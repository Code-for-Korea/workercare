# frozen_string_literal: true

class CompareApprovalFactorsTool < ApplicationMCPTool
  tool_name "compare_approval_factors"
  description "Statistically compare approved vs rejected disease cases to identify key approval/rejection factors."

  property :disease_name,
           type: "string",
           description: "Specific disease name to filter by (e.g., 손목터널증후군)",
           required: false

  property :disease_category,
           type: "string",
           description: "Disease category. Allowed: musculoskeletal, other_disease, hearing_loss, cardiovascular, cancer, pneumoconiosis, respiratory",
           required: true

  property :body_part,
           type: "string",
           description: "Body part. Allowed: chest_back, ear, other, eye, leg, head, neck, foot, abdomen, multiple, urogenital, digestive, hand, circulatory, nervous_system, face, hip, whole_body, arm, lower_back, respiratory_organ",
           required: false

  property :year_range,
           type: "array",
           description: "Year range as [start_year, end_year] (e.g., [2020, 2025])",
           required: false

  output_schema do
    property :error, type: "string", required: false
    property :data, type: "object", required: false do
      object :statistics do
        property :approved_count, type: "number", required: true
        property :rejected_count, type: "number", required: true
        property :partially_approved_count, type: "number", required: true
        property :revised_approved_count, type: "number", required: true
        property :approval_rate, type: "string", required: true
        property :rejection_rate, type: "string", required: true
      end

      object :approved_common_patterns do
        property :medical_evidence, type: "string"
        property :work_relation, type: "string"
        property :objective_findings, type: "string"
      end

      object :rejected_common_patterns do
        property :medical_evidence, type: "string"
        property :work_relation, type: "string"
        property :objective_findings, type: "string"
      end

      array :key_differences do
        object :difference do
          property :factor, type: "string", required: true
          property :approved, type: "string", required: true
          property :rejected, type: "string", required: true
        end
      end

      object :detailed_evidence_stats do
      end

      property :llm_explanation, type: "string", required: false
    end
  end

  def perform
    rules = load_extraction_rules

    approved_cases = fetch_cases("approved")
    rejected_cases = fetch_cases("rejected")
    partially_approved_cases = fetch_cases("partially_approved")
    revised_approved_cases = fetch_cases("revised_approved")

    total = approved_cases.count + rejected_cases.count + partially_approved_cases.count + revised_approved_cases.count

    if total.zero?
      return render structured: {
        error: nil,
        data: {
          statistics: zero_statistics,
          approved_common_patterns: {},
          rejected_common_patterns: {},
          key_differences: [],
          detailed_evidence_stats: {},
          llm_explanation: nil
        }
      }
    end

    approved_stats = extract_evidence_stats(approved_cases, rules)
    rejected_stats = extract_evidence_stats(rejected_cases, rules)

    statistics = build_statistics(
      approved_cases.count,
      rejected_cases.count,
      partially_approved_cases.count,
      revised_approved_cases.count
    )

    approved_patterns = build_common_patterns(approved_stats, approved_cases.count)
    rejected_patterns = build_common_patterns(rejected_stats, rejected_cases.count)
    key_diffs = build_key_differences(approved_stats, rejected_stats, rules)
    detailed_stats = build_detailed_evidence_stats(approved_stats, rejected_stats)

    render structured: {
      error: nil,
      data: {
        statistics: statistics,
        approved_common_patterns: approved_patterns,
        rejected_common_patterns: rejected_patterns,
        key_differences: key_diffs,
        detailed_evidence_stats: detailed_stats,
        llm_explanation: nil
      }
    }
  rescue => e
    Rails.logger.error("[CompareApprovalFactorsTool] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    render structured: {
      error: "비교 분석 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
      data: nil
    }
  end

  private

  def load_extraction_rules
    yaml = YAML.load_file(Rails.root.join("config/evidence_rules.yml"))
    category_rules = yaml[disease_category.to_s]
    return {} unless category_rules && category_rules["extraction_rules"]

    category_rules["extraction_rules"].transform_values do |rule|
      {
        keywords: Array(rule["keywords"]).map { |k| Regexp.new(k, Regexp::IGNORECASE) },
        positive: Array(rule["positive"]).map { |p| Regexp.new(p, Regexp::IGNORECASE) },
        negative: Array(rule["negative"]).map { |n| Regexp.new(n, Regexp::IGNORECASE) },
        not_performed: Array(rule["not_performed"]).map { |np| Regexp.new(np, Regexp::IGNORECASE) }
      }
    end
  rescue Errno::ENOENT
    {}
  end

  def fetch_cases(result_value)
    params = {}
    params[:q] = disease_name if disease_name.present?
    params[:result] = result_value
    params[:disease_category] = [disease_category] if disease_category.present?
    params[:body_part] = [body_part] if body_part.present?

    if year_range.present? && year_range.size >= 2
      params[:decided_on_from] = Date.new(year_range[0].to_i, 1, 1)
      params[:decided_on_to] = Date.new(year_range[1].to_i, 12, 31)
    end

    scope, _fallback = DiseaseCase.search(params)
    scope
  end

  def extract_evidence_stats(cases, rules)
    stats = {}

    rules.each do |rule_name, rule|
      stats[rule_name] = { positive: 0, negative: 0, not_performed: 0, unknown: 0 }
    end

    cases.find_each do |c|
      text = [c.recognized_facts, c.committee_decision, c.medical_records].compact.join(" ")

      rules.each do |rule_name, rule|
        status = extract_status(text, rule)
        next unless status

        stats[rule_name][status] += 1
      end
    end

    stats
  end

  def extract_status(text, rule)
    return nil unless rule[:keywords].any? { |k| text.match?(k) }

    context = extract_context(text, Regexp.union(rule[:keywords]))

    return :not_performed if match_any?(context, rule[:not_performed])
    return :positive if match_any?(context, rule[:positive])
    return :negative if match_any?(context, rule[:negative])

    :unknown
  end

  def extract_context(text, keyword_regex, window: 30)
    match = text.match(keyword_regex)
    return text unless match

    start_pos = [match.begin(0) - window, 0].max
    end_pos = [match.end(0) + window, text.length].min
    text[start_pos...end_pos]
  end

  def match_any?(text, patterns)
    patterns.any? { |p| text.match?(p) }
  end

  def build_statistics(approved, rejected, partially_approved, revised_approved)
    total = approved + rejected + partially_approved + revised_approved
    {
      approved_count: approved,
      rejected_count: rejected,
      partially_approved_count: partially_approved,
      revised_approved_count: revised_approved,
      approval_rate: format_rate((approved + partially_approved + revised_approved).to_f / total),
      rejection_rate: format_rate(rejected.to_f / total)
    }
  end

  def zero_statistics
    {
      approved_count: 0,
      rejected_count: 0,
      partially_approved_count: 0,
      revised_approved_count: 0,
      approval_rate: "0.0%",
      rejection_rate: "0.0%"
    }
  end

  def format_rate(value)
    total = value.finite? ? (value * 100).round(1) : 0.0
    "#{total}%"
  end

  def build_common_patterns(stats, total_count)
    return {} if total_count.zero?

    patterns = {}

    stats.each do |rule_name, counts|
      next if counts.values.sum.zero?

      dominant = counts.max_by { |_k, v| v }
      next unless dominant

      label = case dominant[0]
              when :positive then "#{rule_name} 양성률"
              when :negative then "#{rule_name} 정상/음성률"
              when :not_performed then "#{rule_name} 미실시률"
              when :unknown then "#{rule_name} 결과 불명률"
              end

      rate = (dominant[1].to_f / total_count * 100).round(0)
      patterns[rule_name.to_s] = "#{label} #{rate}%"
    end

    patterns
  end

  def build_key_differences(approved_stats, rejected_stats, rules)
    differences = []

    rules.each do |rule_name, _rule|
      a_counts = approved_stats[rule_name] || { positive: 0, negative: 0, not_performed: 0, unknown: 0 }
      r_counts = rejected_stats[rule_name] || { positive: 0, negative: 0, not_performed: 0, unknown: 0 }

      a_total = a_counts.values.sum
      r_total = r_counts.values.sum

      next if a_total.zero? && r_total.zero?

      a_dominant = a_counts.max_by { |_k, v| v }
      r_dominant = r_counts.max_by { |_k, v| v }

      a_desc = a_dominant ? "#{a_dominant[0]} #{a_dominant[1]}건" : "해당 없음"
      r_desc = r_dominant ? "#{r_dominant[0]} #{r_dominant[1]}건" : "해당 없음"

      differences << {
        factor: rule_name.to_s,
        approved: a_desc,
        rejected: r_desc
      }
    end

    differences
  end

  def build_detailed_evidence_stats(approved_stats, rejected_stats)
    detailed = {}

    (approved_stats.keys | rejected_stats.keys).each do |rule_name|
      a = approved_stats[rule_name] || { positive: 0, negative: 0, not_performed: 0, unknown: 0 }
      r = rejected_stats[rule_name] || { positive: 0, negative: 0, not_performed: 0, unknown: 0 }

      detailed[rule_name.to_s] = {
        approved: a,
        rejected: r
      }
    end

    detailed
  end
end
