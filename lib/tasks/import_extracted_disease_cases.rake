namespace :import do
  desc "추출된 직업/근무조건/신체부위/사망/신청서 데이터 CSV 임포트\n" \
       "  사용법: rails 'import:extracted_disease_cases[wip/extract_disease_cases_details_cerebras-ksco.csv]'"
  task :extracted_disease_cases, [:path] => :environment do |_, args|
    require "csv"
    require "json"
    path = args[:path] or abort "CSV 경로를 지정하세요."
    raise "파일 없음: #{path}" unless File.exist?(path)

    rows = CSV.read(path, headers: true, encoding: "UTF-8")
    puts "추출 데이터: #{rows.size}건"

    imported = 0
    errors = 0

    rows.each do |row|
      case_no = row["case_no"].to_s.strip
      record = DiseaseCase.find_by(case_no: case_no)
      unless record
        warn "판정서 없음: #{case_no}"
        errors += 1
        next
      end

      # 1. 기존 DiseaseCase 속성 업데이트 (숫자 필드는 반드시 to_i/to_d로 저장 — job_tenure_months/max_item_weight/
      #    daily_total_weight는 wip/cerebras_prompts.rb 추출 스키마상 숫자이므로 문자열로 남기지 않는다)
      record.update!(
        job_name: row["직종명"].to_s.strip,
        job_description: row["담당_업무"].to_s.strip,
        employment_type: row["고용_형태"].to_s.strip,
        work_type: row["근무_형태"].to_s.strip,
        job_tenure_months: row["현_직종_총_종사기간"].to_s.strip.presence&.to_i,
        weekly_work_hours: row["1주_평균_근무시간"].to_s.strip.presence&.to_d,
        daily_work_hours: row["1일_평균_근무시간"].to_s.strip.presence&.to_d,
        burden_body_part: row["부담_신체_부위"].to_s.strip,
        bad_posture: row["주요_부적절한_자세"].to_s.strip,
        heavy_lifting: row["중량물_취급_여부"].to_s.strip,
        max_item_weight: row["취급_물품_최대_무게"].to_s.strip.presence&.to_d,
        daily_total_weight: row["1일_취급_총_누적_중량"].to_s.strip.presence&.to_d,
        other_harmful_factors: row["기타_유해요인_노출"].to_s.strip,
        work_relevance_eval: row["업무관련성_평가"].to_s.strip,
        aggravating_factors: row["업묵부담_가중요인_노출"].to_s.strip,
        main_reasoning: row["판단_주요_근거"].to_s.strip,
        death_status: row["사망_여부"].to_s.strip,
        application_type: row["신청서_종류"].to_s.strip
      )

      # 1-1. 최종_산재_인정_여부와 기존 result 비교 — 덮어쓰지 않고 불일치만 로그
      #      (import_disease_cases.rake의 전역 상수 RESULT_MAP을 그대로 재사용)
      extracted_result_raw = row["최종_산재_인정_여부"].to_s.strip
      extracted_result = RESULT_MAP[extracted_result_raw]
      if extracted_result && record.result.present? && record.result != extracted_result
        warn "result 불일치 (case_no=#{case_no}): 기존=#{record.result} 추출=#{extracted_result}"
      end

      # 2. KSCO 매핑 동기화 (JSON 파싱) — 이번 CSV의 ksco_codes_json을 "전체 목표 집합"으로 취급한다.
      #    이 데이터는 추출 프롬프트/모델이 개선될 때마다 재추출·재임포트되므로, upsert만 하면
      #    이전에 붙었지만 이번에는 빠진 코드가 그대로 남아 ksco_code 필터가 오래된(false positive)
      #    매핑까지 매칭하게 된다. 그래서 파싱에 성공했을 때만 "현재 JSON에 없는 매핑은 제거"까지 함께 수행한다.
      #    current_codes는 "이번 JSON에 언급된 코드 전체"여야 한다 — KscoCode 테이블에 아직 없어서
      #    skip한 코드도 포함해야, 참조 데이터 누락이 기존 매핑의 데이터 손실로 이어지지 않는다.
      ksco_json = row["ksco_codes_json"].to_s.strip
      if ksco_json.present?
        parsed =
          begin
            JSON.parse(ksco_json)
          rescue JSON::ParserError => e
            warn "ksco_codes_json 파싱 실패, KSCO 매핑 동기화 건너뜀 (case_no=#{case_no}): #{e.message}"
            nil
          end

        if parsed
          current_codes = []
          parsed.each do |item|
            code = item["ksco_code"].to_s.strip
            next if code.blank?

            current_codes << code

            ksco = KscoCode.find_by(code: code)
            unless ksco
              warn "KSCO 코드 없음: #{code} (case_no=#{case_no}) — 매핑은 유지, 참조 데이터 보완 후 재실행 필요"
              next
            end

            record.disease_case_ksco_codes.find_or_initialize_by(ksco_code_id: code).update!(
              similarity: item["similarity"].to_f
            )
          end

          # JSON 파싱에 성공했을 때만 "이번 JSON에 없는 매핑 제거"를 수행한다.
          record.disease_case_ksco_codes.where.not(ksco_code_id: current_codes).destroy_all
        end
      end
      # ksco_codes_json이 비어있거나 파싱 실패한 행은 삭제 동기화를 건너뛴다 — "비어있음"과
      # "필드 누락/파싱 실패"를 구분할 수 없으므로 삭제보다 보존을 택하는 안전한 기본값이다.

      imported += 1
    rescue => e
      errors += 1
      warn "오류 (case_no=#{case_no}): #{e.message}"
    end

    puts "추출 데이터 임포트 완료: #{imported}건 / 오류: #{errors}건"

    ActiveRecord::Base.connection.execute(
      "INSERT INTO disease_cases_extracted_fts(disease_cases_extracted_fts) VALUES('rebuild')"
    )
    puts "Extracted FTS rebuild 완료"
  end
end
