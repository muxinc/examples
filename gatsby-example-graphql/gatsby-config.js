/**
 * Configure your Gatsby site with this file.
 *
 * See: https://www.gatsbyjs.org/docs/gatsby-config/
 */

require("dotenv").config({
  path: `.env.${process.env.NODE_ENV}`,
})

module.exports = {
  /* Your site config here */
  plugins: [
    {
      resolve: "gatsby-source-graphql",
      options: {
        // Arbitrary name for the remote schema Query type
        typeName: "OneGraph",
        // Field under which the remote schema will be accessible. You'll use this in your Gatsby query
        fieldName: "onegraph",
        // Url to query from - this is the onegraph Mux API
        url: `https://serve.onegraph.com/dynamic?app_id=${process.env.ONEGRAPH_APP_ID}`,
      },
    },
  ],
}
