$(document).ready(function(){
  if($("body").data("logged-in-id") != ""){
    App.global = App.cable.subscriptions.create({channel: "GlobalChannel"},
    {
      received: function(data) {
        if(data['count'] > 0){
          $(".chat-room-online-"+data['chat_room_id']).removeClass("hidden");
          $(".chat-room-online-"+data['chat_room_id']).find(".online-count-wrap").html(data['count']);
          $(".chat-room-online-"+data['chat_room_id']).find(".j-online-users-wrap").html(data['online_users_name']);
        }
        else{
          $(".chat-room-online-"+data['chat_room_id']).addClass("hidden");
          $(".chat-room-online-"+data['chat_room_id']).find(".online-count-wrap").html('');
          $(".chat-room-online-"+data['chat_room_id']).find(".j-online-users-wrap").html('');
        }
      }
    });
  }
});
