"""Terminal palette shared by every command console.

Standard markup names used across the CLI (``green``, ``cyan``, ``dim``, ``yellow``, ``red``)
map onto the palette so every command renders one consistent brand without per-call style
changes.
"""

from __future__ import annotations

from rich.theme import Theme

ACCENT = "#b6f7c8"
MUTED = "#626b65"
WARNING = "#e3b341"
ERROR = "#c25b4e"

EXP_THEME = Theme(
    {
        "green": ACCENT,
        "cyan": ACCENT,
        "dim": MUTED,
        "yellow": WARNING,
        "red": ERROR,
        "rule.line": MUTED,
        "prompt.choices": ACCENT,
        "prompt.default": MUTED,
        "prompt.invalid": ERROR,
    }
)

