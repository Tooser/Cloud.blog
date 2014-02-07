#
#
#
require 'sqlite3'
require 'dropbox_sdk'

class Blog

	attr_reader :id, :user_id, :access_token, :user_object, :title, :description, :created_at
	
	@dropbox_client = nil
	
	#
	# Constructor
	#
	def initialize(sqlrow)
		@id = sqlrow['id']
		@user_id = sqlrow['user_id']
		@access_token = sqlrow['access_token']
		@title = sqlrow['title']
		@description = sqlrow['description']
		@created_at = sqlrow['created_at']
	end
	
	def user
		unless @user_object then
			@user_object = User.FromId @user_id
		end
		
		return @user_object
	end
	
	def client
		unless @dropbox_client then	# wenn client objekt noch nicht existiert
			if @access_token then # wenn gültiger access_token ausgewählt
				unless @access_token.empty? then # wenn access_token nicht leer
					@dropbox_client = DropboxClient.new(@access_token)
				end
			end
		end
		
		return @dropbox_client
	end
	
	def posts
		return Post.GetList client
	end
	
	def sites
		return Site.GetList client
	end
	
	def dropbox_link(access_token)
		# $stmt_SetAccessToken = $db.prepare( "UPDATE blogs SET access_token = :access_token WHERE id = :blog_id" )
		
		@access_token = access_token
		
		$stmt_SetAccessToken.execute({ :access_token => @access_token, :blog_id => @id })
	end
	
	def dropbox_unlink
		@access_token = ""
		
		$stmt_SetAccessToken.execute({ :access_token => @access_token, :blog_id => @id })
	end
	
	#
	# Static methods
	#
	def self.FromId(blog_id)
		# $stmt_BlogById = $db.prepare( "SELECT * FROM blogs WHERE id = :blog_id" )
		
		begin
			row = $stmt_BlogById.execute ({ :blog_id => blog_id })
			
			return Blog.new row.next()
		rescue
			return nil
		end
	end
	
	def self.FromUserId(user_id)
		# $stmt_BlogByUserId = $db.prepare( "SELECT * FROM blogs WHERE user_id = :user_id" )
		
		begin
			row = $stmt_BlogByUserId.execute ({ :user_id => user_id })
			
			return Blog.new row.next()
		rescue
			return nil
		end
	end
	
	def self.CreateNew(user_id, title, description)
		# $stmt_CreateBlog = $db.prepare( "INSERT INTO blogs (user_id, title, description) VALUES (:user_id, :title, :description)" )
		
		begin
			# create new blog
			$stmt_CreateBlog.execute ({ :user_id => user_id, :title => title, :description => description })
			
			# return blog
			return Blog.FromId $db.last_insert_row_id
		rescue
			return nil
		end
	end
end