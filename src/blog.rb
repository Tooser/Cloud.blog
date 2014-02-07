get '/blog/:blogid' do
	#
	# Allgemeine Blog Startseite
	#
	@blog = Blog.FromId params[:blogid]
	
	"Hier entsteht der Blog von " + @blog.user.name + "..."
end

get '/blog/post/:name' do
	#
	# Anzeige eines spezifischen Posts
	#
	
end

get '/blog/site/:name' do
	#
	# Anzeige einer spezifischen Seite
	#
	
end

get '/blog/posts' do
	#
	# Auflistung aller Posts?
	#
	
end