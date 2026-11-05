class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]

  def index
    @categories = Category.includes(:listings).order(:name)

    render :index
  end

  def show
    @listings = @category.listings
                         .includes(:user, :category)
                         .with_attached_images
                         .order(created_at: :desc)

    render :show
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      render :show, status: :created
    else
      render json: {
        error: "Unable to create category",
        messages: @category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render :show
    else
      render json: {
        error: "Unable to update category",
        messages: @category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render json: {
        message: "Category deleted successfully"
      }
    else
      render json: {
        error: "Unable to delete category",
        messages: @category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
