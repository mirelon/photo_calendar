class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.date :day
      t.string :photo
      t.integer :calendar_id

      t.timestamps
    end
  end
end
