%% 获取所有电导名字的列向量
function [ModelStruct]=GenGrName(ModelStruct)
    if ~exist('ModelStruct.GrName','var')
        ModelStruct.GrName=string([]);
    end
    % 遍历所有节点
    for i=1:length(ModelStruct.NodeName)
        % 获取当前节点的名字
        NodeName1=ModelStruct.NodeName(i);
        NodeName1=string(NodeName1);
        % 获取与NodeName1相连的所有节点
        NodeNameLinked=ModelStruct.NodeLink{i};
        NodeNameLinked=string(NodeNameLinked);
        % 遍历与NodeName1相连的所有节点
        for j=1:length(NodeNameLinked)
            % 获取当前节点的名字
            NodeName2=NodeNameLinked(j);
            NodeName2=string(NodeName2);
            % 生成电导名字
            GrNameTemp1=[NodeName1,NodeName2];
            GrNameTemp2=[NodeName2,NodeName1];
            % 如果电导名字不存在,则添加
            if isempty(ModelStruct.GrName)
                ModelStruct.GrName=GrNameTemp1;
            elseif ~ismember(GrNameTemp1,ModelStruct.GrName,"rows") && ~ismember(GrNameTemp2,ModelStruct.GrName,"rows")
                ModelStruct.GrName=[ModelStruct.GrName;GrNameTemp1];
            end
        end
    end
end