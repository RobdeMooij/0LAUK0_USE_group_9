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
            % position      start position
            % diameter      diameter of sphere shaped debris
            % density       debris material density
            %output:
            % obj           debris object with properties based on inputs
            
            obj.diameter  = diameter;
            obj.mass      = 61*(diameter/2)^2.26;
            
            obj.direction = [0 1 0];%[sin(azimuth)*cos(elevation) cos(azimuth)*cos(elevation) sin(elevation)];
            obj.position  = [0 0 6371e3+400e3];%+[rand()-0.5 rand()-0.5 rand()-0.5]*50;
            obj.velocity  = 7700;
            obj.get_start_position(distance,dt)            
%             obj.energy    = obj.mass*obj.velocity^2/2;
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
            vel = this.velocity+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
            this.position = this.position+this.velocity.*dt;
        end
        function back_step(this,dt)
            this.acceleration = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
            vel = this.velocity+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
            prev_position = this.position;
            this.position = this.position-vel.*dt;
            disp(this.position)
            line([prev_position(1),this.position(1)],[prev_position(2),this.position(2)],[prev_position(3),this.position(3)],'LineWidth',1,'Color','k')             
        end
    end
    methods(Access = protected)
        function get_start_position(this,distance,dt)
            dist = 0;
            begin_position = this.position;
            while dist < distance
                this.back_step(-dt)
                dist = sqrt((begin_position(1)-this.position(1))^2+(begin_position(2)-this.position(2))^2+(begin_position(3)-this.position(3))^2);
            end
        end
    end
end

