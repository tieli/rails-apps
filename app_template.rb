
@recipes = ["core", "git", "railsapps", "learn_rails", 
            "rails_bootstrap", "rails_foundation", "rails_omniauth", 
            "rails_devise", "rails_devise_roles", "rails_devise_pundit", 
            "rails_signup_download", "rails_mailinglist_activejob", 
            "rails_stripe_checkout", "rails_stripe_coupons", 
            "rails_stripe_membership_saas", "setup", "locale", "readme", 
            "gems", "tests", "email", "devise", "omniauth", "roles", 
            "frontend", "pages", "init", "analytics", "deployment", 
            "extras"]

@prefs = {}
@gems = []

@diagnostics_recipes = [["example"], ["setup"], ["railsapps"], 
            ["gems", "setup"], ["gems", "readme", "setup"], 
            ["extras", "gems", "readme", "setup"], 
            ["example", "git"], ["git", "setup"], ["git", "railsapps"], 
            ["gems", "git", "setup"], ["gems", "git", "readme", "setup"], 
            ["extras", "gems", "git", "readme", "setup"], 
            ["email", "extras", "frontend", "gems", "git", "init", 
             "railsapps", "readme", "setup", "testing"], 
            ["core", "email", "extras", "frontend", "gems", "git", 
              "init", "railsapps", "readme", "setup", "testing"], 
            ["core", "email", "extras", "frontend", "gems", "git", 
             "init", "railsapps", "readme", "setup", "testing"], 
            ["core", "email", "extras", "frontend", "gems", "git", 
             "init", "railsapps", "readme", "setup", "testing"], 
            ["email", "example", "extras", "frontend", "gems", 
              "git", "init", "railsapps", "readme", "setup", "testing"], 
            ["email", "example", "extras", "frontend", "gems", 
             "git", "init", "railsapps", "readme", "setup", "testing"], 
            ["email", "example", "extras", "frontend", "gems", 
              "git", "init", "railsapps", "readme", "setup", "testing"], 
            ["apps4", "core", "email", "extras", "frontend", "gems", 
             "git", "init", "railsapps", "readme", "setup", "testing"], 
            ["apps4", "core", "email", "extras", "frontend", "gems", 
             "git", "init", "railsapps", "readme", "setup", "tests"], 
            ["apps4", "core", "deployment", "email", "extras", 
             "frontend", "gems", "git", "init", "railsapps", "readme", 
             "setup", "testing"], 
            ["apps4", "core", "deployment", "email", "extras", 
              "frontend", "gems", "git", "init", "railsapps", "readme", 
              "setup", "tests"], 
            ["apps4", "core", "deployment", "devise", "email", "extras", 
             "frontend", "gems", "git", "init", "omniauth", "pundit", 
             "railsapps", "readme", "setup", "tests"]]

@diagnostics_prefs = []
diagnostics = {}

# --------------------------- 
# templates/helpers.erb 
# ---------------------------
def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end
def prefs; @prefs end
def prefer(key, value); @prefs[key].eql? value end
def gems; @gems end
def diagnostics_recipes; @diagnostics_recipes end
def diagnostics_prefs; @diagnostics_prefs end

# Colored Output
def colorize(text, color_code)
  "\033[1m\033[#{color_code}m#{text}\033[0m"
end

def red(text); colorize(text, 31); end
def cyan(text); colorize(text, 36); end
def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end

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

prefs[:apps4] = multiple_choice "Build a Rails Apps?",
    [["Build a Rails Blog App", "railsblogs"],
    ["Build a Rails Shop App", "railsshop"],
    ["Custom application (experimental)", "none"]]

remove_file "README.rdoc"
create_file "README.md", "TODO"

gem "rspec-rails", group: [:test, :development]
gem 'haml', version: '>= 4.0.7'
gem 'bcrypt', '~> 3.1.7'

run "bundle install"
git :init

append_file ".gitignore", "config/database.yml"
run "cp config/database.yml config/example_database.yml"
git add: ".", commit: "-m 'initial commit'"

def get_gen_str(type, res_desc)
  name = res_desc[0]
  str = " " + type + " "
  case type
  when 'scaffold'
    str = str + name.pluralize(1)
  when 'model'
    str = str + name.pluralize(1)
  when 'resource'
    str = str + name.pluralize(2)
  end
  res_desc[1].each { |k,v| str << " " << k << ":" << v }
  str
end

article_model = ["Article", { "title" => "string", "content" => "text",
                "published_at" => "datetime", "hidden" => "boolean" }]

comment_model = ["Comment", { "commenter" => "string", 
                "content" => "text", "article" => "references" } ]

tag_model     = ["tag", { "name" => "string" } ]

tagging_model = ["tagging", { "tag" => "belongs_to", 
                "article" => "belongs_to" } ]

user_model    = ["user", { "email" => "string", "password" => "string",
                "password_digest" => "string" } ]

case prefs[:apps4]
when 'railsblogs'
  app_name = 'railsblogs'
  generate get_gen_str("scaffold", article_model)
  generate get_gen_str("model", comment_model)
  generate get_gen_str("model", tag_model)
  generate get_gen_str("model", tagging_model)
  generate get_gen_str("resource", user_model)
  generate "controller", "comments" 
  generate "controller", "sessions new" 

  route "root to: 'articles\#index'"

  rake "db:migrate"

  repo = "https://raw.githubusercontent.com/tieli/RailsApps/master/"

  app_files = ['app/assets/stylesheets/application.scss', 
               'app/assets/stylesheets/scaffolds.scss',
               'app/views/layouts/application.html.erb',
               'app/controllers/users_controller.rb',
               'app/controllers/articles_controller.rb',
               'app/controllers/comments_controller.rb',
               'app/views/comments/_comment.html.erb',
               'app/views/comments/edit.html.erb',
               'app/views/comments/_form.html.erb',
               'app/views/articles/index.html.erb',
               'app/views/articles/show.html.erb',
               'app/views/articles/_form.html.erb',
               'app/views/users/new.html.erb',
               'app/models/user.rb',
               'app/models/article.rb',
               'config/routes.rb',
               'db/seeds.rb']

  app_files.each do |from_file|
    copy_from_repo app_name, from_file, :repo => repo
  end
when 'railsshop'
end

remove_file "public/index.html"
generate "rspec:install"
capify!

rake "db:seed"

