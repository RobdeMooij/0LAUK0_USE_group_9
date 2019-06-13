classdef Laser < handle
    properties
        position            %vector coordinates of position             [m]
        omega               %angular velocity                           [rad/s]
        azimuth
        elevation
        fov
        target
        direction           %normalized vector of aiming direction      [m]
        range               %range of the laser                         [m]
        vision = false      %boolean: facing debris                     [-]
    end
    methods(Access = public,Static)
        function obj = Laser(position,azimuth,elevation,fov)
            obj.position  = position;
            obj.direction = obj.get_direction(azimuth,elevation);
            obj.azimuth   = azimuth;
            obj.elevation = elevation;
            obj.omega     = 0.1;
            obj.range     = 100e3;
            obj.fov       = fov;
        end
    end
    methods(Access = public)
        function show(this,dist)            
            x = [this.position(1) this.position(1)+this.direction(1)*dist];
            y = [this.position(2) this.position(2)+this.direction(2)*dist];
            z = [this.position(3) this.position(3)+this.direction(3)*dist];
            if this.vision
                plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',4,'MarkerFaceColor','r')
                line(x,y,z,'LineWidth',2,'Color','r')
%                 line(x,y,z,'LineWidth',1,'Color','r')
            else
                plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',4,'MarkerFaceColor','c')
                line(x,y,z,'LineWidth',2,'Color','c')
%                 line(x,y,z,'LineWidth',1,'Color','c')
            end
        end
        function take_aim(this,debris_pos,dt)
            this.target = [debris_pos(1)-this.position(1) debris_pos(2)-this.position(2) debris_pos(3)-this.position(3)];
            distance_to_debris = sqrt(this.target(1)^2+this.target(2)^2+this.target(3)^2);
            this.target = this.target/distance_to_debris;
            [target_azimuth,target_elevation] = this.get_angles(this.target);
            azimuth_difference = target_azimuth-this.azimuth;
            if abs(azimuth_difference) <= this.omega*dt
                this.azimuth = target_azimuth;
            else
                this.azimuth = this.azimuth+this.omega*dt*sign(azimuth_difference);
            end
            elevation_difference = target_elevation-this.elevation;
            if abs(elevation_difference) <= this.omega*dt
                this.elevation = target_elevation;
            else
                this.elevation = this.elevation+this.omega*dt*sign(elevation_difference);
            end
            this.clamp_angles()
            this.direction = this.get_direction(this.azimuth,this.elevation);
            if distance_to_debris <= this.range && this.azimuth == target_azimuth && this.elevation == target_elevation
                this.vision = true;
            else
                this.vision = false;
            end
        end
    end
    methods(Access = protected,Static)
        function [azimuth,elevation] = get_angles(normalized_vector)
            elevation = asin(normalized_vector(3));
            azimuth = atan2(normalized_vector(2),normalized_vector(1));
        end
        function [normalized_vector] = get_direction(azimuth,elevation)
            normalized_vector = [cos(azimuth)*cos(elevation) sin(azimuth)*cos(elevation) sin(elevation)];
        end
    end
    methods(Access = protected)            
        function clamp_angles(this)
            this.azimuth = min(this.fov(2),max(this.azimuth,this.fov(1)));
            this.elevation = min(this.fov(4),max(this.elevation,this.fov(3)));
        end
    end
end