module Api
	class RaceResultsController < ApplicationController

		protect_from_forgery with: :null_session

		def index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results"
			else
				race = Race.find(params[:race_id])
				@entrants = race.entrants

				max_updated_at = race.entrants.max(:updated_at)
				fresh_when last_modified: max_updated_at if stale? max_updated_at
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results/#{params[:id]}"
			else
				@result = Race.find(params[:race_id]).entrants.where(id: params[:id]).first
			end
		end

		def create
			if !request.accept || request.accept == "*/*"
				render plain: :nothing, status: :ok
			else
				#real implementation
			end
		end

		def update
			entrant = Race.find(params[:race_id]).entrants.where(id: params[:id]).first

			result = params[:result]
			if result
				if result[:swim]
					entrant.swim = entrant.race.race.swim
					entrant.swim_secs = result[:swim].to_f
				end
				if result[:t1]
					entrant.t1 = entrant.race.race.t1
					entrant.t1_secs = result[:t1].to_f
				end
				if result[:bike]
					entrant.bike = entrant.race.race.bike
					entrant.bike_secs = result[:bike].to_f
				end
				if result[:t2]
					entrant.t2 = entrant.race.race.t2
					entrant.t2_secs = result[:t2].to_f
				end
				if result[:run]
					entrant.run = entrant.race.race.run
					entrant.run_secs = result[:run].to_f
				end
				entrant.save
			end

			render plain: :nothing, status: :ok
		end

	end
end