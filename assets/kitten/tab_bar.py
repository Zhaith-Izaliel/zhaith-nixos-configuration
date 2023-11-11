# pyright: reportMissingImports=false
from datetime import timedelta
import subprocess
from textwrap import shorten
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.utils import color_as_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)

opts = get_options()
icon_fg = as_rgb(color_as_int(opts.color16))
icon_bg = as_rgb(color_as_int(0x1e2030))
bat_text_color = as_rgb(color_as_int(opts.color15))
# Date and clock colors
uptime_color = as_rgb(color_as_int(opts.color8))
# Music segment colors
music_color = as_rgb(color_as_int(opts.color6))
music_icon_color = as_rgb(color_as_int(opts.color4))
music_separator_color = as_rgb(color_as_int(opts.color15))

SEPARATOR_SYMBOL, SOFT_SEPARATOR_SYMBOL = ("", "  ")
RIGHT_MARGIN = 1
REFRESH_TIME = 1
ELLIPSIS_LENGTH = 20
ICON = " 🪷  "
UPTIME_ICON = "⇡ "
MUSIC_ICON = " "
ELLIPSIS = ""
UNPLUGGED_ICONS = {
    10: "󰂎",
    20: "󰁺",
    30: "󰁻",
    40: "󰁽",
    50: "󰁾",
    60: "󰁿",
    70: "󰂀",
    80: "󰂁",
    90: "󰂂",
    100: "󰁹",
}
PLUGGED_ICONS = {
   1: "󰂄",
}
UNPLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color15)),
}
PLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color6)),
    99: as_rgb(color_as_int(opts.color6)),
    100: as_rgb(color_as_int(opts.color2)),
}


def _draw_icon(screen: Screen, index: int) -> int:
    if index != 1:
        return 0
    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.draw(ICON)
    screen.cursor.fg, screen.cursor.bg = fg, bg
    screen.cursor.x = len(ICON)
    return screen.cursor.x


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if screen.cursor.x >= screen.columns - right_status_length:
        return screen.cursor.x
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False
    if screen.cursor.x <= len(ICON):
        screen.cursor.x = len(ICON)
    screen.draw(" ")
    screen.cursor.bg = tab_bg
    draw_title(draw_data, screen, tab, index)
    if not needs_soft_separator:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(SEPARATOR_SYMBOL)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        elif tab_bg != default_bg:
            c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
            c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
            if c1 < c2:
                screen.cursor.fg = default_bg
        screen.draw(" " + SOFT_SEPARATOR_SYMBOL)
        screen.cursor.fg = prev_fg
    end = screen.cursor.x
    return end


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return 0
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.fg = 0
    for color, status in cells:
        screen.cursor.fg = color
        screen.draw(status)
    screen.cursor.bg = 0
    return screen.cursor.x


def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()

# def get_mpd_current_song() -> list:
#     try:
#     # Using subprocess since we can't use external packages
#         output = subprocess.check_output(['ncmpcpp', '-q', '--current-song', "%t - %a"]).decode('utf-8')
#         if not output:
#             return []
#         text = shorten(output, width=ELLIPSIS_LENGTH, placeholder=ELLIPSIS)
#         return [
#             (music_icon_color, MUSIC_ICON),
#             (music_color, text),
#             (music_separator_color,SOFT_SEPARATOR_SYMBOL)
#         ]
#     except subprocess.CalledProcessError:
#         return []

def get_uptime() -> list:
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = float(f.readline().split()[0])
    uptime = UPTIME_ICON + str(timedelta(seconds=uptime_seconds)).split('.')[0]
    return [(music_separator_color,SOFT_SEPARATOR_SYMBOL), (uptime_color, uptime)]


def get_battery_cells() -> list:
    try:
        with open("/sys/class/power_supply/BAT0/status", "r") as f:
            status = f.read()
        with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
            percent = int(f.read())
        compute_key = lambda x: abs(x - percent)
        if status == "Discharging\n":
            icon_color = UNPLUGGED_COLORS[
                min(UNPLUGGED_COLORS.keys(), key=compute_key)
            ]
            icon = UNPLUGGED_ICONS[
                min(UNPLUGGED_ICONS.keys(), key=compute_key)
            ]
        elif status == "Not charging\n":
            icon_color = UNPLUGGED_COLORS[
                min(UNPLUGGED_COLORS.keys(), key=compute_key)
            ]
            icon = PLUGGED_ICONS[
                min(PLUGGED_ICONS.keys(), key=compute_key)
            ]
        else:
            icon_color = PLUGGED_COLORS[
                min(PLUGGED_COLORS.keys(), key=compute_key)
            ]
            icon = PLUGGED_ICONS[
                min(PLUGGED_ICONS.keys(), key=compute_key)
            ]
        percent_cell = (bat_text_color, str(percent) + "% ")
        icon_cell = (icon_color, icon)
        return [percent_cell, icon_cell]
    except FileNotFoundError:
        return []


timer_id = None
right_status_length = -1

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    global right_status_length
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    # cells = get_mpd_current_song()
    cells = get_battery_cells()
    cells += get_uptime()
    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[1]))

    _draw_icon(screen, index)
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        screen,
        is_last,
        cells,
    )
    return screen.cursor.x

