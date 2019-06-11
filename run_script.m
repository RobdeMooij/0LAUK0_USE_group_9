clear
close all
mesh_dir = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss_2.json";
laser_specs = {
    %case 1:    no lasers
%     [];

    %case 2:    2 front, 1 back
    [15.5666 -9.05011   -5.256      -pi/8   pi/8;
     18.2369 17.3792    -4.583       pi/8   pi/8;
    -40.028 0           -5.437       pi     pi/8]
    
    %
    };

azimuth_steps   = 20;
elevation_steps = 5;
diameter_steps  = 10;

update_steps    = 25;
dt              = 0.01;

scale           = 100e3;
distance        = 100e3;
offset          = [50e3 0 0];

azimuth_min     = -pi;
azimuth_max     = pi;
elevation_min   = 0;
elevation_max   = pi/4;
diameter_min    = 0.01;
diameter_max    = 0.10; 



%save:  case   diameter   azimuth   elevation   impact   velocity
azimuth_step    = (azimuth_max-azimuth_min)/(azimuth_steps-1);
elevation_step  = (elevation_max-elevation_min)/(elevation_steps-1);
diameter_step   = (diameter_max-diameter_min)/(diameter_steps-1);
system.mesh     = Mesh(mesh_dir);
colors          = {[0 1 1],[0 1 0],[1 0.5 0],[1 0 0]};
nr_debris       = azimuth_steps*elevation_steps*diameter_steps;
nr_cases        = size(laser_specs,1);
print_string    = strings(4,nr_cases);
data            = zeros(nr_debris,6,nr_cases);
figure('units','normalized','outerposition',[0 0.12 0.5 0.9],'color','w')
view(-30,30)
hold on
for current_case = 1:nr_cases
    system.lasers = init_lasers(laser_specs{current_case},system.mesh.position);
    class_hit = [0 0 0 0];
    tic
    percentage = 0;
    for diameter = diameter_min:diameter_step:diameter_max        
        for azimuth = azimuth_min:azimuth_step:azimuth_max
            for elevation = elevation_min:elevation_step:elevation_max
                diameter = 0.01+rand()*0.09;
                azimuth = rand()*2*pi-pi;
                elevation = rand()*pi/4;
                reset_lasers(system,laser_specs{current_case})
                system.debris = Debris(azimuth,elevation,distance,diameter,dt);
                while system.debris.steps > 0
                    steps(system,update_steps,dt)
                    show_all(system,scale,offset,colors)            
                end
                class_hit(system.debris.impact+1) = class_hit(system.debris.impact+1)+1;
                percentage = percentage+100/nr_debris;
                clc
                fprintf('case %0.0f: %0.1f%%',current_case,percentage)
                
                impact_velocity = system.debris.direction*system.debris.velocity;
                impact_velocity = sqrt((impact_velocity(1)-7.7e3)^2+impact_velocity(2)^2+impact_velocity(3)^2);
                data(round(percentage/100*nr_debris),:,current_case) = [current_case diameter azimuth elevation system.debris.impact impact_velocity];                
            end
        end
    end
    time_elapsed = toc;
    print_string(1,current_case) = sprintf('#case %0.0f',current_case);
    print_string(2,current_case) = sprintf('miss: %0.0f, green: %0.0f, orange: %0.0f, red: %0.0f',class_hit(1),class_hit(2),class_hit(3),class_hit(4));
    print_string(3,current_case) = sprintf('elapsed time: %0.4f sec (%0.2f debris/sec)',time_elapsed,nr_debris/time_elapsed);
end
clc
fprintf('total number of debris: %0.0f\n\n',nr_debris)
for str = print_string
    disp(char(str))
end

function steps(system,nr_steps,dt)
    for i = 1:nr_steps
        Fl = [0 0 0];
        for j = 1:size(system.lasers,2)
            system.lasers(j).take_aim(system.debris.position,dt);
            if system.lasers(j).vision == true
                Fl = Fl+get_force(system.lasers(j),system.debris.diameter);
            end
        end
        system.debris.step(Fl,dt)
        system.debris.steps = system.debris.steps-1;
        if system.debris.steps <= 0
            break
        end
    end
    system.debris.check_impact(system.mesh,dt)
end

function force_vec = get_force(laser,d)   
%     b = a*M^2*lambda*L/D;
    b = 0.02;
    Ep = 10;
    Ed = Ep*min(1,(d/b)^2);
    Cm = 1e-4;
    R = 1e4;
    F = Cm*Ed*R;
    force_vec = laser.direction*F;
%     fprintf('F: %0.2f\n',F)
end

function show_all(system,scale,offset,colors)
    cla
%     hold on
    system.mesh.show(scale,offset)
    for i = 1:size(system.lasers,2)
    	system.lasers(i).show(scale/6)
    end
    c = colors{system.debris.impact+1};
    system.debris.show(scale/4,c)    
    draw_lines(system.debris.position,scale*99,c)
%     hold off
    drawnow
end

function draw_lines(position,scale,c)
    linewidth = 0.5;
    x = [-scale scale];y = [position(2) position(2)];z = [position(3) position(3)];line(x,y,z,'Color',c,'LineWidth',linewidth);
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






% 
% pos = [0 1 iss.mesh.position(3)];
% movement_speed = 0.05;
% a = 0;
% b = 0;
% for i = 1:20
%     ta = rand()*2*pi;
%     tb = rand()*pi-pi/2;
%     while true
%         [az,el] = view;
%         plot3(pos(1),pos(2),pos(3),'O','MarkerSize',10,'Color',[0 0 0],'MarkerFaceColor',[0 1 0])
%         x = [-150 150];y = [pos(2) pos(2)];z = [pos(3) pos(3)];line(x,y,z);
%         x = [pos(1) pos(1)];y = [-150 150];z = [pos(3) pos(3)];line(x,y,z);
%         x = [pos(1) pos(1)];y = [pos(2) pos(2)];z = iss.mesh.position(3)+[-150 150];line(x,y,z);
%         rotate3d on
%         axis([iss.mesh.position(1) iss.mesh.position(1) iss.mesh.position(2) iss.mesh.position(2) iss.mesh.position(3) iss.mesh.position(3)]+[-1 1 -1 1 -1 1]*150)
%         axis vis3d
%         view(az,el)
%         xlabel('x [m]')
%         ylabel('y [m]')
%         zlabel('z [m]')
%         grid on
%         for k = 1:size(iss.lasers,2)
%             iss.lasers(k).take_aim(pos);
%             iss.lasers(k).show(laser_draw_size);     
%         end
%         da = ta-a;
%         db = tb-b;
%         if abs(da) <= movement_speed
%             a = ta;            
%         else 
%             a = a+sign(ta-a)*movement_speed;
%         end
%         if abs(db) <= movement_speed
%             b = tb;
%         else
%             b = b+sign(tb-b)*movement_speed;
%         end
%         pos = [0 0 iss.mesh.position(3)]+150*[cos(a)*cos(b) sin(a)*cos(b) sin(b)];
%         drawnow        
%         if a == ta && b == tb
%             break
%         end            
%     end
% end
% 



% pos = iss.mesh.position+[18 -11 99995];
% % pos = iss.mesh.position+[0 0 -5];
% for i = 1:15
%     plot3(0,0,0)
%     iss.mesh.show(70)
%     iss.lasers(1).take_aim(pos)
%     iss.lasers(1).show(laser_draw_size);
%     drawnow
% end


% %hold to draw all triangles and define the colors for different ray hits {[miss],[solar panel],[body]}
% hold on
% colors = {[0 1 0],[1 0.75 0],[1 0 0]};
% 
% % laser_pos = [0,18,-5];
% % laser = laser_(laser_pos);
% 
% for i = 1:500
% % for azimuth = 0:pi/20:2*pi
% %     for elevation = -pi/2:pi/20:pi/2
%         azimuth = rand()*2*pi;
%         elevation = rand()*pi-pi/2;
%         debris = debris_(azimuth,elevation,100e3);
% %         debris.get_path(2)
%         debris.show()
% %     end
% end

%loop over number of debris particles
% for i = 1:10
%     %define random azimuth and elevation for debris
%     azimuth = rand()*2*pi;
%     elevation  = rand()*2*pi;
%     
%     %with a distance from the origin
%     dist = 70;%+rand()*1000;
%     position = [dist*cos(azimuth)*cos(elevation) dist*sin(azimuth)*cos(elevation) dist*sin(elevation)];
%     debris = debris_(position,0.01,1000);
%     
%     %set hit and distance to represent a miss
%     least_dist = inf;
%     first_hit = 0;
%     
%     %loop over all triangles to change hit and distance to the earliest intersection
%     for triangle = iss.triangles
%         [hit,dist] = ray_hit_triangle(debris,triangle);
%         if hit ~= 0
%             if dist < least_dist 
%                 first_hit = hit;
%                 least_dist = dist;
%                 debris.velocity = least_dist;
%             end
%         end
%     end
%     
%     %draw debris trajectory
%     laser.take_aim(position,iss.triangles)
%     laser_pos = laser.position;
%     laser_dir = laser.direction;
%     if laser.vision == 1
%         line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
%         %line([laser_pos(1) laser_pos(1)+laser.velocity*laser_dir(1)],[laser_pos(2) laser_pos(2)+laser.velocity*laser_dir(2)],[laser_pos(3) laser_pos(3)+laser.velocity*laser_dir(3)],'Color','b','LineWidth',1)
%     else
%         line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1,'Linestyle','--')
%         %line([laser_pos(1) laser_pos(1)+laser.velocity*laser_dir(1)],[laser_pos(2) laser_pos(2)+laser.velocity*laser_dir(2)],[laser_pos(3) laser_pos(3)+laser.velocity*laser_dir(3)],'Color','k','LineWidth',1)
%     end
%     %line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
%     
%     %if the debris hits something, draw circle at impact location
%     if first_hit > 0
%         plot3(position(1)+debris.velocity*debris.direction(1),position(2)+debris.velocity*debris.direction(2),position(3)+debris.velocity*debris.direction(3),'O','Color',colors{first_hit+1},'MarkerSize',8,'MarkerFaceColor',colors{first_hit+1}) 
%     end
%     
% end
% 
% % if first_hit > 0
% %     plot3(laser_pos(1)+laser.velocity*laser_dir(1),laser_pos(2)+laser.velocity*laser_dir(2),laser_pos(3)+laser.velocity*laser_dir(3),'O','Color','k','MarkerSize',8,'MarkerFaceColor','k') 
% % end
% 
% %set background color of the figure to white for better screenshots =)
% set(gcf,'color','w');

% clear
% close all
% 
% %make mesh_ object based on file and show it
% iss = mesh_("C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\test.json");
% iss.show()
% 
% %hold to draw all triangles and define the colors for different ray hits {[miss],[solar panel],[body]}
% hold on
% colors = {[0 1 0],[1 0.75 0],[1 0 0]};
% 
% %loop over number of debris particles
% for i = 1:10
%     %define random azimuth and elevation for debris
%     azimuth = pi;%rand()*2*pi;
%     elevation  = rand()*2*pi;
%     
%     %with a distance from the origin
%     dist = 5;%+rand()*1000;
% %     position = [dist*cos(azimuth)*cos(elevation) dist*sin(azimuth)*cos(elevation) dist*sin(elevation)];
%     position = [rand()*8-4 rand()*8-4 5];
%     debris = debris_(position,0.01,1);
%     
%     %set hit and distance to represent a miss
%     least_dist = inf;
%     first_hit = 0;
%     
%     %loop over all triangles to change hit and distance to the earliest intersection
%     for triangle = iss.triangles
%         [hit,dist] = ray_hit_triangle(debris,triangle);
%         if hit ~= 0
%             if dist < least_dist 
%                 first_hit = hit;
%                 least_dist = dist;
%                 debris.velocity = least_dist;
%             end
%         end
%     end
%     
%     %draw debris trajectory
%     line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
%     
%     %if the drbis hits something, draw circle at impact location
%     if first_hit > 0
%         plot3(position(1)+debris.velocity*debris.direction(1),position(2)+debris.velocity*debris.direction(2),position(3)+debris.velocity*debris.direction(3),'O','Color',colors{first_hit+1},'MarkerSize',8,'MarkerFaceColor',colors{first_hit+1}) 
%     end
% end
% 
% %set background color of the figure to white for better screenshots =)
% set(gcf,'color','w');
% 
