classdef ImageSegment
    %ImageSegment - Image pixels, header, and ordered TRE snapshots
    %   OBJ = ImageSegment creates an empty segment for incremental editing.
    %
    %   OBJ = ImageSegment(DATA) attaches dense real uint8 or uint16 pixels
    %   in rows-by-columns-by-bands-by-frames order without converting class.
    %   Multiple frames require matching MTIMSA timing and a motion ICAT.
    %
    %   OBJ = ImageSegment(DATA,header=HEADER) also supplies image metadata.
    %   Derived fields always reflect DATA and current block dimensions.
    %
    %   ImageSegment functions:
    %       plus      - Append a validated TRE snapshot
    %       removeTRE - Remove one attachment by its ID
    %       validate  - Check header, data, and attached TREs
    %       compress  - Capture an experimental lossless OpenJPEG encoding
    %       uncompress - Restore native uncompressed storage
    %
    %   ImageSegment properties:
    %       data     - Native pixel array
    %       header   - Editable image header with derived dimensions
    %       tre_ids  - Attachment IDs in insertion order
    %       tre_tags - Six-character tags in insertion order
    %       lish     - Derived subheader byte length
    %       li       - Derived stored image byte length
    %       tre_records - Physical snapshots, including derived records
    %       number_frames - Frame count in the native pixel array
    %       compression - Immutable JPEG2000 snapshot, or empty
    %
    %   See also ImageHeader, RPC00B, File

    properties (Dependent)
        data % Native rows-by-columns-by-bands-by-frames pixels
        header % Metadata with fresh derived fields
    end
    properties (Dependent, SetAccess = private)
        tre_ids % Ordered private-collection identities, exposed for removal
        tre_tags % Ordered tags, one row per attachment
        tre_records % Physical record snapshots, including logical attachment IDs
        lish % Serialized image header length
        li % Serialized padded pixel or compressed codestream length
        number_frames % Frame count derived from the fourth pixel dimension
        compression % Immutable JPEG2000 snapshot, or empty for NC storage
    end
    properties (Access = private)
        pixels = zeros(0, 0, 'uint8')
        headerValue
        store
        stats = struct('bits', 1, 'trailing', 8)
        compressed
    end
    methods
        function [tre, ok, status] = CSCRNA(obj, index, options) %#codegen
            %CSCRNA - Retrieve an editable copy of a direct CSCRNA attachment
            %   [TRE, OK, STATUS] = OBJ.CSCRNA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSCRNA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSCRNA and OK=false.
            %
            %   See also tre, treCount, nfx.CSCRNA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSCRNA(), index, options.ID);
        end

        function [tre, ok, status] = ICHIPB(obj, index, options) %#codegen
            %ICHIPB - Retrieve an editable copy of a direct ICHIPB attachment
            %   [TRE, OK, STATUS] = OBJ.ICHIPB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.ICHIPB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar ICHIPB and OK=false.
            %
            %   See also tre, treCount, nfx.ICHIPB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ICHIPB(), index, options.ID);
        end

        function [tre, ok, status] = MTIMSA(obj, index, options) %#codegen
            %MTIMSA - Retrieve an editable copy of a direct MTIMSA attachment
            %   [TRE, OK, STATUS] = OBJ.MTIMSA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.MTIMSA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar MTIMSA and OK=false.
            %
            %   See also tre, treCount, nfx.MTIMSA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MTIMSA(), index, options.ID);
        end

        function [tre, ok, status] = AIMIDB(obj, index, options) %#codegen
            %AIMIDB - Retrieve an editable copy of a direct AIMIDB attachment
            %   [TRE, OK, STATUS] = OBJ.AIMIDB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.AIMIDB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar AIMIDB and OK=false.
            %
            %   See also tre, treCount, nfx.AIMIDB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.AIMIDB(), index, options.ID);
        end

        function [tre, ok, status] = ACFTB(obj, index, options) %#codegen
            %ACFTB - Retrieve an editable copy of a direct ACFTB attachment
            %   [TRE, OK, STATUS] = OBJ.ACFTB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.ACFTB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar ACFTB and OK=false.
            %
            %   See also tre, treCount, nfx.ACFTB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ACFTB(), index, options.ID);
        end

        function [tre, ok, status] = HISTOA(obj, index, options) %#codegen
            %HISTOA - Retrieve an editable copy of a direct HISTOA attachment
            %   [TRE, OK, STATUS] = OBJ.HISTOA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.HISTOA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar HISTOA and OK=false.
            %
            %   See also tre, treCount, nfx.HISTOA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.HISTOA(), index, options.ID);
        end

        function [tre, ok, status] = BANDSB(obj, index, options) %#codegen
            %BANDSB - Retrieve an editable copy of a direct BANDSB attachment
            %   [TRE, OK, STATUS] = OBJ.BANDSB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.BANDSB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar BANDSB and OK=false.
            %
            %   See also tre, treCount, nfx.BANDSB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.BANDSB(), index, options.ID);
        end

        function [tre, ok, status] = SENSRB(obj, index, options) %#codegen
            %SENSRB - Retrieve an editable copy of a direct SENSRB attachment
            %   [TRE, OK, STATUS] = OBJ.SENSRB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.SENSRB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar SENSRB and OK=false.
            %
            %   See also tre, treCount, nfx.SENSRB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.SENSRB(), index, options.ID);
        end

        function [tre, ok, status] = RSMIDA(obj, index, options) %#codegen
            %RSMIDA - Retrieve an editable copy of a direct RSMIDA attachment
            %   [TRE, OK, STATUS] = OBJ.RSMIDA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMIDA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMIDA and OK=false.
            %
            %   See also tre, treCount, nfx.RSMIDA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMIDA(), index, options.ID);
        end

        function [tre, ok, status] = RSMPCA(obj, index, options) %#codegen
            %RSMPCA - Retrieve an editable copy of a direct RSMPCA attachment
            %   [TRE, OK, STATUS] = OBJ.RSMPCA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMPCA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMPCA and OK=false.
            %
            %   See also tre, treCount, nfx.RSMPCA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMPCA(), index, options.ID);
        end

        function [tre, ok, status] = RSMPIA(obj, index, options) %#codegen
            %RSMPIA - Retrieve an editable copy of a direct RSMPIA attachment
            %   [TRE, OK, STATUS] = OBJ.RSMPIA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMPIA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMPIA and OK=false.
            %
            %   See also tre, treCount, nfx.RSMPIA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMPIA(), index, options.ID);
        end

        function [tre, ok, status] = RSMGGA(obj, index, options) %#codegen
            %RSMGGA - Retrieve an editable copy of a direct RSMGGA attachment
            %   [TRE, OK, STATUS] = OBJ.RSMGGA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMGGA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMGGA and OK=false.
            %
            %   See also tre, treCount, nfx.RSMGGA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMGGA(), index, options.ID);
        end

        function [tre, ok, status] = RSMGIA(obj, index, options) %#codegen
            %RSMGIA - Retrieve an editable copy of a direct RSMGIA attachment
            %   [TRE, OK, STATUS] = OBJ.RSMGIA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMGIA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMGIA and OK=false.
            %
            %   See also tre, treCount, nfx.RSMGIA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMGIA(), index, options.ID);
        end

        function [tre, ok, status] = RSMAPB(obj, index, options) %#codegen
            %RSMAPB - Retrieve an editable copy of a direct RSMAPB attachment
            %   [TRE, OK, STATUS] = OBJ.RSMAPB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMAPB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMAPB and OK=false.
            %
            %   See also tre, treCount, nfx.RSMAPB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMAPB(), index, options.ID);
        end

        function [tre, ok, status] = RSMECB(obj, index, options) %#codegen
            %RSMECB - Retrieve an editable copy of a direct RSMECB attachment
            %   [TRE, OK, STATUS] = OBJ.RSMECB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMECB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMECB and OK=false.
            %
            %   See also tre, treCount, nfx.RSMECB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMECB(), index, options.ID);
        end

        function [tre, ok, status] = RSMDCB(obj, index, options) %#codegen
            %RSMDCB - Retrieve an editable copy of a direct RSMDCB attachment
            %   [TRE, OK, STATUS] = OBJ.RSMDCB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RSMDCB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RSMDCB and OK=false.
            %
            %   See also tre, treCount, nfx.RSMDCB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMDCB(), index, options.ID);
        end

        function [tre, ok, status] = CSRLSB(obj, index, options) %#codegen
            %CSRLSB - Retrieve an editable copy of a direct CSRLSB attachment
            %   [TRE, OK, STATUS] = OBJ.CSRLSB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSRLSB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSRLSB and OK=false.
            %
            %   See also tre, treCount, nfx.CSRLSB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSRLSB(), index, options.ID);
        end

        function [tre, ok, status] = CSWRPB(obj, index, options) %#codegen
            %CSWRPB - Retrieve an editable copy of a direct CSWRPB attachment
            %   [TRE, OK, STATUS] = OBJ.CSWRPB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSWRPB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSWRPB and OK=false.
            %
            %   See also tre, treCount, nfx.CSWRPB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSWRPB(), index, options.ID);
        end

        function [tre, ok, status] = FCRNSA(obj, index, options) %#codegen
            %FCRNSA - Retrieve an editable copy of a direct FCRNSA attachment
            %   [TRE, OK, STATUS] = OBJ.FCRNSA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FCRNSA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FCRNSA and OK=false.
            %
            %   See also tre, treCount, nfx.FCRNSA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FCRNSA(), index, options.ID);
        end

        function [tre, ok, status] = MATESA(obj, index, options) %#codegen
            %MATESA - Retrieve an editable copy of a direct MATESA attachment
            %   [TRE, OK, STATUS] = OBJ.MATESA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.MATESA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar MATESA and OK=false.
            %
            %   See also tre, treCount, nfx.MATESA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MATESA(), index, options.ID);
        end

        function [tre, ok, status] = ILLUMB(obj, index, options) %#codegen
            %ILLUMB - Retrieve an editable copy of a direct ILLUMB attachment
            %   [TRE, OK, STATUS] = OBJ.ILLUMB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.ILLUMB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar ILLUMB and OK=false.
            %
            %   See also tre, treCount, nfx.ILLUMB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ILLUMB(), index, options.ID);
        end

        function [tre, ok, status] = CSEXRB(obj, index, options) %#codegen
            %CSEXRB - Retrieve an editable copy of a direct CSEXRB attachment
            %   [TRE, OK, STATUS] = OBJ.CSEXRB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSEXRB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSEXRB and OK=false.
            %
            %   See also tre, treCount, nfx.CSEXRB.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSEXRB(), index, options.ID);
        end

        function [tre, ok, status] = FREESA(obj, index, options) %#codegen
            %FREESA - Retrieve an editable copy of a direct FREESA attachment
            %   [TRE, OK, STATUS] = OBJ.FREESA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FREESA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FREESA and OK=false.
            %
            %   See also tre, treCount, nfx.FREESA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FREESA(), index, options.ID);
        end

        function [tre, ok, status] = FSYNWA(obj, index, options) %#codegen
            %FSYNWA - Retrieve an editable copy of a direct FSYNWA attachment
            %   [TRE, OK, STATUS] = OBJ.FSYNWA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FSYNWA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FSYNWA and OK=false.
            %
            %   See also tre, treCount, nfx.FSYNWA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FSYNWA(), index, options.ID);
        end

        function [tre, ok, status] = FASYWA(obj, index, options) %#codegen
            %FASYWA - Retrieve an editable copy of a direct FASYWA attachment
            %   [TRE, OK, STATUS] = OBJ.FASYWA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FASYWA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FASYWA and OK=false.
            %
            %   See also tre, treCount, nfx.FASYWA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FASYWA(), index, options.ID);
        end

        function [tre, ok, status] = CONTXA(obj, index, options) %#codegen
            %CONTXA - Retrieve an editable copy of a direct CONTXA attachment
            %   [TRE, OK, STATUS] = OBJ.CONTXA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CONTXA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CONTXA and OK=false.
            %
            %   See also tre, treCount, nfx.CONTXA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CONTXA(), index, options.ID);
        end

        function [tre, ok, status] = J2KLRA(obj, index, options) %#codegen
            %J2KLRA - Retrieve an editable copy of a direct J2KLRA attachment
            %   [TRE, OK, STATUS] = OBJ.J2KLRA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.J2KLRA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar J2KLRA and OK=false.
            %
            %   See also tre, treCount, nfx.J2KLRA.deserialize
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.J2KLRA(), index, options.ID);
        end

        function [count, ok, status] = treCount(obj, tag) %#codegen
            %treCount - Count direct logical TRE attachments
            %   N = OBJ.treCount(TAG) counts matching logical attachments.
            %   N = OBJ.treCount() counts all types, including continuations
            %   as one attachment. Wrapper children are inspected separately.
            %
            %   See also tre, tre_ids, tre_records
            arguments
                obj (1,1) nfx.ImageSegment
                tag = ''
            end
            [count, ok, status] = countTRE(obj.tre_records, tag);
        end

        function [record, ok, status] = tre(obj, index, options) %#codegen
            %tre - Inspect one logical attachment through a scalar view
            %   [RECORD, OK, STATUS] = OBJ.tre(INDEX) selects all TRE types
            %   in insertion order. INDEX defaults to 1. OBJ.tre(ID=ID)
            %   selects a stable attachment identity. Failure returns a
            %   default scalar nfx.TRERecord and OK=false.
            %
            %   See also nfx.TRERecord, treCount
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [record, ok, status] = viewTRE( ...
                obj.tre_records, index, options.ID);
        end
    end
    methods
        function obj = ImageSegment(data, options) %#codegen
            %ImageSegment - Construct a segment without pixel conversion
            arguments
                data {mustBePixels} = zeros(0, 0, 'uint8')
                options.header (1,1) nfx.ImageHeader = nfx.ImageHeader()
            end
            obj.store = nfx.internal.TREStore();
            obj.compressed = nfx.JPEG2000.empty(1,0);
            obj.pixels = data;
            obj.stats = pixelStatistics(data);
            obj.headerValue = options.header;
        end
        function value = get.data(obj) %#codegen
            %get.data - Return the native pixel array
            value = obj.pixels;
        end
        function obj = set.data(obj, value) %#codegen
            %set.data - Replace pixels without an implicit type conversion
            mustBePixels(value);
            obj.pixels = value;
            obj.stats = pixelStatistics(value);
            obj.compressed = nfx.JPEG2000.empty(1,0);
        end
        function value = get.header(obj) %#codegen
            %get.header - Derive structural fields on access
            value = derive(obj.headerValue, obj.pixels, obj.stats);
            if ~isempty(obj.compressed), value = withJPEG2000(value,obj.compressed.comrat); end
        end
        function obj = set.header(obj, value) %#codegen
            %set.header - Replace editable image metadata
            arguments
                obj (1,1) nfx.ImageSegment
                value (1,1) nfx.ImageHeader
            end
            obj.headerValue = value;
        end
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return attachment identifiers in insertion order
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return attachment tags in insertion order
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Return physical snapshots for inspection
            snapshots = effectiveStore(obj);
            value = snapshots.records;
        end
        function [tre, ok, status] = RPC00B(obj, index, options) %#codegen
            %RPC00B - Decode one directly attached RPC00B snapshot
            %   TRE = RPC00B(OBJ) returns the first matching attachment, or
            %   a default scalar RPC00B when none can be decoded.
            %
            %   TRE = RPC00B(OBJ,INDEX) selects a one-based occurrence.
            %
            %   TRE = RPC00B(OBJ,ID=VALUE) selects a stable attachment ID.
            %
            %   [TRE,OK] = RPC00B(...) also reports retrieval success.
            %
            %   [TRE,OK,STATUS] = RPC00B(...) also returns diagnostics.
            arguments
                obj (1,1) nfx.ImageSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RPC00B(), index, options.ID);
        end
        function value = get.lish(obj) %#codegen
            %get.lish - Derive the subheader length with whole-record overflow
            snapshots = effectiveStore(obj);
            [inline, user, overflow, overflowUser] = snapshots.modelAreas(99985);
            h = obj.header;
            bands = size(obj.pixels, 3);
            value = 426 + 13*bands + 5*(bands > 9) + ...
                60*~strcmp(h.icords, ' ') + 80*h.nicom + numel(inline) + numel(user) + ...
                3*(~isempty(inline) || (~isempty(overflow) && ~overflowUser)) + ...
                3*(~isempty(user) || (~isempty(overflow) && overflowUser)) + ...
                4*~isempty(obj.compressed);
        end
        function value = get.li(obj) %#codegen
            %get.li - Derive padded image byte length
            h = obj.header;
            if ~isempty(obj.compressed), value = numel(obj.compressed.codestream); return; end
            value = h.nbpr * h.nbpc * h.nppbh * h.nppbv * ...
                size(obj.pixels, 3) * obj.number_frames * (h.nbpp / 8);
        end
        function value = get.number_frames(obj) %#codegen
            %get.number_frames - Derive the stored frame count
            value = size(obj.pixels,4);
        end
        function value = get.compression(obj)
            %get.compression - Return the immutable encoding snapshot
            value = obj.compressed;
        end
        function obj = compress(obj, encoder, options)
            %COMPRESS - Capture an experimental OpenJPEG lossless codestream
            %   OBJ = COMPRESS(OBJ,ENCODER) selects NPJE using the supplied
            %   OpenJPEG 2.5.4 Windows executable. Native pixels remain in DATA.
            %
            %   OBJ = COMPRESS(...,Profile=VALUE) selects NPJE or EPJE. Still,
            %   right-justified images with 1024-square blocks are supported.
            %   ABPP and NBPP both describe native codestream precision. Pixel
            %   edits restore NC storage; other encoding edits need validation.
            arguments
                obj (1,1) nfx.ImageSegment
                encoder {mustBeTextScalar, mustBeNonzeroLengthText}
                options.Profile {mustBeTextScalar, mustBeMember(options.Profile,{'NPJE','EPJE'})} = 'NPJE'
            end
            requireValid(validate(obj));
            h = obj.header;
            if obj.number_frames ~= 1 || ~strcmp(h.pjust,'R') || h.nppbh ~= 1024 || h.nppbv ~= 1024 || ...
                    endsWith(char(h.icat),'.M') || any(strcmp({obj.store.records.tag},'MTIMSA'))
                error('nfx:JPEG2000Scope','Compression requires still, right-justified imagery and 1024-square blocks.');
            end
            obj.compressed = nfx.JPEG2000(obj.pixels,encoder,Profile=options.Profile);
        end
        function obj = uncompress(obj)
            %UNCOMPRESS - Restore uncompressed storage from retained pixels
            %   OBJ = UNCOMPRESS(OBJ) drops the codestream and derived J2KLRA.
            %   DATA is unchanged and no decoder or executable is required.
            arguments
                obj (1,1) nfx.ImageSegment
            end
            obj.compressed = nfx.JPEG2000.empty(1,0);
        end
        function obj = plus(obj, tre) %#codegen
            %PLUS - Append a serialized TRE snapshot
            %   OBJ = OBJ + TRE validates TRE and appends its current state.
            %   Later edits to TRE leave OBJ unchanged. Use TRE_IDS to select
            %   an attachment for removal. Placement is checked on attachment.
            arguments
                obj (1,1) nfx.ImageSegment
                tre (1,1) nfx.TRE
            end
            obj.store = obj.store.attach(tre, 'image');
        end
        function obj = removeTRE(obj, id) %#codegen
            %removeTRE - Remove one attachment without reordering others
            %   OBJ = removeTRE(OBJ,ID) removes the attachment identified in
            %   OBJ.tre_ids. Removed IDs are not reused within this collection.
            arguments
                obj (1,1) nfx.ImageSegment
                id {mustBeMetadata(id, 1, 9007199254740991, 1), mustBeFinite}
            end
            obj.store = obj.store.remove(id);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the supported image and attached metadata
            %   REPORT = VALIDATE(OBJ) aggregates header and segment issues.
            %   Repeated RPC00B attachments can be edited and removed, but a
            %   writable image may contain at most one RPC00B model.
            arguments
                obj (1,1) nfx.ImageSegment
            end
            report = validateStructure(obj);
            snapshots = effectiveStore(obj);
            [extended,user,overflow,~] = snapshots.modelAreas(99985);
            item = struct('owner',1,'offset',0,'data',zeros(1,0,'uint8'));
            areas = repmat(item,1,3);
            areas(1).data = user; areas(2).data = extended; areas(2).offset = numel(user);
            areas(3).data = overflow; areas(3).offset = numel(user)+numel(extended);
            [contexts,child] = frameContexts(contextNodes(areas),obj);
            report = mergeReport(report,child,'');
            if child.valid, report = mergeReport(report,contextImageReport(contexts,obj),''); end
        end
    end

    methods (Access = ?nfx.File)
        function report = validateStructure(obj) %#codegen
            %validateStructure - Check storage before resolving metadata contexts
            report = newReport('NITF 2.1 image segment');
            report = mergeReport(report, validate(obj.header), 'header.');
            h = obj.header;
            report = addIssue(report,~isempty(obj.compressed) && ...
                (h.nppbh ~= 1024 || h.nppbv ~= 1024 || ~strcmp(h.pjust,'R') || obj.number_frames ~= 1 || ...
                endsWith(char(h.icat),'.M') || any(strcmp({obj.store.records.tag},'MTIMSA'))), ...
                'JPEG2000Snapshot','compression','Restore 1024-square blocks and right justification, or uncompress the image.', ...
                'BPJ2K01.20, Table 8-2 and Appendices D/E');
            reference = 'JBP 2025.1, 5.9 and 5.13; STDI-0002-1 App E, E.3.12';
            report = addIssue(report, isempty(obj.pixels), 'PixelsRequired', ...
                'data', 'Attach a nonempty pixel array.', reference);
            report = addIssue(report, sum(strcmp({obj.store.records.tag}, 'RPC00B')) > 1, ...
                'DuplicateRPC', 'tre_ids', 'Remove duplicate RPC00B attachments before writing.', reference);
            report = mergeReport(report,motionImageReport(obj.store.records,obj.header,obj.number_frames),'motion.');
            report = addIssue(report, obj.li > 9999999998 || obj.lish > 999998, ...
                'Length', 'li/lish', 'Image data or subheader exceeds its NITF length field.', reference);
        end
        function value = subheader(obj, inline, overflow, user, userOverflow) %#codegen
            %SUBHEADER - Serialize the preflight-selected metadata areas
            value = bytes(obj.header, inline, overflow, user, userOverflow);
        end
        function [inline, user, overflow, overflowUser] = areas(obj) %#codegen
            %AREAS - Partition whole records for the owning file
            snapshots = effectiveStore(obj);
            [inline, user, overflow, overflowUser] = snapshots.modelAreas(99985);
        end
        function value = explicitLevel(obj) %#codegen
            %explicitLevel - Return the caller's level or an automatic marker
            value = explicitLevel(obj.headerValue);
        end
        function obj = resolveLevel(obj, value) %#codegen
            %resolveLevel - Refresh the containing file's display default
            obj.headerValue = resolveLevel(obj.headerValue, value);
        end
        function count = writePixels(obj, fid) %#codegen
            %writePixels - Stream band-interleaved blocks in big-endian order
            h = obj.header;
            if ~isempty(obj.compressed)
                count = writeBytes(fid,obj.compressed.codestream); return
            end
            count = 0;
            for blockRow = 1:h.nbpc
                rows = (blockRow-1)*h.nppbv+1:min(blockRow*h.nppbv, h.nrows);
                for blockCol = 1:h.nbpr
                    cols = (blockCol-1)*h.nppbh+1:min(blockCol*h.nppbh, h.ncols);
                    for frame = 1:obj.number_frames
                        for band = 1:size(obj.pixels, 3)
                            % Transpose just this block for row-major storage.
                            block = zeros(h.nppbh, h.nppbv, 'like', obj.pixels);
                            block(1:numel(cols), 1:numel(rows)) = obj.pixels(rows, cols, band, frame).';
                            if isa(block, 'uint16')
                                buffer = zeros(2, numel(block), 'uint8');
                                buffer(1,:) = uint8(bitshift(block(:), -8));
                                buffer(2,:) = uint8(bitand(block(:), uint16(255)));
                                count = count + writeBytes(fid, buffer);
                            else
                                count = count + writeBytes(fid, block);
                            end
                        end
                    end
                end
            end
        end
    end
    methods (Access = private)
        function store = effectiveStore(obj)
            %effectiveStore - Append derived metadata without attachment IDs
            store = obj.store;
            if ~isempty(obj.compressed), store = store.withJPEG2000(obj.compressed.j2klra); end
        end
    end
end
