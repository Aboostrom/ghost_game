require "./player.rb"
require "./aiplayer.rb"
require "set"

class Game
  attr_reader :fragment, :current_player, :next_player, :losses

  def initialize(player_names)
    dictionary = File.readlines('./short_dictionary.txt').map(&:chomp)
    
    @players = []
    player_names.each do |player, type| 
      type ? @players << Player.new(player) : @players << AiPlayer.new(player)
    end
    @fragment = ""
    @dictionary = Set.new(dictionary)
    @current_player = @players[0]
    @next_player = @players[1]
    @previous_player = @players[-1]
    @losses = {}
    @players.each { |player| @losses[player] = 0 }
  end

  def print_losses
    puts "Current standings:"
    @losses.each do |player, losses|
      if losses == 0
        puts "#{player.player_name} currently has nothing!"
      else
        puts "#{player.player_name} currently has '#{convert_losses_to_ghost(losses)}'"
      end
    end
    puts
  end

  def convert_losses_to_ghost(num)
    i = 0
    loss_word = ""
    while i < num
      loss_word += "ghost"[i]
      i += 1
    end
    loss_word
  end

  def switch_player
    @current_player = @players.rotate![0]
    @next_player = @players[1]
    @previous_player = @players[-1]
  end

  def valid_play?(char)
    @dictionary.any? { |word| word.start_with?(@fragment + char) }
  end

  def complete_word?(char)
    @dictionary.include?(@fragment + char)
  end

  def players_still_in_count
    @players.count { |player| player.still_in }
  end

  def play_round
    while players_still_in_count > 1  
      if !current_player.still_in
        puts "It's ghost #{current_player.player_name}'s turn!"  
      else
        puts "It's #{current_player.player_name}'s turn!"
      end
      puts
      player_guess = @current_player.guess(@fragment, @players.count, @dictionary)
      valid = valid_play?(player_guess)
      complete = complete_word?(player_guess)
      @fragment += player_guess
      if !valid || complete
        if @current_player.still_in == true
          @losses[@current_player] += 1
          @current_player.still_in = false
          puts "#{@current_player.player_name} is out!"
        end
        if !valid
          puts "  '#{@fragment}' is not a valid fragment!"
          puts
        elsif complete
          puts "  The word was '#{@fragment}'"
          puts
        end
        @fragment = ""
      else
        puts "The fragment currently is '#{@fragment}'"
      end

      switch_player
    end

    winner = @players.select { |player| player.still_in }[0].player_name
    puts "#{winner} is the winner of this round!"
    puts
  end
  
  def game_loser?
    @losses.values.any? { |losses| losses == 5 }
  end

  def game_winner
    lowest = ["", 5]
    @losses.each do |player, losses|
      if lowest[1] > losses
        lowest = [player.player_name, losses]
      elsif lowest[1] == losses
        lowest.push(player.player_name, losses)
      end
    end
    lowest
  end

  def final_loser
    losers = []
    @losses.each do |player, losses|
      if losses == 5
        losers << player.player_name
      end
    end
    losers
  end

  def reset_players_still_in
    @players.each { |player| player.still_in = true }
  end

  def update_player_words
    @losses.each { |player, losses| player.ghost_check = convert_losses_to_ghost(losses) }
  end

  def run
    until game_loser?
      play_round

      print_losses

      update_player_words

      reset_players_still_in
    end

    losers = final_loser
    if losers.length == 1
      puts "#{losers[0]} just lost by getting 'ghost'"
    else
      all_losers = ""
      losers.each_with_index do |loser, i|
        if i == losers.length - 1
          all_losers += " #{loser} just lost by getting 'ghost'"
        else
          all_losers += "#{loser} and"
        end
      end
      puts all_losers
    end

    winner = game_winner
    if winner.length > 2 
      print "That means "
      i = 0
      while i < winner.length
        if i == winner.length - 2
          print " #{winner[i]} "
        else
          print "#{winner[i]} and"
        end
        i += 2
      end
      if winner[1] == 0
        print "tied for victory with a perfect score of zero losses!"
      elsif winner[1] == 1
        print "tied for victory with only #{winner[1]} loss!"
      else
        print "tied for victory with only #{winner[1]} losses!"
      end
      puts
    elsif winner[1] == 0
      puts "That means #{winner[0]} won the game with a perfect score of zero losses!"
    elsif winner[1] == 1
      puts "That means #{winner[0]} won the game with only #{winner[1]} loss!"
    else
      puts "That means #{winner[0]} won the game with only #{winner[1]} losses!"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  game = Game.new('Tom'=>true, 'Dick'=>true, 'Mary'=>true, 'Computer'=>false)
  game.run
end