class RunResult < LegResult
	
	field :mmile, as: :minute_mile, type: Float

	def calc_ave
		return unless event && secs
		self.minute_mile = (secs / 60) / event.miles
	end
	
end