class AddLogoAndColorToUser < ActiveRecord::Migration
  def change
    add_column :users, :logo, :string, default: nil
    add_column :users, :color, :string, default: nil
  end
end
