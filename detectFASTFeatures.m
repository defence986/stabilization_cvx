function pts = detectFASTFeatures(I, varargin)
% detectFASTFeatures Find corners using the FAST algorithm
%   POINTS = detectFASTFeatures(I) returns a cornerPoints object,
%   POINTS, containing information about the feature points detected in a
%   2-D grayscale image I. detectFASTFeatures uses the Features from
%   Accelerated Segment Test (FAST) algorithm to find feature points.
%
%   POINTS = detectFASTFeatures(I,Name,Value) specifies additional
%   name-value pair arguments described below:
%
%   'MinQuality'   A scalar Q, 0 <= Q <= 1, specifying the minimum accepted
%                  quality of corners as a fraction of the maximum corner
%                  metric value in the image. Larger values of Q can be
%                  used to remove erroneous corners.
% 
%                  Default: 0.1
%
%   'MinContrast'  A scalar T, 0 < T < 1, specifying the minimum intensity
%                  difference between a corner and its surrounding region,
%                  as a fraction of the maximum value of the image class.
%                  Increasing the value of T reduces the number of detected
%                  corners.
%
%                  Default: 0.2
%
%   'ROI'          A vector of the format [X Y WIDTH HEIGHT], specifying
%                  a rectangular region in which corners will be detected.
%                  [X Y] is the upper left corner of the region.
%
%                 Default: [1 1 size(I,2) size(I,1)]
%
% Class Support
% -------------
% The input image I can be logical, uint8, int16, uint16, single, or
% double, and it must be real and nonsparse.
%
% Example
% -------  
% % Find and plot corner points in the image.
% I = imread('cameraman.tif');
% corners = detectFASTFeatures(I);
% imshow(I); hold on;
% plot(corners.selectStrongest(50));
%
% See also cornerPoints, detectHarrisFeatures, detectMinEigenFeatures,
%          detectBRISKFeatures, detectSURFFeatures, detectMSERFeatures,
%          extractFeatures, matchFeatures

% Reference
% ---------
% E. Rosten and T. Drummond. "Fusing Points and Lines for High
% Performance Tracking." Proceedings of the IEEE International
% Conference on Computer Vision Vol. 2 (October 2005): pp. 1508?1511.

% Copyright  The MathWorks, Inc.

%#codegen
%#ok<*EMCA>

% Check the input image and convert it to the range of uint8.
checkImage(I);
imageSize = size(I);

if isa(I, 'uint8')
    I_u8 = I;
elseif (isSimMode())
    I_u8 = im2uint8(I);
else
    I_u8 = step(getImageDataTypeConverter(),I);
end

params = parseInputs(imageSize, varargin{:});

% Convert the minContrast property to the range of unit8.
if isSimMode()
    minContrast = im2uint8(params.MinContrast);
else
    minContrast = step(getImageDataTypeConverter2(), params.MinContrast);
end

if params.usingROI
    % If an ROI has been defined, we expand it by 2 pixels on the top,
    % bottom, left, and right borders, so only valid pixels are used to
    % compute the corners.
    expandedROI = vision.internal.detector.expandROI(imageSize, ...
        params.ROI, 2);
    
    % Crop the image within the expanded ROI.
    I_u8c = vision.internal.detector.cropImage(I_u8, expandedROI);
else
    expandedROI =  coder.nullcopy(zeros(1,4,'like',params.ROI));
    I_u8c = I_u8;
end

% Find corner locations by using OpenCV.
if isSimMode()
    rawPts = ocvDetectFAST(I_u8c, minContrast);
else
    [rawPts_loc,  rawPts_metric] = vision.internal.buildable.detectFASTBuildable.detectFAST_uint8(I_u8c, minContrast);
    rawPts.Location = rawPts_loc;
    rawPts.Metric = rawPts_metric;
end

% Exclude corners that do not meet the threshold criteria.
if ~isempty(rawPts.Metric)
    % in codegen, max doesn't support empty input
    threshold = params.MinQuality * max(rawPts.Metric);

    validIndex = rawPts.Metric >= threshold;
    locations = rawPts.Location(validIndex, :);
    metricValues = rawPts.Metric(validIndex);
else
    locations    = zeros(0, 2, 'like', rawPts.Location);
    metricValues = zeros(0, 1, 'like', rawPts.Metric);
end

if params.usingROI
    % Because the ROI was expanded earlier, we need to exclude corners
    % which are outside the original ROI.
    [locations, metricValues] ...
        = vision.internal.detector.excludePointsOutsideROI(...
        params.ROI, expandedROI, locations, metricValues);
end

% Pack the output into a cornerPoints object.
pts = cornerPoints(locations, 'Metric', metricValues);


%==========================================================================
function params = parseInputs(imageSize,varargin)
if isSimMode()
    params = parseInputs_sim(imageSize,varargin{:});
else
    params = parseInputs_cg(imageSize,varargin{:});
end
%==========================================================================
function params = parseInputs_sim(imageSize,varargin)
% Instantiate an input parser
parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = true;

defaults = getDefaultParameters(imageSize);

parser.addParamValue('MinQuality',  defaults.MinQuality, ...
    @vision.internal.detector.checkMinQuality); 

parser.addParamValue('MinContrast', defaults.MinContrast, ...
    @vision.internal.detector.checkMinContrast);

parser.addParamValue('ROI', defaults.ROI);

% Parse and check the optional parameters
parser.parse(varargin{:});
params = parser.Results;

params.usingROI = isempty(regexp([parser.UsingDefaults{:} ''],...
    'ROI','once'));

if params.usingROI     
    vision.internal.detector.checkROI(params.ROI,imageSize);   
end

%==========================================================================
function params = parseInputs_cg(imageSize,varargin)

% Opional Name-Value pair: 3 pairs (see help section)
defaults = getDefaultParameters(imageSize);
defaultsNoVal = getDefaultParametersNoVal();
properties    = getEmlParserProperties();

optarg = eml_parse_parameter_inputs(defaultsNoVal, properties, varargin{:});
params.MinQuality = (eml_get_parameter_value( ...
        optarg.MinQuality, defaults.MinQuality, varargin{:}));
params.MinContrast = (eml_get_parameter_value( ...
    optarg.MinContrast, defaults.MinContrast, varargin{:}));
params.ROI = (eml_get_parameter_value( ...
    optarg.ROI, defaults.ROI, varargin{:}));

usingROI = ~(optarg.ROI==uint32(0));

if usingROI
    params.usingROI = true;
    vision.internal.detector.checkROI(params.ROI, imageSize);    
else
    params.usingROI = false;
end

vision.internal.detector.checkMinQuality(params.MinQuality);
vision.internal.detector.checkMinContrast(params.MinContrast);

%==========================================================================
function r = checkImage(I)
validateattributes(I, ...
  {'logical', 'uint8', 'int16', 'uint16', 'single', 'double'}, ...
  {'2d', 'nonempty', 'nonsparse', 'real'},...
  mfilename, 'I', 1); 
r = true;

%==========================================================================
function defaults = getDefaultParameters(imageSize)
       
defaults = struct(...
    'MinQuality', 0.1, ...
    'MinContrast', 0.2, ...
    'ROI', int32([1 1 imageSize(2) imageSize(1)])); % [1 1 size(I,2) size(I,1)]

%==========================================================================
function defaultsNoVal = getDefaultParametersNoVal()

defaultsNoVal = struct(...
    'MinQuality', uint32(0), ... 
    'MinContrast', uint32(0), ... 
    'ROI', uint32(0));

%==========================================================================
function properties = getEmlParserProperties()

properties = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', false);

%==========================================================================
function h_idtc = getImageDataTypeConverter()

persistent h
if isempty(h)
    % input data type locked at compile-time
    h = vision.ImageDataTypeConverter('OutputDataType','uint8');
end
h_idtc = h;

%==========================================================================
function h_idtc = getImageDataTypeConverter2()

persistent h2
if isempty(h2)
    % input data type locked at compile-time
    h2 = vision.ImageDataTypeConverter('OutputDataType','uint8');
end
h_idtc = h2;

%==========================================================================
function flag = isSimMode()

flag = isempty(coder.target);   


