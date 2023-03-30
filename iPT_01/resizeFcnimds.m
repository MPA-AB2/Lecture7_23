function img = resizeFcnimds(filename)
%data = load(filename);
img = imread(filename);
%img = imcrop(img,data.cropData);
disp(filename)
% figure
% imshow(img)
img = imresize(img,[400 600]);
figure
imshow(img)
end