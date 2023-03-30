addpath(genpath('V:\AB2'));

%%
im=imread('im01.png');
figure
imshow(im)
gt=imread('mask01.png');
figure
imshow(gt,[])

%%


%%





resizeFcn = @(x) imresize(x, targetSize);

imageSize = [400 600 3];


numClasses = 5;
encoderDepth = 3;
lgraph = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth)

plot(lgraph)

% dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
% imageDir = fullfile(dataSetDir,'trainingImages');
% labelDir = fullfile(dataSetDir,'trainingLabels');

imds = imageDatastore('V:\AB2\Lecture7_data\public');
inputSize = [400 600];
imds.ReadFcn = @(loc)imresize(imread(loc),inputSize);
%resizeFcnimds = @(x) imresize(x,[400 600]);
%imdsResized = transform(imds, resizeFcnimds);

%imds.ReadFcn = @resizeFcnimds;




classNames = ["background","tumour","stroma","necrosis","fat"]; % background,tumour,stroma,necrosis,fat
labelIDs   = [0 1 2 3 4];

pxds = pixelLabelDatastore('V:\AB2\Lecture7_data\masks',classNames,labelIDs);
inputSize = [400 600];
pxds.ReadFcn = @(loc)imresize(imread(loc),inputSize);

%resizeFcnpxds = @(x) imresize(x,[400 600]);
%pxdsResized = transform(pxds, resizeFcnpxds);

%pxds.ReadFcn = @resizeFcnpxds;


ds = combine(imds,pxds);

options = trainingOptions('adam', ...
    'InitialLearnRate',1e-3, ...
    'MiniBatchSize',2, ...
    'MaxEpochs',4, ...
    'VerboseFrequency',1);

net = trainNetwork(ds,lgraph,options)
save ('netv4','net');


%%
pxdsResults = semanticseg(imds,net, ...
    'WriteLocation',pwd, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxds,'Verbose',false);

metrics.DataSetMetrics

metrics.ClassMetrics


%%

for a = 1: 2 : 41
    num = num2str([a].','%02d');
    img{a}=imread(['V:\AB2\Lecture7_data\public\im' num '.png']);
%     masks{a}=imread(['mask' num '.png'])
    


im=img{a};
imsize=size(im);
C = semanticseg(imresize(im, [400 600]),net);
A=zeros(size(C));
for i=1:200
    for j=1:296
        if C(i,j)=="background"
            A(i,j)=0;
        elseif C(i,j)=="tumour"
            A(i,j)=1;
            elseif C(i,j)=="stroma"
            A(i,j)=2;
            elseif C(i,j)=="necrosis"
            A(i,j)=3;
        else
            A(i,j)=4;
        end
    end
end

B=imresize(A,imsize(1,1:2));
B=round(B);
imshow(B,[])

B = uint8(B);
% imshow(B)

cesta = ['V:\AB2\Lecture7_data\my_mask\mask',num,'.png']
imwrite(B, cesta)
end

%%
cesta_moje = 'V:\AB2\Lecture7_data\my_mask'
cesta_stara = 'V:\AB2\Lecture7_data\masks'

[dice_scores] = evaluate_segmentation(cesta_stara, cesta_moje)


%%
obr1 = imread('V:\AB2\Lecture7_data\my_mask\mask09.png')
obr2=imread('V:\AB2\Lecture7_data\masks\mask09.png')

subplot 211
imshow(obr1,[])
subplot 212
imshow(obr2,[])