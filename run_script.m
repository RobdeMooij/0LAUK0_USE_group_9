clear
close all
all_time = tic;
% inputs % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
mesh_dir  = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss_2.json";
video_dir = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\videos\";
laser_specs = {
    %case 1:    no lasers
%     [];
    
    %case 2:    1 front
    [16.9017    4.1645     -4.920       0      pi/8]
    
    %case 3:    2 front
    [15.5666    -9.05011   -5.256      -pi/8   pi/8;
     18.2369    17.3792    -4.583       pi/8   pi/8]
    
    %case 4:    3 front
    [15.5666    -9.05011   -5.256      -pi/8   pi/8;     
     16.9017    4.1645     -4.920       0      pi/8;
     18.2369    17.3792    -4.583       pi/8   pi/8]
    
    %
    };

azimuth_steps   = 3;
elevation_steps = 5;
diameter_steps  = 3;

% show_update     = false;
show_update     = true;
% save_video      = false;
save_video      = true;
update_steps    = 10;
dt              = 0.01;
detailed_factor = 0.2;

distance        = 100e3;
threshold_dist  = 500;
system.power    = 150e3;

azimuth_min     = -pi/4;
azimuth_max     = pi/4;
elevation_min   = 0;
elevation_max   = pi/4;
diameter_min    = 0.01;
diameter_max    = 0.10; 

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
debris_offset   = [rand()-0.5 rand()-0.5 rand()-0.5]*0;
system.mesh     = Mesh(mesh_dir);
colors          = {[0 0 0],[0 1 0],[1 1 0],[1 0.5 0]};
azimuth_step    = (azimuth_max-azimuth_min)/(azimuth_steps-1);
elevation_step  = (elevation_max-elevation_min)/(elevation_steps-1);
diameter_step   = (diameter_max-diameter_min)/(diameter_steps-1);
nr_debris       = azimuth_steps*elevation_steps*diameter_steps;
nr_cases        = size(laser_specs,1);
print_string    = strings(4,nr_cases);
data            = zeros(nr_debris,6,nr_cases);
diameter_list   = diameter_min:diameter_step:diameter_max;
azimuth_list    = azimuth_min:azimuth_step:azimuth_max;
elevation_list  = elevation_min:elevation_step:elevation_max;
if show_update
    if save_video
        figure_outer_pos = [0 0.12 0.5 0.9];%[0 0 0.5625 1];
    else
        figure_outer_pos = [0 0.12 0.5 0.9];
    end
    figure('color','w','units','normalized','outerposition',figure_outer_pos)
    hold on    
else
    save_video = false;
end

for current_case = 1:nr_cases
    case_start = tic;
    system.lasers = init_lasers(laser_specs{current_case},system.mesh.position);
    class_hit = [0 0 0 0];
    percentage = 0;
%     diameter_list  = [0.1 0.05 0.01];
%     azimuth_list   = [-pi/4 -pi/8 0 pi/8 pi/4];  
%     elevation_list = [0 pi/8 pi/4];
    for diameter = diameter_list
        for azimuth = azimuth_list
            for elevation = elevation_list
%                 diameter = 0.01+rand()*0.09;
%                 azimuth = rand()*2*pi-pi;
%                 elevation = rand()*pi/4;
                if save_video
                    write_dir = char(strcat(video_dir,sprintf('case=%1d_d=%0.2f_a=%0.3f_e=%0.3f_%05d.avi',current_case,diameter,azimuth,elevation,round(0))));%rand()*99999))));
                    new_video = VideoWriter(write_dir);
                    new_video.FrameRate = 1/update_steps/dt;
                    open(new_video);
                end
                reset_lasers(system,laser_specs{current_case})
                system.debris = Debris(azimuth,elevation,distance,diameter,debris_offset,dt);
                if show_update
                    axis_area = get_axis_area(system);
                    axis(axis_area)
                    view(30,36) %azimuth/pi*180+
                    scale = axis_area(2)-axis_area(1);
                end
                detailed = false;
                while system.debris.steps > 0
                    if detailed == false
                        detailed = steps(system,update_steps,threshold_dist,dt);
                        if show_update   
                            show_all_big(system,axis_area,scale,colors{system.debris.impact+1})
                        end
                    else
                        threshold_step(system,dt*detailed_factor)
%                         system.debris.steps = round(system.debris.steps*detailed_factor);
%                         disp(threshold_dist*system.debris.velocity/dt)
%                         disp(system.debris.steps)
                        if show_update
                            show_all_small(system,colors{system.debris.impact+1})
                        end
                    end                    
                    if save_video
                       frame = getframe(gcf);
                       writeVideo(new_video,frame);  
                    end                    
                end
                class_hit(system.debris.impact+1) = class_hit(system.debris.impact+1)+1;
                percentage = percentage+100/nr_debris;
                clc
                fprintf('case %0d: %0.2f%%',current_case,percentage)
                
                if system.debris.impact ~= 0
                    impact_velocity = system.debris.direction*system.debris.velocity;
                    impact_velocity = sqrt((impact_velocity(1)-7.7e3)^2+impact_velocity(2)^2+impact_velocity(3)^2);
                else
                    impact_velocity = 0;
                end
                data(round(percentage/100*nr_debris),:,current_case) = [current_case diameter azimuth elevation system.debris.impact impact_velocity];
                if save_video
                    for extra_frames = 1:72
                        [az,el] = view;
                        view(az+15,el-1)
                        frame = getframe(gcf);
                        writeVideo(new_video,frame);  
                    end
                    close(new_video)
                end                
            end
        end
    end
    case_end = toc(case_start);
    print_string(1,current_case) = sprintf('#case %0d',current_case);
    print_string(2,current_case) = sprintf('miss: %0.0f, green: %0.0f, yellow: %0.0f, orange: %0.0f',class_hit(1),class_hit(2),class_hit(3),class_hit(4));
    print_string(3,current_case) = sprintf('elapsed time: %0.4f sec (%0.2f debris/sec)',case_end,nr_debris/case_end);
end
clc
fprintf('total number of debris: %0.0f\n\n',nr_debris)
for str = print_string
    disp(char(str))
end
fprintf('total time elapsed: %0.0fs\n',toc(all_time))

function threshold_reached = steps(system,nr_steps,threshold_dist,dt)
    threshold_reached = false;
    for i = 1:nr_steps
        Fl = [0 0 0];
        nr_vision_lasers = 0;
        for j = 1:size(system.lasers,2)
            system.lasers(j).take_aim(system.debris.position,dt);            
            if system.lasers(j).vision == true
                nr_vision_lasers = nr_vision_lasers+1;
            end
        end
        for j = 1:size(system.lasers,2)            
            if system.lasers(j).vision == true
                Fl = Fl+get_force(min(100e3,system.power/nr_vision_lasers),system.lasers(j).direction,system.debris.diameter);
            end
        end
        system.debris.step_rough(Fl,dt)
        step_threshold = threshold_dist/system.debris.velocity/dt;
        if system.debris.steps <= step_threshold
            threshold_reached = true;
            return
        end
    end
    if system.debris.steps > 0
        system.debris.check_impact(system.mesh,dt)
    end
end

function threshold_step(system,dt)
    Fl = [0 0 0];
    nr_vision_lasers = 0;
    for j = 1:size(system.lasers,2)
        system.lasers(j).take_aim(system.debris.position,dt);            
        if system.lasers(j).vision == true
            nr_vision_lasers = nr_vision_lasers+1;
        end
    end
    for j = 1:size(system.lasers,2)            
        if system.lasers(j).vision == true
            Fl = Fl+get_force(system.power/nr_vision_lasers,system.lasers(j).direction,system.debris.diameter);
        end
    end
    system.debris.step(Fl,dt)    
    if system.debris.steps > 0
        system.debris.check_impact(system.mesh,dt)
    end
    system.debris.steps = system.debris.steps-1;
end

function force_vec = get_force(power,direction,d)   
%     a       = 0.85;
%     M2      = 1;
%     lambda  = 0.35e-6;
%     L       = 100e3;
%     D       = 1.5;
%     b       = a*M2*lambda*L/D;
    Ep      = 10;
    b       = 0.02;
    Cm      = 1e-4;
    Ed      = Ep*min(1,(d/b)^2);    
    R       = power/Ep;
    F       = Cm*Ed*R;
%     fprintf('R:%0.0f F:%0.2f\n',R,F)
    force_vec = direction*F;
end

function show_all_big(system,axis_area,scale,c)
    cla            
    system.mesh.show(axis_area,false)
    for i = 1:size(system.lasers,2)
        system.lasers(i).show(scale/10)
    end
    system.debris.show_vel(scale/8)    
    draw_lines(system.debris.position,1e10,1.5,c)
    drawnow
end

function show_all_small(system,c)
    cla    
    new_axis_area = get_axis_area(system);
    system.mesh.show(new_axis_area,true)
    for i = 1:size(system.lasers,2)
        system.lasers(i).show(50)
    end
    system.debris.show_net()
    draw_lines(system.debris.position,1e10,1,c)
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
    x = [position(1) scale];y = [position(2) position(2)];z = [position(3) position(3)];line(x,y,z,'Color',c,'LineWidth',linewidth);
    x = [position(1) position(1)];y = [-scale scale];z = [position(3) position(3)];line(x,y,z,'Color',c,'LineWidth',linewidth);
    x = [position(1) position(1)];y = [position(2) position(2)];z = [-scale scale];line(x,y,z,'Color',c,'LineWidth',linewidth);      
end

function lasers = init_lasers(laser_specs,origin)
    if size(laser_specs,1) > 0
        lasers = Laser(origin+laser_specs(1,1:3),laser_specs(1,4),laser_specs(1,5));
        for i = 2:size(laser_specs,1)
            lasers = [lasers Laser(origin+laser_specs(i,1:3),laser_specs(i,4),laser_specs(i,5))];
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