#INCLUDE 	"PROTHEUS.CH" 
#INCLUDE	"FINA271X.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FAExcCVF     ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao a visao gerencial.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271x                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FAExcCVF(cCodigo)
	ProcRegua(4)
	
	IncProc()
	IncProc( STR0001 ) //"Apagando Detalhes"
	
	DbSelectArea("FJ3")
	DbSetOrder(1)
	FJ3->(DbSeek(xFilial()+cCodigo))
	While ! FJ3->(Eof()) .AND. xFilial('FJ3')==FJ3->FJ3_FILIAL	.And. FJ3->FJ3_CODPLA == cCodigo
		RecLock('FJ3',.F.)
		DbDelete()
		MsUnLock()
	    DbSkip()
	Enddo           
	
	IncProc( STR0002 ) //"Apagando Estrutura"
	
	DbSelectArea("FJ2")
	DbSetOrder(1)
	FJ2->(DbSeek(xFilial()+cCodigo))
	While !FJ2->(Eof()) .And. xFilial('FJ2')==FJ2->FJ2_FILIAL	.And.FJ2->FJ2_CODIGO == cCodigo
		RecLock('FJ2',.F.)
		DbDelete()
		MsUnLock()
	
		DbSkip()
	EndDo
	
	IncProc()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fVldFormula  ³ Autor ³ Totvs			    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ valida formula                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldFormula()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C271VldFormula(cExpr)
	Local lReturn	:= .F.
	Local oError	:= ErrorBlock( {|e| C271ErrFormula( e ) } )
	
	If !Empty( cExpr )
		Begin Sequence

		&( AllTrim( cExpr ) )
		Return .T.

		End Sequence
	Else
		lReturn := .T.
	EndIf
	
	ErrorBlock( oError )
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fErrFormula  ³ Autor ³ Totvs			    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ trata erro de formula                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fErrFormula()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C271ErrFormula(e)
	Local cMessage := e:Description

	MsgAlert( cMessage, STR0003 ) //"Erro"
	Break
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FinaCheck   		³ Autor ³ Totvs				    ³ Data ³ 01/12/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  FinaCheck ()	  				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinaCheck()
Local aArea		:= GetArea()
Local aAreaFJ1	:= FJ1->( GetArea() )
Local aAreaFJ2	:= FJ2->( GetArea() )
Local aAreaFJ3	:= FJ3->( GetArea() )
Local nOpca		:= 1

If (FJ3->(DbSeek(xFilial())) .And. !FJ1->(DbSeek(xFilial())) )
	nOpca := FIN271CTS() 
EndIf

RestArea( aArea )
RestArea( aAreaFJ1 )
RestArea( aAreaFJ2 )
RestArea( aAreaFJ3 )

Return nOpca == 1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FIN271CTS  ºAutor  ³Microsiga           º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa os campos logicos da tabeka FJ2                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FIN271CTS()
Local aSays		:=	{}
Local aButtons	:=	{}                 
Local nOpca	:=	0

AADD (aSays, STR0004 ) //"Foram detectadas Visoes Gerencias nao convertidas."
AADD (aSays, STR0005 ) //"Para dar manutencao estas deverao ser convertidas para o novo formato."
AADD (aSays, STR0006 ) //"Este programa tem como objetivo importar as estruturas das Visoes gerenciais para o  "
AADD (aSays, STR0007 ) //"novo formato."
AADD (aSays, STR0008 ) //"O novo formato visa facilitar a construcao e manutencao das Visoes, mantendo as mesmas"
AADD (aSays, STR0009 )  //"funcionalidades da versao anterior."
AADD (aSays, "")

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( STR0010 , aSays, aButtons) //"ConversÃOo de VisÕes"

If  nOpca==1 
	DbSelectArea("FJ3")
	DbSetOrder(2)
	DbSeek(xFilial())
	cChave1	:=	""
	cChave2	:=	""
	While !EOF()  .And. xFilial() == FJ3_FILIAL
		If cChave1 <> FJ3->FJ3_CODPLA
			RecLock('FJ1',.T.)
			Replace FJ1_FILIAL With xFilial()
			Replace FJ1_CODIGO With FJ3->FJ3_CODPLA
			Replace FJ1_DESCRI With FJ3->FJ3_NOME
			MsUnlock()
			cChave1	:=	FJ3->FJ3_CODPLA
		Endif	
		If cChave2 <> FJ3->(FJ3_CODPLA+FJ3_CONTAG)
			RecLock('FJ2',.T.)
			Replace FJ2_FILIAL With xFilial()
			Replace FJ2_CODIGO With FJ3->FJ3_CODPLA
			Replace FJ2_CONTAG With FJ3->FJ3_CONTAG
			Replace FJ2_DESCCG With FJ3->FJ3_DESCCG
			Replace FJ2_ORDEM 	With FJ3->FJ3_ORDEM	
			Replace FJ2_CTASUP	With FJ3->FJ3_CTASUP
			Replace FJ2_CLASSE	With FJ3->FJ3_CLASSE
			Replace FJ2_NORMAL	With FJ3->FJ3_NORMAL	
			Replace FJ2_DESCCG	With FJ3->FJ3_DESCCG
			Replace FJ2_COLUNA	With Alltrim(STR(FJ3->FJ3_COLUNA))
			Replace FJ2_IDENT	WITH FJ3->FJ3_IDENT
			MsUnlock()
			cChave2	:=	FJ3->(FJ3_CODPLA+FJ3_CONTAG)
		Endif		
		FJ3->(DbSkip())
		DbSelectArea("FJ3")
	Enddo		
Endif

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cni271Del    ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271x                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA271Del( cAlias, nReg, nOpc, lArvore )
Local nOpcA		:= 0
Local nAviso 	:= 0 
Local aParam	:=	{ {|| Nil}, {|| Aviso(STR0016, STR0029,{STR0018,STR0019}) == 1 },{|| Processa({||FAExcCVF(FJ3->FJ3_CODPLA)})},{|| Nil}} //"Atencao"###"Confirma a exclusão de todos o itens da visão? Esta ação não poderá ser revertida!"###"Sim"###"Nao"
Local cChave	:= FJ3->( FJ3_CODPLA + FJ3_ORDEM )
Local cCodigo	:= FJ3->FJ3_CODPLA
Local aCpos		:= {}
Local cContag	:= FJ3->FJ3_CONTAG
Local aAreaFJ3	:= {}
Local lRet		:= .T.

Default lArvore:= .F.

If !FinaCheck()
	Return .F.
Endif

Fa271Pos()

If lRet
	Begin Transaction
	
	If lArvore
		AxDeleta( "FJ1", FJ1->( Recno() ), nOpc, /*cTransact*/,/*aCpos*/,/*aButtons*/, aParam, /*aAuto*/,/*lMaximized*/ )
	Else
	
		aCpos:= Ctb160aCpo("FJ3",.F.,"")   
		nOpcA := AxDeleta( "FJ3", FJ3->( Recno() ), nOpc, , aCpos )
		If nOpcA == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se nao houver CTS exclui todos os registros das tabelas³
			//³CVF e CVE correspondentes.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "FJ3" )
			FJ3->( DbSetOrder( 1 ) )
			If FJ3->( !DbSeek( xFilial( "FJ3" ) + cCodigo ) )
				Processa( { || FAExcCVF( cCodigo ) } )   
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³exclui o CVF correspondente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( "FJ1" )
				FJ1->( DbSetOrder( 1 ) )
				If FJ1->( DbSeek( xFilial( "FJ1" ) + cCodigo ) )
					RecLock( "FJ1" )
					FJ1->( DbDelete() )
					MsUnLock()
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³exclui o CVF correspondente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( "FJ2" )
				FJ2->( DbSetOrder( 4 ) )
				If FJ2->( DbSeek( xFilial( "FJ2" ) + cChave ) )
					RecLock( "FJ2" )
					FJ2->( DbDelete() )
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
	
	End Transaction
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³FA271Sup  ³ Autor ³ Totvs			        ³ Data ³ 21.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271Sup()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := FJ2->(GetArea())
                  
If !Empty(M->FJ2_CONTAG)
	dbSelectArea("FJ2")
	dbSetOrder(1)

	//A conta superior não está cadastrada na natureza. 
	IF !Empty(M->FJ2_CTASUP)

		If !MsSeek(xFilial("FJ2")+M->FJ2_CODIGO+M->FJ2_CTASUP)
			Help("  ", 1, "NOCADCTASU" )
			lRet := .F.
        Endif
		
		//A conta superior deve ser sintetica. 
		If lRet .And. FJ2->FJ2_CLASSE != "1"
			Help(" ",1,"NOCLASSESI")
			lRet := .F.
		Endif	
	EndIf
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fa271Ent ³ Autor ³ Totvs					³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271Ent(lInclui)

Local lRet	:= .T.
Local cAlias  := Alias()
Local aArea   := FJ2->(GetArea())
                  
If !Empty(M->FJ2_CONTAG) .And. lInclui
	lRet	:= ExistChav("FJ2",M->FJ2_CODIGO+M->FJ2_CONTAG,2,)
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fa271Ord ³ Autor ³ Totvs			        ³ Data ³ 17.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche com zeros a esquerda o campo ordem do Pl.Gerencial³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Contas Gerencial                ³±±
±±³          ³ ExpN1 = Ordem no Plano                                     ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271Ord(lInclui)

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := FJ2->(GetArea())
Local cFilFJ2 := xFilial("FJ2")
Local nIncrementa := MV_PAR01

If lInclui
	If nIncrementa  > 0 .And. Empty(M->FJ2_ORDEM)
		dbSelectArea("FJ2")
		dbSetOrder(1)
		
		If MsSeek(cFilFJ2+M->FJ2_CODIGO, .F.)
			While FJ2->(!Eof()) .and. FJ2->FJ2_FILIAL == cFilFJ2 .and. FJ2->FJ2_CODIGO == M->FJ2_CODIGO
				FJ2->(dbSkip())                                 
				If FJ2->FJ2_FILIAL <> cFilFJ2 .or. FJ2->FJ2_CODIGO <> M->FJ2_CODIGO
					dbSkip(-1)
					M->FJ2_ORDEM := StrZero(Val(FJ2->FJ2_ORDEM) + nIncrementa,Len(M->FJ2_ORDEM))
					dbSkip()
				EndIf
			EndDo
		Else                                                       
			M->FJ2_ORDEM := StrZero(1,Len(M->FJ2_ORDEM))
		Endif

		RestArea(aArea)
		DbSelectArea(cAlias)
	Else
		M->FJ2_ORDEM := If(!Empty(M->FJ2_ORDEM),StrZero(Val(M->FJ2_ORDEM),Len(M->FJ2_ORDEM)),M->FJ2_ORDEM)
	Endif
EndIf	

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fa271Pos ³ Autor ³ Totvs                 ³ Data ³ 22/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona o FJ1/FJ3                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271Pos()
	If cAliasBrw == "FJ1" 		// Cabecalho
		DbSelectArea( "FJ3" )
		FJ3->( DbSetOrder( 1 ) )
		FJ3->( DbSeek( xFilial( "FJ3" ) + FJ1->FJ1_CODIGO ) )

		DbSelectArea( "FJ2" )
		FJ2->( DbSetOrder( 1 ) )
		FJ2->( DbSeek( xFilial( "FJ2" ) + FJ1->FJ1_CODIGO ) )
	ElseIf cAliasBrw == "FJ3"	// Itens
		DbSelectArea( "FJ1" )
		FJ1->( DbSetOrder( 1 ) )
		FJ1->( DbSeek( xFilial( "FJ1" ) + FJ3->FJ3_CODPLA ) )

		DbSelectArea( "FJ2" )
		FJ2->( DbSetOrder( 1 ) )
		FJ2->( DbSeek( xFilial( "FJ2" ) + FJ3->FJ3_CODPLA ) )
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FA271VlCkBx ³ Autor ³ Totvs			    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ valida e carrega checkbox                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldCkBx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FA271VlCkBx(nTipo,nOpc,cSelecao)

Default cSelecao := ""

Do Case
	//Tratamento para inicializar variaveis
	Case nTipo = 1
		Do Case
			Case cIdent $ "1/2" //Soma/Subtrai
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .F.
				lVldTotal     := .F.
				lVldSeparador := .F.
				lVldTraco     := .F.
	
			Case cIdent = "3" //Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .T.
				lVldTraco     := .T.
	
			Case cIdent = "4" //Total Geral/Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .T.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .F.
				lVldTraco     := .F.
	
			Case cIdent = "5" //Linha sem valor
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .T.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .F.
				lVldSeparador := .T.
				lVldTraco     := .F.
	
			Case cIdent = "6" //Linha sem valor/Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .F.
				lSeparador    := .T.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .F.
				lVldSeparador := .T.
				lVldTraco     := .F.
	
			Case cIdent = "7" //Separador
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .T.
				//Permitir edicao
				lVldNegrito   := .F.
				lVldTotal     := .F.
				lVldSeparador := .F.
				lVldTraco     := .T.
	
			Otherwise
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .T.
				lVldTraco     := .T.		
		EndCase
		If !Empty(cSelecao)
			oGet01:Refresh()
			oGet02:Refresh()
			oGet03:Refresh()
			oGet04:Refresh()
		EndIf
		
	//Tratamento para validar selecao
	Case nTipo = 2
		Do Case
			Case lNegrito .And.  lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Disable()/*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "4"

			Case !lNegrito .And.  lTotal .And. !lSeparador .And. !lTraco
					//Forca selecao do negrito quando total
					lNegrito      := .T.
					//Permitir edicao
					oGet01:Disable()/*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "4"

			Case lNegrito .And.  !lTotal .And. lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "6"
			
			Case !lNegrito .And.  !lTotal .And. lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "5"

			Case 	lTraco
					lNegrito := .F.
					lTotal := .F.
					lSeparador := .F.
					//Permitir edicao somente do traco
					oGet01:Disable()/*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Enable() /*"Separador"      */
					cIdent := "7"
					
					If Inclui
						M->FJ3_DESCCG := PadR("-",Len(FJ3->FJ3_DESCCG))
					Else
						If Empty(M->FJ3_DESCCG) .OR. Alltrim(M->FJ3_DESCCG)=="-" .OR. Aviso(STR0016,STR0017 , {STR0018, STR0019})==1  //"Atencao"###"Sobrepor descricao da conta por (-)traco."###"Sim"###"Não"
							M->FJ3_DESCCG := PadR("-",Len(FJ3->FJ3_DESCCG))
						Else
							lTraco := .F.
							//Permitir edicao
							oGet01:Enable() /*"Negrito"        */
							oGet02:Enable() /*"Total Geral"    */
							oGet03:Enable() /*"Linha sem Valor"*/
							oGet04:Enable() /*"Separador"      */
							cIdent := " "							
						EndIf
					EndIf

			Case 	lNegrito .And. !lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "3"

			Case 	!lNegrito .And. !lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Enable() /*"Separador"      */
					cIdent := " "
		EndCase
		oGet01:Refresh()
		oGet02:Refresh()
		oGet03:Refresh()
		oGet04:Refresh()

EndCase

//Bloquei para edicao quando diferente inclusao e alteracao
If !(AllTrim(Str(nOpc)) $ "3/4")
	lVldNegrito   := .F.
	lVldTotal     := .F.
	lVldSeparador := .F.
	lVldTraco     := .F.
EndIf

oEnch:Refresh()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa271CHKINCºAutor  ³Microsiga         º Data ³  07/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa271ChkInc()
Local lRet := .F.
Local aArea := GetArea()
Local nRecFJ3 := FJ3->(Recno())
dbSelectArea("FJ3")
dbSetOrder(1)

lRet := dbSeek(xFilial("FJ3")+PadR(FJ1->FJ1_CODIGO, Len(FJ3_CODPLA))+StrZero(1, Len(FJ3->FJ3_ORDEM)))

dbSelectArea("FJ3")
dbGoto(nRecFJ3)

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa271GRV ºAutor  ³Microsiga           º Data ³  07/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa271Grv()
//esta funcao apenas salva o recno na variavel private nRecFJ1
//considerando que esta executando neste momento a funcao axinclui
//com tabela FJ1 posicionada
nRecFJ1 := Recno()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNI271VlTotºAutor ³Totvs				 º Data ³  24/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que a visão gerencial tenha apenas uma entidadade    º±±
±±º          ³totalizadora de analise vertical                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA271VlTot(cVisao,cOrdem)
Local lRet 		:= .T.
Local aArea		:= GetArea()

Default cVisao	:= M->FJ3_CODPLA
Default cOrdem	:= M->FJ3_ORDEM


FJ3->(dbSetOrder(1)) 

If lRet .And. M->FJ3_TOTVIS == '1'
	If FJ3->(MsSeek(xFilial("FJ3") + cVisao ))
		While FJ3->(FJ3_FILIAL+FJ3_CODPLA) == xFilial("FJ3") + cVisao .And. FJ3->(!EOF())
			If FJ3->FJ3_TOTVIS == '1' .And. FJ3->FJ3_ORDEM != cOrdem
				Help("",1,"HELP","VLTOTVIS",STR0020+FJ3->FJ3_DESCCG+STR0021,3,1) //"A entidade "###" já está selecionada como totalizadora da Visão "
				lRet := .F.
				Exit
			EndIf    
			FJ3->(dbSkip())
		EndDo 
	EndIf
EndIf
RestArea(aArea)	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNI61VlTotºAutor  ³Totvs				 º Data ³  24/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que a visão gerencial tenha apenas uma entidadade    º±±
±±º          ³totalizadora de analise vertical                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA61VlTot(cVisao,cOrdem)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaFJ2	:= {}

Default cVisao	:= M->FJ2_CODIGO
Default cOrdem	:= M->FJ2_ORDEM

 

If lRet	
	aAreaFJ2 := FJ2->(GetArea())
	FJ2->(dbSetOrder(1))
	If !Empty(ALLTRIM(M->FJ2_CTASUP)) .and. FJ2->(MsSeek(xFilial("FJ2") + cVisao + M->FJ2_CTASUP ))
		If FJ2->FJ2_TOTVIS == '1'
			Help("",1,"HELP","NOTOTVIS",STR0032,3,1) //"Não é permitido utilizar a entidade totalizadora como entidade superior."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaFJ2)
EndIf

FJ2->(dbSetOrder(4))
If lRet .And. M->FJ2_TOTVIS == '1'
	If !Empty(M->FJ2_CTASUP)
		Help("",1,"HELP","SUPTOTVIS",STR0030,3,1) //"Não será permitido o preenchimento do campo entidade superior para a entidade totalizadora."
		lRet := .F.
	EndIf
	If lRet
		If FJ2->(MsSeek(xFilial("FJ2") + cVisao ))
			While FJ2->(FJ2_FILIAL+FJ2_CODIGO) == xFilial("FJ2") + cVisao .And. FJ2->(!EOF())
				If FJ2->FJ2_TOTVIS == '1' .And. FJ2->FJ2_ORDEM != cOrdem
					Help("",1,"HELP","VLTOTVIS",STR0020+FJ2->FJ2_DESCCG+STR0021,3,1) //"A entidade"###"já está selecionada como totalizadora da Visão"
					lRet := .F.
					Exit
				EndIf  

				If !Empty(FJ2->FJ2_CTASUP) .and. FJ2->FJ2_CTASUP == M->FJ2_CONTAG
					Help("",1,"HELP","SUPTOTVIS",STR0031,3,1) // "A entidade totalizadora não deverá estar cadastrada como entidade superior de outra entidade."
					lRet := .F.
					Exit
				EndIf
				FJ2->(dbSkip())
			EndDo 
		EndIf
	EndIf
EndIf

RestArea(aArea)	
Return lRet
	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CNI271Cad ³ Autor ³ Totvs					³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela enchoice e a getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNI271Cad(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNI271X                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CNI271Cad(cAlias,nReg,nOpc, lUsaCad )
Local aCmpAdic		:= {}
Local nInc			:= 0

// Declaração das variaveis
Private oDlg,oEnch,oPanel,oScroll
Private oGet01,oGet02,oGet03,oGet04
Private lNegrito, lTotal, lSeparador, lTraco
Private lVldNegrito,lVldTotal,lVldSeparador,lVldTraco
Private oGDItens
Private nCtrlGet  	:= 1
Private aGets     	:= {} 
Private aTela     	:= {}
Private aButtons  	:= {}
Private nOpcao		:= 0
Private bOk       	:= { || IIf(  Cni271TOk() , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }  
Private bCancel   	:= { || nOpcao:=0 , oDlg:End() }
Private nSuperior 	:= 0
Private nEsquerda 	:= 0
Private nInferior 	:= 0
Private nDireita  	:= 0
Private aSizeAut  	:= {}
Private aObjects  	:= {}
Private aInfo     	:= {}
Private aPosGet   	:= {}
Private aPosObj   	:= {}
Private aCT1Blq		:= {}
Private cIdent

Default lUsaCad		:= .T.

Fa271Pos()

If nOpc != 3
	cIdent		:= FJ3->FJ3_IDENT
Else
	cIdent		:= CriaVar("FJ3_IDENT",.T.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a forma de exibicao da visao gerencial.³
//³Modo tradicional ou arvore.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUsaCad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³posiciona no CVE correspondente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		Fin271Inc() 
		Return
	Else
		If nOpc == 2					// Visuaizar
			Fin271Cad( cAlias, nReg, nOpc )    
			Return
		ElseIf nOpc == 4				// Alterar
			Fin271Cad( cAlias, nReg, nOpc )  
			Return
		EndIf
	EndIf
EndIf

nReg   := IIf(nOpc==3,Nil,FJ3->(Recno()))
cAlias := "FJ3"

// Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()
aAdd(aObjects,{100,083,.T.,.F.})
aAdd(aObjects,{100,100,.T.,.T.})

aInfo     := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj   := MsObjSize(aInfo,aObjects)

//Ajusta para ter mais um array com divisoes da dimenssao da tela
aAdd(aPosObj,{aPosObj[1,1],aPosObj[1,4]*0.7+3,aPosObj[1,3]-15,(aPosObj[1,4]*0.3)-3})
aPosObj[1,4]:=aPosObj[1,4]*0.7

// Verifica o tipo de chamada e trata a situação
cExbCpos := "FJ3_CODPLA/FJ3_ORDEM/FJ3_CONTAG/FJ3_CTASUP/FJ3_CLASSE/FJ3_NORMAL/FJ3_DESCCG/FJ3_DETHCG/FJ3_COLUNA/FJ3_NOME"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui os campos adicionais se os mesmos existirem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aCmpAdic, "FJ3_TOTVIS" )
aAdd( aCmpAdic, "FJ3_VISENT" )
aAdd( aCmpAdic, "FJ3_SLDENT" )
aAdd( aCmpAdic, "FJ3_FATSLD" )

For nInc := 1 To Len( aCmpAdic )
	cExbCpos += "/" + aCmpAdic[nInc]
Next

Do Case
	Case nOpc == 2	//Visualização
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Case nOpc == 3	//Inclusão
		nOpEnch:= 3
		aExbCpo:= fInitVarX3(cAlias,.T.,cExbCpos)
		
	Case nOpc == 4	//Alteração
		nOpEnch:= 3
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Case nOpc == 5	//Exclusão
		nOpEnch:= 5
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Otherwise //Outras situações
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
EndCase

// Montagem da tela que serah apresentada para usuario (lay-out)
Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel

/*Cabeçalho		*/	oEnch := Msmget():New(cAlias,nReg,nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)
/*CheckBox		*/	F271xChBox(nOpc,oDlg,nReg)   
/*Itens			*/ fGDItens(nOpc,oDlg,nReg)             

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

Do Case
   //Se for inclusao e foi confirmado
   Case nOpc == 3 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg) 
   //Se for alteracao e foi confirmado
   Case nOpc == 4 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)     

   //Se for exclusao e foi confirmado
   Case nOpc == 5 .And. nOpcao == 1
        fExcluiTudo()         
EndCase

Return                               


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fInitVarX3   ³ Autor ³ Totvs			    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega as variaveis em memoria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fInitVarX3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fInitVarX3(cAlias,lInitVarX3,cExibeCpos)

Local aExibLst 	:= {}

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If cNivel >= SX3->X3_NIVEL
		If Empty(cExibeCpos) .Or. AllTrim(SX3->X3_CAMPO) $ cExibeCpos
			If lInitVarX3
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
			Else
				If SX3->X3_CONTEXT != "V"
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_CAMPO))
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_RELACAO))
				EndIf
			EndIf
			AADD(aExibLst,SX3->X3_CAMPO)
		//---------------------------------
		// Tratamento de campo de Usuario
		//---------------------------------
		ElseIf SX3->X3_PROPRI == "U"
			If lInitVarX3
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
			Else
				If SX3->X3_CONTEXT != "V"
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_CAMPO))
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_RELACAO))
				EndIf
			EndIf
			AADD(aExibLst,SX3->X3_CAMPO)		
		EndIf
	EndIf
	SX3->(DbSkip())
End

//Tratamento pra travar campo nome da visao
Fin271Nome()

Return(aExibLst)   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin271Nome ³ Autor ³Totvs				    ³ Data ³ 10.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Fin271Nome()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := FJ3->(GetArea())

dbSelectArea("FJ3")
dbSetOrder(1)
If MsSeek(xFilial("FJ3")+M->FJ3_CODPLA,.F.)
	M->FJ3_NOME := FJ3->FJ3_NOME
	lTrvNome := .F.
Else
	lTrvNome := .T.
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ F271xChBox     ³ Autor ³ Totvs			    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Panel com checkbox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F271xChBox()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function F271xChBox(nOpc,oDefTela,nReg)

@ aPosObj[3,1], aPosObj[3,2] MSPANEL oPanel SIZE aPosObj[3,4], aPosObj[3,3] Of oDlg
@ 000,000 SCROLLBOX oScroll SIZE 010,010 Pixel Of oPanel
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

//Inicializa variaveis do checkbox
FA271VlCkBx(1, nOpc)  

//se for analitica nao deve permitir alterar o check
If M->FJ3_CLASSE == "2"
	lVldNegrito   := .F.
	lVldTotal     := .F.
	lVldSeparador := .F.
	lVldTraco     := .F.
EndIf

@ 09,15 Say STR0022 Size 050,009 COLOR CLR_HBLUE Of oScroll Pixel //"Identificadores"
@ 25,15 CHECKBOX oGet01 VAR lNegrito   Size 050,009 PROMPT STR0023 When (lVldNegrito  ) On Change(FA271VlCkBx(2,nOpc)) Of oScroll  //"Negrito"
@ 36,15 CHECKBOX oGet02 VAR lTotal     Size 050,009 PROMPT STR0024 When (lVldTotal    ) On Change(FA271VlCkBx(2,nOpc)) Of oScroll //"Total Geral"
@ 47,15 CHECKBOX oGet03 VAR lSeparador Size 050,009 PROMPT STR0025 When (lVldSeparador) On Change(FA271VlCkBx(2,nOpc)) Of oScroll //"Linha sem Valor"
@ 58,15 CHECKBOX oGet04 VAR lTraco     Size 050,009 PROMPT STR0026 When (lVldTraco    ) On Change(FA271VlCkBx(2,nOpc)) Of oScroll //"Separador"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGDItens     ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta MsNewGetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGDItens()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGDItens(nOpc,oDefTela,nReg)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local cGetOpc        := GD_INSERT+GD_DELETE+GD_UPDATE    // GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinhaOk       := "Cni271LOk"                     // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk        := "Cni271GOk"                     // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos       := "+FJ3_LINHA"                     // Nome dos campos do tipo caracter que utilizarao incremento automatico.                                                              
Local nFreeze        := Nil                              // Campos estaticos na GetDados.                                                               
Local nMax           := 999                              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk       := Nil                              // Funcao executada na validacao do campo                                           
Local cSuperApagar   := Nil                              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk       := Nil                              // Funcao executada para validar a exclusao de uma linha do aCols                   
Local aHead          := {}                               // Array do aHeader
Local aCols          := {}                               // Array do aCols

// Valor das variaveis que as rotinas faCols e faHead irá utilizar como referencia
Local x       := 1                                       //Variavel usada no For/Next
Local cGetAls := "FJ3"                                   //Alias usado na função para montar o aHeader e o Acols
Local nGetOpc := nOpc                                    //Opção da operação que está sendo executada
Local cGetOrd := 1                                       //Ordem do Indice utilizado na função que carrega o aCols
Local nGetQtd := 1                                       //Quantidade de linhas iniciadas no aCols quando inclusão
Local cGetCnd := "xFilial('FJ3')+M->FJ3_CODPLA+M->FJ3_ORDEM"
Local cGetCpo := "FJ3->FJ3_FILIAL+FJ3->FJ3_CODPLA+FJ3->FJ3_ORDEM"
Local cExbCpo := "FJ3_LINHA/FJ3_SEDINI/FJ3_SEDFIM/FJ3_IDENTI/FJ3_FORMUL" //Forçar mostrar no MsNewGetDados apenas os campos definidos nesta variavel
Local aTrtCpo := {}                                      //Array contendo campos com valores que serão usadas no aCols quando inclusão
Local aAuxHead		:= {}
Local cAuxExbCpo	:= ""

//Montando um array conforme parametros acima para ser usada na função que montas o aCols
For x:=1 To nGetQtd
    aAdd(aTrtCpo,{"FJ3_LINHA",StrZero(x,Len(CriaVar("FJ3_LINHA"))),.F.})
Next x

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos a serem exibidos no MsNewGetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cExbCpo := "FJ3_LINHA/FJ3_SEDINI/FJ3_SEDFIM"
//Execução das rotinas

aEval(aAuxHead, {|x|aAdd(aHead, x)})

cExbCpo += cAuxExbCpo
	
oGDItens:=MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)                                   
oGDItens:oBrowse:bWhen := { || M->FJ3_CLASSE $ "|2|" }

//Reposiciona a seta no registro inicial
If nOpc != 3 ; DbGoTo(nReg) ; EndIf

Return                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSalvaTudo   ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSalvaTudo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

// Declara variaveis
Local x        := 1
Local nOrdSeek := 1
Local aGrvCps  := {}
Local cCpoItem := "FJ3_LINHA"
Local cCndSeek := "xFilial('FJ3')+M->FJ3_CODPLA+M->FJ3_ORDEM" 

//Trata campos do enchoice
For x:=1 To Len(aExbCpo)
    aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x]	})
Next x

//Trata campos extras
aAdd(aGrvCps,{"FJ3_FILIAL"   ,"xFilial('FJ3')"   })
aAdd(aGrvCps,{"FJ3_LINHA"    ,"cCodItem"         })

If M->FJ3_CLASSE == "1"
	aAdd(aGrvCps,{"FJ3_IDENT"    ,"cIdent"           })
ElseIf M->FJ3_CLASSE == "2"
	aAdd(aGrvCps,{"FJ3_IDENT"    ,"M->FJ3_IDENTI"           })
EndIf
	
//Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
fGravaGD(oGDItens,cAlias,aGrvCps,nOpc,nOrdSeek,cCndSeek,cCpoItem) 

//Reposiciona no primeiro registro no grupo em questão
FJ3->(DbSetOrder(1))
FJ3->(DbSeek(xFilial('FJ3')+M->FJ3_CODPLA+M->FJ3_ORDEM))

Return
                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fExcluiTudo  ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela exclusão de todos os itens         ³±±
±±³          ³ apresentados na tela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fExcluiTudo()

//Executa procedimento de exclusão de registros
FJ3->(DbSetOrder(1))
If FJ3->(DbSeek(xFilial('FJ3')+M->(FJ3_CODPLA+FJ3_ORDEM)))
	While FJ3->(!Eof()) .And. xFilial('FJ3')+M->(FJ3_CODPLA+FJ3_ORDEM) == FJ3->(FJ3_FILIAL+FJ3_CODPLA+FJ3_ORDEM)
		RecLock("FJ3",.F.)
		dbDelete()
		MsUnLock()
		FJ3->(DbSkip())
	End
EndIf
	
Return  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGravaGD     ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±³          ³ apontadas no MsNewGetDados / tratamento por objeto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm)

Local x 		:= 1
Local y 		:= 1
Local k 		:= 1
Local lCriaFJ2	:= .F.
Local lTotVis	:= .T.
Local lVisEnt	:= .T.
Local lSldEnt	:= .T.
Local lFatSld	:= .T.

Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

DbSelectArea(cAlias)

For x:=1 To Len(oObjct:aCols)
	If !oObjct:aCols[x,Len(oObjct:aHeader)+1]
		
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		
		If nTpOper == 3
			RecLock(cAlias,.T.)
		ElseIf DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIf
		
		For y:=1 To Len(oObjct:aHeader)
			&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
		Next y
		
		For k:=1 To Len(aCposAdd)
			&(aCposAdd[k,1]) := &(aCposAdd[k,2])
		Next k
		
		cCodItem := Soma1(cCodItem)
		MsUnLock()

		// Grava a tabela FJ1
		If nTpOper == 3
			If FJ1->( !DbSeek( xFilial( "FJ1" ) + FJ3->FJ3_CODPLA ) )
				RecLock( "FJ1", .T. )
				Replace FJ1_FILIAL With xFilial( "FJ1" )
				Replace FJ1_CODIGO With FJ3->FJ3_CODPLA
				Replace FJ1_DESCRI With FJ3->FJ3_NOME
				MsUnLock()
			EndIf
		EndIf		

		// Grava a tabela FJ2
		FJ2->( DbSetOrder( 1 ) )
		lCriaFJ2 := FJ2->( !DbSeek( xFilial( "FJ2" ) + FJ3->FJ3_CODPLA + FJ3->FJ3_CONTAG) )
		RecLock( "FJ2", lCriaFJ2 )
		Replace FJ2_FILIAL 	With xFilial( "FJ2" )
		Replace FJ2_CODIGO 	With FJ3->FJ3_CODPLA
		Replace FJ2_CONTAG 	With FJ3->FJ3_CONTAG
		Replace FJ2_DESCCG 	With FJ3->FJ3_DESCCG
		If FJ2->(FIELDPOS("FJ2_DETHCG")) > 0
			Replace FJ2_DETHCG 	With FJ3->FJ3_DETHCG
		EndIf
		Replace FJ2_ORDEM 	With FJ3->FJ3_ORDEM	
		Replace FJ2_CTASUP	With FJ3->FJ3_CTASUP
		Replace FJ2_CLASSE	With FJ3->FJ3_CLASSE
		Replace FJ2_NORMAL	With FJ3->FJ3_NORMAL	
		Replace FJ2_COLUNA	With AllTrim( Str( FJ3->FJ3_COLUNA ) )
		Replace FJ2_IDENT	With FJ3->FJ3_IDENT
		If lTotVis
			Replace FJ2_TOTVIS	With FJ3->FJ3_TOTVIS
		EndIf
		If lVisEnt
			Replace FJ2_VISENT	With FJ3->FJ3_VISENT
		EndIf
		If lSldEnt
			Replace FJ2_SLDENT	With FJ3->FJ3_SLDENT
		EndIf
		If lFatSld
			Replace FJ2_FATSLD	With FJ3->FJ3_FATSLD
		EndIf
		MsUnLock()
	Else
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		If nTpOper != 3
			If DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
				RecLock(cAlias,.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
	EndIf
Next x

Return

                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cni271TOk ºAutor  ³Microsiga           º Data ³  09/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a validação da tela de cadastro                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cni271TOk()
Local lRet := .T.
Local xRet := Nil
If lRet 
	lRet := Cni271Key(INCLUI)
EndIf 

If lRet
	lRet := Cni271Cbc() 
EndIf          

If lRet
	lRet := FA271VlTot() 
EndIf

If lRet 
	lRet := Fin271GOk() 
EndIf

If lRet	
	lRet := Obrigatorio(aGets,aTela) 
EndIf

If lRet
	lRet := oGDItens:TudoOk()
EndIf

Return lRet     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Cni271Key ³ Autor ³ Totvs				    ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro do Plano de Contas Gerencial                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNI160Key(cCts_CodPla,cCts_Ordem,nOpc)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Contas Gerencial                ³±±
±±³          ³ ExpN1 = Ordem no Plano                                     ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Cni271Key(lInclui)

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := FJ3->(GetArea())

If lInclui
	dbSelectArea("FJ3")
	dbSetOrder(1)
	If dbSeek(xFilial()+M->FJ3_CODPLA+M->FJ3_ORDEM)
		Help("  ", 1, "PLANOEXIST")
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Cni271Cbc ³ Autor ³ Totvs				    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Classe e condicao normal da conta co cabecalho      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNI271Cbc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do SX3 do Campo CTS_Conta                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cni271Cbc()

Local lRet := .T.

If lRet .And. Empty(M->FJ3_CODPLA)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("FJ3_CODPLA")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_ORDEM)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("FJ3_ORDEM")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_CONTAG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("FJ3_CONTAG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_DESCCG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("FJ3_DESCCG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_NOME)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("FJ3_NOME")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_CLASSE) .And. !(cIdent $ "3/4/5/6" .Or. SubStr(M->FJ3_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCLASS")
	lRet := .f.
EndIf

If lRet .And. Empty(M->FJ3_NORMAL) .And. !(cIdent $ "5/6" .Or. SubStr(M->FJ3_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCOND")
	lRet := .f.
EndIf

Return lRet             


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fin271GOk    ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todos os campos do MsNewGetDados de todas as linhas ³±±
±±³          ³ para obrigar preenchimento dos campos obrigatorio.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNI271TOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fin271GOk()

Local aSaveArea:= GetArea()
Local aCols    := oGDItens:aCols
Local lRet     := .T.
Local nCont    := 0


For nCont := 1 To Len(aCols)
   oGDItens:oBrowse:nAt:=nCont
   oGDItens:oBrowse:Refresh()
   oGDItens:oBrowse:SetFocus()
	If !Fin271LOK()
		lRet := .F.
		Exit
	EndIf
Next nCont

RestArea(aSaveArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FIN271LOk    ³ Autor ³ Totvs			    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida linhas do MsNewGetDados para obrigar preenchimento  ³±±
±±³          ³ dos campos obrigatorio.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FIN271LOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNIA271X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fin271LOk()

Local aSaveArea   := GetArea()
Local aHeader     := oGDItens:aHeader
Local aCols       := oGDItens:aCols
Local n           := oGDItens:oBrowse:nAt
Local lRet		  := .T.
Local nPosNatIni  := Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_SEDINI"})
Local nPosNatFim  := Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_SEDFIM"})
Local nPosIdent   := Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_IDENTI"})
Local nPosFormula := Ascan(aHeader,{|x|Alltrim(x[2]) == "FJ3_FORMUL"})


If M->FJ3_CLASSE = "2"						// Verifica Analiticas
	If !aCols[n][Len(aHeader)+1]
		If Empty(aCols[n][nPosNatIni]) 	.And. Empty(aCols[n][nPosNatFim]) 	.And.;
			Empty(aCols[n][nPosFormula])	.And.;
			(aCols[n][nPosIdent] == "1" .Or. aCols[n][nPosIdent] == "2") .And.;
			! (cIdent = "3" .Or. cIdent = "4" .Or. cIdent $ "5/6" .Or. M->FJ3_DESCCG = "-")
			lRet := .F.
		EndIf

		If !lRet
			Help(" ",1,"C160NOENTI")
		EndIf

		If lRet
			If !Empty(aCols[n][nPosNatIni]) .And. Empty(aCols[n][nPosNatFim])
				Help(" ",1,"C160NOCTA")
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If	M->FJ3_CLASSE = "1" .And. (Empty(aCols[n][nPosIdent]) .Or. !(cIdent $ "1/2"))
				Help(" ",1,"C160NOSIN")
				lRet := .F.
			EndIf
		EndIf
		
	EndIf
EndIf

If M->FJ3_CLASSE = "1" .And. cIdent = "4"
	If !Empty(aCols[n][nPosNatIni]) 	.Or. !Empty(aCols[n][nPosNatFim])
		lRet := .F.
	EndIf
    
		If !lRet
			MsgAlert(STR0027,STR0028) //"Conta de total somente pode possuir formula"###"Alerta"
        EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

