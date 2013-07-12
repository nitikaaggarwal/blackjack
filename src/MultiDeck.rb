require 'Card'

# @author Nitika Aggarwal
#
# This class is an infinitely replenishable
# deck of cards that can contain multiple
# packs of cards. It uses objects of type {Card}
class MultiDeck

	# The constructor
	# @param num_packs [Integer] The number of packs of card in the full deck
	def initialize(num_packs)

		@deck = Array.new
		@num_packs = num_packs

	end

	# Picks one card from the deck.
	# This repopulates the deck
	# if it is empty, effectively
	# giving us an infinite deck
	# @return [Card] A card from the deck
	def pick
		if @deck.length == 0
			populate
			@deck.shuffle!
		end

		@deck.shift
	end


	private
	# repopulate the deck
	def populate

		@deck = Array.new

		# add num_packs x 4 x 13 deck
		# or num_packs x 52 deck
		@num_packs.times do
			4.times do
				@deck.push(Card.new(:ACE))
				@deck.push(Card.new(:TWO))
				@deck.push(Card.new(:THREE))
				@deck.push(Card.new(:FOUR))
				@deck.push(Card.new(:FIVE))
				@deck.push(Card.new(:SIX))
				@deck.push(Card.new(:SEVEN))
				@deck.push(Card.new(:EIGHT))
				@deck.push(Card.new(:NINE))
				@deck.push(Card.new(:TEN))
				@deck.push(Card.new(:KING))
				@deck.push(Card.new(:QUEEN))
				@deck.push(Card.new(:JACK))
			end
		end
	end

end
