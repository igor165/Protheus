#include 'PROTHEUS.CH'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA940.CH"

Function CTBS480()

If ReqMinimos()
	//verifico se existe o parametro criado na base
	if FWSX6Util():ExistsParam( "MV_ULTVECD" ) 
    	PutMv("MV_ULTVECD",DTOS(date()))
	endIf
	FWCallApp("ctbs480")
EndIf



Return 

Static Function ReqMinimos()
Local oBtnLink 
Local cMsg	:= ""
Local lRet := .T.

//Release
If  GetRPORelease() < "12.1.033"
    cMsg += '<b>' + STR0001 + ' </b><br>' 	// "RPO está desatualizado"
    cMsg += ' ' + STR0002 + ' ' + GetRPORelease() + ' - ' + STR0003 + '12.1.033 <br><br>' 	//"Versão atual: " | "Versão mínima: "   
EndIf

If !Empty(cMsg)

	DEFINE DIALOG oDlg TITLE STR0008 FROM 180,180 TO 500,750 PIXEL // "Ambiente Desatualizado"
	// Cria fonte para ser usada no TSay
	oFont := TFont():New('Courier new',,-15,.T.)
   
	lHtml := .T.
	oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

	oBtnLink := TButton():New( 145, 5, STR0009, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Acesse o Portal do Cliente"
	oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
	oBtnLink:bLClicked := {|| ShellExecute("open", "https://suporte.totvs.com/portal/p/10098/download#000006/","","",3) }
	
	ACTIVATE DIALOG oDlg CENTERED

    lRet := .F.

EndIf

Return(.T.)
