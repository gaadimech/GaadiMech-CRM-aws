"use client";

import { useEffect, useState } from "react";
import StatusBadge from "../../components/StatusBadge";
import ActionButtons from "../../components/ActionButtons";
import LeadDetailDialog from "../../components/LeadDetailDialog";
import { fetchQueue, fetchTeamMembers, fetchCurrentUser } from "../../lib/api";
import type { QueueItem } from "../../lib/types";
import { getTodayIST, formatDateIST, formatDateTimeIST } from "../../lib/dateUtils";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

interface DashboardMetrics {
  todays_followups: number;
  initial_assignment: number;
  completion_rate: number;
  new_leads_today: number;
  completed_followups: number;
  pending_followups: number;
}

interface TeamMember {
  id: number;
  name: string;
  assigned: number;
  worked: number;
  pending: number;
  completion_rate: number;
  new_leads: number;
}

interface TeamMemberOption {
  id: number;
  name: string;
  username: string;
}

function formatTime(dateIso: string) {
  if (!dateIso) return "";
  const d = new Date(dateIso);
  return d.toLocaleTimeString("en-IN", { 
    timeZone: "Asia/Kolkata",
    hour: "2-digit", 
    minute: "2-digit" 
  });
}

function formatDate(dateIso: string) {
  if (!dateIso) return "";
  // Use formatDateIST to ensure proper IST conversion
  const formatted = formatDateIST(dateIso);
  // Extract just the date part (day month) without year for display
  const parts = formatted.split(" ");
  return `${parts[0]} ${parts[1]}`;
}

export default function DashboardPage() {
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [teamPerformance, setTeamPerformance] = useState<TeamMember[]>([]);
  const [todaysFollowups, setTodaysFollowups] = useState<QueueItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState(getTodayIST());
  const [selectedTeamMember, setSelectedTeamMember] = useState<number | null>(null);
  const [teamMembers, setTeamMembers] = useState<TeamMemberOption[]>([]);
  const [isAdmin, setIsAdmin] = useState(false);
  const [editingLead, setEditingLead] = useState<QueueItem | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Fetch current user and team members on mount
  useEffect(() => {
    async function loadUserAndTeam() {
      try {
        const user = await fetchCurrentUser();
        setIsAdmin(user.is_admin || false);
        
        // Only fetch team members if user is admin
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
    loadDashboard();
  }, [selectedDate, selectedTeamMember]);

  async function loadDashboard() {
    setLoading(true);
    try {
      // Build query params
      const params = new URLSearchParams();
      params.set("date", selectedDate);
      if (selectedTeamMember) {
        params.set("user_id", String(selectedTeamMember));
      }

      // Fetch dashboard metrics
      const metricsRes = await fetch(
        `${API_BASE}/api/dashboard/metrics?${params.toString()}`,
        { credentials: "include" }
      );
      if (metricsRes.ok) {
        const metricsData = await metricsRes.json();
        setMetrics(metricsData);
      }

      // Fetch team performance
      const teamRes = await fetch(
        `${API_BASE}/api/dashboard/team-performance?${params.toString()}`,
        { credentials: "include" }
      );
      if (teamRes.ok) {
        const teamData = await teamRes.json();
        setTeamPerformance(teamData);
      }

      // Fetch today's followups (show all like the old UI)
      const queueData = await fetchQueue({ 
        date: selectedDate,
        user_id: selectedTeamMember || undefined
      });
      
      // Sort by status priority (most important first)
      // Priority order: New Lead > Feedback > Confirmed > Open > Completed > Needs Followup > Did not Pick up
      const statusPriority: Record<string, number> = {
        "New Lead": 0,              // First priority
        "Feedback": 1,              // Second priority
        "Confirmed": 2,            // Third priority
        "Open": 3,                  // Fourth priority
        "Completed": 4,             // Fifth priority
        "Needs Followup": 5,        // Sixth priority
        "Did Not Pick Up": 6,       // Seventh priority
      };
      
      const sortedItems = (queueData.items || []).sort((a, b) => {
        // Normalize status strings (trim whitespace)
        const statusA = (a.status || "").trim();
        const statusB = (b.status || "").trim();
        
        // Get priority (default to 99 for unknown statuses)
        const priorityA = statusPriority[statusA] ?? 99;
        const priorityB = statusPriority[statusB] ?? 99;
        
        // Sort by priority (lower number = higher priority = comes first)
        if (priorityA !== priorityB) {
          return priorityA - priorityB;
        }
        // If same priority, sort by followup_date (earlier first)
        const dateA = a.followup_date ? new Date(a.followup_date).getTime() : 0;
        const dateB = b.followup_date ? new Date(b.followup_date).getTime() : 0;
        return dateA - dateB;
      });
      
      setTodaysFollowups(sortedItems);
      setCurrentPage(1); // Reset to first page when data changes
    } catch (err) {
      console.error("Failed to load dashboard:", err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-7xl px-2 sm:px-4 py-4 sm:py-6">
        {/* Header */}
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-zinc-900">Dashboard</h1>
            <p className="text-sm text-zinc-600">Overview of today's activities</p>
          </div>
          <div className="flex items-center gap-2">
            {isAdmin && teamMembers.length > 0 && (
              <select
                value={selectedTeamMember || ""}
                onChange={(e) => setSelectedTeamMember(e.target.value ? Number(e.target.value) : null)}
                className="px-3 py-2 border border-zinc-300 rounded-lg text-sm bg-white"
              >
                <option value="">All Team Members</option>
                {teamMembers.map((member) => (
                  <option key={member.id} value={member.id}>
                    {member.name}
                  </option>
                ))}
              </select>
            )}
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="px-3 py-2 border border-zinc-300 rounded-lg text-sm"
            />
            <button
              onClick={loadDashboard}
              className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800"
            >
              Refresh
            </button>
          </div>
        </div>

        {/* Metrics Cards */}
        {metrics && (
          <div className="grid grid-cols-2 gap-2 sm:gap-4 mb-4 sm:mb-6 lg:grid-cols-4">
            <div className="bg-purple-50 border border-purple-200 rounded-xl p-3 sm:p-4">
              <p className="text-xs sm:text-sm text-purple-700 mb-1">Today's Followups</p>
              <p className="text-xl sm:text-2xl font-bold text-purple-900">
                {metrics.todays_followups}
              </p>
              <p className="text-xs text-purple-600 mt-1">
                {metrics.pending_followups} pending
              </p>
            </div>
            <div className="bg-green-50 border border-green-200 rounded-xl p-3 sm:p-4">
              <p className="text-xs sm:text-sm text-green-700 mb-1">Initial Assignment</p>
              <p className="text-xl sm:text-2xl font-bold text-green-900">
                {metrics.initial_assignment}
              </p>
              <p className="text-xs text-green-600 mt-1">Fixed at 5:00 AM IST</p>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 sm:p-4">
              <p className="text-xs sm:text-sm text-blue-700 mb-1">Completion Rate</p>
              <p className="text-xl sm:text-2xl font-bold text-blue-900">
                {metrics.completion_rate.toFixed(1)}%
              </p>
              <p className="text-xs text-blue-600 mt-1">
                {metrics.completed_followups} of {metrics.initial_assignment} done
              </p>
            </div>
            <div className="bg-pink-50 border border-pink-200 rounded-xl p-3 sm:p-4">
              <p className="text-xs sm:text-sm text-pink-700 mb-1">New Leads Today</p>
              <p className="text-xl sm:text-2xl font-bold text-pink-900">
                {metrics.new_leads_today}
              </p>
              <p className="text-xs text-pink-600 mt-1">Fresh leads added</p>
            </div>
          </div>
        )}

        {/* Today's Followups */}
        <div className="bg-white rounded-xl border border-zinc-200 p-4 sm:p-6 mb-4 sm:mb-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-zinc-900">
              Pending Followups for {new Date(selectedDate).toLocaleDateString("en-IN", {
                day: "numeric",
                month: "short",
                year: "numeric"
              })}
            </h2>
            <div className="flex items-center gap-4">
              {!loading && todaysFollowups.length > 0 && (
                <span className="text-sm text-zinc-500">
                  {todaysFollowups.length} total
                </span>
              )}
              {!loading && todaysFollowups.length > itemsPerPage && (
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                    className="px-3 py-1 text-sm border border-zinc-300 rounded-lg hover:bg-zinc-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    ←
                  </button>
                  <span className="text-sm text-zinc-600">
                    Page {currentPage} of {Math.ceil(todaysFollowups.length / itemsPerPage)}
                  </span>
                  <button
                    onClick={() => setCurrentPage((p) => Math.min(Math.ceil(todaysFollowups.length / itemsPerPage), p + 1))}
                    disabled={currentPage >= Math.ceil(todaysFollowups.length / itemsPerPage)}
                    className="px-3 py-1 text-sm border border-zinc-300 rounded-lg hover:bg-zinc-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    →
                  </button>
                </div>
              )}
            </div>
          </div>
          {loading ? (
            <p className="text-sm text-zinc-500">Loading...</p>
          ) : todaysFollowups.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-sm text-zinc-500 mb-2">
                No pending followups for {new Date(selectedDate).toLocaleDateString("en-IN", {
                  day: "numeric",
                  month: "short",
                  year: "numeric"
                })}
              </p>
              <p className="text-xs text-zinc-400">
                All followups for this date are completed or confirmed
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {todaysFollowups
                .slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
                .map((item) => (
                <div
                  key={item.id}
                  className="flex items-start justify-between gap-4 p-3 rounded-lg border border-zinc-200 hover:bg-zinc-50"
                >
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-medium text-zinc-900">
                        {item.customer_name || "Unnamed"}
                      </h3>
                      <StatusBadge status={item.status} />
                      {item.overdue && (
                        <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded">
                          Overdue
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-zinc-600">{item.mobile}</p>
                    <p className="text-xs text-zinc-500">
                      {item.car_registration || "No reg"} •{" "}
                      {item.followup_date ? formatDateIST(item.followup_date) : ""} {item.followup_date ? formatTime(item.followup_date) : ""}
                    </p>
                    {item.remarks && (
                      <p className="text-xs text-zinc-600 mt-1 line-clamp-1">
                        {item.remarks}
                      </p>
                    )}
                  </div>
                  <ActionButtons 
                    lead={item} 
                    compact 
                    onEditClick={() => setEditingLead(item)}
                  />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Team Performance */}
        {teamPerformance.length > 0 && (
          <div className="bg-white rounded-xl border border-zinc-200 p-4 sm:p-6">
            <h2 className="text-base sm:text-lg font-semibold text-zinc-900 mb-4">
              Team Performance - Daily Progress
            </h2>
            <div className="overflow-x-auto -mx-2 sm:mx-0">
              <table className="w-full text-xs sm:text-sm min-w-[600px]">
                <thead>
                  <tr className="border-b border-zinc-200">
                    <th className="text-left py-2 px-3 text-zinc-600 font-medium">
                      Rank
                    </th>
                    <th className="text-left py-2 px-3 text-zinc-600 font-medium">
                      Team Member
                    </th>
                    <th className="text-right py-2 px-3 text-zinc-600 font-medium">
                      Assigned
                    </th>
                    <th className="text-right py-2 px-3 text-zinc-600 font-medium">
                      Worked
                    </th>
                    <th className="text-right py-2 px-3 text-zinc-600 font-medium">
                      Pending
                    </th>
                    <th className="text-right py-2 px-3 text-zinc-600 font-medium">
                      Completion
                    </th>
                    <th className="text-right py-2 px-3 text-zinc-600 font-medium">
                      New Leads
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {teamPerformance.map((member, idx) => (
                    <tr key={member.id} className="border-b border-zinc-100">
                      <td className="py-2 px-3 text-zinc-900">#{idx + 1}</td>
                      <td className="py-2 px-3 font-medium text-zinc-900">
                        {member.name}
                      </td>
                      <td className="py-2 px-3 text-right text-zinc-700">
                        {member.assigned}
                      </td>
                      <td className="py-2 px-3 text-right text-zinc-700">
                        {member.worked}
                      </td>
                      <td className="py-2 px-3 text-right text-zinc-700">
                        {member.pending}
                      </td>
                      <td className="py-2 px-3 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <div className="w-20 bg-zinc-200 rounded-full h-2">
                            <div
                              className={`h-2 rounded-full ${
                                member.completion_rate >= 100
                                  ? "bg-green-500"
                                  : member.completion_rate >= 50
                                  ? "bg-yellow-500"
                                  : "bg-red-500"
                              }`}
                              style={{ width: `${Math.min(member.completion_rate, 100)}%` }}
                            />
                          </div>
                          <span className="text-xs text-zinc-600 w-12 text-right">
                            {member.completion_rate.toFixed(1)}%
                          </span>
                        </div>
                      </td>
                      <td className="py-2 px-3 text-right text-zinc-700">
                        {member.new_leads}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Lead Detail Dialog */}
        <LeadDetailDialog
          lead={editingLead}
          isOpen={editingLead !== null}
          onClose={() => setEditingLead(null)}
          onUpdate={() => {
            setEditingLead(null);
            loadDashboard();
          }}
          isAdmin={isAdmin}
        />
      </div>
    </div>
  );
}

