import sys

sys.path.append('./python')

from ostrngs.hw.xdc import Platform, Routing
from ostrngs.hw.ap import Area, scatter

TOP_ENTITY      = "system_i"
TRNG_TESTBED    = TOP_ENTITY + "/TrngTestbed_0"
TRNG_GENERATORS = TRNG_TESTBED + "/inst/eCore/eSandbox/eTrngs"

p = Platform("./hdl/xdc/ostrngs_generated.xdc")
r = Routing("./tcl/ostrngs_prerouter.tcl")

entropy_sources = [
    "MeshCoupledXor",
    "OpenLoopMetaTrng",
    "LwxnorLutTrng",
    "XorRingTrng",
    "DigitalNonlinearOscillator",
    "HybridFfsrTrng",
    "LwxnorTrng",
    "RoLdceTrng"
]

source_sizes = [
    (3,3),
    (4,16),
    (2,6),
    (1,4),
    (1,2),
    (3,3),
    (3,3),
    (3,3)
]

X_MIN = 12
Y_MIN = 5
X_MAX = 76
Y_MAX = 49

coords = []
space = Area(X_MIN, X_MAX, Y_MIN, Y_MAX)

for size in source_sizes:
    next_coord = scatter(space, size[0], size[1])
    if next_coord is not None:
        coords.append(next_coord)
        print(next_coord)
    else:
        raise Exception

for id, source, size in zip(range(len(entropy_sources)), entropy_sources, source_sizes):
    pb = f"p_source{id}_{source}"
    if source == "MeshCoupledXor":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gMeshCoupledXor.eMeshCoupledXor/e*")
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gMeshCoupledXor.eMeshCoupledXor/*")
    elif source == "OpenLoopMetaTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]),soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/eFirstCarry_C")
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/eFirstCarry_D")
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[*].eCarry_C")
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[*].eCarry_D")
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/gSampleLatches[*].d_latch_reg[*]")
        p.add_module_to_pblock(pb, 
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/eCascade/*")
        
        # Add macro to make d_latch_regs align with carry chain.
        cells = []
        rlocs = []
        for carry in range(1, 16):
            cells.append(
                TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
                f".gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[{carry}].eCarry_C")
            rlocs.append(f"X0Y{carry}")
            cells.append(
                TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
                f".gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[{carry}].eCarry_D")
            rlocs.append(f"X2Y{carry}")
            for latch in range(4):
                cells.append(
                    TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
                    f".gOpenLoopMetaTrng.eOpenLoopMeta/gSampleLatches[{4 * (carry - 1) + latch}].d_latch_reg[{4 * (carry - 1) + latch}]")
                rlocs.append(f"X2Y{(carry - 1)}")

        p.add_macro(f"m0_source{id}_{source}", cells, rlocs)

        p.set_false_path(path_thru=
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/eFirstCarry_C/CYINIT")

        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/eCascade/*")
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/c_init")
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gOpenLoopMetaTrng.eOpenLoopMeta/d_init")
    elif source == "LwxnorLutTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gLwxnorLutTrng.eLwxnorLutTrng/gLwxnorLuts[*].e*")
        
        r.add_obj_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gLwxnorLutTrng.eLwxnorLutTrng/gLwxnorLuts[*].e*")
    elif source == "XorRingTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gXorRingTrng.eXorRingTrng/xor_net*")
        
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gXorRingTrng.eXorRingTrng/xor_net[*]")
    elif source == "DigitalNonlinearOscillator":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gDnoTrng.eDnoTrng/eDno/*")
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gDnoTrng.eDnoTrng/ro*")
        
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gDnoTrng.eDnoTrng/eDno/*")
        r.add_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gDnoTrng.eDnoTrng/ro[*]")
    elif source == "HybridFfsrTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gHybridFfsrTrng.eHybridFfsrTrng/e*")
        
        r.add_obj_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gHybridFfsrTrng.eHybridFfsrTrng/e*")
    elif source == "LwxnorTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gLwxnorTrng.eLwxnorTrng/gLwxnors[*].e*")
        
        r.add_obj_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gLwxnorTrng.eLwxnorTrng/gLwxnors[*].e*")
    elif source == "RoLdceTrng":
        p.allocate_pblock(pb, size, point=(coords[id][0], coords[id][1]), soft=False, contain_routing=True, exclusion=True)
        p.add_module_to_pblock(pb,
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gRoLdceTrng.eRoLdceTrng/gRoLdces[*].e*")
        
        r.add_obj_to_preroute(
            TRNG_GENERATORS + f"/gEntropySourceInstantiation[{id}]" + 
            ".gRoLdceTrng.eRoLdceTrng/gRoLdces[*].e*")

