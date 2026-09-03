"""Emacs-like bindings for Keyhac 2 on Windows."""

from keyhac import *


# Process names are compared without a trailing ".exe".
EXCLUDED_APPS = {
    "windowsterminal",
}

# Cascadia class is included as a fallback for Windows Terminal.
EXCLUDED_CLASSES = {
    "cascadia_hosting_window_class",
    "consolewindowclass",
    "cygwin/x x rl-xterm-xterm-0",
    "meadow",
}


def configure(keymap):
    keymap.clipboard_history.max_items = 500
    state = {"mark": False}

    kt_global = keymap.define_keytable(focus_path_pattern="*")

    def toggle_ime():
        status = keymap.get_ime_status()
        if status is None:
            return
        keymap.set_ime_status(not status)

    kt_global["Ctrl-Space"] = toggle_ime        

    #
    # Key bind except terminal apps
    #

    def normalized_app_name(focus):
        name = (focus.app_name or "").casefold()
        return name[:-4] if name.endswith(".exe") else name

    def use_emacs_bindings(focus):
        app_name = normalized_app_name(focus)
        class_name = (focus.class_name or "").casefold()
        return app_name not in EXCLUDED_APPS and class_name not in EXCLUDED_CLASSES

    kt = keymap.define_keytable(custom_condition_func=use_emacs_bindings)

    def send(*keys, clear_mark=True):
        def command():
            with keymap.get_input_context() as ctx:
                for key in keys:
                    ctx.send_key(key)
            if clear_mark:
                state["mark"] = False

        return command

    def move(key):
        def command():
            output = f"Shift-{key}" if state["mark"] else key
            with keymap.get_input_context() as ctx:
                ctx.send_key(output)

        return command

    def toggle_mark():
        state["mark"] = not state["mark"]
        if state["mark"]:
            keymap.pop_balloon("emacs-mark", "Mark set", 1.0)
        else:
            keymap.close_balloon("emacs-mark")

    # Cursor movement.  While mark mode is active these extend the selection.
    kt["Ctrl-A"] = move("Home")
    kt["Ctrl-E"] = move("End")
    kt["Ctrl-F"] = move("Right")
    kt["Ctrl-B"] = move("Left")
    kt["Ctrl-P"] = move("Up")
    kt["Ctrl-N"] = move("Down")
    kt["Alt-V"] = move("PageUp")
    # Ctrl-< and Ctrl-> are Ctrl-Shift-Comma and Ctrl-Shift-Period on the
    # keyboard.  While mark mode is active these extend the selection.
    kt["Ctrl-Shift-Comma"] = move("Ctrl-Home")
    kt["Ctrl-Shift-Period"] = move("Ctrl-End")
    kt["Alt-F"] = move("Ctrl-Right")
    kt["Alt-B"] = move("Ctrl-Left")

    # Editing and basic commands.
    kt["Ctrl-D"] = send("Delete")
    kt["Ctrl-H"] = send("Back")
    kt["Ctrl-K"] = send("Shift-End", "Ctrl-X")
    kt["Ctrl-O"] = send("End", "Return", "Up")
    kt["Ctrl-G"] = send("Escape")
    kt["Ctrl-J"] = send("Return", "Tab")
    kt["Ctrl-M"] = send("Return")
    kt["Ctrl-I"] = send("Tab")

    # Windows applications generally have only forward search.
    kt["Ctrl-S"] = send("Ctrl-F")
    kt["Ctrl-R"] = send("Ctrl-F")

    # Clipboard and undo.
    kt["Alt-W"] = send("Ctrl-C")
    kt["Ctrl-W"] = send("Ctrl-X")
    kt["Ctrl-Y"] = send("Ctrl-V")
    kt["Alt-Y"] = ShowClipboardHistory()
    kt["Ctrl-Slash"] = send("Ctrl-Z")

    # Mark mode.  Ctrl-Atmark is useful on some JIS keyboard layouts.
    kt["Ctrl-Atmark"] = toggle_mark

    # Emacs-style C-x prefix.  The original AHK comments said C-x, although its
    # actual hotkey was Ctrl-Z; this uses the conventional Emacs spelling.
    ctrl_x = keymap.define_keytable(name="Ctrl-X")
    ctrl_x["Ctrl-F"] = send("Ctrl-O")
    ctrl_x["Ctrl-S"] = send("Ctrl-S")
    ctrl_x["Ctrl-C"] = send("Alt-F4")
    kt["Ctrl-X"] = ctrl_x
