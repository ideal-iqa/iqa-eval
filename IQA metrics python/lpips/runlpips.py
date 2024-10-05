import lpips
from scipy.io import loadmat, savemat
import os
import numpy as np
import torch
import sys

loss_fn = lpips.LPIPS(net='alex')
algorithmname="LPIPS_python"

def GREYtoRGB(image_grey):
    w, h = image_grey.shape
    image_rgb = np.empty((1,3,h, w),dtype=image_grey.dtype)
    image_rgb[0,0,:, :] =  image_grey.T
    image_rgb[0,1,:, :] =  image_grey.T
    image_rgb[0,2,:, :] =  image_grey.T
    return torch.tensor(image_rgb, device='cpu', dtype=torch.float32)
    

directory=sys.argv[1]
directoryoutput=sys.argv[2]
directorybytes = os.fsencode(directory)
if not os.path.exists(directoryoutput+algorithmname+"/"):
    os.mkdir(directoryoutput+algorithmname+"/")

for file in os.listdir(directorybytes):
    if str(file, "utf-8").endswith(".mat")  and os.path.isfile(directorybytes+file) and not os.path.isfile(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8")):
        loadedfile=loadmat(directorybytes+file)
        name=loadedfile["name"][0]
        ref_img=loadedfile["ref_img"]
        deg_img=loadedfile["deg_img"]
        ref_img=ref_img*2-1
        deg_img=deg_img*2-1
        ref_img_color=GREYtoRGB(ref_img)
        deg_img_color=GREYtoRGB(deg_img)
        lpips_value = loss_fn.forward(ref_img_color, deg_img_color).detach().numpy()[0,0,0,0] 
        savemat(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8"), {'algorithmvalue':lpips_value,'algorithmname':algorithmname,'name':name})
