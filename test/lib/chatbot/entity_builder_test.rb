# frozen_string_literal: true

require "test_helper"

class Chatbot::EntityBuilderTest < ActiveSupport::TestCase
  def config(concepts, min_hits: 2, column: "disease_name")
    {
      "column" => column,
      "min_hits" => min_hits,
      "concepts" => concepts.transform_values { |body| body.transform_keys(&:to_s) }
    }
  end

  def builder(concepts, **options)
    Chatbot::EntityBuilder.new(config(concepts, **options))
  end

  def create_case(case_no, disease_name)
    DiseaseCase.create!(case_no: case_no, disease_name: disease_name, year: 2024)
  end

  setup do
    create_case("EB-1", "우측 견관절 회전근개 파열")
    create_case("EB-2", "회전근개파열")
    create_case("EB-3", "좌측 회전근개  파열/우측 어깨 충돌증후군")
    create_case("EB-4", "어깨 충격증후군")
    create_case("EB-5", "급성심근경색증")
  end

  test "counts matches ignoring spaces and across spelling variants" do
    entity = builder({ "어깨 충돌증후군" => { db: [ "충돌증후군", "충격증후군" ], colloquial: [] } })

    row = entity.rows.first
    assert_equal 2, row.hits # EB-3(충돌), EB-4(충격)
  end

  test "plain_hits shows what a single LIKE on the representative would find" do
    entity = builder({ "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] } })

    row = entity.rows.first
    assert_equal 3, row.hits   # 띄어쓰기 변형 3건 모두
    assert_equal 1, row.plain_hits # '회전근개 파열'(띄어쓰기 1칸)은 EB-1만
  end

  test "concepts below min_hits are dropped from rows but reported" do
    entity = builder({
      "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] },
      "심근경색" => { db: [ "심근경색" ], colloquial: [] }
    }, min_hits: 2)

    assert_equal [ "회전근개 파열" ], entity.rows.map(&:representative)
    assert_equal [ "심근경색" ], entity.dropped.map(&:representative)
  end

  test "rows are ordered by hits then by dictionary order" do
    entity = builder({
      "심근경색" => { db: [ "심근경색" ], colloquial: [] },
      "충돌증후군" => { db: [ "충돌증후군" ], colloquial: [] },
      "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] }
    }, min_hits: 1)

    assert_equal [ "회전근개 파열", "심근경색", "충돌증후군" ], entity.rows.map(&:representative)
  end

  test "synonyms merge colloquial and db variants without the representative or duplicates" do
    entity = builder({
      "회전근개 파열" => { db: [ "회전근개 파열", "회전근개파열", "회전근개 힘줄 파열" ], colloquial: [ "어깨 힘줄 파열", "어깨힘줄 파열", "어깨 힘줄 파열" ] }
    })

    assert_equal [ "어깨 힘줄 파열", "회전근개 힘줄 파열" ], entity.synonyms_for("회전근개 파열")
  end

  test "an expression used by two concepts is rejected" do
    entity = builder({
      "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [ "어깨 파열" ] },
      "어깨 충돌증후군" => { db: [ "충돌증후군" ], colloquial: [ "어깨파열" ] }
    })

    assert_match(/어깨파열.*여러 개념에 중복/, entity.structural_errors.join)
    assert_raises(Chatbot::EntityBuilder::InvalidDictionary) { entity.rows }
  end

  test "a synonym equal to another concept's representative is rejected" do
    entity = builder({
      "뇌경색" => { db: [ "뇌경색" ], colloquial: [] },
      "뇌출혈" => { db: [ "뇌출혈" ], colloquial: [ "뇌 경색" ] }
    })

    assert_match(/뇌경색.*여러 개념에 중복/, entity.structural_errors.join)
  end

  test "consecutive spaces and missing db variants are rejected" do
    entity = builder({
      "회전근개 파열" => { db: [], colloquial: [ "어깨  힘줄" ] }
    })

    errors = entity.structural_errors.join("\n")
    assert_match(/연속 공백/, errors)
    assert_match(/db 표기가 하나도 없습니다/, errors)
  end

  test "column must be a real, plain column name" do
    [ "no_such_column", "disease_name; DROP TABLE disease_cases", "" ].each do |column|
      assert_raises(Chatbot::EntityBuilder::InvalidDictionary, column) do
        builder({ "x" => { db: [ "x" ], colloquial: [] } }, column: column)
      end
    end
  end

  test "to_csv follows the Kakao upload sample: no header, one synonym per column, rows padded to equal width" do
    entity = builder({
      "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [ "어깨 힘줄 파열", "회전근개 찢어짐", "어깨 힘줄파열 증후" ] },
      "충돌증후군" => { db: [ "충돌증후군" ], colloquial: [ "어깨 충돌" ] }
    }, min_hits: 1)

    lines = entity.to_csv.lines.map(&:chomp)
    assert_equal 2, lines.size, "헤더가 없어야 한다"
    assert_equal "회전근개 파열,어깨 힘줄 파열,회전근개 찢어짐,어깨 힘줄파열 증후", lines[0]
    assert_equal "충돌증후군,어깨 충돌,,", lines[1], "모자란 칸은 따옴표 없는 빈 칸으로 채운다"
    assert_equal [ 4 ], CSV.parse(entity.to_csv).map(&:size).uniq
  end

  test "to_csv keeps a synonym that contains a comma in a single quoted cell" do
    entity = builder({ "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [ "어깨, 힘줄 파열" ] } })

    parsed = CSV.parse(entity.to_csv)
    assert_equal [ "회전근개 파열", "어깨, 힘줄 파열" ], parsed.first.compact
  end

  test "write_csv writes UTF-8 without a BOM" do
    entity = builder({ "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] } })
    path = Rails.root.join("tmp/entity_builder_test.csv")

    entity.write_csv(path)
    bytes = File.binread(path)

    assert_not bytes.start_with?("\xEF\xBB\xBF".b)
    assert_equal "회전근개 파열", bytes.force_encoding("UTF-8").lines.first.chomp.split(",").first
  ensure
    FileUtils.rm_f(path)
  end

  test "coverage reports the share of cases matched by any dictionary pattern" do
    entity = builder({ "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] } }, min_hits: 1)

    coverage = entity.coverage
    assert_equal 3, coverage[:matched]
    assert_equal 5, coverage[:total]
    assert_in_delta 0.6, coverage[:ratio]
  end

  test "report lists every kept concept" do
    entity = builder({ "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [] } })

    assert_match(/회전근개 파열\s+1\s+3\s+33%/, entity.report)
    assert_match(/사전이 덮는 사례: 3 \/ 5/, entity.report)
  end

  test "config_path rejects entity names that could escape the config directory" do
    [ "../secrets", "a/b", "Disease", "", nil ].each do |name|
      assert_raises(ArgumentError, name.inspect) { Chatbot::EntityBuilder.config_path(name) }
    end
    assert_equal Rails.root.join("config/chatbot/entities/disease_name.yml"), Chatbot::EntityBuilder.config_path("disease_name")
  end

  # --- 저장소에 커밋된 실제 사전과 CSV ---

  Dir[Rails.root.join(Chatbot::EntityBuilder::CONFIG_DIR, "*.yml")].each do |path|
    test "committed dictionary #{File.basename(path)} has no structural errors" do
      assert_empty Chatbot::EntityBuilder.from_file(path).structural_errors
    end
  end

  Dir[Rails.root.join(Chatbot::EntityBuilder::CONFIG_DIR, "*.yml")].each do |path|
    entity_name = File.basename(path, ".yml")

    test "committed #{entity_name}.csv only contains concepts and synonyms from the dictionary" do
      entity = Chatbot::EntityBuilder.load(entity_name)
      csv_path = Rails.root.join("docs/kakaotalk/entities/#{entity_name}.csv")
      skip "CSV not generated yet" unless csv_path.exist?

      table = CSV.read(csv_path, encoding: "UTF-8")
      assert_operator table.size, :>, 0
      assert_equal [ table.first.size ], table.map(&:size).uniq, "모든 행의 폭이 같아야 한다"
      table.each do |cells|
        representative, *synonyms = cells
        assert_includes entity.concepts.keys, representative, "헤더 행이 섞이면 안 된다"
        assert_equal entity.synonyms_for(representative), synonyms.compact, representative
        assert_equal synonyms.compact, synonyms.first(synonyms.compact.size), "빈 칸은 행 끝에만 있어야 한다"
      end
      assert_equal table.size, table.map(&:first).uniq.size
    end
  end

  # --- decision_type: 서버의 변환표와 어긋나면 챗봇이 판정 필터를 조용히 버린다 ---

  test "decision_type representatives are exactly what the Kakao request adapter understands" do
    entity = Chatbot::EntityBuilder.load("decision_type")
    understood = Chatbot::KakaoRequestAdapter::RESULT_BY_LABEL.keys + Chatbot::KakaoRequestAdapter::ANY_RESULT_LABELS

    entity.concepts.each_key do |representative|
      assert_includes understood, representative, "서버가 모르는 대표 엔트리: #{representative}"
      payload = { "action" => { "params" => { "decision_type" => representative } } }
      conditions = Chatbot::KakaoRequestAdapter.new(payload).conditions
      assert_empty conditions.ignored, representative
    end
    assert_equal Chatbot::KakaoRequestAdapter::RESULT_BY_LABEL.keys.sort,
      (entity.concepts.keys - [ "전체" ]).sort, "서버의 판정 라벨과 사전의 개념이 달라졌습니다"
  end

  test "decision_type maps every representative to the matching enum value" do
    entity = Chatbot::EntityBuilder.load("decision_type")

    entity.concepts.each do |representative, body|
      next if representative == "전체"

      assert_equal 1, body[:db].size, representative
      payload = { "action" => { "params" => { "decision_type" => representative } } }
      assert_equal body[:db].first, Chatbot::KakaoRequestAdapter.new(payload).conditions.result
    end
    assert_empty Chatbot::EntityBuilder.load("decision_type").concepts.values.flat_map { |b| b[:db] } - DiseaseCase.results.keys
  end

  # --- match: exact / fts ---

  test "match must be one of the supported modes" do
    assert_raises(Chatbot::EntityBuilder::InvalidDictionary) do
      Chatbot::EntityBuilder.new({ "match" => "regex", "column" => "disease_name", "concepts" => {} })
    end
  end

  test "exact mode counts enum values and keeps the enum values out of the synonyms" do
    DiseaseCase.where(case_no: %w[EB-1 EB-2 EB-3]).update_all(result: "approved")
    DiseaseCase.where(case_no: "EB-4").update_all(result: "rejected")
    entity = Chatbot::EntityBuilder.new({
      "column" => "result", "match" => "exact", "min_hits" => 1,
      "concepts" => {
        "인정" => { "db" => [ "approved" ], "colloquial" => [ "승인" ] },
        "불인정" => { "db" => [ "rejected" ], "colloquial" => [ "기각" ] },
        "전체" => { "db" => [ "approved", "rejected" ], "colloquial" => [ "모두" ] }
      }
    })

    hits = entity.rows.to_h { |row| [ row.representative, row.hits ] }
    assert_equal({ "전체" => 4, "인정" => 3, "불인정" => 1 }, hits)
    assert_equal [ "승인" ], entity.synonyms_for("인정")
    assert_empty entity.structural_errors, "전체와 인정이 같은 enum 값을 가져도 중복이 아니다"
    assert_not_includes entity.to_csv, "approved"
  end

  test "fts mode measures hits with main_search and compares the representative alone" do
    DiseaseCase.where(case_no: "EB-1").update_all(job_description: "반복적인 동작으로 어깨 사용")
    DiseaseCase.where(case_no: "EB-2").update_all(job_description: "반복 작업 수행")
    DiseaseCase.where(case_no: "EB-3").update_all(job_description: "야간 교대 근무")
    entity = Chatbot::EntityBuilder.new({
      "match" => "fts", "min_hits" => 1,
      "concepts" => { "반복 동작" => { "db" => [ "반복", "반복적인" ], "colloquial" => [ "같은 동작" ] } }
    })

    row = entity.rows.first
    assert_equal 2, row.hits        # EB-2(반복) + EB-1(반복적인)
    # q='반복 동작'은 전문 검색에서 두 단어가 모두 있어야 해 0건이지만, main_search가 0건일 때 쓰는
    # 부분 문자열 폴백(job_name/job_description)이 EB-1("반복적인 동작으로")을 찾는다. 서버 실제 동작 그대로다.
    assert_equal 1, row.plain_hits
    assert_equal [ "같은 동작", "반복", "반복적인" ], entity.synonyms_for("반복 동작")
  end

  test "fts mode does not require a real column" do
    assert_nothing_raised do
      Chatbot::EntityBuilder.new({ "match" => "fts", "concepts" => { "x" => { "db" => [ "x" ] } } })
    end
  end

  # --- exclude_synonyms / 엔티티 사이 중복 ---

  test "exclude_synonyms keeps a term out of the synonyms but still uses it to count hits" do
    create_case("EB-6", "어깨파열")
    entity = Chatbot::EntityBuilder.new({
      "column" => "disease_name", "min_hits" => 1,
      "concepts" => { "회전근개 파열" => {
        "db" => [ "회전근개파열", "어깨파열" ], "colloquial" => [ "어깨 힘줄 파열" ], "exclude_synonyms" => [ "어깨 파열" ]
      } }
    })

    assert_equal [ "어깨 힘줄 파열" ], entity.synonyms_for("회전근개 파열")
    assert_equal 4, entity.rows.first.hits, "제외한 표현(어깨파열)도 건수 측정에는 쓴다: EB-1,2,3 + EB-6"
    assert_not_includes entity.to_csv, "어깨파열"
  end

  test "exclude_synonyms must name a term of the concept and cannot exclude the representative" do
    entity = builder({
      "회전근개 파열" => { db: [ "회전근개파열" ], colloquial: [], exclude_synonyms: [ "없는 표현", "회전근개 파열" ] }
    })

    errors = entity.structural_errors.join("\n")
    assert_match(/없는 표현.*db·colloquial에 없습니다/, errors)
    assert_match(/대표 엔트리 '회전근개 파열'/, errors)
  end

  test "the same expression in two entities is reported, ignoring spaces" do
    disease = builder({ "충돌증후군" => { db: [ "충돌증후군" ], colloquial: [ "상하 차" ] } }, column: "disease_name")
    job = builder({ "물류 노동자" => { db: [ "물류" ], colloquial: [ "상하차" ] } }, column: "job_name")

    errors = Chatbot::EntityBuilder.cross_entity_errors({ "disease_name" => disease, "job_name" => job })

    assert_equal 1, errors.size
    assert_match(/상하차.*disease_name:충돌증후군.*job_name:물류 노동자/, errors.first)
  end

  test "a representative colliding with another entity's synonym is reported" do
    disease = builder({ "석면" => { db: [ "석면" ], colloquial: [] } })
    factor = builder({ "석면 노출" => { db: [ "석면" ], colloquial: [ "석면 작업" ] } }, column: "disease_name")

    errors = Chatbot::EntityBuilder.cross_entity_errors({ "disease_name" => disease, "work_factor" => factor })

    assert_equal 1, errors.size
    assert_match(/석면/, errors.first)
  end

  test "excluding the colliding term resolves the cross-entity conflict" do
    job = builder({ "물류 노동자" => { db: [ "물류" ], colloquial: [ "상하차" ] } }, column: "job_name")
    factor = Chatbot::EntityBuilder.new({
      "match" => "fts",
      "concepts" => { "물건 운반" => { "db" => [ "운반", "상하차" ], "colloquial" => [], "exclude_synonyms" => [ "상하차" ] } }
    })

    assert_empty Chatbot::EntityBuilder.cross_entity_errors({ "job_name" => job, "work_factor" => factor })
  end

  test "duplicates inside one entity are not cross-entity errors" do
    disease = builder({
      "a" => { db: [ "a" ], colloquial: [ "공통" ] },
      "b" => { db: [ "b" ], colloquial: [ "공통" ] }
    })

    assert_empty Chatbot::EntityBuilder.cross_entity_errors({ "disease_name" => disease })
    assert_match(/공통.*여러 개념에 중복/, disease.structural_errors.join)
  end

  test "committed dictionaries have no expression shared between entities" do
    builders = Dir[Rails.root.join(Chatbot::EntityBuilder::CONFIG_DIR, "*.yml")].to_h do |path|
      [ File.basename(path, ".yml"), Chatbot::EntityBuilder.from_file(path) ]
    end

    assert_empty Chatbot::EntityBuilder.cross_entity_errors(builders)
  end
end
