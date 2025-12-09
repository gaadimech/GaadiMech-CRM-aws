"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

export default function ProtectedRoute({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);

  useEffect(() => {
    // Skip protection for login page
    if (pathname === "/login") {
      setIsAuthenticated(true);
      return;
    }

    async function checkAuth() {
      try {
        const res = await fetch(`${API_BASE}/api/user/current`, {
          credentials: "include",
        });

        if (res.ok) {
          setIsAuthenticated(true);
        } else if (res.status === 401 || res.status === 302) {
          setIsAuthenticated(false);
          router.push("/login");
        } else {
          setIsAuthenticated(false);
        }
      } catch (err) {
        console.error("Auth check failed:", err);
        setIsAuthenticated(false);
        router.push("/login");
      }
    }

    checkAuth();
  }, [pathname, router]);

  // Show loading state while checking auth
  if (isAuthenticated === null && pathname !== "/login") {
    return (
      <div className="min-h-screen bg-zinc-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-zinc-900 mx-auto"></div>
          <p className="mt-4 text-zinc-600">Loading...</p>
        </div>
      </div>
    );
  }

  // Redirect to login if not authenticated (except login page)
  if (isAuthenticated === false && pathname !== "/login") {
    return null; // Router will handle redirect
  }

  return <>{children}</>;
}

