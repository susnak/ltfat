function [g,info] = nsgabwin(g,a,M);
%NSGABWIN  Compute a set of non-stationary Gabor windows from text or cell array
%   Usage: [g,info] = nsgabwin(g,a,M);
%
%   `[g,info]=nsgabwin(g,a,M,L)` computes a window that fits well with
%   time shift *a*, number of channels *M* and and transform length *L*.
%   The window itself is as a cell array containing additional parameters.
%
%   The window can be specified directly as a cell array of vectors of
%   numerical values. In this case, `nsgabwin` only checks assumptions
%   about transform sizes etc.
%
%   `[g,info]=nsgabwin(g,a,M)` does the same, but the windows must be FIR
%   windows, as the transform length is unspecified.
%
%   The window can also be specified as cell array. The possibilities are:
%
%     `{'dual',...}`
%         Canonical dual window of whatever follows. See the examples below.
%
%     `{'tight',...}`
%         Canonical tight window of whatever follows. See the examples below.
%
%   The structure *info* provides some information about the computed
%   window:
%
%     `info.gauss`
%        True if the windows are Gaussian.
%
%     `info.tfr`
%        Time/frequency support ratios of the window. Set whenever it makes sense.
%
%     `info.isfir`
%        Input is an FIR window
%
%     `info.isdual`
%        Output is the dual window of the auxiliary window.
%
%     `info.istight`
%        Output is known to be a tight window.
%
%     `info.auxinfo`
%        Info about auxiliary window.
%   
%     `info.gl`
%        Length of window.
%
%   See also: filterbank, filterbankdual, filterbankrealdual
  
% Assert correct input.
if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ~iscell(g)
  error('%s: Window g must be a cell array.',upper(mfilename));
end;

if isempty(g)
  error('%s: Window g must not be empty.',upper(mfilename));
end;

if ischar(g{1})
  winname=lower(g{1});
  switch(winname)
   case {'dual'}
    [g,info.auxinfo] = nsgabwin(g{2},a,M);
      g = nsgabdual(g,a,M);
      info.isdual=1;
   
   case {'tight'}
    [g,info.auxinfo] = nsgabwin(g{2},a,M);    
    g = nsgabtight(g,a,M);
    info.istight=1;
    
otherwise
    error('%s: Unsupported window type %s.',winname,upper(mfilename));
  end;
end;
  

