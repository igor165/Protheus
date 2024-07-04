#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBS440.CH'

Static oCS440Log
Static lExistCT1	:= .t.

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS440
Cadastro do Bloco K - Conglomerados Economicos
Registro K300: Saldos das Contas Consolidadas

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CTBS440()

Local oBrowse	:= Nil

oBrowse := FWmBrowse():New()

oBrowse:SetAlias('CQX')

oBrowse:SetDescription(STR0001) //"Registro K300: Saldos das Contas Consolidadas"

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.CTBS440' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.CTBS440' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.CTBS440' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.CTBS440' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'CTBS440Imp'      OPERATION 3 ACCESS 0 //'Importa Saldos Contábeis'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCQX	:= FWFormStruct(1,'CQX')
Local oStruCQY	:= FWFormStruct(1,'CQY')
Local oStruCQZ	:= FWFormStruct(1,'CQZ')
Local oModel	:= Nil

//----------------------------------------------------------------------------------
// Validação inclusa no modelo devido X3_VALID nao comportar o tamanho da expressao
//----------------------------------------------------------------------------------
oStruCQX:SetProperty('CQX_CODCTA', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .Or. (ExistCpo("CQU",FWFldGet("CQX_IDBLK")+FWFldGet("CQX_CODCTA"),1) .And. ExistChav( "CQX", FWFldGet("CQX_IDBLK")+FWFldGet("CQX_CODCTA")))' ))

oStruCQX:AddTrigger("CQX_VALAGL","CQX_VLCONS",{||.T.},{|| CQXValCons()})
oStruCQX:AddTrigger("CQX_INDVAG","CQX_VLCONS",{||.T.},{|| CQXValCons()})
oStruCQX:AddTrigger("CQX_VALEL" ,"CQX_VLCONS",{||.T.},{|| CQXValCons()})
oStruCQX:AddTrigger("CQX_INDVEL","CQX_VLCONS",{||.T.},{|| CQXValCons()})
oStruCQX:AddTrigger("CQX_CODCTA","CQX_CODCTA",{||.T.},{|| CQXValCons()})

oModel := MPFormModel():New('CTBS440', /*<bPre >*/,{|oModel| ChkIndCons(oModel) }/*<bPost >*/, /*<bCommit >*/, /*<bCancel>*/)

oModel:AddFields('CQXMASTER',,oStruCQX,/*bPreVld*/{|oCQX,cAcao,cCampo,cValAnt| CQXPreVal(oCQX,cAcao,cCampo,cValAnt)},/*bPostVld*/{||CQXPosVal()})

oModel:AddGrid('CQYDETAIL','CQXMASTER',oStruCQY,/*bLinePre*/,/*bLinePost*/                ,/*bPreVal*/{|oCQY,nLinha,cAcao| CQYPreVal(oCQY,nLinha,cAcao)},/*bPosVal*/{||CQYPosVal()},/*BLoad*/)
oModel:AddGrid('CQZDETAIL','CQYDETAIL',oStruCQZ,/*bLinePre*/,/*bLinePost*/{||CQZLinePos()},/*bPreVal*/{|oCQZ,nLinha,cAcao| CQZPreVal(oCQZ,nLinha,cAcao)},/*bPosVal*/{||CQZPosVal()},/*BLoad*/)

oModel:SetRelation('CQYDETAIL',{{'CQY_FILIAL','XFilial("CQY")'},{'CQY_IDBLK','CQX_IDBLK'},{'CQY_CODCTA','CQX_CODCTA'}},CQY->(IndexKey(1)))
oModel:SetRelation('CQZDETAIL',{{'CQZ_FILIAL','XFilial("CQZ")'},{'CQZ_IDBLK','CQX_IDBLK'},{'CQZ_CODCTA','CQX_CODCTA'},{'CQZ_CODPAR','CQY_CODPAR'}},CQZ->(IndexKey(1)))

oModel:GetModel("CQYDETAIL"):SetUniqueLine({'CQY_CODPAR'})
oModel:GetModel("CQZDETAIL"):SetUniqueLine({'CQZ_EMPCPA','CQZ_CTACPA'})

oModel:GetModel('CQYDETAIL'):SetOptional(.T.)
oModel:GetModel('CQZDETAIL'):SetOptional(.T.)

oModel:SetDescription(STR0007) //'Bloco K - Conglomerados Econômicos'

oModel:GetModel('CQXMASTER'):SetDescription(STR0001) //"Registro K300: Saldos das Contas Consolidadas"
oModel:GetModel('CQYDETAIL'):SetDescription(STR0008) //"Registro K310: Empresas Detentoras das Parcelas do Valor Eliminado Total"
oModel:GetModel('CQZDETAIL'):SetDescription(STR0009) //"Registro K315: Empresas Contrapartes das Parcelas do Valor Eliminado Total"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCQX	:= FWFormStruct(2,'CQX')
Local oStruCQY	:= FWFormStruct(2,'CQY')
Local oStruCQZ	:= FWFormStruct(2,'CQZ')
Local oModel	:= FWLoadModel('CTBS440')
Local oView		:= Nil

oStruCQX:SetProperty("CQX_INDVCS",MVC_VIEW_CANCHANGE,.T.)

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CQX',oStruCQX,'CQXMASTER')

oView:AddGrid('VIEW_CQY',oStruCQY,'CQYDETAIL')
oView:AddGrid('VIEW_CQZ',oStruCQZ,'CQZDETAIL')

oView:CreateHorizontalBox('TOP'		,30)
oView:CreateHorizontalBox('CENTER'	,35)
oView:CreateHorizontalBox('DOWN'	,35)

oView:SetOwnerView('VIEW_CQX','TOP'		)
oView:SetOwnerView('VIEW_CQY','CENTER'	)
oView:SetOwnerView('VIEW_CQZ','DOWN'	)

oView:EnableTitleView('VIEW_CQX')
oView:EnableTitleView('VIEW_CQY')
oView:EnableTitleView('VIEW_CQZ')

oView:AddUserButton(STR0010,'OK',{||C440Saldo()}) //"Carrega Saldo"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CQXValCons
Preenche o valor consolidado - REGRA_CALCULO_VALOR_CONSOLIDADO

O valor absoluto consolidado é igual ao resultado da diferença entre o valor
absoluto aglutinado e o valor absoluto das eliminações, considerando os
indicadores da situação do saldo (devedor ou credor).

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQXValCons(cOpcIndVCS,lValido)
Local aSaveArea	:= GetArea()
Local nValAglut	:= FWFldGet("CQX_VALAGL")
Local cTipAglut	:= FWFldGet("CQX_INDVAG")
Local nValElim	:= FWFldGet("CQX_VALEL")
Local cTipElim	:= FWFldGet("CQX_INDVEL")
Local cTipCons	:= ""
Local nValCons	:= 0
Local cCodCta	:= FWFldGet("CQX_CODCTA")
Local cNatCta	:= " "

Default cOpcIndVCS	:= ""
Default lValido	:= If(!Empty(cOpcIndVCS),.f.,.t.)
//------------------------------------------------------
// Adiciona o Saldo Aglutinado para o Saldo Consolidado
//------------------------------------------------------
If !Empty(cTipAglut)

	//---------------------------------------------------
	// Transforma em negativo para calcular a eliminação
	//---------------------------------------------------
	If cTipAglut == "D"
		nValAglut *= -1
	EndIf

	nValCons := nValAglut

	//------------------------------------------------
	// Subtrai o Saldo Eliminado do Saldo Consolidado
	//------------------------------------------------
	If nValElim != 0 .And. !Empty(cTipElim)

		//-----------------------------------------------
		// Transforma em negativo para aplicar a formula
		//-----------------------------------------------
		If cTipElim == "D"
			nValElim *= -1
			EndIf

			nValCons -= (nValElim)

		EndIf

EndIf

//---------------------------------------------------------------
// Obtem a natureza da conta (Credora ou Devedora), para definir
// o indicador consolidado, caso o saldo seja igual a 0
//---------------------------------------------------------------
If nValCons == 0 .And. !Empty(cCodCta)
	lExistCT1 := .f.
	DBSelectArea("CT1")
	CT1->(DBSetOrder(1))
	If CT1->(MSSeek(XFilial("CT1")+cCodCta))
		lExistCT1 := .t.
		cNatCta := If(CT1->CT1_NORMAL == "1","D","C")
	EndIf
EndIf

cTipCons := If(nValCons > 0,"C",If(nValCons < 0, "D", cNatCta))

If ( Empty(cTipCons) )
	cTipCons := If(nValCons > 0,"C","D")
EndIf

If !Empty(cOpcIndVCS)
	lValido := Upper(Alltrim(cOpcIndVCS)) == Upper(Alltrim(cTipCons))
Else
	FWFldPut("CQX_INDVCS",cTipCons)
EndIf	

RestArea(aSaveArea)

Return ABS(nValCons)

//-------------------------------------------------------------------
/*/{Protheus.doc} CQXPreVal
Pré-validações da CQX

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CQXPreVal(oCQX,cAcao,cCampo,cConteudo)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local oModel	:= FWModelActive()
Local oCQY		:= oModel:GetModel("CQYDETAIL")
Local oCQZ		:= oModel:GetModel("CQYDETAIL")

If lRet .And. cAcao == "SETVALUE"

	//-------------------------------------------------------------------------------------------------------
	// Não permite a alteração do ID do Bloco K (CQX_IDBLK) caso algum dado relacionado já esteja preenchido
	//-------------------------------------------------------------------------------------------------------
	If lRet .And. cCampo ==  "CQX_IDBLK" .And. cConteudo != oCQX:GetValue("CQX_IDBLK")

		If lRet .And. !Empty(oCQX:GetValue("CQX_CODCTA"))
			lRet := .F.
			Help(" ",1,"CQXPreVal",,STR0011,1, 0,,,,,,{STR0012}) //"Não é possivel alterar o ID do bloco K devido relacionamento com o valor preenchido no campo Cod.Conta (CQX_CODCTA)."###'Apague a informação do campo Cod.Conta (CQX_CODCTA).'
		EndIf

		If lRet .And. !oCQY:IsEmpty() .And. oCQY:Length(.T.) > 0
			lRet := .F.
			Help(" ",1,"CQXPreVal",,STR0013,1, 0,,,,,,{STR0014}) //"Não é possivel alterar o ID do bloco K devido relacionamento com o dados preenchidos no painel K310."###'Delete as linhas do painel K310.'
		EndIf

		If lRet .And. !oCQZ:IsEmpty() .And. oCQZ:Length(.T.) > 0
			lRet := .F.
			Help(" ",1,"CQXPreVal",,STR0015,1, 0,,,,,,{STR0016}) //"Não é possivel alterar o ID do bloco K devido relacionamento com o dados preenchidos no painel K315."###'Delete as linhas do painel K315.'
		EndIf

	EndIf

	//-------------------------------------
	// Validações de negócio do CQX_CODCTA
	//-------------------------------------
	If lRet .And. cCampo == "CQX_CODCTA" .And. !Empty(cConteudo)

		//---------------------------------------------------------------------------------------------
		// Não permite o preenchimento do campo CQX_CODCTA se o usuario nao informar o campo CQX_IDBLK
		//---------------------------------------------------------------------------------------------
		If lRet .And. Empty(oCQX:GetValue("CQX_IDBLK"))
			lRet := .F.
			Help(" ",1,"CQXPreVal",,STR0018,1, 0,,,,,,{STR0017}) //'Preencha o campo Id.Bloco K (CQX_IDBLK).'###"Não é possivel informar a conta contábil sem possuir o ID do bloco K informado."
		EndIf

		//-------------------------------------------------------------
		// Valida se a conta é analitica - REGRA_EXISTE_K200_ANALITICA
		//-------------------------------------------------------------
		If lRet
			DBSelectArea("CQU")
			CQU->(DBSetOrder(1)) //CQU_FILIAL+CQU_IDBLK+CQU_CODCTA
			If CQU->(DBSeek(XFilial("CQU") + oCQX:GetValue("CQX_IDBLK") + cConteudo)) .And. CQU->CQU_INDCTA != "A"
				lRet := .F.
				Help(" ",1,"CQXPreVal",,STR0020,1,0,,,,,,{STR0019}) //'Selecione no campo Cod.Conta (CQX_CODCTA) uma conta analítica.'###'A conta contábil consolidada (K300) não pode ser sintética.'
			EndIf
		EndIf

	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQXPosVal
Pós-validações da CQX

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQXPosVal()

Local lRet		:= .T.

Local oModel	:= FWModelActive()
Local oCQX		:= oModel:GetModel("CQXMASTER")
Local oCQY		:= oModel:GetModel("CQYDETAIL")

//---------------------------------------------------------------------------------
// Valida se o Valor Eliminado foi preenchido e o indicador do valor eliminado não
//---------------------------------------------------------------------------------
If lRet .And. oCQX:GetValue("CQX_VALEL") > 0 .And. Empty(oCQX:GetValue("CQX_INDVEL"))
	lRet := .F.
	Help(" ",1,"CQXPosVal",,STR0055,1,0,,,,,,{STR0056}) //'Quando informado o campo "Valor Elimin" (CQX_VALEL), é necessário preencher o campo "Ind.Vlr.Elim" (CQX_INDVEL), no painel "Registro K300: Saldos das Contas Consolidadas".'###'Revise os dados informados nos campos "Valor Elimin" (CQX_VALEL) e "Ind.Vlr.Elim" (CQX_INDVEL), no painel K300.'
EndIf

//---------------------------------------------------------------------------------
// Valida se o Indicador do valor eliminado foi preenchido e o valor eliminado não
//---------------------------------------------------------------------------------
If lRet .And. !Empty(oCQX:GetValue("CQX_INDVEL")) .And. oCQX:GetValue("CQX_VALEL") == 0
	lRet := .F.
	Help(" ",1,"CQXPosVal",,STR0057,1,0,,,,,,{STR0056}) //'Quando informado o campo "Ind.Vlr.Elim" (CQX_INDVEL), é necessário preencher o campo "Valor Elimin" (CQX_VALEL), no painel "Registro K300: Saldos das Contas Consolidadas".'###'Revise os dados informados nos campos "Valor Elimin" (CQX_VALEL) e "Ind.Vlr.Elim" (CQX_INDVEL), no painel K300.'
EndIf

//--------------------------------------------------------------
// Valida se o K310 foi preenchido - REGRA_OBRIGATORIEDADE_K310
//--------------------------------------------------------------
If lRet .And. oCQX:GetValue("CQX_VALEL") > 0 .And. oCQY:Length(.T.) == 0
	lRet := .F.
	Help(" ",1,"CQXPosVal",,STR0021,1,0,,,,,,{STR0022}) //'O valor do campo "Valor Elimin" (CQX_VALEL) não coincide com o total informado no painel "Registro K310:Empresas Detentoras das Parcelas do Valor Eliminado Total".'###"Revise os dados informados no painel K310."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQYPreVal
Pré-validações da CQY

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQYPreVal(oCQY,nLinha,cAcao)
Local lRet := .T.

//-----------------------------------------------------------------------------
// Não permite a edição do K310 sem antes informar o ID do Bloco K (CQX_IDBLK)
//-----------------------------------------------------------------------------
If lRet .And. cAcao $ "CANSETVALUE|UNDELETE" .And. Empty(FWFldGet("CQX_IDBLK"))

	If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
		MSGINFO("CQYPreVal - "+STR0023, STR0017 )	   //"Não é possivel informar o painel K310 sem possuir o ID do bloco K informado."###'Preencha o campo Id.Bloco K (CQX_IDBLK).'
	Else
		Help(" ",1,"CQYPreVal",,STR0023,1, 0,,,,,,{STR0017}) //"Não é possivel informar o painel K310 sem possuir o ID do bloco K informado."###'Preencha o campo Id.Bloco K (CQX_IDBLK).'
	EndIf

	lRet := .F.
	
EndIf

//---------------------------------------------------------------------------
// Ao tentar remover a deleçao, confirma se o ID do bloco K não foi alterado
//---------------------------------------------------------------------------
If lRet .And. cAcao == "UNDELETE" .And. !Empty(FWFldGet("CQX_IDBLK")) .And. !Empty(oCQY:GetValue("CQY_CODPAR"))

	If !ExistCpo("CQR",FWFldGet("CQX_IDBLK")+oCQY:GetValue("CQY_CODPAR"),1,,.F.)
		lRet := .F.
		If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
			MSGINFO("CQYPreVal - "+STR0058, STR0059 )	//'Não é possivel reativar a linha. A empresa informada no campo "Cd.Emp.Dt.El" (CQY_CODPAR), não possui relação com o Id.Bloco K (CQX_IDBLK), painel K300.'#'Insira uma nova linha.'
		Else
			Help(" ",1,"CQYPreVal",,STR0058,1, 0,,,,,,{STR0059})	//'Não é possivel reativar a linha. A empresa informada no campo "Cd.Emp.Dt.El" (CQY_CODPAR), não possui relação com o Id.Bloco K (CQX_IDBLK), painel K300.'#'Insira uma nova linha.'
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQYPosVal
Pós-validações da CQY

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQYPosVal()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oCQX		:= oModel:GetModel("CQXMASTER")
Local oCQY		:= oModel:GetModel("CQYDETAIL")
Local aSaveRows	:= FWSaveRows()
Local nX		:= 0
Local nTotCQY	:= 0
Local cTipLin	:= ""
Local nValLin	:= 0

//------------------------------------------
// Validações referentes ao valor eliminado
//------------------------------------------
If lRet .And. oCQY:Length(.T.) > 0

	//------------------------------------------------------------------------------------------------------------------
	// Valida se o total do K310 é igual o valor eliminado (K300 - campo CQX_VALEL) - REGRA_SOMATORIO_VALOR_ELIMINACOES
	// A soma e a comparação leva em consideração o indicador da situação do saldo (devedor ou credor)
	//------------------------------------------------------------------------------------------------------------------
	For nX := 1 To oCQY:Length()

		oCQY:GoLine( nX )

		If !oCQY:IsDeleted()

			cTipLin	:= oCQY:GetValue("CQY_INDELI")
			nValLin	:= oCQY:GetValue("CQY_VLRELI")

			If cTipLin == "D"
				nValLin *= -1
			EndIf

			nTotCQY := (nTotCQY) + (nValLin)

		EndIf

	Next nX

	If oCQX:GetValue("CQX_VALEL") != ABS(nTotCQY)
		lRet := .F.
		Help(" ",1,"CQYPosVal",,STR0025,1,0,,,,,,{STR0022}) //'O valor absoluto das eliminações (K300 - campo "Valor Elimin") e a soma das parcelas do valor eliminado total (painel K310), devem ser iguais.'###'Revise os dados informados no painel K310.'
	EndIf

	If oCQX:GetValue("CQX_INDVEL") != If(nTotCQY > 0,"C",If(nTotCQY < 0, "D", " "))
		lRet := .F.
		Help(" ",1,"CQYPosVal",,STR0024,1,0,,,,,,{STR0022}) //'O indicador do valor eliminado do campo "Ind.Vlr.Elim" (CQX_INDVEL), não coincide com o total informado no painel "Registro K310:Empresas Detentoras das Parcelas do Valor Eliminado Total".'###'Revise os dados informados no painel K310.'
	EndIf

EndIf

FWRestRows(aSaveRows)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQZPreVal
Pré-validações da CQZ

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQZPreVal(oCQZ,nLinha,cAcao)
Local lRet := .T.

//-----------------------------------------------------------------------------
// Não permite a edição do K315 sem antes informar o ID do Bloco K (CQX_IDBLK)
//-----------------------------------------------------------------------------
If lRet .And. cAcao $ "CANSETVALUE|UNDELETE" .And. Empty(FWFldGet("CQX_IDBLK"))

	lRet := .F.

	If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
		MSGINFO("CQZPreVal - "+STR0027, STR0026 )	    //"Não é possivel informar o painel K315 sem possuir o ID do bloco K informado."###'Preencha o campo ID Bloco K (CQX_IDBLK).'
	Else
		Help(" ",1,"CQZPreVal",,STR0027,1, 0,,,,,,{STR0026}) //"Não é possivel informar o painel K315 sem possuir o ID do bloco K informado."###'Preencha o campo ID Bloco K (CQX_IDBLK).'
	EndIf

EndIf

//-----------------------------------------------------------------------------------------------------------------
// Ao tentar remover a deleçao, confirma se o ID do bloco K não foi alterado para consistir os dados já preenchido
//-----------------------------------------------------------------------------------------------------------------
If lRet .And. cAcao == "UNDELETE" .And. !Empty(FWFldGet("CQX_IDBLK"))

	If !Empty(oCQZ:GetValue("CQZ_EMPCPA"))
		If !ExistCpo("CQR",FWFldGet("CQX_IDBLK")+oCQZ:GetValue("CQZ_EMPCPA"),1,,.F.)
			lRet := .F.
			Help(" ",1,"CQZPreVal",,STR0060,1, 0,,,,,,{STR0059})//'Não é possivel reativar a linha. A empresa de contrapartida informada no campo "Emp.C.Part." (CQZ_EMPCPA), não possui relação com o Id.Bloco K (CQX_IDBLK), painel K300.'#'Insira uma nova linha.'
		EndIf
	EndIf

	If !Empty(oCQZ:GetValue("CQZ_CTACPA"))
		If !ExistCpo("CQU",FWFldGet("CQX_IDBLK")+oCQZ:GetValue("CQZ_CTACPA"),1,,.F.)
			lRet := .F.
			Help(" ",1,"CQZPreVal",,STR0061,1, 0,,,,,,{STR0059})//'Não é possivel reativar a linha. A conta de contrapartida informada no campo "Cta.C.Partid" (CQZ_CTACPA), não possui relação com o Id.Bloco K (CQX_IDBLK), painel K300.'#'Insira uma nova linha.'
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQZLinePos
Pós-validações da linha do CQZ

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQZLinePos()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oCQX		:= oModel:GetModel("CQXMASTER")
Local oCQY		:= oModel:GetModel("CQYDETAIL")
Local oCQZ		:= oModel:GetModel("CQZDETAIL")

//---------------------------------------------------------------------------------------------
// Verifica se o código da empresa da contrapartida é diferente do código da empresa detentora
// do valor aglutinado que foi eliminado - REGRA_EMP_COD_CONTRA_DIFERENTE_EMP_COD_PARTE
//---------------------------------------------------------------------------------------------
If lRet .And. oCQZ:GetValue("CQZ_EMPCPA") == oCQY:GetValue("CQY_CODPAR")
	lRet := .F.
	Help(" ",1,"CQZLinePos",,STR0029,1,0,,,,,,{STR0028}) //"A empresa de contraparte (K315) não pode ser igual a empresa detentora do valor eliminado (K310)."###'Altere o código da empresa de contraparte.'
EndIf

//------------------------------------------------------------------------
// Verifica se o código da conta consolidada da contrapartida é diferente
// do código da conta consolidada - REGRA_COD_CTA_DIFERENTE_COD_CONTRA
//------------------------------------------------------------------------
If lRet .And. oCQZ:GetValue("CQZ_CTACPA") == oCQX:GetValue("CQX_CODCTA")
	lRet := .F.
	Help(" ",1,"CQZLinePos",,STR0031,1,0,,,,,,{STR0030}) //"A conta de contrapartida (K315) não pode ser igual a conta consolidada (K300)."###'Altere a conta de contrapartida.'
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQZPosVal
Pós-validações dos dados da CQZ referentes ao CQY posicionado

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQZPosVal()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oCQY		:= oModel:GetModel("CQYDETAIL")
Local oCQZ		:= oModel:GetModel("CQZDETAIL")
Local aSaveRows	:= FWSaveRows()
Local nY		:= 0
Local nTotCQZ	:= 0
Local cTipLin	:= ""
Local nValLin	:= 0

If !oCQY:IsDeleted()

	//---------------------------------------------------------------------------------------------------------
	// Valida se o somatório dos valores informados no campo parcela da contrapartida do valor eliminado total
	// (K315), é igual à parcela do valor eliminado total (K310) - REGRA_SOMATORIO_VALOR_CONTRAPARTIDA
	//---------------------------------------------------------------------------------------------------------
	For nY := 1 To oCQZ:Length()

		oCQZ:GoLine( nY )

		If !oCQZ:IsDeleted()

			cTipLin	:= oCQZ:GetValue("CQZ_INDELI")
			nValLin	:= oCQZ:GetValue("CQZ_VALELI")

			If cTipLin == "D"
				nValLin *= -1
			EndIf

			nTotCQZ := (nTotCQZ) + (nValLin)

		EndIf

	Next nY

	If ABS(nTotCQZ) != oCQY:GetValue("CQY_VLRELI")
		lRet := .F.
		Help(" ",1,"CQZPosVal",,STR0034,1,0,,,,,,{STR0032}) //'O valor do campo "Valor Elim." (CQY_VLRELI) K310, não coincide com o total informado no painel "Registro K315: Empresas Contrapartes das Parcelas do Valor Eliminado Total".'###'Revise os dados informados no painel K315.'
	EndIf

	If oCQY:GetValue("CQY_INDELI") == If(nTotCQZ > 0,"C",If(nTotCQZ < 0, "D", " "))
		lRet := .F.
		Help(" ",1,"CQZPosVal",,STR0033,1,0,,,,,,{STR0032}) //'O indicador do valor eliminado do campo "Ind.Vlr.Elim" (CQY_INDELI) K310, não coincide com o total informado no painel "Registro K315: Empresas Contrapartes das Parcelas do Valor Eliminado Total".'###'Revise os dados informados no painel K315.'
	EndIf

EndIf

FWRestRows(aSaveRows)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS440Imp
Realiza a importação das contas contábeis analiticas do registro
K200 (CQU) utilizando a CTGERPlan para obter o saldo.

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CTBS440Imp()
Local lContinua	:= .T.
Local cIDBlocoK	:= ""
Local cDataApur	:= STOD("")
Local cContaDe	:= ""
Local cContaAte	:= ""
Local cMoeda	:= ""
Local cTipoSld	:= ""
Local lApaga	:= .T.
Local cDataApur	:= STOD("")
Local lMultEmp	:= .F.
Local lImpAntLP	:= .F.

If Pergunte("CTBS440IM2",.T.)

	cIDBlocoK	:= MV_PAR01
	lImpAntLP	:= MV_PAR02 == 1
	cDataApur	:= MV_PAR03
	cContaDe	:= MV_PAR04
	cContaAte	:= MV_PAR05
	cMoeda		:= MV_PAR06
	cTipoSld	:= MV_PAR07
	lApaga		:= MV_PAR08 == 1

	lMultEmp	:= MV_PAR09 == 1
	
	If lContinua .And. Empty(cIDBlocoK)
		lContinua := .F.
		Help(" ",1,"CTBS440Imp",,STR0036,1, 0,,,,,,{STR0035}) //"Identificador do bloco K não informado."###'Preencha o parâmetro "Identificador do bloco K".'
	EndIf

	If lContinua .And. Empty(cContaAte)
		lContinua := .F.
		Help(" ",1,"CTBS440Imp",,STR0038,1, 0,,,,,,{STR0037}) //"Intervalo de contas não foi informado corretamente."###'Preencha o parâmetro "Conta Até".'
	EndIf

	If lContinua .And. Empty(cMoeda)
		lContinua := .F.
		Help(" ",1,"CTBS440Imp",,STR0040,1, 0,,,,,,{STR0039}) //"Moeda do saldo não informada."###'Preencha o parâmetro "Moeda".'
	EndIf

	If lContinua .And. Empty(cTipoSld)
		lContinua := .F.
		Help(" ",1,"CTBS440Imp",,STR0041,1, 0,,,,,,{STR0042}) //"Tipo de saldo não informado."###'Preencha o parâmetro "Tipo de Saldo".'
	EndIf

	If lContinua

		//-----------------------------------------------
		// Apaga as contas do periodo para nova inclusão
		//-----------------------------------------------
		If lApaga

			MsgRun( STR0043,STR0044, { || lContinua := CTBS440Del(cIDBlocoK,cContaDe,cContaAte) } ) //"Deletando registros..."###"Aguarde"

		Else

			//----------------------------------------------------
			// Valida se já existem contas no intervalo informado
			//----------------------------------------------------
			MsgRun( STR0045,STR0044, { || lContinua := C440VldImp(cIDBlocoK,cContaDe,cContaAte) } ) //"Validando intervalo de dados..."###"Aguarde"

		EndIf

	EndIf

	//------------------------------------
	// Inclui os dados por meio do modelo
	//------------------------------------
	If lContinua

		MsgRun( STR0046,STR0044, { || lContinua := CTBS440Inc(cIDBlocoK,cContaDe,cContaAte,cMoeda,cTipoSld,cDataApur,lMultEmp,lImpAntLP) } )	//"Incluindo registros..."###"Aguarde"

		If ( !lContinua )
			Help(" ",1,"CTBS440Inc",,STR0062,1, 0,,,,,,{STR0063})//"Não há dados a serem processados."#
		EndIf

	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS440Sld
Carga do Saldo da Conta Contábil

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CTBS440Sld(cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,oModel,lMultEmp,dDataIni,dDataFim,lImpAntLP)

Local cAliasProc	:= "CT7"
Local cContaIni		:= cCodCta
Local cContaFim		:= cCodCta
Local axFil			:= {cFilAnt}
Local nRet			:= 0

Local aTmpFil := {}
Local nSldAtu := 0
Local nX
Local aArea

Default lMultEmp	:= .F.
Default dDataIni	:= GetAdvFVal("CQQ","CQQ_DTINI",XFilial("CQQ") + cIDBlK)
Default dDataFim	:= GetAdvFVal("CQQ","CQQ_DTFIM",XFilial("CQQ") + cIDBlK)
Default lImpAntLP	:= .F.

//Senão for multi-empresa, roda somente a funcao CQ0BlnQry chamada pela CtGerpLan(..), sem necessidade de criar threads
If ( !lMultEmp )

	aArea := GetArea()

	If Select("TRBTMP") > 0  //se este alias estiver em aberto 
		TRBTMP->(DBCloseArea())  // fecha pois sera usado como alias da query pela funcao CQ0BlnQry
	EndIf

	//troca da funcao de retorno de saldo da CtGerPlan para CQ0BlnQry por questao de performance
	//pois neste caso somente executa query sem criar arquivo com temporary table
	//esta funcao eh a mesma chamada pela CTGERPLAN retornando o saldo e  alias da query  eh TRBTMP
    CQ0BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cMoeda,cTpSald,CTBSetOf("")/*aSetOfBook*/,.T./*lImpMov*/,.F./*lVlrZerado*/,lImpAntLP,dDataLP,""/*cFilUsu*/,cMoeda/*cMoedaDsc*/,axFil/*aSelFil*/,/*dDtCorte*/,.F./*lTodasFil*/,aTmpFil/*aTmpFil*/ )
	
	If !lImpAntLP
		// SALDO ATUAL =  CREDITO - DEBITO
		nSldAtu := ( TRBTMP->SALDOANTCR + TRBTMP->SALDOCRD ) - ( TRBTMP->SALDOANTDB + TRBTMP->SALDODEB )
	Else
		// SALDO ATUAL =  CREDITO - DEBITO
		nSldAtu := ( TRBTMP->SALDOANTCR-TRBTMP->SLDLPANTCR + TRBTMP->SALDOCRD-TRBTMP->MOVLPCRD ) - ( TRBTMP->SALDOANTDB-TRBTMP->SLDLPANTDB + TRBTMP->SALDODEB-TRBTMP->MOVLPDEB )
	EndIf
	nRet 	:= nSldAtu

	//fecha alias TRBTMP criado na funcao CQ0BlnQry
	TRBTMP->( dbCloseArea() )
	
	//apaga os arquivos temporarios criados
	CTDelTmpFil()
	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next

	RestArea(aArea)

Else	//Do Contrario, cria-se um controle de threads para rodar a CtGerPlan(..) nas n empresas do bloco k210

	If ( oModel:IsActive() )
		nRet := CS440ManJob(oModel,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)
	EndIf	

EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS440Del
Apaga os registros do periodo selecionado para importacao

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CTBS440Del(cIDBlocoK,cContaDe,cContaAte)
Local aSaveArea	:= GetArea()
Local oModel	:= FWLoadModel("CTBS440")
Local cAliasQry	:= GetNextAlias()
Local lRet		:= .T.
Local cMsgErr	:= ""
Local cMsgSol	:= ""
Local aError	:= {}

BeginSql Alias cAliasQry

SELECT R_E_C_N_O_
FROM %table:CQX%
WHERE	CQX_FILIAL = %xfilial:CQX%
		AND CQX_IDBLK = %Exp:cIDBlocoK%
		AND CQX_CODCTA BETWEEN %Exp:cContaDe% AND %Exp:cContaAte%
		AND %NotDel%

EndSql

While (cAliasQry)->(!Eof())

	CQX->(DBGoTo((cAliasQry)->R_E_C_N_O_))

	oModel:SetOperation(MODEL_OPERATION_DELETE)

	oModel:Activate()

	If oModel:VldData()

		oModel:CommitData()

	Else

		lRet := .F.

		aError := oModel:GetErrorMessage()

		cMsgErr := aError[MODEL_MSGERR_IDFORMERR]	+ ' - '
		cMsgErr += aError[MODEL_MSGERR_IDFIELDERR]	+ ' - '
		cMsgErr += aError[MODEL_MSGERR_ID]			+ ' - '
		cMsgErr += aError[MODEL_MSGERR_MESSAGE]

		cMsgSol := aError[MODEL_MSGERR_SOLUCTION]

		Help(" ",1,"CTBS440DEL",,cMsgErr,1, 0,,,,,,{cMsgSol})

		Exit

	EndIf

	oModel:DeActivate()

(cAliasQry)->(DBSkip())
EndDo

(cAliasQry)->(DBCloseArea())

oModel:Destroy()

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C440VldImp
Consulta se já existem registros importados para o intervalo de importação

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function C440VldImp(cIDBlocoK,cContaDe,cContaAte)
Local aSaveArea	:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local lRet		:= .T.

BeginSql Alias cAliasQry
SELECT CQX_IDBLK
FROM %table:CQX%
WHERE	CQX_FILIAL = %xfilial:CQX%
		AND CQX_IDBLK = %Exp:cIDBlocoK%
		AND CQX_CODCTA BETWEEN %Exp:cContaDe% AND %Exp:cContaAte%
		AND %NotDel%
EndSql

If (cAliasQry)->(!Eof())
	lRet := .F.
	Help(" ",1,"C440VldImp",,STR0047,1, 0,,,,,,{STR0048}) //"Já existem registros cadastrados para o intervalo de contas informado."###"Revise o intervalo de contas para importação ou ative o parâmetro de sobreposição dos dados."
EndIf

(cAliasQry)->(DBCloseArea())

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS440Inc
Inclui os registros

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CTBS440Inc(cIDBlocoK,cContaDe,cContaAte,cMoeda,cTpSald,dDataLP,lMultEmp,lImpAntLP)

Local oModel	:= FWLoadModel("CTBS440")
Local cAliasQry	:= CriaTrab(,.f.)
Local lRet		:= .T.
Local cMsgErr	:= ""
Local cMsgSol	:= ""
Local aError	:= {}
Local nSaldoCta	:= 0
Local cIndCta	:= ""
Local cQuery	:= ""	
Local oModelA	:= FWLoadModel("CTBS440A")
Local oTableCQU	

Local aResultSet	:= {}
Local aRet			:= {}

Local nI			:= 0

Local cArquivo		:= ""

Local lHasError		:= .f.

cQuery := "SELECT " + chr(13)
cQuery += "	CQU_CODCTA, " + chr(13) 
cQuery += "	CQU_IDBLK " + chr(13)
cQuery += "FROM " + chr(13) 
cQuery += "	" + RetSQLName("CQU") + " CQU " + chr(13)
cQuery += "WHERE " + chr(13)
cQuery += "	CQU_FILIAL = '" + xFilial("CQU") + "' " + chr(13)
cQuery += "	AND CQU_IDBLK = '" + cIDBlocoK + "' " + chr(13)
cQuery += "	AND CQU_CODCTA BETWEEN '" + cContaDe + "' AND '" + cContaAte + "' " + chr(13)
cQuery += "	AND CQU_INDCTA = 'A' " + chr(13)
cQuery += "	AND CQU.D_E_L_E_T_ = '' " 

cQuery := ChangeQuery(cQuery)

If ( Select(cAliasQry) > 0 )
	(cAliasQry)->(DBCloseArea())
EndIf

oTableCQU := ATFTempTable(cQuery,cAliasQry)

ATFSeekTemp(oTableCQU,{{"CQU_IDBLK",cIDBlocoK}},aResultSet)

oModelA:SetOperation(MODEL_OPERATION_UPDATE)

For nI := 2 to Len(aResultSet)

	If ( lMultEmp .And. CQU->(DBSeek(xFilial("CQU") + aResultSet[nI,2] + aResultSet[nI,1]) ) )				
		oModelA:Activate()
	EndIf

	nSaldoCta	:= CTBS440Sld(cIDBlocoK,aResultSet[nI,1],cMoeda,cTpSald,dDataLP,oModelA,lMultEmp,,,lImpAntLP)
		
	If ( oModelA:IsActive() )				
		oModelA:DeActivate()
	EndIf

	lHasError  := HasErrorLog()

	//não encontrou no log de erro de execução da thread, então atualiza a tabela CQX, do contrário, não inclui	
	If ( !lHasError )

		cIndCta		:= If(nSaldoCta > 0,"C",If(nSaldoCta <= 0, "D", " "))

		oModel:SetOperation(MODEL_OPERATION_INSERT)

		oModel:Activate()

		oModel:SetValue("CQXMASTER" ,"CQX_IDBLK"  ,cIDBlocoK               )
		oModel:SetValue("CQXMASTER" ,"CQX_CODCTA" ,aResultSet[nI,1] 		)
		oModel:SetValue("CQXMASTER" ,"CQX_VALAGL" ,ABS(nSaldoCta)          )
		oModel:SetValue("CQXMASTER" ,"CQX_INDVAG" ,cIndCta                 )

		If oModel:VldData()

			oModel:CommitData()

		Else

			lRet := .F.

			aError := oModel:GetErrorMessage()

			cMsgErr := aError[MODEL_MSGERR_IDFORMERR]	+ ' - '
			cMsgErr += aError[MODEL_MSGERR_IDFIELDERR]	+ ' - '
			cMsgErr += aError[MODEL_MSGERR_ID]			+ ' - '
			cMsgErr += aError[MODEL_MSGERR_MESSAGE]

			cMsgSol := aError[MODEL_MSGERR_SOLUCTION]

			Help(" ",1,"CTBS440Inc",,cMsgErr,1, 0,,,,,,{cMsgSol})

			Exit

		EndIf

		oModel:DeActivate()

	EndIf

Next nI

oTableCQU:Delete()
FreeObj(oTableCQU)

oModel:Destroy()

If ( lHasError )
	FWExecView(STR0066,"CTBS440C",MODEL_OPERATION_VIEW)	//"Log de Erro"
	CS440CloseLog()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C440Saldo
Carrega o saldo da Conta Consolidada

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function C440Saldo()
Local oModel	:= FWModelActive()
Local oCQX		:= oModel:GetModel("CQXMASTER")
Local cIDBlocoK	:= oCQX:GetValue("CQX_IDBLK")
Local cConta	:= oCQX:GetValue("CQX_CODCTA")
Local cDataApur	:= STOD("")
Local cMoeda	:= ""
Local cTipoSld	:= ""
Local nSaldoCta	:= 0
Local cIndCta	:= ""
Local lContinua	:= .T.
Local nOper		:= oModel:GetOperation()

Local oModelA	:= FWLoadModel("CTBS440A")

Local lMultEmp	:= .F.
Local lImpAntLP	:= .T.

If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE

	If !Empty(cIDBlocoK) .And. !Empty(cConta)

		If Pergunte("CTBS440SL2",.T.)
			
			lImpAntLP	:= MV_PAR01 == 1
			cDataApur	:= MV_PAR02
			cMoeda		:= MV_PAR03
			cTipoSld	:= MV_PAR04
			
			lMultEmp	:= MV_PAR05 == 1
			
			If lContinua .And. Empty(cMoeda)
				Help(" ",1,"C440Saldo",,STR0049,1, 0,,,,,,{STR0050}) //"Não é possivel carregar o saldo."###'Informe o parâmetro "Moeda".'
			EndIf

			If lContinua .And. Empty(cTipoSld)
				Help(" ",1,"C440Saldo",,STR0049,1, 0,,,,,,{STR0051}) //"Não é possivel carregar o saldo."###'Informe o parâmetro "Tipo de Saldo".'
			EndIf

			If lContinua

				CursorWait()

				oModelA:SetOperation(MODEL_OPERATION_UPDATE)

				If ( lMultEmp .And. CQU->(DBSeek(xFilial("CQU") + cIDBlocoK + cConta)) )
					
					oModelA:Activate()

				EndIf

				nSaldoCta := CTBS440Sld(cIDBlocoK,cConta,cMoeda,cTipoSld,cDataApur,oModelA,lMultEmp,,,lImpAntLP)
				
				If ( oModelA:IsActive() )				
					oModelA:DeActivate()
				EndIf

				CursorArrow()
				
				If nSaldoCta == 0
					Help(" ",1,"C440Saldo",,STR0052,1, 0,,,,,,{STR0053}) //"O saldo da conta é igual a 0."###"Revise os parâmetros utilizados ou o período definido no registro K100."
				EndIf

				cIndCta := If(nSaldoCta > 0,"C",If(nSaldoCta < 0, "D", " "))

				oCQX:SetValue("CQX_VALAGL",ABS(nSaldoCta))
				oCQX:SetValue("CQX_INDVAG",cIndCta)

			EndIf

		EndIf

	Else
		Help(" ",1,"C440Saldo",,STR0049,1, 0,,,,,,{STR0054}) //"Não é possivel carregar o saldo."###"Informe os campos Id.Bloco K (CQX_IDBLK) e Cod.Conta (CQX_CODCTA) - K300."
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CQUFiltro
Realiza o filtro dos dados apresentados na consulta padrão CQU
conforme o ID do bloco K

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CQUFiltro()
Local lRet := .T.

If FWIsInCallStack("CTBS440Imp")

	lRet := CQU->CQU_IDBLK == MV_PAR01 .And. CQU->CQU_INDCTA == "A"

Else

	lRet := CQU->CQU_IDBLK == FWFldGet("CQX_IDBLK") .And. CQU->CQU_INDCTA == "A"

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CQRFiltro
Realiza o filtro dos dados apresentados na consulta padrão CQR2
conforme o ID do bloco K

@author TOTVS
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CQRFiltro()
Local lRet := .T.

If FWIsInCallStack("CTBS440")

	lRet := CQR->CQR_IDBLK == FWFldGet("CQX_IDBLK")

ElseIf FWIsInCallStack("CTBS430")

	lRet := CQR->CQR_IDBLK == FWFldGet("CQU_IDBLK")

EndIf

Return lRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440AddLog

Insere registro de log na tabela temporária de Logs

@params:
	cCtaAgl:	Caractere. Conta contábil aglutinadora	
	cMsgErro:	Caractere. Mensagem do erro que será guardado em log	
@return: 
	
@sample:
	CS440AddLog(cConta,cErro)
@author Fernando Radu Muscalu

@since 18/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CS440AddLog(cCtaAgl,cMsgErro)

Local cAliasLog	:= ""

Default cCtaAgl		:= ""
Default cMsgErro	:= ""

If ( !Empty(cMsgErro) )

	//Não existe a tabela temporária
	If ( Valtype(oCS440Log)  <> "O" )
		CS440TabLog()
	EndIf

	cAliasLog := oCS440Log:GetAlias()

	RecLock(cAliasLog,.t.)
		
		(cAliasLog)->CONTA_AGL	:= cCtaAgl
		(cAliasLog)->MSG_ERRO	:= cMsgErro

	(cAliasLog)->(MsUnlock())

EndIf

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440GetLog

Retorna objeto com a tabela temporária de log dos erros das execuções de multithread

@params:

@return: 
	oCS440Log: Objeto. Instância da classe FWTemporaryTable()
@sample:
	aLog := CS440GetLog()
@author Fernando Radu Muscalu

@since 18/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CS440GetLog()
 
Return(oCS440Log)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440TabLog

Cria tabela temporária de Log

@params:

@return: 
	oCS440Log: Objeto. Instância da classe FWTemporaryTable()
@sample:
	
@author Fernando Radu Muscalu

@since 14/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Function CS440TabLog()

Local aCampos	:= {}

aAdd(aCampos,{"CONTA_AGL","C",TamSx3("CQV_CODCTA")[1],0})	//Conta Aglutinadora
aAdd(aCampos,{"MSG_ERRO","C",400,0})						//Mensagem de erro

oCS440Log := FWTemporaryTable():New()

oCS440Log:SetFields(aCampos)
oCS440Log:AddIndex("1", {"CONTA_AGL"})
oCS440Log:Create()

Return(oCS440Log)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440CloseLog

Encerra a tabela temporária de log de erros

@params:

@return: 
	lRet:	Lógico. .t. Possui erro; .f. Não possui 	
@sample:
	
@author Fernando Radu Muscalu

@since 14/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CS440CloseLog()

If ( Valtype(oCS440Log) == "O" )
	oCS440Log:Delete()
	FreeObj(oCS440Log)
EndIf	

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} HasErrorLog

Verifica se existe errorLog

@params:

@return: 
	lRet:	Lógico. .t. Possui erro; .f. Não possui 	
@sample:
	
@author Fernando Radu Muscalu

@since 14/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function HasErrorLog()

Local lRet	:= .f.

//Verifica se existe o objeto da tabela temporária de log.
If ( Valtype(oCS440Log) == "O" )
	//busca a conta aglutinadora no log de erro
	lRet := ATFSeekTemp(oCS440Log,{{"CONTA_AGL",CQU->CQU_CODCTA}})
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ChkIndCons

Validação do formulário para verificar se o tipo de indicador do saldo consolidado condiz com o tipo
de conta contábil (devedora ou crededora), no caso de uma conta existente. Para contas que não constam
no plano de contas, não há validações. 

@params:
	oModel: objeto. Instância da classe FWFormModel
@return: 
	lRet:	Lógico. .t. Validado; .f. Não validado (a conta existe e o tipo difere)
@sample:
	
@author Fernando Radu Muscalu

@since 24/05/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ChkIndCons(oModel)

Local lRet	:= .t.

Local oMdlCQX	:= oModel:GetModel("CQXMASTER")

Local cTitField := oMdlCQX:GetStruct():GetProperty("CQX_INDVCS",MODEL_FIELD_TITULO)

If ( oModel:GetOperation() == MODEL_OPERATION_INSERT .or.;
	oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	
	If (!lExistCT1)
		lRet := .t.
	Else
		CQXValCons(oMdlCQX:GetValue("CQX_INDVCS"),@lRet) 
	Endif
	
	If (!lRet)
		Help(" ",1,"CQXPreVal",,STR0067,1, 0,,,,,,{STR0068 + cTitField +")."}) //"O Indicador de valor consolidado está incorreto."###"Troque o tipo de indicador (campo "
	EndIf
EndIf

Return(lRet)
