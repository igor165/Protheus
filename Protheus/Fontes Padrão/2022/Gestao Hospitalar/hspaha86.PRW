#INCLUDE "HSPAHA86.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHA86 ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Perguntas                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHA86()

Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Perguntas"

DbSelectArea("GNI") // Somente para criar a tabela GNI

DbSelectArea("GCH")
DbSetOrder(1) // GCH_FILIAL + GCH_CODPER

mBrowse(6, 1, 22, 75, "GCH",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_A86Roti ³ Autor ³ Robson Ramiro A.Olivei³ Data ³11.08.04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA86                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_A86Roti(cAlias, nReg, nOpc)

Local oDlg	    := NIL
Local nOpA 	   := ""                   
Local nGDOpc := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local aCposAlt := {}

Private aTela 		:= {}, aGets := {}
Private aHGNI := {}, aCGNI := {}, nUGNI := 0
Private oGNI, oEnchoi
Private nGNISTAREG, nGNICODITE,	nGNIDESMNE, nGNICODRES
                                  
DbSelectArea(cAlias)

DbSelectArea("SX3")
DbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
DbSeek("GCH")
While !Eof() .And. SX3->X3_ARQUIVO == "GCH"
  If !(SX3->X3_CAMPO $ "GCH_TIPPER/GCH_TAMRES/GCH_DECRES/GCH_PICRES/GCH_CBOX  ") .And. (nOpc == 4)
   aAdd(aCposAlt, SX3->X3_CAMPO)
  EndIf
 DbSkip()
End
RegToMemory("GCH", (nOpc == 3))
Inclui := .F.

If HS_ExisDic({{"T", "GNI"}}, .F.)
	nLenGD := HS_BDados("GNI", @aHGNI, @aCGNI, @nUGNI, 1, M->GCH_CODPER, IIf((nOpc == 3), Nil, "'" + M->GCH_CODPER + "' == GNI->GNI_CODPER"),.T.)
	nGNISTAREG := aScan(aHGNI, {| aVet | aVet[2] == "HSP_STAREG"})
	nGNICODITE := aScan(aHGNI, {| aVet | aVet[2] == "GNI_CODITE"})
	nGNIDESMNE := aScan(aHGNI, {| aVet | aVet[2] == "GNI_DESMNE"})
	nGNICODRES := aScan(aHGNI, {| aVet | aVet[2] == "GNI_CODRES"})

	//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
	If Empty(aCGNI[1, nGNICODITE])
		aCGNI[1, nGNICODITE] := StrZero(1, Len(GNI->GNI_CODITE))
	EndIf
EndIf

aSize 			:= MsAdvSize(.T.)
aObjects := {}
 
AAdd( aObjects, { 100, 070, .T., .T. } )
AAdd( aObjects, { 100, 030, .T., .T. } )
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007)From aSize[7], 0 TO aSize[6], aSize[5]	PIXEL of oMainWnd//"Perguntas"
 
oEnchoi := MsMGet():New("GCH", nReg, nOpc,,,,,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, IIF(nOpc == 4, aCposAlt, nil),,,,, oDlg,, .T.) 
oEnchoi:oBox:align := CONTROL_ALIGN_ALLCLIENT

If HS_ExisDic({{"T", "GNI"}}, .F.)
	oGNI := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAC(oGNI:oBrowse:nAt, oGNI:aCols, {nGNICODRES})",,"+GNI_CODITE",,, 99999,,,, oDlg, aHGNI, aCGNI)
	oGNI:oBrowse:align := CONTROL_ALIGN_BOTTOM
	oGNI:cFieldOk           := "HS_GDAtrib(oGNI, {{nGNIStaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)" 
 oGNI:oBrowse:bDelete    := {|| {HS_GDAtrib(oGNI, {{nGNIStaReg, "BR_CINZA", "BR_VERDE"}}, 4),oGNI:DelLine()}}
EndIf	

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,	{||	nOpA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpA == 0)},;
																																																	{||	nOpA := 0, oDlg:End()})

If (nOpA == 1) .And. (nOpc # 2)//(nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5)
	FS_A86Grav(nOpc)
EndIf

Return(Nil)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_A86Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava/Exclui                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_A86Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPAHA86                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FS_A86Grav(nOpc)

 Local lGraOk	:= .T., nCntFor := 1
 Local nCont		:= 0
 Local nCpo
 Local bCampo	:= { |nCPO| Field(nCPO) }

 /* Não Permite alteração de um pergunta que já esteja relacionada com algum grupo de perguntas */
 DbSelectArea("GCG")
 DbSetOrder(2) //GCG_FILIAL + GCG_CODPER
 If DbSeek(xFilial("GCG") + M->GCH_CODPER)
  If nOpc == 5 // Exsclusao
   HS_MsgInf(STR0009, STR0008, STR0010)//"Este código está sendo usado pelo Cadastro de Grupos de Perguntas. Impossível Excluí-lo!"###"Atenção"###"Exclusão não Permitida"
   Return(.F.)
	 EndIf 
 EndIf

 DbSelectArea("GCH")
 DbSetOrder(1) //GCH_FILIAL + GCH_CODPER

 Begin Transaction
  If (nOpc == 3 .Or. nOpc == 4)
 	 RecLock("GCH", nOpc == 3)
  	 For nCont := 1 To FCount()
 	 	 If "FILIAL" $ Field(nCont)
 	 	 	FieldPut(nCont, xFilial("GCH"))
 	 	 ElseIf "LOGARQ" $ Field(nCont)
 	 	 	FieldPut(nCont, HS_LOGARQ())
 	 	 Else
 	 	 	FieldPut(nCont, M->&(EVAL(bCampo, nCont)))
 	 	 EndIf
 	  Next nCont
 	 MsUnlock()	
  ElseIf nOpc == 5 
   RecLock("GCH", .F.)
 	  DbDelete()
 	 MsUnlock()
  EndIf

		If HS_ExisDic({{"T", "GNI"}}, .F.)
   For nCntFor := 1 To Len(oGNI:aCols)
    If oGNI:aCols[nCntFor, nGNIStaReg] <> "BR_VERDE"
     DbSelectArea("GNI")
     DbSetOrder(1) 
     lAchou := DbSeek(xFilial("GNI") + M->GCH_CODPER + oGNI:aCols[nCntFor, nGNICODITE])
     If Inclui .Or. Altera
      If oGNI:aCols[nCntFor, Len(oGNI:aCols[nCntFor])] .And. lAchou // exclusao
       RecLock("GNI", .F., .T.)
        DbDelete()
       MsUnlock()
       WriteSx2("GNI")
      Else
       If !oGNI:aCols[nCntFor, Len(oGNI:aCols[nCntFor])]
  	     RecLock("GNI", !lAchou)
  	      HS_GrvCpo("GNI", oGNI:aCols, oGNI:aHeader, nCntFor)
  	      GNI->GNI_FILIAL := xFilial("GNI")
  	      GNI->GNI_CODPER := M->GCH_CODPER
  	     MsUnlock()
  	    EndIf 
  	   EndIf
 	   EndIf
    EndIf 
   Next
  EndIf
 End Transaction 
Return(lGraOk)

// Função para validação
Function HS_VldA86()
 Local lRet := .F., cChrInv := ""
 
 If ReadVar() == "M->GCH_CODPER"
  If     !(lRet := !HS_SeekRet("GCH", "M->GCH_CODPER", 1, .F.,,,,, .T.))
   HS_MsgInf("A pergunta " + M->GCH_CODPER + " ja existe no cadastro", STR0008, "Validação do código da pergunta") //"Atenção"
                                               
  ElseIf !(lRet := !HS_TEspaco(M->GCH_CODPER))
   HS_MsgInf("Não é permitido incluir espaço no inicio ou entre os caracteres que compõem o código da pergunta", STR0008, "Validação do código da pergunta") //"Atenção"
  
  ElseIf !(lRet := !HS_TChrInv(M->GCH_CODPER, @cChrInv))
   HS_MsgInf("Os caracteres [" + cChrInv + "] não são permitidos na composição do código da pergunta", STR0008, "Validação do código da pergunta") //"Atenção"
   
  EndIf
 ElseIf ReadVar() == "M->GNI_CODRES"
  If !(lRet := HS_SeekRet("GCQ", "M->GNI_CODRES", 2, .F., "oGNI:aCols[oGNI:nAt, nGNIDESMNE]", "GCQ_DESMNE"))
   HS_MsgInf(STR0011, STR0008, STR0012) //"Mnemônico não encontrado."###"Atenção"###"Validação de Mnemônico"
  else
			//oGNI:aCols[oGNI:nAt, nGNIDESMNE] :=  GCQ->GCQ_DESMNE  
  EndIf 
 EndIf
 
Return(lRet)

Function HS_TEspaco(cChr)
Return(At(" ", RTrim(cChr)) > 0)

Function HS_TChrInv(cChr, cChrInv)
 Local nChr := 0
  
 cChr := Upper(RTrim(cChr))
 
 For nChr := 1 To Len(cChr)
  If     !( (Asc(SubStr(cChr, nChr, 1)) >=  48).And.(Asc(SubStr(cChr, nChr, 1)) <= 57) ) ;
   .And. !( (Asc(SubStr(cChr, nChr, 1)) >= 65) .And.(Asc(SubStr(cChr, nChr, 1)) <= 90) )
   cChrInv += IIf(!Empty(cChrInv), ", ", "") + SubStr(cChr, nChr, 1)
  EndIf
 Next  
 
Return(!Empty(cChrInv))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 06/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{ OemToAnsi(STR0001),	"AxPesqui"  ,	0, 1, 0, nil},;	 //"Pesquisar"
					 { OemToAnsi(STR0002),	"HS_A86Roti",	0, 2, 0, nil},; //"Visualizar"
					 { OemToAnsi(STR0003),	"HS_A86Roti",	0, 3, 0, nil},; //"Incluir"
					 { OemToAnsi(STR0004),	"HS_A86Roti",	0, 4, 0, nil},; //"Alterar"
					 { OemToAnsi(STR0005),	"HS_A86Roti",	0, 5, 0, nil} } //"Excluir"
Return(aRotina)
