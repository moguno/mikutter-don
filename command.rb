Plugin.create(:"mikutter丼") {
  # 極限まで手を抜いた投稿コマンド
  command(:don_post,
          :name => _("Mastodonに投稿"),
          :condition => lambda { |opt| true },
          :visible => true,
          :role => :postbox) { |opt|
     postbox = Plugin[:gtk].widgetof(opt.widget)
     text = postbox.widget_post.buffer.text

     @client.create_status(text)
     postbox.widget_post.buffer.text = ""
  }
 
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
