classdef (Sealed) SensorBand
    %SensorBand - Identify one spectral band associated with a CSSFAB model
    %   OBJ = SensorBand(Name=VALUE) stores BAND_INDEX, IREPBAND, and ISUBCAT.
    %   ISUBCAT is a scalar double wavelength in micrometers, or NaN for blank.
    %   Its six-byte decimal field uses the available fractional precision.
    %   Image subheader ISUBCAT values are in nanometers for this association.
    %
    %   See also CSSFAB, ImageHeader

    properties
        band_index {mustBeMetadata(band_index,1,99999,1)} = NaN
        irepband {mustBeAscii(irepband,2)} = ''
        isubcat {mustBeMetadata(isubcat,0,999999,0)} = NaN
    end
    methods
        function obj = SensorBand(options) %#codegen
            %SensorBand - Construct editable band association metadata
            arguments
                options.?nfx.SensorBand
            end
            if isfield(options,'band_index'), obj.band_index = options.band_index; end
            if isfield(options,'irepband'), obj.irepband = options.irepband; end
            if isfield(options,'isubcat'), obj.isubcat = options.isubcat; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check a known index and meaningful wavelength precision
            report = newReport('CSSFAB SensorBand');
            reference = 'STDI-0002-2 Appendix M, Table M.6-7';
            report = addIssue(report,isnan(obj.band_index),'Required','band_index','Supply a one-based band index.',reference);
            if ~isnan(obj.isubcat)
                encoded = str2double(char(bandDecimal(obj.isubcat,6)));
                report = addIssue(report,obj.isubcat ~= 0 && encoded == 0,'BandWavelengthPrecision','isubcat', ...
                    'The six-byte decimal field cannot round a nonzero wavelength to zero.',reference);
            end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the index and supplemental band identity fields
            requireValid(validate(obj)); subcat = repmat(uint8(' '),1,6);
            if ~isnan(obj.isubcat), subcat = bandDecimal(obj.isubcat,6); end
            value = [decimalField(obj.band_index,5,0,false) textField(obj.irepband,2) subcat];
        end
    end
end
