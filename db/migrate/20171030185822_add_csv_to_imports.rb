class AddCsvToImports < ActiveRecord::Migration
  def change
    add_column :imports, :csv, :string
  end
end
