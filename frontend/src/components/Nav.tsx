"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

const navItems = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/add-lead", label: "Add Lead" },
  { href: "/followups", label: "View Followups" },
];

export default function Nav() {
  const pathname = usePathname();
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    // Check if user is admin (you can enhance this with actual API call)
    async function checkAdmin() {
      try {
        const res = await fetch(`${API_BASE}/api/user/current`, {
          credentials: "include",
        });
        if (res.ok) {
          const data = await res.json();
          setIsAdmin(data.is_admin || false);
        }
      } catch (err) {
        // Silent fail
      }
    }
    checkAdmin();
  }, []);

  return (
    <nav className="sticky top-0 z-20 bg-white/95 backdrop-blur border-b border-zinc-200">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
        <Link href="/dashboard" className="text-lg font-bold text-zinc-900">
          GaadiMech CRM
        </Link>
        <div className="flex items-center gap-1">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition ${
                pathname === item.href
                  ? "bg-zinc-900 text-white"
                  : "text-zinc-600 hover:bg-zinc-100"
              }`}
            >
              {item.label}
            </Link>
          ))}
          {isAdmin && (
            <Link
              href="/admin/leads"
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition ${
                pathname === "/admin/leads"
                  ? "bg-zinc-900 text-white"
                  : "text-zinc-600 hover:bg-zinc-100"
              }`}
            >
              Admin Leads
            </Link>
          )}
        </div>
      </div>
    </nav>
  );
}

