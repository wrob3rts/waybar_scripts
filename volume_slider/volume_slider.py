#!/usr/bin/env python3

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk
import subprocess
import sys

class VolumePopup(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, type=Gtk.WindowType.POPUP)

        # No title bar, borderless popup
        self.set_decorated(False)
        self.set_border_width(5)
        self.set_default_size(150, 30)

        # Horizontal slider from 0 to 100
        self.slider = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.slider.set_value(self.get_volume())
        self.slider.set_draw_value(False)  # Hide numeric value on slider
        self.slider.connect("value-changed", self.on_volume_change)

        self.add(self.slider)

        # Close popup when mouse leaves or loses focus
        self.connect("leave-notify-event", self.on_mouse_leave)
        self.connect("focus-out-event", self.on_focus_out)

        self.show_all()

    def get_volume(self):
        try:
            output = subprocess.check_output(["pamixer", "--get-volume"])
            return int(output.strip())
        except Exception:
            return 50

    def on_volume_change(self, scale):
        vol = int(scale.get_value())
        subprocess.call(["pamixer", "--set-volume", str(vol)])

    def on_mouse_leave(self, widget, event):
        Gtk.main_quit()

    def on_focus_out(self, widget, event):
        Gtk.main_quit()

def main():
    win = VolumePopup()

    # Default fixed coordinates just below top bar PulseAudio module
    # You can override by passing X and Y as command line args
    x = 1200
    y = 40

    if len(sys.argv) >= 3:
        try:
            x = int(sys.argv[1])
            y = int(sys.argv[2])
        except ValueError:

