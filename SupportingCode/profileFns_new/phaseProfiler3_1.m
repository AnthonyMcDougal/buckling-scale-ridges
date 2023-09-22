function [figs] = phaseProfiler3_1(Pimgs, refImgs, phaseD)
%phaseProfiler is a tool to examine a slice of phase data from a 3D volume of phase data
%   This builds on phaseProfiler2, to include unwrapped regions. Note that 
%   using the GUI "snap" button (to get a snapshot of a surface ROI and 
%   relevant parameters) now overwrites the previous "snap," whereas in v2 
%   snapping added the snapshot to an array. 

%   Workflow:
%   Call function;adjust slice of data on Figure 1 GUI slider; grab and adjust end points of the trace line for profile.
%   Checking the output figures, tweak the tolerance and ceiling of periodicity, as well as the minimum threashold for peak height detection.
%   Data is sent to the main workspace by using the snap button.
%
%   Visible regions of the axes of some windows are constrained to 20um according to our normal workflow. This may be adjusted based on use case.
%   Note of caution: this function uses global variables. Future improvements should consider best practices for variable handling.
%
%   Known issue: 
%   System hangs if the 'borderLine' profiles land outside image (recommended to restart Matlab)
%
%   Jan Totz, Anthony McDougal, Leonie Wagner, Sungsam Kang, Peter So, 
%   Jörn Dunkel, Bodo Wilts, and Mathias Kolle, 2023

%% Image parameters
meas = struct;

% phaseD = 800/(2*2*pi*1.346); %parameter to convert phase to difference via phase shift, included as function variable

meas.maxAmp = max(abs(Pimgs(:)));
meas.imgsize = size(Pimgs(:,:,1));

meas.pxSize = 0.0726*1024/size(Pimgs,1); % in um


%% setup figures, views
% stack information
sliceMin = 1;
sliceMax = size(Pimgs,3);
meas.slice = 1;

% UI control
UI_fig = figure;

% % Phase figure
% figure
% figs.phase = imagesc(angle(Pimgs(:,:,meas.slice)));
% figs.phase.Parent.Parent.Color = [1 1 1];
% axis image
% % set(gca,'color',bgColor)
% colormap(twilight)

% Amplitude figure
figure
figs.amp = imagesc(abs(Pimgs(:,:,meas.slice)));
figs.amp.Parent.Parent.Color = [1 1 1];
axis image
% set(gca,'color',bgColor)
colormap(gray)
title('Amplitude component')

% MagDPimgs
figure
figs.refImgs = imagesc(refImgs(:,:,meas.slice));
axis image
colormap(twilight)
title('Orientation of the phase gradient')

% Profile figures
figs.profileUW = figure;
figs.profileUW.Color = [1 1 1];

figs.profileUWrot = figure;
figs.profileUWrot.Color = [1 1 1];

figs.profileFourier = figure;
figs.profileFourier.Color = [1 1 1];

% Surface Figures
figs.surface = figure;
figs.surface.Color = [1 1 1];
view(-180,40)

figs.surf2D = figure;
figs.surfXSec = figure;

%% Layout figures
UI_fig.Units = 'normalized';
UI_fig.Position(1:2) = [0.01 0.5];
% figs.phase.Parent.Parent.Units = 'normalized';
% figs.phase.Parent.Parent.Position(1:2) = [0.7 0.5];
figs.amp.Parent.Parent.Units = 'normalized';
figs.amp.Parent.Parent.Position(1:2) = [0.7 0.5];
figs.refImgs.Parent.Parent.Units = 'normalized';
figs.refImgs.Parent.Parent.Position(1:2) = [0.35 0.5];

figs.profileUW.Units = 'normalized';
figs.profileUW.Position(1:2) = [0.35 0.02];
figs.profileUWrot.Units = 'normalized';
figs.profileUWrot.Position(1:2) = [0.01 0.02];

figs.profileFourier.Units = 'normalized';
figs.profileFourier.Position(1:2) = [0.7 0.02];

figs.surface.Units = 'normalized';
% figs.surface.Position(1:2) = [0.01 0.02];
figs.surface.Position(1:2) = [0.35 0.02];
figs.surf2D.Units = 'normalized';
figs.surf2D.Position(1:2) = [0.7 0.02];
figs.surfXSec.Units = 'normalized';
figs.surfXSec.Position(1:2) = [0.7 0.5];

%% line of interest
figXSize = size(figs.amp.CData,2);
figYSize = size(figs.amp.CData,1);

cornerX1 = figXSize/2;
cornerX2 = figXSize/2 + figXSize/10;
cornerY1 = figYSize/2;
cornerY2 = figYSize/2 + figYSize/10;

myLine = drawline(figs.refImgs.Parent,'Position',[cornerX1 cornerY1; cornerX2 cornerY2]);
addlistener(myLine,'ROIMoved',@myLineMoved);
myLineStart = drawcircle(figs.refImgs.Parent, 'Center', myLine.Position(1,:),...
    'Radius',10,...
    'Color', [1 0 0],...
    'InteractionsAllowed','none',...
    'FaceSelectable',false);
mirrorLine = drawline(figs.amp.Parent,'Position',myLine.Position);
addlistener(mirrorLine,'ROIMoved',@myMirrorLineMoved);

borderLineOne = drawline(figs.refImgs.Parent,'Position',[(cornerX1+figXSize/10), cornerY1/2; (cornerX2+figXSize/10), cornerY2/2]);
borderLineEnd = drawline(figs.refImgs.Parent,'Position',[(cornerX1-figXSize/10), cornerY1/2; (cornerX2-figXSize/10), cornerY2/2]);

%% Intialize tolerance parameters for profile analysis
meas.minFreqRatioAllow = .3;
meas.minPeak = 0.01;
meas.maxPeriod = 2;

profileLength = 7;
profilesDepth = 7;

%% UI controls
sliceSlider = uicontrol('Parent',UI_fig,'Style','slider',...
    'Position',[50,60,30,150],...
    'value',meas.slice,'min',sliceMin,'max',sliceMax,...
    'SliderStep',[1/sliceMax 10/sliceMax],...
    'Callback',{@sliceCallback,figs});
sliceEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[50,30,50,20],...
    'string',num2str(sliceSlider.Value),...
    'Callback',{@sliceEditCallback,figs});
sliceLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[50,60+150,30,20],...
    'String','slice');
buttonNewROI = uicontrol('Parent',UI_fig,...
    'Style','pushbutton',...
    'Position',[300,300,150,30],...
    'string','make new profile',...
    'fontsize', 9,...
    'Callback',{@buttonNewLineCallback,figs});
buttonSnap = uicontrol('Parent',UI_fig,...
    'Style','pushbutton',...
    'Position',[300,360,150,30],...
    'string','SNAP',...
    'fontsize', 9,...
    'Callback',{@buttonSnapCallback,figs});

maxPeriodEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[300,30,50,20],...
    'string',meas.maxPeriod,...
    'Callback',{@maxPeriodEditCallback,figs});
maxPeriodLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[195,30,100,20],...
    'String','Period ceiling');
minPeakEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[300,60,50,20],...
    'string', meas.minPeak,...
    'Callback',{@minPeakEditCallback,figs});
minPeakLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[195,60,100,20],...
    'String','min peak height');
minFreqRatioEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[300,90,50,20],...
    'string',meas.minFreqRatioAllow,...
    'Callback',{@minFreqRatioCallback,figs});
minFreqRatioLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[195,90,100,20],...
    'String','min ratio (tolerance)');

loadPtsEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[300,150,200,20]);
buttonLoad = uicontrol('Parent',UI_fig,...
    'Style','pushbutton',...
    'Position',[195,150,100,20],...
    'string','load profile',...
    'fontsize', 9,...
    'Callback',{@buttonLoadCallback,figs});

snapCommentEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[90,365,200,20]);


profileLengthEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[400,30,50,20],...
    'string',profileLength,...
    'Callback',{@profileLengthEditCallback,figs});
profileLengthLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[450,30,100,30],...
    'String','length of profile (um)');


profilesDepthEdit = uicontrol('Parent',UI_fig,...
    'Style','edit',...
    'Position',[400,60,50,20],...
    'string',profilesDepth,...
    'Callback',{@profilesDepthEditCallback,figs});
profilesDepthLabel = uicontrol('Parent',UI_fig,'Style','text',...
    'Position',[450,60,100,30],...
    'String','depth of profiles (um)');


%% UI callbacks
    function sliceCallback(thisSlider, ~, handles)
        %second argument in this function is EventData
        meas.slice = round(thisSlider.Max - thisSlider.Value + thisSlider.Min);
        updateAll();
    end
    function sliceEditCallback(thisSlider, ~, handles)
        meas.slice = str2double(sliceEdit.String);
        if meas.slice > sliceMax
            meas.slice = sliceMax;
        elseif meas.slice < sliceMin
            meas.slice = sliceMin;
        end
        updateAll();
    end
    function myLineMoved(~,~,~)
        %Uncomment the following three lines to force a particular line of interest
        % temppoints = ...
        % [784.806921748568,447.003827709986;826.388679891842,418.416368986485];
        % myLine.Position = temppoints;
        
%         forceL = 7 / (pxSize); % microns to pixels
        forceL = profileLength / (meas.pxSize); % microns to pixels
        newPosition = relength(myLine.Position, forceL);
        myLine.Position = newPosition;
        
        mirrorLine.Position = myLine.Position;

        updateProfile();
    end
    function myMirrorLineMoved(~,~,~)
        myLine.Position = mirrorLine.Position;
        myLineMoved
    end
    function buttonNewLineCallback(thisSlider, ~, handles)
        delete(myLine)
        myLine = drawpolygon(figs.refImgs.Parent,'FaceAlpha',0);
        addlistener(myLine,'ROIMoved',@myLineMoved);
        
        mirrorLine.Position = myLine.Position;
        updateAll();
    end
    function buttonSnapCallback(thisButton,~,handles)
        snapCurrent;
    end

    function maxPeriodEditCallback(thisBox, ~, handles)
        meas.maxPeriod = str2double(maxPeriodEdit.String);
        updateAll();
    end
    function minPeakEditCallback(thisBox, ~, handles)
        meas.minPeak = str2double(minPeakEdit.String);
        updateAll();
    end
    function minFreqRatioCallback(thisBox, ~, handles)
        meas.minFreqRatioAllow = str2double(minFreqRatioEdit.String);
        updateAll();
    end
    function buttonLoadCallback(thisButton,~,handles)
        expFilt = '[\[\],;\{\}]';
        
        entries = regexp(loadPtsEdit.String,expFilt,'split');
        entrynums = str2mat(entries);
        entrynums = str2num(entrynums);
        entrynums = reshape(entrynums,[2,2]);
        entrynums = entrynums';
        myLine.Position = entrynums;
        mirrorLine.Position = myLine.Position;
        updateProfile();
    end
    function profileLengthEditCallback(thisBox, ~, handles)
        profileLength = str2double(profileLengthEdit.String);
        myLineMoved()
    end
    function profilesDepthEditCallback(thisBox, ~, handles)
        profilesDepth = str2double(profilesDepthEdit.String);
        myLineMoved()
    end

%% update callbacks
    function updateAll()
        updateUI();
        
        updateFigs()
        
        updateProfile()
    end

    function updateFigs()
        %         figs.phase.CData = angle(Pimgs(:,:,meas.slice));
        
        figs.amp.CData = abs(Pimgs(:,:,meas.slice));
        figs.refImgs.CData = refImgs(:,:,meas.slice);
    end
    function updateUI()
        sliceSlider.Value = round(sliceSlider.Max - meas.slice + sliceSlider.Min);
        sliceEdit.String = num2str(meas.slice);
    end

%% Processing of selected profile (callback)
    function updateProfile()
        lp = myLine.Position
        myLineStart.Center = myLine.Position(1,:);
        
        forcedepth = profilesDepth/(meas.pxSize);
        lineArray = makeProfileLists(lp, forcedepth);
        [meas.cx_2D, meas.cy_2D, meas.phase_2D] = unwrapProfileArray(lineArray);
        
        %         figure
        
        %the first point clicked is the first point in the data
%         [cx,cy,c] = improfile(angle(Pimgs(:,:,meas.slice)),lp(:,1),lp(:,2));
        [meas.cx,meas.cy,~] = improfile(angle(Pimgs(:,:,meas.slice)),lp(:,1),lp(:,2));
        complexLine = interp2(Pimgs(:,:,meas.slice), meas.cx, meas.cy);
        meas.phaseProfile = angle(complexLine);        
        
        %Unwrap phase data (and flip phase to relate to distance)
        cUnwrap = unwrap(-meas.phaseProfile);
        cUWum = cUnwrap*phaseD/1000;
        %get line length, convert to um
        cxNew = sqrt((meas.cx-meas.cx(1)).^2 + (meas.cy-meas.cy(1)).^2);
        cxNewUm = cxNew*meas.pxSize;
        %Rotate profile so that scale surface lies flat
        [meas.cxNewUmRot, meas.heightProfileUmRot] = rotProfile(cxNewUm, cUWum);
                
        %Determine the dominant period
        [frqs1,pks1,fsampleP,fs, df] = getProfileFreq(meas.heightProfileUmRot,meas.cxNewUmRot,meas.maxPeriod);
        meas.period = 1/frqs1;
        %Determine peak heights corresponding to this period (within specified tolerances)
        minspacing = meas.period*fs*meas.minFreqRatioAllow;
        [peakInd,troughInd] = peakMinFinder(meas.heightProfileUmRot,minspacing,meas.minPeak);
        [meas.meanHeights,meas.stdHeights,meas.nHeights] = getHeights(meas.cxNewUmRot,meas.heightProfileUmRot,peakInd,troughInd);
        
        %UPDATE ALL FIGURES
        figure(figs.profileFourier)
        plot(df,abs(fsampleP))
        title(['Fourier transform of profile. f = ', num2str(frqs1), ' , w = ', num2str(meas.period)])
        hold on
        scatter(frqs1,pks1)
        hold off
                
        figure(figs.profileUW)
        yyaxis left
        plot(cxNewUm,cUnwrap)
        xlabel('in plane (µm)')
        ylabel('phase depth (rad)')
        title('Unwrapped, not-rotated phase (blue) compared to amplitude (orange)')
        h2 = figs.profileUW.CurrentAxes;
        %         h2.YLim = [-0.35, 0.35];
        h2.XLim = [0, 20.5];
        
        yyaxis right
        meas.ampProfile = improfile(abs(Pimgs(:,:,meas.slice)),lp(:,1),lp(:,2));
        plot(cxNewUm,meas.ampProfile./meas.maxAmp)
        ylabel('Amplitude (fraction of vol. max)')
        legend('phase', 'amplitude')
        
        figure(figs.profileUWrot)
        plot(meas.cxNewUmRot,meas.heightProfileUmRot)
        xlabel('µm lateral')
        ylabel('µm vertical')
        title(['Rotated, unwrapped profile, meanH = ',num2str(meas.meanHeights)])
        h2 = figs.profileUWrot.CurrentAxes;
        h2.YLim = [-0.05, 0.95];
        h2.XLim = [0, 20.5];
        
        hold on;
        scatter(meas.cxNewUmRot(peakInd),meas.heightProfileUmRot(peakInd));
        scatter(meas.cxNewUmRot(troughInd),meas.heightProfileUmRot(troughInd));
        hold off;
        
        % have most relevant figures on top
        figure(UI_fig)
        figure(figs.surf2D)
        figure(figs.surface)

    end

%% Send data to workspace on UI demand (callback)
    function snapCurrent()
%         updateAll() %not strictly necessary, but be aware if that if some values in the gui fields might not be updated before clicking snap--if you need them updated, then uncomment this line
        
        %Future improvement: may want to handle the following more robustly
        meas.endpoints = myLine.Position;
        meas.comment = snapCommentEdit.String;
        meas.phaseD = phaseD; 
        
        %the following are not detected in some callbacks, so saving here:
        meas.profileLength = profileLength;
        meas.profilesDepth = profilesDepth;

        %send to base workspace in matlab
        assignin('base','meas',meas)
        
        msg = ['data sent to workspace for: ', meas.comment];
        display(msg)
    end

%% Supporting functions
    function lpNew = relength(lp, newLen)
        %newLen implemented with Pixels
        
        lpNew = lp;
        
        theta = atan2((lp(2,2)-lp(1,2)),(lp(2,1)-lp(1,1)));
        lpNew(2,2) = lp(1,2) + newLen*sin(theta);
        lpNew(2,1) = lp(1,1) + newLen*cos(theta);
    end

    function lpArray = makeProfileLists(lp, targetLength)
        %arLength implemented with Pixels
        arLength = round(targetLength);
        
        
        theta = atan2((lp(2,2)-lp(1,2)),(lp(2,1)-lp(1,1)));
        theta2 = theta + pi/2;
        
        cornerXa = lp(1,2) + targetLength*sin(theta2)/2;
        cornerYa = lp(1,1) + targetLength*cos(theta2)/2;
        cornerXb = lp(1,2) - targetLength*sin(theta2)/2;
        cornerYb = lp(1,1) - targetLength*cos(theta2)/2;
        
        cornerXc = lp(2,2) + targetLength*sin(theta2)/2;
        cornerYc = lp(2,1) + targetLength*cos(theta2)/2;
        cornerXd = lp(2,2) - targetLength*sin(theta2)/2;
        cornerYd = lp(2,1) - targetLength*cos(theta2)/2;
                
        lpArray_1 = [cornerYa, cornerXa; cornerYc, cornerXc];
        lpArray = repmat(lpArray_1, 1,1,arLength+1);
        
        dX = (cornerXb - cornerXa) ;
        shiftX = 0:dX/arLength:dX;
        lpArray(1,2,:) = squeeze(lpArray(1,2,:)) + squeeze(shiftX'); %(move first point in x)
        lpArray(2,2,:) = squeeze(lpArray(2,2,:)) + squeeze(shiftX'); %(move second point in x)
        
        
        dY = (cornerYb - cornerYa);
        shiftY = 0:dY/arLength:dY;
        lpArray(1,1,:) = squeeze(lpArray(1,1,:)) + squeeze(shiftY'); %(move first point in Y)
        lpArray(2,1,:) = squeeze(lpArray(2,1,:)) + squeeze(shiftY'); %(move second point in Y)
        
        lineOneP = [lpArray(1,1,1) lpArray(1,2,1); lpArray(2,1,1) lpArray(2,2,1)];
        lineEndP = [lpArray(1,1,end) lpArray(1,2,end); lpArray(2,1,end) lpArray(2,2,end)];
        
        % check if line profiles are out of bounds!
        % (currently assumes image is square)
        lineOneOOB = max(or(lineOneP<0 , lineOneP>meas.imgsize));
        lineEndOOB = max(or(lineEndP<0 , lineEndP>meas.imgsize));
        
        if or(lineOneOOB,lineEndOOB)
            msg = 'lines are out of image bounds, please try again'
            error(msg)
        else
            borderLineOne.Position = lineOneP;
            borderLineEnd.Position = lineEndP;
        end
    end

    function [cx_array, cy_array, c_array] = unwrapProfileArray(lpArray)
        for k = 1:size(lpArray,3)
%             [cx_array(:,k),cy_array(:,k),c_array(:,k)] = improfile(angle(Pimgs(:,:,meas.slice)),lpArray(:,1,k),lpArray(:,2,k));
            [cx_array(:,k),cy_array(:,k),~] = improfile(angle(Pimgs(:,:,meas.slice)),lpArray(:,1,k),lpArray(:,2,k));
            complexLine(:,k) = interp2(Pimgs(:,:,meas.slice), cx_array(:,k), cy_array(:,k));
            c_array(:,k) = angle(complexLine(:,k));
        end

        %Unwrap phase data (and flip phase to relate to distance)
        cPy = py.skimage.restoration.unwrap_phase(-c_array);
        c_arrayUW = double(cPy);
        
        %convert to microns
        c_arrayUW_um = c_arrayUW*phaseD/1000; %convert from rads to um
        cx_array_um = cx_array*meas.pxSize;
        cy_array_um = cy_array*meas.pxSize;
        
        [cxFlatArray_um, cyFlatArray_um, cFlatArray_um] = flatPlane(cx_array_um, cy_array_um, c_arrayUW_um);
        
        meas.phase_2DNewUmRot = cFlatArray_um - min(cFlatArray_um(:));
        
        % rotate coordinates
        [meas.cx_2DNewUmRot, meas.cy_2DNewUmRot] = rotCoordinates(cxFlatArray_um,cyFlatArray_um);
        
        scaleH = 5;
        
        %plot surface
        scaleH3D = scaleH;
        figure(figs.surface)
        [azNow, elNow] = view();
        
        s = surf(cxFlatArray_um, cyFlatArray_um, meas.phase_2DNewUmRot);
        s.EdgeColor = 'none';
        %         s = mesh(cxFlatArray_um, cyFlatArray_um, scaleH*cFlatArray2_um);
        colormap(viridis)
        axis image
        axis vis3d
        rotate3d on
        set(gca, 'DataAspectRatio', [1 1 1/scaleH3D])
        zlimOLD = get(gca, 'ZLim');
        zPad = .15*(zlimOLD(2)-zlimOLD(1));
        set(gca,'ZLim', [zlimOLD(1)-zPad, zlimOLD(2)+zPad])
        title(['z-axis stretched by × ', num2str(scaleH3D)])
        colorbar
        xlabel([char(0181),'m'])
        ylabel([char(0181),'m'])
        zlabel([char(0181),'m'])
        hold on
        midline = round(size(cxFlatArray_um,2)/2);
        scatter3(cxFlatArray_um(1,midline), cyFlatArray_um(1,midline), meas.phase_2DNewUmRot(1,midline),'r')
        hold off
        set(gca,'Xdir','reverse')
        view(azNow,elNow)
        
        % plot 2d view
        figure(figs.surf2D)
        imagesc([meas.cx_2DNewUmRot(1,1),meas.cx_2DNewUmRot(end,1)], [meas.cy_2DNewUmRot(1,1), meas.cy_2DNewUmRot(1,end)], meas.phase_2DNewUmRot')
        axis image, colormap(viridis)
        xlabel([char(0181),'m'])
        ylabel([char(0181),'m'])
        hold on
        midline2 = round(size(meas.cx_2DNewUmRot,2)/2);
        scatter3(meas.cx_2DNewUmRot(1,midline2), meas.cy_2DNewUmRot(1,midline2), meas.phase_2DNewUmRot(1,midline2),'r')
        hold off
        cbar = colorbar;
        cbar.Label.String = ['rotated height, ', char(0181), 'm'];
        set(gca,'Ydir','normal')
        
        % plot Cross-section view
        scaleHside = scaleH;
        figure(figs.surfXSec)
%         cla(gca)
%         hold on
        nLines = size(meas.phase_2DNewUmRot,2);
        for k = 1:nLines
            p(k) = plot(meas.cx_2DNewUmRot(:,k),meas.phase_2DNewUmRot(:,k),'Color', [0 0 0]);
            %     p(k).Color(4) = 2*1/nLines;
            p(k).Color(4) = .08;
            hold on
        end
        
        hold on
        plot(meas.cx_2DNewUmRot(:,1),mean(meas.phase_2DNewUmRot,2), 'Color', [.9 0 0])
        set(gca, 'DataAspectRatio', [1 1/scaleHside 1])
        ylimOLD = get(gca, 'YLim');
        yPad = .15*(ylimOLD(2)-ylimOLD(1));
        set(gca,'YLim', [ylimOLD(1)-yPad, ylimOLD(2)+yPad])
        title(['z-axis stretched by × ', num2str(scaleHside)])
        xlabel([char(0181),'m'])
        ylabel([char(0181),'m'])
        hold off
        
    end
end