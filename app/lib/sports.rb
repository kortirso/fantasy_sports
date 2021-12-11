# frozen_string_literal: true

module Sports
  extend self

  def all
    data['sports']
  end

  def sport(value)
    all[value]
  end

  def positions
    data['positions']
  end

  def positions_for_sport(value)
    positions.select { |_, v| v['sport_kind'] == value }
  end

  def position(value)
    positions[value]
  end

  private

  def data
    @data ||= load_data
  end

  def load_data
    file = File.read(data_path)
    @data = JSON.parse(file)
  end

  def data_path
    @data_path ||= Rails.root.join('config/sport_settings.json')
  end
end
