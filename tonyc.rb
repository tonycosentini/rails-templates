run 'rm readme'

gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com'
gem 'nifty-generators', :lib => 'nifty_generators', :source => 'http://gems.github.com'
gem 'haml'
rake "gems:install", :sudo => true

plugin "paperclip", :git => 'git://github.com/thoughtbot/paperclip.git'
plugin "restful-authentication", :git => 'git://github.com/technoweenie/restful-authentication.git'

# add generation for user/session
name = ask('What do you want a user to be called?')
generate :nifty_authentication, name
rake "db:migrate"

run "rm public/javascripts/*"
run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"

# Well this here is a total hack...
env = IO.read 'config/environment.rb'
ins = 'Haml::Template.options[:format] = :html5'
env.gsub!(/^end$/, "end\n#{ins}") unless env.include?(ins)
File.open('config/environment.rb', 'w') do |env_out|
env_out.write(env)
end

run "rm -rf app/views/"
run "mkdir app/views"

file 'app/views/layouts/application.html.haml', <<-END
!!!
%html{:lang => 'en'}
  %head
    %meta{:charset => 'UTF-8'}
    %title
    =stylesheet_link_tag('style')
    =javascript_include_tag('jquery')
    =javascript_include_tag('application')
  %body
    =yield
END

file 'public/stylesheets/style.css', <<-END
/* BEGIN RESET */
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, font, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td {
	margin: 0;
	padding: 0;
	border: 0;
	outline: 0;
	font-size: 100%;
	vertical-align: baseline;
	background: transparent;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: '';
	content: none;
}

/* remember to define focus styles! */
:focus {
	outline: 0;
}

/* remember to highlight inserts somehow! */
ins {
	text-decoration: none;
}
del {
	text-decoration: line-through;
}

/* tables still need 'cellspacing="0"' in the markup */
table {
	border-collapse: collapse;
	border-spacing: 0;
}
/* END RESET */
END

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

git :add => '.', :commit => "-m 'Initial commit.'"