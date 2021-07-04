from shakersynth.synth.rotor import RotorSynth
from math import isclose
from pytest import fixture, raises


@fixture
def rotor():
    return RotorSynth()


def test_calculate_rotor_rpm_is_correct_for_mi8(rotor):
    telemetry = {
        "module": "mi-8mt",
        "rotor_rpm_percent": 95.0
    }
    rpm = rotor._calculate_rotor_rpm(telemetry)
    assert isclose(rpm, 200)


def test_calculate_rotor_rpm_is_correct_for_mi24(rotor):
    telemetry = {
        "module": "mi-24p",
        "rotor_rpm_percent": 95.0
    }
    rpm = rotor._calculate_rotor_rpm(telemetry)
    assert isclose(rpm, 280)


def test_calculate_rotor_rpm_is_correct_for_huey(rotor):
    telemetry = {
        "module": "uh-1h",
        "rotor_rpm_percent": 90.0
    }
    rpm = rotor._calculate_rotor_rpm(telemetry)
    assert isclose(rpm, 324)


def test_unsupported_module_raises_exception(rotor):
    with raises(NotImplementedError):
        rotor.update({"module": "whirlybird-5000"})
