import pyo
import time
import random

# pyo docs: http://ajaxsoundstudio.com/pyodoc/

# audio synthesis setup

server = pyo.Server(
    nchnls=2,
    duplex=0,
    buffersize=2048,
    sr=44100
)
server.setVerbosity(1)


def scan_pick_audio_device():
    # Map audio outputs from internal numbers (which can be sparse and large)
    # to a friendly, 1-indexed, monotonic series for the user.
    print("Scanning audio devices...")
    output_devices = pyo.pa_get_devices_infos()[1]
    default_api = pyo.pa_get_default_host_api()
    friendly_to_internal = {}

    print("Found these audio outputs:")
    device_details = enumerate(output_devices.items())
    for friendly_index, (internal_index, properties) in device_details:
        # Only list devices that are available using the default audio API.
        if properties["host api index"] == default_api:
            friendly_index += 1
            friendly_to_internal[friendly_index] = internal_index
            print(f"  {friendly_index}: {properties['name']}")

    print("Enter device ID to use: ", end="")
    chosen_device = int(input())
    print("picked device with internal id: ", friendly_to_internal[chosen_device])
    return friendly_to_internal[chosen_device]


# server.setOutputDevice(scan_pick_audio_device())
server.setOutputDevice(6)  # pulseaudio

server.boot()
server.start()
server.setAmp(0.8)


def blade_synth(num_blades=5, max_harm=5):
    """
    major sources of excitation are at frequencies of
    (n - 1) Ω, n Ω, (n + 1) Ω, (2n - 1) Ω, 2nQ, (2n + 1) Ω,
    determined by the number of blades n and the rotational frequency of the rotor, Ω.
    """
    harmonics = [0] * num_blades * max_harm
    for i in range(1, max_harm):
        harmonics[i * num_blades] += i ** -2
    # print(harmonics)

    t = pyo.HarmTable(harmonics)
    return pyo.Osc(table=t, freq=[10, 11], mul=.2)


# s = blade_synth(3).out()

env = pyo.Fader(fadein=.01, fadeout=.1, dur=.11)  # sharp attack, long release.
env.setExp(1.2)  # setExp method can be used to create exponential or logarithmic envelope.


def play_note():
    "Play a new note with random frequency and jitterized envelope."
    freq = 40
    sig.freq = [freq, freq * 1.001]
    env.play()


# sig = pyo.LFO(freq=[1, 1], mul=env)
# pat = pyo.Pattern(play_note, time=.2).play()  # periodically call a function.
# lp = pyo.Biquad(sig, freq=200).out()

# Creates two objects with cool parameters, one per channel.
a = pyo.FM().out()
b = pyo.FM().out(1)

# Opens the controller windows.
a.ctrl(title="Frequency modulation left channel")
b.ctrl(title="Frequency modulation right channel")

# If a list of values is given at a particular argument, the ctrl
# window will show a multislider to set each value separately.

oscs = pyo.Sine([100, 200, 300, 400, 500, 600, 700, 800], mul=0.1).out()
oscs.ctrl(title="Simple additive synthesis")

spec = pyo.Spectrum(oscs, size=1024)
server.gui(locals())
