% https://nasa3d.arc.nasa.gov/detail/iss-6628
clear
close all
iss = mesh_("C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\iss.json");
iss.show()

hold on
colors = ['g','c','r'];
for i = 1:20
    angle_z  = rand()*2*pi;
    angle_xy = rand()*2*pi;
    dist = 70;%+rand()*1000;
    position = [dist*cos(angle_xy)*cos(angle_z) dist*sin(angle_xy)*cos(angle_z) dist*sin(angle_z)];
    debris = debris_(position,0.01,1);       
    least_dist = inf;
    first_hit = 0;
    for tri = iss.triangles
        [hit,dist] = debris.hit_triangle(tri);
        if hit ~= 0
            if dist < least_dist 
                first_hit = hit;
                least_dist = dist;
                debris.velocity = least_dist;
            end
        end
    end
    line([position(1) position(1)+debris.velocity*debris.direction(1)],[position(2) position(2)+debris.velocity*debris.direction(2)],[position(3) position(3)+debris.velocity*debris.direction(3)],'Color',colors(first_hit+1),'LineWidth',1)
    if first_hit > 0
        plot3(position(1)+debris.velocity*debris.direction(1),position(2)+debris.velocity*debris.direction(2),position(3)+debris.velocity*debris.direction(3),'O','Color',colors(first_hit+1),'MarkerSize',5,'MarkerFaceColor',colors(first_hit+1)) 
    end
end
set(gcf,'color','w');

