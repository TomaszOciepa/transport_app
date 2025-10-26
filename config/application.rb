require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TransportApp
  class Application < Rails::Application

    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])
    
    config.i18n.default_locale = :pl

    config.time_zone = "Europe/Warsaw"
    config.active_record.default_timezone = :utc

  end
end
