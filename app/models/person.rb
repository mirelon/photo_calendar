class Person < ActiveRecord::Base
  attr_accessible :calendar_id, :day, :name, :photo
  belongs_to :calenda
end
