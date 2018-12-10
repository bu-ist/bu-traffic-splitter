# HTTP Traffic Splitter

This docker image is helpful when you need to re-route HTTP requests from one
container to two other ones in your development environment.


## Environment Variables

Variable name  | Default value
---------------|---------------
DNS_RESOLVER   | auto
DEFAULT_URL    | -
ALTERNATE_MASK | -
ALTERNATE_URL  | -
INTERCEPT_URL  | -
ALTERNATE_REF  | -
DEBUG          | -


## Sample Usage

### Split Traffic By Mask

Use `DEFAULT_URL` for the default route, `ALTERNATE_URL` for the alternative
route and `ALTERNATE_MASK` to determine when to switch from the default to
the alternative. 

In the example below, requests like `http://localhost:3000/`,
`http://localhost:3000/login`, `http://localhost:3000/pagename`, etc will be
proxied to the `app-server` container. The requests like
`http://localhost:3000/static/css/file.css`, `http://localhost:3000/static/js/file.js`,
etc will be proxied to the `static-content` container.

```
version: "3.4"

services:
  app-server:
    # Serving dynamic content

  static-content:
    # Serving static content

  splitter:
    image: bostonuniversity/traffic-splitter:latest
    ports:
      - 3000:80
    environment:
      DEFAULT_URL: http://app-server:80
      ALTERNATE_MASK: static
      ALTERNATE_URL: http://static-content:80
    depends_on:
      - app-server
      - static-content

```


### Intercept Traffic Outside Of Docker Network

Sometimes, your app contains links to resources that you want to be served
from a third-party server on prod and from the localhost while developing
locally.

In many cases, developers default to having an `if/else` statement
in their HTML templates that changes the URL depending on some condition but
that's error-prone. The best option is to always use prod-like references in
your source HTML but "teach" the dev environment to use the alternative ones.

For example, you want to serve your minified JS from CDN in prod but work
with unminified local code in dev. The example below assumes that your
CDN URL is `cdn.com` and your HTML links to resources like 
`http://cdn.com/lib/script.js`.

If you use the config similar to the one below, the following will happen:

- `http://cdn.com/lib/script.js` will become `http://localhost:3000/cdn.com/lib/script.js`
- Requests to `http://localhost:3000/cdn.com` will be proxied to `static-content`

```
version: "3.4"

services:
  app-server:
    # Serving dynamic content

  static-content:
    # Serving static content

  splitter:
    image: bostonuniversity/traffic-splitter:latest
    ports:
      - 3000:80
    environment:
      DEFAULT_URL: http://app-server:80
      ALTERNATE_URL: http://static-content:80
      INTERCEPT_MASK: cdn.com
    depends_on:
      - app-server

```


### Forge Referrer For Intercepted Traffic

In some cases, CDNs and other content servers are configured to only serve
content to those requests that come with certain referrers.

The example below assumes that you have HTML containing references to
`http://protected.cdn.com` that only allows the content to be requested from
`http://authorized.application.com`.

If you use the config similar to the one below, the following will happen:

- `http://protected.cdn.com/lib/script.js` will become
`http://localhost:3000/protected.cdn.com/lib/script.js`
- Requests to `http://localhost:3000/protected.cdn.com` will be proxied to
`http://protected.cdn.com` with the header `Referer: authorized.application.com`


```
version: "3.4"

services:
  app-server:
    # Serving dynamic content

  splitter:
    image: bostonuniversity/traffic-splitter:latest
    ports:
      - 3000:80
    environment:
      DEBUG: 1
      DEFAULT_URL: http://app-server:80
      INTERCEPT_MASK: protected.cdn.com
      ALTERNATE_REF: authorized.application.com
    depends_on:
      - app-server

```
