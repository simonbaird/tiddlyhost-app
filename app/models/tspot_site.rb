
class TspotSite < ApplicationRecord
  include SiteCommon

  # Some duck typing for hub rendering
  alias_attribute :view_count, :access_count

  # The TspotFetcher class knows how to fetch a site from the
  # dreamhost bucket. It can also determine if the site is public
  # or private, and can fetch the htpasswd file for auth checks.
  #
  def fetcher
    @_fetcher ||= TspotFetcher.new(name)
  end

  def fetcher=(fetcher)
    @_fetcher = fetcher
  end

  def html_content
    if tiddlywiki_file.blob
      # This will exist only if the site was ever updated
      # post-tiddlyhost. Use it if we have it.
      # (This is defined in site_common.rb)
      file_download
    else
      # The original pre-tiddlyhost content is availble here.
      # Treat this as read-only.
      fetched_html
    end
  end

  def fetched_html
    site_cache(:fetched_html) do
      logger.info "  TspotSite fetch for #{name}"
      fetcher.html_file
    end
  end

  def self.find_or_create(site_name, ip_address=nil)
    # If we have a record for it already then return it,
    # otherwise create a new one
    find_by_name(site_name) || create_new(site_name, ip_address)
  end

  def self.create_new(site_name, ip_address=nil)
    fetched_site = TspotFetcher.new(site_name)
    if fetched_site.exists?
      new_site = TspotSite.create({
        name: site_name,
        exists: true,
        is_private: fetched_site.is_private?,
        htpasswd: fetched_site.htpasswd_file,
        created_ip: ip_address.to_s,
      })
      # Could consider creating the tiddlywiki_file
      # attachment here, but for now let's leave the
      # content where it is until the site is updated.

    else
      # Site doesn't exist but create a record for it anyway. The idea
      # is to avoid trying again and avain to fetch a site that will
      # never exist. (Might cause problems if we get a million of them.)
      new_site = TspotSite.create({
        name: site_name,
        exists: false,
        created_ip: ip_address.to_s,
      })

    end

    # Avoid recreating the fetcher the first time around (I guess)
    new_site.fetcher = fetched_site

    new_site
  end

  def passwd_ok?(user, pass)
    TspotFetcher.passwd_match?(user, pass, htpasswd)
  end

  def url
    Settings.tiddlyspot_site_url(name)
  end

  def favicon_asset_name
    'favicon-tiddlyspot.ico'
  end

end
