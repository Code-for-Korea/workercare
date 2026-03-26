Rails.application.config.after_initialize do
  db = ActiveRecord::Base.connection
  db.execute("PRAGMA mmap_size=#{256 * 1024 * 1024}")  # 256MB
  db.execute("PRAGMA cache_size=-32768")               # 32MB page cache
  db.execute("PRAGMA journal_mode=WAL")
  db.execute("PRAGMA synchronous=NORMAL")
end
