import {
  Link,
  Links,
  Meta,
  NavLink,
  Scripts,
  ScrollRestoration,
} from "react-router";

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <header className="top-0 sticky">
          <nav className="flex items-center bg-orange-100 gap-4">
            <Link to="/">
              <img
                src="logo.png"
                alt="HeatSync Labs Member Portal Home"
                className="w-11 m-1"
              />
            </Link>
            <NavLink to="/resources">Resources</NavLink>
            <NavLink to="/computers">Computers</NavLink>
            <NavLink to="/login">Login</NavLink>
            <NavLink to="/signup">Membership Application</NavLink>
            <a href="http://wiki.heatsynclabs.org" target="_blank" className="flex items-center">
              <span>wiki</span>
              <span>
                <span className="sr-only"> opens in new tab</span>
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" aria-hidden className="w-5 ml-1">
                  {/* <!--!Font Awesome Free v7.1.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--> */}
                  <path
                    d="M354.4 83.8C359.4 71.8 371.1 64 384 64L544 64C561.7 64 576 78.3 576 96L576 256C576 268.9 568.2 280.6 556.2 285.6C544.2 290.6 530.5 287.8 521.3 278.7L464 221.3L310.6 374.6C298.1 387.1 277.8 387.1 265.3 374.6C252.8 362.1 252.8 341.8 265.3 329.3L418.7 176L361.4 118.6C352.2 109.4 349.5 95.7 354.5 83.7zM64 240C64 195.8 99.8 160 144 160L224 160C241.7 160 256 174.3 256 192C256 209.7 241.7 224 224 224L144 224C135.2 224 128 231.2 128 240L128 496C128 504.8 135.2 512 144 512L400 512C408.8 512 416 504.8 416 496L416 416C416 398.3 430.3 384 448 384C465.7 384 480 398.3 480 416L480 496C480 540.2 444.2 576 400 576L144 576C99.8 576 64 540.2 64 496L64 240z"
                  />
                </svg>
              </span>
            </a>
          </nav>
        </header>
        
        {children}

        <footer>
          <marquee>
            <div>hack your hackerspace</div>
          </marquee>
        </footer>

        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}