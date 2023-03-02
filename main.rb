# frozen_string_literal: true

require_relative 'instance_counter'
require_relative 'company'
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'passenger_train'
require_relative 'cargo_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'

class Main
  MENU = [
    { id: 0, title: 'Выйти из приложения', action: :exit },
    { id: 1, title: 'Создать станцию"', action: :new_station },
    { id: 2, title: 'Создать поезд', action: :new_train },
    { id: 3, title: 'Создать маршрут', action: :new_route },
    { id: 4, title: 'Добавить станцию в маршрут', action: :add_station },
    { id: 5, title: 'Удалить станцию из маршрута', action: :delete_station },
    { id: 6, title: 'Назначить маршрут поезду', action: :set_route },
    { id: 7, title: 'Прицепить вагон к поезду', action: :set_wagon },
    { id: 8, title: 'Отцепить вагон от поезда', action: :delete_wagon },
    { id: 9, title: 'Переместить поезд по маршруту вперед', action: :next_station },
    { id: 10, title: 'Переместить поезд по маршруту назад', action: :previous_station },
    { id: 11, title: 'Просмотреть список станций на маршруте', action: :list_stations },
    { id: 12, title: 'Просмотреть список поездов на станции', action: :list_trains },
    { id: 13, title: 'Просмотреть список поездов на станции с указанием харатеристик',
      action: :list_trains_on_station },
    { id: 14, title: 'Просмотреть список вагонов у поезда', action: :wagons_list },
    { id: 15, title: 'Занять место/объем в вагоне', action: :take_spaces }

  ].freeze

  def initialize
    @trains = []
    @routes = []
    @stations = []
  end

  def start_menu
    puts ''
    puts ''
    puts 'Меню:'
    MENU.each do |item|
      puts "#{item[:id]} - #{item[:title]}"
    end
  end

  def program
    loop do
      start_menu
      puts 'Выберите необходимое действие и введите соответствующую цифру:'
      choice = gets.chomp.to_i
      break if choice.zero?

      puts
      send(MENU[choice][:action])
    end
  end

  def new_station
    name = ask('Введите наименование станции')
    @stations << Station.new(name)
    puts "Станция #{name} создана."
  rescue RuntimeError => e
    puts e.message
    retry
  end

  def new_train
    id = ask('Введите номер поезда согласно формату xxx-xx или xxxxx')
    company = ask('Введите наименование производителя поезда')
    puts 'Выберите тип поезда: passenger или cargo'
    type = gets.chomp.to_sym
    if type == :passenger
      train = PassengerTrain.new(id, type, company)
      puts "Пассажирский поезд № #{id} создан, производитель поезда: #{company}"
    else
      train = CargoTrain.new(id, type, company)
      puts "Грузовой поезд № #{id} создан производитель поезда: #{company}"
    end
    @trains << train
  rescue RuntimeError => e
    puts e.message
    retry
  end

  def new_route
    start_station = ask('Укажите первую станцию маршрута')
    finish_station = ask('Укажите последнюю станцию маршрута')
    @stations <<
      first_station = Station.new(start_station)
    last_station = Station.new(finish_station)
    @routes << route = Route.new(first_station, last_station)
    puts "Маршрут создан. Начальная станция #{start_station}, конечная станция #{finish_station}"
  rescue RuntimeError => e
    puts e.message
    retry
  end

  def add_station
    name = ask('Введите наименование промежуточной станции')
    station = Station.new(name)
    @stations.insert(-2, station)
  end

  def delete_station
    station = ask('Введите наименование станции')
    @stations.delete(find_station(station))
  end

  def set_route
    id = ask('Введите номер поезда')
    start_station = ask('Введитете наименование первой станции')
    finish_station = ask('Введитете наименование конечной станции')
    first_station = Station.new(start_station)
    last_station = Station.new(finish_station)
    @stations << last_station
    @stations << first_station
    route = Route.new(first_station, last_station)
    train(id).take_route(route)
    first_station.add_train(train(id))
  end

  def set_wagon
    id = ask('Введите номер поезда, к которому необходимо прицепить вагон')
    number = ask_num('Введите номер вагона')
    wagon_type = ask_num('Введите тип вагона 1 - пассажирский, 2 - грузовой')
    company = ask('Введите наименование производителя вагона')
    case wagon_type
    when 1
      amount_space = ask_num('Введите общее количество мест в вагоне')
      wagon = PassengerWagon.new(number, company, amount_space, :passenger)
    when 2
      amount_space = ask_num('Введите объем грузового вагона')
      wagon = CargoWagon.new(number, company, amount_space, :cargo)
    end
    train(id).add_wagon(wagon)
    puts "Вагон №#{number}, производителя #{company} успешно присоединен к поезду №#{id}"
  rescue RuntimeError => e
    puts e.message
    retry
  end

  def delete_wagon
    id = ask('Введите номер поезда')
    number = ask_num('Введите номер вагона')
    train(id).delete_wagon(wagon_of_train(id, number))
  end

  def next_station
    train.next_station
  end

  def previous_station
    train.previous_station
  end

  def list_stations
    route.all_stations
  end

  def list_trains
    @id_trains.each { |id| puts id }
  end

  def list_trains_on_station
    station_name = ask('Введите наименование станции')
    station(station_name).trains_on_station do |train|
      puts "#{train.type} поезд №#{train.id}, количество вагонов #{train.amount_of_wagons}"
    end
  end

  def station(station)
    @stations.find { |object| object.name == station }
  end

  def wagons_list
    id = ask('Введите номер поезда')
    train(id).wagons_of_train do |wagon|
      if wagon.type == :passenger
        puts "Пассажирский вагон #{wagon.number}. Свободно:#{wagon.free_space}, занято #{wagon.occupied_space}"
      else
        puts "Грузовой вагон №#{wagon.number}. Свободно:#{wagon.free_space}, занято: #{wagon.occupied_space}"
      end
    end
  end

  def train(id)
    @trains.find { |train| train.id == id }
  end

  def wagon_of_train(id, number)
    train(id).wagons.find { |wagon| wagon.number == number }
  end

  def take_spaces
    id = ask('Введите номер поезда')
    number = ask_num('Введите номер вагона')
    if train(id).type == :passenger
      wagon1 = wagon_of_train(id, number)
      wagon1.take_space
    else
      volume = ask_num('Введите загружаемый объем')
      wagon_of_train(id, number).take_space(volume)
    end
  end

  def ask(question)
    puts question
    gets.chomp
  end

  def ask_num(question)
    puts question
    gets.chomp.to_i
  end
end

Main.new.program
