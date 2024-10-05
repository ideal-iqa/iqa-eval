from haarPsi import *
from scipy.io import loadmat, savemat
import os
import numpy as np
import sys

algorithmname="HaarPsi_python_tensorflow"

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
        ref_img=ref_img*255
        deg_img=deg_img*255
        haarpsi_value = haar_psi(ref_img, deg_img)[0]
        savemat(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8"), {'algorithmvalue':haarpsi_value,'algorithmname':algorithmname,'name':name})
