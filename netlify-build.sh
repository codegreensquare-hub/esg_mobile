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

# Prefer runtime .env via assets for Flutter web.
# This file must only contain PUBLIC values (anon key + URL). Never write service-role keys here.
ENV_ASSET_PATH="assets/env/config.env"
mkdir -p "$(dirname "$ENV_ASSET_PATH")"
cat > "$ENV_ASSET_PATH" <<EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_USER_PHOTO_BUCKET=${SUPABASE_USER_PHOTO_BUCKET:-user}
EOF

flutter build web --release
