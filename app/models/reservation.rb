# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :company, required: true

  validates :reservation_date,         presence: true
  validates :phone_number,             presence: true

  validate :reservation_details

  def reservation_details
    # unless reservation_date.future?
    #   errors.add(:base, I18n.t('reservation.not_in_the_future', company_name: company.name))
    #   return
    # end

    if company.temporarily_closed
      errors.add(:base, I18n.t('reservation.temporarily_closed', company_name: company.name, company_temporarily_closed_message: company.temporarily_closed_message))
      return
    end

    unless company.open?(reservation_date)
      errors.add(:base, I18n.t('reservation.out_of_business_hour', company_name: company.name, company_schedule: company.schedule))
      return
    end

    unless company.reservation_slot_still_available?(reservation_date)
      errors.add(:base, I18n.t('reservation.reservation_slot_still_available', company_name: company.name, next_slots: company.next_available_time_slots_to_string(reservation_date, 3)))
      return
    end
  end
end
