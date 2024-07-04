#INCLUDE "HSPAHR95.ch"
#include "Protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR95 º Autor ³ MARCELO JOSE       º Data ³22/06/05     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Solicitações                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR95()
 Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local cTitulo := STR0003 //"Relação de Solicitações"
 Local nLin    := 80
 Local cCabec1 := ""
 Local cCabec2 := ""
 Local imprime := .T.
 Local aOrd    := {}
 Local nLinTotal := 60
 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR95"
 Private nTipo        := 15
 Private aReturn      := {STR0004, 1, STR0005, 1, 1, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHR95"
 Private cString      := ""
 Private aRegistros   := {}

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 
 cPerg := "HSPR95"
 If !Pergunte(cPerg,.T.)
  return
 EndIf          

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
           
 cCabec1 := STR0014 //"Data      Solicitação  Produto Solicitado                          Qtd.Solic.   Qtd.Ate.Farm  "

 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPREL º Autor ³ MARCELO JOSE       º Data ³22/06/05     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local cSolici 	:= ""

 DbSelectArea("GAI")
 DbSetOrder(2)
 If !Empty(MV_PAR01)
  DbSeek(xFilial("GAI") + MV_PAR01, .T.)
 EndIf 
 While !Eof() .And. GAI->GAI_FILIAL == xFilial("GAI") .And. GAI->GAI_REGATE >= MV_par01 .and. GAI->GAI_REGATE <= MV_par02

  If nLin > nMaxLin
   Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
   nLin := 10
  Endif                    

  cSolici := GAI->GAI_SOLICI
  @ nlin,00 Psay STR0007 + GAI->GAI_REGATE + " - " + Posicione("GCY", 01, xFilial("GCY") + GAI->GAI_REGATE, "GCY_NOME") //"Registro: "
  nLin = nLin + 2
  
  DBSelectArea("GAJ")
  DbSetOrder(1)
  DbSeek(xFilial("GAJ") + cSolici )
  While !Eof() .And. xFilial("GAJ") == GAJ->GAJ_FILIAL .And. GAJ->GAJ_SOLICI == cSolici
   @ nlin, 00 Psay DTOC(GAI->GAI_DATSOL)
   @ nlin, 10 Psay GAJ->GAJ_SOLICI
   @ nlin, 23 Psay SUBSTR(POSICIONE("SB1",1,xFilial("SB1") + GAJ->GAJ_PROSOL, "B1_DESC"),1,40)
   @ nlin, 66 Psay Transform(GAJ->GAJ_QTDSOL, "@E 99,999.9999")
   @ nlin, 81 Psay Transform(GAJ->GAJ_QTDATE, "@E 99,999.9999")
   nlin++
   If nLin > nMaxLin
    Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
    nLin := 10
   Endif                    
   dbSkip()
  Enddo
  
  nlin++ 
  DbSelectArea("GAI")
  DbSetOrder(2)
  dbSkip()
  
 Enddo

 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)