module TimeUtils
  def datetime_from_text(datetime, date_format)

    Company::ACCEPTED_DATE_FORMATS[date_format].each do |date_formatter|
      begin
        return DateTime.strptime(datetime, date_formatter)
      rescue ArgumentError => e
        nil
      end
    end

    nil
  end

  def hour_min(date_time)
    date_time.strftime('%H:%M')
  end

  def hour_min_am_pm(date_time)
    date_time.strftime('%H:%M %p')
  end

  def day_month_hour_min_am_pm(date_time)
    date_time.strftime('%d %B, %H:%M %p')
  end

  def day_month_hour_min(date_time)
    date_time.strftime('%d %B, %H:%M')
  end
end

class TimeMonkeyPatch
  include ::TimeUtils
end
