require "json"

module Mastodon
  module Streaming
    module Timelines
      def streaming_public_timeline(options = {}, &block)
        Mastodon::Streaming::Request.new(self, :get, "/api/v1/streaming/public", options).perform(&block)
      end

      def streaming_local_timeline(options = {}, &block)
        Mastodon::Streaming::Request.new(self, :get, "/api/v1/streaming/public/local", options).perform(&block)
      end

      def streaming_user_timeline(options = {}, &block)
        Mastodon::Streaming::Request.new(self, :get, "/api/v1/streaming/user", options).perform(&block)
      end

      def streaming_hashtag_timeline(options = {}, &block)
        Mastodon::Streaming::Request.new(self, :get, "/api/v1/streaming/hashtag", options).perform(&block)
      end
    end

    class Request < Mastodon::REST::Request
      def perform(&block)

        options_key = @request_method == :get ? :params : :form
        response    = http_client.headers(@headers).public_send(@request_method, @uri.to_s, options_key => @options)

        if Mastodon::Error::ERRORS.include?(response.code)
          return
        else
          buffer = ""
          event = nil

          loop {
            partial = response.body.readpartial(10 * 1024)

            if !partial
              raise Mastodon::Error::ClientError.new("streaming connection closed")
            end

            buffer += "\n#{partial}"

            while buffer =~ /^([^\n]+)\n(.*)$/
              line = $1
              buffer = $2

              if line.start_with?("event:")
                event = line.split(/:/)[1].strip
              elsif line.start_with?("data") && event
                body = line.gsub(/^data: /, "")

                if event == "update"
                  status = Mastodon::Status.new(JSON.parse(body).to_h)
                  block.(event, status)
                else
                  block.(event, body)
                end

                event = nil
              end

            end
          }
        end
      end

      def http_client
        HTTP
      end
    end
  end

  module REST
    class Client
      include Mastodon::Streaming::Timelines
    end
  end
end
