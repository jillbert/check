class CreateNations < ActiveRecord::Migration
  def change
    create_table :nations do |t|
      t.string :client_uid
      t.string :secret_key
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
