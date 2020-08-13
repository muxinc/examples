import React from "react"
import { graphql } from 'gatsby'
import VideoPlayer from '../components/video-player'

export default function Home({ data }) {
  return (
    <div className="wrapper">
      <h1>Gatsby + Mux (GraphQL example)</h1>
      <ul>
        {
          data.onegraph.mux.video.assets.edges.filter(({ node }) => {
            return node.status === 'ready' && node.playbackIds && node.playbackIds[0]
          }).map(({ node }) => (
            <li key={node.id}>
              <div className="video-container">
                <VideoPlayer src={node.playbackIds[0].playbackUrl} poster={node.playbackIds[0].thumbnail} />
                <div className="asset-info">
                  <div className="asset-id">
                    <span className="label">asset:</span> {node.id}
                  </div>
                  <div className="playback-id">
                    <span className="label">playback:</span> {node.playbackIds[0].id}
                  </div>
                </div>
              </div>
            </li>
          ))
        }
      </ul>
    </div>
  )
}

export const query = graphql`
  query($tokenId: String!, $tokenSecret: String!) {
    onegraph {
      mux(auths: {muxAuth: {accessToken: {tokenId: $tokenId, secret: $tokenSecret}}}) {
        video {
          assets {
            edges {
              node {
                isTest
                isLive
                status
                id
                playbackIds {
                  id
                  playbackUrl
                  thumbnail(extension:PNG time:1)
                }
              }
            }
          }
        }
      }
    }
  }
`
