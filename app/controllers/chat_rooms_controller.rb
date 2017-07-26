class ChatRoomsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_social_layout
  before_action :remove_footer, only: [:show, :conversations]
  before_action :find_and_check_chat_room, only: [:edit, :update, :destroy]
  before_action :get_chat_room, only: [:show, :get_chat_messages, :update_last_seen]

  def index
    @chat_room = ChatRoom.new
    get_trending_rooms
  end

  def get_sub_categories
    category = MainCategory.find_by_id params[:id]
    @sub_categories = category.sub_categories
    respond_to :js
  end

  def new
    @chat_room = ChatRoom.new
  end

  def create
    @chat_room = current_user.chat_rooms.new(chat_room_params)
    if @chat_room.save
      flash[:notice] = "#{@chat_room.name} created successfully"
      redirect_to chat_room_path(@chat_room)
    else
      flash[:alert] = @chat_room.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
  end

  def update
    #if @chat_room.update
    #  flash[:notice] = "#{@chat_room.name} updated successfully"
    #else
    #  flash[:alert] = @chat_room.errors.full_messages.join(", ")
    #end
    #respond_to :js
  end

  def destroy
  end

  def show
    if @chat_room.blank?
      redirect_to root_path
      return
    end
    if current_user
      current_user.join_chat_room(@chat_room) unless current_user.joined_chat_room?(@chat_room)
      current_user.get_membership(@chat_room).update_attribute(:last_seen, Time.now.utc) #Need callback to function
    end
    @count = @chat_room.online_count
    @chat_messages = @chat_room.chat_messages.order(created_at: :desc).limit(20).reverse
    respond_to do |format|
      format.js {respond_to :js}
      format.html {respond_to :html}
    end
  end

  def conversations
    @messaged_chat_rooms = current_user.joined_chat_rooms.where("chat_rooms.id in (?)", current_user.chat_messages.select("DISTINCT chat_room_id")).public_rooms.includes(:chat_messages).order("chat_messages.created_at DESC")
    @inactive_chatrooms = current_user.joined_chat_rooms.where("chat_rooms.id not in (?)", current_user.chat_messages.select("DISTINCT chat_room_id"))
    @joined_chat_rooms = current_user.joined_chat_rooms
    if @joined_chat_rooms.blank?
      get_trending_rooms
    else
      if @messaged_chat_rooms.present?
        @first_room = @messaged_chat_rooms.first
      elsif @inactive_chatrooms.present?
        @first_room = @inactive_chatrooms.first
      end
      @count = @first_room.online_count
      @messaged_chat_room_messages = @first_room.chat_messages.order(created_at: :desc).limit(20).reverse
      @first_message = @messaged_chat_room_messages.first
    end
  end

  def update_last_seen
    if @chat_room.present?
      if current_user.get_membership(@chat_room).update_attribute(:last_seen, Time.now.utc)
        render json: {success: true}
      else
        render json: {success: false}
      end
    else
      render json: {success: false}
    end
  end

  def get_chat_messages
    @chat_messages = @chat_room.chat_messages.where("id < ?", params[:last_id]).order(created_at: :desc).limit(20).reverse
    @chat_messages.present? ? @remaining_count = @chat_room.chat_messages.where("id < ?", @chat_messages.first.id).count : @remaining_count = 0
    respond_to :js
  end

  def autocomplete
    render json: ChatRoom.search(params[:q], autocomplete: true, limit: 20).map(&:name)
  end

  private

  def chat_room_params
    params.require(:chat_room).permit(:name, :main_category_id, :sub_category_id)
  end

  def find_and_check_chat_room
    current_user.chat_rooms.find_by_id params[:id]
  end

  def get_chat_room
    @chat_room = ChatRoom.find_by_id params[:id]
  end

  def get_trending_rooms
    @trending_chat_rooms = ChatRoom.joins(:chat_messages).order('count(chat_messages.chat_room_id) DESC').group('chat_rooms.id').limit(12)
  end

end
