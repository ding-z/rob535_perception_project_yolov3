clear all; close all; clc;
files = dir('./images/*_image.jpg');

seed = 64594;
rng(seed);

Number = size(files,1);
train_percent = 0.8;
random_idx = randperm(Number)';

train_idx = floor(Number * train_percent);
trainfile = fopen('train.part','w');
for idx = 1:train_idx
    filepath = [files(random_idx(idx)).folder(end-6:end),'\',files(random_idx(idx)).name];
    filepath = strrep(filepath,'\','/');
    fprintf(trainfile,'%s\n',filepath);
end
fclose(trainfile);

validatefile = fopen('valid.part','w');
for idx = train_idx+1:Number
    filepath = [files(random_idx(idx)).folder(end-6:end),'\',files(random_idx(idx)).name];
    filepath = strrep(filepath,'\','/');
    fprintf(validatefile,'%s\n',filepath);
end
fclose(validatefile);