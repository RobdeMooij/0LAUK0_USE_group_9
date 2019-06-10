classdef Laser < handle
    properties
        position            %vector coordinates of position             [m]
        omega               %angular velocity                           [rad]
        azimuth
        elevation
        target
        direction           %normalized vector of aiming direction      [m]
        distance            %distance to debris                         [m]
        power               %total avaiable power for laser             [W]
        range               %range of the laser                         [m]
%         vision              %ability of laser to 'see' debris           []
    end
    methods(Access = public,Static)
        function obj = Laser(position,azimuth,elevation)
            obj.position  = position;
            obj.direction = obj.get_direction(azimuth,elevation);
            obj.azimuth   = azimuth;
            obj.elevation = elevation;
            obj.omega     = 0.1;
            obj.range     = 100e3;
            obj.power     = 100e3;
        end
    end
    methods(Access = public)
        function show(this,dist)            
            x = [this.position(1) this.position(1)+this.direction(1)*dist];
            y = [this.position(2) this.position(2)+this.direction(2)*dist];
            z = [this.position(3) this.position(3)+this.direction(3)*dist];
%             c = [0 0.8 1];
            c = [1 0 0];
%             hold on
            plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',8,'MarkerFaceColor',c)
%             hold off
            line(x,y,z,'LineWidth',3,'Color','k')
            line(x,y,z,'LineWidth',2,'Color',c)
        end
        function take_aim(this,debris_pos,dt)
            this.target = [debris_pos(1)-this.position(1) debris_pos(2)-this.position(2) debris_pos(3)-this.position(3)];
            this.target = this.target/sqrt(this.target(1)^2+this.target(2)^2+this.target(3)^2);
            [target_azimuth,target_elevation] = this.get_angles(this.target);
            azimuth_difference = target_azimuth-this.azimuth;
            if abs(azimuth_difference) > pi
                azimuth_difference = azimuth_difference-pi*2*sign(azimuth_difference);
            end
            if abs(azimuth_difference) <= this.omega*dt
                this.azimuth = target_azimuth;
            else
                this.azimuth = this.azimuth+this.omega*dt*sign(azimuth_difference);
            end
            elevation_difference = target_elevation-this.elevation;
%             if abs(elevation_difference) > pi
%                 elevation_difference = elevation_difference-pi*2*sign(elevation_difference);
%                 disp("ele")
%             end
            if abs(elevation_difference) <= this.omega*dt
                this.elevation = target_elevation;
            else
                this.elevation = this.elevation+this.omega*dt*sign(elevation_difference);
            end
            this.direction = this.get_direction(this.azimuth,this.elevation);
        end
%         function ablate(this,target,duration)
%             beam_energy = min(target.energy,this.power);
%             if beam_energy > 0
%                 %target.energy = target.energy - beam_energy;
%                 this.capacity = this.capacity - beam_energy;
%             end
%         end
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
end

% % Aim at debris object.
%             this.target = [pos_debris(1)-this.position(1) pos_debris(2)-this.position(2) pos_debris(3)-this.position(3)];
%             this.target = this.target/(sqrt(this.target(1)^2+this.target(2)^2+this.target(3)^2));
% %             this.vision = 0;
% %             theta
% %             this.omega
%             if abs(theta-this.omega) > this.omega
%                 this.direction = this.direction + this.change*(this.omega/theta);
%             else 
%                 this.direction = this.target;
%             end
%             %disp(this.direction)
%             this.distance = sqrt((pos_debris(1)-this.position(1))^2+(pos_debris(2)-this.position(2))^2+(pos_debris(3)-this.position(3))^2);
%             line([this.position(1) this.position(1)+this.velocity*this.direction(1)],[this.position(2) this.position(2)+this.velocity*this.direction(2)],[this.position(3) this.position(3)+this.velocity*this.direction(3)],'Color','b','LineWidth',1)
%             if this.distance < this.range
%                 this.vision = 1;
%                 for triangle = obsts
%                     [hit,dist] = ray_hit_triangle(this,triangle);
%                     if hit ~= 0
%                         this.vision = 0;
%                         break
%                     end
%                 end
%             end