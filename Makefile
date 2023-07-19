build:
	elm make src/Main.elm --output=main.js

run:
	elm-live src/Main.elm --start-page=index.html -- --output=main.js

test:
	elm-test
