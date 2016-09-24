RSpec.describe 'hanami new', type: :cli do
  it 'generates vanilla project' do
    project = 'bookshelf'
    output  = <<-OUT
      create  .hanamirc
      create  .env.development
      create  .env.test
      create  Gemfile
      create  config.ru
      create  config/environment.rb
      create  lib/#{project}.rb
      create  public/.gitkeep
      create  config/initializers/.gitkeep
      create  lib/#{project}/entities/.gitkeep
      create  lib/#{project}/repositories/.gitkeep
      create  lib/#{project}/mailers/.gitkeep
      create  lib/#{project}/mailers/templates/.gitkeep
      create  spec/#{project}/entities/.gitkeep
      create  spec/#{project}/repositories/.gitkeep
      create  spec/#{project}/mailers/.gitkeep
      create  spec/support/.gitkeep
      create  db/.gitkeep
      create  Rakefile
      create  spec/spec_helper.rb
      create  spec/features_helper.rb
      create  .gitignore
         run  git init . from "."
      create  apps/web/application.rb
      create  apps/web/config/routes.rb
      create  apps/web/views/application_layout.rb
      create  apps/web/templates/application.html.erb
      create  apps/web/assets/favicon.ico
      create  apps/web/controllers/.gitkeep
      create  apps/web/assets/images/.gitkeep
      create  apps/web/assets/javascripts/.gitkeep
      create  apps/web/assets/stylesheets/.gitkeep
      create  spec/web/features/.gitkeep
      create  spec/web/controllers/.gitkeep
      create  spec/web/views/.gitkeep
      insert  config/environment.rb
      insert  config/environment.rb
      append  .env.development
      append  .env.test
OUT

    run_command "hanami new #{project}", output

    within_project_directory(project) do
      # Assert it's an initialized Git repository
      run_command "git status", "On branch master"

      #
      # .hanamirc
      #
      expect('.hanamirc').to have_file_content <<-END
project=#{project}
architecture=container
test=minitest
template=erb
END

      #
      # .env.development
      #
      expect('.env.development').to have_file_content(%r{# Define ENV variables for development environment})
      expect('.env.development').to have_file_content(%r{DATABASE_URL="file:///db/#{project}_development"})
      expect('.env.development').to have_file_content(%r{SERVE_STATIC_ASSETS="true"})
      expect('.env.development').to have_file_content(%r{WEB_SESSIONS_SECRET="[\w]{64}"})

      #
      # .env.test
      #
      expect('.env.test').to have_file_content(%r{# Define ENV variables for test environment})
      expect('.env.test').to have_file_content(%r{DATABASE_URL="file:///db/#{project}_test"})
      expect('.env.test').to have_file_content(%r{SERVE_STATIC_ASSETS="true"})
      expect('.env.test').to have_file_content(%r{WEB_SESSIONS_SECRET="[\w]{64}"})

      #
      # Gemfile
      #
      expect('Gemfile').to have_file_content <<-END
source 'https://rubygems.org'

gem 'bundler'
gem 'rake'
gem 'hanami',       '~> 1.0'
gem 'hanami-model', '~> 0.6'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/applications/code-reloading
  gem 'shotgun'
end

group :test, :development do
  gem 'dotenv', '~> 2.0'
end

group :test do
  gem 'minitest'
  gem 'capybara'
end

group :production do
  # gem 'puma'
end
END

      #
      # config.ru
      #
      expect('config.ru').to have_file_content <<-END
require './config/environment'

run Hanami::Container.new
END

      #
      # config/environment.rb
      #
      expect('config/environment.rb').to have_file_content <<-END
require 'bundler/setup'
require 'hanami/setup'
require_relative '../lib/#{project}'
require_relative '../apps/web/application'

Hanami::Container.configure do
  mount Web::Application, at: '/'
end
END

      #
      # lib/<project>.rb
      #
      expect("lib/#{project}.rb").to have_file_content <<-END
require 'hanami/model'
require 'hanami/mailer'
Dir["\#{ __dir__ }/#{project}/**/*.rb"].each { |file| require_relative file }

Hanami::Model.configure do
  ##
  # Database adapter
  #
  # Available options:
  #
  #  * File System adapter
  #    adapter type: :file_system, uri: 'file:///db/#{project}_development'
  #
  #  * Memory adapter
  #    adapter type: :memory, uri: 'memory://localhost/#{project}_development'
  #
  #  * SQL adapter
  #    adapter type: :sql, uri: 'sqlite://db/#{project}_development.sqlite3'
  #    adapter type: :sql, uri: 'postgres://localhost/#{project}_development'
  #    adapter type: :sql, uri: 'mysql://localhost/#{project}_development'
  #
  adapter type: :file_system, uri: ENV['DATABASE_URL']

  ##
  # Database mapping
  #
  # Intended for specifying application wide mappings.
  #
  mapping do
    # collection :users do
    #   entity     User
    #   repository UserRepository
    #
    #   attribute :id,   Integer
    #   attribute :name, String
    # end
  end
end.load!

Hanami::Mailer.configure do
  root "\#{ __dir__ }/#{project}/mailers"

  # See http://hanamirb.org/guides/mailers/delivery
  delivery do
    development :test
    test        :test
    # production :smtp, address: ENV['SMTP_PORT'], port: 1025
  end
end.load!
END

      #
      # public/.gitkeep
      #
      expect('public/.gitkeep').to be_an_existing_file

      #
      # config/initializers/.gitkeep
      #
      expect('config/initializers/.gitkeep').to be_an_existing_file

      #
      # lib/<project>/entities/.gitkeep
      #
      expect("lib/#{project}/entities/.gitkeep").to be_an_existing_file

      #
      # lib/<project>/mailers/.gitkeep
      #
      expect("lib/#{project}/mailers/.gitkeep").to be_an_existing_file

      #
      # lib/<project>/mailers/templates/.gitkeep
      #
      expect("lib/#{project}/mailers/templates/.gitkeep").to be_an_existing_file

      #
      # spec/<project>/entities/.gitkeep
      #
      expect("spec/#{project}/entities/.gitkeep").to be_an_existing_file

      #
      # spec/<project>/repositories/.gitkeep
      #
      expect("spec/#{project}/repositories/.gitkeep").to be_an_existing_file

      #
      # spec/<project>/mailers/.gitkeep
      #
      expect("spec/#{project}/mailers/.gitkeep").to be_an_existing_file

      #
      # spec/support/.gitkeep
      #
      expect("spec/support/.gitkeep").to be_an_existing_file

      #
      # db/.gitkeep
      #
      expect("db/.gitkeep").to be_an_existing_file

      #
      # Rakefile
      #
      expect('Rakefile').to have_file_content <<-END
require 'rake'
require 'hanami/rake_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs    << 'spec'
  t.warning = false
end

task default: :test
task spec: :test
END

      #
      # spec/spec_helper.rb
      #
      expect("spec/spec_helper.rb").to have_file_content <<-END
# Require this file for unit tests
ENV['HANAMI_ENV'] ||= 'test'

require_relative '../config/environment'
require 'minitest/autorun'

Hanami::Application.preload!
END

      #
      # spec/features_helper.rb
      #
      expect("spec/features_helper.rb").to have_file_content <<-END
# Require this file for feature tests
require_relative './spec_helper'

require 'capybara'
require 'capybara/dsl'

Capybara.app = Hanami::Container.new

class MiniTest::Spec
  include Capybara::DSL
end
END

      #
      # .gitignore
      #
      expect(".gitignore").to have_file_content <<-END
/db/#{project}_development
/db/#{project}_test
/public/assets*
/tmp
END

      #
      # apps/web/application.rb
      #
      expect("apps/web/application.rb").to have_file_content <<-END
require 'hanami/helpers'
require 'hanami/assets'

module Web
  class Application < Hanami::Application
    configure do
      ##
      # BASIC
      #

      # Define the root path of this application.
      # All paths specified in this configuration are relative to path below.
      #
      root __dir__

      # Relative load paths where this application will recursively load the code.
      # When you add new directories, remember to add them here.
      #
      load_paths << [
        'controllers',
        'views'
      ]

      # Handle exceptions with HTTP statuses (true) or don't catch them (false).
      # Defaults to true.
      # See: http://www.rubydoc.info/gems/hanami-controller/#Exceptions_management
      #
      # handle_exceptions true

      ##
      # HTTP
      #

      # Routes definitions for this application
      # See: http://www.rubydoc.info/gems/hanami-router#Usage
      #
      routes 'config/routes'

      # URI scheme used by the routing system to generate absolute URLs
      # Defaults to "http"
      #
      # scheme 'https'

      # URI host used by the routing system to generate absolute URLs
      # Defaults to "localhost"
      #
      # host 'example.org'

      # URI port used by the routing system to generate absolute URLs
      # Argument: An object coercible to integer, default to 80 if the scheme is http and 443 if it's https
      # This SHOULD be configured only in case the application listens to that non standard ports
      #
      # port 443

      # Enable cookies
      # Argument: boolean to toggle the feature
      #           A Hash with options
      #
      # Options: :domain   - The domain (String - nil by default, not required)
      #          :path     - Restrict cookies to a relative URI (String - nil by default)
      #          :max_age  - Cookies expiration expressed in seconds (Integer - nil by default)
      #          :secure   - Restrict cookies to secure connections
      #                      (Boolean - Automatically set on true if currently using a secure connection)
      #                      See #scheme and #ssl?
      #          :httponly - Prevent JavaScript access (Boolean - true by default)
      #
      # cookies true
      # or
      # cookies max_age: 300

      # Enable sessions
      # Argument: Symbol the Rack session adapter
      #           A Hash with options
      #
      # See: http://www.rubydoc.info/gems/rack/Rack/Session/Cookie
      #
      # sessions :cookie, secret: ENV['WEB_SESSIONS_SECRET']

      # Configure Rack middleware for this application
      #
      # middleware.use Rack::Protection

      # Default format for the requests that don't specify an HTTP_ACCEPT header
      # Argument: A symbol representation of a mime type, default to :html
      #
      # default_request_format :html

      # Default format for responses that doesn't take into account the request format
      # Argument: A symbol representation of a mime type, default to :html
      #
      # default_response_format :html

      # HTTP Body parsers
      # Parse non GET responses body for a specific mime type
      # Argument: Symbol, which represent the format of the mime type (only `:json` is supported)
      #           Object, the parser
      #
      # body_parsers :json

      # When it's true and the router receives a non-encrypted request (http),
      # it redirects to the secure equivalent resource (https). Default disabled.
      #
      # force_ssl true

      ##
      # TEMPLATES
      #

      # The layout to be used by all views
      #
      layout :application # It will load Web::Views::ApplicationLayout

      # The relative path to templates
      #
      templates 'templates'

      ##
      # ASSETS
      #
      assets do
        # JavaScript compressor
        #
        # Supported engines:
        #
        #   * :builtin
        #   * :uglifier
        #   * :yui
        #   * :closure
        #
        # See: http://hanamirb.org/guides/assets/compressors
        #
        # In order to skip JavaScript compression comment the following line
        javascript_compressor :builtin

        # Stylesheet compressor
        #
        # Supported engines:
        #
        #   * :builtin
        #   * :yui
        #   * :sass
        #
        # See: http://hanamirb.org/guides/assets/compressors
        #
        # In order to skip stylesheet compression comment the following line
        stylesheet_compressor :builtin

        # Specify sources for assets
        #
        sources << [
          'assets'
        ]
      end

      ##
      # SECURITY
      #

      # X-Frame-Options is a HTTP header supported by modern browsers.
      # It determines if a web page can or cannot be included via <frame> and
      # <iframe> tags by untrusted domains.
      #
      # Web applications can send this header to prevent Clickjacking attacks.
      #
      # Read more at:
      #
      #   * https://developer.mozilla.org/en-US/docs/Web/HTTP/X-Frame-Options
      #   * https://www.owasp.org/index.php/Clickjacking
      #
      security.x_frame_options 'DENY'

      # X-Content-Type-Options prevents browsers from interpreting files as
      # something else than declared by the content type in the HTTP headers.
      #
      # Read more at:
      #
      #   * https://www.owasp.org/index.php/OWASP_Secure_Headers_Project#X-Content-Type-Options
      #   * https://msdn.microsoft.com/en-us/library/gg622941%28v=vs.85%29.aspx
      #   * https://blogs.msdn.microsoft.com/ie/2008/09/02/ie8-security-part-vi-beta-2-update
      #
      security.x_content_type_options 'nosniff'

      # X-XSS-Protection is a HTTP header to determine the behavior of the browser
      # in case an XSS attack is detected.
      #
      # Read more at:
      #
      #   * https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
      #   * https://www.owasp.org/index.php/OWASP_Secure_Headers_Project#X-XSS-Protection
      #
      security.x_xss_protection '1; mode=block'

      # Content-Security-Policy (CSP) is a HTTP header supported by modern browsers.
      # It determines trusted sources of execution for dynamic contents
      # (JavaScript) or other web related assets: stylesheets, images, fonts,
      # plugins, etc.
      #
      # Web applications can send this header to mitigate Cross Site Scripting
      # (XSS) attacks.
      #
      # The default value allows images, scripts, AJAX, fonts and CSS from the same
      # origin, and does not allow any other resources to load (eg object,
      # frame, media, etc).
      #
      # Inline JavaScript is NOT allowed. To enable it, please use:
      # "script-src 'unsafe-inline'".
      #
      # Content Security Policy introduction:
      #
      #  * http://www.html5rocks.com/en/tutorials/security/content-security-policy/
      #  * https://www.owasp.org/index.php/Content_Security_Policy
      #  * https://www.owasp.org/index.php/Cross-site_Scripting_%28XSS%29
      #
      # Inline and eval JavaScript risks:
      #
      #   * http://www.html5rocks.com/en/tutorials/security/content-security-policy/#inline-code-considered-harmful
      #   * http://www.html5rocks.com/en/tutorials/security/content-security-policy/#eval-too
      #
      # Content Security Policy usage:
      #
      #  * http://content-security-policy.com/
      #  * https://developer.mozilla.org/en-US/docs/Web/Security/CSP/Using_Content_Security_Policy
      #
      # Content Security Policy references:
      #
      #  * https://developer.mozilla.org/en-US/docs/Web/Security/CSP/CSP_policy_directives
      #
      security.content_security_policy %{
        form-action 'self';
        frame-ancestors 'self';
        base-uri 'self';
        default-src 'none';
        script-src 'self';
        connect-src 'self';
        img-src 'self' https: data:;
        style-src 'self' 'unsafe-inline' https:;
        font-src 'self';
        object-src 'none';
        plugin-types application/pdf;
        child-src 'self';
        frame-src 'self';
        media-src 'self'
      }

      ##
      # FRAMEWORKS
      #

      # Configure the code that will yield each time Web::Action is included
      # This is useful for sharing common functionality
      #
      # See: http://www.rubydoc.info/gems/hanami-controller#Configuration
      controller.prepare do
        # include MyAuthentication # included in all the actions
        # before :authenticate!    # run an authentication before callback
      end

      # Configure the code that will yield each time Web::View is included
      # This is useful for sharing common functionality
      #
      # See: http://www.rubydoc.info/gems/hanami-view#Configuration
      view.prepare do
        include Hanami::Helpers
        include Web::Assets::Helpers
      end
    end

    ##
    # DEVELOPMENT
    #
    configure :development do
      # Don't handle exceptions, render the stack trace
      handle_exceptions false

      # Logger
      # See: http://hanamirb.org/guides/applications/logging
      #
      # Logger stream. It defaults to STDOUT.
      # logger.stream "log/development.log"
      #
      # Logger level. It defaults to DEBUG
      # logger.level :debug
      #
      # Logger format. It defaults to DEFAULT
      # logger.format :default
    end

    ##
    # TEST
    #
    configure :test do
      # Don't handle exceptions, render the stack trace
      handle_exceptions false

      # Logger
      # See: http://hanamirb.org/guides/applications/logging
      #
      # Logger level. It defaults to ERROR
      logger.level :error
    end

    ##
    # PRODUCTION
    #
    configure :production do
      # scheme 'https'
      # host   'example.org'
      # port   443

      # Logger
      # See: http://hanamirb.org/guides/applications/logging
      #
      # Logger stream. It defaults to STDOUT.
      # logger.stream "log/production.log"
      #
      # Logger level. It defaults to INFO
      logger.level :info

      # Logger format.
      logger.format :json

      assets do
        # Don't compile static assets in production mode (eg. Sass, ES6)
        #
        # See: http://www.rubydoc.info/gems/hanami-assets#Configuration
        compile false

        # Use digest file name for asset paths
        #
        # See: http://hanamirb.org/guides/assets/overview
        digest  true

        # Content Delivery Network (CDN)
        #
        # See: http://hanamirb.org/guides/assets/content-delivery-network
        #
        # scheme 'https'
        # host   'cdn.example.org'
        # port   443

        # Subresource Integrity
        #
        # See: http://hanamirb.org/guides/assets/subresource-integrity
        subresource_integrity :sha256
      end
    end
  end
end
END

      #
      # apps/web/config/routes.rb
      #
      expect("apps/web/config/routes.rb").to have_file_content <<-END
# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
END

      #
      # apps/web/views/application_layout.rb
      #
      expect("apps/web/views/application_layout.rb").to have_file_content <<-END
module Web
  module Views
    class ApplicationLayout
      include Web::Layout
    end
  end
end
END

      #
      # apps/web/templates/application.html.erb
      #
      expect("apps/web/templates/application.html.erb").to have_file_content <<-END
<!DOCTYPE html>
<html>
  <head>
    <title>Web</title>
    <%= favicon %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
END

      #
      # apps/web/assets/favicon.ico
      #
      expect("apps/web/assets/favicon.ico").to be_an_existing_file

      #
      # apps/web/controllers/.gitkeep
      #
      expect("apps/web/controllers/.gitkeep").to be_an_existing_file

      #
      # apps/web/assets/images/.gitkeep
      #
      expect("apps/web/assets/images/.gitkeep").to be_an_existing_file

      #
      # apps/web/assets/javascripts/.gitkeep
      #
      expect("apps/web/assets/javascripts/.gitkeep").to be_an_existing_file

      #
      # apps/web/assets/javascripts/.gitkeep
      #
      expect("apps/web/assets/javascripts/.gitkeep").to be_an_existing_file

      #
      # apps/web/assets/stylesheets/.gitkeep
      #
      expect("apps/web/assets/stylesheets/.gitkeep").to be_an_existing_file

      #
      # spec/web/features/.gitkeep
      #
      expect("spec/web/features/.gitkeep").to be_an_existing_file

      #
      # spec/web/controllers/.gitkeep
      #
      expect("spec/web/controllers/.gitkeep").to be_an_existing_file

      #
      # spec/web/views/.gitkeep
      #
      expect("spec/web/views/.gitkeep").to be_an_existing_file
    end
  end

  context "with underscored project name" do
    it_behaves_like "a new project" do
      let(:input) { "cool_name" }
    end
  end

  context "with dashed project name" do
    it_behaves_like "a new project" do
      let(:input) { "awesome-project" }
    end
  end

  context "with camel case project name" do
    it_behaves_like "a new project" do
      let(:input) { "CaMElCaSE" }
    end
  end

  context "with missing name" do
    it "fails" do
      output = <<-OUT
`hanami new` was called with no arguments
Usage: `hanami new PROJECT_NAME`
      OUT

      run_command "hanami new", output, exit_status: 1
    end
  end

  context "help" do
    xit "prints help message" do
      output = <<-OUT
Usage:
  hanami new PROJECT_NAME

Options:
  -d, --db, [--database=DATABASE]                        # Application database (mysql/mysql2/postgresql/postgres/sqlite/sqlite3/filesystem/memory)
                                                         # Default: filesystem
  -a, --arch, [--architecture=ARCHITECTURE]              # Project architecture (container/app)
                                                         # Default: container
          [--application-name=APPLICATION_NAME]          # Application name, only for container
                                                         # Default: web
          [--application-base-url=APPLICATION_BASE_URL]  # Application base url
                                                         # Default: /
          [--template=TEMPLATE]                          # Template engine (erb/slim/haml)
                                                         # Default: erb
          [--test=TEST]                                  # Project test framework (rspec/minitest)
                                                         # Default: minitest
          [--hanami-head], [--no-hanami-head]            # Use hanami HEAD (true/false)
          [--help=HELP]                                  # Displays the usage method
OUT

# rubocop:disable Style/CommentIndentation
# FIXME: this extra verbatim causes a spec failure
# Description:
#   `hanami new` creates a new hanami project. You can specify various options such as the database to be used as well as the path and architecture.
#
#   $ > hanami new fancy_app --application_name=admin
#
#   $ > hanami new fancy_app --arch=app
#
#   $ > hanami new fancy_app --hanami-head=true
# rubocop:enable Style/CommentIndentation

      run_command "hanami new --help", output
    end
  end
end
