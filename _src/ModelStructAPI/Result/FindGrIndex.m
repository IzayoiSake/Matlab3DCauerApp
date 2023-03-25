function Index=FindGrIndex(GrNameNeed,GrName,ThisNodeName)
% Find the index of the GrNameNeed in the GrName

% check the inputs
    if~exist('ThisNodeName','var')||isempty(ThisNodeName)
        % Check if GrNameNeed is a matrix with 2 columns
        if size(GrNameNeed,2)~=2
            errorMessage="FindGrIndex() is error"+newline+...
                "Illegal function call method,Check the GrNameNeed";
            error(errorMessage);
        end
        Method=1;
    else
        % check if ThisNodeName is one element
        if size(ThisNodeName,1)~=1 || size(ThisNodeName,2)~=1
            errorMessage="FindGrIndex() is error"+newline+...
                "Illegal function call method,Check the ThisNodeName";
            error(errorMessage);
        end
        % check if GrNameNeed is a vector
        if ~isvector(GrNameNeed)
            errorMessage="FindGrIndex() is error"+newline+...
                "Illegal function call method,Check the GrNameNeed";
            error(errorMessage);
        end
        Method=2;
    end
% get the posible GrNameNeed
    switch Method
        case 1
            GrNamePosb1=[GrNameNeed(:,1),GrNameNeed(:,2)];
            GrNamePosb2=[GrNameNeed(:,2),GrNameNeed(:,1)];
            IsInGrNamePosb1=ismember(GrNamePosb1,GrName,'rows');
            IsInGrNamePosb2=ismember(GrNamePosb2,GrName,'rows');
            ActuialGrNameNeed=GrNamePosb1;
            ActuialGrNameNeed(IsInGrNamePosb2,:)=GrNamePosb2(IsInGrNamePosb2,:);
            % get the index of the GrNameNeed
            [IsIn,Index]=ismember(ActuialGrNameNeed,GrName,'rows');
            if ~all(IsIn)
                error('The GrName Needed is not all in the GrName');
            end
        case 2
            GrNameNeed=GrNameNeed(:);
            ThisNNArray=zeros(length(GrNameNeed),1);
            ThisNNArray=string(ThisNNArray);
            ThisNNArray(:)=ThisNodeName;
            GrNamePosb1=[ThisNNArray,GrNameNeed];
            GrNamePosb2=[GrNameNeed,ThisNNArray];
            IsInGrNamePosb1=ismember(GrNamePosb1,GrName,'rows');
            IsInGrNamePosb2=ismember(GrNamePosb2,GrName,'rows');
            ActuialGrNameNeed=GrNamePosb1;
            ActuialGrNameNeed(IsInGrNamePosb2,:)=GrNamePosb2(IsInGrNamePosb2,:);
            % get the index of the GrNameNeed
            [IsIn,Index]=ismember(ActuialGrNameNeed,GrName,'rows');
            if ~all(IsIn)
                error('The GrName Needed is not all in the GrName');
            end
    end
end