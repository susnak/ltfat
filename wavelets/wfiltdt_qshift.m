function [h,g,a,info] = wfiltdt_qshift(N)
%WFILT_SYMORTH  Improved Orthogonality and Symmetry properties 
%
%   Usage: [h,g,a] = wfilt_symorth(N);
%
%   `[h,g,a]=wfilt_qshift(N)` with *N\in {1,2,3}*
%
%   Examples:
%   ---------
%   :::
%     figure(1);
%     wfiltinfo('ana:symds1');
% 
%   References: kingsbury2000
%

info.istight = 1;
a = [2;2;2;2];

switch(N)
 case 1
    % Example 1. from the reference. Symmetric near-orthogonal
    hlp = [
          0.03516384   % z^4
          0             
         -0.08832942   % z^2    
          0.23389032   % z^1
          0.76027237   % z^0 <-- origin
          0.58751830   % z^-1
          0
         -0.11430184   % z^-3
          0
          0
    ];

    d = 4;

case 2
    % Example 2. From the reference. 
    hlp = [
          0.00325314
         -0.00388321
          0.03466035
         -0.03887280
         -0.11720389
          0.27529538
          0.75614564 % <-- origin
          0.56881042
          0.01186609
         -0.10671180
          0.02382538
          0.01702522
         -0.00543948
         -0.00455690
    ];
case 3
    
      % Example 3. From the reference. 
    hlp = [
        -0.00228413   % z^8
         0.00120989   % z^7  
        -0.01183479   % z^6
         0.00128346   % z^5
         0.04436522   % z^4
        -0.05327611   % z^3
        -0.11330589   % z^2
         0.28090286   % z^1
         0.75281604   % z^0 <-- origin
         0.56580807   % z^-1
         0.02455015   % z^-2
        -0.12018854   % z^-3
         0.01815649   % z^-4
         0.03152638   % z^-5
        -0.00662879   % z^-6
        -0.00257617   % z^-7
         0.00127756   % z^-8
         0.00241187   % z^-9
    ];

case 4
    % Generated using sowtware by Prof. Nick Kingsbury
    % http://sigproc.eng.cam.ac.uk/foswiki/pub/Main/NGK/qshiftgen.zip
    % hlp = qshiftgen([26,1/3,1,1,1]); hlp = hlp/norm(hlp);
    hlp = [9.69366641745754e-05;3.27432154422329e-05;...
          -0.000372508343063683;0.000265822010615719;0.00420106192587724;...
          -0.000851685012123638;-0.0194099330331787;0.0147647107515980;...
           0.0510823932256706;-0.0665925933116249;-0.111697066192884;...
           0.290378669551088;0.744691179589718;0.565900493333378;...
           0.0350864022239272;-0.130600567220340;0.0106673205278386;...
           0.0450881734744377;-0.0116452911371123;-0.0119726865351617;...
           0.00464728269258923;0.00156428519208473;-0.000193257944314871;...
           -0.000997377567082884;-4.77392249288136e-05;0.000126793092000602];

case 5
    % hlp = qshiftgen([38,1/3,1,1,1]); hlp = hlp/norm(hlp);
    hlp = [-5.60092763439975e-05;5.48406024854987e-05;...
           9.19038839527110e-05;-8.70402717115631e-05;...
           -0.000220539629671714;0.000281927965110883;...
           0.000785261918054103;-0.000284818785208508;...
           -0.00347903355232634;0.00106170047948173;0.0112918523131508;...
           -0.00661418560030456;-0.0275662474083655;0.0256353066092428;...
           0.0558968886331913;-0.0797279144129786;-0.109398280267440;...
           0.299471557624693;0.735969669961052;0.565697237934440;...
           0.0456103326499340;-0.139358668718518;0.00372525621820399;...
           0.0578449676250133;-0.0102649107519070;-0.0227204202705973;...
           0.00707541881254841;0.00739220672191233;-0.00294716840272524;...
           -0.00194108140290843;0.000711544068828577;0.000568969033823645;...
           -0.000141696506233205;-0.000156935421570824;...
           -9.35020254608262e-07;-2.40218618976427e-05;...
           2.34727799564078e-05;1.31525730967674e-05];
  otherwise
        error('%s: No such filters.',upper(mfilename)); 

end
    % numel(hlp) must be even
    d = numel(hlp)/2 - 1; 
    range = (0:numel(hlp)-1) -d;
    
    % Create the filters according to the reference paper.
    % NOTE: We are using  
    %
    % REMARK: The phase of the alternating +1 and -1 is crucial here.
    %         
    harr = [...
            flipud(hlp),...
            (-1).^(range).'.*hlp,...
            hlp,...
            (-1).^(range).'.*flipud(hlp),...
            ];
        
        
    % Reverese the filters to obtain the synthesis filters
    % harr = flipud(harr);

    % d gets changed
    % info.d = [d, d, d, d] + 1;

garr = harr;  
h=mat2cell(harr,size(harr,1),ones(1,size(harr,2)));
g=mat2cell(garr,size(garr,1),ones(1,size(garr,2)));


info.defaultfirst = 'symorth1';
info.defaultleaf = 'symorth1';


