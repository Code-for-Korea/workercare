# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class SolarExtraction::ResultStoreTest < ActiveSupport::TestCase
  setup { @dir = Dir.mktmpdir("solar_store") }
  teardown { FileUtils.remove_entry(@dir) }

  test "이어 받기는 깨진 줄과 객체가 아닌 JSON 줄을 건너뛴다" do
    File.write(File.join(@dir, "results.jsonl"), [
      %({"case_no":"A-1"}), "null", "[]", %("x"), "5", "true", "{깨진 줄", %({"status":"ok"}), %({"case_no":null}), %({"case_no":"A-2"})
    ].join("\n") + "\n")

    assert_equal Set.new(%w[A-1 A-2]), SolarExtraction::ResultStore.new(@dir).done_case_nos
  end
end
