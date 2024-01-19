resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'giveautocommand'


server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
  'server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
  'utils.lua',
  'client.lua'
}

dependency 'es_extended'

export 'GeneratePlate'