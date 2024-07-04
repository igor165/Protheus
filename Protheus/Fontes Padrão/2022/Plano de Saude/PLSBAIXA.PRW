#INCLUDE "Plsbaixa.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSBAIXAЁ Autor Ё Tulio Cesar            Ё Data Ё 17.11.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Rotina de Baixa de Titulos Generica...                     Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSBAIXA                                                   Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus 5.07                                     Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial.                              Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSBAIXA()
Local nInt
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina 	:= 	MenuDef()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Titulo...                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLBX01")
   cCadastro := ExecBlock("PLBX01",.F.,.F.)
Else   
   cCadastro := STR0003 //"Recebimentos de Titulos no Caixa"
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define ordem default...                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF ExistBlock("PLBX02")
   nOrdem := ExecBlock("PLBX02",.F.,.F.)
Else   
   nOrdem := 1
Endif  
SA1->(DbSetOrder(nOrdem))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Filtro...                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltro := "A1_FILIAL = '"+xFilial("SA1")+"'"

If ExistBlock("PLBX03")
   cFiltro += cFiltro + " .And. "+ExecBlock("PLBX03",.F.,.F.)
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Condicao Vermelha ou Verde...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! ExistBlock("PLBX04")
   cCondCor := ""
Else
   cCondCor := ExecBlock("PLBX04",.F.,.F.)
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta mBrowse...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SA1->(DbSetFilter( {|| &cFiltro },  cFiltro ))
SA1->(dbGoTop())
SA1->(mBrowse(06,01,22,75,"SA1",,If(Empty(cCondCor),Nil,cCondFor)  ,20,,,,,, .T. ))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera Filtro...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SA1->(DbClearFilter())
SA1->(RetIndex("SA1"))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return Nil
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLBAIMOV Ё Autor Ё Tulio                 Ё Data Ё 17.11.00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Baixa de varios titulos ao mesmo tempo.                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLBAIMOV(cAlias,nReg,nOpc)                                 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLBAIMOV(cAlias,nReg,nOpc)
Local I__f := 0
Local nInd
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Uso na enchoice...                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nOpca := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Folder's...                                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oFolder 
PRIVATE oDlgFolder                                                         
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados da Enchoice...                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aCampos := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё GetDados de toda a movimentacao financeira...                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oBrwFin
PRIVATE aCabFin   := {}
PRIVATE aDadFin   := {}
PRIVATE aTrbFin   := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё GetDados das Parcelas em Aberto...                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oBrwAbe
PRIVATE aCabAbe   := {}
PRIVATE aDadAbe   := {}
PRIVATE aTrbAbe   := {}

PRIVATE nJuros    := 0
PRIVATE nValor    := 0
PRIVATE nTotal    := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Genericos...                                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nOpcx	    := nOpc                                              
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aDadosRef  := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta campos usados exibidos do cliente...                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLBX05")
   aCampos := ExecBlock("PLBX05",.F.,.F.)
Else
   aCampos := {}
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Dialogo...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM 008.2,010.3 TO 035,100.3 OF GetWndDefault()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Folder Principal...                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 030,003 FOLDER oFolder SIZE 348,151 OF oDlgFolder PIXEL	PROMPTS	STR0004,STR0005,STR0006 //"Dados do Cliente"###"Historico Financeiro"###"Parcelas em Aberto"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ENCHOICE (SA1)                                                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpcx == K_Incluir
   Copy "SA1" TO Memory Blank
Else
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Copia o contrato atual para a memoria...                            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   Copy "SA1" TO Memory
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё MSMGET -> CONTRATO                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAlias:="SA1";nReg:=SA1->(RecNo());oEncSA1 := MSMGet():New(cAlias,nReg,nOpcx,,,,If(Empty(aCampos),Nil,aCampos),{005,005,131,339},aCampos,,,,,oFolder:aDialogs[1],,,.F.)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё HISTORICO FINANCIERO                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLBX06")
   cCampos := ExecBlock("PLBX06",.F.,.F.)
   Store Header "SE1" TO aCabFin For SX3->X3_ORDEM >= "02" .And. SX3->X3_CAMPO $ cCampos
Else
   Store Header "SE1" TO aCabFin For SX3->X3_ORDEM >= "02"
Endif   
SX3->(DbSetOrder(2))
SX3->(DbSeek("E1_SALDO  "))
AaDd(aCabFin,{trim(X3TITULO()),SX3->X3_CAMPO,;
     SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
     SX3->X3_TIPO,nil,SX3->X3_CONTEXT})

If nOpcx == K_Incluir
   Store COLS Blank "SE1" TO aDadFin FROM aCabFin
Else
   SE1->(DbSetOrder(2))
   If ! SE1->(DbSeek(xFilial("SE1")+SA1->A1_COD))
      Store COLS Blank "SE1" TO aDadFin FROM aCabFin
   Else
      Store COLS "SE1" TO aDadFin FROM aCabFin VETTRAB aTrbFin While xFilial("SE1") == SE1->E1_FILIAL .And. SA1->A1_COD == SE1->E1_CLIENTE
   Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё PARCELAS EM ABERTO...                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLBX06")
   cCampos := ExecBlock("PLBX06",.F.,.F.)
   Store Header "SE1" TO aCabAbe For SX3->X3_ORDEM >= "02" .And. SX3->X3_CAMPO $ cCampos
Else
   Store Header "SE1" TO aCabAbe For SX3->X3_ORDEM >= "02" 
Endif   
SX3->(DbSetOrder(2))
SX3->(DbSeek("E1_SALDO  "))
AaDd(aCabAbe,{trim(X3TITULO()),SX3->X3_CAMPO,;
        SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
        SX3->X3_TIPO,nil,SX3->X3_CONTEXT})

If nOpcx == K_Incluir
   Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
Else
   SE1->(DbSetOrder(2))
   If ! SE1->(DbSeek(xFilial("SE1")+SA1->A1_COD))
      Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
   Else
      Store COLS "SE1" TO aDadAbe FROM aCabAbe VETTRAB aTrbAbe While xFilial("SE1") == SE1->E1_FILIAL .And. SA1->A1_COD == SE1->E1_CLIENTE For SE1->E1_SALDO > 0 .And. !Empty(SE1->E1_PLNUCOB)

      nInd := 1
      For nInd := 1 To Len(aDadAbe)        
          nPos  := PLRETPOS("E1_VENCREA",aCabAbe)
          dVenc := aDadAbe[nInd,nPos]

          If ! (dtos(dVenc) >= dtos(dDataBase))
             aDadAbe[nInd,Len(aCabAbe)+1] := .T.
          Endif   
      Next
      
      If Empty(aDadAbe)
         Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
      Endif
   Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё LABELS TOTALIZADORES...                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 172, 010 SAY STR0007 SIZE 060,010 OF oDlgFolder PIXEL  //"VALOR"
@ 172, 130 SAY STR0008 SIZE 060,010 OF oDlgFolder PIXEL  //"JUROS"
@ 172, 240 SAY STR0009 SIZE 060,010 OF oDlgFolder PIXEL  //"TOTAL"

@ 182, 010 MSGET oValor VAR nValor SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
@ 182, 130 MSGET oJuros VAR nJuros SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
@ 182, 240 MSGET oTotal VAR nTotal SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё PARCELAS EM ABERTO...                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oBrwAbe := TPLSBrw():New(015,005,335,115,nil,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabAbe,aDadAbe,.F.,"SE1",K_Visualizar,STR0006,nil,nil,.T.,"PLBMARK(oBrwAbe)") //"Parcelas em Aberto"

lCheck := .F.

@ 003, 005 CHECKBOX oCheck VAR lCheck PROMPT STR0010 OF oFolder:aDialogs[3] SIZE 050,010 PIXEL //"Marca/Desmarca Todos"
oCheck:bChange := {|| PLMARKALL(lCheck,oBrwAbe) }
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё HISTORICO FINANCEIRO...                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oBrwFin := TPLSBrw():New(005,005,335,125,nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin,aDadFin,.T.,"SE1",K_Visualizar,STR0011,{{"E1_SALDO","<=",0}}) //"Movimentacao Financeira"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de Entrada. Botoes na enchoicebar...                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLBX07")
   aButtons := ExecBlock("PLBX07",.F.,.F.)
Else
   aButtons := {}
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa Dialog                                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgFolder ON INIT Eval( {|| EnchoiceBar(oDlgFolder,{|| nOpca := 1, oDlgFolder:End() },{|| nOpca :=2 , oDlgFolder:End() },K_MsgDel,aButtons), PLBMARK(oBrwAbe) } )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da Rotina de Gravacao dos Dados...                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If 	nOpca == K_OK
   
      nOrdA1 := SA1->(IndexOrd())
      nOrdE1 := SE1->(IndexOrd())
      
      For nInd := 1 To Len(oBrwAbe:aCols)                 
          If oBrwAbe:aCols[nInd,Len(oBrwAbe:aHeader)+1]
             nCol01    := PLRETPOS("E1_PREFIXO",oBrwAbe:aHeader)
             cPrefixo  := oBrwAbe:aCols[nInd,nCol01]
             nCol02    := PLRETPOS("E1_NUMERO",oBrwAbe:aHeader)
             cNumero   := oBrwAbe:aCols[nInd,nCol02]
             nCol03    := PLRETPOS("E1_PARCELA",oBrwAbe:aHeader)
             cParcela  := oBrwAbe:aCols[nInd,nCol03]
      
             PLBXE1(cPrefixo,cNumero,cParcela)
          Endif
      Next

     SA1->(DbSetOrder(nOrdA1))
     SE1->(DbSetOrder(nOrdE1))
     
     If ExistBlock("PLBX08")
        ExecBlock("PLBX08",.F.,.F.)
     Endif   
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal de Movimentacao                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLBMARK  Ё Autor Ё Tulio                 Ё Data Ё 17.11.00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Totaliza dados.                                            Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLBMARK(oBrowse)
Local nInd

nInd   := 0           
nValor := 0
nTotal := 0      
nJuros := 0

For nInd   := 1 To Len(oBrowse:aCols)

    If oBrowse:aCols[nInd,Len(oBrowse:aHeader)+1]

       nCol   := PLRETPOS("E1_SALDO",oBrowse:aHeader)
       nValor := nValor + oBrowse:aCols[nInd,nCol]
       
       nPos  := PLRETPOS("E1_VENCTO",aCabAbe)
       dVenc := aDadAbe[nInd,nPos]
       If ! (dtos(dVenc) >= dtos(dDataBase))
          nPos   := PLRETPOS("E1_VENCTO",oBrowse:aHeader)
          nDias  := dDataBase-oBrowse:aCols[nInd,nPos]   
          nPos   := PLRETPOS("E1_VALJUR",oBrowse:aHeader)
          
          If oBrowse:aCols[nInd,nPos] > 0
             nJuros += (oBrowse:aCols[nInd,nPos]*nDias)
          Else
             nPos   := PLRETPOS("E1_PORCJUR",oBrowse:aHeader)
             
             If oBrowse:aCols[nInd,nCol] > 0
                nAuxJur:= ((oBrowse:aCols[nInd,nCol]*oBrowse:aCols[nInd,nPos])*nDias)/100
                nJuros += nAuxJur 
             Endif   
          Endif   
       Endif   

       nTotal := nValor+nJuros
    Endif   

Next

oBrowse:Atualiza()

oValor:Refresh()       
oJuros:Refresh()                     
oTotal:Refresh()

Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLBXE1   Ё Autor Ё Tulio                 Ё Data Ё 17.11.00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Baixa um titulo.                                           Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLBXE1(cPrefixo,cNumero,cParcela)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dados para manter conpatibilidade com Financeiro...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oFontLbl ; DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
PRIVATE nTotAGer   := 0
PRIVATE nTotADesc  := 0
PRIVATE nTotAMul   := 0
PRIVATE nTotAJur   := 0
PRIVATE nTotADesp  := 0
PRIVATE cLoteFin   := Space (4 )
PRIVATE cMarca     := GetMark()
PRIVATE cOld       := cCadastro
PRIVATE aCampos    := {}   
PRIVATE cLote      := ""      
PRIVATE aCaixaFin  := xCxFina()
PRIVATE lF070Auto  := .F.
PRIVATE lFini055   := IsInCallStack("FINI055")
PRIVATE lValidou   := .F. //	Incluido para nЦo dar erro no FINA070

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca parametros da rotina do financeiro...                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte("FIN070",.F.)

SE1->(DbSetOrder(1))
If ! SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela))
   Help("",1,"PLBXE1")
Else
   FA070Tit("SE1",0,SE1->(Recno()))
Endif       
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLMARKALLЁ Autor Ё Tulio                 Ё Data Ё 06.12.00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Marca/Descmarca todos os registros...                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLMARKALL(lCheck,oBrowse)
LOCAL nInd

For nInd := 1 To Len(oBrowse:aCols)
    oBrowse:aCols[nInd,Len(oBrowse:aHeader)+1] := If(lCheck,.T.,.F.)
Next                                            

oBrowse:Atualiza()


Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё08/01/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё		1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Local nInt
Private aRotina := {	{ STR0001	,'AxPesqui' , 0 ,K_Pesquisar , 0, .F.},; //"Pesquisar"
						{ STR0002	,'PLBAIMOV' , 0 ,K_Visualizar, 0, Nil} } //"Consultar"
If ExistBlock("PLBX09")
   aVets := ExecBlock("PLBX09",.F.,.F.)
   nInt  := 0
   For nInt := 1 To Len(aVets)
       aadd(aRotina,aVets[nInt])
   Next    
Endif                              
Return(aRotina)