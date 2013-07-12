require 'Card'

class Player
	
	attr_accessor :balance
	attr_reader :bet
	attr_reader :split_bet
	attr_reader :hand
	attr_reader :split_hand

	# name of player
	attr_reader :name

	def initialize(name,balance,bustlimit)
		@balance = balance
		@bet = 0
		@split_bet = 0
		@hand = Array.new
		@split_hand = Array.new
		@BustLimit = bustlimit
		@name = name
		@standing = false
		@is_split = false
		@split_standing = false
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

	def standing?
		@standing
	end

	def can_split?
		if (hand.length == 2 and hand[0].value == hand[1].value)
			true
		else
			false
		end
	end

	def deal(card)
		@hand.push(card)
	end

	def busted?
		hand_busted?(@hand)
	end

	def lose!
		@bet = 0
	end

	def win!(payoff)
		@balance += Integer((1.0 + payoff)*@bet)
		@bet = 0
	end

	def push!
		@balance += @bet
		@bet = 0
	end

	def double!
		if can_double?
			@balance -= @bet
			@bet *= 2
		end
	end

	def can_double?
		@hand.length == 2 && @balance >= @bet
	end

	def stand!
		@standing = true
	end

	def blackjack?
		hand.length == 2 and hand_value == BustLimit
	end

	def hand_value
		evaluate_hand(@hand)
	end

	# this function effectively
	# resets the state of the object
	# for the next game, without
	# modifying the total available cash
	def clear_hand!
		# restore balances and bet
		# values in case user forgets
		# to call win, lose, push etc.
		@balance += (@bet + @split_bet)
		@bet = 0
		@split_bet = 0

		@standing = false
		@split_standing = false
		@is_split = false
		@hand = Array.new
		@split_hand = Array.new
	end

	# split the current player's hand
	# if possible, into two playing hands
	def split!
		if can_split?
			@split_hand.push(@hand.pop)
			@balance -= @bet
			@split_bet = @bet
			@is_split = true
		end
	end

	# check if the player has split hands
	def split?
		@is_split
	end

	# returns true iff split hand got blackjack
	def split_blackjack?
		@split_hand.length == 2 and split_hand_value == @BustLimit
	end

	# returns the value on the split hand
	def split_hand_value
		evaluate_hand(@split_hand)
	end

	def split_win!(payoff)
		@balance += Integer((1.0 + payoff)*@split_bet)
		@split_bet = 0
	end

	def split_lose!
		@split_bet = 0
	end

	def split_push!
		@balance += @split_bet
		@split_bet = 0
	end

	def split_double!
		if can_split_double?
			@balance -= @split_bet
			@split_bet *= 2
		end
	end

	def can_split_double?
		@split_hand.length == 2 && @balance >= @split_bet
	end

	def split_stand!
		@split_standing = true
	end

	def split_deal(card)
		@split_hand.push(card)
	end

	def split_busted?
		hand_busted?(@split_hand)
	end

	def split_standing?
		@split_standing
	end

private

	def hand_busted?(hand)
		evaluate_hand(hand) > @BustLimit
	end

	def evaluate_hand(hand)

		value = 0

		# extract aces
		num_aces = hand.find_all{|card| card.type == :ACE}.length

		# blindly add values
		# of all cards
		hand.each do |x|
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

end
