class Point
	attr_accessor :longitude, :latitude

	def initialize(longitude, latitude)
		@longitude = longitude
		@latitude = latitude
	end

	def mongoize
		{ type: "Point", coordinates: [@longitude, @latitude] }
	end

	def self.mongoize(object)
		case object
		when nil then
			nil
		when Hash then
			object
		when Point then
			object.mongoize
		end
	end

	def self.demongoize(object)
		case object
		when nil then
			nil
		when Hash then
			coordinates = object[:coordinates]
			Point.new(coordinates[0], coordinates[1]) if coordinates
		when Point then
			object
		end
	end

	def self.evolve(object)
		mongoize(object)
	end
	
end