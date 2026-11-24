CHANNELS_FILE=./env/guix/du/env/guix/channels.scm
GUIXTM=GUILE_LOAD_PATH="./src" guix time-machine --unsafe-channel-evaluation -L ./env/guix -C ${CHANNELS_FILE}
GUIX=$(GUIXTM) --

SRC_DIR=./src
CONFIGS=${SRC_DIR}/du/configs.scm
PULL_EXTRA_OPTIONS=
# --allow-downgrades

ROOT_MOUNT_POINT=/mnt

VERSION=latest

repl:
	${GUIX} shell -L ./env/guix -L ./env/dev guile \
	-e '(@ (du env dev packages) guix-package)' \
	-e '(@ (du env dev packages) channels-package)' \
	-- guile \
	-L ./env/guix \
	-L ./env/dev

repl-shakhzod:
	${GUIX} shell -L ./env/guix -L ./env/dev guile \
	-e '(@ (du env dev packages) guix-package)' \
	-e '(@ (du env dev packages) channels-package)' \
	-- guile \
	-L ./env/guix \
	-L ./env/dev \
	-c \
"(begin (use-modules (du users shakhzod)))"

ares:
	${GUIX} shell -L ./env/guix -L ./env/dev guile guile-ares-rs \
	-e '(@ (du env dev packages) guix-package)' \
	-e '(@ (du env dev packages) channels-package)' \
	-- guile \
	-L ./env/guix \
	-L ./env/dev \
	-c \
"(begin (use-modules (guix gexp)) #;(load gexp reader macro globally) \
((@ (ares server) run-nrepl-server)))"

env/guix/rde/env/guix/channels.scm: ./env/guix/rde/env/guix/channels.scm
	mkdir -p $(@D)
	cat $< > $@
	echo -e "\n;;; This is an automatic copy of RDE's channels.scm" >> $@
	echo -e ";;; Do not edit it manually" >> $@

env/sync: env/guix/rde/env/guix/channels.scm
guix: env/sync

guix-pull:
	guix pull -L ./env/guix --unsafe-channel-evaluation -C ${CHANNELS_FILE} --allow-downgrades

qoravoy/home/build:
	RDE_TARGET=qoravoy-home ${GUIX} home \
	build ${CONFIGS}

qoravoy/home/reconfigure:
	RDE_TARGET=qoravoy-home ${GUIX} home \
	reconfigure ${CONFIGS}

qoravoy/system/build:
	RDE_TARGET=qoravoy-system ${GUIX} system \
	build ${CONFIGS}

qoravoy/system/reconfigure:
	RDE_TARGET=qoravoy-system ${GUIX} system \
	reconfigure ${CONFIGS} --allow-downgrades

cow-store:
	sudo herd start cow-store ${ROOT_MOUNT_POINT}

qoravoy/system/init: guix
	RDE_TARGET=qoravoy-system ${GUIX} system \
	init ${CONFIGS} ${ROOT_MOUNT_POINT}
