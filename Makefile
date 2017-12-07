
info:
	@echo ""
	@echo " docker:"
	@echo " build:"
	@echo " copy:"
	@echo " ls:"
	@echo " wd:"
	@echo " clean:"

docker:
	docker build --force-rm -f Dockerfile -t lxde-live-min .

build: docker
	docker run -i \
		--cap-add=SYS_ADMIN \
		--device /dev/loop0 \
		--privileged \
		--tty \
		--name lxde-live-min \
		lxde-live-min
	make copy

copy:
	docker cp lxde-live-min:/home/livebuilder/live/lxde-min-amd64.hybrid.iso ../

ls:
	docker exec -t lxde-live-min ls -lah

wd:
	docker exec -t lxde-live-min pwd

clean:
	docker rm -f lxde-live-min
