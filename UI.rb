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
			puts "Enter bet for player " + player_name + " no more than " + max_bet.to_s
			bet = Integer(gets.chomp)
			raise ArgumentError unless bet <= max_bet
		rescue
			puts "You can't bet more than you have!"
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

	def print_card(card)
		puts "You were dealt: #{card.type}"
	end

	def print_busted(name,value)
		print "Tough luck, #{name}. You got busted: #{value}!\n\n"
	end

	def print_stand(name,value)
		print "#{name}, you are now standing at: #{value}\n\n"
	end

end
