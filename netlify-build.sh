#!/usr/bin/env bash
set -euo pipefail

# Netlify build images do not ship with Flutter.
# Install Flutter SDK into the build cache directory.
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --no-analytics

flutter pub get

# pubspec bundles `.env` as an asset for local runs.
# In Netlify CI, the repo does not include `.env` (gitignored), so create a safe placeholder.
# Real values are served at runtime via `/.netlify/functions/config`.
if [ ! -f ".env" ]; then
  cat > ".env" <<'EOF'
SUPABASE_URL=
SUPABASE_ANON_KEY=
EOF
fi

# If you deploy under a sub-path, set this accordingly, e.g. --base-href /myapp/
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "ERROR: Missing Netlify environment variables SUPABASE_URL and/or SUPABASE_ANON_KEY" 1>&2
  echo "Set them in Netlify: Site settings → Build & deploy → Environment." 1>&2
  exit 1
fi

if [ -n "${SUPABASE_KEY:-}" ]; then
  echo "WARNING: SUPABASE_KEY (service-role) detected in build environment; unsetting to prevent client exposure." 1>&2
  unset SUPABASE_KEY
fi

flutter build web --release
