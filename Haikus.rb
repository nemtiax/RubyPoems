class Word
	def initialize(word, pronunciation)
			@word = word
			pronunciation.gsub!(/\s/,"")
			syllables = pronunciation.split("-")
			@numSyllables = syllables.length
			@rhymeKey = Word.analyzeRhyme(syllables)
			#puts "Word: #{@word}, Key: #{@rhymeKey}\n"
	end
	
	def self.analyzeRhyme(syllables)
		#syllableIndex = syllables.length-1
		#currentSyllable = syllables[syllableIndex]
		#key = currentSyllable.gsub(/\d/,"")
		#while(not (/1/ === currentSyllable)) 
		#	syllableIndex = syllableIndex - 1
		#	currentSyllable = syllables[syllableIndex]
		#	key = currentSyllable.gsub(/\d/,"") + "_" + key
		#end
		#return key
		return ""
	end
	
	def getWord
		return @word
	end
	
	def getNumSyllables
		return @numSyllables
	end
	
	def getRhymeKey
		return @rhymeKey
	end
	
	def to_s
		return @word
	end
	
end

class Dictionary
	def initialize()
		@syllablesMap = Hash.new
		@rhymeMap = Hash.new
	end
	def addWord(word) 
		if(not @syllablesMap.has_key? word.getNumSyllables)
			@syllablesMap[word.getNumSyllables] = []
		end
		@syllablesMap[word.getNumSyllables] << word
		
		if(not @rhymeMap.has_key? word.getRhymeKey)
			@rhymeMap[word.getRhymeKey] = []
		end
		@rhymeMap[word.getRhymeKey] << word
	end
	
	def getRandomWordBySyllables(n)
		puts "Request for random word with #{n} syllables\n"
		return @syllablesMap[n].sample
	end
	
	def loadFromFile(filename) 
		f = File.open(filename,"r")
		f.each_line do |line|
			if(/^##/ === line) 
				next
			end
			matchData = /^(.*?)(\(\d+\))?  (.*)$/.match(line)
			word = matchData[1]
			pronunciation = matchData[3]
			parsed = Word.new(word,pronunciation)
			addWord(parsed)
		
		end
	end
	
end

class HaikuBuilder
	
	def initialize(dict)
		@dictionary = dict
	end
	
	def randomHaiku()
		result = Haiku.new
		result.addLine(randomLine(5))
		result.addLine(randomLine(7))
		result.addLine(randomLine(5))
		return result
	end
	
	def randomLine(numSyllables)
		line = Line.new
		syllablesSoFar = 0
		while(syllablesSoFar<numSyllables)
			nextWord = @dictionary.getRandomWordBySyllables(rand(numSyllables - syllablesSoFar) + 1)
			line.addWord(nextWord)
			syllablesSoFar+=nextWord.getNumSyllables
		end
		return line
	end
	
end

class Line
	def initialize
		@words = []
		@numWords = 0
	end
	def addWord(word)
		@words << word
		@numWords+=1
	end
	def numWords
		return @numWords
	end
	def to_s
		#result = "==="
		result = ""
		@words.each do |word|
			result += word.getWord + " "
		end
		#result += "==="
		return result
	end
	def mutate(dictionary)
		
		mutationType = rand(3)
		if(mutationType==0)
			return replacementMutate(dictionary)
		end
		if(mutationType==1)
			return splitMutate(dictionary)
		end
		if(mutationType==2)
			return mergeMutate(dictionary)
		end
	end
	
	def mergeMutate(dictionary)
		mutant = Line.new
		wordToReplace = rand(@numWords)
		
		if(wordToReplace==@numWords-1)
			return replacementMutate(dictionary)
		end
		
		(0..@numWords-1).each do |i|
			if(i==wordToReplace)
				mutant.addWord(dictionary.getRandomWordBySyllables(@words[wordToReplace].getNumSyllables() + @words[wordToReplace+1].getNumSyllables()))
			elsif(i!=wordToReplace+1)
				mutant.addWord(@words[i])
			end
		end
		return mutant
	end
	
	def splitMutate(dictionary)
		mutant = Line.new
		wordToReplace = rand(@numWords)
		
		firstSyllables = rand(@words[wordToReplace].getNumSyllables)+1
		
		(0..@numWords-1).each do |i|
			if(i==wordToReplace)
				mutant.addWord(dictionary.getRandomWordBySyllables(firstSyllables))
				if(@words[i].getNumSyllables-firstSyllables>0)
					mutant.addWord(dictionary.getRandomWordBySyllables(@words[i].getNumSyllables-firstSyllables))
				end
			else
				mutant.addWord(@words[i])
			end
		end
		return mutant
	end
	
	def replacementMutate(dictionary)
		mutant = Line.new
		wordToReplace = rand(@numWords)
		(0..@numWords-1).each do |i|
			if(i==wordToReplace)
				mutant.addWord(dictionary.getRandomWordBySyllables(@words[i].getNumSyllables))
			else
				mutant.addWord(@words[i])
			end
		end
		return mutant
	end
	
	def clone
		copy = Line.new
		@words.each do |word|
			copy.addWord(word)
		end
		return copy
	end
	
end

class Haiku
	def initialize()
		@numWords = 0
		@lines = []
		@currentLine = 0
	end
	def addLine(line)
		@lines[@currentLine] = line
		@numWords += line.numWords
		nextLine()
	end
	def nextLine()
		@currentLine += 1
	end
	def numWords()
		return @numWords
	end
	def to_html
		puts @lines[0].to_s
		return @lines[0].to_s + "<br>" + @lines[1].to_s + "<br>" + @lines[2].to_s
	end
	
	def mutate(dictionary)
		lineToMutate = rand(3)
		result = Haiku.new
		(0..2).each do |line|
			if(line == lineToMutate)
				result.addLine(@lines[line].mutate(dictionary))
			else
				result.addLine(@lines[line].clone)
			end
		end
		return result
	end
	
	
end