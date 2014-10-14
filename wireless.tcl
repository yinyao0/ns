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
set val(nn)     22                          ;# number of mobilenodes
set val(rp)     DumbAgent                       ;# routing protocol
set val(x)      700                      ;# X dimension of topography
set val(y)      700                      ;# Y dimension of topography
set val(stop)   30                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
Mac/802_11 set PLCPDataRate_ 11e6  
Mac/802_11 set dataRate_ 11.0e6  
Mac/802_11 set basicRate_ 1.0e6 
#Create a ns simulator
set ns [new Simulator]
#the transmit rate
set rate 2
set al 0
#the number of AP
set nAP 2
#the number of STA
set nSTA [expr $val(nn)-$nAP]
#the capacity
set CPA 5.5
set CPN [expr $CPA*$nAP]




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
#ap0's sta
set nsta0 12                        
for {set i 0} {$i < $nsta0} {incr i} {            
  $r1 set min_ 1.3
  $r1 set max_ 2.7   
  set x0($i) [$r1 value]     
  set x0($i) [expr $x0($i)*100]    
}                      
for {set i 0} {$i < $nsta0} {incr i} {
  $r1 set min_ 2.3
  $r1 set max_ 3.7
  set y0($i) [$r1 value]
  set y0($i) [expr $y0($i)*100]
}


#the node belong to overlapping area
set nstao 5
for {set i 0} {$i < $nstao} {incr i} {
   $r1 set min_ 3.0 
   $r1 set max_ 3.9
   set xo($i) [$r1 value]
   set xo($i) [expr $xo($i)*100]
}

for {set i 0} {$i < $nstao} {incr i} {
  $r1 set min_ 2.0
  $r1 set max_ 4.0
  set yo($i) [$r1 value]
  set yo($i) [expr $yo($i)*100]
}



#the node belong to ap1
set nsta1 3
for {set i 0} {$i < $nsta1} {incr i} {
   $r1 set min_ 5.0
   $r1 set max_ 6.4
   set x1($i) [$r1 value]
   set x1($i) [expr $x1($i)*100]
}

for {set i 0} {$i < $nsta1} {incr i} {
  $r1 set min_ 1.6
  $r1 set max_ 4.4
  set y1($i) [$r1 value]
  set y1($i) [expr $y1($i)*100]
}

#set al 1
##########################################################################
#addmission control and cell breath
puts "nAP:$nAP"
puts "nSTA:$nSTA"
puts "CPA:$CPA"
puts "CPN:$CPN"
#flag of breath
set flag 0
set nflow0 0
set nflowo0 0
set nflowo1 0
set nflow1 0
set acn0 $nsta0
set acno0 $nstao
set acno1 0
set acn1 $nsta1
#if {$al ==1} {
for {set i 0} {$i < $nsta0} {incr i} {
   set nflow0 [expr $nflow0+$rate]
   if {$nflow0 > $CPA} {
     set nflow0 [expr $nflow0-$rate]
     break;
   }
}
puts "nflow0:$nflow0"
if {$i < $nsta0} {
  set flag 1
  set acn0  $i
  set acno0 0
} else {
  set flag 0
  set acn0 $nsta0
  for {set i 0} {$i < $nstao} {incr i} {
     set nflowo0 [expr $nflowo0+$rate]
     if {[expr $nflowo0+$nflow0] > $CPA} {
       set nflowo0 [$nflowo0-$rate]
       break
     }
  }
  set acno0 $i
}
#al
#}
puts "flag:$flag"
puts "acn0:$acn0"
puts "acno0:$acno0"

set acno1 [expr $nstao-$acno0]
set acn1 $nsta1
puts "acno1:$acno1"
puts "acn1:$acn1"

###########################################################################


#Create 2 Aps
#200m
if {$al == 0} {
  Phy/WirelessPhy set Pt_ 0.115441
} else {
  Phy/WirelessPhy set Pt_ 0.00721505
}
set n(0) [$ns node]
$n(0) color "red"
$n(0) set X_ 200
$n(0) set Y_ 300
$n(0) set Z_ 0.0
$ns at 0.01 "$n(0) color red"

if {$al == 0} {
  Phy/WirelessPhy set Pt_ 0.115441
} else {
  Phy/WirelessPhy set Pt_ 0.281838
}
$ns initial_node_pos $n(0) 20
set n(1) [$ns node]
$n(1) color "red"
$n(1) set X_ 500
$n(1) set Y_ 300
$n(1) set Z_ 0.0
$ns at 0.01 "$n(1) color red"
$ns initial_node_pos $n(1) 20

#the node belong to ap0
for {set i 0} {$i < 12} {incr i} {
   set n0($i) [$ns node]
   $n0($i) set X_ $x0($i)
   $n0($i) set Y_ $y0($i)
   $n0($i) set Z_ 0.0
   $ns initial_node_pos $n0($i) 20
}

#the node belong to overlapping area
for {set i 0} {$i < 5} {incr i} {
   set no($i) [$ns node]
   $no($i) color "blue"
   $no($i) set X_ $xo($i)
   $no($i) set Y_ $yo($i)
   $no($i) set Z_ 0.0
   $ns at 0.01 "$no($i) color blue"
   $ns initial_node_pos $no($i) 20
}

#the node belong to ap1
for {set i 0} {$i < 3} {incr i} {
   set n1($i) [$ns node]
   $n1($i) set X_ $x1($i)
   $n1($i) set Y_ $y1($i)
   $n1($i) set Z_ 0.0
   $ns initial_node_pos $n1($i) 20
}





#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
#ap0
for {set i 0} {$i < $acn0} {incr i} {
  set udp0($i) [new Agent/UDP]
  $ns attach-agent $n(0) $udp0($i)
  set null0($i) [new Agent/Null]
  $ns attach-agent $n0($i) $null0($i)
  $ns connect $udp0($i) $null0($i)
}

#ap0
for {set i 0} {$i < $acno0} {incr i} {
  set udpo0($i) [new Agent/UDP]
  $ns attach-agent $n(0) $udpo0($i)
  set nullo0($i) [new Agent/Null]
  $ns attach-agent $no($i) $nullo0($i)
  $ns connect $udpo0($i) $nullo0($i)
}

#ap1
for {set i 0} {$i < $acno1} {incr i} {
  set udpo1($i) [new Agent/UDP]
  $ns attach-agent $n(1) $udpo1($i)
  set nullo1($i) [new Agent/Null]
  $ns attach-agent $no([expr $i+$acno0]) $nullo1($i)
  $ns connect $udpo1($i) $nullo1($i)
}

#ap1
for {set i 0} {$i < $acn1} {incr i} {
  set udp1($i) [new Agent/UDP]
  $ns attach-agent $n(1) $udp1($i)
  set null1($i) [new Agent/Null]
  $ns attach-agent $n1($i) $null1($i)
  $ns connect $udp1($i) $null1($i)
}

#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
for {set i 0} {$i < $acn0} {incr i} {
  set cbr0($i) [new Application/Traffic/CBR]
  $cbr0($i) attach-agent $udp0($i)
  $cbr0($i) set packetSize_ 1500
  $cbr0($i) set rate_ [expr $rate*1e6]
  $cbr0($i) set random_ null
  $ns at 0.1 "$cbr0($i) start"
  $ns at 30.0 "$cbr0($i) stop"
}

for {set i 0} {$i < $acno0} {incr i} {
  set cbro0($i) [new Application/Traffic/CBR]
  $cbro0($i) attach-agent $udpo0($i)
  $cbro0($i) set packetSize_ 1500
  $cbro0($i) set rate_ [expr $rate*1e6]
  $cbro0($i) set random_ null
  $ns at 0.1 "$cbro0($i) start"
  $ns at 30.0 "$cbro0($i) stop"
}

for {set i 0} {$i < $acno1} {incr i} {
  set cbro1($i) [new Application/Traffic/CBR]
  $cbro1($i) attach-agent $udpo1($i)
  $cbro1($i) set packetSize_ 1500
  $cbro1($i) set rate_ [expr $rate*1e6]
  $cbro1($i) set random_ null
  $ns at 0.1 "$cbro1($i) start"
  $ns at 30.0 "$cbro1($i) stop"
}


for {set i 0} {$i < $acn1} {incr i} {
  set cbr1($i) [new Application/Traffic/CBR]
  $cbr1($i) attach-agent $udp1($i)
  $cbr1($i) set packetSize_ 1500
  $cbr1($i) set rate_ [expr $rate*1e6]
  $cbr1($i) set random_ null
  $ns at 0.1 "$cbr1($i) start"
  $ns at 30.0 "$cbr1($i) stop"
}
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
