Stage1 AUV planning
1.  "stage1_auv"               includes the below codes and save "auv_mobile_charger_yyyy-mm-dd_HHMMSS.mat"
-   "stage1_auv_planner"       is to run the GA
-   "stage1_auv_plot_path"     is to plot the AUV-USV path
2.  "stage1_auv_plot_battery " is to plot the AUV-USV batteru schedule and save "asv_travel.mat"

To run the record data: 
1. Read the previous data, press F9 in line 327 of "stage1_auv" 
   - load('auv_mobile_charger_2024-01-17_162755.mat');
2. Plot the AUV-USV path, press F9 in line 332 of "stage1_auv" 
   - [traj_segment,time_given_charger, traj_worker_nth] = stage1_auv_plot_path(a,userConfig.numTarChargers,userConfig,start_point,start_pCharger,G,start_node_th,points_to_remove);
3. Run "stage1_auv_plot_battery " is to plot the AUV-USV batteru schedule 

----------------------------------------------------

Stage2 UAV planning, UAV battery life is 0.4 hour
1.  "stage2_uav"               includes the below codes and save "uav_time_sequence_charging_yyyy-mm-dd_HHMMSS.mat"
-   "stage2_uav_planner"       is to run the GA
-   "stage2_uav_plot_path"     is to plot the UAV-USV path 
2.  "stage2_uav_plot_battery " is to plot the UAV-USV battery schedule


To run the record data: 
1. Read the previous data, press F9 in line 229~230 of "stage2_uav"
-  load('uav_time_sequence_charging_2024-01-20_051116');
-  load('asv_travel.mat');
2. Plot the UAV-USV path, press F9 in line 236 of "stage2_uav"
-  [traj_segment] = stage2_uav_plot_path(a,userConfig.numTarChargers,userConfig,start_point,start_pCharger, asv_xy);
3. Run "stage2_uav_plot_battery " is to plot the UAV-USV battery schedule
