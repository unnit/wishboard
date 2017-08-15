class VideoService
  def initialize
    @firebasekey = FIREBASE_CONFIG[:server_key]
  end

  def vimeo_iframe(video_key)
    video_iframe =<<-EOS
    <iframe src="https://player.vimeo.com/video/#{video_key}" class="embed-responsive-item" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
    EOS
  end

  def facebook_iframe(facebook_url)
    video_iframe = <<-EOS
    <iframe src="https://www.facebook.com/plugins/video.php?href=#{facebook_url}&show_text=0&width=560" class="embed-responsive-item" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true" allowFullScreen="true"></iframe>
    EOS
  end

  def youtube_iframe(video_key)
    video_iframe = <<-EOS
    <iframe id="ytplayer" type="text/html"  class="embed-responsive-item" src="https://www.youtube.com/embed/#{video_key}?origin=https://cocociti.com" frameborder="0">
    </iframe>
    EOS
  end

  def is_youtube_video_link(url)
    url.include?("youtube") || url.include?("youtu.be")
  end

  def is_facebook_video_link(url)
    url.include?("facebook.com") || url.include?("facebook.com")
  end

  def is_vimeo_video_Link(url)
    url.include?("vimeo.com") || url.include?("vimeo.com")
  end

  def video_key_from_url(url)
    if is_youtube_video_link(url)
      if (url.split("v=")[1])
        (url.split("v=")[1]).split(" ")[0]
      else
        ((url.split("/").last).strip).gsub('/', '')
      end
    elsif is_vimeo_video_Link(url)
      ((url.split("/").last).strip).gsub('/', '')
    else
      ""
    end
  end

  def get_video_iframe(url)
    if is_youtube_video_link(url)
      return youtube_iframe(video_key_from_url(url))
    elsif is_facebook_video_link(url)
      return facebook_iframe(url)
    elsif is_vimeo_video_Link(url)
      vimeo_iframe(video_key_from_url(url))
    else
      "<a target='_blank' href=#{url}>#{url}</a>"
    end
  end
end
