/**
 * v0 by Mux.
 * @see https://v0.dev/t/RlBPS8TB6is
 * Documentation: https://v0.dev/docs#integrating-generated-code-into-your-nextjs-app
 */
import Link from 'next/link';
import Image from 'next/image';
import FeedContainer from '../components/FeedContainer';
import ApiTriggers from '../components/ApiTriggers';
export default function Home() {
  return (
    <main className="grid md:grid-cols-6 gap-10 items-start">
      <div className="col-span-4 grid gap-4">
        <ApiTriggers></ApiTriggers>
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
            <div className="font-medium line-clamp-2">
              How to use Mux with Next.js
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              Mux
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              300K views · 5 days ago
            </div>
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
            <div className="font-medium line-clamp-2">
              Building a Video Player with Mux
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              Mux
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              1.2M views · 2 months ago
            </div>
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
            <div className="font-medium line-clamp-2">
              Using Mux Data with Next.js
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              Dave Kiss
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              21K views · 1 week ago
            </div>
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
            <div className="font-medium line-clamp-2">
              Getting Started with Mux
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              Darius
            </div>
            <div className="text-xs text-gray-500 line-clamp-1 dark:text-gray-400">
              12K views · 10 days ago
            </div>
          </div>
        </div>
      </div>
    </main>
  );
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
  );
}
