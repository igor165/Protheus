#INCLUDE "Protheus.ch"
#INCLUDE "RSPM001.CH"
Static __cEmpAnt
Static __cFilAnt
Static lRspAltLeg	:= ExistBlock("RSPALTLEG")
Static leSocGPE		:= .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPM001  ³ Autor ³ Fernando Joly         ³ Data ³ 20.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AdmissÆo de Funcionarios atrav‚s do Curr¡culo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPM001                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ REQ. ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.  |31/03/14|315701|Ajuste na integracao SIGAORG com modulos  ³±±
±±³            |        |      |SIGACSA, SIGATRM, SIGARSP, SIGAGPE.       ³±±
±±³Flavio Corre|18/12/14|TRAVYV|Indica se candidato pode ser admitido caso³±±
±±³            |        |      |seja reprovado em alguma etapa do processo³±±
±±³            |        |      |criado parametro MV_RSPREP para tratar isso³±±
±±³Renan Borges|15/10/15|TTPIDV|Ajuste admitir um candidato carregando o  ³±±
±±³            |        |      |departamento e o posto corretamente, quan-³±±
±±³            |        |      |do possuir controle de postos ativado.    ³±±
±±³Oswaldo L.  |29-03-17|RHRH001-502| Alterar sistema para respeitar a filial    ³±±
±±³            |        |           |selecionada pelo usuário em tela,idependente³±±
±±³            |        |           |da filial na qual conectou inicialmente.    ³±±
±±³Esther V.   |13/06/17|DRHPONTP-886|Melhorias e ajustes p/ processo de admissão³±±
±±³            |        |            |de candidatos pelo módulo SIGARSP.         ³±±
±±³            |        |            |Inclusao PE RS01DEPA.                      ³±±
±±³Isabel N    |21/06/17|DRHPONTP-926|Ajuste para gravar QG_FILIAL e QG_MAT de   ³±±
±±³            |        |            |acordo com funcionário criado na Admissão. ³±±
±±³Isabel N.   |04/08/17|DRHPONTP-973|Ajuste no combobox p/ exibir tamanho maximo³±±
±±³            |        |            |das descrições de empresa + filial.        ³±±
±±³Jaqueline L.|12/02/17|DRHPONTP-   |Ajuste no posicionamento da SQG pois estava³±±
±±³            |        |2874        |disposionando o registro selecionado.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPM001

	Local lIntTaf		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local aSocialNiv	:= If( (lIntTaf .Or. lMiddleware) .And. Findfunction("fGM17Nivel"), fGM17Nivel("TRMRSP"), {.F.,""})
	Local oMBrowse

	Static  nSelecao	:= 0
	
	Private cFiltraSQS	:= ""			//Variavel para filtro
	Private cFilUserSQS	:= ""			//Variavel para filtro
	Private aIndexSQS	:= {}			//Variavel Para Filtro
	Private bFilBrwSQS 	:= {|| Nil}		//Variavel para Filtro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aAC       	:= { STR0001, STR0002 } 			//'Abandona'###'Confirma'
	Private aCRA      	:= { STR0002, STR0003 , STR0001 } 	//'Confirma'###'Redigita'###'Abandona'
	Private lPassThru 	:= .F.
	Private lCtrVaga	:= GetNewPar("MV_CTRVAGA",.T.)	// 	T -> Controla Vagas
	Private cVaga		:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Redefine Variaveis                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA := 0

	__cEmpAnt := cEmpAnt
	__cFilAnt := cFilant

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemtoAnsi(STR0007) //'Admissao de Candidatos'

	// Informa usuário sobre compartilhamento indevido na SRA
	If fR33SRA()
		Return
	EndIf

	If !aSocialNiv[1] .And. aSocialNiv[2]<>""
		MsgAlert(aSocialNiv[2],OemToAnsi(STR0008))  //"Usuário ou módulo sem acesso aos campos necessários ao eSocial. A informação será atualizada somente na base do GPE, sem integração do evento."
		leSocGPE := .T.
	EndIf

	nSelecao := fRsm001Sel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Cadastro de Vagas - SQS
	Private aRotina := MenuDef()// ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	If nSelecao == 1	// Selecao por Vaga

		dbSelectArea("SQS")
		dbSetOrder(1)

		oMBrowse := FWMBrowse():New()
		
		oMBrowse:SetAlias("SQS")
		oMBrowse:SetDescription(OemtoAnsi(STR0007)) //'Admissao de Candidatos'
		oMBrowse:ForceQuitButton() //"Incluir botao de sair" 
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto Entrada para adicionar condicao ao filtro 				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("RSFILSQS")
			cFilUserSQS	:= ExecBlock( "RSFILSQS", .F., .F. )
		Endif
		cFiltraSQS	:= "SQS->QS_NRVAGA > SQS->QS_VAGAFEC"
		cFiltraSQS	:= Iif(!empty(cFiltraSQS) .and. !empty(cFilUserSQS), cFiltraSQS + " .and. ", cFiltraSQS)
		cFiltraSQS	:= Iif(!empty(cFilUserSQS),cFiltraSQS + cFilUserSQS, cFiltraSQS)
				
		oMBrowse:SetFilterDefault( cFiltraSQS )
		oMBrowse:DisableDetails()
		oMBrowse:Activate()
			
	ElseIf nSelecao == 2					// Selecao por Candidato
		Rs001Ok()
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs001Ok   ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 09/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra candidatos agendados para a Vaga selecionada.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs001Ok()                                 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RspM001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs001Ok()

Local aCores 		:= {}
Local aLegenda		:= {}
Local cArray		:= ""
Local cOrgCfg		:= GetMv("MV_ORGCFG", NIL, "0")
Local cReprovado	:= GetMv("MV_RSPREP", NIL, "1")//0=Não Mostra se teve etapa reprovada;1=mostra sempre
Local cBlqCV		:= SuperGetMv("MV_BLQCV",,"1")
Local lSelecao		:= .F.
Local lIntRSP		:= GetMv("MV_IORGRSP", NIL, "0") == "1"
Local nx 			:= 0
Local oMBrowse

Private cFilUserSQG	:= ""
Private cFiltraSQG	:= ""			//Variavel para filtro
Private cFiltraCV	:= ""			//Variavel para filtro
Private aIndexSQG	:= {}			//Variavel Para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DOCRSP:                                                    	 ³
//³ 	As cores definidas na mBrowse depende do campo QG_SITUAC.³
//³   Foram definidas da seguinte maneira:                  	 ³
//³   001 - VERDE         005 - LARANJA                     	 ³
//³   002 - VERMELHO      006 - MARROM                      	 ³
//³   003 - AMARELO       007 - PINK                        	 ³
//³   004 - CINZA         e acima de 007 - PRETO            	 ³
//³   					  FUN - AZUL				          	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCores  := { 	{ "SQG->QG_SITUAC=='001'",'BR_VERDE' },;
				{ "EMPTY(SQG->QG_SITUAC)",'BR_VERDE' },;
				{ "SQG->QG_SITUAC=='002'",'DISABLE' },;
				{ "SQG->QG_SITUAC=='003'",'BR_AMARELO' },;
				{ "SQG->QG_SITUAC=='004'",'BR_CINZA' },;
				{ "SQG->QG_SITUAC=='005'",'BR_LARANJA' },;
				{ "SQG->QG_SITUAC=='006'",'BR_MARROM' },;
				{ "SQG->QG_SITUAC=='007'",'BR_PINK' },;
				{ "SQG->QG_SITUAC=='FUN'",'BR_AZUL' },;
				{ "Val(SQG->QG_SITUAC) ==008",'BR_PRETO' } }

If ( lRspAltLeg )
	aCores := ExecBlock("RSPALTLEG" , .F. , .F. , { aCores , {}} )
EndIf

cVaga := SQS->QS_VAGA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a integracao ORG X RSP esta ativada e se existe posto associado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntRSP .And. cOrgCfg == '1' .and. nSelecao == 1
	If Empty(SQS->QS_POSTO)
		Aviso(STR0007,STR0033,{"OK"},,STR0008)	//"Admissao de Candidatos" ### "Nenhum posto foi associado à vaga selecionada!! A integração entre os módulos Arquitetura Organizacional e Recrutamento e Seleção está ativada, portanto a associação entre vaga e posto é obrigatória. Acesse a rotina de cadastro de vagas e associe um posto para cada vaga." ### Atencao
		Return .T.
	Endif
Endif

DBSELECTAREA("SQG")

IF Columnpos("QG_ACTRSP") > 0
	cFiltraSQG	:= " SQG->QG_ACTRSP <> '1' "  //1- sem aceite e 2-com aceite"
ENDIF

IF cBlqCV == '2'
	cFiltraCV := "SQG->QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	cFiltraSQG := Iif(!empty(cFiltraSQG),cFiltraCV + " .and. " + cFiltraSQG , cFiltraCV)
ENDIF

If nSelecao == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Garantir o funcionamento da rotina no MenuDef a partir do Protheus 10  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lSelecao := .T.
	nSelecao := 2

	//Filtro conforme Agenda - SQD
	dbSelectArea("SQD")
	dbSetOrder(3)
	dbSeek(xFilial("SQD")+cVaga)
	While !Eof() .And. SQD->QD_VAGA == cVaga
		cCurric := SQD->QD_CURRIC
		cArray += SQD->QD_CURRIC+","
		While !Eof() .And. cCurric == SQD->QD_CURRIC
			If SQD->QD_SITPROC =="2"  .And. cReprovado == "0" //QD_SITPROC->0=Nao avaliado;1=Aprovado;2=Reprovado
				cArray := replace(cArray,SQD->QD_CURRIC+",","")
			EndIf
			dbSkip()
		EndDo
	EndDo

	dbSelectArea("SQD")
	dbSetOrder(1)

	dbSelectArea("SQG")
	dbSetOrder(1)

	cFiltraCV	:= " SQG->QG_CURRIC $ " + "'" + cArray + "' "
	cFiltraSQG := Iif(!empty(cFiltraSQG),cFiltraCV + " .and. " + cFiltraSQG , cFiltraCV)

EndIf

// Cadastro de Curriculos - SQG
aRotina := MenuDef()// ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

If lSelecao
	nSelecao := 1
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto Entrada para adicionar condicao ao filtro 				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("RSFILSQG")
	cFilUserSQG	:= ExecBlock( "RSFILSQG", .F., .F. )
Endif

cFiltraSQG	:= Iif(!empty(cFiltraSQG) .and. !empty(cFilUserSQG), cFiltraSQG + " .and. " + cFilUserSQG, cFiltraSQG)

dbSelectArea("SQG")
dbSetOrder(1)

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SQG")
oMBrowse:SetDescription(OemtoAnsi(STR0007)) //'Admissao de Candidatos'
	
aLegenda := Rsp001Leg()
For nx := 1 To Len(aLegenda)
	If nx == 1
		oMBrowse:AddLegend("SQG->QG_SITUAC=='001' .Or. EMPTY(SQG->QG_SITUAC)", aLegenda[nX][2], OemToAnsi(aLegenda[nx][3]))
	Else
		oMBrowse:AddLegend("SQG->QG_SITUAC=='"+aLegenda[nX][1]+"'", aLegenda[nX][2], OemToAnsi(aLegenda[nx][3]))
	EndIf
Next nX

oMBrowse:ForceQuitButton() //"Incluir botao de sair" 
oMBrowse:SetFilterDefault( cFiltraSQG )
oMBrowse:DisableDetails()
oMBrowse:Activate()
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs001emp  ³ Autor ³ Joeudo Santana 		³ Data ³ 18.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta tela para escolha de empresa/Filial         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs001emp(ExpC1,ExpN1,ExpN2)					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	nil						                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RspM001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs001emp(cAlias, nReg, nOpcX)

Local oDlg2
Local oMainWnd
Local oCbx
Local nOpca 	:= 0
Local nEmp		:= 0
Local aEmp		:={}
Local lFiliais	:= .T.
Local bSet15
Local bSet24

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Local aRet 			:= PswRet()
Local nI
Local nX
Local nY
Local nSM0Recno		:= SM0->( Recno() )
Local aUsrGrp		:= UsrRetGrp()
Local aUsrFil		:= {}
Local aUsrFilAux	:= {}

Private aCodEmp	:={}
Private cEmpAte	:= ""
Private cFilAte	:= ""
Private nCont	:= 0

// Monta array com as empresas

If Len(aRet[2][6]) > 0
	aUsrFil := aRet[2][6]
Else
	For nX := 1 to Len(aUsrGrp)
		aUsrFilAux := FWGrpEmp(aUsrGrp[nX])
		For nY := 1 to Len(aUsrFilAux)
			If aScan(aUsrFil, {|X| X == aUsrFilAux[nY]}) == 0
				aAdd(aUsrFil,aUsrFilAux[nY])
			EndIf
		Next nY
	Next nX
EndIf

dbSelectArea("SM0")
dbGotop()
While !Eof()

	For nI := 1 to Len(aUsrFil)
		If (Alltrim(aUsrFil[nI])== alltrim(SM0->M0_CODIGO+M0_CODFIL)) .OR. aUsrFil[nI] == "@@@@"

			lFiliais := .T.
			If !empty(SQS->QS_POSTO) .and. nSelecao == 1 //selecao por vaga
				If SQS->QS_FILPOST <> FWGETCODFILIAL
					lFiliais := .F.
				EndIf
			EndIf

			If lFiliais .AND. aScan(aCodEmp, {|X| X[1] == SM0->M0_CODIGO .AND. X[2] == FWGETCODFILIAL }) == 0
				nCont++
				aAdd(aEmp,alltrim(SM0->M0_NOME) + "  –  " + FWGETCODFILIAL + "  –  " + alltrim(SM0->M0_FILIAL))
				aAdd(aCodEmp,{SM0->M0_CODIGO,FWGETCODFILIAL} )
				nEmp:= Iif (SM0->M0_CODIGO+FWGETCODFILIAL == cEmpAnt + cFilant, nCont,nEmp)
			EndIf
		Endif
	Next
 	DbSkip()
EndDo
DbGoTo(nSM0Recno)

// Somente apresenta tela de opcao se tiver mais de uma empresa ou filial
If nCont > 1

	dbSelectArea("SQG")
	dbSetOrder(1)
	dbGoTop()
	If SQG->( EOF())
		Aviso(STR0007,STR0032,{"OK"},,STR0008)	//"Admissao de Candidatos"#"Operação Inválida: Não há currículos cadastrados na Base de Dados."#Atencao
		Return .T.
	Else
	// Volto para o Registro posicionado no Grid
	DbGoTo(nReg)

		nCbx:=nEmp

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta as Dimensoes dos Objetos         					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aAdvSize		:= MsAdvSize()
		aAdvSize[5]	:=	(aAdvSize[5]/100) * 52	//horizontal
		aAdvSize[6]	:=  (aAdvSize[6]/100) * 70	//Vertical
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
		aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*65), (((aObjSize[1,4])/100)*50) }	//1,3 Vertical /1,4 Horizontal
        DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

		DEFINE MSDIALOG oDlg2 TITLE STR0029 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL  					   				 //"Empresa - Filial"
		    bSet15 := {|| nOpca := 1, oDlg2:End()}
		    bSet24 := {|| nOpca := 0, oDlg2:End()}
			@ aGdCoord[1], aGdCoord[2] BITMAP oBmp RESNAME "MARCADAGUA" oF oDlg2 SIZE aGdCoord[4],aGdCoord[3]  NOBORDER WHEN .F. PIXEL
	 		@ aGdCoord[1]+5, aGdCoord[2]+5 SAY STR0030 FONT oBold PIXEL
	 		@ aGdCoord[1]+25, aGdCoord[2]+5 SAY STR0029 of oDlg2 PIXEL                                          						 //"Empresa"
	 		@ aGdCoord[1]+34, aGdCoord[2]+5 MSCOMBOBOX oCbx VAR nCbx ITEMS aEmp SIZE 420, 80 OF oDlg2 PIXEL ON CHANGE nEmp := oCbx:nAt

		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar( oDlg2 , bSet15 , bSet24 , Nil , Nil ) CENTERED

		// Codigos de empresa e filial selecionadas
		cEmpAte	:=	aCodEmp[nEmp][1]
		cFilAte	:=	aCodEmp[nEmp][2]

		If nOpca == 1
			lPassThru := .F.
			Rs001Cnv(cAlias, nReg, nOpcX)
		EndIf
	EndIf
Else
	Rs001Cnv(cAlias, nReg, nOpcX)
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs001Cnv  ³ Autor ³ Fernando Joly Siquini ³ Data ³ 25.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma Curriculuns em Cadastros de Funcion rios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs001Cnv(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = N£mero do registro                                 ³±±
±±³          ³ ExpN2 = N£mero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RspM001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs001Cnv(cAlias, nReg, nOpcX)

//-- Formato Padr„o do Arquivo TXT
//-- 111111111122222222223333333333444444444455555555556666666666
//-- 123456789012345678901234567890123456789012345678901234567890
//-- Ex.:
//-- <DEDEDEDEDEDEDEDEDEDEDEDEDEDE><PARAPARAPARAPARAPARAPARAPARA>
//-- Onde as 30 primeiras posi‡”es s„o destinadas ao preenchimento do Campo
//-- ( no formato ALIAS->NOME_DO_CAMPO - Ex.: SQG->QG_NOME ) ou Sintax Clipper
//-- ( Ex.: MsDate() ou dDataBase ) e as 30 posi‡”es seguintes s„o destinadas ao
//-- preenchimento do campo de Destino no arquivo SRA ( no formato j  citado ),
//-- mas com Alias referenciando uma vari vel de mem¢ria ( M-> ).

//-- Defini‡„o de Variaveis Locais
Local cString	:= ''
Local cArquivo  := ''
Local lPerg	 	:= .F.
Local nBytes    := 0
Local nStrSize  := 0
Local nFileSize := 0
Local nHandle   := 0
Local aSaveArea	:= GetArea()
Local lOutros	:= .F.
Local cTudoOk 	:= 'fRsm001Ok()'
Local lFech		:= .F.
Local cArray 	 := ""

//-- Defini‡„o de Variaveis Private
Private cCurric		:= SQG->QG_CURRIC
Private cMat		:= Space(06)
Private aDePara    	:= {}
Private aDePara2   	:= {}
Private bGPE010bAdd := {|| .T. }

//-- Impede que a fun‡Æo seja executada 2 vezes pelo AxInclui
If lPassThru
	lPassThru := .F.
	Return Nil
EndIf

//-- Define o arquivo TXT a ser utilizado
cArquivo := GetMv('MV_RSPDEPA')

If nSelecao == 1

	dbSelectArea("SQS")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SQS") + cVaga)
		Return Nil
	EndIf

	If !A001Existe()
		Return Nil
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SQG",aIndexSQG,.T.)
	aIndexSQG := {}

	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSeek(xFilial("SQG") + cCurric)

Endif

If nSelecao == 2 .And. lCtrVaga
	lPerg := PERGUNTE("RSP001",.T.)
	If ! lPerg
		Return Nil
	EndIf
	If !A001Existe()
		Return Nil
	EndIf
	cVaga := mv_par01
EndIf

If SQG->QG_SITUAC == '002'
	Help(Space(1), 1, 'RSPFUJAADM') //-- Cadastrar - Funcionario ja Admitido

ElseIf SQG->QG_SITUAC == 'FUN'


		cMat	:= SQG->QG_MAT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao Cadastro Funcionario / Envio e-mail ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fRsm001Fun(nOpcx)


ElseIf !File(cArquivo)
	Aviso(STR0008,STR0034,{"Ok"})	//"Atencao"###"Arquivo RSPDEPA.TXT não encontrado. Verifique o preenchimento do parâmetro MV_RSPDEPA. Este parâmetro deve conter a localização e o nome correto do arquivo TXT"

ElseIf ( nHandle := fOpen(cArquivo) ) >= 0
	nBytes    := 0
	nFileSize := fSeek(nHandle, 0, 2)
	fSeek(nHandle, 0, 0)

	nStrSize := 0
	cString  := ''

	Do While nBytes < nFileSize

		//-- Lˆ 256 bytes para encontrar a Quebra de Linha
		nStrSize := 256
		cString  := Space(nStrSize)
		If ( nStrSize := fRead(nHandle, @cString, nStrSize) ) # nStrSize
			Help(Space(1), 1, 'RSPERROTXT') //-- Cadastrar - Erro de Leitura no Arquivo TXT
		EndIf
		fSeek(nHandle, ((nStrSize)*(-1)), 1)

		//-- Carrega o conte£do de 1 linha para a variavel cString
		nStrSize := At( Chr(10), cString)	//Buscar apenas chr(10) devido Linux
		cString  := Space(nStrSize)

		If fRead(nHandle, @cString, nStrSize) # nStrSize
			Help(Space(1), 1, 'RSPERROTXT') //-- Cadastrar - Erro de Leitura no Arquivo TXT
			Exit
		Else
			If Subs(cString,(nStrSize - 1) ) == Chr(13)+Chr(10)
				cString := Subs(cString, 1, (nStrSize - 2) ) //Windows
			Else
				cString := Subs(cString, 1, (nStrSize - 1) ) //Linux
			EndIf

			If Left(cString,1) == "<"
				lOutros := .T.
				nBytes += nStrSize
				Loop
			EndIf

			If lOutros
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para RSPDEPA.TXT com 80 posicoes - NOVO formato  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SubStr(cString,44,2) == "->"
				  	aAdd(aDePara2, { AllTrim(Left(cString, 40)), AllTrim(Subs(cString, 41))} )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para RSPDEPA.TXT com 60 posicoes - formato antigo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf SubStr(cString,34,2) == "->"
					aAdd(aDePara2, { AllTrim(Left(cString, 30)), AllTrim(Subs(cString, 31))} )
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para RSPDEPA.TXT com 80 posicoes - NOVO formato  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SubStr(cString,41,3) == "M->"
				  	If Len(cString) >= 41
						aAdd(aDePara, { &(AllTrim(Left(cString, 40))), AllTrim(Subs(cString, 41))} )
					EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para RSPDEPA.TXT com 60 posicoes - formato antigo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf SubStr(cString,31,3) == "M->"
					If Len(cString) >= 31
						aAdd(aDePara, { &(AllTrim(Left(cString, 30))), AllTrim(Subs(cString, 31))} )
					EndIf
				EndIf
			EndIf

		EndIf
		nBytes += IIf(nStrSize== 0,256,nStrSize)

	EndDo

	If fClose(nHandle)
		//Ponto de Entrada para manipular campos que serao gravados no SRA ou Tabelas Dependentes durante processo de admissao.
		If ExistBlock("RS01DEPA")
			aReturn:= ExecBlock( "RS01DEPA", .F., .F., {aDePara,aDePara2} )
			If Len(aReturn) == 2
				aDePara := aReturn[1]
				aDePara2 := aReturn[2]
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto Entrada para validacao antes de apresentar tela de entrada. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("RS01AG")
			If !( ExecBlock( "RS01AG", .F., .F. ) )
				Eval(bFilBrwSQG)
				RestArea(aSaveArea)
				Return Nil
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto Entrada para Montagem de TudoOk na tela de Dados do SRA.	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("RS01TDOK")
			cTudoOk += " .And. ExecBlock( 'Rs01TdOk',.F.,.F.)"
		EndIf

		bGPE010bAdd := &('{||'+ cTudoOk + '}')

		dbSelectArea('SRA')

    	//Para mais de uma empresa ou "n" filiais de uma mesma empresa
		If nCont > 1
			// Carrega empresa onde sera efetivado o candidato
	    	If __cEmpAnt <> cEmpAte
	     		GPEGetEmpr( cEmpAte+cFilAte  )
	   		ElseIf __cFilAnt <> cFilAte
				cFilAnt := cFilAte
	   		EndIf
	   	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cadastro de Funcionarios partindo de um Candidato SQG	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Gpea010Mnt( "SRA", Nil, 3, cMat, Nil, Nil, Nil, , leSocGPE ) == 1
 	   		MBrChgLoop( .F. )

			fRsM001DP2()	// Carrega variaveis de outros arquivos

   	 		dbSelectArea("SQG")
   			dbSetOrder(1)
			If dbSeek(xFilial("SQG")+cCurric)

				lPassThru := .T.

				Begin Transaction
					SQG->(RecLock('SQG', .F.))
					Replace SQG->QG_SITUAC 	With '002'
					Replace SQG->QG_VAGA 	With cVaga
					Replace SQG->QG_MAT		With SRA->RA_MAT
					Replace SQG->QG_FILMAT 	With SRA->RA_FILIAL
					SQG->(MsUnlock())
				End Transaction
			EndIf

			If lCtrVaga		// Encontrar a vaga do candidato

				// Subtrair a vaga do candidato
				dbSelectArea("SQS")
				dbSetOrder(1)
				If dbSeek(xFilial("SQS")+cVaga)
					RecLock("SQS",.F.)
						Replace QS_VAGAFEC With QS_VAGAFEC + 1
						If SQS->QS_VAGAFEC >= SQS->QS_NRVAGA
							Replace QS_DTFECH WITH dDataBase
							lFech := .T.
						EndIf
					MsUnlock()

					//Limpa campos do SQG referente a Vaga encerrada
					If lFech .And. MsgYesNo(STR0026)	//"Deseja atualizar campos dos Curriculos, referente esta vaga ?"
						Processa( {|| RsLimpSQG()} )
					EndIf					
				EndIf				
			EndIf	
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravacao da Pontuacao da Graduacao do Fator |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SQ8")
			dbSetOrder(1)
			dbSeek(xFilial("SQ8")+SRA->RA_MAT)

			While SQ8->( !Eof() ) .And. SQ8->Q8_MAT == SRA->RA_MAT

				dbSelectArea("SQ2")
				SQ2->( dbSetOrder(2) )

				If SQ2->( dbSeek(xFilial("SQ2")+SQ8->Q8_FATOR+SQ8->Q8_GRAU) )
					Begin Transaction
						SQ8->(RecLock('SQ8', .F.))
						Replace SQ8->Q8_PONTOS With SQ2->Q2_PONTOSI
						SQ8->(MsUnlock())
					End Transaction
				EndIf

				dbSelectArea("SQ8")
				SQ8->( dbSkip() )

			EndDo

			 //Retorna a empresa original
   	        If nCont > 1 //Para mais de uma empresa ou "n" filiais de uma mesma empresa
				If __cEmpAnt <> cEmpAnt
			   		GPEGetEmpr( __cEmpAnt+__cFilAnt )
		   		ElseIf __cFilAnt <> cFilAnt
		   			cFilAnt := __cFilAnt
		   		EndIf
		   	EndIf
		EndIf

		If nCont > 1  //Para mais de uma empresa ou "n" filiais de uma mesma empresa
			If __cEmpAnt <> cEmpAnt
		   		GPEGetEmpr( __cEmpAnt )
	   			cFilAnt := __cFilAnt
	   		ElseIf __cFilAnt <> cFilAnt
	   			cFilAnt := __cFilAnt
	   		EndIf
	  	EndIf

	Else
		Help(Space(1), 1, 'RSPERROTXT') //-- Cadastrar - Erro de Leitura no Arquivo TXT
	EndIf
EndIf


//-------------------------------------------------------------------------------------
// Refaz filtros do Browse (SQG) - Curriculos
//-------------------------------------------------------------------------------------

If nSelecao == 1 	// Selecao por Vaga

	//Filtro conforme Agenda - SQD
	dbSelectArea("SQD")
	dbSetOrder(3)
	dbSeek(xFilial("SQD")+cVaga)
	While !Eof() .And. SQD->QD_VAGA == cVaga
		cCurric := SQD->QD_CURRIC
		cArray += SQD->QD_CURRIC+","
		While !Eof() .And. cCurric == SQD->QD_CURRIC
			dbSkip()
		EndDo
	EndDo

	dbSelectArea("SQG")
	dbSetOrder(1)
 	cFiltraSQG		:= " SQG->QG_CURRIC $ "+"'"+cArray+"'"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQG",aIndexSQG,.T.)
cFiltraSQG	:= Iif(!empty(cFiltraSQG) .and. !empty(cFilUserSQG), cFiltraSQG + " .and. ", cFiltraSQG)
cFiltraSQG	:= Iif(!empty(cFilUserSQG),cFiltraSQG + cFilUserSQG, cFiltraSQG)
bFilBrwSQG 	:= {|| FilBrowse("SQG",@aIndexSQG,@cFiltraSQG) }
Eval(bFilBrwSQG)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQG")
dbGotop()

RestArea(aSaveArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001Dep³ Autor ³ Fernando Joly Siquini ³ Data ³ 03.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche as Variaveis de Mem¢ria com Informa‡”es do Func.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001Dep                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv - Chamada no GPEA010.PRX                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM001DeP()

Local nX 		:= 0
Local cFuncao	:= " "
Local cCargo	:= " "
Local cTabela	:= Space(03)
Local cTabNive	:= Space(02)

// Busca Funcao no Cadastro de Vagas
If lCtrVaga

	dbSelectArea("SQS")
	dbSetOrder(1)
	If dbSeek(xFilial("SQS")+cVaga)
		cFuncao := SQS->QS_FUNCAO
	EndIf

	If nCont > 1  //Para mais de uma empresa ou "n" filiais de uma mesma empresa
		// Carrega empresa onde sera efetivado o candidato
    	If __cEmpAnt <> cEmpAte
     		GPEGetEmpr( cEmpAte+cFilAte  )
   		ElseIf __cFilAnt <> cFilAte
			cFilAnt := cFilAte
   		EndIf
   	EndIf

	dbSelectArea("SRJ")
	dbSetOrder(1)
	If dbSeek(xFilial("SRJ")+cFuncao)
		cCargo := SRJ->RJ_CARGO
	EndIf

	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cCargo)
		cTabela	:=  SQ3->Q3_TABELA
		cTabNive:=  SQ3->Q3_TABNIVE
	EndIf

	Iif( IsMemVar( "RA_CODFUNC"		), M->RA_CODFUNC	:= cFuncao	,	)
	Iif( IsMemVar( "RA_TABELA"		), M->RA_TABELA		:= cTabela	,	)
	Iif( IsMemVar( "RA_TABNIVE"		), M->RA_TABNIVE	:= cTabNive	,	)

EndIf

dbSelectArea("SRA")
For nX := 1 to Len(aDePara)
  	&(aDePara[nX, 2]) := (aDePara[nX, 1])
Next nX

RunTrigger(1, NIL, NIL, NIL, "RA_CODFUNC")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001DP2³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche  Variaveis com Informa‡”es do Func. (Outros Arq.) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001DP2                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM001DP2

Local nX 		:= 0
Local cAliasAnt := cAliasAtu := cAliasDe := Space(03)
Local aTmp		:= {}

For nX := 1 to Len(aDePara2)
	cAliasAtu := Left(aDePara2[nX, 2],3)
	If cAliasAnt != cAliasAtu
		If Len(aTmp) > 0

			fRSM001Grv(aTmp,cAliasDe,cAliasAnt) // Gravacao

			aTmp := {}
		EndIf
		cAliasDe  := Left(aDePara2[nX, 1],3)
		cAliasAnt := cAliasAtu
	EndIf
	If !Empty(cAliasAnt)
		dbSelectArea(cAliasAnt)
		If FieldPos(Subs(aDePara2[nX, 2],6,Len(aDepara2[nx, 2]))) != 0
			Aadd(aTmp,aDePara2[nx])
	    EndIf
	EndIf
Next nX

If Len(aTmp) > 0
	fRSM001Grv(aTmp,cAliasDe,cAliasAnt) // Gravacao
EndIf

Return Nil


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao que verifica se existe vaga disponivel. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A001Existe()
Local lCtlVaga	:= GetNewPar("MV_CTRVAGA",.T.)	// 	T -> Controla Vagas
Local lRet:=.T.
Local cReprovado	:= GetMv("MV_RSPREP", NIL, "1")//0=Não Mostra se teve etapa reprovada;1=mostra sempre

If ! lCtlVaga
	Return lRet
EndIf

If nSelecao == 2
	cVaga := mv_par01
EndIf

dbSelectArea("SQS")
dbSetOrder(1)
If dbSeek(xFilial("SQS")+cVaga)
	If SQS->QS_NRVAGA <= SQS->QS_VAGAFEC
		lRet:= .F.
	EndIf
Else
	lRet:= .F.
EndIf

If !lRet
	Help(Space(1), 1, 'RSPNEXIST') //-- Nao existe a vaga indicada para o candidato.
EndIf

If cReprovado == "0"
	dbSelectArea("SQD")
	dbSetOrder(3)//QD_FILIAL+QD_VAGA+QD_CURRIC+DTOS(QD_DATA)
	dbSeek(xFilial("SQD")+cVaga+cCurric)
	While !SQD->(Eof()) .And. SQD->QD_VAGA == cVaga .And. cCurric == SQD->QD_CURRIC
		If SQD->QD_SITPROC =="2"   //QD_SITPROC->0=Nao avaliado;1=Aprovado;2=Reprovado
			lRet := .F.
			Aviso(STR0007,STR0035,{"OK"},,STR0008)	//"Admissao de Candidatos" ### "Candidato não aprovado nos testes para esta vaga"    ### Atencao
			Exit
		EndIf
		SQD->(dbSkip())
	EndDo
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001Grv³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados dos funcionarios referente outros arquivos .   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001Grv                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM001Grv(aTmp,cAliasDe,cAliasPara)

Local nx
Local cAliasCur := Subst(cAliasDe,2,2)
Local cCampoCur := cAliasCur+"_CURRIC"

Private cDCurso	:= "" // Uso em RSPDEPA.TXT

dbSelectArea(cAliasDe)
dbSetOrder(1)
dbSeek(xFilial(cAliasDe)+cCurric)
While !Eof() .And. cCurric == &cCampoCur

    If cAliasCur == "QM"

    	dbSelectArea("SQT")
    	dbSetOrder(1)
    	cDCurso := Space(20)
    	If dbSeek(xFilial("SQT")+SQM->QM_CURSO)
	    	cDCurso	:= SQT->QT_DESCRIC
	    EndIf

    	dbSelectArea(cAliasDe)
    	dbSetOrder(1)
    EndIf

	If 	( cAliasPara == "RA4" .And. Empty(SQM->QM_CDCURSO) ) .Or.;
	 	( cAliasPara == "SQ9" .And. !Empty(SQM->QM_CDCURSO))
		dbSkip()
		Loop
	EndIf

	dbSelectArea(cAliasPara)
	dbSetOrder(1)
	RecLock(cAliasPara, .T.)
	For nx := 1 to Len(aTmp)
		&(aTmp[nX, 2]) := &(aTmp[nX, 1])
	Next nx
	MsUnlock()

	dbSelectArea(cAliasDe)
	dbSkip()
EndDo
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001Ok ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Salario de acordo com Tabela Salarial.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001Ok	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRsm001Ok()
Local lRet 		:= .T.
Local lOk1 		:= .F.
Local lOk2		:= .F.
Local aFaixas 	:= {}
Local nTipoVl	:= 0
Local i 		:= 0

If ValType(M->RA_TABELA) != "U" .And. ValType(M->RA_TABNIVE)	!= "U"

	dbSelectArea("RB6")
  	dbSetOrder(1)
  	If dbSeek(xFilial("RB6")+M->RA_TABELA+M->RA_TABNIVE)
  		nTipoVl	:= RB6->RB6_TIPOVL
  		While !Eof() .And. RB6->RB6_TABELA+RB6->RB6_NIVEL ==;
  								M->RA_TABELA+M->RA_TABNIVE

	  		Aadd(aFaixas,{RB6->RB6_FAIXA, RB6->RB6_VALOR})
	  		dbSkip()
	  	EndDo

	  	For i := 1 to Len(aFaixas)

	  		If nTipoVl == 1 .Or. nTipoVl == 3		//Valores Exatos
	  		 	If M->RA_SALARIO == aFaixas[i][2]
	  		 		lOk1 := lOk2 := .T.
	  		 		Exit
	  		 	EndIf

	  		ElseIf nTipoVl == 2						//Por Intervalo
	  			If Val(aFaixas[i][1]) % 2 != 0//Faixa de
		  			If M->RA_SALARIO >= aFaixas[i][2]
		  				lOk1 := .T.
		  			Else
		  				lOk1 := .F.
		  			EndIf
		  		Else//Faixa ate
		  			If M->RA_SALARIO <= aFaixas[i][2]
		  				lOk2 := .T.
		  			Else
		  				lOk2 := .F.
		  			EndIf
	  			EndIf

	  			If lOk1 .And. lOk2
	  				Exit
	  			EndIf

	  		EndIf
		Next i

		If lOk1 .And. lOk2
			lRet := .T.
		Else
			lRet := .F.
		EndIf

  	EndIf
EndIf

If !lRet
	If GetNewPar("MV_RSPTAB",.F.)
		If MsgYesNo(OemToAnsi(STR0010)+" "+OemToAnsi(STR0027))	//"O salario esta fora das faixas da Tabela Salarial."###"Confirma o cadastro nesta condição? "
			lRet := .T.
		EndIf
	Else
		Aviso(OemToAnsi(STR0008), OemToAnsi(STR0010),{"OK"})	//"Atencao"###"O salario esta fora das faixas da Tabela Salarial."
	EndIf
EndIf

If lRet
	lRet := PcoVldLan('000084','02','GPEA010')
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001FUN³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao de Opcoes (Atualizacao Cadastro / e-mail).		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001OFun	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRsm001Fun(nOpcx)

Local oDlg,oRadio
Local bBlock
Local nOpca		:= 0
Local nRadio	:= 1
Local lRet		:= .F.
Local lFech		:= .F.
Local bSet15
Local bSet24

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private lSraOk		:= .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 55	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 45	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*30), (((aObjSize[1,4])/100)*50) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0013) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL	//"Aprovacao de Funcionario"
    bSet15 := {|| lRet := .T., nOpca:=1,oDlg:End()}// Confirma
    bSet24 := {|| lRet := .T., oDlg:End()}     	 // Cancela
	bBlock 	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
	oRadio 	:= TRadMenu():New( aGdCoord[1]+5, aGdCoord[2]+5, {STR0014, STR0015},bBlock, oDlg,,,,,,,,80,10)	//"Atualizar Cadastro"###"Enviar e-mail"
	nRadio 	:= oRadio:nOption

ACTIVATE MSDIALOG oDlg Valid lRet ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED

If nOpca == 1
	dbSelectArea('SRA')
	dbSetOrder(1)
	If dbSeek(xFilial("SRA")+cMat)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Cadastro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRadio == 1
			If Gpea010(4) == 1
				lPassThru := .T.
				Begin Transaction
					SQG->(RecLock('SQG', .F.))
						Replace SQG->QG_SITUAC With '002'
						Replace SQG->QG_FILMAT With SRA->RA_FILIAL
						Replace SQG->QG_MAT	  With SRA->RA_MAT
					SQG->(MsUnlock())
				End Transaction

			EndIf
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia e-mail do Evento 020                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fMontaMail("020")

		EndIf

		If lCtrVaga .And. lSraOk	// Encontrar a vaga do candidato

			// Subtrair a vaga do candidato
			dbSelectArea("SQS")
			dbSetOrder(1)
			If dbSeek(xFilial("SQS")+cVaga)
				RecLock("SQS",.F.)
					Replace QS_VAGAFEC With QS_VAGAFEC + 1
					If SQS->QS_VAGAFEC >= SQS->QS_NRVAGA
						Replace QS_DTFECH WITH dDataBase
						lFech := .T.
					EndIf
				MsUnlock()

				//Limpa campos do SQG referente a Vaga encerrada
				If lFech .And. MsgYesNo(STR0026)	//"Deseja atualizar campos dos Curriculos, referente esta vaga ?"
					Processa( {|| RsLimpSQG()} )
				EndIf					
			EndIf					
		EndIf	
				
	Else
		Aviso(OemToAnsi(STR0008),OemToAnsi(STR0021), {"Ok"},,OemToAnsi(STR0022))	//"Atencao"###"Alterar a Situacao no curriculo, pois nao foi utilizada opcao de Selecao interna."###"Situacao do Candidato incorreta"
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM001Sel³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao de Opcoes (Atualizacao Cadastro / e-mail).		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM001OFun	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fRsm001Sel(nOpcx, cCadastro)

Local oDlg
Local oRadio
Local bBlock
Local nOpca		:= 0
Local nRadio	:= 1
Local lRet		:= .F.
Local bSet15
Local bSet24

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Default cCadastro := OemtoAnsi(STR0007) //'Admissao de Candidatos'

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 55	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 30	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*50) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL
    bSet15 := {|| lRet := .T., nOpca:=1,oDlg:End()}// Confirma
    bSet24 := {|| lRet := .T., oDlg:End()}   		 // Cancela
	bBlock 	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
	oRadio 	:= TRadMenu():New( aGdCoord[1]+10, aGdCoord[2]+5, {OemToAnsi(STR0023), OemToAnsi(STR0024)},bBlock, oDlg,,,,,,,,80,10)	//"Selecao por Vaga"###"Selecao por Candidato"
	nRadio 	:= oRadio:nOption

	//DEFINE SBUTTON FROM 01,95  TYPE 1 ACTION (lRet := .T., nOpca:=1,oDlg:End()) ENABLE OF oDlg		// Confirma
   //	DEFINE SBUTTON FROM 16,95  TYPE 2 ACTION (lRet := .T., oDlg:End()) ENABLE OF oDlg				// Cancela

ACTIVATE MSDIALOG oDlg Valid lRet ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED

If nOpca != 1
	nRadio := 0
EndIf

Return nRadio

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RsLimpSQG ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 25/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa campos do curriculo (SQG) ref. vaga encerrada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RsLimpSQG()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RsLimpSQG()

Local aSaveArea		:= GetArea()
Local cAliasQry		:= ""
Local aStruSQG		:= {}
Local nx			:= 0
Local lPeRS001GV	:= ExistBlock("RS001GV")

dbSelectArea("SQG")
dbSetOrder(1)

aStruSQG := SQG->(dbStruct())
cAliasQry := GetNextAlias()

cQuery := "SELECT * "
cQuery += "  FROM "+RetSqlName("SQG")+" SQG "
cQuery += " WHERE SQG.QG_FILIAL  = '" + xFilial("SQG")+"'"
cQuery += "  AND SQG.QG_ULTVAGA = '" + cVaga + "'"
cQuery += "  AND SQG.QG_SITUAC <> '002'"
cQuery += "	 AND SQG.D_E_L_E_T_=' ' "
cQuery += "ORDER BY QG_FILIAL, QG_ULTVAGA"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T.)

For nX := 1 To Len(aStruSQG)
	If ( aStruSQG[nX][2] <> "C" )
		TcSetField(cAliasQry,aStruSQG[nX][1],aStruSQG[nX][2],aStruSQG[nX][3],aStruSQG[nX][4])
	EndIf
Next nX

dbSelectArea(cAliasQry)


ProcRegua( (cAliasQry)->( RecCount() ) )

While !(cAliasQry)->(Eof())

	IncProc(STR0025+(cAliasQry)->QG_CURRIC)	//"Curriculo: "

	DbSelectarea("SQG")
	DbSetOrder(1)
	DbSeek(xFilial("SQG")+(cAliasQry)->(QG_CURRIC))

	RecLock("SQG",.F.)
		SQG->QG_ULTVAGA	:= Space(06)
		SQG->QG_ULTETAP	:= Space(02)
		SQG->QG_ULTDATA	:= Ctod(Space(08))
		SQG->QG_DTTESTE	:= Ctod(Space(08))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para gravacao de campos no SQG para cada candidato agendado  ³
		//³ para a vaga encerrada. 														  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPeRS001GV
			ExecBlock("RS001GV",.F.,.F.)
		Endif
	SQG->( MsUnlock() )

    (cAliasQry)->( dbSkip() )

EndDo

(cAliasQry)->(dbCloseArea())
dbSelectArea("SQG")
RestArea(aSaveArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPEGetEmpr³ Autor ³ Ivan Cabral			³ Data ³ 22/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza abertura de novo ambiente de trabalho			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEGetEmpr()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs001Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPEGetEmpr(cEmp)
Local lIsPyme := __lPyme

DEFAULT cEmp := cEmpAnt

cNumEmp := cEmp

If UnCheckStation(cNumEmp) .or. UnCheckStation(cEmpAnt+cFilAnt)	//se for empresa teste forca verificacao de licenca
	__lLogOff := .T.
	__nOldModulo:=999999
EndIf

If SubStr(cEmpAnt,1,2) != SubStr(cNumEmp,1,2)
	cArqTab := ""
	cEmpAnt := Substr(cNumEmp,1,2)
	cFilAnt := Substr(cNumEmp,3,FWGETTAMFILIAL)
	DbCloseAll()
	OpenSm0(cNumEmp)
	OpenFile(cNumEmp)
	If lIsPyme != __lPyme
		CursorWait()
		aMenu:={}
		MsgRun(Space(15)+STR0028,,{|| AmbInit()})   //"Aguarde.....O novo ambiente será inicializado!"
		CursorArrow()
	EndIf
Else
	Connect()
	CheckAut(cNumEmp)
	ResetCtb()
EndIf

DbSelectArea("SM0")
DbSeek(cNumEmp)
cEmpAnt := SUBSTR(cNumEmp,1,2)
cFilAnt := SUBSTR(cNumEmp,3,FWGETTAMFILIAL)

FWMonitorMsg("Emp :"+cEmpAnt+"/"+cFIlAnt+" Logged :"+Padr(Subs(cUsuario,7,15),15)+Padr(' SIGA'+cModulo,9)+' Obj :Main Window')

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AmbInit	³ Autor ³ Ivan Cabral			³ Data ³ 22/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o ambiente novo								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AmbInit()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEGetEmpr                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AmbInit()
Local cOldFOpened

Private aOpt1[0],aOpt2[0],aOpt3[0],aOpt4[0]
Private aOpt1m[0],aOpt2m[0],aOpt3m[0],aOpt4m[0]

cOldFOpened:=cFOpened
cFOpened := ""
__nOriModulo := nModulo

ReOpenFile(cFOpened,cOldFOpened)
InitPublic()
SetOnExit(,.T.)
Return


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPM001                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

	Local aRotina
	Local cCadastro := OemtoAnsi(STR0007) //'Admissao de Candidatos'

	If IsInCallStack('CFGA530')
		nSelecao := fRsm001Sel(, cCadastro)
	EndIf
	
	If nSelecao == 1	// Selecao por Vaga

		// Cadastro de Vagas - SQS
		aRotina := {{"OK", "RS001OK", 0, 2}}		//"OK"

	ElseIf nSelecao == 2 // Selecao por Candidato

		// Cadastro de Curriculos - SQG
		aRotina := {{STR0004, 'AxPesqui'	,	0,	1,, .F.}, ; //'Pesquisar'
					{STR0005, 'AxVisual'	,	0,	2}		, ; //'Visualizar'
					{STR0006, 'Rs001emp'	,	0, 	3}		, ; //'Admissao'
					{STR0011, "RSP010Leg"	,	0, 	2,, .F.	} }	//"Legenda"
	EndIf

Return aRotina

/*/{Protheus.doc} Rsp001Leg()
	(Busca informações na tabela R3 para montagem da Legenda)
	@type  Static Function
	@author Emerson Grassi Rocha
	@since 11/08/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function Rsp001Leg()

Local aSaveArea	:= GetArea()
Local aCores 	:= {}
Local aLegenda	:= {}
Local nX		:= 0

aCores  := { 	{ "001",'BR_VERDE' 		},; 
				{ "   ",'BR_VERDE' 		},;
				{ "002",'DISABLE' 		},;
				{ "003",'BR_AMARELO'	},;
				{ "004",'BR_CINZA'		},;
				{ "005",'BR_LARANJA'	},;
				{ "006",'BR_MARROM' 	},;
				{ "007",'BR_PINK' 		},;
				{ "FUN",'BR_AZUL' 		}}

If ( lRspAltLeg )
	aCores := ExecBlock("RspAltLeg" , .F. , .F. , { {} , aCores } )
EndIf

dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"R3")
While !Eof() .And. SX5->X5_TABELA == "R3"
	nX := Ascan(aCores, {|x| x[1] == AllTrim(SX5->X5_CHAVE)} )
	If nX > 0
		Aadd(aLegenda, {aCores[nX][1], aCores[nX][2], AllTrim(SX5->X5_DESCRI)})
	Else
		Aadd(aLegenda, {AllTrim(SX5->X5_CHAVE), "BR_PRETO", AllTrim(SX5->X5_DESCRI)})
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)

Return(aLegenda)
