Rails.application.config.after_initialize do
  begin
    db = ActiveRecord::Base.connection
    db.execute("PRAGMA mmap_size=#{256 * 1024 * 1024}")
    db.execute("PRAGMA cache_size=-32768")
    db.execute("PRAGMA journal_mode=WAL")
    db.execute("PRAGMA synchronous=NORMAL")
  rescue ActiveRecord::ConnectionNotEstablished, SQLite3::CantOpenException
  end
end
