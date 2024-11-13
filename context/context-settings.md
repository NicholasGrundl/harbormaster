Repository Documentation
This document provides a comprehensive overview of the repository's structure and contents.
The first section, titled 'Directory/File Tree', displays the repository's hierarchy in a tree format.
In this section, directories and files are listed using tree branches to indicate their structure and relationships.
Following the tree representation, the 'File Content' section details the contents of each file in the repository.
Each file's content is introduced with a '[File Begins]' marker followed by the file's relative path,
and the content is displayed verbatim. The end of each file's content is marked with a '[File Ends]' marker.
This format ensures a clear and orderly presentation of both the structure and the detailed contents of the repository.

Directory/File Tree Begins -->

./
├── Makefile
├── TODO.md

<-- Directory/File Tree Ends

File Content Begin -->
[File Begins] Makefile
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

[File Ends] Makefile

[File Begins] TODO.md
# Reimplement

I want to reconfigure my app to be in separate repos to make development easier

This repo will be fore deployment and setting up the VPS

# 1. VPS Setup and scripts

Setting up and accessing a new VPS
- [ ] digital ocean droplet makefile
- [ ] docs with steps for setup
- [ ] where to keep secrets...?

# 2. Dockercompose

Docker compose files for dev and prod
- [ ] mount secrets as per the new `README.md`
- [ ] mount nginx configs (find a good way to do this)
- [ ] local/dev versus prod
- [ ] pull images from GAR

# 3. GCloud Registry setup

Setup and configure the google artifact registry 
- [ ] New registry setup
- [ ] credentials
- [ ] service worker setup

4. Deployment

Semi manual deployment to the VPS
- [ ] pulling images
- [ ] updating secrets files
- [ ] service accounts

5. Docs

Update docs with common routines
[File Ends] TODO.md


<-- File Content Ends

