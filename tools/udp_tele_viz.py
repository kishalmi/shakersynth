import socket
import yaml
import numpy as np
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtGui

# UDP client socket
udp = socket.socket(type=socket.SOCK_DGRAM)
udp.bind(("", 17707))

buf = 3000


def value1(telemetry):
    if 'accel' not in telemetry: return 0
    return np.sqrt(telemetry['accel'][0] ** 2 + telemetry['accel'][1] ** 2 + telemetry['accel'][2] ** 2)


def value2(telemetry):
    if 'shake' not in telemetry: return 0
    return telemetry['shake'][1]


def value3(telemetry):
    if 'gun_rounds' not in telemetry: return 0
    return telemetry['gun_rounds']


# setup UI
win = pg.GraphicsLayoutWidget(show=True)
win.setWindowTitle('DCS telemetry')

pl1 = win.addPlot()
data1 = np.zeros(buf)
curve1 = pl1.plot(data1)
win.nextRow()
pl2 = win.addPlot()
data2 = np.zeros(buf)
curve2 = pl2.plot(data2)
win.nextRow()
pl3 = win.addPlot()
data3 = np.zeros(buf)
curve3 = pl3.plot(data3)

ptr = 0


def update():
    global ptr, data1, data2, data3
    ptr += 1

    # receive telemetry
    msg = udp.recv(1024)
    telemetry = yaml.safe_load(msg.decode())

    data1[:-1] = data1[1:]  # shift data in the array one sample left (see also: np.roll)
    data1[-1] = value1(telemetry)
    curve1.setData(data1)
    curve1.setPos(ptr, 0)

    data2[:-1] = data2[1:]
    data2[-1] = value2(telemetry)
    curve2.setData(data2)
    curve2.setPos(ptr, 0)

    data3[:-1] = data3[1:]
    data3[-1] = value3(telemetry)
    curve3.setData(data3)
    curve3.setPos(ptr, 0)


timer = pg.QtCore.QTimer()
timer.timeout.connect(update)
timer.start(1)

## Start Qt event loop unless running in interactive mode or using pyside.
if __name__ == '__main__':
    import sys

    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QGuiApplication.instance().exec_()
