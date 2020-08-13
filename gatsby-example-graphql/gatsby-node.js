/**
 * Implement Gatsby's Node APIs in this file.
 *
 * See: https://www.gatsbyjs.org/docs/node-apis/
 */

exports.createPages = async function ({ actions, graphql }) {
  actions.createPage({
    path: '/',
    component: require.resolve('./src/templates/index.js'),
    context: {
      tokenId: process.env.MUX_TOKEN_ID,
      tokenSecret: process.env.MUX_TOKEN_SECRET,
    }
  });
}
