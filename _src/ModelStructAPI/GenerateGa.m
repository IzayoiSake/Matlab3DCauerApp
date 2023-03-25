function [ModelStruct]=GenerateGa(ModelStruct)
% GenerateGa: Generate the Ga structure
% 1: PreTest
    try
        ModelStruct.Temp.State;
    catch ME
        ErrorMessage = "The current ModelStruct cannot generate Ga matrix" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    try
        if ModelStruct.Temp.State=="GenerateGa() Start"
        % get the number of the Node in the last layer
            NodeName = ModelStruct.NodeName;
            NodeNameEffective = ModelStruct.NodeNameEffective;
            NodeNameNoEffectIndex = ismember(NodeName,NodeNameEffective);
            NodeNameNoEffect = NodeName(~NodeNameNoEffectIndex);
        % initialize Ga
            Ga=zeros(length(NodeNameEffective),length(NodeNameNoEffect));
            GaName=zeros(size(Ga));
            GaName=string(GaName);
            GaName=strrep(GaName,'0',"");
        % generate the Ga
            % Find the node linkde with NodeNameNoEffect
            NodeLink=ModelStruct.NodeLink;
            GrName=ModelStruct.GrName;
            Gr=ModelStruct.Gr;
            for i = 1:length(NodeNameNoEffect)
                [~,Index] = ismember(NodeNameNoEffect(i),NodeName);
                NoEeffectNodeLink=NodeLink{Index};
                GrNeed=zeros(length(NoEeffectNodeLink),1);
                GrNeedName=zeros(length(NoEeffectNodeLink),1);
                GrNeedName=string(GrNeedName);
                GrNeedName=strrep(GrNeedName,'0',"");
                for j = 1:length(NoEeffectNodeLink)
                    % find the GrNeed
                    GrNameTemp=[NodeNameNoEffect(i),NoEeffectNodeLink(j)];
                    GrIndex=ismember(GrName,GrNameTemp,"rows");
                    % if no GrIndex is found
                    if sum(GrIndex)==0
                        GrNameTemp=[NoEeffectNodeLink(j),NodeNameNoEffect(i)];
                        GrIndex=ismember(GrName,GrNameTemp,"rows");
                    end
                    GrNeed(j)=Gr(GrIndex);
                    GrNeedName(j)="G("+GrNameTemp(1)+";"+GrNameTemp(2)+")";
                end
                % find the index of NoEeffectNodeLink in NodeNameEffective
                NoEeffectNodeLinkIndex=zeros(length(NoEeffectNodeLink),1);
                for j = 1:length(NoEeffectNodeLink)
                    NoEeffectNodeLinkIndex(j)=find(ismember(NodeNameEffective,NoEeffectNodeLink(j)));
                end
                % generate Ga
                Ga(NoEeffectNodeLinkIndex,i)=GrNeed;
                GaName(NoEeffectNodeLinkIndex,i)=GrNeedName;
            end
            ModelStruct.Ga=Ga;
            ModelStruct.GaName=GaName;
            ModelStruct.Temp.State="GenerateGa() End";
        end
    catch ME
        ErrorMessage = "Error at State:" + ModelStruct.Temp.State + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end