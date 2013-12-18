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

    subtitle_box_width = cell_width
    subtitle_box_height = 15


    pdf = Prawn::Document.new(page_size: page_size, page_layout: :portrait)
    pdf.font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    page_width = pdf.bounds.width
    page_height = pdf.bounds.height
    start_date = Date.new(year)
    end_date = start_date.end_of_year
    (start_date .. end_date).each do |date|
      if date.day == 1
        pdf.fill_color "0000ff"
        pdf.text_box I18n.t('date.month_names', locale: :sk)[date.month],
          at: [0, 570],
          width: 2*cell_width,
          fill_color: "0000ff",
          size: 36
        (0..6).each do |weekday|
          if weekday==6
            pdf.fill_color "cc0000"
          else
            pdf.fill_color "000000"
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
      pdf.fill_color "ddddff"
      pdf.fill_rectangle [x1 + 1, y1 - 1], 17, cell_header_height - 2
      if date.sunday?
        pdf.fill_color "cc0000"
      else
        pdf.fill_color "000000"
      end
      pdf.font "Helvetica" do
        pdf.text_box date.day.to_s,
          at: [x1 + 1, y1 - 4],
          height: cell_header_height - 4,
          width: 17,
          align: :center,
          valign: :center,
          size: 12,
          style: :bold
      end
      pdf.text_box PhotoCalendar::Application.config.namesday[date.month][date.day] || "",
        at: [x1 + 15, y1 - 4],
        width: cell_width - 15,
        height: cell_header_height - 4,
        valign: :center,
        align: :center,
        size: 9

      # Find birthdays  

      pdf.fill_color "000000"
      found_people = []
      people.each do |person|
        if person.day.day == date.day and person.day.month == date.month
          found_people << person.name
          if found_people.size == 1
            pdf.image person.photo,
                at: [x1, y1 - cell_header_height],
                fit: [cell_width, cell_height-cell_header_height]
          else
            pdf.bounding_box([x1, y1 - cell_header_height], width: cell_width, height: cell_height-cell_header_height) do
              pdf.image person.photo,
                position: :right,
                fit: [cell_width, cell_height-cell_header_height]
            end
          end
        end
      end
      if found_people.size >= 1
        pdf.transparent(0.5) do
          pdf.fill_rectangle [x1, y1 - cell_height + 15], subtitle_box_width, subtitle_box_height
        end
        
        pdf.fill_color "ffffff"
        pdf.text_box found_people[0] || "",
          at: [x1 + 2, y1 - cell_height + 15],
          width: subtitle_box_width,
          height: subtitle_box_height,
          align: :left,
          valign: :center,
          size: 10
        if found_people.size == 2
          pdf.text_box found_people[1] || "",
            at: [x1 + 2, y1 - cell_height + 15],
            width: subtitle_box_width - 4,
            height: subtitle_box_height,
            align: :right,
            valign: :center,
            size: 10
        end
        pdf.fill_color "000000"
      end


      if date.tomorrow.day == 1 and not date.tomorrow.january?
        pdf.start_new_page
      end
    end
    pdf
  end
end
