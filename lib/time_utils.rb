module TimeUtils
  def datetime_from_text(date_text, time_text)
    [date_text, time_text].join(' ').to_datetime.in_time_zone
  end

  def hour_min(date_time)
    date_time.strftime('%H:%M')
  end

  def hour_min_am_pm(date_time)
    date_time.strftime('%H:%M %p')
  end
end
