#
#
#

require 'sinatra'

# -------------------------------------------------------------------
# Make Cookie ready
use Rack::Session::Cookie,  :key => 'SESSION_ID',
                            :expire_after => 60*60*24, # == one day
                            :secret => 'DasSollteGeheimBleiben'

# -------------------------------------------------------------------
# load other stuff
load('db.rb')

# classes
load('classes/Content.class.rb')
load('classes/Post.class.rb')
load('classes/Site.class.rb')
load('classes/User.class.rb')
load('classes/Blog.class.rb')

# ...
load('helpers.rb')
load('dropbox.rb')
load('blog.rb')

# -------------------------------------------------------------------
# Basic stuff
get '/' do
	erb :index, :layout => :layout_intern_start
end

get '/register' do
	erb :register, :layout => :layout_intern_start
end

post '/register' do
	# check username
	unless /\w{5,20}/.match(params[:username]) then
		redirect url('/register?error=username')
	end
	
	# check email
	unless /@/.match(params[:email]) then
		redirect url('/register?error=email')
	end
	
	# check password
	unless params[:password1] == params[:password2] then
		redirect url('/register?error=password')
	end
	
	unless /\w{5,20}/.match(params[:password1]) then
		redirect url('/register?error=password')
	end
	
	# all is okay, then create user
	@user = User.RegisterNew(params[:username], params[:email], params[:password1])
	
	unless @user then
		redirect url('/register?error=create')
	end
	
	# user successfully created, redirect to start
	redirect url('/?success')
end

post '/login' do
	@user = User.FromName params[:username]
	
	unless @user then
		redirect url('/?error=usernotfound')
	end
	
	unless @user.checkPassword(params[:password]) then
		redirect url('/?error=wrongpassword')
	end
	
	session[:id] ||= SecureRandom.uuid
	@user.login session[:id]
	
	redirect url('/intern/user.' + @user.id.to_s)
end

get '/logout' do
	@user = get_current_user
	
	unless @user then
		redirect url('/')
	end
	
	@user.logout

	redirect url('/?logout')
end

get '/impressum' do
	erb :impressum, :layout => :layout_intern_start
end

# -------------------------------------------------------------------
# user stuff
get '/intern' do
	# get current user
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	erb :intern_home, :layout => :layout_intern
end

get '/intern/:site' do
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end

	# select site
	
	begin
		case params[:site]
			when "useredit"
				erb :intern_useredit, :layout => :layout_intern
			when "home"
				erb :intern_home, :layout => :layout_intern
			when "blogsettings"
				erb :intern_blogsettings, :layout => :layout_intern
			when "posts"
				erb :intern_posts, :layout => :layout_intern
			when "sites"
				erb :intern_sites, :layout => :layout_intern
			else
				redirect url('/intern?error=sitenotfound')
		end
	rescue DropboxOAuth2Flow::DropboxAuthError => e
		# Es scheint, als ob die Authentifizierung mit einem Dropbox-Konto nicht geklappt hat
		# Deshalb setzen wir den access_token lieber zurück, um keinen Fehler zu verursachen
        
		@user.blog.dropbox_unlink
		
		redirect url('/intern/' + params[:site] + '?error=dropboxauth')
	end
end

post '/intern/useredit' do
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# check username
	# unless check_username( params[:username] ) then
	# 	redirect url('/intern/useredit?error=username')
	# end
	
	# check email
	unless check_email( params[:email] ) then
		redirect url('/intern/useredit?error=email')
	end
	
	@user.updateInfo( @user.name, params[:email] )
	
	redirect url('/intern/useredit?success=useredit')
end

post '/intern/passwd' do
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# check password
	unless params[:newpassword1] == params[:newpassword2] then
		redirect url('/intern/useredit?error=passwordmatch')
	end
	
	unless check_password(params[:newpassword1]) then
		redirect url('/intern/useredit?error=password')
	end
	
	@user.updatePassword params[:newpassword1]
	
	redirect url('/intern/useredit?success=password')
end

# -------------------------------------------------------------------
# editor stuff
get '/intern/editor/:type.:name' do
	# User überprüfen
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# auf gültigen dropbox client checken
	client = @user.blog.client
	
	unless client then
		redirect url('/intern/blogsettings?error=dropboxlink')
	end
	
	# type und action checken	
	if params[:type] == "post" then
		if params[:name] == "new" then
			@content = Post.new client
		else
			@content = Post.new client, params[:name]
			@content.fetch_content
		end
	end
	
	if params[:type] == "site" then
		if params[:name] == "new" then
			@content = Site.new client
		else
			@content = Site.new client, params[:name]
			@content.fetch_content
		end
	end
	
	erb :intern_editor, :layout => :layout_intern
end

post '/intern/editor/:type.:name' do
	# User überprüfen
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# auf gültigen dropbox client checken
	client = @user.blog.client
	
	unless client then
		redirect url('/intern/blogsettings?error=dropboxlink')
	end
	
	# type und action checken	
	if params[:type] == "post" then
		if params[:name] == "new" then
			@content = Post.new client
			@content.set_raw_content params[:raw_content]	# Content setzen
			@content.generate_name								# Namen generieren
			@content.upload									# Datei hochladen
		else
			@content = Post.new client, params[:name]
			@content.set_raw_content params[:raw_content]
			@content.upload
		end
		
		redirect url('/intern/posts?success=' + @content.name)
	end
	
	if params[:type] == "site" then
		if params[:name] == "new" then
			@content = Site.new client
			@content.set_raw_content params[:raw_content]	# Content setzen
			@content.generate_name								# Namen generieren
			@content.upload									# Datei hochladen
		else
			@content = Site.new client, params[:name]
			@content.set_raw_content params[:raw_content]
			@content.upload
		end
		
		redirect url('/intern/sites?success=' + @content.name)
	end
	
	#finish
end

get '/intern/delete/:type.:name' do
	# User überprüfen
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# auf gültigen dropbox client checken
	client = @user.blog.client
	
	unless client then
		redirect url('/intern/blogsettings?error=dropboxlink')
	end
	
	# type checken
	if params[:type] == "post" then
		client.file_delete '/posts/' + params[:name] + '.md'
		redirect url('/intern/posts?success=delete')
	end
	
	if params[:type] == "site" then
		client.file_delete '/sites/' + params[:name] + '.md'
		redirect url('/intern/sites?success=delete')
	end
	
end

# -------------------------------------------------------------------
# 