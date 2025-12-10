"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

const navItems = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/add-lead", label: "Add Lead" },
  { href: "/todays-leads", label: "Today's Leads" },
  { href: "/followups", label: "View Followups" },
  { href: "/whatsapp-templates", label: "Whatsapp Templates" },
];

const adminNavItems = [
  { href: "/admin/leads", label: "Admin Leads" },
  { href: "/password-manager", label: "Password Manager" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const [isAdmin, setIsAdmin] = useState(false);
  const [userName, setUserName] = useState("");
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    async function checkUser() {
      try {
        const res = await fetch(`${API_BASE}/api/user/current`, {
          credentials: "include",
        });
        if (res.ok) {
          const data = await res.json();
          setIsAdmin(data.is_admin || false);
          setUserName(data.name || data.username || "User");
        }
      } catch (err) {
        // Silent fail
      }
    }
    checkUser();
  }, []);

  async function handleLogout() {
    try {
      const API_BASE =
        process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
        "http://localhost:5000";
      
      await fetch(`${API_BASE}/logout`, {
        method: "GET",
        credentials: "include",
        headers: {
          "Accept": "application/json",
        },
      });
      
      router.push("/login");
      router.refresh();
    } catch (err) {
      console.error("Logout error:", err);
      // Still redirect to login
      router.push("/login");
    }
  }

  // Don't show sidebar on login page
  if (pathname === "/login") {
    return null;
  }

  return (
    <>
      {/* Hamburger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`fixed z-50 p-2 bg-white border border-zinc-200 rounded-lg shadow-sm hover:bg-zinc-50 transition ${
          isOpen ? "left-[260px] top-4" : "left-4 top-4"
        }`}
        aria-label="Toggle sidebar"
      >
        <svg
          className="w-5 h-5 text-zinc-900"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          {isOpen ? (
            <path d="M6 18L18 6M6 6l12 12" />
          ) : (
            <path d="M4 6h16M4 12h16M4 18h16" />
          )}
        </svg>
      </button>

      {/* Sidebar */}
      <aside
        className={`fixed left-0 top-0 h-screen bg-white border-r border-zinc-200 flex flex-col z-40 transition-all duration-300 ease-in-out ${
          isOpen ? "w-64" : "-translate-x-full w-64"
        }`}
      >
        {/* Logo/Header */}
        <div className="p-6 border-b border-zinc-200">
          <h1 className="text-lg font-semibold text-zinc-900">GaadiMech CRM</h1>
          {userName && (
            <p className="text-sm text-zinc-600 mt-1">{userName}</p>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-1">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setIsOpen(false)}
              className={`block px-4 py-2.5 rounded-lg text-sm font-medium transition ${
                pathname === item.href
                  ? "bg-zinc-100 text-zinc-900"
                  : "text-zinc-700 hover:bg-zinc-50 hover:text-zinc-900"
              }`}
            >
              {item.label}
            </Link>
          ))}
          {isAdmin && (
            <>
              {adminNavItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setIsOpen(false)}
                  className={`block px-4 py-2.5 rounded-lg text-sm font-medium transition ${
                    pathname === item.href
                      ? "bg-zinc-100 text-zinc-900"
                      : "text-zinc-700 hover:bg-zinc-50 hover:text-zinc-900"
                  }`}
                >
                  {item.label}
                </Link>
              ))}
            </>
          )}
        </nav>

        {/* Logout Button */}
        <div className="p-4 border-t border-zinc-200">
          <button
            onClick={handleLogout}
            className="w-full px-4 py-2.5 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-50 hover:text-zinc-900 transition text-left"
          >
            Logout
          </button>
        </div>
      </aside>

      {/* Overlay for mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/20 z-30 md:hidden"
          onClick={() => setIsOpen(false)}
        />
      )}
    </>
  );
}

