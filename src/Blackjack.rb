#!/usr/bin/ruby

# @author Nitika Aggarwal
# This is the main program that should be
# run to play the Blackjack game. This
# requires the use of classes {UI} and {Table}

require 'UI'
require 'Table'

	# @return [Integer] The limit beyond which a player or dealer goes bust
	BustLimit = 21
	# @return [Integer] The limit dealer must hit before it stops dealing to itself
	SoftLimit = 17
	# @return [Integer] The initial number of cards to be dealt to each player and dealer
	InitCards = 2
	# @return [String] Name of the dealer
	DealerName = "Lord Voldemort"
	# @return [String] Name of the loan shark
	LoanSharkName = "Lucius Malfoy"

	ui = UI.new

	# welcome message
	ui.welcome(DealerName)

	# prompt for number of users
	num_players = ui.prompt_num_players

	# prompt for initial cash
	cash = ui.prompt_cash

	# create table
	table = Table.new(BustLimit,SoftLimit,InitCards,DealerName,LoanSharkName,cash,num_players,ui)

	# play game
	while table.new_game?
		table.play_game
	end
