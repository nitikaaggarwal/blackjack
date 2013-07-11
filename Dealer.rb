require 'Card'
require 'Player'

class Dealer < Player

	attr_reader :softlimit

	def initialize(name,bustlimit,softlimit)
		super(name,0,bustlimit)
		@softlimit = softlimit
	end

	# check if upcard is ACE
	# to detect insurance 3:2 payout
	def upcard_ace?
		!@hand.empty? and @hand.first.type == :ACE
	end

	# check if reached softlimit
	def softlimit?
		hand_value >= softlimit
	end

	# hide vestigial parent functions
	private :push!
	private :lose!
	private :win!
	private :double?
	private :make_bet?

end
