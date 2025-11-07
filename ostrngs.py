import serial
import numpy as np
from datetime import datetime

s = serial.Serial("/dev/ttyUSB1", 9600)

rng_types = [
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor",
    "MeshCoupledXor"
]

rng_idx = 0
total   = 1000000

# Get the current local date and time
current_datetime = datetime.now()
datetime_string = current_datetime.strftime("%Y-%m-%d_%H:%M:%S")

s.write('r'.encode("utf-8"))

data = s.read(total)
data = np.frombuffer(data, dtype=np.uint8)

fname = 'data/collections/' + datetime_string + "_" + rng_types[rng_idx] + "_raw.npy"
print("Done")
np.save(fname, data)
