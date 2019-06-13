classdef Debris < handle
    properties
        position            %vector coordinates of position [m]
        direction           %normalized velocity vector     [m]
        velocity            %velocity magnitude             [m/s]
        acceleration        %acceleration vector            [m/s^2]
        mass                %mass of he debris              [kg]
        diameter            %diameter of the debris         [m]
%         impact = 0          %what it is going to hit        [-]
%         steps = 0           %steps needed to hit ISS        [-]
%         hit_pos = [0 0 0]   %position of impact on ISS      [m]
%         next_pos = [0 0 0]  %position of next step          [m]
    end
    methods(Access = public,Static)
        function obj = Debris(azimuth,elevation,distance,diameter,offset,dt)
            %initialize a debris object
            %input:
            % azimuth       
            % elevation
            % distance
            % diameter
            % offset
            % dt
            %output:
            % obj           debris object with properties based on inputs            
            obj.diameter  = diameter;
            obj.mass      = 61*(diameter/2)^2.26;            
            obj.direction = [cos(azimuth)*cos(elevation) sin(azimuth)*cos(elevation) sin(elevation)];
            obj.position  = [0 0 6.371e6+400e3]+offset;
            obj.velocity  = 7700;
            obj.get_start_position(distance,dt)
        end
    end
    methods(Access = public)
        function show_vel(this,scale)                
            x = [this.position(1) this.position(1)+this.direction(1)*scale];
            y = [this.position(2) this.position(2)+this.direction(2)*scale];
            z = [this.position(3) this.position(3)+this.direction(3)*scale];
            line(x,y,z,'Color',[0.5 0 1],'LineWidth',1.5)
        end
        function show_net(this,next_pos,draw_marker)
            x = [this.position(1) next_pos(1)];
            y = [this.position(2) next_pos(2)];
            z = [this.position(3) next_pos(3)];
            if draw_marker
                plot3(next_pos(1),next_pos(2),next_pos(3),'O','Color','k','MarkerSize',12,'MarkerFaceColor','r')
            end
            line(x,y,z,'Color',[0.5 0 1],'LineWidth',1)
        end
        function step(this,Fr,dt)
            this.movement_force(Fr,dt)
            this.movement_iss(dt)
        end
        function movement_force(this,Fr,dt)
            Fg = -3.9857e+14*this.position/((this.position(1)^2+this.position(2)^2+this.position(3)^2)^1.5);
            this.acceleration = Fg+Fr/this.mass;
            vel = this.velocity*this.direction+this.acceleration.*dt;
            this.velocity = sqrt(vel(1)^2+vel(2)^2+vel(3)^2);
            this.direction = vel/this.velocity;
            this.position = this.position+vel.*dt;
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
    end
    methods(Access = protected)
        function get_start_position(this,distance,dt)
            dist = 0;
            while dist < distance
                prev_pos = this.position;
                this.movement_force(0,dt)                
                this.movement_iss(-dt)
                d_dist = sqrt((prev_pos(1)-this.position(1))^2+(prev_pos(2)-this.position(2))^2+(prev_pos(3)-this.position(3))^2);
                dist = dist+d_dist;
            end
            this.direction = -this.direction;            
        end
    end
end

%         function step_rough(this,Fr,dt) 
%             if this.steps > 0
%                 this.movement_force(Fr,dt)
%                 this.movement_iss(dt)
%                 this.steps = this.steps-1;
%             end
%         end
%         function check_impact_rough(this,mesh,dt)            
%             original_position  = this.position;
%             original_direction = this.direction;
%             original_velocity  = this.velocity;
%             this.steps = 0;
%             this.impact = 0;
%             while true
%                 dist_before = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
%                 this.steps = this.steps+1;
%                 this.step(0,dt)
%                 dist_after = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
%                 step_velocity = this.velocity*dt;
%                 if dist_after <= step_velocity+60
%                     [triangle_hit_type,min_dist] = hit_mesh(this,mesh,net_direction);
%                     if min_dist <= step_velocity
%                         this.impact  = triangle_hit_type;
%                         this.hit_pos = this.position+net_direction*min_dist;
%                         break
%                     end
%                 end
%                 if dist_before <= dist_after
%                     break
%                 end
%             end
%             this.steps     = this.steps-1;
%             this.position  = original_position;
%             this.direction = original_direction;
%             this.velocity  = original_velocity;
%             
%         end
%         function step_impact(this,mesh,Fr,dt)
%             this.impact   = 0;
%             step_velocity = this.velocity*dt;
%             dist = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
%             if dist <= step_velocity+60
%                 net_direction = this.direction*this.velocity-[7.7e3 0 0];
%                 net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
%                 min_dist = this.hit_mesh(mesh,net_direction);
%                 if min_dist <= step_velocity
%                     [triangle_hit_type,min_dist] = hit_mesh(this,mesh,net_direction);
%                     if min_dist <= step_velocity
%                         this.impact  = triangle_hit_type;
%                         this.hit_pos = this.position+net_direction*min_dist;
%                         return
%                     end
%                 end
%             else
%                 this.movement_force(Fr,dt)
%                 this.movement_iss(dt)
%                 original_position  = this.position;
%                 original_direction = this.direction;
%                 original_velocity  = this.velocity;
%                 
%                 this.position  = original_position;
%                 this.direction = original_direction;
%                 this.velocity  = original_velocity;
%             end
%         end
%         function step_threshold(this,mesh,dt)
%             if this.steps == 1
%                 this.hit_pos = [0 0 0];
%                 net_direction = this.direction*this.velocity-[7.7e3 0 0];
%                 net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
%                 min_dist = this.hit_mesh(mesh,net_direction);
%                 if min_dist < this.velocity*dt
%                     this.next_pos = this.position+net_direction*min_dist;
%                     this.hit_pos  = this.next_pos;
%                 else
%                     this.next_pos = this.position+net_direction*min_dist;
%                 end                
%                 this.steps = 0;
%             else
%                 original_position  = this.position;
%                 original_direction = this.direction;
%                 original_velocity  = this.velocity;
%                 diff = 1;
%                 this.steps = 0;
%                 this.impact = 0;
%                 while diff > 0
%                     dist_before = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
%                     this.steps = this.steps+1;
%                     this.step(0,dt)
%                     if this.steps == 1
%                         this.next_pos = this.position;
%                     end
%                     dist_after = sqrt((mesh.position(1)-this.position(1))^2+(mesh.position(2)-this.position(2))^2+(mesh.position(3)-this.position(3))^2);
%                     diff = dist_before-dist_after;
%                     if dist_after <= this.velocity*dt+60
%                         net_direction = this.direction*this.velocity-[7.7e3 0 0];
%                         net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
%                         min_dist = this.hit_mesh(mesh,net_direction);
%                         if min_dist <= this.velocity*dt
% %                             this.next_pos = this.position+net_direction*min_dist;
%                             this.hit_pos  = this.position+net_direction*min_dist;
%                             break
%                         end
% %                     else
% %                         net_direction = this.direction*this.velocity-[7.7e3 0 0];
% %                         net_direction = net_direction/sqrt(net_direction(1)^2+net_direction(2)^2+net_direction(3)^2);
% %                         this.next_pos = this.position+net_direction*this.velocity*dt;
%                     end                    
%                 end
%                 this.steps = this.steps-1;
%                 this.position  = original_position;
%                 this.direction = original_direction;
%                 this.velocity  = original_velocity;
%             end
%         end

