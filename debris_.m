classdef debris_ < handle
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
            
            obj.velocity = 70;%700;%+200*rand();
            obj.position = position;
            obj.mass = 4/3*pi*(diameter/2)^3*density;
            
            %calculate direction with azimuth, elevation and added noise
            azimuth = atan2(-position(2),-position(1))+rand()/3;
            elevation = asin(-position(3)/sqrt(position(1)^2+position(2)^2+position(3)^2))+rand()/3;            
            obj.direction = [cos(elevation)*cos(azimuth);cos(elevation)*sin(azimuth);sin(elevation)];
            obj.energy = obj.mass*obj.velocity^2/2;
        end
    end   
end

