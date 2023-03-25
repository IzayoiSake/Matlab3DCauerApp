function [Pr] = GetPr(ModelStruct)
% GetPr - Get the Pr of nodes
    
% 1: get the Nomenclature of NodeName
    Nomenclature = ModelStruct.Temp.Nomenclature;
% 2: read Pr Data
    SteadyPowerData = ModelStruct.Temp.SteadyPowerData;
    SteadyTemptPath = ModelStruct.Temp.SteadyTemptPath;
    Header = SteadyPowerData(1,2:end);
    NodeHeader = SteadyPowerData(2:end,1);
    NodeHeader = ConvertNodeName(NodeHeader,Nomenclature);
    PrData = SteadyPowerData(2:end,2:end);
% 3: get the Pr one by one of SteadyTemptPath file name
    FileName = zeros(numel(SteadyTemptPath),1);
    FileName = string(FileName);
    FileName = strrep(FileName,'0',"");
    for i = 1:numel(SteadyTemptPath)
        [~,FileName(i),~] = fileparts(SteadyTemptPath(i));
    end
    Pr = zeros(numel(ModelStruct.NodeNameEffective),numel(SteadyTemptPath));
    for i = 1:numel(SteadyTemptPath)
        for j = 1:numel(ModelStruct.NodeNameEffective)
            IndexNode = find(strcmp(NodeHeader,ModelStruct.NodeNameEffective(j)));
            IndexHeader = find(strcmp(Header,FileName(i)));
            if ~isempty(IndexNode) && ~isempty(IndexHeader)
                Pr(j,i) = PrData(IndexNode,IndexHeader);
            else
                Pr(j,i) = 0;
            end
        end
    end
    PrOneCol = zeros(numel(Pr),1);
    for i = 1:numel(Pr)
        PrOneCol(i) = Pr(i);
    end
    Pr = PrOneCol;
end


