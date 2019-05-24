clear
close all

%make mesh_ object based on file and show it
iss = mesh_("C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss.json");
iss.show()

%hold to draw all triangles and define the colors for different ray hits {[miss],[solar panel],[body]}
hold on
colors = {[0 1 0],[1 0.75 0],[1 0 0]};

%loop over number of debris particles
for i = 1:30
    %define random azimuth and elevation for debris
    azimuth = rand()*2*pi;
    elevation  = rand()*2*pi;
    
    %with a distance from the origin
    dist = 70;%+rand()*1000;
    position = [dist*cos(azimuth)*cos(elevation) dist*sin(azimuth)*cos(elevation) dist*sin(elevation)];
    debris = debris_(position,0.01,1);
    
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
    line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors{first_hit+1},'LineWidth',1)
    
    %if the drbis hits something, draw circle at impact location
    if first_hit > 0
        plot3(position(1)+debris.velocity*debris.direction(1),position(2)+debris.velocity*debris.direction(2),position(3)+debris.velocity*debris.direction(3),'O','Color',colors{first_hit+1},'MarkerSize',8,'MarkerFaceColor',colors{first_hit+1}) 
    end
end

%set background color of the figure to white for better screenshots =)
set(gcf,'color','w');

