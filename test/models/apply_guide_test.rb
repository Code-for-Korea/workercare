# frozen_string_literal: true

require "test_helper"

class ApplyGuideTest < ActiveSupport::TestCase
  test "the five topics are loaded in order with titles taken from the heading line" do
    assert_equal ApplyGuide::TOPIC_KEYS, ApplyGuide.topics.map(&:key)
    assert_equal [ "신청 절차", "필요 서류", "불인정 시 대응 절차", "수급 가능한 보험급여", "처리 기간" ], ApplyGuide.topics.map(&:title)
    ApplyGuide.topics.each { |t| refute t.markdown.start_with?("##"), "#{t.key}: 제목 줄은 본문에서 뗀다" }
  end

  test "source and last updated date come from the header comments of the guide file" do
    assert_match %r{\Ahttps://}, ApplyGuide.source
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, ApplyGuide.last_updated)
  end

  test "the markdown version has every topic, the disclaimer, the source and the date" do
    md = ApplyGuide.markdown

    assert_includes md, "# 산재 신청 방법 안내"
    ApplyGuide.topics.each { |t| assert_includes md, "## #{t.title}" }
    assert_includes md, ApplyGuide::DISCLAIMER
    assert_includes md, ApplyGuide.source
    assert_includes md, ApplyGuide.last_updated
  end

  test "the guide makes no claim about approval chances" do
    text = ApplyGuide.markdown
    assert_no_match(/인정됩니다|인정될 것|승인될 것|가능성이 높/, text)
  end
end
