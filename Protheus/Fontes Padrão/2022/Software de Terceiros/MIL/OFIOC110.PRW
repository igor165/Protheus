#INCLUDE "ofioc110.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOC110 ³ Autor ³ Andre                 ³ Data ³ 29/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta da Negociacao de Pagamento da Venda Balcao        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC110

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0003) //"Orcamentos"
Private lA1_IBGE  := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)

cIndVS1 := CriaTrab(Nil, .F.)
cChave  := "VS1_FILIAL+VS1_NUMORC"
cCond   := "!Empty(VS1->VS1_NUMNFI)"        //Orcamento Vendido

IndRegua("VS1",cIndVS1,cChave,,cCond,OemToAnsi(STR0004) ) //"Orcamento"

mBrowse( 6, 1,22,75,"VS1")

DbSelectArea("VS1")
RetIndex()

#IFNDEF TOP
   If File(cIndVS1+OrdBagExt())
      fErase(cIndVS1+OrdBagExt())
   Endif
#ENDIF

Return


////////////////////
Function ConsulOrc()

   Local bCampo   := { |nCPO| Field(nCPO) }
   Local cTitulo , cLinOk , cTudoOk , cFieldOk 
   Local nCntFor := 0 , _ni := 0 , nUsado := 0 , i := 0
   Local dDataCal 
   Local nPosRec := 0

   Private aTELA[0][0], aGETS[0]
   Private nTotDes := 0
   Private nTotOrc := 0
   Private nTotPec := 0
   Private nTotSrv := 0
   Private nP := 1
   Private oLbEntIte
   Private lPri := .t.
   Private aTitles  := {}
   Private aTitles2 := {}
   Private oFolder
   
   Private nOpc := 2 , nOpcE := 2 , nOpcG := 2
   Private lRefresh := .t. , Inclui   := .f. , lVirtual := .f. , nLinhas  := 99
   Private aCols := {} , aHeader := {} , aCpoEnchoice  :={} , aHeaderP:={} , aColsP := {}
   Private aEntrada := {} , aDescEnt := {} , aIteParc := {}

   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private oNo := LoadBitmap( GetResources(), "LBNO" )

   aRotina := { { " " ," " , 0, 1},;    //Pesquisar
                { " " ," " , 0, 2},;    //Visualizar
                { " " ," " , 0, 3},;    //Incluir
                { " " ," " , 0, 4},;   	//Alterar
                { " " ," " , 0, 5} }   	//Excluir

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Opcoes de acesso para a Modelo 3                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cTitulo       :=STR0005 //"Consulta Venda de Pecas"
   cLinOk        :="AllwaysTrue()"
   cTudoOk       :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

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
   
      If X3USO(x3_usado).and.cNivel>=x3_nivel.and.( Alltrim(x3_campo) $ [VS1_CLIFAT#VS1_LOJA#VS1_NCLIFT#VS1_ENDCLI#VS1_CIDCLI#VS1_ESTCLI#VS1_NUMNFI#VS1_SERNFI])
         AADD(aCpoEnchoice,x3_campo)
      Endif

	   If x3_context == "V"
		   &("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf   

      dbSkip()

   End
   
   DbSelectArea("SA1")
   DbGotop()
   DbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
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

         
         &( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

      Endif

      dbSkip()

   EndDo

	// Inclui coluna de registro atraves de funcao generica
	dbSelectArea("VS3")
	ADHeadRec("VS3",aHeaderP)
	// Posicao do registro
	nPosRec:=Len(aHeaderP)
	nUsadoP:=Len(aHeaderP)

   aColsP:={Array(nUsadoP+1)}
   aColsP[1,nUsadoP+1]:=.F.

   For _ni:=1 to nUsadoP
		If IsHeadRec(aHeaderP[_ni,2])
			aColsP[Len(aColsP),_ni] := 0
		ElseIf IsHeadAlias(aHeaderP[_ni,2])
			aColsP[Len(aColsP),_ni] := "VS3"
		Else	
			aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
		EndIf	
   Next

   aColsP := {}
   dbSelectArea("VS3")
   DbGotop()
   dbSetOrder(1)
   Fg_Seek("VS3","VS1->VS1_NUMORC",1,.F.)

   While VS3->VS3_NUMORC == VS1->VS1_NUMORC .And. VS3->VS3_FILIAL == xFilial("VS3") .and. !eof()

      AADD(aColsP,Array(nUsadoP+1))

      For _ni:=1 to nUsadoP

			 If IsHeadRec(aHeaderP[_ni,2])
				 aColsP[Len(aColsP),_ni] := VS3->(RecNo())
			 ElseIf IsHeadAlias(aHeaderP[_ni,2])
				 aColsP[Len(aColsP),_ni] := "VS3"
			 Else
				 aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
			 EndIf

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

			If IsHeadRec(aHeaderP[_ni,2])
				aColsP[Len(aColsP),_ni] := 0
			ElseIf IsHeadAlias(aHeaderP[_ni,2])
				aColsP[Len(aColsP),_ni] := "VS3"
			Else	
				aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
			EndIf	

      Next

   Endif

   aIteRel := FG_ITEREL(VS1->VS1_TIPTEM,aColsP[1,fg_posvar("VS3_GRUITE","aHeaderP")],If(ReadVar()=="M->VS3_CODITE",M->VS3_CODITE,aColsP[1,fg_posvar("VS3_CODITE","aHeaderP")]),"VS1->VS1_FORMUL")

   aHeader := aClone(aHeaderP)
   aCols   := aClone(aColsP)

   aEntrada := {}
   aDescEnt := {}
   aIteParc := {}

   DbSelectArea("VSE")
   DbGotop()
   DbSeek(xFilial("VSE")+VS1_NUMNFI+VS1_SERNFI)

   While !EOF() .and. (xFilial("VSE") == VSE->VSE_FILIAL) 
       
         if VSE->VSE_NUMNFS != VS1->VS1_NUMNFI
            DbSkip()
            Loop
         Endif   

         if VSE_NOMECP = [QTDEPARC]
            nQtdeParc:= VSE_VALDIG
         Endif
         DbSkip()
         if VSE_NOMECP = [INTERVAL]
            nInterval:= VSE_VALDIG
         Endif   
         DbSkip()
         if VSE_NOMECP = [PRIMPARC]
            nPrimParc:= VSE_VALDIG
         Endif   
         DbSkip()
         if VSE_NOMECP = [NUMDOCTO]
            nNumDocto:= VSE_VALDIG
         Endif
         DbSkip()                               
         if VSE_NOMECP = [VALDOCTO]
            nValDocto:= VSE_VALDIG
         Endif
         DbSkip()                               

         DbSelectArea("VSA")
         DbGotop()
         DbSeek(xFilial("VSA")+VSE->VSE_TIPPAG)

         DbSelectArea("VSE")
         
         dDataCal := dDataBase+val(nPrimParc)

         For i:=1 to val(nQtdeParc)

             if i=1
                aadd(aEntrada,{.f.,VSE->VSE_TIPPAG, VSA->VSA_DESPAG, dDataCal, (val(nValDocto)/val(nQtdeParc)), Str(val(nNumDocto),10) })
             Else
                aadd(aEntrada,{.f.,VSE->VSE_TIPPAG, VSA->VSA_DESPAG, dDataCal, (val(nValDocto)/val(nQtdeParc)), Str(val(nNumDocto+str(i)),10) })
             Endif

             dDataCal := dDataCal+val(nInterval)

         Next

         Do While .t.

            if VSE->VSE_TIPPAG == VSA->VSA_TIPPAG
               aadd(aDescEnt,{VSE->VSE_DESCCP,Transform(VSE->VSE_VALDIG,VSE->VSE_PICTCP)})
            Else
               Exit
            Endif

            DbSkip()

         EndDo

   Enddo 
   
   if Len(aEntrada) == 0
      AADD(aEntrada,{.F.," "," "," ",0," "})
   Endif

   If Len(aDescEnt) == 0
      aadd(aDescEnt,{" ", "0" })
   EndIf
   
   DbSelectArea("SE1")
   DbGoTop()
   DbSeek(xFilial("SE1")+"001"+VS1->VS1_NUMNFI)

   Do While !EOF() .and. (E1_NUM == VS1->VS1_NUMNFI)  .And. SE1->E1_FILIAL == xFilial("SE1") 

      if alltrim(SE1->E1_TIPO) == "DP"
         aadd(aIteParc,{E1_VENCREA,E1_VALOR})
      Endif

      DbSkip()

   Enddo
   
   If Len(aIteParc) == 0
      aadd(aIteParc,{ Ctod("  /  /  ") , 0 })
   EndIf   
   
   aTitles  := {OemToAnsi(STR0006),OemToAnsi(STR0007)} //"Venda"###"Pagamento"
   aTitles2 := {OemToAnsi(STR0008),OemToAnsi(STR0009)} //"Pecas"###"Servicos"

   DEFINE MSDIALOG oDlg FROM 000,000 TO 027,080 TITLE cTitulo OF oMainWnd

      // Folder 1

      @ 012,001 FOLDER oFolder SIZE 316,254 OF oDlg PROMPTS aTitles[1],aTitles[2] PIXEL

      oFolder:bChange    := {|| .t. }                                     // Executa na mudanca da aba
      oFolder:bSetOption := {|x| .t.}                                     // Validacao na saida da aba
      oFolder:aDialogs[1]:lVisible := .t.  
      oFolder:aDialogs[1]:bWhen    := {|| .t. }
      oFolder:aDialogs[1]:bValid   := {|| .t. }

      Zero()
      oGetMGet:= MsMGet():New("VS1",0,nOpcE,,,,aCpoEnchoice,{001,002,070,312},,2,,,,oFolder:aDialogs[1],,.T.,.F.)

      @ 165,002 Say OemToAnsi(STR0008)    SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Pecas"
      @ 165,032 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK when .f.
      @ 165,121 Say OemToAnsi(STR0010) SIZE 50,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Desconto"
      @ 165,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK when .f.
      @ 165,235 Say OemToAnsi(STR0011)    SIZE 50,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Total"
      @ 165,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK when .f.

      aHeader  := aClone(aHeaderP)
      aCols    := aClone(aColsP)
      oGetPecas                       := MsGetDados():New(074,002,162,312,nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])
      oGetPecas:oBrowse:default()
      oGetPecas:oBrowse:bGotFocus     := {|| Fs_VerCabec(),aHeader := aClone(aHeaderP),aCols := aClone(aColsP),n := nP }
      oGetPecas:oBrowse:bLostFocus    := {|| aHeaderP:= aClone(aHeader), aColsP:= aClone(aCols), nP:= n }


      // Folder 2

      @ 001,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(""),;
                                               OemToAnsi(STR0012),; //"Tipo       "
                                               OemToAnsi(STR0013),; //"Descricao  "
                                               OemToAnsi(STR0014),; //"Data       "
                                               OemToAnsi(STR0015),; //"Valor      "
                                               OemToAnsi(STR0016); //"Docto      "
      COLSIZES 10,20,60,35,40,50 ;
      SIZE 312,090 OF oFolder:aDialogs[2] ON CHANGE (FS_MUDATP(oLbItens:nAt)) PIXEL

      oLbItens:SetArray(aEntrada)
      oLbItens:bLine := { || {  IIF(aEntrada[oLbItens:nAt,1],oOk,oNo) ,;
                                    aEntrada[oLbItens:nAt,2] ,;
                                    aEntrada[oLbItens:nAt,3] ,;
                                    aEntrada[oLbItens:nAt,4] ,;
                                    Transform(aEntrada[oLbItens:nAt,5],"@E 999,999,999.99") ,;
                                    aEntrada[oLbItens:nAt,6] }}


      @ 092,001 LISTBOX oLbEntIte FIELDS HEADER OemToAnsi(STR0013),; //"Descricao  "
                                                OemToAnsi(STR0015); //"Valor      "
      COLSIZES 60,100 ;
      SIZE 200,088 OF oFolder:aDialogs[2] PIXEL

      oLbEntIte:SetArray(aDescEnt)
      oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
                                aDescEnt[oLbEntIte:nAt,2] }}

      @ 092,203 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0017),OemToAnsi(STR0018); //"Data"###"Valor"
      COLSIZES 40,50;
      SIZE 110,088 OF oFolder:aDialogs[2] PIXEL ON DBLCLICK (FG_ALTFINAN(oLbParc:nAt))

      oLbParc:SetArray(aIteParc)
      oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
                         Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}

   ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALNF3 ºAutor  ³Andre / Fabio       º Data ³  10/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida NF de saida existe                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALNF3()

DbSelectArea("SF2")
DbSetOrder(1)

if !FG_VALIDA(Nil,"SF2T1mv_par01*",Nil)
   Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALNF4 ºAutor  ³Andre / Fabio       º Data ³  10/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida Orcamento                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALNF4()

DbSelectArea("VS1")
DbSetOrder(3)

if !FG_VALIDA(Nil,"VS1T3mv_par01+mv_par02*",Nil)
   Return .t.
Else
   FG_VALIDA(Nil,"SA1T1VS1->VS1_CLIFAT+VS1->VS1_LOJA*","mv_par03 := sa1->a1_nome")
   mv_par04 := VS1->VS1_DATORC
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MUDATP ºAutor  ³Andre / Fabio       º Data ³  10/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDATP(nLin)

   DbSelectArea("VSE")
   DbGotop()
   DbSeek(xFilial("VSE")+VS1_NUMNFI+VS1_SERNFI+aEntrada[nLin,2])

   aDescEnt := {}

   While !EOF() .and. (xFilial("VSE") == VSE->VSE_FILIAL) 
       
         if VSE->VSE_NUMNFS != VS1->VS1_NUMNFI
            DbSkip()
            Loop
         Endif   

         DbSkip(5)

         DbSelectArea("VSA")
         DbGotop()
         DbSeek(xFilial("VSA")+VSE->VSE_TIPPAG)

         DbSelectArea("VSE")
         
         Do While .t.
            if VSE->VSE_TIPPAG == VSA->VSA_TIPPAG
               aadd(aDescEnt,{VSE->VSE_DESCCP,Transform(VSE->VSE_VALDIG,VSE->VSE_PICTCP)})
            Else
               Exit
            Endif
            DbSkip()
         EndDo

   Enddo 

   If Len(aDescEnt) == 0
      aadd(aDescEnt,{" ", "0" })
   EndIf

   if !lPri
      oLbEntIte:SetArray(aDescEnt)
      oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
                                aDescEnt[oLbEntIte:nAt,2] }}

      oLbEntIte:Refresh()
      lPri := .f.
   Else
      lPri := .f.
   Endif   
   
Return .t.

Static Function MenuDef()
Local aRotina := {{STR0001,"AxPesqui" ,0,1},; //"Pesquisar"
                    {STR0002,"CONSULORC",0,2}} //"Consultar"
Return aRotina
