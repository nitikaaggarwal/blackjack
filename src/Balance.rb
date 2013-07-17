# @author Nitika Aggarwal
#
# It is a container class that stores an Integer
# value which allows different {Player} objects to 
# share balance for split bets.
class Balance

	# @return [Integer] The balance
	attr_accessor :balance

	# The constructor
	# @param balance [Integer] Initial value for the balance variable.
	# @return [nil]
	def initialize (balance=0)
		@balance = balance
	end

end
