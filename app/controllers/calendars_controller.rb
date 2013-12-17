class CalendarsController < ApplicationController
  require 'prawn'
  
  def index
  	@calendars = Calendar.all
  end

  def show
    calendar = Calendar.find(params[:id])
    if params[:reload]
      calendar.load_people
    end
    pdf = calendar.render (params[:year] || Date.current.year + 1).to_i
    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
  end
end
