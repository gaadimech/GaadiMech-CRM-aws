import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Use static export for production builds
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  reactStrictMode: true,
};

export default nextConfig;
