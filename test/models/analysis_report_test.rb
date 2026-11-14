# frozen_string_literal: true

require "test_helper"

class AnalysisReportTest < ActiveSupport::TestCase
  setup do
    rows = [
      [ "AR-1", "approved", 2019, "musculoskeletal", "arm", "용접공", "높음", "요양급여", "Y", "어깨|팔꿈치", "우측 견관절 회전근개 파열" ],
      [ "AR-2", "approved", 2019, "musculoskeletal", "arm", "용접공", "높음", "요양급여", "N", "어깨", "좌측 견관절 회전근개 파열" ],
      [ "AR-3", "rejected", 2020, "musculoskeletal", "lower_back", "용접공", "낮음", "요양급여", "N", "허리", "요추 염좌" ],
      [ "AR-4", "partially_approved", 2020, "cardiovascular", nil, "조리원", nil, "유족급여", "Y", "", "뇌경색" ],
      [ "AR-5", "revised_approved", 2020, nil, nil, "-", "보통", nil, nil, nil, nil ]
    ]
    rows.each do |no, result, year, cat, bp, job, rel, app, death, burden, name|
      DiseaseCase.create!(case_no: no, result: result, year: year, disease_category: cat, body_part: bp, job_name: job,
                          work_relevance_eval: rel, application_type: app, death_status: death,
                          burden_body_part: burden, disease_name: name)
    end
    @report = AnalysisReport.new(scope: DiseaseCase.where("case_no LIKE 'AR-%'"), generated_on: Date.new(2026, 11, 12)).to_markdown
  end

  test "prints every reproducible section heading and marks the others as not reproducible" do
    [ "## 1. 핵심 요약", "### 2.1 판정 결과 분포", "### 2.2 연도별 분포", "### 2.3 신청서 종류 및 사망자 결정",
      "## 3. 업무관련성 평가와 판정 결과", "### 4.1 판정 사례 누적 상위 40개 직종", "### 4.2", "### 4.3 근무 형태별",
      "### 5.1 질병군", "### 5.2 신청 상병 부위", "### 5.3 상병군별 분포 (정규화)", "### 5.4 정규화된 상병 다발 순위",
      "### 6.3 신체부위 × 신체부담 부위", "#### 6.3.1 신체부위 단계 요약", "## 7. 일부인정 구조 분석" ].each do |heading|
      assert_includes @report, heading
    end
    assert_equal 2, @report.scan("**재현 불가.**").size
  end

  test "counts the fixture rows" do
    assert_includes @report, "| 전체 판정 사례 | 5건 |"
    assert_includes @report, "| 인정 | 40.00% (2건) |"
    assert_includes @report, "| 불인정 | 20.00% (1건) |"
    assert_includes @report, "| 2019년 | 2 | 2 | 0 | 0 | 0 | 100.00% | 100.00% |"
    assert_includes @report, "| 높음 | 2 | 2 | 0 | 0 | 100.00% | 0.00% |"
    assert_includes @report, "| 용접공 | 3 | 66.7% | 66.7% | 33.3% |"
    refute_includes @report, "| - | 1 | 0.0% | 100.0% | 0.0% |" # 직종 `-`는 4장에서 뺀다
    assert_includes @report, "| 견관절회전근개파열 | 2 | 2 | 0 | 100.0% |"
  end

  test "splits burden tokens on the pipe boundary" do
    assert_includes @report, "#### 6.3.2 팔 — 2행"
    assert_includes @report, "| 어깨 | 2 | 2 | 0 | 100.0% |"
    assert_includes @report, "| 팔꿈치 | 1 | 1 | 0 | 100.0% |"
    assert_includes @report, "| 신체부위 기록 있음 | 3 | 0 | 3 |"
    assert_includes @report, "| 신체부위 미기록 | 0 | 2 | 2 |"
  end

  test "rake task writes the report file and leaves the data untouched" do
    require "rake"
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/analysis.rake")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "nested", "report.md")
      before = DiseaseCase.count
      out = StringIO.new
      old = $stdout
      $stdout = out
      begin
        Rake::Task["analysis:report"].invoke(path)
      ensure
        $stdout = old
      end
      body = File.read(path)
      assert_includes body, "## 1. 핵심 요약"
      assert_includes body, "#{before}건"
      assert_includes out.string, path
      assert_equal before, DiseaseCase.count
    end
  end

  test "refuses writes while building" do
    assert_raises(ActiveRecord::ReadOnlyError) do
      ActiveRecord::Base.while_preventing_writes { DiseaseCase.create!(case_no: "AR-W") }
    end
  end
end
