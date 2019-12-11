clear all; close all; clc;
classes = {0,1,1,1,1,1,1,1,1,3,3,2,2,2,3,0,0,0,2,2,2,2,0};

%%
location = '../data-2019/test/';
datainformation = importdata('Detect_information.txt');
filepaths = datainformation.textdata;
labels = datainformation.data;

training_size_x = 512;
training_size_y = 512;

Test = readtable('template.csv', 'HeaderLines',1,'Delimiter',',');

submissionfile = fopen('Task_2.csv','w');
fprintf(submissionfile,"%s,%s\n","guid/image/axis","value");
for idx = 1:2:size(Test,1)
    aimimage = char(Test{idx,1});
    aimimage = aimimage(1:end-2);
    conf = 0;
    r=30;
    theta = 0;
    for detect = 1:size(labels,1)
        foldername = filepaths{detect}(20:end-15);
        imagename = filepaths{detect}(end-13:end);
        snapshot = [location, foldername, '/', imagename];
        Name = snapshot(19:end-10);
        if strcmp(Name,aimimage) && (labels(detect,6) > conf)
            conf = labels(detect,6);
            img = imread(snapshot);

            xyz = read_bin(strrep(snapshot, '_image.jpg', '_cloud.bin'));
            xyz = reshape(xyz, [], 3)';

            proj = read_bin(strrep(snapshot, '_image.jpg', '_proj.bin'));
            proj = reshape(proj, [4, 3])';

            uv = proj * [xyz; ones(1, size(xyz, 2))];
            uv = uv ./ uv(3, :);

            dist = vecnorm(xyz);

            cur_label = labels(detect,1);
            x_c = labels(detect,2); y_c =labels(detect,3);   %center in training image sizes

            x_scaled = x_c/training_size_x * size(img,2);
            y_scaled = y_c/training_size_y * size(img,1);

            nearest_id = knnsearch(uv(1:2,:)',[x_scaled y_scaled]);
            if dist(nearest_id) < 50
                r = dist(nearest_id);
                theta = atan(xyz(1,nearest_id)/xyz(3,nearest_id))/pi*180;
            end
        end
    end
    
    fprintf(submissionfile,"%s,%.5f\n",char(Test{idx,1}),r);
    fprintf(submissionfile,"%s,%.5f\n",char(Test{idx+1,1}),theta);
    
end

fclose(submissionfile);

function data = read_bin(file_name)
id = fopen(file_name, 'r');
data = fread(id, inf, 'single');
fclose(id);
end
