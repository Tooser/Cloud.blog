#
# db.rb
#

require 'sqlite3'

# Creating Database object
$db = SQLite3::Database.new( "resources/db.sqlite" )
$db.results_as_hash = true

# Create Table if not exists
$db.execute("CREATE TABLE IF NOT EXISTS users (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR UNIQUE,
	email VARCHAR UNIQUE,
	password VARCHAR,
	session_id VARCHAR,
	created_at DATE DEFAULT (datetime('now','localtime'))
);")

$db.execute("CREATE TABLE IF NOT EXISTS blogs (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id INTEGER,
	access_token VARCHAR,
	title VARCHAR,
	description TEXT,
	created_at DATE DEFAULT (datetime('now','localtime'))
);")

# Creating prepared statements

# User statements
$stmt_UserById = $db.prepare( "SELECT * FROM users WHERE id = :user_id" )
$stmt_UserByName = $db.prepare( "SELECT * FROM users WHERE name = :name" )
$stmt_UserBySessionID = $db.prepare( "SELECT * FROM users WHERE session_id = :session_id" )
$stmt_AllUsers = $db.prepare( "SELECT * FROM users" )
$stmt_CreateUser = $db.prepare( "INSERT INTO users (name, email, password) VALUES (:name, :email, :password)" )

$stmt_UpdateSessionID = $db.prepare( "UPDATE users SET session_id = :session_id WHERE id = :user_id" )
$stmt_UpdatePassword = $db.prepare( "UPDATE users SET password = :password WHERE id = :user_id" )
$stmt_UpdateUserInfo = $db.prepare( "UPDATE users SET name = :name, email = :email WHERE id = :user_id" )

$stmt_CheckPassword = $db.prepare( "SELECT * FROM users WHERE id = :user_id" )


# Blog statements
$stmt_BlogById = $db.prepare( "SELECT * FROM blogs WHERE id = :blog_id" )
$stmt_BlogByUserId = $db.prepare( "SELECT * FROM blogs WHERE user_id = :user_id" )
$stmt_CreateBlog = $db.prepare( "INSERT INTO blogs (user_id, title, description) VALUES (:user_id, :title, :description)" )

$stmt_SetAccessToken = $db.prepare( "UPDATE blogs SET access_token = :access_token WHERE id = :blog_id" )