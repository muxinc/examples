const path = require('path')

exports.createPages = ({ graphql, actions }) => {
  const { createPage } = actions

  return new Promise((resolve, reject) => {
    const videoTemplate = path.resolve(`src/templates/video.jsx`)

    resolve(
      graphql(
        `
          {
            allAirtable(filter: { table: { eq: "Videos" } }) {
              edges {
                node {
                  id
                  data {
                    Title
                    Description
                    Status
                    Upload_ID
                    Upload_URL
                    Asset_ID
                    Playback_ID
                  }
                }
              }
            }
          }
        `
      ).then(result => {
        if (result.errors) {
          reject(result.errors)
        }

        result.data.allAirtable.edges.forEach(({ node }) => {
          createPage({
            path:
              node.data.ID +
              '-' +
              encodeURI(node.data.Title.split(' ').join('-')),
            component: videoTemplate,
            context: {
              video: node.data,
            },
          })
        })
      })
    )
  })
}
