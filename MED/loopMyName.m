%function ave = loopMyName(pathToPublic)
    %part to delete
    clear all; close all; clc;
    pathToPublic = "V:\Ladicky\AB2\cv7\public";
    %part to delete end

    imageFiles = dir(strcat(pathToPublic,'\*.png')); 
    for i=1:size(imageFiles,1)/2
        %string magic
        thisImage = strcat(pathToPublic,'\',imageFiles(i).name);    
        disp(thisImage);
        thisNumber = imageFiles(i).name(3:end);
        thisMakeName = strcat(pathToPublic,'\','mask',thisNumber);
        disp(thisMakeName);

        %loading image and corresponding mask
        thisImage = imread(thisImage);
        thisMask = imread(thisMakeName);
    end
%end