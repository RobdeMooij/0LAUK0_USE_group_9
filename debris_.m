classdef debris_  < handle
    properties
        position            %vector coordinates of position             [m]
        path                %position history                           [m]
        direction           %normalized vector of movement direction    [m]
        velocity            %magnitude of the velocity                  [m/s]
        energy              %kinetic energy                             [J]
        mass                %mass                                       [kg]
        diameter            %diameter of the spehere formed debris      [m]
        density             %debris material density                    [kg/m^3]
        hit                 %what it is going to hit                    [-]
    end
    methods(Access = public,Static)
        function obj = debris_(position,diameter,density)
            %initialize a debris object
            %input:
            % position      start position
            % diameter      diameter of sphere shaped debris
            % density       debris material density
            %output:
            % obj           debris object with properties based on inputs
            obj.position  = position;
            obj.get_start_movement();
            obj.diameter  = diameter;
            obj.density   = density;
            obj.mass      = 4/3*pi*(diameter/2)^3*density;
            obj.energy    = obj.mass*obj.velocity^2/2;
        end
    end
    methods(Access = public)
        function show(this)
            for i = 1:size(this.path,1)-1
                x = this.path(i:i+1,1);
                y = this.path(i:i+1,2);
                z = this.path(i:i+1,3);
                line(x,y,z,'Color',[rand() rand() rand()])
            end
            line([this.position(1) this.position(1)+this.direction(1)*this.velocity],...
                [this.position(2) this.position(2)+this.direction(2)*this.velocity],...
                [this.position(3) this.position(3)+this.direction(3)*this.velocity])
        end
        function get_path(this,dt)
            sqrt(this.position(1)^2+this.position(3)^2+this.position(3)^2)/this.velocity/dt
            nr_steps = ceil(sqrt(this.position(1)^2+this.position(3)^2+this.position(3)^2)/this.velocity/dt);
            this.path = zeros(nr_steps,3);
            for i = 1:nr_steps
                this.get_movement()
                this.position = (this.position+this.velocity.*this.direction)*dt;
                this.path(i,:) = this.position;
            end
        end
    end
    methods(Access = protected)
        function get_start_movement(this)
            %v=sqrt(G*M/r) Earth: r = 6.371e6, G = 6.674e-11, m = 5.972e24, ISS: 330-400km
            debris_velocity = sqrt(3.9857e+14/(this.position(3)+6.736e6));            
            debris_direction = [-this.position(1) -this.position(2) -this.position(3)];            
            debris_direction = debris_direction*debris_velocity/sqrt(debris_direction(1)^2+debris_direction(2)^2+debris_direction(3)^2);
            this.direction = [debris_direction(1) debris_direction(2) debris_direction(3)];
            this.velocity = sqrt(this.direction(1)^2+this.direction(2)^2+this.direction(3)^2);
%             this.position = [this.position(1) this.position(2)+7700 this.position(3)];
            this.direction = this.direction./this.velocity;
        end
        function get_movement(this)
%             this.direction = this.direction+([rand() rand() rand()]-0.5)/5;
        end
    end
end

