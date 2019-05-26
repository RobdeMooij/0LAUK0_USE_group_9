clear
close all

%make mesh_ object based on file and show it
iss = mesh_("C:\Users\s161012\Documents\Project Robots Everywhere\0LAUK0_USE_group_9-master\iss.json");
iss.show()

%hold to draw all triangles and define the colors for different ray hits {[miss],[solar panel],[body]}
hold on
colors = {[0 1 0],[1 0.75 0],[1 0 0]};

laser_pos = [0,17.25,-5];
laser = laser_(laser_pos);
plot3(laser.position(1),laser.position(2),laser.position(3),'O','Color','w','MarkerSize',8,'MarkerFaceColor','b');

%loop over number of debris particles
for i = 1:30
    %define random azimuth and elevation for debris
    azimuth = rand()*2*pi;
    elevation  = rand()*2*pi;
    
    %with a distance from the origin
    dist = 70;%+rand()*1000;
    position = [dist*cos(azimuth)*cos(elevation) dist*sin(azimuth)*cos(elevation) dist*sin(elevation)];
    debris = debris_(position,0.01,1000);
    
    %set hit and distance to represent a miss
    least_dist = inf;
    first_hit = 0;
    
    %loop over all triangles to change hit and distance to the earliest intersection
    for triangle = iss.triangles
        [hit,dist] = ray_hit_triangle(debris,triangle);
        if hit ~= 0
            if dist < least_dist 
                first_hit = hit;
                least_dist = dist;
                debris.velocity = least_dist;
            end
        end
    end
    
    %draw debris trajectory
    laser.take_aim(position,iss.triangles)
    laser_pos = laser.position;
    laser_dir = laser.direction;
    if laser.vision == 1
        line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
        %line([laser_pos(1) laser_pos(1)+laser.velocity*laser_dir(1)],[laser_pos(2) laser_pos(2)+laser.velocity*laser_dir(2)],[laser_pos(3) laser_pos(3)+laser.velocity*laser_dir(3)],'Color','b','LineWidth',1)
    else
        line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1,'Linestyle','--')
        %line([laser_pos(1) laser_pos(1)+laser.velocity*laser_dir(1)],[laser_pos(2) laser_pos(2)+laser.velocity*laser_dir(2)],[laser_pos(3) laser_pos(3)+laser.velocity*laser_dir(3)],'Color','k','LineWidth',1)
    end
    %line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
    
    %if the debris hits something, draw circle at impact location
    if first_hit > 0
        plot3(position(1)+debris.velocity*debris.direction(1),position(2)+debris.velocity*debris.direction(2),position(3)+debris.velocity*debris.direction(3),'O','Color',colors{first_hit+1},'MarkerSize',8,'MarkerFaceColor',colors{first_hit+1}) 
    end
    
end

% if first_hit > 0
%     plot3(laser_pos(1)+laser.velocity*laser_dir(1),laser_pos(2)+laser.velocity*laser_dir(2),laser_pos(3)+laser.velocity*laser_dir(3),'O','Color','k','MarkerSize',8,'MarkerFaceColor','k') 
% end

%set background color of the figure to white for better screenshots =)
set(gcf,'color','w');

