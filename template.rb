def responses; @responses ||= {}; end
def after_bundler_blocks; @after_bundler_blocks ||= []; end
def after_bundler(&block); after_bundler_blocks << block; end

def create_markdown_readme
  remove_file "README.rdoc"
  create_file "README.md", <<-README
# #{application_name}
  README
end

def application_name
  @app_name
end

def ask_with_default(question, default_value)
  response = ask("#{question} [#{default_value}]")
  response = default_value if response.blank?
  response
end

def yes_with_default?(question)
  yes = %w[y yes].include? ask_with_default(question, "y")
  yield if block_given? && yes
  yes
end

def say_custom(tag, text)
  say "\033[33m[#{tag}]\033[0m #{text}"
end

def replace_file_contents(path, new_contents = "")
  remove_file(path)
  create_file(path, new_contents)
end

def ember_variant(variant)
  "# ember.js variant\n  config.ember.variant = :#{variant}\n"
end

def create_root_controller
  return unless responses[:use_root_controller]

  say_custom "Ember.js", "Creating the root controller..."
  controller_name = responses[:controller_name]
  generate "controller", "#{controller_name} index"

  replace_file_contents("app/views/#{controller_name}/index.html.erb", "")
  create_file("app/assets/javascripts/templates/application.hbs", "<h1>Welcome to Ember!</h1>")

  gsub_file "config/routes.rb", "get \"#{controller_name}/index\"", ""
  route "root to: '#{controller_name}#index'"
  route "match '*ember', to: '#{controller_name}#index', via: :all"
end

def bootstrap_ember
  after_bundler do
    say_custom "Ember.js", "Bootstrapping..."
    generate "ember:bootstrap --javascript-engine #{responses[:ember_javascript_engine]}"
    create_root_controller
  end
end

def install_ember
  say_custom "Ember.js", "Installing..."
  gem 'ember-rails'
  gem 'ember-source', "~> #{responses[:ember_version]}"

  application(nil, env: :development) { ember_variant(:development) }
  application(nil, env: :test) { ember_variant(:production) }
  application(nil, env: :production) { ember_variant(:production) }

  if responses[:use_ember_data]
    gem 'ember-data-source', "~> #{responses[:ember_data_version]}"
  end

  bootstrap_ember
end

def install_ui_gems
  say_custom "Gems", "Configuring the UI gems"
  gem 'bootstrap-sass', '~> 3.0' if responses[:use_bootstrap_sass]
  gem 'font-awesome-rails' if responses[:use_font_awesome]

  after_bundler do
    if responses[:use_bootstrap_sass]
      say_custom "Bootstrap Sass", "Bootstrapping..."
      remove_file "app/assets/stylesheets/application.css"
      create_file "app/assets/stylesheets/application.css.scss", "@import \"bootstrap\";\n"
      inject_into_file "app/assets/javascripts/application.js", after: "//= require jquery_ujs\n" do
        "//= require bootstrap\n"
      end
    end

    if responses[:use_font_awesome]
      say_custom "Font Awesome", "Bootstrapping..."
      if responses[:use_bootstrap_sass]
        inject_into_file "app/assets/stylesheets/application.css.scss", after: "@import \"bootstrap\";\n" do
          "@import \"font-awesome\";\n"
        end
      else
        inject_into_file "app/assets/stylesheets/application.css", before: " *= require_self\n" do
          " *= require font-awesome\n"
        end
      end
    end
  end
end

def install_development_gems
  say_custom "Gems", "Configuring the development gems"
  gem_group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'pry-rails'
    gem 'quiet_assets'
    gem 'meta_request'
  end
end

def install_development_and_test_gems
  say_custom "Gems", "Configuring the development and test gems"
  gem_group :development, :test do
    gem 'rspec-rails', version: '~> 2.0' if responses[:use_rspec]
    gem 'factory_girl_rails', version: '~> 4.0' if responses[:use_factory_girl]
  end

  after_bundler do
    if responses[:use_rspec]
      say_custom "RSpec", "Bootstrapping..."
      generate "rspec:install" if responses[:use_rspec]
    end

    if responses[:use_factory_girl]
      if responses[:use_rspec]
        say_custom "Factory Girl", "Configuring for RSpec"
        inject_into_file "spec/spec_helper.rb", after: "RSpec.configure do |config|\n" do
          "  config.include FactoryGirl::Syntax::Methods\n\n"
        end
      else
        say_custom "Factory Girl", "Configuring for Test::Unit"
        inject_into_file "test/test_helper.rb", after: "class ActiveSupport::TestCase\n" do
          "  include FactoryGirl::Syntax::Methods\n\n"
        end
      end
    end
  end
end

def install_test_gems
  say_custom "Gems", "Configuring the test gems"
  gem_group :test do
    gem 'shoulda-matchers'
  end
end

def bundle_install
  say_custom "Bundler", "Installing..."
  run 'bundle install'

  say_custom "Bundler", "Running the after bundle steps..."
  after_bundler_blocks.each do |block|
    block.call
  end
end

def disable_turbolinks
  return unless responses[:disable_turbolinks]

  say_custom "Turbolinks", "Removing from Gemfile"
  gsub_file "Gemfile", "gem 'turbolinks'", "#gem 'turbolinks'"

  say_custom "Turbolinks", "Removing from app/assets/javascripts/application.js"
  gsub_file "app/assets/javascripts/application.js", "//= require turbolinks\n", ""

  say_custom "Turbolinks", "Removing from app/views/layouts/application.html.erb"
  gsub_file "app/views/layouts/application.html.erb", ", \"data-turbolinks-track\" => true", ""
end

def customize_generators
  return unless responses[:customize_generators]

  say_custom "Generators", "Customizing..."
  application do <<-GENERATORS
config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.helper false
      g.test_framework :#{responses[:use_rspec] ? "rspec" : "test_unit"},
                       :fixtures => true,
                       :view_specs => false,
                       :helper_specs => false,
                       :routing_specs => false,
                       :controller_specs => true,
                       :request_specs => false
      #{responses[:use_factory_girl] ? "g.fixture_replacement :factory_girl, :dir => \"#{responses[:use_rspec] ? "spec" : "test"}/factories\"" : ""}
    end
  GENERATORS
  end
end

def setup_template
  say_custom "Setup", "Gathering information"
  responses[:ember_version] = ask_with_default("What version of ember.js would you like?", "1.3.1")
  responses[:use_ember_data] = yes_with_default?("Would you like to use ember-data?") do
    responses[:ember_data_version] = ask_with_default("What version of ember data would you like?", "1.0.0.beta.5")
  end
  responses[:ember_javascript_engine] = ask_with_default("Which JavaScript engine do you want to use with ember.js (js or coffee)?", "js")
  responses[:use_root_controller] = yes_with_default?("Would you like to create an ember controller as the root route?") do
    responses[:controller_name] = ask_with_default("What is the name of the ember root controller?", "ember").underscore
  end
  responses[:disable_turbolinks] = yes_with_default?("Would you like to disable turbolinks for this app?")
  responses[:use_rspec] = yes_with_default?("Do you want to use RSpec for testing?")
  responses[:use_factory_girl] = yes_with_default?("Do you want to use Factory Girl?")
  responses[:use_bootstrap_sass] = yes_with_default?("Do you want to use the bootstrap-sass gem?")
  responses[:use_font_awesome] = yes_with_default?("Do you want to use Font Awesome?")
  responses[:customize_generators] = yes_with_default?("Do you want to customize the standard Rails generators?")
end

def run_template
  create_markdown_readme
  install_ember
  install_ui_gems
  install_development_gems
  install_development_and_test_gems
  install_test_gems
  disable_turbolinks
  customize_generators
  bundle_install
end

setup_template
run_template
