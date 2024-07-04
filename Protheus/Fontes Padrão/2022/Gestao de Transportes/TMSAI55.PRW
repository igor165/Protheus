#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSAI55.ch"

#DEFINE CRLF ( chr(13)+chr(10) )

//===========================================================================================================
/* Configuração Impressão CRT
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSAI55()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DIG" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return()

//===========================================================================================================
/* ModelDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruDIG 	:= Nil
Local bCommit   := {|oModel| CommitMdl(oModel) }

oStruDIG := FwFormStruct( 1, "DIG" ) 

oModel := MPFormModel():New ( "TMSAI55",/*bPreValid*/, /*bPosValid*/, bCommit, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDIG',	, oStruDIG, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDIG' )
oModel:SetPrimaryKey( { "DIG_FILIAL","DIG_CDPDES", "DIG_CLIREM", "DIG_LOJREM" } ) 

Return( oModel )

//===========================================================================================================
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruDIG 	:= Nil

oModel   := FwLoadModel( "TMSAI55" )
oStruDIG := FwFormStruct( 2, "DIG" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDIG', oStruDIG , 'MdFieldDIG' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDIG' , 'TOPO' )

Return( oView )

//===========================================================================================================
/* MenuDef.
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { "Pesquisar"	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { "Visualizar"	, "VIEWDEF.TMSAI55"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { "Incluir"		, "VIEWDEF.TMSAI55"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { "Alterar"		, "VIEWDEF.TMSAI55"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { "Excluir"		, "VIEWDEF.TMSAI55"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)

//===========================================================================================================
/* CommitMdl 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function CommitMdl(oModel)

 Local   lRet      := .T.

 Default oModel    := FwModelActive()

	lRet := FWFormCommit(oModel)
	
    If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If Alltrim(M->DIG_CDPDES) == "105"
			RecLock('DIB',.T.)
			DIB->DIB_FILIAL := xFilial('DIB')
			DIB->DIB_DATALT := dDataBase
			DIB->DIB_HORALT := StrTran(Left(Time(),5),':','')
			DIB->DIB_USER   := __CUSERID
			DIB->DIB_CPODOC := 'CL'
			DIB->DIB_FILDOC := cFilAnt
			DIB->DIB_FILORI := cFilAnt
			MSMM(DIB->DIB_CODINF,,,"***** CLAUSULAS PORTUGUES ***** " + CRLF + M->DIG_CLAUPT + CRLF + CRLF + "***** CLAUSULAS ESPANHOL ***** " + CRLF + M->DIG_CLAUES ,1,,,"DIB","DIB_CODINF")
			MsUnlock()		
		EndIf
	EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI55Vld³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI55Vld(cCampo) 

Local   lRet	  := .T.
Default cCampo   := ReadVar()

If cCampo == 'M->DIG_CDPDES'	
	lRet := ExistCpo('SYA',M->DIG_CDPDES,1)	
	If lRet
		If !Empty(M->DIG_CLIREM) .And. !Empty(M->DIG_LOJREM)
			lRet := ExistChav('DIG',M->DIG_CDPDES+M->DIG_CLIREM+M->DIG_LOJREM)
		EndIf
		If lRet
			M->DIG_PAISES := Posicione('SYA',1,xFilial('SYA')+M->DIG_CDPDES,'YA_DESCR')
		EndIf			
	EndIf
ElseIf cCampo == 'M->DIG_CLIREM' .Or. cCampo == 'M->DIG_LOJREM'
	If cCampo == 'M->DIG_CLIREM' .And. Empty(M->DIG_CLIREM)
		M->DIG_LOJREM := CriaVar('DIG_LOJREM',.F.)
	ElseIf cCampo == 'M->DIG_LOJREM' .And. Empty(M->DIG_LOJREM)
		M->DIG_CLIREM := CriaVar('DIG_CLIREM',.F.)
	ElseIf !Empty(M->DIG_CLIREM)
		lRet := ExistCpo('SA1',M->DIG_CLIREM+AllTrim(M->DIG_LOJREM))
	EndIf
	If lRet 
		If !Empty(M->DIG_CDPDES)
			lRet := ExistChav('DIG',M->DIG_CDPDES+M->DIG_CLIREM+M->DIG_LOJREM)
		EndIf
		If lRet			
			M->DIG_NOMREM := Posicione('SA1',1,xFilial('SA1')+M->DIG_CLIREM+M->DIG_LOJREM,'A1_NOME')
		EndIf			
	EndIf		
EndIf			
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI55Whe³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita a digitacao do campo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI55Whe(cCampo) 

Local   lRet	:= .T.
Default cCampo := ReadVar()

Return(lRet)
