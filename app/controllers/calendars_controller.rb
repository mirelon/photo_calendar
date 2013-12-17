class CalendarsController < ApplicationController
  require 'prawn'
  
  def index
  	@calendars = Calendar.all
  end

  def show
    cell_width = 100
    cell_height = 80
    page_size = "A3"

  	@people = Calendar.find(params[:id]).people
    @year = (params[:year] || Date.current.year + 1).to_i
    pdf = Prawn::Document.new(page_size: page_size, page_layout: :portrait)
    pdf.font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    page_width = pdf.bounds.width
    page_height = pdf.bounds.height
    start_date = Date.new(@year)
    end_date = start_date.end_of_year
    (start_date .. end_date).each do |date|
      if date.day == 1
        pdf.text_box Date::MONTHNAMES[date.month],
          at: [page_width/2-cell_width/2, 550],
          width: cell_width,
          align: :center
        (0..6).each do |weekday|
          pdf.draw_text Date::DAYNAMES[(weekday + 1) % 7], at: [weekday * cell_width, 515] 
        end
      end
      x1 = (date.wday - date.previous_monday.wday)%7 * cell_width
      y1 = 500 - date.all_sundays_in_month.select{|i| i<date.day}.size * cell_height
      pdf.rectangle [x1, y1], cell_width, cell_height
      pdf.stroke
      pdf.rectangle [x1, y1], cell_width, 20
      pdf.stroke
      pdf.font "Helvetica" do
        pdf.draw_text date.day.to_s, at: [x1 + 7, y1 - 15], style: :bold
      end
      pdf.draw_text PhotoCalendar::Application.config.namesday[date.month][date.day], at: [x1 + 22, y1 - 15], size: 7
      @people.each do |person|
        if person.day.day == date.day and person.day.month == date.month
          pdf.image person.photo, at: [x1 + 10, y1 - 30], fit: [cell_width-50, cell_height-40]
        end
      end
      if date.tomorrow.day == 1 and not date.tomorrow.january?
        pdf.start_new_page
      end
    end
    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
  end
end
