#!/bin/bash

pushd `pwd`

cd ~

echo
echo 'Install manually:'
echo
echo '    - Mysql: http://www.mysql.com/downloads/mysql/'
echo '    - Chrome: https://www.google.com/intl/en/chrome/browser/'
echo '    - Fire Fox: http://www.mozilla.org/en-US/firefox/new/'
echo '    - Virtualbox: https://www.virtualbox.org/wiki/Downloads'
echo '    - Vagrant: http://www.vagrantup.com/downloads.html'
echo '    - iTerm2: http://www.iterm2.com  (http://code.google.com/p/iterm2/downloads/list)'
echo '    - Sequel Pro: http://www.sequelpro.com/download/'
echo
echo '    - Sublime Text: http://www.sublimetext.com/2'
echo '    - Alfred: http://www.alfredapp.com/#download'
echo '    - LittleIpsum: http://littleipsum.com/'
echo
echo 'Make sure all versions in the file paths and package names are still'
echo 'correct and up to date.'
read -p 'ENTER to continue...'
echo

echo 'Installing Homebrew...'
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
brew doctor
brew update
brew upgrade

brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

echo 'Installing base tools...'
brew install autoconf automake apple-gcc42
brew install git bash-completion
brew install wget
brew install nmap
brew install ack
brew install source-highlight
brew install tree
brew install jsl

# TODO with more and more usage of sneakers, I imagine this may go.
brew install elasticsearch

echo 'Installing PHP...'
brew install php54 --with-mysql --with-intl --with-imap
brew install php54-intl php54-xdebug php54-oauth php54-apc

echo 'Installing PHP tooling...'
brew install phploc
brew install phpmd

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
 
echo 'Make "PSR-2" the default coding standard...'
phpcs --config-set default_standard PSR2

echo 'Installing composer...'
curl -s https://getcomposer.org/composer.phar -o /usr/local/bin/composer
chmod +x /usr/local/bin/composer

echo 'Installing dotfiles...'
mkdir Projects
cd Projects
rm -f .bashrc
rm -f .bash_profile
rm -f .gitconfig
rm -f .inputrc
git clone https://github.com/mathiasbynens/dotfiles.git && cd dotfiles && source bootstrap.sh
cd ~

echo 'Installing rbenv...'
brew install rbenv ruby-build

echo 'Installing FE stuff...'
brew install node
gem install scss-lint
npm install -g bower
npm install -g gulp
npm install gulp-scsslint --save-dev

echo 'Grabbing virtual boxes... yeh, this could take a while'
mkdir VirtualBox VMs
cd ~/VirtualBox VMs
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE7-Vista&parts=4&filename=VMBuild_20131127/VirtualBox/IE7_Vista/Mac/IE7.Vista.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE8-WinXP&parts=2&filename=VMBuild_20131127/VirtualBox/IE8_WinXP/Mac/IE8.WinXP.For.MacVirtualBox.part{1.sfx,2.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE9-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE9_Win7/Mac/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE10-Win8.1&parts=5&filename=VMBuild_20131127/VirtualBox/IE10_Win8/Mac/IE10.Win8.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"
#curl -O -L "http://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE11-Win8.1&parts=4&filename=VMBuild_20140402/VirtualBox/IE11_Win8.1/Mac/IE11.Win8.1.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
cd ~

popd