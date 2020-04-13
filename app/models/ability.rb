# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :manage, Company, user_id: user.id
    can :create, Company

    can :destroy, Reservation, company: { user_id: user.id }
  end
end
