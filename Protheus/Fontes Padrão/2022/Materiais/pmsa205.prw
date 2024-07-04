#include "PMSA205.ch"
#include "protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pa205Dialog³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Composicoes                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205Dialog(cAlias,nReg,nOpcx)

Local oDlg
Local l205Inclui	:= nOpcx == 3
Local lContinua		:= .T.
Local l205Visual	:= nOpcx == 2 .Or. nOpcx == 5
Local l205Altera	:= nOpcx == 4
Local l205Exclui	:= nOpcx == 5
Local aSize			:= {}
Local aObjects		:= {}
Local aPages		:= { '' }
Local nOpcA			:= 0
Local aRecAJU		:= {}
Local aRecAJV		:= {}
Local aRecAJX		:= {}
Local aRecAJURe 	:= {}
Local nRecAJT		:= AJT->( RecNo() )
Local aAuxArea		:= {}
Local aTitles		:= { 	STR0007,;	//"Insumos"
							STR0008,; 	//"Despesas"
							STR0009 }	//"Sub-Composicoes"

Local aTmpSV5  		:= {}
Local aTmp2SV5 		:= {}
Local ny 			:= 0
Local ni 			:= 0
Local nx 			:= 0
Local aButtons		:=	{}
Local aArea 		:= GetArea()
Local cFilAJT 		:= xFilial( "AJT" )
Local cFilAJU 		:= xFilial( "AJU" )
Local cFilAJV 		:= xFilial( "AJV" )
Local cFilAJX 		:= xFilial( "AJX" )
Local cFilAJY 		:= xFilial( "AJY" )

Local nPIndImp		:= 0
Local nPIndPrd		:= 0
Local nPCusPrd		:= 0
Local nPCusImp		:= 0
Local nPCustd	 	:= 0
Local nPDMT			:= 0
Local nPGrOrga		:= 0
Local nPCstItem		:= 0
Local nPQtde		:= 0

Local nAux			:= 0
Local nLenItem		:= 0

Private oGD[4]
Private oEnch
Private aHeader	 := {}
Private aCols	 := {}
Private aHeaderSV:= {{},{},{},{}}
Private aColsSV	 := {{},{},{},{}}
Private aSavN	 := {1,1,1,1}
Private aTELA[0][0]
Private aGETS[0]
Private oFolder
Private n
Private nQtSubComp	:=0

If ExistBlock("PMA205BTN")
	aButtons:= ExecBlock("PMA205BTN",.F.,.F.)
EndIf

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l205Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l205Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l205Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
      If PMSA205Del( AJT->AJT_COMPUN, AJT->AJT_PROJET, AJT->AJT_REVISA )
			l205Exclui	:= .T.
			l205Visual	:= .T.
		Else
			l205Exclui	:= .F.
			l205Visual	:= .F.						
      EndIf
EndCase

RegToMemory("AJT",l205Inclui)

// montagem do aHeaderAJU
dbSelectArea( "SX3" )
dbSetOrder( 1 )
dbSeek( "AJU" )
While !Eof() .And. ( SX3->X3_ARQUIVO == "AJU")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO) $ "AJU_RECURS")
		AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

SX3->( DbSeek( "AJU_FILIAL" ) )
cUsado := SX3->X3_USADO

AADD( aHeaderSV[1], { "Alias WT","AJU_ALI_WT", "", 09, 0,, cUsado, "C", "AJU", "V"} )
AADD( aHeaderSV[1], { "Recno WT","AJU_REC_WT", "", 09, 0,, cUsado, "N", "AJU", "V"} )

FillGetDados(nOpcx,"AJV",1,,,,,,,,{||.T.},.T.,aHeaderSV[2])
FillGetDados(nOpcx,"AJX",1,,,,,,,,{||.T.},.T.,aHeaderSV[3])

If l205Inclui
	
	// faz a montagem de uma linha em branco no aColsAJU
	aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
	For ny := 1 to Len(aHeaderSV[1])
		If Trim(aHeaderSV[1][ny][2]) == "AJU_ITEM"
			aColsSV[1][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AJU_ALI_WT | AJU_REC_WT"
			If AllTrim(aHeaderSV[1][ny][2]) == "AJU_ALI_WT"
				aColsSV[1][1][ny] := "AJU"
			ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AJU_REC_WT"
				aColsSV[1][1][ny] := 0
			EndIf
		Else
			aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
		EndIf

		aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
	Next ny
	
	// faz a montagem de uma linha em branco no aColsAJV
	aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
	For ny := 1 to Len(aHeaderSV[2])
		If Trim(aHeaderSV[2][ny][2]) == "AJV_ITEM"
			aColsSV[2][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AJV_ALI_WT | AJV_REC_WT"
			If AllTrim(aHeaderSV[2][ny][2]) == "AJV_ALI_WT"
				aColsSV[2][1][ny] := "AJV"
			ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AJV_REC_WT"
				aColsSV[2][1][ny] := 0
			EndIf
		Else
			aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
		EndIf

		aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
	Next ny
	
	// faz a montagem de uma linha em branco no aColsAJX
	aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
	For ny := 1 to Len(aHeaderSV[3])
		If Trim(aHeaderSV[3][ny][2]) == "AJX_ITEM"
			aColsSV[3][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AJX_ALI_WT | AJX_REC_WT"
			If AllTrim(aHeaderSV[3][ny][2]) == "AJX_ALI_WT"
				aColsSV[3][1][ny] := "AJX"
			ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AJX_REC_WT"
				aColsSV[3][1][ny] := 0
			EndIf
		Else
			aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
		EndIf
		aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
	Next ny
Else

	// trava o registro do AJT - Alteracao,Visualizacao
	If l205Altera .Or. l205Exclui
		If !SoftLock("AJT")
			lContinua := .F.
		Endif
	EndIf
	
	// faz a montagem do aColsAJU
	dbSelectArea("AJU")
	AJU->(dbSetOrder(1))
	AJU->(dbSeek(xFilial("AJU") + AJT->( AJT_COMPUN ) ))
	While ! AJU->(Eof()) .And. AJU->(AJU_FILIAL + AJU_COMPUN) ==;
		xFilial("AJU") + AJT->AJT_COMPUN .And. lContinua

		If AJU->( AJU_PROJET + AJU_REVISA ) <> AJT->( AJT_PROJET + AJT_REVISA ) 
			AJU->( DbSkip() )
			Loop
		EndIf
		
		// trava o registro do AJU - Alteracao, Exclusao
		If l205Altera .Or. l205Exclui
			If !SoftLock("AJU")
				lContinua := .F.
			Else
				aAdd(aRecAJU,RecNo())
			Endif
		EndIf

		AJY->(dbSetOrder(1))
		If AJY->(dbSeek(xFilial("AJY") + AJU->AJU_PROJET + AJU->AJU_REVISA + AJU->AJU_INSUMO))
			aAdd( aColsSV[ 1 ], Array( Len( aHeaderSV[ 1 ] ) + 1 ) )
		
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_TIPO"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_TIPO
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_DESCRI"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_DESC
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_UM"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_UM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_SEGUM"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_SEGUM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_GRORGA"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_GRORGA
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_SIMBCS"
							If !Empty(AJU->AJU_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := GetMV("MV_SIMB"+ AJY->AJY_MCUSTD)
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_CUSTD"
							aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_CUSTD
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_CUSPRD"
							aColsSV[1][Len(aColsSV[1])][ny] := AJY->AJY_CUSTD
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_ALI_WT"
							aColsSV[1][Len(aColsSV[1])][ny] := "AJU"
						Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_REC_WT"
							aColsSV[1][Len(aColsSV[1])][ny] := AJU->(Recno())
						OtherWise
							aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
					EndCase
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny
			// Atualiza o custo conforme horas produtivas/improdutivas com todos os campos do acol preenchido
			nLenItem 	:= Len( aColsSV[1] )
			nPIndImp	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_HRIMPR" } )
			nPIndPrd	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_HRPROD" } )
			nPCusPrd	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_CUSPRD" } )		
			nPCusImp	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_CUSIMP" } ) 
			nPCustd 	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_CUSTD"  } )
			nPDMT		:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_DMT"		} )
			nPGrOrga	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_GRORGA" 	} )
			nPCstItem	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_CSTITM" 	} )
			nPQtde		:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AJU_QUANT" 	} )

			For ny := 1 to Len(aHeaderSV[1])
				Do Case
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AJU_CUSPRD" .AND. ( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						aColsSV[1][nLenItem][nPCusPrd]	:= 0
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AJU_HRPROD" .AND. !( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						nAux	:= aColsSV[1][nLenItem][nPIndPrd]
						aColsSV[1][nLenItem][nPCustd]	:= (aColsSV[1][nLenItem][nPCusPrd] * nAux) + (aColsSV[1][nLenItem][nPCusImp] * aColsSV[1][nLenItem][nPIndImp])	
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AJU_HRIMPR" .AND. !( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						nAux	:= aColsSV[1][nLenItem][nPIndImp]
						aColsSV[1][nLenItem][nPCustd]	:= (aColsSV[1][nLenItem][nPCusPrd] * aColsSV[1][nLenItem][nPIndPrd]) + (aColsSV[1][nLenItem][nPCusImp] * nAux)
				EndCase
			Next

			// Atualiza o custo conforme DMT
			nLenItem := Len( aColsSV[1] )
			For ny := 1 to Len(aHeaderSV[1])
				Do Case
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AJU_DMT" .AND. !( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*" )
						nAux	:= aColsSV[1][nLenItem][nPDMT]
						If nAux > 0
							aColsSV[1][nLenItem][nPCstItem]	:= aColsSV[1][nLenItem][nPQtde] * aColsSV[1][nLenItem][nPCustd] * nAux
						EndIf
				EndCase
			Next
		EndIf
		
		AJU->(dbSkip())
	EndDo
	
	// faz a montagem de uma linha em branco no aColsAJU
	If Empty(aColsSV[1])
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			
			If Trim(aHeaderSV[1][ny][2]) == "AJU_ITEM"
				aColsSV[1][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AJU_ALI_WT | AJU_REC_WT"
				If AllTrim(aHeaderSV[1][ny][2]) == "AJU_ALI_WT"
					aColsSV[1][1][ny] := "AJU"
				ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AJU_REC_WT"
					aColsSV[1][1][ny] := 0
				EndIf
			Else
				aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf

			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf
	
	// faz a montagem do aColsAJV
	DbSelectArea("AJV")
	AJV->( DbSetOrder( 2 ) )
	If AJV->( DbSeek(xFilial("AJV") + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ))
		While !AJV->( Eof() ) .AND. AJV->(AJV_FILIAL + AJV_PROJET + AJV_REVISA + AJV_COMPUN) == xFilial("AJV") + AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN ) .And. lContinua
			// trava o registro do AJV - Alteracao,Exclusao
			If l205Altera.Or.l205Exclui
				If !SoftLock("AJV")
					lContinua := .F.
				Else
					aAdd(aRecAJV,RecNo())
				Endif
			EndIf
			
			aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
			For ny := 1 to Len(aHeaderSV[2])
				SX5->(dbSetOrder(1))
				SX5->(dbSeek(xFilial()+"02"+AJV->AJV_TIPOD))
				If ( aHeaderSV[2][ny][10] != "V")
					aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
				Else
					Do Case
						Case Alltrim(aHeaderSV[2][ny][2]) == "AJV_DESCTP"
							aColsSV[2][Len(aColsSV[2])][ny] := X5DESCRI()
						Case Alltrim(aHeaderSV[2][ny][2]) == "AJV_SIMBMO"
							aColsSV[2][Len(aColsSV[2])][ny] := GetMv("MV_SIMB"+Alltrim(STR(AJV->AJV_MOEDA,2,0)))
						Case AllTrim(aHeaderSV[2][ny][2]) == "AJV_ALI_WT"
							aColsSV[2][Len(aColsSV[2])][ny] := "AJV"
						Case AllTrim(aHeaderSV[2][ny][2]) == "AJV_REC_WT"
							aColsSV[2][Len(aColsSV[2])][ny] := AJV->(Recno())
						OtherWise
							aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
					EndCase
				EndIf
				aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
			Next ny
			AJV->(dbSkip())
		EndDo
	EndIf

	// faz a montagem de uma linha em branco no aColsAJV
	If Empty(aColsSV[2])
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AJV_ITEM"
				aColsSV[2][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AJV_ALI_WT | AJV_REC_WT"
				If AllTrim(aHeaderSV[2][ny][2]) == "AJV_ALI_WT"
					aColsSV[2][1][ny] := "AJV"
				ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AJV_REC_WT"
					aColsSV[2][1][ny] := 0
				EndIf
			Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf
	
	// faz a montagem do aColsAJX
	dbSelectArea("AJX")
	AJX->( DbSetOrder( 2 ) )
	If AJX->( DbSeek( xFilial("AJX") +  AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
		While AJX->( !Eof() ) .AND. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial("AJX") + AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN ) .And. lContinua
			// posiciona na Sub-Composicao
			aAuxArea := AJT->(GetArea()	)
			AJT->(dbSetOrder(1))
			AJT->(dbSeek(xFilial("AJT") + AJX->AJX_SUBCOM))
			dbSelectArea("AJX")
			
			// trava o registro do AJX - Alteracao,Exclusao
			If l205Altera .Or. l205Exclui
				If !SoftLock("AJX")
					lContinua := .F.
				Else
					aAdd(aRecAJX,RecNo())
				Endif
			EndIf
			
			aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
			For ny := 1 to Len(aHeaderSV[3])
				If ( aHeaderSV[3][ny][10] != "V")
					aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
				Else
					Do Case
						
						Case Alltrim(aHeaderSV[3][ny][2]) == "AJX_DESCRI"
							aColsSV[3][Len(aColsSV[3])][ny] := AJT->AJT_DESCRI
							
						Case Alltrim(aHeaderSV[3][ny][2]) == "AJX_UM"
							aColsSV[3][Len(aColsSV[3])][ny] := AJT->AJT_UM
							
						Case AllTrim(aHeaderSV[3][ny][2]) == "AJX_ALI_WT"
							aColsSV[3][Len(aColsSV[3])][ny] := "AJX"
							
						Case AllTrim(aHeaderSV[3][ny][2]) == "AJX_REC_WT"
							aColsSV[3][Len(aColsSV[3])][ny] := AJX->(Recno())
							
						OtherWise
							aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
					EndCase
				EndIf
				aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
			Next ny
			RestArea(aAuxArea)
			AJX->(dbSkip())
		EndDo
	EndIf

	// faz a montagem de uma linha em branco no aColsAJV
	If Empty(aColsSV[3])
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AJX_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AJX_ALI_WT | AJX_REC_WT"
				If AllTrim(aHeaderSV[3][ny][2]) == "AJX_ALI_WT"
					aColsSV[3][1][ny] := "AJX"
				ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AJX_REC_WT"
					aColsSV[3][1][ny] := 0
				EndIf
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	Else
		nQtSubComp := Len( aColsSV[ 3 ] )
	EndIf
EndIf

// valida se utiliza o template CCT
If lUsaCCT
	If ExistTemplate("CCTAJUINI")
		ExecTemplate("CCTAJUINI",.F.,.F., { "AJT" } )
	EndIf
EndIf

// faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize(,.F.,370)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If (l205Inclui .Or. l205Altera .Or. l205Exclui .Or. l205Visual) .AND. lConfirma
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	Zero()
	oEnch:= MsMGet():New(cAlias, nReg, nOpcx,,,,,aPosObj[1],,,,,,oDlg,,.T.,.F.,,.T. )
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
	oFolder:bSetOption:={|nFolder| a205SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@oGD)}
	
	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[1])
	aCols		:= aClone(aColsSV[1])
	oGD[1]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"a205GD1LinOk","a205GD1TudOk","+AJU_ITEM",.T.,,1,,300,"a205FdOkA",,,"a205GDDel(1)",oFolder:aDialogs[1])
	
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[2])
	aCols		:= aClone(aColsSV[2])
	oGD[2]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"a205GD2LinOk","a205GD2TudOK","+AJV_ITEM",.T.,,1,,300,"a205FdOkB",,,"a205GDDel(2)",oFolder:aDialogs[2])
	
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[3])
	aCols		:= aClone(aColsSV[3])
	oGD[3]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"a205GD3LinOk","a205GD3TudOK","+AJX_ITEM",.T.,,1,,300,"a205FdOkC",,,"a205GDDel(3)",oFolder:aDialogs[3])
	
	aHeader		:= aClone(aHeaderSV[1])
	aCols		:= aClone(aColsSV[1])
	
	If l205Inclui .OR. l205Altera
		//aAdd( aButtons, { "SALVAR", { || IIf( l205Exclui .OR. ( Obrigatorio(aGets,aTela) .And.AGDTudok(1,oFolder).And.AGDTudok(2,oFolder).And.AGDTudok(3,oFolder) ), ( A205SetOption( NIL, oFolder:nOption, @aCols, @aHeader, @oGD ), a205Grava( .F., nRecAJT, aRecAJU, aRecAJV, aRecAJX, l205Altera, aRecAJURe ), A205SetOption( oFolder:nOption, oFolder:nOption, @aCols, @aHeader, @oGD ) ), NIL ) }, STR0025 } )
		aAdd( aButtons, { "SALVAR", { || Pma205Salvar( l205Exclui, aGets, aTela, oFolder, @aCols, @aHeader, @oGD, , nRecAJT, aRecAJU, aRecAJV, aRecAJX, l205Altera, aRecAJURe ) }, STR0025 } )
    EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If( l205Exclui .OR. ( Obrigatorio(aGets,aTela) .And.AGDTudok(1,oFolder).And.AGDTudok(2,oFolder).And.AGDTudok(3,oFolder) ) ,(nOpcA:=1,oDlg:End()),Nil)},{||Eval(oFolder:bSetOption),oDlg:End()},,aButtons)
EndIf	

If ( ( l205Inclui .Or.l205Altera .Or. l205Exclui ) .And. nOpcA == 1 ) .OR. !lConfirma
	a205Grava(l205Exclui,nRecAJT)
EndIf
	A205Cancel()

If ExistBlock("PMa205GRV")
	ExecBlock("PMa205GRV",.F.,.F., {l205Inclui,l205Altera,l205Exclui,(nOpcA==1)} )
EndIf

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA205                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a205SetOption(nFolder,nOldFolder,aCols,aHeader,oGD)

If nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])
	// salva o conteudo da GetDados se existir
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint := .T.
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])
	// restaura o conteudo da GetDados se existir
	oGD[nFolder]:oBrowse:lDisablePaint := .F.
	aCols	:= aClone(aColsSV[nFolder])
	aHeader := aClone(aHeaderSV[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205GD1LinOk()

Local nPosProd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_INSUMO" } )
Local nPosQT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_QUANT"  } )
Local nContItem := 1
Local lRet 		:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosProd])
		Help("  ",1,"PMSA0101")
		lRet := .F.
	EndIf
	
//	If lRet .And. Empty(aCols[n][nPosQT])
//		HELP("  ",1,"PMSA0102")
//		lRet := .F.
//	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica duplicidade de insumos na composicao Aux.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aCols ) > 0 .AND. nPosProd > 0 .AND. !Empty( aCols[ n ][ nPosProd ] )
		For nContItem := 1 To Len( aCols )
			If n <> nContItem .AND. aCols[ n ][ nPosProd ] == aCols[ nContItem ][ nPosProd ] .AND. !aCols[ nContItem ][ Len( aCols[ nContItem ] ) ]
				Aviso( STR0026, STR0053, { "Ok" } ) // "Não é permitido duplicidade de insumos em uma composição aux!"
				lRet := .F.
	
				Exit
			EndIf
		Next
	EndIf
EndIf

If lRet
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205GD2LinOk()

Local nPosDescri	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_DESCRI" } )
Local nPosValor		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_VALOR"  } )
Local nPosTP		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_TIPOD"  } )
Local lRet			:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosDescri])
		Help("  ",1,"PMSA0103")
		lRet := .F.
	EndIf
	If lRet .And. Empty(aCols[n][nPosValor])
		HELP("  ",1,"PMSA0104")
		lRet := .F.
	EndIf
	If lRet .And. Empty(aCols[n][nPosTP])
		HELP("  ",1,"PMSA0105")
		lRet := .F.
	EndIf
EndIf

If lRet
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 3.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205GD3LinOk()
Local nPosSubC	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJX_SUBCOM" } )
Local nContItem := 1
Local lRet 		:= .T.

If lRet
	If !aCols[n, Len( aCols[n] ) ]
	For nContItem := 1 to Len(aCols)
		If ! aCols[nContItem,Len(aCols[nContItem])] .And. nContItem <> n
			If aCols[nContItem,nPosSubC] == aCols[n,nPosSubC]
				Aviso(STR0026,STR0028,{"Ok"})
				lRet := .F.
				Exit
			EndIf
		EndIf

			If aCols[nContItem,nPosSubC] == M->AJT_COMPUN
				Aviso( STR0026, STR0063,{ "Ok" } )
				lRet := .F.
				Exit
			EndIf
	Next
	EndIf
EndIf

If lRet
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

Return(lRet)

/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Função    ³AGDTudOk³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
//±±³          ³ TudOk da GetDados                                            ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(nGetDados,oFolder)

Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local lRet			:= .T.
Local aArea         := GetArea()

Eval(oFolder:bSetOption)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.

aCols			:= aClone(aColsSV[nGetDados])
aHeader			:= aClone(aHeaderSV[nGetDados])
n				:= aSavN[nGetDados]
oFolder:nOption	:= nGetDados

Do Case
	Case nGetDados == 1
		lRet := a205GD1Tudok()
	Case nGetDados == 2
		lRet := a205GD2Tudok()
	Case nGetDados == 3
		lRet := a205GD3Tudok()
EndCase

// valida se utiliza o template CCT
If lUsaCCT .And. nGetDados == 1
	If ExistTemplate("CCTAJTCUST")
		ExecTemplate("CCTAJTCUST",.F.,.F.,{ nGetDados,, "AJT" } )
	EndIf
EndIf

aColsSV[nGetDados] := aClone(aCols)
aHeaderSV[nGetDados] := aClone(aHeader)

If nGetDados != oFolder:nOption
	aCols	:= aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		:= nSavN
EndIf

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados 1                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function a205GD1TudOk()
	Local nPosProd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_INSUMO" } )
	Local nPosQT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_QUANT"  } )
	Local nSavN		:= n
	Local lRet		:= .T.
	Local nx 		:= 0
	
	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosProd ] ) .Or. !Empty( aCols[ n ][ nPosQT ] )
			If !a205GD1LinOk()
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	
	n := nSavN
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a205GD2TudOk()
	Local nPosDescri	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_DESCRI" } )
	Local nPosValor		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_VALOR"  } )
	Local nPosTP		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_TIPOD"  } )
	Local nSavN			:= n
	Local lRet			:= .T.
	Local nx 			:= 0

	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosDescri ] ) .Or. !Empty( aCols[ n ][ nposValor ] ) .Or. !Empty( aCols[ n ][ nPosTP ] )
			If !a205GD2LinOk()
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	
	n := nSavN
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a205GD3TudOk()
	Local nPosSubCmp 	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJX_SUBCOM" } )
	Local nSavN			:= n
	Local lRet			:= .T.
	Local nx 			:= 0
	
	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosSubCmp ] )
			If !a205GD3LinOk()
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	
	n := nSavN
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205Grava³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a gravaco da composicao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA205.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205Grava(lExclui,nRecAJT, cProjet, cRevisa, cCompun )
	Local aArea			:= GetArea()
	Local aAreaAJT		:= AJT->(GetArea())
	Local aAreaAJU		:= AJU->(GetArea())
	Local aAreaAJV		:= AJV->(GetArea())
	Local aAreaAJX		:= AJX->(GetArea())
	Local bCampo		:= { |n| FieldName( n ) }
	Local cCodiSubC 	:= ""
	Local cInsumo		:= ""
	Local cSubCom		:= ""
	Local nPosProd		:= 0
	Local nPosDescri	:= 0
	Local nPosSubCmp	:= 0
	Local nPosItem1		:= 0
	Local nPosItem2		:= 0
	Local nPosItem3		:= 0
	Local nCntFor
	Local nCntFor2
	Local nx
	Local nTotCampos

	Default cProjet		:= M->AJT_PROJET
	Default cRevisa 	:= M->AJT_REVISA
	Default cCompun		:= M->AJT_COMPUN

	Begin Transaction

	If ! lExclui
	
		If Type("aHeaderSV") == 'A'
			nPosProd	:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AJU_INSUMO" } )
			nPosDescri	:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AJV_DESCRI" } )
			nPosSubCmp	:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AJX_SUBCOM" } )
			nPosItem1	:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AJU_ITEM"   } )
			nPosItem2	:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AJV_ITEM"   } )
			nPosItem3	:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AJX_ITEM"   } )
		EndIf

		// grava arquivo AJT (Composicoes)
		DbSelectArea( "AJT" )
		AJT->( DbSetOrder( 2 ) )
		If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) ) 
			RecLock( "AJT" )
		Else
			RecLock( "AJT", .T. )
		EndIf

		For nCntFor := 1 To FCount()
			If "FILIAL" $ Field( nCntFor )
				FieldPut( nCntFor, xFilial( "AJT" ) )
			Else
				FieldPut( nCntFor, M->&( Eval( bCampo, nCntFor ) ) )
			EndIf
		Next nCntFor

		AJT->AJT_FILIAL	:= xFilial( "AJT" )
		AJT->AJT_PROJET	:= cProjet
		AJT->AJT_REVISA	:= cRevisa
		AJT->AJT_COMPUN	:= cCompun
		AJT->AJT_ULTATU	:= MsDate()
		AJT->( MsUnlock() )
		
		// grava arquivo AJU (Insumos)
		DbSelectArea("AJU")
		AJU->( DbSetOrder( 2 ) )
		For nCntFor := 1 To Len( aColsSV[ 1 ] )
			nTotCampos := Len( aColsSV[ 1 ][ nCntFor ] )
			If !aColsSV[ 1 ][ nCntFor ][ nTotCampos ]
				If !Empty( aColsSV[ 1 ][ nCntFor ][ nPosProd ] )
					If AJU->( DbSeek( xFilial( "AJU" ) + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[ 1 ][ nCntFor ][ nPosItem1 ] ) )
						RecLock( "AJU", .F. )
					Else
						RecLock( "AJU", .T. )
					EndIf

					For nCntFor2 := 1 To Len( aHeaderSV[ 1 ] )
						If ( aHeaderSV[1][nCntFor2][8] != "V" )
							AJU->(FieldPut(FieldPos(aHeaderSV[1][nCntFor2][2]),aColsSV[1][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AJU->AJU_FILIAL	:= xFilial( "AJU" )
					AJU->AJU_PROJET	:= cProjet
					AJU->AJU_REVISA	:= cRevisa
					AJU->AJU_COMPUN	:= cCompun
					AJU->( MsUnlock() )
				EndIf
			Else
				If AJU->(dbSeek(xfilial("AJU") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[1][nCntFor][nPosItem1]))
					cInsumo	:= AJU->AJU_INSUMO

					RecLock("AJU",.F.,.T.)
					AJU->( DbDelete() )
					AJU->( MsUnlock() )
					If !PA204UsaInsumo( M->AJT_PROJET, M->AJT_REVISA, cInsumo, .F. )
						PA204Exc( M->AJT_PROJET, M->AJT_REVISA, cInsumo, .T. )
					EndIf
				EndIf
			EndIf
		Next nCntFor

		// grava arquivo AJV (Despesas)
		dbSelectArea( "AJV" )
		AJV->( DbSetOrder( 2 ) )
		For nCntFor := 1 To Len( aColsSV[ 2 ] )
			nTotCampos := Len( aColsSV[ 2 ][ nCntFor ] )
			If !aColsSV[ 2 ][ nCntFor ][ nTotCampos ]
				If !Empty(aColsSV[2][nCntFor][nPosDescri])
					If AJV->(dbSeek(xfilial("AJV") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[2][nCntFor][nPosItem2]))
						RecLock("AJV",.F.)
					Else
						RecLock("AJV",.T.)
					EndIf

					For nCntFor2 := 1 To Len(aHeaderSV[2])
						If ( aHeaderSV[2][nCntFor2][8] != "V" )
							AJV->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AJV->AJV_FILIAL	:= xFilial("AJV")
					AJV->AJV_PROJET	:= cProjet
					AJV->AJV_REVISA	:= cRevisa
					AJV->AJV_COMPUN	:= cCompun
					MsUnlock()
				EndIf
			Else
				If AJV->(dbSeek(xfilial("AJV") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[2][nCntFor][nPosItem2]))
					RecLock("AJV",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
		
		// grava arquivo AJX (SubComposicoes)
		dbSelectArea("AJX")
		AJX->(dbSetOrder(2))
		For nCntFor := 1 To Len( aColsSV[ 3 ] )
			aAreaAJT	:= AJT->( GetArea() )
			nTotCampos	:= Len( aColsSV[ 3 ][ nCntFor ] )
			If !aColsSV[ 3 ][ nCntFor ][ nTotCampos ]
				If !Empty(aColsSV[3][nCntFor][nPosSubCmp])
					If AJX->(dbSeek(xfilial("AJX") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[3][nCntFor][nPosItem3]))
						RecLock("AJX",.F.)
					Else
						RecLock("AJX",.T.)
					EndIf

					For nCntFor2 := 1 To Len(aHeaderSV[3])
						If ( aHeaderSV[3][nCntFor2][8] != "V" )
							AJX->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AJX->AJX_FILIAL	:= xFilial( "AJX" )
					AJX->AJX_PROJET	:= cProjet
					AJX->AJX_REVISA	:= cRevisa
					AJX->AJX_COMPUN	:= cCompun
					AJX->( MsUnlock() )
				EndIf
			Else
				If AJX->(dbSeek(xfilial("AJX") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[3][nCntFor][nPosItem3]))
					RecLock("AJX",.F.,.T.)
					AJX->( DbDelete() )
					AJX->( MsUnlock() )

					If PMSA205Del( AJX->AJX_SUBCOM, M->AJT_PROJET, M->AJT_REVISA, .F. )
						DbSelectArea( "AJT" )
						AJT->( DbSetOrder( 2 ) )
						If AJT->( DbSeek( xFilial( "AJT" ) + M->AJT_PROJET + M->AJT_REVISA + AJX->AJX_SUBCOM ) )
							a205Grava( .T., AJT->( RecNo() ) )
						EndIf
					EndIf
				EndIf
			EndIf
			
			AJT->( RestArea( aAreaAJT ) )
		Next nCntFor
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui registros referentes a composicao Aux  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "AJT" )
		AJT->( DbGoTo( nRecAJT ) )
		If AJT->( !Eof() )
			DbSelectArea("AJU")
			AJU->( DbSetOrder( 3 ) )
			While AJU->( DbSeek( xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
				cInsumo	:= AJU->AJU_INSUMO

				RecLock( "AJU" )
				AJU->( DbDelete() )
				AJU->( MsUnlock() )

				If !PA204UsaInsumo( AJT->AJT_PROJET, AJT->AJT_REVISA, cInsumo, .F. )
					PA204Exc( AJT->AJT_PROJET, AJT->AJT_REVISA, cInsumo, .T. )
				EndIf

				AJU->( DbSkip() )
			End

			DbSelectArea( "AJV" )
			AJV->( DbSetOrder( 2 ) )
			While AJV->( DbSeek( xFilial( "AJV" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
				RecLock( "AJV" )
				AJV->( DbDelete() )
				AJV->( MsUnlock() )

				AJV->( DbSkip() )
			End

			aAreaAJT	:= AJT->( GetArea() )

			DbSelectArea( "AJX" )
			AJX->( DbSetOrder( 2 ) )
			While AJX->( DbSeek( xFilial( "AJX" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
				cSubCom	:= AJX->AJX_SUBCOM
				
				RecLock( "AJX" )
				AJX->( DbDelete() )
				AJX->( MsUnlock() )

				If PMSA205Del( cSubCom, AJT->AJT_PROJET, AJT->AJT_REVISA, .F. )
					DbSelectArea( "AJT" )
					AJT->( DbSetOrder( 2 ) )
					If AJT->( DbSeek( xFilial( "AJT" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + cSubCom ) )
						a205Grava( .T., AJT->( RecNo() ), AJT->AJT_PROJET, AJT->AJT_REVISA, cSubCom )
					EndIf
					
					AJT->( RestArea( aAreaAJT ) )
				EndIf

				AJX->( DbSkip() )
			End

			AJT->( DbGoTo( nRecAJT ) )

			RecLock( "AJT" )
			AJT->( DbDelete() )
			AJT->( MsUnlock() )
		EndIf
	EndIf

	End Transaction

	RestArea(aAreaAJT)
	RestArea(aAreaAJU)
	RestArea(aAreaAJV)
	RestArea(aAreaAJX)
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Pa205Dupl  ºAutor³ Totvs                     º Data ³ 15/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Duplica a composicao Aux para um novo codigo                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Pa205Dupl(cAlias,nReg,nOpcx)                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Apelido do arquivo                                          º±±
±±º          ³ ExpN2 - Número do registro a ser copiado                            º±±
±±º          ³ ExpN3 - Opção do arotina                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205Dupl( cAlias, nReg, nOpcx )
	Local aCampoAJT	:= {}
	Local aCampoAJU	:= {}
	Local aCampoAJV	:= {}
	Local aCampoAJX	:= {}
	Local aStruct	:= {}
	Local aRegs		:= {}
	Local nCount	:= 0
	Local nInc		:= 0
	Local nFieldPos	:= 0
	Local nTamField	:= TamSX3( "AJT_COMPUN" )[1]
	Local nRegAJT	:= AJT->( RecNo() )

	If ParamBox( { { 1, STR0022, Space( nTamField ), "@!", "", "AJT001", "", 40, .T. } }, STR0019,, )
		If AJT->( DbSeek( xFilial( "AJT" ) + MV_PAR01 ) )
			Alert( STR0060 ) // "O código da composição aux já existe! Informe um novo código."
			Return
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena a composicao Aux em array para posteriormente   ³
		//³duplicar alterando o codigo informado na ParamBox        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AJT->( DbGoTo( nRegAJT ) )
		aEval( AJT->( DbStruct() ), { |x| aAdd( aCampoAJT, AJT->( FieldGet( FieldPos( x[1] ) ) ) ) } )

		AJU->( DbSetOrder( 3 ) )
		If AJU->( DbSeek( xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
			aStruct := AJU->( DbStruct() )
			While AJU->( !Eof() ) .AND. AJU->AJU_FILIAL == xFilial( "AJU" ) .AND. AJU->( AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN )
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AJU->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AJU->( FieldPos( "AJU_COMPUN" ) )
				aRegs[ nFieldPos ] := MV_PAR01
			
				aAdd( aCampoAJU, aClone( aRegs ) )

				AJU->( DbSkip() )
			End
		EndIf
		
		AJV->( DbSetOrder( 2 ) )
		If AJV->( DbSeek( xFilial( "AJV" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
			aStruct := AJV->( DbStruct() )
			While AJV->( !Eof() ) .AND. AJV->AJV_FILIAL == xFilial( "AJV" ) .AND. AJV->( AJV_PROJET + AJV_REVISA + AJV_COMPUN ) == AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN )
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AJV->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AJV->( FieldPos( "AJV_COMPUN" ) )
				aRegs[ nFieldPos ] := MV_PAR01

				aAdd( aCampoAJV, aClone( aRegs ) )
				AJV->( DbSkip() )
			End
		EndIf

		AJX->( DbSetOrder( 2 ) )
		If AJX->( DbSeek( xFilial( "AJX" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
			aStruct := AJX->( DbStruct() )
			While AJX->( !Eof() ) .AND. AJX->AJX_FILIAL == xFilial( "AJX" ) .AND. AJX->( AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN )
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AJX->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AJX->( FieldPos( "AJX_COMPUN" ) )
				aRegs[ nFieldPos ] := MV_PAR01

				aAdd( aCampoAJX, aClone( aRegs ) )
				AJX->( DbSkip() )
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a gravacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
		Reclock("AJT",.T.)
		For nCount := 1 to Len( aCampoAJT )
			FieldPut( nCount, aCampoAJT[ nCount ] )
		Next

		AJT->AJT_FILIAL := xFilial( "AJT" )
		AJT->AJT_COMPUN := MV_PAR01
		AJT->( MsUnlock() )

		For nInc := 1 To Len( aCampoAJU )
			Reclock( "AJU", .T. )
			For nCount := 1 to Len( aCampoAJU[ nInc ] )
				FieldPut( nCount, aCampoAJU[ nInc ][ nCount ] )
			Next

			AJU->AJU_FILIAL := xFilial( "AJU" )
			AJU->( MsUnlock() )
		Next

		For nInc := 1 To Len( aCampoAJV )
			Reclock( "AJV", .T. )
			For nCount := 1 to Len( aCampoAJV[ nInc ] )
				FieldPut( nCount, aCampoAJV[ nInc ][ nCount ] )
			Next

			AJV->AJV_FILIAL := xFilial( "AJV" )
			AJV->( MsUnlock() )
		Next

		For nInc := 1 To Len( aCampoAJX )
			Reclock( "AJX", .T. )
			For nCount := 1 to Len( aCampoAJX[ nInc ] )
				FieldPut( nCount, aCampoAJX[ nInc ][ nCount ] )
			Next

			AJX->AJX_FILIAL := xFilial( "AJX" )
			AJX->( MsUnlock() )
		Next

		End Transaction		
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Pa205Imp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Importacao de composicoa Aux                                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Pa205Imp(cAlias,nReg,nOpcx)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Codigo do Projeto                                           º±±
±±º          ³ ExpC2 - Revisao do Projeto                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205Imp( cProjet, cRevisa, cCompun, cTarefa )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aCodCU	:= {}				// Array com as composicoes Aux selecionadas
	Local aCodPrj	:= {}				// Array com os projetos selecionados
	Local aCriticas	:= {}				// Array com os projetos onde as composicoes Aux ja existem
	Local aExport  	:= {}				// Array com as composicoes a serem exportadas com seus respectivos projetos
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local aInsumos	:= {}
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar as composicoes Aux
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncCU	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local nInsu		:= 0
	Local lNewRec	:= .F.
	Local oDlg
	Local oPMSA2051	:= Nil
	Local oPMSA2052	:= Nil

	Local oPanel
	Local oGet
	Local cProcura
	Local oButton

	Default cCompun	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta as composicoes Aux disponiveis para exportacao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	If Empty( cCompun )
		aTrab	:= {	{ "OK"    , "C", 1, 							0 },;
						{ "CODIGO", "C", TamSX3( "AEG_COMPUN" )[1],	0 },;
						{ "DESCR"  , "C", TamSX3( "AEG_DESCRI" )[1], 	0 }}
				
		oPMSA2051 := FWTemporaryTable():New( "TRB" )  
		oPMSA2051:SetFields(aTrab) 
		oPMSA2051:AddIndex("1", {"CODIGO"})
	
		//------------------
		//Criação da tabela temporaria
		//------------------
		oPMSA2051:Create()

		Processa( { || MontaTRBImp() }, STR0050 ) // "Selecionando composicoes Aux para exportacao... Aguarde!"

		DbSelectArea( "TRB" )
		TRB->( DbGoTop() )
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL

		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

		cProcura := space(TamSX3( "AJT_COMPUN")[1]+TamSX3( "AJT_PROJET" )[1])
		@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
		oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(alltrim(cProcura))) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

		aCpos := {	{ "OK"    , "", "", ""}, ;
					{ "CODIGO", "", A093RetDescr( "AEG_COMPUN" ), "" },;
					{ "DESCR"  , "", A093RetDescr( "AEG_DESCRI" ), "" } }

		oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
		oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:lCanAllMark	:= .T.
		oMark:oBrowse:bAllMark		:= { || PMA205Inv( cMarca, .T., oMark ) }
	
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) ) CENTERED
	
		If lOk
			TRB->( DbGoTop() )
			While TRB->( !Eof() )
				If TRB->OK == "X"
					aAdd( aCodCU, { TRB->CODIGO, TRB->DESCR } )
				EndIf
			
				TRB->( DbSkip() )
			End
		EndIf
	
		If oPMSA2051 <> Nil
			oPMSA2051:Delete()
			oPMSA2051 := Nil
		Endif
	Else
		DbSelectArea( "AEG" )
		AEG->( DbSetOrder( 1 ) )
		If AEG->( DbSeek( xFilial( "AEG" ) + cCompun ) )
			aAdd( aCodCU, { cCompun, AEG->AEG_DESCRI } )
		EndIf
	EndIf
	
	If Len( aCodCU ) > 0
		DbSelectArea( "AF8" )
		AF8->( DbSetOrder( 1 ) )
		If AF8->( DbSeek( xFilial( "AF8" ) + cProjet ) )
			aAdd( aCodPrj, { cProjet, cRevisa, AF8->AF8_DESCRI } )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se no projeto selecionado existe alguma composicao³
	//³selecionada e questiona se deve substituir ou manter.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aCodCU ) .AND. !Empty( aCodPrj )
		For nIncPrj := 1 To Len( aCodPrj )
			DbSelectArea( "AF8" )
			AF8->( DbSetOrder( 1 ) )
			If AF8->( DbSeek( xFilial( "AF8" ) + aCodPrj[ nIncPrj ][ 1 ] ) )
				For nIncCU := 1 To Len( aCodCU )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica na tabela AJT-Composicoes Aux do Projeto se a    ³
					//³composicao a ser exportada ja existe para aquele projeto  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea( "AJT" )
					AJT->( DbSetOrder( 2 ) )
					If AJT->( DbSeek( xFilial( "AJT" ) + aCodPrj[ nIncPrj ][1] + aCodPrj[ nIncPrj ][2] + aCodCU[ nIncCU ][1] ) )
						aAdd( aCriticas, { aCodCU[ nIncCU ][1], aCodCU[ nIncCU ][2], aCodPrj[ nIncPrj ][1], aCodPrj[ nIncPrj ][3], aCodPrj[ nIncPrj ][2] }  ) // Composicao Aux, Desc CU, Projeto, Desc Prj
					Else
						aAdd( aExport, { aCodPrj[ nIncPrj ][1], aCodPrj[ nIncPrj ][2], aCodCU[ nIncCU ][1] }  ) // Projeto, Revisao, Composicao Aux

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui as sub-composicoes das composicoes que devem ³
						//³obrigatoriamente serem exportadas.                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA205IncSub( aCodPrj[ nIncPrj ][1], aCodPrj[ nIncPrj ][2], aCodCU[ nIncCU ][1], @aExport, .F. ) // Projeto, Revisa, Composicao Aux
					EndIf
				Next
			EndIf
		Next

		If !Empty( aCriticas )
			Alert( STR0051 + chr(13) + chr(10) + STR0052 )
	
			aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
								{ "COMPUN", "C", TamSX3( "AEG_COMPUN" )[1],	0 },;
								{ "DESCCU", "C", TamSX3( "AEG_DESCRI" )[1],	0 },;
								{ "PROJET", "C", TamSX3( "AF8_PROJET" )[1],	0 },;
								{ "DESCPR", "C", TamSX3( "AF8_DESCRI" )[1],	0 },;
								{ "REVISA", "C", TamSX3( "AF8_REVISA" )[1],	0 }}
		
					
			oPMSA2052 := FWTemporaryTable():New( "TRB" )  
			oPMSA2052:SetFields(aTrab) 
			oPMSA2052:AddIndex("1", {"COMPUN","PROJET"})
		
			//------------------
			//Criação da tabela temporaria
			//------------------
			oPMSA2052:Create()
		
			For nInc := 1 To Len( aCriticas )
				RecLock( "TRB", .T. ) 
				TRB->COMPUN	:= aCriticas[ nInc ][1]
				TRB->DESCCU	:= aCriticas[ nInc ][2]
				TRB->PROJET	:= aCriticas[ nInc ][3]
				TRB->DESCPR	:= aCriticas[ nInc ][4]
				TRB->REVISA	:= aCriticas[ nInc ][5]
				MsUnLock()
			Next

			DbSelectArea( "TRB" )
			TRB->( DbGoTop() )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "COMPUN"	, "", A093RetDescr( "AEG_COMPUN" ), "" },;
						{ "DESCCU"	, "", A093RetDescr( "AEG_DESCRI" ), "" },;
						{ "PROJET"	, "", A093RetDescr( "AF8_PROJET" ), "" },;
						{ "REVISA"	, "", A093RetDescr( "AF8_REVISA" ), "" },;
						{ "DESCPR"	, "", A093RetDescr( "AF8_DESCRI" ), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA205Inv( cMarca, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) ) CENTERED

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aExport, { TRB->PROJET, TRB->REVISA, TRB->COMPUN }  ) // Projeto, Revisao, Composicao Aux

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui as sub-composicoes das composicoes que devem ³
						//³obrigatoriamente serem exportadas.                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA205IncSub( TRB->PROJET, TRB->REVISA, TRB->COMPUN, @aExport, .F. ) // Projeto, Revisa, Composicao Aux
					EndIf
					
					TRB->( DbSkip() )
				End
			EndIf
		
			If oPMSA2052 <> Nil
				oPMSA2052:Delete()
				oPMSA2052 := Nil
			Endif
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a exportacao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aExport )
		For nInc := 1 To Len( aExport )
			cChave := aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3]

			Begin Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui as composicoes associadas aos projetos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AJT" )
			AJT->( DbSetOrder( 2 ) )
			AJT->( DbSeek( xFilial( "AJT" ) + cChave ) )
			While AJT->( !Eof() ) .AND. AJT->AJT_FILIAL == xFilial( "AJT" ) .AND. AJT->( AJT_PROJET + AJT_REVISA + AJT_COMPUN ) == cChave
				RecLock( "AJT" )
				AJT->( DbDelete() )
				AJT->( MsUnLock() )

				AJT->( DbSkip() )
			End

			DbSelectArea( "AJU" )
			AJU->( DbSetOrder( 3 ) )
			AJU->( DbSeek( xFilial( "AJU" ) + cChave ) )
			While AJU->( !Eof() ) .AND. AJU->AJU_FILIAL == xFilial( "AJU" ) .AND. AJU->( AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == cChave
				RecLock( "AJU" )
				AJU->( DbDelete() )
				AJU->( MsUnLock() )

				AJU->( DbSkip() )
			End

			DbSelectArea( "AJV" )
			AJV->( DbSetOrder( 2 ) )
			AJV->( DbSeek( xFilial( "AJV" ) + cChave ) )
			While AJV->( !Eof() ) .AND. AJV->AJV_FILIAL == xFilial( "AJV" ) .AND. AJV->( AJV_PROJET + AJV_REVISA + AJV_COMPUN ) == cChave
				RecLock( "AJV" )
				AJV->( DbDelete() )
				AJV->( MsUnLock() )

				AJV->( DbSkip() )
			End

			DbSelectArea( "AJX" )
			AJX->( DbSetOrder( 2 ) )
			AJX->( DbSeek( xFilial( "AJX" ) + cChave ) )
			While AJX->( !Eof() ) .AND. AJX->AJX_FILIAL == xFilial( "AJX" ) .AND. AJX->( AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == cChave
				RecLock( "AJX" )
				AJX->( DbDelete() )
				AJX->( MsUnLock() )

				AJX->( DbSkip() )
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a copia da estrutura da composicao Aux associando ao projeto.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEG", "AJT", .T. ) // Banco de Composicao Aux
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEH", "AJU", .T. ) // Insumo X Banco de Composicao Aux
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEI", "AJV", .T. ) // Despesas da Composicao Aux do Banco
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEJ", "AJX", .T. ) // SubComposicao da Composicao Aux do Banco

			// Insumos
			DbSelectArea( "AJU" )
			AJU->( DbSetOrder( 3 ) )
			AJU->( DbSeek( xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3] ) )
			While AJU->( !Eof() ) .AND. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3]
				// Insumo
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) )
				AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
				While AJY->( !Eof() ) .AND. AJY->AJY_FILIAL == xFilial( "AJY" ) .AND. AJY->( AJY_PROJET + AJY_REVISA + AJY_INSUMO ) == AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO )
					RecLock( "AJY" )
					AJY->( DbDelete() )
					AJY->( DbSkip() )
				End

				aInsumos := PA205Insumos( AJU->AJU_INSUMO, .T. )
				For nInsu := 1 To Len( aInsumos )
				DbSelectArea( "AJZ" )
				AJZ->( DbSetOrder( 1 ) )
					If AJZ->( DbSeek( xFilial( "AJZ" ) + aInsumos[nInsu] ) )
						aFields := AJZ->( DbStruct() )
	
						lNewRec := AJY->( !DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + aInsumos[nInsu] ) ) )
						If lNewRec
							RecLock( "AJY", lNewRec )
							For nCampo := 1 To Len( aFields )
								cCampo := "AJY_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
								If AJY->( FieldPos( cCampo ) ) > 0
									AJY->( &(cCampo) ) := AJZ->( &(aFields[nCampo][1]) )
								EndIf
							Next
					
							If AJZ->AJZ_GRORGA=='A' .And. AJZ->AJZ_TPPARC $ '1;2'
								AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJZ->AJZ_DEPREC, 0) +;
													IIf(AF8->AF8_JUROS  $ "13", AJZ->AJZ_VLJURO, 0) +;
													IIf(AF8->AF8_MDO    $ "13", AJZ->AJZ_MDO   , 0) +;
													IIf(AF8->AF8_MATERI $ "13", AJZ->AJZ_MATERI, 0) +;
													IIf(AF8->AF8_MANUT  $ "13", AJZ->AJZ_MANUT , 0)
								AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJZ->AJZ_DEPREC, 0) +;
													IIf(AF8->AF8_JUROS  $ "23", AJZ->AJZ_VLJURO, 0) +;
													IIf(AF8->AF8_MDO    $ "23", AJZ->AJZ_MDO   , 0)
							EndIf

							AJY->AJY_FILIAL := xFilial( "AJY" )
							AJY->AJY_PROJET := AJU->AJU_PROJET
							AJY->AJY_REVISA := AJU->AJU_REVISA
							AJY->( MsUnLock() )
						EndIf
					EndIf
				
					// Estrutura do Insumo
					DbSelectArea( "AEM" )
					AEM->( DbSetOrder( 1 ) )
					AEM->( DbSeek( xFilial( "AEM" ) + AJU->( AJU_PROJET + AJU_REVISA + aInsumos[nInsu] ) ) )
					While AEM->( !Eof() ) .AND. AEM->AEM_FILIAL == xFilial( "AEM" ) .AND. AEM->( AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == AJU->( AJU_PROJET + AJU_REVISA + aInsumos[nInsu] )
						RecLock( "AEM" )
						AEM->( DbDelete() )
						AEM->( DbSkip() )
					End
	
					DbSelectArea( "AEK" )
					AEK->( DbSetOrder( 1 ) )
					AEK->( DbSeek( xFilial( "AEK" ) + aInsumos[nInsu] ) )
					While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + aInsumos[nInsu]
						aFields := AEK->( DbStruct() )
	
						lNewRec := AEM->( !DbSeek( xFilial( "AEM" ) + AJU->( AJU_PROJET + AJU_REVISA + AEK->AEK_SUBCOD ) ) )
						RecLock( "AEM", lNewRec )
						For nCampo := 1 To Len( aFields )
							cCampo := "AEM_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
							If AEM->( FieldPos( cCampo ) ) > 0
								AEM->( &(cCampo) ) := AEK->( &(aFields[nCampo][1]) )
							EndIf
						Next
				
						AEM->AEM_FILIAL := xFilial( "AEM" )
						AEM->AEM_PROJET := AJU->AJU_PROJET
						AEM->AEM_REVISA := AJU->AJU_REVISA
						AEM->AEM_SUBINS := AEK->AEK_SUBCOD
						AEM->( MsUnLock() )

						AEK->( DbSkip() )
					End
				Next
									
				AJU->( DbSkip() )
			End

			End Transaction
		Next

		// Define o aHeader e aCols da tela quando copia pela rotina PMSA205
		If Empty( cCompun )
			PA205AtuBrw( cProjet, cRevisa, cTarefa )
			oGetD:aCols := aCols
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Pa205Exp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Exportacao de composicoa Aux                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Pa205Exp(cAlias,nReg,nOpcx)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Codigo do Projeto                                           º±±
±±º          ³ ExpC2 - Revisao do Projeto                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205Exp( cProjet, cRevisa )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aCodCU	:= {}				// Array com as composicoes Aux selecionadas
	Local aCodExp	:= {}				// Array com as composicoes Aux do cadastro
	Local aCriticas	:= {}				// Array com os projetos onde as composicoes Aux ja existem
	Local aExport  	:= {}				// Array com as composicoes a serem exportadas com seus respectivos projetos
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local aInsumos	:= {}
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar as composicoes Aux
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local lNewRec	:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncCU	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local nInsu		:= 0
	Local oDlg
	Local oPMSA2053 := Nil
	Local oPMSA2054 := Nil 

	Local oPanel
	Local oGet
	Local cProcura
	Local oButton
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta as composicoes Aux disponiveis para exportacao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
						{ "PROJET", "C", TamSX3( "AJT_PROJET" )[1],	0 },;
						{ "REVISA", "C", TamSX3( "AJT_REVISA" )[1],	0 },;
						{ "CODIGO", "C", TamSX3( "AJT_COMPUN" )[1],	0 },;
						{ "DESCR"  , "C", TamSX3( "AJT_DESCRI" )[1], 	0 }}
				
	oPMSA2053 := FWTemporaryTable():New( "TRB" )  
	oPMSA2053:SetFields(aTrab) 
	oPMSA2053:AddIndex("1", {"CODIGO"})

	//------------------
	//Criação da tabela temporaria
	//------------------
	oPMSA2053:Create()

	Processa( { || MontaTRB1( "AJT", cProjet, cRevisa ) }, STR0050 ) // "Selecionando composicoes Aux para exportacao... Aguarde!"

	DbSelectArea( "TRB" )
	TRB->( DbGoTop() )
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

	cProcura := space(TamSX3( "AJT_COMPUN")[1]+TamSX3( "AJT_PROJET" )[1])
	@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
	oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(alltrim(cProcura))) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

	aCpos := {	{ "OK"    , "", "", ""}, ;
				{ "PROJET", "", A093RetDescr( "AJT_PROJET" ), "" },;
				{ "REVISA", "", A093RetDescr( "AJT_REVISA" ), "" },;
				{ "CODIGO", "", A093RetDescr( "AJT_COMPUN" ), "" },;
				{ "DESCR"  , "", A093RetDescr( "AJT_DESCRI" ), "" } }

	oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
	oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lCanAllMark	:= .T.
	oMark:oBrowse:bAllMark		:= { || PMA205Inv( cMarca, .T., oMark ) }

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) ) CENTERED
	
	If lOk
		TRB->( DbGoTop() )
		While TRB->( !Eof() )
			If TRB->OK == "X"
				aAdd( aCodCU, { TRB->CODIGO, TRB->DESCR, TRB->PROJET, TRB->REVISA } ) // Comp Aux, Descricao, Projeto, Revisao
			EndIf
			
			TRB->( DbSkip() )
		End
	EndIf
	
	If oPMSA2053 <> Nil
		oPMSA2053:Delete()
		oPMSA2053 := Nil
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se no projeto selecionado existe alguma composicao³
	//³selecionada e questiona se deve substituir ou manter.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aCodCU )
		For nIncCU := 1 To Len( aCodCU )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica na tabela AEG-Composicoes Aux do Banco se a    ³
			//³composicao a ser exportada ja existe                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEG" )
			AEG->( DbSetOrder( 1 ) )
			If AEG->( DbSeek( xFilial( "AEG" ) + aCodCU[ nIncCU ][1] ) )
				aAdd( aCriticas, { aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][1], aCodCU[ nIncCU ][2] }  ) //  Projeto, Revisao, Composicao Aux, Descricao
			Else
				aAdd( aExport, { aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][1], aCodCU[ nIncCU ][2] } ) // Projeto, Revisao, Composicao Aux, Descricao

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui as sub-composicoes das composicoes que devem ³
				//³obrigatoriamente serem exportadas.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PA205IncSub( aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][1], @aExport ) // Projeto, Revisa, Composicao Aux
			EndIf
		Next

		If !Empty( aCriticas )
			Alert( STR0051 + chr(13) + chr(10) + STR0052 )
	
			aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
								{ "COMPUN", "C", TamSX3( "AJT_COMPUN" )[1],	0 },;
								{ "DESCCU", "C", TamSX3( "AJT_DESCRI" )[1],	0 },;
								{ "PROJET", "C", TamSX3( "AF8_PROJET" )[1],		0 },;
								{ "REVISA", "C", TamSX3( "AF8_REVISA" )[1],		0 } }
		
			oPMSA2054 := FWTemporaryTable():New( "TRB" )  
			oPMSA2054:SetFields(aTrab) 
			oPMSA2054:AddIndex("1", {"COMPUN","PROJET"})
		
			//------------------
			//Criação da tabela temporaria
			//------------------
			oPMSA2054:Create()
		
			For nInc := 1 To Len( aCriticas )
				RecLock( "TRB", .T. ) 
				TRB->COMPUN	:= aCriticas[ nInc ][3]
				TRB->DESCCU	:= aCriticas[ nInc ][4]
				TRB->PROJET	:= aCriticas[ nInc ][1]
				TRB->REVISA	:= aCriticas[ nInc ][2]
				MsUnLock()
			Next

			DbSelectArea( "TRB" )
			TRB->( DbGoTop() )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "COMPUN"	, "", A093RetDescr( "AJT_COMPUN" ), "" },;
						{ "DESCCU"	, "", A093RetDescr( "AJT_DESCRI" ), "" },;
						{ "PROJET"	, "", A093RetDescr( "AF8_PROJET" ), "" },;
						{ "REVISA"	, "", A093RetDescr( "AF8_REVISA" ), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA205Inv( cMarca, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) ) CENTERED

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aExport, { TRB->PROJET, TRB->REVISA, TRB->COMPUN, TRB->DESCCU } ) // Projeto, Revisao, Composicao Aux, Descricao

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui as sub-composicoes das composicoes que devem ³
						//³obrigatoriamente serem exportadas.                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA205IncSub( TRB->PROJET, TRB->REVISA, TRB->COMPUN, @aExport ) // Projeto, Revisa, Composicao Aux
					EndIf
					
					TRB->( DbSkip() )
				End
			EndIf
		
			If oPMSA2054 <> Nil
				oPMSA2054:Delete()
				oPMSA2054 := Nil
			Endif
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a exportacao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aExport )
		For nInc := 1 To Len( aExport )
			cChave := aExport[nInc][3]

			Begin Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui as composicoes associadas aos projetos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEG" )
			AEG->( DbSetOrder( 1 ) )
			AEG->( DbSeek( xFilial( "AEG" ) + cChave ) )
			While AEG->( !Eof() ) .AND. AEG->AEG_FILIAL == xFilial( "AEG" ) .AND. AEG->AEG_COMPUN == cChave
				RecLock( "AEG" )
				AEG->( DbDelete() )
				AEG->( MsUnLock() )

				AEG->( DbSkip() )
			End

			DbSelectArea( "AEH" )
			AEH->( DbSetOrder( 1 ) )
			AEH->( DbSeek( xFilial( "AEH" ) + cChave ) )
			While AEH->( !Eof() ) .AND. AEH->AEH_FILIAL == xFilial( "AEH" ) .AND. AEH->AEH_COMPUN == cChave
				RecLock( "AEH" )
				AEH->( DbDelete() )
				AEH->( MsUnLock() )

				AEH->( DbSkip() )
			End

			DbSelectArea( "AEI" )
			AEI->( DbSetOrder( 1 ) )
			AEI->( DbSeek( xFilial( "AEI" ) + cChave ) )
			While AEI->( !Eof() ) .AND. AEI->AEI_FILIAL == xFilial( "AEI" ) .AND. AEI->AEI_COMPUN == cChave
				RecLock( "AEI" )
				AEI->( DbDelete() )
				AEI->( MsUnLock() )

				AEI->( DbSkip() )
			End

			DbSelectArea( "AEJ" )
			AEJ->( DbSetOrder( 1 ) )
			AEJ->( DbSeek( xFilial( "AEJ" ) + cChave ) )
			While AEJ->( !Eof() ) .AND. AEJ->AEJ_FILIAL == xFilial( "AEJ" ) .AND. AEJ->AEJ_COMPOS == cChave
				RecLock( "AEJ" )
				AEJ->( DbDelete() )
				AEJ->( MsUnLock() )

				AEJ->( DbSkip() )
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a copia da estrutura da composicao Aux associando ao projeto.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJT", "AEG" ) // Banco de Composicao Aux
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJU", "AEH" ) // Insumo X Banco de Composicao Aux
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJV", "AEI" ) // Despesas da Composicao Aux do Banco
			P205CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJX", "AEJ" ) // SubComposicao da Composicao Aux do Banco

			// Insumos
			DbSelectArea( "AJU" )
			AJU->( DbSetOrder( 3 ) )
			AJU->( DbSeek( xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3] ) )
			While AJU->( !Eof() ) .AND. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3]
				aInsumos := PA205Insumos( AJU->AJU_INSUMO, .F., AJU->AJU_PROJET, AJU->AJU_REVISA )
				For nInsu := 1 To Len( aInsumos )
					// Insumo
					DbSelectArea( "AJZ" )
					AJZ->( DbSetOrder( 1 ) )
					AJZ->( DbSeek( xFilial( "AJZ" ) + aInsumos[nInsu] ) )
					While AJZ->( !Eof() ) .AND. AJZ->AJZ_FILIAL == xFilial( "AJZ" ) .AND. AJZ->AJZ_INSUMO == aInsumos[nInsu]
						RecLock( "AJZ" )
						AJZ->( DbDelete() )
						AJZ->( MsUnLock() )

						AJZ->( DbSkip() )
					End
	
					DbSelectArea( "AJY" )
					AJY->( DbSetOrder( 1 ) )
					If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + aInsumos[nInsu] ) ) )
						aFields := AJY->( DbStruct() )

						lNewRec := 	AJZ->( !DbSeek( xFilial( "AJZ" ) + aInsumos[nInsu] ) )
						RecLock( "AJZ", lNewRec )
						For nCampo := 1 To Len( aFields )
							cCampo := "AJZ_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
							If AJZ->( FieldPos( cCampo ) ) > 0
								AJZ->( &(cCampo) ) := AJY->( &(aFields[nCampo][1]) )
							EndIf
						Next
				
						AJZ->AJZ_FILIAL := xFilial( "AJZ" )
						AJZ->( MsUnLock() )
					EndIf
					
					// Estrutura do Insumo
					DbSelectArea( "AEK" )
					AEK->( DbSetOrder( 1 ) )
					AEK->( DbSeek( xFilial( "AEK" ) + aInsumos[nInsu] ) )
					While AEK->( !Eof() ) .AND. AEK->AEK_FILIAL == xFilial( "AEK" ) .AND. AEK->AEK_INSUMO == aInsumos[nInsu]
						RecLock( "AEK" )
						AEK->( DbDelete() )
						AEK->( MsUnLock() )

						AEK->( DbSkip() )
					End
	
					DbSelectArea( "AEM" )
					AEM->( DbSetOrder( 1 ) )
					If AEM->( DbSeek( xFilial( "AEM" ) + AJU->( AJU_PROJET + AJU_REVISA + aInsumos[nInsu] ) ) )
						aFields := AEM->( DbStruct() )
	
						lNewRec := 	AEK->( !DbSeek( xFilial( "AEK" ) + aInsumos[nInsu] ) )
						RecLock( "AEK", lNewRec )
						For nCampo := 1 To Len( aFields )
							cCampo := "AEK_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
							If AEK->( FieldPos( cCampo ) ) > 0
								AEK->( &(cCampo) ) := AEM->( &(aFields[nCampo][1]) )
							EndIf
						Next
				
						AEK->AEK_FILIAL := xFilial( "AEK" )
						AEK->( MsUnLock() )
					EndIf
				Next
									
				AJU->( DbSkip() )
			End

			End Transaction
		Next
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GDDel    ³ Autor ³Fabio Rogerio Pereira³ Data ³01-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao do item da getdados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AJT                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205GDDel(nGet)
Local cCampo	:= IIf( nGet == 2, "AJV_VALOR", "_QUANT" )
Local nPos  	:= aScan( aHeader, { |x| cCampo $ AllTrim( x[ 2 ] ) } )
   
If nPos > 0
	aCols[n][nPos] := 0
EndIf

// somente valida a exclusao de itens para opcao diferente de Visualizar
If (oGD[nGet]:nOpc <> 2)
	// valida se utiliza o template CCT
	If lUsaCCT
		If ExistTemplate("CCTAJTCUST")
			ExecTemplate("CCTAJTCUST",.F.,.F.,{ nGet,, "AJT"} )
		EndIf
	EndIf
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205SegUm    ³ Autor ³Adriano Ueda         ³ Data ³07-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a segunda unidade de medida do produto na composicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AJT                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205SegUm()
Local aAreaAJY := AJY->(GetArea())
Local ny := 0

Local nProdutoPos := 0
Local nQtSegUmPos := 0
Local nProdQtdPos := 0

// procura o codigo do produto
// digitado no aCols
For ny := 1 To Len(aHeaderSV[1])
	Do Case
		Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_INSUMO"
			nProdutoPos := ny
		Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_QTSEGU"
			nQtSegUmPos := ny
		Case AllTrim(aHeaderSV[1][ny][2]) == "AJU_QUANT"
			nProdQtdPos := ny
	EndCase
Next

If nProdutoPos > 0
	AJY->(dbSetOrder(1))
	
	// procura o produto no AJY
	If AJY->(dbSeek(xFilial() + aCols[n][nProdutoPos]))
		
		// se o fator de conversao e o tipo de conversao
		// nao forem vazios
		If AJY->AJY_CONV > 0 .And. AJY->AJY_TIPCONV <> ""
			If nQtSegUmPos > 0
				
				// multiplica ou divide a quantidade pelo fator
				If AJY->AJY_TIPCONV = "M"
					aCols[n][nQtSegUmPos] := M->AJU_QUANT * AJY->AJY_CONV
				Else
					aCols[n][nQtSegUmPos] := M->AJU_QUANT / AJY->AJY_CONV
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAJY)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pa205CPYIN³ Autor ³Reynaldo Miyashita     ³ Data ³ 22.12.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de inicializacao na tela de cadastro da copia de       ³±±
±±³          ³Composicao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA205                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205CPYINI()

If ExistBlock("Pa205INI")
	ExecBlock("Pa205INI",.F.,.F.)
EndIf

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
Local aRotina 	:= {	{ STR0002,"AxPesqui"   , 0 , 1, 0, .F.},; //"Pesquisar"
{ STR0003,"Pa205Dialog"	, 0 , 2},; //"Visualizar"
{ STR0004,"Pa205Dialog"	, 0 , 3},; //"Incluir"
{ STR0005,"Pa205Dialog"	, 0 , 4},; //"Alterar"
{ STR0006,"Pa205Dialog"	, 0 , 5},; //"Excluir"
{ STR0055,"Pa205Imp"	, 0 , 1},; //"Importar"
{ STR0056,"Pa205Exp"	, 0 , 7},; //"Exportar"
{ STR0057,"Pa205Dupl"	, 0 , 8}}  //"Duplicar"
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a205FdOkA ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³Aux, atualizando os custos Un. Truncado e Arredondado.      º±±
±±º          ³  a205FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  a205FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  a205FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA205 - Cadastro de Composicao Aux                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205FdOkA()
Local cCampo  	:= ReadVar()
Local nPosQt  	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_QUANT"  } )
Local nPIndImp	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_HRIMPR" } )
Local nPIndPrd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_HRPROD" } )
Local nPCusPrd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_CUSPRD" } )		
Local nPCusImp	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_CUSIMP" } ) 
Local nPCustd 	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_CUSTD"  } )
Local nPDMT   	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_DMT"  } )
Local nPGrOrga	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_GRORGA" } )
Local nPCstItem	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJU_CSTITM" } )
Local nDMT		:= 1
Local nDecCst	:= TamSX3("AEH_CSTITM")[2]
   
If nPGrOrga > 0
	If aCols[n][nPGrOrga] == "F"
		nDMT := aCols[n][nPDMT]
	EndIf
EndIf
   
Do Case
	Case cCampo == "M->AJU_QUANT"
  		aCols[n][nPosQt] 	:= &cCampo
	Case cCampo == "M->AJU_DMT"
  		aCols[n][nPDMT] 	:= &cCampo
	Case cCampo == "M->AJU_HRPROD" 
  		aCols[n][nPIndPrd]	:= &cCampo
		aCols[n][nPCustd]	:= (aCols[n][nPCusPrd] * aCols[n][nPIndPrd]) + (aCols[n][nPCusImp] * aCols[n][nPIndImp])	
	Case cCampo == "M->AJU_HRIMPR"
  		aCols[n][nPIndImp]	:= &cCampo
		aCols[n][nPCustd]	:= (aCols[n][nPCusPrd] * aCols[n][nPIndPrd]) + (aCols[n][nPCusImp] * aCols[n][nPIndImp])	
EndCase

// Desconsiderar o custo produtivo e indice produtivo quando insumo
// do grupo orgao B, E e F
If nPGrOrga > 0
	If aCols[n][nPGrOrga] == "F"
		aCols[n][nPCstItem]	:= aCols[n][nPosQt] * aCols[n][nPCustd] * nDMT
	Else
		aCols[n][nPCstItem]	:= aCols[n][nPosQt] * aCols[n][nPCustd]
	EndIf
	aCols[n][nPCstItem]:=Round( aCols[n][nPCstItem], nDecCst )
	If aCols[n][nPGrOrga] != "A"
		aCols[n][nPIndPrd]	:= 0
		aCols[n][nPCusPrd]	:= 0
	EndIf
EndIf

If ExistTemplate("CCTAJTCUST")
	ExecTemplate("CCTAJTCUST",.F.,.F.,{ 2,, "AJT" })
EndIf

a205GDCalcCust(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a205FdOkB ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³Aux, atualizando os custos Un. Truncado e Arredondado.      º±±
±±º          ³  a205FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  a205FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  a205FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA205 - Cadastro de Composicao Aux                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205FdOkB()
Local cCampo 	:= ReadVar()
Local nPosVal	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_VALOR" } )
Local nPosDMTT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_DMTT" } )
Local nPosDMTP	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_DMTP" } )
Local nPosDMT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_DMT" } )
Local nPosCusto	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_CUSTO" } )
Local nPosCons	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AJV_CONSUM"} )

If cCampo == "M->AJV_VALOR"
	aCols[n][nPosVal] := &cCampo
ElseIf cCampo == "M->AJV_DMTT"
	aCols[n][nPosDMTT] := &cCampo
ElseIf cCampo == "M->AJV_DMTP"
	aCols[n][nPosDMTP] := &cCampo
ElseIf cCampo == "M->AJV_CUSTO"
	aCols[n][nPosCusto] := &cCampo
ElseIf cCampo == "M->AJV_CONSUM"
	aCols[n][nPosCons] := &cCampo
EndIf

If nPosDMT > 0 .AND. nPosDMTT > 0 .AND. nPosDMTP > 0 .AND. N > 0
	aCols[n][nPosDMT] := aCols[n][nPosDMTT] + aCols[n][nPosDMTP]
	If aCols[n][nPosDMT] > 0
		aCols[n][nPosVal] := aCols[n][nPosDMT] * aCols[n][nPosCusto] * aCols[n][nPosCons]
	EndIf
EndIf

If ExistTemplate("CCTAJTCUST")
	ExecTemplate("CCTAJTCUST",.F.,.F.,{2,,"AJT"})
EndIf

a205GDCalcCust(2)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a205FdOkC ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³Aux, atualizando os custos Un. Truncado e Arredondado.      º±±
±±º          ³  a205FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  a205FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  a205FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA205 - Cadastro de Composicao Aux                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a205FdOkC()
Local cCampo    := ReadVar()
Local nPosQtSub := aScan(aHeader,{|x|AllTrim(x[2]) == "AJX_QUANT"})
Local nPosSubC  := aScan(aHeader,{|x|AllTrim(x[2]) == "AJX_SUBCOM"})

Do Case
	Case cCampo == "M->AJX_QUANT"
  		aCols[n][nPosQtSub] := &cCampo
	Case cCampo == "M->AJX_SUBCOM" 
  		aCols[n][nPosSubC] := &cCampo
EndCase

If ExistTemplate("CCTAJTCUST")
	ExecTemplate("CCTAJTCUST",.F.,.F.,{3,, "AJT"})
EndIf

a205GDCalcCust(3)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a205GDCalcCustºAutor  ³Reynaldo Miyashitaº Data ³29-01-2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os custos item dos insumos, despesas e subcomposicaoº±±
±±º          ³ e o custo unitario da composicao Aux.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA205 - Cadastro de Composicao Aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a205GDCalcCust(nGet)
Local aHeaderSAV := {}
Local aColsSAV := {}

Default nGet := 0

If ValType("oFolder") != "U" .and. (oFolder:nOption > 0) .and. ValType("oGD") != "U" .and. len(oGD) >= oFolder:nOption

	nGet := IIf(nGet == 0,oFolder:nOption,nGet)
	
	If Len(oGD) >= nGet
		nGet := IIf(nGet == 0,oFolder:nOption,nGet)

		If oFolder:nOption # nGet
			aHeaderSAV := Aclone(aHeader)
			aColsSAV   := Aclone(aCols)
			aHeader    := Aclone(aHeaderSV[nGet])
			aCols      := Aclone(aColsSV[nGet])
		EndIf
		oGD[nGet]:oBrowse:Refresh()
	
		If oFolder:nOption # nGet
			aHeader := Aclone(aHeaderSAV)
			aCols   := Aclone(aColsSAV)
		EndIf

	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA205DelºAutor  ³Pedro Pereira Lima  º Data ³  10/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validacao para exclusao da comp. Aux, verificandoº±±
±±º          ³se existe vinculo da comp. Aux com alguma tarefa/projeto, º±±
±±º          ³ou se a comp. Aux selecionada para delecao e utilizada    º±±
±±º          ³como subcomposicao em outra comp. Aux. Caso ocorra alguma º±±
±±º          ³das situacoes acima, sera restringida a exclusao.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA205 - Cadastro de Composicao Aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA205Del( cCompun, cProjet, cRevisa, lShowMsg, nRecnoAEN )
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAJT := AJT->(GetArea())
Local aAreaAJX := AJX->(GetArea())
Local lOk      := .T.

Default lShowMsg	:= .T.

If Empty( cCompun )
	Return .F.
EndIf

//Verifico se a composicao Aux selecionada para exclusao e subcomposicao de outra composicao Aux
dbSelectArea( "AJX" )
AJX->( DbSetOrder( 2 ) )
AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa ) )
While !AJX->( Eof() ) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA ) == xFilial( "AJX" ) + cProjet + cRevisa
	If AJX->AJX_SUBCOM == cCompun //Verifico se a comp. Aux selecionada para delecao existe como subcomposicao
		lOk     := .F.     

		If lShowMsg
			Alert( STR0058 + AllTrim( AJX->AJX_COMPUN ) + STR0059 ) // "A composição aux selecionada é subcomposição de " ## " e não pode ser excluída!"
		EndIf

		Exit
	EndIf

	AJX->( DbSkip() )
End
           
//Verifico se a composicao Aux esta sendo usada em algum projeto e bloqueia
If lOk
/*
	DbSelectArea( "AF9" )
	AF9->( DbSetOrder( 1 ) )
	AF9->( DbSeek( xFilial( "AF9" ) + cProjet + cRevisa ) )
	While AF9->( !Eof() ) .AND. AF9->( AF9_FILIAL + AF9_PROJET + AF9_REVISA ) == xFilial( "AF9" ) + cProjet + cRevisa
		If AF9->AF9_COMPUN == cCompun
			lOk     := .F.     

			If lShowMsg
				Alert( STR0061 ) // "A composição aux selecionada esta sendo usado no projeto e não pode ser excluida!"
			EndIf

			Exit
		EndIf

		AF9->( DbSkip() )
	End
*/
	DbSelectArea( "AEN" )
	AEN->( DbSetOrder( 1 ) )
	AEN->( DbSeek( xFilial( "AEN" ) + cProjet + cRevisa ) )
	While AEN->( !Eof() ) .AND. AEN->( AEN_FILIAL + AEN_PROJET + AEN_REVISA ) == xFilial( "AEN" ) + cProjet + cRevisa
		If AEN->AEN_SUBCOM == cCompun .And. ( nRecnoAEN==nil .Or. AEN->(Recno())!=nRecnoAEN )
			lOk     := .F.     

			If lShowMsg
				Alert( STR0061 ) // "A composição aux selecionada esta sendo usado no projeto e não pode ser excluida!"
			EndIf

			Exit
		EndIf

		AEN->( DbSkip() )
	End
EndIf

RestArea(aAreaAJX)
RestArea(aAreaAJT)
RestArea(aAreaAF9)
RestArea(aArea)

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao das composicoes Aux        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRB1( cAlias, cProjet, cRevisa )
	DbSelectArea( cAlias )
	(cAlias)->( DbSetOrder( 1 ) )
	(cAlias)->( DbGoTop() )
	While (cAlias)->( !Eof() )
		If (cAlias)->( &(cAlias + "_PROJET") ) == cProjet .AND. (cAlias)->( &(cAlias + "_REVISA") ) == cRevisa
			RecLock( "TRB", .T. ) 
			TRB->PROJET	:= (cAlias)->( &(cAlias + "_PROJET") )
			TRB->REVISA	:= (cAlias)->( &(cAlias + "_REVISA") )
			TRB->CODIGO	:= (cAlias)->( &(cAlias + "_COMPUN") )
			TRB->DESCR	:= (cAlias)->( &(cAlias + "_DESCRI") )
			MsUnLock()
		EndIf

		(cAlias)->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³P205CpyCompos³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Realiza a copia de composicoes Aux                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function P205CpyCompos( cCodPrj, cRevisa, cCodCU, cOrigem, cDestino, lImport )
	Local aFields 	:= {}
	Local cCampo	:= ""
	Local nCampo	:= 0
	Local cChave	:= IIf( cOrigem == "AEJ", "_COMPOS", "_COMPUN" )

	Default lImport := .F.

	DbSelectArea( cOrigem )
	(cOrigem)->( DbSetOrder( 1 ) )
	(cOrigem)->( DbSeek( xFilial( cOrigem ) + cCodCU ) )
	aFields := (cOrigem)->( DbStruct() )
	While (cOrigem)->( !Eof() ) .AND. (cOrigem)->( &(cOrigem + "_FILIAL") ) == xFilial( cOrigem ) .AND. (cOrigem)->( &(cOrigem + cChave) ) == cCodCU
		If !lImport
			If (cOrigem)->( FieldPos( cOrigem + "_PROJET" ) ) > 0 .AND. (cOrigem)->( FieldPos( cOrigem + "_REVISA" ) ) > 0
				If (cOrigem)->( &( cOrigem + "_PROJET" ) + &( cOrigem + "_REVISA" ) ) <> cCodPrj + cRevisa
					(cOrigem)->( DbSkip() )
					Loop
				EndIf
			EndIf
		EndIf
		
		RecLock( cDestino, .T. )
		For nCampo := 1 To Len( aFields )
			cCampo := cDestino + "_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
			If (cDestino)->( FieldPos( cCampo ) ) > 0
				(cDestino)->( &(cCampo) ) := (cOrigem)->( &(aFields[nCampo][1]) )
			EndIf
		Next

		(cDestino)->( &( cDestino + "_FILIAL" ) ) := xFilial( cDestino )

		If lImport
			(cDestino)->( &( cDestino + "_PROJET" ) ) := cCodPrj
			(cDestino)->( &( cDestino + "_REVISA" ) ) := cRevisa

			If cOrigem == "AEJ"
				(cDestino)->AJX_COMPUN := (cOrigem)->AEJ_COMPOS
			EndIf
		Else
			If cOrigem == "AJX"
				AEJ->AEJ_COMPOS := AJX->AJX_COMPUN
			EndIf
		EndIf

		(cDestino)->( MsUnLock() )

		(cOrigem)->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao das composicoes Aux        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRBImp()
	DbSelectArea( "AEG" )
	AEG->( DbSetOrder( 1 ) )
	AEG->( DbGoTop() )
	While AEG->( !Eof() )
		RecLock( "TRB", .T. ) 
		TRB->CODIGO	:= AEG->AEG_COMPUN
		TRB->DESCR	:= AEG->AEG_DESCRI
		MsUnLock()

		AEG->( DbSkip() )
	End
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PA205Dlg2  ³ Autor ³ Totvs                 ³ Data ³ 12-06-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ³±±
±±³          ³ de Composicoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA205Dlg2( cProjet, cRevisa, bReCalc, cTarefa )
	Local aNoFields := {"AEM_FILIAL","AEM_PROJET","AEM_REVISA"}					// Campos que nao serao apresentados no aCols
	Local bCond     := {|| .T.}													// Se bCond .T. executa bAction1, senao executa bAction2
	Local cMarca	:= "X"				// Caractere de marca
	Local lInverte	:= .F.
	Local lOk		:= .F.
	Local oDlg
	Local oProjet
	Local oRevisa
	Local cQuery    := ""
	Local cSeek     := ""
	Local cWhile    := ""
	Local nI		:= 0
	Local nUsado	:= 0
	Local cPesq		:= Space( TamSX3( "AJT_DESCRI" )[1] )
	Local nRadio	:= 1
	Local oPesq
	Local oRadio
	Local aArea		:= GetArea()
	Local aAreaAF9	:= AF9->(GetArea())
	Local lImpExp	:= .T.

	Private cCadastro	:= STR0001										//"Composicoes Auxiliares"
	Private lUsaCCT 	:= GetMV( "MV_PMSCCT" ) == "2"                 // 1=Nao;2=Sim
	Private aRotina 	:= MenuDef()
	Private lConfirma 	:= .T.
	Private oGetD
	Private lRefresh 	:= .T.
	Private aHeader 	:= {}
	Private aCols 		:= {}
	Private aHeaderCM 	:= {}
	Private aColsCM 	:= {}

	SaveInter()

	If ExistBlock("PMA205IE") // Botoes de importar/exportar
		lImpExp := ExecBlock("PMA205IE",.F.,.F.)
	EndIf

	// so executa se houver o template aplicadoc com licença, caso 
	// contrario mostra uma mensagem de alerta e aborta
	ChkTemplate("CCT")
	
	If AMIIn( 44 ) 
		// Define o aHeader e aCols da tela
		PA205AtuBrw( cProjet, cRevisa, cTarefa )
	
		DEFINE MSDIALOG oDlg TITLE STR0001 From C(264),C(241)  TO C(610), C(774) OF oMainWnd PIXEL
	
		@ C(000),C(000) TO C(020),C(267) LABEL "" PIXEL OF oDlg
	
		@ C(005),C(131) MsGet oRevisa Var cRevisa Size C(060),C(009) COLOR CLR_BLACK PIXEL OF oDlg READONLY
		@ C(005),C(024) MsGet oProjet Var cProjet Size C(060),C(009) COLOR CLR_BLACK PIXEL OF oDlg READONLY
		
		@ C(008),C(003) Say STR0002 			Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(008),C(111) Say STR0003 			Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
		@ C(163),C(016) Button STR0003 	Size C(037),C(012) PIXEL OF oDlg ACTION PA205Act( 2, cProjet, cRevisa, cTarefa ) 	// Visualizar
		@ C(163),C(059) Button STR0005	Size C(037),C(012) PIXEL OF oDlg ACTION PA205Act( 4, cProjet, cRevisa, cTarefa ) 	// Alterar
		@ C(163),C(102) Button STR0006	Size C(037),C(012) PIXEL OF oDlg ACTION PA205Act( 5, cProjet, cRevisa, cTarefa ) 	// Excluir
		If lImpExp
			@ C(163),C(144) Button STR0055	Size C(037),C(012) PIXEL OF oDlg ACTION PA205Imp( cProjet, cRevisa, , cTarefa )    	// Importar
			@ C(163),C(186) Button STR0056	Size C(037),C(012) PIXEL OF oDlg ACTION PA205Exp( cProjet, cRevisa ) 				// Exportar
		EndIf
		@ C(163),C(228) Button STR0023	Size C(037),C(012) PIXEL OF oDlg ACTION oDlg:End()     					// Cancelar

		oGetD := MsNewGetDados():New(034, 005, 170, 338, 2,"AlwaysTrue","AlwaysTrue","",{}/*aCpoGet*/,,,"AlwaysTrue","AlwaysTrue","AlwaysTrue",,aHeader,aCols)

		@ C(135),C(002) TO C(160),C(059) LABEL "Indice de Pesquisa" PIXEL OF oDlg //"Indice de Pesquisa"
		@ C(142),C(005) RADIO oRadio Var nRadio Items "Referencia", "Descricao" 3D Size C(047),C(010) PIXEL OF oDlg //"Referencia", "Descricao"

		@ C(142),C(064) Say "Pesquisar por" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg //"Pesquisar por"
		@ C(148),C(064) MsGet oPesq Var cPesq Picture "@!" Size C(160),C(009) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(147),C(228) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION PA205Pesq( nRadio, cPesq )  //"Pesquisar"
		ACTIVATE MSDIALOG oDlg CENTERED
	
		// Efetua o recalculo dos custos
		aCols := NIL
		PMS200ReCalc()
		Eval( bReCalc )
	EndIf
	
	RestInter()

	RestArea(aAreaAF9)
	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA205AtuBrw ³ Autor ³ Totvs                 ³ Data ³ 12.06.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Atualiza o browser                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA205AtuBrw( cProjet, cRevisa, cTarefa )
	Local nI		:= 0
	Local nJ		:= 0
	Local nUsado	:= 0
	Local aComps	:= {}

	aCols	:= {}
	aHeader	:= {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("AJT")
	While !Eof() .And. SX3->X3_ARQUIVO == "AJT"
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .AND. !( "CUSTO" $ SX3->X3_CAMPO )
			nUsado++
			AADD( aHeader, {	Trim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								"",;
								SX3->X3_TIPO,;
								"",;
								SX3->X3_CONTEXT })
		EndIf

		DbSkip()
	End

	If cTarefa=Nil
		dbSelectArea( "AJT" )
		AJT->( dbSetOrder( 2 ) )
		AJT->( dbSeek( xFilial( "AJT" ) + cProjet + cRevisa ) )
		Do While AJT->( !Eof() ) .AND. AJT->( AJT_FILIAL + AJT_PROJET + AJT_REVISA ) == xFilial( "AJT" ) + cProjet + cRevisa
			aADD(aCols,Array(Len(aHeader)+1))
			For nI := 1 To Len(aHeader)
				// Campo não é virtual, isto é, existe o campo fisicamente na tabela
				If ( aHeader[nI][10] != "V")
					aCols[Len(aCols)][aScan(aHeader,{ |x| x[2] == aHeader[nI][2]})] := AJT->&(aHeader[nI][2])
				EndIf
			Next nI
			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			AJT->(dbSkip())
		EndDo
	Else
		dbSelectArea( "AJT" )
		AJT->( dbSetOrder( 2 ) )
        For nJ := 1 to Len(aComps)
			AJT->( dbSeek( xFilial( "AJT" ) + cProjet + cRevisa + aComps[nJ] ) )
			aADD(aCols,Array(Len(aHeader)+1))
			For nI := 1 To Len(aHeader)
				// Campo não é virtual, isto é, existe o campo fisicamente na tabela
				If ( aHeader[nI][10] != "V")
					aCols[Len(aCols)][aScan(aHeader,{ |x| x[2] == aHeader[nI][2]})] := AJT->&(aHeader[nI][2])
				EndIf
			Next nI
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nJ
	EndIf

	// se aCols estiver vazio. Cria a 1a linha vazia
	If Empty(aCols)
		aAdd( aCols, Array( nUsado + 1 ) )
		For nI := 1 To nUsado
			// Campo não é virtual, isto é, existe o campo fisicamente na tabela
			If ( aHeader[nI][10] != "V")
				aCols[1][nI] := CriaVar(aHeader[nI][2])
			EndIf
		Next nI
		aCols[1][nUsado+1] := .F.
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PA204Act ³ Autor   ³ Totvs                  ³ Data ³07/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel pela acao dos botoes                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA205Act( nOpc, cProjet, cRevisa, cTarefa  )
	Local cCompUnic		:= ""
	Local nPosCU		:= aScan( aHeader, { |x| x[2] == "AJT_COMPUN" } )

	If !Empty( aCols ) .AND. oGetD:nAt >= 1 .AND. nPosCU > 0
		cCompUnic := aCols[oGetD:nAt][nPosCU]
	EndIf

	If !Empty( cCompUnic )
		INCLUI := .F.
		ALTERA := .F.
		EXCLUI := .F.
		If nOpc == 4
			ALTERA := .T.
		ElseIf nOpc == 5
			EXCLUI := .T.
		EndIf

		// Localiza a composicao Aux
		DbSelectArea( "AJT" )
		AJT->( DbSetOrder( 2 ) )
		If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompUnic ) )
			Pa205Dialog( "AJT", AJT->( RecNo() ), nOpc )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o browser³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5 .OR. nOpc == 4
			// Define o aHeader e aCols da tela
			PA205AtuBrw( cProjet, cRevisa, cTarefa )
			oGetD:aCols := aCols
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJXCheckRef ³ Autor ³ Adriano Ueda     ³ Data ³ 17/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se uma determinada composição é uma subcomposição   ³±±
±±³          ³ de outra composição.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Utiliza recursão para iterar nas composições.                ³±±
±±³          ³ principal ou encontrar a EDT origem.                         ³±±
±±³          ³                                                              ³±±
±±³          ³ OBS.: Esta função não está preparada para o caso de qualquer ³±±
±±³          ³ composição que tem como subcomposição cCompSource e que seja ³±±
±±³          ³ subcomposição em cCompDest.                                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Assume que a EDT origem e a EDT destino pertencem ao mesmo   ³±±
±±³          ³ projeto.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCompSource - código da composição a ser pesquisado.         ³±±
±±³          ³                                                              ³±±
±±³          ³ cCompDest   - código da composição onde será pesquisada.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ - Retorna .T. se cCompSource for subcomposição em cCompDest, ³±±
±±³          ³   em qualquer nível desta.                                   ³±±
±±³          ³ - Retorna .F. se cCompSource não for subcomposição em        ³±±
±±³          ³   cCompDest.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJXCheckRef(cCompSource, cCompDest)

Local aAreaAJT := AJT->(GetArea())
Local aAreaAJX := AJX->(GetArea())
Local lRet     := .T.

AJT->(dbSetOrder(1))
If ! AJT->(dbSeek(xfilial("AJT") + cCompSource))
	lRet := .F.
	RestArea(aAreaAJT)
	RestArea(aAreaAJX)
	Return lRet
EndIf

// a composição origem e EDT destino não podem
// ser a mesma
If cCompSource == cCompDest
	lRet := .F.
	RestArea(aAreaAJT)
	RestArea(aAreaAJX)
	Return lRet
EndIf

dbSelectArea("AJX")
AJX->(dbSetOrder(1)) 	// AJX_FILIAL + AJX_COMPUN + AJX_ITEM

If AJX->( MsSeek( xFilial( "AJX" ) + cCompSource ) )
	While !AJX->(Eof()) .And.;
		AJX->AJX_FILIAL + AJX->AJX_COMPUN == xFilial("AJX") + cCompSource
		
		If AJX->AJX_SUBCOM == cCompDest
			lRet := .F.
			RestArea(aAreaAJT)
			RestArea(aAreaAJX)
			Return lRet
		Else
			lRet := PMSAJXCheckRef(AJX->AJX_SUBCOM, cCompDest)
			RestArea(aAreaAJT)
			RestArea(aAreaAJX)
			Return lRet
		EndIf
		
		dbSelectArea("AJX")
		AJX->(dbSkip())
	End
EndIf

RestArea(aAreaAJT)
RestArea(aAreaAJX)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA205IncSub  ³ Autor ³ Totvs                 ³ Data ³ 18.06.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Inclui no array para exportar as sub-composicoes              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PA205IncSub( cProjet, cRevisa, cCompun, aExport, lExporta )
	Local aArea		:= {}

	Default lExporta := .T.

	If lExporta
		DbSelectArea( "AJX" )
		AJX->( DbSetOrder( 2 ) )
		AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + cCompun ) )
		While AJX->( !Eof() ) .AND. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJX" ) + cProjet + cRevisa + cCompun
			aArea := AJX->( GetArea() )

			If !Empty( AJX->AJX_SUBCOM )
				aAdd( aExport, { cProjet, cRevisa, AJX->AJX_SUBCOM } )
				PA205IncSub( cProjet, cRevisa, AJX->AJX_SUBCOM, @aExport, lExporta )
			EndIf

			RestArea( aArea )

			AJX->( DbSkip() )
		End
	Else
		DbSelectArea( "AEJ" )
		AEJ->( DbSetOrder( 1 ) )
		AEJ->( DbSeek( xFilial( "AEJ" ) + cCompun ) )
		While AEJ->( !Eof() ) .AND. AEJ->( AEJ_FILIAL + AEJ_COMPOS ) == xFilial( "AEJ" ) + cCompun
			aArea := AEJ->( GetArea() )

			If !Empty( AEJ->AEJ_SUBCOM )
				aAdd( aExport, { cProjet, cRevisa, AEJ->AEJ_SUBCOM } )
				PA205IncSub( cProjet, cRevisa, AEJ->AEJ_SUBCOM, @aExport, lExporta )
			EndIf

			RestArea( aArea )

			AEJ->( DbSkip() )
		End
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³Pma015Salvar ³ Autor ³ Totvs                 ³ Data ³ 01.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Acao do botao SALVAR                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Pma205Salvar( l205Exclui, aGets, aTela, oFolder, aCols, aHeader,;
							  oGD, nRecAJT, aRecAJU, aRecAJV, aRecAJX, l205Altera,;
							  aRecAJURe )

	Local nAtuFolder := oFolder:nOption

	Eval( oFolder:bSetOption )
	If l205Exclui .OR. ( Obrigatorio(aGets,aTela) .And. AGDTudok(1,oFolder) .And. AGDTudok(2,oFolder) .And. AGDTudok(3,oFolder) )
		a205Grava( l205Exclui, nRecAJT )
	EndIf

	A205SetOption( nAtuFolder, oFolder:nOption, @aCols, @aHeader, @oGD )

	MsgAlert( STR0062 ) 

	oFolder:nOption := nAtuFolder
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA205Pesq    ³ Autor ³ Totvs                 ³ Data ³ 01.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Efetua a pesquisa no aCols do MsGetDados e posiciona          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA205Pesq( nRadio, cPesq )
	Local aAuxCols	:= aClone( aCols )
	Local nSearch	:= 0
	
	If Len( aAuxCols ) > 0
		// Ordena o aCols conforme a opcao do usuario (Radio)
		aAuxCols := aSort( aAuxCols,,, { |x,y| x[nRadio] < y[nRadio]  } )

		// Localiza o item desejado (Edit)
		nSearch := aScan( aAuxCols, { |x| AllTrim( cPesq ) $ AllTrim( x[nRadio] ) } )
		If nSearch > 0
			oGetD:nAt					:= nSearch
			oGetD:oBrowse:nAt			:= nSearch
			oGetD:aCols					:= aClone( aAuxCols )

			oGetD:lChgField				:= .F.
			oGetD:oBrowse:lHitBottom	:= .F.
			
			oGetD:oBrowse:Refresh()
			oGetD:oBrowse:SetFocus()
		EndIf
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³Pma205CpyComp³ Autor ³ Totvs                 ³ Data ³ 21.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Realiza a copia de uma comp. auxiliar para o projeto.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pma205CpyComp( cProjet, cRevisa, cCompun, lExporta, cPrjPara, cRevPara, cTarefa )
	Default lExporta := .F.
	Default cPrjPara := ""
	Default cRevPara := ""

	If !lExporta
		DbSelectArea( "AJT" )
		AJT->( DbSetOrder( 2 ) )
		If !AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) )
			DbSelectArea( "AEG" )
			AEG->( DbSetOrder( 1 ) )
			If AEG->( DbSeek( xFilial( "AJT" ) + cCompun ) )
				Pa205Imp2( cProjet, cRevisa, cCompun )
			Else
				Help( " ", 1, STR0039, STR0055, STR0064, 1, 0 ) // "Composicoes Unicas" # "Importar" # "Composicao Auxiliar não encontrada!"
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PMA015Inv  ³ Autor ³ Totvs                 ³ Data ³ 24/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca titulos					  	         		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PMA205Inv( cMarca, lTodos, oMark )
Local nReg := TRB->(Recno())

DEFAULT lTodos  := .T.

DbSelectArea( "TRB" )
If lTodos
	DbGoTop()
EndIf

While !lTodos .Or. !Eof()
	If TRB->OK == cMarca
		RecLock("TRB")
		Replace OK With Space(02)
		TRB->(MsUnlock())
	Else
		RecLock("TRB")
		Replace OK With cMarca
		TRB->(MsUnlock())
	EndIf

	If lTodos
		TRB->(dbSkip())
	Else
		Exit
	Endif
End

DbGoTo( nReg )

Return(NIL)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PA205Insumos³ Autor ³ Totvs                 ³ Data ³ 29/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Localiza os insumos e sub-insumos para efetuar a copia       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PA205Insumos( cInsumo, lImporta, cProjet, cRevisa )
	Local aReturn	:= { cInsumo }
	Local aAreaAEX	:= AEK->( GetArea() )

	If lImporta
		DbSelectArea( "AEK" )
		AEK->( DbSetOrder( 1 ) )
		AEK->( DbSeek( xFilial( "AEK" ) + cInsumo ) )
		While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + cInsumo
			aAreaAEX	:= AEK->( GetArea() )
			If !Empty( AEK->AEK_SUBCOD ) // Protecao
				aAdd( aReturn, AEK->AEK_SUBCOD )
				PA205Insumos( AEK->AEK_SUBCOD, lImporta )
			EndIf
	
			AEK->( RestArea( aAreaAEX ) )
			AEK->( DbSkip() )
		End
	Else
		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 1 ) )
		AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
		While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
			aAreaAEX	:= AEM->( GetArea() )
			If !Empty( AEM->AEM_SUBINS ) // Protecao
				aAdd( aReturn, AEM->AEM_SUBINS )
				PA205Insumos( AEM->AEM_SUBINS, lImporta, cProjet, cRevisa )
			EndIf
	
			AEM->( RestArea( aAreaAEX ) )
			AEM->( DbSkip() )
		End
	EndIf
Return aReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A205Cancel³ Autor ³ Marcelo Akama         ³ Data ³ 28/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui composicoes incluidas.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA205.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A205Cancel()
/*
	Local aAreaAJT		:= AJT->( GetArea() )
	Local bCampo		:= { |n| FieldName( n ) }
	Local cCodiSubC 	:= ""
	Local cInsumo		:= ""
	Local cSubCom		:= ""
	Local nPosProd		:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AJU_INSUMO" } )
	Local nPosDescri	:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AJV_DESCRI" } )
	Local nPosSubCmp	:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AJX_SUBCOM" } )
	Local nPosItem1		:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AJU_ITEM"   } )
	Local nPosItem2		:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AJV_ITEM"   } )
	Local nPosItem3		:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AJX_ITEM"   } )
	Local nCntFor
	Local nCntFor2
	Local nx
	Local nTotCampos

	Default cProjet		:= M->AJT_PROJET
	Default cRevisa 	:= M->AJT_REVISA
	Default cCompun		:= M->AJT_COMPUN

	Begin Transaction

	If ! lExclui
		// grava arquivo AJT (Composicoes)
		DbSelectArea( "AJT" )
		AJT->( DbSetOrder( 2 ) )
		If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) ) 
			RecLock( "AJT" )
		Else
			RecLock( "AJT", .T. )
		EndIf

		For nCntFor := 1 To FCount()
			If "FILIAL" $ Field( nCntFor )
				FieldPut( nCntFor, xFilial( "AJT" ) )
			Else
				FieldPut( nCntFor, M->&( Eval( bCampo, nCntFor ) ) )
			EndIf
		Next nCntFor

		AJT->AJT_FILIAL	:= xFilial( "AJT" )
		AJT->AJT_PROJET	:= cProjet
		AJT->AJT_REVISA	:= cRevisa
		AJT->AJT_COMPUN	:= cCompun
		AJT->AJT_ULTATU	:= MsDate()
		AJT->( MsUnlock() )
		
		
		// grava arquivo AJX (SubComposicoes)
		dbSelectArea("AJX")
		AJX->(dbSetOrder(2))
		For nCntFor := 1 To Len( aColsSV[ 3 ] )
			aAreaAJT	:= AJT->( GetArea() )
			nTotCampos	:= Len( aColsSV[ 3 ][ nCntFor ] )
				If AJX->(dbSeek(xfilial("AJX") + M->AJT_PROJET + M->AJT_REVISA + M->AJT_COMPUN + aColsSV[3][nCntFor][nPosItem3]))
					RecLock("AJX",.F.,.T.)
					AJX->( DbDelete() )
					AJX->( MsUnlock() )

					If PMSA205Del( AJX->AJX_SUBCOM, M->AJT_PROJET, M->AJT_REVISA, .F. )
						DbSelectArea( "AJT" )
						AJT->( DbSetOrder( 2 ) )
						If AJT->( DbSeek( xFilial( "AJT" ) + M->AJT_PROJET + M->AJT_REVISA + AJX->AJX_SUBCOM ) )
							a205Grava( .T., AJT->( RecNo() ) )
						EndIf
					EndIf
				EndIf
			EndIf
			
			AJT->( RestArea( aAreaAJT ) )
		Next nCntFor
	EndIf

	End Transaction
*/

Local aAreaAJT	:= AJT->( GetArea() )
Local cProjet	:= M->AJT_PROJET
Local cRevisa	:= M->AJT_REVISA

Begin Transaction

	DbSelectArea( "AJT" )
	AJT->( DbSetOrder( 2 ) )
	AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa ) )
	Do While AJT->( AJT_FILIAL+AJT_PROJET+AJT_REVISA ) == xFilial( "AJT" ) + cProjet + cRevisa
		aAreaAJT := AJT->( GetArea() )
		If PMSA205Del( AJT->AJT_COMPUN, AJT->AJT_PROJET, AJT->AJT_REVISA, .F. )
			a205Grava( .T., AJT->( RecNo() ) )
		EndIf

		AJT->( RestArea( aAreaAJT ) )
		AJT->(dbSkip())
	EndDo
	A204Cancel()
		
End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Pa205Imp2  ºAutor³ Marcelo Akama             º Data ³ 23/11/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Importacao de composicao Aux                                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Pa205Imp2(cAlias,nReg,nOpcx)                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Codigo do Projeto                                           º±±
±±º          ³ ExpC2 - Revisao do Projeto                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pa205Imp2( cProjet, cRevisa, cCompun )
Local aFields
Local aInsumos
Local cCampo
Local nX, nY
Local lNewRec
Local aArea		:= GetArea()
Local aAreaAEG	:= AEG->(GetArea())
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAEH	:= AEH->(GetArea())
Local aAreaAJU	:= AJU->(GetArea())
Local aAreaAEI	:= AEI->(GetArea())
Local aAreaAJV	:= AJV->(GetArea())
Local aAreaAEJ	:= AEJ->(GetArea())
Local aAreaAJX	:= AJX->(GetArea())
Local aAreaAJY	:= AJY->(GetArea())
Local aAreaAJZ	:= AJZ->(GetArea())
Local aAreaAEM	:= AEM->(GetArea())
Local aAreaAEK	:= AEK->(GetArea())

dbSelectArea("AEG")
AEG->(dbSetOrder(1)) // AEG_FILIAL+AEG_COMPUN
If AEG->( DbSeek( xFilial( "AEG" ) + cCompun ) )
	dbSelectArea("AJT")
	AJT->(dbSetOrder(2)) // AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
	If !AJT->(dbSeek(xFilial("AJT")+cProjet+cRevisa+cCompun))

		// Banco de Composicao Aux
		dbSelectArea("AJT")
		AJT->(dbSetOrder(2)) // AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
		dbSelectArea("AEG")
		AEG->(dbSetOrder(1)) // AEG_FILIAL+AEG_COMPUN
		AEG->(DbSeek(xFilial("AEG")+cCompun))
		aFields := AEG->(DbStruct())
		Do While !AEG->(Eof()) .And. AEG->AEG_FILIAL == xFilial("AEG") .And. AEG->AEG_COMPUN == cCompun
			If !AJT->(dbSeek(xFilial("AJT")+cProjet+cRevisa+cCompun))
				RecLock("AJT",.T.)
				For nX := 1 To Len( aFields )
					cCampo := "AJT_" + AllTrim(substr(aFields[nX][1],5))
					If AJT->(FieldPos(cCampo)) > 0
						AJT->(&(cCampo)) := AEG->(&(aFields[nX][1]))
					EndIf
				Next nX
				AJT->AJT_FILIAL := xFilial("AJT")
				AJT->AJT_PROJET := cProjet
				AJT->AJT_REVISA := cRevisa
				AJT->(MsUnLock())
			EndIf
			AEG->(DbSkip())
		EndDo
		
		// Insumo X Banco de Composicao Aux
		DbSelectArea("AJU")
		AJU->(DbSetOrder(3)) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJU->(DbSeek(xFilial("AJU")+cProjet+cRevisa+cCompun))
		Do While !AJU->(Eof()) .And. AJU->AJU_FILIAL == xFilial("AJU") .And. AJU->(AJU_PROJET+AJU_REVISA+AJU_COMPUN) == cProjet+cRevisa+cCompun
			RecLock( "AJU" )
			AJU->( DbDelete() )
			AJU->( MsUnLock() )
			AJU->( DbSkip() )
		EndDo
		dbSelectArea("AEH")
		AEH->(dbSetOrder(1)) // AEH_FILIAL+AEH_COMPUN+AEH_ITEM
		AEH->(DbSeek(xFilial("AEH")+cCompun))
		aFields := AEH->(DbStruct())
		Do While !AEH->(Eof()) .And. AEH->AEH_FILIAL == xFilial("AEH") .And. AEH->AEH_COMPUN == cCompun
			RecLock("AJU",.T.)
			For nX := 1 To Len( aFields )
				cCampo := "AJU_" + AllTrim(substr(aFields[nX][1],5))
				If AJU->(FieldPos(cCampo)) > 0
					AJU->(&(cCampo)) := AEH->(&(aFields[nX][1]))
				EndIf
			Next nX
			AJU->AJU_FILIAL := xFilial("AJU")
			AJU->AJU_PROJET := cProjet
			AJU->AJU_REVISA := cRevisa
			AJU->(MsUnLock())
			AEH->(DbSkip())
		EndDo
		
		// Despesas da Composicao Aux do Banco
		DbSelectArea("AJV")
		AJV->(DbSetOrder(2)) //AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN+AJV_ITEM
		AJV->(DbSeek(xFilial("AJV")+cProjet+cRevisa+cCompun))
		Do While !AJV->(Eof()) .And. AJV->AJV_FILIAL == xFilial("AJV") .And. AJV->(AJV_PROJET+AJV_REVISA+AJV_COMPUN) == cProjet+cRevisa+cCompun
			RecLock( "AJV" )
			AJV->( DbDelete() )
			AJV->( MsUnLock() )
			AJV->( DbSkip() )
		EndDo
		dbSelectArea("AEI")
		AEI->(dbSetOrder(1)) // AEI_FILIAL+AEI_COMPUN+AEI_ITEM
		AEI->(DbSeek(xFilial("AEI")+cCompun))
		aFields := AEI->(DbStruct())
		Do While !AEI->(Eof()) .And. AEI->AEI_FILIAL == xFilial("AEI") .And. AEI->AEI_COMPUN == cCompun
			RecLock("AJV",.T.)
			For nX := 1 To Len( aFields )
				cCampo := "AJV_" + AllTrim(substr(aFields[nX][1],5))
				If AJV->(FieldPos(cCampo)) > 0
					AJV->(&(cCampo)) := AEI->(&(aFields[nX][1]))
				EndIf
			Next nX
			AJV->AJV_FILIAL := xFilial("AJV")
			AJV->AJV_PROJET := cProjet
			AJV->AJV_REVISA := cRevisa
			AJV->(MsUnLock())
			AEI->(DbSkip())
		EndDo
		
		// SubComposicao da Composicao Aux do Banco
		dbSelectArea("AJX")
		AJX->(dbSetOrder(4)) // AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_SUBCOM
		dbSelectArea("AEJ")
		AEJ->(dbSetOrder(1)) // AEJ_FILIAL+AEJ_COMPOS+AEJ_ITEM
		AEJ->(DbSeek(xFilial("AEJ")+cCompun))
		aFields := AEJ->(DbStruct())
		Do While !AEJ->(Eof()) .And. AEJ->AEJ_FILIAL == xFilial("AEJ") .And. AEJ->AEJ_COMPOS == cCompun
			If !AJX->(dbSeek(xFilial("AJX")+cProjet+cRevisa+AEJ->AEJ_COMPOS+AEJ->AEJ_SUBCOM))
				RecLock("AJX",.T.)
				For nX := 1 To Len( aFields )
					cCampo := "AJX_" + AllTrim(substr(aFields[nX][1],5))
					If AJX->(FieldPos(cCampo)) > 0
						AJX->(&(cCampo)) := AEJ->(&(aFields[nX][1]))
					EndIf
				Next nX
				AJX->AJX_FILIAL := xFilial("AJX")
				AJX->AJX_PROJET := cProjet
				AJX->AJX_REVISA := cRevisa
				AJX->AJX_COMPUN := AEJ->AEJ_COMPOS
				AJX->(MsUnLock())
				Pa205Imp2( cProjet, cRevisa, AEJ->AEJ_SUBCOM )
			EndIf
			AEJ->(DbSkip())
		EndDo

		// Insumos
		DbSelectArea("AJU")
		AJU->(DbSetOrder(3)) // AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJU->(DbSeek(xFilial("AJU")+cProjet+cRevisa+cCompun))
		Do While !AJU->(Eof()) .And. AJU->AJU_FILIAL == xFilial("AJU") .And. AJU->(AJU_PROJET+AJU_REVISA+AJU_COMPUN) == cProjet+cRevisa+cCompun
			// Insumo
			DbSelectArea("AJY")
			AJY->(DbSetOrder(1)) // AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
			AJY->(DbSeek(xFilial("AJY")+AJU->(AJU_PROJET+AJU_REVISA+AJU_INSUMO)))
			Do While !AJY->(Eof()) .And. AJY->AJY_FILIAL == xFilial("AJY") .And. AJY->(AJY_PROJET+AJY_REVISA+AJY_INSUMO) == AJU->(AJU_PROJET+AJU_REVISA+AJU_INSUMO)
				RecLock("AJY")
				AJY->(DbDelete())
				AJY->(DbSkip())
			EndDo

			aInsumos := PA205Insumos(AJU->AJU_INSUMO,.T.)
			For nX := 1 To Len(aInsumos)
				DbSelectArea("AJZ")
				AJZ->(DbSetOrder(1))
				If AJZ->(DbSeek(xFilial("AJZ")+aInsumos[nX]))
					aFields := AJZ->(DbStruct())

					If !AJY->(DbSeek(xFilial("AJY")+AJU->(AJU_PROJET+AJU_REVISA+aInsumos[nX])))
						RecLock("AJY",.T.)
						For nY := 1 To Len(aFields)
							cCampo := "AJY_"+AllTrim(substr(aFields[nY][1],5))
							If AJY->(FieldPos(cCampo))>0
								AJY->(&(cCampo)) := AJZ->(&(aFields[nY][1]))
							EndIf
						Next nY
					
						If AJZ->AJZ_GRORGA=='A' .And. AJZ->AJZ_TPPARC $ '1;2'
							AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJZ->AJZ_DEPREC, 0) +;
												IIf(AF8->AF8_JUROS  $ "13", AJZ->AJZ_VLJURO, 0) +;
												IIf(AF8->AF8_MDO    $ "13", AJZ->AJZ_MDO   , 0) +;
												IIf(AF8->AF8_MATERI $ "13", AJZ->AJZ_MATERI, 0) +;
												IIf(AF8->AF8_MANUT  $ "13", AJZ->AJZ_MANUT , 0)
							AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJZ->AJZ_DEPREC, 0) +;
												IIf(AF8->AF8_JUROS  $ "23", AJZ->AJZ_VLJURO, 0) +;
												IIf(AF8->AF8_MDO    $ "23", AJZ->AJZ_MDO   , 0)
						EndIf

						AJY->AJY_FILIAL := xFilial("AJY")
						AJY->AJY_PROJET := AJU->AJU_PROJET
						AJY->AJY_REVISA := AJU->AJU_REVISA
						AJY->(MsUnLock())
					EndIf
				EndIf
				
				// Estrutura do Insumo
				DbSelectArea("AEM")
				AEM->(DbSetOrder(1)) // AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_INSUMO+AEM_ITEM
				AEM->(DbSeek(xFilial("AEM")+AJU->(AJU_PROJET+AJU_REVISA+aInsumos[nX])))
				Do While !AEM->(Eof()) .And. AEM->AEM_FILIAL == xFilial("AEM") .And. AEM->(AEM_PROJET+AEM_REVISA+AEM_INSUMO) == AJU->(AJU_PROJET+AJU_REVISA+aInsumos[nX])
					RecLock("AEM")
					AEM->(DbDelete())
					AEM->(DbSkip())
				EndDo

				DbSelectArea("AEK")
				AEK->(DbSetOrder(1)) // AEK_FILIAL+AEK_INSUMO+AEK_ITEM
				AEK->(DbSeek(xFilial("AEK")+aInsumos[nX]))
				Do While !AEK->(Eof()) .And. AEK->(AEK_FILIAL+AEK_INSUMO) == xFilial("AEK") + aInsumos[nX]
					aFields := AEK->(DbStruct())

					lNewRec := !AEM->(DbSeek(xFilial("AEM")+AJU->(AJU_PROJET+AJU_REVISA+AEK->AEK_SUBCOD)))
					RecLock("AEM",lNewRec)
					For nY := 1 To Len(aFields)
						cCampo := "AEM_"+AllTrim(substr(aFields[nY][1],5))
						If AEM->(FieldPos(cCampo))>0
							AEM->(&(cCampo)) := AEK->(&(aFields[nY][1]))
						EndIf
					Next
					
					AEM->AEM_FILIAL := xFilial("AEM")
					AEM->AEM_PROJET := AJU->AJU_PROJET
					AEM->AEM_REVISA := AJU->AJU_REVISA
					AEM->AEM_SUBINS := AEK->AEK_SUBCOD
					AEM->(MsUnLock())

					AEK->(DbSkip())
				EndDo
			Next nX
									
			AJU->(DbSkip())
		EndDo

	EndIf
EndIf

RestArea(aAreaAJZ)
RestArea(aAreaAJY)
RestArea(aAreaAJX)
RestArea(aAreaAEJ)
RestArea(aAreaAJV)
RestArea(aAreaAEI)
RestArea(aAreaAJU)
RestArea(aAreaAEH)
RestArea(aAreaAJT)
RestArea(aAreaAEG)
RestArea(aArea)

Return
