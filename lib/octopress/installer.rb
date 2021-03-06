module Octopress
  class Installer

    OCTO_DIRS = {
      "configs"  => "config/defaults",
      "javascripts/lib"     => "javascripts/lib",
      "javascripts/modules" => "javascripts/modules",
      "source"      => "source",
      "includes" => "source/_includes",
      "layouts"  => "source/_layouts",
      "stylesheets" => "stylesheets",
      "plugins"     => "plugins"
    }

    def initialize(plugin_name)
      begin
        require "#{plugin_name}"
      rescue LoadError
        Octopress.logger.error "We can't load the plugin '#{plugin_name}'. Please add it" +
                               " to your Gemfile and run 'bundle install' and try" +
                               " installing the plugin again."
        raise LoadError
      end

      @plugin_name  = plugin_name
      @class_name   = plugin_name.gsub(/-_\ /, "_").split("_").map(&:capitalize).join("")
      @plugin_class = Object.const_get(@class_name)
      @verbose      = Octopress.logger.level == Logger::DEBUG
    end

    def type
      manifest_yml.fetch('type', 'plugin')
    end

    def theme?
      type == "theme"
    end

    def plugin?
      type == "plugin"
    end

    def plugin_slug
      plugin? ? manifest_yml.fetch('slug') : "theme"
    end

    ####################
    # Fetchers
    ####################

    def namespace?(subdir)
      !%w[javascripts/lib source].include?(subdir)
    end

    def stylesheets?(subdir)
      "stylesheets" == subdir
    end

    def source(*subdirs)
      File.join(@plugin_class.root, *subdirs, ".")
    end

    def local(subdir)
      dir = File.join(Octopress.root, subdir)
      dir = File.join(dir, "plugins") if stylesheets?(subdir) && plugin?
      dir = File.join(dir, "theme") if stylesheets?(subdir) && theme?
      dir = File.join(dir, plugin_slug) if namespace?(subdir)
      dir
    end

    ###################
    # Installers
    ###################

    def install
      OCTO_DIRS.each do |source_dir, local_dir|
        _install(source_dir, local_dir)
      end
    end

    def _install(source_dir, local_dir)
      FileUtils.mkdir_p local(local_dir), verbose: @verbose
      FileUtils.cp_r source(source_dir), local(local_dir), verbose: @verbose
    end

    private
    def manifest_yml
      @manifest ||= YAML.safe_load_file(File.join(@plugin_class.root, "MANIFEST.yml"))
    rescue Errno::ENOENT
      Octopress.logger.error "The plugin '#{@plugin_name}' doesn't seem to have a " +
        "MANIFEST.yml file and thus isn't a valid Octopress plugin."
      raise LoadError
    end

  end
end
