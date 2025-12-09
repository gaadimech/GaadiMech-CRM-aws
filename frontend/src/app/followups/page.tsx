"use client";

import { useEffect, useState } from "react";
import Nav from "../../components/Nav";
import StatusBadge from "../../components/StatusBadge";
import ActionButtons from "../../components/ActionButtons";
import type { Lead, LeadStatus } from "../../lib/types";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

const STATUS_OPTIONS: LeadStatus[] = [
  "All Status",
  "Needs Followup",
  "Did Not Pick Up",
  "Confirmed",
  "Open",
  "Completed",
  "Feedback",
] as any;

function formatDate(dateIso: string) {
  const d = new Date(dateIso);
  return d.toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatDateTime(dateIso: string) {
  const d = new Date(dateIso);
  return d.toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default function FollowupsPage() {
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    search: "",
    followup_date: "",
    created_date: "",
    modified_date: "",
    car_registration: "",
    mobile: "",
    status: "All Status" as string,
    user_id: "",
  });
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    loadFollowups();
  }, [filters, page]);

  async function loadFollowups() {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (filters.search) params.set("search", filters.search);
      if (filters.followup_date) params.set("date", filters.followup_date);
      if (filters.created_date) params.set("created_date", filters.created_date);
      if (filters.modified_date) params.set("modified_date", filters.modified_date);
      if (filters.car_registration)
        params.set("car_registration", filters.car_registration);
      if (filters.mobile) params.set("mobile", filters.mobile);
      if (filters.status && filters.status !== "All Status")
        params.set("status", filters.status);
      if (filters.user_id) params.set("user_id", filters.user_id);
      params.set("page", String(page));
      params.set("per_page", "50");

      const res = await fetch(`${API_BASE}/api/followups?${params.toString()}`, {
        credentials: "include",
      });

      if (res.ok) {
        const data = await res.json();
        setLeads(data.leads || []);
        setTotalPages(data.total_pages || 1);
      }
    } catch (err) {
      console.error("Failed to load followups:", err);
    } finally {
      setLoading(false);
    }
  }

  function handleFilterChange(
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
    setPage(1); // Reset to first page on filter change
  }

  function handleReset() {
    setFilters({
      search: "",
      followup_date: "",
      created_date: "",
      modified_date: "",
      car_registration: "",
      mobile: "",
      status: "All Status",
      user_id: "",
    });
    setPage(1);
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <Nav />
      <main className="mx-auto max-w-6xl px-4 py-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-zinc-900 mb-2">View Followups</h1>
          <p className="text-sm text-zinc-600">Search and filter all leads</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl border border-zinc-200 p-4 mb-6">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Search
              </label>
              <input
                type="text"
                name="search"
                value={filters.search}
                onChange={handleFilterChange}
                placeholder="Search name, mobile, car..."
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Followup Date
              </label>
              <input
                type="date"
                name="followup_date"
                value={filters.followup_date}
                onChange={handleFilterChange}
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Created Date
              </label>
              <input
                type="date"
                name="created_date"
                value={filters.created_date}
                onChange={handleFilterChange}
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Car Registration
              </label>
              <input
                type="text"
                name="car_registration"
                value={filters.car_registration}
                onChange={handleFilterChange}
                placeholder="Enter registration number"
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Mobile Number
              </label>
              <input
                type="tel"
                name="mobile"
                value={filters.mobile}
                onChange={handleFilterChange}
                placeholder="Enter mobile number"
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-zinc-700 mb-1">
                Status
              </label>
              <select
                name="status"
                value={filters.status}
                onChange={handleFilterChange}
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
              >
                {STATUS_OPTIONS.map((status) => (
                  <option key={status} value={status}>
                    {status}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="flex gap-2 mt-4">
            <button
              onClick={loadFollowups}
              className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800"
            >
              Search
            </button>
            <button
              onClick={handleReset}
              className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100"
            >
              Reset
            </button>
          </div>
        </div>

        {/* Results */}
        <div className="bg-white rounded-xl border border-zinc-200 overflow-hidden">
          <div className="p-4 border-b border-zinc-200">
            <h2 className="text-lg font-semibold text-zinc-900">
              All Team Leads ({leads.length} shown)
            </h2>
          </div>

          {loading ? (
            <div className="p-8 text-center text-zinc-500">Loading...</div>
          ) : leads.length === 0 ? (
            <div className="p-8 text-center text-zinc-500">No leads found</div>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-zinc-50">
                    <tr>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Customer
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Mobile
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Followup Date
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Status
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Remarks
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Created
                      </th>
                      <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {leads.map((lead) => (
                      <tr
                        key={lead.id}
                        className="border-b border-zinc-100 hover:bg-zinc-50"
                      >
                        <td className="py-3 px-4 text-zinc-900 font-medium">
                          {lead.customer_name || "Unnamed"}
                        </td>
                        <td className="py-3 px-4">
                          <a
                            href={`tel:${lead.mobile}`}
                            className="text-blue-600 hover:underline"
                          >
                            {lead.mobile}
                          </a>
                        </td>
                        <td className="py-3 px-4 text-zinc-700">
                          {formatDate(lead.followup_date)}
                        </td>
                        <td className="py-3 px-4">
                          <StatusBadge status={lead.status} />
                        </td>
                        <td className="py-3 px-4 text-zinc-600 max-w-xs truncate">
                          {lead.remarks || "—"}
                        </td>
                        <td className="py-3 px-4 text-zinc-500 text-xs">
                          {lead.created_at
                            ? formatDateTime(lead.created_at)
                            : "—"}
                        </td>
                        <td className="py-3 px-4">
                          <ActionButtons lead={lead} compact />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="p-4 border-t border-zinc-200 flex items-center justify-between">
                  <button
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                    className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100 disabled:opacity-50"
                  >
                    Previous
                  </button>
                  <span className="text-sm text-zinc-600">
                    Page {page} of {totalPages}
                  </span>
                  <button
                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    disabled={page === totalPages}
                    className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100 disabled:opacity-50"
                  >
                    Next
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </main>
    </div>
  );
}

