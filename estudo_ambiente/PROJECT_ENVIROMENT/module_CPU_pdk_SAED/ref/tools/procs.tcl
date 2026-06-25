#
# Define some useful aliases and functions
#
set al(rq) "report_qor -summary"
set al(h) history
set al(ga) get_attribute
set al(sa) set_attribute
set al(gs) get_selection
set al(cs) change_selection
set al(csa) {change_selection -add}
set al(rt) {report_timing -cap -tran -sign 3}
set al(rtm) {report_timing -cap -tran -sign 3 -delay min}
set al(rc) {report_constraint -all_violators}
set al(rcd) {report_constraint -all_violators -max_delay}
set al(v) {view}
set al(vv) {view exec cat}


echo
echo "**********************************************************"
echo "Design Compiler NXT Workshop\nThe following aliases are available:"
foreach n [lsort [array names al]] {
	echo [format " %-30s%s" $n $al($n)]
	alias $n $al($n)
}

create_command_group {ces} -info "Design Compiler NXT workshop - useful procedures"

proc ces_help {} {
	echo "\n"
	echo "ces: Design Compiler Workshop - useful aliases"
	uplevel {
		foreach n [lsort [array names al]] {
			echo [format " %-30s%s" $n $al($n)]
			alias $n $al($n)
		}
	}
	echo "\n"
	help ces
}
define_proc_attributes ces_help \
	-info "print list of CES useful aliases and procedures" \
	-command_group ces \
	-define_args {}

proc measure_time {args} {
        set time [clock seconds]
        set command [join $args]
        echo "##### Started timer for command \"$command\""
        uplevel $args
        set stop_time [clock seconds]
        set hrs  [expr ($stop_time - $time) / 60 / 60]
        set mins [expr ($stop_time - $time) / 60 % 60]
        set secs [expr ($stop_time - $time) % 60]
        echo [format "####----#### Runtime: %3d:%02d:%02d  for command \"$command\"" $hrs $mins $secs]
}
define_proc_attributes measure_time \
        -info "Run a command while measuring the time it takes" \
        -command_group ces \
        -define_args {
                {script "Tcl-commands to time (and run)" args}
        }

proc gui {} {
        if {$::in_gui_session == false} {
                gui_start
        } else {
                gui_stop
                echo "... or just 'gui'"
        }
}
define_proc_attributes gui \
        -info "Start or stop the GUI" \
	-command_group ces

#
# Always Ask
# This useful procedure is on solvnet, Doc Id  012959
#
proc aa {args} {

        parse_proc_arguments -args $args results
        set pat $results(pattern)

        echo "******** Commands    ***********"
        
	redirect -variable treport "help *$pat*"
	if { ! [regexp "CMD-040" $treport]} { echo $treport }

        if {$::synopsys_program_name == "icc2_shell" || $::synopsys_program_name == "icc2_lm_shell" || $::synopsys_program_name == "fc_shell"} {
		echo "******** App Options ***********"
		redirect -variable treport "report_app_options *$pat*"
		set treport [split $treport "\n"] 
		set treport [lrange $treport 6 [expr [llength $treport] - 3]]
		set treport [join $treport "\n "]
		if {! [regexp "No options matched the specified pattern" $treport]} { echo " $treport" }
        }

	echo "******** Variables   ***********"
	redirect -variable treport "printvar *$pat*"
	if { ! [regexp "CMD-040" $treport]} { echo $treport }

        if {[info exists results(-verbose)]} {
                echo "******** apropos     ***********"
                redirect -variable treport "apropos *$pat*"
		if { ! [regexp "CMD-040" $treport]} { echo $treport }
        }
}; # end proc

define_proc_attributes aa \
	-info "always ask - Searches Synopsys help for both commands and application options/variables" \
	-command_group ces \
	-define_args {
		{pattern "Pattern to search for" pattern string required}
		{-verbose "Search -help as well" "" boolean optional}
	}

set VIEW_COMMAND "../ref/tools/view.tk"

# Get command results/reports in separate graphical tk window
# This expects view.tk to be in the path, which is the other half
# of this procedure!
# Examples: view man compile,  view report_timing -max_paths 20
#======================================================  
#Compatibility with VCS/DVE:
if {[info exists uclidir]} {
	set view_proc_name tview
} else {
	set view_proc_name view
}

proc $view_proc_name {args} {
	global VIEW_COMMAND

	if {$args == ""} {
		puts "Please provide a command."
		return
	}
	
	if { [catch {open "| $VIEW_COMMAND \"$args\"" w} PIPE] } {
		return "Can't open pipe for '$VIEW_COMMAND'"
	}
	redirect -channel $PIPE {uplevel $args}
	flush $PIPE
}
if {$view_proc_name == "view"} {
	define_proc_attributes $view_proc_name \
	-info "Display output of any command in a separate Tk window." \
	-command_group ces \
	-define_args { {args "Command with arguments" args} }
}


echo "**********************************************************"
help ces


