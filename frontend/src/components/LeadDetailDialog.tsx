"use client";

import { useState, useEffect } from "react";
import type { Lead, LeadStatus } from "../lib/types";
import StatusBadge from "./StatusBadge";
import { formatDateIST, formatDateTimeIST } from "../lib/dateUtils";
import VoiceInputButton from "./VoiceInputButton";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

const STATUS_OPTIONS: LeadStatus[] = [
  "New Lead",
  "Needs Followup",
  "Did Not Pick Up",
  "Confirmed",
  "Open",
  "Completed",
  "Feedback",
];

interface LeadDetailDialogProps {
  lead: Lead | null;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: () => void;
  isAdmin: boolean;
}

export default function LeadDetailDialog({
  lead,
  isOpen,
  onClose,
  onUpdate,
  isAdmin,
}: LeadDetailDialogProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    customer_name: "",
    mobile: "",
    car_registration: "",
    car_model: "",
    followup_date: "",
    status: "Needs Followup" as LeadStatus,
    remarks: "",
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (lead) {
      // Convert followup_date from UTC ISO to IST date string (YYYY-MM-DD)
      let followupDate = "";
      if (lead.followup_date) {
        const d = new Date(lead.followup_date);
        // Get date in IST timezone
        const istString = d.toLocaleString("en-US", {
          timeZone: "Asia/Kolkata",
          year: "numeric",
          month: "2-digit",
          day: "2-digit",
        });
        // Convert MM/DD/YYYY to YYYY-MM-DD
        const [month, day, year] = istString.split("/");
        followupDate = `${year}-${month}-${day}`;
      }
      
      setFormData({
        customer_name: lead.customer_name || "",
        mobile: lead.mobile || "",
        car_registration: lead.car_registration || "",
        car_model: (lead as any).car_model || "",
        followup_date: followupDate,
        status: lead.status || "Needs Followup",
        remarks: lead.remarks || "",
      });
      setIsEditing(false);
    }
  }, [lead]);

  if (!isOpen || !lead) return null;

  async function handleSave() {
    if (!lead) return;
    
    setSaving(true);
    try {
      // Convert followup_date from YYYY-MM-DD to UTC ISO format
      // We need to ensure the date stays exactly as the user selected it
      // Send the date as a string in YYYY-MM-DD format to avoid timezone conversion issues
      let followupDateTime = formData.followup_date || null;

      const res = await fetch(`${API_BASE}/api/followups/${lead.id}`, {
        method: "PATCH",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          customer_name: formData.customer_name,
          mobile: formData.mobile,
          car_registration: formData.car_registration,
          car_model: formData.car_model,
          followup_date: followupDateTime,
          status: formData.status,
          remarks: formData.remarks,
        }),
      });

      if (res.ok) {
        setIsEditing(false);
        onUpdate();
        onClose();
      } else {
        alert("Failed to update lead");
      }
    } catch (err) {
      console.error("Error updating lead:", err);
      alert("Error updating lead");
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!lead || !isAdmin) return;
    if (!confirm("Are you sure you want to delete this lead?")) return;

    try {
      const res = await fetch(`${API_BASE}/api/followups/${lead.id}`, {
        method: "DELETE",
        credentials: "include",
      });

      if (res.ok) {
        onUpdate();
        onClose();
      } else {
        alert("Failed to delete lead");
      }
    } catch (err) {
      console.error("Error deleting lead:", err);
      alert("Error deleting lead");
    }
  }

  return (
    <div
      className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="p-6 border-b border-zinc-200 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-zinc-900">
            Lead Details
          </h2>
          <button
            onClick={onClose}
            className="text-zinc-400 hover:text-zinc-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="p-6 space-y-4">
          {isEditing ? (
            <>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Customer Name
                </label>
                <input
                  type="text"
                  value={formData.customer_name}
                  onChange={(e) =>
                    setFormData({ ...formData, customer_name: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Mobile
                </label>
                <input
                  type="tel"
                  value={formData.mobile}
                  onChange={(e) =>
                    setFormData({ ...formData, mobile: e.target.value })
                  }
                  pattern="(\+91[0-9]{10}|[0-9]{10}|91[0-9]{10})"
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                  placeholder="+917404625111, 7404625111, or 917404625111"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Car Registration
                </label>
                <input
                  type="text"
                  value={formData.car_registration}
                  onChange={(e) =>
                    setFormData({ ...formData, car_registration: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Car Model
                </label>
                <input
                  type="text"
                  value={formData.car_model}
                  onChange={(e) =>
                    setFormData({ ...formData, car_model: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                  placeholder="e.g., Maruti Celerio, Hyundai i20"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Followup Date
                </label>
                <input
                  type="date"
                  value={formData.followup_date}
                  onChange={(e) =>
                    setFormData({ ...formData, followup_date: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Status
                </label>
                <select
                  value={formData.status}
                  onChange={(e) =>
                    setFormData({ ...formData, status: e.target.value as LeadStatus })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                >
                  {STATUS_OPTIONS.map((status) => (
                    <option key={status} value={status}>
                      {status}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block text-sm font-medium text-zinc-700">
                    Remarks
                  </label>
                  <VoiceInputButton
                    onTranscript={(text) =>
                      setFormData({ ...formData, remarks: text })
                    }
                    currentValue={formData.remarks}
                    size="sm"
                  />
                </div>
                <textarea
                  value={formData.remarks}
                  onChange={(e) =>
                    setFormData({ ...formData, remarks: e.target.value })
                  }
                  rows={4}
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm"
                  placeholder="Click mic icon to use voice input"
                />
              </div>
            </>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Customer Name</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.customer_name || "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Mobile</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.mobile || "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Car Registration</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.car_registration || "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Car Model</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {(lead as any).car_model || "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Status</p>
                  <StatusBadge status={lead.status} />
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Followup Date</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {formatDateIST(lead.followup_date)}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Created</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.created_at ? formatDateTimeIST(lead.created_at) : "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Modified</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.modified_at ? formatDateTimeIST(lead.modified_at) : "—"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-zinc-500 mb-1">Created By</p>
                  <p className="text-sm font-medium text-zinc-900">
                    {lead.creator_name || "—"}
                  </p>
                </div>
              </div>
              <div>
                <p className="text-xs text-zinc-500 mb-1">Remarks</p>
                <p className="text-sm text-zinc-900 whitespace-pre-wrap">
                  {lead.remarks || "—"}
                </p>
              </div>
            </>
          )}
        </div>

        <div className="p-6 border-t border-zinc-200 flex items-center justify-between gap-2">
          <div>
            {isAdmin && !isEditing && (
              <button
                onClick={handleDelete}
                className="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700"
              >
                Delete
              </button>
            )}
          </div>
          <div className="flex gap-2">
            {isEditing ? (
              <>
                <button
                  onClick={() => setIsEditing(false)}
                  className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSave}
                  disabled={saving}
                  className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800 disabled:opacity-50"
                >
                  {saving ? "Saving..." : "Save"}
                </button>
              </>
            ) : (
              <>
                <button
                  onClick={onClose}
                  className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100"
                >
                  Close
                </button>
                <button
                  onClick={() => setIsEditing(true)}
                  className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800"
                >
                  Edit
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

