classdef (Abstract, Hidden) MetadataWrapper < nfx.TRE
    %MetadataWrapper - Shared snapshot composition for concrete wrapper TREs
    %   Concrete wrappers use + to capture validated TRE values and
    %   removeTRE to remove an attachment. Ordering is retained exactly;
    %   later metadata therefore retains its standard-defined precedence.
    %
    %   See also FSYNWA, FASYWA, CONTXA

    properties (Dependent, SetAccess = private)
        tre_ids
        tre_tags
        tre_records
    end
    properties (Access = private)
        store
    end
    methods
        function obj = MetadataWrapper() %#codegen
            %MetadataWrapper - Initialize the shared snapshot store
            obj.store = nfx.internal.TREStore();
        end
        function [tre, ok, status] = getCONTXA(obj, index, options) %#codegen
            %getCONTXA - Retrieve a nested wrapper without constructor ambiguity
            %   [TRE, OK, STATUS] = OBJ.getCONTXA(INDEX) selects a logical
            %   occurrence; INDEX defaults to 1. ID=ID selects its identity.
            %   Failure returns a default scalar CONTXA and OK=false.
            %
            %   See also nfx.CONTXA.deserialize, treCount
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CONTXA(), index, options.ID);
        end

        function [tre, ok, status] = getFSYNWA(obj, index, options) %#codegen
            %getFSYNWA - Retrieve a nested wrapper without constructor ambiguity
            %   [TRE, OK, STATUS] = OBJ.getFSYNWA(INDEX) selects a logical
            %   occurrence; INDEX defaults to 1. ID=ID selects its identity.
            %   Failure returns a default scalar FSYNWA and OK=false.
            %
            %   See also nfx.FSYNWA.deserialize, treCount
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FSYNWA(), index, options.ID);
        end

        function [tre, ok, status] = getFASYWA(obj, index, options) %#codegen
            %getFASYWA - Retrieve a nested wrapper without constructor ambiguity
            %   [TRE, OK, STATUS] = OBJ.getFASYWA(INDEX) selects a logical
            %   occurrence; INDEX defaults to 1. ID=ID selects its identity.
            %   Failure returns a default scalar FASYWA and OK=false.
            %
            %   See also nfx.FASYWA.deserialize, treCount
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FASYWA(), index, options.ID);
        end

    end
    methods
        function [tre, ok, status] = ACFTB(obj, index, options) %#codegen
            %ACFTB - Retrieve an editable copy of a direct ACFTB attachment
            %   [TRE, OK, STATUS] = OBJ.ACFTB(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.ACFTB(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar ACFTB and OK=false.
            %
            %   See also tre, treCount, nfx.ACFTB.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ACFTB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.AIMIDB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.BANDSB(), index, options.ID);
        end

        function [tre, ok, status] = CAMSDA(obj, index, options) %#codegen
            %CAMSDA - Retrieve an editable copy of a direct CAMSDA attachment
            %   [TRE, OK, STATUS] = OBJ.CAMSDA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CAMSDA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CAMSDA and OK=false.
            %
            %   See also tre, treCount, nfx.CAMSDA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CAMSDA(), index, options.ID);
        end

        function [tre, ok, status] = CSCRNA(obj, index, options) %#codegen
            %CSCRNA - Retrieve an editable copy of a direct CSCRNA attachment
            %   [TRE, OK, STATUS] = OBJ.CSCRNA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSCRNA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSCRNA and OK=false.
            %
            %   See also tre, treCount, nfx.CSCRNA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSCRNA(), index, options.ID);
        end

        function [tre, ok, status] = CSDIDA(obj, index, options) %#codegen
            %CSDIDA - Retrieve an editable copy of a direct CSDIDA attachment
            %   [TRE, OK, STATUS] = OBJ.CSDIDA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.CSDIDA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar CSDIDA and OK=false.
            %
            %   See also tre, treCount, nfx.CSDIDA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSDIDA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.CSEXRB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FCRNSA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FREESA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.HISTOA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ICHIPB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.ILLUMB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MATESA(), index, options.ID);
        end

        function [tre, ok, status] = MICIDA(obj, index, options) %#codegen
            %MICIDA - Retrieve an editable copy of a direct MICIDA attachment
            %   [TRE, OK, STATUS] = OBJ.MICIDA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.MICIDA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar MICIDA and OK=false.
            %
            %   See also tre, treCount, nfx.MICIDA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MICIDA(), index, options.ID);
        end

        function [tre, ok, status] = MIMCSA(obj, index, options) %#codegen
            %MIMCSA - Retrieve an editable copy of a direct MIMCSA attachment
            %   [TRE, OK, STATUS] = OBJ.MIMCSA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.MIMCSA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar MIMCSA and OK=false.
            %
            %   See also tre, treCount, nfx.MIMCSA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MIMCSA(), index, options.ID);
        end

        function [tre, ok, status] = MTIMFA(obj, index, options) %#codegen
            %MTIMFA - Retrieve an editable copy of a direct MTIMFA attachment
            %   [TRE, OK, STATUS] = OBJ.MTIMFA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.MTIMFA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar MTIMFA and OK=false.
            %
            %   See also tre, treCount, nfx.MTIMFA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MTIMFA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.MTIMSA(), index, options.ID);
        end

        function [tre, ok, status] = RPC00B(obj, index, options) %#codegen
            %RPC00B - Retrieve an editable copy of a direct RPC00B attachment
            %   [TRE, OK, STATUS] = OBJ.RPC00B(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.RPC00B(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar RPC00B and OK=false.
            %
            %   See also tre, treCount, nfx.RPC00B.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RPC00B(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMAPB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMDCB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMECB(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMGIA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.RSMPIA(), index, options.ID);
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.SENSRB(), index, options.ID);
        end

        function [tre, ok, status] = TMINTA(obj, index, options) %#codegen
            %TMINTA - Retrieve an editable copy of a direct TMINTA attachment
            %   [TRE, OK, STATUS] = OBJ.TMINTA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.TMINTA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar TMINTA and OK=false.
            %
            %   See also tre, treCount, nfx.TMINTA.deserialize
            arguments
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.TMINTA(), index, options.ID);
        end

        function [count, ok, status] = treCount(obj, tag) %#codegen
            %treCount - Count direct logical TRE attachments
            %   N = OBJ.treCount(TAG) counts matching logical attachments.
            %   N = OBJ.treCount() counts all types, including continuations
            %   as one attachment. Wrapper children are inspected separately.
            %
            %   See also tre, tre_ids, tre_records
            arguments
                obj (1,1) nfx.MetadataWrapper
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
                obj (1,1) nfx.MetadataWrapper
                index = 1
                options.ID = []
            end
            [record, ok, status] = viewTRE( ...
                obj.tre_records, index, options.ID);
        end
    end
    methods
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return logical attachment identities
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return attached tags in insertion order
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Inspect encoded value snapshots
            value = obj.store.records;
        end
        function obj = plus(obj,tre) %#codegen
            %PLUS - Snapshot a concrete TRE in this wrapper
            arguments
                obj (1,1) nfx.MetadataWrapper
                tre (1,1) nfx.TRE
            end
            obj.store = obj.store.attach(tre,'wrapped');
        end
        function obj = removeTRE(obj,id) %#codegen
            %REMOVETRE - Remove a logical attachment without reordering others
            arguments
                obj (1,1) nfx.MetadataWrapper
                id {mustBeMetadata(id,1,9007199254740991,1),mustBeFinite}
            end
            obj.store = obj.store.remove(id);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize wrapper fields followed by complete TREs
            requireValid(validate(obj));
            value = [wrapperPrefix(obj) wrappedBytes(obj)];
        end
        function value = allowsPlacement(obj,owner) %#codegen
            %ALLOWSPLACEMENT - Check concrete child scopes and context hierarchy
            arguments
                obj (1,1) nfx.MetadataWrapper
                owner {mustBeMember(owner,{'file','image'})}
            end
            value = wrapperLegal(obj.cetag,[wrapperPrefix(obj) wrappedBytes(obj)],owner);
        end
    end
    methods (Access = protected)
        function obj = restoreSnapshots(obj, records) %#codegen
            %restoreSnapshots - Store only decoded and checked child records
            obj.store = nfx.internal.TREStore.fromSnapshots(records);
        end
        function value = wrappedBytes(obj) %#codegen
            %wrappedBytes - Encode children without padding or an extra count
            [value,~] = obj.store.areas(Inf);
        end
        function report = wrapperReport(obj,report,prefixLength) %#codegen
            %wrapperReport - Check containment length and supported semantics
            records = obj.store.records;
            report = mergeReport(report, unknownTREReport(records), '');
            total = prefixLength;
            largest = 0;
            for k = 1:numel(records)
                total = total+11+numel(records(k).payload);
                largest = max(largest,numel(records(k).payload));
            end
            reference = 'STDI-0002-1 Appendix AF, AF5.9-AF5.13';
            report = addIssue(report,isempty(records),'WrappedTRERequired','tre_ids', ...
                'A wrapper must contain at least one complete TRE.',reference);
            report = addIssue(report,total > 99985,'TRELength','tre_ids', ...
                'Wrapper fields and complete child envelopes must fit 99985 bytes.',reference);
            maximumChild = 99956;
            if strcmp(obj.cetag,'FASYWA'), maximumChild = 99926; end
            report = addIssue(report,largest > maximumChild,'WrappedTRELength','tre_ids', ...
                'A child payload exceeds the wrapper table field limit.',reference);
            if report.valid
                legal = allowsPlacement(obj,'file') || allowsPlacement(obj,'image');
                report = addIssue(report,~legal,'WrapperContext','tre_ids', ...
                    'The wrapped records have no supported legal owner/context combination.',reference);
            end
        end
    end
    methods (Abstract, Access = protected)
        value = wrapperPrefix(obj)
    end
end
