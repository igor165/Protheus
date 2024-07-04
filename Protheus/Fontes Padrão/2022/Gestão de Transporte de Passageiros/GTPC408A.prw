#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPC408A.CH"

/*/{Protheus.doc} GTPC408A
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPC408A()

FwExecView(STR0001,"VIEWDEF.GTPC408A",MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,10/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,) // "Divergência de Horários"

Return

/*/{Protheus.doc}  ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
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
Local bLoad		:= {|oModel|  G408ALoad(oModel)}
Local bLoadGrid	:= {|oGrid|  LoadGrid(oGrid)}

oModel := MPFormModel():New("GTPC408A",,,)

SetMdlStruct(oStruHor)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRIDHORARIO", 'HEADER', oStruHor,,,,,bLoadGrid)

oModel:SetDescription(STR0001) // "Divergências de Horários"
oModel:GetModel("HEADER"):SetDescription(STR0002)   // "Filtro" 
oModel:GetModel("GRIDHORARIO"):SetDescription(STR0003)  // "Escalas" 

oModel:GetModel("GRIDHORARIO"):SetOptional(.T.)

oModel:GetModel("GRIDHORARIO"):SetOnlyQuery(.T.)
oModel:GetModel("GRIDHORARIO"):SetOnlyView(.T.)
	
oModel:GetModel("GRIDHORARIO"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDHORARIO"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDHORARIO"):SetNoDeleteLine(.T.)

oModel:GetModel('GRIDHORARIO'):SetMaxLine(999999)

oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc}  ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPC408A")
//Local oStruCab	:= FwFormViewStruct():New()
Local oStruHor	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruHor)

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Divergência de Horários"

oView:AddGrid("VIEW_HORARIO", oStruHor, "GRIDHORARIO")

oView:CreateHorizontalBox('GRID1', 100)

oView:SetOwnerView('VIEW_HORARIO','GRID1')

oView:EnableTitleView("VIEW_HORARIO",STR0003)	// "Escalas"

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:GetViewObj("VIEW_HORARIO")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_HORARIO")[3]:SetFilter(.T.)

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc}  SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruHor)

	If ValType(oStruHor) == "O"

		oStruHor:AddTable("G52TMP",{},"CONSULTA")
	
		oStruHor:AddField(STR0004,STR0004,"G52_CODIGO","C",TamSx3('G52_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Escala"
		oStruHor:AddField(STR0005,STR0005,"G52_DESCRI","C",TamSx3('G52_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Descr. Escala"
		oStruHor:AddField(STR0006,STR0006,"G52_SERVIC","C",TamSx3('G52_SERVIC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Serviço"
		oStruHor:AddField(STR0007,STR0007,"G52_HRSDRD","C",TamSx3('G52_HRSDRD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Início"
		oStruHor:AddField(STR0008,STR0008,"G52_HRCHRD","C",TamSx3('G52_HRCHRD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Fim"
        oStruHor:AddField(STR0009,STR0009,"G52_SEGUND","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                        //"Seg"		
        oStruHor:AddField(STR0010,STR0010,"G52_TERCA","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                    //"Ter"
        oStruHor:AddField(STR0011,STR0011,"G52_QUARTA","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                //"Qua"
        oStruHor:AddField(STR0012,STR0012,"G52_QUINTA","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                //"Qui"
        oStruHor:AddField(STR0013,STR0013,"G52_SEXTA","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                    //"Sex"
        oStruHor:AddField(STR0014,STR0014,"G52_SABADO","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		                //"Sáb"
        oStruHor:AddField(STR0015,STR0015,"G52_DOMING","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	                    //"Dom"	
        oStruHor:AddField(STR0016,STR0016,"DIVERGENCI","C",60,0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.)                       //"Divergência"	
        
	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruHor)

	If ValType(oStruHor) == "O"

		oStruHor:AddField("G52_CODIGO","01",STR0004,STR0004,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //"Cód. Escala"
		oStruHor:AddField("G52_DESCRI","02",STR0005,STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //"Descr. Escala"
		oStruHor:AddField("G52_SERVIC","03",STR0006,STR0006,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //"Cód. Serviço"
		oStruHor:AddField("G52_HRSDRD","04",STR0007,STR0007,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //"Hora Início"
		oStruHor:AddField("G52_HRCHRD","05",STR0008,STR0008,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    //"Hora Fim"
		oStruHor:AddField("G52_SEGUND","06",STR0009,STR0009,{""},"CHECK","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Seg"
		oStruHor:AddField("G52_TERCA" ,"07",STR0010,STR0010,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Ter"
		oStruHor:AddField("G52_QUARTA","08",STR0011,STR0011,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Qua"
		oStruHor:AddField("G52_QUINTA","09",STR0012,STR0012,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Qui"
		oStruHor:AddField("G52_SEXTA" ,"10",STR0013,STR0013,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Sex"
		oStruHor:AddField("G52_SABADO","11",STR0014,STR0014,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Sáb"
		oStruHor:AddField("G52_DOMING","12",STR0015,STR0015,{""},"CHECK","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)    //"Dom"
		oStruHor:AddField("DIVERGENCI","13",STR0016,STR0016,{""},"GET","",NIL,"",.T.,NIL,NIL,{STR0017,;             //"1=Hora Inicial"
                                                                                              STR0018,;             //"2=Hora Final"
                                                                                              STR0019,;             //"3=Freq./Segunda"
                                                                                              STR0020,;             //"4=Freq./Terça"
                                                                                              STR0021,;             //"5=Freq./Quarta"
                                                                                              STR0022,;             //"6=Freq./Quinta"
                                                                                              STR0023,;             //"7=Freq./Sexta"
                                                                                              STR0024,;             //"8=Freq./Sábado"
                                                                                              STR0025},NIL,NIL,.F.) //"9=Freq./Domingo"},NIL,NIL,.F.) //""Divergência""

	Endif
	
Return

/*/{Protheus.doc} G408ALoad
(long_description)
@type  Static Function
@author flavio.martins
@since 22/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G408ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} LoadGrid
(long_description)
@type  Static Function
@author flavio.martins
@since 23/10/2020
@version 1.0
@param oGrid, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadGrid(oGrid)
Local cAliasTmp := GetNextAlias()
Local aRet		:= {}
Local cDataVig  := DtoS(dDataBase) 

BeginSql Alias cAliasTmp

    COLUMN G52_SEGUND   AS Logical
    COLUMN G52_TERCA    AS Logical
    COLUMN G52_QUARTA   AS Logical
    COLUMN G52_QUINTA   AS Logical
    COLUMN G52_SEXTA    AS Logical
    COLUMN G52_SABADO   AS Logical
    COLUMN G52_DOMING   AS Logical

    SELECT G52.G52_CODIGO,
        G52.G52_DESCRI,
        G52.G52_SERVIC,
        G52.G52_HRSDRD,
        G52.G52_SEGUND,
        G52.G52_TERCA,
        G52.G52_QUARTA,
        G52.G52_QUINTA,
        G52.G52_SEXTA,
        G52.G52_SABADO,
        G52.G52_DOMING,
        G52.G52_HRCHRD,
        GID.GID_HORCAB,
        GID.GID_SEG,
        GID.GID_TER,
        GID.GID_QUA,
        GID.GID_QUI,
        GID.GID_SEX,
        GID.GID_SAB,
        GID.GID_DOM,
        GID.GID_HORFIM,
        CASE
            WHEN GID.GID_HORCAB <> G52.G52_HRSDRD THEN  '1' //'Divergência no hora inicial'
            WHEN GID.GID_HORFIM <> G52.G52_HRCHRD THEN  '2' //'Divergência no hora final'
            WHEN GID.GID_SEG <> G52.G52_SEGUND THEN     '3' //'Divergência na freq./Segunda'
            WHEN GID.GID_TER <> G52.G52_TERCA THEN      '4' //'Divergência na freq./Terça'
            WHEN GID.GID_QUA <> G52.G52_QUARTA THEN     '5' //'Divergência na freq./Quarta'
            WHEN GID.GID_QUI <> G52.G52_QUINTA THEN     '6' //'Divergência na freq./Quinta'
            WHEN GID.GID_SEX <> G52.G52_SEXTA THEN      '7' //'Divergência na freq./Sexta'
            WHEN GID.GID_SAB <> G52.G52_SABADO THEN     '8' //'Divergência na freq./Sábado'
            WHEN GID.GID_DOM <> G52.G52_DOMING THEN     '9' //'Divergência na freq./Domingo'
            ELSE ''
        END DIVERGENCI
    FROM %Table:GY4% GY4
    INNER JOIN %Table:G52% G52 ON G52.G52_FILIAL = GY4.GY4_FILIAL
    AND G52.G52_CODIGO = GY4.GY4_ESCALA
    AND G52.%NotDel%
    INNER JOIN %Table:GID% GID ON GID.GID_FILIAL = G52.G52_FILIAL
    AND GID.GID_COD = G52.G52_SERVIC
    AND GID.GID_HIST = '2'
    AND GID.%NotDel%
    WHERE GY4.GY4_FILIAL = %xFilial:GY4%
    AND %Exp:cDataVig% BETWEEN GY4.GY4_DATADE AND GY4.GY4_DATATE
    AND GY4.%NotDel%
    AND (GID.GID_HORCAB <> G52.G52_HRSDRD
        OR GID.GID_SEG <> G52.G52_SEGUND
        OR GID.GID_TER <> G52.G52_TERCA
        OR GID.GID_QUA <> G52.G52_QUARTA
        OR GID.GID_QUI <> G52.G52_QUINTA
        OR GID.GID_SEX <> G52.G52_SEXTA
        OR GID.GID_SAB <> G52.G52_SABADO
        OR GID.GID_DOM <> G52.G52_DOMING
        OR GID.GID_HORFIM <> G52.G52_HRCHRD)
    GROUP BY G52.G52_CODIGO,
            G52.G52_DESCRI,
            G52.G52_SERVIC,
            G52.G52_HRSDRD,
            G52.G52_SEGUND,
            G52.G52_TERCA,
            G52.G52_QUARTA,
            G52.G52_QUINTA,
            G52.G52_SEXTA,
            G52.G52_SABADO,
            G52.G52_DOMING,
            G52.G52_HRCHRD,
            GID.GID_HORCAB,
            GID.GID_SEG,
            GID.GID_TER,
            GID.GID_QUA,
            GID.GID_QUI,
            GID.GID_SEX,
            GID.GID_SAB,
            GID.GID_DOM,
            GID.GID_HORFIM

EndSql

If (cAliasTmp)->(!Eof())
    aRet := FwLoadByAlias(oGrid, cAliasTmp) 
Endif

Return aRet
