#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA980.CH'

Static cRetcBase 	:= ""
Static cRetcItem	:= ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA980
    Cadastro Base x Ativo.
@sample	TECA980() 
@since		27/07/2016       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA980()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( "TWH" )
oBrw:SetMenudef( "TECA980" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // "Base x Ativo"
oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
    Rotina para construção do menu
@sample	Menudef() 
@since		27/07/2016       
@version	P12
@return    aMenu, ARRAY, lista de opções disponíveis para usuário x rotina
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

ADD OPTION aMenu Title STR0002  Action 'PesqBrw'       	 OPERATION 1 ACCESS 0 	//"Pesquisar"
ADD OPTION aMenu Title STR0003  Action 'VIEWDEF.TECA980' OPERATION 2 ACCESS 0 	//"Visualizar"
ADD OPTION aMenu Title STR0004  Action 'VIEWDEF.TECA980' OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aMenu Title STR0005  Action 'VIEWDEF.TECA980' OPERATION 4 ACCESS 0 	//"Alterar"
ADD OPTION aMenu Title STR0006  Action 'VIEWDEF.TECA980' OPERATION 5 ACCESS 0 	//"Excluir"

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@since 29/08/2013
@version     P11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView := Nil
Local oMdl := ModelDef()

Local oStrCabec := FWFormStruct( 2,"TWH" , {|cCampo|  ( Alltrim( cCampo )$"TWH_BASE+TWH_FILORI+TWH_DESC+TWH_QTDATF+TWH_SLDLOC+TWH_SLDRES+TWH_SLDMAN+TWH_SLDBLQ+TWH_SLDDIS" ) } )
Local oStrGrid := FWFormStruct( 2,"TWH" , {|cCampo|  !( Alltrim( cCampo )$"TWH_BASE+TWH_FILORI+TWH_DESC+TWH_QTDATF+TWH_SLDLOC+TWH_SLDRES+TWH_SLDMAN+TWH_SLDBLQ+TWH_SLDDIS" ) } )

oView := FWFormView():New()

oView:SetModel(oMdl)
oView:SetDescription( STR0001 ) // "Base x Ativo"

oView:AddField("CABEC",oStrCabec,"TWH_CABEC")
oView:AddGrid("GRID",oStrGrid,"TWH_GRID")

//--------------------------------------
//        Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "SUPERIOR", 20 )  // Cabeçalho
oView:CreateHorizontalBox( "INFERIOR", 80 )  // Grid

//--------------------------------------
//        Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( 'CABEC', 'SUPERIOR' ) 
oView:SetOwnerView( 'GRID' , 'INFERIOR' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@since 29/08/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil
Local oStrCabec := FWFormStruct( 1,"TWH" , {|cCampo|  ( Alltrim( cCampo )$"TWH_BASE+TWH_FILORI+TWH_DESC+TWH_QTDATF+TWH_SLDLOC+TWH_SLDRES+TWH_SLDMAN+TWH_SLDBLQ+TWH_SLDDIS" ) } )
Local oStrGrid := FWFormStruct( 1,"TWH" , {|cCampo|  !( Alltrim( cCampo )$"TWH_BASE+TWH_FILORI+TWH_DESC+TWH_QTDATF+TWH_SLDLOC+TWH_SLDRES+TWH_SLDMAN+TWH_SLDBLQ+TWH_SLDDIS" ) } )

oModel := MPFormModel():New("TECA980",/*bPreValid*/,{|oModel| At980TudoOk(oModel)}, {|oModel| At980Commit(oModel)}, /*bCancel*/)
oModel:AddFields("TWH_CABEC",/*cOwner*/,oStrCabec)
oModel:AddGrid("TWH_GRID", "TWH_CABEC", oStrGrid, {|oMdlG,nLine,cAcao,cCampo| At980PreV( oMdlG,nLine,cAcao,cCampo ) },/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

oModel:SetRelation("TWH_GRID",{ { "TWH_FILIAL", "xFilial('TWH')" }, { "TWH_BASE", "TWH_BASE" }, { "TWH_FILORI", "TWH_FILORI" } },TWH->(IndexKey( 1 ) ) )
oModel:SetPrimaryKey( { "TWH_FILIAL" , "TWH_BASE" } )
oModel:SetDescription( STR0001 ) // "Base x Ativo"

oModel:GetModel("TWH_GRID"):SetUniqueLine({"TWH_ATVCBA","TWH_ATVITE"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} At980F3()
Construção da consulta especifica

@since 27/07/2016
@version P12
/*/
//------------------------------------------------------------------
Function At980F3()
Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= GetNextAlias()
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita	:= 0
Local oDlgTela	:= Nil
Local cQry			:= ""
Local aIndex		:= { "N1_CBASE", "N1_FILIAL" }    // adicionada a filial para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último
Local aSeek		:= { { STR0018, { { STR0023,"C",TamSX3("N1_CBASE")[1],0,"",,} } } }  // "Ativos" ### "Cod. do Bem"
Local oModel		:= FwModelActive()
Local cFil 		:= xFilial("SN1", oModel:GetValue("TWH_CABEC","TWH_FILORI") )

cQry := " SELECT "
cQry += 	" N1_CBASE, N1_FILIAL, N1_ITEM, N1_DESCRIC "
cQry += " FROM " + RetSqlName("SN1") + " SN1 "
cQry += " WHERE N1_FILIAL = '"+cFil+"'"
cQry += 	" AND SN1.D_E_L_E_T_ = ' '"
cQry += " ORDER BY SN1.N1_FILIAL, SN1.N1_CBASE"

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0018 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL  // "Ativos"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0017)  // "Ativo Fixo"
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRetcBase := (oBrowse:Alias())->N1_CBASE, cRetcItem := (oBrowse:Alias())->N1_ITEM , lRet := .T. ,oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi( STR0007 ), {|| cRetcBase   := (oBrowse:Alias())->N1_CBASE, cRetcItem := (oBrowse:Alias())->N1_ITEM  ,lRet := .T., oDlgTela:End() } ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi( STR0008 ),  {|| cRetcBase  := "" , cRetcItem := "" , oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()

ADD COLUMN oColumn DATA { ||  N1_FILIAL }	TITLE STR0009 SIZE TamSX3("N1_FILIAL")[1]		OF oBrowse //"Filial"
ADD COLUMN oColumn DATA { ||  N1_CBASE }	TITLE STR0010 SIZE TamSX3("N1_CBASE")[1] 		OF oBrowse //"Código"
ADD COLUMN oColumn DATA { ||  N1_ITEM }		TITLE STR0011 SIZE TamSX3("N1_ITEM")[1] 		OF oBrowse //"Item"
ADD COLUMN oColumn DATA { ||  N1_DESCRIC }	TITLE STR0012 SIZE TamSX3("N1_DESCRIC")[1] 		OF oBrowse //"Descrição"

oBrowse:SetQueryIndex( aIndex )
oBrowse:SetSeek( , aSeek)

oBrowse:Activate()

ACTIVATE MSDIALOG oDlgTela CENTERED

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At980Rt()
Retorno da consulta especifica

@since 27/07/2016
@version P12
/*/
//------------------------------------------------------------------
Function At980Rt()
Local oModel		:= FwModelActive()
Local oView		:= FWViewActive()
Local oGridTHW	:= oModel:GetModel("TWH_GRID")

TWH->(DbSetOrder(2))
If !TWH->(DbSeek(xFilial("TWH") + oModel:GetModel('TWH_CABEC'):GetValue("TWH_FILORI") + PadR(cRetcBase,TamSX3('TWH_ATVCBA')[1])  + PadR(cRetcItem,TamSX3('TWH_ATVITE')[1])))	
	If oGridTHW:SetValue("TWH_ATVCBA",cRetcBase) 
		oGridTHW:ClearField("TWH_ATVITE")
		If oGridTHW:SetValue("TWH_ATVITE",cRetcItem)
			oView:Refresh()
		EndIf	
	Endif
Else
	Help(,, "At980VlCpo",, STR0015 , 1, 0,,,,,,{ STR0016 }) //"Ja existe esse ativo amarrado" # "Informe outro ativo"
	cRetcBase := ""
EndIf			

Return cRetcBase

//-------------------------------------------------------------------
/*/{Protheus.doc} At980VlCpo()
Valida se existe o ativo.

@since 27/07/2016
@version P12
/*/
//------------------------------------------------------------------
Function At980VlCpo(cSeek)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet 		:= .T.
Default cSeek		:= ""

DbSelectArea("SN1")
SN1->(DbSetOrder(1))

DbSelectArea("TWH")
TWH->(DbSetOrder(2))		

If !Empty(cSeek)
	If !SN1->(DbSeek(cSeek))
		lRet := .F.
		Help(,, "At980VlCpo",, STR0013 , 1, 0,,,,,,{ STR0014 }) //"Não existe esse ativo" # "Informe um ativo existente"
	Elseif TWH->(DbSeek(xFilial("TWH")+cSeek))
		lRet := .F.
		Help(,, "At980VlCpo",, STR0015 , 1, 0,,,,,,{ STR0016 }) //"Ja existe esse ativo amarrado" # "Informe outro ativo"
	Endif
Endif

If	Len(aArea) > 0
	RestArea(aArea)
EndIf
FWRestRows(aSaveLines)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} TEC980BQtd()
Verificação de quantidade de registros entre Base e Ativo

@author guilherme.pimentel

@since 18/08/2016
@version P12
@Return lRet

@Obs Validação para verificar se o produto vinculado a base
possui controle de ID unico, caso possua somente poderá ser adicionado
um registro no grid
/*/
//-------------------------------------------------------------------
Function TEC980BQtd()
Local oModel := FWModelActive()
Local oModelTHWG := oModel:GetModel('TWH_GRID')
Local oModelTHWC := oModel:GetModel('TWH_CABEC')
Local lRet := .T.

Local oTecProvider	:= TECProvider():New(oModelTHWC:GetValue('TWH_BASE'))

	If ValType(oTecProvider) == "O" .and. oTecProvider:lValido
		If oModelTHWG:Length(.T.) == 1
			oModelTHWG:SetNoInsertLine(oTecProvider:lIdUnico)
		Else
			If oTecProvider:lIdUnico
				lRet := .F.
				Help(" ",1,"TEC980BQtd",,STR0019,4,1)  // 'O produto vinculado a base possui o controle de ID Único, favor vincular apenas um ativo.'
			EndIf
		EndIf
	ElseIf ValType(oTecProvider) == "O"
		oTecProvider:ShowErro()
		lRet := .F.
		
		FreeObj(oTecProvider)
		DelClassIntF(oTecProvider)
	Else
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} Tc980LDes()
Retorna a descrição da base de atendimento. Uso no inicializador padrao
do campo TWH_DESC (X3_RELACAO)

@author cesar.augusto
@since 18/08/2016
@version P12
@Return cRet

/*/
//-------------------------------------------------------------------
Function Tc980LDes(cBase,lGatilho)
	Local cDesc := Space(TamSx3('B1_DESC')[1])
	Local cCodPro := ""
	Local aArea := {}
	Default cBase	 := ""
	Default lGatilho := .F.
	
	If !Empty(cBase) .And. !INCLUI .Or. lGatilho
		aArea := GetArea()
		
		dbSelectArea('AA3')
		AA3->(dbSetOrder(6))
		If AA3->(dbSeek(xFilial('AA3') + cBase ))
			dbSelectArea('SB1')
			SB1->(dbSelectArea(1))
			If SB1->(dbSeek(xFilial('SB1') + AA3->AA3_CODPRO))
				cDesc := alltrim(SB1->B1_DESC)
			EndIf
		EndIf
		
		RestArea(aArea)
	EndIf                       

Return cDesc

//------------------------------------------------------------------
/*/{Protheus.doc} TEC980Qtd()
Caso o produto seja controlado por ID unico não poderá ser vinculado
a bens com quantidade maior que um

@author guilherme.pimentel

@since 18/08/2016
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function TEC980Qtd(xValue)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .T.
Local oTecProvider	:= TECProvider():New(AA3->AA3_NUMSER)

SN1->(DbSetOrder(1))
SN1->(DbSeek(xFilial("SN1")+xValue))

If SN1->N1_QUANTD > 1 .And. oTecProvider:lIdUnico
	lRet := .F.
	Help(" ",1,"TEC980Qtd",,STR0020,4,1)  // 'Não é possivel vincular ativos com quantidade maior que um à bases de atendimento com ID único'
EndIf

If	Len(aArea) > 0
	RestArea(aArea)
EndIf
FWRestRows(aSaveLines)

Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} At980Commit()
Realiza a gravação do modelo.

@since 06/09/2016
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Static Function At980Commit(oModel)
Local lRet 			:= .T.
Local aSaveLines	:= FWSaveRows()
Local oCabcTWH		:= oModel:GetModel("TWH_CABEC")
Local oGridTWH		:= oModel:GetModel("TWH_GRID")
Local nQtdAtf		:= 0
Local nX			:= 0
Local oTecProvider	:= Nil
Local cNumSer		:= oCabcTWH:GetValue("TWH_BASE")
Local lFromAtf	:= IsInCallStack("ATFA060") .or. IsInCallStack("ATFA036")

	If !lFromAtf
		BeginTran()
	EndIF

	//Verifica se existe quantidade maior que 0 para o desbloqueio da base de atendimento.
	For	nX := 1 To oGridTWH:Length()
		oGridTWH:GoLine(nX)
		If oGridTWH:GetValue("TWH_QUANTD") > 0
			oTecProvider := TECProvider():New(cNumSer)
			If oTecProvider:lBaseBloq
				oTecProvider:DesbloqueiaBase()                             
			Endif

			Exit

		Endif
	Next nX

	FWRestRows(aSaveLines)

	If oModel:VldData()
		If !FWFormCommit(oModel)
			lRet := .F.
			JurShowErro( oModel:GetModel():GetErrormessage() )	
		Endif
	Else
		lRet := .F.
		JurShowErro( oModel:GetModel():GetErrormessage() )
	Endif

	If !lRet
		DisarmTransaction()
	Endif

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		If ValType(oTecProvider) <> 'O'
			oTecProvider := TECProvider():New(cNumSer)
		EndIf
		oTecProvider:AtStatusBase()
	EndIf		

	If !(lFromAtf)
		EndTran()
	EndIf

	TecDestroy(oTecProvider)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} At890Exc()

@since 19/09/2016
@Return lRet
/*/
//-------------------------------------------------------------------
Function At890Exc()
Local oTecProvider := TECProvider():New(TWH->TWH_BASE)
Local lRet := oTecProvider:SaldoDisponivel() == oTecProvider:SaldoTotal()
If !lRet
	Help(,, "At980NExc",, STR0024,1, 0,,,,,,{ STR0022 })  // "Não será possível excluir este registro, pois existem movimentações que compromentem o saldo da base de atendimento" ### "Consulte a aba de Saldos"
EndIf 

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} At980PreV()

@since 19/09/2016
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function At980PreV( oMdlG,nLine,cAcao,cCampo )
Local lRet := .T.
Local oModel := oMdlG:GetModel()

If oModel:GetValue('TWH_CABEC','TWH_QTDATF') <>  oModel:GetValue('TWH_CABEC','TWH_SLDDIS') .And. cAcao $ 'DELETE|SETVALUE' .And. !oMdlG:IsInserted()
	lRet := .F.
	Help(,, "At980NExc",, STR0025,4, 1,,,,,,{ STR0022 })  // "Não sera possível alterar/excluir este registro, pois existem movimentações que compromentem o saldo da base de atendimento" ### "Consulte a aba de Saldos"
EndIf

Return lRet 
 	

//------------------------------------------------------------------
/*/{Protheus.doc} At980TudoOk()

@since 19/09/2016
@version P12
@Return lRet
/*/
//------------------------------------------------------------------- 	
Function At980TudoOk(oModel)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oTWHMaster := oModel:GetModel('TWH_CABEC')
Local oTWHDetail := oModel:GetModel('TWH_GRID')
Local lRet := .T.
Local oTecProvider	:= TECProvider():New(oTWHMaster:GetValue('TWH_BASE'))
Local nI	:= 1
Local nRet	:= 0

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	lRet := At890Exc()
EndIf

If lRet
	If oTecProvider:lIdUnico
		For nI := 1 To oTWHDetail:Length()
			oTWHDetail:GoLine(nI)
			If !oTWHDetail:IsDeleted()
				nRet += oTWHDetail:GetValue('TWH_QUANTD')
			EndIf
		Next nI
		lRet := nRet <= 1
	EndIf
	
	If !lRet
		Help(" ",1,"TEC980Qtd",,STR0019,4,1) // 'O produto vinculado a base possui o controle de ID Único, a quantidade dos ativos vinculados deve ser igual a um.'
	EndIf
EndIf
FWRestRows(aSaveLines)

Return lRet
