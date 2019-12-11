clear all; close all; clc;
classes = {0,1,1,1,1,1,1,1,1,3,3,2,2,2,3,0,0,0,2,2,2,2,0};

%%
files = dir('../data-2019/test/*/*_image.jpg');
for idx = 1:size(files,1)
    snapshot = [files(idx).folder, '/', files(idx).name];
    disp(snapshot)

    image_name = [files(idx).folder(70:end),'_', files(idx).name];
    image_name = image_name(1:end-4);
    img = imread(snapshot);

    resized_img = imresize(img,[512,512]);
    imwrite(resized_img, ['./test_large/',image_name,'.jpg']);
end
