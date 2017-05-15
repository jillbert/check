ActiveAdmin.register Person do
# belongs_to :nation
menu priority: 4

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

#Index page
index do
  selectable_column
  column "Name" do |p|
    p.first_name.titleize + ' ' + p.last_name.titleize
  end
  column :email
  column :phone_number
  column "Nation" do |p|
    Nation.find(p.nation_id).name unless p.nation_id.nil?
  end
  column "RSVPs" do |p|
    p.rsvps.count
  end
  actions
end

# #Filters
filter :nation
filter :first_name
filter :last_name
filter :email

#show page
show do
    attributes_table do
      row "Name" do |p|
        p.first_name.titleize + ' ' + p.last_name.titleize
      end
      row :email
      row :phone_number
      row :created_at
      row :updated_at
      row :nation
      row "RSVPs" do |p|
        p.rsvps.count
      end
    end
    active_admin_comments
  end


end
