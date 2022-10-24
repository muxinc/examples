import Head from "next/head";
import Link from "next/link";
import { getPostsData } from "../utils/blogPosts";

import styles from "../styles/Home.module.css";

export default function Home({ allPostsData }) {
  return (
    <div className={styles.container}>
      <Head>
        <title>Create Next App</title>
        <meta name="description" content="Generated by create next app" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h2 className={styles.heading}>Blog</h2>
        <ul className={styles.list}>
          {allPostsData.map(({ slug, title }) => (
            <li className={styles.listItem} key={slug}>
              <Link href={`/posts/${slug}`}>
                <a>{title}</a>
              </Link>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}

export async function getStaticProps() {
  const allPostsData = getPostsData();

  return {
    props: {
      allPostsData,
    },
  };
}
