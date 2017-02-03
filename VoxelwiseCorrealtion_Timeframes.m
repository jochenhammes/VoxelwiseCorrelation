clear all

%%Evironemt

%Define Output Figure
numberOfFigureCols = 5;
numberOfFigureRows = 3;
figure


%% Filepaths: Find images
pathImage1 = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SampleData/ReuschKlaus/FDG/wFDG-ReKl.nii';
pathImage2 = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SampleData/ReuschKlaus/Tau_fr�h/Full/wrTau_early_ReKl_1.nii';

pathSubjectNormalized = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SampleData/ReuschKlaus/Tau_fr�h/Full/';
subjects = dir(strcat(pathSubjectNormalized,'wrTau_early*.nii'));

pathGreyMatterMask = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/spm_grey_79x95x78.nii';

%% Load images
image1 = load_nii(pathImage1);

for h = 1:size(subjects,1)
    images2(h) = load_nii([pathSubjectNormalized subjects(h).name]);
end

greyMatterMask = load_nii(pathGreyMatterMask);
greyMatterMask.img = greyMatterMask.img > 0.5;

%Don't apply gray matter mask
%greyMatterMask.img = true(size(greyMatterMask.img)); 

imageDimensions = size(image1.img);
voxelValues = zeros(nnz(greyMatterMask.img),2);
%voxelValues = zeros(numel(image1.img),2);



%% Analyze single Timeframes

for h = 1:size(subjects,1)
    
    %run through all voxels of both images
    elementCounter = 0;
    for i = 1:imageDimensions(1)
        for j = 1:imageDimensions(2)
            for k = 1:imageDimensions(3)
                
                if greyMatterMask.img(i,j,k) %Apply gray matter mask
                    elementCounter = elementCounter +1;
                    voxelValues(elementCounter, 1) = image1.img(i,j,k);
                    voxelValues(elementCounter, 2) = images2(h).img(i,j,k);
                end
                
            end
        end
    end
    
    %Create subplot for each Timeslice
    subplot(numberOfFigureRows, numberOfFigureCols,h)
    scatter(voxelValues(:,1),voxelValues(:,2), '.');
    [R, P] = corrcoef(voxelValues(:,1),voxelValues(:,2));
    
    currentCorrCoeff = R(1,2);
    currentCorrP = P(1,2);
    
    currentStartTime = (h-1)*60;
    currentStopTime = h*60;
    
    title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's r=' num2str(currentCorrCoeff) ])
    xlabel('AV 1451')
    ylabel('FDG')
    
    %Save data to struct
    Correlations(h).StartTime = currentStartTime;
    Correlations(h).StopTime = currentStopTime;
    Correlations(h).currentCorrCoeff = currentCorrCoeff;
    Correlations(h).currentCorrP = currentCorrP;
    
end


%% Analyze Sum-Images

sumImage = image1;
listOfSums = [2 3; 3 4; 4 5; 3 5; 5 6];

for l = 1:size(listOfSums,1)
    
    %Create Current Sum-Image based on listOfSums
    sumImage.img = images2(listOfSums(l,1)).img + images2(listOfSums(l,2)).img;
    
    elementCounter = 0;
    
    for i = 1:imageDimensions(1)
        for j = 1:imageDimensions(2)
            for k = 1:imageDimensions(3)
                
                if greyMatterMask.img(i,j,k)
                    elementCounter = elementCounter +1;
                    voxelValues(elementCounter, 1) = image1.img(i,j,k);
                    voxelValues(elementCounter, 2) = sumImage.img(i,j,k);
                end
                
            end
        end
    end
    
    %Create sublot for each  sumImage
    subplot(numberOfFigureRows, numberOfFigureCols,h+l)
    scatter(voxelValues(:,1),voxelValues(:,2), '.');
    [R, P] = corrcoef(voxelValues(:,1),voxelValues(:,2));
    
    currentCorrCoeff = R(1,2);
    currentCorrP = P(1,2);
    
    currentStartTime = (listOfSums(l,1)-1)*60;
    currentStopTime = listOfSums(l,2)*60;
    
    title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's r=' num2str(currentCorrCoeff) ])
        
    xlabel('AV 1451')
    ylabel('FDG')

    %Save data to struct
    Correlations(h+l).StartTime = currentStartTime;
    Correlations(h+l).StopTime = currentStopTime;
    Correlations(h+l).currentCorrCoeff = currentCorrCoeff;
    Correlations(h+l).currentCorrP = currentCorrP;
    
end



