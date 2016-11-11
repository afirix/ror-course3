class Point
	attr_accessor :longitude, :latitude

	def initialize(hash)
		hash = hash.with_indifferent_access
		if hash.key?(:type)
			@longitude = hash[:coordinates][0]
			@latitude = hash[:coordinates][1]
		else
			@longitude = hash[:lng]
			@latitude = hash[:lat]
		end
	end

	def to_hash
		{type: "Point", coordinates: [longitude, latitude]}
	end
end