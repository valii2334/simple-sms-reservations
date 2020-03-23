# frozen_string_literal: true

module ApplicationHelper
  def page(controller, action)
    params[:controller] == controller && params[:action] == action
  end

  def object_page(object)
    params[:id].to_i == object.id
  end

  def active_show_class(condition, display_class)
    return display_class if condition
    return ''
  end
end
