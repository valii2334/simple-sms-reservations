# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :company, required: true

  validates :reservation_date,         presence: true
  validates :phone_number,             presence: true
  validate :company_is_open
  validate :time_slot_still_available, if: -> { company.open_today? && !already_booked? }
  validate :already_booked_today,      if: -> { company.open_today? }

  def company_is_open
    errors.add(:base, "#{company.name} is closed today. Our schedule is #{company.schedule}") unless company.open_today?
  end

  def already_booked_today
    errors.add(:base, "#{company.name}: you can not make more than one reservation per day for each company") if already_booked?
  end

  def time_slot_still_available
    errors.add(
      :base, "#{company.name}: you can not make a reservation at this time. #{company.next_available_time_slots_to_s(reservation_date, 3)}"
    ) unless company.reservation_time_available?(reservation_date)
  end

  def already_booked?
    !Reservation.where('phone_number = ? AND company_id = ? AND reservation_date BETWEEN ? AND ?',
      phone_number, company_id, DateTime.now.beginning_of_day, DateTime.now.end_of_day).empty?
  end
end
