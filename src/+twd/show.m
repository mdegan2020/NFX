function viewer = show(data, varargin)
    %SHOW - Open a linked three-window image display
    %   VIEWER = SHOW(DATA) displays a real grayscale or RGB array in linked
    %   main, overview, and zoom windows. The main view has a fixed 1:1 scale;
    %   the zoom view starts at 4:1. Source values are preserved.
    %
    %   VIEWER = SHOW(DATA,Name=VALUE) forwards display options to DISPLAY.
    %   For example, SHOW(DATA,Title="Scene",ZoomFactor=6) names the group
    %   and starts its zoom view at six display pixels per source pixel.
    %
    %   See also twd.Display
    viewer = twd.Display(data, varargin{:});
end
