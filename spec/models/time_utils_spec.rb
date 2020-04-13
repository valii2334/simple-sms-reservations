require 'rails_helper'

RSpec.describe TimeMonkeyPatch do
  context 'returns DateTime' do
    it 'returns corrent datetime in format %d/%m/%Y %H:%M' do
      time_monkey_patch = TimeMonkeyPatch.new
      datetime = time_monkey_patch.datetime_from_text('06/12/2020', '13:00')
      expect(datetime).to eql(DateTime.new(2020, 12, 6, 13, 0))
    end

    it 'returns correct datetime in format %d/%m %H:%M' do
      time_monkey_patch = TimeMonkeyPatch.new
      datetime = time_monkey_patch.datetime_from_text('06/12', '13:00')
      expect(datetime).to eql(DateTime.new(2020, 12, 6, 13, 0))
    end

    it 'returns corrent datetime in format %d.%m.%Y %H:%M' do
      time_monkey_patch = TimeMonkeyPatch.new
      datetime = time_monkey_patch.datetime_from_text('06.12.2020', '13:00')
      expect(datetime).to eql(DateTime.new(2020, 12, 6, 13, 0))
    end

    it 'returns correct datetime in format %d.%m %H:%M' do
      time_monkey_patch = TimeMonkeyPatch.new
      datetime = time_monkey_patch.datetime_from_text('06.12', '13:00')
      expect(datetime).to eql(DateTime.new(2020, 12, 6, 13, 0))
    end
  end
end
