# encoding: UTF-8
#
# Superklasse für Posts und Sites

require 'dropbox_sdk'
require 'metadown'

class Content
	@directory = '/'
	attr_reader :name, :client, :raw_content, :metadata, :html_output
	
	def initialize(directory, client)
		@directory = directory
	
		# used for new Post
		@client = client
		
		# set default content
		@raw_content = ''
	end
	
	def initialize(directory, client, name)
		@directory = directory
		@name = name
		@client = client
	end
	
	def fetch_content
		# read raw content
		@raw_content = client.get_file('/' + @directory + name + '.md')
		
		render
	end
	
	def render
		# render content with Markdown
		md = Metadown.render(@raw_content)
		
		# save headers
		@metadata = md.metadata
		
		# save html output
		@html_output = md.output
	end
	
	def set_raw_content(raw_content)
		@raw_content = raw_content
		
		render
	end
	
	def generate_name	
		@name = @metadata["CreatedAt"].strftime('%Y%m%d%H%M-') + Content.MakeFriendlyTitle(@metadata["Title"])
	end
	
	def upload
		client.put_file '/' + @directory + @name + '.md', @raw_content, true	# Post-Datei hochladen/aktualisieren
	end
	
	def self.GetList(directory, client, count=10)
		contents = Array.new
		
		metadata = client.metadata('/' + directory)			# Ordner-Inhalt herunterladen
		
		metadata["contents"].reverse.each do |file|		# Datei-Array umdrehen (reverse) und durch Liste iterieren
			if count <= 0 then
				break
			end
		
			contents.push Content.new directory, client, File.basename(file["path"], ".*")
				
			count = count - 1
		end
		
		return contents
	end
	
	def self.MakeFriendlyTitle(title)
		return title.gsub(/[^\w\s_-]+/, '')
				.gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
				.gsub(/\s+/, '_')
	end
end