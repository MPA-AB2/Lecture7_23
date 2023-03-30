function nazev_fce(slozka_obrazku,neuronka,slozka_kam_to_chces_ulozit)
%NAZEV_FCE Summary of this function goes here
%   Detailed explanation goes here
dataSetDir = slozka_obrazku;%'V:\4_mag\Lecture7_23\public';
imageDir = fullfile(dataSetDir,'im*.png');
imds = imageDatastore(imageDir);

if ~exist('tmp\')
    mkdir("tmp\");
    tempdir = fullfile(dataSetDir,"tmp")
else
  tempdir = fullfile(dataSetDir,"tmp")
  delete("tmp\*");  
end

imageSize=[256 256 3];
%delete("tmp\*");
for i = 1:2:2*length(imds.Files)
    if (i < 10)
    im = imread(strcat('public\im0',num2str(i),'.png'));
    ret = strcat('tmp\cvic0',num2str(i),'.png')
    else
    im = imread(strcat('public\im',num2str(i),'.png'));
    ret = strcat('tmp\cvic',num2str(i),'.png')
    end
    vys = oriz(im,imageSize);
    imwrite(vys,ret)

end


%%
load(neuronka);
%%

imageTest = fullfile(tempdir,'cvic*.png');
imdTest = imageDatastore(imageTest);
vys_pro = semanticseg(imdTest,net);




%%
origDir = fullfile(dataDir,'mask*.png');
orig = imageDatastore(origDir);
imageFiles = dir(strcat(dataDir,'\mask*.png')); 



%delete("res\*");

for i = 1:size(imageFiles,1)
    origin = readimage(orig,i);
    vel_or = size(origin);
    vysled = readimage(vys_pro,i);
    kateg = categorical(classNames);
    konec = oriz(vysled,vel_or);
    realvysledek = zeros(size(konec));
    realvysledek(konec==classNames(1)) = labelIDs(1);
    realvysledek(konec==classNames(2)) = labelIDs(2);
    realvysledek(konec==classNames(3)) = labelIDs(3);
    realvysledek(konec==classNames(4)) = labelIDs(4);
    realvysledek(konec==classNames(5)) = labelIDs(5);
   
    ret = strcat(slozka_kam_to_chces_ulozit,imageFiles(i).name);
    imwrite(uint8(realvysledek),ret);
    
end



end

