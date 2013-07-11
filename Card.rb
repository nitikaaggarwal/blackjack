class Card

	# the card type, could be ace, king queen etc
	attr_reader :type

	# value ranges from 1 to 11, depending on type
	attr_reader :value

	# constructor
	def initialize(type)
		@type = type

		case @type
		when :ACE
			@value = 11
		when :TWO
			@value = 2
		when :THREE
			@value = 3
		when :FOUR
			@value = 4
		when :FIVE
			@value = 5
		when :SIX
			@value = 6
		when :SEVEN
			@value = 7
		when :EIGHT
			@value = 8
		when :NINE
			@value = 9
		when :TEN
			@value = 10
		when :KING
			@value = 10
		when :QUEEN
			@value = 10
		when :JACK
			@value = 10
		else
			@type = :ACE
			@value = 11
		end
	end

	# check if it's an ace
	def ace?
		@type == :ACE
	end

end
