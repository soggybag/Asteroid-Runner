#!/bin/sh
# Stamps the built app's Info.plist with a build number and commit, so the
# version in the corner of the screen identifies exactly what's running.
#   CFBundleVersion = number of commits on this branch
#   GitCommit       = short commit hash, with + when there are uncommitted changes
# Runs as the last build phase of the app target. Leaves the source
# Info.plist alone.

PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
cd "${SRCROOT}" || exit 0

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "stamp-version: not a git repo, skipping"
  exit 0
fi

BUILD=$(git rev-list --count HEAD)
COMMIT=$(git rev-parse --short HEAD)
if ! git diff --quiet HEAD -- 2>/dev/null; then
  COMMIT="${COMMIT}+"
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD}" "${PLIST}"
/usr/libexec/PlistBuddy -c "Delete :GitCommit" "${PLIST}" 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :GitCommit string ${COMMIT}" "${PLIST}"
echo "stamp-version: build ${BUILD}, commit ${COMMIT}"
