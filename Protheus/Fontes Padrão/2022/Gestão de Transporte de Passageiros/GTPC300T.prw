#Include "GTPC300T.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GTPC300T
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300T()

FwExecView(STR0001,"VIEWDEF.GTPC300T",MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,10/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,)  //"Divergências de viagens x horários"

Return

/*/{Protheus.doc}  ModelDef
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruHor	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel|  LoadGC300(oModel)}
Local bGridLoad	:= {|oGrid|  GridLoad(oGrid)}

oModel := MPFormModel():New("GTPC300T",,,)

SetMdlStru(oStruHor)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRIDVIAGENS", 'HEADER', oStruHor,,,,,bGridLoad)

oModel:SetDescription(STR0001)  //"Divergências de viagens x horários"
oModel:GetModel("HEADER"):SetDescription(STR0002 )    //"Filtro"
oModel:GetModel("GRIDVIAGENS"):SetDescription(STR0003)  //"Viagens"

oModel:GetModel("GRIDVIAGENS"):SetOptional(.T.)

oModel:GetModel("GRIDVIAGENS"):SetOnlyQuery(.T.)
oModel:GetModel("GRIDVIAGENS"):SetOnlyView(.T.)
	
oModel:GetModel("GRIDVIAGENS"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDVIAGENS"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDVIAGENS"):SetNoDeleteLine(.T.)

oModel:GetModel('GRIDVIAGENS'):SetMaxLine(999999)

oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc}  ViewDef
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPC300T")
Local oStruHor	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruHor)

oView:SetModel(oModel)

oView:SetDescription(STR0001)  //"Divergências de viagens x horários"

oView:AddGrid("VIEW_VIAGENS", oStruHor, "GRIDVIAGENS")

oView:CreateHorizontalBox('GRID1', 100)

oView:SetOwnerView('VIEW_VIAGENS','GRID1')

oView:EnableTitleView("VIEW_VIAGENS", STR0003)	 //"Viagens"

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:GetViewObj("VIEW_VIAGENS")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_VIAGENS")[3]:SetFilter(.T.)

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc}  SetMdlStru
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruHor)

	If ValType(oStruHor) == "O"

		oStruHor:AddTable("GYNTMP",{},STR0004) //"CONSULTA"
	
		oStruHor:AddField(STR0003,STR0003,"GYN_CODIGO","C" ,TamSx3('GYN_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	 //STR0003 //"Viagens"
		oStruHor:AddField(STR0005,STR0005,"GYN_TIPO"  ,"C" ,TamSx3('GYN_TIPO')[1]  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	 //STR0005 //"Tipo Viagem"
		oStruHor:AddField(STR0006,STR0006,"GYN_LINCOD","C" ,TamSx3('GYN_LINCOD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	 //STR0006 //"Cód.Linha"
		oStruHor:AddField(STR0007,STR0007,"GYN_LINSEN","C" ,TamSx3('GYN_LINSEN')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	 //STR0007 //"Sentido"
		oStruHor:AddField(STR0008,STR0008,"GYN_CODGID","C" ,TamSx3('GYN_CODGID')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	 //STR0008 //"Cod.Horário"
        oStruHor:AddField(STR0009,STR0009,"GYN_LOCORI","C" ,TamSx3('GYN_LOCORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                        	 //STR0009 //"Local Origem"
        oStruHor:AddField(STR0010,STR0010,"GYN_LOCDES","C" ,TamSx3('GYN_LOCDES')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                	                //STR0010 //"Local Destin"
        oStruHor:AddField(STR0011,STR0011,"GYN_DTINI" ,"D" ,TamSx3('GYN_DTINI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                     //STR0011 //"Data Início"
        oStruHor:AddField(STR0012,STR0012,"GYN_HRINI" ,"C" ,TamSx3('GYN_HRINI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                 //STR0012 //"Hora Início"
        oStruHor:AddField(STR0013,STR0013,"GYN_DTFIM" ,"D" ,TamSx3('GYN_DTFIM')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	                     //STR0013 //"Data Fim"
        oStruHor:AddField(STR0014,STR0014,"GYN_HRFIM" ,"C" ,TamSx3('GYN_HRFIM')[1] ,0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.)                        //STR0014 //"Hora Fim"
        oStruHor:AddField(STR0015,STR0015,"DIVERGENCI","C",60,0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.)   //STR0015 //'Divergência'
	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruHor)

	If ValType(oStruHor) == "O"

		oStruHor:AddField("GYN_CODIGO","01",STR0003,STR0003,{""},"GET","@!"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	     //STR0003 //"Viagens"
		oStruHor:AddField("GYN_TIPO"  ,"02",STR0005,STR0005,{""},"GET","@9"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //STR0005 //"Tipo Viagem"
		oStruHor:AddField("GYN_LINCOD","03",STR0006,STR0006,{""},"GET","@!"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	     //STR0006 //"Cód.Linha"
		oStruHor:AddField("GYN_LINSEN","04",STR0007,STR0007,{""},"GET","@9"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	     //STR0007 //"Sentido"
		oStruHor:AddField("GYN_CODGID","05",STR0008,STR0008,{""},"GET","@!"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	     //STR0008 //"Cod.Horário"
		oStruHor:AddField("GYN_LOCORI","06",STR0009,STR0009,{""},"GET","@!"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	     //STR0009 //"Local Origem"
		oStruHor:AddField("GYN_LOCDES","08",STR0010,STR0010,{""},"GET","@!"      ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)         //STR0010 //"Local Destin"
		oStruHor:AddField("GYN_DTINI" ,"10",STR0011,STR0011,{""},"GET","99/99/9999"        ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     //STR0011 //"Data Início"
		oStruHor:AddField("GYN_HRINI" ,"11",STR0012,STR0012,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     //STR0012 //"Hora Início"
		oStruHor:AddField("GYN_DTFIM" ,"12",STR0013,STR0013,{""},"GET","99/99/9999"        ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     //STR0013 //"Data Fim"
		oStruHor:AddField("GYN_HRFIM" ,"13",STR0014,STR0014,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0014 //"Hora Fim"
        oStruHor:AddField("DIVERGENCI","13",STR0015,STR0015,{""},"GET","",NIL,"",.T.,NIL,NIL,{STR0017,STR0016},NIL,NIL,.F.)  //STR0015 //'2=Hora Final' //'1=Hora Inicial' //'Divergência'
        
	Endif
	
Return

/*/{Protheus.doc} LoadGC300
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadGC300(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GridLoad
(long_description)
@type  Static Function
@author eduardo ferreira
@since 17/12/2020
@version 1.0
@param oGrid, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GridLoad(oGrid)
Local cAliasTmp := GetNextAlias()
Local aRet		:= {}
Local cDataVig  := DtoS(dDataBase) 

BeginSql Alias cAliasTmp

    Column GYN_DTINI as Date
    Column GYN_DTFIM as Date

    SELECT
        GYN_CODIGO,
        GYN_TIPO  ,
        GYN_LINCOD,
        GYN_LINSEN,
        GYN_CODGID,
        GYN_LOCORI,
        GYN_LOCDES,
        GYN_DTINI ,
        GYN_HRINI ,
        GYN_DTFIM ,
        GYN_HRFIM,
        GIE_HORCAB,
        GIE_HORDES,
        CASE
            WHEN GID.GID_HORCAB <> GYN.GYN_HRINI THEN  '1' //'Divergência no hora inicial'
            WHEN GID.GID_HORFIM <> GYN.GYN_HRFIM THEN '2' //'Divergência no hora final'
            WHEN GIE.GIE_SEQ IS NULL THEN     '3' //'Trechos não encontrato nos horarios
            ELSE ''
        END DIVERGENCI
    FROM 
    	%Table:GYN% GYN
    	INNER JOIN %Table:G55% G55 ON G55.G55_FILIAL = GYN.GYN_FILIAL
    	AND G55.G55_CODVIA = GYN.GYN_CODIGO
    	AND G55.%NotDel%
    	INNER JOIN %Table:GID% GID ON GID.GID_FILIAL = G55_FILIAL
    	AND GID.GID_COD = GYN.GYN_CODGID
    	AND GID.GID_HIST = '2'
    	AND GID.%NotDel%
    	LEFT JOIN %Table:GIE% GIE ON GIE.GIE_CODGID = GID.GID_COD
    	AND GIE.GIE_SEQ = G55.G55_SEQ
    	AND GIE.%NotDel%
    WHERE
    	GYN.GYN_FILIAL = %xFilial:GYN%
    	AND %Exp:cDataVig% BETWEEN GYN.GYN_DTINI AND GYN.GYN_DTFIM
    	AND GYN.%NotDel%
    	AND GYN.GYN_CANCEL = '1'
        AND GYN_FINAL = '2'
    	AND (GYN.GYN_HRINI <> GIE.GIE_HORCAB OR
    		GIE.GIE_SEQ IS NULL)

EndSql

If (cAliasTmp)->(!Eof())
    aRet := FwLoadByAlias(oGrid, cAliasTmp) 
Endif

Return aRet
