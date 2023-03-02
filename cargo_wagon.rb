# frozen_string_literal: true

class CargoWagon < Wagon
  attr_reader :type
  attr_accessor :volume

  def initialize(number, company, amount_space, type)
    super(number, company, amount_space, type)
    @type == :cargo
  end

  def take_space(volume)
    raise "свободного объема в вагоне недостаточно, осталось #{amount_space}" if (@amount_space - volume) <= 0

    @occupied_space += volume
    @amount_space -= volume
    puts "Вы загрузили объем в размере #{volume}, количество свободного объема:#{wagon.free_space}."
  end
end
