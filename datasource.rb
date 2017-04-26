Plugin.create(:"mikutter丼") {
  # データソース
  filter_extract_datasources { |datasources|
    @timelines.each { |method, name|
      datasources[:"mikutter丼/#{name}"] = _("Mastodon/#{name}")
    }

    [datasources]
  }
}
