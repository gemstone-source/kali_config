-- Input devices: keyboard, mouse, touchpad, and cursor.

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape",
        kb_rules = "",

        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,
        accel_profile = "flat",

        repeat_rate = 50,
        repeat_delay = 300,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            drag_lock = 0,
            disable_while_typing = true,
            scroll_factor = 0.5,
        },
    },

    cursor = {
        -- Force software cursor rendering for VMware compatibility.
        no_hardware_cursors = 1,
    },

    device = {
        ["virtualps/2-vmware-vmmouse"] = {
            enabled = false,
        },
        ["virtualps/2-vmware-vmmouse-1"] = {
            enabled = false,
        },
        ["vmware-dnd-uinput-pointer"] = {
            enabled = false,
        },
    },
})
