"use client";

import { useState } from "react";
import type { Lead } from "../lib/types";
import WhatsAppTemplateModal from "./WhatsAppTemplateModal";

function telHref(mobile: string) {
  return `tel:${mobile}`;
}

function whatsappHref(mobile: string, message?: string) {
  const cleaned = mobile.replace(/[^\d]/g, "");
  const withCountry = cleaned.length === 10 ? `91${cleaned}` : cleaned;
  let url = `https://wa.me/${withCountry}`;
  if (message) {
    url += `?text=${encodeURIComponent(message)}`;
  }
  return url;
}

interface ActionButtonsProps {
  lead: Lead;
  onStatusClick?: () => void;
  onRescheduleClick?: () => void;
  onEditClick?: () => void;
  compact?: boolean;
}

export default function ActionButtons({
  lead,
  onStatusClick,
  onRescheduleClick,
  onEditClick,
  compact = false,
}: ActionButtonsProps) {
  const [showTemplateModal, setShowTemplateModal] = useState(false);
  const sizeClass = compact ? "px-2 py-1 text-xs" : "px-3 py-1.5 text-xs";

  function handleWhatsAppClick(e: React.MouseEvent) {
    e.preventDefault();
    setShowTemplateModal(true);
  }

  function handleTemplateSelect(message: string) {
    const url = whatsappHref(lead.mobile, message);
    window.open(url, "_blank", "noopener,noreferrer");
  }

  return (
    <>
      <div className={`flex flex-wrap gap-2 ${compact ? "gap-1.5" : ""}`}>
        <a
          href={telHref(lead.mobile)}
          className={`rounded-full bg-black ${sizeClass} font-medium text-white shadow hover:bg-zinc-800 transition`}
        >
          Call
        </a>
        <button
          onClick={handleWhatsAppClick}
          className={`rounded-full bg-emerald-600 ${sizeClass} font-medium text-white shadow hover:bg-emerald-700 transition`}
        >
          WhatsApp
        </button>
        {onEditClick && (
          <button
            onClick={onEditClick}
            className={`rounded-full bg-blue-600 ${sizeClass} font-medium text-white shadow hover:bg-blue-700 transition`}
          >
            Edit
          </button>
        )}
        {onStatusClick && (
          <button
            onClick={onStatusClick}
            className={`rounded-full border border-zinc-200 ${sizeClass} font-medium text-zinc-800 hover:bg-zinc-100 transition`}
          >
            Status
          </button>
        )}
        {onRescheduleClick && (
          <button
            onClick={onRescheduleClick}
            className={`rounded-full border border-zinc-200 ${sizeClass} font-medium text-zinc-800 hover:bg-zinc-100 transition`}
          >
            {compact ? "Reschedule" : "Snooze"}
          </button>
        )}
      </div>
      <WhatsAppTemplateModal
        mobile={lead.mobile}
        isOpen={showTemplateModal}
        onClose={() => setShowTemplateModal(false)}
        onSelectTemplate={handleTemplateSelect}
      />
    </>
  );
}

