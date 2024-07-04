#INCLUDE "TMSAE20.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20  ³ Autor ³ Jesus Pedro           ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configuracao de lay-out de importacao/exportacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20()

Private lOrdSeq   := .F.
Private cCadastro := STR0001 //'Configuracao de layout'
Private aRotina	:= MenuDef()

DE0->(DbSetOrder(2))

MBrowse( 6,1,22,75,'DE0',,'DE0_STATUS=="2"')

RetIndex('DE0')

Return( Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20Mnt³ Autor ³ Jesus Pedro           ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configuracao de Layouts                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20Mnt(cAlias,nReg,nOpcx)

Local oEnch
Local oDlgEsp
Local aAreaAnt		:= GetArea()
Local aAreaDE1		:= DE1->( GetArea() )
Local nCntFor		:= 0
Local nc
Local cCodAnt       := ""
Local aVisual		:= {}
Local aAltera		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local aNoFields	    := {}
Local aYesFields	:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local cCodLay       := DE0->DE0_CODLAY
Local cCodReg       := DE0->DE0_CODREG
Local aVoltaDED     := {}
Local aVoltaDEE     := {}
Local aCposDED      := {}
Local aCposDEE      := {}
Local bCampo        := { |nCPO| Field( nCPO ) }

Private oGetD
Private lAltCompl  := .F.
Private nPosSeq    := 0
Private lCopy      := .F.
Private aHeader    := {}
Private aCols      := {}
Private aPosObj    := {}
Private nPosTipo   := 0
Private aGrvOrdDED := {}
Private aGrvOrdDEE := {}
Private aTela[0][0]
Private aGets[0]
           
//-- Configura variaveis da Enchoice
RegToMemory(cAlias,nOpcx==3)

//-- Guarda o codigo anterior
cCodAnt := M->DE0_CODLAY + M->DE0_CODREG

//-- Se for copia, zera a chave e troca o nOpcx para 4 (Alteracao)
If nOpcx == 6
	M->DE0_CODLAY := CriaVar( "DE0_CODLAY", .F. )
	M->DE0_CODREG := CriaVar( "DE0_CODREG", .F. )
	nOpcx  := aRotina[nOpcx,4]
	Inclui := .T.
	lCopy  := .T.
EndIf

//-- Se for Alteracao, armazena o complemento de layout, utilizado no cancelamento da rotina
If nOpcx == 4
	DbSelectArea("DE1")
	DbSetOrder(1)
	If MsSeek(xFilial("DE1")+cCodLay+cCodReg)
		While DE1->(!Eof()) .And. DE1->DE1_FILIAL+DE1->DE1_CODLAY+DE1->DE1_CODREG == xFilial("DE1")+cCodLay+cCodReg
			If DE1->DE1_TIPO $ "2,3"
				AE20SeqComp(DE1->DE1_SEQUEN,DE1->DE1_SEQUEN,@aCposDED,@aCposDEE)
			EndIf
			DE1->(DbSkip())
		EndDo
		aVoltaDED  := aGrvOrdDED
		aVoltaDEE  := aGrvOrdDEE
		aGrvOrdDED := {}
		aGrvOrdDEE := {}
	EndIf
EndIf


Aadd( aNoFields, 'DE1_CODLAY')
Aadd( aNoFields, 'DE1_CODREG')

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DE1', 1,xFilial( 'DE1' ) + cCodAnt, { ||	DE1->DE1_FILIAL + DE1->DE1_CODLAY + DE1->DE1_CODREG}, ;
{ || .T. }, aNoFields,	aYesFields )

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DE1_SEQUEN', 1 ) )
	GDFieldPut( 'DE1_SEQUEN', StrZero(1,Len(DE1->DE1_SEQUEN)), 1 )
EndIf

nPosSeq:= Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_SEQUEN"})

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, {100, 50, .T., .T. } )
AAdd( aObjects, {100, 50, .T., .T. } )

nPosTipo := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_TIPO"  })

aAdd(aButtons,{"EDIT",{|| If(aCols[n,nPosTipo] $ "2,3",AE20ComEDI(nOpcX,cAlias),)}, STR0015 , STR0020 })//"Complemento de Configuracao dos Itens do Laytout"

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	oEnch := MsMGet():New( cAlias, nReg, nOpcx,,,,,aPosObj[1],, 3,,,,,,.T. )
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,"TMSAE20LinOk","TMSAE20TudOk","+DE1_SEQUEN",nOpcx==3 .Or. nOpcx==4,,,,999,,,,"TMSAE20PIF(1)")
	oGetD:oBrowse:bEditCol 	:= {|| AE20OrdSeq("DE1"), oGetD:oBrowse:Refresh() }
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetD:TudoOk(),(nOpca:=1,oDlgEsp:End()),)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1
	TMSAE20Grv( nOpcx, cCodLay, cCodReg )
ElseIf Inclui .And. nOpcA <> 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui Complementos de Layout. 				    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor:= 1 To Len(aCols)
		TMSAE20ExC(aCols[nCntFor,nPosSeq])
	Next nCnt	

ElseIf nOpcA <> 1

	If lAltCompl
		Begin Transaction		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui Complementos de Layout. 				    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCntFor:= 1 To Len(aCols)
				TMSAE20ExC(aCols[nCntFor,nPosSeq])
			Next nCntFor
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclui Complementos de Layout inicial.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCntFor := 1 To Len(aCposDED)
				DbSelectArea("DED")
				RecLock("DED",.T.)
				For nC := 1 TO FCount()
					If FieldName(nC) == 'DED_FILIAL'
						FieldPut(nC,xFilial("DED"))
					Else
						FieldPut( nC, aCposDED[nCntFor,nC] )
					EndIf
				Next nC
				MsUnLock()
			Next nCntFor

			For nCntFor := 1 To Len(aCposDEE)
				DbSelectArea("DEE")
				RecLock("DEE",.T.)
				For nC := 1 TO FCount()
					If FieldName(nC) == 'DEE_FILIAL'
						FieldPut(nC,xFilial("DEE"))
					Else
						FieldPut( nC, aCposDEE[nCntFor,nC] )
					EndIf
				Next nC
				MsUnLock()
			Next nCntFor

		End Transaction
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Devolve a sequencia do complemento de Layout.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AE20Grvcp(aVoltaDED,aVoltaDEE)
    EndIf

EndIf

DeleteObject( oDlgEsp )
DeleteObject( oEnch )
DeleteObject( oGetD )

RestArea( aAreaDE1 )
RestArea( aAreaAnt )

Return(nOpca)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20Grv³ Autor ³ Jesus Pedro          ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20Grv(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAE20Grv( nOpcx, cCodLay, cCodReg )

Local aAreaAnt	:= GetArea()
Local aAreaDE1	:= DE1->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0
Local nq

If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Enchoice ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DE0->( DbSetOrder( 1 ) )

		If	DE0->( MsSeek( xFilial('DE0') + M->DE0_CODLAY + M->DE0_CODREG, .F. ))
			RecLock('DE0',.F.)
		Else
			RecLock('DE0',.T.)
		EndIf
		For nQ:=1 To FCount()
			If ( FieldName(nQ) == "DE0_FILIAL" )
				FieldPut(nQ, xFilial())
			Else
				FieldPut(nQ, M->&(FieldName(nQ)))
			EndIf
		Next
		If DE0->(FieldPos("DE0_CODQRY")) > 0
			MSMM(DE0->DE0_CODQRY,,,M->DE0_QUERY,1,,,"DE0","DE0_CODQRY")
		EndIf
		MsUnLock()
		
		// Se ja existir o registro apaga pra incluir novamente
		DE1->( DbSetOrder( 1 ))
		If	DE1->( MsSeek( xFilial('DE1') + M->DE0_CODLAY + M->DE0_CODREG, .F. ))
			While !Eof() .And. (DE1->DE1_FILIAL + DE1->DE1_CODLAY + DE1->DE1_CODREG == xFilial('DE1') + M->DE0_CODLAY + M->DE0_CODREG)
				RecLock('DE1',.F.,.T.)
				DE1->(DbDelete())
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava GetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DE9")
		dbSetOrder(1)
		MSSeek( xFilial("DE9")+M->DE0_CODLAY)
		ASORT(aCols,,,{|x, y| x[nPosSeq] < y[nPosSeq]}) // Ordena o campo sequencia
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava GetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )
				RecLock('DE1',.T.)
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				DE1->DE1_FILIAL := xFilial('DE1')
				DE1->DE1_CODLAY := M->DE0_CODLAY
				DE1->DE1_CODREG := M->DE0_CODREG
				MsUnLock()
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui Complementos de Layout. 				 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TMSAE20ExC(aCols[nCntFor,nPosSeq])
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia do Complemento.  						   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCopy
			TMSAE20CpC(cCodLay,cCodReg)
			lCopy := .F.
		EndIf
		
		EvalTrigger()

	End Transaction
Else
	Begin Transaction
		DE0->( DbSetOrder( 1 ) )
		If	DE0->( MsSeek( xFilial('DE0') + M->DE0_CODLAY + M->DE0_CODREG, .F. ))
			RecLock('DE0',.F.,.T.)
			DE0->(DbDelete())
			MsUnLock()
		EndIf

		DE1->( DbSetOrder( 1 ))
		If	DE1->( MsSeek( xFilial('DE1') + M->DE0_CODLAY + M->DE0_CODREG, .F. ))
			While !Eof() .And. (DE1->DE1_FILIAL + DE1->DE1_CODLAY + DE1->DE1_CODREG == xFilial('DE1') + M->DE0_CODLAY + M->DE0_CODREG)
				RecLock('DE1',.F.,.T.)
				DE1->(DbDelete())
				MsUnLock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui Complementos de Layout. 				 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TMSAE20ExC(DE1->DE1_SEQUEN)
				dbSkip()
			EndDo
		EndIf

	End Transaction
EndIf

RestArea( aAreaDE1 )	
RestArea( aAreaAnt )	

Return( Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20LinOk ³ Autor ³ Jesus Pedro       ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao na troca de linha na getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20LinOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20LinOk()

Local lRet := .T.
Local nPos := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_SEQUEN"})

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))

	//O campo a ser verificado
	If nPos > 0
		cCampo:= "DE1_SEQUEN"
	Else
		cCampo:= "DEE_SEQUEN"
	EndIf

	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { cCampo }, 4 )
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20TudOk ³ Autor ³ Jesus Pedro       ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao na troca de linha na getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20TudOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20TudOk()

Local lRet    := .T.
Local nPosFim := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_POSFIM"})
Local nCnt    := 0
Local cTamFim := ""

//-- Verifica se o tamanho do registro eh igual a ultima posicao do layout
If nPosFim > 0
	For nCnt:= 1 To Len(aCols)
		If !GDdeleted(nCnt)
			cTamFim:= aCols[nCnt,nPosFim]
		EndIf
	Next nCnt
	
	If Val(cTamFim) <> M->DE0_TAMREG
		Help("",1,"TMSAE2001") // "O Tamanho Total dos itens de Layout tem que ser igual ao definido para o tamanho do registro."
		lRet := .F.
	EndIf
EndIf

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
If lRet
	lRet := Obrigatorio( aGets, aTela )
EndIf

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE20LinOk()
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20LEG   ³ Autor ³ Jesus Pedro       ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20LEG()

BrwLegenda( cCadastro,STR0007,{	{'BR_VERDE'	  ,STR0017},; 	//"Legenda"###"Ativo"
											{'BR_VERMELHO',STR0018}})	// "Inativo"

Return( .T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20SIX   ³ Autor ³ Jesus Pedro       ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Indice digitado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20SIX()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20SIX()

Local aArea     := GetArea()
Local nPosAlias := ""
Local nPosChave := ""
Local cAlias	 := SubStr(ReadVar(),4,3)
Local cIndice   := ""
Local nTamChv   := 0 
Local nIndex    := 0

Local lRet := .T.

If cAlias == "DE0"
	nTamChv   := TamSx3("DE0_POSCHV")[1]
ElseIf cAlias == "DE1"
	nPosAlias := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_ALIAS" })
	nPosChave := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_POSCHV"})
	nTamChv   := TamSx3("DE1_POSCHV")[1]
ElseIf cAlias == "DED"
	nTamChv   := TamSx3("DED_POSCHV")[1]
ElseIf cAlias == "DEE"
	nPosAlias := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_ALIAS" })
	nPosChave := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_POSCHV"})
	nTamChv   := TamSx3("DEE_POSCHV")[1]
EndIf

dbSelectArea("SIX")

nIndex  := Val(&(ReadVar()))
If nIndex > 0 .And. nIndex < 36
	cIndice := StrZero(nIndex,2)
	If Left(cIndice,1) > "0"
		cIndice := Chr(((Val(Left(cIndice,1)) * 10) + 54) + (Val(Right(cIndice,1)) + 1))
	Else
		cIndice := Right(cIndice,1)
	EndIf
	
	If cAlias == "DE0"  
		If MsSeek(M->DE0_ALIAS+cIndice)
			M->DE0_POSCHV := SIX->CHAVE
		Else
			M->DE0_POSCHV := Space(nTamChv)
			Msgalert(STR0024,STR0023)	//-- "Indice não localizado" ### "Atenção"
			lRet := .F.
		EndIf
	ElseIf cAlias == "DE1"
		If MsSeek(aCols[n,nPosAlias]+cIndice)
			aCols[n,nPosChave] := SIX->CHAVE
		Else
			aCols[n,nPosChave] := Space(nTamChv)
			Msgalert(STR0024,STR0023)	//-- "Indice não localizado" ### "Atenção"
			lRet := .F.
		EndIf
	ElseIf cAlias == "DED"
		If MsSeek(M->DED_ALIAS+cIndice)
			M->DED_POSCHV := SIX->CHAVE
		Else
			M->DED_POSCHV := Space(nTamChv)
			Msgalert(STR0024,STR0023)	//-- "Indice não localizado" ### "Atenção"
			lRet := .F.
		EndIf
	ElseIf cAlias == "DEE"
		If MsSeek(aCols[n,nPosAlias]+cIndice)
			aCols[n,nPosChave] := SIX->CHAVE
		Else
			aCols[n,nPosChave] := Space(nTamChv)
			Msgalert(STR0024,STR0023)	//-- "Indice não localizado" ### "Atenção"
			lRet := .F.
		EndIf
	EndIf
Else
	Msgalert(STR0022,STR0023)	//-- "Número do índice inválido..." ### "Atenção"
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE20F3    ³ Autor ³ Jesus Pedro       ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Informacoes do X3                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20F3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20F3()

Local cCadastro  := STR0008 // Campos
Local aRotOld    := aClone(aRotina)
Local aCampos    := {} 
Local aRotina    := {}
Local aArea      := GetArea()
Local nPosCpo    := 0
Local nPosTip    := 0
Local nPosTam    := 0
Local nPosDec    := 0
Local nPosTipLt  := 0
Local nPosTamLt  := 0
Local nPosDecLt  := 0
Local aPesqui    := {}
Local cAlias     := SubStr(StrTran(ReadVar(),"M->",""),1,3)
Local cFldSel		:= ""
Local cX3Arquivo	:= ""
Local cX3Ordem		:= ""
Local cX3Titulo		:= ""
Local cX3Tipo		:= ""
Local nX3Tamanho	:= 0
Local nX3Decimal	:= 0

Private nOpcSel   := 0       
Private nPosAlias := 0

If cAlias == "DE1"
	cFldSel		:= "DE1_CAMPO"
	nPosAlias  := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_ALIAS"})
	nPosCpo    := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_CAMPO"})
	nPosTip    := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_FORMAT"})
	nPosTam    := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_TAMANH"})
	nPosDec    := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_DECIMA"})
	nPosTamLt  := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_LAYTAM"})
	nPosDecLt  := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_LAYDEC"})
ElseIf cAlias == "DEE"
	cFldSel		:= "DEE_CAMPO"
	nPosAlias  := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_ALIAS"})
	nPosCpo    := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_CAMPO"})
	nPosTip    := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_FORMAT"})
	nPosTam    := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_TAMANH"})
	nPosDec    := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_DECIMA"})
	nPosTamLt  := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_LAYTAM"})
	nPosDecLt  := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_LAYDEC"})
EndIf

cX3Arquivo	:= GetSX3Cache(cFldSel, "X3_ARQUIVO")
cX3Ordem	:= GetSX3Cache(cFldSel, "X3_ORDEM")
cX3Titulo	:= GetSX3Cache(cFldSel, "X3_TITULO")
cX3Tipo		:= GetSX3Cache(cFldSel, "X3_TIPO")
nX3Tamanho	:= GetSX3Cache(cFldSel, "X3_TAMANHO")
nX3Decimal	:= GetSX3Cache(cFldSel, "X3_DECIMAL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos,{"X3_ARQUIVO","",STR0010,Len(cX3Arquivo)}) // Arquivo
Aadd(aCampos,{"X3_ORDEM"  ,"",STR0011,Len(cX3Ordem)})   // Ordem
Aadd(aCampos,{"X3_CAMPO"  ,"",STR0012,Len(cFldSel)})   // Campo
Aadd(aCampos,{"X3_TITULO" ,"",STR0013,Len(cX3Titulo)})  // Titulo
Aadd(aPesqui,{STR0010+"+"+STR0011,1}) // Arquivo+Ordem
Aadd(aPesqui,{STR0012,2}) // Campo
Aadd(aRotina,{ STR0009,"TMSConfSel",0,2,,,.T.} ) // "Confirmar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaWndBrowse( 0,0,300,600,cCadastro,"SX3",aCampos,aRotina,,'aCols[n,nPosAlias]','aCols[n,nPosAlias]',.T.,,,aPesqui,"",.F.)

If !Empty(aCols[n,nPosAlias])
	aCols[n,nPosTip] := cX3Tipo
	aCols[n,nPosTam] := nX3Tamanho
	aCols[n,nPosDec] := nX3Decimal
	
	// Preenche esses valores como default
	aCols[n,nPosTamLt] := nX3Tamanho
	aCols[n,nPosDecLt] := nX3Decimal
	
	If cAlias == "DE1"
		TMSAE20Pif(1) //-- Atualiza Posicao Inicial e Final do Layout.
	EndIf

EndIf

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20Mnt³ Autor ³ Jesus Pedro           ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configuracao de Layouts                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao Selecionada                                  ³±±
±±³          ³ ExpC1 = Alias do registro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AE20ComEDI(nOpcX,cAlias)

Local aArea		:= GetArea()
Local aAreaDE0	:= DE0->(GetArea())
Local aAreaDE1	:= DE1->(GetArea())
Local cAliasAnt	:= cAlias
Local cCodLay	:= ""
Local cCodReg	:= ""
Local cChvDEE	:= ""
Local nRegDED	:= 0
Local nQ		:= 0
Local nSeqAnt	:= nPosSeq
Local aVisual	:= {}
Local aAltera	:= {}
Local nOpca		:= 0
Local oEnch
Local oDlg
Local aNoFields	:= {}
Local aYesFields:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local nPosTam   := 0
Local nPosItem  := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_SEQUEN"})
Local cSeqItem  := Acols[n,nPosItem]
Local nTamLay   := 0
Local nPosAtu   := 0
Local nPosCpo   := 0
Local nCntFo1           
Local nCntFor

Private aPosObjE := {}

SAVEINTER()

aTelaA := aTela
aGetsA := aGets

aTela			:= {}
aGets			:= {}
aHeader			:= {}
aCols			:= {}

If !Empty(M->DE0_CODLAY) .And. !Empty(M->DE0_CODREG)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia do Complemento.  						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCopy
		TMSAE20CpC()
		lCopy := .F.
	EndIf

	cCodLay	:= M->DE0_CODLAY
	cCodReg	:= M->DE0_CODREG
	cAlias	:= "DED"
	dbSelectArea("DED")
	dbSetOrder(1)
	If dbSeek(xFilial("DED")+M->DE0_CODLAY+M->DE0_CODREG+cSeqItem)
		nRegDED := DED->(Recno())
		If nOpcx == 3
			nOpcx := 4
		EndIf
	EndIf
	
	//Configura variaveis da Enchoice
	RegToMemory(cAlias,nOpcx==3)
	
	//-- Guarda o codigo anterior
	cChvDEE := M->DED_CODLAY + M->DED_CODREG + cSeqItem
	
	Aadd( aNoFields, 'DEE_CODLAY')
	Aadd( aNoFields, 'DEE_CODREG')
	
	//-- Configura variaveis da GetDados
	TMSFillGetDados( nOpcx, 'DEE', 1,xFilial( 'DEE' ) + cChvDEE, { ||	DEE->DEE_FILIAL + DEE->DEE_CODLAY + DEE->DEE_CODREG + DEE->DEE_SEQITE }, ;
	{ || .T. }, aNoFields,	aYesFields )
	
	//-- Inicializa o item da getdados se a linha estiver em branco.
	If Len(aCols) == 1 .And. Empty( GDFieldGet( 'DEE_SEQUEN', 1 ) )
		GDFieldPut( 'DEE_SEQUEN', StrZero(1,Len(DEE->DEE_SEQUEN)), 1 )
	EndIf
	
	nPosSeq	:= Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_SEQUEN"})

	//-- Dimensoes padroes
	aSizeEDI := MsAdvSize()
	AAdd( aObjects, { 100, 50, .T., .T. } )
	AAdd( aObjects, { 100, 50, .T., .T. } )
	
	aInfo := { aSizeEDI[1], aSizeEDI[2], aSizeEDI[3]/1.5, aSizeEDI[4]/1.5, 3, 3 }
	aPosObjE := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oDlg TITLE STR0016 FROM aSizeEDI[7]/1.5, 000 TO aSizeEDI[6]/1.5, aSizeEDI[5]/1.5 PIXEL
		//-- Monta a enchoice.
		oEnch	:= MsMGet():New(cAlias,nRegDED,nOpcx,,,,,aPosObjE[1],, 3,,,,,,.T. )
		M->DED_CODLAY	:= cCodLay
		M->DED_DSCLAY	:= Posicione("DE9",1,xFilial("DE9")+M->DED_CODLAY,"DE9_DSCLAY")
		M->DED_CODREG	:= cCodReg
		M->DED_DSCREG	:= Posicione("DE3",1,xFilial("DE3")+M->DED_CODREG,"DE3_DSCREG")
		
		//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
		oGetCEDI:= MSGetDados():New(aPosObjE[2,1], aPosObjE[2,2],aPosObjE[2,3],aPosObjE[2,4], nOpcx,'TMSAE20LinOk','TMSAE20TudOk','+DEE_SEQUEN',nOpcx==3 .Or. nOpcx==4,,,,999)
		oGetCEDI:oBrowse:bEditCol 	:= {|| AE20OrdSeq("DEE"), oGetCEDI:oBrowse:Refresh() }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If( oGetCEDI:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()}) CENTERED
	
	If nOpcx != 2 .And. nOpcA == 1
		If	nOpcx == 3 .Or. nOpcx == 4 //Incluir ou Alterar
			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Enchoice ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DED->(DbSetOrder(1))
				If	DED->( MsSeek( xFilial('DED')+M->DED_CODLAY+M->DED_CODREG+cSeqItem,.F.))
					RecLock('DED',.F.)
				Else
					RecLock('DED',.T.)
				EndIf
				For nQ:=1 To FCount()
					If ( FieldName(nQ) == 'DED_FILIAL')
						FieldPut(nQ, xFilial())
					Else
						FieldPut(nQ, M->&(FieldName(nQ)))
					EndIf
				Next
				DED->DED_SEQITE := cSeqItem
				MsUnLock()
				
				// Se ja existir o registro apaga pra incluir novamente
				DEE->( DbSetOrder(1))
				If	DEE->( MsSeek(xFilial('DEE')+M->DED_CODLAY+M->DED_CODREG+cSeqItem, .F. ))
					While !Eof() .And. (DEE->DEE_FILIAL+DEE->DEE_CODLAY+DEE->DEE_CODREG+DEE->DEE_SEQITE==xFilial('DEE')+M->DED_CODLAY+M->DED_CODREG+cSeqItem)
						RecLock('DEE',.F.,.T.)
						DEE->(DbDelete())
						MsUnLock()
						dbSkip()
					EndDo
				EndIf
				ASORT(aCols,,,{|x, y| x[nPosSeq] < y[nPosSeq]}) // Ordena o campo sequencia
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava GetDados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCntFor := 1 To Len(aCols)
					If	!GDDeleted( nCntFor )
						RecLock('DEE',.T.)
						For nCntFo1 := 1 To Len(aHeader)
							If	aHeader[nCntFo1,10] != 'V'
				         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
			    			EndIf
						Next
						DEE->DEE_FILIAL := xFilial('DEE')
						DEE->DEE_CODLAY := M->DED_CODLAY
						DEE->DEE_CODREG := M->DED_CODREG
						DEE->DEE_SEQITE := cSeqItem
						MsUnLock()						
					EndIf
				Next
				EvalTrigger()
				lAltCompl := .T.
			End Transaction
		EndIf
	EndIf
	
	DeleteObject( oDlg )
	DeleteObject( oEnch )
	DeleteObject( oGetCEDI )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o Tamanho total do complemento do Layout. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3 .Or. nOpcx == 4 .And. nOpcA == 1
		nPosTam := Ascan( aHeader, {|x| Trim(x[2] ) == "DEE_LAYTAM"})
		For nCntFor:= 1 To Len(aCols)
			If !GDDeleted(nCntFor)
				nTamLay+= aCols[nCntFor,nPosTam]
			EndIf
		Next nCntFor
	EndIf
  
	RestArea(aAreaDE1)
	RestArea(aAreaDE0)
	RestArea(aArea)
	cAlias	:= cAliasAnt
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as variaveis utilizadas na GetDados Anterior. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RESTINTER()

aTela := aTelaA
aGets := aGetsA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Tamanho do Complemento de Layout.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx != 2 .And. nOpcA == 1
	If nOpcx == 3 .Or. nOpcx == 4
		nPosCpo	:= Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_CAMPO" })
		nPosSeq	:= Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_SEQUEN"})
		nPosTam := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_LAYTAM"})
		nPosAtu := Ascan( aCols, {|x| x[nPosSeq] == cSeqItem })
	
		aCols[nPosAtu,nPosCpo]:= SubStr(STR0019,1,TamSx3("DE1_CAMPO")[1]) // "Complemento"
		aCols[nPosAtu,nPosTam]:= (nTamLay * M->DED_OCOREG)
	
		TMSAE20Pif(1) //-- Atualiza Posicao Inicial e Final do Layout.
	EndIf
EndIf

nPosSeq := nSeqAnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20PIF³ Autor ³ Eduardo de Souza      ³ Data ³ 09/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Posicao Inicial e Final do Item do Layout          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20PIF(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao de Atualizacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20PIF(nOpcao)

Local nCnt    := 0
Local aArea   := GetArea()
Local nPosTam := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_LAYTAM"})
Local nPosIni := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_POSINI"})
Local nPosFim := Ascan( aHeader, {|x| Trim(x[2] ) == "DE1_POSFIM"})
Local nTamLay := 0
Local nIniLay := 1
Local nFimLay := 0
Local nTamRet := TamSx3("DE1_POSINI")[1]
Local nPosAnt := 0

Default nOpcao := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Todas posicoes Iniiciais e Finais do Acols.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(aCols)

	//-- Calcula somente os dados que nao estiver deletado.
	If !GDdeleted(nCnt)

		If nCnt <> n .Or. nOpcao == 1 .Or. ( nCnt == n .And. nOpcao == 2 )
			nTamLay := aCols[nCnt,nPosTam]
		Else
			nTamLay := M->DE1_LAYTAM
		EndIf	
		
		If nCnt <> 1
			If nPosAnt > 0
				If aCols[nCnt,nPosTipo] == "3" // Complemento Condicional
					nIniLay := Val(aCols[nPosAnt,nPosFim])
					nTamLay := 1
				Else
					nIniLay := Val(aCols[nPosAnt,nPosFim])+1
				EndIf
			EndIf
		Else
			If aCols[nCnt,nPosTipo] == "3" // Complemento Condicional
				nIniLay := 0
				nTamLay := 1
			EndIf		
		EndIf
	
		nFimLay := nIniLay+(nTamLay-1)	
		aCols[nCnt,nPosIni]:= StrZero(nIniLay,nTamRet)
		aCols[nCnt,nPosFim]:= StrZero(nFimLay,nTamRet)	
		nPosAnt:= nCnt

	EndIf

Next nCnt

oGetD:Refresh()

RestArea( aArea )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20COMP³ Autor ³ Eduardo de Souza     ³ Data ³ 12/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Complemento de Item Layout.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20COMP()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20COMP()

Local aArea    := GetArea()
Local nOpcX    := If(Inclui,3,If(Altera,4,2))
Local cAlias   := Alias()

If M->DE1_TIPO $ "2,3" // Complemento / Complemento Condicional
	aCols[n,nPosTipo]:= M->DE1_TIPO
	AE20ComEDI(nOpcX,cAlias)
EndIf

RestArea( aArea )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20ExC ³ Autor ³ Eduardo de Souza     ³ Data ³ 12/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui Complementos de Layout.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20ExC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAE20ExC(cSeqItem)

Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui Complemento 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DED")
dbSetOrder(1)
If MsSeek(xFilial("DED") + M->DE0_CODLAY + M->DE0_CODREG + cSeqItem)
	RecLock('DED',.F.,.T.)
	DED->(DbDelete())
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui Itens do Complemento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DEE")
dbSetOrder(1)
If MsSeek(xFilial("DEE") + M->DE0_CODLAY + M->DE0_CODREG + cSeqItem)
	While !Eof() .And. DEE->DEE_FILIAL + DEE->DEE_CODLAY + DEE->DEE_CODREG + DEE->DEE_SEQITE == ;
		xFilial("DEE") + M->DE0_CODLAY + M->DE0_CODREG + cSeqItem
		RecLock('DEE',.F.,.T.)
		DEE->(DbDelete())
		MsUnlock()
		DEE->(DbSkip())
	EndDo
EndIf

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20Ini ³ Autor ³ Eduardo de Souza     ³ Data ³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializacao dos campos Formato/Tamanho/Decimal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20Ini(ExpC1,ExpC2,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo utilizado na GetDados             ³±±
±±³          ³ ExpC2 - Campo                                              ³±±
±±³          ³ ExpN1 - Tipo (1=Tamanho;2=Decimal;3=Formato)               ³±±
±±³          ³ ExpL1 - Gatilho (T=Verdadeiro;F=Falso)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20INI(cAlias,cCampo,nTipo,lGatilho)
Local aArea     := GetArea()
Local cRet      := ""
Local nPosAlias := Ascan( aHeader, {|x| Trim(x[2] ) == cAlias+"_ALIAS" })
Local aTam      := {}

Default lGatilho:= .F.

If nPosAlias > 0
	If lGatilho
		If !Empty(aCols[n,nPosAlias])
			If dbSelectArea(Select(aCols[n,nPosAlias])) > 0
				If (aCols[n,nPosAlias])->(FieldPos(cCampo)) > 0
					aTam := TamSx3(cCampo)
					If Len(aTam) > 0
						cRet:= aTam[nTipo]
					EndIf					
				EndIf
			EndIf
		EndIf
    Else
		If !Empty((cAlias)->&(cAlias+"_ALIAS"))
			If dbSelectArea(Select((cAlias)->&(cAlias+"_ALIAS"))) > 0
				If ((cAlias)->&(cAlias+"_ALIAS"))->(FieldPos(cCampo)) > 0 .And. ((cAlias)->&(cAlias+"_ALIAS")) <> "SM0"
					aTam := TamSx3(cCampo)
					If Len(aTam) > 0
						cRet:= aTam[nTipo]
					EndIf					
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE20CpC³ Autor ³ Eduardo de Souza      ³ Data ³ 16/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia do Complemento de Layout                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20CpC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Layout                                   ³±±
±±³          ³ ExpC2 = Codigo do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20CpC(cCodLay,cCodReg)

Local aCpCompl := {}
Local aCopy    := {}
Local aAreaDED := {}
Local nI       := 0
Local nCnt     := 0
Local bCampo   := {|nCPO| Field( nCPO ) }

Default cCodLay := DE0->DE0_CODLAY
Default cCodReg := DE0->DE0_CODREG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia do Complemento.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DED")
DbSetOrder(1)
MsSeek(xFilial("DED")+cCodLay+cCodReg)
While DED->(!Eof()) .And. DED->DED_FILIAL+DED->DED_CODLAY+DED->DED_CODREG == xFilial("DED")+cCodLay+cCodReg

	aAreaDED := DED->(GetArea())
	aCompl   := {}
	aCopy    := {}

	For nCnt:= 1 To FCount()
		Aadd(aCopy,FieldGet(nCnt))
	Next nCnt

	RecLock("DED",.T.)
	For nI:= 1 To FCount()
		If FieldName(nI) == 'DED_FILIAL'
			FieldPut(nI,xFilial("DED"))
		Else
			FieldPut(nI,aCopy[nI])
		EndIf
	Next nI
	DED->DED_FILIAL := xFilial("DED")
	DED->DED_CODLAY := M->DE0_CODLAY
	DED->DED_CODREG := M->DE0_CODREG
	MsUnlock()

	aCopy := {}
	RestArea( aAreaDED )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia Itens do Complemento.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("DEE")
	DbSetOrder(1)
	MsSeek(xFilial("DEE")+DED->DED_CODLAY+DED->DED_CODREG+DED->DED_SEQITE)	
	While DEE->(!Eof()) .And. DEE->DEE_FILIAL+DEE->DEE_CODLAY+DEE->DEE_CODREG+DEE->DEE_SEQITE == xFilial("DEE")+DED->DED_CODLAY+DED->DED_CODREG+DED->DED_SEQITE
	
		For nCnt:= 1 To FCount()
			Aadd(aCopy,FieldGet(nCnt))
		Next nCnt
		Aadd(aCompl,aCopy)
		aCopy := {}

		DbSkip()
	EndDo
	
	For nCnt:= 1 To Len(aCompl)
		RecLock("DEE",.T.)
		For nI:= 1 To FCount()
			If FieldName(nI) == 'DEE_FILIAL'
				FieldPut(nI,xFilial("DEE"))
			Else
				FieldPut(nI,aCompl[nCnt,nI])
			EndIf
		Next nI
		DEE->DEE_FILIAL := xFilial("DEE")
		DEE->DEE_CODLAY := M->DE0_CODLAY
		DEE->DEE_CODREG := M->DE0_CODREG
		MsUnlock()
	Next nCnt

	DbSelectArea("DED")
	DbSkip()
EndDo

Return	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSA20Ord ³ Autor ³Eduardo de Souza      ³ Data ³ 30/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reordena Itens da Configuracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA20Ord()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AE20Sequen()

Local nPos01  := 0
Local nCnt    := 0
Local cSeq    := ""
Local cCampo  := ReadVar()

If Len(aCols) > 1

	nPos01 := Ascan( aCols, { |X| X[nPosSeq] == cCampo } )
    
	If nPos01 == 0
		nPos01 := 1
		cSeq   := &(cCampo)
	Else
		cSeq := aCols[nPos01,nPosSeq]
	EndIf

	For nCnt := nPos01 To Len(aCols)
        If nCnt <> N .And. aCols[nCnt,nPosSeq] >= cSeq
			cSeq    := Soma1(cSeq)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza complemento de layout                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosTipo > 0
				If aCols[nCnt,nPosTipo] $ "2,3"
					AE20SeqComp(aCols[nCnt,nPosSeq],cSeq)
				EndIf
			EndIf
			
			aCols[nCnt,nPosSeq]:= cSeq
		EndIf
	Next nCnt			

EndIf

lOrdSeq := .T.

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AE20OrdSeq ³ Autor ³Eduardo de Souza      ³ Data ³ 30/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para auxiliar a Reordenacao dos itens     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AE20OrdSeq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AE20OrdSeq(cAlias)

Local nCnt := 0

If lOrdSeq

	aCols:= asort(aCols,,, { | x,y | x[nPosSeq] < y[nPosSeq] })

	If cAlias == "DE1"
		TMSAE20Pif(1) //-- Atualiza Posicao Inicial e Final do Layout.
	EndIf

	lOrdSeq    := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a sequencia do complemento de Layout.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AE20Grvcp(aGrvOrdDED,aGrvOrdDEE)

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AE20SeqComp³ Autor ³Eduardo de Souza      ³ Data ³ 31/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena Sequencia dos Complementos de Layout              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AE20OrdSeq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AE20SeqComp(cSeqAnt,cSeq,aCposDED,aCposDEE)

Local nPos01 := 0
Local aCpos  := {}
Local bCampo := { |nCPO| Field( nCPO ) }
Local ni

DbSelectArea("DED")
DbSetOrder(1)
If MsSeek(xFilial("DED")+M->DE0_CODLAY+M->DE0_CODREG+cSeqAnt)
	While DED->(!Eof()) .And. xFilial("DED")+M->DE0_CODLAY+M->DE0_CODREG+cSeqAnt == ;
		DED->DED_FILIAL+DED->DED_CODLAY+DED->DED_CODREG+DED->DED_SEQITE
				
		DbSelectArea("DEE")
		DbSetOrder(1)
		If MsSeek(xFilial("DEE")+DED->DED_CODLAY+DED->DED_CODREG+DED->DED_SEQITE)
			While DEE->(!Eof()) .And. xFilial("DEE")+DED->DED_CODLAY+DED->DED_CODREG+DED->DED_SEQITE == ;
				DEE->DEE_FILIAL+DEE->DEE_CODLAY+DEE->DEE_CODREG+DEE->DEE_SEQITE
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena Itens do Complemento de Layout         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nPos01:= Ascan( aGrvOrdDEE, {|x| x[2]  == DEE->(RecNo()) })) == 0
					Aadd(aGrvOrdDEE, { .F., DEE->(RecNo()), cSeq } )
				Else
					If aGrvOrdDEE[nPos01,3] <> cSeq
						aGrvOrdDEE[nPos01,1] := .F.
						aGrvOrdDEE[nPos01,3] := cSeq
					EndIf
				EndIf
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena Itens do Complemento de Layout para    ³
				//³ utilizacao no caso de cancelamento do cadastro. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aCposDEE <> NIL
					For nI := 1 To FCount()
						aADD(aCpos,&("DEE->"+Eval(bCampo,nI)))
					Next nI
					Aadd(aCposDEE,aCpos)
					aCpos := {}
				EndIf

				DbSelectArea("DEE")
				DbSkip()
			EndDo
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena Complemento de Layout                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos01:= Ascan( aGrvOrdDED, {|x| x[2]  == DED->(RecNo()) })) == 0
			Aadd(aGrvOrdDED, { .F., DED->(RecNo()), cSeq } )
		Else
			If aGrvOrdDED[nPos01,3] <> cSeq
				aGrvOrdDED[nPos01,1] := .F.
				aGrvOrdDED[nPos01,3] := cSeq
			EndIf
		EndIf
								
		DbSelectArea("DED")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena Itens do Complemento de Layout para    ³
		//³ utilizacao no caso de cancelamento do cadastro. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCposDED <> NIL
			For nI := 1 To FCount()
				aADD(aCpos,&("DED->"+Eval(bCampo,nI)))
			Next nI
			Aadd(aCposDED,aCpos)
			aCpos := {}
		EndIf

		DbSkip()
	EndDo
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AE20Grvcp ³ Autor ³Eduardo de Souza      ³ Data ³ 31/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Sequencia dos Complementos de Layout              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AE20Grvcp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AE20Grvcp(aArrayDED,aArrayDEE)

Local nCnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a sequencia do complemento de Layout.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt := 1 To Len(aArrayDED)
	If !aArrayDED[nCnt,1] //-- Verifica se ja esta atualizado

		DbSelectArea("DED")
		DbGoto(aArrayDED[nCnt,2])
	
		RecLock("DED",.F.)
		DED->DED_SEQITE := aArrayDED[nCnt,3]
		MsUnLock()
	
		aArrayDED[nCnt,1]:= .T. //-- Flag que indica que o complemento foi atualizado
	EndIf
Next nCnt
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Sequencia dos Itens de Complemento.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt := 1 To Len(aArrayDEE)
	If !aArrayDEE[nCnt,1] //-- Verifica se ja esta atualizado
	
		DbSelectArea("DEE")
		DbGoto(aArrayDEE[nCnt,2])
	
		RecLock("DEE",.F.)
		DEE->DEE_SEQITE := aArrayDEE[nCnt,3]
		MsUnLock()
	
		aArrayDEE[nCnt,1]:= .T. //-- Flag que indica que o complemento foi atualizado
	EndIf
Next nCnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAE20Vld ³ Autor ³Eduardo de Souza      ³ Data ³ 30/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE20Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE20                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE20Vld()

Local cCampo   := ReadVar()
Local lRet     := .T.
Local cIdtReg  := ""
Local aAreaDE0 := DE0->(GetArea())

If cCampo == "M->DE0_CODRCP"
	If !Empty(M->DE0_CODRCP)
		//-- Nao permite informar complemento para o recebimento.
		If Posicione("DE9",1,xFilial("DE9")+M->DE0_CODLAY,"DE9_TIPLAY") == StrZero(2,Len(DE9->DE9_TIPLAY)) //-- Recebimento
			Help("",1,"TMSAE2002") //"O registro complementar nao devera ser preenchido para layout de recebimento"
			lRet := .F.
		EndIf
		//-- Verifica se o registro existe.
		If lRet
			lRet := ExistCpo("DE3")
		EndIf
		//-- Verifica se o registro atual eh menor que o complementar.
		If lRet
			cIdtReg := Posicione("DE0",1,xFilial("DE0")+M->DE0_CODLAY+M->DE0_CODRCP,"DE0_IDTREG")
			If Empty(cIdtReg)
				Help("",1,"TMSAE2003") //"Nao foi encontrado no layout o registro complementar informado"
				lRet := .F.
			Else
				If M->DE0_IDTREG >= cIdtReg
  					Help("",1,"TMSAE2004") //"O identificador do registro atual nao pode ser maior que o identificador do registro complementar"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDE0 )

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSAE20Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE20Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSAE20Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0014,'TMSAE20Mnt',0,5,0,NIL},; //'Excluir'
								{ STR0006,'TMSAE20Mnt',0,4,0,NIL},; //'Copiar'
								{ STR0007,'TMSAE20Leg',0,6,0,.F.} } //'Legenda'


If ExistBlock("TME20MNU")
	ExecBlock("TME20MNU",.F.,.F.)
EndIf

Return(aRotina)
