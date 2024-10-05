from paq2piq.inference_model import *
from PIL import Image
from scipy.io import loadmat, savemat
import os
import sys

algorithmname="PAQ2PIQ_python"
directory=sys.argv[1]
directoryoutput=sys.argv[2]
directorybytes = os.fsencode(directory)
if not os.path.exists(directoryoutput+algorithmname+"/"):
    os.mkdir(directoryoutput+algorithmname+"/")
    
for file in os.listdir(directorybytes):
    if str(file, "utf-8").endswith(".mat")  and os.path.isfile(directorybytes+file) and not os.path.isfile(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8")):
        loadedfile=loadmat(directorybytes+file)
        name=loadedfile["name"][0]
        deg_img=loadedfile["deg_img"]
        deg_img=deg_img*255
        deg_img_PIL=Image.fromarray(deg_img)
        model = InferenceModel(RoIPoolModel(), './paq2piq/RoIPoolModel-fit.10.bs.120.pth')
        output = model.predict_from_pil_image(deg_img_PIL)
        paq_value=output['global_score']
        savemat(directoryoutput+algorithmname+"/"+algorithmname+str(file, "utf-8"), {'algorithmvalue':paq_value,'algorithmname':algorithmname,'name':name})
