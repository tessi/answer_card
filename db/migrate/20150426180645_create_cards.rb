class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :uuid, null: false
      t.string :name, null: false
      t.boolean :can_come
      t.integer :people_count
      t.boolean :need_room
      t.integer :room_count
      t.date :room_start_date
      t.date :room_end_date
      t.text :notes

      t.timestamps null: false
    end

    add_index :cards, :uuid
  end
end
