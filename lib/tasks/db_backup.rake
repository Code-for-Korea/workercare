# frozen_string_literal: true

namespace :db do
  desc "primary SQLite DB를 VACUUM INTO로 백업한다. OUT_DIR(기본 storage/backups). 같은 이름이 있으면 거부한다. 정규화 백필 전 백업과 복구용이다."
  task backup: :environment do
    result = Exports::SqliteBackup.new(out_dir: ENV["OUT_DIR"]).run
    puts "백업 완료: #{result.path}"
    puts "크기: #{ActiveSupport::NumberHelper.number_to_human_size(result.bytes)} (#{result.bytes} bytes)"
    puts "SHA-256: #{result.sha256}"
    puts "integrity_check: #{result.integrity}"
  rescue Exports::SqliteBackup::Error => e
    abort "백업 실패: #{e.message}"
  end
end
