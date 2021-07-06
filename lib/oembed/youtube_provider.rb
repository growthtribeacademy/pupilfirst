module Oembed
  class YoutubeProvider < BaseProvider
    def self.domains
      [
        /youtube\.com/,
        /youtu\.be/
      ]
    end

    def url
      "https://www.youtube.com/oembed?format=json&url="
    end

    def embed_code
      provide_youtube_player_required_configuration(super)
    end

    def provide_youtube_player_required_configuration(code)
      return unless code
      tag_id = "youtube-video-#{SecureRandom.urlsafe_base64}"
      code.sub!("iframe", "iframe id=\"#{tag_id}\"")
      code.sub!("feature=oembed", "enablejsapi=1")
    end
  end
end
