#INCLUDE "VEIVA570.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ VEIVA570   ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Cadastro de Figuras para Visualizacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ VEIVA570()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ Nao tem                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±  ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.  ±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programador ³    BOPS    ³    BOPS     ³                 Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Farinelli    ³            ³             ³Complementacao da funcionalidade            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA570()

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Lay-Out de Imagens"

mBrowse( 06, 01, 22, 75, "VVU" )

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ INCIMG     ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Inclusao de Imagens                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ INCIMG( cAlias, nReg, nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cAlias : Alias do Arquivo                                             ³±±
±±³             ³ nReg   : Numero do Registro                                           ³±±
±±³             ³ nOpc   : Numero da opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function INCIMG( cAlias, nReg, nOpc )
Local cCodigo

cCodigo := GetSX8Num("VVU","VVU_CODIGO")
If EditImg(cCodigo)
   ConfirmSX8()
Else
   RollBackSx8()
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ ALTIMG     ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Alteracao de lay-out de imagens                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ INCIMG( cAlias, nReg, nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cAlias : Alias do Arquivo                                             ³±±
±±³             ³ nReg   : Numero do Registro                                           ³±±
±±³             ³ nOpc   : Numero da opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ALTIMG( cAlias, nReg, nOpc )
Local cCodigo

cCodigo := VVU->VVU_CODIGO
EditImg(cCodigo)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ EditImg    ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Editor do lay-out de imagens                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ EditImg( cCodigo )                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cCodigo: Codigo da imagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EditImg( cCodigo)
Local oDlg,oGet
Local aPartes := {}
Local nMovva570 := 5
Local lGrava := .F.
Local cNome
Local cArquivo
Local oWindow
Local nOpcao := 0
Local nI,nCont
Local cDesva570
Local oCima,oBaixo,oEsq,oDir
Private cBmpAtu := "OFIG001"

aPartes := Carrega(cCodigo,@cDesva570)

DEFINE MSDIALOG oDlg FROM 55,80 TO 490,790 TITLE STR0007 PIXEL //"Edicao do Lay-Out de Imagens"

For nI := 1 to Len(aPartes)
   cNome := aPartes[nI,1]
   cArquivo := Trim(aPartes[nI,9])
   &cNome := TBtnAutFmt():New(10,20 , "", oDlg,,,,,,Trim(aPartes[nI,4]),,,,cArquivo)
   &cNome:nTop := aPartes[nI,2]
   &cNome:nLeft:= aPartes[nI,3]
   &cNome:CREADVAR  := cNome
   &cNome:BRCLICKED := {|x|CadProp(@oDlg,@x,@aPartes,@OFIG001)}   // passar como parametro o Objeto da figura principal para localizar
   &cNome:BLCLICKED := {|x| TrataClick(x)  }
Next

oDlg:BRCLICKED := {||(cNome := AchaNome(aPartes),;
                       cArquivo := ProcDsk(),;
                       If(cArquivo#NIL,&cNome := TBtnAutFmt():New( 25, 20, "", oDlg,{|x| TrataClick(x)  } ,,,,,cArquivo,,,,cArquivo),.T.),;
                       If(cArquivo#NIL,&cNome:CREADVAR := cNome,.T.),;
                       If(cArquivo#NIL,AADD(aPartes,{cNome,&cNome:nTop,&cNome:nLeft,cNome,"","","","",cArquivo,"","",.F.}),.T.),;
                       If(cArquivo#NIL,&cNome:BRCLICKED := {|x|CadProp(@oDlg,@x,@aPartes,@OFIG001)},.T.),;
                       If(cArquivo#NIL,TrataClick(&cNome),.T.),;
                       If(cArquivo#NIL,AtuCord(&cNome,cNome,@aPartes),.T.),;
                       .T.)}
//                       If(Upper(cBmpAtu)#"OFIG001",OFIG001:DockOnBmp(&cBmpAtu),.T.),;

nLinSobe := -40

@ 210+nLinSobe,0 to 270+nLinSobe,oDlg:NRIGHT of oDlg Pixel
@ 230+nLinSobe,010 Say STR0008  Pixel //"Descricao "
@ 230+nLinSobe,040 MsGet oGet Var cDesva570 Picture "@!" SIZE 115,10 of oDlg Pixel

@ 230+nLinSobe,187 MsGet oGet Var nMovva570 Picture "999" SIZE 015,10 of oDlg Pixel

@ 220+nLinSobe,190 BUTTON "*"         SIZE 10,10 PIXEL OF oDlg ACTION (MoveFig(&cBmpAtu,"C",nMovva570),AtuCord(&cBmpAtu,cBmpAtu,@aPartes))  // para cima
@ 230+nLinSobe,170 BUTTON "*"         SIZE 10,10 PIXEL OF oDlg ACTION (MoveFig(&cBmpAtu,"E",nMovva570),AtuCord(&cBmpAtu,cBmpAtu,@aPartes))	// para esquerda
@ 230+nLinSobe,212 BUTTON "*"         SIZE 10,10 PIXEL OF oDlg ACTION (MoveFig(&cBmpAtu,"D",nMovva570),AtuCord(&cBmpAtu,cBmpAtu,@aPartes))	// para direita
@ 242+nLinSobe,190 BUTTON "*"         SIZE 10,10 PIXEL OF oDlg ACTION (MoveFig(&cBmpAtu,"B",nMovva570),AtuCord(&cBmpAtu,cBmpAtu,@aPartes))	// para baixo
@ 230+nLinSobe,235 BUTTON STR0009 SIZE 38,11 PIXEL ACTION (If(Upper(cBmpAtu)#"OFIG001",OFIG001:DockOnBmp(&cBmpAtu),.T.)) //"Posiciona"

//ACTIVATE MSDIALOG oDlg CENTER 
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||oDlg:End()}))

lGrava := .F.

If nOpcao==1 .and. Len(aPartes) > 0 .and. !Empty(cDesva570)
	 lGrava := .T.
   VVU->(DbSetOrder(1))
   VVU->(DbSeek(xFilial("VVU")+cCodigo))
   If VVU->(Eof())
      RecLock("VVU",.T.)
   Else
      RecLock("VVU",.F.)
   EndIf   
   VVU->VVU_FILIAL := xFilial("VVU")
   VVU->VVU_CODIGO := cCodigo
   VVU->VVU_DESC   := cDesva570

   VVV->(DbSetOrder(1))
   VVV->(DbSeek(xFilial("VVV")+cCodigo))
   While xFilial("VVV") == VVV->VVV_FILIAL .and. cCodigo == VVV->VVV_CODIGO .and. !(VVV->(Eof()))
      RecLock("VVV",.F.)
      VVV->(DbDelete())
      VVV->(MsUnlock())
      VVV->(DbSkip())
   EndDo

   nCont := 1
   For nI := 1 to Len(aPartes)
      If aPartes[nI,12]
         Loop
      EndIf
      RecLock("VVV",.T.)
      VVV->VVV_FILIAL := xFilial("VVV")
      VVV->VVV_CODIGO := cCodigo
      VVV->VVV_ORDEM  := StrZero(nCont,3)
      VVV->VVV_FILHO  := aPartes[nI,07]
      VVV->VVV_DESFIL := aPartes[nI,08]
      VVV->VVV_DESC   := aPartes[nI,04]
      VVV->VVV_FIG1   := aPartes[nI,09]
      VVV->VVV_FIG2   := aPartes[nI,10]
      VVV->VVV_CODGRU := aPartes[nI,11]
      VVV->VVV_NTOP   := aPartes[nI,02]
      VVV->VVV_NLEFT  := aPartes[nI,03]
      nCont++
   Next
EndIf
Return lGrava




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ VIZIMG     ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Chama visualizador do lay-out de imagens                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ VIZIMG( cAlias, nReg, nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cAlias : Alias do Arquivo                                             ³±±
±±³             ³ nReg   : Numero do Registro                                           ³±±
±±³             ³ nOpc   : Numero da opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VIZIMG( cAlias, nReg, nOpc )
Local cCodigo

cCodigo := VVU->VVU_CODIGO

MostraImg(cCodigo,.T.,STR0010)   // manda .T. para permitir a visualizacao dos filhos //"Visualiza Lay-Out de imagens"

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ EXCIMG     ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Exclui lay-out de imagens                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ EXCIMG( cAlias, nReg, nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cAlias : Alias do Arquivo                                             ³±±
±±³             ³ nReg   : Numero do Registro                                           ³±±
±±³             ³ nOpc   : Numero da opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EXCIMG( cAlias, nReg, nOpc )
Local cCodigo

cCodigo := VVU->VVU_CODIGO

nOpcao := MostraImg(cCodigo,.F.,STR0011)   // manda .F. para nao permitir a visualizacao dos filhos //"Exclusao do Lay-Out de imagens"
If nOpcao == 1   // se tiver selecionado OK para exclusao
   VVU->(DbSetOrder(1))
   VVU->(DbSeek(xFilial("VVU")+VVU->VVU_CODIGO))
   RecLock("VVU",.F.)
   VVU->(DbDelete())
   VVU->(MsUnlock())

   VVV->(DbSetOrder(1))
   VVV->(DbSeek(xFilial("VVV")+VVU->VVU_CODIGO))
   While VVV->VVV_FILIAL == xFilial("VVV") .and. VVV->VVV_CODIGO == VVU->VVU_CODIGO .and. ! (VVV->(Eof()))
      RecLock("VVV",.F.)
      VVV->(DbDelete())
      VVV->(MsUnlock())
      VVV->(DbSkip())
   EndDo
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao	    ³ MostraImg  ³ Autor ³ Eduardo Motta                ³ Data ³ 06/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Vizualizador do lay-out de imagens                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe	    ³ MostraImg( cCodigo )                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ cCodigo: Codigo do lay-out                                            ³±±
±±³             ³ lFilho : Permite ou nao visualizar os filhos                          ³±±
±±³             ³ cTitViz: Titulo do Programa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    	³ Generico                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Nao tem															     															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MostraImg( cCodigo,lFilho,cTitViz,bLClick)
Local oGet1,oGet2,oGet3,oGet4
Local aPartes := {}
Local nMovva570 := 5
Local cNome
Local cArquivo
Local oDlg
Local nI,nCont
Local cDesva570
Local oCima,oBaixo,oEsq,oDir
Local nOpcao := 0

aPartes := Carrega(cCodigo,@cDesva570)

DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 TITLE cTitViz PIXEL

For nI := 1 to Len(aPartes)
   cNome := aPartes[nI,1]
   cArquivo := Trim(aPartes[nI,9])
   &cNome := TBtnAutFmt():New(10,20 , "", oDlg,,,,,,Trim(aPartes[nI,4]),,,,cArquivo)
   &cNome:nTop := aPartes[nI,2]
   &cNome:nLeft:= aPartes[nI,3]
   &cNome:CREADVAR  := cNome
   If bLClick == Nil
      If lFilho
         &cNome:BLCLICKED := {|x| MostraFilho(x,aPartes,cTitViz)  }
      EndIf   
   Else
      &cNome:BLCLICKED := bLClick   // {|x| MostraFilho(x,aPartes,cTitViz)  }
   EndIf
Next

@ 210,oDlg:NLEFT to 270,oDlg:NRIGHT of oDlg Pixel
@ 230,010 Say STR0008  Pixel //"Descricao "
@ 230,040 MsGet oGet Var cDesva570 Picture "@!" SIZE 115,10 of oDlg Pixel When .F.
// soh para dar foco em alguma coisa
@ 5000,5000 BUTTON ""  SIZE 38,14 PIXEL ACTION .T.

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpcao:=1 ,oDlg:End()},{||nOpcao:=2,oDlg:End()})
Return nOpcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MostraFilho  ³ Autor ³  Eduardo Motta     ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia de um filho na figura, se tiver      ³±±
±±³          ³ vizualiza o Filho                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oBmp   : Objeto BMP                                        ³±±
±±³          ³ aPartes: Array com os dados das partes do veiculo          ³±±
±±³          ³ cTitViz: Titulo do Programa                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  - (Veiculos)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MostraFilho(oBmp,aPartes,cTitViz)
Local nLoc := AScan(aPartes,{|x| Trim(x[1]) == Trim(oBmp:CREADVAR)})
If nLoc > 0
   If cTitViz == Nil
      cTitViz := Trim(aPartes[nLoc,4])
   EndIf
   If !Empty(aPartes[nLoc,7])
      MostraImg(aPartes[nLoc,7],.T.,cTitViz)
   EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PROCDSK  ³ Autor ³  Eduardo Motta        ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para procurar a figura no disco.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  - (Veiculos)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProcDsk()
Local cMask := OemToAnsi(STR0012)+"(*.BMP) |*.bmp|"+OemToAnsi(STR0013 )+"(*.*)|*.*|" //"Arquivos Bitmap"###"Todos os Arquivos"
Local cArquivo
cArquivo := cGetFile(cMask,OemToAnsi(STR0014)) //"Selecione arquivo..."
If Empty(cArquivo)
   cArquivo := SubStr(cArquivo,Rat("\",cArquivo))
EndIf
Return cArquivo


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MoveFig 	³ Autor ³ Eduardo Motta  	    ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para movimentar a figura.    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MoveFig(oBmp,cTipo,nMov,aPartes)                        	  ³±±
±±³          ³ oBmp    - Nome do objeto BMP                           	  ³±±
±±³          ³ cTipo   - Tipo do movimento (cima,baixo,esquerda,direita)  ³±±
±±³          ³ nMov    - Numero de pixels a movimentar                    ³±±
±±³          ³ aPartes - Array contendo as figuras e as coordenadas.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 	 ³ Veiculos												      											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MoveFig(oBmp,cTipo,nMov)
If cTipo == "C"
   oBmp:NTOP := oBmp:NTOP - nMov
   If oBmp:NTOP < 25
      oBmp:NTOP := 25
   EndIf
ElseIf cTipo == "B"
   oBmp:NTOP := oBmp:NTOP + nMov
ElseIf cTipo == "E"
   oBmp:NLEFT := oBmp:NLEFT - nMov
   If oBmp:NLEFT < 0
      oBmp:NLEFT := 0
   EndIf
ElseIf cTipo == "D"
   oBmp:NLEFT := oBmp:NLEFT + nMov
EndIf
oBmp:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³ AchaNome	³ Autor ³ Eduardo Motta  	        ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa achar o proximo nome do objeto da parte do veiculo  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AchaNome(aPartes)                                       	    ³±±
±±³          ³ aPartes - Array contendo o nome de todos os objetos que	    ³±±
±±³          ³           sao partes do veiculo, deve ser passado com o      ³±±
±±³          ³           @ na frente na chamada da funcao AchaNome(@aPartes)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 	 ³ Veiculos												        											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AchaNome(aPartes)
Local nTam  := Len(aPartes) 
Local cNome := "OFIG"+StrZero(nTam+1,3)
Return cNome

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³TrataClick³ Autor ³ Eduardo Motta  	        ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa selecionar a figura que foi clicada.                |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TrataClick(oBmp)                                        	    ³±±
±±³          ³ oBmp - Objeto BMP que foi clicado, pode ser a figura do      ³±±
±±³          ³        veiculo inteiro ou uma parte dele.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ Veiculos												         											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TrataClick(oBmp)
cBmpAtu := oBmp:CREADVAR
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtuCord   ³ Autor ³ Eduardo Motta  	      ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza coordenada da figura.                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtuCord(oBmp,cNome,aPartes)                             	    ³±±
±±³          ³ oBmp    - Objeto BMP que foi clicado, pode ser a figura do   ³±±
±±³          ³           veiculo inteiro ou uma parte dele.                 ³±±
±±³          ³ cNome   - Nome do objeto BMP                                 ³±±
±±³          ³ aPartes - Array com os dados dos BMPs                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ Veiculos												         											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuCord(oBmp,cNome,aPartes)
Local nLoc := AScan(aPartes,{|x|x[1]==cNome})
If nLoc > 0
   aPartes[nLoc,2] := oBmp:NTOP
   aPartes[nLoc,3] := oBmp:NLEFT
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CadProp   ³ Autor ³ Eduardo Motta  	      ³ Data ³ 03/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastra proprietades da imagem                              |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CadProp(oDlg,oBmp,aPartes)                             	    ³±±
±±³          ³ oDlg    - Objeto do dialogo que se encontra o BMP            ³±±
±±³          ³ oBmp    - Objeto BMP que foi clicado, pode ser a figura do   ³±±
±±³          ³           veiculo inteiro ou uma parte dele.                 ³±±
±±³          ³ aPartes - Array com os dados dos BMPs                        ³±±
±±³          ³ oBmpPrin- Objeto BMP principal para localizar a parte do     ³±±
±±³          ³           veiculo nesta figura.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ Veiculos												         											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CadProp(oDlg,oBmp,aPartes,oBmpPrin)
Local nLin := oBmp:NTOP
Local nCol := oBmp:NLEFT
Local nOpca
Local nLoc := AScan(aPartes,{|x|x[1]==oBmp:CREADVAR})
Local cDesva570  := aPartes[nLoc,4]
Local cLClick  := aPartes[nLoc,5]
Local cRClick  := aPartes[nLoc,6]
Local cDFva570  := aPartes[nLoc,8]
Local cFig2    := aPartes[nLoc,10]
Local cDGva570 := ""
Local oProp
Local oGet
Local oProcDsk
Local OFIG2
Private cFilva570   := aPartes[nLoc,7]
Private cCGva570  := aPartes[nLoc,11]

If (aPartes[nLoc,12])
   Return .T.
EndIf

If Empty(cDesva570)
   cDesva570 := Space(30)
EndIf
If Empty(cLClick)
   cLClick := Space(30)
EndIf
If Empty(cRClick)
   cRClick := Space(30)
EndIf
If Empty(cFilva570)
   cFilva570 := Space(6)
EndIf
If Empty(cDFva570)
   cDFva570 := Space(30)
EndIf
If Empty(cCGva570)
   cCGva570 := Space(06)
EndIf
If Empty(cFig2)
   cFig2 := Space(255)
EndIf

cDesva570  := cDesva570  + Space(30-Len(cDesva570))
cLClick  := cLClick  + Space(30-Len(cLClick))
cRClick  := cRClick  + Space(30-Len(cRClick))
cFilva570   := cFilva570   + Space(06-Len(cFilva570))
cDFva570  := cDFva570  + Space(30-Len(cDFva570))
cCGva570  := cCGva570  + Space(06-Len(cCGva570))
cFig2    := cFig2    + Space(255-Len(cFig2))

DEFINE MSDIALOG oProp FROM nLin,nCol TO nLin+250,nCol+400 TITLE STR0015+Trim(cDesva570) PIXEL //"Propriedades do Item "

@ 10,10 Say STR0016 PIXEL //"Nome da Figura"
@ 10,55 MsGet oGet Var cDesva570  Picture "@!" SIZE 098,10 of oProp PIXEL

If nLoc > 1   // a figura principal nao pode ter filho
   @ 25,10 Say STR0017 PIXEL //"Grupo         "
   @ 25,55 MsGet oGet1 Var cCGva570  Picture "@!" F3 "VA0" Valid (Vazio() .or. ExistCpo("VA0",cCGva570)) SIZE 015,10 of oProp PIXEL
   @ 25,95 MsGet oGet2 Var cDGva570  SIZE 75,10 When (Posicione("VA0",1,xFilial("VA0")+cCGva570,""),cDGva570 := VA0->VA0_DESCRI,oGet2:REFRESH(),.F.) PIXEL
   @ 45,10 Say STR0018 PIXEL //"Sub-Item      "
   @ 45,55 MsGet oGet3 Var cFilva570  Picture "@!" F3 "VVU" Valid (Vazio() .or. ExistCpo("VVU",cFilva570)) SIZE 015,10 of oProp PIXEL
   @ 65,10 Say STR0019 PIXEL //"Descricao     "
   @ 65,55 MsGet oGet4 Var cDFva570  Picture "@!"  When (Posicione("VVU",1,xFilial("VVU")+cFilva570,""),cDFva570 := VVU->VVU_DESC,oGet4:REFRESH(),.F.) SIZE 098,10 of oProp PIXEL

   DEFINE SBUTTON FROM 045,085 TYPE 15 ACTION (VisFig(cFilva570))  ENABLE OF oProp WHEN !Empty(cFilva570)

EndIf

DEFINE SBUTTON FROM 110,070 TYPE 1 ACTION (nOpca := 1,oProp:End())  ENABLE OF oProp
DEFINE SBUTTON FROM 110,105 TYPE 2 ACTION (nOpca := 0,oProp:End())  ENABLE OF oProp

If nLoc > 1   // a figura principal nao pode apagar
   @ 110,140 BUTTON STR0020     SIZE 38,14 PIXEL ACTION (nOpca := -1,oProp:End()) //"Apaga"
EndIf
ACTIVATE MSDIALOG oProp CENTERED
If nOpca == 1 
   aPartes[nLoc,02]	 := oBmp:NTOP
   aPartes[nLoc,03]	 := oBmp:NLEFT
   aPartes[nLoc,04]	 := cDesva570
   aPartes[nLoc,05]	 := ""   // lClick
   aPartes[nLoc,06]	 := ""   // rClick
   aPartes[nLoc,07]	 := cFilva570
   aPartes[nLoc,08]	 := cDFva570
   aPartes[nLoc,11]	 := cCGva570
   oBmp:CTOOLTIP	:= Trim(cDesva570)
ElseIf nOpca == -1
   aPartes[nLoc,12] := .T.
   oBmp:LVISIBLE := .F.
   oBmp:LACTIVE  := .F.
   oBmp:SetBitmap("\branco.bmp")
   oBmp:NTOP   := 0
   oBmp:NLEFT  := 0
EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARREGA   ºAutor  ³Ricardo Farinelli   º Data ³  11/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as partes que formam a figura informada das quais   º±±
±±º          ³compoem as sub-figuras da principal                         º±±
±±ºParametros³cCodigo - codigo da figura a ser carregada                  º±±
±±º          ³cDesva570  - nao passar mais                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Carrega(cCodigo,cDesva570)
Local aPartes := {}
VVU->(DbSetOrder(1))
VVU->(DbSeek(xFilial("VVU")+cCodigo))
cDesva570 := VVU->VVU_DESC

/*
aPartes[x,01] := Nome do Objeto
aPartes[x,02] := NTOP
aPartes[x,03] := NLEFT
aPartes[x,04] := Descricao (Hint)
aPartes[x,05] := (cod block LCLICK)
aPartes[x,06] := (cod block RCLICK)
aPartes[x,07] := Filho
aPartes[x,08] := Descricao do Filho
aPartes[x,09] := Caminho da Figura 1
aPartes[x,10] := Caminho da Figura 2
aPartes[x,11] := Grupo Generico
aPartes[x,12] := Deletato (.T. / .F.)

*/

VVV->(DbSetOrder(1))
VVV->(DbSeek(xFilial("VVV")+cCodigo))
While VVV->VVV_FILIAL == xFilial("VVV") .and. VVV->VVV_CODIGO == cCodigo .and. ! (VVV->(Eof()))
   AADD(aPartes,{"OFIG"+VVV->VVV_ORDEM,VVV->VVV_NTOP,VVV->VVV_NLEFT,VVV->VVV_DESC,"","",VVV->VVV_FILHO,VVV->VVV_DESFIL,VVV->VVV_FIG1,VVV->VVV_FIG2,VVV->VVV_CODGRU,.F.})
   VVV->(DbSkip())
EndDo

Return aPartes


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VISFIG    ºAutor  ³Ricardo Farinelli   º Data ³  11/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza as figuras                                        º±±
±±ºParametros³cNFig - numero da figura principal a ser mostrada           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VisFig(cNFig)
Local OFIG,oDlgFig

VVV->(Dbseek(xFilial("VVV")+cNFig))

DEFINE MSDIALOG oDlgFig FROM 0,0 TO 500,500 TITLE Trim(VVV->VVV_DESC) PIXEL

OFIG := TBtnAutFmt():New(0,0 , "", oDlgFig,,,,,,Trim(VVV->VVV_DESC),,,,Trim(VVV->VVV_FIG1))
OFIG:lVISIBLE := .T.
OFIG:Show()
OFIG:Refresh()

ACTIVATE MSDIALOG oDlgFig CENTERED
//oFig:nClientHeight+5,oFig:nClientWidth+5

Return .T.

Static Function MenuDef()
Local aRotina := {	{ OemToAnsi( STR0001 )  ,"AxPesqui", 0, 1 },;  //"Pesquisar"
						{ OemToAnsi( STR0002 ) ,"VizImg", 0, 2 },; //"Visualizar"
						{ OemToAnsi( STR0003 )    ,"IncImg", 0, 3 },; //"Incluir"
						{ OemToAnsi( STR0004 )    ,"AltImg", 0, 4 },; //"Alterar"
						{ OemToAnsi( STR0005 )    ,"ExcImg", 0, 5 } }  //"Excluir"
Return aRotina
