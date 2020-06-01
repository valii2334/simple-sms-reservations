# frozen_string_literal: true

require 'time_utils'

class Company < ApplicationRecord
  include ::TimeUtils

  ACCEPTED_DATE_FORMATS = {
    'YMD' => ['%Y/%m/%d %H:%M %p', '%Y.%m.%d %H:%M %p', '%Y/%m/%d %H:%M', '%Y.%m.%d %H:%M'],
    'DMY' => ['%d/%m/%Y %H:%M %p', '%d.%m.%Y %H:%M %p', '%d/%m/%Y %H:%M', '%d.%m.%Y %H:%M', '%d/%m %H:%M %p', '%d.%m %H:%M %p', '%d/%m %H:%M', '%d.%m %H:%M'],
    'MDY' => ['%m/%d/%Y %H:%M %p', '%m.%d.%Y %H:%M %p', '%m/%d/%Y %H:%M', '%m.%d.%Y %H:%M', '%m/%d %H:%M %p', '%m.%d %H:%M %p', '%m/%d %H:%M', '%m.%d %H:%M']
  }.freeze

  has_many   :reservations, -> { order(reservation_date: :desc) }, dependent: :destroy
  belongs_to :user, required: true

  validates :name,                                           uniqueness: true,
                                                             presence: true
  validates :date_format,                                    inclusion: { in: ['YMD', 'DMY', 'MDY'] }
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
  validate :can_change_unit_of_time

  before_save :downcase_code

  def downcase_code
    code.downcase!
  end

  def can_change_unit_of_time
    return unless reservations.any? && unit_of_time_changed?

    errors.add(:unit_of_time, 'can not be changed if reservations present')
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

  def open_today?(date)
    return false if temporarily_closed
    return false if closed_saturday && date.saturday?
    return false if closed_sunday && date.sunday?
    true
  end

  def opening_closing_time_for_given_date(date)
    return [opening_time_sunday, closing_time_sunday] if date.sunday?
    return [opening_time_saturday, closing_time_saturday] if date.saturday?

    [opening_time, closing_time]
  end

  def sync_day_month_year(date, reference_date)
    date.change({
      day: reference_date.day,
      month: reference_date.month,
      year: reference_date.year
    })
  end

  def today_time_slots(date)
    start_time, end_time = opening_closing_time_for_given_date(date).map{
      |d| sync_day_month_year(d, date)
    }

    Enumerator.new {
      |y| loop {
        y.yield start_time; start_time += unit_of_time.minutes
      }
    }.take_while {
      |d| d + unit_of_time.minutes <= end_time
    }
  end

  def available_time_slots_after_given_date_time(date_time)
    today_time_slots(date_time).select { |available_time_slot|
      available_time_slot >= date_time &&
      time_slot_still_available?(available_time_slot)
    }
  end

  def available_time_slots_after_given_date_time_to_string(date_time, n)
    available_time_slots_after_given_date_time(date_time).first(n).map{ |available_time_slot|
      hour_min_am_pm(available_time_slot)
    }.join(', ')
  end

  def time_slot_still_available?(date_time)
    return false unless open?(date_time)

    reservations.where(reservation_date: date_time).count < customers_per_unit_of_time
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
    work_week = [ :mon, :tue, :wed, :thu, :fri ]
    work_week += [ :sat ] unless closed_saturday
    work_week += [ :sun ] unless closed_sunday

    BusinessTime::Config.work_week = work_week

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
    return [opening_time_saturday.strftime('%H %p'), closing_time_saturday.strftime('%H %p')] unless closed_saturday
    []
  end

  def sunday_working_schedule
    return [opening_time_sunday.strftime('%H %p'), closing_time_sunday.strftime('%H %p')] unless closed_sunday
    []
  end

  def weekday_working_schedule
    [opening_time.strftime('%H %p'), closing_time.strftime('%H %p')]
  end
end
