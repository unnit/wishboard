class ChatRoomsController < ApplicationController

  before_action :authenticate_user!, :set_social_layout
  before_action :find_and_check_chat_room, only: [:edit, :update, :destroy]
  before_action :get_chat_room, only: [:get_chat_messages]

  def index
    @chat_room = ChatRoom.new
    get_trending_rooms
  end

  def new
  end

  def create
    @chat_room = current_user.chat_rooms.new(chat_room_params)
    if @chat_room.save
      flash[:notice] = "#{@chat_room.name} created successfully"
      render js: "window.location = '#{GLOBAL_VARIABLES[:root_url]}/chatrooms/#{@chat_room.id}'"
    else
      flash[:alert] = @chat_room.errors.full_messages.join(", ")
      respond_to :js
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
    @chat_room = ChatRoom.includes(:chat_messages).find_by_id params[:id]
    if @chat_room.blank?
      redirect_to root_path
      return
    end
    current_user.join_chat_room(@chat_room) unless current_user.joined_chat_room?(@chat_room)
    @count = @chat_room.online_count
    @chat_messages = @chat_room.chat_messages.order(created_at: :desc).limit(20).reverse
    respond_to do |format|
      format.js {respond_to :js}
      format.html {respond_to :html}
    end
  end

  def conversations
    @public_chat_rooms = current_user.messaged_chat_rooms.public_rooms.to_a.uniq
    if @public_chat_rooms.blank?
      get_trending_rooms
    else
      @count = @public_chat_rooms.first.online_count
      @public_chat_messages = @public_chat_rooms.first.chat_messages.order(created_at: :desc).limit(20).reverse
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
    params.require(:chat_room).permit(:name, :wish_prefix)
  end

  def find_and_check_chat_room
    current_user.chat_room_params.find_by_id params[:id]
  end

  def get_chat_room
    @chat_room = ChatRoom.find_by_id params[:room_id]
  end

  def get_trending_rooms
    @trending_chat_rooms = ChatRoom.where("id in (?) and room_type = ?", ChatMessage.select(:chat_room_id).group(:chat_room_id).order('count(chat_room_id) DESC'), ChatRoom::CHAT_ROOM_TYPES[0][0])
  end

end
