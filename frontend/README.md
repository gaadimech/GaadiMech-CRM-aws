# Frontend - GaadiMech CRM

Next.js frontend application for the GaadiMech CRM.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment variables:**
   Create a `.env.local` file in this directory with:
   ```
   NEXT_PUBLIC_API_BASE_URL=http://localhost:5000
   ```

   **Note:** This is only for local development. In production, the frontend should use relative paths (empty string).

## Running Locally

```bash
npm run dev
```

The application will start on `http://localhost:3000`

## Building for Production

```bash
npm run build
```

This creates a static export in the `out/` directory.

## API Configuration

The frontend is configured to call the backend API at:
- **Local development:** `http://localhost:5000` (from `.env.local`)
- **Production:** Relative paths (same domain as frontend)

Make sure the backend is running on port 5000 when testing locally.
