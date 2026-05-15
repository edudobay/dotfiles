import argparse
import json
import subprocess
from datetime import datetime, timezone

from tabulate import tabulate

from dotfiles import term_markup


def _format_age(created_at: str) -> str:
    # Parse "2026-05-14 15:31:45 -0300 -03" — drop the trailing tz name
    parts = created_at.rsplit(" ", 1)
    dt = datetime.strptime(parts[0], "%Y-%m-%d %H:%M:%S %z")
    delta = datetime.now(timezone.utc) - dt
    total = int(delta.total_seconds())
    if total < 3600:
        return f"{total // 60}m"
    if total < 86400:
        return f"{total // 3600}h"
    return f"{total // 86400}d"


def _port_range_key(port: str) -> int:
    return int(port.split('-')[0])


def _render_ports(entries: list[tuple[str, bool]], max_ports: int | None = 3) -> str:
    """Render a list of (label, published) port entries into a display string.

    Entries are sorted published-first, then by port number. If max_ports is
    set and entries are truncated, an ellipsis is appended. Pass max_ports=None
    to show all ports (for a future --all-ports flag).
    """
    entries = sorted(entries, key=lambda e: (not e[1], _port_range_key(e[0])))
    truncated = max_ports is not None and len(entries) > max_ports
    if truncated:
        entries = entries[:max_ports]
    parts = [label if pub else f'{label}<fg=red>-</>' for label, pub in entries]
    if truncated:
        parts.append('…')
    return ' '.join(parts)


def _format_ports_text(ports_str: str, max_ports: int | None = 3) -> str:
    if not ports_str:
        return ''
    # port_range -> (published, has_tcp, has_udp)
    ports: dict[str, tuple[bool, bool, bool]] = {}
    for entry in ports_str.split(', '):
        entry = entry.strip()
        # published: [addr:]src_port[-src_end]->dst_port[-dst_end]/proto
        if '->' in entry:
            _, rest = entry.rsplit('->', 1)
            dst, proto = rest.split('/')
            port, published = dst, True
        else:
            dst, proto = entry.split('/')
            port, published = dst, False
        cur = ports.get(port, (False, False, False))
        ports[port] = (cur[0] or published, cur[1] or proto == 'tcp', cur[2] or proto == 'udp')

    entries = []
    for port, (pub, has_tcp, has_udp) in ports.items():
        suffix = '/udp' if has_udp and not has_tcp else ''
        entries.append((f'{port}{suffix}', pub))
    return _render_ports(entries, max_ports)


def _format_ports(publishers: list, max_ports: int | None = 3) -> str:
    published: dict[int, bool] = {}
    for p in publishers:
        port = p["TargetPort"]
        if port not in published:
            published[port] = False
        if p["PublishedPort"] > 0:
            published[port] = True

    entries = [(str(port), pub) for port, pub in published.items()]
    return _render_ports(entries, max_ports)


def transform_item(data: str, compose: bool = False, max_ports: int | None = 3) -> dict:
    item = json.loads(data)
    state = item["State"].lower()
    icon = "🟢" if state == "running" else "🔵" if state == "restarting" else "🔴"
    age = _format_age(item["CreatedAt"])
    label = "up" if state == "running" else state
    status = f"{icon} {label} <fg=blue>{age}</>"

    if compose:
        return {
            "Service": item["Service"],
            "Name": item["Name"],
            "Status": status,
            "Ports": _format_ports(item["Publishers"], max_ports),
            "Image": item["Image"],
        }
    return {
        "Name": item["Names"],
        "Status": status,
        "Ports": _format_ports_text(item["Ports"], max_ports),
        "Image": item["Image"],
    }


_STATE_ORDER = {"🟢": 0, "🔵": 1}


def sort_rows(rows: list[dict]) -> list[dict]:
    def key(row: dict) -> tuple:
        icon = row["Status"][0]
        state_rank = _STATE_ORDER.get(icon, 2)
        service = row.get("Service", "")
        return (state_rank, service, row["Name"])

    return sorted(rows, key=key)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compose", action="store_true")
    parser.add_argument("-a", action="store_true")
    parser.add_argument("-f", dest="compose_files", action="append", default=[])
    parser.add_argument("--all-ports", action="store_true")
    args = parser.parse_args()

    if args.compose:
        file_flags = [flag for f in args.compose_files for flag in ("-f", f)]
        cmd = ["docker", "compose", *file_flags, "ps", "--format", "json"]
    else:
        cmd = ["docker", "ps", "--format", "json"]
    if args.a:
        cmd.append("-a")

    max_ports = None if args.all_ports else 3
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    rows = [
        transform_item(line, compose=args.compose, max_ports=max_ports)
        for line in result.stdout.splitlines()
        if line.strip()
    ]

    if not rows:
        return

    rows = sort_rows(rows)
    rows_ansi = [
        {k: term_markup.to_ansi(v) for k, v in row.items()}
        for row in rows
    ]
    headers = {k: k.upper() for k in rows_ansi[0]}
    print(tabulate(rows_ansi, headers=headers, tablefmt="plain"))


if __name__ == "__main__":
    main()
