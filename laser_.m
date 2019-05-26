classdef laser_  < handle
    properties
        position            %vector coordinates of position             [m]
        velocity
        direction           %normalized vector of aiming direction      [m]
        capacity            %total laser energy capacity                [J]
        power               %power of the laser                         [J/s]
        range               %range of the laser                         [m]
        vision              %ability of laser to 'see' debris           []
    end
    methods(Access = public,Static)
        function obj = laser_(position)
            %initialize a debris object
            %input:
            % position      start position
            % diameter      diameter of sphere shaped debris
            % density       debris material density
            %output:
            % obj           debris object with properties based on inputs
            obj.velocity = 100;
            obj.position = position;            
            obj.power    = 100000;
            obj.range    = 100000; 
            obj.capacity = 10000000; % To be determined
        end
    end
    methods(Access = public)
        function take_aim(this,pos_debris,obsts)
            beam = [pos_debris(1)-this.position(1) pos_debris(2)-this.position(2) pos_debris(3)-this.position(3)];
            this.direction = beam/norm(beam);
            this.vision = 1;
            for triangle = obsts
                [hit,dist] = ray_hit_triangle(this,triangle);
                if hit ~= 0
                    this.vision = 0;
                    break
                end
            end
        end
        function ablate(this,target)
            target.energy = target.energy - this.power;
            this.capacity = this.capacity - this.power;
        end
    end
        
end

