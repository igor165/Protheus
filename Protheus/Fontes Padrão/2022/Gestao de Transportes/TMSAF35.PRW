#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#include "TMSAF35.ch"

//===========================================================================================================
/* Amortizacao de Despesas 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSAF35()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DFE" )
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
Local oStruDFE 	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }

oStruDFE := FwFormStruct( 1, "DFE" ) 

oModel := MPFormModel():New ( "TMSAF35",/*bPreValid*/, bPosValid,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDFE',	, oStruDFE, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDFE' )
oModel:SetPrimaryKey( { "DFE_FILIAL","DFE_NUMAMZ" } )

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
Local oStruDFE 	:= Nil

oModel   := FwLoadModel( "TMSAF35" )
oStruDFE := FwFormStruct( 2, "DFE" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddUserButton( STR0003, 'PRECO', {|oView| TMAF35View()} )		

oView:AddField( 'VwFieldDFE', oStruDFE , 'MdFieldDFE' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDFE' , 'TOPO' )

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

aAdd( aRotina, { STR0006	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0007	, "VIEWDEF.TMSAF35"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0008	, "VIEWDEF.TMSAF35"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0009	, "VIEWDEF.TMSAF35"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0010	, "VIEWDEF.TMSAF35"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)

//===========================================================================================================
/* PosVldMdl 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function PosVldMdl(oModel)

Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDFF	:= DFF->( GetArea() )

Default oModel	:= FWModelActive()

If oModel <> Nil 
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		DFF->( dbSetOrder( 1 ) )

		If DFF->( dbSeek( xFilial( 'DFF' ) + M->DFE_NUMAMZ ) )

			Help( '', 1, 'TMSAF3503' )  //'Existem movimentos para essa amortização!'

			lRet := .F.

		EndIf
	EndIf
EndIf			

RestArea( aAreaDFF )


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF35Vld³ Autor ³ Richard Anderson      ³ Data ³14/01/2007 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄ0ÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida após edição do campo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMAF35Vld( cCampo ) 

Local   lRet	 := .T.
Local   aAreaDFD := DFD->( GetArea() )
Default cCampo   := ReadVar()

If cCampo == "M->DFE_CODDES"

	lRet := ExistCpo( "DT7", M->DFE_CODDES, 1 ) 

	If lRet .And. !Empty( M->DFE_SERMNT )

		lRet := ExistCpo( "DFD", M->DFE_SERMNT + M->DFE_CODDES, 2 )

	EndIf

	If lRet

		M->DFE_DSCDES := Posicione( "DT7", 1, xFilial( "DT7" ) + M->DFE_CODDES, "DT7_DESCRI" )

	EndIf
	
ElseIf cCampo == "M->DFE_SERMNT"

	lRet := ExistCpo( "ST4", M->DFE_SERMNT, 1 )

	If lRet 

		M->DFE_NOSMNT := Posicione( "ST4", 1, xFilial( "ST4" ) + M->DFE_SERMNT, "T4_NOME" )

		If !Empty( M->DFE_CODDES )

			DFD->( dbSetOrder( 2 ) )

			If DFD->( dbSeek( xFilial( 'DFD' ) + M->DFE_SERMNT + M->DFE_CODDES ) )

				M->DFE_CODPRO := DFD->DFD_CODPRO
				M->DFE_DESPRO := Posicione( "SB1", 1, xFilial( "SB1" ) + M->DFE_CODPRO, "B1_DESC" )
				M->DFE_TIPAMZ := DFD->DFD_TIPAMZ
				M->DFE_PERAMZ := DFD->DFD_PERAMZ

			EndIf

		Else

			M->DFE_CODPRO := CriaVar( 'DFE_CODPRO' )
			M->DFE_DESPRO := CriaVar( 'DFE_DESPRO' )
			M->DFE_TIPAMZ := CriaVar( 'DFE_TIPAMZ' )
			M->DFE_PERAMZ := CriaVar( 'DFE_PERAMZ' )

		EndIf

	EndIf					
	
ElseIf cCampo == "M->DFE_TIPAMZ"

	If M->DFE_TIPAMZ == '0'

		M->DFE_PERAMZ := 0
		M->DFE_VLRQTA := 0

	EndIf

ElseIf cCampo == "M->DFE_PERAMZ"

	If !Empty( M->DFE_PERAMZ )

		If !Empty( M->DFE_VLRDES )

			M->DFE_VLRQTA := ( M->DFE_VLRDES / M->DFE_PERAMZ )

		EndIf

	Else

		M->DFE_VLRQTA := 0

	EndIf
		
ElseIf cCampo == "M->DFE_VLRDES"

	If !Empty( M->DFE_VLRDES )

		lRet := M->DFE_VLRDES >= M->DFE_VLRAMZ

		If lRet .And. M->DFE_PERAMZ > 0

			M->DFE_VLRQTA := ( M->DFE_VLRDES / M->DFE_PERAMZ )

		EndIf

	Else

		M->DFE_VLRQTA := 0

	EndIf

ElseIf cCampo == "M->DFE_VLRAMZ"

	If !Empty( M->DFE_VLRDES )

		lRet := M->DFE_VLRDES >= M->DFE_VLRAMZ

	EndIf

ElseIf cCampo == "M->DFE_CODVEI"

	DA3->( dbSetOrder( 1 ) )

	If DA3->( !dbSeek( xFilial( 'DA3' ) + M->DFE_CODVEI ) )

		Help( '', 1, 'REGNOIS' )

		lRet := .F.

	EndIf

	If lRet .And. DA3->DA3_FROVEI != '1' //-- Frota Propria

		Help("", 1, "TMSAF3504") //'Veículo não pertence a frota!'

		lRet := .F.

	EndIf

	If lRet		

		M->DFE_MODVEI := DA3->DA3_DESC

	EndIf

EndIf

RestArea( aAreaDFD )
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF35Whe³ Autor ³ Richard Anderson      ³ Data ³14/01/2007 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄ0ÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMAF35Whe( cCampo ) 

Local   lRet   := .T.
Default cCampo := ReadVar()

If "DFE_PERAMZ" $ cCampo

	lRet := M->DFE_TIPAMZ != '0'

EndIf	

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMAF35View³ Autob ³ itor Raspa           ³ Data ³ 29.Jan.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄDÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±³Descri‡„o ³ Visualiza os Movimentos de amortizacao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßŸ
*/

Function TMAF35View()

Local aArea   := GetArea()
Local oDlg    := NIL
Local oLstBox := NIL
Local aDados  := {}
Local cNumAmz := CriaVar( 'DFE_NUMAMZ' )

If Inclui .Or. Altera

	cNumAmz := M->DFE_NUMAMZ

Else

	cNumAmz := DFE->DFE_NUMAMZ

EndIf

//-- Selecao dos registros

DFF->( DbSetOrder( 1 ) )

If DFF->( MsSeek(xFilial( 'DFF' ) + cNumAmz ) )

	While !DFF->( EoF() ) .And. DFF->( DFF_FILIAL + DFF_NUMAMZ ) == xFilial( 'DFF' ) + cNUmAmz

		AAdd( aDados, {	        DFF->DFF_DATMOV                                    , ;
						Transf( DFF->DFF_QTDQTA, PesqPict( 'DFF', 'DFF_QTDQTA' ) ) , ;
						Transf( DFF->DFF_VLRAMZ, PesqPict( 'DFF', 'DFF_VLRAMZ' ) ) } )

		DFF->( DbSkip() )

	EndDo

	DEFINE MSDIALOG oDlg FROM 094,104 TO 380,655 TITLE STR0002 Of oMainWnd PIXEL //'Movimentos'

	@ 020,010 SAY   RetTitle('DFF_NUMAMZ')          OF oDlg PIXEL
	@ 018,050 MSGET cNumAmz                When .F. OF oDlg PIXEL

	@ 040,002 LISTBOX oLstBox FIELDS HEADER	RetTitle('DFF_DATMOV'), RetTitle('DFF_QTDQTA'), RetTitle('DFF_VLRAMZ') ;
									        	 	OF oDlg SIZE 272,100 PIXEL

	oLstBox:SetArray( aDados )
	oLstBox:bLine := { || {	aDados[ oLstBox:nAT, 1 ] , ;
							aDados[ oLstBox:nAT, 2 ] , ;
							aDados[ oLstBox:nAT, 3 ] } }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || oDlg:End() } , ;
													  { || oDlg:End() } ) CENTERED

Else

	Help( '', 1, 'TMSAF3502' ) //-- 'Nao existem movimentos lançados!'

EndIf

RestArea( aArea )

Return
