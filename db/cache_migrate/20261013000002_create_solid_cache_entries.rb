# schema_format이 :sql이라 db:prepare가 db/cache_schema.rb를 읽지 않는다. 큐 DB(db/queue_migrate)처럼
# 마이그레이션으로 Solid Cache 테이블을 만들어 production_cache.sqlite3에 테이블이 생기게 한다.
class CreateSolidCacheEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cache_entries, if_not_exists: true do |t|
      t.binary :key, limit: 1024, null: false
      t.binary :value, limit: 536870912, null: false
      t.datetime :created_at, null: false
      t.integer :key_hash, limit: 8, null: false
      t.integer :byte_size, limit: 4, null: false

      t.index :byte_size
      t.index [ :key_hash, :byte_size ]
      t.index :key_hash, unique: true
    end
  end
end
