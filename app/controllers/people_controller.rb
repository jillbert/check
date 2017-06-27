class PeopleController < ApplicationController
  include ApplicationHelper
  include RsvpsHelper
  include PeopleHelper

  before_filter :has_current_site_and_event
  before_filter :get_event

  def new
    @person = Person.new
    @welcome_message = 'Add RSVP'

    @host_id = params[:host_id].to_i if params[:host_id]

    respond_to do |f|
      f.html {}
      f.js {}
    end
  end

  def create
    @person, @rsvp = nil
    @person = Person.find_or_initialize_by(person_params)
    @person.errors.clear
    @host_id = (params[:host_id].to_i if params[:host_id].to_i > 0)

    nationbuilder_person = send_person_to_nationbuilder(@person)
    if nationbuilder_person[:status]
      @person = Person.import(nationbuilder_person[:person], current_user.nation.id)

      @rsvp = Rsvp.create_new_rsvp(session[:current_nation], @current_event.id, @person.id)

      nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @person)
      if nationbuilder_rsvp[:error].include?('signup_id has already been taken')
        redirect_to rsvp_path(Rsvp.where(event_id: @rsvp.event_id, person_id: @rsvp.person_id).first)
      elsif nationbuilder_rsvp[:status]
        new_person = Person.create_with(last_name: @person.last_name, first_name: @person.first_name, pic: @person.pic)
                           .find_or_create_by(email: @person.email, nbid: @person.nbid)

        @rsvp.update_attributes(rsvpNBID: nationbuilder_rsvp[:id].to_i, person_id: new_person.id, host_id: @host_id)
        if @rsvp.host_id
          host = Rsvp.find(@rsvp.host_id).person
          send_rsvp_host_to_nationbuilder(host, @rsvp.person)
        end
        respond_to do |format|
          format.js {}
          if @host_id
            @add_guests = add_guests(@rsvp.host)
            format.html { redirect_to rsvp_path(@host_id) }
          else
            get_count
            format.html { redirect_to rsvp_path(@rsvp.id) }
          end
        end
      else
        @person.errors.add(:rsvp, nationbuilder_rsvp[:error])
        respond_to do |format|
          format.js { render status: 500 }
          format.html { redirect_to new_rsvp_path }
        end
      end

    else
      @person.errors.add(:person, nationbuilder_person[:error])
      respond_to do |format|
        format.js { render status: 500 }
        format.html { redirect_to new_rsvp_path }
      end
    end
  end

  def edit
    @person = Person.find(params[:id])
    @welcome_message = 'Edit RSVP'
    respond_to do |format|
      format.js {}
      format.html { render 'edit' }
    end
  end

  def update
    @person = Person.find(params[:id])
    @person.assign_attributes(person_params)

    nationbuilder_person = send_person_to_nationbuilder(@person)

    if nationbuilder_person[:status]
      @person.save
      @person.update_attributes(pic: nationbuilder_person[:person]['profile_image_url_ssl'])
      @rsvp = Rsvp.find_by(person_id: @person, event_id: @current_event.id, nation_id: current_user.nation.id)
      puts session[:current_event]
      puts @rsvp
      if !@rsvp.attended
        @rsvp.assign_attributes(attended: true)
        nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @person)

        if nationbuilder_rsvp[:status]
          @rsvp.save

          respond_to do |format|
            format.js
          end
        else
          @person.errors.add(:rsvp, nationbuilder_rsvp[:error])
          respond_to do |format|
            format.js {}
            format.html { render 'edit' }
          end
        end
      else
        respond_to do |format|
          format.js
        end
      end
    else
      @person.errors.add(:person, nationbuilder_person[:error])
      respond_to do |format|
        format.js
        format.html { render 'edit' }
      end
    end
  end

  private

  def has_current_site_and_event
    if session[:current_site]
      if session[:current_event]
        true
      else
        redirect_to choose_event_path
      end
    else
      redirect_to choose_site_path
    end
  end

  def person_params
    params.require(:person).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :work_phone_number,
      :mobile,
      :home_zip
    )
  end
end
