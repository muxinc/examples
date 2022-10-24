import fs from "fs";
import path from "path";
import matter from "gray-matter";
import { bundleMDX } from "mdx-bundler";

const blogDirectory = path.join(process.cwd(), "blog");

export function getPostsData() {
  const fileNames = fs.readdirSync(blogDirectory);

  const allPostsData = fileNames.map((fileName) => {
    const slug = fileName.replace(/\.mdx$/, "");

    const fullPath = path.join(blogDirectory, fileName);
    const fileContents = fs.readFileSync(fullPath, "utf8");

    const matterResult = matter(fileContents);

    return {
      slug,
      ...matterResult.data,
    };
  });

  return allPostsData;
}

export function getAllPostSlugs() {
  const fileNames = fs.readdirSync(blogDirectory);
  return fileNames.map((fileName) => {
    return {
      params: {
        slug: fileName.replace(/\.mdx$/, ""),
      },
    };
  });
}

export async function getPostData(slug) {
  const fullPath = path.join(blogDirectory, `${slug}.mdx`);
  const source = fs.readFileSync(fullPath, "utf8");

  const { code, frontmatter } = await bundleMDX({
    source,
  });

  return {
    slug,
    frontmatter,
    code,
  };
}
