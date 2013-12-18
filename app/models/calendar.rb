class Calendar < ActiveRecord::Base
  attr_accessible :name
  has_many :people

  def load_people
    separator = "-"
    people.delete_all
    Dir.glob("public/uploads/#{id}/*").each do |filename|
      if [".jpg", ".png"].include? File.extname(filename).downcase
        parts = File.basename(filename, ".*").split separator
        if parts.size >=2
          people.create name: parts[2..-1].join(separator),
            day: Date.new(Date.current.year, parts[0].to_i, parts[1].to_i),
            photo: filename
        end
      end
    end
    people
  end

  def render(year)
    cell_width = 100
    cell_height = 80
    cell_header_height = 20
    page_size = "A3"

    subtitle_box_width = cell_width - 4
    subtitle_box_height = 15


    pdf = Prawn::Document.new(page_size: page_size, page_layout: :portrait)
    pdf.font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    page_width = pdf.bounds.width
    page_height = pdf.bounds.height
    start_date = Date.new(year)
    end_date = start_date.end_of_year
    (start_date .. end_date).each do |date|
      if date.day == 1
        pdf.text_box I18n.t('date.month_names', locale: :sk)[date.month],
          at: [0, 570],
          width: cell_width,
          size: 24
        (0..6).each do |weekday|
          if weekday==6
            pdf.fill_color "cc0000"
          end
          pdf.text_box I18n.t('date.day_names', locale: :sk)[(weekday + 1) % 7],
            at: [weekday * cell_width, 520],
            width: cell_width,
            align: :center
          pdf.fill_color "000000"
        end
      end
      x1 = (date.wday - date.previous_monday.wday)%7 * cell_width
      y1 = 500 - date.all_sundays_in_month.select{|i| i<date.day}.size * cell_height
      pdf.rectangle [x1, y1], cell_width, cell_height
      pdf.stroke
      pdf.rectangle [x1, y1], cell_width, cell_header_height
      pdf.stroke
      if date.sunday?
        pdf.fill_color "cc0000"
      end
      pdf.font "Helvetica" do
        pdf.draw_text date.day.to_s, at: [x1 + 5, y1 - cell_header_height + 5], style: :bold
      end
      pdf.text_box PhotoCalendar::Application.config.namesday[date.month][date.day] || "",
        at: [x1 + 15, y1 - 8],
        width: cell_width - 15,
        align: :center,
        size: 7
      pdf.fill_color "000000"
      people.each do |person|
        if person.day.day == date.day and person.day.month == date.month
          pdf.image person.photo, at: [x1 + 2, y1 - cell_header_height - 2], fit: [cell_width-4, cell_height-cell_header_height - 4]
          pdf.transparent(0.5) do
            pdf.fill_rectangle [x1 + 2, y1 - cell_height + 15], subtitle_box_width, subtitle_box_height
          end
          pdf.fill_color "ffffff"
          pdf.text_box person.name || "",
            at: [x1 + 2, y1 - cell_height + 15],
            width: subtitle_box_width,
            height: subtitle_box_height,
            align: :center,
            valign: :center,
            size: 10
          pdf.fill_color "000000"
        end
      end
      if date.tomorrow.day == 1 and not date.tomorrow.january?
        pdf.start_new_page
      end
    end
    pdf
  end
end
