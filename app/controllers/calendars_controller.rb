class CalendarsController < ApplicationController
  require 'prawn'
  require 'fastimage'
  
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

  def edit
    calendar = Calendar.find(params[:id])
    if params[:year]
      @year = params[:year].to_i
      @sizes = {}
      @lines = {}
      (1..12).each do |m|
        @lines[m] = Date.new(@year, m).all_sundays_in_month.size + 1
        month_filename = "10" + m.to_s.rjust(2,'0') + ".JPG"
        @sizes[m] = FastImage.size("public/uploads/#{calendar.id}/#{month_filename}")
      end
    end
  end

end
