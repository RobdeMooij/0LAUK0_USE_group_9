classdef debris_  < handle
    properties
        position            %vector coordinates of position [m]
        path                %position history               [m]
        direction           %velocity vector                [m]
        velocity            %velocity vector                [m/s]
        acceleration        %acceleration vector            [m/s^2]
        mass                %mass of he debris              [kg]
        diameter            %diameter of the debris         [m]
        density             %debris material density        [kg/m^3]
        hit                 %what it is going to hit        [-]
    end
    methods(Access = public,Static)
        function obj = debris_(azimuth,elevation,distance,diameter,dt)
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
            obj.get_start_position(distance,dt)
        end
    end
    methods(Access = public)
        function show(this)
            for i = 1:size(this.path,1)-1
                x = this.path(i:i+1,1);
                y = this.path(i:i+1,2);
                z = this.path(i:i+1,3);
                c = [rand() rand() rand()];
                line(x,y,z,'Color',c)
            end
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
        function back_step(this,dt)
            this.acceleration = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
            vel = this.velocity*this.direction+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
%             prev_position = this.position;
            this.position = this.position+vel.*dt;
%             line([prev_position(1),this.position(1)],[prev_position(2),this.position(2)],[prev_position(3),this.position(3)],'LineWidth',2,'Color','k')
        end
    end
    methods(Access = protected)
        function get_start_position(this,distance,dt)
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',20,'MarkerFaceColor','g')
            dist = 0;
            while dist < distance
                prev_pos = this.position;
                this.back_step(dt)
                dist = dist+sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
            end
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',10,'MarkerFaceColor','r')
            this.direction = -this.direction;
        end
%         function get_end_position(this,distance,dt)            
%             dist = 0;
%             while dist < distance
%                 prev_pos = this.position;
%                 this.step(0,dt)
%                 dist = dist+sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
%             end
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',10,'MarkerFaceColor','b')            
%         end
    end
end

