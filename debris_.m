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
    methods(Access = public)
        function [hit,dist] = hit_triangle(this,triangle)
            %use of the Möller–Trumbore intersection algorithm
            %inputs:
            % position      begin position of ray
            % direction     normalized direction vector of ray
            % triangle      triangle to check intersection with
            %outputs:
            % hit           hit material index(0 = miss)
            % dist          distance from position to the intersection
            smallest_value = 1e-7;
            cross_ve = this.quick_cross(this.direction,triangle.edge_2);
            dot_ec = this.quick_dot(triangle.edge_1,cross_ve);
            
            %ray and triangle are parallel (within smallest allowed value)
            if dot_ec < smallest_value && dot_ec > -smallest_value
                hit = 0;
                dist = inf;
                return
            end
            
            %intersection outside the triangle
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
            
            %ray intersects with triangle
            hit = triangle.material;
            dist = this.quick_dot(triangle.edge_2,cross_vec_edge)/dot_ec;
        end
    end
    methods(Access = protected,Static)
        function scal = quick_dot(a,b)
            % dot product, without exception handling
            scal = a(1)*b(1)+a(2)*b(2)+a(3)*b(3);
        end
        function vec = quick_cross(a,b)
            % cross product, without exception handling
            vec = [a(2)*b(3)-a(3)*b(2);a(3)*b(1)-a(1)*b(3);a(1)*b(2)-a(2)*b(1)];
        end
    end
end

