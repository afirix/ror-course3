class Address
	attr_accessor :city, :state, :location

	def initialize(city=nil, state=nil, location=nil)
		@city = city
		@state = state
		@location = location
	end

	def mongoize
		{ city: @city, state: @state, loc: @location.mongoize }
	end

	def self.mongoize(object)
		case object
		when nil then
			nil
		when Hash then
			object
		when Address then
			object.mongoize
		end
	end

	def self.demongoize(object)
		case object
		when nil then
			nil
		when Hash then
			city = object[:city]
			state = object[:state]
			location = Point.demongoize(object[:loc]) if object[:loc]
			Address.new(city, state, location)
		when Address then
			object
		end
	end

	def self.evolve(object)
		mongoize(object)
	end
	
end