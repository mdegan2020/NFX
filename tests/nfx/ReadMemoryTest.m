classdef ReadMemoryTest < NfxTest
    properties (TestParameter)
        invalidThreshold = {-1, NaN, single(1), [1 2], 1i, '1'}
        reader = {'file', 'collection', 'image', 'all', 'segment'}
    end
    methods (Test)
        function warningDoesNotBlockRequestedRead(t)
            file = fixtureFile(); filename = fullfile(t.folder, 'memory.ntf');
            file.write(filename);
            t.verifyWarning(@() requireRead(filename, 0), 'nfx:MemoryUsage');
            t.verifyWarningFree(@() requireRead(filename, Inf));
        end

        function deferredOperationsWarnAndRetainPixels(t)
            file = fixtureFile(); filename = fullfile(t.folder, 'memory.ntf');
            file.write(filename);
            deferred = nfx.File.read(filename);
            t.verifyWarning(@() requireAll(deferred, 0), 'nfx:MemoryUsage');
            t.verifyWarning(@() requireSegment(deferred, 0), 'nfx:MemoryUsage');
            t.verifyWarning(@() requireImage(deferred.images(1), 0), 'nfx:MemoryUsage');
            t.verifyFalse(deferred.images(1).pixelsLoaded);
        end

        function metadataOnlyDoesNotBudgetUnreadPixels(t)
            [file, image] = fixtureFile(zeros(100, 100, 'uint16'));
            filename = fullfile(t.folder, 'metadata.ntf'); file.write(filename);
            threshold = 2 * (file.header.fl - image.li) + 1;
            t.verifyWarningFree(@() nfx.File.read(filename, MemoryWarningBytes=threshold));
            deferred = nfx.File.read(filename, MemoryWarningBytes=threshold);
            t.verifyWarning(@() requireStoredRead(deferred), 'nfx:MemoryUsage');
            t.verifyWarning(@() requireStoredImage(deferred.images(1)), 'nfx:MemoryUsage');
            t.verifyWarning(@() temporaryPixels(deferred.images(1)), 'nfx:MemoryUsage');
        end

        function explicitCapsStillFail(t)
            file = fixtureFile(); filename = fullfile(t.folder, 'memory.ntf'); file.write(filename);
            deferred = nfx.File.read(filename);
            [copy, ok, status] = deferred.readAll(MaxPixels=1, MemoryWarningBytes=0);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyFalse(copy.images(1).pixelsLoaded);
        end

        function aggregateCollectionWarningContinues(t)
            source = fixtureMIECollection(); paths = source.write(t.folder);
            t.verifyWarning(@() requireCollection(paths{end}, 0), 'nfx:MemoryUsage');
            t.verifyWarningFree(@() requireCollection(paths{end}, Inf));
        end

        function invalidThresholdIsDiagnostic(t, invalidThreshold, reader)
            [~, ok, status] = invalidRead(reader, invalidThreshold);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
        end
    end
end

function requireRead(filename, threshold)
    [file, ok, status] = nfx.File.read(filename, readAll=true, MemoryWarningBytes=threshold);
    assert(ok, status.message); assert(all([file.images.pixelsLoaded]));
end

function requireAll(file, threshold)
    [file, ok, status] = file.readAll(MemoryWarningBytes=threshold);
    assert(ok, status.message); assert(all([file.images.pixelsLoaded]));
end

function requireSegment(file, threshold)
    [file, ok, status] = file.readSegment(1, MemoryWarningBytes=threshold);
    assert(ok, status.message); assert(file.images(1).pixelsLoaded);
end

function requireImage(image, threshold)
    [image, ok, status] = image.read(MemoryWarningBytes=threshold);
    assert(ok, status.message); assert(image.pixelsLoaded);
end

function requireStoredRead(file)
    [file, ok, status] = file.readAll();
    assert(ok, status.message); assert(all([file.images.pixelsLoaded]));
end

function requireStoredImage(image)
    [image, ok, status] = image.read();
    assert(ok, status.message); assert(image.pixelsLoaded);
end

function temporaryPixels(image)
    assert(~isempty(image.data));
end

function requireCollection(filename, threshold)
    [collection, ok, status] = nfx.MIECollection.read(filename, MemoryWarningBytes=threshold);
    assert(ok, status.message); assert(~isempty(collection.blocks));
end

function [value, ok, status] = invalidRead(reader, threshold)
    switch reader
        case 'file'
            [value, ok, status] = nfx.File.read('unused.ntf', MemoryWarningBytes=threshold);
        case 'collection'
            [value, ok, status] = nfx.MIECollection.read('unused.ntf', MemoryWarningBytes=threshold);
        case 'image'
            [value, ok, status] = nfx.ImageSegment().read(MemoryWarningBytes=threshold);
        case 'all'
            [value, ok, status] = nfx.File().readAll(MemoryWarningBytes=threshold);
        case 'segment'
            [value, ok, status] = nfx.File().readSegment([], MemoryWarningBytes=threshold);
    end
end
