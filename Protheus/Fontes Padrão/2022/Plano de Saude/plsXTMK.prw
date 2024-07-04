#INCLUDE "PLSXTMK.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'

#define  K_Evolucao  	11 //9 -> Alterado de 9 pra 11 pois na passagem para a função, essa função tá na posição 11
#define __cTextoAll STR0001 //"*** Todos ***"
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7

Static oFnt10C 		:= TFont():New("Arial",10,10,,.F., , , , .T., .F.)
Static oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .T., .F.)
Static oFnt14N		:= TFont():New("Arial",18,18,,.T., , , , .T., .F.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsCallCenter  ºAutor  ³Henry Fila     º Data ³07/07/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de Integração Call x PLS.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsCallCenter(			oGetTmk 		,nOpc			,oFolderTmk		,oEnchTmk	,;
		cEncerra		,cMotivo		,oFolderTlv		,oEnchTlv	,;
		cCodPagto		,cDescPagto		,cCodTransp		,cTransp	,;
		cCob			,cEnt			,cCidadeC		,cCepC		,;
		cUfC			,cBairroE		,cBairroC		,cCidadeE	,;
		cCepE			,cUfE			,nLiquido		,nTxJuros	,;
		nTxDescon		,nVlJur			,aParcelas		,nEntrada	,;
		nFinanciado		,nNumParcelas	,nValorCC		,oCrono		,;
		cCrono			,nTimeSeg		,nTimeMin		,lHabilita	,;
		oFolderTlc		,oEnchTlc		,aColsTmk		,aColsTlv	,;
		oDlg			,cCodAnt		,aParScript		,l380		,;
		lMsg			,aSx3SUA		,cAgenda		,nValNFat	,;
		aSx3SUC			,aItens			,oCodPagto		,oDescPagto	,;
		oCodTransp		,oTransp		,oCob			,oEnt		,;
		oCidadeC		,oUfC			,oBairroE		,oCepC		,;
		oCidadeE		,oBairroC		,cCidadeE		,oCepE		,;
		oUfE			,oLiquido		,nTxJuros		,oTxJuros	,;
		oTxDescon		,oParcelas		,oEntrada		,oFinanciado,;
		oNumParcelas	,lTipo9			,oValNFat		,lSigaCRD)

	Local lRet		 := .T.
	Local aArea		 := GetArea()	// Salva a area atual
	Local aArSel	 := {}
	Local lEmpresa	 := .F.
	Local cTitulo	 := STR0002 //"Plano de Saúde"
	Local nOpcA		 := 0
	Local oDlgPls	 := Nil
	Local aButtons	 := {}

	Local oMenuAut	 := {}
	Local oMenuCar	 := {}
	Local oMenuCrt	 := {}

	Local cFilSC := "(BD6->BD6_FASE $ '1,2,3,4' .And. ( ( BD6->BD6_SITUAC = '1' ) .Or. ( BD6->BD6_SITUAC = '3' .And. BD6->BD6_LIBERA = '1' )  )  )"
	Local cFilHO := "(BE4->BE4_FASE $ '1,2,3,4' .And. BE4->BE4_SITUAC = '1')"

	Local bOk
	Local bCancel

	Local bBotMn1    := {|| oMenuAut:Activate(C(200,'1'),L(45),oDlgPls)}
	Local bBotMn2    := {|| oMenuCar:Activate(C(150,'2'),L(45),oDlgPls)}
	Local bBotMn3    := {|| oMenuCrt:Activate(C(350,'3'),L(45),oDlgPls)}
	Local nRecBa1    := 0
	Local nRecBTS    := 0

	Local aSlvAcols  := aCols
	Local aColsAux		:= {}
	Local aHeadAux		:= {}
	Local bBotFin    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		nRecBTS := BTS->(Recno()),;
		PLPOSFIN(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),.T.,.T.),;
		BA1->(DbGoTo(nRecBa1)),;
		BTS->(DbGoTo(nRecBTS)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('1')}
	Local bBotMov    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		aRet := PLSA730FAS(),;
		IIf(aRet[1],PLHISMOV(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),aRet[2],aRet[3],NIL,NIL,aRet[4]),.T.),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('2')}
	Local bBotCob    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSVLRCOB(,,.T.),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('3')}
	Local bBotCar    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSC005(),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('4')}
	Local bBotCla    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSVSCLACAR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('5')}
	Local bBotLib	 := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		DbSelectArea("BEA"),;
		inclui := .T.,;
		PLSA090MOV("BEA",0,K_Incluir,nil,nil,"2",.F.,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO ),nil,nil,nil,nil,nil,nil,nil,nil,cNumProTMK ),;
		BEA->(DbCloseArea()),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('6')}
	Local bBotAut    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		DbSelectArea("BEA"),;
		inclui := .T.,;
		PLSA090MOV("BEA",0,K_Incluir,nil,nil,"1",.F.,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO ),nil,nil,nil,nil,nil,nil,nil,nil,cNumProTMK ),;
		BEA->(DbCloseArea()),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('7')}
	Local bBotGih    := {|| aTela := {},;
		agets := {},;
		PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		DbSelectArea("BE4"),;
		inclui := .T.,;
		PLSA092Mov("BE4",0,K_Incluir,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO ),cNumProTMK),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('8')}
	Local bBotOdo    := {|| aTela := {},;
		agets := {},;
		PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		DbSelectArea("B01"),;
		inclui := .T.,;
		PLS090OMov("B01",0,K_Incluir,nil,nil,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO ) ,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cNumProTMK),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('9')}
	Local bBotFunAte := {|| aColsAux := aCols,;
		PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsFunAte(BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG, NIL, cNumProTMK),;
		aCols := aColsAux,;
		N	:= Len(aCols),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco(FindMAtB20())}
	Local bBotLbE    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsLibEsp(BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco("19")}
	Local bBotRDA    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsTmkOco('10'),;
		PLSTMKRDA( IIF(!Empty(BA1->BA1_CODPLA),BA1->BA1_CODPLA,BA3->BA3_CODPLA),IIF(!Empty(BA1->BA1_CODPLA),BA1->BA1_VERSAO,BA3->BA3_VERSAO)),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco("25")}
	Local bBotBol    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSTMKBOL(	 SA1->A1_COD,; //Cliente
		SA1->A1_LOJA,;//Loja
		BA1->BA1_CODINT,;//Operadora
		BA1->BA1_CODEMP),;//Empresa
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('11')}
	Local bBotCrt    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSTMKCRT(	BA1->BA1_CODINT,;//Operadora
		BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;//Matricula
		BA1->BA1_DTVLCR),;//Data de Validade do Cartão
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('12')}
	Local bBotVia    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSA261VIA(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),;//Matricula
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('13')}
	Local bBotAge    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSA300(	BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;// Matricula
		BA1->BA1_NOMUSR,;//Nome
		BA1->BA1_MATANT,;//MAtricula Antiga
		BA1->(BA1_DDD+BA1_TELEFO),;// DDD + Telefone
		BA1->BA1_RECNAS),;//Recem Nascido
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('14')}
	Local bBotConSol	:= {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSConSol(	BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),;// Matricula
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('25')}
	Local bBotResS	:= {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsResSen(,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('26')}
	Local bBotIndPre	:= {|| PLSTMKBOT("1"),;
		aSlvrotina := aClone(aRotina),;
		aRotina := {},;
		nRecBa1 := BA1->(Recno()),;
		PL809FBRW(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),;
		aRotina := aClone(aSlvrotina),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('27')}
	Local bBotRee    := {|| aTela := {},;
		agets := {},;
		PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		DbSelectArea("B44"),;
		inclui := .T.,;
		aSlvrotina := aClone(aRotina),;
		PL001MOV("B44",0,K_Incluir,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_TIPREG,BA1->BA1_DIGITO,Nil,cNumProTMK),;
		aRotina := aclone(aSlvrotina),;
		B44->(DbCloseArea()),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('28')}
	Local bBotProtRee := {|| aTela := {},; //Declarar sempre o aTela e aGets para não trazer campos da ultima tela aberta
		aGets := {},;
		PLSTMKBOT("1"),;
		aHeadAux := aHeader,;
		aColsAux := aCols,;
		nRecBa1 := BA1->(Recno()),;
		inclui := .T.,;
		aSlvrotina := aClone(aRotina),;
		PLBOWMOV("BOW",0,K_Incluir,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_TIPREG,BA1->BA1_DIGITO,.F.,cNumProTMK),;
		aHeader := aHeadAux,;
		aCols := aColsAux,;
		N	:= Len(aCols),;
		aRotina := aclone(aSlvrotina),;
		BA1->(DbGoTo(nRecBa1)),;
		BOW->(DbCloseArea()),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('29')}
	Local bBotAud    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		inclui := .T.,;
		aSlvrotina := aClone(aRotina),;
		PLSxTMKAUD(BA1->BA1_CODINT,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)),;
		aRotina := aclone(aSlvrotina),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('30')}
	Local bBotProAte	:= {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsTmkProA(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),cNumProTMK),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS),;
		PlsTmkOco('31')}
	Local bBotBlo    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLSTMKBLOQ(	BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;// Matricula
		BA1->BA1_NOMUSR,;
		cNumProTMK ),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotRee),;
		PlsTmkOco('37')}
	Local bBAudito	:= {||PLSA790V()}

	Local aPosObj    := {}
	Local aPosGet    := {}
	Local aObjects   := {}
	Local aInfo		 := {}
	Local aSize      := MsAdvSize( .F. )

	Local cCodCli  	 := ""
	Local cLojCli	 := ""
	Local cNivCob	 := ""
	Local cCodOpe 	 := ""
	Local cCodEmp 	 := ""
	Local cMatricUsr := ""
	Local cTiReg	 := ""
	Local cContrato  := ""
	Local cVerCon	 := ""
	Local cSubCon	 := ""
	Local cVerSub	 := ""
	Local cMatric	 := ""
	LOCAL cMatricBA1 := ""

	Local oObsMemo 	 := Nil
	Local cObsMemo   := ""
	Local oMonoAs  	 := TFont():New( "Courier New",6,0) 			// Fonte para o campo Memo

	Local nIndCob 	 := 0
	Local nLarCobDef := 0
	Local nLarCob 	 := 0

	Local nIndCad 	 := 0
	Local nLarCadDef := 0
	Local nLarCad 	 := 0
	Local lPainel	 := (nOpc = 4)
	Local lDisableA1 := .F.

	LOCAL aCliente := {}
	Local oBar
	LOCAL oFolder

	Local lSelEntF3	:= GetNewPar("MV_TMKF3",.F.)
	Local cTimeIni	:= Time()
	Local cTimeFim

	Local nSeg	:= 0
	Local nMin	:= 0
	LOCAL aRetPto := {}
	lOCAL oEncBA1
	Local i			:=1
	Local lInibTel :=.T.
	Local lHabAbaCob  	:= GetNewPar("MV_PLHBCOB",.T.)
	Local lHabAbaVen	:=.T.
	Local nOpcao := 4
	Local cNumProTMK  := Space(20)
	Local aBtn			:= {}

	Static  lGravaBTS	 := GetNewPar("MV_PGRVBTS",.T.) //Define se habilita digitação da aba Dados cadastrais  do BTS

	Private lPrim260 	:= .F.
	Private	oRazaoSo 	, cRazaoSo	:= Space(40)
	Private	oEndCon 	, cEndCon 	:= ""
	Private	oBaiCob 	, cBaiCob 	:= ""
	Private	oMunCob 	, cMunCob 	:= ""
	Private	oDesMun 	, cDesMun 	:= ""
	Private	oUfCob 		, cUfCob 	:= ""
	Private	oCepCob 	, cCepCob 	:= ""
	Private	oDddCob 	, cDddCob 	:= CriaVar("A1_DDD")
	Private	oFoneCob 	, cFoneCob 	:= CriaVar("A1_TEL")
	Private	oDiaVen		, nDiaVen	:= CriaVar("BA3_VENCTO")
	Private	aVetor	    := {}
	Private	aVetorAlt   := {}
	Private	bLin		:= "PlsLinVetor()"
	Private oTreeUsr	:= Nil
	Private oTreeCon	:= Nil
	Private oGetTmkPls	:= Nil
	Private	oLblUsr,oLblCon,oLblInf
	Private cCampBTS	:= ""
	Private cCampFld1	:= ""
	Private aCampFld1	:= {}
	Private	oNrEnder 	, cNrEnder	:= CriaVar("BA3_NUMERO")

	//Tratamento para abrir a tela com perfil de Prestador
	If (Type("M->UC_ENTIDAD") == "C" .and. M->UC_ENTIDAD == "BAU") .or. (Len(M->UC_CHAVE) == 6)
		PLSTMKPRE(ALLTRIM(M->UC_CHAVE), nOpc, nTimeMin, nTimeSeg, cCrono, oCrono, oEnchTmk)
		Return(.F.)
	EndIf

	If GetNewPar("MV_PLRN395","0") == "1" .And. SUC->(FieldPos("UC_PROTANS")) > 0
		If Empty(M->UC_MOTPLS)
			Aviso(STR0007,STR0175,{STR0012},2) //"Atenção"###"É necessário preencher o campo Motivo ANS"###"Voltar"
			Return(.F.)
		Else
			cNumProTMK := M->UC_PROTANS
		EndIf
	EndIf

	If !lGravaBTS
		lHabAbaVen := .F.
	Endif

	If nOpc = K_Visualizar
		Return(.F.)
	EndIf

	If ExistBLock("PLTKBTS")
		cCampBTS := ExecBlock("PLTKBTS",.F.,.F.)
	Else
		cCampBTS := GetNewPar("MV_PLTKBTS","BTS_NOMUSR,BTS_DATNAS,BTS_SEXO,BTS_ESTCIV,BTS_MAE,BTS_DRGUSR,BTS_CPFUSR,BTS_DDD,BTS_TELEFO,BTS_ENDERE,BTS_NR_END,BTS_COMEND,BTS_BAIRRO,BTS_MUNICI,BTS_ESTADO,BTS_CEPUSR,BTS_CODMUN,BTS_NOMTIT,BTS_SOBRTI,BTS_CPFTIT,BTS_MAILTI,BTS_DDDCEL,BTS_CELTIT,BTS_DDDTEL,BTS_TELTIT,BTS_CEPTIT,BTS_ENDTIT,BTS_NRENTI,BTS_COMTIT,BTS_BAITIT,BTS_CIDTIT,BTS_UFTIT ,BTS_MUNCTI,BTS_BANTIT,BTS_AGETIT,BTS_NUMTIT")
	EndIf

	If ExistBLock("PLSCALL")
		aRetPto := ExecBlock("PLSCALL",.F.,.F.,{M->UC_CHAVE,M->UC_ENTIDAD})
		If ! aRetPto[1]
			Return
		Else
			M->UC_CHAVE := aRetPto[2]
		Endif
	Endif

	AaDD(aRotina,{ "" , "" , 0 , K_Alterar    , 0, Nil})
	AaDD(aRotina,{ "" , "" , 0 , K_Excluir    , 0, Nil})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as variaveis chave.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFolder == 1 // TeleMarketing, Televendas ou Telecobranca


		If 	lSelEntF3
			BA1->(dbSetOrder(GetNewPar("MV_PLORDTM",2)))
		Else
			BA1->(dbSetOrder(1))
		EndIf
		BA3->(dbSetOrder(1))

		If BA1->( MsSeek( xFilial( "BA1" ) + M->UC_CHAVE ) ) .And.;
				BA3->( MsSeek( xFilial("BA3") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB ) ) )

			aCliente := PLSAVERNIV(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
				BA1->BA1_CONEMP,BA1->BA1_VERCON,BA1->BA1_SUBCON,BA1->BA1_VERSUB,Val(BA1->BA1_COBNIV),BA1->BA1_TIPREG,.F.)

			If Select("BTS") == 0
				dbSelectArea("BTS")
			EndIf
			BTS->(dbSetOrder(1))
			BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
			nRecBA1 := BA1->(Recno())
			nRecBTS := BTS->(Recno())

			If aCliente[1,1] <> "ZZZZZZ"
				cCodCli		:= aCliente[1][1]//BA1->BA1_CODCLI
				cLojCli		:= aCliente[1][2]//BA1->BA1_LOJA
				cRazaoSo	:= aCliente[1][3]
				cEndCon 	:= aCliente[1][4]
				cBaiCob 	:= aCliente[1][8]
				cMunCob 	:= aCliente[1][32]
				If Len(Alltrim(cMunCob))< 7
					cMunCob 	:= aCliente[1][5]
					cDesMun		:= Posicione("BID",2,xFilial("BID")+cMunCob,"BID_DESCRI")
					cMunCob		:=BID->BID_CODMUN
				Else
					cDesMun		:= Posicione("BID",1,xFilial("BID")+cMunCob,"BID_DESCRI")
				Endif
				cUfCob 		:= aCliente[1][6]
				cCepCob 	:= aCliente[1][10]

				If BA3->BA3_COBNIV =='1' // nivel da familia
					If BA3->BA3_ENDCOB ='2'  .and. lHabAbaCob
						lHabAbaCob:=.F.
					ElseIf BA3->BA3_ENDCOB ='3' .and. lHabAbaCob
						lInibTel   :=.F.
						lHabAbaCob :=.F.
					Endif
				Else
					DBSelectArea("BQC")
					BQC->(DbSetOrder(1)) // BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
					If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)))
						If BQC->BQC_COBNIV = '1' .AND. BA3->BA3_COBNIV <> '1' .and. lHabAbaCob
							lInibTel   :=.F.
							lHabAbaCob :=.F.
							lHabAbaVen :=.F.
						Endif
					EndIf
				Endif

				cFoneCob    :=  aCliente[1][11]
				cFoneCob	:= StrTran(cFoneCob," ","")
				cFoneCob	:= StrTran(cFoneCob,"-","")
				cFoneCob	:= StrTran(cFoneCob,"(","")
				cFoneCob	:= StrTran(cFoneCob,")","")

				If Len(cFoneCob)>1
					If SubStr(cFoneCob,1,1) == '0'
						cFoneCob := SubStr(cFoneCob,2,Len(cFoneCob))
					EndIf

					cDddCob 	:= SubStr(cFoneCob,1,2)
					cFoneCob 	:= SubStr(cFoneCob,3,Len(cFoneCob))
				EndIf

				nDiaVen		:= aCliente[1][16]
				cNivCob		:= aCliente[1][18]
				cCodOpe 	:= BA1->BA1_CODINT
				cCodEmp 	:= BA1->BA1_CODEMP
				cMatricUsr 	:= BA1->BA1_MATRIC
				cMatricBA1  := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
				cTipReg	    := BA1->BA1_TIPREG
				cContrato   := BA1->BA1_CONEMP
				cVerCon		:= BA1->BA1_VERCON
				cSubCon		:= BA1->BA1_SUBCON
				cVerSub		:= BA1->BA1_VERSUB
				cObsMemo    := M->UC_OBS
				cNrEnder	:= aCliente[1][31]
			Else
				MsgAlert(STR0006,STR0007) //"Não Encontrado Cliente nos níveis de Cobrança."###"Atenção"
				RestArea(aArea)
				Return(.F.)
			EndIf
		Else
			MsgAlert(STR0008,STR0007) //"Usuário ou Familia não encontrado"###"Atenção"
			RestArea(aArea)
			Return(.F.)

		Endif

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do PLS.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMatric	:= cCodOpe+cCodEmp+cContrato+cVerCon+cSubCon+cVerSub+cMatricUsr

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de Contrato.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lEmpresa := (AllTrim(Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp+"2","BG9->BG9_TIPO"))=="2")

	cTitulo 	:= cTitulo + " - " + cCodOpe + " " + cCodEmp + " " + cMatricUsr

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as variaveis com informacoes da cobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SA1")
	SA1->(DBSetOrder(1))
	If	SA1->(DBSeek(xFilial("SA1")+cCodCli+cLojCli))

		cBanco 		:= SA1->A1_BCO1
		cA1Email	:= SA1->A1_EMAIL

	Else
		MsgAlert(STR0010,STR0007) //"Cliente não encontrado."###"Atenção"
		RestArea(aArea)
		Return(.F.)
	EndIf

	RegToMemory( "SA1", .F., .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o conteudo original das variaveis de Cobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOldRazaoSo	:= cRazaoSo
	cOldEndCon 	:= cEndCon
	cOldBaiCob 	:= cBaiCob
	cOldMunCob 	:= cMunCob
	cOldUfCob 	:= cUfCob
	cOldCepCob 	:= cCepCob
	cOldDddCob 	:= cDddCob
	cOldFoneCob := cFoneCob
	nOldDiaVen	:= nDiaVen
	cOldcNrEnder:= cNrEnder

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize:= MsAdvSize( .T., .F., 400)
	aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 0 , 0 }
	aObjects:= {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 150, .T., .T. } )
	AAdd( aObjects, { 50, 100, .T., .T. } )

	aPosObj:= MsObjSize( aInfo, aObjects ,.T.)

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

	DEFINE MSDIALOG oDlgPls TITLE cTitulo FROM 000,000 to aSize[6],aSize[5] OF oMainWnd PIXEL //  COLOR CLR_BLACK , CLR_LIGHTGRAY // CLR_HRED

	//Sub Menu Botaão bBotMn1
	MENU oMenuAut POPUP
	MENUITEM STR0013 	ACTION Eval(bBotLib) //"&Liberaçao"
	MENUITEM STR0014 	ACTION Eval(bBotAut) //"&Autorização"
	MENUITEM STR0015 	ACTION Eval(bBotGih) //"&GIH"
	If GetNewPar("MV_PLATIOD","0") == "1"
		MENUITEM STR0016 		ACTION Eval(bBotOdo) //"&Odonto"
	EndIf
	MENUITEM STR0134	ACTION Eval(bBotFunAte) //""
	MENUITEM STR0135	ACTION Eval(bBotLbE) //Liberação Especial
	MENUITEM "Auditoria"	ACTION Eval(bBotAud) //Auditoria
	ENDMENU

	MENU oMenuCar POPUP
	MENUITEM STR0017 	ACTION Eval(bBotCar) //"&Procedimento"
	MENUITEM STR0018 	ACTION Eval(bBotCla) //"Classe Ca&renc."
	ENDMENU

	MENU oMenuCrt POPUP
	MENUITEM STR0019 	ACTION Eval(bBotCrt) //"&Emissão"
	MENUITEM STR0020 	ACTION Eval(bBotVia) //"Cons. V&ias"
	ENDMENU

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Blocos de codigo para a EnchoiceBar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bOk 		:= {|| Iif(lGravaBTS,fFreshMe("BTS",0,.F.),),IIf( fObrigatorio(lHabAbaCob),( nOpcA:=1, oDlgPls:End() ) , ) }
	bOkExclui 	:= {|| nOpcA:=1, oDlgPls:End() }
	bCancel 	:= {|| nOpcA:=0, oDlgPls:End() }

	DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlgPls

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta botoes                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aBtn,{"SALARIOS","SALARIOS"	,,,STR0021, bBotFin,.T.,oBar,,,STR0022+" < F4 >"}) //"Financeiro" //"Financ."###"Financeiro"
	aadd(aBtn,{"SUMARIO","SUMARIO"		,,,STR0023, bBotMov,.T.,oBar,,,STR0024+" < F5 >"}) //"Atendimentos" //"Movim."###"Atendimentos"
	aadd(aBtn,{"BUDGET","BUDGET"		,,,STR0025, bBotCob,.T.,oBar,,,STR0025+" < F6 >"}) //"Cobrança" //"Cobrança"###"Cobrança"
	aadd(aBtn,{"PENDENTE","PENDENTE"	,,,STR0026, bBotMn2,.T.,oBar,,,STR0026+" < F7 >"}) //"Carência" //"Carência"###"Carência"
	aadd(aBtn,{"PEDIDO","PEDIDO"		,,,STR0027, bBotMn1,.T.,oBar,,,STR0027+" < F8 >"}) //"Autorização" //"Guias"###"Guias"
	aadd(aBtn,{"BMPVISUAL","BMPVISUAL"	,,,STR0028, bBotRDA,.T.,oBar,,,STR0028+" < F9 >"}) //"Cons. RDA" //"Cons. RDA"###"Cons. RDA"
	aadd(aBtn,{"IMPRESSAO","IMPRESSAO"	,,,STR0029, bBotBol,.T.,oBar,,,STR0029+" < F10 >"}) //"V. Boleto" //"V. Boleto"###"V. Boleto"
	aadd(aBtn,{"ATALHO","ATALHO"		,,,STR0030, bBotMn3,.T.,oBar,,,STR0030+" < F11 >"}) //"Cartão" //"Cartão"###"Cartão"
	aadd(aBtn,{"BTCALEND","BTCALEND"	,,,STR0031, bBotAge,.T.,oBar,,,STR0031+" < F12 >"}) //"Agenda" //"Agenda"###"Agenda"
	aadd(aBtn,{"TCFIMG32","TCFIMG32"	,,,STR0269, bBotIndPre,.T.,oBar,,,STR0269 + " < Shift + F3 >"}) //"Indicação de Credenciamento"
	aadd(aBtn,{"SOLICITA","SOLICITA"	,,,STR0270,bBotConSol,.T.,oBar,,,STR0270 + " < Shift + F4 >"})//"Consultar solicitações"
	aadd(aBtn,{"SIMULACAO","SIMULACAO"	,,,STR0271, bBotProtRee,.T.,oBar,,,STR0271 + " < Shift + F5 >"}) //"Protocolo de reembolso"
	aadd(aBtn,{"CADEADO","CADEADO"	  	,,,STR0273, bBotResS,.T.,oBar,,,STR0273 + " < Shift + F7 >"}) //"Resetar senha"
	aadd(aBtn,{"NG_ICO_EXPORTAR_PROJECT","NG_ICO_EXPORTAR_PROJECT"	,,,STR0274, bBotProAte,.T.,oBar,,,STR0274 + " < Shift + F8 >"}) //"Resetar senha"
	aadd(aBtn,{"SELECTALL","SELECTALL" 	,,,STR0275, bBotAud,.T.,oBar,,,STR0275}) //"Auditoria"
	aadd(aBtn,{"AFASTAME","AFASTAME"	,,,"Bloqueio Plano", bBotBlo,.T.,oBar,,,"Solic. Bloqueio"}) //"Bloqueio Plano" //""Solic. Bloqueio""


	//NG_ICO_EXPORTAR_PROJECT NGICONOTE
	//RELATORIO_MDI.PNG
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para inclusão de botões na tela do plstmk  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLSTMKBUT")
		aBtn := ExecBlock("PLSTMKBUT",.F.,.F.,{aBtn, oBar})
	EndIf
	If Len(aBtn) > 0
		For i:=1 to Len(aBtn)
			// 1 - Tipo de botão
			// 2 - Descrição do botão
			// 3 - Função de usuário a ser executado  em bloco de código
			oBtn := TBtnBmp():NewBar( aBtn[I,1],aBtn[I,2],aBtn[I,3],aBtn[I,4],aBtn[I,5], aBtn[I,6],aBtn[I,7],aBtn[I,8],aBtn[I,9],aBtn[I,10],aBtn[I,11])
			PLSXButCap(oBtn)
		Next i
	Endif

	oBtn := TBtnBmp():NewBar( "OK","OK",,,"Ok", bOk,.T.,oBar,,,"Ok" )//OK
	oBtn:cTitle := "Ok"
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "CANCEL","CANCEL",,,STR0032 , bCancel,.T.,oBar,,,STR0032 )//SAIR //"Sair"###"Sair"
	oBtn:cTitle := STR0032 //"Sair"
	PLSXButCap(oBtn)

	cCampFld1 := StrTran(cCampBTS,",",'","')
	aCampFld1 := &('{"'+cCampFld1+'"}')  // 16

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Dados do Titular e Depedentes...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PlsTree( cMatric , oDlgPls , oTreeUsr , oTreeCon , aPosObj, cMatricBA1, aVetor)
	BA1->(dbGoTo(nRecBA1))//Familia com varios usuarios perde a referencia do ba1 e bts
	BTS->(dbGoTo(nRecBTS))

	If 	Len(aVetor)== 0
		Aviso(STR0007,STR0011,{STR0012},2) //"Atenção"###"Não foi encontrado as vidas dessa familia."###"Voltar"
		RestArea(aArea)
		Return()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apos posicionar no BA1, preencho as variaveis de momoria.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RegToMemory( "BQC", .F., .F.,.F.)
	RegToMemory( "BA1", .F., .F.,.F.)
	RegToMemory( "BTS", .F., .F.,.F.)

	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

	RegToMemory( "BA3", .F., .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados Cadastrais. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],{STR0033,STR0034},{"",""},oDlgPls,,,,.T.,.F.,(aPosObj[2,4]),aPosObj[2,3]) //"Dados &Usuário"###"&Dados Cliente"

	If lGravaBTS
		nOpcao := 4 //alterar
	else
		nOpcao := 2 //visualizar
	endif

	//oEncFld1 := TFolder():New(1,aPosObj[2,2],{"Dados Pessoais","Dados do Responsável Legal"},{"",""},oFolder:aDialogs[01],,,,.T.,.F.,(aPosObj[2,4]),aPosObj[2,3])
	oEncFld1 := MSMGet():New("BTS",,nOpcao,,,, aCampFld1,{1,aPosObj[2,2],(aPosObj[2,3]-105),(aPosObj[2,4]-5)},aCampFld1,,,,,oFolder:aDialogs[01],,,.F.,,.F.,.T.)

	fFreshMe("BTS")

	PLSTMKBOT("1",bBotFin,bBotMov,bBotCob,bBotMn2,bBotMn1,bBotRDA,bBotBol,bBotMn3,bBotAge,bBotCar,bBotCla,bBotLib,bBotAut,bBotGih,bBotOdo,bBotCrt,bBotVia,bBotFunAte,bBotLbE,bBotAut,bBotAud,bBotIndPre,bBotConSol,bBotProtRee,bBotRee,bBotResS,bBotProAte)

	SetKey(21   , {||oFolder:SetOption(1) })
	SetKey(4    , {||oFolder:SetOption(2) })

	nLarCadDef 	:= 506
	nLarCad 	:= aPosObj[2,4]
	nIndCad 	:= (nLarCad/nLarCadDef)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Linha 01:³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	nLin := 1//(aPosObj[2,1]+05)
	nCol := (aPosObj[2,2]+08)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados de Cobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nLarCobDef 	:= 379.5 - 06
	nLarCob 	:= 3*((aPosObj[2,4]/4)-06)
	nIndCob		:= (nLarCob/nLarCobDef)

	nLin := 1
	nCol := (aPosObj[2,2]+08)

	@ nLin+000,nCol		SAY STR0056 		SIZE 050,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Razão Social"
	@ nLin+008,nCol		MSGET 	oRazaoSo 			Var cRazaoSo;
		PICTURE PesqPict("SA1","A1_NOME") ;
		PIXEL SIZE 140*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]

	nCol += (140*nIndCob)+05
	@ nLin+000,nCol		SAY STR0045 		SIZE 030,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Cep"
	@ nLin+008,nCol		MSGET oCepCob 		Var cCepCob ;
		PICTURE PesqPict("SA1","A1_CEP") ;
		F3 	CpoRetF3("BA1_CEPUSR") ;
		VALID ( fUpdEnde( 1 , cCepCob,@cEndCon,@cBaiCob,@cMunCob,@cUfCob,@cDesMun));
		PIXEL SIZE 050*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]


	nCol += (050*nIndCob)+05
	@ nLin+000,nCol		SAY STR0046 			SIZE 050,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Endereço"
	@ nLin+008,nCol		MSGET 	oEndCon 			Var cEndCon;
		PICTURE PesqPict("SA1","A1_END") ;
		PIXEL SIZE 140*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]


	nCol += (140*nIndCob)+05
	@ nLin+000,nCol		SAY STR0047			SIZE 050,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Numero
	@ nLin+008,nCol		MSGET 	oNrEnder 			Var cNrEnder;
		PICTURE PesqPict("BA3","BA3_NUMERO") ;
		PIXEL SIZE 020*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Linha 02:³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	nLin += 20
	nCol := (aPosObj[3,2]+08)

	@ nLin+000,nCol		SAY 	STR0049 	SIZE 050,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Bairro"
	@ nLin+008,nCol		MSGET 	oBaiCob 	Var cBaiCob;
		PICTURE PesqPict("SA1","A1_BAIRRO") ;
		PIXEL SIZE 080*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]

	nCol += (080*nIndCob)+05
	@ nLin+000,nCol		SAY 	STR0050 	SIZE 030,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Cidade"
	@ nLin+008,nCol		MSGET 	oMunCob 	Var cMunCob ;
		PICTURE PesqPict("SA1","A1_MUN") ;
		F3 		CpoRetF3("BQC_CODMUN") ;
		VALID (fUpdEnde( 3 , nil,nil,nil,cMunCob,nil,@cDesMun) );
		PIXEL SIZE 040*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]

	nCol += (040*nIndCob)+05
	@ nLin+010,nCol		SAY  	oDesMun 	Prompt cDesMun ;
		COLOR CLR_HBLUE;
		PIXEL SIZE 095*nIndCob,009;
		OF oFolder:aDialogs[02]

	nCol += (095*nIndCob)+05
	@ nLin+000,nCol		SAY STR0051 	SIZE 030,009 PIXEL COLOR CLR_HBLUE OF oFolder:aDialogs[02]//OF oDlgPls //"Estado"
	@ nLin+008,nCol		MSGET 	oUfCob 	Var cUfCob ;
		PICTURE PesqPict("SA1","A1_EST") ;
		F3 		CpoRetF3("A1_EST") ;
		PIXEL 	SIZE 020*nIndCob,009;
		When lHabAbaCob;
		OF oFolder:aDialogs[02]

	nCol += (020*nIndCob)+05
	@ nLin+000,nCol		SAY STR0052 SIZE 080,009 	PIXEL COLOR CLR_BLACK OF oFolder:aDialogs[02]//OF oDlgPls //"DDD"
	@ nLin+008,nCol		MSGET oDddCob	 			Var cDddCob ;
		PICTURE "99" ;
		PIXEL SIZE 030*nIndCob,009;
		When lHabAbaCob .and. lInibTel;
		OF oFolder:aDialogs[02]

	nCol += (030*nIndCob)+03
	@ nLin+000,nCol		SAY STR0053 SIZE 080,009 PIXEL COLOR CLR_BLACK OF oFolder:aDialogs[02]//OF oDlgPls //"Fone Residencial"
	@ nLin+008,nCol		MSGET oFoneCob 			Var cFoneCob ;
		PICTURE PesqPict("BQC","BQC_TEL") ;
		PIXEL SIZE 050*nIndCob,009;
		When lHabAbaCob .and. lInibTel;
		OF oFolder:aDialogs[02]

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Linha 03:³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	nLin += 20
	nCol := (aPosObj[3,2]+08)

	@ nLin+000,nCol		SAY STR0057 	SIZE 050,009 PIXEL COLOR CLR_BLACK OF oFolder:aDialogs[02]//OF oDlgPls //"Vencto"
	@ nLin+008,nCol		MSGET oDiaVen 	Var nDiaVen ;
		PICTURE PesqPict("BA3","BA3_VENCTO") ;
		PIXEL SIZE 020*nIndCob,009;
		When lHabAbaVen ;
		Valid(nDiaVen>=1 .and. nDiaVen<=31);
		OF oFolder:aDialogs[02]

	aEdit := {}

	AEval(aHeader, {|x| IIF(x[2]<>"CHECKBOX",AAdd(aEdit,x[2]),"")})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observacao das ocorrencias.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetTmkPls := MSGetDados():New(aPosObj[3,1]+26,aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],nOpc,"AllwaysTrue","AllwaysTrue","",.T.,aEdit,,,,,,,,oDlgPls)
	oGetTmkPls:OBROWSE:BADD := { || oGetTmkPls:LCHGFIELD := .F. ,oGetTmkPls:ADDLINE(),PlAfterAdd(aHeader, aCols)}

	ACTIVATE MSDIALOG oDlgPls

	If ( nOpcA == 1 ) .And. nOpc > 2

		lRet := fGrava( cCodCli ,;
			cLojCli ,;
			cMatric ,;
			lEmpresa ,;
			cCodOpe ,;
			cCodEmp ,;
			cMatricUsr ,;
			cContrato ,;
			cVerCon ,;
			cSubCon ,;
			cVerSub,;
			cNivCob,;
			cTipReg,;
			aCliente,;
			lHabAbaCob )

		If	MsgNoYes(STR0058)  //"Deseja Finalizar o Atendimento"

			If Empty(M->UC_OPERACA)
				M->UC_OPERACA := '2'
			EndIf

			If Empty(M->UC_STATUS)
				nPos := Ascan(aCols,{|x| x[PLRETPOS("UD_STATUS",aHeader)] $ ' ,1'})
				M->UC_STATUS := Iif( nPos > 0 , '2' , '3' )
			EndIf

			lRet := Tk271Grava(	@nOpc          	,@oFolderTmk	,@nTimeSeg		,@nTimeMin   	,;
				@oCrono        	,@cCrono        ,@oEnchTmk      ,@cMotivo    	,;
				@cEncerra      	,@oFolderTlv    ,@oEnchTlv      ,@cCodPagto  	,;
				@cDescPagto    	,@cCodTransp    ,@cTransp       ,@cCob       	,;
				@cEnt          	,@cCidadeC      ,@cCepC         ,@cUfC       	,;
				@cBairroE      	,@cBairroC      ,@cCidadeE      ,@cCepE      	,;
				@cUfE          	,@nLiquido      ,@nTxJuros      ,@nTxDescon  	,;
				@nVlJur        	,@aParcelas     ,@nEntrada      ,@nFinanciado	,;
				@nNumParcelas  	,@nValorCC      ,@lHabilita     ,@oFolderTlc 	,;
				@oEnchTlc      	,aColsTmk       ,aColsTlv       ,@oDlgPls       	,;
				@cCodAnt       	,aParScript		,l380			,@lMsg		 	,;
				aSx3SUA			,cAgenda		,nValNFat		,aSx3SUC	 	,;
				@aItens			,oCodPagto		,@oDescPagto	,@oCodTransp 	,;
				@oTransp		,@oCob			,@oEnt			,@oCidadeC	 	,;
				@oUfC			,@oBairroE		,@oCepC			,@oCidadeE		,;
				@oBairroC		,@cCidadeE	 	,@oCepE			,@oUfE			,;
				@oLiquido		,@nTxJuros	 	,@oTxJuros		,@oTxDescon		,;
				@oParcelas		,@oEntrada	 	,@oFinanciado	,@oNumParcelas	,;
				@lTipo9			,@oValNFat		,Nil			,Nil			,;
				lSigaCRD)
		EndIf

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso a tela seja cancelada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet 	:= .F.

		If nOpca = 0
			aCols 	:= aSlvAcols
		EndIf

	EndIf
	//restaura botoes
	PLSTMKBOT("1")

	SetKey(21   , { || AllWaysTrue() })
	SetKey(4    , { || AllWaysTrue() })

	cTimeFim := Time()
	nMin := Val(SubStr(ElapTime(cTimeIni,cTimeFim),4,2))
	nSeg := Val(SubStr(ElapTime(cTimeIni,cTimeFim),7,2))

	nTimeMin += nMin
	nTimeSeg += nSeg

	PLSTKAtuCro(	@nTimeSeg	,@nTimeMin	,"00:00"	,@cCrono	,	@oCrono		)

	RestArea(aArea)
	oEnchTmk:Refresh()


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsTree   ºAutor  ³Paulo Sampaio       º Data ³ 20/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o DBTree.                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsTREE( cMatric , oDlgPls , oTreeUsr , oTreeCnt , aPosObj, cMatricBA1, aVetor )
	LOCAL nInd	 	:= 0
	LOCAL nI		:= 0
	LOCAL aRetCli 	:= {}
	LOCAL acCodCli	:= {}
	LOCAL acLoja	:= {}
	LOCAL anInd		:= {}
	LOCAL aRetPtoEnt := {}
	LOCAL cQuery 	:= ""
	LOCAL cCamp		:= ""
	LOCAL cAliasPesq	:= ""
	LOCAL cCargoSeek := ""
	LOCAL cUsTit	:=  SuperGetMV("MV_PLCDTIT")
	LOCAL cCodPla  	:= BA3->BA3_CODPLA
	LOCAL cVersao  	:= BA3->BA3_VERSAO
	LOCAL cCodPlaBA1 := BA1->BA1_CODPLA
	LOCAL cVersaoBA1 := BA1->BA1_VERSAO
	LOCAL aDadUsr    	:= PLSDADUSR(cMatricBA1,"1",.F.,dDataBase)
	LOCAL lPLTMKBA1  := ExistBlock("PLTMKBA1")

	If ExistBlock("PLSXRGCP")
		aRetPtoEnt := ExecBlock("PLSXRGCP",.F.,.F.,{cCodPla,cVersao,cCodPlaBA1,cVersaoBA1,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)})
		cCodPla    := aRetPtoEnt[1]
		cVersao    := aRetPtoEnt[2]
		cCodPlaBA1 := aRetPtoEnt[3]
		cVersaoBA1 := aRetPtoEnt[4]
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o DBTree do Contrato.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@aPosObj[1,1]+5,aPosObj[1,2] TO aPosObj[1,3] , ((aPosObj[1,4])/2) LABEL STR0059 COLOR CLR_HBLUE  OF oDlgPls PIXEL // LABEL "Legenda"  //"Informações do Cliente"

	oTreeCon := XTree():New((aPosObj[1,1]+15),(aPosObj[1,2]+2),(aPosObj[1,3]-2),((aPosObj[1,4]/2)-2),oDlgPls,/*uChange*/,{||M100Edit(oTreeCon:GetCargo())},/*bDblClick*/)
	oTreeCon:BeginUpdate()
	oTreeCon:Reset()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta DbTree para o Contrato...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("BT5")
	BT5->(DBSetOrder(1)) // BT5_FILIAL + BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
	If BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON)))
		oTreeCon:AddTree(LEFT(STR0060+BT5->BT5_NUMCON+" - "+BT5->BT5_NOME+Space(100),100),"EDITABLE","EDITABLE",	"BT5/"+StrZero(BT5->(Recno()),6)+"/Contrato",/*bAction*/,/*bRClick*/,/*bDblClick*/)

		oTreeCon:AddTreeItem(STR0061+Iif(BT5->BT5_INTERC = '1',STR0062,STR0063),"EDITABLE","BT5/"+StrZero(BT5->(Recno()),6)+"/Contrato")
		oTreeCon:AddTreeItem(STR0064+IIF(BT5->BT5_MODPAG = '1',STR0065,STR0066),"EDITABLE","BT5/"+StrZero(BT5->(Recno()),6)+"/Contrato")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta DbTree para o Sub-Contrato...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("BQC")
		BQC->(DbSetOrder(1)) // BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
		If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)))
			oTreeCon:EndTree()

			oTreeCon:AddTree(LEFT(STR0067+BQC->BQC_NUMCON+" - "+BQC->BQC_DESCRI+Space(100),100),"EDITABLE","EDITABLE","BQC/"+StrZero(BQC->(Recno()),6)+"/Sub-Contrato",/*bAction*/,/*bRClick*/,/*bDblClick*/)
			oTreeCon:EndTree()
		else
			oTreeCon:EndTree()
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta DbTree para o plano de saude...                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistBlock("PLSTMKT1")
		BI3->(DbSetOrder(1))
		If BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cCodPla+cVersao))
			oTreeCon:AddTree(LEFT(STR0068+cCodPla+STR0069+cVersao+" - "+BI3->BI3_DESCRI+Space(100),100),"PLNPROP","PLNPROP","BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saúde",/*bAction*/,/*bRClick*/,/*bDblClick*/)

			oTreeCon:AddTreeItem(STR0070+IIF(BI3->BI3_APOSRG = '1',STR0062,STR0063),"PLNPROP","BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saúde")
			oTreeCon:AddTreeItem(STR0071+Posicione("BI4",1,xFilial("BI4")+BI3->BI3_CODACO,"BI4->BI4_DESCRI"),"PLNPROP","BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saúde")
			oTreeCon:AddTreeItem(STR0072+Posicione("BI6",1,xFilial("BI6")+BI3->BI3_CODSEG,"BI6->BI6_DESCRI"),"PLNPROP","BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saúde")
			oTreeCon:AddTreeItem(STR0073+Posicione("BF7",1,xFilial("BF7")+BI3->BI3_ABRANG,"BF7->BF7_DESORI"),"PLNPROP","BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saúde")

			oTreeCon:EndTree()
		EndIf
	Else
		ExecBlock("PLSTMKT1",.F.,.F.,{oTreeCon,cMatricBA1,cCodPla,cVersao,cCodPlaBA1,cVersaoBA1})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta DbTree para o cliente...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetCli := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,Val(BA1->BA1_COBNIV),BA1->BA1_TIPREG)

	If aRetCli[1,1] <> "ZZZZZZ"

		cCodCli := aRetCli[1,1]
		cLoja   := aRetCli[1,2]
		DBSelectArea("SA1")
		SA1->(DBSetOrder(1))
		SA1->(DBSeek(xFilial("SA1")+cCodCli+cLoja))
		cNome   := SA1->A1_NOME
		cFisJur := SA1->A1_PESSOA

		oTreeCon:AddTree(Left(STR0074+Space(050),050),"RESPONSA",/*cResource2*/,"SA1/"+StrZero(SA1->(Recno()),6)+"/Cliente",/*bAction*/,/*bRClick*/,/*bDblClick*/)

		oTreeCon:AddTreeItem(cCodCli+"-"+cLoja+"   -   "+cNome+STR0075+cFisJur,"RESPONSA","SA1/"+StrZero(SA1->(Recno()),6)+"/Cliente")

		oTreeCon:EndTree()

	EndIf
	oTreeCon:EndUpdate()
	oTreeCon:Refresh()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o DBTree do usuario. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@aPosObj[1,1]+5,((aPosObj[1,4])/2) TO aPosObj[1,3], aPosObj[1,4] LABEL STR0076  COLOR CLR_HBLUE OF oDlgPls PIXEL // LABEL "Legenda"  //"Usuário(s)"

	DEFINE DBTREE oTreeUsr FROM (@aPosObj[1,1]+5),(((aPosObj[1,4])/2)+2) TO (aPosObj[1,3]-2), (aPosObj[1,4]-2) CARGO OF oDlgPls ON CHANGE fChange(oTreeUsr:GetCargo())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta DbTree para o titular e seus depedentes...                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! ExistBlock("PLSTMKT2")
		BA1->(DbSetOrder(13))
		BTS->(DbSetOrder(1))
		If BA1->(MsSeek(xFilial("BA1")+cMatric))

			While !BA1->(Eof()) .And. BA1->(BA1_CODINT + BA1_CODEMP + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB + BA1_MATRIC) == cMatric
				cCodPlaBA1 := BA1->BA1_CODPLA
				cVersaoBA1 := BA1->BA1_VERSAO

				If cMatricBA1 == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
					cCargoSeek := "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário"
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta DbTree de acordo com bloqueio/desbloqueio...                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If	BA1->BA1_TIPUSU == cUsTit
					DBADDTREE oTreeUsr PROMPT "("+BA1->BA1_TIPUSU+")-"+BA1->BA1_NOMUSR+"("+AllTrim(Str(DateDiffYear(dDataBase,BA1->BA1_DATNAS),3))+")"+Space(150) RESOURCE "GROUP"       CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario"
				Else
					DBADDTREE oTreeUsr PROMPT "("+BA1->BA1_TIPUSU+")-"+BA1->BA1_NOMUSR+"("+AllTrim(Str(DateDiffYear(dDataBase,BA1->BA1_DATNAS),3))+")"+Space(150) RESOURCE "DEPENDENTES" CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario" //
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se Bloquado exibe Data de Bloqueio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(BA1->BA1_DATBLO)
					BCA->(DbSetOrder(1))
					If BCA->(Dbseek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+dtos(BA1->BA1_DATBLO)+"0"))

						If BCA->BCA_NIVBLQ == "S"	   //Bloqueio por SubContrato
							cAliasPesq := "BQU"
						ElseIf BCA->BCA_NIVBLQ == "F" //Bloqueio por Familia
							cAliasPesq := "BG1"
						ElseIf BCA->BCA_NIVBLQ == "U" //Bloqueio por Usuario
							cAliasPesq := "BG3"
						EndIf

						_cTexto := STR0078+dtoc(BA1->BA1_DATBLO)+STR0079+BA1->BA1_MOTBLO+" "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA1->BA1_MOTBLO,cAliasPesq+"_DESBLO") //"Data Bloqueio:"###"  Motivo:"

						DBADDITEM oTreeUsr PROMPT  _cTexto  RESOURCE "BMPEMERG"  CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario"
					Endif
				ElseIf !Empty(BA3->BA3_DATBLO)
					BC3->(DbSetOrder(1))
					If BC3->(Dbseek(xFilial("BC3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+dtos(BA3->BA3_DATBLO)+"0"))

						If BC3->BC3_NIVBLQ == "S"	   //Bloqueio por SubContrato
							cAliasPesq := "BQU"
						ElseIf BC3->BC3_NIVBLQ == "F" //Bloqueio por Familia
							cAliasPesq := "BG1"
						ElseIf BC3->BC3_NIVBLQ == "U" //Bloqueio por Usuario
							cAliasPesq := "BG3"
						EndIf

						_cTexto := STR0078+dtoc(BA3->BA3_DATBLO)+STR0079+BA3->BA3_MOTBLO+" "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA3->BA3_MOTBLO,cAliasPesq+"_DESBLO") //"Data Bloqueio:"###"  Motivo:"
						DBADDITEM oTreeUsr PROMPT  _cTexto  RESOURCE "BMPEMERG"  CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario"
					Endif
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Exibe Data de Inclusao e Vigencia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//oTreeUsr:AddTreeItem(STR0080+DtoC(BA1->BA1_DTVLCR)+STR0081+DtoC(BA1->BA1_DATINC), RESOURCE "NOTE" CARGO,"BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário")
				DBADDITEM oTreeUsr PROMPT  STR0080+DtoC(BA1->BA1_DTVLCR)+STR0081+DtoC(BA1->BA1_DATINC)  RESOURCE "NOTE"  CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario" //"Data Validade Carterinha: "###"      Data Inclusao:"

				If !Empty(cCodPlaBA1)
					DBADDITEM oTreeUsr PROMPT STR0082+cCodPlaBA1+STR0069+cVersaoBA1 RESOURCE "PLNPROP"  CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuário" //"/Usuario" //"Produto do Usuário - "###" Versão - "
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta opcionais do plano para o usuario...                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT BF4_CODPRO, BF4_VERSAO, BF4_TIPVIN, BF4_MOTBLO, BI3_DESCRI "
				cQuery += " FROM " + RetSqlName("BF4")+ " BF4 , "
				cQuery += RetSqlName("BI3") + " BI3 "
				cQuery += " WHERE "
				cQuery += " BF4_FILIAL = '" + xFilial("BF4") + "' AND "
				cQuery += " BF4_CODINT = '" + BA1->BA1_CODINT + "' AND "
				cQuery += " BF4_CODEMP = '" + BA1->BA1_CODEMP + "' AND "
				cQuery += " BF4_MATRIC = '" + BA1->BA1_MATRIC + "' AND "
				cQuery += " BF4_TIPREG = '" + BA1->BA1_TIPREG + "' AND "
				cQuery += " BF4_CODPRO <> '" + Space(Len(BF4->BF4_CODPRO ) ) + "' AND "
				cQuery += " BF4_VERSAO <> '" + Space(Len(BF4->BF4_VERSAO ) ) + "' AND "
				cQuery += " BF4.D_E_L_E_T_ = ' ' AND "
				cQuery += " BI3_FILIAL = '" + xFilial("BI3") + "' AND "
				cQuery += " BI3_CODINT = BF4_CODINT AND "
				cQuery += " BI3_CODIGO = BF4_CODPRO AND "
				cQuery += " BI3_VERSAO = BF4_VERSAO AND "
				cQuery += " BI3.D_E_L_E_T_ = ' '"
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBF4",.F.,.T.)

				If !TRBBF4->(EOF())
					DBADDTREE oTreeUsr PROMPT STR0083+Space(300) RESOURCE "PLNPROP" CARGO "BA1/"+StrZero(BA1->(Recno()),10)+"/Usuario"          //"Opcionais "###"/Usuario" //"Opcionais "

					While !TRBBF4->(EOF())
						DBADDITEM oTreeUsr PROMPT 	TRBBF4->BF4_CODPRO+" - "+;
							TRBBF4->BF4_VERSAO+" - "+;
							TRBBF4->BI3_DESCRI+;
							"Vinculado - "+IIf(TRBBF4->BF4_TIPVIN <> "1","NÃO","SIM")  +;
							"  Bloqueado - "+IIf(Empty(BF4_MOTBLO),"NÃO","SIM") CARGO " "
						TRBBF4->(DbSkip())
					EndDo
					DBENDTREE oTreeUsr
				EndIf
				TRBBF4->(DbCloseArea())

				If BTS->(DbSeek(xFilial("BTS")+BA1->BA1_MATVID))
					cCamp := StrTran(cCampBTS,",",",BTS->")
					&("AADD(aVetor, {BTS->"+cCamp+",ddatabase,BA1->(Recno())} )")
				EndIf

				If lPLTMKBA1
					aVetor := ExecBlock("PLTMKBA1",.F.,.F.,{aVetor,cMatric})
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena os valores originais.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aVetorAlt := aClone(aVetor)

				BA1->(DbSkip())
				DBENDTREE oTreeUsr
			Enddo
		Endif
	Else
		aVetor := ExecBlock("PLSTMKT2",.F.,.F.,{oTreeUsr,cMatricBA1,cCodPla,cVersao,cCodPlaBA1,cVersaoBA1,aVetor})
	Endif

	DBENDTREE oTreeUsr
	oTreeUsr:TreeSeek(cCargoSeek)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois do laco no BA1, eu posiciono a tabela novamente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->(DbSetOrder(13))//BA1_FILIAL, BA1_OPEDES, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG
	BA1->(MsSeek(xFilial("BA1")+cMatric))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim da Rotina...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fChange   ºAutor  ³Paulo Sampaio       º Data ³ 15/03/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza informacoes referente ao usuario selecionado no    º±±
±±º          ³DBTree.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fChange(cCargo)

	Local cAlias	:= ""
	Local nRecno	:= 0
	Local nRecOld	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa conteudo do parametro...                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCargo)
		Return()
	EndIf

	cAlias  := Subs(cCargo,1,3)
	nRecno  := Val(Subs(cCargo,5,10))
	nRecOld := &(cAlias+"->(Recno())")

	DBSelectArea(cAlias)
	DBGoTo(nRecno)

	If cAlias == "BA1"
		BTS->(DbSetOrder(1))
		BTS->(DbSeek(xFilial("BTS")+BA1->BA1_MATVID))
	EndIf

	fFreshMe("BTS",nRecOld)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fFreshMe  ºAutor  ³Paulo Sampaio       º Data ³ 15/03/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os M-> do BA1 posicionado.						  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fFreshMe(cAlias,nRecOld,lRfresh,lAltVet)
	Local i,nI,x,nX	:= 0
	Local aStruTB	:= &(cAlias+"->(DbStruct())")
	Local nPosRec	:= Len(aVetor[1])
	Local lRet		:= .T.
	Default	nRecOld := 0
	Default	lRfresh := .T.
	Default lAltVet	:= .F.

	If cAlias == "BTS"

		If lRfresh .and. !Obrigatorio(oEncFld1:aGets,oEncFld1:aTela)
			lRet := .F.
		EndIf

		nI := aScan(aVetor,{ |x| x[nPosRec] = BA1->(Recno()) })
		If nRecOld > 0
			nX 		:= aScan(aVetor,{ |x| x[nPosRec] = nRecOld })
			lAltVet	:= .T.
		Else
			nX := nI
		EndIf

		If nX > 0 .And. lGravaBTS
			For x:=1 to Len(aCampFld1)
				If lAltVet
					aVetor[nX,x] := &("M->"+aCampFld1[x])
				EndIf
				If nI > 0
					&("M->"+aCampFld1[x]) :=  aVetor[nI,x]
				Endif
			Next
		Endif

		If lRfresh
			oEncFld1:Refresh()
		EndIf

	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fUpdEnde  ºAutor  ³Paulo Sampaio       º Data ³ 20/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o endereco de acordo com o Cep selecionado.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fUpdEnde( nLabel , cCep,cEndere,cBairro,cMunicipio,cEstado,cDesMunicipio)

	Local 	lRet := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao mudou o valor original do cep, nao aparecer a tela de confirmacao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If		nLabel = 1 .And. (cOldCepCob == cCepCob  .Or. Empty(cCep))
		Return(.T.)
	ElseIf	nLabel = 2 .And.( aVetor[&bLin][20] == aVetorAlt[&bLin][20]  .Or. Empty(cCep))
		Return(.T.)
	EndIf

	If nLabel = 3
		cDesMunicipio:= Posicione("BID",1,xFilial("BID")+cMunicipio,"BID_DESCRI")
		lRet := .T.
	Else
		If	MsgNoYes(STR0087+ CRLF+; //"Deseja atualizar os campos abaixo: "
				STR0045 + CRLF+; //"Cep"
				STR0046 + CRLF+; //"Endereço"
				STR0049  + CRLF+; //"Bairro"
				STR0088  + CRLF+; //"Município"
				STR0051,STR0089 ) //"Estado"###"Atualização de Cep"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na tabela de CEP.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea("BC9")
			BC9->(DBSetOrder(1)) // BC9_FILIAL + BC9_CEP
			If	BC9->(MsSeek(xFilial("BC9")+cCep))
				cEndere		 := BC9->BC9_END
				cBairro		 := BC9->BC9_BAIRRO
				cDesMunicipio:= BC9->BC9_MUN
				cEstado		 := BC9->BC9_EST
				cMunCob		 := BC9->BC9_CODMUN
			EndIf

		EndIf
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fGrava    ºAutor  ³Paulo Sampaio       º Data ³ 20/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza informacoes referente ao usuario selecionado no    º±±
±±º          ³DBTree.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrava( cCodCli , cLojCli , cMatric , lEmpresa , cCodOpe , cCodEmp ,;
		cMatricUsr , cContrato , cVerCon , cSubCon , cVerSub, cNivCob, cTipReg, aCliente, lHabAbaCob )
	Local 	lRet			:= .T.
	Local 	lCart			:= .F.
	Local 	cCampo			:= ""
	Local 	lInterCambio 	:= .F. 		// Verifica se houve alteracao de municipio.
	Local 	aCpoSUD			:= {}
	Local 	cLogin 			:= ""
	Local 	nL				:= 0
	Local 	nI				:= 0
	Local	x				:= 0
	Local	i				:= 0
	Local	cContato		:= ""
	Local 	cAlias			:= ""
	Local	lAlt			:= .F.
	Local	aStruSA1		:= SA1->(DbStruct())
	Local	aStruBA1		:= BA1->(DbStruct())
	Local	aStruBA3		:= BA3->(DbStruct())
	Local	aStruBQC		:= BQC->(DbStruct())
	Local	aStruBTS		:= BTS->(DbStruct())
	Local	aStruSU5		:= SU5->(DbStruct())
	Local   cUsTit			:= SuperGetMV("MV_PLCDTIT")
	Local   nOldRecBA1      := 0
	LOCAL   aRetPto         := {}
	Local	lDadosCobAlt	:=.F.
	Local 	cCpoNaoAtu		:= "BTS_ORIEND"
	Local   lAtuCad         := GetNewPar("MV_PLGRTMK",.T.)
	Local   lPLSTMKCT       := ExistBLock("PLSTMKCT")

	BA3->(DbSetOrder(1))
	BA1->(DbSetOrder(1))
	BQC->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+cCodOpe+cCodEmp+cMatricUsr+cContrato+cVerCon+cSubCon+cVerSub))
	BQC->(DbSeek(xFilial("BQC")+cCodOpe+cCodEmp+cContrato+cVerCon+cSubCon+cVerSub))

	If 	cOldRazaoSo	<> cRazaoSo .OR.;
			cOldEndCon 	<> cEndCon .OR.;
			cOldBaiCob 	<> cBaiCob .OR.;
			cOldMunCob 	<> cMunCob .OR.;
			cOldUfCob 	<> cUfCob .OR.;
			cOldCepCob 	<> cCepCob .OR.;
			cOldDddCob 	<> cDddCob .OR.;
			cOldFoneCob <> cFoneCob .OR. ;
			cOldcNrEnder<> cNrEnder

		lDadosCobAlt:=.T.


	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BQC ou BA3 - Dia do Vencimento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If	nOldDiaVen	!= nDiaVen // Se o dia de vencimento foi alterado.        €

		If	cNivCob = '1'

			cAlias := "BG9"
			cChave := cCodOpe+cCodEmp

		ElseIf cNivCob = '2'

			cAlias := "BT5"
			cChave := cCodOpe + cCodEmp + cContrato + cVerCon

		ElseIf cNivCob = '3'

			cAlias := "BQC"
			cChave := cCodOpe + cCodEmp + cContrato + cVerCon + cSubCon + cVerSub

		ElseIf cNivCob = '4'

			cAlias := "BA3"
			cChave := cCodOpe + cCodEmp + cMatricUsr

		ElseIf cNivCob = '5'

			cAlias := "BA1"
			cChave := cCodOpe + cCodEmp + cMatricUsr + cTipReg

		ElseIf cNivCob = '6'

			cAlias := "BA0"
			cChave := cCodOpe

		EndIf

		DBSelectArea(cAlias)
		DBSetOrder(1)
		If 	DBSeek(xFilial(cAlias)+cChave)
			If lAtuCad
				RegToMemory(cAlias,.F.,.F.)

				&("M->"+cAlias+"_VENCTO") := nDiaVen

				PLUPTENC(cAlias,4)
			EndIf
		Else
			MsgAlert(STR0009,STR0007) //"Nivel de Cobrança Não encontrado encontrado."###"Atenção"
		EndIf
		PlsTmkOco("17")
	EndIf

	For x := 1 To Len(aVetor)





		BA1->(DbGoTo(aVetor[x,Len(aVetor[x])]))
		BTS->(DbSetOrder(1))
		BTS->(DbSeek(xFilial("BTS")+BA1->BA1_MATVID))

		If BA3->BA3_COBNIV =='1' // nivel da familia
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cobrança Nivel da Familia  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  BA3->BA3_ENDCOB = "1" //  Cliente
				If lDadosCobAlt
					If BA1->BA1_TIPUSU =='T'

						If lAtuCad
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Local de cobrança - Titular³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							M->BA3_CEP		:=cCepCob
							M->BA3_END		:=cEndCon
							M->BA3_NUMERO	:=cNrEnder
							M->BA3_BAIRRO	:=cBaiCob
							M->BA3_CODMUN	:=cMunCob
							M->BA3_MUN		:=cDesMun
							M->BA3_ESTADO	:=cUfCob
							M->BA3_VENCTO	:=nDiaVen
							fFreshMe("BA3",0,.F.)
							PLUPTENC("BA3",4)
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava SA1          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DBSelectArea("SA1")
						SA1->(DBSetOrder(1))
						If	SA1->(DBSeek(xFilial("SA1")+cCodCli+cLojCli))
							If lHabAbaCob
								For i:=1 to Len(aStruSA1)
									&("M->"+aStruSA1[i,1]) := &("SA1->"+aStruSA1[i,1])
								Next
								M->A1_NOME 		:= cRazaoSo
								M->A1_END		:= Alltrim(cEndCon)+" "+cNrEnder
								M->A1_BAIRRO	:= cBaiCob
								M->A1_MUN		:= cDesMun
								M->A1_EST		:= cUfCob
								M->A1_CEP		:= cCepCob
								M->A1_DDD		:= cDddCob
								M->A1_TEL		:= cFoneCob
								M->A1_COD_MUN	:= Right(cMunCob,TamSX3("A1_COD_MUN")[1])
								PLUPTENC("SA1",4)
							EndIf
						Else
							MsgAlert(STR0010,STR0007) //"Cliente não encontrado."###"Atenção"
						EndIf
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BTS          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGravaBTS
					For i:=1 to Len(aStruBTS)
						If aStruBTS[i,1] $ cCpoNaoAtu .OR. !(aStruBTS[i,1] $ cCampBTS) // Atualiza somente os campos apresentados
							Loop
						EndIf

						&("M->"+aStruBTS[i,1]) := &("BTS->"+aStruBTS[i,1])
					Next

					M->BTS_MATVID  := BTS->BTS_MATVID
					M->BTS_NOMCAR  := BTS->BTS_NOMCAR

					fFreshMe("BTS",0,.F.)
					PLUPTENC("BTS",4)

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BA1          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->(DbSetOrder(7))
				If BA1->(DbSeek(xFilial("BA1")+BTS->BTS_MATVID))
					nOldRecBA1 := BA1->(Recno())
					While !BA1->(Eof()) .and. BA1->BA1_MATVID = BTS->BTS_MATVID
						For i:=1 to Len(aStruBA1)
							&("M->"+aStruBA1[i,1]) := &("BA1->"+aStruBA1[i,1])
						Next

						For i:=1 to Len(aStruBTS)
							If aStruBTS[i,1] $ cCpoNaoAtu .OR. !(aStruBTS[i,1] $ cCampBTS) // Atualiza somente os campos apresentados
								Loop
							EndIf

							&("M->BA1_"+SubStr(aStruBTS[i,1],5,6)) := &("BTS->"+aStruBTS[i,1])
						Next
						If lAtuCad
							PLUPTENC("BA1",4)
						EndIf

						BA1->(DbSkip())
					Enddo
					BA1->(DbGoTo(nOldRecBA1))
				Else
					MsgAlert(STR0098+" "+BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+" "+STR0099,STR0007) //"Problema ao alterar matricula ["###"] no cadastro de usuário."###"Atenção"
				EndIf
			ElseIf BA3->BA3_ENDCOB == "2" // Titular

				If BA1->BA1_TIPUSU =='T'

					IF lAtuCad
						M->BA3_END		:=aVetor[x,10]
						M->BA3_NUMERO	:=aVetor[x,11]
						M->BA3_COMPLE	:=aVetor[x,12]
						M->BA3_BAIRRO	:=aVetor[x,13]
						M->BA3_MUN		:=aVetor[x,14]
						M->BA3_ESTADO	:=aVetor[x,15]
						M->BA3_CEP		:=aVetor[x,16]
						M->BA3_CODMUN	:=aVetor[x,17]
						M->BA3_VENCTO	:=nDiaVen
						fFreshMe("BA3",0,.F.)
						PLUPTENC("BA3",4)
					EndIf

					If lDadosCobAlt
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava SA1          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DBSelectArea("SA1")
						SA1->(DBSetOrder(1))
						If	SA1->(DBSeek(xFilial("SA1")+cCodCli+cLojCli))
							If lHabAbaCob
								For i:=1 to Len(aStruSA1)
									&("M->"+aStruSA1[i,1]) := &("SA1->"+aStruSA1[i,1])
								Next
								M->A1_NOME 		:= cRazaoSo
								M->A1_END		:= Alltrim(cEndCon)+" "+cNrEnder
								M->A1_BAIRRO	:= cBaiCob
								M->A1_MUN		:= cDesMun
								M->A1_EST		:= cUfCob
								M->A1_CEP		:= cCepCob
								M->A1_DDD		:= cDddCob
								M->A1_TEL		:= cFoneCob
								M->A1_COD_MUN	:= Right(cMunCob,TamSX3("A1_COD_MUN")[1])
								PLUPTENC("SA1",4)
							EndIf
						Else
							MsgAlert(STR0010,STR0007) //"Cliente não encontrado."###"Atenção"
						EndIf
					Endif

				ElseIf BA1->BA1_TIPUSU <>'T' .and. lDadosCobAlt  // Houve Alteracao no endereco de cobrança e se o usuario que não for titular pode alterar

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava SA1          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DBSelectArea("SA1")
					SA1->(DBSetOrder(1))
					If	SA1->(DBSeek(xFilial("SA1")+cCodCli+cLojCli))
						If lHabAbaCob
							For i:=1 to Len(aStruSA1)
								&("M->"+aStruSA1[i,1]) := &("SA1->"+aStruSA1[i,1])
							Next
							M->A1_NOME 		:= cRazaoSo
							M->A1_END		:= cEndCon+" "+cNrEnder
							M->A1_BAIRRO	:= cBaiCob
							M->A1_MUN		:= cDesMun
							M->A1_EST		:= cUfCob
							M->A1_CEP		:= cCepCob
							M->A1_DDD		:= cDddCob
							M->A1_TEL		:= cFoneCob
							M->A1_COD_MUN	:= Right(cMunCob,TamSX3("A1_COD_MUN")[1])
							PLUPTENC("SA1",4)
						EndIf
					Else
						MsgAlert(STR0010,STR0007) //"Cliente não encontrado."###"Atenção"
					EndIf
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BTS          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGravaBTS
					For i:=1 to Len(aStruBTS)
						If aStruBTS[i,1] $ cCpoNaoAtu
							Loop
						EndIf

						&("M->"+aStruBTS[i,1]) := &("BTS->"+aStruBTS[i,1])
					Next
					fFreshMe("BTS",0,.F.)

					PLUPTENC("BTS",4)

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BA1          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->(DbSetOrder(7))
				If BA1->(DbSeek(xFilial("BA1")+BTS->BTS_MATVID))
					nOldRecBA1 := BA1->(Recno())
					While !BA1->(Eof()) .and. BA1->BA1_MATVID = BTS->BTS_MATVID
						For i:=1 to Len(aStruBA1)
							&("M->"+aStruBA1[i,1]) := &("BA1->"+aStruBA1[i,1])
						Next

						If lGravaBTS
							For i:=1 to Len(aStruBTS)
								If aStruBTS[i,1] $ cCpoNaoAtu
									Loop
								EndIf

								&("M->BA1_"+SubStr(aStruBTS[i,1],5,6)) := &("BTS->"+aStruBTS[i,1])
							Next
						EndIf
						If lAtuCad
							PLUPTENC("BA1",4)
						EndIf

						BA1->(DbSkip())
					Enddo
					BA1->(DbGoTo(nOldRecBA1))
				Else
					MsgAlert(STR0098+" "+BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+" "+STR0099,STR0007) //"Problema ao alterar matricula ["###"] no cadastro de usuário."###"Atenção"
				EndIf

			ElseIf  BA3->BA3_ENDCOB == "3" // Endereco do contrato
				If BA1->BA1_TIPUSU =='T'
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Local de cobrança - Titular³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAtuCad
						M->BA3_CEP		:=cCepCob
						M->BA3_END		:=cEndCon
						M->BA3_NUMERO	:=cNrEnder
						M->BA3_BAIRRO	:=cBaiCob
						M->BA3_CODMUN	:=cMunCob
						M->BA3_MUN		:=cDesMun
						M->BA3_ESTADO	:=cUfCob
						M->BA3_VENCTO	:=nDiaVen
						fFreshMe("BA3",0,.F.)
						PLUPTENC("BA3",4)
					EndIf
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BTS          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If lGravaBTS
					For i:=1 to Len(aStruBTS)
						&("M->"+aStruBTS[i,1]) := &("BTS->"+aStruBTS[i,1])
					Next
					fFreshMe("BTS",0,.F.)

					PLUPTENC("BTS",4)

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava BA1          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->(DbSetOrder(7))
				If BA1->(DbSeek(xFilial("BA1")+BTS->BTS_MATVID))
					nOldRecBA1 := BA1->(Recno())
					While !BA1->(Eof()) .and. BA1->BA1_MATVID = BTS->BTS_MATVID
						For i:=1 to Len(aStruBA1)
							&("M->"+aStruBA1[i,1]) := &("BA1->"+aStruBA1[i,1])
						Next

						For i:=1 to Len(aStruBTS)
							&("M->BA1_"+SubStr(aStruBTS[i,1],5,6)) := &("BTS->"+aStruBTS[i,1])
						Next

						If lAtuCad
							PLUPTENC("BA1",4)
						EndIf

						BA1->(DbSkip())
					Enddo
					BA1->(DbGoTo(nOldRecBA1))
				Else
					MsgAlert(STR0098+" "+BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+" "+STR0099,STR0007) //"Problema ao alterar matricula ["###"] no cadastro de usuário."###"Atenção"
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cobrança Nivel do contrato ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BQC->BQC_ENDCOB='2' .And. lAtuCad// endereco do contrato
				M->BQC_CEP		:=cCepCob
				M->BQC_LOGRAD	:=cEndCon
				M->BQC_NUMERO	:=cNrEnder
				M->BQC_BAIRRO	:=cBaiCob
				M->BQC_CODMUN	:=cMunCob
				M->BQC_MUN		:=cDesMun
				M->BQC_ESTADO	:=cUfCob
				M->BQC_TEL		:=cFoneCob
				M->BQC_VENCTO	:=nDiaVen
				PLUPTENC("BQC",4)
			ElseIf lHabAbaCob // endereço do cliente
				M->A1_NOME 		:= cRazaoSo
				M->A1_END		:= cEndCon+" "+cNrEnder
				M->A1_BAIRRO	:= cBaiCob
				M->A1_MUN		:= cDesMun
				M->A1_EST		:= cUfCob
				M->A1_CEP		:= cCepCob
				M->A1_DDD		:= cDddCob
				M->A1_TEL		:= cFoneCob
				M->A1_COD_MUN	:= Right(cMunCob,TamSX3("A1_COD_MUN")[1])
				PLUPTENC("SA1",4)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava BTS          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lGravaBTS
				For i:=1 to Len(aStruBTS)
					&("M->"+aStruBTS[i,1]) := &("BTS->"+aStruBTS[i,1])
				Next
				fFreshMe("BTS",0,.F.)

				PLUPTENC("BTS",4)

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava BA1          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BA1->(DbSetOrder(7))
			If BA1->(DbSeek(xFilial("BA1")+BTS->BTS_MATVID))
				nOldRecBA1 := BA1->(Recno())
				While !BA1->(Eof()) .and. BA1->BA1_MATVID = BTS->BTS_MATVID
					For i:=1 to Len(aStruBA1)
						&("M->"+aStruBA1[i,1]) := &("BA1->"+aStruBA1[i,1])
					Next

					For i:=1 to Len(aStruBTS)
						&("M->BA1_"+SubStr(aStruBTS[i,1],5,6)) := &("BTS->"+aStruBTS[i,1])
					Next

					If lAtuCad
						PLUPTENC("BA1",4)
					EndIf

					BA1->(DbSkip())
				Enddo
				BA1->(DbGoTo(nOldRecBA1))
			Else
				MsgAlert(STR0098+" "+BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+" "+STR0099,STR0007) //"Problema ao alterar matricula ["###"] no cadastro de usuário."###"Atenção"
			EndIf
		Endif
		If lPLSTMKCT
			aRetPto := ExecBlock("PLSTMKCT",.F.,.F.,{nOldRecBA1})
			cContato := PlsCodContato(aRetPto[2],aRetPto[1])
		Else
			cContato := PlsCodContato(BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),"BA1")

			If Empty(cContato)
				cContato := PlsCodContato(BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO),"BA1")
			EndIf
		Endif

		SU5->(DBSetOrder(01))
		If	!Empty(cContato) .and. SU5->(MsSeek(xFilial("SU5")+cContato))
			RegToMemory("SU5",.F.,.F.)

			For i:=1 to Len(aStruSU5)
				&("M->"+aStruSU5[i,1]) := &("SU5->"+aStruSU5[i,1])
			Next

			For i:=1 to Len(aCampFld1)
				If aCampFld1[i] = "BTS_NOMUSR"
					M->U5_CONTAT := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_DATNAS"
					M->U5_NIVER := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_SEXO"
					M->U5_SEXO := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_ESTCIV"
					M->U5_CIVIL := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_CPFUSR"
					M->U5_CPF := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_EMAIL"
					M->U5_EMAIL := aVetor[x,i]
				ElseIf aCampFld1[i] = "BTS_DDD"
					M->U5_DDD := aVetor[x,i]
				ElseIf	aCampFld1[i] = "BTS_TELEFO"
					M->U5_FONE := aVetor[x,i]
				ElseIf	aCampFld1[i] = "BTS_BAIRRO"
					M->U5_BAIRRO := aVetor[x,i]
				ElseIf	aCampFld1[i] = "BTS_MUNICI"
					M->U5_MUN := aVetor[x,i]
				ElseIf	aCampFld1[i] = "BTS_ESTADO"
					M->U5_EST := aVetor[x,i]
				ElseIf	aCampFld1[i] = "BTS_CEPUSR"
					M->U5_CEP := aVetor[x,i]
				ElseIf aCampFld1[i] $ "BTS_ENDERE,BTS_NR_END,BTS_COMEND"
					M->U5_END += aVetor[x,i]+" "
				EndIf
				If Len(aVetorAlt) >= x .And. Len(aVetor) >= x
					If aVetor[x,i] <> aVetorAlt[x,i]
						lAlt := .T.
					EndIf
				Endif
			Next

			PLUPTENC("SU5",4)
		ElseIf !Empty(cContato)
			MsgAlert(STR0100+" "+BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+" "+STR0101,STR0007) //"Problema ao alterar matrícula ["###"] no cadastro de contato."###"Atenção"
		EndIf
		If lAlt
			PlstmkOco("16")
		EndIf
	Next x

	BA1->(DbSetOrder(1))

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fObrigatorioºAutor  ³Paulo Sampaio     º Data ³ 30/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica o preenchimento obriagatorio dos campos.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fObrigatorio(lHabAbaCob)

	Local lRet 		:= .T.
	Local nCpo,i	:= 0
	Local aCpoObri	:= Iif(lHabAbaCob,{cRazaoSo,cEndCon,cBaiCob,cMunCob,cUfCob,cCepCob},{}) // Campos Obrigatorios
	Local cMsg		:= STR0106 //"Existem campos obrigatórios não preenchidos."
	Local nPosMae	:= 0
	Local nPosNom	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos obrigatorios nos Dados de Cobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCpo := 1 To len(aCpoObri)
		If	Empty(aCpoObri[nCpo])
			lRet 	:= .F.
			MsgAlert(cMsg+STR0108,STR0007) //" [Label Dados de Cobrança]"###"Atenção"
			Return(lRet)
		EndIf
	Next nCpo

	nPosMae	:= ascan(aCampFld1,{|x| x = "BTS_MAE"})
	nPosNom	:= ascan(aCampFld1,{|x| x = "BTS_NOMUSR"})

	If nPosMae > 0 .And. cPaisLOC == "BRA"
		For i:=1 to Len(aVetor)
			If	Empty(AllTrim(aVetor[i][nPosMae]))
				MsgAlert(STR0094+AllTrim(aVetor[i][nPosNom])+STR0095,STR0007) //"O usuário ["###"] está sem nome da mãe. O preenchimento é obrigatório."###"Atenção"
				lRet := .F.
			EndIf
		Next
	EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PlsCodContatoºAutor  ³Henry Fila        º Data ³ 02/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Traz o codigo do contato a partir de um BA1                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsCodContato(cChave,cAlias)

	Local cFilEnt	:= ""
	Local cContato	:= ""
	DEFAULT cAlias  := "BA1"

	cFilEnt	:= xFilial(cAlias)

	AC8->(dbSetOrder(2))
	If AC8->( MsSeek( xFilial("AC8") + cAlias + cChave ) )
		cContato := AC8->AC8_CODCON
	Endif

Return(cContato)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLSTMKBOL    ºAutor  ³ David de Oliveiraº Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³iMPRIME 2a VIA DE BOLETO ATRAVÉS DE INTEGRAÇAO SIGATMK      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTMKBOL(cCliente,cLoja,cCodint,cCodEmp)

	Local cPerg := "PLSTMK"
	Local cRotina := SuperGetMV( "MV_PLBOTK",.F.,"PLSR580")
	Local lGeraPDF := .T.
	Local lEnviaEmail := .T.

	If cRotina = "PLSR580"
		Pergunte(cPerg,.T.)

		PLSR580( cCliente,; //Cliente de
			cLoja,;//Loja de
			cCliente,;//Cliente Ate
			cLoja,;//Loja Ate
			cCodint,;//Operadora de
			cCodint,;//Operadora Ate
			cCodEmp,;//Empresa de
			cCodEmp,;//Empresa Ate
			Space(12),;//Contrato de
			'ZZZZZZZZZZZZ',;//Contrato ate
			Space(9),;//Sub-Contrato de
			'ZZZZZZZZZ',;//Sub-Contrato ate
			space(6),;//Matricula de
			'ZZZZZZ',;//MAtricula Ate
			MV_PAR01,;//Mes de
			MV_PAR02,;//Ano de
			MV_PAR03,;//Mes Ate
			MV_PAR04,;// Ano Ate
			1,;//Detalha Cobranca - Por Usuario/Por Tipo Cobranca
			2, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,;
			lGeraPDF,;
			lEnviaEmail)

	ElseIf !Empty(cRotina) .and. ExistBlock(cRotina)

		ExecBlock(cRotina,.F.,.F.,{})

	Else

		MsgAlert(STR0109) //"Rotina de Impressão de Boleto Customizada Não Existe"

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    PLSTMKCRT     ºAutor  ³ David de Oliveiraº Data ³ 07/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³EMITE CARTEIRINHA PARA USUARIO VIA INTEGRAÇAO SIGATMK      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTMKCRT(cCodInt,cMatric,dDatVal)

	Local cPerg := "PLTMK2"

	If Pergunte(cPerg,.T.)

		PLSA261INC(cCodInt,cMatric,MV_PAR01,.F.,dDatval)

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    PlsTmkOco     ºAutor  ³                  º Data ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Ocorrências de cada Funcção acessada via Tela de     º±±
±±º          ³integração CALL X PLS                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsTmkOco(cFunc)

	Local nInd			:= 0
	Local nLinA,nColA,I	:= 0
	Local cAssunto 		:= ""
	Local cDesAssu		:= ""
	Local cOcorre		:= ""
	Local cDesOco		:= ""
	Local cOperad		:= __CUSERID
	Local cDesOpe		:= CUSERNAME
	Local cStatus   	:= SuperGetMV( "MV_PLTKST",.F.,"2")
	Local aRet			:= {}
	Local aColAux  		:= aClone(aCols)
	Default cFunc 		:= ''

	DbSelectArea("B20")
	B20->(DbSetOrder(1))

	If !Empty(cFunc) .and. MsSeek(xFilial("B20")+StrZero(Val(cFunc),6))

		nLinA := Len(aCols)

		If !Empty(aCols[1,PLRETPOS("UD_ASSUNTO",aHeader)])

			aadd(aCols,{})
			nLinA++

			For nInd :=  1 To Len(aHeader)+1

				If nInd <= Len(aHeader)
					If     aHeader[nInd,8] == "C"
						aadd(aCols[Len(aCols)],Space(aHeader[nInd,4]))
					ElseIf aHeader[nInd,8] == "D"
						aadd(aCols[Len(aCols)],ctod(""))
					ElseIf aHeader[nInd,8] == "N"
						aadd(aCols[Len(aCols)],0)
					ElseIf aHeader[nInd,8] == "L"
						aadd(aCols[Len(aCols)],.T.)
					ElseIf aHeader[nInd,8] == "M"
						aadd(aCols[Len(aCols)],"")
					Endif
				Else
					aadd(aCols[Len(aCols)],.F.)
				Endif

			Next

		EndIf

		DbSelectarea("SX5")
		DbSetorder( 1 )
		If DbSeek( xFilial("SX5")+"T1"+B20->B20_ASSUNT )
			cAssunto 	:= SX5->X5_CHAVE
			cDesAssu	:= X5DESCRI()
		Else
			Help(" ",1,"ASSUNTO" )
			lRet := .F.
		Endif

		DbSelectarea("SU9")
		DbSetorder( 1 )
		If DbSeek( xFilial("SU9")+B20->B20_ASSUNT+B20->B20_OCORRE )
			cOcorre	:= SU9->U9_CODIGO
			cDesOco	:= SU9->U9_DESC
		Else
			Help(" ",1,"OCORRENCIA")
			lRet := .F.
		Endif

		If ExistBlock("PLTMKOCO")

			aRet := ExecBlock( "PLTMKOCO",.F.,.F., {cAssunto,cDesAssu,cOcorre,cDesOco,cOperad,cDesOpe,cStatus, cFunc, aCols, aHeader} )
			lRet		:= aRet[1]
			aOcorrencias:= aRet[2]

			If lRet .and. len(aOcorrencias) > 0
				For I:= 1 to Len(aOcorrencias)
					nColA := PLRETPOS(aOcorrencias[I,1],aHeader)
					If nColA > 0 .and. nColA < (Len(aHeader)+1)
						aCols[nLinA,nColA] := aOcorrencias[I,2]
					EndIf
				Next

			Else
				aCols := aClone(aColAux)
			EndIf

		Else
			aCols[nLinA,PLRETPOS("UD_ASSUNTO",aHeader)]	:= cAssunto
			aCols[nLinA,PLRETPOS("UD_DESCASS",aHeader)]	:= cDesAssu
			aCols[nLinA,PLRETPOS("UD_OCORREN",aHeader)] := cOcorre
			aCols[nLinA,PLRETPOS("UD_DESCOCO",aHeader)] := cDesOco
			aCols[nLinA,PLRETPOS("UD_OPERADO",aHeader)] := cOperad
			aCols[nLinA,PLRETPOS("UD_DESCOPE",aHeader)] := cDesOpe
			aCols[nLinA,PLRETPOS("UD_STATUS",aHeader)] 	:= cStatus
			aCols[nLinA,PLRETPOS("UD_DATA",aHeader)] 	:= dDatabase
		EndIf

	Else
		aCols 	:= aClone(aColAux)
		MsgAlert(STR0115) //"!!PLS x TMK não encotrada!!"
	EndIf

	N	:= Len(aCols)

	If	ValType(oGetTmkPls:oBrowse) <> "O"
		oGetTmk:SetArray(aCols)
		oGetTmk:ForceRefresh()
	Else
		oGetTmkPls:SetArray(aCols)
		oGetTmkPls:ForceRefresh()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    PLSTMKBOT    ºAutor  ³ David de Oliveiraº Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para controle Botões                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSTMKBOT(cTela,bBot1,bBot2,bBot3,bBot4,bBot5,bBot6,bBot7,bBot8,bBot9,bBot10,bBot11,bBot12,bBot13,bBot14,bBot15,bBot16,bBot17,bBot18,bBot19,bBot20,bBot21,bBot22,bBot23,bBot24,bBot25,bBot26)

	Local aAreaSel 	:= GetArea()
	default bBot1	:= { || AllWaysTrue() }
	default bBot2	:= { || AllWaysTrue() }
	default bBot3	:= { || AllWaysTrue() }
	default bBot4	:= { || AllWaysTrue() }
	default bBot5	:= { || AllWaysTrue() }
	default bBot6	:= { || AllWaysTrue() }
	default bBot7	:= { || AllWaysTrue() }
	default bBot8	:= { || AllWaysTrue() }
	default bBot9	:= { || AllWaysTrue() }
	default bBot10	:= { || AllWaysTrue() }
	default bBot11	:= { || AllWaysTrue() }
	default bBot12	:= { || AllWaysTrue() }
	default bBot13	:= { || AllWaysTrue() }
	default bBot14	:= { || AllWaysTrue() }
	default bBot15	:= { || AllWaysTrue() }
	default bBot16	:= { || AllWaysTrue() }
	default bBot17	:= { || AllWaysTrue() }
	default bBot18	:= { || AllWaysTrue() }
	default bBot19	:= { || AllWaysTrue() }
	default bBot20	:= { || AllWaysTrue() }
	default bBot21	:= { || AllWaysTrue() }
	default bBot22	:= { || AllWaysTrue() }
	default bBot23	:= { || AllWaysTrue() }
	default bBot24	:= { || AllWaysTrue() }
	default bBot25	:= { || AllWaysTrue() }
	default bBot26	:= { || AllWaysTrue() }

	If cTela = "1"

		SetKey(VK_F4	,{|a,b| Eval(bBot1)	})
		SetKey(VK_F5 	,{|a,b| Eval(bBot2)	})
		SetKey(VK_F6 	,{|a,b| Eval(bBot3)	})
		SetKey(VK_F7 	,{|a,b| Eval(bBot4)	})
		SetKey(K_SH_F1	,{|a,b| Eval(bBot10)})
		SetKey(K_SH_F2 	,{|a,b| Eval(bBot11)})
		SetKey(VK_F8 	,{|a,b| Eval(bBot5)	})
		SetKey(12 		,{|a,b| Eval(bBot12)})
		SetKey(1 		,{|a,b| Eval(bBot13)})
		SetKey(7 		,{|a,b| Eval(bBot14)})
		If GetNewPar("MV_PLATIOD","0") == "1"
			SetKey(20 	,{|a,b| Eval(bBot15)})
		EndIf
		SetKey(6 		,{|a,b| Eval(bBot18)})
		SetKey(2 		,{|a,b| Eval(bBot19)})
		SetKey(VK_F9 	,{|a,b| Eval(bBot6)	})
		SetKey(VK_F10 	,{|a,b| Eval(bBot7)	})
		SetKey(VK_F11 	,{|a,b| Eval(bBot8)	})
		SetKey(5 		,{|a,b| Eval(bBot16)})
		SetKey(9 		,{|a,b| Eval(bBot17)})
		SetKey(VK_F12 	,{|a,b| Eval(bBot9)	})
		SetKey(20 		,{|a,b| Eval(bBot20)})
		SetKey(21 		,{|a,b| Eval(bBot21)})
		SetKey(K_SH_F3	,{|a,b| Eval(bBot22)})
		SetKey(K_SH_F4	,{|a,b| Eval(bBot23)})
		SetKey(K_SH_F5	,{|a,b| Eval(bBot24)})
		SetKey(K_SH_F6	,{|a,b| Eval(bBot25)})
		SetKey(K_SH_F7	,{|a,b| Eval(bBot26)})
	EndIf

	If cTela = "2"

		SetKey(VK_F2 	,{|a,b| Eval(bBot1)	})
		SetKey(VK_F4 	,{|a,b| Eval(bBot2)	})
		SetKey(VK_F5 	,{|a,b| Eval(bBot3)	})
		SetKey(VK_F6 	,{|a,b| Eval(bBot4)	})
		SetKey(16 		,{|a,b| Eval(bBot5)	})
		SetKey(18 		,{|a,b| Eval(bBot6)	})

	EndIf

	RestArea(aAreaSel)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PlsTmkRda    ºAutor  ³David de Oliveira º Data ³ 07/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para pesquisa de RDA                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTMKRDA(cProduto, cVersao, lFiltRDA)

	LOCAL cCodOpe
	LOCAL bOKRDA  := { || oDlgPls:End() }
	LOCAL bCancel := { || oDlgPls:End() }

	LOCAL oMemo
	LOCAL cMemo := ""

	LOCAL oEstado
	LOCAL aEstado
	LOCAL cEstado

	LOCAL oEspec
	LOCAL aEspec   := {__cTextoAll}
	LOCAL cEspec   := __cTextoAll
	LOCAL bEsp     := { || aEspec := PLSLESP(cCodOpe,cEstado), oEspec:aItems := aClone(aEspec), cEspec := aEspec[1], Eval(bMun), Eval(bReg), Eval(bBairro), cCodProc  := __cTextoAll, oEspec:Refresh()}

	LOCAL oMun
	LOCAL aMun     := {__cTextoAll}
	LOCAL cMun     := __cTextoAll
	LOCAL bMun     := { || aMun := PLSLISMUN(cCodOpe,Subs(cEspec,1,7),cEstado,"",.T.),If(LEN(aMun) == 1 .AND. EMPTY(aMun[1]),aMun := {__cTextoAll},NIL), oMun:aItems := aClone(aMun), cMun := aMun[1], Eval(bReg), Eval(bBairro), cCodProc  := __cTextoAll, oMun:Refresh()  }

	LOCAL oReg
	LOCAL aReg     := {__cTextoAll}
	LOCAL cReg     := __cTextoAll
	LOCAL bReg     := { || aReg := TMKPLSREG(cCodOpe,If(cMun <> __cTextoAll,RIGHT(cMun,7),cMun)),If(LEN(aReg) == 1 .AND. EMPTY(aReg[1]),aReg := {__cTextoAll},NIL), oReg:aItems := aClone(aReg), cReg := aReg[1], (bBairro), cCodProc  := __cTextoAll, oReg:Refresh()  }

	LOCAL oBairro
	LOCAL aBairro  := {__cTextoAll}
	LOCAL cBairro  := __cTextoAll
	LOCAL bBairro  := { || aBairro := PLSLISBAI(cCodOpe,Subs(cEspec,1,7),cEstado,If(cMun <> __cTextoAll,RIGHT(cMun,7),cMun)),If(LEN(aBairro) == 1 .AND. EMPTY(aBairro[1]),aBairro := {__cTextoAll},NIL), oBairro:aItems := aClone(aBairro), cBairro := aBairro[1], cCodProc  := __cTextoAll, oBairro:Refresh() }

	LOCAL oCodPad

	LOCAL oCodProc
	LOCAL cCodProc  := __cTextoAll

	Local ARDAS		:= {}
	LOCAL oRDA
	LOCAL aRDA     := {}
	LOCAL cRDA     := ""
	LOCAL bRDA     := { || aRDA := TMKLISRDA(cCodOpe,Subs(cEspec,1,7),cEstado,If(cMun <> __cTextoAll,RIGHT(cMun,7),cMun),cBairro), oRDA:aItems := aClone(aRDA), cRDA := aRda[1], oRDA:Refresh() }

	Local aPosObj    := {}
	Local aPosGet    := {}
	Local aObjects   := {}
	Local aInfo		 := {}
	Local aSize      := MsAdvSize( .T., .F., 400)
	Local oMenuAut
	Local bBotMn1    := {|| oMenuAut:Activate(C(150,'2'),L(45),oDlgPls)}

	Local bBotPes	 := {||	Processa({||aRdas := TMKLISRDA(cCodOpe,Subs(cEspec,1,3),cEstado,If(cMun <> __cTextoAll,RIGHT(cMun,7),cMun),substr(cReg,1,3), cBairro, cProduto, cVersao, lFiltRDA, cCdPad, cCodProc),;
		aDadRDATMK := TMKRDA(aRdas,cCodOpe)},STR0260),; //"Pesquisa em andamento, aguarde..."
		CargaPesRDA(oPesRda,aDadRDATMK),;
		oPesRda:Refresh()}

	Local bBotInc	 := {|| TMKINCRDA(oPesRda,cCodProc,aDadRDaTMK,aDadGRDA,cCdPad),;
		CargaGuiRDA(oGuiRda,aDadGRDA),;
		oGuiRDA:Refresh()}

	Local bBotExc	 := {|| TMKEXCRDA(oGuiRda,aDadGRDA),;
		CargaGuiRDA(oGuiRda,aDadGRDA),;
		oGuiRDA:Refresh()}

	Local bBotAut 	 :=	{|| PLSTMKBOT("2"),;
		TMKAUTCON(aDadGRDA,"1"),;
		PLSTMKBOT("2",bBotPes,bBotInc,bBotExc,bBotMn1,bBotLib,bBotAut)}

	Local bBotLib 	 :=	{|| PLSTMKBOT("2"),;
		TMKAUTCON(aDadGRDA,"2"),;
		PLSTMKBOT("2",bBotPes,bBotInc,bBotExc,bBotMn1,bBotLib,bBotAut)}

	Local bBotImp 	 :=	{|| PLSIMPRDA(aDadRDATMK,aDadGRDA),;
		}

	Private cCdPad  := GETMV("MV_PLSTBPD")

	Private aDadRDaTMK    := {}
	Private aCabRdaTMK

	Private aDadGRDa    := {}
	Private aGuiRda

	Private aDadPRDa    := {}
	Private aProRda

	DEFAULT cProduto := ""
	DEFAULT cVersao  := ""
	DEFAULT lFiltRDA := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 2 , 2 }
	aObjects:= {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 090, .T., .F. } )
	AAdd( aObjects, { 100, 070, .T., .F. } )

	aPosObj:= MsObjSize( aInfo, aObjects ,.T.)

	DEFINE FONT oFontePLS NAME "Courier New" SIZE 000,-010

	cCodOpe  := PLSINTPAD()

	aEstado  := PLSLISEST(cCodOpe)
	cEstado  := aEstado[1]

	DEFINE MSDIALOG oDlgPls TITLE STR0155 FROM 000,000 to aSize[6],aSize[5] OF oMainWnd PIXEL//FROM 008.2,010.3 TO 049.5,117.3  //"Consultar Rede de Atendimento (Rdas)"

	bOkRDA 		:= {|| nOpcA:=1, oDlgPls:End() }
	bOkExclui 	:= {|| nOpcA:=1, oDlgPls:End() }
	bCancel 	:= {|| nOpcA:=0, oDlgPls:End() }

	DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlgPls

	//Sub Menu Botaão bBotMn1
	MENU oMenuAut POPUP
	MENUITEM STR0013 	ACTION Eval(bBotLib) //"&Liberaçao"
	MENUITEM STR0014 	ACTION Eval(bBotAut) //"&Autotização"
	ENDMENU
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta botoes                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBtn := TBtnBmp():NewBar( "BMPVISUAL","BMPVISUAL",,,STR0116, bBotPes,.T.,oBar,,,STR0116+" < F2 >") //"Consultar" //"Consultar"###"Consultar"
	oBtn:cTitle := STR0116 //"Consultar"
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "BMPINCLUIR","BMPINCLUIR",,,STR0117, bBotInc,.T.,oBar,,,STR0118+" < F4 >") //"Incluir" //"Incluir Proc."###"Incluir"
	oBtn:cTitle := STR0117 //"Incluir Proc."
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "BMPDEL","BMPDEL",,,STR0119, bBotExc,.T.,oBar,,,STR0120+" < F5 >") //"Excluir" //"Excluir Proc."###"Excluir"
	oBtn:cTitle := STR0119 //"Excluir Proc."
	PLSXButCap(oBtn)

	If !Empty(cProduto)
		oBtn := TBtnBmp():NewBar( "PEDIDO","PEDIDO",,,STR0121, bBotMn1,.T.,oBar,,,STR0121+" < F6 >") //"Guia" //"Guia"###"Guia"
		oBtn:cTitle := STR0121 //"Guia"
		PLSXButCap(oBtn)
	EndIf

	oBtn := TBtnBmp():NewBar( "TOTVSPRINTER_PDF","TOTVSPRINTER_PDF",,,"Imprime RDA", bBotImp,.T.,oBar,,," < Imprime RDA >") //
	oBtn:cTitle := "Imprime RDA" //
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "OK","OK",,,"Ok"+" < Ctrl-O >", bOkRDA,.T.,oBar,,,"Ok" + " < Ctrl-O >")//OK
	oBtn:cTitle := "Ok"
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "CANCEL","CANCEL",,,STR0032 + " < Ctrl-X >", bCancel,.T.,oBar,,,STR0032 + " < Ctrl-X >")//SAIR //"Sair"###"Sair"
	oBtn:cTitle := STR0032 //"Sair"
	PLSXButCap(oBtn)

	TGroup():New(015,005,180,167,STR0156,, , ,.T.)  //"Parametros de Pesquisa" 170
	TGroup():New(015,177,180,aPosObj[1][4] - 2,STR0157,, , ,.T.)  //"Rede(s) de Atendimento(s)" 170
	TGroup():New(185,005,290,aPosObj[1][4] - 2,STR0122,, , ,.T.)  //"Rede(s) de Atendimento(s)" 170 //"RDA x Procedimentos"

	@ 030,012 SAY oSay PROMPT STR0158  SIZE 220,010 OF oDlgPls PIXEL  //"Estado(s)"
	@ 040,012 COMBOBOX oEstado  Var cEstado ITEMS aEstado  SIZE 050,010 OF oDlgPls PIXEL

	@ 055,012 SAY oSay PROMPT STR0159  SIZE 220,010 OF oDlgPls PIXEL  //"Especialidade(s)"
	@ 065,012 COMBOBOX oEspec   Var cEspec  ITEMS aEspec   SIZE 150,010 OF oDlgPls PIXEL
	oEspec:bGotFocus := bEsp

	@ 080,012 SAY oSay PROMPT STR0160  SIZE 220,010 OF oDlgPls PIXEL  //"Muncipio(s)"
	@ 090,012 COMBOBOX oMun     Var cMun    ITEMS aMun     SIZE 150,010 OF oDlgPls PIXEL
	oMun:bGotFocus := bMun

	@ 105,012 SAY oSay PROMPT STR0123  SIZE 220,010 OF oDlgPls PIXEL  //"Região(s)" //"Região"
	@ 115,012 COMBOBOX oReg     Var cReg    ITEMS aReg     SIZE 150,010 OF oDlgPls PIXEL
	oReg:bGotFocus := bReg

	@ 130,012 SAY oSay PROMPT STR0161  SIZE 220,010 OF oDlgPls PIXEL  //"Bairro(s)"
	@ 140,012 COMBOBOX oBairro  Var cBairro ITEMS aBairro  SIZE 150,010 OF oDlgPls PIXEL
	oBairro:bGotFocus := bBairro

	@ 155,012 SAY oSay PROMPT STR0124  SIZE 220,010 OF oDlgPls PIXEL  //"Código Procedimento" //"Código Procedimento"
	@ 165,012 MSGET oCodPad  VAR cCdPad   SIZE 030,010 OF oDlgPls PIXEL F3 "B41PLS" hasbutton
	@ 165,042 MSGET oCodProc VAR cCodProc  SIZE 120,010 OF oDlgPls PIXEL F3 "BBVPLS" hasbutton

	aCabRDATMK:= {STR0162,STR0163,STR0164,STR0165,STR0166,STR0167,STR0168,STR0169,STR0170}
	aadd(aDadRDATMK, {"","","","","","","","",""})

	oPesRda := TcBrowse():New(030,180,aPosObj[1][4] - 187,148,,,, oDlgPls,,,,,,,,,,,, .F.,, .T.,, .F., )

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[1],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[2],nil,;
		nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[3],nil,;
		nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[4],nil,;
		nil,nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[5],nil,;
		nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[6],nil,;
		nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[7],nil,;
		nil,nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[8],nil,;
		nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))

	oPesRda:AddColumn(TcColumn():New(aCabRDATMK[9],nil,;
		nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))

	CargaPesRDA(oPesRda,aDadRDATMK)

	aGuiRDA:= {STR0125,STR0035,STR0126,STR0127,STR0128,STR0129,STR0035} //"Código"###"Nome"###"Local"###"Especialidade"###"Cod. Pad."###"Procedimento"###"Nome"
	aadd(aDadGRDA, {"","","","","","",""})

	oGuiRda := TcBrowse():New(195,012,aPosObj[1][4] - 20,90,,,, oDlgPls,,,,,,,,,,,, .F.,, .T.,, .F., )//50

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[1],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[2],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[3],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[4],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[5],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[6],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[7],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	CargaGuiRDA(oGuiRda,aDadGRDA)

	PLSTMKBOT("2",bBotPes,bBotInc,bBotExc,bBotMn1,bBotLib,bBotAut)

	SetKey(15 	,{|a,b| Eval(bOkRDA)	})
	SetKey(24 	,{|a,b| Eval(bCancel)	})

	ACTIVATE MSDIALOG oDlgPls

	PLSTMKBOT("2")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ TMKLISRDA³ Autor ³ Tulio Cesar           ³ Data ³ 02.07.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Devolve todas as RDAS...                                   ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMKLISRDA(cCodOpe,cCodEsp,cEstado,cCodMun,cCodReg, cBairro,cProduto,cVersao,lFiltRDA, cCodPad, cCodProc)

	LOCAL aRetorno   := {}
	LOCAL aArea		 := GetArea()
	LOCAL cSQL
	LOCAL lFlag      := .F.
	LOCAL cMVPLSRDAG := GetNewPar("MV_PLSRDAG","999999")
	LOCAL nPos
	LOCAL lGrava
	LOCAL nQtd 		 := 0
	LOCAL aRetRDA	 := {}
	LOCAL aRetUsr	 := {}
	LOCAL aRetExe	 := {}
	LOCAL aRedePerm  := {}
	LOCAL aNiveis	 := PLSESPNIV(cCodPad)
	LOCAL nNiveis	 := (aNiveis[1]+1)
	LOCAL nFor		 := 0
	LOCAL lRedePerm  := .F.

	DEFAULT cCodMun  := ""
	DEFAULT cCodReg  := ""
	DEFAULT cProduto := ""
	DEFAULT cVersao  := ""
	DEFAULT lFiltRDA := .F.
	DEFAULT cCodpad  := ""
	DEFAULT cCodProc := ""

	cSQL := "SELECT BAU_CODIGO, BAU_NOME, BB8_CODINT, BB8_CODIGO, BB8_CODMUN, BB8_CEP, BB8_CODLOC, BAX_CODESP"
	cSQL += " FROM "+RetSQLName("BAX")+", "+RetSQLName("BB8")+", "+RetSQLName("BAU")
	If !Empty(cCodPad) .And. !Empty(cCodProc) .and. subs(cCodProc,1,2) <> Subs(__cTextoAll,1,2) .AND. GetNewPar("MV_PLVFBE9","0") == "1"
		cSQL += ", "+RetSQLName("BE9")
	EndIf
	cSQL += " WHERE "
	cSQL += "BAU_FILIAL = '"+xFilial("BAU")+"' AND "
	cSQL += "BAU_CODIGO = BB8_CODIGO AND "
	cSQL += "BAU_CODBLO = '   ' AND "
	cSQL += "BB8_FILIAL = '"+xFilial("BAU")+"' AND "
	cSQL += "BB8_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BB8_EST    = '"+cEstado+"' AND "
	If subs(cCodMun,1,7) <> Subs(__cTextoAll,1,7)
		cSQL += "BB8_CODMUN = '"+cCodMun+"' AND "
	Endif
	If AllTrim(cBairro) <> __cTextoAll
		cSQL += "BB8_BAIRRO = '"+cBairro+"' AND "
	Endif
	cSQL += "BB8_GUIMED = '1' AND "
	cSQL += "BB8_DATBLO = '        ' AND "
	cSQL += "BB8_CODIGO = BAX_CODIGO AND "
	cSQL += "BB8_CODINT = BAX_CODINT AND "
	cSQL += "BB8_CODLOC = BAX_CODLOC AND "
	cSQL += "BAX_FILIAL = '"+xFilial("BAX")+"' AND "
	cSQL += "BAX_CODINT = '"+cCodOpe+"' AND "
	If subs(cCodEsp,1,3) <> Subs(__cTextoAll,1,3)
		cSQL += "BAX_CODESP = '"+subs(cCodEsp,1,3)+"' AND "
	Endif
	cSQL += "BAX_GUIMED = '1' AND "

	If !Empty(cCodPad) .And. !Empty(cCodProc) .and. subs(cCodProc,1,2) <> Subs(__cTextoAll,1,2) .And. GetNewPar("MV_PLVFBE9","0") == "1"
		cSQL += "BAX_CODIGO = BE9_CODIGO AND "
		cSQL += "BAX_CODINT = BE9_CODINT AND "
		cSQL += "BAX_CODLOC = BE9_CODLOC AND "
		cSQL += "BAX_CODESP = BE9_CODESP AND "
		cSQL += "BE9_FILIAL = '"+xFilial("BE9")+"' AND "
		cSQL += "BE9_CODPLA = '"+cProduto+"' AND "
		cSQL += "BE9_CODPAD = '"+cCodPad+"' AND "
		For nFor := 1 To nNiveis
			If nFor == 1
				cSQL += "(BE9_CODPRO = '"+cCodProc+"' "
				If nNiveis == 1
					cSQL += " OR  "
					cSQL += "(BE9_CDNV01"+" = '"+Subs(cCodProC,1,4)+"' AND "
					cSQL += "BE9_NIVEL = '"+'1'+"') "
					cSQL += ") AND "
				EndIf
			ElseIf nFor <> nNiveis
				cSQL += " OR"
				cSQL += "(BE9_CDNV0"+StrZero(nFor-1,1)+" = '"+Subs(cCodProC,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])+"' AND "
				cSQL += "BE9_NIVEL = '"+aNiveis[2,(nFor-1),3]+"')"
			Else
				cSQL += " OR  "
				cSQL += "(BE9_CDNV0"+StrZero(nFor-1,1)+" = '"+Subs(cCodProC,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])+"' AND "
				cSQL += "BE9_NIVEL = '"+aNiveis[2,(nFor-1),3]+"') "
				cSQL += ") AND "
			EndIf
		Next
		cSQL += RetSQLName("BE9")+".D_E_L_E_T_ = ' ' AND "
	EndIf

	cSQL += RetSQLName("BAU")+".D_E_L_E_T_ = ' ' AND "
	cSQL += RetSQLName("BB8")+".D_E_L_E_T_ = ' ' AND "
	cSQL += RetSQLName("BAX")+".D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY"

	If !Empty(cCodPad) .And. !Empty(cCodProc) .and. subs(cCodProc,1,2) <> Subs(__cTextoAll,1,2) .AND. GetNewPar("MV_PLVFBE9","0") == "1"
		cSQL += " BE9_ATEND"
	Else
		cSQL += " BAU_PRDATN"
	EndIf

	PLSQuery(cSQL,"TrbPls")

	//esta função está preparada para utilizar a função processa
	ProcRegua(TrbPls->( LASTREC()))

	DbSelectArea("BIB")
	BIB->(DbSetOrder(1))

	While ! TrbPls->(Eof())

		IncProc(" ") //Sem texto padrão

		If cMVPLSRDAG == TrbPls->BB8_CODIGO
			TrbPls->(DbSkip())
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o local de atendimento pode atender o produto. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BBI->(DbSetOrder(1)) //BBI_FILIAL + BBI_CODIGO + BBI_CODINT + BBI_CODLOC + BBI_CODESP + BBI_CODPRO + BBI_VERSAO
		If (BBI->(MsSeek(xFilial("BBI")+TrbPls->BB8_CODIGO + TrbPls->BB8_CODINT + TrbPls->BB8_CODLOC + TrbPls->BAX_CODESP + cProduto + cVersao))) .And. BBI->BBI_ATIVO == "0"
			TrbPls->(DbSkip())
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o tipo de Rede de Atendimento da Rda pode atender o produto. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRedePerm := {}
		lRedePerm := .F.
		DbSelectArea("BI3")
		BI3->(DbSetOrder(1))//BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
		If BI3->(DbSeek(xFilial("BI3")+cCodOpe+cProduto+cVersao))
			If BI3->BI3_ALLRED <> "1" //Se estiver "Sim" nao verifica pois atende todas os tipos de Rede de Atendimento
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica os tipos de rede ativos no produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("BB6")
				BB6->(DbSetOrder(1))//BB6_FILIAL+BB6_CODIGO+BB6_VERSAO
				If BB6->(DbSeek(xFilial("BB6")+cCodOpe+cProduto+cVersao))
					While BB6->BB6_CODIGO == cCodOpe+cProduto .And. BB6->BB6_VERSAO == cVersao .And. BB6->(!Eof())
						If BB6->BB6_ATIVO == "1"
							Aadd(aRedePerm,BB6->BB6_CODRED)
						EndIf
						BB6->(DbSkip())
					EndDo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica na Rda se ela permite o atendimento aos tipos de rede encontrados³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nFor := 1 to len(aRedePerm)
						DbSelectArea("BBK")
						DbSelectArea(1)//BBK_FILIAL+BBK_CODIGO+BBK_CODINT+BBK_CODLOC+BBK_CODESP+BBK_CODRED
						If BBK->(DbSeek(xFilial("BBK")+TrbPls->BAU_CODIGO+TrbPls->BB8_CODINT+TrbPls->BB8_CODLOC+TrbPls->BAX_CODESP+aRedePerm[nFor]))
							lRedePerm := .T.
							Exit
						EndIf
					Next
				EndIf

				If !lRedePerm
					TrbPls->(DbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		If	!Empty(cCodReg) .and.;
				SubStr(cCodReg,1,2) <> Subs(__cTextoAll,1,2) .and.;
				BIB->(MsSeek(xFilial("BIB")+cCodOpe+cCodReg))

			cSQL1 := "SELECT COUNT(*) AS BICQTD FROM "+RetSqlName("BIC")+" WHERE BIC_FILIAL = '"+xFilial("BIC")+"' AND BIC_CODINT = '"+cCodOpe+"' AND BIC_CODREG = '"+cCodReg+"' AND BIC_CODMUN = '"+TRBPLS->BB8_CODMUN+"' AND D_E_L_E_T_ <> '*' "

			cSQL2 := "SELECT COUNT(*) AS BY7QTD FROM "+RetSqlName("BY7")+" WHERE BY7_FILIAL = '"+xFilial("BY7")+"' AND BY7_CODINT = '"+cCodOpe+"' AND BY7_CODREG = '"+cCodReg+"' AND BY7_CEPDE <= '"+TRBPLS->BB8_CEP+"' AND '"+TRBPLS->BB8_CEP+"' <= BY7_CEPATE AND D_E_L_E_T_ <> '*' "

			If BIB->BIB_TIPO = '1'

				PLSQuery(cSQL1,"TRBBIC")
				nQtd +=  TRBBIC->BICQTD
				TRBBIC->(DbCloseArea())

			ElseIf BIB->BIB_TIPO = '2'

				PLSQuery(cSQL2,"TRBBY7")
				nQtd +=  TRBBY7->BY7QTD
				TRBBY7->(DbCloseArea())

			ElseIf BIB->BIB_TIPO = '3'

				PLSQuery(cSQL1,"TRBBIC")
				nQtd +=  TRBBIC->BICQTD
				TRBBIC->(DbCloseArea())

				PLSQuery(cSQL2,"TRBBY7")
				nQtd +=  TRBBY7->BY7QTD
				TRBBY7->(DbCloseArea())

			EndIf

			If nQtd <= 0

				TrbPls->(DbSkip())
				Loop

			EndIf

		EndIf

		lGrava := .T.

		If !Empty(cCodProc) .and. subs(cCodProc,1,2) <> Subs(__cTextoAll,1,2)
			aRetRda := PLSDADRDA(cCodOpe,TrbPls->BAU_CODIGO,"1",dDataBase,TrbPLS->BB8_CODLOC,TrbPLS->BAX_CODESP,cCodPad,cCodProc)
			aRetUsr := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDatabase)
			If aRetUsr[1]
				aRetExe := PLSAUTPMDD(	cCodOpe,TrbPls->BAU_CODIGO,cCodPad,;
					cCodProc,aRetRda,"1",aRetUsr,"1",;
					TrbPLS->BAX_CODESP,TrbPLS->BB8_CODLOC,.F.,{{aRetUsr[11]}})
			Else
				aRetExe := {.F.}
			EndIf

			If !aRetExe[1]
				TrbPls->(DbSkip())
				Loop
			EndIf
		EndIf

		If lGrava
			nPos := Ascan(aRetorno,{ |x| x[1] == TrbPls->BAU_CODIGO .and. x[3] == TrbPls->BB8_CODLOC .and. x[4] == TrbPls->BAX_CODESP})
			If  nPos == 0
				aadd(aRetorno,{TrbPls->BAU_CODIGO,TrbPls->BAU_NOME,TrbPls->BB8_CODLOC,TrbPls->BAX_CODESP})
			Endif
		EndIf

		TrbPls->(DbSkip())

	Enddo

	TrbPls->(DbCloseArea())

	If Len(aRetorno) == 0
		aRetorno := {}
	Endif

	RestArea(aArea)

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    TMKRDA        ºAutor  ³DAVID DE OLIVEIRA º Data ³ 07/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³GRAVA ARRAY COM RDAS BUSCADAS                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKRDA(aRdas,cCodOpe)

	LOCAL nFor
	LOCAL cCodRda
	LOCAL cCodLoc
	LOCAL cCodEsp
	LOCAL aDRDA := {}

	For nFor := 1 To Len(aRdas)
		cCodRda := aRdas[nFor,1]
		cCodLoc := aRdas[nFor,3]
		cCodEsp := aRdas[nFor,4]

		BAU->(DbSetOrder(1))
		BAU->(MsSeek(xFilial("BAU")+cCodRDA))

		BB8->(DbSetOrder(1))
		BB8->(MsSeek(xFilial("BB8")+cCodRda+cCodOpe+cCodLoc))

		BAX->(DbSetOrder(1))
		BAX->(MsSeek(xFilial("BAX")+cCodRda+cCodOpe+cCodLoc+cCodEsp))

		BAQ->(DbSetOrder(1))
		BAQ->(MsSeek(xFilial("BAQ")+cCodOpe+cCodEsp))

		aADD(aDRDA, {BAU->BAU_CODIGO,AllTrim(BAU->BAU_NOME),BB8->BB8_CODLOC+'-'+AllTrim(BB8->BB8_DESLOC),ALLTRIM(BB8->BB8_END)+SPACE(02)+AllTrim(BB8->BB8_NR_END),BB8->BB8_BAIRRO,BB8->BB8_MUN,BB8->BB8_EST,BB8->BB8_TEL,cCodEsp+"-"+AllTrim(BAQ->BAQ_DESCRI)})

	Next

Return(aDRDA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    CARGAPESRDA  ºAutor  ³DAVID DE OLIVEIRAº Data ³ 07/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CargaPesRDA(oPesRda,aRDA)

	Static objCENFUNLGP := CENFUNLGP():New()

	oPesRda:ACOLUMNS[1]:BDATA     := { || aRDA[oPesRda:nAt,1]}
	oPesRda:ACOLUMNS[2]:BDATA     := { || aRDA[oPesRda:nAt,2]}
	oPesRda:ACOLUMNS[3]:BDATA     := { || aRDA[oPesRda:nAt,3]}
	oPesRda:ACOLUMNS[4]:BDATA     := { || aRDA[oPesRda:nAt,4]}
	oPesRda:ACOLUMNS[5]:BDATA     := { || aRDA[oPesRda:nAt,5]}
	oPesRda:ACOLUMNS[6]:BDATA     := { || aRDA[oPesRda:nAt,6]}
	oPesRda:ACOLUMNS[7]:BDATA     := { || aRDA[oPesRda:nAt,7]}
	oPesRda:ACOLUMNS[8]:BDATA     := { || aRDA[oPesRda:nAt,8]}
	oPesRda:ACOLUMNS[9]:BDATA     := { || aRDA[oPesRda:nAt,9]}

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BAU_CODIGO",;
			"BAU_NOME",;
			"BB8_CODLOC+BB8_DESLOC",;
			"BB8_END+BB8_NR_END",;
			"BB8_BAIRRO",;
			"BB8_MUN",;
			"BB8_EST",;
			"BB8_TEL",;
			"BAQ_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oPesRda:aObfuscatedCols := aBls
	endif

	oPesRda:SetArray(aRda)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    CARAGAGUIRDA  ºAutor  ³DAVID DE OLIVEIRA º Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CargaGuiRDA(oGuiRda,aDadGRDA)

	oGuiRda:ACOLUMNS[1]:BDATA     := { || aDadGRDA[oGuiRda:nAt,1]}
	oGuiRda:ACOLUMNS[2]:BDATA     := { || aDadGRDA[oGuiRda:nAt,2]}
	oGuiRda:ACOLUMNS[3]:BDATA     := { || aDadGRDA[oGuiRda:nAt,3]}
	oGuiRda:ACOLUMNS[4]:BDATA     := { || aDadGRDA[oGuiRda:nAt,4]}
	oGuiRda:ACOLUMNS[5]:BDATA     := { || aDadGRDA[oGuiRda:nAt,5]}
	oGuiRda:ACOLUMNS[6]:BDATA     := { || aDadGRDA[oGuiRda:nAt,6]}
	oGuiRda:ACOLUMNS[7]:BDATA     := { || aDadGRDA[oGuiRda:nAt,7]}

	oGuiRda:SetArray(aDadGRDA)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍLLÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    TMKINCRDA     ºAutor  ³DAVID DE OLIVEIRA º Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKINCRDA(oPesRda, cCodProc, aRDa, aDadGRDA, cCodPad, nAuto)

	Local nPosRDA := 0
	Local aAux := {}
	Local i := 0
	Local nPesRda := 0

	Default cCodPad := '01'
	Default nAuto := 0 // Automação

	nPesRda := IIF(nAuto > 0, nAuto, oPesRda:nAt)

	If Len(aRDa) > 0
		nPosRDA:= Ascan(aDadGRDA, {|x| 	x[1] = aRDa[nPesRda,1] .and.;
			x[3] = aRDa[nPesRda,3] .and.;
			x[4] = aRDa[nPesRda,9] .and.;
			x[5] = cCodPad .and.;
			x[6] = cCodProc})
	EndIf

	If nPosRDA > 0
		MsgAlert(STR0130) //"RDA e Procedimento ja incluído!!"
		Return

	ElseIf SubStr(cCodProc,1,3) = "***"
		MsgAlert(STR0132) //"Informe um procedimento!!"
		Return

	ElseIf Len(aRDa) > 0 .and. Empty(aRDa[nPesRda,1])
		MsgAlert(STR0133) //"Selecione uma RDA"
		Return

	Else
		If Len(aRDa) > 0
			AaDd(aDadGRDA,{aRDa[nPesRda,1],aRDa[nPesRda,2],aRDa[nPesRda,3], aRDa[nPesRda,9],cCodpad,cCodProc,Posicione("BR8",1,xFilial("BR8")+cCodpad+cCodProc,"BR8->BR8_DESCRI")})
		Endif

	EndIf

	aAux := aDadGRDA
	aDadGRDA := {}

	For i := 1 to len(aAux)

		If !Empty(aAux[i,1]+aAux[i,2]+aAux[i,3]+aAux[i,4]+aAux[i,5]+aAux[i,6]+aAux[i,7])
			AaDd(aDadGRDA,{aAux[i,1],aAux[i,2],aAux[i,3],aAux[i,4],aAux[i,5],aAux[i,6],aAux[i,7]})
		EndIf

	Next

	aDadGRDA := ASort(aDadGRDA,,, { |x,y| 	x[1] + x[3] + x[4] + x[5] + x[6] <;
		y[1] + y[3] + y[4] + y[5] + y[6] })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    TMKEXCRDA     ºAutor  ³DAVID DE OLIVEIRA º Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKEXCRDA(oGuiRda,aDadGRDA)

	Local nSelLine 	:= oGuiRda:nAt
	Local i			:= 0
	Local aDadAux	:= aDadGRDA

	aDadGRDA := {}

	For i := 1 to Len(aDadAux)

		If i <> nSelLine

			AaDd(aDadGRDA,aDadAux[i])

		EndIf

	Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    TMKAUTCON     ºAutor  ³DAVID DE OLIVEIRA º Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKAUTCON(aDadGRDA,cTipAut)

	Local nFor
	Local aProc 	:= {}
	Local cRda  	:= iiF(Len(aDadGRDA) > 0 ,aDadGRDA[1,1]+aDadGRDA[1,3]+aDadGRDA[1,4],"")
	Local cCid		:= ""
	Local cRegSol	:= ""
	Local cRegExe	:= ""
	Local cMvPLSCDCO := GETMV("MV_PLSCDCO")


	If !empty(cRda)
		For nFor := 1 to Len(aDadGRDA)

			cRda  := aDadGRDA[nFor,1]+aDadGRDA[nFor,3]+aDadGRDA[nFor,4]

			If aDadGRDA[nFor,5]+aDadGRDA[nFor,6] <> cMvPLSCDCO
				AaDd(aProc,{aDadGRDA[nFor,5]+aDadGRDA[nFor,6]})
			EndIf

			If 	nFor+1 > Len(aDadGRDA) .OR.;
					cRda <> aDadGRDA[nFor+1,1]+aDadGRDA[nFor+1,3]+aDadGRDA[nFor+1,4] .or. ;
					aDadGRDA[nFor,5]+aDadGRDA[nFor,6] = cMvPLSCDCO

				BB8->(DbSetOrder(1))
				BB8->(MsSeek(xFilial("BB8")+aDadGRDA[nFor,1]+BA1->BA1_CODINT+SubStr(aDadGRDA[nFor,3],1,3)))
				inclui := .T.
				If aDadGRDA[nFor,5]+aDadGRDA[nFor,6] = cMvPLSCDCO
					PLSA090MOV("BEA",0,K_Incluir,nil,nil,cTipAut,.F.,,aDadGRDA[nFor,1],BB8->(BB8_CODLOC+BB8_LOCAL),SubStr(aDadGRDA[nFor,4],1,3),nil,.T.)
				Else

					If  GetNewPar("MV_PLCIDSO","1") == "1"

						If Pergunte("PLTMK3",.T.)

							cCid	:= MV_PAR01
							cRegSol	:= MV_PAR02
							cRegExe	:= MV_PAR03

						EndIf

					EndIf

					PLSA090MOV("BEA",0,K_Incluir,nil,nil,cTipAut,.F.,,aDadGRDA[nFor,1],BB8->(BB8_CODLOC+BB8_LOCAL),SubStr(aDadGRDA[nFor,4],1,3),aProc,nil,cCid,cRegSol,cRegExe)
				EndIf

				If cTipAut = '1'
					PlsTmkOco('7')
				ElseIf cTipAut = '2'
					PlsTmkOco('6')
				EndIf

				aProc := {}

			EndIf

		Next
	Else
		Help( " ", 1, "NVAZIO",,STR0132 + " " + STR0133,4,0 )
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    TMKPLSREG     ºAutor  ³DAVID DE OLIVEIRA º Data ³07/07/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKPLSREG(cCodOpe,cMun)

	Local aReg := {__cTextoAll}
	Local cSql := ''

	cSql := "SELECT BIB_CODREG, BIB_DESCRI "
	cSql += "FROM "+RetSqlName("BIB")+" "
	cSql += "WHERE BIB_FILIAL = '"+xFilial("BIB")+"' "
	cSql += "AND BIB_CODINT = '"+cCodOpe+"' "

	If subs(cMun,1,7) <> Subs(__cTextoAll,1,7)
		cSql += "AND BIB_ESPMUN = '"+cMun+"' "
	Endif

	cSql += "AND D_E_L_E_T_ <> '*' "

	PlsQuery(cSql,"BIBTRB")

	While !BIBTRB->(Eof())

		AaDd(aReg,BIBTRB->BIB_CODREG+"-"+BIBTRB->BIB_DESCRI)

		BIBTRB->(DbSkip())
	EndDo

	BIBTRB->(DbCloseArea())

	If Len(aReg) == 1
		aReg := {""}
	Endif

Return(aReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    PlsLinVetor   ºAutor  ³                  º Data ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsLinVetor()

	Local nPos := aScan(aVetor, {|x| x[24]==BA1->(Recno())} )

	If nPos = 0

		DbSelectArea("BA1")
		nPos := aScan(aVetor, {|x| x[24]==BA1->(Recno())} )

	EndIf

Return(nPos)

/*/{Protheus.doc} PLS09PTmk
	(Funcao criada para receber os parametros da funcao PLS09PMov e antes de executa-la
	criar os campos do MENUDEF do código PLSA09P, pois trocamos a tela de Evolução/Prorrogação da Internação )
	@type  Static Function
	@author Gabriel Mucciolo
	@since 2022-05-12
	@version P12
/*/
Static Function PLS09PTmk(cAlias,nReg,nOpc,lAudit, cGuiRef, cNumProTMK)
	DEFAULT cAlias := ''
	DEFAULT nReg := 0
	DEFAULT nOpc := 0
	DEFAULT lAudit := .F.
	DEFAULT cGuiRef := ''
	DEFAULT cNumProTMK := ''
	PRIVATE aAutForAnx 	:= {}
	PRIVATE aCodCriHis 	:= {}

	PLS09PMov(cAlias, nReg, nOpc, lAudit, cGuiRef, cNumProTMK)
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao       ºAutor  ³                  º Data ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsFunAte(cCodint, cCodEmp, cMatric, cTipReg,cCodRda, cNumProTMK)
	Local aArea		:= {}
	Local aDadBEA	:= {}
	Local aCabBEA	:= {}
	Local aTrbBEA	:= {}
	Local oDadBEA
	Local oDlg
	Local bOK		:= {||oDlg:End()}
	Local bCancel	:= {||oDlg:End()}
	Local cAnoAut	 := ""
	Local cMesAut	 := ""
	Local cOrigem	 := ""
	Local cNumAut	 := ""
	Local oRadio
	Local oDlgRd
	Local nRadio   	 := 1
	Local nOpca    	 := 0
	Local bBotBus	:= {||GdSeek(oDadBEA,OemtoAnsi(STR0149),oDadBEA:aHeader,oDadBEA:aCols,.F.)}
	Local bBotVis	:= {||BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		PlTmkVis(oDadBEA)}
	Local bBotExc	:= {||BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		PLXTMKBE4(BEA->BEA_OPEMOV,BEA->BEA_ANOINT,BEA->BEA_MESINT,BEA->BEA_NUMINT),;
		Iif(BEA->BEA_TIPGUI == "03",PLSA092Mov("BE4",BE4->(Recno()),K_Excluir),PLSA090MOV("BEA",BEA->(Recno()),K_Excluir,,,cOrigem)),;
		oDlg:End(),;
		PlsTmkOco('18')}
	Local bBotCan	:= {||BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		PLSA090CAN(),;
		oDlg:End(),;
		PlsTmkOco('18')}
	Local bBotRas	:= {||BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		PLSA090RAS(),;
		oDlg:End(),;
		PlsTmkOco('20')}
	Local bBotVisGIH:= {||aTela := {},;
		agets := {},;
		inclui := .F.,;
		BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		BE4->(MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) ),;
		PLSA092Mov("BE4",BE4->(Recno()),K_Visualizar),;
		inclui := .T.}
	Local bBotEvo	:= {||aTela := {},;
		agets := {},;
		inclui := .T.,;
		BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		BE4->(MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) ),;
		PLS09PTmk("B4Q",0, K_Incluir, .F., BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT), cNumProTMK),;
		PlsTmkOco('21')}
	Local bBotDInt	:= {||BEA->( DbClearFilter() ),;
		BEA->(DbGoTo(aTrbBEA[oDadBEA:oBrowse:nAt])),;
		BE4->(MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) ),;
		PLSA92DtIn(),;
		PlsTmkOco('22')}
	Local bBotVaz	:= {|| MsgInfo(STR0154)}

	Local aButtons	:= {}
	Local aStruBEA	:= BEA->(DbStruct())
	Local nCntFor	:= 0
	Local nX		:= 0
	Local cQuery	:= ""
	Local lQuery	:= .T.
	Local cAliasBEA := ""
	Local cExpFil	:= ""
	Local aButtonUsr:= {}
	Default cCodint	:= ""
	Default cCodEmp := ""
	Default cMatric	:= ""
	Default cTipReg	:= ""
	Default cCodRda  := ""
	Default cNumProTMK  := ""

	aArea := GetArea()

	/*
AjustaSU9()
AjustaB20()
	*/

	DEFINE MSDIALOG oDlg FROM 0,0 TO 80,227 PIXEL TITLE STR0136 //"Manipulação de Atendimentos"

	@ 001,003 TO 040,080 LABEL STR0137 OF oDlg PIXEL //"Funções Disponíveis"
	@ 008,008 RADIO oRadio VAR nRadio 3D SIZE 060,009 ITEMS STR0138,STR0139,STR0140  PIXEL OF oDlg

	DEFINE SBUTTON FROM 003,084  TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 020,084 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

	If nOpca == 0
		Return()
	Endif

	AaDd(aButtons,{ "S4WB011N",bBotBus, OemtoAnsi(STR0141)} ) //"Busca"

	If nRadio = 1
		cExpFil := "BEA_ORIMOV IN ('1','2','3','4')"
		cCadastro := STR0138
	ElseIf nRadio = 2 .and. BEA->(FieldPos("BEA_STALIB")) > 0
		cExpFil := "BEA_ORIGEM ='2'"
		cCadastro := STR0139
	ElseIf nRadio = 3
		cExpFil := "BEA_ORIMOV = '2'"
		dbSelectArea("BE4")
		BE4->(DbSetOrder(2))
		cCadastro := STR0140
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as criticas relacionadas ao procedimento...                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BEA" TO aCabBEA For .T.

	cQuery    	:= ""
	lQuery 		:= .T.
	cAliasBEA 	:= "QRYBEA"

	cQuery := "SELECT BEA.R_E_C_N_O_ BEAREC "
	cQuery += " FROM "
	cQuery += RetSqlName("BEA")+ " BEA "
	cQuery += " WHERE "
	cQuery += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
	cQuery += "BEA_OPEUSR = '"+cCodint+"' AND "
	if(!empty(cMatric))
		cQuery += "BEA_CODEMP = '"+cCodEmp+"' AND "
		cQuery += "BEA_MATRIC = '"+cMatric+"' AND "
		cQuery += "BEA_TIPREG = '"+cTipReg+"' AND "
	endif

	if(!empty(cCodRda))
		cQuery += "BEA_CODRDA = '"+cCodRda+"' AND "
	endIf
	If !Empty(cExpFil)
		cQuery += cExpFil+" AND "
	EndIf
	cQuery += "BEA.D_E_L_E_T_ = ' ' "
	//cQuery += "ORDER BY BEA_FILIAL,BEA_OPEUSR,BEA_CODEMP,BEA_MATRIC,BEA_TIPREG"
	cQuery += "ORDER BY BEA_FILIAL,BEA_OPEUSR,BEA_CODEMP,BEA_MATRIC,BEA_TIPREG,BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,BEA_ORIGEM"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasBEA,.F.,.T.)

	For nCntFor := 1 To Len(aStruBEA)
		If ( aStruBEA[nCntFor,2]<>"C" )
			TcSetField(cAliasBEA,aStruBEA[nCntFor,1],aStruBEA[nCntFor,2],aStruBEA[nCntFor,3],aStruBEA[nCntFor,4])
		EndIf
	Next nCntFor

	While (cAliasBEA)->(!Eof())
		BEA->(DbGoTo((cAliasBEA)->BEAREC))

		Aadd(aDadBEA,Array(Len(aCabBEA)+1))

		For nX := 1 To Len(aCabBEA)
			If ( aCabBEA[nX,10] !=  "V" )
				aDadBEA[Len(aDadBEA)][nX] := BEA->(FieldGet(FieldPos(aCabBEA[nX,2])))
			Else
				aDadBEA[Len(aDadBEA)][nX] := CriaVar(aCabBEA[nX,2],.T.)
			EndIf
		Next nX
		aDadBEA[Len(aDadBEA)][Len(aCabBEA)+1] := .F.

		Aadd(aTrbBEA, (cAliasBEA)->BEAREC )

		dbSelectArea(cAliasBEA)

		(cAliasBEA)->(dbSkip())
	EndDo

	If Empty(aDadBEA)
		BEA->(MsGoto(0))
		Store COLS Blank "BEA" TO aDadBEA FROM aCabBEA
	EndIf

	(cAliasBEA)->(dbCloseArea())
	dbSelectArea("BEA")
	BEA->(DbSetOrder(2))
	dbSelectArea("BE1")
	BE1->(DbSetOrder(1))

	cAnoAut  := aDadBEA[1,GdFieldPos("BEA_ANOAUT",aCabBEA)]
	cMesAut  := aDadBEA[1,GdFieldPos("BEA_MESAUT",aCabBEA)]
	cNumAut	 := aDadBEA[1,GdFieldPos("BEA_NUMAUT",aCabBEA)]
	cOrigem	 := aDadBEA[1,GdFieldPos("BEA_ORIGEM",aCabBEA)]

	If nRadio = 1
		AaDd(aButtons,{ "SUMARIO" 	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotVis), OemtoAnsi(STR0142)} ) //"Visualizar"
		AaDd(aButtons,{ "EXCLUIR" 	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotExc), OemtoAnsi(STR0143)} ) //"Excluir"
		AaDd(aButtons,{ "S4WB004N"	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotCan), OemtoAnsi(STR0144)} ) //"Cancelar"
		cExpFil := "BEA_ORIMOV IN ('1','3','4')"
	ElseIf nRadio = 2 .and. BEA->(FieldPos("BEA_STALIB")) > 0
		AaDd(aButtons,{ "SUMARIO" 	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotVis), OemtoAnsi(STR0142)} ) //"Visualizar"
		AaDd(aButtons,{ "LOCALIZA"  ,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotRas), OemtoAnsi(STR0145)} ) //"Rastrear"
		cExpFil := "BEA_ORIGEM ='2'"
	ElseIf nRadio = 3
		AaDd(aButtons,{ "SUMARIO" 	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotVisGIH), OemtoAnsi(STR0142)} ) //"Visualizar"
		AaDd(aButtons,{ "NOTE"  	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotEvo), OemtoAnsi(STR0146)} ) //"Evolução"
		AaDd(aButtons,{ "SDUPROPR"	,Iif(Empty(cAnoAut+cMesAut+cNumAut),bBotVaz,bBotDInt), OemtoAnsi(STR0147)} ) //"Dt. Intern."
		cExpFil := "BEA_ORIMOV = '2'"
		dbSelectArea("BE4")
		BE4->(DbSetOrder(2))
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0148 FROM 008.0,010.3 TO 034.4,100.3

	oDadBEA		:= MsNewGetDados():New(033,010,180,340,0,,,,,,9999,,,,oDlg,aCabBEA,aDadBEA)
	oDadBEA:oBrowse:bGotFocus  := {|| 	cAnoAut  := oDadBEA:aCols[oDadBEA:oBrowse:nAt,GdFieldPos("BEA_ANOAUT",aCabBEA)],;
		cMesAut  := oDadBEA:aCols[oDadBEA:oBrowse:nAt,GdFieldPos("BEA_MESAUT",aCabBEA)],;
		cOrigem  := oDadBEA:aCols[oDadBEA:oBrowse:nAt,GdFieldPos("BEA_ORIGEM",aCabBEA)],;
		cNumAut	 := oDadBEA:aCols[oDadBEA:oBrowse:nAt,GdFieldPos("BEA_NUMAUT",aCabBEA)]}
	oDadBEA:oBrowse:bChange  	:= {|| Eval(oDadBEA:oBrowse:bGotFocus)}

	If ExistBlock('PLFUNBOT')
		aButtonUsr := ExecBlock('PLFUNBOT',.F.,.F.,{cCodint, cCodEmp, cMatric, cTipReg, oDadBEA})
		If ValType(aButtonUsr) == 'A'
			For nX := 1 to Len(aButtonUsr)
				aAdd(aButtons,aClone(aButtonUsr[nX]))
			Next nX
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOk,bCancel,.F.,aButtons) } )

	Restarea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao       ºAutor  ³                  º Data ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsLibEsp(cCodint, cCodEmp, cMatric, cTipReg)
	Local aDadBE2	:= {}
	Local aCabBE2	:= {}
	Local aTrbBE2	:= {}
	Local oDadBE2
	Local oDlg
	Local bOK		:= {||oDlg:End()}
	Local bCancel	:= {||oDlg:End()}
	Local cAnoAut	 := ""
	Local cMesAut	 := ""
	Local cNumAut	 := ""
	Local bBotBus	:= {||GdSeek(oDadBE2,OemtoAnsi(STR0149),oDadBE2:aHeader,oDadBE2:aCols,.F.)}
	Local bBotVis	:= {||Iif(Valtype(aDadBE2) <> "U",PosLibEsp(aDadBE2[oDadBE2:nAt]),PosLibEsp()),;
		PLSA460Vis("BE2",BE2->(Recno()))}
	Local bBotLib	:= {||Iif(Valtype(aDadBE2) <> "U",PosLibEsp(aDadBE2[oDadBE2:nAt]),PosLibEsp()),;
		PLSA460Lib(),;
		oDlg:End()}
	Local bBotNeg	:= {||Iif(Valtype(aDadBE2) <> "U",PosLibEsp(aDadBE2[oDadBE2:nAt]),PosLibEsp()),;
		PLSA460Neg(),;
		oDlg:End()}
	Local aButtons	 := {}
	Local aStruBE2	:= BE2->(DbStruct())
	Local nCntFor	:= 0
	Local nX		:= 0
	Local cQuery	:= ""
	Local lQuery	:= .T.
	Local cAliasBEA := ""

	Default cCodint	:= ""
	Default cCodEmp := ""
	Default cMatric	:= ""
	Default cTipReg	:= ""

	AaDd(aButtons,{ "S4WB011N"	,bBotBus, OemtoAnsi(STR0149)} ) //"Busca"
	AaDd(aButtons,{ "SUMARIO" 	,bBotVis, OemtoAnsi(STR0142)} ) //"Visualizar"
	AaDd(aButtons,{ "NOTE"  	,bBotLib, OemtoAnsi(STR0150)} ) //"Liberar"
	AaDd(aButtons,{ "EXCLUIR"  	,bBotNeg, OemtoAnsi(STR0151)} ) //"Liberar"

	Store Header "BE2" TO aCabBE2 For .T.

	cQuery    	:= ""
	lQuery 		:= .T.
	cAliasBE2 	:= "QRYBE2"

	cQuery := "SELECT BE2.*, BE2.R_E_C_N_O_ BE2REC "
	cQuery += " FROM "
	cQuery += RetSqlName("BE2")+ " BE2 "
	cQuery += " WHERE "
	cQuery += "BE2_FILIAL = '"+xFilial("BE2")+"' AND "
	cQuery += "BE2_OPEUSR = '"+cCodint+"' AND "
	cQuery += "BE2_CODEMP = '"+cCodEmp+"' AND "
	cQuery += "BE2_MATRIC = '"+cMatric+"' AND "
	cQuery += "BE2_TIPREG = '"+cTipReg+"' AND "
	cQuery += "BE2_NEGADA <> '1' AND "
	cQuery += "BE2_STATUS = '0' AND "
	cQuery += "BE2_AUDITO <> '1' AND "
	cQuery += "BE2_LIBESP = '1' AND "
	cQuery += "BE2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BE2_FILIAL,BE2_OPEUSR,BE2_CODEMP,BE2_MATRIC,BE2_TIPREG"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasBE2,.F.,.T.)

	For nCntFor := 1 To Len(aStruBE2)
		If ( aStruBE2[nCntFor,2]<>"C" )
			TcSetField(cAliasBE2,aStruBE2[nCntFor,1],aStruBE2[nCntFor,2],aStruBE2[nCntFor,3],aStruBE2[nCntFor,4])
		EndIf
	Next nCntFor

	While !Eof()

		Aadd(aDadBE2,Array(Len(aCabBE2)+1))

		For nX := 1 To Len(aCabBE2)
			If ( aCabBE2[nX,10] !=  "V" )
				aDadBE2[Len(aDadBE2)][nX] := (cAliasBE2)->(FieldGet(FieldPos(aCabBE2[nX,2])))
			Else
				aDadBE2[Len(aDadBE2)][nX] := CriaVar(aCabBE2[nX,2],.T.)
			EndIf
		Next nX
		aDadBE2[Len(aDadBE2)][Len(aCabBE2)+1] := .F.

		Aadd(aTrbBE2, (cAliasBE2)->BE2REC )

		dbSelectArea(cAliasBE2)
		dbSkip()
	EndDo

	If Empty(aDadBE2)
		BE2->(MsGoto(0))
		Store COLS Blank "BE2" TO aDadBE2 FROM aCabBE2
	EndIf

	(cAliasBE2)->(dbCloseArea())
	dbSelectArea("BE2")
	//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	BE2->(DbSetOrder(1))

	DEFINE MSDIALOG oDlg TITLE STR0152 FROM 008.0,010.3 TO 034.4,100.3

	cAnoAut  := aDadBE2[1,GdFieldPos("BE2_ANOAUT",aCabBE2)]
	cMesAut  := aDadBE2[1,GdFieldPos("BE2_MESAUT",aCabBE2)]
	cNumAut	 := aDadBE2[1,GdFieldPos("BE2_NUMAUT",aCabBE2)]

	oDadBE2		:= MsNewGetDados():New(022,005,180,340,0,,,,,,9999,,,,oDlg,aCabBE2,aDadBE2)
	oDadBE2:oBrowse:bGotFocus 	:= {|| 	cAnoAut  := oDadBE2:aCols[oDadBE2:oBrowse:nAt,GdFieldPos("BE2_ANOAUT",aCabBE2)],;
		cMesAut  := oDadBE2:aCols[oDadBE2:oBrowse:nAt,GdFieldPos("BE2_MESAUT",aCabBE2)],;
		cNumAut	 := oDadBE2:aCols[oDadBE2:oBrowse:nAt,GdFieldPos("BE2_NUMAUT",aCabBE2)]}
	oDadBE2:oBrowse:bChange  	:= {||Eval(oDadBE2:oBrowse:bGotFocus) }

	If Len(aDadBE2) <= 0
		@ 001,001 	SAY STR0153 SIZE 030,009 PIXEL COLOR CLR_HBLUE OF oDlg
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOk,bCancel,.F.,aButtons) } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PosLibEsp   ºAutor  ³ Victor Ferreira  º Data ³ 02/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Responsavel por posicionar corretamente o registro da      º±±
±±º          ³ da tabela BE2 ao Liberar/Negar/Visualizar uma Lib. Espec.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PosLibEsp(aDados)
	Local cOpeMov := ""
	Local cAnoAut := ""
	Local cMesAut := ""
	Local cNumAut := ""
	Local cSequen := ""

	Default aDados := {}

	If Len(aDados) > 0
		cOpeMov:= aDados[3]
		cAnoAut:= aDados[4]
		cMesAut:= aDados[5]
		cNumAut:= aDados[6]
		cSequen:= aDados[7]
	Endif

	BE2->(dbSetOrder(1)) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	BE2->(MsSeek(xFilial("BE2")+cOpeMov+cAnoAut+cMesAut+cNumAut+cSequen))

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao       ºAutor  ³                  º Data ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlGrAtTMK(cAlias,cNumAtd,nInd,cChave,lRec,lRet)
	Local lAchou	:= .T.
	Local cRet		:= ""
	Default cAlias 	:= ""
	Default cNumAtd	:= IIf(Funname() $ "TMKA271,TMKA380", M->UC_CODIGO, "" )
	Default nInd   	:= 0
	Default cChave 	:= ""
	Default lRec	:= .F.
	Default lRet	:= .T.

	If !Empty(cAlias) .and. !Empty(cNumAtd)

		If nInd <> 0 .and. !Empty(cChave)
			&(cAlias + "->(DbSetOrder(" + Str(nInd) + "))")
			lAchou := &(cAlias+"->(MsSeek(xFilial("+cAlias+")+"+cChave)
		EndIf

		If lAchou
			If lRec
				RecLock(cAlias,.F.)
				&(cAlias+"->("+cAlias+"_ATDTMK)") := cNumAtd
				&(cAlias+"->(msUnlock())")
			ElseIf  !lRet .and. &( cAlias+"->( FieldPos('"+cAlias+"_ATDTMK') )" ) > 0
				&(cAlias+"->("+cAlias+"_ATDTMK)") := cNumAtd
			ElseIf lRet
				cRet := cNumAtd
			EndIf
		EndIf

	EndIf

	If ExistBlock("PLGRVTMK")

		ExecBlock( "PLGRVTMK",.F.,.F., {cAlias,cNumAtd,nInd,cChave,lRec,lRet} )

	EndIf

Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam,cObj)

	If ((Alltrim(GetTheme()) == "CLASSIC") .OR. (Alltrim(GetTheme()) == "OCEAN")) .and. !SetMdiChild()
		Do Case
			Case cObj == '1'
				nTam := 100
			Case cObj == '2'
				nTam := 70
			Case cObj == '3'
				nTam := 170
		EndCase
	EndIf

Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   L()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function L(nTam)

	If ((Alltrim(GetTheme()) == "CLASSIC") .OR. (Alltrim(GetTheme()) == "OCEAN")) .and. !SetMdiChild()
		nTam := 25
	EndIf

Return Int(nTam)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PLSXButCap ³ Autores ³ TOTVS	               ³ Data ³11/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Tira o Caption do Botão quando o Ambiente MDI estiver em uso ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PLSXButCap(oBtn)
	If SetMdiChild()
		OBtn:cCaption:=""
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   |PlAfterAdd ³ Autores ³ TOTVS	               ³ Data ³25/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Ajusta legenda da nova linha.								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PlAfterAdd(aHeader, aCols)

	Local nCnt := Len(aCols)
	Local nX		:= 0
	Local nY		:= 0
	Local aHead2	:= {}
	Local aCols2	:= {}
	Local oVerde	:= LoaDbitmap(GetResources(),"BR_VERDE")
	Local oVerm		:= LoaDbitmap(GetResources(),"BR_VERMELHO")
	Local nPosStat := Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})

	If aScan(aHeader,{|x| AllTrim(x[2]) == "CHECKBOX" }) == 0

		AAdd(aHead2,{"","CHECKBOX","@BMP",2,00,,,"C",,"V"})

		For nX := 1 to Len(aHeader)
			AAdd(aHead2,aClone(aHeader[nX]))
		Next nX

		aHeader := aClone(aHead2)
	EndIf

	nPosStat := Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})

	For nX := 1 to nCnt
		If ValType(aCols[nX][1]) <> "O"
			aCols2 := {}
			AAdd(aCols2,Nil)

			If !Empty(aCols[nX][nPosStat]) .AND. aCols[nX][nPosStat] == "2"
				aCols2[1] := oVerde
			Else
				aCols2[1] := oVerm
			EndIf

			If Len(aCols[Len(aCols)]) < Len(aHeader) + 1
				For nY := 1 to Len(aCols[nX])
					AAdd(aCols2,aCols[nX][nY])
				Next nY
				aCols[nX] := aClone(aCols2)
			Else
				aCols[nX][1] := aCols2[1]
			EndIf
		EndIf
	Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   | AjustaSU9 ³ Autores ³ TOTVS	               ³ Data ³01/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Ajusta SU9.													 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
Static Function AjustaSU9()

Local aArea := GetArea()
Local cCod	:= ""

DbSelectArea("SU9")
DbSetOrder(2)

While !SU9->(Eof())

	If AllTrim(SU9->U9_DESC) == "Manip. Atend."
		cCod	:= AllTrim(SU9->U9_CODIGO)
		Exit
	EndIf
	SU9->(DbSkip())

EndDo

If Empty(cCod)

	SU9->(DbSkip(-1))
	cCod	:= AllTrim(SU9->U9_CODIGO)

	SU9->(RecLock("SU9",.T.))

		SU9->U9_FILIAL	:= xFilial("SU9")
		SU9->U9_CODIGO	:= Soma1(cCod)
		SU9->U9_DESC	:= "Manip. Atend."
		SU9->U9_ASSUNTO	:= StrZero(2,TamSx3("U9_ASSUNTO")[1])
		SU9->U9_VALIDO	:= "1"
		SU9->U9_TIPOATE	:= "1"

	SU9->(MsUnLock())

EndIf

RestArea(aArea)

Return
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   | AjustaB20 ³ Autores ³ TOTVS	               ³ Data ³01/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Ajusta B20.													 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
Static Function AjustaB20()

Local aArea 	:= GetArea()
Local cCodB20	:= ""
Local cCodSU9	:= FindMAtSU9()

DbSelectArea("B20")
DbSetOrder(1)

While !B20->(Eof())

	If AllTrim(B20->B20_DESC) == "Manip. Atend."
		cCodB20 := AllTrim(B20->B20_CODIGO)
		Exit
	EndIf
	B20->(DbSkip())

EndDo

If Empty(cCodB20)

	B20->(DbSkip(-1))
	cCodB20 := AllTrim(B20->B20_CODIGO)

	B20->(RecLock("B20",.T.))

		B20->B20_FILIAL := xFilial("B20")
		B20->B20_CODIGO := Soma1(cCodB20)
		B20->B20_DESC	:= "Manip. Atend."
		B20->B20_ASSUNT := StrZero(2,TamSx3("B20_ASSUNT")[1])
		B20->B20_DESCAS	:= "SOLICITACAO"
		B20->B20_OCORRE := IIf(Empty(cCodSU9),StrZero(24,TamSx3("B20_CODIGO")[1]),cCodSU9)
		B20->B20_DESCOC	:= "Manip. Atend."

	B20->(MsUnLock())

EndIf

RestArea(aArea)

Return
/*

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   |FindMAtB20 ³ Autores ³ TOTVS	               ³ Data ³03/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Encontra codigo da Manipulacao de Atendimento no B20		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FindMAtB20()

	Local aArea := GetArea()
	Local cCod	:= ""

	DbSelectArea("B20")
	DbSetOrder(1)
	DbGoTop()

	While ! B20->(Eof())

		If AllTrim(B20->B20_DESC) == STR0134
			cCod := CValToChar(Val(B20->B20_CODIGO))
			Exit
		EndIf
		B20->(DbSkip())

	EndDo

	RestArea(aArea)

Return cCod

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   |FindMAtSU9 ³ Autores ³ TOTVS	               ³ Data ³03/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Encontra codigo da Manipulacao de Atendimento no SU9		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
Static Function FindMAtSU9()

Local aArea := GetArea()
Local cCod	:= ""

DbSelectArea("SU9")
DbSetOrder(2)
DbGoTop()

While ! SU9->(Eof())

	If AllTrim(SU9->U9_DESC) == "Manip. Atend."
		cCod := SU9->U9_CODIGO
		Exit
	EndIf
	SU9->(DbSkip())

EndDo

RestArea(aArea)

Return cCod
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   |PLXTMKBE4  ³ Autores ³ TOTVS	               ³ Data ³31/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Posiciona no registro referente a internacao para exclusao   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLXTMKBE4(cCodOpe,cAnoInt,cMesInt,cNumInt)
	Local aArea := GetArea()

	BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
	If BEA->BEA_TIPGUI == "03"
		BE4->(MsSeek(xFilial("BE4")+cCodOpe+cAnoInt+cMesInt+cNumInt))
	Else
		RestArea(aArea)
		Return
	Endif

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLXTMKVIS   ºAutor  ³Microsiga         º Data ³  04/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PlTmkVis(oDadBEA)

	Local nPosTipo:=PLRETPOS("BEA_TIPO"  ,oDadBEA:AHEADER)
	Local nPosOpem:=PLRETPOS("BEA_OPEINT",oDadBEA:AHEADER)
	Local nPosAno :=PLRETPOS("BEA_ANOINT",oDadBEA:AHEADER)
	Local nPosMes :=PLRETPOS("BEA_MESINT",oDadBEA:AHEADER)
	Local nPosaut :=PLRETPOS("BEA_NUMINT",oDadBEA:AHEADER)

	If oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='1'
		PLSA090MOV("BEA",BEA->(Recno()),2,,,)
	ElseIf	oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='2'
		PLSA090MOV("BEA",BEA->(Recno()),2,,,)
	ElseIf	oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='3'
		BE4->(DbSetOrder(2))
		If BE4->(MsSeek(xFilial("BE4")+oDadBEA:ACOLS[oDadBEA:NAT,nPosOpem] + oDadBEA:ACOLS[oDadBEA:NAT,nPosAno] + oDadBEA:ACOLS[oDadBEA:NAT,nPosMes]  +oDadBEA:ACOLS[oDadBEA:NAT,nPosaut] ))
			PLSA092MOV("BE4",BE4->(Recno()),2)
		Endif
	ElseIf	oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='7'
		PLS09AMov("B4A",BEA->(Recno()),2)
	ElseIf	oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='8'
		PLS09AMov("B4A",BEA->(Recno()),2)
	ElseIf	oDadBEA:ACOLS[oDadBEA:NAT,nPosTipo]='9'
		PLS09AMov("B4A",BEA->(Recno()),2)
	Else
		PLSA090MOV("BEA",BEA->(Recno()),2,,,)
	Endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMotANSCC
Valid do campo UC_MOTPLS, indica se vai gerar protocolo ANS

@author  PLS TEAM
@version P11
@since    04.04.16
/*/
//-------------------------------------------------------------------
Function PLMotANSCC()
	Local cNumProt := Space(20)
	Local aArea    := {}
	Local lInterc  := .F.
	Local lRet     := .F.

	B3B->(DbSetOrder(1)) //B3B_FILIAL+B3B_CODIGO

	If GetNewPar("MV_PLRN395","0") == "1" .And. B3B->(DbSeek(xFilial("B3B")+M->UC_MOTPLS)) .And. B3B->B3B_GERPRO == "1"
		AC8->(DbSetOrder(1)) //AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
		BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		aArea    := AC8->(GetArea())

		If AC8->(DbSeek(xFilial("AC8")+M->UC_CODCONT)) .And. AC8->AC8_ENTIDA == "BA1" .And. BA1->(DbSeek(xFilial("BA1")+Alltrim(AC8->AC8_CODENT)))
			IIf(GetNewPar("MV_PLSUNI","1") == "1" .And. BA1->BA1_CODEMP == GetNewPar("MV_PLSGEIN","0050"),lInterc := .T.,lInterc := .F.)

			P773AutInc("SUC",@cNumProt,nil,lInterc,nil,nil,.T.,nil,Alltrim(AC8->AC8_CODENT))
		EndIf

		If (!Empty(cNumProt) .And. len(cNumProt) == 20) .Or. GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J")
			lRet := .T.
			If ExistBlock("PL773PE02")
				M->UC_PROTANS := cNumProt
			EndIf
		EndIf

		RestArea(aArea)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao for motivo que precisa de protocolo retorna .T. 					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := .T.
		M->UC_PROTANS := Space(20)
	EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTMKPRE
Tela do PLS no TMK com o perfil de Prestador.
@author Fábio S. dos Santos
@since 03/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSTMKPRE(cChvPre, nOpc, nTimeMin, nTimeSeg, cCrono, oCrono, oEnchTmk)
	Local lRet			:= .T.
	Local aArea			:= GetArea()	// Salva a area atual
	Local cTitulo		:= STR0002 //"Plano de Saúde"
	Local nOpcA			:= 0
	Local oDlgPls		:= Nil
	Local oMenuAut		:= {}
	Local cFilSC		:= "(BD6->BD6_FASE $ '1,2,3,4' .And. ( ( BD6->BD6_SITUAC = '1' ) .Or. ( BD6->BD6_SITUAC = '3' .And. BD6->BD6_LIBERA = '1' )  )  )"
	Local cFilHO		:= "(BE4->BE4_FASE $ '1,2,3,4' .And. BE4->BE4_SITUAC = '1')"
	Local bOk
	Local bCancel
	Local bBotMn1		:= {|| oMenuAut:Activate(C(200,'1'),L(45),oDlgPls)}
	Local aColsAux		:= {}
	Local aHeadAux		:= {}
	Local nRecBau := 0
	Local bBotComp		:= {|| aHeadAux := aHeader,;
		aColsAux := aCols,;
		PLSTMKBOT("1"),;
		cCadastro := STR0182,;
		PLSA365MNT("BAU",BAU->(Recno()),2),;
		aHeader := aHeadAux,;
		aCols := aColsAux,;
		N	:= Len(aCols),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('10')}

	Local bBotRDA		:= {|| PLSTMKBOT("1"),;
		PLSTMKRDA(),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('25')}

	Local bBotMov		:= {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PLHISMOV(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),cFilSC,cFilHO),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('1')}

	Local bBotBen		:= {|| PLSTMKBOT("1"),;
		aSlvrotina := aClone(aRotina),;
		aRotina := {},;
		PLSA730(),;
		aRotina := aClone(aSlvrotina),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('33')}

	Local bBotLib		:= {|| PLSTMKBOT("1"),;
		cCadastro := "Liberação",;
		nRecBau := BAU->(Recno()),;
		DbSelectArea("BEA"),;
		inclui := .T.,;
		PLSA090MOV("BEA",0,K_Incluir,nil,nil,"2",.F.,,BAU->BAU_CODIGO),;
		BEA->(DbCloseArea()),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('6')}

	Local bBotAut		:= {|| PLSTMKBOT("1"),;
		cCadastro := STR0259,; //"Autorização"
		nRecBau := BAU->(Recno()),;
		DbSelectArea("BEA"),;
		inclui := .T.,;
		PLSA090MOV("BEA",0,K_Incluir,nil,nil,"1",.F.,, BAU->BAU_CODIGO),;
		BEA->(DbCloseArea()),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('7')}

	Local bBotGih		:= {|| aTela := {},;
		agets := {},;
		PLSTMKBOT("1"),;
		cCadastro := STR0184,; //"Internação"
		nRecBau := BAU->(Recno()),;
		DbSelectArea("BE4"),;
		inclui := .T.,;
		PLSA092Mov("BE4",0,K_Incluir,,,BAU->BAU_CODIGO),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('8')}

	Local bBotOdo		:= {|| aTela := {},;
		agets := {},;
		PLSTMKBOT("1"),;
		cCadastro := STR0185,; //"Autorização Odontológica"
		nRecBau := BAU->(Recno()),;
		DbSelectArea("B01"),;
		inclui := .T.,;
		PLS090OMov("B01",0,K_Incluir,nil,nil,,,BAU->BAU_CODIGO),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('9')}

	Local bBotFunAte	:= {|| aColsAux := aCols,;
		PLSTMKBOT("1"),;
		nRecBau := BAU->(Recno()),;
		PlsFunAte(PLSINTPAD(), , , , BAU->BAU_CODIGO),;
		aCols := aColsAux,;
		N	:= Len(aCols),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco(FindMAtB20())}

	Local bBotIndPre	:= {|| PLSTMKBOT("1"),;
		aSlvrotina := aClone(aRotina),;
		aRotina := {},;
		nRecBau := BAU->(Recno()),;
		PL809FBRW(),;
		aRotina := aClone(aSlvrotina),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('27')}

	Local bBotNeg    := {|| PLSTMKBOT("1"),;
		aSlvrotina := aClone(aRotina),;
		aRotina := {},;
		PLSA813(),;
		aRotina := aClone(aSlvrotina),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('35')}

	Local bBotAltC	:= {|| PLSTMKBOT("1"),;
		nRecBau := BAU->(Recno()),;
		PL814FBRW(BAU->BAU_CODIGO, STR0186),; //"Alterações cadastrais"
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('36')}

	Local bBotResS	:= {|| PLSTMKBOT("1"),;
		nRecBau := BAU->(Recno()),;
		PlsResSen(BAU->BAU_CODIGO),;
		BAU->(DbGoTo(nRecBau)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('26')}

	Local bBotProt    := {|| PLSTMKBOT("1"),;
		nRecBa1 := BA1->(Recno()),;
		PlsRetPro(BAU->BAU_CODIGO, BAU->BAU_NOME),;
		BA1->(DbGoTo(nRecBa1)),;
		PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS),;
		PlsTmkOco('32')}

	Local aPosObj		:= {}
	Local aPosGet		:= {}
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aSize			:= MsAdvSize( .F. )
	Local oMonoAs		:= TFont():New( "Courier New",6,0) 			// Fonte para o campo Memo
	Local oBar
	Local oFolder
	Local cTimeIni		:= Time()
	Local cTimeFim		:= ""
	Local nSeg			:= 0
	Local nMin			:= 0
	Local i				:= 1
	Local nOpcao		:= 2
	Local aCpoBau		:= {}
	Local aBtn		:= {}
	Private cCodOpe  	:= PlsIntPad()

	If nOpc = K_Visualizar
		Return(.F.)
	EndIf

	AaDD(aRotina,{ "" , "" , 0 , K_Alterar    , 0, Nil})
	AaDD(aRotina,{ "" , "" , 0 , K_Excluir    , 0, Nil})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize:= MsAdvSize( .T., .F., 400)
	aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 0 , 0 }
	aObjects:= {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 150, .T., .T. } )
	AAdd( aObjects, { 50, 100, .T., .T. } )

	aPosObj:= MsObjSize( aInfo, aObjects ,.T.)

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

	DEFINE MSDIALOG oDlgPls TITLE cTitulo FROM 000,000 to aSize[6],aSize[5] OF oMainWnd PIXEL //  COLOR CLR_BLACK , CLR_LIGHTGRAY // CLR_HRED

	//Sub Menu Botaão bBotMn1
	MENU oMenuAut POPUP
	MENUITEM STR0013 	ACTION Eval(bBotLib) //"&Liberaçao"
	MENUITEM STR0014 	ACTION Eval(bBotAut) //"&Autotização"
	MENUITEM STR0015 	ACTION Eval(bBotGih) //"&GIH"
	If GetNewPar("MV_PLATIOD","0") == "1"
		MENUITEM STR0016 		ACTION Eval(bBotOdo) //"&Odonto"
	EndIf
	MENUITEM STR0134	ACTION Eval(bBotFunAte) //"Manip. Atend."
	ENDMENU

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Blocos de codigo para a EnchoiceBar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bOk 		:= {|| nOpcA:=1, oDlgPls:End() }
	bOkExclui 	:= {|| nOpcA:=1, oDlgPls:End() }
	bCancel 	:= {|| nOpcA:=0, oDlgPls:End() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta botoes                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE BUTTONBAR oBar SIZE 30,25 3D TOP OF oDlgPls

	aadd(aBtn,{"PLSIMG32","PLSIMG32",,,STR0187						, bBotComp	,.T.,oBar,,,STR0187 + " < F4 >"}) //"Complemento"
	aadd(aBtn,{"QADIMG32","QADIMG32",,,STR0028						, bBotRDA	,.T.,oBar,,,STR0028 + " < F5 >"}) //Consulta Rede de Atendimento
	aadd(aBtn,{"TABPRICE","TABPRICE",,,STR0188						, bBotProt	,.T.,oBar,,,STR0188 + " < F6 >"}) //"Dados de Faturamento"
	aadd(aBtn,{"DEPENDENTES","DEPENDENTES",,,STR0189					, bBotBen	,.T.,oBar,,,STR0189 + " < F7 >"}) //"Consultar Dados de Beneficiário"
	aadd(aBtn,{"PEDIDO","PEDIDO",,,STR0190								, bBotMn1	,.T.,oBar,,,STR0190 + " < F8 >"}) //"Guias"
	aadd(aBtn,{"TCFIMG32","TCFIMG32",,,STR0191						, bBotIndPre,.T.,oBar,,,STR0191 + " < F9 >"}) //"Indicação de Credenciamento"
	aadd(aBtn,{"CRMIMG32","CRMIMG32",,,STR0192						, bBotNeg	,.T.,oBar,,,STR0192 + " < F10 >"}) //"Consultar Passos de Negociação"
	aadd(aBtn,{"ALTERA","ALTERA",,,STR0193								, bBotAltC	,.T.,oBar,,,STR0193 + " < F11 >"}) //"Consultar passos de alteração contratual"
	aadd(aBtn,{"CADEADO","CADEADO",,,STR0181							, bBotResS	,.T.,oBar,,,STR0181 + " < Shift + F1 >"}) //"Resetar Senha"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para inclusão de botões na tela do plstmk  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLSTMKBT2")
		aBtn := ExecBlock("PLSTMKBT2",.F.,.F.,{aBtn, oBar})
	EndIf
	If Len(aBtn) > 0
		For i:=1 to Len(aBtn)
			// 1 - Tipo de botão
			// 2 - Descrição do botão
			// 3 - Função de usuário a ser executado  em bloco de código
			oBtn := TBtnBmp():NewBar( aBtn[I,1],aBtn[I,2],aBtn[I,3],aBtn[I,4],aBtn[I,5], aBtn[I,6],aBtn[I,7],aBtn[I,8],aBtn[I,9],aBtn[I,10],aBtn[I,11])
			PLSXButCap(oBtn)
		Next i
	Endif

	oBtn := TBtnBmp():NewBar( "OK","OK",,,STR0194, bOk,.T.,oBar,,,STR0194 )//OK
	oBtn:cTitle := "Ok"
	PLSXButCap(oBtn)

	oBtn := TBtnBmp():NewBar( "CANCEL","CANCEL",,,STR0032 , bCancel,.T.,oBar,,,STR0032 )//SAIR //"Sair"###"Sair"
	oBtn:cTitle := STR0032 //"Sair"
	PLSXButCap(oBtn)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Dados do Titular e Depedentes...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := PlsTreePre( cChvPre , oDlgPls , aPosObj)

	If !lRet
		Aviso(STR0007,STR0195,{STR0012},2) //"Atenção"###"Não foi encontrado o prestador para o contato informado!"###"Voltar"
		RestArea(aArea)
		Return()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apos posicionar no BAU, preencho as variaveis de momoria.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "BAU", .F., .F.,.F.)
	BAU->(DbSeek(xFilial("BAU") + cChvPre))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados Cadastrais. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("BAU")

	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BAU"
		aadd(aCpoBau,SX3->X3_CAMPO)

		SX3->(DbSkip())
	End

	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],{STR0196},{""},oDlgPls,1,,,.T.,.F.,(aPosObj[2,4]),aPosObj[2,3]) //Rede de Atendimento

	oEncFld1 := MSMGet():New("BAU",BAU->(Recno()),nOpcao,,,,	aCpoBau,{1,aPosObj[2,2],(aPosObj[2,3]-105),(aPosObj[2,4]-5)},aCpoBau,,,,,oFolder:aDialogs[01],,,.F.,,.F.,.T.)

	PLSTMKBOT("1",bBotComp,bBotRDA,bBotProt,bBotBen,bBotMn1,bBotIndPre,bBotNeg,bBotAltC,bBotResS)

	aEdit := {}

	AEval(aHeader, {|x| IIF(x[2]<>"CHECKBOX",AAdd(aEdit,x[2]),"")})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observacao das ocorrencias.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetTmkPls := MSGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],nOpc,"AllwaysTrue","AllwaysTrue","",.T.,aEdit,,,,,,,,oDlgPls)
	oGetTmkPls:OBROWSE:BADD := { || oGetTmkPls:LCHGFIELD := .F. ,oGetTmkPls:ADDLINE(),PlAfterAdd(aHeader, aCols)}

	ACTIVATE MSDIALOG oDlgPls

	If ( nOpcA == 1 ) .And. nOpc > 2

		If	MsgNoYes(STR0058)  //"Deseja Finalizar o Atendimento"

			If Empty(M->UC_OPERACA)
				M->UC_OPERACA := '2'
			EndIf

			If Empty(M->UC_STATUS)
				nPos := Ascan(aCols,{|x| x[PLRETPOS("UD_STATUS",aHeader)] $ ' ,1'})
				M->UC_STATUS := Iif( nPos > 0 , '2' , '3' )
			EndIf
		EndIf

	Else
		//Caso a tela seja cancelada
		lRet 	:= .F.
	EndIf

	//restaura botoes
	PLSTMKBOT("1")

	cTimeFim := Time()
	nMin := Val(SubStr(ElapTime(cTimeIni,cTimeFim),4,2))
	nSeg := Val(SubStr(ElapTime(cTimeIni,cTimeFim),7,2))

	nTimeMin += nMin
	nTimeSeg += nSeg

	PLSTKAtuCro(	@nTimeSeg	,@nTimeMin	,"00:00"	,@cCrono	,	@oCrono		)

	RestArea(aArea)
	oEnchTmk:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsTREEPre
Monta o DBTree.
@author Fábio S. dos Santos
@since 04/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PlsTREEPre( cCodRda , oDlgPls , aPosObj )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o DBTree do Contrato.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@aPosObj[1,1]+5,aPosObj[1,2] TO aPosObj[1,3] , ((aPosObj[1,4])/2) LABEL STR0197 COLOR CLR_HBLUE  OF oDlgPls PIXEL //"Locais de Atendimento"

	oTreeCon := XTree():New((aPosObj[1,1]+15),(aPosObj[1,2]+2),(aPosObj[1,3]-2),((aPosObj[1,4]/2)-2),oDlgPls,/*uChange*/,{||M100Edit(oTreeCon:GetCargo())},/*bDblClick*/)
	oTreeCon:BeginUpdate()
	oTreeCon:Reset()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta DbTree para os Locais de Atendimento e Especialidades         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("BB8")
	DBSetOrder(6) // BB8_FILIAL+BB8_CODINT+BB8_CODIGO+BB8_CODLOC
	If DbSeek(xFilial("BB8")+cCodOpe+cCodRda)
		DbSelectArea("BAX")
		BAX->(DBSetOrder(4)) // BAX_FILIAL+BAX_CODINT+BAX_CODIGO+BAX_CODLOC+BAX_CODESP

		While !BB8->(Eof()) .And. BB8->BB8_FILIAL + BB8->BB8_CODINT + BB8->BB8_CODIGO == xFilial("BB8")+cCodOpe+cCodRda
			oTreeCon:AddTree(AllTrim(BB8->BB8_DESLOC) + " - " + AllTrim(BB8->BB8_END) + " " + AllTrim(BB8->BB8_NR_END) + " " + AllTrim(BB8->BB8_COMEND)+ " " + AllTrim(BB8->BB8_MUN) + " " + AllTrim(BB8->BB8_EST),"PLNPROP","PLNPROP","BB8/"+StrZero(BB8->(Recno()),6)+"/Local de Atendimento")
			BAX->(DbSeek(xFilial("BAX")+BB8->BB8_CODINT+BB8->BB8_CODIGO+BB8->BB8_CODLOC))
			While !BAX->(Eof()) .And. BAX->BAX_FILIAL + BAX->BAX_CODINT + BAX->BAX_CODIGO + BAX->BAX_CODLOC == BB8->BB8_FILIAL + BB8->BB8_CODINT + BB8->BB8_CODIGO + BB8->BB8_CODLOC

				oTreeCon:AddTreeItem(Posicione("BAQ",1,xFilial("BAQ")+BAX_CODINT+BAX_CODESP,"BAQ->BAQ_DESCRI"),"PLNPROP","BAQ/"+StrZero(BAQ->(Recno()),6)+"/" + STR0198)//Especialidades

				BAX->(DbSkip())
			End
			oTreeCon:EndTree()
			BB8->(DbSkip())
		End

		oTreeCon:EndUpdate()
		oTreeCon:Refresh()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o DBTree do Contatos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@aPosObj[1,1]+5,((aPosObj[1,4])/2) TO aPosObj[1,3], aPosObj[1,4] LABEL STR0199  COLOR CLR_HBLUE OF oDlgPls PIXEL // "Contatos"

		oTreeUsr := XTree():New((aPosObj[1,1]+15),((aPosObj[1,4]/2)+2),(aPosObj[1,3]-2),((aPosObj[1,4])-2),oDlgPls,/*uChange*/,{||M100Edit(oTreeUsr:GetCargo())},/*bDblClick*/)
		oTreeUsr:BeginUpdate()
		oTreeUsr:Reset()

		DbSelectArea("BBG")
		DbSetOrder(1)
		BB8->(DbSeek(xFilial("BB8")+cCodOpe+cCodRda))
		oTreeUsr:AddTree("","GROUP","GROUP",)
		While !BB8->(Eof()) .And. BB8->BB8_FILIAL + BB8->BB8_CODINT + BB8->BB8_CODIGO == xFilial("BB8")+cCodOpe+cCodRda

			BAX->(DbSeek(xFilial("BAX")+BB8->BB8_CODINT+BB8->BB8_CODIGO+BB8->BB8_CODLOC))
			While !BAX->(Eof()) .And. BAX->BAX_FILIAL + BAX->BAX_CODINT + BAX->BAX_CODIGO + BAX->BAX_CODLOC == BB8->BB8_FILIAL + BB8->BB8_CODINT + BB8->BB8_CODIGO + BB8->BB8_CODLOC
				If BBG->(DbSeek(xFilial("BBG") + BAX->BAX_CODIGO + BAX->BAX_CODINT + BAX->BAX_CODLOC + BAX->BAX_CODESP))
					While !BBG->(Eof()) .And. BAX->BAX_FILIAL + BAX->BAX_CODINT + BAX->BAX_CODIGO + BAX->BAX_CODLOC == BBG->BBG_FILIAL + BBG->BBG_CODINT + BBG->BBG_CODIGO + BBG->BBG_CODLOC
						oTreeUsr:AddTreeItem(BBG->BBG_NOME + " - " + BBG->BBG_EMAIL + " - " + BBG->BBG_TEL,"DEPENDENTES","BBG/"+StrZero(BBG->(Recno()),6)+"/" + STR0199)
						BBG->(DbSkip())
					End
					oTreeUsr:EndTree()
				EndIf
				BAX->(DbSkip())
			End

			BB8->(DbSkip())
		End

		oTreeUsr:EndUpdate()
		oTreeUsr:Refresh()
	Else
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsResSen
Resetar senha
@author Karine Riquena Limp
@since 12/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlsResSen(cCodRda, cMatric)

	Static objCENFUNLGP := CENFUNLGP():New()

	Local aArea		:= getArea()
	LOCAL oDlgLogin
	LOCAL oListaLogin
	LOCAL lRet := .F.
	LOCAL aLogin := {}
	Local cSql := ""
	Local nCount := 0
	Local nRecno := 0
	local cSenha := ""
	local cCripto := ""
	local nOpca := 0
	default cCodRda := ""
	default cMatric := ""
	private cSenhaTmk := ""

	if(!empty(cCodRda))
		cSql += " select BSW_LOGUSR, BSW.R_E_C_N_O_ AS RECNO "
		cSql += " FROM " + RetSqlName("BSO") + " BSO "
		cSql += " INNER JOIN " + RetSqlName("BSW") + " BSW ON(BSO.BSO_CODUSR = BSW.BSW_CODUSR) "

		cSql += " WHERE BSO.BSO_CODIGO = '" + cCodRda + "' "
		cSql += " AND BSW.BSW_TPPOR = '1' "
		cSql += " AND BSO.BSO_FILIAL = '" + xFilial("BSO") + "' "
		cSql += " AND BSW.BSW_FILIAL = '" + xFilial("BSW") + "' "
		cSql += " AND BSO.D_E_L_E_T_ <> '*' "
		cSql += " AND BSW.D_E_L_E_T_ <> '*' "
	elseif(!empty(cMatric))
		cSql += " select BSW_LOGUSR, BSW.R_E_C_N_O_ AS RECNO "
		cSql += " FROM " + RetSqlName("B49") + " B49 "
		cSql += " INNER JOIN " + RetSqlName("BSW") + " BSW ON(B49.B49_CODUSR = BSW.BSW_CODUSR) "

		cSql += " WHERE B49.B49_BENEFI = '" + cMatric + "' "
		cSql += " AND BSW.BSW_TPPOR <> '1' "
		cSql += " AND B49.B49_FILIAL = '" + xFilial("B49") + "' "
		cSql += " AND BSW.BSW_FILIAL = '" + xFilial("BSW") + "' "
		cSql += " AND B49.D_E_L_E_T_ <> '*' "
		cSql += " AND BSW.D_E_L_E_T_ <> '*' "
	endIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBSW",.F.,.T.)

	while TrbBSW->(!eof())
		aadd(aLogin, {TrbBSW->BSW_LOGUSR, TrbBSW->RECNO} )
		nCount++
		TrbBSW->(dbSkip())
	endDo

	TrbBSW->(dbCloseArea())

	if nCount == 0
		msgAlert(STR0200) //"Não existem usuários de portal vinculados!"
	elseif nCount == 1
		cLogin := aLogin[1][1]
		nRecno := aLogin[1][2]
		nOpca := 1
	else

		//exibir apenas se achar mais de um login só
		DEFINE MSDIALOG oDlgLogin TITLE STR0201 FROM 018,005 TO 28, 100 //"Usuários vinculados"

		oListaLogin := TcBrowse():New( 020, 002, 372, 062,,,, oDlgLogin,,,,,,,,,,,, .F.,, .T.,, .F., )
		oListaLogin:SetArray(aLogin)

		oListaLogin:AddColumn(TcColumn():New(STR0202,nil,nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil)) //"Usuário "
		oListaLogin:ACOLUMNS[1]:BDATA     := { || aLogin[oListaLogin:nAt,1] }

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		if objCENFUNLGP:isLGPDAt()
			aCampos := {"BSW_LOGUSR"}
			aBls := objCENFUNLGP:getTcBrw(aCampos)

			oListaLogin:aObfuscatedCols := aBls
		endif

		TButton():New(005,002,STR0203,,{|| nOpca := 1, cLogin := aLogin[oListaLogin:nAt,1], nRecno := aLogin[oListaLogin:nAt,2], oDlgLogin:End()},040,012,,,,.T.) //'Confirmar'
		TButton():New(005,060,STR0204,, {|| nOpca := 0, oDlgLogin:End()},040,012,,,,.T.) //'Cancelar'

		ACTIVATE MSDIALOG oDlgLogin CENTERED

	endIf

	if nOpca <> 0
		If MsgYesNo(STR0205,STR0007) //"Deseja redefinir a senha?"#"Atenção"
			begin transaction
				cSenhaTmk := alltrim(str(Randomize( 10, 100))) + alltrim(str(Randomize( 10, 100))) + alltrim(str(Randomize( 10, 100))) + alltrim(str(Randomize( 10, 100)))
				cCripto := PLSCRIDEC(1,AllTrim(cSenhaTmk))
				BSW->(dbGoto(nRecno))
				BSW->(RecLock('BSW'),.f.)
				BSW->BSW_SENHA := cCripto
				BSW->BSW_DTSEN := ddatabase
				BSW->(MsUnlock())
			end transaction
			BOJ->(DbSetOrder(3))
			BOJ->(MsSeek(xFilial("BOJ") + "PLSXTMK" + (Space(TamSx3("BOJ_ROTINA")[1] - 7))))

			PLSinaliza(BOJ->BOJ_CODSIN,nil,nil, alltrim(BSW->BSW_EMAIL), STR0206,,,,,, .F.,"",,,) //"Envio email redefinição de senha"

			msgInfo(STR0207 + BSW->BSW_EMAIL) //"Senha redefinida com sucesso, foi enviada no email "
		EndIf
	endIf


	Restarea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSxTMKAUD
Abrir a rotina de auditoria filtrando pelo beneficiario
@author Karine Riquena Limp
@since 13/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSxTMKAUD(cCodint, cMatric)
	LOCAL cFil := " B53_FILIAL = '" + xFilial('B53') + "' .AND. "
	cFil +=	" B53_CODOPE = '" + cCodint + "' .AND. "
	cFil +=	" B53_MATUSU = '" + cMatric + "' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//| Chama rotina de auditoria
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	PLSA790V(1,cFil)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//| Fim da Rotina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSConSol
Consulta solicitações do portal beneficiário
@author Fábio S. dos Santos
@since 13/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSConSol(cMatric)
	Local aArea		:= GetArea()
	Local oDlg
	Local cTitulo 	:= "Consulta Solicitações de Portal"
	Local oLbx
	Local aVetor := {}

	Processa({||PLSAtuSol(@aVetor,cMatric)},"Consulta de Solicitações","Atualizando consulta...Aguarde!") //Consulta de Solicitações#Atualizando consulta...Aguarde!

	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
	If Len( aVetor ) == 0
		Aviso( cTitulo , "Não foram encontrados registros para o beneficiário!", {"Ok"} )
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 640,900 Pixel

	@ 10,10 LISTBOX oLbx FIELDS HEADER "Origem", "Data", "Hora", "Status" SIZE 430,290 OF oDlg PIXEL ColSizes 60,50

	oLbx:SetArray( aVetor )
	oLbx:bLine := { || {	aVetor[oLbx:nAt,1],;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4]}}
	DEFINE SBUTTON FROM 307,413 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER


	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSAtuSol ºAutor  ³Fábio S. dos Santos º Data ³ 13/05/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca os dados nas tabelas.					              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSAtuSol(aVetor,cMatric)
	Local cQuery	:= ""
	Local cStatus	:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados da segunda via											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT BED_DTSOLI, BED_STACAR, BED_VIACAR FROM " + RetSqlName("BED") + " BED "
	cQuery += " WHERE BED_FILIAL = '" + xFilial("BED") + "' AND "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cQuery += " BED_CODINT||BED_CODEMP||BED_MATRIC||BED_TIPREG||BED_DIGITO = '" + cMatric + "' "
	Else
		cQuery += " BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO = '" + cMatric + "' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select("TRBBED") > 0
		TRBBED->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBED",.F.,.T.)

	TRBBED->(DbGoTop())

	ProcRegua(TRBBED->(RecCount()))
	TRBBED->(DbGoTop())
	While !TRBBED->(Eof())
		IncProc("Processando Segunda Via...")//"Processando Segunda Via..."
		aadd(aVetor,{Iif(TRBBED->BED_VIACAR == 1,"Solicitação 1ª via cartão","Solicitação 2ª via cartão"),DtoC(StoD(TRBBED->BED_DTSOLI)),"",Iif(TRBBED->BED_STACAR == "1","Em aberto","Encerrado")})
		TRBBED->(DbSkip())
	End

	TRBBED->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados de reembolso											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT BOW_DTDIGI, BOW_STATUS FROM " + RetSqlName("BOW") + " BOW "
	cQuery += " WHERE BOW_FILIAL = '" + xFilial("BOW") + "' AND "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cQuery += " BOW_OPEUSR||BOW_CODEMP||BOW_MATRIC||BOW_TIPREG||BOW_DIGITO = '" + cMatric + "' "
	Else
		cQuery += " BOW_OPEUSR+BOW_CODEMP+BOW_MATRIC+BOW_TIPREG+BOW_DIGITO = '" + cMatric + "' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ''"

	If Select("TRBBOW") > 0
		TRBBOW->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBOW",.F.,.T.)

	TRBBOW->(DbGoTop())

	ProcRegua(TRBBOW->(RecCount()))
	TRBBOW->(DbGoTop())
	While !TRBBOW->(Eof())
		IncProc("Processando Reembolso...")//"Processando Reembolso ..."
		If TRBBOW->BOW_STATUS == "1"
			cStatus := "Protocolado"
		ElseIf TRBBOW->BOW_STATUS == "2"
			cStatus := "Em analise"
		ElseIf TRBBOW->BOW_STATUS == "3"
			cStatus := "Deferido"
		ElseIf TRBBOW->BOW_STATUS == "4"
			cStatus := "Indeferido"
		ElseIf TRBBOW->BOW_STATUS == "5"
			cStatus := "Em digitação"
		ElseIf TRBBOW->BOW_STATUS == "6"
			cStatus := "Lib. Financeiro"
		ElseIf TRBBOW->BOW_STATUS == "7"
			cStatus := "Não Lib. Financeiro"
		ElseIf TRBBOW->BOW_STATUS == "8"
			cStatus := "Glosado"
		ElseIf TRBBOW->BOW_STATUS == "9"
			cStatus := "Auditoria"
		ElseIf TRBBOW->BOW_STATUS == "A"
			cStatus := "Solicitação não concluída"
		ElseIf TRBBOW->BOW_STATUS == "B"
			cStatus := "Aguardando informação Beneficiária"
		ElseIf TRBBOW->BOW_STATUS == "C"
			cStatus := "Aprovado parcialmente"
		ElseIf TRBBOW->BOW_STATUS == "D"
			cStatus := "Cancelado"
		EndIf

		aadd(aVetor,{"Reembolso",DtoC(StoD(TRBBOW->BOW_DTDIGI)),"",cStatus})
		TRBBOW->(DbSkip())
	End

	TRBBOW->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados de indicação de prestador.								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT B9Y_DATAIN, B9Y_STCRED FROM " + RetSqlName("B9Y") + " B9Y "
	cQuery += " WHERE B9Y_FILIAL = '" + xFilial("B9Y") + "' AND "
	cQuery += " B9Y_CARTEI = '" + cMatric + "' "
	cQuery += " AND D_E_L_E_T_ = ''"

	If Select("TRBB9Y") > 0
		TRBB9Y->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBB9Y",.F.,.T.)

	TRBB9Y->(DbGoTop())

	ProcRegua(TRBB9Y->(RecCount()))
	TRBB9Y->(DbGoTop())
	While !TRBB9Y->(Eof())
		IncProc("Processando...")//"Processando..."

		If TRBB9Y->B9Y_STCRED == "1"
			cStatus := "Pendente com a Operadora"
		ElseIf TRBB9Y->B9Y_STCRED == "2"
			cStatus := "Pendente com o Prestador"
		ElseIf TRBB9Y->B9Y_STCRED == "3"
			cStatus := "Credenciado"
		ElseIf TRBB9Y->B9Y_STCRED == "4"
			cStatus := "Indeferido"
		EndIf

		aadd(aVetor,{"Indicação de Prestador",DtoC(StoD(TRBB9Y->B9Y_DATAIN)),"",cStatus})
		TRBB9Y->(DbSkip())
	End

	TRBB9Y->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados de guias												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT BEA_DATSOL, BEA_HORSOL, BEA_STATUS FROM " + RetSqlName("BEA") + " BEA "
	cQuery += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' AND "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cQuery += " BEA_OPEUSR||BEA_CODEMP||BEA_MATRIC||BEA_TIPREG = '" + cMatric + "' "
	Else
		cQuery += " BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG = '" + cMatric + "' "
	EndIf

	cQuery += " AND D_E_L_E_T_ = ''"

	If Select("TRBBEA") > 0
		TRBBEA->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBEA",.F.,.T.)

	TRBBEA->(DbGoTop())

	ProcRegua(TRBBEA->(RecCount()))
	TRBBEA->(DbGoTop())
	While !TRBBEA->(Eof())
		IncProc("Processando Guias...")//"Processando Guias..."

		If TRBBEA->BEA_STATUS == "1"
			cStatus := "Autorizada"
		ElseIf TRBBEA->BEA_STATUS == "2"
			cStatus := "Em Análise / Autorizada Parcialmente"
		ElseIf TRBBEA->BEA_STATUS == "3"
			cStatus := "Negado / Guia Cancelada"
		ElseIf TRBBEA->BEA_STATUS == "4"
			cStatus := " Pendente de Anexo "
		ElseIf TRBBEA->BEA_STATUS == "5"
			cStatus := "Apenas Conhecimento"
		EndIf

		aadd(aVetor,{"Indicação de Prestador",DtoC(StoD(TRBBEA->BEA_DATSOL)),TRBBEA->BD5_HORA,cStatus})
		TRBBEA->(DbSkip())
	End

	TRBBEA->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados de internação											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT BE4_DTDIGI, BE4_HHDIGI, BE4_STATUS FROM " + RetSqlName("BE4") + " BOW "
	cQuery += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' AND "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cQuery += " BE4_OPEUSR||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG = '" + cMatric + "' "
	Else
		cQuery += " BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG = '" + cMatric + "' "
	EndIf

	cQuery += " AND D_E_L_E_T_ = ''"

	If Select("TRBBE4") > 0
		TRBBE4->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBBE4",.F.,.T.)

	TRBBE4->(DbGoTop())

	ProcRegua(TRBBE4->(RecCount()))
	TRBBE4->(DbGoTop())
	While !TRBBE4->(Eof())
		IncProc("Processando Internação...")//"Processando Internação..."

		If TRBBE4->BE4_STATUS == "1"
			cStatus := "Autorizada"
		ElseIf TRBBE4->BE4_STATUS == "2"
			cStatus := "Autorizada Parcialmente"
		ElseIf TRBBE4->BE4_STATUS == "3"
			cStatus := "Nao Autorizada"
		ElseIf TRBBE4->BE4_STATUS == "4"
			cStatus := "Aguardando finalizacao do atendimento"
		EndIf

		aadd(aVetor,{"Internação",TRBBE4->BOW_DTSOLI,"",cStatus})
		TRBBE4->(DbSkip())
	End

	TRBBE4->(DbCloseArea())
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsRetPro
Dados de faturamento
@author Roberto Vanderlei
@since 18/05/2016
@version P12
/*/
//-------------------------------------------------------------------
function PlsRetPro(cCodRda, cNome)

	Static objCENFUNLGP := CENFUNLGP():New()

	local oDlgPls
	Local aSize      	:= MsAdvSize()
	local aGuiRDA
	local aDadGRDA 	:= {}
	local oshowesp 	:= {}

	local bBotMn1		:= {|| oMenuAut:Activate(C(150,'2'),L(45),oDlgPls)}

	local cCodOpe   	:= PLSINTPAD()
	local nTamRDA   	:= TamSX3("BCI_CODRDA")[1]
	local aDados    	:= {}

	BCI->(dbSetOrder(5)) //BCI_FILIAL+BCI_OPERDA+BCI_CODRDA+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
	if BCI->(msSeek( xFilial("BCI") + cCodOpe + strZero( val(cCodRda),nTamRDA )))
		While !BCI->(Eof()) .and. BCI->(BCI_FILIAL+BCI_OPERDA+BCI_CODRDA) == xFilial("BCI")+ cCodOpe + strZero( val(cCodRda),nTamRDA )

			aadd(aDados, {BCI->BCI_CODPEG, BCI->BCI_FASE,BCI->BCI_SITUAC, dtoc(BCI->BCI_DATPAG)} )

			BCI->(DbSkip())
		enddo
	endif

	aGuiRDA:= {STR0250,STR0215,STR0251} //Dados de Faturamento ## Protocolo ## Previsão Pagto.

	DEFINE MSDIALOG oDlgPls TITLE STR0252 + "-" + cNome  FROM 009,000 TO 025,80 OF GetWndDefault() //FROM 000,000 to aSize[6],aSize[5] OF oMainWnd PIXEL//FROM 008.2,010.3 TO 049.5,117.3  //"Consultar Rede de Atendimento (Rdas)"

	oGuiRda := TcBrowse():New( 001,001,315,100,,,, oDlgPls,,,,,,,,,,,, .F.,, .T.,, .F., )//50

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[1],nil,;
		nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
	oGuiRda:ACOLUMNS[1]:BDATA     := { || aDados[oGuiRda:nAt,1] }

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[2],nil,;
		nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))
	oGuiRda:ACOLUMNS[2]:BDATA     := { || retornaStatus(PLRETSTISS(aDados[oGuiRda:nAt,2], aDados[oGuiRda:nAt,3], 0 , .F.)) }

	oGuiRda:AddColumn(TcColumn():New(aGuiRDA[3],nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oGuiRda:ACOLUMNS[3]:BDATA     := { || aDados[oGuiRda:nAt,4] }

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BCI_CODPEG",.F.,"BCI_DATPAG"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oGuiRda:aObfuscatedCols := aBls
	endif

	oGuiRda:Refresh()


	oGuiRda:SetArray(aDados)

	mv_par01 := cCodOpe
	mv_par02 := cCodRda
	mv_par03 := cCodRda

	TButton():New( 105, 82, STR0253, oDlgPls,{|| chamaRel("1", cCodOpe, cCodRda, aDados[oGuiRda:nAt,1])  },90,010,,,.F.,.T.,.F.,,.F.,,,.F.)
	TButton():New( 105, 177, STR0254, oDlgPls,{|| chamaRel("2", cCodOpe, cCodRda) },75,010,,,.F.,.T.,.F.,,.F.,,,.F.)


	ACTIVATE MSDIALOG oDlgPls

return

//-------------------------------------------------------------------
/*/{Protheus.doc} chamaRel
Chama relatório
@author Roberto Vanderlei
@since 18/05/2016
@version P12
/*/
//-------------------------------------------------------------------
function chamaRel(cTipo, cCodOpe, cCodRda, cProtocolo)
	if cTipo == "1" //Análise de Conta
		FS_PosSx1("PLSRELACP 01",cCodOpe)
		FS_PosSx1("PLSRELACP 02",cCodRda)
		FS_PosSx1("PLSRELACP 03",cCodRda)
		FS_PosSx1("PLSRELACP 04",cProtocolo)
		PLSRELDAC(,,,,,,, .T.)
	else //Demonstrativo de Pagamento
		FS_PosSx1("PLSRELDPM 01",cCodOpe)
		FS_PosSx1("PLSRELDPM 02",cCodRda)
		FS_PosSx1("PLSRELDPM 03",cCodRda)
		PLSRELDPM()
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} retornaStatus
De/Para para o status
@author Roberto Vanderlei
@since 18/05/2016
@version P12
/*/
//-------------------------------------------------------------------
function retornaStatus(cIntStatus)
	local cStatus

	Do Case
		Case cIntStatus == "1"
			cStatus := STR0255 // "Recebido"
		Case cIntStatus == "2"
			cStatus := STR0222 // "Em análise"
		Case cIntStatus == "3"
			cStatus := STR0256 // "Liberado para pagamento"
		Case cIntStatus == "4"
			cStatus := STR0257 // "Encerrado sem pagamento"
		Case cIntStatus == "6"
			cStatus := STR0258 // "Pagamento Efetuado"
	EndCase

return cStatus

Static Function FS_PosSx1(cChave, xConteudo)
	// *** CONTEUDO REMOVIDO - Nao permitido manuseio de dicionario via codigo fonte - SGBD
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSImpRda
Imprime as Rda's que foram listadas e envia por e-mail
@author Fábio S. dos Santos
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSImpRda(aRda,aDadGRDA)
	Local aRet	    := {}
	Local aAux      := {}
	Local aAux1     := {}
	Local nI        := 0
	Local nJ        := 0
	Local cPos      := ""
	Local lAchou    := .F.
	Default aDadGRDa:= {}

	If Len(aDadGRDA)>0

		aAux1:= aclone(aRda)

		For nI:=1 to Len(aRda)
			lAchou:=.F.
			For nJ:= 1 to Len(aDadGRDA)

				If aRda[nI,1] + aRda[nI,3] + aRda[nI,9] == aDadGRDA[nJ,1] +aDadGRDA[nJ,3] +aDadGRDA[nJ,4]
					lAchou:= .T.
					Exit
				EndIf
			Next nJ

			If !lAchou
				cPos+= cValToChar(nI) + "/"
			EndIf

		Next nI

		aAux:=StrTokArr(cPos,"/")

		For nI:= 1 to Len(aAux)
			aDel(aRda,Val(aAux[nI]))
		Next nI

		ASize(aRda,(Len(aRda)-Len(aAux)))
	EndIf

	If Len(aRda) >= 1
		If ParamBox({ {1,"E-mail's (separar por ';')",Space(120),"@!","",,'.T.',120,.T.}}, "Relatório RDA",aRet,,,.T.,256,129,,,.F.,.F.) //, caso queira inserir mais de um e-mail, separe por ';':
			Processa({|| PLSImpDados(aRda, aRet)},"Relatório RDA","Processando",.F.)
			MsgInfo("O relatório foi enviado para o e-mail informado.","Atenção")
		EndIf
	Else
		MsgInfo("Informar os dados para Impressão!","Atenção")
	EndIf

	If Len(aDadGRDA)>0
		oPesRda:AARRAY:=aclone(aAux1)
		aRda:=aclone(aAux1)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSImpDados
Imprime as Rda's que foram listadas e envia por e-mail
@author Fábio S. dos Santos
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSImpDados(aRda, aEmail)
	Local oReport     	:= nil
	Local cDirPath		:= Lower(GetMV("MV_RELT"))
	Local cFileName		:= "relacao_rda_"+DtoS(dDataBase) + "_" + SubStr(Time(),1,2) + SubStr(Time(),4,2)

	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.f.)
	oReport:cPathPDF	:= cDirPath
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetLandscape()
	oReport:SetPaperSize(9)
	oReport:setMargin(07,07,07,07)

	PLSRImpRda(oReport,aRda)

	oReport:SetViewPDF(.F.)
	oReport:EndPage()

	oReport:Print()
	FreeObj(oReport)

	BOJ->(DbSetOrder(3))
	BOJ->(MsSeek(xFilial("BOJ") + Left( "PLSIMPRDA" + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] )))

	PLSinaliza(BOJ->BOJ_CODSIN,nil,nil, aEmail[1], "Envio email relatório de RDA",,,,cDirPath+cFileName+".pdf",, .F.,"",,,)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRImpRda
Monta o relatório com os dados
@author Fábio S. dos Santos
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRImpRda(oReport,aRda)
	Local nCont		:= 0
	Local nLinha	:= 1
	Local lFirst	:= .T.
	Local nPag		:= 1

	Private nLeft	:= 40
	Private nRight	:= 2500
	Private nCol0  := nLeft
	Private nTop	:= 130
	Private nTopInt	:= nTop

	Private nTweb	:= 3
	Private nLweb	:= 10

	ProcRegua(Len(aRda))

	oReport:StartPage()
	ProcRegua(Len(aRda))
	For nCont := 1 To Len(aRda)
		IncProc("Imprimindo...")
		If lFirst
			ImpCab(oReport, nPag)
			lFirst := .F.
		EndIf
		nColAux := (nLeft/nTweb) //"Código"
		oReport:Say(nTop/nTweb, nColAux, aRda[nCont,1], oFnt10c)

		nColAux += __NTAM1*3 //"Nome RDA"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,2],1,23), oFnt10c)

		nColAux += __NTAM2*12 //"Local Atendimento"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,3],1,30), oFnt10c)

		nColAux += __NTAM3*7.5 //"Endereço"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,4],1,35), oFnt10c)

		nColAux += __NTAM4*7 //"Bairro"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,5],1,20), oFnt10c)

		nColAux += __NTAM5*2 //"Município"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,6],1,10), oFnt10c)

		nColAux += __NTAM6*3.3 //"Estado"
		oReport:Say(nTop/nTweb, nColAux, aRda[nCont,7], oFnt10c)

		nColAux += __NTAM7*4 //"Telefone"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,8],1,10), oFnt10c)

		nColAux += __NTAM8*5 //"Especialidade"
		oReport:Say(nTop/nTweb, nColAux, SubStr(aRda[nCont,9],1,23), oFnt10c)

		nLinha++
		nTop += 45
		If nLinha > 25 .And. nCont < Len(aRda)
			nLinha := 1
			oReport:EndPage()
			oReport:StartPage()
			nPag++
			ImpCab(oReport, nPag)
		EndIf

	Next nCont

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCab
Monta o cabeçalho do relatório
@author Fábio S. dos Santos
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpCab(oReport, nPag)
	Local cTitulo 	:= "Relação de Rede de Atendimento"

	oReport:EndPage() //Salta para proxima pagina

	nTop		:= 15
	nTopInt		:= nTop
	nLeft		:= 40
	nTop		+= _BL
	nTopAux 	:= nTop

	aBMP	:= {"lgesqrl.bmp"}

	If File("lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMP := { "lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgesqrl" + FWGrpCompany() + ".bmp")
		aBMP := { "lgesqrl" + FWGrpCompany() + ".bmp" }
	EndIf

	oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 100, 100)

	cMsg := cTitulo
	nTop += 250
	oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 800)/nTweb, cMsg, oFnt14N)
	cMsg := "Data: "+DtoC(dDataBase)
	nTop += 35
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

	cMsg := "Hora: "+time()
	nTop += 35
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

	nTop += 35
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, "Pagina: "+AllTrim(Str(nPag))+"", oFnt10N)

	nTop += _BL
	oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)

	nTop += _BL + 40
	nColAux := (nCol0/nTweb)
	oReport:Say(nTop/nTweb, nColAux, "Código", oFnt10c)

	nColAux += __NTAM1*3
	oReport:Say(nTop/nTweb, nColAux, "Nome RDA", oFnt10c)

	nColAux += ((__NTAM2*12))
	oReport:Say(nTop/nTweb, nColAux, "Local Atendimento", oFnt10c)

	nColAux += __NTAM3*7.5
	oReport:Say(nTop/nTweb, nColAux, "Endereço", oFnt10c)

	nColAux += __NTAM4*7
	oReport:Say(nTop/nTweb, nColAux, "Bairro", oFnt10c)

	nColAux += __NTAM5*2
	oReport:Say(nTop/nTweb, nColAux, "Município", oFnt10c)

	nColAux += __NTAM6*3.3
	oReport:Say(nTop/nTweb, nColAux, "UF", oFnt10c)

	nColAux += __NTAM7*4
	oReport:Say(nTop/nTweb, nColAux, "Telefone", oFnt10c)

	nColAux += __NTAM8*5
	oReport:Say(nTop/nTweb, nColAux, "Especialidade", oFnt10c)

	nTop += _BL
	nTop += 43
	oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsTmkProA
Imprime ou manda por email algum protocolo de atendimento da RN 395
@author Karine Riquena Limp
@since 19/10/2016
@version P12
/*/
//-------------------------------------------------------------------
function PlsTmkProA(cMatric, cNumProTmk)
	local aAreaBA1	:= BA1->(getArea())
	local cProt		:= space( 20 )
	local cEmail	:= space( 60 )
	local aRetPar	:= {}
	Local aPergs	:= {}
	local nTipo		:= 1

	default cNumProTmk := ""

	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	BA1->(msSeek(xFilial("BA1")+cMatric))

	cProt	:= cNumProTmk
	cEmail	:= BA1->BA1_EMAIL

	aadd(/*01*/ aPergs,{ 1,"Protocolo",cProt,"",'.T.','BA1B00',/*'.T.'*/,40,.T. } )
	aadd(/*02*/ aPergs,{ 2,"Tipo",nTipo,{ "1=Email","2=Impressao" },50,/*'.T.'*/,.T. } )
	aadd(/*03*/ aPergs,{ 1,"E-mail",cEmail,"",'.T.','',/*'.T.'*/,40,.T. } )

	if( paramBox( aPergs,"Parâmetros",aRetPar,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSXTMK',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
		B00->(DbSetOrder(1))
		If B00->(msSeek(xFilial("B00")+aRetPar[ 01 ]))
			PLSA773Pro(aRetPar[ 02 ] == 1, aRetPar[ 03 ])
		EndIf
	endIf

	restArea(aAreaBA1)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTMKBLOQ
Chama rotina para realizar o bloqueio

@author  PLS TEAM
@version P11
@since    04.04.16
/*/
//-------------------------------------------------------------------
Function PLSTMKBLOQ(cMatric,cNome,cNumProTMK)
	Local oModel
	Local oModelB5J
	Local oModelB5K
	Local oView
	Local xValue      := ""
	Local cTitular    := GetNewPar("MV_PLCDTIT","T")
	Local nX          := 0
	Local aArea       := BA1->(GetArea())
	Local lOk         := .T.
	Local lBenefOk    := .T.

	If Empty(cNumProTMK)
		lOk := .F.
		Aviso( STR0007,STR0265,{ "Ok" }, 2 )//"Para realizar a solicitação é necessário gerar um protocolo de atendimento."
	EndIf

	B00->(DbSetOrder(1))//B00_FILIAL+B00_COD
	If lOk .And. B00->(MsSeek(xFilial("B00")+cNumProTMK)) .And. !Empty(B00->B00_SOLCAN)
		lOk := .F.
		Aviso( STR0007,STR0266,{ "Ok" }, 2 )//"Já foi confirmada a solicitação para o protocolo informado, por gentileza realize um novo atendimento."
	EndIf

	If lOk
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(MsSeek(xFilial("BA1")+cMatric))
			If BA1->BA1_TIPUSU <> cTitular .And. (DateDiffYear(dDataBase,BA1->BA1_DATNAS) < 18 )
				Aviso(STR0007,STR0262,{"OK"},2)//"Beneficiário dependente deve ser maior para realizar a solicitação."
				lOk := .F.
			Else
				//Verifica se e beneficiario dependente com solicitacao pendente
				B5K->(DbSetOrder(2))//B5K_FILIAL+B5K_MATUSU
				If BA1->BA1_TIPUSU <> cTitular .And. B5K->(MsSeek(xFilial("B5K")+cMatric))
					While B5K->(B5K_FILIAL+B5K_MATUSU) == xFilial("B5K")+cMatric .And. !B5K->(Eof())
						B5J->(DbSetOrder(1))//B5J_FILIAL+B5J_CODIGO
						If B5J->(MsSeek(xFilial("B5J")+B5K->B5K_CODIGO)) .And. B5J->B5J_STATUS == "0"
							Aviso( STR0007,STR0263,{ "OK" }, 2 )//"O beneficiário informado já tem uma solicitação pendente."
							lOk := .F.
							Exit
						EndIf

						B5K->(DbSkip())
					EndDo
				EndIf
			EndIf
		Else
			Aviso(STR0007,STR0264,{"OK"},2) //"Não foi encontrado o beneficiário solicitante informado."
		EndIf
	EndIf

	If lOk
		BA1->(MsSeek(xFilial("BA1")+cMatric))
		xValue := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

		oModel      := FwLoadModel('PLSA99B')
		oModelB5J   := oModel:GetModel( 'B5JMASTER' )
		oModelB5K   := oModel:GetModel( 'B5KDETAIL' )

		oModel:setOperation( MODEL_OPERATION_INSERT )
		oModel:activate()

		FwFldPut("B5J_MATSOL",cMatric)
		FwFldPut("B5J_NOMBEN",Alltrim(BA1->BA1_NOMUSR))
		FwFldPut("B5J_ORISOL","2")
		FwFldPut("B5J_PROTOC",cNumProTMK)

		If BA1->BA1_TIPUSU <> cTitular
			FwFldPut("B5K_MATUSU",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
			FwFldPut("B5K_NOMBEN",BA1->BA1_NOMUSR)
		Else
			If MsgYesNo(STR0261) .And. BA1->(MsSeek(xFilial("BA1")+xValue))//"Deseja carregar todos os beneficiários da família?"

				While BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+Substr(xValue,1,14) .And. !BA1->(Eof())
					If Empty(BA1->BA1_MOTBLO)
						lBenefOk := .T.
						B5K->(DbSetOrder(2))//B5K_FILIAL+B5K_MATUSU
						If B5K->(MsSeek(xFilial("B5K")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))

							While B5K->(B5K_FILIAL+B5K_MATUSU) == xFilial("B5K")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)  .And. !B5K->(Eof())
								B5J->(DbSetOrder(1))//B5J_FILIAL+B5J_CODIGO
								If B5J->(MsSeek(xFilial("B5J")+B5K->B5K_CODIGO)) .And. B5J->B5J_STATUS == "0"
									Aviso(STR0007,STR0267+Alltrim(BA1->BA1_NOMUSR)+STR0268,{"OK"},2)//"O beneficiário "###" já tem uma solicitação pendente."
									lBenefOk := .F.
								EndIf
								B5K->(DbSkip())
							EndDo

						EndIf
						//Adiciona registro na grid
						If lBenefOk
							If nX > 0
								oModelB5K:AddLine(.T.)
							EndIf
							FwFldPut("B5K_MATUSU",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
							FwFldPut("B5K_NOMBEN",BA1->BA1_NOMUSR)
							nX++
						EndIf
					EndIf
					BA1->(DbSkip())

				EndDo
			EndIf
		EndIf

		FWExecView('Incluir','PLSA99B', MODEL_OPERATION_INSERT,, { || .T. } ,nil,nil,nil,nil,nil,nil,oModel)

		oModel:deActivate()
		oModel:destroy()
		freeObj( oModel )
		oModel := nil
		delClassInf()
	EndIf

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTKAtuCro
Incrementa o Cronometro na Tela a cada 10 segundos
@author  Vinicius.Queiros
@version P12
@since   30/09/2020
@Observ  Função baseada na Tk271AtuCro do Call Center
@Param   1 = Segundos
		 2 = Minutos
		 3 = Time Out
		 4 = Variavel do objeto de Cronometro
		 5 = Objeto Cronometro
/*/
//-------------------------------------------------------------------

Static Function PLSTKAtuCro(nTimeSeg, nTimeMin, cTimeOut, cCrono, oCrono)

	Local cTimeAtu	:= ""
	Local cTipoAte	:= TkGetTipoAte()

	Do Case
		Case (cTipoAte $ "145")  // Telemarketing, Ambos e TMK x TLV

			// Verifica qual o tempo medio de atendimento desse operador
			cTimeOut := TkPosto(M->UC_OPERADO,"U0_TEMPCRO")

		Case (cTipoAte == "2") //Televendas

			// Verifica qual o tempo medio de atendimento desse operador
			cTimeOut := TkPosto(M->UA_OPERADO,"U0_TEMPCRO")

		Case (cTipoAte == "3") //Telecobranca

			// Verifica qual o tempo medio de atendimento desse operador
			cTimeOut := TkPosto(M->ACF_OPERAD,"U0_TEMPCRO")
	EndCase

	nTimeSeg += 10

	If nTimeSeg > 59
		nTimeMin ++
		nTimeSeg := 0
		If nTimeMin > 60
			nTimeMin := 0
		Endif
	Endif

	cTimeAtu := STRZERO(nTimeMin,2,0)+":"+STRZERO(nTimeSeg,2,0)

	If cTimeAtu > cTimeOut
		oCrono:nClrText := CLR_RED
		oCrono:Refresh()
	Endif

	cCrono := cTimeAtu
	oCrono:Refresh()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLBA1B00
Consulta Específica do Protocolo na Rotina de Call Center
 
@author Giovanna Charlo
@since 22/08/2022
@version P12
/*/
//-------------------------------------------------------------------
 
Function PLBA1B00()
    Local aGetRotBkp := aRotina
    Local cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
    Local lRet := .f.
    Local aDados := {}
    local cFil := ""
	Local bBotao := {|| oPrinWnd:oOwner:End()}
	Local aBotoes := {}
 
    cFil = "@(B00_FILIAL = '"+xFilial("B00")+"' AND B00_MATRIC = '" + cMatric + "' AND D_E_L_E_T_ = '')"
 
    //Criação da Modal
    oPrinWnd := FWDialogModal():New()
    oPrinWnd:SetBackground(.t.)
    oPrinWnd:SetTitle("Consulta Padrão - Prot Atend Benef ")
    oPrinWnd:SetFreeArea(450, 200)
    oPrinWnd:EnableFormBar(.t.)
    oPrinWnd:SetEscClose(.t.)
    oPrinWnd:CreateDialog()

	Aadd(aBotoes, {"", "Confirmar", bBotao, , , .T., .F.}) 
	Aadd(aBotoes, {"", "Fechar", bBotao, , , .T., .F.})
	oPrinWnd:AddButtons(aBotoes)
    oPainel := oPrinWnd:getPanelMain()
 
    oFwCamada := FwLayer():New()
    oFwCamada:init(oPainel,.F.)
    oFwCamada:AddLine( "LINSUP",100, .F.)
    oLINSUP  := oFwCamada:GetLinePanel("LINSUP")
 
    oGridB00 := FWmBrowse():New()
    oGridB00:setOwner(oLINSUP)
    oGridB00:setProfileID('0')
    oGridB00:setAlias("B00")
    oGridB00:disableDetails()  
    oGridB00:SetMenuDef('')
    oGridB00:disableReport()  
    oGridB00:setFilterDefault(cFil)
    aRotina:={}
    aadd(aDados, {"Protocolo", {|| B00->B00_COD}})
    aadd(aDados, {"Dt. Atendim.", {|| B00->B00_DTATEN}})
    aadd(aDados, {"Hr. Atendim.", {|| B00->B00_HRATEN}})  
    aadd(aDados, {"Dt.Protocolo", {|| B00->B00_DTPROT}})  
    aadd(aDados, {"Hr.Protocolo", {|| B00->B00_HRPROT}})  
    aadd(aDados, {"Matrícula", {|| B00->B00_MATRIC }})  
    aadd(aDados, {"Nome Usuario", {|| B00->B00_NOMUSR}})

    oGridB00:setFields(aDados)
    oGridB00:activate()
    oPrinWnd:Activate()
	
    lRet := .t.
    aRotina := aGetRotBkp
return lRet