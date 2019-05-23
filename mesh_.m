classdef mesh_ < handle
   properties       
       vertices
       indices
       triangles
       materials
       normals
   end
   methods(Access = public, Static)
        function obj = mesh_(file_name)            
			json_file = fopen(file_name); 
            json_data = jsondecode(fread(json_file,inf,'*char'));
            fclose(json_file);
            obj.vertices    = json_data.vertices;
            obj.indices     = json_data.triangles;
            obj.materials   = json_data.materials;
            obj.normals     = json_data.normals;
            for i = 1:size(obj.indices,1)
                obj.triangles = [obj.triangles triangle_(obj.vertices(obj.indices(i,1),:),obj.vertices(obj.indices(i,2),:),obj.vertices(obj.indices(i,3),:),obj.normals(i,:),obj.materials(i))];
            end
        end
   end
   methods(Access = public)
        function show(this)            
            hold on
            for i = 1:size(this.indices,1)
                x = this.vertices(this.indices(i,:),1);
                y = this.vertices(this.indices(i,:),2);
                z = this.vertices(this.indices(i,:),3);
                c = 1-[this.materials(i);this.materials(i);this.materials(i)];
                fill3(x,y,z,c)
%                 mean_x = mean(x);
%                 mean_y = mean(y);
%                 mean_z = mean(z);
%                 line([mean_x mean_x+10*this.normals(i,1)],[mean_y mean_y+10*this.normals(i,2)],[mean_z mean_z+10*this.normals(i,3)],'Color','r','LineWidth',1)
            end
            view(45,30)            
            rotate3d on            
            hold off
%             max_ver = max([this.vertices(:,1) this.vertices(:,2) this.vertices(:,3)]);
%             min_ver = min([this.vertices(:,1) this.vertices(:,2) this.vertices(:,3)]);
%             middle = (max_ver+min_ver)/2;
%             diff = max((max_ver-min_ver)/2);
%             axis([middle(1)-diff middle(1)+diff middle(2)-diff middle(2)+diff middle(3)-diff middle(3)+diff])
            axis([-1 1 -1 1 -1 1]*70)
            axis vis3d
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            grid on
        end
    end
end