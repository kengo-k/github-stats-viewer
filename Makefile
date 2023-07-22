build:
	elm make src/Main.elm --output=main.js

dev:
	elm-live src/Main.elm --start-page=index.html -- --output=main.js --debug

test:
	elm-test

deploy:
	elm make src/Main.elm --output=docs/main.js && \
	npx vercel --prod --token $$(cat vercel_token)

css:
	npx postcss styles.css -o _styles.css && \
	npx cleancss -o docs/main.css _styles.css && \
	rm _styles.css

dev-css:
	npx onchange "src/**/*.elm" styles.scss custom.scss -- sh -c 'npx node-sass styles.scss styles.css && npx postcss styles.css -o main.css'
