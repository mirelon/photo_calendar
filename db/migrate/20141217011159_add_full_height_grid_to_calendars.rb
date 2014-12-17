class AddFullHeightGridToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :full_height_grid, :boolean, default: false
  end
end
