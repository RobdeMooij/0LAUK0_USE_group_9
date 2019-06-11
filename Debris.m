classdef Debris < handle
    properties
        position            %vector coordinates of position [m]
        direction           %normalized velocity vector     [m]
        velocity            %velocity magnitude             [m/s]
        acceleration        %acceleration vector            [m/s^2]
        mass                %mass of he debris              [kg]
        diameter            %diameter of the debris         [m]
        impact = 0          %what it is going to hit        [-]
        steps = 0           %steps needed to hit ISS        [-]
    end
    methods(Access = public,Static)
        function obj = Debris(azimuth,elevation,distance,diameter,dt)
            %initialize a debris object
            %input:
            % azimuth       
            % elevation
            % distance
            % diameter
            % dt
            % mesh
            %output:
            % obj           debris object with properties based on inputs
            
            obj.diameter  = diameter;
            obj.mass      = 61*(diameter/2)^2.26;
            
            obj.direction = [cos(azimuth)*cos(elevation) sin(azimuth)*cos(elevation) sin(elevation)];
            obj.position  = [0 0 6.371e6+400e3]+[rand()-0.5 rand()-0.5 rand()-0.5]*0;
            obj.velocity  = 7700;
            obj.get_start_position(distance,dt)
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
        function step(this,Fr,dt) 
            if this.steps > 0
                this.movement_force(Fr,dt)
                this.movement_iss(dt)
            end
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
        function check_impact(this,mesh,dt)
            if this.steps > 0
                original_position  = this.position;
                original_direction = this.direction;
                original_velocity  = this.velocity;
                diff = 1;
                this.steps = 0;
                while diff > 0
                    dist_before = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
                    this.steps = this.steps+1;
                    this.step(0,dt)                    
                    dist_after = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
                    diff = dist_before-dist_after;
                    this.impact = 0;
                    if dist_after <= this.velocity*dt+60
                        min_dist = this.hit_mesh(mesh);
                        if min_dist <= this.velocity*dt
                            break
                        end
                    end                
                end
                this.position  = original_position;
                this.direction = original_direction;
                this.velocity  = original_velocity;
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
                this.movement_iss(-dt)
                d_dist = sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
                dist = dist+d_dist;
                this.steps = this.steps + 1;
                if this.steps > 30/dt
                    break
                end
            end
%             plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',10,'MarkerFaceColor','r')
            this.direction = -this.direction;            
        end
        function min_dist = hit_mesh(this,mesh)            
            min_dist = inf;
            for triangle = mesh.triangles
                [triangle_hit_type,dist] = ray_hit_triangle(this,triangle);
                if dist < min_dist
                    min_dist = dist;
                    this.impact = triangle_hit_type;                    
                end
            end
        end
    end
end

