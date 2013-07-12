require 'UI'
require 'Card'
require 'MultiDeck'
require 'Player'
require 'Dealer'

# @author Nitika Aggarwal
#
# This represents the table in a Blackjack
# game. Contains the players, dealer and
# deck of card. This takes care of the
# gameplay.
class Table

public

	# The constructor.
	# @param bustlimit [Integer] The limit before player goes bust, typically 21
	# @param softlimit [Integer] The soft limit which the dealer hand value must hit before stops dealing, typically 17
	# @param initcards [Integer] The initial number of cards to be dealt to players and dealer, typically 2
	# @param dealername [String] Name of the dealer
	# @param loansharkname [String] Name of the loan shark
	# @param cash [Integer] Starting cash with each player
	# @param numplayers [Integer] Number of players on the table
	# @param ui [UI] The pretty-print interface that it should use to print to console
	def initialize(bustlimit,softlimit,initcards,dealername,loansharkname,cash,numplayers,ui)
		# set variables
		@BustLimit = bustlimit
		@SoftLimit = softlimit
		@InitCards = initcards
		@DealerName = dealername
		@LoanSharkName = loansharkname
		@Cash = cash
		@ui = ui
		@new_game = true

		setup_table(numplayers)

	end

	# Plays one round of Blackjack with each player.
	# The balance at the end of the round becomes
	# the starting balance for the next round
	# @return [nil]
	def play_game

		@new_game = true
		clear_all_hands

		@players.each{ |player| get_player_bets(player) }

		# deal two cards to dealer
		deal_dealer_cards

		# for each user play
		@players.each{ |player| play_with_player(player) }

		# play with dealer
		play_with_dealer

		# for each player, compute winnings
		@players.each{ |player| compute_winnings(player) }

		# prompt for new game
		@new_game = @ui.prompt_new_game?

	end

	# Indicates whether players want to play another round
	# @return [Boolean] true iff players want to play another round
	def new_game?
		@new_game
	end


private

	def init_player(player,bet)
		player.make_bet?(bet)
		@InitCards.times{player.deal(@deck.pick)}
	end

	def setup_table(numplayers)

		# setup each user
		@players = Array.new
		for i in 1..numplayers
			@players.push(Player.new("player#{i.to_s}",@Cash,@BustLimit))
		end

		# create dealer
		@dealer = Dealer.new(@DealerName,@BustLimit,@SoftLimit)

		# setup deck, one deck per player
		@deck = MultiDeck.new(numplayers)

	end

	def get_player_bets(player)

		# check if player has enough balance
		# if not, lend some moolah
		if (player.balance == 0)
			player.balance = @Cash
			@ui.print_nobalance(player.name, @LoanSharkName, @Cash)
		end

		# prompt and make bet
		init_player(player,@ui.prompt_bet(player.name,player.balance))

	end

	def play_with_player(player)

		# enter loop if one of the following conditions is met:
		# 1. player is playing first hand
		# 2. player has split and is playing the second hand
		while((!player.busted? and !player.standing?) or (player.split? and !player.split_busted? and !player.split_standing?))

			playing_first_hand = !player.busted? and !player.standing?
			playing_second_hand = !playing_first_hand and player.split? and !player.split_busted? and !player.split_standing?

			# if user has split, inform which hand currently betting on
			if (playing_first_hand and player.split? and player.hand.length == @InitCards)
				@ui.print_first_split
			elsif (playing_second_hand and player.split_hand == @InitCards)
				@ui.print_second_split
			end

			# print player hand information
			if playing_first_hand
				@ui.print_hand(player.name, player.hand, player.hand_value)
			else
				@ui.print_hand(player.name, player.split_hand, player.split_hand_value)
			end

			# check for blackjack or full hand
			# if you're playing the first hand
			skip = false
			if playing_first_hand and (@dealer.blackjack? or player.blackjack? or player.hand_value == @BustLimit)
				skip = true
				player.stand!
			# if you're playing the second hand TODO: the extra if may not be necessary
			elsif playing_second_hand and (@dealer.blackjack? or player.split_blackjack? or player.split_hand_value == @BustLimit)
				skip = true
				player.split_stand!
			end

			# prompt for option and process
			just_split = false
			card = nil
			split_card = nil
			if !skip
				case (@ui.prompt_options(((playing_first_hand and player.can_double?) or (playing_second_hand and player.can_split_double?)),player.can_split?))
					when "h"
						card = @deck.pick
						playing_first_hand ? player.deal(card) : player.split_deal(card)
					when "s"
						playing_first_hand ? player.stand! : player.split_stand!
					when "d"
						playing_first_hand ? player.double! : player.split_double!
						card = @deck.pick
						playing_first_hand ? player.deal(card) : player.split_deal(card)
						playing_first_hand ? player.stand! : player.split_stand!
					when "t"
						player.split!
						card = @deck.pick
						split_card = @deck.pick
						player.deal(card)
						player.split_deal(split_card)
						just_split = true
					else
				end # end case
			end

			# inform UI

			# print current card unless we have elected to stand or
			# have just decided to split
			@ui.print_card(card.type) if !card.nil? and !just_split

			# check if user just split
			if just_split
				@ui.print_split(card.type,split_card.type)
			# check for blackjack
			elsif ((playing_first_hand and player.blackjack?) or (playing_second_hand and player.split_blackjack?))
				@ui.print_blackjack
			# check if user just hit the BustLimit
			elsif((playing_first_hand and player.hand_value == @BustLimit) or (playing_second_hand and player.split_hand_value == @BustLimit))
				@ui.print_limit(player.name)
			elsif ((playing_first_hand and player.busted?) or (playing_second_hand and player.split_busted?))
				@ui.print_busted(player.name, player.hand_value)
			elsif ((playing_first_hand and player.standing?) or (playing_second_hand and player.split_standing?))
				@ui.print_stand(player.name, player.hand_value)
				break
			end

		end # end while

	end

	def clear_all_hands
		# clear hands for each player
		@players.each{ |player| player.clear_hand!}
		# reset dealer
		@dealer.clear_hand!
	end

	def deal_dealer_cards
		# deal cards
		@InitCards.times{@dealer.deal(@deck.pick)}
		# convey to UI
		@ui.print_upcard(@dealer.upcard.type,@dealer.upcard.value)
	end


	# This function computes the player's winnings
	# depending upon it's own and the dealer's cards
	# A positive sign indicates a win for the player
	# Negative sign means a loss and 0 winnings
	# indicate a push
	def compute_winnings(player)

		winnings = 0

		# player busted before dealer or player's hand's value
		# less than dealer's but dealer not busted
		# dealer win
		if (player.busted? or (!@dealer.busted? and player.hand_value < @dealer.hand_value))
			winnings -= player.bet
			player.lose!
		# push
		elsif ((player.blackjack? and @dealer.blackjack?) or (!player.blackjack? and player.hand_value == @dealer.hand_value))
			player.push!
		# player wins
		else
			payoff = 1.0
			# insurance
			if (@dealer.upcard_ace?)
				payoff = 2.0
			# blackjack
			elsif (player.blackjack?)
				payoff = 1.5
			end
			winnings += Integer(player.bet*payoff)
			player.win!(payoff)
		end

		if (player.split?)
			# dealer win
			if (player.split_busted? or (!@dealer.busted? and player.split_hand_value < @dealer.hand_value))
				winnings -= player.split_bet
				player.split_lose!
			# player's hand equals dealer's hand
			elsif ((player.split_blackjack? and @dealer.blackjack?) or (!player.split_blackjack? and player.split_hand_value == @dealer.hand_value))
				player.split_push!
			# player wins
			else
				payoff = 1.0
				# insurance
				if (@dealer.upcard_ace?)
					payoff = 2.0
				# blackjack
				elsif (player.split_blackjack?)
					payoff = 1.5
				end
				winnings += Integer(player.split_bet*payoff)
				player.split_win!(payoff)
			end
		end

		# convey to UI
		ui_player_results(player,winnings)
	end

	# plays with dealer until dealer goes bust
	# or soft limit is reached
	def play_with_dealer

		@ui.print_dealer_turn(@dealer.name)

		# if everyone is busted, no need for dealer to play
		all_busted = true
		@players.each { |player|
			all_busted = false if (!player.busted? or (player.split? and !player.split_busted?))
		}

		while(!all_busted and !@dealer.busted? and !@dealer.softlimit?)
			@dealer.deal(@deck.pick)
		end

		# convey to UI
		ui_dealer_results
	end

	# conveys dealer winnings to the UI
	def ui_dealer_results
		@ui.print_hand(@dealer.name, @dealer.hand, @dealer.hand_value)
		@ui.print_dealer_blackjack if @dealer.blackjack?
		@ui.print_dealer_bust(@dealer.name) if @dealer.busted?
	end

	# convey player winnings to the UI
	def ui_player_results(player,winnings)
		if (winnings == 0)
			@ui.print_push(player.name)
		elsif (winnings < 0)
			@ui.print_lose(player.name, winnings)
		else
			# check for insurance, takes priority over blackjack
			# since it presents higher returns
			if @dealer.upcard_ace?
				@ui.print_insurance
			end
			@ui.print_win(player.name, winnings)
		end

		@ui.print_balance(player.balance)
	end

end
