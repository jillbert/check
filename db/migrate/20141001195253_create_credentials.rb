class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.integer :nation_id
      t.string :token

      t.timestamps
    end
  end
end
