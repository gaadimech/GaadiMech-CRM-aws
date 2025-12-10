"use client";

import { useEffect, useState } from "react";
import AddToCrmDialog from "../../components/AddToCrmDialog";
import { getTodayIST } from "../../lib/dateUtils";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

interface TeamLead {
  assignment_id: number;
  customer_name: string;
  mobile: string;
  car_model: string;
  service_type: string;
  pickup_type: string;
  scheduled_date: string;
  source: string;
  status: string;
  added_to_crm: boolean;
  assigned_at: string | null;
  assigned_date: string | null;
}

interface TeamLeadsStatistics {
  total_assigned: number;
  pending: number;
  contacted: number;
  added_to_crm: number;
}

export default function TodaysLeadsPage() {
  const [leads, setLeads] = useState<TeamLead[]>([]);
  const [statistics, setStatistics] = useState<TeamLeadsStatistics>({
    total_assigned: 0,
    pending: 0,
    contacted: 0,
    added_to_crm: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedDate, setSelectedDate] = useState(getTodayIST());
  const [search, setSearch] = useState("");
  const [showFilters, setShowFilters] = useState(false);
  const [selectedAssignmentId, setSelectedAssignmentId] = useState<number | null>(null);
  const [showAddToCrmDialog, setShowAddToCrmDialog] = useState(false);

  useEffect(() => {
    loadLeads();
  }, [selectedDate, search]);

  async function loadLeads() {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams();
      if (selectedDate) {
        params.append("assigned_date", selectedDate);
      }
      if (search) {
        params.append("search", search);
      }

      const res = await fetch(`${API_BASE}/api/team-leads?${params.toString()}`, {
        credentials: "include",
      });

      if (res.ok) {
        const data = await res.json();
        if (data.success) {
          setLeads(data.leads || []);
          setStatistics(data.statistics || {
            total_assigned: 0,
            pending: 0,
            contacted: 0,
            added_to_crm: 0,
          });
        } else {
          setError(data.message || "Failed to load leads");
        }
      } else {
        const text = await res.text();
        setError(text || "Failed to load leads");
      }
    } catch (err) {
      setError("Error loading leads");
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  function handleCall(mobile: string) {
    window.location.href = `tel:${mobile}`;
  }

  function handleWhatsApp(mobile: string) {
    // Remove any non-digit characters except +
    const cleanMobile = mobile.replace(/[^\d+]/g, "");
    // Ensure it starts with country code
    let whatsappNumber = cleanMobile;
    if (!whatsappNumber.startsWith("+")) {
      if (whatsappNumber.startsWith("91")) {
        whatsappNumber = `+${whatsappNumber}`;
      } else {
        whatsappNumber = `+91${whatsappNumber}`;
      }
    }
    window.open(`https://wa.me/${whatsappNumber.replace("+", "")}`, "_blank");
  }

  function handleAddToCrm(assignmentId: number) {
    setSelectedAssignmentId(assignmentId);
    setShowAddToCrmDialog(true);
  }

  function handleAddToCrmSuccess() {
    loadLeads();
  }

  function handleClearFilters() {
    setSelectedDate(getTodayIST());
    setSearch("");
  }

  function formatDate(dateStr: string | null) {
    if (!dateStr) return "";
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString("en-IN", {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    } catch {
      return dateStr;
    }
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-7xl px-4 py-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-zinc-900 mb-2">
            Today&apos;s Leads
          </h1>
          <p className="text-zinc-600">
            View and manage leads assigned to you
          </p>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl p-4 text-white">
            <div className="text-3xl font-bold">{statistics.total_assigned}</div>
            <div className="text-sm opacity-90">Total Assigned</div>
          </div>
          <div className="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl p-4 text-white">
            <div className="text-3xl font-bold">{statistics.pending}</div>
            <div className="text-sm opacity-90">Pending</div>
          </div>
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-4 text-white">
            <div className="text-3xl font-bold">{statistics.contacted}</div>
            <div className="text-sm opacity-90">Contacted</div>
          </div>
          <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-4 text-white">
            <div className="text-3xl font-bold">{statistics.added_to_crm}</div>
            <div className="text-sm opacity-90">Added to CRM</div>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl border border-zinc-200 p-4 mb-6">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2 text-sm font-medium text-zinc-700 hover:text-zinc-900 mb-4"
          >
            <svg
              className={`w-4 h-4 transition-transform ${
                showFilters ? "rotate-180" : ""
              }`}
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path d="M19 9l-7 7-7-7" />
            </svg>
            Filter Leads
          </button>

          {showFilters && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-medium text-zinc-700 mb-1">
                  Assigned Date
                </label>
                <input
                  type="date"
                  value={selectedDate}
                  onChange={(e) => setSelectedDate(e.target.value)}
                  className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-zinc-700 mb-1">
                  Search Customer/Car
                </label>
                <input
                  type="text"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  placeholder="Enter customer name or car model"
                  className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                />
              </div>
              <div className="flex items-end gap-2">
                <button
                  onClick={handleClearFilters}
                  className="px-4 py-2 text-sm border border-zinc-300 rounded-lg text-zinc-700 hover:bg-zinc-100 transition"
                >
                  Clear
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg mb-6">
            {error}
          </div>
        )}

        {/* Leads List */}
        {loading ? (
          <div className="text-center py-12 text-zinc-500">Loading leads...</div>
        ) : leads.length === 0 ? (
          <div className="bg-white rounded-xl border border-zinc-200 p-12 text-center">
            <p className="text-zinc-600">No leads found for the selected date.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {leads.map((lead) => (
              <div
                key={lead.assignment_id}
                className="bg-white rounded-xl border border-zinc-200 p-6 hover:shadow-md transition"
              >
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h3 className="text-lg font-semibold text-zinc-900 mb-1">
                      {lead.customer_name}
                    </h3>
                    {lead.added_to_crm && (
                      <span className="inline-block px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded">
                        Added to CRM
                      </span>
                    )}
                  </div>
                  <span className="px-3 py-1 text-xs font-medium bg-purple-100 text-purple-800 rounded">
                    {lead.status}
                  </span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div className="flex items-center gap-2 text-sm text-zinc-600">
                    <svg
                      className="w-4 h-4"
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    <span>{lead.mobile}</span>
                  </div>
                  {lead.car_model && (
                    <div className="flex items-center gap-2 text-sm text-zinc-600">
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                      </svg>
                      <span>{lead.car_model}</span>
                    </div>
                  )}
                  {lead.service_type && (
                    <div className="flex items-center gap-2 text-sm text-zinc-600">
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                      <span>{lead.service_type}</span>
                    </div>
                  )}
                  {lead.scheduled_date && (
                    <div className="flex items-center gap-2 text-sm text-zinc-600">
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      <span>{formatDate(lead.scheduled_date)}</span>
                    </div>
                  )}
                  {lead.source && (
                    <div className="flex items-center gap-2 text-sm text-zinc-600">
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                      </svg>
                      <span>{lead.source}</span>
                    </div>
                  )}
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3 pt-4 border-t border-zinc-100">
                  <button
                    onClick={() => handleCall(lead.mobile)}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 transition flex items-center justify-center gap-2"
                  >
                    <svg
                      className="w-4 h-4"
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    Call
                  </button>
                  <button
                    onClick={() => handleWhatsApp(lead.mobile)}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 transition flex items-center justify-center gap-2"
                  >
                    <svg
                      className="w-4 h-4"
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                    WhatsApp
                  </button>
                  {!lead.added_to_crm && (
                    <button
                      onClick={() => handleAddToCrm(lead.assignment_id)}
                      className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition flex items-center justify-center gap-2"
                    >
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M12 4v16m8-8H4" />
                      </svg>
                      Add to CRM
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Add to CRM Dialog */}
      <AddToCrmDialog
        assignmentId={selectedAssignmentId}
        isOpen={showAddToCrmDialog}
        onClose={() => {
          setShowAddToCrmDialog(false);
          setSelectedAssignmentId(null);
        }}
        onSuccess={handleAddToCrmSuccess}
      />
    </div>
  );
}

