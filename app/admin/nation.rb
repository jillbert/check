ActiveAdmin.register Nation do

  menu priority: 2


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

#index
index do
  selectable_column
  column :name
  column "Owner" do |n|
    User.find(n.user_id).email unless User.where(id: n.user_id).empty?
  end
  column "Events" do |n|
    n.events.count
  end
  actions
end

#Filters
filter :name
filter :url
filter :created_at

#show page
show do
  attributes_table do
    row :id
    row :name
    row :url do |n|
      link_to(n.url, n.url)
    end
    row :created_at
    row :updated_at
    row "Owner" do |n|
      User.find(n.user_id)
    end
  end
  active_admin_comments
end

end
