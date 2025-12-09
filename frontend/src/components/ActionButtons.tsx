"use client";

import type { Lead } from "../lib/types";

function telHref(mobile: string) {
  return `tel:${mobile}`;
}

function whatsappHref(mobile: string) {
  const cleaned = mobile.replace(/[^\d]/g, "");
  const withCountry = cleaned.length === 10 ? `91${cleaned}` : cleaned;
  return `https://wa.me/${withCountry}`;
}

interface ActionButtonsProps {
  lead: Lead;
  onStatusClick?: () => void;
  onRescheduleClick?: () => void;
  compact?: boolean;
}

export default function ActionButtons({
  lead,
  onStatusClick,
  onRescheduleClick,
  compact = false,
}: ActionButtonsProps) {
  const sizeClass = compact ? "px-2 py-1 text-xs" : "px-3 py-1.5 text-xs";
  
  return (
    <div className={`flex flex-wrap gap-2 ${compact ? "gap-1.5" : ""}`}>
      <a
        href={telHref(lead.mobile)}
        className={`rounded-full bg-black ${sizeClass} font-medium text-white shadow hover:bg-zinc-800 transition`}
      >
        Call
      </a>
      <a
        href={whatsappHref(lead.mobile)}
        target="_blank"
        rel="noreferrer"
        className={`rounded-full bg-emerald-600 ${sizeClass} font-medium text-white shadow hover:bg-emerald-700 transition`}
      >
        WhatsApp
      </a>
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
  );
}

