###############################################
# Centconf Server
# License GPL
#
###############################################

## Preamble Section-
Name: centconf-server
Version: 1.0
Release: 0
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-build
BuildArch: noarch
Docdir: %{_datadir}/doc
AutoReqProv: yes
License: GPL
Group: IndianGNU/Centconf
Packager: Myops
URL: http://indiangnu.org
Summary: Centconf Server
Vendor: Centconf Server

%description
Centconf Server used to sync files in network using cvs/svn repository.

## Preparation Section-
%prep
%setup -q -n %{name}-%{version}

## Build Section-
%build

## Install Section-
%install
install -Dm 755 centconf-client.pl  ${RPM_BUILD_ROOT}/home/centconf/centconf-client.pl
install -Dm 755 email-notification.pl	${RPM_BUILD_ROOT}/home/centconf/email-notification.pl
install -Dm 644 centconf.conf		${RPM_BUILD_ROOT}/home/centconf/centconf.conf
install -Dm 644 world_mon-db.sql		${RPM_BUILD_ROOT}/home/centconf/world_mon-db.sql
install -dm 755 module/			${RPM_BUILD_ROOT}/home/centconf/module/
install -dm 775 www/graph		${RPM_BUILD_ROOT}/home/centconf/www/graph/
install -dm 755 www/cgi/		${RPM_BUILD_ROOT}/home/centconf/www/cgi/
install -dm 755 www/css/		${RPM_BUILD_ROOT}/home/centconf/www/css/
install -dm 755 www/javascript/		${RPM_BUILD_ROOT}/home/centconf/www/javascript/
install -Dm 755 www/cgi/*.pl		${RPM_BUILD_ROOT}/home/centconf/www/cgi/
install -Dm 644 www/css/*.css		${RPM_BUILD_ROOT}/home/centconf/www/css/
install -Dm 644 module/*.pm		${RPM_BUILD_ROOT}/home/centconf/module/
/bin/cp -rf	www/images/		${RPM_BUILD_ROOT}/home/centconf/www/
install -Dm 644 www/javascript/*.js	${RPM_BUILD_ROOT}/home/centconf/www/javascript/
install -Dm 755 www/index.php		${RPM_BUILD_ROOT}/home/centconf/www/index.php
install -Dm 644 -o root -g root  centconf-server_httpd.conf  ${RPM_BUILD_ROOT}/etc/httpd/conf.d/centconf-server.conf

# Build directory cleanup
%clean
rm -rf $RPM_BUILD_ROOT

## Post Installation Section- 
%post 
chmod 755 /home/centconf/www /home/centconf/www/images /home/centconf/www/images/themes /home/centconf/www/images/themes/blue
chmod 755 /home/centconf/www/images/jwysiwyg /home/centconf/www/images/thickbox  /home/centconf/module
chown Myops:Myops -R /home/centconf/www /home/centconf/module
## Files Section-
%files
%attr(755,root,root) /home/centconf/centconf-client.pl
%attr(755,Myops,Myops) /home/centconf/email-notification.pl
%attr(644,Myops,Myops) /home/centconf/centconf.conf
%attr(644,Myops,Myops) /home/centconf/world_mon-db.sql
%attr(644,root,root) /etc/httpd/conf.d/centconf-server.conf
%attr(755,Myops,Myops) /home/centconf/www/index.php
%attr(755,Myops,Myops) /home/centconf/www/cgi/*
%attr(775,Myops,Myops) /home/centconf/www/graph/
%attr(644,Myops,Myops) /home/centconf/module/*
%attr(644,Myops,Myops) /home/centconf/www/css/*
%attr(644,Myops,Myops) /home/centconf/www/images/*
%attr(644,Myops,Myops) /home/centconf/www/javascript/*
#end 
