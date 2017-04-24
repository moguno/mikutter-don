require "json"

module Mastodon
  module REST
    class Request
      alias :perform_org :perform

      def perform(&block)
        if block
          options_key = @request_method == :get ? :params : :form
          response    = http_client.headers(@headers).public_send(@request_method, @uri.to_s, options_key => @options)

          if Mastodon::Error::ERRORS.include?(response.code)
            return
          else
            buffer = ""
            event = nil

            loop {
              partial = response.body.readpartial(1024 * 1024)

              if !partial
                return
              end

              buffer += "\n#{partial}"

              while buffer =~ /^([^\n]+)\n(.*)$/
                line = $1
                buffer = $2

                if line =~ /^event:/
                  event = line.split(/:/)[1].strip
                elsif line =~ /^data:/ && event

                  if event == "update"
                    body = line.gsub(/^data: /, "")
                    status = Mastodon::Status.new(JSON.parse(body).to_h)
#                    block.([event, status])
                  end

                  event = nil
                end

              end
            }
          end
        else
          perform_org
        end
      end
    end
  end
end
