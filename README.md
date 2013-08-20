# ember-rails-template

This is a template that can be used to create a Rails 4.0 application with the [Ember.js](http://emberjs.com/) framework installed.

## Usage

`rails new my_app -m https://raw.github.com/mstarkman/ember-rails-template/master/template.rb`

## Gems Installed and configured

Here are the gems that are installed and configured for you by this template.

### Always installed

This is a list of gems that are always installed.

* [ember-rails](https://github.com/emberjs/ember-rails)
* [ember-source](https://github.com/emberjs/ember.js) - The version of this gem is specified by you

#### Development group

This is a list of gems that are installed in the development group within your `Gemfile`.

* [better_errors](https://github.com/charliesome/better_errors)
* [binding_of_caller](https://github.com/banister/binding_of_caller)
* [pry-rails](https://github.com/rweng/pry-rails)
* [quiet_assets](https://github.com/evrone/quiet_assets)
* [meta_request](https://github.com/qqshfox/meta_request)

#### Test group

This is a list of gems that are installed in the test group within your `Gemfile`.

* [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers)

### Optionally installed

This is a list of gems that are optionally installed based on your responses.

* [bootstrap-sass](https://github.com/thomas-mcdonald/bootstrap-sass) - This is currently set to version `~> 2.3.2.1`
* [font-awesome-rails](https://github.com/bokmann/font-awesome-rails)

#### Development and test groups

This is a list of gems that are installed in the development and test groups within your `Gemfile`.

* [rspec-rails](https://github.com/rspec/rspec-rails) - This is currently set to version `~> 2.0`
* [factory_girl_rails](https://github.com/thoughtbot/factory_girl_rails) - This is currently set to version `~> 4.0`

### Turbolinks gem

You will be prompted to disable the [turbolinks]() gem within your app.

## Rails generators customizations

This code snippet will be added to your `config/application.rb` file.  Some of the items may be a little different depending on the options you choose.

```ruby
config.generators do |g|
  g.javascripts false
  g.stylesheets false
  g.helper false
  g.test_framework :rspec,
                   :fixtures => true,
                   :view_specs => false,
                   :helper_specs => false,
                   :routing_specs => false,
                   :controller_specs => true,
                   :request_specs => false
  g.fixture_replacement :factory_girl, :dir => "spec/factories"
end
```

## To be done

* Upgrade and test the latest version of the Ember.js release candidates
* Upgrade to the latest version of the bootstrap-sass gem once it is updated for Bootstrap 3.0
* Make this work with Rails 3.x (I might work out as-is, I just haven't tested it)
* Add testing framework to make testing of Ember.js easier

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See [LICENSE](LICENSE).
