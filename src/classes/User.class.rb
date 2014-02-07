#
#
#
require 'sqlite3'
require 'digest/md5'

class User
	attr_reader :id, :name, :email, :created_at, :blog_object

	#
	# Constructor
	#
	def initialize(sqlrow)
		@id = sqlrow['id']
		@name = sqlrow['name']
		@email = sqlrow['email']
		@created_at = sqlrow['created_at']
	end
	
	def blog
		unless @blog_object then
			@blog_object = Blog.FromUserId @id
		end
		
		return @blog_object
	end
	
	#
	# Login/Logout
	#
	def login(session_id)
		# $stmt_UpdateSessionID = $db.prepare( "UPDATE users SET session_id = :session_id WHERE id = :user_id" )		
		$stmt_UpdateSessionID.execute ({ :session_id => session_id, :user_id => @id })
	end
	
	def logout
		$stmt_UpdateSessionID.execute ({ :session_id => "", :user_id => @id })
	end
	
	def checkPassword(password)
		# $stmt_CheckPassword = $db.prepare( "SELECT * FROM users WHERE id = :user_id" )
		rows = $stmt_CheckPassword.execute ({ :user_id => @id })
		
		rows.each do |row|
			return row['password'] == Digest::MD5.hexdigest(password)
		end
	end
	
	def updatePassword(password)
		# $stmt_UpdatePassword = $db.prepare( "UPDATE users SET password = :password WHERE id = :user_id" )
		
		$stmt_UpdatePassword.execute ({:password => Digest::MD5.hexdigest(password), :user_id => @id })
	end
	
	def updateInfo(name, email)
		# $stmt_UpdateUserInfo = $db.prepare( "UPDATE users SET name = :name, email = :email WHERE id = :user_id" )
		$stmt_UpdateUserInfo.execute ({ :name => name, :email => email, :user_id => @id })
	end
	
	def blog
		# $stmt_BlogByUserId = $db.prepare( "SELECT * FROM blogs WHERE user_id = :user_id" )
		
		return Blog.FromUserId @id
	end
	
	#
	# Static methods
	#
	def self.FromId(user_id)
		# $stmt_UserById = $db.prepare( "SELECT * FROM users WHERE id = :user_id" )
		
		begin
			row = $stmt_UserById.execute ({ :user_id => user_id })

			return User.new row.next()
		rescue
			return nil
		end
	end
	
	def self.FromName(name)
		# $stmt_UserByName = $db.prepare( "SELECT * FROM users WHERE name = :name" )
		
		begin
			row = $stmt_UserByName.execute ({ :name => name })

			return User.new row.next()
		rescue
			return nil
		end
	end
	
	def self.FromSessionID(session_id)
		# $stmt_UserBySessionID = $db.prepare( "SELECT * FROM users WHERE session_id = :session_id" )
		
		begin
			row = $stmt_UserBySessionID.execute ({ :session_id => session_id })
			
			return User.new row.next()
		rescue
			return nil
		end
	end
	
	def self.RegisterNew(name, email, password)
		# $stmt_CreateUser = $db.prepare( "INSERT INTO users (name, email, password) VALUES (:name, :email, :password)" )
		
		begin
			# create new user
			$stmt_CreateUser.execute ({ :name => name, :email => email, :password => Digest::MD5.hexdigest(password) })
			
			# return user
			newUser = User.FromName name
			
			# create new default blog for user
			Blog.CreateNew newUser.id, "Default Blog", "This is your first blog. Have fun with it."
			
			# return new user
			return newUser
		rescue
			return nil
		end
	end
end