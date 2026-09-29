-- Desktop monitor layout and workspace assignments.

hl.monitor({ output = "DP-1", mode = "5120x1440@119.970", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "5120x-480", scale = 1, transform = 1 })
hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "-1080x-480", scale = 1, transform = 3 })
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "1280x-1440", scale = 1.5 })

hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
hl.workspace_rule({ workspace = "7", monitor = "DP-1" })
hl.workspace_rule({ workspace = "8", monitor = "DP-3" })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "10", monitor = "DP-2" })
