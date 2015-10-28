class PeopleController < ApplicationController

  include ApplicationHelper
  include RsvpsHelper
  include PeopleHelper

  before_filter :has_current_site_and_event
  before_filter :get_event

  def new
    @person = Person.new

    if params[:host_id]
      @host_id = params[:host_id]
    end

    respond_to do |f|
      f.html {}
      f.js {}
    end

  end

  def create
    @person = Person.new(person_params)

    nationbuilder_person = send_person_to_nationbuilder(@person)
    if nationbuilder_person[:status]
      @person.assign_attributes(nbid: nationbuilder_person[:person]["id"].to_i, pic: nationbuilder_person[:person]["profile_image_url_ssl"])

     @rsvp = Rsvp.create_new_rsvp(session[:current_nation], @current_event.id, @person.id)
      nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @person)
      
      if nationbuilder_rsvp[:status]
        new_person = Person.create_with(last_name: @person.last_name, first_name: @person.first_name, pic: @person.pic)
        .find_or_create_by(email: @person.email, nbid: @person.nbid)

        @rsvp.update_attributes(rsvpNBID: nationbuilder_rsvp["id"].to_i, person_id: new_person.id)
        
        if params[:host_id]
          @rsvp.update_attributes(host_id: params[:host_id])
        end

        respond_to do |format|
          format.js {}
          if params[:host_id]
            format.html { redirect_to rsvp_path(params[:host_id]) }
          else
            format.html {redirect_to rsvp_path(@rsvp.id)}
          end
        end
      else
        @person.errors.add(:rsvp, nationbuilder_rsvp[:error])
        respond_to do |format|
          format.js {}
          format.html {render 'new' }
        end
      end
    
    else
      @person.errors.add(:person, nationbuilder_person[:error])
      respond_to do |format|
        format.js {}
        format.html { render 'new' }
      end
    end
  end

  def edit
    @person = Person.find(params[:id])
    respond_to do |format|
      format.js {}
      format.html { render 'edit' }
    end
  end

  def update
    @person = Person.find(params[:id])
    @person.assign_attributes(person_params)
    nationbuilder_person = send_person_to_nationbuilder(@person)
    puts nationbuilder_person
    if nationbuilder_person[:status]
      @person.save
      @person.update_attributes(pic: nationbuilder_person[:person]["profile_image_url_ssl"])
      @rsvp = Rsvp.find_by(person_id: @person, event_id: @current_event.id, nation_id: session[:current_nation])

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
            format.html {render 'edit' }
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
    unless session[:current_site]
      redirect_to choose_site_path
    else
      unless session[:current_event]
        redirect_to choose_event_path
      else
        return true
      end
    end
  end
  

  def person_params
    params.require(:person).permit(
      :first_name, 
      :last_name, 
      :email
    )
  end

end
