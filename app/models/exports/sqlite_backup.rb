# frozen_string_literal: true

require "digest"
require "fileutils"

module Exports
  # primary SQLite DB를 VACUUM INTO로 일관된 파일 하나로 복사한다.
  # 실행 중인 서비스를 멈추지 않아도 되고, WAL 내용까지 합쳐진 단일 파일이 나온다.
  # 이 파일이 복구용 백업이다. CSV(Exports::WorkercareData)는 복구 수단이 아니다.
  class SqliteBackup
    class Error < StandardError; end

    Result = Struct.new(:path, :bytes, :sha256, :integrity, keyword_init: true)

    def self.default_out_dir
      Rails.root.join("storage", "backups")
    end

    def initialize(out_dir: nil, time: Time.current, connection: ActiveRecord::Base.connection)
      @out_dir = Pathname(out_dir.presence || self.class.default_out_dir)
      @time = time
      @connection = connection
    end

    def target_path
      @out_dir.join("workercare_#{@time.strftime('%Y%m%d_%H%M%S')}.sqlite3")
    end

    def source_path
      database = @connection.pool.db_config.database
      Pathname(database).absolute? ? Pathname(database) : Rails.root.join(database)
    end

    def run
      target = target_path
      raise Error, "이미 파일이 있어 덮어쓰지 않습니다: #{target}" if target.exist?

      FileUtils.mkdir_p(@out_dir)
      tmp = Pathname("#{target}.tmp")
      FileUtils.rm_f(tmp)
      begin
        @connection.execute("VACUUM INTO #{@connection.quote(tmp.to_s)}")
        integrity = check_integrity(tmp)
        raise Error, "백업 파일의 integrity_check가 실패했습니다: #{integrity}" unless integrity == "ok"

        File.rename(tmp, target)
      ensure
        FileUtils.rm_f(tmp)
      end
      Result.new(path: target, bytes: target.size, sha256: Digest::SHA256.file(target).hexdigest, integrity: integrity)
    end

    private

    def check_integrity(path)
      db = SQLite3::Database.new(path.to_s, readonly: true)
      db.get_first_value("PRAGMA integrity_check")
    ensure
      db&.close
    end
  end
end
