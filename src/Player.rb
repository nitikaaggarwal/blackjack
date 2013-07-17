require 'Card'
require 'Balance'

# @author Nitika Aggarwal
#
# This class represents a player in the
# Blackjack game. A player has a main hand
# with which a normal game proceeds. It also
# has a split hand that should be populated when the
# player decides to split.
class Player
	
	# @return [Integer] The current bet
	attr_reader :bet
	# @return [Array<Card>] The current hand of the player
	attr_reader :hand
	# @return [<String>] Name of player
	attr_reader :name
	
	# The constructor
	# @param name [String] Name of the player
	# @param balance [Integer] The starting balance of the player
	# @param bustlimit [Integer] The limit after which the player goes bust, typically 21
	def initialize(name,balance,bustlimit)
		@bet = 0
		@hand = Array.new
		@BustLimit = bustlimit
		@name = name
		@standing = false
		@is_split = false
		@balance = Balance.new(balance)
		@first_hand = true
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
		if amount <= (@balance.balance + @bet)
			@balance.balance = @balance.balance + @bet - amount
			@bet = amount
			return true
		else
			return false
		end

	end

	# Tells if the player decided to stand with main hand
	# @return [Boolean] true iff player had decided to stand with main hand
	def standing?
		return @standing
	end

	# Tells if player has sufficient balance to split
	# @return [Boolean] true iff user has sufficient balance to split
	def can_split?
		if (!@is_split and @hand.length == 2 and @hand[0].value == @hand[1].value and can_double?)
			return true
		else
			return false
		end
	end

	# Deals a card to the player for the main hand
	# @param card [Card] The card dealt
	# @return [void]
	def deal(card)
		@hand.push(card)
	end

	# Tells if player has been busted on main hand
	# @return [Boolean] true iff player busted on main hand
	def busted?
		return hand_busted?(@hand)
	end

	# Indicates to player that current main bet was lost
	# @return [void]
	def lose!
		@bet = 0
	end

	# Indicates to player that current main bet was won with payoff
	# @param payoff [Double] Payoff for current main bet
	# @return [void]
	def win!(payoff)
		@balance.balance += Integer((1.0 + payoff)*@bet)
		@bet = 0
	end

	# Indicates to player that main game ended in a push
	# @return [void]
	def push!
		@balance.balance += @bet
		@bet = 0
	end

	# Indicates to player that the current main bet has doubled
	# @return [void]
	def double!
		if can_double?
			@balance.balance -= @bet
			@bet *= 2
		end
	end

	# Checks if player has sufficient balance to double the main bet
	# @return [Boolean] true iff balance is greater than current main bet
	def can_double?
		return (@hand.length == 2 and @balance.balance >= @bet)
	end

	# Indicates to player that it has decided to stand on the main bet
	# @return [void]
	def stand!
		@standing = true
	end

	# Checks if main hand has Blackjack
	# @return [Boolean] true iff main hand has Blackjack
	def blackjack?
		return (hand.length == 2 and hand_value == BustLimit)
	end

	# Returns the current value of the main hand.
	# This ensures that Aces are assigned the
	# appropriate value, depending on the total.
	# @return [Integer] Value of the main hand
	def hand_value
		return evaluate_hand(@hand)
	end

	# This function effectively
	# resets the state of the object
	# for the next game, without
	# modifying the total available cash
	# @return [void]
	def clear_hand!
		# restore balances and bet
		# values in case user forgets
		# to call win, lose, push etc.
		@balance.balance += @bet
		@bet = 0

		@standing = false
		@is_split = false
		@hand = Array.new
	end

	# Split the current player's hand
	# if possible, into two playing hands.
	# The split player it returns has the 
	# same bet and shares it's balance with
	# self
	# @return [Player,nil] The player with the split hand
	def split!
		p = nil
		if can_split?
			p = Player.new(@name,@balance.balance,@BustLimit)
			p.instance_variable_set(:@first_hand,false)
			@is_split = true
			p.instance_variable_set(:@is_split,true)
			p.instance_variable_set(:@balance,@balance)
			p.make_bet?(@bet)
			p.deal(hand.pop)
		end
		return p
	end

	# This is used to check if the player
	# is the first hand in a split
	# @return [Boolean] true iff self is not split or first hand in a split
	def first_hand?
		return @first_hand
	end

	# Check if the player has split hands
	# @return [Boolean] true iff player has split his hand
	def split?
		return @is_split
	end
	
	# Returns the current balance with the player
	# excluding the bet amount
	# @return [Integer] Balance
	def get_balance
		return @balance.balance
	end

	# Set the balance for the player
	# and resets the bet
	# @return [void]
	def set_balance!(value)
		@balance.balance = value
		@bet = 0 
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
