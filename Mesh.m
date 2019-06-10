classdef Mesh < handle
   properties
       position         %vector coordinates of position
       vertices         %vertices coordinates
       indices          %vertices indices that make up triangle
       triangles        %triangle_ objects
       materials        %triangles material indices
   end
   methods(Access = public, Static)
        function obj = Mesh(file_name)
            %create mesh_ object based on (.json or .txt) file
            json_file = fopen(file_name);
            try %possible bug in jsondecode in Matlab version 2018b and higher
                json_data = jsondecode(fread(json_file,inf,'*char'));
            catch %use JSONlab toolbox (has to be installed)
                json_data = loadjson(file_name);
            end
            fclose(json_file);
            obj.position    = [0 0 6371e3+400e3];
            obj.vertices    = json_data.vertices+obj.position;
            obj.indices     = json_data.indices;
            obj.materials   = json_data.materials;
            
            %create triangle_ objects
            for i = 1:size(obj.indices,1)
                obj.triangles = [obj.triangles Triangle(obj.vertices(obj.indices(i,1),:),obj.vertices(obj.indices(i,2),:),obj.vertices(obj.indices(i,3),:),obj.materials(i))]; % obj.normals(i,:),
            end
        end
        function new_axis(scale,offset)
            axis([offset(1) offset(1) offset(2) offset(2) offset(3) offset(3)]+[-1 1 -1 1 -1 1]*scale)
        end
   end
   methods(Access = public)
        function show(this,scale,offset)
            %shows mesh
            [az,el] = view;
            if scale < 1000
%                 hold on
                for triangle = this.triangles
                    triangle.show()
                end
%                 hold off
            else
                plot3(this.position(1),this.position(2),this.position(3),'O','Color','k','MarkerSize',12,'MarkerFaceColor',[1 1 0]);
                line(this.position(1)+[0 scale/4],this.position(2)+[0 0],this.position(3)+[0 0],'Color','k','LineWidth',3)            
            end
            view(az,el)
            rotate3d on            
            axis([offset(1) offset(1) offset(2) offset(2) offset(3) offset(3)]+[this.position(1) this.position(1) this.position(2) this.position(2) this.position(3) this.position(3)]+[-1 1 -1 1 -1 1]*scale)
            axis vis3d
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            grid on
        end        
    end
end