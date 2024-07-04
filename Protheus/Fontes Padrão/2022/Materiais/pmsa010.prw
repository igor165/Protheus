#include "pmsa010.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA010  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Composicoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA010(nRotina)

PRIVATE cCadastro	:= STR0001 //"Composicoes"
PRIVATE aRotina		:= MenuDef()
PRIVATE lUsaCCT		:= GetMV("MV_PMSCCT") == "2"

SaveInter()
// Somente para os modulos SIGAPMS SIGAFAT e SIGATEC
If ( Alltrim(Str(nModulo)) $ "44|05|28|73" ) .AND. AMIIn(nModulo) .And. !PMSBLKINT()
	If nRotina != Nil
		PA010Dialog("AE1",AE1->(RecNo()),nRotina)
	Else
		mBrowse(6,1,22,75,"AE1")
	EndIf
EndIf

RestInter()

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010Dialog³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Composicoes                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010Dialog(cAlias,nReg,nOpcx)

Local oDlg
Local l010Inclui	:= .F.
Local lContinua		:= .T.
Local l010Visual	:= .F.
Local l010Altera	:= .F.
Local l010Exclui	:= .F.
Local aSize			:= {}
Local aObjects		:= {}
Local aPages		:= {''}
Local nOpcA			:= 0
Local aRecAE2		:= {}
Local aRecAE3		:= {}
Local aRecAE4		:= {}
Local aRecAE2Re 	:= {}
Local nRecAE1		:= AE1->(RecNo())
Local aAuxArea		:= {}
Local aTitles		:= {  STR0007,; //"Itens"
						  STR0008,; //"Despesas"
						  STR0009 } //"Sub-Composicoes"
Local aTmpSV5  	:= {}
Local aTmp2SV5 	:= {}
Local ny 		:= 0
Local ni 		:= 0
Local nx 		:= 0
Local aButtons	:= {} 
Local aButPE	:= {}
Local aArea 	:= GetArea()
Local lExistADV	:= .F.
Local lExistAG6	:= .F.
Local cSeek		:= ""
Local bWhile	:= Nil
Local nGdOpc	:= 0 
Local aHeadProd := {}
Local aProdAux	 := {}	 	
Local aHeadRecr := {{},{}}
Local aTempSV	 := {}


If ExistBlock("PMA010BTN")
	aButPE:= ExecBlock("PMA010BTN",.F.,.F.)
	If ValType(aButPE) <> "A"
		aButPE := {}
	EndIf
EndIf

Private oGD[4]
Private oEnch
Private aHeader	 := {}
Private aCols	 := {}
Private aHeaderSV:= {{},{},{},{}}
Private aColsSV	 := {{},{},{},{}}
Private aSavN	 := {1,1,1,1}
Private aTELA[0][0],aGETS[0]
Private oFolder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir a tabela AG6 (perguntas x processo), exibe o   ³
//³botao de associacao de perguntas.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lExistAG6 := ChkFile("AG6") 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botoes da EnchoiceBar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ALTERA .AND. lExistAG6 .AND. nModulo == 5 
	AAdd(aButtons,{"NCO",{||Ft530RlPer(nOpcx,"1",M->AE1_COMPOS)},"Relacionar perguntas (Simulador de horas)","Perguntas"}) //"Relacionar perguntas (Simulador de horas)"###"Perguntas"
EndIf

For nX :=1 to Len(aButPE)
	AAdd(aButtons,aClone(aButPE[nX]))
Next nX


/*Private 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
*/

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
Case aRotina[nOpcx][4] == 2
	l010Visual := .T.
Case aRotina[nOpcx][4] == 3
	l010Inclui	:= .T.
Case aRotina[nOpcx][4] == 4
	l010Altera	:= .T.
Case aRotina[nOpcx][4] == 5
	l010Exclui	:= .T.
	l010Visual	:= .T.
EndCase
aAdd(aTitles,STR0024)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir a tabela ADV (componentes), insere mais uma aba³
//³no folder                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ChkFile("ADV") 
	lExistADV := .T.
	aAdd(aTitles,"Componentes")
	oGd	:=	Array(5)    
	AAdd(aHeaderSV,{})
	AAdd(aColsSV,{})
	AAdd(aSavN,1)
EndIf

RegToMemory("AE1",l010Inclui)

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AE2")
While !EOF() .And. (X3_ARQUIVO == "AE2")
	IF X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. !(AllTrim(X3_CAMPO)$"AE2_RECURS")// .And. Upper(Alltrim(SX3->X3_PROPRI)) <> "U"
		AADD(aHeadProd,X3_CAMPO)
	Endif
	dbSkip()
End

If ExistBlock("PMA010PD")
	aProdAux := ExecBlock("PMA010PD",.F.,.F.,{aHeadProd})
	If ValType(aProdAux) == "A"
		aHeadProd := aClone(aProdAux)
	Else
		Alert(STR0025 + "'PMA010PD'")
	EndIf		
EndIf

// montagem do aHeaderAE2
dbSelectArea("SX3")
dbSetOrder(2)
For nI := 1 To Len(aHeadProd)
	If SX3->(dbSeek(aHeadProd[nI]))
		AADD(aHeaderSV[1],{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO,X3_CONTEXT } )
	Endif
Next nI


SX3->(DbSeek("AE2_FILIAL"))
cUsado := SX3->X3_USADO  

If ExistBlock("PMA010AC") .And. ExistBlock("PMA010PD")
	aTempSV := ExecBlock("PMA010AC",.F.,.F.,{aHeaderSV[1]})
	If ValType(aTempSV) == "A"
		aHeaderSV[1] := aClone(aTempSV)
		aTempSV := {}
	Else
		Alert(STR0025 + "'PMA010AC'")		
	EndIf
EndIf	

AADD( aHeaderSV[1], { "Alias WT","AE2_ALI_WT", "", 09, 0,, cUsado, "C", "AE2", "V"} )
AADD( aHeaderSV[1], { "Recno WT","AE2_REC_WT", "", 09, 0,, cUsado, "N", "AE2", "V"} )

FillGetDados(nOpcx,"AE3",1,,,,,,,,{||.T.},.T.,aHeaderSV[2])

FillGetDados(nOpcx,"AE4",1,,,,,,,,{||.T.},.T.,aHeaderSV[3])

If lExistADV
	cSeek 	:= 	xFilial("ADV")+M->AE1_COMPOS
	bWhile	:=	{||ADV->ADV_FILIAL + ADV->ADV_COMPOS} 
	FillGetDados(nOpcx,"ADV",1,cSeek,bWhile,,,,,,,,aHeaderSV[5],aColsSV[5],{|a,b|PA010AfCol(a,b)})
	nx		:=  aScan(aHeaderSV[5],{|x|AllTrim(x[2]) == "ADV_ITEM"})
	If (nx > 0) .AND. (Len(aColsSV[5]) == 1) .AND. Empty(aColsSV[5][1][nx])
		aColsSV[5][1][nx]	:= "01"
	EndIf
EndIf

// estes campos devem ser apresentados no browse
aTmpSV5	:= { "AE2_ITEM"	,"AE2_RECURS" ,"AE2_QUANT" ,"AE2_PRODUT" ,"AE2_DESCRI" ,"AE2_CODIGO" ;
			,"AE2_UM"   ,"AE2_SEGUM"}
	
// estes campos devem não devem ser apresentados no browse
aTmp2SV5 := {"AE2_FILIAL", "AE2_RECPAI","AE2_COMPOS", "AE2_QTSEGU", "AE2_DMTX"  , "AE2_CAPM3" , "AE2_VELO"  ,;
             "AE2_TCDM"  , "AE2_TPERC" , "AE2_TPTOT" , "AE2_PHM3"  , "AE2_MT"    , "AE2_EMPOLA","AE2_FATOR"  }

If ExistBlock("PMA010RE")
	aHeadRecr := ExecBlock("PMA010RE",.F.,.F.,{aTmpSV5,aTmp2SV5})
	If ValType(aHeadRecr) == "A"
		aTmpSV5  := aClone(aHeadRecr[1])
		aTmp2SV5 := aClone(aHeadRecr[2])
	Else
		Alert(STR0025 + "'PMA010RE'")
	EndIf		
EndIf

dbSelectArea("SX3")  	
For nx := 1 to Len(aTmpSV5)
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(aTmpSV5[nx]))
			AADD(aHeaderSV[4],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
	EndIf
Next

    
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AE2")
While !EOF() .And. (x3_arquivo == "AE2")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		AScan(aTmp2SV5, { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0 .And. ;
		AScan(aTmpSV5,  { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0
		AADD(aHeaderSV[4],{ TRIM(x3titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End


SX3->(DbSeek("AE2_FILIAL"))
cUsado := SX3->X3_USADO

If ExistBlock("PMA010AC") .And. ExistBlock("PMA010RE")
	aTempSV := ExecBlock("PMA010AC",.F.,.F.,{aHeaderSV[4]})
	If ValType(aTempSV) == "A"
		aHeaderSV[4] := aClone(aTempSV)   
		aTempSV := {}
	Else
		Alert(STR0025 + "'PMA010AC'")		
	EndIf
EndIf	

AADD( aHeaderSV[4], { "Alias WT","AE2_ALI_WT", "", 09, 0,, cUsado, "C", "AE2", "V"} )
AADD( aHeaderSV[4], { "Recno WT","AE2_REC_WT", "", 09, 0,, cUsado, "N", "AE2", "V"} )

If l010Inclui

	// faz a montagem de uma linha em branco no aColsAE2
	aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
	For ny := 1 to Len(aHeaderSV[1])
		If Trim(aHeaderSV[1][ny][2]) == "AE2_ITEM"
			aColsSV[1][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AE2_ALI_WT | AE2_REC_WT"
			If AllTrim(aHeaderSV[1][ny][2]) == "AE2_ALI_WT"
				aColsSV[1][1][ny] := "AE2"				
			ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AE2_REC_WT"
				aColsSV[1][1][ny] := 0
			EndIf	
		Else
			aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
		EndIf
		aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
	Next ny
  
	// faz a montagem de uma linha em branco no aColsAE3
	aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
	For ny := 1 to Len(aHeaderSV[2])
		If Trim(aHeaderSV[2][ny][2]) == "AE3_ITEM"
			aColsSV[2][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AE3_ALI_WT | AE3_REC_WT"
			If AllTrim(aHeaderSV[2][ny][2]) == "AE3_ALI_WT"
				aColsSV[2][1][ny] := "AE3"				
			ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AE3_REC_WT"
				aColsSV[2][1][ny] := 0
			EndIf	
		Else
			aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
		EndIf
		aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
	Next ny

	// faz a montagem de uma linha em branco no aColsAE4
	aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
	For ny := 1 to Len(aHeaderSV[3])
		If Trim(aHeaderSV[3][ny][2]) == "AE4_ITEM"
			aColsSV[3][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AE4_ALI_WT | AE4_REC_WT"
			If AllTrim(aHeaderSV[3][ny][2]) == "AE4_ALI_WT"
				aColsSV[3][1][ny] := "AE4"				
			ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AE4_REC_WT"
				aColsSV[3][1][ny] := 0
			EndIf	
		Else
			aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
		EndIf
		aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
	Next ny

	// faz a montagem de uma linha em branco no aColsAE2 (Recursos)
	aadd(aColsSV[4],Array(Len(aHeaderSV[4])+1))
	For ny := 1 to Len(aHeaderSV[4])
		If Trim(aHeaderSV[4][ny][2]) == "AE2_ITEM"
			aColsSV[4][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[4][ny][2]) $ "AE2_ALI_WT | AE2_REC_WT"
			If AllTrim(aHeaderSV[4][ny][2]) == "AE2_ALI_WT"
				aColsSV[4][1][ny] := "AE2"				
			ElseIf AllTrim(aHeaderSV[4][ny][2]) == "AE2_REC_WT"
				aColsSV[4][1][ny] := 0
			EndIf	

		Else
			aColsSV[4][1][ny] := CriaVar(aHeaderSV[4][ny][2])
		EndIf
		aColsSV[4][1][Len(aHeaderSV[4])+1] := .F.
	Next ny
Else

	// trava o registro do AE1 - Alteracao,Visualizacao
	If l010Altera.Or.l010Exclui
		If !SoftLock("AE1")
			lContinua := .F.
			Aviso(STR0026, STR0027, {"Ok"})  //"Atencao"###"Composição esta sendo utilizada por outro usuário. Verifique!"
			Return
		Endif
	EndIf

	// faz a montagem do aColsAE2
	dbSelectArea("AE2")
	dbSetOrder(1)
	dbSeek(xFilial()+AE1->AE1_COMPOS)
	While !Eof() .And. AE2->AE2_FILIAL+AE2->AE2_COMPOS==xFilial("AE2")+AE1->AE1_COMPOS.And.lContinua
		If Empty(AE2->AE2_RECURS)

			// trava o registro do AE2 - Alteracao, Exclusao
			If l010Altera.Or.l010Exclui
				If !SoftLock("AE2")
					lContinua := .F.
				Else
					aAdd(aRecAE2,RecNo())
				Endif
			EndIf
			aADD(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial()+AE2->AE2_PRODUT))
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_TIPO"
							If !Empty(AE2->AE2_PRODUT)
								aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_TIPO
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_DESCRI"
							If !Empty(AE2->AE2_PRODUT)
								aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_DESC
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_UM"
							If !Empty(AE2->AE2_PRODUT)
								aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_UM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_SEGUM"
							If !Empty(AE2->AE2_PRODUT)
								aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_SEGUM
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_SIMBCS"
							If !Empty(AE2->AE2_PRODUT)
								aColsSV[1][Len(aColsSV[1])][ny] := GetMV("MV_SIMB"+RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
							EndIf
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_CUSTD"
							aColsSV[1][Len(aColsSV[1])][ny] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_ALI_WT"
							aColsSV[1][Len(aColsSV[1])][ny] := "AE2"     
						Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_REC_WT"	
							aColsSV[1][Len(aColsSV[1])][ny] := AE2->(Recno())     															
						OtherWise
							aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
					EndCase
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny
		EndIf
	dbSkip()
	EndDo
	If Empty(aColsSV[1])

		// faz a montagem de uma linha em branco no aColsAE2
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			If Trim(aHeaderSV[1][ny][2]) == "AE2_ITEM"
				aColsSV[1][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[1][ny][2]) $ "AE2_ALI_WT | AE2_REC_WT"
				If AllTrim(aHeaderSV[1][ny][2]) == "AE2_ALI_WT"
					aColsSV[1][1][ny] := "AE2"				
				ElseIf AllTrim(aHeaderSV[1][ny][2]) == "AE2_REC_WT"
					aColsSV[1][1][ny] := 0
				EndIf
			Else
				aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf
			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf

	// faz a montagem do aColsAE3
	dbSelectArea("AE3")
	dbSetOrder(1)
	dbSeek(xFilial()+AE1->AE1_COMPOS)
	While !Eof() .And. AE3->AE3_FILIAL+AE3->AE3_COMPOS==xFilial("AE3")+AE1->AE1_COMPOS.And.lContinua

		// trava o registro do AE3 - Alteracao,Exclusao
		If l010Altera.Or.l010Exclui
			If !SoftLock("AE3")
				lContinua := .F.
			Else
				aAdd(aRecAE3,RecNo())
			Endif
		EndIf
		aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			SX5->(dbSetOrder(1))
			SX5->(dbSeek(xFilial()+"02"+AE3->AE3_TIPOD))
			If ( aHeaderSV[2][ny][10] != "V")
				aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
			Else
				Do Case
					Case Alltrim(aHeaderSV[2][ny][2]) == "AE3_DESCTP"
						aColsSV[2][Len(aColsSV[2])][ny] := X5DESCRI()
					Case Alltrim(aHeaderSV[2][ny][2]) == "AE3_SIMBMO"
						aColsSV[2][Len(aColsSV[2])][ny] := GetMv("MV_SIMB"+Alltrim(STR(AE3->AE3_MOEDA,2,0)))
					Case AllTrim(aHeaderSV[2][ny][2]) == "AE3_ALI_WT"
						aColsSV[2][Len(aColsSV[2])][ny] := "AE3"     
					Case AllTrim(aHeaderSV[2][ny][2]) == "AE3_REC_WT"	
						aColsSV[2][Len(aColsSV[2])][ny] := AE3->(Recno())     															
					OtherWise
						aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
				EndCase
			EndIf
			aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
		Next ny
		dbSkip()
	EndDo

	If Empty(aColsSV[2])

		// faz a montagem de uma linha em branco no aColsAE3
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AE3_ITEM"
				aColsSV[2][1][ny] 	:= "01"
		ElseIf AllTrim(aHeaderSV[2][ny][2]) $ "AE3_ALI_WT | AE3_REC_WT"
			If AllTrim(aHeaderSV[2][ny][2]) == "AE3_ALI_WT"
				aColsSV[2][1][ny] := "AE3"				
			ElseIf AllTrim(aHeaderSV[2][ny][2]) == "AE3_REC_WT"
				aColsSV[2][1][ny] := 0
			EndIf	
		Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf

	// faz a montagem do aColsAE4
	dbSelectArea("AE4")
	dbSetOrder(1)
	dbSeek(xFilial()+AE1->AE1_COMPOS)
	While !Eof() .And. AE4->AE4_FILIAL+AE4->AE4_COMPOS==xFilial("AE4")+AE1->AE1_COMPOS.And.lContinua

		// posiciona na Sub-Composicao
		aAuxArea := AE1->(GetArea()	)
		AE1->(dbSetOrder(1))
		AE1->(dbSeek(xFilial()+AE4->AE4_SUBCOM))
		dbSelectArea("AE4")

		// trava o registro do AE4 - Alteracao,Exclusao
		If l010Altera.Or.l010Exclui
			If !SoftLock("AE4")
				lContinua := .F.
			Else
				aAdd(aRecAE4,RecNo())
			Endif
		EndIf
		aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If ( aHeaderSV[3][ny][10] != "V")
				aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
			Else
				Do Case
					Case Alltrim(aHeaderSV[3][ny][2]) == "AE4_DESCRI"
						aColsSV[3][Len(aColsSV[3])][ny] := AE1->AE1_DESCRI
					Case Alltrim(aHeaderSV[3][ny][2]) == "AE4_UM"
						aColsSV[3][Len(aColsSV[3])][ny] := AE1->AE1_UM
					Case AllTrim(aHeaderSV[3][ny][2]) == "AE4_ALI_WT"
						aColsSV[3][Len(aColsSV[3])][ny] := "AE4"     
					Case AllTrim(aHeaderSV[3][ny][2]) == "AE4_REC_WT"	
						aColsSV[3][Len(aColsSV[3])][ny] := AE4->(Recno())     															
					OtherWise
						aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
				EndCase
			EndIf
			aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
		Next ny
		RestArea(aAuxArea)
		dbSelectArea("AE4")
		dbSkip()
	EndDo

	If Empty(aColsSV[3])

		// faz a montagem de uma linha em branco no aColsAE3
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AE4_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			ElseIf AllTrim(aHeaderSV[3][ny][2]) $ "AE4_ALI_WT | AE4_REC_WT"
				If AllTrim(aHeaderSV[3][ny][2]) == "AE4_ALI_WT"
					aColsSV[3][1][ny] := "AE4"				
				ElseIf AllTrim(aHeaderSV[3][ny][2]) == "AE4_REC_WT"
					aColsSV[3][1][ny] := 0
				EndIf	
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	EndIf


		// faz a montagem do aColsAE
		dbSelectArea("AE2")
		dbSetOrder(1)
		dbSeek(xFilial()+AE1->AE1_COMPOS)
		While !Eof() .And. AE2->AE2_FILIAL+AE2->AE2_COMPOS==xFilial("AE2")+AE1->AE1_COMPOS.And.lContinua

			// trava o registro do AE2 - Alteracao,Exclusao
			If !Empty(AE2->AE2_RECURS)
				If l010Altera.Or.l010Exclui
					If !SoftLock("AE2")
						lContinua := .F.
					Else
						aAdd(aRecAE2Re,RecNo()) 
						nPosRec1 := GDFieldPos("AE2_REC_WT")
					Endif
				EndIf
				aADD(aColsSV[4],Array(Len(aHeaderSV[4])+1))
				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+AE2->AE2_RECURS))
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial()+AE2->AE2_PRODUT))
				For ny := 1 to Len(aHeaderSV[4])
					If ( aHeaderSV[4][ny][10] != "V")
						aColsSV[4][Len(aColsSV[4])][ny] := FieldGet(FieldPos(aHeaderSV[4][ny][2]))
					Else
						Do Case
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_TIPO"
								If !Empty(AE2->AE2_PRODUT)
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_TIPO
								EndIf
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_DESCRI"
								aColssv[4][Len(aColsSV[4])][ny] := AE8->AE8_DESCRI
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_UM"
								If !Empty(AE2->AE2_PRODUT)
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_UM
								EndIf
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_SEGUM"
								If !Empty(AE2->AE2_PRODUT)
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_SEGUM
								EndIf
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_SIMBCS"
								If !Empty(AE2->AE2_PRODUT)
									aColsSV[4][Len(aColsSV[4])][ny] := GetMV("MV_SIMB"+RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
								EndIf
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_CUSTD"
								If !Empty(AE8->AE8_VALOR)
									aColsSV[4][Len(aColsSV[4])][ny] := AE8->AE8_VALOR
		   						Else
		   							aColsSV[4][Len(aColsSV[4])][ny] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
		   						Endif
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_ALI_WT"
								aColsSV[4][Len(aColsSV[4])][ny] := "AE2"
							Case AllTrim(aHeaderSV[4][ny][2]) == "AE2_REC_WT"
								aColsSV[4][Len(aColsSV[4])][ny] := AE2->(Recno())									
							OtherWise
								aColsSV[4][Len(aColsSV[4])][ny] := CriaVar(aHeaderSV[4][ny][2])
						EndCase
					EndIf
					aColsSV[4][Len(aColsSV[4])][Len(aHeaderSV[4])+1] := .F.
				Next ny
			EndIf
			dbSelectArea("AE2")
			AE2->(dbSkip())
		EndDo
		If Empty(aColsSV[4])

			// faz a montagem de uma linha em branco no aColsAE2
			aadd(aColsSV[4],Array(Len(aHeaderSV[4])+1))
			For ny := 1 to Len(aHeaderSV[4])
				If Trim(aHeaderSV[4][ny][2]) == "AE2_ITEM"
					aColsSV[4][1][ny] 	:= "01"
				ElseIf AllTrim(aHeaderSV[4][ny][2]) $ "AE2_ALI_WT | AE2_REC_WT"
					If AllTrim(aHeaderSV[4][ny][2]) == "AE2_ALI_WT"
						aColsSV[4][1][ny] := "AE2"				
					ElseIf AllTrim(aHeaderSV[4][ny][2]) == "AE2_REC_WT"
						aColsSV[4][1][ny] := 0
					EndIf	
				Else
					aColsSV[4][1][ny] := CriaVar(aHeaderSV[4][ny][2])
				EndIf
				aColsSV[4][1][Len(aHeaderSV[4])+1] := .F.
			Next ny
		EndIf
EndIf
	
// valida se utiliza o template CCT
If lUsaCCT 
	If ExistTemplate("CCTAE2INI")
		ExecTemplate("CCTAE2INI",.F.,.F.)
	EndIf
EndIf

// faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize(,.F.,370)
aObjects := {} 

AAdd( aObjects, { 100, 100 , .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

aHeader	:= aClone(aHeaderSV[1])
aCols		:= aClone(aColsSV[1])

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	Zero()
	oEnch:= MsMGet():New(cAlias, nReg, nOpcx,,,,,aPosObj[1],,,,,,oDlg,,.T.,.F.,,.F. )

	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
	oFolder:bSetOption:={|nFolder| A010SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@oGD) }
	
	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next	
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[1])
	aCols		   := aClone(aColsSV[1])
	oGD[1]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A010GD1LinOk","A010GD1TudOk","+AE2_ITEM",.T.,,1,,300,,,,"A010GDDel(1)",oFolder:aDialogs[1])

	oFolder:aDialogs[2]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[2])
	aCols		   := aClone(aColsSV[2])
	oGD[2]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A010GD2LinOk","A010GD2TudOK","+AE3_ITEM",.T.,,1,,300,,,,"A010GDDel(2)",oFolder:aDialogs[2])
	
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	aHeader		:= aClone(aHeaderSV[3])
	aCols		   := aClone(aColsSV[3])
	oGD[3]		:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A010GD3LinOk","A010GD3TudOK","+AE4_ITEM",.T.,,1,,300,,,,"A010GDDel(3)",oFolder:aDialogs[3])

	oFolder:aDialogs[4]:oFont := oDlg:oFont
	aHeader	:= aClone(aHeaderSV[4])
	aCols		:= aClone(aColsSV[4])
	oGD[4]	:= MsGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nOpcx,"A010GD4LinOk","A010GD4TudOK","+AE2_ITEM",.T.,,1,,300,"A010GD4FieldOk",,,"A010GDDel(4)",oFolder:aDialogs[4])
	
	If lExistADV
		oFolder:aDialogs[5]:oFont := oDlg:oFont
		nGdOpc	:= IIf(l010Inclui .OR. l010Altera,GD_INSERT+GD_UPDATE+GD_DELETE,0)
		oGD[5]	:= MsNewGetDados():New(4,4,aPosObj[2,3]-aPosObj[2,1]-18,aPosObj[2,4]-8,nGdOpc,"A010GD5LinOk","A010GD5TudOK","+ADV_ITEM",,,300,"A010GD5FieldOk",,"A010GDDel(5)",oFolder:aDialogs[5],aHeaderSV[5],aColsSV[5])
	EndIf
 
 	//
 	// O conteudo da variavel nOldFolder deve ser da posicao utilizada dos arrays acolssv e aheadersv 
 	// que foram atribuidos em aheader e acols. 
 	//
	A010SetOption(1,4,@aCols,@aHeader,@oGD)	

FATPDLogUser("PA010DIALO")
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela).And.AGDTudok(1,oFolder).And.AGDTudok(2,oFolder).And.AGDTudok(3,oFolder) .And. AGDTudok(4,oFolder).AND.If(lExistADV,AGDTudok(5,oFolder),.T.),(nOpcA:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)

If (l010Inclui .Or.l010Altera .Or. l010Exclui) .And. nOpcA == 1 
	Begin Transaction
		A010Grava(l010Exclui,nRecAE1,aRecAE2,aRecAE3,aRecAE4,l010Altera,aRecAE2Re)
	End Transaction
EndIf
          
If l010Altera.Or.l010Exclui
	AE1->( MsUnlockAll() )
EndIf

If ExistBlock("PMA010GRV")
	ExecBlock("PMA010GRV",.F.,.F., {l010Inclui,l010Altera,l010Exclui,(nOpcA==1)} )
EndIf

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010SetOption(nFolder,nOldFolder,aCols,aHeader,oGD)
           
If nOldFolder!=Nil .And. nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])

	// salva o conteudo da GetDados se existir
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint := .T.
EndIf

If nFolder!=Nil .And. nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])

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
±±³Fun‡…o    ³A010GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD1LinOk()

Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_PRODUT"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_QUANT"})
Local lRet 		:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosProd])
		Help("  ",1,"PMSA0101")
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(aCols[n][nPosQT])
		HELP("  ",1,"PMSA0102")
		lRet := .F.
	EndIf
EndIf
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD2LinOk()

Local nPosDescri:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_DESCRI"})
Local nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_VALOR"})
Local nPosTP	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_TIPOD"})
Local lRet 		:= .T.

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
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 3.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD3LinOk()

Return MaCheckCols(aHeader,aCols,n)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD4LinOk³ Autor ³ Adriano Ueda        ³ Data ³ 27-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 4.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD4LinOk()

Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_RECURS"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_QUANT"})
Local lRet 		:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosProd])
		Help("  ",1,"PMSA0101")
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(aCols[n][nPosQT])
		HELP("  ",1,"PMSA0102")
		lRet := .F.
	EndIf
EndIf
	
Return lRet
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD5LinOk³ Autor ³ Vendas Clientes     ³ Data ³ 30-01-2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 5.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD5LinOk()
Local lRet 		:= .T.
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGDTudOk³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
±±³          ³ TudOk da GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(nGetDados,oFolder)
Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local lRet			:= .T.

Eval(oFolder:bSetOption)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.

aCols			:= aClone(aColsSV[nGetDados])
aHeader		:= aClone(aHeaderSV[nGetDados])
n				:= aSavN[nGetDados]
oFolder:nOption	:= nGetDados

Do Case
	Case nGetDados == 1
		lRet := A010GD1Tudok()
	Case nGetDados == 2
		lRet := A010GD2Tudok()	
	Case nGetDados == 3
		lRet := A010GD3Tudok()	
	Case nGetDados == 4
		lRet := A010GD4Tudok()
	Case nGetDados == 5
		lRet := A010GD5Tudok()	
EndCase

// valida se utiliza o template CCT
If lUsaCCT .And. nGetDados == 1
	If ExistTemplate("CCTAE1CUST")
		ExecTemplate("CCTAE1CUST",.F.,.F.,{nGetDados})
	EndIf
EndIf

aColsSV[nGetDados] := aClone(aCols)
aHeaderSV[nGetDados] := aClone(aHeader)

If nGetDados != oFolder:nOption
	aCols	:= aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		:= nSavN
EndIf

Return lRet 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados 1                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010GD1TudOk()

Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_PRODUT"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_QUANT"})
Local nSavN	:= n
Local lRet	:= .T.
Local nx := 0
Local lP010GD1 := ExistBlock( "P010GD1" )

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosProd]) .Or. !Empty(aCols[n][nPosQT])
		If !A010GD1LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

IF lP010GD1 .And. lRet
	lRet := ExecBlock( "P010GD1", .F., .F., {aCols, aHeader} )
EndIf

n	:= nSavN
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD2TudOk()

Local nPosDescri:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_DESCRI"})
Local nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_VALOR"})
Local nPosTP	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE3_TIPOD"})
Local nSavN	:= n
Local lRet	:= .T.
Local nx := 0
Local lP010GD2 := ExistBlock( "P010GD2" )

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosDescri]).Or.!Empty(aCols[n][nposValor]).Or.!Empty(aCols[n][nPosTP])
		If !A010GD2LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

IF lP010GD2 .And. lRet
	lRet := ExecBlock( "P010GD2", .F., .F., {aCols, aHeader} )
EndIf
	
n	:= nSavN

Return lRet

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 2.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD3TudOk()
Local nPosSubCmp	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE4_SUBCOM"})
Local nSavN	:= n
Local lRet	:= .T.
Local nx := 0 
Local lP010GD3 := ExistBlock( "P010GD3" )

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosSubCmp])
		If !A010GD3LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

If lP010GD3 .And. lRet
   lRet := ExecBlock( "P010GD3", .F., .F., {aCols, aHeader} )	
EndIf
	
n	:= nSavN

Return lRet


Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD4TudOk³ Autor ³ Edson Maricate      ³ Data ³ 28-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados 4                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 4.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010GD4TudOk()

Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_RECURS"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_QUANT"})
Local nSavN	:= n
Local lRet	:= .T.
Local nx		:=0  
Local lP010GD4 := ExistBlock( "P010GD4" )

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosProd]) .Or. !Empty(aCols[n][nPosQT])
		If !A010GD4LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

If lP010GD4 .And. lRet
   lRet := ExecBlock( "P010GD4", .F., .F., {aCols, aHeader} )	
EndIf

n	:= nSavN
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD5TudOk³ Autor ³ Vendas Clientes     ³ Data ³ 30-01-2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados 5                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 5.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD5TudOk()

Local lRet	:= .T.  
Local lP010GD5 := ExistBlock( "P010GD5" )

If lP010GD5 .And. lRet
   lRet := ExecBlock( "P010GD5", .F., .F., {aCols, aHeader} )	
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010Grava³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a gravaco da composicao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA010.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010Grava(lExclui,nRecAE1,aRecAE2,aRecAE3,aRecAE4,lAltera,aRecAE2Re)


Local nPosProd	:= aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AE2_PRODUT"})
Local nPosDescri:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AE3_DESCRI"})
Local nPosSubCmp:= aScan(aHeaderSV[3],{|x|AllTrim(x[2])=="AE4_SUBCOM"})
Local nPosRec   := aScan(aHeaderSV[4],{|x|AllTrim(x[2])=="AE2_RECURS"})
Local nPosComp	:= 0
Local nPosRecNo := 0 
Local nPosMemo	:= 0
Local bCampo 	:= {|n| FieldName(n) }
Local aRecADV	:= {}
Local nCntFor
Local nCntFor2
Local nx
Local lExistADV	:= (Len(aHeaderSV) >= 5)
Local lExistAG6 := ChkFile("AG6") 
Local cTpPerg	:= "1"

If !lExclui

	// grava arquivo AE1 (Composicoes)
	dbSelectArea("AE1")
	If lAltera
		dbGoto(nRecAE1)
		RecLock("AE1",.F.)
	Else
		RecLock("AE1",.T.)
	EndIf
	AE1->AE1_ULTATU	:= dDataBase
	For nCntFor := 1 TO FCount()
		If "FILIAL"$Field(nCntFor)
			FieldPut(nCntFor,xFilial("AE1"))
		Else
			FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
		EndIf
	Next nCntFor
	AE1->AE1_ULTATU	:= MsDate()
	MsUnlock()
	AE1->(FkCommit())	

	// grava arquivo AE2 (Itens)
	dbSelectArea("AE2")
	For nCntFor := 1 to Len(aColsSV[1])
		If !aColsSV[1][nCntFor][Len(aHeaderSV[1])+1]
			If !Empty(aColsSV[1][nCntFor][nPosProd])
				If nCntFor <= Len(aRecAE2)
					dbGoto(aRecAE2[nCntFor])
					RecLock("AE2",.F.)
				Else
					RecLock("AE2",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[1])
			      If ( aHeaderSV[1][nCntFor2][10] != "V" )
						AE2->(FieldPut(FieldPos(aHeaderSV[1][nCntFor2][2]),aColsSV[1][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AE2->AE2_FILIAL	:= xFilial("AE2")
				AE2->AE2_COMPOS := AE1->AE1_COMPOS
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecAE2)
				dbGoto(aRecAE2[nCntFor])
				RecLock("AE2",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor
	AE2->(FkCommit())	

	// grava arquivo AE3 (Despesas)
	dbSelectArea("AE3")
	For nCntFor := 1 to Len(aColsSV[2])
		If !aColsSV[2][nCntFor][Len(aHeaderSV[2])+1]
			If !Empty(aColsSV[2][nCntFor][nPosDescri])
				If nCntFor <= Len(aRecAE3)
					dbGoto(aRecAE3[nCntFor])
					RecLock("AE3",.F.)
				Else
					RecLock("AE3",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[2])
			      If ( aHeaderSV[2][nCntFor2][10] != "V" )
						AE3->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AE3->AE3_FILIAL	:= xFilial("AE3")
				AE3->AE3_COMPOS := AE1->AE1_COMPOS
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecAE3)
				dbGoto(aRecAE3[nCntFor])
				RecLock("AE3",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor
	AE3->(FkCommit())	

	// grava arquivo AE4 (SubComposicoes)
	dbSelectArea("AE4")
	For nCntFor := 1 to Len(aColsSV[3])
		If !aColsSV[3][nCntFor][Len(aHeaderSV[3])+1]
			If !Empty(aColsSV[3][nCntFor][nPosSubCmp])
				If nCntFor <= Len(aRecAE4)
					dbGoto(aRecAE4[nCntFor])
					RecLock("AE4",.F.)
				Else
					RecLock("AE4",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[3])
			      If ( aHeaderSV[3][nCntFor2][10] != "V" )
						AE4->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AE4->AE4_FILIAL	:= xFilial("AE4")
				AE4->AE4_COMPOS := AE1->AE1_COMPOS
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecAE4)
				dbGoto(aRecAE4[nCntFor])
				RecLock("AE4",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor
	AE4->(FkCommit())		

	// grava arquivo AE2 (Recursos)
		dbSelectArea("AE2")
		For nCntFor := 1 to Len(aColsSV[4])
			If !aColsSV[4][nCntFor][Len(aHeaderSV[4])+1]
				If !Empty(aColsSV[4][nCntFor][nPosRec])
					If nCntFor <= Len(aRecAE2Re)
						dbGoto(aRecAE2Re[nCntFor])
						RecLock("AE2",.F.)
					Else
						RecLock("AE2",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[4])
				      If ( aHeaderSV[4][nCntFor2][10] != "V" )
							AE2->(FieldPut(FieldPos(aHeaderSV[4][nCntFor2][2]),aColsSV[4][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AE2->AE2_FILIAL	:= xFilial("AE2")
					AE2->AE2_COMPOS := AE1->AE1_COMPOS
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAE2Re)
					dbGoto(aRecAE2Re[nCntFor])
					RecLock("AE2",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		Next nCntFor
		AE2->(FkCommit())	
	
	//grava arquivo ADV (Componentes)
	If lExistADV  
	 
		nPosComp := aScan(aHeaderSV[5],{|x|AllTrim(x[2])=="ADV_CODCMP"})
		nPosRecNo:= aScan(aHeaderSV[5],{|x|AllTrim(x[2])=="ADV_REC_WT"})
		nPosMemo := aScan(aHeaderSV[5],{|x|AllTrim(x[2])=="ADV_MEMO"  })   
		
		dbSelectArea("ADV")
		
		For nCntFor	:= 1 to Len(oGd[5]:aCols)
			If !aTail(oGd[5]:aCols[nCntFor])
				If !Empty(oGd[5]:aCols[nCntFor][nPosComp])
					If oGd[5]:aCols[nCntFor][nPosRecNo] > 0
						dbGoto(oGd[5]:aCols[nCntFor][nPosRecNo])
						RecLock("ADV",.F.)
					Else
						RecLock("ADV",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[5])
						If (aHeaderSV[5][nCntFor2][10] != "V" )
							ADV->(FieldPut(FieldPos(aHeaderSV[5][nCntFor2][2]),oGd[5]:aCols[nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					ADV->ADV_FILIAL	:= xFilial("ADV")
					ADV->ADV_COMPOS := AE1->AE1_COMPOS  
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava campo memo³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( nPosMemo <> 0 )
						If !Empty(oGd[5]:aCols[nCntFor][nPosMemo])
							MSMM(ADV->ADV_CODMEM,,,oGd[5]:aCols[nCntFor][nPosMemo],1,,,"ADV","ADV_CODMEM")
						ElseIf !Empty(ADV->ADV_CODMEM)
							MSMM(ADV->ADV_CODMEM,,,,2)
							ADV->ADV_CODMEM := ""
						EndIf
					EndIf
					
					MsUnlock()
				EndIf
			Else 
				If oGd[5]:aCols[nCntFor][nPosRecNo] > 0
					dbGoto(oGd[5]:aCols[nCntFor][nPosRecNo]) 
					If !Empty(ADV->ADV_CODMEM)
						MSMM(ADV->ADV_CODMEM,,,,2)
					EndIf
					RecLock("ADV",.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next 
		
		ADV->(FkCommit()) 
		
	EndIf
		
Else

	// grava arquivo AE2 (Itens)
	dbSelectArea("AE2")
	
	For nx := 1 to Len(aRecAE2)
		dbGoto(aRecAE2[nx])
		RecLock("AE2",.F.,.T.)
		dbDelete()
		MsUnlock()
	Next
	AE2->(FkCommit())	

	// grava arquivo AE3 (Itens)
	dbSelectArea("AE3")
	For nx := 1 to Len(aRecAE3)
		dbGoto(aRecAE3[nx])
		RecLock("AE3",.F.,.T.)
		dbDelete()
		MsUnlock()
	Next
	AE3->(FkCommit())	

	// grava arquivo AE4
	dbSelectArea("AE4")
	For nx := 1 to Len(aRecAE4)
		dbGoto(aRecAE4[nx])
		RecLock("AE4",.F.,.T.)
		dbDelete()
		MsUnlock()
	Next
	AE4->(FkCommit())	

	// grava arquivo AE2 (Recursos)
	dbSelectArea("AE2")
		For nx := 1 to Len(aRecAE2Re)
			dbGoto(aRecAE2Re[nx])
			RecLock("AE2",.F.,.T.)
			dbDelete()
			MsUnlock()
		Next
		AE2->(FkCommit())	
		
	// exclui registros da ADV (Componentes)
	If lExistADV
		dbSelectArea("ADV")
		dbSetOrder(1)	//ADV_FILIAL+ADV_COMPOS+ADV_ITEM
		dbSeek(xFilial("ADV")+AE1->AE1_COMPOS)
		While !ADV->(Eof()) 					.AND.;
			ADV->ADV_FILIAL == xFilial("ADV") 	.AND.;
			ADV->ADV_COMPOS == AE1->AE1_COMPOS
			AAdd(aRecADV,ADV->(Recno()))
			ADV->(DbSkip())
		End
		For nX := 1 to Len(aRecADV)
			dbGoto(aRecADV[nx])
			If !Empty(ADV->ADV_CODMEM)
				MSMM(ADV->ADV_CODMEM,,,,2)
			EndIf
			RecLock("ADV",.F.,.T.)
			dbDelete()
			MsUnlock()
		Next nX  
		ADV->(FkCommit())	
	EndIf
	
	// exclui perguntas relacionadas na AG6
	If lExistAG6

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui perguntas relacionadas ao AF1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AG6")
		dbSetOrder(1) //"AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_LOCAL+AG6_CODPER"
		dbSeek(xFilial("AG6")+cTpPerg+AE1->AE1_COMPOS)
		aRecnos	:= {}
		
		While !AG6->(Eof()) 					.AND.;
			AG6->AG6_FILIAL	== xFilial("AG6")	.AND.;
			AG6->AG6_TIPO	== cTpPerg			.AND.;
			AG6->AG6_CODPRO	== AE1->AE1_COMPOS
			
			AAdd(aRecnos,AG6->(Recno()))
			
			AG6->(DbSkip())
		End
		
		For nX := 1 to Len(aRecnos)
	
			AG6->(DbGoTo(aRecnos[nX]))
			RecLock("AG6",.F.)
			DbDelete()
			MsUnLock()
	
		Next nX
		
	EndIf
		
	// exclui arquivo AE1 (Composicoes)
	dbSelectArea("AE1")
	dbGoto(nRecAE1)
	RecLock("AE1",.F.,.T.)
	dbDelete()
	MsUnlock()
	AE1->(FkCommit())	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010SXBInclui³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Inclusao de Composicoes.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AE1                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SXBInclui()

PMSA010(3)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010SXBVisual³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Visualizacao de Composicoes.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AE1                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SXBVisual()

PMSA010(2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMA010Copy³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 16/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para criar Composicoes a partir de outra composicao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA010,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010Copy(cAlias,nReg,nOpcx)
Local nOpc       := Aviso(STR0020,STR0021,{STR0022,STR0023},2) //"Copiar Composicao"###"Esta rotina tem como objetivo criar uma nova Composicao a partir de uma Composicao ja existente. Selecione a origem da copia."###"Composicao"###"Cancelar"
Local lHelpADV   := .F.
Local cMensagem  := ""
Local cTpTrfCpy  := ""
Local cTpTarefa  := ""
Local cChvPsqADV := ""

If (nOpc == 1)
	If ParamBox({{1,STR0022,CriaVar("AE1_COMPOS",.F.),"@!","AE1->(dbSeek(xFilial('AE1')+AllTrim(mv_par01)))","AE1","",40,.T.}} ,STR0019 ,, ) //"Composicao" ### "Copia"
		nRec := Recno()
		cTpTarefa := AE1->AE1_TPTARE
		If !(AxInclui(cAlias,nReg,nOpcx,,"PA010CPYINI" )<>1)
			cTpTrfCpy := AE1->AE1_TPTARE
			Begin Transaction

				dbSelectArea("AE1")
				PmsImpoCon(nRec)

				dbSelectArea("AE2")
				dbSetOrder(1)
				Mv_Par01 := xFilial("AE2") + Mv_Par01
				MsSeek(Mv_Par01)
				While !Eof() .And. (xFilial("AE2") + AE2_COMPOS == Mv_Par01)
					nRec := Recno()
					DbGoto( PmsImpoReg("AE2",{{"AE2_COMPOS",AE1->AE1_COMPOS}}) )
					PmsImpoCon(nRec)
					DbGoto(nRec)
					dbSkip()
				End

				dbSelectArea("AE3")
				dbSetOrder(1)
				MsSeek(Mv_Par01)
				While !Eof() .And. (xFilial("AE3") + AE3_COMPOS == Mv_Par01)
					nRec := Recno()
					DbGoto( PmsImpoReg("AE3",{{"AE3_COMPOS",AE1->AE1_COMPOS}}) )
					PmsImpoCon(nRec)
					DbGoto(nRec)
					dbSkip()
				End

				dbSelectArea("AE4")
				dbSetOrder(1)
				MsSeek(Mv_Par01)
				While !Eof() .And. (xFilial("AE4") + AE4_COMPOS == Mv_Par01)
					nRec := Recno()
					DbGoto( PmsImpoReg("AE4",{{"AE4_COMPOS",AE1->AE1_COMPOS}}) )
					PmsImpoCon(nRec)
					DbGoto(nRec)
					dbSkip()
				End
				
				DbSelectArea("ADV")
				ADV->(DbSetOrder(1))
				// Preparar chave de pesquisa do registro da tabela ADV conforme compartilhamento atual da tabela
				cChvPsqADV := StrTran(Mv_Par01, FwXFilial("AE1"), FwXFilial("ADV"))
				If ADV->(MsSeek(cChvPsqADV))
					If (PA010VldTf(@cMensagem, 2 /*nOrigemVld = 2 = na cópia da composição*/, cTpTrfCpy))
				 		If (cTpTrfCpy == cTpTarefa)
							While !ADV->(EOF()) .And. (xFilial("ADV") + ADV->ADV_COMPOS == cChvPsqADV)
								nRec := ADV->(Recno())
								ADV->(DbGoto(PmsImpoReg("ADV",{{"ADV_COMPOS", AE1->AE1_COMPOS}})))
								PmsImpoCon(nRec)
								ADV->(DbGoto(nRec))
								ADV->(DbSkip())
							End
						Else
							cMensagem := STR0030 + "(" + AllTrim(cTpTrfCpy) + ")" + STR0031 + "(" + AllTrim(cTpTarefa) + ")." // "O programa não selecionou e copiou os componente da composição informada para manter a integridade entre o tipo de tarefa e os componentes copiados. O tipo de tarefa informado " #" não é igual ao da composição selecionada para cópia " 
							lHelpADV := .T.
						EndIf
					Else
						lHelpADV := .T.	
					EndIf
				EndIf
					
			End Transaction
			
			If lHelpADV
				Help(" ", 1, STR0026, NIL, cMensagem, 1, 1)	// #"Atencao" 
			EndIf
			
			If ExistBlock("PMA010FCC")
				ExecBlock("PMA010FCC", .F., .F.)
			EndIf
		EndIf              
	EndIf
EndIf
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GDDel    ³ Autor ³Fabio Rogerio Pereira³ Data ³01-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao do item da getdados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AE1                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GDDel(nGet)

// somente valida a exclusao de itens para opcao diferente de Visualizar
If (oGD[nGet]:oBrowse:nOpc <> 2)

	// valida se utiliza o template CCT
	If lUsaCCT
		If ExistTemplate("CCTAE1CUST")
			ExecTemplate("CCTAE1CUST",.F.,.F.,{nGet})
		EndIf
	EndIf
EndIf

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010SegUm    ³ Autor ³Adriano Ueda         ³ Data ³07-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a segunda unidade de medida do produto na composicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - AE1                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010SegUm()
Local aAreaSB1 := SB1->(GetArea())
Local ny := 0
  
Local nProdutoPos := 0
Local nQtSegUmPos := 0
Local nProdQtdPos := 0

// procura o codigo do produto
// digitado no aCols
For ny := 1 To Len(aHeaderSV[1])

	Do Case
		Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_PRODUT"
			nProdutoPos := ny

		Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_QTSEGU"
			nQtSegUmPos := ny
		
		Case AllTrim(aHeaderSV[1][ny][2]) == "AE2_QUANT"
			nProdQtdPos := ny
			
	EndCase
Next

If nProdutoPos > 0
	SB1->(dbSetOrder(1))
  
	// procura o produto no SB1
	If SB1->(dbSeek(xFilial() + aCols[n][nProdutoPos]))

		// se o fator de conversao e o tipo de conversao
		// nao forem vazios
		If SB1->B1_CONV > 0 .And. SB1->B1_TIPCONV <> ""
			If nQtSegUmPos > 0

				// multiplica ou divide a quantidade pelo fator
				If SB1->B1_TIPCONV = "M"
					aCols[n][nQtSegUmPos] := M->AE2_QUANT * SB1->B1_CONV
				Else
					aCols[n][nQtSegUmPos] := M->AE2_QUANT / SB1->B1_CONV
				EndIf
			EndIf
  		EndIf
 		EndIf
EndIf
  
RestArea(aAreaSB1)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD4FieldOk³ Autor ³ Adriano Ueda      ³ Data ³ 28/06/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 4                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD4FieldOk()  

Local cCampo		:= ReadVar()
Local lRet			:= .T.
Local nPosDescri	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_DESCRI"})
Local nPosProd    := aScan(aHeader,{|x|AllTrim(x[2])=="AE2_PRODUT"})
Local nPosRec     := aScan(aHeader,{|x|AllTrim(x[2])=="AE2_RECURS"})
Local nPosCUSTD	:= aScan(aHeader,{|x|AllTrim(x[2])=="AE2_CUSTD"})   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cCampo == "M->AE2_RECURS"
	  If !Empty(M->AE2_RECURS)
			AE8->(dbSetOrder(1))
			AE8->(dbSeek(xFilial()+M->AE2_RECURS))
			aCols[n][nPosDescri] := AE8->AE8_DESCRI
			If !Empty(AE8->AE8_PRODUT)
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial()+AE8->AE8_PRODUT))
				aCols[n][nPosProd] 		:= AE8->AE8_PRODUT
				aCols[n][nposCustD]		:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
			EndIf
			If !Empty(AE8->AE8_VALOR)
				aCols[n][nposCustD]		:= AE8->AE8_VALOR
			EndIf
			If Empty(AE8->AE8_PRODUT) .And. Empty(AE8->AE8_VALOR)
				aCols[n][nPosProd] 		:= CriaVar("AE8_PRODUT")
				aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
			EndIf
		Else
			M->AE2_RECURS          	:= CriaVar(cCampo)
			aCols[n][nPosRec] 		:= CriaVar(cCampo)
			aCols[n][nPosProd] 		:= CriaVar("AE8_PRODUT")
			aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
			aCols[n][nPosDescri]		:= CriaVar("B1_DESC")
		EndIf
EndCase
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010GD5FieldOk³ Autor ³ Vendas Clientes   ³ Data ³ 31/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 5                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GD5FieldOk()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cCampo	:= AllTrim(ReadVar())
Local nPDesc	:= aScan(oGd[5]:aHeader,{|x|AllTrim(x[2])== "ADV_DSCCMP"})
Local nPCod		:= aScan(oGd[5]:aHeader,{|x|AllTrim(x[2])== "ADV_CODCMP"})
Local nPDescIt	:= aScan(oGd[5]:aHeader,{|x|AllTrim(x[2])== "ADV_DSCITE"})
Local nX		:= 0 
Local cSufixo	:= "" 

Do Case
	Case cCampo == "M->ADV_CODCMP"
		
		oGd[5]:aCols[oGd[5]:nAt][nPDesc]	:= Posicione("ADR",1,xFilial("ADR")+M->ADV_CODCMP,"ADR_DESCRI")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa os campos a direita³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		For nX := (nPCod+2) to Len(oGd[5]:aHeader) 
			If !(IsHeadRec(oGd[5]:aHeader[nX][2]) .Or. IsHeadAlias(oGd[5]:aHeader[nX][2]))
				oGd[5]:aCols[oGd[5]:nAt][nX] := CriaVar(oGd[5]:aHeader[nX][2])
			EndIF
		Next nX
		
	Case cCampo == "M->ADV_ITCOMP"
	
		DbSelectArea("ADU")
		DbSetOrder(1) //ADU_FILIAL+ADU_CODCMP+ADU_ITEM
		If DbSeek(xFilial("ADU")+oGd[5]:aCols[oGd[5]:nAt][nPCod]+M->ADV_ITCOMP)
			oGd[5]:aCols[oGd[5]:nAt][nPDescIt]	:= ADU->ADU_DESC

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenche os campos a direita com base no item selecionado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			For nX := (nPDescIt + 1) to Len(oGd[5]:aHeader)
				If !(IsHeadRec(oGd[5]:aHeader[nX][2]) .Or. IsHeadAlias(oGd[5]:aHeader[nX][2]))
					cSufixo	:= SubStr(oGd[5]:aHeader[nX][2],At("_",oGd[5]:aHeader[nX][2]),10)
					If cSufixo <> "_MEMO"
						oGd[5]:aCols[oGd[5]:nAt][nX] := ADU->&("ADU"+cSufixo)
					Else
						oGd[5]:aCols[oGd[5]:nAt][nX] := Msmm(ADU->ADU_CODMEM)
					EndIf
				EndIf
			Next nX
		
		EndIf		
		
EndCase

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAE4Che³ Autor ³ Adriano Ueda           ³ Data ³ 17/08/2005 ³±±
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
Function PMSAE4CheckRef(cCompSource, cCompDest)    

Local aAreaAE1 := AE1->(GetArea())
Local aAreaAE4 := AE4->(GetArea())
Local lRet     := .T.

// a composição origem e EDT destino não podem
// ser a mesma
If cCompSource == cCompDest
	lRet := .F.
	RestArea(aAreaAE1)
	RestArea(aAreaAE4)
	Return lRet				
EndIf	
 
dbSelectArea("AE4")
AE4->(dbSetOrder(1)) 	// AE4_FILIAL + AE4_COMPOS + AE4_ITEM

If AE4->(MsSeek(xFilial("AE4") + cCompSource))
	While !AE4->(Eof()) .And.;
		AE4->AE4_FILIAL + AE4->AE4_COMPOS == xFilial("AE4") + cCompSource

		If AE4->AE4_SUBCOM == cCompDest
			lRet := .F.
			RestArea(aAreaAE1)
			RestArea(aAreaAE4)			
			Return lRet
		Else
			lRet := PMSAE4CheckRef(AE4->AE4_SUBCOM, cCompDest)
			RestArea(aAreaAE1)
			RestArea(aAreaAE4)
			Return lRet				
		EndIf

		dbSelectArea("AE4")
		AE4->(dbSkip())
	End
EndIf					

RestArea(aAreaAE1)
RestArea(aAreaAE4)   

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PA010CPYIN³ Autor ³Reynaldo Miyashita     ³ Data ³ 22.12.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de inicializacao na tela de cadastro da copia de       ³±±
±±³          ³Composicao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010CPYINI()
	
	// Preencher o tipo de tarefa automaticamente para evitar inconsistencias e erros do usuario
	M->AE1_TPTARE := AE1->AE1_TPTARE 
	
	If ExistBlock("PA010INI")
		ExecBlock("PA010INI",.F.,.F.)
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
						{ STR0003,"PA010Dialog", 0 , 2},; //"Visualizar"
						{ STR0004,"PA010Dialog", 0 , 3},; //"Incluir"
						{ STR0005,"PA010Dialog", 0 , 4},; //"Alterar"
						{ STR0006,"PA010Dialog", 0 , 5},; //"Excluir"
						{ STR0019,"PA010Copy"  , 0 , 3} }   //"Copia" 
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novos itens no menu aRotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PMA10ROT")
	aRotinaNew := ExecBlock("PMA10ROT",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA010   ºAutor  ³Microsiga           º Data ³  01/31/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010Psq(cAlias)

Local cWhere	:= "" 
Local aCposLst	:= {}
Local nOrder	:= 1  
Local cCpoPesq	:= ""
Local cRetCpo	:= ""
Local cRetorno	:= ""  
Local lRet		:= .F.
Local lContinua	:= .F.
Local cCodComp	:= "" 
Local bSeek		:= Nil
Local cMensagem := ""
                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao eh necessario utilizar o pre-projeto na pesquisa do mesmo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cAlias == "ADR"
	
		If !(PA010VldTf(@cMensagem))
	
			MsgStop(cMensagem, STR0026)	// #"Atencao"
	
		Else
	
			aCposLst	:= {"ADR_CODIGO","ADR_DESCRI"}
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Remove deletados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TcSrvType() != "AS/400"
				cWhere	+= " ADT.D_E_L_E_T_ = '' "
			Else
				cWhere	+= " ADT.@DELETED@ = '' "
			EndIf
	
			cWhere		+= " AND ADT.ADT_CODTAR = '" + M->AE1_TPTARE + "' "	
			nOrder		:= 1  
			cCpoPesq	:= "ADR_DESCRI" 
			cRetCpo		:= "ADR_CODIGO"
			cJoin		:= " INNER JOIN "+RetSqlName("ADT")+" ADT ON ADT_FILIAL = ADR_FILIAL AND ADT_CODCMP = ADR_CODIGO "
			lContinua	:= .T. 
			bSeek		:= {||DbSeek(xFilial(cAlias)+cRetorno)}
	
		EndIf

	Case cAlias == "ADU"
		
		cCodComp	:= aCols[n][aScan(aHeader,{|x|AllTrim(x[2]) == "ADV_CODCMP" })]
		
		If Empty(cCodComp)
	
			MsgStop("Selecione o componente deste item antes de selecionar seu item de complexidade.","Atenção")
	
		Else
	
			aCposLst	:= {"ADU_ITEM","ADU_DESC","ADU_QUANT"}
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Remove deletados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TcSrvType() != "AS/400"
				cWhere	+= " ADR.D_E_L_E_T_ = '' "
			Else
				cWhere	+= " ADR.@DELETED@ = '' "
			EndIf
	
			cWhere		+= " AND ADU.ADU_CODCMP = '" + cCodComp + "' "	
			nOrder		:= 1  
			cCpoPesq	:= "ADU_DESC" 
			cRetCpo		:= "ADU_ITEM"
			cJoin		:= " INNER JOIN "+RetSqlName("ADR")+" ADR ON ADU_FILIAL = ADR_FILIAL AND ADU_CODCMP = ADR_CODIGO "
			lContinua	:= .T.
			bSeek		:= {||DbSeek(xFilial(cAlias)+cCodComp+cRetorno)}
	
		EndIf
	
EndCase

If lContinua

	cRetorno := Ft530F3(cAlias	, cWhere	, aCposLst	, nOrder	,;
						cCpoPesq, cRetCpo	, cJoin		)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona alias para que a pesquisa do SXB recupere o³
	//³registro localizado pelo usuario                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cRetorno)
		(cAlias)->(DbSetOrder(1))
		If (cAlias)->(Eval(bSeek))
			lRet := .T.
		EndIf
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA010TarefºAutor  ³Vendas Clientes     º Data ³  01/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a tarefa selecionada pelo usuario                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PMSA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010Taref()

Local aArea		:= GetArea()
Local cTarefa	:= &(ReadVar())
Local lRet		:= .T.
Local nCnt		:= 0
Local nPCompo	:= 0 
Local oObj      := NIL 


DbSelectArea("ADS")
DbSetOrder(1)

If (lRet:= DbSeek(xFilial("ADS")+cTarefa))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha itens preenchidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(IsInCallStack("PA010COPY"))
		If IsInCallStack("PMSA010")
			oObj	:= oGd[5]
			nPCompo	:= aScan(oObj:aHeader,{|x|AllTrim(x[2])== "ADV_CODCMP"})
		ElseIf IsInCallStack("FTA530Dlg")
			oObj	:= oGd[3]
			nPCompo	:= aScan(oObj:aHeader,{|x|AllTrim(x[2])== "ADX_CODCMP"})
		EndIf
	
		If oObj <> Nil
			
			For nCnt	:= 1 to Len(oObj:aCols)
				If !aTail(oObj:aCols[nCnt]) .AND. !Empty(oObj:aCols[nCnt][nPCompo])
					lRet := .F.
					MsgStop("Para alterar o tipo de tarefa, é necessário apagar todos os componentes atuais.")
					Exit
				EndIf
			Next nCnt
		EndIf
	EndIf	
Else
	Help(" ",1,"REGNOIS")
EndIf


RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA010   ºAutor  ³Vendas Clientes     º Data ³  31/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o componente selecionado                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PMSA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010Compo()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cComp		:= &(ReadVar())

DbSelectArea("ADR")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a existencia do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(lRet:= DbSeek(xFilial("ADR")+cComp))
	Help(" ",1,"REGNOIS")
Else
	DbSelectArea("ADT")            
	DbSetOrder(2) //ADT_FILIAL+ADT_CODCMP+ADT_CODTAR
	If !(lRet := DbSeek(xFilial("ADT")+ADR->ADR_CODIGO+M->AE1_TPTARE))
		MsgStop("O componente selecionado não corresponde ao tipo de tarefa desta composição","Atenção")
	EndIf
EndIf

RestArea(aArea)

Return lRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA010   ºAutor  ³Microsiga           º Data ³  01/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o item de complexidade selecionado                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PMSA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA010ItCom()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cItem		:= &(ReadVar())
Local cComp		:= oGd[5]:aCols[oGd[5]:nAt][aScan(oGd[5]:aHeader,{|x|AllTrim(x[2])=="ADV_CODCMP"})]

DbSelectArea("ADU")                                       
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a existencia do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(lRet:= DbSeek(xFilial("ADU")+cComp+cItem))
	Help(" ",1,"REGNOIS")
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA010   ºAutor  ³Microsiga           º Data ³  01/31/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PA010AfCol(aCols,aHeader)

Local aArea		:= GetArea()
Local nPos		:= Len(aCols)
Local nPCod		:= aScan(aHeader,{|x|AllTrim(x[2])== "ADV_CODCMP"})
Local nPItem	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADV_ITCOMP"})
Local nPDesc	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADV_DSCCMP"})
Local nPDescIt	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADV_DSCITE"})

aCols[nPos][nPDesc]		:= Posicione("ADR",1,xFilial("ADR")+aCols[nPos][nPCod],"ADR_DESCRI")
aCols[nPos][nPDescIt]	:= Posicione("ADU",1,xFilial("ADU")+aCols[nPos][nPCod]+aCols[nPos][nPItem],"ADU_DESC")

RestArea(aArea)

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} PA010VldTf()
Validar o preenchimento da tarefa no cabecalho da rotina - Tabela AE1.

@sample 	PA010VldTf(cAlias)
@param		cMensagem     , Char   , Mensagem caso a validacao seja negativa
@param		nOrigemVld    , Number , Tipo da execução para tratar a mensagem de retorno -> 1=Inclusão/Alteração 2=Cópia
@param      cTpTarefa     , Char   , Tipo da tarefa a ser avaliada.
@author 	Squad CRM
@since 		11/01/2019
@version 	12.1.17
@return 	lTrfPreenc    , Bool   , Indica se o tipo da tarefa esta preenchido ou nao. .T.=Preenchido, .F.=Falso
/*/
//-------------------------------------------------------------------
Function PA010VldTf(cMensagem, nOrigemVld, cTpTarefa)

	Local lTrfPreenc   := .T.
	Default nOrigemVld := 1
	Default cMensagem  := ""
	Default cTpTarefa  := Iif(nOrigemVld == 1, M->AE1_TPTARE, "") 
	
	If !(Empty(cTpTarefa))
		Return lTrfPreenc
	EndIf
	
	lTrfPreenc := .F. 
	
	Do Case 
		// Validacao do campo de código do componente
		Case nOrigemVld == 1
			cMensagem  := STR0028	// #"Selecione o tipo da tarefa desta composição antes de selecionar seus componentes."
		// Validacao na copia
		Case nOrigemVld == 2
			cMensagem := STR0029	// #"O programa não selecionou e copiou os componente da composição informada para manter a integridade entre o tipo de tarefa e os componentes copiados. Apesar de a composição selecionada para cópia conter o tipo de tarefa e seus componentes associados, na cópia não foi informado nenhum tipo de tarefa."
	EndCase
	
Return lTrfPreenc

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive   
