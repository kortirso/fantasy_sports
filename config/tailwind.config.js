const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx}',
    './app/views/**/*.{erb,html}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Source Sans Pro', ...defaultTheme.fontFamily.sans],
      },
      minHeight: {
        '6': '1.5rem',
      },
      maxWidth: {
        '8xl': '90rem',
      },
      colors: {
        goldeen: {
          light: '#f8f8f8',
          support: '#ffc57b',
          supportMiddle: '#ee7b41',
          supportDark: '#d54110',
          gray: '#d5d5de',
          dark: '#0e0e0e'
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}

