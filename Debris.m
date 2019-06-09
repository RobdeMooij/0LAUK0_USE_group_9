classdef Debris  < handle
    properties
        position            %vector coordinates of position [m]
        direction           %velocity vector                [m]
        velocity            %velocity vector                [m/s]
        acceleration        %acceleration vector            [m/s^2]
        mass                %mass of he debris              [kg]
        diameter            %diameter of the debris         [m]
        density             %debris material density        [kg/m^3]
        hit                 %what it is going to hit        [-]
    end
    methods(Access = public,Static)
        function obj = Debris(azimuth,elevation,distance,diameter,dt)
            %initialize a debris object
            %input:
            % azimuth       angle in the 
            % elevation
            % distance
            % diameter
            % dt
            %output:
            % obj           debris object with properties based on inputs
            
            obj.diameter  = diameter;
            obj.mass      = 61*(diameter/2)^2.26;
            
            obj.direction = [cos(azimuth)*cos(elevation) sin(azimuth)*cos(elevation) sin(elevation)];
            obj.position  = [0 0 6.371e6+400e3]+[rand()-0.5 rand()-0.5 rand()-0.5]*50;
            obj.velocity  = 7700;
%             target_hit    = obj.position;
            obj.get_start_position(distance,dt)            
%             start_pos     = obj.position;
%             obj.get_start_position(distance,dt)
%             actual_hit    = obj.position;
%             disp(norm(actual_hit-target_hit));
%             obj.position = start_pos;
        end
    end
    methods(Access = public)
        function show(this)
            hold on
            axis([-1 1 -1 1 -1 1]*(6.371e6+400e3))
            plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',6,'MarkerFaceColor','b')
            x = [this.position(1) this.position(1)+this.direction(1)*this.velocity];
            y = [this.position(2) this.position(2)+this.direction(2)*this.velocity];
            z = [this.position(3) this.position(3)+this.direction(3)*this.velocity];
            c = [rand() rand() rand()];
            line(x,y,z,'Color',c)
        end
        function step(this,Fr,dt)
            Fg = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
            this.acceleration = Fg+Fr/this.mass;
            vel = this.velocity*this.direction+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
%             prev_position = this.position;
            this.position = this.position+vel.*dt;
%             line([prev_position(1),this.position(1)],[prev_position(2),this.position(2)],[prev_position(3),this.position(3)],'LineWidth',1,'Color','c')
        end
%         function back_step(this,dt)
%             this.acceleration = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
%             vel = this.velocity*this.direction+this.acceleration.*dt;
%             this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
%             this.direction = vel/this.velocity;
% %             prev_position = this.position;
%             this.position = this.position+vel.*dt;
% %             line([prev_position(1),this.position(1)],[prev_position(2),this.position(2)],[prev_position(3),this.position(3)],'LineWidth',2,'Color','k')
%         end
    end
    methods(Access = protected)
        function get_start_position(this,distance,dt)
            plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',20,'MarkerFaceColor','g')
            dist = 0;
            while dist < distance
                prev_pos = this.position;
                this.step(0,dt)
                d_dist = sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
                dist = dist+d_dist;
            end
            plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',10,'MarkerFaceColor','r')
            this.direction = -this.direction;
            rotate_iss_movement(-dt)
        end
        function rotate_iss_movement(this,dt)
%             sqrt((this.position-)^2
            rotation = [0 0 7.7e3/(6.371e6+400e3)*dt];
            ct = cos(rotation);
            st = sin(rotation);
            rotation_matrix = [ct(:,2).*ct(:,1)                             ct(:,2).*st(:,1)                             -st(:,2);
                               st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1) st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1)  st(:,3).*ct(:,2);
                               ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1) ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1)  ct(:,3).*ct(:,2)];
            this.position = this.position*rotation_matrix;
        end        
    end
end

