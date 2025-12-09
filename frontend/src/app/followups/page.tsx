"use client";

import { useEffect, useState } from "react";
import StatusBadge from "../../components/StatusBadge";
import ActionButtons from "../../components/ActionButtons";
import LeadDetailDialog from "../../components/LeadDetailDialog";
import { fetchFollowups, fetchTeamMembers, fetchCurrentUser } from "../../lib/api";
import { getTodayIST, formatDateIST, formatDateTimeIST } from "../../lib/dateUtils";
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

export default function FollowupsPage() {
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);
  const [teamMembers, setTeamMembers] = useState<Array<{ id: number; name: string }>>([]);
  const [filters, setFilters] = useState({
    search: "",
    followup_date: getTodayIST(), // Default to today's date in IST
    created_date: "",
    modified_date: "",
    car_registration: "",
    mobile: "",
    status: "All Status" as string,
    user_id: "",
  });
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [total, setTotal] = useState(0);

  // Load user and team members on mount
  useEffect(() => {
    async function loadUserAndTeam() {
      try {
        const user = await fetchCurrentUser();
        setIsAdmin(user.is_admin || false);
        
        if (user.is_admin) {
          try {
            const teamData = await fetchTeamMembers();
            setTeamMembers(teamData.members || []);
          } catch (err) {
            console.error("Failed to load team members:", err);
          }
        }
      } catch (err) {
        console.error("Failed to load user:", err);
      }
    }
    loadUserAndTeam();
  }, []);

  useEffect(() => {
    loadFollowups();
  }, [filters, page]);

  async function loadFollowups() {
    setLoading(true);
    try {
      const data = await fetchFollowups({
        search: filters.search || undefined,
        date: filters.followup_date || undefined,
        created_date: filters.created_date || undefined,
        modified_date: filters.modified_date || undefined,
        car_registration: filters.car_registration || undefined,
        mobile: filters.mobile || undefined,
        status: filters.status !== "All Status" ? filters.status : undefined,
        user_id: filters.user_id || undefined,
        page,
        per_page: 50,
      });
      
      setLeads(data.leads || []);
      setTotalPages(data.total_pages || 1);
      setTotal(data.total || 0);
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
      followup_date: getTodayIST(), // Reset to today
      created_date: "",
      modified_date: "",
      car_registration: "",
      mobile: "",
      status: "All Status",
      user_id: "",
    });
    setPage(1);
  }

  function handleRowClick(lead: Lead) {
    setSelectedLead(lead);
    setIsDialogOpen(true);
  }

  function handleDialogClose() {
    setIsDialogOpen(false);
    setSelectedLead(null);
  }

  function handleDialogUpdate() {
    loadFollowups();
  }

  async function handleEdit(lead: Lead) {
    setSelectedLead(lead);
    setIsDialogOpen(true);
  }

  async function handleDelete(lead: Lead) {
    if (!isAdmin) return;
    if (!confirm(`Are you sure you want to delete lead for ${lead.customer_name || lead.mobile}?`)) return;

    try {
      const res = await fetch(`${API_BASE}/api/followups/${lead.id}`, {
        method: "DELETE",
        credentials: "include",
      });

      if (res.ok) {
        loadFollowups();
      } else {
        alert("Failed to delete lead");
      }
    } catch (err) {
      console.error("Error deleting lead:", err);
      alert("Error deleting lead");
    }
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-7xl px-2 sm:px-4 py-4 sm:py-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-zinc-900 mb-2">View Followups</h1>
          <p className="text-sm text-zinc-600">Search and filter all leads</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl border border-zinc-200 p-4 mb-6">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {isAdmin && teamMembers.length > 0 && (
              <div>
                <label className="block text-xs font-medium text-zinc-700 mb-1">
                  Team Member
                </label>
                <select
                  name="user_id"
                  value={filters.user_id}
                  onChange={handleFilterChange}
                  className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent bg-white"
                >
                  <option value="">All Team Members</option>
                  {teamMembers.map((member) => (
                    <option key={member.id} value={member.id}>
                      {member.name}
                    </option>
                  ))}
                </select>
              </div>
            )}
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
          <div className="p-4 border-b border-zinc-200 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-zinc-900">
              All Team Leads ({total} total, {leads.length} shown)
            </h2>
            {totalPages > 1 && (
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page === 1}
                  className="p-2 border border-zinc-300 rounded-lg hover:bg-zinc-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  aria-label="Previous page"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
                <span className="text-sm text-zinc-600 px-2">
                  Page {page} of {totalPages}
                </span>
                <button
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                  disabled={page === totalPages}
                  className="p-2 border border-zinc-300 rounded-lg hover:bg-zinc-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  aria-label="Next page"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              </div>
            )}
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
                        Modified
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
                        onClick={() => handleRowClick(lead)}
                        className="border-b border-zinc-100 hover:bg-zinc-50 cursor-pointer"
                      >
                        <td className="py-3 px-4 text-zinc-900 font-medium">
                          {lead.customer_name || "Unnamed"}
                        </td>
                        <td className="py-3 px-4">
                          <a
                            href={`tel:${lead.mobile}`}
                            onClick={(e) => e.stopPropagation()}
                            className="text-blue-600 hover:underline"
                          >
                            {lead.mobile}
                          </a>
                        </td>
                        <td className="py-3 px-4 text-zinc-700">
                          {formatDateIST(lead.followup_date)}
                        </td>
                        <td className="py-3 px-4">
                          <StatusBadge status={lead.status} />
                        </td>
                        <td className="py-3 px-4 text-zinc-600 max-w-xs truncate">
                          {lead.remarks || "—"}
                        </td>
                        <td className="py-3 px-4 text-zinc-500 text-xs">
                          {lead.created_at
                            ? formatDateTimeIST(lead.created_at)
                            : "—"}
                        </td>
                        <td className="py-3 px-4 text-zinc-500 text-xs">
                          {lead.modified_at
                            ? formatDateTimeIST(lead.modified_at)
                            : "—"}
                        </td>
                        <td className="py-3 px-4" onClick={(e) => e.stopPropagation()}>
                          <div className="flex items-center gap-2">
                            <ActionButtons lead={lead} compact />
                            <button
                              onClick={() => handleEdit(lead)}
                              className="px-2 py-1 text-xs border border-zinc-300 rounded text-zinc-700 hover:bg-zinc-100"
                              title="Edit"
                            >
                              Edit
                            </button>
                            {isAdmin && (
                              <button
                                onClick={() => handleDelete(lead)}
                                className="px-2 py-1 text-xs border border-red-300 rounded text-red-700 hover:bg-red-50"
                                title="Delete"
                              >
                                Delete
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Lead Detail Dialog */}
      <LeadDetailDialog
        lead={selectedLead}
        isOpen={isDialogOpen}
        onClose={handleDialogClose}
        onUpdate={handleDialogUpdate}
        isAdmin={isAdmin}
      />
    </div>
  );
}
