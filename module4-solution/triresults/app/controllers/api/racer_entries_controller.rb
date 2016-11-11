module Api
	class RacerEntriesController < ApplicationController

		protect_from_forgery with: :null_session

		def index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries"
			else
				#real implementation ...
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}"
			else
				#real implementation ...
			end
		end

		def create
			if !request.accept || request.accept == "*/*"
				render plain: :nothing, status: :ok
			else
				#real implementation
			end
		end

	end
end