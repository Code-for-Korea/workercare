namespace :import do
  RESULT_MAP = {
    "인정"     => "approved",
    "불인정"   => "rejected",
    "일부인정" => "partially_approved",
    "변경인정" => "revised_approved"
  }.freeze

  CATEGORY_MAP = {
    "근골격계질병"    => "musculoskeletal",
    "기타질병"        => "other_disease",
    "소음성난청"      => "hearing_loss",
    "뇌심혈관계질병"  => "cardiovascular",
    "암"              => "cancer",
    "진폐"            => "pneumoconiosis",
    "호흡기질병"      => "respiratory"
  }.freeze

  BODY_PART_MAP = {
    "흉부/등"    => "chest_back",
    "귀"         => "ear",
    "기타"       => "other",
    "눈"         => "eye",
    "다리"       => "leg",
    "머리/뇌"    => "head",
    "목"         => "neck",
    "발/발가락"  => "foot",
    "복부"       => "abdomen",
    "복합부위"   => "multiple",
    "비뇨생식기" => "urogenital",
    "소화기"     => "digestive",
    "손/손가락"  => "hand",
    "순환기"     => "circulatory",
    "신경계"     => "nervous_system",
    "안면"       => "face",
    "엉덩이"     => "hip",
    "전신"       => "whole_body",
    "팔"         => "arm",
    "허리"       => "lower_back",
    "호흡기"     => "respiratory_organ"
  }.freeze

  desc "업무상질병 판정서 CSV 임포트\n" \
       "  사용법: rails 'import:disease_cases[판정서.csv,목록.csv]'"
  task :disease_cases, [:cases_path, :list_path] => :environment do |_, args|
    require "csv"
    cases_path = args[:cases_path] or abort "판정서 CSV 경로를 첫 번째 인자로 지정하세요."
    list_path  = args[:list_path]  or abort "목록 CSV 경로를 두 번째 인자로 지정하세요."

    raise "파일 없음: #{cases_path}" unless File.exist?(cases_path)
    raise "파일 없음: #{list_path}"  unless File.exist?(list_path)

    # comwel_list.csv에서 연번 → 링크 맵 구성
    link_map = {}
    CSV.foreach(list_path, headers: true, encoding: "UTF-8") do |row|
      no   = row["연번"].to_s.strip
      link = row["링크"].to_s.strip
      link_map[no] = link if no.present? && link.present?
    end
    puts "링크 맵: #{link_map.size}건"

    # 판정서 본문 로드
    rows = CSV.read(cases_path, headers: true, encoding: "UTF-8")
    puts "판정서: #{rows.size}건"

    # 연번 검증
    case_nos = rows.map { |r| r["연번"].to_s.strip }
    raise "연번 nil 포함" if case_nos.any?(&:blank?)

    dups = case_nos.group_by(&:itself).select { |_, v| v.size > 1 }.keys
    warn "연번 중복: #{dups}" if dups.any?

    # 링크 없는 row 경고
    rows.each do |r|
      no = r["연번"].to_s.strip
      warn "링크 없음: 연번=#{no}" unless link_map.key?(no)
    end

    imported = 0
    errors   = 0

    rows.each do |row|
      no = row["연번"].to_s.strip

      result_raw   = row["심의결과"].to_s.strip
      category_raw = row["질병분류"].to_s.strip
      body_raw     = row["신체부위"].to_s.strip

      raise "Unknown result '#{result_raw}' (연번=#{no})" unless RESULT_MAP.key?(result_raw)

      decided_raw = row["판정일"].to_s.strip
      decided_on  = decided_raw.present? ? (Date.parse(decided_raw) rescue nil) : nil

      attrs = {
        disease_name:        row["신청질병"].to_s.strip,
        result:              RESULT_MAP[result_raw],
        year:                row["심의연도"].to_s.strip.to_i,
        disease_category:    CATEGORY_MAP[category_raw],
        body_part:           BODY_PART_MAP[body_raw],
        link:                link_map[no],
        statement:           row["주문"].to_s.strip,
        claim_purpose:       row["청구 취지"].to_s.strip,
        application_content: row["신청 내용"].to_s.strip,
        applicant_claim:     row["신청인 주장"].to_s.strip,
        medical_records:     row["진료기록 및 의학적 소견"].to_s.strip,
        recognized_facts:    row["인정 사실"].to_s.strip,
        related_laws:        row["관계 법령"].to_s.strip,
        committee_decision:  row["위원회 판단 및 결론"].to_s.strip,
        decided_on:          decided_on
      }

      record = DiseaseCase.find_or_initialize_by(case_no: no)
      record.assign_attributes(attrs)
      record.save!
      imported += 1
    rescue => e
      errors += 1
      warn "오류 (연번=#{no}): #{e.message}"
    end

    puts "임포트 완료: #{imported}건 / 오류: #{errors}건"

    ActiveRecord::Base.connection.execute(
      "INSERT INTO disease_cases_fts(disease_cases_fts) VALUES('rebuild')"
    )
    puts "FTS rebuild 완료"
  end
end

namespace :fts do
  desc "FTS5 인덱스 전체 재구성"
  task rebuild: :environment do
    ActiveRecord::Base.connection.execute(
      "INSERT INTO disease_cases_fts(disease_cases_fts) VALUES('rebuild')"
    )
    puts "FTS rebuild 완료"
  end
end
