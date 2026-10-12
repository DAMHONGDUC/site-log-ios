#!/usr/bin/env bash
# Enforces the layer rules in docs/feature-docs/00-overview.md §4.2.
# Package dependencies already stop Domain and Core from using other layers; these rules cover the rest.
set -euo pipefail

failed=0

# Rule 1: Domain imports Foundation only (a package may still import any Apple framework)
domain_imports=$(grep -rhE '^[[:space:]]*import ' Packages/DomainLayer/Sources --include='*.swift' | sed -E 's/^[[:space:]]*//' | sort -u | grep -vE '^import Foundation$' || true)
if [ -n "$domain_imports" ]; then
  echo "Domain may import Foundation only. Found:"
  echo "$domain_imports"
  failed=1
fi

# Rule 2: Presentation never imports DataLayer (the app links it only for App/AppDependencies.swift)
data_imports=$(grep -rnE '^[[:space:]]*(@testable[[:space:]]+)?import DataLayer$' SiteLog/Presentation --include='*.swift' || true)
if [ -n "$data_imports" ]; then
  echo "Presentation may not import DataLayer; use Domain use cases. Found:"
  echo "$data_imports"
  failed=1
fi

# Rule 3: Presentation never touches storage or the network directly
direct_access=$(grep -rnE '^[[:space:]]*import (SwiftData|CoreData)$|ModelContext|URLSession' SiteLog/Presentation --include='*.swift' || true)
if [ -n "$direct_access" ]; then
  echo "Presentation may not use SwiftData, ModelContext or URLSession. Found:"
  echo "$direct_access"
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "OK: layer rules"