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

echo
echo 'Installing base tools...'
brew install autoconf automake apple-gcc42
brew install git bash-completion

# Add git completion to your bash file
cat >> ~/.bash_profile <<EOF
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
EOF

brew install wget
brew install nmap
brew install ack
brew install source-highlight
brew install tree

echo
echo 'Installing Apache'
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
brew tap homebrew/apache
## --with-brewed-apr --with-brewed-openssl
brew install -v httpd22 
[ ! -d ~/Projects ] && mkdir -pv ~/Projects
[ ! -d ~/Projects/logs ] && mkdir -pv ~/Projects/logs
[ ! -d ~/Projects/config ] && mkdir -pv ~/Projects/config
USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') cat >> /usr/local/etc/apache2/2.2/httpd.conf <<EOF
DocumentRoot "${USERHOME}/Projects"
ErrorLog "${USERHOME}/Projects/logs/apache2_error_log"
EOF

echo 'Start Apache'
ln -sfv /usr/local/opt/httpd22/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.httpd22.plist

echo
echo 'Installing elasticsearch...'
brew install elasticsearch

echo
echo 'Installing PHP...'
brew tap homebrew/php
brew install php54 --with-mysql --with-imap --with-apache
brew install php54-intl php54-xdebug php54-oauth php54-apc php54-mcrypt

[ ! -d /usr/local/etc/apache2/2.2/other ] && mkdir -pv /usr/local/etc/apache2/2.2/other
cat >> $(brew --prefix)/etc/apache2/2.2/httpd.conf <<EOF

# Send PHP extensions to mod_php
LoadModule php5_module    /usr/local/opt/php54/libexec/apache2/libphp5.so
AddHandler php5-script .php
AddType text/html .php
DirectoryIndex index.php index.html

# Use port 80 instead of 8080
Listen 80
NameVirtualHost *:80

# Local dev environment so we can enable these options
<VirtualHost *:80>
        ServerName localhost
        DocumentRoot ${USERHOME}/Projects
        VirtualDocumentRoot ${USERHOME}/Projects

        <Directory ${USERHOME}/Projects>
                Options Indexes FollowSymLinks
                AllowOverride all
                Order deny,allow
                Allow from all
        </Directory>
</VirtualHost>

# Include all the other domain conf files
Include /usr/local/etc/apache2/2.2/other/*.conf

# Set doc root to your personal folder
DocumentRoot "${USERHOME}/Projects"

# Run httpd as a different user and group
User $(whoami)
Group admin

# Use this servername for doc root, just in case
ServerName localhost
EOF

sed -i '-default' "s|^;\(date\.timezone[[:space:]]*=\).*|\1 \"$(sudo systemsetup -gettimezone|awk -F"\: " '{print $2}')\"|; s|^\(memory_limit[[:space:]]*=\).*|\1 256M|; s|^\(post_max_size[[:space:]]*=\).*|\1 200M|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 100M|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|;" $(brew --prefix)/etc/php/5.4/php.ini

cat >> $(brew --prefix)/etc/php/5.4/php.ini <<EOF
; PHP Error log
error_log = ${USERHOME}/Projects/logs/php_error_log
EOF
ln -s /usr/local/etc/php/5.4/php.ini ~/Projects/config/php.ini
ln -s /usr/local/etc/apache2/2.2/httpd.conf ~/Projects/config/httpd.conf
ln -s /usr/local/etc/apache2/2.2/other/ ~/Projects/config/vhosts
ln -s /etc/hosts ~/Projects/config/hosts
sudo chmod 0777 /etc/hosts

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
pear upgrade --force
pear channel-discover pear.phpunit.de
pear install --alldeps phpunit/phpunit PHP_Codesniffer
brew unlink php54
brew link php54
touch $(brew --prefix php54)/lib/php/.lock && chmod 0644 $(brew --prefix php54)/lib/php/.lock

echo
echo 'Make "PSR-2" the default coding standard...'
phpcs --config-set default_standard PSR2

echo
echo 'Installing composer...'
curl -s https://getcomposer.org/composer.phar -o /usr/local/bin/composer
chmod +x /usr/local/bin/composer

#echo
#echo 'Installing dotfiles...'
#[ ! -d ~/Projects/config/dotfiles ] && mkdir -pv ~/Projects/config/dotfiles
#rm -f .bashrc
#rm -f .bash_profile
#rm -f .gitconfig
#rm -f .inputrc
#git clone https://github.com/mathiasbynens/dotfiles.git && ~/Projects/config/dotfiles && source bootstrap.sh
#cd ~

echo
echo 'Installing rbenv...'
brew install rbenv ruby-build

echo
echo 'Installing FE stuff...'
brew install node
sudo gem install scss-lint
npm install -g jslint
npm install -g bower
npm install -g jslint
npm install -g gulp

echo
echo 'Installing (almost all) gulp modules...'
npm install gulp-util --save-dev
npm install gulp-changed --save-dev
npm install gulp-livereload --save-dev
npm install gulp-jshint --save-dev
npm install jshint-stylish --save-dev
npm install gulp-concat --save-dev
npm install gulp-uglify --save-dev
npm install gulp-imagemin --save-dev
npm install gulp-sass --save-dev
npm install gulp-scss-lint --save-dev
npm install gulp-scsslint --save-dev
npm install gulp-csslint --save-dev
npm install gulp-minify-css --save-dev
npm install gulp-autoprefixer --save-dev

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
echo '    - Java Runtime Environment (JRE): http://www.oracle.com/technetwork/java/javase/downloads/index.html'
echo '    - Chrome: https://www.google.com/intl/en/chrome/browser/'
echo '    - Fire Fox: http://www.mozilla.org/en-US/firefox/new/'
echo '    - Virtualbox: https://www.virtualbox.org/wiki/Downloads'
echo '    - Vagrant: http://www.vagrantup.com/downloads.html'
echo '    - iTerm2: http://www.iterm2.com/downloads'
echo '    - Sequel Pro: http://www.sequelpro.com/download/'
echo
echo '    - Sublime Text: http://www.sublimetext.com/2'
echo '    - Alfred: http://www.alfredapp.com/#download'
echo '    - LittleIpsum: http://littleipsum.com/'
echo
echo 'Finally, set up your git account:'
echo 'git config --global user.name "Your Name Here"'
echo 'git config --global user.email "firstname.lastname@group94.com"'

popd