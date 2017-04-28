namespace :coco_jobs do
  desc "TODO"
  task transaction_reset: :environment do
    @transactions = Transaction.where("status = ?", Transaction::TRANSACTION_STATUS[1][1])
    puts @transactions.count unless @transactions.blank?
    @transactions.each do |transaction|
      if Time.now.in_time_zone("Kolkata") > (transaction.created_at + GLOBAL_VARIABLES[:time_out].minutes)
        transaction.status = Transaction::TRANSACTION_STATUS[4][1]
        transaction.save
      end
    end
  end

  task send_email_notifications: :environment do
    achieved_notifications = AchievedNotification.where("active = ? and mailed = ?", true, false)
    achieved_notifications.each do |achieved_notification|
      if achieved_notification.user.subscribed?
        ShowcaseMailer.achieved_showcase(achieved_notification.user.email, achieved_notification.showcase).deliver_now
      end
      achieved_notification.mailed = true
      achieved_notification.save
    end
    showcase_notifications = ShowcaseNotification.where("mailed = ?", false)
    showcase_notifications.each do |showcase_notification|
      if showcase_notification.user.subscribed?
        ShowcaseMailer.new_showcase(showcase_notification.user.email, showcase_notification.showcase).deliver_now
      end
      showcase_notification.mailed = true
      showcase_notification.save
    end
    wows = Wow.where("mailed = ?", false)
    wows.each do |wow|
      if wow.showcase.user.subscribed?
        ShowcaseMailer.send_wow_notification(wow.showcase.user.email, wow.user, wow.showcase).deliver_now unless wow.showcase.user == wow.user
      end
      wow.mailed = true
      wow.save
    end
    coins = Coin.where("mailed = ?", false)
    coins.each do |coin|
      if coin.showcase.user.subscribed?
        ShowcaseMailer.send_coin_notification(coin.showcase.user.email, coin.user, coin.showcase).deliver_now unless coin.showcase.user == coin.user
      end
      coin.mailed = true
      coin.save
    end
    comments = Comment.where("mailed = ?", false)
    comments.each do |comment|
      if comment.showcase.user.subscribed?
        ShowcaseMailer.send_showcase_owner_notification_for_comment(comment.showcase.user.email, comment.user, comment.showcase).deliver_now unless comment.user == comment.showcase.user
      end
      comment.mailed = true
      comment.save
    end
    commenter_notifications = CommenterNotification.where("mailed = ?", false)
    commenter_notifications.each do |commenter_notification|
      if commenter_notification.user.subscribed?
        ShowcaseMailer.send_showcase_member_notification_for_comment(commenter_notification.user.email, commenter_notification.comment.user, commenter_notification.showcase).deliver_now
      end
      commenter_notification.mailed = true
      commenter_notification.save
    end
    relationships = Relationship.where("mailed = ?", false)
    relationships.each do |relationship|
      if relationship.followed.subscribed?
        UserMailer.send_follow_notification(relationship.follower, relationship.followed.email).deliver_now
      end
      relationship.mailed = true
      relationship.save
    end
  end

end
