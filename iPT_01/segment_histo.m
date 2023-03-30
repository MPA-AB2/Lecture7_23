function  segment_histo(path_to_images, path_of_results)
for a = 1: 2 : 41
    num = num2str([a].','%02d')
    img{a}=imread([path_to_images '\im' num '.png'])
    masks{a}=imread(['mask' num '.png'])
    
end
%%
for iter = 1: 2 : 41

     im = img{iter};
     im_anno = masks{iter};
    
    im_CB = rgb2gray(im2double(im));
    
    im_R = im;
    im_R(:,:,2:3) = [];
    
    im_G = im;
    im_G(:,:,[1,3]) = [];
    
    im_B = im;
    im_B(:,:,1:2) = [];
    
    
    %%
    im_double = im2double(im);
    im_R_double = im2double(im_R);
    
    [h,x] = hist(im_double(:),256);
    [h_R,x_R] = hist(im_R_double(:),256);
    
    im_R_eq = histeq(im_R_double);
    [h_R_eq,x_R_eq] = hist(im_R_eq(:),256);
    
    %rozmazani
    im_R_eq_med = im_R_eq;
    a = 1;
    while a <= 2
        im_R_eq_med = medfilt2(im_R_eq_med, [8 8]);
        a = a+1;
    end
    [h_R_eq_med,x_R_eq_med] = hist(im_R_eq_med(:),256);
    

    
    %%
    thresh = multithresh(im_R_eq_med,4);
    labels = imquantize(im_R_eq_med,thresh);
    labelsRGB = label2rgb(labels);
    
    
    
    %%
    [x,y,z] = size(labelsRGB);
    newim = zeros(x,y);
    modra = labelsRGB(:,:,3);
    
    
    for i = 1:x
        for j = 1:y
            if modra(i,j) > 100
                newim(i,j)=1;
            end 
        end
    end
    

    
    %%
    %%
    SE = strel("disk",3);
    im_R_eq_med_T_uprava = imclose(newim,SE);

    %%
    
    bin = imbinarize(newim);
    bin_inv = bin;
    bin_inv(bin == 1) = 0;
    bin_inv(bin == 0) = 1;
    bin_smazane = bwareaopen(bin_inv,2500);
    

    
    %%
    bin_inv_inv = bin_inv;
    bin_inv_inv(bin_smazane == 1) = 0;
    bin_inv_inv(bin_smazane == 0) = 1;
    
    bin_smazane_smazane = bwareaopen(bin_inv_inv,15000);

    
    %%
    SE = strel("disk",5);
    im_final = imclose(bin_smazane_smazane,SE);

    
    %% vyhlazení 
    windowSize = 20;
    kernel = ones(windowSize) / windowSize ^ 2;
    blurryImage = conv2(single(im_final), kernel, 'same');
    binaryImage = blurryImage > 0.5; % Rethreshold
       
    
    finim = zeros(x,y);
    finim = uint8(finim);
    
    cervena = labelsRGB(:,:,1);
    redmed = medfilt2(cervena,[15,15]);
      redmed=  im2double(redmed); 
    
    for i = 1:x
        for j = 1:y
             if   redmed(i,j) == 1 
                finim(i,j)=3;
            end 
            if binaryImage(i,j) == 1
                finim(i,j)=1;
            elseif binaryImage(i,j) == 0
                finim(i,j)=2;
            end 
        end
    end
    
    subplot(221)
    imshow(binaryImage)
    subplot(222)
    imshow(im_final)
    subplot 223
    imshow(im_anno,[])
    title('Refernce')
    subplot 224
    imshow(finim,[])


num = num2str([iter].','%02d')
cesta = [path_of_results '\mask',num,'.png']
imwrite(finim, cesta)
end

[dice_scores] = evaluate_segmentation(path_to_images, path_of_results)
end
