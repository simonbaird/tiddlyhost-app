
class ThFile < TwFile

  DEFAULT = 'tw5'

  def self.empty_dir
    File.expand_path("#{__dir__}/../tw_content/empties")
  end

  def self.empty_path(empty_type=DEFAULT)
    "#{empty_dir}/#{empty_type}.html"
  end

  def self.empty_html(empty_type=DEFAULT)
    File.read(empty_path(empty_type))
  end

  def self.plugins_dir
    File.expand_path("#{__dir__}/../tw_content/plugins")
  end

  def self.plugin_path(plugin_name)
    "#{plugins_dir}/#{plugin_name}.js.erb"
  end

  def self.plugin_template(plugin_name)
    ERB.new(File.read(plugin_path(plugin_name)))
  end

  def self.available_empties
    Dir.glob("#{empty_dir}/*.html").map{ |f| File.basename(f, '.html') }
  end

  def self.empty_versions
    Hash[ available_empties.map{ |e| [e, ThFile.from_empty(e).tiddlywiki_version] } ]
  end

  def self.from_empty(empty_type=DEFAULT)
    from_file(empty_path(empty_type))
  end

  def apply_tiddlyhost_mods(site_name)
    if is_tw5?
      write_tiddlers({
        # TiddlyWiki will POST to this url using code in core/modules/savers/upload.js
        '$:/UploadURL' => Settings.subdomain_site_url(site_name),

        # Set this otherwise TiddlyWiki won't consider upload.js usable unless there
        # is a username and password present.
        '$:/UploadWithUrlOnly' => 'yes',

        # Autosave is nice, but I'm thinking we should start with it off to generate
        # a little less traffic.
        '$:/config/AutoSave' => 'no',
      })

    else # classic
      # We don't want to hard code the site url in the plugin, but we also don't
      # want to hard code the domain name and port etc since they're different
      # in different environments. This is clever way to deal with that.
      site_url = Settings.subdomain_site_url("' + siteName + '")

      write_tiddlers({
        'ThostUploadPlugin' => {
          content: plugin_content(:thost_upload_plugin, site_name: site_name, site_url: site_url),
          tags: 'systemConfig',
          modifier: 'TiddlyHost',
        }
      })

      # This could be a regular tiddler, but let's make it a shadow tiddler just to be cool.
      # Will be clickable when viewing the plugin since we used 'TiddlyHost' as the modifier above.
      # (I'm using camel case intentionally here despite the usual spelling of Tiddlyhost.)
      write_shadow_tiddlers({
        'TiddlyHost' => {
          content: "[[Tiddlyhost|#{Settings.main_site_url}]] is a hosting service for ~TiddlyWiki.",
          modifier: 'TiddlyHost',
        }
      })

    end
  end

  def plugin_content(plugin_name, erb_vars)
    ThFile.plugin_template(plugin_name).result_with_hash(erb_vars)
  end

  def get_site_name
    # (It would be nice if there was a better way to do this.)
    if is_tw5?
      tiddler_content('$:/UploadURL').
        match(%r{//([a-z-]+)\.}).try(:[], 1)
    else
      tiddler_content('ThostUploadPlugin').
        match(%r{bidix\.initOption\('txtThostSiteName','(\w+)'\);}).try(:[], 1)
    end
  end

end
