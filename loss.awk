BEGIN{
fsDrops=0;
numfs_sum=0;
numfs=0;
}
{
	action = $1;
	time =$2;
	node = $3;
	trace_type=$4;
	pkt_type=$7;

#缁熻鍙戝寘鎬绘暟
	if(action=="s" && trace_type=="AGT" && pkt_type=="cbr")
		numfs_sum ++;

#缁熻鎺ュ寘鎬绘暟
	if(action=="r" && trace_type=="AGT" && pkt_type=="cbr")
		numfs ++;
}
END{
#printf("send:%d  recive:%d\n",numfs_sum,numfs);
d_rate=0;
r_rate=0;
fsDrops=numfs_sum-numfs;
d_rate=fsDrops/numfs_sum;
r_rate=numfs/numfs_sum;
#printf("lost_rate:%f  recieve_rate:%f\n",d_rate,r_rate);
printf("lost_rate:%3f\n",d_rate);

}

