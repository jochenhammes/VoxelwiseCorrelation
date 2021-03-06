clear all


pathImage1 = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SampleData/Sander_Peter/Tau_frueh/0-180/wTau_0-180_SP.nii';
pathImage2 = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SampleData/Sander_Peter/FDG/wFDG_SP.nii';
pathGreyMatterMask = '/Volumes/MMNI_RAID/RAID_MMNI/Templates/spm_grey_79x95x78.nii';

%Load images
image1 = load_nii(pathImage1);
image2 = load_nii(pathImage2);
greyMatterMask = load_nii(pathGreyMatterMask);
greyMatterMask.img = greyMatterMask.img > 0.5;

%greyMatterMask.img = true(size(greyMatterMask.img)); %Don't apply gray matter mask


%run through all voxels of both images
imageDimensions = size(image1.img);
elementCounter = 0;
voxelValues = zeros(nnz(greyMatterMask.img),2);
%voxelValues = zeros(numel(image1.img),2);

for i = 1:imageDimensions(1)
    for j = 1:imageDimensions(2)
        for k = 1:imageDimensions(3)
            
            if greyMatterMask.img(i,j,k)
                elementCounter = elementCounter +1;
                voxelValues(elementCounter, 1) = image1.img(i,j,k);
                voxelValues(elementCounter, 2) = image2.img(i,j,k);
            end
            
        end
    end
end

scatter(voxelValues(:,1),voxelValues(:,2), '.');
corrcoef(voxelValues(:,1),voxelValues(:,2))


% 
%     
%     VOIName = VOIDict(j,2)
%     
%     subj=dir(strcat(fullPath,'*.nii'));
%     numberOfFiles=length(subj);
%     
%     
%     %Load all Nii-Files from Folder 'fullPath' to image
%     clear image
%     
%     for i = 1:numberOfFiles
%         currentPath = [fullPath subj(i).name];
%         image(i) = CreateNiiFromVOI(VOIs(j) ,currentPath);
%     end
%     
%     
%        
%     for i = 1:numberOfFiles
%         %i + (numberOfFiles*(j-1))
%         
%         LocalID = i + (numberOfFiles*(j-1));
%         
%         ImageProperties(LocalID).FileName = subj(i).name;
%         ImageProperties(LocalID).VOIs = VOIName;
%         ImageProperties(LocalID).VOICode = VOIDict(j,1);
%         ImageProperties(LocalID).sumOfAllElemntsInImage = sum(image(i).img(:));
%         ImageProperties(LocalID).CountNotZero = nnz(image(i).img);
%         ImageProperties(LocalID).MeanOfNotZero = ImageProperties(LocalID).sumOfAllElemntsInImage / ImageProperties(LocalID).CountNotZero;
%         ImageProperties(LocalID).Max = max(image(i).img(:));
%     end
%     
%     
%     disp([num2str(j) ' of ' num2str(length(VOIs))  ' VOIs done']);
%  
% 
% 
% 
% %WriteResultsToFile
% writetable(struct2table(ImageProperties), [fullPath 'outputMeansAndMaxFromVOIs.csv'])
% disp('Done. Result ist stored in ImageProperties and written to file')