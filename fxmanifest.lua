fx_version 'cerulean'
game 'gta5'

author 'Panchuuu'
description 'Sistema de Bandas y Mafias para ESX con ox_lib'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua' -- IMPORTANTE para inicializar ox_lib
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/bandas.lua'
}

client_scripts {
    'client/main.lua',
    'client/panel.lua'
}

dependencies {
    'ox_lib'
}

