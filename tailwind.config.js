/** @type {import('tailwindcss').Config} */
module.exports = {
  purge: ['./src/**/*.elm'], // srcディレクトリ以下の全てのElmファイルを対象にする
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
