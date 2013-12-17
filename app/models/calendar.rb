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
end
