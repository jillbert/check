module EventsHelper
  
  def makeRSVP(rsvp, event_id, person_id, guests_count, volunteer, isPrivate, canceled, attended)

    if rsvp
      putParams = {
        "rsvp" => {
          "id" => rsvp.to_i,
          "event_id" => session[:current_event].to_i,
          "person_id" => person_id.to_i,
          "guests_count" => guests_count.to_i,
          "volunteer" => to_boolean(volunteer),
          "private" => to_boolean(isPrivate),
          "canceled" => to_boolean(canceled),
          "attended" => to_boolean(attended),
          "shift_ids" => []
        }
      }
    else
      putParams = {
        "rsvp" => {
          "event_id" => session[:current_event].to_i,
          "person_id" => person_id.to_i,
          "guests_count" => guests_count.to_i,
          "volunteer" => to_boolean(volunteer),
          "private" => to_boolean(isPrivate),
          "canceled" => to_boolean(canceled),
          "attended" => to_boolean(attended),
          "shift_ids" => []
        }
      }
    end

    return putParams

  end

  def createMatchParams(first_name, last_name, email, phone, mobile)
    params = {
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :phone => phone,
      :mobile => mobile
    }

    params.delete_if { |k, v| v.empty? }

    return params
  
  end

  def new_site
    session[:current_site] = nil
    session[:current_event] = nil
    redirect_to :controller => "events", :action => "index"
  end

  def new_event
    session[:current_event] = nil
    redirect_to :controller => "events", :action => "choose_event"
  end
end
