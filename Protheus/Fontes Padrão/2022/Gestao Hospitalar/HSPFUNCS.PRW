#INCLUDE "HSPFUNCS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_EDITPAC   ³ Autor ³ Manoel Filho     ³ Data ³03/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Chama Tela para alteracao dos dados do Paciente           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_EditPac(nOpc)
 Local lRet := .F.
 
 Private Inclui := nOpc == 3, Altera := nOpc <> 3, aMemos := {}
 
 If Type("lM01Auto") # "U" .And. lM01Auto
 	Return(.T.)
 EndIf
 
 DbSelectArea("GBH")
 lRet := HS_A58("GBH", GBH->(RecNo()), nOpc)
 
 DbSelectArea("GCY")
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_SEEKRET   ³ Autor ³ Manoel Filho     ³ Data ³03/01/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Executa Busca; Retorna conteudo de campos;                ³±±
±±³          ³  Mostra mensagem na tela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Uso Geral                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*** Parametros ***

cAliasS  = arquivo alvo
cChv_    = chave de pesquisa
Ord_     = numero do indice associado a ExpC1  (Opcional)
           Se nao informado assume 1
Sss_     = se .t. softseek ON                  (Opcional)
           Se nao informado assume .f.
cCpoDest = Campo Destino (que recebera conteudo) com as possibilidades abaixo
           - Campo caracter ex.: "GC9_CODCON"
           - Campo Array    ex.: {"GC9_CODCON", "GC9_CODPAC"}
cCpoOrig = Campo Origem do conteudo com as possibilidades abaixo
           - Campo caracter ex.: "GCZ_CODCON"
           - Campo Array    ex.: {"GCZ_CODCON", "GCZ_CODPAC"}
           
cMens    = Mensagem a Ser apresentada na Tela

lMosMens = se .t. Mostra EXPC5 quando Found(), caso contrario quando !Found()
        
lNaoaCols= Se .t. nao usa campos do aCols para fazer o SEEK, caso contrario usa

Retorna:   .t. se o reg. existir, deixando posicionado no mesmo
           .f. se o reg. nao existir, deixando posic. no final do Arquivo
*/
Function HS_SeekRet(cAliasS,Chv_,Ord_,Sss_,cCpoDest,cCpoOrig,cMens,lMosMens,lNaoaCols)
 Local bCampo, nCpoDest, i
 
 Atu_:=SELECT()
 Ind_ := 0
 Sem_dbf:=ALIAS()
 Achou_ := .T.

 Ord_:=IF(Ord_=NIL,1,Ord_)
 Sss_:=IF(Sss_=NIL,.f.,Sss_)
 If ValType(cCpoDest) # "A"
  cCom := IIf(cCpoOrig == NIL, " ", cAliasS + "->" + cCpoOrig)
 Else                                             
  cCom := {}
  For nCpoDest := 1 To Len(cCpoDest)
   If ValType(cCpoOrig) # "A" .Or. Len(cCpoOrig) < nCpoDest
    aAdd(cCom, " ")
   Else
    aAdd(cCom, cAliasS + "->" + cCpoOrig[nCpoDest])
   EndIf 
  Next 
 EndIf 

 Select(cAliasS)
 Ind_:=IndexOrd()
 DbSetOrder(Ord_)
 //Set SoftSeek (Sss_)
 
 if Type("aCols") == "A" .and. !lNaoAcols    && Modelo 3
  cChave := ""
  if type(readvar()) == "U"
   cUlCpo := ""
  Else
   cUlCpo := &(readvar())
  Endif
   
  If Len(aCols) > 0
   k := at("M->",chv_)
   If k > 0 .and. ( Subs(chv_,k-1,1) == "+" .or. (k-1 == 0) .or. !SX2->(dbSeek(Subs(chv_,k-2,3))) )
    bCampo := {|x| aHeader[x,2]}
    w1 := READVAR()
    For i=1 to Len(aHeader)
     wVar := "M->"+(EVAL(bCampo,i))
     If wVar != w1
      Private &wVar := aCols[n,i]
     Endif
    Next
   Endif
  EndIf
   
  While .t.
   k := at("+",chv_)
   if k > 0
    cCPO := substr(chv_,1,k-1)
    chv_ := substr(chv_,k+1)
    if at("->",cCpo) == 0 .and. ValType(cCpo) == "U"
    	cChave := cChave + FieldGet(FieldPos(cCPO))
    else
    	cChave := cChave + &cCpo
    endif
   Else
    if !Chv_ == readvar()
     cUlCpo := &Chv_
    endif
    Exit
   Endif
  Enddo

  cChv_ := cChave+cUlCpo
 Else
  cChv_ := (&Chv_) 
 Endif
    
 DbGotop()
 DbSeek(xFilial(cAliasS) + cChv_, Sss_)
 Achou_:=IIF(Sss_, !Eof(), FOUND())

 DbSetOrder(ind_)
 IF Empty(sem_dbf)
  Sele 0
 ELSE
  Sele (Atu_)
 ENDIF

 Set SoftSeek (.f.)
              
 If ValType(cCpoDest) # "A"
  if cCom != " " .and. cCpoDest # ""
   M->&cCpoDest := &cCom
  endif
 Else 
  For nCpoDest := 1 To Len(cCpoDest)
   M->&(cCpoDest[nCpoDest]) := &(cCom[nCpoDest])
  Next
 EndIf 

 if Type("aCols") == "A"    && Modelo 3
  If ValType(cCpoDest) # "A"
   nPos := aScan(aHeader,{|x| x[2] == PadR(cCpoDest, 10)})
   If Type("aCols[n,nPos]") # "U"
    aCols[n,nPos] := &cCom
   Endif   
  Else     
   For nCpoDest := 1 To Len(cCpoDest)
    nPos := aScan(aHeader,{|x| x[2] == PadR(cCpoDest[nCpoDest], 10)})
    If ValType("aCols[n,nPos]") # "U"
     aCols[n,nPos] := &(cCom[nCpoDest])
    Endif   
   Next 
  EndIf 
 Endif   

 If Type("cMens") # "U" .Or. ValType(cMens) # "U"
  If Type("lMosMens") # "U" .Or. ValType(lMosMens) # "U"
   if lMosMens
    If aChou_
     MsgStop(cMens)
    Endif   
   Else
    If !aChou_
     MsgStop(cMens)
    Endif
   Endif
  Endif         
 Endif
Return(Achou_)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_PESQ      ³ Autor ³ Manoel Filho     ³ Data ³23/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Pesquisa nos Arquivos (Com UPPER quando caracter)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PESQ()
 cSavArea  := Alias()                        
 cSavInd   := IndexOrd()
 aIndFil   := {} 
 cChaveSel := space(100)
 cIndSel   := space(100) 

 DBSelectArea("SIX")
 DBSeek(cSavArea)   
 cNumOrd := 1
 While !Eof() .and. indice == cSavArea
  AADD(aIndFil,StrZero(cNumOrd++,2)+". "+Descricao)
  DBSkip()
 Enddo                 

 DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0001) From 5,14 to 11,76	of oMainWnd	  //"Pesquisar"

 @ 011,004 MSCOMBOBOX oPesq1 VAR cIndSel SIZE 200,9 COLOR CLR_BLACK;
           ITEMS aIndFil OF oDlgP PIXEL
              
 @ 024,004 MSGet oPesq2 var cChaveSel PICTURE "@!" size 200,9 OF oDlgP PIXEL COLOR CLR_BLACK 

 DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (HS_Pesq2(),oDlgP:End()) ENABLE OF oDlgP
 DEFINE SBUTTON FROM 024,209 TYPE 2 ACTION (oDlgP:End()) ENABLE OF oDlgP

 ACTIVATE MSDIALOG oDlgP CENTERED
Return                     

Static Function HS_Pesq2()                                           
 DBSelectArea(cSavArea)
 nOrdAnt := IndexOrd()
 DBSetOrder(Val(Subs(cIndSel,1,2)))
 DbSeek(xFilial(cSavArea) + Alltrim(cChaveSel)) 
 If Len(aIndFil) < nOrdAnt
  DBSetOrder(nOrdAnt)
 Endif   
 DbSetOrder(cSavInd)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_LEGENDA³Autor  ³ Manoel Filho          ³ Data ³25.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gestao Hospitalar                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_LEGENDA()
 BrwLegenda(cCadastro, STR0002,{{"BR_VERDE"   , STR0003},;  //"Legenda"###"Ambulatorio"
                                {"BR_AMARELO" , STR0004},;  //"Centro Cirurgico"
						        {"BR_AZUL"    , STR0005},;  //"Postos de Enfermagem"
						        {"BR_VERMELHO", STR0006},;  //"U.T.I."
						   	    {"BR_CINZA"   , "Bercario"}})
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_LEGFEC ³Autor  ³ Manoel Filho   		³ Data ³25.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse do Fechamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gestao Hospitalar                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_LEGFEC()
BrwLegenda(cCadastro,STR0002,{{"BR_VERDE",STR0010},; 		 //"Legenda"###"Contas Abertas"
								{"BR_VERMELHO",STR0011}})    //"Contas Fechadas"
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_LEGLOT ³Autor  ³ Manoel Filho          ³ Data ³25.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores mbrowse do Atribuição de Lotes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gestao Hospitalar                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_LEGLOT()
BrwLegenda(cCadastro,STR0002,{{"BR_VERDE",STR0016},; 		 //"Legenda"###"Contas Não Atribuidas"
								{"BR_VERMELHO",STR0017}})    //"Contas Atribuídas"
Return(.T.)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_LEGDES ³Autor  ³ Manoel Filho          ³ Data ³25.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores mbrowse do Atribuição de Lotes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gestao Hospitalar                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function HS_LEGDES()
 BrwLegenda(cCadastro,STR0002,{{"BR_VERDE"   , STR0018}, ; //"Legenda"###"Contas Não Geradas"
                               {"BR_VERMELHO", STR0019}})  //"Contas Geradas"
Return(.T.)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_LEGFAT ³Autor  ³ Manoel Filho          ³ Data ³25.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse do Faturamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gestao Hospitalar                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_LEGFAT()
BrwLegenda(cCadastro,STR0002,{{"BR_VERDE",STR0020},; 		 //"Legenda"###"Contas Não Faturadas"
								{"BR_VERMELHO",STR0021}})    //"Contas Faturadas"
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_GRVCPO    ³ Autor ³ Manoel Filho     ³ Data ³28/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Gravacao dos Campos de Um Arquivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cAliasArq := Alias do arquivo a ser gravado               ³±±
±±³          ³  aColsVet  := Nome do vetor da Gravacao                    ³±±
±±³          ³  aHeaderVet:= Obrigatorio quando for gravar o aColsVet     ³±±
±±³          ³  nx1       := Linha do aCols que sera brafada Obrigat=aCols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Uso Geral                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GRVCPO(cAliasGrv,aColsGrv,aHeaderGrv,ni)
Local bCampo3   := { |nCPO| FieldName(nCPO) }
Local cSavAlias := Alias()
Local nCpoMem := 0, cCampoGrv := "", nxi, nix

DbSelectArea(cAliasGrv)

If aColsGrv == NIL
	For nxi := 1 to FCount()
		If Type("M->"+(EVAL(bCampo3,nxi))) != "U"
			&(EVAL(bCampo3, nxi)) := M->&(EVAL(bCampo3, nxi))
		EndIf
	Next
	&(Alltrim(cAliasGrv)+"_FILIAL")  := xFilial(cAliasGrv)
	
	aMemos := HS_AMemos(cAliasGrv)
	
	If Type("aMemos") == "A" .And. Len(aMemos) > 0 .And. Upper(SubStr(aMemos[1, 1], 1, At("_", aMemos[1, 1]) - 1)) == Upper(cAliasGrv)
		For nCpoMem := 1 To Len(aMemos)
			cCampoGrv := aMemos[nCpoMem, 2]
			DbSelectArea("SX3")
			DbSetOrder(2)
			DbSeek(cCampoGrv)
			DbSelectArea(cAliasGrv)
			If SX3->X3_TIPO == "M" .And. SX3->X3_CONTEXT == "V" .And. ValType("M->" + cCampoGrv) <> "U"
				MSMM(, TamSx3(cCampoGrv)[1],, &("M->" + cCampoGrv), 1,,, cAliasGrv, aMemos[nCpoMem, 1])
			EndIf
		Next nCpoMem
	EndIf
Else
	For nix := 1 to Len(aHeaderGrv)
		&(aHeaderGrv[nix,2]) := aColsGrv[ni,nix]
	Next
EndIf


DbSelectArea(cSavAlias)
Return(Nil)
                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_PRODES    ³ Autor ³ Manoel Filho     ³ Data ³26/02/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Verifica se Produto esta Desativado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ProDes()
          
If GBI->GBI_PRODES == "D"
   MsgStop(STR0024,STR0025) //"Produto Desativado!"###"Atencao"
   Return .f.
Endif
   
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_VALREQ    ³ Autor ³ Manoel Filho     ³ Data ³26/02/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Verifica se é Valido o Requisitante do Produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ValReq()

 if M->GAI_REQUIS == '2' .and. !SB1->B1_REQUIS $ '03'
    MSGSTOP(STR0017,STR0010) //"Este Produto Não Pode Ser Solicitado Para CENTRO DE CUSTOS !"###"Atenção"
    Return .f.
 Endif   
 if M->GAI_REQUIS == '3' .and. !SB1->B1_REQUIS $ '03'
      MSGSTOP(STR0018,STR0010) //"Este Produto Não Pode Ser Solicitado Para CONSUMO PRÓPRIO !"###"Atenção"
    Return .f.
 Endif 
 if M->GAI_REQUIS == '1' .and. !SB1->B1_REQUIS $ '13'
      MSGSTOP(STR0019,STR0010) //"Este Produto Não Pode Ser Solicitado Para PACIENTE !"###"Atenção"
      Return .f.
 Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_RETCOD    ³ Autor ³ Manoel Filho     ³ Data ³Marco/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Verifica se ha duplicidade do codigo de barras            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_RetCod

cCodPro   := space(15)
cBarras   := space(15)
if SX3->X3_ARQUIVO == 'SD3'
   cBarras := M->D3_COD
 Elseif SX3->X3_ARQUIVO == 'SC2'
   cBarras := M->C2_PRODUTO
Endif    
If Len(Alltrim(cBarras)) > 7
	IF SUBSTR(cBarras,1,3)=="170"
	   MsgStop(STR0029,STR0030) //"Codigo de Barras Invalido"###"Atenção"
	   Return .f.
	ENDIF
		
	IF SUBSTR(cBarras,1,3)=="010"
	   cBarras := SUBSTR(cBarras,4,13)
	  ELSE
	   cBarras := SUBSTR(cBarras,1,13)
	ENDIF
	
	DBSelectArea("SB1")
	DBSetOrder(5)
	DBGoTop()
	DBSeek(xFilial("SB1")+cBarras)
	if !Found()  
	   DBSelectArea("GAP")
	   DBSetOrder(1)
	   DBGoTop()
	   DBSeek(xFilial("GAP")+cBarras)
	   If !Found()
	      MsgStop(STR0036,STR0030) //"Código de Barras Não Encontrado !"###"Atenção"
	      Return .f.                 
	     Else
	      cCodPro := GAP_CODIGO + Space(9)
	   Endif
	 Else
	   cCodPro := B1_COD
	endif    
	
	if SX3->X3_ARQUIVO == 'SD3'
	   M->D3_COD := cCodPro
	   DBSelectArea("SB1")
	   DBSetOrder(1)              
	
	   A240Inicpo()
	
	 Elseif SX3->X3_ARQUIVO == 'SC2'
	   M->C2_PRODUTO := cCodPro
	   DBSelectArea("SB1")
	   DBSetOrder(1)              
	
	   A650Inicpo()
	   SeleOpc(1)
	   A650Quant()
	   A650QTSeg()
	   
	Endif    
  Else
  	if SX3->X3_ARQUIVO == 'SD3'
	   DBSelectArea("SB1")
	   DBSetOrder(1)              
	
	   A240Inicpo()
	
	 Elseif SX3->X3_ARQUIVO == 'SC2'
	  
	   DBSelectArea("SB1")
	   DBSetOrder(1)              
	
	   A650Inicpo()
	   SeleOpc(1)
	   A650Quant()
	   A650QTSeg()
	   
	Endif    

Endif	   

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_CPOOBR   ³ Autor ³ José Orfeu        ³ Data ³28/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Verifica se todos os campos obrigatorios estao preenchidos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aObrGets - Matriz contendo todas as aGets da tela         ³±±
±±³          ³  aObrTela - Matriz contendo todas as aTela da tela         ³±±
±±³          ³  aCposObr - Campos que nao sao definidos como obrigatorio  ³±±
±±³          ³             no dicionario mas sao obrigatorio no cadastro  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Verdadeiro ou Falso                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_CpoObr(aObrGets, aObrTela, aCposObr)
 Local lRet := .T., nForVld := 0, aArea := GetArea(), cHlpMsg := "", cAliasCpo := ""
 
 For nForVld := 1 To Len(aObrGets)
  If !(lRet := Obrigatorio(aObrGets[nForVld], aObrTela[nForVld]))
   Exit
  EndIf
 Next
 
 If lRet .And. Len(aCposObr) > 0
  For nForVld := 1 To Len(aCposObr)
   If Empty(&("M->" + aCposObr[nForVld]))
    aCposSx3 := HS_CfgSx3(aCposObr[nForVld])
    If !Empty(aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
     DbSelectArea("SXA")
     DbSetOrder(1)                                 
     DbSeek(aCposSx3[SX3->(FieldPos("X3_ARQUIVO"))] + aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
     cHlpMsg += STR0145 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "] " + Chr(10) //"Campo obrigatorio ["
     cHlpMsg += STR0146 + AllTrim(SXA->XA_DESCRIC) + "]" + Chr(10) //"Pasta ["
    Else                                                 
     cHlpMsg := STR0145 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "]" + Chr(10) //"Campo obrigatorio ["
    EndIf
   EndIf
  Next  
  
  If !Empty(cHlpMsg)
   HS_MsgInf(cHlpMsg, STR0030, STR0147) //"Atenção"###"Campos Obrigatorios"
   lRet := .F.
  EndIf
 EndIf
   
 RestArea(aArea)
Return(lRet)

Function HS_AtvFilt(cAlias, cFiltro, lBuildExpr, oDlgBuildExpr, lTop)
 Local cOldAlias := Alias()
 
 Default lBuildExpr := .F.
 Default lTop       := .F.
 
 DbSelectArea(cAlias)
 
 If lBuildExpr
  cFiltro := BuildExpr(cAlias, oDlgBuildExpr, cFiltro, lTop)
 EndIf 

 If At("_FILIAL", cFiltro) == 0
  If !Empty(cFiltro)                     
   cFiltro := "(" + cFiltro + ")" + IIf(lTop, " And ", " .And. ")
  EndIf
 
  If lTop
   cFiltro += PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "'"
  Else
   cFiltro += cAlias + "->" + PrefixoCpo(cAlias) + "_FILIAL == '" + xFilial(cAlias) + "'"
  EndIf 
 EndIf 
 
 If lTop .And. At("@", cFiltro) == 0
  cFiltro := "@" + cFiltro
 EndIf
                   
 DBSetFilter({|| &(cFiltro)}, cFiltro)
 DbSeek(xFilial(cAlias))

 DbSelectArea(cOldAlias)
Return(Nil)                         

Function HS_DtvFilt(cAlias)
 Local cOldAlias := Alias()
 DbSelectArea(cAlias)
 DbClearFilter() 
 DbSelectArea(cOldAlias)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_TelSX5    ³ Autor ³ Manoel           ³ Data ³21/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que monta Tela de Inclusao, alteracao e Exclusao   ³±±
±±³          ³  nas Tabelas do SX5                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  HS_TelSx5(cFuncExc, cFuncCheck, nOpc, nNroDigCod, cPict)
 Local nTamt		:=15
 Default cFuncExc   := ".T."
 Default cFuncCheck := ".T."
 Default nNroDigCod := Len(SX5->X5_CHAVE)
 Default cPict      := Replicate("9", nNroDigCod)


// If ValType(nNroDigCod) == "N"
//  cPict := Replicate("9",nNroDigCod)
// Else
//  cPict := "'" + nNroDigCod + "'"
// EndIf

 nOpca := 0       
 aSize := MsAdvSize(.T.)     

 DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6], aSize[5] OF oMainWnd Pixel
   
 @ 17+nTamt,004 SAY OemToAnsi(cSayCpo1) OF oDlg PIXEL COLOR CLR_HBLUE
 @ 27+nTamt,004 MSGET oTipDes VAR M->X5_CHAVE PICTURE cPict VALID &cFuncCheck SIZE 30,4 OF oDlg PIXEL  when str(nopc,1) == "3"
 @ 41+nTamt,004 SAY OemToAnsi(cSayCpo2) OF oDlg PIXEL COLOR CLR_HBLUE
 @ 51+nTamt,004 MSGET oDescri VAR M->X5_DESCRI PICTURE "@!" SIZE 160,4 OF oDlg PIXEL  when str(nopc,1) $ "34"
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf(nOpc==5, IIf(&(cFuncExc), oDlg:End(), nOpcA := 0) ,oDlg:End())},;
                                                 {|| nOpcA := 0, oDlg:End() })   

Return

Function HS_RConta(cAlias, cCond)
 Local cAliasAnt := Alias(), nRConta := 0, nRecAtu := 0
 DbSelectArea(cAlias)                                  
 nRecAtu := RecNo()
 COUNT TO nRConta FOR &(cCond)
 DbGoTo(nRecAtu)
 DbSelectArea(cAliasAnt) 
Return(nRConta)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_PESQLD    ³ Autor ³ Manoel Filho     ³ Data ³23/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Pesquisa Exclusiva para os Arquivos de Trabalho criados na³±±
±±³          ³  Rotina de Lancamento Despesas (Com UPPER quando caracter) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PESQLD()

cSavArea  := Alias()                        
cChaveSel := space(100)
cIndSel   := space(100) 

aIndFil   := {STR0074} //"01. Data da Despesa + Codigo da Despesa"

DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0001) From 5,14 to 11,76	of oMainWnd	  //"Pesquisar"

@ 011,004 MSCOMBOBOX oPesq1 VAR cIndSel SIZE 200,9 COLOR CLR_BLACK;
              ITEMS aIndFil OF oDlgP PIXEL
              
@ 024,004 MSGet oPesq2 var cChaveSel PICTURE "@!" size 200,9 OF oDlgP PIXEL COLOR CLR_BLACK 

DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (HS_PesqLD2(),oDlgP:End()) ENABLE OF oDlgP
DEFINE SBUTTON FROM 024,209 TYPE 2 ACTION (oDlgP:End()) ENABLE OF oDlgP

ACTIVATE MSDIALOG oDlgP CENTERED

Return                     

Static Function HS_PesqLD2()                                           

DBSelectArea(cSavArea)
nOrdAnt := IndexOrd()
DBSetOrder(Val(Subs(cIndSel,1,2)))
DbSeek(Alltrim(cChaveSel)) 
If Len(aIndFil) < nOrdAnt
   DBSetOrder(nOrdAnt)
Endif   

Return
   
// Importa Cadastro de Pacientes
Function HS_ImpPac()
 Processa({|| FS_GrvPac()})
Return(Nil)

Static Function FS_GrvPac()
 Local nHandle := fOpen("\Import\Paciente.Txt", 0)
 Local nBuffer := 0
 Local nLidos := 0
 Local nTotal := 0
 Local aPacientes := {}
 Local nPac := 0
 Private cBuffer := Space(nBuffer)
           
 nTotal := fSeek(nHandle, 0, 2)

 fSeek(nHandle, 0)

 ProcRegua(nTotal / 300)
 
 While nLidos < nTotal                          
  fSeek(nHandle, nLidos)
  nBuffer := 500
  cBuffer := Space(nBuffer)
  fRead(nHandle, @cBuffer, nBuffer)
  
  fSeek(nHandle, nLidos)
  nBuffer := At(Chr(13), cBuffer)
  nBuffer := IIF(nBuffer == 0, 500, nBuffer)
  cBuffer := Space(nBuffer)
  fRead(nHandle, @cBuffer, nBuffer)
  
  aPacientes := &("{" + AllTrim(cBuffer) + "}")
  
  IncProc(STR0075 + aPacientes[02]) //"Importando Paciente "
  
  If aPacientes[09] == 2
   DbSelectArea("SA1")
   DbSetOrder(1)
   RecLock("SA1", !DbSeek(xFilial("SA1") + StrZero(aPacientes[01], Len(SA1->A1_COD))))
   SA1->A1_FILIAL := xFilial("SA1")          
   SA1->A1_NREDUZ := SubStr(aPacientes[02], 1, Len(SA1->A1_NREDUZ))
   SA1->A1_TIPO   := "F"
   SA1->A1_COD    := StrZero(aPacientes[01], Len(SA1->A1_COD))
   SA1->A1_LOJA   := "01"
   SA1->A1_CLICNV := "0"
   SA1->A1_NOME   := aPacientes[02]
   SA1->A1_DTNASC := CToD(aPacientes[03])
   SA1->A1_END    := SubStr(AllTrim(aPacientes[04]) + " " + AllTrim(aPacientes[14]), 1, Len(SA1->A1_END))
   SA1->A1_MUN    := aPacientes[05]
   SA1->A1_EST    := aPacientes[06]
   SA1->A1_BAIRRO := aPacientes[08]
   SA1->A1_CEP    := StrTran(aPacientes[10], "-", "")
   SA1->A1_TEL    := aPacientes[11]
   SA1->A1_RG     := aPacientes[12]
   MsUnLock()
  EndIf
              
  DbSelectArea("GBH")
  DbSetOrder(1)
  RecLock("GBH", !DbSeek(xFilial("GBH") + StrZero(aPacientes[01], Len(GBH->GBH_CODPAC))))
  GBH->GBH_FILIAL := xFilial("GBH")
  GBH->GBH_CODPAC := StrZero(aPacientes[01], Len(GBH->GBH_CODPAC))
  GBH->GBH_NOME   := aPacientes[02]
  GBH->GBH_DTNASC := CToD(aPacientes[03])
  GBH->GBH_END    := SubStr(AllTrim(aPacientes[04]) + " " + AllTrim(aPacientes[14]), 1, Len(GBH->GBH_END))
  GBH->GBH_MUN    := aPacientes[05]
  GBH->GBH_EST    := aPacientes[06]
  GBH->GBH_SEXO   := IIF(aPacientes[07] == "M", "0", "1")
  GBH->GBH_BAIRRO := aPacientes[08]
  GBH->GBH_CEP    := StrTran(aPacientes[10], "-", "")
  GBH->GBH_RG     := aPacientes[12]
  GBH->GBH_PROFIS := aPacientes[13]
  GBH->GBH_NOMPAI := aPacientes[16]
  GBH->GBH_NOMMAE := aPacientes[17]
  GBH->GBH_CODCLI := SA1->A1_COD
  GBH->GBH_LOJA   := SA1->A1_LOJA
  MsUnLock()
  
  nLidos += Len(cBuffer) + 1
 End
              
 fClose(nhandle)
Return(Nil)
 
// Importa Cadastro de Fornecedores
Function HS_ImpFor()
 msgAlert( "Função descontinuada pelo SGBD.","Atenção!" )
Return(Nil)

// Importa cadastro de TES
Function HS_ImpTes()
 msgAlert( "Função descontinuada pelo SGBD.","Atenção!" )
Return(Nil)

// Abre DLL para ser executada pelo Protheus para retornar o ID da maquina - Volume Serial
Function HS_NumId(nFunc, cDrv)
 Local cRetId := ""
 Local nHdlDll := 0
 
 nHdlDll := ExecInDLLOpen("VolIDHsp.Dll")
 If nHdlDll == -1
  Final(STR0086) //"VolIDHsp.Dll tem que estar no diretorio BIN\Remote."
 Else	
  //cRetID := ExecInDLLRun(nHdlDll, 1, cDrv) // Função 1 Retorna o Label do HD
  //MsgStop("Label " + cRetID)
 
  cRetID := ExecInDLLRun(nHdlDll, 2, cDrv) // Função 2 Retorna o Volume Serial do HD 
  // MsgStop("Volume Serial " + cRetID)
 EndIf	
 ExecInDLLClose(nHdlDll)
Return(cRetId)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_HTOM      ³ Autor ³ Rodrigo Xavier   ³ Data ³15/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Recebe uma hora em string de 5 caracteres                 ³±±
±±³          ³  e retorna a qtd de minutos        ex: "01:15" ret: 75     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_HTOM(cHora)
 Local nMinutos := 0, nHoras := 0

 cHora := StrTran(cHora, ":", "")
 
 nHoras 		:= Val(SubStr(cHora, 1, 2))
 nMinutos	:= nHoras * 60 + Val(SubStr(cHora, 3, 2))

Return(nMinutos)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_MTOH      ³ Autor ³ Rodrigo Xavier   ³ Data ³15/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Recebe uma qtd de minutos em inteiro e transforma em      ³±±
±±³          ³  formato hora:minutos             ex: 75 ret: "01:15"      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MTOH(nMin)
 Local cHora := "", nHoras := 0, nMinutos := 0

 nHoras 		:= Int(nMin / 60)
 nMinutos := nMin - (nHoras * 60)
 cHora 			:= StrZero(nHoras, 2) + ":" + StrZero(nMinutos, 2)
 
Return(cHora)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_GETUF     ³ Autor ³ Rodrigo Xavier   ³ Data ³15/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Retorna a descricao do estado.                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GETUF(cUf)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cEstado := ""    

 Do Case
  Case cUf == "AC"
   cEstado := "do Acre"
  Case cUf == "AL"
   cEstado := "de Alagoas"
  Case cUf == "AP"
   cEstado := "do Amapa"
  Case cUf == "AM"
   cEstado := "do Amazonas"
  Case cUf == "BA"
   cEstado := "da Bahia"
  Case cUf == "CE"
   cEstado := "do Ceara"
  Case cUf == "DF"
   cEstado := "do Distrito Federal"
  Case cUf == "ES"
   cEstado := "do Espirito Santo"
  Case cUf == "GO"
   cEstado := "de Goias"
  Case cUf == "MA"
   cEstado := "do Maranhao"
  Case cUf == "MT"
   cEstado := "do Mato Grosso"
  Case cUf == "MS"
   cEstado := "do Mato Grosso do Sul"
  Case cUf == "MG"
   cEstado := "de Minas Gerais"
  Case cUf == "PA"
   cEstado := "do Para"
  Case cUf == "PB"
   cEstado := "da Paraiba"
  Case cUf == "PR"
   cEstado := "do Parana"
  Case cUf == "PE"
   cEstado := "de Pernambuco"
  Case cUf == "PI"
   cEstado := "do Piaui"
  Case cUf == "RJ"
   cEstado := "do Rio de Janeiro"
  Case cUf == "RN"
   cEstado := "do Rio Grande do Norte"
  Case cUf == "RS"
   cEstado := "do Rio Grande do Sul"
  Case cUf == "RO"
   cEstado := "de Rondonia"
  Case cUf == "RR"
   cEstado := "de Roraima"
  Case cUf == "SC"
   cEstado := "de Santa Catarina"
  Case cUf == "SP"
   cEstado := "de Sao Paulo"
  Case cUf == "SE"
   cEstado := "de Sergipe"
  Case cUf == "TO"
   cEstado := "do Tocantins"
 EndCase
Return (cEstado)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_SEMANA    ³ Autor ³ Rodrigo Xavier   ³ Data ³15/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Retorna o nome do dia da semana                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_SEMANA(nSemana)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cSemana := ""    
 
 Do Case
  Case nSemana == 1
   cSemana := STR0043  // "Domingo"
  Case nSemana == 2
   cSemana := STR0044  // "Segunda-feira"
  Case nSemana == 3
   cSemana := STR0045  // "Terca-feira"
  Case nSemana == 4
   cSemana := STR0046  // "Quarta-feira"
  Case nSemana == 5
   cSemana := STR0047  // "Quinta-feira"
  Case nSemana == 6
   cSemana := STR0048  // "Sexta-feira"
  Case nSemana == 7
   cSemana := STR0049  // "Sabado"
 EndCase
 
Return (cSemana)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_MULTL    ³ Autor ³ José Orfeu        ³ Data ³15/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  GetDados para Editar dados com variaveis sem dicionário   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MultiL(nTop, nLeft, nBottom, nRight, lAlter, lDeleta, cLinhaOk, nFreeze, cCampoOk, oDlgML)
 Local nOpc := 3, aSavRot, lNeedRest := .f., oGetDados

 If Type("aRotina") == "A"
  lNeedRest := .t.
  aSavRot := aClone(aRotina)
 EndIf

 Private aRotina := {{"RDMAKE", "SIGAIXB", 0, If(lAlter, 3, 2)}}
 
 AADD(aRotina, aClone(aRotina[1]))
 AADD(aRotina, aClone(aRotina[1]))
 
 oGetDados := MsGetDados():New(nTop, nLeft, nBottom, nRight, nOpc, cLinhaOk,,,lDeleta,,nFreeze,,,cCampoOk,,,,oDlgML)

 If lNeedRest
  aRotina := aClone(aSavRot)
 EndIf
Return oGetDados 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_CENTLUC   ³ Autor ³ José Orfeu       ³ Data ³24/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Monta Centro de Lucro com base nos convenios              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Centro de Luscro do Convenio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_CentLuc(cCodCon, cCentLuc)         
 Local cAliasOld := Alias()
 Local rCentLuc := ""
 Local cConvCCu := ""
                  
 If CtbInUse()
  DbSelectArea("CTT")
  DbSetOrder(1)
  If DbSeek(xFilial("CTT") + GetMV("MV_PREFCL") + cCodCon)
   cConvCCu := cCodCon
  Else 
   cConvCCu := "999"
  EndIf 
 Else
  DbSelectArea("SI3")
  DbSetOrder(1)
  If DbSeek(xFilial("SI3") + GetMV("MV_PREFCL") + cCodCon)
   cConvSI3 := cCodCon
  Else 
   cConvSI3 := "999"
  EndIf 
 EndIf
 
 rCentLuc := GetMV("MV_PREFCL") + AllTrim(SubStr(cCentLuc, GetMV("MV_TAMPREF") + 1)) + cConvCCu
 
 DbSelectArea(cAliasOld)
Return(rCentLuc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_RETKIT    ³ Autor ³ José Orfeu       ³ Data ³30/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Retorno itens do Kit                                       ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³  Código do Kit                                             ³±±
±±³Retorno   ³  Retorno                                                   ³±±
±±³             aCols   Com os itens do Kit                               ³±±
±±³             aHeader Com os campos do arquivo GAG gravados no aCols    ³±±
±±³             nUsado  Numero de colunas do aCols                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                               
Function HS_RetKit(cCodKit)
 Local aRetHead := {}, aRetCols := {}, cPesqKit := PadR(AllTrim(cCodKit), Len(GAG->GAG_CODKIT)), nFieldGag := 0
 Local cCampoGAG := "", cAliasOld := Alias()
 
 If Type("Inclui") == "U"
  Private Inclui := .F.
 EndIf 
 
 aRetCols := {}
 aRetHead := {}
 nRetUsad := 0
 DbSelectArea("SX3")
 DbSeek("GAG")
 While !Eof() .And. (SX3->X3_ARQUIVO == "GAG")
  If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
   nRetUsad++
   Aadd(aRetHead, {TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,;
                   SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, ;
                   SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, ;
                   SX3->X3_CONTEXT, SX3->X3_RELACAO, SX3->X3_RESERV})
   cCampoGAG  := "M->" + SX3->X3_CAMPO
   &cCampoGAG := CriaVar(SX3->X3_CAMPO)
  Endif                                                                          
  DbSkip()
 End

 DbSelectArea("GAG")
 DbSetOrder(1)
 DbSeek(xFilial("GAG") + cPesqKit)
 
 While !Eof() .And. xFilial("GAG") + cPesqKit == GAG->GAG_FILIAL + GAG->GAG_CODKIT
  DbSelectArea("SB1")
  DbSetOrder(1)
  DbSeek(xFilial("SB1") + GAG->GAG_CCOKIT)
  
  DbSelectArea("GBI")
  DbSetOrder(1)
  DbSeek(xFilial("GBI") + GAG->GAG_CCOKIT)
   
  DbSelectArea("GAG")
  M->GAG_CCOKIT := GAG->GAG_CCOKIT // Sera utilizado no inicializador padrão dos campos virtuais
  If GBI->GBI_PRODES # "0"
   aAdd(aRetCols, Array(nRetUsad + 1))
   aRetCols[Len(aRetCols), nRetUsad + 1] := .F.
   For nFieldGag := 1 to nRetUsad
    aRetCols[Len(aRetCols), nFieldGag] := If(aRetHead[nFieldGag, 10] # "V", FieldGet(FieldPos(aRetHead[nFieldGag, 02])), CriaVar(aRetHead[nFieldGag, 02]))
   Next
  Else 
   MsgStop(AllTrim(SB1->B1_COD) + " " + Alltrim(SB1->B1_DESC) + ", " + STR0024, STR0025) //"Produto Desativado"###"Atenção"
  Endif   
  DbSelectArea("GAG")
  DbSkip()
 Enddo
 DbSelectArea(cAliasOld)
Return({aRetCols, aRetHead, nRetUsad})
                     
// Grava no campo GA7_TABPRO as tabelas que o procedimento pertence
// buscando do arquivo GA8 - itens do procedmiento
Function HspGTPro()
 Processa({|| FS_GTProE()})
Return(Nil)                

Static Function FS_GTProE()                    
 Local cGa7_TabPro := ""
 If MsgYesNo(STR0084) //"Confirma atualização"
  DbSelectArea("GA7")
  DbGoTop() 
  ProcRegua(RecCount())
  While !Eof()
   IncProc(AllTrim(GA7->GA7_CODPRO) + "-" + AllTrim(GA7->GA7_DESC))
   DbSelectArea("GA8")
   DbSetOrder(1)
   DbSeek(xFilial("GA8") + GA7->GA7_CODPRO)
   cGa7_TabPro := ""
   While !Eof() .And. GA7->GA7_CODPRO == GA8->GA8_CODPRO
    cGa7_TabPro := cGa7_TabPro + IIF(!Empty(AllTrim(cGa7_TabPro)), "/", "") + GA8->GA8_TABPRO    
    DbSkip()
   End
   DbSelectArea("GA7")
   RecLock("GA7", .F.)
   GA7->GA7_TABPRO := cGa7_TabPro + "/"
   MsUnLock()
   DbSelectArea("GA7")
   DbSkip()
  End
 EndIf 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_MBrow     ³ Autor ³ Microsiga        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Monta Browse                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MBrow(oWndBrw, cAliasBrw, aCoord, cTopFun, cBotFun, cCpoSta, aResLeg, cCpoMar, aResMar, aItensMar, cCpoChave, bViewReg, lPesq, cFunMB, lBrowse, aColsBrw, cFunAM, aRotMB, aCIniBrw, lVirtual)
 Local oBrowse, oEnable, oDisable, nAlias, i, lUsado
 Local cField, cBranch, cValorCbx := ""
 Local cExpSta := "Empty(" + If(cCpoSta == Nil, "  ", cCpoSta) + ")"
 Local cExpMar := ""
 Local oCbx, aSix := {}, aCbx := {}, cOrd := Space(40), cCampo := Space(40), oBigGet
 Local nForBMB := 0, nColBMB := 0, cFunBMB := "", nFIniBrw := 0

 Default lVirtual := .F.
 
 Public __cHS_Marca := GetMark()                                                     
 
 lBrowse  := IIf(lBrowse  == Nil, .T., lBrowse )
 aColsBrw := IIf(aColsBrw == Nil,  {}, aColsBrw)
 aCIniBrw := IIf(aCIniBrw == Nil,  {}, aCIniBrw)
       
 If cCpoMar # Nil                                    
  If At("->", cCpoMar) == 0
   cExpMar := IIf(cCpoMar == Nil, "", cAliasBrw + "->" + cCpoMar + " == '" + __cHS_Marca + "'")
  Else                                                                                         
   cExpMar := IIf(cCpoMar == Nil, "", cCpoMar + " == '" + __cHS_Marca + "'")
  EndIf 
 EndIf 
 
 lPesq := IIF(lPesq == Nil, .T., lPesq)
 
 DbSelectArea("SIX")
 DbSeek(cAliasBrw)
 While !Eof() .And. SIX->INDICE == cAliasBrw
  If (lPesq .And. cTopFun == Nil .And. cBotFun == Nil) .Or. ;
     (lPesq .And. (cTopFun # Nil .Or. cTopFun # Nil) .And. HS_NInd(SIX->ORDEM) == &(cAliasBrw + "->(IndexOrd())"))
   aAdd(aSix, {SIX->DESCRICAO, HS_NInd(SIX->ORDEM)})
   aAdd(aCbx, SIX->DESCRICAO)
  EndIf 
  DbSkip()
 End
 
 If aResMar == Nil
  aResMar := {{"LBTIK", " "}, ;
              {"LBNO" , " "}}
 EndIf               
	
 nAlias := Select(cAliasBrw)        

 dbSelectArea(cAliasBrw)
 nAlias := Select()        
 
 cField := cAliasBrw + "->" + PrefixoCpo(cAliasBrw) + "_FILIAL"
 If !Empty(cTopFun)
  cField := IndexKey()
 EndIf

 cTopFun := xFilial(cAliasBrw) + IIF(cTopFun == Nil, "", &(cTopFun))
 cBotFun := xFilial(cAliasBrw) + IIF(cBotFun == Nil, "", &(cBotFun))
 
 oBrowse := TcBrowse():New(aCoord[1] + IIf(lPesq, 25, 0), aCoord[2], aCoord[3], aCoord[4],,,, oWndBrw, cField, cTopFun, cBotFun,, bViewReg,, oWndBrw:oFont,,,,, .F., cAliasBrw, .T.,, .F.,,,.F.)
 
 If Type(ReadVar()) <> "U" .And. !Empty(ReadVar()) .And. !Empty(&(ReadVar()))
  If !((cAliasBrw)->(DbSeek(xFilial(cAliasBrw) + AllTrim(&(ReadVar())))))
   DbGoTop()
  EndIf
 EndIf 
                                                      
 If lPesq
  @ aCoord[1]   , aCoord[2] COMBOBOX oCBX VAR cOrd ITEMS aCbx SIZE 196,36 PIXEL OF oWndBrw FONT oWndBrw:oFont

  oCbx:nAt := &(cAliasBrw + "->(IndexOrd())")

  @ aCoord[1]+12, aCoord[2] MSGET oBigGet VAR cCampo Valid (FS_SeekBrow(cAliasBrw, cCampo, oBrowse, oCbx, aSix)) SIZE 196,10 PIXEL OF oWndBrw
 EndIf         
 
If aRotMB # Nil
  nColBMB := 170
  For nForBMB := 1 To Len(aRotMB)          
   nColBMB += 32     
   If     aRotMB[nForBMB, 1] $ "Incluir" .And. ValType("Inclui") # "U" .And. ValType("Altera") # "U" // Incluir
    cFunBMB := &("{|| IncOld := Inclui, AltOld := Altera, Inclui := .T., Altera := .F., " + aRotMB[nForBMB, 2] + ", Inclui := IncOld, Altera := AltOld}")
   ElseIf aRotMB[nForBMB, 1] $ "Alterar" .And. ValType("Inclui") # "U" .And. ValType("Altera") # "U" // Alterar
    cFunBMB := &("{|| IncOld := Inclui, AltOld := Altera, Inclui := .F., Altera := .T., " + aRotMB[nForBMB, 2] + ", Inclui := IncOld, Altera := AltOld}")
   Else
    cFunBMB := &("{|| " + aRotMB[nForBMB, 2] + " }")
   EndIf
   tButton():New(aCoord[1]+11, aCoord[2]+nColBMB, aRotMB[nForBMB, 1], oWndBrw, cFunBMB, 30,,,,, .T.) //imprimir
  Next 
 EndIf         

 If cCpoMar # Nil
  oEnable  := LoadBitmap( GetResources(), aResMar[1][1] ) //"LBTIK"
  oDisable := LoadBitmap( GetResources(), aResMar[2][1] ) //"LBNO"
  oBrowse:AddColumn( TCColumn():New( "",{ || IF(&(cExpMar),oEnable,oDisable)},,,, "LEFT", 10, .T., .F.,,,, .T., ))
  oBrowse:BLDBLCLICK := {|| HS_DblClick(cAliasBrw, cCpoMar, __cHS_Marca, @aItensMar, cCpoChave, cFunMB, cFunAM)}
 EndIf
 
 If cCpoSta # Nil
  oEnable  := LoadBitmap( GetResources(), "ENABLE") 
  oDisable := LoadBitmap( GetResources(), "DISABLE")
  oBrowse:AddColumn( TCColumn():New( "",{ || IF(&(cExpSta), oEnable, oDisable)},,,, "LEFT", 10, .T., .F.,,,, .T., ))
 EndIf

 If aResLeg # Nil
  oBrowse:AddColumn( TCColumn():New( "",{ || HS_MBLeg(aResLeg)},,,, "LEFT", 10, .T., .F.,,,, .T., ))
 EndIf
 
 DbSelectArea("SX3")
 If Len(aCIniBrw) > 0
  DbSetOrder(2)
  For nFIniBrw := 1 To Len(aCIniBrw)
   If DbSeek(aCIniBrw[nFIniBrw])
    If SX3->X3_CONTEXT == "V"
     oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), WndIniBrw(SX3->x3_campo, nAlias), AllTrim(SX3->X3_PICTURE),,, if(SX3->X3_TIPO == "N", "RIGHT", "LEFT"), If(SX3->X3_TAMANHO > Len(SX3->X3_TITULO), 3 + (SX3->X3_TAMANHO * 3.7), 3 + (LEN(SX3->X3_TITULO) * 3.7)), .F., .F.,,,, .F.,))
    Else
     If !Empty(SX3->X3_CBOX)  
      cValorCbx := &("{|| HS_RDescrB('" + SX3->X3_CAMPO + "', " + cAliasBrw + "->" + SX3->X3_CAMPO + ")}")
      oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), cValorCbx, AllTrim(SX3->X3_PICTURE),,, if(SX3->X3_TIPO == "N", "RIGHT", "LEFT"), 3 + (LEN(SX3->X3_TITULO) * 3.7), .F., .F.,,,, .F.,))
     Else
      oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), FieldWBlock(SX3->x3_campo, nAlias), AllTrim(SX3->X3_PICTURE),,, if(SX3->X3_TIPO == "N", "RIGHT", "LEFT"), If(SX3->X3_TAMANHO > Len(SX3->X3_TITULO),3 + (SX3->X3_TAMANHO * 3.7),3 + (LEN(SX3->X3_TITULO) * 3.7)), .F., .F.,,,, .F.,))
     EndIf 
    EndIf
   EndIf 
  Next
 EndIf        
 
 dbSetOrder(1)
 dbSeek(cAliasBrw)
 While !EOF() .And. (SX3->x3_arquivo == cAliasBrw)
  If aScan(aCIniBrw, SX3->X3_CAMPO) == 0 .And. IIf(Len(aColsBrw) > 0, aScan(aColsBrw, SX3->X3_CAMPO) > 0, X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. IIf(lBrowse, SX3->X3_BROWSE == "S", .T.))
   If SX3->X3_CONTEXT == "V"
    If lVirtual
     oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), WndIniBrw(SX3->x3_campo, nAlias), AllTrim(SX3->x3_PICTURE),,, if(SX3->x3_TIPO == "N", "RIGHT", "LEFT"), If(SX3->x3_TAMANHO > Len(SX3->x3_TITULO), 3 + (SX3->x3_TAMANHO * 3.7), 3 + (LEN(SX3->x3_TITULO) * 3.7)), .F., .F.,,,, .F.,))
    EndIf 
   Else
    If !Empty(SX3->x3_CBOX)  
     cValorCbx := &("{|| HS_RDescrB('" + SX3->x3_CAMPO + "', " + cAliasBrw + "->" + SX3->x3_CAMPO + ")}")
     oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), cValorCbx, AllTrim(SX3->x3_PICTURE),,, if(SX3->x3_TIPO == "N", "RIGHT", "LEFT"), 3 + (LEN(SX3->x3_TITULO) * 3.7), .F., .F.,,,, .F.,))
    Else
     oBrowse:AddColumn(TCColumn():New(Trim(SX3->x3_titulo), FieldWBlock(SX3->x3_campo, nAlias), AllTrim(SX3->x3_PICTURE),,, if(SX3->x3_TIPO == "N", "RIGHT", "LEFT"), If(SX3->x3_TAMANHO > Len(SX3->x3_TITULO),3 + (SX3->x3_TAMANHO * 3.7),3 + (LEN(SX3->x3_TITULO) * 3.7)), .F., .F.,,,, .F.,))
    EndIf 
   EndIf
  Endif                                                 
  
  dbSkip()
 EndDo
 
 // Para não permitir que o ultimo campo fique com o valor escondido no grid
 oBrowse:AddColumn(TCColumn():New("", {|| }, "",,, "LEFT", 3, .F., .F.,,,, .F.,))

 dbSelectArea(cAliasBrw)
 oBrowse:Refresh()
 SysRefresh()
Return(oBrowse)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WndIniBrw     ³ Autor ³ Microsiga        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WndIniBrw(cCampo,cAlias)
 Local aArea := GetArea()
 DbSelectArea("SX3")
 DbSetOrder(2)
 DbSeek(cCampo)
 bBlock := &('{||' + SX3->x3_INIBRW + '}')
 SX3->(dbSetOrder(1))
 RestArea(aArea)
Return(bBlock)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_SeekBrow   ³ Autor ³ Microsiga        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SeekBrow(cAliasBrw, cCampo, oBrwPesq, oCbx, aSix)
 Local cAliasBrwOld := Alias()
 DbSelectArea(cAliasBrw)
 DbSetOrder(aSix[oCbx:nAt][2])
 If !DbSeek(xFilial(cAliasBrw) + RTrim(cCampo))
  MsgStop(STR0148,STR0025) //"Registro nao encontrado"###"Atencao"
  DbGoTop()
 EndIf 
 oBrwPesq:SetFocus()
 oBrwPesq:Refresh()
 DbSelectArea(cAliasBrwOld)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_VALATE    ³ Autor ³ José Orfeu       ³ Data ³03/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Calcula Total da Conta do Paciente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Retorno   ³ aTotAten := {0, ; // 1-Total de Honorarios Direto           ±±
±±           ³              0, ; // 2-Total de Honorarios Repasse          ±±
±±           ³              0, ; // 3-Total de Filmes para Raio X          ±±
±±           ³              0, ; // 4-Total de Raio X                      ±±
±±           ³              0, ; // 5-Total de Sangue                      ±±
±±           ³              0, ; // 6-Total de Procedimentos / Exames      ±±
±±           ³              0, ; // 7-Total de Mat/Med                     ±±
±±           ³              0, ; // 8-Total de Taxas e Diarias             ±±
±±           ³              0, ; // 9-Total Geral                          ±±
±±           ³              0, ; // 10-Desconto                            ±±
±±           ³              0}   // 11-Pgto Medico                         ±±
±±           ³                                                             ±±
±±           ³ Honorarios, Filmes, Raio X, Sangue e Exames                 ±±
±±           ³ aIProced := {"", ; // 1-Tipo do Procedimento                ±±
±±           ³              "", ; // 2-Codigo do Procedimento              ±±
±±           ³              "", ; // 3-Descrição do Procedimento           ±±
±±           ³               0, ; // 4-Valor do Procedimento com desconto  ±±
±±           ³               0, ; // 5-Valor do Procedimento sem desconto  ±±
±±           ³               0, ; // 6-Quantidade do Procedimento          ±±
±±           ³               0, ; // 7-Valor do Desconto                   ±±
±±           ³               0,}  // 8-Coeficiente de Despesa              ±±
±±           ³                                                             ±±
±±           ³ Materiais e Medicamentos                                    ±±
±±           ³ aIMatMed := {"", ; // 1-Codigo do Material / Medicamento    ±±
±±           ³              "", ; // 2-Descrição do Material / Medicamento ±±
±±           ³               0, ; // 3-Valor do Mat/Med com desconto       ±±
±±           ³               0, ; // 4-Valor do Mat/Med sem desconto       ±±
±±           ³               0, ; // 5-Quantidade do Material / Medicamento±±
±±           ³               0} ; // 6-Valor do Desconto                   ±±
±±           ³                                                             ±±
±±           ³ Taxas e Diarias                                             ±±
±±           ³ aITaxDia := {"", ; // 1-Codigo da Taxa / Diaria             ±±
±±           ³              "", ; // 2-Descrição da Taxa / Diaria          ±±
±±           ³               0, ; // 3-Valor da Taxa / Diaria com desconto ±±
±±           ³               0, ; // 4-Valor da Taxa / Diaria sem desconto ±±
±±           ³               0, ; // 5-Quantidade da Taxa / Diaria         ±±
±±           ³               0} ; // 6-Valor do Desconto                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ValAte(cGcy_RegAte, cModo, lPDirMed, cStatus)

Local lStatus	:= ( Valtype(cStatus) == "C" )
Local aTotAten := {0, ; // 01-Total de Honorarios Medicos
                   0, ; // 02-Total de Serviços Hospitalares
                   0, ; // 03-Total de Filmes para Raio X
                   0, ; // 04-Total de Raio X
                   0, ; // 05-Total de Sangue
                   0, ; // 06-Total de Procedimentos / Exames
                   0, ; // 07-Total de Mat/Med
                   0, ; // 08-Total de Taxas e Diarias
                   0, ; // 09-Total Geral
                   0, ; // 10-Total de desconto
                   0}   // 11-Total Pgto Med.

Local aIProced := {} //Honorarios, Filmes, Raio X, Sangue e Exames
Local aIMatMed := {} //Materiais e Medicamentos
Local aITaxDia := {} //Taxas e Diarias

Local cAliasOld	 := Alias()
Local vValPro		 := 0
Local vValTPro	 := 0
Local cPArq			 := ""
Local cAArq	     := ""
Local cPgtMed	   := "0"
Local tPDirMed	 := 0
Local nVPgtMed	 := 0
Local cMVCodFRx  := GetMv("MV_CODFRX")

Local aArea	:= {{cAliasOld, 0, 0}, {"GCY", 0, 0}, {"GA9", 0, 0}, {"GD7", 0, 0}, {"GE7", 0, 0}, {"GD6", 0, 0}, ;
                {"GE6"    , 0, 0}, {"GD5", 0, 0}, {"GE5", 0, 0}, {"GA7", 0, 0}, {"GBJ", 0, 0}}
								
HS_SavArea( aArea )								

cModo    := IIf(cModo    == Nil, "P", cModo   )
lPDirMed := IIf(lPDirMed == Nil, .T., lPDirMed)

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + cGCY_RegAte)

// Despesas com Honorarios
dbSelectArea("GCZ")
dbSetOrder(2)
dbSeek(xFilial("GCZ")+cGCY_RegAte)

While !Eof() .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE .and. xFilial("GCZ") == GCZ->GCZ_FILIAL

	If lStatus
		If ! ( GCZ->GCZ_STATUS $ cStatus )
			dbSkip()
			Loop
		EndIf
	EndIf

	cPArq := IIf(cModo == "P", "GD7->GD7", "GE7->GE7")
	cAArq := IIf(cModo == "P", "GD7"     , "GE7"     )

	DbSelectArea(cAArq)
	DbSetOrder(2)
	
	dbSeek(xFilial() + GCZ->GCZ_NRSEQG)
	While ! Eof() .and. ;
	 &(cPArq + "_FILIAL")  == xFilial(cAArq) .and. ;
	 &(cPArq + "_NRSEQG") == GCZ->GCZ_NRSEQG .And. ;
	 &(cPArq + "_DATDES") >= GCY->GCY_DATATE .and. ;
	 &(cPArq + "_DATDES") <= IIF(!Empty(GCY->GCY_DATALT), GCY->GCY_DATALT, dDataBase)
	 
		If &(cPArq + "_GLODES") # "0"
			DbSkip()
			Loop
		Endif
	
		DbSelectArea("GA7")
		DbSetOrder(1)
		DbSeek(xFilial("GA7") + &(cPArq + "_CODDES"))
	
//		vValTPro := &(cPArq + "_QTDDES") * (&(cPArq + "_VALDES") * &(cPArq + "_COEDES"))
  vValTPro := HS_CValDes(cAArq, &(cPArq + "_SEQDES"))
		vValPro  := &(cPArq + "_VALDES") 

	
		If GA7->GA7_HONORA == "1" // Honorarios Médicos
			aTotAten[1] += vValTPro
		Else                      // Serviços Hospitalares
			aTotAten[2] += vValTPro
		Endif
	
		If AllTrim(GA7->GA7_CODPRO) == AllTrim(cMVCodFRx)
			aTotAten[3] += &(cPArq + "_VALDES")
		Else
			aTotAten[3] += &(cPArq + "_QTDDES") * &(cPArq + "_VFILME")
		EndIf
	
		If     GA7->GA7_TIPPRO == "3" // Raio X e Filme
			aTotAten[4] += vValTPro
		ElseIf GA7->GA7_TIPPRO == "6" // Banco de Sangue
			aTotAten[5] += vValTPro
		Else                          // Procedimentos / Exames
			aTotAten[6] += vValTPro
		Endif
	
  //aTotAten[10] += &(cPArq + "_VALDES")

		If GA7->GA7_HONORA == "1"
			nVPgtMed := &(cPArq + "_VALREP")
			aTotAten[11] += nVPgtMed
			If cPgtMed == &(cPArq + "_PGTMED") // Direto
				tPDirMed += nVPgtMed
			EndIf
		EndIf
	
		aAdd(aIProced, {GA7->GA7_TIPPRO, ;
		                &(cPArq + "_CODDES"), ;
		                GA7->GA7_DESC  , ;
		                vValPro, ;
		                vValPro, ;
		                &(cPArq + "_QTDDES"), ;
		                &(cPArq + "_VALDES"), ;
		                &(cPArq + "_COEDES"), ;
		                &(cPArq + "_NRSEQG"), ; // &(cPArq + "_NROREC"), ; AQUI - QUAL O CAMPO CORRESPONDENTE? 
		                &(cPArq + "_DATDES"), ;
	                	&(cPArq + "_SEQDES")})
		
		DbSelectArea(cAArq)
		DbSkip()

	Enddo

	cPArq := IIf(cModo == "P", "GD5->GD5", "GE5->GE5")
	cAArq := IIf(cModo == "P", "GD5"     , "GE5"     )

	//Despesas com Mat/Med
	DbSelectArea(cAArq)
	DbSetOrder(2)
	DbSeek(xFilial(cAArq) + GCZ->GCZ_NRSEQG, .T.)
	While !Eof() .And. ;
	&(cPArq + "_FILIAL")  == xFilial(cAArq) .and. ;
	&(cPArq + "_NRSEQG") == GCZ->GCZ_NRSEQG .And. ;
	&(cPArq + "_DATDES") >= GCY->GCY_DATATE .And. ;
	&(cPArq + "_DATDES") <= GCY->GCY_DATALT
	
		If &(cPArq + "_GLOMAT") # "0"
			DbSkip()
			Loop
		Endif
	
//		aTotAten[7] += (&(cPArq + "_VALDES") * &(cPArq + "_QTDDES"))
  aTotAten[7] += HS_CValDes(cAArq, &(cPArq + "_SEQDES"))		
		
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1") + &(cPArq + "_CODDES")))
		
		aAdd(aIMatMed, {&(cPArq + "_CODDES"),;
							 SB1->B1_DESC,;
							 &(cPArq + "_VALDES"),;
							 &(cPArq + "_VALDES"),;
							 &(cPArq + "_QTDMAT"),;
							 0,;
							 &(cPArq + "_NRSEQG"),; // seria o numero da requisicao, que nao tem mais
							 &(cPArq + "_DATDES"),;
							 &(cPArq + "_SEQDES")})
		
  //aTotAten[10] += &(cPArq + "_VALDES") - NAO TEM DESCONTO NA TABELA NOVA
		
		DbSelectArea(cAArq)
		DbSkip()
	End
	
	cPArq := IIf(cModo == "P", "GD6->GD6", "GE6->GE6")
	cAArq := IIf(cModo == "P", "GD6"     , "GE6"     )
	
	// Despesas com Taxas e Diarias
	DbSelectArea(cAArq)
	DbSetOrder(2)
	DbSeek(xFilial(cAArq) + GCZ->GCZ_NRSEQG, .T.)
	While !Eof() .And. ;
	 &(cPArq + "_FILIAL") == xFilial(cAArq)  .and. ;
	 &(cPArq + "_NRSEQG") == GCZ->GCZ_NRSEQG .And. ;
	 &(cPArq + "_DATDES") >= GCY->GCY_DATATE .And. ; 
	 &(cPArq + "_DATDES") <= GCY->GCY_DATALT
	
		If &(cPArq + "_GLODES") # "0"
			DbSkip()
			Loop
		Endif
		
//		aTotAten[8] += (&(cPArq + "_VALDES") * &(cPArq + "_QTDDES"))
  aTotAten[8] += HS_CValDes(cAArq, &(cPArq + "_SEQDES"))		
		
		GAB->(DbSetorder(1))
		GAB->(DbSeek(xFilial("GAB") + &(cPArq + "_CODDES") + GCZ->GCZ_CODCON))
		
		aAdd(aITaxDia, {&(cPArq + "_CODDES"),;
							 GAB->GAB_DESC,;
							 &(cPArq + "_VALDES"),;
							 &(cPArq + "_VALDES"),;
							 &(cPArq + "_QTDDES"),;
							 0,;
							 &(cPArq + "_NRSEQG"),;
							 &(cPArq + "_DATDES"),;
							 &(cPArq + "_SEQDES")})
		
  //aTotAten[10] += &(cPArq + "_VALDES") NAO TEM DESCONTO
		
		DbSelectArea(cAArq)
		DbSkip()
	End
		
	dbSelectArea("GCZ")
	dbSkip()
	
Enddo

aTotAten[9] := aTotAten[3] + aTotAten[4] + aTotAten[5] + aTotAten[6] + aTotAten[7] + aTotAten[8]

If !lPDirMed
	aTotAten[9] -= tPDirMed
EndIf

// Restauro as areas utilizadas
HS_ResArea( aArea )

DbSelectArea(cAliasOld)
Return({aIProced, aIMatMed, aITaxDia, aTotAten})

*********************************************************************************************************
Function HS_IntLoja(cNrSeqG, cRegGer)
 Local lGravou := .F., cNumOrc := "", cMay := "", cTes := GetMV("MV_TESNFS"), cCodVend := GetMV("MV_VENDHSP")
 Local aSL1 := {}, aSL2 := {}, aTotAten := {}
 Local cTabPre := "1"
 Local cSb1Proc := GetMV("MV_SB1PROC")
 Local cSb1Imag := GetMV("MV_SB1IMAG")
 Local cSb1TaxD := GetMV("MV_SB1TAXD")
 Local cSb1MatM := GetMV("MV_SB1MATM")
 Local cPagHsp := GetMV("MV_CPAGHSP"), nCntParc := Len(Condicao(1000, cPagHsp))
 Local nVlrTotal, nVlrProc, nVlrImag, nVlrMatM, nVlrTaxD, aSL4 := {}
 Local aArea := GetArea() 
 Local nDiasValid := GETNEWPAR("MV_DIASVAL", 0)
 Local nVlDProc := 0, nVlDImag := 0, nVlDMatM := 0, nVlDTaxD := 0, nVlDTotal := 0
 Local lSurenN5 := GetNewPar("MV_SURENN5",.F.)
 Local nL2ITEM 	:= 1

 SF4->(DbSetOrder(1))
 SF4->(DbSeek(xFilial("SF4") + cTes))
 
 aTotAten := HS_ATEVAL(cNrSeqG)        
 
 nVlrProc := aTotAten[1]
 nVlDProc := aTotAten[5]
 
 nVlrImag := aTotAten[2]
 nVlDImag := aTotAten[6]
 
 nVlrMatM := aTotAten[3]
 nVlDMatM := aTotAten[7] 
 
 nVlrTaxD := aTotAten[4]
 nVlDTaxD := aTotAten[8] 
 
 nVlDTotal:= aTotAten[5] + aTotAten[6] + aTotAten[7] + aTotAten[8] //Total de Descontos
 nVlrTotal:= aTotAten[1] + aTotAten[2] + aTotAten[3] + aTotAten[4] //Total sem descontos
 
 dbSelectArea("GBH")
 dbSetOrder(1)
 dbSeek(xFilial("GBH") + cRegGer)
 
 DbSelectArea("SA1")
 DbSetOrder(1)
 DbSeek(xFilial("SA1") + GBH->GBH_CODCLI + GBH->GBH_LOJA)
 
 DbSelectArea("SL1")
 // A CriaVar do L1_NUM ira chamar a GetSxeNum()
 cNumOrc := CriaVar("L1_NUM")
 
 // Caso o SXE e o SXF estejam corrompidos o numero do orcamento estava se repetindo.
 cMay := Alltrim(xFilial("SL1")) + cNumOrc
 FreeUsedCode()
 SL1->(dbSetOrder(1))
 
 // Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
 nTent := 0
 While SL1->(dbSeek(xFilial("SL1") + cNumOrc)) .Or. !MayIUseCode(cMay)
 	If ++nTent > 20
 		MsgStop(STR0087) //"Impossivel gerar número sequencial de orçamento correto. Informe ao administrador do sistema."
 		Return(.F.)
 	Endif
 	ConfirmSx8()
 	cNumOrc := CriaVar("L1_NUM")
 	FreeUsedCode()
 	cMay := Alltrim(xFilial("SL1")) + cNumOrc
 End
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o array aSL1                                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aAdd(aSL1, {"L1_FILIAL" , xFilial("SL1")})
 aAdd(aSL1, {"L1_EMISSAO", dDataBase     })
 aAdd(aSL1, {"L1_NUM"    , cNumOrc       })
 aAdd(aSL1, {"L1_COMIS"  , 0             })
 aAdd(aSL1, {"L1_CLIENTE", SA1->A1_COD   })
 aAdd(aSL1, {"L1_LOJA"   , SA1->A1_LOJA  })
 aAdd(aSL1, {"L1_TIPOCLI", SA1->A1_TIPO  })
 aAdd(aSL1, {"L1_DESCONT", 0             })
 aAdd(aSL1, {"L1_DESCNF" , 0             })
 aAdd(aSL1, {"L1_DTLIM"  , dDataBase + nDiasValid })
 aAdd(aSL1, {"L1_CONDPG" , cPagHsp       })
 aAdd(aSL1, {"L1_PARCELA", nCntParc      })
 aAdd(aSL1, {"L1_FORMPG" , "R$"          })
 aAdd(aSL1, {"L1_CONFVEN", "SSSSSSSSNSSS"})
 aAdd(aSL1, {"L1_HORA"   , Time()        })
 aAdd(aSL1, {"L1_TPFRET" , ""            })
 aAdd(aSL1, {"L1_IMPRIME", "1N"          })
 aAdd(aSL1, {"L1_TIPODES", "0"           })
 aAdd(aSL1, {"L1_VEND"   , cCodVend      })
 If Hs_ExisDic({{"C", "L1_IMPNF"}}, .F.)
 	aAdd(aSL1, {"L1_IMPNF"   , .T.      }) 
 EndIf
 
 MaFisEnd()
 MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", Nil, Nil, Nil, .F., "SB1", "LOJA701")

 // Adiciona Procedimentos
 If nVlrProc > 0
 	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial("SB1") + cSb1Proc))
 	
 	GA7->(DbSetOrder(1))
 	GA7->(DbSeek(xFilial("GA7") + cSb1Proc))
 	
 	MaFisAdd(cSb1Proc, ; // Produto
 	         cTes    , ;	// Tes
 	         1       , ; // Quantidade
 	         nVlrProc - nVlDProc, ; // Preco unitario ja com desconto
 	         nVlDProc, ; // Valor do desconto
 	         ""      , ; // Numero da NF original
 	         ""      , ; // Serie da NF original
 	         0       , ;	// Recno da NF original
 	         0       , ; // Valor do frete do item
 	         0       , ; // Valor da despesa do item
 	         0       , ; // Valor do seguro do item
 	         0       , ; // Valor do frete autonomo
 	         nVlrProc, ; // Valor da mercadoria sem desconto
 	         0)				      // Valor da embalagem
 	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Monta o array aSL2                                                       ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	aAdd(aSL2, {})
 	aAdd(aSL2[Len(aSL2)], {"L2_FILIAL" , xFilial("SL2")       })
 	aAdd(aSL2[Len(aSL2)], {"L2_NUM"    , cNumOrc              })
 	aAdd(aSL2[Len(aSL2)], {"L2_ITEM"   , STRZERO(nL2ITEM++,2)   })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRODUTO",	cSb1Proc             })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCRI" , Iif(GA7->(Found()),GA7->GA7_DESC,SB1->B1_DESC)}) //GA7->GA7_DESC
 	aAdd(aSL2[Len(aSL2)], {"L2_QUANT"  , 1})
 	aAdd(aSL2[Len(aSL2)], {"L2_VRUNIT" , nVlrProc - nVlDProc})
 	aAdd(aSL2[Len(aSL2)], {"L2_VLRITEM", nVlrProc - nVlDProc})
 	aAdd(aSL2[Len(aSL2)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
 	aAdd(aSL2[Len(aSL2)], {"L2_UM"     , SB1->B1_UM           })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESC"   , IIF(nVlDProc == 0, 0, (nVlDProc / nVlrProc) * 100)})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALDESC", nVlDProc})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCPRO", 0                    })
 	aAdd(aSL2[Len(aSL2)], {"L2_TES"    , cTes                 })
 	aAdd(aSL2[Len(aSL2)], {"L2_CF"     , SF4->F4_CF           })
 	aAdd(aSL2[Len(aSL2)], {"L2_EMISSAO", dDataBase            })
 	aAdd(aSL2[Len(aSL2)], {"L2_GRADE"  , "N"                  })
 	aAdd(aSL2[Len(aSL2)], {"L2_VEND"   ,	cCodVend             })
 	aAdd(aSL2[Len(aSL2)], {"L2_TABELA" ,	cTabPre              })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRCTAB" , nVlrProc})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
 	aAdd(aSL2[Len(aSL2)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
 	If SL2->(FieldPos("L2_BRICMS")) > 0
 		aAdd(aSL2[Len(aSL2)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
 	Endif
 	If SL2->(FieldPos("L2_ICMSRET")) > 0
 		aAdd( aSL2[Len(aSL2)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
 	Endif
 EndIf

 // Adiciona Imagens caso parametro MV_SURENN5 Igual a TRUE. 
 // Caso contrario eh acicionado nos procedimentos acima.
 // Esta regra tambem eh definida na funcao HS_AteVal
 If nVlrImag > 0 .AND. lSurenN5
 	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial("SB1") + cSb1Imag))
 	
 	GA7->(DbSetOrder(1))
 	GA7->(DbSeek(xFilial("GA7") + cSb1Imag))
 	
 	MaFisAdd(cSb1Imag, ; // Produto
 	         cTes    , ;	// Tes
 	         1       , ; // Quantidade
 	         nVlrImag - nVlDImag, ; // Preco unitario ja com desconto
 	         nVlDImag, ; // Valor do desconto
 	         ""      , ; // Numero da NF original
 	         ""      , ; // Serie da NF original
 	         0       , ;	// Recno da NF original
 	         0       , ; // Valor do frete do item
 	         0       , ; // Valor da despesa do item
 	         0       , ; // Valor do seguro do item
 	         0       , ; // Valor do frete autonomo
 	         nVlrImag, ; // Valor da mercadoria sem desconto
 	         0)		     // Valor da embalagem
 	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Monta o array aSL2                                                       ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	aAdd(aSL2, {})
 	aAdd(aSL2[Len(aSL2)], {"L2_FILIAL" , xFilial("SL2")       })
 	aAdd(aSL2[Len(aSL2)], {"L2_NUM"    , cNumOrc              })
 	aAdd(aSL2[Len(aSL2)], {"L2_ITEM"   , STRZERO(nL2ITEM++,2) })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRODUTO", cSb1Imag             })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCRI" , Iif(GA7->(Found()),GA7->GA7_DESC,SB1->B1_DESC)}) //GA7->GA7_DESC
 	aAdd(aSL2[Len(aSL2)], {"L2_QUANT"  , 1})
 	aAdd(aSL2[Len(aSL2)], {"L2_VRUNIT" , nVlrImag - nVlDImag})
 	aAdd(aSL2[Len(aSL2)], {"L2_VLRITEM", nVlrImag - nVlDImag})
 	aAdd(aSL2[Len(aSL2)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
 	aAdd(aSL2[Len(aSL2)], {"L2_UM"     , SB1->B1_UM           })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESC"   , IIF(nVlDImag == 0, 0, (nVlDImag / nVlrImag) * 100)})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALDESC", nVlDImag})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCPRO", 0                    })
 	aAdd(aSL2[Len(aSL2)], {"L2_TES"    , cTes                 })
 	aAdd(aSL2[Len(aSL2)], {"L2_CF"     , SF4->F4_CF           })
 	aAdd(aSL2[Len(aSL2)], {"L2_EMISSAO", dDataBase            })
 	aAdd(aSL2[Len(aSL2)], {"L2_GRADE"  , "N"                  })
 	aAdd(aSL2[Len(aSL2)], {"L2_VEND"   , cCodVend             })
 	aAdd(aSL2[Len(aSL2)], {"L2_TABELA" , cTabPre              })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRCTAB" , nVlrImag})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
 	aAdd(aSL2[Len(aSL2)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
 	If SL2->(FieldPos("L2_BRICMS")) > 0
 		aAdd(aSL2[Len(aSL2)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
 	Endif
 	If SL2->(FieldPos("L2_ICMSRET")) > 0
 		aAdd( aSL2[Len(aSL2)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
 	Endif
 EndIf
 
 If nVlrMatM > 0
 	// Adcionando Materias e Medicamentos
 	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial("SB1") + cSb1MatM))
 	MaFisAdd(cSb1MatM, ; // Produto
 	         cTes    , ;	// Tes
 	         1       , ; // Quantidade
 	         nVlrMatM - nVlDMatM, ; // Preco unitario ja com desconto
 	         nVlDMatM, ; // Valor do desconto
 	         ""      , ; // Numero da NF original
 	         ""      , ; // Serie da NF original
 	         0       , ; // Recno da NF original
 	         0       , ; // Valor do frete do item
 	         0       , ; // Valor da despesa do item
 	         0       , ; // Valor do seguro do item
 	         0       , ; // Valor do frete autonomo
 	         nVlrMatM, ; // Valor da mercadoria sem desconto
 	         0)	         // Valor da embalagem
 	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Monta o array aSL2                                                       ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	aAdd(aSL2, {})
 	aAdd(aSL2[Len(aSL2)], {"L2_FILIAL" , xFilial("SL2")       })
 	aAdd(aSL2[Len(aSL2)], {"L2_NUM"    , cNumOrc              })
 	aAdd(aSL2[Len(aSL2)], {"L2_ITEM"   ,STRZERO(nL2ITEM++,2)  })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRODUTO",	cSb1MatM})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCRI" , SB1->B1_DESC})
 	aAdd(aSL2[Len(aSL2)], {"L2_QUANT"  , 1})
 	aAdd(aSL2[Len(aSL2)], {"L2_VRUNIT" , nVlrMatM - nVlDMatM})
 	aAdd(aSL2[Len(aSL2)], {"L2_VLRITEM", nVlrMatM - nVlDMatM})
 	aAdd(aSL2[Len(aSL2)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
 	aAdd(aSL2[Len(aSL2)], {"L2_UM"     , SB1->B1_UM           })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESC"   , IIF(nVlDMatM == 0, 0,(nVlDMatM / nVlrMatM) * 100)})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALDESC", nVlDMatM})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCPRO", 0                    })
 	aAdd(aSL2[Len(aSL2)], {"L2_TES"    , cTes                 })
 	aAdd(aSL2[Len(aSL2)], {"L2_CF"     , SF4->F4_CF           })
 	aAdd(aSL2[Len(aSL2)], {"L2_EMISSAO", dDataBase            })
 	aAdd(aSL2[Len(aSL2)], {"L2_GRADE"  , "N"                  })
 	aAdd(aSL2[Len(aSL2)], {"L2_VEND"   ,	cCodVend             })
 	aAdd(aSL2[Len(aSL2)], {"L2_TABELA" ,	cTabPre              })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRCTAB" , nVlrMatM})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
 	aAdd(aSL2[Len(aSL2)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
 	If SL2->(FieldPos("L2_BRICMS")) > 0
 		aAdd(aSL2[Len(aSL2)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
 	Endif
 	If SL2->(FieldPos("L2_ICMSRET")) > 0
 		aAdd( aSL2[Len(aSL2)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
 	Endif
 EndIf

 If nVlrTaxD > 0
 	// Adcionando Taxas e Diarias
 	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial("SB1") + cSb1TaxD))
 	
 	GAA->(DbSetOrder(1))
 	GAA->(DbSeek(xFilial("GAA") + cSb1TaxD))
 	
 	//If MaFisFound("NF")
 	MaFisAdd(cSb1TaxD, ; // Produto
 	         cTes    , ; // Tes
 	         1       , ; // Quantidade
 	         nVlrTaxD - nVlDTaxD, ; // Preco unitario ja com desconto
 	         nVlDTaxD, ; // Valor do desconto
 	         ""      , ; // Numero da NF original
 	         ""      , ; // Serie da NF original
 	         0       , ; // Recno da NF original
 	         0       , ; // Valor do frete do item
 	         0       , ; // Valor da despesa do item
 	         0       , ; // Valor do seguro do item
 	         0       , ; // Valor do frete autonomo
 	         nVlrTaxD, ; // Valor da mercadoria sem desconto
 	         0)	         // Valor da embalagem
 	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Monta o array aSL2                                                       ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	aAdd(aSL2, {})
 	aAdd(aSL2[Len(aSL2)], {"L2_FILIAL" , xFilial("SL2")       })
 	aAdd(aSL2[Len(aSL2)], {"L2_NUM"    , cNumOrc              })
 	aAdd(aSL2[Len(aSL2)], {"L2_ITEM"   , STRZERO(nL2ITEM++,2) })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRODUTO",	cSb1TaxD             })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCRI" , GAA->GAA_DESC}) //aIMatMed[nITaxDia, 2]})
 	aAdd(aSL2[Len(aSL2)], {"L2_QUANT"  , 1})
 	aAdd(aSL2[Len(aSL2)], {"L2_VRUNIT" , nVlrTaxD - nVlDTaxD})
 	aAdd(aSL2[Len(aSL2)], {"L2_VLRITEM", nVlrTaxD - nVlDTaxD})
 	aAdd(aSL2[Len(aSL2)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
 	aAdd(aSL2[Len(aSL2)], {"L2_UM"     , SB1->B1_UM           })
 	aAdd(aSL2[Len(aSL2)], {"L2_DESC"   , IIF(nVlDTaxD == 0, 0,(nVlDTaxD / nVlrTaxD) * 100)})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALDESC", nVlDTaxD})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESCPRO", 0                    })
 	aAdd(aSL2[Len(aSL2)], {"L2_TES"    , cTes                 })
 	aAdd(aSL2[Len(aSL2)], {"L2_CF"     , SF4->F4_CF           })
 	aAdd(aSL2[Len(aSL2)], {"L2_EMISSAO", dDataBase            })
 	aAdd(aSL2[Len(aSL2)], {"L2_GRADE"  , "N"                  })
 	aAdd(aSL2[Len(aSL2)], {"L2_VEND"   ,	cCodVend             })
 	aAdd(aSL2[Len(aSL2)], {"L2_TABELA" ,	cTabPre              })
 	aAdd(aSL2[Len(aSL2)], {"L2_PRCTAB" , nVlrTaxD})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
 	aAdd(aSL2[Len(aSL2)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
 	aAdd(aSL2[Len(aSL2)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
 	aAdd(aSL2[Len(aSL2)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
 	If SL2->(FieldPos("L2_BRICMS")) > 0
 		aAdd(aSL2[Len(aSL2)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
 	Endif
 	If SL2->(FieldPos("L2_ICMSRET")) > 0
 		aAdd( aSL2[Len(aSL2)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
 	Endif
 EndIf
 
 aAdd(aSL1, {"L1_VLRTOT" , IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal)})
 aAdd(aSL1, {"L1_VLRLIQ" , IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal - nVlDTotal)})
 aAdd(aSL1, {"L1_VALBRUT", IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal)})
 aAdd(aSL1, {"L1_VALMERC", IIf(MaFisRet(, "NF_VALMERC") > 0, MaFisRet(, "NF_VALMERC"), nVlrTotal - nVlDTotal)})
 aAdd(aSL1, {"L1_DINHEIR", IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal - nVlDTotal)})
 aAdd(aSL1, {"L1_VALICM" , IIf(MaFisRet(, "NF_VALICM" ) > 0, MaFisRet(, "NF_VALICM" ), nVlrTotal - nVlDTotal)})
 aAdd(aSL1, {"L1_VALIPI" , IIf(MaFisRet(, "NF_VALIPI" ) > 0, MaFisRet(, "NF_VALIPI" ), nVlrTotal - nVlDTotal)})
 aAdd(aSL1, {"L1_VALISS" , IIf(MaFisRet(, "NF_VALISS" ) > 0, MaFisRet(, "NF_VALISS" ), nVlrTotal - nVlDTotal)})
 If SL1->(FieldPos("L1_BRICMS")) > 0
 	aAdd(aSL1, {"L1_BRICMS",	IIf(MaFisRet(, "NF_BASESOL") > 0, MaFisRet(, "NF_BASESOL"), nVlrTotal - nVlDTotal)})
 Endif
 If SL1->(FieldPos("L1_ICMSRET")) > 0
 	aAdd(aSL1, {"L1_ICMSRET", IIf(MaFisRet(, "NF_VALSOL") > 0, MaFisRet(, "NF_VALSOL" ), nVlrTotal - nVlDTotal)})
 Endif
//Grava tabela SL4
 aAdd(aSL4, {})
 aAdd(aSL4[Len(aSL4)], {"L4_NUM    ", cNumOrc       })
 aAdd(aSL4[Len(aSL4)], {"L4_DATA   ", dDataBase     })
 aAdd(aSL4[Len(aSL4)], {"L4_VALOR  ", IIf(MaFisRet(, "NF_VALMERC") > 0, MaFisRet(, "NF_VALMERC"), nVlrTotal - nVlDTotal)})  // Valor 
 aAdd(aSL4[Len(aSL4)], {"L4_FORMA  ", "R$"          })
 
 /************************************************
 / Ponto de Entrada para alterar a gravação 
 / dos itens da tabela SL2(Loja) - Chamado TPHXCH
 /************************************************/ 
If Existblock("HSSL2")
	aSL2 := Execblock("HSSL2", .F., .F., aSL2)
Endif
 lGravou := Lj7GrvOrc(aSL1, aSL2, aSL4)[1]
 MaFisEnd()
 If lGravou
 	DbSelectArea("GCZ")
 	DbSetorder(1)
 	If cNrSeqG == GCZ->GCZ_NRSEQG .Or. DbSeek(xFilial("GCZ") + cNrSeqG)
 	
		RecLock("GCZ", .F.)
			GCZ->GCZ_NUMORC := cNumOrc
		MsUnLock()

		If ExistBlock("HSGEROR")
 			ExecBlock("HSGEROR", .F., .F., {cNumOrc})
	 	EndIf
 	 
 	EndIf
 EndIf

 RestArea(aArea)
Return(lGravou)

Function HS_AMemos(cAliasSx3)
 Local aHS_Memos := {}
 Local cAliasOld := Alias() 
 Local nOrderSx3, nRecSx3, nCodObsF
 DbSelectArea("SX3")     
 nOrderSx3 := IndexOrd()
 DbSetOrder(1)        
 nRecSx3 := RecNo()
 DbSeek(cAliasSx3)
 While !Eof() .and. SX3->X3_ARQUIVO == cAliasSx3
  If SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M"
   If (nCodObs := AT(cAliasSx3 + "_", SX3->X3_RELACAO)) > 0
    nCodObsF := At(",", SX3->X3_RELACAO)
    If nCodObsF == 0
     nCodObsF := At(")", SX3->X3_RELACAO)
    EndIf 
    nCodObsF := nCodObsF - (nCodObs - 1) - 1
    aAdd(aHs_Memos, {Upper(AllTrim(SubStr(SX3->X3_RELACAO, nCodObs, nCodObsF))), AllTrim(SX3->X3_CAMPO)})
   EndIf 
  EndIf 
  DbSkip()
 End                    
 DbGoTo(nRecSx3)
 DbSetOrder(nOrderSx3)
 DbSelectArea(cAliasOld)
Return(aHs_Memos)

Function HS_ParHsp(cAlias)
 MSGALERT("Essa rotina foi descontinuada. Para fazer alterações nos parâmetros utilize o Configurador (SIGACFG).","Rotina Descontinuada")
Return(Nil)             


// Retorna a Descrição da opçao dos campos combobox
Function HS_RDescrB(cCampo, cOpcao)

 Local cAlias := Alias(), nIndSx3 := 0, cRet := "", nRecSx3 := 0
 
 If !Empty(AllTrim(cOpcao)) 
 
  DbSelectArea("SX3")                  
  nIndSx3 := IndexOrd()                                          
  nRecSx3 := RecNo()
  DbSetOrder(2)
  DbSeek(cCampo)

  If !Empty(cRet := IIF(At("#", SX3->X3_CBOX) > 0, SubStr(SX3->X3_CBOX, 2), ""))
   cRet := &(cRet)
   cRet := SubStr(cRet, At(cOpcao + "=", cRet) + Len(cOpcao + "="))        
   cRet := IIF(At(";", cRet) > 0, SubStr(cRet, 1, At(";", cRet) - 1), cRet)   
  Else 
   // Pega opcao do sinal de igualdade ate o fim da opcao
   cRet := SubStr(SX3->X3_CBOX, At(cOpcao + "=", SX3->X3_CBOX) + Len(cOpcao + "="))
   cRet := IIF(At(";", cRet) > 0, SubStr(cRet, 1, At(";", cRet) - 1), cRet)
  EndIf
   
  DbSetOrder(nIndSx3)
  DbGoTo(nRecSx3)
  DbSelectArea(cAlias)
  
 EndIf           	
 
Return(cRet)


Function Calc_Anos(DatIni, DatFin)
 /*
  Objetivo  : Calcular intervalo de tempo em anos, com precisÆo, entre
              duas datas informadas.
  Parametros: datini -> data inicial para c lculo (ex: nascimento)
              datfin -> data final para c lculo   (normalmente DATE())
  Retorno   : g_anos -> intervalo de tempo calculado em anos.
 */
 LOCAL g_anos:=0
 LOCAL mesini:=0
 LOCAL diaini:=0
 LOCAL mesfin:=0
 LOCAL diafin:=0
 
 IF datini == NIL
  //Alarme(1)
  //Mensagem("CALC_ANOS: falta parametro n§ 1 ...",3)
  RETURN(0)
 ENDIF

 IF datfin == NIL
  //Alarme(1)
  //Mensagem("CALC_ANOS: falta parametro n§ 2 ...",3)
  RETURN(0)
 ENDIF

 IF datfin < datini
  //Alarme(1)
  //Mensagem("CALC_ANOS: data final < data inicial ...",3)
  RETURN(0)
 ENDIF

 g_anos := YEAR(datfin) - YEAR(datini)
 mesini := MONTH(datini)
 diaini := DAY(datini)
 mesfin := MONTH(datfin)
 diafin := DAY(datfin)
 
 WHILE .T.
  IF mesfin < mesini
   g_anos := g_anos - 1
   EXIT
  ELSEIF mesfin = mesini
   IF diafin < diaini
    g_anos := g_anos - 1
   ENDIF
   EXIT
  ENDIF
  EXIT
 ENDDO
RETURN(g_anos)

Function HS_DblClick(cAliasBrw, cCpoMar, cMarca, aItensMar, cCpoChave, cFunMB, cFunAM)
 Local cAliasOld := Alias(), nPosVet := 0
 Local cCpoGrv := cAliasBrw + "->" + cCpoMar                         
                                                                                     
 cFunAM := IIf(cFunAM # Nil, cFunAM + "('" + cMarca + "')", "")
 If !Empty(cFunAM)
  If !&(cFunAM)
   Return(.F.)
  EndIf 
 EndIf
 
 DbSelectArea(cAliasBrw)
 RecLock(cAliasBrw, .F.)
 &(cCpoGrv) := IIf(&(cCpoGrv) == cMarca, Space(Len(cCpoGrv)), cMarca)
 MsUnLock()                             
                  
 nPosVet := aScan(aItensMar, {|aVet| aVet[1] == &(cCpoChave)})
  
 If !Empty(&cCpoGrv)      
  If nPosVet == 0
   aAdd(aItensMar, {&(cCpoChave), cMarca})
  Else 
   aItensMar[nPosVet][2] := cMarca
  EndIf 
 Else                                    
  aDel(aItensMar, nPosVet)
  aSize(aItensMar, Len(aItensMar) - 1)
 EndIf 

 cFunMB := IIf(cFunMB # Nil, cFunMB + "('" + cMarca + "')", "")
 If !Empty(cFunMB)
  &(cFunMB)
 EndIf                  
 
 DbSelectArea(cAliasOld)
Return(.T.)

Function HS_MBLeg(aResLeg)
 Local oMBLeg, nLeg := 1
 For nLeg := 1 To Len(aResLeg)
  If &(aResLeg[nLeg][1])
   oMBLeg := LoadBitmap(GetResources(), aResLeg[nLeg][2])
   Exit
  EndIf 
 Next 
Return(oMBLeg)

Function HS_DesMMP(cOriMMP, cCodTes, cCodMMp)
 Local cRet := ""
 If     cOriMMP == "0" // Material e Medicamentos
  cRet := Posicione("SB1", 1, xFilial("SB1") + cCodMMP, "B1_DESC")
 ElseIf cOriMMP == "1" // Procedimentos                           
  cRet := Posicione("GA7", 1, xFilial("GA7") + cCodMMP, "GA7_DESC")
 ElseIf cOriMMP == "2" // Taxas/Diarias                            
  cRet := Posicione("GAA", 1, xFilial("GAA") + cCodMMP, "GAA_DESC")
 EndIf
Return(cRet)      
               
// Retorna a quantidade de auxiliares do procedimento
Function HS_QtdAux(cCodPro, cTabPro, dVigencia)
 Local nQtdAux := 0, cAliasOld := Alias(), nIndGa8 := GA8->(IndexOrd()), nIndGa7 := GA7->(IndexOrd())
 Local aRVldVig := {{0, "GA8_QTDAUX"}}
                   
 Default dVigencia := dDataBase
 
 If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + cTabPro + "' AND GA8_CODPRO = '" + cCodPro + "'", "GA8_DATVIG", @aRVldVig, dVigencia)
  nQtdAux := aRVldVig[1][1]
 EndIf 
 
 If nQtdAux == 0
  DbSelectArea("GA7")
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + PadR(AllTrim(cCodPro), Len(GA7->GA7_CODPRO)))
  nQtdAux := GA7->GA7_QTDAUX
 EndIf 
 
 DbSelectArea("GA8")
 DbSetOrder(nIndGa8)
                    
 DbSelectArea("GA7")
 DbSetOrder(nIndGa7)
 
 DbSelectArea(cAliasOld)
Return(nQtdAux)

// Retorna o codigo do porte anestesico do procedimento
Function HS_CodPan(cCodPro, cTabPro, dVigencia)
 Local cCodPan := Space(Len(GA3->GA3_CODPAN)), cAliasOld := Alias(), nIndGa8 := GA8->(IndexOrd()), nIndGa7 := GA7->(IndexOrd())
 Local aRVldVig := {{0, "GA8_CODPAN"}}
                   
 Default dVigencia := dDataBase                   
 
 If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + cTabPro + "' AND GA8_CODPRO = '" + cCodPro + "'", "GA8_DATVIG", @aRVldVig, dVigencia)
  cCodPan := aRVldVig[1][1]
 EndIf 
 
 If Empty(AllTrim(cCodPan))
  DbSelectArea("GA7")
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + PadR(AllTrim(cCodPro), Len(GA7->GA7_CODPRO)))
  cCodPan := GA7->GA7_CODPAN
 EndIf 
 
 DbSelectArea("GA8")
 DbSetOrder(nIndGa8)
                    
 DbSelectArea("GA7")
 DbSetOrder(nIndGa7)
 
 DbSelectArea(cAliasOld)
Return(cCodPan)

Function HS_PAnest(cTabPro, cCodPan)
 Local cAliasOld := Alias()
 Local nQtChAn := 0, cMv_CTabPr := GetMV("MV_CTABPR")
 Local cCodTxd := 0
 
 DbSelectArea("GA3")
 DbSetOrder(1)          
 DbSeek(xFilial("GA3") + PadR(cTabPro, Len(GA3->GA3_TABPRO)) + PadR(cCodPan, Len(GA3->GA3_CODPAN)))
 If Found()
  nQtChAn := GA3->GA3_CHSPAN                         
  cCodTxd := GA3->GA3_CODTXD
 Else
  // cTabPro    == Código da Tabela que esta configurada no GA7 Cabeçalho de Procedimentos
  // cMv_CTabPr == Código da Tabela que esta configurada no parametro MV_CTABPR
  // Caso não encontre o Porte Anestesico para a Tabela cTabPro pesquiza com cMv_CTabPro parametro que
  // contem o código da Tabela de Procedimento padrão para calculo do porte anestesico
  DbSelectArea("GA3")
  DbSetOrder(1)          
  DbSeek(xFilial("GA3") + PadR(cMv_CTabPr, Len(GA3->GA3_TABPRO)) + PadR(cCodPan, Len(GA3->GA3_CODPAN)))
  nQtChAn := GA3->GA3_CHSPAN
  cCodTxd := GA3->GA3_CODTXD
 EndIf 
 DbSelectArea(cAliasOld)
Return({nQtChAn, cCodTxd})

// Salva ordem e registros da area 
Function HS_SavArea(aArea)
 Local nArea := 1
 For nArea := 1 To Len(aArea)
  aArea[nArea, 2] := &(aArea[nArea, 1] + "->(IndexOrd())")
  aArea[nArea, 3] := &(aArea[nArea, 1] + "->(RecNo())")
 Next 
Return(aArea)
                                   
// Restaura ordem e registros da area 
Function HS_ResArea(aArea)
 Local nArea := 1
 For nArea := 1 To Len(aArea)
  &(aArea[nArea, 1] + "->(DbSetOrder(" + AllTrim(Str(aArea[nArea, 2])) + "))")
  &(aArea[nArea, 1] + "->(DbGoTo(" + AllTrim(Str(aArea[nArea, 3])) + "))")
 Next 
Return(Nil)                                 

/*            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_RevCnt    ³ Autor ³ Jose orfeu       ³ Data ³13/11/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Revaloriza Contas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³parametros³  cNrSeqG - Numero da guia                                  ³±±
±±³          ³  dDatIni - Data inicial do processamento                   ³±±
±±³          ³  dDatFin - Data final do processamento                     ³±±
±±³          ³  cPlaOld - Plano atual da guia                             ³±±
±±³          ³  cPlaNew - Novo plano da guia                              ³±±
±±³          ³  lRevMat - .T. Revaloriza, .F. não revaloriza materiais    ³±±
±±³          ³  lRevMed - .T. Revaloriza, .F. não revaloriza medicamentos ³±±
±±³          ³  lRevRes - .T. Revaloriza, .F. não revaloriza restaur/frig ³±±
±±³          ³  lRevTax - .T. Revaloriza, .F. não revaloriza taxas        ³±±
±±³          ³  lRevDia - .T. Revaloriza, .F. não revaloriza diarias      ³±±
±±³          ³  lRevPro - .T. Revaloriza, .F. não revaloriza procedimentos³±±
±±³          ³  lUltPrc - .T. Desconsidera a data do lancamento da despesa³±±
±±³          ³            e usa a data base para calculo da vigencia.     ³±±
±±³          ³            .F. Considera a data do lancamento da despesa p/³±±
±±³          ³            calculo da vigencia.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                     
*/
Function HS_RevCnt(cNrSeqG, dDatIni, dDatFin, cPlaOld, cPlaNew, lRevMat, lRevMed, lRevRes, lRevTax, lRevDia, lRevPro, lRevTxS, lUltPrc, cMsgRev)
 Local cAlias := "", cPref := "", cAliasOld := Alias(), aArea := HS_SavArea({{"GCZ", 0, 0}}), nAlias := 1, lFound := .T.
 Local aRValDes := {}, cSTmpPrinc := "", cCodDes :="", cQryInc := "", dDatDes := dDataBase, aTabPre := {}
 Local nIncidProc := 0
 Local lRepCDsc   := IIF(HS_VldSx6({{"MV_REPCDSC",{"L","T/F","$"}}},.F.),GetMv("MV_REPCDSC"),.F.) //Repasse com Desconto
 Local lCpRepMMTD := HS_ExisDic({{"C", "GD5_VALREB"}, {"C", "GE5_VALREB"},{"C", "GD6_VALREB"},{"C", "GE6_VALREB"}}, .F.) 
 
 DbSelectArea("GCZ")
 DbSetOrder(1)
 If GCZ->GCZ_NRSEQG <> cNrSeqG
  DbSeek(xFilial("GCZ") + cNrSeqG)
 EndIf

 If cPlaNew <> Nil .And. !Empty(cPlaNew) .And. cPlaNew <> GCZ->GCZ_CODPLA .And. ;
    cPlaOld <> Nil .And. !Empty(cPlaOld) .And. cPlaOld == GCZ->GCZ_CODPLA
  RecLock("GCZ", .F.)
   GCZ->GCZ_CODCON := HS_IniPadr("GCM", 2, cPlaNew, "GCM_CODCON",, .F.)
   GCZ->GCZ_CODPLA := cPlaNew
  MsUnLock()
 EndIf
 
 DbSelectArea("GCY")
 DbSetOrder(1)
 If GCY->GCY_REGATE <> GCZ->GCZ_REGATE
  DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
 EndIf 
  
 For nAlias := 1 To 2
  If lRevMat .Or. lRevMed .Or. lRevRes                 
   // nAlias == 1 // Despesas de Postos // 1a Fase - Revalorizacao no Arquivo de Materiais e Medicamentos
   // nAlias == 2 // Despesas de Faturamento // 2a Fase - Revalorizacao no Arquivo de Materiais e Medicamentos
  
   cAlias := IIf(nAlias == 1, "GD5"     , "GE5"     )
   cPref  := IIf(nAlias == 1, "GD5->GD5", "GE5->GE5")
   
   DbSelectArea(cAlias)
   DBSetOrder(2)
   DbSeek(xFilial(cAlias) + cNrSeqG + DToS(dDatIni), .T.)
                   
   While !Eof() .And. xFilial(cAlias) == &(cPref + "_FILIAL") .And. &(cPref + "_NRSEQG") == cNrSeqG .And. &(cPref + "_DATDES") <= dDatFin
                      
    If !(&(cPref + "_GLODES") $ '02')
     DBSkip()
     Loop
    Endif                            
    
    If !(lFound := GBI->GBI_PRODUT == &(cPref + "_CODDES"))
     DbSelectArea("GBI")
     DbSetOrder(1)
     lFound := DbSeek(xFilial("GBI") + &(cPref + "_CODDES"))
     
     DbSelectArea(cAlias)
    EndIf                          
                             
    //0=Materiais;1=Medicamentos;2=Rest./Frig.;3=Estoque;4=Kit
    If !lFound .Or. (GBI->GBI_TIPO == "0" .And. !lRevMat) ;
               .Or. (GBI->GBI_TIPO == "1" .And. !lRevMed) ;
               .Or. (GBI->GBI_TIPO == "2" .And. !lRevRes)
     DbSkip()
     Loop
    EndIf            
                                             
    aRValDes := HS_RValMM(GCZ->GCZ_CODPLA, &(cPref + "_CODDES"),,.F.,IIf(lUltPrc, dDataBase, &(cPref + "_DATDES")),.F.,&(cPref + "_CODCRM"), &(cPref + "_CODLOC"), &(cPref + "_HORDES")  ,{GCY->GCY_ATENDI, GCY->GCY_CARATE})
    
    If aRValDes[1] <> 0 
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0150 + ALLTRIM(&(cPref + "_CODDES")) + STR0151 + CHR(10)  //"Nro Seq Guia: "###" Cod Mat/Med: "###" contêm inconsistencia e não pode ser revalorizado"
     DbSelectArea(cAlias)
     DbSkip()
     Loop
    ElseIf !HS_VldDsc(cAlias, HS_CValDes(cAlias, &(cPref+"_SEQDES"),,,,,, .F.)) 
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0150 + ALLTRIM(&(cPref + "_CODDES")) + STR0161 + CHR(10)//"Nro Seq Guia: "###" Cod Mat/Med: "###" com valor de desconto maior que o valor unitário não pode ser revalorizado"  
     DbSelectArea(cAlias)
     DbSkip()
     Loop
    EndIf
    
    DbSelectArea(cAlias)
    RecLock(cAlias, .F.)
     &(cPref + "_VALDES") := aRValDes[02]
     &(cPref + "_PCUDES") := aRValDes[03]
     &(cPref + "_GLODES") := IIf(aRValDes[04][01], "2", "0")
     &(cPref + "_CODPRO") := aRValDes[09]
     &(cPref + "_DESPRO") := aRValDes[10]
     
     If Hs_ExisDic({{"C", cAlias + "_TABELA"}}, .F.)
      &(cPref + "_TABELA") := aRValDes[11]
     EndIf
     
     If lCpRepMMTD 
      &(cPref + "_PGTMED") := aRValDes[13][01]
      &(cPref + "_REPAMB") := aRValDes[13][3]
      &(cPref + "_CODPRE") := aRValDes[14]
      
      &(cPref + "_VALREB") := &(cPref+"_QTDDES") * aRValDes[13][05]
      &(cPref + "_VALREP") := (&(cPref+"_QTDDES") * aRValDes[13][05])  * IIF(lRepCDsc, HS_CValDes(cAlias, &(cPref + "_SEQDES")) / HS_CValDes(cAlias, &(cPref + "_SEQDES"),,,,,, .F.) , 1)
     EndIf 
     
     If cAlias == "GD5"
      &(cPref + "_FATPAR") := aRValDes[04][02]
     EndIf 
    MsUnlock()
   
    DbSkip()
   End
  EndIf 
	 
	 If lRevTax .Or. lRevDia
   // nAlias == 1 // Despesas de Postos // 1a Fase - Revalorizacao no Arquivo de Taxas e Diarias
   // nAlias == 2 // Despesas de Faturamento // 2a Fase - Revalorizacao no Arquivo de Taxas e Diarias
  
   cAlias := IIf(nAlias == 1, "GD6"     , "GE6"     )
   cPref  := IIf(nAlias == 1, "GD6->GD6", "GE6->GE6")    
  
   DbSelectArea(cAlias)
   DBSetOrder(2)
   DbSeek(xFilial(cAlias) + cNrSeqG + DToS(dDatIni), .T.)
                   
   While !Eof() .And. xFilial(cAlias) == &(cPref + "_FILIAL") .And. &(cPref + "_NRSEQG") == cNrSeqG .And. &(cPref + "_DATDES") <= dDatFin
                      
    If !(&(cPref + "_GLODES") $ "02")
     DbSkip()
    	Loop
    Endif             

    If !(lFound := GAA->GAA_CODTXD == &(cPref + "_CODDES"))   
     DbSelectArea("GAA")
     DbSetOrder(1)
     lFound := DbSeek(xFilial("GAA") + &(cPref + "_CODDES"))
     
     DbSelectArea(cAlias)
    EndIf 
                                                       
    //2=Taxas;7=Diarias
    If !lFound .Or. (GAA->GAA_TIPDES == "2" .And. !lRevTax) ;
               .Or. (GAA->GAA_TIPDES == "7" .And. !lRevDia)
     DbSkip()
     Loop
    EndIf            
                                                                                
    aRValDes := HS_RValTD(&(cPref + "_CODDES"), GCZ->GCZ_CODPLA, &(cPref + "_CODLOC"), .F., IIf(lUltPrc, dDataBase, &(cPref + "_DATDES")),,&(cPref + "_CODCRM"), &(cPref + "_HORDES"), {GCY->GCY_ATENDI, GCY->GCY_CARATE})
    
    If aRValDes[1] <> 0 
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0152 + ALLTRIM(&(cPref + "_CODDES")) + STR0151 + CHR(10) //"Nro Seq Guia: "###" Cod Tax/Dia: "###" contêm inconsistencia e não pode ser revalorizado"
     DbSelectArea(cAlias)
     DbSkip()
     Loop
    ElseIf !HS_VldDsc(cAlias, HS_CValDes(cAlias, &(cPref+"_SEQDES"),,,,,, .F.)) 
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0152 + ALLTRIM(&(cPref + "_CODDES")) + STR0161 + CHR(10) //"Nro Seq Guia: "###" Cod Tax/Dia: "###" com valor de desconto maior que o valor unitário não pode ser revalorizado"
     DbSelectArea(cAlias)
     DbSkip()
     Loop
    EndIf
    
    DbSelectArea(cAlias)
    RecLock(cAlias, .F.)
     &(cPref + "_VALDES") := aRValDes[02]
     &(cPref + "_PCUDES") := aRValDes[03]
     &(cPref + "_GLODES") := IIf(aRValDes[04][01], "2", "0")
     &(cPref + "_CODTXC") := aRValDes[07]
     &(cPref + "_DESTXC") := aRValDes[08]
     
     If Hs_ExisDic({{"C", cAlias + "_TABELA"}}, .F.)
      &(cPref + "_TABELA") := aRValDes[09]
     EndIf
     
     If lCpRepMMTD 
      &(cPref + "_PGTMED") := aRValDes[10][01]
      &(cPref + "_REPAMB") := aRValDes[10][aRValDes[12]]
      &(cPref + "_CODPRE") := aRValDes[11]
     
      &(cPref + "_VALREB") := &(cPref + "_QTDDES") * aRValDes[10][05]
      &(cPref + "_VALREP") := (&(cPref + "_QTDDES") * aRValDes[10][05])  * IIF(lRepCDsc, HS_CValDes(cAlias, &(cPref + "_SEQDES")) / HS_CValDes(cAlias, &(cPref + "_SEQDES"),,,,,, .F.) , 1)
     EndIf

     If cAlias == "GD6"
      &(cPref + "_FATPAR") := aRValDes[04][02]
     EndIf 
    MsUnlock()
	   
    DbSkip()
   End
  EndIf
	 
	 If lRevPro
   // nAlias == 1 // Despesas de Postos // 1a Fase - Revalorizacao no Arquivo de Procedimentos e Honorarios
   // nAlias == 2	// Despesas de Faturamento // 2a Fase - Revalorizacao no Arquivo de Procedimentos e Honorarios
   
   cAlias := IIf(nAlias == 1, "GD7"     , "GE7"     )
   cPref  := IIf(nAlias == 1, "GD7->GD7", "GE7->GE7")
   
   DbSelectArea(cAlias)
   DBSetOrder(2)
   DbSeek(xFilial(cAlias) + cNrSeqG + DToS(dDatIni), .T.)
                   
   While !Eof() .And. xFilial(cAlias) == &(cPref + "_FILIAL") .And. &(cPref + "_NRSEQG") == cNrSeqG .And. &(cPref + "_DATDES") <= dDatFin
                         
    If !(&(cPref + "_GLODES") $ "02")
	    DbSkip()
	    Loop
    EndIf
    
    If &(cPref + "_ORIDES") == "2" // 2-Incidencia
     //Procurar o procedimento que gerou a incidência
     cSTmpPrinc := &(cPref + "_SPRINC")
      
     cQryInc := "SELECT " + cAlias + "_CODDES CODDES, " + cAlias + "_DATDES DATDES, " + cAlias + "_INCIDE INCIDE "
     cQryInc += "FROM " + RetSqlName(cAlias) + " "
     cQryInc += "WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' AND "
     cQryInc +=            cAlias + "_SPRINC = '" + &(cPref + "_SPRINC") + "' AND " + cAlias + "_SEQDES = " + cAlias + "_SPRINC "
     
     cQryInc := ChangeQuery(cQryInc)
     TCQUERY cQryInc NEW ALIAS "QRYINC"                                                                        
     
     DbSelectArea("QRYINC")
     DbGotop()
     
     If !Eof()
     
      cCodDes   := QRYINC->CODDES
      dDatDes   := IIf(!Empty(QRYINC->DATDES), STOD(QRYINC->DATDES), dDataBase)
      nQtDigInc := QRYINC->INCIDE
     
      aTabPre    := HS_RTabPre("GC6", GCZ->GCZ_CODPLA, cCodDes, dDatDes)
      nIncidProc := HS_IniPadr("GA7", 1, cCodDes, "GA7_INCIDE",,.F.)
     
      DbSelectArea("GAU")
      DbSetOrder(2)
      DbSeek(xFilial("GAU") + aTabPre[1] + GA7->GA7_CODGPP)
     
      aRValDes := HS_RValPr(&(cPref + "_CODDES"), GCZ->GCZ_CODPLA, &(cPref + "_CODLOC"), &(cPref + "_HORDES"), "2", &(cPref + "_CODCRM"), &(cPref + "_CODATO"), {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE}, .F., IIf(lUltPrc, dDataBase, &(cPref + "_DATDES")), {GAU->GAU_FORVAL, cCodDes, nQtDigInc, nIncidProc})
     
      cSTmpPrinc := ""
      
     EndIf
     
     DbSelectArea("QRYINC")
     DbCloseArea()
    Else
     // Na revalorizacao sempre sera passado 2-Regra para o calculo da urgencia.
		   aRValDes := HS_RValPr(&(cPref + "_CODDES"), GCZ->GCZ_CODPLA, &(cPref + "_CODLOC"), &(cPref + "_HORDES"), "2", &(cPref + "_CODCRM"), &(cPref + "_CODATO"), {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE}, .F., IIf(lUltPrc, dDataBase, &(cPref + "_DATDES")))
		  EndIf
		  
		  If aRValDes[1] <> 0 
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0153 + ALLTRIM(&(cPref + "_CODDES")) + STR0151 + CHR(10) //"Nro Seq Guia: "###"  Cod Pro/Hon: "###" contêm inconsistencia e não pode ser revalorizado"
     DbSelectArea(cAlias)
     DbSkip()
     Loop
		  ElseIf !HS_VldDsc(cAlias, HS_CValDes(cAlias, &(cPref+"_SEQDES"),,,,,, .F.))
     cMsgRev += STR0149 + GCZ->GCZ_NRSEQG + STR0153 + ALLTRIM(&(cPref + "_CODDES")) + STR0161//"Nro Seq Guia: "###"  Cod Pro/Hon: "###" com valor de desconto maior que o valor unitário não pode ser revalorizado" + CHR(10) 
     DbSelectArea(cAlias)
     DbSkip()
     Loop
		  EndIf
		  
		  DbSelectArea(cAlias)
		  RecLock(cAlias, .F.)                  
		   &(cPref + "_COEFAM") := aRValDes[02][01][02]
 	 	 &(cPref + "_VALDES") := aRValDes[02][01][01]
     &(cPref + "_PCUDES") := aRValDes[03]
     &(cPref + "_GLODES") := IIf(aRValDes[04][01], "2", "0")
     &(cPref + "_CODPRT") := aRValDes[02][15]
     &(cPref + "_DESPRT") := aRValDes[02][18]

     If &(cPref + "_ORIDES") == "2" 
      &(cPref + "_QTDDES") := aRValDes[16][01]
      &(cPref + "_COEDES") := aRValDes[16][02]
     Endif
          
     If cAlias == "GD7"
      &(cPref + "_FATPAR") := aRValDes[04][02]
     EndIf 
     
     &(cPref + "_URGDES") := aRValDes[02][14]
     &(cPref + "_COECHP") := aRValDes[02][10]
     &(cPref + "_QTDCHP") := aRValDes[02][11]
     &(cPref + "_PGTMED") := aRValDes[09][01]
     &(cPref + "_COECHM") := aRValDes[09][aRValDes[11]]
     &(cPref + "_REPAMB") := aRValDes[09][aRValDes[10]]                     
     
     
     If cMV_AteSus == "S" // Se atende SUS
      If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA
       &(cPref + "_CDGATE") := aRValDes[15][2][1]
       &(cPref + "_CDTATE") := aRValDes[15][3][1]
      EndIf
     EndIf               
      
     If HS_ExisDic({{"C", cAlias+"_VALREB"}},.F.)
      &(cPref + "_VALREB") := &(cPref + "_QTDDES") * aRValDes[9][14]   
      &(cPref + "_VALREP") := (&(cPref + "_QTDDES") * aRValDes[9][14]) * IIF(lRepCDsc, HS_CValDes(cAlias, &(cPref + "_SEQDES")) / HS_CValDes(cAlias, &(cPref + "_SEQDES"),,,,,, .F.) , 1)
     Else
      &(cPref + "_VALREP") := &(cPref + "_QTDDES") * aRValDes[9][14]
     EndIf

     If HS_ExisDic({{"C", cAlias + "_VLREPF"}})  
      &(cPref + "_VLREPF") := &(cPref + "_QTDDES") * aRValDes[9][17]             
     EndIf
            
     &(cPref + "_VCUSOP") := aRValDes[02][02]
     &(cPref + "_VFILME") := aRValDes[02][03]
     &(cPref + "_VLRCOS") := aRValDes[2][24]
     &(cPref + "_CODPRE") := aRValDes[14]
     
     If Hs_ExisDic({{"C", cAlias + "_TABELA"}}, .F.)
      &(cPref + "_TABELA") := aRValDes[02][20]
     EndIf
     
 	 	MsUnLock() 
 	 	        
 	 	DbSkip()
   End
  EndIf
  // efetua calculo de taxa/servico sobre despesas de material e taxa/diaria
  If lRevMat .OR. lRevMed .OR. lRevTax .OR. lRevDia .OR. lRevTxS
   IIf(nAlias == 1, HS_VlTxSer('GD6', GCZ->GCZ_NRSEQG), HS_VlTxSer('GE6', GCZ->GCZ_NRSEQG))
  EndIf  
 Next
                                                        
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(Nil)

Function HS_RevalRM()

 Processa({|| FS_RevalRM() })

Return(Nil)

Static Function FS_RevalRM()
 Local cSql := "", aArea := GetArea()
 Local cCodPreIni := ""
 Local cCodPreFin := ""
 Local cDatDesIni := ""
 Local cDatDesFin := ""
 Local cGczNrFatu := ""            
 Local cPrefi     := ""
 Local nRecCount  := 0
 Local lContinua  := .T.
 Local nUpdTran   := 0
 Local nRecAtu    := 0
 Local cMsgRev    := ""
 Local lRepCDsc   := IIF(HS_VldSx6({{"MV_REPCDSC",{"L","T/F","$"}}},.F.),GetMv("MV_REPCDSC"),.F.) //Repasse com Desconto
 Local aDesp      := {}
 Local nForDesp   := 0, nI :=0, nDesp := 0 
 Local aCpoDesp   := {}
 Local lCpRepMMTD := HS_ExisDic({{"C", "GD5_VALREB"}, {"C", "GE5_VALREB"},{"C", "GD6_VALREB"},{"C", "GE6_VALREB"}}, .F.) 
                       
 Private aRValDes   := {}
     
 If lCpRepMMTD //Se existir campos do repasse Mat/Med e Tax/Dia 
  aAdd(aDesp,{"GD5", "GD5.GD5", "GE5", "GE5.GE5", "G5"})
  aAdd(aDesp,{"GD6", "GD6.GD6", "GE6", "GE6.GE6", "G6"})
 EndIf 
 
 aAdd(aDesp,{"GD7", "GD7.GD7", "GE7", "GE7.GE7", "G7"})

 //              Campo            G5                  G6                               G7
 aAdd(aCpoDesp,{"_PGTMED", "aRValDes[13][01]", "aRValDes[10][01]"          , "aRValDes[9][1]"           })
 aAdd(aCpoDesp,{"_REPAMB", "aRValDes[13][3]" , "aRValDes[10][aRValDes[12]]", "aRValDes[9][aRValDes[10]]"})
 aAdd(aCpoDesp,{"_CODPRE", "aRValDes[14]"    , "aRValDes[11]"              , "aRValDes[14]"             })
 aAdd(aCpoDesp,{"_VALREB", "aRValDes[13][05]", "aRValDes[10][05]"          , "aRValDes[9][14]"          })
 aAdd(aCpoDesp,{"_VALREP", "aRValDes[13][05]", "aRValDes[10][05]"          , "aRValDes[9][14]"          })
 aAdd(aCpoDesp,{"_TABELA", "aRValDes[11]"    , "aRValDes[09]"              , "aRValDes[2][20]"          })

 
 If !Pergunte("HSPFRM")
  RestArea(aArea)
  Return(Nil)
 EndIf 
 
 cDatDesIni := DToS(MV_PAR01)
 cDatDesFin := DToS(MV_PAR02)
 cCodPreIni := MV_PAR03
 cCodPreFin := MV_PAR04
 cGczNrFatu := MV_PAR05
 
 cSql := ""
 For nForDesp := 1 to Len(aDesp)
 
  DbSelectArea(aDesp[nForDesp, 1])
  DbSetOrder(1)
 
  DbSelectArea(aDesp[nForDesp, 1])
  DbSetOrder(1)

  If cSql # ""
   cSql += " UNION ALL " 
  EndIf
  
 If Empty(cGczNrFatu)
   cSql += "SELECT '" + aDesp[nForDesp, 1] + "' CALIAS, 'N' FATURADO, " + aDesp[nForDesp, 2] + "_SEQDES SEQDES, "
   cSql +=         aDesp[nForDesp, 2] + "_DATDES DATDES, GCY.GCY_ATENDI ATENDI, GCY.GCY_ATORIG ATORIG, GCY.GCY_IDADE IDADE, "
   cSql += "       GCZ.GCZ_CODPLA CODPLA, GCY.GCY_SEXO SEXO, GCY.GCY_CARATE CARATE, '"+aDesp[nForDesp, 5]+"' TIPODESP"
   cSql += "  FROM " + RetSqlName(aDesp[nForDesp, 1]) + " " + aDesp[nForDesp, 1] 
   cSql += "  JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
   cSql += "   AND GCY.GCY_REGATE = " + aDesp[nForDesp, 2] + "_REGATE AND GCY.GCY_TPALTA <> '99' "     
   cSql += "  JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
   cSql += "   AND GCZ.GCZ_NRSEQG = " + aDesp[nForDesp, 2] + "_NRSEQG AND GCZ.GCZ_CANCEL <> '1' "   
   cSql += " WHERE " + aDesp[nForDesp, 2] + "_FILIAL = '" + xFilial(aDesp[nForDesp, 1]) + "'"
   cSql += "   AND " + aDesp[nForDesp, 1] + ".D_E_L_E_T_ <> '*' "
   cSql += "   AND " + aDesp[nForDesp, 2] + "_SEQ" + aDesp[nForDesp, 3] + " = '" + Space(Len(&( StrTran(aDesp[nForDesp, 2],".","->") + "_SEQ" + aDesp[nForDesp, 3]))) + "' "
   cSql += "   AND " + aDesp[nForDesp, 2] + "_DATDES BETWEEN '" + cDatDesIni + "' AND '" + cDatDesFin + "'"
   cSql += "   AND " + aDesp[nForDesp, 2] + "_CODPRE BETWEEN '" + cCodPreIni + "' AND '" + cCodPreFin + "'"
 
   cSql += " UNION ALL "
 Else
   cSql += "" 
 EndIf 
 
  cSql += "SELECT '" + aDesp[nForDesp, 1] + "' CALIAS, 'S' FATURADO, " + aDesp[nForDesp, 2] + "_SEQDES SEQDES, "
  cSql +=          aDesp[nForDesp, 2] + "_DATDES DATDES, GCY.GCY_ATENDI ATENDI, GCY.GCY_ATORIG ATORIG, GCY.GCY_IDADE IDADE, "
  cSql += "        GCZ.GCZ_CODPLA CODPLA, GCY.GCY_SEXO SEXO, GCY.GCY_CARATE CARATE, '"+aDesp[nForDesp, 5]+"' TIPODESP"
  cSql += "  FROM " + RetSqlName(aDesp[nForDesp, 1]) + " " + aDesp[nForDesp, 1]
  cSql += "  JOIN " + RetSqlName(aDesp[nForDesp, 3]) + " " + aDesp[nForDesp, 3] + " ON " + aDesp[nForDesp, 4] + "_FILIAL = '" + xFilial(aDesp[nForDesp, 3]) + "'"
  cSql += "   AND " + aDesp[nForDesp, 3] + ".D_E_L_E_T_ <> '*' AND " + aDesp[nForDesp, 4] + "_SEQDES = " + aDesp[nForDesp, 2] + "_SEQ" + aDesp[nForDesp, 3] 
  cSql += "   AND " + aDesp[nForDesp, 3] + "_NREXTC = '" + Space(Len(&(StrTran(aDesp[nForDesp, 4],".","->") + "_NREXTC"))) + "'"
  cSql += "   AND " + aDesp[nForDesp, 3] + "_NREXTM = '" + Space(Len(&( StrTran(aDesp[nForDesp, 4],".","->")+"_NREXTM"))) + "'"
  cSql += "  JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSql += "   AND GCY.GCY_REGATE = " + aDesp[nForDesp, 2] + "_REGATE AND GCY.GCY_TPALTA <> '99' "
  cSql += "  JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSql += "   AND GCZ.GCZ_NRSEQG = " + aDesp[nForDesp, 2] + "_NRSEQG AND GCZ.GCZ_CANCEL <> '1' " 
 
 If !Empty(cGczNrFatu)
   cSql += " AND GCZ.GCZ_NRFATU = '" + cGczNrFatu + "' "
 EndIf 
 
  cSql += " WHERE " + aDesp[nForDesp, 2] + "_FILIAL = '" + xFilial(aDesp[nForDesp, 1]) + "'"
  cSql += "   AND " + aDesp[nForDesp, 1] + ".D_E_L_E_T_ <> '*' "
  cSql += "   AND " + aDesp[nForDesp, 2] + "_SEQ" + aDesp[nForDesp, 3] + " <> '" + Space(Len(&( StrTran(aDesp[nForDesp, 2],".","->") + "_SEQ" + aDesp[nForDesp, 3]))) + "' "
  cSql += "   AND " + aDesp[nForDesp, 2] + "_DATDES BETWEEN '" + cDatDesIni + "' AND '" + cDatDesFin + "'"
  cSql += "   AND " + aDesp[nForDesp, 2] + "_CODPRE BETWEEN '" + cCodPreIni + "' AND '" + cCodPreFin + "' " 
 
  cSql += " UNION ALL "
 
 
 cSql += "SELECT '" + aDesp[nForDesp, 1] + "' CALIAS, 'S' FATURADO, " + aDesp[nForDesp, 4] + "_SEQDES SEQDES, " 
 cSql +=             aDesp[nForDesp, 4] + "_DATDES DATDES, GCY.GCY_ATENDI ATENDI, GCY.GCY_ATORIG ATORIG, GCY.GCY_IDADE IDADE, "
 cSql += "           GCZ.GCZ_CODPLA CODPLA, GCY.GCY_SEXO SEXO, GCY.GCY_CARATE CARATE, '"+aDesp[nForDesp, 5]+"' TIPODESP"
 cSql += "  FROM " + RetSqlName(aDesp[nForDesp, 3]) + " " + aDesp[nForDesp, 3]
 cSql += "  JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSql += "   AND GCY.GCY_REGATE = " + aDesp[nForDesp, 4] + "_REGATE AND GCY.GCY_TPALTA <> '99' "
 cSql += "  JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSql += "   AND GCZ.GCZ_NRSEQG = " + aDesp[nForDesp, 4] + "_NRSEQG AND GCZ.GCZ_CANCEL <> '1' " 
 
 If !Empty(cGczNrFatu)
  cSql += " AND GCZ.GCZ_NRFATU = '" + cGczNrFatu + "' "
 EndIf 
 
 cSql += " WHERE " + aDesp[nForDesp, 4] + "_FILIAL = '" + xFilial(aDesp[nForDesp, 3]) + "' AND " + aDesp[nForDesp, 3] + ".D_E_L_E_T_ <> '*' "
 cSql += "   AND " + aDesp[nForDesp, 4] + "_NREXTC = '" + Space(Len(&(StrTran(aDesp[nForDesp, 4],".","->")+"_NREXTC"))) + "'"
 cSql += "   AND " + aDesp[nForDesp, 4] + "_NREXTM = '" + Space(Len(&(StrTran(aDesp[nForDesp, 4],".","->")+"_NREXTM"))) + "'"
 cSql += "   AND " + aDesp[nForDesp, 4] + "_DATDES BETWEEN '" + cDatDesIni + "' AND '" + cDatDesFin + "'"
 cSql += "   AND " + aDesp[nForDesp, 4] + "_CODPRE BETWEEN '" + cCodPreIni + "' AND '" + cCodPreFin + "' "   
  
 Next nForDesp                                                                                                
 
 cSql += " ORDER BY DATDES"
 
 cSql := ChangeQuery(cSql)
                          
 TCQuery cSql New Alias "REVREP"
  
 DbSelectArea("REVREP")
 DbGoTop()  
 
 While REVREP->(!EoF())
  nRecCount++
  DbSkip()
 EndDo
 
 DbGoTop() 
 
 If nRecCount == 0
  
  MsgInfo(STR0154, STR0025) //"Nao foi encontrado nenhum registro para o processamento do repasse médico, verifique os parametros"
  RestArea(aArea)
  Return(Nil)
  
 EndIf
 
 While lContinua
  
  Begin Transaction
        
   nUpdTran := 0
   While (lContinua := !Eof()) .And. nUpdTran <= 20
    
    nUpdTran++
    nRecAtu++
   
    IncProc(STR0155 + DToC(SToD(REVREP->DATDES)) + "][" + StrZero(nRecAtu, 8) + "][" + StrZero(nRecCount, 8) + "]") //"Revalorizando ["
      
    cPrefi := REVREP->CALIAS + "->" + REVREP->CALIAS
    
    DbSelectArea(REVREP->CALIAS)
    DbSeek(xFilial(REVREP->CALIAS) + REVREP->SEQDES)
    
    If REVREP->TIPODESP == "G5"
     aRValDes := HS_RValMM(REVREP->CODPLA, &(cPrefi + "_CODDES"),,.F.,&(cPrefi + "_DATDES"),.F.,&(cPrefi + "_CODCRM"), &(cPrefi + "_CODLOC"), &(cPrefi + "_HORDES")  ,{REVREP->ATENDI, REVREP->CARATE})
    ElseIf REVREP->TIPODESP == "G6"
     aRValDes := HS_RValTD(&(cPrefi + "_CODDES"), REVREP->CODPLA, &(cPrefi + "_CODLOC"), .F., &(cPrefi + "_DATDES"),,&(cPrefi + "_CODCRM"), &(cPrefi + "_HORDES"), {REVREP->ATENDI, REVREP->CARATE})
    Else
    // Na revalorizacao sempre sera passado 2-Regra para o calculo da urgencia.
     aRValDes := HS_RValPr(&(cPrefi + "_CODDES"), REVREP->CODPLA, &(cPrefi + "_CODLOC"), &(cPrefi + "_HORDES"), "2", &(cPrefi + "_CODCRM"), &(cPrefi + "_CODATO"), {REVREP->ATENDI, REVREP->ATORIG, REVREP->IDADE, REVREP->SEXO, REVREP->CARATE}, .F., &(cPrefi + "_DATDES"))
	  	EndIf
	  	  
    If aRValDes[1] <> 0 
     cMsgRev += STR0149 + &(cPrefi + "_NRSEQG") + STR0153 + ALLTRIM(&(cPrefi + "_CODDES")) + STR0151 + CHR(10) //"Nro Seq Guia: "###"  Cod Pro/Hon: "###" contêm inconsistencia e não pode ser revalorizado"
    	DbSelectArea("REVREP") 	        
     DbSkip()
     Loop    
		  
		  ElseIf !HS_VldDsc(REVREP->CALIAS, HS_CValDes(REVREP->CALIAS, &(cPrefi+"_SEQDES"),,,,,, .F.))
     cMsgRev += STR0149 + &(cPrefi + "_NRSEQG") + STR0153 + ALLTRIM(&(cPref + "_CODDES")) + STR0161//"Nro Seq Guia: "###"  Cod Pro/Hon: "###" com valor de desconto maior que o valor unitário não pode ser revalorizado" + CHR(10) 
     DbSelectArea("REVREP") 	 
     DbSkip()
     Loop
    EndIf
    
    DbSelectArea(REVREP->CALIAS)
    RecLock(REVREP->CALIAS, .F.)                  
     
     nDesp := IIF(REVREP->TIPODESP == "G5",2, IIF(REVREP->TIPODESP == "G6", 3, 4)) 
     For nI := 1 to Len(aCpoDesp)
      If (aCpoDesp[nI, 1] == "_TABELA") .And. !Hs_ExisDic({{"C", REVREP->CALIAS + "_TABELA"}}, .F.)
       Loop
      ElseIf (aCpoDesp[nI, 1] == "_VALREB") .And. Hs_ExisDic({{"C", REVREP->CALIAS + "_VALREB"}}, .F.)
       &(cPrefi + aCpoDesp[nI, 1]) := &(cPrefi + "_QTDDES") * &(aCpoDesp[nI, nDesp])
       Loop
      ElseIf (aCpoDesp[nI, 1] == "_VALREP")
       &(cPrefi + "_VALREP") := (&(cPrefi + "_QTDDES") * &(aCpoDesp[nI, nDesp])) * IIF(lRepCDsc .And. Hs_ExisDic({{"C", REVREP->CALIAS + "_VALREB"}}, .F.), HS_CValDes(REVREP->CALIAS, &(cPrefi + "_SEQDES")) / HS_CValDes(REVREP->CALIAS, &(cPrefi + "_SEQDES"),,,,,, .F.) , 1)       
       Loop
      EndIf                                                                                                                          
      &(cPrefi + aCpoDesp[nI, 1]) := &(aCpoDesp[nI, nDesp])   
     Next nI

     If REVREP->TIPODESP == "G7" 
      &(cPrefi + "_COEFAM") := aRValDes[2][1][2]
      &(cPrefi + "_COECHM") := aRValDes[9][aRValDes[11]]
       
      If HS_ExisDic({{"C", REVREP->CALIAS + "_VLREPF"}})  
       &(cPrefi + "_VLREPF") := &(cPrefi + "_QTDDES") * aRValDes[9][17]      
      EndIf
          
      &(cPrefi + "_VCUSOP") := aRValDes[2][2]
      &(cPrefi + "_VFILME") := aRValDes[2][3]
      &(cPrefi + "_VLRCOS") := aRValDes[2][24]
     EndIf
   	MsUnLock() 
   	
   	DbSelectArea("REVREP") 	        
   	DbSkip()
   End
  End Transaction
 
 End
               
 If !Empty(cMsgRev)
  HS_MsgInf(cMsgRev, STR0030, STR0162)
 EndIf
              
 DbSelectArea("REVREP")
 DbCloseArea()
 RestArea(aArea)
Return(Nil)

/// Conta o numero de vezes que o chr informado existe na string passada
Function HS_CntChr(cString, cChr)
 Local nChr := 0, nCnt := 0
 For nChr := 0 To Len(cString)
  If SubStr(cString, nChr, 1) == cChr
   nCnt++
  EndIf 
 Next
Return(nCnt)

Function HS_NInd(cInd)
 Local nInd := 0
 Local cIndOrd := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 
 nInd := At(cInd, cIndOrd)
Return(nInd)

Function HS_CInd(nInd)
 Local cInd := " "
 Local cIndOrd := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 
 cInd := SubStr(cIndOrd, nInd, 1)
Return(cInd)

Function HS_PrivVar(cRegAte, lPosGcy)
 Local cAliasOld := Alias(), nForArq := 0
 Local cCpoPriv := "", cCpoArqu := "", cMemVar := ""
 Local lIncOld := IIf(Type(STR0098) # "U", Inclui, Nil) //"Inclui"
 Local lAltOld := IIf(Type(STR0099) # "U", Altera, Nil) //"Altera"
 Local cLstArqP := GetMV("MV_LSTARQP")
 Local aSavArea := {}
 Local aRVet := {}
 
 Default lPosGcy := .F.            
 
 // Para garantir que o arquivo GAD não seja utilizado no lugar do GCY
 cLstArqP := StrTran(cLstArqP, "GAD", "GCY")
  
 aLstArqP := &(cLstArqP)
 
 If Empty(aLstArqP)
  Return(aRVet)
 EndIf
  
 For nForArq := 1 To Len(aLstArqP)
  aAdd(aSavArea, {aLstArqP[nForArq, 1], 0, 0})
 Next  
 
 aSavArea := HS_SavArea(aSavArea)
 
 If lIncOld # Nil
  Inclui := .F.
 EndIf
 
 If lAltOld # Nil
  Altera := .T.
 EndIf 
                                    
 If lPosGcy                                              
  DbSelectArea("GCY")
  DbSetOrder(1)
  If cRegAte == Nil
   DbGoTop()
  Else
   DbSeek(xFilial("GCY") + cRegAte)
  EndIf
 EndIf 
 
 For nForArq := 1 To Len(aLstArqP)
  DbSelectArea("SX3")
  DbSetOrder(1)
  DbSeek(aLstArqP[nForArq, 1])
  While !Eof() .And. SX3->X3_ARQUIVO == aLstArqP[nForArq, 1]
   DbSelectArea(aLstArqP[nForArq, 1])
   If !Empty(AllTrim(aLstArqP[nForArq, 2])) .And. !Empty(AllTrim(aLstArqP[nForArq, 3]))
    DbSetOrder(HS_NInd(aLstArqP[nForArq, 2]))
    DbSeek(xFilial(aLstArqP[nForArq, 1]) + FS_PegaCpo("GCY", aLstArqP[nForArq, 3]))
   EndIf 
   
   cCpoPriv := "__" + Lower(SX3->X3_TIPO) + AllTrim(SX3->X3_CAMPO)
   cCpoArqu := aLstArqP[nForArq, 1] + "->" + SX3->X3_CAMPO
   cMemVar  := "M->" + AllTrim(SX3->X3_CAMPO)
    
   If SX3->X3_CONTEXT == "V"
    &(cMemVar)  := CriaVar(SX3->X3_CAMPO)
    aAdd(aRVet, {cCpoPriv, CriaVar(SX3->X3_CAMPO)})
   Else                 
    &(cMemVar)  := &(cCpoArqu)
    aAdd(aRVet, {cCpoPriv, &(cCpoArqu)})
   EndIf
   
   DbSelectArea("SX3")
   DbSkip()
  End
 Next              
 
 HS_ResArea(aSavArea)
 
 If lIncOld # Nil
  Inclui := lIncOld
 EndIf
 
 If lAltOld # Nil
  Altera := lAltOld
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(aRVet)

Static Function FS_PegaCpo(cX3_Arquivo, cX3_Ordem)
 Local nRecSx3 := 0, nIndSx3 := 0, cAliasOld := Alias(), nCpoSx3 := 0, cRetCpo := ""
 DbSelectArea("SX3")
 nRecSx3 := RecNo()              
 nIndSx3 := IndexOrd()
 DbSetOrder(1)
 
 For nCpoSx3 := 1 To Len(cX3_Ordem) Step Len(SX3->X3_ORDEM)
  DbSeek(cX3_Arquivo + SubStr(cX3_Ordem, nCpoSx3, Len(SX3->X3_ORDEM)))
  cRetCpo += IIf(Empty(AllTrim(cRetCpo)), "", " + ") + AllTrim(SX3->X3_ARQUIVO) + "->" + AllTrim(SX3->X3_CAMPO)
 Next   
              
 cRetCpo := IIf(!Empty(cRetCpo), &(cRetCpo), "")
         
 DbSetOrder(nIndSx3)
 DbGoTo(nRecSx3)                         
 DbSelectArea(cAliasOld)
Return(cRetCpo)                                              
       

Function HS_MovEst(cTipo, cCodPro, nQuant, cAlmOri, cUserMov, cCCusto, cDoc, cNumLot, cLoteCt, cDtVali, lEstorno, cNumSeq, dDatMov, cRegAte, aCabMov, aItensMov, lErro)
Local aSd3 := {}, aArea := HS_SavArea({{"SB1", 0, 0}, {"SD3", 0, 0},{"GAI", 0, 0}, {"GBD", 0, 0}}), cAliasOld := Alias(), lOk := .T.
Local cTpMvEst := "", cD3NumSeq := "", cMvPar01Old := MV_PAR01
Local nQAtu := nQuant, nQtSegUM := ConvUm(cCodPro, nQuant, 0, 2)

Default cRegate	:= ""
Default cDoc		:= ""
Default lEstorno	:= .F.
Default dDatMov	:= dDataBase
Default lErro		:= .F.

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

If ValType(aItensMov) == "U"
	
	If     cTipo == "C" // Tipo de Movimentação para transferencia de material de consumo
		cTpMvEst := GetMV("MV_TPMADM")
	ElseIf cTipo == "S" // Tipo de Movimentação para saida de materiais
		cTpMvEst := GetMv("MV_TPMVSA")
	ElseIf cTipo == "E" // Tipo de Movimentação para entrada de materias
		cTpMvEst := GetMv("MV_TPMVEN")
	ElseIf cTipo == "G" // Tipo de Movimentação para saida de materiais  do hospital para um terceiro
		cTpMvEst := GetMv("MV_TMESSAI")
	ElseIf cTipo == "R" // Tipo de Movimentação de entrada de materiais devolvidas de um terceiro para o hospital
		cTpMvEst := GetMv("MV_TMESENT")
	ElseIf cTipo == "D" // Tipo de Movimentação de saida de materiais devolvidas do hospital para um terceiro
		cTpMvEst := GetMv("MV_TMEESAI")
	ElseIf cTipo == "I"// Tipo de Movimentação para entrada de materias de um terceiro para o hospital
		cTpMvEst := GetMv("MV_TMEEENT")
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + PadR(AllTrim(cCodPro), Len(SB1->B1_COD)))
	If !lEstorno
		aAdd(aSd3, {"D3_TM"     , cTpMvEst   , NIL})
		aAdd(aSd3, {"D3_COD"    , SB1->B1_COD, NIL})
		aAdd(aSd3, {"D3_UM"     , SB1->B1_UM , NIL})
		aAdd(aSd3, {"D3_QUANT"  , nQAtu      , NIL})
		aAdd(aSd3, {"D3_LOCAL"  , cAlmOri    , NIL})
		aAdd(aSd3, {"D3_EMISSAO", dDatMov    , NIL})
		aAdd(aSd3, {"D3_USUARIO", cUserMov   , NIL})
		aAdd(aSd3, {"D3_CC"     , cCCusto    , NIL})
		
		If !Empty(cRegate)
			aAdd(aSd3, {"D3_REGATEN"    , cRegate  , Nil})
		Endif
		If !Empty(SB1->B1_SEGUM) .And. nQtSegUm > 0
			aAdd(aSd3, {"D3_SEGUM"  , SB1->B1_SEGUM, NIL})
			aAdd(aSd3, {"D3_QTSEGUM", nQtSegUM     , NIL})
		EndIf
		
		If Rastro(cCodPro)
			aAdd(aSd3, {"D3_NUMLOTE", cNumLot, NIL})
			aAdd(aSd3, {"D3_LOTECTL", cLoteCt, NIL})
			aAdd(aSd3, {"D3_DTVALID", cDtVali, NIL})
		EndIf
	Else
		aAdd(aSd3, {"D3_NUMSEQ" , cNumSeq   , Nil})
		aAdd(aSd3, {"INDEX"     , 4         , Nil})
	Endif
	
	DbSelectArea("SD3")
	If !lEstorno
		DBSetOrder(1)
	Endif
	
	MSExecAuto({|x,y| MATA240(x,y)}, aSd3, IIF(lEstorno, 5, 3))
Else
	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCabMov, aItensMov, 3)
Endif

If lMsErroAuto
	MostraErro()
	lOk := .F.
	lErro := .T.
EndIf

cD3NumSeq := SD3->D3_NUMSEQ

MV_PAR01 := cMvPar01Old

HS_ResArea(aArea)
DbSelectArea(cAliasOld)
Return({lOk, cD3NumSeq})

Function HS_VldLote(cChave, nIndSb8, cMsgLot, lBlqVld)
 Local lRet := .T., aArea := {{"SB8", 0, 0}}, cAliasOld := Alias()
 Local cNumLote := "", cLoteFor := "", cLoteCtl := "", dDtValid := CToD(" ")

 Default lBlqVld := .T.

 cMsgLot := IIf(cMsgLot == Nil, STR0100, cMsgLot) //"Lote Invalido"
 
 aArea := HS_SavArea(aArea)
 
 DbSelectArea("SB8")
 DbSetOrder(nIndSb8)
 If !DbSeek(xFilial("SB8") + cChave)
  If lBlqVld
   Help(STR0010, 1, "FUNCLOTNAO",, cMsgLot, 1)
  Endif
  lRet := !lBlqVld  
 Else
  cNumLote := SB8->B8_NUMLOTE
  cLoteFor := SB8->B8_LOTEFOR
  cLoteCtl := SB8->B8_LOTECTL 
  dDtValid := SB8->B8_DTVALID  
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return({lRet, cNumLote, cLoteFor, cLoteCtl, dDtValid})
                            
// Retorna Custo do Filme
Function HS_CusFil(cCodFrx)
 Local cAliasOld := Alias(), aArea := HS_SavArea({{"GA7", 0, 0}}), vCusFil := 0
 DbSelectArea("GA7")
 DbSetOrder(1)
 If DbSeek(xFilial("GA7") + PadR(AllTrim(cCodFrx), Len(GA7->GA7_CODPRO)))
  vCusFil := GA7->GA7_CUSTOP
 EndIf
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(vCusFil)

// Retorna Log do Usuário
Function HS_LogArq()
 Local cLog := cUserName + " - " + StrZero(Day(Date()), 02) + "/" + StrZero(Month(Date()), 02) + "/" + Str(Year(Date()), 04) + " - " + Time() + "h"
Return(cLog)
            
// Verifica se é Urgencia, se for retorna .T. caso contrario .F.
Function HS_FUrgDes(nFUConv, cTipAte, cCodLoc, cCodPla, cCodDes, dDatDes, cHorDes, cUrgDes)
 Local lRet := .F., cAliasOld := Alias(), aArea := HS_SavArea({{"GCY", 0, 0}, {"GA9", 0, 0}})
 Local lFeriado := .F., cDiaSem := "", cCFUExa := ""
 Local cMvCTipExa := AllTrim(GetMV("MV_CTIPEXA")), lExceUrg := .F., lHoraUrg := .F.
 Local cTipPro := Posicione("GA7", 1, xFilial("GA7") + cCodDes, "GA7_TIPPRO")
 Local cCodCon := Posicione("GCM", 2, xFilial("GCM") + cCodPla, "GCM_CODCON")
  
 Default nFUConv := 0 
 Default dDatDes := dDataBase
 Default cHorDes := Time()
 
 If cTipAte == "0" // Internação
  nFUConv := HS_RCfgCP(cCodCon, cCodPla, "_FAUINT", dDatDes)
 Else 
  nFUConv := HS_RCfgCP(cCodCon, cCodPla, "_FAUAMB", dDatDes)
 EndIf 

 // Checa se o Setor atende urgência
 cAliasOld := Alias()
 DbSelectArea("GCS")
 DbSetOrder(1)
 If !DbSeek(xFilial("GCS") + cCodLoc)
   HS_MsgInf("Setor ["+ cCodLoc +"] não cadastrado!", "Atenção", "Cadastro de Setor") 
 EndIf
 
 if GCS->GCS_ATEURG <> "1" // Setor NAO atende urgência
  cUrgDes := "0"
 EndIf
 DbSelectArea(cAliasOld) 
 
 // Se foi lançado como 0-Nao ou 1-Sim para urgencia calcula de forma manual desconsidera os outros parametros
 If  cUrgDes == "0" .OR. cTipAte $ "3" // 0-Nao para urgencia 
  Return(.F.)
 ElseIf cUrgDes == "1" // 1-Sim para Urgencia
  Return(.T.)
 EndIf
 
 lFeriado := HS_IsFreeDay(dDatDes) // Verifica se é feriado
 
 // Verificar se o setor esta no cadastro de excecoes, se estiver com o tipo 8 nao calcula urgencia.
 lExceUrg := HS_LDesExc(cCodCon, cCodPla, "8", cCodLoc, dDatDes)[1]

 // Verifica se o procedimento esta no cadastro de exceções, se estiver com o tipo 5 não calcula urgencia.
 If !lExceUrg .And. !Empty(cCodDes)
  lExceUrg := HS_LDesExc(cCodCon, cCodPla, "5", cCodDes, dDatDes)[1]
 EndIf 
       
 If lFeriado
  cDiaSem := "0"
 Else
  cDiaSem := AllTrim(Str(Dow(dDatDes)))
 EndIf
                                          
 lHoraUrg := FS_HoraUrg(cHorDes, cCodPla, cCodDes, dDatDes, cDiaSem)

 cCFUExa := HS_RCfgCP(cCodCon, cCodPla, "_CFUEXA", dDatDes)
              
 // Se o lancamento ou o atendimento estiver definido como urgencia descarta todos os outro parametros
 // Se esta contido no horario de urgencia
 // Se for exame Não calcula urgencia se não for permitido calculo de urgencia pra exames
 If IIf(!lExceUrg, lHoraUrg, .F.)
  If IIf(cTipPro $ cMvCTipExa, cCFUExa == "1", .T.)
   lRet := .T.
  EndIf 
 EndIf 
                         
 HS_ResArea(aArea)     
 DbSelectArea(cAliasOld)     
Return(lRet)

Function HS_LDesExc(cCodCon, cCodPla, cOriDes, cCodPro, dVigencia)
 Local aRet := {.F., "0"}, cAliasOld := Alias()
 Local cCodGpa := HS_IniPadr("GA7", 1, cCodPro, "GA7_CODGPP",, .F.)
 
 Default dVigencia := dDataBase
 
 cCodPro := PadR(AllTrim(cCodPro), Len(GA4->GA4_CODDES))
 
 If cOriDes $ "1/5" // 1-Procedimentos ou 5-Urgencia
  If !(aRet := FS_VigExc(cCodCon, cCodPla, cOriDes, cCodPro, dVigencia))[1]
   // Caso não encontre o procedimento no cadastro de exceções procura por grupo
   aRet := FS_VigExc(cCodCon, cCodPla, IIf(cOriDes == "1", "6", "7"), cCodGpa, dVigencia)
  EndIf 
 Else
  aRet := FS_VigExc(cCodCon, cCodPla, cOriDes, cCodPro, dVigencia)
 EndIf
 DbSelectArea(cAliasOld)
Return(aRet)

Function FS_VigExc(cCodCon, cCodPla, cOriDes, cCodPro, dVigencia)
 Local cAliasOld := Alias(), vRet := {.F., "1"}
 
 DbSelectArea("GA4")
 DbSetOrder(1)
 DbSeek(xFilial("GA4") + cCodCon + cCodPla + cOriDes + cCodPro)
 
 While GA4->GA4_FILIAL == xFilial("GA4") .And. GA4->GA4_CODCON == cCodCon .And. ;
       GA4->GA4_CODPLA == cCodPla        .And. GA4->GA4_ORIDES == cOriDes .And. ;
       GA4->GA4_CODDES == cCodPro        .And. !Eof() 
       
  If dVigencia >= GA4->GA4_DATVIG
   vRet[1] := .T.                   
   vRet[2] := GA4->GA4_FATPAR
  Else 
   Exit
  EndIf
     
  DbSkip()
  Loop
 End
 
 DbSelectArea(cAliasOld)
Return(vRet)
            
Function HS_ValDif(cCodCon, cCodPla, cOriDes, cCodPro, dVigencia)
 Local vRet := {.F., 0, ""}, cAliasOld := Alias()
 
 cCodPro := PadR(AllTrim(cCodPro), Len(GAC->GAC_CODPRO))
 
 DbSelectArea("GAC")
 DbSetOrder(1)
 DbSeek(xFilial("GAC") + cCodCon + cCodPla + cOriDes + cCodPro)
 While GAC->GAC_FILIAL == xFilial("GAC") .And. GAC->GAC_CODCON == cCodCon .And. ;
       GAC->GAC_CODPLA == cCodPla .And. GAC->GAC_ARQORI == cOriDes .And. ;
       GAC->GAC_CODPRO == cCodPro .And. !Eof()
         
  If dVigencia >= GAC->GAC_DATVIG
   vRet[1] := .T.
   vRet[2] := GAC->GAC_VALPRO    
  Else 
   Exit
  EndIf
    
  DbSkip()
  Loop
 End
 
 DbSelectArea(cAliasOld)
Return(vRet)

Function HS_CHDifGr(cCodCon, cCodPla, cCodPro, cCpoGrp, dVigencia)
 Local vRet := {.F., 0}, cAliasOld := Alias()
 Local cCodGpa := HS_IniPadr("GA7", 1, cCodPro, "GA7_CODGPP",, .F.)
 
 Default dVigencia := dDataBase
  
 vRet := FS_VigCHDG(cCodCon, cCodPla, cCodGpa, cCpoGrp, dVigencia)
 
 DbSelectArea(cAliasOld)
Return(vRet)

Static Function FS_VigCHDG(cCodCon, cCodPla, cCodPro, cCpoGrp, dVigencia)
 Local vRet := {.F., 0}, cAliasOld := Alias()
 
 cCodPro := PadR(AllTrim(cCodPro), Len(GA5->GA5_CODGPA))
 
 DbSelectArea("GA5")
 DbSetOrder(1)
 DbSeek(xFilial("GA5") + cCodCon + cCodPla + cCodPro)
 While GA5->GA5_FILIAL == xFilial("GA5") .And. GA5->GA5_CODCON == cCodCon .And. ;
       GA5->GA5_CODPLA == cCodPla .And. GA5->GA5_CODGPA == cCodPro .And. !Eof()
         
  If dVigencia >= GA5->GA5_DATVIG .And. &("GA5->GA5" + cCpoGrp) > 0
   vRet[1] := .T.                   
   vRet[2] := &("GA5->GA5" + cCpoGrp)
  Else 
   Exit
  EndIf
    
  DbSkip()
  Loop
 End
 
 DbSelectArea(cAliasOld)
Return(vRet)

Function HS_ChDifPl(cCodCon, cCodPla, cTipChf, dVigencia, cCodLoc)
 Local vRet := {.F., 0}, cAliasOld := Alias()
 
 Default cCodLoc := ""
 
 DbSelectArea("GA6")
 DbSetOrder(1)
 If Empty(cCodLoc) .Or. !DbSeek(xFilial("GA6") + cCodCon + cCodPla + cTipChf + cCodLoc)
  cCodLoc := Space(Len(GA6->GA6_CODLOC))
  DbSeek(xFilial("GA6") + cCodCon + cCodPla + cTipChf + cCodLoc)
 EndIf 
 
 While GA6->GA6_FILIAL == xFilial("GA6") .And. GA6->GA6_CODCON == cCodCon .And. ;
       GA6->GA6_CODPLA == cCodPla        .And. GA6->GA6_TIPCHF == cTipChf .And. ;
       GA6->GA6_CODLOC == cCodLoc        .And. !Eof()
  
  If GA6->GA6_MODLOC == "0"
   If dVigencia >= GA6->GA6_DATVIG
    vRet[1] := .T.                   
    vRet[2] := GA6->GA6_CHSVAL
   Else 
    Exit
   EndIf
  EndIf 
    
  DbSkip()
  Loop
 End
 
 DbSelectArea(cAliasOld)
Return(vRet)

Function HS_DesPla(cCodCon, cCodPla)
 Local cDesPla := Space(Len(GCM->GCM_DESPLA)), cAliasOld := Alias()
 
 DbSelectArea("GCM")
 DbSetOrder(1)
 If DbSeek(xFilial("GCM") + cCodCon + cCodPla)
  cDesPla := GCM->GCM_DESPLA
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(cDesPla)
         
//Grava numero do orçamento e dados da nota fiscal gerada no GCY
// Parametros 
//  cNumOrc  - Numero do Orcamento
//  nValTot  - Valor total da venda sem descontos e no caso de venda parcelada
//             devera conter o acumulado total das parcelas
//  nValRec  - Valor total recebido a vista ja subtraido o desconto
//  nValDesc - Valor do desconto
//  cSerie   - Serie da nota fiscal
//  cNroNF   - Numero da nota fiscal
//  
// Essa funcao é executada na finalizacao da venda no siga loja.
Function HS_ConfRAt(cNumOrc, nValTot, nValRec, nValDesc, cSerie, cNroNF)
 Local aArea := GetArea()
 
 DbSelectArea("GCZ")
	DbSetorder(14)     
	DbSeek(xFilial("GCZ") + cNumOrc)
	
	While !Eof() .And. GCZ->GCZ_NUMORC == cNumOrc

	 RecLock("GCZ", .F.)   
   GCZ->GCZ_STATUS := "4"
   GCZ->GCZ_DATSTA := dDatabase
   GCZ->GCZ_DATFAT := dDataBase
   GCZ->GCZ_HORFAT := Time()
   GCZ->GCZ_NRFATU := cNroNF
   GCZ->GCZ_NRNOTA := cNroNF
   GCZ->GCZ_SERIE  := cSerie
   GCZ->GCZ_VLGUIA := nValRec
  MsUnLock()
  
	 DbSkip()
	End 
	
	RestArea(aArea)

Return(.T.)

// Essa funcao é executada na exclusao da nota fiscal e na exclusao do orcamento dentro do sigaloja.
Function HS_ExclRAt(cNumOrc, lExclNF)
Local aArea := GetArea()
 
DbSelectArea("GCZ")
DbSetorder(14)
DbSeek(xFilial("GCZ")+cNumOrc)
	
While !Eof() .And. GCZ->GCZ_NUMORC == cNumOrc

	If HS_ExisDic({{"T","GN0"}})
		//Gravação na Tabela de Log Exclusao
		DbSelectArea("GN0")
		M->GN0_CODLOG := HS_VSxeNum("GN0", "M->GN0_CODLOG", 1)
		ConfirmSx8()     

		RecLock("GN0", .T.)   
		GN0->GN0_CODLOG := M->GN0_CODLOG
		GN0->GN0_REGATE := GCZ->GCZ_REGATE
		GN0->GN0_NRSEQG := GCZ->GCZ_NRSEQG
		GN0->GN0_NUMORC := GCZ->GCZ_NUMORC
		GN0->GN0_DATEXC := DDATABASE
		GN0->GN0_HOREXC := TIme()
		GN0->GN0_DATFAT := GCZ->GCZ_DATFAT
		GN0->GN0_HORFAT := GCZ->GCZ_HORFAT
		GN0->GN0_NRFATU := GCZ->GCZ_NRFATU
		GN0->GN0_NRNOTA := GCZ->GCZ_NRNOTA
		GN0->GN0_SERIE  := GCZ->GCZ_SERIE
		GN0->GN0_VLGUIA := GCZ->GCZ_VLGUIA	 
		MsUnLock()
	EndIf 
	 
DbSelectArea("GCZ")
RecLock("GCZ", .F.)   
	
	If lExclNF
		GCZ->GCZ_DATFAT := CToD(" ")
		GCZ->GCZ_HORFAT := Space(Len(GCZ->GCZ_HORFAT))
		GCZ->GCZ_NRFATU := Space(Len(GCZ->GCZ_NRFATU))
		GCZ->GCZ_NRNOTA := Space(Len(GCZ->GCZ_NRNOTA))
		GCZ->GCZ_SERIE  := Space(Len(GCZ->GCZ_SERIE ))
		GCZ->GCZ_VLGUIA := 0 
		GCZ->GCZ_STATUS := "2"
		
		If !EMPTY(GCZ->GCZ_NRLOTE)
			GCZ->GCZ_NRLOTE	:= Space(Len(GCZ->GCZ_NRLOTE)) 	
		Endif
 			
	Else 	
		GCZ->GCZ_NUMORC := Space(Len(GCZ->GCZ_NUMORC))
		GCZ->GCZ_STATUS := IIF(SubStr(FunName(), 1, 6) == "HSPM24", "0", "2")
   
		If !EMPTY(GCZ->GCZ_NRLOTE) .and. GCZ->GCZ_STATUS =="2" 
			GCZ->GCZ_NRLOTE	:= Space(Len(GCZ->GCZ_NRLOTE)) 	
		Endif
 
	EndIf  	
  	
GCZ->GCZ_DATSTA := dDataBase 
MsUnLock()
                                              
DBSkip()
End
 
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldSenh  ºAutor ³ Suporte Rdmake    º Data ³  02/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Programa para valida‡Æo de senha quando do momento de fina-º±±
±±º          ³ lizar documentos                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQDO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldSenh()
Local cSenHsp := Space(25)
Local cUsuHsp := Space(25)
Local llPassW := .F.
Local aInfoUsr := PswRet() 
 
DEFINE MSDIALOG oDlgSenha TITLE STR0163 FROM 0,0 TO 120,320 PIXEL                             //"Senha"
	@ 010,002 Say OemToAnsi(STR0164) Size 050, 009 PIXEL COLOR CLR_BLUE //"Nome do Usuario: "
	@ 010,055 MSGet oEdit1 var cUsuHsp Size 100, 009 OF oDlgSenha PIXEL COLOR CLR_BLACK  
	@ 025,002 Say OemToAnsi(STR0165) Size 050, 009 PIXEL COLOR CLR_BLUE //"Senha do Usuario: "
	@ 025,055 MSGet oEdit2 var cSenHsp PASSWORD Size 100, 009 OF oDlgSenha PIXEL COLOR CLR_BLACK  
	oBtn1 := tButton():New(040, 55, STR0171, oDlgSenha, {|| QdoPsw(cUsuHsp, cSenHsp, @llPassW)}, 048, 014,,,, .T.)  // Encaixar //"Confirmar"
ACTIVATE MSDIALOG oDlgSenha CENTERED
 
PswOrder(2)
PswSeek(cUserName,.T.)
PswName(aInfoUsr[1][3])
Return(llPassW)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QdoPsw    ºAutor  ³ Suporte Rdmake     º Data ³  02/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Valida a senha digitada.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQDO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QdoPsw(cUsuHsp, cSenHsp, llPassW)
Local i := 0
Local _daduser  :={}

PswOrder(2)

If PswSeek(cUsuHsp, .T.)
	_daduser := PswRet(1)
	If PswName(cSenHsp)
		If PswAdmin(_daduser[1][2],_daduser[1][3],_daduser[1][1]) == 0
			llPassW := .T.
		Else
			MsgInfo(STR0168,STR0163) //"Este usuario nao tem permissao de administrador!"###"Senha"
			llPassW:=.F.
		EndIf
	Else
		MsgInfo(STR0167,STR0163) //"A senha esta incorreta!"###"Senha"
		llPassW:=.F.
	EndIf
Else
	MsgInfo(OemToAnsi(STR0169),OemToAnsi(STR0170))   //"Usu rio nao cadastrado!"###"Usu rio"
Endif
                                           
oDlgSenha:End()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_VldDesc º Autor ³ Jose Orfeu       º Data ³  Maio/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida desconto                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldDesc(nValDesc, nValMed)
 LOCAL lSenha := .F.
 
 lSenha := GetMv("MV_ATEDESC")  
 
 If nValDesc < 0
  MsgStop(STR0108, STR0109) //"O valor do desconto nao pode ser menor que 0!"###"Atencao!"
  Return .F.
 ElseIf nValDesc > nValMed
  MsgStop(STR0110, STR0109) //"O valor do desconto nao pode ser maior que o valor da despesa!"###"Atencao!"
  Return .F.   
 Else
  If nValDesc > 0
   If lSenha
    If !HS_VldSenh()
     nValDesc := 0
     nValMed  := nValMed 	 
     Return .F.
    Else
     nValMed := nValMed - nValDesc
     Return .T.
    EndIf
   Else
    nValMed := nValMed - nValDesc
    Return .T.     
   EndIf            
  EndIf   
 EndIf
Return .T. 

Function HS_RDescCC(cCodCCu)
 Local cDesCCu := Space(Len(IIf(CtbInUse(), CTT->CTT_DESC01, SI3->I3_DESC))), cAliasOld := Alias()
 
 If CtbInUse()
  DbSelectArea("CTT")
  DbSetOrder(1)
  If DbSeek(xFilial("CTT") + PadR(AllTrim(cCodCCu), Len(CTT->CTT_CUSTO)))
   cDesCCu := CTT->CTT_DESC01
  EndIf 
 Else
  DbSelectArea("SI3")
  DbSetOrder(1)
  If DbSeek(xFilial("SI3") + PadR(AllTrim(cCodCCu), Len(SI3->I3_CUSTO)))
   cDesCCu := SI3->I3_DESC
  EndIf 
 EndIf
 
 DbSelectArea(cAliasOld)
Return(cDesCCu)

Function HS_VldCCu(cCodCCu, cDesCCu, lVldCCA)
 Local cAliasOld := Alias(), lRet := .F.
 Local cMascCus  := AllTrim(GetMv("MV_MASCCUS"))
 Local nLenCus   := 0, nForPos := 0
 
 Default lVldCCA := .F. //Indica se deve validar ou nao se o centro de custo eh analitico
 
 &(cDesCCu) := Space(Len(IIf(CtbInUse(), CTT->CTT_DESC01, SI3->I3_DESC)))
 
 If CtbInUse()
  DbSelectArea("CTT")
  DbSetOrder(1)
  If DbSeek(xFilial("CTT") + PadR(AllTrim(cCodCCu), Len(CTT->CTT_CUSTO)))
   If !lVldCCA .or. CTT->CTT_CLASSE == "2"
    &(cDesCCu) := CTT->CTT_DESC01
    lRet := .T.
   Endif 
  EndIf 
 Else
  DbSelectArea("SI3")
  DbSetOrder(1)
  If DbSeek(xFilial("SI3") + PadR(AllTrim(cCodCCu), Len(SI3->I3_CUSTO)))
   If lVldCCA
    For nForPos := 1 to len(cMascCus)
     nLenCus += Val(SUBSTR(cMascCus, nForPos, 1))
    Next nForPos
   Endif 
   If !lVldCCA .or. Len(AllTrim(cCodCCu)) == nLenCus //se sim, o centro de custo eh analitico
    &(cDesCCu) := SI3->I3_DESC
    lRet := .T.
   Endif 
  EndIf 
 EndIf        
 
 If !lRet
  MsgStop(IIF(lVldCCA, STR0133, STR0111), STR0010) //"Centro de custo não encontrado ou nao analitico"
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)

Function HS_IsFreeDay(dDatDes)
 Local lRet := .F., aFeriados := RetFeriados()
 
 If aScan(aFeriados, DToS(dDatDes)) > 0
  lRet := .T.
 EndIf 
 
Return(lRet)
                
Function HS_RCfgCP(cCodCon, cCodPla, cCfg, dVigencia, cCodLoc, cTabPre)
 Local vRetCfg := "", aArea := GetArea()
 Local cCpoGc1 := "", cCpoGa9 := "", cTipo := "", vChEDif := {.F., 0}
 Local lAchouGa9 := .F., lAchouGc1 := .F.                                      
 Local aRVldVig := {{"", "GC1" + cCfg}}
 
 Default cTabPre := ""
 Default dVigencia := dDataBase
                               
 // Caso a tabela não use o indice financeiro do plano retorna 1 como indice financeiro
 If !Empty(cTabPre) .And. cCfg $ "_VLCHEX/_VLCHHO/_VLCHCO" .And. HS_IniPadr("GDB", 1, cTabPre, "GDB_USAIND",, .F.) == "0"
  
  vRetCfg := 1
 
 Else
 
  If GA9->GA9_CODCON <> cCodCon
   DbSelectArea("GA9")
   IIf(IndexOrd() == 1, .T., DbSetOrder(1))
   DbSeek(xFilial("GA9") + cCodCon)
  EndIf 
               
  If (lAchouGa9 := FS_CpoReal("GA9" + cCfg))[1]
   cCpoGa9 := &("GA9->GA9" + cCfg)
  Else 
   cCpoGa9 := ""
  EndIf                   
  
  cCpoGc1 := cCpoGa9 
                                                  
  If (lAchouGc1 := FS_CpoReal("GC1" + cCfg))[1]
   If HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cCodPla + "'", "GC1_DATVIG", @aRVldVig, dVigencia)
    cCpoGc1 := aRVldVig[1][1]
   Else
    cCpoGc1 := IIF(lAchouGc1[2] == "N", 0, IIF(lAchouGc1[2] == "D", CToD(""), ""))
   EndIf
  EndIf
  
  cTipo := IIf(lAchouGc1[1], lAchouGc1[2], IIf(lAchouGa9[1], lAchouGa9[2], "U"))
  
  If lAchouGa9[1] .Or. lAchouGc1[1]
   If cTipo $ "C/D"
    If !lAchouGa9[1] .Or. !Empty(cCpoGc1) .And. cCpoGc1 # Replicate("X", Len(cCpoGc1))
     vRetCfg := cCpoGc1
    Else 
     vRetCfg := cCpoGa9
    EndIf 
   ElseIf cTipo == "N"
    If !lAchouGa9[1] .Or. cCpoGc1 > 0
     vRetCfg := cCpoGc1
    Else 
     vRetCfg := cCpoGa9
    EndIf 
   EndIf                
  Else
   Final(STR0156 + AllTrim(cCfg) + STR0157) //"Campo ["###"] não encontrado (GA9/GC1), informe ao administrador do sistema"
  EndIf 
  
 EndIf 
 
 // Verifica diferenciados    
 If     cCfg == "_VLCHEX" // CH dos Exames
  vChEDif := HS_ChDifPl(cCodCon, cCodPla, "0", dVigencia, cCodLoc)
 ElseIf cCfg == "_VLCHHO" // CH dos Honorarios
  vChEDif := HS_ChDifPl(cCodCon, cCodPla, "1", dVigencia, cCodLoc)
 ElseIf cCfg == "_VM2FRX" // Valor do M2 do filme
  vChEDif := HS_ChDifPl(cCodCon, cCodPla, "2", dVigencia, cCodLoc)
 ElseIf cCfg == "_VLCHCO" // CH dos Custos Operacionais
  vChEDif := HS_ChDifPl(cCodCon, cCodPla, "3", dVigencia, cCodLoc)
 EndIf  
    
 If vChEDif[1]
  vRetCfg := vChEDif[2]
 EndIf 
 
 RestArea(aArea)
Return(vRetCfg)

Static Function FS_HoraUrg(cHorDes, cCodPla, cCodDes, dDatDes, cDiaSem)
 Local lRet := .F., cAliasOld := Alias()
 Local aTabPre := {}, cCodCon := Posicione("GCM", 2, xFilial("GCM") + cCodPla, "GCM_CODCON")
 
 DbSelectArea("GDG")
 DbSetOrder(1)
 DbSeek(xFilial("GDG") + cCodCon + cCodPla + cDiaSem)
 While !Eof() .And. GDG->GDG_FILIAL == xFilial("GDG") .And. GDG->GDG_CODCON == cCodCon .And. ;
                    GDG->GDG_CODPLA == cCodPla        .And. GDG->GDG_DIASEM == cDiaSem
                    
  If cHorDes >= GDG->GDG_HINACR .And. cHorDes <= GDG->GDG_HFIACR
   lRet := .T.
   Exit
  EndIf 
  
  DbSkip()
 End
  
 If !lRet
  If Len(aTabPre := HS_RTabPre("GC6", cCodPla, cCodDes, dDatDes)) > 0
 
   DbSelectArea("GCN")
   DbSetOrder(1)
   DbSeek(xFilial("GCN") + aTabPre[1] + cDiaSem)
             
   While !Eof() .And. GCN->GCN_TABPRO == aTabPre[1] .And. GCN->GCN_DIASEM == cDiaSem
    If cHorDes >= GCN->GCN_HINURG .And. cHorDes <= GCN->GCN_HFIURG
     lRet := .T.
     Exit
    EndIf 
    
    DbSkip()
   End
  EndIf 
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)

Function HS_RSeqRem(cCodCon)
 Local rSeqRem := Replicate("0", Len(GA9->GA9_SEQREM)), aArea := HS_SavArea({{"GA9", 0, 0}}), cAliasOld := Alias()
                        
 DbSelectArea("GA9")
 DbSetOrder(1)
 If DbSeek(xFilial("GA9") + cCodCon)
  rSeqRem := Soma1(PadL(GA9->GA9_SEQREM, Len(GA9->GA9_SEQREM), "0"), Len(GA9->GA9_SEQREM))
  RecLock("GA9", .F.)
   GA9->GA9_SEQREM := rSeqRem
  MsUnLock()  
 EndIf 
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(rSeqRem)

Function HS_LAltCpo(cSx3Campo)
 Local lRet := .T., aArea := HS_SavArea({{"SX3", 0, 0}}), cAliasOld := Alias()
 
 DbSelectArea("SX3")
 DbSetOrder(2)
 If DbSeek(cSx3Campo)
  lRet := IIf(SX3->X3_VISUAL == "V", .F., .T.)
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_CPDifCon³ Autor ³ Robson Ramiro A. Olive³ Data ³ 02.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o cod do procedimento utilizado para excessao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_CPDifCon                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_CPDifCon(cAtendi, cCodCon, cCodPla, cTabPro, cCodEsp, cCodPro, dDatDes, cHorDes, cUrgDes, cCodLoc)

Local cHorPro   := "0"
Local cCPDifCon := {}
Local aSeek 	:= {}
Local nX		:= 0
Local nLin		:= 0
Local nLenLoc   := Len(GCR->GCR_CODLOC)
Local nLenEsp   := Len(GCR->GCR_CODESP)
Local nLenPla   := Len(GCR->GCR_CODPLA)
Local aRVldVig  := {{"", "GCR_DATVIG"}}
Local dVigencia := DTOS(DDATABASE)

cCodPro := PadR(AllTrim(cCodPro), Len(GA7->GA7_CODPRO))

Default cAtendi := " "
Default cCodEsp := Space(nLenEsp)

GA7->(DbSetOrder(1))
GA7->(DbSeek(xFilial("GA7") + cCodPro))

If !Empty(cAtendi) .And. Empty(cUrgDes)
 cHorPro := IIf(HS_FUrgDes(, cAtendi, cCodLoc, cCodPla, cCodPro, dDatDes, cHorDes, cUrgDes), "1", "0")
ElseIf !Empty(cUrgDes)
 cHorPro := cUrgDes 
EndIf 

//Validacao para buscar a partir da ultima vigencia da tabela de Cod. Proc. Convenio
 If HS_VldVig("GCR", "GCR_FILIAL = '" + xFilial("GCR") + "' AND GCR_CODPLA = '" + cCodPla + "' AND GCR_CODPRO = '" + cCodPro + "'", "GCR_DATVIG", @aRVldVig, dDatDes)
  dVigencia := aRVldVig[1][1]
 EndIf 
// Array com todas as combinacoes de busca possiveis conforme regra de negocio
aSeek := { 	cCodPla	      	+	cCodEsp       	+	cCodLoc 	      +	cHorPro + dVigencia,;
												cCodPla	      	+	cCodEsp       	+	cCodLoc 	      +	"2"     + dVigencia,;
												cCodPla       	+	cCodEsp       	+	Space(nLenLoc)	+	cHorPro + dVigencia,;
												cCodPla       	+	cCodEsp 	    +	Space(nLenLoc)	+	"2"     + dVigencia,;
												cCodPla       	+	Space(nLenEsp)	+	cCodLoc       	+	cHorPro + dVigencia,;
												cCodPla       	+	Space(nLenEsp)	+	cCodLoc 	      +	"2"     + dVigencia,;
												cCodPla       	+	Space(nLenEsp)	+	cCodLoc 	      +	"0"     + dVigencia,;
												cCodPla       	+	Space(nLenEsp)	+	Space(nLenLoc)	+	"0"     + dVigencia,;
												cCodPla	      	+	Space(nLenEsp)	+	Space(nLenLoc)	+	cHorPro + dVigencia,;												
												cCodPla	      	+	Space(nLenEsp)	+	Space(nLenLoc)	+	"2"     + dVigencia,;
												Space(nLenPla)	+	cCodEsp       	+	cCodLoc 	      +	cHorPro + dVigencia,;
												Space(nLenPla)	+	cCodEsp       	+	cCodLoc       	+	"2"     + dVigencia,;
												Space(nLenPla)	+	cCodEsp       	+	Space(nLenLoc)	+	cHorPro + dVigencia,;
												Space(nLenPla)	+	cCodEsp 	      +	Space(nLenLoc)	+	"2"     + dVigencia,;
												Space(nLenPla)	+	Space(nLenEsp)	+	cCodLoc 	      +	cHorPro + dVigencia,;
												Space(nLenPla)	+	Space(nLenEsp)	+	cCodLoc 	      +	"2"     + dVigencia,;
												Space(nLenPla)	+	Space(nLenEsp)	+	Space(nLenLoc)	+	"0"     + dVigencia,;
												Space(nLenPla)	+	Space(nLenEsp)	+	Space(nLenLoc)	+	"2"     + dVigencia }


GCR->(DbSetOrder(2))

For nX := 1 To Len(aSeek)
	If GCR->(DbSeek(xFilial("GCR") + cCodCon + cCodPro + aSeek[nX]))
		aAdd(cCPDifCon, GCR->GCR_CPROUT)
		aAdd(cCPDifCon, GCR->GCR_DPROUT)
		aAdd(cCPDifCon, GCR->GCR_VLRPRO)
		Exit
	Endif
Next nX

If Empty(cCPDifCon)  .AND. Len(aRVldVig[1]) > 1 //Verifica se ha mais de uma configuracao para o mesmo com vigencias validas
	
	If HS_VldVig("GCR", "GCR_FILIAL = '" + xFilial("GCR") + "' AND GCR_CODPLA = '" + cCodPla + "' AND GCR_DATVIG <> '" + dVigencia + "' AND GCR_CODPRO = '" + cCodPro + "'", "GCR_DATVIG", @aRVldVig, dDatDes)
		aSeek := {}
		For nLin := 1 to Len(aRVldVig[1])
			AADD(aSeek , 	cCodPla	      	+	cCodEsp       	+	Space(nLenLoc)  +	"0"     + aRVldVig[1][nLin])
			AADD(aSeek , 	cCodPla	      	+	Space(nLenEsp) 	+	Space(nLenLoc)  +	"0"     + aRVldVig[1][nLin])
			AADD(aSeek , 	cCodPla     	+	Space(nLenEsp)	+	Space(nLenLoc)	+	cHorPro + aRVldVig[1][nLin])
			AADD(aSeek , 	cCodPla	      	+	cCodEsp       	+	cCodLoc        +	"0"     + aRVldVig[1][nLin])
			AADD(aSeek , 	cCodPla	      	+	Space(nLenEsp) 	+	cCodLoc        +	"0"     + aRVldVig[1][nLin])
		Next nLin
	EndIf
EndIf


GCR->(DbSetOrder(2))

For nX := 1 To Len(aSeek)
	If GCR->(DbSeek(xFilial("GCR") + cCodCon + cCodPro + aSeek[nX]))
		aAdd(cCPDifCon, GCR->GCR_CPROUT)
		aAdd(cCPDifCon, GCR->GCR_DPROUT)
		aAdd(cCPDifCon, GCR->GCR_VLRPRO)
		Exit
	Endif
Next nX	
	

If Empty(cCPDifCon)
 aAdd(cCPDifCon, "")
 aAdd(cCPDifCon, "")
 aAdd(cCPDifCon,  0)
EndIf

If Empty(cCPDifCon[1]) .Or. Empty(cCPDifCon[2])
	GA8->(DbSetOrder(1))
	If GA8->(DbSeek(xFilial("GA8") + cCodPro + cTabPro)) .And. Empty(cCPDifCon[1])
	 cCPDifCon[1] := GA8->GA8_CODPRT
 ElseIf Empty(cCPDifCon[1])
  cCPDifCon[1] := cCodPro
	Endif
	
	If Empty(cCPDifCon[2])
	 cCPDifCon[2] := GA7->GA7_DESC
	EndIf 
Endif

Return cCPDifCon

Function HS_DifData(dParIni, dParFin)
 Local nAnos, nMeses, nDias, nForM, dDataAux, nMesAtu, nAnoAtu
 Local nPMes := 0, aMeses := {{0, 28}, {0, 29}, {0, 30}, {0, 31}}
	Local dDataIni , dDataFin
	
	If Empty(dParIni) .Or. Empty(dParFin)
	 Return({0, 0, 0})
	EndIf

	If dParIni > dParFin
		dDataFin := dParIni
		dDataIni := dParFin
 Else
		dDataFin := dParFin
		dDataIni := dParIni
 EndIf
 
 nAnos	 := DateDiffYear (dDataIni,dDataFin )
 nDias  := DateDiffDay  (dDataIni,dDataFin )
 
 nMeses	:= HS_DifMes(dDataIni, dDataFin)
 
 nMesAtu := Month(dDataIni)
 nAnoAtu := Year(dDataIni)
 
 For nForM := 1 To nMeses
  dDataAux := CToD("01/" + StrZero(nMesAtu, 2) + "/" + StrZero(nAnoAtu, 4), "DDMMYYYY")
  nPMes := aScan(aMeses, {| aVet | aVet[2] == f_UltDia(dDataAux)})
  aMeses[nPMes][1]++
  
  nMesAtu++
  If nMesAtu > 12
   nMesAtu := 1
   nAnoAtu++
  EndIf
 Next
                                      
 For nForM := 1 To 4
  nDias -= (aMeses[nForM][1] * aMeses[nForM][2])
 Next 
 
 nMeses	:= Abs(nMeses - (nAnos  * 12))
Return({nAnos, nMeses, nDias})

Function HS_DifMes(dDate1, dDate2)
 Local nTmpDt1 := ( year(dDate1) * 12 ) + month(dDate1)
 Local nTmpDt2 := ( year(dDate2) * 12 ) + month(dDate2)
 Local nDayDt1 := day(dDate1) , nDayDt2 := day(dDate2)
Return(Abs(nTmpDt2 - nTmpDt1) + IIF(dDate2 > dDate1, IIF(nDayDt2 < nDayDt1, -1, 0), IIF(nDayDt2 > nDayDt1, -1, 0)))

Function HS_TAMD()
 Local oDlgData, oDataI, oDataF, dDataI := MSDate(), dDataF := MSDate(), oIdade,  oMeu
 Local cIdade := Space(100)
 Local cMeu := Space(100)
 
	set date british
	set century on 
	set epoch to 1950
	
 DEFINE MSDIALOG oDlgData TITLE OemToAnsi(STR0132) From 5,14 To 11,76	// Of oMainWnd //"Teste de Idade"

  @ 005,004 MSGet oDataI var dDataI PICTURE "@D" OF oDlgData PIXEL 
  @ 017,004 MSGet oDataI var dDataF PICTURE "@D" OF oDlgData PIXEL 
  @ 029,004 MSGet oIdade var cIdade PICTURE "@D" OF oDlgData PIXEL 

  DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (FS_Idade(dDataI, dDataF, @cIdade)) ENABLE OF oDlgData

 ACTIVATE MSDIALOG oDlgData CENTERED
Return(Nil)                                                            

Static Function FS_Idade(dDataI, dDataF, cIdade)
 Local aIdade := HS_DifData(dDataI, dDataF)

 cIdade := StrZero(aIdade[1], 2) + STR0158 + StrZero(aIdade[2], 2) + STR0159 + StrZero(aIdade[3], 2) + STR0160 //" ano(s) "###" mes(es) "###" dia(s) "
Return(.T.)

Function HS_AgeGer(dDataNasc, dDataAtu)

 Local aIdade := {}
       
 Default dDataAtu := dDataBase
 
 aIdade := HS_DIFDATA(dDataNasc, dDataAtu)
 
Return(Str(aIdade[1], 3, 0) + "a" + Str(aIdade[2], 2, 0) + "m" + Str(aIdade[3], 2, 0) + "d")

Function HS_IniPadr(cAlias, nOrdem, cChave, cCampo, lSoftSeek, lInclui, cChvURel, cFilAlias)
//cChvURel: se veio preenchido, a rotina deve retornar conteudo somente se ha somente 1 registro para esta chave

 Local aArea := GetArea()
 Local cRet := "", cAliasOld := Alias()
 Local cChvPesq := ""
 Local cChvComp := ""
 Local cInic    := ""
 Local aAreaSX3 := HS_SavArea({{"SX3", 0, 0}})
  
 Default lSoftSeek := .F.
 Default lInclui   := .T.
 Default cFilAlias := ""
 Default cChave	:= "" 
 
 cChvPesq := IIF(!Empty(cFilAlias) .And. !Empty(xFilial(cAlias)), cFilAlias, xFilial(cAlias)) + cChave
 
 If !Empty(cChvURel)
  cChvComp := cAlias + "->" + PrefixoCpo(cAlias) + "_FILIAL + " + cAlias + "->" + cChvURel
 Endif 
                                            
 If cCampo <> Nil .And. !Empty(cCampo)
  SX3->(DbSetOrder(2))
  SX3->(DbSeek(cCampo))
  cInic := IIf(SX3->X3_TIPO == "D", CToD(" "), IIf(SX3->X3_TIPO == "N", 0, SPACE(SX3->X3_TAMANHO)))
  cRet  := cInic
 EndIf 
  
 If !Empty(cChave) .And. IIf(lInclui .And. Type("Inclui") <> "U", !Inclui, .T.)
  IIf((cAlias)->(IndexOrd()) == nOrdem, .T., (cAlias)->(DbSetOrder(nOrdem)))
  If (cAlias)->(DbSeek(cChvPesq, lSoftSeek)) .And. cCampo <> Nil .And. !Empty(cCampo)
   cRet := (cAlias)->(FieldGet(FieldPos(cCampo)))
   If !Empty(cChvURel)
    (cAlias)->(DbSkip())
	    cRet := IIf((cAlias)->(Eof()) .Or. &(cChvComp) <> cChvPesq, cRet, cInic)
   Endif  
  EndIf
 EndIf
 
 HS_ResArea(aAreaSX3)
 If !Empty(cAliasOld)
  DbSelectArea(cAliasOld)
 Endif 

RestArea(aArea)
Return(cRet)
                                
// Esta rotina é executada na entrada do módulo
// o Protheus procura esta funcao no RPO , sigla do módulo + Load , no caso HSPLoad()
/*Function HSPLoad()
 IF !SetMDIChild(0)
  OpenLoja()
 EndIf       
Return(Nil)*/

Function HSPLoad()


If GETNEWPAR("MV_HSPCFIS", .F.) // Parametro que indica se o módulo HSP utiliza CF.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh um usuario fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __cUserID=="000000"
		cStrAcesso:="SNN"
	Else
		cNumCaixa := xNumCaixa() 
		If SX5->(DbSeek(xFilial("SX5")+'23'+ cNumCaixa ) )	
			DbSelectArea("SLF")
			DbSetOrder(1)
			DbSeek(xFilial("SLF")+SA6->A6_COD)
			cStrAcesso:=LF_ACESSO
		Else
			cStrAcesso := Repl("N", TamSx3("LF_ACESSO")[1])
		EndIf
	EndIf
	If LJProFile(3)
		IF !SetMDIChild(0)
			OpenLoja()
		EndIf
	EndIf
Else
	If !SetMDIChild( 0 )
		OpenLoja()
	EndIf
EndIf

Return(Nil)

                    
// Valida digito verificador modulo 11
 Function HS_VldM11(cCodMod11, nTamanho, nTDigVer, cTitulo, lVldTam, lVldMatric)
 Local nCodMod11 := 0, nDigMod11 := 0, nMulti := 9, nForMod11 := 1, lRet := .F.
                                                                                                             
 Default nTDigVer := 1
 Default nTamanho := 17                           
 Default lVldTam  := .T.                                                    
 Default cTitulo  := "" 
 Default lVldMatric := .T.  
 
 cTitulo += IIf(!Empty(cTitulo), "-", "")
                                                
 If lVldTam .And. Len(AllTrim(cCodMod11)) <> nTamanho
  Return({.F., cTitulo + STR0139}) // "Tamanho do codigo invalido"
 Endif 
  
 If !lVldMatric .And. Val(cCodMod11) == 0
  Return({.F., cTitulo + STR0144}) // "Matrícula inválida"
 Endif
 
 cCodMod11 := PadL(AllTrim(cCodMod11), nTamanho, "0")   
   
 nTamanho -= nTDigVer
 
 nDigMod11 := Val(Right(cCodMod11, nTDigVer)) 
 cCodMod11 := SubStr(cCodMod11, 1, nTamanho) 
   
 For nForMod11 := 1 To nTamanho
 
  nCodMod11 += (nMulti * Val(SubStr(cCodMod11, nForMod11, 1)))

  nMulti--
  nMulti := IIf(nMulti < 2, 9, nMulti)
                                                       
 Next

 nCodMod11 := Mod(nCodMod11, 11)
 nCodMod11 := 11 - nCodMod11
 
 If StrZero(nCodMod11, 2) $ "10/11"
  nCodMod11 := 0
 Endif
 
 lRet := nCodMod11 == nDigMod11

 Return({lRet, IIf(!lRet, cTitulo + STR0138, "")}) // "Digito verificador invalido"              
 
 
 Function HS_TotHoras(cHoraIni, cHoraInt, cModo, lSegundos, lIntervalo, lDecimal, nCasasDec)
 Local nHoraDec := 0, nHoraInt := 0, cHoraRet := "", nHoraRet := 0
 Local nSegIni := 0, nSegInt := 0, nSeg := 0, nHora := 0, nMin := 0
 
 Default cModo      := "+"                           
 Default lSegundos  := .F.                                             
 Default lIntervalo := .T.                                             
 Default lDecimal   := .F.                                                       
 Default nCasasDec  := 2
 
 cHoraIni := StrTran(cHoraIni, ":", "")
 cHoraInt := StrTran(cHoraInt, ":", "")
 
 If lSegundos

  nSegIni	:= Val(SubStr(cHoraIni, 1, 2)) * 3600 + Val(SubStr(cHoraIni, 3, 2)) * 60 + Val(SubStr(cHoraIni, 5, 2))
  nSegInt	:= Val(SubStr(cHoraInt, 1, 2)) * 3600 + Val(SubStr(cHoraInt, 3, 2)) * 60 + Val(SubStr(cHoraInt, 5, 2))
  
  If cModo == "+"
   nSeg	:= IIf(!lIntervalo .And. cModo == "+", nSegInt - nSegIni, nSegIni + nSegInt)
  Else 
   nSeg	:= IIf(lIntervalo, nSegIni - nSegInt, nSegInt - nSegIni)
  EndIf 
  
  // Formato Decimal
  nHoraRet := (nSeg / 3600)
  
  nHora	  := Int(nSeg / 3600)
  nSeg 	  -= (nHora * 3600)
  
  nMin	   := Int(nSeg / 60)
  nSeg 	  -= (nMin * 60)
  
  // Formato Hora
  cHoraRet := StrZero(nHora, 2) + ":" + StrZero(nMin, 2) + ":" + StrZero(nSeg, 2)
 
 Else
 
  nHoraDec := Val(SubStr(cHoraIni, 1, 2)) + (Val(SubStr(cHoraIni, 3, 2)) / 60)
  nHoraInt := Val(SubStr(cHoraInt, 1, 2)) + (Val(SubStr(cHoraInt, 3, 2)) / 60)
  
  If cModo == "+"
   nHoraDec := IIf(!lIntervalo .And. cModo == "+", nHoraInt - nHoraDec, nHoraDec + nHoraInt)
  Else 
   nHoraDec := IIf(lIntervalo, nHoraDec - nHoraInt, nHoraInt - nHoraDec)
  EndIf 
  
  // Formato Decimal
  nHoraRet := nHoraDec
 
  cHoraRet := StrZero(Int(nHoraDec), 2) + ":" + StrZero(((nHoraDec - Int(nHoraDec)) * 60), 2)
 Endif
 
Return(IIf(lDecimal, Round(nHoraRet, nCasasDec), cHoraRet))
                             
// Verifica se o campo existe no dicionario
Static Function FS_CpoReal(cCampo)
 Local lRet := .F., aArea := GetArea()
 
 DbSelectArea("SX3")
 DbSetOrder(2)
 lRet := DbSeek(cCampo)
 
 RestArea(aArea)
Return({lRet, SX3->X3_TIPO})       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldGui ºAutor  ³ Mario Arizono      º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida Nr Guia.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_VldGui(cCodPla, lMsgYesNo)
Local aRet := {}, lRet := .T., cGcmNrGui := "", aArea := GetArea()
Local oError := ErrorBlock({|e| HS_MsgInf(STR0172, STR0013, STR0141)})

Default lMsgYesNo := .T.

DbSelectArea("GCM")
DbSetOrder(2)
DbSeek(xFilial("GCM") + cCodPla)

cGcmNrGui := GCM->GCM_VLDGUI

If !Empty(cGcmNrGui)
	Begin Sequence
	aRet := &(cGcmNrGui)
		If ValType(aRet) == 'A' .And. ValType(aRet[1]) == 'L' .And. ValType(aRet[2]) == 'C'
			If !(lRet := aRet[1]) .And. lMsgYesNo
				HS_MsgInf(aRet[2], STR0025, STR0141) //"Atencao"##"Validação Nr Guia"
			EndIf
		Else
			HS_MsgInf(STR0172, STR0013, STR0141)
			lRet := .F.
		EndIf
	End Sequence
EndIf
ErrorBlock(oError)
RestArea(aArea)
Return(lRet)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VlNrGuiºAutor  ³ Mario Arizono      º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o digito verificador e valido.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_VlNrGui(cNrGuia, nTamanho, nDigVer, lVldMsg)
 Local nForGui := 1, nDigGui := 0, nTamGui := 0 
 Local cNumFin := ""
 Local lRet := .F.

 Default cNrGuia  := ""
 Default nDigVer  := 1
 Default nTamanho := 13                           
 Default lVldMsg  := .T.                                                    
                                                  
 If !Empty(cNrguia)
  If Len(AllTrim(cNrGuia)) <> nTamanho
   If lVldMsg
    Return({.F., STR0139}) // "Tamanho do codigo invalido"
   Endif
  Endif 
   
  nTamGui := nTamanho - nDigVer
   
  For nForGui := 1 To len(ALLTRIM(cNrGuia))
  
   If !(SUBSTR(cNrGuia,nForGui,1) $ "0123456789")
    If lVldMsg
     Return({.F., STR0142})//"Nr. da guia só deve conter números"
    Endif
   Endif
  
  Next nForGui
  
  cNumFin := SUBSTR(cNrGuia, 1, nTamGui)
  If VAL(cNumFin) == 0 
   If lVldMsg
    Return({.F., STR0143}) //"Nr. da guia não pode conter apenas zeros"
   Endif
  Endif  
  nResto  := VAL(SUBSTR(STRZERO(Mod(Val(cNumFin),11),nDigVer),1,nDigVer))
  nDigGui := VAL(SUBSTR(cNrGuia,(nTamanho-nDigVer)+1, nDigVer))
  lRet    := (nResto == nDigGui)
 Endif
Return({lRet, IIf(!lRet, STR0138, "")}) // "Digito verificador invalido"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_CposUsuºAutor  ³Daniel Peixoto      º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que adiciona no vetor os campos alteráveis criados   º±±
±±º          ³por usuario.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_CposUsu(aCpoAlt, cAlias)   
Local aAreaOld := GetArea()
Local aCposUsu := {}

 DbSelectArea("SX3")
 DbSetOrder(1) //X3_ARQUIVO

 DbSeek(cAlias)
 While !Eof() .And. SX3->X3_ARQUIVO == cAlias
 	If SX3->X3_PROPRI == "U" .And. SX3->X3_VISUAL == "A"
  	AADD(aCpoAlt, SX3->X3_CAMPO)
  	AADD(aCposUsu, SX3->X3_CAMPO)
  EndIf	
 	DbSkip()
 EndDo

 RestArea(aAreaOld) 

Return(aCposUsu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FilUsu ºAutor  ³Cibele Peria        º Data ³  12/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Converte o filtro do usuario (usado nos relatorios), para o º±±
±±º          ³formato SQL.                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilUsu(cAlias, cAliasQr)
 Local   nPos1    := 0
 Local   nPos2    := 0
 Local   cFilUsu  := Upper(aReturn[7])
 Default cAliasQr := "QRY"

 If Empty(cFilUsu)
  cFilusu := ".T."
 Else 
  cFilUsu := StrTran(cFilUsu, cAlias + "->", cAliasQr + "->")
  cFilUsu := StrTran(cFilUsu, cAlias + "_", cAliasQr + "->" + cAlias + "_")
  
  While (nPos1 := AT("DTOS(", Upper(cFilUsu))) > 0
   nPos2 := AT(") ", cFilUsu, nPos1) - 5
   If nPos1 == 1
    cFilUsu := Substr(cFilUsu, 6)
   Else 
    cFilUsu := Substr(cFilUsu, 1, nPos1-1) + Substr(cFilUsu, nPos1+5)
   Endif
   cFilUsu := Substr(cFilUsu, 1, nPos2-1) + Substr(cFilUsu, nPos2+1)
  End
 Endif 
Return(cFilUsu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldBrowºAutor  ³Darcio R. Sporl     º Data ³  27/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para validar se ha registros no browse.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VldBrowse(oMB)
Local lRet := .T.

If oMB:oBrowse:nLen <= 0	//	Verifica se ha registros no browse
	Help("",1,"ARQVAZIO")
	lRet := .F.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPFUNCS  ºAutor  ³Microsiga           º Data ³  09/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao do Modulo 11                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 Function HS_Modulo11(cCodMod11, nTamanho, nTDigVer, lVldTam, lVldMatric)
 Local nCodMod11 := 0, nDigMod11 := 0, lRet := .F.
                                                                                                             
 Default nTDigVer := 1
 Default nTamanho := 17                           
 Default lVldTam  := .T.                                                    
 Default cTitulo  := "" 
 Default lVldMatric := .T.  
 
                                               
 If lVldTam .And. Len(AllTrim(cCodMod11)) <> nTamanho
  Return({.F., cTitulo + STR0139}) // "Tamanho do codigo invalido"
 Endif 
  
 If !lVldMatric .And. Val(cCodMod11) == 0
  Return({.F., cTitulo + STR0144}) // "Matrícula inválida"
 Endif
 
 cCodMod11 := PadL(AllTrim(cCodMod11), nTamanho, "0")   
   
 nTamanho -= nTDigVer
 
 nDigMod11 := Val(Right(cCodMod11, nTDigVer)) 
 cCodMod11 := SubStr(cCodMod11, 1, nTamanho) 
   
 nCodMod11 := Mod(Val(cCodMod11), 11)
 
 If StrZero(nCodMod11, 2) $ "10/11"
  nCodMod11 := 0
 Endif
 
 lRet := nCodMod11 == nDigMod11

 Return({lRet, IIf(!lRet, STR0138, "")}) // "Digito verificador invalido"    
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPORCFAT  ºAutor  ³Saude               º Data ³  16/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a chamada para a rotina de aprovação de orçamento       º±±
±±º          ³ do Faturamento(5)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPORCFAT()

Local cSql	:= ""
Local aSCJ	:= {}

MATA416() //Efetivação do Orçamento

M57CHKORC()	//	Apaga Itens Relacionados aos Itens Excluidos no Orçamento 

/* ***************************************************************************** 
	VERIFICA SE EXISTE ALGUM ORÇAMENTO DO FATURAMENTO SCJ QUE NÃO ESTA INSERIDO 
	NO LOJA (SL1) APÓS A UTILIZAÇÃO DA ROTINA DE EFETIVAÇÃO DO ORÇAMENTO
********************************************************************************/
cSql := " SELECT CJ_NUM, CJ_STATUS, CJ_CLIENTE, CJ_EMISSAO FROM " + RetSqlName("SCJ") + " SCJ "
cSql += " WHERE SCJ.D_E_L_E_T_ <> '*' AND SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' AND "
cSql += " NOT EXISTS(SELECT 1 FROM " + RetSqlName("GT9") + " GT9 WHERE GT9.GT9_NUMFAT = SCJ.CJ_NUM AND "
cSql += " GT9.D_E_L_E_T_ <> '*' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "')" 
If HS_ExisDic({{"C", "GT9_COBRAN"}},.F.)
	cSql += " UNION "
	cSql += " SELECT CJ_NUM, CJ_STATUS, CJ_CLIENTE, CJ_EMISSAO "
	cSql += " FROM " + RetSqlName("SCJ") + " SCJ "
	cSql += " JOIN " + RetSqlName("GT9") + " GT9 ON GT9_NUMLOJ = '" + SPACE(TamSx3("GT9_NUMLOJ")[1]) + "' AND GT9_COBRAN = '1'"
	cSql += " AND GT9_NUMFAT = CJ_NUM AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "' AND GT9.D_E_L_E_T_ <> '*' 
	cSql += " WHERE CJ_STATUS = 'B' AND SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' AND SCJ.D_E_L_E_T_ <> '*' " 
EndIf
cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRYORC"
While !QRYORC->(Eof())
	QRYORC->(AADD(aSCJ, {CJ_NUM, CJ_STATUS, CJ_CLIENTE, CJ_EMISSAO, ""}))
	QRYORC->(DbSkip())
	EndDo
QRYORC->(DbCloseArea())
If Len(aSCJ) > 0
	MsgRun("Aguarde, atualizando venda...",, { || HS_AtuLoja(aSCJ)})  //"Aguarde, atualizando venda..."
EndIf

Return()
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AtuLoja ºAutor  ³Saude               º Data ³  16/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza as tabelas SL1 , SL2 E SL4 com os orçamentos       º±±
±±º          ³ baixados do Faturamento(5)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_AtuLoja(aOrc, cUsuario)
Local lGravou := .F., cTes := GetMV("MV_TESNFS"), cCodVend := GetMV("MV_VENDHSP")
Local aSL1 := {}, aSL2 := {},  aSL4 := {}, aGTJ := {}
Local cTabPre := "1"
Local cNumOrc := "", cMay := ""
Local cPagHsp := GetMV("MV_CPAGHSP") 
Local cItem 	:= "00"

Local nCntParc := 0 
Local nVlrTotal := 0
Local aArea := GetArea() 
Local nDiasValid := GETNEWPAR("MV_DIASVAL", 0)
Local nVlDProc := 0 
Local nVlDTotal := 0
Local nL := 0   
Local nIt 		:= 0 
Local nOrd 		:= 0 
Local aVigOrc	:= {} //PE de vigencia do tratamento
Local dVigIni	:= CTOD("")
Local dVigFim	:= CTOD("") 
Local lPct 		:= .F. 
Local aSLRet	:= {}
Local dDatAtOrc := GetNewPar("MV_RDCDTOR","")
//Local cItenf := Repl( "0", TamSX3( "D2_ITEM" )[1] )
Local lHsaTl1L2 := ExistBlock("HSATL1L2")
Local lHSFusVig := ExistBlock("HSFUSVIG")

Private lLoja	  := .F.

nCntParc := Len(Condicao(1000, cPagHsp))

Default cUsuario := cUserName

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se data do parametro MV_RDCDTOR inferior a 11/04/2013, altera para    ³     
//³ esta data pois e a data de correcao da gravacao do GTJ_ITEPAI         ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                               
If !Empty(dDatAtOrc) .And. Dtos(dDatAtOrc) < '20130411'
	dDatAtOrc := Stod('20130411') 
EndIf
 
DbSelectArea("SF4")
SF4->(DbSetOrder(1))
SF4->(DbSeek(xFilial("SF4") + cTes))
 
For nL := 1 To Len(aOrc) 
	cItem := "00"
	lPct := .F. 
	DbSelectArea("SCJ")
	DbSetOrder(1)
	DbSeek(xFilial("SCJ") + aOrc[nL,1])
		
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA)  
	aSL1 := {}
	aSL2 := {}
	aSL4 := {}
    If aOrc[nL,2] == 'B' // Caso já esteja baixado no faturamento e não pode ser alterado, inclui no Loja
		DbSelectArea("SL1")
		// A CriaVar do L1_NUM ira chamar a GetSxeNum()
		cNumOrc := CriaVar("L1_NUM")
		//cItenf := Repl( "0", TamSX3( "D2_ITEM" )[1] )   
		
		// Caso o SXE e o SXF estejam corrompidos o numero do orcamento estava se repetindo.
		cMay := Alltrim(xFilial("SL1")) + cNumOrc
		FreeUsedCode()
		SL1->(dbSetOrder(1))
		
		// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
		nTent := 0
		While SL1->(dbSeek(xFilial("SL1") + cNumOrc)) .Or. !MayIUseCode(cMay)
			If ++nTent > 20
				MsgStop(STR0087) //"Impossivel gerar número sequencial de orçamento correto. Informe ao administrador do sistema."
				Return(.F.)
			Endif
			ConfirmSx8()
			cNumOrc := CriaVar("L1_NUM")
			FreeUsedCode()
			cMay := Alltrim(xFilial("SL1")) + cNumOrc
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array aSL1                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aSL1, {"L1_FILIAL" , xFilial("SL1")})
		aAdd(aSL1, {"L1_EMISSAO", SCJ->CJ_EMISSAO})
		aAdd(aSL1, {"L1_NUM"    , cNumOrc      })
		aAdd(aSL1, {"L1_COMIS"  , 0             })
		aAdd(aSL1, {"L1_CLIENTE", SA1->A1_COD   })
		aAdd(aSL1, {"L1_LOJA"   , SA1->A1_LOJA  })
		aAdd(aSL1, {"L1_TIPOCLI", SA1->A1_TIPO  })
		aAdd(aSL1, {"L1_DESCONT", 0             })
		aAdd(aSL1, {"L1_DESCNF" , 0             })
		aAdd(aSL1, {"L1_DTLIM"  , dDataBase + nDiasValid })
		aAdd(aSL1, {"L1_CONDPG" , SCJ->CJ_CONDPAG })
		aAdd(aSL1, {"L1_PARCELA", nCntParc      })
		aAdd(aSL1, {"L1_FORMPG" , "R$"          })
		aAdd(aSL1, {"L1_CONFVEN", "SSSSSSSSNSSS"})
		aAdd(aSL1, {"L1_HORA"   , Time()        })
		aAdd(aSL1, {"L1_TPFRET" , ""            })
		aAdd(aSL1, {"L1_IMPRIME", "1N"          })
		aAdd(aSL1, {"L1_TIPODES", "0"           })
		aAdd(aSL1, {"L1_VEND"   , cCodVend      })
		If Hs_ExisDic({{"C", "L1_IMPNF"}}, .F.)
			aAdd(aSL1, {"L1_IMPNF"   , .T.      })
		EndIf
		
		MaFisEnd()
		MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", Nil, Nil, Nil, .F., "SB1", "LOJA701")
		
		// Adciona Procedimentos
		DbSelectArea("SCK")
		DbSetOrder(1)
		If DbSeek(xFilial("SCK") + SCJ->CJ_NUM)
			While !SCK->(Eof()) .AND. SCK->CK_NUM == SCJ->CJ_NUM //.AND. SCK->CK_FILIAL == SCJ->CJ_FILIAL
				If !lPct
					cItem := Soma1(cItem)	 
				EndIf
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1") + SCK->CK_PRODUTO))    
	
				DbSelectArea("GA7")
				GA7->(DbSetOrder(1))
	 			GA7->(DbSeek(xFilial("GA7") + PADR(SCK->CK_PRODUTO, TamSx3("GA7_CODPRO")[1])))			

				/*aItePct := HS_RetPct(GA7->GA7_CODPRO, 3) // Inclui itens do Pacote/Procedimento Padrão
				If Len(aItePct) > 0
					lPct := .T.
					FS_ADDPCT(aItePct,@aSL2, @cItem, cNumOrc)
					
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1") + SCK->CK_PRODUTO)) 					
					
					nVlrTotal += SB1->B1_PRV1
					nVlDTotal += SCK->CK_VALDESC
					SCK->(DbSkip())
					Loop
				Else
					lPct := .F.
				EndIf*/
				
				MaFisAdd(SCK->CK_PRODUTO, ; // Produto
				cTes    , ;	// Tes
				SCK->CK_QTDVEN       , ; // Quantidade
				SCK->CK_PRCVEN, ; // Preco unitario ja com desconto
				SCK->CK_VALDESC, ; // Valor do desconto
				""      , ; // Numero da NF original
				""      , ; // Serie da NF original
				0       , ;	// Recno da NF original
				0       , ; // Valor do frete do item
				0       , ; // Valor da despesa do item
				0       , ; // Valor do seguro do item
				0       , ; // Valor do frete autonomo
				SCK->CK_PRUNIT, ; // Valor da mercadoria sem desconto
				0)				      // Valor da embalagem
				
				//cIteNF			:= SomaIt( cIteNf )				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o array aSL2                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aSL2, {})
				aAdd(aSL2[Len(aSL2)], {"L2_FILIAL" , xFilial("SL2")       })
				aAdd(aSL2[Len(aSL2)], {"L2_NUM"    , cNumOrc              })
				aAdd(aSL2[Len(aSL2)], {"L2_ITEM"   , SCK->CK_ITEM			      }) // SCK->CK_ITEM    //cItem
				aAdd(aSL2[Len(aSL2)], {"L2_PRODUTO", SCK->CK_PRODUTO             })
				aAdd(aSL2[Len(aSL2)], {"L2_DESCRI" , GA7->GA7_DESC})
				aAdd(aSL2[Len(aSL2)], {"L2_QUANT"  , SCK->CK_QTDVEN})
				aAdd(aSL2[Len(aSL2)], {"L2_VRUNIT" , SCK->CK_PRCVEN})
				aAdd(aSL2[Len(aSL2)], {"L2_VLRITEM", SCK->CK_VALOR})
				aAdd(aSL2[Len(aSL2)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
				aAdd(aSL2[Len(aSL2)], {"L2_UM"     , SB1->B1_UM           })
				aAdd(aSL2[Len(aSL2)], {"L2_DESC"   , IIF(nVlDProc == 0, 0, (SCK->CK_VALDESC / SCK->CK_PRUNIT) * 100)})
				aAdd(aSL2[Len(aSL2)], {"L2_VALDESC", SCK->CK_VALDESC})
				aAdd(aSL2[Len(aSL2)], {"L2_DESCPRO", 0                    })
				aAdd(aSL2[Len(aSL2)], {"L2_TES"    , cTes                 })
				aAdd(aSL2[Len(aSL2)], {"L2_CF"     , SF4->F4_CF           })
				aAdd(aSL2[Len(aSL2)], {"L2_EMISSAO", SCJ->CJ_EMISSAO            })
				aAdd(aSL2[Len(aSL2)], {"L2_GRADE"  , "N"                  })
				aAdd(aSL2[Len(aSL2)], {"L2_VEND"   ,	cCodVend             })
				aAdd(aSL2[Len(aSL2)], {"L2_TABELA" ,	cTabPre              })
				aAdd(aSL2[Len(aSL2)], {"L2_PRCTAB" , SCK->CK_PRUNIT})
				aAdd(aSL2[Len(aSL2)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
				aAdd(aSL2[Len(aSL2)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
				aAdd(aSL2[Len(aSL2)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
				aAdd(aSL2[Len(aSL2)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
				aAdd(aSL2[Len(aSL2)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
				aAdd(aSL2[Len(aSL2)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
				aAdd(aSL2[Len(aSL2)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
				If SL2->(FieldPos("L2_BRICMS")) > 0
					aAdd(aSL2[Len(aSL2)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
				Endif
				If SL2->(FieldPos("L2_ICMSRET")) > 0
					aAdd( aSL2[Len(aSL2)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
				Endif
				nVlrTotal += SCK->CK_PRUNIT
				nVlDTotal += SCK->CK_VALDESC
				SCK->(DbSkip())
			EndDo
		EndIf
		
		aAdd(aSL1, {"L1_VLRTOT" , IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal)})
		aAdd(aSL1, {"L1_VLRLIQ" , IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal - nVlDTotal)})
		aAdd(aSL1, {"L1_VALBRUT", IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal)})
		aAdd(aSL1, {"L1_VALMERC", IIf(MaFisRet(, "NF_VALMERC") > 0, MaFisRet(, "NF_VALMERC"), nVlrTotal - nVlDTotal)})
		aAdd(aSL1, {"L1_DINHEIR", IIf(MaFisRet(, "NF_TOTAL"  ) > 0, MaFisRet(, "NF_TOTAL"  ), nVlrTotal - nVlDTotal)})
		aAdd(aSL1, {"L1_VALICM" , IIf(MaFisRet(, "NF_VALICM" ) > 0, MaFisRet(, "NF_VALICM" ), nVlrTotal - nVlDTotal)})
		aAdd(aSL1, {"L1_VALIPI" , IIf(MaFisRet(, "NF_VALIPI" ) > 0, MaFisRet(, "NF_VALIPI" ), nVlrTotal - nVlDTotal)})
		aAdd(aSL1, {"L1_VALISS" , IIf(MaFisRet(, "NF_VALISS" ) > 0, MaFisRet(, "NF_VALISS" ), nVlrTotal - nVlDTotal)})
		If SL1->(FieldPos("L1_BRICMS")) > 0
			aAdd(aSL1, {"L1_BRICMS",	IIf(MaFisRet(, "NF_BASESOL") > 0, MaFisRet(, "NF_BASESOL"), nVlrTotal - nVlDTotal)})
		Endif
		If SL1->(FieldPos("L1_ICMSRET")) > 0
			aAdd(aSL1, {"L1_ICMSRET", IIf(MaFisRet(, "NF_VALSOL") > 0, MaFisRet(, "NF_VALSOL" ), nVlrTotal - nVlDTotal)})
		Endif
		//Grava tabela SL4
		aAdd(aSL4, {})
		aAdd(aSL4[Len(aSL4)], {"L4_NUM    ", cNumOrc       })
		aAdd(aSL4[Len(aSL4)], {"L4_DATA   ", dDataBase     })
		aAdd(aSL4[Len(aSL4)], {"L4_VALOR  ", IIf(MaFisRet(, "NF_VALMERC") > 0, MaFisRet(, "NF_VALMERC"), nVlrTotal - nVlDTotal)})  // Valor
		aAdd(aSL4[Len(aSL4)], {"L4_FORMA  ", "R$"          })
		If lHsaTl1L2
			aSLRet := ExecBlock("HSATL1L2", .F., .F., {aSL1, aSL2, aSL4})
			aSL1 := aClone(aSLRet[1])
			aSL2 := aClone(aSLRet[2])
			aSL4 := aClone(aSLRet[3])
		EndIf
		lGravou := Lj7GrvOrc(aSL1, aSL2, aSL4)[1] 
	EndIf

	DbSelectArea("GT9")
	DbSetOrder(1)
	If DbSeek(xFilial("GT9") + aOrc[nL,1])
		If lGravou
			RecLock("GT9", .F.)
				GT9->GT9_NUMLOJ	:= cNumOrc
				GT9->GT9_STATUS	:= '2'
				If lHSFusVig // Ponto de Entrada da Vigencia do tratamento
					aVigOrc := ExecBlock("HSFUSVIG", .F., .F., {aOrc[nL,1], SA1->A1_COD})
					If ValType(aVigOrc) == "A"
						dVigIni := aVigOrc[1]
						dVigFim := aVigOrc[2]
					EndIf
					GT9->GT9_VIGINI	:= IIF(!Empty(dVigIni), dVigIni,GT9->GT9_VIGINI) 
					GT9->GT9_VIGFIN	:= IIF(!Empty(dVigFim), dVigFim,GT9->GT9_VIGFIN)									
				EndIf
			MsUnlock() 						
		EndIf
		If Hs_ExisDic({{"C", "GTJ_NUMORC"}}, .F.)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se os itens foram deletados do orcamento                     ³     
			//³ OBS: So atualiza itens lancados depois da data da correcao do chamado ³  
			//³ TGRZ14. Itens anteriores foram gravados com o GTJ_ITEPAI incorreto    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			SCJ->(DbSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
			If SCJ->(DbSeek(xFilial("SCJ")+aOrc[nL,1]))
				GTJ->(DbSetOrder(1))//GTJ_FILIAL+GTJ_NUMORC+GTJ_ITEM 
				SCK->(DbSetOrder(1))//CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
				If !Empty(dDatAtOrc) .And. GT9->GT9_DTEMIS >= dDatAtOrc .And.  GTJ->(DbSeek(xFilial("GTJ")+aOrc[nL,1])) 
					While GTJ->(GTJ_FILIAL+GTJ_NUMORC) == xFilial("GTJ")+aOrc[nL,1] .And. !GTJ->(Eof()) 
						If GTJ->GTJ_STATUS <> "2" .And. !SCK->(DbSeek(xFilial("SCK")+GTJ->(GTJ_NUMORC+Iif(Empty(GTJ->GTJ_ITEPAI),GTJ->GTJ_ITEM,GTJ_ITEPAI))))
							GTJ->(RecLock("GTJ", .F.))
							GTJ->GTJ_STATUS := "2"
							GTJ->(MsUnlock())
						EndIf
						GTJ->(DbSkip())
					EndDo
				EndIf
			EndIf
			
			//Ordenação do plano de tratamento conforme configuração
			aGTJ := {}
			For nIt := 1 To Len(aSL2)
				DbSelectArea("GA7")	
				DbGoTop()		
				DbSetOrder(1)
				If DbSeek(xFilial("GA7") + PADR(aSL2[nIt,4], TamSx3("GA7_CODPRO")[1])) 			
					DbSelectArea("GFR")
					DbGoTop()			
					DbSetOrder(1)
					DbSeek(xFilial("GFR") + GA7->GA7_CODESP) 
					AADD(aGTJ, {aOrc[nL,1], aSL2[nIt,3,2], GFR->GFR_PRIORI,GA7->GA7_PRIORI, aSL2[nIt,4,2]})
				Else
					AADD(aGTJ, {aOrc[nL,1], aSL2[nIt,3,2], "","", aSL2[nIt,4,2]})
				EndIf
			Next nIt
			aSort(aGTJ,,,{|x,y| x[3] + x[4] < y[3] + y[4]})		
			nOrd := 0
			For nIt := 1 To Len(aGTJ)
				nOrd := nOrd + 10 
				DbSelectArea("GTJ")
				DbSetorder(1)
				If !DbSeek(xFilial("GTJ") + aGTJ[nIt,1] + aGTJ[nIt,2])						
					If Len(HS_RetPct(PadR(AllTrim(aGTJ[nIt,5]), Len(GA7->GA7_CODPRO)), 3)) == 0 //Se não é principal de um pacote insere na GTJ
						RecLock("GTJ", .T.)
							GTJ->GTJ_FILIAL := xFilial("GTJ")
							GTJ->GTJ_NUMORC	:= aGTJ[nIt,1]
							GTJ->GTJ_ITEM	:= aGTJ[nIt,2]
							GTJ->GTJ_STATUS	:= '0'
							GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd)),TamSx3("GTJ_PRIORI")[1],"0")
							GTJ->GTJ_PRODUT := aGTJ[nIt,5]
						MsUnlock()
					EndIf
				EndIf 			
			Next nIt
		EndIf
	Else
		RecLock("GT9", .T.)
			GT9->GT9_FILIAL := xFilial("GT9")
			GT9->GT9_NUMFAT	:= aOrc[nL,1]
			GT9->GT9_NUMLOJ	:= IIf(lGravou,cNumOrc, SPACE(TamSx3("GT9_NUMLOJ")[1]))
			GT9->GT9_CLIENT	:= SA1->A1_COD			
			GT9->GT9_USUORC	:= cUsuario
			GT9->GT9_DTEMIS	:= SCJ->CJ_EMISSAO
			GT9->GT9_STATUS	:= '0' 
			If HS_ExisDic({{"C", "GT9_REGGER"}},.F.) .AND. !Empty(aOrc[nL,5])
				GT9->GT9_REGGER	:= aOrc[nL,5]					
			EndIf			
			If HS_ExisDic({{"C", "GT9_COBRAN"}},.F.)
				GT9->GT9_COBRAN	:= '1'
			EndIf
			If HS_ExisDic({{"C", "GT9_NRCONT"}},.F.)
				aCtrVig := HS_GETNRCTR(SA1->A1_COD)
				dVigIni := IIf(Empty(aCtrVig[2]), SCJ->CJ_EMISSAO, STOD(aCtrVig[2]))				
				dVigFim := IIf(Empty(aCtrVig[3]), SCJ->CJ_VALIDA, STOD(aCtrVig[3]))				
				If lHSFusVig // Ponto de Entrada da Vigencia do tratamento
					aVigOrc := ExecBlock("HSFUSVIG", .F., .F., {aOrc[nL,1], SA1->A1_COD})
					If ValType(aVigOrc) == "A"
						dVigIni := aVigOrc[1]
						dVigFim := aVigOrc[2]
					EndIf
				EndIf
				GT9->GT9_NRCONT	:= aCtrVig[1]//HS_GETNRCTR(SA1->A1_COD)
				GT9->GT9_VIGINI	:= dVigIni
				GT9->GT9_VIGFIN	:= dVigFim 
			EndIf			
			If ValType("__cCdJustGT9") # "U" .AND. !Empty(__cCdJustGT9) .AND. HS_ExisDic({{"C", "GT9_MTVAGE"}},.F.)
				GT9->GT9_MTVAGE := __cCdJustGT9
				GT9->GT9_USRFOR := __cCdUsrFGT9
			EndIf			
		MsUnlock() 		
	EndIf

	MaFisEnd()	
Next nL

RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_GETNRCTRºAutor  ³Saude               º Data ³  13/05/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza as tabelas SL1 , SL2 E SL4 com os orçamentos       º±±
±±º          ³ baixados do Faturamento(5)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GETNRCTR(cCodCli, lVigAnt)
Local aArea			:= GetArea()
Local cNrContrato 	:= ""  
Local cSql 			:= ""
Local dVigIni		:= CTOD("")
Local dVigFin		:= CTOD("")   

Default lVigAnt 	:= .F.

cSql := " SELECT GT9_NRCONT, GT9_VIGINI, GT9_VIGFIN FROM " + RetSqlName("GT9") +" GT9 "
cSql += " WHERE GT9_CLIENT  = '" + cCodCli + "' AND GT9_STATUS IN ('0','2','3','5') AND GT9_FILIAL = '" + xFilial("GT9") + "' AND D_E_L_E_T_ <> '*'"

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRYORC"

DbSelectArea("QRYORC")               
DbGoTop()
If !Eof()
	cNrContrato := QRYORC->GT9_NRCONT  
	If lVigAnt
		dVigIni := QRYORC->GT9_VIGINI
		dVigFin := QRYORC->GT9_VIGFIN
	EndIf
Else
	cNrContrato := GetSXENum('GT9','GT9_NRCONT')
EndIf	

While __lSx8
	ConfirmSx8()
End	         

DbSelectArea("QRYORC") 
DbCloseArea()

RestArea(aArea)
Return ({cNrContrato,dVigIni,dVigFin})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ADDPCT  ºAutor  ³Saude               º Data ³  05/07/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona os procedimentos do pacote aos itens do tratamentoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*
* *   F O R A   D E   U S O   * *

Static Function	FS_ADDPCT(aItens, aVetAdd, cItem, cNumOrc)
Local aArea := GetArea()
Local nI	:= 0				
Local cTes := GetMV("MV_TESNFS") 
Local cCodVend := GetMV("MV_VENDHSP")  

For nI := 1 To Len(aItens)
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + PADR(aItens[nI], TamSx3("B1_COD")[1])))
	
	DbSelectArea("GA7")
	GA7->(DbSetOrder(1))
	GA7->(DbSeek(xFilial("GA7") + PADR(aItens[nI], TamSx3("GA7_CODPRO")[1])))			

	MaFisAdd(	SB1->B1_COD, ; // Produto
				cTes    , ;	// Tes
				1       , ; // Quantidade
				SB1->B1_PRV1, ; // Preco unitario ja com desconto
				0, ; // Valor do desconto
				""      , ; // Numero da NF original
				""      , ; // Serie da NF original
				0       , ;	// Recno da NF original
				0       , ; // Valor do frete do item
				0       , ; // Valor da despesa do item
				0       , ; // Valor do seguro do item
				0       , ; // Valor do frete autonomo
				SB1->B1_PRV1, ; // Valor da mercadoria sem desconto
				0)				      // Valor da embalagem
	
	//cIteNF			:= SomaIt( cIteNf )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array aSL2                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aVetAdd, {})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_FILIAL" , xFilial("SL2")       	})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_NUM"    , cNumOrc              	})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_ITEM"   , cItem         			})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_PRODUTO", SB1->B1_COD			})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_DESCRI" , GA7->GA7_DESC})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_QUANT"  , 1})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VRUNIT" , SB1->B1_PRV1})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VLRITEM", SB1->B1_PRV1})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_LOCAL"  , SB1->B1_LOCPAD       })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_UM"     , SB1->B1_UM           })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_DESC"   , 0})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VALDESC", 0})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_DESCPRO", 0                    })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_TES"    , cTes                 })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_CF"     , SF4->F4_CF           })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_EMISSAO", SCJ->CJ_EMISSAO            })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_GRADE"  , "N"                  })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VEND"   , cCodVend             })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_TABELA" ,	"1"              })
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_PRCTAB" , SB1->B1_PRV1})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VALIPI" , MaFisRet(1, "IT_VALIPI" )})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VALICM" , MaFisRet(1, "IT_VALICM" )})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VALISS" , MaFisRet(1, "IT_VALISS" )})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_BASEICM", MaFisRet(1, "IT_BASEICM")})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_VALFRE" , MaFisRet(1, "IT_FRETE"  )})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_SEGURO" , MaFisRet(1, "IT_SEGURO" )})
	aAdd(aVetAdd[Len(aVetAdd)], {"L2_DESPESA", MaFisRet(1, "IT_DESPESA")})
	If SL2->(FieldPos("L2_BRICMS")) > 0
		aAdd(aVetAdd[Len(aVetAdd)], {"L2_BRICMS", MaFisRet(1, "IT_BASESOL")})
	Endif
	If SL2->(FieldPos("L2_ICMSRET")) > 0
		aAdd( aVetAdd[Len(aVetAdd)], {"L2_ICMSRET", MaFisRet(1, "IT_VALSOL")})
	Endif 
	cItem := Soma1(cItem)
Next nI
     
RestArea(aArea)
Return()
*/