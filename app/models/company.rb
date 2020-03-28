require 'convert_time_to_datetime'

class Company < ApplicationRecord
  has_many   :reservations, -> { order(reservation_date: :desc) }, dependent: :destroy
  belongs_to :user, required: true

  validates :name,                                           uniqueness: true,
                                                             presence: true
  validates :opening_time,                                   presence: true
  validates :closing_time,                                   presence: true
  validates :closed_saturday,                                inclusion: { in: [ true, false ] }
  validates :closed_sunday,                                  inclusion: { in: [ true, false ] }
  validates :opening_time_saturday,                          presence: true, if: -> { !self.closed_saturday }
  validates :closing_time_saturday,                          presence: true, if: -> { !self.closed_saturday }
  validates :opening_time_sunday,                            presence: true, if: -> { !self.closed_sunday }
  validates :closing_time_sunday,                            presence: true, if: -> { !self.closed_sunday }
  validates :temporarily_closed,                             inclusion: { in: [ true, false ] }
  validates :code,                                           uniqueness: true,
                                                             format: { with: /\A[a-z0-9.]+\z/ ,
                                                             message: 'no special characters, only lowercase letters and numbers' }

  validates :unit_of_time,                                   numericality: { greater_than_or_equal_to: 1 }
  validates :customers_per_unit_of_time,                     numericality: { greater_than_or_equal_to: 1 }
  validate :closing_time_bigger_than_oppening_time,          if: -> { self.opening_time.present? && self.closing_time.present? }
  validate :closing_time_bigger_than_oppening_time_saturday, if: -> { self.opening_time_saturday.present? && self.closing_time_saturday.present? && !self.closed_saturday }
  validate :closing_time_bigger_than_oppening_time_sunday,   if: -> { self.opening_time_sunday.present? && self.closing_time_sunday.present? && !self.closed_sunday }

  before_save :downcase_code

  def downcase_code
    self.code.downcase!
  end

  def closing_time_bigger_than_oppening_time
    if self.closing_time <= self.opening_time
      errors.add(:closing_time, "must be bigger than #{self.closing_time}")
    end
  end

  def closing_time_bigger_than_oppening_time_saturday
    if self.closing_time_saturday <= self.opening_time_saturday
      errors.add(:closing_time_saturday, "must be bigger than #{self.closing_time_saturday}")
    end
  end

  def closing_time_bigger_than_oppening_time_sunday
    if self.closing_time_sunday <= self.opening_time_sunday
      errors.add(:closing_time_sunday, "must be bigger than #{self.closing_time_sunday}")
    end
  end

  def available_reservation_times
    time_slots            = []
    open_time, close_time = current_day_opening_time_closing_time
    hour                  = open_time

    while (hour + unit_of_time.minutes) <= close_time
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

  def current_day_opening_time_closing_time
    if DateTime.now.strftime("%A") == 'Saturday'
      return self.opening_time_saturday, self.closing_time_saturday
    elsif DateTime.now.strftime("%A") == 'Sunday'
      return self.opening_time_sunday, self.closing_time_sunday
    else
      return self.opening_time, self.closing_time
    end
  end

  def schedule
    readable_schedule = ''
    readable_schedule += "Monday - Friday: #{self.opening_time.strftime('%H:%M %p')} - #{self.closing_time.strftime('%H:%M %p')}. "

    if self.closed_saturday
      readable_schedule += 'Saturday: Closed. '
    else
      readable_schedule += "Saturday: #{self.opening_time_saturday.strftime('%H:%M %p')} - #{self.closing_time_saturday.strftime('%H:%M %p')}. "
    end

    if self.closed_sunday
      readable_schedule += 'Sunday: Closed. '
    else
      readable_schedule += "Sunday: #{self.opening_time_sunday.strftime('%H:%M %p')} - #{self.closing_time_sunday.strftime('%H:%M %p')}. "
    end

    readable_schedule
  end

  def next_available_time_slots(desired_reservation_time, number_of_time_slots_available)
    all_company_time_slots      = available_reservation_times
    next_n_available_time_slots = []

    all_company_time_slots.each do |time_slot|
      reservation_date = ConvertTimeToDateTime.perform(time_slot)

      break if next_n_available_time_slots.size >= number_of_time_slots_available
      next if reservation_date < desired_reservation_time
      next unless reservation_time_available?(reservation_date)

      next_n_available_time_slots << time_slot
    end

    next_n_available_time_slots
  end

  def next_available_time_slots_to_s(desired_reservation_time, number_of_time_slots_available)
    next_n_available_time_slots = next_available_time_slots(desired_reservation_time, number_of_time_slots_available)

    if next_n_available_time_slots.empty?
      'There are no more free spots for today'
    else
      "Next #{next_n_available_time_slots.count} available spot(s) are: #{next_n_available_time_slots.join(',')}"
    end
  end
end
