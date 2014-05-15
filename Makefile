top_builddir=../..
top_srcdir=../../
srcdir=.

include $(top_srcdir)/Make.rules

.SUFFIXES: .la .lo

SHARED_CFLAGS=-DPR_SHARED_MODULE
SHARED_LDFLAGS=-avoid-version -export-dynamic -module


MODULE_NAME=mod_dnsbl
MODULE_OBJS=mod_dnsbl.o
SHARED_MODULE_OBJS=mod_dnsbl.lo

MODULE_LIBS=-lresolv

# Necessary redefinitions
INCLUDES=-I. -I../.. -I../../include -I/usr/include/openssl
CPPFLAGS= $(ADDL_CPPFLAGS) -DHAVE_CONFIG_H $(DEFAULT_PATHS) $(PLATFORM) $(INCLUDES)
LDFLAGS=-L../../lib -lz -lbz2 -larchive -L/usr/lib/openssl

.c.o:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<

.c.lo:
	$(LIBTOOL) --mode=compile --tag=CC $(CC) $(CPPFLAGS) $(CFLAGS) $(SHARED_CFLAGS) -c $<

shared: $(SHARED_MODULE_OBJS)
	$(LIBTOOL) --mode=link --tag=CC $(CC) -o $(MODULE_NAME).la $(SHARED_MODULE_OBJS) -rpath $(LIBEXECDIR) $(LDFLAGS) $(SHARED_LDFLAGS) $(SHARED_MODULE_LIBS) `cat $(MODULE_NAME).c | grep '$$Libraries:' | sed -e 's/^.*\$$Libraries: \(.*\)\\$$/\1/'`

static: $(MODULE_OBJS)
	test -z "$(MODULE_LIBS)" || echo "$(MODULE_LIBS)" >> $(MODULE_LIBS_FILE)
	$(AR) rc $(MODULE_NAME).a $(MODULE_NAME).o $(MODULE_OBJS)
	$(RANLIB) $(MODULE_NAME).a

install:
	if [ -f $(MODULE_NAME).la ] ; then \
		$(LIBTOOL) --mode=install --tag=CC $(INSTALL_BIN) $(MODULE_NAME).la $(DESTDIR)$(LIBEXECDIR) ; \
	fi

clean:
	$(LIBTOOL) --mode=clean $(RM) $(MODULE_NAME).a $(MODULE_NAME).la *.o *.lo .libs/*.o

dist: clean
	$(RM) Makefile mod_dnsbl.h config.status config.cache config.log
	-$(RM) -r .libs/ .git/ CVS/ RCS/
