import { Link as LibLink } from "@remix-run/react";

/**
 *
 * @param className this component does not merge className with the default classes -- it only appends -- so beware of duplicates
 */
const Link = ({
  className = "",
  ...rest
}: React.ComponentProps<typeof LibLink>) => (
  <LibLink
    className={`underline hover:no-underline focus-visible:no-underline text-blue-600 ${className}`}
    {...rest}
  />
);

export default Link;
