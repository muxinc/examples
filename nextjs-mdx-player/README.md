This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app). It has been modified to illustrate how to embed the [Mux Player](https://www.mux.com/player) into blog posts in the [.mdx](https://mdxjs.com) file format.

`utils/blogPosts.js` uses [mdx-bundler](https://github.com/kentcdodds/mdx-bundler) to process all `.mdx` files in the `blog` directory. And `pages/posts/[slug].js` renders the `<MDX Component />` and imports `<MuxPlayer />` for [Component Substitution](https://github.com/kentcdodds/mdx-bundler#component-substitution).

## Getting Started

First, run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Mux Player](https://www.mux.com/player) - a video component that integrates with [Mux](https://www.mux.com).
- [MDX](https://mdxjs.com) - JSX + markdown

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.
