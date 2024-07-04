#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA040.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA040    ³ Autor ³ Newton Rogerio Ghir³ Data ³ 24/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Pastas / Manuais                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA040()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQDO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³ Programador ³Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³19/03/02  ³  META  ³ Eduardo S.  ³ Refeita a Rotina e criada Amarracao ³±±
±±³          ³        ³             ³ Departamentos x Pasta.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui", 0,1,,.F.},; // "Pesquisar"
				  {OemToAnsi(STR0002),"QD040Telas", 0,2},; // "Visualizar"
				  {OemToAnsi(STR0003),"QD040Telas", 0,3},; // "Incluir"
				  {OemToAnsi(STR0004),"QD040Telas", 0,4},; // "Alterar"
				  {OemToAnsi(STR0005),"QD040Telas", 0,5}}  // "Excluir"

Return aRotina

Function QDOA040()

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0006) // "Cadastro de Pastas/Manuais"
Private nQaConpad := 8

DbSelectArea("QDC")
DbSetOrder(1)
DbGoTop()

mBrowse(006,001,022,075,"QDC")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD040Telas³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Pastas / Manuais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040Telas(cAlias,nReg,nOpc)

Local aAlias    := {}
Local aAlter    := {}
Local aNoFields := {}
Local aTitles   := {}
Local nCnt      := 0
Local nI        := 0
Local nOpcao    := 0
Local oDlg      := NIL
Local oGetQDC   := NIL
Local oSayPas   := NIL
Local oSize     := NIL

Private aCols	   := {}
Private aGETS      := {}
Private aHeader    := {}
Private aTELA      := {}
Private bCampo     := {|nCPO| Field( nCPO ) }
Private cFilDep    := xFilial("QAD") // utilizada no SXB
Private lFwExecSta := FindClass( Upper("FwExecStatement") )
Private nUsado	   := 0
Private oGet       := NIL

RegToMemory("QDC",If(nOpc==3,.T.,.F.),.T.)

DbSelectArea("QDT")
QDT->(DbSetOrder(2))

DbSelectArea("QDC")
QDC->(DbSetOrder(1))

Aadd(aAlias,"QDC")
Aadd(aAlias,"QDT")

For nCnt:= 1 To Len(aAlias)
	DbSelectArea(aAlias[nCnt])
	If nOpc == 3 
	   For nI := 1 To FCount()
	       cCampo := Eval( bCampo, nI )
	       lInit  := .F.
	       If ExistIni( cCampo )
	          lInit := .T.
	          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
	          If ValType( M->&( cCampo ) ) = "C"
	             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
	          EndIf
	          If M->&( cCampo ) == Nil
	             lInit := .F.
	          EndIf
	       EndIf
	       If !lInit
	          M->&( cCampo ) := FieldGet( nI )
	          If ValType( M->&( cCampo ) ) = "C"
	             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
	          ElseIf ValType( M->&( cCampo ) ) = "N"
	             M->&( cCampo ) := 0
	          ElseIf ValType( M->&( cCampo ) ) = "D"
	             M->&( cCampo ) := CtoD( "  /  /  " )
	          ElseIf ValType( M->&( cCampo ) ) = "L"
	             M->&( cCampo ) := .f.
	          EndIf
	       EndIf
	   Next nI
	Else
	   For nI := 1 To FCount()
	       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	   Next nI
	EndIf
Next nCnt

If Inclui
	M->QDC_FILIAL:= xFilial("QDC")
	M->QDT_FILIAL:= xFilial("QDT")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "CABECALHO"    ,100, 35, .T., .T. ) // Adiciona Cabecalho
oSize:AddObject( "FOLDER"   ,  100, 17, .T., .F. ) // Adiciona Folder / Nao dimensiona
oSize:AddObject( "GETDADOS"    ,100, 65, .T., .T. ) // Adiciona GetDados 


oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 33, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL // "Cadastro de Pastas/Manuais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetQDC:=MsMGet():New( "QDC", nReg, nOpc,,,,,;
	 {oSize:GetDimension("CABECALHO","LININI"),;
	 oSize:GetDimension("CABECALHO","COLINI"),;
	 oSize:GetDimension("CABECALHO","LINEND"),;
	 oSize:GetDimension("CABECALHO","COLEND")};
	, , 3, , , , , ,.T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis do Objeto Folder                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTitles,STR0009) //"Departamentos x Pasta"admin
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Objeto Folder "Departamentos x Pasta"                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//                                                      
oSayPas:=TFolder():New( oSize:GetDimension("FOLDER","LININI"),;
                        oSize:GetDimension("FOLDER","COLINI"),aTitles,,,,,,.T.,;
                        .T.,oSize:GetDimension("FOLDER","XSIZE"),;
                        oSize:GetDimension("FOLDER","YSIZE") )

if FWModeAccess("QDC",3) == "C" 
	aNoFields := {"QDT_FILCOD","QDT_CODMAN","QDT_FILDEP","QDT_DESMAN","QDT_DESMadminAN"}
else
	aNoFields := {"QDT_FILCOD","QDT_CODMAN","QDT_DESMAN","QDT_DESMadminAN"}
Endif

cSeek  := QDC->QDC_FILIAL+QDC->QDC_CODMAN
cWhile := "QDC->QDC_FILIAL+QDC->QDC_CODMAN"

If Inclui
	FillGetDados(nOpc,"QDT",1     ,     ,          ,        ,aNoFields,          ,       ,      ,                     ,Inclui ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols             ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QDT",1     ,     ,          ,        ,aNoFields,          ,       ,      ,{|| QD040Acols(nOpc)},       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols             ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf
nPosFil:= aScan(aHeader, { |x| AllTrim(x[2]) == "QDT_FILDEP" })
nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que podem ser Alterados	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlter,"QDT_FILDEP")
Aadd(aAlter,"QDT_DEPTO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oGet := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),;
                         oSize:GetDimension("GETDADOS","COLINI"),;
                         oSize:GetDimension("GETDADOS","LINEND"),;
                         oSize:GetDimension("GETDADOS","COLEND"),;
                         nOpc,"QD040LinOk","QD040TudOk"," ",.T.,aAlter) 
                         
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. If(nOpc == 5,QD040MsgVd(),.T.) .And. QD040TudOk(nOpc),;
										(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED
							

If nOpc <> 2 .And. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		QDA040GPst(nOpc)	
	ElseIf nOpc == 5
		QDA040Dele()
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA040GPst³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Pastas / Manuais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA040GPst(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA040GPst(nOpc)

Local lRecLock:= .F.
Local nCnt    := 0
Local nCont   := 0
Local nCpo    := 0
Local nPosDel := Len(aHeader) + 1
Local nPos01  := aScan(aHeader, { |x| AllTrim(x[2]) == "QDT_DEPTO" })
Local nPos02  := Ascan(aHeader, { |x| Alltrim(x[2]) == "QDT_FILDEP"})

IF FWModeAccess("QDC",3) == "C"
	nPos02 := 2
Endif

If nOpc == 3
	lRecLock:= .T.
EndIf

If Altera
	dbSelectArea("QDT")
	dbSetOrder(2)
	dbSeek(M->QDC_FILIAL+M->QDC_CODMAN)
	While !Eof() .And. QDT->QDT_FILCOD == M->QDC_FILIAL .And. QDT->QDT_CODMAN == M->QDC_CODMAN
		RecLock("QDT",.F.)
		QDT->(DbDelete())
		MsUnlock()
		QDT->(DbSkip())
	EndDo
EndIF

Begin Transaction
	RecLock("QDC",lRecLock)
	For nCnt := 1 TO FCount()
		FieldPut(nCnt,M->&(Eval(bCampo,nCnt)))
	Next nCnt
	MsUnLock()      
	FKCOMMIT()
	
	DbSelectArea("QDT")
	DbSetOrder(2)
	For nCnt:= 1 To Len(aCols)
		If !aCols[nCnt, nPosDel] .And. !Empty(aCols[nCnt,nPos01])  // Verifica se o item foi deletado
			If Altera
				If QDT->(DbSeek(M->QDC_FILIAL+M->QDC_CODMAN+Acols[nCnt,nPos02]+Acols[nCnt,nPos01]))
					RecLock("QDT",.F.)
				Else
					RecLock("QDT",.T.)
				Endif
			Else
				RecLock("QDT",.T.)
			Endif
			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					QDT->(FieldPut(FieldPos(Trim(aHeader[nCpo,2])),aCols[nCnt,nCpo]))
				EndIf
			Next nCpo
			QDT->QDT_FILial:= xFilial("QDT")
			QDT->QDT_FILCOD:= M->QDC_FILIAL
			QDT->QDT_CODMAN:= M->QDC_CODMAN
			MsUnlock()
			FKCOMMIT()			
		Else
			If QDT->(DbSeek(M->QDC_FILIAL+M->QDC_CODMAN+Acols[nCnt,1]+Acols[nCnt,2])) .And. nOpc <> 3
				Aeval( aCols, { |X| X[nPos01] == aCols[N,nPos01] .And. X[nPos02] == aCols[N,nPos02] ,nCont++,nCont})
				If nCont == 1
					RecLock("QDT",.F.)
					QDT->(DbDelete())
					MsUnlock()
					FKCOMMIT()	
				EndIf
			Endif
		Endif
	Next nCnt
End Transaction

QDT->(DbSetOrder(1))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA040Dele³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Pastas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA040Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA040Dele()
Local cAliasQDT  := GetNextAlias()
Local cArquivQDT := RetSqlName("QDT")
Local cQuery     := ""
Local oExec      := NIL

DEFAULT lFwExecSta := .F. //Para facilitar a cobertuar de código não declarar essa variavel na user function

Begin Transaction

	If !lFwExecSta

		cQuery := " SELECT QDT.R_E_C_N_O_ "
		cQuery += "   FROM " + cArquivQDT + " QDT "
		cQuery += "  WHERE QDT.QDT_CODMAN = '" + M->QDC_CODMAN + "' "
		cQuery += "    AND QDT.QDT_FILIAL = '" + M->QDC_FILIAL + "' "
		cQuery += "    AND QDT.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDT)

	Else

		cQuery := " SELECT QDT.R_E_C_N_O_ "
		cQuery += "   FROM " + cArquivQDT + " QDT "
		cQuery += "  WHERE QDT.QDT_CODMAN  = ? "
		cQuery += "    AND QDT.QDT_FILIAL  = ? "
		cQuery += "    AND QDT.D_E_L_E_T_  = ? "
	
		oExec := FwExecStatement():New(cQuery)
		oExec:setString( 1, M->QDC_CODMAN )
		oExec:setString( 2, M->QDC_FILIAL )
		oExec:setString( 3, " "           )
		cAliasQDT := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 

	EndIf

	If &(cAliasQDT+"->(!Eof())")
		While &(cAliasQDT+"->(!Eof())")
			QDT->(DbGoTo(&(cAliasQDT+"->(R_E_C_N_O_)")))
			RecLock("QDT",.F.)
				QDT->(DbDelete())
			QDT->(MsUnlock())
			FKCOMMIT()
			&(cAliasQDT+"->(DbSkip())")
			LOOP
		EndDo
	EndIf
	&(cAliasQDT+"->(DbCloseArea())")

	RecLock("QDC",.F.)
		QDC->(DbDelete())
	QDC->(MsUnlock())
	FKCOMMIT()
	QDC->(DbSkip())

End Transaction

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD040MsgVd³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mensagem Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040MsgVd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040MsgVd()

lRet:= .T.

CursorWait()
MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0007),{|| QD040VdPst(@lRet)})	// "Validando a Exclusao da Pasta" ### "Aguarde..."
CursorArrow()

If !lRet
	Help(" ",1,"EXISTEMUN") // "Esta pasta esta em uso, nao e possivel exclui-la"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD040VdPst³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Pastas / Manuais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040VdPst(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 - Retorno da Validacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040VdPst(lRet)
Local cAliasQDG  := GetNextAlias()
Local cArquivQDG := RetSqlName("QDG")
Local cQuery     := ""
Local oExec      := NIL

DEFAULT lFwExecSta := .F. //Para facilitar a cobertuar de código não declarar essa variavel na user function

If !lFwExecSta

	cQuery := " SELECT QDG.R_E_C_N_O_ "
	cQuery += "   FROM " + cArquivQDG + " QDG "
	cQuery += "  WHERE QDG.QDG_CODMAN = '" + QDC->QDC_CODMAN + "' "
	cQuery += "    AND QDG.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDG)

Else

	cQuery := " SELECT QDG.R_E_C_N_O_ "
	cQuery += "   FROM " + cArquivQDG + " QDG "
	cQuery += "  WHERE QDG.D_E_L_E_T_  = ? "
	cQuery += "    AND QDG.QDG_CODMAN  = ? "

	oExec := FwExecStatement():New(cQuery)
	oExec:setString( 1, " "             )
	oExec:setString( 2, QDC->QDC_CODMAN )
	cAliasQDG := oExec:OpenAlias()
	oExec:Destroy()
	oExec := nil 

EndIf

	If &(cAliasQDG+"->(!Eof())")
		lRet := .F.
	EndIf
	&(cAliasQDG+"->(DbCloseArea())")

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD040Acols³ Autor ³Eduardo de Souza      ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040Acols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040Acols(nOpc)

Local   nI   := 0

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               		    	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	aCols := Array(1,nUsado+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD("  /  /  ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI
	aCols[1,nUsado+1] := .F.
Else
	DbSelectArea("QDT")
	DbSetOrder(2)
	If QDT->(DbSeek(QDC->QDC_FILIAL+QDC->QDC_CODMAN))
		While QDT->(!Eof()) .And. QDT->QDT_FILCOD+QDT->QDT_CODMAN == QDC->QDC_FILIAL+QDC->QDC_CODMAN
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				If !(aHeader[nI,2] $ "QDT_REC_WT | QDT_ALI_WT")
					If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Else										// Campo Virtual
						cCpo := AllTrim(Upper(aHeader[nI,2]))
						aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
						IF aHeader[nI,2] == 'QDT_DESDEP' .And. EMPTY(aCols[Len(aCols),nI])
							aCols[Len(aCols),nI] := QA_NDEPT(QDT->QDT_DEPTO,.F.,QDT->QDT_FILCOD)
						ENDIF
					EndIf
				ElseIf aHeader[nI,2] == "QDT_ALI_WT"
					aCols[Len(aCols),nI] := Alias()
				ElseIf IsHeadRec(aHeader[nI,2])
					aCols[Len(aCols),nI] := QDT->(RecNo())
				EndIf
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			QDT->(DbSkip())
		Enddo
	Else
		aCols := Array(1,nUsado+1)
		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD("  /  /  ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI
		aCols[1,nUsado+1] := .F.
	EndIf
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QD040LinOk³ Autor ³ Eduardo de Souza     ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040LinOk()

Local lRet   := .t.
Local nCont  := 0
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDT_FILDEP"})
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDT_DEPTO" })
Local nPosDel:= Len(aHeader) + 1
Local nX

If lRet .And. nPos01 <> 0 .And. nPos02 <> 0
	For nX := 1 To Len(aCols)
		Aeval( aCols, { |X| If(X[nPosDel] == .F. .And. X[nPos01] == aCols[nX,nPos01] .And. X[nPos02] == aCols[nX,nPos02],nCont++,nCont)})
		If nCont > 1
			Help(" ",1,"QALCTOJAEX")
			lRet:= .F.
			Exit
		ElseIf Empty(aCols[n,nPos02]) .And. Acols[n,nPosDel] == .F.
			Help(" ",1,"QDT_DEPTO")
			lRet := .F.
			Exit
		Endif
		nCont := 0
	Next nX
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QD040TudOk³ Autor ³ Wagner Mobile Costa  ³ Data ³ 23/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para confirmacao da gravacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD040TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD040TudOk(nOpc)
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDT_FILDEP"})
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDT_DEPTO" })
Local nPosDel:= Len(aHeader) + 1
Local lRet := .T.
Local nX

For nX := 2 To Len(aCols)
	If ! QD040LinOk()
		lRet := .F.
		Exit
	Endif
Next nX

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InDepQDT  ºAutor  ³Rafael S. Bernardi  º Data ³  19/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicialiazador padrao para o campo vitual QDT_DESDEP        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA040	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function InDepQDT()
Local nPos := 0
Local nX
Local oModel		:= FWModelActive()
Local lMVC			:= ValType(oModel) == "O"

If !lMVC
	For nX := 1 To Len(aHeader)
		If ascan(aHeader[nX],"QDT_DEPTO") != 0
			nPos := nX
		EndIf
	Next nX
	
	If nPos == 0
		Posicione("QAD",1,M->QAD_FILIAL+M->QAD_CUSTO,"QAD_DESC")
	Else
		If Len(aHeader) > 0
			Posicione("QAD",1,QDT->QDT_FILDEP+aCols[Len(aCols)][nPos],"QAD_DESC")
			Return QAD->QAD_DESC
		EndIf
	EndIf
EndIf
Return " "
