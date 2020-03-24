class Reservation < ApplicationRecord
  belongs_to :company, required: true

  validates :reservation_date, presence: true
  validates :phone_number, presence: true
  validates_uniqueness_of :reservation_date, :scope => [:company_id, :phone_number], message: 'is already reserved by you.'
  validate :company_is_open
  validate :time_slot_still_available

  def company_is_open
    errors.add(:company_id, "#{self.company.name} is closed today.") unless self.company.open_today?
  end

  def time_slot_still_available
    errors.add(:reservation_date, 'can not be booked anymore.') unless self.company.reservation_time_available?(self.reservation_date)
  end
end
