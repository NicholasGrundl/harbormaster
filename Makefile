#### Context ####
.PHONY: context
context: context.clean context.settings


.PHONY: context.settings
context.settings:
	repo2txt -r . -o ./context/context-settings.txt \
	--exclude-dir context old \
	--ignore-types \
	--ignore-files LICENSE README.md \
	&& python -c 'import sys; open("context/context-settings.md","wb").write(open("context/context-settings.txt","rb").read().replace(b"\0",b""))' \
	&& rm ./context/context-settings.txt

.PHONY: context.clean
context.clean:
	@if [ -f ./context/context-* ]; then rm ./context/context-*; fi
