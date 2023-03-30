function img = resizeFcnpxds(filename)
%data = load([filename '.png']);
img = imread(filename);
%img = imcrop(img,data.cropData);
img = imresize(img,[400 600]);
end