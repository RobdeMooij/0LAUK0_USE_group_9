function [hit,dist] = ray_hit_triangle(position,direction,triangle)
%use of the M�ller�Trumbore intersection algorithm
%inputs:
% position      position of object producing ray
% direction     direction of ray (normalized or not)
% triangle      triangle to check intersection with
%outputs:
% hit           hit material index(0 = miss)
% dist          distance from position to the intersection

smallest_value = 1e-10;
cross_ve = quick_cross(direction,triangle.edge_2);
dot_ec = quick_dot(triangle.edge_1,cross_ve);

%ray and triangle are parallel (within smallest allowed value)
if dot_ec < smallest_value && dot_ec > -smallest_value
    hit = 0;
    dist = 1e10;
    return
end

%intersection outside the triangle
vec_plane_to_tri = position-triangle.point_1;
barycentric_1 = quick_dot(vec_plane_to_tri,cross_ve)/dot_ec;
if barycentric_1 < 0 || barycentric_1 > 1
    hit = 0;
    dist = 1e10;
    return
end
cross_vec_edge = quick_cross(vec_plane_to_tri,triangle.edge_1);
barycentric_2 = quick_dot(direction,cross_vec_edge)/dot_ec;
if barycentric_2 < 0 || barycentric_1+barycentric_2 > 1
    hit = 0;
    dist = 1e10;
    return
end

%calculate distance to the intersection
dist = quick_dot(triangle.edge_2,cross_vec_edge)/dot_ec;
if dist > smallest_value
    %ray intersects with triangle
    hit = triangle.material;
    return
else
    %intersects only in opposite direction
    hit = 0;
    dist = 1e10;
    return
end
end

function scal = quick_dot(a,b)
% dot product, without exception handling
scal = a(1)*b(1)+a(2)*b(2)+a(3)*b(3);
end

function vec = quick_cross(a,b)
% cross product, without exception handling
vec = [a(2)*b(3)-a(3)*b(2);a(3)*b(1)-a(1)*b(3);a(1)*b(2)-a(2)*b(1)];
end