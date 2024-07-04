#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA026B.CH'

Static cGA026BGrid	:= ""

/*/{Protheus.doc} GTPA026B
    Programa em MVC da conferência de Vendas POS
    @type  Function
    @author Flavio Martins
    @since 02/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA026B()
    
	FwMsgRun(, {|| FwExecView("","VIEWDEF.GTPA026B",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //"Buscando registros..."
	
Return()

/*/{Protheus.doc} ModelDef
    Model - Conferência de Vendas POS
    @type  Static Function
    @author Flavio Martins
    @since 02/06/2020
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormStruct( 1, "G6X",,.F. ) // Ficha de Remessa 
Local oStruPos  := FwFormModelStruct():New()

oModel := MPFormModel():New("GTPA026B",,,)

G026BStruct('M',oStruCab, oStruPos)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,/*bLoad*/)
oModel:AddGrid('GRIDPOS', 'HEADER', oStruPos,,,,,/*bLoad*/)
//oModel:AddFields("TOTAIS", "GRIDPOS", oStruTot, /*bPre*/ , /*bPost*/,  {|oMdl| SetLoadModel(oMdl)} )

oModel:AddCalc('CALC_TOTAL', 'HEADER', 'GRIDPOS', 'GQM_VALOR', 'TOTAL_DEBITO', 'SUM', { || oModel:GetModel("GRIDPOS"):GetValue('GQL_TPVEND') == '1'},,"Total Débito")	// "Valor Total"
oModel:AddCalc('CALC_TOTAL', 'HEADER', 'GRIDPOS', 'GQM_VALOR', 'TOTAL_CREDITO', 'SUM', { || oModel:GetModel("GRIDPOS"):GetValue('GQL_TPVEND') == '2'},,"Total Crédito")	// "Valor Total"

oModel:GetModel("HEADER"):SetOnlyView(.T.)

oModel:SetPrimaryKey({})

oModel:SetDescription(STR0002) //"Conferência de Vendas POS"

oModel:GetModel('HEADER'):SetDescription(STR0003) //"Ficha de Remessa"
oModel:GetModel('GRIDPOS'):SetDescription(STR0004) //"Vendas POS"

oModel:SetCommit({|oModel| G026BCommit(oModel)})
oModel:SetVldActivate({|oModel| G026BVldAct(oModel)})
oModel:SetActivate( { |oModel|G026BActiv(oModel) } )

oModel:GetModel('GRIDPOS'):SetNoDeleteLine(.T.)

Return(oModel)

/*/{Protheus.doc} ViewDef
    View - Conferência de Vendas POS
    @type  Static Function
    @author Flavio Martins
    @since 02/06/2020
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel    := FwLoadModel("GTPA026B")
Local oStruCab	:= FwFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruPos	:= FwFormViewStruct():New()
Local oStruCalc := FwCalcStruct( oModel:GetModel('CALC_TOTAL'))

// Cria o objeto de View
oView := FwFormView():New()

//oView:SetDescription("Conferência de Vendas POS") //"Conferência de Vendas POS"

G026BStruct('V', oStruCab, oStruPos)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_HEADER", oStruCab, "HEADER")
oView:AddGrid("VIEW_DETAIL", oStruPos, "GRIDPOS")
oView:AddField('VIEW_TOTAL', oStruCalc, "CALC_TOTAL")

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("DETAIL", 70 )
oView:CreateHorizontalBox("TOTAL", 10 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
oView:SetOwnerView("VIEW_TOTAL", "TOTAL")

oView:AddUserButton(STR0005, "", {|oModel| ConfereTudo(oModel)} )   // "Conferir Todos"

//oView:GetViewObj("VIEW_DETAIL")[3]:SetGotFocus({|| cGA117BGrid := "GRID" })

oView:EnableTitleView('VIEW_HEADER', STR0007) // "Dados da Ficha de Remessa"
oView:EnableTitleView('VIEW_DETAIL', STR0004) // "Vendas POS"

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.T.)

Return(oView)

/*/{Protheus.doc} G026BStruct(ctipo, oStruCab, oStruPos)
    Configura as estruturas do model e view
    @type  Static Function
    @author Flavio Martins
    @since 02/06/2020
    @version 1
    @param oStruCab, oStruPos
    @return
    @see (links_or_references)
/*/
Static Function G026BStruct(cTipo, oStruCab, oStruPos)
Local bTrig     := {|oMdl,cField,uVal| G026BTrigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue| G026BdValid(oMdl,cField,uNewValue,uOldValue)}
Local aNewFlds  := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON', 'GQM_VLACER'}
Local lNewFlds  := GTPxVldDic('GQM', aNewFlds, .F., .T.)

	If cTipo == 'M' 
    
        If ValType(oStruPos) == "O"
	
            oStruPos:AddField(STR0008,STR0008,"GQM_CODIGO","C",TamSx3('GQM_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // "Código"						
            oStruPos:AddField(STR0009,STR0009,"GQL_CODADM","C" ,TamSx3('GQL_CODADM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) // "Cód. Adm"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
            oStruPos:AddField(STR0010,STR0010,"GQL_TPVEND","C",TamSx3('GQL_TPVEND')[1],0,{|| .T.},{|| .T.},GTPXCBox("GQL_TPVEND"),.F.,NIL,.F.,.T.,.T.) // "Tipo Venda"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
            oStruPos:AddField(STR0011,STR0011,"GQM_DTVEND","D",8,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Data Venda"					
            oStruPos:AddField(STR0012,STR0012,"GQM_CODNSU","C",TamSx3('GQM_CODNSU')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) // "Cód. NSU"					
            oStruPos:AddField(STR0013,STR0013,"GQM_CODAUT","C",TamSx3('GQM_CODAUT')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Cód. Aut."					
            oStruPos:AddField(STR0014,STR0014,"GQM_VALOR","N",TamSx3('GQM_VALOR')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Valor"				
            oStruPos:AddField(STR0015,STR0015,"GQM_QNTPAR","C",TamSx3('GQM_QNTPAR')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // Num. Parc.						
            oStruPos:AddField(STR0020,STR0020,"GQL_RECNO","N",8,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Recno GQL"						

            If lNewFlds
                oStruPos:AddField(STR0016,STR0016,"GQM_CONFER","C",TamSx3('GQM_CONFER')[1],0,{|| .T.},{|| .T.},GTPXCBox("GQM_CONFER"),.F.,	NIL,.F.,.T.,.T.) // "Status Conf."						
                oStruPos:AddField(STR0017,STR0017,"GQM_DTCONF","D",8,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Data Conf."					
                oStruPos:AddField(STR0019,STR0019,"GQM_MOTREJ","C",TamSx3('GQM_MOTREJ')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Motivo Rej."						
                oStruPos:AddField(STR0018,STR0018,"GQM_USUCON","C",TamSx3('GQM_USUCON')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Usu. Conf."						
                oStruPos:AddField(STR0027,STR0027,"GQM_VLACER","N",TamSx3('GQM_VLACER')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // "Vlr. Acerto"						
            Endif

            oStruPos:AddTrigger('GQM_CONFER','GQM_CONFER',{||.T.}, bTrig)
            oStruPos:SetProperty('GQL_CODADM', MODEL_FIELD_VALID, bFldVld)

        Endif	

    ElseIf cTipo == 'V'

        If ValType(oStruPos) == "O"

            oStruPos:AddField("GQM_CODIGO","01",STR0008,STR0008,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				
            oStruPos:AddField("GQL_CODADM","02",STR0009,STR0009,{""},"GET","@!",NIL,"SAE",.T.,NIL,NIL,{},NIL,NIL,.F.)		
            oStruPos:AddField("GQL_TPVEND","03",STR0010,STR0010,{""},"GET","@!",NIL,"",.T.,NIL,NIL,GTPXCBox("GQL_TPVEND"),NIL,NIL,.F.)				
            oStruPos:AddField("GQM_DTVEND","04",STR0011,STR0011,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			
            oStruPos:AddField("GQM_CODNSU","05",STR0012,STR0012,{""},"GET","",	NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			
            oStruPos:AddField("GQM_CODAUT","06",STR0013,STR0013,{""},"GET","",	NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			
            oStruPos:AddField("GQM_VALOR" ,"07",STR0014,STR0014,{""},"GET","@E 9,999.99",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	
            oStruPos:AddField("GQM_VLACER","08","Vlr. Acerto","Vlr. Acerto",{""},"GET","@E 9,999.99",NIL,,.T.,NIL,NIL,{},NIL,NIL,.F.)	
            oStruPos:AddField("GQM_QNTPAR","09",STR0015,STR0015,{""},"GET","@!",NIL,,.T.,NIL,NIL,{},NIL,NIL,.F.)	

            If lNewFlds
                oStruPos:AddField("GQM_CONFER","10",STR0016,STR0016,{""},"GET","@!",NIL,,.T.,NIL,NIL,GTPXCBox("GQM_CONFER"),NIL,NIL,.F.)	
                oStruPos:AddField("GQM_DTCONF","11",STR0017,STR0017,{""},"GET","@!",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	
                oStruPos:AddField("GQM_MOTREJ","12",STR0019,STR0019,{""},"GET","@!",NIL,,.T.,NIL,NIL,{},NIL,NIL,.F.)	
                oStruPos:AddField("GQM_USUCON","13",STR0018,STR0018,{""},"GET","@!",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	
            Endif

        Endif

    Endif
	
Return

/*/{Protheus.doc} G026BTrigger(oMdl,cField,uVal)
(long_description)
@type function
@author flavio.martins
@since 03/06/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G026BTrigger(oMdl,cField,uVal)

If cField == 'GQM_CONFER'

    If uVal != '3'
        oMdl:ClearField('GQM_MOTREJ')
    Endif

Endif

Return

/*/{Protheus.doc} G026BdValid(oMdl,cField,uNewValue,uOldValue)
(long_description)
@type function
@author flavio.martins
@since 03/06/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G026BdValid(oMdl,cField,uNewValue,uOldValue)
Local lRet     := .T.
Local cMsgErro := ''
Local cMsgSol  := ''

If cField == 'GQL_CODADM'

    If !GtpExistCpo('SAE',uNewValue)
        lRet        := .F.
        cMsgErro    := STR0025 // "Registro não encontrado ou se encontra bloqueado"
        cMsgSol     := STR0026 // "Verifique os dados informados"
    Endif 
    
Endif

If !lRet .and. !Empty(cMsgErro)
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"G026BdValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} GA115VldAct
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G026BVldAct(oModel)
Local cStatus	:= G6X->G6X_STATUS //oMdlG6X:GetValue("G6X_STATUS")
Local lRet		:= .T.
Local aNewFlds  := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON', 'GQM_VLACER'}
Local cMsgErro  := ''
Local cMsgSol   := ''

If !(GTPxVldDic('GQM', aNewFlds, .F., .T.))
    lRet     := .F.
    cMsgErro := STR0023 // "Dicionário desatualizado"
    cMsgSol  := STR0024 // "Atualize o dicionário para utilizar esta rotina"  
Endif

If lRet
    If cStatus <> '2'
        lRet := .F.
        cMsgErro := STR0022
        cMsgSol  := ''
    Endif
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G026BVldAct",cMsgErro,cMsgSol,,)
Endif

Return lRet

/*/{Protheus.doc} G026BActiv()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 02/06/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G026BActiv(oModel)
Local oMdlG6X   := oModel:GetModel('HEADER')
Local oGridPos  := oModel:GetModel('GRIDPOS')
Local cNumFch   := oMdlG6X:GetValue('G6X_NUMFCH')
Local cAgencia  := oMdlG6X:GetValue('G6X_AGENCI') 
Local cAliasPos	:= GetNextAlias()
Local cQuery    := ''

If GQM->(FieldPos('GQM_VLACER')) > 0
    cQuery := ', GQM_VLACER '
Endif

cQuery := '%' + cQuery + '%'

BeginSql Alias cAliasPOS

    SELECT GQL.GQL_CODADM,
        GQL.GQL_TPVEND,
        GQL.R_E_C_N_O_ GQL_RECNO,
        GQM.GQM_CODIGO,
        GQM.GQM_CODNSU,
        GQM.GQM_CODAUT,
        GQM_DTVEND,
        GQM.GQM_VALOR,
        GQM.GQM_QNTPAR,
        GQM.GQM_CONFER,
        GQM.GQM_DTCONF,
        GQM.GQM_USUCON,
        GQM.GQM_MOTREJ
        %Exp:cQuery%
    FROM %Table:GQL% GQL
    INNER JOIN %Table:GQM% GQM 
        ON GQM.GQM_FILIAL = GQL.GQL_FILIAL
        AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
        AND GQM.%NotDel%
    WHERE GQL.GQL_FILIAL = %xFilial:GQL% 
        AND GQL.GQL_CODAGE = %Exp:cAgencia%
        AND GQL.GQL_NUMFCH = %Exp:cNumFch%
        AND GQL.%NotDel%

EndSql

While !(cAliasPos)->(Eof())

    If !(oGridPos:IsEmpty())
        oGridPos:AddLine()
    Endif

    oGridPos:SetValue('GQL_CODADM', (cAliasPOS)->GQL_CODADM)
    oGridPos:SetValue('GQL_TPVEND', (cAliasPOS)->GQL_TPVEND)
    oGridPos:SetValue('GQM_CODIGO', (cAliasPOS)->GQM_CODIGO)
    oGridPos:SetValue('GQM_DTVEND', STOD((cAliasPOS)->GQM_DTVEND))
    oGridPos:SetValue('GQM_CODNSU', (cAliasPOS)->GQM_CODNSU)
    oGridPos:SetValue('GQM_CODAUT', (cAliasPOS)->GQM_CODAUT)
    oGridPos:SetValue('GQM_VALOR', (cAliasPOS)->GQM_VALOR)
    oGridPos:SetValue('GQM_QNTPAR', (cAliasPOS)->GQM_QNTPAR)
    oGridPos:SetValue('GQM_CONFER', (cAliasPOS)->GQM_CONFER)
    oGridPos:SetValue('GQM_DTCONF', STOD((cAliasPOS)->GQM_DTCONF))
    oGridPos:SetValue('GQM_USUCON', (cAliasPOS)->GQM_USUCON)
    oGridPos:SetValue('GQM_MOTREJ', (cAliasPOS)->GQM_MOTREJ)
    oGridPos:SetValue('GQL_RECNO', (cAliasPOS)->GQL_RECNO)

    If GQM->(FieldPos('GQM_VLACER')) > 0
        oGridPos:SetValue('GQM_VLACER', (cAliasPOS)->GQM_VLACER)
    Endif
    
    (cAliasPos)->(dbSkip())

End

oGridPos:GetStruct():SetProperty('GQM_MOTREJ',MODEL_FIELD_WHEN,{|oMdl| oMdl:GetValue('GQM_CONFER') == "3" })

oGridPos:SetNoInsertLine(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} (oModel)
Confere todos os bilhetes disponiveis na grid

@type  Static Function
@param oModel
@return
@example (examples)
@see (links_or_references)

@author Flavio Martins
@since 27/10/2017
@version 1
/*/
//------------------------------------------------------------------------------
Static Function ConfereTudo(oView)
Local oGridPos	:= oView:GetModel('GRIDPOS')
Local lFiltrado	:= oView:GetViewObj('VIEW_DETAIL')[3]:oBrowse:Filtrate()
Local aFiltrado	:= Nil
Local nX		:= 0
Local lUsrConf  := GQM->(FieldPos('GQM_USUCON')) > 0
Local cUserLog  := AllTrim(RetCodUsr())

If !lFiltrado
	For nX := 1 To oGridPOS:Length()
		oGridPos:GoLine(nX)
		If !(Empty(oGridPos:GetValue('GQM_CODIGO'))) .And. oGridPos:GetValue('GQM_CONFER') == '1'
			oGridPos:SetValue('GQM_CONFER', '2')
			
			If lUsrConf
				oGridPos:LoadValue('GQM_USUCON', cUserLog )
			EndIf

		Endif
	Next nX 
Else
	aFiltrado := oView:GetViewObj('VIEW_DETAIL')[3]:GetFilLines()
	For nX := 1 To Len(aFiltrado)
		oGridPos:GoLine(aFiltrado[nX])
		If !(Empty(oGridPos:GetValue('GQM_CODIGO'))) .And. oGridPos:GetValue('GQM_CONFER') == '1'
			oGridPos:SetValue('GQM_CONFER', '2')

			If lUsrConf
				oGridPos:LoadValue('GQM_USUCON', cUserLog )
			EndIf

		Endif
	Next nX
Endif

If oGridPos:SeekLine({{'GQM_CONFER', '1'}})
//	Help( , , "ConfereTudo", "GTPA115B", STR0052, 1, 0)	// "Existente bilhetes que não foram conferidos. Preencha o(s) campo(s) obrigatório(s) à conferência e repita o processo."	
EndIf

oGridPos:GoLine(1)
GTPDestroy(aFiltrado)

Return

/*/{Protheus.doc} G026BCommit(oModel)
    Realiza o commit dos bilhetes conferidos
    @type  Static Function
    @author Flavio Martins
    @since 03/06/2020
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G026BCommit(oModel)
Local oGridPos  := oModel:GetModel('GRIDPOS')
Local oMdl026   := FwLoadModel('GTPA026') 
Local oGridGQM  := oMdl026:GetModel('GQMDETAIL')
Local cUserLog  := AllTrim(RetCodUsr())
Local nX        := 0
Local lRet      := .T.
Local nRecno    := 0
Local cCodGQM   := ''

Begin Transaction 

	For nX := 1 To oGridPos:Length()
	
		oGridPos:GoLine(nX)

        nRecno  := oGridPos:GetValue('GQL_RECNO')
        cCodGQM := oGridPos:GetValue('GQM_CODIGO')
        
        GQL->(dbGoto(nRecno))
		
      	oMdl026:SetOperation(MODEL_OPERATION_UPDATE)
	    oMdl026:Activate()

        If oGridGQM:SeekLine({{"GQM_CODIGO", cCodGQM}},.F.,.T.)

            oGridGQM:SetValue('GQM_DTVEND', oGridPos:GetValue('GQM_DTVEND'))
            oGridGQM:SetValue('GQM_CODNSU', oGridPos:GetValue('GQM_CODNSU'))
            oGridGQM:SetValue('GQM_CODAUT', oGridPos:GetValue('GQM_CODAUT'))
            oGridGQM:SetValue('GQM_VALOR', oGridPos:GetValue('GQM_VALOR'))
            oGridGQM:SetValue('GQM_QNTPAR', oGridPos:GetValue('GQM_QNTPAR'))
            oGridGQM:SetValue('GQM_MOTREJ', oGridPos:GetValue('GQM_MOTREJ'))
            oGridGQM:SetValue('GQM_CONFER', oGridPos:GetValue('GQM_CONFER'))

            If oGridPos:GetValue('GQM_CONFER') > '1'
                oGridGQM:SetValue('GQM_DTCONF', dDataBase)
                oGridGQM:SetValue('GQM_USUCON', cUserLog)
            Endif

            If GQM->(FieldPos('GQM_VLACER')) > 0
                oGridGQM:SetValue('GQM_VLACER', oGridPos:GetValue('GQM_VLACER'))
            Endif

        Endif 

        If oMdl026:VldData()
            oMdl026:CommitData()
        Endif

        oMdl026:DeActivate()

	Next
	
	If lRet
	
		FwFormCommit(oModel)
		
	Else
	
		DisarmTransaction()
	
	Endif

End Transaction

Return lRet

