classdef Display < handle
    %DISPLAY - Three linked image windows with fixed and isotropic scales
    %   VIEWER = DISPLAY(DATA) opens a 1:1 main view, a fitted overview, and
    %   a 4:1 zoom view for a grayscale or RGB array. Use SHOW as shorthand.
    %   Drag the overview box to pan the main view. Drag the main-view box
    %   to move the zoom view. Right-drag the main image to pan it directly.
    %
    %   VIEWER = DISPLAY(DATA,Title=TEXT,MainSize=[W H],OverviewWidth=W,...
    %       ZoomSize=[W H],ZoomFactor=N,Visible="on") configures the windows.
    %   Defaults are [500 500], 400, [100 100], and 4, respectively. Zoom
    %   factors range from 1 through 1024. Sizes use MATLAB display-pixel
    %   units; operating-system DPI scaling and window minimum sizes apply.
    %
    %   VIEWER = DISPLAY(...,Stretch="percentile") uses a sampled linear
    %   2-98 percent stretch independently per channel. Stretch="minmax"
    %   uses each channel's full finite range. Limits=[LOW HIGH] overrides
    %   stretching; RGB also accepts three rows, one per channel. These
    %   display settings never change DATA. Nonfinite pixels display black.
    %
    %   panTo and zoomTo take [COLUMN ROW] coordinates, with the first pixel
    %   centered at [1 1]. setZoomFactor changes the integer magnification.
    %   NavigationChanged fires after navigation or resizing, providing an
    %   extension point for future links between independent display groups.
    %   Closing any window closes the entire group.
    %
    %   This desktop utility uses base MATLAB graphics, outside the NFX
    %   MATLAB Coder target. It does not use IMSHOW or change the MATLAB path.
    %
    %   See also twd.show

    properties (SetAccess = private)
        Data
        Limits (:, 2) double
        MainFigure
        OverviewFigure
        ZoomFigure
        MainCenter (1, 2) double = [1 1]
        ZoomCenter (1, 2) double = [1 1]
        ZoomFactor (1, 1) double = 4
        MainViewport (1, 4) double = [0.5 0.5 1 1]
        ZoomViewport (1, 4) double = [0.5 0.5 1 1]
    end

    properties (Access = private)
        MainAxes
        OverviewAxes
        ZoomAxes
        MainImage
        OverviewImage
        ZoomImage
        MainBox
        ZoomBox
        Crosshair
        Title (1, :) char = 'TWD'
        Busy (1, 1) logical = false
        Closing (1, 1) logical = false
        OverviewSize (1, 2) double = [0 0]
        OverviewRasterSize (1, 2) double = [0 0]
        DragKind (1, :) char = ''
        DragAnchor (1, 2) double = [0 0]
        DragCenter (1, 2) double = [0 0]
    end

    events
        NavigationChanged
    end

    methods
        function obj = Display(data, options)
            arguments
                data {validateImage}
                options.Title {mustBeTextScalar} = 'TWD'
                options.MainSize {mustBeSize} = [500 500]
                options.OverviewWidth {mustBePixelCount} = 400
                options.ZoomSize {mustBeSize} = [100 100]
                options.ZoomFactor {mustBeZoomFactor} = 4
                options.Stretch {mustBeTextScalar, ...
                    mustBeMember(options.Stretch, ...
                    {'percentile', 'minmax'})} = 'percentile'
                options.Limits = []
                options.Visible {mustBeTextScalar, ...
                    mustBeMember(options.Visible, ...
                    {'on', 'off'})} = 'on'
            end
            obj.Data = data;
            obj.Title = char(options.Title);
            obj.Limits = displayLimits(data, options.Stretch, options.Limits);
            obj.ZoomFactor = double(options.ZoomFactor);
            imageSize = [size(data, 2) size(data, 1)];
            obj.MainCenter = (imageSize + 1) / 2;
            obj.ZoomCenter = obj.MainCenter;
            mainSize = double(options.MainSize(:).');
            zoomSize = double(options.ZoomSize(:).');
            overviewWidth = double(options.OverviewWidth);
            overviewSize = [overviewWidth ...
                max(1, round(overviewWidth * ...
                imageSize(2) / imageSize(1)))];
            positions = initialPositions(mainSize, overviewSize, zoomSize);
            try
                obj.MainFigure = obj.makeFigure('main', positions(1, :));
                obj.OverviewFigure = obj.makeFigure( ...
                    'overview', positions(2, :));
                obj.ZoomFigure = obj.makeFigure('zoom', positions(3, :));
                obj.MainAxes = obj.makeAxes(obj.MainFigure);
                obj.OverviewAxes = obj.makeAxes(obj.OverviewFigure);
                obj.ZoomAxes = obj.makeAxes(obj.ZoomFigure);
                obj.MainImage = obj.makeImage(obj.MainAxes, 'main');
                obj.OverviewImage = obj.makeImage( ...
                    obj.OverviewAxes, 'overview');
                obj.ZoomImage = obj.makeImage(obj.ZoomAxes, 'zoom');
                obj.MainBox = obj.makeBox(obj.OverviewAxes, 'overview');
                obj.ZoomBox = obj.makeBox(obj.MainAxes, 'main');
                obj.Crosshair = line(obj.ZoomAxes, NaN, NaN, ...
                    'Color', 'r', 'LineWidth', 1, 'HitTest', 'off', ...
                    'PickableParts', 'none', 'Tag', 'twd.crosshair');
                obj.makeZoomButton('-', 1, -1);
                obj.makeZoomButton('+', 22, 1);
                obj.OverviewSize = positions(2, 3:4);
                obj.refresh();
                set([obj.MainFigure obj.OverviewFigure obj.ZoomFigure], ...
                    'Visible', char(options.Visible));
            catch problem
                delete(obj);
                rethrow(problem);
            end
        end

        function panTo(obj, center)
            %panTo - Move the main view to a source [column row] coordinate
            arguments
                obj (1, 1) twd.Display
                center {mustBePoint}
            end
            previous = obj.MainCenter;
            bounds = obj.imageBounds();
            rect = viewRectangle(center, obj.canvasSize(obj.MainFigure), ...
                bounds, true);
            obj.MainCenter = rect(1:2) + rect(3:4) / 2;
            obj.ZoomCenter = obj.ZoomCenter + obj.MainCenter - previous;
            obj.update();
        end

        function zoomTo(obj, center)
            %zoomTo - Move the zoom view within the visible main image
            arguments
                obj (1, 1) twd.Display
                center {mustBePoint}
            end
            obj.ZoomCenter = double(center(:).');
            obj.update();
        end

        function setZoomFactor(obj, factor)
            %setZoomFactor - Set integer display pixels per source pixel
            %   setZoomFactor(OBJ,FACTOR) accepts integers from 1 to 1024.
            arguments
                obj (1, 1) twd.Display
                factor {mustBeZoomFactor}
            end
            obj.ZoomFactor = double(factor);
            obj.update();
        end

        function delete(obj)
            %DELETE - Close all windows belonging to this display group
            if obj.Closing
                return;
            end
            obj.Closing = true;
            figures = [obj.MainFigure obj.OverviewFigure obj.ZoomFigure];
            figures = figures(isgraphics(figures));
            set(figures, 'CloseRequestFcn', '', 'DeleteFcn', '', ...
                'SizeChangedFcn', '', 'WindowButtonMotionFcn', '', ...
                'WindowButtonDownFcn', '', 'WindowButtonUpFcn', '');
            delete(figures);
        end
    end

    methods (Access = private)
        function fig = makeFigure(obj, kind, position)
            fig = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', position, 'Color', 'k', 'MenuBar', 'none', ...
                'ToolBar', 'none', 'NumberTitle', 'off', ...
                'IntegerHandle', 'off', 'WindowStyle', 'normal', ...
                'DockControls', 'off', 'Tag', ['twd.' kind], ...
                'CloseRequestFcn', @(~, ~) delete(obj), ...
                'DeleteFcn', @(~, ~) delete(obj), ...
                'SizeChangedFcn', @(~, ~) obj.resize(kind), ...
                'WindowButtonMotionFcn', @(~, ~) obj.drag(), ...
                'WindowButtonUpFcn', @(~, ~) obj.stopDrag(), ...
                'WindowKeyPressFcn', @(~, event) obj.key(kind, event));
        end

        function ax = makeAxes(obj, fig) %#ok<INUSL>
            ax = axes('Parent', fig, 'Units', 'pixels', ...
                'Position', [1 1 1 1], 'PositionConstraint', 'innerposition', ...
                'Visible', 'off', 'Color', 'k', 'YDir', 'reverse', ...
                'DataAspectRatio', [1 1 1], 'XLimMode', 'manual', ...
                'YLimMode', 'manual', 'NextPlot', 'add', ...
                'HitTest', 'off', 'Tag', 'twd.canvas');
            ax.Toolbar = [];
            disableDefaultInteractivity(ax);
            ax.Interactions = [];
            ax.PlotBoxAspectRatioMode = 'auto';
        end

        function im = makeImage(obj, ax, kind)
            im = image('Parent', ax, 'CData', zeros(1, 1, 3, 'uint8'), ...
                'XData', 1, 'YData', 1, 'Tag', 'twd.pixels', ...
                'ButtonDownFcn', @(~, ~) obj.startDrag(kind));
            if isprop(im, 'Interpolation')
                im.Interpolation = 'nearest';
            end
        end

        function box = makeBox(obj, ax, kind)
            box = line(ax, NaN, NaN, 'Color', 'r', 'LineWidth', 1, ...
                'Tag', 'twd.viewport', ...
                'ButtonDownFcn', @(~, ~) obj.startDrag(kind));
        end

        function makeZoomButton(obj, label, x, delta)
            uicontrol(obj.ZoomFigure, 'Style', 'pushbutton', ...
                'Units', 'pixels', 'Position', [x 1 21 21], ...
                'String', label, 'ForegroundColor', 'r', ...
                'BackgroundColor', [0.08 0.08 0.08], 'FontSize', 13, ...
                'FontWeight', 'bold', 'Tag', ['twd.' label], ...
                'TooltipString', 'Change integer zoom factor', ...
                'Callback', @(~, ~) obj.changeZoom(delta));
        end

        function changeZoom(obj, delta)
            obj.setZoomFactor(min(1024, max(1, obj.ZoomFactor + delta)));
        end

        function resize(obj, kind)
            if obj.Busy || obj.Closing || isempty(obj.Crosshair)
                return;
            end
            if strcmp(kind, 'overview')
                obj.fitOverviewWindow();
            end
            obj.update();
        end

        function fitOverviewWindow(obj)
            position = getpixelposition(obj.OverviewFigure);
            extent = position(3:4);
            ratio = size(obj.Data, 2) / size(obj.Data, 1);
            change = abs(extent - obj.OverviewSize) ./ ...
                max(1, obj.OverviewSize);
            if change(1) >= change(2)
                extent(2) = max(1, round(extent(1) / ratio));
            else
                extent(1) = max(1, round(extent(2) * ratio));
            end
            screen = screenPixels();
            available = max([120 80], screen(3:4) - [80 120]);
            scale = min([1 available ./ extent]);
            % Native window chrome has a minimum size. Extreme aspect
            % ratios use margins inside it, never stretched source pixels.
            extent = max([120 80], round(extent * scale));
            obj.OverviewSize = extent;
            obj.Busy = true;
            cleanup = onCleanup(@() obj.releaseBusy());
            position(2) = position(2) + position(4) - extent(2);
            setpixelposition(obj.OverviewFigure, [position(1:2) extent]);
            movegui(obj.OverviewFigure, 'onscreen');
        end

        function update(obj)
            obj.refresh();
            notify(obj, 'NavigationChanged');
        end

        function refresh(obj)
            if obj.Busy || obj.Closing
                return;
            end
            obj.Busy = true;
            cleanup = onCleanup(@() obj.releaseBusy());
            bounds = obj.imageBounds();
            mainSize = obj.canvasSize(obj.MainFigure);
            zoomSize = obj.canvasSize(obj.ZoomFigure);
            obj.MainViewport = viewRectangle( ...
                obj.MainCenter, mainSize, bounds, true);
            obj.MainCenter = obj.MainViewport(1:2) + mainSize / 2;
            zoomBounds = intersectRect(obj.MainViewport, bounds);
            obj.ZoomViewport = viewRectangle(obj.ZoomCenter, ...
                zoomSize / obj.ZoomFactor, zoomBounds, false);
            obj.ZoomCenter = obj.ZoomViewport(1:2) + ...
                obj.ZoomViewport(3:4) / 2;
            obj.renderCrop(obj.MainAxes, obj.MainImage, ...
                obj.MainViewport, mainSize);
            obj.renderCrop(obj.ZoomAxes, obj.ZoomImage, ...
                obj.ZoomViewport, zoomSize);
            obj.renderOverview(bounds);
            setBox(obj.MainBox, intersectRect(obj.MainViewport, bounds));
            setBox(obj.ZoomBox, ...
                intersectRect(obj.ZoomViewport, obj.MainViewport));
            center = obj.ZoomCenter;
            radius = 6 / obj.ZoomFactor;
            set(obj.Crosshair, ...
                'XData', [center(1) + [-radius radius] NaN center(1) ...
                    center(1)], ...
                'YData', [center(2) center(2) NaN ...
                    center(2) + [-radius radius]]);
            obj.MainFigure.Name = [obj.Title ' | Main 1:1'];
            obj.OverviewFigure.Name = [obj.Title ' | Overview'];
            obj.ZoomFigure.Name = sprintf('%s | Zoom %d:1', ...
                obj.Title, obj.ZoomFactor);
        end

        function renderCrop(obj, ax, im, rect, extent)
            first = max([1 1], floor(rect(1:2) + 0.5));
            last = min([size(obj.Data, 2) size(obj.Data, 1)], ...
                ceil(rect(1:2) + rect(3:4) - 0.5));
            pixels = obj.Data(first(2):last(2), first(1):last(1), :);
            set(im, 'CData', stretchPixels(pixels, obj.Limits), ...
                'XData', [first(1) last(1)], ...
                'YData', [first(2) last(2)]);
            set(ax, 'Position', [1 1 extent], ...
                'XLim', rect(1) + [0 rect(3)], ...
                'YLim', rect(2) + [0 rect(4)]);
        end

        function renderOverview(obj, bounds)
            extent = obj.canvasSize(obj.OverviewFigure);
            % Fit an exact isotropic plot box; at most one pixel of rounding
            % margin remains when the window aspect cannot be integral.
            scale = min(extent ./ bounds(3:4));
            plotSize = bounds(3:4) * scale;
            position = [1 + (extent - plotSize) / 2 plotSize];
            rasterSize = max(1, round(plotSize));
            if ~isequal(rasterSize, obj.OverviewRasterSize)
                pixels = overviewPixels(obj.Data, obj.Limits, rasterSize);
                % A singleton image dimension spans one source unit in
                % MATLAB. Duplicate it so XData/YData can describe edges.
                pixels = repmat(pixels, ...
                    [1 + (rasterSize(2) == 1) ...
                     1 + (rasterSize(1) == 1) 1]);
                textureSize = [size(pixels, 2) size(pixels, 1)];
                step = bounds(3:4) ./ textureSize;
                set(obj.OverviewImage, 'CData', pixels, ...
                    'XData', bounds(1) + [step(1) / 2 ...
                        bounds(3) - step(1) / 2], ...
                    'YData', bounds(2) + [step(2) / 2 ...
                        bounds(4) - step(2) / 2]);
                obj.OverviewRasterSize = rasterSize;
            end
            set(obj.OverviewAxes, 'Position', position, ...
                'XLim', bounds(1) + [0 bounds(3)], ...
                'YLim', bounds(2) + [0 bounds(4)]);
        end

        function startDrag(obj, kind)
            [ax, fig] = obj.surface(kind);
            point = obj.sourcePoint(ax);
            anchor = point;
            if strcmp(kind, 'main') && strcmp(fig.SelectionType, 'alt')
                kind = 'pan';
                center = obj.MainCenter;
                anchor = point - obj.MainViewport(1:2);
            elseif strcmp(kind, 'overview')
                center = obj.MainCenter;
                if ~inside(point, obj.MainViewport)
                    obj.panTo(point);
                    center = obj.MainCenter;
                end
            elseif strcmp(kind, 'main')
                center = obj.ZoomCenter;
                if ~inside(point, obj.ZoomViewport)
                    obj.zoomTo(point);
                    center = obj.ZoomCenter;
                end
            else
                anchor = point - obj.ZoomViewport(1:2);
                obj.zoomTo(point);
                center = obj.ZoomCenter;
            end
            obj.DragKind = kind;
            obj.DragAnchor = anchor;
            obj.DragCenter = center;
        end

        function drag(obj)
            kind = obj.DragKind;
            if isempty(kind)
                return;
            end
            [ax, ~] = obj.surface(kind);
            point = obj.sourcePoint(ax);
            if strcmp(kind, 'pan')
                % Screen displacement is stable while the axes limits move.
                delta = (point - obj.MainViewport(1:2)) - obj.DragAnchor;
                obj.panTo(obj.DragCenter - delta);
            elseif strcmp(kind, 'overview')
                obj.panTo(obj.DragCenter + point - obj.DragAnchor);
            elseif strcmp(kind, 'zoom')
                delta = (point - obj.ZoomViewport(1:2)) - obj.DragAnchor;
                obj.zoomTo(obj.DragCenter + delta);
            else
                obj.zoomTo(obj.DragCenter + point - obj.DragAnchor);
            end
        end

        function stopDrag(obj)
            obj.DragKind = '';
        end

        function key(obj, kind, event)
            shift = 1;
            if ismember('shift', event.Modifier)
                shift = 10;
            end
            switch event.Key
                case 'leftarrow', delta = [-shift 0];
                case 'rightarrow', delta = [shift 0];
                case 'uparrow', delta = [0 -shift];
                case 'downarrow', delta = [0 shift];
                case {'add', 'equal'}
                    obj.changeZoom(1);
                    return;
                case {'subtract', 'hyphen'}
                    obj.changeZoom(-1);
                    return;
                otherwise, return;
            end
            if strcmp(kind, 'zoom')
                obj.zoomTo(obj.ZoomCenter + delta);
            else
                obj.panTo(obj.MainCenter + delta);
            end
        end

        function [ax, fig] = surface(obj, kind)
            switch kind
                case 'overview'
                    ax = obj.OverviewAxes;
                    fig = obj.OverviewFigure;
                case 'zoom'
                    ax = obj.ZoomAxes;
                    fig = obj.ZoomFigure;
                otherwise
                    ax = obj.MainAxes;
                    fig = obj.MainFigure;
            end
        end

        function point = sourcePoint(obj, ax) %#ok<INUSL>
            point = ax.CurrentPoint(1, 1:2);
        end

        function extent = canvasSize(obj, fig) %#ok<INUSL>
            position = getpixelposition(fig);
            extent = max(1, round(position(3:4)));
        end

        function bounds = imageBounds(obj)
            bounds = [0.5 0.5 size(obj.Data, 2) size(obj.Data, 1)];
        end

        function releaseBusy(obj)
            if isvalid(obj)
                obj.Busy = false;
            end
        end
    end
end

function mustBeSize(value)
    mustBePoint(value);
    if any(value < 1 | value ~= fix(value))
        error('twd:InvalidSize', 'Sizes must be positive integer pixels.');
    end
end

function mustBePoint(value)
    if ~isnumeric(value) || ~isreal(value) || numel(value) ~= 2 || ...
            ~isvector(value) || any(~isfinite(value))
        error('twd:InvalidPoint', 'Expected two finite real coordinates.');
    end
end

function mustBePixelCount(value)
    if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ...
            ~isfinite(value) || value < 1 || value ~= fix(value)
        error('twd:InvalidSize', 'Expected a positive integer pixel count.');
    end
end

function mustBeZoomFactor(value)
    mustBePixelCount(value);
    if value > 1024
        error('twd:InvalidZoomFactor', ...
            'ZoomFactor must be an integer from 1 through 1024.');
    end
end

function result = intersectRect(a, b)
    first = max(a(1:2), b(1:2));
    last = min(a(1:2) + a(3:4), b(1:2) + b(3:4));
    result = [first max(0, last - first)];
end

function setBox(box, rect)
    set(box, 'XData', rect(1) + [0 rect(3) rect(3) 0 0], ...
        'YData', rect(2) + [0 0 rect(4) rect(4) 0]);
end

function result = inside(point, rect)
    result = all(point >= rect(1:2) & point <= rect(1:2) + rect(3:4));
end

function positions = initialPositions(mainSize, overviewSize, zoomSize)
    screen = screenPixels();
    available = max([100 100], screen(3:4) - [80 160]);
    mainSize = min(mainSize, available);
    % Leave room below the main window, including window decorations.
    mainSize(2) = min(mainSize(2), max(100, screen(4) - 275));
    x = screen(1) + 40;
    mainY = screen(2) + screen(4) - mainSize(2) - 80;
    belowMain = max(1, mainY - (screen(2) + 40) - 55);
    scale = min([1 available(1) / overviewSize(1) ...
        belowMain / overviewSize(2)]);
    overviewSize = max([120 80], round(overviewSize * scale));
    zoomSize = min(zoomSize, [available(1) belowMain]);
    overviewY = mainY - overviewSize(2) - 55;
    zoomX = min(x + overviewSize(1) + 16, ...
        screen(1) + screen(3) - zoomSize(1) - 20);
    zoomY = mainY - zoomSize(2) - 55;
    positions = [x mainY mainSize; x overviewY overviewSize; ...
        zoomX zoomY zoomSize];
end

function screen = screenPixels()
    previousUnits = get(groot, 'Units');
    cleanup = onCleanup(@() set(groot, 'Units', previousUnits));
    set(groot, 'Units', 'pixels');
    screen = get(groot, 'ScreenSize');
end
