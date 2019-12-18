.PHONY: build clean deploy

build:
	# tried to install `dep` with `brew`, but still got the error:
	# .../aws-golang-http-get-post is not within a known GOPATH/src
	# so, tyring to comment `dep ensure -v` out
	# (if it's not obvious, I don't know `golang` very much, if at all)
	# dep ensure -v
	env GOOS=linux go build -ldflags="-s -w" -o bin/getBin getFolder/getExample.go
	env GOOS=linux go build -ldflags="-s -w" -o bin/postBin postFolder/postExample.go
	env GOOS=linux go build -ldflags="-s -w" -o bin/getQueryBin getFolder/getQueryExample.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose
