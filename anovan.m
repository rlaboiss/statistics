## Copyright (C) 2003 Andy Adler
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{pval}, @var{f}, @var{df_b}, @var{df_w}] =} anovan (@var{data}, @var{grps})
## Perform a multi-way analysis of variance (ANOVA).  The goal is to test
## whether the population means of data taken from @var{k} different
## groups are all equal.
##
## Data is a single vector @var{data} with groups specified by
## a corresponding matrix of group labels @var{grps}, where @var{grps}
## has the same number of rows as @var{data}. For example, if
## @var{data} = [1.1;1.2]; @var{grps}= [1,2,1; 1,5,2];
## then data point 1.1 was measured under conditions 1,2,1 and
## data point 1.2 was measured under conditions 1,5,2.
## Note that groups do not need to be sequentially numbered.
##
## Under the null of constant means, the statistic @var{f} follows an F
## distribution with @var{df_b} and @var{df_w} degrees of freedom.
##
## The p-value (1 minus the CDF of this distribution at @var{f}) is
## returned in @var{pval}.
##
## If no output argument is given, the standard one-way ANOVA table is
## printed.
##
## NOTE: this function has not yet been tested with > 2 ways
## @end deftypefn

## Author: Andy Adler <adler@site.uottawa.ca>
## Based on code by: KH <Kurt.Hornik@ci.tuwien.ac.at>
## $Id$

function [pval, f, df_b, df_w] = anovan (data, grps)

    if nargin <= 1
        usage ("anovan (data, grps)");
    end

    if ~isvector (data)
          error ("anova: for `anova (data, grps)', data must be a vector");
    endif

    nd = size (grps,1); # number of data points
    nw = size (grps,2); # number of anova "ways"
    if (~ isvector (data) || (length(data) ~= nd))
      error ("anova: grps must be a matrix of the same number of rows as data");
    endif

    [g,grp_map]   = relabel_groups (grps);
    max_interact  = length(grp_map); #must be maximum currently
    ng = length(grp_map);
    int_tbl       = interact_tbl (nw, ng, max_interact );
    [gn, gs, gss] = raw_sums(data, g, ng, int_tbl);

    stats_tbl = int_tbl(2:size(int_tbl,1),:)>0;
    nstats= size(stats_tbl,1);
    stats= zeros( nstats+1, 5); # SS, DF, MS, F, p
    for i= 1:nstats
        [SS, DF, MS]= factor_sums( gn, gs, gss, stats_tbl(i,:), ng, nw);
        stats(i,1:3)= [SS, DF, MS];
    end

    # The Mean squared error is the data - avg for each possible measurement
    # This calculation doesn't work unless there is replication for all grps
#   SSE= sum( gss(sel) ) - sum( gs(sel).^2 ./ gn(sel) );  
    SST= gss(1) - gs(1)^2/gn(1);
    SSE= SST - sum(stats(:,1));
    sel = select_pat( ones(1,nw), ng, nw);
    DFE= sum( (gn(sel)-1).*(gn(sel)>0) );
    MSE= SSE/DFE;
    stats(nstats+1,1:3)= [SSE, DFE, MSE];

    for i= 1:nstats
        MS= stats(i,3);
        F= MS/MSE;
        pval = 1 - f_cdf (F, DF, DFE);
        stats(i,4:5)= [F, pval];
    end

    printout( stats, stats_tbl );
endfunction


# relabel groups to a mapping from 1 to ng
# Input
#   grps    input grouping
# Output
#   g       relabelled grouping
#   grp_map map from output to input grouping
function [g,grp_map] = relabel_groups(grps)
    grp_vec= vec(grps);
    s= sort (grp_vec);
    uniq = 1+[0;find(diff(s))];
    # mapping from new grps to old groups
    grp_map = s(uniq);
    # create new group g
    ngroups= length(uniq);
    g= zeros(size(grp_vec));
    for i = 1:ngroups
        g( find( grp_vec== grp_map(i) ) ) = i;
    end
    g= reshape(g, size(grps));
endfunction

# Create interaction table
#
# Input: 
#    nw            number of "ways"
#    ng            number of ANOVA groups
#    max_interact  maximum number of interactions to consider
#                  default is nw
function int_tbl =interact_tbl(nw, ng, max_interact)
    if nargin<3
        max_interact= nw;
    end
    combin= 2^nw;
    interact_tbl= zeros( combin, nw);
    idx= (0:combin-1)';
    for i=1:nw;
       interact_tbl(:,i) = ( rem(idx,2^i) >= 2^(i-1) ); 
    end

    # find elements with more than max_interact 1's
    idx = ( sum(interact_tbl',1) > max_interact );
    int_tbl(idx,:) =[];
    combin= size(interact_tbl,1); # update value

    #scale interact_tbl 
    # use ng+1 to map combinations of groups to integers
    # this would be lots easier with a hash data structure
    int_tbl = interact_tbl .* (ones(combin,1) * (ng+1).^(0:nw-1) );
endfunction 

# Calculate sums for each combination
#
# Input: 
#    g             relabelled grouping matrix
#    ng            number of ANOVA groups
#    max_interact
#
# Output (virtual (ng+1)x(nw) matrices):
#    gn            number of data sums in each group
#    gs            sum of data in each group
#    gss           sumsqr of data in each group
function    [gn, gs, gss] = raw_sums(data, g, ng, int_tbl);
    nw=    size(g,2);
    ndata= size(g,1);
    gn= gs= gss=  zeros((ng+1)^nw, 1);
    for i=1:ndata
        # need offset by one for indexing
        datapt= data(i);
        idx = 1+ int_tbl*g(i,:)';
        gn(idx)  +=1;
        gs(idx)  +=datapt;
        gss(idx) +=datapt^2;
    end
endfunction

# Calcualte the various factor sums
# Input:  
#    gn            number of data sums in each group
#    gs            sum of data in each group
#    gss           sumsqr of data in each group
#    select        binary vector of factor for this "way"?
#    ng            number of ANOVA groups
#    nw            number of ways

function [SS,DF]= raw_factor_sums( gn, gs, gss, select, ng, nw);
   sel= select_pat( select, ng, nw);
   ss_raw=   gs(sel).^2 ./ gn(sel);
   SS= sum( ss_raw( ~isnan(ss_raw) ));
   if length(find(select>0))==1
       DF= sum(gn(sel)>0)-1;
   else
       DF= 1; #this isn't the real DF, but needed to multiply
   end
endfunction

function [SS, DF, MS]= factor_sums( gn, gs, gss, select, ng, nw);
   SS=0;
   DF=1;

   ff = find(select);
   lff= length(ff);
   # zero terms added, one term subtracted, two added, etc
   for i= 0:2^lff-1
       remove= find( rem( floor( i * 2.^(-lff+1:0) ), 2) );
       sel1= select;
       if ~isempty(remove)
           sel1( ff( remove ) )=0;
       end
       [raw_sum,raw_df]= raw_factor_sums(gn,gs,gss,sel1,ng,nw);
       
       add_sub= (-1)^length(remove);
       SS+= add_sub*raw_sum;
       DF*= raw_df;
   end

   MS=  SS/DF;
endfunction

# Calcualte the various factor sums
# Input:  
#    select        binary vector of factor for this "way"?
#    ng            number of ANOVA groups
#    nw            number of ways
function sel= select_pat( select, ng, nw);
   # if select(i) is zero, remove nonzeros
   # if select(i) is zero, remove zero terms for i
   static field=[];

   if length(select) ~= nw;
       error("length of select must be = nw");
   end
   ng1= ng+1;

   if isempty(field)
       # expand 0:(ng+1)^nw in base ng+1
       field= (0:(ng1)^nw-1)'* ng1.^(-nw+1:0);
       field= rem( floor( field), ng1);
       # select zero or non-zero elements
       field= field>0;
   end
   sel= find( all( field == ones(ng1^nw,1)*select(:)', 2) );
endfunction


function printout( stats, stats_tbl );
  nw= size( stats_tbl,2);
  [jnk,order]= sort( sum(stats_tbl,2) );

  printf('\n%d-way ANOVA Table (Factors A%s):\n\n', nw, ...
         sprintf(',%c',toascii('A')+(1:nw-1)) );
  printf('Source of Variation        Sum Sqr   df      MeanSS    Fval   p-value\n');
  printf('*********************************************************************\n');
  printf('Error                  %10.2f  %4d %10.2f\n', stats( size(stats,1),1:3));
  
  for i= order(:)'
      str=  sprintf(' %c x',toascii('A')+find(stats_tbl(i,:)>0)-1 );
      str= str(1:length(str)-2); # remove x
      printf('Factor %15s %10.2f  %4d %10.2f  %7.3f  %7.6f\n', ...
         str, stats(i,:) );
  end
  printf('\n');
endfunction

# Test Data from http://maths.sci.shu.ac.uk/distance/stats/14.shtml
data=[7  9  9  8 12 10 ...
      9  8 10 11 13 13 ...
      9 10 10 12 10 12]';
grp = [1,1; 1,1; 1,2; 1,2; 1,3; 1,3;
       2,1; 2,1; 2,2; 2,2; 2,3; 2,3;
       3,1; 3,1; 3,2; 3,2; 3,3; 3,3];
data=[7  9  9  8 12 10  9  8 ...
      9  8 10 11 13 13 10 11 ...
      9 10 10 12 10 12 10 12]';
grp = [1,4; 1,4; 1,5; 1,5; 1,6; 1,6; 1,7; 1,7;
       2,4; 2,4; 2,5; 2,5; 2,6; 2,6; 2,7; 2,7;
       3,4; 3,4; 3,5; 3,5; 3,6; 3,6; 3,7; 3,7];
# Test Data from http://maths.sci.shu.ac.uk/distance/stats/13.shtml
data=[7.56  9.68 11.65  ...
      9.98  9.69 10.69  ...
      7.23 10.49 11.77  ...
      8.22  8.55 10.72  ...
      7.59  8.30 12.36]'; 
grp = [1,1;1,2;1,3;
       2,1;2,2;2,3;
       3,1;3,2;3,3;
       4,1;4,2;4,3;
       5,1;5,2;5,3];



