"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { fetchCurrentUser } from "../../lib/api";

const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ||
  "http://localhost:5000";

interface User {
  id: number;
  username: string;
  name: string;
  is_admin: boolean;
}

export default function PasswordManagerPage() {
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);
  const [editingUserId, setEditingUserId] = useState<number | null>(null);
  const [passwordData, setPasswordData] = useState({
    newPassword: "",
    confirmPassword: "",
  });
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  useEffect(() => {
    async function checkAccess() {
      try {
        const user = await fetchCurrentUser();
        setIsAdmin(user.is_admin || false);
        
        if (!user.is_admin) {
          router.push("/dashboard");
          return;
        }
        
        await loadUsers();
      } catch (err) {
        console.error("Failed to check access:", err);
        router.push("/login");
      } finally {
        setLoading(false);
      }
    }
    checkAccess();
  }, [router]);

  async function loadUsers() {
    try {
      const res = await fetch(`${API_BASE}/api/admin/users`, {
        credentials: "include",
      });
      
      if (res.ok) {
        const data = await res.json();
        setUsers(data.users || []);
      } else {
        setError("Failed to load users");
      }
    } catch (err) {
      console.error("Failed to load users:", err);
      setError("Failed to load users");
    }
  }

  function handleEditClick(userId: number) {
    setEditingUserId(userId);
    setPasswordData({ newPassword: "", confirmPassword: "" });
    setError("");
    setSuccess("");
  }

  function handleCancelEdit() {
    setEditingUserId(null);
    setPasswordData({ newPassword: "", confirmPassword: "" });
    setError("");
    setSuccess("");
  }

  async function handleUpdatePassword(userId: number) {
    setError("");
    setSuccess("");

    // Validation
    if (!passwordData.newPassword || passwordData.newPassword.length < 6) {
      setError("Password must be at least 6 characters long");
      return;
    }

    if (passwordData.newPassword !== passwordData.confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/api/admin/users/${userId}/password`, {
        method: "PATCH",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          new_password: passwordData.newPassword,
        }),
      });

      if (res.ok) {
        setSuccess("Password updated successfully!");
        setEditingUserId(null);
        setPasswordData({ newPassword: "", confirmPassword: "" });
        // Reload users after a short delay
        setTimeout(() => {
          loadUsers();
        }, 1000);
      } else {
        const data = await res.json();
        setError(data.error || data.message || "Failed to update password");
      }
    } catch (err) {
      console.error("Error updating password:", err);
      setError("Error updating password. Please try again.");
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-zinc-50 flex items-center justify-center">
        <div className="text-zinc-600">Loading...</div>
      </div>
    );
  }

  if (!isAdmin) {
    return null;
  }

  return (
    <div className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-6xl px-4 py-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-zinc-900 mb-2">
            Password Manager
          </h1>
          <p className="text-sm text-zinc-600">
            Manage user passwords. Only admins can access this page.
          </p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-50 border border-red-200 p-3 text-sm text-red-800">
            {error}
          </div>
        )}

        {success && (
          <div className="mb-4 rounded-lg bg-green-50 border border-green-200 p-3 text-sm text-green-800">
            {success}
          </div>
        )}

        <div className="bg-white rounded-xl border border-zinc-200 overflow-hidden">
          <div className="p-4 border-b border-zinc-200">
            <h2 className="text-lg font-semibold text-zinc-900">
              All Users ({users.length})
            </h2>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-zinc-50">
                <tr>
                  <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                    ID
                  </th>
                  <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                    Username
                  </th>
                  <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                    Name
                  </th>
                  <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                    Role
                  </th>
                  <th className="text-left py-3 px-4 text-zinc-700 font-medium">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr
                    key={user.id}
                    className="border-b border-zinc-100 hover:bg-zinc-50"
                  >
                    <td className="py-3 px-4 text-zinc-900">{user.id}</td>
                    <td className="py-3 px-4 text-zinc-900 font-medium">
                      {user.username}
                    </td>
                    <td className="py-3 px-4 text-zinc-900">{user.name}</td>
                    <td className="py-3 px-4">
                      {user.is_admin ? (
                        <span className="px-2 py-1 text-xs font-medium bg-purple-100 text-purple-800 rounded-full">
                          Admin
                        </span>
                      ) : (
                        <span className="px-2 py-1 text-xs font-medium bg-zinc-100 text-zinc-800 rounded-full">
                          User
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4">
                      {editingUserId === user.id ? (
                        <div className="space-y-2">
                          <div>
                            <input
                              type="password"
                              placeholder="New Password"
                              value={passwordData.newPassword}
                              onChange={(e) =>
                                setPasswordData({
                                  ...passwordData,
                                  newPassword: e.target.value,
                                })
                              }
                              className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                            />
                          </div>
                          <div>
                            <input
                              type="password"
                              placeholder="Confirm Password"
                              value={passwordData.confirmPassword}
                              onChange={(e) =>
                                setPasswordData({
                                  ...passwordData,
                                  confirmPassword: e.target.value,
                                })
                              }
                              className="w-full px-3 py-2 text-sm border border-zinc-300 rounded-lg focus:ring-2 focus:ring-zinc-900 focus:border-transparent"
                            />
                          </div>
                          <div className="flex gap-2">
                            <button
                              onClick={() => handleUpdatePassword(user.id)}
                              className="px-3 py-1.5 text-xs bg-zinc-900 text-white rounded-lg hover:bg-zinc-800 transition"
                            >
                              Update
                            </button>
                            <button
                              onClick={handleCancelEdit}
                              className="px-3 py-1.5 text-xs border border-zinc-300 rounded-lg text-zinc-700 hover:bg-zinc-100 transition"
                            >
                              Cancel
                            </button>
                          </div>
                        </div>
                      ) : (
                        <button
                          onClick={() => handleEditClick(user.id)}
                          className="px-3 py-1.5 text-xs bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                        >
                          Change Password
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {users.length === 0 && (
            <div className="p-8 text-center text-zinc-500">
              No users found
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

