dataSetDir = 'V:\4_mag\Lecture7_23\tmp';
imageDir = fullfile(dataSetDir,'cvic*.png');
labelDir = fullfile(dataSetDir,'cmask*.png');

%%
imds = imageDatastore(imageDir);
classNames = ["background","tumour","stroma","necrosis","fat"];
labelIDs   = [0 1 2 3 4];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);
%%

%imageSize = [256 256 3];
numClasses = 5;
encoderDepth = 2;
lgraph = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth);


ds = combine(imds,pxds);
options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-4, ...
    'MaxEpochs',20, ...
    'VerboseFrequency',10);

%%
net = trainNetwork(ds,lgraph,options);
save('myaNet.mat',"net")

%%
imageTest = fullfile(dataSetDir,'cvic*.png');
imdTest = imageDatastore(imageTest);
vys_pro = semanticseg(imdTest,net);


%%
dataDir = 'V:\4_mag\Lecture7_23\public';
origDir = fullfile(dataDir,'mask*.png');
orig = imageDatastore(origDir);
imageFiles = dir(strcat(dataDir,'\mask*.png')); 

delete("res\*");

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
   
    ret = strcat('res\',imageFiles(i).name);
    imwrite(uint8(realvysledek),ret);
    
end

[dice_scores] = evaluate_segmentation('V:\4_mag\Lecture7_23\public', 'V:\4_mag\Lecture7_23\res')

%%
I = read(imdTest);
C = read(vys_pro);

B = labeloverlay(I,C{1});
figure
imshow(B)


%% to je pro správně velké obrázky

imageSize=[256 256 3];
delete("tmp\*");
for i = 1:2:2*length(pxds.Files)
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

% for i = 1:2:2*length(pxds.Files)
%     if (i < 10)
%     im = imread(strcat('public\mask0',num2str(i),'.png'));
%     ret = strcat('tmp\cmask0',num2str(i),'.png')
%     else
%     im = imread(strcat('public\mask',num2str(i),'.png'));
%     ret = strcat('tmp\cmask',num2str(i),'.png')
%     end
%     vys = oriz(im,imageSize);
%     imwrite(vys,ret)
% end
