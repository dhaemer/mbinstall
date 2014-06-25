#!/bin/bash

pushd `pwd`

cd ~

echo 'Make sure all versions in the file paths and package names are still'
echo 'correct and up to date.'
read -p 'ENTER to continue...'

echo
echo 'Installing Homebrew...'
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
echo 'export PATH=/usr/local/bin:$PATH' >>~/.bash_profile
brew doctor
brew update
brew upgrade

brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

echo
echo 'Installing base tools...'
brew install autoconf automake apple-gcc42
brew install git bash-completion
brew install wget
brew install nmap
brew install ack
brew install source-highlight
brew install tree

echo
echo 'Installing Apache'
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
brew tap homebrew/apache
brew install -v httpd22 --with-brewed-apr --with-brewed-openssl
[ ! -d ~/Projects ] && mkdir -pv ~/Projects
[ ! -d ~/Projects/logs ] && mkdir -pv ~/Projects/logs

# TODO with more and more usage of sneakers, I imagine this may go.
# brew install elasticsearch

echo
echo 'Installing PHP...'
brew tap homebrew/php
brew install php54 --with-mysql --with-intl --with-imap --with-apache
brew install php54-intl php54-xdebug php54-oauth php54-apc php54-mcrypt

cat >> $(brew --prefix)/etc/apache2/2.2/httpd.conf <<EOF
# Send PHP extensions to mod_php
AddHandler php5-script .php
AddType text/html .php
DirectoryIndex index.php index.html
EOF

sed -i '-default' "s|^;\(date\.timezone[[:space:]]*=\).*|\1 \"$(sudo systemsetup -gettimezone|awk -F"\: " '{print $2}')\"|; s|^\(memory_limit[[:space:]]*=\).*|\1 256M|; s|^\(post_max_size[[:space:]]*=\).*|\1 200M|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 100M|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|;" $(brew --prefix)/etc/php/5.4/php.ini

USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') cat >> $(brew --prefix)/etc/php/5.4/php.ini <<EOF
; PHP Error log
error_log = ${USERHOME}/Projets/logs/php-error_log
EOF

touch $(brew --prefix php54)/lib/php/.lock && chmod 0644 $(brew --prefix php54)/lib/php/.lock

echo
echo 'Installing PHP tooling...'
brew install phploc
brew install phpmd

echo
echo 'PEAR, play nice with the homebrew PHP...'
chmod -R ug+w `brew --prefix php54`/lib/php
pear config-set php_ini /usr/local/etc/php/5.4/php.ini
pear config-set auto_discover 1
pear update-channels
pear upgrade
pear channel-discover pear.phpunit.de
pear install --alldeps phpunit/phpunit PHP_Codesniffer
brew unlink php54
brew link php54
#echo 'If installed PEAR tools cannot be executed, add "`brew --prefix php54`/bin" to $PATH'
 
echo
echo 'Make "PSR-2" the default coding standard...'
phpcs --config-set default_standard PSR2

echo
echo 'Installing composer...'
curl -s https://getcomposer.org/composer.phar -o /usr/local/bin/composer
chmod +x /usr/local/bin/composer

echo 'Start Apache'
ln -sfv $(brew --prefix httpd22)/homebrew.mxcl.httpd22.plist ~/Library/LaunchAgents
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.httpd22.plist

#echo
#echo 'Installing dotfiles...'
#mkdir Projects && cd Projects
#rm -f .bashrc
#rm -f .bash_profile
#rm -f .gitconfig
#rm -f .inputrc
#git clone https://github.com/mathiasbynens/dotfiles.git && cd dotfiles && source bootstrap.sh
#cd ~

echo
echo 'Installing POW...'
echo 'export POW_DST_PORT=88' >> ~/.powconfig
sudo curl https://gist.github.com/soupmatt/1058580/raw/zzz_pow.conf -o /private/etc/apache2/other/zzz_pow.conf
sudo apachectl restart
curl get.pow.cx | sh

echo
echo 'Installing rbenv...'
brew install rbenv ruby-build

echo
echo 'Installing FE stuff...'
brew install node
sudo gem install scss-lint
npm install -g jslint
npm install -g bower
npm install -g gulp
npm install -g jslint
npm install -g gulp-scsslint --save-dev

echo
echo 'Grabbing virtual boxes... yeh, this could take a while'
mkdir 'VirtualBox VMs' && cd ~/VirtualBox VMs
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE7-Vista&parts=4&filename=VMBuild_20131127/VirtualBox/IE7_Vista/Mac/IE7.Vista.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE8-WinXP&parts=2&filename=VMBuild_20131127/VirtualBox/IE8_WinXP/Mac/IE8.WinXP.For.MacVirtualBox.part{1.sfx,2.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE9-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE9_Win7/Mac/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE10-Win8.1&parts=5&filename=VMBuild_20131127/VirtualBox/IE10_Win8/Mac/IE10.Win8.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE11-Win8.1&parts=4&filename=VMBuild_20140402/VirtualBox/IE11_Win8.1/Mac/IE11.Win8.1.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
cd ~

echo
echo 'Install manually:'
echo
echo '    - Mysql: http://www.mysql.com/downloads/mysql/'
echo '    - Chrome: https://www.google.com/intl/en/chrome/browser/'
echo '    - Fire Fox: http://www.mozilla.org/en-US/firefox/new/'
echo '    - Virtualbox: https://www.virtualbox.org/wiki/Downloads'
echo '    - Vagrant: http://www.vagrantup.com/downloads.html'
echo '    - iTerm2: http://www.iterm2.com/downloads'
echo '    - Sequel Pro: http://www.sequelpro.com/download/'
echo '    - Anvil: http://anvilformac.com/'
echo
echo '    - Sublime Text: http://www.sublimetext.com/2'
echo '    - Alfred: http://www.alfredapp.com/#download'
echo '    - LittleIpsum: http://littleipsum.com/'
echo
echo 'Finally, set up your git account:'
echo 'git config --global user.name "Your Name Here"'
echo 'git config --global user.email "firstname.lastname@group94.com"'

popd