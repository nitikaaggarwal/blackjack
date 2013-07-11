#!/usr/bin/ruby

require 'UI'
require 'Table'

	BustLimit = 21
	SoftLimit = 17
	InitCards = 2
	DealerName = "Lord Voldemort"
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
