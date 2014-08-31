# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>
###############################################

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     6                          ;# number of mobilenodes
set val(rp)     DumbAgent                       ;# routing protocol
set val(x)      1000                      ;# X dimension of topography
set val(y)      1000                      ;# Y dimension of topography
set val(stop)   30                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
Mac/802_11 set PLCPDataRate_ 11e6  
Mac/802_11 set dataRate_ 11.0e6  
Mac/802_11 set basicRate_ 1.0e6 
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
set rng [new RNG]
$rng seed 0
set r1 [new RandomVariable/Uniform]  
$r1 use-rng $rng                              
$r1 set min_ 1.0                            
$r1 set max_ 10.0                          
set a [$r1 value]     
puts $a                          

#Create 2 Aps
set n0 [$ns node]
$n0 color "red"
$n0 set X_ 200
$n0 set Y_ 300
$n0 set Z_ 0.0
$ns at 0.01 "$n0 color red"
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 400
$n1 set Y_ 300
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20




#        Generate movement          
#===================================
#$ns at 20 " $n4 setdest 800 100 5 " 
#$ns at 150 " $n4 setdest 200 100 5 " 

#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null1 [new Agent/Null]
$ns attach-agent $n1 $null1
$ns connect $udp0 $null1


#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1500
$cbr0 set rate_ 11Mb
$cbr0 set random_ null
$ns at 0.5 "$cbr0 start"
$ns at 28.0 "$cbr0 stop"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    #exec nam out.nam &
    exit 0
}
#for {set i 0} {$i < $val(nn) } { incr i } {
#    $ns at $val(stop) "\$n$i reset"
#}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
