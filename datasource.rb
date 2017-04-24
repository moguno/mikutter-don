Plugin.create(:"mikutter-datasource-exchange") {
  # データソース
  filter_extract_datasources { |datasources|
    @currencies.each { |currency|
      datasources[:"mikutter_don"] = _("Mastodon")
    }

    [datasources]
  }
}
