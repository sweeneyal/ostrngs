import numpy as np

class Platform:
    def __init__(self, filename, fpga_size=(100,200)):
        self.file    = open(filename, mode="w")
        self.fpga    = fpga_size

    def create_zone(self, xl, xh, yl, yh):
        self.zones.append((xl, xh, yl, yh))

    def create_pblock(self, pblock_name):
        self.file.write(f"create_pblock {pblock_name}\n")

    def resize_pblock(self, pblock_name, slices):
        self.file.write(f"resize_pblock [get_pblocks {pblock_name}] -add {slices}\n")
    
    def make_pblock_hard(self, pblock_name):
        self.file.write(f"set_property IS_SOFT 0 [get_pblocks {pblock_name}]\n")

    def contain_routing(self, pblock_name):
        self.file.write(f"set_property CONTAIN_ROUTING TRUE [get_pblocks {pblock_name}]\n")

    def allocate_pblock(self, pblock_name, size, point, exclusion=False, soft=True, contain_routing=False):
        self.create_pblock(pblock_name)
        if len(size) > 1:
            slices = f"SLICE_X{point[0]}Y{point[1]}:SLICE_X{point[0] + size[0]}Y{point[1] + size[1]}"
        else:
            slices = f"SLICE_X{point[0]}Y{point[1]}"
        self.resize_pblock(pblock_name, slices)
        if not soft:
            self.make_pblock_hard(pblock_name)
        if contain_routing:
            self.contain_routing(pblock_name)

    def add_module_to_pblock(self, pblock_name, module_name):
        self.file.write(f"add_cells_to_pblock [get_pblocks {pblock_name}] -cells [get_cells {module_name}]\n")

    def add_macro(self, cells, rlocs):
        pass

class Routing:
    def __init__(self, filename):
        self.file = open(filename, mode="w")
    
    def add_to_preroute(self, routes):
        self.file.write(f"route_design -nets [get_nets {routes}]\n")

    def add_obj_to_preroute(self, obj):
        self.file.write(f"route_design -nets [get_nets -of_objects [get_cells {obj}]]\n")

    def __del__(self):
        self.file.write("set_property -name {STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS} -value -preserve -objects [get_runs impl_1]")