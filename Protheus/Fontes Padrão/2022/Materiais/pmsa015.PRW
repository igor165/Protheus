#include "pmsa015.ch"
#include "protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMSA015  ³Autor  ³ Totvs				  ³ Data ³18/10/2008      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Composicoes Auxiliares                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Número da rotina chamada na MBrowse                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSA015(nRotina)

Private cCadastro	:= STR0001										//"Composicoes Auxiliares"
Private lUsaCCT 	:= GetMV( "MV_PMSCCT" ) == "2"                 // 1=Nao;2=Sim
Private aRotina 	:= MenuDef()
Private lConfirma 	:= .T.

SaveInter()

// so executa se houver o template aplicadoc com licença, caso 
// contrario mostra uma mensagem de alerta e aborta
ChkTemplate("CCT")
	
If AMIIn( 44 ) 
	If nRotina != Nil
		PA015Dialog("AEG",AEG->(RecNo()),nRotina)
	Else
		mBrowse(6,1,22,75,"AEG")
	EndIf
EndIf

RestInter()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PA015Dialog³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Composicoes                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PA015Dialog(cAlias,nReg,nOpcx)

Local oDlg
Local l015Inclui	:= nOpcx == 3
Local lContinua		:= .T.
Local l015Visual	:= nOpcx == 2 .Or. nOpcx == 5
Local l015Altera	:= nOpcx == 4
Local l015Exclui	:= nOpcx == 5
Local aSize			:= {}
Local aObjects		:= {}
Local aPages		:= { '' }
Local nOpcA			:= 0
Local aRecAEH		:= {}
Local aRecAEI		:= {}
Local aRecAEJ		:= {}
Local aRecAEHRe 	:= {}
Local nRecAEG		:= AEG->( RecNo() )
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
Local cFilAEG 		:= xFilial( "AEG" )
Local cFilAEH 		:= xFilial( "AEH" )
Local cFilAEI 		:= xFilial( "AEI" )
Local cFilAEJ 		:= xFilial( "AEJ" )
Local cFilAJZ 		:= xFilial( "AJZ" )

Local nPosQtSub 	:= 0
Local nPosCusIt		:= 0
Local nPosCusto		:= 0

Local nPIndImp		:= 0
Local nPIndPrd		:= 0
Local nPCusPrd		:= 0
Local nPCusImp		:= 0
Local nPCustd	 	:= 0
Local nPGrOrga		:= 0
Local nAux			:= 0
Local nLenItem		:= 0

Local nPDMT			:= 0
Local nPGrOrga		:= 0
Local nPCstItem		:= 0
Local nPQtde		:= 0

If ExistBlock("PMA015BTN")
	aButtons:= ExecBlock("PMA015BTN",.F.,.F.)
EndIf

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

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l015Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l015Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l015Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
      If PMSA015Del(AEG->AEG_COMPUN)
			l015Exclui	:= .T.
			l015Visual	:= .T.
		Else
			l015Exclui	:= .F.
			l015Visual	:= .F.						
      EndIf
EndCase

RegToMemory("AEG",l015Inclui)

// montagem do aHeaderAEH
dbSelectArea( "SX3" )
dbSetOrder( 1 )
dbSeek( "AEH" )
While !Eof() .And. ( SX3->X3_ARQUIVO == "AEH")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO) $ "AEH_RECURS")
		AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

SX3->( DbSeek( "AEH_FILIAL" ) )
cUsado := SX3->X3_USADO

AADD( aHeaderSV[1], { "Alias WT","AEH_ALI_WT", "", 09, 0,, cUsado, "C", "AEH", "V"} )
AADD( aHeaderSV[1], { "Recno WT","AEH_REC_WT", "", 09, 0,, cUsado, "N", "AEH", "V"} )

FillGetDados(nOpcx,"AEI",1,,,,,,,,{||.T.},.T.,aHeaderSV[2])
FillGetDados(nOpcx,"AEJ",1,,,,,,,,{||.T.},.T.,aHeaderSV[3])

If l015Inclui
	
	// faz a montagem de uma linha em branco no aColsAEH
	aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
	For ny := 1 to Len(aHeaderSV[1])
		If Trim(aHeaderSV[1][ny][2]) == "AEH_ITEM"
			aColsSV[1][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AEH_ALI_WT | AEH_REC_WT"
			If AllTrim(aHeaderSV[1][ny][2]) == "AEH_ALI_WT"
				aColsSV[1][1][ny] := "AEH"
			ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AEH_REC_WT"
				aColsSV[1][1][ny] := 0
			EndIf
		Else
			aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
		EndIf

		aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
	Next ny
	
	// faz a montagem de uma linha em branco no aColsAEI
	aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
	For ny := 1 to Len(aHeaderSV[2])
		If Trim(aHeaderSV[2][ny][2]) == "AEI_ITEM"
			aColsSV[2][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AEI_ALI_WT | AEI_REC_WT"
			If AllTrim(aHeaderSV[2][ny][2]) == "AEI_ALI_WT"
				aColsSV[2][1][ny] := "AEI"
			ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AEI_REC_WT"
				aColsSV[2][1][ny] := 0
			EndIf
		Else
			aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
		EndIf

		aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
	Next ny
	
	// faz a montagem de uma linha em branco no aColsAEJ
	aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
	For ny := 1 to Len(aHeaderSV[3])
		If Trim(aHeaderSV[3][ny][2]) == "AEJ_ITEM"
			aColsSV[3][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AEJ_ALI_WT | AEJ_REC_WT"
			If AllTrim(aHeaderSV[3][ny][2]) == "AEJ_ALI_WT"
				aColsSV[3][1][ny] := "AEJ"
			ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AEJ_REC_WT"
				aColsSV[3][1][ny] := 0
			EndIf
		Else
			aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
		EndIf
		aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
	Next ny
Else

	// trava o registro do AEG - Alteracao,Visualizacao
	If l015Altera .Or. l015Exclui
		If !SoftLock("AEG")
			lContinua := .F.
		Endif
	EndIf

	// faz a montagem do aColsAEH
	dbSelectArea("AEH")
	AEH->(dbSetOrder(1))
	AEH->(dbSeek(xFilial("AEH") + AEG->AEG_COMPUN))
	While ! AEH->(Eof()) .And. AEH->(AEH_FILIAL + AEH_COMPUN) ==;
		xFilial("AEH") + AEG->AEG_COMPUN .And. lContinua
		
		// trava o registro do AEH - Alteracao, Exclusao
		If l015Altera .Or. l015Exclui
			If !SoftLock("AEH")
				lContinua := .F.
			Else
				aAdd(aRecAEH,RecNo())
			Endif
		EndIf

		AJZ->( DbSetOrder( 1 ) )
		If AJZ->( dbSeek( xFilial( "AJZ" ) + AEH->AEH_INSUMO ) )
			aAdd( aColsSV[ 1 ], Array( Len( aHeaderSV[ 1 ] ) + 1 ) )
		
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_TIPO"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJZ->AJZ_TIPO
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_DESCRI"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJZ->AJZ_DESC
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_UM"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJZ->AJZ_UM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_SEGUM"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJZ->AJZ_SEGUM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_SIMBCS"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := GetMV("MV_SIMB"+ AJZ->AJZ_MCUSTD)
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_CUSTD"
							If !Empty(AEH->AEH_INSUMO)
								aColsSV[1][Len(aColsSV[1])][ny] := AJZ->AJZ_CUSTD
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_ALI_WT"
							aColsSV[1][Len(aColsSV[1])][ny] := "AEH"
						Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_REC_WT"
							aColsSV[1][Len(aColsSV[1])][ny] := AEH->(Recno())
						OtherWise
							aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
					EndCase
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny

			// Atualiza o custo conforme horas produtivas/improdutivas com todos os campos do acol preenchido
			nLenItem := Len( aColsSV[1] )
			nPIndImp	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_HRIMPR" 	} )
			nPIndPrd	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_HRPROD" 	} )
			nPCusPrd	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_CUSPRD" 	} )		
			nPCusImp	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_CUSIMP" 	} ) 
			nPCustd 	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_CUSTD"  	} )
			nPDMT		:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_DMT"		} )
			nPGrOrga	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_GRORGA" 	} )
			nPCstItem	:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_CSTITM" 	} )
			nPQtde		:= aScan( aHeaderSV[1], { |x| AllTrim( x[2] ) == "AEH_QUANT" 	} )

			For ny := 1 to Len(aHeaderSV[1])
				Do Case
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AEH_CUSPRD" .AND. ( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						aColsSV[1][nLenItem][nPCusPrd]	:= 0
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AEH_HRPROD" .AND. !( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						nAux	:= aColsSV[1][nLenItem][nPIndPrd]
						aColsSV[1][nLenItem][nPCustd]	:= (aColsSV[1][nLenItem][nPCusPrd] * nAux) + (aColsSV[1][nLenItem][nPCusImp] * aColsSV[1][nLenItem][nPIndImp])	
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AEH_HRIMPR" .AND. !( aColsSV[1][nLenItem][nPGrOrga] $ "B*E*F" )
						nAux	:= aColsSV[1][nLenItem][nPIndImp]
						aColsSV[1][nLenItem][nPCustd]	:= (aColsSV[1][nLenItem][nPCusPrd] * aColsSV[1][nLenItem][nPIndPrd]) + (aColsSV[1][nLenItem][nPCusImp] * nAux)	
				EndCase
			Next

			// Atualiza o custo conforme DMT
			nLenItem := Len( aColsSV[1] )
			For ny := 1 to Len(aHeaderSV[1])
				Do Case
					Case AllTrim( aHeaderSV[1][ny][2] ) == "AEH_DMT" .And. aColsSV[1][nLenItem][nPGrOrga] == "A"
						nAux	:= aColsSV[1][nLenItem][nPDMT]
						If nAux > 0
							aColsSV[1][nLenItem][nPCstItem]	:= aColsSV[1][nLenItem][nPQtde] * aColsSV[1][nLenItem][nPCustd] * nAux
						EndIf
				EndCase
			Next
		EndIf

		AEH->(dbSkip())
	End
	
	If Empty(aColsSV[1])
		// faz a montagem de uma linha em branco no aColsAEH
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			
			If Trim(aHeaderSV[1][ny][2]) == "AEH_ITEM"
				aColsSV[1][1][ny] 	:= "01"
				
			ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AEH_ALI_WT | AEH_REC_WT"
				If AllTrim(aHeaderSV[1][ny][2]) == "AEH_ALI_WT"
					aColsSV[1][1][ny] := "AEH"
				ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AEH_REC_WT"
					aColsSV[1][1][ny] := 0
				EndIf
			Else
				aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf

			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf
	
	// faz a montagem do aColsAEI
	dbSelectArea("AEI")
	AEI->(dbSetOrder(1))
	AEI->(dbSeek(xFilial("AEI") + AEG->AEG_COMPUN ))
	While !AEI->(Eof()) .And. AEI->(AEI_FILIAL + AEI_COMPUN) ==;
			 xFilial("AEI") + AEG->AEG_COMPUN .And. lContinua
		
		// trava o registro do AEI - Alteracao,Exclusao
		If l015Altera.Or.l015Exclui
			If !SoftLock("AEI")
				lContinua := .F.
			Else
				aAdd(aRecAEI,RecNo())
			Endif
		EndIf
		
		aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			SX5->(dbSetOrder(1))
			SX5->(dbSeek(xFilial()+"02"+AEI->AEI_TIPOD))
			If ( aHeaderSV[2][ny][10] != "V")
				aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
			Else
				Do Case
					Case Alltrim(aHeaderSV[2][ny][2]) == "AEI_DESCTP"
						aColsSV[2][Len(aColsSV[2])][ny] := X5DESCRI()
					Case Alltrim(aHeaderSV[2][ny][2]) == "AEI_SIMBMO"
						aColsSV[2][Len(aColsSV[2])][ny] := GetMv("MV_SIMB"+Alltrim(STR(AEI->AEI_MOEDA,2,0)))
					Case AllTrim(aHeaderSV[2][ny][2]) == "AEI_ALI_WT"
						aColsSV[2][Len(aColsSV[2])][ny] := "AEI"
					Case AllTrim(aHeaderSV[2][ny][2]) == "AEI_REC_WT"
						aColsSV[2][Len(aColsSV[2])][ny] := AEI->(Recno())
					OtherWise
						aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
				EndCase
			EndIf
			aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
		Next ny
		AEI->(dbSkip())
	EndDo
	
	If Empty(aColsSV[2])
		// faz a montagem de uma linha em branco no aColsAEI
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AEI_ITEM"
				aColsSV[2][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AEI_ALI_WT | AEI_REC_WT"
				If AllTrim(aHeaderSV[2][ny][2]) == "AEI_ALI_WT"
					aColsSV[2][1][ny] := "AEI"
				ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AEI_REC_WT"
					aColsSV[2][1][ny] := 0
				EndIf
			Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf
	
	// faz a montagem do aColsAEJ
	nPosQtSub 	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2]) == "AEJ_QUANT"})
	nPosCusIt	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2]) == "AEJ_CUSIT"})
	nPosCusto	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2]) == "AEJ_CUSTO"})

	dbSelectArea("AEJ")
	AEJ->(dbSetOrder(1))
	AEJ->(dbSeek(xFilial("AEJ") + AEG->AEG_COMPUN))
	While ! AEJ->(Eof()) .And. AEJ->(AEJ_FILIAL + AEJ->AEJ_COMPOS) ==;
		xFilial("AEJ") + AEG->AEG_COMPUN .And. lContinua
		
		// posiciona na Sub-Composicao
		aAuxArea := AEG->(GetArea()	)
		AEG->(dbSetOrder(1))
		If AEG->(dbSeek(xFilial("AEG") + AEJ->AEJ_SUBCOM))
			dbSelectArea("AEJ")
			
			// trava o registro do AEJ - Alteracao,Exclusao
			If l015Altera .Or. l015Exclui
				If !SoftLock("AEJ")
					lContinua := .F.
				Else
					aAdd(aRecAEJ,RecNo())
				Endif
			EndIf
			
			aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
			For ny := 1 to Len(aHeaderSV[3])
				If ( aHeaderSV[3][ny][10] != "V")
					aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
				Else
					Do Case
						Case Alltrim(aHeaderSV[3][ny][2]) == "AEJ_DESCRI"
							aColsSV[3][Len(aColsSV[3])][ny] := AEG->AEG_DESCRI
						Case Alltrim(aHeaderSV[3][ny][2]) == "AEJ_UM"
							aColsSV[3][Len(aColsSV[3])][ny] := AEG->AEG_UM
						Case AllTrim(aHeaderSV[3][ny][2]) == "AEJ_ALI_WT"
							aColsSV[3][Len(aColsSV[3])][ny] := "AEJ"
						Case AllTrim(aHeaderSV[3][ny][2]) == "AEJ_REC_WT"
							aColsSV[3][Len(aColsSV[3])][ny] := AEJ->(Recno())
						OtherWise
							aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
					EndCase
				EndIf
				aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
			Next ny

			If nPosCusIt > 0 .AND. nPosCusto > 0 .AND. ExistTemplate( "CCTAEGCALC" ) .AND. lUsaCCT
				aColsSV[3][Len(aColsSV[3])][nPosCusIt] := aColsSV[3][Len(aColsSV[3])][nPosQtSub] * ExecTemplate( "CCTAEGCALC", .F., .F., { AEJ->AEJ_SUBCOM, '2' } )
			EndIf
		EndIf

		RestArea(aAuxArea)
		AEJ->(dbSkip())
	EndDo
	
	If Empty(aColsSV[3])
		// faz a montagem de uma linha em branco no aColsAEI
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AEJ_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AEJ_ALI_WT | AEJ_REC_WT"
				If AllTrim(aHeaderSV[3][ny][2]) == "AEJ_ALI_WT"
					aColsSV[3][1][ny] := "AEJ"
				ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AEJ_REC_WT"
					aColsSV[3][1][ny] := 0
				EndIf
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	EndIf
EndIf

// valida se utiliza o template CCT
If lUsaCCT
	If ExistTemplate("CCTAJUINI")
		ExecTemplate("CCTAJUINI",.F.,.F., { "AEG" } )
	EndIf
EndIf

// faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize(,.F.,370)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If (l015Inclui .Or. l015Altera .Or. l015Exclui .Or. l015Visual) .AND. lConfirma
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	Zero()
	oEnch:= MsMGet():New(cAlias, nReg, nOpcx,,,,,aPosObj[1],,,,,,oDlg,,.T.,.F.,,.T. )
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
	oFolder:bSetOption:={|nFolder| A015SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@oGD)}
	
	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[1])
	aCols		:= aClone(aColsSV[1])
	oGD[1]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A015GD1LinOk","A015GD1TudOk","+AEH_ITEM",.T.,,1,,300,"A015FdOkA",,,"A015GDDel(1)",oFolder:aDialogs[1])
	
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[2])
	aCols		:= aClone(aColsSV[2])
	oGD[2]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A015GD2LinOk","A015GD2TudOK","+AEI_ITEM",.T.,,1,,300,"A015FdOkB",,,"A015GDDel(2)",oFolder:aDialogs[2])
	
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[3])
	aCols		:= aClone(aColsSV[3])
	oGD[3]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A015GD3LinOk","A015GD3TudOK","+AEJ_ITEM",.T.,,1,,300,"A015FdOkC",,,"A015GDDel(3)",oFolder:aDialogs[3])
	
	aHeader		:= aClone(aHeaderSV[1])
	aCols		:= aClone(aColsSV[1])
	
	If l015Inclui .OR. l015Altera
		aAdd( aButtons, { "SALVAR", { || Pma015Salvar( l015Exclui, aGets, aTela, oFolder, @aCols, @aHeader, @oGD, , nRecAEG, aRecAEH, aRecAEI, aRecAEJ, l015Altera, aRecAEHRe, nOpcX ) }, STR0025 } )
    EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If( l015Exclui .OR. ( Obrigatorio(aGets,aTela) .And.AGDTudok(1,oFolder).And.AGDTudok(2,oFolder).And.AGDTudok(3,oFolder) ) ,(nOpcA:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
EndIf	

If ( ( l015Inclui .Or.l015Altera .Or. l015Exclui ) .And. nOpcA == 1 ) .OR. !lConfirma
	A015Grava( l015Exclui, nRecAEG, aRecAEH, aRecAEI, aRecAEJ, l015Altera, aRecAEHRe )
EndIf

If ExistBlock("PMA015GRV")
	ExecBlock("PMA015GRV",.F.,.F., {l015Inclui,l015Altera,l015Exclui,(nOpcA==1)} )
EndIf

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A015SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA015                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A015SetOption(nFolder,nOldFolder,aCols,aHeader,oGD)

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
±±³Fun‡…o    ³A015GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015GD1LinOk()

Local nPosProd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_INSUMO" } )
Local nContItem := 1
Local lRet 		:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosProd])
		Help("  ",1,"PMSA0101")
		lRet := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica duplicidade de insumos na composicao auxiliar.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aCols ) > 0 .AND. nPosProd > 0 .AND. !Empty( aCols[ n ][ nPosProd ] )
		For nContItem := 1 To Len( aCols )
			If n <> nContItem .AND. aCols[ n ][ nPosProd ] == aCols[ nContItem ][ nPosProd ] .AND. !aCols[ nContItem ][ Len( aCols[ nContItem ] ) ]
				Aviso( STR0026, STR0053, { "Ok" } ) // "Não é permitido duplicidade de insumos em uma composição auxiliar!"
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
±±³Fun‡…o    ³A015GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015GD2LinOk()

Local nPosDescri	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_DESCRI" } )
Local nPosValor		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_VALOR"  } )
Local nPosTP		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_TIPOD"  } )
Local lRet			:= .T.

If n > 0
	If !aCols[n][Len(aHeader)+1]
		If nPosDescri > 0 .AND. Empty(aCols[n][nPosDescri])
			Help("  ",1,"PMSA0103")
			lRet := .F.
		EndIf

		If nPosValor > 0 .AND. lRet .AND. Empty(aCols[n][nPosValor])
			HELP("  ",1,"PMSA0104")
			lRet := .F.
		EndIf

		If nPosTP > 0 .AND. lRet .AND. Empty(aCols[n][nPosTP])
			HELP("  ",1,"PMSA0105")
			lRet := .F.
		EndIf
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
±±³Fun‡…o    ³A015GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 3.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015GD3LinOk()
Local nPosSubC	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEJ_SUBCOM" } )
Local nContItem := 1
Local lRet 		:= .T.

If lRet
	If !aCols[n, Len( aCols[n] ) ]
		For nContItem := 1 to Len(aCols)
			// Verifica se o item foi excluido
			If ! aCols[nContItem,Len(aCols[nContItem])] .And. nContItem <> n
				If aCols[nContItem,nPosSubC] == aCols[n,nPosSubC]
					Aviso(STR0026,STR0028,{"Ok"})
					lRet := .F.
					Exit
				EndIf
			EndIf	
	
			If aCols[nContItem,nPosSubC] == M->AEG_COMPUN
				Aviso( STR0026, STR0062,{ "Ok" } )
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
		lRet := A015GD1Tudok()
	Case nGetDados == 2
		lRet := A015GD2Tudok()
	Case nGetDados == 3
		lRet := A015GD3Tudok()
EndCase

// valida se utiliza o template CCT
If lUsaCCT .And. nGetDados == 1
	If ExistTemplate("CCTAEGCUST")
		ExecTemplate("CCTAEGCUST",.F.,.F.,{nGetDados,,"AEG"})
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
±±³Fun‡…o    ³A015GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados 1                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A015GD1TudOk()
	Local nPosProd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_INSUMO" } )
	Local nSavN		:= n
	Local lRet		:= .T.
	Local nx 		:= 0
	
	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosProd ] )
			If !A015GD1LinOk()
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
±±³Fun‡…o    ³A015GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A015GD2TudOk()
	Local nPosDescri	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_DESCRI" } )
	Local nPosValor		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_VALOR"  } )
	Local nPosTP		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_TIPOD"  } )
	Local nSavN			:= n
	Local lRet			:= .T.
	Local nx 			:= 0

	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosDescri ] ) .Or. !Empty( aCols[ n ][ nposValor ] ) .Or. !Empty( aCols[ n ][ nPosTP ] )
			If !A015GD2LinOk()
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
±±³Fun‡…o    ³A015GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A015GD3TudOk()
	Local nPosSubCmp 	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEJ_SUBCOM" } )
	Local nSavN			:= n
	Local lRet			:= .T.
	Local nx 			:= 0

	For nx := 1 To Len( aCols )
		n := nx
		If !Empty( aCols[ n ][ nPosSubCmp ] )
			If !A015GD3LinOk()
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
±±³Fun‡…o    ³A015Grava³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a gravaco da composicao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA015.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A015Grava(lExclui,nRecAEG,aRecAEH,aRecAEI,aRecAEJ,lAltera,aRecAEHRe)
	Local bCampo		:= { |n| FieldName( n ) }
	Local nPosProd		:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AEH_INSUMO" } )
	Local nPosDescri	:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AEI_DESCRI" } )
	Local nPosSubCmp	:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AEJ_SUBCOM" } )
	Local nPosItem1		:= aScan( aHeaderSV[ 1 ], { |x| AllTrim( x[ 2 ] ) == "AEH_ITEM"   } )
	Local nPosItem2		:= aScan( aHeaderSV[ 2 ], { |x| AllTrim( x[ 2 ] ) == "AEI_ITEM"   } )
	Local nPosItem3		:= aScan( aHeaderSV[ 3 ], { |x| AllTrim( x[ 2 ] ) == "AEJ_ITEM"   } )
	Local nCntFor
	Local nCntFor2
	Local nx
	Local nTotCampos

	// Valida os campos obrigatorios
	If !Obrigatorio( aGets, aTela )
		Return
	EndIf

	Begin Transaction

	If !lExclui
		// grava arquivo AEG (Composicoes)
		DbSelectArea( "AEG" )
		AEG->( DbSetOrder( 1 ) )
		If AEG->( DbSeek( xFilial( "AEG" ) + M->AEG_COMPUN ) ) 
			RecLock( "AEG", .F. )
		Else
			RecLock( "AEG", .T. )
		EndIf

		AEG->AEG_ULTATU	:= dDataBase
		For nCntFor := 1 To FCount()
			If "FILIAL" $ Field( nCntFor )
				FieldPut( nCntFor, xFilial( "AEG" ) )
			Else
				FieldPut( nCntFor, M->&( Eval( bCampo, nCntFor ) ) )
			EndIf
		Next nCntFor

		AEG->AEG_ULTATU	:= MsDate()
		AEG->( MsUnlock() )
		
		// grava arquivo AEH (Insumos)
		DbSelectArea("AEH")
		AEH->( DbSetOrder( 1 ) )
		For nCntFor := 1 To Len( aColsSV[ 1 ] )
			nTotCampos := Len( aColsSV[ 1 ][ nCntFor ] )
			If !aColsSV[ 1 ][ nCntFor ][ nTotCampos ]
				If !Empty( aColsSV[ 1 ][ nCntFor ][ nPosProd ] )
					If AEH->( DbSeek( xFilial( "AEH" ) + M->AEG_COMPUN + aColsSV[ 1 ][ nCntFor ][ nPosItem1 ] ) )
						RecLock( "AEH", .F. )
					Else
						RecLock( "AEH", .T. )
					EndIf

					For nCntFor2 := 1 To Len( aHeaderSV[ 1 ] )
						If ( aHeaderSV[1][nCntFor2][10] != "V" )
							AEH->(FieldPut(FieldPos(aHeaderSV[1][nCntFor2][2]),aColsSV[1][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AEH->AEH_FILIAL	:= xFilial( "AEH" )
					AEH->AEH_COMPUN	:= M->AEG_COMPUN
					AEH->( MsUnlock() )
				EndIf
			Else
				If AEH->(dbSeek(xfilial("AEH") + M->AEG_COMPUN + aColsSV[1][nCntFor][nPosItem1]))
					RecLock("AEH",.F.,.T.)
					AEH->( DbDelete() )
					AEH->( MsUnlock() )
				EndIf
			EndIf
		Next nCntFor
		AEH->( FkCommit() )

		// grava arquivo AEI (Despesas)
		dbSelectArea( "AEI" )
		AEI->( DbSetOrder( 1 ) )
		For nCntFor := 1 To Len( aColsSV[ 2 ] )
			nTotCampos := Len( aColsSV[ 2 ][ nCntFor ] )
			If !aColsSV[ 2 ][ nCntFor ][ nTotCampos ]
				If !Empty(aColsSV[2][nCntFor][nPosDescri])
					If AEI->(dbSeek(xfilial("AEI") + M->AEG_COMPUN + aColsSV[2][nCntFor][nPosItem2]))
						RecLock("AEI",.F.)
					Else
						RecLock("AEI",.T.)
					EndIf

					For nCntFor2 := 1 To Len(aHeaderSV[2])
						If ( aHeaderSV[2][nCntFor2][10] != "V" )
							AEI->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AEI->AEI_FILIAL	:= xFilial("AEI")
					AEI->AEI_COMPUN   := M->AEG_COMPUN
					MsUnlock()
				EndIf
			Else
				If AEI->(dbSeek(xfilial("AEI") + M->AEG_COMPUN + aColsSV[2][nCntFor][nPosItem2]))
					RecLock("AEI",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
		AEI->( FkCommit() )
		
		// grava arquivo AEJ (SubComposicoes)
		dbSelectArea("AEJ")
		AEJ->(dbSetOrder(1))
		For nCntFor := 1 To Len( aColsSV[ 3 ] )
			nTotCampos := Len( aColsSV[ 3 ][ nCntFor ] )
			If !aColsSV[ 3 ][ nCntFor ][ nTotCampos ]
				If !Empty(aColsSV[3][nCntFor][nPosSubCmp])
					If AEJ->(dbSeek(xfilial("AEJ") + M->AEG_COMPUN + aColsSV[3][nCntFor][nPosItem3]))
						RecLock("AEJ",.F.)
					Else
						RecLock("AEJ",.T.)
					EndIf

					For nCntFor2 := 1 To Len(aHeaderSV[3])
						If ( aHeaderSV[3][nCntFor2][10] != "V" )
							AEJ->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2

					AEJ->AEJ_FILIAL	:= xFilial( "AEJ" )
					AEJ->AEJ_COMPOS	:= M->AEG_COMPUN
					AEJ->( MsUnlock() )
				EndIf
			Else
				If AEJ->(dbSeek(xfilial("AEJ") + M->AEG_COMPUN + aColsSV[3][nCntFor][nPosItem3]))
					RecLock("AEJ",.F.,.T.)
					AEJ->( DbDelete() )
					AEJ->( MsUnlock() )
				EndIf
			EndIf
		Next nCntFor
		
		AEJ->( FkCommit() )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui registros referentes a composicao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "AEG" )
		AEG->( DbGoTo( nRecAEG ) )
		If AEG->( !Eof() )
			DbSelectArea("AEH")
			AEH->( DbSetOrder( 1 ) )
			While AEH->( DbSeek( xFilial( "AEH" ) + AEG->AEG_COMPUN ) )
				RecLock( "AEH" )
				AEH->( DbDelete() )
				AEH->( MsUnlock() )
			End

			DbSelectArea( "AEI" )
			AEI->( DbSetOrder( 1 ) )
			While AEI->( DbSeek( xFilial( "AEI" ) + AEG->AEG_COMPUN ) )
				RecLock( "AEI" )
				AEI->( DbDelete() )
				AEI->( MsUnlock() )
			End

			DbSelectArea( "AEJ" )
			AEJ->( DbSetOrder( 1 ) )
			While AEJ->( DbSeek( xFilial( "AEJ" ) + AEG->AEG_COMPUN ) )
				RecLock( "AEJ" )
				AEJ->( DbDelete() )
				AEJ->( MsUnlock() )
			End

			RecLock( "AEG" )
			AEG->( DbDelete() )
			AEG->( MsUnlock() )
		EndIf
	EndIf

	End Transaction
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A015SXBInclui³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Inclusao de Composicoes.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AEG                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015SXBInclui()

PMSA015(3)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A015SXBVisual³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Visualizacao de Composicoes.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AEG                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015SXBVisual()

PMSA015(2)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA015Dupl  ºAutor³ Totvs                     º Data ³ 15/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Duplica a composicao auxiliar para um novo codigo                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PA015Dupl(cAlias,nReg,nOpcx)                                        º±±
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
Function PA015Dupl( cAlias, nReg, nOpcx )
	Local aCampoAEG	:= {}
	Local aCampoAEH	:= {}
	Local aCampoAEI	:= {}
	Local aCampoAEJ	:= {}
	Local aStruct	:= {}
	Local aRegs		:= {}
	Local nCount	:= 0
	Local nInc		:= 0
	Local nFieldPos	:= 0
	Local nTamField	:= TamSX3( "AEG_COMPUN" )[1]
	Local nRegAEG	:= AEG->( RecNo() )

	If ParamBox( { { 1, STR0022, Space( nTamField ), "@!", "", "", "", 60, .T. } }, STR0019,, )
		If AEG->( DbSeek( xFilial( "AEG" ) + MV_PAR01 ) )
			Alert( STR0060 ) // "O código da composição auxiliar já existe! Informe um novo código."
			Return
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena a composicao aux   em array para posteriormente ³
		//³duplicar alterando o codigo informado na ParamBox        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AEG->( DbGoTo( nRegAEG ) )
		aEval( AEG->( DbStruct() ), { |x| aAdd( aCampoAEG, AEG->( FieldGet( FieldPos( x[1] ) ) ) ) } )

		If AEH->( DbSeek( xFilial( "AEH" ) + AEG->AEG_COMPUN ) )
			aStruct := AEH->( DbStruct() )
			While AEH->( !Eof() ) .AND. AEH->AEH_FILIAL == xFilial( "AEH" ) .AND. AEH->AEH_COMPUN == AEG->AEG_COMPUN
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AEH->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AEH->( FieldPos( "AEH_COMPUN" ) )
				aRegs[ nFieldPos ] := MV_PAR01
			
				aAdd( aCampoAEH, aClone( aRegs ) )

				AEH->( DbSkip() )
			End
		EndIf
		
		If AEI->( DbSeek( xFilial( "AEI" ) + AEG->AEG_COMPUN ) )
			aStruct := AEI->( DbStruct() )
			While AEI->( !Eof() ) .AND. AEI->AEI_FILIAL == xFilial( "AEI" ) .AND. AEI->AEI_COMPUN == AEG->AEG_COMPUN
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AEI->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AEI->( FieldPos( "AEI_COMPUN" ) )
				aRegs[ nFieldPos ] := MV_PAR01

				aAdd( aCampoAEI, aClone( aRegs ) )
				AEI->( DbSkip() )
			End
		EndIf

		If AEJ->( DbSeek( xFilial( "AEJ" ) + AEG->AEG_COMPUN ) )
			aStruct := AEJ->( DbStruct() )
			While AEJ->( !Eof() ) .AND. AEJ->AEJ_FILIAL == xFilial( "AEJ" ) .AND. AEJ->AEJ_COMPOS == AEG->AEG_COMPUN
				aRegs := {}
				aEval( aStruct, { |x| aAdd( aRegs, AEJ->( FieldGet( FieldPos( x[1] ) ) ) ) } )

				nFieldPos	:= AEJ->( FieldPos( "AEJ_COMPOS" ) )
				aRegs[ nFieldPos ] := MV_PAR01

				aAdd( aCampoAEJ, aClone( aRegs ) )
				AEJ->( DbSkip() )
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a gravacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
		Reclock("AEG",.T.)
		For nCount := 1 to Len( aCampoAEG )
			FieldPut( nCount, aCampoAEG[ nCount ] )
		Next

		AEG->AEG_FILIAL := xFilial( "AEG" )
		AEG->AEG_COMPUN := MV_PAR01
		AEG->( MsUnlock() )

		For nInc := 1 To Len( aCampoAEH )
			Reclock("AEH",.T.)
			For nCount := 1 to Len( aCampoAEH[ nInc ] )
				FieldPut( nCount, aCampoAEH[ nInc ][ nCount ] )
			Next

			AEH->AEH_FILIAL := xFilial( "AEH" )
			AEH->( MsUnlock() )
		Next

		For nInc := 1 To Len( aCampoAEI )
			Reclock("AEI",.T.)
			For nCount := 1 to Len( aCampoAEI[ nInc ] )
				FieldPut( nCount, aCampoAEI[ nInc ][ nCount ] )
			Next

			AEI->AEI_FILIAL := xFilial( "AEI" )
			AEI->( MsUnlock() )
		Next

		For nInc := 1 To Len( aCampoAEJ )
			Reclock("AEJ",.T.)
			For nCount := 1 to Len( aCampoAEJ[ nInc ] )
				FieldPut( nCount, aCampoAEJ[ nInc ][ nCount ] )
			Next

			AEJ->AEJ_FILIAL := xFilial( "AEJ" )
			AEJ->( MsUnlock() )
		Next

		End Transaction		
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA015Imp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Importacao de composicoa auxiliar                                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PA015Imp(cAlias,nReg,nOpcx)                                         º±±
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
Function PA015Imp( cAlias, nReg, nOpcx )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aCodCU	:= {}				// Array com as composicoes auxiliar selecionadas
	Local aCodPrj	:= {}				// Array com os projetos selecionados
	Local aCriticas	:= {}				// Array com os projetos onde as composicoes auxiliar ja existem
	Local aExport  	:= {}				// Array com as composicoes a serem exportadas com seus respectivos projetos
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar as composicoes auxiliar
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncCU	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local oDlg
	Local oPMSA0151	:= Nil
	Local oPMSA0152 := Nil

	Local oPanel
	Local oGet
	Local cProcura
	Local oButton
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta as composicoes auxiliar disponiveis para exportacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	aTrab		:= {	{ "OK"    	, "C", 1, 							0 },;
						{ "CODIGO"	, "C", TamSX3( "AJT_COMPUN" )[1],	0 },;
						{ "DESCR"	, "C", TamSX3( "AJT_DESCRI" )[1],	0 },;
						{ "PROJET"	, "C", TamSX3( "AJT_PROJET" )[1], 	0 },;
						{ "REVISA"	, "C", TamSX3( "AJT_REVISA" )[1], 	0 },;
						{ "DESCPR"	, "C", TamSX3( "AF8_DESCRI" )[1], 	0 }}
			
	oPMSA0151 := FWTemporaryTable():New( "TRB" )  
	oPMSA0151:SetFields(aTrab) 
	oPMSA0151:AddIndex("1", {"CODIGO","PROJET"})

	//------------------
	//Criação da tabela temporaria
	//------------------
	oPMSA0151:Create()

	Processa( { || MontaTRBImp() }, STR0050 ) // "Selecionando composicoes auxiliar para exportacao... Aguarde!"

	DbSelectArea( "TRB" )
	TRB->( DbGoTop() )
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

	cProcura := space(TamSX3( "AJT_COMPUN")[1]+TamSX3( "AJT_PROJET" )[1])
	@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
	oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(alltrim(cProcura))) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

	aCpos := {	{ "OK"    	, "", "", ""}, ;
				{ "CODIGO"	, "", A093RetDescr( "AJT_COMPUN" ), "" },;
				{ "DESCR"	, "", A093RetDescr( "AJT_DESCRI" ), "" },;
				{ "PROJET"	, "", A093RetDescr( "AJT_PROJET" ), "" },;
				{ "REVISA"	, "", A093RetDescr( "AJT_REVISA" ), "" },;
				{ "DESCPR"	, "", A093RetDescr( "AF8_DESCRI" ), "" } }

	oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
	oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lCanAllMark	:= .T.
	oMark:oBrowse:bAllMark		:= { || PMA015Inv( cMarca, .T., oMark ) }

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) )

	If lOk
		TRB->( DbGoTop() )
		While TRB->( !Eof() )
			If TRB->OK == "X"
				aAdd( aCodCU, { TRB->CODIGO, TRB->DESCR, TRB->PROJET, TRB->REVISA, TRB->DESCPR,  } )
			EndIf

			TRB->( DbSkip() )
		End
	EndIf

	If oPMSA0151 <> Nil
		oPMSA0151:Delete()
		oPMSA0151 := Nil
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se no projeto selecionado existe alguma composicao³
	//³selecionada e questiona se deve substituir ou manter.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aCodCU )
		For nIncCU := 1 To Len( aCodCU )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica na tabela AJT-Composicoes Aux    do Projeto se a ³
			//³composicao a ser exportada ja existe para aquele projeto  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEG" )
			AEG->( DbSetOrder( 1 ) )
			If AEG->( DbSeek( xFilial( "AEG" ) + aCodCU[ nIncCU ][1] ) )
				aAdd( aCriticas, { aCodCU[ nIncCU ][1], aCodCU[ nIncCU ][2], aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][5] }  ) // Composicao Aux, Desc CU, Projeto, Desc Prj
			Else
				aAdd( aExport, { aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][1] }  ) // Projeto, Revisao, Composicao Aux

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui as sub-composicoes das composicoes que devem ³
				//³obrigatoriamente serem exportadas.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PA015IncSub( aCodCU[ nIncCU ][3], aCodCU[ nIncCU ][4], aCodCU[ nIncCU ][1], @aExport, .T. ) // Projeto, Revisa, Composicao Aux
			EndIf
		Next

		If !Empty( aCriticas )
			Alert( STR0051 + chr(13) + chr(10) + STR0052 )
	
			aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
								{ "COMPUN", "C", TamSX3( "AEG_COMPUN" )[1],	0 },;
								{ "DESCCU", "C", TamSX3( "AEG_DESCRI" )[1],	0 },;
								{ "PROJET", "C", TamSX3( "AF8_PROJET" )[1],	0 },;
								{ "REVISA", "C", TamSX3( "AF8_REVISA" )[1],	0 },;
								{ "DESCPR", "C", TamSX3( "AF8_DESCRI" )[1],	0 } }
		
			oPMSA0152 := FWTemporaryTable():New( "TRB" )  
			oPMSA0152:SetFields(aTrab) 
			oPMSA0152:AddIndex("1", {"COMPUN","PROJET"})
			
			//------------------
			//Criação da tabela temporaria
			//------------------
			oPMSA0152:Create()
		
			For nInc := 1 To Len( aCriticas )
				RecLock( "TRB", .T. ) 
				TRB->COMPUN	:= aCriticas[ nInc ][1]
				TRB->DESCCU	:= aCriticas[ nInc ][2]
				TRB->PROJET	:= aCriticas[ nInc ][3]
				TRB->REVISA	:= aCriticas[ nInc ][4]
				TRB->DESCPR	:= aCriticas[ nInc ][5]
				MsUnLock()
			Next

			DbSelectArea( "TRB" )
			TRB->( DbGoTop() )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "COMPUN"	, "", A093RetDescr( "AEG_COMPUN" ), "" },;
						{ "DESCCU"	, "", A093RetDescr( "AEG_DESCRI" ), "" },;
						{ "PROJET"	, "", A093RetDescr( "AF8_PROJET" ), "" },;
						{ "DESCPR"	, "", A093RetDescr( "AF8_DESCRI" ), "" },;
						{ "REVISA"	, "", A093RetDescr( "AF8_REVISA" ), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA015Inv( cMarca, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) )

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aExport, { TRB->PROJET, TRB->REVISA, TRB->COMPUN }  ) // Projeto, Revisao, Composicao Aux

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui as sub-composicoes das composicoes que devem ³
						//³obrigatoriamente serem exportadas.                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA015IncSub( TRB->PROJET, TRB->REVISA, TRB->COMPUN, @aExport, .T. ) // Projeto, Revisa, Composicao Aux
					EndIf
					
					TRB->( DbSkip() )
				End
			EndIf
		
			If oPMSA0152 <> Nil
				oPMSA0152:Delete()
				oPMSA0152 := Nil
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
			//³Realiza a copia da estrutura da composicao aux   associando ao projeto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJT", "AEG" ) // Banco de Composicao Aux
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJU", "AEH" ) // Insumo X Banco de Composicao Aux
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJV", "AEI" ) // Despesas da Composicao Aux do Banco
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AJX", "AEJ" ) // SubComposicao da Composicao Aux do Banco
	
			// Insumos
			DbSelectArea( "AEH" )
			AEH->( DbSetOrder( 1 ) )
			AEH->( DbSeek( xFilial( "AEH" ) + aExport[nInc][3] ) )
			While AEH->( !Eof() ) .AND. AEH->( AEH_FILIAL + AEH_COMPUN ) == xFilial( "AEH" ) + aExport[nInc][3]
				// Insumo
				DbSelectArea( "AJZ" )
				AJZ->( DbSetOrder( 1 ) )
				AJZ->( DbSeek( xFilial( "AJZ" ) + AEH->AEH_INSUMO ) )
				While AJZ->( !Eof() ) .AND. AJZ->AJZ_FILIAL == xFilial( "AJZ" ) .AND. AJZ->AJZ_INSUMO == AEH->AEH_INSUMO
					RecLock( "AJZ" )
					AJZ->( DbDelete() )
					AJZ->( DbSkip() )
				End

				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) )
				If AJY->( DbSeek( xFilial( "AJY" ) + aExport[nInc][1] + aExport[nInc][2]+ AEH->AEH_INSUMO ) )
					aFields := AJY->( DbStruct() )
					RecLock( "AJZ", .T. )
					For nCampo := 1 To Len( aFields )
						cCampo := "AJZ_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
						If AJZ->( FieldPos( cCampo ) ) > 0
							AJZ->( &(cCampo) ) := AJY->( &(aFields[nCampo][1]) )
						EndIf
					Next
			
					AJZ->AJZ_FILIAL := xFilial( "AJZ" )
					AJZ->AJZ_INSUMO := AEH->AEH_INSUMO
					AJZ->( MsUnLock() )
				EndIf
				
				// Estrutura do Insumo
				DbSelectArea( "AEK" )
				AEK->( DbSetOrder( 1 ) )
				AEK->( DbSeek( xFilial( "AEK" ) + AEH->AEH_INSUMO ) )
				While AEK->( !Eof() ) .AND. AEK->AEK_FILIAL == xFilial( "AEK" ) .AND. AEK->AEK_INSUMO == AEH->AEH_INSUMO
					RecLock( "AEK" )
					AEK->( DbDelete() )
					AEK->( DbSkip() )
				End

				DbSelectArea( "AEM" )
				AEM->( DbSetOrder( 1 ) )
				If AEM->( DbSeek( xFilial( "AEM" ) + aExport[nInc][1] + aExport[nInc][2]+ AEH->AEH_INSUMO ) )
					aFields := AEM->( DbStruct() )

					RecLock( "AEK", .T. )
					For nCampo := 1 To Len( aFields )
						cCampo := "AEK_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
						If AEK->( FieldPos( cCampo ) ) > 0
							AEK->( &(cCampo) ) := AEM->( &(aFields[nCampo][1]) )
						EndIf
					Next
			
					AEK->AEK_FILIAL := xFilial( "AEK" )
					AEK->AEK_INSUMO := AEH->AEH_INSUMO
					AEK->( MsUnLock() )
				EndIf
									
				AEH->( DbSkip() )
			End

			End Transaction
		Next
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA015Exp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Exportacao de composicoa aux                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PA015Exp(cAlias,nReg,nOpcx)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Apelido do arquivo                                          º±±
±±º          ³ ExpN2 - Número do registro a ser copiado                            º±±
±±º          ³ ExpN3 - Opção do arotina                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA015Exp( cAlias, nReg, nOpcx )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aCodCU	:= {}				// Array com as composicoes aux selecionadas
	Local aCodPrj	:= {}				// Array com os projetos selecionados
	Local aCriticas	:= {}				// Array com os projetos onde as composicoes aux ja existem
	Local aExport  	:= {}				// Array com as composicoes a serem exportadas com seus respectivos projetos
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar as composicoes aux
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncCU	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local nLenDin	:= 0
	Local oDlg
	Local oPMSA0153 := Nil
	Local oPMSA0154 := Nil
	Local oPMSA0155 := Nil

	Local oPanel
	Local oGet
	Local cProcura
	Local oButton
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta as composicoes aux    disponiveis para exportacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
						{ "CODIGO", "C", TamSX3( "AEG_COMPUN" )[1],	0 },;
						{ "DESCR" , "C", TamSX3( "AEG_DESCRI" )[1], 	0 }}
		
	oPMSA0153 := FWTemporaryTable():New( "TRB" )  
	oPMSA0153:SetFields(aTrab) 
	oPMSA0153:AddIndex("1", {"CODIGO"})
	
	//------------------
	//Criação da tabela temporaria
	//------------------
	oPMSA0153:Create()

	Processa( { || MontaTRB1( "AEG" ) }, STR0050 ) // "Selecionando composicoes aux para exportacao... Aguarde!"

	DbSelectArea( "TRB" )
	TRB->( DbGoTop() )
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

	cProcura := space(TamSX3( "AEG_COMPUN")[1])
	@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
	oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(Alltrim(cProcura))) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

	aCpos := {	{ "OK"    , "", "", ""}, ;
				{ "CODIGO", "", A093RetDescr( "AEG_COMPUN" ), "" },;
				{ "DESCR" , "", A093RetDescr( "AEG_DESCRI" ), "" } }

	oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
	oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lCanAllMark	:= .T.
	oMark:oBrowse:bAllMark		:= { || PMA015Inv( cMarca, .T., oMark ) }

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) )
	
	If lOk
		TRB->( DbGoTop() )
		While TRB->( !Eof() )
			If TRB->OK == "X"
				aAdd( aCodCU, { TRB->CODIGO, TRB->DESCR } )
			EndIf
			
			TRB->( DbSkip() )
		End
	EndIf
	
	If oPMSA0153 <> Nil
		oPMSA0153:Delete()
		oPMSA0153 := Nil
	Endif
	
	If Len( aCodCU ) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apresenta os projetos disponiveis onde as composicoes podem³
		//³ser importadas.                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
							{ "CODIGO", "C", TamSX3( "AF8_PROJET" )[1],	0 },;
							{ "DESCR" , "C", TamSX3( "AF8_DESCRI" )[1], 	0 },;
							{ "REVISA", "C", TamSX3( "AF8_REVISA" )[1], 	0 }}
				
		oPMSA0154 := FWTemporaryTable():New( "TRB" )  
		oPMSA0154:SetFields(aTrab) 
		oPMSA0154:AddIndex("1", {"CODIGO"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		oPMSA0154:Create()
	
		Processa( { || MontaTRB2() }, STR0049 ) // "Selecionando projetos para importacao... Aguarde!"
	
		DbSelectArea( "TRB" )
		TRB->( DbGoTop() )
	
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	
		aCpos := {	{ "OK"    , "", "", ""}, ;
					{ "CODIGO", "", A093RetDescr( "AF8_PROJET" ), "" },;
					{ "REVISA", "", A093RetDescr( "AF8_REVISA" ), "" },;
					{ "DESCR" , "", A093RetDescr( "AF8_DESCRI" ), "" } }
	
		oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
		oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:lCanAllMark	:= .T.
		oMark:oBrowse:bAllMark		:= { || PMA015Inv( cMarca, .T., oMark ) }
	
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) )
		
		If lOk
			TRB->( DbGoTop() )
			While TRB->( !Eof() )
				If TRB->OK == "X"
					aAdd( aCodPrj, { TRB->CODIGO, TRB->REVISA, TRB->DESCR } )
				EndIf
				
				TRB->( DbSkip() )
			End
		EndIf
	
		If oPMSA0154 <> Nil
			oPMSA0154:Delete()
			oPMSA0154 := Nil
		Endif
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
					//³Verifica na tabela AJT-Composicoes Aux    do Projeto se a ³
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
						PA015IncSub( aCodPrj[ nIncPrj ][1], aCodPrj[ nIncPrj ][2], aCodCU[ nIncCU ][1], @aExport ) // Projeto, Revisa, Composicao Aux
					EndIf
				Next
			EndIf
		Next

		If !Empty( aCriticas )
			Alert( STR0051 + chr(13) + chr(10) + STR0052 )
	
			aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
								{ "COMPUN", "C", TamSX3( "AEG_COMPUN" )[1],		0 },;
								{ "DESCCU", "C", TamSX3( "AEG_DESCRI" )[1],		0 },;
								{ "PROJET", "C", TamSX3( "AF8_PROJET" )[1],	0 },;
								{ "DESCPR", "C", TamSX3( "AF8_DESCRI" )[1],		0 },;
								{ "REVISA", "C", TamSX3( "AF8_REVISA" )[1],	0 }}


			oPMSA0155 := FWTemporaryTable():New( "TRB" )  
			oPMSA0155:SetFields(aTrab) 
			oPMSA0155:AddIndex("1", {"COMPUN","PROJET"})
			
			//------------------
			//Criação da tabela temporaria
			//------------------
			oPMSA0155:Create()
		
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

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "COMPUN"	, "", A093RetDescr( "AEG_COMPUN" ), "" },;
						{ "DESCCU"	, "", A093RetDescr( "AEG_DESCRI" ), "" },;
						{ "PROJET"	, "", A093RetDescr( "AF8_PROJET" ), "" },;
						{ "REVISA"	, "", A093RetDescr( "AF8_REVISA" ), "" },;
						{ "DESCPR"	, "", A093RetDescr( "AF8_DESCRI" ), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA015Inv( cMarca, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) )

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aExport, { TRB->PROJET, TRB->REVISA, TRB->COMPUN }  ) // Projeto, Revisao, Composicao Aux

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui as sub-composicoes das composicoes que devem ³
						//³obrigatoriamente serem exportadas.                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA015IncSub( TRB->PROJET, TRB->REVISA, TRB->COMPUN, @aExport ) // Projeto, Revisa, Composicao Aux
					EndIf
					
					TRB->( DbSkip() )
				End
			EndIf
		
			If oPMSA0155 <> Nil
				oPMSA0155:Delete()
				oPMSA0155 := Nil
			EndIf

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
			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 1 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + cChave ) )
			While AEM->( !Eof() ) .AND. AEM->AEM_FILIAL == xFilial( "AEM" ) .AND. AEM->( AEM_PROJET + AEM_REVISA ) == aExport[nInc][1] + aExport[nInc][2]
				RecLock( "AEM" )
				AEM->( DbDelete() )
				AEM->( MsUnLock() )

				AEM->( DbSkip() )
			End

			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) )
			AJY->( DbSeek( xFilial( "AJY" ) + cChave ) )
			While AJY->( !Eof() ) .AND. AJY->AJY_FILIAL == xFilial( "AJY" ) .AND. AJY->( AJY_PROJET + AJY_REVISA ) == aExport[nInc][1] + aExport[nInc][2]
				RecLock( "AJY" )
				AJY->( DbDelete() )
				AJY->( MsUnLock() )

				AJY->( DbSkip() )
			End

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
			AJU->( DbSetOrder( 2 ) )
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
			//³Realiza a copia da estrutura da composicao aux associando ao projeto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEG", "AJT", .T. ) // Banco de Composicao Aux
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEH", "AJU", .T. ) // Insumo X Banco de Composicao Aux
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEI", "AJV", .T. ) // Despesas da Composicao Aux do Banco
			P015CpyCompos( aExport[nInc][1], aExport[nInc][2], aExport[nInc][3], "AEJ", "AJX", .T. ) // SubComposicao da Composicao Aux do Banco

			// Insumos
			DbSelectArea( "AJU" )
			AJU->( DbSetOrder( 2 ) )
			AJU->( DbSeek( xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3] ) )
			While AJU->( !Eof() ) .AND. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3]
				P015ExpIns( AJU->AJU_PROJET, AJU->AJU_REVISA, AJU->AJU_INSUMO )
				AJU->( DbSkip() )
			End Do

			End Transaction
		Next
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A015GDDel    ³ Autor ³Fabio Rogerio Pereira³ Data ³01-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao do item da getdados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AEG                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015GDDel(nGet)
Local cCampo	:= IIf( nGet == 2, "AEI_VALOR", "_QUANT" )
Local nPos  	:= aScan( aHeader, { |x| cCampo $ AllTrim( x[ 2 ] ) } )
   
If nPos > 0
	aCols[n][nPos] := 0
EndIf

// somente valida a exclusao de itens para opcao diferente de Visualizar
If (oGD[nGet]:nOpc <> 2)
	// valida se utiliza o template CCT
	If lUsaCCT
		If ExistTemplate("CCTAEGCUST")
			ExecTemplate("CCTAEGCUST",.F.,.F.,{nGet,,"AEG"})
		EndIf
	EndIf
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A015SegUm    ³ Autor ³Adriano Ueda         ³ Data ³07-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a segunda unidade de medida do produto na composicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AEG                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015SegUm()
Local aAreaAJZ := AJZ->(GetArea())
Local ny := 0

Local nProdutoPos := 0
Local nQtSegUmPos := 0
Local nProdQtdPos := 0

// procura o codigo do produto
// digitado no aCols
For ny := 1 To Len(aHeaderSV[1])
	Do Case
		Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_INSUMO"
			nProdutoPos := ny
		Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_QTSEGU"
			nQtSegUmPos := ny
		Case AllTrim(aHeaderSV[1][ny][2]) == "AEH_QUANT"
			nProdQtdPos := ny
	EndCase
Next

If nProdutoPos > 0
	AJZ->(dbSetOrder(1))
	
	// procura o produto no AJZ
	If AJZ->(dbSeek(xFilial() + aCols[n][nProdutoPos]))
		
		// se o fator de conversao e o tipo de conversao
		// nao forem vazios
		If AJZ->AJZ_CONV > 0 .And. AJZ->AJZ_TIPCONV <> ""
			If nQtSegUmPos > 0
				
				// multiplica ou divide a quantidade pelo fator
				If AJZ->AJZ_TIPCONV = "M"
					aCols[n][nQtSegUmPos] := M->AEH_QUANT * AJZ->AJZ_CONV
				Else
					aCols[n][nQtSegUmPos] := M->AEH_QUANT / AJZ->AJZ_CONV
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAJZ)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAEJCheckRef ³ Autor ³ Adriano Ueda     ³ Data ³ 17/08/2005 ³±±
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
Function PMSAEJCheckRef(cCompSource, cCompDest)

Local aAreaAEG := AEG->(GetArea())
Local aAreaAEJ := AEJ->(GetArea())
Local lRet     := .T.

AEG->(dbSetOrder(1))
If ! AEG->(dbSeek(xfilial("AEG") + cCompSource))
	lRet := .F.
	RestArea(aAreaAEG)
	RestArea(aAreaAEJ)
	Return lRet
EndIf

// a composição origem e EDT destino não podem
// ser a mesma
If cCompSource == cCompDest
	lRet := .F.
	RestArea(aAreaAEG)
	RestArea(aAreaAEJ)
	Return lRet
EndIf

dbSelectArea("AEJ")
AEJ->(dbSetOrder(1)) 	// AEJ_FILIAL + AEJ_COMPOS + AEJ_ITEM

If AEJ->(MsSeek(xFilial("AEJ") + cCompSource))
	While !AEJ->(Eof()) .And.;
		AEJ->AEJ_FILIAL + AEJ->AEJ_COMPOS == xFilial("AEJ") + cCompSource
		
		If AEJ->AEJ_SUBCOM == cCompDest
			lRet := .F.
			RestArea(aAreaAEG)
			RestArea(aAreaAEJ)
			Return lRet
		Else
			lRet := PMSAEJCheckRef(AEJ->AEJ_SUBCOM, cCompDest)
			RestArea(aAreaAEG)
			RestArea(aAreaAEJ)
			Return lRet
		EndIf
		
		dbSelectArea("AEJ")
		AEJ->(dbSkip())
	End
EndIf

RestArea(aAreaAEG)
RestArea(aAreaAEJ)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PA015CPYIN³ Autor ³Reynaldo Miyashita     ³ Data ³ 22.12.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de inicializacao na tela de cadastro da copia de       ³±±
±±³          ³Composicao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA015                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA015CPYINI()

If ExistBlock("PA015INI")
	ExecBlock("PA015INI",.F.,.F.)
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMS15LeReg ºAutor³João Gonçalves de Oliveira º Data ³ 17/10/2008    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Duplica um registro usando como base o registro posicionado        ³±±
±±³          ³ pelo MBrowse. Será chamada pela inclusão quando o semáforo         ³±±
±±³          ³ lCopia estiver ligado na rotina de inclusão.                       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMSA016Cop(cAlias,nReg,nOpc,aCpoChav)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Apelido do Arquivo                                          º±±
±±º          ³ ExpN2 - Número do registro a ser copiado                            º±±
±±º          ³ ExpN3 - Opção do aRotina                                            º±±
±±º          ³ ExpA4 - Vetor com campos que não devem ser copiados                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMS15LeReg(cAlias,nReg,nOpc,aCpoChav)

Local bCampo    := { |nCPO| Field(nCPO) }
Local nScan     := 0
Local nContItem := 0
Local aCpoNot   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto que Indica os campos que nao devem ser copiados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PMS015NC" )
	If Valtype( aCpoNot := ExecBlock( "PMS015NC", .F., .F. ) ) <> "A"
		aCpoNot := {}
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia os campos do insumo                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
For nContItem := 1 TO FCount()
	If Empty( AScan( aCpoNot,{|x| x == Upper(AllTrim(FieldName( nContItem )))} ) )
		M->&(EVAL(bCampo,nContItem)) := FieldGet(nContItem)
	EndIf
NEXT nContItem
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMS15TudOk ºAutor³João Gonçalves de Oliveira º Data ³ 10/10/2008    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Valida tela de gravação de composição                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMS15TudOk()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ Nenhum                                                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Valida se os dados estão corretamente cadastrados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMS15TudOk()
Local lValiComp := .T.

AEG->(dbSetOrder(1))
lValiComp := ! AEG->(dbSeek(xfilial("AEG") + M->AEG_COMPUN ))

If ! lValiComp
	Aviso(STR0026,STR0032,{"Stop"})
EndIf

Return(lValiComp)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSCompPad  ºAutor³João Gonçalves de Oliveira º Data ³ 25/11/2008   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Consulta padrão para buscar composição aux   por projeto e modelo   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMSCompPad()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Código do Projeto (Opcional)                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpX1 - Expressão com a consulta padrão a ser executada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSCompPad( cTitulo, cAlias, nStartOrdem, cCampoDefault, cProjeto, cRevisa, lFiltra)
Local cTexto          := SPACE(40), nOrdem := nStartOrdem
Local lOk             := .F., aCombo, oCombo1, oFiltrar, aRadio
Local nMarca          := &(cAlias)->(Recno()), nOldOrd := &(cAlias)->(IndexOrd())
Local aGrid           := {}
Local aFiltrar        := {}
Local aNFiltrar       := {}
Local nFiltrar        := 1
Local nSeq            := 1
Local cFiltro         := ""                 
Default cTitulo       := STR0039 //"Composições Auxiliares"
Default cAlias        := "AJT"
Default nStartOrdem   := 2
Default cCampoDefault := "AJT_COMPUN"
Default cRevisa       := ""
Default lFiltra       := .F.

If Empty( cProjeto )
	cFiltro := "(!Empty( " + cCampoDefault + " ))"
Else
	cFiltro := "(!Empty(AJT_COMPUN)) .AND. AJT_PROJET = '" + cProjeto + "' .and. AJT_REVISA = '" + cRevisa + "' "
EndIf

Filtra(cAlias,cTexto,cCampoDefault,cFiltro)                                                

&(cAlias)->(dbSetOrder(nStartOrdem))
@ 66,0 To 550,790 Dialog mkwdlg Title OemToAnsi(cTitulo)
@ 205,005 say STR0040 // "Buscar "
nRadio := 2
@ 212,005 GET cTexto Picture "@!" Valid Filtra(cAlias,cTexto,cCampoDefault,cFiltro) Object oTexto
aRadio := {STR0041,STR0042} //"Pelo Inicio" ##"Qualquer Posicao"
@ 223,005 RADIO aRadio VAR nRadio

DbSelectArea("SIX")
DbSeek(cAlias)
aCombo := {}
Do While SIX->INDICE == cAlias
	AADD(aCombo,SIX->DESCRICAO)
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias,.T.)
Do While X3_ARQUIVO == cAlias
	If X3_BROWSE == "S" .AND. X3_CONTEXT <> "V"
		AADD(aGrid,{X3_CAMPO,X3_DESCRIC,X3_PICTURE})
		If X3_TIPO == "C"
			AADD(aFiltrar ,X3_CAMPO)
			AADD(aNFiltrar,X3_DESCRIC)
			If AllTrim(X3_CAMPO) == cCampoDefault
				nFiltrar := nSeq
			EndIf
			nSeq++
		EndIf
	EndIf
	DbSkip()
EndDo

@ 205,80 Say STR0043 // "Campo"
@ 212,80 LISTBOX nFiltrar Items aNFiltrar Size 90,26 Object oFiltrar

@ 205,180 Say STR0044 //"Ordem"
@ 212,180 LISTBOX nOrdem Items aCombo Size 90,26 Object oCombo1
oCombo1:bChange := {|| ;
oCombo1:Refresh(),;
&(cAlias)->(DbSetOrder(nOrdem)),;
&(cAlias)->(DbGoTop()), ;
oABC:oBrowse:GoTop(), ;
oABC:oBrowse:Refresh() }

DbSelectArea(cAlias)
@ 0,0 TO 200,393 BROWSE cAlias FIELDS aGrid Object oABC
@ 220,288 Button OemToAnsi(STR0045)   Size 36,16 Action Filtra(cAlias,cTexto,cCampoDefault,cFiltro) Object obj01 //_Filtrar
@ 220,324 Button OemToAnsi(STR0046) Size 36,16 Action Eval({|| lOk:= .T., Close(mkwdlg)})  Object obj02  //_Confirmar
@ 220,360 Button OemToAnsi(STR0047)    Size 36,16 Action Close(mkwdlg)                        Object obj03  // _Fechar
oABC:oBrowse:blDblClick := {|| lOk:= .T., Close(mkwdlg)}
oABC:oBrowse:lColDrag   := .T.
//oABC:oBrowse:nFreeze    := 1
Activate Dialog mkwdlg CENTERED
nPosicionar := Recno()
DbSelectArea(cAlias)
&(cAlias)->(DbClearFil())
DbSetOrder(nOldOrd)
If lOk
	DbGoTo(nPosicionar)
Else
	DbGoTo(nMarca)
EndIf

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Filtra    ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Filtra(cAlias,cTexto,cCampo,cExtraFilter)
Local cFiltro := ""

cFiltro    := cCampo+'>="'+AllTrim(cTexto)+'" .And. ' + cExtraFilter 

dbSelectArea(cAlias)
dbSetFilter({||&cFiltro},cFiltro)
dbGoTop()

Return .T.


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
{ STR0003,"PA015Dialog"	, 0 , 2},; //"Visualizar"
{ STR0004,"PA015Dialog"	, 0 , 3},; //"Incluir"
{ STR0005,"PA015Dialog"	, 0 , 4},; //"Alterar"
{ STR0006,"PA015Dialog"	, 0 , 5},; //"Excluir"
{ STR0055,"PA015Imp"	, 0 , 6},; //"Importar"
{ STR0056,"PA015Exp"	, 0 , 7},; //"Exportar"
{ STR0057,"PA015Dupl"	, 0 , 8}}  //"Duplicar"
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A015FdOkA ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³aux, atualizando os custos Un. Truncado e Arredondado.    º±±
±±º          ³  A015FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  A015FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  A015FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA015 - Cadastro de Composicao aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015FdOkA()
Local cCampo  	:= ReadVar()
Local nPosQt  	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_QUANT"  } )
Local nPIndImp	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_HRIMPR" } )
Local nPIndPrd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_HRPROD" } )
Local nPCusPrd	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_CUSPRD" } )	
Local nPCusImp	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_CUSIMP" } ) 
Local nPCustd 	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_CUSTD"  } )
Local nPDMT   	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_DMT"  } )
Local nPGrOrga	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_GRORGA" } )
Local nPCstItem	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEH_CSTITM" } )
Local nDMT		:= 1
Local nDecCst	:= TamSX3("AEH_CSTITM")[2]

If nPGrOrga > 0
	If aCols[n][nPGrOrga] == "F"
		nDMT := aCols[n][nPDMT]
	EndIf
EndIf

Do Case
	Case cCampo == "M->AEH_QUANT"
  		aCols[n][nPosQt] 	:= &cCampo
	Case cCampo == "M->AEH_DMT"
  		aCols[n][nPDMT] 	:= &cCampo
  		nDMT				:= aCols[n][nPDMT]
	Case cCampo == "M->AEH_HRPROD" 
  		aCols[n][nPIndPrd]	:= &cCampo
		aCols[n][nPCustd]	:= (aCols[n][nPCusPrd] * aCols[n][nPIndPrd]) + (aCols[n][nPCusImp] * aCols[n][nPIndImp])
	Case cCampo == "M->AEH_HRIMPR"
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
Else
	aCols[n][nPCstItem]	:= 0
EndIf

If ExistTemplate("CCTAEGCUST")
	ExecTemplate("CCTAEGCUST",.F.,.F.,{2,,"AEG"})
EndIf

A015GDCalcCust(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A015FdOkB ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³aux, atualizando os custos Un. Truncado e Arredondado.    º±±
±±º          ³  A015FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  A015FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  A015FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA015 - Cadastro de Composicao aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015FdOkB()
Local cCampo 	:= ReadVar()
Local nPosVal	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_VALOR" } )
Local nPosDMTT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_DMTT"  } )
Local nPosDMTP	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_DMTP"  } )
Local nPosDMT	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_DMT"   } )
Local nPosCusto	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_CUSTO" } )
Local nPosCons	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEI_CONSUM"} )

If cCampo == "M->AEI_VALOR"
	aCols[n][nPosVal] := &cCampo
ElseIf cCampo == "M->AEI_DMTT"
	aCols[n][nPosDMTT] := &cCampo
ElseIf cCampo == "M->AEI_DMTP"
	aCols[n][nPosDMTP] := &cCampo
ElseIf cCampo == "M->AEI_CUSTO"
	aCols[n][nPosCusto] := &cCampo
ElseIf cCampo == "M->AEI_CONSUM"
	aCols[n][nPosCons] := &cCampo
EndIf

If nPosDMT > 0 .AND. nPosDMTT > 0 .AND. nPosDMTP > 0 .AND. N > 0
	aCols[n][nPosDMT] := aCols[n][nPosDMTT] + aCols[n][nPosDMTP]
	If aCols[n][nPosDMT] > 0
		aCols[n][nPosVal] := aCols[n][nPosDMT] * aCols[n][nPosCusto] * aCols[n][nPosCons]
	EndIf
EndIf

If ExistTemplate("CCTAEGCUST")
	ExecTemplate("CCTAEGCUST",.F.,.F.,{2,,"AEG"})
EndIf

A015GDCalcCust(2)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A015FdOkC ºAutor  ³Pedro Pereira Lima  º Data ³  01/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a alteracao dos campos que geram custo para a Comp.º±±
±±º          ³aux, atualizando os custos Un. Truncado e Arredondado.    º±±
±±º          ³  A015FdOkA() - Controle no folder "Insumos"                º±±
±±º          ³  A015FdOkB() - Controle no folder "Despesas"               º±±
±±º          ³  A015FdOkC() - Controle no folder "Sub-Composicoes"        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA015 - Cadastro de Composicao aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A015FdOkC()
Local cCampo    := ReadVar()
Local nPosQtSub := aScan(aHeader,{|x|AllTrim(x[2]) == "AEJ_QUANT"})
Local nPosSubC  := aScan(aHeader,{|x|AllTrim(x[2]) == "AEJ_SUBCOM"})
Local nPosCusIt	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AEJ_CUSIT"})
Local nPosCusto	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AEJ_CUSTO"})

Do Case
	Case cCampo == "M->AEJ_QUANT"
  		aCols[n][nPosQtSub] := &cCampo
	Case cCampo == "M->AEJ_SUBCOM" 
  		aCols[n][nPosSubC] := &cCampo
EndCase

If nPosCusIt > 0 .AND. nPosCusto > 0
	aCols[n][nPosCusIt] := aCols[n][nPosQtSub] * aCols[n][nPosCusto]
EndIf

If ExistTemplate("CCTAEGCUST")
	ExecTemplate("CCTAEGCUST",.F.,.F.,{3,,"AEG"})
EndIf

A015GDCalcCust(3)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A015GDCalcCustºAutor  ³Reynaldo Miyashitaº Data ³29-01-2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os custos item dos insumos, despesas e subcomposicaoº±±
±±º          ³ e o custo unitario da composicao aux.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA015 - Cadastro de Composicao aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A015GDCalcCust(nGet)
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
±±ºPrograma  ³PMSA015DelºAutor  ³Pedro Pereira Lima  º Data ³  10/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validacao para exclusao da comp. aux, verificandoº±±
±±º          ³se existe vinculo da comp. aux com alguma tarefa/projeto, º±±
±±º          ³ou se a comp. aux selecionada para delecao e utilizada    º±±
±±º          ³como subcomposicao em outra comp. aux. Caso ocorra alguma º±±
±±º          ³das situacoes acima, sera restringida a exclusao.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA015 - Cadastro de Composicao aux                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA015Del(cCompun)
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAEG := AEG->(GetArea())
Local aAreaAEJ := AEJ->(GetArea())
Local lOk      := .T.

//Verifico se a composicao aux selecionada para exclusao e subcomposicao de outra composicao aux
dbSelectArea( "AEJ" )
AEJ->( dbSetOrder( 1 ) )
AEJ->( DbGoTop() )
While !AEJ->( Eof() ) .And. xFilial("AEJ") == AEJ->AEJ_FILIAL
	If AEJ->AEJ_SUBCOM == cCompun //Verifico se a comp. aux selecionada para delecao existe como subcomposicao
		lOk     := .F.     
		Alert( STR0058 + AllTrim(AEJ->AEJ_COMPOS) + STR0059 ) // "A composição única selecionada é subcomposição de " ## " e não pode ser excluída!"
		Exit
	EndIf

	AEJ->(dbSkip())
EndDo
           
RestArea(aAreaAEJ)
RestArea(aAreaAEG)
RestArea(aAreaAF9)
RestArea(aArea)

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAEJCompºAutor  ³Pedro Pereira Lima  º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a consulta F3 para o campo AEJ_SUBCOM (Subcomposicao)º±±
±±º          ³dentro do cadastro de composicoes auxs.                   º±±
±±º          ³Essa rotina chama a PMSCompPad(), passando os parametros    º±±
±±º          ³para consulta, conforme situacao da composicao principal,   º±±
±±º          ³alternando o resultado mostrado conforme o campo AEG_MODELO.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta padrao do campo AEJ_SUBCOM - PMSA015              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAEJComp()
Local lFiltraMod:= .T.
Return( PMSCompPad( STR0001, "AEG", 1, "AEG_COMPUN", "", "", lFiltraMod ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAJXCompºAutor  ³Pedro Pereira Lima  º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a consulta F3 para o campo AEJ_SUBCOM (Subcomposicao)º±±
±±º          ³dentro do cadastro de composicoes auxs.                   º±±
±±º          ³Essa rotina chama a PMSCompPad(), passando os parametros    º±±
±±º          ³para consulta, conforme situacao da composicao principal,   º±±
±±º          ³alternando o resultado mostrado conforme o campo AEG_MODELO.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta padrao do campo AEJ_SUBCOM - PMSA015              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJXComp()
Local lFiltraMod := .T.
Return PMSCompPad( STR0001, 'AJT', 1, 'AJT_PROJET', AF8->AF8_PROJET, AF8->AF8_REVISA, lFiltraMod )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao das composicoes auxs        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRB1( cAlias )
	DbSelectArea( cAlias )
	(cAlias)->( DbSetOrder( 1 ) )
	(cAlias)->( DbGoTop() )
	While (cAlias)->( !Eof() )
		RecLock( "TRB", .T. ) 
		TRB->CODIGO	:= (cAlias)->( &(cAlias + "_COMPUN") )
		TRB->DESCR	:= (cAlias)->( &(cAlias + "_DESCRI") )
		MsUnLock()

		(cAlias)->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao dos projetos.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRB2()
	DbSelectArea( "AF8" )
	AF8->( DbSetOrder( 1 ) )
	AF8->( DbGoTop() )
	While AF8->( !Eof() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apenas projetos que usam composicao aux³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AF8->AF8_USAAJT == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a fase do projeto permite alterar ou incluir tarefa e edts³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEA" )
			AEA->( DbSetOrder( 1 ) )
			If AEA->( DbSeek( xFilial( "AEA" ) + AF8->AF8_FASE ) )
				If AEA->AEA_EVEN15 == "1" .AND. ; 	// Incluir tarefa
				   AEA->AEA_EVEN16 == "1" .AND. ; 	// Incluir EDT
				   AEA->AEA_EVEN17 == "1" .AND. ; 	// Alterar EDT
				   AEA->AEA_EVEN18 == "1"			// Alterar tarefa
	
					RecLock( "TRB", .T. ) 
					TRB->CODIGO := AF8->AF8_PROJET
					TRB->DESCR	:= AF8->AF8_DESCRI
					TRB->REVISA	:= AF8->AF8_REVISA
					MsUnLock()
				EndIf
			EndIf
		EndIf

		AF8->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao das composicoes auxs        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRBImp()
	Local cDescPrj	:= ""

	DbSelectArea( "AJT" )
	AJT->( DbSetOrder( 1 ) )
	AJT->( DbGoTop() )
	While AJT->( !Eof() )
		cDescPrj	:= ""

		DbSelectArea( "AF8" )
		AF8->( DbSetOrder( 1 ) )
		If AF8->( DbSeek( xFilial( "AF8" ) + AJT->AJT_PROJET ) )
			cDescPrj := AF8->AF8_DESCRI
		EndIf

		RecLock( "TRB", .T. ) 
		TRB->CODIGO	:= AJT->AJT_COMPUN
		TRB->DESCR		:= AJT->AJT_DESCRI
		TRB->PROJET	:= AJT->AJT_PROJET
		TRB->REVISA	:= AJT->AJT_REVISA
		TRB->DESCPR	:= cDescPrj
		MsUnLock()

		AJT->( DbSkip() )
	End
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³P015CpyCompos³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Realiza a copia de composicoes auxs                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function P015CpyCompos( cCodPrj, cRevisa, cCodCU, cOrigem, cDestino, lExport )
	Local aFields 	:= {}
	Local cCampo	:= ""
	Local nCampo	:= 0
	Local cChave	:= IIf( cOrigem == "AEJ", "_COMPOS", "_COMPUN" )
	
	Default lExport := .F.

	DbSelectArea( cOrigem )
	(cOrigem)->( DbSetOrder( 1 ) )
	(cOrigem)->( DbSeek( xFilial( cOrigem ) + cCodCU ) )
	aFields := (cOrigem)->( DbStruct() )
	While (cOrigem)->( !Eof() ) .AND. (cOrigem)->( &(cOrigem + "_FILIAL") ) == xFilial( cOrigem ) .AND. (cOrigem)->( &(cOrigem + cChave) ) == cCodCU
		If !lExport
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

		If lExport
			(cDestino)->( &( cDestino + "_PROJET" ) ) := cCodPrj
			(cDestino)->( &( cDestino + "_REVISA" ) ) := cRevisa

			If cOrigem == "AEJ"
				AJX->AJX_COMPUN := AEJ->AEJ_COMPOS
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA015IncSub  ³ Autor ³ Totvs                 ³ Data ³ 18.06.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Inclui no array para exportar as sub-composicoes              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA015IncSub( cProjet, cRevisa, cCompun, aExport, lImporta )
	Local aArea		:= {}
	
	Default lImporta := .F.

	If lImporta
		DbSelectArea( "AJX" )
		AJX->( DbSetOrder( 2 ) )
		AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + cCompun ) )
		While AJX->( !Eof() ) .AND. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJX" ) + cProjet + cRevisa + cCompun
			aArea := AJX->( GetArea() )

			If !Empty( AJX->AJX_SUBCOM ) // Protecao
				aAdd( aExport, { cProjet, cRevisa, AJX->AJX_SUBCOM } )
				PA015IncSub( cProjet, cRevisa, AJX->AJX_SUBCOM, @aExport, lImporta )
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
				PA015IncSub( cProjet, cRevisa, AEJ->AEJ_SUBCOM, @aExport, lImporta )
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
Static Function Pma015Salvar( l015Exclui, aGets, aTela, oFolder, aCols, aHeader,;
							  oGD, nRecAEG, aRecAEH, aRecAEI, aRecAEJ, l015Altera,;
							  aRecAEHRe, nOpcX )
	Local lContinua	:= .T.
	Local aAuxArea		:= {}
	Local ny 			:= 0
	Local ni 			:= 0
	Local nx 			:= 0
	
	Local nPosQtSub 	:= 0
	Local nPosCusIt		:= 0
	Local nPosCusto		:= 0
	
	Local nPIndImp		:= 0
	Local nPIndPrd		:= 0
	Local nPCusPrd		:= 0
	Local nPCusImp		:= 0
	Local nPCustd	 	:= 0
	Local nAux			:= 0
	Local nLenItem		:= 0
		
	Eval( oFolder:bSetOption )

	If l015Exclui .OR. ( Obrigatorio(aGets,aTela) .And. AGDTudok(1,oFolder) .And. AGDTudok(2,oFolder) .And. AGDTudok(3,oFolder) )
		A015Grava( .F., nRecAEG, aRecAEH, aRecAEI, aRecAEJ, l015Altera, aRecAEHRe )
		MsgAlert( STR0061 ) 

		// Foca a primeira aba/folder
		A015SetOption( 1, oFolder:nOption, @aCols, @aHeader, @oGD )
		oFolder:nOption := 1
	EndIf

	// valida se utiliza o template CCT
	If lUsaCCT
		If ExistTemplate("CCTAJUINI")
			ExecTemplate("CCTAJUINI",.F.,.F., { "AEG" } )
		EndIf
	EndIf
Return

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
Static Function PMA015Inv( cMarca, lTodos, oMark )
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
±±³Fun‡„o	 ³ P015ExpIns ³ Autor ³ Marcelo Akama         ³ Data ³ 24/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exp Ins               					  	         		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function P015ExpIns( cProj, cRev, cIns )
Local aFields
Local cCampo
Local nCampo
Local aAreaAJY := AJY->(GetArea())
Local aAreaAJZ := AJZ->(GetArea())
Local aAreaAEM := AEM->(GetArea())
Local aAreaAEK := AEK->(GetArea())

// Insumo
DbSelectArea( "AJY" )
AJY->( DbSetOrder( 1 ) )
AJY->( DbSeek( xFilial( "AJY" ) + cProj + cRev + cIns ) )
While AJY->( !Eof() ) .AND. AJY->AJY_FILIAL == xFilial( "AJY" ) .AND. AJY->( AJY_PROJET + AJY_REVISA + AJY_INSUMO ) == cProj + cRev + cIns
	RecLock( "AJY" )
	AJY->( DbDelete() )
	AJY->( DbSkip() )
End

DbSelectArea( "AJZ" )
AJZ->( DbSetOrder( 1 ) )
If AJZ->( DbSeek( xFilial( "AJZ" ) + cIns ) )
	aFields := AJZ->( DbStruct() )

	RecLock( "AJY", .T. )
	For nCampo := 1 To Len( aFields )
		cCampo := "AJY_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
		If AJY->( FieldPos( cCampo ) ) > 0
			AJY->( &(cCampo) ) := AJZ->( &(aFields[nCampo][1]) )
		EndIf
	Next

	AJY->AJY_FILIAL := xFilial( "AJY" )
	AJY->AJY_PROJET := cProj
	AJY->AJY_REVISA := cRev
	AJY->( MsUnLock() )
EndIf

// Estrutura do Insumo
DbSelectArea( "AEM" )
AEM->( DbSetOrder( 1 ) )
AEM->( DbSeek( xFilial( "AEM" ) + cProj + cRev + cIns ) )
While AEM->( !Eof() ) .AND. AEM->AEM_FILIAL == xFilial( "AEM" ) .AND. AEM->( AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == cProj + cRev + cIns
	RecLock( "AEM" )
	AEM->( DbDelete() )
	AEM->( DbSkip() )
End

DbSelectArea( "AEK" )
AEK->( DbSetOrder( 1 ) )
AEK->( DbSeek( xFilial( "AEK" ) + cIns ) )
Do While !AEK->(EOF()) .And. AEK->(AEK_FILIAL+AEK_INSUMO)==xFilial( "AEK" ) + cIns
	P015ExpIns( cProj, cRev, AEK->AEK_SUBCOD )
	
	aFields := AEK->( DbStruct() )

	RecLock( "AEM", .T. )
	For nCampo := 1 To Len( aFields )
		cCampo := "AEM_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
		If AEM->( FieldPos( cCampo ) ) > 0
			AEM->( &(cCampo) ) := AEK->( &(aFields[nCampo][1]) )
		EndIf
	Next
	AEM->AEM_FILIAL := xFilial( "AEM" )
	AEM->AEM_PROJET := cProj
	AEM->AEM_REVISA := cRev
	AEM->AEM_SUBINS := AEK->AEK_SUBCOD
	AEM->( MsUnLock() )
	
	AEK->(dbSkip())
EndDo

RestArea(aAreaAJY)
RestArea(aAreaAJZ)
RestArea(aAreaAEM)
RestArea(aAreaAEK)

Return .T.