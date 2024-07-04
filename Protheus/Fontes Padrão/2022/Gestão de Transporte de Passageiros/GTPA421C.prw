#Include "GTPA421C.ch"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"

Static lOpDesej := .F.

/*/{Protheus.doc} GTPA421C
    Chamada para ativar receita
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421CR ()
lOpDesej := .T.

GTPA421C()

Return

/*/{Protheus.doc} GTPA421C
    Chamada para ativar despesa
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421CD ()
lOpDesej := .F.

GTPA421C()

Return

/*/{Protheus.doc} GTPA421C
    Programa em MVC da conferência de Receita/Despesa
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421C()

	FwMsgRun(, {|| FwExecView("","VIEWDEF.GTPA421C",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //STR0001 //"Buscando registros..."
	
Return()

/*/{Protheus.doc} ModelDef
    Model - Conferência de receita/despesa
    @type  Static Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormStruct( 1, "G6X",,.F. ) // Ficha de Remessa 
Local oStruRec  := FwFormModelStruct():New()
Local cTitulo   := IIF(lOpDesej,STR0002,STR0003) //"Receita" //"Despesa"
oModel := MPFormModel():New("GTPA421C",,,)

G421CBStruct('M',oStruCab, oStruRec)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,/*bLoad*/)
oModel:AddGrid('GRIDREC', 'HEADER', oStruRec,,,,,/*bLoad*/)
//oModel:AddFields("TOTAIS", "GRIDREC", oStruTot, /*bPre*/ , /*bPost*/,  {|oMdl| SetLoadModel(oMdl)} )
If lOpDesej
    oModel:AddCalc('CALC_TOTAL', 'HEADER', 'GRIDREC', 'GZG_VALOR', 'TOTAL_DEBITO', 'SUM', { || oModel:GetModel("GRIDREC"):GetValue('GZG_TIPO') == '1'},,STR0004)	// "Valor Total" //"Total Receita"
Else
    oModel:AddCalc('CALC_TOTAL', 'HEADER', 'GRIDREC', 'GZG_VALOR', 'TOTAL_CREDITO', 'SUM', { || oModel:GetModel("GRIDREC"):GetValue('GZG_TIPO') == '2'},,STR0005)	// "Valor Total" //"Total Despesa"
EndIf

oModel:GetModel("HEADER"):SetOnlyView(.T.)

oModel:SetPrimaryKey({})

oModel:SetDescription(STR0006 + cTitulo) // //"Conferência de "

oModel:GetModel('HEADER'):SetDescription(STR0007) // //"Ficha de Remessa"
oModel:GetModel('GRIDREC'):SetDescription(cTitulo) //

oModel:SetCommit({|oModel| G421CBCommit(oModel)})
oModel:SetVldActivate({|oModel| G421CBVldAct(oModel)})
oModel:SetActivate( { |oModel|G421CBActiv(oModel) } )

oModel:GetModel('GRIDREC'):SetNoDeleteLine(.T.)

Return(oModel)

/*/{Protheus.doc} ViewDef
    View - Conferência de receita/despesa
    @type  Static Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel    := FwLoadModel("GTPA421C")
Local oStruCab	:= FwFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruRec	:= FwFormViewStruct():New()
Local oStruCalc := FwCalcStruct( oModel:GetModel('CALC_TOTAL'))
Local cTitulo   := IIF(lOpDesej,STR0002,STR0003) //"Despesa" //"Receita"
// Cria o objeto de View
oView := FwFormView():New()

G421CBStruct('V', oStruCab, oStruRec)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_HEADER", oStruCab, "HEADER")
oView:AddGrid("VIEW_DETAIL", oStruRec, "GRIDREC")
oView:AddField('VIEW_TOTAL', oStruCalc, "CALC_TOTAL")

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("DETAIL", 70 )
oView:CreateHorizontalBox("TOTAL", 10 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
oView:SetOwnerView("VIEW_TOTAL", "TOTAL")

oView:AddUserButton(STR0008, "", {|oModel| ConfereTudo(oModel)} )   //  //"Conferir Todos"

oView:EnableTitleView('VIEW_HEADER', STR0009) //  //"Dados da Ficha de Remessa"

oView:EnableTitleView('VIEW_DETAIL', cTitulo) // 

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.T.)

Return(oView)

/*/{Protheus.doc} G421CBStruct(ctipo, oStruCab, oStruRec)
    Configura as estruturas do model e view
    @type  Static Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param oStruCab, oStruRec
    @return
    @see (links_or_references)
/*/
Static Function G421CBStruct(cTipo, oStruCab, oStruRec)
Local bTrig     := {|oMdl,cField,uVal| G421CBTrigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,cNewValue,cOldValue| FieldValid(oMdl,cField,cNewValue,cOldValue)}
Local aNewFlds  := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_VLACER'}
Local lNewFlds  := GTPxVldDic('GZG', aNewFlds, .F., .T.)

	If cTipo == 'M' 
    
        If ValType(oStruRec) == "O"
	
            oStruRec:AddField(STR0010,STR0010,"GZG_SEQ","C",TamSx3('GZG_SEQ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // 					 //STR0010 //"Sequencia"
            oStruRec:AddField(STR0011,STR0011,"GZG_COD","C",TamSx3('GZG_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // 					 //STR0011 //"Código"
            oStruRec:AddField(STR0012,STR0012,"GZG_DESCRI","C",TamSx3('GZG_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // 					 //STR0012 //"Descrição"
            oStruRec:AddField(STR0013,STR0013,"GZG_AGENCI","C",TamSx3('GZG_AGENCI')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0013					 //STR0013 //"Agência"
            oStruRec:AddField(STR0014,STR0014,"GZG_VALOR","N",TamSx3('GZG_VALOR')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0014				 //STR0014 //"Valor"
            oStruRec:AddField(STR0015,STR0015,"GZG_TIPO","C",TamSx3('GZG_TIPO')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0015				 //STR0015 //"Tipo"
            oStruRec:AddField(STR0026,STR0026,"GZG_CARGA","L",TamSx3('GZG_CARGA')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0015				 //STR0015 //"Carga"

            If lNewFlds
                oStruRec:AddField(STR0016,STR0016,"GZG_CONFER","C",TamSx3('GZG_CONFER')[1],0,{|| .T.},{|| .T.},GTPXCBox("GZG_CONFER"),.F.,	NIL,.F.,.T.,.T.) // STR0016						 //STR0016 //"Status Conf."
                oStruRec:AddField(STR0017,STR0017,"GZG_DTCONF","D",8,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0017					 //STR0017 //"Data Conf."
                oStruRec:AddField(STR0018,STR0018,"GZG_MOTREJ","C",TamSx3('GZG_MOTREJ')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0018						 //STR0018 //"Motivo Rej."
                oStruRec:AddField(STR0019,STR0019,"GZG_USUCON","C",TamSx3('GZG_USUCON')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0019						 //STR0019 //"Usu. Conf."
                oStruRec:AddField(STR0027,STR0027,"GZG_VLACER","N",TamSx3('GZG_VLACER')[1],2,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.) // STR0014				 //STR0014 //"Vlr. Acerto"
    
                oStruRec:AddTrigger('GZG_CONFER','GZG_CONFER',{||.T.}, bTrig)

                oStruRec:SetProperty('GZG_CONFER', MODEL_FIELD_VALID, bFldVld)

            Endif

            
        Endif	

    ElseIf cTipo == 'V'

        If ValType(oStruRec) == "O"

            oStruRec:AddField("GZG_SEQ"   ,"01",STR0010,STR0010	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0010 //"Sequencia"
            oStruRec:AddField("GZG_COD"   ,"02",STR0011,STR0011	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0011 //"Código"
            oStruRec:AddField("GZG_DESCRI","03",STR0012,STR0012	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)					 //STR0012 //"Descrição"
            oStruRec:AddField("GZG_VALOR" ,"04",STR0014,STR0014,{""},"GET","@E 9,999.99",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0014 //"Valor"
            If lNewFlds
                oStruRec:AddField("GZG_CONFER","06",STR0016,STR0016,{""},"GET","@!",NIL,,.T.,NIL,NIL,GTPXCBox("GZG_CONFER"),NIL,NIL,.F.)	 //STR0016 //"Status Conf."
                oStruRec:AddField("GZG_DTCONF","07",STR0017,STR0017,{""},"GET","@!",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0017 //"Data Conf."
                oStruRec:AddField("GZG_MOTREJ","08",STR0018,STR0018,{""},"GET","@!",NIL,,.T.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0018 //"Motivo Rej."
                oStruRec:AddField("GZG_USUCON","09",STR0019,STR0019,{""},"GET","@!",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0019 //"Usu. Conf."
                oStruRec:AddField("GZG_VLACER","05",STR0027,STR0027,{""},"GET","@E 9,999.99",NIL,,.T.,NIL,NIL,{},NIL,NIL,.F.)	 //STR0014 //"Valor"
            Endif

        Endif

    Endif
	
Return

/*/{Protheus.doc} G421CBTrigger(oMdl,cField,uVal)
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
Static Function G421CBTrigger(oMdl,cField,uVal)

If cField == 'GZG_CONFER'

    If uVal != '3'
        oMdl:ClearField('GZG_MOTREJ')
    Endif

Endif

Return

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
Static Function G421CBVldAct(oModel)

Local lRet		:= .T.
Local cStatus	:= G6X->G6X_STATUS
Local aNewFlds  := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_VLACER'}
Local cMsgErro  := ''
Local cMsgSol   := ''

If !(GTPxVldDic('GZG', aNewFlds, .F., .T.))
    lRet     := .F.
    cMsgErro := STR0020 //  //"Dicionário desatualizado"
    cMsgSol  := STR0021   //  //"Atualize o dicionário para utilizar esta rotina"
Endif

If cStatus <> '2'
    cMsgErro := STR0022//"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G421CBVldAct",cMsgErro,cMsgSol,,)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldArrecFch
Valida se a ficha de remessa tem uma arrecadação
@type Function
@author 
@since 29/06/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function VldArrecFch(cMsgErro,cMsgSol)

Local lRet      := .T.
Local cAgencia  := G6X->G6X_AGENCI
Local cNumFch   := G6X->G6X_NUMFCH
Local cAliasRec	:= GetNextAlias()

BeginSql Alias cAliasRec

    SELECT 
        G59.R_E_C_N_O_ RECNO
    FROM %Table:G59% G59
    WHERE G59.G59_FILIAL = %xFilial:G59% 
		AND G59.G59_AGENCI = %Exp:cAgencia%
		AND G59.G59_NUMFCH = %Exp:cNumFch%
		AND G59.%NotDel%

EndSql

If !(cAliasRec)->(Eof())
    lRet := .F.
    cMsgErro := STR0023//"Fechamento da arrecadação criada para está ficha."
    cMsgSol  := STR0024//"Exclua a arrecadação antes de conferir novamente."
EndIf
(cAliasRec)->(DbCloseArea())
Return lRet 

/*/{Protheus.doc} G421CBActiv()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 09/06/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G421CBActiv(oModel)
Local oMdlG6X   := oModel:GetModel('HEADER')
Local oGridRec  := oModel:GetModel('GRIDREC')
Local cNumFch   := oMdlG6X:GetValue('G6X_NUMFCH')
Local cAgencia  := oMdlG6X:GetValue('G6X_AGENCI') 
Local cAliasRec	:= GetNextAlias()
Local cTipo     := IIF(lOpDesej,"1","2")

BeginSql Alias cAliasRec

    SELECT 
        GZG.GZG_SEQ,
        GZG.GZG_AGENCI,
        GZG.GZG_CONFER,
        GZG.GZG_DTCONF,
        GZG.GZG_USUCON,
        GZG.GZG_MOTREJ,
        GZG.GZG_VALOR,
        GZG.GZG_TIPO,
        GZG.GZG_COD,
        GZG.GZG_DESCRI,
        GZG.GZG_CARGA,
        GZG.GZG_VLACER
    FROM %Table:GZG% GZG
    WHERE GZG.GZG_FILIAL = %xFilial:GZG% 
    AND GZG.GZG_AGENCI = %Exp:cAgencia%
    AND GZG.GZG_NUMFCH = %Exp:cNumFch%
    AND GZG.GZG_TIPO = %Exp:cTipo%
    AND GZG.%NotDel%

EndSql

While !(cAliasRec)->(Eof())

    If !(oGridRec:IsEmpty())
        oGridRec:AddLine()
    Endif

    oGridRec:SetValue('GZG_SEQ', (cAliasRec)->GZG_SEQ)
    oGridRec:SetValue('GZG_COD', (cAliasRec)->GZG_COD)
    oGridRec:SetValue('GZG_DESCRI', (cAliasRec)->GZG_DESCRI)
    oGridRec:SetValue('GZG_AGENCI', (cAliasRec)->GZG_AGENCI)
    oGridRec:SetValue('GZG_VALOR', (cAliasRec)->GZG_VALOR)
    oGridRec:SetValue('GZG_TIPO', (cAliasRec)->GZG_TIPO)
    oGridRec:SetValue('GZG_CONFER', (cAliasRec)->GZG_CONFER)
    oGridRec:SetValue('GZG_DTCONF', STOD((cAliasRec)->GZG_DTCONF))
    oGridRec:SetValue('GZG_USUCON', (cAliasRec)->GZG_USUCON)
    oGridRec:SetValue('GZG_MOTREJ', (cAliasRec)->GZG_MOTREJ)
    oGridRec:SetValue('GZG_CARGA',  IIF((cAliasRec)->GZG_CARGA == 'T', .T.,.F.))
    oGridRec:SetValue('GZG_VLACER', (cAliasRec)->GZG_VLACER)
    
    (cAliasRec)->(dbSkip())

End

oGridRec:GetStruct():SetProperty('GZG_MOTREJ',MODEL_FIELD_WHEN,{|oMdl| oMdl:GetValue('GZG_CONFER') == "3" })
oGridRec:GetStruct():SetProperty('GZG_VLACER',MODEL_FIELD_WHEN,{|oMdl| !(oMdl:GetValue('GZG_CARGA'))})

oGridRec:SetNoInsertLine(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} (oModel)
Confere todos os bilhetes disponiveis na grid

@type  Static Function
@param oModel
@return
@example (examples)
@see (links_or_references)

@author Henrique Madureira
@since 27/10/2017
@version 1
/*/
//------------------------------------------------------------------------------
Static Function ConfereTudo(oView)

Local oGridRec	:= oView:GetModel('GRIDREC')
Local lFiltrado	:= oView:GetViewObj('VIEW_DETAIL')[3]:oBrowse:Filtrate()
Local aFiltrado	:= Nil
Local nX		:= 0
Local lUsrConf  := GZG->(FieldPos('GZG_USUCON')) > 0
Local cUserLog  := AllTrim(RetCodUsr())

If !lFiltrado
	For nX := 1 To oGridRec:Length()
		oGridRec:GoLine(nX)
		If oGridRec:GetValue('GZG_CONFER') == '1'
			oGridRec:SetValue('GZG_CONFER', '2')
			
			If lUsrConf
				oGridRec:LoadValue('GZG_USUCON', cUserLog )
			EndIf

		Endif
	Next nX 
Else
	aFiltrado := oView:GetViewObj('VIEW_DETAIL')[3]:GetFilLines()
	For nX := 1 To Len(aFiltrado)
		oGridRec:GoLine(aFiltrado[nX])
		If oGridRec:GetValue('GZG_CONFER') == '1'
			oGridRec:SetValue('GZG_CONFER', '2')

			If lUsrConf
				oGridRec:LoadValue('GZG_USUCON', cUserLog )
			EndIf

		Endif
	Next nX
Endif

oGridRec:GoLine(1)
GTPDestroy(aFiltrado)

Return

/*/{Protheus.doc} G421CBCommit(oModel)
    Realiza o commit dos bilhetes conferidos
    @type  Static Function
    @author Henrique Madureira
    @since 03/06/2020
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G421CBCommit(oModel)
Local oGridCab	:= oModel:GetModel('HEADER')
Local nNumFch   := oGridCab:GetValue('G6X_NUMFCH')
Local oGridRec  := oModel:GetModel('GRIDREC')
Local oMdl421   := FwLoadModel('GTPA421') 
Local oGridGZG  := NIL
Local cUserLog  := AllTrim(RetCodUsr())
Local nX        := 0
Local lRet      := .T.

If lOpDesej
    oGridGZG := oMdl421:GetModel('GZGRECEITA')
Else
    oGridGZG := oMdl421:GetModel('GZGDESPESA')
EndIf
Begin Transaction 

	For nX := 1 To oGridRec:Length()
	
		oGridRec:GoLine(nX)

        //GZG_FILIAL, GZG_AGENCI, GZG_NUMFCH, GZG_SEQ, GZG_TIPO
        GZG->(DbSetOrder(1))
        GZG->(DbSeek(XFILIAL("GZG") + oGridRec:GetValue('GZG_AGENCI',nX) + nNumFch + oGridRec:GetValue('GZG_SEQ',nX) + oGridRec:GetValue('GZG_TIPO',nX)))
		
      	oMdl421:SetOperation(MODEL_OPERATION_UPDATE)
	    oMdl421:Activate()

        If oGridGZG:SeekLine({  {"GZG_COD",oGridRec:GetValue('GZG_COD',nX)},;
                                {"GZG_AGENCI",oGridRec:GetValue('GZG_AGENCI',nX)},;
                                {"GZG_SEQ", oGridRec:GetValue('GZG_SEQ',nX)};
                            },.F.,.T.)
                            
            oGridGZG:SetValue('GZG_AGENCI', oGridRec:GetValue('GZG_AGENCI',nX))
            oGridGZG:SetValue('GZG_MOTREJ', oGridRec:GetValue('GZG_MOTREJ',nX))
            oGridGZG:SetValue('GZG_CONFER', oGridRec:GetValue('GZG_CONFER',nX))

            If oGridRec:GetValue('GZG_CONFER',nX) > '1'
                oGridGZG:SetValue('GZG_DTCONF', dDataBase)
                oGridGZG:SetValue('GZG_USUCON', cUserLog)
            Endif

            If GZG->(FieldPos('GZG_VLACER')) > 0
                oGridGZG:SetValue('GZG_VLACER', oGridRec:GetValue('GZG_VLACER'))
            Endif

        EndIf
        If oMdl421:VldData()
            oMdl421:CommitData()
        Endif

        oMdl421:DeActivate()

	Next
	
	If lRet
	
		FwFormCommit(oModel)
		
	Else
	
		DisarmTransaction()
	
	Endif

End Transaction

Return lRet

/*/{Protheus.doc} FieldValid(oMdl,cField,cNewValue,cOldValue) 
//TODO Descrição auto-gerada.
@author flavio.martins
@since 21/07/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function FieldValid(oMdl,cField,cNewValue,cOldValue) 
Local lRet      := .T.

If cField == 'GZG_CONFER'

    If cNewValue == '3' .And. oMdl:GetValue('GZG_CARGA')
        lRet := .F.
        oMdl:GetModel():SetErrorMessage(oMdl:GetId(),,oMdl:GetId(),,"FieldValid",STR0025,,,) // "Receitas e Despesas geradas automaticamente não podem ser rejeitadas"
    Endif

Endif

Return lRet
