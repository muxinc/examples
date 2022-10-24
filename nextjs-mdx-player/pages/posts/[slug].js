import { useMemo } from 'react';
import MuxPlayer from '@mux/mux-player-react';
import { getMDXComponent } from 'mdx-bundler/client';
import { getAllPostSlugs, getPostData } from '../../utils/blogPosts';

export const getStaticProps = async ({ params }) => {
  const postData = await getPostData(params.slug);

  return {
    props: {
      ...postData,
    },
  };
};

export async function getStaticPaths() {
  const paths = getAllPostSlugs();

  return {
    paths,
    fallback: false,
  };
}

export default function BlogPost({ code, frontmatter }) {
  const Component = useMemo(() => getMDXComponent(code), [code]);

  return (
    <>
      <h1>{frontmatter.title}</h1>
      <article>
        <Component
          components={{
            MuxPlayer,
          }}
        />
      </article>
    </>
  );
}
