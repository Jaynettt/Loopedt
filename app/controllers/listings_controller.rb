
class ListingsController < Web::PublicController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :require_logged_in_user!, only: [:new, :create, :edit, :update]
  before_action :require_approved_seller!, only: [:new, :create, :edit, :update]

  def new
    @listing = Listing.new
  end

  def index
    @listings = Listing.includes(:user, :category).with_attached_images

    @listings = @listings.where(category_id: params[:category_id]) if params[:category_id].present?
    @listings = @listings.where(condition: params[:condition]) if params[:condition].present?
    @listings = @listings.where(brand: params[:brand]) if params[:brand].present?
    @listings = @listings.where(size: params[:size]) if params[:size].present?
    @listings = @listings.where(colour: params[:colour]) if params[:colour].present?
    @listings = @listings.where("price >= ?", params[:min_price]) if params[:min_price].present?
    @listings = @listings.where("price <= ?", params[:max_price]) if params[:max_price].present?

    if params[:search].present?
      search = "%#{params[:search]}%"
      @listings = @listings.where(
        "title ILIKE :search OR description ILIKE :search OR brand ILIKE :search",
        search: search
      )
    end

    @listings = @listings.where(status: params[:status]) if params[:status].present?
    @listings = @listings.order(created_at: :desc)

    render :index
  end

  def show
    render :show
  end

  def new
    @listing = Listing.new
  end

  def edit
    unless current_user && @listing.user_id == current_user.id
      redirect_to seller_dashboard_path, alert: "You are not authorised to edit this listing."
      return
    end
  end

  def create
    @listing = current_user.listings.build(listing_params)

    if @listing.save
      attach_images

      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing),
                      notice: "Your listing has been published successfully!"
        end

        format.json do
          render json: listing_response(@listing), status: :created
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: {
            error: "Unable to create listing",
            messages: @listing.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    unless current_user && @listing.user_id == current_user.id
      redirect_to seller_dashboard_path, alert: "You are not authorised to edit this listing."
      return
    end

    if @listing.update(listing_params)
      attach_images

      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing), notice: "Listing updated successfully!"
        end

        format.json { render json: listing_response(@listing) }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: {
            error: "Unable to update listing",
            messages: @listing.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    unless current_user && @listing.user_id == current_user.id
      redirect_to seller_dashboard_path, alert: "You are not authorised to delete this listing."
      return
    end

    @listing.destroy

    respond_to do |format|
      format.html do
        redirect_to seller_dashboard_path, notice: "Listing deleted successfully."
      end

      format.json do
        render json: { message: "Listing deleted successfully" }
      end
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_logged_in_user!
    return if current_user

    redirect_to "/login", alert: "Please log in first."
  end

  def require_approved_seller!
    return unless current_user

    unless current_user.seller_application&.status == "approved"
      redirect_to seller_onboarding_path,
                  alert: "Your seller application is not yet approved."
    end
  end

  def set_listing
    @listing = Listing.includes(:user, :category)
                      .with_attached_images
                      .find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :category_id,
      :title,
      :description,
      :price,
      :condition,
      :brand,
      :size,
      :colour,
      :status,
      :bust,
      :waist,
      :hips,
      :length
    )
  end

  def attach_images
    return unless params[:images].present?

    @listing.images.attach(params[:images])
  end

  def listing_response(listing)
    listing.as_json(
      include: {
        user: {
          only: [:id, :username, :first_name, :last_name, :verified]
        },
        category: {
          only: [:id, :name]
        }
      }
    )
  end
end
