fx_version 'cerulean'
games { 'gta5' }

author 'RipXolo'
description 'black market system babyy'
version '1.0.0'


client_scripts {
    'client/main.lua',
    'client/dealer.lua',
    '@oxmysql/lib/MySQL.lua'
}

server_script {
    'server/main.lua',
}

shared_scripts {
    'config.lua'

} 


ui_page 'HTML/index.html'
files {
    'HTML/*' ,
    'HTML/images/*'
}