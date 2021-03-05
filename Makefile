.PHONY: all arch archive clean dist distro includes install macros os package uninstall version
.DEFAULT_GOAL := dist
PREFIX = /usr/local
BINDEST = $(PREFIX)/bin
MANDEST = $(PREFIX)/man/man1

OS ?= $(shell uname -s | tr [A-Z] [a-z])
ARCH ?= $(shell uname -m | tr [A-Z] [a-z])
PACKAGE ?= $(shell awk '{print $$1; exit}' README | tr [A-Z] [a-z])
VERSION ?= $(shell awk '{print $$2; exit}' README)
DIST ?= dist/$(OS)/$(ARCH)/$(PACKAGE)
ARCHIVE ?= $(DIST).tar.gz
DISTRO ?= $(shell grep ^ID /etc/os-release | awk -F = '{printf $$2; exit}' | tr [A-Z] [a-z])

CC = gcc
INCLUDES += -I .
CFLAGS = -O1 -Wall $(INCLUDES)
LDFLAGS = -s
LIBS = 

ifdef OS2
LDFLAGS += -Zsmall-conv
LIBS += -lsocket
BINSUFFIX = .exe
STRIP =
else
STRIP = -s
endif

all: netselect

includes:
ifeq (darwin, $(OS))
INCLUDES += \
-I /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/machine
endif
ifeq (linux, $(OS))
INCLUDES += \
-I /usr/include
endif

netselect:
	$(CC) $(CFLAGS) -c $(@).c
	$(CC) $(LDFLAGS) -o $(@) $(@).o $(LIBS)

install: $(PROG)
	
ifdef OS2
	emxbind -bwq netselect
else
	chown root netselect && chmod u+s netselect
endif
	
	-install -d $(BINDEST)
	-install -d $(MANDEST)
	install -o root -g root -m 4755 \
		netselect$(BINSUFFIX) $(BINDEST)
	install -o root -g root -m 0755 netselect-apt $(BINDEST)
	install -o root -g root -m 0644 netselect.1 $(MANDEST)
	install -o root -g root -m 0644 netselect-apt.1 $(MANDEST)

uninstall:
	$(RM) $(BINDEST)/netselect$(BINSUFFIX) $(BINDEST)/netselect-apt
	$(RM) $(MANDEST)/netselect.1
	$(RM) $(MANDEST)/netselect-apt.1

clean:
	$(RM) netselect netselect$(BINSUFFIX) *.o *~ .*~ build-stamp core
	$(RM) mirrors_full
	$(RM) macros.h

dist: netselect
	@mkdir -p $(shell dirname $(DIST))
	tar c -z -f $(ARCHIVE) $(PACKAGE) $(PACKAGE).sh

distclean: clean
	$(RM) $(ARCHIVE)

macros: ## Generate predefined macros
	@$(CC) -dM -E - < /dev/null > $(@).h

arch: ## Print Arch
	@printf "$(ARCH)\n"

archive: ## Print Archive
	@printf "$(ARCHIVE)\n"

distro: ## Print OS Distribution
	@printf "$(DISTRO)\n"

os: ## Print OS
	@printf "$(OS)\n"

package: ## Print Package
	@printf "$(PACKAGE)\n"

version: ## Print Version
	@printf "$(VERSION)\n"

docker/shell: ## Starts a shell session in the Apline container
	docker-compose exec alpine sh

docker/up: ## Start Docker containers
	docker-compose up --detach --remove-orphans --renew-anon-volumes

docker/up/build: ## Re-build and Start Docker containers
	docker-compose up --detach --build --force-recreate --remove-orphans --renew-anon-volumes

docker/build:
	docker-compose build --no-cache --force-rm --pull

docker/build/up: docker/build docker/up ## Re-build and Start Docker containers

docker/down: ## Stop and remove Docker containers
	docker-compose down --remove-orphans

docker/logs: ## View output from docker containers
	docker-compose logs --follow

docker/images: ## Show all docker images
	docker images --all \
		| grep --invert-match "<none>" \
			| sort

docker/system/prune: ## Remove all unused Docker images and volumes
	docker system prune --force --all --volumes

docker/system/storage: ## Show Docker storage info
	docker system df
