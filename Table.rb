require 'UI'
require 'Card'
require 'MultiDeck'
require 'Player'
require 'Dealer'

class Table

public

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

		# prompt each user until either busted or stands
		while(!player.busted? && !player.standing?)

			# print player hand information
			@ui.print_hand(player.name, player.hand, player.hand_value)

			# check for blackjack or full hand
			if (player.blackjack? or player.hand_value == BustLimit)
				break
			end

			# prompt for option and process
			card = nil
			case (@ui.prompt_options(player.can_double?,player.can_split?))
				when "h"
					card = @deck.pick
					player.deal(card)
				when "s"
					player.stand!
				when "d"
					player.double!
					card = @deck.pick
					player.deal(card)
					player.stand!
				else
			end # end case

			# inform UI
			@ui.print_card(card) unless card.nil?
			if (player.blackjack?)
				@ui.print_blackjack(player)
			elsif(player.hand_value == BustLimit)
				@ui.print_limit(player)
			elsif (player.busted?)
				@ui.print_busted(player.name, player.hand_value)
			elsif (player.standing?)
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
		if (player.busted? or (!@dealer.busted? and player.hand_value < @dealer.hand_value))
			winnings = -player.bet
			player.lose!
		# player's hand equals dealer's hand
		elsif (player.hand_value == @dealer.hand_value)
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
			winnings = Integer(player.bet*payoff)
			player.win!(payoff)
		end

		# convey to UI
		ui_player_results(player,winnings)
	end

	# plays with dealer until dealer goes bust
	# or soft limit is reached
	def play_with_dealer
		while(!@dealer.busted? && !@dealer.softlimit?)
			@dealer.deal(@deck.pick)
		end

		# convey to UI
		ui_dealer_results
	end

	# conveys dealer winnings to the UI
	def ui_dealer_results
		@ui.print_hand(@dealer.name, @dealer.hand, @dealer.hand_value)
		if (@dealer.busted?)
			@ui.print_dealerbust(@dealer.name)
		end
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
