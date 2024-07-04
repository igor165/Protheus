#INCLUDE "ofior120.ch"
#Include "protheus.ch"
#Include "FileIO.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOR120 ³ Autor ³  Andre                ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia da Nota Fiscal de Venda Balcao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR120

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0004) // //"Orcamentos"
Private lA1_IBGE  := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)

cIndVS1 := CriaTrab(Nil, .F.)
cChave  := "VS1_FILIAL+VS1_NUMORC"
cCond   := "!Empty(VS1->VS1_NUMNFI)"        //Orcamento Vendido

IndRegua("VS1",cIndVS1,cChave,,cCond,OemToAnsi(STR0005) ) // //"Orcamento"

mBrowse( 6, 1,22,75,"VS1")

DbSelectArea("VS1")
RetIndex()

#IFNDEF TOP
   If File(cIndVS1+OrdBagExt())
      fErase(cIndVS1+OrdBagExt())
   Endif
#ENDIF

Return


Function ImpNota()
***************

   Local bCampo   := { |nCPO| Field(nCPO) }
   Local aPages:= {}, aVar:={}
   Local nCntFor := 0
   Local _ni	 := 0

   Private aTELA[0][0], aGETS[0], aHeader[0]
   Private nTotDes := 0
   Private nTotOrc := 0
   Private nTotPec := 0
   Private nTotSrv := 0
   Private nP := 1
   Private oLbEntIte
   Private lPri := .t.
   Private aCabPV  := {}
   Private aItePV  := {}
   Private cCodVen
   Private lAbortPrint := .f.

   aRotina := { { " " ," " , 0, 1},;    //Pesquisar
                { " " ," " , 0, 2},;    //Visualizar
                { " " ," " , 0, 3},;    //Incluir
                { " " ," " , 0, 4},;   	//Alterar
                { " " ," " , 0, 5} }  	//Excluir

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Opcoes de acesso para a Modelo 3                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cTitulo        := STR0006 // //"Consulta Venda de Pecas"
   cAliasEnchoice := "VS1"
   cLinOk         := "AllwaysTrue()"
   cTudoOk        := "AllwaysTrue()"
   cFieldOk       := "FG_MEMVAR()"

   nOpc :=2
   nOpcE:=2
   nOpcG:=2

   nOpca:=0

   lRefresh := .t.
   Inclui   := .f.
   lVirtual := .f.
   nLinhas  := 99

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria variaveis M->????? da Enchoice                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //RegToMemory("VS1",.T.)
   
   DbSelectArea("VS1")
	For nCntFor := 1 TO FCount()
	    &( "M->"+FieldName(nCntFor) ) := FieldGet(nCntFor)
	Next
   
   aCpoEnchoice  :={}
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("VS1")
   While !Eof().and.(x3_arquivo=="VS1")
      
      If X3USO(x3_usado).and. cNivel>=x3_nivel .and.(x3_campo $ [VS1_CLIFAT#VS1_LOJA#VS1_NCLIFT#VS1_ENDCLI#VS1_CIDCLI#VS1_ESTCLI#VS1_NUMNFI#VS1_SERNFI])
         AADD(aCpoEnchoice,x3_campo)
      Endif
      
	   If x3_context == "V"
		   &("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf   
      
      dbSkip()
      
   End

   DbSelectArea("SA3")
   DbSetOrder(2)
   DbSeek(xFilial("SA3")+Substr(VS1->VS1_NOMVEN,7,15))
   cCodVen := SA3->A3_COD
   DbSelectArea("SA1")
   DbGotop()
   DbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
   M->VS1_NOMVEN := VS1->VS1_NOMVEN
   M->VS1_ENDCLI := SA1->A1_END
	If lA1_IBGE
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek(xFilial("VAM")+SA1->A1_IBGE)
   	M->VS1_CIDCLI := VAM->VAM_DESCID
	   M->VS1_ESTCLI := VAM->VAM_ESTADO
	Else
   	M->VS1_CIDCLI := SA1->A1_MUN
	   M->VS1_ESTCLI := SA1->A1_EST
	EndIf

   DbSelectArea("VS1")
   For nCntFor := 1 TO FCount()
       M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta o aCols Pecas                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nUsadoP:=0
   dbSelectArea("SX3")
   dbSeek("VS3")
   aHeaderP:={}
   While !Eof().And.(x3_arquivo=="VS3")
      If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
         nUsadoP++
         Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
         wVar := "M->"+x3_campo
         &wVar := CriaVar(x3_campo)
      Endif
      dbSkip()
   EndDo

   aColsP:={Array(nUsadoP+1)}
   aColsP[1,nUsadoP+1]:=.F.
   For _ni:=1 to nUsadoP
       aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
   Next

   aColsP := {}
   dbSelectArea("VS3")
   DbGotop()
   dbSetOrder(1)
   Fg_Seek("VS3","VS1->VS1_NUMORC",1,.F.)
   While VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
      AADD(aColsP,Array(nUsadoP+1))
      For _ni:=1 to nUsadoP
          aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
          if aHeaderP[_ni,2] == "VS3_CODTES"
             dbSelectArea("SB1")
             dbsetorder(7)
             if DbSeek(xFilial("SB1")+aColsP[Len(aColsP),2]+aColsP[Len(aColsP),3])
                aColsP[Len(aColsP),_ni] := SB1->B1_TS
             Endif   
             dbSelectArea("VS3")
          Endif
      Next

      aColsP[Len(aColsP),nUsadoP+1]:=.F.
      nTotDes += VS3->VS3_VALDES
      nTotPec += VS3->VS3_VALTOT
      nTotOrc += VS3->VS3_VALTOT
      dbSkip()

   EndDo

   if Len(aColsP) == 0
      aColsP:={Array(nUsadoP+1)}
      aColsP[1,nUsadoP+1]:=.F.
      For _ni:=1 to nUsadoP
          aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
      Next
   Endif

   aHeader := aClone(aHeaderP)
   aCols   := aClone(aColsP)

   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private oNo := LoadBitmap( GetResources(), "LBNO" )
  
   DEFINE MSDIALOG oDlg FROM 000,000 TO 027,080 TITLE cTitulo OF oMainWnd

      // Folder 1

      Zero()
      oGetMGet:= MsMGet():New("VS1",0,nOpcE,,,,aCpoEnchoice,{014,002,084,312},,2,,,,oDlg,,.T.,.F.)

      @ 180,002 Say OemToAnsi(STR0007)    SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE // //"Pecas"
      @ 180,032 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
      @ 180,121 Say OemToAnsi(STR0008) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE // //"Desconto"
      @ 180,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
      @ 180,235 Say OemToAnsi(STR0009)    SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE // //"Total"
      @ 180,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

      aHeader  := aClone(aHeaderP)
      aCols    := aClone(aColsP)
      oGetPecas                       := MsGetDados():New(089,002,176,312,nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oDlg)
      oGetPecas:oBrowse:default()
      oGetPecas:oBrowse:bGotFocus     := {|| Fs_VerCabec(),aHeader := aClone(aHeaderP),aCols := aClone(aColsP),n := nP }
      oGetPecas:oBrowse:bLostFocus    := {|| aHeaderP:= aClone(aHeader), aColsP:= aClone(aCols), nP:= n }


   ACTIVATE MSDIALOG oDlg CENTER ON INIT (FG_EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()}) )

   if nOpca == 1
      Processa( {|| FS_IMPRNOTA() } )
   Endif
   
Return



Function FS_IMPRNOTA()
******************

If ExistBlock("NFPECSER")
   ExecBlock("NFPECSER",.f.,.f.,{VS1->VS1_NUMNFI,VS1->VS1_SERNFI}) // SN - NF Saida (Normal)
Endif

Return 

Static Function MenuDef()
Local aRotina := {{OemToAnsi(STR0002),"AxPesqui",0,1},; //"Pesquisar"
                  {OemToAnsi(STR0003),"ImpNota" ,0,2}}  //"Imprimir"
Return aRotina
