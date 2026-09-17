function status = decodeStatus(code, message, offset) %#codegen
    %decodeStatus - Create a homogeneous lookup or decoding status
    arguments
        code = 'OK'
        message = ''
        offset = 0
    end
    status = struct('code', code, 'message', message, 'offset', offset);
end
