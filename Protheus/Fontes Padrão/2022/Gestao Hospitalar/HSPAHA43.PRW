#INCLUDE "HSPAHA43.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA43  º Autor ³ Daniel Peixoto     º Data ³  01/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ REGRAS DE MOVIMENTACAO DE LEITOS                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA43()  
 
 Private cCadastro :=  STR0001 //"Cadastro de Regras de Movimentacao de Leitos"
 Private aRotina   := MenuDef()


 DBSelectArea("GFL")
 DBSetOrder(1)
 mBrowse(06, 01, 22, 75, "GFL")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA43  º Autor ³ Daniel Peixoto     º Data ³ 01/12/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Regras de Modificacao de Leito                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MntA43(cAliasA43, nRegA43, nOpcA43)
 Local nGDOpc := IIf(StrZero(aRotina[nOpcA43, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 
 Private aTela := {}, aGets := {}, aSTela := {{},{}}, aSGets := {{},{}}
 Private aHGFM := {}, aCGFM := {}, nUGFM := 0, nLGFM := 0, oGFM
 Private nGFM_IteQua := 0, nGFE_Quarto := 0     
 Private cGcsCodLoc := ""
       
 RegToMemory("GFL", aRotina[nOpcA43, 4] == 3)

 HS_BDados("GFM", @aHGFM, @aCGFM, @nUGFM, 1, "", IIf(aRotina[nOpcA43, 4] # 3, "GFM->GFM_CODREG == '" + M->GFL_CODREG + "'", Nil))
 nGFM_IteQua := aScan(aHGFM, {| aVet | aVet[2] == "GFM_ITEQUA"})
 nGFM_CodLoc := aScan(aHGFM, {| aVet | aVet[2] == "GFM_CODLOC"})
 nGFM_Quarto := aScan(aHGFM, {| aVet | aVet[2] == "GFM_QUARTO"}) 
 
 If StrZero(aRotina[nOpcA43, 4], 2) $ "03/04"
  If EMPTY(aCGFM[1, nGFM_IteQua])
   aCGFM[1, nGFM_IteQua] := Soma1(aCGFM[1, nGFM_IteQua], Len(aCGFM[1, nGFM_IteQua]))
  EndIf 
 EndIf      
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 080, .T., .T.,.T. } )	
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )      
 
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )
 
 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oGFL := MsMGet():New("GFL", nRegA43, nOpcA43,,,,, aPObjs[1],, 2,,,, oDlg)
  oGFL:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts "&1-Quartos"
  oFolGDs:Align := CONTROL_ALIGN_BOTTOM
  
  oGFM := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,"+GFM_ITEQUA",,,,,,, oFolGDs:aDialogs[1], aHGFM, aCGFM)
  oGFM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                                     
   
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. oGFM:TudoOk(), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )
         
 If nOpca == 1
  Begin Transaction
   FS_GrvA43(nOpcA43)
   FS_GrvGFM()
  End Transaction 
  
  While __lSx8
   ConfirmSx8() 
  End
 Else
  While __lSx8
   RollBackSx8() 
  End
 EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_GrvA43 ³ Autor ³ Daniel Peixoto        ³ Data ³ 01/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ GRAVA REGRAS DA MOVIMENTACAO                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_GrvA43(nOpcA43)
 Local lAchou := .F.
 Local nForDel:= 0
 
 If aRotina[nOpcA43, 4] # 2 // nao for consulta
  DbSelectArea("GFL")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("GFL") + M->GFL_CODREG)
  If Inclui .Or. Altera
   RecLock("GFL", If(lAchou, .F., .T.))
    HS_GRVCPO("GFL")
    GFL->GFL_FILIAL := xFilial("GFL")
		 MsUnLock() 
  Else  // exclusao
   If !( Len(oGFM:aCols) == 1 .And. Empty(oGFM:aCols[1,nGFM_ITEQUA]) ) //marca como deletado os itens
    For nForDel := 1 To Len(oGFM:aCols)
     oGFM:aCols[nForDel, Len(oGFM:aCols[nForDel])] := .T.
    Next
   Endif 
   RecLock("GFL", .F., .T.)
    dbdelete()
   MsUnlock()
   WriteSx2("GFL")
  EndIf 
 EndIf  
  
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_GrvGFM ³ Autor ³ Daniel Peixoto        ³ Data ³ 01/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ GRAVA ARQUIVO DE REGRAS POR QUARTOS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvGFM()
 Local nItem 				:= 0
 Local cAliasOld := Alias()
 Local lAchou    := .F.
 
 For nItem := 1 To Len(oGFM:aCols)
  
  DbSelectArea("GFM")
  DbSetOrder(1) //GFM/1
  lAchou := IIf(!Empty(oGFM:aCols[nItem, nGFM_IteQua]), DbSeek(xFilial("GFM") + M->GFL_CODREG + oGFM:aCols[nItem, nGFM_IteQua]), .F.)
  If oGFM:aCols[nItem, Len(oGFM:aCols[nItem])] .And. lAchou /* exclusao */
   RecLock("GFM", .F., .T.)
    DbDelete()
    MsUnlock()
   WriteSx2("GFM")
  Else   
   If !EMPTY(oGFM:aCols[nItem, nGFM_Quarto]) .And. !EMPTY(oGFM:aCols[nItem,nGFM_CodLoc])
    RecLock("GFM", !lAchou)
     HS_GRVCPO("GFM", oGFM:aCols, oGFM:aHeader, nItem)
     GFM->GFM_FILIAL := xFilial("GFM")
     GFM->GFM_CODREG := M->GFL_CODREG
    MsUnlock()
   EndIf 
  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return(Nil)         

Function HS_VldA43()
 Local lRet := .T., cAliasOld := Alias(), nPos := 0

 If ReadVar() == "M->GFL_TPORIG" .OR. ReadVar() == "M->GFL_TPDEST"
  DbSelectArea("GFL")
  DbSetOrder(1)
  DbGoTop()
  While !EOF() .And. lRet
   If GFL->GFL_TPORIG == M->GFL_TPORIG .AND. GFL->GFL_TPDEST == M->GFL_TPDEST
    HS_MsgInf(STR0007, STR0008, STR0001) //"Regra ja cadastrada"###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
    lRet := .F.
   EndIf
   DbSkip() 
  EndDo
 Endif
 
 If lRet .and. M->GFL_TPORIG == M->GFL_TPDEST
  HS_MsgInf(STR0009, STR0008, STR0001) //"Tipo Origem igual Tipo Destino"###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
  lRet := .F.
 
 ElseIf ReadVar() == "M->GFM_CODLOC" 
  nPos := aScan(oGFM:aCols, {|aVet| aVet[nGFM_CodLoc] == M->GFM_CODLOC .And. aVet[nGFM_Quarto] == oGFM:aCols[oGFM:nAt,nGFM_Quarto]} ) 
  If nPos <> 0 .And. nPos <> oGFM:nAt .And. !oGFM:aCols[nPos,Len(oGFM:aCols[nPos])] //achou nessa regra e nao esta deletado
   lRet := .F.
   HS_MsgInf(STR0010, STR0008, STR0001) //"Relacao Setor/Quarto ja cadastrada nessa regra"###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
  ElseIf !EMPTY(oGFM:aCols[oGFM:nAt,nGFM_Quarto]) 
   lRet := FS_TipoDis(M->GFL_TPORIG, M->GFL_TPDEST, M->GFM_CODLOC, oGFM:aCols[oGFM:nAt,nGFM_Quarto])
   If lRet
    lRet := FS_TipoPad(M->GFM_CODLOC, oGFM:aCols[oGFM:nAt,nGFM_Quarto]) 
   EndIf 
  EndIf 
  If lRet 
   cGcsCodLoc := M->GFM_CODLOC  
  EndIf
  
 ElseIf ReadVar() == "M->GFM_QUARTO" 
  nPos := aScan(oGFM:aCols, {|aVet| aVet[nGFM_CodLoc] == oGFM:aCols[oGFM:nAt,nGFM_CodLoc] .And. aVet[nGFM_Quarto] == M->GFM_QUARTO }) 
  If nPos <> 0 .And. nPos <> oGFM:nAt .And. !oGFM:aCols[nPos,Len(oGFM:aCols[nPos])] //achou nessa regra e nao esta deletado
   lRet := .F.
   HS_MsgInf(STR0010, STR0008, STR0001) //"Relacao Setor/Quarto ja cadastrada nessa regra"###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
  ElseIf !Empty(oGFM:aCols[oGFM:nAt,nGFM_CodLoc])
   lRet := FS_TipoDis(M->GFL_TPORIG, M->GFL_TPDEST, oGFM:aCols[oGFM:nAt,nGFM_CodLoc], M->GFM_QUARTO)
   If lRet
    lRet := FS_TipoPad(oGFM:aCols[oGFM:nAt,nGFM_CodLoc], M->GFM_QUARTO)
   EndIf 
  EndIf
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(lRet)

Function HS_RetDesc(nTipo, cCpo)
Local lDesc := ""

If nTipo == 0
 If cCpo == "0"
  lDesc := STR0013 //"AMBULATORIO"
 Elseif cCpo == "1"
  lDesc := STR0014  //"ENFERMARIA"
 Elseif cCpo == "2"
  lDesc := STR0015 //"APARTAMENTO"
 Elseif cCpo == "3"
  lDesc := STR0016 //"SUITE"
 Elseif cCpo == "4"
  lDesc := STR0017  //"SALA CIRURGICA"
 Elseif cCpo == "5"
  lDesc := STR0018  //"UTI"
 Elseif cCpo == "6"
  lDesc := STR0019  //"UTI-NEO"
 Elseif cCpo == "7"
  lDesc := STR0020  //"SEMI-UTI"
 EndIf 
ElseIf nTipo == 1      
 If cCpo == "0"
  lDesc := STR0021 //"NAO"
 Elseif cCpo == "1"
  lDesc := STR0022  //"SIM"
 EndIf 
EndIf

Return(lDesc)

/**************************************************************************************************************/
//Verifica se o quarto tem leito do tipo de Origem ou Destino da regra 
Static Function FS_TipoDis(cModOrig, cModDest, cSetor, cQuarto)
Local lret     := .F.
Local aAreaOld := GetArea()
Local cModelo    := ""  
Local nCont    := 0

DbSelectArea("GAV")
DbSetOrder(6) //GAV/6

For nCont:= 1 to 2
 cModelo := IIF(nCont == 1, cModOrig, cModDest) 
 If !(lRet := DbSeek(xFilial("GAV") + cSetor + cQuarto + cModelo))
  HS_MsgInf(STR0011+HS_RetDesc(0, cModelo), STR0008, STR0001) //"Quarto nao possui leito do tipo "###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
  Return(lret)
 Endif 
Next

RestArea(aAreaOld)               
Return(lRet)

/**************************************************************************************************************/
//Verifica se o quarto tem como padrao o tipo de Origem da regra 
Static Function FS_TipoPad(cSetor, cQuarto) 
Local lRet := .T.
Local aAreaOld := GetArea()

DbSelectArea("GFM")
DbSetOrder(2)

If DbSeek(xFilial("GFM") + cSetor + cQuarto)
 DbSelectArea("GFL")
 DbSetOrder(1)
 DbSeek(xFilial("GFL") + GFM->GFM_CODREG)
  If GFL->GFL_TPORIG <> M->GFL_TPORIG 
   HS_MsgInf(STR0012+HS_RetDesc(0, GFL->GFL_TPORIG), STR0008, STR0001) //"Tipo de origem invalido, o padrao e "###"Atencao"###"Cadastro de Regras de Movimentacao de Leitos"
   lRet := .F.
  EndIf
EndIf 

RestArea(aAreaOld)               
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 11/07/07 ³±±
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},;  //"Pesquisar"
	                 {OemToAnsi(STR0003), "HS_MntA43", 0, 2, 0, nil},;  //"Visualizar"
                	 {OemToAnsi(STR0004), "HS_MntA43", 0, 3, 0, nil},;  //"Incluir"
		             {OemToAnsi(STR0005), "HS_MntA43", 0, 4, 0, nil},;  //"Alterar"
		             {OemToAnsi(STR0006), "HS_MntA43", 0, 5, 0, nil}}   //"Excluir" 
Return(aRotina)