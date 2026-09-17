function [obj, reader] = readImagingOperation(reader) %#codegen
    %readImagingOperation - Decode bounded ImagingOperation fields without exceptions
    obj = nfx.ImagingOperation();
    [value, reader] = reader.sizedText(2, 99);
    if reader.ok
        obj.cm_id = value;
    end
    [value, reader] = reader.sizedText(2, 99);
    if reader.ok
        obj.sensor_config = value;
    end
    [value, reader] = reader.sizedText(2, 99);
    if reader.ok
        obj.img_op_id = value;
    end
    [value, reader] = reader.number( ...
        2, 1, 99, 1, false);
    if reader.ok
        obj.num_exp = value;
    end
    [width, reader] = reader.number(1, 0, 8, true);
    if width > 0
        [count, reader] = reader.count(2, width, 99);
        [indices, reader] = reader.unsigned(width, count);
        if reader.ok
            obj.index_in_img_op_id = indices;
        end
    end
    if reader.ok
        obj.index_size = width;
    end
    [count, reader] = reader.count(2, 7, 99);
    metrics = nfx.QualityMetric.empty(1, 0);
    for k = 1:count
        [item, reader] = readQualityMetric(reader);
        if reader.ok
            metrics(k) = item;
        end
    end
    if reader.ok
        obj.quality_metrics = metrics;
    end
end
