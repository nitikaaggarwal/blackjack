require 'Card'

# @author Nitika Aggarwal
#
# This class represents a player in the
# Blackjack game. A player has a main hand
# with which a normal game proceeds. It also
# has a split hand that should be populated when the
# player decides to split.
class Player
	
	# @return [Integer] The balance left with player, excluding the current bet
	attr_accessor :balance
	# @return [Integer] The current bet
	attr_reader :bet
	# @return [Integer] The current bet on the split hand, if the player has split
	attr_reader :split_bet
	# @return [Array<Card>] The current hand of the player
	attr_reader :hand
	# @return [Array<Card>] The current split hand of the player, if the player has split
	attr_reader :split_hand
	# @return [<String>] Name of player
	attr_reader :name

	# The constructor
	# @param name [String] Name of the player
	# @param balance [Integer] The starting balance of the player
	# @param bustlimit [Integer] The limit after which the player goes bust, typically 21
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

	# This function makes a bet of the given
	# amount with the {Dealer}. This returns
	# true or false depending on whether the
	# player has sufficient balance to make
	# the bet
	# @param amount [Integer] The bet amount
	# @return [Boolean] true iff total balance is no less than the bet
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

	# Tells if the player decided to stand with main hand
	# @return [Boolean] true iff player had decided to stand with main hand
	def standing?
		@standing
	end

	# Tells if player has sufficient balance to split
	# @return [Boolean] true iff user has sufficient balance to split
	def can_split?
		if (hand.length == 2 and hand[0].value == hand[1].value)
			true
		else
			false
		end
	end

	# Deals a card to the player for the main hand
	# @param card [Card] The card dealt
	# @return [nil]
	def deal(card)
		@hand.push(card)
	end

	# Tells if player has been busted on main hand
	# @return [Boolean] true iff player busted on main hand
	def busted?
		hand_busted?(@hand)
	end

	# Indicates to player that current main bet was lost
	# @return [nil]
	def lose!
		@bet = 0
	end

	# Indicates to player that current main bet was won with payoff
	# @param payoff [Double] Payoff for current main bet
	# @return [nil]
	def win!(payoff)
		@balance += Integer((1.0 + payoff)*@bet)
		@bet = 0
	end

	# Indicates to player that main game ended in a push
	# @return [nil]
	def push!
		@balance += @bet
		@bet = 0
	end

	# Indicates to player that the current main bet has doubled
	# @return [nil]
	def double!
		if can_double?
			@balance -= @bet
			@bet *= 2
		end
	end

	# Checks if player has sufficient balance to double the main bet
	# @return [Boolean] true iff balance is greater than current main bet
	def can_double?
		@hand.length == 2 and @balance >= @bet
	end

	# Indicates to player that it has decided to stand on the main bet
	# @return [nil]
	def stand!
		@standing = true
	end

	# Checks if main hand has Blackjack
	# @return [Boolean] true iff main hand has Blackjack
	def blackjack?
		hand.length == 2 and hand_value == BustLimit
	end

	# Returns the current value of the main hand.
	# This ensures that Aces are assigned the
	# appropriate value, depending on the total.
	# @return [Integer] Value of the main hand
	def hand_value
		evaluate_hand(@hand)
	end

	# This function effectively
	# resets the state of the object
	# for the next game, without
	# modifying the total available cash
	# @return [nil]
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

	# Split the current player's hand
	# if possible, into two playing hands
	# @return [nil]
	def split!
		if can_split?
			@split_hand.push(@hand.pop)
			@balance -= @bet
			@split_bet = @bet
			@is_split = true
		end
	end

	# Check if the player has split hands
	# @return [Boolean] true iff player has split his hand
	def split?
		@is_split
	end

	# Checks if player got Blackjack on split hand
	# @return [Boolean] true iff split hand got Blackjack
	def split_blackjack?
		@split_hand.length == 2 and split_hand_value == @BustLimit
	end

	# Returns the current value of the split hand.
	# This ensures that Aces are assigned the
	# appropriate value, depending on the total.
	# @return [Integer] Value of the split hand
	def split_hand_value
		evaluate_hand(@split_hand)
	end

	# Indicates to player that current split bet was won with payoff
	# @param payoff [Double] Payoff for current split bet
	# @return [nil]
	def split_win!(payoff)
		@balance += Integer((1.0 + payoff)*@split_bet)
		@split_bet = 0
	end

	# Indicates to player that current split bet was lost
	# @return [nil]
	def split_lose!
		@split_bet = 0
	end

	# Indicates to player that split game ended in a push
	# @return [nil]
	def split_push!
		@balance += @split_bet
		@split_bet = 0
	end

	# Indicates to player that the current split bet has doubled
	# @return [nil]
	def split_double!
		if can_split_double?
			@balance -= @split_bet
			@split_bet *= 2
		end
	end

	# Checks if player has sufficient balance to double the split bet
	# @return [Boolean] true iff balance is greater than current split bet
	def can_split_double?
		@split_hand.length == 2 and @balance >= @split_bet
	end

	# Indicates to player that it has decided to stand on the split bet
	# @return [nil]
	def split_stand!
		@split_standing = true
	end

	# Deals a card to the player for the split hand
	# @param card [Card] The card dealt
	# @return [nil]
	def split_deal(card)
		@split_hand.push(card)
	end

	# Tells if player has been busted on split hand
	# @return [Boolean] true iff player busted on split hand
	def split_busted?
		hand_busted?(@split_hand)
	end

	# Tells if the player decided to stand with split hand
	# @return [Boolean] true iff player had decided to stand with split hand
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
