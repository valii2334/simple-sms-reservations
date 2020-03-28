class Reservation < ApplicationRecord
  belongs_to :company, required: true

  validates :reservation_date,         presence: true
  validates :phone_number,             presence: true
  validate :company_is_open
  validate :time_slot_still_available, if: -> { self.company.open_today? }
  validate :already_booked_today,      if: -> { self.company.open_today? }

  def company_is_open
    errors.add(:base, "#{self.company.name} is closed today. Our schedule is #{self.company.schedule}") unless self.company.open_today?
  end

  def already_booked_today
    unless Reservation.where('phone_number = ? AND company_id = ? AND reservation_date BETWEEN ? AND ?',
      self.phone_number, self.company_id, DateTime.now.beginning_of_day, DateTime.now.end_of_day).empty?

      errors.add(:base, 'You can not make more than one reservation per day for each company')
    end
  end

  def time_slot_still_available
    errors.add(
      :base, "You can not make a reservation at this time. #{self.company.next_available_time_slots_to_s(self.reservation_date, 3)}"
    ) unless self.company.reservation_time_available?(self.reservation_date)
  end
end
