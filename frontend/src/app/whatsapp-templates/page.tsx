"use client";

import { useEffect, useState } from "react";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

interface WhatsAppTemplate {
  id: number;
  name: string;
  message: string;
  created_at: string;
  updated_at: string;
  created_by: number;
}

export default function WhatsAppTemplatesPage() {
  const [templates, setTemplates] = useState<WhatsAppTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [formData, setFormData] = useState({ name: "", message: "" });
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    loadTemplates();
  }, []);

  async function loadTemplates() {
    setLoading(true);
    setError("");
    try {
      const res = await fetch(`${API_BASE}/api/whatsapp-templates`, {
        credentials: "include",
        headers: {
          "Accept": "application/json",
        },
      });
      if (res.ok) {
        const data = await res.json();
        setTemplates(data.templates || []);
      } else {
        try {
          const errorData = await res.json();
          setError(errorData.error || `Failed to load templates: ${res.status}`);
        } catch (parseErr) {
          setError(`Failed to load templates: ${res.status} ${res.statusText}`);
        }
      }
    } catch (err: any) {
      console.error("Failed to load templates:", err);
      setError(`Failed to load templates: ${err.message || "Network error. Make sure the backend server is running."}`);
    } finally {
      setLoading(false);
    }
  }

  function handleEdit(template: WhatsAppTemplate) {
    setEditingId(template.id);
    setFormData({ name: template.name, message: template.message });
    setShowForm(true);
    setError("");
  }

  function handleDelete(templateId: number) {
    if (!confirm("Are you sure you want to delete this template?")) {
      return;
    }

    fetch(`${API_BASE}/api/whatsapp-templates/${templateId}`, {
      method: "DELETE",
      credentials: "include",
    })
      .then((res) => {
        if (res.ok) {
          loadTemplates();
        } else {
          setError("Failed to delete template");
        }
      })
      .catch((err) => {
        console.error("Failed to delete template:", err);
        setError("Failed to delete template");
      });
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    const url = editingId
      ? `${API_BASE}/api/whatsapp-templates/${editingId}`
      : `${API_BASE}/api/whatsapp-templates`;
    const method = editingId ? "PUT" : "POST";

    fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify(formData),
    })
      .then(async (res) => {
        if (res.ok) {
          setShowForm(false);
          setEditingId(null);
          setFormData({ name: "", message: "" });
          loadTemplates();
        } else {
          try {
            const data = await res.json();
            setError(data.error || `Failed to save template: ${res.status} ${res.statusText}`);
          } catch (parseErr) {
            setError(`Failed to save template: ${res.status} ${res.statusText}`);
          }
        }
      })
      .catch((err) => {
        console.error("Failed to save template:", err);
        setError(`Failed to save template: ${err.message || "Network error"}`);
      });
  }

  function handleCancel() {
    setShowForm(false);
    setEditingId(null);
    setFormData({ name: "", message: "" });
    setError("");
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-6xl px-4 py-6">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-zinc-900 mb-2">
              WhatsApp Templates
            </h1>
            <p className="text-sm text-zinc-600">
              Manage message templates for quick customer communication
            </p>
          </div>
          {!showForm && (
            <button
              onClick={() => {
                setShowForm(true);
                setEditingId(null);
                setFormData({ name: "", message: "" });
                setError("");
              }}
              className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800 transition"
            >
              + Add Template
            </button>
          )}
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
            {error}
          </div>
        )}

        {showForm && (
          <div className="bg-white rounded-xl border border-zinc-200 p-6 mb-6">
            <h2 className="text-lg font-semibold text-zinc-900 mb-4">
              {editingId ? "Edit Template" : "Add New Template"}
            </h2>
            <form onSubmit={handleSubmit}>
              <div className="mb-4">
                <label className="block text-sm font-medium text-zinc-700 mb-2">
                  Template Name
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) =>
                    setFormData({ ...formData, name: e.target.value })
                  }
                  placeholder="e.g., Greeting, Follow-up, Service Inquiry"
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  required
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-zinc-700 mb-2">
                  Message
                </label>
                <textarea
                  value={formData.message}
                  onChange={(e) =>
                    setFormData({ ...formData, message: e.target.value })
                  }
                  placeholder="Enter the message template..."
                  rows={6}
                  className="w-full px-3 py-2 border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                  required
                />
              </div>
              <div className="flex gap-2">
                <button
                  type="submit"
                  className="px-4 py-2 bg-zinc-900 text-white rounded-lg text-sm font-medium hover:bg-zinc-800 transition"
                >
                  {editingId ? "Update" : "Create"} Template
                </button>
                <button
                  type="button"
                  onClick={handleCancel}
                  className="px-4 py-2 border border-zinc-300 rounded-lg text-sm font-medium text-zinc-700 hover:bg-zinc-100 transition"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        {loading ? (
          <div className="bg-white rounded-xl border border-zinc-200 p-8 text-center text-zinc-500">
            Loading templates...
          </div>
        ) : templates.length === 0 ? (
          <div className="bg-white rounded-xl border border-zinc-200 p-8 text-center text-zinc-500">
            No templates found. Create your first template to get started.
          </div>
        ) : (
          <div className="bg-white rounded-xl border border-zinc-200 overflow-hidden">
            <div className="p-4 border-b border-zinc-200">
              <h2 className="text-lg font-semibold text-zinc-900">
                All Templates ({templates.length})
              </h2>
            </div>
            <div className="divide-y divide-zinc-100">
              {templates.map((template) => (
                <div
                  key={template.id}
                  className="p-4 hover:bg-zinc-50 transition"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="text-base font-semibold text-zinc-900 mb-2">
                        {template.name}
                      </h3>
                      <p className="text-sm text-zinc-600 whitespace-pre-wrap">
                        {template.message}
                      </p>
                      <p className="text-xs text-zinc-400 mt-2">
                        Created:{" "}
                        {new Date(template.created_at).toLocaleDateString(
                          "en-IN",
                          {
                            day: "numeric",
                            month: "short",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                          }
                        )}
                      </p>
                    </div>
                    <div className="flex gap-2 ml-4">
                      <button
                        onClick={() => handleEdit(template)}
                        className="px-3 py-1.5 text-xs font-medium text-zinc-700 border border-zinc-300 rounded-lg hover:bg-zinc-100 transition"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(template.id)}
                        className="px-3 py-1.5 text-xs font-medium text-red-700 border border-red-300 rounded-lg hover:bg-red-50 transition"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

