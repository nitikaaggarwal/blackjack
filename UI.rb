require 'Card'

# @author Nitika Aggarwal
#
# This class contains methods that allow
# a {Table} object to write game progress
# to the console. I call it the pretty-print
# class
class UI

	# Prints the welcome message
	# @param dealer_name [String] Name of the dealer
	# @return [nil]
	def welcome(dealer_name)
		puts "Welcome to Hog's Head, Muggles!"
		puts "Your dealer today is #{dealer_name}"
		puts "Good luck and happy gambling!\n\n"
	end

	# Prompts for the number of players in the game
	# @return [Integer] Number of players on the table. Must be positive.
	def prompt_num_players
		puts "Please enter number of players:"
		num_players = Integer(gets.chomp)
		puts ""
		num_players
	end

	# Prints the hand of the player
	# @param name [String] Name of the player
	# @param hand [Array<Card>] The hand of the player
	# @param hand_value [Integer] Value of the hand
	# @return [nil]
	def print_hand (name,hand,hand_value)

		puts "#{name}, your cards are:"
		hand.each{|card|
			puts card.type
		}
		puts "current hand value: #{hand_value.to_s}"
		puts ""

	end

	# Prompts the player to enter the starting cash for each player
	# for the entire game
	# @return [Integer] Starting cash for each player. Must be positive.
	def prompt_cash
		puts "Please enter initial cash"
		cash = Integer(gets.chomp)
		puts ""
		cash
	end

	# Prompts the player to enter bet for current round
	# @param player_name [String] Name of player
	# @param max_bet [Integer] Maximum bettable amount
	# @return [Integer] Bet amount
	def prompt_bet(player_name, max_bet)
		bet = 0
		begin
			puts "Enter an integral bet for " + player_name + " no more than $" + max_bet.to_s
			inputstring = gets.chomp
			raise ArgumentError unless bet.is_a? Integer
			bet = Integer(inputstring)
			raise RangeError unless (bet <= max_bet and bet > 0)
		rescue RangeError
			puts "You can't bet more than you have!"
			retry
		rescue ArgumentError
			puts "I know you're drunk but bets can only be integers."
			retry
		end

		puts ""
		bet
	end

	# Prompts player with options for the current hand
	# @param double [Boolean] true iff player is allowed to double bet
	# @param split [Boolean] true iff player is allowed to split bet
	# @return [String] The string code for the option chosen. It is either h (hit), s (stand), d (double) or t (split).
	def prompt_options(double, split)

		# figure out options to present
		options_string = "h - hit, s - stand"
		if double
			options_string = options_string + ", d - double"
		end
		if split
			options_string = options_string + ", t - split"
		end

		begin
			# prompt the user
			puts options_string
	
			# get option
			op = gets.chomp

			# return value
			retval = ""
	
			# check for valid input
			if (op.eql? "h" or op.eql? "s" or (op.eql? "d" and double) or (op.eql? "t" and split))
				retval = op
			else
				raise ArgumentError, "Bummer! Choose from the options below"
			end
		rescue
			puts "Bummer! Choose from the options below"
			retry
		end

		retval

	end

	# Prints the current card
	# @param card_type [Constant] The type of card
	# @return [nil]
	def print_card(card_type)
		puts "You were dealt: #{card_type}"
	end

	# Prints a busted message for player
	# @param name [String] Name of player
	# @param value [Integer] Value of hand
	# @return [nil]
	def print_busted(name,value)
		print "Tough luck, #{name}. You got busted with a score: #{value}\n\n"
	end

	# Prints a message when player decided to stand
	# @param name [String] Name of player
	# @param value [Integer] Value of hand
	# @return [nil]
	def print_stand(name,value)
		print "#{name}, you are now standing at: #{value}\n\n"
	end

	# Prints a message when player loses
	# @param name [String] Name of player
	# @param bet [Integer] Bet value lost
	# @return [nil]
	def print_lose(name,bet)
		bet = -bet
		puts "#{name}, you lost $#{bet.to_s}"
	end

	# Prints balance with user
	# @param balance [Integer] Current user balance
	# @return [nil]
	def print_balance(balance)
		print "You now have $#{balance.to_s} remaining\n\n"
	end

	# Prints message when the bet ends in a push
	# @param name [String] Name of player
	# @return [nil]
	def print_push(name)
		puts "#{name}, your game ended in a push."
	end

	# Prints a message when player wins
	# @param name [String] Name of player
	# @param bet [Integer] Winning bet amount
	# @return [nil]
	def print_win(name,bet)
		puts "Congratulations #{name}! You won $#{bet.to_s}!"
	end

	# Prints message indicating player payoff has increased
	# if the dealer has received an Ace as the upcard
	# @return [nil]
	def print_insurance
		puts "The face card of dealer was an Ace! You get insurance on your payoff at 2:1."
	end

	# Prints a message if player gets a Blackjack
	# @return [nil]
	def print_blackjack
		print "BLACKJACK! Your payoff increases to 3:2 unless dealer gets one too.\n\n"
	end

	# Prints a message if current hand value of player is 21
	# @param name [String] Name of player
	# @return [nil]
	def print_limit(name)
		print "Congratulations #{name}! You're unbeatable now!\n\n"
	end

	# Prints message if dealer goes bust
	# @param name [String] Name of dealer
	# @return [nil]
	def print_dealer_bust(name)
		print "THE DEALER GOT BUSTED! Let's check if #{name} owes you.\n\n"
	end

	# Prints message that displays the dealer's upcard
	# @param cardtype [Constant] The type of card
	# @param value [Integer] Value of the upcard
	# @return [nil]
	def print_upcard(cardtype,value)
		print "The dealer's upcard is: #{cardtype} valued at #{value.to_s}\n\n"
	end

	# Prints message before game exits
	# @return [nil]
	def print_exit
		print "\n\nExiting game. Avada Kedavra!\n\n"
	end

	# Prints message when a player runs out of cash
	# @param player_name [String] Name of the player
	# @param shark_name [String] Name of the loan shark
	# @param cash [Integer] Cash lent by loan shark
	# @return [nil]
	def print_nobalance(player_name, shark_name, cash)
		puts "#{player_name}, it seems like you're out of cash."
		puts "Our loan shark, #{shark_name} will be happy to lend you $#{cash.to_s}."
		print "Use them well!\n\n"
	end

	# Prompts player if they want to start a new round
	# @return [Boolean] true iff player wants a new round
	def prompt_new_game?
		print "\n\nGame for another bet?\n"
		print "anything for yes, n for no\n"
		new_game = true

		if (gets.chomp.eql? "n")
			false
		end

		print "\n\n\n"
		new_game
	end

	# Prints a message when player decides to split
	# @param card_type [Constant] Card type dealt to first hand
	# @param split_card_type [Constant] Card type dealt to second hand
	# @return [nil]
	def print_split(card_type, split_card_type)
		puts "You decided to split."
		puts "You were dealt #{card_type} for the first hand"
		print "You were dealt #{split_card_type} for the second hand\n\n"
	end

	# Prints that player is playing for first split
	# @return [nil]
	def print_first_split
		print "**** Playing first split ****\n\n"
	end

	# Prints that player is playing for the second split
	# @return [nil]
	def print_second_split
		print "**** Playing second split ****\n\n"
	end

	# Prints message when dealer gets a Blackjack
	# @return [nil]
	def print_dealer_blackjack
		print "Your dealer got a BLACKJACK! You could be in trouble now!\n\n"
	end

	# Prints a message indicating that it's now the dealer's turn to play
	# @param name [String] Name of the dealer
	# @return [nil]
	def print_dealer_turn(name)
		print "It's your dealer, #{name}'s turn now!\n\n"
	end

end
