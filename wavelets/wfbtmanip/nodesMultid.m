function [g,a] = nodesMultid(wtPath,rangeLoc,rangeOut,wt)
%NODESMULTID Filter tree multirate identity filterbank
%   Usage:  [g,a]=nodesMultid(wtPath,rangeLoc,rangeOut,wt);
%
%   Input parameters:
%         wtPath   : Indexes of nodes to be processed in that order.
%         rangeLoc : Idxs of each node terminal outputs. Length  
%                    cell array of vectors.
%         rangeOut : Output subband idxs of each node terminal outputs.
%         wt       : Filter-Tree defining structure.
%
%   Output parameters:
%         g   : Cell array containing filters
%         a   : Vector of subsampling factors

%clean cache
nodePredecesorsMultId();


% number of outputs of the tree
treeOutputs = sum(cellfun(@(rEl) numel(rEl),rangeOut));

g = cell(treeOutputs,1);
a = zeros(treeOutputs,1);

for ii = 1:numel(wtPath)
   iiNode = wtPath(ii);
   hmi = nodePredecesorsMultId(iiNode,wt);
   locRange = rangeLoc{ii};
   outRange = rangeOut{ii};
   for jj = 1:length(locRange)
      tmpUpsFac = nodeFiltUps(iiNode,wt);
      tmpFilt = wt.nodes{iiNode}.g{locRange(jj)};
      g{outRange(jj)} = struct();
      % Involution is here because of the filterbank convention is
      % different from the one used in wavelet filtering.
      g{outRange(jj)}.h = conj(flipud(conv2(hmi,comp_ups(tmpFilt.h(:),tmpUpsFac,1))));
      g{outRange(jj)}.offset = 1-numel(g{outRange(jj)}.h)+nodePredecesorsOrig(-tmpFilt.offset,iiNode,wt);
   end
   atmp = nodeSub(iiNode,wt);
   a(outRange) = atmp{1}(locRange);
end
        
        
% clean the cache
nodePredecesorsMultId();


function hmi = nodePredecesorsMultId(nodeNo,wt)
% Build multirate identity of nodes preceeding nodeNo
% chache of the intermediate multirate identities
persistent multIdPre;
% if no paramerer passed, clear the cache
if(nargin==0),  multIdPre = {}; return; end
% in case nodePredecesorsMultId with nodeNo was called before

% if(~isempty(multIdPre))
%   if(length(multIdPre)>=nodeNo&&~isempty(multIdPre{pre(jj)}))
%     hmi = multIdPre{nodeNo};
%   end
% end

startIdx = 1;
hmi = [1];
pre = nodePredecesors(nodeNo,wt);
pre = [nodeNo,pre];
for jj = 1:length(pre)
  if(~isempty(multIdPre))
     if(length(multIdPre)>=pre(jj)&&~isempty(multIdPre{pre(jj)}))
       hmi = multIdPre{pre(jj)};
       startIdx = length(pre)+1 -jj;
       break;
     end
  end
end

pre = pre(end:-1:1);

for ii=startIdx:length(pre)-1
    id = pre(ii);
    hcurr = wt.nodes{id}.g{wt.children{id}==pre(ii+1)}.h(:);
    hcurr = comp_ups(hcurr,nodeFiltUps(id,wt),1);
    hmi = conv2(hmi,hcurr);
end

function predori = nodePredecesorsOrig(baseOrig,nodeNo,wt)
% Calculate total offset of a filter identical to a path from root to 
% node nodeNo in treeStruct. The last filter in the chain itself has
% offset equal to baseOrig

% Get nodes from the path from root to nodeNo
pre = nodePredecesors(nodeNo,wt);
pre = pre(end:-1:1);

% Shortcut out if nodeNo is the root node
if(isempty(pre))
 predori = baseOrig;
 return;
end

% Add the curernt node to the list
pre(end+1) = nodeNo;
predori = 0;
% Do from root to nodeNo
for ii=1:length(pre)-1
    % Get node id
    id = pre(ii);
    % Find which path to go
    childLogInd = wt.children{id}==pre(ii+1);
    % Obtain offset
    tmpOffset = -wt.nodes{id}.g{childLogInd}.offset;
    % Update te current offset
    predori = nodeFiltUps(id,wt)*tmpOffset + predori;
end

% We do not know here which filter from the node are we working with so
% this line substitutes the last iteration of the previous loop
predori = nodeFiltUps(nodeNo,wt)*baseOrig + predori;


