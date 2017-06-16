//= require emojione
//= require emojionearea
function customUnicodeToHtml(element_selector){
  counter = 0
  $(element_selector+":not([data-emojioneadded])").each(function() {

       $(this).attr("emojioneadded","");
       $(this).html(emojione.unicodeToImage($(this).html()));
       $(this).removeClass("hidden");
       counter += 1;
  });
  console.log("elemnets_replaced:"+counter);
  }



$(document).ready(function(){
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
						send_message(this.getText(), editor.closest(".j-c-msg-wrapper").data("chat-room-id"))
						editor.html("");
					}
				}else if (e.keyCode == 13) {
					// e.preventDefault();
				}
			},
		}
	});

	
});
