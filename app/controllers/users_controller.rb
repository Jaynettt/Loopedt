class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = User.order(created_at: :desc)

    render :index
  end

  def show
    @listings = @user.listings
                     .includes(:category)
                     .with_attached_images
                     .where(status: "available")
                     .order(created_at: :desc)

    render :show
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render :show, status: :created
    else
      render json: {
        error: "Unable to create user",
        messages: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render :show
    else
      render json: {
        error: "Unable to update user",
        messages: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    render json: {
      message: "User deleted successfully"
    }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email,
      :username,
      :first_name,
      :last_name,
      :phone_number,
      :bio
    )
  end
end
