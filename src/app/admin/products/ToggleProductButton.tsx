"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { toggleProductActiveAction } from "./actions";

export function ToggleProductButton({
  productId,
  isActive,
}: {
  productId: string;
  isActive: boolean;
}) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function handleToggle() {
    if (loading) return;
    setLoading(true);

    const result = await toggleProductActiveAction(productId);
    if (result.ok) {
      router.refresh();
    } else {
      alert(result.error || "Failed to toggle product status");
    }
    setLoading(false);
  }

  return (
    <button
      type="button"
      onClick={handleToggle}
      disabled={loading}
      className={`px-4 py-2 text-sm font-semibold rounded transition ${
        isActive
          ? "text-red-700 bg-white border border-red-300 hover:bg-red-50"
          : "text-green-700 bg-white border border-green-300 hover:bg-green-50"
      } disabled:opacity-50 disabled:cursor-not-allowed`}
    >
      {loading ? "..." : isActive ? "Disable" : "Enable"}
    </button>
  );
}
