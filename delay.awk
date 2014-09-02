BEGIN { 
     highest_packet_id = 0; 
     i=0; 
}  
{ 
   action = $1; 
   time = $2; 
   packet_id = $6; 
   type = $7; 
    
   if ( type == "cbr" ) { 
    
		   if ( packet_id > highest_packet_id ) 
			 highest_packet_id = packet_id; 
		  
		   if ( start_time[packet_id] == 0 )   
			start_time[packet_id] = time; 
		  
		   if (  action != "d" ) { 
		      if ( action == "r" ) { 
			 end_time[packet_id] = time; 
		      } 
		   } else { 
		      end_time[packet_id] = -1; 
		   } 
	}	 
}						   
END { 
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) { 
       start = start_time[packet_id]; 
       end = end_time[packet_id]; 
       packet_duration = end - start; 
  
       if ( start < end ){ 
        delaysum += packet_duration; 
       	i++; 
          
  	}    
 }  
ratio=delaysum/i;  
    printf(" %f\n", ratio);
   } 

