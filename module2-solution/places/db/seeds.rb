# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'pp'

Photo.all.each { |photo| photo.destroy }
Place.all.each { |place| place.destroy }
Place.create_indexes
Place.load_all(File.open('./db/places.json'))
Dir.glob('./db/image*.jpg') { |file| photo = Photo.new; photo.contents = File.open(file, 'rb'); photo.save }
Photo.all.each { |photo| place = photo.find_nearest_place_id(1*1609.34); photo.place = place; photo.save }
pp Place.all.reject {|pl| pl.photos.empty?}.map {|pl| pl.formatted_address}.sort
