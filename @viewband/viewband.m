function [obj, varargout] = viewband(varargin)
%@viewband Constructor function for viewband class
%   OBJ = viewband(varargin)
%
%   OBJ = viewband('auto') attempts to create a viewband object by ...
%   
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on viewband %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = viewband('save','redo')
%
%dependencies: 

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0, ...
				'FileName','bandfield.mat', 'ObjectLevel','Channel');
Args.flags = {'Auto','ArgsOnly'};
% Specify which arguments should be checked when comparing saved objects
% to objects that are being asked for. Only arguments that affect the data
% saved in objects should be listed here.
Args.DataCheckArgs = {};                            

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'viewband';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'vb';

% To decide the method to create or load the object
[command, robj] = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);

if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
	obj = robj;
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!! 
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,modvarargin{:});
end

function obj = createObject(Args,varargin)

% example object
dlist = dir(Args.FileName);
% get entries in directory
dnum = size(dlist,1);

% check if the right conditions were met to create object
if(dnum>0)
	% these are fields that are useful for most objects
	data.numChannels = 1;

	data.locSI = zeros(dnum,1);
	for didx = 1:dnum
		l = load(dlist(didx).name);
        data.thetaTime(didx,:,:) = l.thetaTime;
        data.thetaPowerSpec(didx,:,:) = l.thetaPowerSpec;
        data.theta_locSI(didx) = l.theta_locSI;
        data.thetaPValue(didx,:,:) = l.thetaPValue;
        data.alphaTime(didx,:,:) = l.alphaTime;
        data.alphaPowerSpec(didx,:,:) = l.alphaPowerSpec;
        data.alpha_locSI(didx) = l.alpha_locSI;
        data.alphaPValue(didx,:,:) = l.alphaPValue;
        data.gammaTime(didx,:,:) = l.gammaTime;
        data.gammaPowerSpec(didx,:,:) = l.gammaPowerSpec;
        data.gamma_locSI(didx) = l.gamma_locSI;
        data.gammaPValue(didx,:,:) = l.gammaPValue;
        data.posterPosition(didx,:,:) = l.posterPosition;
	end
	% set index to keep track of which data goes with which directory
	data.ChannelIndex = [0; dnum];
	data.ArrayIndex = [0; dnum];
	data.SessionIndex = [0; dnum];
	data.DayIndex = [0; dnum];
	% get channel string
	[data.arrstr(1,:), chnstr] = nptFileParts(pwd);
	% get array string
	[data.sesstr(1,:), arrstr] = nptFileParts(data.arrstr(1,:));
	% get session string
	[data.daystr(1,:), sesstr] = nptFileParts(data.sesstr(1,:));
	% get day string
	% [p4, data.daystr(1,:)] = nptFileParts(p3);
    data.Args = Args;
		
	% create nptdata so we can inherit from it    
    data.Args = Args;
	n = nptdata(data.numChannels,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	saveObject(obj,'ArgsC',Args);
else
	% create empty object
	obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numChannels = 0;
data.numArrays = 0;
data.numSessions = 0;
data.numDays = 0;
data.locSI = [];

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
