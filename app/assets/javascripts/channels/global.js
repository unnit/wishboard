$(document).ready(function(){
  App.global = App.cable.subscriptions.create({channel: "GlobalChannel"},
  {
    received: function(data) {
      if(data['count'] > 0){
        $(".chat-room-online-count"+data['chat_room_id']).html(data['count']);
        $(".chat-room-online-status"+data['chat_room_id']).removeClass('hidden');
      }
      else{
        $(".chat-room-online-count"+data['chat_room_id']).html('');
        $(".chat-room-online-status"+data['chat_room_id']).addClass('hidden');
      }
    }
  });
});