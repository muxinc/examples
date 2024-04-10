/**
 * v0 by Mux.
 * @see https://v0.dev/t/RlBPS8TB6is
 * Documentation: https://v0.dev/docs#integrating-generated-code-into-your-nextjs-app
 */
import Link from "next/link"
import Image from "next/image"
import Player from "./components/player"
export default function Home() {
  return (
    <div className="w-full px-4 mx-auto grid grid-rows-[auto_1fr_auto] gap-4 md:gap-6 pb-10">
      <header>
        <div className="mx-auto h-14 flex items-center gap-4">
          <Link className="flex gap-2 font-semibold items-center" href="#">
            <YoutubeIcon className="w-8 h-8 text-red-500" />
            MyTube
          </Link>
          <div className="flex-1 ml-auto">
            <form className="max-w-sm mx-auto">
              <input className="rounded-full py-2 px-4" placeholder="Search" type="search" />
            </form>
          </div>
          <button className="h-8">
            <BellIcon className="w-4 h-4" />
          </button>
          <button className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center">
            Subscribe
          </button>
        </div>
      </header>
      <main className="grid md:grid-cols-6 gap-10 items-start">
        <div className="col-span-4 grid gap-4">
          <div className="grid gap-2">
            <div className="rounded-xl overflow-hidden">
              <span className="w-full aspect-video rounded-md bg-muted">
                <Player />
              </span>
            </div>
            <div className="py-2 grid gap-2">
              <h1 className="text-xl font-semibold line-clamp-2">
                The Mux Informational: Subscribing to New Videos
              </h1>
              <div className="flex gap-2 items-center">
                <div className="flex gap-2 items-center">
                  <img
                    alt="Thumbnail"
                    className="rounded-full object-cover aspect-square"
                    height={40}
                    src="/placeholder.svg"
                    width={40}
                  />
                  <div className="text-sm">
                    <div className="font-semibold">Mux</div>
                    <div className="text-xs text-gray-500 dark:text-gray-400">70K subscribers</div>
                  </div>
                </div>
                <div className="ml-auto">
                  <button className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center">Subscribe</button>
                </div>
              </div>
            </div>
            <div className="bg-gray-100 rounded-xl p-4 text-sm dark:bg-gray-800">
              <p>
                In this video, we'll show you how to subscribe to new videos from Mux. We'll cover the basics of
                subscribing to a channel, how to get notified when new videos are uploaded, and how to manage your
                subscriptions.
              </p>
            </div>
          </div>
          <div className="grid gap-6">
            <h2 className="font-semibold text-xl">110 Comments</h2>
            <div className="text-sm flex items-start gap-4">
              <Image src="/placeholder-user.jpg" alt="@shadcn" width={10} height={10} className="w-10 h-10 border" />
              <div className="grid gap-1.5">
                <div className="flex items-center gap-2">
                  <div className="font-semibold">@burttunes</div>
                  <div className="text-gray-500 text-xs dark:text-gray-400">5 months ago</div>
                </div>
                <div>
                  I'm so excited to see how Mux is going to change the way we build video applications. 🚀
                </div>
              </div>
            </div>
            <div className="text-sm flex items-start gap-4">
              <Image src="/placeholder-user.jpg" alt="@shadcn" width={10} height={10} className="w-10 h-10 border" />
              <div className="grid gap-1.5">
                <div className="flex items-center gap-2">
                  <div className="font-semibold">@gogetem</div>
                  <div className="text-gray-500 text-xs dark:text-gray-400">2 months ago</div>
                </div>
                <div>
                  We are more than excited to leverage all the new stuff, building better products for our clients ✨
                </div>
              </div>
            </div>
            <div className="text-sm flex items-start gap-4">
              <Image src="/placeholder-user.jpg" alt="@shadcn" width={10} height={10} className="w-10 h-10 border" />
              <div className="grid gap-1.5">
                <div className="flex items-center gap-2">
                  <div className="font-semibold">@watergal123</div>
                  <div className="text-gray-500 text-xs dark:text-gray-400">6 days ago</div>
                </div>
                <div>does anyone know which monospace are they using when showing code?</div>
              </div>
            </div>
          </div>
        </div>
        <div className="col-span-2 grid gap-4">
          <div className="flex items-start gap-4 relative">
            <Link className="absolute inset-0" href="#">
              <span className="sr-only">View</span>
            </Link>
            <img
              alt="Thumbnail"
              className="aspect-video rounded-lg object-cover"
              height={94}
              src="/placeholder.svg"
              width={168}
            />
            <div className="text-sm">
              <div className="font-medium line-clamp-2">How to use Mux with Next.js</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">Mux</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">300K views · 5 days ago</div>
            </div>
          </div>
          <div className="flex items-start gap-4 relative">
            <Link className="absolute inset-0" href="#">
              <span className="sr-only">View</span>
            </Link>
            <img
              alt="Thumbnail"
              className="aspect-video rounded-lg object-cover"
              height={94}
              src="/placeholder.svg"
              width={168}
            />
            <div className="text-sm">
              <div className="font-medium line-clamp-2">Building a Video Player with Mux</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">Mux</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">1.2M views · 2 months ago</div>
            </div>
          </div>
          <div className="flex items-start gap-4 relative">
            <Link className="absolute inset-0" href="#">
              <span className="sr-only">View</span>
            </Link>
            <img
              alt="Thumbnail"
              className="aspect-video rounded-lg object-cover"
              height={94}
              src="/placeholder.svg"
              width={168}
            />
            <div className="text-sm">
              <div className="font-medium line-clamp-2">Using Mux Data with Next.js</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">Dave Kiss</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">21K views · 1 week ago</div>
            </div>
          </div>
          <div className="flex items-start gap-4 relative">
            <Link className="absolute inset-0" href="#">
              <span className="sr-only">View</span>
            </Link>
            <img
              alt="Thumbnail"
              className="aspect-video rounded-lg object-cover"
              height={94}
              src="/placeholder.svg"
              width={168}
            />
            <div className="text-sm">
              <div className="font-medium line-clamp-2">Getting Started with Mux</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">Darius</div>
              <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">12K views · 10 days ago</div>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

function BellIcon(props: any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" />
      <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
    </svg>
  )
}


function YoutubeIcon(props: any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M2.5 17a24.12 24.12 0 0 1 0-10 2 2 0 0 1 1.4-1.4 49.56 49.56 0 0 1 16.2 0A2 2 0 0 1 21.5 7a24.12 24.12 0 0 1 0 10 2 2 0 0 1-1.4 1.4 49.55 49.55 0 0 1-16.2 0A2 2 0 0 1 2.5 17" />
      <path d="m10 15 5-3-5-3z" />
    </svg>
  )
}