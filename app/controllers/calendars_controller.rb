class CalendarsController < ApplicationController
  require 'prawn'
  
  def index
  	@calendars = Calendar.all
  end

  def show
    width = 100
    height = 80
  	@people = Calendar.find(params[:id]).people
    @year = (params[:year] || Date.current.year + 1).to_i
    pdf = Prawn::Document.new(page_layout: :landscape)
    start_date = Date.new(@year)
    end_date = start_date.end_of_year
    (start_date .. end_date).each do |date|
      if date.day == 1
        pdf.draw_text Date::MONTHNAMES[date.month], at: [300, 530]
        (0..6).each do |weekday|
          pdf.draw_text Date::DAYNAMES[(weekday + 1) % 7], at: [weekday * width, 515] 
        end
      end
      x1 = (date.wday - date.previous_monday.wday)%7 * width
      y1 = 500 - date.all_sundays_in_month.select{|i| i<date.day}.size * height
      pdf.rectangle [x1, y1], width, height
      pdf.stroke
      pdf.rectangle [x1, y1], width, 20
      pdf.stroke
      pdf.draw_text date.day.to_s, at: [x1 + 7, y1 - 15], style: :bold
      @people.each do |person|
        if person.day.day == date.day and person.day.month == date.month
          pdf.image person.photo, at: [x1 + 10, y1 - 30], fit: [width-50, height-40]
        end
      end
      if date.tomorrow.day == 1 and not date.tomorrow.january?
        pdf.start_new_page
      end
    end
    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
  end
end
