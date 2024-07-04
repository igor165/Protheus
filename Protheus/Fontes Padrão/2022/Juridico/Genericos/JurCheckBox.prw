#INCLUDE "PROTHEUS.CH"

#DEFINE CSSTCHECK "QCheckBox { background-repeat: repeat-x } "+;
"QCheckBox { background-repeat: repeat-y } "+;
"QCheckBox { padding-top: 0px }"+;
"QCheckBox { max-height: 14px }"+; // Limitação de altura do check
"QCheckBox { min-height: 14px }"+; // Limitação de altura do check
"QCheckBox { color: #000000 } "+;  // cor da fonte normal
"QCheckBox { background-image: url(rpo:fwskin_chk_nml.png)}"+; // Imagem de fundo normal
"QCheckBox:hover { background-image: url(rpo:fwskin_chk_nml.png) } "+; // Imagem de fundo no hover
"QCheckBox::indicator::checked {image: url(rpo:fwskin_chk_ckd.png);} "+; // Imagem quando estiver checado
"QCheckBox::indicator::unchecked {image: url(rpo:fwskin_rdo_uck.png);} "+; // Imagem quando não estiver checado
"QWidget { border-width: 0px }"


//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function __JurCheckBox() // Function Dummy
ApMsgInfo( 'JurCheckBox -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurCheckBox FROM TCHECKBOX

 DATA lCheckJur

 METHOD New (nRow, nCol, cCaption, bSetGet, oDlg, ;
  					  nWidth, nHeight, uParam8, bChange, ;
  					  oFont, bValid, nClrText, nClrPane, uParam14, ;
  					  lPixel, cMsg, uParam17, bWhen) CONSTRUCTOR

METHOD Checked()
METHOD SetCheck(lCheck)
	
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (nRow, nCol, cCaption, bSetGet, oDlg, ;
  					  nWidth, nHeight, uParam8, bChange, ;
  					  oFont, bValid, nClrText, nClrPane, uParam14, ;
  					  lPixel, cMsg, uParam17, bWhen) CLASS TJurCheckBox
        :New (nRow, nCol, cCaption, bSetGet, oDlg, nWidth, nHeight, uParam8, bChange, oFont, bValid, nClrText, nClrPane, uParam14, lPixel, cMsg, uParam17, bWhen)

	Self:lCheckJur := .T.
	Self:bSetGet := {|u|if( pcount()>0,::lCheckJur := u, ::lCheckJur)}
	Self:SetCss( CSSTCHECK )

	If !Empty(bChange) .And. ValType(bChange) == "B"
		Self:bLClicked := bChange
		Self:bChange := {|| }
	EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Checked()
Classe para retornar o a variavel lCheckJur

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Checked() CLASS TJurCheckBox
Return Self:lCheckJur


//-------------------------------------------------------------------
/*/{Protheus.doc} Checked()
Classe para setar a variavel lCheckJur

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetCheck(lCheck) CLASS TJurCheckBox

If ValType(lCheck) == "L"
	Self:lCheckJur := lCheck
EndIf

Return Self:lCheckJur
