#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA894.CH"
#INCLUDE "TOPCONN.CH"

STATIC cProdInter 	:= ''
STATIC aPrdTroc		:= {}
Static cRetFac		:= ""
Static aChvTXL		:= {}
Static lUnif		:= At984Uni()
Static cRetUnif 	:= "" //Variavel para retorno da consulta de Uniforme

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA894
Controle de Uniforme

@author		Serviços
@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function TECA894()
Local oBrowse   := NIL

Private aRotina	:= MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TXC')
oBrowse:SetDescription(STR0001) //'Controle de Uniformes'

If !IsBlind()
	oBrowse:Activate()
EndIF

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Controle de Uniforme

@author		Serviços
@since		11/06/2019
@version	P12.1.23
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION 'PesqBrw'			OPERATION 1							ACCESS 0	//'Pesquisar'
ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.TECA894'	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.TECA894'	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //'Incluir'	
ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.TECA894'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //'Solicitar/Alterar'
ADD OPTION aRotina TITLE STR0006	ACTION 'At894Mnt(1)'		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //'Realizar Entrega'	
ADD OPTION aRotina TITLE STR0007	ACTION 'At894Mnt(2)'		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //'Troca/Substituição'
ADD OPTION aRotina TITLE STR0008	ACTION 'At894Mnt(4)'		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //'Trocas Pendentes'	
ADD OPTION aRotina TITLE STR0009	ACTION 'At894Mnt(3)'		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //'Devolução'
ADD OPTION aRotina TITLE STR0010	ACTION 'At894Excl'			OPERATION MODEL_OPERATION_DELETE	ACCESS 0 //'Exclusão'	
ADD OPTION aRotina TITLE STR0011	ACTION 'At894Impr'			OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //'Termo de  Entrega'
ADD OPTION aRotina TITLE STR0012	ACTION 'MsDocument("TXC",TXC->(RECNO()),4)'	OPERATION 9			ACCESS 0 //'Bco. Conhecimento'

Return(aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Controle de Uniforme

@Return 	model
@author 	Serviços
@since 		11/06/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStrCabec	:= FWFormStruct(1, 'TXC')
Local oStrItens	:= FWFormStruct(1, 'TXD')
Local oStrTroca	:= FWFormStruct(1, 'TXE')
//Referente aos intes do Facilitador
Local oStrTXL	:= Iif(lUnif,FwFormStruct(1,'TXL'),NIL)
Local oModel  	:= NIL
Local bLinePre	:= {|oModel, nLine, cAction, cField| At894PreLn(oModel, nLine, cAction, cField) }
Local bPreTXL	:= {|oModel, nLine, cAction, cField,xValue,xOldValue| At894PrTXL(oModel, nLine, cAction, cField,xValue,xOldValue) }
Local aAux		:= {}
Local lDevolParc	:= CmpDevoPar() //Verifica se tem os campos para a devolução parcial
Local lMV_MultFil	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local lIntUnif		:= SuperGetMv("MV_GSITORC",,"2") == "1"

If lUnif
	oModel := MPFormModel():New('TECA894', /*bPreValidacao*/,/*bPosValidacao*/, {|oModel| aChvTXL := {},FWFormCommit(oModel)} /*bCommit*/, {|oModel| aChvTXL := {},FWFormCancel(oModel)} /*bCancel*/ )
Else
	oModel := MPFormModel():New('TECA894', /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
EndIf

If lIntUnif
	// Gatilhos para limpar campos
	aAux := FwStruTrigger( 'TXD_FILTFF', 'TXD_CONTRT', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_FILTFF', 'TXD_POSTO', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_FILTFF', 'TXD_CODPRO', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_FILTFF', 'TXD_DESCR', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_CONTRT', 'TXD_POSTO', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_CONTRT', 'TXD_CODPRO', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_CONTRT', 'TXD_DESCR', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TXD_CODPRO', 'TXD_QTDE', '', .F. )
		oStrItens:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	If At894CmpUn()
		If lMV_MultFil
			oStrItens:SetProperty( "TXD_FILTFF", MODEL_FIELD_OBRIGAT, .T.)
		EndIf
		oStrItens:SetProperty( "TXD_CODPRO", MODEL_FIELD_OBRIGAT, .T.)
		oStrItens:SetProperty( "TXD_POSTO" , MODEL_FIELD_OBRIGAT, .T.)
		oStrItens:SetProperty( "TXD_QTDE"  , MODEL_FIELD_OBRIGAT, .T.)
	Endif
Endif

oModel:SetDescription(STR0001)

oModel:AddFields('TXCMaster', NIL, oStrCabec)
oModel:GetModel('TXCMaster'):SetDescription(STR0065)//'Funcionário'
oModel:SetPrimaryKey({'TXC_FILIAL+TXC_CODTEC'})

oModel:AddGrid('TXDItens', 'TXCMaster', oStrItens, bLinePre)
oModel:SetRelation('TXDItens', {{'TXD_FILIAL','xFilial("TXD")'}, {'TXD_CODTEC', 'TXC_CODTEC'}}, TXD->(IndexKey(1)))

If !lDevolParc
	oModel:GetModel('TXDItens'):SetUniqueLine({'TXD_CODPRO'})
EndIf

oModel:AddGrid('TXETroca', 'TXCMaster', oStrTroca, bLinePre )
oModel:SetRelation('TXETroca', {{'TXE_FILIAL','xFilial("TXE")'}, {'TXE_CODTEC', 'TXC_CODTEC'}}, TXE->(IndexKey(1)))
oModel:GetModel('TXETroca'):SetUniqueLine({'TXE_ITEM'})
oModel:SetOptional('TXETroca', .T.)
oModel:GetModel('TXETroca'):SetLoadFilter(, "TXE_DTTROC = ' '")

If lUnif
	//Facilitador
	oStrTXL:SetProperty('TXL_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := (Vazio() .Or. ExistCpo("TWM")),FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
	oModel:AddGrid('TXLDETAIL', 'TXCMaster', oStrTXL, bPreTXL )
	oModel:SetRelation('TXLDETAIL', { { 'TXL_FILIAL', 'xFilial("TXL")' },{'TXL_CODTEC', 'TXC_CODTEC'} }, TXL->(IndexKey(1)) )
	oModel:GetModel("TXLDETAIL"):SetOptional(.T.)
EndIf 

oModel:GetModel('TXETroca'):SetNoInsertLine(.T.)
oModel:GetModel('TXETroca'):SetNoUpdateLine(.T.)
oModel:GetModel('TXETroca'):SetNoDeleteLine(.T.)

oModel:SetVldActivate({|oModel| At894Pre(oModel)})

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
ViewDef - Controle de Uniforme

@author		Serviços
@since		11/06/2019
@version	P12.1.23
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel('TECA894')
Local oStrCabec  := FWFormStruct(2, 'TXC')
Local oStrItens  := FWFormStruct(2, 'TXD')
Local oStrTroca  := FWFormStruct(2, 'TXE')
Local lContCont	 := CamposCont()
Local lContCCus	 := CampoCCusto()
Local lEndereco  := CmpLocali()
Local lNumSerie  := CmpNumSer()
Local lDevolParc := CmpDevoPar() //Verifica se tem os campos para a devolução parcial
Local lMV_MultFil:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local lIntUnif   := SuperGetMv("MV_GSITORC",,"2") == "1"

//Monta o modelo da interface do formulário
oView := FWFormView():New()
oView:SetModel(oModel)

If lDevolParc	
	oView:AddUserButton(STR0080,"MAGIC_BMP",{ |oModel,oView| At894TrSbD(oModel)},STR0080,,{MODEL_OPERATION_UPDATE})  //"Visualizar substit./devol."     
EndIf

If lIntUnif
	If At894CmpUn()
		// Altera ordem dos campos da aba Uniformes
		oStrItens:SetProperty( 'TXD_ITEM'   , MVC_VIEW_ORDEM,'00')
		oStrItens:SetProperty( 'TXD_FILTFF' , MVC_VIEW_ORDEM,'01')
		oStrItens:SetProperty( 'TXD_CONTRT' , MVC_VIEW_ORDEM,'02')
		oStrItens:SetProperty( 'TXD_POSTO'  , MVC_VIEW_ORDEM,'03')
		oStrItens:SetProperty( 'TXD_CODPRO' , MVC_VIEW_ORDEM,'04')
		oStrItens:SetProperty( 'TXD_DESCR'  , MVC_VIEW_ORDEM,'05')
		// Consulta especifica para Gestao de Uniformes
		oStrItens:SetProperty( "TXD_CONTRT", MVC_VIEW_LOOKUP,{|| "TXDCTR"} )
		oStrItens:SetProperty( "TXD_POSTO" , MVC_VIEW_LOOKUP,{|| "TXDCTR"} )
		oStrItens:SetProperty( "TXD_CODPRO", MVC_VIEW_LOOKUP,{|| "TXDCTR"} )
	EndIf
Endif

If At894CmpUn()
	If SuperGetMv("MV_GSITORC",,"2") == "2"
		oStrItens:RemoveField("TXD_FILTFF")
		oStrItens:RemoveField("TXD_CONTRT")
		oStrItens:RemoveField("TXD_POSTO")
		oStrItens:RemoveField("TXD_CODTXP") //Cod Unif x Orc
	ElseIf !lMV_MultFil
		oStrItens:RemoveField("TXD_FILTFF")
	EndIf
Endif


oStrItens:RemoveField("TXD_CODTEC")
oStrTroca:RemoveField("TXE_CODTEC")
If !lContCont
	If TXD->(ColumnPos("TXD_CONTA")) > 0
		oStrItens:RemoveField("TXD_CONTA")
	EndIf
	If TXD->(ColumnPos("TXD_CLVL")) > 0
		oStrItens:RemoveField("TXD_CLVL")
	EndIf
	If TXD->(ColumnPos("TXD_ITEMCO")) > 0
		oStrItens:RemoveField("TXD_ITEMCO")
	EndIf
	If TXE->(ColumnPos("TXE_CONTA")) > 0
		oStrTroca:RemoveField("TXE_CONTA")
	EndIf
	If TXE->(ColumnPos("TXE_CLVL")) > 0
		oStrTroca:RemoveField("TXE_CLVL")
	EndIf
	If TXE->(ColumnPos("TXE_ITEMCO")) > 0
		oStrTroca:RemoveField("TXE_ITEMCO")
	EndIf
EndIf

If !lContCCus
	If TXD->(ColumnPos("TXD_CCUSTO")) > 0
		oStrItens:RemoveField("TXD_CCUSTO")
	EndIf
	If TXE->(ColumnPos("TXE_CCUSTO")) > 0
		oStrTroca:RemoveField("TXE_CCUSTO")
	EndIf
EndIf

If !lEndereco
	If TXD->(ColumnPos("TXD_LOCALI")) > 0
		oStrItens:RemoveField("TXD_LOCALI")
	EndIf
	If TXE->(ColumnPos("TXE_LOCALI")) > 0
		oStrTroca:RemoveField("TXE_LOCALI")
	EndIf
EndIf

If !lNumSerie
	If TXD->(ColumnPos("TXD_NUMSER")) > 0
		oStrItens:RemoveField("TXD_NUMSER")
	EndIf
	If TXE->(ColumnPos("TXE_NUMSER")) > 0
		oStrTroca:RemoveField("TXE_NUMSER")
	EndIf
EndIf

oView:AddField('viewCabec', oStrCabec, 'TXCMaster')
oView:EnableTitleView('viewCabec', STR0065)//'Funcionário'

oView:AddGrid('viewItens', oStrItens, 'TXDItens')
oView:EnableTitleView('viewItens', STR0065)//'Uniformes'

oView:AddGrid('viewTroca', oStrTroca, 'TXETroca')
oView:EnableTitleView('viewTroca', STR0067)//'Trocas Pendentes'

oView:CreateHorizontalBox('hdrCabec'	, 20)
oView:CreateHorizontalBox('grdItens'	, 50)
oView:CreateHorizontalBox('grdTroca'	, 30)

oView:SetOwnerView('viewCabec'	, 'hdrCabec')
oView:SetOwnerView('viewItens'	, 'grdItens')
oView:SetOwnerView('viewTroca'	, 'grdTroca')

oView:AddIncrementField('viewItens', 'TXD_ITEM')
oView:AddIncrementField('viewTroca', 'TXE_ITEM')

If lUnif
	oView:AddUserButton(STR0076,"",{|oModel,oView| TEC894FACI(oModel)},,,)//"Facilitador"
EndIf 

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Pre()
bloco que será chamado antes do Activate do model.

@sample	At894Pre(oModel)

@param  oModel, Modelo de dados para validação

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At894Pre(oModel)
Local lRet      := .T.
Local cAliasQry := ''

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	// ----------------------------------------
	// VERIFICA SE EXISTEM ITENS ENTREGUES
	// ----------------------------------------
	If lRet
		cAliasQry := GetNextAlias()
		BeginSQL Alias cAliasQry
			SELECT TXD.TXD_CODTEC
			  FROM %Table:TXD% TXD
			 WHERE TXD.TXD_FILIAL = %xFilial:TXD%
			   AND TXD.TXD_CODTEC = %Exp:TXC->TXC_CODTEC%
			   AND TXD.TXD_DTENTR <> ' '
			   AND TXD.%NotDel%
		EndSQL
		If !(cAliasQry)->(Eof())
			oModel:SetErrorMessage(,,,,, CHR(13)+CHR(10)+STR0013)//Existem itens entregues ao funcionário! A Exclusão somente será permitida após a devolução dos mesmos.'
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf


	// ----------------------------------------
	// VERIFICA TROCAS PENDENTES
	// ----------------------------------------
	If lRet
		cAliasQry := GetNextAlias()
		BeginSQL Alias cAliasQry
			SELECT TXE.TXE_CODTEC
			  FROM %Table:TXE% TXE
			 WHERE TXE.TXE_FILIAL = %xFilial:TXE%
			   AND TXE.TXE_CODTEC = %Exp:TXC->TXC_CODTEC%
			   AND TXE.TXE_DTTROC = ' '
			   AND TXE.%NotDel%
		EndSQL
		If !(cAliasQry)->(Eof())
			oModel:SetErrorMessage(,,,,, CHR(13)+CHR(10)+STR0014)//'Existem trocas pendentes para esse Funcionário! Exclusão não permitida.'
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894PreLn()
Bloco de Código de pre-edição da linha do grid.
O bloco é invocado na deleção de linha, no undelete da linha e nas tentativas de atribuição de valor. 

@sample	At894PreLn(oModel, nLine, cAction, cField)

@param  oModel, Modelo de dados
@param  nLine, número da linha atual
@param  cAction, Identificação da ação
@param  cField, campo que está sendo atualizado,somente será passado se a ação for SETVALUE

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At894PreLn(oModel, nLine, cAction, cField)

Local lRet := .T.
Local lIntUnif := SuperGetMv("MV_GSITORC",,"2") == "1" .And. At894CmpUn()

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If !Empty(oModel:GetValue('TXD_DTENTR')) .And. !oModel:IsInserted()
		lRet := .F.
		Help(,, 'At894PrLn',, STR0015, 1, 0) //'Existem trocas pendentes para esse Funcionário! Exclusão não permitida.'
	EndIf
EndIf

If lIntUnif
	If !oModel:IsInserted()
		If Empty(oModel:GetValue("TXD_FILTFF")) .And. Empty(oModel:GetValue("TXD_CONTRT")) .And. Empty(oModel:GetValue("TXD_POSTO"))
			lRet := .F.
			Help(,, 'At894PrLn',, STR0109, 1, 0) //"Alteração não permitida para registros não integrados ao Orçamento."
		EndIf
	Endif
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Vld()
Validação de campos especificos

@sample	At894Vld(cCampo, cPrdInter, cProdNew)

@param  cCampo, Campo que será validado
@param  cPrdInter, Produto Intercambiavel
@param  cProdNew, Novo Produto a ser escolhido(Utilizado para Intercambiavel)

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894Vld(cCampo, cPrdInter, cProdNew)
Local lRet       := .T.
Local aTpUnif    := StrTokArr(SuperGetMV('MV_TPUNIF',, 'UN;'), ';') 	//-- TIPOS DE PRODUTO CORRESPONDENTE AOS UNIFORMES
Local nPosA      := 0
Local aAreaSB1   := SB1->(GetArea())
Local aAreaTWY   := TWY->(GetArea())
Local cTmpQry    := ""
Local cQuery     := ""
Local cTipo      := ""
Local cFilCont   := ""
Local cContrat   := ""
Local cPosto     := ""
Local cCodProd   := ""
Local cCodTec    := ""
Local nQtdProd   := 0
Local lMV_MultFil:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local oModel     := Nil
Local oModITUN   := Nil
Local lIntUnif   := SuperGetMv("MV_GSITORC",,"2") == "1" .And. At894CmpUn()

Default cCampo  := ReadVar()

If cCampo == 'M->TXD_CODPRO' .Or. cCampo == 'M->TXE_CODPRO' .Or. cCampo == 'cProduto'
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	If !SB1->(DbSeek(xFilial('SB1')+If(cCampo == 'M->TXD_CODPRO', M->TXD_CODPRO, If(cCampo == 'M->TXE_CODPRO', M->TXE_CODPRO, cPrdInter))))
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	Else
		nPosA := aScan(aTpUnif, {|c| c ==  SB1->B1_TIPO})
		If nPosA == 0
			lRet := .F.
			Help(,, 'At894Vld',, STR0016, 1, 0) //'O produto informado não é um uniforme!'
		ElseIf cCampo == 'cProduto'
				TWY->(DbSetOrder(1)) //--TWY_FILIAL+TWY_CODPRO+TWY_CODINT+TWY_ITEM
				If TWY->(DbSeek(xFilial('TWY')+cPrdInter))
					lRet := .F.
					Help(,, 'At894Vld',,STR0017 , 1, 0) //"O produto informado é um produto Intercambiável. Informe um produto que não seja Intercambiável para o processo de troca"
				EndIf
		ElseIf cCampo == 'M->TXD_CODPRO' .And. lIntUnif
			If SuperGetMv("MV_GSITORC",,"2") == "1" .And. lMV_MultFil
				cFilCont := FwFldGet("TXD_FILTFF")
			Else
				cFilCont := cFilAnt
			EndIf
			cContrat := FwFldGet("TXD_CONTRT")
			cPosto   := FwFldGet("TXD_POSTO" )
			cCodProd := FwFldGet("TXD_CODPRO")
			cTmpQry  := GetNextAlias()
			cTipo    := Replace(cCampo,"M->","") // Retira prefixo
			cQuery   := TecGetQry(cTipo, cFilCont, cContrat, cPosto, cCodProd)
			DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTmpQry, .T., .T.)
			If (cTmpQry)->(EOF())
				lRet := .F.
				Help(,, 'At894Vld',, STR0106 + cContrat, 1, 0) //"Posto não pertence ao Contrato "
			EndIf
			(cTmpQry)->(DbCloseArea())
		EndIf
	EndIf
ElseIf cCampo == 'cPrdInter'
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial('SB1')+cProdNew))
		TWY->(DbSetOrder(1)) //--TWY_FILIAL+TWY_CODPRO+TWY_CODINT+TWY_ITEM
		If TWY->(DbSeek(xFilial('TWY')+cPrdInter+cProdNew))
			lRet := .T.
		Else
			lRet := .F.
			Help(,, 'At894Vld',, STR0018 + cPrdInter, 1, 0) //'O Produto informado não é intercambiável com o produto '
		EndIf
	Else
		lRet := .F.
		Help('', 1, 'REGNOIS')
	EndIf
ElseIf cCampo == 'M->TXD_FILTFF' .And. lIntUnif
	If SuperGetMv("MV_GSITORC",,"2") == "1" .And. lMV_MultFil
		cFilCont := FwFldGet("TXD_FILTFF")
	Else
		cFilCont := cFilAnt
	EndIf
	If !ExistCpo('SM0',cEmpAnt+cFilCont,1)                                                                                         
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	EndIf
ElseIf cCampo == 'M->TXD_CONTRT' .And. lIntUnif
	If SuperGetMv("MV_GSITORC",,"2") == "1" .And. lMV_MultFil
		cFilCont := FwFldGet("TXD_FILTFF")
	Else
		cFilCont := cFilAnt
	EndIf
	cContrat := FwFldGet("TXD_CONTRT")
	CN9->(DbSetOrder(7)) //CN9_FILIAL+CN9_NUMERO+CN9_SITUAC
	If !CN9->(DbSeek(cFilCont+cContrat+"05"))
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	Else
		cTmpQry := GetNextAlias()
		cTipo   := Replace(cCampo,"M->","") // Retira prefixo
		cQuery  := TecGetQry(cTipo, cFilCont, cContrat)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTmpQry, .T., .T.)
		If (cTmpQry)->(EOF())
			lRet := .F.
			Help(,, 'At894Vld',, STR0108, 1, 0) //Contrato sem Uniformes informados.
		EndIf
		(cTmpQry)->(DbCloseArea())
	EndIf
ElseIf cCampo == 'M->TXD_POSTO' .And. lIntUnif
	If SuperGetMv("MV_GSITORC",,"2") == "1" .And. lMV_MultFil
		cFilCont := FwFldGet("TXD_FILTFF")
	Else
		cFilCont := cFilAnt
	EndIf
	cContrat := FwFldGet("TXD_CONTRT")
	cPosto   := FwFldGet("TXD_POSTO" )
	TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
	If !TFF->(DbSeek(cFilCont+cPosto))
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	ElseIf TFF->TFF_CONTRT<>cContrat
		lRet := .F.
		Help(,, 'At894Vld',, STR0106 + cContrat, 1, 0) //"Posto não pertence ao Contrato "
	Else
		cTmpQry := GetNextAlias()
		cTipo   := Replace(cCampo,"M->","") // Retira prefixo
		cQuery  := TecGetQry(cTipo, cFilCont, cContrat, cPosto)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTmpQry, .T., .T.)
		If (cTmpQry)->(EOF())
			lRet := .F.
			Help(,, 'At894Vld',, STR0108, 1, 0) //Contrato sem Uniformes informados.
		EndIf
		(cTmpQry)->(DbCloseArea())
	EndIf
ElseIf cCampo == 'M->TXD_QTDE' .And. lIntUnif
	If SuperGetMv("MV_GSITORC",,"2") == "1" .And. lMV_MultFil
		cFilCont := FwFldGet("TXD_FILTFF")
	Else
		cFilCont := cFilAnt
	EndIf
	cContrat := FwFldGet("TXD_CONTRT")
	cPosto   := FwFldGet("TXD_POSTO" )
	cCodProd := FwFldGet("TXD_CODPRO")
	nQtdProd := FwFldGet("TXD_QTDE"  )
	cCodTec  := FwFldGet("TXC_CODTEC")
	If nQtdProd > 0
		oModel   := FwModelActive()
		oModITUN := oModel:GetModel('TXDItens')
		nTotUnif := At894TotUnif(oModITUN, cFilCont, cContrat, cPosto, cCodProd) // Retorna Total Uniformes do Tecnico
		cTmpQry  := GetNextAlias()
		cTipo    := Replace(cCampo,"M->","") // Retira prefixo
		cQuery   := TecGetQry(cTipo, cFilCont, cContrat, cPosto, cCodProd, cCodTec) // Retorna Quantidade Vendida - Entregue
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTmpQry, .T., .T.)
		If (cTmpQry)->(EOF()) .Or. (cTmpQry)->TOTAL_QTDVEN-(cTmpQry)->TOTENT<nTotUnif
			lRet := .F.
			Help(,, 'At894Vld',, STR0107, 1, 0) //"Quantidade superior a quantidade informada no contrato"
		Else
			FWFldPut("TXD_CODTXP", (cTmpQry)->TXP_CODIGO) //Cod Unif x Orc
		EndIf
		(cTmpQry)->(DbCloseArea())
	Else
		lRet := .F.
	EndIf
EndIf

//-- RESTAURA AMBIENTE
RestArea(aAreaTWY)
RestArea(aAreaSB1)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Impr()

Imprime o termo de entrega de Uniforme

@sample	At894Impr()

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894Impr()
Local lRet      := .F.
Local cAliasQry := ''
Local oDlg      := NIL
Local oGrpBrw   := NIL
Local oBrowse   := NIL
Local aItBrowse := {{'', STR0019, STR0020, STR0021, STR0022, STR0023, STR0024, STR0025,STR0026}, {}} //'Código Produto','Descrição','Quantidade','Armazém','Dt. Entrega','Vigencia','Tp. Vigencia','Dt Validade'
Local oOk       := LoadBitmap( GetResources(), "LBOK")
Local oNo       := LoadBitmap( GetResources(), "LBNO")
Local lOk       := .F.
Local aItens    := {}
Local nCountA   := 0
Local nPosA		:= 0
Local lRHProt	:= SuperGetMv("MV_GSXINT",.F., "2") == "2"
Local cFilJoin	:= "%"+FWJoinFilial("TXC","TXD","TXC","TXD",.T.)+"%"

// -----------------------------------
// VERIFICA SE EXISTEM ITENS ENTREGUES
// AO FUNCIONARIO
// -----------------------------------
cAliasQry := GetNextAlias()
BeginSQL Alias cAliasQry
	SELECT TXD.*, AA1.AA1_NOMTEC, SRA.RA_CIC
	  FROM %Table:TXD% TXD
	  JOIN %Table:AA1% AA1
	  ON AA1.AA1_FILIAL = %xFilial:AA1%
	  AND AA1.AA1_CODTEC = TXD.TXD_CODTEC
	  AND AA1.%NotDel%
	  JOIN %Table:TXC% TXC ON
	  TXC.TXC_CODTEC = TXD.TXD_CODTEC
	  AND TXC.TXC_FILIAL = %Exp:TXC->TXC_FILIAL%
	  AND TXC.%NotDel%
	  AND %Exp:cFilJoin%
	  LEFT JOIN %Table:SRA% SRA
	  ON SRA.RA_FILIAL = AA1.AA1_FUNFIL
	  AND SRA.RA_MAT = AA1.AA1_CDFUNC
	  AND SRA.%NotDel%
	 WHERE TXD.TXD_CODTEC = %Exp:TXC->TXC_CODTEC%
	   AND TXD.TXD_DTENTR <> ' '
	   AND TXD.%NotDel%
EndSQL

lRet := (cAliasQry)->(Eof())

If lRet
	Help(,, 'At894Impr',, STR0027, 1, 0) //'Não existem itens entregues para o Funcionário. Impressão permitida somente quando existem itens entregues.'
Else

	While !(cAliasQry)->(Eof()) .And. (cAliasQry)->(TXD_FILIAL+TXD_CODTEC) == xFilial('TXD')+TXC->TXC_CODTEC
		nPosA := aScan(aItens, {|x| x[1] == (cAliasQry)->TXD_CODTEC}) 
		If nPosA == 0
			aAdd(aItens, {(cAliasQry)->TXD_CODTEC, (cAliasQry)->AA1_NOMTEC, IIF(lRHProt,  Transform((cAliasQry)->RA_CIC, PesqPict('SRA', 'RA_CIC')),""), {}})
		EndIf
		aAdd(aItBrowse[2], {.F.,;																//--[01] CHECKBOX
							(cAliasQry)->TXD_CODPRO,;													//--[02] CODIGO PRODUTO
							POSICIONE('SB1', 1, xFilial('SB1')+(cAliasQry)->TXD_CODPRO, 'B1_DESC'),;	//--[03] DESCRICAO PRODUTO
							(cAliasQry)->TXD_QTDE,;														//--[04] QUANTIDADE
							'',;																//--[05] ARMAZEM
							(cAliasQry)->TXD_DTENTR,;													//--[06] DATA DE ENTREGA DO UNIFORME
							(cAliasQry)->TXD_QTDVIG,;													//--[07] QTDE DE PERIODOS VIGENCIA
							(cAliasQry)->TXD_TIPVIG,;													//--[08] TIPO DA VIGENCIA
							(cAliasQry)->TXD_DTVAL,;													// Data de Validade
							'',;																//--[09] CODIGO DO ITEM (SB1), QUANDO INTERCAMBIAVEL
							'',;																//--[10] CODIGO PRODUTO ORIGINAL (NO CASO DA TROCA)
							'',;													//--[11] RECNO TXE
							'TXD' })															//--[12] ALIAS P/ REFERENCIA/TRATAMENTO
		(cAliasQry)->(DbSkip())
End

// -------------------------------
// MONTA INTERFACE
// -------------------------------
If Len(aItBrowse[2]) > 0
	
	//-- INTERFACE
		Define MSDialog oDlg From 000, 000 To 270, 610 Title STR0028 Of oMainWnd Pixel //"Itens para impressão"
			oGrpBrw    := TGroup():New(035, 005, 120, 300, STR0029, oDlg,,, .T.) //'Selecione os itens para Impressão'
			oBrowse    := TWBrowse():New(045, 010, 285, 070, NIL, aItBrowse[1], NIL, oGrpBrw, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	
			oBrowse:SetArray(aItBrowse[2])
			oBrowse:bLine := {|| {	If( aItBrowse[2][oBrowse:nAT, 1], oOk, oNo),;																				//-- Checkbox
										aItBrowse[2][oBrowse:nAT, 2],;																							//-- Codigo Produto
										aItBrowse[2][oBrowse:nAT, 3],;																							//-- Descricao
										aItBrowse[2][oBrowse:nAT, 4],;																							//-- Quantidade
										aItBrowse[2][oBrowse:nAT, 5],;																							//-- Armazem
										aItBrowse[2][oBrowse:nAT, 6],;																					//-- Dt. Entrega
										aItBrowse[2][oBrowse:nAT, 7],;																							//-- Qtde Periodos Vigencia
										If(aItBrowse[2][oBrowse:nAT, 8] == '1', STR0030, If(aItBrowse[2][oBrowse:nAT, 8] == '2', STR0031, STR0032))}}				//-- Tipo Vigencia
	
			oBrowse:blDblClick := {|| aItBrowse[2][oBrowse:nAt, 1] := !aItBrowse[2][oBrowse:nAt, 1], oBrowse:Refresh()}
	
		Activate MSDialog oDlg On Init EnchoiceBar(oDlg, {|| (lOk := .T., oDlg:End())}, {|| lOk := .F., oDlg:End()}) Centered
		
		If lOk  .AND. aScan(aItBrowse[2], {|x| x[1] == .T.}) > 0
			For nCountA := 1 To Len(aItBrowse[2])
				If aItBrowse[2][nCountA, 1]
					aAdd(aItens[1, 4], {	AllTrim(aItBrowse[2][nCountA, 2]),;
									AllTrim(aItBrowse[2][nCountA, 3]),;
									Transform(aItBrowse[2][nCountA, 4], PesqPict('TXD', 'TXD_QTDE')),;
									StoD(aItBrowse[2][nCountA, 9]) })
				EndIf			
			Next nCountA
			
			If ExistBlock("At894Doc")
				ExecBlock("At894Doc",.F.,.F.)
			Else	
				TECR894(aItens)
			EndIf
		EndIf
		

EndIf

	(cAliasQry)->(DbCloseArea())
	
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Mnt()

Processo de entrega, troca e devolução dos Uniformes

@sample	At894Mnt(nOpc)

@param  nOpc, Operação a ser efetuada
		1 = PROCESSO DE ENTREGA DE UNIFORMES
		2 = PROCESSO DE TROCA DE UNIFORMES
		3 = PROCESSO DE DEVOLUCAO DE UNIFORMES
		4 = PROCESSO DE TROCA - ITENS PENDENTES   
		
@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894Mnt(nOpc)
Local oDlg      	:= NIL
Local oGrpBrw   	:= NIL
Local oBrowse   	:= NIL
Local aItBrowse 	:= {}
Local oOk       	:= LoadBitmap( GetResources(), "LBOK")
Local oNo       	:= LoadBitmap( GetResources(), "LBNO")
Local lOk       	:= .F.
Local aCabec    	:= {}
Local aItens    	:= {}
Local aArrUnif		:= {}
Local nCountA   	:= 0
Local nOpcTrc   	:= 0
Local bAction   	:= {|| }
Local cTMReq    	:= TXC->TXC_TMREQ   //-- TIPO DE MOVTO INTERNO PADRAO - REQUISICAO
Local cTMDev    	:= TXC->TXC_TMDEV   //-- TIPO DE MOVTO INTERNO PADRAO - DEVOLUCAO
Local cArmUnif  	:= TXC->TXC_ARMUNI  //-- ARMAZEM PADRAO P/ UNIFORMES
Local cArmQrt   	:= TXC->TXC_ARMDEV  //-- ARMAZEM "QUARENTENA" P/ DEVOLUCAO DOS UNIFORMES
Local cCCusto		:= IIF(CampoCCusto(), TXC->TXC_CCUSTO, "" )
Local cItem			:= ""
Local cMotTroca		:= ""
Local lRHProt	    := SuperGetMv("MV_GSXINT",.F., "2") == "2"
Local cCdTec		:= POSICIONE('TXC', 1, xFilial('TXC')+TXC->TXC_CODTEC, 'TXC_CODTEC')	
Local cNomtec 		:= POSICIONE('AA1', 1, xFilial('AA1')+TXC->TXC_CODTEC, 'AA1_NOMTEC')
Local aItensImp		:= {{cCdTec,cNomtec,"" , {}}} 
Local lContCont		:= CamposCont()
Local lEndereco 	:= CmpLocali()
Local lNumSerie 	:= CmpNumSer()
Local lDevolParc 	:= CmpDevoPar() //Verifica se tem os campos para a devolução parcial
Local lAt894Cpo		:= ExistBlock("At894Cpo")
Local nQtdTroca		:= 0
Local nTrocSubst	:= 0
Local nQtdVig		:= 0
Local cTipVig		:= ""

If lDevolParc
	aItBrowse := {{'', STR0019, STR0020, "", STR0021, STR0022, STR0023, STR0024, STR0025,STR0026}, {}} //'Código Produto','Descrição','Quantidade','Armazém','Dt. Entrega','Vigencia','Tp. Vigencia','Dt Validade'
Else
	aItBrowse := {{'', STR0019, STR0020, STR0021, STR0022, STR0023, STR0024, STR0025,STR0026}, {}} //'Código Produto','Descrição','Quantidade','Armazém','Dt. Entrega','Vigencia','Tp. Vigencia','Dt Validade'
EndIf

If nOpc <> 4
	// ------------------------------------------
	// RELACIONA OS PRODUTOS P/ ENTREGA OU TROCA
	// ------------------------------------------
	If lDevolParc
		If nOpc == 1
			aItBrowse[1,4]:= STR0081 //"Qtd. entr."
		ElseIf nOpc == 2
			nTrocSubst := Aviso('', STR0082, {STR0083, STR0084}, 2) //'Realizar uma troca ou uma substituição?'##"Troca'##"Substituição"
			If nTrocSubst == 1
				aItBrowse[1,4]:= STR0085 //"Qtd. troca"
			Else
				aItBrowse[1,4]:= STR0086 //"Qtd. subst."
			EndIf
		ElseIf nOpc == 3
			aItBrowse[1,4]:= STR0087 //"Qtd. devol."
		EndIf
	EndIf	

	TXD->(DbSetOrder(1)) //--TXD_FILIAL+TXD_CODTEC+TXD_ITEM
	TXD->(DbSeek(xFilial('TXD')+TXC->TXC_CODTEC))
	While !TXD->(Eof()) .And. TXD->(TXD_FILIAL+TXD_CODTEC) == xFilial('TXD')+TXC->TXC_CODTEC
		If (nOpc == 1 .And. Empty(TXD->TXD_DTENTR) .AND. TXD->TXD_QTDE > 0) .Or.;
		((nOpc == 2 .Or. nOpc == 3) .And. !Empty(TXD->TXD_DTENTR))
			If lDevolParc
				aAdd(aItBrowse[2], {.F.,;																//--[01] CHECKBOX
									TXD->TXD_CODPRO,;													//--[02] CODIGO PRODUTO
									POSICIONE('SB1', 1, xFilial('SB1')+TXD->TXD_CODPRO, 'B1_DESC'),;	//--[03] DESCRICAO PRODUTO
									IIF(nOpc == 1,TXD->TXD_QTDE,nQtdTroca),;							//--[04] QUANTIDADE DE TROCA
									TXD->TXD_QTDE,;														//--[05] QUANTIDADE
									cArmUnif,;															//--[06] ARMAZEM
									TXD->TXD_DTENTR,;													//--[07] DATA DE ENTREGA DO UNIFORME
									TXD->TXD_QTDVIG,;													//--[08] QTDE DE PERIODOS VIGENCIA
									TXD->TXD_TIPVIG,;													//--[09] TIPO DA VIGENCIA
									'',;																//--[10] CODIGO DO ITEM (SB1), QUANDO INTERCAMBIAVEL
									'',;																//--[11] CODIGO PRODUTO ORIGINAL (NO CASO DA TROCA)
									TXD->(Recno()),;													//--[12] RECNO TXE
									'TXD',;																//--[13] ALIAS P/ REFERENCIA/TRATAMENTO	
									IIF(lContCont, TXD->TXD_CONTA, ""),;
									IIF(lContCont, TXD->TXD_ITEMCO, ""),;
									IIF(lContCont, TXD->TXD_CLVL, ""),;
									IIF(lEndereco, TXD->TXD_LOCALI, ""),;
									IIF(lNumSerie, TXD->TXD_NUMSER, "")})	
			Else
				aAdd(aItBrowse[2], {.F.,;																//--[01] CHECKBOX
								TXD->TXD_CODPRO,;													//--[02] CODIGO PRODUTO
								POSICIONE('SB1', 1, xFilial('SB1')+TXD->TXD_CODPRO, 'B1_DESC'),;	//--[03] DESCRICAO PRODUTO
								TXD->TXD_QTDE,;														//--[04] QUANTIDADE
								cArmUnif,;															//--[05] ARMAZEM
								TXD->TXD_DTENTR,;													//--[06] DATA DE ENTREGA DO UNIFORME
								TXD->TXD_QTDVIG,;													//--[07] QTDE DE PERIODOS VIGENCIA
								TXD->TXD_TIPVIG,;													//--[08] TIPO DA VIGENCIA
								'',;																//--[09] CODIGO DO ITEM (SB1), QUANDO INTERCAMBIAVEL
								'',;																//--[10] CODIGO PRODUTO ORIGINAL (NO CASO DA TROCA)
								TXD->(Recno()),;													//--[11] RECNO TXE
								'TXD',;																//--[12] ALIAS P/ REFERENCIA/TRATAMENTO	
								IIF(lContCont, TXD->TXD_CONTA, ""),;
								IIF(lContCont, TXD->TXD_ITEMCO, ""),;
								IIF(lContCont, TXD->TXD_CLVL, ""),;
								IIF(lEndereco, TXD->TXD_LOCALI, ""),;
								IIF(lNumSerie, TXD->TXD_NUMSER, "")})																

			EndIf																					
		EndIf
		TXD->(DbSkip())
	End
Else
	If lDevolParc
		aItBrowse[1,4]:= STR0081 //"Qtd. entr."	
	EndIf	
EndIf

// ------------------------------------------
// CASO SEJA DEVOLUCAO, RELACIONA TAMBEM OS
// PRODUTOS PENDENTES P/ TROCA
// ------------------------------------------
If nOpc == 3 .Or. nOpc == 4
	TXE->(DbSetOrder(1)) //--TXE_FILIAL+TXE_CODTEC+TXE_ITEM
	TXE->(DbSeek(xFilial('TXE')+TXC->TXC_CODTEC))
	While !TXE->(Eof()) .And. TXE->(TXE_FILIAL+TXE_CODTEC) == xFilial('TXE')+TXC->TXC_CODTEC
		If Empty(TXE->TXE_DTTROC)
			If lDevolParc
				aAdd(aItBrowse[2], {.F.,;																//--[01] CHECKBOX
									TXE->TXE_CODPRO,;													//--[02] CODIGO PRODUTO
									POSICIONE('SB1', 1, xFilial('SB1')+TXE->TXE_CODPRO, 'B1_DESC'),;	//--[03] DESCRICAO PRODUTO
									TXE->TXE_QTDE,;																	//--[04] QUANTIDADE DEVOLUÇÃO
									TXE->TXE_QTDE,;														//--[05] QUANTIDADE
									cArmQrt,;															//--[06] ARMAZEM
									TXE->TXE_DTGERA,;													//--[07] DATA DE ENTREGA DO UNIFORME
									0,;																	//--[08] QTDE DE PERIODOS VIGENCIA
									'',;																//--[09] TIPO DA VIGENCIA
									'',;																//--[10] CODIGO DO ITEM (SB1), QUANDO INTERCAMBIAVEL
									'',;																//--[11] CODIGO PRODUTO ORIGINAL (NO CASO DA TROCA)
									TXE->(Recno()),;													//--[12] RECNO TXE
									'TXE',;																//--[13] ALIAS P/ REFERENCIA/TRATAMENTO
									IIF(lContCont, TXE->TXE_CONTA, ""),;
									IIF(lContCont, TXE->TXE_ITEMCO, ""),;
									IIF(lContCont, TXE->TXE_CLVL, ""),;
									IIF(lEndereco, TXE->TXE_LOCALI, ""),;
									IIF(lNumSerie, TXE->TXE_NUMSER, "")})																
			Else
				aAdd(aItBrowse[2], {.F.,;																//--[01] CHECKBOX
								TXE->TXE_CODPRO,;													//--[02] CODIGO PRODUTO
								POSICIONE('SB1', 1, xFilial('SB1')+TXE->TXE_CODPRO, 'B1_DESC'),;	//--[03] DESCRICAO PRODUTO
								TXE->TXE_QTDE,;														//--[04] QUANTIDADE
								cArmQrt,;																//--[05] ARMAZEM
								TXE->TXE_DTGERA,;													//--[06] DATA DE ENTREGA DO UNIFORME
								0,;																	//--[07] QTDE DE PERIODOS VIGENCIA
								'',;																//--[08] TIPO DA VIGENCIA
								'',;																//--[09] CODIGO DO ITEM (SB1), QUANDO INTERCAMBIAVEL
								'',;																//--[10] CODIGO PRODUTO ORIGINAL (NO CASO DA TROCA)
								TXE->(Recno()),;													//--[11] RECNO TXE
								'TXE',;
								IIF(lContCont, TXE->TXE_CONTA, ""),;
								IIF(lContCont, TXE->TXE_ITEMCO, ""),;
								IIF(lContCont, TXE->TXE_CLVL, ""),;
								IIF(lEndereco, TXE->TXE_LOCALI, ""),;
								IIF(lNumSerie, TXE->TXE_NUMSER, "")})																//--[12] ALIAS P/ REFERENCIA/TRATAMENTO

			EndIf
		EndIf
		TXE->(DbSkip())
	End
EndIf

// -------------------------------
// MONTA INTERFACE
// -------------------------------
If Len(aItBrowse[2]) > 0

	If !IsBlind()
		If lDevolParc
			//-- TRATA ACAO P/ DUPLO CLICK
			If nOpc == 1
				bAction := {|| cProdInter := aItBrowse[2][oBrowse:nAT, 2], At894Camb(nOpc, oBrowse, aItBrowse), oBrowse:Refresh()}
		
			ElseIf nOpc == 2 .AND. nTrocSubst == 1
				bAction := {|| At894Edita(oBrowse,aItBrowse[2]), oBrowse:Refresh() }
			ElseIf nOpc == 2 .AND. (nTrocSubst == 0 .OR. nTrocSubst == 2)
				bAction := {|| At894Camb(nOpc, oBrowse, aItBrowse, TXC->TXC_CODTEC), oBrowse:Refresh() }
			ElseIf nOpc == 3
				bAction := {|| At894Edita(oBrowse,aItBrowse[2]), oBrowse:Refresh()}
			ElseIf nOpc == 4
				bAction := {|| aItBrowse[2][oBrowse:nAt, 1] := !aItBrowse[2][oBrowse:nAt, 1], oBrowse:Refresh()}
			EndIf
		Else
			If nOpc == 1
				bAction := {|| cProdInter := aItBrowse[2][oBrowse:nAT, 2], At894Camb(nOpc, oBrowse, aItBrowse), oBrowse:Refresh()}
			ElseIf nOpc == 2
				bAction := {|| At894Camb(nOpc, oBrowse, aItBrowse, TXC->TXC_CODTEC), oBrowse:Refresh() }
			ElseIf nOpc == 3 .Or. nOpc == 4
				bAction := {|| aItBrowse[2][oBrowse:nAt, 1] := !aItBrowse[2][oBrowse:nAt, 1], oBrowse:Refresh()}
			EndIf
		EndIf
		//-- INTERFACE
		Define MSDialog oDlg From 000, 000 To 270, 610 Title If(nOpc == 1, STR0033, If((nOpc == 2 .Or. nOpc == 4), STR0034, STR0035))  + STR0036 Of oMainWnd Pixel
			oGrpBrw    := TGroup():New(035, 005, 120, 300, STR0037 + If(nOpc == 1, STR0033, If((nOpc == 2 .Or. nOpc == 4), STR0034, STR0035)), oDlg,,, .T.)
			oBrowse    := TWBrowse():New(045, 010, 285, 070, NIL, aItBrowse[1], NIL, oGrpBrw, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )

			oBrowse:SetArray(aItBrowse[2])
			If lDevolParc
				oBrowse:bLine := {|| {	If( aItBrowse[2][oBrowse:nAT, 1], oOk, oNo),;																				//-- Checkbox
											aItBrowse[2][oBrowse:nAT, 2],;																							//-- Codigo Produto
											aItBrowse[2][oBrowse:nAT, 3],;
											aItBrowse[2][oBrowse:nAT, 4],;																							//-- Quantidade de troca
											aItBrowse[2][oBrowse:nAT, 5],;																							//-- Quantidade
											aItBrowse[2][oBrowse:nAT, 6],;																							//-- Armazem
											DtoC(aItBrowse[2][oBrowse:nAT, 7]),;																					//-- Dt. Entrega
											aItBrowse[2][oBrowse:nAT, 8],;																							//-- Qtde Periodos Vigencia
											If(aItBrowse[2][oBrowse:nAT, 9] == '1', STR0030, If(aItBrowse[2][oBrowse:nAT, 9] == '2', STR0031, STR0032))}}			//-- Tipo Vigencia
			Else
				oBrowse:bLine := {|| {	If( aItBrowse[2][oBrowse:nAT, 1], oOk, oNo),;																				//-- Checkbox
										aItBrowse[2][oBrowse:nAT, 2],;																							//-- Codigo Produto
										aItBrowse[2][oBrowse:nAT, 3],;																							//-- Descricao
										aItBrowse[2][oBrowse:nAT, 4],;																							//-- Quantidade
										aItBrowse[2][oBrowse:nAT, 5],;																							//-- Armazem
										DtoC(aItBrowse[2][oBrowse:nAT, 6]),;																					//-- Dt. Entrega
										aItBrowse[2][oBrowse:nAT, 7],;																							//-- Qtde Periodos Vigencia
										If(aItBrowse[2][oBrowse:nAT, 8] == '1', STR0030, If(aItBrowse[2][oBrowse:nAT, 8] == '2', STR0031, STR0032))}}		    //-- Tipo Vigencia
			EndIf
			oBrowse:blDblClick := bAction
		If lDevolParc
			Activate MSDialog oDlg On Init EnchoiceBar(oDlg, {|| lOk:= At894VlQnt(aItBrowse[2]), IIF(lOk, oDlg:End(),Nil)}, {|| lOk := .F., oDlg:End()}) Centered
		Else
			Activate MSDialog oDlg On Init EnchoiceBar(oDlg, {|| (lOk := .T., oDlg:End())}, {|| lOk := .F., oDlg:End()}) Centered
		EndIf
	EndIf
	// ----------------------------------
	// REALIZA O PROCESSAMENTO DA ENTREGA
	// ----------------------------------
	If aScan(aItBrowse[2], {|x| x[1] == .T.}) > 0
		If lOk .And. (nOpc == 2 .Or. nOpc == 3)
			cMotTroca := At894TGet(	nOpc, @lOk)
		EndIf
		If lOk .And. MsgYesNo(STR0038 + If(nOpc == 1, STR0033, If((nOpc == 2 .Or. nOpc == 4), STR0034, STR0035)) + STR0039)
			//-- CABECALHO DO MOVIMENTO
			aCabec := {	{"D3_DOC"		, CriaVar("D3_DOC",.T.)							, NIL},;
						{"D3_TM"		, If(nOpc  == 1 .Or. nOpc == 2, cTMReq, cTMDev)	, NIL},;
						{"D3_EMISSAO"	, dDataBase										, NIL},;
						{"D3_CC"		, cCCusto										, NIL}}


			//-- TRATA OS ITENS PARA MOVIMENTACAO:
			For nCountA := 1 To Len(aItBrowse[2])
				If aItBrowse[2][nCountA, 1]
					If lDevolParc
						AAdd(aItens, {	{"D3_COD"		, If(!Empty(aItBrowse[2][nCountA, 10]), aItBrowse[2][nCountA, 10], aItBrowse[2][nCountA, 2]), NIL},;
										{"D3_QUANT"		, aItBrowse[2][nCountA, 4], NIL},;
										{"D3_LOCAL"		, If(nOpc == 1 .Or. nOpc == 2, cArmUnif, cArmQrt), NIL},;
										{"D3_CONTA"		, aItBrowse[2][nCountA, 14]						, NIL},;
										{"D3_ITEMCTA"	, aItBrowse[2][nCountA, 15]						, NIL},; 
										{"D3_CLVL"		, aItBrowse[2][nCountA, 16]						, NIL},;
										{"D3_LOCALIZ"	, aItBrowse[2][nCountA, 17]						, NIL},;
										{"D3_NUMSERI"	, aItBrowse[2][nCountA, 18]						, NIL}})

						//-- CRIA O PRODUTO NO ARMAZEM DE QUARENTENA
						CriaSB2(If(!Empty(aItBrowse[2][nCountA, 10]), aItBrowse[2][nCountA, 10], aItBrowse[2][nCountA, 2]), cArmQrt)
						
						//Grava o Historico para troca/Devolução
						If !Empty(cMotTroca) .And. (nOpc == 2 .Or. nOpc == 3)
							At894Memo(cMotTroca,nOpc,nCountA,aItBrowse[2][nCountA, 2],TXC->TXC_CODTEC,aItBrowse[2][nCountA, 4])
						EndIf
						
						If nOpc == 1
							aAdd(aItensImp[01,04], {If(!Empty(aItBrowse[2][nCountA, 10]), aItBrowse[2][nCountA, 10], aItBrowse[2][nCountA, 2]),;
												aItBrowse[2][nCountA, 3],;
												aItBrowse[2][nCountA, 4],;
												At894Vig(dDataBase, aItBrowse[2][nCountA, 8], aItBrowse[2][nCountA, 9])})
						EndIf
					Else
						AAdd(aItens, {	{"D3_COD"		, If(!Empty(aItBrowse[2][nCountA, 9]), aItBrowse[2][nCountA, 9], aItBrowse[2][nCountA, 2]), NIL},;
									{"D3_QUANT"		, aItBrowse[2][nCountA, 4], NIL},;
									{"D3_LOCAL"		, If(nOpc == 1 .Or. nOpc == 2, cArmUnif, cArmQrt), NIL},;
									{"D3_CONTA"		, aItBrowse[2][nCountA, 13]						, NIL},;
									{"D3_ITEMCTA"	, aItBrowse[2][nCountA, 14]						, NIL},; 
									{"D3_CLVL"		, aItBrowse[2][nCountA, 15]						, NIL},;
									{"D3_LOCALIZ"	, aItBrowse[2][nCountA, 16]						, NIL},;
									{"D3_NUMSERI"	, aItBrowse[2][nCountA, 17]						, NIL}})

						//-- CRIA O PRODUTO NO ARMAZEM DE QUARENTENA
						CriaSB2(If(!Empty(aItBrowse[2][nCountA, 9]), aItBrowse[2][nCountA, 9], aItBrowse[2][nCountA, 2]), cArmQrt)
					
						//Grava o Historico para troca/Devolução
						If !Empty(cMotTroca) .And. (nOpc == 2 .Or. nOpc == 3)
							At894Memo(cMotTroca,nOpc,nCountA,aItBrowse[2][nCountA, 2],TXC->TXC_CODTEC)
						EndIf
						
						If nOpc == 1					
							aAdd(aItensImp[01,04], {If(!Empty(aItBrowse[2][nCountA, 9]), aItBrowse[2][nCountA, 9], aItBrowse[2][nCountA, 2]),;
												aItBrowse[2][nCountA, 3],;
												aItBrowse[2][nCountA, 4],;
												At894Vig(dDataBase, aItBrowse[2][nCountA, 7], aItBrowse[2][nCountA, 8])})
						EndIf
					EndIf 
				EndIf
		
			Next nCountA

			// ---------------------
			// PROCESSA MOVIMENTACAO
			// ---------------------
			If lAt894Cpo
				aArrUnif := ExecBlock("At894Cpo",.F.,.F.,{aCabec,aItens,nOpc})
			EndIf
		
			Begin Transaction
				lMSErroAuto := .F.
				If lAt894Cpo
					MsgRun(STR0040, STR0041,;
						{|| MSExecAuto({|x,y| MATA241(x,y)}, aArrUnif[1], aArrUnif[2])}) //'Realizando movimentação....', 'Aguarde...'
				Else
					MsgRun(STR0040, STR0041,;
						{|| MSExecAuto({|x,y| MATA241(x,y)}, aCabec, aItens)}) //'Realizando movimentação....', 'Aguarde...'
				EndIf				

				If lMSErroAuto
					DisarmTransaction()
					Help(,, 'At894Entr',, STR0042, 1, 0)//'Ocorreu um erro ao processar Requisição!'
					MostraErro()
				Else
					// --------------------------------------------------
					// PARA TROCA, VERIFICA SE PROCESSA ENTRADA DOS ITENS
					// --------------------------------------------------
					If nOpc == 2
						nOpcTrc := Aviso(STR0034, STR0043, {STR0044, STR0045}, 2)//'Indique o tratamento para os itens que estão sendo trocados','Realizar Recebimento','Deixar Troca Pendente'
						If nOpcTrc == 1
							//-- CABECALHO DO MOVIMENTO
							aCabec := {	{"D3_DOC"		, CriaVar("D3_DOC",.T.)	, NIL},;
										{"D3_TM"		, cTMDev				, NIL},;
										{"D3_EMISSAO"	, dDataBase				, NIL},;
										{"D3_CC"		, cCCusto				, NIL} }

							aItens := {}
							For nCountA := 1 To Len(aItBrowse[2])
								If aItBrowse[2][nCountA, 1]
									If lDevolParc
										AAdd(aItens, {	{"D3_COD"		, If(!Empty(aItBrowse[2][nCountA, 11]), aItBrowse[2][nCountA, 11], aItBrowse[2][nCountA, 2])	, NIL},;
														{"D3_QUANT"		, aItBrowse[2][nCountA, 04] , NIL},;
														{"D3_LOCAL"		, cArmQrt					, NIL},;
														{"D3_CONTA"		, aItBrowse[2][nCountA, 14]						, NIL},;
														{"D3_ITEMCTA"	, aItBrowse[2][nCountA, 15]						, NIL},; 
														{"D3_CLVL"		, aItBrowse[2][nCountA, 16]						, NIL},;
														{"D3_LOCALIZ"	, aItBrowse[2][nCountA, 17]						, NIL},;
														{"D3_NUMSERI"	, aItBrowse[2][nCountA, 18]						, NIL}})
									Else
										AAdd(aItens, {	{"D3_COD"		, aItBrowse[2][nCountA, 10]	, NIL},;
													{"D3_QUANT"		, aItBrowse[2][nCountA, 04]	, NIL},;
													{"D3_LOCAL"		, cArmQrt					, NIL},;
													{"D3_CONTA"		, aItBrowse[2][nCountA, 13]						, NIL},;
													{"D3_ITEMCTA"	, aItBrowse[2][nCountA, 14]						, NIL},; 
													{"D3_CLVL"		, aItBrowse[2][nCountA, 15]						, NIL},;
													{"D3_LOCALIZ"	, aItBrowse[2][nCountA, 16]						, NIL},;
													{"D3_NUMSERI"	, aItBrowse[2][nCountA, 17]						, NIL}})
									EndIf 
								EndIf
							Next nCountA

							// ---------------------
							// PROCESSA MOVIMENTACAO
							// ---------------------
							If lAt894Cpo
								aArrUnif := ExecBlock("At894Cpo",.F.,.F.,{aCabec,aItens,nOpc})
							EndIf

							lMSErroAuto := .F.
							If lAt894Cpo
								MsgRun(STR0040, STR0041,;
									{|| MSExecAuto({|x,y| MATA241(x,y)}, aArrUnif[1], aArrUnif[2])}) //'Realizando movimentação....', 'Aguarde...'
							Else
								MsgRun(STR0040, STR0041,;
									{|| MSExecAuto({|x,y| MATA241(x,y)}, aCabec, aItens)}) //'Realizando movimentação....', 'Aguarde...'
							EndIf	

							If lMSErroAuto
								DisarmTransaction()
								Help(,, 'At894Entr',, STR0042, 1, 0)
								MostraErro()
							EndIf
							
						ElseIf nOpcTrc == 2
							//-- GERA REGISTRO DE TROCA PENDENTE
							For nCountA := 1 To Len(aItBrowse[2])
								If aItBrowse[2][nCountA, 1]
									cItem := NumItem( TXC->TXC_CODTEC )
									If lDevolParc
										TXD->(DbGoTo(aItBrowse[2][nCountA, 12]))
									Else
										TXD->(DbGoTo(aItBrowse[2][nCountA, 11]))
									EndIf 	
									RecLock('TXE', .T.)
									TXE->TXE_FILIAL := xFilial('TXE')
									TXE->TXE_CODTEC := TXC->TXC_CODTEC
									TXE->TXE_ITEM   := cItem
									If lDevolParc
										TXE->TXE_CODPRO := If(!Empty(aItBrowse[2][nCountA, 11]), aItBrowse[2][nCountA, 11], aItBrowse[2][nCountA, 2])
									Else
										TXE->TXE_CODPRO := aItBrowse[2][nCountA, 10]
									EndIf

									TXE->TXE_QTDE   := aItBrowse[2][nCountA, 04]
									TXE->TXE_DTGERA := dDataBase
									If lDevolParc
										If lContCont
											TXE->TXE_CONTA	:= aItBrowse[2][nCountA, 14]
											TXE->TXE_ITEMCO	:= aItBrowse[2][nCountA, 15]
											TXE->TXE_CLVL	:= aItBrowse[2][nCountA, 16]
										EndIf
										If lEndereco
											TXE->TXE_LOCALI	:= aItBrowse[2][nCountA, 17]
										EndIf
										If lNumSerie
											TXE->TXE_NUMSER	:= aItBrowse[2][nCountA, 18]
										EndIf	
									Else
										If lContCont
											TXE->TXE_CONTA	:= aItBrowse[2][nCountA, 13]
											TXE->TXE_ITEMCO	:= aItBrowse[2][nCountA, 14]
											TXE->TXE_CLVL	:= aItBrowse[2][nCountA, 15]
										EndIf
										If lEndereco
											TXE->TXE_LOCALI	:= aItBrowse[2][nCountA, 16]
										EndIf
										If lNumSerie
											TXE->TXE_NUMSER	:= aItBrowse[2][nCountA, 17]
										EndIf
									EndIf 

									TXE->(MsUnLock())
								EndIf
							Next nCountA
						EndIf
					ElseIf nOpc == 3 .Or. nOpc == 4
						//-- GERA REGISTRO DE TROCA PENDENTE
						For nCountA := 1 To Len(aItBrowse[2])
							If lDevolParc
								If aItBrowse[2][nCountA, 1] .And. aItBrowse[2][nCountA, 13] == 'TXE'
									TXE->(DbGoTo(aItBrowse[2][nCountA, 12]))
									RecLock('TXE', .F.)
									TXE->TXE_DTTROC := dDataBase
									TXE->(MsUnLock())
								EndIf
							Else
								If aItBrowse[2][nCountA, 1] .And. aItBrowse[2][nCountA, 12] == 'TXE'
									TXE->(DbGoTo(aItBrowse[2][nCountA, 11]))
									RecLock('TXE', .F.)
									TXE->TXE_DTTROC := dDataBase
									TXE->(MsUnLock())
								EndIf
							EndIf 	
						Next nCountA
					EndIf

					// --------------------------------
					// ATUALIZA SOLICITACAO DE UNIFORME
					// --------------------------------
					If nOpc <> 4
						For nCountA := 1 To Len(aItBrowse[2])
							If aItBrowse[2][nCountA, 1]
								If lDevolParc
									If nTrocSubst == 0 .Or. aItBrowse[2][nCountA, 04] == aItBrowse[2][nCountA, 05]
										TXD->(DbGoTo(aItBrowse[2][nCountA, 12]))
										cCodTec:= TXD->TXD_CODTEC
										cItem:= MAXITEMTXD(cCodTec)
										cItem:= Soma1(cItem)
										RecLock('TXD', .F.)
										If nTrocSubst == 2
											TXD->TXD_CODPRO:= aItBrowse[2][nCountA, 2]
										ElseIf nTrocSubst == 0 .And. nOpc == 1
											TXD->TXD_CODPRO := If(!Empty(aItBrowse[2][nCountA, 10]), aItBrowse[2][nCountA, 10], aItBrowse[2][nCountA, 2])
										Else
											TXD->TXD_CODPRO := If(!Empty(aItBrowse[2][nCountA, 11]), aItBrowse[2][nCountA, 11], aItBrowse[2][nCountA, 2])
										EndIf
										
										If nOpc <> 3
											TXD->TXD_DTENTR := If(nOpc == 1 .Or. nOpc == 2, dDataBase, CtoD(Space(08)))
											TXD->TXD_DTVAL  := If(nOpc == 1 .Or. nOpc == 2, At894Vig(dDataBase, TXD->TXD_QTDVIG, TXD->TXD_TIPVIG), CtoD(Space(08)))

											If TXD->TXD_DEVOL <> 0
												TXD->TXD_DEVOL := 0
											EndIf
										Else
											//Verifica se a quantidade devolvida é a mesma da quantidade entregue
											If aItBrowse[2][nCountA, 4] = aItBrowse[2][nCountA, 5]
												TXD->TXD_DTENTR := If(nOpc == 1 .Or. nOpc == 2, dDataBase, CtoD(Space(08)))
												TXD->TXD_DTVAL  := If(nOpc == 1 .Or. nOpc == 2, At894Vig(dDataBase, TXD->TXD_QTDVIG, TXD->TXD_TIPVIG), CtoD(Space(08)))
												
												//Restaura a quantidade do uniforme
												TXD->TXD_QTDE	:= TXD->TXD_QTDE + TXD->TXD_DEVOL
												TXD->TXD_DEVOL	:= TXD->TXD_QTDE	
											Else
												TXD->TXD_QTDE	:= aItBrowse[2][nCountA, 5] - aItBrowse[2][nCountA, 4]
												TXD->TXD_DEVOL	:= aItBrowse[2][nCountA, 4]	+ TXD->TXD_DEVOL								
											EndIf
										EndIf 
									Else
										//Atualiza a quantidade do produto substituido/trocado
										TXD->(DbGoTo(aItBrowse[2][nCountA, 12]))
										RecLock('TXD', .F.)
											TXD->TXD_QTDE	:= aItBrowse[2][nCountA, 5] - aItBrowse[2][nCountA, 4]

											cCodTec:= TXD->TXD_CODTEC
											cItem:= MAXITEMTXD(cCodTec)
											cItem:= Soma1(cItem)
											nQtdVig := TXD->TXD_QTDVIG
											cTipVig := TXD->TXD_TIPVIG

										TXD->(MsUnLock())
										
										//cria a nova linha
										RecLock('TXD', .T.)
											TXD->TXD_FILIAL	:= xFilial("TXD")
											TXD->TXD_CODTEC	:= cCodTec
											TXD->TXD_ITEM	:= cItem
											TXD->TXD_CODPRO:= aItBrowse[2][nCountA, 2]					
											TXD->TXD_DTENTR := dDataBase
											TXD->TXD_QTDE	:= aItBrowse[2][nCountA, 4]

											TXD->TXD_QTDVIG := nQtdVig
											TXD->TXD_TIPVIG := cTipVig
											TXD->TXD_DTENTR := If(nOpc == 1 .Or. nOpc == 2, dDataBase, CtoD(Space(08)))
											TXD->TXD_DTVAL  := If(nOpc == 1 .Or. nOpc == 2, At894Vig(dDataBase, nQtdVig, cTipVig), CtoD(Space(08)))

									EndIf 

									TXD->(MsUnLock())

									If nOpc == 4
										RecLock('TXD', .T.)
										TXD->TXD_FILIAL	:= xFilial("TXD")
										TXD->TXD_CODTEC	:= cCodTec
										TXD->TXD_ITEM	:= cItem
										If nTrocSubst == 2
											TXD->TXD_CODPRO:= aItBrowse[2][nCountA, 2]
										Else
											TXD->TXD_CODPRO := If(!Empty(aItBrowse[2][nCountA, 10]), aItBrowse[2][nCountA, 10], aItBrowse[2][nCountA, 2])
										EndIf
										TXD->TXD_DTENTR := If(nOpc == 1 .Or. nOpc == 2, dDataBase, CtoD(Space(08)))
										TXD->TXD_QTDE	:= aItBrowse[2][nCountA, 4]
										TXD->(MsUnLock())
									EndIf
								Else
									TXD->(DbGoTo(aItBrowse[2][nCountA, 11]))
									RecLock('TXD', .F.)
									TXD->TXD_CODPRO := If(!Empty(aItBrowse[2][nCountA, 9]), aItBrowse[2][nCountA, 9], aItBrowse[2][nCountA, 2])
									TXD->TXD_DTENTR := If(nOpc == 1 .Or. nOpc == 2, dDataBase, CtoD(Space(08)))
									TXD->TXD_DTVAL  := If(nOpc == 1 .Or. nOpc == 2, At894Vig(dDataBase, TXD->TXD_QTDVIG, TXD->TXD_TIPVIG), CtoD(Space(08)))
									TXD->(MsUnLock())
								EndIf 
							EndIf
						Next nCountA

						If nOpc == 1 .and. Len(aItensImp[01,04]) > 0
							If MsgYesNo(STR0046)//'Deseja realizar a impressão do Termo de Entrega?'
								If lRHProt
									aItensImp[01,03] :=  Transform(GetAdvFVal("SRA", "RA_CIC", xFilial("SRA")+aItensImp[01,01], 1, ""), PesqPict('SRA', 'RA_CIC'))
								EndIf		

								If ExistBlock("At894Doc")
									ExecBlock("At894Doc",.F.,.F.)
								Else	
									TECR894(aItensImp)
								EndIf
							EndIf
						EndIf
					EndIf
					MsgInfo(STR0047, STR0048)//'Processo concluído!','Entrega Uniforme'
				EndIf
			End Transaction
		EndIf
	Else
		If lOk
			Help(,, 'At894Entr',, STR0049 + If(nOpc == 1, STR0033, If(nOpc == 2, STR0034, STR0035)) + STR0050, 1, 0)
		EndIf
	EndIf
Else
	Help(,, 'At894Entr',, STR0051 + If(nOpc == 1, STR0033, If(nOpc == 2, STR0034, STR0035)) + STR0052, 1, 0)
EndIf

//-> Ponto de Entrada para tratamentos especificos apos o processamento de Entrega, Troca ou Devolução de uniformes.
//-> Disponibiliza itens tratados na operação e numero da operação selecionada pelo usuario.
If ExistBlock("At894Uni")
	ExecBlock("At894Uni",.F.,.F.,{aItBrowse,nOpc})
EndIf

//Limpa o array para historico
aPrdTroc	:= {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Camb()
Verifica se o item é Intercambiavel e solicita o produto a ser
Considerado na movimentação

@sample	At894Camb(nOpc, oBrowse, aItBrowse)

@param  nOpc, Operação que está sendo realizada
@param  oBrowse, Objeto do Browse
@param  aItBrowse, Item do browse

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At894Camb(nOpc, oBrowse, aItBrowse, cCodTec)
Local oDlg    		:= NIL
Local oGrpProd		:= NIL
Local oGetProd		:= NIL
Local oGetQnt		:= Nil
Local oBtnOk  		:= NIL
Local oBtnCanc		:= NIL
Local lOk     		:= .F.
Local cProduto		:= If(nOpc == 1, Space(Len(SB1->B1_COD)), aItBrowse[2][oBrowse:nAt, 2])
Local cMsg			:= STR0069 // "Não é possível realizar a troca deste item pois o mesmo já foi realizado a troca e esta como pendente."
Local nQuant		:= 0
Local lDevolParc	:= CmpDevoPar() //Verifica se tem os campos para a devolução parcial

Default cCodTec	:= ""

If nOpc == 1 
	If !aItBrowse[2][oBrowse:nAt, 1]
		TWY->(DbSetOrder(1)) //--TWY_FILIAL+TWY_CODPRO+TWY_CODINT+TWY_ITEM
		If TWY->(DbSeek(xFilial('TWY')+aItBrowse[2][oBrowse:nAt, 2]))
			If !IsBlind()
				Define MSDialog oDlg From 000, 000 To 160, 330 Pixel Title STR0053
					oGrpProd := TGroup():New(005, 002, 030, 100, '', oDlg,,, .T.)
					oGetProd := TGet():New(013, 005, {|u| If(PCount() > 0, cProduto := u, cProduto)}, oGrpProd, 050, 010, '@!',;
													{|| !Empty(cProduto) .And. At894Vld('cPrdInter', aItBrowse[2][oBrowse:nAt, 2], cProduto )},,, TFont():New('Courier New', 0, -12, .F., .T.), .F.,, .T.,, .F.,;
													{|| .T.}, .F., .F.,, .F., .F.)
		
					oGetProd:cF3 := 'PRDINT'
		
					oBtnOk    	:=  TButton():New( 010, 110, STR0054,oDlg,{|| lOk := .T., oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"							
					oBtnCanc 	:= TButton():New(025, 110, STR0055, oDlg, {|| lOk := .F., oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //'Cancelar'
		
				Activate MSDialog oDlg Centered
			EndIF
	
			If lOk
				If lDevolParc
					Aadd(aPrdTroc,{oBrowse:nAt,aItBrowse[2][oBrowse:nAt, 10]})
					aItBrowse[2][oBrowse:nAt, 01] := !aItBrowse[2][oBrowse:nAt, 1]
					aItBrowse[2][oBrowse:nAt, 10] := cProduto
				Else
					Aadd(aPrdTroc,{oBrowse:nAt,aItBrowse[2][oBrowse:nAt, 09]})
					aItBrowse[2][oBrowse:nAt, 01] := !aItBrowse[2][oBrowse:nAt, 1]
					aItBrowse[2][oBrowse:nAt, 09] := cProduto
				EndIf	
			EndIf
	
		Else
			aItBrowse[2][oBrowse:nAt,1] := !aItBrowse[2][oBrowse:nAt,1]
		EndIf
	Else
		aItBrowse[2][oBrowse:nAt,1] := !aItBrowse[2][oBrowse:nAt,1]
	EndIf
ElseIf nOpc == 2 .And. !aItBrowse[2][oBrowse:nAt, 1]
	If !IsBlind()
		Define MSDialog oDlg From 000, 000 To 120, 330 Pixel Title STR0056
			oGrpProd := TGroup():New(005, 002, 030, 100, '', oDlg,,, .T.)
			oGetProd := TGet():New(013, 005, {|u| If(PCount() > 0, cProduto := u, cProduto)}, oGrpProd, 080, 010, '@!',;
									{|| !Empty(cProduto) .And. At894Vld('cProduto', cProduto)},,, TFont():New('Courier New', 0, -12, .F., .T.), .F.,, .T.,, .F.,;
									{|| .T.}, .F., .F.,, .F., .F.)
			If lDevolParc
				oGetQnt := TGet():New(033, 005, {|u| If(PCount() > 0, nQuant := u, nQuant)}, oGrpProd, 080, 010, "@ER 999,999",;
														{|| nQuant > 0 .And. At894Quant(aItBrowse[2][oBrowse:nAt, 05],nQuant,aItBrowse[2][oBrowse:nAt, 02])},,, TFont():New('Courier New', 0, -12, .F., .T.), .F.,, .T.,, .F.,;
														{|| .T.}, .F., .F.,, .F., .F.)														
			EndIf 
				oGetProd:cF3 := 'SB1UNI'
				oBtnOk   := TButton():New(010, 110, STR0054, oDlg, {|| lOk := .T., oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
				oBtnCanc := TButton():New(025, 110, STR0055, oDlg, {|| lOk := .F., oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
	
			Activate MSDialog oDlg Centered
	EndIf

		If lOk
			If !lDevolParc .And. !At894VerPr( cCodTec, cProduto, @cMsg )
				Help(,, 'At894Vld',, cMsg, 1, 0)
			Else
				Aadd(aPrdTroc,{oBrowse:nAt,aItBrowse[2][oBrowse:nAt, 02]})
				aItBrowse[2][oBrowse:nAt, 01] := !aItBrowse[2][oBrowse:nAt, 1]
				If lDevolParc
					aItBrowse[2][oBrowse:nAt, 04] := nQuant
					aItBrowse[2][oBrowse:nAt, 11] := aItBrowse[2][oBrowse:nAt, 02]	
				Else	
					aItBrowse[2][oBrowse:nAt, 10] := aItBrowse[2][oBrowse:nAt, 02]
				EndIf	
				aItBrowse[2][oBrowse:nAt, 02] := cProduto
				aItBrowse[2][oBrowse:nAt, 03] := Posicione('SB1', 1, xFilial('SB1')+cProduto, 'B1_DESC')
			EndIf
		EndIf
Else
	If lDevolParc
		aItBrowse[2][oBrowse:nAt, 01] := !aItBrowse[2][oBrowse:nAt, 1]
		aItBrowse[2][oBrowse:nAt, 10] := ''
		aItBrowse[2][oBrowse:nAt, 02] := aItBrowse[2][oBrowse:nAt, 11]
		aItBrowse[2][oBrowse:nAt, 03] := Posicione('SB1', 1, xFilial('SB1')+aItBrowse[2][oBrowse:nAt, 02], 'B1_DESC')

	Else
		aItBrowse[2][oBrowse:nAt, 01] := !aItBrowse[2][oBrowse:nAt, 1]
		aItBrowse[2][oBrowse:nAt, 09] := ''
		aItBrowse[2][oBrowse:nAt, 02] := aItBrowse[2][oBrowse:nAt, 10]
		aItBrowse[2][oBrowse:nAt, 03] := Posicione('SB1', 1, xFilial('SB1')+aItBrowse[2][oBrowse:nAt, 02], 'B1_DESC')
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894F3()
Consulta padrão dos produtos Intercambiaveis
Função Utilizada na Consulta padrão(SXB) "PRDINT"

@sample	At894F3()

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894F3()
Local aCabec   := {}
Local aItens   := {}
Local nRet     := 0
Local lRet     := .F.

aAdd(aCabec, STR0057)//'Produto'
aAdd(aCabec, STR0058)//'Descrição'

TWY->(DbSetOrder(1)) //--TWY_FILIAL+TWY_CODPRO+TWY_CODINT+TWY_ITEM
If TWY->(DbSeek(xFilial('TWY')+cProdInter))
	While !TWY->(Eof()) .And. TWY->(TWY_FILIAL+TWY_CODPRO) == xFilial('TWY')+cProdInter
		aAdd(aItens, {	TWY->TWY_CODINT,;
						Posicione('SB1', 1, xFilial('SB1')+TWY->TWY_CODINT, 'B1_DESC')})
		TWY->(DbSkip())
	End
	If !IsBlind()
		nRet := TmsF3Array(aCabec, aItens, STR0059, .T.,, aCabec)//'Produtos Intercambiáveis'
	EndIf
	If nRet <> 0
		lRet := .T.
		VAR_IXB := aItens[nRet, 1]
	EndIf

EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Vig()
Calcula a data de vigencia do uniforme a partir da data de entrega

@sample	At894Vig(dDtEntr, nQtdVig, cTpVig)

@param  dDtEntr, Data de Entrega
@param  nQtdVig, Quantidade da Vigencia
@param  cTpVig, Tipo da Vigencia(Ano,Mes,Dias)

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894Vig(dDtEntr, nQtdVig, cTpVig)
Local dDtValid := CtoD(Space(08))
Local oModel   := FWLoadModel('TECA894')

Default dDtEntr := oModel:GetValue('TXD_DTENTR')
Default nQtdVig := oModel:GetVAlue('TXD_QTDVIG')
Default cTpVig  := oModel:GetValue('TXD_TIPVIG')

If cTpVig == '1' //-- DIAS
	dDtValid := dDtEntr + nQtdVig

ElseIf cTpVig == '2' //-- MESES
	dDtValid := MonthSum(dDtEntr, nQtdVig)

ElseIf cTpVig == '3' //-- ANOS
	dDtValid := YearSum(dDtEntr, nQtdVig)

EndIf

Return(dDtValid)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Filt()
Retorna expressão de filtro para a consulta padrão de Produtos
Função utilizada na consulta padrão SB1UNI

@sample	At894Filt()

@since		11/06/2019
@version	P12.1.23  //A partir da 12.1.31 essa função pode ser retirada
/*/
//------------------------------------------------------------------------------
Function At894Filt()
Local lRet    := .T.
Local aTpUnif := StrTokArr(SuperGetMV('MV_TPUNIF',, 'UN;'), ';') 	//-- TIPOS DE PRODUTO CORRESPONDENTE AOS UNIFORMES
Local nPosA   := 0

nPosA := aScan(aTpUnif, SB1->B1_TIPO)
If nPosA == 0
	lRet := .F.
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894TGet()
Função para informar o motivo da troca/Substituição de um item do uniforme

@sample	At894TGet()

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894TGet(nOpc, lOk)
Local oDlg	:= Nil
Local oGet1	:= Nil
Local cMotTroca := Space(500)

Default lOk := .T.

If !IsBlind()
	Define MSDialog oDlg From 000, 000 To 120, 330 Pixel Title If(nOpc == 2, STR0060, STR0068) //"Motivo da Devolução"
		oGet1 := tMultiget():new( 005, 009, {| u | if( pCount() > 0, cMotTroca := u, cMotTroca ) },;
				oDlg, 100, 050,,,,,, .T. , , , , , , , , , , , .T. , , , ,  )
		oBtnOk    :=  TButton():New( 005, 110, STR0054,oDlg,{|| lOk := .T., oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )							
		oBtnCanc := TButton():New(020, 110, STR0055, oDlg, {|| lOk := .F., cMotTroca := "", oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	Activate MSDialog oDlg Centered
EndIf
If Empty(cMotTroca)
	cMotTroca := At894dMsgM( cMotTroca, nOpc )
EndIf

Return cMotTroca

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Memo()
Função para gravar o motivo e os itens de historico das movimentações feitas

@sample	At894Memo(cTGet1,nTipo,nPos,cProdut,cCodTec)

@param  cTGet1, Campo com o motivo da troca/Substituição
@param  nTipo, Tipo da movimentação 2=Troca e 3= Devolução
@param  nPos, Posição do produto no array - Usado para achar o produto a ser trocado
@param  cProdut, Produto Novo- Produto que está sendo entregue
@param  cCodTec, Codigo do atendente 

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894Memo(cTGet1,nTipo,nPos,cProdut,cCodTec,nQuant)
Local nPosA			:= 0 //variavel utilizada para achar prosição do produto que está sendo trocado
Local lDevolParc	:= CmpDevoPar() //Verifica se tem os campos para a devolução parcial

Default nQuant := 0

nPosA := aScan(aPrdTroc, {|x| x[1] == nPos})

If nPosA > 0 .Or. nTipo == 3
	DbSelectArea("TXF")
	RecLock("TXF", .T.)	
		TXF->TXF_FILIAL := xFilial("TXF")
		TXF->TXF_CODIGO := GetSXENUM("TXF","TXF_CODIGO")
		TXF->TXF_CODTEC	:= cCodTec	
		TXF->TXF_TIPO	:= cValToChar(nTipo)
		If nTipo == 2
			TXF->TXF_PRDANT := aPrdTroc[nPosA][02] //Grava codigo do produto a ser trocado
			TXF->TXF_PRDNOV := cProdut             //Grava codigo do produto a ser entregue
		Else
			If nTipo == 3 .And. lDevolParc
				TXF->TXF_DEVOL:= nQuant
			EndIf
			TXF->TXF_PRDDEV := cProdut             //Grava codigo do produto devolvido
		EndIf
		TXF->TXF_MOTIVO := Rtrim(cTGet1)
		TXF->TXF_USR	:= __cUserId
		TXF->TXF_DATA	:= dDataBase
	MsUnLock() // Confirma e finaliza a operação
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894VlReq()
Função para validar os campos de Tipo de movimento

@sample	At894VlReq(cCodReq,cTipo)

@param  cCodReq, Codigo do tipo de movimento a ser validado
@param  cTipo, Tipo da movimentação "Req" - Requisição - "DEV" - Devolução

@since		11/06/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At894VlReq(cCodReq,cTipo)
Local lRet	:= .F.
Local aArea	:= {}

If ExistCpo("SF5",cCodReq)
	aArea := SF5->(GetArea())
	DbSelectArea("SF5")
	SF5->(DbSetOrder(1))
	If SF5->(DbSeek(xFilial("SF5")+cCodReq)) 
		If SF5->F5_TIPO == "R" .And. cTipo == "REQ"
			lRet := .T.
		ElseIf SF5->F5_TIPO == "D" .And. cTipo == "DEV"
			lRet := .T.	
		EndIf
	EndIf
	If !lRet
		Help(,, 'At894Entr',, STR0061 + If(cTipo == "REQ", STR0062, STR0063) + STR0064, 1, 0) //'O tipo de movimento deve ser de '
	EndIf
	RestArea(aArea)
Else	
	Help('', 1, 'REGNOIS')
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894VerPr

@Verificação para saber se o item selecionado para troca esta como troca pendente
ou está/foi entregue para o funcionario

@author	Augusto Albuquerque
@since	20/01/2020
/*/
//------------------------------------------------------------------------------
Function At894VerPr( cCodTec, cProduto, cMsg )
Local cAlias	:= GetNextAlias()
Local lRet		:= .T.

BEGINSQL Alias cAlias
	SELECT COUNT (*) CONT
	FROM %Table:TXD% TXD
	WHERE TXD.TXD_FILIAL = %xFilial:TXD%
		AND TXD.TXD_CODTEC = %Exp:cCodTec%
		AND TXD.TXD_CODPRO = %Exp:cProduto%
		AND TXD.%NotDel%
EndSQL

lRet := ((cAlias)->CONT == 0)
(cAlias)->(DbCloseArea())

If lRet
	cAlias	:= GetNextAlias()
	BEGINSQL Alias cAlias
		SELECT COUNT (*) CONT
		FROM %Table:TXE% TXE
		WHERE TXE.TXE_FILIAL = %xFilial:TXE%
			AND TXE.TXE_CODTEC = %Exp:cCodTec%
			AND TXE.TXE_CODPRO = %Exp:cProduto%
			AND TXE.TXE_DTTROC = %Exp:""%
			AND TXE.%NotDel%
	EndSQL

	lRet := ((cAlias)->CONT == 0)
	(cAlias)->(DbCloseArea())
Else
	cMsg := STR0070 // "Não é possivel fazer a troca para um item no qual ja esta na lista do Funcionario." 
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} NumItem

@description Utilizado para pegar o proximo codigo na tabela TXE, usado como chave

@author	Augusto Albuquerque
@since	20/01/2020
/*/
//------------------------------------------------------------------------------
Static Function NumItem( cCodTec )
Local cAliasTXE	:= GetNextAlias()
Local cRet		:= ""

BEGINSQL Alias cAliasTXE
	SELECT MAX (TXE.TXE_ITEM) CONT
	FROM %Table:TXE% TXE
	WHERE TXE.TXE_FILIAL = %xFilial:TXE%
		AND TXE.TXE_CODTEC = %Exp:cCodTec%
		AND TXE.%NotDel%
EndSQL

If (cAliasTXE)->(!EOF())
	cRet := Soma1((cAliasTXE)->CONT)
EndIf
(cAliasTXE)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894Excl

@description Utilziada para dar execview como delete, para deletar corretamente
os registros na tabela.

@author	boiani
@since	20/01/2020
/*/
//------------------------------------------------------------------------------
Function At894Excl()

Local lRet := .F.
If !IsBlind()
	lRet := ( FWExecView( STR0001, "VIEWDEF.TECA894", MODEL_OPERATION_DELETE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;   //'Controle de Uniformes'
											{||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ,,,) == 0 )
EndIF
//-> Ponto de Entrada para tratamentos especificos apos a exclusao da requisicao de uniformes.
//-> Disponibiliza os RECNOS dos registros das principais tabelas tratadas nesse processo.
If ExistBlock("Ex894Req")
	ExecBlock("Ex894Req",.F.,.F.,{If(TXC->(!EOF()), TXC->(RECNO()), 0) /*Cabecalho Gestao de Uniforme*/,;
								  If(TXD->(!EOF()), TXD->(RECNO()), 0) /*Itens Gestao de Uniformes*/,;
								  If(TXE->(!EOF()), TXE->(RECNO()), 0) /*Itens Troca Gestao de Uniforme*/})
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At894dMsgM

@description Mensagem inserida nas manutenções da agenda

@author	Augusto Albuquerque
@since	20/01/2020
/*/
//------------------------------------------------------------------------------
Function At894dMsgM( nOpc, cMotivo)
Local cRet := ""
If nOpc == "2"
	cRet := STR0071 // "Processo de Troca incluída."
Else
	cRet := STR0072 // "Processo de Devolução incluída."
EndIf
 cRet +=	CRLF + STR0073 + __cUserID + CRLF +;	//"Usuário: "
			STR0074 + dToC(Date()) + CRLF +;	//"Data da inclusão: "
			STR0075 + Time()	//"Horário da inclusão: "
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TEC894FACI
Função de validação para realizar a caraga dos dados nas abas

@author Filipe Gonçalves
@since 01/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function TEC894FACI(oModLoc)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oModCab		:= oModel:GetModel('TXCMaster')
Local oModITUN		:= oModel:GetModel('TXDItens')
Local oStruTXL 	 	:= FWFormStruct(2, "TXL" , {|cCampo| !AllTrim(cCampo)$ "TXL_CODTEC"},NIL )
Local oSubView		:= FwFormView():New(oModel)
Local lRet			:= .T.
Local oModTXL		:= oModel:GetModel('TXLDETAIL')
Local oMdlFac 		:= Nil
Local oMdlFacUN 	:= Nil
Local cCodFac		:= ""
Local cItem 		:= Replicate("0", TamSx3("TXD_ITEM")[1]  )
Local nY			:= 0
Local nX 			:= 0
Local nQuant		:= 0

If !Empty(oModCab:GetValue("TXC_CODTEC"))

	//Cria uma subView para chamar na tela flutuante
	oSubView:SetModel(oModel)
	oSubView:CreateHorizontalBox('POPBOX',100)
	oSubView:AddGrid('VIEW_TXL',oStruTXL,'TXLDETAIL')
	oSubView:AddIncrementField('VIEW_TXL', 'TXL_ITEM')
	oSubView:SetOwnerView('VIEW_TXL','POPBOX')

	TECXFPOPUP(oModel,oSubView, STR0076, MODEL_OPERATION_UPDATE, 70 ) //"Facilitador"

	If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() ==  MODEL_OPERATION_INSERT

		For nX := 1 To oModTXL:Length()
			oModTXL:GoLine( nX )
			If !Empty(oModTXL:GetValue('TXL_CODFAC')) .And. (oModTXL:GetValue('TXL_QUANT') > 0 ) .And. At894VldFa(oModTXL:GetValue('TXL_CODFAC'),oModCab:GetValue("TXC_CODTEC"),oModTXL:GetValue('TXL_QUANT'))
				cCodFac := oModTXL:GetValue('TXL_CODFAC')
				nQuant := oModTXL:GetValue('TXL_QUANT')
				TWM->(dbSetOrder(1))//TWN_FILIAL+TWN_CODTWM
				TWM->(dbSeek(xFilial("TWM") + cCodFac)) //Necessario posicionar para realizar load da TWM
				TXK->(dbSetOrder(2))
				If TXK->(dbSeek(xFilial("TXK") + cCodFac))
					oMdlFac := FwLoadModel("TECA984")
					oMdlFac:SetOperation(MODEL_OPERATION_VIEW)
					oMdlFac:Activate()
					oMdlFacUN := oMdlFac:GetModel("UNIDETAIL")
					FwModelActive( oModTXL:GetModel() )

					If !oMdlFacUN:IsEmpty()
						//Caso o Grid ja possua itens, ajusta o campo ITEM para adicionar os produtos do facilitador
						If !oModITUN:IsEmpty()
							oModITUN:GoLine(oModITUN:Length())
							cItem := oModITUN:GetValue('TXD_ITEM')
						EndIf

						For nY := 1 To oMdlFacUN:Length()
							oMdlFacUN:GoLine( nY )
							If !Empty( oMdlFacUN:GetValue("TXK_CODPRO") )
								If oModITUN:SeekLine( { { 'TXD_CODPRO', oMdlFacUN:GetValue("TXK_CODPRO")}})
									// Só atribui quando tem conteúdo
									If !( EMPTY(oMdlFacUN:GetValue("TXK_QTDE")) )
										oModITUN:SetValue('TXD_QTDE', (nQuant * oMdlFacUN:GetValue("TXK_QTDE")) )
									EndIf  		
								Else 
									cItem :=  Soma1(cItem)
									If !oModITUN:IsEmpty()
										oModITUN:AddLine()
										// atribui os conteúdos relacionados ao controle de associação do facilitador
										oModITUN:SetValue('TXD_ITEM', cItem)
									EndIf 

									// Só atribui quando tem conteúdo
									If !( EMPTY(oMdlFacUN:GetValue("TXK_CODPRO")) )
										oModITUN:SetValue('TXD_CODPRO', oMdlFacUN:GetValue("TXK_CODPRO"))
									EndIf 

									// Só atribui quando tem conteúdo
									If !( EMPTY(oMdlFacUN:GetValue("TXK_QTDE")) )
										oModITUN:SetValue('TXD_QTDE', nQuant * oMdlFacUN:GetValue("TXK_QTDE"))
									EndIf 

									// Só atribui quando tem conteúdo
									If !( EMPTY(oMdlFacUN:GetValue("TXK_QTDVIG")) )
										oModITUN:SetValue('TXD_QTDVIG', oMdlFacUN:GetValue("TXK_QTDVIG"))
									EndIf 

									// Só atribui quando tem conteúdo
									If !( EMPTY(oMdlFacUN:GetValue("TXK_TIPVIG")) )
										oModITUN:SetValue('TXD_TIPVIG', oMdlFacUN:GetValue("TXK_TIPVIG"))
									EndIf 

								EndIf
							EndIf
						Next nY
						aAdd(aChvTXL,{cCodFac,oModCab:GetValue("TXC_CODTEC"),oModTXL:GetValue('TXL_QUANT')})
					EndIf				
				EndIf
			EndIf	
		Next nX
	EndIf 
Else 
	Help(,, 'At894Facil',, STR0077, 1, 0) //"Selecione um Atendente para aplicar o Facilitador"
EndIf 

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At894TXK()
Construção da consulta especifica

@author Luiz Gabriel
@since 15/06/2020
@return Nil
/*/
//------------------------------------------------------------------
Function At894TXK()

Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= ""
Local aIndex		:= {}
Local aSeek 		:= {}

Aadd( aSeek, {STR0078, {{"","C",TamSX3("TWM_CODIGO")[1],0,STR0078,,}} } )	// "Código" ### "Código"
Aadd( aSeek, { STR0058, {{"","C",TamSX3("TWM_DESCRI")[1],0,STR0058,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "TWM_CODIGO" )
Aadd( aIndex, "TWM_DESCRI")
Aadd( aIndex, "TWM_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

cQry := " SELECT TWM.TWM_FILIAL,TWM.TWM_CODIGO,TWM.TWM_DESCRI  "
cQry += " FROM " + RetSqlName("TWM") + " TWM"
cQry += " INNER JOIN " + RetSqlName("TXK") + " TXK"
cQry += 	" ON TXK.TXK_FILIAL = '" +  xFilial('TXK') + "' "
cQry += 	" AND TXK.TXK_CODTWM = TWM.TWM_CODIGO"
cQry += 	" AND TXK.D_E_L_E_T_ = ' '"
cQry += 	" AND TWM.D_E_L_E_T_ = ' '"
cQry += " WHERE TWM.TWM_FILIAL = '" +  xFilial('TWM') + "'"
cQry += "GROUP BY TWM.TWM_FILIAL,TWM.TWM_CODIGO,TWM.TWM_DESCRI"

nSuperior := 0
nEsquerda := 0

If !IsBlind()
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

	DEFINE MSDIALOG oDlgEscTela TITLE STR0077 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Facilitador"

		oBrowse := FWFormBrowse():New()
		oBrowse:SetOwner(oDlgEscTela)
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAls)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery(cQry)
		oBrowse:SetSeek(,aSeek)
		oBrowse:SetDescription(STR0077)  //"Facilitador"
		oBrowse:SetMenuDef("")
		oBrowse:DisableDetails()
		oBrowse:SetUseFilter(.T.)


		oBrowse:SetDoubleClick({ || cRetFac := (oBrowse:Alias())->TWM_CODIGO, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0054), {|| cRetFac   := (oBrowse:Alias())->TWM_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
		oBrowse:AddButton( OemTOAnsi(STR0055),  {||  cRetFac  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
		oBrowse:DisableDetails()

		ADD COLUMN oColumn DATA { ||  TWM_CODIGO } TITLE STR0078 SIZE TamSX3("TWM_CODIGO")[1] OF oBrowse //"Código"
		ADD COLUMN oColumn DATA { ||  TWM_DESCRI } TITLE STR0058 SIZE TamSX3("TWM_DESCRI")[1] OF oBrowse //"Descrição"

		oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TECRetFac()
Retorno da consulta especifica

@author Luiz Gabriel
@since 15/06/2020
@return Nil

/*/
//------------------------------------------------------------------
Function TECRetFac()

Return cRetFac

//-------------------------------------------------------------------
/*/{Protheus.doc} At894VldFa()
Valida se o facilitador já foi aplicado,e se houve alterações na quantidade

@author Luiz Gabriel
@since 15/06/2020
@return Nil

/*/
//------------------------------------------------------------------
Static Function At894VldFa(cCODFAC ,cCODTEC,nQuant)
Local lRet			:= .T.
Local cAliasQry 	:= GetNextAlias()
Local nScan			:= 0

BeginSql Alias cAliasQry
	SELECT	TXL.TXL_CODFAC,TXL.TXL_CODTEC,TXL.TXL_QUANT
		FROM %table:TXL% TXL
	WHERE
		TXL.TXL_FILIAL = %xFilial:TXL% AND
		TXL.TXL_CODFAC = %Exp:cCODFAC% AND
		TXL.TXL_CODTEC = %Exp:cCODTEC% AND
		TXL.%NotDel%
EndSql

	If !(cAliasQry)->(Eof())
		If nQuant == TXL->TXL_QUANT
			lRet := .F.
		EndIf	
	EndIf 

(cAliasQry)->(DbCloseArea())

If lRet 
	nScan := aScan(aChvTXL,{|x| x[1] == cCODFAC .And. x[2] == cCODTEC})
	If nScan > 0
		If nQuant == aChvTXL[nScan][3]
			lRet := .F.
		EndIf	
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At894PrTXL()
Valida se o facilitador selecionado já foi aplicado

@author Luiz Gabriel
@since 15/06/2020
@return Nil

/*/
//------------------------------------------------------------------
Function At894PrTXL(oModel, nLine, cAction, cField,xValue,xOldValue)
Local lRet		:= .T.
Local nX 		:= 0

If cAction ==  "SETVALUE" .And. cField == "TXL_CODFAC"
	//Verifica se o facilitador já está sendo utilizado
	For nX := 1 To oModel:Length()
		If oModel:GetValue(cField,nX) == xValue
			If !IsBlind()
				Help(,, 'At894Facil',, STR0079, 1, 0) //"Facilitador já utilizado, selecione outro ou mude a quantidade"
			Endif
			lRet := .F.
			Exit
		EndIf 
	Next nX 
EndIf 

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CamposCont
@description Retorna .T. caso tenha todos os campos criados para a entidade contabil.
@author Augusto Albuquerque
@since  15/09/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CamposCont()
Return (TXD->(ColumnPos("TXD_CONTA")) > 0 .AND. TXE->(ColumnPos("TXE_CONTA")) > 0) .AND. (TXD->(ColumnPos("TXD_CLVL")) > 0 .AND. TXE->(ColumnPos("TXE_CLVL")) > 0) .AND. (TXD->(ColumnPos("TXD_ITEMCO")) > 0 .AND. TXE->(ColumnPos("TXE_ITEMCO")) > 0)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CampoCCusto
@description Retorna .T. caso tenha o campo de Centro de Custo.
@author Augusto Albuquerque
@since  15/09/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CampoCCusto()
Return TXC->(ColumnPos("TXC_CCUSTO")) > 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CmpLocali
@description Retorna .T. caso tenha o campo de Endereço.
@author Junior Geraldo 
@since  05/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CmpLocali()
Return TXD->(ColumnPos("TXD_LOCALI")) > 0 .AND. TXE->(ColumnPos("TXE_LOCALI")) > 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CmpNumSer
@description Retorna .T. caso tenha o campo Número de Série.
@author Junior Geraldo
@since  05/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CmpNumSer()
Return TXD->(ColumnPos("TXD_NUMSER")) > 0 .AND.TXE->(ColumnPos("TXE_NUMSER")) > 0 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At894Edita
@description Função que habilita a edição do grid
@author Aleson Silva
@since  17/12/2020
/*/'
//--------------------------------------------------------------------------------------------------------------------
Static Function At894Edita(oBrowse,aDados)
Local lAt894Edit:= .T.

If oBrowse:nColPos == 4
	lEditCell(@aDados,oBrowse,"@ER 999,999",oBrowse:nColpos)
ElseIf oBrowse:nColPos == 1
	aDados[oBrowse:nAt,1] := !aDados[oBrowse:nAt,1]
EndIf

Return lAt894Edit

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At894VlQnt
@description Valida a quantidade
@author Aleson Silva
@since  21/12/2020
/*/'
//--------------------------------------------------------------------------------------------------------------------
Static function At894VlQnt(aDados)
Local lAt894VlQn:= .T.
Local nX		:= 0

For nX:= 1 to Len(aDados)
	If aDados[nX,1]
		If aDados[nX,4] <= 0
			lAt894VlQn:= .F.
			Help(,, 'At894Edita',, STR0088 +aDados[nX][2]+STR0089, 1, 0)//"Produto "#" - Valor não pode ser negativo e nem ser zerado."
			Exit
		ElseIf aDados[nX][4] > aDados[nX][5]
			lAt894VlQn:= .F.
			Help(,, 'At894Edita',, STR0088 +aDados[nX][2]+STR0090, 1, 0)//"Produto "#" - Valor de troca/substituição não pode ser maior que a entregue."
			Exit
		EndIf
	EndIf	
Next nX

Return lAt894VlQn

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MAXITEMTXD
@description Retorna o maior item do codigo do tecnico
@author Aleson Silva
@since  21/12/2020
/*/'
//--------------------------------------------------------------------------------------------------------------------
Static function MAXITEMTXD(cCodTec)
Local aArea:= GetArea()
Local cAlias:= GetNextAlias()
Local cQuery:= ""
Local cItem:= ""

cQuery+= " SELECT MAX(TXD.TXD_ITEM) ITEM "
cQuery+= " FROM "+RetSqlName("TXD")+" TXD "
cQuery+= " WHERE TXD.TXD_FILIAL = '"+xFilial("TXD")+"' "
cQuery+= " AND TXD.TXD_CODTEC 	= '"+cCodTec+"' "
cQuery+= " AND TXD.D_E_L_E_T_ 	= '' "
TCQUERY cQuery NEW ALIAS (cAlias)
If (cAlias)->(!EOF())
	cItem:= (cAlias)->ITEM
EndIf
(cAlias)->(DbCloseArea())

RestArea(aArea)

Return cItem

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At894TrSbD
@description Retorna as trocas, substituições e devoluções efetuadas
@author Aleson Silva
@since  22/12/2020
/*/'
//--------------------------------------------------------------------------------------------------------------------
Static function At894TrSbD(oModel)
Local aArea:= GetArea()
Local cAlias:= GetNextAlias()
Local cQuery:= ""
Local oModCab:= oModel:GetModel('TXCMaster')
Local aItBrowse := {{STR0091,STR0092,STR0093,STR0094,STR0095,STR0096,STR0097}, {}} //'Tipo Mov.', 'Mot. Troca', 'Produto de Troca antigo', 'Produto de Troca Nova', 'Produto devolução', 'Data', 'Qtd. devol.'

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	cQuery+= " SELECT TXF.R_E_C_N_O_ TXFRECNO "
	cQuery+= " FROM "+RetSqlName("TXF")+" TXF "
	cQuery+= " WHERE TXF.TXF_FILIAL = '"+xFilial("TXF")+"' "
	cQuery+= " AND TXF.TXF_CODTEC 	= '"+oModCab:GetValue("TXC_CODTEC")+"' "
	cQuery+= " AND TXF.D_E_L_E_T_ 	= '' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
	
	While (cAlias)->(!EOF())
		TXF->(DbGoTo((cAlias)->TXFRECNO))
		AADD(aItBrowse[2],; 
						{IIF(TXF->TXF_TIPO = '2',STR0083,STR0009),; //Troca#"Devolução"
						TXF->TXF_MOTIVO,;
						TXF->TXF_PRDANT,;
						TXF->TXF_PRDNOV,;
						TXF->TXF_PRDDEV,;
						TXF->TXF_DATA,;
						TXF->TXF_DEVOL})
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())

	If Len(aItBrowse[2]) > 0
		DEFINE MSDialog oDlg From 000, 000 To 270, 610 Title STR0098 Of oMainWnd Pixel //"Histórico"
		oGrpBrw    := TGroup():New(035, 005, 120, 300, STR0099, oDlg,,, .T.) //"Movimentação"
		oBrowse    := TWBrowse():New(045, 010, 285, 070, NIL, aItBrowse[1], NIL, oGrpBrw, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	
			oBrowse:SetArray(aItBrowse[2])
			oBrowse:bLine := {|| {	aItBrowse[2][oBrowse:nAT, 1],;
									aItBrowse[2][oBrowse:nAT, 2],;
									aItBrowse[2][oBrowse:nAT, 3],;
									aItBrowse[2][oBrowse:nAT, 4],;
									aItBrowse[2][oBrowse:nAT, 5],;
									aItBrowse[2][oBrowse:nAT, 6],;
									aItBrowse[2][oBrowse:nAT, 7]}}
		Activate MSDialog oDlg On Init EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()}) Centered
	Else
		Help(,, 'At894TrSbD',, STR0100, 1, 0) //"Não há itens para serem visualizados!."
	EndIf
Else
	Help(,, 'At894TrSbD',, STR0101, 1, 0)//"Visualização somente em modo 'Solicitar/Alterar."
EndIf

RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CmpDevoPar
@description Retorna .T. caso tenha os campos de devolução parcial
@author Aleson Silva
@since  06/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CmpDevoPar()

Return TXD->(ColumnPos("TXD_DEVOL")) > 0 .AND. TXF->(ColumnPos("TXF_DEVOL")) > 0 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At894Quant
@description Valida a quantidade a ser substituida
@author Luiz Gabriel
@since  01/02/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At894Quant(nQtdEnt,nQtdSub,cProdut)
Local lRet	:= .F.

If nQtdEnt >= nQtdSub
	lRet := .T.
Else
	Help(,, 'At894Vld',, STR0088 + cProdut + STR0090, 1, 0)//"Produto "#" - Valor de troca/substituição não pode ser maior que a entregue."
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TECUniSB1()
Construção da consulta especifica de Uniforme

@author Luiz Gabriel
@since  01/02/2021
/*/
//------------------------------------------------------------------
Function TECUniSB1()

Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= "SB1UNI"
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= ""
Local aIndex		:= {}
Local aSeek 		:= {}
Local cProfID		:= "SB1UNI"  //Indica o ID do browse para recuperar as informações do usuario	
Local aTpUnif 		:= StrTokArr(SuperGetMV('MV_TPUNIF',, 'UN;'), ';') 	//-- TIPOS DE PRODUTO CORRESPONDENTE AOS UNIFORMES
Local nX			:= 0
Local cTpProd		:= ""

Aadd( aSeek, { STR0078, {{"","C",TamSX3("B1_COD")[1],0,STR0078,,}} } )	// "Código" ### "Código"
Aadd( aSeek, { STR0020, {{"","C",TamSX3("B1_DESC")[1],0,STR0020,,}}}) // "Descrição" ### "Descrição"
Aadd( aSeek, { STR0102, {{"","C",TamSX3("B1_TIPO")[1],0,STR0102,,}}}) // "Tipo de Produto" ### "Tipo de Produto"

Aadd( aIndex, "B1_COD" )
Aadd( aIndex, "B1_DESC")
Aadd( aIndex, "B1_TIPO")
Aadd( aIndex, "B1_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

//Concatena os tipos de uniformes para adicionar na query
If Len(aTpUnif) == 1
	cTpProd := "In('" + aTpUnif[1] + "')	
Else
	For nX := 1 to Len(aTpUnif)
		//Monta o Range com os tipos de uniforme
		If nX == Len(aTpUnif)
			cTpProd += ",'" + aTpUnif[nX] + "')	
		ElseIf !Empty(cTpProd) 
			cTpProd += ",'" + aTpUnif[nX] + "'	
		Else
			cTpProd := "In('" + aTpUnif[nX] + "'	
		EndIf
	Next nY
EndIf

cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_LOCPAD, B1_TIPCONV "
cQry += " FROM " + RetSqlName("SB1") + " B1"
cQry += " WHERE B1_FILIAL = '" +  xFilial('SB1') + "'"
cQry += " AND B1_TIPO "
cQry += cTpProd

//-- Necessário utilizar FieldPos, pois o campo de bloqueio de registro é opcional para o cliente.
If SB1->(FieldPos('B1_MSBLQL')) > 0
	cQry += " AND B1.B1_MSBLQL <> '1'"
EndIf

cQry := ChangeQuery(cQry)

IF !isBlind()
	nSuperior := 0
	nEsquerda := 0
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

	DEFINE MSDIALOG oDlgEscTela TITLE STR0066 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Uniforme"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0066)  // "Uniforme"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetUnif := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0054), {|| cRetUnif := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0055), {|| cRetUnif := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  B1_COD  } TITLE STR0078 SIZE TamSX3("B1_COD")[1] OF oBrowse //"Código"
	ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE STR0020 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição"
	ADD COLUMN oColumn DATA { ||  B1_TIPO  } TITLE STR0102 SIZE TamSX3("B1_TIPO")[1] OF oBrowse //"Tipo de Produto"
	ADD COLUMN oColumn DATA { ||  B1_UM } TITLE STR0103 SIZE TamSX3("B1_UM")[1] OF oBrowse //"Unidade de Medida"
	ADD COLUMN oColumn DATA { ||  B1_LOCPAD  } TITLE STR0104 SIZE TamSX3("B1_LOCPAD")[1] OF oBrowse //"Armazem Padrao p/Requis."
	ADD COLUMN oColumn DATA { ||  B1_TIPCONV } TITLE STR0105 SIZE TamSX3("B1_TIPCONV")[1] OF oBrowse //"Tipo de Conversao da UM "


	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TECRetUnif()
Retorno da consulta especifica

@author Luiz Gabriel
@since  01/02/2021
/*/
//------------------------------------------------------------------
Function TECRetUnif()

Return cRetUnif

//-------------------------------------------------------------------
/*/{Protheus.doc} At894CmpUn
	(long_description)
	@author Kaique Schiller
	@since 13/07/2022
	@return lRet
/*/
//-------------------------------------------------------------------
Static Function At894CmpUn()
Local lRet := .F.

If	TXD->(ColumnPos("TXD_FILTFF")) > 0 ; 
	.And. TXD->(ColumnPos("TXD_CONTRT")) > 0 ; 
	.And. TXD->(ColumnPos("TXD_POSTO")) > 0
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At894TotUnif()
Soma quantidade entregue e subtrai quantidade devolvida do atendente/tecnico conforme Filial/Contrato
@param oModel, Modelo de dados para validação
@Param cFilCont, String, Filial
@Param cContrat, String, Contrato
@Param cCodProd, String, Uniforme
@Return nQtdProd, Number, Quantidade de Uniformes
@author Flavio Vicco
@since  19/07/2021
/*/
//------------------------------------------------------------------
Static Function At894TotUnif(oModITUN,cFilCont,cContrat,cPosto,cCodProd)

Local nX       := 0
Local nQtdProd := 0
Local nLineSav := oModITUN:GetLine()

For nX := 1 To oModITUN:Length()
	oModITUN:GoLine(nX)
	If !oModITUN:IsDeleted()
		If	cFilCont == FwFldGet("TXD_FILTFF") .And. ;
			cContrat == FwFldGet("TXD_CONTRT") .And. ;
			cPosto   == FwFldGet("TXD_POSTO" ) .And. ;
			cCodProd == FwFldGet("TXD_CODPRO")
			nQtdProd += (oModITUN:GetValue("TXD_QTDE")-oModITUN:GetValue("TXD_DEVOL"))
		EndIf
	EndIf
Next nX

oModITUN:GoLine(nLineSav)

Return nQtdProd
