function [g,a,info] = dtwfb2filterbank( dualwt, varargin)
%DTWFB2FILTERBANK DTWFB equivalent non-iterated filterbank
%   Usage: [g,a,info] = dtwfb2filterbank(dualwt)
%          [g,a,info] = dtwfb2filterbank(dualwt,...)
%
%   Input parameters:
%      dualwt : Dual-tree wavelet filterbank specification.
%
%   Output parameters:
%      g      : Cell array of filters.
%      a      : Downsampling rate for each channel.
%      info   : Additional information.
%
%   `[g,a] = dtwfb2filterbank(dualwt)` constructs a set of filters *g* and
%   subsampling factors *a* of a non-iterated filterbank, which is 
%   equivalent to the dual-tree wavelet filterbank defined by *dualwt*. 
%   The returned parameters can be used directly in |filterbank| and other
%   routines. The format of *dualwt* is the same as in |dtwfb| and 
%   |dtwfbreal|.  
%
%   The function internally calls |dtwfbinit| and passes *dualwt* and all
%   additional parameters to it.
%
%   `[g,a,info] = dtwfb2filterbank(...)` additionally outputs a *info*
%   struct containing equivalent filterbanks of individual real-valued
%   trees as fields *info.g1* and *info.g2*.
%
%   Additional parameters:
%   ----------------------
%   
%   By default, the function returns a filtebank equivalent to |dtwfb|.
%   The filters can be restricted to cover only the positive frequencies
%   and to be equivivalent to |dtwfbreal| by passing a `'real'` flag.   
%
%   Examples:
%   ---------
%
%   The following two examples create a multirate identity filterbank
%   using a duel-tree of depth 3:::
%
%      [g,a] = dtwfb2filterbank({'qshift3',3},'real');
%      filterbankfreqz(g,a,1024,'plot','linabs');
%
%   In the second example, the filterbank is identical to the full
%   wavelet tree:::
%
%      [g,a] = dtwfb2filterbank({'qshift3',3,'full'},'real');
%      filterbankfreqz(g,a,1024,'plot','linabs');
%
%   See also: dtwfbinit

complainif_notenoughargs(nargin,1,'DTWFB2FILTERBANK');

% Search for the 'real' flag
do_real = ~isempty(varargin(strcmp('real',varargin)));

if do_real
    %Remove the 'real' flag from varargin
    varargin(strcmp('real',varargin)) = [];
end

% Initialize the dual-tree
dtw = dtwfbinit({'strict',dualwt},varargin{:});

% Determine relation between the tree nodes
wtPath = 1:numel(dtw.nodes);
wtPath(noOfNodeOutputs(1:numel(dtw.nodes),dtw)==0)=[];
rangeLoc = rangeInLocalOutputs(wtPath,dtw);
rangeOut = rangeInOutputs(wtPath,dtw);

% Multirate identity filters of the first tree
[g,a] = nodesMultid(wtPath,rangeLoc,rangeOut,dtw);

% Multirate identity filters of the second tree
dtw.nodes = dtw.dualnodes;
g2 = nodesMultid(wtPath,rangeLoc,rangeOut,dtw);

% Return the filterbanks before doing the alignment
info.g1 = g;
info.g2 = g2;

% Align filter offsets so they can be summed
for ii = 1:numel(g)
   % Sanity checks
   assert(g{ii}.offset<=0,sprintf('%s: Invalid wavelet filters.',upper(mfilename)));
   assert(g2{ii}.offset<=0,sprintf('%s: Invalid wavelet filters.',upper(mfilename)));
    
   offdiff = g{ii}.offset-g2{ii}.offset;
   if offdiff>0
       g{ii}.offset = g{ii}.offset - offdiff;
       g{ii}.h = [zeros(offdiff,1);g{ii}.h(:)];
   elseif offdiff<0
       g2{ii}.offset = g2{ii}.offset + offdiff;
       g2{ii}.h = [zeros(-offdiff,1);g2{ii}.h(:)];
   end
   
   lendiff = numel(g{ii}.h) - numel(g2{ii}.h);
   if lendiff~=0
       maxLen = max(cellfun(@(gEl) numel(gEl.h),g));
       g{ii}.h = postpad(g{ii}.h,maxLen);
       g2{ii}.h = postpad(g2{ii}.h,maxLen);
   end
end


% Filters covering the positive frequencies
g = cellfun(@(gEl,g2El) setfield(gEl,'h',(gEl.h+1i*g2El.h)),g,g2,'UniformOutput',0);

% Mirror the filters when negative frequency filters are required too
if ~do_real
   gneg = cellfun(@(gEl,g2El) setfield(gEl,'h',(gEl.h-1i*g2El.h)),g,g2,'UniformOutput',0);
   g = [g;gneg(end:-1:1)];
   a = [a;a(end:-1:1)];
end


