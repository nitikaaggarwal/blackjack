require 'Card'

class MultiDeck

	# constructor
	def initialize(num_decks)

		@deck = Array.new
		@num_decks = num_decks

	end

	# pick one card from the deck
	# this repopulates the deck
	# if it is empty, effectively
	# giving us an infinite deck
	def pick
		if @deck.length == 0
			populate
			@deck.shuffle!
		end

		@deck.shift
	end


	# repopulate the deck
	private
	def populate

		@deck = Array.new

		# add num_decks x 4 x 13 deck
		# or num_decks x 52 deck
		@num_decks.times do
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
