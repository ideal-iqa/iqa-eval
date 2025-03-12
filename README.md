# IQA-eval

This repository contains a collection of several IQA metrics in Python (SSIM, PSNR, MS-SSIM, VIF, DISTS, HaarPSI, LPIPS, PaQ2PiQ) and Matlab (SSIM, PSNR, MS-SSIM, IW-SSIM, DISTS, DSS, FSIM, GMSD, HaarPSI, MDSI, NIQE, VSI, BRISQUE) used in the paper [A study on the adequacy of common IQA measures for medical images](https://arxiv.org/abs/2405.19224) for several datasets.

If you use this code, please cite the paper:
```
@InProceedings{breger2024study,
      title={A study on the adequacy of common IQA measures for medical images}, 
      author={Anna Breger and Clemens Karner and Ian Selby and Janek Gröhl and Sören Dittmer and Edward Lilley and Judith Babar and Jake Beckford and Timothy J Sadler and Shahab Shahipasand and Arthikkaa Thavakumar and Michael Roberts and Carola-Bibiane Schönlieb},
      year={2024},
      eventtitle={Medical Imaging and Computer-Aided Diagnosis (MICAD) 2024},
      series={Springer Lecture Notes in Electrical Engineering},
      venue={Manchester, UK}
}
```

## How to use this code

First, store the dataset in the dataset folder, with subfolders for each dataset, e.g. "./datasets/DATASETNAME/". Each dataset subfolder has to contain for each dataset entry a .mat file which contains the variables:
* "name": char, The name of this dataset entry, e.g. the filename
* "ref_img": NxM double,  2D Array containing a grayscale reference image, rescaled to 0-1
* "deg_img": NxM double,  2D Array containing a grayscale degraded image, rescaled to 0-1

If several annotations for a dataset are available, they have to be saved as separate .csv files in "./annotations/DATASETNAME/", e.g. as "./annotations/DATASETNAME/ANNOTATIONS1.csv" and "./annotations/DATASETNAME/ANNOTATIONS2.csv". The .csv files must contain a column called "filename", which entries is equal to the name provided in the .mat dataset files and a column "overall_quality", which contains the rating.

Then, to run the metrics, execute "./IQA metrics python/runpythonmetrics.py" and "./IQA metrics matlab/runmatlabmetrics.m". For the python metrics, it is necessary to create a virtual environment for each metric in  "./IQA metrics python/METRICNAME/venv/" and for the file "./IQA metrics python/runpythonmetrics.py" in "./IQA metrics python/venv/". The necessary requirements.txt files are provided in each folder.

Finally, execute the file "./compute correlation/compute_correlation.ipynb" using the provided environment file "./compute correlation/requirements.txt" to compute the correlation of the computed IQA metrics and the annotations.

In this repository, we provide annotations for the datasets:
* [LIVE Image Quality Assessment Database Release 2](http://live.ece.utexas.edu/research/quality), converted to grayscale  with the in-built MATLAB function mat2gray
* [LIVE Multiply Distorted Image Quality Database](https://live.ece.utexas.edu/research/Quality/live_multidistortedimage.html), converted to grayscale  with the in-built MATLAB function mat2gray

