classdef Triangle < handle
    properties
        point_1         %position of first point in the triangle
        point_2         %position of second point in the triangle
        point_3         %position of third point in the triangle
        edge_1          %point_2-point_1
        edge_2          %point_3-point_1
        material        %material index
    end
    methods(Access = public, Static)
        function obj = Triangle(point_1,point_2,point_3,material) % normal,
            obj.point_1  = point_1;
            obj.point_2  = point_2;
            obj.point_3  = point_3;
            obj.edge_1   = obj.point_2-obj.point_1;
            obj.edge_2   = obj.point_3-obj.point_1;
            obj.material = material;
        end
    end
    methods(Access = public)
        function show(this)
            x = [this.point_1(1) this.point_2(1) this.point_3(1)];
            y = [this.point_1(2) this.point_2(2) this.point_3(2)];
            z = [this.point_1(3) this.point_2(3) this.point_3(3)];
%             c = {[0 1 0],[1 1 0],[1 0 0]};
            c = {[0 1 0],[1 1 0],[1 0.7 0]};
            patch(x,y,z,c{this.material})
        end
    end
end



