% dr = 100;
% R_E = 6.37e6;
% rho = 2700;
% m = 0.1^3*4/3*pi*2700;
% C_m = 1e-5;
% lambda = 0.35e-6;
% D = 1.5;
% d = 100e3;
% Q = sqrt(2);
% v = 10e3;
% 
% E_l = (rho^2*m)^(1/3)/(pi*C_m)*lambda^2*Q^4/(D^2)*d^2*v*dr/R_E
close all
clear

dt = 1;
steps = 10000;
R = 6.371e6;
M = 5.972e24;
m = 0.07;
G = 6.674e-11;
x_0 = [0 0 R+400e3];
x = x_0;
v = [7700 0 0];
hold on

[x_earth,y_earth,z_earth] = sphere;
x_earth = x_earth-1;
y_earth = y_earth-1;
z_earth = z_earth-1;
a_earth = [1 1 1 1]*R;
s1 = surf(x_earth*a_earth(1,4)+a_earth(1,1),y_earth*a_earth(1,4)+a_earth(1,2),z_earth*a_earth(1,4)+a_earth(1,3));
% daspect([1 1 1])
view(-135,30)
rotate3d on
iss = [x(1) x(1) x(2) x(2) x(3) x(3)]+[-1 1 -1 1 -1 1].*50e3;
earth = [-1 1 -1 1 -1 1]*8e6;
axis vis3d
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
grid on

plot3(x(1),x(2),x(3),'O','Color','w','MarkerSize',10,'MarkerFaceColor','k')
for i = 1:steps
    r = sqrt(x(1)^2+x(2)^2+x(3)^2);
    if r < R
        disp("boom")
        break
    end
    Fl = -10*v/sqrt(v(1)^2+v(2)^2+v(3)^2);
    Fg = -G*M*m*x/(r^3);
    F = Fg+Fl;
    a = F/m;
    v = v+a.*dt;
    prev_x = x;
    x = x+v.*dt;
    line([prev_x(1),x(1)],[prev_x(2),x(2)],[prev_x(3),x(3)],'LineWidth',2,'Color','k')
end
plot3(x(1),x(2),x(3),'O','Color','w','MarkerSize',10,'MarkerFaceColor','r')
mn = (x_0+x)/2;
val = max(abs(x_0-x));
impact = [mn(1) mn(1) mn(2) mn(2) mn(3) mn(3)]+[-1 1 -1 1 -1 1]*val*1;
axis(impact)
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

