#INCLUDE "Eicpo112.ch"
//Funcao:     EICPO112  
//Autor:      AVERAGE/Regina        
//Data:       12.08.99 
//Descricao:  Emissao do Pedido Cancelado                       
//Sintaxe:    #EICPO112                                         
//Uso:        Protheus v507 e v508 (Alex Wallauer 04 de Setembro de 2000)

#include 'avprint.ch'
//#include 'font.ch'
#include "Average.ch"
#include 'rwmake.ch'
#DEFINE INGLES                     1
#DEFINE PORTUGUES                  2
#define DLG_CHARPIX_H   15.1
#define DLG_CHARPIX_W    7.9
#DEFINE LITERAL_PEDIDO             IF( nIdioma == INGLES, "CANCELLED PURCHASE ORDER #: ", STR0001 ) //"NR. PEDIDO CANCELADO : "
#DEFINE LITERAL_ALTERACAO          IF( nIdioma == INGLES, "ALTERATION Number: ", STR0002 ) //"ALTERAÇÃO Número: "
#DEFINE LITERAL_CANCELAMENTO       IF( nIdioma == INGLES, "CANCEL DATE: "      , STR0003 ) //"Data Cancelamento: "
#DEFINE LITERAL_DATA               IF( nIdioma == INGLES, "Date: "             , STR0004 ) //"Data: "
#DEFINE LITERAL_PAGINA             IF( nIdioma == INGLES, "Page: "             , STR0005 ) //"Página: "
#DEFINE LITERAL_FORNECEDOR         IF( nIdioma == INGLES, "SUPPLIER........: " , STR0006 ) //"FORNECEDOR......: "
#DEFINE LITERAL_ENDERECO           IF( nIdioma == INGLES, "ADDRESS.........: " , STR0007 ) //"ENDEREÇO........: "
#DEFINE LITERAL_REPRESENTANTE      IF( nIdioma == INGLES, "REPRESENTATIVE..: " , STR0008 ) //"REPRESENTANTE...: "
#DEFINE LITERAL_REPR_TEL           IF( nIdioma == INGLES, "TEL.: "             , STR0009 ) //"FONE: "
#DEFINE LITERAL_COMISSAO           IF( nIdioma == INGLES, "COMMISSION......: " , STR0010 ) //"COMISSÃO........: "
#DEFINE LITERAL_CONTATO            IF( nIdioma == INGLES, "CONTACT.........: " , STR0011 ) //"CONTATO.........: "
#DEFINE LITERAL_IMPORTADOR         IF( nIdioma == INGLES, "IMPORTER........: " , STR0012 ) //"IMPORTADOR......: "
#DEFINE LITERAL_CONDICAO_PAGAMENTO IF( nIdioma == INGLES, "TERMS OF PAYMENT: " , STR0013 ) //"COND. PAGAMENTO.: "
#DEFINE LITERAL_VIA_TRANSPORTE     IF( nIdioma == INGLES, "MODE OF DELIVERY: " , STR0014 ) //"VIA TRANSPORTE..: "
#DEFINE LITERAL_DESTINO            IF( nIdioma == INGLES, "DESTINATION.....: " , STR0015 ) //"DESTINO.........: "
#DEFINE LITERAL_AGENTE             IF( nIdioma == INGLES, "FORWARDER.......: " , STR0016 ) //"AGENTE..........: "
#DEFINE LITERAL_QUANTIDADE         IF( nIdioma == INGLES, "Quantity"           , STR0017 ) //"Quantidade"
#DEFINE LITERAL_DESCRICAO          IF( nIdioma == INGLES, "Description"        , STR0018 ) //"Descrição"
#DEFINE LITERAL_FABRICANTE         IF( nIdioma == INGLES, "Manufacturer"       , STR0019 ) //"Fabricante"
#DEFINE LITERAL_PRECO_UNITARIO1    IF( nIdioma == INGLES, STR0020              , STR0021 ) //"Unit"###"Preço"
#DEFINE LITERAL_PRECO_UNITARIO2    IF( nIdioma == INGLES, "Price"              , STR0022 ) //"Unitário"
#DEFINE LITERAL_TOTAL_MOEDA        IF( nIdioma == INGLES, "Amount"             , STR0023 ) //"   Total"
#DEFINE LITERAL_DATA_PREVISTA1     IF( nIdioma == INGLES, "Req. Ship"          , STR0024 ) //"Data Prev."
#DEFINE LITERAL_DATA_PREVISTA2     IF( nIdioma == INGLES, "Date"               , STR0025 ) //"Embarque"
#DEFINE LITERAL_OBSERVACOES        IF( nIdioma == INGLES, "REMARKS"            , STR0026 ) //"OBSERVAÇÕES"
#DEFINE LITERAL_INLAND_CHARGES     IF( nIdioma == INGLES, "INLAND CHARGES"     , STR0027 ) //"Despesas Internas"
#DEFINE LITERAL_PACKING_CHARGES    IF( nIdioma == INGLES, "PACKING CHARGES"    , STR0028 ) //"Despesas Embalagem"
#DEFINE LITERAL_INTL_FREIGHT       IF( nIdioma == INGLES, "INT'L FREIGHT"      , STR0029 ) //"Frete Internacional"
#DEFINE LITERAL_DISCOUNT           IF( nIdioma == INGLES, "DISCOUNT"           , STR0030 ) //"Desconto"

*-----------------------------*
Function Eicpo112()
*-----------------------------*
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
nCont := 0; nTotal:=0; nTotalGeral:=0; nIdioma:=INGLES

cCadastro := STR0031 //"Sele‡Æo de Purchase Order"
nPagina:=0

oDlgIdioma := nVolta := oRadio1 := Nil
lEnd := nil
DBSELECTAREA("EI4")
IF EI4->(EOF()) .AND. EI4->(BOF())
   Help(" ",1,"E_NAOHAITE")
   RETURN .F.
ENDIF
@ (9*DLG_CHARPIX_H),(10*DLG_CHARPIX_W) TO (17*DLG_CHARPIX_H),(42*DLG_CHARPIX_W) DIALOG oDlgIdioma TITLE STR0032 //"Seleção"

@  8,10 TO 48,80 TITLE STR0033 //"Selecione o Idioma"

nVolta:=0

oRadio1 := oSend( TRadMenu(), 'NEW', 18, 13, {STR0034,STR0035},{|u| If(PCount() == 0, nIdioma, nIdioma := u)}, oDlgIdioma,,,,,, .F.,, 55, 13,, .F., .T., .T. ) //"Inglês"###"Português"

oSend( SButton(), 'NEW', 10, 90,1, {|| nVolta:=1, oSend(oDlgIdioma, 'End')}, oDlgIdioma, .T.,,)
oSend( SButton(), 'NEW', 37, 90,2, {|| oSend(oDlgIdioma,'End')}, oDlgIdioma, .T.,,)

ACTIVATE DIALOG oDlgIdioma CENTERED
DBSELECTAREA('EI4')
IF nVolta == 1
   PO112Report()
Endif

Return(NIL)

*-----------------------------------*
Static FUNCTION PO112Report()
*-----------------------------------*
#xtranslate :TIMES_NEW_ROMAN_18_NEGRITO    => \[1\]
#xtranslate :TIMES_NEW_ROMAN_12            => \[2\]
#xtranslate :TIMES_NEW_ROMAN_12_NEGRITO    => \[3\]
#xtranslate :COURIER_08_NEGRITO            => \[4\]
#xtranslate :TIMES_NEW_ROMAN_08_NEGRITO    => \[5\]
#xtranslate :COURIER_12_NEGRITO            => \[6\]
#xtranslate :COURIER_20_NEGRITO            => \[7\]
#xtranslate :TIMES_NEW_ROMAN_10_NEGRITO    => \[8\]
#xtranslate :TIMES_NEW_ROMAN_08_UNDERLINE  => \[9\]
#xtranslate :COURIER_NEW_10_NEGRITO        => \[10\]

#COMMAND    TRACO_NORMAL                   => oSend(oPrn,'LINE', Linha  ,  50, Linha  , 2300 ) ;
                                           ;  oSend(oPrn,'LINE', Linha+1,  50, Linha+1, 2300 )

#COMMAND    TRACO_REDUZIDO                 => oSend(oPrn,'LINE', Linha  ,1200, Linha  , 2300 ) ;
                                           ;  oSend(oPrn,'LINE', Linha+1,1200, Linha+1, 2300 )

#COMMAND    ENCERRA_PAGINA                 => oSend(oPrn,'OFONT',aFontes:COURIER_20_NEGRITO) ;
                                           ;  TRACO_NORMAL


#COMMAND    COMECA_PAGINA                  => AVNEWPAGE                                ;
                                           ;  Linha := 180                             ;
                                           ;  nPagina := nPagina+ 1                    ;
                                           ;  pTipo := 2                               ;
                                           ;  PO112Cabec()                      ;
                                           ;  PO112Cab_Itens()


#xTranslate  DATA_MES(<x>) =>              SUBSTR(DTOC(<x>)  ,1,2)+ " " + ;
                                           SUBSTR(CMONTH(<x>),1,3)+ " " + ;
                                           SUBSTR(DTOC(<x>)  ,7,10)//2)       // GFP - 02/04/2012 - Ajuste da data no relatorio.


cIndex := cCond := nIndex := Nil; nMarcados:=0; nOldArea:=ALIAS()
oFont1:=oFont2:=oFont3:=oFont4:=oFont5:=oFont6:=oFont7:=oFont8:=oFont9:=Nil
oPrn:= Linha:= aFontes:= Nil; cCliComp:=''
aCampos:={}; cNomArq:=Nil; aHeader:={}
aMarcados:={}

cPictQtde:='@E 999,999,999.999'; cPict1Total:='@E 999,999,999,999.99999'
cPict2Total:='@E 99,999,999,999,999.99999'

dbSelectArea('EI4')

AVPRINT oPrn NAME STR0036 //"Emissão do Pedido"
      //                              Font            W  H  Bold          Device
oFont1 := oSend(TFont(),'NEW','Times New Roman',0,18,,.T.,,,,,,,,,,,oPrn )
oFont2 := oSend(TFont(),'NEW','Times New Roman',0,12,,.F.,,,,,,,,,,,oPrn )
oFont3 := oSend(TFont(),'NEW','Times New Roman',0,12,,.T.,,,,,,,,,,,oPrn )
oFont4 := oSend(TFont(),'NEW','Courier New'    ,0,10,,.T.,,,,,,,,,,,oPrn )
oFont5 := oSend(TFont(),'NEW','Times New Roman',0,08,,.T.,,,,,,,,,,,oPrn )
oFont6 := oSend(TFont(),'NEW','Courier New'    ,0,12,,.T.,,,,,,,,,,,oPrn )
oFont7 := oSend(TFont(),'NEW','Courier New'    ,0,26,,.T.,,,,,,,,,,,oPrn )
oFont8 := oSend(TFont(),'NEW','Times New Roman',0,10,,.T.,,,,,,,,,,,oPrn )
      //                                                            Underline
oFont9 := oSend(TFont(),'NEW','Times New Roman',0,10,,.T.,,,,,.T.,,,,,,oPrn )
oFont10:= oSend(TFont(),'NEW','Courier New'    ,0,10,,.T.,,,,,,,,,,,oPrn )
aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, oFont7, oFont8, oFont9, oFont10 }

AVPAGE

Processa({|| PO112Det()},STR0037) //"Imprimindo..."

AVENDPAGE

oSend(oFont1,'End')
oSend(oFont2,'End')
oSend(oFont3,'End')
oSend(oFont4,'End')
oSend(oFont5,'End')
oSend(oFont6,'End')
oSend(oFont7,'End')
oSend(oFont8,'End')
oSend(oFont9,'End')
AVENDPRINT

dbSelectArea('EI4')


Return .T.

*-------------------------------------*
Static Function PO112Det()
*-------------------------------------*
LOCAL nCont:=0,cFil:=XFILIAL('EI5')
dbSelectArea('EI5')
EI5->(dbSetOrder(1))
EI5->(dbSeek(xFilial()+EI4->EI4_PO_NUM))
EI5->(DBEVAL({||nCont++},,{||EI5->EI5_FILIAL == cFil .AND. ;
                            EI5->EI5_PO_NUM == EI4->EI4_PO_NUM}))

ProcRegua(nCont)

   Linha := 180
   nTotal:=nTotalGeral:=0
   nPagina:=1
   nCont := 0

   pTipo := 1
   PO112Cabec()

   dbSelectArea('EI5')
   EI5->(dbSetOrder(1))
   EI5->(dbSeek(cFil+EI4->EI4_PO_NUM))

   While EI5->(!Eof())           .AND.;
         EI5->EI5_FILIAL == cFil .AND.;
         EI5->EI5_PO_NUM == EI4->EI4_PO_NUM

         IncProc(STR0038+EI5->EI5_COD_I) //"Lendo Item: "

      If EI5->EI5_SEQ #0
         EI5->(dbSkip())
         LOOP
      Endif

      If Linha >= 3000
         ENCERRA_PAGINA
         COMECA_PAGINA
      Endif

      PO112Item()

      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 5
      PO112BateTraco()

      Linha := Linha + 50

      EI5->(dbSkip())
   Enddo //loop dos itens EI5

   cCliComp:=IF(EasyGParam('MV_ID_CLI')='S',SA1->A1_NOME,SY1->Y1_NOME)
   PO112Remarks()
   PO112Totais()

   oSend(oPrn,'LINE', Linha, 50, Linha, 1200 )
   oSend(oPrn,'LINE', Linha+1, 50, Linha+1, 1200 )

   Linha := Linha + 70
   oSend(oPrn,'SAY', Linha, 50, cCliComp, aFontes:TIMES_NEW_ROMAN_12 )

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Atualiza FLAG de EMITIDO                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea('EI4')

   RecLock('EI4',.F.)
   EI4->EI4_EMITIDO := "S" //PO Impresso
   EI4->(MsUnLock())


Return nil

*----------------------------------*
Static FUNCTION PO112Cabec()
*----------------------------------*

c2EndSM0:=''; c2EndSA2:=''; cCommission:=''; c2EndSYT:=''; cTerms:=''
cDestinat:=''; cRepr:=''; cCGC:=''

IF EasyGParam('MV_ID_CLI') == 'S'
   //-----------> Cliente.
   SA1->( DBSETORDER( 1 ) )
   SA1->( DBSEEK( xFilial("SA1")+EI4->EI4_CLIENTE ) )
ELSE
   // --------->  Comprador.
   SY1->( DBSETORDER(1) )
   SY1->( DBSEEK( xFilial("SY1")+EI4->EI4_COMPRA ) )
ENDIF
//----------->  Fornecedor.
SA2->( DBSETORDER( 1 ) )
SA2->( DBSEEK( xFilial()+EI4->EI4_FORN ) )

c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_MUN   ), ALLTRIM(SA2->A2_MUN   )+' - ', '' )
c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_BAIRRO), ALLTRIM(SA2->A2_BAIRRO)+' - ', '' )
c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_ESTADO), ALLTRIM(SA2->A2_ESTADO)+' - ', '' )
c2EndSA2 := LEFT( c2EndSA2, LEN(c2EndSA2)-2 )

//-----------> Pedidos.
IF EI4->EI4_COMIS == "S"
   cCommission :=EI4->EI4_MOEDA+" "+TRANS(EI4->EI4_VAL_CO,E_TrocaVP(nIdioma,'@E 9,999,999,999.9999'))
   IF( EI4->EI4_TIP_CO == '1', cCommission:=TRANS(EI4->EI4_PER_CO,E_TrocaVP(nIdioma,'@E 999.99'))+"%", )
   IF( EI4->EI4_TIP_CO == '4', cCommission:=EI4->EI4_OUT_CO, )
ENDIF

//-----------> Importador.
SYT->( DBSETORDER( 1 ) )
SYT->( DBSEEK( xFilial()+EI4->EI4_IMPORT ) )

c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_CIDADE), ALLTRIM(SYT->YT_CIDADE)+' - ', '' )
c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_ESTADO), ALLTRIM(SYT->YT_ESTADO)+' - ', '' )
c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_PAIS  ), ALLTRIM(SYT->YT_PAIS  )+' - ', '' )
c2EndSYT := LEFT( c2EndSYT, LEN(c2EndSYT)-2 )
cCgc     := ALLTRIM(SYT->YT_CGC)

//-----------> Condicoes de Pagamento.
SY6->( DBSETORDER( 1 ) )
SY6->( DBSEEK( xFilial()+EI4->EI4_COND_P+STR(EI4->EI4_DIAS_P,3,0) ) )

SYP->( DBSETORDER( 1 ) )
SYP->( DBSEEK( xFilial()+SY6->Y6_DESC_I) )

SYP->( DBEVAL( {|| IF(!EMPTY(SYP->YP_TEXTO),cTerms:=SYP->YP_TEXTO,) },,;
               {|| xFilial('SYP')==SYP->YP_FILIAL .AND. SY6->Y6_DESC_I==SYP->YP_CHAVE  .AND.  EMPTY(cTerms)} ) )

//-----------> Portos.
//acd   SY9->( DBSETORDER( 1 ) )
SY9->( DBSETORDER( 2 ) )
SY9->( DBSEEK( xFilial()+EI4->EI4_DEST ) )

cDestinat := ALLTRIM(EI4->EI4_DEST) + " - " + ALLTRIM(SY9->Y9_DESCR)

//-----------> Agentes Embarcadores.
SY4->( DBSETORDER( 1 ) )
SY4->( DBSEEK( xFilial()+EI4->EI4_FORWAR ) )

//-----------> Agentes Embarcadores.
SYQ->( DBSEEK( xFilial()+EI4->EI4_TIPO_E ) )

//-----------> Agentes Compradores.
SY1->(DBSEEK(xFilial()+EI4->EI4_COMPRA))


oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
Linha := Linha+70

IF EasyGParam("MV_ID_EMPR") == 'S'
   oSend( oPrn, 'SAY', Linha    , 1150, ALLTRIM(SM0->M0_NOME), aFontes:TIMES_NEW_ROMAN_18_NEGRITO,,,, 2 )
   Linha:=Linha+150
   oSend( oPrn, 'SAY', Linha    , 1150, ALLTRIM(SM0->M0_ENDCOB) , aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
ELSE
   oSend( oPrn, 'SAY', Linha    , 1150, ALLTRIM(SYT->YT_NOME), aFontes:TIMES_NEW_ROMAN_18_NEGRITO,,,, 2 )
   Linha:=Linha+150
   oSend( oPrn, 'SAY', Linha    , 1150, ALLTRIM(SYT->YT_ENDE), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
ENDIF

oSend( oPrn, 'SAY', Linha:= Linha+50, 1150, ALLTRIM(c2EndSM0), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )

IF EasyGParam("MV_ID_CLI") == 'S'  // Cliente.

   IF ! EMPTY( ALLTRIM(SA1->A1_TEL) )
      oSend( oPrn, 'SAY', Linha := Linha+50, 1150, STR0039 + ALLTRIM(SA1->A1_TEL), aFontes:TIMES_NEW_ROMAN_12,,,, 2 ) //"Tel: "
   ENDIF
   IF ! EMPTY( ALLTRIM(SA1->A1_FAX) )
      oSend( oPrn, 'SAY', Linha := Linha+50, 1150, STR0040 + ALLTRIM(SA1->A1_FAX), aFontes:TIMES_NEW_ROMAN_12,,,, 2 ) //"Fax: "
   ENDIF

ELSE                         // Comprador.

   IF ! EMPTY( ALLTRIM(SY1->Y1_TEL) )
      oSend( oPrn, 'SAY', Linha := Linha+50, 1150, STR0039 + ALLTRIM(SY1->Y1_TEL), aFontes:TIMES_NEW_ROMAN_12,,,, 2 ) //"Tel: "
   ENDIF
   IF ! EMPTY( ALLTRIM(SY1->Y1_FAX) )
      oSend( oPrn, 'SAY', Linha := Linha+50, 1150, STR0040 + ALLTRIM(SY1->Y1_FAX), aFontes:TIMES_NEW_ROMAN_12,,,, 2 ) //"Fax: "
   ENDIF

ENDIF
Linha := Linha+100

oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
Linha := Linha+30

oSend( oPrn, 'SAY', Linha, 1150, LITERAL_PEDIDO + ALLTRIM(TRANS(EI4->EI4_PO_NUM,_PictPo)), aFontes:TIMES_NEW_ROMAN_12,,,,2 )
Linha := Linha+100

IF ! EMPTY(EI4->EI4_NR_ALTE)
   oSend( oPrn, 'SAY', Linha, 400 , LITERAL_ALTERACAO + STRZERO(EI4->EI4_NR_ALT,2) , aFontes:TIMES_NEW_ROMAN_12 )
   oSend( oPrn, 'SAY', Linha, 1770, LITERAL_DATA + DATA_MES( EI4->EI4_DT_ALT )     , aFontes:TIMES_NEW_ROMAN_12 )
   Linha:=Linha+100
ENDIF

oSend( oPrn, 'SAY', Linha, 400 , LITERAL_DATA + DATA_MES( DATE() )     , aFontes:TIMES_NEW_ROMAN_12 )
oSend( oPrn, 'SAY', Linha, 1770, LITERAL_PAGINA + STRZERO(nPagina,3), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+100

If pTipo == 2  // A partir da 2o. p gina.
   Return
Endif

oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO112BateTraco()
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_FORNECEDOR, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, SA2->A2_NOME + Alltrim(IF(EICLOJA(),"Loja:" + Alltrim(SA2->A2_LOJA),"")) , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_ENDERECO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, ALLTRIM(SA2->A2_END)+" "+ALLTRIM(SA2->A2_NR_END), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 630, c2EndSA2              , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 630, SA2->A2_CEP           , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

cRepr:=IF(nIdioma==INGLES,"NONE",STR0041) //"NAO HA"

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_REPRESENTANTE, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, IF(EMPTY(SA2->A2_REPRES),cRepr,SA2->A2_REPRES)       , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_ENDERECO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, SA2->A2_REPR_EN , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_COMISSAO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, cCommission     , aFontes:TIMES_NEW_ROMAN_12 )

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha,1750, LITERAL_REPR_TEL, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha,1910, ALLTRIM(IF(!EMPTY(SA2->A2_REPRES),SA2->A2_REPRTEL,SA2->A2_TEL)), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_CONTATO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, SA2->A2_CONTATO, aFontes:TIMES_NEW_ROMAN_12 )

oSend( oPrn, 'SAY',  Linha,1750, STR0042           , aFontes:COURIER_12_NEGRITO ) //"FAX.: "
oSend( oPrn, 'SAY',  Linha,1910, ALLTRIM(IF(!EMPTY(SA2->A2_REPRES),SA2->A2_REPRFAX,SA2->A2_FAX)), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO112BateTraco()

Linha := Linha+20
oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_IMPORTADOR, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, SYT->YT_NOME      , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 630, SYT->YT_ENDE       , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 630, c2EndSYT           , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

IF ! EMPTY(cCGC)
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 1
   PO112BateTraco()

   oSend( oPrn, 'SAY',  Linha, 630, STR0043 + Trans(cCGC,"@R 99.999.999/9999-99") , aFontes:TIMES_NEW_ROMAN_12 ) //"C.G.C: "
   Linha := Linha+50
ENDIF

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO112BateTraco()

Linha := Linha+20
oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO)
TRACO_NORMAL
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100 , STR0044, aFontes:COURIER_12_NEGRITO ) //"PROFORMA INVOICE: "
oSend( oPrn, 'SAY',  Linha, 630 , EI4->EI4_NR_PRO      , aFontes:TIMES_NEW_ROMAN_12 )

oSend( oPrn, 'SAY',  Linha, 1720, LITERAL_DATA            , aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 1920, DATA_MES(EI4->EI4_DT_PRO), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO112BateTraco()

Linha := Linha+20
oSend(oPrn,'OFONT',aFontes:COURIER_20_NEGRITO)
TRACO_NORMAL

oSend(oPrn,'LINE', Linha-50,   50, (Linha+150),   50 ) ; oSend(oPrn,'LINE', Linha-50,   51, (Linha+150),   51 )
oSend(oPrn,'LINE', Linha-50, 2300, (Linha+150), 2300 ) ; oSend(oPrn,'LINE', Linha-50, 2301, (Linha+150), 2301 )

Linha := Linha+50

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_CONDICAO_PAGAMENTO , aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, cTerms                     , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO112BateTraco()

Linha := Linha+20
oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )

oSend( oPrn, 'LINE',  Linha  ,  50, Linha  , 2300 )
oSend( oPrn, 'LINE',  Linha+1,  50, Linha+1, 2300 )
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, STR0045 , aFontes:COURIER_12_NEGRITO ) //"INCOTERMS.......: "
oSend( oPrn, 'SAY',  Linha, 630, ALLTRIM(EI4->EI4_INCOTE)+" "+ALLTRIM(EI4->EI4_COMPL), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

//LRS - 16/03/2015 - Pegar o tipo via Transporte de acordo com o Idioma do relatorio
SX5->(DbSetOrder(1))
SX5->(dbSeek(xFilial("SX5")+"Y3"+Alltrim(SubStr(SYQ->YQ_COD_DI,1,1)))) 

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_VIA_TRANSPORTE , aFontes:COURIER_12_NEGRITO )
If nIdioma == INGLES
	oSend( oPrn, 'SAY',  Linha, 630, SX5->X5_DESCENG        , aFontes:TIMES_NEW_ROMAN_12 )
ElseIF nIdioma == PORTUGUES
	oSend( oPrn, 'SAY',  Linha, 630, SX5->X5_DESCRI         , aFontes:TIMES_NEW_ROMAN_12 )
ElseIF nIdioma == ESPANHOL
	oSend( oPrn, 'SAY',  Linha, 630, SX5->X5_DESCSPA        , aFontes:TIMES_NEW_ROMAN_12 )
EndIF
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_DESTINO , aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, cDestinat       , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 100, LITERAL_AGENTE, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 630, SY4->Y4_NOME  , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

PO112Cab_Itens()

Return

*------------------------------------*
Static FUNCTION PO112Cab_Itens()
*------------------------------------*

Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 4
PO112BateTraco()

oSend(oPrn,'OFONT', aFontes:COURIER_20_NEGRITO)  // Define fonte padrao
TRACO_NORMAL

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 2
PO112BateTraco()

Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 4
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha,  065, STR0046                , aFontes:TIMES_NEW_ROMAN_10_NEGRITO ) //"IT"
oSend( oPrn, 'SAY',  Linha,  200, LITERAL_QUANTIDADE     , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha,  470, LITERAL_DESCRICAO      , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 1380, LITERAL_FABRICANTE     , aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )
oSend( oPrn, 'SAY',  Linha, 1470, LITERAL_PRECO_UNITARIO1, aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 1740, LITERAL_TOTAL_MOEDA    , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 2080, LITERAL_DATA_PREVISTA1 , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
Linha := Linha+50

pTipo := 5
oFnt := aFontes:COURIER_20_NEGRITO
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha,   65, STR0047                   , aFontes:TIMES_NEW_ROMAN_10_NEGRITO ) //"Nb"
oSend( oPrn, 'SAY',  Linha, 1470, LITERAL_PRECO_UNITARIO2, aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 1770, EI4->EI4_MOEDA          , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 2080, LITERAL_DATA_PREVISTA2 , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )

Linha := Linha+50

oSend(oPrn,'OFONT', aFontes:COURIER_20_NEGRITO) // Define fonte padrao

TRACO_NORMAL

RETURN NIL

*------------------------------*
Static FUNCTION PO112Item()
*------------------------------*
local i
i := n1 := n2 := nil
nNumero := 1
bAcumula := bWhile := lPulaLinha := nil
nTam := 20 //DFS - Redução do tamanho da descrição por linha para não sobrepor informações.
cDescrItem := '' //Esta variavel ‚ Private por causa do Rdmake "EICPOOLI"

//-----------> Unidade Requisitante (C.Custo).
SY3->( DBSETORDER( 1 ) )
SY3->( DBSEEK( xFilial()+EI5->EI5_CC ) )

//-----------> Fornecedores.
SA2->( DBSETORDER( 1 ) )
SA2->( DBSEEK( xFilial()+EI5->EI5_FABR ) )

//-----------> Reg. Ministerio.
SYG->( DBSETORDER( 1 ) )
SYG->( DBSEEK( xFilial()+EI4->EI4_IMPORT+EI5->EI5_FABR+EI5->EI5_COD_I ) )

//-----------> Produtos (Itens) e Textos.
SB1->( DBSETORDER( 1 ) )
SB1->( DBSEEK( xFilial()+EI5->EI5_COD_I ) )

SYP->( DBSETORDER( 1 ) )
IF nIdioma == INGLES
   SYP->( DBSEEK( xFilial()+SB1->B1_DESC_I ) )
ELSE
   SYP->( DBSEEK( xFilial()+SB1->B1_DESC_P ) )
ENDIF

bWhile   := {|| xFilial('SYP') == SYP->YP_FILIAL  .AND.  IF( nIdioma==INGLES, SB1->B1_DESC_I, SB1->B1_DESC_P ) == SYP->YP_CHAVE }
bAcumula := {|| IF( !EMPTY(SYP->YP_TEXTO), cDescrItem:=cDescrItem+ALLTRIM(SYP->YP_TEXTO)+" ",) }

SYP->( DBEVAL( bAcumula,, bWhile ) )

//-----------> Produtos X Fornecedor.
SA5->( DBSETORDER( 3 ) )
SA5->( DBSEEK( xFilial()+EI5->EI5_COD_I+EI5->EI5_FABR+EI5->EI5_FORN ) )

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO112BateTraco()

Linha := Linha + 50
oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO112BateTraco()

nCont:=nCont+1
oSend( oPrn, 'SAY',  Linha,  65, STRZERO(nCont,3),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha, 370, TRANS(EI5->EI5_QTDE,E_TrocaVP(nIdioma,cPictQtde)),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, 'SAY',  Linha, 400, BUSCA_UM(EI5->EI5_COD_I+EI5->EI5_FABR +EI5->EI5_FORN,EI5->EI5_CC+EI5->EI5_SI_NUM),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )  //SO.:0022/02 OS.: 0151/02 FCD

IF MLCOUNT(cDescrItem,nTam) == 1
   oSend( oPrn, 'SAY',  Linha, 480, MEMOLINE( cDescrItem,nTam ,1 ),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )//DFS - Alteração do tipo/tamanho de letra para não sobrepor informações
ELSE
   oSend( oPrn, 'SAY',  Linha, 480, AV_Justifica(MEMOLINE( cDescrItem,nTam ,1 )),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )//DFS - Alteração do tipo/tamanho de letra para não sobrepor informações
ENDIF

oSend( oPrn, 'SAY',  Linha,1380, LEFT(SA2->A2_NREDUZ,20),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 ) //DFS - Alteração do tamanho do nome reduzido para caber todos caracteres
oSend( oPrn, 'SAY',  Linha+40,1380/*1380*/, IF(EICLOJA(), "Loja:" + Alltrim(SA2->A2_LOJA)," "),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 ) //DFS - Inclusão de loja em outra linha para não sobrepor informações.
oSend( oPrn, 'SAY',  Linha,1640, TRANS(EI5->EI5_PRECO,E_TrocaVP(nIdioma,'@E 999,999,999.99999')),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, 'SAY',  Linha,2000, TRANS(EI5->EI5_QTDE*EI5->EI5_PRECO,E_TrocaVP(nIdioma,cPict1Total )),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, 'SAY',  Linha,2100, DATA_MES(EI5->EI5_DT_EMB),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )

nTotal := nTotal + EI5->EI5_QTDE*EI5->EI5_PRECO
Linha  := Linha + 50

// Part. Number + Part. Number Opc. + Reg. Minis. - 1o. Linha Descr. ja batida.
n1 := ( MlCount( cDescrItem, nTam ) + 1 + 2 + 1 ) - 1
n2 := 0   //acd   MLCOUNT( SUBSTR(ALLTRIM(SY3->Y3_DESC),1,LEN(SY3->Y3_DESC)-12), 12 )
n1 := IF( n1 > n2, n1, n2 )

FOR i:=2 TO n1 + 1   // Soma um para bater o ultimo.

    lPulaLinha := .F.

    IF Linha >= 3000
       ENCERRA_PAGINA
       COMECA_PAGINA

       oFnt := aFontes:COURIER_20_NEGRITO
       pTipo := 5
       PO112BateTraco()

       Linha := Linha+50
    ENDIF

    IF !EMPTY( MEMOLINE( cDescrItem,nTam, i ) )
       IF MLCOUNT(cDescrItem,nTam) == i
          oSend( oPrn, 'SAY',  Linha, 480,MEMOLINE( cDescrItem,nTam,i ), aFontes:COURIER_NEW_10_NEGRITO )
       ELSE
          oSend( oPrn, 'SAY',  Linha, 480,AV_Justifica( MEMOLINE( cDescrItem,nTam,i ) ), aFontes:COURIER_NEW_10_NEGRITO )
       ENDIF
       lPulaLinha := .T.
    ENDIF

    IF EMPTY( MEMOLINE( cDescrItem,nTam, i ) )
       IF nNumero == 1  
           If EI5->(FieldPos("EI5_PART_N")) # 0  .And. !Empty(EI5->EI5_PART_N)//ASK 08/10/2007  
              oSend( oPrn, 'SAY',  Linha, 480 , EI5->EI5_PART_N,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
              lPulaLinha := .T.
           Else  
              If !Empty( SA5->A5_CODPRF )
                 oSend( oPrn, 'SAY',  Linha, 480 , SA5->A5_CODPRF,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
                 lPulaLinha := .T.
              Endif
           EndIf   
           nNumero := nNumero+1

        ELSEIF nNumero == 2
           If !Empty( MEMOLINE(SA5->A5_PARTOPC,24,1) )
              oSend( oPrn, 'SAY',  Linha, 480 , MEMOLINE(SA5->A5_PARTOPC,24,1),  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
              lPulaLinha := .T.
           Endif
           nNumero := nNumero+1

        ELSEIF nNumero == 3
           If !Empty( MEMOLINE(SA5->A5_PARTOPC,24,2) )
              oSend( oPrn, 'SAY',  Linha, 480 , MEMOLINE(SA5->A5_PARTOPC,24,2),  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
              lPulaLinha := .T.
           Endif
           nNumero := nNumero+1

        ELSEIF nNumero == 4
           If !Empty( SYG->YG_REG_MIN )
              oSend( oPrn, 'SAY',  Linha, 480 , SYG->YG_REG_MIN,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
              lPulaLinha := .T.
           Endif
           nNumero := nNumero+1

        ENDIF
    ENDIF

    /*IF !EMPTY( RIGHT(SA2->A2_NREDUZ, 10 ) )  .AND.  i == 2
       oSend( oPrn, 'SAY',  Linha,1380, RIGHT(SA2->A2_NREDUZ,10), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
       lPulaLinha := .T.
    ENDIF*/

    oFnt := aFontes:COURIER_20_NEGRITO
    pTipo := 5
    PO112BateTraco()

    If lPulaLinha
       Linha := Linha+50
    Endif

NEXT


Return

*------------------------------------*
Static FUNCTION PO112Remarks()
*------------------------------------*
Local i
i := bWhile := bAcumula := nil
cRemarks:=''

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO112BateTraco()

Linha := Linha+50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 2
   PO112BateTraco()
   Linha := Linha+50
Endif

oSend( oPrn, 'SAY',  Linha, 750, LITERAL_OBSERVACOES, aFontes:TIMES_NEW_ROMAN_08_UNDERLINE )

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO112BateTraco()

Linha := Linha+50


SYP->( DBSEEK( xFilial()+EI4->EI4_OBS ) )

bWhile  :={||xFilial('SYP') == SYP->YP_FILIAL .AND. EI4->EI4_OBS == SYP->YP_CHAVE }
bAcumula:={||IF( !EMPTY(SYP->YP_TEXTO), cRemarks := cRemarks+ALLTRIM(SYP->YP_TEXTO)+" ", ) }

SYP->( DBEVAL( bAcumula,, bWhile ) )


FOR i:=1 TO MLCOUNT( cRemarks, 40 )

   IF Linha >= 3000
      ENCERRA_PAGINA
      COMECA_PAGINA

      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 5
      PO112BateTraco()
      Linha := Linha+50

      oSend( oPrn, 'SAY',  Linha, 750, LITERAL_OBSERVACOES, aFontes:TIMES_NEW_ROMAN_08_UNDERLINE )

      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 2
      PO112BateTraco()
      Linha := Linha+50
   ENDIF

   IF !EMPTY(MEMOLINE( cRemarks,40, i ))
      oSend( oPrn, 'SAY',  Linha, 700 , MEMOLINE( cRemarks,40, i ),  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
   ENDIF

   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 5
   PO112BateTraco()
   Linha := Linha+50
NEXT

RETURN NIL

*------------------------------*
Static FUNCTION PO112Totais()
*------------------------------*

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO112BateTraco()
Linha := Linha+50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50
Else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_NORMAL
   Linha := Linha+50
Endif

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 1250 , STR0048                                   , aFontes:COURIER_08_NEGRITO ) //"TOTAL "
oSend( oPrn, 'SAY',  Linha,2100, TRANS(nTotal,E_TrocaVP(nIdioma,cPict2Total))  , aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )

Linha := Linha+50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50
else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_REDUZIDO
   Linha := Linha+50
Endif

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 1250 , LITERAL_INLAND_CHARGES , aFontes:COURIER_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha,2100, TRANS(EI4->EI4_INLAND,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
Linha := Linha + 50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50

else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_REDUZIDO
   Linha := Linha+50
Endif

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 1250 , LITERAL_PACKING_CHARGES , aFontes:COURIER_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha,2100, TRANS(EI4->EI4_PACKIN,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
Linha := Linha+50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50
else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_REDUZIDO
   Linha := Linha+50
Endif

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()
oSend( oPrn, 'SAY',  Linha, 1250 , LITERAL_INTL_FREIGHT , aFontes:COURIER_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha,2100, TRANS(EI4->EI4_FRETEI,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
Linha := Linha+50

If Linha >= 3000
   ENCERRA_PAGINA
   COMECA_PAGINA

   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50
else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_REDUZIDO
   Linha := Linha+50
Endif

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()
oSend( oPrn, 'SAY',  Linha, 1250 , LITERAL_DISCOUNT , aFontes:COURIER_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha,2100, TRANS(EI4->EI4_DESCON,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
Linha := Linha+50

If Linha >=2730
   ENCERRA_PAGINA
   COMECA_PAGINA
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   Linha := Linha+50
else
   oFnt  := aFontes:COURIER_20_NEGRITO
   pTipo := 6
   PO112BateTraco()
   TRACO_REDUZIDO
   Linha := Linha+50
Endif

nTotalGeral := (nTotal+EI4->EI4_INLAND+EI4->EI4_PACKIN+EI4->EI4_FRETEI)-EI4->EI4_DESCON

oFnt  := aFontes:COURIER_20_NEGRITO
pTipo := 6
PO112BateTraco()

oSend( oPrn, 'SAY',  Linha, 1250 , STR0048 + ALLTRIM( EI4->EI4_INCOTER )         , aFontes:COURIER_08_NEGRITO ) //"TOTAL "
oSend( oPrn, 'SAY',  Linha, 1675 , EI4->EI4_MOEDA,aFontes:COURIER_08_NEGRITO )
oSend( oPrn, 'SAY',  Linha,2100, TRANS(nTotalGeral,E_TrocaVP(nIdioma,cPict2Total)), aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )

Linha := Linha+50

oSend( oPrn, 'OFONT', aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
Linha := Linha+200

RETURN NIL

*--------------------------------*
Static FUNCTION PO112BateTraco()
*--------------------------------*

xLinha := nil

If pTipo == 1      .OR.  pTipo == 2  .OR. pTipo == 7
   xLinha := 100

ElseIf pTipo == 3  .OR.  pTipo == 4
   xLinha := 20

ElseIf pTipo == 5  .OR.  pTipo == 6
   xLinha := 50

Endif


oSend(oPrn,'OFONT',oFnt)

DO CASE

   CASE pTipo == 1  .OR.  pTipo == 3
        oSend(oPrn,'LINE', Linha,   50, (Linha+xLinha),   50 ) ; oSend(oPrn,'LINE', Linha,   51, (Linha+xLinha),   51 )
        oSend(oPrn,'LINE', Linha, 2300, (Linha+xLinha), 2300 ) ; oSend(oPrn,'LINE', Linha, 2301, (Linha+xLinha), 2301 )


   CASE pTipo == 2  .OR.  pTipo == 4  .OR.  pTipo == 5
        oSend(oPrn,'LINE', Linha,   50, (Linha+xLinha),   50 ) ; oSend(oPrn,'LINE', Linha,   51, (Linha+xLinha),   51 )
        oSend(oPrn,'LINE', Linha,  120, (Linha+xLinha),  120 ) ; oSend(oPrn,'LINE', Linha,  121, (Linha+xLinha),  121 )
        oSend(oPrn,'LINE', Linha,  460, (Linha+xLinha),  460 ) ; oSend(oPrn,'LINE', Linha,  461, (Linha+xLinha),  461 )
        oSend(oPrn,'LINE', Linha, 1390, (Linha+xLinha), 1390 ) ; oSend(oPrn,'LINE', Linha, 1391, (Linha+xLinha), 1391 )
        oSend(oPrn,'LINE', Linha, 1650, (Linha+xLinha), 1650 ) ; oSend(oPrn,'LINE', Linha, 1651, (Linha+xLinha), 1651 )
        oSend(oPrn,'LINE', Linha, 2010, (Linha+xLinha), 2010 ) ; oSend(oPrn,'LINE', Linha, 2011, (Linha+xLinha), 2011 )
        oSend(oPrn,'LINE', Linha, 2300, (Linha+xLinha), 2300 ) ; oSend(oPrn,'LINE', Linha, 2301, (Linha+xLinha), 2301 )


   CASE pTipo == 6  .OR.  pTipo == 7
        oSend(oPrn,'LINE', Linha,   50, (Linha+xLinha),   50 ) ; oSend(oPrn,'LINE', Linha,   51, (Linha+xLinha),   51 )
        oSend(oPrn,'LINE', Linha, 1200, (Linha+xLinha), 1200 ) ; oSend(oPrn,'LINE', Linha, 1201, (Linha+xLinha), 1201 )
        oSend(oPrn,'LINE', Linha, 2300, (Linha+xLinha), 2300 ) ; oSend(oPrn,'LINE', Linha, 2301, (Linha+xLinha), 2301 )


ENDCASE

RETURN NIL


