
#Creator: Nil Medvedev


#Задача ActiveRecord.
#Сделать динамеческий поиск по параметрам. Нужно реализовать:
#1.	класс Entry с реализацией динамического поиска по параметрам определенным в наследуемых классах
#2.	класс Person < Entry с параметрами: "name", "second_name", "age", "sex"
#3.	нужно сгенерировать данные по которым будет работать поиск
#4.	необходима реализация для динамических запросов как - "find_by_name", "find_by_age", ... Эти методы не должны быть явно определены а создаваться в зависимости от определенных параметров наследуемого класса.
#5.	объекты должны храниться по правилу FIFO

#Пример:
#Person.find_by_name("Ivan") # результат - массив содержащий все объекты у которых name == "Ivan"
#Person.find_first_by_second_name("Ivanov") # результат - объект содержащий первое соответствие second_name == "Ivanov"




# fifo implementation
module Fifo
  @@fifo = []
  def all_instances
    @@fifo.select { |el| p el if el.class == self.class }
  end

  def add_element_to_fifo(obj)
    @@fifo.push(obj)
  end

  def get_element_from_fifo
    @@fifo.shift
  end

  def fifo_empty?
    @@fifo.empty?
  end

  def start_fifo_immutable_transact
    @@fifo_dup = @@fifo.dup
  end

  def end_fifo_immutable_transact
    @@fifo = @@fifo_dup.dup
  end
end

# Entry implementation
class Entry
  # just show all subclasses
  def self.descendants
    @desc = ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def method_missing(*args)
    if args[0].to_s.include? 'find'
      start_fifo_immutable_transact
      first_flag = 0
      el_arr = []
      first_flag = if args[0].to_s.include? 'first'
                     1
                   else
                     0
                   end

      obj_inst_var = instance_variables; obj_inst_var.map! { |value| value.to_s.tr('@', '') }
      method_name = args[0].to_s.split('by_')[-1]
      parameter_value = args[1]

      p self.class.to_s + ' ' + method_name + ' = ' + parameter_value

      until fifo_empty?
        el = get_element_from_fifo
        if el.class == self.class && el.public_send(method_name).casecmp(parameter_value.downcase).zero? && first_flag == 0
          el_arr << el
        elsif el.class == self.class && el.public_send(method_name).casecmp(parameter_value.downcase).zero? && first_flag == 1
          p el
          break
        end
      end

      if el_arr.count == 0 && first_flag == 0
        p 'No Data'
      else
        el_arr.select { |el| p el }
      end
      # return array
      end_fifo_immutable_transact
    else
      # do nothing
      p 'No such implementation'
    end
  end
end

# Person subclass
class Person < Entry
  include Fifo
  attr_accessor :name, :second_name, :age, :sex
  def initialize(name, second_name, age, sex)
    @name = name
    @second_name = second_name
    @age = age
    @sex = sex
    add_element_to_fifo(self)
  end
end

# Car class
# Entry can work with several subclasses
class Car < Entry
  include Fifo
  attr_accessor :type, :brand, :year
  def initialize(type, brand, year)
    @type = type
    @brand = brand
    @year = year
    add_element_to_fifo(self)
  end
end

# #generate some data
session = true
person = Person.new('Sergey', 'Black', '1994', 'm')
person = Person.new('Sasha', 'White', '1980', 'm')
person = Person.new('Vlad', 'Orange', '2000', 'm')
person = Person.new('Nick', 'Pink', '1947', 'm')
person = Person.new('Test', 'Purple', '2017', 'm')
person = Person.new('Vlada', 'Grey', '1993', 'f')
person = Person.new('Hanna', 'Blue', '1995', 'f')
person = Person.new('Vika', 'Green', '2000', 'f')
person = Person.new('Karina', 'Summertime', '1980', 'f')
car = Car.new('Truck', 'BMW', '1999')
car = Car.new('Truck', 'BMW', '1999')
car = Car.new('Pickup', 'Ford', '1930')
car = Car.new('Sedan', 'Kia', '2015')

puts "
Hi, choose method and enter parameters
1.Person find by name
2.Person find first by second_name
3.Person find by age
4.Person find by sex
5.Show all persons
6.Car find by type
7.Show all cars
0.Exit
A.descendants of Entry"

puts 'Enter parameters'
while session == true
  arr_input = gets.chomp.split
  if arr_input[0] == '1' && arr_input.count == 2
    person.find_by_name(arr_input[1])
    puts 'find_by_name is done'
  elsif arr_input[0] == '2' && arr_input.count == 2
    person.find_first_by_second_name(arr_input[1])
    puts 'find_first_by_second_name is done'
  elsif arr_input[0] == '3' && arr_input.count == 2
    person.find_by_name(arr_input[1])
    puts 'find_by_age is done'
  elsif arr_input[0] == '4' && arr_input.count == 2
    person.find_by_sex(arr_input[1])
    puts 'find_by_sex is done'
  elsif arr_input[0] == '5'
    person.all_instances
    puts 'all persons is done'
  elsif arr_input[0] == '6' && arr_input.count == 2
    car.find_by_type(arr_input[1])
    puts 'find_car_by_type is done'
  elsif arr_input[0] == '7'
    car.all_instances
    puts 'all cars is done'
  elsif arr_input[0] == '0' && arr_input.count == 1
    session = false
    puts 'Bye!'
  elsif arr_input[0] == 'A' && arr_input.count == 1
    p Entry.descendants
  else puts 'Wrong input. Try again.'
  end
end
#
