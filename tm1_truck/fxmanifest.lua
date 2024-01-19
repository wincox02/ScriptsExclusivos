fx_version 'adamant'
game 'gta5'

author 'wincox#2959'
version '1.0.0'
lua54 'yes'
description 'Trabajo Camionero (trucker)'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua',
}

client_scripts {
	'client/main.lua'
}


server_exports {
	'getPlayerFromId',
}