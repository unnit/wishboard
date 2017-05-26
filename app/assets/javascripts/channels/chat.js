$(document).ready(function(){
  var messages_to_bottom = function() {
    return $("#chat_messages").scrollTop($("#chat_messages").prop("scrollHeight"));
  };
  messages_to_bottom();
  var values = String($(".chat-ids-holder").data("chat-room-ids")).split(",");
  for(i=0; i<values.length; i++){
    App.chat = App.cable.subscriptions.create({channel: "ChatChannel", chat_room_id: values[i]},
      {
        received: function(data) {
          if($(".chat-room-"+data['chat_room_id']).length > 0){
            $(".chat-room-"+data['chat_room_id']).append($(data['message']).hide());
            if($(".chat-room-"+data['chat_room_id']).data('current-user-id') == data['owner_id']){
              $(".chat-txt-"+data['chat_id']).removeClass("pull-left left-top bg-white mleft5").addClass("pull-right right-top mright5");
              $(".chat-photo-"+data['chat_id']).removeClass("pull-left").addClass("pull-right");
              $(".chat-usr-name-"+data['chat_id']).removeClass("text-left").addClass("text-right");
            }
            $(".chat-"+data['chat_id']).show();
            messages_to_bottom();
          }
          else{
            if($(".chat-conv-card-"+data['chat_room_id']).data('current-user-id') != data['owner_id']){
              var count = $(".chat-conv-card-"+data['chat_room_id']).find(".j-chat-count");
              count.html(parseInt(count.html()) + 1);
              count.fadeIn();
            }
          }
        },
        save_message: function(content, chat_room_id){
          return this.perform('save_message', { content: content, chat_room_id: chat_room_id });
        }
    });
  }
  $(document).on("keypress", ".chat-submit-btn", function(e) {
    if (e.keyCode == 13 && !e.shiftKey){
      e.preventDefault();
      if ($.trim($(this).val()).length >= 1) {
        App.chat.save_message($(this).val(), $(this).closest(".j-c-msg-wrapper").data("chat-room-id"));
        $(this).val('');
      }
    }
  });
})
