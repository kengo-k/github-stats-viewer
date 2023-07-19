build:
	elm make src/Main.elm --output=main.js

dev:
	elm-live src/Main.elm --start-page=index.html -- --output=main.js

test:
	elm-test

deploy:
	elm make src/Main.elm --output=docs/main.js && \
	npx vercel --prod --token $$(cat vercel_token)
