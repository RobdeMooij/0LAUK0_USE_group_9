clear
close all
% laser_specs = [ 17      -11     -5      -pi/6   0;
%                 19      8       -5      pi/6    0;
%                 -40     -5.5    -5.5    pi      0];
% laser_specs = [ 50  50  50    rand()*2*pi    rand()*pi-pi/2;
%                 50  50  -50   rand()*2*pi    rand()*pi-pi/2;
%                 50  -50  50   rand()*2*pi    rand()*pi-pi/2;
%                 50  -50  -50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  50  50   rand()*2*pi    rand()*pi-pi/2;
%                 -50  50  -50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  -50  50  rand()*2*pi    rand()*pi-pi/2;
%                 -50  -50  -50 rand()*2*pi    rand()*pi-pi/2];
laser_specs = [0 0 0 rand()*2*pi rand()*pi-pi/2];
%make mesh_ object based on file and show it
iss.mesh = Mesh("C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss_2.json");
iss.mesh.show(150)

laser_draw_size = 50;
iss.lasers = Laser(iss.mesh.position+laser_specs(1,1:3),laser_specs(1,4),laser_specs(1,5));
iss.lasers(1).show(laser_draw_size)
for i = 2:size(laser_specs,1)
    iss.lasers = [iss.lasers Laser(iss.mesh.position+laser_specs(i,1:3),laser_specs(i,4),laser_specs(i,5))];
    iss.lasers(i).show(laser_draw_size)
end

pos = [0 5 iss.mesh.position(3)];
movement_speed = 0.05;
a = 0;
b = 0;
for i = 1:50
    ta = rand()*2*pi;
    tb = rand()*pi-pi/2;
    while true
        [az,el] = view;
        plot3(pos(1),pos(2),pos(3),'O','MarkerSize',10,'Color',[0 0 0],'MarkerFaceColor',[0 1 0])
        x = [-150 150];y = [pos(2) pos(2)];z = [pos(3) pos(3)];line(x,y,z);
        x = [pos(1) pos(1)];y = [-150 150];z = [pos(3) pos(3)];line(x,y,z);
        x = [pos(1) pos(1)];y = [pos(2) pos(2)];z = iss.mesh.position(3)+[-150 150];line(x,y,z);
        rotate3d on
        axis([iss.mesh.position(1) iss.mesh.position(1) iss.mesh.position(2) iss.mesh.position(2) iss.mesh.position(3) iss.mesh.position(3)]+[-1 1 -1 1 -1 1]*150)
        axis vis3d
        view(iss.lasers(1).azimuth*180/pi,0)
        xlabel('x [m]')
        ylabel('y [m]')
        zlabel('z [m]')
        grid on
        for k = 1:size(iss.lasers,2)
            iss.lasers(k).take_aim(pos);
            iss.lasers(k).show(laser_draw_size);     
        end
        da = ta-a;
        db = tb-b;
        if abs(da) <= movement_speed
            a = ta;            
        else 
            a = a+sign(ta-a)*movement_speed;
        end
        if abs(db) <= movement_speed
            b = tb;
        else
            b = b+sign(tb-b)*movement_speed;
        end
        pos = [0 0 iss.mesh.position(3)]+150*[cos(a)*cos(b) sin(a)*cos(b) sin(b)];
        drawnow        
        if a == ta && b == tb
            break
        end            
    end
end

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
