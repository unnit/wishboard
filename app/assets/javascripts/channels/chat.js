$(document).ready(function(){
  var values = String($(".chat-ids-holder").data("chat-room-ids")).split(",");
  for(i=0; i<values.length; i++){
    App.chat = App.cable.subscriptions.create({channel: "ChatChannel", chat_room_id: values[i]},
      {
        received: function(data) {
          $(".online-count").text(data['count']);
          if($(".chat-room-"+data['chat_room_id']).length > 0){
            $(".chat-room-"+data['chat_room_id']).append($(emojione.unicodeToImage(data['message'])).hide());
            $(".chat-room-"+data['chat_room_id']+" .j-chat_content_data").removeClass("hidden");
            if($(".chat-room-"+data['chat_room_id']).data('current-user-id') == data['owner_id']){
              $(".chat-txt-"+data['chat_id']).removeClass("pull-left left-top bg-white mleft5").addClass("pull-right right-top mright5");
              $(".chat-photo-"+data['chat_id']).removeClass("pull-left").addClass("pull-right");
              $(".chat-usr-name-"+data['chat_id']).removeClass("text-left").addClass("text-right");
            }
            $(".chat-"+data['chat_id']).show();
            if($("#chat_messages").scrollTop() < $("#chat_messages .j-cm-scroll-wrap").height() - ($("#chat_messages").height() * 2)){
              $(".scroll-bt-msg-count").show();
              $(".scroll-bt-msg-count").html(parseInt($(".scroll-bt-msg-count").html()) + 1)
            }else{
              messages_to_bottom();
            }
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
  function send_message(val, room){
    App.chat.save_message(val, room);
  }
  $("#chat_message_content").emojioneArea({
  	container: "#chat_text_div",
  	autocomplete: false,
  	hideSource: true,
  	events: {
  		paste: function(editor, e ){
  		},
  		click: function(editor, e){
  			this.hidePicker();
  		},
  		keydown: function (editor, e) {
  			if (e.keyCode == 13 && !e.shiftKey){
  				e.preventDefault();
  				if ($.trim(this.getText()).length >= 1) {
            this.hidePicker();
  					send_message(this.getText(), editor.closest(".j-c-msg-wrapper").data("chat-room-id"))
  					editor.html("");
            $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").val("");
  				}
  			}
  		},
  	}
  });
  $(document).on("click", ".j-btn-wrap", function(){
    var $wrap = $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").data("emojioneArea");
    if($wrap.getText().length > 0){
      send_message($wrap.getText(), $(this).closest(".j-c-msg-wrapper").data("chat-room-id"));
      $wrap.setText("");
      $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").val("");
    }
  })
  $(document).on("click", ".scroll-bt-msg-count", function(){
    $(this).hide();
    $(this).text("0");
    messages_to_bottom();
  })
})
