ActiveAdmin.register User do

  menu priority: 5

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
  column :email
  column "Nation" do |u|
    u.nation.name unless u.nation.nil?
  end
  column "Created" do |u|
    u.created_at
  end
  actions
end

# #Filters
filter :email
filter :nation
filter :created_at

#show page
show do
    attributes_table do
      row :email
      row :created_at
      row :updated_at
      row :activation_state
      row :nation
    end
    active_admin_comments
  end

end
