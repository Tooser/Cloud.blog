# encoding: UTF-8

class Post < Content
	def initialize(client, name='new')
		super('posts/', client, name)
		
		if name == 'new' then
			@raw_content = '
---
Title: Mein neuer Blogeintrag
CreatedAt: ' + Time.now.to_s + '
---

Mein neuer Blogtext, den ich jetzt ändern muss
'
		end
	end
	
	def self.GetList(client, count=10)
		posts = Array.new
		
		metadata = client.metadata('/posts/')			# Ordner-Inhalt herunterladen
		
		metadata["contents"].reverse.each do |file|		# Datei-Array umdrehen (reverse) und durch Liste iterieren
			if count <= 0 then
				break
			end
		
			posts.push Post.new client, File.basename(file["path"], ".*")
				
			count = count - 1
		end
		
		return posts
	end
end