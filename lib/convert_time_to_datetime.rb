class ConvertTimeToDateTime
  def self.perform(time)
    DateTime.now.in_time_zone.beginning_of_day.change({hour: time.to_datetime.hour, min: time.to_datetime.min})
  end
end
