"use client";

import { useState, useEffect } from "react";
import type { LeadStatus } from "../lib/types";
import { getTodayIST } from "../lib/dateUtils";
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

interface AddToCrmDialogProps {
  assignmentId: number | null;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  initialData?: {
    customer_name: string;
    mobile: string;
    car_model: string;
    followup_date: string;
    status: LeadStatus;
    remarks: string;
  };
}

export default function AddToCrmDialog({
  assignmentId,
  isOpen,
  onClose,
  onSuccess,
  initialData,
}: AddToCrmDialogProps) {
  const [formData, setFormData] = useState({
    customer_name: "",
    mobile: "",
    car_registration: "",
    car_model: "",
    followup_date: getTodayIST(),
    status: "New Lead" as LeadStatus,
    remarks: "",
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isOpen && assignmentId) {
      // Load assignment details if not provided
      if (!initialData) {
        loadAssignmentDetails();
      } else {
        setFormData({
          customer_name: initialData.customer_name || "",
          mobile: initialData.mobile || "",
          car_registration: "",
          car_model: initialData.car_model || "",
          followup_date: initialData.followup_date || getTodayIST(),
          status: initialData.status || "New Lead",
          remarks: initialData.remarks || "",
        });
      }
    }
  }, [isOpen, assignmentId, initialData]);

  async function loadAssignmentDetails() {
    if (!assignmentId) return;
    
    setLoading(true);
    setError("");
    try {
      const res = await fetch(
        `${API_BASE}/api/team-leads/assignment/${assignmentId}`,
        {
          credentials: "include",
        }
      );
      const data = await res.json();
      
      if (data.success) {
        setFormData({
          customer_name: data.customer_name || "",
          mobile: data.mobile || "",
          car_registration: data.car_registration || "",
          car_model: data.car_model || "",
          followup_date: data.followup_date || getTodayIST(),
          status: data.status || "New Lead",
          remarks: data.remarks || "",
        });
      } else {
        setError(data.message || "Failed to load assignment details");
      }
    } catch (err) {
      setError("Error loading assignment details");
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handleSave() {
    if (!assignmentId) return;
    
    if (!formData.customer_name || !formData.mobile) {
      setError("Customer Name and Mobile Number are required");
      return;
    }

    setSaving(true);
    setError("");
    
    try {
      const res = await fetch(
        `${API_BASE}/api/team-leads/add-to-crm/${assignmentId}`,
        {
          method: "POST",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            customer_name: formData.customer_name,
            mobile: formData.mobile,
            car_registration: formData.car_registration,
            car_model: formData.car_model,
            followup_date: formData.followup_date,
            status: formData.status,
            remarks: formData.remarks,
          }),
        }
      );

      const data = await res.json();
      
      if (data.success) {
        onSuccess();
        onClose();
      } else {
        setError(data.message || "Failed to add lead to CRM");
      }
    } catch (err) {
      setError("Error adding lead to CRM");
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto m-4">
        <div className="sticky top-0 bg-white border-b border-zinc-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-zinc-900">
            Add Lead to CRM
          </h2>
          <button
            onClick={onClose}
            className="text-zinc-400 hover:text-zinc-600 transition"
          >
            <svg
              className="w-6 h-6"
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="p-6 space-y-4">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          {loading ? (
            <div className="text-center py-8 text-zinc-500">Loading...</div>
          ) : (
            <>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Customer Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={formData.customer_name}
                  onChange={(e) =>
                    setFormData({ ...formData, customer_name: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  placeholder="Enter customer name"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Mobile Number <span className="text-red-500">*</span>
                </label>
                <input
                  type="tel"
                  value={formData.mobile}
                  onChange={(e) =>
                    setFormData({ ...formData, mobile: e.target.value })
                  }
                  pattern="(\+91[0-9]{10}|[0-9]{10}|91[0-9]{10})"
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  placeholder="Enter +91XXXXXXXXXX, XXXXXXXXXX, or 91XXXXXXXXXX"
                  required
                />
                <p className="mt-1 text-xs text-zinc-500">
                  Enter 10 digits, or 91 followed by 10 digits, or +91 followed by 10 digits.
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Car Registration
                </label>
                <input
                  type="text"
                  value={formData.car_registration}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      car_registration: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  placeholder="Enter car registration number"
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
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  placeholder="e.g., Maruti Swift"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Follow-up Date <span className="text-red-500">*</span>
                </label>
                <input
                  type="date"
                  value={formData.followup_date}
                  onChange={(e) =>
                    setFormData({ ...formData, followup_date: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Status <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.status}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      status: e.target.value as LeadStatus,
                    })
                  }
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  required
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
                      setFormData((prev) => ({ ...prev, remarks: text }))
                    }
                    currentValue={formData.remarks}
                    size="md"
                  />
                </div>
                <textarea
                  value={formData.remarks}
                  onChange={(e) =>
                    setFormData({ ...formData, remarks: e.target.value })
                  }
                  rows={3}
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  placeholder="Enter any remarks or notes (or use the mic)"
                />
              </div>
            </>
          )}
        </div>

        <div className="sticky bottom-0 bg-white border-t border-zinc-200 px-6 py-4 flex gap-3">
          <button
            onClick={handleSave}
            disabled={saving || loading}
            className="flex-1 bg-zinc-900 text-white py-2.5 rounded-lg font-medium hover:bg-zinc-800 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? "Adding..." : "Add to CRM"}
          </button>
          <button
            onClick={onClose}
            disabled={saving}
            className="px-6 py-2.5 border border-zinc-300 rounded-lg font-medium text-zinc-700 hover:bg-zinc-100 transition disabled:opacity-50"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
}

