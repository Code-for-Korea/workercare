# frozen_string_literal: true

module DiseaseCases
  # 검색 결과와 상세를 마크다운으로 만든다(LLM·스크립트용). HTML 화면과 같은 스코프를 받아 표현만 바꾸고
  # 새 조회 로직은 두지 않는다. 문서: docs/markdown-responses.md
  #
  # ERB 대신 PORO인 이유: ERB는 기본 HTML 이스케이프가 걸려 `&amp;`가 섞이고, 표 셀의 `|`·개행 처리를
  # 한곳에서 테스트하기 어렵다. 본문은 PIIMasking을 거친다(웹 HTML은 마스킹하지 않는다).
  class MarkdownRenderer
    DISCLAIMER = "이 자료는 근로복지공단 업무상질병 판정서를 검색한 참고용 결과입니다. " \
                 "개인의 산재 인정 여부를 예측하거나 의료·법률 판단을 대신하지 않습니다."

    # 쿼리 파라미터 설명. 허용값은 코드에서 가져온다(하드코딩 금지).
    USAGE_PARAMS = %i[q job_name job_name_any job_description disease_name application_type employment_type work_type
                      work_relevance_eval death_status burden_body_part sort page].freeze

    def initialize(base_url:)
      @base_url = base_url.to_s.chomp("/")
    end

    # cases: 한 쪽의 DiseaseCase, pagy: Pagy, metadata: DiseaseCasesController#build_metadata,
    # path: "/index" | "/search", query: 쪽 링크에 유지할 쿼리, options: 필터 허용값(컨트롤러의 옵션 목록)
    def search(cases:, pagy:, metadata:, path:, query:, options:)
      lines = [ "# #{I18n.t('search.title')}", "" ]
      lines.concat(summary_lines(metadata, pagy, query))
      lines << I18n.t("search.fallback_notice") << "" if metadata[:used_fallback]

      if cases.empty?
        lines << I18n.t("search.no_results") << ""
      else
        lines.concat(case_table(cases))
        lines.concat(pagination_lines(pagy, path, query))
      end

      lines.concat(usage_lines(path, options))
      lines << "---" << "" << DISCLAIMER << ""
      lines.join("\n")
    end

    def show(disease_case)
      c = disease_case
      lines = [ "# #{inline(c.disease_name.presence || '미상')}", "" ]
      lines << "- #{label(:case_no)}: #{inline(c.case_no)}"
      lines << "- #{label(:result)}: #{inline(c.human_attribute_enum(:result))}"
      lines << "- #{label(:disease_category)}: #{inline(c.human_attribute_enum(:disease_category))}"
      lines << "- #{label(:body_part)}: #{inline(c.human_attribute_enum(:body_part))}"
      lines << "- #{label(:decided_on)}: #{c.decided_on.present? ? I18n.l(c.decided_on) : "#{c.year}년"}"
      lines << "- #{label(:link)}: #{c.link}" if c.link.present?
      lines << ""

      lines.concat(extracted_table(c))

      DiseaseCase.detail_sections.each do |attr, title|
        body = c.public_send(attr)
        next if body.blank?

        lines << "## #{title}" << ""
        lines.concat(quote(PIIMasking.mask(body)))
        lines << ""
      end

      reasoning = c.main_reasoning
      if reasoning.present?
        lines << "## #{label(:main_reasoning)}" << ""
        lines.concat(quote(PIIMasking.mask(reasoning)))
        lines << ""
      end

      lines << "---" << "" << DISCLAIMER << ""
      lines.join("\n")
    end

    # 표 셀: 개행은 공백으로, `|`는 이스케이프, HTML 태그가 되지 않도록 `<`·`>`를 바꾼다.
    def cell(text)
      inline(text).presence || "-"
    end

    def inline(text)
      text.to_s.gsub(/\r?\n+/, " ").gsub("\\", "\\\\\\\\").gsub("|", "\\|")
        .gsub("<", "&lt;").gsub(">", "&gt;").strip
    end

    private

    def label(attr)
      DiseaseCase.human_attribute_name(attr)
    end

    # 본문은 인용 블록으로 넣어 본문 속 `#`·`-`가 문서 구조를 바꾸지 못하게 한다.
    def quote(text)
      text.to_s.gsub("<", "&lt;").gsub(">", "&gt;").each_line.map { |l| "> #{l.chomp}".rstrip }
    end

    def summary_lines(metadata, pagy, query)
      lines = []
      lines << "- 검색어: #{inline(query['q'])}" if query["q"].present?
      if metadata[:over_cap]
        lines << "- #{I18n.t('search.over_cap')}"
      elsif metadata[:total_count]
        lines << "- 결과: #{metadata[:total_count]}#{I18n.t('search.results')} (#{pagy.page}/#{[ pagy.last, 1 ].max}쪽)"
      end
      lines << "" if lines.any?
      lines
    end

    def case_table(cases)
      headers = %i[case_no disease_name job_name job_description application_type work_type
                   work_relevance_eval death_status result year]
      lines = [ "| #{headers.map { |h| label(h) }.join(' | ')} |", "|#{'---|' * headers.size}" ]
      cases.each do |c|
        lines << "| #{[
          "[#{inline(c.case_no)}](#{case_url(c.case_no)})",
          cell(c.disease_name),
          cell(c.job_name),
          cell(truncate(c.job_description, 40)),
          cell(c.application_type),
          cell(truncate(c.work_type, 40)),
          cell(c.work_relevance_eval&.tr("_", " ")),
          c.death_status == "Y" ? I18n.t("search.death_badge") : "-",
          cell(c.human_attribute_enum(:result)),
          c.year.present? ? "#{c.year}년" : "-"
        ].join(' | ')} |"
      end
      lines << ""
    end

    def pagination_lines(pagy, path, query)
      links = []
      links << "[이전 쪽](#{page_url(path, query, pagy.previous)})" if pagy.previous
      links << "[다음 쪽](#{page_url(path, query, pagy.next)})" if pagy.next
      links.empty? ? [] : [ links.join(" · "), "" ]
    end

    def extracted_table(c)
      rows = {
        job_name: c.job_name, job_description: c.job_description,
        employment_type: c.employment_type, work_type: c.work_type,
        application_type: c.application_type, burden_body_part: c.burden_body_part,
        work_relevance_eval: c.work_relevance_eval&.tr("_", " "),
        death_status: c.death_status
      }.select { |_, v| v.present? }
      return [] if rows.empty?

      lines = [ "## 추출 정보", "", "| 항목 | 값 |", "|---|---|" ]
      rows.each { |attr, value| lines << "| #{label(attr)} | #{cell(PIIMasking.mask(value))} |" }
      lines << ""
    end

    def usage_lines(path, options)
      lines = [ "## 검색 방법", "", "`#{@base_url}#{path}.md?q=손목&job_name=운전원` 처럼 쿼리 파라미터를 붙입니다. " \
                "같은 주소에 `Accept: text/markdown` 헤더를 보내도 됩니다.", "" ]
      lines << "| 파라미터 | 설명 | 허용값 |" << "|---|---|---|"
      USAGE_PARAMS.each do |param|
        lines << "| `#{param}` | #{inline(param_description(param))} | #{inline(allowed_values(param, options))} |"
      end
      lines << ""
    end

    def param_description(param)
      {
        q: "검색어", job_name: "직종명(부분 일치)",
        job_name_any: "핵심어 중 하나라도 포함하는 직업명(띄어쓰기 무시). 배열로 여러 개: job_name_any[]=택배&job_name_any[]=배송",
        job_description: "담당 업무(부분 일치)",
        disease_name: "신청질병", application_type: "신청서 종류. 여러 개를 주면 하나라도 포함(OR)",
        employment_type: "고용 형태", work_type: "근무 형태", work_relevance_eval: "업무관련성 평가",
        death_status: "사망 사례만(Y)", burden_body_part: "부담 신체 부위. 여러 개 가능",
        sort: "정렬. 생략하면 관련도순, recent는 최신순", page: "쪽 번호"
      }.fetch(param)
    end

    def allowed_values(param, options)
      case param
      when :application_type then Array(options[:application_type]).join(", ")
      when :employment_type then Array(options[:employment_type]).join(", ")
      when :work_type then Array(options[:work_type]).join(", ")
      when :work_relevance_eval then Array(options[:work_relevance_eval]).join(", ")
      when :death_status then "Y"
      when :burden_body_part then Array(options[:burden_body_part]).join(", ")
      when :sort then "recent"
      else ""
      end
    end

    def case_url(case_no)
      "#{@base_url}/disease_cases/#{ERB::Util.url_encode(case_no)}.md"
    end

    def page_url(path, query, page)
      "#{@base_url}#{path}.md?#{query.merge('page' => page).to_query}"
    end

    def truncate(text, length)
      text.to_s.truncate(length)
    end
  end
end
