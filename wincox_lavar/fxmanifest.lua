fx_version 'adamant'
game 'gta5'
version '1.0.0'
description ''
lua54 'yes'

description 'Lavar dinero by wincox'

server_scripts {
  'config.lua',
	'@mysql-async/lib/MySQL.lua',
  'server.lua'
}

client_scripts {
  'config.lua',
  'client.lua'
}
