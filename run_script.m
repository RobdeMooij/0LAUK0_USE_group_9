clear
close all
all_time = tic;
% inputs % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
mesh_dir  = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss_2.json";
video_dir = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\videos\";
factor = 0.25;
laser_specs = {
    %case 1:    no lasers
    [];
    
    %case 2:    1 front
    [56.9017    4.1645     -4.920       0      pi/16    -pi*factor  pi*factor   -pi*factor  pi*factor]
    
    %case 3:    2 front
    [55.5666    -9.05011   -5.256      -pi/4   pi/16    -pi*factor  pi*factor   -pi*factor  pi*factor;
     58.2369    17.3792    -4.583       pi/4   pi/16    -pi*factor  pi*factor   -pi*factor  pi*factor]
    
    %case 4:    3 front
    [55.5666    -9.05011   -5.256      -pi/4   pi/16   -pi*factor  pi*factor   -pi*factor  pi*factor;     
     56.9017    4.1645     -4.920       0      pi/16   -pi*factor  pi*factor   -pi*factor  pi*factor;
     58.2369    17.3792    -4.583       pi/4   pi/16   -pi*factor  pi*factor   -pi*factor  pi*factor]
    
    %
    };

show_update      = false;
show_update      = true;
save_video       = true;
update_steps     = 10;
dt               = 0.01;
detailed_factor  = 0.05;

distance         = 100e3;
threshold_dist   = 500;
system.power     = 150e3;
system.max_power = 100e3;

%define range
azimuth_steps    = 100;
elevation_steps  = 1;
diameter_steps   = 1;
offset_steps     = 1;

azimuth_min      = -pi*1.0;
azimuth_max      = pi*1.0;
elevation_min    = 0;
elevation_max    = pi/4;
diameter_min     = 0.01;
diameter_max     = 0.10;
offset_y_min     = -50;
offset_y_max     = 50;
offset_z_min     = -50;
offset_z_max     = 50;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
if diameter_steps > 1
    diameter_step = (diameter_max-diameter_min)/(diameter_steps-1);
    diameter_list = diameter_min:diameter_step:diameter_max;
else
    diameter_list = (diameter_min+diameter_max)/2;
end
if azimuth_steps > 1
    azimuth_step = (azimuth_max-azimuth_min)/(azimuth_steps-1);
    azimuth_list = azimuth_min:azimuth_step:azimuth_max;
else
    azimuth_list = (azimuth_min+azimuth_max)/2;
end
if elevation_steps > 1
    elevation_step = (elevation_max-elevation_min)/(elevation_steps-1);
    elevation_list = elevation_min:elevation_step:elevation_max;
else
    elevation_list = (elevation_min+elevation_max)/2;
end
if offset_steps > 1
    offset_y_step = (offset_y_max-offset_y_min)/(offset_steps-1);
    offset_z_step = (offset_z_max-offset_z_min)/(offset_steps-1);
    offset_y_list  = offset_y_min:offset_y_step:offset_y_max;
    offset_z_list  = offset_z_min:offset_z_step:offset_z_max;
else
    offset_y_list  = (offset_y_min+offset_y_max)/2;
    offset_z_list  = (offset_y_min+offset_y_max)/2;
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%force lists
diameter_list  = [0.01 0.05 0.1];
azimuth_list   = [0];  
elevation_list = [0];
offset_y_list  = [0];
offset_z_list  = [-5];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

if show_update
    if save_video
        figure_outer_pos = [0 0 0.5625 1];
    else
        figure_outer_pos = [0 0.12 0.5 0.9];
    end
    figure('color','w','units','normalized','outerposition',figure_outer_pos)
    hold on
else
    save_video = false;
end

system.mesh    = Mesh(mesh_dir);
colors         = {[0 0 0],[0 1 0],[1 1 0],[1 0.5 0]};
nr_cases       = size(laser_specs,1);
nr_debris      = nr_cases*size(diameter_list,2)*size(azimuth_list,2)*size(elevation_list,2)*size(offset_y_list,2)*size(offset_z_list,2);
print_string   = strings(4,nr_cases);
data           = zeros(nr_debris,7,nr_cases);

clc
percentage = 0;
fprintf('%0.2f%% eta: ... seconds\n',0)
eta_timer = tic;
for offset_y = offset_y_list
    for offset_z = offset_z_list
        for current_case = 1:nr_cases
            case_start = tic;
            system.lasers = init_lasers(laser_specs{current_case},system.mesh.position);
            class_hit = [0 0 0 0];            
            for diameter = diameter_list
                for azimuth = azimuth_list
                    for elevation = elevation_list
%                         diameter  = 0.01+rand()*0.09;
%                         azimuth   = rand()*2*pi-pi;
%                         elevation = rand()*pi/4;
%                         offset_x  = (rand()-0.5)*100;
%                         offset_y  = (rand()-0.5)*100;
                        if save_video
                            write_dir = char(strcat(video_dir,sprintf('case=%1d_d=%0.2f_a=%0.3f_e=%0.3f_%05d.avi',current_case,diameter,azimuth,elevation,round(0))));%rand()*99999))));
                            new_video = VideoWriter(write_dir);
                            new_video.FrameRate = 1/update_steps/dt;
                            open(new_video);
                        end
                        reset_lasers(system,laser_specs{current_case})
                        debris_offset = [0 offset_y offset_z];
                        system.debris = Debris(azimuth,elevation,distance,diameter,debris_offset,dt);
                        if show_update
                            axis_area = get_axis_area(system);
                            axis(axis_area)
                            view(30,24) % azimuth/pi*180+
                            scale = axis_area(2)-axis_area(1);
                        end
                        next = 0;
                        impact = 1;
                        while true
                            if next == 0
                                next = steps(system,update_steps,threshold_dist,dt);
                                if show_update
                                    show_all_big(system,axis_area,scale,colors{impact})
                                end
                            elseif next == 1
                                temp_dt = dt*detailed_factor;
                                next = step(system,temp_dt);
                                [impact,extra_info] = get_end_impact(system,temp_dt);                        
                                if show_update
                                    show_all_small(system,extra_info,colors{impact})
                                end
                                if size(extra_info,2) == 3
                                    break
                                end
                            else
                                break
                            end                    
                            if save_video
                               frame = getframe(gcf);
                               writeVideo(new_video,frame);  
                            end                    
                        end
                        class_hit(impact) = class_hit(impact)+1;
                        percentage = percentage+100/nr_debris;
                        if save_video
                            if next ~= 2
                                for extra_frames = 1:72
                                    [az,el] = view;
                                    view(az+5,el-0.4)
                                    frame = getframe(gcf);
                                    writeVideo(new_video,frame);  
                                end
                            end
                            close(new_video)
                        end                
                        %rough eta, assumes every simulation takes the same time
                        eta = (100-percentage)/percentage*toc(eta_timer);
                        clc
                        fprintf('%0.2f%% eta: %0.1f seconds\n',percentage,eta)                
                        if impact ~= 1
                            impact_velocity = system.debris.direction*system.debris.velocity;
                            impact_velocity = sqrt((impact_velocity(1)-7.7e3)^2+impact_velocity(2)^2+impact_velocity(3)^2);
                        else
                            impact_velocity = 0;
                        end
                        data(round(percentage/100*nr_debris),:,current_case) = [diameter azimuth elevation impact impact_velocity debris_offset(1) debris_offset(3)];
                    end
                end
            end
            case_end = toc(case_start);
            print_string(1,current_case) = sprintf('#case %0d',current_case);
            print_string(2,current_case) = sprintf('miss: %0.0f, low risk: %0.0f, medium risk: %0.0f, high risk: %0.0f',class_hit(1),class_hit(2),class_hit(3),class_hit(4));
            print_string(3,current_case) = sprintf('elapsed time: %0.4f sec (%0.2f debris/sec)',case_end,nr_debris/case_end);
        end
    end
end
clc
fprintf('total number of debris: %0.0f\n\n',nr_debris)
for str = print_string
    disp(char(str))
end
fprintf('total time elapsed: %0.0f seconds\n',toc(all_time))

function [color_index_impact,extra_info] = get_end_impact(system,dt)    
    dist_to_iss = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
    vec_velocity = system.debris.direction*system.debris.velocity-[7.7e3 0 0];
    net_velocity = sqrt(vec_velocity(1)^2+vec_velocity(2)^2+vec_velocity(3)^2);
    net_direction = vec_velocity/net_velocity;
    
    if dist_to_iss <= net_velocity*dt+60
        [triangle_hit_type,min_dist] = hit_mesh(system.debris.position,net_direction,system.mesh.triangles);
        if min_dist <= net_velocity*dt
            color_index_impact = triangle_hit_type+1;
            extra_info = system.debris.position+net_direction*min_dist;
        else
            color_index_impact = 1;
            extra_info = [system.debris.position+net_direction*net_velocity*dt 0];
        end
    else
        color_index_impact = 1;
        extra_info = [system.debris.position+net_direction*net_velocity*dt 0];
    end
end

function [triangle_hit_type,min_dist] = hit_mesh(position,direction,triangles)
    min_dist = 1e10;
    triangle_hit_type = 0;
    for triangle = triangles
        [hit,dist] = ray_hit_triangle(position,direction,triangle);
        if dist < min_dist
            min_dist = dist;
            triangle_hit_type = hit;
        end
    end
end

function next = steps(system,nr_steps,threshold_dist,dt)
%     actual_steps = 0;
    next = 0;
    for i = 1:nr_steps
%         actual_steps = actual_steps+1;
        dist = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
        laser_force = get_laser_force(system,dt);
        system.debris.step(laser_force,dt)
        new_dist = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
        if new_dist <= threshold_dist
            next = 1;
            break
        end
        if dist < new_dist 
            next = 2;
            break
        end
    end
%     fprintf('%0d,%0d',nr_steps,actual_steps)    
end

function next = step(system,dt)
    dist = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
    laser_force = get_laser_force(system,dt);
    system.debris.step(laser_force,dt)
    new_dist = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
    if dist > new_dist 
        next = 1;
    else
        next = 3;
    end
end

function force_vec = get_laser_force(system,dt)
    force_vec = [0 0 0];
    nr_vision_lasers = 0;
    for i = 1:size(system.lasers,2)
        system.lasers(i).take_aim(system.debris.position,dt);            
        if system.lasers(i).vision == true
            nr_vision_lasers = nr_vision_lasers+1;
        end
    end
    for i = 1:size(system.lasers,2)            
        if system.lasers(i).vision == true
            power = min(system.max_power,system.power/nr_vision_lasers);
            force_mag = get_force(power,system.debris.diameter);
            force_vec = force_vec+system.lasers(i).direction*force_mag;
        end
    end
end

function force = get_force(power,d)   
%     a       = 0.85;
%     M2      = 1;
%     lambda  = 0.35e-6;
%     L       = 100e3;
%     D       = 1.5;
%     b       = a*M2*lambda*L/D;
    Ep    = 10;
    b     = 0.02;
    Cm    = 1e-4;
    Ed    = Ep*min(1,(d/b)^2);    
    R     = power/Ep;
    force = Cm*Ed*R;
%     fprintf('R:%0.0f F:%0.2f\n',R,F)

end

function show_all_big(system,axis_area,scale,c)
    cla            
    system.mesh.show(axis_area,false)
    for i = 1:size(system.lasers,2)
        system.lasers(i).show(scale/10)
    end
    draw_lines(system.debris.position,1e10,1,c)
    system.debris.show_vel(scale/8)
    drawnow
end

function show_all_small(system,extra_info,c)
    cla    
    new_axis_area = get_axis_area(system);
    system.mesh.show(new_axis_area,true)
    for i = 1:size(system.lasers,2)
        system.lasers(i).show(30)
    end
    draw_lines(system.debris.position,1e10,0.1,c)
    if size(extra_info,2) == 3
        system.debris.show_net(extra_info,true)
    else
        system.debris.show_net(extra_info(1:3),false)
    end    
    drawnow
end

function axis_area = get_axis_area(system)
    max_coordinates = max([system.mesh.position;system.debris.position]);
    min_coordinates = min([system.mesh.position;system.debris.position]);
    max_dist = max((max_coordinates-min_coordinates)/2);
    dist = max(1.1*max_dist,max_dist+50);
    means = (max_coordinates+min_coordinates)/2;
    axis_area = [means(1)-dist means(1)+dist means(2)-dist means(2)+dist means(3)-dist means(3)+dist];
end

function draw_lines(position,scale,linewidth,c)
%     x = [position(1) scale];y = [position(2) position(2)];z = [position(3) position(3)];line(x,y,z,'Color',c,'LineWidth',linewidth);
    x = [position(1) position(1)];y = [-scale scale];z = [position(3) position(3)];line(x,y,z,'Color',c,'LineWidth',linewidth);
    x = [position(1) position(1)];y = [position(2) position(2)];z = [-scale scale];line(x,y,z,'Color',c,'LineWidth',linewidth);      
end

function lasers = init_lasers(laser_specs,origin)
    if size(laser_specs,1) > 0
        lasers = Laser(origin+laser_specs(1,1:3),laser_specs(1,4),laser_specs(1,5),laser_specs(1,6:9));
        for i = 2:size(laser_specs,1)
            lasers = [lasers Laser(origin+laser_specs(i,1:3),laser_specs(i,4),laser_specs(i,5),laser_specs(1,6:9))];
        end
    else
        lasers = [];
    end
end

function reset_lasers(system,laser_specs)
    for i = 1:size(system.lasers,2)
        system.lasers(i).azimuth = laser_specs(i,4);
        system.lasers(i).elevation = laser_specs(i,5);
    end
end

% laser_specs = [ 50  50  50    rand()*2*pi    rand()*pi-pi/2;
%                 50  50  -50   rand()*2*pi    rand()*pi-pi/2;
%                 50  -50  50   rand()*2*pi    rand()*pi-pi/2;
%                 50  -50  -50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  50  50   rand()*2*pi    rand()*pi-pi/2;
%                 -50  50  -50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  -50  50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  -50  -50 rand()*2*pi    rand()*pi-pi/2];
% laser_specs = [0 0 0 rand()*2*pi rand()*pi-pi/2];

%SLOOOOOOOOOOOOOOOOOOOOOOOOOOOW
% function [color_index_impact,extra_info] = get_impact(system,dt)
%     nr_steps = 0;
%     original_position  = system.debris.position;
%     original_direction = system.debris.direction;
%     original_velocity  = system.debris.velocity;
%     step_next = false;
%     while true
%         nr_steps = nr_steps+1;
%         dist_to_iss = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
%         if dist_to_iss <= system.debris.velocity*dt+60 && step_next == false
%             net_direction = system.debris.direction*system.debris.velocity-[7.7e3 0 0];
%             net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
%             [triangle_hit_type,min_dist] = hit_mesh(system.debris.position,net_direction,system.mesh.triangles);
%             if min_dist <= system.debris.velocity*dt
%                 color_index_impact = triangle_hit_type+1;
%                 extra_info = system.debris.position+net_direction*min_dist;
%                 break
%             else
%                 step_next = true;
%             end
%         else
%             system.debris.step(0,dt)
%             new_dist_to_iss = sqrt((system.debris.position(1)-system.mesh.position(1))^2+(system.debris.position(2)-system.mesh.position(2))^2+(system.debris.position(3)-system.mesh.position(3))^2);
%             if new_dist_to_iss >= dist_to_iss
%                 color_index_impact = 1;
%                 net_direction = system.debris.direction*system.debris.velocity-[7.7e3 0 0];
%                 net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
%                 extra_info = [system.debris.position+net_direction*system.debris.velocity*dt 0];
%                 break
%             end
%             step_next = false;
%         end
%     end
%     system.debris.position  = original_position;
%     system.debris.direction = original_direction;
%     system.debris.velocity  = original_velocity;
%     disp(nr_steps)
% end