import torch
from scipy.io import loadmat, savemat
import os
import numpy as np
import sys
from torchmetrics.image import VisualInformationFidelity

vif = VisualInformationFidelity()
algorithmname="VIF_python_pytorch"

def topytorch(image_grey):
    w, h = image_grey.shape
    image_grey_2 = np.empty((1,1,w, h),dtype=image_grey.dtype)
    image_grey_2[0,0,:, :] =  image_grey
    return torch.tensor(image_grey_2, device='cpu', dtype=torch.float32)

directory=sys.argv[1]
directoryoutput=sys.argv[2]
directorybytes = os.fsencode(directory)
if not os.path.exists(directoryoutput+algorithmname+"/"):
    os.mkdir(directoryoutput+algorithmname+"/")

for file in os.listdir(directorybytes):
    if str(file, "utf-8").endswith(".mat") and os.path.isfile(directorybytes+file) and not os.path.isfile(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8")):
        loadedfile=loadmat(directorybytes+file)
        name=loadedfile["name"][0]
        ref_img=topytorch(loadedfile["ref_img"])
        deg_img=topytorch(loadedfile["deg_img"])
        vif_value=float(vif(deg_img, ref_img))
        savemat(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8"), {'algorithmvalue':vif_value,'algorithmname':algorithmname,'name':name})
