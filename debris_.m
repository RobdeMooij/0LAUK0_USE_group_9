classdef debris_  < handle
    properties
        position            %vector coordinates of position             [m]
        direction           %normalized vector of movement direction    [m]
        velocity            %magnitude of the velocity                  [m/s]
        energy              %kinetic energy                             [J]
        mass                %mass                                       [kg]
        diameter            %diameter of the spehere formed debris      [m]
        density             %debris material density                    [kg/m^3]
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
            
            obj.position = position;            
            obj.energy   = obj.mass*obj.velocity^2/2;
            obj.mass     = 4/3*pi*(diameter/2)^3*density;
            obj.diameter = diameter;
            obj.density  = density;
            obj.get_movement();
        end
    end
    methods(Access = protected)
        function get_movement(this)
            %calculate direction with azimuth, elevation and added noise
            azimuth = atan2(-this.position(2),-this.position(1))+rand()/3;
            elevation = asin(-this.position(3)/sqrt(this.position(1)^2+this.position(2)^2+this.position(3)^2))+rand()/3;            
            this.direction = [cos(elevation)*cos(azimuth);cos(elevation)*sin(azimuth);sin(elevation)];
            
            %give velocity
            this.velocity = 70;%700;%+200*rand();
        end
    end
end

