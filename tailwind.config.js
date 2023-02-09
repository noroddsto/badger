/** @type {import('tailwindcss').Config} */
const plugin = require("tailwindcss/plugin")
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "./src/**/*.{html,js,ts,jsx,tsx,elm}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'baijamjuree': ['Bai Jamjuree', 'sans-serif'],
        'sans': ['Roboto Flex', ...defaultTheme.fontFamily.sans],
      },
      boxShadow: {
        'inset-sm-c': 'inset 0 1px 2px rgba(0,0,0,0.15)',
        'sm-c': '0 1px 2px rgba(0,0,0,0.15)',
        '5xl': '0 4px 16px rgba(0,0,0,0.15)'
      },
      backgroundImage: {
        'grid': "url('../images/background_grid.svg')"
      },
    },
  },
  plugins: [
    plugin(
      function ({ addUtilities, e }) {

        // this class define how would you call it for ex 'variant-caps-[value]' 
        const yourClass = 'variant-caps';

        // key - Tailwind 'caller', value - actual CSS property value
        const values = {
          'normal': 'normal',
          'small-caps': 'small-caps',
          'all-small-caps': 'all-small-caps',
          'petite-caps': 'petite-caps',
          'all-petite-caps': 'all-petite-caps',
          'unicase': 'unicase',
          'titling-caps': 'titling-caps',
          'inherit': 'inherit',
          'initial': 'initial',
          'revert': 'revert',
          'revert-layer': 'revert-layer',
          'unset': 'unset',
        };

        // add support for responsive variants so you can use it like sm:variant-ligature-normal 
        const variants = ['responsive'];

        addUtilities(
          [
            Object.entries(values).map(([key, value]) => {
              return {
                [`.${e(`${yourClass}-${key}`)}`]: {
                  'font-variant-caps': value, // CSS
                },
              }
            }),
          ],
          { variants }
        );
      }
    )
  ],
}
