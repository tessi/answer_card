## Reflects an card answeting to our wedding questions.
# Attributes:
# string  :uuid, null: false
# string  :name, null: false
# boolean :can_come
# integer :people_count
# boolean :need_room
# integer :room_count
# date    :room_start_date
# date    :room_end_date
# text    :notes
class Card < ActiveRecord::Base
  validates :people_count, numericality: { only_integer: true, greater_than: 0, less_than: 10 }
  validates :room_count,   numericality: { only_integer: true, greater_than: 0, less_than: 10 }

  has_defaults :uuid => proc { SecureRandom.uuid },
               :people_count => 1,
               :room_count => 1,
               :room_start_date => Date.new(2015, 8, 1),
               :room_end_date => Date.new(2015, 8, 2)
end
