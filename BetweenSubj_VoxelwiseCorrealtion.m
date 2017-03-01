clear all


%% Filepaths

outputPath = '/Volumes/MMNI_RAID/RAID_MMNI/BatchScriptsMatlab/VoxelwiseCorrelation/';

pathGreyMatterMask = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/spm_grey_79x95x78.nii';
    
greyMatterMask = load_nii(pathGreyMatterMask);
greyMatterMask.img = greyMatterMask.img > 0.1; %Apply threshold to gray matter mask.
    
imageDimensions = size(greyMatterMask.img);

% paths to images

paths{1,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_EbFr.nii';
paths{1,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_EbFr.nii';
paths{2,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_EsEd.nii';
paths{2,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_EsEd.nii';
paths{3,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_GeOl.nii';
paths{3,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_GeOl.nii';
paths{4,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_LoBe.nii';
paths{4,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_LoBe.nii';
paths{5,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_MoHi.nii';
paths{5,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_MoHi.nii';
paths{6,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_NeMa.nii';
paths{6,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_NeMa.nii';
paths{7,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_PeAn.nii';
paths{7,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_PeAn.nii';
paths{8,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_ReKl.nii';
paths{8,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_ReKl.nii';
paths{9,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_SaPe.nii';
paths{9,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_SaPe.nii';
paths{10,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_SoHa.nii';
paths{10,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_SoHa.nii';
paths{11,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_StIn.nii';
paths{11,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_StIn.nii';
paths{12,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_ToTh.nii';
paths{12,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_ToTh.nii';
paths{13,1} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/s8SUVR_Sum_60-300_Tau_WeVo.nii';
paths{13,2} = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/SUVR_wFDG_WeVo.nii';


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

%% Load Images
for subjectCounter = 1:size(paths,1)
    
    %% Load images
    imagesEarlyTau(subjectCounter) = load_nii(paths{subjectCounter,1});
    imagesFDG(subjectCounter) = load_nii(paths{subjectCounter,2});
  
end

%% Prepare OutputFiles
correlationMatrix = load_nii(pathGreyMatterMask);
correlationMatrix.img = correlationMatrix.img .*0;
pValueMatrix = correlationMatrix;



%% Calculate Voxelwise Between Subject Correlations
elementCounter = 0;

for i = 1:imageDimensions(1)
    disp(i);
    
    for j = 1:imageDimensions(2)
        for k = 1:imageDimensions(3)
            
            if greyMatterMask.img(i,j,k) %Apply mask that contains VOI and Gray matter mask
                elementCounter = elementCounter +1;
                
                % Prepare values for each subject 
                currentVoxelValues = zeros(size(paths,1),2);
                for subjectCounter = 1:size(paths,1)
                    currentVoxelValues(subjectCounter,1) = imagesEarlyTau(subjectCounter).img(i,j,k);
                    currentVoxelValues(subjectCounter,2) = imagesFDG(subjectCounter).img(i,j,k);
                end
                % Calculate Between Subjeckt Correlation
                [R, P] = corrcoef(currentVoxelValues(:,1),currentVoxelValues(:,2));
                currentCorrCoeff = R(1,2);
                currentCorrP = P(1,2);
                
                correlationMatrix.img(i,j,k) = currentCorrCoeff;
                pValueMatrix.img(i,j,k) = currentCorrP;

            end
            
        end
    end
end


%% Save output

%Fisher's Z Transformation of Rs
fisherZMatrix = correlationMatrix;
fisherZMatrix.img = fisherz(correlationMatrix.img);

save_nii(correlationMatrix, [outputPath 'BetweenSubjCorrelationR.nii']);
save_nii(pValueMatrix, [outputPath 'BetweenSubjCorrelationP.nii']);
save_nii(fisherZMatrix, [outputPath 'BetweenSubjCorrelationFisherZ.nii']);
