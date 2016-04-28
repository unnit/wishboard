class HomeController < ApplicationController
  skip_before_filter :check_user_status, :check_profile, :check_interests, only: [:user_signup_confirmation]
  skip_before_filter :check_interests, only: [:interests, :toggle_follow_interest, :follow_all_interest, :unfollow_all_interest]
  before_filter :back_to_home, only: [:authenticate]
  before_filter :authenticate_user!, except: [:myprofile, :myshowpieces, :mywishes, :following, :followers, :user_card, :bulk_bookings, :feed, :index, :offers]
  before_filter :set_profile_caseless, only: [:myprofile, :myshowpieces, :mywishes, :following, :followers]
  before_filter :set_social_layout, except: [:index, :offers, :user_signup_confirmation, :interests, :feed]
  before_filter :set_plain_layout, only: [:user_signup_confirmation, :interests]

  def index
    @adv_search = "none"
  end

  def feed
    if current_user
      @social_layout = "yes"
      @sh_btn = 'none;'
      @showcase = Showcase.new
      @showcase.build_location
      @showcase_updated = true if (params[:showcases].to_i || 0) > (params[:prev_showcase_page].to_i || 0)
      @user_updated = true if (params[:users].to_i || 0) > (params[:prev_user_page].to_i || 0)
      @showcases = Showcase.order("RANDOM()")
      #@showcases = Showcase.all.order(created_at: :desc).page(params[:showcases]).per(2)
      @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(2)
      @users = User.where.not(id:current_user.following.map(&:id).append(current_user.id))
      @users = Kaminari.paginate_array(@users).page(params[:users]).per(5)
      respond_to do |format|
        format.html
        format.js
      end
    else
      @auth_layout = "yes"
      render :authenticate
    end
  end

  def unchecked_notifications
    @unchecked = (current_user.unchecked_wows + current_user.unchecked_comments + current_user.unchecked_followers + current_user.unchecked_showcase_notifications).sort_by{|e| e.created_at}.reverse
    respond_to :js
  end

  def notifications
    @notifications = (current_user.appreciations + current_user.received_comments + current_user.passive_relationships + current_user.showcase_notifications).sort_by{|e| e.created_at}.reverse
    @notifications = Kaminari.paginate_array(@notifications).page(params[:notifications]).per(10)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_all_notifications
    current_user.unchecked_wows.each do |wow|
      wow.update_column :checked, true
    end
    current_user.unchecked_comments.each do |comment|
      comment.update_column :checked, true
    end
    current_user.unchecked_followers.each do |relationship|
      relationship = current_user.passive_relationships.find_by(follower_id: relationship.follower.id)
      relationship.update_column :checked, true
    end
    current_user.unchecked_showcase_notifications.each do |showcase_notification|
      showcase_notification.update_column :checked, true
    end
    respond_to :js
  end

  def update_wow_checked
    wow = Wow.find_by_id params[:id]
    unless wow.blank?
      wow.update_column :checked, true if wow.showcase.user == current_user
      redirect_to showcase_path(wow.showcase)
    else
      redirect_to root_path
    end
  end

  def update_comment_checked
    comment = Comment.find_by_id params[:id]
    unless comment.blank?
      comment.update_column :checked, true if comment.showcase.user == current_user
      redirect_to showcase_path(comment.showcase, q: "#{comment.id}")
    else
      redirect_to root_path
    end
  end

  def update_follower_checked
    user = User.find_by_id params[:id]
    unless user.blank?
      relationship = current_user.passive_relationships.find_by(follower_id: user.id)
      relationship.update_column :checked, true unless relationship.blank?
      redirect_to myprofile_path(user.profile.slug)
    else
      redirect_to root_path
    end
  end

  def update_showcase_checked
    showcase_notification = ShowcaseNotification.find_by_id params[:id]
    unless showcase_notification.blank?
      showcase_notification.update_column :checked, true if showcase_notification.user == current_user
      redirect_to showcase_path(showcase_notification.showcase)
    else
      redirect_to root_path
    end
  end

  def toggle_follow
    @user = User.find_by_id params[:id]
    current_user.toggle_follow!(@user) unless @user == current_user
    @user.reload
    respond_to :js
  end

  def myprofile
    @showcases = @user.showcases.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(2)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def myshowpieces
    @showcases = @user.showcases.showpieces.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(4)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def mywishes
    @showcases = @user.showcases.wishes.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(4)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def following
    @following = @user.following.order(created_at: :desc)
    @following = Kaminari.paginate_array(@following).page(params[:following]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def followers
    @followers = @user.followers.order(created_at: :desc)
    @followers = Kaminari.paginate_array(@followers).page(params[:followers]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def user_card
    user = User.find_by_id params[:id]
    render json: {user: (render_to_string '_user_card', layout: false, locals: {users: Array(user), card_padding: '0px'})}
  end

  def interests
  end

  def following_all
    @users = User.where.not(id:current_user.following.map(&:id).append(current_user.id))
    @users = Kaminari.paginate_array(@users).page(params[:users]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def toggle_follow_interest
    @tag = Tag.find_by_id params[:id]
    current_user.toggle_follow_interest!(@tag)
    @tag.reload
    respond_to :js
  end

  def follow_all_interest
    current_user.activate_all_interest!
    @follow_all = true
    render "toggle_follow_interest.js"
  end

  def unfollow_all_interest
    current_user.deactivate_all_interest!
    @unfollow_all = true
    render "toggle_follow_interest.js"
  end

  def get_state_and_city
    result={city: "", state: "", country: "India"}
    address = Geokit::Geocoders::GoogleGeocoder.geocode "#{params[:zip]} India"
    if address
      logger.info address.state
      result[:city] = address.city
      result[:state] = address.state_name
    end
    render json: result
  end

  def bulk_bookings
    @bulk_booking = BulkBooking.new(bulk_params)
    if @bulk_booking.save
      GLOBAL_VARIABLES[:manager_mobile_nos].each do |no|
        send_mobile_sms(no, "Mobile: #{@bulk_booking.mobile}, Email: #{@bulk_booking.email}")
      end
      message = "Mobile: #{@bulk_booking.mobile}<br>Email: #{@bulk_booking.email}<br><br>#{@bulk_booking.message}"
      UserMailer.bulk_booking_details(message).deliver_now
      flash[:notice] = "Thank you, We will get back to you within few minutes for your booking."
    else
      @errors = @bulk_booking.errors.full_messages
    end
    respond_to :js
  end

  def user_signup_confirmation
    redirect_to root_path unless current_user.inactive
  end

  def authenticate
  end

  def offers
    @product = Product.find_by_id GLOBAL_VARIABLES[:offer_product]
    @offers_visible = "none"
  end

  private

  def bulk_params
    params.require(:bulk_booking).permit(:email, :mobile, :message)
  end

  def back_to_home
    redirect_to root_path if current_user
  end

  def set_profile_caseless
    @profile = Profile.friendly.find params[:id].downcase
    @user = @profile.user
  end

end
