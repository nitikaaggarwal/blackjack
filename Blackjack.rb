#!/usr/bin/ruby

require 'UI'
require 'Card'
require 'MultiDeck'
require 'Player'
require 'Dealer'


	BustLimit = 21
	SoftLimit = 17
	InitCards = 2
	DealerName = "Lord Voldemort"
	LoanSharkName = "Lucius Malfoy"

	ui = UI.new

	# print welcome message
	ui.welcome(DealerName)

	# prompt for number of users
	numplayers = ui.prompt_numplayers

	# prompt for initial cash
	cash = ui.prompt_cash

	# setup each user
	players = Array.new
	for i in 1..numplayers
		players.push(Player.new("player#{i.to_s}",cash,BustLimit))
	end

	# create dealer
	dealer = Dealer.new(DealerName,BustLimit,SoftLimit)

	# setup deck, one deck per player
	deck = MultiDeck.new(numplayers)

	# start game
	while (true) do
		# deal two cards to dealer
		InitCards.times{dealer.deal(deck.pick)}
		ui.print_upcard(dealer.upcard.type,dealer.upcard.value)

		# for each user get bet and deal two cards
		players.each{|player| 
			# check if player has enough balance
			# if not, lend some moolah
			if (player.balance == 0)
				player.balance = cash
				ui.print_nobalance(player.name, LoanSharkName, cash)
			end

			player.make_bet?(ui.prompt_bet(player.name,player.balance))
			InitCards.times{player.deal(deck.pick)}
		}

		# for each user play
		players.each{|player|

			first_turn = true

			# prompt each user until either busted or stands
			while(!player.busted? && !player.standing)
				ui.print_hand(player.name, player.hand, player.hand_value)
				# get player option
				op = ui.prompt_options(first_turn,player.can_split?)
				first_turn = false

				# process option
				case op
					when "h"
						card = deck.pick
						player.deal(card)
						ui.print_card(card)
					when "s"
						player.stand!
					when "d"
						player.double?
						card = deck.pick
						player.deal(card)
						player.stand!

						ui.print_card(card)
					when "q"
						ui.print_exit
						exit
					else
				end

				# check if busted
				if (player.busted?)
					ui.print_busted(player.name, player.hand_value)
				elsif (player.standing)
					ui.print_stand(player.name, player.hand_value)
					break
				end
			end
		}

		# deal cards to dealer until minimum value or bust
		while(!dealer.busted? && !dealer.softlimit?)
			dealer.deal(deck.pick)
		end
		ui.print_hand(dealer.name, dealer.hand, dealer.hand_value)
		if (dealer.busted?)
			ui.print_dealerbust(dealer.name)
		end

		# go to each player and check who wins
		players.each{ |player|
			if (player.busted? or (!dealer.busted? and player.hand_value < dealer.hand_value))
				# print lost
				ui.print_lose(player.name, player.bet)
				player.lose!
			elsif (player.hand_value == dealer.hand_value)
				# print push
				ui.print_push(player.name, player.bet)
				player.push!
			else
				# print won
				ui.print_win(player.name, player.bet)

				payoff = 1.0
				# insurance
				if (dealer.upcard_ace?)
					ui.print_insurance
					payoff = 2.0
				# blackjack
				elsif (player.blackjack?)
					ui.print_blackjack
					payoff = 1.5
				end
				player.win!(payoff)
			end

			ui.print_balance(player.balance)
			player.clear_hand!
		}

		dealer.clear_hand!

	end
