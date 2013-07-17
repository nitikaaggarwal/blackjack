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
	# @return [void]
	def play_game

		@new_game = true
		clear_all_hands

		@players.each{ |player| get_player_bets(player) }

		# deal two cards to dealer
		deal_dealer_cards

		# for each user play
		@players.each_index{ |i|
			split_player = play_with_player(@players[i])
			@players.insert(i+1,split_player) if split_player != nil
		}

		# play with dealer
		play_with_dealer

		# for each player, compute winnings
		@players.each_index{ |i|
			# if first hand of a split, then remove next player from
			# array and assign as the split player
			split_player = (@players[i].split? and @players[i].first_hand?) ? @players.delete_at(i+1) : nil
			compute_winnings(@players[i], split_player)
		}

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
		if (player.get_balance == 0)
			player.set_balance!(@Cash)
			@ui.print_nobalance(player.name, @LoanSharkName, @Cash)
		end

		# prompt and make bet
		init_player(player,@ui.prompt_bet(player.name,player.get_balance))

	end

	# This function contains most of the complex logic for playing Blackjack
	def play_with_player(player)

		# in case of a split, this will hold a split copy
		# of the player
		split_player = nil

		# if we're playing the second copy of a split
		@ui.print_second_split if !player.first_hand?

		# play until user goes bust
		while(player.hand_value < @BustLimit)

			# print current hand information
			@ui.print_hand(player.name, player.hand, player.hand_value)

			# prompt for options based on current state
			case (@ui.prompt_options(player.can_double?, player.can_split?))

				# hit
				when 'h'
					card = @deck.pick
					player.deal(card)

					@ui.print_card(card.type)
				# stand
				when 's'
					@ui.print_stand(player.name, player.hand_value)
					break
				# double
				when 'd'
					player.double!
					card = @deck.pick
					player.deal(card)

					@ui.print_card(card.type)
					@ui.print_hand(player.name, player.hand, player.hand_value) # FIXME: not happy with this call
					break
				# split
				when 't'
					split_player = player.split!
					card1 = @deck.pick
					card2 = @deck.pick
					player.deal(card1)
					split_player.deal(card2)

					@ui.print_split(card1.type,card2.type)
					# print that first hand will be played
					@ui.print_first_split
			end

		end

		player.stand!

		# check for blackjack
		@ui.print_blackjack if player.blackjack?
		# check for full hand sans blackjack
		@ui.print_limit(player.name) if (!player.blackjack? and player.hand_value == @BustLimit)
		# check if busted
		@ui.print_busted(player.name, player.hand_value) if player.busted?

		return split_player

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
	def compute_winnings(player,split_player=nil)

		winnings = compute_single_winnings(player) + compute_single_winnings(split_player)

		# convey to UI
		ui_player_results(player,winnings)
	end

	# plays with dealer until dealer goes bust
	# or soft limit is reached
	def play_with_dealer

		@ui.print_dealer_turn(@dealer.name)

		# if everyone is busted or has Blackjack, no need for dealer to play
		not_play = true
		@players.each { |player| not_play = false if (!player.busted? and !player.blackjack?) }

		while(!not_play and !@dealer.busted? and !@dealer.softlimit?)
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
		if (winnings == 0 && !player.split?)
			@ui.print_push(player.name)
		elsif (player.split?)
			@ui.print_split_winnings(player.name,winnings)
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

		@ui.print_balance(player.get_balance)
	end

	# compute winnings of one player
	def compute_single_winnings (player)

		winnings = 0

		if (player.nil?)
			return winnings
		end

		# player busted before dealer or player's hand's value
		# less than dealer's but dealer not busted
		# dealer win
		if (player.busted? or (!@dealer.busted? and player.hand_value < @dealer.hand_value) or (!player.blackjack? and dealer.blackjack?))
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

		return winnings

	end

end
