import json
from datetime import datetime, timedelta, timezone

from dotfiles.docker import docker_ps


def _now_minus(delta: timedelta) -> str:
    dt = datetime.now(timezone.utc) - delta
    local = dt.astimezone()
    offset = local.strftime("%z")
    tz_name = local.strftime("%Z")
    return local.strftime(f"%Y-%m-%d %H:%M:%S {offset} {tz_name}")


def test_compose_running():
    created_at = _now_minus(timedelta(minutes=8))
    item = {
        "Command": '"caddy run --config …"',
        "CreatedAt": created_at,
        "ExitCode": 0,
        "Health": "",
        "ID": "2ad8da04f9ea",
        "Image": "caddy:alpine",
        "Labels": "com.docker.compose.container-number=1,com.docker.compose.service=caddy",
        "LocalVolumes": "2",
        "Mounts": "…",
        "Name": "myproject-caddy-1",
        "Names": "myproject-caddy-1",
        "Networks": "mynet",
        "Ports": "443/tcp, 0.0.0.0:80->80/tcp, [::]:80->80/tcp, 2019/tcp, 443/udp",
        "Project": "myproject",
        "Publishers": [
            {"URL": "0.0.0.0", "TargetPort": 80, "PublishedPort": 80, "Protocol": "tcp"},
            {"URL": "::",      "TargetPort": 80, "PublishedPort": 80, "Protocol": "tcp"},
            {"URL": "",        "TargetPort": 443, "PublishedPort": 0, "Protocol": "tcp"},
            {"URL": "",        "TargetPort": 443, "PublishedPort": 0, "Protocol": "udp"},
            {"URL": "",        "TargetPort": 2019, "PublishedPort": 0, "Protocol": "tcp"},
        ],
        "RunningFor": "About an hour ago",
        "Service": "caddy",
        "Size": "0B",
        "State": "running",
        "Status": "Up About an hour",
    }
    expected = {
        'Service': 'caddy',
        'Name': 'myproject-caddy-1',
        'Status': '🟢 up <fg=blue>8m</>',
        'Ports': '80 443<fg=red>-</> 2019<fg=red>-</>',
        'Image': 'caddy:alpine',
    }

    actual = docker_ps.transform_item(json.dumps(item), compose=True)
    assert actual == expected


def test_docker_running():
    created_at = _now_minus(timedelta(minutes=8))
    item = {
        "Command": '"caddy run --config …"',
        "CreatedAt": created_at,
        "ID": "2ad8da04f9ea",
        "Image": "caddy:alpine",
        "Labels": "",
        "LocalVolumes": "2",
        "Mounts": "myproject_caddy-…,myproject_caddy-…,/home/eduardo/…,/home/eduardo/…",
        "Names": "myproject-caddy-1",
        "Networks": "mynet",
        "Platform": {"architecture": "amd64", "os": "linux"},
        "Ports": "443/tcp, 0.0.0.0:80->80/tcp, [::]:80->80/tcp, 2019/tcp, 443/udp",
        "RunningFor": "About an hour ago",
        "Size": "12.3kB (virtual 63.9MB)",
        "State": "running",
        "Status": "Up About an hour",
    }
    expected = {
        'Name': 'myproject-caddy-1',
        'Status': '🟢 up <fg=blue>8m</>',
        'Ports': '80 443<fg=red>-</> 2019<fg=red>-</>',
        'Image': 'caddy:alpine',
    }

    actual = docker_ps.transform_item(json.dumps(item), compose=False)
    assert actual == expected


def test_format_ports_text_ranges():
    # port ranges (e.g. RabbitMQ) must not crash and must appear in output
    ports_str = "15691-15692/tcp, 0.0.0.0:5672->5672/tcp, 25672/tcp"
    result = docker_ps._format_ports_text(ports_str, max_ports=None)
    parts = result.split()
    assert "5672" in parts                        # published, no dash
    assert "15691-15692<fg=red>-</>" in parts
    assert "25672<fg=red>-</>" in parts


def test_render_ports_published_first():
    entries = [("9000", False), ("80", True), ("8080", False)]
    result = docker_ps._render_ports(entries, max_ports=None)
    parts = result.split()
    assert parts[0] == "80"                       # published sorts first


def test_render_ports_clamp_and_ellipsis():
    entries = [(str(p), False) for p in [80, 443, 8080, 9000]]
    result = docker_ps._render_ports(entries, max_ports=3)
    parts = result.split()
    assert len(parts) == 4                        # 3 ports + ellipsis
    assert parts[-1] == "…"


def test_render_ports_no_ellipsis_when_fits():
    entries = [(str(p), True) for p in [80, 443, 8080]]
    result = docker_ps._render_ports(entries, max_ports=3)
    assert "…" not in result


def test_sort_rows():
    def row(name, status, service=None):
        r = {"Name": name, "Status": status, "Ports": "", "Image": ""}
        if service is not None:
            r["Service"] = service
        return r

    rows = [
        row("proj-web-1",    "🔴 exited ...",     service="web"),
        row("proj-worker-1", "🔵 restarting ...", service="worker"),
        row("proj-db-1",     "🟢 up ...",         service="db"),
        row("proj-web-2",    "🟢 up ...",         service="web"),
        row("proj-db-2",     "🔴 exited ...",     service="db"),
    ]
    result = docker_ps.sort_rows(rows)
    assert [r["Name"] for r in result] == [
        "proj-db-1",     # running, service=db
        "proj-web-2",    # running, service=web
        "proj-worker-1", # restarting
        "proj-db-2",     # exited, service=db
        "proj-web-1",    # exited, service=web
    ]
