import os,sys
import torch,torchvision
import torchio as tio
from random import randrange
# import nibabel as nib
# import matplotlib.pyplot as plt
# import pandas as pd
# import numpy as np
# import cv2


# # Dataloader for cat segmentation
class HIST_Dataset(torch.utils.data.Dataset):

    def __init__(self,imgPath,lblPath,transform=None):
        self.imgPath = imgPath
        self.lblPath = lblPath
        self.transform = transform
        self.imgAnnot = sorted(os.listdir(imgPath))
        self.lblAnnot = sorted(os.listdir(lblPath))
        self.steps = self.imgAnnot.__len__()

    def __len__(self):
        return self.steps
    
    def __getitem__(self, idx):
        # trim = torchvision.transforms.Resize((256,256))
        # tr = torchvision.transforms.Grayscale()
        if self.imgAnnot[idx][-6:-5] == self.lblAnnot[idx][-6:-5]:
            imP = os.path.join(self.imgPath,self.imgAnnot[idx])
            img = torchvision.io.read_image(imP)
            img = img.float()/255
            img = torchvision.transforms.functional.rgb_to_grayscale(img,num_output_channels = 1)
            lblP = os.path.join(self.lblPath,self.lblAnnot[idx])
            lbl = torchvision.io.read_image(lblP)
            lbl = lbl.to(torch.int64)
            # lbl = lbl/255
            # lbl[np.where(lbl<0.9)] = 0
            # lbl[np.where(lbl>=0.9)] = 1
           
            if self.transform:
                sub = tio.Subject(
                    one_image=tio.ScalarImage(tensor=torch.unsqueeze(img,dim=0)),
                    a_segmentation=tio.LabelMap(tensor=torch.unsqueeze(lbl,dim=0)))
                trSub = self.transform(sub)
                img = torch.squeeze(trSub.one_image.data,dim=0)
                lbl = torch.squeeze(trSub.a_segmentation.data,dim=0)
                lbl = lbl.type(torch.LongTensor)
            width = img.shape[1] ## get dimensions of image
            height = img.shape[2]
            xstart = randrange((width-200))
            ystart = randrange((height-200))
            img = img[:,xstart:(xstart+200), ystart:(ystart+200)]
            lbl = lbl[:,xstart:(xstart+200), ystart:(ystart+200)]
            #print([xstart,ystart])
            #print(img.shape)
            #print(lbl.shape)
        else:
            img = None
            lbl = None
            sys.exit('imgName != lblName')
        return img, lbl

