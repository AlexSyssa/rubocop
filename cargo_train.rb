# frozen_string_literal: true

class CargoTrain < Train
  def initialize(id, type, company)
    super(id, type, company)
    @type == :cargo
  end
end
