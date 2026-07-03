"""Generate a GitLab CI child pipeline from ``nix flake show --json`` output.

One job per package / check / devShell / nixosConfiguration.
Categories that are empty or absent are skipped.
"""

import json
import sys


def yaml_key(s: str) -> str:
    if any(ch in s for ch in '":{}[]&*?|#><=!%@`,'):
        return f'"{s}"'
    return s


def job_block(name: str, stage: str, script: str) -> str:
    return "\n".join(
        [
            f"{yaml_key(name)}:",
            f"  stage: {stage}",
            "  image: nixpkgs/nix-flakes",
            f"  script:",
            f"    - {script}",
        ]
    )


CATEGORIES: list[tuple[str, str]] = [
    (
        "packages",
        "nix build --no-link --print-build-logs .#packages.{system}.{name}",
    ),
    (
        "checks",
        "nix build --no-link --print-build-logs .#checks.{system}.{name}",
    ),
    (
        "devShells",
        "nix build --no-link --print-build-logs .#devShells.{system}.{name}",
    ),
    (
        "nixosConfigurations",
        "nix build --no-link --print-build-logs .#nixosConfigurations.{name}.config.system.build.toplevel",
    ),
]


def main() -> None:
    flake = json.loads("".join([line for line in sys.stdin]))

    stages: list[str] = []
    jobs: list[tuple[str, str, str]] = []  # (name, stage, script)

    for cat_name, cmd_tpl in CATEGORIES:
        if cat_name not in flake:
            continue

        cat = flake[cat_name]

        items: list[tuple[str, str]] = []  # (job_suffix, build_command)

        if cat_name == "nixosConfigurations":
            for host in sorted(cat):
                items.append((host, cmd_tpl.format(name=host)))
        else:
            for system in sorted(cat):
                names = cat[system]
                if isinstance(names, dict):
                    names = list(names)
                multi_system = len(cat) > 1
                for name in sorted(names):
                    suffix = f"{name} ({system})" if multi_system else name
                    items.append((suffix, cmd_tpl.format(system=system, name=name)))

        if not items:
            continue

        stages.append(cat_name)

        for suffix, cmd in items:
            job_name = f"{cat_name}:{suffix}"
            jobs.append((job_name, cat_name, cmd))

    print(
        "# Generated child pipeline — do not edit by hand\n"
        "\n"
        "stages:\n"
        + "".join(f"  - {s}\n" for s in stages)
        + "\n"
        + "\n".join(job_block(n, s, c) for n, s, c in jobs)
    )


if __name__ == "__main__":
    main()
