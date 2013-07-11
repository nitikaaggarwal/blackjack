class UI

	def welcome(dealer_name)
		puts "Welcome to Hog's Head, Muggles!"
		puts "Your dealer today is #{dealer_name}"
		puts "Good luck and happy gambling!\n\n"
	end

	def prompt_numplayers
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
			puts "Enter an integral bet for player " + player_name + " no more than " + max_bet.to_s
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
		options_string = options_string + ", q - quit"


		begin
			# prompt the user
			puts options_string
	
			# get option
			op = gets.chomp

			# return value
			retval = ""
	
			# check for valid input
			if (op.eql? "h" or op.eql? "s" or (op.eql? "d" and double) or (op.eql? "t" and split) or op.eql? "q")
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

	def print_card(card)
		puts "You were dealt: #{card.type}"
	end

	def print_busted(name,value)
		print "Tough luck, #{name}. You got busted with a score: #{value}\n\n"
	end

	def print_stand(name,value)
		print "#{name}, you are now standing at: #{value}\n\n"
	end

	def print_lose(name,bet)
		puts "#{name}, you lost $#{bet.to_s}"
	end

	def print_balance(balance)
		print "You now have $#{balance.to_s} remaining\n\n"
	end

	def print_push(name,bet)
		puts "#{name}, your game ended in a push."
	end

	def print_win(name,bet)
		puts "Congratulations #{name}! You won your bet worth $#{bet.to_s}!"
	end

	def print_insurance
		puts "The face card of dealer was an Ace! You get insurance on your payoff at 2:1."
	end

	def print_blackjack
		puts "You have a Blackjack! Your payoff increases to 3:2."
	end

	def print_dealerbust(name)
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

end
