# frozen_string_literal: true

# MCP 서버를 제거하면서 actionmcp·solid_mcp가 만든 테이블을 지운다.
# 되돌릴 수 없다. 운영 DB는 먼저 백업한다. 옛 *.action_mcp.rb 마이그레이션은 이력으로 남긴다.
class DropMcpTables < ActiveRecord::Migration[8.1]
  def up
    # 외래키 자식부터 지운다.
    drop_table :action_mcp_session_messages, if_exists: true
    drop_table :action_mcp_session_subscriptions, if_exists: true
    drop_table :action_mcp_session_tasks, if_exists: true
    drop_table :action_mcp_sessions, if_exists: true
    drop_table :solid_mcp_messages, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "MCP 테이블은 복원하지 않는다. 필요하면 actionmcp 마이그레이션을 다시 설치한다."
  end
end
