# frozen_string_literal: true

class Wagon
  include Company
  include InstanceCounter

  WAGON_FORMAT = /^[0-9]{1,3}$/.freeze

  attr_reader :number, :company
  attr_accessor :amount_space, :occupied_space

  def initialize(number, company, amount_space, type)
    @number = number.to_s
    @company = company
    @amount_space = amount_space
    @occupied_space = 0
    @type = type
    validate!
  end

  def free_space
    amount_space - occupied_space
  end

  def valid?
    validate!
    true
  rescue RuntimeError
    false
  end

  def validate!
    raise 'Введите номер вагона' if number.nil?
    raise 'Номер не соответствует формату. Допустимый формат: от 1 до 999' if number !~ WAGON_FORMAT

    true
  end
end
