Name:		<PACKAGE_NAME>
Version:	%{version}
Release:	%(echo "%{release}" | cut -d '.' -f1)%{?dist}
Summary:	<PACKAGE_SUMMARY>
Group:		Applications/<PACKAGE_NAME>
License:	GPL
URL:		<PROD_URL>
Source0:	%{tarfile}
Requires:	<PACKAGE_REQUIRES> 


%description
<PACKAGE_DESCRIPTION>

%prep


%install
echo $RPM_BUILD_ROOT
( cd %{srcdir} && cp -af <SRC_DIRS> $RPM_BUILD_ROOT )

%clean
( cd $RPM_BUILD_ROOT && rm -rf <SRC_DIRS> )

%post

%postun

%files

