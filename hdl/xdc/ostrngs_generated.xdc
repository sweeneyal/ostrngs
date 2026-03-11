create_pblock p_source0_MeshCoupledXor
resize_pblock [get_pblocks p_source0_MeshCoupledXor] -add SLICE_X12Y5:SLICE_X15Y8
set_property IS_SOFT 0 [get_pblocks p_source0_MeshCoupledXor]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source0_MeshCoupledXor]
add_cells_to_pblock [get_pblocks p_source0_MeshCoupledXor] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[0].gMeshCoupledXor.eMeshCoupledXor/e*]
create_pblock p_source1_OpenLoopMetaTrng
resize_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -add SLICE_X20Y5:SLICE_X24Y21
set_property IS_SOFT 0 [get_pblocks p_source1_OpenLoopMetaTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source1_OpenLoopMetaTrng]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/eFirstCarry_C]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/eFirstCarry_D]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[*].eCarry_C]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/gFineDelayGeneration[*].eCarry_D]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/gSampleLatches[*].d_latch_reg[*]]
add_cells_to_pblock [get_pblocks p_source1_OpenLoopMetaTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[1].gOpenLoopMetaTrng.eOpenLoopMeta/eCascade/*]
create_pblock p_source2_LwxnorLutTrng
resize_pblock [get_pblocks p_source2_LwxnorLutTrng] -add SLICE_X28Y5:SLICE_X30Y11
set_property IS_SOFT 0 [get_pblocks p_source2_LwxnorLutTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source2_LwxnorLutTrng]
add_cells_to_pblock [get_pblocks p_source2_LwxnorLutTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[2].gLwxnorLutTrng.eLwxnorLutTrng/gLwxnorLuts[*].e*]
create_pblock p_source3_XorRingTrng
resize_pblock [get_pblocks p_source3_XorRingTrng] -add SLICE_X36Y5:SLICE_X37Y9
set_property IS_SOFT 0 [get_pblocks p_source3_XorRingTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source3_XorRingTrng]
add_cells_to_pblock [get_pblocks p_source3_XorRingTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[3].gXorRingTrng.eXorRingTrng/xor_net*]
create_pblock p_source4_DigitalNonlinearOscillator
resize_pblock [get_pblocks p_source4_DigitalNonlinearOscillator] -add SLICE_X44Y5:SLICE_X45Y7
set_property IS_SOFT 0 [get_pblocks p_source4_DigitalNonlinearOscillator]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source4_DigitalNonlinearOscillator]
add_cells_to_pblock [get_pblocks p_source4_DigitalNonlinearOscillator] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[4].gDnoTrng.eDnoTrng/eDno/*]
add_cells_to_pblock [get_pblocks p_source4_DigitalNonlinearOscillator] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[4].gDnoTrng.eDnoTrng/ro*]
create_pblock p_source5_HybridFfsrTrng
resize_pblock [get_pblocks p_source5_HybridFfsrTrng] -add SLICE_X52Y5:SLICE_X55Y8
set_property IS_SOFT 0 [get_pblocks p_source5_HybridFfsrTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source5_HybridFfsrTrng]
add_cells_to_pblock [get_pblocks p_source5_HybridFfsrTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[5].gHybridFfsrTrng.eHybridFfsrTrng/e*]
create_pblock p_source6_LwxnorTrng
resize_pblock [get_pblocks p_source6_LwxnorTrng] -add SLICE_X60Y5:SLICE_X62Y7
set_property IS_SOFT 0 [get_pblocks p_source6_LwxnorTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source6_LwxnorTrng]
add_cells_to_pblock [get_pblocks p_source6_LwxnorTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[6].gLwxnorTrng.eLwxnorTrng/gLwxnors[*].e*]
create_pblock p_source7_RoLdceTrng
resize_pblock [get_pblocks p_source7_RoLdceTrng] -add SLICE_X68Y5:SLICE_X70Y7
set_property IS_SOFT 0 [get_pblocks p_source7_RoLdceTrng]
set_property CONTAIN_ROUTING TRUE [get_pblocks p_source7_RoLdceTrng]
add_cells_to_pblock [get_pblocks p_source7_RoLdceTrng] -cells [get_cells system_i/TrngTestbed_0/inst/eCore/eSandbox/eTrngs/gEntropySourceInstantiation[7].gRoLdceTrng.eRoLdceTrng/gRoLdces[*].e*]
