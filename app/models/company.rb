class Company < ApplicationRecord
  has_many :reservations, -> { order(reservation_date: :desc) }, dependent: :destroy
  belongs_to :user, required: true

  validates :name, uniqueness: true, presence: true
  validates :opening_time, presence: true
  validates :closing_time, presence: true
  validates :closed_saturday, inclusion: { in: [ true, false ] }
  validates :closed_sunday, inclusion: { in: [ true, false ] }
  validates :temporarily_closed, inclusion: { in: [ true, false ] }
  validates :code, uniqueness: true, format: { with: /\A[a-z0-9.]+\z/ , message: 'no special characters, only lowercase letters and numbers' }
  validates :unit_of_time, numericality: { greater_than_or_equal_to: 1 }
  validates :customers_per_unit_of_time, numericality: { greater_than_or_equal_to: 1 }
  validate :closing_time_bigger_than_oppening_time
  before_save :downcase_code

  def downcase_code
    self.code.downcase!
  end

  def closing_time_bigger_than_oppening_time
    if self.closing_time <= self.opening_time
      errors.add(:closing_time, "must be bigger than #{self.closing_time}")
    end
  end

  def available_reservation_times
    time_slots = []

    hour = opening_time
    while hour < closing_time
      time_slots << hour.strftime('%H:%M')
      hour += unit_of_time.minutes
    end

    time_slots
  end

  def open_today?
    return false if temporarily_closed
    return false if DateTime.now.strftime("%A") == 'Saturday' && closed_saturday
    return false if DateTime.now.strftime("%A") == 'Sunday' && closed_sunday
    true
  end

  def reservation_time_available?(desired_reservation_time)
    return false unless available_reservation_times.include?(desired_reservation_time.strftime('%H:%M'))
    return false if reservations.where(reservation_date: desired_reservation_time).count >= customers_per_unit_of_time
    true
  end
end
