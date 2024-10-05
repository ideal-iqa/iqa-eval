#This code expects a dataset folder, with subfolders for each dataset in
#it. Each dataset subfolder has to contain for each dataset entry a .mat
#file which contains the variables:
# "name": char, contains the name of the dataset entry
# "ref_img": NxM double, contains greyscale reference image, rescaled to 0-1
# "deg_img": NxM double, contains greyscale degraded image, rescaled to 0-1
# Furthermore, for each Algorithm implemented in python, the corresponding 
# virtual environment should be created using the provided requirements.txt file 
# in the relative location ./venv/
# For paq2piq, please download https://github.com/baidut/PaQ-2-PiQ/releases/download/v1.0/RoIPoolModel-fit.10.bs.120.pth and save it in the paq2piq folder.

import os
#Directory where the datasets are stored
datasetdirectory="../datasets/"
#Directory where the results are to be stored
resultsdirectory="../results/"
#The variable datasets is a list of all sub folders in the dataset
#directory to compute the IQA metrics for, e.g. datasets=["folder#1","folder#2","folder#3"];
datasets=["live","live_multi"]
for dataset in datasets:
    if not os.path.exists(resultsdirectory):
        os.mkdir(resultsdirectory)
    if not os.path.exists(resultsdirectory+dataset+"/"):
        os.mkdir(resultsdirectory+dataset+"/")
    algorithmlist=["dists","haarpsi","lpips","paq2piq"]
    for algorithmname in algorithmlist:
        os.system("./"+algorithmname+"/venv/bin/python3 ./"+algorithmname+"/run"+algorithmname+".py "+datasetdirectory+dataset+"/ "+resultsdirectory+dataset+"/")

    algorithmlist=["ssim","psnr","msssim","vif"]
    for algorithmname in algorithmlist:
        os.system("./SSIM_PSNR_MSSSIM_VIF/venv/bin/python3 ./SSIM_PSNR_MSSSIM_VIF/run"+algorithmname+".py "+datasetdirectory+dataset+"/ "+resultsdirectory+dataset+"/")
