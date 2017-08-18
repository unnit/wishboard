class HomeController < ApplicationController
  before_action :redirect_to_home, only: [:index, :bulk_bookings, :offers, :fansday]
  skip_before_action :check_user_status, :check_profile, :check_interests, only: [:user_signup_confirmation], raise: false
  skip_before_action :check_interests, only: [:interests, :toggle_follow_interest, :follow_all_interest, :unfollow_all_interest], raise: false
  before_action :back_to_home, only: [:authenticate]
  before_action :authenticate_user!, except: [:myprofile, :myshowpieces, :mywishes, :mymomentary, :view_collection, :wiki, :following, :followers, :user_card, :bulk_bookings, :feed, :index, :offers, :about, :terms, :privacy, :contact, :goodness_and_open_source, :sitemap, :fansday, :authenticate, :jobs, :hackers, :cocopay, :refund, :mobile, :save_firebase_token]
  before_action :set_profile_caseless, only: [:myprofile, :myshowpieces, :mywishes, :mymomentary, :view_collection, :following, :followers, :wiki]
  before_action :set_wiki_and_check_owner, only: [:edit_wiki, :delete_wiki]
  before_action :set_social_layout, except: [:index, :offers, :user_signup_confirmation, :interests, :feed, :fansday, :authenticate]
  before_action :set_plain_layout, only: [:user_signup_confirmation, :interests]
  before_action :remove_footer, only: [:feed]
  after_action  :broadcast_notification_count, only: [:update_all_notifications, :update_wow_checked, :update_coin_checked, :update_comment_checked, :update_follower_checked, :update_showcase_checked, :update_commenter_checked, :update_achieved_checked]
  skip_before_action :verify_authenticity_token, only: [:save_firebase_token]
  def index
    @adv_search = "none"
  end

  def feed
    if current_user
      @social_layout = "yes"
      @sh_btn = 'none;'
      @scase_modal = "no"
      @count = feed_wishes.count
      @showcases = feed_wishes.limit(8)
      @all_count = all_wishes(nil).count
      @all_showcases = all_wishes(nil).limit(8)
      admin_wish_conditions = ["admin_created = true and admin_status = #{Showcase::ADMIN_STATUS[0]} and coin_wish = false"]
      unless current_user.showcases.public_accessible.where("parent_id is not null").map{|s| s.parent_id}.uniq.blank?
        admin_wish_conditions[0]+=" and id not in (?) "
        admin_wish_conditions.push current_user.showcases.public_accessible.where("parent_id is not null").map{|s| s.parent_id}.uniq
      end
      @admin_showcases = Showcase.public_accessible.where(admin_wish_conditions).order(created_at: :desc)
      coin_wish_conditions = ["admin_created = true and admin_status = #{Showcase::ADMIN_STATUS[0]} and coin_wish = true"]
      unless current_user.coin_wishes.map{|c| c.id}.uniq.blank?
        coin_wish_conditions[0]+=" and id not in (?) "
        coin_wish_conditions.push current_user.coin_wishes.map{|c| c.parent_id}.uniq
      end
      @coin_wishes = Showcase.public_accessible.where(coin_wish_conditions).order(created_at: :desc)
      #@users = User.joins(:profile).where.not(id:current_user.following.map(&:id).append(current_user.id), verified: false)
      #@users = Kaminari.paginate_array(@users).page(params[:users]).per(5)
      @top_performers = User.where("id in (?)", GLOBAL_VARIABLES[:top_performers])
      @featured_tags = Tag.featured - current_user.active_tags
      reload_wallet
      respond_to do |format|
        format.html
        format.js
      end
    else
      @auth_layout = "yes"
      @remove_footer = nil
      @showcases = Showcase.public_accessible.where('id in (?)', GLOBAL_VARIABLES[:featured_wishes])
      render :authenticate
    end
  end

  def get_showcases
    @last_all_value = params[:last_all_value]
    @all_count = params[:all_count]
    @showcases = Showcase.where("admin_created = ? and user_id in (?) and achieved_at < ?", false, current_user.following.map(&:id).append(current_user.id), params[:last_value]).order(achieved_at: :desc).limit(8)
    @showcases.present? ? @count = Showcase.public_accessible.where("admin_created = ? and user_id in (?) and achieved_at < ?", false, current_user.following.map(&:id).append(current_user.id), @showcases.last.achieved_at).count : @count = 0
    respond_to :js
  end

  def get_all_showcases
    @last_value = params[:last_value]
    @count = params[:count]
    @all_showcases = all_wishes(params[:last_all_value]).limit(8)
    @all_showcases.present? ? @all_count = all_wishes(@all_showcases.last.achieved_at).count : @all_count = 0
    respond_to :js
  end

  def get_similar_friends
    if current_user.active_tags.present?
      @similar_friends = current_user.similar_friends.uniq.reject{|f| f.id == current_user.id || current_user.following.map(&:id).include?(f.id) || f.verified == false}.take(20)
    elsif current_user.referrer.present?
      @similar_friends = current_user.referrer.following.reject{|f| current_user.following.map(&:id).include?(f.id) || f.verified == false}.take(20)
    else
      @similar_friends = User.where("id in (?)", GLOBAL_VARIABLES[:top_performers])
    end
    respond_to :js
  end

  def user_results
    if params[:user_query].present?
      profiles = Profile.where("lower(first_name) = ? or lower(last_name) = ?", params[:user_query].split(" ").first.downcase, params[:user_query].split(" ").last.downcase)
      @users = profiles.map{|p| p.user}
      @users = Kaminari.paginate_array(@users).page(params[:users]).per(20)
    else
      profiles = Profile.all.order(created_at: :desc)
      @users = profiles.map{|p| p.user}
      @users = Kaminari.paginate_array(@users).page(params[:users]).per(20)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def user_autocomplete
    render json: Profile.search(params[:q], autocomplete: true, limit: 20).flat_map{|p| [{first_name: p.first_name, last_name: p.last_name}]}
  end

  def fansday
    @special_layout = "yes"
  end

  def unchecked_notifications
    @unchecked = (current_user.unchecked_wows + current_user.unchecked_comments + current_user.unchecked_followers + current_user.unchecked_showcase_notifications + current_user.unchecked_achieved_notifications + current_user.unchecked_coins + current_user.unchecked_commenter_notifications + current_user.unchecked_fundreceived_notifications).sort_by{|e| e.created_at}.reverse
    respond_to :js
  end

  def notifications
    @notifications = (current_user.appreciations + current_user.coins_gifted + current_user.received_comments + current_user.current_passive_relationships + current_user.showcase_notifications + current_user.active_achieved_notifications + current_user.commenter_notifications + current_user.fundreceived_notifications).sort_by{|e| e.created_at}.reverse
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
    current_user.unchecked_coins.each do |coin|
      coin.update_column :checked, true
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
    current_user.unchecked_achieved_notifications.each do |achieved_notification|
      achieved_notification.update_column :checked, true
    end
    current_user.unchecked_commenter_notifications.each do |commenter_notification|
      commenter_notification.update_column :checked, true
    end
    current_user.unchecked_fundreceived_notifications.each do |fundreceived_notification|
      fundreceived_notification.update_column :checked, true
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

  def update_coin_checked
    coin = Coin.find_by_id params[:id]
    unless coin.blank?
      coin.update_column :checked, true if coin.showcase.user == current_user
      redirect_to showcase_path(coin.showcase)
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

  def update_achieved_checked
    achieved_notification = AchievedNotification.find_by_id params[:id]
    unless achieved_notification.blank?
      achieved_notification.update_column :checked, true if achieved_notification.user == current_user
      redirect_to showcase_path(achieved_notification.showcase)
    else
      redirect_to root_path
    end
  end

  def update_commenter_checked
    commenter_notification = CommenterNotification.find_by_id params[:id]
    unless commenter_notification.blank?
      commenter_notification.update_column :checked, true if commenter_notification.user == current_user
      redirect_to showcase_path(commenter_notification.showcase, q: "#{commenter_notification.comment.id}")
    else
      redirect_to root_path
    end
  end

  def update_fundreceived_checked
    fundreceived_notification = FundreceivedNotification.find_by_id params[:id]
    unless fundreceived_notification.blank?
      fundreceived_notification.update_column :checked, true if fundreceived_notification.user == current_user
      redirect_to showcase_path(fundreceived_notification.cocotransfer.showcase)
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
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Showcases", myprofile_path(@profile.slug)
    if @user == current_user
      @showcases = @user.showcases.where("admin_created = ?", false).order(achieved_at: :desc).limit(6)
    else
      @showcases = @user.showcases.public_accessible.where("admin_created = ?", false).order(achieved_at: :desc).limit(6)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def myshowpieces
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Showcases", myprofile_path(@profile.slug)
    add_breadcrumb "Fulfilled", myshowpieces_path(@profile.slug)
    if @user == current_user
      @showcases = @user.showcases.where("admin_created = ?", false).showpieces.order(achieved_at: :desc)
    else
      @showcases = @user.showcases.public_accessible.where("admin_created = ?", false).showpieces.order(achieved_at: :desc)
    end
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(12)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def mywishes
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Showcases", myprofile_path(@profile.slug)
    add_breadcrumb "Future", mywishes_path(@profile.slug)
    if @user == current_user
      @showcases = @user.showcases.where("admin_created = ?", false).wishes.order(achieved_at: :desc)
    else
      @showcases = @user.showcases.public_accessible.where("admin_created = ?", false).wishes.order(achieved_at: :desc)
    end
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(12)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def mymomentary
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Showcases", myprofile_path(@profile.slug)
    add_breadcrumb "Momentary", mymomentary_path(@profile.slug)
    if @user == current_user
      @showcases = @user.showcases.where("admin_created = ?", false).momentary.order(achieved_at: :desc)
    else
      @showcases = @user.showcases.public_accessible.where("admin_created = ?", false).momentary.order(achieved_at: :desc)
    end
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(12)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def view_collection
    @collection = Collection.find_by_id params[:name]
    if @collection.blank? || @collection.user != @user
      redirect_to root_path
      return
    end
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Showcases", myprofile_path(@profile.slug)
    add_breadcrumb "#{@collection.name}"
    @showcases = @collection.showcases.where("admin_created = ?", false).order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(12)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def following
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Following", following_path(@profile.slug)
    @users = @user.following.order(created_at: :desc)
    @users = Kaminari.paginate_array(@users).page(params[:following]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def followers
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Followers", followers_path(@profile.slug)
    @users = @user.followers.order(created_at: :desc)
    @users = Kaminari.paginate_array(@users).page(params[:followers]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def wiki
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Wiki", wiki_path(@profile.slug)
    @wiki = Wiki.new
  end

  def create_wiki
    @wiki = current_user.wikis.build(title: params[:wiki][:title], description: params[:wiki][:description])
    if @wiki.valid?
      @wiki.save
    else
      flash[:alert] = @wiki.errors.full_messages.join(", ")
    end
    respond_to :js
  end

  def edit_wiki
    @wiki.title = params[:wiki][:title]
    @wiki.description = params[:wiki][:description]
    if @wiki.valid?
      @wiki.save
    else
      flash[:alert] = @wiki.errors.full_messages.join(", ")
    end
    respond_to :js
  end

  def delete_wiki
    @wiki.destroy
    render js: "$('.wiki-#{@wiki.id}').fadeOut();$('.wiki-#{@wiki.id}').remove();"
  end

  def user_card
    user = User.find_by_id params[:id]
    render json: {user: (render_to_string '_user', layout: false, locals: {user: user, card_padding: '0px', card_width: "100%"})}
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
    current_user.active_interests.reload
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
    @auth_layout = "yes"
    @showcases = Showcase.public_accessible.where('id in (?)', GLOBAL_VARIABLES[:featured_wishes])
  end

  def offers
    @product = Product.find_by_id GLOBAL_VARIABLES[:offer_product]
    @offers_visible = "none"
  end

  def check_email
    File.open("#{Rails.root}/lib/emails-invited.csv", "a") do |f|
      f.puts "#{current_user.name}, #{current_user.id} invited these members"
      params[:email].each do |email|
        f.puts email
      end
    end
    head :ok
  end

  def save_firebase_token
   @firebasetoken =   FirebaseToken.where(token: params[:token], user_id: current_user.try(:id)).first_or_create   if current_user
   @firebasetoken.update_attributes(active: true)  if @firebasetoken
   FirebaseToken.where(token: params[:token]).where.not(user_id: current_user.id).update_all(active: false)   if @firebasetoken && current_user
   render json: {saved:  @firebasetoken ? true : false}
  end

  private

  def bulk_params
    params.require(:bulk_booking).permit(:email, :mobile, :message)
  end

  def back_to_home
    redirect_to root_path if current_user
  end

  def set_wiki_and_check_owner
    @wiki =  Wiki.find_by_id params[:id]
    unless @wiki.user == current_user
      redirect_to root_path
      return
    end
  end

  def broadcast_notification_count
   CountBroadcastJob.perform_later(current_user)
  end

  def feed_wishes
    return Showcase.public_accessible.where("admin_created = ? and user_id in (?)", false, current_user.following.map(&:id).append(current_user.id)).order(achieved_at: :desc)
  end

  def all_wishes(last_all_value)
    conditions = ["admin_created = false"]
    unless feed_wishes.blank?
      conditions[0]+=" and id not in (?)"
      conditions.push feed_wishes.map(&:id)
    end
    unless last_all_value.blank?
      conditions[0]+=" and achieved_at < ?"
      conditions.push last_all_value
    end
    return Showcase.public_accessible.where(conditions).order(achieved_at: :desc)
  end

end
