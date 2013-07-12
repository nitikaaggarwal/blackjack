class UI

	def welcome(dealer_name)
		puts "Welcome to Hog's Head, Muggles!"
		puts "Your dealer today is #{dealer_name}"
		puts "Good luck and happy gambling!\n\n"
	end

	def prompt_num_players
		puts "Please enter number of players:"
		num_players = Integer(gets.chomp)
		puts ""
		num_players
	end

	def print_hand (name,hand,hand_value)

		puts "#{name}, your cards are:"
		hand.each{|card|
			puts card.type
		}
		puts "current hand value: #{hand_value.to_s}"
		puts ""

	end

	def prompt_cash
		puts "Please enter initial cash"
		cash = Integer(gets.chomp)
		puts ""
		cash
	end

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

	def print_card(card_type)
		puts "You were dealt: #{card_type}"
	end

	def print_busted(name,value)
		print "Tough luck, #{name}. You got busted with a score: #{value}\n\n"
	end

	def print_stand(name,value)
		print "#{name}, you are now standing at: #{value}\n\n"
	end

	def print_lose(name,bet)
		bet = -bet
		puts "#{name}, you lost $#{bet.to_s}"
	end

	def print_balance(balance)
		print "You now have $#{balance.to_s} remaining\n\n"
	end

	def print_push(name)
		puts "#{name}, your game ended in a push."
	end

	def print_win(name,bet)
		puts "Congratulations #{name}! You won $#{bet.to_s}!"
	end

	def print_insurance
		puts "The face card of dealer was an Ace! You get insurance on your payoff at 2:1."
	end

	def print_blackjack
		print "BLACKJACK! Your payoff increases to 3:2 unless dealer gets one too.\n\n"
	end

	def print_limit(name)
		print "Congratulations #{name}! You're unbeatable now!\n\n"
	end

	def print_dealer_bust(name)
		print "THE DEALER GOT BUSTED! Let's check if #{name} owes you.\n\n"
	end

	def print_upcard(cardtype,value)
		print "The dealer's upcard is: #{cardtype} valued at #{value.to_s}\n\n"
	end

	def print_exit
		print "\n\nExiting game. Avada Kedavra!\n\n"
	end

	def print_nobalance(player_name, shark_name, cash)
		puts "#{player_name}, it seems like you're out of cash."
		puts "Our loan shark, #{shark_name} will be happy to lend you $#{cash.to_s}."
		print "Use them well!\n\n"
	end

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

	def print_split(card_type, split_card_type)
		puts "You decided to split."
		puts "You were dealt #{card_type} for the first hand"
		print "You were dealt #{split_card_type} for the second hand\n\n"
	end

	def print_first_split
		print "**** Playing first split ****\n\n"
	end

	def print_second_split
		print "**** Playing second split ****\n\n"
	end

	def print_dealer_blackjack
		print "Your dealer got a BLACKJACK! You could be in trouble now!\n\n"
	end

	def print_dealer_turn(name)
		print "It's your dealer, #{name}'s turn now!\n\n"
	end

end
