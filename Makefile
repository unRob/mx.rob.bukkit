LOCAL_BUKKIT=$(shell xmllint --xpath "//dict/key[text()='ProgramArguments'][1]/following-sibling::array[1]/string[2]/text()" my.bukkit.plist)
EXECUTABLE_PATH=$(shell xmllint --xpath "//dict/key[text()='Program']/following-sibling::string[1]/text()" my.bukkit.plist)

my.bukkit.plist:
	sed -e "s|USER|$(USER)|" < mx.rob.bukkit.plist > my.bukkit.plist
	$(EDITOR) my.bukkit.plist

setup-bukkit:
	mkdir -pv $(LOCAL_BUKKIT)/template
	cp -rv ./template $(LOCAL_BUKKIT)/template
	cp bukkit.sh $(EXECUTABLE_PATH)

install: my.bukkit.plist
	$(MAKE) setup-bukkit
	cp my.bukkit.plist ~/Library/LaunchAgents/
	launchctl load ~/Library/LaunchAgents/my.bukkit.plist

# gifsicle \
#   -O3 "$(TARGET).gif" \
#   --resize-fit 300x300 \
#   --colors 64 \
#   -o "dst/$(TARGET)".gif \
#   +x \
#   --dither \
#   --lossy=50 \
#   --delete '#0-20' '#200-' --done

.PHONY: setup-bukkit optimize