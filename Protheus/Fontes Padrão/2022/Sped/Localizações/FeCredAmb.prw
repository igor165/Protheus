#Include "Protheus.ch"
#INCLUDE "ARGNFE.CH"
#INCLUDE "ARGWSLPEG.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FeCredAmb� Autor �Danilo Santos           � Data �09.08.2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Parametriza o  Totvs Services para o webservice WSFECRED    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�����������������������������������������������������������������������������
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
	//������������������������������������������������������������������������Ŀ
	//�Obtem o codigo da entidade                                              �
	//��������������������������������������������������������������������������
	
	cIdEnt  := StaticCall( Locxnf2, GetIdEnt)
	
	//������������������������������������������������������������������������Ŀ
	//�Obtem o ambiente                                                        �
	//��������������������������������������������������������������������������	
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

		Aviso("NFFE",STR0298 + CHR(10) + CHR(13) +;  // "No se detect� configuraci�n de conexi�n con TSS."
					  STR0299 +  CHR(10) + CHR(13) +; // "Por favor, ejecute opci�n Wizard de Configuraci�n."
					  STR0300 + CHR(10) + CHR(13),;   // "Siga atentamente os passos para a configura��o da nota fiscal eletr�nica."
					  {"OK"},3)

EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TpRetFECrd� Autor �Danilo Santos          � Data �12.08.2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o tipo de reten��o e a descri��o                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   aTpRet - array com as informa��es                            ���
�����������������������������������������������������������������������������
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