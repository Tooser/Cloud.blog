# encoding: UTF-8

class Site < Content
	
	def initialize(client, name='new')
		super('sites/', client, name)
		
		if name == 'new' then
			@raw_content = '
---
Title: Meine neue Seite
CreatedAt: ' + Time.now.to_s + '
---

Mein Seitentext
'
		end
	end
	
	def generate_name	
		@name = Content.MakeFriendlyTitle(@metadata["Title"])
	end
	
	def self.GetList(client, count=10)
		sites = Array.new
		
		metadata = client.metadata('/sites/')			# Ordner-Inhalt herunterladen
		
		metadata["contents"].reverse.each do |file|		# Datei-Array umdrehen (reverse) und durch Liste iterieren
			if count <= 0 then
				break
			end
		
			sites.push Site.new client, File.basename(file["path"], ".*")
				
			count = count - 1
		end
		
		return sites
	end
end