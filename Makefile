PACKER = packer

providers = libvirt parallels virtualbox vmware

ifeq ($(HEADLESS),)
packerbuildvars = -var-file=vars.json
else
packerbuildvars = -var-file=vars.json -var headless=$(HEADLESS)
endif

define target

all: $2

$2: $2.box

$2.box: http/$1/* scripts/$1.sh templates/$1.json vars.json
ifneq ($(shell uname -s),Linux)
	$(if $(findstring -libvirt,$2),cd linuxbuild && vagrant up && vagrant ssh -c 'make $(MAKEOVERRIDES) -C /vagrant $2' && vagrant halt,$(PACKER) build $(packerbuildvars) -only=$2 templates/$1.json)
else
	$(PACKER) build $(packerbuildvars) $(if $(findstring -libvirt,$2),-var vagrantcloud_no_release=false) -only=$2 templates/$1.json
endif

$(foreach provider,libvirt parallels virtualbox vmware,$(if $(findstring $(provider),$2),$(patsubst %-$(provider),%,$2): $2))
$(foreach provider,libvirt parallels virtualbox vmware,$(if $(findstring $(provider),$2),$(provider): $2))
$(foreach bits,32 64,$(foreach provider,$(providers),$(if $(findstring -$(bits)-$(provider),$2),$(patsubst %-$(bits)-$(provider),%-$(provider),$2): $2)))
$(foreach bits,32 64,$(foreach provider,$(providers),$(if $(findstring -$(bits)-$(provider),$2),$(patsubst %-$(bits)-$(provider),%,$2): $2)))

endef

$(foreach template,$(wildcard templates/*.json),$(foreach builder,$(shell jq -r '.builders[] | .name' $(template)),$(eval $(call target,$(patsubst templates/%.json,%,$(template)),$(builder)))))
