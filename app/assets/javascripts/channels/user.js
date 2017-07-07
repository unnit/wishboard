$(document).ready(function(){
	$(document).on("click", ".show_new_wishes", function(){
		$new_wish_counter_el = $('.j-new_wishes_count');
		$hidden_wishesh_elements = $('.showcase-strip .showcase-ps-wrapper.hidden');
		$('.j-show_new_wishes').addClass('hidden');
		$new_wish_counter_el.attr('data-new-wishes-count', 0);
		$new_wish_counter_el.html("(0)");
		$hidden_wishesh_elements.hide().removeClass('hidden').slideDown(500);
	});
	App.user = App.cable.subscriptions.create({channel: "UserChannel"},
	{
		received: function(data) {
			if(data['notification_count'] || data['notification_count'] === 0){
				$(".j-notification-count").html(data['notification_count']);
				if( data['notification_count'] > 0){$(".j-notification-count").removeClass('hidden');}
				else{$(".j-notification-count").addClass('hidden'); }
				if (data['notifications_content']){
					$(".notif-content").empty().append(data['notifications_content']);
					$(".notif-inner-strip").mCustomScrollbar({theme:"minimal-dark",advanced:{ updateOnContentResize: true }});
				}
			}

			if(data['chat_message_count'] || data['chat_message_count'] === 0 ){
				$(".j-chat-message-count").html(data['chat_message_count']);
				if(data['chat_message_count'] > 0){$(".j-chat-message-count").removeClass('hidden'); }
				else{$(".j-chat-message-count").addClass('hidden'); }
			}

			if(data['showcase_content']){
				$('.showcase-strip').prepend(data['showcase_content']);
				$('.j-show_new_wishes').removeClass('hidden');
				$new_wish_counter_el = $('.j-new_wishes_count');
				new_count = parseInt($new_wish_counter_el.attr('data-new-wishes-count')) + 1;
				$new_wish_counter_el.attr('data-new-wishes-count', new_count);
				$new_wish_counter_el.html("("+new_count+ ")");
			}
		}
	});
});