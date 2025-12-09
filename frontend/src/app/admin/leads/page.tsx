"use client";

import { useEffect, useState } from "react";
import Nav from "../../../components/Nav";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

interface UnassignedLead {
  id: number;
  mobile: string;
  customer_name?: string;
  car_manufacturer?: string;
  car_model?: string;
  pickup_type?: string;
  service_type?: string;
  scheduled_date?: string;
  source?: string;
  remarks?: string;
  created_at: string;
  assigned_to?: string;
}

interface TeamMember {
  id: number;
  name: string;
}

export default function AdminLeadsPage() {
  const [unassignedLeads, setUnassignedLeads] = useState<UnassignedLead[]>([]);
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [parseText, setParseText] = useState("");
  const [parseResult, setParseResult] = useState<any>(null);
  const [formData, setFormData] = useState({
    mobile: "",
    customer_name: "",
    car_manufacturer: "",
    car_model: "",
    pickup_type: "",
    service_type: "",
    scheduled_date: "",
    source: "Website",
    remarks: "",
    assign_to: "",
  });
  const [search, setSearch] = useState("");
  const [createdDate, setCreatedDate] = useState("");

  useEffect(() => {
    loadData();
  }, [search, createdDate]);

  async function loadData() {
    setLoading(true);
    try {
      // Load unassigned leads
      const params = new URLSearchParams();
      if (search) params.set("search", search);
      if (createdDate) params.set("created_date", createdDate);

      const leadsRes = await fetch(
        `${API_BASE}/api/admin/unassigned-leads?${params.toString()}`,
        { credentials: "include" }
      );
      if (leadsRes.ok) {
        const leadsData = await leadsRes.json();
        setUnassignedLeads(leadsData.leads || []);
      }

      // Load team members
      const teamRes = await fetch(`${API_BASE}/api/admin/team-members`, {
        credentials: "include",
      });
      if (teamRes.ok) {
        const teamData = await teamRes.json();
        setTeamMembers(teamData.members || []);
      }
    } catch (err) {
      console.error("Failed to load data:", err);
    } finally {
      setLoading(false);
    }
  }

  async function handleParseText() {
    if (!parseText.trim()) return;

    try {
      const res = await fetch(`${API_BASE}/api/parse-customer-text`, {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text: parseText }),
      });

      if (res.ok) {
        const data = await res.json();
        setParseResult(data.data);
        // Auto-fill form if parsing successful
        if (data.data && data.success) {
          setFormData((prev) => ({
            ...prev,
            mobile: data.data.mobile || prev.mobile,
            customer_name: data.data.customer_name || prev.customer_name,
            car_manufacturer: data.data.car_manufacturer || prev.car_manufacturer,
            car_model: data.data.car_model || prev.car_model,
            service_type: data.data.service_type || prev.service_type,
            remarks: data.data.remarks || prev.remarks,
          }));
        }
      }
    } catch (err) {
      console.error("Failed to parse text:", err);
    }
  }

  async function handleAddLead(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.mobile || !formData.assign_to) {
      alert("Mobile number and team member assignment are required");
      return;
    }

    try {
      const formDataToSend = new URLSearchParams();
      Object.entries(formData).forEach(([key, value]) => {
        if (value) formDataToSend.append(key, value);
      });

      const res = await fetch(`${API_BASE}/admin_leads`, {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: formDataToSend.toString(),
      });

      if (res.ok) {
        alert("Lead added and assigned successfully!");
        setFormData({
          mobile: "",
          customer_name: "",
          car_manufacturer: "",
          car_model: "",
          pickup_type: "",
          service_type: "",
          scheduled_date: "",
          source: "Website",
          remarks: "",
          assign_to: "",
        });
        loadData();
      } else {
        alert("Failed to add lead");
      }
    } catch (err) {
      console.error("Failed to add lead:", err);
      alert("Error adding lead");
    }
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <Nav />
      <main className="mx-auto max-w-6xl px-4 py-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-zinc-900 mb-2">Admin Leads</h1>
          <p className="text-sm text-zinc-600">Manage unassigned leads and team assignments</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left Column: AI Parser & Add Lead Form */}
          <div className="space-y-6">
            {/* AI Text Parser */}
            <div className="bg-white rounded-xl border border-zinc-200 p-6">
              <h2 className="text-lg font-semibold text-zinc-900 mb-4">
                AI Text Parser - Extract Customer Information
              </h2>
              <div className="space-y-3">
                <textarea
                  value={parseText}
                  onChange={(e) => setParseText(e.target.value)}
                  placeholder="Paste your message here..."
                  rows={6}
                  className="w-full px-4 py-3 border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                />
                <button
                  onClick={handleParseText}
                  className="w-full bg-blue-600 text-white py-2.5 rounded-lg font-medium hover:bg-blue-700 transition"
                >
                  Parse Text
                </button>
                {parseResult && (
                  <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg text-sm">
                    <pre className="whitespace-pre-wrap text-xs">
                      {JSON.stringify(parseResult, null, 2)}
                    </pre>
                  </div>
                )}
              </div>
            </div>

            {/* Add New Lead Form */}
            <div className="bg-white rounded-xl border border-zinc-200 p-6">
              <h2 className="text-lg font-semibold text-zinc-900 mb-4">
                Add New Lead & Assign to Team
              </h2>
              <form onSubmit={handleAddLead} className="space-y-3">
                <div>
                  <label className="block text-xs font-medium text-zinc-700 mb-1">
                    Mobile Number *
                  </label>
                  <input
                    type="tel"
                    value={formData.mobile}
                    onChange={(e) =>
                      setFormData((prev) => ({ ...prev, mobile: e.target.value }))
                    }
                    required
                    pattern="[0-9]{10,12}"
                    className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    placeholder="Enter 10 or 12 digit mobile number"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-zinc-700 mb-1">
                    Customer Name
                  </label>
                  <input
                    type="text"
                    value={formData.customer_name}
                    onChange={(e) =>
                      setFormData((prev) => ({ ...prev, customer_name: e.target.value }))
                    }
                    className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    placeholder="Enter customer name"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Car Manufacturer
                    </label>
                    <input
                      type="text"
                      value={formData.car_manufacturer}
                      onChange={(e) =>
                        setFormData((prev) => ({
                          ...prev,
                          car_manufacturer: e.target.value,
                        }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                      placeholder="e.g., Maruti, Hyundai"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Car Model
                    </label>
                    <input
                      type="text"
                      value={formData.car_model}
                      onChange={(e) =>
                        setFormData((prev) => ({ ...prev, car_model: e.target.value }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                      placeholder="e.g., Swift, i20"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Pickup Type
                    </label>
                    <select
                      value={formData.pickup_type}
                      onChange={(e) =>
                        setFormData((prev) => ({ ...prev, pickup_type: e.target.value }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    >
                      <option value="">Select pickup type</option>
                      <option value="Pickup">Pickup</option>
                      <option value="Self Walkin">Self Walkin</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Service Type
                    </label>
                    <select
                      value={formData.service_type}
                      onChange={(e) =>
                        setFormData((prev) => ({ ...prev, service_type: e.target.value }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    >
                      <option value="">Select service type</option>
                      <option value="Express Car Service">Express Car Service</option>
                      <option value="Dent Paint">Dent Paint</option>
                      <option value="AC Service">AC Service</option>
                      <option value="Car Wash">Car Wash</option>
                      <option value="Repairs">Repairs</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Scheduled Date
                    </label>
                    <input
                      type="date"
                      value={formData.scheduled_date}
                      onChange={(e) =>
                        setFormData((prev) => ({ ...prev, scheduled_date: e.target.value }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-zinc-700 mb-1">
                      Source
                    </label>
                    <select
                      value={formData.source}
                      onChange={(e) =>
                        setFormData((prev) => ({ ...prev, source: e.target.value }))
                      }
                      className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    >
                      <option value="Website">Website</option>
                      <option value="WhatsApp">WhatsApp</option>
                      <option value="Chatbot">Chatbot</option>
                      <option value="Social Media">Social Media</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-zinc-700 mb-1">
                    Remarks
                  </label>
                  <textarea
                    value={formData.remarks}
                    onChange={(e) =>
                      setFormData((prev) => ({ ...prev, remarks: e.target.value }))
                    }
                    rows={3}
                    className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                    placeholder="Add any additional notes or remarks"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-zinc-700 mb-1">
                    Assign to Team Member *
                  </label>
                  <select
                    value={formData.assign_to}
                    onChange={(e) =>
                      setFormData((prev) => ({ ...prev, assign_to: e.target.value }))
                    }
                    required
                    className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  >
                    <option value="">Select team member</option>
                    {teamMembers.map((member) => (
                      <option key={member.id} value={member.id}>
                        {member.name}
                      </option>
                    ))}
                  </select>
                </div>

                <button
                  type="submit"
                  className="w-full bg-zinc-900 text-white py-2.5 rounded-lg font-medium hover:bg-zinc-800 transition"
                >
                  + Add Lead
                </button>
              </form>
            </div>
          </div>

          {/* Right Column: Recent Leads */}
          <div className="bg-white rounded-xl border border-zinc-200 p-6">
            <h2 className="text-lg font-semibold text-zinc-900 mb-4">Recent Leads</h2>

            {/* Filters */}
            <div className="mb-4 space-y-2">
              <input
                type="date"
                value={createdDate}
                onChange={(e) => setCreatedDate(e.target.value)}
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg"
              />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search name/car"
                className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg"
              />
            </div>

            {loading ? (
              <div className="text-center py-8 text-zinc-500">Loading...</div>
            ) : unassignedLeads.length === 0 ? (
              <div className="text-center py-8 text-zinc-500">No leads found</div>
            ) : (
              <div className="space-y-2">
                {unassignedLeads.map((lead) => (
                  <div
                    key={lead.id}
                    className="p-3 border border-zinc-200 rounded-lg hover:bg-zinc-50"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div className="min-w-0 flex-1">
                        <p className="font-medium text-zinc-900">
                          {lead.customer_name || "Unnamed"}
                        </p>
                        <p className="text-sm text-zinc-600">{lead.mobile}</p>
                        <p className="text-xs text-zinc-500">
                          {lead.car_manufacturer} {lead.car_model} • {lead.service_type}
                        </p>
                        {lead.assigned_to && (
                          <p className="text-xs text-blue-600 mt-1">
                            Assigned to: {lead.assigned_to}
                          </p>
                        )}
                      </div>
                      <a
                        href={`tel:${lead.mobile}`}
                        className="px-3 py-1.5 bg-black text-white text-xs rounded-lg hover:bg-zinc-800"
                      >
                        Call
                      </a>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

