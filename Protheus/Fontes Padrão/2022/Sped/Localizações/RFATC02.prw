// #########################################################################################
// Projeto: Saceem
// Modulo : SIGAFAT
// Fonte  : RFATC02
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 11/05/14 | Rafael Yera Barchi| Consulta de status de documento fiscal via webservice.  
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RFATC02
Consulta de status de documento fiscal via webservice.

@author    Rafael Yera Barchi
@version   1.00
@since     11/05/2014

/*/
//------------------------------------------------------------------------------------------
User Function RFATC02()
	
	Local oDlg 
	Local oOK 	:= LoadBitmap(GetResources(), "BR_VERDE")
	Local oNO 	:= LoadBitmap(GetResources(), "BR_VERMELHO")
	Local aCab	:= {"", "Codigo", "Motivo", "Descripcion"}
	Local aTam	:= {20, 30, 50, 80}
	Local aSize	:= MSAdvSize()
	
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] PIXEL TITLE "Consulta"
		
		oBrowse := TWBrowse():New(0, 0, 260, 0, , aCab, aTam, oDlg, ,,,, {||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
		aBrowse := { U_RFATC01("", 0, "", 0, 2) }
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := {|| 	{If(aBrowse[oBrowse:nAt,01],oNO,oOK),;
								aBrowse[oBrowse:nAt,02],;
								aBrowse[oBrowse:nAt,03],;
								aBrowse[oBrowse:nAt,04] } }
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()}, , {})
	
Return Nil