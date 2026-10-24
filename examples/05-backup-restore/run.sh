#!/usr/bin/env bash
# 05-backup-restore/run.sh
set -euo pipefail
POOL="${POOL:-rbd-pool}"; IMAGE="${IMAGE:-vm-100-disk-0}"; SNAP="backup-$(date +%Y%m%d-%H%M%S)"
rbd snap create "${POOL}/${IMAGE}@${SNAP}"
rbd snap protect "${POOL}/${IMAGE}@${SNAP}"
rbd export "${POOL}/${IMAGE}@${SNAP}" "/tmp/${IMAGE}-${SNAP}.rbd"
rbd import "/tmp/${IMAGE}-${SNAP}.rbd" "${POOL}/${IMAGE}-restored"
rbd snap ls "${POOL}/${IMAGE}"
echo "Done."
