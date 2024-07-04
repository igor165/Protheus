#Include 'Protheus.ch'
#Include 'TECA360.CH'

Function TECA360()

MsgInfo(STR0063) //"Assistente Para Implanta��o de Contrato: Rotina Descontinuada!"

Return

/*
#Include 'FWMVCDEF.CH'
//Itens Contratos
#DEFINE P_MARCA				1
#DEFINE P_NUMCONT				2
#DEFINE P_CLIENT				3
#DEFINE P_LOJA				4
#DEFINE P_NOMECLI				5
#DEFINE P_TIPO  				6
#DEFINE P_DATA  				7
#DEFINE P_DATA2  				8
#DEFINE P_GRUPOCOBERT 		9
#DEFINE P_NUMPROP				10
#DEFINE P_CPAGPV				11
#DEFINE P_CENTROCUSTO		12
#DEFINE P_OCOROS				13

//Itens Funcionarios
#DEFINE P_FILIAL				1
#DEFINE P_MAT					2
#DEFINE P_NOME				3
#DEFINE P_CARGO				4
#DEFINE P_DESCARG				5
#DEFINE P_FUNCAO				6
#DEFINE P_TURNO				7
#DEFINE P_CC					8
#DEFINE P_DESFUNC				9

//Itens Atendentes
#DEFINE P_CODATEND			1
#DEFINE P_NOMEATEND			2
#DEFINE P_FUNCAOATD			3
#DEFINE P_ALOCA				4
#define P_TIPOATEND			5

//Base de Atendimento do Contrato
#DEFINE P_PRODUTO				1
#DEFINE P_DESCRICAO			2
#DEFINE P_IDENTIFICADOR		3
#DEFINE P_SITE				4
#DEFINE P_LOJA				5
#DEFINE P_FAB					6

// Benef�cios do Contrato
#DEFINE P_BENEFPROP			1
#DEFINE P_DESCBNPROP			2
#DEFINE P_VALORBENPROP		3


	*************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: TECA360||Autor: Douglas Bichir||Data 26/12/2012|*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Interface Assistente de implanta��o do Contrato||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: SIGATEC     ||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*************************************************************


Function TECA360()

Local oWizard		:= Nil											//objeto que ser� utilizado como objeto visual tipo wizard
Local oPanel 		:= Nil											//objeto que ser� usado como painel
Local oPesq1		:= Nil											//Pesquisa de Contrato
Local oLbxCont	:= Nil											//ListBox Contrato
Local oOk			:= Nil											//Check no list de contrato
Local oNo			:= Nil											//Check no list de contrato
Local oLbxDadosC	:= Nil											//Utilizado para ListBox Base de Atendimento
Local oLbxFunc	:= Nil											//Utilizado para ListBox Funcion�rios
Local oLbxBenPro	:= Nil											//Utilizado para ListBox Benef�cios
local oLbxAtend	:= Nil											//Utilizado para ListBox Atendente
Local oModel		:= Nil  										//Utilizado para Receber valor dO fonte teca350 feito em MVC.
Local oView		:= Nil

Local nTamCond	:= TamSx3("E4_CODIGO")[1]					//Quantidade Maxima de caracteres da Condi��o de Pagamento.
Local nTamOco	:= TamSx3("AAG_CODPRB")[1]						//Quantidade Maxima de caracteres da Ocorr�ncia do Contrato.

Local aSize		:= FWGetDialogSize( oMainWnd )
Local aContrato	:=	{}											//Array onde ser�o carregados os contratos dispon�veis para implanta��o.
Local aFuncionar 	:=	{}											//Array onde os novos funcion�rios que n�o s�o atendentes ser�o carregados.
Local aAtendente	:=	{}											//Array onde ser�o carregados os atendentes do mesmo centro de custo do contrato.
Local aDadosCont	:=	{}											//Array onde ser�o carregadas as Bases de Atendimento do Contrato.
Local aBenProp	:=	{}											//Array onde ser� carregado o benef�cio do contrato e seus intens.
Local aChaveAA3	:= {}											//Array com bases de atendimento, com o formato nencess�rio para a function de gera��o da Ordem de Servi�o.

Local cProposta	:= ""											//Proposta Comercial
Local cPesq1		:= Space(40)									//Valor do c�digo do contrato a ser pesquisado na tela de contratos.
Local cCondPV	:= Space(nTamCond)								//Condi��o de Pagamento
Local cOcorren	:= Space(nTamOco)								//Ocorr�ncia do Contrato
Local cContMnt	:= ""											//Contrato de Manuten��o
Local cCodCli		:= ""
Local cCodBen		:= ""										//Cliente do contrato
Local cOS		:= ""

Local  bFinish	:= NIL											//Finalizar do Wizard.

Local lGera		:= .F.											//Para Gera��o da Ordem de Servi�o.
Local lAloc		:= .F.											//Verificar se o usu�rio pretende realizar a aloca��o ao encerrar o Assistente de Implanta��o do Contrato.

oOk	:= LoadBitMap(GetResources(), "LBOK")
oNo	:= LoadBitMap(GetResources(), "LBNO")

aContrato	:= At360Cont()										//Popula Array do listBox para iniciar a tela dos contratos.
aDadosCont	:= At360BsAtd()										//Popula Array do listBox para iniciar a tela das Bases de Atendimento.
aFuncionar	:= At360Func()										//Popula Array do listBox para iniciar a tela dos Funcion�rios.
aAtendente	:= At360Atend()										//Popula Array do listBox para iniciar a tela dos Atendentes.

//Chama gera��o da OS
bFinish		:= {||lGera := At360GrOrS(cProposta, aChaveAA3, cCondPV, cOcorren, cContMnt, @cOS)}

//Cria��o de paineis do assistente de implanta��o de contrato
oWizard := ApWizard():New (STR0001, STR0002, STR0001, STR0002,{ || .T.}, { || .T.}, .T.,sem uso ,sem uso,.T.,{aSize[1],aSize[2],aSize[3]*0.95,aSize[4]})//"Assistente"/ "Assistente de Implanta��o de Contrato"/ "Assistente"/ "Assistende de Implanta��o de Contrato"
oWizard:newPanel(STR0003, STR0004, {||.T.}, {||At360VldCt(oWizard, oLbxCont,"Contr",oPanel,oWizard)}, {||.T.}, .F., {||.T.} ) //"Contratos para Implanta��o"/ "Selecione um Contrato para implanta��o"
oWizard:newPanel(STR0005, STR0006, {||.T.}, {||At360Benef(oWizard, oPanel:=oWizard:GetPanel(4), cContMnt,1, aContrato[oLbxCont:nAt,P_NUMPROP])}, {||.T.}, .F., {||.T.}) // "Bases de Atendimento do Contrato"/ "Visualize ou Inclua Bases de Atendimento ao Contrato"
oWizard:newPanel(STR0007, STR0008, {||.T.}, {||.T.}, {||.T.}, .T.,{||.T.}) //"Benef�cios do Contrato"/ "Visualize o Benef�cio do Contrato"
oWizard:newPanel(STR0009, STR0010, {||At360Benef(oWizard, oPanel:=oWizard:GetPanel(4), cContMnt, 2, aContrato[oLbxCont:nAt,P_NUMPROP] )}, {|| At360VldFc(aFuncionar, aAtendente, oLbxFunc, oLbxAtend, aContrato[oLbxCont:nAt,P_CENTROCUSTO])}, {||.T.},.F.,{||.T.}) // "Funcion�rios que n�o s�o Atendentes"/ "Cadastre os novos funcion�rios como Atendentes para que sejam alocados"
oWizard:newPanel(STR0011, STR0012, {||.T.}, {||.T.}, bFinish, .F., {||.T.})//"Manuten��o de Atendentes"/ "Visualize ou Altere os Atendentes"

//Painel para sele��o de Contrato que n�o foi implantado
oPanel	:= oWizard:getPanel(2)
	@ 001,005 SAY STR0013 OF oPanel PIXEL SIZE 120,9 //"Contrato de Manuten��o:"
	@ 010,007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 PIXEL
	@ 010,115 BUTTON STR0014 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxCont, cPesq1, @oPesq1, .T.)) //"Pequisar"
	@ 010,150 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxCont, cPesq1, @oPesq1, .F.)) //"Proximo"
	@ 010,185 BUTTON STR0016 SIZE 30,12 OF oPanel PIXEL Action (At360VCtrt(aContrato[oLbxCont:nAt,P_NUMCONT])) //"Visualizar"

	@ 025,007 LISTBOX oLbxCont FIELDS;
		HEADER	"" 						,;
				STR0017 ,;//"N�mero do Contrato"
				STR0018 				,;//"Cliente"
				STR0019				,;//"Loja"
				STR0020 	,;//"Nome do Cliente"
				STR0021 	,;//"Tipo de Contrato"
				STR0022	,;//"Inicio de Vig�ncia"
				STR0023 	,;//"Fim da Vig�ncia"
				STR0024 ,;//"Grupo de Cobertura"
				STR0025 ,;//"N�mero da Proposta"
		SIZE (oPanel:nWidth/2)-20,(((oPanel:nHeight/2)*0.9)-20) of oPanel PIXEL;
		ON dblClick(aEval(aContrato, {|x|x[P_MARCA] := .F.}), aContrato[oLbxCont:nAt,P_MARCA] := .T.,aChaveAA3 := At360AtuBs(aDadosCont,aContrato[oLbxCont:nAt,P_NUMCONT],oLbxDadosC), At360AtFnc(aFuncionar,oLbxFunc,aContrato[oLbxCont:nAt,P_CENTROCUSTO]),;          //Chama atualiza��o da Base de Atendimento de acordo com contrato selecionado.
		cContMnt := aContrato[oLbxCont:nAt,P_NUMCONT], cCondPV := aContrato[oLbxCont:nAt,P_CPAGPV], cOcorren	:=	aContrato[oLbxCont:nAt,P_OCOROS], cProposta:=aContrato[oLbxCont:nAt,P_NUMPROP], At360Atndt(aAtendente,oLbxAtend, aContrato[oLbxCont:nAt,P_CENTROCUSTO]), cCodCli:=aContrato[oLbxCont:nAt,P_CLIENT], oLbxCont:Refresh())

//Popula o listbox de acordo com os valores atribuidos a variavel aContrato pela function At360Cont().
oLbxCont:SetArray(aContrato)
oLbxCont:bLine := { ||{If(aContrato[oLbxCont:nAt,P_MARCA],oOk,oNo)		,;
					aContrato[oLbxCont:nAt,P_NUMCONT]						,;
					aContrato[oLbxCont:nAt,P_CLIENT]						,;
					aContrato[oLbxCont:nAt,P_LOJA]							,;
					aContrato[oLbxCont:nAt,P_NOMECLI]						,;
					X3Combo("AAH_TPCONT",aContrato[oLbxCont:nAt,P_TIPO])	,;
					aContrato[oLbxCont:nAt,P_DATA]							,;
					aContrato[oLbxCont:nAt,P_DATA2]							,;
					aContrato[oLbxCont:nAt,P_GRUPOCOBERT]					,;
					aContrato[oLbxCont:nAt,P_NUMPROP]}}
//Painel para visualiza��o das Bases de Atendimento
oPanel := oWizard:GetPanel(3)
	@ 001,005 SAY STR0026 OF oPanel PIXEL SIZE 120,9 //"Bases de Atendimento:"
	@ 010,007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 PIXEL
	@ 010,115 BUTTON STR0014 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxDadosC, cPesq1, @oPesq1, .T.)) //"Pequisar"
	@ 010,150 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxDadosC, cPesq1, @oPesq1, .F.)) //"Proximo"
	@ 010,185 BUTTON STR0016 SIZE 30,12 OF oPanel PIXEL Action (At360VBase(aDadosCont[oLbxDadosC:nAt,P_IDENTIFICADOR])) //"Visualizar"
	@ 010,220 BUTTON STR0027 SIZE 60,12 OF oPanel PIXEL Action (Iif(At360IncBs(cContMnt, cCodCli)=1,At360AtuBs(aDadosCont,cContMnt,oLbxDadosC),Nil)) //"Incluir no Contrato"

	@ 025,007 LISTBOX oLbxDadosC FIELDS;
		HEADER STR0028					,; //"Produto"
				STR0029	,; //"Descri��o do Produto"
				STR0030			,; //"Identifica��o"
				STR0031						,; //"Site"
		SIZE (oPanel:nWidth/2)-20,(((oPanel:nHeight/2)*0.9)-20) of oPanel PIXEL;

//Popula o listbox de acordo com os valores atribuidos a variavel aDadosCont pela K At360BsAtd().
oLbxDadosC:SetArray(aDadosCont)
oLbxDadosC:bLine	:= { ||{	aDadosCont[oLbxDadosC:nAt,P_PRODUTO ]			,;
					 		 	aDadosCont[oLbxDadosC:nAt,P_DESCRICAO ]		,;
					 		 	aDadosCont[oLbxDadosC:nAt,P_IDENTIFICADOR ]	,;
					 		 	aDadosCont[oLbxDadosC:nAt,P_SITE ]}}

// Painel para visualiza��o, cadastrar/associar o funcion�rio a um atendente
oPanel := oWizard:GetPanel(5)
	@ 001, 005 SAY STR0032 OF oPanel PIXEL SIZE 220,9 //"Novos Funcion�rios contratados para o centro de custo do contrato:"
	@ 010, 007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 PIXEL
	@ 010, 115 BUTTON STR0014 SIZE 30,12 OF oPanel PIXEL ACTION(Tk040Busca(@oLbxFunc, cPesq1,@oPesq1, .T.)) //"Pesquisar"
	@ 010, 150 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL ACTION(Tk040Busca(@oLbxFunc, cPesq1, @oPesq1, .F.)) //"Proximo"
	@ 010, 185 BUTTON STR0033 SIZE 45,12 OF oPanel PIXEL ACTION (At360CaAtd(, 3, "INCLUIR"), At360AtFnc(aFuncionar,oLbxFunc,aContrato[oLbxCont:nAt,P_CENTROCUSTO]),oLbxAtend, oLbxFunc:Refresh()) //"Cad. Atendente"

	@ 025,  007 LISTBOX oLbxFunc FIELDS;
		HEADER STR0034			,; //"Matricula"
				STR0035			,; //"Nome"
				STR0036			,; //"Cargo"
				STR0037			,; //"Desc. Cargo"
				STR0038			,; //"Fun��o"
				STR0039			,; //"Desc. Fun��o"
		SIZE (oPanel:nWidth/2)-20,(((oPanel:nHeight/2)*0.9)-20) of oPanel PIXEL;

//	Popula o listbox de acordo com os valores atribuidos a variavel "afuncionar" pela function At360Func().
oLbxFunc:SetArray(aFuncionar)
oLbxFunc:bLine :={||{aFuncionar[oLbxFunc:nAt,P_MAT]					,;
					aFuncionar[oLbxFunc:nAt,P_NOME]						,;
					aFuncionar[oLbxFunc:nAt,P_CARGO]					,;
					aFuncionar[oLbxFunc:nAt,P_DESCARG]					,;
 					aFuncionar[oLbxFunc:nAt,P_FUNCAO]					,;
					aFuncionar[oLbxFunc:nAt,P_DESFUNC]}}

//Painel para visualiza��o,altera��o de um atendente
oPanel:= oWizard:GetPanel(6)
	@ 001, 005 SAY STR0040 OF oPanel PIXEL SIZE 220,9 //"Op��es para Atendentes"
	@ 010, 005 BUTTON STR0016 SIZE 30,12 OF oPanel PIXEL ACTION At360CaAtd(aAtendente[oLbxAtend:nAt,P_CODATEND], 1, "VISUALIZAR")//"Visualizar"
	@ 010, 040 BUTTON STR0041 SIZE 30,12 OF oPanel PIXEL ACTION (At360CaAtd(aAtendente[oLbxAtend:nAt,P_CODATEND], 4, "ALTERAR"), At360Atndt(aAtendente, oLbxAtend,aContrato[oLbxCont:nAt,P_CENTROCUSTO])) //"Alterar"

	@ 025, 007 LISTBOX oLbxAtend FIELDS;
		HEADER	STR0042		,; //"Cod. Atendente"
				STR0035		,; //"Nome"
				STR0038		,; //"Fun��o"
				STR0043		,; //"Tipo"
			STR0044		,; //"Aloca��o"
	SIZE (oPanel:nWidth/2)-20,(((oPanel:nHeight/2)*0.9)-20) of oPanel PIXEL;

//	Popula o listbox com os atendentes de acordo com o centro de custo do contrato.
oLbxAtend:SetArray(aAtendente)
oLbxAtend:bLine	:= {||{aAtendente[oLbxAtend:nAt,P_CODATEND]				,;
						aAtendente[oLbxAtend:nAt,P_NOMEATEND]				,;
						aAtendente[oLbxAtend:nAt,P_FUNCAOATD]				,;
						X3Combo("AA1_ALOCA",aAtendente[oLbxAtend:nAt,P_ALOCA]),;
						X3Combo("AA1_TIPO",aAtendente[oLbxAtend:nAt,P_TIPOATEND])}}

oWizard:activate( .T., {||lGera .OR. MsgYesNo(STR0045)}, <bInit>, <bWhen> ) //"Tem certeza que deseja cancelar o Assistente de Implanta��o de Contrato?"

If lGera
lAloc	:= MsgYesNo(STR0046)//" Deseja realizar aloca��o neste Instante? "
	If lAloc
		MsgRun ( STR0060, STR0061, {|| TECA330(cContMnt)} ) //"Abrindo rotina de Aloca��o de Atendentes", "Aguarde"
	EndIf
EndIf
Return	(.T.)


	*************************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360Cont||Autor: Douglas Bichir||Data 26/12/2012|||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega contratos existentes que n�o tenham sidos implantados||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*************************************************************************


Static Function At360Cont()

Local aArea		:= GetArea()
Local aAreaADY	:= ADY->(GetArea())
Local aCont		:= {}
Local cAliasAAH	:= "AAH"
Local cFilAAH		:= xFilial("AAH")
Local cQuery		:= ""

Local cNmAAH 	:= RetSQLName("AAH")
Local cNMSA1 	:= RetSQLName("SA1")

dbSelectArea("AAH")
dbSetOrder(1)

	cAliasAAH	:= GetNextAlias()
	cQuery		:= "SELECT AAH_FILIAL, AAH_CCUSTO,AAH_CONTRT, AAH_CODCLI, AAH_LOJA, A1_NOME, AAH_TPCONT, AAH_INIVLD, AAH_FIMVLD, AAH_CODGRP, AAH_PROPOS, AAH_CPAGPV, AAH_OCOROS, AAH_IMPLAN "
	cQuery		+= " FROM " + cNmAAH
	cQuery		+= " INNER JOIN " + cNMSA1
	cQuery		+= 		" ON " + cNMSA1+".A1_FILIAL = " + "'"+xFilial("SA1")+"'"
	cQuery		+= 		" AND " + cNMSA1+".D_E_L_E_T_= ' '"
	cQuery		+= 		" AND " + cNmAAH+".AAH_CODCLI = " + cNMSA1+".A1_COD "
	cQuery		+= 		" AND " + cNmAAH+".AAH_LOJA = " + cNMSA1+".A1_LOJA "
	cQuery		+= " WHERE AAH_FILIAL = '" + cFilAAH + "'"
	cQuery		+= " AND AAH_IMPLAN = '2' "
	cQuery		+= " AND " + cNmAAH +".D_E_L_E_T_ = '' "
	cQuery		+= " ORDER BY AAH_FILIAL, AAH_INIVLD"

	cQuery		:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasAAH, .T., .T.)
	TcSetField(cAliasAAH, "AAH_INIVLD", "D")

	DbSelectArea(cAliasAAH)
	DbSelectArea("ADY")
	DbSetOrder(1)

//	Preenche o array com as informa��es do contrato

While !(cAliasAAH)->(Eof())

	If ( ADY->(DbSeek(xFilial("ADY")+(cAliasAAH)->AAH_PROPOS)) .AND. ADY->ADY_PROCES == "S" )
		aAdd(aCont,{	.F.					,;
			(cAliasAAH)->AAH_CONTRT		,;
			(cAliasAAH)->AAH_CODCLI		,;
			(cAliasAAH)->AAH_LOJA		,;
			(cAliasAAH)->A1_NOME			,;
			(cAliasAAH)->AAH_TPCONT		,;
			(cAliasAAH)->AAH_INIVLD		,;
			(cAliasAAH)->AAH_FIMVLD		,;
			(cAliasAAH)->AAH_CODGRP		,;
			(cAliasAAH)->AAH_PROPOS		,;
			(cAliasAAH)->AAH_CPAGPV		,;
			(cAliasAAH)->AAH_CCUSTO		,;
			(cAliasAAH)->AAH_OCOROS		})
	EndIf
	(cAliasAAH)->(DbSkip())
End

#IFDEF TOP
	(cAliasAAH)->(DbCloseArea())
#ENDIF

If Len(aCont)==0
	aCont	:=	{{.F.,"","","","","","","","","","","",""}}
EndIf

RestArea(aArea)
RestArea(aAreaADY)
Return aCont


	*****************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360VCtrt||Autor: Douglas Bichir||Data 26/12/2012||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*||Cria tela de Visualiza��o do Contrato Selecionado||||||||||||*
 	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cNrContrat - N�mero do Contrato||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*****************************************************************


Static Function At360VCtrt(cNrContrat)		//Visualiza��o do Contrato

Local nReg        := 0

Private cCadastro := "Contrato - VISUALIZAR"
Private aRotina         := {}            // Variavel com a opcao visualizar.
Private Inclui          := .F.           // Declarado falso para que n�o seja considerada tela de inclus�o.
Private Altera          := .F.           // Declarado falso para que n�o seja considerada tela de altera��o.

If !Empty(cNrContrat)

	DbSelectArea("AAH")
	DbSetOrder(1)
	DbSeek(xFilial("AAH")+cNrContrat)
	aRotina := {{"Visualizar","At200Manut",0,2}}
	nReg := AAH->(Recno())
	At200Manut("AAH",nReg, 1 )
Else
	MsgAlert(STR0047,STR0048)//"Selecione um Contrato"/"Aten��o"
EndIf

Return( .T. )


	***************************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360AtuBs||Autor: Douglas Bichir||Data 26/12/2012||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*||Desc. Atualiza Base de atendimento de acordo com Contrato selecionado||*
 	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: aDadosCont - Base de Atendimento|||||||||||||||||||||||||||*
 	*|||Par�metro: cNrContrat - N�mero do Contrato||||||||||||||||||||||||||||*
 	*|||Par�metro: oLbxDadosC - Objeto ListBox Base Atendimento|||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	***************************************************************************


Static Function At360AtuBs(aDadosCont, cNrContrat,oLbxDadosC)

Local aChavesAA3 := {}
Local nCont	:= 0

aDadosCont := At360BsAtd(cNrContrat)

oLbxDadosC:SetArray(aDadosCont)
oLbxDadosC:bLine	:= { ||{	aDadosCont[oLbxDadosC:nAt,P_PRODUTO ]		,;
					 		 	aDadosCont[oLbxDadosC:nAt,P_DESCRICAO ]		,;
					 		 	aDadosCont[oLbxDadosC:nAt,P_IDENTIFICADOR ],;
					 		 	aDadosCont[oLbxDadosC:nAt,P_SITE ]}}

oLbxDadosC:Refresh()

For nCont=1 To Len(aDadosCont)
	aAdd(aChavesAA3,	xFilial("AA3")+aDadosCont[nCont][6]+aDadosCont[nCont][5]+aDadosCont[nCont][1]+aDadosCont[nCont][3])
Next nCont

Return( aChavesAA3 )


	**************************************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360BsAtd||Autor: Douglas Bichir||Data 26/12/2012|||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega informa��es Base de Atendimento de acordo com Contrato Selecionado||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cNrContrat - N�mero do Contrato|||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	**************************************************************************************


Static Function At360BsAtd(cNrContrat)
Local aArea		:= GetArea()
Local cQuery		:= ""
Local cAliasAA3	:= "AA3"
Local aDadosCont := {}

Default cNrContrat := ""

DbSelectArea("AA3")
cAliasAA3 := GetNextAlias()

cQuery := "SELECT AA3_FILIAL, AA3_CODCLI, AA3_LOJA, AA3_NUMSER, AA3_CODPRO, AA3_SITE, AA3_CODFAB, AA3_LOJAFA, AA3_CONTRT"
cQuery	+= " FROM " + RetSQLName("AA3")
cQuery += " WHERE AA3_CONTRT = "+"'"+cNrContrat+"'"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAA3, .T., .T. )

DbSelectArea(cAliasAA3)

While !(cAliasAA3)->(Eof())
	aAdd(aDadosCont,{		(cAliasAA3)->AA3_CODPRO														,;
							Posicione("SB1",1,xFilial("SB1")+(cAliasAA3)->AA3_CODPRO,"B1_DESC")	,;
							(cAliasAA3)->AA3_NUMSER 														,;
							(cAliasAA3)->AA3_SITE 														,;
							(cAliasAA3)->AA3_LOJAFA 														,;
							(cAliasAA3)->AA3_CODFAB	})

	(cAliasAA3)->(DbSkip())
End

(cAliasAA3)->(DbCloseArea())

If Len(aDadosCont)==0
	aDadosCont={{"", "", "", "", "", ""}}
EndIf

RestArea(aArea)

Return( aDadosCont )


	*******************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360VldCt||Autor: Douglas Bichir||Data 26/12/2012||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Valida��o do bot�o avan�ar do painel de contrato|||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: oLbxCont - Objeto ListBox Contrato ||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*******************************************************************


Static Function At360VldCt(oWizard, oLbxCont)

Local lRet		:= .T.
Local nItSel	:= 0

nItSel := aScan(oLbxCont:aArray,{|x| x[P_MARCA] }) 	// Validar se existe contrato selecionado

If nItSel == 0 .AND. !Empty(oLbxCont:aArray[1][P_NUMCONT])
	MsgInfo(STR0049) 					//"Selecione o Contrato para implanta��o"
	lRet := .F.

ElseIf Empty(oLbxCont:aArray[1][P_NUMCONT])
	lRet := .F.
	MsgInfo(STR0050) //"N�o existem Contratos para serem implantados, finalize o Assistente!"
	oWizard:SetFinish()
EndIf

Return lRet


	************************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360VBase||Autor: Douglas Bichir||Data 26/12/2012|||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Cria tela de visualiza��o da Base de atendimento selecionada||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cNrBaseAt - ID Base de Atendimento||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	************************************************************************


Static Function At360VBase(cNrBaseAt)

Local nReg        := 0

Private cCadastro := "Base de Atendimento - VISUALIZAR"
Private aRotina         := {}                                    // Variavel com a opcao visualizar.
Private Inclui          := .F.                                         // Declarado falso para que n�o seja considerada tela de inclus�o.
Private Altera          := .F.                                         // Declarado falso para que n�o seja considerada tela de altera��o.

If !Empty(cNrBaseAt)

	DbSelectArea("AA3")
	DbSetOrder(6)
	DbSeek(xFilial("AA3")+cNrBaseAt)
	aRotina := {{"Visualizar","At040Visua",0,2}}
	nReg := AA3->(Recno())
	At040Visua("AA3",nReg,1)
Else
	MsgAlert(STR0051,STR0048) //"Selecione uma Base de Atendimento"/"Aten��o"
EndIf

Return( .T. )


	****************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa:At360IncBs||Autor: Douglas Bichir||Data 26/12/2012||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega tela de Inclus�o de Base de Atendimento|||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cContMnt - Contrato de Manuten��o|||||||||||||||*
 	*|||Par�metro: cCodCli - C�digo do Cliente ||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	****************************************************************


Static Function At360IncBs(cContMnt, cCodCli)
Local aArea		:= GetArea()
Local nOpcA		:= 0
Local cAlias		:="AA3"
Local cIdUnico	:=""
Private Inclui          := .T.
Private Altera          := .F.
Private cCadastro := "Base de Atendimento - INCLUIR"

SaveInter()

DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias))
Private aRotina := {{ "Pesquisar"	,"AxPesqui"  	,0	,1	,0	,.F.},;//"Pesquisar"
						{"Visualizar"	,"At040Visua"	,0	,2	,0	,.T.},;	//"Visualizar"
						{"Incluir"	,"At040Inclu"	,0	,3	,0	,.T.}}	//"Incluir"
nOpcA := At040Inclu(cAlias,0,3,1)
cIdUnico := AA3->AA3_NUMSER

MsUnlock()
RestInter()
RestArea(aArea)

At360IncCont(cIdUnico, cCodCli, nOpcA, cContMnt)		//Inclui no Contrato que foi selecionado

Return nOpcA


	******************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360Benef||Autor: Douglas Bichir||Data 26/12/2012|||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega tela de benef�cios||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||Par�metro: oWizard - objeto Panel de Benef�cios||||||||||||||*
 	*|||Par�metro: oPanel - objeto wizard do Panel ||||||||||||||||||*
 	*|||Par�metro: cContMnt - Contrato de Manutne��o|||||||||||||||||*
 	*|||Par�metro: cProposta - N�mero da Proposta||||||||||||||||||||*
 	*|||Par�metro: nDirecao - verifica se est� avan�ando/voltando||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	******************************************************************


Static Function At360Benef(oWizard, oPanel, cContMnt, nDirecao, cProposta)

Local lVisualiza	:=	.F.
Local aBenef		:= {}
Local cAliasBen	:= GetNextAlias()

BeginSQL alias cAliasBen
	SELECT DISTINCT SB1.B1_COD, SB1.B1_DESC, ABO.ABO_ITPRO
		FROM  %table:ABO%  ABO
		JOIN %table:SB1%  SB1 ON
 			SB1.B1_FILIAL = %xFilial:SB1% AND
			SB1.%notDel%	AND
 			SB1.B1_COD = ABO.ABO_PRODUT
 	WHERE
 		ABO.ABO_FILIAL = %xFilial:ABO% AND
		ABO.%notDel%	AND
		ABO.ABO_PROPOS = %exp:cProposta%
EndSQL

DbSelectArea(cAliasBen)
If !(cAliasBen)->(Eof())
	While !(cAliasBen)->(Eof())
		Aadd(aBenef, {cContMnt, '2', Space(2), (cAliasBen)->B1_COD, (cAliasBen)->B1_DESC, (cAliasBen)->ABO_ITPRO })
		(cAliasBen)->(DbSkip())
	End

	TECA350(aBenef, .T.) //carrega as variaveis para load
	oModel := FWLoadModel("TECA350")
	oModel:SetOperation(1)
	oModel:Activate()

	oView := FWLoadView("TECA350")
	oView:SetModel(oModel)
	oView:SetOperation(1)
	oView:SetOwner(oPanel)
	oView:EnableControlBar(.F.)
	oView:SetUseCursor(.F.)
	oView:Activate()

	lVisualiza	:= .T.
Else
	If(nDirecao==1)
		msgAlert(STR0052,STR0048) //"N�o existe Benef�cio para esta proposta, ser� direcionado para tela de Funcion�rios!","Aten��o"
		oWizard:SetPanel(5)
	ElseIf(nDirecao==2)
		oWizard:SetPanel(3)
	EndIf
	lVisualiza	:= .F.

EndIf

(cAliasBen)->(DbCloseArea())

Return lVisualiza


	****************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360Func||Autor: Douglas Bichir||Data 26/12/2012||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega funcion�rios que ainda n�o s�o atendentes|||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||Par�metro: cCusto - Centro de Custo do Contrato |||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	****************************************************************


Static Function At360Func(cCcusto)

Local cQuery	:= ""
Local cAliasSRA	:= "SRA"
Local aFunc	:= {}
Local aArea	:= GetArea()

Default cCCusto := ""

DbSelectArea("SRA")
DbSetOrder(1)

cAliasSRA		:= GetNextAlias()

cQuery		:= "SELECT RA_FILIAL, RA_TNOTRAB, RA_CC, RA_MAT, RA_NOME, RA_CARGO, RA_CODFUNC"
cQuery		+= " FROM " + RetSqlName("SRA")

// Where para selecionar funcion�rios que n�o estejam cadastrados como atendente
cQuery		+= "WHERE RA_CC = '" + cCcusto + "'"
cQuery		+= " AND NOT EXISTS(SELECT AA1_CDFUNC FROM " + RetSqlName("AA1") + " WHERE AA1_CDFUNC = " + RetSqlName("SRA")+".RA_MAT  AND "+ RetSqlName("AA1")+".D_E_L_E_T_ = ' ' )"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSRA, .T., .T. )

DbSelectArea(cAliasSRA)

//	Preenche o array com as informa��es de funcion�rios que n�o s�o atendentes.
While !(cAliasSRA)->(Eof())
	aAdd(aFunc,{	(cAliasSRA)-> RA_FILIAL																,;
					( cAliasSRA)->	RA_MAT																,;
					(cAliasSRA)->	RA_NOME																,;
					(cAliasSRA)->RA_CARGO																,;
					Posicione("SQ3", 1, xFilial("SQ3") + (cAliasSRA)->RA_CARGO , "Q3_DESCSUM")	,;
					(cAliasSRA)->RA_CODFUNC 																,;
					(cAliasSRA)->RA_TNOTRAB																,;
					(cAliasSRA)->RA_CC																	,;
					Posicione("SRJ", 1,  xFilial("SRJ") + (cAliasSRA)->RA_CODFUNC, "RJ_DESC") })
					(cAliasSRA)->(DbSkip())
End

(cAliasSRA)->(DbCloseArea())

If Len(aFunc)==0
	aFunc :={{"","","","","","","","",""}}
EndIf
RestArea(aArea)

Return ( aFunc )


	******************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360CaAtd||Autor: Douglas Bichir||Data 26/12/2012||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega tela Atendente pelo bot�o Cad.Atendente|||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: oLbxDadosC - Objeto ListBox Base de Atendimento|||*
 	*|||Par�metro: nOperation - Tipo de opera��o no FwExecView|||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	******************************************************************


Static Function At360CaAtd(cCodAtend, nOperation, cOperation)

Default cCodAtend := ""

	If nOperation=3
		FwExecView(cOperation, "VIEWDEF.TECA020", nOperation, oDlg, {|| .T.}, bOK ,nPercReducao)
	Else
		DbSelectArea("AA1")
		DbsetOrder(1)
		DbSeek(xFilial("AA1")+cCodAtend)
		FwExecView(cOperation, "VIEWDEF.TECA020", nOperation, oDlg, {|| .T.}, bOK ,nPercReducao)
	EndIf
Return ( .T. )


	**********************************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360AtFnc||Autor: Douglas Bichir||Data 26/12/2012|||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Atualiza Funcion�rios que n�o s�o atendentes no painel de Funcion�rios||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: aFuncionar - Array com dados dos funcion�rios|||||||||||||||||||||*
 	*|||Par�metro: oLbxFunc - Objeto ListBox Funcion�rio ||||||||||||||||||||||||||||*
 	*|||Par�metro: cCusto - Centro de Custo do Contrato |||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	**********************************************************************************


Static Function At360AtFnc(aFuncionar, oLbxFunc,cCcusto)
aFuncionar := At360Func(cCcusto)

	oLbxFunc:SetArray(aFuncionar)
	oLbxFunc:bLine :={||{aFuncionar[oLbxFunc:nAt,P_MAT]				,;
					aFuncionar[oLbxFunc:nAt,P_NOME]						,;
					aFuncionar[oLbxFunc:nAt,P_CARGO]					,;
					aFuncionar[oLbxFunc:nAt,P_DESCARG]					,;
 					aFuncionar[oLbxFunc:nAt,P_FUNCAO]					,;
					aFuncionar[oLbxFunc:nAt,P_DESFUNC]}}
	oLbxFunc:Refresh()

Return( .T. )


	****************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa:At360Atend||Autor: Douglas Bichir||Data 26/12/2012||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Carrega atendentes cadastrados||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	****************************************************************


Static Function At360Atend(cCcusto)

Local cQuery	:= ""
Local cAliasAA1	:= "AA1"
Local aAtend	:= {}
Local aArea	:= GetArea()
DbSelectArea("AA1")
DbSetOrder(1)

Default cCcusto := ""

cAliasAA1	:= GetNextAlias()

cQuery	:= "SELECT AA1_CODTEC, AA1_NOMTEC, AA1_FUNCAO, AA1_ALOCA, AA1_TIPO, AA1_CC"
cQuery	+= "FROM" + RetSqlName("AA1")
cQuery += "WHERE AA1_CC = '"+cCcusto+"'"
cQuery	+= " AND " + RetSqlName("AA1")+".D_E_L_E_T_ = ''"

cQuery := changeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAA1, .T., .T.)

While!(cAliasAA1)->(Eof())
	aAdd(aAtend, {	(cAliasAA1)->AA1_CODTEC,;
						(cAliasAA1)->AA1_NOMTEC,;
						(cAliasAA1)->AA1_FUNCAO,;
						(cAliasAA1)->AA1_ALOCA,;
						(cAliasAA1)->AA1_TIPO})
	(cAliasAA1)->(DbSkip())
End

(cAliasAA1)->(DbCloseArea())

If Len(aAtend)==0
	aAtend:={{"", "", "", "", ""}}
EndIf
RestArea(aArea)

Return (aAtend)


	*****************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360GrOrS||Autor: Douglas Bichir||Data 26/12/2012||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Gera��o Ordem de Servi�os||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cCodProp - N�mero da Proposta||||||||||||||||||||*
 	*|||Par�metro: aChaveAA3 - Bases de Atendimento do Contrato|||||*
 	*|||Par�metro: cCondPV - Condi��o de Pagamento||||||||||||||||||*
 	*|||Par�metro: cOcorren - Ocorr�ncia||||||||||||||||||||||||||||*
 	*|||Par�metro: cContMnt - Contrato de Manuten��o||||||||||||||||*
 	*|||Par�metro: cNumOS - N�mero da Ordem de Servi�o||||||||||||||*
 	*|||Par�metro: dDataInc - Data de Inclus�o||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*****************************************************************


Static Function At360GrOrS(	cCodProp	, aChaveAA3	, cCondPV	, cOcorren	,;
						cContMnt	, cNumOS	, dDataInc)

Local lRet		:= .T.

Local aCab		:= {}
Local aItens	:= {}
Local aItem		:= {}

Local dDataBkp	:= dDataBase

Local lConfirm	:= .T.

Local nX		:= 0

Private lMsErroAuto	:= .F.

Default dDataInc := dDataBase

AB6->(DbSetOrder(1))

ADY->(DbSetOrder(1)) //ADY_FILIAL+ADY_PROPOS
ADY->(DbSeek(xFilial("ADY") + cCodProp))

//	Pega a ultima posi��o na tabela AB6 para atribuir o n�mero na OS que est� sendo realizada.
cNumOS := GetSXENum("AB6","AB6_NUMOS")
While AB6->(DbSeek(xFilial("AB6")+cNumOS))
	ConfirmSX8()
	cNumOS := GetSXENum("AB6","AB6_NUMOS")
End
RollBackSx8()

dDataBase := dDataInc

lConfirm	:= MsgYesNo(STR0053 + cNumOS + STR0054 + cContMnt + " ?")//"Confirma a gera��o da OS "/" e implanta��o do contrato "

If lConfirm

	//	Cabe�alho da OS

	aAdd(aCab,{"AB6_NUMOS"	,cNumOS				,Nil})
	aAdd(aCab,{"AB6_CODCLI"	,ADY->ADY_CODIGO	,Nil})
	aAdd(aCab,{"AB6_LOJA"	,ADY->ADY_LOJA		,Nil})
	aAdd(aCab,{"AB6_EMISSA"	,dDataInc			,Nil})
	aAdd(aCab,{"AB6_CONPAG"	,cCondPV			,Nil})
	aAdd(aCab,{"AB6_HORA"	,Time()				,Nil})
	aAdd(aCab,{"AB6_TPCONT"	,"1"				,Nil})
	aAdd(aCab,{"AB6_CONTRT"	,cContMnt			,Nil})

	//	Chave da base utilizada(Indice 4): AA3_FILIAL+AA3_CODFAB+AA3_LOJAFA+AA3_CODPRO+AA3_NUMSER

	AA3->(DbSetOrder(4))

	For nX := 1 to Len(aChaveAA3)
		AA3->(DbSeek(aChaveAA3[nX]))
		aItem:= {}

	//	Item da OS
		aAdd(aItem,{"AB7_ITEM"		,StrZero(nX,2)  	,Nil})
		aAdd(aItem,{"AB7_TIPO"		,"1"				,Nil})
		aAdd(aItem,{"AB7_CODPRO"	,AA3->AA3_CODPRO	,Nil})
		aAdd(aItem,{"AB7_NUMSER"	,AA3->AA3_NUMSER	,Nil})
		aAdd(aItem,{"AB7_CODPRB"	,cOcorren			,Nil})
		aAdd(aItens,aItem)
	Next nX

	TECA450(,aCab,aItens,,3)

	dDataBase := dDataBkp

	If lMsErroAuto
		lRet := .F.
		ConOut(STR0055) //"Erro na inclusao da Ordem de Servi�o!"
		MostraErro()
	Else	//Caso a Ordem de Servi�o seja incluida com sucesso, o contrato passa a ter status implantado.

		AAH->(DbSetOrder(1))
		If AAH->(DbSeek(xFilial("AAH")+cContMnt))
			RecLock("AAH",.F.)
			AAH->AAH_IMPLAN := "1"
			MsUnLock()
		End
		Aviso(STR0056,STR0057 + cNumOS,{"Ok"},2,STR0058)//"Assistente de Implanta��o de Contrato"/"Ordem de Servi�o Gerada:"/"Ordem de Servi�o Gerada com Sucesso!"

	EndIf
Else
	lRet := .F.
EndIf
Return lRet


	********************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360GFunc||Autor: Douglas Bichir||Data 08/01/2013|||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Chamada de execu��o automatica para gera��o de atendente||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: aFuncionar - Array com dados dos funcion�rios|||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	********************************************************************


Static Function At360GFunc(aFuncionar)
	Local aRotAuto := {}
	Local nCont	:= 0
	Private lMsErroAuto := .F.

	For nCont=1 To Len(aFuncionar)

		aAdd(aRotAuto,{"AA1_NOMTEC",aFuncionar[nCont,P_NOME],Nil})
		aAdd(aRotAuto,{"AA1_FUNCAO",aFuncionar[nCont,P_FUNCAO],Nil})
		aAdd(aRotAuto,{"AA1_CDFUNC",aFuncionar[nCont,P_MAT],Nil})
		aAdd(aRotAuto,{"AA1_FUNFIL",aFuncionar[nCont,P_FILIAL],Nil})
		aAdd(aRotAuto,{"AA1_CC",aFuncionar[nCont,P_CC],Nil})
		aAdd(aRotAuto,{"AA1_TURNO",aFuncionar[nCont,P_TURNO],Nil})

		TECA020(3,aRotAuto)

		If lMsErroAuto
			MostraErro()
			Exit
		EndIf

	Next nCont

Return lMsErroAuto


	********************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360GFunc||Autor: Douglas Bichir||Data 08/01/2013|||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Atualiza listbox atendente||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: aAtendente - Array com dados dos atendentes|||||||||*
 	*|||Par�metro: oLbxAtend - Objeto ListBox tela de Atendentes|||||||*
 	*|||Par�metro: cCusto - Array Centro de Custo||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	********************************************************************


Static Function At360Atndt(aAtendente, oLbxAtend,cCcusto)
aAtendente := At360Atend(cCcusto)

oLbxAtend:SetArray(aAtendente)
oLbxAtend:bLine	:= {||{aAtendente[oLbxAtend:nAt,P_CODATEND]				,;
							aAtendente[oLbxAtend:nAt,P_NOMEATEND]				,;
							aAtendente[oLbxAtend:nAt,P_FUNCAOATD]				,;
							X3Combo("AA1_ALOCA",aAtendente[oLbxAtend:nAt,P_ALOCA]),;
							X3Combo("AA1_TIPO",aAtendente[oLbxAtend:nAt,P_TIPOATEND])}}
oLbxAtend:Refresh()

Return( .T. )


	********************************************************************
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360GFunc||Autor: Douglas Bichir||Data 08/01/2013|||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Inclui Base de Atendimento no Contrato||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: cIdUnico - Id.Unico da Base de Atendimento||||||||||*
 	*|||Par�metro: cCodCli - C�digo do CLiente do Contrato|||||||||||||*
 	*|||Par�metro: nOpcA - Verificador se houve inclus�o|||||||||||||||*
 	*|||Par�metro: cContMnt - Contrato de Manuten��o|||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     |||||||||||||||||||||||||||||||||||||||||*
	*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	********************************************************************


Function At360IncCont(cIdUnico, cCodCli, nOpcA, cContMnt)
Local aArea		:= GetArea()

DbSelectArea("AA3")
DbSetOrder(6)
DbSeek(xFilial("AA3")+cIdUnico)
RecLock("AA3", .F.)
If AA3->AA3_CODCLI = cCodCli .AND. nOpcA = 1
	AA3->AA3_DTCTAM := dDataBase
	AA3->AA3_CONTRT := cContMnt
EndIf

MsUnlock()

RestInter()
RestArea(aArea)

Return (.T.)


	*********************************************************************
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|Programa: At360VldCt||Autor: Douglas Bichir||Data 10/01/2013||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*||Desc. Valida��o do bot�o avan�ar do painel Funcion�rio|||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
 	*|||Par�metro: aFuncionar - Array com Funcion�rios |||||||||||||||||*
 	*|||Par�metro: aAtendente - Array com Atendentes||||||||||||||||||||*
 	*|||Par�metro: oLbxFunc - Objeto ListBox Funcion�rio||||||||||||||||*
 	*|||Par�metro: oLbxAtend - Objeto ListBox Atendente|||||||||||||||||*
 	*|||Par�metro: cCcusto - Centro de Custo||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*|||     Uso: TECA360     ||||||||||||||||||||||||||||||||||||||||||*
	*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
	*********************************************************************


Static Function At360VldFc(aFuncionar, aAtendente, oLbxFunc, oLbxAtend, cCcusto)

If aFuncionar[1][1]<>""
	If MsgYesNo(STR0059,STR0048)//"Deseja tornar todos os novos funcion�rios em atendentes?"/"Aten��o"
		At360GFunc(aFuncionar)
	EndIf
EndIf
At360AtFnc(aFuncionar, oLbxFunc,cCcusto)
At360Atndt(aAtendente, oLbxAtend,cCcusto)
Return (.T.)*/