class Player
  attr_reader :guessed, :player_name
  attr_accessor :still_in, :ghost_check

  def initialize(player_name)
    @player_name = player_name
    @guessed = ""
    @still_in = true
    @ghost_check = ""
  end

  
  def guess(fragment, players_total, dictionary)
    print "Enter a letter: "
    player_guess = gets.chomp
    until ("a".."z").to_a.include?(player_guess.downcase)
      print "Not a valid letter. Please enter a letter: "
      player_guess = gets.chomp
    end
    @guessed = player_guess.downcase
  end
end