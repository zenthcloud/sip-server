#
# Asterisk -- An open source telephony toolkit.
#
# Top level Makefile
#
# Copyright (C) 1999-2010, Digium, Inc.
#
# Mark Spencer <markster@digium.com>
#
# This program is free software, distributed under the terms of
# the GNU General Public License
#

# All Makefiles use the following variables:
#
# ASTCFLAGS - compiler options provided by the user (if any)
# _ASTCFLAGS - compiler options provided by the build system
# ASTLDFLAGS - linker flags (not libraries) provided by the user (if any)
# _ASTLDFLAGS - linker flags (not libraries) provided by the build system
# LIBS - additional libraries, at top-level for all links,
#      on a single object just for that object
# SOLINK - linker flags used only for creating dynamically loadable modules
#          as .so files
# DYLINK - linker flags used only for creating shared libraries
#          (.so files on Unix-type platforms, .dylib on Darwin)
#
# Values for ASTCFLAGS and ASTLDFLAGS can be specified in the
# environment when running make, as follows:
#
#	$ ASTCFLAGS="-Werror" make ...
#
# or as a variable value on the make command line itself:
#
#	$ make ASTCFLAGS="-Werror" ...

export ASTTOPDIR		# Top level dir, used in subdirs' Makefiles
export ASTERISKVERSION
export ASTERISKVERSIONNUM

#--- values used for default paths

# DESTDIR is the staging (or final) directory where files are copied
# during the install process. Define it before 'export', otherwise
# export will set it to the empty string making ?= fail.
# Trying to run asterisk from the DESTDIR is completely unsupported
# behavior.
# WARNING: do not put spaces or comments after the value.
DESTDIR?=$(INSTALL_PATH)
export DESTDIR

export INSTALL_PATH       # Additional prefix for the following paths
export ASTCACHEDIR
export ASTETCDIR          # Path for config files
export ASTVARRUNDIR
export ASTSPOOLDIR
export ASTVARLIBDIR
export ASTDATADIR
export ASTDBDIR
export ASTLOGDIR
export ASTLIBDIR
export ASTMODDIR
export ASTMANDIR
export ASTHEADERDIR
export ASTSBINDIR
export AGI_DIR
export ASTCONFPATH
export ASTKEYDIR

export OSARCH             # Operating system

export NOISY_BUILD        # Used in Makefile.rules
export MENUSELECT_CFLAGS  # Options selected in menuselect.
export AST_DEVMODE        # Set to "yes" for additional compiler
                          # and runtime checks
export AST_DEVMODE_STRICT # Enables shadow warnings (-Wshadow)

export _SOLINK            # linker flags for all shared objects
export SOLINK             # linker flags for loadable modules
export DYLINK             # linker flags for shared libraries

#--- paths to various commands
# The makeopts include below tries to set these if they're found during
# configure.
export CC
export CXX
export AR
export RANLIB
export HOST_CC
export BUILD_CC
export INSTALL
export STRIP
export DOWNLOAD
export AWK
export GREP
export MD5
export WGET_EXTRA_ARGS
export LDCONFIG
export LDCONFIG_FLAGS
export PYTHON
export TAR
export PATCH
export SED
export NM
export FIND
export BASENAME
export DIRNAME
export XMLLINT
export XMLSTARLET

# makeopts is required unless the goal is just {dist{-}}clean
ifeq ($(MAKECMDGOALS),clean)
else ifeq ($(MAKECMDGOALS),distclean)
else ifeq ($(MAKECMDGOALS),dist-clean)
else
include makeopts
endif

# start the primary CFLAGS and LDFLAGS with any that were provided
# to the configure script
_ASTCFLAGS:=$(CONFIG_CFLAGS) $(CONFIG_SIGNED_CHAR)
_ASTLDFLAGS:=$(CONFIG_LDFLAGS)

# Some build systems, such as the one in openwrt, like to pass custom target
# CFLAGS and LDFLAGS in the COPTS and LDOPTS variables; these should also
# go before any build-system computed flags, since they are defaults, not
# overrides
_ASTCFLAGS+=$(COPTS)
_ASTLDFLAGS+=$(LDOPTS)

# libxml2 cflags
_ASTCFLAGS+=$(LIBXML2_INCLUDE)

# BIND_8_COMPAT
_ASTCFLAGS+=$(BIND8_CFLAGS)

#Uncomment this to see all build commands instead of 'quiet' output
#NOISY_BUILD=yes

empty:=
space:=$(empty) $(empty)
ASTTOPDIR:=$(subst $(space),\$(space),$(CURDIR))

# Overwrite config files on "make samples" or other config installation targets
OVERWRITE=y

# Include debug and macro symbols in the executables (-g) and profiling info (-pg)
DEBUG=-g3

# Asterisk.conf is located in ASTETCDIR or by using the -C flag
# when starting Asterisk
ASTCONFPATH=$(ASTETCDIR)/asterisk.conf
AGI_DIR=$(ASTDATADIR)/agi-bin

# If you use Apache, you may determine by a grep 'DocumentRoot' of your httpd.conf file
HTTP_DOCSDIR=/var/www/html
# Determine by a grep 'ScriptAlias' of your Apache httpd.conf file
HTTP_CGIDIR=/var/www/cgi-bin

# If your platform's linker expects a prefix on symbols generated from compiling C
# source files, set LINKER_SYMBOL_PREFIX to that value. On some systems, exported symbols
# from C source files are prefixed with '_', for example. If this value is not set
# properly, the linker scripts that live in the '*.exports' files in various places
# in this tree will unintentionally suppress symbols that should be visible
# in the final binary objects.
LINKER_SYMBOL_PREFIX=

# Uncomment this to use the older DSP routines
#_ASTCFLAGS+=-DOLD_DSP_ROUTINES

# Default install directory for DAHDI hooks.
DAHDI_UDEV_HOOK_DIR = /usr/share/dahdi/span_config.d

# If the file .asterisk.makeopts is present in your home directory, you can
# include all of your favorite menuselect options so that every time you download
# a new version of Asterisk, you don't have to run menuselect to set them.
# The file /etc/asterisk.makeopts will also be included but can be overridden
# by the file in your home directory.

ifeq ($(wildcard menuselect.makeopts),)
	USER_MAKEOPTS=$(wildcard ~/.asterisk.makeopts)
	GLOBAL_MAKEOPTS=$(wildcard /etc/asterisk.makeopts)
else
	USER_MAKEOPTS=
	GLOBAL_MAKEOPTS=
endif


MOD_SUBDIR_CFLAGS="-I$(ASTTOPDIR)/include"
OTHER_SUBDIR_CFLAGS="-I$(ASTTOPDIR)/include"

# Create OPTIONS variable, but probably we can assign directly to ASTCFLAGS
OPTIONS=

ifeq ($(findstring -save-temps,$(_ASTCFLAGS) $(ASTCFLAGS)),)
  ifeq ($(findstring -pipe,$(_ASTCFLAGS) $(ASTCFLAGS)),)
    _ASTCFLAGS+=-pipe
  endif
endif

ifeq ($(findstring -Wall,$(_ASTCFLAGS) $(ASTCFLAGS)),)
  _ASTCFLAGS+=-Wall
endif

_ASTCFLAGS+=-Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations $(AST_NESTED_FUNCTIONS) $(AST_CLANG_BLOCKS) $(DEBUG)
ADDL_TARGETS=

ifeq ($(AST_DEVMODE),yes)
  _ASTCFLAGS+=-Werror
  _ASTCFLAGS+=-Wunused
  _ASTCFLAGS+=$(AST_DECLARATION_AFTER_STATEMENT)
  _ASTCFLAGS+=$(AST_TRAMPOLINES)
  _ASTCFLAGS+=-Wundef
  _ASTCFLAGS+=-Wmissing-format-attribute
  _ASTCFLAGS+=-Wformat=2
  ifeq ($(AST_DEVMODE_STRICT),yes)
    _ASTCFLAGS+=-Wshadow
  endif
  ifneq ($(DISABLE_XMLDOC),yes)
    ADDL_TARGETS+=validate-docs
  endif
endif

ifeq ($(OSARCH),NetBSD)
  _ASTCFLAGS+=-isystem /usr/pkg/include
else ifneq ($(findstring BSD,$(OSARCH)),)
  _ASTCFLAGS+=-isystem /usr/local/include
endif

ifeq ($(OSARCH),FreeBSD)
  # -V is understood by BSD Make, not by GNU make.
  BSDVERSION=$(shell make -V OSVERSION -f /usr/share/mk/bsd.port.subdir.mk)
  _ASTCFLAGS+=$(shell if test $(BSDVERSION) -lt 500016 ; then echo "-D_THREAD_SAFE"; fi)
endif

ifeq ($(OSARCH),NetBSD)
  _ASTCFLAGS+=-pthread -D__LIBPTHREAD_SOURCE__ -I/usr/pkg/include
endif

ifeq ($(OSARCH),OpenBSD)
  _ASTCFLAGS+=-pthread -ftrampolines
endif

ifeq ($(OSARCH),linux-uclibc)
  AST_LIBS+=-lpthread -ldl
endif

ifeq ($(OSARCH),SunOS)
  _ASTCFLAGS+=-Wcast-align -DSOLARIS -I../include/solaris-compat -I/opt/ssl/include -I/usr/local/ssl/include -D_XPG4_2 -D__EXTENSIONS__
endif

ifeq ($(GREP),)
else ifeq ($(GREP),:)
else
  ASTERISKVERSION:=$(shell GREP=$(GREP) AWK=$(AWK) GIT=$(GIT) build_tools/make_version .)
endif
ifneq ($(AWK),)
  ifneq ($(wildcard .version),)
    ASTERISKVERSIONNUM:=$(shell $(SED) -e 's/^certified\///' -e 's/-cert/./' .version | $(AWK) -F. '{printf "%01d%02d%02d", $$1, $$2, $$3}')
  endif
endif

ifneq ($(wildcard .svn),)
  ASTERISKVERSIONNUM:=999999
endif

ifneq ($(DISABLE_XMLDOC),yes)
  CORE_XMLDOC=doc/core-en_US.xml
  FULL_XMLDOC=doc/full-en_US.xml
else
  CORE_XMLDOC=
  FULL_XMLDOC=
endif

_ASTCFLAGS+=$(OPTIONS)

MOD_SUBDIRS:=third-party channels pbx apps codecs formats cdr cel bridges funcs tests main res addons $(LOCAL_MOD_SUBDIRS)
OTHER_SUBDIRS:=utils agi contrib
SUBDIRS:=$(OTHER_SUBDIRS) $(MOD_SUBDIRS)
SUBDIRS_INSTALL:=$(SUBDIRS:%=%-install)
SUBDIRS_CLEAN:=$(SUBDIRS:%=%-clean)
SUBDIRS_DIST_CLEAN:=$(SUBDIRS:%=%-dist-clean)
SUBDIRS_UNINSTALL:=$(SUBDIRS:%=%-uninstall)
MOD_SUBDIRS_MENUSELECT_TREE:=$(MOD_SUBDIRS:%=%-menuselect-tree)

ifneq ($(findstring darwin,$(OSARCH)),)
  _ASTCFLAGS+=-D__Darwin__ -mmacosx-version-min=10.6
  _SOLINK=-mmacosx-version-min=10.6 -Wl,-undefined,dynamic_lookup
  _SOLINK+=/usr/lib/bundle1.o
  SOLINK=-bundle $(_SOLINK)
  DYLINK=-Wl,-dylib $(_SOLINK)
  _ASTLDFLAGS+=-L/usr/local/lib
else
# These are used for all but Darwin
  SOLINK=-shared
  DYLINK=$(SOLINK)
  ifeq ($(OSARCH),NetBSD)
    _ASTLDFLAGS+=-L/usr/pkg/lib
  else ifneq ($(findstring BSD,$(OSARCH)),)
    _ASTLDFLAGS+=-L/usr/local/lib
  endif
endif

# Include rpath settings
_ASTLDFLAGS+=$(AST_RPATH)

ifeq ($(OSARCH),SunOS)
  SOLINK=-shared -fpic -L/usr/local/ssl/lib -lrt
  DYLINK=$(SOLINK)
endif

ifeq ($(OSARCH),OpenBSD)
  SOLINK=-shared -fpic
  DYLINK=$(SOLINK)
endif

# comment to print directories during submakes
#PRINT_DIR=yes

ifneq ($(INSIDE_EMACS),)
PRINT_DIR=yes
endif

SILENTMAKE:=$(MAKE) --quiet --no-print-directory
ifneq ($(PRINT_DIR)$(NOISY_BUILD),)
SUBMAKE:=$(MAKE)
else
SUBMAKE:=$(MAKE) --quiet --no-print-directory
endif

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

# $(MAKE) is printed in several places, and we want it to be a
# fixed size string. Define a variable whose name has also the
# same size, so we can easily align text.
ifeq ($(MAKE), gmake)
	mK="gmake"
else
	mK=" make"
endif

all: _all
	@echo " +--------- Asterisk Build Complete ---------+"
	@echo " + Asterisk has successfully been built, and +"
	@echo " + can be installed by running:              +"
	@echo " +                                           +"
	@echo " +               $(mK) install               +"
	@echo " +-------------------------------------------+"

full: _full
	@echo " +--------- Asterisk Build Complete ---------+"
	@echo " + Asterisk has successfully been built, and +"
	@echo " + can be installed by running:              +"
	@echo " +                                           +"
	@echo " +               $(mK) install               +"
	@echo " +-------------------------------------------+"


_all: makeopts $(SUBDIRS) $(CORE_XMLDOC) $(ADDL_TARGETS)

_full: makeopts $(SUBDIRS) $(FULL_XMLDOC) $(ADDL_TARGETS)

makeopts: configure
	@echo "****"
	@echo "**** The configure script must be executed before running '$(MAKE)'."
	@echo "****               Please run \"./configure\"."
	@echo "****"
	@exit 1

menuselect.makeopts: menuselect/menuselect menuselect-tree makeopts build_tools/menuselect-deps $(GLOBAL_MAKEOPTS) $(USER_MAKEOPTS)
ifeq ($(filter %.menuselect,$(MAKECMDGOALS)),)
	menuselect/menuselect --check-deps $@
	menuselect/menuselect --check-deps $@ $(GLOBAL_MAKEOPTS) $(USER_MAKEOPTS)
endif

$(MOD_SUBDIRS_MENUSELECT_TREE):
	+@$(SUBMAKE) -C $(@:-menuselect-tree=) SUBDIR=$(@:-menuselect-tree=) moduleinfo
	+@$(SUBMAKE) -C $(@:-menuselect-tree=) SUBDIR=$(@:-menuselect-tree=) makeopts

$(SUBDIRS): makeopts .lastclean main/version.c include/asterisk/build.h defaults.h

ifeq ($(findstring $(OSARCH), mingw32 cygwin ),)
main: third-party
else
    # Windows: we need to build main (i.e. the asterisk dll) first,
    # followed by res, followed by the other directories, because
    # dll symbols must be resolved during linking and not at runtime.
D1:= $(filter-out main,$(MOD_SUBDIRS))
D1:= $(filter-out res,$(D1))

$(D1): res
res:	main
endif

$(MOD_SUBDIRS): makeopts
	+@_ASTCFLAGS="$(MOD_SUBDIR_CFLAGS) $(_ASTCFLAGS)" ASTCFLAGS="$(ASTCFLAGS)" _ASTLDFLAGS="$(_ASTLDFLAGS)" ASTLDFLAGS="$(ASTLDFLAGS)" $(SUBMAKE) --no-builtin-rules -C $@ SUBDIR=$@ all

$(OTHER_SUBDIRS): makeopts
	+@_ASTCFLAGS="$(OTHER_SUBDIR_CFLAGS) $(_ASTCFLAGS)" ASTCFLAGS="$(ASTCFLAGS)" _ASTLDFLAGS="$(_ASTLDFLAGS)" ASTLDFLAGS="$(ASTLDFLAGS)" $(SUBMAKE) --no-builtin-rules -C $@ SUBDIR=$@ all

defaults.h: makeopts .lastclean build_tools/make_defaults_h
	@build_tools/make_defaults_h > $@.tmp
	@cmp -s $@.tmp $@ || mv $@.tmp $@
	@rm -f $@.tmp

main/version.c: FORCE include/asterisk/buildopts.h menuselect.makeopts .lastclean
	@build_tools/make_version_c > $@.tmp
	@cmp -s $@.tmp $@ || mv $@.tmp $@
	@rm -f $@.tmp

include/asterisk/buildopts.h: menuselect.makeopts .lastclean
	@build_tools/make_buildopts_h > $@.tmp
	@cmp -s $@.tmp $@ || mv $@.tmp $@
	@rm -f $@.tmp

# build.h must depend on .lastclean, or parallel make may wipe it out after it's
# been created.
include/asterisk/build.h: .lastclean
	@build_tools/make_build_h > $@

$(SUBDIRS_CLEAN):
	+@$(SUBMAKE) -C $(@:-clean=) clean

$(SUBDIRS_DIST_CLEAN):
	+@$(SUBMAKE) -C $(@:-dist-clean=) dist-clean

clean: $(SUBDIRS_CLEAN) _clean

_clean:
	rm -f defaults.h
	rm -f include/asterisk/build.h
	rm -f main/version.c
	rm -f doc/core-en_US.xml
	rm -f doc/full-en_US.xml
	rm -f doc/rest-api/*.wiki
	rm -f doxygen.log
	rm -rf latex
	rm -f rest-api-templates/*.pyc
	@$(MAKE) -C menuselect clean
	cp -f .cleancount .lastclean

dist-clean: distclean

distclean: $(SUBDIRS_DIST_CLEAN) _clean
	@$(MAKE) -C menuselect dist-clean
	@$(MAKE) -C sounds dist-clean
	rm -f menuselect.makeopts makeopts menuselect-tree menuselect.makedeps
	rm -f config.log config.status config.cache
	rm -rf autom4te.cache
	rm -f include/asterisk/autoconfig.h
	rm -f include/asterisk/buildopts.h
	rm -rf doc/api
	rm -f doc/Doxyfile
	rm -f build_tools/menuselect-deps

datafiles: _all $(CORE_XMLDOC)
	CFLAGS="$(_ASTCFLAGS) $(ASTCFLAGS)" build_tools/mkpkgconfig "$(DESTDIR)$(libdir)/pkgconfig";

#	# Recursively install contents of the static-http directory, in case
#	# extra content is provided there. See contrib/scripts/get_swagger_ui.sh
	find static-http | while read x; do \
		if test -d $$x; then \
			$(INSTALL) -m 755 -d "$(DESTDIR)$(ASTDATADIR)/$$x"; \
		else \
			$(INSTALL) -m 644 $$x "$(DESTDIR)$(ASTDATADIR)/$$x" ; \
		fi \
	done
ifneq ($(DISABLE_XMLDOC),yes)
	$(INSTALL) -m 644 doc/core-en_US.xml "$(DESTDIR)$(ASTDATADIR)/static-http";
	$(INSTALL) -m 644 doc/appdocsxml.xslt "$(DESTDIR)$(ASTDATADIR)/static-http";
endif
	if [ -d doc/tex/asterisk ] ; then \
		$(INSTALL) -d "$(DESTDIR)$(ASTDATADIR)/static-http/docs" ; \
		for n in doc/tex/asterisk/* ; do \
			$(INSTALL) -m 644 $$n "$(DESTDIR)$(ASTDATADIR)/static-http/docs" ; \
		done \
	fi
	for x in images/*.jpg; do \
		$(INSTALL) -m 644 $$x "$(DESTDIR)$(ASTDATADIR)/images" ; \
	done
	$(MAKE) -C sounds install
	find rest-api -name "*.json" | while read x; do \
		$(INSTALL) -m 644 $$x "$(DESTDIR)$(ASTDATADIR)/rest-api" ; \
	done

DOC_MOD_SUBDIRS := $(filter-out third-party,$(MOD_SUBDIRS))
XML_core_en_US := $(shell build_tools/make_xml_documentation --command=print_dependencies --source-tree=. --mod-subdirs="$(DOC_MOD_SUBDIRS)")
# core-en_US.xml is the normal documentation created with asterisk builds.
doc/core-en_US.xml: makeopts .lastclean $(XML_core_en_US)
	@build_tools/make_xml_documentation --command=create_xml --source-tree=. --mod-subdirs="$(DOC_MOD_SUBDIRS)" \
		--with-moduleinfo --output-file=$@

# The full-en_US.xml target is only called by the wiki documentation generation process
# and does special post-processing in preparation for uploading to the wiki.
# It creates full-en_US.xml but then re-creates core-en_US.xml as well.
doc/full-en_US.xml: makeopts .lastclean $(XML_core_en_US)
ifeq ($(PYTHON),:)
	@echo "--------------------------------------------------------------------------"
	@echo "---        Please install python to build full documentation           ---"
	@echo "--------------------------------------------------------------------------"
else
	@build_tools/make_xml_documentation --command=create_xml --source-tree=. --mod-subdirs="$(DOC_MOD_SUBDIRS)" \
		--for-wiki --output-file=$@ --core-output-file=./doc/core-en_US.xml
endif

validate-docs: doc/core-en_US.xml
ifeq ($(XMLSTARLET)$(XMLLINT),::)
	@echo "--------------------------------------------------------------------------"
	@echo "--- Please install xmllint or xmlstarlet to validate the documentation ---"
	@echo "--------------------------------------------------------------------------"
else
  ifneq ($(XMLLINT),:)
	$(XMLLINT) --dtdvalid doc/appdocsxml.dtd --noout $<
  else
	$(XMLSTARLET) val -d doc/appdocsxml.dtd $<
  endif
endif

update:
	@if [ -d .svn ]; then \
		echo "Updating from Subversion..." ; \
		fromrev="`svn info | $(AWK) '/Revision: / {print $$2}'`"; \
		svn update | tee update.out; \
		torev="`svn info | $(AWK) '/Revision: / {print $$2}'`"; \
		echo "`date`  Updated from revision $${fromrev} to $${torev}." >> update.log; \
		rm -f .version; \
		if [ `grep -c ^C update.out` -gt 0 ]; then \
			echo ; echo "The following files have conflicts:" ; \
			grep ^C update.out | cut -b4- ; \
		fi ; \
		rm -f update.out; \
	else \
		echo "Not under version control";  \
	fi

NEWHEADERS=$(notdir $(wildcard include/asterisk/*.h))
OLDHEADERS=$(filter-out $(NEWHEADERS) $(notdir $(DESTDIR)$(ASTHEADERDIR)),$(notdir $(wildcard $(DESTDIR)$(ASTHEADERDIR)/*.h)))
INSTALLDIRS="$(ASTLIBDIR)" "$(ASTMODDIR)" "$(ASTSBINDIR)" "$(ASTCACHEDIR)" "$(ASTETCDIR)" "$(ASTVARRUNDIR)" \
	"$(ASTSPOOLDIR)" "$(ASTSPOOLDIR)/dictate" "$(ASTSPOOLDIR)/meetme" \
	"$(ASTSPOOLDIR)/monitor" "$(ASTSPOOLDIR)/system" "$(ASTSPOOLDIR)/tmp" \
	"$(ASTSPOOLDIR)/voicemail" "$(ASTSPOOLDIR)/recording" \
	"$(ASTLOGDIR)" "$(ASTLOGDIR)/cdr-csv" "$(ASTLOGDIR)/cdr-custom" \
	"$(ASTLOGDIR)/cel-custom" "$(ASTDATADIR)" "$(ASTDATADIR)/documentation" \
	"$(ASTDATADIR)/documentation/thirdparty" "$(ASTDATADIR)/firmware" \
	"$(ASTDATADIR)/firmware/iax" "$(ASTDATADIR)/images" "$(ASTDATADIR)/keys" \
	"$(ASTDATADIR)/phoneprov" "$(ASTDATADIR)/rest-api" "$(ASTDATADIR)/static-http" \
	"$(ASTDATADIR)/sounds" "$(ASTDATADIR)/moh" "$(ASTMANDIR)/man8" "$(AGI_DIR)" "$(ASTDBDIR)" \
	"$(ASTDATADIR)/third-party" "${ASTDATADIR}/keys/stir_shaken" "${ASTDATADIR}/keys/stir_shaken/cache"

installdirs:
	@for i in $(INSTALLDIRS); do \
		if [ ! -z "$${i}" -a ! -d "$(DESTDIR)$${i}" ]; then \
			$(INSTALL) -d "$(DESTDIR)$${i}"; \
		fi; \
	done

main-bininstall:
	+@DESTDIR="$(DESTDIR)" ASTSBINDIR="$(ASTSBINDIR)" ASTLIBDIR="$(ASTLIBDIR)" $(SUBMAKE) -C main bininstall

bininstall: _all installdirs $(SUBDIRS_INSTALL) main-bininstall
	$(INSTALL) -m 755 contrib/scripts/astversion "$(DESTDIR)$(ASTSBINDIR)/"
	$(INSTALL) -m 755 contrib/scripts/astgenkey "$(DESTDIR)$(ASTSBINDIR)/"
	$(INSTALL) -m 755 contrib/scripts/autosupport "$(DESTDIR)$(ASTSBINDIR)/"
ifneq ($(HAVE_SBIN_LAUNCHD),1)
	./build_tools/install_subst contrib/scripts/safe_asterisk "$(DESTDIR)$(ASTSBINDIR)/safe_asterisk";
endif

ifneq ($(DISABLE_XMLDOC),yes)
	$(INSTALL) -m 644 doc/core-*.xml "$(DESTDIR)$(ASTDATADIR)/documentation"
	$(INSTALL) -m 644 doc/appdocsxml.xslt "$(DESTDIR)$(ASTDATADIR)/documentation"
	$(INSTALL) -m 644 doc/appdocsxml.dtd "$(DESTDIR)$(ASTDATADIR)/documentation"
endif
	$(INSTALL) -m 644 doc/asterisk.8 "$(DESTDIR)$(ASTMANDIR)/man8"
	$(INSTALL) -m 644 doc/astdb*.8 "$(DESTDIR)$(ASTMANDIR)/man8"
	$(INSTALL) -m 644 contrib/scripts/astgenkey.8 "$(DESTDIR)$(ASTMANDIR)/man8"
	$(INSTALL) -m 644 contrib/scripts/autosupport.8 "$(DESTDIR)$(ASTMANDIR)/man8"
	$(INSTALL) -m 644 contrib/scripts/safe_asterisk.8 "$(DESTDIR)$(ASTMANDIR)/man8"
	if [ -f contrib/firmware/iax/iaxy.bin ] ; then \
		$(INSTALL) -m 644 contrib/firmware/iax/iaxy.bin "$(DESTDIR)$(ASTDATADIR)/firmware/iax/iaxy.bin"; \
	fi
ifeq ($(HAVE_DAHDI),1)
	$(INSTALL) -d $(DESTDIR)/$(DAHDI_UDEV_HOOK_DIR)
	$(INSTALL) -m 644 contrib/scripts/dahdi_span_config_hook $(DESTDIR)$(DAHDI_UDEV_HOOK_DIR)/40-asterisk
endif

$(SUBDIRS_INSTALL):
	+@DESTDIR="$(DESTDIR)" ASTSBINDIR="$(ASTSBINDIR)" ASTDATADIR="$(ASTDATADIR)" $(SUBMAKE) -C $(@:-install=) install

NEWMODS:=$(foreach d,$(MOD_SUBDIRS),$(notdir $(wildcard $(d)/*.so)))
OLDMODS=$(filter-out $(NEWMODS) $(notdir $(DESTDIR)$(ASTMODDIR)),$(notdir $(wildcard $(DESTDIR)$(ASTMODDIR)/*.so)))
ifneq ($(BASH),:)
	FILMODS=$(filter-out $(shell ./build_tools/list_valid_installed_externals),$(OLDMODS))
else
	FILMODS=$(OLDMODS)
endif
BADMODS=$(strip $(FILMODS))

oldmodcheck:
	@if [ -n "$(BADMODS)" ]; then \
		echo " WARNING WARNING WARNING" ;\
		echo "" ;\
		echo " Your Asterisk modules directory, located at" ;\
		echo " $(DESTDIR)$(ASTMODDIR)" ;\
		echo " contains modules that were not installed by this " ;\
		echo " version of Asterisk. Please ensure that these" ;\
		echo " modules are compatible with this version before" ;\
		echo " attempting to run Asterisk." ;\
		echo "" ;\
		for f in $(BADMODS); do \
			echo "    $$f" ;\
		done ;\
		echo "" ;\
		echo " WARNING WARNING WARNING" ;\
	fi

ld-cache-update:
ifeq ($(LDCONFIG),)
else ifeq ($(LDCONFIG),:)
else
ifeq ($(DESTDIR),)  # DESTDIR means binary archive creation; ldconfig should be run on postinst
	@if [ $$(id -u) -eq 0 ] ; then \
		$(LDCONFIG) "$(ASTLIBDIR)/" ; \
	else \
		echo " WARNING WARNING WARNING" ;\
		echo "" ;\
		echo " You cannot rebuild the system linker cache unless you are root. " ;\
		echo " You MUST do one of the following..." ;\
		echo "  * Re-run 'make install' as root. " ;\
		echo "  * Run 'ldconfig $(ASTLIBDIR)' as root. " ;\
		echo "  * Run asterisk with 'LD_LIBRARY_PATH=$(ASTLIBDIR) asterisk' " ;\
		echo "" ;\
		echo " WARNING WARNING WARNING" ;\
	fi
endif
endif

export _oldlibdir =
export _oldmoddir =
ifeq ($(findstring 64,$(HOST_CPU)),64)
    # Strip any trailing '/' so the dir and notdir functions work correctly
    _current_libdir = $(patsubst %/,%,$(DESTDIR)$(ASTLIBDIR))

    # Only process if the paths end in lib64 or lib.
    # If we're installing to lib64, check lib for orphans.
    # If we're installing to lib, check lib64 for orphans.
    # Otherwise, leave _oldlibdir empty.
    ifeq ($(notdir $(_current_libdir)),lib64)
        _oldlibdir = $(dir $(_current_libdir))lib
    else ifeq ($(notdir $(_current_libdir)),lib)
        _oldlibdir = $(dir $(_current_libdir))lib64
    endif

    # Strip any trailing '/' so the dir and notdir functions work correctly
    _current_moddir = $(patsubst %/,%,$(DESTDIR)$(ASTMODDIR))

    # Only process if the paths contain /lib64/ or /lib/.
    # If we're installing to lib64, check lib for orphans.
    # If we're installing to lib, check lib64 for orphans.
    # Otherwise, leave _oldmoddir empty.
    ifeq ($(findstring /lib64/,$(_current_moddir)),/lib64/)
        _oldmoddir = $(subst /lib64/,/lib/,$(_current_moddir))
    else ifeq ($(findstring /lib/,$(_current_moddir)),/lib/)
        _oldmoddir = $(subst /lib/,/lib64/,$(_current_moddir))
    endif
endif

check-old-libdir:
	@test -n "$(_oldlibdir)" -a -d "$(_oldlibdir)" || exit 0 ;\
	oldfiles=`find "$(_oldlibdir)" -name libasterisk* -print -quit -o \( -path *asterisk/modules/* -a -name *.so \) -print -quit 2>/dev/null` ;\
	if [ "x$$oldfiles" != "x" ] ; then \
		echo " WARNING WARNING WARNING" ;\
		echo "" ;\
		echo " Installation is to: " ;\
		echo "   $(DESTDIR)$(ASTLIBDIR)" ;\
		echo " but there are asterisk shared libraries in: " ;\
		echo "   $(_oldlibdir)" ;\
		echo " or" ;\
		echo "   $(_oldlibdir)/asterisk/modules" ;\
		echo "" ;\
		echo " It is unlikely that asterisk will start." ;\
		echo "" ;\
		echo " You should do one of the following..." ;\
		echo "  * Run 'make uninstall' to remove the incorrect libraries" ;\
		echo "    then run 'make install' again." ;\
		echo "  * Manually remove the libraries from" ;\
		echo "   $(_oldlibdir)" ;\
		echo "   and run 'ldconfig' to rebuild the linker cache." ;\
		echo "" ;\
		echo " WARNING WARNING WARNING" ;\
	fi

badshell:
ifneq ($(filter ~%,$(DESTDIR)),)
	@echo "Your shell doesn't do ~ expansion when expected (specifically, when doing \"make install DESTDIR=~/path\")."
	@echo "Try replacing ~ with \$$HOME, as in \"make install DESTDIR=\$$HOME/path\"."
	@exit 1
endif

versioncheck:
ifeq ($(ASTERISKVERSION),UNKNOWN__git_check_fail)
	@echo "Asterisk Version is unknown due to a git error. If you are running make"
	@echo "as a different user than the project owner, this can be resolved by"
	@echo "running the following command as the user currently executing make: "$$USER
	@echo "git config --global --add safe.directory "$(mkfile_dir:/=)
	@exit 1
endif


install: badshell versioncheck bininstall datafiles
	@if [ -x /usr/sbin/asterisk-post-install ]; then \
		/usr/sbin/asterisk-post-install "$(DESTDIR)" . ; \
	fi
	@echo " +---- Asterisk Installation Complete -------+"
	@echo " +                                           +"
	@echo " +    YOU MUST READ THE SECURITY DOCUMENT    +"
	@echo " +                                           +"
	@echo " + Asterisk has successfully been installed. +"
	@echo " + If you would like to install the sample   +"
	@echo " + configuration files (overwriting any      +"
	@echo " + existing config files), run:              +"
	@echo " +                                           +"
	@echo " + For generic reference documentation:      +"
	@echo " +   $(mK) samples                           +"
	@echo " +                                           +"
	@echo " + For a sample basic PBX:                   +"
	@echo " +   $(mK) basic-pbx                         +"
	@echo " +                                           +"
	@echo " +                                           +"
	@echo " +-----------------  or ---------------------+"
	@echo " +                                           +"
	@echo " + You can go ahead and install the asterisk +"
	@echo " + program documentation now or later run:   +"
	@echo " +                                           +"
	@echo " +              $(mK) progdocs               +"
	@echo " +                                           +"
	@echo " + **Note** This requires that you have      +"
	@echo " + doxygen installed on your local system    +"
	@echo " +-------------------------------------------+"
	@$(MAKE) -s oldmodcheck
	@$(MAKE) -s ld-cache-update
	@$(MAKE) -s check-old-libdir

isntall: install

upgrade: bininstall


# Install configuration files from the specified directory
# Parameters:
#  (1) the configuration directory to install from
#  (2) the extension to strip off
define INSTALL_CONFIGS
	@for x in $(1)/*$(2); do \
		dst="$(DESTDIR)$(ASTETCDIR)/`$(BASENAME) $$x $(2)`"; \
		if [ -f "$${dst}" ]; then \
			if [ "$(OVERWRITE)" = "y" ]; then \
				if cmp -s "$${dst}" "$$x" ; then \
					echo "Config file $$x is unchanged"; \
					continue; \
				fi ; \
				mv -f "$${dst}" "$${dst}.old" ; \
			else \
				echo "Skipping config file $$x"; \
				continue; \
			fi ;\
		fi ; \
		echo "Installing file $$x"; \
		$(INSTALL) -m 644 "$$x" "$${dst}" ;\
	done ; \
	if [ "$(OVERWRITE)" = "y" ]; then \
		echo "Updating asterisk.conf" ; \
		sed -e 's|^astcachedir.*$$|astcachedir => $(ASTCACHEDIR)|' \
			-e 's|^astetcdir.*$$|astetcdir => $(ASTETCDIR)|' \
			-e 's|^astmoddir.*$$|astmoddir => $(ASTMODDIR)|' \
			-e 's|^astvarlibdir.*$$|astvarlibdir => $(ASTVARLIBDIR)|' \
			-e 's|^astdbdir.*$$|astdbdir => $(ASTDBDIR)|' \
			-e 's|^astkeydir.*$$|astkeydir => $(ASTKEYDIR)|' \
			-e 's|^astdatadir.*$$|astdatadir => $(ASTDATADIR)|' \
			-e 's|^astagidir.*$$|astagidir => $(AGI_DIR)|' \
			-e 's|^astspooldir.*$$|astspooldir => $(ASTSPOOLDIR)|' \
			-e 's|^astrundir.*$$|astrundir => $(ASTVARRUNDIR)|' \
			-e 's|^astlogdir.*$$|astlogdir => $(ASTLOGDIR)|' \
			-e 's|^astsbindir.*$$|astsbindir => $(ASTSBINDIR)|' \
			"$(DESTDIR)$(ASTCONFPATH)" > "$(DESTDIR)$(ASTCONFPATH).tmp" ; \
		$(INSTALL) -m 644 "$(DESTDIR)$(ASTCONFPATH).tmp" "$(DESTDIR)$(ASTCONFPATH)" ; \
		rm -f "$(DESTDIR)$(ASTCONFPATH).tmp" ; \
	fi
endef

install-headers:
# Will create all components of "$(DESTDIR)$(ASTHEADERDIR)/doxygen" including "$(DESTDIR)$(includedir)"
	$(INSTALL) -d "$(DESTDIR)$(ASTHEADERDIR)/doxygen"
	$(INSTALL) -m 644 include/asterisk.h "$(DESTDIR)$(includedir)"
	$(INSTALL) -m 644 include/asterisk/*.h "$(DESTDIR)$(ASTHEADERDIR)"
	$(INSTALL) -m 644 include/asterisk/doxygen/*.h "$(DESTDIR)$(ASTHEADERDIR)/doxygen"
	if [ -n "$(OLDHEADERS)" ]; then \
		for h in $(OLDHEADERS); do rm -f "$(DESTDIR)$(ASTHEADERDIR)/$$h"; done \
	fi

install-configs:
	@if test -z "$(CONFIG_SRC)" -o ! -d "$(CONFIG_SRC)"; then \
		>&2 echo "CONFIG_SRC must be set to a directory."; \
		exit 1; \
	fi
	@echo "Installing config files from $(CONFIG_SRC)/*$(CONFIG_EXTEN)"
	$(call INSTALL_CONFIGS,$(CONFIG_SRC),$(CONFIG_EXTEN))

# XXX why *.adsi is installed first ?
adsi:
	@echo Installing adsi config files...
	$(INSTALL) -d "$(DESTDIR)$(ASTETCDIR)"
	@for x in configs/samples/*.adsi; do \
		dst="$(DESTDIR)$(ASTETCDIR)/`$(BASENAME) $$x`" ; \
		if [ -f "$${dst}" ] ; then \
			echo "Overwriting $$x" ; \
		else \
			echo "Installing $$x" ; \
		fi ; \
		$(INSTALL) -m 644 "$$x" "$(DESTDIR)$(ASTETCDIR)/`$(BASENAME) $$x`" ; \
	done

samples: adsi
	@echo Installing other config files...
	$(call INSTALL_CONFIGS,configs/samples,.sample)
	$(INSTALL) -d "$(DESTDIR)$(ASTSPOOLDIR)/voicemail/default/1234/INBOX"
	build_tools/make_sample_voicemail "$(DESTDIR)/$(ASTDATADIR)" "$(DESTDIR)/$(ASTSPOOLDIR)"
	@for x in phoneprov/*; do \
		dst="$(DESTDIR)$(ASTDATADIR)/$$x" ;	\
		if [ -f "$${dst}" ]; then \
			if [ "$(OVERWRITE)" = "y" ]; then \
				if cmp -s "$${dst}" "$$x" ; then \
					echo "Config file $$x is unchanged"; \
					continue; \
				fi ; \
				mv -f "$${dst}" "$${dst}.old" ; \
			else \
				echo "Skipping config file $$x"; \
				continue; \
			fi ;\
		fi ; \
		echo "Installing file $$x"; \
		$(INSTALL) -m 644 "$$x" "$${dst}" ;\
	done

basic-pbx:
	@echo Installing basic-pbx config files...
	$(call INSTALL_CONFIGS,configs/basic-pbx)

webvmail:
	@[ -d "$(DESTDIR)$(HTTP_DOCSDIR)/" ] || ( printf "http docs directory not found.\nUpdate assignment of variable HTTP_DOCSDIR in Makefile!\n" && exit 1 )
	@[ -d "$(DESTDIR)$(HTTP_CGIDIR)" ] || ( printf "cgi-bin directory not found.\nUpdate assignment of variable HTTP_CGIDIR in Makefile!\n" && exit 1 )
	$(INSTALL) -m 4755 contrib/scripts/vmail.cgi "$(DESTDIR)$(HTTP_CGIDIR)/vmail.cgi"
	$(INSTALL) -d "$(DESTDIR)$(HTTP_DOCSDIR)/_asterisk"
	for x in images/*.gif; do \
		$(INSTALL) -m 644 $$x "$(DESTDIR)$(HTTP_DOCSDIR)/_asterisk/"; \
	done
	@echo " +--------- Asterisk Web Voicemail ----------+"
	@echo " +                                           +"
	@echo " + Asterisk Web Voicemail is installed in    +"
	@echo " + your cgi-bin directory:                   +"
	@echo " + $(DESTDIR)$(HTTP_CGIDIR)"
	@echo " + IT USES A SETUID ROOT PERL SCRIPT, SO     +"
	@echo " + IF YOU DON'T LIKE THAT, UNINSTALL IT!     +"
	@echo " +                                           +"
	@echo " + Other static items have been stored in:   +"
	@echo " + $(DESTDIR)$(HTTP_DOCSDIR)"
	@echo " +                                           +"
	@echo " + If these paths do not match your httpd    +"
	@echo " + installation, correct the definitions     +"
	@echo " + in your Makefile of HTTP_CGIDIR and       +"
	@echo " + HTTP_DOCSDIR                              +"
	@echo " +                                           +"
	@echo " +-------------------------------------------+"

progdocs:
ifeq ($(DOXYGEN),:)
	@echo "Doxygen is not installed.  Please install and re-run the configuration script."
else
	@cp doc/Doxyfile.in doc/Doxyfile
ifeq ($(DOT),:)
	@echo "DOT is not installed. Doxygen will not produce any diagrams. Please install and re-run the configuration script."
else
	@echo "HAVE_DOT = YES" >> doc/Doxyfile
endif
ifneq ($(NOISY_BUILD),yes)
	@echo "EXTRACT_ALL = YES" >> doc/Doxyfile
endif
ifeq ($(AST_DEVMODE),yes)
	@echo "INTERNAL_DOCS = YES" >> doc/Doxyfile
	@echo "WARN_NO_PARAMDOC = YES" >> doc/Doxyfile
endif
ifeq ($(ASTERISKVERSION),UNKNOWN__and_probably_unsupported)
	@echo "Asterisk Version is unknown, not configuring Doxygen PROJECT_NUMBER."
else ifeq ($(ASTERISKVERSION),UNKNOWN__git_check_fail)
	@echo "Asterisk Version is unknown due to a git error. If you are running make"
	@echo "as a different user than the project owner, this can be resolved by"
	@echo "running the following command as the user currently executing make: "$$USER
	@echo "git config --global --add safe.directory "$(mkfile_dir:/=)
	@echo "not configuring Doxygen PROJECT_NUMBER."
else
	@echo "PROJECT_NUMBER = $(ASTERISKVERSION)" >> doc/Doxyfile
endif
	@echo "Generating C-API documentation. This will take a while."
	@doxygen doc/Doxyfile
	@echo "Generation complete. Any warnings are in ./doxygen.log."
endif

install-logrotate:
	if [ ! -d "$(DESTDIR)$(ASTETCDIR)/../logrotate.d" ]; then \
		$(INSTALL) -d "$(DESTDIR)$(ASTETCDIR)/../logrotate.d" ; \
	fi
	sed 's#__LOGDIR__#$(ASTLOGDIR)#g' < contrib/scripts/asterisk.logrotate | sed 's#__SBINDIR__#$(ASTSBINDIR)#g' > contrib/scripts/asterisk.logrotate.tmp
	$(INSTALL) -m 0644 contrib/scripts/asterisk.logrotate.tmp "$(DESTDIR)$(ASTETCDIR)/../logrotate.d/asterisk"
	rm -f contrib/scripts/asterisk.logrotate.tmp

config:
	@if [ -f /etc/redhat-release -o -f /etc/fedora-release ]; then \
		./build_tools/install_subst contrib/init.d/rc.redhat.asterisk  "$(DESTDIR)/etc/rc.d/init.d/asterisk"; \
		if [ ! -f "$(DESTDIR)/etc/sysconfig/asterisk" ] ; then \
			$(INSTALL) -m 644 contrib/init.d/etc_default_asterisk "$(DESTDIR)/etc/sysconfig/asterisk" ; \
		fi ; \
		if [ -z "$(DESTDIR)" ] ; then \
			/sbin/chkconfig --add asterisk ; \
		fi ; \
	elif [ -f /etc/debian_version ] ; then \
		./build_tools/install_subst contrib/init.d/rc.debian.asterisk  "$(DESTDIR)/etc/init.d/asterisk"; \
		if [ ! -f "$(DESTDIR)/etc/default/asterisk" ] ; then \
			$(INSTALL) -m 644 contrib/init.d/etc_default_asterisk "$(DESTDIR)/etc/default/asterisk" ; \
		fi ; \
		if [ -z "$(DESTDIR)" ] ; then \
			/usr/sbin/update-rc.d asterisk defaults 50 91 ; \
		fi ; \
	elif [ -f /etc/gentoo-release ] ; then \
		./build_tools/install_subst contrib/init.d/rc.gentoo.asterisk  "$(DESTDIR)/etc/init.d/asterisk"; \
		if [ -z "$(DESTDIR)" ] ; then \
			/sbin/rc-update add asterisk default ; \
		fi ; \
	elif [ -f /etc/mandrake-release -o -f /etc/mandriva-release ] ; then \
		./build_tools/install_subst contrib/init.d/rc.mandriva.asterisk  "$(DESTDIR)/etc/rc.d/init.d/asterisk"; \
		if [ ! -f /etc/sysconfig/asterisk ] ; then \
			$(INSTALL) -m 644 contrib/init.d/etc_default_asterisk "$(DESTDIR)/etc/sysconfig/asterisk" ; \
		fi ; \
		if [ -z "$(DESTDIR)" ] ; then \
			/sbin/chkconfig --add asterisk ; \
		fi ; \
	elif [ -f /etc/SuSE-release -o -f /etc/novell-release ] ; then \
		./build_tools/install_subst contrib/init.d/rc.suse.asterisk  "$(DESTDIR)/etc/init.d/asterisk"; \
		if [ ! -f /etc/sysconfig/asterisk ] ; then \
			$(INSTALL) -m 644 contrib/init.d/etc_default_asterisk "$(DESTDIR)/etc/sysconfig/asterisk" ; \
		fi ; \
		if [ -z "$(DESTDIR)" ] ; then \
			/sbin/chkconfig --add asterisk ; \
		fi ; \
	elif [ -f /etc/os-release ] && [ "opensuse" = "$(shell . /etc/os-release 2>/dev/null && echo $$ID)" ] ; then \
		./build_tools/install_subst contrib/init.d/rc.suse.asterisk  "$(DESTDIR)/etc/init.d/asterisk"; \
		if [ ! -f /etc/sysconfig/asterisk ] ; then \
			$(INSTALL) -m 644 contrib/init.d/etc_default_asterisk "$(DESTDIR)/etc/sysconfig/asterisk" ; \
		fi ; \
		if [ -z "$(DESTDIR)" ] ; then \
			/sbin/chkconfig --add asterisk ; \
		fi ; \
	elif [ -f /etc/arch-release -o -f /etc/arch-release ] ; then \
		./build_tools/install_subst contrib/init.d/rc.archlinux.asterisk  "$(DESTDIR)/etc/init.d/asterisk"; \
	elif [ -f /etc/slackware-version ]; then \
		./build_tools/install_subst contrib/init.d/rc.slackware.asterisk  "$(DESTDIR)/etc/rc.d/rc.asterisk"; \
	elif [ -f /etc/os-release ] && [ "slackware" = "$(shell . /etc/os-release 2>/dev/null && echo $$ID)" ] ; then \
		./build_tools/install_subst contrib/init.d/rc.slackware.asterisk  "$(DESTDIR)/etc/rc.d/rc.asterisk"; \
	elif [ -d "$(DESTDIR)/Library/LaunchDaemons" ]; then \
		if [ ! -f "$(DESTDIR)/Library/LaunchDaemons/org.asterisk.asterisk.plist" ]; then \
			./build_tools/install_subst contrib/init.d/org.asterisk.asterisk.plist "$(DESTDIR)/Library/LaunchDaemons/org.asterisk.asterisk.plist"; \
		fi; \
		if [ ! -f "$(DESTDIR)/Library/LaunchDaemons/org.asterisk.muted.plist" ]; then \
			./build_tools/install_subst contrib/init.d/org.asterisk.muted.plist "$(DESTDIR)/Library/LaunchDaemons/org.asterisk.muted.plist"; \
		fi; \
	else \
		echo "We could not install init scripts for your distribution." ; \
	fi

sounds:
	$(MAKE) -C sounds all

# If the cleancount has been changed, force a make clean.
# .cleancount is the global clean count, and .lastclean is the
# last clean count we had

.lastclean: .cleancount
	@$(MAKE) clean
	@[ -f "$(DESTDIR)$(ASTDBDIR)/astdb.sqlite3" ] || [ ! -f "$(DESTDIR)$(ASTDBDIR)/astdb" ] || [ ! -f menuselect.makeopts ] || grep -q MENUSELECT_UTILS=.*astdb2sqlite3 menuselect.makeopts || (sed -i.orig -e's/MENUSELECT_UTILS=\(.*\)/MENUSELECT_UTILS=\1 astdb2sqlite3/' menuselect.makeopts && echo "Updating menuselect.makeopts to include astdb2sqlite3" && echo "Original version backed up to menuselect.makeopts.orig")


$(SUBDIRS_UNINSTALL):
	+@DESTDIR="$(DESTDIR)" ASTSBINDIR="$(ASTSBINDIR)" ASTDATADIR="$(ASTDATADIR)" $(SUBMAKE) -C $(@:-uninstall=) uninstall

main-binuninstall:
	+@DESTDIR="$(DESTDIR)" ASTSBINDIR="$(ASTSBINDIR)" ASTLIBDIR="$(ASTLIBDIR)" $(SUBMAKE) -C main binuninstall

uninstall-headers:
	rm -rf "$(DESTDIR)$(ASTHEADERDIR)"
	rm -f "$(DESTDIR)$(includedir)/asterisk.h"

_uninstall: $(SUBDIRS_UNINSTALL) main-binuninstall
	rm -f "$(DESTDIR)$(ASTMODDIR)/"*
	test -n "$(_oldmoddir)" -a -d "$(_oldmoddir)" && rm -f "$(_oldmoddir)/"* || :
	rm -f "$(DESTDIR)$(ASTSBINDIR)/astgenkey"
	rm -f "$(DESTDIR)$(ASTSBINDIR)/autosupport"
	rm -rf "$(DESTDIR)$(ASTDATADIR)/firmware"
	rm -f "$(DESTDIR)$(ASTMANDIR)/man8/asterisk.8"
	rm -f "$(DESTDIR)$(ASTMANDIR)/man8/astgenkey.8"
	rm -f "$(DESTDIR)$(ASTMANDIR)/man8/autosupport.8"
	rm -f "$(DESTDIR)$(ASTMANDIR)/man8/safe_asterisk.8"
ifeq ($(HAVE_DAHDI),1)
	rm -f $(DESTDIR)$(DAHDI_UDEV_HOOK_DIR)/40-asterisk
endif
	$(MAKE) -C sounds uninstall
ifeq ($(LDCONFIG),)
else ifeq ($(LDCONFIG),:)
else
	$(LDCONFIG) "$(ASTLIBDIR)/" || :
endif

uninstall: _uninstall
	@echo " +--------- Asterisk Uninstall Complete -----+"
	@echo " + Asterisk binaries, sounds, man pages,     +"
	@echo " + headers, modules, and firmware builds,    +"
	@echo " + have all been uninstalled.                +"
	@echo " +                                           +"
	@echo " + To remove ALL traces of Asterisk,         +"
	@echo " + including configuration, spool            +"
	@echo " + directories, and logs, run the following  +"
	@echo " + command:                                  +"
	@echo " +                                           +"
	@echo " +            $(mK) uninstall-all            +"
	@echo " +-------------------------------------------+"

uninstall-all: _uninstall uninstall-headers
	rm -rf "$(DESTDIR)$(ASTMODDIR)"
	test -n "$(_oldmoddir)" -a -d "$(_oldmoddir)" && rm -rf "$(_oldmoddir)" || :
	rm -rf "$(DESTDIR)$(ASTVARLIBDIR)"
	rm -rf "$(DESTDIR)$(ASTDATADIR)"
	rm -rf "$(DESTDIR)$(ASTSPOOLDIR)"
	rm -rf "$(DESTDIR)$(ASTETCDIR)"
	rm -rf "$(DESTDIR)$(ASTLOGDIR)"
	rm -rf "$(DESTDIR)$(ASTCACHEDIR)"

menuconfig: menuselect

cmenuconfig: cmenuselect

gmenuconfig: gmenuselect

nmenuconfig: nmenuselect

menuselect: menuselect/cmenuselect menuselect/nmenuselect menuselect/gmenuselect
	@if [ -x menuselect/nmenuselect ]; then \
		$(MAKE) nmenuselect; \
	elif [ -x menuselect/cmenuselect ]; then \
		$(MAKE) cmenuselect; \
	elif [ -x menuselect/gmenuselect ]; then \
		$(MAKE) gmenuselect; \
	else \
		echo "No menuselect user interface found. Install ncurses,"; \
		echo "newt or GTK libraries to build one and re-rerun"; \
		echo "'./configure' and 'make menuselect'."; \
	fi

cmenuselect: menuselect/cmenuselect menuselect-tree menuselect.makeopts
	-@menuselect/cmenuselect menuselect.makeopts && (echo "menuselect changes saved!"; rm -f channels/h323/Makefile.ast main/asterisk) || echo "menuselect changes NOT saved!"

gmenuselect: menuselect/gmenuselect menuselect-tree menuselect.makeopts
	-@menuselect/gmenuselect menuselect.makeopts && (echo "menuselect changes saved!"; rm -f channels/h323/Makefile.ast main/asterisk) || echo "menuselect changes NOT saved!"

nmenuselect: menuselect/nmenuselect menuselect-tree menuselect.makeopts
	-@menuselect/nmenuselect menuselect.makeopts && (echo "menuselect changes saved!"; rm -f channels/h323/Makefile.ast main/asterisk) || echo "menuselect changes NOT saved!"

# options for make in menuselect/
MAKE_MENUSELECT=CC="$(BUILD_CC)" CXX="$(CXX)" LD="" AR="" RANLIB="" \
		CFLAGS="$(BUILD_CFLAGS)" LDFLAGS="$(BUILD_LDFLAGS)" \
		$(MAKE) -C menuselect CONFIGURE_SILENT="--silent"

menuselect/menuselect: menuselect/makeopts .lastclean
	+$(MAKE_MENUSELECT) menuselect

menuselect/cmenuselect: menuselect/makeopts .lastclean
	+$(MAKE_MENUSELECT) cmenuselect

menuselect/gmenuselect: menuselect/makeopts .lastclean
	+$(MAKE_MENUSELECT) gmenuselect

menuselect/nmenuselect: menuselect/makeopts .lastclean
	+$(MAKE_MENUSELECT) nmenuselect

menuselect/makeopts: makeopts .lastclean
	+$(MAKE_MENUSELECT) makeopts

menuselect-tree: $(foreach dir,$(filter-out main,$(MOD_SUBDIRS)),$(wildcard $(dir)/*.c) $(wildcard $(dir)/*.cc) $(wildcard $(dir)/*.xml)) main/channelstorage_makeopts.xml build_tools/cflags.xml build_tools/cflags-devmode.xml sounds/sounds.xml utils/utils.xml agi/agi.xml configure makeopts
	@echo "Generating input for menuselect ..."
	@echo "<?xml version=\"1.0\"?>" > $@
	@echo >> $@
	@echo "<menu name=\"Asterisk Module and Build Option Selection\">" >> $@
	+@for dir in $(sort $(filter-out main,$(MOD_SUBDIRS))); do $(SILENTMAKE) -C $${dir} SUBDIR=$${dir} moduleinfo >> $@; done
	@cat main/channelstorage_makeopts.xml >> $@
	@cat build_tools/cflags.xml >> $@
	+@for dir in $(sort $(filter-out main,$(MOD_SUBDIRS))); do $(SILENTMAKE) -C $${dir} SUBDIR=$${dir} makeopts >> $@; done
	@if [ "${AST_DEVMODE}" = "yes" ]; then \
		cat build_tools/cflags-devmode.xml >> $@; \
	fi
	@cat utils/utils.xml >> $@
	@cat agi/agi.xml >> $@
	@cat sounds/sounds.xml >> $@
	@echo "</menu>" >> $@

# We don't want to require Python or Pystache for every build, so this is its
# own target.
ari-stubs:
ifeq ($(PYTHON),:)
	@echo "--------------------------------------------------------------------------"
	@echo "---        Please install python to build ARI stubs            ---"
	@echo "--------------------------------------------------------------------------"
	@false
else
	@$(INSTALL) -d doc/rest-api
	$(PYTHON) rest-api-templates/make_ari_stubs.py \
		--resources rest-api/resources.json --source-dir $(ASTTOPDIR) \
		--dest-dir $(ASTTOPDIR)/doc/rest-api --docs-prefix ../
endif

check-alembic: makeopts
	@find contrib/ast-db-manage/ -name '*.pyc' -delete
	@ALEMBIC=$(ALEMBIC) build_tools/make_check_alembic config cdr voicemail >&2

.PHONY: install-configs
.PHONY: install-headers
.PHONY: menuselect
.PHONY: main
.PHONY: sounds
.PHONY: clean
.PHONY: dist-clean
.PHONY: distclean
.PHONY: all
.PHONY: _all
.PHONY: full
.PHONY: _full
.PHONY: uninstall
.PHONY: _uninstall
.PHONY: uninstall-all
.PHONY: uninstall-headers
.PHONY: badshell
.PHONY: installdirs
.PHONY: progdocs
.PHONY: validate-docs
.PHONY: _clean
.PHONY: ari-stubs
.PHONY: basic-pbx
.PHONY: check-alembic
.PHONY: ld-cache-update
.PHONY: check-old-libdir
.PHONY: $(SUBDIRS_INSTALL)
.PHONY: $(SUBDIRS_DIST_CLEAN)
.PHONY: $(SUBDIRS_CLEAN)
.PHONY: $(SUBDIRS_UNINSTALL)
.PHONY: $(SUBDIRS)

FORCE:

# This only stops targets within the root Makefile from building in parallel.
.NOTPARALLEL:
