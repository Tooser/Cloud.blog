#
# dropbox.rb
#

APP_KEY = 'irwm275wrq114uj'
APP_SECRET = '1ld0qea2hf72o6u'

def get_web_auth
	return DropboxOAuth2Flow.new(APP_KEY, APP_SECRET, url('/dropbox-auth-finish'), session, :dropbox_auth_csrf_token)
end

get '/dropbox-auth-finish' do
	# read user
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end

	# start flow, and rescue Exceptions
    begin
        access_token, user_id, url_state = get_web_auth.finish(params)
    rescue DropboxOAuth2Flow::BadRequestError => e
        return "Error in OAuth 2 flow", "<p>Bad request to /dropbox-auth-finish: #{e}</p>"
    rescue DropboxOAuth2Flow::BadStateError => e
        return "Error in OAuth 2 flow", "<p>Auth session expired: #{e}</p>"
    rescue DropboxOAuth2Flow::CsrfError => e
        logger.info("/dropbox-auth-finish: CSRF mismatch: #{e}")
        return "Error in OAuth 2 flow", "<p>CSRF mismatch</p>"
    rescue DropboxOAuth2Flow::NotApprovedError => e
        return "Not Approved?", "<p>Why not, bro?</p>"
    rescue DropboxOAuth2Flow::ProviderError => e
        return "Error in OAuth 2 flow", "Error redirect from Dropbox: #{e}"
    rescue DropboxError => e
        logger.info "Error getting OAuth 2 access token: #{e}"
        return "Error in OAuth 2 flow", "<p>Error getting access token</p>"
    end

    # save access_token
	@user.blog.dropbox_link access_token
	
	# create used folder if not exists
	@user.blog.client.file_create_folder('/posts/')
	@user.blog.client.file_create_folder('/sites/')
	
    redirect url('/intern/blogsettings?success')
end

get '/dropbox-auth-start' do
	# read user
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end

	# get authorization url
    authorize_url = get_web_auth().start()

	# redirect to url
    redirect authorize_url
end

get '/dropbox-unlink' do
    # read user
	@user = get_current_user
	
	unless @user then
		redirect url('/?error=notloggedin')
	end
	
	# dropbox unlink
	
	@user.blog.dropbox_unlink
	
	redirect url('/intern/blogsettings?success')
end