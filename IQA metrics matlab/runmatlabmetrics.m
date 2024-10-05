%This code expects a dataset folder, with subfolders for each dataset in
%it. Each dataset subfolder has to contain for each dataset entry a .mat
%file which contains the variables:
% "name": char, contains the name of the dataset entry
% "ref_img": NxM double, contains greyscale reference image, rescaled to 0-1
% "deg_img": NxM double, contains greyscale degraded image, rescaled to 0-1

clear();
%set boolean true (1) or false (0) for each IQA metric to set wether it
%should be computed
runIWSSIM=1;
runSSIM=1;
runMSSSIM=1;
runPSNR=1;
runDISTS=1;
runDSS=1;
runFSIM=1;
runGMSD=1;
runHaarPSI=1;
runMDSI=1;
runniqe=1;
runVSI=1;
runBRISQUE=0; %only works on Windows
%Directory where the datasets are stored
datasetdirectory="../datasets/";
%Directory where the results are to be stored
resultsdirectory="../results/";
%The variable datasets is a list of all sub folders in the dataset
%directory to compute the IQA metrics for, e.g. datasets=["folder#1","folder#2","folder#3"];
datasets=["live","live_multi"];
for i_dataset=1:length(datasets)
    datasetpath=datasetdirectory+datasets(i_dataset)+"/";
    datasetfiles=dir(fullfile(datasetpath,"*.mat"));
    disp(length(datasetfiles))
    disp(datasets(i_dataset))
    resultspath=resultsdirectory+datasets(i_dataset)+"/";
    mkdir(resultspath+"IW-SSIM_matlab/");
    mkdir(resultspath+"SSIM_matlab/");
    mkdir(resultspath+"MS-SSIM_matlab/");
    mkdir(resultspath+"PSNR_matlab/");
    mkdir(resultspath+"DISTS_matlab/");
    mkdir(resultspath+"DSS_matlab/");
    mkdir(resultspath+"FSIM_matlab/");
    mkdir(resultspath+"GMSD_matlab/")
    mkdir(resultspath+"HaarPSI_matlab/");
    mkdir(datasetpath+"BRISQUE_matlab/");
    mkdir(resultspath+"MDSI_matlab/");
    mkdir(resultspath+"FSIM_matlab/");
    mkdir(resultspath+"niqe_matlab/");
    mkdir(resultspath+"VSI_matlab/");
    if runBRISQUE
        addpath("BRISQUE/") 
    end
    if runIWSSIM
        addpath("IW-SSIM/")
        addpath("IW-SSIM/matlabPyrTools/")
        addpath("IW-SSIM/matlabPyrTools/MEX")
    end
    for i_file =1:length(datasetfiles)
        file_name=datasetfiles(i_file);
        if mod(i_file,1000)==0
            display(i_file)
        end
        load(datasetpath+file_name.name)
        ref_img_double=ref_img;
        deg_img_double=deg_img;
        ref_img_color_double=cat(3,ref_img_double,ref_img_double,ref_img_double);
        deg_img_color_double=cat(3,deg_img_double,deg_img_double,deg_img_double);
        ref_img_double255=double(ref_img_double*(2^8-1));
        deg_img_double255=double(deg_img_double*(2^8-1));
        ref_img_color_double255=double(ref_img_color_double*(2^8-1));
        deg_img_color_double255=double(deg_img_color_double*(2^8-1));
        ref_img_uint8=uint8(ref_img_double*(2^8-1));
        deg_img_uint8=uint8(deg_img_double*(2^8-1));
        ref_img_color_uint8=uint8(ref_img_color_double*(2^8-1));
        deg_img_color_uint8=uint8(deg_img_color_double*(2^8-1));
        if ~any(any(mod(ref_img*(2^8-1),1)))
            ref_img_uint=uint8(ref_img_double*(2^8-1));
            deg_img_uint=uint8(deg_img_double*(2^8-1));
            ref_img_color_uint=uint8(ref_img_color_double*(2^8-1));
            deg_img_color_uint=uint8(deg_img_color_double*(2^8-1));
        elseif ~any(any(mod(ref_img*(2^16-1),1)))
            ref_img_uint=uint16(ref_img_double*(2^16-1));
            deg_img_uint=uint16(deg_img_double*(2^16-1));
            ref_img_color_uint=uint16(ref_img_color_double*(2^16-1));
            deg_img_color_uint=uint16(deg_img_color_double*(2^16-1));
        end
        %
        algorithmname='IW-SSIM_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runIWSSIM && ~isfile(tempfilename)
            algorithmvalue=iwssim(ref_img_uint,deg_img_uint);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end
        algorithmname='SSIM_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runSSIM && ~isfile(tempfilename)
            algorithmvalue=ssim(deg_img_uint,ref_img_uint);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='MS-SSIM_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runMSSSIM&& ~isfile(tempfilename)
            algorithmvalue=multissim(deg_img_uint,ref_img_uint);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='PSNR_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runPSNR&& ~isfile(tempfilename)
            algorithmvalue=psnr(deg_img_uint,ref_img_uint);
            algorithmname='PSNR_matlab';
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='DISTS_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runDISTS&& ~isfile(tempfilename)
            addpath("DISTS/")
            net_params = load('DISTS/weights/net_param.mat');
            weights = load('DISTS/weights/alpha_beta.mat');
            resize_img = 0;
            use_gpu = 0;
            algorithmvalue=DISTS(ref_img_double255, deg_img_double255,net_params,weights, resize_img, use_gpu);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end
        algorithmname='DSS_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runDSS&& ~isfile(tempfilename)
            addpath("DSS/") %input greyscale, check 0-255 or 0-1, probably doesnt matter, check why uint
            algorithmvalue=dss_index(deg_img_uint,ref_img_uint);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='FSIM_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runFSIM&& ~isfile(tempfilename)
            addpath("FSIM/")% gray-scale images, their dynamic range should be 0-255.
            algorithmvalue=FeatureSIM(ref_img_double255,deg_img_double255);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='GMSD_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runGMSD&& ~isfile(tempfilename)
            addpath("GMSD/")  %(grayscale image, double type, 0~255)
            algorithmvalue=GMSD(ref_img_double255,deg_img_double255);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='HaarPSI_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runHaarPSI&& ~isfile(tempfilename)
            addpath("HaarPSI/") %(grayscale image,  0~255)
            algorithmvalue=HaarPSI(ref_img_double255,deg_img_double255);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='BRISQUE_matlab';
        tempfilename=datasetpath+algorithmname+"/"+algorithmname+file_name.name;
        if runBRISQUE && ~isfile(tempfilename)
            algorithmvalue=brisquescore(deg_img_uint);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end        

        algorithmname='MDSI_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runMDSI&& ~isfile(tempfilename)
            addpath("MDSI/") %color, different results for 0~1, 0~255, 0~255 results seem to be reasonable
            algorithmvalue=MDSI(ref_img_color_double255,deg_img_color_double255);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='niqe_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runniqe&& ~isfile(tempfilename)
            addpath("niqe/") % probably 0~255, for color double nan when double -> double255 gray?
            load modelparameters.mat

            blocksizerow    = 96;
            blocksizecol    = 96;
            blockrowoverlap = 0;
            blockcoloverlap = 0;

            algorithmvalue=computequality(deg_img_double255,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap, ...
                mu_prisparam,cov_prisparam);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end

        algorithmname='VSI_matlab';
        tempfilename=resultspath+algorithmname+"/"+algorithmname+file_name.name;
        if runVSI&& ~isfile(tempfilename)
            addpath("VSI/")%color, 0~255
            algorithmvalue=VSI(ref_img_color_double255,deg_img_color_double255);
            save(tempfilename,"algorithmvalue","algorithmname","name");
        end
    end
end
