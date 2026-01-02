import serial
import numpy as np
from tqdm import tqdm

ERROR_HEADER = 0xFF
SET_HEADER   = 0xA0
GET_HEADER   = 0x0A

DDR_ADDRESS = 0x8000_0000
# Add an additional buffer on top. This cuts the available space,
# but there's 256 MB, and it's a loss of 256 bytes.
RAM_ADDRESS = DDR_ADDRESS + 0x100

TRNG_TESTBED_ADDRESS        = 0x0
TRNG_FIFO_ADDRESS           = TRNG_TESTBED_ADDRESS + 0x200
TRNG_STATUS_MODE_ADDRESS    = TRNG_TESTBED_ADDRESS + 0x204
TRNG_STATUS_TOTAL_ADDRESS   = TRNG_TESTBED_ADDRESS + 0x208
TRNG_STATUS_COUNT_ADDRESS   = TRNG_TESTBED_ADDRESS + 0x20C
TRNG_STATUS_RNG_ADDRESS     = TRNG_TESTBED_ADDRESS + 0x210
TRNG_STATUS_MEMADDR_ADDRESS = TRNG_TESTBED_ADDRESS + 0x214
TRNG_STATUS_HEALTH_ADDRESS  = TRNG_TESTBED_ADDRESS + 0x214

class Supervisor:
    def __init__(self, port, baud, timeout=5.0):
        self.serial = serial.Serial(port, baud, timeout=timeout)
        self.total  = 0

    def open(self):
        # An empty packet with just the error header 
        # ensures that we will only get an error in response
        packet = bytearray(
            [ERROR_HEADER, 0, 0, 0, 0, 0, 0, 0, 0, 0, ERROR_HEADER]
        )
        self.serial.write(packet)
        response = self.serial.read(1)
        if int.from_bytes(response, 'little') == ERROR_HEADER:
            return True
        else:
            raise Exception

    """
    The following functions are setters. These set different mapped addresses
    for the TRNG Testbed IP. The packet structure for setting packets is:
        header  (0xA0)
        address (4 bytes little endian)
        data    (4 bytes little endian)
        wstrb   (1 byte)
        crc     (1 byte, overflowed sum of all previous bytes)
    If a set command is accepted, a set header is returned. Otherwise, an error 
    header is returned.
    """

    def __create_set_packet(self, address, data, wstrb):
        packet = bytearray([SET_HEADER]) \
            + address.to_bytes(4, 'little') \
            + data.to_bytes(4, 'little') \
            + wstrb.to_bytes(1) 
        crc = sum(packet)
        crc &= 0xFF
        crc = crc.to_bytes(1, 'little')
        packet += crc
        return packet

    def set_entropy_source(self, source):
        packet = self.__create_set_packet(TRNG_STATUS_RNG_ADDRESS, source, 0x0F)
        self.serial.write(packet)
        response = self.serial.read(1)
        if int.from_bytes(response, 'little') == SET_HEADER:
            return True
        else:
            raise Exception

    def set_status(self, mode, enable):
        packet = self.__create_set_packet(TRNG_STATUS_MODE_ADDRESS, (enable << 8) | mode, 0x0F)
        self.serial.write(packet)
        response = self.serial.read(1)
        if int.from_bytes(response, 'little') == SET_HEADER:
            return True
        else:
            raise Exception

    def set_total(self, total):
        packet = self.__create_set_packet(TRNG_STATUS_TOTAL_ADDRESS, total, 0x0F)
        self.serial.write(packet)
        response = self.serial.read(1)
        if int.from_bytes(response, 'little') == SET_HEADER:
            self.total = total
            return True
        else:
            raise Exception

    def set_address(self, address):
        packet = self.__create_set_packet(TRNG_STATUS_MEMADDR_ADDRESS, address, 0x0F)
        self.serial.write(packet)
        response = self.serial.read(1)
        if int.from_bytes(response, 'little') == SET_HEADER:
            return True
        else:
            raise Exception

    """
    The following functions are getters. These get different mapped addresses
    for the TRNG Testbed IP. The packet structure for getting packets is:
        header  (0x0A)
        address (4 bytes little endian)
        data    (4 bytes little endian)
        wstrb   (1 byte, all bits zero)
        crc     (1 byte, overflowed sum of all previous bytes)
    If a get command is accepted, the data is returned with a crc. Otherwise, an error 
    header is returned.
    """

    def __create_get_packet(self, address):
        packet = bytearray([GET_HEADER]) \
            + address.to_bytes(4, 'little') \
            + 0x00000000.to_bytes(4, 'little') \
            + 0x00.to_bytes(1) 
        crc = sum(packet)
        crc &= 0xFF
        crc = crc.to_bytes(1, 'little')
        packet += crc
        return packet

    def get_entropy(self):
        pass

    def get_entropy_source(self):
        packet = self.__create_get_packet(TRNG_STATUS_RNG_ADDRESS)
        self.serial.write(packet)
        response = self.serial.read(5)
        if len(response) == 5 and \
                sum(response[0:4]) == response[4]:
            return int.from_bytes(response[0:4], 'little')
        else:
            raise Exception
        
    def get_status(self):
        packet = self.__create_get_packet(TRNG_STATUS_MODE_ADDRESS)
        self.serial.write(packet)
        response = self.serial.read(5)
        if len(response) == 5 and \
                sum(response[0:4]) == response[4]:
            return int.from_bytes(response[0:4], 'little')
        else:
            raise Exception
        
    def get_mode(self):
        return self.get_status() & 0xFF;

    def get_enable(self):
        return self.get_status() >> 8;

    def get_count(self):
        packet = self.__create_get_packet(TRNG_STATUS_COUNT_ADDRESS)
        self.serial.write(packet)
        response = self.serial.read(5)
        if len(response) == 5 and \
                sum(response[0:4]) == response[4]:
            return int.from_bytes(response[0:4], 'little')
        else:
            raise Exception

    def get_total(self):
        packet = self.__create_get_packet(TRNG_STATUS_TOTAL_ADDRESS)
        self.serial.write(packet)
        response = self.serial.read(5)
        if len(response) == 5 and \
                sum(response[0:4]) == response[4]:
            return int.from_bytes(response[0:4], 'little')
        else:
            raise Exception

    def get_address(self):
        packet = self.__create_get_packet(TRNG_STATUS_MEMADDR_ADDRESS)
        self.serial.write(packet)
        response = self.serial.read(5)
        if len(response) == 5 and \
                sum(response[0:4]) == response[4]:
            return int.from_bytes(response[0:4], 'little')
        else:
            raise Exception
        
    def get_ddr_address(self, address):
        packet = self.__create_get_packet(address)
        self.serial.write(packet)
        response = self.serial.read(5)
        crc = sum(response[0:4])
        crc &= 0xFF
        if len(response) == 5 and crc == response[4]:
            return response[0:4]
        else:
            raise Exception
        
    def read_ddr(self):
        capture = np.zeros(self.total,dtype=np.uint8)
        pbar = tqdm(total=self.total, desc="Reading DDR Ram")
        for ii in range(0, self.total, 4):
            attempts = 0
            success  = False
            data     = bytes(4)
            while not success and attempts < 3:
                try:
                    data = self.get_ddr_address(RAM_ADDRESS + ii)
                    success = True
                except:
                    attempts += 1
            data = np.frombuffer(data, dtype=np.uint8)
            for jj in range(4):
                capture[ii + jj] = data[jj]
            pbar.update(4)
        return capture


if __name__ == "__main__":
    import time

    s = Supervisor("/dev/ttyUSB1", 12000000)
    s.open()

    s.set_status(0, 0)

    s.set_entropy_source(1)
    print(f"Selected entropy source: {s.get_entropy_source()}")

    s.set_total(1_000)
    print(f"Set total collected: {s.get_total()}")

    s.set_address(RAM_ADDRESS)
    print(f"Starting memory address: {hex(s.get_address())}")

    # This will set the mode to 1, which is DDR write mode, with 
    # only entropy source 5 enabled.
    s.set_status(1, 1 << 1)

    time.sleep(1)
    while s.get_mode() != 0:
        time.sleep(1)

    capture = s.read_ddr()

    from datetime import datetime
    now = datetime.now()

    now = now.strftime("%Y-%m-%d_%H:%M:%S")
    with open(now + '_collection.bin', "wb") as f:
        f.write(capture)