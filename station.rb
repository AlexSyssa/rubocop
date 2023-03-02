# frozen_string_literal: true

class Station
  include InstanceCounter

  attr_accessor :name, :trains

  @@stations = []
  NAME_FORMAT = /^[0-9а-яa-z]{3,33}$/i.freeze

  def initialize(name)
    @name = name
    @trains = []
    validate!
    @@stations << self
    register_instance
  end

  def trains_on_station(&block)
    trains.each { |train| block.call(train) }
    puts 'На станции нет поездов' if trains.empty?
  end

  def valid?
    validate!
    true
  rescue RuntimeError
    false
  end

  def self.all
    @@stations.each { |station| puts station.name }
  end

  def add_train(train)
    @trains << train
  end

  def output_trains
    trains.each { |train| puts train.id }
  end

  def trains_by_type(type)
    trains.each { |train| puts "На станции находятся #{train.id} поезд(а)" if type == type }
  end

  def train_dispatch(train)
    trains.delete(train) if trains.include?(train)
  end

  private

  def validate!
    raise 'Наименование станции должно содержать больше 3 символов' if name.length < 3
    raise 'Не соответствует формату. Наименование может содержать от 3 до 33 букв и/или цифр' if name !~ NAME_FORMAT

    true
  end
end
