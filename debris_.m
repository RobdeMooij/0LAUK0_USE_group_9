classdef debris_  < handle
    properties
        position            %vector coordinates of position             [m]
        path                %position history                           [m]
        direction           %normalized vector of movement direction    [m]
        velocity            %magnitude of the velocity                  [m/s]
%         energy              %kinetic energy                             [J]
        mass                %mass                                       [kg]
        diameter            %diameter of the spehere formed debris      [m]
        density             %debris material density                    [kg/m^3]
        hit                 %what it is going to hit                    [-]
    end
    methods(Access = public,Static)
        function obj = debris_(azimuth,elevation,distance,diameter)
            %initialize a debris object
            %input:
            % position      start position
            % diameter      diameter of sphere shaped debris
            % density       debris material density
            %output:
            % obj           debris object with properties based on inputs            
            obj.direction = [sin(azimuth)*cos(elevation) cos(azimuth)*cos(elevation) sin(elevation)];
            obj.position  = -obj.direction*distance+[rand()-0.5 rand()-0.5 rand()-0.5]*55;
            obj.velocity  = 14800*(1-abs(cos(azimuth/2)))+1200*rand();
            obj.diameter  = diameter;
            obj.density   = 2700;
            obj.mass      = 4/3*pi*(diameter/2)^3*obj.density;
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
        function get_path(this,dt)
            nr_steps = min(ceil(sqrt(this.position(1)^2+this.position(2)^2+this.position(3)^2)/this.velocity/dt),50);
            this.path = zeros(nr_steps,3);
            for i = 1:nr_steps
                this.get_movement()
                this.position = this.position+(this.velocity.*this.direction)*dt;
                this.path(i,:) = this.position;
            end
        end
    end
    methods(Access = protected)
        function get_movement(this)            
%             this.direction = this.direction+([rand() rand() rand()]-0.5)/5;
        end
    end
end

