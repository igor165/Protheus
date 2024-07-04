#INCLUDE "ARGWSLPEG.CH"  
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ARGWSLPEG  ³ Autor ³ Danilo Santos        ³ Data ³03.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de transmissao Web Services de Liquidación         ³±±
±±³           Primaria Electrónica de Granos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

Function ARGWSLPEG()
	
Local aArea     := GetArea()
Local lRetorno  := .T.
Local nVezes    := 0

PRIVATE lBtnFiltro:= .F.
PRIVATE cAliasMnt := "NJC"
PRIVATE nTamPV := TamSX3("F2_PV")[1]
PRIVATE lAutoNf := .F.
PRIVATE cURL	:= (PadR(GetNewPar("MV_ARGNEURL","http://"),250))
PRIVATE cModeloWS := "8"
Private lAutAfip :=  GetNewPar("MV_AUTAFIP",.T.)
	
While lRetorno
	lBtnFiltro:= .F.
    lRetorno := ARGTLPEG(nVezes==0)
    nVezes++
    If !lBtnFiltro
    	Exit
    EndIf
EndDo
RestArea(aArea)
Return Nil

Function ARGTLPEG(lInit,cAlias)

Local cMsgCmp	:= ""
Local aPerg     := {}
Local aCores    := {}
Local aIndArqE	:= {}
Local lRetorno  := .T.
Local lEntAtiva := .T.
Local lPerg 	:= .F.
Local lValidUpd := .T.
Local oWsPunto
Local cIdEntP	:= ""
Local cEspecie	:= ""
Local lAutomato := IsBlind()
PRIVATE cTipoLiq := ""
PRIVATE cCondic	:= ""
PRIVATE cCadastro  := STR0001 //"Transmissão Eletronica de Granos"
PRIVATE aRotina    := {}
PRIVATE bFiltraBrw
PRIVATE oTmpTable := Nil
PRIVATE nTamPV := TamSX3("F2_PV")[1]
PRIVATE cModalidad := ""

If !lAutomato
	aadd(aPerg,{2,STR0002,PadR("",Len(STR0003)),{STR0003,STR0004},120,".T.",.T.,".T."})  //"Tipo de Liquidacion"###"2-Primaria"###"1-Secundaria"###"2-Primaria"
	aadd(aPerg,{2,STR0012,PadR("",Len(STR0013)),{STR0013,STR0014},120,".T.",.T.,".T."})  //"Especie"###"2-Pagar"###"1-Receber"###"2-Pagar"
	aadd(aPerg,{2,STR0015,PadR("",Len(STR0016)),{STR0016,STR0017,STR0018},120,".T.",.T.,".T."})  //"Tipo"###"2-Parcial"###"1-Total"###"2-Parcial"###"3-Final"
	aadd(aPerg,{2,STR0005,PadR("",Len(STR0006)),{STR0007,STR0008,STR0009,STR0010},120,".T.",.T.,".T."}) //"Filtra"###"1-Autorizadas"###"2-Sem filtro"###"3-Não Autorizadas"###"4-Transmitidas"###"5-Não Transmitidas" //"Filtra"###"5-Não Transmitidas"###"1-Nao Trasmitida"###"2-Autorizada"###"3-Rejeitada"###"4-Cont. Manual"###"5-Sem Filtro"
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o serviço foi configurado - Somente o Adm pode configurar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	lPerg := ParamBox(aPerg,"Liquidacion Granos",,,,,,,,"WSLPEG",.T.,.T.) // WSLPEG
Else
	If FindFunction("GetParAuto")
		aRetAuto 	:= GetParAuto("FISA828TESTCASE")
		MV_PAR01 	:= aRetAuto[1]
		MV_PAR02	:= aRetAuto[2]
		MV_PAR03	:= aRetAuto[3]
		MV_PAR04	:= aRetAuto[4] 
		lPerg := .T.
	Endif
EndIf

If lInit
	If (!StaticCall( ARGNFE, IsReady) .Or. !StaticCall( ARGNFE, IsReady,,2))
		If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0		
			ARGNNFeCFG()
		Else
			HelProg(,"FISTRFNFe")
		EndIf
	EndIf

EndIf			                                		

If lEntAtiva .And. (!lInit .Or. StaticCall( ARGNFE, IsReady))
	
	If lPerg .And. lValidUpd
		
		aRotina   := MenuDef()
		aCores    :={{"NJC_FLLPEG==' '",'BR_VERMELHO' },;	//No transmitida
					 {"NJC_FLLPEG=='1'",'BR_VERDE'},;	//Liquidacion Autorizada
					 {"NJC_FLLPEG=='2'",'BR_PRETO'},;	//Liquidacion Rechazada   BR_AZUL
					 {"NJC_FLLPEG=='3'",'BR_AZUL'},;	//Aguardando Regresso de datos AFIP 
					 {"NJC_FLLPEG=='4'",'BR_AMARELO'}}	//Erros de cadastro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a Filtragem                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If Substr(MV_PAR02,1,1) == "1" .And. Substr(MV_PAR01,1,1) == "2"
			//Pagar e secundario
			Alert(STR0024)
			lRetorno := .F.
			Return lRetorno
		ElseIf Substr(MV_PAR02,1,1) == "2" .And. Substr(MV_PAR01,1,1) == "1"
			//Receber e primario
			Alert(STR0025)
			lRetorno := .F.
			Return lRetorno
		Endif
			
		cModalidad := Substr(MV_PAR01,1,1)
		
		If Substr(MV_PAR02,1,1) == "1"
			cEspecie := "1"
		Else
			cEspecie := "2"
		Endif
		
		cTipoLiq := Substr(MV_PAR03,1,1)
							
		cCondic := "NJC_FILIAL ='" + xFilial("NJC") + "' "
		cCondic += " .AND. NJC_TPLIQ = '" + SubStr(MV_PAR01,1,1) + "'
		cCondic += " .AND. NJC_ESPLIQ ='"+ cEspecie +"'
		cCondic += " .AND. NJC_TIPO ='"+Substr(MV_PAR03,1,1)+"'
		cCondic += " .AND. NJC_LIQ =='2'                                                
		
		If NJC->(ColumnPos("NJC_FLLPEG")) > 0	
			If SubStr(MV_PAR04,1,1) == "1" //"1-No Transmitida"
				cCondic += ".AND. NJC_FLLPEG = ' ' "
			ElseIf SubStr(MV_PAR04,1,1) == "2" //"2-Transmitida Autorizada"
				cCondic += ".AND. NJC_FLLPEG = '1' "
			ElseIf SubStr(MV_PAR04,1,1) == "3" //"3-Transmitida Rechazada"
				cCondic += ".AND. NJC_FLLPEG = '2' "  
			ElseIf SubStr(MV_PAR04,1,1) == "4" //"Sin Filtro"
				cCondic += ".AND. (NJC_FLLPEG = ' '  .OR. NJC_FLLPEG = '1' .OR. NJC_FLLPEG = '2' .OR. NJC_FLLPEG = '3' .OR. NJC_FLLPEG = '4')" 
			EndIf			
		Endif
		
		If !lAutomato	
			bFiltraBrw := {|| FilBrowse("NJC",@aIndArqE,@cCondic) }
			Eval(bFiltraBrw)
				
			mBrowse( 6, 1,22,75,"NJC",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,)
		Else
			TrfLPEG(cModeloWS)
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Restaura a integridade da rotina                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("NJC")
		RetIndex("NJC")
		dbClearFilter()
		aEval(aIndArqE,{|x| Ferase(x[1]+OrdBagExt())})	
					
	Else
		if !lValidUpd
			Aviso("REMe",STR0030 + cMsgCmp,{"OK"},3)
		endif
		lRetorno := .F.
	EndIf
Else
	HelProg(,"FISTRFNFe")
	lRetorno := .F.
EndIf
Return(lRetorno)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³MenuDef   ³ Autor ³Danilo Santos          ³ Data ³06.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Static Function MenuDef()
Private aRotina := {}                  

IF TYPE ("cModeloWS")<> "C"
	cModeloWS:="8"
endif
If lAutAfip
	aRotina := {    {STR0021, "TrfLPEG(cModeloWS)"    ,0,3,0 ,.f.},;  //"Transmissão"
				{STR0019, "ARGNNFeCfg"            ,0,2,0 ,NIL},;  //Wizard de Configuacion""
				{STR0020, "AMBWSLPEG"             ,0,3,0 ,NIL},;  //"Ambiente"###"1-Producion###"2-Homologacion"					
				{STR0011, "LPEGLeg"               ,0,2,0 ,NIL}}   //"Legenda"
Else
	aRotina := {    {STR0021, "TrfLPEG(cModeloWS)"    ,0,3,0 ,.f.},;  //"Transmissão"
				{STR0019, "ARGNNFeCfg"            ,0,2,0 ,NIL},; //Wizard de Configuacion""
				{STR0020, "AMBWSLPEG"             ,0,3,0 ,NIL},;  //"Ambiente"###"1-Producion###"2-Homologacion"
				{STR0022, "MonitLPEG"             ,0,3,0 ,NIL},;  //"Monitor"
				{STR0073, "IMPPDFLPEG"            ,0,3,0 ,NIL},;  //"PDF"								
				{STR0011, "LPEGLeg"               ,0,2,0 ,NIL}}  //"Legenda"   
Endif				            

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrfLPEG    ³ Autor ³ Danilo Santos        ³ Data ³07.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de transmissao das informaciones de Liquidación    ³±±
±±³           Primaria Electrónica de Granos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

Function TrfLPEG(cModeloWS) //(cSerie,cNotaIni,cNotaFim,lCTe,lRetorno, lAutoNf)

Local aArea       := GetArea()
Local aPerg       := {}
Local aParam      := {Space(Len(NJC->NJC_CODLIQ)),Space(Len(NJC->NJC_CODLIQ))}
Local aTexto      := {}
Local aXML        := {}
Local cRetorno    := ""
Local cIdEnt      := ""
//Local cModalidade := ""
Local cAmbiente   := ""
Local cVersao     := ""
Local cVersaoCTe  := ""
Local cVersaoDpec := ""
Local cMonitorSEF := ""
Local cSugestao   := ""
Local cURL        := "" 
Local cliqIni	  := ""
Local cliqFim	  := ""
Local nX          := 0
Local lOk         := .T.
Local oWs
Local oWizard
Local cParNfeRem := __cUserID+SM0->M0_CODIGO+SM0->M0_CODFIL+ STR0048
Local lAutomato   := IsBlind()

cURL :=  StaticCall( ARGNFE, FindURL)

MV_PAR01 := aParam[01] := cliqIni := Space(Len(NJC->NJC_CODLIQ))
MV_PAR02 := aParam[02] := cliqFim := Space(Len(NJC->NJC_CODLIQ)) 

aadd(aPerg,{1,STR0026,aParam[01],"",".T.","",".T.",50,.T.})
aadd(aPerg,{1,STR0027,aParam[02],"",".T.","",".T.",50,.T.}) 

If !Empty(cURL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAutAfip
		cIdEnt := "0000001"
	Else
		cIdEnt  := StaticCall( Locxnf2, GetIdEnt)
	Endif
	If !Empty(cIdEnt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o ambiente de execucao do Totvs Services ARGN                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAutAfip
			cAmbiente := "2"
		Else
			oWS := WSNFECFGLOC():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:nAmbiente  := 0	
			oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
			lOk := oWS:CFGAMBLOC()
			cAmbiente := oWS:CCFGAMBLOCRESULT
        Endif
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Interface                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Default cAmbiente :=""
		
		If (lOk == .T. .or. lOk == Nil)
			aadd(aTexto,{})
			aTexto[1] :=STR0034 +" "
			aTexto[1] +=STR0035+CRLF+CRLF
			aTexto[1] +=STR0036+cAmbiente+CRLF
			If !Empty(cSugestao)
				aTexto[1] += CRLF
				aTexto[1] += cSugestao
				aTexto[1] += CRLF
			EndIf			
			aTexto[1] += cMonitorSEF
			aadd(aTexto,{})
			If !lAutomato
				DEFINE WIZARD oWizard ;
					TITLE STR0031;
					HEADER STR0032;
					MESSAGE STR0033;
					TEXT aTexto[1] ;
					NEXT {|| .T.} ;
					FINISH {||.T.}
				CREATE PANEL oWizard  ;
					HEADER STR0031 ;
					MESSAGE ""	;
					BACK {|| .T.} ;
					NEXT {|| ParamSave(cParNfeRem,aPerg,"1"),Processa({|lEnd| cRetorno := WSARGTrf(aArea[1],aParam[1],aParam[2],cIdEnt,cAmbiente,cModalidad,cTipoLiq,cVersao,@lEnd)}),aTexto[02]:= cRetorno,.T.} ;
					PANEL
			    	ParamBox(aPerg,"NFEe - NFe",@aParam,,,,,,oWizard:oMPanel[2],cParNfeRem,.T.,.T.)
				CREATE PANEL oWizard  ;
					HEADER STR0031;
					MESSAGE "";
					BACK {|| .T.} ;
					FINISH {|| .T.} ;
					PANEL
				@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
				ACTIVATE WIZARD oWizard CENTERED
			Else
				If FindFunction("GetParAuto")
					aRetAuto 	:= GetParAuto("FISA828TESTCASE")
					aParam[1] 	:= aRetAuto[5]
					aParam[2]	:= aRetAuto[6]
					WSARGTrf(aArea[1],aParam[1],aParam[2],cIdEnt,cAmbiente,cModalidad,cTipoLiq,cVersao,) 
				Endif
			EndIf
		EndIf
		
		lRetorno := lOk
	Else
		lRetorno := .F.
	EndIf
Else
//Aviso("NFEe",STR0087,{" nota(s) em "},3)
	 Aviso("NFFE",STR0028 + CHR(10) + CHR(13) +;  // "No se detectó configuración de conexión con TSS."
		  STR0028 +  CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
		  STR0028 + CHR(10) + CHR(13),;   // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
		  {"OK"},3)
EndIf

RestArea(aArea)
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ARGNNFeTrf³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service ARGN                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela da Mbrowse                           ³±±
±±³          ³ExpC2: Serie                                                ³±±
±±³          ³ExpC3: Nota inicial                                         ³±±
±±³          ³ExpC4: Nota final                                           ³±±
±±³          ³ExpC5: Id da entidade empresarial                           ³±±
±±³          ³ExpC6: Ambiente de emissao da NFe                           ³±±
±±³          ³ExpC7: Modalidade de emissao da NFe                         ³±±
±±³          ³ExpC8: Versa da NFe                                         ³±±
±±³          ³ExpL9: Controle de encerramento                             ³±±
±±³          ³ExpL10: Controle de execucao em Job                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/             	
Function WSARGTrf(cAlias ,cNotaIni ,cNotaFim ,cIDEnt ,cAmbiente ,cModalidad ,cTipoLiq ,cVersao ,lEnd)

Local aArea     := GetArea()
Local aNotas    := {}
Local aRetNotas := {}
Local aNotasErr := {}
Local aRetLPG   := {}
Local aLPGTrans := {}
Local cRetorno  := ""
Local cRetAFIP  := ""
Local cWhere    := ""
Local cErro     := ""
Local cCanje	:= ""
Local cRetLPG	:= ""
Local lQuery    := .F.
Local lRetorno  := .T.
Local lCert		:= .F.
Local nRet		:= 0
Local nX        := 0
Local nY        := 0
Local nZ		:= 0
Local nI        := 0
Local nA		:= 0
Local nNFes     := 0
Local nXmlSize  := 0
Local dDataIni  := Date()
Local cHoraIni  := Time()
Local cURL      := StaticCall( ARGNFE, FindURL)
Local cEspecie	:= ""
Local cData := ""
Local cWSModelo := ""
Local oWs
Local oWSE
Local lExecute	:= .T.
Local cTeste1	:= ""
Local cTeste3	:= ""
Local nComp		:= 0
Local cTmpCert	:= criatrab(nil,.F.)  
Local lAutomato   := IsBlind()

Private oWs1
Private oWsLP
Private oWsLS
Private	oWSAP
Private oWsAS
Private oWsMonit

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina caso exista filtro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutAfip
	IF(cModeloWS $"8") //Liquidacion Eletronica de granos
		oWs := WSWSLPEG():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL       := AllTrim(cURL)+"/WSLPEG.apw"	  	
	 	if (oWS:DUMMYLPEG(oWs:cUserToken,oWs:cID_ENT))
	 		If !(oWs:OWSDUMMYLPEGRESULT:CAPPSERVER == "OK" .And. oWs:OWSDUMMYLPEGRESULT:CAUTHSERVER == "OK" .And. oWs:OWSDUMMYLPEGRESULT:CDBSERVER == "OK") 
	 			Alert(STR0023)
	 			cRetorno := STR0023
	 			Return cRetorno
	 		Endif	
	 	Else
	 		cRetAFIP += STR0063 + CRLF
	 		cRetAFIP += STR0070 + CRLF
	 		cRetAFIP += STR0071
	 		Alert(cRetAFIP)
	 		cRetorno := STR0063 
	 		Return cRetorno 
	 	Endif	
	EndIf
	
	oWSE:= WSNFESLOC():New()
	oWsE:cUserToken := "TOTVS"
	oWsE:cID_ENT    := cIdEnt
	oWSE:_URL       := AllTrim(cURL)+"/NFESLOC.apw"
	cData:=	 FsDateConv(Date(),"YYYYMMDD")
	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)
	oWSE:CDATETIMEGER := cData+"T00:00:00"
	oWSE:cDATETIMEEXP := cData+"T23:59:59"
	oWsE:cCWSSERVICE  := "wslpg"	
		
	oWSE:GETAUTHREM()
Endif
If  lAutAfip .OR. (GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3) .Or.  ("006" $ GetWscError(3) .And. !("999" $ GetWscError(3))))
	If !lAutAfip
		lExecute := .T.
		cTeste1 := GetWscError(1)
		cTeste3 := GetWscError(3)
		
		If cTeste1 == Nil .Or. cTeste3 == Nil 
			lExecute:=.F.
			nComp:=1
			While nComp < 5 .And. !lExecute
				oWSE:GETAUTHREM()
				cTeste1 := GetWscError(1)
				cTeste3 := GetWscError(3)
				If cTeste1 <> Nil .And. cTeste3 <> Nil 	
					lExecute:=.T.
				EndIf	
				nComp:=nComp+1
			EndDo 
		Endif
	Endif
	
	dbSelectArea(cAlias)
	dbClearFilter()
	RetIndex(cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as notas fiscais       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
			
	//////INCLUSAO DE CAMPOS NA QUERY////////////			
	//cField := "%"
	//cField += ",F1_CAEE" 						
	//cField += "%"
	//////////////////////////////////////////////	
	
	dbSelectArea("NJC")
	dbSetOrder(1)
	#IFDEF TOP
		
		cAlias := GetNextAlias()
		lQuery    := .T.
		BeginSql Alias cAlias
			
		COLUMN NJC_EMISSA AS DATE
					
			SELECT NJC_FILIAL,NJC_EMISSA,NJC_CODLIQ,NJC_TPLIQ,NJC_ESPLIQ,NJC_TIPO,NJC_STATUS,NJC_FLLPEG,R_E_C_N_O_   FROM %Table:NJC% NJC
				WHERE
				NJC.NJC_FILIAL = %xFilial:NJC% AND
				NJC.NJC_TPLIQ = %Exp:cModalidade% AND
				NJC.NJC_TIPO = %Exp:cTipoLiq % AND
				NJC.NJC_CODLIQ >= %Exp:cNotaIni% AND 
				NJC.NJC_CODLIQ <= %Exp:cNotaFim% AND  
				NJC.%notdel%
		EndSql
			cWhere := ".T."	
	#ELSE
		MsSeek(xFilial("NJC")+cNotaIni,.T.)
	#ENDIF
	cWhere := "!(NJC_STATUS$'2|3' ) .And. !(NJC_FLLPEG$'1')"
		
	While !Eof() .And. xFilial("NJC") == (cAlias)->NJC_FILIAL .And.;
		(cAlias)->NJC_TPLIQ == cModalidade .And.;
		(cAlias)->NJC_CODLIQ >= cNotaIni .And.;
		(cAlias)->NJC_CODLIQ <= cNotaFim
		
		dbSelectArea(cAlias)
			
		IncProc("(1/2) "+STR0045+(cAlias)->NJC_CODLIQ)  //"Preparando nota: "

		If  &cWhere
			aadd(aNotas,{})	
			nX := Len(aNotas)
			aadd(aNotas[nX],(cAlias)->NJC_FILIAL)
			aadd(aNotas[nX],(cAlias)->NJC_CODLIQ) // NJC_EMISSA,NJC_CODLIQ,NJC_TPLIQ,NJC_ESPLIQ,NJC_TIPO,NJC_FLLPEG
			aadd(aNotas[nX],(cAlias)->NJC_TPLIQ)
			aadd(aNotas[nX],(cAlias)->NJC_ESPLIQ)
			aadd(aNotas[nX],(cAlias)->NJC_TIPO)
			aadd(aNotas[nX],(cAlias)->NJC_STATUS)
			aadd(aNotas[nX],(cAlias)->NJC_EMISSA)
			aadd(aNotas[nX],(cAlias)->NJC_FLLPEG)
			aadd(aNotas[nX],(cAlias)->R_E_C_N_O_)						
		EndIf

		dbSelectArea(cAlias)
		dbSkip()	
	EndDo
	
	If lQuery
		dbSelectArea(cAlias)
		dbCloseArea()
		dbSelectArea("NJC")
	EndIf
		
	ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
	
Else
	If cTeste1 <> Nil
		MsgInfo(GetWscError(1))
	Else
		Aviso("NFFE", STR0042 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
					  STR0043 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
					  STR0044 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					  {"OK"},3)
	EndIf 	
Endif

If Len(aNotas) == 0
	cRetorno := STR0046 //"Ningun registro encontrado para los parametros informados." 	
	RestArea(aArea)
	oWs := Nil
	oWsE := Nil
	DelClassIntF()
	Return(cRetorno)	
endIf
		
cAutMsg := "- Notas Localizadas:[" + StrZero( Len(aNotas),3 ) + "]"

oWs := Nil
oWsE := Nil
If ExistBlock("XMLARLPG")
	For nX := 1 To Len(aNotas)
			
		NJC->(dbGoto(aNotas[nX][9]))
		
		//Rdmake da montagem do xml
		aRetLPG := ExecBlock("XMLARLPG",.F.,.F.,{cModeloWS, aNotas[nX][3],cTipoLiq, aNotas[nX],@aRetNotas}) 
	    aadd(aLPGTrans,aRetLPG)
	Next nX
	
Else
	Aviso(STR0076,STR0072,{"OK"},3)
	lRetorno := .F.
Endif

If Len(aLPGTrans) > 0
	cRetLPG += STR0060+CRLF //"Documento transmitido"
	For nRet:=1 to Len(aLPGTrans)
		cRetLPG += Alltrim(Str(nRet))+" - " + aLPGTrans[nRet][1][1][1][2] + CRLF
	next nRet
Else
	cErro += STR0061 +CRLF //"Documento no transmitido"
EndIf

If lRetorno
	cRetorno := STR0032+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services ARGN."
	cRetorno += STR0033 +CRLF+CRLF //"Verifique se as notas foram autorizadas , utilizando a rotina 'Monitor'. Antes de imprimir "
	cRetorno +=STR0034+AllTrim(Str(nNFes,18))+STR0035+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	cRetorno += cRetLPG	
Else
	cRetorno := STR0036+CRLF+CRLF  //"Houve erro durante a transmissão para o Totvs Services ARGN."
	cRetorno += cErro
EndIf

oWsLS := Nil 
oWs1  := Nil

If !lAutomato
	Eval(bFiltraBrw)
EndIf

RestArea(aArea)

Return(cRetorno)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ARGNNfeLeg³Autor  ³ Danilo Santos         ³ Data ³08.04.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LPEGLeg()
Local aLegenda := {}
						  
aCores    :={{"NJC_FLLPEG==' '",'DISABLE' },;			//No transmitida
							  {"NJC_FLLPEG=='1'",'ENABLE'},;		//Liquidacion Autorizada
							  {"NJC_FLLPEG=='2'",'BR_PRETO'},;		//Liquidacion Rechazada
							  {"NJC_FLLPEG=='3'",'BR_AZUL'},;	    //Aguardando Regresso de datos AFIP 
							  {"NJC_FLLPEG=='4'",'BR_AMARELO'}}		//Erros de cadastro	

Aadd(aLegenda, {"DISABLE"  ,STR0041})     //"No trasmitida" 
Aadd(aLegenda, {"ENABLE"    ,STR0037})    //"NF Transmitida" ENABLE
Aadd(aLegenda, {"BR_PRETO"   ,STR0038})   //"NF Nao transmitida"  BR_PRETO - DISABLE
Aadd(aLegenda, {"BR_AZUL"   ,STR0039})    //Aguardando Regresso de datos AFIP
Aadd(aLegenda, {"BR_AMARELO"  ,STR0040})  //"Erros de cadastro
BrwLegenda(cCadastro,STR0011,aLegenda)    //"Legenda"

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ConvDtLPG    ºAutor  ³Danilo Santos    º Data ³  15/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a data convertida conforme padrão AFIP             º±±
±±º          ³ EX: 2020-03-20 (Ano, Mes, Data)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Liquidacion de Granos Argentina                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ConvDtLPG(dEMISSA)

cDataAfip := DTOS(dEMISSA)

cDtRet := (Substr(cDataAfip,1,4) + "-" + Substr(cDataAfip,5,2) + "-" + Substr(cDataAfip,7,2))

Return cDtRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³MonitLPEG³ Autor ³Danilo Santos          ³ Data ³18.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento Liquidacion Eletronica              ³±±
±±³          ³Granos                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/

Function MonitLPEG()

Local cIdEnt   := ""
Local aPerg    := {}
Local aParam   := {Space(Len(NJC->NJC_PTOEMI)),Space(Len(NJC->NJC_CODLIQ)),Space(Len(NJC->NJC_CODLIQ))}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg                           
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+ STR0048
Local lOK        := .F.
Local cUrl       := ""
Local cNotaIni := ''
Local cNotaFim := ''
Local oScrollBox
Private lAutAfip :=  GetNewPar("MV_AUTAFIP",.T.)

cURL :=  StaticCall( ARGNFE, FindURL)

aadd(aPerg,{1,STR0062,aParam[01],"",".T.","CFH",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0026,aParam[02],"",".T.","",".T.",50,.T.})   //"Liquidacion de"
aadd(aPerg,{1,STR0027,aParam[03],"",".T.","",".T.",50,.T.})   //"Liquidacion ate"

aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])

If !Empty(cURL)//IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lAutAfip
		cIdEnt  := "000001"
	Else
		cIdEnt  := StaticCall( Locxnf2, GetIdEnt)
	Endif
	
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt) 
			lOK := ParamBox(aPerg,"ARG - NFEe",@aParam,,,,,,,cParNfeRem,.T.,.T.)	
			If (lOK)
				aListBox := LiquidMnt(cIdEnt,aParam)
			
				If !Empty(aListBox)
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )
			
					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )
										
					DEFINE MSDIALOG oDlg TITLE "Liquidacion - Granos" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "", "Liquidacion",STR0049,STR0050,STR0065,STR0066,STR0053,STR0054; //"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"
					SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aListBox )
					oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ][oListBox:nAT][5]} }
					
					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   	 		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn4 PROMPT "Refresh" 		ACTION (aListBox := LiquidMnt(cIdEnt,aParam),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn4 PROMPT "Msg Erros"  		ACTION (LPEGMsgErr(oListBox:nAT,aListBox[ oListBox:nAT,7 ])) OF oDlg PIXEL SIZE 035,011 //"Msg Erros"

					ACTIVATE MSDIALOG oDlg
				EndIf	
			EndIf
		EndIf
	Else

		Aviso("NFFE",STR0042 + CHR(10) + CHR(13) +;  // "No se detectó configuración de conexión con TSS." 
			     STR0043 +  CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
			     STR0044 + CHR(10) + CHR(13),;   // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
		         {"OK"},3)			  
	EndIf
Else
	Aviso("NFFE",STR0042 + CHR(10) + CHR(13) +;  // "No se detectó configuración de conexión con TSS."
			     STR0043 +  CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
			     STR0044 + CHR(10) + CHR(13),;   // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
			     {"OK"},3)		  
EndIf

Return

Static Function LiquidMnt(cIdEnt,aParam)

Local aListBox := {}
Local aMsg     := {}
Local nX       := 0
Local nY       := 0
Local nL	   := 0
Local cMsgErr  := ""
Local aMsgErr  := {}
Local cTpError := ""
Local cErrForm := ""
Local cNumLiq  := ""
Local cIDTss   := ""
Local cLiqIni  := ""
Local cLiqFin  := ""
Local lAjuste  := .F. 
Local cModTrans := ""
Local cURL :=  StaticCall( ARGNFE, FindURL)
Local lOk      := .T.  
Local oOk      := LoadBitMap(GetResources(), "ENABLE")
Local oNo      := LoadBitMap(GetResources(), "DISABLE") 
Local oWS
Local oRetorno
Local cAlias:=Alias()

Private oXml

If lAutAfip
	lOk := .T.
Else	
	oWs := WSWSLPEG():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/WSLPEG.apw"	

	NJC->(dbGoTop())
	dbSetOrder(1)
	MsSeek(xFilial("NJC")+Alltrim(aParam[02]))
	cLiqIni := Alltrim(NJC->NJC_CODLIQ)

	NJC->(dbGoTop())
	dbSetOrder(1)
	MsSeek(xFilial("NJC")+Alltrim(aParam[03]))
	cLiqIFin := Alltrim(NJC->NJC_CODLIQ)

	If NJC_TPLIQ == "1" .And. NJC_ESPLIQ == "1" .And. (NJC_TIPO $ "1|3")
		cModTrans := "1"
		cIDTss := "1"
	ElseIf NJC_TPLIQ == "1" .And. NJC_ESPLIQ == "1" .And. (NJC_TIPO $ "2")
		lAjuste := .T.
		cModTrans := "3"
		cIDTss := "2"
	ElseIf NJC_TPLIQ == "2" .And. NJC_ESPLIQ == "2" .And. (NJC_TIPO $ "1|3")
		cModTrans := "2"
		cIDTss := "3"
	ElseIf NJC_TPLIQ == "2" .And. NJC_ESPLIQ == "2" .And. (NJC_TIPO $ "2") 
		cModTrans := "4"
		cIDTss := "4"
		lAjuste := .T.
	Endif

	oWS:cIdInicial    := Alltrim(aParam[01]) + Alltrim(cLiqIni) + cIDTss
	oWS:cIdFinal      := Alltrim(aParam[01]) + Alltrim(cLiqIFin) + cIDTss

	lOk := oWS:MONITORLPEG()
	sleep(5000)                                                                 
	oRetorno :=  oWs:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG						
Endif 	
If (lOk)
	dbSelectArea(cAlias)
	dbSetOrder(1)
	//MsSeek(xFilial("NJC")+Alltrim(aParam[02]))
    IF(cModeloWS $ "8") //
		For nX := 1 To Len(oWs:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG)
			cNumLiq := SubStr(oWs:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG[nX]:CIDNROORDEN,5 ,12)
			DbSetOrder(1)
			If MsSeek(xFilial("NJC")+ cNumLiq )
	  		
				//aMsg := {} // Zera o array
				oXml := oWs:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG[nX]

				nPos:=0
				nPos:= aScan(aMsg,{|x| x[1]==oXml:CIDNROORDEN})
				If nPos>0
					aMsg[nPos][1]:= oXml:CIDNROORDEN 
					aMsg[nPos][2]:= oXml:CRESULTADO
					If !EMPTY(oXml:OWSRESERROR:OWSERRORARRAY[nX]:CCODIGO) .And. !EMPTY(oXml:OWSRESERROR:OWSERRORARRAY[nX]:CDESCR)
						cMsgErr := oXml:OWSRESERROR:OWSERRORARRAY[nX]:CCODIGO + " - " +  oXml:OWSRESERROR:OWSERRORARRAY[nX]:CDESCR
						aMsgErr := oXml:OWSRESERROR:OWSERRORARRAY
						aMsg[nPos][3]:= cMsgErr
					Else
						aMsg[nPos][3]:= ""
					Endif	
					aMsg[nPos][4]:= OXML:OWSRESERRORFORM:OWSERRORFORMARRAY
				Else
					aadd(aMsg,{oXml:CIDNROORDEN,oXml:CRESULTADO,IIf(!EMPTY(oXml:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) .And. !EMPTY(oXml:OWSRESERROR:OWSERRORARRAY[1]:CDESCR),aMsgErr := oXml:OWSRESERROR:OWSERRORARRAY ,aMsgErr := {}),OXML:OWSRESERRORFORM:OWSERRORFORMARRAY,IIf(Valtype(OXML:CNRAFIP) <> "U" .And. !Empty(OXML:CNRAFIP),OXML:CNRAFIP,"")}) //,oXml:CRECOMENDACAO,;
					cMsgErr := oXml:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO + " - " +  oXml:OWSRESERROR:OWSERRORARRAY[1]:CDESCR
		 		EndIf                                                                
		 		aAliasAtu:=GetArea()

		 		If oXml:CRESULTADO == "A"
		 			RecLock("NJC") //Verificar se os campos serão gravados tbm ?
		 				NJC_FLLPEG := "1" 
					//Adicionar campos a serem gravados
	 							
					MsUnlock() 						 
				ElseIf oXml:CRESULTADO == "R" .And. (!Empty(oXml:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) .And.!Empty(oXml:OWSRESERROR:OWSERRORARRAY[1]:CDESCR))
					RecLock("NJC")
						NJC_FLLPEG := "2" 
						//Adicionar campos a serem gravados
					MsUnlock()   
					cTpError := "ERR"	
				ElseIf oXml:CRESULTADO == "R" .And. (Len(OXML:OWSRESERRORFORM:OWSERRORFORMARRAY) > 1 .And. !Empty(OXML:OWSRESERRORFORM:OWSERRORFORMARRAY[1]:CDESCR))
					RecLock("NJC")
						NJC_FLLPEG := "4" 
						//Adicionar campos a serem gravados
					MsUnlock()
					cTpError := "ERRFORM" 
					cErrForm := STR0040 + " - " + STR0064
				Endif

				RestArea(aAliasAtu)
	 		
		 		If cModTrans == "1"
		 			cTpTrans := "Liquidacion Primaria"
		 		ElseIf cModTrans == "2"	
		 			cTpTrans := "Liquidacion Secundaria"
		 		ElseIf cModTrans == "3"
		 			cTpTrans := "Ajuste Primario"
		 		ElseIf cModTrans == "4"
		 			cTpTrans := "Ajuste Secundario"
		 		Endif
			 	nPos:=0 
			 	nPos:= aScan(aListBox,{|x| x[2]==oXml:CIDNROORDEN})
		        If nPos >0
			       	aListBox[nPos][1]:= IIf(oXml:CRESULTADO == "A",oOk,oNo) //IIf(Empty(oXml:CCAE),oNo,oOk) COE,  Quando retornar autorizado
		   	       	aListBox[nPos][2]:= SubStr(oXml:CIDNROORDEN,1,Len(oXml:CIDNROORDEN)-1)
		   	       	aListBox[nPos][3]:= IIf(oXml:cAMBIENTE==1,STR0055,STR0056)
		   	       	aListBox[nPos][4]:= cTpTrans
		   	       	aListBox[nPos][5]:= IIf(cTpError == "ERR", cMsgErr, cErrForm)
		   	       	aListBox[nPos][6]:= IIf(oXml:CRESULTADO == "A",STR0067,STR0068)  //PadR(oXml:CRESULTADO,250)
		   	       	aListBox[nPos][7]:= aMsg //IIf(oXml:CRESULTADO == "A",STR0067,STR0068)  PadR(oXml:CRESULTADO,250)
		   	       	aListBox[nPos][8]:= ""
		   	       	aListBox[nPos][9]:= ""
		    	Else
		   	 	   	aadd(aListBox,{ IIf(oXml:CRESULTADO == "A",oOk,oNo),; 
		   			  	SubStr(oXml:CIDNROORDEN,1,Len(oXml:CIDNROORDEN)-1),; //"ID Liquidacion"
		   			  	IIf(oXml:cAMBIENTE=="1",STR0055,STR0056) ,; //"Produção"###"Homologação"
		   			  	cTpTrans,;								
		   			  	IIf(cTpError == "ERR", cMsgErr, cErrForm),;
		   			  	IIf(oXml:CRESULTADO == "A",STR0067,STR0068),; //"Aprobado"###"Rechazado"
		   			  	aMsg,; 
		   			  	"",; 
		   			  	""})  		
		   		EndIf
			Endif
		Next nX
    Endif      
EndIf 
  
If Empty(aListBox)
	Aviso("NFEe",STR0057,{"OK"})
EndIf
   
Return(aListBox)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³LPEGMsgErr³ Autor ³Danilo Santos          ³ Data ³29.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de apresentação dos erros retornados da afip         ³±±
±±³          ³Granos                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Parametro : Array com informações do erro                              ´±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/

Function LPEGMsgErr (nLin,aListBox)
	Local cMsgAfip := ""
	Local cAux:= ""
	Local nErro := 1
	Local nI := 0
	Default aListBox := {}
	Default nLin := 1
	
	nErro := nLin 
	If aListBox[nLin][2] == "R" .And. Empty(aListBox[nLin][5])
		If Len(aListBox[nErro][3]) >= 1 .And. !Empty(aListBox[nErro][3][1]:CCODIGO) .And. !Empty(aListBox[nErro][3][1]:CDESCR)
			For nI := 1 to Len(aListBox[nErro][3])
				cMsgAfip += aListBox[nErro][3][nI]:CCODIGO + " - " + aListBox[nErro][3][nI]:CDESCR + CRLF
			Next nI
		Else
			For nI := 1 to Len(aListBox[nErro][4])
				aListBox[1][4][ni]:CDESCR
				cMsgAfip += aListBox[nErro][4][ni]:CDESCR + CRLF
			Next nI
		Endif
	
	ElseIf aListBox[nLin][2] == "A" .And. !Empty(aListBox[nLin][5])
		cMsgAfip := STR0037 + ": " + Alltrim(aListBox[nLin][5])
	Endif
	cAux := NoAcentARG(cMsgAfip)
	Aviso("Liquidacion Eletronica de Ganos",cAux,{"OK"},3)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMPPDFLPE  ³ Autor ³ Danilo Santos        ³ Data ³12.08.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa que realiza a consulta do COE na afip para a       ³±±
±±³           do pdf da liquidação eletronica de granos AFIP Argentina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

Function IMPPDFLPEG()

Local cURL   := StaticCall( ARGNFE, FindURL)
Local cIdEnt := StaticCall( Locxnf2, GetIdEnt)
Local cData  := ""	
Local cRetorno := ""
Local cRetAFIP := ""
Local lExecute := .T.
Local lPdf     := .F.
Local cTeste1 := ""
Local cTeste3 := ""
Local nComp := 0
Local cPDF  := ""
Local oWSImp := Nil
Local oWSAuth := Nil
Local oWSXCoe := Nil

oWSImp := WSWSLPEG():New()
oWSImp:cUserToken := "TOTVS"
oWSImp:cID_ENT    := cIdEnt
oWSImp:_URL       := AllTrim(cURL)+"/WSLPEG.apw"	  	
if (oWSImp:DUMMYLPEG(oWSImp:cUserToken,oWSImp:cID_ENT))
	If !(oWSImp:OWSDUMMYLPEGRESULT:CAPPSERVER == "OK" .And. oWSImp:OWSDUMMYLPEGRESULT:CAUTHSERVER == "OK" .And. oWSImp:OWSDUMMYLPEGRESULT:CDBSERVER == "OK") 
		Alert(STR0023)
		cRetorno := STR0023
		Return cRetorno
	Endif	
Else
	cRetAFIP += STR0063 + CRLF
	cRetAFIP += STR0070 + CRLF
	cRetAFIP += STR0071
	Alert(cRetAFIP)
	cRetorno := STR0063 
	Return cRetorno 
Endif	

lPdf := !Empty(NJC->NJC_PDFLG) 
	
oWSAuth:= WSNFESLOC():New()
oWSAuth:cUserToken := "TOTVS"
oWSAuth:cID_ENT    := cIdEnt
oWSAuth:_URL       := AllTrim(cURL)+"/NFESLOC.apw"
cData:=	 FsDateConv(Date(),"YYYYMMDD")
cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)
oWSAuth:CDATETIMEGER := cData+"T00:00:00"
oWSAuth:cDATETIMEEXP := cData+"T23:59:59"
oWSAuth:cCWSSERVICE  := "wslpg"	
		
oWSAuth:GETAUTHREM()

If (GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3) .Or.  ("006" $ GetWscError(3) .And. !("999" $ GetWscError(3))))

	lExecute := .T.
	cTeste1 := GetWscError(1)
	cTeste3 := GetWscError(3)
		
	If (cTeste1 == Nil .Or. cTeste3 == Nil) 
		lExecute:=.F.
		nComp:=1
		While nComp < 5 .And. !lExecute
			oWSAuth:GETAUTHREM()
			cTeste1 := GetWscError(1)
			cTeste3 := GetWscError(3)
			If cTeste1 <> Nil .And. cTeste3 <> Nil 	
				lExecute:=.T.
			EndIf	
			nComp:=nComp+1
		EndDo 
	Endif
	
	If NJC->NJC_TPLIQ == "1" .And.(!Empty(NJC->NJC_COMPRO) .Or. !Empty(NJC->NJC_COEAJU))
		If !Empty(NJC->NJC_PDFLG)
			LpgPdfImp(NJC->NJC_CODLIQ)
		Else
			oWSXCoe := WSWSLPEG():New()
			oWSXCoe:cUserToken := "TOTVS"
			oWSXCoe:cID_ENT    := cIdEnt
			oWSXCoe:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
			oWSXCoe:CCOE	   := IIf(NJC->NJC_TIPO $"1|3|",Alltrim(NJC->NJC_COMPRO),Alltrim(NJC->NJC_COEAJU))
	
			If oWSXCoe:LIQUIDPRIMXCOECONSULTAR()
				cPDF :=  oWSXCoe:oWSLIQUIDPRIMXCOECONSULTARRESULT:cPDF
				//oWSXCoe:oWSLIQUIDPRIMXCOECONSULTARRESULT:OWSAUTORIZACION:CCOE
				//oWSXCoe:oWSLIQUIDPRIMXCOECONSULTARRESULT:OWSAUTORIZACION:CESTADO
				RecLock("NJC",.F.) 
					NJC->NJC_PDFLG := cPDF
				NJC->(MsUnlock())
				LpgPdfImp(NJC->NJC_CODLIQ)
			Endif
		Endif	
	ElseIf NJC->NJC_TPLIQ == "1"
		MsgAlert(STR0075)
	Endif	
	
	If NJC->NJC_TPLIQ == "2" .And.(!Empty(NJC->NJC_COMPRO) .Or. !Empty(NJC->NJC_COEAJU))
		If !Empty(NJC->NJC_PDFLG)
			LpgPdfImp(NJC->NJC_CODLIQ)
		Else
			oWSXCoe := WSWSLPEG():New()
			oWSXCoe:cUserToken := "TOTVS"
			oWSXCoe:cID_ENT    := cIdEnt
			oWSXCoe:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
			oWSXCoe:CCOE	   := IIf(NJC->NJC_TIPO $"1|3|",Alltrim(NJC->NJC_COMPRO),Alltrim(NJC->NJC_COEAJU))
		
			If oWSXCoe:LIQUIDSECXCOECONSULTAR()
				cPDF :=  oWSXCoe:oWSLIQUIDSECXCOECONSULTARRESULT:cPDF
				//oWSXCoe:oWSLIQUIDSECXCOECONSULTARRESULT:OWSAUTORIZACION:CCOE
				//oWSXCoe:oWSLIQUIDSECXCOECONSULTARRESULT:OWSAUTORIZACION:CESTADO
				RecLock("NJC",.F.) 
					NJC->NJC_PDFLG := cPDF
				NJC->(MsUnlock())
				LpgPdfImp(NJC->NJC_CODLIQ)
			Endif
		Endif
	ElseIf NJC->NJC_TPLIQ == "2"
		MsgAlert(STR0075)
	Endif
		
Else
	
	If cTeste1 <> Nil
		MsgInfo(GetWscError(1))
	Else
		Aviso("NFFE", STR0042 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
					  STR0043 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
					  STR0044 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					  {"OK"},3)
	EndIf 	
Endif

oWSImp := Nil
oWSAuth := Nil
oWSXCoe := Nil

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LpgPdfImp
Obtem um conteudo em formato binario base64 gravado na NJC referente a liquidação 
    eletronica de Granos AFIP Argentina e transforma em arquivo PDF

@param cLiquid	- Tabela utilizada para extração do arquivo
@author  Microsiga Protheus
@version P12.25
@since 	 13/08/2020
@return Nil
/*/
//-------------------------------------------------------------------------------------          
Function LpgPdfImp(cLiquid)
Local cArqCom	:= ""
Local cPtoEmiss := ""
//Local cNunNota	:= IIf(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
//Local cSerNota 	:= IIf(cAlias=="SF1",SF1->F1_SERIE,SF2->F2_SERIE) 
Local cPathImp  := GetTempPath()
Local nHandle   := 0  

If MsSeek(xFilial("NJC") + cLiquid )  		
	cArqCom := Decode64(NJC->NJC_PDFLG) 
	cPtoEmiss := Alltrim(NJC->NJC_PTOEMI)
Endif

If !Empty (cArqCom)	
		nHandle := FCreate(cPathImp+LOWER(Alltrim(cLiquid))+Alltrim(cPtoEmiss)+".pdf",,,.F.,3)
		FWrite(nHandle,cArqCom)	
		Sleep(1000)
		FClose(nHandle)
		ShellExecute("Open",cPathImp+LOWER(Alltrim(cLiquid))+Alltrim(cPtoEmiss)+".pdf","",cPathImp, 1 )
	Else
		MsgAlert(STR0074)   //Arquivo PDF não encontrado
	Endif
Return
