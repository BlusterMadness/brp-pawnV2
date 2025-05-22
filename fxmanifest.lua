
fx_version 'cerulean'

author 'Bluster_Madness'

game 'gta5'

client_scripts {
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
	'@mysql-async/lib/MySQL.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	
}

lua54 'yes'
