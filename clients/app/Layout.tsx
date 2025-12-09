import type React from 'react';
import { Links, Meta, Scripts, ScrollRestoration } from 'react-router';
import AppSidebar from './lib/layout/AppSidebar';
import Backdrop from './lib/layout/Backdrop';
import { SidebarProvider, useSidebar } from './lib/context/SidebarContext';
import AppHeader from './lib/layout/AppHeader';
import { ThemeProvider } from './lib/context/ThemeContext';
import { useAuth } from './lib/utils/store';

// Layout will bear all your Providers :>
export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider>
      <SidebarProvider>
        <TheRealLayout>{children}</TheRealLayout>
      </SidebarProvider>
    </ThemeProvider>
  );
}

function TheRealLayout({ children }: { children: React.ReactNode }) {
  useAuth();
  const { isExpanded, isHovered, isMobileOpen } = useSidebar();

  // Dynamic class for main content margin based on sidebar state
  const mainContentMargin = isMobileOpen
    ? 'ml-0'
    : isExpanded || isHovered
      ? 'xl:ml-[290px]'
      : 'xl:ml-[90px]';

  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <div className="min-h-screen xl:flex">
          {/* Sidebar and Backdrop */}
          <AppSidebar />
          <Backdrop />
          {/* Main Content Area */}
          <div
            className={`flex-1 transition-all  duration-300 ease-in-out ${mainContentMargin}`}
          >
            {/* Header */}
            <AppHeader />
            {/* Page Content */}
            <div className="p-4 mx-auto max-w-(--breakpoint-2xl) md:p-6">
              {children}
            </div>
          </div>
        </div>

        <footer>
          <div>hack your hackerspace</div>
        </footer>

        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}
