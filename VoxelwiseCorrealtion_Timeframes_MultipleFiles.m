clear all

%%Evironemt

%Define Output Figure
numberOfFigureCols = 5;
numberOfFigureRows = 3;

% Unit of Size are Voxels. In MNI Space with 79x95x78-matrix, one voxel is 2mm.
smoothingSize = [5 5 5];



%% Filepaths: Find images
pathGreyMatterMask = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/spm_grey_79x95x78.nii';
pathAtlas = '/Users/hammesj/Downloads/Tau_RAW_abNov2016/Template/Hammers_mith_concatenatedRegions_79x95_78.nii';


pathsToPerfusionStudyFiles;


%for subjectCounter = 8:8
for subjectCounter = 1:size(paths,1)
    
    %Prepare new figure window for current Subject
    figureList(subjectCounter) = figure;
    figure(figureList(subjectCounter));
    
    currentSubjects = dir(strcat(paths{subjectCounter,2},'wrTau_early*.nii'));
    
    %extract filename of first entry of currentSubjects to save as
    %patient-identifier
    currentPatientID = currentSubjects(1).name;
    figureList(subjectCounter).Name = currentPatientID;
    
    
    %% Load images
    image1 = load_nii(paths{subjectCounter,1});
    
    for h = 1:size(currentSubjects,1)
        images2(h) = load_nii([paths{subjectCounter,2} currentSubjects(h).name]);
    end
    
    greyMatterMask = load_nii(pathGreyMatterMask);
    greyMatterMask.img = greyMatterMask.img > 0.5;
    
    %Don't apply gray matter mask
    %greyMatterMask.img = true(size(greyMatterMask.img));
    
    imageDimensions = size(image1.img);
    voxelValues = zeros(nnz(greyMatterMask.img),2);
    %voxelValues = zeros(numel(image1.img),2);
    
    %% Smooth images
    image1.img = smooth3(image1.img,'box',smoothingSize);
    
    for h = 1:size(currentSubjects,1)
        images2(h).img = smooth3(images2(h).img,'box',smoothingSize);
    end
    
    %% Analyze single Timeframes
    
    l=0;
    
    for h = 1:size(currentSubjects,1)
        
        disp(h+l);
        
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
        subplotList(h+l) = subplot(numberOfFigureRows, numberOfFigureCols,h+l);
        scatter(voxelValues(:,1),voxelValues(:,2), '.');
        xlim([0 30000]);
        %ylim([0 35000]);
        
        
        [R, P] = corrcoef(voxelValues(:,1),voxelValues(:,2));
        currentCorrCoeff = R(1,2);
        currentCorrP = P(1,2);
        
        %Calculate linear regression
        x = voxelValues(:,1);
        y = voxelValues(:,2);
        
        currenRegression = [ones(length(x),1) ,reshape(x,length(x),1)] \ reshape(y,length(y),1);
        currentSlope = currenRegression(2);
        currentIntercept = currenRegression(1);
        
        %draw regression line
        %refline(currentSlope,currentIntercept);
        
        currentStartTime = (h-1)*60;
        currentStopTime = h*60;
        
        title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's']);
        ylabel('AV 1451');
        xlabel('FDG');
        t = text(1000,1000,['r=' num2str(round(currentCorrCoeff,3))]);
        
        %Save data to struct
        outputEntryCounter = h + l + (subjectCounter - 1)*15;
        
        Correlations(outputEntryCounter).SubjetNumber = subjectCounter;
        Correlations(outputEntryCounter).PatientID = currentPatientID;
        Correlations(outputEntryCounter).StartTime = currentStartTime;
        Correlations(outputEntryCounter).StopTime = currentStopTime;
        Correlations(outputEntryCounter).CorrCoeff = currentCorrCoeff;
        Correlations(outputEntryCounter).CorrFisherZ = fisherz(currentCorrCoeff);
        Correlations(outputEntryCounter).Slope = currentSlope;
        Correlations(outputEntryCounter).Intercept = currentIntercept;
        Correlations(outputEntryCounter).SmoothingKernelInMM = smoothingSize(1)*2;
        
    end
    
    
    %% Analyze Sum-Images
    
    sumImage = image1;
    listOfSums = [2 3; 2 4; 2 5; 3 5; 3 6];
    
    for l = 1:size(listOfSums,1)
        
        
        disp(h+l);
        
        %Create Current Sum-Image based on listOfSums
        %sumImage.img = images2(listOfSums(l,1)).img + images2(listOfSums(l,2)).img;
        
        sumImage.img = images2(listOfSums(l,1)).img; %start with first image
        for m = (listOfSums(l,1)+1):listOfSums(l,2) %add all the images in between consecutively
            sumImage.img = sumImage.img + images2(m).img;
        end
        
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
        subplotList(h+l) = subplot(numberOfFigureRows, numberOfFigureCols,h+l);
        scatter(voxelValues(:,1),voxelValues(:,2), '.');
        xlim([0 30000]);
        
        
        [R, P] = corrcoef(voxelValues(:,1),voxelValues(:,2));
        currentCorrCoeff = R(1,2);
        currentCorrP = P(1,2);
        
        %Calculate linear regression
        x = voxelValues(:,1);
        y = voxelValues(:,2);
        
        currenRegression = [ones(length(x),1) ,reshape(x,length(x),1)] \ reshape(y,length(y),1);
        currentSlope = currenRegression(2);
        currentIntercept = currenRegression(1);
        
        %draw regression line
        %refline(currentSlope,currentIntercept);
        
        currentStartTime = (listOfSums(l,1)-1)*60;
        currentStopTime = listOfSums(l,2)*60;
        
        title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's']);
        ylabel('AV 1451');
        xlabel('FDG');
        t = text(1000,2000,['r=' num2str(round(currentCorrCoeff,3))]);
        
        
        %Save data to struct
        outputEntryCounter = h + l + (subjectCounter - 1)*15;
        
        Correlations(outputEntryCounter).SubjetNumber = subjectCounter;
        Correlations(outputEntryCounter).PatientID = currentPatientID;
        Correlations(outputEntryCounter).StartTime = currentStartTime;
        Correlations(outputEntryCounter).StopTime = currentStopTime;
        Correlations(outputEntryCounter).CorrCoeff = currentCorrCoeff;
        Correlations(outputEntryCounter).CorrFisherZ = fisherz(currentCorrCoeff);
        Correlations(outputEntryCounter).Slope = currentSlope;
        Correlations(outputEntryCounter).Intercept = currentIntercept;
        Correlations(outputEntryCounter).SmoothingKernelInMM = smoothingSize(1)*2;
        
        
    end
    
end
