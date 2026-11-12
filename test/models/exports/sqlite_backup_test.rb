# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class Exports::SqliteBackupTest < ActiveSupport::TestCase
  # VACUUM INTO는 트랜잭션 안에서 실행할 수 없다. 이 테스트는 데이터를 쓰지 않는다.
  self.use_transactional_tests = false

  setup { @dir = Dir.mktmpdir("backup-test") }
  teardown { FileUtils.remove_entry(@dir) }

  test "VACUUM INTO로 테이블이 있는 유효한 SQLite 파일을 만든다" do
    result = Exports::SqliteBackup.new(out_dir: @dir, time: Time.utc(2026, 11, 12, 1, 2, 3)).run

    assert_equal "workercare_20261112_010203.sqlite3", result.path.basename.to_s
    assert_equal "ok", result.integrity
    assert_equal result.path.size, result.bytes
    assert_equal Digest::SHA256.file(result.path).hexdigest, result.sha256

    db = SQLite3::Database.new(result.path.to_s, readonly: true)
    tables = db.execute("SELECT name FROM sqlite_master WHERE type = 'table'").flatten
    assert_includes tables, "disease_cases"
    assert_includes tables, "schema_migrations"
    assert_equal "ok", db.get_first_value("PRAGMA integrity_check")
    db.close
    assert_empty Dir[File.join(@dir, "*.tmp")]
  end

  test "같은 이름의 파일이 있으면 덮어쓰지 않고 거부한다" do
    time = Time.utc(2026, 11, 12, 1, 2, 3)
    backup = Exports::SqliteBackup.new(out_dir: @dir, time: time)
    backup.run
    before = Digest::SHA256.file(backup.target_path).hexdigest

    assert_raises(Exports::SqliteBackup::Error) { backup.run }
    assert_equal before, Digest::SHA256.file(backup.target_path).hexdigest
  end

  test "원본 DB 경로를 ActiveRecord 설정에서 읽는다" do
    assert_equal Rails.root.join("storage/test.sqlite3").realpath, Exports::SqliteBackup.new(out_dir: @dir).source_path.realpath
  end
end
