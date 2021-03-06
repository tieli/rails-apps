

comments_filers = ["# Bundle edge Rails",
                   "# Use sqlite3 as the",
                   "# Use SCSS for stylesheets",
                   "# Use Uglifier as compressor",
                   "# Use CoffeeScript",
                   "# See https://github.com/rails",
                   "# Use jquery as the",
                   "# Turbolinks makes",
                   "# Build JSON APIs",
                   "# bundle exec rake doc:rails",
                   "# Use ActiveModel",
                   "# Call 'byebug' anywhere",
                   "# Access an IRB console ",
                   "# Spring speeds up development"]

repo = "https://raw.githubusercontent.com/tieli/rails-apps/master/"

app_css            = 'app/assets/stylesheets/application.css'
app_scss           = 'app/assets/stylesheets/application.scss'
app_css_scss       = 'app/assets/stylesheets/application.css.scss'
forms_css_scss     = 'app/assets/stylesheets/forms.css.scss'

app_erb            = 'app/views/layouts/application.html.erb'
app_html_erb       = 'app/views/layouts/application.html.erb'
app_haml           = 'app/views/layouts/application.html.haml'
app_html_haml      = 'app/views/layouts/application.html.haml'

app_helpers_layout = 'app/helpers/layout_helper.rb'
app_controller     = 'app/controllers/application_controller.rb',
app_ctrl           = 'app/controllers/application_controller.rb',

scaffolds_css      = 'app/assets/stylesheets/scaffolds.css'
scaffolds_scss     = 'app/assets/stylesheets/scaffolds.scss'
scaffolds_css_scss = 'app/assets/stylesheets/scaffolds.css.scss'
app_js             = 'app/assets/javascripts/application.js'

devise_reg_edit = "app/views/devise/registrations/edit.html.erb"
devise_reg_new  = "app/views/devise/registrations/new.html.erb"
devise_ses_new  = "app/views/devise/sessions/new.html.erb"

config_dev         = 'config/environments/development.rb'
config_test        = 'config/environments/test.rb'
config_routes      = 'config/routes.rb'
routes_file        = 'config/routes.rb'

av = 'app/views/'
am = 'app/models/'
ac = 'app/controllers/'
aa = 'app/assets/'

user_rb      = 'app/models/user.rb'
cart_rb      = 'app/models/cart.rb'
article_rb   = 'app/models/article.rb'
line_item_rb = 'app/models/line_item.rb'

@prefs = {}
@gems = []

@diagnostics_prefs = []
diagnostics = {}

##########################
#  templates/hepers.erb  #
##########################

def recipes 
  @recipes 
end

def recipe?(name) 
  @recipes.include?(name) 
end

def prefs 
  @prefs 
end

def prefer(key, value) 
  @prefs[key].eql? value 
end

def gems 
  @gems 
end

def diagnostics_recipes 
  @diagnostics_recipes 
end

def diagnostics_prefs 
  @diagnostics_prefs 
end

# Colored Output
def colorize(text, color_code)
  "\033[1m\033[#{color_code}m#{text}\033[0m"
end

def red(text) 
  colorize(text, 31) 
end

def cyan(text)
  colorize(text, 36) 
end

def green(text) 
  colorize(text, 32) 
end

def yellow(text) 
  colorize(text, 33) 
end

def say_custom(tag, text) 
    say cyan(tag.to_s.rjust(10)) + "  #{text}" 
end

def say_loud(tag, text) 
    say cyan(tag.to_s.rjust(10) + "  #{text}")
end

def say_recipe(name) 
    say cyan("recipe".rjust(10)) + "  Running #{name}" 
end

def say_wizard(text) 
    say_custom(@current_recipe || 'composer', text) 
end

def ask_wizard(question)
  ask cyan(("choose").rjust(10)) + "  #{question}" 
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('option', question)
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom( (i + 1).to_s + ')', choice[0] )
  end

  begin 
    answer = ask_wizard("Enter your selection:") 
  end while(!values.keys.include?(answer))

  values[answer]
end

def html_to_haml(source)
  begin
    html = open(source) {|input| input.binmode.read }
    Haml::HTML.new(html, :erb => true, :xhtml => true).render
  rescue RubyParser::SyntaxError
    say_wizard "Ignoring RubyParser::SyntaxError"
    # special case to accommodate https://github.com/RailsApps/rails-composer/issues/55
    html = open(source) {|input| input.binmode.read }
    say_wizard "applying patch" if html.include? 'card_month'
    say_wizard "applying patch" if html.include? 'card_year'
    html = html.gsub(/, {add_month_numbers: true}, {name: nil, id: "card_month"}/, '')
    html = html.gsub(/, {start_year: Date\.today\.year, end_year: Date\.today\.year\+10}, {name: nil, id: "card_year"}/, '')
    result = Haml::HTML.new(html, :erb => true, :xhtml => true).render
    result = result.gsub(/select_month nil/, "select_month nil, {add_month_numbers: true}, {name: nil, id: \"card_month\"}")
    result = result.gsub(/select_year nil/, "select_year nil, {start_year: Date.today.year, end_year: Date.today.year+10}, {name: nil, id: \"card_year\"}")
  end
end

def copy_from_repo(app_name, file_name, opts = {})

  repo = opts[:repo] unless opts[:repo].nil?
  if (!opts[:prefs].nil?) && (!prefs.has_value? opts[:prefs])
    return
  end
  source_filename = app_name + "/" + file_name
  destination_filename = file_name

  unless opts[:prefs].nil?
    if filename.include? opts[:prefs]
      destination_filename = filename.gsub(/\-#{opts[:prefs]}/, '')
    end
  end
  if (prefer :templates, 'haml') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.haml')
  end
  if (prefer :templates, 'slim') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.slim')
  end
  begin
    remove_file destination_filename
    if (prefer :templates, 'haml') && (filename.include? 'views')
      create_file destination_filename, html_to_haml(repo + source_filename)
    elsif (prefer :templates, 'slim') && (filename.include? 'views')
      create_file destination_filename, html_to_slim(repo + source_filename)
    else
      get repo + source_filename, destination_filename
    end
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source_filename} from the repo #{repo}"
  end

end

def get_gen_str(type, res_desc, options = {})
  name = res_desc[0]
  fields = res_desc[1]
  str = " " + type + " "
  case type
  when 'scaffold'
    str = str + name.pluralize(1)
  when 'model'
    str = str + name.pluralize(1)
  when 'resource'
    str = str + name.pluralize(2)
  when 'migration'
    str = str + name
  when 'mailer'
    str = str + name
  end
  fields.each { |k,v| str << " " << k << ":" << v }
  options.each { |k,v| str << " " << "--" + k << " " << v }
  str
end

prefs[:apps4] = multiple_choice "Build a Rails Apps?",
    [["Build a Basic Rails App", "basic"],
    ["Build a Simple Blog App", "simple_blogs"],
    ["Build a Blog App", "blogs"],
    ["Build a Simple Store App", "simple_store"],
    ["Build a Store App", "store"],
    ["Build a Rails Todo List(Ajax)", "todos"],
    ["Build a Movies Review App", "movie_review"],
    ["Custom Application (experimental)", "none"],
    ["Quit", "quit"]]

exit if prefs[:apps4] == "quit"

gem_group :development, :test do
  gem "bullet"
  gem "better_errors", "~> 2.1", ">= 2.1.1"
  gem "binding_of_caller", "~> 0.7.2"
  gem "meta_request"
end

gem_group :development, :test do
  gem 'capybara', '~> 2.7', '>= 2.7.1'
  gem 'launchy-rails'
  gem 'rack-mini-profiler'
end

gem 'paperclip'
gem "haml", version: ">= 4.0.7"
gem 'will_paginate', '~> 3.1.0'
gem 'acts_as_votable', '~> 0.10.0'
gem 'jquery-ui-rails', '~> 5.0', '>= 5.0.5'

gem 'ruby-prof'
gem 'rails-perftest', '~> 0.0.6'
gem 'hirb', '~> 0.7.3'
gem 'awesome_print', '~> 1.7'
gem 'methodfinder', '~> 2.0'
gem 'fancy_irb', '~> 0.6.0'

gem 'pry', '~> 0.10.4'
gem 'pry-doc', '~> 0.9.0'
gem 'commands'

gem 'faker', '~> 1.6', '>= 1.6.6'
gem 'html2haml', '~> 2.0'

uncomment_lines 'Gemfile', /bcrypt/
uncomment_lines 'Gemfile', /'therubyracer'/

run "bundle install"

###############################
#  Select Frontend Framework  #
###############################

prefs[:frontend] = multiple_choice "Front End Framework?",
    [["Baisc", "basic"],
    ["Bootstrap", "bootstrap"],
    ["Zurb Foundation", "foundation"],
    ["No Frontend Framework", "no_frontend"]]

##########################
#  Select Authencation   #
##########################

prefs[:auth] = multiple_choice "Authentication?",
    [["No Authentication", "no_auth"],
    ["Basic Authentication", "basic"],
    ["Authlogic", "authlogic"],
    ["Sorcery", "sorcery"],
    ["Warden", "warden"],
    ["Omni Authentication", "omniauth"],
    ["Devise", "devise"]]

##############################
#  Select Testing Framework  #
##############################

prefs[:test] = multiple_choice "Testing Framework?",
    [["Rspec", "rspec"],
    ["Test::Unit", "test_unit"],
    ["Minitest::Test", "minitest"]]

prefs[:javascript_driver] = yes_wizard?("Using PhantomJs as Javascript driver?")

prefs[:announcement] = yes_wizard?("Add sitewise announcement?")

case prefs[:test]

when 'test_unit'

when 'rspec'
  gem_group :development, :test do
    gem "rspec-rails"
    gem 'factory_girl_rails', '~> 4.7'
    gem 'database_cleaner', '~> 1.5', '>= 1.5.3' 
  end
  
  run "bundle install"
  generate "rspec:install"

  #Add config.include Capybara::DSL in spec/rails_helper.rb
  inject_into_file 'spec/rails_helper.rb', after: "RSpec.configure do |config|\n" do <<-'RUBY'
  #config.filter_run focus: true
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    ActionMailer::Base.deliveries = []
  end

=begin
  config.before(:suite) do
    begin
      DatabaseCleaner[:active_record].strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
=end

  config.include Capybara::DSL
  RUBY
  end

  comment_lines 'spec/rails_helper.rb', /config.use_transactional_fixtures/


  if prefs[:javascript_driver] then
    gem "poltergeist", group: ["test", "development"]

    inject_into_file 'spec/spec_helper.rb', before: "RSpec.configure" do <<-'RUBY'
    require 'capybara/poltergeist'
    Capybara.javascript_driver = :poltergeist
    RUBY
    end
  else
    gem "selenium-webdriver", group: ["test", "development"]
  end

when 'minitest'

  gem_group :development, :test do
    gem 'minitest-rails', '~> 2.2', '>= 2.2.1'
  end

  run "bundle install"
  generate "minitest:install"

end

###################################
#  Layout and Stylesheet files    #
###################################

app_files = [ scaffolds_css_scss, app_helpers_layout, app_html_erb ]

case prefs[:frontend]
when 'basic'
  if prefs[:auth] == 'no_auth'
    app_name = "frontend/no_auth"
  elsif prefs[:auth] == 'authlogic'
    app_name = "frontend/authlogic"
    app_files += [ config_routes ]
  elsif prefs[:auth] == 'sorcery'
    app_name = "frontend/sorcery"
    app_files += [ config_routes ]
  elsif prefs[:auth] == 'warden'
    app_name = "frontend/warden"
    app_files += [ config_routes ]
  elsif prefs[:auth] == 'devise'
    app_name = "frontend/devise"
    app_files += [ config_routes ]
  elsif prefs[:auth] == 'omniauth'
    app_name = "frontend/omniauth"
  else
    app_name = "frontend/basic_auth"
    app_files += [ config_routes ]
  end
when 'bootstrap'
  abort("Auth method is required") if prefs[:auth] == 'no_auth'
    app_name = "frontend/bootstrap"

  gem 'simple_form', '~> 3.2', '>= 3.2.1'
  gem 'bootstrap-sass'

  run "bundle install"

  generate "simple_form:install --bootstrap"

  append_to_file app_js do <<-'RUBY'
  //= require jquery-ui
  //= require bootstrap-sprockets
  RUBY
  end

  app_files = [ app_html_erb, app_css_scss, config_routes ]

  remove_file app_css

when 'foundation'
  abort("Auth method is required") if prefs[:auth] == 'no_auth'
    app_name = "frontend/foundation"

  gem 'zurb-foundation'
  generate "foundation:install --force"

end

app_files.each do |from_file|
  copy_from_repo app_name, from_file, :repo => repo
end

app_files = [ ]

case prefs[:auth]
when 'no_auth'
when 'basic'
  generate "resource", "user email password_digest" 
  generate "controller", "sessions new" 
  generate "controller", "password_resets new" 

  user_auth_token_migration = ["add_auth_token_to_users", 
                          { "auth_token" => "string" } ]
  generate get_gen_str("migration", user_auth_token_migration)

  password_reset_migration = ["add_password_reset_token_to_users", 
                          {"password_reset_token" => "string" ,
                           "password_reset_sent_at" => "datetime" } ]
  generate get_gen_str("migration", password_reset_migration)

  user_mailer = ["user_mailer",
                {"password_reset" => "string" }]

  generate get_gen_str("mailer", user_mailer)

  [config_dev, config_test].each do 
    inject_into_file config_dev, after: "Rails.application.configure do\n" do <<-'RUBY'
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    RUBY
    end
  end

  app_files += ['app/models/user.rb',
               'app/views/users/new.html.erb',
               'app/views/users/show.html.erb',
               'app/views/sessions/new.html.erb',
               'app/views/user_mailer/password_reset.text.erb',
               'app/views/password_resets/edit.html.erb',
               'app/views/password_resets/new.html.erb',
               'app/controllers/application_controller.rb',
               'app/controllers/users_controller.rb',
               'app/controllers/sessions_controller.rb',
               'app/controllers/password_resets_controller.rb',
               'app/mailers/user_mailer.rb',
               'app/helpers/application_helper.rb',
               ]
  app_name = "auth/basic"

when 'authlogic'

  gem 'authlogic', '~> 3.4', '>= 3.4.6'
  run "bundle install"

  user_model = ["User", { "email" => "string",
                          "crypted_password" => "string",
                          "password_salt" => "string",
                          "persistence_token" => "string" }]
  generate get_gen_str("scaffold", user_model)

  inject_into_file user_rb, after: "class User < ActiveRecord::Base\n" do <<-'RUBY'
  acts_as_authentic
  RUBY
  end

  app_files += ['app/views/users/new.html.erb',
               'app/views/user_sessions/new.html.erb',
               'app/views/shared/_errors.html.erb',
               'app/models/user_session.rb',
               'app/controllers/application_controller.rb',
               'app/controllers/user_sessions_controller.rb',
               'app/controllers/users_controller.rb']
  app_name = "auth/authlogic"

when 'sorcery'
  gem 'sorcery', '~> 0.9.1'
  run "bundle install"

  run "rails g sorcery:install"

  user_model = ["User", { "email" => "string",
                          "crypted_password" => "string",
                          "salt" => "string" }]
  options = { "migration" => "false",
              "force" => "" }
  generate get_gen_str("scaffold", user_model, options)

  inject_into_file user_rb, after: "class User < ActiveRecord::Base\n" do <<-'RUBY'
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true
  RUBY
  end

  app_files += ['app/views/users/new.html.erb',
               'app/views/user_sessions/new.html.erb',
               #'app/views/user_sessions/_form.html.erb',
               'app/controllers/user_sessions_controller.rb',
               'app/controllers/users_controller.rb']
  app_name = "auth/sorcery"

when 'warden'
  gem 'warden', '~> 1.2', '>= 1.2.6'
  run "bundle install"

  generate "resource", "user username email password_digest" 
  generate "controller", "sessions new" 

  inject_into_file user_rb, after: "class User < ActiveRecord::Base\n" do <<-'RUBY'
  has_secure_password
  RUBY
  end

  initializer "warden.rb", "#puts 'this is the beginning'"

  app_files += ['config/initializers/warden.rb',
               'app/models/user.rb',
               'app/views/users/new.html.erb',
               'app/views/sessions/create.html.erb',
               'app/views/sessions/new.html.erb',
               'app/controllers/application_controller.rb',
               'app/controllers/sessions_controller.rb',
               'app/controllers/users_controller.rb']
  app_name = "auth/warden"

when 'omniauth'
  gem 'omniauth-twitter', '~> 1.2', '>= 1.2.1'
  gem 'omniauth-facebook', '~> 3.0'

  app_files = ['config/initializers/omniauth.rb']
  app_name = "auth/omniauth"

when 'devise'
  gem 'devise', '~> 4.2'
  run "bundle install"

  generate "devise:install"
  generate "devise:views"
  generate "devise User"

  [config_dev, config_test].each do |file|
    inject_into_file file, after: "Rails.application.configure do\n" do <<-'RUBY'
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    RUBY
    end
  end

end

app_files.each do |from_file|
  copy_from_repo app_name, from_file, :repo => repo
end


app_files = []
app_name = prefs[:apps4]

case prefs[:apps4]
when 'basic'

  app_files = []

  generate "controller", "welcome home"
  route "root to: 'welcome\#home'"

when 'blogs'

  route "root to: 'articles\#index'"
  rake "db:migrate"

when "store"

  generate "controller", "store index"
  route "root to: 'store\#index'"

  product = ["Product", { "title" => "string",
                        "description" => "text",
                        "image_url" => "string",
                        "price" => "decimal" } ]
  generate get_gen_str("scaffold", product)

  cart = ["Cart", {}]
  generate get_gen_str("scaffold", cart)

  line_item = ["Line_item", { "product_id" => "integer",
                        "quantity" => "integer",
                        "cart_id" => "integer" } ]
  generate get_gen_str("scaffold", line_item)

  inject_into_file app_ctrl, after: "protect_from_forgery with: :exception\n" do <<-'RUBY'

  private
  def current_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end
  RUBY
  end

  inject_into_file cart_rb, after: "< ActiveRecord::Base\n" do <<-'RUBY'
    has_many :line_items, :dependent => :destroy

    def add_product(product_id)
    current_item = line_items.find_by(product_id: product_id)
    if current_item
      current_item.quantity += 1
    else
      current_item = line_items.build(product_id: product_id)
      current_item.price = current_item.product.price
    end
    current_item
    end

    def total_price
      line_items.to_a.sum { |item| item.total_price }
    end

  RUBY
  end

  inject_into_file line_item_rb, after: "< ActiveRecord::Base\n" do <<-'RUBY'
    belongs_to :product
    belongs_to :cart

    def total_price
      product.price * quantity
    end

  RUBY
  end

  app_files = [#'config/routes.rb',
               'db/seeds.rb',
               'app/assets/images/cs.jpg',
               'app/assets/images/rtp.jpg',
               'app/assets/images/ruby.jpg',
               'app/models/product.rb',
               'app/views/store/index.html.erb',
               'app/views/carts/show.html.erb',
               'app/views/line_items/index.html.erb',
               'app/views/products/index.html.erb',
               'app/controllers/carts_controller.rb',
               'app/controllers/store_controller.rb',
               'app/controllers/line_items_controller.rb',
               'app/controllers/concerns/current_cart.rb',
               'test/fixtures/products.yml',
               'test/models/product_test.rb',
               'test/controllers/store_controller_test.rb',
               'test/controllers/line_items_controller_test.rb',
               'test/controllers/products_controller_test.rb',
               ]

  rake "db:migrate"

when 'simple_blogs'

  generate "controller", "welcome home"
  route "root to: 'welcome\#home'"

  article_model = ["Article", {"title" => "string",
                               "content" => "text",
                               "hidden" => "boolean",
                               "published_at" => "datetime" }]
  generate get_gen_str("scaffold", article_model)

  comment_model = ["Comment", {"commenter" => "string",
                               "content" => "text",
                               "article" => "references" } ]
  generate get_gen_str("model", comment_model)

  category_model = ["Category", { "name" => "string" } ]
  generate get_gen_str("model", category_model)

  article_category_migration = ["add_category_id_to_articles", 
                             {"category_id" => "integer"} ]
  generate get_gen_str("migration", article_category_migration)

  tag_model     = ["tag", {"name" => "string" } ]
  generate get_gen_str("model", tag_model)

  tagging_model = ["tagging", {"tag" => "belongs_to",
                            "article" => "belongs_to" } ]
  generate get_gen_str("model", tagging_model)

  generate "controller", "comments" 

  app_files = [#'config/routes.rb',
               'db/seeds.rb',
               'app/assets/stylesheets/articles.scss',
               'app/models/article.rb',
               'app/models/comment.rb',
               'app/models/tag.rb',
               'app/views/articles/new.html.erb',
               'app/views/articles/index.html.erb',
               'app/views/articles/show.html.erb',
               'app/views/articles/_article.html.erb',
               'app/views/articles/_form.html.erb',
               'app/views/comments/_comment.html.erb',
               'app/views/comments/edit.html.erb',
               'app/views/comments/_form.html.erb',
               'app/views/layouts/mailer.text.erb',
               'app/controllers/articles_controller.rb',
               'app/controllers/comments_controller.rb',
               'test/fixtures/articles.yml',
               'test/fixtures/categories.yml',
               'spec/requests/articles_spec.rb'
               ]

  [config_dev, config_test].each do |item|
    inject_into_file item, after: "Rails.application.configure do\n" do <<-'RUBY'
    config.action_mailer.default_url_options = { :host => "http://127.0.0.1:23000" }
    RUBY
    end
  end

  inject_into_file "app/views/welcome/home.html.erb", before: "<h1>Welcome#home</h1>\n" do <<-'RUBY'
  <% provide(:title, "Home") %>
  RUBY
  end

  inject_into_file routes_file, after: "Rails.application.routes.draw do\n" do <<-'RUBY'
  get 'tags/:tag', to: 'articles#index', as: :tag

  resources :articles  do
    resources :comments
  end

  RUBY
  end

when 'simple_store'

  model = ["Product", { "name" => "string",
                        "price" => "decimal",
                        "stock" => "integer",
                        "rating" => "integer",
                        "released_on" => "date",
                        "category_id" => "integer",
                        "publisher_id" => "integer",
                        "discontinued" => "boolean" }]
  generate get_gen_str("scaffold", model)

  model = ["Order", { "price" => "decimal", 
                      "purchased_at" => "datetime",
                      "shipping" => "boolean" }]
  generate get_gen_str("scaffold", model)

  model = ["Publisher", { "name" => "string" } ]
  generate get_gen_str("model", model)

  model = ["Categorization", {
           "product_id" => "integer", "category_id" => "integer" }]
  generate get_gen_str("model", model)

  model = ["Category", { "name" => "string" } ]
  generate get_gen_str("model", model)

  route "root to: 'products\#index'"

  app_files = ['db/seeds.rb',
               'config/routes.rb',
               'app/assets/images/up_arrow.gif',
               'app/assets/images/down_arrow.gif',
               'app/models/product.rb',
               'app/models/publisher.rb',
               'app/models/category.rb',
               'app/models/categorization.rb',
               'app/views/orders/index.html.erb',
               'app/views/products/index.html.erb',
               'app/views/products/summary.html.erb',
               'app/views/products/_footer.html.erb',
               'app/views/products/_form.html.erb',
               'app/views/shared/_footer.html.erb',
               'app/controllers/orders_controller.rb',
               'app/controllers/products_controller.rb',
               'app/helpers/application_helper.rb' ]

  gem 'simple_form', '~> 3.2', '>= 3.2.1'
  generate "simple_form:install --bootstrap"

when 'movie_review'

  movie_model = ["Movie", { "title" => "string",
                            "year" => "integer",
                            "rating" => "string",
                            "director_id" => "integer",
                            "description" => "text",
                            "movie_length" => "string" }]
  generate get_gen_str("scaffold", movie_model)

  director_model = ["Director", {"name" => "string" }]
  generate get_gen_str("model", director_model)

  actor_model    = ["Actor", {"name" => "string" }]
  generate get_gen_str("model", actor_model)

  acting_model   = ["Acting", {"actor" => "belongs_to",
                            "movie" => "belongs_to" } ]
  generate get_gen_str("model", acting_model)

  review_model = ["Review", { "comment" => "text",
                              "rating" => "string",
                              "movie_id" => "integer" } ]
  generate get_gen_str("model", review_model)

  generate "controller", "directors" 

  gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
  gem 'jquery-ui-rails', '~> 5.0', '>= 5.0.5'

  gem 'devise', '~> 4.2'
  generate "devise:install"
  generate "devise:views"
  generate "devise User"

  generate "paperclip movie image"

  if prefs[:auth] != "no_auth"
    movie_user_migration = ["add_user_id_to_movies", 
                            { "user_id" => "integer" } ]
  end

  generate get_gen_str("migration", movie_user_migration)

  route "root to: 'movies\#index'"

  inject_into_file config_dev, after: "Rails.application.configure do\n" do <<-'RUBY'
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  RUBY
  end

  movie_rb = 'app/models/movie.rb'
  inject_into_file movie_rb, after: "class Movie < ActiveRecord::Base\n" do <<-'RUBY'
  belongs_to :user
  belongs_to :director
  has_many :actings
  has_many :actors, through: :actings
  has_many :reviews
  has_attached_file :image, styles: { medium: "400x600#" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def actor_list_in_string
    actors.pluck(:name).join(",")
  end

  RUBY
  end

  review_rb = 'app/models/review.rb'
  inject_into_file review_rb, after: "class Review < ActiveRecord::Base\n" do <<-'RUBY'
  belongs_to :movie
  RUBY
  end

  actor_rb = 'app/models/actor.rb'
  inject_into_file actor_rb, after: "class Actor < ActiveRecord::Base\n" do <<-'RUBY'
  has_many :actings
  has_many :movies, through: :actings
  RUBY
  end

  user_rb = 'app/models/user.rb'
  inject_into_file user_rb, after: "class User < ActiveRecord::Base\n" do <<-'RUBY'
  has_many :movies
  RUBY
  end

  director_rb = 'app/models/director.rb'
  inject_into_file director_rb, after: "class Director < ActiveRecord::Base\n" do <<-'RUBY'
  has_many :movies
  RUBY
  end

  director_controller_file = 'app/controllers/directors_controller.rb'
  inject_into_file director_controller_file, after: "class DirectorsController < ApplicationController\n" do <<-'RUBY'
  def index
    @directors = Director.order(:name).where("name like ?", "%#{params[:term]}%")
    render json: @directors.map(&:name)
  end
  RUBY
  end

  application_file = "app/assets/stylesheets/application"
  copy_file "#{application_file}.css", "#{application_file}.scss"
  append_to_file "#{application_file}.scss" do <<-'RUBY'
  @import "bootstrap-sprockets";
  @import "bootstrap";
  RUBY
  end

  append_to_file app_js do <<-'RUBY'
  //= require jquery-ui
  //= require bootstrap-sprockets
  RUBY
  end

  app_files = ['db/seeds.rb', 
               app_scss, app_erb, 
               'app/assets/javascripts/movies.coffee',
               'app/assets/stylesheets/movies.scss',
               'app/assets/images/1.jpg',
               'app/views/movies/index.html.erb',
               'app/views/movies/show.html.erb',
               'app/views/movies/_form.html.erb',
               'app/views/reviews/_form.html.erb',
               'app/views/reviews/_review.html.erb',
               'app/views/devise/sessions/new.html.erb',
               'app/views/devise/registrations/edit.html.erb',
               'app/views/devise/registrations/new.html.erb',
               'app/controllers/reviews_controller.rb',
               'app/controllers/movies_controller.rb' ]

  comment_lines 'config/routes.rb', /resources :movies/
  route "resources :movies do\n resources :reviews\nend"
  route "resources :directors"

  rake "db:populate"

end

rake "db:migrate"

capify!

inject_into_file 'bin/rails', before: "require \'rails/commands\'" do <<-'RUBY'
# Set default host and port to rails server
if ARGV.first == 's' || ARGV.first == 'server'
  require 'rails/commands/server'
  module Rails
    class Server
      def default_options
        super.merge(Host:  '0.0.0.0', Port: 3000)
      end
    end
  end
end
RUBY
end

app_files.each do |from_file|
  copy_from_repo app_name, from_file, :repo => repo
end

########################
#  Common Rails Tasks  #
########################

common_files = [ 'lib/tasks/setup.thor',
                 'lib/tasks/haml.rake', 
                 'lib/tasks/populate.rake',
                 'lib/tasks/list.rake',
                 'test/fixtures/users.yml',
                 'test/models/user_test.rb',
                 'test/integration/users_login_test.rb',
                 'test/integration/users_signup_test.rb',
                 'test/integration/password_reset_test.rb',
                 'spec/factories/users.rb',
                 'spec/models/user_spec.rb',
                 'spec/requests/users_signups_spec.rb',
                 'spec/requests/users_logins_spec.rb',
                 'spec/requests/password_resets_spec.rb',
                 'test/controllers/welcome_controller_test.rb',
                 'spec/mailers/user_mailer_spec.rb']

common_files.each do |from_file|
  copy_from_repo "shared", from_file, :repo => repo
end

gsub_file('Gemfile', /^\s*#.*\n/, '') 

inject_into_file 'Gemfile', after: "source 'https://rubygems.org'\n" do <<-'RUBY'
#

RUBY
end

append_to_file 'Gemfile' do <<-'RUBY'
#

RUBY
end

#######################
#  Site-announcement  #
#######################

if prefs[:announcement]
  generate "model", "announcement message:text starts_at:datetime ends_at:datetime" 

  app_files = ['app/assets/stylesheets/announcements.scss',
               'app/models/announcement.rb',
               'app/controllers/announcements_controller.rb',
               'spec/models/announcement_spec.rb',
               'spec/requests/announcements_spec.rb' ]

  inject_into_file 'app/controllers/application_controller.rb', after: "protect_from_forgery with: :exception\n" do <<-'RUBY'

  def enable_site_announcement?
    return true
  end
  helper_method :enable_site_announcement?
  RUBY
  end

  inject_into_file routes_file, after: "Rails.application.routes.draw do\n" do <<-'RUBY'
  get "announcements/:id/hide", to: 'announcements#hide', as: 'hide_announcement'
  RUBY
  end

  app_name = "announcement"
  app_files.each do |from_file|
    copy_from_repo app_name, from_file, :repo => repo
  end

  rake "db:migrate"

else

  inject_into_file 'app/controllers/application_controller.rb', after: "protect_from_forgery with: :exception\n" do <<-'RUBY'

  def enable_site_announcement?
    return false
  end
  helper_method :enable_site_announcement?
  RUBY
  end


end

remove_file "README.rdoc"
remove_file "public/index.html"

append_file ".gitignore", "config/database.yml"
#copy_file "config/database.yml", "config/example_database.yml"

git :init
git add: ".", commit: "-m 'initial commit'"

rake "db:seed"

