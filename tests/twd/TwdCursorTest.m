classdef TwdCursorTest < matlab.uitest.TestCase
    %TwdCursorTest - Cursor gestures, values, and independent window lifetime
    properties (TestParameter)
        view = {'main', 'overview', 'zoom'};
        nonfinite = {NaN, Inf, -Inf};
        originalClass = {'logical', 'uint32', 'int32', 'single', 'double'};
        edge = struct('first', [1 1], 'last', [400 400]);
        cropView = {'main', 'zoom'};
        edgeDirection = {[1 0], [0 1]};
    end

    methods (TestClassSetup)
        function configurePaths(testCase)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'src')));
        end
    end

    methods (Test)
        function doubleClickOpensAndReusesWindow(testCase)
            viewer = testCase.create(ones(400));
            ax = showCanvas(viewer.MainFigure);
            testCase.press(ax, [200 200]);
            testCase.verifyEmpty(viewer.CursorFigure);
            testCase.press(ax, [200 200], SelectionType='open');
            first = viewer.CursorFigure;
            testCase.assertTrue(isgraphics(first));
            testCase.verifyEqual(first.Visible, ...
                matlab.lang.OnOffSwitchState.on);
            testCase.verifyTrue(contains(cursorText(viewer), ...
                'Column (X): 200    Row (Y): 200'));
            testCase.press(ax, [205 210], SelectionType='open');
            testCase.verifyEqual(viewer.CursorFigure, first);
            testCase.verifyTrue(contains(cursorText(viewer), ...
                'Column (X): 205    Row (Y): 210'));
        end

        function hoverReportsCoordinatesAndNativeValues(testCase, view)
            data = reshape(uint32(1:160000), 400, 400);
            viewer = testCase.create(data, Limits=[0 160000]);
            testCase.openCursor(viewer, [211 177]);
            resizeFigure(viewer.OverviewFigure, [400 400]);
            viewer.zoomTo([211 177]);
            figures = struct('main', viewer.MainFigure, ...
                'overview', viewer.OverviewFigure, 'zoom', viewer.ZoomFigure);
            ax = showCanvas(figures.(view));
            mainBefore = viewer.MainViewport;
            zoomBefore = viewer.ZoomViewport;
            if strcmp(view, 'zoom')
                % Batch axes gestures can shift within tiny native windows.
                % The figure-pixel gesture reaches the same source center.
                testCase.hover(viewer.ZoomFigure, ...
                    viewer.ZoomFigure.Position(3:4) / 2);
            else
                testCase.hover(ax, [211 177]);
            end
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, ['View: ' view]));
            testCase.verifyTrue(contains(text, ...
                'Column (X): 211    Row (Y): 177'), text);
            testCase.verifyTrue(contains(text, 'Displayed (0-255): 134'), ...
                text);
            testCase.verifyTrue(contains(text, 'Original (uint32): 84177'), ...
                text);
            testCase.verifyEqual(viewer.MainViewport, mainBefore);
            testCase.verifyEqual(viewer.ZoomViewport, zoomBefore);
            testCase.verifyEqual(viewer.Data, data);
        end

        function rgbReadoutPreservesChannelOrderAndClipping(testCase)
            data = repmat(reshape(int16([-10 20 1000]), 1, 1, 3), ...
                400, 400, 1);
            viewer = testCase.create(data, ...
                Limits=[-20 0; 0 40; 0 100]);
            testCase.openCursor(viewer, [200 200]);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, ...
                'Displayed (0-255): [128 128 255]'));
            testCase.verifyTrue(contains(text, ...
                'Original (int16): [-10 20 1000]'));
        end

        function nonfiniteValuesRemainVisible(testCase, nonfinite)
            viewer = testCase.create(repmat(nonfinite, 400, 400));
            testCase.openCursor(viewer, [200 200]);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, 'Displayed (0-255): 0'));
            testCase.verifyTrue(contains(text, ...
                ['Original (double): ' mat2str(nonfinite)]));
        end

        function retainsOriginalNumericType(testCase, originalClass)
            data = ones(400, 400, originalClass);
            viewer = testCase.create(data);
            testCase.openCursor(viewer, [200 200]);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, ...
                ['Original (' originalClass '): ' mat2str(data(1))]));
            testCase.verifyTrue(contains(text, 'Displayed (0-255): 128'));
            testCase.verifyClass(viewer.Data, originalClass);
        end

        function floatingReadoutRetainsPrecision(testCase)
            value = 0.123456789012345;
            viewer = testCase.create(repmat(value, 400, 400));
            testCase.openCursor(viewer, [200 200]);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, ...
                ['Original (double): ' sprintf('%.17g', value)]));
        end

        function overviewReportsResampledDisplayValue(testCase)
            data = repmat(uint8([0 255]), 400, 400);
            viewer = testCase.create(data, Limits=[0 255]);
            testCase.openCursor(viewer, [300 200]);
            resizeFigure(viewer.OverviewFigure, [400 200]);
            ax = showCanvas(viewer.OverviewFigure);
            testCase.hover(ax, [201.25 101.25]);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, 'View: overview (resampled)'));
            testCase.verifyTrue(contains(text, 'Displayed (0-255): 128'));
            % Each overview texel averages a black/white source pair.
            coordinates = sscanf(char(extractAfter(string(text), ...
                'Column (X): ')), '%d Row (Y): %d', [1 2]);
            % Gesture placement rounds to screen pixels in this 2:1 view.
            testCase.verifyEqual(coordinates, [201 101], 'AbsTol', 1);
            testCase.verifyTrue(contains(text, 'Original (uint8): 0'));
        end

        function nonuniformOverviewMatchesRenderedTexel(testCase)
            [x, y] = meshgrid(1:809, 1:403);
            data = uint8(cat(3, mod(17 * x + 29 * y, 256), ...
                mod(31 * x + 7 * y, 256), mod(3 * x + 43 * y, 256)));
            viewer = testCase.create(data, Limits=[0 255]);
            testCase.openCursor(viewer, viewer.MainCenter);
            ax = showCanvas(viewer.OverviewFigure);
            im = findobj(viewer.OverviewFigure, 'Tag', 'twd.pixels');
            raster = im.CData;
            xs = linspace(im.XData(1), im.XData(end), size(raster, 2));
            ys = linspace(im.YData(1), im.YData(end), size(raster, 1));
            targets = [57 41; 301 147];
            for target = targets.'
                testCase.hover(ax, [xs(target(1)) ys(target(2))]);
                % Find the nearest rendered texel independently of source
                % rounding; the overview has noninteger sampling ratios.
                point = ax.CurrentPoint(1, 1:2);
                [~, column] = min(abs(xs - point(1)));
                [~, row] = min(abs(ys - point(2)));
                displayed = reshape(raster(row, column, :), 1, []);
                pixel = round(point);
                original = reshape(data(pixel(2), pixel(1), :), 1, []);
                text = cursorText(viewer);
                testCase.verifyTrue(contains(text, ...
                    ['Displayed (0-255): ' mat2str(displayed)]));
                testCase.verifyTrue(contains(text, ...
                    ['Original (uint8): ' mat2str(original)]));
            end
        end

        function firstAndLastPixelsRemainAddressable(testCase, edge)
            data = reshape(uint32(1:160000), 400, 400);
            viewer = testCase.create(data);
            testCase.openCursor(viewer, [200 200]);
            ax = showCanvas(viewer.MainFigure);
            testCase.hover(ax, edge);
            text = cursorText(viewer);
            testCase.verifyTrue(contains(text, sprintf( ...
                'Column (X): %d    Row (Y): %d', edge)));
            testCase.verifyTrue(contains(text, sprintf( ...
                'Original (uint32): %d', data(edge(2), edge(1)))));
        end

        function doubleClickInPaddingAlsoOpensReadout(testCase)
            viewer = testCase.create(uint8(42));
            testCase.openCursor(viewer, [-20 -20]);
            testCase.verifyEqual(cursorText(viewer), 'Outside image');
        end

        function overviewMarginDoesNotClampToSourcePixel(testCase)
            viewer = testCase.create(ones(1, 1000));
            testCase.openCursor(viewer, [500 1]);
            showCanvas(viewer.OverviewFigure);
            testCase.hover(viewer.OverviewFigure, [10 10]);
            testCase.verifyEqual(cursorText(viewer), 'Outside image');
        end

        function zoomButtonsDoNotReportObscuredPixels(testCase)
            viewer = testCase.create(ones(400));
            testCase.openCursor(viewer, [200 200]);
            showCanvas(viewer.ZoomFigure);
            testCase.hover(viewer.ZoomFigure, [10 10]);
            testCase.verifyEqual(cursorText(viewer), 'Outside image');
        end

        function paddingClearsReadoutAndValidHoverRestoresIt(testCase)
            viewer = testCase.create(uint16(64000));
            testCase.openCursor(viewer, [1 1]);
            ax = showCanvas(viewer.MainFigure);
            testCase.hover(ax, [-20 -20]);
            testCase.verifyEqual(cursorText(viewer), 'Outside image');
            testCase.hover(ax, [1 1]);
            testCase.verifyTrue(contains(cursorText(viewer), ...
                'Original (uint16): 64000'));
        end

        function readoutCanCloseDeleteAndReopen(testCase)
            viewer = testCase.create(ones(400));
            testCase.openCursor(viewer, [200 200]);
            first = viewer.CursorFigure;
            close(first);
            testCase.verifyFalse(isgraphics(first));
            testCase.verifyTrue(isvalid(viewer));
            testCase.verifyTrue(all(isgraphics([viewer.MainFigure ...
                viewer.OverviewFigure viewer.ZoomFigure])));
            ax = showCanvas(viewer.MainFigure);
            testCase.hover(ax, [201 202]);
            testCase.openCursor(viewer, [200 200]);
            second = viewer.CursorFigure;
            testCase.verifyNotEqual(second, first);
            delete(second);
            testCase.hover(ax, [201 202]);
            testCase.openCursor(viewer, [200 200]);
            testCase.verifyTrue(isgraphics(viewer.CursorFigure));
            testCase.verifyTrue(isvalid(viewer));
        end

        function groupCloseAlsoClosesReadout(testCase)
            viewer = testCase.create(ones(400));
            testCase.openCursor(viewer, [200 200]);
            cursor = viewer.CursorFigure;
            close(viewer.ZoomFigure);
            testCase.verifyFalse(isgraphics(cursor));
            testCase.verifyFalse(isvalid(viewer));
        end

        function groupsHaveIndependentReadouts(testCase)
            first = testCase.create(ones(400) * 12);
            second = testCase.create(ones(400) * 34);
            testCase.openCursor(first, [200 200]);
            testCase.openCursor(second, [200 200]);
            ax = showCanvas(first.MainFigure);
            testCase.hover(ax, [210 220]);
            testCase.verifyTrue(contains(cursorText(first), ...
                'Original (double): 12'));
            testCase.verifyTrue(contains(cursorText(second), ...
                'Original (double): 34'));
            testCase.verifyTrue(contains(cursorText(second), ...
                'Column (X): 200    Row (Y): 200'));
            close(first.CursorFigure);
            testCase.verifyTrue(isgraphics(second.CursorFigure));
        end

        function draggingStillWorksWithReadoutOpen(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            testCase.openCursor(viewer, viewer.MainCenter);
            ax = showCanvas(viewer.MainFigure);
            before = viewer.MainCenter;
            testCase.drag(ax, before + [40 40], before + [100 80], ...
                SelectionType='alt');
            testCase.verifyEqual(viewer.MainCenter, before - [60 40], ...
                'AbsTol', 2);
            testCase.verifyTrue(contains(cursorText(viewer), ...
                'Displayed (0-255): 128'));
        end

        function regressionViewportEdges(testCase, cropView, edgeDirection)
            viewer = testCase.create(repmat(uint32(1:1000), 1000, 1));
            testCase.openCursor(viewer, viewer.MainCenter);
            figures = struct('main', viewer.MainFigure, ...
                'zoom', viewer.ZoomFigure);
            fig = figures.(cropView);
            resizeFigure(fig, [500 500]);
            ax = showCanvas(fig);
            % Inset the axes to make their exact boundary reachable by a
            % figure gesture; axes gestures reject the upper boundary.
            % The one-pixel aspect margin aligns the edge with a screen
            % pixel center, so the gesture can land exactly on the edge.
            ax.Position = [21 21 400 + edgeDirection];
            testCase.hover(fig, [221 221] + [200 -200] .* edgeDirection);
            point = ax.CurrentPoint(1, 1:2);
            upper = [ax.XLim(2) ax.YLim(2)];
            testCase.assertEqual(point(logical(edgeDirection)), ...
                upper(logical(edgeDirection)), 'AbsTol', 1e-10);
            testCase.verifyEqual(cursorText(viewer), 'Outside image');
        end

        function regressionClosingListenerDuringMotion(testCase)
            viewer = testCase.create(zeros(1000, 1000, 'uint8'));
            fig = viewer.MainFigure;
            ax = showCanvas(fig);
            point = viewer.ZoomCenter;
            testCase.hover(ax, point);
            image = findobj(fig, 'Tag', 'twd.pixels');
            image.ButtonDownFcn(image, []);
            testCase.hover(ax, point + [1 1]);
            listener = addlistener(viewer, 'NavigationChanged', ...
                @(source, ~) delete(source));
            testCase.addTeardown(@() delete(listener));
            motion = fig.WindowButtonMotionFcn;
            testCase.verifyWarningFree(@() motion(fig, []));
            testCase.verifyFalse(isvalid(viewer));
            testCase.verifyFalse(isgraphics(fig));
        end
    end

    methods (Access = private)
        function viewer = create(testCase, data, varargin)
            viewer = twd.show(data, varargin{:}, Visible='off');
            testCase.addTeardown(@() deleteIfValid(viewer));
        end

        function openCursor(testCase, viewer, point)
            ax = showCanvas(viewer.MainFigure);
            testCase.press(ax, point, SelectionType='open');
            testCase.assertTrue(isgraphics(viewer.CursorFigure));
        end
    end
end

function text = cursorText(viewer)
    box = findobj(viewer.CursorFigure, 'Tag', 'twd.cursorText');
    text = char(join(string(box.String), newline));
end

function ax = showCanvas(fig)
    fig.Visible = 'on';
    drawnow;
    ax = findobj(fig, 'Type', 'axes');
end

function resizeFigure(fig, extent)
    fig.Position(3:4) = extent;
    fig.SizeChangedFcn(fig, []);
    drawnow;
end

function deleteIfValid(viewer)
    if isvalid(viewer)
        delete(viewer);
    end
end
