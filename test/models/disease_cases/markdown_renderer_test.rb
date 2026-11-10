# frozen_string_literal: true

require "test_helper"

class DiseaseCases::MarkdownRendererTest < ActiveSupport::TestCase
  Meta = Struct.new(:page, :last, :previous, :next)

  def renderer
    DiseaseCases::MarkdownRenderer.new(base_url: "https://example.test/")
  end

  def search(cases, metadata: { total_count: cases.size, over_cap: false, used_fallback: false }, pagy: Meta.new(1, 1, nil, nil), query: {})
    renderer.search(cases: cases, pagy: pagy, metadata: metadata, path: "/search", query: query,
      options: { application_type: %w[요양급여 기타], work_relevance_eval: %w[높음] })
  end

  test "cell escapes pipes, newlines and html so tables do not break" do
    assert_equal "a\\|b c", renderer.cell("a|b\nc")
    assert_equal "&lt;b&gt;", renderer.cell("<b>")
    assert_equal "-", renderer.cell(nil)
    assert_equal "-", renderer.cell("  ")
  end

  test "search table escapes a title containing a pipe and links to the .md detail" do
    c = DiseaseCase.new(case_no: "A|1", disease_name: "손목|터널", year: 2024, result: "approved")
    out = search([ c ])

    assert_includes out, "손목\\|터널"
    assert_includes out, "[A\\|1](https://example.test/disease_cases/A%7C1.md)"
    assert_includes out, "1건 (1/1쪽)"
  end

  test "empty result, fallback notice and over-cap are explained" do
    out = search([], metadata: { total_count: 0, over_cap: false, used_fallback: true })
    assert_includes out, I18n.t("search.no_results")
    assert_includes out, I18n.t("search.fallback_notice")

    capped = search([], metadata: { total_count: nil, over_cap: true, used_fallback: false })
    assert_includes capped, I18n.t("search.over_cap")
  end

  test "pagination links keep the query and point at .md" do
    c = DiseaseCase.new(case_no: "P1", disease_name: "쪽", year: 2024)
    out = search([ c ], pagy: Meta.new(2, 3, 1, 3), query: { "q" => "손목" })

    assert_includes out, "[이전 쪽](https://example.test/search.md?page=1&q=%EC%86%90%EB%AA%A9)"
    assert_includes out, "[다음 쪽](https://example.test/search.md?page=3&q=%EC%86%90%EB%AA%A9)"
  end

  test "usage block lists allowed values passed in and ends with the disclaimer" do
    out = search([])
    assert_includes out, "요양급여, 기타"
    assert_includes out, DiseaseCases::MarkdownRenderer::DISCLAIMER
  end

  test "show masks PII in every body section and quotes text so it cannot add structure" do
    c = DiseaseCase.new(case_no: "S1", disease_name: "상세", year: 2024, result: "approved",
      statement: "# 가짜 제목\n주민번호 900101-1234567", main_reasoning: "메일 a@b.com <script>")
    out = renderer.show(c)

    assert_includes out, "> # 가짜 제목"
    assert_no_match(/900101-1234567/, out)
    assert_no_match(/a@b\.com/, out)
    assert_includes out, "&lt;script&gt;"
    assert_includes out, DiseaseCases::MarkdownRenderer::DISCLAIMER
  end
end
