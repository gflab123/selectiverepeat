set ns [new Simulator]
set nf [open selective_repeat.nam w]

set f [open selective_repeat.tr w]


$ns namtrace-all $nf 
$ns trace-all $f

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam selective_repeat.nam &
	exit 0
}

for {set i 0} {$i<6} {incr i} {
	set n($i) [$ns node]
}

set color {"red" "green" "black"}

for {set i 0} {$i < 6} {incr i 2} {
	$n($i) color [lindex $color $i]
	$n([expr ($i+1)]) color [lindex $color $i]
}

for {set i 0} {$i < 6} {incr i} {
	$n($i) shape circle;
	$ns at 0.0 "$n($i) label SYS$i"
}


$ns duplex-link $n(0) $n(2) 1Mb 10ms DropTail
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns queue-limit $n(0) $n(2) 5
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link $n(2) $n(3) 1Mb 10ms DropTail
$ns duplex-link-op $n(2) $n(3) orient right
$ns duplex-link $n(3) $n(4) 1Mb 10ms DropTail
$ns duplex-link-op $n(3) $n(4) orient right-up
$ns duplex-link $n(3) $n(5) 1Mb 10ms DropTail
$ns duplex-link-op $n(3) $n(5) orient right-down

set tcp [new Agent/TCP]
$tcp set fid 1

$ns attach-agent $n(1) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n(4) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.05 "$ftp start"
$ns at 0.06 "$tcp set windowInit 8"
$ns at 0.06 "$tcp set maxcwnd 8"
$ns at 0.25 "$ns queue-limit $n(3) $n(4) 0"
$ns at 0.26 "$ns queue-limit $n(3) $n(4) 10"
$ns at 0.30 "$tcp set windowInit 1"
$ns at 0.30 "$tcp set maxcwnd 1"
$ns at 0.30 "$ns queue-limit $n(3) $n(4) 10"
$ns at 0.47 "$ns detach-agent $n(1) $tcp; $ns detach-agent $n(4) $sink"; 
$ns at 1.75 "finish"

$ns run
