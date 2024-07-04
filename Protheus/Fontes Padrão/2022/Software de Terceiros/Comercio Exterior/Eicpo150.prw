#INCLUDE "Eicpo150.ch"  
#INCLUDE "AvPrint.ch"  
#INCLUDE "Average.ch"  
#INCLUDE "rwmake.ch"                 
#DEFINE INGLES                     1
#DEFINE PORTUGUES                  2    
#DEFINE DLG_CHARPIX_H   15.1
#DEFINE DLG_CHARPIX_W    7.9
#DEFINE LITERAL_PEDIDO             IF( nIdioma == INGLES, "PURCHASE ORDER NR: ", STR0001 ) //"NR. PEDIDO: "
#DEFINE LITERAL_ALTERACAO          IF( nIdioma == INGLES, "REVISION Number: ", STR0002 ) //"ALTERA�+O N�mero: "
#DEFINE LITERAL_DATA               IF( nIdioma == INGLES, "Date: "             , STR0003 ) //"Data: "
#DEFINE LITERAL_PAGINA             IF( nIdioma == INGLES, "Page: "             , STR0004 ) //"P�gina: "
#DEFINE LITERAL_FORNECEDOR         IF( nIdioma == INGLES, "SUPPLIER........: " , STR0005 ) //"FORNECEDOR......: "
#DEFINE LITERAL_ENDERECO           IF( nIdioma == INGLES, "ADDRESS.........: " , STR0006 ) //"ENDERE�O........: "
#DEFINE LITERAL_REPRESENTANTE      IF( nIdioma == INGLES, "REPRESENTATIVE..: " , STR0007 ) //"REPRESENTANTE...: "
#DEFINE LITERAL_REPR_TEL           IF( nIdioma == INGLES, "TEL.: "             , STR0008 ) //"FONE: "
#DEFINE LITERAL_COMISSAO           IF( nIdioma == INGLES, "COMMISSION......: " , STR0009 ) //"COMISS+O........: "
#DEFINE LITERAL_CONTATO            IF( nIdioma == INGLES, "CONTACT.........: " , STR0010 ) //"CONTATO.........: "
#DEFINE LITERAL_IMPORTADOR         IF( nIdioma == INGLES, "IMPORTER........: " , STR0011 ) //"IMPORTADOR......: "
#DEFINE LITERAL_CONDICAO_PAGAMENTO IF( nIdioma == INGLES, "TERMS OF PAYMENT: " , STR0012 ) //"COND. PAGAMENTO.: "
#DEFINE LITERAL_VIA_TRANSPORTE     IF( nIdioma == INGLES, "MODE OF DELIVERY: " , STR0013 ) //"VIA TRANSPORTE..: "
#DEFINE LITERAL_DESTINO            IF( nIdioma == INGLES, "DESTINATION.....: " , STR0014 ) //"DESTINO.........: "
#DEFINE LITERAL_AGENTE             IF( nIdioma == INGLES, "FORWARDER.......: " , STR0015 ) //"AGENTE..........: "
#DEFINE LITERAL_QUANTIDADE         IF( nIdioma == INGLES, "Quantity"           , STR0016 ) //"Quantidade"
#DEFINE LITERAL_DESCRICAO          IF( nIdioma == INGLES, "Description"        , STR0017 ) //"Descri��o"
#DEFINE LITERAL_FABRICANTE         IF( nIdioma == INGLES, "Manufacturer"       , STR0018 ) //"Fabricante"
#DEFINE LITERAL_PRECO_UNITARIO1    IF( nIdioma == INGLES, "Unit"               , STR0019 ) //"Pre�o"
#DEFINE LITERAL_PRECO_UNITARIO2    IF( nIdioma == INGLES, "Price"              , STR0020 ) //"Unit�rio"
#DEFINE LITERAL_TOTAL_MOEDA        IF( nIdioma == INGLES, "Amount"             , STR0021 ) //"   Total"
#DEFINE LITERAL_DATA_PREVISTA1     IF( nIdioma == INGLES, "Req. Ship"          , STR0022 ) //"Data Prev."
#DEFINE LITERAL_DATA_PREVISTA2     IF( nIdioma == INGLES, "Date"               , STR0023 ) //"Embarque"
#DEFINE LITERAL_OBSERVACOES        IF( nIdioma == INGLES, "REMARKS"            , STR0024 ) //"OBSERVA�iES"
#DEFINE LITERAL_INLAND_CHARGES     IF( nIdioma == INGLES, "INLAND CHARGES"     , STR0025 ) //"Despesas Internas"
#DEFINE LITERAL_PACKING_CHARGES    IF( nIdioma == INGLES, "PACKING CHARGES"    , STR0026 ) //"Despesas Embalagem"
#DEFINE LITERAL_INTL_FREIGHT       IF( nIdioma == INGLES, "INT'L FREIGHT"      , STR0027 ) //"Frete Internacional"
#DEFINE LITERAL_DISCOUNT           IF( nIdioma == INGLES, "DISCOUNT"           , STR0028 ) //"Desconto"
#DEFINE LITERAL_OTHER_EXPEN        IF( nIdioma == INGLES, "OTHER EXPEN."       , STR0045 ) //"Outras Despesas"
#DEFINE LITERAL_STORE              IF( nIdioma == INGLES, "STORE: "            , STR0046 ) //FDR - 06/01/12 //"Loja"

static aMarcados:={},nMarcados

Function Eicpo150()

If EasyEntryPoint("PO150RDM")
   ExecBlock( "PO150RDM" ,.F.,.F., )
   Return
endif

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CPOINT1P,LPOINT1P,CPOINT2P,LPOINT2P,CMARCA,LINVERTE")
SetPrvt("APOS,AROTINA,BFUNCAO,NCONT")
SetPrvt("NTOTAL,NTOTALGERAL,NIDIOMA,CCADASTRO,NPAGINA,ODLGIDIOMA")
SetPrvt("NVOLTA,ORADIO1,LEND,OPRINT>,LINHA,PTIPO")
SetPrvt("CINDEX,CCOND,NINDEX,NOLDAREA,OFONT1")
SetPrvt("OFONT2,OFONT3,OFONT4,OFONT5,OFONT6,OFONT7")
SetPrvt("OFONT8,OFONT9,OPRN,AFONTES,CCLICOMP,ACAMPOS")
SetPrvt("CNOMARQ,AHEADER,LCRIAWORK,CPICTQTDE,CPICT1TOTAL")
SetPrvt("CPICT2TOTAL,CQUERY,OFONT10,OFNT,C2ENDSM0,C2ENDSA2")
SetPrvt("CCOMMISSION,C2ENDSYT,CTERMS,CDESTINAT,CREPR,CCGC")
SetPrvt("CNR,CPOINTS,I,N1,N2,NNUMERO")
SetPrvt("BACUMULA,BWHILE,LPULALINHA,NTAM,CDESCRITEM,CREMARKS")
SetPrvt("XLINHA,")

// Para imprimir um BitMap
// Ex: oSend(oPrn, "SayBitmap", nLin, 100, "SEAL.BMP" , 400, 200 )

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �EICPO150  � Autor � Cristiano A. Ferreira � Data �09/11/1998���
��+----------+------------------------------------------------------------���
���Descri��o �Emissao do Pedido                                           ���
��+----------+------------------------------------------------------------���
���Sintaxe   �#EICPO150                                                   ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Private _PictPo:=ALLTRIM(X3Picture("W2_PO_NUM"))
//Tabelas referentes a rotina da Manuten��o de Proformas
Private lNewProforma := ChkFile("EYZ") .AND. ChkFile("EW0")  //TRP-12/08/08
aMarcados:={}  

cPoint1P := "EICPO1P"
lPoint1P := EasyEntryPoint(cPoint1P)

cPoint2P := "EICPOPIC"
lPoint2P := EasyEntryPoint(cPoint2P)

cMarca := Nil; lInverte:=.F.
aPos:= {  8,  4, 11, 74 }

aRotina := MenuDef()
if existFunc("PO151Imp")
   bFuncao := {|| PO151Imp() }
else
   bFuncao := {|| PO150Impr() }
endif

nCont := 0; nTotal:=0; nTotalGeral:=0; nIdioma:=INGLES

cCadastro := STR0032 //"Sele��o de Purchase Order"
nPagina:=0

SA5->(DBSETORDER(2))
cMarca := GetMark()
                         

//+--------------------------------------------------------------+
//� Pega picture especifica para Unisys ( Qtde e Total )         �
//+--------------------------------------------------------------+

IF lPoint1P
   ExecBlock( cPoint1P,.F.,.F.,"1" )
ENDIF
//+-----------------------------------------------------------------+
//� Pega picture especifica para Deda Behring  Qtde e Preco unitario�
//+-----------------------------------------------------------------+

IF lPoint2P
   ExecBlock( cPoint2P ,.F.,.F. )
ENDIF

dbSelectArea("SW2")  
SW2->(MarkBrow("SW2","W2_OK",,,,cMarca,,,,,"PO150Marca()")) //EMISSAO

SA5->(DBSETORDER(1))

Return(NIL)        
                    

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 14:25
*/
Static Function MenuDef()
Local aRotAdic := {}   
Local aRotina :=  { { STR0029,"AxPesqui"  , 0 , 1},; //"Pesquisar"
                    { STR0030,"Eval(bFuncao)", 0 , 0}} //"Emissao"###"ReEmissao"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPO150MNU")
	aRotAdic := ExecBlock("IPO150MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*----------------------------------------------
Function PO150Marca()
*----------------------------------------------
Local nPos:=aScan(aMarcados,SW2->(RecNo()))

If SoftLock("SW2")
   If SW2->W2_OK == cMarca
      SW2->W2_OK := ""    
      If nPos > 0
         aDel(aMarcados,nPos)
         aSize(aMarcados,Len(aMarcados)-1)
      Endif                               
   Else
      SW2->W2_OK := cMarca
      If nPos = 0
         aAdd(aMarcados,SW2->(Recno()))
      Endif                               
   Endif
Endif   
Return
*--------------------------*
Static FUNCTION PO150Impr()
*--------------------------*
oDlgIdioma := nVolta := oRadio1 := Nil
lEnd := nil

@ (9*DLG_CHARPIX_H),(10*DLG_CHARPIX_W) TO (17*DLG_CHARPIX_H),(45*DLG_CHARPIX_W) DIALOG oDlgIdioma TITLE AnsiToOem(STR0033) //"Sele��o"

@  8,10 TO 48,80 TITLE STR0034 //"Selecione o Idioma"

nVolta:=0

//oRadio1 := oSend( TRadMenu(), "New", 18, 13, {STR0035,STR0036},{|u| If(PCount() == 0, nIdioma, nIdioma := u)}, oDlgIdioma,,,,,, .F.,, 45, 13,, .F., .T., .T. ) //"Ingl�s"###"Idioma Corrente"
oRadio1 := oSend( TRadMenu(), "New", 17, 13, {STR0035,STR0036},{|u| If(PCount() == 0, nIdioma, nIdioma := u)}, oDlgIdioma,,,,,, .F.,, 55, 13,, .F., .T., .T. ) //"Ingl�s"###"Idioma Corrente"

oSend( SButton(), "New", 10, 90,1, {|| nVolta:=1, oSend(oDlgIdioma, "End")}, oDlgIdioma, .T.,,)
oSend( SButton(), "New", 37, 90,2, {|| oSend(oDlgIdioma,"End")}, oDlgIdioma, .T.,,)

ACTIVATE DIALOG oDlgIdioma CENTERED

IF nVolta == 1
   PO150Report()
Endif

Return(NIL)        


*----------------------------*
Static FUNCTION PO150Report()
*----------------------------*

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

#COMMAND    TRACO_NORMAL                   => oSend(oPrn,"Line", Linha  ,  50, Linha  , 2300 ) ;
                                           ;  oSend(oPrn,"Line", Linha+1,  50, Linha+1, 2300 )

#COMMAND    TRACO_REDUZIDO                 => oSend(oPrn,"Line", Linha  ,1511, Linha  , 2300 ) ; //DFS - 28/02/11 - Posi��o alterada
                                           ;  oSend(oPrn,"Line", Linha+1,1511, Linha+1, 2300 )

#COMMAND    ENCERRA_PAGINA                 => oSend(oPrn,"oFont",aFontes:COURIER_20_NEGRITO) ;
                                           ;  TRACO_NORMAL


#COMMAND    COMECA_PAGINA [<lItens>]       => AVNEWPAGE                    ;
                                           ;  Linha := 160                  ; //180
                                           ;  nPagina := nPagina+ 1        ;
                                           ;  pTipo := 2                   ;
                                           ;  PO150Cabec()                 ;
                                           ;  PO150Cab_Itens(<lItens>)

/*  // Transformado em funcao Static
#xTranslate  DATA_MES(<x>) =>              SUBSTR(DTOC(<x>)  ,1,2)+ " " + ;
                                           IF( nIdioma == INGLES,;
                                               SUBSTR(CMONTH(<x>),1,3),;
                                               SUBSTR(Nome_Mes(MONTH(<x>)),1,3) ) +; 
                                           " " + LEFT(DTOS(<x>)  ,4)

*/
cIndex := cCond := nIndex := Nil; nOldArea:=ALIAS()
oFont1:=oFont2:=oFont3:=oFont4:=oFont5:=oFont6:=oFont7:=oFont8:=oFont9:=Nil
oPrn:= Linha:= aFontes:= Nil; cCliComp:=""
aCampos:={}; cNomArq:=Nil; aHeader:={}
lCriaWork:=.T.

cPictQtde:='@E 999,999,999.999'; cPict1Total:='@E 999,999,999,999.99'
cPict2Total:='@E 99,999,999,999,999.99'

nMarcados:=Len(aMarcados)

IF nMarcados == 0
   MsgInfo(STR0037,STR0038) //"N�o existem registros marcados para a impress�o !"###"Aten��o"

ELSE
   dbSelectArea("SW2")

   AVPRINT oPrn NAME STR0039 //"Emiss�o do Pedido"
      //                              Font            W  H  Bold          Device
      oFont1 := oSend(TFont(),"New","Times New Roman",0,18,,.T.,,,,,,,,,,,oPrn )
      oFont2 := oSend(TFont(),"New","Times New Roman",0,12,,.F.,,,,,,,,,,,oPrn )
      oFont3 := oSend(TFont(),"New","Times New Roman",0,12,,.T.,,,,,,,,,,,oPrn )
      oFont4 := oSend(TFont(),"New","Courier New"    ,0,08,,.T.,,,,,,,,,,,oPrn )
      oFont5 := oSend(TFont(),"New","Times New Roman",0,08,,.T.,,,,,,,,,,,oPrn )
      oFont6 := oSend(TFont(),"New","Courier New"    ,0,12,,.T.,,,,,,,,,,,oPrn )
      oFont7 := oSend(TFont(),"New","Courier New"    ,0,26,,.T.,,,,,,,,,,,oPrn )
      oFont8 := oSend(TFont(),"New","Times New Roman",0,10,,.T.,,,,,,,,,,,oPrn )
      //                                                            Underline
      oFont9 := oSend(TFont(),"New","Times New Roman",0,10,,.T.,,,,,.T.,,,,,,oPrn )
      oFont10:= oSend(TFont(),"New","Courier New"    ,0,10,,.T.,,,,,,,,,,,oPrn )

      aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, oFont7, oFont8, oFont9, oFont10 }

      AVPAGE

         Processa({|X| lEnd := X, PO150Det() })

      AVENDPAGE

      oSend(oFont1,"End")
      oSend(oFont2,"End")
      oSend(oFont3,"End")
      oSend(oFont4,"End")
      oSend(oFont5,"End")
      oSend(oFont6,"End")
      oSend(oFont7,"End")
      oSend(oFont8,"End")
      oSend(oFont9,"End")

   AVENDPRINT

   dbSelectArea("SW2")
   dbGoTop()
ENDIF
aMarcados:={}
Return .T.

*--------------------------*
Static Function PO150Det()
*--------------------------*
Local nMarcados
ProcRegua(Len(aMarcados))  //LRL 11/02/04 - ProcRegua(nMarcados))
Private lMaisPag := .F.
Private nLinTtfob := 0

For nMarcados:=1 To Len(aMarcados)

   SW2->(dbGoTo(aMarcados[nMarcados]))
   IncProc("Imprimindo...") // Atualiza barra de progresso

   Linha := 160 // 180
   nTotal:=nTotalGeral:=0
   nPagina:=1
   nCont := 0

   pTipo := 1
   PO150Cabec()

   //loop dos itens SW3
   dbSelectArea("SW3")
   SW3->(dbSetOrder(1))
   SW3->(dbSeek(xFilial()+SW2->W2_PO_NUM))
   While SW3->(!Eof()) .AND.;
         SW3->W3_FILIAL == XFILIAL("SW3") .AND. ;
         SW3->W3_PO_NUM == SW2->W2_PO_NUM

      If SW3->W3_SEQ # 0
         SW3->(dbSkip())
         LOOP
      Endif

      PO150Item()

      SW3->(dbSkip())
   Enddo
   Linha := Linha+50
   TRACO_NORMAL
   
   PO150Totais()
   PO150Remarks()

   //+---------------------------------------------------------+
   //� Atualiza FLAG de EMITIDO                                �
   //+---------------------------------------------------------+
   dbSelectArea("SW2")

   RecLock("SW2",.F.)
   SW2->W2_EMITIDO := "S" //PO Impresso
   SW2->W2_OK      := ""  //PO Desmarcado
   MsUnLock()

   If nMarcados+1 <= Len(aMarcados)
      AVNEWPAGE
   Endif

Next // LOOP DO PO/SW2

Return nil

*---------------------------*
Static FUNCTION PO150Cabec()
*---------------------------*
local i//FSY - 02/05/2013

c2EndSM0:=""; c2EndSA2:=""; cCommission:=""; c2EndSYT:=""; cTerms:=""
cDestinat:=""; cRepr:=""; cCGC:=""; cNr:=""

IF EasyGParam("MV_ID_CLI") == 'S'
   //-----------> Cliente.
   SA1->( DBSETORDER( 1 ) )
   SA1->( DBSEEK( xFilial("SA1")+SW2->W2_CLIENTE+EICRetLoja("SW2","W2_CLILOJ") ) )
   cCliComp:= SA1->A1_NOME //IF(EasyGParam("MV_ID_CLI")='S',SA1->A1_NOME,SY1->Y1_NOME)
ELSE
   // --------->  Comprador.
   SY1->( DBSETORDER(1) )
   SY1->( DBSEEK( xFilial("SY1")+SW2->W2_COMPRA ) )
   cCliComp:= SY1->Y1_NOME
ENDIF
//----------->  Fornecedor.
SA2->( DBSETORDER( 1 ) )
SA2->( DBSEEK( xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ") ) )
//----------->  Paises.
SYA->( DBSETORDER( 1 ) )
SYA->( DBSEEK( xFilial()+SA2->A2_PAIS ) )
c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_MUN   ), ALLTRIM(SA2->A2_MUN   )+' - ', "" )
c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_BAIRRO), ALLTRIM(SA2->A2_BAIRRO)+' - ', "" )
c2EndSA2 := c2EndSA2 + IF( !EMPTY(SA2->A2_ESTADO), ALLTRIM(SA2->A2_ESTADO)+' - ', "" )
IF nIdioma==INGLES
	c2EndSA2 := c2EndSA2 + IF( !EMPTY(SYA->YA_PAIS_I ), ALLTRIM(SYA->YA_PAIS_I )+' - ', "" )
ELSE
	c2EndSA2 := c2EndSA2 + IF( !EMPTY(SYA->YA_DESCR ), ALLTRIM(SYA->YA_DESCR )+' - ', "" )
ENDIF
c2EndSA2 := LEFT( c2EndSA2, LEN(c2EndSA2)-2 )

//-----------> Pedidos.
IF SW2->W2_COMIS $ cSim
   cCommission :=SW2->W2_MOEDA+" "+TRANS(SW2->W2_VAL_COM,E_TrocaVP(nIdioma,'@E 9,999,999,999.9999'))
   IF( SW2->W2_TIP_COM == "1", cCommission:=TRANS(SW2->W2_PER_COM,E_TrocaVP(nIdioma,'@E 999.99'))+"%", )
   IF( SW2->W2_TIP_COM == "4", cCommission:=SW2->W2_OUT_COM, )
ENDIF

//-----------> Importador.
SYT->( DBSETORDER( 1 ) )
SYT->( DBSEEK( xFilial()+SW2->W2_IMPORT ) )
cPaisImpor := Alltrim(Posicione("SYA",1,xFilial("SYA")+SYT->YT_PAIS,"YA_DESCR"))    //Acb - 26/11/2010

c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_CIDADE), ALLTRIM(SYT->YT_CIDADE)+' - ', "" )
c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_ESTADO), ALLTRIM(SYT->YT_ESTADO)+' - ', "" )
//c2EndSYT := c2EndSYT + IF( !EMPTY(SYT->YT_PAIS  ), ALLTRIM(SYT->YT_PAIS  )+' - ', "" )
c2EndSYT := c2EndSYT + IF( !EMPTY(cPaisImpor), cPaisImpor  +' - ', "" )    //Acb - 26/11/2010
c2EndSYT := LEFT( c2EndSYT, LEN(c2EndSYT)-2 )
cCgc     := ALLTRIM(SYT->YT_CGC)

IF EasyGParam("MV_ID_EMPR") == 'S'
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SM0->M0_CIDCOB), ALLTRIM(SM0->M0_CIDCOB)+' - ', "" )
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SM0->M0_ESTCOB), ALLTRIM(SM0->M0_ESTCOB)+' - ', "" )
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SM0->M0_CEPCOB), TRANS(SM0->M0_CEPCOB,"@R 99999-999")+' - ', "" )
   c2EndSM0 := LEFT( c2EndSM0, LEN(c2EndSM0)-2 )
   //acd   cCgc:=ALLTRIM(SM0->M0_CGC)
ELSE
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SYT->YT_CIDADE), ALLTRIM(SYT->YT_CIDADE)+' - ', "" )
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SYT->YT_ESTADO), ALLTRIM(SYT->YT_ESTADO)+' - ', "" )
   c2EndSM0 := c2EndSM0 +IF( !EMPTY(SYT->YT_CEP), TRANS(SYT->YT_CEP,"@R 99999-999")+' - ', "" )
   c2EndSM0 := LEFT( c2EndSM0, LEN(c2EndSM0)-2 )
   //acd   cCgc:=ALLTRIM(SYT->YT_CGC)
ENDIF

//-----------> Condicoes de Pagamento.
SY6->( DBSETORDER( 1 ) )
SY6->( DBSEEK( xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0) ) )
           
IF nIdioma == INGLES
   cTerms := MSMM(SY6->Y6_DESC_I,AVSX3("Y6_VM_DESI",3))//48)	//ASR 04/11/2005
ELSE
   cTerms := MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3))//48)	//ASR 04/11/2005
ENDIF
cTerms := STRTRAN(cTerms, CHR(13)+CHR(10), " ")	//ASR 04/11/2005

//-----------> Portos.
//acd   SY9->( DBSETORDER( 1 ) )
SY9->( DBSETORDER( 2 ) )
SY9->( DBSEEK( xFilial()+SW2->W2_DEST ) )

cDestinat := ALLTRIM(SW2->W2_DEST) + " - " + ALLTRIM(SY9->Y9_DESCR)

//-----------> Agentes Embarcadores.
SY4->( DBSETORDER( 1 ) )
SY4->( DBSEEK( xFilial()+SW2->W2_AGENTE ) ) //W2_FORWARD ) )     // GFP - 10/06/2013

//-----------> Agentes Embarcadores.
SYQ->( DBSEEK( xFilial()+SW2->W2_TIPO_EMB ) )

//-----------> Agentes Compradores.
SY1->(DBSEEK(xFilial()+SW2->W2_COMPRA))


oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
//Linha := Linha+70
  Linha := Linha// acb - 29/01/2010

//THTS - 18/02/2021 - Ponto de Entrada para auxiliar na inclus�o de um logotipo no relat�rio
If EasyEntryPoint("PO150LGO")
   ExecBlock("PO150LGO",.f.,.f.,{Linha})
Endif

IF EasyGParam("MV_ID_EMPR") == 'S'
   oSend( oPrn, "Say", Linha    , 1150, ALLTRIM(SM0->M0_NOME)  , aFontes:TIMES_NEW_ROMAN_18_NEGRITO,,,, 2 )
//   Linha:=Linha+150
    Linha := Linha+100// acb - 29/01/2010
   oSend( oPrn, "Say", Linha    , 1150, ALLTRIM(SM0->M0_ENDCOB), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
ELSE
   If SYT->(FieldPos("YT_COMPEND")) > 0  // TLM - 09/06/2008 Inclus�o do campo complemento, SYT->YT_COMPEND
      cNr:=IF(!EMPTY(SYT->YT_COMPEND),ALLTRIM(SYT->YT_COMPEND),"") + IF(!EMPTY(SYT->YT_NR_END),", "+ALLTRIM(STR(SYT->YT_NR_END,6)),"")
   Else
      cNr:=IF(!EMPTY(SYT->YT_NR_END),", "+ALLTRIM(STR(SYT->YT_NR_END,6)),"")
   EndIf
   oSend( oPrn, "Say", Linha    , 1150, ALLTRIM(SYT->YT_NOME)    , aFontes:TIMES_NEW_ROMAN_18_NEGRITO,,,, 2 )
//   Linha:=Linha+150
    Linha := Linha+100// acb - 29/01/2010
   oSend( oPrn, "Say", Linha    , 1150, ALLTRIM(SYT->YT_ENDE)+ " " + cNr, aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
ENDIF

oSend( oPrn, "Say", Linha:= Linha+50, 1150, ALLTRIM(c2EndSM0), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )

IF EasyGParam("MV_ID_CLI") == 'S'  // Cliente.

   IF ! EMPTY( ALLTRIM(SA1->A1_TEL) )
      oSend( oPrn, "Say", Linha := Linha+50, 1150, "Tel: " + ALLTRIM(SA1->A1_TEL), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
   ENDIF
   IF ! EMPTY( ALLTRIM(SA1->A1_FAX) )
      oSend( oPrn, "Say", Linha := Linha+50, 1150, "Fax: " + ALLTRIM(SA1->A1_FAX), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
   ENDIF

ELSE                         // Comprador.

   IF ! EMPTY( ALLTRIM(SY1->Y1_TEL) )
      oSend( oPrn, "Say", Linha := Linha+50, 1150, "Tel: " + ALLTRIM(SY1->Y1_TEL), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
   ENDIF
   IF ! EMPTY( ALLTRIM(SY1->Y1_FAX) )
      oSend( oPrn, "Say", Linha := Linha+50, 1150, "Fax: " + ALLTRIM(SY1->Y1_FAX), aFontes:TIMES_NEW_ROMAN_12,,,, 2 )
   ENDIF

ENDIF
//Linha := Linha+100
  Linha := Linha+50// acb - 29/01/2010

oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
//Linha := Linha+30
  Linha := Linha+10// acb - 29/01/2010

oSend( oPrn, "Say", Linha, 1150, LITERAL_PEDIDO + ALLTRIM(TRANS(SW2->W2_PO_NUM,_PictPo)), aFontes:TIMES_NEW_ROMAN_12,,,,2 )
//Linha := Linha+100
  Linha := Linha+50// acb - 29/01/2010

IF ! EMPTY(SW2->W2_NR_ALTE)
   oSend( oPrn, "Say", Linha, 400 , LITERAL_ALTERACAO + STRZERO(SW2->W2_NR_ALTE,2) , aFontes:TIMES_NEW_ROMAN_12 )
   oSend( oPrn, "Say", Linha, 1750, LITERAL_DATA + DATA_MES( SW2->W2_DT_ALTE )     , aFontes:TIMES_NEW_ROMAN_12 )
//Linha := Linha+100
  Linha := Linha+50// acb - 29/01/2010
ENDIF

//oSend( oPrn, "Say", Linha, 400 , LITERAL_DATA + DATA_MES( dDataBase ) , aFontes:TIMES_NEW_ROMAN_12 )
oSend( oPrn, "Say", Linha, 400 , LITERAL_DATA + DATA_MES( SW2->W2_PO_DT ) , aFontes:TIMES_NEW_ROMAN_12 )
oSend( oPrn, "Say", Linha, 1750, LITERAL_PAGINA + STRZERO(nPagina,3)  , aFontes:TIMES_NEW_ROMAN_12 )
//Linha := Linha+100
  Linha := Linha+50// acb - 29/01/2010

If pTipo == 2  // A partir da 2o. p�gina.
   Return
Endif

oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO150BateTraco()
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_FORNECEDOR, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, SA2->A2_NREDUZ + Space(2) + Alltrim(IF(EICLOJA(), LITERAL_STORE /*"Loja:"*/ + Alltrim(SA2->A2_LOJA),"")) , aFontes:TIMES_NEW_ROMAN_12 ) //FDR - 06/01/12
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_ENDERECO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, ALLTRIM(SA2->A2_END)+" "+ALLTRIM(SA2->A2_NR_END), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

If !Empty(SA2->A2_COMPLEM)  // GFP - 31/10/2013
   oSend( oPrn, "Say",  Linha, 630, ALLTRIM(SA2->A2_COMPLEM), aFontes:TIMES_NEW_ROMAN_12 )
   Linha := Linha+50
EndIf

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 630, c2EndSA2              , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 630, SA2->A2_CEP           , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

cRepr:=IF(nIdioma==INGLES,"NONE","NAO HA")

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_REPRESENTANTE, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, IF(EMPTY(SA2->A2_REPRES),cRepr,SA2->A2_REPRES)       , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_ENDERECO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, SA2->A2_REPR_EN , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_COMISSAO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, cCommission     , aFontes:TIMES_NEW_ROMAN_12 )

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha,1750, LITERAL_REPR_TEL, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha,1910, ALLTRIM(IF(!EMPTY(SA2->A2_REPRES),SA2->A2_REPRTEL,ALLTRIM(SA2->A2_DDI)+" "+ALLTRIM(SA2->A2_DDD)+" "+SA2->A2_TEL)), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_CONTATO, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, SA2->A2_CONTATO, aFontes:TIMES_NEW_ROMAN_12 )

oSend( oPrn, "Say",  Linha,1750, "FAX.: "           , aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha,1910, ALLTRIM(IF(!EMPTY(SA2->A2_REPRES),SA2->A2_REPRFAX,ALLTRIM(SA2->A2_DDI)+" "+ALLTRIM(SA2->A2_DDD)+" "+SA2->A2_FAX)), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO150BateTraco()

Linha := Linha+20
oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO )
TRACO_NORMAL
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_IMPORTADOR, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, SYT->YT_NOME      , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

IF SYT->(FieldPos("YT_COMPEND")) > 0  // TLM - 09/06/2008 Inclus�o do campo complemento, SYT->YT_COMPEND
   cNr:=If(!EMPTY(SYT->YT_COMPEND),ALLTRIM(SYT->YT_COMPEND),"") + IF(!EMPTY(SYT->YT_NR_END),", " +  ALLTRIM(STR(SYT->YT_NR_END,6)),"") 
Else
   cNr:=IF(!EMPTY(SYT->YT_NR_END),", "+ALLTRIM(STR(SYT->YT_NR_END,6)),"")
EndIF 
oSend( oPrn, "Say",  Linha, 630, ALLTRIM(SYT->YT_ENDE)+ " " + cNr, aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 630, c2EndSYT           , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

IF ! EMPTY(cCGC)
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 1
   PO150BateTraco()

   oSend( oPrn, "Say",  Linha, 630, AVSX3("YT_CGC",5)+": "  + Trans(cCGC,"@R 99.999.999/9999-99") , aFontes:TIMES_NEW_ROMAN_12 ) // "C.N.P.J. "
   Linha := Linha+50
ENDIF

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO150BateTraco()

Linha := Linha+20
oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO)
TRACO_NORMAL
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100 , STR0040, aFontes:COURIER_12_NEGRITO ) //"PROFORMA INVOICE: "
oSend( oPrn, "Say",  Linha, 1750, LITERAL_DATA            , aFontes:COURIER_12_NEGRITO )

//TRP-12/08/08
If lNewProforma .and. EasyGParam("MV_AVG0186",,.F.) // NCF - 05/01/2010 - Cria��o do Par�metro MV_AVG0186 que define se as informa��es da proforma
                                          //                    vir�o da capa do PO (.F.) ou se vir�o da tabela de manuten��o de proformas (.T.)
   EYZ->(DbSetOrder(2))
   EYZ->(DbSeek(xFilial("EYZ")+ SW2->W2_PO_NUM )) 

   Do While EYZ->(!EOF()) .AND. xFilial("EYZ") == EYZ->EYZ_FILIAL .AND. EYZ->EYZ_PO_NUM == SW2->W2_PO_NUM

      oSend( oPrn, "Say",  Linha, 630 , EYZ->EYZ_NR_PRO         , aFontes:TIMES_NEW_ROMAN_12 )
      oSend( oPrn, "Say",  Linha, 1920, DATA_MES(EYZ->EYZ_DT_PRO), aFontes:TIMES_NEW_ROMAN_12 )
      Linha := Linha+50 

      EYZ->(DbSkip())
   Enddo
Else 
   oSend( oPrn, "Say",  Linha, 630 , SW2->W2_NR_PRO          , aFontes:TIMES_NEW_ROMAN_12 )
   oSend( oPrn, "Say",  Linha, 1920, DATA_MES(SW2->W2_DT_PRO), aFontes:TIMES_NEW_ROMAN_12 )
Endif
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO150BateTraco()

Linha := Linha+20
oSend(oPrn,"oFont",aFontes:COURIER_20_NEGRITO)
TRACO_NORMAL

nLinCp := Max(MLCOUNT( cTerms, 80 ),1)

oSend(oPrn,"Line", Linha-50,   50, (Linha+100+50*nLinCp),   50 ) ; oSend(oPrn,"Line", Linha-50,   51, (Linha+100+50*nLinCp),   51 )
oSend(oPrn,"Line", Linha-50, 2300, (Linha+100+50*nLinCp), 2300 ) ; oSend(oPrn,"Line", Linha-50, 2301, (Linha+100+50*nLinCp), 2301 )

Linha := Linha+20//FSY - 02/05/2013

oSend( oPrn, "Say",  Linha, 100, LITERAL_CONDICAO_PAGAMENTO , aFontes:COURIER_12_NEGRITO )
//ASR 04/11/2005 - oSend( oPrn, "Say",  Linha, 630, MEMOLINE(cTerms,48,1)      , aFontes:TIMES_NEW_ROMAN_12 )
IF nIdioma == INGLES
   //oSend( oPrn, "Say",  Linha, 630, MEMOLINE(cTerms,48,1)      , aFontes:TIMES_NEW_ROMAN_12 )
   FOR i:=1 TO MLCOUNT( cTerms, 80 )//FSY - Para imprimir toda descri��o do pagamento - 02/05/2013
      oSend( oPrn, "Say",  Linha, 630, MEMOLINE(cTerms,80,i)      , aFontes:TIMES_NEW_ROMAN_12 )
      Linha := Linha+50
   Next
ELSE
   //oSend( oPrn, "Say",  Linha, 630, MEMOLINE(cTerms,48,1)      , aFontes:TIMES_NEW_ROMAN_12 )
   FOR i:=1 TO MLCOUNT( cTerms, 80 )//FSY - Para imprimir toda descri��o do pagamento - 02/05/2013
      oSend( oPrn, "Say",  Linha, 630, MEMOLINE(cTerms,80,i)      , aFontes:TIMES_NEW_ROMAN_12 )
      Linha := Linha+50
   Next
ENDIF
If MLCOUNT( cTerms, 80 ) == 0//FSY - 02/05/2013
   Linha := Linha+50
EndIf

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 3
PO150BateTraco()

Linha := Linha+20
oSend( oPrn, "oFont", aFontes:COURIER_20_NEGRITO )

oSend( oPrn, "Line",  Linha  ,  50, Linha  , 2300 )
oSend( oPrn, "Line",  Linha+1,  50, Linha+1, 2300 )
Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, STR0041 , aFontes:COURIER_12_NEGRITO ) //"INCOTERMS.......: "
oSend( oPrn, "Say",  Linha, 630, ALLTRIM(SW2->W2_INCOTERMS)+" "+ALLTRIM(SW2->W2_COMPL_I), aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

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
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_DESTINO , aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, cDestinat       , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 1
PO150BateTraco()

oSend( oPrn, "Say",  Linha, 100, LITERAL_AGENTE, aFontes:COURIER_12_NEGRITO )
oSend( oPrn, "Say",  Linha, 630, SY4->Y4_NOME  , aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+50

PO150Cab_Itens()

Return

*--------------------------------*
Static FUNCTION PO150Cab_Itens(lImp)
*--------------------------------*
Default lImp := .T.
If !lImp
   Return Nil
EndIf

Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 4
PO150BateTraco()

oSend(oPrn,"oFont", aFontes:COURIER_20_NEGRITO)  // Define fonte padrao
TRACO_NORMAL

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 2
PO150BateTraco()

Linha := Linha+20

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 4
PO150BateTraco()

oSend( oPrn, "Say",  Linha,  065, STR0042                , aFontes:TIMES_NEW_ROMAN_10_NEGRITO ) //"IT"
oSend( oPrn, "Say",  Linha,  200, LITERAL_QUANTIDADE     , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha,  470, LITERAL_DESCRICAO      , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 1500, LITERAL_FABRICANTE     , aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )
oSend( oPrn, "Say",  Linha, 1570, LITERAL_PRECO_UNITARIO1, aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 1840, LITERAL_TOTAL_MOEDA    , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2130, LITERAL_DATA_PREVISTA1 , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
Linha := Linha+50

pTipo := 5
oFnt := aFontes:COURIER_20_NEGRITO
PO150BateTraco()

oSend( oPrn, "Say",  Linha,   65, STR0043                , aFontes:TIMES_NEW_ROMAN_10_NEGRITO ) //"Nb"
oSend( oPrn, "Say",  Linha, 1570, LITERAL_PRECO_UNITARIO2, aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 1870, SW2->W2_MOEDA          , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2130, LITERAL_DATA_PREVISTA2 , aFontes:TIMES_NEW_ROMAN_10_NEGRITO )

Linha := Linha+50

oSend(oPrn,"oFont", aFontes:COURIER_20_NEGRITO) // Define fonte padrao

TRACO_NORMAL

oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 5
PO150BateTraco()

RETURN NIL

*-------------------------*
Static FUNCTION PO150Item()
*-------------------------*
Local i
Private cNomeFantasia := ""
cPointS :="EICPOOLI"
i := n1 := n2 := nil
nNumero := 1
nTam := 20 //MFR 28/02/2020 OSSME-4409 Redu��o novamente do tamanho pois na impress�o ou gera��o via pdf a descri��o do item sobrep�e a descri��o do produto
cDescrItem := "" //Esta variavel � Private por causa do Rdmake "EICPOOLI"

//-----------> Unidade Requisitante (C.Custo).
SY3->( DBSETORDER( 1 ) )
SY3->( DBSEEK( xFilial()+SW3->W3_CC ) )

//-----------> Fornecedores.
SA2->( DBSETORDER( 1 ) )
SA2->( DBSEEK( xFilial()+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ") ) )

//-----------> Reg. Ministerio.
SYG->( DBSETORDER( 1 ) )
SYG->( DBSEEK( xFilial()+SW2->W2_IMPORT+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")+SW3->W3_COD_I ) )

//-----------> Produtos (Itens) e Textos.
SB1->( DBSETORDER( 1 ) )
SB1->( DBSEEK( xFilial()+SW3->W3_COD_I ) )

If EasyEntryPoint(cPointS)
   ExecBlock(cPointS,.f.,.f.)
Endif

cDescrItem := MSMM(IF( nIdioma==INGLES, SB1->B1_DESC_I, SB1->B1_DESC_P ),) // MPG - 08/03/2019
STRTRAN(cDescrItem,CHR(13)+CHR(10), " ") 
n1 := MlCount( cDescrItem, nTam )
n2 := n1+4

IF(lPoint1P,ExecBlock(cPoint1P,.F.,.F.,"2"),)

//-----------> Produtos X Fornecedor.
SA5->( DBSETORDER( 3 ) )
//SA5->( DBSEEK( xFilial()+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN ) )
EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW3", "W3_FORLOJ"))

IF Linha >= 3100 .or. Linha+100 >= 3100
   Linha := Linha+50
   ENCERRA_PAGINA
   COMECA_PAGINA

   Linha := Linha+50
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 5
   PO150BateTraco()
else
   Linha := Linha+50
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 5
   PO150BateTraco()
ENDIF

nCont:=nCont+1
oSend( oPrn, "Say",  Linha,  65, STRZERO(nCont,3),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
oSend( oPrn, "Say",  Linha, 370, TRANS(SW3->W3_QTDE,E_TrocaVP(nIdioma,cPictQtde)),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, "Say",  Linha, 400, BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,IF(EICLOJA(),SW3->W3_FABLOJ,""),IF(EICLOJA(),SW3->W3_FORLOJ,"")),   aFontes:TIMES_NEW_ROMAN_08_NEGRITO )  
cNomeFantasia := (SA2->A2_NREDUZ)

If Len(Alltrim(cNomeFantasia)) > 50
   oSend( oPrn, "Say",  Linha,1450, LEFT(AllTrim(SA2->A2_NREDUZ),len(cNomeFantasia)/2) + Space(2) + IF(EICLOJA(), LITERAL_STORE /*"Loja:"*/ + Alltrim(SA2->A2_LOJA),"") ,aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 ) //FDR - 06/01/12
   Linha := Linha + 30
   oSend( oPrn, "Say",  Linha,1300, RIGHT(AllTrim(SA2->A2_NREDUZ),len(cNomeFantasia)/2) + Space(2) ,aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1) 
   Linha := Linha - 30
else
    oSend( oPrn, "Say",  Linha,1450, AllTrim(SA2->A2_NREDUZ) + Space(2) + IF(EICLOJA(), LITERAL_STORE /*"Loja:"*/ + Alltrim(SA2->A2_LOJA),"") ,aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
endIF

oSend( oPrn, "Say",  Linha,1740, TRANS(SW3->W3_PRECO,E_TrocaVP(nIdioma,'@E 999,999,999.99999')),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, "Say",  Linha,2100, TRANS(ROUND(SW3->W3_QTDE*SW3->W3_PRECO,2),E_TrocaVP(nIdioma,cPict1Total )),aFontes:TIMES_NEW_ROMAN_08_NEGRITO,,,,1 )
oSend( oPrn, "Say",  Linha,2130, DATA_MES(SW3->W3_DT_EMB),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
nTotal := DI500TRANS(nTotal + SW3->W3_QTDE*SW3->W3_PRECO,2)

For i := 1 to n2

   lPulaLinha := .F.
   IF Linha >= 3100
      Linha := Linha+50
      ENCERRA_PAGINA
      COMECA_PAGINA

      Linha := Linha+50
      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 5
      PO150BateTraco()
   
   ENDIF
/* //retirado para que a vari�vel nTam n�o mude de tamanho, pois estava perdendo parte da descri��o do item na funcao MEMOLINE( cDescrItem, nTam , i )
   if i > 1
      nTam := 50
   endif
  */ 
   if i <= n1 .and. !empty(MEMOLINE( cDescrItem, nTam , i ))
      oSend( oPrn, "Say",  Linha, 480, MEMOLINE( cDescrItem,nTam , i ),aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
      lPulaLinha := .T.
   endif
   
   IF i > n1
      IF i == n1+1
         If SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N)
            oSend( oPrn, "Say",  Linha, 480 , SW3->W3_PART_N,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
            lPulaLinha := .T.
         Else
            If !Empty( SA5->A5_CODPRF )
               oSend( oPrn, "Say",  Linha, 480 , SA5->A5_CODPRF,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
               lPulaLinha := .T.
            Endif
         EndIf   

      ELSEIF i == n1+2
         If !Empty( MEMOLINE(SA5->A5_PARTOPC,24,1) )
            oSend( oPrn, "Say",  Linha, 480 , MEMOLINE(SA5->A5_PARTOPC,24,1),  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
            lPulaLinha := .T.
         Endif

      ELSEIF i == n1+3
         If !Empty( MEMOLINE(SA5->A5_PARTOPC,24,2) )
            oSend( oPrn, "Say",  Linha, 480 , MEMOLINE(SA5->A5_PARTOPC,24,2),  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
            lPulaLinha := .T.
         Endif

      ELSEIF i == n1+4
         If !Empty( SYG->YG_REG_MIN )
            oSend( oPrn, "Say",  Linha, 480 , SYG->YG_REG_MIN,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )
            lPulaLinha := .T.
         Endif
      ENDIF
   Endif

   if lPulaLinha
      Linha := Linha+50
      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 5
      PO150BateTraco()
   endif

Next

Return

*----------------------------*
Static FUNCTION PO150Remarks()
*----------------------------*
Local i, x
Local cTextAux := ""
cRemarks:=""


IF Linha+100 >= 3100
   TRACO_NORMAL
   COMECA_PAGINA(.F.)
   TRACO_NORMAL
   
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 8
   PO150BateTraco()
   Linha := Linha+50
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 8
   PO150BateTraco()

else

   Linha := Linha+75
   TRACO_NORMAL
   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 8
   PO150BateTraco()
   Linha := Linha+25
   PO150BateTraco()

ENDIF

oSend( oPrn, "Say",  Linha, 065, LITERAL_OBSERVACOES, aFontes:TIMES_NEW_ROMAN_08_UNDERLINE )
Linha := Linha+50
oFnt := aFontes:COURIER_20_NEGRITO
pTipo := 8
PO150BateTraco()

cRemarks := MSMM(SW2->W2_OBS,60)

nTam := 150
n1 := MlCount( cRemarks, nTam )

for i := 1 to n1

   Linha := Linha+50

   IF Linha >= 3100
      TRACO_NORMAL
      COMECA_PAGINA(.F.)
      TRACO_NORMAL
      
      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 8
      PO150BateTraco()
      Linha := Linha+50
      oFnt := aFontes:COURIER_20_NEGRITO
      pTipo := 8
      PO150BateTraco()
   ENDIF

   oFnt := aFontes:COURIER_20_NEGRITO
   pTipo := 8
   PO150BateTraco()
   oSend( oPrn, "Say",  Linha, 065 , MEMOLINE( cRemarks , nTam , i ) ,  aFontes:TIMES_NEW_ROMAN_08_NEGRITO )

next

// fecha o quadro da observa��o
Linha := Linha + 50
TRACO_NORMAL

// box para o nome do comprador para assinatura
Linha := Linha+50
pTipo := 9
PO150BateTraco()
oSend(oPrn,"Line", Linha, 50, Linha, 2300 )
Linha := Linha+25
PO150BateTraco()
oSend(oPrn,"Say", Linha, 60, cCliComp, aFontes:TIMES_NEW_ROMAN_12 )
Linha := Linha+100
oSend(oPrn,"Line", Linha, 50, Linha, 2300 )

RETURN NIL

*---------------------------*
Static FUNCTION PO150Totais()
*---------------------------*
Local nTamPntos := 74
Local nAuxPontos := 0

If Linha >= 3100 .or. Linha+300 >= 3100

   ENCERRA_PAGINA
   COMECA_PAGINA(.F.)
   TRACO_NORMAL
   oFnt  := aFontes:TIMES_NEW_ROMAN_12 //COURIER_20_NEGRITO
   pTipo := 9 // 6
   PO150BateTraco()

   Linha := Linha+25

   oFnt  := aFontes:TIMES_NEW_ROMAN_12 //COURIER_20_NEGRITO
   pTipo := 9 // 6
   PO150BateTraco()

Else
   oFnt  := aFontes:TIMES_NEW_ROMAN_12 //COURIER_20_NEGRITO
   pTipo := 9 // 6
   PO150BateTraco()

   Linha := Linha+25

   oFnt  := aFontes:TIMES_NEW_ROMAN_12 //COURIER_20_NEGRITO
   pTipo := 9 // 6
   PO150BateTraco() 
Endif

nAuxPontos := nTamPntos - len(STR0044)
oSend( oPrn, "Say",  Linha, 0100 , STR0044 + replicate('.', nAuxPontos )+":", aFontes:COURIER_NEW_10_NEGRITO ) //"TOTAL " // 1570 - COURIER_08_NEGRITO
oSend( oPrn, "Say",  Linha, 2100 , TRANS(ROUND(nTotal,2),E_TrocaVP(nIdioma,cPict2Total))  , aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 ) // 2100 // TIMES_NEW_ROMAN_08_NEGRITO

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 

nAuxPontos := nTamPntos - len(LITERAL_INLAND_CHARGES)
oSend( oPrn, "Say",  Linha, 0100 , LITERAL_INLAND_CHARGES  + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO ) // INLAND CHARGES
oSend( oPrn, "Say",  Linha, 2100 , TRANS(SW2->W2_INLAND,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 

nAuxPontos := nTamPntos - len(LITERAL_PACKING_CHARGES)
oSend( oPrn, "Say",  Linha, 0100 , LITERAL_PACKING_CHARGES + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO ) // PACKING CHARGES
oSend( oPrn, "Say",  Linha, 2100 , TRANS(SW2->W2_PACKING,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 

nAuxPontos := nTamPntos - len(LITERAL_INTL_FREIGHT)
oSend( oPrn, "Say",  Linha, 0100 , LITERAL_INTL_FREIGHT + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2100 , TRANS(SW2->W2_FRETEINT,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco()

nAuxPontos := nTamPntos - len(LITERAL_DISCOUNT)
oSend( oPrn, "Say",  Linha, 0100 , LITERAL_DISCOUNT + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2100 , TRANS(SW2->W2_DESCONT,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco()

nAuxPontos := nTamPntos - len(LITERAL_OTHER_EXPEN)
oSend( oPrn, "Say",  Linha, 0100 , LITERAL_OTHER_EXPEN + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2100 , TRANS(SW2->W2_OUT_DES,E_TrocaVP(nIdioma,'@E 999,999,999,999.99')), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

Linha := Linha+25
oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
pTipo := 9 // 6
PO150BateTraco() 
//TRACO_NORMAL

//TDF 02/02/12 - TRATAMENTO PARA FRETE INCLUSO SIM
If SW2->W2_FREINC == "1"
   nTotalGeral := DI500TRANS((nTotal+SW2->W2_OUT_DES)-SW2->W2_DESCONT,2)   
Else
   nTotalGeral := DI500TRANS((nTotal+SW2->W2_INLAND+SW2->W2_PACKING+SW2->W2_FRETEINT+SW2->W2_OUT_DES)-SW2->W2_DESCONT,2)
EndIf

Linha := Linha+25
cAux := alltrim(STR0044) + " " + alltrim( SW2->W2_INCOTER ) + " " + alltrim(SW2->W2_MOEDA)
nAuxPontos := nTamPntos - len(cAux)
oSend( oPrn, "Say",  Linha, 0100 , cAux + replicate('.', nAuxPontos )+":" , aFontes:COURIER_NEW_10_NEGRITO ) //"TOTAL "
//oSend( oPrn, "Say",  Linha, 0350 , SW2->W2_MOEDA + replicate('.', nAuxPontos )+":" ,aFontes:COURIER_NEW_10_NEGRITO )
oSend( oPrn, "Say",  Linha, 2100 , TRANS(DITRANS(nTotalGeral,2),E_TrocaVP(nIdioma,cPict2Total)), aFontes:TIMES_NEW_ROMAN_10_NEGRITO,,,,1 )

oFnt  := aFontes:TIMES_NEW_ROMAN_10_NEGRITO //COURIER_20_NEGRITO
Linha := Linha+75
TRACO_NORMAL

RETURN NIL

*----------------------------------------*
Static FUNCTION PO150BateTraco()
*----------------------------------------*
xLinha := nil

If pTipo == 1      .OR.  pTipo == 2  .OR. pTipo == 7 .OR. pTipo == 9
   xLinha := 100
ElseIf pTipo == 3  .OR.  pTipo == 4
   xLinha := 20
ElseIf pTipo == 5  .OR.  pTipo == 6 .Or. pTipo == 8
   xLinha := 50
Endif

oSend(oPrn,"oFont",oFnt)

DO CASE

   CASE pTipo == 1  .OR.  pTipo == 3
        oPrn:Box( Linha,  50, (Linha+xLinha),  51)
        oPrn:Box( Linha,2300, (Linha+xLinha),2301)

   CASE pTipo == 2  .OR.  pTipo == 4  .OR.  pTipo == 5
        oPrn:Box( Linha,  50, (Linha+xLinha),  51)
        oPrn:Box( Linha, 120, (Linha+xLinha), 121)
        oPrn:Box( Linha, 460, (Linha+xLinha), 461)
        oPrn:Box( Linha,1510, (Linha+xLinha),1511)        
        oPrn:Box( Linha,1750, (Linha+xLinha),1751)
        oPrn:Box( Linha,2110, (Linha+xLinha),2111)
        oPrn:Box( Linha,2300, (Linha+xLinha),2301)

   CASE pTipo == 6  .OR.  pTipo == 7
        oPrn:Box( Linha,  50, (Linha+xLinha),  51)
        oPrn:Box( Linha,1510, (Linha+xLinha),1511) //DFS - 28/02/11 - Posicionamento das linhas
        oPrn:Box( Linha,2300, (Linha+xLinha),2301)
   
   Case pTipo == 8
        oPrn:Box( Linha,  50, (Linha+xLinha),  51)
        oPrn:Box( Linha,2300, (Linha+xLinha),2301)
   CASE pTipo == 9 
        oPrn:Box( Linha,  50, (Linha+xLinha),  51)
//        oPrn:Box( Linha,1510, (Linha+xLinha),1511) //DFS - 28/02/11 - Posicionamento das linhas
        oPrn:Box( Linha,2300, (Linha+xLinha),2301)
ENDCASE

RETURN NIL
*----------------------------------------*
Static Function DATA_MES(x)
*----------------------------------------*

IF !Empty(x)
   Return SUBSTR(DTOC(x)  ,1,2)+ " " + IF( nIdioma == INGLES, SUBSTR(CMONTH(x),1,3),;
          SUBSTR(Nome_Mes(MONTH(x)),1,3) ) + " " + LEFT(DTOS(x)  ,4)
EndIf

Return ""

function PO150Marks(lClear)
   local aRet := {}

   default lClear := .F.

   if !lClear
      aRet := aClone(aMarcados)
   else
      aSize(aMarcados,0)
      aMarcados := {}
   endif

return aRet
