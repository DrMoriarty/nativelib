const { name, description } = require('../../package')
const fs = require("fs");
const path = require("path");

module.exports = {
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#title
   */
  title: name,
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#description
   */
  description: description,

  base: "/nativelib/",

  /**
   * Extra tags to be injected to the page HTML `<head>`
   *
   * ref：https://v1.vuepress.vuejs.org/config/#head
   */
  head: [
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }]
  ],

  /**
   * Theme configuration, here is the default theme configuration for VuePress.
   *
   * ref：https://v1.vuepress.vuejs.org/theme/default-theme-config.html
   */
  themeConfig: {
    repo: '',
    editLinks: false,
    docsDir: '',
    editLinkText: '',
    lastUpdated: false,
    nav: [
      {
        text: 'Guide',
        link: '/guide/',
      },
      {
        text: 'Packages',
        link: '/packages/'
      },
      {
        text: 'Buy me a ☕',
        link: 'https://ko-fi.com/drmoriarty'
      }
    ],
    sidebar: {
      '/guide/': [
        {
          title: 'Guide',
          collapsable: false,
          children: [
            '',
            'requirements',
            'gui-usage',
            'cli-usage',
            'troubleshooting'
          ]
        }
      ],
      '/packages/': getSideBar("packages", "Packages")
    }
  },

  /**
   * Apply plugins，ref：https://v1.vuepress.vuejs.org/zh/plugin/
   */
  plugins: {
    '@vuepress/plugin-back-to-top': {},
    '@vuepress/plugin-medium-zoom': {},
    'sitemap': {
      hostname: 'https://drmoriarty.github.io',
      exclude: ['/404.html']
    },
  }
}

function getSideBar(folder, title) {
  const extension = [".md"];

  const files = fs
        .readdirSync(path.join(`${__dirname}/../${folder}`))
        .filter(
          (item) =>
          item.toLowerCase() != "readme.md" &&
            item.toLowerCase() != "index.md" &&
            fs.statSync(path.join(`${__dirname}/../${folder}`, item)).isFile() &&
            extension.includes(path.extname(item))
        );

  console.log('Side bar', files);
  return [{ title: title, collapsable: false, children: ["", ...files] }];
}
