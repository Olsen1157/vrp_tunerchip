--   ____  _       _____ ______ _   _ __ __ _____ ______  _  _     __ _  _    ___    __  
--  / __ \| |     / ____|  ____| \ | /_ /_ | ____|____  || || |_  / /| || |  / _ \  / /  
-- | |  | | |    | (___ | |__  |  \| || || | |__     / /_  __  _|/ /_| || |_| | | |/ /_  
-- | |  | | |     \___ \|  __| | . ` || || |___ \   / / _| || |_| '_ \__   _| | | | '_ \ 
-- | |__| | |____ ____) | |____| |\  || || |___) | / / |_  __  _| (_) | | | | |_| | (_) |
--  \____/|______|_____/|______|_| \_||_||_|____/ /_/    |_||_|  \___/  |_|  \___/ \___/ 

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
