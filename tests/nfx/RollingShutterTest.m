classdef RollingShutterTest < NfxTest
    methods (Test)
        function literalMinimumAndSignedTimes(t)
            value = nfx.CSRLSB(rs_dt_1=0,rs_dt_2=1.25,rs_dt_3=-2.5,rs_dt_4=9999999999);
            expected = uint8('0101+.0000000000+1.250000000-2.500000000+9999999999.');
            t.verifyEqual(value.payload(),expected); t.verifyEqual(value.cel,52);
            t.verifyEqual(value.bytes(),[uint8('CSRLSB00052') expected]);
            t.verifyEqual(value.n_rs_row_blocks,1); t.verifyEqual(value.m_rs_column_blocks,1);
        end
        function rowColumnAndCornerOrderIsExplicit(t)
            value = nfx.CSRLSB(rs_dt_1=[1 2 3;4 5 6],rs_dt_2=[11 12 13;14 15 16], ...
                rs_dt_3=[21 22 23;24 25 26],rs_dt_4=[31 32 33;34 35 36]);
            payload = value.payload(); t.verifyEqual(char(payload(1:4)),'0203');
            decoded = str2double(cellstr(reshape(char(payload(5:end)),12,[]).')).';
            t.verifyEqual(decoded,[1 11 21 31 2 12 22 32 3 13 23 33 4 14 24 34 5 15 25 35 6 16 26 36]);
        end
        function precisionAndSignBoundaries(t)
            value = nfx.CSRLSB(rs_dt_1=1e-10,rs_dt_2=-1e-10,rs_dt_3=-9999999999,rs_dt_4=9.9999999996);
            payload = value.payload();
            t.verifyEqual(char(payload(5:16)),'+.0000000001');
            t.verifyEqual(char(payload(17:28)),'-.0000000001');
            t.verifyEqual(char(payload(29:40)),'-9999999999.');
            t.verifyEqual(char(payload(41:52)),'+10.00000000');
            value.rs_dt_1 = 1e-12; t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.payload(),'nfx:Invalid');
        end
        function missingAndMismatchedCornerArraysFail(t)
            t.verifyFalse(nfx.CSRLSB().validate().valid);
            value = nfx.CSRLSB(rs_dt_1=zeros(2,3),rs_dt_2=zeros(2,3),rs_dt_3=zeros(2,3),rs_dt_4=zeros(3,2));
            t.verifyFalse(value.validate().valid); value.rs_dt_4 = zeros(2,3);
            t.verifyTrue(value.validate().valid); value.rs_dt_2(1,2) = NaN; t.verifyFalse(value.validate().valid);
        end
        function dimensionsAndTypesAreStrict(t)
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=zeros(100,1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=zeros(1,100)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=zeros(1,1,2)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=single(0)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=sparse(1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=Inf),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=1i),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSRLSB(rs_dt_1=10000000000),'nfx:GLASMatrix');
        end
        function payloadLimitAppliesToTheProductOfBlockCounts(t)
            % 2080 is the largest legal block product with both axes <= 99.
            data = zeros(32,65); value = nfx.CSRLSB(rs_dt_1=data,rs_dt_2=data,rs_dt_3=data,rs_dt_4=data);
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.cel,99844);
            data = zeros(33,64); value = nfx.CSRLSB(rs_dt_1=data,rs_dt_2=data,rs_dt_3=data,rs_dt_4=data);
            report = value.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'TRELength')));
        end
    end
end
