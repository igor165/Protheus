#INCLUDE "TOTVS.CH"

Static lMvLjPdvPa := LjxBGetPaf()[2]

//--------------------------------------------------------
/*/{Protheus.doc}LjMonitPAF

Monitor do PAF-ECF para lidar com os XML's

@param 		nenhum
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Function LjMonitPAF()
Local oTela := NIL

oTela := LjMPTela()

Return NIL

//--------------------------------------------------------
/*/{Protheus.doc}LjMPTela

Monta a tela

@param 		nenhum
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Static Function LjMPTela()
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oBtn1		:= NIL
Local oBtn2		:= NIL
Local oBtn3		:= NIL
Local oBtn4		:= NIL
Local oDlg		:= NIL
Local oListBox	:= NIL
Local bLine		:= {||}
Local aCabeca	:= {"Tipo do XML","Situação","Recno","XML Enviado","XML Retorno"}
Local aListBox	:= LjListaXML("")


If GetRemoteType() == 5
	MsgAlert ("Monitor XML do PAF não disponível para ambiente SmartClient WebApp")
Else 
	If Len(aListBox) == 0
		Conout("Rotina LJMONITPAF - Nenhum dado de XML para avaliar")
		Alert("Rotina LJMONITPAF - Nenhum dado de XML para avaliar")
	Else
		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
		DEFINE MSDIALOG oDlg TITLE "Monitor XML do PAF-ECF" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
		
		bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],;
						aListBox[ oListBox:nAT,3 ],""/*aListBox[ oListBox:nAT,4 ]*/,;
						""/*aListBox[ oListBox:nAT,5 ]*/} }
		
		@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER ;
				aCabeca[1],aCabeca[2],aCabeca[3],aCabeca[4],aCabeca[5];
				SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
		
		oListBox:SetArray( aListBox )
		oListBox:bLine := bLine
		oListBox:bLDblClick := {|| LjMPRecXML(aListBox[ oListBox:nAT,5 ],@aListBox,oListBox) }

		@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "Fechar" ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"Fechar"
		@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT "XML Envio" ACTION (LjMPXmEnv(aListBox[ oListBox:nAT,4 ])) OF oDlg PIXEL SIZE 035,011 //"XML Envio"
		@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT "XML Retorno" ACTION (LjMPXmRet(aListBox[ oListBox:nAT,5 ])) OF oDlg PIXEL SIZE 035,011 //"XML Retorno"
		@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Recursos" ACTION (LjMPRecXML(aListBox[ oListBox:nAT,5 ],@aListBox,oListBox)) OF oDlg PIXEL SIZE 035,011 //"Recursos"
		
		ACTIVATE MSDIALOG oDlg
	EndIf
Endif 

Return oDlg

//--------------------------------------------------------
/*/{Protheus.doc}LjListaXML

Lista os XML's

@param		cTipoArq, caracter, Tipo de Arquivo 
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	aRet - {Tipo,Situacao XML,Recno,XML Envio,XML Retorno,Indice}
/*/
//--------------------------------------------------------
Static Function LjListaXML(cTipoArq)
Local aRet	:= {}
Local aFileRZ := {}
Local aFileES := {}
Local nX	:= 0

/*
Retorno dos Arrays aFileRZ e aFileES:
[1][1] := 1 - contador
[1][2] := "" - XML de Envio
[1][3] := "" - XML de Retorno
[1][4] := 0 - Recno do Registro para as alterações dos retornos
[1][5] := Indice da Chave de Pesquisa, no caso a 1 - Chave do Registro
*/

/*Reducao Z*/
If Empty(cTipoArq) .Or. cTipoArq == "R"
	aFileRZ := STRedXML("AE")
	If Len(aFileRZ) > 0
		For nX := 1 to Len(aFileRZ)
			If aFileRZ[nX][1] > 0
				aadd(aRet,{"Redução Z","Erro",aFileRZ[nX][4],aFileRZ[nX][2],aFileRZ[nX][3],aFileRZ[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileRZ := STRedXML("S")
	If Len(aFileRZ) > 0
		For nX := 1 to Len(aFileRZ)
			If aFileRZ[nX][1] > 0
				aadd(aRet,{"Redução Z","Sucesso",aFileRZ[nX][4],aFileRZ[nX][2],aFileRZ[nX][3],aFileRZ[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileRZ := STRedXML("V")
	If Len(aFileRZ) > 0
		For nX := 1 to Len(aFileRZ)
			If aFileRZ[nX][1] > 0
				aadd(aRet,{"Redução Z","Aguardando",aFileRZ[nX][4],aFileRZ[nX][2],aFileRZ[nX][3],aFileRZ[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileRZ := STRedXML("N")
	If Len(aFileRZ) > 0
		For nX := 1 to Len(aFileRZ)
			If aFileRZ[nX][1] > 0
				aadd(aRet,{"Redução Z","Não Enviado",aFileRZ[nX][4],aFileRZ[nX][2],aFileRZ[nX][3],aFileRZ[nX][5]})
			EndIf
		Next nX
	EndIf
EndIf

/*Estoque*/
If Empty(cTipoArq) .Or. cTipoArq == "E"
	aFileES := STEstqXML(lMvLjPdvPa,"AE")
	If Len(aFileES) > 0
		For nX := 1 to Len(aFileES)
			If aFileES[nX][1] > 0
				aadd(aRet,{"Estoque","Erro",aFileES[nX][4],aFileES[nX][2],aFileES[nX][3],aFileES[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileES := STEstqXML(lMvLjPdvPa,"S")
	If Len(aFileES) > 0
		For nX := 1 to Len(aFileES)
			If aFileES[nX][1] > 0
				aadd(aRet,{"Estoque","Sucesso",aFileES[nX][4],aFileES[nX][2],aFileES[nX][3],aFileES[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileES := STEstqXML(lMvLjPdvPa,"V")
	If Len(aFileES) > 0
		For nX := 1 to Len(aFileES)
			If aFileES[nX][1] > 0
				aadd(aRet,{"Estoque","Aguardando",aFileES[nX][4],aFileES[nX][2],aFileES[nX][3],aFileES[nX][5]})
			EndIf
		Next nX
	EndIf
	
	aFileES := STEstqXML(lMvLjPdvPa,"N")
	If Len(aFileES) > 0
		For nX := 1 to Len(aFileES)
			If aFileES[nX][1] > 0
				aadd(aRet,{"Estoque","Não Enviado",aFileES[nX][4],aFileES[nX][2],aFileES[nX][3],aFileES[nX][5]})
			EndIf
		Next nX
	EndIf
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}LjMPXmEnv

Mostra o XML de Envio

@param		cXML, caracter, arquivo XML
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Static Function LjMPXmEnv(cXML)

Default cXML := ""

STPosMSG( "XML de Envio" , cXML, .T., .F., .F.)
Return NIL

//--------------------------------------------------------
/*/{Protheus.doc}LjMPXmRet

Mostra o XML de Retorno

@param		cXML, caracter, arquivo XML
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Static Function LjMPXmRet(cXML)

Default cXML := ""

STPosMSG( "XML de Retorno" , cXML, .T., .F., .F.)
Return NIL

//--------------------------------------------------------
/*/{Protheus.doc}LjMPRecXML

Tela para possibilitar os recursos adicionais ao XML

@param		cXML, caracter, arquivo XML
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Static Function LjMPRecXML(cXML,aListBox,oListBox)
Local oTelRecu	:= NIL
Local oBtnOut	:= NIL
Local oBtnRep	:= NIL
Local oBtnCnc	:= NIL
Local oBtnRev	:= NIL
Local oBtnCon	:= NIL
Local oBtnRec	:= NIL
Local oXML		:= NIL
Local oScr1		:= NIL
Local oFont		:= TFont():New( "Times New Roman",,15,,.F.)
Local cMsgGener := ""
Local cMsgComp1 := ""
Local aXML		:= {}
Local aBotoes	:= {}

If Empty(cXML)
	aXML := {"","","",""}
Else
	/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
	aXML := LPXLeReXML(cXML,@oXML)
	
	If !Empty(aXML[4])
		aXML[3] := aXML[4]
	EndIf
EndIf

cMsgGener := aXML[2]
cMsgComp1 := aXML[3]

DEFINE MSDIALOG oTelRecu TITLE "Recursos - XML PAF-ECF" FROM 0,0 TO 210,350 PIXEL OF GetWndDefault()
	
	oFont:Bold := .T.
	@ 10,008 SAY "Mensagem Genérica: "	PIXEL OF oTelRecu FONT oFont
	oFont:Bold := .F.
	@ 10,068 SAY cMsgGener				PIXEL OF oTelRecu FONT oFont

	oFont:Bold := .T.
	@ 23,008 SAY "Mensagem Completa: "	PIXEL OF oTelRecu FONT oFont
	
	oFont:Bold := .F.
	oScr1 := tMultiget():new(23,69,{| u | if( pCount() > 0, cMsgComp1 := u, cMsgComp1 )},oTelRecu,97,33,oFont,,,,,.T.,,,,,,.T.,,,,,.T.)
	
	oFont:Bold := .T.
    @ 62,008 SAY "Selecione a Opção Disponível para tratamento do XML" PIXEL OF oTelRecu  FONT oFont
    
    aBotoes := LJMPVerErr(AllTrim(@aXML[3]),aListBox,oListBox)
    
    @ 75,008 BUTTON oBtnRep PROMPT "&Reprocessar" SIZE 38,11 PIXEL ACTION (LJMPCncRep(.F.,cXML,@aListBox,oListBox),oTelRecu:End()) WHEN aBotoes[1]
    @ 75,048 BUTTON oBtnCnc PROMPT "&Cancelar" SIZE 38,11 PIXEL ACTION (LJMPCncRep(.T.,cXML,@aListBox,oListBox),oTelRecu:End()) WHEN aBotoes[2]
    @ 75,088 BUTTON oBtnRev PROMPT "Re&enviar" SIZE 38,11 PIXEL ACTION (LJMPReenvX(@aListBox,oListBox),oTelRecu:End()) WHEN aBotoes[3]
    
    @ 88,008 BUTTON oBtnCon PROMPT "&Pend.Contrib" SIZE 38,11 PIXEL ACTION (LJMPPenCon(),oTelRecu:End()) WHEN aBotoes[4]
    @ 88,048 BUTTON oBtnRec PROMPT "C&ons. Recibo" SIZE 38,11 PIXEL ACTION (LJMPConRec(@aListBox,oListBox),oTelRecu:End()) WHEN aBotoes[5]
    @ 88,088 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oTelRecu:End()

ACTIVATE DIALOG oTelRecu CENTERED

Return oTelRecu

//--------------------------------------------------------
/*/{Protheus.doc}LJMPVerErr

Avalia os erros do XML e libera ou não os botões

@param		cXML, caracter, arquivo XML
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Function LJMPVerErr(cErroXML,aListBox,oListBox)
Local aBotoes	:= { .F. , .F. , .F. , .F. , .F.}
Local cErro		:= Upper(LjRmvChEs(cErroXML))

If Upper("Erro 3001") $ cErro
	LJMPAltXML(cErro,aListBox,oListBox)
	
	cErroXML := aListBox[oListBox:nAT][2] //Status
	aBotoes := { .T. , .F. , .T. , .T., .T.}
	
ElseIf Upper("Sucesso") $ cErro
	//*** Somente com arquivo em Sucesso que  
	//*** pode cancelar conforme o manual
	aBotoes := { .F. , .T. , .F. , .T., .T.}
	
Else
	aBotoes := { .T. , .F. , .T. , .T., .T.}
EndIf

Return aBotoes

//--------------------------------------------------------
/*/{Protheus.doc}LJMPCncRep

Executa reprocessamento/cancelamento

@param		lCancela, lógico, Cancela (ou Reprocessa)?
@param		cXML, caracter, arquivo XML
@param		aListBox, array, lista com os itens
@param		oListBox, array, objeto com os itens da tela
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	NIL
/*/
//--------------------------------------------------------
Function LJMPCncRep(lCancela,cXML,aListBox,oListBox)
Local aXML		:= {}
Local lRet		:= .T.
Local cRet		:= ""
Local cMotivo	:= ""
Local cXMLTratR	:= ""
Local cSitu		:= "Erro"
Local cTpSitu	:= "E"
Local cTpOpe	:= IIf(lCancela,"Cancelamento","Reprocessamento")

cMotivo := AllTrim( FWInputBox("Insira o motivo do " + cTpOpe, "") ) 
If cMotivo <> "" .And. Len(cMotivo) > 14
	
	/*Usado a função XMLParser pois o TXMLManager não retorna a parte do XML que precisa ser lida*/
	aXML := LPXLeReXML(cXML,NIL)
		
	LjGrvLog( NIL, "Antes de LPXCncRepX",cMotivo)
	If Empty(aXML[1])
		MsgAlert("XML de Retorno invalido para Reprocessamento - necessita do número do Recibo")
	Else
		aXML := LPXCncRepX( lCancela , aXML[1] , cMotivo)
		LjGrvLog( NIL, "Retorno de LPXCncRepX",aXML)
		
		If "XML INVALIDO" $ Upper(LjRmvChEs(aXML[6]))
			aXML[5] := 2 //Sinaliza ERRO
		EndIf
		
		lRet := aXML[1]
		cXMLTratR := aXML[2]
		
		cRet := Upper("Método " + cTpOpe +" de Arquivo") + CHR(10) + CHR(13)
		cRet += "Situação Processamento: " + aXML[4] + CHR(10) + CHR(13)
		cRet += "Situação Operação: " + aXML[6]
		
		If aXML[5] == 0 //AGUARDANDO
			cTpSitu := "A"
			cSitu := "Aguardando"
		EndIf
		
		If aXML[5] == 1 //SUCESSO
			cTpSitu := "S"
			cSitu := "Sucesso"
		EndIf
		
		If aXML[5] == 2 .Or. aXML[5] == -1 .Or. aXML[5] == 9999 //ERRO
			cTpSitu := "E"
			cSitu := "Erro"
		EndIf
		
		If aXML[5] == 3 //CANCELADO
			cTpSitu := "X"
			cSitu := "Cancelado"
		EndIf
		
		aListBox[oListBox:nAT][2] := cSitu //Status
		aListBox[oListBox:nAT][5] := cXMLTratR //XML Retorno
		oListBox:Refresh()
		
		//*** Atualiza as tabelas (SFI ou MDZ) ***//
		If Substr(AllTrim(Upper(aListBox[oListBox:nAT][1])),1,1) == "R"
			STRedXML("R",aListBox[oListBox:nAT][6],{cTpSitu,cXMLTratR}, NIL)
		Else
			STEstqXML(lMvLjPdvPa,"R",aListBox[oListBox:nAT][6],{cTpSitu,cXMLTratR},NIL)
		EndIf
		
		MsgInfo(cRet,"PAF-ECF")
	EndIf
Else
	MsgAlert("Motivo em branco ou texto muito curto para justificativa")
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LJMPReenvX

Efetua o reenvio do XML

@param		aListBox, array, lista com os itens
@param		oListBox, array, objeto com os itens da tela
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	lEnv, lógico, enviado ?
/*/
//--------------------------------------------------------
Function LJMPReenvX(aListBox,oListBox)
Local cTipo	 := Substr(AllTrim(aListBox[oListBox:nAT,1]),1,1)
Local aRet	 := {}
Local lRet	 := .T.
Local lEnv	 := .F.
Local dData	 := CTOD("")

If cTipo == "E"
	dData := StoD(SubStr(aListBox[oListBox:nAT,6],TamSX3("MDZ_FILIAL")[1] + 1,Len(aListBox[oListBox:nAT,6])))
	//o indice retorna o ultimo dia do mes referente ao estoque
	//e na data de referencia (nome do arquivo) deve ser passado 
	//o ultimo dia mais um. 
	//Ex.: Data do XML (ultimo dia do estoque) - 29022020
	//o Nome do arquivo deve ser do mes posterior: 03 
	// portanto a data de referencia será: 29/02/2020 + 1 = 01032020 mas nome do arquivo 032020 (MMAAAA)
	aRet := LPXFiscoEstMen( .F. , STFIsPOS() , dData , .F., dData+1,/*ArrayProd*/,FwxFilial("SB1"))
Else
	DbSelectArea("SFI")
	SFI->(MsGoTo(aListBox[oListBox:nAT,3]))
	aRet := LPXFiscoRedZ(STFIsPOS(),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV),SFI->FI_DTMOVTO)
EndIf

If aRet[1][1]
	aRet := LPXAjXML(cTipo , @aRet[1][2] , IIf(cTipo=="R",SFI->FI_PDV,))
Else
	lRet := .F.
EndIf

If lRet
	aListBox[oListBox:nAT][2] := "Reproc. Env." 				//Status
	aListBox[oListBox:nAT][4] := aRet[2]						//XML Envio
	aListBox[oListBox:nAT][5] := IIf(Len(aRet)> 2,aRet[3], "")	//XML Retorno
	oListBox:Refresh()
	lEnv := .T.
Else
	MsgAlert("XML de Envio não foi gerado e/ou arquivo não foi reprocessado. Tente novamente")
EndIf

Return lEnv

//--------------------------------------------------------
/*/{Protheus.doc}LJMPPenCon

efetua a consulta do contribuinte

@param		cIndice, caracter, indice
@author  	julio.nery
@version 	P12
@since   	10/02/2020
@return  	lEnv, lógico, enviado ?
/*/
//--------------------------------------------------------
Function LJMPPenCon()
Local lRet	  := .T.
Local aRet	  := {}
Local oFont	  := TFont():New( "Times New Roman",,15,,.F.)
Local oCnsCont:= NIL
Local oScr1	  := NIL
Local cMsgComp1 := "" 

aRet := LPXCnPeCon()

lRet := aRet[1]
If lRet
	cMsgComp1 := aRet[3]
	
	DEFINE MSDIALOG oCnsCont TITLE "Consulta Contribuinte" FROM 0,0 TO 200,220 PIXEL OF GetWndDefault()
	
		oFont:Bold := .T.
		@ 10,008 SAY "Retorno da Consulta"	PIXEL OF oCnsCont FONT oFont
		
		oFont:Bold := .F.
		oScr1 := tMultiget():new(01,01,{| u | if( pCount() > 0, cMsgComp1 := u, cMsgComp1 )},oCnsCont,100,100,oFont,,,,,.T.,,,,,,.T.,,,,,.T.)		

    ACTIVATE DIALOG oCnsCont CENTERED
Else
	MsgAlert("Não há dados de contribuinte para serem mostrados")    
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LJMPConRec

efetua a consulta do Recibo em Status Aguardando

@param		aListBox, array, lista com os dados
@param		oListBox, objeto, objeto da listagem
@author  	julio.nery
@version 	P12
@since   	17/02/2020
@return  	.T.
/*/
//--------------------------------------------------------
Function LJMPConRec(aListBox,oListBox)
Local aRet := {}
Local cTpEnv:= Substr(aListBox[oListBox:nAt,1],1,1)

aRet := LPXLeReXML(aListBox[oListBox:nAt][5])

If Empty(AllTrim(aRet[1]))
	MsgInfo("Ação não permitida para esse XML - Não há numero de recibo","PAF-ECF")
Else
	aRet := LPXTrPrXML(cTpEnv,aListBox[oListBox:nAt][4],aListBox[oListBox:nAt][5],,.T.)
	If cTpEnv == "R"
		STRedXML("R",aListBox[oListBox:nAt][6],{aRet[1],aRet[2]}, NIL)
	Else
		STEstqXML(lMvLjPdvPa,"R",aListBox[oListBox:nAt][6],{aRet[1],aRet[2]},NIL)
	EndIf
	
	If Upper(aRet[1]) == "A"
		cTpEnv := "Aguardando"
	ElseIf Upper(aRet[1]) == "E"
		cTpEnv := "Erro"
	ElseIf Upper(aRet[1]) == "S"
		cTpEnv := "Sucesso"
	ElseIf aRet[1] == "N"
		cTpEnv := "Sem Recibo/N Gerado"
	Else
		cTpEnv := Upper(aRet[1])
	EndIf 
	
	aListBox[oListBox:nAT][2] := cTpEnv //Status
	aListBox[oListBox:nAT][5] := aRet[2] //XML Retorno
	oListBox:Refresh()
EndIf

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc}LJMPAltXML

Alteração de XML dependendo de alguns erros 
deve modificar os status

@param		cErro, caracter, erro do xml
@param		aListBox, array, lista com os dados
@param		oListBox, objeto, objeto da listagem
@author  	julio.nery
@version 	P12
@since   	17/02/2020
@return  	.T.
/*/
//--------------------------------------------------------
Function LJMPAltXML(cErro,aListBox,oListBox)
Local aRet := {}
	
If ExistFunc("LPXReWriXM")
	aRet := LPXReWriXM(cErro)
	
	If !Empty(aRet[1])
	
		If Substr(aListBox[oListBox:nAt,1],1,1) == "R"
			STRedXML("R",aListBox[oListBox:nAt][6],{SubStr(aRet[1],1,1),aRet[3]}, NIL)
		Else
			STEstqXML(lMvLjPdvPa,"R",aListBox[oListBox:nAt][6],{SubStr(aRet[1],1,1),aRet[3]},NIL)
		EndIf
		
		aListBox[oListBox:nAT][2] := aRet[1] //Status
		aListBox[oListBox:nAT][5] := aRet[3] //XML Retorno
		oListBox:Refresh()
	EndIf
EndIf
	
Return NIL