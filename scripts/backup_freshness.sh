#!/usr/bin/env bash
# backup_freshness.sh -- are the backups actually recent?
#
# Lists the newest vzdump backup per guest on a Proxmox Backup Server
# datastore mount or a local backup directory, and flags guests whose
# newest backup is older than MAX_AGE_HOURS (default 26 -- a daily job
# plus slack). A backup that exists but is stale is a failed backup plan
# that hasn't told you yet.
#
# Usage: ./backup_freshness.sh /path/to/backup/dir [max_age_hours]
#   The directory is scanned for files named like:
#     vzdump-qemu-<vmid>-<YYYY_MM_DD-HH_MM_SS>.vma* / .tar*
#     vzdump-lxc-<vmid>-<YYYY_MM_DD-HH_MM_SS>.tar*
#
# Exit code: 0 if every guest found is fresh, 1 if any is stale,
# 2 on usage/environment errors. Guests with NO backup are reported by
# absence -- diff the guest list against `qm list` / `pct list`.

set -euo pipefail

backup_dir="${1:-}"
max_age_hours="${2:-26}"

[[ -n "${backup_dir}" && -d "${backup_dir}" ]] || {
    echo "Usage: $0 /path/to/backup/dir [max_age_hours]" >&2
    exit 2
}

now_epoch="$(date +%s)"
stale=0

# Newest backup file per guest id.
declare -A newest_file newest_epoch
while IFS= read -r -d '' f; do
    base="$(basename "${f}")"
    if [[ "${base}" =~ vzdump-(qemu|lxc)-([0-9]+)-([0-9]{4})_([0-9]{2})_([0-9]{2})-([0-9]{2})_([0-9]{2})_([0-9]{2}) ]]; then
        vmid="${BASH_REMATCH[2]}"
        when="${BASH_REMATCH[3]}-${BASH_REMATCH[4]}-${BASH_REMATCH[5]} ${BASH_REMATCH[6]}:${BASH_REMATCH[7]}:${BASH_REMATCH[8]}"
        epoch="$(date -d "${when}" +%s 2>/dev/null || echo 0)"
        if [[ -z "${newest_epoch[${vmid}]:-}" || "${epoch}" -gt "${newest_epoch[${vmid}]}" ]]; then
            newest_epoch["${vmid}"]="${epoch}"
            newest_file["${vmid}"]="${base}"
        fi
    fi
done < <(find "${backup_dir}" -type f -name 'vzdump-*' -print0)

if [[ "${#newest_epoch[@]}" -eq 0 ]]; then
    echo "No vzdump backups found under ${backup_dir}" >&2
    exit 2
fi

printf '%-8s %-10s %s\n' "VMID" "AGE (h)" "NEWEST BACKUP"
for vmid in $(printf '%s\n' "${!newest_epoch[@]}" | sort -n); do
    age_h=$(( (now_epoch - newest_epoch[${vmid}]) / 3600 ))
    flag=""
    if [[ "${age_h}" -gt "${max_age_hours}" ]]; then
        flag="  <-- STALE (limit ${max_age_hours}h)"
        stale=1
    fi
    printf '%-8s %-10s %s%s\n' "${vmid}" "${age_h}" "${newest_file[${vmid}]}" "${flag}"
done

exit "${stale}"
