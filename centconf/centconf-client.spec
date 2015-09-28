###############################################
# Centconf Client
# License GPL
#
###############################################

## Preamble Section-
Name: centconf-client
Version: 1.0
Release: 0
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-build
BuildArch: noarch
Docdir: %{_datadir}/doc
AutoReqProv: yes
License: GPL
Group: World/Centconf
Packager: Myops
URL: http://www.world.com
Summary: World Centconf Client
Vendor: World Centconf Client

%description
World Centconf Client used to sync files in World network.

## Preparation Section-
%prep
%setup -q -n %{name}-%{version}

## Build Section-
%build

## Install Section-
%install
install -Dpm 755 centconf-client.pl  ${RPM_BUILD_ROOT}/usr/local/bin/centconf-client.pl

# Build directory cleanup
%clean
rm -rf $RPM_BUILD_ROOT

## Files Section-
%files
%attr(-,root,root) /usr/local/bin/centconf-client.pl
#end 
