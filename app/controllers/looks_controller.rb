
class LooksController < ApplicationController
  before_action :require_login!
  before_action :set_look, only: [:show]

  def new
    @look = current_user.looks.new
  end

  def create
    @look = current_user.looks.new(look_params)
    @look.status = "uploaded"

    if @look.save
      if params[:look][:inspiration_image].present?
        @look.inspiration_image.attach(params[:look][:inspiration_image])
      end

      redirect_to look_path(@look),
                  notice: "Your inspiration look has been uploaded!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    unless @look.user_id == current_user.id
      redirect_to new_look_path, alert: "You cannot access this look."
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login!
    redirect_to "/login", alert: "Please log in first." unless current_user
  end

  def set_look
    @look = Look.find(params[:id])
  end

  def look_params
    params.require(:look).permit(:title, :source_url)
  end
end
