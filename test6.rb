#Clase Hola
class Hola
  attr_accessor :hi
  attr_reader :some
  attr_writer :thing
  def say a , b
    puts a
    puts b
  end
  def set b
    @some = b
  end
  def thingy
    puts @thing
  end
end

al = Hola.new
al.say 'hola andreas', "final"
al.set 'seteando un attr'
al.say 'hi', 'chau'
al.hi = 'yummy'
puts al.hi
al.say 'hola' , 'chau'
al.thing = 333
al.thingy
al.thing = 334
al.thingy
puts al.some

puts "----------------------------------"
# define la clase Perro
class Perro  
  # método inicializar clase
  def initialize(raza, nombre)
    # atributos
    @raza = raza
    @nombre = nombre
  end
  
  # método ladrar
  def ladrar
    puts 'Guau! Guau!'
  end
  
  # método saludar
  def saludar
    puts "Mi raza es"
# #{@raza}"
    puts @raza
    puts "y mi nombre es" 
# #{@nombre}"
    puts @nombre
  end
  
end

# para crear nuevos objetos, se usa el método new
d = Perro.new( 'Labrador' , 'Benzy' )
# usamos la instancia ahora
d.ladrar
d.saludar
puts "-----"
# con esta variable, apuntamos al mismo objeto
d1 = d
d1.saludar
