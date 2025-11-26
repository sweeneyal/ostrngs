import sys

sys.path.append('./python')

from ostrngs.hw.control import Supervisor, RAM_ADDRESS
import time
import numpy as np

DATA_PATH = "./data/collections/"
SEQ_PATH  = "sequential/"
RES_PATH  = "restart/"

s = Supervisor("/dev/ttyUSB1", 12_000_000)
s.open()

def run_sequential_collection(s : Supervisor, source):
    # clear mode and enable on the testbed IP.
    # this will reset all entropy sources.
    s.set_status(0, 0)

    # set the selected entropy source.
    s.set_entropy_source(source)
    source = s.get_entropy_source()
    print(f"> Selected entropy source: {source}")

    # set the total to the sequential requirement of 1 million samples.
    s.set_total(1_000_000)
    print(f"> Set total collected: {s.get_total()}")

    # set the RAM address.
    s.set_address(RAM_ADDRESS)
    print(f"> Starting memory address: {hex(s.get_address())}")

    # now set the mode and the enable simultaneously
    s.set_status(1, 1 << source)
    print("> Starting on-board data collection...")

    time.sleep(1)
    while s.get_mode() != 0:
        time.sleep(1)

    capture = s.read_ddr()

    from datetime import datetime
    now = datetime.now()

    now = now.strftime("%Y-%m-%d_%H:%M:%S")
    path = DATA_PATH + SEQ_PATH + f"sourceid_{source}_" + now + '_sequential.bin'
    with open(path, "wb") as f:
        f.write(capture)

def run_restart_collection(s : Supervisor, source):
    # clear mode and enable on the testbed IP.
    # this will reset all entropy sources.
    s.set_status(0, 0)

    # set the selected entropy source.
    s.set_entropy_source(source)
    source = s.get_entropy_source()
    print(f"> Selected entropy source: {source}")

    # set the total captured to be 1000, per the requirements of the restart tests
    s.set_total(1_000)
    print(f"> Set total collected: {s.get_total()}")

    # set the ram address
    s.set_address(RAM_ADDRESS)
    print(f"> Starting memory address: {hex(s.get_address())}")

    collection = np.zeros(1000 * 1000, dtype=np.uint8)
    for ii in range(1000):
        s.set_status(1, 1 << source)
        print(f"> Starting restart iteration {ii} of source {source}...")

        time.sleep(1)
        while s.get_mode() != 0:
            time.sleep(1)

        capture = s.read_ddr()
        collection[1000*ii:1000*ii + 1000] = capture[0:1000]

    from datetime import datetime
    now = datetime.now()

    now = now.strftime("%Y-%m-%d_%H:%M:%S")
    path = DATA_PATH + RES_PATH + f"sourceid_{source}_" + now + '_restart.bin'
    with open(path, "wb") as f:
        f.write(collection)

for ii in range(8):
    run_sequential_collection(s, ii)
    run_restart_collection(s, ii)