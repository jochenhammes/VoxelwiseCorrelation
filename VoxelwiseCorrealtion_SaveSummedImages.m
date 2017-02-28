clear all

%load paths to images
pathsToPerfusionStudyFiles;

outputFolder = '/Volumes/MMNI_RAID/RAID_MMNI/Tau-Perfusion/SummedImages/';


for subjectCounter = 1:size(paths,1)
        
    currentSubjects = dir(strcat(paths{subjectCounter,2},'wrTau_early*.nii'));
    
    %extract filename of first entry of currentSubjects to save as
    %patient-identifier
    currentPatientID = currentSubjects(1).name;
    currentPatientID = currentPatientID(13:end-7);
    
    %copy fdg image
    copyfile(paths{subjectCounter,1},outputFolder)

        
    for h = 1:size(currentSubjects,1)
        images2(h) = load_nii([paths{subjectCounter,2} currentSubjects(h).name]);
    end
    
    sumImage = images2(1);
    
    listOfSummedFrames = [2 5];
    
    for l = 1:size(listOfSummedFrames,1)
        
        disp(l);
        %Calculate start and stop time for filename
        currentStartTime = (listOfSummedFrames(l,1)-1)*60;
        currentStopTime = listOfSummedFrames(l,2)*60;
        
        
        %Create Current Sum-Image based on listOfSummedFrames
        sumImage.img = images2(listOfSummedFrames(l,1)).img; %start with first image
        if listOfSummedFrames(l,2) == listOfSummedFrames(l,1)
            disp('no sum');
        else
            for m = (listOfSummedFrames(l,1)+1):listOfSummedFrames(l,2) %add all the images in between consecutively
                sumImage.img = sumImage.img + images2(m).img;
            end
        end
        %Save Current Sum-Image
        save_nii(sumImage, [outputFolder 'Sum_' num2str(currentStartTime) '-' num2str(currentStopTime) '_Tau_' currentPatientID '.nii']);   
        
    end

    
end


