ActiveAdmin.register Event do

  menu priority: 1

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
  column :name do |e|
    link_to(e.name, administrator_event_path(e))
  end
  column "Nation" do |e|
    e.nation.name
  end
  column "RSVPs" do |e|
    e.rsvps.count
  end
  column :start_time
  column :end_time
  column :created_at
  actions
end

#Filters
filter :name
filter :nation
filter :created_at

end
