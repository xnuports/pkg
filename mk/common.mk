$(info CFLAGS=$(CFLAGS))
CFLAGS?=	-O2 -pipe
CFLAGS+=	-DPREFIX=\"$(PREFIX)\"
OBJS=	${SRCS:.c=.o}
SHOBJS?=	${SRCS:.c=.pico}
DEPFILES=	${OBJS:.o=.Po} ${SHOBJS:.pico=.Ppico}
CFLAGS+=	$(CPPFLAGS)
CFLAGS+=	-Werror=implicit-function-declaration
CFLAGS+=	-Werror=return-type

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	OSFLAG += -D DARWIN
	CFLAGS +=\
				-I/opt/homebrew/opt/openssl/include\
				-I/opt/homebrew/opt/libarchive/include
	LDFLAGS +=\
				-L/opt/homebrew/opt/openssl/lib\
				-L/opt/homebrew/opt/libarchive/lib
$(info AFTER_DARWIN CFLAGS=$(CFLAGS))
$(info AFTER_DARWIN CFLAGS=$(CFLAGS))
endif

# bmake's traditional include support treats empty strings in the expanded
# result (whether because the variable is empty or there are consecutive
# whitespace characters) as file names, and thus tries to read the containing
# directory as a Makefile, which fails, and isn't ignored since it exists.
# Work around this quirky behaviour by adding an extra entry that should never
# exist and then normalize its whitespace during substitution with :=.
DEPFILES_NONEMPTY=	$(DEPFILES) /nonexistent
-include $(DEPFILES_NONEMPTY:=)

.SUFFIXES: .pico

.c.o:
	$(CC) -Wall -Wextra -std=gnu17 -D_GNU_SOURCE=1 -MT $@ -MD -MP -MF $*.Tpo -o $@ -c $(CFLAGS) $(LOCAL_CFLAGS) $<
	mv $*.Tpo $*.Po

.c.pico:
	$(CC) -Wall -Wextra -std=gnu17 -D_GNU_SOURCE=1 -MT $@ -MD -MP -MF $*.Tpico -o $@ -c $(CFLAGS) $(LOCAL_CFLAGS) $(SHOBJ_CFLAGS) $<
	mv $*.Tpico $*.Ppico

.PHONY: clean clean-files distclean distclean-files check

clean: clean-files

clean-files:
	rm -f $(CLEAN_FILES)

distclean: distclean-files

distclean-files:
	rm -r $(DISTCLEAN_FILES)
