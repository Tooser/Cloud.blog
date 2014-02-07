helpers do
	def get_current_user	
		return User.FromSessionID session[:id]
	end
	
	def check_username(username)
		unless /\w{5,20}/.match(username) then
			return false
		end
		
		return true
	end
	
	def check_email(email)
		unless /@/.match(email) then
			return false
		end
		
		return true
	end
	
	def check_password(password)
		unless /\w{5,20}/.match(password) then
			return false
		end
		
		return true
	end
	
	def blog_uri(blogid)
		return base_url + "/blog/" + blogid.to_s
	end
	
	def base_url
		@base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
	end
end