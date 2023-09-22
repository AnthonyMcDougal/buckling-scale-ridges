% Demo of using scikit-image unwrapping in matlab

%% enter correct python environment: 
% for Matlab R2022b, must be Python 3.10 or some lower version; 

%% Installing Python 
% 	- Determine the correct version of Python for your version of MatLab: https://www.mathworks.com/support/requirements/python-compatibility.html 
% 	- Install Python: `winget install -e --id Python.Python.3.10`
% 	- Install Pip: `py -m pip install pip`
% 	- Upgrade Pip: `py -m pip install --upgrade pip`
% 	- Install scikit-image: `py -m pip install scikit-image`
% 	- Restart Matlab if open

%% If you have multiple versions of python, you must have scikit-image for the correct version and Matlab pointing to the correct one
% Recommended to use py, python launcher for windows. e.g. in windows commandline:
% `py -3.10 -m pip install pip`
% `py -3.10 -m pip install --upgrade pip`
% `py -3.10 -m pip install scikit-image`

% When starting up matlab, set the correct python version
% you might get away without doing that for some use cases, but apparently not when handling matrices
% `pyenv('Version','3.10')`


%% Sample image
A = peaks*2;
A_w = wrapToPi(A);

figure, imagesc(A)
colormap(twilight)
title('True height')
colorbar

figure, imagesc(A_w)
colormap(twilight)
title('wrapped height')
colorbar

%% Sample unwrap
auw = py.skimage.restoration.unwrap_phase(A_w);
% If properly done, we get an ndarray that is a numpy array; use double() to transform back to matlab array
A_uw = double(auw);

figure, imagesc(A_uw)
colormap(twilight)
title('unwrapped height')
colorbar

%%
errorUW = A-A_uw;
figure, imagesc(errorUW)
colormap(twilight)
title('error')
colorbar
