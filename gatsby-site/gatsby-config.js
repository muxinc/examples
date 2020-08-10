/**
 * Configure your Gatsby site with this file.
 *
 * See: https://www.gatsbyjs.org/docs/gatsby-config/
 */

module.exports = {
  /* Your site config here */
  plugins: [
    {
      resolve: "gatsby-source-graphql",
      options: {
        // Arbitrary name for the remote schema Query type
        typeName: "mux",
        // Field under which the remote schema will be accessible. You'll use this in your Gatsby query
        fieldName: "mux",
        // Url to query from - this is the onegraph Mux API
        url: "https://serve.onegraph.com/dynamic?app_id=0b33e830-7cde-4b90-ad7e-2a39c57c0e11",
      },
    },
  ],
}
