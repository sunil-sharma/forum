class Api::V1::CoursesController < ApplicationController
  def index
    render json: {message: "Authenticated successfuly"}, status: :ok and return
  end
end
