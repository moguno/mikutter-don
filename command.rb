Plugin.create(:"mikutter丼") {
  # ふぁぼ
  command(:don_fav,
          :name => _("ふぁぼる"),
          :condition => lambda { |opt|
            opt.messages.any? { |message|
              message.is_a?(DonMessage)
            }
          },
          :visible => true,
          :role => :timeline) { |opt|

    opt.messages.select { |_| _.is_a?(DonMessage) }.each { |message|
      Thread.new {
        @client.favourite(message[:id])
      }
    }
  }

  # ブースト
  command(:don_boost,
          :name => _("ブースト"),
          :condition => lambda { |opt|
            opt.messages.any? { |message|
              message.is_a?(DonMessage)
            }
          },
          :visible => true,
          :role => :timeline) { |opt|

    opt.messages.select { |_| _.is_a?(DonMessage) }.each { |message|
      Thread.new {
        @client.reblog(message[:id])
      }
    }
  }
}
