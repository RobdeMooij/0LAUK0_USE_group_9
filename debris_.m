classdef debris_ < handle
    properties
        position
        direction
        velocity
        energy
        mass
        size
        density
        smallest_value
    end
    methods(Access = public,Static)
        function obj = debris_(position,size,density)
            obj.velocity = 7700;%+200*rand();
            obj.position = position;
            obj.mass = 4/3*pi*size^3*density;
            angle_z = asin(-position(3)/sqrt(position(1)^2+position(2)^2+position(3)^2))+rand()/3;
            angle_xy = atan2(-position(2),-position(1))+rand()/3;
            obj.direction = [cos(angle_z)*cos(angle_xy);cos(angle_z)*sin(angle_xy);sin(angle_z)];            
            obj.energy = obj.mass*obj.velocity^2/2;
            obj.smallest_value = 1e-7;
        end
    end
    methods(Access = public)
        function [hit,dist] = hit_triangle(this,triangle)
            cross_ve = this.quick_cross(this.direction,triangle.edge_2);
            dot_ec = this.quick_dot(triangle.edge_1,cross_ve);            
            if dot_ec < this.smallest_value && dot_ec > -this.smallest_value
                hit = 0;
                dist = inf;
                return
            end
            vec_plane_to_tri = this.position-triangle.point_1;
            barycentric_1 = this.quick_dot(vec_plane_to_tri,cross_ve)/dot_ec;            
            if barycentric_1 < 0 || barycentric_1 > 1
                hit = 0;
                dist = inf;
                return
            end
            cross_vec_edge = this.quick_cross(vec_plane_to_tri,triangle.edge_1);
            barycentric_2 = this.quick_dot(this.direction,cross_vec_edge)/dot_ec;            
            if barycentric_2 < 0 || barycentric_1+barycentric_2 > 1
                hit = 0;
                dist = inf;
                return
            end
            hit = triangle.material;
            dist = this.quick_dot(triangle.edge_2,cross_vec_edge)/dot_ec;
        end
    end
    methods(Access = protected,Static)
        function scal = quick_dot(a,b)
            scal = a(1)*b(1)+a(2)*b(2)+a(3)*b(3);
        end
        function vec = quick_cross(a,b)
            vec = [a(2)*b(3)-a(3)*b(2);
                   a(3)*b(1)-a(1)*b(3);
                   a(1)*b(2)-a(2)*b(1)];
        end
    end
end

