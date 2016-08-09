# NPM PACKAGE FUNCTIONS

# installs airbnb style guide  packages & copy default eslintrc config to current directory
function nil() {
	npm install --save-dev eslint-config-airbnb eslint-plugin-import eslint-plugin-react eslint-plugin-jsx-a11y eslint
	mv  /Users/bruno/.eslintrc.global "${pwd}/.eslintrc"
}
