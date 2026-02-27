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

  # Defensive: ensure no Supabase values can be captured into build output.
  unset SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_KEY SUPABASE_USER_PHOTO_BUCKET || true
fi

# For Web builds, pass non-secret runtime config through dart-defines.
# Note: dart-defines are compiled into JS bundle, so do not pass secrets.
dart_defines=()
for key in \
  MODE \
  PORTONE_V1_USER_CODE \
  PORTONE_V1_USER_CODE_DEV \
  PORTONE_V1_PG \
  PORTONE_V1_PG_DEV \
  PORTONE_V1_TEST_AMOUNT
do
  value="${!key:-}"
  if [ -n "$value" ]; then
    dart_defines+=("--dart-define=$key=$value")
  fi
done

if [ ${#dart_defines[@]} -gt 0 ]; then
  flutter build web "${dart_defines[@]}"
else
  flutter build web
fi
