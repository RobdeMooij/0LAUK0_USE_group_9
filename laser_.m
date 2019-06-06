classdef laser_  < handle
    properties
        position            %vector coordinates of position             [m]
        omega               %angular velocity                           [rad]
        velocity
        target
        change
        direction           %normalized vector of aiming direction      [m]
        distance            %distance to debris                         [m]
        capacity            %total laser energy capacity                [J]
        energy              %pulse energy of the laser                  [J]
        frequency           %repetition frequency of the laser          [Hz]
        range               %range of the laser                         [m]
        obst                %possible obstructions of the laser         []
        vision              %ability of laser to 'see' debris           []
    end
    methods(Access = public,Static)
        function obj = laser_(position,obst)
            obj.velocity = 10000;
            obj.omega    = 1; 
            obj.position = position;  
            obj.direction = [0,1,0];
            obj.obst     = obst;
            obj.energy    = 10;
            obj.frequency = 10000;
            obj.range    = 100000; 
            obj.capacity = 10000000; % To be determined
        end
    end
    methods(Access = public)
        function theta = set_aim(this,pos_debris)
            this.target = [pos_debris(1)-this.position(1) pos_debris(2)-this.position(2) pos_debris(3)-this.position(3)];
            this.target = this.target/norm(this.target);
            this.change = this.target-this.direction;
            theta = acos(dot(this.direction,this.target)/(norm(this.direction)*norm(this.target)));
        end
            
        function take_aim(this,pos_debris,obsts,theta)
            % Aim at debris object. 
            this.vision = 0;
            theta
            this.omega
            if abs(theta-this.omega) > this.omega
                this.direction = this.direction + this.change*(this.omega/theta);
            end
            %disp(this.direction)
            this.distance = sqrt((pos_debris(1)-this.position(1))^2+(pos_debris(2)-this.position(2))^2+(pos_debris(3)-this.position(3))^2);
            line([this.position(1) this.position(1)+this.velocity*this.direction(1)],[this.position(2) this.position(2)+this.velocity*this.direction(2)],[this.position(3) this.position(3)+this.velocity*this.direction(3)],'Color','b','LineWidth',1)
            if this.distance < this.range
                this.vision = 1;
                for triangle = obsts
                    [hit,dist] = ray_hit_triangle(this,triangle);
                    if hit ~= 0
                        this.vision = 0;
                        break
                    end
                end
            end
        end
%         function ablate(this,target,duration)
%             beam_energy = min(target.energy,this.power);
%             if beam_energy > 0
%                 %target.energy = target.energy - beam_energy;
%                 this.capacity = this.capacity - beam_energy;
%             end
%         end
    end
        
end

