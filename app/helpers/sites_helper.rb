
module SitesHelper

  def site_link(site, opts={})
    link_title = opts.delete(:link_title)
    link_to site.url, {target: '_blank'}.merge(opts) do
      link_title || site.name
    end
  end

  def site_long_link(site, opts={})
    link_to site.url, {target: '_blank'}.merge(opts) do
      (yield if block_given?).to_s + site.long_name
    end
  end

  def site_pretty_link(site)
    site_long_link(site) do
      image_tag(asset_path(site.favicon_asset_name))
    end
  end

  def site_download_link(site, opts={})
    link_to site.download_url, opts do
      yield
    end
  end

  def site_access(site)
    [
      site.is_public? && site.is_searchable? ? 'Hub listed' : nil,
      site.is_public? ? 'Public' : 'Private',

    ].compact.join(', ')
  end

  def hub_all_url
    add_sort_param_maybe("/hub")
  end

  def hub_tag_url(tag_name)
    add_sort_param_maybe("/hub/tag/#{ERB::Util.url_encode(tag_name)}")
  end

  def hub_user_url(username)
    add_sort_param_maybe("/hub/user/#{ERB::Util.url_encode(username)}")
  end

  def add_sort_param_maybe(url)
    url += "?#{{ s: params[:s] }.to_query}" if controller_name == 'hub' && params[:s]
    url
  end

  def clickable_site_tags(site)
    safe_join(site.tag_list.map do |tag_name|
      link_to tag_name, hub_tag_url(tag_name)
    end, ' ')
  end

end
