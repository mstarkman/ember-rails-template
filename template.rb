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

def replace_file_contents(path, new_contents = "")
  remove_file(path)
  create_file(path, new_contents)
end

def ember_variant(variant)
  "# ember.js variant\n  config.ember.variant = :#{variant}\n"
end

def ember_version
  @ember_version ||= ask_with_default("What version of ember.js would you like?", "1.0.0.rc6.4")
end

def create_ember_controller
  if yes?("Would you like to create default ember controller?")
    controller_name = ask_with_default("What is the name of the default ember controller?", "ember").underscore
    generate "controller", "#{controller_name} index"

    replace_file_contents("app/views/#{controller_name}/index.html.erb", "")
    create_file("app/assets/javascripts/templates/application.hbs", "<h1>Welcome to Ember!</h1>")

    gsub_file "config/routes.rb", "get \"#{controller_name}/index\"", ""
    route "root to: '#{controller_name}#index'"
    route "match '*ember', to: '#{controller_name}#index', via: :all"
  end
end

def bootstrap_ember
  generate "ember:bootstrap"

  create_ember_controller
end

def install_ember
  gem 'ember-rails'
  gem 'ember-source', ember_version
  run 'bundle install'

  application(nil, env: :development) do
    ember_variant(:development)
  end

  application(nil, env: :test) do
    ember_variant(:production)
  end

  application(nil, env: :production) do
    ember_variant(:production)
  end

  bootstrap_ember
end

def run_template
  create_markdown_readme
  install_ember
end

run_template