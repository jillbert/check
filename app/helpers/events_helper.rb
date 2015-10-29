module EventsHelper

  def new_site
    session[:current_site] = nil
    session[:current_event] = nil

    redirect_to :controller => "events", :action => "choose_site"
  end

  def new_event
    session[:current_event] = nil
    redirect_to :controller => "events", :action => "choose_event"
  end


end
