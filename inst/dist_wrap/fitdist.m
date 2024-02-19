## Copyright (C) 2024 Andreas Bertsatos <abertsatos@biol.uoa.gr>
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

function [varargout] = fitdist (varargin)

  ## Add list of supported probability distribution objects
  PDO = {'Beta'; 'Binomial'; 'BirnbaumSaunders'; 'Burr'; 'ExtremeValue'; ...
         'Exponential'; 'Gamma'; 'GeneralizedExtremeValue'; ...
         'GeneralizedPareto'; 'HalfNormal'; 'InverseGaussian'; ...
         'Kernel'; 'Logistic'; 'Loglogistic'; 'Lognormal'; 'Nakagami'; ...
         'NegativeBinomial'; 'Normal'; 'Poisson'; 'Rayleigh'; 'Rician'; ...
         'Stable'; 'tLocationScale'; 'Weibull'};

  ## Check for input arguments
  if (nargin == 0)
    varargout{1} = PDO;
    return
  elseif (nargin == 1)
    error ("fitdist: DISTNAME is required.");
  else
    x = varargin{1};
    distname = varargin{2};
    varargin([1:2]) = [];
  endif

  ## Check distribution name
  if (! (ischar (distname) && size (distname, 1) == 1))
    error ("fitdist: DISTNAME must be a character vector.");
  elseif (! any (strcmpi (distname, PDO)))
    error ("fitdist: unrecognized distribution name.");
  endif

  ## Check data in X being a real vector
  if (! (isvector (x) && isnumeric (x) && isreal (x)))
    error ("fitdist: X must be a numeric vector of real values.");
  endif

  ## Add defaults
  groupvar = [];
  censor = zeros (size (x));
  freq = ones (size (x));
  alpha = 0.05;
  ntrials = [];
  mu = 0;
  options.Display = "off";
  options.MaxFunEvals = 400;
  options.MaxIter = 200;
  options.TolX = 1e-6;

  ## Parse extra arguments
  if (mod (numel (varargin), 2) != 0)
    error ("fitdist: optional arguments must be in NAME-VALUE pairs.");
  endif
  while (numel (varargin) > 0)
    switch (tolower (varargin{1}))
      case "by"
        groupvar = varargin{2};
        if (! isequal (size (x), size (groupvar)) && ! isempty (groupvar))
          error (strcat (["fitdist: GROUPVAR argument must have the same"], ...
                         [" size as the input data in X."]));
        endif
      case "censoring"
        censor = varargin{2};
        if (! isequal (size (x), size (censor)))
          error (strcat (["fitdist: 'censoring' argument must have the"], ...
                         [" same size as the input data in X."]));
        endif
      case "frequency"
        freq = varargin{2};
        if (! isequal (size (x), size (freq)))
          error (strcat (["fitdist: 'frequency' argument must have the"], ...
                         [" same size as the input data in X."]));
        endif
        if (any (freq != round (freq)) || any (freq < 0))
          error (strcat (["fitdist: 'frequency' argument must contain"], ...
                         [" non-negative integer values."]));
        endif
      case "alpha"
        alpha = varargin{2};
        if (! isscalar (alpha) || ! isreal (alpha) || alpha <= 0 || alpha >= 1)
          error ("fitdist: invalid value for 'alpha' argument.");
        endif
      case "ntrials"
        ntrials = varargin{2};
        if (! (isscalar (ntrials) && isreal (ntrials) && ntrials > 0
                                  && fix (ntrials) == ntrials))
          error (strcat (["fitdist: 'ntrials' argument must be a positive"], ...
                         [" integer scalar value."]));
        endif
      case {"theta", "mu"}
        mu = varargin{2};
      case "options"
        options = varargin{2};
        if (! isstruct (options) || ! isfield (options, "Display") ||
            ! isfield (options, "MaxFunEvals") || ! isfield (options, "MaxIter")
                                               || ! isfield (options, "TolX"))
          error (strcat (["fitdist: 'options' argument must be a"], ...
                         [" structure compatible for 'fminsearch'."]));
        endif

      case {"kernel", "support", "width"}
        warning ("fitdist: parameter not supported yet.");
      otherwise
        error ("fitdist: unknown parameter name.");
    endswitch
    varargin([1:2]) = [];
  endwhile

  ## Handle group variable
  if (isempty (groupvar) && nargout > 1)
    error ("fitdist: must define GROUPVAR for more than one output arguments.");
  endif
  if (! isempty (groupvar))
    [g, gn, gl] = grp2idx (groupvar);
    groups = numel (gn);
  endif

  ## Switch to selected distribution
  switch (tolower (distname))

    case "beta"
      warning ("fitdist: 'Beta' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "binomial"
      warning ("fitdist: 'Binomial' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "birnbaumsaunders"
      warning ("fitdist: 'BirnbaumSaunders' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "burr"
      warning ("fitdist: 'Burr' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "extremevalue"
      warning ("fitdist: 'ExtremeValue' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "exponential"
      warning ("fitdist: 'Exponential' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "gamma"
      warning ("fitdist: 'Gamma' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "generalizedextremevalue"
      warning ("fitdist: 'GeneralizedExtremeValue' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "generalizedpareto"
      warning ("fitdist: 'GeneralizedPareto' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "halfnormal"
      warning ("fitdist: 'HalfNormal' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "inversegaussian"
      warning ("fitdist: 'InverseGaussian' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "kernel"
      warning ("fitdist: 'Kernel' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "logistic"
      warning ("fitdist: 'Logistic' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "loglogistic"
      warning ("fitdist: 'Loglogistic' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "lognormal"
      warning ("fitdist: 'Lognormal' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "nakagami"
      if (isempty (groupvar))
        varargout{1} = NakagamiDistribution.fit ...
                       (x, alpha, censor, freq, options);
      else
        pd = NakagamiDistribution.fit ...
             (x(g==1), alpha, censor(g==1), freq(g==1), options);
        for i = 2:groups
          pd(i) = NakagamiDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "negativebinomial"
      if (isempty (groupvar))
        varargout{1} = NegativeBinomialDistribution.fit ...
                       (x, alpha, freq, options);
      else
        pd = NegativeBinomialDistribution.fit ...
             (x(g==1), alpha, freq(g==1), options);
        for i = 2:groups
          pd(i) = NegativeBinomialDistribution.fit ...
                  (x(g==i), alpha, freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "normal"
      if (isempty (groupvar))
        varargout{1} = NormalDistribution.fit (x, alpha, censor, freq, options);
      else
        pd = NormalDistribution.fit ...
             (x(g==1), alpha, censor(g==1), freq(g==1), options);
        for i = 2:groups
          pd(i) = NormalDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "poisson"
      if (isempty (groupvar))
        varargout{1} = PoissonDistribution.fit (x, alpha, freq);
      else
        pd = PoissonDistribution.fit (x(g==1), alpha, freq(g==1));
        for i = 2:groups
          pd(i) = PoissonDistribution.fit (x(g==i), alpha, freq(g==i));
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "rayleigh"
      if (isempty (groupvar))
        varargout{1} = RayleighDistribution.fit (x, alpha, censor, freq);
      else
        pd = RayleighDistribution.fit (x(g==1), alpha, censor(g==1), freq(g==1));
        for i = 2:groups
          pd(i) = RayleighDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i));
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "rician"
      if (isempty (groupvar))
        varargout{1} = RicianDistribution.fit (x, alpha, censor, freq, options);
      else
        pd = RicianDistribution.fit ...
             (x(g==1), alpha, censor(g==1), freq(g==1), options);
        for i = 2:groups
          pd(i) = RicianDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "stable"
      warning ("fitdist: 'Stable' distribution not supported yet.");
      if (isempty (groupvar))
        varargout{1} = [];
      else
        varargout{1} = [];
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "tlocationscale"
      if (isempty (groupvar))
        varargout{1} = tLocationScaleDistribution.fit ...
                       (x, alpha, censor, freq, options);
      else
        pd = tLocationScaleDistribution.fit ...
             (x(g==1), alpha, censor(g==1), freq(g==1), options);
        for i = 2:groups
          pd(i) = tLocationScaleDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

    case "weibull"
      if (isempty (groupvar))
        varargout{1} = WeibullDistribution.fit (x, alpha, censor, freq, options);
      else
        pd = WeibullDistribution.fit ...
             (x(g==1), alpha, censor(g==1), freq(g==1), options);
        for i = 2:groups
          pd(i) = WeibullDistribution.fit ...
                  (x(g==i), alpha, censor(g==i), freq(g==i), options);
        endfor
        varargout{1} = pd;
        varargout{2} = gn;
        varargout{3} = gl;
      endif

  endswitch

endfunction

## Test output
%!test
%! x = nakarnd (2, 0.5, 100, 1);
%! pd = fitdist (x, "Nakagami");
%! [phat, pci] = nakafit (x);
%! assert ([pd.mu, pd.omega], phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = nakarnd (2, 0.5, 100, 1);
%! x2 = nakarnd (5, 0.8, 100, 1);
%! pd = fitdist ([x1; x2], "Nakagami", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = nakafit (x1);
%! assert ([pd(1).mu, pd(1).omega], phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = nakafit (x2);
%! assert ([pd(2).mu, pd(2).omega], phat);
%! assert (paramci (pd(2)), pci);
%!test
%! x = nbinrnd (2, 0.5, 100, 1);
%! pd = fitdist (x, "negativebinomial");
%! [phat, pci] = nbinfit (x);
%! assert ([pd.R, pd.P], phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = nbinrnd (2, 0.5, 100, 1);
%! x2 = nbinrnd (5, 0.8, 100, 1);
%! pd = fitdist ([x1; x2], "negativebinomial", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = nbinfit (x1);
%! assert ([pd(1).R, pd(1).P], phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = nbinfit (x2);
%! assert ([pd(2).R, pd(2).P], phat);
%! assert (paramci (pd(2)), pci);
%!test
%! x = normrnd (1, 1, 100, 1);
%! pd = fitdist (x, "normal");
%! [muhat, sigmahat, muci, sigmaci] = normfit (x);
%! assert ([pd.mu, pd.sigma], [muhat, sigmahat]);
%! assert (paramci (pd), [muci, sigmaci]);
%!test
%! x1 = normrnd (1, 1, 100, 1);
%! x2 = normrnd (5, 2, 100, 1);
%! pd = fitdist ([x1; x2], "normal", "By", [ones(100,1); 2*ones(100,1)]);
%! [muhat, sigmahat, muci, sigmaci] = normfit (x1);
%! assert ([pd(1).mu, pd(1).sigma], [muhat, sigmahat]);
%! assert (paramci (pd(1)), [muci, sigmaci]);
%! [muhat, sigmahat, muci, sigmaci] = normfit (x2);
%! assert ([pd(2).mu, pd(2).sigma], [muhat, sigmahat]);
%! assert (paramci (pd(2)), [muci, sigmaci]);
%!test
%! x = poissrnd (1, 100, 1);
%! pd = fitdist (x, "poisson");
%! [phat, pci] = poissfit (x);
%! assert (pd.lambda, phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = poissrnd (1, 100, 1);
%! x2 = poissrnd (5, 100, 1);
%! pd = fitdist ([x1; x2], "poisson", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = poissfit (x1);
%! assert (pd(1).lambda, phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = poissfit (x2);
%! assert (pd(2).lambda, phat);
%! assert (paramci (pd(2)), pci);
%!test
%! x = raylrnd (1, 100, 1);
%! pd = fitdist (x, "rayleigh");
%! [phat, pci] = raylfit (x);
%! assert (pd.sigma, phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = raylrnd (1, 100, 1);
%! x2 = raylrnd (5, 100, 1);
%! pd = fitdist ([x1; x2], "rayleigh", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = raylfit (x1);
%! assert ( pd(1).sigma, phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = raylfit (x2);
%! assert (pd(2).sigma, phat);
%! assert (paramci (pd(2)), pci);
%!test
%! x = ricernd (1, 1, 100, 1);
%! pd = fitdist (x, "rician");
%! [phat, pci] = ricefit (x);
%! assert ([pd.nu, pd.sigma], phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = ricernd (1, 1, 100, 1);
%! x2 = ricernd (5, 2, 100, 1);
%! pd = fitdist ([x1; x2], "rician", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = ricefit (x1);
%! assert ([pd(1).nu, pd(1).sigma], phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = ricefit (x2);
%! assert ([pd(2).nu, pd(2).sigma], phat);
%! assert (paramci (pd(2)), pci);
%!warning <fitdist: 'Stable' distribution not supported yet.> ...
%! fitdist ([1 2 3 4 5], "Stable");
%!test
%! x = tlsrnd (0, 1, 1, 100, 1);
%! pd = fitdist (x, "tlocationscale");
%! [phat, pci] = tlsfit (x);
%! assert ([pd.mu, pd.sigma, pd.nu], phat);
%! assert (paramci (pd), pci);
%!test
%! x1 = tlsrnd (0, 1, 1, 100, 1);
%! x2 = tlsrnd (5, 2, 1, 100, 1);
%! pd = fitdist ([x1; x2], "tlocationscale", "By", [ones(100,1); 2*ones(100,1)]);
%! [phat, pci] = tlsfit (x1);
%! assert ([pd(1).mu, pd(1).sigma, pd(1).nu], phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = tlsfit (x2);
%! assert ([pd(2).mu, pd(2).sigma, pd(2).nu], phat);
%! assert (paramci (pd(2)), pci);
%!test
%! x = [1 2 3 4 5];
%! pd = fitdist (x, "weibull");
%! [phat, pci] = wblfit (x);
%! assert ([pd.lambda, pd.k], phat);
%! assert (paramci (pd), pci);
%!test
%! x = [1 2 3 4 5 6 7 8 9 10];
%! pd = fitdist (x, "weibull", "By", [1 1 1 1 1 2 2 2 2 2]);
%! [phat, pci] = wblfit (x(1:5));
%! assert ([pd(1).lambda, pd(1).k], phat);
%! assert (paramci (pd(1)), pci);
%! [phat, pci] = wblfit (x(6:10));
%! assert ([pd(2).lambda, pd(2).k], phat);
%! assert (paramci (pd(2)), pci);

## Test input validation
%!error <fitdist: DISTNAME is required.> fitdist (1)
%!error <fitdist: DISTNAME must be a character vector.> fitdist (1, ["as";"sd"])
%!error <fitdist: unrecognized distribution name.> fitdist (1, "some")
%!error <fitdist: X must be a numeric vector of real values.> ...
%! fitdist (ones (2), "normal")
%!error <fitdist: X must be a numeric vector of real values.> ...
%! fitdist ([i, 2, 3], "normal")
%!error <fitdist: X must be a numeric vector of real values.> ...
%! fitdist (["a", "s", "d"], "normal")
%!error <fitdist: optional arguments must be in NAME-VALUE pairs.> ...
%! fitdist ([1, 2, 3], "normal", "By")
%!error <fitdist: GROUPVAR argument must have the same size as the input data in X.> ...
%! fitdist ([1, 2, 3], "normal", "By", [1, 2])
%!error <fitdist: 'censoring' argument must have the same size as the input data in X.> ...
%! fitdist ([1, 2, 3], "normal", "Censoring", [1, 2])
%!error <fitdist: 'frequency' argument must have the same size as the input data in X.> ...
%! fitdist ([1, 2, 3], "normal", "frequency", [1, 2])
%!error <fitdist: 'frequency' argument must contain non-negative integer values.> ...
%! fitdist ([1, 2, 3], "negativebinomial", "frequency", [1, -2, 3])
%!error <fitdist: invalid value for 'alpha' argument.> ...
%! fitdist ([1, 2, 3], "normal", "alpha", [1, 2])
%!error <fitdist: invalid value for 'alpha' argument.> ...
%! fitdist ([1, 2, 3], "normal", "alpha", i)
%!error <fitdist: invalid value for 'alpha' argument.> ...
%! fitdist ([1, 2, 3], "normal", "alpha", -0.5)
%!error <fitdist: invalid value for 'alpha' argument.> ...
%! fitdist ([1, 2, 3], "normal", "alpha", 1.5)
%!error <fitdist: 'ntrials' argument must be a positive integer scalar value.> ...
%! fitdist ([1, 2, 3], "normal", "ntrials", [1, 2])
%!error <fitdist: 'ntrials' argument must be a positive integer scalar value.> ...
%! fitdist ([1, 2, 3], "normal", "ntrials", 0)
%!error <fitdist: 'options' argument must be a structure compatible for 'fminsearch'.> ...
%! fitdist ([1, 2, 3], "normal", "options", 0)
%!error <fitdist: 'options' argument must be a structure compatible for 'fminsearch'.> ...
%! fitdist ([1, 2, 3], "normal", "options", struct ("options", 1))
%!warning fitdist ([1, 2, 3], "kernel", "kernel", "normal");
%!warning fitdist ([1, 2, 3], "kernel", "support", "positive");
%!warning fitdist ([1, 2, 3], "kernel", "width", 1);
%!error <fitdist: unknown parameter name.> ...
%! fitdist ([1, 2, 3], "normal", "param", struct ("options", 1))
%!error <fitdist: must define GROUPVAR for more than one output arguments.> ...
%! [pdca, gn, gl] = fitdist ([1, 2, 3], "normal");