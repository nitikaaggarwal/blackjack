require 'Card'

class Player
	
	attr_accessor :balance
	attr_reader :bet
	attr_reader :standing
	attr_reader :hand

	# name of player
	attr_reader :name

	def initialize(name,balance,bustlimit)
		@balance = balance
		@bet = 0
		@hand = Array.new
		@BustLimit = bustlimit
		@name = name
		@standing = false
	end
	
	def make_bet?(amount)
		standing = false
		if amount <= (@balance + @bet)
			@balance = @balance + @bet - amount
			@bet = amount
			true
		else
			false
		end

	end


	def can_split?
		if (hand.length > 1 and hand[0].value == hand[1].value)
			true
		else
			false
		end
	end


	def deal(card)
		@hand.push(card)
	end

	def busted?
		hand_value > @BustLimit
	end

	def lose!
		@standing = false
		@bet = 0
	end

	def win!(payoff)
		@standing = false
		@balance += Integer((1.0 + payoff)*@bet)
		@bet = 0
	end

	def push!
		@standing = false
		@balance += @bet
		@bet = 0
	end

	def double?

		if @balance >= @bet 

			@balance -= @bet
			@bet *= 2
			true

		else
			false
		end

	end

	def stand!
		@standing = true
	end

	def blackjack?
		hand_value == BustLimit
	end

	def hand_value

		value = 0

		# extract aces
		num_aces = @hand.find_all{|card| card.type == :ACE}.length

		# blindly add values
		# of all cards
		@hand.each do |x|
			value += x.value
		end

		# subtract ace values
		# until you reach the
		# BustLimit, if possible
		while (value > @BustLimit and num_aces > 0)
			value -= 10
			num_aces -= 1
		end

		value
	end

	def clear_hand!
		@hand = Array.new
	end

end
