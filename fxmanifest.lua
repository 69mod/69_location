fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '69'
version '1.0.0'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib'
}

shared_script '@es_extended/imports.lua'