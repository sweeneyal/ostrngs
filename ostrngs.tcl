# Create the namespace
namespace eval ::ostrngs {
    # Export commands
    namespace export help import_sources

    set home [file tail [pwd]]
}

# Create a new stack
proc ::ostrngs::help {} {
    # Output an explanation of how this package works
}

proc ::ostrngs::import_sources args {
    array set options { -mode project }
    while {[llength $args]} {
        switch -glob -- [lindex $args 0] {
            -m*   {set args [lassign $args - options(-mode)]}
            -*    {error "unknown option [lindex $args 0]"}
            default break
        }
    }
    puts "options: [array get options]"

    # If we're running in project mode:
    if { options(-mode) eq project } {
        import_files [
            $home/hdl/rtl/MeshCoupledXor/CxUnit.vhd
            $home/hdl/rtl/MeshCoupledXor/MeshCoupledXor.vhd

            $home/hdl/rtl/OpenLoopMetaTrng/CoarseCascade.vhd
            $home/hdl/rtl/OpenLoopMetaTrng/OpenLoopMetaTrng.vhd

            $home/hdl/rtl/StrTrng/MullerC.vhd
            $home/hdl/rtl/StrTrng/SelfTimedRing.vhd
            $home/hdl/rtl/StrTrng/StrTrng.vhd

            $home/hdl/rtl/TrngGenerator.vhd
            $home/hdl/rtl/TrngTestbed.vhd
        ]
    }
}