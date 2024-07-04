#Include "Protheus.ch"
#INCLUDE "ARGNFE.CH"
#INCLUDE "ARGWSLPEG.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FeCredAmb³ Autor ³Danilo Santos           ³ Data ³09.08.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Parametriza o  Totvs Services para o webservice WSFECRED    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FeCredAmb()

Local oWs
Local aPerg  := {}

Local aCombo1:= {}

Local cCombo1:= ""
Local aCombo2:={}
Local cCombo2:= ""
Local cCombo3:= ""
Local cCombo4:= ""
Local cCombo5:= ""
Local cIdEnt := ""
Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))  
Local ntempo:=0
Local cParNfePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"Facturas de Credito Eeletronica"

aadd(aCombo1,STR0127) 
aadd(aCombo1,STR0128)
 
If !Empty(cURL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cIdEnt  := StaticCall( Locxnf2, GetIdEnt)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o ambiente                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oWS :=  WSNFECFGLOC():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw" 
	oWS:cID_ENT    := cIdEnt
	oWS:nAmbiente  := 0	 
	oWS:cMODELO := "6"            
	oWS:CFGAMBLOC()         
	cCombo1 := IIf(oWS:CCFGAMBLOCRESULT <> Nil ,oWS:CCFGAMBLOCRESULT,"2")
	
	If SubStr(cCombo1,1,1) == "1"
		cCombo1 := STR0127	
	elseIf SubStr(cCombo1,1,1) == "2"
		cCombo1 := STR0128
	Endif 
	
	aadd(aPerg,{2,"Ambiente",cCombo1,aCombo1,120,".T.",.T.,".T."}) 
	
	aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,cCombo4,cCombo5,nTempo}
	If ParamBox(aPerg,"ARG - WSFECRED",aParam,,,,,,,cParNfePar,.T.,.F.)
		oWS:cUSERTOKEN := "TOTVS"
		oWS:_URL       :=  AllTrim(cURL)+"/NFECFGLOC.apw"
		oWS:cID_ENT    := cIdEnt
		oWS:nAmbiente  := Val(aParam[1])
		oWS:cMODELO	 := "6"    
		oWS:CFGAMBLOC()
	EndIf
Else

		Aviso("NFFE",STR0298 + CHR(10) + CHR(13) +;  // "No se detectó configuración de conexión con TSS."
					  STR0299 +  CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
					  STR0300 + CHR(10) + CHR(13),;   // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					  {"OK"},3)

EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TpRetFECrd³ Autor ³Danilo Santos          ³ Data ³12.08.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o tipo de retenção e a descrição                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   aTpRet - array com as informações                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TpRetFECrd(oGridRet,aColsRet,lPreOrd)
Local aTpRet	:= {}
Local nZ		:= 0
Local cCorRet := ""
Local cDescREt:= ""

Default oGridRet :=  Nil
Default aColsRet := {}
Default lPreOrd := .F.

If !lPreOrd
	For nZ := 1 To Len(oGridRet:aCols)
		If oGridRet:aCols[nZ][1] $ "I|G|S|"
			cCorRet := "1"
			cDescREt := STR0109
			AADD(aTpRet,{cCorRet,cDescREt})
		ElseIf oGridRet:aCols[nZ][1] $ "B"
			cCorRet := "2"
			cDescREt := STR0111
			AADD(aTpRet,{cCorRet,cDescREt})
		ElseIf oGridRet:aCols[nZ][1] $ "B"
			cCorRet := "3"
			cDescREt := STR0112
			AADD(aTpRet,{cCorRet,cDescREt})
		Endif
	Next nZ
ElseIf lPreOrd
	For nZ := 1 To Len(aColsRet)
		If aColsRet[nZ][1] $ "I|G|S|"
			cCorRet := "1"
			cDescREt := STR0109
			AADD(aTpRet,{cCorRet,cDescREt})
		ElseIf aColsRet[nZ][1] $ "B"
			cCorRet := "2"
			cDescREt := STR0111
			AADD(aTpRet,{cCorRet,cDescREt})
		ElseIf aColsRet[nZ][1] $ "B"
			cCorRet := "3"
			cDescREt := STR0112
			AADD(aTpRet,{cCorRet,cDescREt})
		Endif
	Next nZ
Endif
Return aTpRet