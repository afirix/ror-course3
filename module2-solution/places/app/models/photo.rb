class Photo
	attr_accessor :id, :location
	attr_writer :contents

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.all(offset=0, limit=nil)
		view = mongo_client.database.fs.find.skip(offset)
		view = view.limit(limit) if limit
		view.map { |doc| Photo.new(doc) }
	end

	def self.find(id)
		_id = BSON::ObjectId.from_string(id)
		doc = mongo_client.database.fs.find(_id: _id).first
		Photo.new(doc) if doc
	end

	def self.find_photos_for_place(place_id)
		place_id = BSON::ObjectId.from_string(place_id)
		mongo_client.database.fs.find('metadata.place': place_id)
	end

	def initialize(hash={})
		return unless hash
		
		@id = hash[:_id].to_s if hash[:_id]
		@location = Point.new(hash[:metadata][:location]) if hash[:metadata] && hash[:metadata][:location]
		@place = hash[:metadata][:place] if hash[:metadata]
	end

	def persisted?
		!@id.nil?
	end

	def save
		if persisted?
			_id = BSON::ObjectId.from_string(@id)
			self.class.mongo_client.database.fs.find({_id: _id})
				.update_one({'$set': {
					'metadata.location': @location.to_hash,
					'metadata.place': @place
				}})
		else
			gps = EXIFR::JPEG.new(@contents).gps
			@location = Point.new(lng: gps.longitude, lat: gps.latitude)

			description = {}
			description[:content_type] = 'image/jpeg'
			description[:metadata] = {}
			description[:metadata][:location] = @location.to_hash
			description[:metadata][:place] = @place

			@contents.rewind
			grid_file = Mongo::Grid::File.new(@contents.read, description)
			id = self.class.mongo_client.database.fs.insert_one(grid_file)

			@id = id.to_s
		end
	end

	def contents
		_id = BSON::ObjectId.from_string(@id)
		grid_file = self.class.mongo_client.database.fs.find_one(_id: _id)
		chunks = grid_file.chunks.map { |chunk| chunk.data.data }
		chunks.reduce(:concat)
	end

	def destroy
		_id = BSON::ObjectId.from_string(@id)
		grid_file = self.class.mongo_client.database.fs.find_one(_id: _id)
		self.class.mongo_client.database.fs.delete_one(grid_file)
	end

	def find_nearest_place_id(max_meters)
		doc = Place.near(@location, max_meters).limit(1).projection({_id: 1}).first
		doc[:_id] if doc
	end

	def place
		Place.find(@place) if @place
	end

	def place=(new_place)
		@place = new_place unless new_place

		case
		when new_place.is_a?(Place)
			@place = BSON::ObjectId.from_string(new_place.id)
		when new_place.is_a?(String)
			@place = BSON::ObjectId.from_string(new_place)
		when new_place.is_a?(BSON::ObjectId)
			@place = new_place
		end
	end

end