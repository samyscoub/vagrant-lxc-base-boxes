UBUNTU_BOXES= precise quantal raring saucy trusty utopic vivid wily xenial yakkety bionic focal
DEBIAN_BOXES= squeeze wheezy jessie stretch sid buster
CENTOS_BOXES= centos6 centos7 centos8
FEDORA_BOXES= rawhide fedora33 fedora23 fedora22 fedora21 fedora20 fedora19
TODAY=$(shell date -u +"%Y-%m-%d")

# Replace i686 with i386 and x86_64 with amd64
ARCH=$(shell uname -m | sed -e "s/68/38/" | sed -e "s/x86_64/amd64/")

default:

all: ubuntu debian fedora

ubuntu: $(UBUNTU_BOXES)
debian: $(DEBIAN_BOXES)
centos: $(CENTOS_BOXES)
fedora: $(FEDORA_BOXES)

# REFACTOR: Figure out how can we reduce duplicated code
$(UBUNTU_BOXES): CONTAINER = "vagrant-base-${@}-$(ARCH)"
$(UBUNTU_BOXES): PACKAGE = "output/${TODAY}/vagrant-lxc-${@}-$(ARCH).box"
$(UBUNTU_BOXES):
	@mkdir -p $$(dirname $(PACKAGE))
	@sudo -E ./mk-debian.sh ubuntu $(@) $(ARCH) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)
$(DEBIAN_BOXES): CONTAINER = "vagrant-base-${@}-$(ARCH)"
$(DEBIAN_BOXES): PACKAGE = "output/${TODAY}/vagrant-lxc-${@}-$(ARCH).box"
$(DEBIAN_BOXES):
	@mkdir -p $$(dirname $(PACKAGE))
	@sudo -E ./mk-debian.sh debian $(@) $(ARCH) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)
$(CENTOS_BOXES): CONTAINER = "vagrant-base-${@}-$(ARCH)"
$(CENTOS_BOXES): PACKAGE = "output/${TODAY}/vagrant-lxc-${@}-$(ARCH).box"
$(CENTOS_BOXES):
	@mkdir -p $$(dirname $(PACKAGE))
	@sudo -E ./mk-centos.sh $(@) $(ARCH) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)
$(FEDORA_BOXES): CONTAINER = "vagrant-base-${@}-$(ARCH)"
$(FEDORA_BOXES): PACKAGE = "output/${TODAY}/vagrant-lxc-${@}-$(ARCH).box"
$(FEDORA_BOXES):
	@mkdir -p $$(dirname $(PACKAGE))
	@sudo -E ./mk-fedora.sh $(@) $(ARCH) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)

acceptance: CONTAINER = "vagrant-base-acceptance-$(ARCH)"
acceptance: PACKAGE = "output/${TODAY}/vagrant-lxc-acceptance-$(ARCH).box"
acceptance:
	@mkdir -p $$(dirname $(PACKAGE))
	@PUPPET=1 CHEF=1 sudo -E ./mk-debian.sh ubuntu precise $(ARCH) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)

release:
	@test -z '$(version)' && echo 'version parameter not provided to `make`!' && exit 1 || return 0
	gh release create -d -a output/${TODAY} $(version)
	git tag $(version)
	git push && git push --tags

clean: ALL_BOXES = ${DEBIAN_BOXES} ${UBUNTU_BOXES} ${CENTOS_BOXES} ${FEDORA_BOXES} acceptance
clean:
	@for r in $(ALL_BOXES); do \
		sudo -E ./clean.sh $${r}\
			vagrant-base-$${r}-$(ARCH) \
			output/${TODAY}/vagrant-lxc-$${r}-$(ARCH).box; \
	done
