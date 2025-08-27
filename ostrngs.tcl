# Create the namespace
namespace eval ::ostrngs {
    # Export commands
    namespace export help import_sources

    set home [pwd]
}

# Create a new stack
proc ::ostrngs::help {} {
    # Output an explanation of how this package works
}

proc optproc {name args script} {
    proc $name args [
        string map [list ARGS $args SCRIPT $script] {
            foreach var {ARGS} {
                set [lindex $var 0] [lindex $var 1]
            }

            foreach {var val} $args {
                set [string trim $var -] $val
            }

            SCRIPT
        }
    ]
}

optproc ::ostrngs::import_sources {{mode "project"}} {
    # If we're running in project mode:
    if { $mode eq "project" } {
        set files "
            $ostrngs::home/hdl/rtl/TrngSandbox.vhd
            $ostrngs::home/hdl/rtl/Common/AxiCrossbar.vhd
            $ostrngs::home/hdl/rtl/Common/DualClockFifo.vhd
            $ostrngs::home/hdl/rtl/Common/ClockMux.vhd
            $ostrngs::home/hdl/rtl/Common/AxiUtility.vhd
            $ostrngs::home/hdl/rtl/Common/DualClockBram.vhd
            $ostrngs::home/hdl/rtl/Common/ClockManager.vhd
            $ostrngs::home/hdl/rtl/OpenLoopMetaTrng/CoarseCascade.vhd
            $ostrngs::home/hdl/rtl/OpenLoopMetaTrng/OpenLoopMetaTrng.vhd
            $ostrngs::home/hdl/rtl/TrngTestbedCore.vhd
            $ostrngs::home/hdl/rtl/StrTrng/StrTrng.vhd
            $ostrngs::home/hdl/rtl/StrTrng/MullerC.vhd
            $ostrngs::home/hdl/rtl/StrTrng/SelfTimedRing.vhd
            $ostrngs::home/hdl/rtl/TrngTestbed.vhd
            $ostrngs::home/hdl/rtl/TrngGenerator.vhd
            $ostrngs::home/hdl/rtl/TrngStorage.vhd
            $ostrngs::home/hdl/rtl/MeshCoupledXor/CxUnit.vhd
            $ostrngs::home/hdl/rtl/MeshCoupledXor/MeshCoupledXor.vhd
        "
        import_files $files

        foreach file $files {
            set_property library ostrngs [get_files [file tail $file]]
        }
    }
}