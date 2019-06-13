close all
colors = {[0 0 0],[0 1 0],[1 1 0],[1 0.7 0]};
figure('color','w','units','normalized','outerposition',[0 0 1 1])
all_velocities = data(:,5,:);
factor = 3/max(all_velocities(:));
for current_case = 1:size(data,3)
%     diameter_list   = data(:,1,current_case);
    azimuth_list    = data(:,2,current_case);
%     elevations_list = data(:,3,current_case);
    impact_list     = data(:,4,current_case);
    velocity_list   = data(:,5,current_case);
    subplot(2,2,current_case)
    axis equal
%     factor = 3/max(velocity_list);
    nr_steps = size(azimuth_list,1);
    for i = 1:nr_steps
        x = [sin(azimuth_list(i)/2)/2 sin(azimuth_list(i)/2)*((velocity_list(i) ~= 0)/2+velocity_list(i)*factor)];
        y = [cos(azimuth_list(i)/2)/2 cos(azimuth_list(i)/2)*((velocity_list(i) ~= 0)/2+velocity_list(i)*factor)];
        line(x,y,'Color',colors{impact_list(i)})
    end
    draw_circle(0.5,60)
    draw_circle(3.5,60)
end

function draw_circle(radius,nr_steps)
    angles = 0:pi/nr_steps:pi;
    x = cos(angles)*radius;
    y = sin(angles)*radius;
    line(x,y,'Color',[0 0 0])    
end
% close all
% clear
% mesh_dir = "C:\Users\s167917\Documents\#School\Jaar 3\4 Project USE Robots Everywhere\model\test.json";
% mesh     = Mesh(mesh_dir);
% axis_area = [mesh.position(1) mesh.position(1) mesh.position(2) mesh.position(2) mesh.position(3) mesh.position(3)]+[-1 1 -1.5 0.5 -1 1]*50;
% hold on
% mesh.show(axis_area,true)
% 
% position = mesh.position+[0 -10000 0];
% plot3(position(1),position(2),position(3),'O','Color','k','MarkerSize',6,'MarkerFaceColor',[1 1 0]);
% direction = [0 1 0];
% 
% min_dist = 99999;
% for triangle = mesh.triangles
%     [hit,dist] = ray_hit_triangle(position,direction,triangle);
%     if dist < min_dist
%         min_dist = dist;       
%     end
% end
% x = [position(1) position(1)+direction(1)*min_dist];
% y = [position(2) position(2)+direction(2)*min_dist];
% z = [position(3) position(3)+direction(3)*min_dist];
% line(x,y,z)


% rotation = [0 0 7.7e3/(6.371e6+400e3)];
%             ct = cos(rotation);
%             st = sin(rotation);
%             rotation_matrix = [ct(:,2).*ct(:,1)                             ct(:,2).*st(:,1)                             -st(:,2);
%                               st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1) st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1)  st(:,3).*ct(:,2);
%                               ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1) ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1)  ct(:,3).*ct(:,2)]
%                           
% asd
% 
% close all
% clear
% position = [0 0 1];
% 
% tic
% rotation = [0.3 -1.2 0.6];
% % rot_mat = [1 0 -angle;0 1 0;angle 0 1];
% 
% ct = cos(rotation);
% st = sin(rotation);
% rotationMatrix = [ct(:,2).*ct(:,1)                             ct(:,2).*st(:,1)                             -st(:,2);
%                   st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1) st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1)  st(:,3).*ct(:,2);
%                   ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1) ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1)  ct(:,3).*ct(:,2)];
% toc
% plot3(position(1),position(2),position(3),'O')
% hold on
% axis([-1 1 -1 1 -1 1]*1.5)
% for i = 1:60
% %     position = position*rot_mat;
%     position = position*rotationMatrix;
%     plot3(position(1),position(2),position(3),'O')
% end
% view(-135,30)
% rotate3d on
% % axis([this.position(1) this.position(1) this.position(2) this.position(2) this.position(3) this.position(3)]+[-1 1 -1 1 -1 1]*scale)
% axis vis3d
% xlabel('x [m]')
% ylabel('y [m]')
% zlabel('z [m]')
% grid on

% % for i = 1:50
%     disp("asd")
%     azimuth = rand()*2*pi
%     elevation = rand()*pi-pi/2;
%     vec = [sin(azimuth)*cos(elevation) cos(azimuth)*cos(elevation) sin(elevation)];
%     get_angles(vec);
% % end
% 
% 
% 
% function [azimuth,elevation] = get_angles(normalized_vector)
%     elevation = asin(normalized_vector(3));
%     azimuth = atan2(normalized_vector(2),normalized_vector(1));
% end

% dt = 10;
% t = 10000;
% steps = t/dt;
% R = 6.371e6;
% M = 5.972e24;
% m = 1.7;
% G = 6.674e-11;
% x_0 = [0 0 R+400e3];
% x = x_0;
% v = [7700 0 0];
% hold on
% 
% [x_earth,y_earth,z_earth] = sphere;
% x_earth = x_earth-1;
% y_earth = y_earth-1;
% z_earth = z_earth-1;
% a_earth = [1 1 1 1]*R;
% s1 = surf(x_earth*a_earth(1,4)+a_earth(1,1),y_earth*a_earth(1,4)+a_earth(1,2),z_earth*a_earth(1,4)+a_earth(1,3));
% % daspect([1 1 1])
% view(-135,30)
% rotate3d on
% iss = [x(1) x(1) x(2) x(2) x(3) x(3)]+[-1 1 -1 1 -1 1].*50e3;
% earth = [-1 1 -1 1 -1 1]*8e6;
% axis vis3d
% xlabel('x [m]')
% ylabel('y [m]')
% zlabel('z [m]')
% grid on
% azi = rand()*2*pi;
% ele = rand()*pi/3;
% deb = debris_(azi,ele,100e3,0.1,0.01);
% % disp(sqrt(deb.position(1)^2+deb.position(2)^2+(6.371e6+400e3-deb.position(3))^2))
% axis([-0.010    0.21   -0.11    0.11    6.6056 6.9356]*1e6);


% axis([-0.0899    0.2697   -0.1798    0.1798 6.5341    6.8937]*1e6)
% plot3(x(1),x(2),x(3),'O','Color','w','MarkerSize',10,'MarkerFaceColor','g')
% tic
% for i = 1:steps
%     r = sqrt(x(1)^2+x(2)^2+x(3)^2);
%     if r < R
%         disp("boom")
%         break
%     end
%     Fl = -2*[1 0 0];
%     Fg = -G*M*m*x/(r^3);
%     F = Fg+Fl;
%     a = F/m;
%     v = v+a.*dt;
%     prev_x = x;
%     x = x+v.*dt;
%     line([prev_x(1),x(1)],[prev_x(2),x(2)],[prev_x(3),x(3)],'LineWidth',1,'Color','k') 
% end
% toc
% r_0 = sqrt(x_0(1)^2+x_0(2)^2+x_0(3)^2); 
% r_1 = sqrt(x(1)^2+x(2)^2+x(3)^2); 
% disp(r_0)
% disp(r_1)
% disp(r_0-r_1)
% plot3(x(1),x(2),x(3),'O','Color','w','MarkerSize',10,'MarkerFaceColor','r')
% mn = (x_0+x)/2;
% val = max(abs(x_0-x))/2;
% impact = [mn(1) mn(1) mn(2) mn(2) mn(3) mn(3)]+[-1 1 -1 1 -1 1]*val*1.1;
% axis(impact)







% r1 = rand();
% r2 = rand()
% c1 = rand();
% c2 = c1*(1/sqrt(r1)-sqrt(2*r2/r1/(r2+r1)))
% 
% r2 = r1^2/(2/(1/sqrt(r1)-c2/c1)^2-r1)

% nr = 99999;
% figure
% tic
% for i = 1:nr
%    line([0 0],[1 0],[1 1]) 
% end
% toc
% close all
% figure
% tic
% for i = 1:nr
%     x = [0 0];
%     y = [1 0];
%     z = [1 1];
%     line(x,y,z)
% end
% toc

% nr = 1000;
% 
% R = 6.371e6;
% M = 5.972e24;
% G = 6.674e-11;
% 
% r = 0.05;
% E = 10*100e3;
% T_tel = 1;
% T_atm = 1;
% S = 4*pi*r^2;
% C_m = 2e-5;
% phi2_R = 1;
% m = 2700*4/3*pi*r^3;
% 
% c1 = G*M;
% c2 = E*T_tel*T_atm*S*C_m/pi/phi2_R;
% v = c2/m;
% disp(v)
% R1 = R+365000;
% for i = 1:nr
%     R1 = R1^2/(2/(1/sqrt(R1)-c2/nr/c1)^2-R1);
% end
% disp(R+365000-R1)
% 
% R1 = R+365000;
% R1 = R1 - R1^2/(2/(1/sqrt(R1)-c2/c1)^2-R1);
% disp(R1)

