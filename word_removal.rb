def word_removal
  shorter = ""
  dictionary = File.readlines('./dictionary.txt').map(&:chomp)
  dictionary.each do |word|
    if word.length > 3
      shorter += "#{word}\n"
    end
  end
  File.write("./short_dictionary.txt", shorter)
end

word_removal