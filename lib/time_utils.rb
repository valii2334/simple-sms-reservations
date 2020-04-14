module TimeUtils
  def datetime_from_text(date_text, time_text)
    datetime = [date_text, time_text].join(' ')

    begin
      formated_date_time = DateTime.strptime(datetime, '%d/%m/%Y %H:%M %p')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d.%m.%Y %H:%M %p')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d/%m/%Y %H:%M')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d.%m.%Y %H:%M')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d/%m %H:%M %p')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d.%m %H:%M %p')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d/%m %H:%M')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end

    begin
      formated_date_time = DateTime.strptime(datetime, '%d.%m %H:%M')
      return formated_date_time
    rescue ArgumentError => e
      nil
    end
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
end

class TimeMonkeyPatch
  include TimeUtils
end
