#!/usr/bin/env python

def process(line,package):
    etime=float(line.split()[1])
    layer=line.split()[3]
    action=line.split()[0]
    pack_size=int(line.split()[7])
  
    if layer=="MAC" and pack_size >= 500:
       package.append(pack_size) 
    return etime

stime=0.5
package=[]
f=open("out.tr")
for line in f:
    etime=process(line,package)
f.close()
total=0
for p in package:
    total=total+p
print total
throughput=total/(etime-stime)/1000
print "The throughput is %.2f kbps"%throughput
