require 'sinatra'
require_relative 'Haikus'


enable :sessions


rhymingDictionary = Dictionary.new
rhymingDictionary.loadFromFile("cmudict.rep.txt")

haikus = HaikuBuilder.new(rhymingDictionary)

get '/' do 
	
	base = haikus.randomHaiku()
	@first = base.mutate(rhymingDictionary)
	@second = base.mutate(rhymingDictionary)
	@third = base.mutate(rhymingDictionary)
	
	session[1] = @first
	session[2] = @second
	session[3] = @third
	
	erb :poemDisplay
end

get /\A\/([123])/ do
	base = ""
	
	
	if(session[params['captures'].first.to_i].nil?)
		base = haikus.randomHaiku()
	else
		base = session[params['captures'].first.to_i]
	end
	
	@first = base.mutate(rhymingDictionary)
	@second = base.mutate(rhymingDictionary)
	@third = base.mutate(rhymingDictionary)
	
	session[1] = @first
	session[2] = @second
	session[3] = @third
	
	erb :poemDisplay
	
end






#puts rhymingDictionary.getRandomWordBySyllables(3)