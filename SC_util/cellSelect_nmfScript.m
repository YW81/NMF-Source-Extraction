Acquisition2P([],@SClk);
cd(FOV1.defaultDir)
motionCorrect(FOV1)
for i=1:4
    indexMovie(FOV1,i);
end
FOV1.derivedData(1).syncObj = bSyncIm(FOV1);
fprintf('%d frames from Acq Obj \n',sum(FOV1.correctedMovies.slice(end).channel.size(:,3))),
FOV1.save,

%% Select Slice and run Patches
for nSlice = 1:4
    extractSourcesNMF(FOV1,nSlice);
end