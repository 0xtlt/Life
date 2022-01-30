build:
	cargo build --release --target=x86_64-unknown-linux-musl

# Run build an no optimized docker image and run it
# Passing the ./simulation as /simulation folder
# The image name is "Life"
run:
	docker build -t life .
	docker run -it --rm -v $(PWD)/simulation:/simulation life

run_machine:
	docker build -t life . --build-arg --TYPE=ownMachine
	docker run -it --rm -v $(PWD)/simulation:/simulation -p 6080:6080 -p 127.0.0.1:9222:9222 life

run_machine_debug:
	docker build --no-cache --progress=plain -t life --build-arg --TYPE=ownMachine .
	docker run -it --rm -v $(PWD)/simulation:/simulation life