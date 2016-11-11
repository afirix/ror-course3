module Api
	class RacesController < ApplicationController

		protect_from_forgery with: :null_session

		def index
			offset = params[:offset]
			limit = params[:limit]

			if !request.accept || request.accept == "*/*"
				render plain: "/api/races, offset=[#{offset}], limit=[#{limit}]"
			else
				#real implementation ...
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:id]}"
			else
				@race = Race.find(params[:id])
				#render json: race
			end
		end

		def create
			if !request.accept || request.accept == "*/*"
				race = params[:race]
			  race_name = race[:name] if race
				render plain: race_name
			else
				race = Race.create(race_params)
				render plain: race.name, status: :created
			end
		end

		def update
			race = Race.find(params[:id])
			race.update(race_params)
			render json: race
		end

		def destroy
			race = Race.find(params[:id])
			race.destroy
			render nothing: true, status: :no_content
		end

		rescue_from Mongoid::Errors::DocumentNotFound do |exception|
			if !request.accept || request.accept == "*/*"
			  render plain: "woops: cannot find race[#{params[:id]}]", status: :not_found
			else
				render status: :not_found, template: "api/error_msg", locals: { msg: "woops: cannot find race[#{params[:id]}]" }
			end
		end

		rescue_from ActionView::MissingTemplate do |exception|
			Rails.logger.debug exception
			render plain: "woops: we do not support that content-type[#{request.accept}]", status: :unsupported_media_type
		end

		private
		  def race_params
        params.require(:race).permit(:name, :date)
      end

	end
end