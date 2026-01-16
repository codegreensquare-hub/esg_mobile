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
# On Netlify, never allow a real `.env` (even "public" anon key/URL) into build output,
# because secrets scanning can still flag it. Always overwrite with a safe placeholder.
if [ "${NETLIFY:-}" = "true" ]; then
  cat > ".env" <<'EOF'
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_USER_PHOTO_BUCKET=
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
