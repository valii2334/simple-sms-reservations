# frozen_string_literal: true

require 'time_utils'

class Company < ApplicationRecord
  include TimeUtils

  has_many   :reservations, -> { order(reservation_date: :desc) }, dependent: :destroy
  belongs_to :user, required: true

  validates :name,                                           uniqueness: true,
                                                             presence: true
  validates :opening_time,                                   presence: true
  validates :closing_time,                                   presence: true
  validates :closed_saturday,                                inclusion: { in: [true, false] }
  validates :closed_sunday,                                  inclusion: { in: [true, false] }
  validates :opening_time_saturday,                          presence: true, if: -> { !closed_saturday }
  validates :closing_time_saturday,                          presence: true, if: -> { !closed_saturday }
  validates :opening_time_sunday,                            presence: true, if: -> { !closed_sunday }
  validates :closing_time_sunday,                            presence: true, if: -> { !closed_sunday }
  validates :temporarily_closed,                             inclusion: { in: [true, false] }
  validates :code,                                           uniqueness: true,
                                                             format: { with: /\A[a-z0-9.]+\z/,
                                                             message: 'no special characters, only lowercase letters and numbers' }
  validates :unit_of_time,                                   numericality: { greater_than_or_equal_to: 1 }
  validates :customers_per_unit_of_time,                     numericality: { greater_than_or_equal_to: 1 }
  validate :closing_time_bigger_than_oppening_time,          if: -> { opening_time.present? && closing_time.present? }
  validate :closing_time_bigger_than_oppening_time_saturday, if: -> { opening_time_saturday.present? && closing_time_saturday.present? && !closed_saturday }
  validate :closing_time_bigger_than_oppening_time_sunday,   if: -> { opening_time_sunday.present? && closing_time_sunday.present? && !closed_sunday }

  before_save :downcase_code

  def downcase_code
    code.downcase!
  end

  def closing_time_bigger_than_oppening_time
    return if closing_time > opening_time

    errors.add(:closing_time, "must be bigger than #{closing_time}")
  end

  def closing_time_bigger_than_oppening_time_saturday
    return if closing_time_saturday > opening_time_saturday

    errors.add(:closing_time_saturday, "must be bigger than #{closing_time_saturday}")
  end

  def closing_time_bigger_than_oppening_time_sunday
    return if closing_time_sunday > opening_time_sunday

    errors.add(:closing_time_sunday, "must be bigger than #{closing_time_sunday}")
  end

  def available_reservation_times
    time_slots            = []
    open_time, close_time = current_day_opening_time_closing_time
    hour                  = open_time

    while (hour + unit_of_time.minutes) <= close_time
      time_slots << hour_min(hour)
      hour += unit_of_time.minutes
    end

    time_slots
  end

  def open_today?
    return false if temporarily_closed
    return false if DateTime.now.saturday? && closed_saturday
    return false if DateTime.now.sunday? && closed_sunday

    true
  end

  def reservation_time_available?(desired_reservation_time)
    return false unless available_reservation_times.include?(hour_min(desired_reservation_time))
    return false if reservations.where(reservation_date: desired_reservation_time).count >= customers_per_unit_of_time

    true
  end

  def current_day_opening_time_closing_time
    return opening_time_saturday, closing_time_saturday if DateTime.now.saturday?
    return opening_time_sunday, closing_time_sunday if DateTime.now.sunday?

    [opening_time, closing_time]
  end

  def schedule
    [weekday_schedule, saturday_schedule, sunday_schedule].join(' ')
  end

  def weekday_schedule
    "Monday - Friday: #{hour_min_am_pm(opening_time)} - #{hour_min_am_pm(closing_time)}."
  end

  def saturday_schedule
    return 'Saturday: Closed.' if closed_saturday

    "Saturday: #{hour_min_am_pm(opening_time_saturday)} - #{hour_min_am_pm(closing_time_saturday)}."
  end

  def sunday_schedule
    return 'Sunday: Closed.' if closed_sunday

    "Sunday: #{hour_min_am_pm(opening_time_sunday)} - #{hour_min_am_pm(closing_time_sunday)}."
  end

  def next_available_time_slots(desired_reservation_time, number_of_time_slots_available)
    all_company_time_slots      = available_reservation_times
    next_n_available_time_slots = []

    all_company_time_slots.each do |time_slot|
      reservation_date = datetime_from_time(time_slot)

      break if next_n_available_time_slots.size >= number_of_time_slots_available
      next if reservation_date < desired_reservation_time
      next unless reservation_time_available?(reservation_date)

      next_n_available_time_slots << time_slot
    end

    next_n_available_time_slots
  end

  def next_available_time_slots_to_s(desired_reservation_time, number_of_time_slots_available)
    next_n_available_time_slots = next_available_time_slots(desired_reservation_time, number_of_time_slots_available)
    return 'There are no more free spots for today.' if next_n_available_time_slots.empty?

    "Next #{next_n_available_time_slots.count} available spot(s) are: #{next_n_available_time_slots.join(', ')}"
  end
end
