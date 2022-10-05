#! /usr/local/bin/octave -qf
# a sample Octave program 
printf ("%s", program_name ());
    arg_list = argv ();
    for i = 1:nargin
      printf (" %s", arg_list{i});
    endfor
    printf ("\n");
# now for the Oxford stuff
pkg load signal
fnam = arg_list{1};
outfile = arg_list{2};
minPeakHeight = str2num(arg_list{3});
fid = fopen (fnam);
data = csvread(fid);
fclose (fid);
[pks, locs, extras] = findpeaks(data,"MinPeakHeight", minPeakHeight, "DoubleSided");
pks;
locs;
extras.parabol.x;
pp1 = {extras.parabol.pp}';
pp1(3,1);
% fidout = fopen(outfile, 'w')
dlmwrite(outfile, locs)
dlmwrite(outfile, pks, '-append')
% dlmwrite(outfile, extras.parabol.x, '-append')
% dlmwrite(outfile, extras.parabol.pp, '-append')
dlmwrite(outfile, extras.height, '-append')
dlmwrite(outfile, extras.baseline, '-append')
dlmwrite(outfile, extras.roots(:,1)', '-append')
dlmwrite(outfile, extras.roots(:,2)', '-append')

