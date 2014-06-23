function f=idtwfbreal(c,par,varargin)
%IWFBT   Inverse Wavelet Filterbank Tree
%   Usage:  f=iwfbt(c,info);
%           f=iwfbt(c,wt,Ls);
%
%   Input parameters:
%         c       : Coefficients stored in a cell-array.
%         info,wt : Transform parameters struct/Wavelet Filterbank tree
%         Ls      : Length of the reconstructed signal.
%
%   Output parameters:
%         f     : Reconstructed data.
%
%   `f = iwfbt(c,info)` reconstructs signal *f* from the coefficients *c*
%   using parameters from `info` struct. both returned by |wfbt| function.
%
%   `f = iwfbt(c,wt,Ls)` reconstructs signal *f* from the coefficients *c*
%   using filter bank tree defined by *wt*. Plese see |wfbt| function for
%   possible formats of *wt*. The *Ls* parameter is mandatory due to the
%   ambiguity of reconstruction lengths introduced by the subsampling
%   operation and by boundary treatment methods. Note that the same flag as
%   in the |wfbt| function have to be used, otherwise perfect reconstruction
%   cannot be obtained. Please see help for |wfbt| for description of the
%   flags.
%
%   Examples:
%   ---------
%
%   A simple example showing perfect reconstruction using the "full decomposition" wavelet tree:::
%
%     f = gspi;
%     J = 7;
%     wtdef = {'db10',J,'full'};
%     c = wfbt(f,wtdef);
%     fhat = iwfbt(c,wtdef,length(f));
%     % The following should give (almost) zero
%     norm(f-fhat)
%
%   See also: wfbt, wfbtinit


complainif_notenoughargs(nargin,2,'IDTWFBREAL');

if(~iscell(c))
   error('%s: Unrecognized coefficient format.',upper(mfilename));
end

if(isstruct(par)&&isfield(par,'fname'))
   complainif_toomanyargs(nargin,2,'IDTWFBREAL');
   
   if ~strcmpi(par.fname,'dtwfbreal')
      error(['%s: Wrong func name in info struct. ',...
             ' The info parameter was created by %s.'],...
             upper(mfilename),par.fname);
   end

   wt = dtwfbinit({'dual',par.wt},par.fOrder);
   Ls = par.Ls;
   ext = par.ext;
   L = wfbtlength(Ls,wt,ext);
else
   complainif_notenoughargs(nargin,3,'IDTWFBREAL');

   %% PARSE INPUT
   definput.keyvals.Ls=[];
   definput.keyvals.dim=1;
   definput.import = {'fwt','wfbtcommon'};

   [flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);
   complainif_notposint(Ls,'Ls');

   ext = flags.ext;
   % Initialize the wavelet tree structure
   wt = dtwfbinit(par,flags.forder);

   [Lc,L]=wfbtclength(Ls,wt,ext);

   % Do a sanity check
   if ~isequal(Lc,cellfun(@(cEl) size(cEl,1),c))
      error(['%s: The coefficient subband lengths do not comply with the'...
             ' signal length *Ls*.'],upper(mfilename));
   end
end

%% ----- step 3 : Run computation
wtPath = nodesBForder(wt,'rev');
outLengths = nodeInLen(wtPath,L,strcmpi(ext,'per'),wt);
outLengths(end) = L;
rangeLoc = rangeInLocalOutputs(wtPath,wt);
rangeOut = rangeInOutputs(wtPath,wt);

% Split the coefficients
creal = cellfun(@real,c,'UniformOutput',0);
cimag = cellfun(@imag,c,'UniformOutput',0);

f1 = comp_iwfbt(creal,wt.nodes(wtPath),outLengths,rangeLoc,rangeOut,ext);
f2 = comp_iwfbt(cimag,wt.dualnodes(wtPath),outLengths,rangeLoc,rangeOut,ext);
f = real(postpad((f1+f2)/2,Ls));
