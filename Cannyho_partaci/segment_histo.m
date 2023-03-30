function segment_histo(path_to_images, path_of_results)

folder=path_to_images;
I=dir(fullfile(folder,'*.png'));
for k=1:numel(I)
  filename=fullfile(folder,I(k).name);
  images{k}=imread(filename);
end

pulka = length(images)/2;
gt_masks = images(pulka+1:end);
images = images(1:pulka);

for i = 1:length(images)
    im = rgb2gray(images{1,i});
    B3 = zeros(size(im,1),size(im,2));
    B3(im > 205) = 4;
    B3((160 < im) & (im<=205)) = 2;
    B3((20 < im) & (im<=160)) = 1;
    B3(im <= 20) = 3;
    B3 = imfill(B3,'holes');
    
    name = I(i+pulka).name;
    B3 = uint8(B3);
    imwrite(B3,strcat(path_of_results,'\',name));
end
end