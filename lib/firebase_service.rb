class FirebaseService
    require 'fcm'
    def initialize
        @firebasekey = FIREBASE_CONFIG[:server_key]
    end
    #registration_ids= ["sggsggdgd..", ... ,"..dkkdjdjjd"] An array of one or more client registration tokens
    def send_notification(notification_title, notification_body, notification_url, notification_image, registration_ids )
        fcm = FCM.new(@firebasekey)
        options = {data: {title: notification_title, body: notification_body, url: notification_url, image: notification_image }, collapse_key: "new_notification"}
        response = fcm.send(registration_ids, options)
    end
end
