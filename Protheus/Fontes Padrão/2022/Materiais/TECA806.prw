#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TECA806.CH"

//=======================================================================================
/*/{Protheus.doc} TECA806
Execução de CheckList

@return	Nil
@author 	Israel.Escorizza
@since 		22/06/2016
@version 	12
/*/
//=======================================================================================
Function TECA806
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('TEW')
oBrowse:SetDescription(STR0001)	//= Execução de CheckList
oBrowse:SetCacheView(.F.)
oBrowse:Activate()

Return Nil

//=======================================================================================
/*/{Protheus.doc} MenuDef
Criação do menu
@return	aRotina
@author 	Israel.Escorizza
@since 		22/06/2016
@version 	12
/*/
//=======================================================================================
Static Function MenuDef()
Local aRotina	:= {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TECA806" OPERATION 1                      ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA806" OPERATION MODEL_OPERATION_VIEW   ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA806" OPERATION MODEL_OPERATION_INSERT ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA806" OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA806" OPERATION MODEL_OPERATION_DELETE ACCESS 0	// "Excluir"

Return aRotina

//=======================================================================================
/*/{Protheus.doc} ModelDef
Criação do modelo
@return	oModel
@author	Israel.Escorizza
@since		22/06/2016
@version 	12
/*/
//=======================================================================================
Static Function ModelDef()
Local oModel	:= NIL

Local oStrTEW		:= FwFormStruct(1,"TEW")		//- Cabeçalho.
Local oStrTWF		:= FwFormStruct(1,"TWF")		//- Execução de checkList.
Local oStrTEW_G		:= FwFormStruct(1,"TEW")		//- Equipamentos envolvidos.
Local cTipoTWF 		:= Iif(IsInCallStack('At806Saida'),"{'1','3'}",Iif(IsInCallStack('At806Retor'),"{'2','3'}","{'1','2','3'}"))
Local aTrigger		:= {}

//- Blocos de Pré-validação dos modelos
Local bPreVldTFW	:= {|oMdlGrid,nLine,cAction,cField,xValue,xOldValue| PreVldTWF(oMdlGrid,nLine,cAction,cField,xValue,xOldValue)}

oModel	:= MPFormModel():New("TECA806",/*bPreValid*/,/*bTudoOk*/,{|oModel| At806Grava(oModel)},{|oModel| At806Canc(oModel) })

//- Adiciona campos virtuais -------------------------------------------------------------
oStrTEW:AddField(	STR0003						,;	// 	[01]  C   Titulo do campo
				 	STR0002+" "+STR0003			,;	// 	[02]  C   ToolTip do campo
				 	"TEW_CHKLST"					,;	// 	[03]  C   Id do Field
				 	"C"								,;	// 	[04]  C   Tipo do campo
				 	1								,;	// 	[05]  N   Tamanho do campo
				 	0								,;	// 	[06]  N   Decimal do campo
				 	NIL								,;	// 	[07]  B   Code-block de validação do campo
				 	NIL								,;	// 	[08]  B   Code-block de validação When do campo
				 	{"1="+STR0004,"2="+STR0005}	,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.								,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	NIL								,;	//	[11]  B   Code-block de inicializacao do campo
				 	NIL								,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.T.								,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.								)	// 	[14]  L   Indica se o campo é virtual

oStrTEW:AddField(	STR0009						,;	// 	[01]  C   Titulo do campo
				 	STR0009						,;	// 	[02]  C   ToolTip do campo
				 	"TEW_DESCRI"					,;	// 	[03]  C   Id do Field
				 	"C"								,;	// 	[04]  C   Tipo do campo
				 	TAMSX3('B1_DESC')[1]			,;	// 	[05]  N   Tamanho do campo
				 	0								,;	// 	[06]  N   Decimal do campo
				 	NIL								,;	// 	[07]  B   Code-block de validação do campo
				 	NIL								,;	// 	[08]  B   Code-block de validação When do campo
				 	NIL								,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.								,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| Iif (!Inclui ,Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT, "B1_DESC"),"")},;	//	[11]  B   Code-block de inicializacao do campo
				 	NIL								,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.T.								,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.								)	// 	[14]  L   Indica se o campo é virtual

oStrTEW_G:AddField(STR0009						,;	// 	[01]  C   Titulo do campo
				 	STR0009						,;	// 	[02]  C   ToolTip do campo
				 	"TEW_DESCRI"					,;	// 	[03]  C   Id do Field
				 	"C"								,;	// 	[04]  C   Tipo do campo
				 	TAMSX3('B1_DESC')[1]			,;	// 	[05]  N   Tamanho do campo
				 	0								,;	// 	[06]  N   Decimal do campo
				 	NIL								,;	// 	[07]  B   Code-block de validação do campo
				 	NIL								,;	// 	[08]  B   Code-block de validação When do campo
				 	NIL								,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.								,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| Iif(!Inclui,Posicione("SB1",1,xFilial("SB1")+FwFldGet('TEW_PRODUT'),"B1_DESC"),"")}								,;	//	[11]  B   Code-block de inicializacao do campo
				 	NIL								,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.T.								,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.								)	// 	[14]  L   Indica se o campo é virtual

//- Adiciona campos ao cabeçalho
oModel:AddFields("TEWMASTER",/*cOwner*/,oStrTEW)

//- Adiciona grid ao modelo ---------------------------------------------------------------
oModel:AddGrid("TWFDETAIL",	"TEWMASTER",oStrTWF, bPreVldTFW)
oModel:AddGrid("TEWDETAIL",	"TEWMASTER",oStrTEW_G,,,,,{|oModel | At806Load(oModel ) } )

//- Relação entre os modelos
oModel:SetRelation("TWFDETAIL",	{{"TWF_FILIAL","TEW_FILIAL"},{"TWF_CODTEW","TEW_CODMV"}},TWF->(IndexKey(1)))
//oModel:SetRelation("TEWDETAIL",	{{"TEW_FILIAL","TEW_FILIAL"},{"TEW_KITSEQ","TEW_KITSEQ"}},TEW->(IndexKey(1)))

//- Modelos somente para visualização
oModel:GetModel('TEWDETAIL'):SetOnlyQuery(.T.)
//- Grid somente dos dias normais
oModel:GetModel("TWFDETAIL"):SetLoadFilter( { { "TWF_TIPTWD", cTipoTWF , MVC_LOADFILTER_IS_CONTAINED } } )
//oModel:GetModel("TEWDETAIL"):SetLoadFilter( { { "TEW_CODKIT", "' '" , MVC_LOADFILTER_NOT_EQUAL } } )

//- Modelos de preenchimento não obrigatórios
oModel:GetModel('TWFDETAIL'):SetOptional(.T.)
oModel:GetModel('TEWDETAIL'):SetOptional(.T.)

//- Chave primaria do modelo
oModel:SetPrimaryKey( {} )

oModel:SetVldActivate({|oModel| At806VlAct(oModel)})
oModel:SetActivate({|oModel| At806Act(oModel)})

Return oModel

//=======================================================================================
/*/{Protheus.doc} ViewDef
Criação do modelo
@return	oView
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Static Function ViewDef()
Local oView	:= FWFormView():New()
Local oModel	:= ModelDef()

//- Filtro de campos
Local cCamposTEW 	:= "TEW_CHKLST|TEW_CONTRT|TEW_LOCAL|TEW_DSLOC|TEW_CODMV|TEW_TIPO|TEW_PRODUT|TEW_BAATD|TEW_NUMPED|TEW_NFSAI|TEW_SERSAI|TEW_NFENT|TEW_SERENT"
Local cCamposTWF	:= "TWF_ITCHK|TWF_ITEM|TWF_DESCIT|TWF_EXEC|TWF_NOMUSR|TWF_DTEXEC|TWF_HREXEC"
Local cCampTEW_G	:= "TEW_CODMV|TEW_PRODUT|TEW_DESCRI|TEW_BAATD"

//- Criação de estrutura
Local oStrTEW		:= FwFormStruct(2,"TEW",{|cCampo| AllTrim(cCampo) $ cCamposTEW  })		//- Cabeçalho
Local oStrTWF		:= FwFormStruct(2,"TWF",{|cCampo| AllTrim(cCampo) $ cCamposTWF  })		//- Execução de CheckList.
Local oStrTEW_G		:= FwFormStruct(2,"TEW",{|cCampo| AllTrim(cCampo) $ cCampTEW_G  })		//- Equipamentos envolvidos.

//- Adiciona campos virtuais -------------------------------------------------------------
oStrTEW:AddField(	"TEW_CHKLST"					,;	// [01]  C   Nome do Campo
					"01"							,;	// [02]  C   Ordem
					STR0003						,;	// [03]  C   Titulo do campo
					STR0002+" "+STR0003			,;	// [04]  C   Descricao do campo
					NIL								,;	// [05]  A   Array com Help
					"C"								,;	// [06]  C   Tipo do campo
					NIL								,;	// [07]  C   Picture
					NIL								,;	// [08]  B   Bloco de Picture Var
					NIL								,;	// [09]  C   Consulta F3
					.T.								,;	// [10]  L   Indica se o campo é alteravel
					NIL								,;	// [11]  C   Pasta do campo
					NIL								,;	// [12]  C   Agrupamento do campo
					{"1="+STR0004,"2="+STR0005}	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL								,;	// [15]  C   Inicializador de Browse
					.T.								,;	// [16]  L   Indica se o campo é virtual
					NIL								,;	// [17]  C   Picture Variavel
					.T.								)	// [18]  L   Indica pulo de linha após o campo

oStrTEW:AddField(	"TEW_DESCRI"					,;	// [01]  C   Nome do Campo
					"06"							,;	// [02]  C   Ordem
					STR0009						,;	// [03]  C   Titulo do campo
					STR0009						,;	// [04]  C   Descricao do campo
					NIL								,;	// [05]  A   Array com Help
					"C"								,;	// [06]  C   Tipo do campo
					"@!"							,;	// [07]  C   Picture
					NIL								,;	// [08]  B   Bloco de Picture Var
					NIL								,;	// [09]  C   Consulta F3
					.F.								,;	// [10]  L   Indica se o campo é alteravel
					NIL								,;	// [11]  C   Pasta do campo
					NIL								,;	// [12]  C   Agrupamento do campo
					NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL								,;	// [15]  C   Inicializador de Browse
					.T.								,;	// [16]  L   Indica se o campo é virtual
					NIL								,;	// [17]  C   Picture Variavel
					NIL								)	// [18]  L   Indica pulo de linha após o campo

oStrTEW_G:AddField("TEW_DESCRI"					,;	// [01]  C   Nome do Campo
					"06"							,;	// [02]  C   Ordem
					STR0009						,;	// [03]  C   Titulo do campo
					STR0009						,;	// [04]  C   Descricao do campo
					NIL								,;	// [05]  A   Array com Help
					"C"								,;	// [06]  C   Tipo do campo
					"@!"							,;	// [07]  C   Picture
					NIL								,;	// [08]  B   Bloco de Picture Var
					NIL								,;	// [09]  C   Consulta F3
					.F.								,;	// [10]  L   Indica se o campo é alteravel
					NIL								,;	// [11]  C   Pasta do campo
					NIL								,;	// [12]  C   Agrupamento do campo
					NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL								,;	// [15]  C   Inicializador de Browse
					.T.								,;	// [16]  L   Indica se o campo é virtual
					NIL								,;	// [17]  C   Picture Variavel
					NIL								)	// [18]  L   Indica pulo de linha após o campo


oView:SetModel(oModel)
oView:AddField(	"VIEW_TEW",		oStrTEW,		"TEWMASTER"	)
oView:AddGrid( 	"VIEW_TEW_G",	oStrTEW_G,		"TEWDETAIL"	)
oView:AddGrid( 	"VIEW_TWF",		oStrTWF,		"TWFDETAIL"	)


//- Definição de formato de tela ----------------------------------------------------------
oView:CreateHorizontalBox("CABEC",25)
oView:CreateHorizontalBox("PASTA",75)

oView:CreateFolder("FLDITEM","PASTA")

oView:AddSheet("FLDITEM","GRDITEM",STR0006)
oView:CreateHorizontalBox("ITENS",100,,,"FLDITEM","GRDITEM")

oView:AddSheet("FLDITEM","GRDEQUI",STR0007)
oView:CreateHorizontalBox("EQUIP",100,,,"FLDITEM","GRDEQUI")

//- Associa componentes as pastas ---------------------------------------------------------
oView:SetOwnerView("VIEW_TEW",		"CABEC")
oView:SetOwnerView("VIEW_TWF",		"ITENS")
oView:SetOwnerView("VIEW_TEW_G",	"EQUIP")

oView:AddUserButton(STR0011, 'CLIPS', {|oView|  TECR806()})//'Imprimir Checklist'

Return oView

//=======================================================================================
/*/{Protheus.doc} At806VlAct()
Pré ativação do modelo
@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806VlAct()
Local lRet := .T.
Return lRet

//=======================================================================================
/*/{Protheus.doc} At806Act()
Pós ativação do modelo
@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Act(oModel)
Local lRet := .T.
Default oModel := FwModelActive()
	If IsInCallStack('At806Saida')
		oModel:LoadValue("TEWMASTER","TEW_CHKLST","1")
	EndIf

	If IsInCallStack('At806Retor')
		oModel:LoadValue("TEWMASTER","TEW_CHKLST","2")
	EndIf

	TECBlView(oModel:GetModel('TEWDETAIL'),.F.,.F.,.F.)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		TECBlView(oModel:GetModel('TWFDETAIL'),.F.,.F.,.T.)
	Else
		TECBlView(oModel:GetModel('TWFDETAIL'),.F.,.F.,.F.)
	EndIf

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	oModel:lModify := .F.
EndIf

Return lRet

//=======================================================================================
/*/{Protheus.doc} At806ExChk(cTipo)
Função para verificação se o checklist deverá ser aberto em modo de execução (Update)

@param		cTipo:		1- Saida
						2- Retorno

@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806ExChk(cTipo)
Local lRet := .F.

DO	CASE
	CASE cTipo == '1'
		If 	TEW->TEW_DTSEPA <> CTOD('') .And. TEW->TEW_DTRINI == CTOD('') //- Equipamento Separado
			lRet := .T.
		EndIf

	CASE cTipo == '2'
		If (TEW->TEW_MOTIVO == ' ' .And. ((TEW->TEW_DTRFIM <> CTOD('') .And. Empty(TEW->TEW_NUMOS)) .Or. (TEW->TEW_DTRFIM <> CTOD('') .And. !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS <> CTOD('')))) .Or.; //- Devolvido
			(TEW->TEW_MOTIVO $ '1|2' .And. TEW->TEW_DTRFIM <> CTOD('')) .Or. ; //- Substituido/Cancelado e Devolvido
			(TEW->TEW_DTRFIM <> CTOD('') .And. !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS == CTOD('')) //- Devolvido e Em manutenção"

			lRet := .T.
		EndIf
ENDCASE

Return lRet

//=======================================================================================
/*/{Protheus.doc} At806Saida()
Função para chamada do checklist de saida
@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Saida()
Local aSaveLines	:= FwSaveRows()
Local aArea		:= GetArea()
Local nOper		:= Iif(At806ExChk('1'),MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW)

DbSelectArea("TWE")
TWE->(DbSetOrder(2))
If TWE->(DbSeek(xFilial("TWE")+TEW->TEW_PRODUT)) .OR. TWE->(DbSeek(xFilial("TWE")+TEW->TEW_CODKIT)) //Verifica se o produto esta amarrado com algum CheckList
	DbSelectArea("TWF")
	TWF->(DbSetOrder(4))
	If TWF->(DbSeek(xFilial("TWF")+TEW->TEW_CODMV)) //Verifica se existe movimentações
		DbSelectArea("TWC")
		TWC->(DbSetOrder(1))
		If TWC->(DbSeek(xFilial("TWC")+TWF->TWF_CODTWC))
			If TWC->TWC_MSBLQL == "2" //Verifica se esta bloqueado
				If nOper == MODEL_OPERATION_VIEW
					MsgInfo(STR0012,STR0010+STR0004) //"Modo de visualização." # "CheckList de " # "Saida"
				Endif
				FWExecView(STR0010+STR0004,"TECA806",nOper,,{|| .T.})
			Else
				Help(,, "At806Saida",,STR0013+TEW->TEW_CODMV+", "+STR0014,1,0,,,,,,{STR0015}) //"O CheckList: " # "esta bloqueado." # "Realize o desbloqueio."
			Endif
		Endif
	Else
		Help(,, "At806Saida",,STR0016,1,0,,,,,,{STR0017}) //"Não existe movimentações para o CheckList." # "Realize as movimentações."
	Endif
Else
	Help(,, "At806Saida",,STR0018,1,0,,,,,,{STR0019}) //"O produto da movimentação não está relacionado com CheckList." # "Verifique se existe o produto relacionado."
Endif

RestArea(aArea)
FWRestRows( aSaveLines )
Return Nil

//=======================================================================================
/*/{Protheus.doc} At806Retor()
Função para chamada do checklist de retorno
@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Retor()
Local aSaveLines	:= FwSaveRows()
Local aArea		:= GetArea()
Local nOper		:= Iif(At806ExChk('2'),MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW)

DbSelectArea("TWE")
TWE->(DbSetOrder(2))
If TWE->(DbSeek(xFilial("TWE")+TEW->TEW_PRODUT)) .OR. TWE->(DbSeek(xFilial("TWE")+TEW->TEW_CODKIT))
	DbSelectArea("TWF")
	TWF->(DbSetOrder(4))
	If TWF->(DbSeek(xFilial("TWF")+TEW->TEW_CODMV)) //Verifica se existe movimentações
		DbSelectArea("TWC")
		TWC->(DbSetOrder(1))
		If TWC->(DbSeek(xFilial("TWC")+TWF->TWF_CODTWC))
			If TWC->TWC_MSBLQL == "2" //Verifica se esta bloqueado
				If nOper == MODEL_OPERATION_VIEW
					MsgInfo(STR0012,STR0010+STR0005)  //"Modo de visualização." # "CheckList de " # "Retorno"
				Endif
				FWExecView(STR0010+STR0005,"TECA806",nOper,,{|| .T.})
			Else
				Help(,, "At806Retor",,STR0013+TWC->TWC_CODIGO+", "+STR0014,1,0,,,,,,{STR0015}) //"O CheckList: " # "esta bloqueado" # "Realize o desbloqueio."
			Endif
		Endif
	Else
		Help(,, "At806Saida",,STR0016+TWE->TWE_CODTWC,1,0,,,,,,{STR0017}) //"Não existe movimentações para o CheckList." # "Realize as movimentações."
	Endif
Else
	Help(,, "At806Retor",,STR0018,1,0,,,,,,{STR0019}) //"O produto da movimentação não está relacionado com CheckList." # "Verifique se existe o produto relacionado."
Endif

RestArea(aArea)
FWRestRows( aSaveLines )
Return Nil

//=======================================================================================
/*/{Protheus.doc} PreVldTWF
Pré-valid do modelo TWFDETAIL
@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function PreVldTWF(oMdlGrid,nLine,cAction,cField,xValue,xOldValue)
Local lRet	:= IsInCallStack('At806ExUsr') .OR. IsInCallStack('At806Inc')
Local cTipoChk := ''
DO 	CASE
	CASE cAction == 'CANSETVALUE'
		lRet := IIf(cField == 'TWF_EXEC',.T.,.F.)
	CASE cAction == 'SETVALUE'
		If cField == 'TWF_EXEC'
			cTipoChk := oMdlGrid:GetModel():GetValue('TEWMASTER','TEW_CHKLST')
			lRet := At806ExUsr(oMdlGrid,xValue,cTipoChk)
		EndIf
ENDCASE

Return lRet
//=======================================================================================
/*/{Protheus.doc} At806ExUsr(oMdlGrid,cTipo)
Função para executar função definida pelo usuário no checklist

@param		cTipo:		1- Marcado
						2- Desmarcado

@return	lRet
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806ExUsr(oMdlGrid,cValor,cTipoChk)
Local aSaveLines	:= FwSaveRows()
Local aArea		:= GetArea()
Local lRet 		:= .F.
Local cCodChk		:= oMdlGrid:GetValue('TWF_CODTWC')
Local cItmChk		:= oMdlGrid:GetValue('TWF_ITEM')
Local cFuncao		:= ""
Local cCodUrs		:= RetCodUsr()
Local dData			:= dDataBase
Local cTime			:= SubStr( Time(), 1, 5 )
Local oMdlPrinc 	:= oMdlGrid:GetModel()
dbSelectArea('TWD')
dbSetOrder(1)	//TWD_FILIAL+TWD_CODTWC+TWD_ITEM
If TWD->(MsSeek(xFilial('TWD')+cCodChk+cItmChk))
	cFuncao := Iif(cValor == "1",AllTrim(TWD->TWD_COMEXE),AllTrim(TWD->TWD_COMDES))
EndIf
If !Empty(cFuncao)
	At806PTbUs(oMdlGrid)

	Begin Transaction

		lRet := &cFuncao.( oMdlGrid, cValor, cTipoChk)
		
		If Valtype(lRet) != 'L' .Or. !lRet
			DisarmTransaction()
		EndIf
	End Transaction
Else
	lRet := .T.
EndIf	

If lRet
	If cValor == "1"
		oMdlGrid:SetValue('TWF_CODUSR', cCodUrs)
		oMdlGrid:SetValue('TWF_DTEXEC', dData)
		oMdlGrid:SetValue('TWF_HREXEC', cTime)
	Else
		oMdlGrid:SetValue('TWF_CODUSR', "")
		oMdlGrid:SetValue('TWF_DTEXEC', CTOD(""))
		oMdlGrid:SetValue('TWF_HREXEC', "")
	EndIf
EndIf

RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//=======================================================================================
/*/{Protheus.doc} At806PTbUs()
Função para Posicionar tabelas antes da execução da função de usuário

@param		Nil
@return	Nil
@author	Israel.Escorizza
@since		23/06/2016
@version 	12
/*/
//=======================================================================================
Function At806PTbUs(oMdlGrid)
Local oModel 		:= oMdlGrid:GetModel()
Local oModelTEW	:= oModel:GetModel('TEWMASTER')


		//-Posiciona Tabelas de acordo com a TEW posicionada.
		dbSelectArea('TFJ')
		TFJ->(dbSetOrder(1)) //- TFJ_FILIAL+TFJ_CODIGO
		TFJ->(MsSeek(xFilial('TFJ')+oModelTEW:GetValue('TEW_ORCSER')))

		dbSelectArea('TFI')
		TFI->(dbSetOrder(1)) //- TFI_FILIAL+TFI_COD
		TFI->(MsSeek(xFilial('TFI')+oModelTEW:GetValue('TEW_CODEQU')))

		dbSelectArea('TFL')
		TFL->(dbSetOrder(1))	//- TFL_FILIAL+TFL_CODIGO
		TFL->(MsSeek(xFilial('TFL')+TFI->TFI_CODPAI))

		dbSelectArea('ABS')
		ABS->(dbSetOrder(1))	//- ABS_FILIAL+ABS_LOCAL
		ABS->(MsSeek(xFilial('ABS')+TFI->TFI_LOCAL))

		dbSelectArea('AA3')
		AA3->(dbSetOrder(6)) //- AA3_FILIAL+AA3_NUMSER
		AA3->(MsSeek(xFilial('AA3')+oModelTEW:GetValue('TEW_BAATD')))

		dbSelectArea('CN9')
		CN9->(dbSetOrder(1)) //- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		CN9->(MsSeek(xFilial('CN9')+TFI->(TFI_CONTRT+TFI_CONREV)))

Return
//=======================================================================================
/*/{Protheus.doc} At806Inc()
Realiza a inclusão da execução do Cheklist.

@sample At806Inc(cCodMov,cCodLoc,cSqKit,cProd)

@param	cCodMov, CHAR, Codigo da movimentação - TEW.
@param	cCodLoc, CHAR, Codigo da locação de equipamentos - TFI.
@param	cSqKit,  CHAR, Codigo da seguqencia do kit.
@param	cProd, 	 CHAR, Codigo do Produto.

@return	Nil
@author	Kaique Schiller
@since		24/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Inc(cCodMov,cCodLoc,cSqKit,cProd,cPrdKit)
Local aArea 		:= GetArea()
Default cCodMov 	:= ""
Default cCodLoc 	:= ""
Default cSqKit  	:= ""
Default cProd		:= ""
Default cPrdKit		:= ""

If !Empty(cCodMov) .AND. !Empty(cCodLoc) .AND. !Empty(cProd)

	DbSelectArea("TEW")
	TEW->(DbSetOrder(1))
	If TEW->(DbSeek(xFilial('TEW')+cCodMov)) //Verifica se existe a movimentação.
			
		DbSelectArea("TWE")
		TWE->(DbSetOrder(2))
		If TWE->(dbSeek(xFilial("TWE")+cProd)) .OR. ;
			(!Empty(cPrdKit) .And. TWE->(dbSeek(xFilial("TWE")+cPrdKit))) //Verifica se existe o produto

			DbSelectArea("TWD")
			TWD->(DbSetOrder(1))
			If TWD->(dbSeek(xFilial("TWD")+TWE->TWE_CODTWC)) 

				DbSelectArea("TWF")

				While !TWD->(Eof()) .AND. TWD->TWD_FILIAL == TWE->TWE_FILIAL .AND. TWD->TWD_CODTWC == TWE->TWE_CODTWC

					If TWD->TWD_TIPO == '3'
						//  cria um registro para o checklist de saída
						At806Cria( cCodMov, cCodLoc, cSqKit, "2" )
						//  cria outro registro para o checklist de retorno
						At806Cria( cCodMov, cCodLoc, cSqKit, "1" )
					Else
						At806Cria( cCodMov, cCodLoc, cSqKit, TWD->TWD_TIPO )
					EndIf
										
					TWD->(DbSkip())

				End
			Endif
		Endif
	Endif
Endif

RestArea(aArea)

Return .T.

/*/{Protheus.doc} At806Cria()
	Função para unificar o momento de criação dos registro para execução do checklist no sistema

@param	cCodMov, Caracter, Codigo da movimentação - TEW.
@param	cCodLoc, Caracter, Codigo da locação de equipamentos - TFI.
@param	cSqKit,  Caracter, Codigo da seguqencia do kit.
@param	cChkTipo,Caracter, Tipo a ser criado no registro para execução do checklist 1=Retorno;2=Saída;3=Ambos

@author	Inovação Gestão de Serviços
@since		23/09/2016
@version 	12
/*/
Static Function At806Cria( cCodMov, cCodLoc, cSqKit, cChkTipo )

Default cChkTipo := TWD->TWD_TIPO

RecLock("TWF",.T.)

	TWF->TWF_FILIAL := xFilial("TWF")
	TWF->TWF_CODIGO := GetSXENum("TWF", "TWF_CODIGO")
	TWF->TWF_CODTEW := cCodMov
	TWF->TWF_CODTFI := cCodLoc
	TWF->TWF_KITSEQ := cSqKit
	TWF->TWF_CODTWC := TWD->TWD_CODTWC
	TWF->TWF_ITEM   := TWD->TWD_ITEM
	TWF->TWF_TIPTWD := cChkTipo
	TWF->TWF_EXEC 	:= "2"

TWF->(MsUnlock())

TWF->(ConfirmSx8())

Return

//=======================================================================================
/*/{Protheus.doc} At806Load()
	Realiza a carga dos equipamentos.

@sample At806Load(oMdl)

@param		oMdl, OBJETO, Modelo ativo no momento.

@return		aRet. ARRAY , Array com a carga dos dados.	
@author	Kaique Schiller
@since		24/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Load(oMdl)
Local aRet    	 := {}
Local cTmpQry    := GetNextAlias()
Local cWhere 	 :=	""

If Empty(TEW->TEW_CODKIT) //Se não for KIT, realiza a query pelo codigo da movimentação.
	cWhere := " TEW_CODMV = '" + TEW->TEW_CODMV + "'"
	cWhere := '%' + cWhere + '%'	
Else
	cWhere := " TEW_KITSEQ = '" + TEW->TEW_KITSEQ + "'"
	cWhere := '%' + cWhere + '%'	
Endif

BeginSql Alias cTmpQry

	SELECT TEW_CODMV, 
		   TEW_PRODUT, 
		   TEW_BAATD 
	FROM %Table:TEW% TEW
	WHERE %Exp:cWhere%
		AND TEW.%NotDel%
		AND TEW_FILIAL = %xFilial:TEW%
	ORDER BY TEW_PRODUT

EndSql

aRet := FwLoadByAlias( oMdl, cTmpQry )

(cTmpQry)->(DbCloseArea())

Return aRet

//=======================================================================================
/*/{Protheus.doc} At806Load()
	Realiza a gravação do modelo.

@sample At806Grava(oModel)

@param		oModel, OBJETO, Modelo ativo no momento.

@return		lRet. LOGICO , Define se realizou a gravação.	
@author	Kaique Schiller
@since		24/06/2016
@version 	12
/*/
//=======================================================================================
Function At806Grava(oModel)
Local aAreaTWF		:= TWF->(GetArea())
Local oMdlTWF 		:= Nil 
Local cKitSq		:= "" //Squencia do KIT
Local cExec			:= "" //Executado?
Local cCodUsr		:= "" //Codigo Usuário
Local cDtExec		:= "" //Data da Execução
Local cHrExec		:= "" //Hora da Execução
Local nX			:= 0
Local lRet			:= .F.
Local cTmpQry 		:= ""
LOcal cItem 		:= ""

If oModel:VldData()
	lRet := FwFormCommit(oModel)

	If lRet

		oMdlTWF := oModel:GetModel("TWFDETAIL")
		
		For nX := 1 To oMdlTWF:Length()
			oMdlTWF:GoLine(nX)

			cItem   := oMdlTWF:GetValue("TWF_ITEM")
			cKitSq	:= oMdlTWF:GetValue("TWF_KITSEQ")
			cExec	:= oMdlTWF:GetValue("TWF_EXEC")
			cCodUsr	:= oMdlTWF:GetValue("TWF_CODUSR")
			cDtExec	:= oMdlTWF:GetValue("TWF_DTEXEC")
			cHrExec	:= oMdlTWF:GetValue("TWF_HREXEC")
						
			If !Empty(cKitSq) .AND. !Empty(cItem) .AND. !Empty(cExec)

				cTmpQry    	:= GetNextAlias()

				BeginSql Alias cTmpQry
				
					SELECT TWF_CODIGO
					FROM %Table:TWF% TWF
					WHERE TWF_KITSEQ = %Exp:cKitSq%
						AND TWF_ITEM = %Exp:cItem%
						AND TWF_FILIAL = %xFilial:TWF%
						AND TWF.%NotDel%
					ORDER BY TWF_CODIGO
				EndSql
			
				If !(cTmpQry)->(Eof())
					DbSelectArea("TWF")
					TWF->(DbSetOrder(1))
					While !(cTmpQry)->(Eof())
						If TWF->(DbSeek(xFilial("TWF")+(cTmpQry)->TWF_CODIGO))
							RecLock("TWF",.F.)

								TWF->TWF_EXEC   := cExec
								TWF->TWF_CODUSR := cCodUsr
								TWF->TWF_DTEXEC := cDtExec
								TWF->TWF_HREXEC := cHrExec

							TWF->(MsUnLock())
						Endif
						(cTmpQry)->(dbSkip())
					End
				Endif
				(cTmpQry)->(DbCloseArea())
			Endif
		Next nX
	Endif
Endif

RestArea(aAreaTWF)

Return lRet

/*/{Protheus.doc} At806Canc()
	Função executada durante o cancelamento dos dados do modelo, irá verificar se houve alteração e questionar 
novamente o usuário se confirma a alteração

@author		Inovação Gestão de Serviços
@param		oModel, objeto FwFormModel/MpFormModel, modelo principal do MVC
@return		Lógico, determina se pode realizar ou não o cancelamento dos dados	
@since		15/09/2016
@version 	12
/*/
Static Function At806Canc(oModel)
Local lRet := .F.

If oModel:GetModel('TEWMASTER'):IsModified()
	lRet := MsgNoYes(STR0020 + CRLF + ; // 'Você está cancelando o checklist inteiro!'
					STR0021 + CRLF + ;  // 'Eventuais alterações executadas durante a confirmação em quaisquer dos itens não serão desfeitas sem que os itens sejam desmarcados.'
					STR0022,;  // 'Tem certeza que deseja continuar?'
					'Checklist')
EndIf
Return lRet 