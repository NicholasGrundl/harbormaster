# TODO

The current setup is fine but i want:
- make my own nginx image in the artifact repository
    - include the default conf.d file in it
    - add a default port EXPOSE
    - add default CMD
- volume mount the environment overides nginx file only
- simplify the docker compsoe for nginx
    - remove the volume mount of the default in the docker compose

