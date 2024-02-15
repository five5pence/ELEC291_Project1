# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import time
import serial

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys, time, math

xsize=100

def data_gen():
    t = data_gen.t
    while True:
        t+=1
        strin = ser.read(5)
        int_val = int(strin.decode('utf-8'))/10
        print(int_val)
        val = int_val
        yield t, val

def run(data):
    # update the data
    t,y = data
    if t>-1:
        xdata.append(t)
        ydata.append(y)
        if t>xsize: # Scroll to the left.
            ax.set_xlim(t-xsize, t)
        line.set_data(xdata, ydata)

    return line,

def on_close_figure(event):
    sys.exit(0)
 
# configure the serial port
#print ("hello world")
ser = serial.Serial(
    port='COM5',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    bytesize=serial.EIGHTBITS
)
ser.isOpen()

plt.rcParams.update({'font.size': 20})
data_gen.t = -1
fig = plt.figure()
fig.canvas.mpl_connect('close_event', on_close_figure)
ax = fig.add_subplot(111)
line, = ax.plot([], [], lw=2)
ax.set_ylim(0, 260)
ax.set_xlim(0, xsize)
ax.grid()
xdata, ydata = [], []
# setting title name
plt.title("Oven Temperature vs. Time", fontsize=20)
plt.xlabel("Time (deciseconds)", fontsize=20)
plt.ylabel("Oven Temperature (degrees celsius)", fontsize=20)

# Important: Although blit=True makes graphing faster, we need blit=False to prevent
# spurious lines to appear when resizing the stripchart.
ani = animation.FuncAnimation(fig, run, data_gen, blit=False, interval=1, repeat=False)
plt.show()