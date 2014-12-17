class AddSinglePhotoToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :single_photo, :boolean, default: false
  end
end
