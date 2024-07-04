#INCLUDE "EDCES150.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCES150  ³ Autor ³ Thomaz               ³ Data ³ 03/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de Relação Simplificada das Estruturas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------*
Function EDCES150()
*------------------*

EDCES150R3(.T.)

Return .T.

*------------------*
Function EDCES150R3(p_R4)
*------------------*
Local nOpca := 1, bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}, nx

Private lNegEstr:= EasyGParam("MV_NEGESTR"), cMarca:= GetMark(), lInverte:= .F.
Private cFilSG1:= xFilial("SG1"), cFilSB1:= xFilial("SB1"), cFilSA5:= xFilial("SA5")
Private cFilSW5:= xFilial("SW5"),cFilSW6:= xFilial("SW6"),cFilSW8:= xFilial("SW8"), cFilED0:= xFilial("ED0")
Private cFilEE9:= xFilial("EE9"), cFilED2:= xFilial("ED2")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cProdIni  := cProdFim  := Space(AVSX3("B1_COD",3)), cPergunte := "EDCES1"
Private cTipoIni  := cTipoFim  := Space(AVSX3("B1_TIPO",3)), cPed:= Space(AVSX3("ED0_PD",3))
Private cGrupoIni := cGrupoFim := Space(AVSX3("B1_GRUPO",3)), nRegSg1
Private cPictQuant := AVSX3("G1_QUANT",6), cPictPerda := AVSX3("G1_PERDA",6)
Private	cPictGrOp := AVSX3("G1_GROPC", 6)
Private cPictIni := AVSX3("G1_INI",6), cPictFim := AVSX3("G1_FIM",6)
// Private cPictOpc := AVSX3("G1_OPC", 6) -- ACSJ - 01/12/2004 - A mesma variavel esta sendo declarada na linha abaixo
   Private cPictOpc := AVSX3("B1_OPC",6)
Private cPictQb := AVSX3("B1_QB",6), lTop
Private cPictAC:= AVSX3("ED0_PD",6), cAlias := "SG1", cNomWork
cPictOpc := AVSX3("B1_OPC",6)
Private cMsg:= ""
Private lIsen := .F.
Private cCabec := ""
Private lMaior := .T.

PRIVATE lR4 := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()                  

//AAF 05/08/05
ED0->( dbSetOrder(1) )
ED1->( dbSetOrder(1) )
ED2->( dbSetOrder(1) )

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif
If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))

   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   SETKEY(VK_F4,{||If(ReadVar() == "MV_PAR01", EDCAC400HLP(@mv_par01), )})
   SETKEY(VK_F5,{||If(ReadVar() == "MV_PAR02", EDCAC400HLP(@mv_par02), )})

Endif


While .T.

   dbselectarea("SG1") // AAF 25/05/04 - É necessario haver um alias aberto antes da chamada ao pergunte
   If !Pergunte(cPergunte,.T.)
      Return .F.
   EndIf

   cProdIni  := mv_par01
   cProdFim  := mv_par02
   cPed      := mv_par03

   ED0->( dbSeek(cFilED0+cPed) )
   lIsen := ( ED0->ED0_MODAL == "2" )
   
   If lIsen
      SW8->( dbSetOrder(6) )
      EE9->( dbSetOrder(2) )      
   Else
      //IF EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas - NOPADO POR AOM - 04/11/10
         MsAguarde({|| IndRegua("ED8","EDCED8"+TEOrdBagExt(),"ED8_FILIAL+ED8_COD_I")})
      //ENDIF
      MsAguarde({|| IndRegua("SW8","EDCESSW8"+TEOrdBagExt(),"W8_FILIAL+W8_COD_I"),;  //AAF 04/08/05 - Indice para encontrar ultima importação do item.
                    IndRegua("EE9","EDCESEE9"+TEOrdBagExt(),"EE9_FILIAL+EE9_COD_I")})//AAF 04/08/05 - Indice para encontrar ultima exportação do item.
   Endif
   
   If nOpca == 1
      Processa({|| EDCES150IMP(lR4) })
   ElseIf nOpca == 0
      Exit
   EndIf

EndDo

E_EraseArq("EDCESSW8")
E_EraseArq("EDCESEE9")

// Desabilita o F4 e o F5 caso estejam ativos
SETKEY(VK_F4,NIL)
SETKEY(VK_F5,NIL)

dbSelectArea(cAlias)

Return

*-----------------------------*
STATIC FUNCTION EDCES150IMP(lR4)
*-----------------------------*
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2         := STR0002 //"de Relação de Estruturas."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Private titulo       := STR0003+If(!Empty(cPed), Space(100)+"Pedido de Drawback : "+Transf(cPed,cPictAC), "") //"Relatório de Relação de Estruturas."
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "SG1"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "EDCES150"
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCES150" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nPagina      := 0
Private lGera        := .F.
Private lImprime     := .F.

If lTop
   cAlias:= "SG1QUERY"
   Processa({|| GeraQuery()}, "Aguarde Pesquisando Dados")
Endif 

If !lR4
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)     
   If nLastKey = 27
      If lTop
         (cAlias)->(DbCloseArea())
      Endif
      Return 
   Endif 
   SetDefault(aReturn,cString)
   nTipo := If(aReturn[4]==1,15,18)    
   
Endif

CriaWorkDbf()

If lR4
   //TRP - 31/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
EndIf
   
Begin Sequence
   
If lTop
   If Select(cAlias) <> 0
      If lR4
         lImprime:= Imprime(wnRel,cString)
         IF !lImprime
            (cAlias)->(DbCloseArea())
            Break
         ENDIF    
         oReport:PrintDialog()
         lImprime:=.t.
         EDCESGERADBF()         
      Else
         RptStatus({|lEnd| lGera:= Imprime(wnRel,cString)})
      Endif
      If(lGera, EDCESGERADBF(), )
      (cAlias)->(DbCloseArea())
   Endif
Else
   RptStatus({|lEnd| Imprime(wnRel,cString)})
Endif

End Sequence
 
WORK->(E_EraseArq(cNomWork))

Return .T.

*--------------------------------------*
STATIC FUNCTION Imprime(wnrel,cString)
*--------------------------------------*
Local nTipo   := 0, bWhile:= {|| (cAlias)->G1_FILIAL == cFilSG1}
Local nX, nPosCnt := nPosOld := 0, cControle := "", lRet:= .T., i

Private nLin := 99, cFilED1:= xFilial("ED1"), lPedido:= .F.
Private nCol1:=06, nCol2:=nCol1+07, nCol3:=nCol2+35, nCol4:=nCol3+08
Private nCol5:=nCol4+41, nCol6:=nCol5+07, nCol7:=nCol6+20, nCol8:=nCol7+16
Private nCol9:=nCol8+10, nCol10:=nCol9+40, cProduto, nNivel, lImp:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//                             1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
//                   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
If lIsen
   cabec1 := "Nível                Código          TRT  Descrição                                               Qtde. Gross U.M.  Qtde. Gross  U.M.   Perda                 Quant. Net  Quant. Net  Tipo de    N.C.M."
   cabec2 := "                                                                                                    Estoque            Compra   Comerc.   %                     Estoque     Compra     Qtde."
Else
   cabec1 := STR0006 //"Nível                Código          TRT  Descrição                            Qtde. Gross U.M.   Qtde. Gross U.M.  Qtde. Gross  U.M.   Perda    Quant. Net   Quant. Net  Quant. Net  Tipo de    N.C.M."
   cabec2 := STR0007 //"                                                                                   NCM              Estoque            Compra   Comerc.   %         NCM         Estoque     Compra     Qtde."
Endif

If !lTop
   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbSeek(cFilSG1+cProdIni))
   If !Empty(cProdIni) .And. Empty(cProdFim)
      bWhile:= {|| (cAlias)->G1_FILIAL == cFilSG1 .And. (cAlias)->G1_COD >= cProdIni}
   ElseIf !Empty(cProdIni) .And. !Empty(cProdFim)
      bWhile:= {|| (cAlias)->G1_FILIAL == cFilSG1 .And. (cAlias)->G1_COD >= cProdIni .And. (cAlias)->G1_COD <= cProdFim}
   Else
      (cAlias)->(dbSeek(cFilSG1))
   Endif
Endif

EE7->(dbSetOrder(2))
//EE9->(dbSetOrder(1))

ProcRegua((cAlias)->(EasyRecCount()))

SG1->( DbSeek(cFilSG1+(cAlias)->G1_COD) )  //NCF - 31/07/2019 - Reposicionar o arquivo com base na primeira linha do ResultSet da query

While !(cAlias)->(EOF()) .And. If(lTop, Eval(bWhile), .T.)

   IncProc(STR0008+(cAlias)->G1_COD) //"Imprimindo Relação de Estrutura "
   SG1->( DbSeek(cFilSG1 + (cAlias)->G1_COD + (cAlias)->G1_COMP ) )  //NCF - 31/07/2019 - Reposicionar o arquivo com base no resultado da linha atual do resultSet da query
   nRegSg1 := SG1->(Recno())

   cProduto := (cAlias)->G1_COD
   nNivel   := 2

   If !Empty(cPed)
      If !ED1->(dbSeek(cFilED1+cPed+cProduto))
         (cAlias)->(dbSkip())
         Loop
      Endif
   Endif
   
   If cControle == (cAlias)->G1_COD
      (cAlias)->(dbSkip())
      Loop
   Else
      cControle := (cAlias)->G1_COD
   Endif

   (cAliasSB1)->(dbSetOrder(1))
   If (cAliasSB1)->(dbSeek(cFilSB1Aux+cProduto))

      SysRefresh()
	  If nLin > 54
	     Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   	     nLin := 09
	  Endif

      SYD->(dbSeek(xFilial("SYD")+If(lTop, (cAlias)->B1_POSIPI, (cAliasSB1)->B1_POSIPI)))

      //EE7->(dbGoBottom())
      
      //** AAF 04/08/05 - Unidade de Compra da ultima Exportação.
      If lIsen .AND. ED1->( dbSeek(cFilED1+cPed+cProduto) ) .AND.;
         ( !Empty(ED1->ED1_UMANEX) .OR. EE9->( dbSeek(cFilEE9+ED1->(ED1_PREEMB+ED1_PEDIDO+ED1_SEQUEN) )) )
         
         cUnidVen:= If(!Empty(ED1->ED1_UMANEX),ED1->ED1_UMANEX,EE9->EE9_UNIDAD)
      ElseIf EE9->( AvSeekLast(cFilEE9+cProduto) )
         cUnidVen:= EE9->EE9_UNIDAD
      Else
         cUnidVen:= If(lTop, (cAlias)->B1_UM, (cAliasSB1)->B1_UM)
      Endif
      //**
      
      
      If !lR4
         @ nlin,nCol1  PSAY STR0009 //"Prod.: "
         @ nlin,nCol2  PSAY cProduto
  	     @ nlin,nCol3  PSAY STR0010 //"Descr.: "
         @ nlin,nCol4  PSAY If(lTop, SubStr((cAlias)->B1_DESC,1,34), SubStr((cAliasSB1)->B1_DESC,1,34))
         @ nlin,nCol5  PSAY STR0011 //"U.M.: "
         @ nlin,nCol6  PSAY If(lTop, (cAlias)->B1_UM, (cAliasSB1)->B1_UM)
         @ nlin,nCol7  PSAY STR0012 //"Base Estrutura: "
         @ nlin,nCol8  PSAY If(lTop, If((cAlias)->B1_QB == 0,'      1',Transf((cAlias)->B1_QB, cPictQb)),If((cAliasSB1)->B1_QB == 0,'      1', Transf((cAliasSB1)->B1_QB, cPictQb)))
         @ nlin,nCol9  PSAY STR0017+Transf(If(lTop, (cAlias)->B1_POSIPI, (cAliasSB1)->B1_POSIPI), AVSX3("B1_POSIPI",6))+"  "+STR0018+SYD->YD_UNID  //"N.C.M.: " ### "UM da N.C.M.: "
         @ nlin,nCol10 PSAY STR0019+cUnidVen //"UM de Venda: "
      Endif
      
	  nlin += 2

   	  nPosOld:= nPosCnt

	  If lTop
         nPosCnt+= EDCES150EXP(cProduto,IF((cAlias)->B1_QB == 0,1,(cAlias)->B1_QB),nNivel,cPictQuant,cPictPerda,(cAlias)->B1_OPC,IF((cAlias)->B1_QB==0,1,(cAlias)->B1_QB),titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nRegSg1)
   	  Else
         nPosCnt+= EDCES150EXP(cProduto,IF((cAliasSB1)->B1_QB == 0,1,(cAliasSB1)->B1_QB),nNivel,cPictQuant,cPictPerda,(cAliasSB1)->B1_OPC,IF((cAliasSB1)->B1_QB==0,1,(cAliasSB1)->B1_QB),titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nRegSg1)
      Endif

      (cAlias)->(dbGoto(nRegSg1))

      For i:=nPosOld to nPosCnt
         IncProc()
      Next I
      
      If !lR4
         @ nlin,000 PSAY __PrtThinline()
      Endif
               
   	  nlin +=2
   	  
   	  lImp:= .T.

   Endif

   (cAlias)->(dbSkip())
   Loop

EndDo

SG1->(dbSetOrder(1))

If cMsg <> ""
   MsgStop("Não foi possivel realizar as seguintes conversões:"+cMsg)
Endif

If lImp
   If !lR4
      If aReturn[5] = 1
         Set Printer To
         Commit
         Ourspool(wnrel)
      EndIf
   endif
Else
   Help(" ",1,"AVG0005190") //MsgInfo(STR0019) //"Nao Ha Dados para Impressao !!!"
   lRet:= .F.
Endif

MS_FLUSH()

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função   ³EDCES150EXP ³                             ³ Data ³ 03/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição³ Faz a explosao de uma estrutura                             ±±
±±  Adaptação da Função MR225Expl() usado no Prgrama Matr225.PRX           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ EDCES150EXP(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpC4,ExpN3)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade do pai a ser explodida                  ³±±
±±³          ³ ExpN2 = Nivel a ser impresso                               ³±±
±±³          ³ ExpC2 = Picture da quantidade                              ³±±
±±³          ³ ExpC3 = Picture da perda                                   ³±±
±±³          ³ ExpC4 = Opcionais do produto                               ³±±
±±³          ³ ExpN3 = Quantidade do Produto Nivel Anterior               ³±±
±±³          ³ As outras 6 variaveis sao utilizadas pela funcao Cabec     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

*----------------------------------------------------------------------------------------------------------------------------------------*
Static Function EDCES150EXP(cProduto,nQuantPai,nNivel,cPictQuant,cPictPerda,cOpcionais,nQtdBase,Titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nRcNmbSG1)
*----------------------------------------------------------------------------------------------------------------------------------------*
Local nReg,nCntItens := 0
Local nPrintNivel
// Local nX      := 0 -- ACSJ - 01/12/2004 - Variavel não é usada.
Local nColun1 := 21
Local nColun2 := nColun1+16, nColun3 := nColun2+05, nColun4 := nColun3+36
Local nColun5 := nColun4+13, nColun6 := nColun5+06, nColun7 := nColun6+13
Local nColun8 := nColun7+05, nColun9 := nColun8+14, nColu10 := nColun9+07
Local nColu11 := nColu10+07, nColu12 := nColu11+13, nColu13 := nColu12+12
Local nColu14 := nColu13+14, nColu15 := nColu14+11
Local nFatGro := 0, nFatNet := 0

Private nQuantItem
Default nRcNmbSG1 := NIL

//SW8->(dbSetOrder(3))
SW6->(dbSetOrder(2))
SW5->(dbSetOrder(2))
SA5->(dbSetOrder(3))
EE7->(dbSetOrder(2))
//EE9->(dbSetOrder(1))
SG1->(dbSetOrder(1))
SG1->(dbSeek(cFilSG1+cProduto))

While !SG1->(Eof()) .And. cFilSG1 == xFilial("SG1") .And. SG1->G1_COD == cProduto
   nReg       := SG1->(Recno())
   nQuantItem := AvExplEstr(nQuantPai,,cOpcionais,,) // Função para a Explosão de Estrutura

   If lNegEstr .Or. (!lNegEstr .And. nQuantItem > 0 )
      
      If nlin > 54
         Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   		 nLin := 08

		 SB1->(dbSeek(cFilSB1+cProduto))
		 SYD->( dbSeek(xFilial("SYD")+SB1->B1_POSIPI))
         
         //EE7->(dbGoBottom())
         
         //** AAF 04/08/05 - Unidade de Compra da ultima Exportação.
         If lIsen .AND. ED1->( dbSeek(cFilED1+cPed+cProduto) ) .AND.;
            ( !Empty(ED1->ED1_UMANEX) .OR. EE9->( dbSeek(cFilEE9+ED1->(ED1_PREEMB+ED1_PEDIDO+ED1_SEQUEN) )) )
            
            cUnidVen:= If(!Empty(ED1->ED1_UMANEX),ED1->ED1_UMANEX,EE9->EE9_UNIDAD)
         ElseIf EE9->( AvSeekLast(cFilEE9+cProduto) )
            cUnidVen:= EE9->EE9_UNIDAD
         Else
            cUnidVen:= If(lTop, (cAlias)->B1_UM, (cAliasSB1)->B1_UM)
         Endif
         //**

         If !lR4
             @ nlin,nCol1 PSAY STR0009 //"Prod.: "
             @ nlin,nCol2 PSAY cProduto
             @ nlin,nCol3 PSAY STR0010 //"Descr.: "
             @ nlin,nCol4 PSAY If(lTop, SubStr((cAlias)->B1_DESC,1,34),SubStr((cAliasSB1)->B1_DESC,1,34))
             @ nlin,nCol5 PSAY STR0011 //"U.M.: "
             @ nlin,nCol6 PSAY If(lTop, (cAlias)->B1_UM, (cAliasSB1)->B1_UM)
             @ nlin,nCol7 PSAY STR0012 //"Base Estrutura:"
             @ nlin,nCol8 PSAY If(lTop, If((cAlias)->B1_QB == 0,'      1',Transf((cAlias)->B1_QB, cPictQb)),If((cAliasSB1)->B1_QB == 0,'      1', Transf((cAliasSB1)->B1_QB, cPictQb)))
             @ nlin,nCol9 PSAY STR0017+ Transf(If(lTop, (cAlias)->B1_POSIPI, (cAliasSB1)->B1_POSIPI), AVSX3("B1_POSIPI",6))+"  "+STR0018+SYD->YD_UNID  //"N.C.M.:"### "UM da N.C.M.: "
             @ nlin,nCol10 PSAY STR0019+cUnidVen  //"UM de Venda: "
         Endif
		 nlin += 2

      EndIf

	  SB1->(dbSeek(cFilSB1+SG1->G1_COMP))
	  nPrintNivel:=If(nNivel>17,17,nNivel-2)
      SYD->( dbSeek(xFilial("SYD")+SB1->B1_POSIPI))
      
      //SW6->(dbGoBottom())           
      
      //** AAF 04/08/05 - Unidade de Compra da ultima Importação.
      If lIsen .AND. ED2->( dbSeek(cFilED2+cPed+SG1->G1_COMP) ) .AND.;
         ( !Empty(ED2->ED2_UMANEX) .OR. SW8->( dbSeek(cFilSW8+ED2->(ED2_HAWB+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU) )) )
         cUnidCom:= If(!Empty(ED2->ED2_UMANEX),ED2->ED2_UMANEX,SW8->W8_UNID)
      ElseIf SW8->( AVSeekLast(cFilSW8+SG1->G1_COMP) )
         cUnidCom:= SW8->W8_UNID
      ElseIf  ED8->(AVSeekLast(XFILIAL("ED8")+SG1->G1_COMP)) //Alcir Alves - define se virá dados das DI´s externas - NOPADO POR  AOM 04/11/10 EasyGParam("MV_EDCDIE",,.F.) .AND.
         cUnidCom:= ED8->ED8_UM
      ElseIf SA5->(DbSeek(cFilSA5+cProduto))
         cUnidCom:= SA5->A5_UNID
      Else
         cUnidCom:= SB1->B1_UM
      Endif
      //**
      
      //ER - 25/09/2007
      If !Empty(cPed)
 
         EDC->(DbSetOrder(1))
         If EDC->(DbSeek(xFilial("EDC")+cPed+ED1->ED1_RE))
      
            If EDC->(FieldPos("EDC_QTDBAS")) > 0 .and. EDC->(FieldPos("EDC_PERDA")) > 0 .and. EDC->(FieldPos("EDC_QTDPRO")) > 0
         
               nFatGro := EDC->((EDC_QTDBAS * EDC_QTDEST) / EDC_QTDPRO)
               nFatNet := EDC->(nFatGro*(1 - EDC_PERDA/100))
      
               nQuantNCM   := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,nFatGro,.T.) //Gross
               nQuant2NCM  := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,nFatNet,.T.) //Net
               nQuantComp  := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,nQuantNCM,.T.)    //Gross
               nQuant2Comp := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,nQuant2NCM,.T.)  //Net
            
            Else
      
               nQuantNCM   := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,nQuantItem,.T.) //Gross
               nQuant2NCM  := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,SG1->G1_QUANT,.T.) //Net
               nQuantComp  := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,nQuantItem,.T.)     //Gross
               nQuant2Comp := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,SG1->G1_QUANT,.T.)  //Net
      
            EndIf
        
         EndIf
      
      Else
   
         nQuantNCM   := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,nQuantItem,.T.) //Gross
         nQuant2NCM  := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SG1->G1_COMP,SG1->G1_QUANT,.T.) //Net
         nQuantComp  := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,nQuantItem,.T.)     //Gross
         nQuant2Comp := AVTransUnid(SB1->B1_UM,cUnidCom,SG1->G1_COMP,SG1->G1_QUANT,.T.)  //Net
      
      EndIf
      
      //** AAF 04/08/05 - Mensagem caso não encontre as conversões.
      If nQuantNCM  == NIL
         cMsgA := Chr(13)+Chr(10)+"De "+SB1->B1_UM+" para "+SYD->YD_UNID
         If At(cMsgA,cMsg) == 0
            cMsg+= cMsgA
         Endif
         nQuantNCM  := 0
         nQuant2NCM := 0
      Endif
      If nQuantComp == NIL
         cMsgA := Chr(13)+Chr(10)+"De "+SB1->B1_UM+" para "+cUnidCom
         If At(cMsgA,cMsg) == 0
            cMsg+= cMsgA
         Endif
         nQuantComp  := 0
         nQuant2Comp := 0
      Endif
      //**
      
      If !lR4
         @ nlin,nPrintNivel PSAY StrZero(nNivel,3)
         @ nlin,nColun1 PSAY SG1->G1_COMP
         @ nlin,nColun2 PSAY SG1->G1_TRT
         @ nlin,nColun3 PSAY SubStr(SB1->B1_DESC,1,34)
     
	  
	     If !lIsen//AAF 05/08/05 - Não exibe NCM caso a Modalidade do Drawback seja Isenção.
            @ nlin,nColun4 PSAY Transf(nQuantNCM, cPictQuant)
            @ nlin,nColun5 PSAY SYD->YD_UNID
         Endif

         @ nlin,nColun6 PSAY Transf(nQuantItem, cPictQuant)
	     @ nlin,nColun7 PSAY SB1->B1_UM
	     @ nlin,nColun8 PSAY Transf(nQuantComp, cPictQuant)
	     @ nlin,nColun9 PSAY cUnidCom
	     @ nlin,nColu10 PSAY Transf(SG1->G1_PERDA, cPictPerda)
	  
	     If !lIsen//AAF 05/08/05 - Não exibe NCM caso a Modalidade do Drawback seja Isenção.
	        @ nlin,nColu11 PSAY Transf(nQuant2NCM, cPictQuant)
	     Endif
      
	     @ nlin,nColu12 PSAY Transf(SG1->G1_QUANT, cPictQuant)
	     @ nlin,nColu13 PSAY Transf(nQuant2Comp, cPictQuant)
	     @ nlin,nColu14 PSAY If(Left(SG1->G1_FIXVAR,1) = "V", STR0013 ,STR0014) //"Variável"###"Fixa"
	     @ nLin,nColu15 PSAY Transf(SYD->YD_TEC, AVSX3("YD_TEC",6) )
      
      Endif
	  nlin++
      
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Verifica se existe sub-estrutura                ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  nRecSG1 := SG1->(RECNO())
	  If SG1->(dbSeek(cFilSG1+SG1->G1_COMP))
         //** PLB 07/10/06
         dbGoto(nReg)
         EDCESGRVWORK(nNivel)
         SG1->(dbSeek(cFilSG1+SG1->G1_COMP))
         //**
	     EDCES150EXP(SG1->G1_COD,nQuantItem,nNivel+1,cPictQuant,cPictPerda,cOpcionais,IF((cAliasSB1)->B1_QB == 0,1,(cAliasSB1)->B1_QB),titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
      //** PLB 07/10/06
      Else
         dbGoto(nReg)
         EDCESGRVWORK(nNivel)
      //**
	  EndIf
	  SG1->(DBGOTO(nRecSG1))
      //dbGoto(nReg)
      //EDCESGRVWORK()
	  
   EndIf
   
   If nRcNmbSG1 <> NIL .And. nRcNmbSG1 <> 0  //NCF - 31/07/2019 - Reposicionar quando a variável for reativada devido a volta na primeira chamada da função EDCES150EXP (recursiva) 
      SG1->(DBGOTO(nRcNmbSG1))
      SG1->(DbSkip())
      nRcNmbSG1 := If( SG1->G1_COD == cProduto , SG1->(Recno()) , 0 )
      SG1->(DbSkip(-1))
   EndIf
   
   SG1->(dbSkip())
   nCntItens++
EndDo

nCntItens--

Return nCntItens

*--------------------------------*
Static Function GeraQuery()
*--------------------------------*
Local cQuery, aCondDel:= {}
// LOCAL cCond:= "", cCond1:= "", cTab:= "" -- ACSJ - 01/12/2004 Variavel não é usada.

aCondDel:={"AND SG1.D_E_L_E_T_ <> '*'", "AND SB1.D_E_L_E_T_ <> '*' ", "AND ED1.D_E_L_E_T_ <> '*' "}  //TRP-31/01/08

If cAliasSB1 == "SB1"
   cSB1ArqAux:=RetSqlName(cAliasSB1)
Else
   cSB1ArqAux:="SB1"+Strzero(Val(ALLTRIM(EasyGParam("MV_EMPEXP",,""))),2)+"0"
EndIf

cQuery:= "SELECT DISTINCT SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_FILIAL, SB1.B1_OPC, "
cQuery+= " SB1.B1_COD, SB1.B1_QB, SB1.B1_DESC, SG1.G1_FILIAL, SG1.G1_COMP, "
cQuery+= " SG1.G1_TRT, SG1.G1_COD, SG1.G1_OBSERV, SG1.G1_PERDA, SG1.G1_QUANT, "
cQuery+= " SG1.G1_FIXVAR, SG1.G1_INI, SG1.G1_FIM FROM "+cSB1ArqAux+" SB1, "
cQuery+= RetSqlName('SG1')+" SG1, "+RetSqlName('ED1')+" ED1 WHERE SB1.B1_FILIAL='"+ cFilSB1+"' "   //TRP-31/01/08 
cQuery+= If(TcSrvType()<>"AS/400",aCondDel[2],"")
cQuery+= " AND SG1.G1_COD = SB1.B1_COD "
If !Empty(cProdIni) .And. !Empty(cProdFim)                                 //NCF - 01/08/2019 - Ajuste da query conforme informações dispostas no filtro.
   cQuery+= " AND SG1.G1_COD BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
ElseIf !Empty(cProdIni)
   cQuery+= " AND SG1.G1_COD = '"+cProdIni+"' "
ElseIf !Empty(cProdFim)
   cQuery+= " AND SG1.G1_COD = '"+cProdFim+"' "
Endif
cQuery+= If(TcSrvType()<>"AS/400",aCondDel[3],"")  //TRP-31/01/08
If !Empty(cPed) //BHF-01/06/09
   cQuery+= " AND ED1.ED1_PD='"+ cPed+"' "   //TRP-31/01/08
Endif
cQuery+= " AND ED1.ED1_PROD = SG1.G1_COD"  //TRP-31/01/08
cQuery+= " AND SG1.G1_FILIAL='"+ cFilSG1+"'"
cQuery+= If(TcSrvType()<>"AS/400",aCondDel[1],"")+" ORDER BY SG1.G1_COD"

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAlias) NEW

If Len(alltrim(SG1->G1_COMP)) > 15  // BHF - 04/02/09
   lMaior := .F.
EndIf

If Select("Query") <> 0
   TCSETFIELD(cAlias,"G1_INI","D")
   TCSETFIELD(cAlias,"G1_FIM","D")
Endif

Return .T.


*---------------------------*
Function EDCES150VAL(cParam)
*---------------------------*
Local lRet:= .T.

If cParam == "MV_PAR01" .And. !Empty(MV_PAR01)
   If(!ExistCpo((cAliasSB1), MV_PAR01), lRet:= .F., )   
Endif

If cParam == "MV_PAR02" .And. !Empty(MV_PAR02)
   If(!ExistCpo((cAliasSB1), MV_PAR02), lRet:= .F., )
Endif

Return lRet


*------------------------------*
Static Function CriaWorkDbf()
*------------------------------*
Private aWork:={;
               {"PRODPAI"  ,"C",AVSX3("B1_COD",3)   ,0},;
               {"DESCPAI"  ,"C",AVSX3("B1_DESC",3)  ,0},;
               {"UMPAI"    ,"C",AVSX3("B1_UM",3)    ,0},;
               {"BASEEST"  ,"N",AVSX3("B1_QB",3)    ,0},;
               {"NCMPAI"   ,"C",AVSX3("B1_POSIPI",3),0},;
               {"UMNCM"    ,"C",AVSX3("B1_UM",3)    ,0},;
               {"UMVENDA"  ,"C",AVSX3("B1_UM",3)    ,0},;
               {"NIVEL"    ,"C",3 ,0},;
               {"PRODFIL"  ,"C",AVSX3("G1_COMP",3) ,0},;
               {"TRT"      ,"C",AVSX3("G1_TRT",3)   ,0},;
               {"DESCFIL"  ,"C",AVSX3("B1_DESC",3)  ,0},;
               {"QTDGRNCM" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"UMGRNCM"  ,"C",AVSX3("B1_UM",3)    ,0},;
               {"QTDGREST" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"UMGREST"  ,"C",AVSX3("B1_UM",3)    ,0},;
               {"QTDGRCOM" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"UMCOMER"  ,"C",AVSX3("B1_UM",3)    ,0},;
               {"PERDA"    ,"N",AVSX3("G1_PERDA",3) ,AVSX3("G1_PERDA",4)},;
               {"QTDNENCM" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"QTDNEEST" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"QTDNECOM" ,"N",AVSX3("G1_QUANT",3) ,AVSX3("G1_QUANT",4)},;
               {"TIPOQTD"  ,"C",8 ,0},;
               {"NCMFIL"   ,"C",AVSX3("YD_TEC",3),0}}

cNomWork:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IndRegua("Work",cNomWork+TEOrdBagExt(),"PRODPAI")

Return .T.

*-------------------------------*
Static Function EDCESGRVWORK(nNivel)  // PLB 07/10/06 - Incluido parametro nNivel para incrementar quando for sub-item
*-------------------------------*
Local nRec := 0
nRec := SG1->( RecNo() )
Work->(dbAppend())

Work->PRODPAI := cProduto
Work->DESCPAI := If(lTop, SubStr((cAlias)->B1_DESC,1,34),SubStr((cAliasSB1)->B1_DESC,1,34))
Work->UMPAI   := If(lTop, (cAlias)->B1_UM, (cAliasSB1)->B1_UM)
Work->BASEEST := If(lTop, If((cAlias)->B1_QB = 0,1,(cAlias)->B1_QB) , If((cAliasSB1)->B1_QB = 0, 1, (cAliasSB1)->B1_QB))
Work->NCMPAI  := If(lTop, (cAlias)->B1_POSIPI, (cAliasSB1)->B1_POSIPI)
Work->UMNCM   := SYD->YD_UNID
Work->UMVENDA := cUnidVen
Work->NIVEL   := StrZero(nNivel,3)
Work->PRODFIL := SG1->G1_COMP
Work->TRT     := SG1->G1_TRT
Work->DESCFIL := SubStr(SB1->B1_DESC,1,34)
Work->QTDGRNCM:= nQuantNCM
Work->UMGRNCM := SYD->YD_UNID
Work->QTDGREST:= nQuantItem
Work->UMGREST := SB1->B1_UM
Work->QTDGRCOM:= nQuantComp
Work->UMCOMER := cUnidCom
Work->PERDA   := SG1->G1_PERDA
Work->QTDNENCM:= nQuant2NCM
Work->QTDNEEST:= SG1->G1_QUANT
Work->QTDNECOM:= nQuant2Comp
Work->TIPOQTD := If(SG1->G1_FIXVAR =="V", "Variavel", "Fixa")
Work->NCMFIL  := SYD->YD_TEC

Return .T.

*-----------------------------*
Static Function EDCESGERADBF()
*-----------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0020 ; //"Geração de Arquivo DBF/TXT" 
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0021 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancelar

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet


***************************
Static Function ReportDef()
//Static Function ReportDef(cAlias, lTop)
***************************
Local nInc
Private nCont:= 0 
Private nTamanho := 0
      
   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem := {}

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EDCES150",STR0003,"EDCES1",{|oReport|ReportPrint(oReport)},STR0001+" "+STR0002)

   oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
   oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

   //Define o objeto com a seção do relatório      
   oSecao1 := TRSection():New(oReport,"Produto","Work",aOrdem) 
 
   //Define o objeto com a seção do relatório
   oSecao2 := TRSection():New(oReport,"Componentes","Work",aOrdem)     
                  
      //Definição das colunas de impressão da seção 1   
   TRCell():New(oSecao1,"PRODPAI"       ,""  ,""  ,"" ,Len("Prod: ")+AVSX3("B1_COD", 3)         ,/*lPixel*/,{|| "Prod: "+Work->PRODPAI })   
   TRCell():New(oSecao1,"DESCPAI"       ,""  ,""  ,"" ,Len("Desc: ")+16/*AVSX3("B1_DESC",3)*/        ,/*lPixel*/,{|| "Descr: "+Work->DESCPAI })
   TRCell():New(oSecao1,"UMPAI"         ,""  ,""  ,"" ,Len("U.M.: ")+AVSX3("B1_UM",3)           ,/*lPixel*/,{|| "U.M.: "+Work->UMPAI })
   TRCell():New(oSecao1,"BASEEST"       ,""  ,""  ,"" ,Len("Base Estrut.: ")+AVSX3("B1_QB",3)   ,/*lPixel*/,{|| "Base Estrut.: " +STR(Work->BASEEST)})   
   TRCell():New(oSecao1,"NCMPAI"        ,""  ,""  ,"" ,Len("N.C.M.: ")+AVSX3("B1_POSIPI",3)     ,/*lPixel*/,{|| "N.C.M.: "+Work->NCMPAI })
   TRCell():New(oSecao1,"UMNCM"         ,""  ,""  ,"" ,Len("U.M. da N.C.M.: ")+AVSX3("B1_UM",3)+3 ,/*lPixel*/,{|| "U.M. da N.C.M.: "+Work->UMNCM })
   TRCell():New(oSecao1,"UMVENDA"       ,""  ,""  ,"" ,Len("U.M. de Venda: ")+AVSX3("B1_UM",3)  ,/*lPixel*/,{|| "U.M. de Venda: "+Work->UMVENDA }) 

//   TRCell():New(oSecao1,"PRODPAI"       ,"Work"  ,"Prod"  ,"" ,/*Len("Prod: ")+*/AVSX3("B1_COD", 3)         ,/*lPixel*/,/*{|| "Prod: "+Work->PRODPAI }*/)   
//   TRCell():New(oSecao1,"DESCPAI"       ,"Work"  ,"Desc"  ,"" ,/*Len("Desc: ")+*/18/*AVSX3("B1_DESC",3)*/        ,/*lPixel*/,/*|| "Descr: "+Work->DESCPAI }*/)
//   TRCell():New(oSecao1,"UMPAI"         ,"Work"  ,"U.M."  ,"" ,/*Len("U.M.: ")+*/AVSX3("B1_UM",3)           ,/*lPixel*/,/*|| "U.M.: "+Work->UMPAI }*/)
//   TRCell():New(oSecao1,"BASEEST"       ,"Work"  ,"Base Estrut."  ,"" ,/*Len("Base Estrut.: ")+*/AVSX3("B1_QB",3)   ,/*lPixel*/,/*|| "Base Estrut.: " + STR(Work->BASEEST) }*/)   
//   TRCell():New(oSecao1,"NCMPAI"        ,"Work"  ,"N.C.M."  ,"" ,/*Len("N.C.M.: ")+*/AVSX3("B1_POSIPI",3)     ,/*lPixel*/,/*|| "N.C.M.: "+Work->NCMPAI }*/)
//   TRCell():New(oSecao1,"UMNCM"         ,"Work"  ,"U.M. da N.C.M."  ,"" ,/*Len("U.M. da N.C.M.: ")+*/AVSX3("B1_UM",3)+3 ,/*lPixel*/,/*|| "U.M. da N.C.M.: "+Work->UMNCM }*/)
//   TRCell():New(oSecao1,"UMVENDA"       ,"Work"  ,"U.M. de Venda"  ,"" ,/*Len("U.M. de Venda: ")+*/AVSX3("B1_UM",3)  ,/*lPixel*/,/*|| "U.M. de Venda: "+Work->UMVENDA }*/) 

//   oReport:Section("Seção 1"):SetLineStyle()

   TRCell():New(oSecao2,"Vazio"         ,""  ,""                         ,/*_PictSI*/        ,5                        ,/*lPixel*/,/*{|| code-block de impressao }*/)                                             
   TRCell():New(oSecao2,"NIVEL"         ,"Work"  ,"Nível"                ,/*_PictSI*/        ,3                        ,/*lPixel*/,/*{|| code-block de impressao }*/)                                       
   TRCell():New(oSecao2,"PRODFIL"       ,"Work"  ,"Código"               ,/*_PictSI*/        ,AVSX3("G1_COMP",3)+5       ,/*lPixel*/,/*{|| code-block de impressao }*/)                                       
   If lMaior //BHF - 04/02/09
      TRCell():New(oSecao2,"TRT"           ,"Work"  ,"TRT"                  ,/*_PictSI*/        ,AVSX3("G1_TRT",3)        ,/*lPixel*/,/*{|| code-block de impressao }*/)                                             
   EndIf
   TRCell():New(oSecao2,"DESCFIL"       ,"Work"  ,"Descrição"            ,/*_PictSI*/        ,20/*AVSX3("B1_DESC",3)*/ ,/*lPixel*/,/*{|| code-block de impressao }*/)                                             
   If lMaior //BHF - 04/02/09
      TRCell():New(oSecao2,"QTDGRNCM"      ,"Work"  ,"Qtde.Gross NCM"       ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                             
   EndIf
   TRCell():New(oSecao2,"UMGRNCM"       ,"Work"  ,"U.M."                 ,/*_PictSI*/        ,AVSX3("B1_UM",3)         ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                         
   TRCell():New(oSecao2,"QTDGREST"      ,"Work"  ,"Qtde.Gross Estoq."    ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                   
   TRCell():New(oSecao2,"UMGREST"       ,"Work"  ,"U.M."                 ,/*_PictSI*/        ,AVSX3("B1_UM",3)         ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                         
   TRCell():New(oSecao2,"QTDGRCOM"      ,"Work"  ,"Qtde.Gross Comp."     ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                         
   TRCell():New(oSecao2,"UMCOMER"       ,"Work"  ,"U.M. Comerc."         ,/*_PictSI*/        ,AVSX3("B1_UM",3)         ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                               
   TRCell():New(oSecao2,"PERDA"         ,"Work"  ,"Perda %"              ,cPictPerda         ,AVSX3("G1_PERDA",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                     
   TRCell():New(oSecao2,"QTDNENCM"      ,"Work"  ,"Qtde.Net NCM"         ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                                 
   TRCell():New(oSecao2,"QTDNEEST"      ,"Work"  ,"Qtde.Net Estoq"       ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                     
   TRCell():New(oSecao2,"QTDNECOM"      ,"Work"  ,"Qtde.Net Comp."       ,cPictQuant         ,AVSX3("G1_QUANT",3)      ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                           
   TRCell():New(oSecao2,"TIPOQTD"       ,"Work"  ,"Tipo de Qtde."        ,/*_PictSI*/        ,8                        ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                                 
   TRCell():New(oSecao2,"NCMFIL"        ,"Work"  ,"N.C.M"                ,AVSX3("YD_TEC",6)  ,AVSX3("YD_TEC",3)        ,/*lPixel*/,/*{|| code-block de impressao }*/)                                                                           
//   oReport:Section("Seção 2"):SetLineStyle()
//   oReport:Section("Seção 2"):Cell("PERDA"):SetCellBreak()
   
//   For nInc:=1 to nCont
//      oReport:Section("Seção 2"):Cell(nInc):HideHeader()
//      nTamanho := Len(oReport:Section("Seção 2"):Cell(nInc):cTitle)
//      If nTamanho >= (oReport:Section("Seção 2"):Cell(nInc):nSize)
//         cCabec += oReport:Section("Seção 2"):Cell(nInc):cTitle+"--"
//      Else      
//         cCabec += PADR(oReport:Section("Seção 2"):Cell(nInc):cTitle, oReport:Section("Seção 2"):Cell(nInc):nSize+1,"*") 
//      Endif
//      oReport:Section("Seção 2"):Cell(nInc):cTitle := ""
//   Next
   
   oBreak := TRBreak():New(oReport:Section("Produto"),{||WORK->(PRODPAI)},,.F.)
   
   
   oReport:Section("Componentes"):Cell("NIVEL"):SetColSpace(3)   
   oReport:Section("Componentes"):Cell("PRODFIL"):SetColSpace(3)
   If lMaior  // BHF - 04/02/09   
      oReport:Section("Componentes"):Cell("TRT"):SetColSpace(3)
      oReport:Section("Componentes"):Cell("QTDGRNCM"):SetColSpace(3)           
   EndIf
   oReport:Section("Componentes"):Cell("DESCFIL"):SetColSpace(3)    
   oReport:Section("Componentes"):Cell("UMGRNCM"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("QTDGREST"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("UMGREST"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("QTDGRCOM"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("UMCOMER"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("PERDA"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("QTDNENCM"):SetColSpace(3)
   oReport:Section("Componentes"):Cell("QTDNEEST"):SetColSpace(3)  
   oReport:Section("Componentes"):Cell("QTDNECOM"):SetColSpace(3)  
   oReport:Section("Componentes"):Cell("TIPOQTD"):SetColSpace(3)           
   
   oReport:Section("Componentes"):SetHeaderBreak(.T.)   
            
//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint()
************************************
Local Prod := ""

//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
//TRPosition():New(oReport:Section("Seção 1"),"SW5",3,{|| xFilial("SW5") + Work->WKPO_NUM})

//TRPosition():New(oReport:Section("Seção 1"),"SA5",3,{|| xFilial("SA5") + SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN})

//TRPosition():New(oReport:Section("Seção 1"),"SB1",1,{|| xFilial("SB1") + Work->WKCOD_I})
//TRPosition():New(oReport:Section("Seção 1"),"SWP",2,{|| xFilial("SWP")})

   //oSection:Print()
   oReport:SetMeter(Work->(EasyRecCount()))
   Work->( dbGoTop() )

   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section("Produto"):Init()
//   oReport:Section("Seção 2"):Init() 


   //Laço principal
   
   Do While Work->(!EoF()) .And. !oReport:Cancel()   
      oReport:SkipLine(1)
      oReport:Section("Produto"):PrintLine() //Impressão da linha
      Prod := Work->PRODPAI  
      

      oReport:Section("Componentes"):Init()      
      Do While Work->(!EoF()) .And. !oReport:Cancel() .AND. Work->PRODPAI==Prod    
         oReport:Section("Componentes"):PrintLine() //Impressão da linha   
         oReport:IncMeter()                     //Incrementa a barra de progresso
         Work->( dbSkip() )
      EndDo
      oReport:Section("Componentes"):Finish()
      oReport:FatLine()
   EndDo

   //Fim da impressão da seção 1
   oReport:Section("Produto"):Finish() 

   //Fim da impressão da seção 2
   oReport:Section("Componentes"):Finish()

Return .T.
