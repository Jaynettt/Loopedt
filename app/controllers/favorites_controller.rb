class FavoritesController < ApplicationController
  def index
    @user = User.find(params[:user_id])

    @favorites = @user.favorites
                       .includes(listing: [:user, :category])
                       .with_attached_images

    render :index
  end

  def create
    @user = User.find(params[:user_id])
    @listing = Listing.find(params[:listing_id])

    @favorite = @user.favorites.build(listing: @listing)

    if @favorite.save
      render :show, status: :created
    else
      render json: {
        error: "Unable to favorite listing",
        messages: @favorite.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @favorite = @user.favorites.find_by!(listing_id: params[:listing_id])

    @favorite.destroy

    render json: {
      message: "Listing removed from favorites"
    }
  end

  private

  def set_favorite
    @favorite = Favorite.find(params[:id])
  end
end
