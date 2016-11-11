class Place
	include ActiveModel::Model
	attr_accessor :id, :formatted_address, :location, :address_components

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		mongo_client[:places]
	end

	def self.load_all(io)
		json = File.read(io)
		hash = JSON.parse(json)
		collection.insert_many(hash)
	end

	def self.find_by_short_name(short_name)
		collection.find("address_components.short_name" => short_name)
	end

	def self.to_places(view)
		view.map { |doc| Place.new(doc) }
	end

	def self.find(id)
		_id = BSON::ObjectId.from_string(id)
		view = collection.find(_id: _id)
		Place.new(view.first) if view.count > 0
	end

	def self.all(offset=0, limit=nil)
		view = collection.find.skip(offset)
		view = view.limit(limit) if limit
		places = []
		view.each do |r|
			places << Place.new(r)
		end
		return places
	end

	def self.get_address_components(sort={}, offset=nil, limit=nil)
		pipeline = [
		{
			'$unwind': '$address_components'
		},
		{
			'$project': {
				_id: 1,
				address_components: 1,
				formatted_address: 1,
				'geometry.geolocation' => 1
			}
		}]

		pipeline << {'$sort': sort} if sort.any?
		pipeline << {'$skip': offset} if offset
		pipeline << {'$limit': limit} if limit

		collection.find.aggregate(pipeline)
	end

	def self.get_country_names
		collection.find.aggregate([
		{
			'$unwind': '$address_components'
		},
		{
			'$unwind': '$address_components.types'
		},
		{
			'$project': {
				'address_components.long_name': 1,
				'address_components.types': 1
			}
		},
		{
			'$match': {
				'address_components.types': 'country'
			}
		},
		{
			'$group': {
				_id: '$address_components.long_name'
			}
		}]).to_a.map {|doc| doc[:_id]}
	end

	def self.find_ids_by_country_code(country_code)
		collection.find.aggregate([
		{
			'$match': {
				'address_components.short_name': country_code
			}
		},
		{
			'$project': {
				_id: 1
			}
		}]).to_a.map {|doc| doc[:_id].to_s}
	end

	def self.create_indexes
		collection.indexes.create_one({'geometry.geolocation': Mongo::Index::GEO2DSPHERE})
	end

	def self.remove_indexes
		collection.indexes.drop_one('geometry.geolocation_2dsphere')
	end

	def self.near(point, max_meters=nil)
		near_hash = {}
		near_hash[:$geometry] = point.to_hash
		near_hash[:$maxDistance] = max_meters if max_meters

		collection.find({
			'geometry.geolocation': {
				'$near': near_hash
			}
		})
	end

	def initialize(hash)
		return unless hash

		@id = hash[:_id].to_s
		@formatted_address = hash[:formatted_address]
		@location = Point.new(hash[:geometry][:geolocation])

		@address_components = []
		acs = hash[:address_components]
		@address_components = acs.map { |ac| AddressComponent.new(ac) } unless acs.nil?
	end

	def near(max_meters=nil)
		places = self.class.near(@location, max_meters)
		self.class.to_places(places)
	end

	def photos(offset=0, limit=nil)
		view = Photo.find_photos_for_place(@id).skip(offset)
		view = view.limit(limit) if limit
		view.map { |doc| Photo.new(doc) }
	end

	def persisted?
		!@id.nil?
	end

	def destroy
		_id = BSON::ObjectId.from_string(@id)
		self.class.collection.delete_one(_id: _id)
	end

end