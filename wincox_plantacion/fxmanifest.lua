fx_version 'adamant'
game 'gta5'
version '1.0.0'
description ''

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server.lua'
}

client_scripts {
	'config.lua',
	'client.lua'
}

dependency 'es_extended'

files {
	'/html/**'
}

ui_page "html/index.html"