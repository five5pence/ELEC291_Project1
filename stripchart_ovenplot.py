# Initialize timer 1 to send a read of temperature every second -> assembly
# Convert binary temperature to ASCII
# Place ASCII value in the accumulator
# Send ASCII byte to serial port
# Write a python script to read from the serial port
# Modify the plot program to read from serial port COM9
# Figure out how python plots serial input values

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys, time, math, serial

# configure the serial port to read from USB COM9
ser = serial.Serial(
    port='COM9',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    bytesize=serial.EIGHTBITS
)
ser.is_open # serial port open status flag

xsize=100 # set default upper bound of x

def data_gen(): # draws a plot of the serial inputs
    data_gen.t = 0 # initialize t to 0
    while True:
        t = data_gen.t
        data_gen.t += 1 # advance t
        val = 2 #ser.readline() # read data from serial port
        print(val)
        yield t, val

def run(data): # define a function to plot
    t,y = data
    if t > -1:
        xdata.append(t) # dynamically update xdata with values of t
        ydata.append(y) # dynamically update ydata with values of y
        if t > xsize: # Scroll to the left.
            ax.set_xlim(t - xsize, t)
        line.set_data(xdata, ydata) 

    return line,

def on_close_figure(event):
    sys.exit(0)

data_gen.t = -1
fig = plt.figure()
fig.canvas.mpl_connect('close_event', on_close_figure)
ax = fig.add_subplot(111)
line, = ax.plot([], [], lw=2)
ax.set_ylim(0, 300) # set bounds of y axis
ax.set_xlim(0, xsize) # set bounds of x axis
ax.grid()
xdata, ydata = [], []
plt.xlabel("Time (seconds)")
plt.ylabel("Temperature (Degrees Celsius)")

# Important: Although blit=True makes graphing faster, we need blit=False to prevent
# spurious lines to appear when resizing the stripchart.
while 1 :
    strin = ser.readline()
    print(strin)

ani = animation.FuncAnimation(fig, run, data_gen, blit=False, interval=100, repeat=False)
plt.show()