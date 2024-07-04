#Include "Mata462T.ch"
#Include "SigaWin.ch"
#include "rwmake.ch"       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ MATA462T ³ AUTOR ³ Leonardo Ruben        ³ DATA ³ 07.12.99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Remito de Transferencia entre depositos (almoxarifados)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ronny Ctvrtnik³02/08/00³xxxxxx³Localizacao Porto Rico e USA.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez ³06/07/15³PCREQ-4256³Se elimina de la funcion xAtuMovFF la ³±±
±±³              ³        ³          ³la modificacion al paramtro MV_SEQFIFO³±±
±±³              ³        ³          ³por motivo de adecuacion a fuentes a  ³±±
±±³              ³        ³          ³nuevas estructuras SX para Version 12.³±±
±±³M.Camargo     ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8	             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata462T()        


SetPrvt("CCADASTRO,LDEPTRANS,CGRDEPORI,CGRDEPDST,LDIGITA,LAGLUTINA")
SetPrvt("LGERALANC,_SALIAS,CPERG,AREGS,I,J")

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT010  ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Remito de Transferencia                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Private cRetTitle := RTrim(RetTitle("CN_REMITO"))
cCadastro := cRetTitle + OemToAnsi(STR0058) // cRetTitle + de Transferencia

//+--------------------------------------------------------------+
//¦ Carrega as perguntas selecionadas                            ¦
//+--------------------------------------------------------------+
If !pergunte("REMT10",.T.)
   Return
EndIf

dbSelectArea("SCN")
dbSetOrder(1)
If mv_par01 == 1  // entrada
   A462Entra()
ElseIf mv_par01 == 2  // saida
   If pergunte("REMT12",.T.)
      lDepTrans := If( mv_par01==1,.T.,.F.)
      cGrDepOri := mv_par02
      cGrDepDst := mv_par03
      lDigita   := If( mv_par04==1,.T.,.F.)
      lAglutina := If( mv_par05==1,.T.,.F.)
      lGeraLanc := If (mv_par06==1,.T.,.F.)
      While A462Salid()
      Enddo
   EndIf
EndIF

dbSelectArea("SCN")
dbSetOrder(1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT011E ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Remito de tranferencia (Entrada)                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462Entra()


SetPrvt("VK_F4,AROTINA,CCADASTRO,CDEPTRANS,CGRDEPDST,LDIGITA")
SetPrvt("LAGLUTINA,LGERALANC,NDEP,CDEPTRAB,CCONDICAO,CINDEX")
SetPrvt("CKEY,NINDEX,_SALIAS,CPERG,AREGS,I")
SetPrvt("J,")


VK_F4 := 115

aRotina := { { OemToAnsi(STR0016) , "A462TPesqui"   , 0 , 1},;  // bUscar
             { OemToAnsi(STR0017) , "A462PrcEnt" , 0 , 0} }  // Entrada

cCadastro := cRetTitle + OemToAnsi(STR0058) + OemToAnsi(STR0059) // cRetTitle + de Transferencia + (Entrada)
cTxtSelec := OemToAnsi(STR0060) + cRetTitle                       // Selecionando + cRetTitle

cDepTrans  := GetNewPar( "MV_DEPTRANS","95")  // Dep.transferencia
//+--------------------------------------------------------------+
//¦ Carrega as perguntas selecionadas                            ¦
//+--------------------------------------------------------------+
If !pergunte("REMT11",.T.)
   Return
EndIf

cGrDepDst := mv_par01
lDigita   := If( mv_par02==1,.T.,.F.)
lAglutina := If( mv_par03==1,.T.,.F.)
lGeraLanc := If( mv_par04==1,.T.,.F.)

// Montagem da cCondicao (depositos do grupo selecionado)
dbSelectArea("SX5")
dbSetOrder(1)
nDep := 1
cDepTrab := ""
cCondicao := ""
If dbSeek( xFilial("SX5")+"74"+cGrDepDst)
   cDepTrab := Alltrim( Extrae( X5DESCRI(), nDep,","))
   While !Empty( cDepTrab)
      cCondicao := cCondicao + 'CN_LOCDEST=="'+cDepTrab+'" .and. '
      nDep := nDep +1
      cDepTrab := Alltrim( Extrae( X5DESCRI(), nDep,","))
   End
EndIf

cCondicao := 'CN_TIPOREM=="6"'  //transferencia

dbSelectArea("SCN")
dbSetOrder(1)

//+--------------------------------------------------------------+
//¦ Cria Indice Condicional para o MbROWSE.                      ¦
//+--------------------------------------------------------------+
cIndex := CriaTrab(nil,.f.)
dbSelectArea("SCN")
cKey   := IndexKey()

IndRegua("SCN",cIndex,cKey,,cCondicao,cTxtSelec)  //"Seleccionando los Remitos..."
nIndex := RetIndex("SCN")
dbSelectArea("SCN")
#IFNDEF TOP
    DbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

mBrowse( 6, 1,22,75,"SCN",,"SCN->CN_QTDEFAT #-1")

dbSelectArea("SCN")
dbSetOrder(1)
Return



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT012  ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Entrada do Remito de Transferencia                         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ REMT011e- llamado por Boton "Entrada " en REMT011E         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦Programador ¦ Data   ¦ BOPS ¦  Motivo da Alteracao                     ¦¦¦
¦¦+------------+--------+------+------------------------------------------¦¦¦
¦¦¦            ¦        ¦      ¦                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462PrcEnt()

Local aArea:= {}
Local cCpos := ""
Local cCampo
Local ni:=0
Local ny:=0
Local nzz:=0
Local nc:=0
SetPrvt("NOPCX,VK_F4,CARQUIVO,LLANCPAD40,LLANCPAD50,LLANCPAD55")
SetPrvt("LLANCPAD60,LLANCPAD65,LLANCPAD95,NHDLPRV,NTOTALLANC,CLOTECOM")
SetPrvt("NLINHA,NMOEDACOR,NTOTAL,CRASTRO,LALTQTRT,AGETSD")
SetPrvt("AHEADER,NUSADO,ACOLS,NCNT,CREMITO,ALOTED3")
SetPrvt("NI,NTOTALITENS,DDEMISSAO,CA100FOR,CLOJA")
SetPrvt("CFORNEC,CTRANSP,CRTOINT,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,ARECNOS")
SetPrvt("NCNTITEM,NZZ,NY,NCOSSTD,CCOND,ACUSTO")
SetPrvt("LLANCTOK,NC,CPRODUTO,CLOCAL,NQUANT,DDATA")
SetPrvt("DDTVALID,CORIGLAN,NEMP,CLOTEFOR,CCHAVE,CLOTECTL")
SetPrvt("CLOTE,NREGISTRO,ACM,LCONTROLE,CLOCDEST,CLOCPROC")
SetPrvt("NRESTOSKIP,CIDENTD7,CCHAVED1,CTIPO,ACPOSD,ACUSTOSB6")
SetPrvt("CCHAVESB6,ACUSTOENT,")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

aArea := GetArea()
If SCN->CN_QTDEFAT#-1
   Help(" ",1,"NOVALID")
   Return
EndIf

nOpcx := 3
VK_F4 := 115

//+--------------------------------------------------------------+
//¦ Variaveis referentes aos Lancamentos Contabéis...            ¦
//+--------------------------------------------------------------+
cArquivo := ""

lLancPad40 := .F.
lLancPad50 := .F.
lLancPad55 := .F.
lLancPad60 := .F.
lLancPad65 := .F.
lLancPad95 := .F.

nHdlPrv    := 1
nTotalLanc := 0
cLoteCom   := ""
nLinha     := 2
nMoedaCor  := 1
nTotal     := 0

cRastro    := GETMV("MV_RASTRO")  // Control de rastreabilidad.
lAltQtRt   := If(GETNEWPAR("MV_ALTQTRT","N")=="N",.f.,.t.)  // Permite alterar Quantidade Remito Transf.

//+--------------------------------------------------------------+
//¦ Montagem do aHeader                                          ¦
//+--------------------------------------------------------------+
aGetSD  := {}
aHeader := {}
nUsado 	:= 0

IF EXISTBLOCK("RMTCPO02")
   cCpos := ExecBlock("RMTCPO02")
Endif


dbSelectArea("SX3")
dbSeek("SCM")
While !EOF() .And. (x3_arquivo == "SCM")
   IF X3USO(x3_usado) .And. cNivel >= x3_nivel
      nUsado:= nUsado + 1
      If AllTrim( X3_CAMPO) $ "CM_ITEM^CM_PRODUTO^CM_UM^CM_QUANT"  // CM_DTVALID
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, x3_valid,;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )
      ElseIf AllTrim( X3_CAMPO) $ "CM_TES^CM_CF"+cCpos
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, x3_valid,;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )
         Aadd( aGetSD, X3_CAMPO)
      ElseIf AllTrim( X3_CAMPO) == "CM_LOCAL"   // "CM_NUMLOTE^CM_LOTECTL^CM_LOCAL"
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, "A462TVldE()",;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )
         Aadd( aGetSD, X3_CAMPO)
      Endif
      If AllTrim( X3_CAMPO)=="CM_QUANT" .and. lAltQtRt
         Aadd( aGetSD, X3_CAMPO)
      Endif
   Endif
   dbSkip()
EndDo

aCOLS := Array(1,Len(aHeader)+1)

//+--------------------------------------------------------------+
//¦ Montando aCols - dados do cRemito posicionado                ¦
//+--------------------------------------------------------------+
nCnt := 0
dbSelectArea("SCN")
dbSetOrder(1)
cRemito := CN_REMITO

dbSeek(xFilial("SCN")+cRemito)
While !EOF() .And. CN_FILIAL+CN_REMITO == xFilial("SCN")+cRemito
   nCnt:=nCnt+1
   dbSkip()
End

If nCnt == 0
   Help(" ",1,"NOITENS")
   Return
EndIf

aCOLS := {}

//+--------------------------------------------------------------+
//¦ Armazeno informacoes do Rastro quando gerada saida no SD3    ¦
//¦ aLoteD3[ITEM][1] -> NumLote                                  ¦
//¦              [2] -> LoteCtl                                  ¦
//¦              [3] -> DtValid                                  ¦
//+--------------------------------------------------------------+
aLoteD3 := {}

//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+
nCnt := 0
dbSelectArea("SCN")
dbSetOrder(1)
dbSeek(xFilial("SCN")+cRemito)
While !EOF() .And. CN_FILIAL+CN_REMITO == xFilial("SCN")+cRemito
   nCnt:=nCnt+1
   AADD(aCOLS,Array(Len(aHeader)+1))
   For nI := 1 to Len(aHeader)
      cCampo := Alltrim(aHeader[nI,2])
      cCampo := If( AllTrim( cCampo)=="CM_LOCAL","CM_LOCDEST",cCampo)
      cCampo := "CN_"+Subs( cCampo,4)
      If aHeader[nI,10] #"V" .and. !AllTrim( cCampo)$"CN_NUMLOTE^CN_LOTECTL^CN_DTVALID"
         aCOLS[Len(aCOLS)][nI] := FieldGet(FieldPos(cCampo))
      Else
         aCOLS[Len(aCOLS)][nI] := CriaVar(cCampo)
      Endif
      If AllTrim( cCampo)=="CN_TES"
         SB1->( dbSetOrder(1) )
         SB1->( dbSeek(xFilial("SB1")+SCN->CN_PRODUTO) )
         aCOLS[Len(aCOLS)][nI] := RetFldProd(SB1->B1_COD,"B1_TE")
      ElseIf AllTrim( cCampo)=="CN_CF"
         SF4->( dbSetOrder(1) )
         SF4->( dbSeek(xFilial("SF4")+RetFldProd(SB1->B1_COD,"B1_TE")) )
         aCOLS[Len(aCOLS)][nI] := SF4->F4_CF
      EndIf
   Next 
   aCOLS[Len(aCOLS)][Len(aHeader)+1] := .F.

   //+--------------------------------------------------------------+
   //¦ Reservo informacoes de Lote da saida no SD3                  ¦
   //+--------------------------------------------------------------+
   Aadd( aLoteD3, { CriaVar("D3_NUMLOTE"), CriaVar("D3_LOTECTL"), CriaVar("D3_DTVALID")})
   dbSelectArea("SD3")
   dbSetOrder(2)
   dbSeek(xFilial("SD3")+cRemito+SCN->CN_PRODUTO)
   While !Eof() .And. D3_FILIAL+D3_DOC+D3_COD == xFilial("SD3")+cRemito+SCN->CN_PRODUTO
      If D3_ITEM==SCN->CN_ITEM .and. D3_TM=="499" .and. D3_CF=="RE4"
         aLoteD3[Len(aLoteD3)][1] := D3_NUMLOTE
         aLoteD3[Len(aLoteD3)][2] := D3_LOTECTL
         aLoteD3[Len(aLoteD3)][3] := D3_DTVALID
      EndIf
      dbSkip()
   End

   dbSelectArea("SCN")
   dbSkip()
End
dbSeek(xFilial("SCN")+cRemito)

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens:=nCnt

//+--------------------------------------------------------------+
//¦ Se nao existir, cria fornecedor generico "TRANSFERENCIA"     ¦
//+--------------------------------------------------------------+
dbSelectArea("SA2")
dbSetOrder(1)
If !dbSeek(xFilial("SA2")+"TRANSF")
   RecLock("SA2",.T.)
   Replace A2_FILIAL  With xFilial("SA2"),;
           A2_COD     With "TRANSF",;
           A2_LOJA    With "00",;
           A2_NOME    With OemToAnsi(STR0027),; //"TRANSFERENCIA"
           A2_NREDUZ  With OemToAnsi(STR0027),; //"TRANSFERENCIA"
           A2_BAIRRO  With ".",;
           A2_MUN     With ".",;
           A2_EST     With ".",;
           A2_END     With "."
   dbUnlock()
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
dDEmissao := dDataBase      // Fecha de Emision Original del Comprobante
ca100For  := SA2->A2_COD    // Proveedor
cLoja     := SA2->A2_LOJA   // Cod.Sucursal de Proveedor
cFornec   := SA2->A2_NOME   // Proveedor
cTransp   := Space(06)      // Codigo del Transportista

cRtoInt := GetSX8Num("SCM","CM_ORT")  // Almacena en SX8 Numeracion Automat.
//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens:=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := cRetTitle + OemToAnsi(STR0058) + OemToAnsi(STR0059) // cRetTile + de Transferencia + (Entrada)

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"ca100For"  ,{15,001} ,OemToAnsi(STR0028),"@!",".T.",,.F.}) //"Proveedor"
AADD(aC,{"cLoja"     ,{15,082} ,OemToAnsi(STR0029),"@!",".T.",,.F.}) //"Suc."
AADD(aC,{"cFornec"   ,{15,122} ," "               ,"@!",".T.",,.F.})
AADD(aC,{"cRtoInt"   ,{30,010} ,OemToAnsi(STR0030),"@R 99999999",".T.",,.F.})  //"Nro Int."
AADD(aC,{"cTransp"   ,{30,090} ,OemToAnsi(STR0031),"@!","a102Transp()","SA4",}) //"Transp"
AADD(aC,{"dDEmissao" ,{30,170} ,OemToAnsi(STR0032),"@D",".T.",,.T.}) //"Fch.Emisión"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,010},OemToAnsi(STR0033),"@E 999",,,.F.}) //"Total de Items"

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk := 'A462TLOk()'
cTudoOk  := 'A462TTOk()'

aGetEdit := {}

//+------------------------------------------------------------------+
//¦ Ativa tecla F4 para comunicacao com Saldos por Lote.             ¦
//+------------------------------------------------------------------+
//Set Key VK_F4 To a462F4() se cancela por rutina A462F4 no compilada en el RPO

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,aGetSD,,"+CM_ITEM",,,.F.,GetmBrowse())

Set Key VK_F4 To

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

   //+--------------------------------------------------------------+
   //¦ posiciona no cliente escolhido                               ¦
   //+--------------------------------------------------------------+
   dbSelectArea("SA2")
   dbSeek(xFilial("SA2")+Subs(ca100for,1,6))

   //+--------------------------------------------------------------+
   //¦ Atualiza o Corpo do Remito                                   ¦
   //+--------------------------------------------------------------+

   If lGeraLanc
      //+--------------------------------------------------------------+
      //¦ Nao Gerar os lancamento Contabeis On-Line                    ¦
      //+--------------------------------------------------------------+
      lLancPad50 := VerPadrao("750")
      lLancPad60 := VerPadrao("760")
   EndIf

   If (lLancPad50 .or. lLancPad60) .and. !__TTSInUse

      //+--------------------------------------------------------------+
      //¦ Posiciona numero do Lote para Lancamentos do Compras         ¦
      //+--------------------------------------------------------------+
      dbSelectArea("SX5")
      dbSeek(xFilial()+"09COM")
      cLoteCom:=IIF(Found(),Trim(X5DESCRI()),"COM ")
      nHdlPrv:=HeadProva(cLoteCom,"REMT012",cUserName,@cArquivo)
      If nHdlPrv <= 0
         Help(" ",1,"A100NOPROV")
      EndIf
   EndIf

   aRecnos := {}
   nCntItem:= 1

   For nZZ := 1 to Len(aCols)
      IF .not. aCols[nZZ][Len(aCols[1])]

          //+--------------------------------------------------------------+
          //¦ Atualiza dados do Remito.                                    ¦
          //+--------------------------------------------------------------+
          dbSelectArea("SCM")
          RecLock("SCM",.T.)
          // Actualizacion de Fuentes 27/04/99
          Replace CM_FILIAL  With xFilial("SCM"),;
                  CM_REMITO  With cRemito,;
                  CM_FORNECE With ca100for,;
                  CM_EMISSAO With dDEmissao,;
                  CM_LOJA    With cLoja,;
                  CM_ORT     With cRtoInt,;     // J.L.Otermin 08/02/99
                  CM_TRANS   With cTransp       // J.L.Otermin 11/02/99

          ConfirmSX8()          // Actualiza Ultimo RtoInterno en SX8

          //+--------------------------------------------------------------+
          //¦ Atualiza dados do corpo do Remito.                           ¦
          //+--------------------------------------------------------------+
          For ny := 1 to Len(aHeader)
              If aHeader[ny][10] #"V"
                 cCampo := AllTrim(aHeader[ny][2])
                 FieldPut(FieldPos(cCampo),aCols[nZZ][ny])
              Endif
          Next ny

          SB1->( dbSetOrder(1) )
          SB1->( dbSeek(xFilial("SB1")+SCM->CM_PRODUTO) )

          // Agrego variable nCosSTD Costo STD del Producto para mover a aCusto  Luis
          nCosSTD := RetFldProd(SB1->B1_COD,"B1_CUSTD")

          //+----------------------------------------------------------+
          //¦ Grava sempre o numero do item sequencial                 ¦
          //+----------------------------------------------------------+
          Replace CM_ITEM    With StrZero(nCntItem,2)
          // j.l.otermin 10/03/99 ----------------
          Replace CM_ORT     With cRtoInt   // Numero Interno de Remito.
          //--------------------------------------
          If Empty(CM_DTVALID) .and. cRastro $ "LS"   // 12-05-99 jose luis
             Replace CM_DTVALID With SCM->CM_EMISSAO + SB1->B1_PRVALID
          EndIf

          AADD(aRecnos,Recno())

          dbSelectArea("SCM")
          Replace CM_TOTAL   With ( SCM->CM_QUANT * RetFldProd(SB1->B1_COD,"B1_UPRC") )
          cCond := SPACE(3) // "   "

          If SF4->F4_PODER3 != "N"
             If Empty(CM_IDENTB6)
                Replace CM_IDENTB6 With CM_NUMSEQ
             EndIf
          EndIf

          nTotal := nTotal + SCM->CM_TOTAL

          If ExistBlock("MREM002")
             ExecBlock("MREM002",.F.,.F.)
          EndIf

          //+----------------------------------------------------------+
          //¦ Verifica se havera movimentaçäo de Estoques...           ¦
          //+----------------------------------------------------------+
          SF4->( dbSetOrder(1) )
          SF4->( dbSeek(xFilial("SF4")+SCM->CM_TES) )
          If SF4->F4_ESTOQUE == "S"
             //+---------------------------------------------------------+
             //¦ Gerar Devolucao automatica para acertar os saldos em    ¦
             //¦ estoque e tratar o custo.                               ¦
             //+---------------------------------------------------------+
             DevAuto()

             dbSelectArea("SCM")
             Replace CM_NUMSEQ  With ProxNum()

             //+---------------------------------------------------------+
             //¦ Transferir material para o CQ.                          ¦
             //+---------------------------------------------------------+
             EnviaCQ()
             //+---------------------------------------------------------+
             //¦ Atualizar e Controlar Saldo em/de Poder de Terceiros... ¦
             //+---------------------------------------------------------+
             If SF4->F4_PODER3 != "N"
                Poder3A()
             EndIf

             dbSelectArea("SCM")
             //+--------------------------------------------+
             //¦ Grava o custo da movimentacao              ¦
             //+--------------------------------------------+
             aCusto := {}  // GravaCusCM(aCM)    // o aCM é montado no DevAuto()   Se comenta  por Rutinas Descontinuadas
             //+-------------------------------------------------------+
             //¦ Atualiza o saldo atual (VATU) com os dados do SCM     ¦
             //+-------------------------------------------------------+
             // B2AtuComCM()   Se comenta  por Rutinas Descontinuadas

          EndIf

          //+--------------------------------------------------+
          //¦ Gera lancamento Contab. a nivel de Itens         ¦
          //+--------------------------------------------------+
          If lLancPad50
             nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"750","REMT012",cLoteCom,@nLinha)
          Endif

          //+---------------------------------------------------------+
          //¦ Gera lancamento Contab. a Devolucao...                  ¦
          //+---------------------------------------------------------+
          //If lLancPad65
          //   nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"765","REMT012",cLoteCom,@nLinha)
          //EndIf

          nCntItem:=nCntItem + 1
       EndIF
       dbSelectArea("SCM")
       DbUnlock()

       dbSelectArea("SCN")
       dbSetOrder(1)
       dbSeek(xFilial("SCN")+cRemito)
       While !EOF() .And. CN_FILIAL+CN_REMITO == xFilial("SCN")+cRemito
          RecLock("SCN",.F.)
          Replace CN_QTDEFAT With 0    // indica que foi dada entrada no rem.transf.
          dbUnlock()
          dbSkip()
       End

       dbSelectArea("SCM")
   Next nZZ

   If nHdlPrv > 0 .and. (lLancPad40.or.lLancPad50.or.lLancPad60) .and. !__TTSInUse

      //+--------------------------------------------------+
      //¦ Gera Lancamento Contab. para Totais da N.Fiscal  ¦
      //+--------------------------------------------------+
      If lLancPad60
         nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"760","REMT012",cLoteCom,@nLinha)
      Endif

      //+-----------------------------------------------------+
      //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
      //+-----------------------------------------------------+
      RodaProva(nHdlPrv,nTotalLanc)

      //+-----------------------------------------------------+
      //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
      //+-----------------------------------------------------+
      lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina)

      If lLanctOk
         For nC := 1 To Len(aRecnos)
             dbSelectArea("SCM")
             dbGoTo( aRecnos[nC] )
             RecLock("SCM",.F.)
             Replace CM_DTLANC With dDataBase
             MsUnLock()
         Next nC
      EndIf
   EndIf
Endif
RestArea( aArea )
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ DevAuto()¦ Autor ¦ José Lucas            ¦ Data ¦ 20/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Devolucao Automatica.                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 07/12/99 ==> Function DevAuto
Static Function DevAuto()

//+---------------------------------------------------------+
//¦ Gerar Devolucao automatica para acertar os saldos em    ¦
//¦ estoque e tratar o custo.                               ¦
//+---------------------------------------------------------+
dbSelectArea("SB2")
dbSeek(xFilial()+SCM->CM_PRODUTO+cDepTrans)
If EOF()
   CriaSB2(SCM->CM_PRODUTO,cDepTrans)
EndIf

//+------------------------------------------+
//¦ Gera Devolucao automatica                ¦
//+------------------------------------------+
dbSelectArea("SD3")
RecLock("SD3",.T.)
Replace D3_FILIAL       With xFilial("SD3")
Replace D3_DOC          With SCM->CM_REMITO
Replace D3_ITEM         With SCM->CM_ITEM
Replace D3_COD          With SCM->CM_PRODUTO
Replace D3_UM           With SCM->CM_UM
Replace D3_QUANT        With SCM->CM_QUANT
Replace D3_SEGUM        With SCM->CM_SEGUM
Replace D3_QTSEGUM      With SCM->CM_QTSEGUM
Replace D3_EMISSAO      With dDatabase
Replace D3_GRUPO        With SB1->B1_GRUPO
Replace D3_TIPO         With SB1->B1_TIPO
Replace D3_CF           With "DE4"
Replace D3_LOCAL        With cDepTrans
Replace D3_TM           With "999"
Replace D3_USUARIO      With CUSERNAME
Replace D3_NUMSEQ       With ProxNum()
Replace D3_CHAVE        With SubStr(D3_CF,2,1)+"0"
If lGeraLanc
   Replace D3_DTLANC    With dDataBase
EndIf
Replace D3_NUMLOTE      With aLoteD3[Val(SCM->CM_ITEM)][1]
Replace D3_LOTECTL      With aLoteD3[Val(SCM->CM_ITEM)][2]
Replace D3_DTVALID      With aLoteD3[Val(SCM->CM_ITEM)][3]

//+------------------------------------------------------+
//¦ Criar um Lote para o Produto.                        ¦
//+------------------------------------------------------+
SB1->( dbSetOrder(1) )
SB1->( dbSeek(xFilial("SB1")+SCM->CM_PRODUTO) )

cProduto := SCM->CM_PRODUTO
cLocal   := SCM->CM_LOCAL
nQuant   := SCM->CM_QUANT
dData    := SCM->CM_EMISSAO
dDtValid := SCM->CM_DTVALID

// Origem do Lancto
// "RE" - Remito de Entrada
// "RS" - Remito de Sa¡da
// "CP" - Compras
// "VT" - Vendas

//+--------------------------------------------+
//¦ Pega os custos medios atuais               ¦
//+--------------------------------------------+
aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
//+--------------------------------------------+
//¦ Grava o custo da movimentacao              ¦
//+--------------------------------------------+
aCusto := GravaCusD3(aCM)
//+-------------------------------------------------------+
//¦ Atualiza o saldo atual (VATU) com os dados do SD3     ¦
//+-------------------------------------------------------+
B2AtuComD3(aCusto)
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ EnviaCQ  ¦ Autor ¦ José Lucas            ¦ Data ¦ 20/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tranferir material para o CQ fazendo o controle de Lotes.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function EnviaCQ()

lControle := .F.

cLocDest  := GetMV("MV_CQ")
cLocProc  := GetMv("MV_LOCPROC")

//+--------------------------------------------------------------+
//¦ Verificar tratamento de SKIP-LOTE para possivel tranferência ¦
//¦ para um almoxarifado indisponivel CQ.                        ¦
//+--------------------------------------------------------------+
dbSelectArea("SA5")
dbSetOrder(1)
dbSeek( xFilial("SA5")+SubStr(cA100For,1,6)+cLoja+SCM->CM_PRODUTO )
If Found() .and. (SA5->A5_SKIPLOTE > 0 .or. SB1->B1_NOTAMIN > SA5->A5_NOTA)
   nRestoSkip := Mod(A5_ENTREGA,A5_SKIPLOTE)
   If SA5->A5_SKIPLOTE > 0
      RecLock("SA5",.F.)
      Replace A5_ENTREGA With A5_ENTREGA + 1
   EndIf
   If A5_NOTA >= SB1->B1_NOTAMIN
      If nRestoSkip == 0
         lControle := .T.
      Endif
   Else
      //+-----------------------------------------------------------------+
      //¦ Se este fornecedor nao tem pontuacao suficiente, mandar para CQ ¦
      //+-----------------------------------------------------------------+
      lControle := .T.
   Endif
EndIf

//+--------------------------------------------------------------+
//¦ Verificar tratamento de SKIP-LOTE para possivel tranferência ¦
//¦ para um almoxarifado indisponivel CQ.                        ¦
//+--------------------------------------------------------------+
If lControle
   dbSelectArea("SA5")
   dbSetOrder(1)
   dbSeek( xFilial()+SubStr(cA100For,1,6)+cLoja+SCM->CM_PRODUTO )
   If Found() .and. (SA5->A5_SKIPLOTE > 0 .or. SB1->B1_NOTAMIN > SA5->A5_NOTA)
      If A5_NOTA >= SB1->B1_NOTAMIN
         If nRestoSkip == 0
            cIdentD7:=SCM->CM_PRODUTO+SCM->CM_REMITO+SCM->CM_ITEM+SCM->CM_FORNECE+SCM->CM_LOJA
            cChaveD1:=SCM->CM_PRODUTO+SCM->CM_REMITO+SCM->CM_ITEM+SCM->CM_FORNECE+SCM->CM_LOJA

            TransAut( SCM->CM_PRODUTO, SCM->CM_UM, SCM->CM_LOCAL, ;
                      SCM->CM_PRODUTO, SCM->CM_UM, cLocDest, SCM->CM_QUANT,;
                      SCM->CM_NUMLOTE, SCM->CM_LOTECTL, cIdentD7 )

            Pergunte("MTA100",.F.)
            RecLock("SA5",.F.)
            dbSelectArea("SCM")
            RecLock("SCM",.F.)
            Replace CM_LOCAL   With cLocDest
            Replace CM_NUMCQ   With SD7->D7_NUMERO
         EndIf
      Else
         //+-----------------------------------------------------------------+
         //¦ Se este fornecedor nao tem pontuacao suficiente, mandar para CQ ¦
         //+-----------------------------------------------------------------+
         cIdentD7:=SCM->CM_PRODUTO+SCM->CM_REMITO+SCM->CM_ITEM+SCM->CM_FORNECE+SCM->CM_LOJA
         cChaveD1:=SCM->CM_PRODUTO+SCM->CM_REMITO+SCM->CM_ITEM+SCM->CM_FORNECE+SCM->CM_LOJA

         TransAut( SCM->CM_PRODUTO, SCM->CM_UM, SCM->CM_LOCAL, ;
                   SCM->CM_PRODUTO, SCM->CM_UM, cLocDest, SCM->CM_QUANT,;
                   SCM->CM_NUMLOTE, SCM->CM_LOTECTL, cIdentD7 )

         Pergunte("MTA100",.F.)
         RecLock("SA5",.F.)
         dbSelectArea("SCM")
         RecLock("SCM",.F.)
         Replace CM_LOCAL   With cLocDest
         Replace CM_NUMCQ   With SD7->D7_NUMERO
      Endif
   EndIf
EndIf
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Poder3A  ¦ Autor ¦ José Lucas            ¦ Data ¦ 20/07/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualizar e Efetuar o Controle de Terceiros.               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 07/12/99 ==> Function Poder3A
Static Function Poder3A()

cProduto  := SCM->CM_PRODUTO
cLocal    := SCM->CM_LOCAL
cTipo     := "N"

//+----------------------------------------------------------+
//¦ Obter o valor unitario do Item do Remito...              ¦
//+----------------------------------------------------------+
dbSelectArea("SC7")
dbSetOrder(1)
dbSeek(xFilial("SC7")+SCM->CM_PEDIDO+SCM->CM_ITEMPED)
If ! Found()
   Help(" ",1,"SEMPEDIDO")
   Return
EndIf

//+----------------------------------------------------------+
//¦ Atualiza o saldo controle de Poder Em/DE Terceiros...    ¦
//+----------------------------------------------------------+
dbSelectArea("SB2")
dbSeek(xFilial()+cProduto+cLocal)
If SF4->F4_ESTOQUE == "S"
   RecLock("SB2",.F.)
   //+-------------------------------------------------------+
   //¦ Recebimento de Terceiros                              ¦
   //+-------------------------------------------------------+
   If SF4->F4_PODER3 == "R"
      Replace B2_QTNP  With B2_QTNP+SCM->CM_QUANT
   ElseIf SF4->F4_PODER3 == "D"
      Replace B2_QNPT  With B2_QNPT-SCM->CM_QUANT
   Endif
   MsUnLock()
Else
   If SF4->F4_PODER3 $ "DR"
      dbSelectArea("SB2")
      If dbSeek(xFilial()+cProduto+cLocal)
         RecLock("SB2",.F.)
      Else
         CriaSB2(cProduto,cLocal)
      Endif
      If SF4->F4_PODER3 == "D"
         Replace B2_QTER  With B2_QTER-SCM->CM_QUANT
      Else
         Replace B2_QTER  With B2_QTER+SCM->CM_QUANT
      Endif
      MsUnLock()
   Endif
Endif

If nTotal > 0
   //+----------------------------------------------------------+
   //¦ Gravar o Array de Saldo Em/De Poder de Terceiros         ¦
   //+----------------------------------------------------------+
   aCpoSD[01]:= SCM->CM_FORNECE
   aCpoSD[02]:= SCM->CM_LOJA
   aCpoSD[03]:= SCM->CM_PRODUTO
   aCpoSD[04]:= SCM->CM_LOCAL
   aCpoSD[05]:= SC7->C7_PRECO
   aCpoSD[06]:= "D"
   aCpoSD[07]:= SCM->CM_REMITO
   aCpoSD[08]:= "REM"
   aCpoSD[09]:= SCM->CM_EMISSAO
   aCpoSD[10]:= SCM->CM_EMISSAO
   aCpoSD[11]:= SF4->F4_CF
   aCpoSD[12]:= SCM->CM_QUANT
   aCpoSD[13]:= SCM->CM_UM
   aCpoSD[14]:= SCM->CM_QTSEGUM
   aCpoSD[15]:= SCM->CM_SEGUM
   aCpoSD[16]:= nTotal
   aCpoSD[17]:= SCM->CM_IDENTB6

   //+-----------------------------------------------------------+
   //¦ Gravar as movimentaçöes no Arquivo De/Poder Terceiros.    ¦
   //+-----------------------------------------------------------+
   aCpoSD[16] := nTotal
   aCustoSB6[1] := aCustoEnt[1][1]
   aCustoSB6[2] := aCustoEnt[1][2]
   aCustoSB6[3] := aCustoEnt[1][3]
   aCustoSB6[4] := aCustoEnt[1][4]
   aCustoSB6[5] := aCustoEnt[1][5]

   cChaveSB6 := SCM->CM_IDENTB6+cProduto
   aCustoEnt := AtuaSB6(SF4->F4_CODIGO,cChaveSB6,aCpoSD,aCustoSB6,cTipo)
   dbSelectArea("SCM")
   RecLock("SCM",.F.)
   Replace CM_IDENTB6 With CM_NUMSEQ
   MsUnLock()
EndIf
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT013E ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 30/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao do aCols da modelo2                              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Remito de Transferencia (Entrada) - REMT011E.PRW           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462TVldE()

Local cCampo
SetPrvt("NPOSLOCAL,NPOSLOTE,NPOSLOTCTL,NPOSDVALID,_CCOD,_CTES")
SetPrvt("_CLOCAL,_CLOTE,_CLOTECTL,_CLOTEDIGI,ACOLS")
SetPrvt("LREFRESH,")

_lRet  := .t.
cCampo := ReadVar()
cContd := &(cCampo)
_cArea := Alias()
If AllTrim( cCampo) $ "M->CM_LOTECTL^M->CM_NUMLOTE"

   nPosCod    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_PRODUTO"})
   nPosTES    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_TES"})
   nPosLocal  := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_LOCAL"})
   nPosLote   := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_NUMLOTE"})
   nPosLotCtl := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_LOTECTL"})
   nPosDValid := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_DTVALID"})

   If nPosCod > 0 .and. nPosTES > 0 .and. nPosLocal > 0 .and.;
      nPosLote > 0 .and. nPosLotCtl > 0 .and. nPosDValid > 0
      _cCod      := aCols[n,nPosCod]
      _cTES      := aCols[n,nPosTES]
      _cLocal    := aCols[n,nPosLocal]
      _cLote     := aCols[n,nPosLote]
      _cLoteCtl  := aCols[n,nPosLotCtl]
      _cLoteDigi := aCols[n,nPosDValid]
   Else
      _lRet := .F.
   EndIf
   If _lRet
      If !Rastro(_cCod)
         aCols[n,nPosLote]   := CriaVar("CM_NUMLOTE")
         aCols[n,nPosLotCtl] := CriaVar("CM_LOTECTL")
         aCols[n,nPosDValid] := CriaVar("CM_DTVALID")
         Help(" ",1,"NAORASTRO")
         Return .F.
      EndIf
      If cCampo == "M->CM_LOTECTL"
         If !Empty(_cLote)
            dbSelectArea("SB8")
            dbSetOrder(2)
            If dbSeek(xFilial()+_cLote+_cCod) .And. cContd != SB8->B8_LOTECTL
               Help(" ",1,"RET_LOTCTL")
               _lRet:=.F.
            EndIf
         Else
            dbSelectArea("SB8")
            dbSetOrder(3)
            If dbSeek(xFilial()+cContd)
               Help(" ",1,"RET_CTLEX")
               _lRet:=.F.
            EndIf
         EndIf
      ElseIf cCampo == "M->CM_NUMLOTE"
         If !Empty(cContd)
            dbSelectArea("SB8")
            dbSetOrder(2)
            If dbSeek(xFilial()+cContd+_cCod)
               M->CM_LOTECTL:=SB8->B8_LOTECTL
               aCols[n,nPosLote] := cContd
               aCols[n,nPosLotCtl] := SB8->B8_LOTECTL
            Else
               M->CM_NUMLOTE := CriaVar("CM_NUMLOTE")
               M->CM_LOTECTL := CriaVar("CM_LOTECTL")
               M->CM_DTVALID := CriaVar("CM_DTVALID")
               aCols[n,nPosLote] := CriaVar("CM_NUMLOTE")
               aCols[n,nPosLotCtl] := CriaVar("CM_LOTECTL")
               aCols[n,nPosdValid] := CriaVar("CM_DTVALID")
            EndIf
            lRefresh:=.T.
         EndIf
      EndIf
   EndIf
ElseIf AllTrim( cCampo) == "M->CM_DTVALID"
   nPosLotCtl := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_LOTECTL"})
   If nPosLotCtl > 0
      If Empty(aCols[n,nPosLotCtl])
         Help(" ",1,"NDIGITLOTE")
         _lRet:=.F.
      EndIf
      If _lRet .And. M->CM_DTVALID < dDataBase
         Help(" ",1,"DTVALIDINV")
        _lRet:=.F.
      EndIf
   EndIf
ElseIf AllTrim( cCampo) $ "M->CM_LOCAL"
   dbSelectArea("SX5")
   dbSetOrder(1)
   If (AllTrim( cCampo) == "M->CM_LOCAL" .And. dbSeek(xFilial("SX5")+"74"+cGrDepDst))
      If !(cContd $ X5DESCRI())
         Help( " ",1,"NOLOCVALID") // deposito nao pertence ao grupo (escolhidos nos parametros)
         _lRet := .f.
      EndIF
   Else
      Help(" ",1,"NOGRPDEP")  // nao encontrou grupo cadastrado
      _lRet := .f.
   EndIf
EndIf
dbSelectArea( _cArea)
Return(_lRet)        



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT011S ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao Manual do Remito de Transferencia                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462Salid()

Local cCpos := ""
Local cCampo
Local i:=0
Local ny:=0
Local nx:=0
Local nc:=0
SetPrvt("NOPCX,VK_F4,CARQUIVO,AROTINA,LLANCPAD10,LLANCPAD20")
SetPrvt("LLANCPAD30,LLANCPAD35,NHDLPRV,NTOTALLANC,CLOTECOM,NLINHA")
SetPrvt("NMOEDACOR,CROTINT,CRASTRO,CDEPTRANS,LCUSFFRM,AHEADER")
SetPrvt("NUSADO,AGETSD,ACOLS,I,DDEMISSAO")
SetPrvt("CCLIENTE,CLOJA,CNOMECLI,CTIPOREM,NTOTALITENS,CTITULO")
SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
SetPrvt("LRETMOD2,NMAXARRAY,NY,ARECNOS,NCNTITEM,NX")
SetPrvt("AIMPCUSTO,ATAMREM,AENVCUS,ACM,ACUSTO,CRTOINT")
SetPrvt("LLANCTOK,NC,CNUMSEQ,NITEMVALTOT,CPRODUTO,CLOCAL")
SetPrvt("NQUANT,CTIPO,ACPOSD,ACUSTOSB6,ACUSTOENT,ADUPL")
SetPrvt("CCHAVESB6,CREMITO,CCADASTRO,MYINDEX,NRECNO,_ALIAS")
SetPrvt("NOPCA,CHELP,CVALUE,NPROP,NQTDBAI,NQTDFIM")
SetPrvt("CALIAS,CCF,CTIPONF,CSERIE,CITEM,CDOC")
SetPrvt("COP,CTM,DDATA,ACUSSBD,ASBDFIM,NOLDREC")
SetPrvt("NDEC,CFILIAL,NCUSTO1,NCUSTO2,NCUSTO3,NCUSTO4")
SetPrvt("NCUSTO5,NSEQ,NSEQFIFO,")

nOpcx := 3
VK_F4 := 115

//+--------------------------------------------------------------+
//¦ Variaveis referentes aos Lancamentos Contabéis...            ¦
//+--------------------------------------------------------------+
cArquivo := ""
aRotina := {} // é necessario por causa do ca100incl

lLancPad10 := .F.
lLancPad20 := .F.
lLancPad30 := .F.
lLancPad35 := .F.

nHdlPrv    := 1
nTotalLanc := 0
cLoteCom   := ""
nLinha     := 2
nMoedaCor  := 1
cRotInt    := ""

cRastro    := GETMV("MV_RASTRO")  // Control de rastreabilidad.
cDepTrans  := GetNewPar( "MV_DEPTRANS","95")  // Dep.transferencia
lCusFFRm   := GetMV("MV_CUSFIFO",.F.)

//+--------------------------------------------------------------+
//¦ Salva a integridade dos campos de Bancos de Dados            ¦
//+--------------------------------------------------------------+
dbSelectArea("SCN")
dbSetOrder(1)

IF EXISTBLOCK("RMTCPO01")
   cCpos := ExecBlock("RMTCPO01")
Endif

//+--------------------------------------------------------------+
//¦ Montagem do aHeader                                          ¦
//+--------------------------------------------------------------+
aHeader:= {}
nUsado := 0
aGetSD := {}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SCN")
While !EOF() .And. (x3_arquivo == "SCN")
   IF X3USO(x3_usado) .And. cNivel >= x3_nivel
      nUsado:= nUsado + 1
      If AllTrim( X3_CAMPO) $ "CN_ITEM"
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, x3_valid,;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )

      ElseIf AllTrim( X3_CAMPO) $ "CN_UM^CN_TES^CN_CF^CN_SEGUM^CN_QTSEGUM"+cCpos
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, x3_valid,;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )
         Aadd( aGetSD, X3_CAMPO)
      ElseIf AllTrim( X3_CAMPO) $ "CN_PRODUTO^CN_NUMLOTE^CN_LOTECTL^CN_DTVALID^CN_LOCAL^CN_LOCDEST^CN_QUANT"
         AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, 'A462TVldS()',;
                        x3_usado, x3_tipo, x3_arquivo,x3_context } )
         Aadd( aGetSD, X3_CAMPO)
         If AllTrim( X3_CAMPO) =="CN_LOCAL"
            aHeader[Len(aHeader)][1] := OemToAnsi(STR0051) // "Dep.Origen"
         ElseIf AllTrim( X3_CAMPO) =="CN_LOCDEST"
            aHeader[Len(aHeader)][1] := OemToAnsi(STR0052) // "Dep.Destino"
         EndIf
      Endif
   EndIF
   dbSkip()
End

//CRIAR COLUNAS PARA DIGITAÇAO DO TES DE ENTRADA
if !lDepTrans
   DbSelectArea("SX3")
   DbSetOrder(2)
   DbSeek("CM_TES")
   AADD(aHeader,{X3Titulo(), x3_campo, x3_picture,;
                 x3_tamanho, x3_decimal, x3_valid,;
                 x3_usado, x3_tipo, x3_arquivo,x3_context } )
   Aadd( aGetSD, X3_CAMPO)

   DbSeek("CM_CF")
   AADD(aHeader,{X3Titulo(), x3_campo, x3_picture,;
                 x3_tamanho, x3_decimal, x3_valid,;
                 x3_usado, x3_tipo, x3_arquivo,x3_context } )
   Aadd( aGetSD, X3_CAMPO)
EndIf
aCOLS := Array(1,Len(aHeader)+1)

//+--------------------------------------------------------------+
//¦ Montagem do aCols                                            ¦
//+--------------------------------------------------------------+
For i:=1 to Len(aHeader)
    cCampo:=Alltrim(aHeader[i,2])
    If aHeader[i,10] #"V"
       IF aHeader[i,8] == "C"
          If alltrim(aHeader[i,2])=="CN_ITEM"
             aCOLS[1][i] := "01"
          Else
             aCOLS[1][i] := SPACE(aHeader[i,4])
          Endif
       ElseIf aHeader[i,8] == "N"
          aCOLS[1][i] := 0
       ElseIf aHeader[i,8] == "D"
          aCOLS[1][i] := dDataBase
       ElseIf aHeader[i,8] == "M"
          aCOLS[1][i] := ""
       Else
          aCOLS[1][i] := .F.
       EndIf
    Else
       aCols[1][i] := CriaVar(cCampo)
    Endif
Next i
aCOLS[1][Len(aHeader)+1] := .F.

//+--------------------------------------------------------------+
//¦ Se nao existir, cria cliente generico "TRANSFERENCIA"        ¦
//+--------------------------------------------------------------+
dbSelectArea("SA1")
dbSetOrder(1)
If !dbSeek(xFilial("SA1")+"TRANSF")
   RecLock("SA1",.T.)
   Replace A1_FILIAL  With xFilial("SA1"),;
           A1_COD     With "TRANSF",;
           A1_LOJA    With "00",;
           A1_NOME    With OemToAnsi(STR0027),;  //"TRANSFERENCIA"
           A1_NREDUZ  With OemToAnsi(STR0027),;  //"TRANSFERENCIA"
           A1_TIPO    With "F",;
           A1_END     With ".",;
           A1_MUN     With ".",;
           A1_EST     With "."
   dbUnlock()
EndIf

dbSelectArea("SCN")
dbSetOrder(1)

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
dDEmissao := dDataBase
cCliente  := SA1->A1_COD
cLoja     := SA1->A1_LOJA
cNomeCli  := SA1->A1_NOME
cTipoRem  := "6"    // de transferencia

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens:=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := cRetTitle + OemToAnsi(STR0058) // cRetTitle + de Transferencia

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cCliente"  ,{15,009} ,OemToAnsi(STR0034),"@!",".T.",,.f.}) //"Cliente"
AADD(aC,{"cLoja"     ,{15,090} ,OemToAnsi(STR0029),"@!",".T.",,.f.}) //"Suc."
AADD(aC,{"cNomeCli"  ,{15,130} ," "              ,"@!",".T.",,.f.})
AADD(aC,{"cTipoRem"  ,{30,010} ,OemToAnsi(STR0035),"@9",".T.",,.f.}) //"Tipo"
AADD(aC,{"dDEmissao" ,{30,070} ,OemToAnsi(STR0036),"@D",".T.",,})    //"Fch. de Emisión"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,10},OemToAnsi(STR0033),"@E 999",,,.F.}) //"Total de Items"

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2.                          ¦
//+--------------------------------------------------------------+
cLinhaOk := 'A462TLOk()'
cTudoOk  := 'A462TTOk()'

aGetEdit := {}

//+------------------------------------------------------------------+
//¦ Ativa tecla F4 para comunicacao com Saldos por Lote.             ¦
//+------------------------------------------------------------------+
//Set Key VK_F4 To a462F4() se cancela por rutina A462F4 no compilada en el RPO

//+------------------------------------------------------------------+
//¦ Chamada da Modelo 2.                                             ¦
//+------------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,aGetSD,,"+CN_ITEM",,,, )

Set Key VK_F4 To

//+------------------------------------------------------------------+
//¦ No Windows existe a funcao de apoio CallMOd2Obj() que retorna o  ¦
//¦ objeto Getdados Corrente...                                      ¦
//+------------------------------------------------------------------+
If lRetMod2

   PegaNum()

   //+--------------------------------------------------------------+
   //¦ posiciona no cliente escolhido                               ¦
   //+--------------------------------------------------------------+
   dbSelectArea("SA1")
   dbSeek(xFilial("SA1")+Subs(cCliente,1,6))

   //+--------------------------------------------------------------+
   //¦ Atualiza o Corpo do Remito                                   ¦
   //+--------------------------------------------------------------+
   dbSelectArea("SCN")
   nMaxArray := Len(aCols)
   For ny := 1 to Len(aHeader)
       If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "CN_PRODUTO"
          nMaxArray := nMaxArray - 1
          Exit
       EndIf
   Next ny

   If lGeraLanc
      //+--------------------------------------------------------------+
      //¦ Nao Gerar os lancamento Contabeis On-Line                    ¦
      //+--------------------------------------------------------------+
      lLancPad10 := VerPadrao("710")
      lLancPad20 := VerPadrao("720")
   EndIf

   If (lLancPad10 .or. lLancPad20) .and. !__TTSInUse

      //+--------------------------------------------------------------+
      //¦ Posiciona numero do Lote para Lancamentos do Compras         ¦
      //+--------------------------------------------------------------+
      dbSelectArea("SX5")
      dbSeek(xFilial()+"09EST")
      cLoteCom:=IIF(Found(),Trim(X5DESCRI()),"EST ")
      nHdlPrv:=HeadProva(cLoteCom,"REMT011S",cUserName,@cArquivo)
      If nHdlPrv <= 0
         Help(" ",1,"A100NOPROV")
      EndIf
   EndIf

   aRecnos := {}
   nCntItem:= 1
   For nx := 1 to nMaxArray
       IF !aCols[nx][Len(aCols[nx])]
          //+--------------------------------------------------------------+
          //¦ Atualiza dados do Remito.                                    ¦
          //+--------------------------------------------------------------+
          dbSelectArea("SCN")
          RecLock("SCN",.T.)
          Replace CN_FILIAL  With xFilial("SCN"),;
                  CN_REMITO  With cRemito,;
                  CN_CLIENTE With cCliente,;
                  CN_EMISSAO With dDEmissao,;
                  CN_LOJA    With cLoja,;
                  CN_TIPOREM With cTipoRem,;
                  CN_GERANF  With "N"
          If lDepTrans
             Replace CN_QTDEFAT With -1 // Controle de condicao para a entrada
          EndIf

          //+--------------------------------------------------------------+
          //¦ Atualiza dados do corpo do Remito.                           ¦
          //+--------------------------------------------------------------+
          For ny := 1 to Len(aHeader)
              If aHeader[ny][10] #"V"
                 cCampo := AllTrim(aHeader[ny][2])
                 FieldPut(FieldPos(cCampo),aCols[nx][ny])
              Endif
          Next ny

          dbSelectArea("SB1")
          dbSetOrder(1)
          dbSeek(xFilial("SB1")+SCN->CN_PRODUTO)

          //+----------------------------------------------------------+
          //¦ Grava sempre o numero do Item Sequencial...              ¦
          //+----------------------------------------------------------+
          dbSelectArea("SCN")
          Replace CN_ITEM    With StrZero(nCntItem,2)
          Replace CN_NUMSEQ  With ProxNum()
          If Empty(CN_DTVALID)
             Replace CN_DTVALID With SCN->CN_EMISSAO + SB1->B1_PRVALID
          EndIf

          //+----------------------------------------------------------+
          //¦ Baixar Quantidades do Contrato de Parcerias...           ¦
          //+----------------------------------------------------------+
          dbSelectArea("SFG")
          dbSetOrder(2)
          dbSeek(xFilial("SFG")+SCN->CN_CLIENTE+SCN->CN_LOJA+SCN->CN_CONTRAT+SCN->CN_ITEMCON)
          If Found()
             RecLock("SFG",.F.)
             Replace FG_QUJE With ( FG_QUJE + SCN->CN_QUANT )
             If ( FG_QUJE > FG_QUANT )
                  Replace FG_QUJE With FG_QUANT
             EndIf
             dbUnLock()
          EndIf

          dbSelectArea("SCN")
          Replace CN_TOTAL   With ( SCN->CN_QUANT * SFG->FG_PRECO )
          If SF4->F4_PODER3 != "N"
             If Empty(CN_IDENTB6)
                Replace CN_IDENTB6 With CN_NUMSEQ
             EndIf
          EndIf

          AADD(aRecnos,Recno())

          //+----------------------------------------------------------+
          //¦ Verifica se havera movimentaçäo de Estoques...           ¦
          //+----------------------------------------------------------+
          dbSelectArea("SF4")
          dbSetOrder(1)
          dbSeek(xFilial("SF4")+SCN->CN_TES)

          IF EXISTBLOCK("RMTSCN01")
             ExecBlock("RMTSCN01")
          Endif
          //
          aImpCusto := {}
          aTamRem   := TamSX3( "CN_REMITO")
          aEnvCus   := {nItemValTot,aImpCusto,0.00,;
                        " "," ",Space(aTamRem[1]),Space(03),;
                        SCN->CN_PRODUTO,SCN->CN_LOCAL,SCN->CN_QUANT,0.00}
          //+-------------------------------------------------------+
          //¦ Pega os custos medios atuais                          ¦
          //+-------------------------------------------------------+
          IF SF4->F4_PODER3 == "D"
             aCM := PegaCMAtu(SCN->CN_PRODUTO,SCN->CN_LOCAL,"D", aEnvCus)
          Else
             aCM := PegaCMAtu(SCN->CN_PRODUTO,SCN->CN_LOCAL,"N", aEnvCus)
          Endif


          //+------------------------------------------------------+
          //¦ Si lleva FIFO, crea los movimientos necesarios.      ¦
          //+---------------------------------------------Diego----+
          If lCusFFRm
             xAtuCusFF()
          EndIf

          //+-------------------------------------------------------+
          //¦ Grava o custo da movimentacao                         ¦
          //+-------------------------------------------------------+
          aCusto := {}   // GravaCusCN(aCM) Se comenta  por Rutinas Descontinuadas

          //+-------------------------------------------------------+
          //¦ Atualiza o saldo atual (VATU) com os dados do SCN     ¦
          //+-------------------------------------------------------+
          // B2AtuComCN(aCusto,,.F.)  Se comenta  por Rutinas Descontinuadas


          //+--------------------------------------------------+
          //¦ Gera lancamento Contab. a nivel de Itens         ¦
          //+--------------------------------------------------+

          // Gera D3 somente se utiliza Dep de Transferencia
          If SF4->F4_ESTOQUE == "S" .And. lDepTrans

             //+---------------------------------------------------------+
             //¦ Gerar Requisicao automatica para acertar os saldos em   ¦
             //¦ estoque e tratar o custo.                               ¦
             //+---------------------------------------------------------+
             ReqAuto()

             //+---------------------------------------------------------+
             //¦ Atualizar e Controlar Saldo em/de Poder de Terceiros... ¦
             //+---------------------------------------------------------+
             If SF4->F4_PODER3 != "N"
                Poder3A()
             EndIf

          ElseIf !lDepTrans

             If Empty(cRotInt)
                cRtoInt := GetSX8Num("SCM","CM_ORT")  // Almacena en SX8 Numeracion Automat.
             EndIf

             nPosCMTES := Ascan(aHeader,{|x| Alltrim(x[2]) = "CM_TES"})
             nPosCMCF  := Ascan(aHeader,{|x| Alltrim(x[2]) = "CM_CF"})
             dbSelectArea("SF4")
             dbSetOrder(1)
             dbSeek(xFilial("SF4")+RetFldProd(SB1->B1_COD,"B1_TE"))

             dbSelectArea("SCM")
             RecLock("SCM",.T.)
             Replace CM_FILIAL  With xFilial("SCM"),;
                     CM_REMITO  With cRemito,;
                     CM_FORNECE With cCliente,;    // tienen el mismo codigo "TRANSF"
                     CM_EMISSAO With dDEmissao,;
                     CM_LOJA    With cLoja,;
                     CM_ORT     With cRtoInt,;     // J.L.Otermin 08/02/99
                     CM_ITEM    With StrZero(nCntItem,2),;
                     CM_NUMSEQ  With ProxNum(),;
                     CM_PRODUTO With SCN->CN_PRODUTO,;
                     CM_UM      With SCN->CN_UM,;
                     CM_QUANT   With SCN->CN_QUANT,;
                     CM_TES     With aCOLS[nx,nPosCMTES],;
                     CM_CF      With aCOLS[nx,nPosCMCF],;
                     CM_LOCAL   With SCN->CN_LOCDEST,;
                     CM_LOTECTL With SCN->CN_LOTECTL,;
                     CM_SEGUM   With SCN->CN_SEGUM,;
                     CM_QTSEGUM With SCN->CN_QTSEGUM

//                     CM_NUMLOTE With SCN->CN_NUMLOTE,;

             If Empty(CM_DTVALID) .and. cRastro $ "LS"   // 12-05-99 jose luis
                Replace CM_DTVALID With SCM->CM_EMISSAO + SB1->B1_PRVALID
             EndIf
             Replace CM_TOTAL   With ( SCM->CM_QUANT * RetFldProd(SB1->B1_COD,"B1_UPRC") )
             If SF4->F4_PODER3 != "N"
                If Empty(CM_IDENTB6)
                   Replace CM_IDENTB6 With CM_NUMSEQ
                EndIf
             EndIf
            IF EXISTBLOCK("RMTSCM01")
               ExecBlock("RMTSCM01")
            Endif

             ConfirmSX8()          // Actualiza Ultimo RtoInterno en SX8
             MsUnlock()

             dbSelectArea("SCM")
             //+--------------------------------------------+
             //¦ Grava o custo da movimentacao              ¦
             //+--------------------------------------------+
             aCusto := {}   // GravaCusCM(aCM)    // o aCM é montado no DevAuto()      Se comenta  por Rutinas Descontinuadas
             //+-------------------------------------------------------+
             //¦ Atualiza o saldo atual (VATU) com os dados do SCM     ¦
             //+-------------------------------------------------------+
             // B2AtuComCM() Se comenta  por Rutinas Descontinuadas

          EndIf

          If lLancPad10
             nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"710","REMT011S",cLoteCom,@nLinha)
          Endif

          //+---------------------------------------------------------+
          //¦ Gera lancamento Contab. a Devolucao...                  ¦
          //+---------------------------------------------------------+
          If lLancPad20
             nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"720","REMT011S",cLoteCom,@nLinha)
          EndIf

          dbSelectArea("SCN")
          nCntItem:=nCntItem + 1
       EndIF
   Next nx

   AtuaSX5()

   If ExistBlock("RMTSCM03")
      ExecBlock("RMTSCM03")
   Endif

   If nHdlPrv > 0 .and. (lLancPad10.or.lLancPad20) .and. !__TTSInUse

      //+--------------------------------------------------+
      //¦ Gera Lancamento Contab. para Totais da N.Fiscal  ¦
      //+--------------------------------------------------+
      If lLancPad20
         nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"720","REMT011S",cLoteCom,@nLinha)
      Endif

      //+-----------------------------------------------------+
      //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
      //+-----------------------------------------------------+
      RodaProva(nHdlPrv,nTotalLanc)

      //+-----------------------------------------------------+
      //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
      //+-----------------------------------------------------+
      lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina)

      If lLanctOk
         For nC := 1 To Len(aRecnos)
             dbSelectArea("SCN")
             dbGoTo( aRecnos[nC] )
             RecLock("SCN",.F.)
             Replace CN_DTLANC With dDataBase
             MsUnLock()
         Next nC
      EndIf
   EndIf
Endif
Return(lRetMod2)        



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ReqAuto()¦ Autor ¦ José Lucas            ¦ Data ¦ 20/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Requisicao Automatica.                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function ReqAuto()

dbSelectArea("SB2")
dbSeek(xFilial()+SCN->CN_PRODUTO+cDepTrans)
If EOF()
   CriaSB2(SCN->CN_PRODUTO,cDepTrans)
EndIf

//+------------------------------------------------------+
//¦ OMB - 02/05/99 - Nao deve estornar reserva, pois nos ¦
//¦ remitos manuais nao ha pedido de venda               ¦
//+------------------------------------------------------+
//RecLock("SB2",.F.)
//Replace B2_RESERVA With B2_RESERVA - SCN->CN_QUANT

cNumseq := ProxNum()

//+------------------------------------------+
//¦ Gera Requisicao automatica               ¦
//+------------------------------------------+
RecLock("SD3",.T.)
Replace D3_FILIAL  With xFilial("SD3")
Replace D3_DOC     With SCN->CN_REMITO
Replace D3_ITEM    With SCN->CN_ITEM
Replace D3_COD     With SCN->CN_PRODUTO
Replace D3_UM      With SCN->CN_UM
Replace D3_EMISSAO With dDatabase
Replace D3_GRUPO   With SB1->B1_GRUPO
Replace D3_TIPO    With SB1->B1_TIPO
Replace D3_CF      With "RE4"
Replace D3_LOCAL   With cDepTrans
Replace D3_QUANT   With SCN->CN_QUANT
Replace D3_TM      With "499"
Replace D3_USUARIO With CUSERNAME
Replace D3_NUMSEQ  With cNumSeq
Replace D3_CHAVE   With SubStr(D3_CF,2,1)+"0"
Replace D3_LOTECTL With SCN->CN_LOTECTL
Replace D3_DTVALID With SCN->CN_DTVALID

IF RASTRO(D3_COD)
   Replace D3_NUMLOTE With NextLote(D3_COD,"S")
ENDIF

nItemValTot := (SCN->CN_QUANT * SC6->C6_PRCVEN)

//+-----------------------------------------------------------+
//¦ Obter o Custo de Entrada com base na Quantidade, Preço do ¦
//¦ do Pedidos/Contrato de Parcerias e nos Impostos Variaveis.¦
//+-----------------------------------------------------------+
aImpCusto := {}
//ARemCusto()

aTamRem := TamSX3( "CN_REMITO")
aEnvCus := {nItemValTot,aImpCusto,0.00,;
            " "," ",Space(aTamRem[1]),Space(03),;
            SCN->CN_PRODUTO,SCN->CN_LOCAL,SD3->D3_QUANT,0.00}

//+-------------------------------------------------------+
//¦ Pega os custos medios atuais                          ¦
//+-------------------------------------------------------+
IF SF4->F4_PODER3 == "D"
   aCM := PegaCMAtu(SCN->CN_PRODUTO,SCN->CN_LOCAL,"D", aEnvCus)
Else
   aCM := PegaCMAtu(SCN->CN_PRODUTO,SCN->CN_LOCAL,"N", aEnvCus)
Endif

//+-------------------------------------------------------+
//¦ Grava o custo da movimentacao                         ¦
//+-------------------------------------------------------+
aCusto := GravaCusD3(aCM)

//+-------------------------------------------------------+
//¦ Atualiza o saldo atual (VATU) com os dados do SD3     ¦
//+-------------------------------------------------------+
B2AtuComD3(aCusto)
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Poder3   ¦ Autor ¦ José Lucas            ¦ Data ¦ 04/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualizar e Efetuar o Controle de Terceiros.               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function Poder3()

cProduto  := SCN->CN_PRODUTO
cLocal    := SCN->CN_LOCAL
nQuant    := SCN->CN_QUANT
cTipo     := "N"
aCpoSD    := Array(17)
aCustoSB6 := Array(5)
aCustoEnt := {}
aDupl     := {}

If SF4->F4_PODER3 != "N"

	If SF4->F4_ESTOQUE == "S"
		//+-------------------------------------------------------------+
		//¦ Atualiza o saldo controle de Poder Terceiros SB2.        	 ¦
		//+-------------------------------------------------------------+
		dbSelectArea("SB2")
		dbSeek(xFilial("SB2")+cProduto+cLocal)
		If Found()
			RecLock("SB2",.F.)
		Else
			CriaSB2(cProduto,cLocal)
		Endif
		If cTipo == "N"
			If     SF4->F4_PODER3 == "D"
				Replace B2_QTNP  With B2_QTNP-nQuant
			ElseIf SF4->F4_PODER3 == "R"
				Replace B2_QNPT  With B2_QNPT+nQuant
			EndIf
		ElseIf cTipo == "B"
			If 	 SF4->F4_PODER3 == "R"
				Replace B2_QNPT  With B2_QNPT+nQuant
			ElseIf SF4->F4_PODER3 == "D"
				Replace B2_QTNP  With B2_QTNP-nQuant
			EndIf
		EndIf
	Else
		aCusto := {0,0,0,0,0}
		If SF4->F4_PODER3 $ "D¦R"
			dbSelectArea("SB2")
			dbSeek(xFilial("SB2")+cProduto+cLocal)
			If Found()
				RecLock("SB2",.F.)
			Else
				CriaSB2(cProduto,cLocal)
			Endif
			If SF4->F4_PODER3 == "D"
				Replace B2_QTER  With B2_QTER-nQuant
			Else
				Replace B2_QTER  With B2_QTER+nQuant
			Endif
		EndIf
	EndIf

	If nItemValTot > 0

		//+-----------------------------------------------------------+
		//¦ Gravar as movimentaçöes no Arquivo De/Poder Terceiros.    ¦
		//+-----------------------------------------------------------+
		aCpoSD[01] := SCN->CN_CLIENTE
		aCpoSD[02] := SCN->CN_LOJA
		aCpoSD[03] := SCN->CN_PRODUTO
		aCpoSD[04] := SCN->CN_LOCAL
		aCpoSD[05] := SC6->C6_PRCVEN
		aCpoSD[06] := "E"
		aCpoSD[07] := SCN->CN_REMITO
		aCpoSD[08] := "REM"
		aCpoSD[09] := SCN->CN_EMISSAO
		aCpoSD[10] := SCN->CN_EMISSAO
		aCpoSD[11] := SC6->C6_CF
		aCpoSD[12] := SCN->CN_QUANT
		aCpoSD[13] := SCN->CN_UM
		aCpoSD[14] := SCN->CN_QTSEGUM
		aCpoSD[15] := SCN->CN_SEGUM
		aCpoSD[16] := nItemValTot
		aCpoSD[17] := SCN->CN_NUMSEQ

		//+-----------------------------------------------------------+
		//¦ Gravar as movimentaçöes no Arquivo De/Poder Terceiros.    ¦
		//+-----------------------------------------------------------+
		aCustoSB6[1] := aCusto[1]
		aCustoSB6[2] := aCusto[2]
		aCustoSB6[3] := aCusto[3]
		aCustoSB6[4] := aCusto[4]
		aCustoSB6[5] := aCusto[5]

		cChaveSB6  := SCN->CN_IDENTB6+cProduto
		AtuaSB6(cTES,cChaveSB6,aCpoSD,aCustoSB6,cTipo)
		dbSelectArea("SCN")
		RecLock("SCN",.F.)
		Replace CN_IDENTB6 With SCN->CN_NUMSEQ
		MsUnLock()
	EndIf
EndIf
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ PegaNum  ¦ Autor ¦ Armando T. Buchina    ¦ Data ¦ 10.02.98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Dat GET para o Primeiro Numero de Remito Valida            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ REMT011S                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function PegaNum()

DbSelectArea("SX5")
If !DbSeek(xFilial("SX5")+"99"+"RE"+cGrDepOri,.F.)
   RecLock("SX5", .t.)
   SX5->X5_TABELA := '99'
   SX5->X5_FILIAL := xFilial("SX5")
   SX5->X5_CHAVE  := 'RE'+IIf(Empty(cGrDepOri),StrZero(Val(SM0->M0_CODFIL),4),cGrDepOri)
   SX5->X5_DESCRI := Subs(SX5->X5_CHAVE,3,4)+'00000001'
   SX5->X5_DESCSPA := Subs(SX5->X5_CHAVE,3,4)+'00000001'
   SX5->X5_DESCENG := Subs(SX5->X5_CHAVE,3,4)+'00000001'
   cRemito        := Alltrim(X5DESCRI())
Else
   cRemito := StrZero(Val(X5DESCRI()),12)
EndIf

While .t.

   cCadastro := OemToAnsi(STR0061)+ cRetTitle + OemToAnsi(STR0058) // Nro + cRetTitle + de Transferencia

   @ 96,42 to 190,350 DIALOG oDlg1 TITLE cCadastro
   @ 05,5 TO 27,150
   @ 5.1 ,8.3  SAY OemToAnsi(STR0062)+OemToAnsi(STR0063)+OemToAnsi(STR0061)+OemToAnsi(STR0064)+cRetTitle  // Informe+el+n£mero+de lapr¢xima+cRetTitle
   @ 15.1,36.3 GET cRemito SIZE 50,10
   @ 30,90  BMPBUTTON TYPE 1 Action myProc()// Substituido pelo assistente de conversao do AP5 IDE em 07/12/99 ==>    @ 30,90  BMPBUTTON TYPE 1 Action Execute(myProc)
   @ 30,120 BMPBUTTON TYPE 2 ACTION fCancel()// Substituido pelo assistente de conversao do AP5 IDE em 07/12/99 ==>    @ 30,120 BMPBUTTON TYPE 2 ACTION Execute(fCancel)
   ACTIVATE DIALOG oDlg1 CENTERED

   IF (nOpcA != 1)
      MsRUnLock()
      Return
   Endif

   // Incluir a Consistencia para existencia do numero do Remito em SCN.
   // Para isso deve existir chave por CN_FILIAL+CN_REMITO para dar seek
   DbSelectArea("SCN")
   myIndex := IndexOrd()
   DbSetOrder(1)
   nRecno := Recno()
   If dbSeek( xFilial("SCN") + cRemito )
      HELP(" ",1,"NUMEXIST")
      cRemito := Soma1( cRemito)
      DbSetOrder( myIndex )
      DbGoTo( nRecno )
      LOOP
   EndIf
   DbSetOrder( myIndex )
   DbGoTo( nRecno )

   Exit
EndDo

Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ AtuaSX5  ¦ Autor ¦ Armando T. Buchina    ¦ Data ¦ 10.02.98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza o Ultimo numero gerado em SX5                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ MatARem                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function AtuaSX5()

_Alias := Alias()
DBSelectArea("SX5")

If DbSeek( xFilial("SX5")+"99"+"RE"+cGrDepOri,.F. )
   cRemito := StrZero( Val(cRemito)+1, 12 )
   RecLock("SX5",.F.)
   Replace X5_DESCRI With cRemito
   Replace X5_DESCSPA With cRemito
   Replace X5_DESCENG With cRemito
   MsUnLock()
Else
   MsUnLock()
   Return(.f.)
EndIf

DbSelectArea( _Alias )
Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ myProc   ¦ Autor ¦ Armando T. Buchina    ¦ Data ¦ 10.02.98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Click do Button OK na Dialog                               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ REMT011S                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function myProc()
   nOpcA := 1
   Close(oDlg1)
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fCancel  ¦ Autor ¦ Armando T. Buchina    ¦ Data ¦ 10.02.98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Click do Button Cancela na Dialog                          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ REMT011S                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function fCancel()
   nOpcA := 2
   Close(oDlg1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Función   ¦xAtuCusFF ¦ Autor ¦ Diego Fernando Rivero ¦ Data ¦ 20/10/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrip.  ¦ Baja de los Saldos de SBD con moviminentos FIFO            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ REMV001, REMV011, REMT011S                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function xAtuCusFF()

cHelp    := ""
cValue   := ""
nProp    := 1
nQtdBai  := 0
nQuant   := 0
nQtdFim  := 0
cAlias   := Alias()
cProduto := ""
cLocal   := ""
cCF      := ""
cTipoNF  := ""
cSerie   := ""
cItem    := ""
cDoc     := ""
cOP      := ""
cTM      := ""
dData    := CtoD("  /  /  ")
aCusSBD  := Array(5)
aSBDFim  := Array(2)
nOldRec  := 0

nDec     := Set(3,8)
Afill(aCusSBD,0)

cFilial  := xFilial("SBD")
cProduto := SCN->CN_PRODUTO
nQuant   := SCN->CN_QUANT
cLocal   := SCN->CN_LOCAL
cCF      := "RE0"
cTM      := "999"
cTipoNF  := "N"
cDoc     := SCN->CN_REMITO
cOP      := Space(5)
dData    := SCN->CN_EMISSAO


While .T.
   //+-------------------------------------------------------+
   //¦ Posiciona no local a ser atualizado,o primeiro que    ¦
   //¦ tiver saldo                                           ¦
   //+-------------------------------------------------------+
   dbSelectArea("SBD")
   dbSetOrder(1)
   dbSeek(cFilial+cProduto+cLocal+" ")

   If Eof()
      Exit
   Endif

   If SBD->BD_QFIM >= nQuant
      nQtdBai := nQuant
      nProp   := (nQtdBai / SBD->BD_QFIM)
   Else
      nQtdBai := SBD->BD_QFIM
      nProp   := 1
   Endif

   aCusSBD[01] := aCusSBD[01] + Round(NoRound(BD_CUSFIM1 * nProp,3),2)
   aCusSBD[02] := aCusSBD[02] + Round(NoRound(BD_CUSFIM2 * nProp,3),2)
   aCusSBD[03] := aCusSBD[03] + Round(NoRound(BD_CUSFIM3 * nProp,3),2)
   aCusSBD[04] := aCusSBD[04] + Round(NoRound(BD_CUSFIM4 * nProp,3),2)
   aCusSBD[05] := aCusSBD[05] + Round(NoRound(BD_CUSFIM5 * nProp,3),2)
   nQtdFim     := nQtdFim + nQtdBai

   nCusto1 := Round(NoRound(BD_CUSFIM1 * nProp,3),2)
   nCusto2 := Round(NoRound(BD_CUSFIM2 * nProp,3),2)
   nCusto3 := Round(NoRound(BD_CUSFIM3 * nProp,3),2)
   nCusto4 := Round(NoRound(BD_CUSFIM4 * nProp,3),2)
   nCusto5 := Round(NoRound(BD_CUSFIM5 * nProp,3),2)
   nSeq    := SBD->BD_SEQ

   //+-------------------------------------------------------+
   //¦ Grava Movimentacao dos Lotes FIFO no "SD8"            ¦
   //+-------------------------------------------------------+
   xAtuMovFF()

   RecLock("SBD",.F.)
   Replace  BD_QFIM    With BD_QFIM    - nQtdBai
   Replace  BD_CUSFIM1 With BD_CUSFIM1 - Round(NoRound(BD_CUSFIM1 * nProp,3),2)
   Replace  BD_CUSFIM2 With BD_CUSFIM2 - Round(NoRound(BD_CUSFIM2 * nProp,3),2)
   Replace  BD_CUSFIM3 With BD_CUSFIM3 - Round(NoRound(BD_CUSFIM3 * nProp,3),2)
   Replace  BD_CUSFIM4 With BD_CUSFIM4 - Round(NoRound(BD_CUSFIM4 * nProp,3),2)
   Replace  BD_CUSFIM5 With BD_CUSFIM5 - Round(NoRound(BD_CUSFIM5 * nProp,3),2)
   Replace BD_DTCALC  With dDataBase
   If SBD->BD_QFIM == 0
      Replace BD_STATUS  With "Z"
   EndIf
   MsUnlock()

   nQuant  := nQuant - nQtdBai

   If nQuant <= 0
      Exit
   Endif

End

aSBDFim[01] := aCusSBD
aSBDFim[02] := nQtdFim
Set(3,nDec)

DbSelectArea("SCN")
RecLock("SCN",.F.)
Replace CN_CUSFF1 With aCusSBD[01]
Replace CN_CUSFF2 With aCusSBD[02]
Replace CN_CUSFF3 With aCusSBD[03]
Replace CN_CUSFF4 With aCusSBD[04]
Replace CN_CUSFF5 With aCusSBD[05]
MsUnLock()

dbSelectArea(cAlias)

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦GravaSD8  ¦ Autor ¦ Marcos / Rosane       ¦ Data ¦ 28/08/97 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava SB8 com Movimentacoes Lotes FIFO                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ REMV001, REMV011, REMT011S                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function xAtuMovFF()
cAlias := Alias()

nSeqFIFO := Val(GetMV("MV_SEQFIFO"))
nSeqFIFO := nSeqFIFO + 1

PUTMV("MV_SEQFIFO", StrZero(nSeqFIFO,6))

//+-------------------------------------------------------+
//¦ Posiciona no local a ser atualizado                   ¦
//+-------------------------------------------------------+
dbSelectArea("SD8")
RecLock("SD8",.T.)
Replace D8_PRODUTO With SBD->BD_PRODUTO
Replace D8_LOCAL   With SBD->BD_LOCAL
Replace D8_QUANT   With IIf(nQtdBai==Nil,SBD->BD_QUANT,nQtdBai)
Replace D8_FILIAL  With xFilial("SD8")
Replace D8_DATA    With dData
Replace D8_CUSTO1  With nCusto1
Replace D8_CUSTO2  With nCusto2
Replace D8_CUSTO3  With nCusto3
Replace D8_CUSTO4  With nCusto4
Replace D8_CUSTO5  With nCusto5
Replace D8_SEQ     With nSeq
Replace D8_CF      With cCF
Replace D8_TIPONF  With cTipoNF
Replace D8_DOC     With cDoc
Replace D8_OP      With cOP
Replace D8_SEQCALC With StrZero(nSeqFIFO,6)
Replace D8_DTPROC  With dDataBase
Replace D8_DTCALC  With dDataBase
Replace D8_TM      With cTM
Replace D8_SERIE   With "X"
Replace D8_ITEM    With cItem
MsUnlock()
dbSelectArea( cAlias )
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMT013S ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao do aCols da modelo2                              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Remito de Transferencia - REMT011S.PRW                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462TVldS()
Local cCampo
SetPrvt("_LRET,CCONTD,_CAREA,NPOSLOCAL,NPOSUM")
SetPrvt("NPOSTES,NPOSCF,_NPOS,ACOLS,NPOSCOD,NPOSLOTE")
SetPrvt("NPOSLOTCTL,NPOSDVALID,_CCOD,_CTES,_CLOCAL,_CLOTE")
SetPrvt("_CLOTECTL,_CLOTEDIGI,LREFRESH")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

_lRet  := .t.
cCampo := ReadVar()
cContd := &(cCampo)
_cArea := Alias()

If AllTrim( cCampo) $ "M->CN_PRODUTO"

   nPosLocal := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_LOCAL"})
   nPosLocDe := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_LOCDEST"})
   nPosUM    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_UM"})
   nPosTES   := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_TES"})
   nPosCF    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_CF"})
   nPosSegUm := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_SEGUM"})
   nPosGrupo := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_GRUPO"})

   If Empty(cContd)
      _lRet := .F.
   Else
      SB1->(dbSetOrder(1))
      SB1->(dbSeek(xFilial("SB1")+cContd))
      If !SB1->( Found() )
         Help(" ",1,"REMT013S")
         _lRet := .F.
      EndIf
      _nPos := Ascan(aCOLS,{|x| x[1] == cCampo})

      If _nPos != 0
         If _nPos != n
            Help(" ",1,"REMT013S")
            _lRet := .F.
         EndIf
      EndIf

      SF4->( dbSetOrder(1) )
      SF4->( dbSeek(xFilial("SF4")+RetFldProd(SB1->B1_COD,"B1_TS")) )
      If nPosLocal > 0
         // Ve si el deposito padron se encuadra en el grupo origen
         dbSelectArea("SX5")
         dbSetOrder(1)
         If dbSeek(xFilial("SX5")+"74"+cGrDepOri)
            If !(RetFldProd(SB1->B1_COD,"B1_LOCPAD") $ X5DESCRI())
               If Len(Alltrim(X5DESCRI()))==2
                  aCOLS[n][nPosLocal] := Subs(X5DESCRI(),1,2)
               Endif
            Else
               aCOLS[n][nPosLocal] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
            EndIF
         EndIf
      EndIf
      If nPosUM > 0
         aCOLS[n][nPosUM] := SB1->B1_UM
      EndIf
      If nPosSegUM > 0
         aCOLS[n][nPosSegUM] := SB1->B1_SegUM
      EndIf
      If nPosGrupo > 0
         aCOLS[n][nPosgRUPO] := SB1->B1_GRUPO
      EndIf
      If nPosTES > 0
         aCOLS[n][nPosTes] := RetFldProd(SB1->B1_COD,"B1_TS")
      EndIf
      If nPosCF > 0
         aCOLS[n][nPosCF] := SF4->F4_CF
      EndIf
      If nPosLocDe   >  0
         dbSelectArea("SX5")
         dbSetOrder(1)
         If dbSeek(xFilial("SX5")+"74"+cGrDepDst)
            If Len(Alltrim(X5DESCRI()))==2
                aCOLS[n][nPosLocDe] := Subs(X5DESCRI(),1,2)
            Endif
         EndIf
      Endif
   EndIf

ElseIf AllTrim( cCampo) $ "M->CN_LOTECTL^M->CN_NUMLOTE"

   nPosCod    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_PRODUTO"})
   nPosTES    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_TES"})
   nPosLocal  := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_LOCAL"})
   nPosLote   := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_NUMLOTE"})
   nPosLotCtl := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_LOTECTL"})
   nPosDValid := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_DTVALID"})

   If nPosCod > 0 .and. nPosTES > 0 .and. nPosLocal > 0 .and.;
      nPosLote > 0 .and. nPosLotCtl > 0 .and. nPosDValid > 0
      _cCod      := aCols[n,nPosCod]
      _cTES      := aCols[n,nPosTES]
      _cLocal    := aCols[n,nPosLocal]
      _cLote     := aCols[n,nPosLote]
      _cLoteCtl  := aCols[n,nPosLotCtl]
      _cLoteDigi := aCols[n,nPosDValid]
   Else
      _lRet := .F.
   EndIf
   If _lRet
      If !Rastro(_cCod)
         aCols[n,nPosLote]   := CriaVar("CN_NUMLOTE")
         aCols[n,nPosLotCtl] := CriaVar("CN_LOTECTL")
         aCols[n,nPosDValid] := CriaVar("CN_DTVALID")
         Help(" ",1,"NAORASTRO")
         Return .F.
      EndIf
      If cCampo == "M->CN_LOTECTL"
         If !Empty(_cLote)
            dbSelectArea("SB8")
            dbSetOrder(2)
            If dbSeek(xFilial()+_cLote+_cCod) .And. cContd != SB8->B8_LOTECTL
               Help(" ",1,"RET_LOTCTL")
               _lRet:=.F.
            EndIf
         Else
            dbSelectArea("SB8")
            dbSetOrder(3)
            If dbSeek(xFilial()+cContd)
               Help(" ",1,"RET_CTLEX")
               _lRet:=.F.
            EndIf
         EndIf
      ElseIf cCampo == "M->CN_NUMLOTE"
         If !Empty(cContd)
            dbSelectArea("SB8")
            dbSetOrder(2)
            If dbSeek(xFilial()+cContd+_cCod)
               M->CN_LOTECTL:=SB8->B8_LOTECTL
               aCols[n,nPosLote] := cContd
               aCols[n,nPosLotCtl] := SB8->B8_LOTECTL
            Else
               M->CN_NUMLOTE := CriaVar("CN_NUMLOTE")
               M->CN_LOTECTL := CriaVar("CN_LOTECTL")
               M->CN_DTVALID := CriaVar("CN_DTVALID")
               aCols[n,nPosLote] := CriaVar("CN_NUMLOTE")
               aCols[n,nPosLotCtl] := CriaVar("CN_LOTECTL")
               aCols[n,nPosdValid] := CriaVar("CN_DTVALID")
            EndIf
            lRefresh:=.T.
         EndIf
      EndIf
   EndIf
ElseIf AllTrim( cCampo) == "M->CN_DTVALID"
   nPosLotCtl := Ascan(aHeader,{|x| AllTrim(x[2]) == "CM_LOTECTL"})
   If nPosLotCtl > 0
      If Empty(aCols[n,nPosLotCtl])
         Help(" ",1,"NDIGITLOTE")
         _lRet:=.F.
      EndIf
      If _lRet .And. M->CM_DTVALID < dDataBase
         Help(" ",1,"DTVALIDINV")
        _lRet:=.F.
      EndIf
   EndIf
ElseIf AllTrim( cCampo) $ "M->CN_LOCAL^M->CN_LOCDEST"
   dbSelectArea("SX5")
   dbSetOrder(1)
   If (AllTrim( cCampo) == "M->CN_LOCAL"  .And. dbSeek(xFilial("SX5")+"74"+cGrDepOri)) .OR.;
      (AllTrim( cCampo) == "M->CN_LOCDEST".And. dbSeek(xFilial("SX5")+"74"+cGrDepDst))
      If !(cContd $ X5DESCRI())
         Help( " ",1,"NOLOCVALID") // deposito nao pertence ao grupo (escolhidos nos parametros)
         _lRet := .f.
      EndIF
   Else
      Help(" ",1,"NOGRPDEP")  // nao encontrou grupo cadastrado
      _lRet := .f.
   EndIf
ElseIf AllTrim( cCampo) == "M->CN_QUANT"
   nPosQtSeg    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_QTSEGUM"})
   nPosSegUm    := Ascan(aHeader,{|x| AllTrim(x[2]) == "CN_SEGUM"})
   If nPosSEGUM+nPosQtSeg  > 0
      aCOLS[n][nPosQtSeg] := M->CN_QUANT * (SB1->B1_CONV  ** IIF(SB1->B1_TIPCONV=="D",-1,1))
   EndIf
EndIf
dbSelectArea( _cArea)
Return(_lRet)        


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMTLOK  ¦ Autor ¦ José Lucas            ¦ Data ¦ 05/05/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validar se a linha da GetDados digitada esta' Ok.          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Parametros¦ ExpC1 = Objeto a ser verificado.                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ REMC011E - Remito de Transferencia                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462TLOk()

Local nPosLocal   := 0
Local nPosLocDest := 0
Local nPosTes     := 0
Local lRet := .T.
Local _cRastro := GetMV("MV_RASTRO")
Local _cProduto := Space(15)
Local _cRastroProd := Space(1)
Local nX,nC
SetPrvt("NTOTALITENS,")

If !aCols[n,Len(aCols[n])]      /// Se esta Deletado

   nC := Ascan(aHeader,{|X| Trim(X[2]) == "CN_PRODUTO"})
   If nC > 0
      _cProduto := aCols[n][nC]
   Endif

   SB1->( dbSetOrder(1) )
   SB1->( dbSeek(xFilial("SB1")+_cProduto) )
   _cRastroProd := SB1->B1_RASTRO

   For nx := 1 To Len(aHeader)
      If Trim(aHeader[nx][2]) == "CN_PRODUTO" .AND.Empty(aCols[n][nx])
         Help(" ",1,"CPOPROD")
         lRet := .F.
         Exit
      ElseIf Trim(aHeader[nx][2]) == "CN_QUANT" .AND.Empty(aCols[n][nx])
         Help(" ",1,"CPOQTDE")
         lRet := .F.
         Exit
      ElseIf Trim(aHeader[nx][2]) == "CN_LOCAL"
         If Empty(aCols[n][nx])
            Help(" ",1,"CPOLOCAL")
            lRet := .F.
            Exit
         Else
            nPosLocal   := nX
         Endif
      ElseIf Trim(aHeader[nx][2]) == "CN_LOCDEST"
         If Empty(aCols[n][nx])
            Help(" ",1,"CPOLOCDEST")
            lRet := .F.
            Exit
         Else
            nPosLocDest   := nX
         Endif
      ElseIf Trim(aHeader[nx][2]) == "CN_TES"
         If Empty(aCols[n][nx])
            Help(" ",1,"CPOTES")
            lRet := .F.
            Exit
         Else
            nPosTes  := nX
         Endif
      ElseIf Trim(aHeader[nx][2]) == "CN_LOTECTL"
         If Empty(aCols[n][nx])
            If ( _cRastro == "S" .And. _cRastroProd == "S" )
               Help(" ",1,"CPOLOTE")
               lRet := .F.
               Exit
            Endif
         ElseIf ( _cRastro == "N" .Or. _cRastroProd == "N" )
             Help(" ",1,"NAORASTRO")
             lRet := .F.
             Exit
         Endif
      ElseIf Trim(aHeader[nx][2]) == "CN_NUMLOTE"
         If Empty(aCols[n][nx])
            If ( _cRastro == "S" .And. _cRastroProd == "S" )
               Help(" ",1,"CPOLOTE")
               lRet := .F.
               Exit
            Endif
         ElseIf ( _cRastro == "N" .Or. _cRastroProd == "N" )
             Help(" ",1,"NAORASTRO")
             lRet := .F.
             Exit
         Endif
      EndIf
   Next nx
   nTotalItens := Len( aCols)

   If lRet
      If nPosTes > 0
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial()+aCols[n][nPosTes]))
         If !SF4->(Found())
            Help(" ",1,"NOTES")
            lRet := .F.
         Endif
      Endif
      If lRet
         dbSelectArea("SX5")
         dbSetOrder(1)
         If  nPosLocDest > 0 .And. dbSeek(xFilial("SX5")+"74"+cGrDepDst)
            If !(aCols[n][nPosLocDest] $ X5DESCRI())
               Help( " ",1,"NOLOCVALID") // deposito nao pertence ao grupo (escolhidos nos parametros)
               lRet := .f.
            EndIF
         Endif
         If lRet .And. nPosLocal > 0 .And. dbSeek(xFilial("SX5")+"74"+cGrDepOri)
            If !(aCols[n][nPosLocal] $ X5DESCRI())
               Help( " ",1,"NOLOCVALID") // deposito nao pertence ao grupo (escolhidos nos parametros)
               lRet := .f.
            EndIf
         EndIf
         If !SX5->(FOUND())
            Help(" ",1,"NOGRPDEP")  // nao encontrou grupo cadastrado
            lRet := .f.
         Endif
      Endif
   EndIf

   For nX := 1 to Len( aCols)
       If aCols[nX,Len(aCols[nX])]
          nTotalItens := nTotalItens - 1
       EndIf
   Next
EndIf
Return( lRet )        



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ REMTTOK   ¦ Autor ¦ José Lucas           ¦ Data ¦ 29/11/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validar se as linhas da GetDados digitadas estäo Ok.       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Parametros¦ ExpC1 = Objeto a ser verificado.                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ REMT011e - Remito de Transferencia                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A462TTOk()

Local aDeps := {}, nPosLocal,nPosDep,nK
Local nx:=0
Local ny:=0
Local nc:=0
SetPrvt("LRET,_CRASTRO,_CPRODUTO,_CRASTROPROD,NC,NX")
SetPrvt("LDELETED,NY,")

lRet := .T.

_cRastro := GetMV("MV_RASTRO")
_cProduto := Space(15)
_cRastroProd := Space(1)
nPosLocal   := Ascan(aHeader,{|X| Alltrim(X[2])=="CN_LOCAL"})
nPosProd    := Ascan(aHeader,{|X| Alltrim(X[2])=="CN_PRODUTO"})
For nC := 1 To Len(aCols)
    For nx:= 1 To Len(aHeader)
        If ValType(aCols[nC,Len(aCols[nC])]) == "L"  /// Verifico se posso Deletar
           lDeleted := aCols[nC,Len(aCols[nC])]      /// Se esta Deletado
        End
    Next nx
    If !lDeleted
       For nY := 1 To Len(aHeader)
           If Trim(aHeader[nY][2]) == "CN_PRODUTO"
              _cProduto := aCols[nC][nY]
              Exit
           Endif
       Next nY

       SB1->( dbSetOrder(1) )
       SB1->( dbSeek(xFilial("SB1")+_cProduto) )
       _cRastroProd := SB1->B1_RASTRO
       For nx := 1 To Len(aHeader)
           If Empty(aCols[nC][nx])
              If Trim(aHeader[nx][2]) == "CN_PRODUTO"
                 Help(" ",1,"CPOPROD")
                 lRet := .F.
                 Exit
              Endif
              If Trim(aHeader[nx][2]) == "CN_QUANT"
                 Help(" ",1,"CPOQTDE")
                 lRet := .F.
                 Exit
              Endif
              If Trim(aHeader[nx][2]) == "CN_LOCAL"
                 Help(" ",1,"CPOLOCAL")
                 lRet := .F.
                 Exit
              Endif
              If Trim(aHeader[nx][2]) == "CN_LOCDEST"
                 Help(" ",1,"CPOLOCDEST")
                 lRet := .F.
                 Exit
              Endif
              If Trim(aHeader[nx][2]) == "CN_TES"
                 Help(" ",1,"CPOTES")
                 lRet := .F.
                 Exit
              Endif
            Else
               If Trim(aHeader[nx][2]) == "CN_QUANT"
                  If GetMv("MV_ESTNEG")<>"S"
                     nPosDep  := Ascan(aDeps,{|x| X[1]==aCols[nC][nPosLocal]+aCols[nC][nPosProd]})
                     If nPosDep > 0
                        aDeps[nPosDep][2] := aDeps[nPosDep][2] + aCols[nC][nX]
                     Else
                        Aadd(aDeps,{aCols[nC][nPosProd]+aCols[nC][nPosLocal],aCols[nC][nX]})
                     Endif
                  Endif
               Endif
           EndIf
           If Empty(aCols[nC][nx])
              If Trim(aHeader[nx][2]) == "CN_LOTECTL"
                 If ( _cRastro == "S" .And. _cRastroProd == "S" )
                    Help(" ",1,"CPOLOTE")
                    lRet := .F.
                    Exit
                 Endif
              EndIf
           Else
              If Trim(aHeader[nx][2]) == "CN_LOTECTL"
                 If ( _cRastro == "N" .Or. _cRastroProd == "N" )
                    Help(" ",1,"NAORASTRO")
                    lRet := .F.
                    Exit
                 Endif
              EndIf
           EndIf
       Next nx
    EndIf
Next nC
DbSelectArea("SB2")
DbSetOrder(1)
For nK   := 1 To Len(aDeps)
   DbSeek(xFilial("SB2")+aDeps[nK][1])
   If !FOUND()
      Help(" ",1,'NoDep '+aDeps[nK][1])
      lRet  := .F.
      Exit
   Else
      If aDeps[nK][2] > SB2->B2_QATU
         Help(" ",1,'NoStck '+aDeps[nK][1])
         lRet  := .F.
         Exit
      Endif
   Endif
Next

Return( lRet )



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦GrpDep    ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.11.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Objeto para entrada de dados (Grupo de depositos) SX5 Tab.74¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function GrpDep()        
Local nre:=0
SetPrvt("CALIAS,CTABELA,AHEADER,NUSADO,NCOLDESC,NCOLCHAV")
SetPrvt("NCNT,ACOLS,LDEPOK,NLINDUP,ADEPSINI,LOK")
SetPrvt("LGRAVA,NREGISTRO,NRE,NPESQ,LRET")
SetPrvt("ANEWDEPS,ADEPS,NY,NDEP,CDEPTRAB,")

cAlias := "SX5"
dbSelectArea( cAlias )
cTabela := "74"
DbSeek(xFilial()+cTabela)
If !Found()
   Help(" ",1,"NOSX5_74",,"GRPDEP",1,30)
   Return
Endif

aHeader := {}
dbSelectArea("SX2")
dBSeek( cAlias)
dBSelectArea("SX3")
dbSeek( cAlias)
nUsado := 0
nColDesc := 2
nColChav := 1
SX3->(DbSetorder(2))
SX3->(DbSeek("X5_CHAVE"))
If SX3->(FOUND())
   AADD(aHeader,{OemToAnsi(STR0045), X3_CAMPO, X3_PICTURE,;  //"Grupo"
                  X3_TAMANHO, X3_DECIMAL, X3_VALID,;
                  X3_USADO, X3_TIPO, X3_ARQUIVO } )
Else
   Return .F.
EndIf
SX3->(DbSeek("X5DESCRI()"))
If SX3->(FOUND())
   AADD(aHeader,{OemToAnsi(STR0046), X3_CAMPO, X3_PICTURE,;  //"Dep¢sitos"
                  X3_TAMANHO, X3_DECIMAL, X3_VALID,;
                  X3_USADO, X3_TIPO, X3_ARQUIVO } )
Else
   Return .F.
Endif

dbSelectArea( cAlias )
dbSeek( xFilial()+cTabela)
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == xFilial()+cTabela
   nCnt := nCnt+1
   dbSkip()
EndDo
If nCnt	==	0
	nCnt	:=	1
Endif
aCOLS := Array(nCnt,3)
dbSelectArea( cAlias )
dbSeek( xFilial()+cTabela)
nCnt   := 0
lDepOk := .t.
nLinDup := 0
If Found()
   While !EOF() .And. X5_FILIAL+X5_TABELA == xFilial()+cTabela
      nCnt := nCnt+1
      aCOLS[nCnt][1] := SX5->X5_CHAVE
      aCOLS[nCnt][2] := X5DESCRI()
      aCOLS[nCnt][3] := .f. //Flag de Delecao
      dbSelectArea( cAlias )
      dbSkip()
   EndDo
   DepDup()
   If !lDepOK
      Help(" ",1,"DEPDUPSX5_74",,"GRPDEP",1,30)
      Return 
   EndIf
EndIf
If nCnt  == 0
   aCOLS[1][1] := Space(4)
   aCOLS[1][2] := Space(40)
   aCOLS[1][3] := .f. //Flag de Delecao
Endif

aDepsIni := aClone( aDeps)
dbSelectArea( cAlias )
lOk := .F.
lGrava := .f.
dbSeek( xFilial()+cTabela)
nRegistro := RecNo( )
dbSelectArea( "SX5" )
dbSeek( xFilial() + "00" + cTabela )
dbGoTo( nRegistro )

While !lOk

   @ 200,1 TO 400,380 DIALOG oDlg3 TITLE OemToAnsi(STR0047) //"Grupo de dep¢sitos"
   @ 6,5 TO 93,150 MULTILINE MODIFY DELETE VALID A462TLinOk() FREEZE 1 
   @ 80,160 BMPBUTTON TYPE 1 ACTION TudoOk() 
   @ 60,160 BMPBUTTON TYPE 2 ACTION dCancel() 
   ACTIVATE DIALOG oDlg3 CENTERED

   If lOk
      DepDup()
      If !lDepOK
         Help(" ",1,"DEPDUPSX5_74",,"GRPDEP",1,30)
         lOk := .f.  // nao sai
         n := nLinDup
         Loop
      Else
         lGrava := .t. // sai e grava
      EndIf
   Else
      lOk := .t. // sai, mas nao grava
   EndIf
End

//+--------------------------------------------------------------+
//¦ Grava no SX5                                                 ¦
//+--------------------------------------------------------------+
If lGrava
   For nRe := 1 To Len(aCols)
      If !Empty(aCols[nRe,nColChav]) .AND. !Empty(aCols[nRe,nColDesc])
         If !dbSeek( xFilial()+cTabela+aCols[nRe][nColChav]) .and.;
            !aCols[nRe][Len(aCols[nRe])]
            RecLock("SX5", .T.)
            Replace X5_FILIAL With xFilial("SX5"),;
                    X5_TABELA With cTabela,;
                    X5_CHAVE  With aCols[nRe][nColChav] ,;
                    X5_DESCRI With aCols[nRe][nColDesc] ,;
                    X5_DESCSPA With aCols[nRe][nColDesc] ,;
                    X5_DESCENG With aCols[nRe][nColDesc] 
            MsUnLock()
         ElseIf !aCols[nRe][Len(aCols[nRe])]
            RecLock("SX5", .F.)
            Replace X5_DESCRI With aCols[nRe][nColDesc]
            Replace X5_DESCSPA With aCols[nRe][nColDesc]
            Replace X5_DESCENG With aCols[nRe][nColDesc]
            MsUnLock()
         Else
            RecLock("SX5", .F.)
            DbDelete()
            MsUnLock()
         EndIf
      EndIf
   Next nRe
   //+--------------------------------------------------------------+
   //¦ Verifica se nao foi alterada nenhuma chave                   ¦
   //+--------------------------------------------------------------+
   dbSelectArea( cAlias )
   DbSeek( xFilial()+cTabela)
   While !EOF() .And. X5_FILIAL+X5_TABELA == xFilial()+cTabela
       nPesq := aScan( aCols, {|aChav| Alltrim(aChav[1])==Alltrim(X5_CHAVE) })
       If nPesq==0
          RecLock("SX5", .F.)
          DbDelete()
          MsUnLock()
       EndIf
       dbSkip()
   End

EndIf

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦LineOk    ¦ Autor ¦ Ary Medeiros          ¦ Data ¦ 15.02.96 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Validacao da linha digitada na funcao MultiLine             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦


¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Function A462TLinOk()
lRet := .T.
lDepOk := .T.
aNewDeps := {}
If !aCols[n][Len(aHeader)+1]
   If Empty(aCols[n,nColChav])
      Help(" ",1,"CLAVEVACIA")
      lRet:=.F.
   ElseIf Empty( aCols[n,nColDesc])
      Help(" ",1,"DEPVACIO")
      lRet:=.F.
   Else
      DepDup()
      If !lDepOk
         Help(" ",1,"DEPDUP")
         lRet := .F.
      EndIf
   EndIf
EndIf
Return lRet


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦DepDup    ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.11.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Verifica duplicidade de depositos                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function DepDup()
Local ny:=0
lDepOk := .T.
aDeps  := {}
nLinDup := 0
For ny := 1 to Len( aCols)
    nDep   := 1
    cDepTrab := Alltrim( Extrae( aCols[ny][nColDesc],nDep,","))
    While !Empty( cDepTrab)
       nPesq := aScan( aDeps, {|x| Alltrim(x)==cDepTrab })
       If nPesq >0
          lDepOk := .F.
          nLinDup := ny
       Else
          Aadd( aDeps, cDepTrab)
       EndIf
       nDep := nDep + 1
       cDepTrab := Alltrim( Extrae( aCols[ny][nColDesc],nDep,","))
    EndDo
Next ny
Return lDepOk


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦TudoOk    ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.11.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Confirmacao dos dados                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function TudoOk()
lOk := .t.
Close(oDlg3)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦Cancel    ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.11.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Cancelar alteracoes                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function dCancel()
lOk := .f.
Close(oDlg3)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a462TPesqui ºAutor  ³Ivan PC           º Data ³  02/19/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para pesquisa...                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A462TPesqui()
Local nOrder := IndexOrd()
AxPesqui()
DbSetOrder( nOrder )
Return
