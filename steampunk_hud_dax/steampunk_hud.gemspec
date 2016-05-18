require 'rubygems'
Gem::Specification.new do |s|
	s.name			= "steampunk_hud_dax"
	s.version = '2.5.0'
	s.date = '2016-05-18'
	s.summary = "Steampunk Hud"
	s.description = "Uma hud com o visual steampunk"
	s.authors = ["Dax"]
	s.email = "dax-soft@live.com"
	## files
	files = []
	files += Dir.glob('./**/*')
	s.files = files
	s.homepage = "https://github.com/DaxSoft/RGSS3/tree/master/steampunk_hud_dax"
end
