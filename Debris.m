classdef Debris  < handle
    properties
        position            %vector coordinates of position [m]
        direction           %velocity vector                [m]
        velocity            %velocity vector                [m/s]
        acceleration        %acceleration vector            [m/s^2]
        mass                %mass of he debris              [kg]
        diameter            %diameter of the debris         [m]
        impact = 0          %what it is going to hit        [-]
        steps = 0           %steps needed to hit ISS        [-]
    end
    methods(Access = public,Static)
        function obj = Debris(azimuth,elevation,distance,diameter,dt,mesh)
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
            obj.position  = [0 0 6.371e6+400e3]+[rand()-0.5 rand()-0.5 rand()-0.5]*100;
            obj.velocity  = 7700;
            obj.get_start_position(distance,dt)            
            start_pos     = obj.position;
            for i = 1:obj.steps
                obj.step(mesh,0,dt)
            end
            obj.position = start_pos;
        end
    end
    methods(Access = public)
        function show(this,scale,c)
%             hold on
            if scale == 1 
                scale = this.velocity;
            end
            x = [this.position(1) this.position(1)+this.direction(1)*scale];
            y = [this.position(2) this.position(2)+this.direction(2)*scale];
            z = [this.position(3) this.position(3)+this.direction(3)*scale];            
            plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',6,'MarkerFaceColor',c)
%             hold off
            line(x,y,z,'Color',c,'LineWidth',3)
        end
        function step(this,mesh,Fr,dt)
            this.movement_force(Fr,dt)
            this.movement_iss(dt)
            this.check_impact(mesh)
        end
        function movement_force(this,Fr,dt)
            Fg = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
            this.acceleration = Fg+Fr/this.mass;
            vel = this.velocity*this.direction+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
%             prev_position = this.position;
            this.position = this.position+vel.*dt;
%             line([prev_position(1),this.position(1)],[prev_position(2),this.position(2)],[prev_position(3),this.position(3)],'LineWidth',1,'Color','c')
        end
        function movement_iss(this,dt)
            rotation = [0 -7.7e3/(6.371e6+400e3)*dt 0];
            ct = cos(rotation);
            st = sin(rotation);
            rotation_matrix = [ct(:,2).*ct(:,1)                             ct(:,2).*st(:,1)                             -st(:,2);
                               st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1) st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1)  st(:,3).*ct(:,2);
                               ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1) ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1)  ct(:,3).*ct(:,2)];
            this.position = this.position*rotation_matrix;
        end
        function check_impact(this,mesh)
            distance_to_iss = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
            if distance_to_iss < 65
                min_dist = inf;
                for triangle = mesh.triangles
                    [hit,dist] = ray_hit_triangle(this,triangle);
                    if dist < min_dist
                        min_dist = dist;
                        this.impact = hit;
                    end
                end
            end
        end
    end
    methods(Access = protected)
        function get_start_position(this,distance,dt)
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',20,'MarkerFaceColor','g')
            dist = 0;
            while dist < distance
                prev_pos = this.position;
                this.movement_force(0,dt)
                d_dist = sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
                this.movement_iss(-dt)
                dist = dist+d_dist;
                this.steps = this.steps + 1;
            end
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',10,'MarkerFaceColor','r')
            this.direction = -this.direction;            
        end
    end
end

