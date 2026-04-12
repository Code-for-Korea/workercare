# frozen_string_literal: true

class SuggestEvidenceTool < ApplicationMCPTool
  tool_name "suggest_evidence"
  title "Suggest Evidence"
  description "Analyze rejected cases and suggest additional evidence needed for approval. Rule-based with structured next steps."
  read_only
  open_world false

  property :user_symptoms,
           type: "string",
           description: "User-described symptoms (e.g., 손목 저림과 통증)",
           required: true

  property :user_work_environment,
           type: "string",
           description: "User's work environment (e.g., 사무실, 하루 8시간 컴퓨터 작업)",
           required: true

  collection :current_evidence,
             type: "string",
             description: "List of evidence the user already has (e.g., [\"정형외과 진단서\"])",
             required: false

  collection :rejected_case_nos,
             type: "string",
             description: "Array of rejected case numbers to analyze (e.g., [\"2023-000123\"])",
             required: false

  property :disease_category,
           type: "string",
           description: "Disease category. Allowed: musculoskeletal, other_disease, hearing_loss, cardiovascular, cancer, pneumoconiosis, respiratory",
           required: true

  def perform
    rules = load_rules
    unless rules
      return render structured: {
        error: "해당 질병 카테고리의 증거 규칙을 찾을 수 없습니다.",
        data: nil
      }
    end

    missing = build_missing_evidence(rules)
    recommended = build_recommended_cases
    steps = build_next_steps(rules, missing)
    legal = build_legal_basis

    render structured: {
      error: nil,
      data: {
        missing_evidence: missing,
        recommended_cases: recommended,
        next_steps: steps,
        legal_basis: legal,
        llm_tailored_advice: nil
      }
    }
  rescue => e
    Rails.logger.error("[SuggestEvidenceTool] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    render structured: {
      error: "증거 자료 제안 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
      data: nil
    }
  end

  private

  def load_rules
    yaml = YAML.load_file(Rails.root.join("config/evidence_rules.yml"))
    yaml[disease_category.to_s]
  rescue Errno::ENOENT
    nil
  end

  def build_missing_evidence(rules)
    current = Array(current_evidence).map { |e| normalize_evidence_name(e) }
    missing = []

    Array(rules["required"]).each do |item|
      next if current.any? { |c| c.include?(normalize_evidence_name(item["key"])) }

      missing << {
        type: item["type"],
        importance: "필수",
        rationale: item["rationale"],
        where_to_get: item["where_to_get"],
        estimated_time: estimate_time(item["key"]),
        estimated_cost: estimate_cost(item["key"])
      }
    end

    Array(rules["optional"]).each do |item|
      next if current.any? { |c| c.include?(normalize_evidence_name(item["key"])) }
      next unless item["importance"] == "high"

      missing << {
        type: item["type"],
        importance: "권장",
        rationale: item["rationale"],
        where_to_get: item["where_to_get"],
        estimated_time: estimate_time(item["key"]),
        estimated_cost: estimate_cost(item["key"])
      }
    end

    missing
  end

  def normalize_evidence_name(name)
    name.to_s.downcase.gsub(/\s+/, "")
  end

  def estimate_time(key)
    case key
    when "objective_test", "cardio_test", "lung_test", "hearing_test", "cancer_diagnosis"
      "1주 내"
    when "medical_opinion", "overwork_proof", "noise_exposure", "carcinogen_exposure"
      "진료 시 즉시"
    when "workload_proof", "work_hours", "stress_factor"
      "1주 내"
    when "coworker_statement", "cluster_case"
      "2주 내"
    when "medical_history", "exposure_duration"
      "2~4주"
    else
      "1주 내"
    end
  end

  def estimate_cost(key)
    case key
    when "objective_test", "cardio_test", "lung_test", "hearing_test"
      "건강보험 적용 시 5~10만원"
    when "cancer_diagnosis"
      "건강보험 적용 시 10~30만원"
    when "medical_opinion", "overwork_proof"
      "묵요"
    when "workload_proof", "work_hours"
      "묵요"
    when "coworker_statement", "cluster_case"
      "묵요"
    else
      "묵요"
    end
  end

  def build_recommended_cases
    return [] if rejected_case_nos.blank?

    cases = []
    nos = Array(rejected_case_nos)

    DiseaseCase.where(case_no: nos).find_each do |rejected_case|
      follow_up = DiseaseCase
        .where.not(id: rejected_case.id)
        .where(disease_name: rejected_case.disease_name)
        .where(result: ["approved", "revised_approved"])
        .order(year: :desc)
        .first

      next unless follow_up

      lesson = extract_key_lesson(follow_up.committee_decision)
      title = build_case_title(follow_up.committee_decision)

      cases << {
        case_no: follow_up.case_no,
        title: title,
        key_lesson: lesson
      }
    end

    cases
  end

  def extract_key_lesson(text)
    return "키워드 추출 실패" if text.blank?

    keywords = %w[인정 전환 보완 재신청 추가 근전도 동료 증언]
    sentences = text.split(/[.!?。]/)

    target = sentences.find { |s| keywords.any? { |kw| s.include?(kw) } }
    target = text if target.blank?

    truncate(target.strip, 100)
  end

  def build_case_title(text)
    return "불인정 후 인정 전환 사례" if text.blank?

    methods = []
    methods << "추가 근전도 검사" if text.include?("근전도")
    methods << "동료 증언" if text.include?("동료") || text.include?("증언")
    methods << "추가 자료 제출" if text.include?("자료") || text.include?("제출")
    methods << "재신청" if text.include?("재신청")

    if methods.any?
      "#{methods.join(" 및 ")}으로 인정 전환"
    else
      "추가 증거로 인정 전환 사례"
    end
  end

  def build_next_steps(rules, missing_evidence)
    steps = []

    steps << {
      action: "산재 지정병원 방문 → 원무과에 최초요양급여신청 대행 요청",
      deadline: "즉시"
    }

    missing_evidence.each do |ev|
      case ev[:type]
      when /객관적|검사|심전도|심장초음파|폐기능|청력|병리/
        steps << {
          action: "#{ev[:type]} 실시 및 결과 보관",
          deadline: ev[:estimated_time] || "1주 내"
        }
      when /소견서|의견서/
        steps << {
          action: "#{ev[:type]} 발급 (병원 원무과에서 대행 요청 가능)",
          deadline: ev[:estimated_time] || "진료 시 즉시"
        }
      when /업무|근무|작업/
        steps << {
          action: "업무 내 작업 시간, 작업 강도 일지 작성",
          deadline: ev[:estimated_time] || "1주 내"
        }
      when /동료|집단/
        steps << {
          action: "동료 2명 이상의 업무 환경 증언 확보 (서면 또는 녹취)",
          deadline: ev[:estimated_time] || "2주 내"
        }
      end
    end

    steps << {
      action: "근로복지공단 관할 지사에 서류 제출 (사업주 날인 불필요)",
      deadline: "준비 완료 후"
    }

    steps.uniq
  end

  def build_legal_basis
    [
      "산업재해보상보험법 제37조: 업무와 재해 사이의 상당인과관계 필요",
      "산업재해보상보험법 제41조: 산재보험 의료기관의 요양급여신청 대행 가능"
    ]
  end

  def truncate(text, max_length)
    return "" if text.blank?
    text.length > max_length ? "#{text[0...max_length]}..." : text
  end
end
