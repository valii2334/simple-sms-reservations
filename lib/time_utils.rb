module TimeUtils
  def datetime_from_time(time)
    DateTime.now.in_time_zone.beginning_of_day.change({hour: time.to_datetime.hour, min: time.to_datetime.min})
  end

  def hour_min(date_time)
    date_time.strftime('%H:%M')
  end

  def hour_min_am_pm(date_time)
    date_time.strftime('%H:%M %p')
  end
end
