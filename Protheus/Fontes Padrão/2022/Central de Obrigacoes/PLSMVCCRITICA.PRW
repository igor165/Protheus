#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CODCRI         1 // Codigo da critica
#DEFINE CODANS         2 // Função de Validação da Crítica
#DEFINE FUNCAO         3 // Função de Validação da Crítica
#DEFINE DESCRI         4 // Descricao
#DEFINE SOLUCAO        5 // Solucao
#DEFINE TOTALIZA       6 // Indicacao de critica totalizadora
#DEFINE CAMPOS         7 // Campos para enviar à ANS

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar

#DEFINE CRIT_PDTE     "1"  // Pendente Validação
#DEFINE CRIT_CORR     "2"  // Valido

#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Invalido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado

//Status dos compromissos
#DEFINE PDTE_ENVIO	"1"
#DEFINE CRITICADO	"2"
#DEFINE PRONT_ENV	"3"
#DEFINE ENV_ANS		"4"
#DEFINE CRIT_ANS	"5"
#DEFINE FINALIZ		"6"

#DEFINE JOBVALIDA 		"1"
#DEFINE JOBESPELHO 		"2"
#DEFINE CRITRETORNO 	"3"

#DEFINE OBR_SIP 		"1"
#DEFINE OBR_SIB 		"2"
#DEFINE OBR_DIOPS	 	"3"

#DEFINE ARQ_LOG_EXC		"log_exclusao_critica.log"
#DEFINE ARQ_LOG_INC		"log_inclusao_critica.log"

#DEFINE DMED 			"4"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef(lAuto)

	Local aRotina := {}
	Default lAuto := .F.

	ADD OPTION aRotina Title 'Pesquisar'					Action 'PesqBrw'					OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' 					Action 'VIEWDEF.PLSMVCCRITICA'		OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Visualiza Cadastro' 			Action 'PLCOExiCad(.F.)'			OPERATION 2 ACCESS 0
	If !(B3D->B3D_TIPOBR == DMED) .AND. !lAuto
		ADD OPTION aRotina Title 'Comparar ANS x Central' 	Action 'PLCOComCad(.F.)'		OPERATION 2 ACCESS 0
		If !(lIsMonit)
			ADD OPTION aRotina Title 'Enviar Alt. ANS' 		Action 'PLSALTANS(.F.,.F.)'		OPERATION 2 ACCESS 0
		EndIf
	EndIf
Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3D e B3F

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
	Local oModel 		:= MPFormModel():New( 'PLSMVCCRITICA' )

	oModel:AddFields( 'B3FMASTER', /*cOwner*/ , oStruB3F )
	oModel:SetDescription( 'Críticas' )
	oModel:GetModel( 'B3FMASTER' ):SetDescription( "Críticas" )

	oModel:SetPrimaryKey({})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3D e B3F

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 	:= FWLoadModel( 'PLSMVCCRITICA' )
	Local oStruB3F 	:= FWFormStruct( 2, 'B3F' )
	Local oView 	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3F', oStruB3F, 'B3FMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B3F', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B3F', "Críticas no Processamento" )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOExiCad

Funcao criada para exibir as telas de cadastros de beneficiario, produto ou despesa

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCOExiCad(lAuto,oBrowUp,lMrk,lVis)

	Local lOk := .F.
	Local cAliasOri := B3F->B3F_ORICRI
	Local nRecno := B3F->B3F_CHVORI
	Local cCodope := B3F->B3F_CODOPE
	Local cMatric := B3F->B3F_IDEORI
	Local cRotina := ""
	Local aArea	  := {}
	Local aRet    := {}
	Local lRet    := .T.
	Default lMrk  := .F.
	Default lAuto := .F.
	default oBrowUp:=nil
	default lVis   :=.F.

	If lMrk .And. !lAuto
		aRet:=CnCritPMrk(oBrowUp,.T.)

		If Len(aRet)<>1
			Alert("Selecione 1 registro para visualizar")
			lRet:=.F.
		Else
			If aRet[1,1] == B3F->(Recno())
				B3F->(DbGoTo(aRet[1,1]))
				cAliasOri := B3F->B3F_ORICRI
				nRecno := B3F->B3F_CHVORI
				cCodope := B3F->B3F_CODOPE
				cMatric := B3F->B3F_IDEORI
				lOk:=.T.
				If lVis
					lRet:=.F.
					FWExecView('Visualização',"PLSMVCCRITICA",MODEL_OPERATION_VIEW)
				Endif
			Else
				lRet:=.F.
				Alert("Selecione e marque o mesmo registro!")
			Endif
		EndIf
	Endif

	If lRet
		If Empty(cAliasOri)
			If !lAuto
				Alert("Selecione uma crítica para visualizar o cadastro de origem")
			EndIf
		Else

			aArea := (cAliasOri)->(GetArea())
			(cAliasOri)->(DbGoTo(nRecno))

			If cAliasOri == "B3K"
				(cAliasOri)->(DbSetOrder(1))
				//B3K_FILIAL+B3K_CODOPE+B3K_MATRIC+B3K_STATUS
				//Seek por recno não esta funcionando por quebra de relacionamento em alguns clientes
				(cAliasOri)->(MsSeek(xFilial("B3K")+cCodope+PADR(cMatric,tamSX3("B3K_MATRIC")[1])))
				cRotina := 'PLSMVCBENE'
			ElseIf cAliasOri == "B3X"
				B3K->(DbGoTo(B3X->B3X_BENEF))
				cRotina := 'PLSMVCBENE'
			ElseIf cAliasOri == "B3J"
				cRotina := 'PLSMVCPRO'
			ElseIf cAliasOri == "B3L"
				cRotina := 'PLSMVCDESP'
			ElseIf cAliasOri $ "BKR,BKS,BKT"
				cRotina := 'CENMVCBKR'
				If cAliasOri == 'BKS'
					BKR->(DbSetOrder(1)) //BKR_FILIAL+BKR_CODOPE+BKR_NMGOPE+BKR_CDOBRI+BKR_ANO+BKR_CDCOMP+BKR_LOTE+DTOS(BKR_DTPRGU)
					BKR->( MsSeek(xFilial("BKR")+BKS->(BKS_CODOPE+BKS_NMGOPE+BKS_CDOBRI+BKS_ANO+BKS_CDCOMP+BKS_LOTE) + DTOS(BKS->BKS_DTPRGU) ) )
				ElseIf cAliasOri == 'BKT'
					BKR->(DbSetOrder(1))
					BKR->( MsSeek(xFilial("BKR")+BKT->(BKT_CODOPE+BKT_NMGOPE+BKT_CDOBRI+BKT_ANO+BKT_CDCOMP+BKT_LOTE) + DTOS(BKT->BKT_DTPRGU) ) )
				EndIf
			ElseIf cAliasOri $ "BVQ,BVT"
				cRotina := 'CENMVCBVQ'
				If cAliasOri == 'BVT'
					BVQ->(DbSetOrder(1)) //BVQ_FILIAL+BVQ_CODOPE+BVQ_NMGPRE+BVQ_CDOBRI+BVQ_ANO+BVQ_CDCOMP+BVQ_LOTE+DTOS(BVQ_DTPRGU)
					BVQ->( MsSeek(xFilial("BVQ")+BVT->(BVT_FILIAL+BVT_CODOPE+BVT_NMGPRE+BVT_CDOBRI+BVT_ANO+BVT_CDCOMP+BVT_LOTE) + DTOS(BKT->BVT_DTPRGU) ) )
				EndIf
			ElseIf cAliasOri == "B3W"
				cRotina := 'PLSMVCB3W'
			ElseIf cAliasOri == "B2W"
				cRotina := 'CENMVCB2W'

			Else
				cRotina := 'PLSMVC'+cAliasOri
			EndIf

			If Findfunction(cRotina)
				If !lAuto
					FWExecView('Visualização',cRotina,MODEL_OPERATION_VIEW)
				EndIf
				lOk := .T.
			Else
				If !lAuto
					Alert("Não existe rotina para visualizar o cadastro da tabela " + cAliasOri)
				EndIf
			EndIf

			(cAliasOri)->(RestArea(aArea))

		EndIf
	Endif
Return lOk
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLBRWCrit

Tela que exibe as criticas

@author everton.mateus
@since 13/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLBRWCrit(cFiltro, lAuto, lMonit)

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer
	Local oPnl
	Local oFWLayerUp
	Local oFWLayerDown
	Local oBrowUp
	Local oBrwBenef
	Local oPnlCriUp
	Local oPnlCriDown
	Local lDmed   :=B3D->B3D_TIPOBR == "4"

	Private oDlgPrinc
	Private lIsMonit

	Default cFiltro := ""
	Default lAuto := .F.
	Default lMonit := .F.

	lIsMonit := lMonit

	Define MsDialog oDlgPrinc Title 'Criticas' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINE', 100, .F. )
	oFWLayer:AddCollumn( 'COLLUP', 100, .T., 'LINE' )
	oFWLayer:AddCollumn( 'COLLDOWN', 100, .T., 'LINE' )

	oPnlCriUp := oFWLayer:GetColPanel( 'COLLUP', 'LINE' )
	oPnlBenDown := oFWLayer:GetColPanel( 'COLLDOWN', 'LINE' )

	// Painel superior Criticas
	oBrowUp := FWmBrowse():New()
	oBrowUp:SetOwner( oPnlCriUp )

	oBrowUp:SetDescription('Criticas')
	oBrowUp:SetAlias('B3F')
	oBrowUp:SetMenuDef('PLSMVCCRITICA')
	oBrowUp:SetProfileID('CRT1')
	oBrowUp:ForceQuitButton()
	oBrowUp:DisableDetails()
	oBrowUp:SetWalkthru(.F.)
	oBrowUp:SetAmbiente(.F.)

	// Painel inferior Beneficiários
	oBrwBenef := FWMBrowse():New()
	oBrwBenef:SetOwner( oPnlBenDown )
	IIF(lDmed,oBrwBenef:SetDescription( "Movimentações DMED" ),oBrwBenef:SetDescription( "Beneficiários" ))
	IIF(lDmed,oBrwBenef:SetAlias( "B2W" ),oBrwBenef:SetAlias( "B3K" ))
	oBrwBenef:SetMenuDef( '' )
	oBrwBenef:DisableDetails()
	oBrwBenef:SetProfileID( 'CRT2' )
	oBrwBenef:SetWalkthru( .F. )
	oBrwBenef:SetAmbiente( .F. )

	// Beneficiários ---
	oBrwCriBen := FWBrwRelation():New()
	If lDmed
		oBrwCriBen:AddRelation( oBrowUp,oBrwBenef, {;
			{ "B2W_FILIAL","B3F_FILIAL"	},;
			{ "B2W_FILIAL"+"B2W_CODOPE"+"B2W_CODOBR"+"B2W_ANOCMP"+"B2W_CDCOMP"+"B2W_CPFTIT"+"B2W_CPFBEN"+"B2W_DTNASD"+"B2W_NOMBEN"+"B2W_CPFPRE"+"B2W_IDEREG","B3F_IDEORI"} ;
			})

	Else
		oBrwCriBen:AddRelation( oBrowUp,oBrwBenef, {;
			{ "B3K_FILIAL","B3F_FILIAL"	},;
			{ "B3K_MATRIC","B3F_IDEORI"	} ;
			})

	Endif

	If !Empty(cFiltro)
		oBrowUp:SetFilterDefault(cFiltro)
	EndIf

	If !lAuto
		oBrowUp:Activate()
		oBrwBenef:Activate()
		oBrwCriBen:Activate()
		Activate MsDialog oDlgPrinc Center
	EndIf

Return oBrwCriBen

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCenCriBen

Funcao criada para exibir as criticas filtradas por alias e Recno

@author everton.mateus
@since 04/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PlCenFilCri(cAlias, nRecno, lAuto)

	Local cFiltro := ""

	Default lAuto  := .F.
	Default cAlias := ""
	Default nRecno := 0

	cFiltro := " B3F_FILIAL = xFilial( 'B3F' ) .AND. " +;
		" B3F_ORICRI = '" + cAlias + "' .AND. " +;
		" B3F_CHVORI = " + AllTrim(Str(nRecno)) + " "

Return PLBRWCrit(cFiltro, lAuto)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOComCad

Funcao criada para exibir as telas de cadastros de beneficiario, produto ou despesa

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCOComCad(lAuto)

	Local lOk := .F.
	Local cAliasOri := B3F->B3F_ORICRI
	Local cCampo := B3F->B3F_CAMPOS
	Local cTipoVld := B3F->B3F_TIPO
	Local nRecno := B3F->B3F_CHVORI

	Default lAuto := .F.

	If cAliasOri == "B3K" .AND. cTipoVld == JOBESPELHO
		If !lAuto
			PLSB3KB3W(nRecno,cCampo)
		EndIf
		lOk := .T.
	Else
		If !lAuto
			Alert("Função disponível apenas para críticas de Comparação de Espelhos")
		EndIf
	EndIf

Return lOk

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLOBVLDCRI

Funcao generica de validacao de criticas

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObr		Chave da obrigacao
@param cAno			Ano do compromisso
@param cCodComp		Chave do compromisso
@param aCriticas	Matriz de criticas do registro
@param cAlias		Area de trabalho corrente
@param cRecno		Numero do recno do registro
@param aAtuCob		Matriz com informacoes de cobertura
@param aCritSib		Array que retorna as críticas encontradas. Utilizado para exibir na tela para o usuario
@param cTipoVld		1=Job Validação;2=Comparação espelhos;3=Arq. Retorno
@param aCritSib
@param cChaveOri
@param cDescOri

@return lCriticado		Indica se o registro foi .T. ou nao .F. criticado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlObVldCri(cCodOpe,cCodObr,cAno,cCodComp,aCriticas,cAlias,nRecno,aAtuCob,oModel,cTipoVld,aCritSib,cChaveOri,cDescOri,cObri,cTabKey)

	Local dDataIni	 := dDataBase
	Local cHoraIni	 := Time()
	Local cAuxRecno	 := ""
	Local nI		 := 0
	Local nLenCri	 := Iif(Valtype(aCriticas[1])=="A",Len(aCriticas),1)
	Local aArea		 := GetArea()
	Local lCriticado := .F.
	Local aCritica	 := {}

	Private __cError   := ""
	Private __cCallStk := ""

	Default aAtuCob  := {}
	Default aCritSib := {}
	Default cTipoVld := JOBVALIDA //1=Job Validação;2=Comparação espelhos; 3 =Arq. Retorno
	Default cObri    := OBR_SIP
	Default cTabKey  := ""

	If oModel == Nil

		B3F->(DbSetOrder(7))
		cAuxRecno := PADL(AllTrim(Str(nRecno)),10)

		BEGIN TRANSACTION
			For nI:= 1 to nLenCri
				//So executo a funcao de validacao se ela nao for totalizadora
				If Valtype(aCriticas[nI]) == "A"
					aCritica := aCriticas[nI]
				Else
					aCritica := aCriticas
				EndIf

				cMacro := aCritica[FUNCAO]
				//lTotaliza := Iif( Len(aCritica) >= TOTALIZA .and. ValType(aCritica[TOTALIZA]) == "L", aCritica[TOTALIZA], .F. )
				cCodCri := aCritica[CODCRI]
				cDesCri := aCritica[DESCRI]
				cSolucao := aCritica[SOLUCAO]
				cCampos := Iif ( Len(aCritica) >= CAMPOS, aCritica[CAMPOS], "" )
				cCodANS := aCritica[CODANS]

				If &cMacro.(oModel,nI)
					//Corrige a critica se a validação correu bem
					PlObCorCri(cCodOpe,cCodObr,cAno,cCodComp,cAlias,cAuxRecno,cCodCri,cTipoVld)
				Else
					//Cria uma nova critica
					PlObInCrit(cCodOpe,cCodObr,cAno,cCodComp,cAlias,cAuxRecno,cCodCri,cDesCri,cSolucao,cCampos,cTipoVld,cCodANS,cChaveOri,cDescOri,,cTabKey)
					aAdd(aCritSib,{cCodCri,cDesCri,cSolucao})
					lCriticado := .T.
				EndIf

			Next nI

			//Informo que o registro foi validado = Status: '1=Nao Validado;2=Valido;3=Invalido'
			TmpStaVld(Val(cAuxRecno),cAlias,dDataIni,cHoraIni,Iif(lCriticado,"3","2"),cObri,cTipoVld)

			//TODO inicio - tratar para nao executar quando for job de validacao do sip

			//Verifico se o compromisso possui criticas.
			B3F->(dbSetOrder(3))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
			If B3F->(MsSeek(xFilial('B3F')+cCodOpe+cCodObr+cAno+cCodComp+"1"))
				cStComp := '2'
			Else
				cStComp := '3'
			EndIf
			B3D->(dbSetOrder(1))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
			If B3D->(MsSeek(xFilial('B3D')+cCodOpe+cCodObr+cAno+cCodComp))
				If B3D->B3D_STATUS != FINALIZ .And. B3D->B3D_STATUS <> cStComp//somente se o status for diferente de 6-finalizado e for diferente do novo status = cStComp, para evitar reclock desnecessario
					Reclock("B3D",.F.)
					//2=Criticado
					B3D->B3D_STATUS := cStComp
					MsUnlock()
				EndIf
			EndIf

			//TODO termino
		END TRANSACTION

	Else

		For nI:= 1 to nLenCri
			//So executo a funcao de validacao se ela nao for totalizadora
			cMacro := aCriticas[nI][FUNCAO]
			If !&cMacro.(oModel,nI)
				//Cria uma nova critica
				aAdd(aCritSib,{aCriticas[nI][CODCRI],aCriticas[nI][DESCRI],aCriticas[nI][SOLUCAO]})
				lCriticado := .T.
			EndIf

		Next nI

	EndIf //If oModel == Nil

	MsUnlockAll()
	RestArea(aArea)

Return !lCriticado

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLOBINCRIT

Funcao generica de inclusao de criticas na tabela B3F

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObr		Chave da obrigacao
@param cAno			Ano do compromisso
@param cCodComp	Chave do compromisso
@param cAlias		Area de trabalho
@param cRecno		Numero do recno do registro
@param cCodCri		Codigo da critica
@param cDesCrit	Descricao da critica
@param cSolucao	Descricao da solucao sugerida
@param cCampos		Campos afetados pela critica
@param cTipoVld	1=Job Validação;2=Comparação espelhos; 3 =Arq. Retorno
@param cCriANS		Codigo da critica no manual da ANS
@param cChaveOri	Chave unica da tabela de origem
@param cDescOri	Descrição do registro que foi criticado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlObInCrit(cCodOpe,cCodObr,cAno,cCodComp,cAlias,cRecno,cCodCri,cDesCrit,cSolucao,cCampos,cTipoVld,cCriANS,cChaveOri,cDescOri,cStatus,cTabKey)

	Local 	lGrava		:= .T.
	Local 	lOk         := .F.
	Default cCampos		:= ""
	Default cTipoVld	:= JOBVALIDA
	Default cChaveOri	:= ""
	Default cDescOri	:= ""
	Default cStatus		:= CRIT_PDTE
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAno		:= ""
	Default cCodComp	:= ""
	Default cAlias		:= ""
	Default cRecno		:= ""
	Default cCodCri		:= ""
	Default cTabKey     := ""

	//Procuro a critica B3F->(DbSetOrder(7)) B3F_FILIAL+B3F_CODOPE+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI
	lInclui := !B3F->(MsSeek(xFilial("B3F")+cCodOpe+cAlias+cRecno+cCodCri+cTipoVld+Subs(cChaveOri,1,50)))

	If TipoSIP(cCodOpe,cCodObr,cAno,cCodComp) .And. ExisteCritica(cCodOpe,cCodObr,cAno,cCodComp,cAlias,cRecno,cCodCri,cTipoVld,cChaveOri,cDescOri)
		lGrava := .F.
	EndIf

	If lGrava

		Reclock("B3F",lInclui)
		B3F->B3F_FILIAL	:= xFilial("B3F")
		B3F->B3F_CODOPE	:= cCodOpe
		B3F->B3F_CDOBRI	:= cCodObr
		B3F->B3F_ANO    := cAno
		B3F->B3F_CDCOMP := cCodComp
		B3F->B3F_CODCRI := cCodCri
		B3F->B3F_DESCRI := cDesCrit
		B3F->B3F_SOLUCA := cSolucao
		B3F->B3F_ORICRI := cAlias
		B3F->B3F_CHVORI := val(cRecno)
		B3F->B3F_STATUS := cStatus
		B3F->B3F_CAMPOS := cCampos
		B3F->B3F_TIPO   := cTipoVld
		B3F->B3F_CRIANS := cCriANS
		B3F->B3F_IDEORI := cChaveOri
		B3F->B3F_DESORI := cDescOri
		If  B3F->(FieldPos("B3F_TABKEY")) > 0 .And. !Empty(cTabKey) //Lima, retirei daqui o ReadyRun pois não está gravando o TABKEY de algumas críticas
			B3F->B3F_TABKEY := cTabKey
		EndIf
		B3F->(MsUnlock())

		lOk := .T.
		/*If lInclui
			PLSLOGFIL(CENDTHRL("I") + " PlObInCrit incluindo - " + " cCodObr: " + cCodObr + " cCodComp: " + cCodComp + " cAlias: " + cAlias + " cRecno: " + cRecno,ARQ_LOG_INC)
		Else
			PLSLOGFIL(CENDTHRL("I") + " PlObInCrit alterando - " + " cCodObr: " + cCodObr + " cCodComp: " + cCodComp + " cAlias: " + cAlias + " cRecno: " + cRecno,ARQ_LOG_INC)
		EndIf*/
	Else
		//PLSLOGFIL(CENDTHRL("I") + " PlObInCrit - ja gravada - " + " cCodObr: " + cCodObr + " cCodComp: " + cCodComp + " cAlias: " + cAlias + " cRecno: " + cRecno,ARQ_LOG_INC)
	EndIf//If lGrava

Return lOk
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLOBCORCRI

Funcao generica de correcao de critica - altera status para 2

@param cAlias		Alias / tabela que originou a critica
@param cRecno		Codigo do recno do registro
@param cCodCri 	Codigo da critica
@param cTipoVld	1=Job Validação;2=Comparação espelhos; 3 =Arq. Retorno

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLOBCORCRI(cCodOpe,cCodObr,cAno,cCodComp,cAlias,cRecno,cCodCri,cTipoVld,lExclus)
	Default cTipoVld := JOBVALIDA
	Default lExclus  := .F.

	cSql := " DELETE FROM " + RetSqlName('B3F')
	cSql += " WHERE "
	cSql += "	B3F_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3F_CODOPE = '" + cCodOpe + "' "
	cSql += "	AND B3F_ORICRI = '" + cAlias + "' "
	cSql += "	AND B3F_CHVORI = '" + AllTrim(cRecno) + "' "

	If !lExclus

		cSql += "	AND B3F_CODCRI = '" + cCodCri + "' "
		cSql += "	AND B3F_TIPO = '" + cTipoVld + "' "
		cSql += "	AND B3F_STATUS = '" + CRIT_PDTE + "'"

	EndIf
	cSql += "	AND D_E_L_E_T_ = ' ' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif
	//PLSLOGFIL(CENDTHRL("I") + " PLOBCORCRI - " + " cCodObr: " + B3F->B3F_CDOBRI + " cCodComp: " + B3F->B3F_CDCOMP + " cAlias: " + B3F->B3F_ORICRI + " cRecno: " + AllTrim(Str(B3F->B3F_CHVORI)),ARQ_LOG_EXC)

Return nRet >= 0
////--------------------------------------------------------------------------------------------------
///*/{Protheus.doc} VLDCRICEN
//
//Funcao criada para validar as criticas de eventos x despesa na central
//
//@author everton.mateus
//@since 26/01/2016
///*/
////--------------------------------------------------------------------------------------------------
//Function VLDCRICEN()
//
//DbSelectArea("B3L")
//B3L->(dbSetOrder(1))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+B3F_CHVORI+B3F_CODCRI
//If B3L->(MsSeek(xFilial("B3L")))
//
//	Do While !B3L->(Eof())
//
//		PLOBVLDCRI(B3L->B3L_CODOPE,B3L->B3L_CODOBR,B3L->B3L_ANOCMP,B3L->B3L_CDCOMP,aCriticas,'B3L',B3L->(Recno()))
//		B3L->(DbSkip())
//
//	EndDo
//
//EndIf
//
//Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NOMEFUNCTION

Funcao criada para capturar um erro que ocorreu durante o processo

@param e	Referencia ao erro encontrado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e)
	__cError := e:Description
	__cCallStk := e:ErrorStack
	BREAK
Return .T.
/*	VALIDACAO DE PRODUTO	-	INICIO	*/
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PSegVazia

Funcao criada para validar se a segmentacao foi informada

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PSegVazia()
	Local lRetorno := .T.

	If Empty(B3J->B3J_SEGMEN)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PSegValid

Funcao criada para validar se a segmentacao informado para o plano / produto e valida

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PSegValid()
	Local lRetorno := .T.

	If PSegVazia() .And. !(B3J->B3J_SEGMEN $ '1,2,3,4')
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PForVazia

Funcao criada para validar se a forma de contratacao do plano / produto se encontra preenchida

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PForVazia()
	Local lRetorno := .T.

	If Empty(B3J->B3J_FORCON)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PForValid

Funcao criada para validar se a forma de contratacao do plano / produdo e valida

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PForValid()
	Local lRetorno := .T.

	If PForVazia() .And. !(B3J->B3J_FORCON $ '1,2,3')
		lRetorno := .F.
	EndIf

Return lRetorno
/*	VALIDACAO DE PRODUTO	-	TERMINO	*/
/*	VALIDACAO DE BENEFICIARIOS	-	INICIO	*/
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BDtNscVazia

Funcao criada validar se a data de nascimento do beneficiario esta preenchida - Critica B001

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BDtNscVazia()
	Local lRetorno := !Empty(B3K->B3K_DATNAS)
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BDtIncVazia

Funcao criada validar se a data de Inclusão/Adesão do beneficiario esta preenchida - Critica B002

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BDtIncVazia()
	Local lRetorno := !Empty(B3K->B3K_DATINC)
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BUFVazia

Funcao criada validar se a data de nascimento do beneficiario esta preenchida - Critica B003

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BUFVazia()
	Local lValido := B3K->B3K_RESEXT == '1' .OR. !Empty(B3K->B3K_UF)
Return lValido
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BUFValid

Funcao criada validar se a UF do beneficiario esta preenchida - Critica B004

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BUFValid()
	Local lValido := .T.
	If  BUFVazia()
		lValido := B3K->B3K_UF $ "NC,AC,AL,AM,AP,BA,CE,DF,ES,GO,MA,MG,MS,MT,PA,PB,PE,PI,PR,RJ,RN,RO,RR,RS,SC,SE,SP,TO"
	EndIf
Return lValido
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BProVazia

Funcao criada validar se a data de nascimento do beneficiario esta preenchida - Critica B005

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BProVazia()
	Local lValido := !Empty(B3K->B3K_CODPRO)
Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BProValid

Funcao criada validar se o produto do beneficiário existe e está válido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BProValid()
	Local lValido := B3JExiste(B3K->B3K_CODOPE,B3K->B3K_CODPRO,"2")
Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BProExist

Funcao criada validar se o produto do beneficiário existe e está válido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BProExist()
	Local lRetorno := B3JExiste(B3K->B3K_CODOPE,B3K->B3K_CODPRO)
Return lRetorno

Static Function B3JExiste(cRegANS,cCodPro,cStatus)
	Local cConsulta	:= ""
	Local cAliTrb	:= GetNextAlias()
	Local lRetorno	:= .F.
	Default cRegANS	:= ""
	Default cCodPro	:= ""
	Default cStatus	:= ""

	If !Empty(cRegANS) .And. !Empty(cCodPro)

		cConsulta := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B3J") + " WHERE B3J_FILIAL='" + xFilial("B3J") + "' AND B3J_CODOPE='" + cRegANS + "' AND B3J_CODIGO='" + cCodPro + "' "
		If !Empty(cStatus)
			cConsulta += " AND B3J_STATUS = '" + cStatus + "' "
		EndIf
		cConsulta += " AND D_E_L_E_T_=' '"
		lRetorno := CriaArea(cConsulta,cAliTrb)

		(cAliTrb)->(dbCloseArea())

	EndIf

Return lRetorno

/*	VALIDACAO DE BENEFICIARIOS	-	TERMINO	*/
/*	VALIDACAO DE EVENTO X DESPESA	-	INICIO	*/
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ETriRecVaz

Funcao criada para validar se o trimestre de reconhecimento foi informado no evento x despesa - Critica E001

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ETriRecVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_TRIREC)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ETriOcoVaz

Funcao criada para validar se o trimestre de ocorrencia foi informado no evento x despesa - Critica E002

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ETriOcoVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_TRIOCO)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EMatriVaz

Funcao criada para validar se a matricula do beneficiario se encontra preenchida  - Critica E003

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EMatriVaz()
	Local lRetorno := .T.
	Local lTotalizador := Empty(B3L->B3L_CDTPTB) .AND. Empty(B3L->B3L_CODEVE) .AND. Empty(B3L->B3L_CID)

	If !lTotalizador .AND. Empty(B3L->B3L_MATRIC)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EChavVazia

Funcao criada para validar se a chave da despesa se encontra preenchida - Critica E004

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EChavVazia()
	Local lRetorno := .T.

	If Empty(B3L->B3L_EVEDES)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ETipTabVaz

Funcao criada para validar se o tipo de tabela se encontra preenchido - Critica E005

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ETipTabVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_CDTPTB) .And. B3L->B3L_EVEDES <> B3L->B3L_MATRIC
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ECodProVaz

Funcao criada para validar se o codigo do evento se econtra preenchido  - Critica E006

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ECodProVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_CODEVE) .And. B3L->B3L_EVEDES <> B3L->B3L_MATRIC
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EDatRelVaz

Funcao criada para validar se a data de realizacao do evento se encontra preenchida - Critica E007

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EDatRelVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_DATEVE)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EQtdRelVaz

Funcao criada para validar se a quantidade do evento realizada se encontra preenchida e eh maior que zero - Critica E008
Totalizador nao pode ter quantidade zero
Item que nao for procedimento como mat/med nao considera a quantidade entao nao deve criticar

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EQtdRelVaz()
	Local lRetorno := .T.

	If (Empty(B3L->B3L_QTDEVE) .Or. B3L->B3L_QTDEVE == 0) .And. ( (B3L->B3L_MATRIC == B3L->B3L_EVEDES) )
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EClasVazia

Funcao criada para validar se a classificacao ambulatorial e internacao se encontram preenchidas  - Critica E010

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EClasVazia()
	Local lRetorno := .T.

	If Empty(B3L->B3L_CLAAMB) .And. Empty(B3L->B3L_CLAINT)
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EGrpIntVaz

Funcao criada para validar se o grupo de internacao se encontra preenchido para evento x despesa de internacao (B3L_CLAINT preenchido) - Critica E012

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EGrpIntVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_GRPINT) .And. !Empty(B3L->B3L_DATINT) .And. ( AllTrim(B3L->B3L_CLAAMB) <> 'H' .Or. AllTrim(B3L->B3L_CLAINT) <> 'H' )
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ERegAteVaz

Funcao criada para validar se o regime de internacao se encontra preenchido para evento x despesa de internacao (B3L_CLAINT preenchido) - Critica E013

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ERegAteVaz()
	Local lRetorno := .T.

	If Empty(B3L->B3L_REGINT) .And. !Empty(B3L->B3L_DATINT) .And. ( AllTrim(B3L->B3L_CLAAMB) <> 'H' .Or. AllTrim(B3L->B3L_CLAINT) <> 'H' )
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBenValido

Funcao criada para validar se o beneficiaio informado se encontra com o status valido  - Critica E014

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBenValido()
	Local lRetorno := .T.
	If EBenExiste() .And. B3K->B3K_STATUS <> VALIDO
		lRetorno := .F.
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBenExiste

Funcao criada para validar se o beneficiario informado existe na tabela de beneficiarios - Critica E015

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBenExiste()
	Local lRetorno := .T.

	B3K->(dbSetOrder(1))
	If B3L->B3L_EVEDES <> B3L->B3L_MATRIC .And. !B3K->(MsSeek(xFilial("B3K")+AllTrim(B3L->B3L_CODOPE)+PADR(B3L->B3L_MATRIC,tamSX3("B3K_MATRIC")[1])))
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EProValido

Funcao criada para validar se o produto do beneficiario informado no evento x despesa e valido - Critica E016

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EProValido()
	Local lRetorno := .T.
	If EBenExiste()
		lRetorno := B3JExiste(B3K->B3K_CODOPE,B3K->B3K_CODPRO,"2")//Procuro o produto com status diferente de 2-valido
	EndIf
Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EProExiste

Funcao criada para validar se o produto do beneficiario informado no evento x despesa existe - Critica E017

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EProExiste()
	Local lRetorno := .T.
	If EBenExiste()
		lRetorno := B3JExiste(B3K->B3K_CODOPE,B3K->B3K_CODPRO)
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomaItem1

Funcao criada para validar se O somatorio dos itens 1-Cons. Amb. e 2-Cons. PS nao correspondem ao total do item A-Cons. Med. - Critica E018

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomaItem1()
	Local lRetorno	:= .T.
	Local cSql		:= ""
	Local nSomaA	:= 0 //A-Cons. Med.
	Local nItensA	:= 0 //1-Cons. Amb. + 2-Cons. PS

	//Total do item A
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_CLAAMB = 'A' AND B3L_CLAINT = 'A' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSomaA := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Total dos itens A1
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND ((B3L_CLAAMB='A1' AND B3L_CLAINT='A1') OR (B3L_CLAAMB='A2' AND B3L_CLAINT='A2')) AND D_E_L_E_T_ = ' ' "
	//cSql += " AND B3L_CDTPTB ='' AND B3L_CODEVE=''"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensA := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nItensA <> nSomaA
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomaItemB

Funcao criada para validar se Vlr. item B-Out. Aten. Amb. nao deve se restringir a soma dos itens 1 a 5 considere outros itens B - Critica E019

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomaItemB()
	Local lRetorno	:= .T.
	Local cSql		:= ""
	Local nItemB	:= 0 //Out. Aten. Amb.
	Local nSubIteB	:= 0 //Cons./Sess. 1-Fisio, 2-Fono, 3-Nutri, 4-Terap. Ocup., 5-Psic.

	//Soma dos itens B1 a B5
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "'  "
	cSql += "AND B3L_MATRIC=B3L_EVEDES AND B3L_CLAAMB BETWEEN 'B1' AND 'B5' AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSubIteB := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Soma do iten B
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "'  "
	cSql += "AND B3L_MATRIC=B3L_EVEDES AND B3L_CLAAMB = 'B' AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItemB := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nItemB < nSubIteB
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ETotalIteE

Funcao criada para validar se Total de despesa liq. (item IV) do grupo E-Int. deve corresponder a soma dos itens E1 a E5 - Critica E020

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ETotalIteE()
	Local lRetorno	:= .T.
	Local cSql		:= ""
	Local nSomaE	:= 0
	Local nItensE1	:= 0

	//Soma dos itens E11 a E15
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' AND B3L_MATRIC=B3L_EVEDES "
	cSql += "AND B3L_CLAAMB IN ('E11','E12','E13','E14','E15') AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensE1 := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Soma do iten E
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' AND B3L_MATRIC=B3L_EVEDES "
	cSql += "AND B3L_CLAAMB = 'E1' AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSomaE := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nSomaE <> nItensE1
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomIteEX

Funcao criada para validar se o Total de despesa lig. (Item IV) do grupo E-Int. deve corresponder a soma dos itens E21, E22 e E23 - Critica E026

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomIteEX()
	Local lRetorno := .T.
	Local cSql		:= ""
	Local nSomaE	:= 0
	Local nItensE2	:= 0

	//Soma dos itens E1, E2 e E3
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' AND B3L_MATRIC=B3L_EVEDES "
	cSql += "AND B3L_CLAAMB IN ('E21','E22','E23') AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensE2 := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Soma do iten E
	cSql := "SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' AND B3L_MATRIC=B3L_EVEDES "
	cSql += "AND B3L_CLAAMB = 'E2' AND B3L_UF = '" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensE := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nSomaE <> nItensE
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBenefFemi

Funcao criada para validar se Beneficiario informado p/ internacao do grupo 3-Obstetrica deve ser do sexo feminino - Critica E021

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBenefFemi()
	Local lRetorno := .T.
	If B3L->B3L_GRPINT == '3' .And. EBenExiste() .And. B3K->B3K_SEXO != "3"
		lRetorno := .F.
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EGuiParObs

Funcao criada para validar se Guia com procedimento de parto (normal / cesario) nao classificada no grupo 3-Obstetrica - Critica E022

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EGuiParObs()
	Local lRetorno := .T.

	If (AllTrim(B3L->B3L_CLAINT) == "E131" .Or. AllTrim(B3L->B3L_CLAINT)=="E132") .And. B3L->B3L_GRPINT <> '3'
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBeFem5069

Funcao criada para validar se Beneficiario informado para evento x despesa C101 deve ser do sexo feminino e ter entre 50 e 69 anos

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBeFem5069()
	Local lRetorno := .T.

	If ( AllTrim(B3L->B3L_CLAAMB) == "C101" .OR. AllTrim(B3L->B3L_CLAINT) == "C101" ) .And. EBenExiste()
		nIdade	:= Calc_Idade(B3L->B3L_DATEVE,B3K->B3K_DATNAS)
		lRetorno := B3K->B3K_SEXO == "3" .AND. nIdade >= 50 .AND. nIdade <= 69
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBenFemiC5

Funcao criada para validar se Beneficiario informado para evento x despesa do grupo C50, C53, D05 e D06 deve ser do sexo feminino - Critica E023

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBenFemiC5()
	Local lRetorno := .T.
	If AllTrim(B3L->B3L_CID) $ "C50,C53,D05,D06" .AND. EBenExiste() .And. B3K->B3K_SEXO != "3"
		lRetorno := .F.
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EBenefMasc

Funcao criada para validar se Beneficiario informado para evento x despesa do grupo C61 deve ser do sexo masculino - Critica E024

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EBenefMasc()
	Local lRetorno := .T.
	Local lTotalizador := Empty(B3L->B3L_CDTPTB) .AND. Empty(B3L->B3L_CODEVE) .AND. Empty(B3L->B3L_CID)

	If (Alltrim(B3L->B3L_CID) == 'C61' .OR. Alltrim(B3L->B3L_CID) == 'C61') .AND. !lTotalizador
		If EBenExiste() .AND. B3K->B3K_SEXO != "1"
			lRetorno := .F.
		EndIf
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EDenRegVaz

Funcao criada para validar se Dente ou regiao nao encontrado para o evento x despesa odontologico - Critica E025

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function EDenRegVaz()
	Local lRetorno := .T.

	/*If SubStr(B3L->B3L_CLAAMB,1,1) == "I" .And. Empty(B3L->B3L_DENREG)
	lRetorno := .F.
	EndIf*/

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomIteA1

Funcao criada para validar o item A1 com os subitnes A11, A12 ... A125 - Critica E027

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 01/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomIteA1()
	Local cSql			:= ""
	Local nSomaA 		:= 0
	Local nItensA		:= 0
	Local lRetorno		:= .T.

	//Total do item A1
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB = 'A1' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSomaA := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Total dos itens A1
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB like 'A1%' and len(B3L_CLAAMB) > 2 AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensA := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nItensA > nSomaA
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomIteCs

Funcao criada para validar o item C com os subitens C1 .. C20  - Critica E028

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 01/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomIteCs()
	Local cSql			:= ""
	Local nSomaC 		:= 0
	Local nItensC		:= 0
	Local lRetorno		:= .T.

	//Total do item C
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB = 'C' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSomaC := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Total dos itens C*
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB BETWEEN 'C1' AND 'C20' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensC := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nItensC > nSomaC
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESomMamo

Funcao criada para validar os itens C10 e C101 de mamografia - Critica E029

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 01/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESomMamo()
	Local cSql			:= ""
	Local nSomaC 		:= 0
	Local nItensC		:= 0
	Local lRetorno		:= .T.

	//Total do item C
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB = 'C10' AND B3L_UF='" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nSomaC := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	//Total dos itens C*
	cSql := " SELECT SUM(B3L_VLREVE) VLREVE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B3L_MATRIC = B3L_EVEDES AND B3L_CLAAMB = 'C101' AND B3L_UF='" + B3L->B3L_UF + "' AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		nItensC := TRB1->VLREVE
	EndIf
	TRB1->(dbCloseArea())

	If nItensC > nSomaC//C101 nao pode ser maior que C10
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmpStaVld

Funcao criada para gravar o tempo gasto para validacao do registro e o novo status

@param nRecno		Recno do registro a ser atualizado
@param cAlias		Alias da tabela do registro
@param cDataIni		Data inicial da validacao
@param cHoraIni		Hora inicial da validacao
@param cStatus		Novo status do registro
@param cObri	1-SIP, 2-SIB, 3-DIOPS
@param cTipoVld	1=Job Validação;2=Comparação espelhos; 3 =Arq. Retorno

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function TmpStaVld(nRecno,cAlias,dDataIni,dHoraIni,cStatus,cObri,cTipoVld)
	Default nRecno		:= 0
	Default cAlias		:= ""
	Default dDataIni	:= Date()
	Default dHoraIni	:= Time()
	Default cStatus		:= PDTE_VALID
	Default cObri		:= OBR_SIP
	Default cTipoVld	:= JOBVALIDA

	If nRecno > 0 .And. !Empty(cAlias)

		(cAlias)->(dbGoTo(nRecno))
		(cAlias)->(RecLock(cAlias,.F.))
		If (cAlias)->( FieldPos(cAlias + "_STASIB") ) > 0 .and. cObri == OBR_SIB
			If cTipoVld == JOBESPELHO
				&(cAlias + "->" + cAlias + "_STAESP") := cStatus
			ElseIf cObri == OBR_SIB
				&(cAlias + "->" + cAlias + "_STASIB") := cStatus
			EndIf
		ElseIf (cAlias)->( FieldPos(cAlias + "_STATUS") ) > 0
			&(cAlias + "->" + cAlias + "_STATUS") := cStatus
			&(cAlias + "->" + cAlias + "_DTINVL") := dDataIni
			&(cAlias + "->" + cAlias + "_HRINVL") := dHoraIni
			&(cAlias + "->" + cAlias + "_DTTEVL") := Date()
			&(cAlias + "->" + cAlias + "_HRTEVL") := Time()
		EndIf
		(cAlias)->(MsUnLock())

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataTrimestre

Funcao criada para transformar a data em trimestre valido para o SIP

@param cData	Data (AAAAMMDD) que sera transformata em trimestre (AAAAMM) ou AAAAMMDD inicial ou final do trimestre
@param nOpc		Tipo de retorno
	1 - monto o retorno da data AAAAMMDD inicial
	2 - monto o retorno da data AAAAMMDD final
	3 - default - monto o retorno do trimestre AAAAMM

@return cTrimestre	Retorno o trimestre identificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function DataTrimestre(cData,cOpc)
	Local nTrimestre	:= 0
	Local cTrimestre	:= ""
	Local aPeriodos		:= {}
	Default cData		:= DTOS(dDataBase)
	Default cOpc		:= ""// "" - AAAADD, "1" - AAAAMMDD inicial, "2" - AAAAMMDD final

	aAdd(aPeriodos,{"01","02","03"})
	aAdd(aPeriodos,{"04","05","06"})
	aAdd(aPeriodos,{"07","08","09"})
	aAdd(aPeriodos,{"10","11","12"})

	//Identifico o trimestre que pertence a data
	nTrimestre := Ascan( aPeriodos,{|x| x[1] == Substr(cData,5,2) .Or. x[2] == Substr(cData,5,2) .Or. x[3] == Substr(cData,5,2)})

	If cOpc == "1"//monto o retorno da data AAAAMMDD inicial

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,1]
		cTrimestre += "01"

	ElseIf cOpc == "2"//monto o retorno da data AAAAMMDD final

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,3]
		If nTrimestre == 1
			If SubStr(cTrimestre,5,2) == "02"
				If Val(SubStr(cTrimestre,1,4)) % 4 == 0
					cTrimestre += "29"
				Else
					cTrimestre += "28"
				EndIf
			Else
				cTrimestre += "31"
			EndIf
		Else
			If SubStr(cTrimestre,5,2) $ "04,06,09,10"
				cTrimestre += "30"
			Else
				cTrimestre += "31"
			EndIf
		EndIf

	Else//monto o retorno do trimestre AAAAMM
		cTrimestre := Substr(cData,1,4)+PADL(Alltrim(Str(nTrimestre)),2,"0")
	EndIf

Return cTrimestre

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB001

Funcao criada para validar se o código CCO esta preenchido - Critica B001

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB001(oModel)
	Local lRet := .T.
	Default oModel := Nil

	If oModel == Nil
		cCodCCO := B3K->B3K_CODCCO
	Else
		cCodCCO := oModel:GetValue( 'B3KMASTER', 'B3K_CODCCO' )
	EndIf

	lRet := !Empty(cCodCCO)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB002

Funcao criada para validar se o plano de destino do beneficiario é
igual ao de origem - Critica B002

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB002(oModel)
	Local lRet := .T.

	Default oModel := Nil

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB003

Funcao criada para validar  - Critica B003

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB003()
	Local lRet := .T.
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB004

Funcao criada para validar  - Critica

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB004()
	Local lRet := .T.
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB005

Funcao criada para validar  Critica B005
Data de Inclusão é obrigatória

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB005(oModel)
	Local lRet := .T.
	Default oModel := Nil

	If oModel == Nil
		lRet := !Empty(B3K->B3K_DATINC)
	Else
		lRet := !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' ))
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB006

Funcao criada para validar  Critica B006

Data de Reativação deve ser posterior ou igual à Data de Cancelamento
existente no cadastro em reativação.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB006(oModel)
	Local lRet := .T.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB007

Funcao criada para validar Critica B007
Data de cancelamento é obrigatória

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB007(oModel)
	Local lRet := .T.
	Default oModel := Nil

	If oModel == Nil
		lRet := !Empty(B3K->B3K_DATBLO) .Or. !Empty(B3K->B3K_DATREA)
	Else
		lRet := !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_DATBLO' )) .Or. !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_DATREA' ))
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB008

Funcao criada para validar Critica B008
Data de cancelamento posterior ou igual a data de contratação.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB008(oModel)
	Local lRet := .T.
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB009

Funcao criada para validar Critica B009
Código de motivo de cancelamento é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB009(oModel)
	Local lRet := .T.
	Local cMotBlo := ""
	Default oModel := Nil

	B4W->(DbSetOrder(1))

	cMatric  := AllTrim(B3K->B3K_MATRIC)
	dMvto	 := B3X->B3X_DATA
	cHoraMov := B3X->B3X_HORA

	If B4W->(MsSeek(xFilial("B4W")+PADR(cMatric,tamSX3("B4W_MATRIC")[1])+DTOS(dMvto)+"0"+cHoraMov ) )
		cMotBlo := Alltrim(B4W->B4W_MOTBLO)
	EndIf

	lRet := !Empty(cMotBlo)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB010

Funcao criada para validar Critica B010
Código de motivo de cancelamento não existe no sistema

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB010(oModel)
	Local lRet := .T.
	Local cMotBlo := ""
	Default oModel := Nil

	B4W->(DbSetOrder(1))

	cMatric  := AllTrim(B3K->B3K_MATRIC)
	dMvto	 := B3X->B3X_DATA
	cHoraMov := B3X->B3X_HORA

	If B4W->(MsSeek(xFilial("B4W")+PADR(cMatric,tamSX3("B4W_MATRIC")[1])+DTOS(dMvto)+"0"+cHoraMov ) )
		cMotBlo := Alltrim(B4W->B4W_MOTBLO)
	EndIf

	lRet := Empty(cMotBlo) .OR. cMotBlo $ "41,42,43,44,45,46,47,48"

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB011

Funcao criada para validar Critica B011
Código de Motivo de Cancelamento existente no cadastro não permite a reativação do registro.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB011(oModel)
	Local lRet := .T.
	Local cMotBlo := ""
	Default oModel := Nil

	B4W->(DbSetOrder(1))

	cMatric  := AllTrim(B3K->B3K_MATRIC)
	dMvto	 := B3X->B3X_DATA
	cHoraMov := B3X->B3X_HORA

	If B4W->(MsSeek(xFilial("B4W")+PADR(cMatric,tamSX3("B4W_MATRIC")[1])+DTOS(dMvto)+"0"+cHoraMov ) )
		cMotBlo := Alltrim(B4W->B4W_MOTBLO)
	EndIf

	lRet := Empty(cMotBlo) .OR. cMotBlo $ "41,42,43"

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB012

Funcao criada para validar Critica B012
Nome de beneficiario é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB012(oModel)
	Local lRet := .T.
	Default oModel := Nil

	If oModel == Nil
		lRet := !Empty(B3K->B3K_NOMBEN)
	Else
		lRet := !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_NOMBEN' ))
	EndIf

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB013

Funcao criada para validar Critica B013
Nome de beneficiario invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 17/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB013(oModel)

	Local lRet := .T.
	Local cNome := ""
	Local cCriNom := "1"

	Default oModel := Nil

	If oModel == Nil
		cNome := B3K->B3K_NOMBEN
		if B3K->(FieldPos("B3K_CRINOM")) > 0
			cCriNom := B3K->B3K_CRINOM
		EndIf
	Else
		cNome := oModel:GetValue( 'B3KMASTER', 'B3K_NOMBEN' )
		if B3K->(FieldPos("B3K_CRINOM")) > 0
			cCriNom := oModel:GetValue( 'B3KMASTER', 'B3K_CRINOM' )
		EndIf
	EndIf

	If cCriNom == '1' .OR. Empty(cCriNom)
		lRet := PLVlANSNome(cNome)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVlANSNome

Funcao criada para validar nomes de acordo com a regra da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------

Function PLVlANSNome(cNome)
	Local lRet := .T.

	Local cInicValid := "D,I,Í,Ì,Ï,O,Ó,Õ,Ô,Ö,U,Ú,Ù,Ü,Y,Ý"
	Local cFimValid := "I,Í,Ì,Ï,O,Ó,Õ,Ô,Ö,U,Ú,Ù,Ü,Y,Ý"
	Local cConValid := "E,É,È,Ê,Ë,Y,Ý"
	Local cCaracVald := "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,Ã,Á,À,Â,Ä,É,È,Ê,Ë,Í,Ì,Ï,Ó,Õ,Ô,Ö,Ú,Ù,Ü,Ñ,Ç,Ý,'"
	Local cChars := ""
	Local cLetra := ""

	Local nI := 0
	Local nJ := 0

	DEFAULT cNome := ""

	cNome := Upper(Alltrim(cNome))
	//Deixa o nome apenas com 1 espaço entre as palavras
	while (nI := At(Space(2),cNome)) > 0
		cNome := Strtran(cNome,Space(2),Space(1))
	Enddo

	//Monta um array de palavras
	aPalavras := StrTokArr(cNome,Space(1))

	nLen := len(aPalavras)
	//Valida se o nome tem apenas uma palavra
	If nLen <= 1
		lRet := .F.
	Else
		//Valida as palavras
		//Primeira palavra só pode ter uma letra se a letra for D,I,O,U ou Y
		If Len(aPalavras[1]) == 1 .AND. !aPalavras[1] $ cInicValid
			lRet := .F.
		Else

			For nI := 1 to nLen

				cPalavra := aPalavras[nI]

				nLenStr := Len(cPalavra)

				//Valida se alguma palavra do meio tem tamamnho 1 e não é um conector ('e' ou 'y')
				If nI > 1 .AND. nI < nLen .AND. nLenStr == 1 .AND. !cPalavra $ cConValid
					lRet := .F.
					Exit
				EndIf

				For nJ := 1 to nLenStr
					//Recupero a letra
					cLetra := SubStr(cPalavra,nJ,1)

					//Verifica se o caracter é valido
					If !cLetra $ cCaracVald
						lRet := .F.
						Exit
					EndIf

					//Valida se o caracter esta repetido mais de 3 vezes seguidas no nome. Ex.: PRRROTHEUS -- O RRR caracteríza um nome invalido.
					If !(cLetra $ cChars)
						cChars += cLetra + ","
						If AT( Replicate(cLetra,3), cNome ) > 0
							lRet := .F.
							Exit
						EndIf
					EndIf


				Next nJ

			Next nI

			//Ultima palavra só pode ter uma letra se a letra for I,O,U ou Y
			If Len(aPalavras[nLen]) == 1 .AND. !aPalavras[nLen] $ cFimValid
				lRet := .F.
			EndIf

		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB014

Funcao criada para validar Critica B014
Data de nascimento é obrigatória

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB014(oModel)
	Local lRet := .T.

	Default oModel := Nil

	If oModel == Nil
		lRet := !Empty(B3K->B3K_DATNAS)
	Else
		lRet := !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' ))
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB015

Funcao criada para validar Critica B015
Data de nascimento deve ser posterior ou igual a 01/01/1890

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB015(oModel)
	Local lRet := .T.

	Local dData := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dData := B3K->B3K_DATNAS
	Else
		dData := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
	EndIf

	lRet := dData >= STOD("18900101")

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB016

Funcao criada para validar Critica B016
Código de sexo do beneficiario é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB016(oModel)
	Local lRet := .T.

	Default oModel := Nil

	If oModel == Nil
		lRet := !Empty(B3K->B3K_SEXO)
	Else
		lRet := !Empty(oModel:GetValue( 'B3KMASTER', 'B3K_SEXO' ))
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB017

Funcao criada para validar Critica B017
Código de sexo não existe no sistema (código invalido).

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB017(oModel)
	Local lRet := .T.

	Local cSexo := ""

	Default oModel := Nil

	If oModel == Nil
		cSexo := B3K->B3K_SEXO
	Else
		cSexo := oModel:GetValue( 'B3KMASTER', 'B3K_SEXO' )
	EndIf

	lRet := cSexo $ "1,3"

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB018

Funcao criada para validar Critica B018
CPF Invalido

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB018(oModel)
	Local lRet := .T.

	Local cCPF := ""

	Default oModel := Nil

	cCPF := RetCPF(oModel)

	If !Empty(cCPF)
		cCPF := PadL(AllTrim(cCPF),11,"0")
		lRet := !(cCPF $ "00000000000,11111111111,22222222222,33333333333,"+;
			"44444444444,55555555555,66666666666,77777777777,"+;
			"88888888888,99999999999") .AND. CGC(cCPF,"",.F.)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB019

Funcao criada para validar Critica B019
CPF é obrigatório para beneficiario titular (independentemente de idade).

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB019(oModel)
	Local lRet := .T.

	Local cCPF := ""
	Local cTipoDep := ""

	Default oModel := Nil

	If oModel == Nil
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
		cCPF := RetCPF(oModel)
	Else
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cCPF := RetCPF(oModel)
	EndIf

	lRet := cTipoDep != '01' .OR. !Empty(cCPF)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB020

Funcao criada para validar Critica B020
CPF é obrigatório para beneficiario dependente com idade igual ou superior a 18 anos.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB020(oModel)
	Local lRet := .T.

	Local cCPF := ""

	Local nIdade := 0

	Local dDatNas := STOD("")

	Default oModel := Nil


	If oModel == Nil
		dDatNas := B3K->B3K_DATNAS
		cCPF := RetCPF(oModel)
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
	Else
		dDatNas := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
		cCPF := RetCPF(oModel)
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
	EndIf

	lRet := cTipoDep == '01' .OR. nIdade < 18 .OR. !Empty(cCPF)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB021

Funcao criada para validar Critica B021
CPF ou Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para dependente menor de idade.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB021(oModel)
	Local lRet := .T.

	Local cCPF := ""
	Local cNomeMae := ""
	Local cCNS := ""
	Local cPisPas := ""
	Local cTipoDep := ""

	Local nIdade := 0

	Local dDatNas := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dDatNas := B3K->B3K_DATNAS
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
		cCPF := RetCPF(oModel)
		cNomeMae := AllTrim(B3K->B3K_NOMMAE)
		cPisPas := AllTrim(B3K->B3K_PISPAS)
		cCNS := AllTrim(B3K->B3K_CNS)
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
	Else
		dDatNas := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cCPF := RetCPF(oModel)
		cNomeMae := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_NOMMAE' ))
		cPisPas := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_PISPAS' ))
		cCNS := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNS' ))
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
	EndIf

	lRet := cTipoDep == '01' .OR. nIdade >= 18 .OR. (nIdade < 18 .AND. (!Empty(cCPF) .OR. !Empty(cNomeMae) .OR. !Empty(cPisPas) .OR. !Empty(cCNS)) )

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB022

Funcao criada para validar Critica B022
Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para titular e dependente maior de idade.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB022(oModel)
	Local lRet := .T.

	Local cNomeMae := ""
	Local cCNS := ""
	Local cPisPas := ""
	Local cTipoDep := ""

	Local nIdade := 0

	Local dDatNas := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dDatNas := B3K->B3K_DATNAS
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
		cNomeMae := AllTrim(B3K->B3K_NOMMAE)
		cPisPas := AllTrim(B3K->B3K_PISPAS)
		cCNS := AllTrim(B3K->B3K_CNS)
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
	Else
		dDatNas := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cNomeMae := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_NOMMAE' ))
		cPisPas := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_PISPAS' ))
		cCNS := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNS' ))
		nIdade	:= Calc_Idade(dDataBase,dDatNas)
	EndIf

	lRet := nIdade < 18 .OR. !Empty(cNomeMae) .OR. !Empty(cPisPas) .OR. !Empty(cCNS)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB023

Funcao criada para validar Critica B023
PIS/PASEP invalido

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB023(oModel)
	Local lRet := .T.

	Local cPisPas := ""

	Default oModel := Nil

	If oModel == Nil

		cPisPas := AllTrim(B3K->B3K_PISPAS)

	Else

		cPisPas := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_PISPAS' ))

	EndIf

	lRet := Empty(cPisPas) .OR. ChkPis(cPisPas)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB025

Funcao criada para validar Critica B025
Nome da Mãe Invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB025(oModel)

	Local lRet 	   := .T.
	Local cNomeMae := ""
	Local cCriMae  := "1"
	Default oModel := Nil

	If oModel == Nil
		cNomeMae := B3K->B3K_NOMMAE
		if B3K->(FieldPos("B3K_CRIMAE")) > 0
			cCriMae := B3K->B3K_CRIMAE
		EndIf
	Else
		cNomeMae := oModel:GetValue( 'B3KMASTER', 'B3K_NOMMAE' )
		if B3K->(FieldPos("B3K_CRIMAE")) > 0
			cCriMae := oModel:GetValue( 'B3KMASTER', 'B3K_CRIMAE' )
		EndIf
	EndIf

	If cCriMae == '1' .OR. Empty(cCriMae)
		lRet := PLVlANSNome(cNomeMae)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB026

Funcao criada para validar Critica B026
CNS invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB026(oModel)
	Local lRet := .T.

	Local cCNS := ""

	Default oModel := Nil

	If oModel == Nil
		cCNS := B3K->B3K_CNS
	Else
		cCNS := oModel:GetValue( 'B3KMASTER', 'B3K_CNS' )
	EndIf

	lRet := CenVldCns(cCNS)

Return lRet


Function CenVldCns(cCNS)
Return(IIF(Substr(cCNS,1,1) $ "7/8/9",Fs_VldCnsP(cCNS),Fs_VldCnsD(cCNS)))

//Valida Cns Definitivo
Static Function Fs_VldCNSD(cCNS)
	Local lRet := .F.
	Local cRad   := '000'

	If cCNS == '000000000000000'
		Return(lRet)
	EndIf
	If Empty(cCNS)
		Return(lRet)
	EndIf
	If Len(cCNS) < 15
		Return(lRet)
	EndIf
	If (nDig := 11 - (Fs_SomaCns(cCns) % 11)) == 11
		nDig := 0
	ElseIf nDig == 10
		nDig := (11 - (Fs_SomaCns(cCns,,2) % 11))
		cRad := '001'
	EndIf

	lRet := SubStr(cCNS, 1, 11)+cRad+AllTrim(Str(nDig)) == cCns

Return(lRet)

//Valida Cns Provisório
Static Function Fs_VldCNSP(cCNS)
	If Len(cCNS) < 15
		Return(.F.)
	EndIf
Return(Fs_SomaCns(cCns, 15, ,15) % 11 == 0)

Static Function Fs_SomaCns(cCns, nMulti, nAdiciona, nFator)

	Local nSoma := 0, nI := 0

	Default nAdiciona := 0
	Default nMulti    := 15
	Default nFator    := 11

	For nI := 1 to nFator
		nSoma += val( substr(cCNS,nI,1) ) * nMulti
		nMulti--
	Next

Return(nSoma+nAdiciona)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB027

Funcao criada para validar Critica B027
Código de Identificação do Beneficiario é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 18/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB027(oModel)
	Local lRet := .T.

	Local cCod := ""

	Default oModel := Nil

	If oModel == Nil
		cCod := B3K->B3K_MATRIC
	Else
		cCod := oModel:GetValue( 'B3KMASTER', 'B3K_MATRIC' )
	EndIf

	lRet := !Empty(cCod)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB029

Funcao criada para validar Critica B029
Código de Indicação de endereço é obrigatório para residentes no Brasi

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB029(oModel)
	Local lRet := .T.


Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB030

Funcao criada para validar Critica B030
Código de Indicação de endereço não deve existir para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB030(oModel)
	Local lRet := .T.

	Local cTipEnd := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cTipEnd := B3K->B3K_TIPEND
		cResExt := B3K->B3K_RESEXT
	Else
		cTipEnd := oModel:GetValue( 'B3KMASTER', 'B3K_TIPEND' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .Or. Empty(cTipEnd)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB031

Funcao criada para validar Critica B031
Logradouro é obrigatório para beneficiarios residentes no Brasil

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB031(oModel)

	Local lRet := .T.
	Local cEnd := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cEnd := B3K->B3K_ENDERE
		cResExt := B3K->B3K_RESEXT
	Else
		cEnd := oModel:GetValue( 'B3KMASTER', 'B3K_ENDERE' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt $ ' ,0' .AND. !Empty(cEnd)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB032

Funcao criada para validar Critica B032
Logradouro não deve existir para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB032(oModel)
	Local lRet := .T.

	Local cEnd := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cEnd  := B3K->B3K_ENDERE
		cResExt := B3K->B3K_RESEXT
	Else
		cEnd  := oModel:GetValue( 'B3KMASTER', 'B3K_ENDERE' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .Or. Empty(cEnd)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB033

Funcao criada para validar Critica B033
Número do Logradouro não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB033(oModel)
	Local lRet := .T.

	Local cNumEnd := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cNumEnd  := B3K->B3K_NR_END
		cResExt := B3K->B3K_RESEXT
	Else
		cNumEnd  := oModel:GetValue( 'B3KMASTER', 'B3K_NR_END' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .Or. Empty(cNumEnd)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB034

Funcao criada para validar Critica B034
Número do Logradouro é obrigatório para beneficiarios residentes no Brasil

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB034(oModel)
	Local lValido := .T.

	Local cEnd := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cEnd := B3K->B3K_NR_END
		cResExt := B3K->B3K_RESEXT
	Else
		cEnd := oModel:GetValue( 'B3KMASTER', 'B3K_ENDERE' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lValido := cResExt $ ' ,0' .AND. !Empty(cEnd)

Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB035

Funcao criada para validar Critica B035
Complemento Logradouro não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB035(oModel)
	Local lRet := .T.

	Local cComplem := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cComplem  := B3K->B3K_COMEND
		cResExt := B3K->B3K_RESEXT
	Else
		cComplem  := oModel:GetValue( 'B3KMASTER', 'B3K_COMEND' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .OR. Empty(cComplem)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB036

Funcao criada para validar Critica B036
Bairro não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB036(oModel)
	Local lRet := .T.

	Local cBairro := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cBairro  := B3K->B3K_BAIRRO
		cResExt := B3K->B3K_RESEXT
	Else
		cBairro  := oModel:GetValue( 'B3KMASTER', 'B3K_BAIRRO' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .OR. Empty(cBairro)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB037

Funcao criada para validar Critica B037
Código de município é obrigatório para beneficiarios residentes no Brasil

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB037(oModel)
	Local lRet := .T.


Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB038

Funcao criada para validar Critica B038
Código de município não existe na tabela de município do IBGE.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB038(oModel)
	Local lRet := .T.

	Local cSql := ""
	Local cCodMun := ""

	Default oModel := Nil

	If oModel == Nil
		cCodMun := B3K->B3K_CODMUN
	Else
		cCodMun := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODMUN' ))
	EndIf

	If !Empty(cCodMun)

		//BID_FILIAL+BID_CODMUN
		cSql := " SELECT BID_CODMUN FROM " + RetSqlName("BID")
		cSql += " WHERE BID_FILIAL = '" + xFilial("BID") + "' "
		cSql += " AND BID_CODMUN like '" + AllTrim(cCodMun) + "%' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		lRet := !TRB1->(Eof())
		TRB1->(dbCloseArea())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB039

Funcao criada para validar Critica B039
Código de município não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB039(oModel)
	Local lRet := .T.

	Local cCodMun := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cCodMun  := B3K->B3K_CODMUN
		cResExt := B3K->B3K_RESEXT
	Else
		cCodMun  := oModel:GetValue( 'B3KMASTER', 'B3K_CODMUN' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .OR. Empty(cCodMun)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB040

Funcao criada para validar Critica B040
CEP é obrigatório para beneficiarios residentes no Brasil

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB040(oModel)
	Local lRet := .T.

	Local cCEP := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cCEP  := B3K->B3K_CEPUSR
		cResExt := B3K->B3K_RESEXT
	Else
		cCEP  := oModel:GetValue( 'B3KMASTER', 'B3K_CEPUSR' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt $ ' ,0' .AND. !Empty(cCEP)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB041

Funcao criada para validar Critica B041
CEP não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB041(oModel)
	Local lRet := .T.

	Local cCEP := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cCEP  := B3K->B3K_CEPUSR
		cResExt := B3K->B3K_RESEXT
	Else
		cCEP  := oModel:GetValue( 'B3KMASTER', 'B3K_CEPUSR' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .OR. Empty(cCEP)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB042

Funcao criada para validar Critica B042
Código de município de residência não existe na tabela de município do IBGE.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB042(oModel)

	Local lRet := .T.
	Local cSql := ""
	Local cCodMun := ""
	Default oModel := Nil

	If oModel == Nil
		cCodMun := B3K->B3K_MUNICI
	Else
		cCodMun := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_MUNICI' ))
	EndIf

	If !Empty(cCodMun) .AND. Val(cCodMun) > 0 .And. SIBVLDB081(oModel)

		//BID_FILIAL+BID_CODMUN
		cSql := " SELECT BID_CODMUN FROM " + RetSqlName("BID")
		cSql += " WHERE BID_FILIAL = '" + xFilial("BID") + "' "
		cSql += " AND BID_CODMUN like '" + AllTrim(cCodMun) + "%' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		lRet := !TRB1->(Eof())
		TRB1->(dbCloseArea())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB043

Funcao criada para validar Critica B043
Código de município de residência não deve existir no cadastro para beneficiarios residentes no exterior

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB043(oModel)
	Local lRet := .T.

	Local cMunRes := ""
	Local cResExt := ""

	Default oModel := Nil

	If oModel == Nil
		cMunRes  := B3K->B3K_MUNICI
		cResExt := B3K->B3K_RESEXT
	Else
		cMunRes := oModel:GetValue( 'B3KMASTER', 'B3K_MUNICI' )
		cResExt := oModel:GetValue( 'B3KMASTER', 'B3K_RESEXT' )
	EndIf

	lRet := cResExt != '1' .OR. Empty(cMunRes)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB044

Funcao criada para validar Critica B044
Código de município de residência não deve existir no cadastro para beneficiarios com endereço residencial

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB044(oModel)
	Local lRet := .T.

	Local cMunRes := ""
	Local cTipEnd := ""

	Default oModel := Nil

	If oModel == Nil
		cMunRes  := B3K->B3K_MUNICI
		cTipEnd := B3K->B3K_TIPEND
	Else
		cMunRes  := oModel:GetValue( 'B3KMASTER', 'B3K_MUNICI' )
		cTipEnd := oModel:GetValue( 'B3KMASTER', 'B3K_TIPEND' )
	EndIf

	lRet := cTipEnd != '2' .OR. Empty(cMunRes)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB045

Funcao criada para validar Critica B045
DN não deve existir no cadastro para beneficiarios com data de nascimento anterior a 01/01/2007

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB045(oModel)
	Local lRet := .T.

	Local cDN := ""

	Local dDatNas := STOD("")

	Default oModel := Nil

	If oModel == Nil
		cDN  := B3K->B3K_DN
		dDatNas := B3K->B3K_DATNAS
	Else
		cDN := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_DN' ))
		dDatNas := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
	EndIf

	lRet := Empty(cDN) .OR. dDatNas >= STOD('20070101')

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB046

Funcao criada para validar Critica B046
Data de nascimento deve ser anterior ou igual à primeira data da contratação do plano

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB046(oModel)
	Local lRet := .T.

	Local dDatCon := STOD("")
	Local dDatNas := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dDatCon  := B3K->B3K_DATINC
		dDatNas := B3K->B3K_DATNAS
	Else
		dDatCon := oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
		dDatNas := oModel:GetValue( 'B3KMASTER', 'B3K_DATNAS' )
	EndIf

	lRet := dDatNas <= dDatCon

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB047

Funcao criada para validar Critica B047
Ja existe registro ativo com o mesmo CPF e plano na operadora.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB047(oModel)
	Local lRet := .T.

	Local cSql := ""
	Local cCodOpe := ""
	Local cCodPro := ""
	Local cMatric := ""
	Local cCpf := ""
	Local cForCon := ""

	Local nCont := 0

	Default oModel := Nil

	If oModel == Nil
		cCodOpe  := B3K->B3K_CODOPE
		cCodPro := B3K->B3K_CODPRO
		cMatric := B3K->B3K_MATRIC
		cCPF := RetCPF(oModel)
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		cCodPro := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODPRO' ))
		cMatric := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_MATRIC' ))
		cCPF := RetCPF(oModel)
	EndIf

	If !Empty(cCpf)

		cSql := " SELECT B3J_FORCON FROM " + RetSqlName("B3J")
		cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
		cSql += " AND B3J_CODOPE = '" + cCodOpe + "' "
		cSql += " AND B3J_CODIGO = '" + cCodPro + "' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		If !TRB1->(Eof())
			cForCon := TRB1->B3J_FORCON
		EndIf
		TRB1->(dbCloseArea())

		//'1=Individual/Familiar;2=Coletivo Empresarial;3=Coletivo por Adesao'
		If cForCon = '1'

			cSql := " SELECT COUNT(*) CONT FROM " + RetSqlName("B3K")
			cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
			cSql += " AND B3K_CODOPE = '" + cCodOpe + "' "
			cSql += " AND B3K_CODPRO = '" + cCodPro + "' "
			cSql += " AND B3K_CPF = '" + cCPF + "' "
			cSql += " AND B3K_MATRIC <> '" + cMatric + "' "
			cSql += " AND B3K_DATBLO = '' "
			cSql += " AND D_E_L_E_T_ = ' '"
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

			If !TRB1->(Eof())
				nCont := TRB1->CONT
			EndIf
			TRB1->(dbCloseArea())

			lRet := nCont == 0

		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB049

Funcao criada para validar Critica B049
Número do plano (RPS) e código do plano (SCPA) não podem ser informados simultaneamente.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB049(oModel)
	Local lRet := .T.

	Local cRPS := ""
	Local cSCPA := ""

	Default oModel := Nil

	If oModel == Nil
		cRPS  := B3K->B3K_SUSEP
		cSCPA  := B3K->B3K_SCPA
	Else
		cRPS := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SUSEP' ))
		cSCPA := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SCPA' ))
	EndIf

	lRet := Empty(cRPS) .OR. Empty(cSCPA)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB050

Funcao criada para validar Critica B050
Um dos planos (RPS ou SCPA) é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB050(oModel)

	Local lRet := .T.
	Local cRPS := ""
	Local cSCPA := ""

	Default oModel := Nil

	If oModel == Nil
		cRPS  := B3K->B3K_SUSEP
		cSCPA  := B3K->B3K_SCPA
	Else
		cRPS := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SUSEP' ))
		cSCPA := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SCPA' ))
	EndIf

	lRet := !Empty(cRPS) .OR. !Empty(cSCPA)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB051

Funcao criada para validar Critica B051
Data de contratação do plano é obrigatória.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB051(oModel)
	Local lRet := .T.

	Local dDatCon := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dDatCon  := B3K->B3K_DATINC
	Else
		dDatCon := oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
	EndIf

	lRet := !Empty(dDatCon)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB052

Funcao criada para validar Critica B052
Data de contratação do plano deve ser posterior ou igual a 01/01/1940

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB052(oModel)
	Local lRet := .T.

	Local dDatCon := STOD("")

	Default oModel := Nil

	If oModel == Nil
		dDatCon  := B3K->B3K_DATINC
	Else
		dDatCon := oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
	EndIf

	lRet := dDatCon >= STOD('19400101')

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB053

Funcao criada para validar Critica B053
Data de Contratação deve ser posterior ou igual a 01/01/1999, pois o plano informado é RPS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB053(oModel)
	Local lRet := .T.

	// Local cRPS := STOD("")

	// Local dDatCon := STOD("")

	Default oModel := Nil

	// If oModel == Nil
	// 	cRPS  := B3K->B3K_SUSEP
	// 	dDatCon  := B3K->B3K_DATINC
	// Else
	// 	cRPS := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SUSEP' ))
	// 	dDatCon := oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
	// EndIf

	// lRet := Empty(cRPS) .OR. dDatCon >= STOD('19990101')

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB054

Funcao criada para validar Critica B054
Código de relação de dependência é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB054(oModel)
	Local lRet := .T.

	Local cRelDep := ""

	Default oModel := Nil

	If oModel == Nil
		cRelDep  := B3K->B3K_TIPDEP
	Else
		cRelDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
	EndIf

	lRet := !Empty(cRelDep)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB055

Funcao criada para validar Critica B055
Código de relação de dependência não existe no sistema.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB055(oModel)
	Local lRet := .T.

	Local cRelDep := ""

	Default oModel := Nil

	If oModel == Nil
		cRelDep  := B3K->B3K_TIPDEP
	Else
		cRelDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
	EndIf

	lRet := cRelDep $ '01,03,04,06,08,10'

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB056

Funcao criada para validar Critica B056
Código de Cobertura Parcial Temporaria (CPT) é obrigatório

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB056(oModel)
	Local lRet := .T.

	Local cCPT := ""

	Default oModel := Nil

	If oModel == Nil
		cCPT  := B3K->B3K_COBPAR
	Else
		cCPT := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_COBPAR' ))
	EndIf

	lRet := !Empty(cCPT)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB057

Funcao criada para validar Critica B057
Código de Cobertura Parcial Temporaria (CPT) não existe no sistema

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB057(oModel)
	Local lRet := .T.

	Local cCPT := ""

	Default oModel := Nil

	If oModel == Nil
		cCPT  := B3K->B3K_COBPAR
	Else
		cCPT := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_COBPAR' ))
	EndIf

	lRet := cCPT $ "0,1"

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB058

Funcao criada para validar Critica B058
Código de itens de procedimentos excluídos da cobertura (IPEC) não existe no sistema.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB058(oModel)
	Local lRet := .T.

	Local cItExc := ""

	Default oModel := Nil

	If oModel == Nil
		cItExc  := B3K->B3K_ITEEXC
	Else
		cItExc := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_ITEEXC' ))
	EndIf

	lRet := cItExc $ "0,1"

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB059

Funcao criada para validar Critica B059
CNPJ e CEI da empresa contratante não podem existir no cadastro simultaneamente

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB059(oModel)

	Local lRet := .T.
	Local cCNPJ := ""
	Local cCEI := ""

	Default oModel := Nil

	If oModel == Nil
		cCNPJ  := B3K->B3K_CNPJCO
		cCEI  := B3K->B3K_CEICON
	Else
		cCNPJ := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNPJCO' ))
		cCEI := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CEICON' ))
	EndIf

	lRet := Empty(cCNPJ) .OR. Empty(cCEI)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB060

Funcao criada para validar Critica B060
CNPJ ou CEI da empresa contratante, um deles deve existir para plano coletivo.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB060(oModel)

	Local lRet := .T.
	Local cCNPJ := ""
	Local cCEI := ""
	Local cCodPro := ""
	Local cCodOpe := ""
	Local cSql := ""
	Local cForCon := ""
	Local cCaepf := ""

	Default oModel := Nil

	If oModel == Nil
		cCNPJ  := B3K->B3K_CNPJCO
		cCEI  := B3K->B3K_CEICON
		cCodPro  := B3K->B3K_CODPRO
		cCodOpe  := B3K->B3K_CODOPE
		If B3K->(FieldPos("B3K_CAEPF")) > 0
			cCaepf := B3K->B3K_CAEPF
		EndIf
	Else
		cCNPJ := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNPJCO' ))
		cCEI := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CEICON' ))
		cCodPro := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODPRO' ))
		cCodOpe := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		If B3K->(FieldPos("B3K_CAEPF")) > 0
			cCaepf := AllTrim(oModel:GetValue('B3KMASTER', 'B3K_CAEPF'))
		EndIf
	EndIf

	cSql := " SELECT B3J_FORCON FROM " + RetSqlName("B3J")
	cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
	cSql += " AND B3J_CODOPE = '" + cCodOpe + "' "
	cSql += " AND B3J_CODIGO = '" + cCodPro + "' "
	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		cForCon := TRB1->B3J_FORCON
	EndIf
	TRB1->(dbCloseArea())

	If B3K->(FieldPos("B3K_CAEPF")) > 0
		lRet := Empty(cForCon) .OR. (cForCon == '1' .OR. !Empty(cCNPJ) .OR. !Empty(cCEI) .OR. !Empty(cCaepf))
	Else
		lRet := Empty(cForCon) .OR. (cForCon == '1' .OR. !Empty(cCNPJ) .OR. !Empty(cCEI))
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB061

Funcao criada para validar Critica B061
CNPJ ou CEI da empresa contratante não deve existir para plano individual ou familiar.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB061(oModel)
	Local lRet := .T.

	Local cCNPJ := ""
	Local cCEI := ""
	Local cCodPro := ""
	Local cCodOpe := ""
	Local cSql := ""
	Local cForCon := ""

	Default oModel := Nil

	If oModel == Nil
		cCNPJ  := B3K->B3K_CNPJCO
		cCEI  := B3K->B3K_CEICON
		cCodPro  := B3K->B3K_CODPRO
		cCodOpe  := B3K->B3K_CODOPE
	Else
		cCNPJ := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNPJCO' ))
		cCEI := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CEICON' ))
		cCodPro := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODPRO' ))
		cCodOpe := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
	EndIf

	cSql := " SELECT B3J_FORCON FROM " + RetSqlName("B3J")
	cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
	cSql += " AND B3J_CODOPE = '" + cCodOpe + "' "
	cSql += " AND B3J_CODIGO = '" + cCodPro + "' "
	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If !TRB1->(Eof())
		cForCon := TRB1->B3J_FORCON
	EndIf
	TRB1->(dbCloseArea())


	lRet := Empty(cForCon) .OR. (cForCon != '1' .OR. (Empty(cCNPJ) .AND. Empty(cCEI)))

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB062

Funcao criada para validar Critica B062
CNPJ da empresa contratante invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB062(oModel)
	Local lRet := .T.

	Local cCNPJ := ""

	Default oModel := Nil

	If oModel == Nil
		cCNPJ  := B3K->B3K_CNPJCO
	Else
		cCNPJ := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNPJCO' ))
	EndIf

	lRet := Empty(cCNPJ) .OR. CGC(cCNPJ,"",.F.)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB063

Funcao criada para validar Critica B063
CEI da empresa contratante invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB063(oModel)
	Local lRet := .T.

	Local cCEI := ""

	Default oModel := Nil

	If oModel == Nil
		cCEI  := B3K->B3K_CEICON
	Else
		cCEI := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CEICON' ))
	EndIf

	lRet := Empty(cCEI) .OR. PlsVldCEI(cCEI)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsVldCEI

Funcao criada para validar um CEI

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------

Function PlsVldCEI(cCEI)
	Local lRet := .T.

	Local cPeso := '74185216374'
	Local cNumero := ""
	Local cDigito :=""
	Local cDV := ""

	Local nSoma := 0
	Local nI := 0

	//Indica que o campo CEI não pode ser preenchido por números repetidos
	Local aInvalidos := {"000000000000","111111111111","222222222222","333333333333","444444444444", "555555555555","666666666666","777777777777","888888888888","999999999999"}

	Default cCEI := ""

	If (Len(cCEI) <> 12 .Or. AScan(aInvalidos,cCEI) .Or. Left(cCEI,10) == "0000000000")
		lRet := .F.
	Else
		cNumero := SubStr(cCei,1,11)
		cDigito := SubStr(cCei,12,1)

		//Soma o produto dos dígitos vezes os pesos
		For nI := 1 to 11

			nSoma += (Val(SubStr(cNumero,nI,1)) * Val(SubStr(cPeso,nI,1)))

		Next nI

		//Recupera a dezena e a unidade da soma anterior (dois dígitos à direita)
		cValor := Right( Alltrim(Str(nSoma)), 2 )
		//Soma o digito da dezena do resultado com o dígito da unidade do resultado  (soma os dois dígitos anteriores)
		nSoma := Val(SubStr(cValor,1,1)) + Val(SubStr(cValor,2,1))
		//Recupera a unidade da segunda soma
		cValor := Right( Alltrim(Str(nSoma)), 1 )
		//Subtrai de dez o digito da unidade do item anterior
		cDV = Right(Alltrim(Str(10 - Val(cValor))),1)

		//O dígito do CEI em validação, deve ser igual ao resultado da subtração
		lRet := cDigito == cDV

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB064

Funcao criada para validar Critica B064
Campo de Identificação de beneficiario titular é obrigatório para beneficiario dependente.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB064(oModel)
	Local lRet := .T.

	Local cTipoDep := ""
	Local cTitular := ""

	Default oModel := Nil

	If oModel == Nil
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
		cTitular  := AllTrim(B3K->B3K_CODTIT)
	Else
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cTitular := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODTIT' ))
	EndIf

	lRet := cTipoDep == '01' .OR. !Empty(cTitular)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB065

Funcao criada para validar Critica B065
Campo de Identificação de beneficiario titular não pertence a um titular

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB065(oModel)
	Local lRet := .T.

	Local cSql := ""
	Local cCodOpe := ""
	Local cTitular := ""

	Default oModel := Nil

	If oModel == Nil
		cCodOpe  := B3K->B3K_CODOPE
		cTitular := B3K->B3K_CODTIT
		cTipDep := B3K->B3K_TIPDEP
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		cTitular := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODTIT' ))
		cTipDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
	EndIf
	If !Empty(cTipDep) .AND. cTipDep <> '01'
		cSql := " SELECT COUNT(*) CONT FROM " + RetSqlName("B3K")
		cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
		cSql += " AND B3K_CODOPE = '" + cCodOpe + "' "
		cSql += " AND (B3K_MATRIC = '" + cTitular + "' "
		cSql += " OR   B3K_MATANT = '" + cTitular + "') "
		cSql += " AND B3K_TIPDEP = '01' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		lRet := TRB1->CONT > 0

		TRB1->(dbCloseArea())

		If !lRet
			cSql := " SELECT COUNT(*) CONT FROM " + RetSqlName("B3W")
			cSql += " WHERE B3W_FILIAL = '" + xFilial("B3W") + "' "
			cSql += " AND B3W_MATRIC = '" + cTitular + "' "
			cSql += " AND B3W_TIPDEP = '1' "
			cSql += " AND D_E_L_E_T_ = ' '"
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

			lRet := TRB1->CONT > 0

			TRB1->(dbCloseArea())
		EndIf

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB066

Funcao criada para validar Critica B066
Campo de Identificação de beneficiario titular não deve existir no cadastro para beneficiario titular.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB066(oModel)
	Local lRet := .T.

	Local cTipoDep := ""
	Local cTitular := ""

	Default oModel := Nil

	If oModel == Nil
		cTipoDep := AllTrim(B3K->B3K_TIPDEP)
		cTitular  := AllTrim(B3K->B3K_CODTIT)
	Else
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cTitular := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODTIT' ))
	EndIf

	lRet := cTipoDep != '01' .OR. Empty(cTitular)
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSALTANS

Funcao criada para corrigir a critica e enviar a alteração para a ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSALTANS(lEnviaANS, lAuto, cRec)

	Local dDtRef   := STOD("")
	Local nI       := 0
	Local nLen     := 0
	Local aCampos  := {}
	Local aArea    := B3K->(GetArea())
	Local cMsg     := ""
	Local cAlias   := ""
	Local cVlrAnt  := ""
	Local cVlrNovo := ""

	Default lEnviaANS := .F.
	Default lAuto     := .F.
	Default cRec     := ''

	If cRec <> ''
		cRec := Val(cRec)
		B3F->(DbGoTo(cRec))
	EndIf

	cAlias := B3F->B3F_ORICRI

	If B3F->B3F_STATUS == CRIT_PDTE .AND. cAlias == "B3K" .AND. B3F->B3F_TIPO = JOBESPELHO

		If !lAuto
			//lEnviaANS :=  Pergunte('PLSENVANS',.T.,"Enviar dados do Beneficiario para ANS",.F.)
			MV_PAR01 := dDataBase
		EndIf

		dDtRef  := If(Empty(MV_PAR01),dDataBase,MV_PAR01)
		cCampos := AllTrim(B3F->B3F_CAMPOS)
		cCodCri := AllTrim(B3F->B3F_CODCRI)

		nRecno := B3F->B3F_CHVORI
		cIdeOri := B3F->B3F_IDEORI
		cDesOri := B3F->B3F_DESORI
		cRegANS := B3F->B3F_CODOPE

		cOpe := RetOpe(cCodCri,nRecno)

		//Cria um registro de alteração para ser enviado à ANS
		If !Empty(cCampos) .AND. !Empty(dDtRef) .AND. !Empty(cOpe)

			cHoraMov := Time()

			If cOpe $ "" + SIB_CANCELA + "," + SIB_REATIVA
				B3K->(DbGoto(nRecno))
				//Atualizo o histórico de cancelamentos
				PLInHisCanCO(dDtRef,cOpe==SIB_CANCELA,cIdeOri,IIf(cOpe==SIB_CANCELA,B3K->B3K_MOTBLO,""),cHoraMov,B3K->B3K_CODOPE,B3K->B3K_CODCCO)
			EndIf
			If cOpe == SIB_RETIFIC
				posBenefAns(cRegANS)
				aCampos := StrTokArr2(cCampos,".")
				nLen := len(aCampos)
				For nI := 1 to nLen

					cCampo := aCampos[nI]
					cVlrAnt  := &("B3W->B3W" + SubStr(cCampo,4,len(cCampo) ) )
					cVlrNovo := &("B3K->" + cCampo)

					PlAtuHisOpe(nRecno,cCampo,dDtRef,cOpe,cIdeOri,;
						cDesOri,,,cRegANS,;
						,cHoraMov,cVlrAnt,cVlrNovo,B3K->B3K_CODCCO)
				Next nI
			Else
				PlAtuHisOpe(nRecno,"",dDtRef,cOpe,cIdeOri,;
					cDesOri,,,cRegANS,;
					,cHoraMov,cVlrAnt,cVlrNovo,B3K->B3K_CODCCO)
			EndIf

			//Coloca o Alias para ser validado novamente
			AtuStatAlias(cAlias,B3F->B3F_CHVORI,B3F->B3F_TIPO )

			CorrigeCritica()

			cMsg := "Movimentação criada e crítica corrigida."
			If !lAuto
				MsgInfo(cMsg)
			EndIf
		EndIf

	ElseIf cAlias == "B3W" .OR. B3F->B3F_TIPO <> JOBESPELHO
		cMsg := "Operação não disponível para este tipo de crítica"
		If !lAuto
			Alert(cMsg)
		EndIf

	Else
		cMsg := "A crítica ja foi corrigida."
		If !lAuto
			Alert(cMsg)
		EndIf
	EndIf

	RestArea(aArea)

Return cMsg

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetOpe

Funcao criada para retornar a operação que deve ser enviada para a ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetOpe(cCodCri,nRecno)
	Local cOpe := ""
	Local cCritInc := "E029"
	Local cCritBlo := "E031"
	Local aArea := B3K->(GetArea())

	If cCodCri $ cCritInc
		cOpe := SIB_INCLUIR
	ElseIf cCodCri $ cCritBlo
		B3K->(DbGoto(nRecno))
		If cCodCri == "E031" //Status diferente entre Central e ANS
			If B3K->B3K_SITANS == "A"
				cOpe := SIB_REATIVA
			ElseIf B3K->B3K_SITANS == "I"
				cOpe := SIB_CANCELA
			EndIf
		EndIf
	Else
		cOpe := SIB_RETIFIC
	EndIf

	RestArea(aArea)
Return cOpe

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} posBenefAns

Posiciona no registro da beneficiário na ANS B3W

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function posBenefAns(cRegANS)
	Local lFound := .F.
	B3W->(DbSetOrder(1)) //B3W_FILIAL+B3W_CODOPE+B3W_CODCCO
	lFound := B3W->(MsSeek(xFilial("B3W")+cRegANS+B3K->B3K_CODCCO))

Return lFound

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CorrigeCritica

Funcao criada para corrigir a critica

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------

Static Function CorrigeCritica()

	Local cSql			:= ""	//Query a ser executada
	Local lRet			:= .T.

	cSql := " DELETE FROM " + RetSqlName('B3F') + " "
	cSql += " WHERE "
	cSql += "	B3F_FILIAL = '" + xFilial("B3F") + "' "
	cSql += " AND B3F_CODOPE = '" + B3F->B3F_CODOPE + "' "
	cSql += " AND B3F_ORICRI = '" + B3F->B3F_ORICRI + "' "
	cSql += " AND B3F_CHVORI = " + PADL(AllTrim(Str(B3F->B3F_CHVORI)),10) + " "
	cSql += " AND B3F_CODCRI = '" + B3F->B3F_CODCRI + "' "
	cSql += " AND B3F_TIPO = '"   + B3F->B3F_TIPO + "' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0

	PLSLOGFIL(CENDTHRL("I") + " CorrigeCritica: " + cSql,ARQ_LOG_EXC)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnLmpCriBen

Limpa as criticas de um beneficiários

@return lRetorno	.F. registros nao apagados ou .T. registros apagados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnLmpCriBen(nRecno,cAliasOri)
	Local cSql			:= ""	//Query a ser executada
	Local lRet			:= .T.

	Default cAliasOri := 'B3K'

	cSql := " DELETE FROM " + RetSqlName('B3F') + " "
	cSql += " WHERE "
	cSql += "	B3F_FILIAL = '" + xFilial("B3F") + "' "
	cSql += " AND B3F_ORICRI = '" + cAliasOri + "' "
	cSql += " AND B3F_CHVORI = " + PADL(AllTrim(Str(nRecno)),10) + " "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0
	PLSLOGFIL(CENDTHRL("I") + " CnLmpCriBen: " + cSql,ARQ_LOG_EXC)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuStatAlias

Funcao criada para atualizar o status da tabela que foi criticada

@param cAlias		Alias da tabela do registro
@param nRecno		Recno do registro a ser atualizado
@param cTipoVld	1=Job Validação;2=Comparação espelhos; 3 =Arq. Retorno

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------

Static Function AtuStatAlias(cAlias,nRecno,cTipoVld)
	DEFAULT cAlias := ""
	DEFAULT nRecno := 0

	If !Empty (cAlias) .AND. nRecno > 0

		B3K->(DbGoTo(nRecno))
		If !B3K->(Eof())
			RecLock(cAlias,.F.)
			If cTipoVld == JOBESPELHO
				B3K->B3K_STAESP := '1'
			Else
				B3K->B3K_STASIB := '1'
			EndIf
			B3K->(MsUnlock())
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB067

Funcao criada para validar Critica B067
Data de contratação deve ser posterior a maior data existente no cadastro: Data de Reativação ou Data de Contratação.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB067(oModel)
	Local lRet := .T.
	Local cCodOpe := ""
	Local cMatOri := ""
	Local dDatCon := STOD("")
	Local dDatTran := STOD("")
	Local aAreaB3K := B3K->(GetArea())
	Default oModel := Nil

	If oModel == Nil
		cCodOpe  := AllTrim(B3K->B3K_CODOPE)
		cMatOri  := AllTrim(B3K->B3K_TRAORI)
		dDatTran := B3K->B3K_DATINC
		dDatRea  := B3K->B3K_DATREA
	Else
		cCodOpe 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		cMatOri 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TRAORI' ))
		dDatTran 	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
		dDatRea  	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATREA' )
	EndIf

	If !Empty(cMatOri)
		B3K->(DbSetOrder(1))

		If B3K->(MsSeek(xFilial("B3K")+cCodOpe+PADR(cMatOri,tamSX3("B3K_MATRIC")[1])))
			dDatCon := B3K->B3K_DATINC
		EndIf

		lRet := dDatTran >= dDatCon .AND. dDatTran >= dDatRea
	EndIf

	RestArea(aAreaB3K)
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB068

Funcao criada para validar Critica B068
Data de Contratação deve ser anterior ou igual a menor data existente no cadastro:
	Data Histórico ou
	Data Cancelamento ou
	Data Reativação ou
	Data de Inclusão.
Se não tiver havido mudança contratual.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB068(oModel)
	Local lRet := .T.

	Local cMatDes := ""

	Local dDatInc := STOD("")
	Local dDatBlo := STOD("")
	Local dDatRea := STOD("")

	Default oModel := Nil

	If oModel == Nil
		cMatDes  := AllTrim(B3K->B3K_TRADES)
		dDatInc := B3K->B3K_DATINC
		dDatBlo  := B3K->B3K_DATBLO
		dDatRea  := B3K->B3K_DATREA

	Else
		cMatDes 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TRADES' ))
		dDatInc 	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
		dDatBlo  	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATBLO' )
		dDatRea  	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATREA' )
	EndIf

	If Empty(cMatDes)
		lRet := (Empty(dDatBlo) .OR. dDatInc <= dDatBlo) .AND. (Empty(dDatRea) .OR. dDatInc <= dDatRea)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB069

Funcao criada para validar Critica B069
Data de Contratação deve ser anterior ou igual a menor data existente no cadastro:
	Data Histórico ou
	Data Cancelamento ou
	Data Reativação ou
	Data da última mudança contratual.
Se tiver havido mudança contratual.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB069(oModel)
	Local lRet := .T.

	Local cMatDes := ""

	Local dDatInc := STOD("")
	Local dDatBlo := STOD("")
	Local dDatRea := STOD("")

	Default oModel := Nil

	If oModel == Nil
		cMatDes  := AllTrim(B3K->B3K_TRADES)
		dDatInc := B3K->B3K_DATINC
		dDatBlo  := B3K->B3K_DATBLO
		dDatRea  := B3K->B3K_DATREA

	Else
		cMatDes 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TRADES' ))
		dDatInc 	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
		dDatBlo  	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATBLO' )
		dDatRea  	:= oModel:GetValue( 'B3KMASTER', 'B3K_DATREA' )
	EndIf

	If Empty(cMatDes)
		lRet := dDatInc <= dDatBlo .AND. dDatInc <= dDatRea
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB070

Funcao criada para validar Critica B070
Ja existe registro ativo com o mesmo CPF, plano e empresa contratante na operadora.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB070(oModel)

	Local lRet := .T.
	Local cSitAns := ""
	Local cSql	  := ""
	Local cCodOpe := ""
	Local cCodPro := ""
	Local cForCon := ""
	Local cMatric := ""
	Local cCpf 	  := ""
	Local cCnpj   := ""
	Local cCEI 	  := ""
	Local dDatBlo := CTOD("")
	Local nCont := 0

	Default oModel := Nil

	If oModel == Nil
		cCodOpe := B3K->B3K_CODOPE
		cCodPro := B3K->B3K_CODPRO
		cMatric := B3K->B3K_MATRIC
		cCPF 	:= RetCPF(oModel)
		cCnpj 	:= B3K->B3K_CNPJCO
		cCEI 	:= B3K->B3K_CEICON
		dDatBlo := B3K->B3K_DATBLO
		cSitAns := B3K->B3K_SITANS
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		cCodPro := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODPRO' ))
		cMatric := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_MATRIC' ))
		cCPF 	:= RetCPF(oModel)
		cCnpj 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CNPJCO' ))
		cCEI 	:= AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CEICON' ))
		dDatBlo := oModel:GetValue( 'B3KMASTER', 'B3K_DATBLO' )
	EndIf

	If !Empty(cCPF) .AND. Empty(dDatBlo)
		cSql := " SELECT B3J_FORCON FROM " + RetSqlName("B3J")
		cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
		cSql += " AND B3J_CODOPE = '" + cCodOpe + "' "
		cSql += " AND B3J_CODIGO = '" + cCodPro + "' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		If !TRB1->(Eof())
			cForCon := TRB1->B3J_FORCON
		EndIf
		TRB1->(dbCloseArea())

		//'1=Individual/Familiar;2=Coletivo Empresarial;3=Coletivo por Adesao'
		If cForCon <> '1' .AND. UPPER(cSitAns) <> 'I'

			cSql := " SELECT COUNT(*) CONT FROM " + RetSqlName("B3K")
			cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
			cSql += " AND B3K_CODOPE = '" + cCodOpe + "' "
			cSql += " AND B3K_CODPRO = '" + cCodPro + "' "
			cSql += " AND B3K_CPF = '" + cCPF + "' "
			cSql += " AND B3K_MATRIC <> '" + cMatric + "' "
			cSql += " AND B3K_SITANS = 'A' "
			cSql += " AND "
			cSql += " (( B3K_CNPJCO <> '' AND B3K_CNPJCO = '" + cCnpj + "' ) "
			cSql += " OR "
			cSql += " ( B3K_CEICON <> '' AND B3K_CEICON = '" + cCEI + "' )) "
			cSql += " AND D_E_L_E_T_ = ' '"
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

			If !TRB1->(Eof())
				nCont := TRB1->CONT
			EndIf
			TRB1->(dbCloseArea())

			lRet := nCont == 0

		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB071

Funcao criada para validar Critica B071
Data de cancelamento deve ser posterior ou igual a maior data informada ou existente no cadastro:
Data Histórico ou
Data de Reativação (registro estiver inativo) ou
Data de Contratação.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB071(oModel)

	Local lValido := .F.
	Local dDatInc := STOD("")
	Local dDatBlo := STOD("")

	Default oModel := Nil

	dDatInc := B3K->B3K_DATINC
	dDatBlo := B3X->B3X_DATA

	lValido := dDatBlo >= dDatInc
	If lValido
		lValido := dDatBlo >= UltReatANS( B3K->( Recno() ) )
	EndIf

Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UltReatANS

Busca a ultima reativação que foi enviada ou acatada pela ANS

@return dReativ	Data da ultima Reativação enviada para a ANS

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function UltReatANS(nRecno)

	Local dReativ := STOD("")
	Local cDB	  := TCGetDB()
	local cDBText := "ORACLE POSTGRES"

	cSql := " SELECT "
	If !(cDB $ cDBText)
		cSql += " 	TOP 1 "
	EndIf
	cSql += " 	B3X_DATA "
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '"+ PADL(AllTrim(Str(nRecno)),10) +"' "
	cSql += "	AND B3X_OPERA = '" + SIB_REATIVA + "' "
	cSql += "	AND B3X_STATUS IN ('" + ENV_ANS + "','" + ACAT_ANS + "') "
	cSql += "	AND D_E_L_E_T_ = ' ' "
	If (cDB $ "ORACLE")
		cSql += "	AND ROWNUM = 1 "
	EndIf
	cSql += "	ORDER BY B3X_DATA||B3X_HORA DESC "
	If (cDB $ "POSTGRES")
		cSql += "	LIMIT 1 "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBREA",.F.,.T.)

	If !TRBREA->(Eof())
		dReativ := STOD(TRBREA->B3X_DATA)
	EndIf
	TRBREA->(dbCloseArea())

Return dReativ


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB072

Funcao criada para validar Critica B072
Um movimento de bloqueio só pode ser precedido de uma inclusão ou um desbloqueio e só pode anteceder um desbloqueio

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 16/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB072(oModel)

	Local lValido := .F.
	Local dDatInc := STOD("")
	Local dDatBlo := STOD("")
	Local dDatOpe := STOD("")
	Local cHora	  := ""

	Default oModel := Nil

	dDatInc := B3K->B3K_DATINC
	dDatBlo := B3X->B3X_DATA
	dDatOpe := B3X->B3X_DATOPE
	cHora   := B3X->B3X_HORA

	cMovAnterior := MvtoAnterior( B3K->( Recno() ), dDatBlo, B3X->(Recno()), dDatOpe, cHora)
	lValido :=  Empty(cMovAnterior) .OR. cMovAnterior $ SIB_REATIVA + "," + SIB_INCLUIR

Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB074

Funcao criada para validar Critica B074
Um movimento de desbloqueio só pode ser precedido de um bloqueio

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 16/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB074(oModel)
	Local lValido := .F.

	Local dDatInc := STOD("")
	Local dDatBlo := STOD("")
	Local dDatRea := STOD("")
	Local dDatOpe := STOD("")
	Local cHora	  := ""

	Default oModel := Nil

	dDatInc := B3K->B3K_DATINC
	dDatRea := B3X->B3X_DATA
	dDatBlo := B3K->B3K_DATBLO
	dDatOpe := B3X->B3X_DATOPE
	cHora   := B3X->B3X_HORA

	cMovAnterior := MvtoAnterior( B3K->( Recno() ), dDatRea, B3X->(Recno()), dDatOpe, cHora )
	If Empty(cMovAnterior)
		If !Empty(dDatBlo) .AND. dDatBlo <= dDatRea
			cMovAnterior := SIB_CANCELA
		EndIf
	EndIf
	lValido :=  cMovAnterior == SIB_CANCELA

Return lValido

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtoAnterior

Busca a ultima reativação que foi enviada ou acatada pela ANS

@return dReativ	Data da ultima Reativação enviada para a ANS

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtoAnterior(nBenef, dDatBlo, nRecno, dDatOpe)

	Local cMovAnterior	:= ""
	Local cLinhaNum		:= ""
	Local cDB			:= TCGetDB()
	local cDBText 		:= "POSTGRES"
	Default dDatOpe		:= ""

	cSql := " SELECT LINHANUM FROM "
	If (cDB $ cDBText)
		cSql += " ( SELECT ROW_NUMBER() OVER (ORDER BY B3X_DATOPE||B3X_DATA||B3X_HORA DESC) LINHANUM" + " , "
	Else
		cSql += " ( SELECT ROW_NUMBER() OVER (ORDER BY B3X_DATOPE||B3X_DATA||B3X_HORA DESC) " + '"LINHANUM"' + " , "
	EndIf
	cSql += " B3X_OPERA, B3X_DATA , B3X_DATOPE, B3X_HORA, R_E_C_N_O_  "
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE 1=1 "
	cSql += "	AND B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '"+ PADL(AllTrim(Str(nBenef)),10) +"' "
	cSql += "	AND B3X_OPERA IN ('" + SIB_REATIVA + "','" + SIB_CANCELA + "','" + SIB_INCLUIR + "') "
	cSql += "	AND B3X_DATA <= '" + DTOS(dDatBlo) + "' "
	if !Empty(dDatOpe)
		cSql += "	AND B3X_DATOPE <= '" + DTOS(dDatOpe) + "' "
	EndIf
	cSql += "	AND B3X_STATUS <> '" + CANCELADO + "' "
	cSql += "	AND D_E_L_E_T_ = ' ' "
	cSql += " ) B3X  WHERE R_E_C_N_O_ =  '" + Alltrim(Str(nRecno)) + "' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMAN",.F.,.T.)

	If !TRBMAN->(Eof())
		cLinhaNum := TRBMAN->LINHANUM
	EndIf

	TRBMAN->(dbCloseArea())

	if !Empty(cLinhaNum)
		cSql := " SELECT * FROM "
		If (cDB $ cDBText)
			cSql += " ( SELECT ROW_NUMBER() OVER (ORDER BY B3X_DATOPE || B3X_DATA || B3X_HORA DESC) LINHANUM" + " , "
		Else
			cSql += " ( SELECT ROW_NUMBER() OVER (ORDER BY B3X_DATOPE || B3X_DATA || B3X_HORA DESC) " + '"LINHANUM"' + " , "
		EndIf
		cSql += " B3X_OPERA, B3X_DATA , B3X_DATOPE, B3X_HORA, R_E_C_N_O_  "
		cSql += " FROM " + RetSqlName("B3X") + " "
		cSql += " WHERE 1=1 "
		cSql += "	AND B3X_FILIAL = '" + xFilial('B3X') + "' "
		cSql += "	AND B3X_BENEF = '"+ PADL(AllTrim(Str(nBenef)),10) +"' "
		cSql += "	AND B3X_OPERA IN ('" + SIB_REATIVA + "','" + SIB_CANCELA + "','" + SIB_INCLUIR + "') "
		cSql += "	AND B3X_DATA <= '" + DTOS(dDatBlo) + "' "
		if !Empty(dDatOpe)
			cSql += "	AND B3X_DATOPE <= '" + DTOS(dDatOpe) + "' "
		EndIf
		cSql += "	AND B3X_STATUS <> '" + CANCELADO + "' "
		cSql += "	AND D_E_L_E_T_ = ' ' "
		cSql += " )  B3X WHERE LINHANUM =  '" + Alltrim(Str(cLinhaNum + 1)) + "' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMAN",.F.,.T.)

		If !TRBMAN->(Eof())
			cMovAnterior := TRBMAN->B3X_OPERA
		EndIf

		TRBMAN->(dbCloseArea())

	EndIf

Return cMovAnterior

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB075

Funcao criada para validar Critica B075
Data de Contratação não pode ser posterior a 01/01/1999,
pois o beneficiario é titular e o plano existente é SCPA e
'Individual ou Familiar'.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB075(oModel)

	Local lRet     := .T.
	Local cCodPro  := ""
	Local cCodOpe  := ""
	Local cSql     := ""
	Local cForCon  := ""
	Local cTipoDep := ""
	Local cSCPA    := ""
	Local dDatInc  := ""
	Local cOpeSib  := ""

	Default oModel := Nil

	If oModel == Nil
		cCodPro  := B3K->B3K_CODPRO
		cCodOpe  := B3K->B3K_CODOPE
		dDatInc  := B3K->B3K_DATINC
		cTipoDep := B3K->B3K_TIPDEP
		cSCPA    := B3K->B3K_SCPA
		cOpeSib  := B3K->B3K_OPESIB
	Else
		cCodPro  := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODPRO' ))
		cCodOpe  := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODOPE' ))
		dDatInc  := oModel:GetValue( 'B3KMASTER', 'B3K_DATINC' )
		cTipoDep := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_TIPDEP' ))
		cSCPA    := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_SCPA' ))
		cOpeSib  := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_OPESIB' ))
	EndIf

	If dDatInc > CTOD("19990101")

		cSql := " SELECT B3J_FORCON FROM " + RetSqlName("B3J")
		cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
		cSql += " AND B3J_CODOPE = '" + cCodOpe + "' "
		cSql += " AND B3J_CODIGO = '" + cCodPro + "' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		If !TRB1->(Eof())
			cForCon := TRB1->B3J_FORCON
		EndIf
		TRB1->(dbCloseArea())

		//'1=Individual/Familiar;2=Coletivo Empresarial;3=Coletivo por Adesao'
		lRet := cTipoDep != '01' .OR. Empty(cSCPA) .OR. cForCon != '1'
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB076

Funcao criada para validar Critica B076
CCO invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB076(oModel)
	Local lRet := .T.

	Local cCCO := ""

	Default oModel := Nil

	If oModel == Nil
		cCCO  := AllTrim(B3K->B3K_CODCCO)
	Else
		cCCO := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CODCCO' ))
	EndIf

	lRet := !Empty(cCCO) .AND. Len(cCCO) == 12

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB077

Funcao criada para validar Critica B077
Código de motivo de cancelamento informado não permite retificação.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB077(oModel)
	Local lRet := .T.

	Local cMotBlo := ""

	Default oModel := Nil

	B4W->(DbSetOrder(1))

	cMatric  := AllTrim(B3K->B3K_MATRIC)
	dMvto	 := B3X->B3X_DATA
	cHoraMov := B3X->B3X_HORA

	If B4W->(MsSeek(xFilial("B4W")+PADR(cMatric,tamSX3("B4W_MATRIC")[1])+DTOS(dMvto)+"0"+cHoraMov ) )
		cMotBlo := Alltrim(B4W->B4W_MOTBLO)
	EndIf
	lRet := Empty(cMotBlo) .OR. cMotBlo $ "41,42,43"

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB078

Funcao criada para validar Critica B078
DN invalido.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB078(oModel)
	Local lRet := .T.

	Local cDN := ""

	Default oModel := Nil

	If oModel == Nil
		cDN  := AllTrim(B3K->B3K_DN)
	Else
		cDN := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_DN' ))
	EndIf

	lRet := Len(cDN) == 0 .OR. Len(cDN) == 11


Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB079

Funcao criada para validar Critica B079
Código de Indicação de Residência (Nacional/Exterior) deve ser informado

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB079(oModel)
	Local lRet := .T.


Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB080

Funcao mantida por compatibilidade. Usar esse nome para uma nova regra a ser criada.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB080(oModel)
	lRet := .T.
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB081

Código do municipio IBGE está menor que 6.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author jose.paulo
@since 19/12/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function SIBVLDB081(oModel)
	Local lRet := .T.
	Local cCodIBGE := ""

	Default oModel := Nil

	If oModel == Nil
		cCodIBGE := B3K->B3K_MUNICI
	Else
		cCodIBGE := oModel:GetValue( 'B3KMASTER', 'B3K_MUNICI' )
	EndIf

	cCodIBGE := AllTrim(cCodIBGE)

	lRet  := LEN(cCodIBGE) > 5 .Or. LEN(cCodIBGE) == 0

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB088

Cep do beneficiário deve possuir oito caracteres.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author lima.everton
@since 05/12/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function SIBVLDB088(oModel)
	Local lRet := .T.
	Local cCepusr := ""

	Default oModel := Nil

	If oModel == Nil
		cCepusr := B3K->B3K_CEPUSR
	Else
		cCepusr := oModel:GetValue( 'B3KMASTER', 'B3K_CEPUSR' )
	EndIf

	lRet  := LEN(Alltrim(cCepusr)) == 8

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB090

Número CAEPF inválido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author lima.everton
@since 05/12/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function SIBVLDB090(oModel)
	Local lRet := .T.
	Local cCaepf := ""

	Default oModel := Nil

	If oModel == Nil
		cCaepf := B3K->B3K_CAEPF
	Else
		cCaepf := oModel:GetValue( 'B3KMASTER', 'B3K_CAEPF' )
	EndIf

	lRet  := Len(Alltrim(cCaepf)) == 0 .OR. (Len(Alltrim(cCaepf)) == 14 .AND. validaCAEPF(cCaepf))

Return lRet

Function validaCAEPF(cCaepf)
	Local cDigCaepf := ""
	Local nDig1		:= calcDigito(SubStr(cCaepf,1,12))
	Local nDig2		:= calcDigito(SubStr(cCaepf,1,12) + AllTrim(Str(nDig1)) )
	Local nDigCaepf	:= nDig1 * 10 + nDig2 + 12

	If (nDigCaepf > 99)
		nDigCaepf := nDigCaepf - 100
	EndIf

	cDigCaepf := AllTrim(Str(nDigCaepf))

	If (Len(cDigCaepf) == 1)
		cDigCaepf := "0" + cDigCaepf
	EndIf
Return cCaepf == (SubStr(cCaepf,1,12) + cDigCaepf)

Function calcDigito(cStr)
	Local aPeso := { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 }
	Local nSoma := 0
	Local nIndice := Len(cStr)
	Local nDigito := 0

	While nIndice > 0
		nDigito := val(SubStr(cStr,nIndice,1))
		nSoma += nDigito * aPeso[len(aPeso) - Len(cStr) + nIndice]
		nIndice--
	EndDo
	nSoma := 11 - nSoma % 11

Return IIf(nSoma > 9 , 0 , nSoma)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE001

O nome do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE001(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_NOMBEN) == AllTrim(TRBBEN->B3W_NOMBEN)
		lValIgual := igualHisMov("B3K_NOMBEN",AllTrim(TRBBEN->B3W_NOMBEN))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE002

A data de nascimento não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE002(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_DATNAS) == AllTrim(TRBBEN->B3W_DATNAS)
		lValIgual := igualHisMov("B3K_DATNAS",AllTrim(TRBBEN->B3W_DATNAS))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE003

O código do sexo do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE003(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_SEXO) == AllTrim(TRBBEN->B3W_SEXO)
		lValIgual := igualHisMov("B3K_SEXO",AllTrim(TRBBEN->B3W_SEXO))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE004

O CPF do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE004(oModel)
	Local lValIgual := .T.
	Local lNaoValid := .F.

	If Empty(TRBBEN->B3W_CPF) .And. Empty(TRBBEN->B3K_CPF) //Se todos os dados estão em branco, não devo criticar
		lNaoValid:=.T.
	EndIf

	If !lNaoValid .And. !AllTrim(TRBBEN->B3W_CPF) $ AllTrim(TRBBEN->B3K_CPF) + "," + AllTrim(TRBBEN->B3K_CPFMAE) + "," + AllTrim(TRBBEN->B3K_CPFPRE)
		lValIgual := igualHisMov("B3K_CPF", AllTrim(TRBBEN->B3W_CPF) )
		If !lValIgual
			lValIgual := igualHisMov("B3K_CPFMAE", AllTrim(TRBBEN->B3W_CPF) )
			If !lValIgual
				lValIgual := igualHisMov("B3K_CPFPRE", AllTrim(TRBBEN->B3W_CPF) )
			EndIf
		EndIf
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE005

O PIS/PASEP do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE005(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_PISPAS) == AllTrim(TRBBEN->B3W_PISPAS)
		lValIgual := igualHisMov("B3K_PISPAS",AllTrim(TRBBEN->B3W_PISPAS))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE006

O CNS do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE006(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_CNS) == AllTrim(TRBBEN->B3W_CNS)
		lValIgual := igualHisMov("B3K_CNS",AllTrim(TRBBEN->B3W_CNS))
	EndIf

Return lValIgual
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE007

O Nome da Mãe do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE007(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_NOMMAE) == AllTrim(TRBBEN->B3W_NOMMAE)
		lValIgual := igualHisMov("B3K_NOMMAE",AllTrim(TRBBEN->B3W_NOMMAE))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE008

O Número da Declaração Nascido Vivo do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE008(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_DN) == AllTrim(TRBBEN->B3W_DN)
		lValIgual := igualHisMov("B3K_DN",AllTrim(TRBBEN->B3W_DN))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE009

O Logradouro do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE009()
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_ENDERE) == AllTrim(TRBBEN->B3W_ENDERE)
		lValIgual := igualHisMov("B3K_ENDERE",AllTrim(TRBBEN->B3W_ENDERE))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} igualHisMov

Diz se o valor no espelho da ANS é igual ao ultimo valor do campo antes da data base informada

@return lRet .T. pendente envio de inclusao

@author everton.mateus
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function igualHisMov(cCampo,cValorAns,cOpe)
	Local lValIgual		:= .F.
	Local cValor		:= ""
	Default cOpe := SIB_RETIFIC

	If getHisMov(cCampo,cOpe,@cValor)
		lValIgual := AllTrim(cValor) == cValorAns
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getHisMov

Retorna o ultimo valor do campo antes da data base

@return cValor valor encontrado no histórico de movimentação

@author everton.mateus
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function getHisMov(cCampo,cOpe,cValor)
	Local lB3X_VLRANT := B3X->(FieldPos("B3X_VLRANT")) > 0
	Local lB3X_VLRNOV := B3X->(FieldPos("B3X_VLRNOV")) > 0
	Local lTemHist := .F.
	Default cOpe := SIB_RETIFIC
	Default cValor 		:= ""

	If lB3X_VLRANT .And. lB3X_VLRNOV
		lTemHist := qryHisMov(cCampo,cOpe)
		If lTemHist
			cValor := AllTrim(TRBHIS->B3X_VLRANT)
		EndIf
	EndIf
	TRBHIS->(DbCloseArea())

Return lTemHist

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryHisMov

Executa a query do historico de movimentação na comparação com o espelho da ANS

@return lRet .T. diz se encontrou resultado

@author everton.mateus
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function qryHisMov(cCampo,cOpera)

	Local cDtReferen 	:= TRBBEN->DATA_BASE
	Local nRecno 		:= TRBBEN->R_E_C_N_O_
	Default cOpera := SIB_RETIFIC
	cSql := " SELECT "
	If !AllTrim( TCGetDB() ) == "ORACLE"
		cSql += " 	TOP 1 "
	EndIf
	cSql += " 	B3X_VLRANT "
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '"+ PADL(AllTrim(Str(nRecno)),10) +"' "
	cSql += "	AND B3X_OPERA = '" + cOpera + "' "
	If cOpera == SIB_RETIFIC
		cSql += "	AND B3X_CAMPO = '" + cCampo + "' "
	EndIf
	cSql += "	AND B3X_DATA > '" + cDtReferen + "'"
	cSql += "	AND B3X_STATUS <> '" + CANCELADO + "' "
	cSql += "	AND D_E_L_E_T_ = ' ' "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cSql += "	AND ROWNUM = 1 "
	EndIf
	cSql += "	ORDER BY B3X_DATA||B3X_HORA ASC "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBHIS",.F.,.T.)

Return  !TRBHIS->(Eof())


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE010

O Número do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE010(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_NR_END) == AllTrim(TRBBEN->B3W_NR_END)
		lValIgual := igualHisMov("B3K_NR_END",AllTrim(TRBBEN->B3W_NR_END))
	EndIf

Return lValIgual
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE011

O Complemento do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE011(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_COMEND) == AllTrim(TRBBEN->B3W_COMEND)
		lValIgual := igualHisMov("B3K_COMEND",AllTrim(TRBBEN->B3W_COMEND))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE012

O Bairro do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE012(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_BAIRRO) == AllTrim(TRBBEN->B3W_BAIRRO)
		lValIgual := igualHisMov("B3K_BAIRRO",AllTrim(TRBBEN->B3W_BAIRRO))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE013

O Código Município Residência do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE013(oModel)

	Local lValIgual := SubStr(AllTrim(TRBBEN->B3K_CODMUN),1,6) == AllTrim(TRBBEN->B3W_CODMUN)
	Local cVlrHist := ""

	If !lValIgual
		If getHisMov("B3K_CODMUN",,@cVlrHist)
			lValIgual := SubStr(AllTrim(cVlrHist),1,6) == AllTrim(TRBBEN->B3W_CODMUN)
		EndIf
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE014

O CEP do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE014(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_CEPUSR) == AllTrim(TRBBEN->B3W_CEPUSR)
		lValIgual := igualHisMov("B3K_CEPUSR",AllTrim(TRBBEN->B3W_CEPUSR))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE015

O Tipo Endereço do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE015(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_TIPEND) == AllTrim(TRBBEN->B3W_TIPEND)
		lValIgual := igualHisMov("B3K_TIPEND",AllTrim(TRBBEN->B3W_TIPEND))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE016

O código Reside Exterior do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE016(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_RESEXT) == AllTrim(TRBBEN->B3W_RESEXT)
		lValIgual := igualHisMov("B3K_RESEXT",AllTrim(TRBBEN->B3W_RESEXT))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE017

O Código do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE017(oModel)

	Local lRet := .T.
	Default oModel := Nil

	If GetNewPar("MV_PLMATAN",.F.)
		If Empty(TRBBEN->B3K_MATANT)
			lRet := AllTrim(TRBBEN->B3K_MATRIC) == AllTrim(TRBBEN->B3W_MATRIC)
		Else
			lRet := AllTrim(TRBBEN->B3K_MATANT) == AllTrim(TRBBEN->B3W_MATRIC)
		EndIf
	Else
		lRet := AllTrim(TRBBEN->B3K_MATRIC) == AllTrim(TRBBEN->B3W_MATRIC)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE018

A Relação Dependência do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE018(oModel)

	Local lValIgual := AllTrim(TRBBEN->B3K_TIPDEP) == PadL(AllTrim(TRBBEN->B3W_TIPDEP),2,"0")

	If !lValIgual
		lValIgual := igualHisMov("B3K_TIPDEP",PadL(AllTrim(TRBBEN->B3W_TIPDEP),2,"0"))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE019

O Código Beneficiario Titular do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE019(oModel)
	Local lRet := .T.
	Default oModel := Nil

	lRet := .T.//AllTrim(TRBBEN->B3K_CODTIT) == AllTrim(TRBBEN->B3W_CODTIT)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE020

A Data Contratação do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE020(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_DATINC) == AllTrim(TRBBEN->B3W_DATINC) .And. !SIBVLMAT()
		lValIgual := igualHisMov("B3K_DATINC",AllTrim(TRBBEN->B3W_DATINC))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE021

A Data Bloqueio do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE021(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_DATBLO) == AllTrim(TRBBEN->B3W_DATBLO)
		If AllTrim(TRBBEN->B3W_SITANS) == "A"
			cOpe := SIB_CANCELA
		Else
			cOpe := SIB_REATIVA
		EndIf
		lValIgual := igualHisMov("B3K_SITANS",AllTrim(TRBBEN->B3W_SITANS),cOpe)
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE022

Número de Registro do Plano na ANS (SUSEP) do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE022(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_SUSEP) == AllTrim(TRBBEN->B3W_SUSEP)
		lValIgual := igualHisMov("B3K_SUSEP",AllTrim(TRBBEN->B3W_SUSEP))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE023

O Código do Cadastro do Plano na ANS (SCPA) do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE023(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_SCPA) == AllTrim(TRBBEN->B3W_SCPA)
		lValIgual := igualHisMov("B3K_SCPA",AllTrim(TRBBEN->B3W_SCPA))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE024

O Plano Origem (portabilidade) do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE024(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_PLAORI) == AllTrim(TRBBEN->B3W_PLAORI)
		lValIgual := igualHisMov("B3K_PLAORI",AllTrim(TRBBEN->B3W_PLAORI))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE025

Cobertura Parcial Temporaria do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE025(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_COBPAR) == AllTrim(TRBBEN->B3W_COBPAR)
		lValIgual := igualHisMov("B3K_COBPAR",AllTrim(TRBBEN->B3W_COBPAR))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE026

Itens CPT do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE026(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_ITEEXC) == AllTrim(TRBBEN->B3W_ITEEXC)
		lValIgual := igualHisMov("B3K_ITEEXC",AllTrim(TRBBEN->B3W_ITEEXC))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE027

O CNPJ Contratante do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE027(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_CNPJCO) == AllTrim(TRBBEN->B3W_CNPJCO)
		lValIgual := igualHisMov("B3K_CNPJCO",AllTrim(TRBBEN->B3W_CNPJCO))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE028

O CEI Contratante do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE028(oModel)

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_CEICON) == AllTrim(TRBBEN->B3W_CEICON)
		lValIgual := igualHisMov("B3K_CEICON",AllTrim(TRBBEN->B3W_CEICON))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE029

O beneficiario esta cadastrado na Base da Operadora, mas não na ANS

@return lRetorno	.F. - Sempre que chamar esta validação, o beneficiario sera criticado

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE029(oModel)
	Local lRet := .F.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE030

O beneficiario esta cadastrado na ANS, mas não na Base da Operadora

@return lRetorno	.F. - Sempre que chamar esta validação, o beneficiario sera criticado

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE030(oModel)
	Local lRet := .F.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCPF

Retorna o CPF do beneficiario

@return cCPF

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------

Static Function RetCPF(oModel)
	Local cCpf := ""

	If oModel == Nil
		cCPF := AllTrim(B3K->B3K_CPF)
		If Empty(cCPF)
			cCPF := AllTrim(B3K->B3K_CPFMAE)
			If Empty(cCPF)
				cCPF := AllTrim(B3K->B3K_CPFPRE)
			EndIf
		EndIf
	Else
		cCPF := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CPF' ))
		If Empty(cCPF)
			cCPF := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CPFMAE' ))
			If Empty(cCPF)
				cCPF := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_CPFPRE' ))
			EndIf
		EndIf
	EndIf

Return cCpf

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE031

Situação da Central não condiz com a situação da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE031()

	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_SITANS) == AllTrim(TRBBEN->B3W_SITANS)
		If AllTrim(TRBBEN->B3W_SITANS) == "A"
			cOpe := SIB_CANCELA
		Else
			cOpe := SIB_REATIVA
		EndIf
		lValIgual := igualHisMov("B3K_SITANS",AllTrim(TRBBEN->B3W_SITANS),cOpe)
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE032

A Data Reativação do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE032(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_DATREA) == AllTrim(TRBBEN->B3W_DATREA)
		If AllTrim(TRBBEN->B3W_SITANS) == "A"
			cOpe := SIB_CANCELA
		Else
			cOpe := SIB_REATIVA
		EndIf
		lValIgual := igualHisMov("B3K_SITANS",AllTrim(TRBBEN->B3W_SITANS),cOpe)
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE033

O Motivo Bloqueio do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/

//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE033(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_MOTBLO) == AllTrim(TRBBEN->B3W_MOTBLO)
		If AllTrim(TRBBEN->B3W_SITANS) == "A"
			cOpe := SIB_CANCELA
		Else
			cOpe := SIB_REATIVA
		EndIf
		lValIgual := igualHisMov("B3K_SITANS",AllTrim(TRBBEN->B3W_SITANS),cOpe)
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDE034

O CAEPF do beneficiario não condiz com o cadastro da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 30/10/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDE034(oModel)
	Local lValIgual := .T.

	If !AllTrim(TRBBEN->B3K_CAEPF) == AllTrim(TRBBEN->B3W_CAEPF)
		lValIgual := igualHisMov("B3K_CAEPF",AllTrim(TRBBEN->B3W_CAEPF))
	EndIf

Return lValIgual

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLEXVLDCEN

Função criada para rodar as validações pelo teste automatizado

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlExVldCen(cMacro,oModel)
	Local lRet := .F.
	Local nI := 0
	Default cMacro := ""
	Default oModel := Nil

	If !Empty(cMacro)
		lRet := &cMacro.(oModel,nI)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESubSemItem

Funcao criada para validar os subitens (filho) sem seus respectivos itens (pai) E033

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 20/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ESubSemItem()

	Local cSql			:= ""
	Local cItem			:= AllTrim(B3L->B3L_CLAINT)
	Local lRetorno		:= .T.

	cItem	:= AllTrim(SubStr(cItem,1,Len(cItem)-1))

	If Len(cItem) > 1

		cSql := " SELECT B3L_CLAINT "
		cSql += " FROM " + RetSqlName("B3L") + " "
		cSql += " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
		cSql += " AND B3L_CODOPE = '" + B3L->B3L_CODOPE + "' "
		cSql += " AND B3L_CODOBR = '" + B3L->B3L_CDOBRI + "' "
		cSql += " AND B3L_ANOCMP = '" + B3L->B3L_ANOCMP + "' "
		cSql += " AND B3L_CDCOMP = '" + B3L->B3L_CDCOMP + "' "
		cSql += " AND B3L_EVEDES = B3L_MATRIC "
		cSql += " AND B3L_CDTPTB = '' "
		cSql += " AND B3L_CODEVE = '' "
		cSql += " AND B3L_CLAAMB = B3L_CLAINT "
		cSql += " AND B3L_CLAINT = '" + cItem + "' "
		cSql += " AND B3L_UF = '" + B3L->B3L_UF + "' "
		cSql += " AND B3L_TRIREC = '" + B3L->B3L_TRIREC + "' "
		cSql += " AND B3L_TRIOCO = '" + B3L->B3L_TRIOCO + "' "
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

		If TRB1->(Eof())//Se nao encontrou o registro pai critica
			lRetorno := .F.
		EndIf
		TRB1->(dbCloseArea())

	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EParSemInt

Funcao criada para validar se algum evento com classificacao de parto nao possui vinculo com internacao

@return lRetorno .F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 20/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function EParSemInt()

	Local cClaPart := ""
	Local lRetorno := .T.
	Local aClaPart := {"E131","E132","E133"}
	Local nClaPart := 0

	cClaPart := AllTrim(B3L->B3L_CLAAMB)
	nClaPart := aScan(aClaPart,{ |x| x == cClaPart})
	If nClaPart > 0 .And. Empty(B3L->B3L_EVDEIN)
		lRetorno := .F.
	EndIf

	cClaPart := AllTrim(B3L->B3L_CLAINT)
	nClaPart := aScan(aClaPart,{ |x| x == cClaPart})
	If nClaPart > 0 .And. Empty(B3L->B3L_EVDEIN)
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIPUFInval

Funcao criada para validar se a UF da despesa e valida - E035

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIPUFInval()

	Local lRetorno	:= .T.

	If !(B3L->B3L_UF $ "NC,AC,AL,AM,AP,BA,CE,DF,ES,GO,MA,MG,MS,MT,PA,PB,PE,PI,PR,RJ,RN,RO,RR,RS,SC,SE,SP,TO")
	lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIPTriInva

Funcao criada para validar se o trimestre de ocorrencia nao e maior que o de reconhecimento - E036

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIPTriInva()

	Local lRetorno		:= .T.

	If B3L->B3L_TRIOCO > B3L->B3L_TRIREC
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EItemSVin

Funcao criada para validar se a despesa possui vinculo com internacao - E037

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function EItemSVin()

	Local lRetorno		:= .T.
	/*Local cClaInt		:= AllTrim(Left(B3L->B3L_CLAINT,1,1))

	If cClaInt == 'E' .And. ( Empty(B3L->B3L_GRPINT) .OR. Empty(B3L->B3L_REGINT) .OR. Empty(B3L->B3L_EVDEIN) )
		lRetorno := .F.
	EndIf*/

Return lRetorno

Static Function CriaArea(cConsulta,cNomeArea)

	Local lRetorno		:= .F.
	Default cConsulta	:= ""
	Default cNomeArea	:= ""

	If !Empty(cConsulta) .And. !Empty(cNomeArea)

		cConsulta := ChangeQuery(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cNomeArea,.F.,.T.)

		If !(cNomeArea)->(Eof())
			lRetorno := .T.
		EndIf

	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteCritica

Funcao criada para verificar se a critica ja existe

@author timoteo.bega
@since 08/03/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteCritica(cCodOpe,cCdObri,cAno,cCdComp,cOriCri,cChvOri,cCodCri,cTipo,cIdeOri,cDesOri)

	Local lRetorno	:= .F.
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Default cCodOpe	:= ""
	Default cCdObri	:= ""
	Default cAno	:= ""
	Default cCdComp	:= ""
	Default cOriCri	:= ""
	Default cChvOri	:= ""
	Default cCodCri	:= ""
	Default cTipo	:= ""
	Default cIdeOri	:= ""
	Default cDesOri	:= ""

	cSql := "SELECT R_E_C_N_O_  FROM " + RetSqlName("B3F") + " WHERE B3F_FILIAL='" + xFilial("B3F") + "' AND B3F_CODOPE='" + cCodOpe + "' AND B3F_CDOBRI='" + cCdObri + "' AND B3F_ANO='" + cAno + "' AND B3F_CDCOMP='" + cCdComp + "' "
	cSql += "AND B3F_ORICRI='" + cOriCri + "' AND B3F_CHVORI='" + cChvOri + "' AND B3F_CODCRI='" + cCodCri + "' AND B3F_TIPO='" + cTipo + "' AND B3F_IDEORI='" + cIdeOri + "' AND B3F_DESORI='" + cDesOri + "' AND D_E_L_E_T_=' ' "
	If CriaArea(cSql,cAliTrb)
		lRetorno := .T.
	EndIf

	(cAliTrb)->(dbCloseArea())

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TipoSIP

Funcao criada para verificar se a obrigacao e do tipo SIP

@author timoteo.bega
@since 08/03/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function TipoSIP(cCodOpe,cCdObri,cAno,cCdComp)
	Local lRetorno	:= .F.
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Default cCodOpe	:= ""
	Default cCdObri	:= ""
	Default cAno	:= ""
	Default cCdComp	:= ""

	cSql := "SELECT B3D_TIPOBR FROM " + RetSqlName("B3D") + " WHERE B3D_FILIAL='" + xFilial("B3D") + "' AND B3D_CODOPE='" + cCodOpe + "' AND B3D_CDOBRI='" + cCdObri + "' AND B3D_ANO='" + cAno + "' AND B3D_CODIGO='" + cCdComp + "' AND D_E_L_E_T_=' '"
	If CriaArea(cSql,cAliTrb)
		lRetorno := (cAliTrb)->B3D_TIPOBR == "1"
	EndIf

	(cAliTrb)->(dbCloseArea())

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB093

O Plano Origem (portabilidade) do beneficiario quando preenchido deve ter números de 0 até 9

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author jose.paulo
@since 31/12/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB093(oModel)

	Local lRet     := .T.
	Local cPlaOri  := ""

	Default oModel := Nil

	If oModel == Nil
		cPlaOri  := B3K->B3K_PLAORI
	Else
		cPlaOri  := AllTrim(oModel:GetValue( 'B3KMASTER', 'B3K_PLAORI' ))
	EndIf

	If !Empty(cPlaOri) .And. (Len(alltrim(cPlaOri))<>9 .Or. !isnumeric(Alltrim(cPlaOri)))
		lRet:=.F.
	Endif

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLMAT

@author jose.paulo
@since 02/08/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLMAT()
	Local lRetorno	:= .F.
	Local cSql		:= ""

	cSql := " SELECT B3K_DATINC FROM " + RetSqlName("B3K") + " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' AND B3K_CODOPE = '" + TRBBEN->B3K_CODOPE + "' "
	cSql += " AND B3K_MATRIC = '" + TRBBEN->B3K_MATRIC + "' "
	cSql += " AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3K",.F.,.T.)

	While TRBB3K->(!Eof())
		IF TRBB3K->B3K_DATINC == TRBBEN->B3K_DATINC
			lRetorno:= .T.
		EndIf
		TRBB3K->(dbSkip())
	EndDo

	TRBB3K->(DBCloseArea())

Return lRetorno
