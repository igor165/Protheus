#INCLUDE "PONM400.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "SIGAWIN.CH"
   
/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁPONM400		 	ЁAutorЁIgor Franzoi	    	ЁData  Ё05/11/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁGeracao do calendario fisico				      			  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁPONM400()													  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerico      										    	  Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               Ё
цддддддддддддбддддддддбддддддддбдддддддддддддддддддддддддддддддддддддддддд╢
ЁProgramador Ё Data   Ё BOPS   Ё  Motivo da Alteracao                     Ё
цддддддддддддеддддддддеддддддддедддддддддддддддддддддддддддддддддддддддддд╢
ЁLeandro DR  Ё18/06/08ЁMelhor  ЁInclusao de tratamento para WorkFlow      Ё
ЁAndreia     Ё29/12/08Ё83942008Ё Chamada da nova regua de processamento   Ё
Ё            Ё        Ё        Ё para versoes posteriores a "R1.1".       Ё
ЁLuis Artuso Ё22/10/15Ё  TTMNNAЁ Ajuste para que gere calendario apenas paЁ
Ё            Ё        Ё        Ё ra funcionarios ativos.           	      Ё
юддддддддддддаддддддддаддддддддадддддддддддддддддддддддддддддддддддддддддды/*/
Function PONM400(lWork , cProc , cPer , cNPag , cDpto , cCC , cFilPrc)

Local lRet  := .T.

Private aParam		:= {}
Private cCond		:= "1"	  // 1 - Somente periodos abertos
Private cPeriodo 	:= ""	  // Codigo do Periodo
Private cProcesso 	:= ""	  // Codigo do Processo 
Private cNumPagto   := ""	  // Num. de Pagto
Private cRot		:= "PON"  // Roteiro de Calculo
Private cPerg		:= "PONM400"
Private oCalendError:= PONERROR():New()
Private lWorkFlow	:= .F.

DEFAULT lWork := .F.

lWorkFlow	:= lWork

oCalendError:lWorkFlow := lWorkFlow

If !lWorkFlow
	Pergunte( cPerg , .F. )

	cProcesso := mv_par02
	cPeriodo  := mv_par03
	cNumPagto := mv_par04
	cFilPrc	  := mv_par05
	cMat	  := mv_par06
	cDpto	  := mv_par07
	cCC		  := mv_par08
Else
	cMat	  := ""
	aParam	  := {cProc,cPer,cNPag,cFilPrc,cDpto,cCC,cMat}
EndIf

    /*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Executa a tela de selecao dos parametros							 Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	WinSel()

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁWinSel 	  ЁAutor ЁIgor Franzoi	  			  ЁDataЁ05/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁApresenta tela de informacao para selecao dos parametros	  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁWinSel()	                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Static Function WinSel()

Local aArea			:= GetArea()
Local cSvFilAnt		:= cFilAnt
Local lRet			:= .T.

Local nOpcA			:= 0

Local aSays			:= {}
Local aButtons		:= {}
Local bProcess	  	:=	{|oSelf| GerCal( cPerg, oSelf )}

Local lBarG1ShowTm := .F.
Local lBarG2ShowTm := .F.

Private cTitulo		 := OemToAnsi( STR0006 + " " + STR0005 + " " + STR0001 ) // "Geracao de CalendАrio"
Private cFunction    := "GerCal"
Private lRelease11	 := (GetRpoRelease("R1.1"))
Private lAbortPrint	 := .F.
Private cDescription := STR0003; // "Este programa tem como objetivo oferecer a manutencao do calendario"
						+ " " +;
						STR0004  // "dos funcion═rios de acordo com os parametros selecionados."

If !lWorkFlow
	If lRelease11
	
		tNewProcess():New(cFunction,cTitulo,bProcess,cDescription,cPerg) 
		
	Else
	
		aAdd(aSays,OemToAnsi( STR0003 ) )// "Este programa tem como objetivo oferecer a manutencao do calendario"
		aAdd(aSays,OemToAnsi( STR0004 ) )// "dos funcion═rios de acordo com os parametros selecionados."
		
		aAdd( aButtons , { 5 , .T. , { ||  Pergunte( cPerg , .T. ) } } )
		aAdd( aButtons , { 1 , .T. , { |o| nOpcA := 1 , IF( GpConfOk() , FechaBatch() , nOpcA := 0 ) } } )
		aAdd( aButtons , { 2 , .T. , { |o| FechaBatch() }} )
		
		FormBatch( cTitulo , aSays , aButtons )
		
		IF ( nOpcA == 1 )
		
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Verifica se deve Mostrar Calculo de Tempo nas BarGauge			 Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
			lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
		
		    /*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Executa o Processo de Geracao de Marcacoes      					 Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			Proc2BarGauge( { || GerCal( cPerg ) } , cTitulo , NIL , '' , .F. , lBarG1ShowTm , lBarG2ShowTm )	
			
		EndIF
		                        	
		cFilAnt := cSvFilAnt
		RestArea( aArea )
	
	EndIf
Else
	GerCal("",,lWorkFlow,aParam)
EndIf

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁGerCal 	  ЁAutor ЁIgor Franzoi	  			  ЁDataЁ05/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁGeracao do calendario fisico								  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGerCal()	                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function GerCal( cPerg, oSelf, lWorkFlow, aParam )

Local aArea := GetArea()

DEFAULT cPerg 	  := "PONM400"
DEFAULT lWorkFlow := .F.
DEFAULT aParam    := {}

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica se a tabela de funcionarios esta vazia			  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If (!ChkVazio("SRA") .or. !ChkVazio("RCH"))
	Break
EndIf

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Processa os calendarios fisicos							  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
fProcCal( cPerg,,,,,,,,,oSelf,lWorkFlow,aParam )

RestArea( aArea )

Return ( NIL )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁfProcCal  ЁAutor ЁIgor Franzoi	  			  ЁDataЁ06/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁProcessa os calendarios fisicos							  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁfProcCal()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ cPerg     = Perguntas do SX1 / assumido DEFAULT PNM400	  Ё╠╠
╠╠Ё	         Ё cFilPrc   = Filiais a serem processadas                    Ё╠╠
╠╠Ё	         Ё cPeriodo  = Periodos para geracao do calendario            Ё╠╠
╠╠Ё	         Ё cMat 	 = Matriculas dos funcionarios para geracao       Ё╠╠
╠╠Ё	         Ё cDpto     = Departamentos dos funcionarios 				  Ё╠╠
╠╠Ё	         Ё cCC 		 = Centros de Custo dos funcionarios              Ё╠╠
╠╠Ё	         Ё cProcPara = Processo para o qual o func. sera transferido  Ё╠╠
╠╠Ё	         Ё lGerSob 	 = Sopbrepor os calendarios gerados				  Ё╠╠
╠╠Ё	         Ё lPar 	 = Se utiliza os parametros do SX1                Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function fProcCal( cPerg,;
				   cFilPrc,;
				   cPeriodo,;
				   cMat,;
				   cDpto,;
				   cCC,;
				   cProcPara,;
				   lGerSob,;
				   lPar,;
				   oSelf,;
				   lWorkFlow,;
				   aParam )

Local lRet   	:= .F.
Local lUpd		:= .T.
Local nField 	:= 0
Local dDtaMax   := Ctod("//")
Local dDtaPrc	:= Ctod("//")
Local cFilAnt   := ""
Local nX		:= 0

Local nOperacao := 0
Local cProcAnt	:= ""
Local cFilScope	:= ""
Local cSraScope := ""
Local cMsgLog	:= ""
Local aRecsSRA	:= {}
Local aLogTitle := {}

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis utilizadas na query SRA - funcionarios			  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/  
Local aCposSRA
Local nContSRA	   := 0
Local cPrfSRA	   := "RA_"
Local cFilterSRA   := ""
Local cFieldsSRA   := ""
Local cAliasQrySRA := GetNextAlias()
Local nOrderSRA	   := ""
Local nRecCalend   := 0.00
Local cRetNameSRA  := InitSqlName( cAliasQrySRA )
Local aFieldsSRA   := {}
Local cSituacao    := 'D'

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis utilizadas na query RCH	- Periodos				  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local cExpRch	   := ""
Local aResRCH	   := {}
Local nContRCH	   := 0
Local nPosPer	   := ""
Local nPosProc 	   := 0
Local nPosDtIni	   := 0
Local nPosDtFim    := 0
Local nPosDtFec	   := 0
Local nRecsBar2    := 0
Local nPosRchFil   := ""
Local nPosNumPag   := ""
Local cAliasRCH    := "RCH"
Local nOrderRCH	   := ""
Local cFieldsRCH   := ""
Local cAliasQryRCH := cAliasRCH
Local aFieldsRCH   := (cAliasRCH)->(dbStruct())

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicio/Fim do periodo atual					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local dIniPer := Ctod("//")
Local dFimPer := Ctod("//")

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis utilizadas nas barras temporizadoras			  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local lIncBar1 := .F.

Private aAuxError   := {}
Private cRecCalend  := ""
Private nIncPercG1	:= 0.00
Private nIncPercG2	:= 0.00
Private nRecsBarG	:= 0.00
Private aInfo		:= {}
Private lErroCal	:= .F.
Private oPeriodo	:= RHPERIODO():New()
Private cAuxFilAnt	:= ""

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Se diferente de AS/400 seta a variavel com valor .T.		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Private lSrvType := TcSrvType() != "AS/400"

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Executa o processo de geracao com os parametros do SX1	  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
DEFAULT lPar  := .T.
/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define os parametros das perguntas						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
DEFAULT cPerg := "PONM400"
/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Nao sobrepoe os calendarios existentes					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
DEFAULT lGerSob := .F.

DEFAULT lWorkFlow := .F.

DEFAULT aParam    := {}

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica o conteudo dos parametros e recarrega os param. SX1Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If !lPar

	nOperacao:= If( !Empty(cProcPara), 4	    , 1 		) //Se foi passado o processo PARA, assume 4 transferencia
	mv_par02 := If( !Empty(cProcesso), cProcesso, mv_par02	) //Processos
	mv_par03 := If( !Empty(cPeriodo) , cPeriodo , mv_par03  ) //Periodos
	mv_par04 := If( !Empty(cNumPagto), cNumPagto, mv_par04  ) //Numero de Pagamento
	mv_par05 := If( !Empty(cFilPrc)  , cFilPrc  , mv_par05  ) //Carrega a filial 	
	mv_par06 := If( !Empty(cMat)     , cMat		, mv_par06  ) //Matriculas
	mv_par07 := If( !Empty(cDpto)	 , cDpto	, mv_par07 	) //Departamentos
	mv_par08 := If( !Empty(cCC) 	 , cCC		, mv_par08	) //Centros de Custo
	
EndIf

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Realimenta o conteudo dos para as variaveis				  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Pergunte( cPerg , .F. )

If lWorkFlow
	nOperacao := 1
	mv_par02  := If( Empty(aParam[1]), "", aParam[1] )
	mv_par03  := If( Empty(aParam[2]), "", aParam[2] )
	mv_par04  := If( Empty(aParam[3]), "", aParam[3] )
	mv_par05  := If( Empty(aParam[4]), "", aParam[4] )
	mv_par06  := If( Empty(aParam[7]), "", aParam[7] )
	mv_par07  := If( Empty(aParam[5]), "", aParam[5] )
	mv_par08  := If( Empty(aParam[6]), "", aParam[6] )
EndIf

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica o conteudo dos parametros e carrega as variaveis   Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If !lWorkFlow
	#IFDEF TOP
		If lSrvType
			MakeSqlExpr( cPerg )
		Else
			MakeAdvplExpr( cPerg )
		EndIf
	#ELSE
		MakeAdvplExpr( cPerg )
	#ENDIF
EndIf

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Carrega variaveis de processamento						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

If Empty(nOperacao)
	nOperacao := mv_par01
EndIf

cProcesso := mv_par02
cPeriodo  := mv_par03
cNumPagto := mv_par04
cFilPrc	  := mv_par05
cMat	  := mv_par06
cDpto	  := mv_par07
cCC		  := mv_par08

//Carrega tabela de erros
oCalendError:InitLogErrors(LoadCalError())
nRecCalend := Len(oCalendError:aMsgErrors)
nRecCalend++
cRecCalend := STR(nRecCalend)
aAdd( oCalendError:aMsgErrors , { cRecCalend , "" } )
/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁAdiciona os campos para Query do RCH						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
For nContRCH := 1 To Len(aFieldsRCH)

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁGuarda a posicao dos campos data inicial/final e processo	  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	If ( aFieldsRCH[nContRch,01] == "RCH_FILIAL" )
		nPosRchFil := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_DTINI" )
		nPosDtIni := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_DTFIM" )
		nPosDtFim := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_PROCES" )
		nPosProc := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_DTFECH" )
		nPosDtFec := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_PER" )
		nPosPer	   := nContRch
	ElseIf ( aFieldsRCH[nContRch,01] == "RCH_NUMPAG" )
		nPosNumPag := nContRch	
	EndIf
	
	If (nContRCH > 1)
		cFieldsRCH += " , " + aFieldsRCH[ nContRCH, 01 ]
	Else
		cFieldsRCH += aFieldsRCH[ nContRCH, 01 ]
	EndIf
	
Next

#IFDEF TOP

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁCarrega o filtro do RCH conforme os parametros selecionados  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cExpRch := "% "
	cExpRch += " RCH_FILIAL = '"+xFilial( "RCH" )+"' "
	If	!Empty(cProcesso)
		cExpRch += "  AND RCH_PROCES = '"+cProcesso+"'"
	EndIf
	If !Empty(cPeriodo)
		cExpRch += " AND RCH_PER = '"+cPeriodo+"'"
	EndIf
	If !Empty(cNumPagto)
		cExpRch += " AND RCH_NUMPAG = '"+cNumPagto+"'"
	EndIf
	cExpRch += " AND RCH_ROTEIR = '"+cRot+"'"
	cExpRch += " %"
	
	cFieldsRch := "% "+cFieldsRch+" %"

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁSeleciona todos os periodos								  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cAliasQryRCH := GetNextAlias()
	
	BeginSql Alias cAliasQryRCH
		column RCH_DTINI as Date, RCH_DTFIM as Date , RCH_DTFECH as Date
	   	%NoParser%
		SELECT 
			%Exp:cFieldsRCH%
		FROM 
			%Table:RCH% RCH
		WHERE 
			%Exp:cExpRch% AND
			RCH.%NotDel%
		ORDER BY 
			%Order:RCH%
	EndSql
	
#ELSE

	cAliasQryRCH := "RCH"
	nOrderRCH := (cAliasQryRCH)->(dbsetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")))

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁCarrega o filtro do RCH conforme os parametros selecionados  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cRCHFilter += xFilial("RCH")+cProcesso+cPeriodo+cNumPagto

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seleciona a area de trabalho								  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	dbSelectArea(cAliasQryRCH)
	(cRCHQuery)->(dbSetOrder(nOrderRCH))
	(cRCHQuery)->(dbSeek(cFilter))	

#ENDIF

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Percorre os periodos selecionados							  Ё
Ё O codigo foi des. para recuperar mais de um periodo, porem  Ё
Ё atualmente so podemos selecionar um unico periodo			  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aAdd( aResRCH, {} )
For nX := 1 To Len(aFieldsRCH)
	aAdd( aResRCH[Len(aResRCH)], (cAliasQryRCH)->&(aFieldsRCH[nX,01]) )
Next

#IFDEF TOP

	(cAliasQryRCH)->(dbCloseArea())

#ENDIF
	
cOrderSRA := SqlOrder( SRA->( IndexKey() ) )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCampos para Query do SRA									  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/  
aFieldsSRA:={;
		 	"RA_FILIAL"		,;
			"RA_MAT"  		,;
			"RA_NOME" 		,;
			"RA_CC"			,;
			"RA_TNOTRAB"	,;
			"RA_SEQTURN" 	,;
			"RA_REGRA"  	,;
	 		"RA_ADMISSA"   	,; 
	 		"RA_DEMISSA"  	,;
	 		"RA_CATFUNC" 	,;
	 		"RA_SITFOLH"  	,;
	 		"RA_HRSEMAN"  	,;
	 		"RA_AFASFGT" 	,;
	 		"RA_RESCRAI"  	,;
	 		"RA_MSBLQL" 	,;
	 		"RA_CRACHA"    ;
	 	}

If cPaisLoc == 'MEX'
	aAdd( aFieldsSRA , "RA_FECREI" )
EndIf	 	
	 	
For nContSRA := 1 To Len(aFieldsSRA)
	If ( (nContSRA > 1) )
		cFieldsSRA += " , " + aFieldsSRA[ nContSRA ]
	Else
		cFieldsSRA += aFieldsSRA[ nContSRA ]
	EndIf
Next

cFieldsSRA += ", SRA.R_E_C_N_O_ RARECNO "
cFieldsSRA := "%"+cFieldsSRA+"%"

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁPassa por todos os periodos selecionados do RCH para gerar o Ё
Ёcalendario para cada um dos periodos selecionados			  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If ( !Empty(aResRCH[1,nPosProc]) .and. !Empty(aResRCH[1,nPosPer]) )

Begin Sequence

	If ( cFilAnt != aResRch[1,nPosRchFil] )
		cFilAnt := aResRch[1,nPosRchFil]
	EndIf
	
	If ( nContSRA == 1 )
		dIniPer  := aResRch[1,nPosDtIni]
		dFimPer  := aResRch[1,nPosDtFim]
		cRchProc := aResRch[1,nPosProc]
		cProcAnt := aResRch[1,nPosProc]
	EndIf

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Gerar log de ocorrencias apenas para a primeira ocorrencia  Ё
	Ё quando o periodo selecionado estiver fechado				  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	If !Empty(aResRch[1,nPosDtFec])
            
	   /*	If ( aScan( aLog, { |x| x == STR0010 + " " + STR0011 + "!" } ) == 0 )		
			aAdd( aLog, { (cAliasQrySRA)->&(cPrfSRA+FILIAL) + " - " +(cAliasQrySRA)->&(cPrfSRA+MAT) }  )
			aAdd( aLog, { (cAliasQrySRA)->&(cPrfSRA+FILIAL) + " - " +(cAliasQrySRA)->&(cPrfSRA+MAT) }  )
			aAdd( aLog, { STR0010 + " " + STR0011 + "!" } )
		EndIf		*/
		Break
	EndIf

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁSeleciona o processo, e as data inicial e final do periodo   Ё
	Ёdeste processo, para selecionar todos os func. deste proc.	  Ё	
	Ёe gerar o calendario para todo periodo						  Ё	
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	If ( Len(aResRch) > 1 )
		If ( nContSRA == Len(aResRch) ) 
			dFimPer  := aResRch[1,nPosDtFim]
			cRchProc := aResRch[1,nPosProc]
		Else     	 
			If ( cProcAnt != aResRch[1,nPosProc] )
				dFimPer  := aResRch[1,nPosDtFim]
				cRchProc := aResRch[1,nPosProc]
			Else
				dIniPer  := aResRch[1,nPosDtIni]
				cProcAnt := aResRch[1,nPosProc]
				Break				
			EndIf
		EndIf
	Else
		dIniPer := aResRch[1,nPosDtIni]
		dFimPer := aResRch[1,nPosDtFim]
	EndIf

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Alimenta o objeto oPeriodo com as Datas Iniciais do ProcessoЁ
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	oPeriodo:cProcesso := aResRch[ 01, nPosProc   ]
	oPeriodo:cPeriodo  := aResRch[ 01, nPosPer	  ]
	oPeriodo:cNumPagto := aResRch[ 01, nPosNumPag ]	
	oPeriodo:GetPer()	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seleciona os funcionarios conforme os parametros			  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	#IFDEF TOP
	
		cFilterSRA := "%"
		
		If !lWorkFlow
			If !Empty(mv_par05)
				cFilterSRA += cFilPrc + " AND "
			EndIf
			If !Empty(mv_par06)
				cFilterSRA += + cMat + " AND "
			EndIf
			If !Empty(mv_par07)
				cFilterSRA += cDpto + " AND "
			EndIf
			If !Empty(mv_par08)
				cFilterSRA += cCC + " AND"
			EndIf
		Else
			If !Empty(mv_par05)
				cFilterSRA += " RA_FILIAL = '" + cFilPrc + "' AND "
			EndIf
			If !Empty(mv_par06)
				cFilterSRA += " RA_MAT = '" + cMat + "' AND "
			EndIf
			If !Empty(mv_par07)
				cFilterSRA += " RA_DEPTO = '" + cDpto + "' AND "
			EndIf
			If !Empty(mv_par08)
				cFilterSRA += " RA_CC = '" + cCC + "' AND"
			EndIf		
		EndIf

		cFilterSRA += " RA_PROCES = '"+cProcesso+"' AND"
		
		cFilterSRA += " RA_SITFOLH <> '"+cSituacao+"'"

		cFilterSRA += " %"
		
		BeginSql Alias cAliasQrySRA
    
            	COLUMN RA_ADMISSA as Date, RA_DEMISSA as Date
	
	            SELECT   
					%Exp:cFieldsSRA%
	            FROM 
	            	%Table:SRA% SRA
	            WHERE 
					%Exp:cFilterSRA% AND SRA.%NotDel%
		EndSql
	          	
	#ELSE
		
		cAliasQrySRA := "SRA"
		nOrderSRA    := (cAliasQrySRA)->(dbSetOrder(RetOrder("SRA","RA_FILIAL+RA_PROCES+RA_MAT")))
			
       	If !Empty(mv_par05)
			cFilterSRA += cFilPrc
		EndIf
		
		cFilterSRA += cProcesso
		
		If !Empty(mv_par06)
			cFilterSRA += " .and. " + cMat
		EndIf
		
		If !Empty(mv_par07)
			cFilterSRA += " .and. " + cDpto
		EndIf
		
		If !Empty(mv_par08)
			cFilterSRA += " .and. " + cCC
		EndIf
	
		dbSelectArea(cAliasQrySRA)
		dbSetOrder(nOrderSRA)
		
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Posiciona no registro do funcionario						  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		(cAliasQrySRA)->(MsSeek(cFilAnt+cRchProc,.T.))
		
	#ENDIF
	    
	    If (cAliasQrySRA)->(Eof())
		    lErroCal := .T.
			oCalendError:SendError('09',OemToAnsi(STR0021), .T.) //"NЦo foi possМvel localizar FuncionАrios! Verifique os parБmetros selecionados."
			aAdd( aAuxError , oCalendError:aLogErrors[Len(oCalendError:aLogErrors)] )			
	    Else
	    
		    If !lWorkFlow
			    If lRelease11
					oSelf:SetRegua1(SRA->(RecCount()))
					oSelf:SaveLog(OemToAnsi(STR0016) + " " + OemToAnsi(STR0005) + " " + OemToAnsi(STR0017))	//"Inicio de Processamento"
				Else					
					MakeAdvplExpr( cPerg )
		
					If !Empty(mv_par05)
						cFilScope := &( " { || " + STRTRAN(mv_par05,"RA_FILIAL","M0_CODFIL") + " } " )
			
						/*
						здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Atualiza a Mensagem para a IncProcG1() (Cadastro de Empresas)Ё
						юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
						CREATE SCOPE aInfo FOR ( ( M0_CODIGO == cEmpAnt ) .and. ( Eval( cFilScope ) ) )
						BarGauge1Set( ( nRecsBarG := SM0->( ScopeCount( aInfo ) ) ) )
					Else
						/*
						здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Atualiza a Mensagem para a IncProcG1() (Cadastro de Empresas)Ё
						юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
						CREATE SCOPE aInfo FOR ( ( M0_CODIGO == cEmpAnt ) )
						BarGauge1Set( ( nRecsBarG := SM0->( ScopeCount( aInfo ) ) ) )			
					EndIf
							
					/*/
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Cria o Bloco dos Funcionarios que atendam ao Scopo	   	   Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			       	If !Empty(mv_par05)
						cSraScope += mv_par05 + " .and. "
					EndIf
					If !Empty(mv_par06)
						cSraScope += mv_par06 + " .and. "
					EndIf
					If !Empty(mv_par07)
						cSraScope += mv_par07 + " .and. "
					EndIf
					If !Empty(mv_par08)
						cSraScope += mv_par08 + " .and. "
					EndIf
					
					cSraScope	:= &( " { || " + cSraScope + "( RA_PROCES = '" + cProcesso + "' ) } " )
					
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Verifica o Total de Registros a Serem Processados            Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					CREATE SCOPE aRecsSRA FOR ( Eval (cSraScope) )
					nRecsBar2 := SRA->( ScopeCount( aRecsSRA ) )			
					
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Define o Numero de Elementos da BarGauge                     Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					BarGauge1Set( nRecsBarG )
					
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Inicializa a Mensagem para a IncProcG2() ( Funcionarios )	   Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					IncProcG2( OemToAnsi( STR0013 ) , .F. )	//Gerando CalendАrio"
					
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Inicializa a Regua para a IncProcG2() ( Funcionarios )	   Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					BarGauge2Set( nRecsBar2 )			
				EndIf
			EndIf
				
			Do Case
				/*/
				зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Geracao de calendario										  Ё
				юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				Case nOperacao == 1
	
					/*/
					зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Percorre os funcionarios selecionados 					  Ё
					юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/    
					While (cAliasQrySRA)->( !Eof() ) 
															
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Controla as Barras de Status/Execucao						  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/				
						fStsBar( oSelf,;
								 lIncBar1,;
								 nRecsBar2,;
								 @cFilAnt,;
								 (cAliasQrySRA)->(RA_FILIAL),;
								 cAliasQrySRA,;
								 lWorkFlow )
										
						#IFNDEF TOP
							If (cAliasQrySRA)->( Eval( cFilterSRA ) )
								(cAliasQrySRA)->(dbSkip())
								Loop		
							EndIf
						#ELSE
							SRA->(MsGoTo((cAliasQrySRA)->RARECNO))
						#ENDIF
						
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Efetua criacao do calendario p/ o periodo 				  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
						fWriteCal( (cAliasQrySRA)->(RA_FILIAL),;
								   (cAliasQrySRA)->(RA_MAT),;
								   (cAliasQrySRA)->(RA_CC),;
								   (cAliasQrySRA)->(RA_SEQTURN),;
								   (cAliasQrySRA)->(RA_TNOTRAB),;
								   dIniPer,;
								   dFimPer )
								   
						(cAliasQrySRA)->(dbSkip())
						
					EndDo
		
				/*/
				зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Gerar com sobreposicao de calendario						  Ё
				юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				Case nOperacao == 2
	
					/*/
					зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Percorre os funcionarios selecionados 					  Ё
					юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/			
					While (cAliasQrySRA)->( !Eof() )
					
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Controla as Barras de Status/Execucao						  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/				
						fStsBar( oSelf,;
								 lIncBar1,;
								 nRecsBar2,;
								 @cFilAnt,;
								 (cAliasQrySRA)->(RA_FILIAL),;
								 cAliasQrySRA,;
								 lWorkFlow )
					
						#IFNDEF TOP
							If (cAliasQrySRA)->( Eval( cFilterSRA ) )
								(cAliasQrySRA)->(dbSkip())
								Loop		
							EndIf
						#ELSE
							SRA->(MsGoTo((cAliasQrySRA)->RARECNO))
						#ENDIF				
		
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Deleta o calendario do inicio do periodo atual ate o ultimo Ё
						Ё calendario criado											  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/						
						fDelCal( (cAliasQrySRA)->(RA_FILIAL), (cAliasQrySRA)->(RA_MAT), dIniPer )
						
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Efetua criacao do calendario p/ o periodo 				  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
						lRet := fWriteCal( (cAliasQrySRA)->(RA_FILIAL),;
										   (cAliasQrySRA)->(RA_MAT),;
										   (cAliasQrySRA)->(RA_CC),;
										   (cAliasQrySRA)->(RA_SEQTURN),;
										   (cAliasQrySRA)->(RA_TNOTRAB),;
										   dIniPer,;
										   dFimPer )
						(cAliasQrySRA)->(dbSkip())
						
				    EndDo
		
				/*/
				зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Eliminar calendario										  Ё
				юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				Case nOperacao == 3
	
					/*/
					зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Percorre os funcionarios selecionados 					  Ё
					юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/			
					While (cAliasQrySRA)->( !Eof() )
					
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Controla as Barras de Status/Execucao						  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/				
						fStsBar( oSelf,;
								 lIncBar1,;
								 nRecsBar2,;
								 @cFilAnt,;
								 (cAliasQrySRA)->(RA_FILIAL),;
								 cAliasQrySRA,;
								 lWorkFlow )
					
						#IFNDEF TOP
							If (cAliasQrySRA)->( Eval( cFilterSRA ) )
								(cAliasQrySRA)->(dbSkip())
								Loop		
							EndIf
						#ELSE
							SRA->(MsGoTo((cAliasQrySRA)->RARECNO))
						#ENDIF				
					
						/*/
						зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Efetua delecao dos calendarios							  Ё
						юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
						fDelCal( (cAliasQrySRA)->(RA_FILIAL), (cAliasQrySRA)->(RA_MAT), dIniPer, dFimPer )
								 
						(cAliasQrySRA)->(dbSkip())
	
					EndDo
			
			EndCase
		
		EndIf

		If lErroCal
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			ЁDemonstra erros na geracao do calendario 					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		    oCalendError:aLogErrors := aClone( aAuxError )
		    oCalendError:ShowErrors()
		EndIf
		
		If !lWorkFlow
			If lRelease11
				oSelf:SaveLog(OemToAnsi(STR0018) + " " + OemToAnsi(STR0005) + " " + OemToAnsi(STR0017))	//"TИrmino de Processamento"
			EndIf
        Endif
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Iguala os processos para busca de novo periodo no RCH		  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	cProcAnt := cProcesso
	
	#IFDEF TOP
		(cAliasQrySRA)->(dbCloseArea())
	#ENDIF
	
	End Sequence
	
Else
	cMsgLog := STR0012	// "Periodo nao Cadastrado!"
	If !lWorkFlow
		MsgInfo( cMsgLog )
	Else
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Enviando Mensagens para o Console do Server                 			Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		ConOut("")
		ConOut( cMsgLog )
		ConOut("")
	EndIf
EndIf

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁfWriteCal ЁAutor ЁIgor Franzoi	  			  ЁDataЁ08/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁChama a funcao de criacao do calendario 					  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁfWriteCal()                                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ cFil      = Filial 					 					  Ё╠╠
╠╠Ё	         Ё cMat 	 = Matriculas dos funcionarios para geracao       Ё╠╠
╠╠Ё	         Ё dIniPer	 = Inicio do periodo atual						  Ё╠╠
╠╠Ё	         Ё dFimPer   = Fim do periodo atual							  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function fWriteCal( cFil,; 		//07 -> Filial atual do funcionario
					cMat,;      //08 -> Matricula atual
					cCC,;       //09 -> Centro de Custo
					cSeq,;      //04 -> Sequencia
					cTno,;      //03 -> Turno
					dIniPer,;   //01 -> Periodo inicial
					dFimPer,;   //02 -> Periodo final
					lDtaCal,; 	//17 -> .T. Caso exista calendario fisico 
					dIniCal,; 	//18 -> Data inicial do calendario fisico
					dFimCal  ) 	//19 -> Data final do calendario fisico	

Local lRet  := .T.
Local aArea := GetArea()

Local lSncMaMe	  := NIL
Local lForceNew	  := .T.
Local lExecQryTop := NIL

Local aTurnos
Local aExcePer
Local aTabPadrao
Local aTabCalend
Local aMarcacoes

If ( Type("cAuxFilAnt") == "U" )
	cAuxFilAnt := ""
EndIf

If ( Type("aAuxError") == "U" )
	aAuxError := {}
EndIf

If ( Type("cRecCalend") == "U" )
	cRecCalend := ""
EndIf

If ( Type("oCalendError") == "U" )
	oCalendError := PONERROR():New()
EndIf

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁChama CriaCalend para geracao do calendario				  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	lRet := CriaCalend(	dIniPer		,; //01 -> Data Inicial do Periodo
		 				dFimPer		,; //02 -> Data Final do Periodo
						cTno		,; //03 -> Turno Para a Montagem do Calendario
						cSeq		,; //04 -> Sequencia Inicial para a Montagem Calendario
						@aTabPadrao	,; //05 -> Array Tabela de Horario Padrao
						@aTabCalend	,; //06 -> Array com o Calendario de Marcacoes
						cFil		,; //07 -> Filial para a Montagem da Tabela de Horario
						cMat		,; //08 -> Matricula para a Montagem da Tabela de Horario
						cCc			,; //09 -> Centro de Custo para a Montagem da Tabela
						@aTurnos	,; //10 -> Array com as Trocas de Turno
						@aExcePer	,; //11 -> Array com Todas as Excecoes do Periodo
						lExecQryTop	,; //12 -> Se executa Query para a Montagem da Tabela Padrao
						lSncMaMe	,; //13 -> Se executa a funcao se sincronismo do calendario
						lForceNew	,; //14 -> Se Forca a Criacao de Novo Calendario
						@aMarcacoes ,; //15 -> Array com marcacoes para tratamento de Turnos Opcionais
						.T.			,; //16 -> .T. Determina a Criacao/Carga do Calendario Fisico  
						lDtaCal		,; //17 -> .T. Caso exista calendario fisico 
						dIniCal		,; //18 -> Data inicial do calendario fisico
						dFimCal		,; //19 -> Data final do calendario fisico	
						.T.			,; //20 -> .T. determina que o calendario sera gravado no caso de nao existir
						.T.			 ; //21 -> .T. determina que a rotina chamadora eh a Geracao de Calendarios (PONM400)
					)
	
	If !lRet
	    If cAuxFilAnt <> cFil
	    	aAdd( aAuxError , { cRecCalend , STR0019 + " - " + cFil } )   //"Filial - XX"
	    	cAuxFilAnt := cFil
	    EndIf
	    aAdd( aAuxError , { cRecCalend , Space(2) + STR0014 + " " + cMat + " - " + STR0015 + " " + SRA->RA_NOME } )//"MatrМcula XX - Nome XXXXXXXXXXXXXXX"
	    IF !Empty( oCalendError:aLogErrors )
	    	aAdd( aAuxError , oCalendError:aLogErrors[Len(oCalendError:aLogErrors)] )
	    Endif
	    oCalendError:aLogErrors := {}
	    lErroCal := .T.
	EndIf
RestArea( aArea )

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁfDelCal   ЁAutor ЁIgor Franzoi	  			  ЁDataЁ08/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁDeleta registros de calendario fisico para o funcionario	  Ё╠╠
╠╠Ё			 ЁEsta funcao deleta os cabec. dos calend. (RF6), e faz uma   Ё╠╠
╠╠Ё			 Ёchamada a outra funcao que delete os itens do calend. (RF7) Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁfDelCal()	                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ															  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function fDelCal( cFil, cMat, dDtaIni, dDtaFim )

Local lRet   := .F.
Local cAlias := "RF6"
Local aArea  := GetArea()

#IFNDEF TOP
	Local nOrderRf6  
#ENDIF
Local cQuery      := ""
Local cFilter     := ""
Local cFilRecno   := ""
Local cAliasQry	  := ""
Local cQueryDelet := ""
Local cRetSqlName := InitSqlName(cAlias)
Local cNameDB	  := ""

Local nMinRec := 0
Local nMaxRec := 0

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCaso nao tenha sido definido o tipo da variavel executa a    Ё
Ёfuncao novamente para setar o valor						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁO banco DB2 nao aceita o nome da tabela apos o comando DELETE			 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cNameDB	:= Upper(TcGetDb())

If lSrvType
	cDelet    := "% RF6.D_E_L_E_T_ = ' ' %"
	cCpoRecno := "R_E_C_N_O_"
Else
	cDelet    := "% RF6.@DELETED@ = ' ' %"
	cCpoRecno := "RRN("+cRetSqlName+")"
EndIf

Begin Transaction

#IFDEF TOP

	cAliasQry := GetNextAlias()

	If !Empty(dDtaFim)
		cFilter := " RF6.RF6_FILIAL = '"+cFil+"'"
		cFilter += " AND RF6.RF6_MAT = '"+cMat+"' "
		cFilter += " AND RF6.RF6_DATA >= '"+Dtos(dDtaIni)+"'"
		cFilter += " AND RF6.RF6_DATA <= '"+Dtos(dDtaFim)+"'"
	Else
		cFilter := " RF6.RF6_FILIAL = '"+cFil+"'"
		cFilter += " AND RF6.RF6_MAT = '"+cMat+"' "
		cFilter += " AND RF6.RF6_DATA >= '"+Dtos(dDtaIni)+"'"
	EndIf
	
	cFilter := "%"+cFilter+"%"

	BeginSql alias cAliasQry
		column RF6_DATA	as Date
		%NoParser%
		SELECT 
			MAX(RF6_DATA) as RF6_DATA,
			MIN(RF6.R_E_C_N_O_) MINREC, 
			MAX(RF6.R_E_C_N_O_) MAXREC
		FROM 
			%Table:RF6% RF6
		WHERE 
			%Exp:cFilter% AND
			%Exp:cDelet%
	EndSql
	
	nMinRec := (cAliasQry)->(MINREC)
	nMaxRec := (cAliasQry)->(MAXREC)

	If !Empty(nMinRec)
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Deleta os itens antes do cabecalho						  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )
			
		cQuery := "DELETE " 
	
		If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
			cQuery += cRetSqlName
		EndIf
	
		cQuery += " FROM " + cRetSqlName + " RF6 "
		 
		While ( nMinRec <= nMaxRec )		
            cFilRecno := " WHERE "
            cFilRecno += " RF6." + cCpoRecno + " >= " + AllTrim( Str( nMinRec , 18 , 0 ) )
            cFilRecno += " AND "
            cFilRecno += " RF6." + cCpoRecno + " <= " + AllTrim( Str( ( nMinRec += 1024 ) , 18 , 0 ) )     
            cFilRecno += " AND "
            cQueryDelet := ( cQuery + cFilRecno + SubStr( AllTrim(cFilter), 3,Len(AllTrim(cFilter))-3 ) )

            TcSqlExec( cQueryDelet )
		End While
		
		TcRefresh( cRetSqlName )
		lRet := .T.
	EndIf
    
	(cAliasQry)->( DbCloseArea() )
	
#ELSE
	
	cAliasQry := cAlias
	nOrderRf6 := RetOrder(cAliasQry, "RF6_FILIAL+RF6_MAT+RF6_DATA+RF6_TURNO")

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seleciona a area de trabalho								  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	dbSelectArea(cAliasQry)
	dbSetOrder(nOrderRf6)
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Posiciona no registro do funcionario						  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	(cAliasQry)->(MsSeek(cFil+cMat+Dtos(dDataIni),.T.))
	
	cPref := cAliasQry
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Deleta os itens antes do cabecalho						  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )
	
	While (cAliasQry)->( !Eof() .and. &(cPref+"FILIAL")+&(cPref+"MAT") ==  cFil+cMat .and. ;
		  (&(cPref+"DATA") >= Dtos(dDtaIni) .and. &(cPref+"DATA") <= Dtos(dDtaFim) ) )
		(cAliasQry)->(dbDelete())
		(cAliasQry)->(dbSkip())
	EndDo

	lRet := .T.
	
#ENDIF

End Transaction 

RestArea(aArea)

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁfDelCalIteЁAutor ЁIgor Franzoi	  			  ЁDataЁ08/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁDeleta registros de calendario fisico para o funcionario	  Ё╠╠
╠╠Ё			 ЁEsta funcao deleta os itens. dos calend. (RF7)			  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁfDelCalIte()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ															  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Static Function fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )

Local lRet   := .T.
Local cAlias := "RF7"

#IFNDEF TOP
	Local nOrderRf7  
#ENDIF
Local cQuery      := ""
Local cFilter     := ""
Local cFilRecno   := ""
Local cAliasQry   := ""
Local cQueryDelet := ""
Local cRetSqlName := InitSqlName(cAlias)
Local cNameDb	  := ""

Local nMinRec := 0
Local nMaxRec := 0

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCaso nao tenha sido definido o tipo da variavel executa a    Ё
Ёfuncao novamente para setar o valor						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁO banco DB2 nao aceita o nome da tabela apos o comando DELETE			 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cNameDB	:= Upper(TcGetDb())

If lSrvType
	cDelet    := "% RF7.D_E_L_E_T_ = ' ' %"
	cCpoRecno := "R_E_C_N_O_"
Else
	cDelet    := "% RF7.@DELETED@ = ' ' %"
	cCpoRecno := "RRN("+cRetSqlName+")"
EndIf

#IFDEF TOP

	If !Empty(dDtaFim)
		cFilter := " RF7.RF7_FILIAL = '"+cFil+"'"
		cFilter += " AND RF7.RF7_MAT = '"+cMat+"'"
		cFilter += " AND RF7.RF7_DATA >= '"+Dtos(dDtaIni)+"'"
		cFilter += " AND RF7.RF7_DATA <= '"+Dtos(dDtaFim)+"'"
	Else
		cFilter := " RF7.RF7_FILIAL = '"+cFil+"'"
		cFilter += " AND RF7.RF7_MAT = '"+cMat+"'"
		cFilter += " AND RF7.RF7_DATA >= '"+Dtos(dDtaIni)+"'"	
	EndIf
	
	cAliasQry := GetNextAlias()
	cFilter   := "%"+cFilter+"%"

	BeginSql alias cAliasQry
		column RF7_DATA as Date
		%NoParser%
		SELECT  
			MAX(RF7_DATA) as RF7_DATA,
			MIN(RF7.R_E_C_N_O_) MINREC, 
			MAX(RF7.R_E_C_N_O_) MAXREC
		FROM 
			%Table:RF7% RF7
		WHERE 
			%Exp:cFilter% AND
			%Exp:cDelet%			
	EndSql
	
	nMinRec := (cAliasQry)->( MINREC )
	nMaxRec := (cAliasQry)->( MAXREC )
	
	cQuery := "DELETE " 
	
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += cRetSqlName
	EndIf
	
	cQuery += " FROM " + cRetSqlName + " RF7 "
	 
	While ( nMinRec <= nMaxRec )
	
            cFilRecno := " WHERE "
            cFilRecno += " RF7." + cCpoRecno + " >= " + AllTrim( Str( nMinRec , 18 , 0 ) )
            cFilRecno += " AND "
            cFilRecno += " RF7." + cCpoRecno + " <= " + AllTrim( Str( ( nMinRec += 1024 ) , 18 , 0 ) )
            cFilRecno += " AND "
            cQueryDelet := ( cQuery + cFilRecno + SubStr( AllTrim(cFilter), 3,Len(AllTrim(cFilter))-3 ) )

            TcSqlExec( cQueryDelet )
	End While
	
	TcRefresh( cRetSqlName )
	
#ELSE
	
	cAliasQry := cAlias
	nOrderRf7 := RetOrder(cAlias,"RF7_FILIAL+RF7_MAT+DTOS(RF7_DATA)+RF7_DEPTO+RF7_POSTO")

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seleciona a area de trabalho								  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	dbSelectArea(cAliasQry)
	dbSetOrder(nOrderRf7)

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Posiciona no registro do funcionario						  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	(cAliasQry)->(MsSeek(cFil+cMat+Dtos(dDataIni),.T.))
	
	cPref := cAliasQry
	
	While (cAliasQry)->( !Eof() .and. &(cPref+"FILIAL")+&(cPref+"MAT") == cFil+cMat .and.    ;
            ( &(cPref+"DATA") >= Dtos(dDtaIni) .and. &(cPref+"DATA") <= Dtos(dDtaFim) ) )
		(cAliasQry)->(dbDelete())
		(cAliasQry)->(dbSkip())
	EndDo
	
#ENDIF

(cAliasQry)->(dbCloseArea())

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  ЁfDatMaxCalЁAutor ЁIgor Franzoi	  			  ЁDataЁ12/11/2007Ё╠╠
╠╠цддддддддадбддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁVerifica qual a data do ultimo calendario gerado para o 	  Ё╠╠
╠╠Ё			 Ёfuncionario 												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁfDatMaxCal()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ cFil = Filial do funcionario								  Ё╠╠
╠╠Ё			 Ё cMat = Matricula do funcionario							  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function fDatMaxCal( cFil, cMat, dDtaMax, dDtaMin )

Local lRet	:= .F.	
Local aArea := GetArea()

Local cAlias 	  := "RF6"
Local cFilter	  := ""

#IFNDEF TOP
	Local nOrderRf6  
#ELSE	
	Local cAliasQuery := cAlias
#ENDIF	

DEFAULT cFil := ""
DEFAULT	cMat := ""
DEFAULT dDtaMax := dDataBase
DEFAULT dDtaMin := dDataBase

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCaso nao tenha sido definido o tipo da variavel executa a    Ё
Ёfuncao novamente para setar o valor						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

If lSrvType
	cDelet    := "% RF6.D_E_L_E_T_ = ' ' %"
	cCpoRecno := "R_E_C_N_O_"
Else
	cDelet    := "% RF6.@DELETED@ = ' ' %"
	cCpoRecno := "RRN("+cRetSqlName+")"
EndIf

#IFDEF TOP
	
	cAliasQuery := GetNextAlias()

	cFilter := " RF6_FILIAL = '"+cFil+"'"
	cFilter += " AND RF6_MAT = '"+cMat+"'"
	cFilter := "%"+cFilter+"%"

	BeginSql alias cAliasQuery
		column MINDTA as Date, MAXDTA as Date
		%NoParser%
		SELECT 
			MIN(cAliasQuery.RF6_DATA) MINDTA, 
			MAX(cAliasQuery.RF6_DATA) MAXDTA
		FROM 
			%Table:RF6% cAliasQuery
		WHERE 
			%Exp:cFilter%
	EndSql
	
	dDtaMax := (cAliasQuery)->(MAXDTA)
	dDtaMin := (cAliasQuery)->(MINDTA)
	
	If !Empty(dDtaMax) .or. !Empty(dDtaMin)
		lRet := .T.
	EndIf
	
	(cAliasQuery)->(dbCloseArea())
	
#ELSE

	cFilter := cFil
	cFilter += cMat
	
	nOrderRf6 := (cAlias)->(dbSetOrder(RetOrder("RF6_FILIAL+RF6_MAT+DTOS(RF6_DATA)+RF6_TURNO")))

	dbSelectArea(cAlias)
	dbSetOrder(nOrderRf6)
	
	(cAlias)->(dbSeek( cFilter, .F. ))
	
	If Found()
		dDtaMin := (cAlias)->(RF6_DATA)
		lRet := .T.
	EndIf

	//Posiciona no registro acima da ultima ocorrencia possivel para a chave
	//Retrocede 1 reg para posicionar na maior ocorrencia.
	(cAlias)->(dbSeek( cFilter + "ZZZZZZZZ", .T. ))
    (cAlias)->(dbSkip(-1))
	dDtaMax := (cAlias)->(RF6_DATA)
    lRet	:= !Empty(dDtaMax)

#ENDIF

RestArea( aArea )

Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддбддддддбддддддддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFun┤┘o  	 ЁfUpdCal ЁAutor ЁIgor Franzoi	  			  ЁDataЁ12/11/2007Ё╠╠
╠╠цддддддддддеддддддддаддддддаддддддддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRealiza Update dos registros dos calendarios existentes	  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   |fUpdCal()	                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ															  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			   Ё		Ё	   Ё										  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function fUpdCal( cFil		,;	//Filial do funcionario
				  cMat		,;	//Matricula
				  cPrc		,;  //Processo para o qual o funcionario sera transf.
				  cCC		,;	//Centro de Custo
				  cRot		,;	//Roteiro
				  cPer		,;	//Periodo
				  cNumPag	,;	//Num. de Pagamento
				  cDepto	,;	//Departamento
				  cPosto	,;	//Posto
				  cCodFun	,;	//Cod. da Funcao
				  dDtaUpd	,;	//Data inicio do calendario ja existente
				  dDtaPrc	,;  //Data fim do calendario existente
				  lUpdRF6	,;	//Efetua Update no RF6 com os campos/dados passados
				  lUpdRF7	,;	//Efetua Update no RF7 com os campos/dados passados
				  aDataRF6	,;  //Dados para update, na mesma ordem dos campos RF6
				  aDataRF7	,;  //Dados para update, na mesma ordem dos campos RF7
				  aCamposRF6,;  //Campos utilizados para Update RF6
				  aCamposRF7 )  //Campos utilizados para Update RF7
				  			
Local lRet 		:= .T.
Local nCont		:= 0
Local aArea  	:= GetArea()
Local cAliasRF6 := "RF6"
Local cAliasRF7 := "RF7"

Local cQuery	  := ""
Local nOrderRF6   := ""
Local nOrderRF7	  := ""
Local cNameRF6 	  := InitSqlName( cAliasRF6 )
Local cNameRF7    := InitSqlName( cAliasRF7 )

DEFAULT lUpdRF6	  := .T.
DEFAULT lUpdRF7	  := .T.

DEFAULT aDataRF6	:= {}
DEFAULT aDataRF7	:= {}
DEFAULT aCamposRF6	:= {}
DEFAULT aCamposRF7	:= {}


/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCaso nao tenha sido definido o tipo da variavel executa a    Ё
Ёfuncao novamente para setar o valor						  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

Begin Transaction

#IFDEF TOP 

	If lSrvType
	
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁCaso nao tenha sido definido o tipo da variavel executa a    Ё
		Ёfuncao novamente para setar o valor						  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/        
		If ( lUpdRF6 )
			cQuery := " UPDATE "  
			cQuery += cNameRF6
			cQuery += " SET "
			If ( !Empty(aCamposRF6) .and. !Empty(aDataRF6) )
				For nCont := 1 To Len(aCamposRF6)
					If ( nCont == 1 )
						cQuery += cNameRF6+".RF6_"+aCamposRF6[nCont] + " = '"+aDataRF6[nCont]+"' "
					Else
						cQuery += "," + cNameRF6+".RF6_"+aCamposRF6[nCont] + " = '"+aDataRF6[nCont]+"' "
					EndIf
				Next			
			Else		
				cQuery += cNameRF6+".RF6_PROCES = '"+cPrc+"' "
				cQuery += cNameRF6+".RF6_PERIOD = '"+cPer+"' "
				cQuery += cNameRF6+".RF6_ROTEIR = '"+cRot+"' "
				cQuery += cNameRF6+".RF6_NUMPAG = '"+cNumPag+"' "
			EndIf
			cQuery += " WHERE "
			cQuery += cNameRF6+".RF6_FILIAL = '"+cFil+"' AND "
			cQuery += " " + cNameRF6+".RF6_MAT = '"+cMat+"' "
			cQuery += " AND " + cNameRF6+".RF6_DATA >= '"+dDtaUpd+"' "
			cQuery += " AND " + cNameRF6+".RF6_DATA <= '"+dDtaPrc+"' "
		
			TcSqlExec( cQuery )		
			TcRefresh( cNameRF6 )		
		EndIf
	
		If ( lUpdRF7 )
			cQuery := " UPDATE "  
			cQuery += cNameRF7
			cQuery += " SET " 
			If ( !Empty(aCamposRF7) .and. !Empty(aDataRF7) )
				For nCont := 1 To Len(aCamposRF7)
					If ( nCont == 1 )
						cQuery += cNameRF7+".RF7_"+aCamposRF7[nCont] + " = '"+aDataRF7[nCont]+"' "
					Else
						cQuery += "," + cNameRF7+".RF7_"+aCamposRF7[nCont] + " = '"+aDataRF7[nCont]+"' "
					EndIf
				Next
			Else
				cQuery += cNameRF7+".RF7_CC = '"+cCC+"' "
				cQuery += cNameRF7+".RF7_DEPTO = '"+cDepto+"' "
				cQuery += cNameRF7+".RF7_POSTO = '"+cPosto+"' "
				cQuery += cNameRF7+".RF7_CODFUN = '"+cCodFun+"' "	
			EndIf
			cQuery += " WHERE "
			cQuery += cNameRF7+".RF7_FILIAL = '"+cFil+"' "
			cQuery += " AND " + cNameRF7+".RF7_MAT = '"+cMat+"' "
			cQuery += " AND " + cNameRF7+".RF7_DATA >= '"+dDtaUpd+"' "
			cQuery += " AND " + cNameRF7+".RF7_DATA <= '"+dDtaPrc+"' "
			
			TcSqlExec( cQuery )		
			TcRefresh( cNameRF7 )	
		EndIf
		
	Else
		
		If ( lUpdRF6 )
			nOrderRF6 := RetOrder("RF6", "RF6_FILIAL+RF6_MAT+RF6_DATA+RF6_TURNO" )
			
			dbSelectArea(cAliasRF6)
			(cAliasRF6)->(dbSetOrder(nOrderRf6))
			(cAliasRF6)->(dbSeek(cFil+cMat+dDtaUpd))
			
			While (cAliasRF6)->( !Eof() .and. RF6_FILIAL+RF6_MAT == cFil+cMat .and.;
				  (RF6_DATA >= dDtaUpd .and. RF6_DATA <= dDtaPrc ) )
	  
				  (cAliasRF6)->(RecLock( cAliasRF6 , .F. ))
					  
					  If ( !Empty(aCamposRF6) .and. !Empty(aDataRF6) )
						For nCont := 1 To Len(aCamposRF6)
							(cAliasRF6)->&(cNameRF6+aCamposRF6[nCont]) := aDataRF6[nCont]
						Next
					  Else
						  (cAliasRF6)->(RF6_PROCES) := cPrc
						  (cAliasRF6)->(RF6_PERIOD) := cPer
						  (cAliasRF6)->(RF6_ROTEIR) := cRot
						  (cAliasRF6)->(RF6_NUMPAG) := cNumPag
					  EndIf
					  
				  (cAliasRF6)->(MsUnlock())
			      
			      (cAliasRF6)->(dbSkip())
			EndDo
		EndIf
		
		If ( lUpdRF7 )
			nOrderRF7 := RetOrder("RF6", "RF7_FILIAL+RF7_MAT+RF7_DATA+RF7_DEPTO+RF7_POSTO" )		
			
			dbSelectArea(cAliasRF7)
			(cAliasRF7)->(dbSetOrder(nOrderRf6))
			(cAliasRF7)->(dbSeek(cFil+cMat+dDtaUpd))		
			
			While (cAliasRF7)->( !Eof() .and. RF7_FILIAL+RF7_MAT == cFil+cMat .and.;
				  (RF7_DATA >= dDtaUpd .and. RF7_DATA <= dDtaPrc ) )
	
				  (cAliasRF7)->(RecLock( cAliasRF7 , .F. ))
				  	  
				  	  If ( !Empty(aCamposRF7) .and. !Empty(aDataRF7) )
						For nCont := 1 To Len(aCamposRF7)
							(cAliasRF7)->&(cNameRF7+aCamposRF7[nCont]) := aDataRF7[nCont]
						Next
				  	  Else				  
						  (cAliasRF7)->(RF7_CC) 	:= cCC
						  (cAliasRF7)->(RF7_DEPTO)  := cDepto
						  (cAliasRF7)->(RF7_POSTO)  := cPosto
						  (cAliasRF7)->(RF7_CODFUN) := cCodFun
					  EndIf				  
					  
				  (cAliasRF7)->(MsUnlock())
			      
			      (cAliasRF7)->(dbSkip())
			EndDo
		EndIf
			
	EndIf

#ELSE

	If ( lUpdRF6 )	
		nOrderRF6 := RetOrder("RF6", "RF6_FILIAL+RF6_MAT+RF6_DATA+RF6_TURNO" )
	     
		dbSelectArea(cAliasRF6)
		(cAliasRF6)->(dbSetOrder(nOrderRF6))
		(cAliasRF6)->(dbSeek(cFil+cMat+dDtaUpd))
		
		While (cAliasRF6)->( !Eof() .and. RF6_FILIAL+RF6_MAT == cFil+cMat .and.;
			  ( RF6_DATA >= dDtaUpd .and. RF6_DATA <= dDtaPrc )  )
			  
			  (cAliasRF6)->( RecLock( cAliasRF6 , .F. ) )
			  
				  If ( !Empty(aCamposRF6) .and. !Empty(aDataRF6) )
					For nCont := 1 To Len(aCamposRF6)
						(cAliasRF6)->&(cNameRF6+aCamposRF6[nCont]) := aDataRF6[nCont]
					Next
				  Else
					  (cAliasRF6)->(RF6_PROCES) := cPrc
					  (cAliasRF6)->(RF6_PERIOD) := cPer
					  (cAliasRF6)->(RF6_ROTEIR) := cRot
					  (cAliasRF6)->(RF6_NUMPAG) := cNumPag
				  EndIf
			  
			  (cAliasRF6)->( MsUnlock() )
		EndDo
	EndIf
	
	If ( lUpdRF7 )
		nOrderRF7 := RetOrder("RF6", "RF7_FILIAL+RF7_MAT+RF7_DATA+RF7_DEPTO+RF7_POSTO" )
		
		dbSelectArea(cAliasRF7)
		(cAliasRF7)->(dbSetOrder(nOrderRF7))
		(cAliasRF7)->(dbSeek(cFil+cMat+dDtaUpd))
		
		While (cAliasRF7)->( !Eof() .and. RF7_FILIAL+RF7_MAT == cFil+cMat .and.;
			  ( RF7_DATA >= dDtaUpd .and. RF7_DATA <= dDtaPrc ) )
			  
			  (cAliasRF7)->( RecLock( cAliasRF7 , .F. ) )
			  
			  	  If ( !Empty(aCamposRF7) .and. !Empty(aDataRF7) )
					For nCont := 1 To Len(aCamposRF7)
						(cAliasRF7)->&(cNameRF7+aCamposRF7[nCont]) := aDataRF7[nCont]
					Next
			  	  Else				  
					  (cAliasRF7)->(RF7_CC) 	:= cCC
					  (cAliasRF7)->(RF7_DEPTO)  := cDepto
					  (cAliasRF7)->(RF7_POSTO)  := cPosto
					  (cAliasRF7)->(RF7_CODFUN) := cCodFun
				  EndIf	
			  
			  (cAliasRF7)->( MsUnlock() )
		EndDo
	EndIf

#ENDIF

End Transaction

RestArea( aArea )

Return lRet

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁPnm400TrnP	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё06/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTransferir o parametro MV_PAR01 para variavel private		Ё
|		   |cProcesso    											    |
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Pnm400TrnP()

cProcesso := &( ReadVar() )

Return( .T. )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁPnm400VP  ЁAutorЁIgor Franzoi               ЁDataЁ06/02/2008Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁValidar o Periodo digitado na Consulta Padrao				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁConsulta Padrao (SXB)				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Pnm400VP()

Local cOldAlias := Alias()
Local cFilRCH	:= xFilial("RCH")
Local cMsg

Local lRet 		:= .T.

Begin Sequence

	IF !( lRet := NaoVazio() )
		Break
	EndIF

	DbSelectArea( "RCH" )
	RCH->( dbsetOrder( Retorder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+DTOS(RCH_DTFECH)" ) ) )
	RCH->( dbSeek( cFilRCH + MV_PAR02 + MV_PAR03 + SPACE(6) , .F. ) )

	If RCH->( Eof() )
		lRet := .F.
		cMsg := STR0012	// "Periodo nao Cadastrado!"
		MsgInfo( cMsg )
	Else
		cPeriodo := MV_PAR03 
	EndIf

End Sequence
	
DbSelectArea(cOldAlias)

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |fTransfCal	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para tratamento do calendario em caso de 			Ё
Ё		   Ёtransferencia (Chamada pelo processo do GPE)				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁAssume-se que para utilizar esta funcao o SRA deve estar	   |
Ёposicionado no funcionario "PARA"							   |
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
Function fTransfCal( cRotPara,;						//Roteiro atual
					 cPerPara,;						//Periodo atual
					 cNumPagPara,;					//Num. de Pagto atual
					 dDtaRef,;						//Data Inicio, para geracao do calendario
					 dDtaFimCal,;					//Data Fim, para geracao do calendario
					 lGeraCal,;						// .T. se nao existe calendario, cria o calendario
					 lDelGer,;                      // .T. deleta o cal. a partir da data de ref. e reconstroi 
					 lAtuGer )						// .T. atualiza o cal. conforme o periodo fornecido

Local lRet 	  := .F.
Local lDtaCal := .F.  

Local dDtaMax  := Ctod("//")
Local dDtaMin  := Ctod("//")

Local dFimPerDe := Ctod("//")				//Data maxima para o calendario independente de periodo (Cal. Fisico)
Local dIniPerDe := Ctod("//")				//Data minima para o calendario independente de periodo

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё dFimPerDe = data maxima do calendario existente do func.,    |
	Ё caso exista o calendario fisico							   |
	Ё dIniPerDe = data minima do calendario existente do func.,    |
	Ё caso exista o calendario fisico							   |
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	lDtaCal := fDatMaxCal( SRA->RA_FILIAL,;
	 					   SRA->RA_MAT,;
						   @dFimPerDe,;
						   @dIniPerDe )

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁCaso nao exista calendario:								  |
	Ё dIniPerDe = data de referencia							  Ё
	Ё dFimPerDe = maior data para o periodo que o funcionario seraЁ	
	Ё 			  transferido									  Ё		
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	dIniPerDe := If( Empty(dIniPerDe), dDtaRef, dIniPerDe ) 		
	dFimPerDe := If( Empty(dFimPerDe), dDtaFimCal, dFimPerDe )

	dDtaMin  := Min( dIniPerDe, dDtaRef )
	dDtaMax  := Max( dFimPerDe, dDtaFimCal )

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё lDtaCal = se .T., existe calendario para o funcionario 	  Ё
	Ё lDtaCal = se .F., nao existe nenhum calendario para o func. Ё
	Ё 			entao gera para o periodo solicitado			  Ё	
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/		
	If !lDtaCal

		If lGeraCal
			lRet := fWriteCal( SRA->RA_FILIAL,;
							   SRA->RA_MAT,;
							   SRA->RA_CC,;
							   SRA->RA_SEQTURN,;
							   SRA->RA_TNOTRAB,;
							   dDtaMin,;
							   dDtaMax,; 
							   lDtaCal,;
							   dDtaMax,;
							   dDtaMin	)
		EndIf
			
	Else
	
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁlDelGer = .T., deleta o calendario desde a data de referenciaЁ
		Ё			ate a data maxima existente do calendario		  Ё		
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		If lDelGer

			/*/
			зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			ЁDeleta o calendario 										  Ё
			юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			fDelCal( SRA->RA_FILIAL, SRA->RA_MAT, dDtaRef, dDtaMax )

			/*/
			зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			ЁConstroi o calendario desde a data de referencia ate Maxima  Ё
			Ёexistente ou data maxima passada							  Ё			
			юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/			
			lRet := fWriteCal( SRA->RA_FILIAL,;
							   SRA->RA_MAT,;
							   SRA->RA_CC,;
							   SRA->RA_SEQTURN,;
							   SRA->RA_TNOTRAB,;
							   dDtaRef,;
							   dDtaMax,; 
							   lDtaCal,;
							   dDtaMax,;
							   dDtaMin	)
			
		Else
					   
			/*/
			зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Atualiza o calendario desde a data de referencia ate 		  Ё
			Ё a data maxima encontrada entre o calendario existente		  Ё
			юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			If lAtuGer
						
				dDtaMax := Max( dFimPerDe, dDtaMax )
				dDtaMin := Min( dIniPerDe, dDtaRef )			
				
				fUpdCal( SRA->RA_FILIAL,;
						 SRA->RA_MAT,;
						 SRA->RA_PROCES,;  
						 SRA->RA_CC,;
						 cRotPara,;
						 cPerPara,;
						 cNumPagPara,;
						 SRA->RA_DEPTO,;
						 SRA->RA_POSTO,;
						 SRA->RA_CODFUN,;
						 dDtaRef,;
						 dFimPerDe		) 

				/*/
				зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Caso a data maxima (dFimPerDe) do cal. seja menor que a dataЁ
				Ё passada (dDtaFimCal), constroi o restante do calendario paraЁ
				Ё o periodo fornecido										  Ё				
				юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				If ( dFimPerDe < dDtaFimCal )

					fWriteCal( SRA->RA_FILIAL,;
							   SRA->RA_MAT,;
							   SRA->RA_CC,;
							   SRA->RA_SEQTURN,;
							   SRA->RA_TNOTRAB,;
							   (dFimPerDe+1),;
							   dDtaFimCal,; 
							   lDtaCal,;
							   dFimPerDe,;
							   dIniPerDe )
							   
				EndIf
						 
			EndIf
										
		EndIf				
	EndIf		

Return ( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁfStsBar		 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё22/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁControle das barras de Gauge								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁfProcCal													Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function fStsBar(oSelf,lIncBar1,nRecsBar2,cFilAnt,cFilAtu,cAlias,lWorkFlow)

Local cMsgBarG1     := ""

If !lWorkFlow

	If lRelease11	
		oSelf:IncRegua1(OemToAnsi(STR0013)) //"Gerando CalendАrio"
	   	oSelf:SetRegua2(1)	     
		oSelf:IncRegua2(OemToAnsi(STR0014) +": "+ (cAlias)->(RA_MAT) + " - " + OemToAnsi(STR0015) +": "+ (cAlias)->(RA_NOME)) //"MatrМcula" " - " "Nome"
	Else
	
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁMovimenta a R┌gua de Processamento do Processamento Primaria  Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If (cFilAnt != cFilAtu)
			lIncBar1 := .T.
			cFilAnt := cFilAtu
			
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Obtem o % de Incremento da 2a. BarGauge					   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				nIncPercG1 := SuperGetMv( "MV_PONINC1" , NIL , 5 , cFilAtu )
				/*                         
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Obtem o % de Incremento da 2a. BarGauge					   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				nIncPercG2 := SuperGetMv( "MV_PONINCP" , NIL , 5 , cFilAtu )
				
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Atualiza a Mensagem para a IncProcG1() 					   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				fInfo( @aInfo , cFilAtu )
				cMsgBarG1 := ( STR0019 + " " + cFilAtu + " - " + AllTrim( aInfo[3] ) ) ////"Filial:"			
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Inicializa Mensagem na 1a BarGauge                           Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				IncProcG1( cMsgBarG1 , .F. )
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				ЁIncrementa a Barra de Gauge referente a Filial				   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				IncPrcG1Time( cMsgBarG1 , nRecsBarG , Time() , .T. , 1 , nIncPercG1 )			
						
		EndIf
		
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Movimenta a R┌gua de Processamento                           Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		IncPrcG2Time( OemToAnsi( STR0020 ) , nRecsBar2 , Time() , .F. , 2 , nIncPercG2 )	//"Processando"   
		
	EndIf
EndIf

Return ( Nil )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6ProcVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo processo						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6ProcVld()

Local lRet := .T.

lRet := EXISTCPO("RCJ")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6PeriVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo periodo						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6PeriVld()

Local lRet := .T.

lRet := EXISTCPO("RCH")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6RoteVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo roteiro						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6RoteVld()

Local lRet := .T.

lRet := EXISTCPO("SRY")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6NuPaVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo numero de pagamento			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6NuPaVld()

Local lRet := .T.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6ProInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao de inicializacao padrao do campo processo			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6ProInit()

Local cProc := Space( TamSx3( "RF6_PROCES" )[1] )

Return( cProc )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6PerInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao de inicializacao padrao do campo periodo				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6PerInit()

Local cPer := Space( TamSx3( "RF6_PERIOD" )[1] )

Return( cPer )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6RotInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao de inicializacao padrao do campo roteiro				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6RotInit()

Local cRot := Space( TamSx3( "RF6_ROTEIR" )[1] )

Return( cRot )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6NPgInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao de inicializacao padrao do campo num. de pagto		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6NPgInit()

Local cNumPag := Space( TamSx3( "RF6_NUMPAG" )[1] )

Return( cNumPag )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6ProWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Processo When								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6ProWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF6PerWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Periodo When								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6PerWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6RotWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Roteiro When								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6RoteIni()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   |RF6NPaWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Nr. de Pagto When							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF6NPaWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7FunVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo funcao						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7FunVld()

Local lRet := .T.

lRet := ( VAZIO() .or. EXISTCPO("RCJ") )

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7CCVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo Centro de Custo				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7CCVld()

Local lRet := .T.

lRet := EXISTCPO("CTT")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7PosVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo Posto						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7PosVld()

Local lRet := .T.

lRet := EXISTCPO("RCL")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7PosVld	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё08/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para validacao do campo Posto						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7DptoVld()

Local lRet := .T.

lRet := EXISTCPO("SQB")

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7CCInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao incializador padrao do Centro de Custo				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7CCInit()

Local cCC := Space( TamSx3( "RA_CC" )[1] )

cCC := SRA->RA_CC

Return cCC

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7DptoInit 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao incializador padrao do Departamento					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7DptoInit()

Local cDepto := Space( TamSx3( "RA_DEPTO" )[1] )

cDepto := SRA->RA_DEPTO

Return cDepto

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7PosInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao incializador padrao do Centro de Custo				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7PosInit()

Local cPosto := Space( TamSx3( "RA_POSTO" )[1] )

cPosto := SRA->RA_POSTO

Return cPosto 

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7FunInit	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao incializador padrao do Centro de Custo				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7FunInit()

Local cCodFun := Space( TamSx3( "RA_CODFUNC" )[1] )

cCodFun := SRA->RA_CODFUNC

Return cPosto

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7CCWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Centro de Custo When						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7CCWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7DptoWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Departamento	When						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7DptoWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7PosWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Posto When									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7PosWhen()

Local lRet := .F.

Return( lRet )

/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁRF7FunWhen	 	ЁAutorЁ  Igor Franzoi	  Ё Data Ё13/02/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao do campo Funcao When									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF7FunWhen()

Local lRet := .F.

Return( lRet )