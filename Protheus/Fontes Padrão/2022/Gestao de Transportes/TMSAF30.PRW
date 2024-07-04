#include "Protheus.ch"
#include "TMSAF30.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF30  ³ Autor ³ Richard Anderson      ³ Data ³ 11.01.07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DSCDES‡„o ³ Despesa x Serviços de Manutenção                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSAF30()

Private cCadastro := STR0001                             //--- Despesa x Serviços de Manutenção
Private aRotina	  := { { STR0002, "AxPesqui" , 0, 1 }, ; //--- Pesquisar
				       { STR0003, "TMAF30Mnt", 0, 2 }, ; //--- Visualizar
 				       { STR0004, "TMAF30Mnt", 0, 3 }, ; //--- Incluir
				       { STR0005, "TMAF30Mnt", 0, 4 }, ; //--- Alterar
				       { STR0006, "TMAF30Mnt", 0, 5 }  } //--- Excluir

dbSelectArea( "DFD" )
dbSetOrder( 1 )
dbGoTop()

mBrowse( 06, 01, 22, 75, "DFD" )

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF30Mnt ³ Autor ³ Richard Anderson     ³ Data ³ 11.01.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface do Cadastro de Regiões para Análise de Custos     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias da tabela                                      ³±±
±±³          ³ ExpN2: Numero do Registro                                   ³±±
±±³          ³ ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF30Mnt( cAlias, nReg, nOpcx )

Local nUsado    := 0
Local nOpcA     := 0
Local aAreaDFD  := DFD->( GetArea() )

Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}
Local aRecno    := {}
Local oSize		:= FwDefSize():New( .T. )
Local nCntFor   := 0
Local aNoFields := {}
Local oDlg

Private aHeader := {}
Private aCols   := {} 
Private cCodDes := IIf( !Inclui, DFD->DFD_CODDES, CriaVar( "DFD_CODDES" ) )
Private cDscDes := CriaVar( "DFD_DSCDES" )
Private oDscDes := {}
Private oGetD   := {}

Aadd( aNoFields, "DFD_CODDES" )
Aadd( aNoFields, "DFD_DSCDES" )

aadd( aGet,{ GetSx3Cache("DFD_CODDES", "X3_TITULO"), GetSx3Cache("DFD_CODDES", "X3_PICTURE") , GetSx3Cache("DFD_CODDES", "X3_F3") } )
aadd( aGet,{ GetSx3Cache("DFD_DSCDES", "X3_TITULO"), GetSx3Cache("DFD_DSCDES", "X3_PICTURE") , GetSx3Cache("DFD_DSCDES", "X3_F3") } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aHeader.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= APBuildHeader("DFD", aNoFields)
nUsado := Len(aHeader)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aCols.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Inclui

	DFD->( dbSetOrder( 1 ) )
	DFD->( dbSeek( xFilial( "DFD" ) + cCodDes ) )

	While DFD->( !Eof() ) .And. DFD->( DFD_FILIAL + DFD_CODDES ) == xFilial( "DFD" ) + cCodDes

		Aadd( aCols, Array( nUsado + 1 ) )

		For nCntFor := 1 To nUsado

			If ( aHeader[ nCntFor ][ 10 ] != "V" )

				aCols[ Len( aCols ) ][ nCntFor ] := DFD->( FieldGet( FieldPos( aHeader[ nCntFor ][ 2 ] ) ) )

			Else

				aCols[ Len( aCols ) ][ nCntFor ] := CriaVar( aHeader[ nCntFor, 2 ] )

			EndIf

		Next

		aCols[ Len( aCols ) ][ nUsado + 1 ] := .F.

		DFD->( dbSkip() )

	Enddo

Else

	If Empty( aCols )

		Aadd( aCols, Array( nUsado + 1 ) )

		For nCntFor := 1 To nUsado

			aCols[ 1 ][ nCntFor ] := CriaVar( aHeader[ nCntFor ][ 2 ] )

		Next nCntFor

		aCols[ Len( aCols ) ][ nUsado + 1 ] := .F.

	EndIf

EndIf

If Empty( GDFieldGet( 'DFD_ITEM', 1 ) )

	GDFieldPut( 'DFD_ITEM', StrZero( 1, Len( DFD->DFD_ITEM ) ), 1 )

EndIf

oSize:lLateral     := .F.  // Calculo vertical

// adiciona Enchoice
oSize:AddObject( "ENCHOICE", 100, 10, .T., .T. ) // Adiciona enchoice

// adiciona grid
oSize:AddObject( "GRID",100, 200, .T., .T. ) // Adiciona Grid

// Dispara o calculo
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro From	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
											oSize:aWindSize[3],oSize:aWindSize[4] Of oMainWnd PIXEL
	
	@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY   aGet[ 1 ][ 1 ] SIZE 50,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 40 MSGET cCodDes ;
														PICTURE aGet[ 1 ][ 2 ] F3 "DT7"  VALID TMAF30Vld() WHEN Inclui SIZE 000,007 OF oDlg PIXEL
	
	@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 135 MSGET oDscDes ;
														VAR cDscDes PICTURE "@!" WHEN .F.    SIZE 120,007 OF oDlg PIXEL
	
	oGetD := MsGetDados():New( oSize:GetDimension("ENCHOICE","LININI") + 30 , oSize:GetDimension("GRID","COLINI"), oSize:GetDimension("GRID","LINEND" ), oSize:GetDimension("GRID","COLEND"), nOpcx, "TMAF30LOk()", "TMAF30TOk()", "+DFD_ITEM", .T.,,,, 999 )
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpcA := 1, If( TMAF30LOk() .And. oGetd:TudoOk(), oDlg:End(), nOpcA := 0 ) }, { || oDlg:End() } )

If nOpcA == 1 .And. nOpcx <> 2

	Begin Transaction

		TMAF30Grv( nOpcx )

	End Transaction

EndIf

RestArea( aAreaDFD )
	
Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF30LOk ³ Autor ³ Richard Anderson     ³ Data ³11/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF30LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.

If	!GDDeleted( n )

   If lRet := MaCheckCols( aHeader, aCols, n )

	   //-- Analisa se ha itens duplicados na GetDados.

	   lRet := GDCheckKey( { 'DFD_SERMNT', 'DFD_CODPRO', 'DFD_VLSATE' }, 4 )

	EndIf   

EndIf

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF30TOk ³ Autor ³ Richard Anderson     ³ Data ³11/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF30TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet

	lRet := oGetD:ChkObrigat( n )

EndIf

//-- Analisa o linha ok.

If lRet

	lRet := TMAF30LOk()

EndIf

//-- Analisa se todas os itens da GetDados estao deletados.

If lRet .And. Ascan( aCols, { | x | x[ Len( x ) ] == .F. } ) == 0

	Help( ' ', 1, 'OBRIGAT2' ) // Um ou alguns campos obrigatorios nao foram preenchidos no Browse.

	lRet := .F.

EndIf

If lRet .And. Empty( cCodDes )

	Help( '', 1, 'OBRIGAT',, PadR( "Campo: Cod.Despesa", 40 ), 03, 00 )

	lRet := .F.

EndIf

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF30Vld ³ Autor ³ Richard Anderson     ³ Data ³19.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de campos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EAL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF30Vld(cCampo)

Local   lRet   := .T.
Default cCampo := AllTrim( Upper( ReadVar() ) )

If "CCODDES" $ cCampo

	lRet := ExistChav( "ST4", cCodDes )

	If lRet

		cDscDes:= Posicione( "DT7", 1, xFilial( "DT7" ) + cCodDes, "DT7_DESCRI" )

		oDscDes:Refresh()

	EndIf		

ElseIf "DFD_SERMNT" $ cCampo

	lRet := ExistCpo( "ST4", M->DFD_SERMNT, 1 )

	If lRet

		GdFieldPut( "DFD_NOSMNT", Posicione( "ST4", 1, xFilial( "ST4" ) + M->DFD_SERMNT, "T4_NOME" ) )

	EndIf

ElseIf "DFD_CODPRO" $ cCampo

	lRet := ExistCpo( 'SB1', M->DFD_CODPRO, 1 )

	If lRet

		GDFieldPut( 'DFD_DESPRO', Posicione( 'SB1', 1, xFilial( 'SB1' ) + M->DFD_CODPRO, 'B1_DESC' ) )

	EndIf

EndIf
			
Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF30Grv ³ Autor ³ Richard Anderson     ³ Data ³11/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Gravacao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF30Grv( nOpcx )

Local nI     := 0
Local nCnt   := 0
Local nUsado := Len( aHeader )

DFD->( dbSetOrder( 1 ) )

If nOpcx == 3 .Or. nOpcx == 4

	For nCnt := 1 To Len( aCols )

		If !GdDeleted( nCnt )

			If DFD->( !MsSeek( xFilial( "DFD" ) + cCodDes+GdFieldGet( "DFD_ITEM", nCnt ) ) )

				RecLock( "DFD", .T. )

				DFD->DFD_FILIAL := xFilial( "DFD" )
				DFD->DFD_CODDES := cCodDes
				DFD->DFD_ITEM   := GdFieldGet( "DFD_ITEM", nCnt )

			Else

				RecLock( "DFD", .F. )

			EndIf

			For nI := 1 To nUsado

				If aHeader[ nI, 10 ] != 'V'

					DFD->( FieldPut( FieldPos( aHeader[ nI, 02 ] ), GDFieldGet( aHeader[ nI, 02 ], nCnt ) ) )

				EndIf

			Next

			MsUnlock()

		ElseIf DFD->( MsSeek( xFilial( "DFD" ) + cCodDes + GdFieldGet( "DFD_ITEM", nCnt ) ) )

			RecLock( "DFD", .F. )
			dbDelete()
			MsUnLock()

		EndIf

	Next nCnt

ElseIf nOpcx == 5

	For nCnt := 1 To Len( aCols )

		If DFD->( MsSeek( xFilial( "DFD" ) + cCodDes + GdFieldGet( "DFD_ITEM", nCnt ) ) )

			RecLock( "DFD", .F. )
			dbDelete()
			MsUnLock()

		EndIf

	Next nCnt					

EndIf	

Return
