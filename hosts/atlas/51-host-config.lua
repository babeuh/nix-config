disable_nvidia = {
  matches = {
    {
      { "device.vendor.name", "equals", "NVIDIA Corporation" },
    },
    {
      { "node.nick", "equals", "Blue Microphones" },
      { "api.alsa.pcm.stream", "equals", "playback" },
    },
  },
  apply_properties = {
    ["device.disabled"] = true,
  },
}

disable_webcam_source = {
  matches = {
    {
      { "node.nick", "equals", "BRIO 4K Stream Edition" },
      { "api.alsa.pcm.stream", "equals", "capture" },
    },
  },
  apply_properties = {
    ["node.disabled"] = true,
  },
}

disable_microphone_sink = {
  matches = {
    {
      { "node.nick", "equals", "Blue Microphones" },
      { "api.alsa.pcm.stream", "equals", "playback" },
    },
  },
  apply_properties = {
    ["node.disabled"] = true,
  },
}

disable_headphones_source = {
  matches = {
    {
      { "node.name", "equals", "alsa_input.pci-0000_0b_00.3.analog-stereo" },
    },
  },
  apply_properties = {
    ["node.disabled"] = true,
  },
}

rename_headphones = {
  matches = {
    {
      { "node.name", "equals", "alsa_output.pci-0000_0b_00.3.analog-stereo" },
    },
  },
  apply_properties = {
    ["node.description"] = "Headphones",
  },
}

table.insert(alsa_monitor.rules,disable_nvidia)
table.insert(alsa_monitor.rules,disable_webcam_source)
table.insert(alsa_monitor.rules,disable_microphone_sink)
table.insert(alsa_monitor.rules,rename_headphones)