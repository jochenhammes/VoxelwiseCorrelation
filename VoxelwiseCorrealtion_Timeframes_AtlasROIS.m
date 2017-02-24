clear all

%%Evironemt

%Define Output Figure
numberOfFigureCols = 5;
numberOfFigureRows = 3;

% Unit of Size are Voxels. In MNI Space with 79x95x78-matrix, one voxel is 2mm.
smoothingSize = [5 5 5];



%% Filepaths: Find images
pathGreyMatterMask = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/spm_grey_79x95x78.nii';

%load paths to images
pathsToPerfusionStudyFiles;

%% Atlas

pathAtlas = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/Hammers_mith_atlas_n30r83_delivery_Dec16/Hammers_mith_concatenatedRegions/Hammers_mith_concatenatedRegions_79x95_78.nii';
atlas = load_nii(pathAtlas);
%convert numbers in atlas to integers
atlas.img = uint8(atlas.img);

numberOfVOIsInAtlas = 4

VOINames{1} = 'frontal';
VOINames{2} = 'temporal';
VOINames{3} = 'parietal';
VOINames{4} = 'occipital';
VOINames{5} = 'wholeBrain';

outputEntryCounter = 0;

%% Begin with the magic
%for subjectCounter = 1:2
for subjectCounter = 1:size(paths,1)
    
    %Prepare new figure window for current Subject
    %figureList(subjectCounter) = figure;
    %figure(figureList(subjectCounter));
    
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
    greyMatterMask.img = greyMatterMask.img > 0.5; %Apply threshold to gray matter mask.
    
    imageDimensions = size(image1.img);
    
    %% Smooth images
    image1.img = smooth3(image1.img,'box',smoothingSize);
    
    for h = 1:size(currentSubjects,1)
        images2(h).img = smooth3(images2(h).img,'box',smoothingSize);
    end
    
    
    
    l=0;
    h=0;

    %% Analyze Images (single timeframes and sums)
    
    sumImage = image1;
    listOfSummedFrames = [1 1; 2 2; 3 3; 4 4 ; 5 5; 6 6; 7 7 ; 8 8; 9 9; 10 10; ;2 3; 2 4; 2 5; 3 5; 3 6];
    
    for VOICounter = 1:length(VOINames)
        
        if VOICounter < 5
            currentVOIMask = (uint8(greyMatterMask.img) .* uint8(atlas.img == VOICounter)) > 0;
        else
            currentVOIMask = greyMatterMask.img;
        end
    
        %prepare Variable voxelValues for individual calculation of correlation coefficient
        clear voxelValues
        voxelValues = zeros(nnz(greyMatterMask.img),2);
        
        for l = 1:size(listOfSummedFrames,1)
            
            
            disp(l);
            
            %Create Current Sum-Image based on listOfSummedFrames
            sumImage.img = images2(listOfSummedFrames(l,1)).img; %start with first image
            if listOfSummedFrames(l,2) == listOfSummedFrames(l,1)
                disp('no sum');
            else
                for m = (listOfSummedFrames(l,1)+1):listOfSummedFrames(l,2) %add all the images in between consecutively
                    sumImage.img = sumImage.img + images2(m).img;
                end
                
            end
            
            elementCounter = 0;
            
            for i = 1:imageDimensions(1)
                for j = 1:imageDimensions(2)
                    for k = 1:imageDimensions(3)
                        
                        if currentVOIMask(i,j,k) %Apply mask that contains VOI and Gray matter mask
                            elementCounter = elementCounter +1;
                            voxelValues(elementCounter, 1) = image1.img(i,j,k);
                            voxelValues(elementCounter, 2) = sumImage.img(i,j,k);
                        end
                        
                    end
                end
            end
            
            %Create sublot for each  sumImage
            %subplotList(h+l) = subplot(numberOfFigureRows, numberOfFigureCols,h+l);
            %scatter(voxelValues(:,1),voxelValues(:,2), '.');
            %xlim([0 30000]);
            
            
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
            
            currentStartTime = (listOfSummedFrames(l,1)-1)*60;
            currentStopTime = listOfSummedFrames(l,2)*60;
            
            %title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's']);
            %ylabel('AV 1451');
            %xlabel('FDG');
            %t = text(1000,2000,['r=' num2str(round(currentCorrCoeff,3))]);
            
            
            %Save data to struct
            outputEntryCounter = outputEntryCounter + 1;
            
            Correlations(outputEntryCounter).SubjetNumber = subjectCounter;
            Correlations(outputEntryCounter).PatientID = currentPatientID;
            Correlations(outputEntryCounter).VOI = VOINames{VOICounter};
            Correlations(outputEntryCounter).StartTime = currentStartTime;
            Correlations(outputEntryCounter).StopTime = currentStopTime;
            Correlations(outputEntryCounter).CorrCoeff = currentCorrCoeff;
            Correlations(outputEntryCounter).CorrFisherZ = fisherz(currentCorrCoeff);
            Correlations(outputEntryCounter).Slope = currentSlope;
            Correlations(outputEntryCounter).Intercept = currentIntercept;
            Correlations(outputEntryCounter).SmoothingKernelInMM = smoothingSize(1)*2;
            
            
        end
    end
    
end
