#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Protheus.ch'  
#INCLUDE "ARGNFE.ch"
#INCLUDE "TOTVS.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AMBWSLPEG³ Autor ³Danilo Santos           ³ Data ³26.03.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Parametriza o  Totvs Services para o webservice WSLPEG      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AMBWSLPEG()

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
Local cURL			:= (PadR(GetNewPar("MV_ARGNEURL","http://"),250))  
Local ntempo:=0
Local cParNfePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"Liquidacion Primaria Electrica de GranoS"

aadd(aCombo1,STR0118) 
aadd(aCombo1,STR0119)
 
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
	oWS:cMODELO := "8"            
	oWS:CFGAMBLOC()         
	cCombo1 := IIf(oWS:CCFGAMBLOCRESULT <> Nil ,oWS:CCFGAMBLOCRESULT,"2")
	
	If SubStr(cCombo1,1,1) == "1"
		cCombo1 := STR0118	
	elseIf SubStr(cCombo1,1,1) == "2"
		cCombo1 := STR0119
	Endif 
	
	aadd(aPerg,{2,"Ambiente",cCombo1,aCombo1,120,".T.",.T.,".T."}) 
	
	aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,cCombo4,cCombo5,nTempo}
	If ParamBox(aPerg,"ARG - WSLPEG",aParam,,,,,,,cParNfePar,.T.,.F.)
		oWS:cUSERTOKEN := "TOTVS"
		oWS:_URL       :=  AllTrim(cURL)+"/NFECFGLOC.apw"
		oWS:cID_ENT    := cIdEnt
		oWS:nAmbiente  := Val(aParam[1])
		oWS:cMODELO	 := "8"    
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
±±³Programa  ³RetCodPro³ Autor ³Danilo Santos           ³ Data ³01-05-2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o codigo da provincia Argentina                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Codigo da provincia                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetCodPro(cDescPro)
//Codigos referentes ao site da AFIP
//http://www.afip.gob.ar/inversiones-bienes-uso/documentos/codigo-provincia.pdf

Local cCodProv := ""
Default cDescPro := ""

cDescPro := Alltrim(cDescPro)

If cDescPro == "CF" //CIUDAD AUTÓNOMA BUENOS AIRES
	cCodProv := "0"
ElseIf cDescPro == "BA" //BUENOS AIRES 	
	cCodProv := "1"
ElseIf cDescPro == "CA" //CATAMARCA
	cCodProv := "2"
ElseIf cDescPro == "CO" //CORDOBA
	cCodProv := "3"
ElseIf cDescPro == "CR" //CORRIENTES
	cCodProv := "4"
ElseIf cDescPro == "ER" //CATAMARCA RIOS
	cCodProv := "5"
ElseIf cDescPro == "JU" //JUJUY
	cCodProv := "6"
ElseIf cDescPro == "ME" //MENDOZA
	cCodProv := "7"
ElseIf cDescPro == "LR" //LA RIOJA
	cCodProv := "8"
ElseIf cDescPro == "SA" //SALTA
	cCodProv := "9"
ElseIf cDescPro == "SJ" //SAN JUAN
	cCodProv := "10"
ElseIf cDescPro == "SL" //SAN LUIS
	cCodProv := "11"
ElseIf cDescPro == "SF" //SANTA FE
	cCodProv := "12"
ElseIf cDescPro == "SE" //SANTIAGO DEL ESTERO
	cCodProv := "13"
ElseIf cDescPro == "TU" //TUCUMAN
	cCodProv := "14"
ElseIf cDescPro == "CH" //CHACO
	cCodProv := "16"
ElseIf cDescPro == "CB" //CHUBUT
	cCodProv := "17"
ElseIf cDescPro == "FO" //FORMOSA
	cCodProv := "18" 
ElseIf cDescPro == "MI" //MISIONES
	cCodProv := "19"
ElseIf cDescPro == "NE" //NEUQUÉN	
	cCodProv := "20"	
ElseIf cDescPro == "LP" //LA PAMPA	
	cCodProv := "21"	
ElseIf cDescPro == "RN" //RIO NEGRO	
	cCodProv := "22"	
ElseIf cDescPro == "SC" //SANTA CRUZ	
	cCodProv := "23"	
ElseIf cDescPro == "TF" //TIERRA DEL FUEGO	
	cCodProv := "24"	
Else
	cCodProv := "0"
Endif	

Return cCodProv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NoAcentARGºAutor  ³Danilo.Santos         º Data ³ 07/05/2020º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por retirar caracteres especiais das     º±±
±±º          ³String                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NoAcentARG(cAuxiliar)

Local cByte,ni
Local s1:= "áéíóú" + "ÁÉÍÓÚ" + "âêîôû" + "ÂÊÎÔÛ" + "äëïöü" + "ÄËÏÖÜ" + "àèìòù" + "ÀÈÌÒÙ"  + "ãõÃÕ" + "çÇ" + "ï¿½"
Local s2:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cC" + "é"
Local nPos:=0, nByte
Local cRet:=''
Default cAuxiliar := ""

cAuxiliar := (StrTran(cAuxiliar,"&","&amp;")) 

For ni := 1 To Len(cAuxiliar)
	cByte := Substr(cAuxiliar,ni,1)
	nByte := ASC(cByte)
	If nByte > 122 .Or. nByte < 48 .Or. ( nByte > 57 .And. nByte < 65 ) .Or. ( nByte > 90 .And. nByte < 97 )
		nPos := At(cByte,s1)
		If nPos > 0
			cByte := Substr(s2,nPos,1)
		Else
			If cByte $ "<"
				cByte := "<"
			Elseif cByte $ ">"
				cByte := ">"
			Elseif cByte $ "/"
				cByte := "/"
			Endif

		EndIf
	EndIf
	cRet+=cByte
Next

Return(AllTrim(cRet))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³RetImpLPGºAutor  ³Danilo.Santos         º Data ³ 23/07/2020º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por verificar aliquotas e                º±±
±±º          ³informações dos impostos                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetImpLPG(cCodLiq,cAliasImp,cTipo)

Local nValBasIva := 0
Local nValAlqIva := 0
Local aRetimp    := {}
Local lTemIva    := .F.
Local cOpDeduc  := InitSqlName("NL4")
Local nImp      := 0
Local nPosAux   := 0
Local nAliqImp  := 0
Local aAuxImp   := {}

Default cCodLiq := ""
Default cAliasImp := ""
DEfault cTipo   := ""

DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SFC")
DbSetOrder(1)

DbSelectArea("SFB")
DbSetOrder(1)

If cAliasImp == "NJC"
	If SF4->( MsSeek( xFilial("SF4")+NJC->NJC_TES) )
		If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
			While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
				If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
					IF SFB->FB_CLASSIF == "3" .AND. SFB->FB_TIPO == "N"	 .AND. SFB->FB_CLASSE == "I"
						nValBasIva := &("NJC->NJC_BASIM"+SFB->FB_CPOLVRO)
						nValAlqIva := &("NJC->NJC_ALQIM"+SFB->FB_CPOLVRO)
					Endif
				Endif
				SFC->( DbSkip() )
			Enddo
		Endif
	Endif
	aadd(aRetimp,{nValBasIva,nValAlqIva})			
Else
	//Query NL4
	cQuery := " SELECT * FROM "
	cQuery += cOpDeduc + " AS NL4 " 
	cQuery += " WHERE " 
	cQuery += " NL4.NL4_FILIAL = '" + xFilial("NL4")  + "' AND "
	cQuery += " NL4.NL4_CODLIQ = '" + NJC->NJC_CODLIQ + "' AND "
	cQuery += " NL4.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	If Select(cOpDeduc) > 0
		dbSelectArea(cOpDeduc)
		dbCloseArea()
	EndIf
	                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cOpDeduc,.T.,.T.)
	
	While (cOpDeduc)->(!Eof())
		lTemIva    := .F.
		NL4->(dbGoto((cOpDeduc)->R_E_C_N_O_))
		If cTipo == "Deduccion" 
			If SF4->( MsSeek( xFilial("SF4")+(cOpDeduc)->NL4_CODTES) )
				If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
					While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
						If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
							IF SFB->FB_CLASSIF == "3" .AND. SFB->FB_TIPO == "N"	 .AND. SFB->FB_CLASSE == "I" .AND. !lTemIva 
								lTemIva := .T.									
								nValBasIva := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
								nValAlqIva := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
								aadd(aAuxImp,{nValBasIva,nValAlqIva,NL4->NL4_TIPO,SFC->FC_IMPOSTO})
							EndIf
						EndIf	
						SFC->( DbSkip() )
					Enddo
				EndIf
			EndIf
		ElseIf cTipo == "Percepcion" 
			If SF4->( MsSeek( xFilial("SF4")+(cOpDeduc)->NL4_CODTES) )
					If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
						While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
							If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
								IF SFB->FB_CLASSE == "P"
									cDescImp := SFB->FB_DESCR
									nValPerc := &("NL4->NL4_VALIM"+SFB->FB_CPOLVRO)
									IF nValPerc > 0 // Se tiver Valor de imposto grava.
										nValBasIva := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
										nValAlqIva := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
										aadd(aAuxImp,{nValBasIva,nValAlqIva,NL4->NL4_TIPO,SFC->FC_IMPOSTO})
										
									EndiF
								EndIF
							EndIf	
							SFC->( DbSkip() )
						Enddo
					EndIf
				EndIf
		Endif	
		(cOpDeduc)->(DbSkip())
	Enddo	
	
	For nImp := 1 To Len(aAuxImp)
		If aAuxImp[nImp][3] == "2" .and.  nAliqImp <> aAuxImp[nImp][2]
			nPosAux := Ascan( aRetimp,{|x| x[1] == aAuxImp[nImp][2] })
			If nPosAux > 0
				//nAliqImp := aAuxImp[nImp][2]
				aRetimp[nPosAux][2] += aAuxImp[nImp][1]
			Else
				nAliqImp := aAuxImp[nImp][2]
				nBase := aAuxImp[nImp][1]
				aadd(aRetimp,{nAliqImp,nBase})
			Endif
		Else
			nPosAux := Ascan( aRetimp,{|x| x[1] == aAuxImp[nImp][2] })
			If nPosAux > 0
				aRetimp[nPosAux][2] += aAuxImp[nImp][1]
			Endif
		Endif
	Next nImp ++
	(cOpDeduc)->(dbCloseArea())
Endif
SF4->(dbCloseArea())
SFC->(dbCloseArea())
SFB->(dbCloseArea())

Return aRetimp



Function ConceptoRet(cConcept)

Default cConcept := ""
Do Case
	Case cConcept == "I"
		cDetallI  := ">I.V.A."
		cConcepI := "RI"
		cAliIVa  := CVALTOCHAR(FKR->FKR_ALIQ)
		nValIva	  +=  FKR->FKR_VALBAS
	Case cConcept == "G"
		cDetallG  := "Impuesto a las Ganancias"
		cConcepG := "RG" 
		cAliGan  := CVALTOCHAR(FKR->FKR_ALIQ)
		nValGan	  +=  FKR->FKR_VALBAS
	Case cConcept == "B"
		cDetallIB  := "Ingresos Brutos"
		cConcepIB := "IB" 
		cAliIB  := CVALTOCHAR(FKR->FKR_ALIQ)
		nValIB	  +=  FKR->FKR_VALBAS
	//OTHERWISE
	//	cDetallO  := "Otros Gravámenes"
	//	cConcepO := "OG" 
	//	cAliOtGr := CVALTOCHAR(FKR->FKR_ALIQ)
	//	nValOtGr  +=  FKR->FKR_VALBAS // Leandro serão tratados com esclarecimento das duvidas.
EndCase

Return .T.

Function ConceptoDed(cOpera)

Default cOpera := ""

Do Case
	Case cOpera == "1"
		cDetalle  := "COMISION"
		cConcepto := SUBSTRING(cDetalle,1,2) 
	//Case cOpera == "2"
	//	cDetalle  := "CALIDAD"
	//	cConcepto := SUBSTRING(cDetalle,1,2) // Leandro Até entender o processo das contas de calidad o envio esta sendo como otras deducciones.
	Case cOpera == "3"
		cDetalle  := "GASTOS INTEMEDIARIOS"
		cConcepto := SUBSTRING(cDetalle,1,2) 
	Case cOpera == "4"
		cDetalle  := "ALMACEN"
		cConcepto := SUBSTRING(cDetalle,1,2) 
	Case cOpera == "5"
		cDetalle  := "OD-OTRAS DEDUCCIONES"
		cConcepto := SUBSTRING(cDetalle,1,2) 
	OTHERWISE
		cDetalle  := "OD-OTRAS DEDUCCIONES"
		cConcepto := SUBSTRING(cDetalle,1,2) 
EndCase

Return .T.

//========================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ImpDebCred ºAutor  ³Danilo.Santos        º Data ³ 06/08/2020º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por verificar aliquotas e                º±±
±±º          ³informações dos impostos para o grupo de debito e credito   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpDebCred(cCodLiq,cCredDeb)

Local nValBas := 0
Local nValAlq := 0
Local nMonto0  := 0
Local nMonto105 := 0
Local nMonto21 := 0
Local aRetimp    := {}
Local lTemIva    := .F.
Local DEBCRED  := InitSqlName("NL4")
Local nImp      := 0
Local nPosAux   := 0
Local nAliqImp  := 0
Local aAuxImp   := {}

Default cCodLiq := ""
Default cAliasImp := ""
DEfault cTipo   := ""

DbSelectArea("SF4")
DbSetOrder(1)

DbSe/lectArea("SFC")
DbSetOrder(1)

DbSelectArea("SFB")
DbSetOrder(1)

//Query NL4
cQuery := " SELECT * FROM "
cQuery += DEBCRED + " AS NL4 " 
cQuery += " WHERE " 
cQuery += " NL4.NL4_FILIAL = '" + xFilial("NL4")  + "' AND "
cQuery += " NL4.NL4_CODLIQ = '" + NJC->NJC_CODLIQ + "' AND "
If cCredDeb == "Credito"
	cQuery += " NL4.NL4_TIPO = '1'  AND  NL4.NL4_TIPAJU  = '2' AND "
ElseiF cCredDeb == "Debito" 
	cQuery += " NL4.NL4_TIPO = '2'  AND  NL4.NL4_TIPAJU  = '1' AND "
Endif
cQuery += " NL4.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
	
If Select(DEBCRED) > 0
	dbSelectArea(DEBCRED)
	dbCloseArea()
EndIf
	                    
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),DEBCRED,.T.,.T.)
	
While (DEBCRED)->(!Eof())
	NL4->(dbGoto((DEBCRED)->R_E_C_N_O_))
	If SF4->( MsSeek( xFilial("SF4")+(DEBCRED)->NL4_CODTES) )
		If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
			While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
				If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
					IF SFB->FB_CLASSE == "P"
						cDescImp := SFB->FB_DESCR
							nValPerc := &("NL4->NL4_VALIM"+SFB->FB_CPOLVRO)
							IF nValPerc > 0 // Se tiver Valor de imposto grava.
								nValBas := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
								nValAlq := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
								If SFB->FB_ALIQ == 0
									nMonto0  += &("NL4->NL4_IMPORT")
								ElseIf SFB->FB_ALIQ == 10.5
									nMonto105 += &("NL4->NL4_IMPORT")
								ElseIf SFB->FB_ALIQ == 21
									nMonto21 += &("NL4->NL4_IMPORT")
								Endif
								aadd(aAuxImp,{nValBas,nValAlq,NL4->NL4_TIPO,SFC->FC_IMPOSTO,nMonto0,nMonto105,nMonto21})
										
							EndiF
					EndIF
				EndIf	
				SFC->( DbSkip() )
			Enddo
		EndIf
	EndIf
	
	(DEBCRED)->(DbSkip())
Enddo	
	
For nImp := 1 To Len(aAuxImp)
	If aAuxImp[nImp][3] == "2" .and.  nAliqImp <> aAuxImp[nImp][2]
		nPosAux := Ascan( aRetimp,{|x| x[1] == aAuxImp[nImp][2] })
		If nPosAux > 0
			//nAliqImp := aAuxImp[nImp][2]
			aRetimp[nPosAux][2] += aAuxImp[nImp][1]
			
		Else
			nAliqImp := aAuxImp[nImp][2]
			nBase := aAuxImp[nImp][1]
			aadd(aRetimp,{nAliqImp,nBase,aAuxImp[nImp][5],aAuxImp[nImp][6],aAuxImp[nImp][7]})
		Endif
	Else
		nPosAux := Ascan( aRetimp,{|x| x[1] == aAuxImp[nImp][2] })
		If nPosAux > 0
			aRetimp[nPosAux][2] += aAuxImp[nImp][1]
		Endif
	Endif
Next nImp ++
(DEBCRED)->(dbCloseArea())

SF4->(dbCloseArea())
SFC->(dbCloseArea())
SFB->(dbCloseArea())

Return aRetimp
