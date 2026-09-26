classdef TwdDisplayTest < matlab.uitest.TestCase
    %TwdDisplayTest - Public navigation, rendering, and window callbacks
    properties (TestParameter)
        shape = struct('landscape', [240 800], ...
            'portrait', [800 240], 'square', [400 400]);
        pixelClass = {'uint8', 'uint16', 'int16', 'single', 'double', ...
            'logical'};
        invalidImage = {[], complex(ones(2)), sparse(eye(2)), ...
            zeros(4, 4, 2), zeros(4, 4, 3, 2), 'pixels'};
        nonfinite = {NaN, Inf, -Inf};
    end

    methods (TestClassSetup)
        function configurePaths(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'src')));
        end
    end

    methods (Test)
        function defaultsAndNativeData(testCase, pixelClass)
            data = cast(reshape(mod(0:359999, 251), 600, 600), pixelClass);
            viewer = testCase.create(data);
            testCase.verifyEqual(viewer.Data, data);
            testCase.verifyEqual(viewer.MainViewport(3:4), [500 500]);
            testCase.verifyEqual(viewer.ZoomFactor, 4);
            testCase.verifyEqual(viewer.ZoomViewport(3:4), [25 25]);
            testCase.verifyScale(viewer.MainFigure, 1);
            testCase.verifyScale(viewer.ZoomFigure, 4);
        end

        function overviewAlwaysIsotropic(testCase, shape)
            viewer = testCase.create(zeros(shape, 'uint8'));
            ax = findobj(viewer.OverviewFigure, 'Type', 'axes');
            testCase.verifyEqual(diff(ax.XLim), shape(2));
            testCase.verifyEqual(diff(ax.YLim), shape(1));
            extent = ax.Position(3:4);
            testCase.verifyEqual(extent(1) / shape(2), ...
                extent(2) / shape(1), 'AbsTol', 1e-12);
            testCase.verifyEqual(ax.DataAspectRatio, [1 1 1]);
        end

        function fixedPerChannelPercentiles(testCase)
            ramp = reshape(0:9999, 100, 100);
            data = cat(3, ramp, ramp * 2 + 100, ramp * 3 - 90);
            viewer = testCase.create(data);
            expected = [199.98 9799.02; 499.96 19698.04; 509.94 29307.06];
            testCase.verifyEqual(viewer.Limits, expected, 'AbsTol', 1e-10);
            viewer.panTo([1 1]);
            viewer.setZoomFactor(9);
            testCase.verifyEqual(viewer.Limits, expected, 'AbsTol', 1e-10);
            testCase.verifyEqual(viewer.Data, data);
        end

        function singleColumnStretch(testCase)
            viewer = testCase.create((0:100).');
            testCase.verifyEqual(viewer.Limits, [2 98], 'AbsTol', 1e-12);
        end

        function explicitLimitsAndRgbMapping(testCase)
            data = cat(3, [0 10; 20 30], [100 200; 300 400], ...
                [-10 0; 10 20]);
            viewer = testCase.create(data, ...
                Limits=[0 30; 100 400; -10 20]);
            pixels = findobj(viewer.MainFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(pixels.CData, ...
                repmat(uint8([0 85; 170 255]), 1, 1, 3));
            testCase.verifyEqual(viewer.Data, data);
        end

        function commonLimitsExpandToRgb(testCase)
            viewer = testCase.create(ones(3, 4, 3), Limits=[0 4]);
            testCase.verifyEqual(viewer.Limits, repmat([0 4], 3, 1));
        end

        function nonfiniteOverviewNeighborsDoNotEraseFinitePixels( ...
                testCase, nonfinite)
            viewer = testCase.create([10 nonfinite; 10 nonfinite], ...
                OverviewWidth=120);
            image = findobj(viewer.OverviewFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(image.CData(:, 1, 1), ...
                repmat(uint8(128), size(image.CData, 1), 1));
            testCase.verifyEqual(image.CData(:, end, 1), ...
                zeros(size(image.CData, 1), 1, 'uint8'));
        end

        function singletonThumbnailColumnCoversWholeSource(testCase)
            viewer = testCase.create(ones(1000, 2), OverviewWidth=1);
            image = findobj(viewer.OverviewFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(size(image.CData, 2), 2);
            step = diff(image.XData) / (size(image.CData, 2) - 1);
            testCase.verifyEqual(image.XData + [-step step] / 2, [0.5 2.5]);
            testCase.verifyEqual(image.CData(:, 1, :), image.CData(:, 2, :));
        end

        function singletonThumbnailRowCoversWholeSource(testCase)
            viewer = testCase.create(ones(2, 1000), OverviewWidth=120);
            image = findobj(viewer.OverviewFigure, 'Tag', 'twd.pixels');
            testCase.verifySize(image.CData, [2 120 3]);
            step = diff(image.YData) / (size(image.CData, 1) - 1);
            testCase.verifyEqual(image.YData + [-step step] / 2, [0.5 2.5]);
            testCase.verifyEqual(image.CData(1, :, :), image.CData(2, :, :));
        end

        function integerOverviewOptionAvoidsSaturation(testCase)
            viewer = testCase.create(zeros(300, 900), ...
                OverviewWidth=uint16(400));
            testCase.verifyEqual(viewer.OverviewFigure.Position(3:4), ...
                [400 133]);
        end

        function normalizedRootUnitsDoNotChangePixelSizes(testCase)
            previous = get(groot, 'Units');
            testCase.addTeardown(@() set(groot, 'Units', previous));
            set(groot, 'Units', 'normalized');
            viewer = testCase.create(zeros(600));
            testCase.verifyEqual(viewer.MainViewport(3:4), [500 500]);
            testCase.verifyEqual(get(groot, 'Units'), 'normalized');
        end

        function portraitOverviewStartsBelowMain(testCase)
            viewer = testCase.create(zeros(2400, 400));
            main = viewer.MainFigure.Position;
            overview = viewer.OverviewFigure.Position;
            zoom = viewer.ZoomFigure.Position;
            testCase.verifyLessThan(overview(2) + overview(4), main(2));
            testCase.verifyLessThan(zoom(2) + zoom(4), main(2));
            testCase.verifyGreaterThanOrEqual(overview(2), 1);
        end

        function extremeAspectResizeStaysBoundedAndIsotropic(testCase)
            viewer = testCase.create(ones(10000, 2), OverviewWidth=120);
            resizeFigure(viewer.OverviewFigure, [160 200]);
            position = viewer.OverviewFigure.Position;
            screen = get(groot, 'ScreenSize');
            testCase.verifyLessThanOrEqual(position(4), screen(4));
            ax = findobj(viewer.OverviewFigure, 'Type', 'axes');
            testCase.verifyEqual(ax.Position(3) / diff(ax.XLim), ...
                ax.Position(4) / diff(ax.YLim), 'AbsTol', 1e-12);
        end

        function finiteMinmaxAndNonfinitePixels(testCase)
            viewer = testCase.create([NaN Inf; -Inf 2; 5 8], ...
                Stretch='minmax');
            pixels = findobj(viewer.MainFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(viewer.Limits, [2 8]);
            testCase.verifyEqual(pixels.CData(:, :, 1), ...
                uint8([0 0; 0 0; 128 255]));
        end

        function constantAndAllNonfiniteChannels(testCase)
            viewer = testCase.create(cat(3, ones(2), NaN(2), Inf(2)));
            pixels = findobj(viewer.MainFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(pixels.CData(:, :, 1), ...
                repmat(uint8(128), 2));
            testCase.verifyEqual(pixels.CData(:, :, 2:3), ...
                zeros(2, 2, 2, 'uint8'));
        end

        function fullFloatingRangeDoesNotOverflow(testCase)
            viewer = testCase.create([-realmax 0 realmax], ...
                Limits=[-realmax realmax]);
            pixels = findobj(viewer.MainFigure, 'Tag', 'twd.pixels');
            testCase.verifyEqual(pixels.CData(:, :, 1), uint8([0 128 255]));
        end

        function tinyImageKeepsScaleAndPads(testCase)
            viewer = testCase.create(uint8(12));
            testCase.verifyEqual(viewer.MainViewport(3:4), [500 500]);
            testCase.verifyEqual(viewer.ZoomViewport(3:4), [25 25]);
            testCase.verifyScale(viewer.MainFigure, 1);
            testCase.verifyScale(viewer.ZoomFigure, 4);
            testCase.verifyEqual(viewer.ZoomCenter, [1 1]);
        end

        function mainClampsAtBothImageEdges(testCase)
            viewer = testCase.create(zeros(800, 1200, 'uint8'));
            viewer.panTo([-100 -100]);
            testCase.verifyEqual(viewer.MainViewport, [0.5 0.5 500 500]);
            viewer.panTo([5000 5000]);
            testCase.verifyEqual(viewer.MainViewport, [700.5 300.5 500 500]);
            testCase.verifyScale(viewer.MainFigure, 1);
        end

        function panTranslatesZoomWithMain(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            original = viewer.ZoomCenter;
            viewer.panTo(viewer.MainCenter + [31 -57]);
            testCase.verifyEqual(viewer.ZoomCenter, original + [31 -57]);
        end

        function zoomStaysWithinMain(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            viewer.zoomTo([-100 -100]);
            testCase.verifyEqual(viewer.ZoomViewport(1:2), ...
                viewer.MainViewport(1:2));
            viewer.zoomTo([10000 10000]);
            testCase.verifyEqual(sum(reshape(viewer.ZoomViewport, 2, 2), 2), ...
                sum(reshape(viewer.MainViewport, 2, 2), 2));
        end

        function mainResizeChangesAreaOnly(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            resizeFigure(viewer.MainFigure, [320 210]);
            testCase.verifyEqual(viewer.MainViewport(3:4), [320 210]);
            testCase.verifyEqual(viewer.ZoomFactor, 4);
            testCase.verifyScale(viewer.MainFigure, 1);
            testCase.verifyScale(viewer.ZoomFigure, 4);
        end

        function zoomResizeKeepsFactor(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            resizeFigure(viewer.ZoomFigure, [180 120]);
            testCase.verifyEqual(viewer.ZoomViewport(3:4), [45 30]);
            testCase.verifyEqual(viewer.ZoomFactor, 4);
            viewer.setZoomFactor(7);
            testCase.verifyEqual(viewer.ZoomViewport(3:4), [180 120] / 7);
            testCase.verifyScale(viewer.ZoomFigure, 7);
        end

        function overviewResizeConstrainsAspect(testCase)
            viewer = testCase.create(zeros(300, 900, 'uint8'));
            resizeFigure(viewer.OverviewFigure, [600 133]);
            position = viewer.OverviewFigure.Position;
            testCase.verifyEqual(position(3:4), [600 200]);
            resizeFigure(viewer.OverviewFigure, [600 250]);
            position = viewer.OverviewFigure.Position;
            testCase.verifyEqual(position(3:4), [750 250]);
            ax = findobj(viewer.OverviewFigure, 'Type', 'axes');
            testCase.verifyEqual(ax.Position(3) / diff(ax.XLim), ...
                ax.Position(4) / diff(ax.YLim), 'AbsTol', 1e-12);
        end

        function overviewGrowthKeepsWindowOnScreen(testCase)
            viewer = testCase.create(zeros(600));
            screen = get(groot, 'ScreenSize');
            sizeBefore = viewer.OverviewFigure.Position(3:4);
            resizeFigure(viewer.OverviewFigure, ...
                [screen(4) - 120 sizeBefore(2)]);
            position = viewer.OverviewFigure.OuterPosition;
            testCase.verifyGreaterThanOrEqual(position(1:2), screen(1:2));
            testCase.verifyLessThanOrEqual(position(1:2) + position(3:4), ...
                screen(1:2) + screen(3:4));
        end

        function oversizedZoomKeepsItsMainBoxVisible(testCase)
            viewer = testCase.create(zeros(1000), ZoomFactor=1, ...
                ZoomSize=[700 600]);
            box = findobj(viewer.MainFigure, 'Tag', 'twd.viewport');
            testCase.verifyEqual(box.XData([1 2]), ...
                viewer.MainViewport(1) + [0 viewer.MainViewport(3)]);
            testCase.verifyEqual(box.YData([1 3]), ...
                viewer.MainViewport(2) + [0 viewer.MainViewport(4)]);
        end

        function boxesRepresentActualViewports(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            viewer.panTo([400 400]);
            viewer.zoomTo([500 500]);
            overviewBox = findobj(viewer.OverviewFigure, ...
                'Tag', 'twd.viewport');
            mainBox = findobj(viewer.MainFigure, 'Tag', 'twd.viewport');
            testCase.verifyEqual(overviewBox.XData([1 2]), ...
                viewer.MainViewport(1) + [0 500]);
            testCase.verifyEqual(mainBox.XData([1 2]), ...
                viewer.ZoomViewport(1) + [0 25]);
            crosshair = findobj(viewer.ZoomFigure, 'Tag', 'twd.crosshair');
            testCase.verifyEqual(mean(crosshair.XData(1:2)), ...
                viewer.ZoomCenter(1));
        end

        function plusMinusCallbacksHaveIntegerFloor(testCase)
            viewer = testCase.create(zeros(500, 'uint8'), ZoomFactor=1);
            minus = findobj(viewer.ZoomFigure, 'Tag', 'twd.-');
            plus = findobj(viewer.ZoomFigure, 'Tag', 'twd.+');
            minus.Callback(minus, []);
            testCase.verifyEqual(viewer.ZoomFactor, 1);
            plus.Callback(plus, []);
            testCase.verifyEqual(viewer.ZoomFactor, 2);
            testCase.verifyScale(viewer.ZoomFigure, 2);
        end

        function overviewClickAndDrag(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            ui = testCase;
            ax = showCanvas(viewer.OverviewFigure);
            ui.press(ax, [300 300]);
            testCase.verifyEqual(viewer.MainCenter, [300 300], 'AbsTol', 4);
            ui.drag(ax, [300 300], [350 340]);
            testCase.verifyEqual(viewer.MainCenter, [350 340], 'AbsTol', 5);
            stopped = viewer.MainCenter;
            ui.hover(ax, [400 400]);
            testCase.verifyEqual(viewer.MainCenter, stopped);
        end

        function mainBoxDragsWithoutJump(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            original = viewer.ZoomCenter;
            ui = testCase;
            ax = showCanvas(viewer.MainFigure);
            ui.press(ax, original + [3 4]);
            testCase.verifyEqual(viewer.ZoomCenter, original);
            ui.drag(ax, original + [3 4], original + [13 24]);
            testCase.verifyEqual(viewer.ZoomCenter, original + [10 20], ...
                'AbsTol', 2);
        end

        function zoomClickRecenters(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'), ...
                ZoomSize=[160 120]);
            target = viewer.ZoomCenter + [4 7];
            ui = testCase;
            ax = showCanvas(viewer.ZoomFigure);
            ui.press(ax, target);
            testCase.verifyEqual(viewer.ZoomCenter, target, 'AbsTol', 0.5);
        end

        function rightDragPansWithoutFeedbackDrift(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            original = viewer.MainCenter;
            ui = testCase;
            ax = showCanvas(viewer.MainFigure);
            ui.drag(ax, original + [40 40], original + [100 80], ...
                SelectionType='alt');
            testCase.verifyEqual(viewer.MainCenter, original - [60 40], ...
                'AbsTol', 2);
            testCase.verifyScale(viewer.MainFigure, 1);
        end

        function keyboardPansAndChangesZoom(testCase)
            viewer = testCase.create(zeros(1000, 1400, 'uint8'));
            original = viewer.MainCenter;
            event = struct('Key', 'rightarrow', 'Modifier', {{'shift'}});
            viewer.MainFigure.WindowKeyPressFcn([], event);
            testCase.verifyEqual(viewer.MainCenter, original + [10 0]);
            event.Key = 'equal';
            viewer.ZoomFigure.WindowKeyPressFcn([], event);
            testCase.verifyEqual(viewer.ZoomFactor, 5);
        end

        function groupsRemainIndependentAndPublishNavigation(testCase)
            first = testCase.create(zeros(1000, 1400, 'uint8'));
            second = testCase.create(zeros(1000, 1400, 'uint8'));
            first.MainFigure.UserData = 0;
            listener = addlistener(first, 'NavigationChanged', ...
                @(~, ~) increment(first.MainFigure));
            testCase.addTeardown(@() delete(listener));
            unchanged = second.MainViewport;
            first.panTo([300 300]);
            testCase.verifyEqual(first.MainFigure.UserData, 1);
            testCase.verifyEqual(second.MainViewport, unchanged);
        end

        function closingOneWindowClosesGroup(testCase)
            viewer = testCase.create(ones(40));
            figures = [viewer.MainFigure viewer.OverviewFigure ...
                viewer.ZoomFigure];
            close(viewer.OverviewFigure);
            testCase.verifyFalse(isvalid(viewer));
            testCase.verifyFalse(any(isgraphics(figures)));
        end

        function deletingOneWindowClosesGroup(testCase)
            viewer = testCase.create(ones(40));
            figures = [viewer.MainFigure viewer.OverviewFigure ...
                viewer.ZoomFigure];
            delete(viewer.ZoomFigure);
            testCase.verifyFalse(isvalid(viewer));
            testCase.verifyFalse(any(isgraphics(figures)));
        end

        function rejectsUnsupportedImages(testCase, invalidImage)
            testCase.verifyError(@() twd.show(invalidImage, Visible='off'), ...
                'twd:InvalidImage');
        end

        function rejectsBadOptionsBeforeOpeningFigures(testCase)
            testCase.verifyError(@() twd.show(ones(2), ZoomFactor=1.5), ...
                'twd:InvalidSize');
            testCase.verifyError(@() twd.show(ones(2), MainSize=[0 10]), ...
                'twd:InvalidSize');
            testCase.verifyError(@() twd.show(ones(2), Limits=[2 1]), ...
                'twd:InvalidLimits');
        end

        function rejectsBadNavigationWithoutChangingState(testCase)
            viewer = testCase.create(ones(600));
            initial = viewer.MainViewport;
            testCase.verifyError(@() viewer.panTo([Inf 2]), ...
                'twd:InvalidPoint');
            testCase.verifyError(@() viewer.setZoomFactor(0), ...
                'twd:InvalidSize');
            testCase.verifyError(@() viewer.setZoomFactor(1e18), ...
                'twd:InvalidZoomFactor');
            testCase.verifyEqual(viewer.MainViewport, initial);
            testCase.verifyEqual(viewer.ZoomFactor, 4);
        end

        function zoomUpperBoundRemainsUsable(testCase)
            viewer = testCase.create(ones(600), ZoomFactor=1024);
            plus = findobj(viewer.ZoomFigure, 'Tag', 'twd.+');
            minus = findobj(viewer.ZoomFigure, 'Tag', 'twd.-');
            plus.Callback(plus, []);
            testCase.verifyEqual(viewer.ZoomFactor, 1024);
            minus.Callback(minus, []);
            testCase.verifyEqual(viewer.ZoomFactor, 1023);
            viewer.panTo([400 400]);
            testCase.verifyScale(viewer.MainFigure, 1);
        end
    end

    methods (Access = private)
        function viewer = create(testCase, data, varargin)
            viewer = twd.show(data, varargin{:}, Visible='off');
            testCase.addTeardown(@() deleteIfValid(viewer));
        end

        function verifyScale(testCase, fig, factor)
            ax = findobj(fig, 'Type', 'axes');
            extent = ax.Position(3:4);
            testCase.verifyEqual(extent ./ [diff(ax.XLim) diff(ax.YLim)], ...
                [factor factor], 'AbsTol', 1e-10);
            testCase.verifyEqual(ax.DataAspectRatio, [1 1 1]);
            testCase.verifyEmpty(ax.Interactions);
            testCase.verifyEmpty(ax.Toolbar);
        end
    end
end

function deleteIfValid(viewer)
    if isvalid(viewer)
        delete(viewer);
    end
end

function resizeFigure(fig, extent)
    fig.Position(3:4) = extent;
    fig.SizeChangedFcn(fig, []);
    drawnow;
end

function ax = showCanvas(fig)
    fig.Visible = 'on';
    drawnow;
    ax = findobj(fig, 'Type', 'axes');
end

function increment(fig)
    fig.UserData = fig.UserData + 1;
end
