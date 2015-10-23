module ApplicationHelper

  def to_boolean(str)
    if str == "false"
      return false
    else
      return true
    end
  end

  def get_event
    @current_event = Event.find_by_id(session[:current_event])
  end
	  
end
