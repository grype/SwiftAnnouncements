SCHEME := SwiftAnnouncements

.PHONY: default all clean build test linuxmain install-git-hooks

default: all 

all: clean build test

clean:
	xcodebuild -scheme $(SCHEME) clean

build:
	xcodebuild -scheme $(SCHEME) build

test: build
	xcodebuild -scheme $(SCHEME) test
