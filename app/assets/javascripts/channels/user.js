$(document).ready(function(){
	$(document).on("click", ".j-show_new_wishes", function(){
		$new_wish_counter_el = $('.j-new_wishes_count');
		$hidden_wishesh_elements = $('.showcase-strip .showcase-ps-wrapper.hidden');
		$(this).addClass('hidden');
		$new_wish_counter_el.attr('data-new-wishes-count', 0);
		$new_wish_counter_el.html("(0)");
		$("html, body").animate({scrollTop: $(".showcase-strip").offset().top - 100})
		$hidden_wishesh_elements.hide().removeClass('hidden').slideDown(500);
	});
	if($("body").data("logged-in-id") != ""){
		App.user = App.cable.subscriptions.create({channel: "UserChannel"},
		{
			received: function(data) {
				if(data['notification_count'] || data['notification_count'] === 0){
					$(".j-notification-count").html(data['notification_count']);
					if( data['notification_count'] > 0){$(".j-notification-count").removeClass('hidden');}
					else{$(".j-notification-count").addClass('hidden'); }
					if (data['live_notifications']){
						$(".j-live-notifications").append(data['live_notifications']);
						$(".j-notif-single").fadeIn("slow");
						setTimeout(function(){$(".live-notification-"+data['live_class']+"-"+data['live_id']).remove()}, 30000)
					}
				}
				if(data['live_notification_count'] || data['live_notification_count'] === 0){
					if(data['live_notification_count'] > 0){
						$(".j-notification-count").html(data['live_notification_count']);
						$(".j-notification-count").removeClass('hidden');
					}else{
						$(".j-notification-count").html(data['live_notification_count']);
						$(".j-notification-count").addClass('hidden');
					}
				}

				if(data['chat_message_count'] || data['chat_message_count'] === 0 ){
					if($(".chat-room-"+data['chat_room_id']).length === 0 && data['chat_room_id']){
						$(".j-chat-message-count").html(data['chat_message_count']);
						if(data['chat_message_count'] > 0){$(".j-chat-message-count").removeClass('hidden');}
						else{$(".j-chat-message-count").addClass('hidden');}
					}
					if(data['current_room_id']){
						$(".j-chat-message-count").html(data['chat_message_count']);
						if(data['chat_message_count'] > 0){$(".j-chat-message-count").removeClass('hidden');}
						else{$(".j-chat-message-count").addClass('hidden');}
						var count = $(".chat-conv-card-"+data['current_room_id']).find(".j-chat-count");
						count.hide();
		        count.text("0");
					}
				}

				if(data['showcase_content']){
					$('.showcase-strip').prepend(data['showcase_content']);
					$('.j-show_new_wishes').removeClass('hidden');
					$new_wish_counter_el = $('.j-new_wishes_count');
					new_count = parseInt($new_wish_counter_el.attr('data-new-wishes-count')) + 1;
					$new_wish_counter_el.attr('data-new-wishes-count', new_count);
					$new_wish_counter_el.html("("+new_count+")");
				}
			}
		});
	}
});
