require "set"
require "byebug"

class AiPlayer
  attr_reader :guessed, :player_name
  attr_accessor :still_in, :ghost_check
  
  def initialize(player_name)
    @player_name = player_name
    @guessed = ""
    @still_in = true
    @ghost_check = ""
  end
  
  def valid_play?(char, fragment, dictionary)
    dictionary.any? { |word| word.start_with?(fragment + char) }
  end

  def valid_options(fragment, dictionary)
    valid = []
    ("a".."z").to_a.each do |char|
      valid << char if valid_play?(char, fragment, dictionary)
    end
    valid
  end

  def non_ending_moves(fragment, dictionary)
    possibilities = []
    ("a".."z").to_a.each do |char|
      possibilities << char if valid_play?(char, fragment, dictionary) || complete_word?(char, fragment, dictionary)
    end
    possibilities
  end

  def complete_word?(char, fragment, dictionary)
    dictionary.include?(fragment + char)
  end

  def guess(fragment, players_total, dictionary)
    revised_dictionary = shorten_dictionary(dictionary)
    return ("a".."z").to_a.sample if fragment.length == 0
    options = non_ending_moves(fragment, revised_dictionary)
    final_options = winning_moves(options, fragment, revised_dictionary, players_total)
    final_options.sample
  end

  def shorten_dictionary(dictionary)
    shorter = Set.new
    shortest_word_version = "z"
    dictionary.each do |word|
      if word.start_with?(shortest_word_version) && word != shortest_word_version
        next
      else
        shortest_word_version = word
        shorter << word
      end
    end
    shorter
  end

  def winning_moves(options, fragment, dictionary, players_total)
    word_options_hash = Hash.new { |h, k| h[k] = Array.new(3) { [] } }
    options.each do |char|
      words = word_options_hash[char]
      dictionary.each do |word| 
        if word.start_with?(fragment + char) && (word.length - fragment.length - 1) % players_total == 0
          words[1] << word
        elsif word.start_with?(fragment + char) && (word.length - fragment.length - 1) % players_total != 0
          words[2] << word
        end
      end
      words[0] << words[2].length.to_f / (words[1].length + words[2].length)
    end
    best_letters = calculate_odds(word_options_hash)
    if best_letters[0].length == 0
      return valid_options(fragment, dictionary)
    end
    best_letters
  end
end

def calculate_odds(word_options)
  best_chance_num = 0
  best_chance_char = ""
  word_options.each do |char, num_and_words|
    if num_and_words[0][0] > best_chance_num
      best_chance_num = num_and_words[0][0]
      best_chance_char = char
    elsif num_and_words[0][0] == best_chance_num && best_chance_num > 0
      best_chance_char += char
    end
  end
  if best_chance_char.length > 1
    return best_chance_char.split("")
  end
  [best_chance_char]
end