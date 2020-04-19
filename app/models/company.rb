# frozen_string_literal: true

require 'time_utils'

class Company < ApplicationRecord
  include ::TimeUtils

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
  validates :temporarily_closed_message,                     presence: true, if: -> { temporarily_closed }
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

  def open?(reservation_date)
    return false if temporarily_closed

    set_business_hours
    reservation_date.during_business_hours?
  end

  def available_time_slots(reservation_date)
    start_time, end_time = opening_time, closing_time if reservation_date.weekday?
    start_time, end_time = opening_time_saturday, closing_time_saturday if reservation_date.saturday?
    start_time, end_time = opening_time_sunday, closing_time_sunday if reservation_date.sunday?

    start_time = start_time.change( { day: reservation_date.day, month: reservation_date.month, year: reservation_date.year })
    end_time = end_time.change( { day: reservation_date.day, month: reservation_date.month, year: reservation_date.year })

    Enumerator.new { |y| loop { y.yield start_time; start_time += unit_of_time.minutes } }.take_while { |d| d + unit_of_time.minutes <= end_time }
  end

  def next_available_time_slots(reservation_date)
    all_available_time_slots = available_time_slots(reservation_date).select{ |available_time_slot| available_time_slot >= reservation_date }
    all_available_time_slots.reject!{ |available_time_slot| !reservation_slot_still_available?(available_time_slot) }
    all_available_time_slots
  end

  def next_available_time_slots_to_string(reservation_date, first_n_available_time_slots)
    next_available_time_slots(reservation_date).first(first_n_available_time_slots).map{ |available_time_slot| hour_min_am_pm(available_time_slot) }.join(', ')
  end

  def reservation_slot_still_available?(reservation_date)
    return false unless open?(reservation_date)

    available_time_slots(reservation_date).include?(reservation_date) &&
    reservations.where(reservation_date: reservation_date).count < customers_per_unit_of_time
  end

  def schedule
    [weekday_schedule, saturday_schedule, sunday_schedule].join(' ')
  end

  def weekday_schedule
    I18n.t 'company.weekday_schedule', opening_time: hour_min(opening_time), closing_time: hour_min(closing_time)
  end

  def saturday_schedule
    return I18n.t 'company.saturday_schedule_closed' if closed_saturday

    I18n.t 'company.saturday_schedule_open', opening_time: hour_min(opening_time_saturday), closing_time: hour_min(closing_time_saturday)
  end

  def sunday_schedule
    return I18n.t 'company.sunday_schedule_closed' if closed_sunday

    I18n.t 'company.sunday_schedule_open', opening_time: hour_min(opening_time_sunday), closing_time: hour_min(closing_time_sunday)
  end

  private

  def set_business_hours
    BusinessTime::Config.work_hours = {
      mon: weekday_working_schedule,
      tue: weekday_working_schedule,
      wed: weekday_working_schedule,
      thu: weekday_working_schedule,
      fri: weekday_working_schedule,
      sat: saturday_working_schedule,
      sun: sunday_working_schedule
    }
  end

  def saturday_working_schedule
    return [opening_time_saturday.strftime('%H:%M %p'), closing_time_saturday.strftime('%H:%M %p')] unless closed_saturday
    ['00:00 AM', '00:00 AM']
  end

  def sunday_working_schedule
    return [opening_time_sunday.strftime('%H:%M %p'), closing_time_sunday.strftime('%H:%M %p')] unless closed_sunday
    ['00:00 AM', '00:00 AM']
  end

  def weekday_working_schedule
    [opening_time.strftime('%H:%M %p'), closing_time.strftime('%H:%M %p')]
  end
end
