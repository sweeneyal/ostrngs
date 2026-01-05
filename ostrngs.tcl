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
            $ostrngs::home/hdl/rtl/Common/AxiCrossbar.vhd
            $ostrngs::home/hdl/rtl/Common/AxiUtility.vhd
            $ostrngs::home/hdl/rtl/Common/ClockManager.vhd
            $ostrngs::home/hdl/rtl/Common/ClockMux.vhd
            $ostrngs::home/hdl/rtl/Common/DualClockBram.vhd
            $ostrngs::home/hdl/rtl/Common/DualClockFifo.vhd
            $ostrngs::home/hdl/rtl/Common/UartRx.vhd
            $ostrngs::home/hdl/rtl/Common/UartTx.vhd
            $ostrngs::home/hdl/rtl/Core/TrngControllerCore.vhd
            $ostrngs::home/hdl/rtl/Core/TrngGenerator.vhd
            $ostrngs::home/hdl/rtl/Core/TrngSandbox.vhd
            $ostrngs::home/hdl/rtl/Core/TrngStorage.vhd
            $ostrngs::home/hdl/rtl/Core/TrngTestbedCore.vhd
            $ostrngs::home/hdl/rtl/EntropySources/DigitalNonlinearOscillator/DigitalNonlinearOscillator.vhd
            $ostrngs::home/hdl/rtl/EntropySources/DigitalNonlinearOscillator/DnoTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HECTOR/CosoTrng/CosoTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HECTOR/EroTrng/EroTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HybridFfsrTrng/DynamicSampler.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HybridFfsrTrng/EntropyInjector.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HybridFfsrTrng/FeedforwardShiftRegister.vhd
            $ostrngs::home/hdl/rtl/EntropySources/HybridFfsrTrng/HybridFfsrTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/Lwxnor.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/LwxnorLut.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/LwxnorLutTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/LwxnorTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/RoLdce.vhd
            $ostrngs::home/hdl/rtl/EntropySources/LwxnorTrng/RoLdceTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/MeshCoupledXor/CxUnit.vhd
            $ostrngs::home/hdl/rtl/EntropySources/MeshCoupledXor/MeshCoupledXor.vhd
            $ostrngs::home/hdl/rtl/EntropySources/OpenLoopMetaTrng/CoarseCascade.vhd
            $ostrngs::home/hdl/rtl/EntropySources/OpenLoopMetaTrng/OpenLoopMetaTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/StrTrng/StrTrng.vhd
            $ostrngs::home/hdl/rtl/EntropySources/StrTrng/MullerC.vhd
            $ostrngs::home/hdl/rtl/EntropySources/StrTrng/SelfTimedRing.vhd
            $ostrngs::home/hdl/rtl/EntropySources/XorRingTrng/XorRingTrng.vhd
            $ostrngs::home/hdl/rtl/TrngController.vhd
            $ostrngs::home/hdl/rtl/TrngTestbed.vhd
        "
        add_files $files

        foreach file $files {
            set_property library ostrngs [get_files [file tail $file]]
        }

        set_property file_type {VHDL 2008} [get_files AxiCrossbar.vhd]
        set_property file_type {VHDL 2008} [get_files TrngGenerator.vhd]
    }
}