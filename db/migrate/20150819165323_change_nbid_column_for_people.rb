class ChangeNbidColumnForPeople < ActiveRecord::Migration
  def change
  	change_column :people, :phone_number, :string
  end
end
