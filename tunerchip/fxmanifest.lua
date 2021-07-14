fx_version 'cerulean'
game 'gta5'

description 'TunerChip omkodet af Olsen1157#6406'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'config.lua'
}

client_scripts {
    "lib/Tunnel.lua",
	"lib/Proxy.lua",
    'client/main.lua'
}
server_scripts {
	"@vrp/lib/utils.lua",
	"server/main.lua"
}


files {
    'html/*',
}