class BikeResult < LegResult
	
	field :mph, type: Float

	def calc_ave
		return unless event && secs
		self.mph = event.miles * 3600 / secs
	end
	
end