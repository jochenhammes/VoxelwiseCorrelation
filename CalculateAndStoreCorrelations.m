
    %Create subplot for each Timeslice
    subplot(numberOfFigureRows, numberOfFigureCols,h+l)
    scatter(voxelValues(:,1),voxelValues(:,2), '.');
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
    refline(currentSlope,currentIntercept);
    
    currentStartTime = (h-1)*60;
    currentStopTime = h*60;
    
    title([num2str(currentStartTime) 's-' num2str(currentStopTime) 's r=' num2str(currentCorrCoeff) ])
    xlabel('AV 1451')
    ylabel('FDG')
    
    %Save data to struct
    Correlations(h+l).StartTime = currentStartTime;
    Correlations(h+l).StopTime = currentStopTime;
    Correlations(h+l).CorrCoeff = currentCorrCoeff;
    Correlations(h+l).CorrFisherZ = fisherz(currentCorrCoeff);
    Correlations(h+l).Slope = currentSlope;
    Correlations(h+l).Intercept = currentIntercept;
    Correlations(h+l).SmoothingKernelInMM = smoothingSize(1)*2;