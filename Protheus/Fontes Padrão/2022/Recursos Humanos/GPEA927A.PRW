#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA927.CH"

//Integração com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )  
Static aSocialNiv	:= If( cPaisLoc == 'BRA' , If(Findfunction("fGM17Nivel"),fGM17Nivel("GPEA927A"), {.F.,""}),{.F.,""})
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )


/*/{Protheus.doc} GPEA927A
Cadastro das Prorrogações do Contrato de Trabalho, Funcionários Temporários 

@author Claudinei R. Soares
@since 06/09/2017
@version 1.0
/*/
/*/
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|                      ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|Programador | Data     | ISSUE	      |          Motivo da Alteracao                      	  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±|Claudinei S.|11/09/2017|DRHESOCP-729	  |Inclusão do fonte a ser chamado nas ações relacionadas.|±±
±±|            |          |               |do cadastro de funcionários temporários (GPEA927).     |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GPEA927A(nOpc, lIntegra)

Local oMBrowse
Local cAliasSGW	:= ""
Local oModel 
Local oMdlActv	:= FwModelActive()
Local oMdlSRA

Private cCpf	:= ""
Private cCateg	:= ""

Default nOpc		:= 4
Default lIntegra	:= .T.

lIntTAF := lIntegra

oModel			:= FWLoadModel( "GPEA927A")
oMdlSRA			:= oModel:GetModel("SRAMASTER")
oModel:SetOperation( nOpc )
oModel:Activate()
oMdlActv	:= FwModelActive()
oMdlSRA:SetValue("RA_FILIAL", oMdlActv:GetModel('SRAMASTER'):GetValue('RA_FILIAL'))
oMdlSRA:SetValue("RA_MAT", oMdlActv:GetModel('SRAMASTER'):GetValue('RA_MAT'))

cAliasSGW	:= "SGW"
dbSelectArea(cAliasSGW)
(cAliasSGW)->(dbSetOrder(1))
FWExecView(OemToAnsi(STR0022),'GPEA927A', nOpc, , { || .T. } ) //"Cadastro de Funcionários Temporários Prorrogação"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MenuDef     ³ Autor ³ Claudinei Soares     ³ Data ³ 05/09/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA927A'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA927A'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA927A'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ModelDef    ³ Autor ³ Claudinei Soares     ³ Data ³ 05/09/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Modelo de dados e Regras de Preenchimento para a Prorrogação  ³±±
±±³          ³de Contrato dos Funcionarios Temporarios (SGW)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ModelDef()

Local oMdlSGW
Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|"}
Local oStruSRA 	  	:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruSGW 	  	:= FWFormStruct(1, 'SGW', /*bAvalCampo*/,/*lViewUsado*/)
Local bCommit		:= {|oMdlSGW| f927AComm(oMdlSGW)}

oMdlSGW := MPFormModel():New('GPEA927A', /*bPreValid */,/* bPosValid*/, bCommit, /*bCancel*/)
oMdlSGW:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)
oMdlSGW:AddGrid( 'SGWDETAIL', 'SRAMASTER', oStruSGW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oMdlSGW:SetRelation('SGWDETAIL', {{'GW_FILIAL', 'xFilial("SGW")'}, {'GW_MAT' , 'RA_MAT'}}, SGW->(IndexKey(1)))
oMdlSGW:GetModel('SGWDETAIL'):SetUniqueLine({'GW_DATAPR'})

//Permite grid sem dados
oMdlSGW:GetModel('SGWDETAIL'):SetOptional(.T.)

oMdlSGW:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlSGW:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Modelo de Dados
oMdlSGW:SetDescription(OemToAnsi(STR0013))  //"Cadastro de Funcionarios Temporarios"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlSGW:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0003)) // "Funcionários"
oMdlSGW:GetModel('SGWDETAIL'):SetDescription(OemToAnsi(STR0022)) // "Prorrogação"

oMdlSGW:SetPrimaryKey({})

Return oMdlSGW

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ModelDef    ³ Autor ³ Claudinei Soares     ³ Data ³ 05/09/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Visualizador de dados do Cadastro de Funcionários Temporários³±±
±±³          ³ (SGW)                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ViewDef()

Local oView
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|"}
Local oModel		:= FWLoadModel('GPEA927A')
Local oStruSRA		:= FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruSGW		:= FWFormStruct(2, 'SGW')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_SGW', oStruSGW, 'SGWDETAIL')

oStruSGW:RemoveField("GW_MAT")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 12)
oView:CreateHorizontalBox('INFERIOR', 88)


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_SGW', 'INFERIOR')


// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0003)) // "Funcionário"
oView:EnableTitleView('VIEW_SGW', OemToAnsi(STR0022)) // "Prorrogação"

cCPF	:= SRA->RA_CIC
cCateg	:= SRA->RA_CATEFD

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Gp927APosVal ³ Autor ³ Claudinei Soares      ³ Data ³ 05/09/17³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Pos-validacao do Cadastro de Prorrogação de contrato dos     ³±±
±±³          ³ Funcionarios Temporarios                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp927APosVal( oMdl )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdl = Objeto do modelo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Gp927APosVal( oMdl )

Local aArea      := GetArea()
Local oGridSGW   := oMdl:GetModel('SGWDETAIL') 
Local nOperation := oMdl:GetOperation()

Local lRetorno   := .T.


RestArea(aArea)

Return lRetorno  
           
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ f926AComm     ³ Autor ³ Claudinei Soares ³ Data ³05/09/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para integracao TAF evento S-2200                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA927A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function f927AComm(oModel)

Local aArea 		:= GetArea()
Local lRet			:= .T.
Local cStatus		:= " "
Local cStat1		:= " "
Local cMsg			:= ""
Local cFilEnv		:= ""
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local aTpAlt		:= {}

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local cVersEnvio    := ""
Local lIntegra 		:= .T.

lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio ), .T.)

If lMiddleware .And. !ChkFile("RJE")
	MsgAlert(OemToAnsi(STR0027)) //"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	lRet := .F.
	Return
EndIf	

If !lMiddleware
	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
Endif	

If (lIntTAF .Or. lMiddleware ) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg))
	RegToMemory("SRA")
	If Empty(SRA->RA_CODUNIC)
		MsgAlert(OemToAnsi(STR0017)) //Funcionario sem codigo unico gerado. Acessar o Cad. Funcionario ou Realizar Carga Inicial
		lRet := .F.
	Else	
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		
		aTpAlt	:= {.F.,.F.,.F.} 
		cCPFCun	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
		If !lMiddleware
			cStatus := TAFGetStat( "S-2200", cCPFCun, cEmpAnt, cFilEnv )
			cStat1 	:= TAFGetStat( "S-2100", cCPFCun, cEmpAnt, cFilEnv )
		Else
			cStat1	:= "-1"
			cStatus := "-1"
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
			cStatus 	:= "-1"			
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus )
		Endif	
		
		If cStatus	== "2" .or. cStat1 == "2" // em transito
			MsgAlert(OemToAnsi(STR0018)) //Registro em transito
			lRet := .F.
		Else
			fStatusTAF(@aTpAlt,cStatus,cStat1)
			If aTpAlt[3] 
				lRet:=  fInt2206("SRA",/*lAltCad*/,3,"S2206",cFilEnv,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,oModel,cVersEnvio)
				If lRet .And. FindFunction("fEFDMsg")
					fEFDMsg()
				EndIf
			Endif
		Endif
	Endif
Endif	

If lRet
	FWFormCommit(oModel)
Endif

RestArea(aArea)
Return( lRet ) 
