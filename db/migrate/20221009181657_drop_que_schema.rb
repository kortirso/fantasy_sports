class DropQueSchema < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      execute <<~SQL
        COMMENT ON TABLE que_jobs IS '4';
      SQL

      Que.migrate!(version: 0)
    end
  end
end
