class VideoService
    def initialize
        @firebasekey = FIREBASE_CONFIG[:server_key]
    end

    def youtube_iframe(video_key)
        video_iframe = <<-EOS
        <iframe id="ytplayer" type="text/html" width="640" height="390" src="https://www.youtube.com/embed/#{video_key}?origin=https://cocociti.com" frameborder="0">
        </iframe>
        EOS
    end

    def is_youtube_video_link(url)
        url.include?("youtube") || url.include?("youtu.be")
    end

    def video_key_from_url(url)
        if is_youtube_video_link(url)
            if (url.split("v=")[1])
                (url.split("v=")[1]).split(" ")[0]
            else
                (url.split("/").last)
            end
        else
        end
    end

    def get_youtube_iframe(url)
        if is_youtube_video_link(url)
            return youtube_iframe(video_key_from_url(url))
        else
            url
        end
    end
end
