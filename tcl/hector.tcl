# Create the namespace
namespace eval ::hector {
    # Export commands
    namespace export help import_sources

    set home [pwd]
}

# Create a new stack
proc ::hector::help {} {
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

optproc ::hector::import_sources {{mode "project"}} {
    # If we're running in project mode:
    if { $mode eq "project" } {
        set files "
            $ostrngs::home/libraries/COSO-TRNG/VHDL/shared/RO_core.vhd
        "
        add_files $files

        foreach file $files {
            set_property library hector_trng_designs [get_files [file tail $file]]
        }
    }
}