$(document).ready(function(){
  if($(".chat-ids-holder").length > 0){
    var values = String($(".chat-ids-holder").data("chat-room-ids")).split(",");
  }
  else{
    var values = []
  }
  var logged_id = $("body").data("logged-in-id");
  if(values.length > 0 && logged_id != ""){
    for(i=0; i<values.length; i++){
      App.chat = App.cable.subscriptions.create({channel: "ChatChannel", chat_room_id: values[i]},
        {
          received: function(data) {
            if($(".chat-room-"+data['chat_room_id']).length > 0){
              $(".chat-room-"+data['chat_room_id']).append($(emojione.unicodeToImage(data['message'])).hide());
              showLinkPreviews(".url_preview");
              $(".chat-room-"+data['chat_room_id']+" .j-chat_content_data").removeClass("hidden");
              if($(".chat-room-"+data['chat_room_id']).data('current-user-id') == data['owner_id']){
                $(".chat-txt-"+data['chat_id']).removeClass("pull-left left-top bg-white mleft5").addClass("pull-right right-top mright5");
                $(".chat-photo-"+data['chat_id']).removeClass("pull-left").addClass("pull-right");
                $(".chat-usr-name-"+data['chat_id']).removeClass("text-left").addClass("text-right");
              }
              $(".chat-"+data['chat_id']).show();
              LocalTime.run();
              if($("#chat_messages").scrollTop() < $("#chat_messages .j-cm-scroll-wrap").height() - ($("#chat_messages").height() * 2)){
                $(".scroll-bt-msg-count").show();
                $(".scroll-bt-msg-count").html(parseInt($(".scroll-bt-msg-count").html()) + 1)
              }else{
                messages_to_bottom();
              }
              return this.update_last_seen(data['chat_room_id']);
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
          },
          update_last_seen: function(chat_room_id){
            return this.perform('update_last_seen', {chat_room_id: chat_room_id})
          }
      });
    }
  }
  function send_message(val, room){
    App.chat.save_message(val, room);
  }
  emojione.greedyMatch = true;
  emojione.riskyMatchAscii = false;
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
          if(logged_id != ""){
            if ($.trim(this.getText()).length >= 1) {
              this.hidePicker();
    					send_message(this.getText(), editor.closest(".j-c-msg-wrapper").data("chat-room-id"))
    					editor.html("");
              $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").val("");
    				}
          }
          else{
            $("#cont-wrapper").html("<div class='col-xs-12 col-sm-6 col-sm-offset-3 mtop100 violet-bg white-fg padding20 border5 font16'><h4 class='full-width mbottom20 text-center'>Sign in/up to be part of chatrooms</h4><div class='col-xs-6 col-sm-6 no-mar-pad text-right'><a class='btn white-fg border2' style='padding: 7px 15px;border: 1px solid #fff;' href='/authenticate?tab=signup'>SignUp</a></div><div class='col-xs-6 col-sm-6'><a class='btn cc-dark-fg bg-white border2' style='padding: 7px 15px;' href='/authenticate'>Login</a></div></div>");
            prependModalClose("#cont-wrapper");
            $("#cont-wrapper").modal("show");
          }
  			}
  		},
  	}
  });
  $(document).on("click", ".j-btn-wrap", function(){
    if(logged_id != ""){
      var $wrap = $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").data("emojioneArea");
      if($wrap.getText().length > 0){
        send_message($wrap.getText(), $(this).closest(".j-c-msg-wrapper").data("chat-room-id"));
        $wrap.setText("");
        $(this).closest(".j-c-msg-wrapper").find("#chat_message_content").val("");
      }
    }
    else {
      $("#cont-wrapper").html("<div class='col-xs-12 col-sm-6 col-sm-offset-3 mtop100 violet-bg white-fg padding20 border5 font16'><h4 class='full-width mbottom20 text-center'>Sign in/up to be part of chatrooms</h4><div class='col-xs-6 col-sm-6 no-mar-pad text-right'><a class='btn white-fg border2' style='padding: 7px 15px;border: 1px solid #fff;' href='/authenticate?tab=signup'>SignUp</a></div><div class='col-xs-6 col-sm-6'><a class='btn cc-dark-fg bg-white border2' style='padding: 7px 15px;' href='/authenticate'>Login</a></div></div>");
      prependModalClose("#cont-wrapper");
      $("#cont-wrapper").modal("show");
    }
  })
  $(document).on("click", ".scroll-bt-msg-count", function(){
    $(this).hide();
    $(this).text("0");
    messages_to_bottom();
  })
})
