require 'Card'
require 'Player'

# @author Nitika Aggarwal
#
# This class represents a dealer in the
# game of Blackjack. It inherits functionalities
# from the {Player} class but hides unnecessary
# functions that are not required of a dealer.
# Additionally, it requires the {Card} class.
class Dealer < Player

	# @return [Integer] The soft dealer limit, typically 17
	attr_reader :softlimit

	# The constructor
	# @param name [String] The name of the dealer
	# @param bustlimit [Integer] The limit before dealer goes bust, typically 21
	# @param softlimit [Integer] The soft limit of the dealer, typically 17
	def initialize(name,bustlimit,softlimit)
		super(name,0,bustlimit)
		@softlimit = softlimit
	end

	# Check if upcard is ACE
	# to help detect insurance 3:2 payout
	# @return [Boolean] true iff upcard is ACE
	def upcard_ace?
		!@hand.empty? and @hand.first.type == :ACE
	end

	# Check if reached softlimit
	# @return [Boolean] true iff dealer has hit {Dealer::softlimit}
	def softlimit?
		hand_value >= softlimit
	end

	# Returns the dealer upcard unless hand is empty (should not happen)
	# @return [Card,nil] Dealer upcard unless hand is empty, in which case it returns nil
	def upcard
		if !hand.empty?
			hand[0]
		else
			nil
		end
	end

	# hide vestigial parent functions
	private :push!
	private :lose!
	private :win!
	private :double!
	private :make_bet?

end
