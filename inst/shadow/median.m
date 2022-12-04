## Copyright (C) 2022 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} @var{y} = median (@var{x})
## @deftypefnx {statistics} @var{y} = median (@var{x}, "all")
## @deftypefnx {statistics} @var{y} = median (@var{x}, @var{dim})
## @deftypefnx {statistics} @var{y} = median (@var{x}, @var{vecdim})
## @deftypefnx {statistics} @var{y} = median (@dots{}, @var{outtype})
## @deftypefnx {statistics} @var{y} = median (@dots{}, @var{nanflag})
##
## Compute the median of the elements of @var{x}.
##
## When the elements of @var{x} are sorted, say
## @code{@var{s} = sort (@var{x})}, the median is defined as
## @tex
## $$
## {\rm median} (x) =
##   \cases{s(\lceil N/2\rceil), & $N$ odd;\cr
##           (s(N/2)+s(N/2+1))/2, & $N$ even.}
## $$
## where $N$ is the number of elements of @var{x}.
##
## @end tex
## @ifnottex
##
## @example
## @group
##              |  @var{s}(ceil(N/2))           N odd
## median (@var{x}) = |
##              | (@var{s}(N/2) + @var{s}(N/2+1))/2   N even
## @end group
## @end example
##
## @end ifnottex
## @itemize
## @item
## If @var{x} is a matrix, then @code{median(@var{x})} returns a row vector
## with the mean of each columns in @var{x}.
##
## @item
## If @var{x} is a multidimensional array, then @code{median(@var{x})}
## operates along the first nonsingleton dimension of @var{x}.
## @end itemize
##
## @code{median(@var{x}, "all")} returns the median of all the elements in
## @var{x}.
##
## @code{median(@var{x}, @var{dim})} returns the median along the
## operating dimension @var{dim} of @var{x}.
##
## @code{median(@var{x}, @var{vecdim})} returns the median over the
## dimensions specified in the vector @var{vecdim}.  For example, if @var{x}
## is a 2-by-3-by-4 array, then @code{median(@var{x}, [1 2])} returns a 1-by-4
## array.  Each element of the output array is the median of the elements on
## the corresponding page of @var{x}.  NOTE! @var{vecdim} MUST index at least
## N-3 dimensions of @var{x}, where @code{N = length (size (@var{x}))} and
## N <= 10.  If @var{vecdim} indexes all dimensions of @var{x}, then it is
## equivalent to @code{median(@var{x}, "all")}.
##
## @code{median(@dots{}, @var{outtype})} returns the median with a specified
## data type, using any of the input arguments in the previous syntaxes.
## @var{outtype} can be "default", "double", or "native".
##
## @code{median(@dots{}, @var{nanflag})} specifies whether to exclude NaN values
## from the calculation, using any of the input argument combinations in
## previous syntaxes.  By default, NaN values are included in the calculation
## (@var{nanflag} has the value "includenan").  To exclude NaN values, set the
## value of @var{nanflag} to "omitnan".
##
## @seealso{mean, mode}
## @end deftypefn

function y = median (x, varargin)

  if (nargin < 1 || nargin > 4 || any (cellfun (@isnumeric, varargin(2:end))))
    print_usage ();
  endif

  ## Check all char arguments.
  all_flag = false;
  omitnan = false;
  outtype = "default";

  for i = 1:length (varargin)
    if (ischar (varargin{i}))
      switch (varargin{i})
        case "all"
          all_flag = true;
        case "omitnan"
          omitnan = true;
        case "includenan"
          omitnan = false;
        case {"default", "double", "native"}
          outtype = varargin{i};
        otherwise
          print_usage ();
      endswitch
    endif
  endfor
  varargin(cellfun (@ischar, varargin)) = [];

  if (((length (varargin) == 1) && ! (isnumeric (varargin{1}))) ...
      || (length (varargin) > 1))
    print_usage ();
  endif

  if (! (isnumeric (x) || islogical (x)))
    error ("median: X must be either a numeric or boolean");
  endif

  if (length (varargin) == 0)

    ## Single numeric input argument, no dimensions given.
    if (all_flag)
      if (omitnan)
        x = x(! isnan (x));
      endif
      n = length (x(:));
      x = sort (x(:), 1);
      k = floor ((n + 1) / 2);
      if (mod (n, 2) == 1)
        y = x(k);
      else
        y = x(k) + x(k+1) / 2;
      endif
      ## Inject NaNs where needed, to be consistent with Matlab.
      if (! omitnan && ! islogical (x))
        y(any (isnan (x))) = NaN;
      endif
    else
      sz = size (x);
      dim = find (sz > 1, 1);
      if length (dim) == 0
        dim = 1;
      endif
      x = sort (x, dim);
      if (omitnan)
        n = sum (! isnan (x), dim);
      else
        n = sum (isnan (x) | ! isnan (x), dim);
      endif
      k = floor ((n + 1) ./ 2);
      for i = 1:numel (k)
        if (mod (n(i), 2) == 1)
          z(i) = {(nth_element (x, k(i), dim))};
        else
          z(i) = {(sum (nth_element (x, k(i):k(i)+1, dim), dim, "native") / 2)};
        endif
      endfor
      ## Collect correct elements
      szargs = cell (1, ndims (x));
      szz = size (z{1});
      for i = 1:numel (k)
        [szargs{:}] = ind2sub (szz, i);
        y(szargs{:}) = z{i}(szargs{:});
      endfor
      ## Inject NaNs where needed, to be consistent with Matlab.
      if (! omitnan && ! islogical (x))
        y(any (isnan (x), dim)) = NaN;
      endif
    endif

  else

    ## Two numeric input arguments, dimensions given.  Note scalar is vector!
    vecdim = varargin{1};
    if (! (isvector (vecdim) && all (vecdim)) || any (rem (vecdim, 1)))
      error ("median: DIM must be a positive integer scalar or vector");
    endif

    if (isscalar (vecdim))
      dim = vecdim;
      x = sort (x, dim);
      if (omitnan)
        n = sum (! isnan (x), dim);
      else
        n = sum (isnan (x) | ! isnan (x), dim);
      endif
      k = floor ((n + 1) ./ 2);
      for i = 1:numel (k)
        if (mod (n(i), 2) == 1)
          z(i) = {(nth_element (x, k(i), dim))};
        else
          z(i) = {(sum (nth_element (x, k(i):k(i)+1, dim), dim, "native") / 2)};
        endif
      endfor
      ## Collect correct elements
      szargs = cell (1, ndims (x));
      szz = size (z{1});
      for i = 1:numel (k)
        [szargs{:}] = ind2sub (szz, i);
        y(szargs{:}) = z{i}(szargs{:});
      endfor
      ## Inject NaNs where needed, to be consistent with Matlab.
      if (! omitnan && ! islogical (x))
        y(any (isnan (x), dim)) = NaN;
      endif

    else

      sz = size (x);
      ndims = length (sz);
      misdim = [1:ndims];

      ## keep remaining dimensions
      for i = 1:length (vecdim)
        misdim(misdim == vecdim(i)) = [];
      endfor

      switch (length (misdim))
        ## if all dimensions are given, compute x(:)
        case 0
          if (omitnan)
            x = x(! isnan (x));
          endif
          n = length (x(:));
          x = sort (x(:), 1);
          k = floor ((n + 1) / 2);
          if (mod (n, 2) == 1)
            y = x(k);
          else
            y = x(k) + x(k+1) / 2;
          endif
          ## Inject NaNs where needed, to be consistent with Matlab.
          if (! omitnan && ! islogical (x))
            y(any (isnan (x))) = NaN;
          endif

        ## for 1 dimension left, return column vector
        case 1
          if (ndims > 10)
            error ("median: vecdim works on X of up to 10 dimensions");
          endif
          x = permute (x, [misdim, vecdim]);
          for i = 1:size (x, 1)
            x_vec = x(i,:,:,:,:,:,:,:,:,:)(:);
            if (omitnan)
              x_vec = x_vec(! isnan (x_vec));
            endif
            n = length (x_vec(:));
            x_vec = sort (x_vec(:), 1);
            k = floor ((n + 1) / 2);
            if (mod (n, 2) == 1)
              y(i) = x_vec(k);
            else
              y(i) = (x_vec(k) + x_vec(k+1)) / 2;
            endif
            ## Inject NaNs where needed, to be consistent with Matlab.
            if (! omitnan && any (isnan (x_vec)) && ! islogical (x))
              y(i) = NaN;
            endif
          endfor

        ## for 2 dimensions left, return matrix
        case 2
          if (ndims > 10)
            error ("median: vecdim works on X of up to 10 dimensions");
          endif
          x = permute (x, [misdim, vecdim]);
          for i = 1:size (x, 1)
            for j = 1:size (x, 2)
              x_vec = x(i,j,:,:,:,:,:,:,:,:)(:);
              if (omitnan)
                x_vec = x_vec(! isnan (x_vec));
              endif
              n = length (x_vec(:));
              x_vec = sort (x_vec(:), 1);
              k = floor ((n + 1) / 2);
              if (mod (n, 2) == 1)
                y(i,j) = x_vec(k);
              else
                y(i,j) = (x_vec(k) + x_vec(k+1)) / 2;
              endif
              ## Inject NaNs where needed, to be consistent with Matlab.
              if (! omitnan && any (isnan (x_vec)) && ! islogical (x))
                y(i,j) = NaN;
              endif
            endfor
          endfor

        ## for 3 dimensions left, return matrix
        case 3
          if (ndims > 10)
            error ("median: vecdim works on X of up to 10 dimensions");
          endif
          x = permute (x, [misdim, vecdim]);
          for i = 1:size (x, 1)
            for j = 1:size (x, 2)
              for l = 1:size (x, 2)
                x_vec = x(i,j,k,:,:,:,:,:,:,:)(:);
                if (omitnan)
                  x_vec = x_vec(! isnan (x_vec));
                endif
                n = length (x_vec(:));
                x_vec = sort (x_vec(:), 1);
                k = floor ((n + 1) / 2);
                if (mod (n, 2) == 1)
                  y(i,j,l) = x_vec(k);
                else
                  y(i,j,l) = (x_vec(k) + x_vec(k+1)) / 2;
                endif
                ## Inject NaNs where needed, to be consistent with Matlab.
                if (! omitnan && any (isnan (x_vec)) && ! islogical (x))
                  y(i,j,l) = NaN;
                endif
              endfor
            endfor
          endfor
        ## for more that 3 dimensions left, print usage
        otherwise
          error ("median: vecdim must index at least N-3 dimensions of X");
      endswitch

    endif

  endif

  ## Convert output as requested
  switch (outtype)
    case "default"
      ## do nothing, the operators already do the right thing
    case "double"
      y = double (y);
    case "native"
      if (! islogical (x))
        y = cast (y, class (x));
      endif
    otherwise
      error ("mean: OUTTYPE '%s' not recognized", outtype);
  endswitch

endfunction


## Test input validation
%!error <Invalid call to median.  Correct usage is> median ()
%!error <Invalid call to median.  Correct usage is> median (1, 2, 3)
%!error <Invalid call to median.  Correct usage is> median (1, 2, 3, 4)
%!error <Invalid call to median.  Correct usage is> median (1, "all", 3)
%!error <Invalid call to median.  Correct usage is> median (1, "b")
%!error <Invalid call to median.  Correct usage is> median (1, 1, "foo")
%!error <median: X must be either a numeric or boolean> median ({1:5})
%!error <median: X must be either a numeric or boolean> median ("char")
%!error <median: DIM must be a positive integer> median (1, ones (2,2))
%!error <median: DIM must be a positive integer> median (1, 1.5)
%!error <median: DIM must be a positive integer> median (1, 0)
%!error <median: vecdim works on X of up to 10 dimensions> ...
%! median (repmat ([1:20;6:25], [5 2 6 3 5 3 4 2 5 5 11]), [1 2 3 4 5 6 7 8 9])
%!error <median: vecdim works on X of up to 10 dimensions> ...
%! median (repmat ([1:20;6:25], [5 2 6 3 5 3 4 2 5 5 11]), [1 2 3 4 5 6 7 8])
%!error <median: vecdim must index at least N-3 dimensions of X> ...
%! median (repmat ([1:20;6:25], [5 2 6 3 5 2]), [1 2])

## Test outtype option
%!test
%! in = [1 2 3];
%! out = 2;
%! assert (median (in, "default"), median (in));
%! assert (median (in, "default"), out);
%!test
%! in = single ([1 2 3]);
%! out = 2;
%! assert (median (in, "default"), median (in));
%! assert (median (in, "default"), single (out));
%! assert (median (in, "double"), out);
%! assert (median (in, "native"), single (out));
%!test
%! in = uint8 ([1 2 3]);
%! out = 2;
%! assert (median (in, "default"), median (in));
%! assert (median (in, "default"), uint8 (out));
%! assert (median (in, "double"), out);
%! assert (median (in, "native"), uint8 (out));
%!test
%! in = logical ([1 0 1]);
%! out = 1;
%! assert (median (in, "default"), median (in));
%! assert (median (in, "default"), logical (out));
%! assert (median (in, "double"), out);
%! assert (median (in, "native"), logical (out));

## Test single input and optional arguments "all", DIM, "omitnan")
%!test
%! x = repmat ([2 2.1 2.2 2 NaN; 3 1 2 NaN 5; 1 1.1 1.4 5 3], [1, 1, 4]);
%! y = repmat ([2 1.1 2 NaN NaN], [1, 1, 4]);
%! assert (median (x), y);
%! assert (median (x, 1), y);
%! y = repmat ([2 1.1 2 3.5 4], [1, 1, 4]);
%! assert (median (x, "omitnan"), y);
%! assert (median (x, 1, "omitnan"), y);
%! y = repmat ([2.05; 2.5; 1.4], [1, 1, 4]);
%! assert (median (x, 2, "omitnan"), y);
%! y = repmat ([NaN; NaN; 1.4], [1, 1, 4]);
%! assert (median (x, 2), y);
%! assert (median (x, "all"), NaN);
%! assert (median (x, "all", "omitnan"), 3);

# Test boolean input
%!test
%! assert (median (true, "all"), logical (1));
%! assert (median (false), logical (0));
%! assert (median ([true false true]), true);
%! assert (median ([true false true], 2), true);
%! assert (median ([true false true], 1), logical ([1 0 1]));
%! assert (median ([true false NaN], 1), [1 0 NaN]);
%! assert (median ([true false NaN], 2), NaN);
%! assert (median ([true false NaN], 2, "omitnan"), 0.5);
%! assert (median ([true false NaN], 2, "omitnan", "native"), 0.5);

## Test dimension indexing with vecdim in n-dimensional arrays
%!test
%! x = repmat ([1:20;6:25], [5 2 6 3]);
%! assert (size (median (x, [3 2])), [10 3]);
%! assert (size (median (x, [1 2])), [6 3]);
%! assert (size (median (x, [1 2 4])), [1 6]);
%! assert (size (median (x, [1 4 3])), [1 40]);
%! assert (size (median (x, [1 2 3 4])), [1 1]);

## Test results with vecdim in n-dimensional arrays and "omitnan"
%!test
%! x = repmat ([2 2.1 2.2 2 NaN; 3 1 2 NaN 5; 1 1.1 1.4 5 3], [1, 1, 4]);
%! assert (median (x, [3 2]), [NaN NaN 1.4]);
%! assert (median (x, [3 2], "omitnan"), [2.05 2.5 1.4]);
%! assert (median (x, [1 3]), [2 1.1 2 NaN NaN]);
%! assert (median (x, [1 3], "omitnan"), [2 1.1 2 3.5 4]);
