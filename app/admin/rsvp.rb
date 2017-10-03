ActiveAdmin.register Rsvp do
  # belongs_to :event
  # belongs_to :person
  menu label: 'RSVPs', priority: 3

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

  # Index page
  index do
    selectable_column
    column 'Person' do |r|
      link_to(Person.find(r.person_id).first_name.titleize + ' ' + Person.find(r.person_id).last_name.titleize, admin_person_path(Person.find(r.person_id)))
    end
    column 'Event' do |r|
      link_to(r.event.name, admin_event_path(r.event))
    end
    column 'Nation' do |r|
      Nation.find(r.nation_id).name
    end
    column :attended
    column :canceled
    actions
  end

  # Filters
  filter :event
  filter :person
  filter :created_at
end
