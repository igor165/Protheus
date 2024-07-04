#INCLUDE "EDCPA150.ch"
#include "AVERAGE.CH"

#DEFINE COURIER_10 oFont1
#DEFINE COURIER_16 oFont2
#define NUMDELIN  39 //56  NCCF 17/02/09
#define NUMDELIN1 37//54  NCCF 17/02/09
#define NUMLINRUD 30//20 - RRC - 11/12/2012 - 30 //DFS - 21/01/2011 - Alteração do número de linhas impressas por página nos relatórios de DrawBack
#define NUMLINDI  19//23 - RRC - 11/12/2012 //19
#define TAMDESC    40
#define TAMDESCLI  48
#define TAMDESCDI  65
#define TAMDESCEXP 60
#define TAMDESCREL 44 //58  - AOM - 02/07/2012 - Alterado o tamanho para 44 para nao cortar descrição
#define TAMDESCPED 54
#define TAMDESCEND 66
#define TAMDESCRE  AVSX3('EE9_VM_DRE',3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função EDCPA150_AP6.PRW  Autor - Thomaz Augusto Netto  Data ³09/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Impressão do Pedido de Drawback                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAEDC - Drawback                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado : Sandra Yuriko - 29/08/2002
           1. Tamanho do campo do CGC de 14 para 18
           2. Criado campo para Incoterm WK_INCOTE
           3. WK_PRAZO, tirado do RPT
           4. Alterado STR0020 para ["Produtos diversas, conforme Anexos" - 10.Discriminacao]
           5. Alterado STR0043 
           6. Inclusão WKD_UNIDAD, utilizado para informar a Unidade de Medida, no relatório.
           7. Inclusão WKD_PEDMSG, utilizado para impressão de Msg do campo 33, qdo tiver Percentual de Perda
           8. Inclusão WKD_PEDMSG1, utilizado para impressão de Msg do campo 'SEM VALOR COMERCIAL',
              qdo tiver Percentual de Perda.
           9. Inclusão WKD_VALEMB, para informar o Valor Local de Embarque, pegando do campo valor original
           10. Inclusão WKD_NF e WKD_DTNF para informar o número e data da Nota Fiscal, ainda não é utilizado no Programa
           11. Inclusão WKD_TUNI01 até WKD_TUNI020 e WKD_UNI01 à WKD_UNI20 para imprimir o total por unidade
               de medida e a unidade de medida.
           12. Inclusão WKD_FR_USS e WKD_SEGURO para informar no Rud o Valor de Frete e Seguro
           13. Inclusão WKD_ASSRU1 e WKD_ASSRU2 para informar o nome dos assinantes do Rud, pegando
               dos parâmetro MV_ASSRUD1 e MV_ASSRUD2.
******************************************************************************
Alteração..: Alessandro Jose Porta
Data/Hora..: 26/06/2007 - 16H00
Objetivo...: Tratamento de Multifilial

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alteração..: Nilson César - 11/02/2009 
Data/Hora..: 11/02/2009 - 16H00
Objetivos..:           
           1. Adicinado SYT->YT_CEP em WKD_ENDERE para informar o cep no endereço
           2. Alterado a impressão de "----" para "Não há" do campo nº 33 do Pedido de Drawback 
           3. Modificação da gravação no campo WK_NCMEXP e WK_NCMIMP --> "Vide Anexo(s) xxx á yyy"
           4. Alteração nos Defines NUMDELIN e NUNDELIN1 para evitar quebra de página incorreta.          
****************************************************************************************************           
*/
*------------------------------*
Function EDCPA150()
*------------------------------*
Local nOldArea := Alias(), aOrd := SaveOrd("ED0"), nOrdSX3 := SX3->(IndexOrd())


Private cFilSB1 := xFilial("SB1"), cFilED0 := xFilial("ED0")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cArqRpt, cTitRpt, lRet := .F., cSeqRel:=""//, cOrdAnexo:=""
Private cFileMen:="", aHeader[0], mMemoCarta:="", cPictDi:=AVSX3("ED2_DI_NUM",6) 
Private cPictPeTot:= "@E 99,999,999,999"+If(AVSX3("ED1_PESO",4)#0,"."+Replicate("9",5),"") 
Private cPictQtde := "@E 999,999,999,999,999"+If(AVSX3("ED1_QTD",4)#0,"."+Replicate("9",AVSX3("ED1_QTD",4)),"")
Private cPictFob  := "@E 9,999,999,999,999"+If(AVSX3("ED3_VAL_CO",4)#0,"."+Replicate("9",AVSX3("ED3_VAL_CO",4)),"")
Private cPictCGC:= AVSX3("YT_CGC",6), cCmd, lAdit := .F., nCont := 1
Private Fre_Seg:= "", aDetail := {},aAnexo:={},aAnexo4:={}, lTop := .F., cFilED7 := xFilial("ED7")
Private cNumPed := "",cFilSG1 := xFilial("SG1"),cFilED1 := xFilial("ED1"),cFilED2 := xFilial("ED2")
//AJP 26/06/2007
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                      .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0

Private nTotPPeso:=0, nTotPQtde:=0, nTotPFrete:=0, nTotPSeg:=0, nVlPTot:=0, cUltPD := ""
// --- ACSJ - Verificação de campos no SX3 - 18/11/2004 ---
SYF->( dbSetOrder(1) )
SYF->( dbSeek( xFilial("SYF")+EasyGParam("MV_SIMB2",,"US$") ) )
//AAF 17/05/05 - Descrição da Moeda Dolar.
Private cDolar   := AllTrim(SYF->YF_DESC_SI)
Private cDolares := AllTrim(SYF->YF_DESC_PL)
SX3->(DBSETORDER(2))
Private lED0Deduzp := SX3->(DBSeek("ED0_DEDUZP"))
Private lED0SubTot := SX3->(DBSeek("ED0_SUBTOT"))
Private lED1Umanex := SX3->(DBSeek("ED1_UMANEX"))
Private lED2Inat   := SX3->(DBSeek("ED2_INAT"))
Private lED2Umanex := SX3->(DBSeek("ED2_UMANEX"))
Private cLastFlag  := ""
Private aTotais    := {}
Private cOrdNF := STR0084//STR0085 RRC - 07/12/2012
SX3->(DBSETORDER(nOrdSX3))
ED8->(DBSETORDER(4))

// INICIO - GFC 25/01/2005
SIX->(dbSetOrder(1))
If !SIX->(dbSeek("ED1"+"8"))
   MsgInfo("Índice 8 do arquivo ED1 não encontrado. Favor entrar em contato com o suporte Average e reportar o problema.")
   Return .F.
ElseIf !SIX->(dbSeek("ED3"+"7"))
   MsgInfo("Índice 7 do arquivo ED3 não encontrado. Favor entrar em contato com o suporte Average e reportar o problema.")
   Return .F.
ElseIf !SIX->(dbSeek("ED4"+"7"))
   MsgInfo("Índice 7 do arquivo ED4 não encontrado. Favor entrar em contato com o suporte Average e reportar o problema.")
   Return .F.
EndIf
//FIM

#IFDEF TOP
   lTop := .T.
#ENDIF

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif              
If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif                               
                  
// criar todos os campos como caracter
Private aArqs, cNomDbfC := "EDCPAC"
Private aCamposC := {{"WK_SEQREL ","C", 08,0},;
                     {"WK_PED    ","C", 13,0},;
                     {"WK_DTEMI  ","D", 08,0},;
                     {"WK_PRACA  ","C", 24,0},;
                     {"WK_BENEFIC","C", 52,0},; //ALTERADO 20/09 (25->52) LAM
                     {"WK_CGC    ","C", 18,0},;
                     {"WK_CGC1   ","C", 18,0},;
                     {"WK_CGC2   ","C", 18,0},;
                     {"WK_MENSA  ","C", 50,0},;
                     {"WK_MENSA2 ","C", 50,0},;
                     {"WK_ENDERE ","C", 60,0},;//ALTERADO 20/09 (55->60) LAM
                     {"WK_SUSPEN ","C", 01,0},;
                     {"WK_COBERT ","C", 01,0},;
                     {"WK_FRETE  ","C", 20,0},;
                     {"WK_SEGURO ","C", 20,0},;
                     {"WK_S_COBE ","C", 01,0},;
                     {"WK_ISENCAO","C", 01,0},;
                     {"WK_TOTALG" ,"C", 20,0},;                      
                     {"WK_TOTPES1","C", 20,0},;
                     {"WK_TOTQTD1","C", 50,0},;
                     {"WK_TOTQTD" ,"C", 50,0},;
                     {"WK_TOTQT"  ,"C", 50,0},;
                     {"WK_TOTFOB1","C", 20,0},;
                     {"WK_FOBEXT1","C",150,0},;
                     {"WK_OPCAO  ","C", 01,0},;
                     {"WK_TOTFOB2","C", 20,0},;
                     {"WK_TOTPES2","C", 20,0},;
                     {"WK_TOTQTD2","C", 54,0},;
                     {"WK_TOTQTD3","C", 54,0},;
                     {"WK_TOTQTD4","C", 54,0},;
                     {"WK_FOBEXT2","C",150,0},;
                     {"WK_VALID  ","C", 01,0},;
                     {"WK_PRAZO  ","D", 08,0},;
                     {"WK_DEL_REC","C", 25,0},;
                     {"WK_DESC_IM","C", 60,0},;  
                     {"WK_DESC_EX","C", 60,0},;  
                     {"WK_DT_PROT","C", 08,0},;
                     {"WK_INCOTE ","C", 03,0},; //29/08/02
                     {"WK_PEDMSG ","C", 40,0},; //Mensagem do Rodapé, impressa qdo tiver percentual de perda
                     {"WK_PEDMSG1","C", 01,0},; //Mensagem do Rodapé, impressa qdo tiver percentual de perda
                     {"WK_LOCALDT","C", 50,0},;
                     {"WK_NCMIMP" ,"C",150,0},;
                     {"WK_NCMEXP" ,"C",150,0},;
                     {"WKD_ASSRU1","C", 32,0},;
                     {"WKD_ASSRU2","C", 32,0},;
                     {"WK_UMTOT1" ,"C", 02,0},;
                     {"WK_UMTOT2" ,"C", 02,0},;
                     {"WK_UMTOT3" ,"C", 02,0},;
                     {"WK_UMTOT4" ,"C", 02,0},;
                     {"WK_UMTOT5" ,"C", 02,0},;
                     {"WK_UMTOT6" ,"C", 02,0},;
                     {"WK_TOTUM1" ,"C", 20,0},;
                     {"WK_TOTUM2" ,"C", 20,0},;
                     {"WK_TOTUM3" ,"C", 20,0},;
                     {"WK_TOTUM4" ,"C", 20,0},;
                     {"WK_TOTUM5" ,"C", 20,0},;
                     {"WK_TOTUM6" ,"C", 20,0}}
PRivate cNomDbfD := "EDCPAD"
Private aCamposD := {{"WK_SEQREL ","C", 08,0},;
                     {"WK_PED    ","C", 13,0},;
                     {"WK_LCS    ","C", 01,0},;
                     {"WKD_ITE   ","C", 15,0},;
                     {"WKD_PORIMP","C", 01,0},;
                     {"WKD_EXPORT","C", 01,0},;
                     {"WKD_PESO  ","C", 20,0},;
                     {"WKD_QTDE  ","C", 60,0},;
                     {"WKD_QTDE2 ","C", 60,0},;
                     {"WKD_UNIDAD","C", 02,0},; //Unidade de Medida
                     {"WKD_DISCR ","C", 75,0},;
                     {"WKD_DOC_E ","C", 18,0},;
                     {"WKD_PRE_F ","C", 20,0},;
                     {"WKD_TOT_F ","C", 20,0},;
                     {"WKD_TOT_P ","C", 20,0},;
                     {"WKD_TOT_Q ","C", 20,0},;
                     {"WKD_ANEXO ","C", 03,0},;
                     {"WKD_DIADOR","C", 16,0},;  // GFP - 22/03/2012
                     {"WKD_DI_ADI","C", 16,0},;
                     {"WKD_DTREGI","C", 10,0},;
                     {"WKD_DTDESE","C", 10,0},;  // GFP - 18/05/2012
                     {"WKD_PARTNU","C", 20,0},;
                     {"WKD_AGENCI","C", 60,0},;
                     {"WKD_CARTA" ,"C",100,0},;
                     {"WKD_CONTAT","C", 60,0},;
                     {"WKD_VALEMB","C", 15,0},;//Valor no Local de embarque
                     {"WKD_NF    ","C", 15,0},;// NF
                     {"WKD_DTNF  ","C", 10,0},;// NF
                     {"WKD_SERIE ","C", 03,0},;    // GFP - 21/10/2011 - Adequação para Compras Nacionais
                     {"WKD_MOD_NF","C", 08,0},;    // e Vendas para Exportadores.
                     {"WKD_PEDCOM","C", 15,0},;
                     {"WKD_CGC   ","C", 14,0},;
                     {"WKD_QTD_AD","C", 02,0},;    // Qtd. - Unidade de medida adotada na NF
                     {"WKD_QTD_ES","C", 02,0},;    // Qtd. - Unidade de medida estatistica
                     {"WKD_VAL_R ","C", 17,0},;    // Valor em R$
                     {"WKD_VAL_D ","C", 16,0},;    // Valor em US$ 
                     {"WKD_TOT_UN","C",100,0},;
                     {"WK_FLAG   ","C", 01,0}}
// ASK - 15/04/05
If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"ARRAY_CAMPOS"),)
//Campos utilizados para Informar total por unidade de medida
Aadd(aCamposD,{"WKD_TUNI01","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI02","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI03","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI04","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI05","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI06","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI07","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI08","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI09","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI10","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI11","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI12","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI13","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI14","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI15","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI16","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI17","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI18","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI19","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI20","C", 05,0})
Aadd(aCamposD,{"WKD_UNI01 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI02 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI03 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI04 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI05 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI06 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI07 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI08 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI09 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI10 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI11 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI12 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI13 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI14 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI15 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI16 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI17 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI18 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI19 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI20 ","C", 05,0})
Aadd(aCamposD,{"WKD_MOEDA ","C", 03,0})
Aadd(aCamposD,{"WKD_FR_USS","C", 15,0})
Aadd(aCamposD,{"WKD_SEGURO","C", 15,0})
Aadd(aCamposD,{"WKD_ASSRU1","C", 32,0})
Aadd(aCamposD,{"WKD_ASSRU2","C", 32,0})
Aadd(aCamposD,{"WKD_TOTFRT","C", 15,0})
Aadd(aCamposD,{"WKD_TOTSEG","C", 15,0})
Aadd(aCamposD,{"WK_PEDMSG ","C", 30,0}) //Mensagem do Rodapé, impressa qdo tiver percentual de perda
Aadd(aCamposD,{"WK_PEDMSG1","C", 01,0}) //Mensagem do Rodapé, impressa qdo tiver percentual de perda
Aadd(aCamposD,{"WK_LOCALDT","C", 50,0})
Aadd(aCamposD,{"WKD_TVEM01","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM02","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM03","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM04","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM05","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM06","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM07","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM08","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM09","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM10","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM11","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM12","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM13","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM14","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM15","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM16","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM17","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM18","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM19","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM20","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM01","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM02","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM03","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM04","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM05","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM06","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM07","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM08","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM09","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM10","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM11","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM12","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM13","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM14","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM15","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM16","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM17","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM18","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM19","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM20","C", 05,0})

// criar todos os campos como caracter * estrutura do EDCRU150.RPT
Private aArqsRud, cNomDbfRudC := "EDCRUC"
Private cArqRptRud, cTitRptRud
Private aCamposRudC := {{"WK_SEQREL  ","C", 08,0},;
                        {"WK_PED     ","C", 13,0},;
                        {"WK_AC      ","C", 13,0},;
                        {"WK_EMPRESA ","C", 52,0},; //ALTERADO 20/09 (25->52) LAM
                        {"WK_ENDERE  ","C", 60,0},; //ALTERADO 20/09 (55->60) LAM
                        {"WK_CGC     ","C", 18,0},;
                        {"WK_ANETIM  ","C", 03,0},;
                        {"WK_ANETEX  ","C", 03,0}}
Private cRudD := "EDCRUD"
Private aRudD := {{"WK_SEQREL   ","C", 08,0},;
                  {"WK_PED      ","C", 13,0},;
                  {"WKD_FLAG    ","C", 01,0},;
                  {"WKD_DIADOR  ","C", 20,0},;  // GFP - 22/03/2012
                  {"WKD_DI_ADI  ","C", 20,0},;
                  {"WKD_NCM     ","C", 15,0},;
                  {"WKD_DTREGI  ","C", 10,0},;
                  {"WKD_DTDESE","C", 10,0},;  // GFP - 18/05/2012
                  {"WKD_PARTNU  ","C", 20,0},;
                  {"WKD_DESCR   ","C", 60,0},;
                  {"WKD_PESO    ","C", 20,0},;
                  {"WKD_QTDE    ","C", 22,0},;
                  {"WKD_VAL_F   ","C", 20,0},;
                  {"WKD_LOCAL   ","C", 50,0},;
                  {"WKD_TOT_P   ","C", 20,0},;
                  {"WKD_TOT_Q   ","C", 20,0},;
                  {"WKD_TOT_F   ","C", 20,0},;
                  {"WKD_UNID    ","C", 03,0},;
                  {"WKD_ANEXO   ","C", 03,0},;
                  {"WKD_VALEMB  ","C", 15,0},; //Valor no Local de embarque
                  {"WKD_TOT_UN  ","C",100,0},;                  
                  {"WKD_NF      ","C", 15,0},;
                  {"WKD_DTNF    ","C", 10,0},;
                  {"WKD_SERIE ","C", 03,0},;    //RRC - 07/12/2012 - Adequação para Compras Nacionais
                  {"WKD_MOD_NF","C", 08,0},;    // e Vendas para Exportadores.
                  {"WKD_PEDCOM","C", 15,0},;
                  {"WKD_CGC   ","C", 14,0},;
                  {"WKD_QTD_AD","C", 02,0},;    // Qtd. - Unidade de medida adotada na NF
                  {"WKD_QTD_ES","C", 02,0},;    // Qtd. - Unidade de medida estatistica
                  {"WKD_VAL_R ","C", 17,0},;    // Valor em R$
                  {"WKD_VAL_D ","C", 16,0}}     // Valor em US$ 
                     

//Campos utilizados para Informar total por unidade de medida
Aadd(aRudD,{"WKD_TUNI01","C", 20,0})
Aadd(aRudD,{"WKD_TUNI02","C", 20,0})
Aadd(aRudD,{"WKD_TUNI03","C", 20,0})
Aadd(aRudD,{"WKD_TUNI04","C", 20,0})
Aadd(aRudD,{"WKD_TUNI05","C", 20,0})
Aadd(aRudD,{"WKD_TUNI06","C", 20,0})
Aadd(aRudD,{"WKD_TUNI07","C", 20,0})
Aadd(aRudD,{"WKD_TUNI08","C", 20,0})
Aadd(aRudD,{"WKD_TUNI09","C", 20,0})
Aadd(aRudD,{"WKD_TUNI10","C", 20,0})
Aadd(aRudD,{"WKD_TUNI11","C", 20,0})
Aadd(aRudD,{"WKD_TUNI12","C", 20,0})
Aadd(aRudD,{"WKD_TUNI13","C", 20,0})
Aadd(aRudD,{"WKD_TUNI14","C", 20,0})
Aadd(aRudD,{"WKD_TUNI15","C", 20,0})
Aadd(aRudD,{"WKD_TUNI16","C", 20,0})
Aadd(aRudD,{"WKD_TUNI17","C", 20,0})
Aadd(aRudD,{"WKD_TUNI18","C", 20,0})
Aadd(aRudD,{"WKD_TUNI19","C", 20,0})
Aadd(aRudD,{"WKD_TUNI20","C", 20,0})
Aadd(aRudD,{"WKD_UNI01 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI02 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI03 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI04 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI05 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI06 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI07 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI08 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI09 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI10 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI11 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI12 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI13 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI14 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI15 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI16 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI17 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI18 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI19 ","C", 05,0})
Aadd(aRudD,{"WKD_UNI20 ","C", 05,0})
Aadd(aRudD,{"WKD_MOEDA ","C", 03,0}) //11/09/02
Aadd(aRudD,{"WKD_FR_USS","C", 15,0})
Aadd(aRudD,{"WKD_SEGURO","C", 15,0})
Aadd(aRudD,{"WKD_ASSRU1","C", 32,0})
Aadd(aRudD,{"WKD_ASSRU2","C", 32,0})
Aadd(aRudD,{"WKD_TOTFRT","C", 15,0})
Aadd(aRudD,{"WKD_TOTSEG","C", 15,0})
Aadd(aRudD,{"WK_LOCALDT","C", 50,0})
Aadd(aRudD,{"WKD_TVEM01","C", 15,0})
Aadd(aRudD,{"WKD_TVEM02","C", 15,0})
Aadd(aRudD,{"WKD_TVEM03","C", 15,0})
Aadd(aRudD,{"WKD_TVEM04","C", 15,0})
Aadd(aRudD,{"WKD_TVEM05","C", 15,0})
Aadd(aRudD,{"WKD_TVEM06","C", 15,0})
Aadd(aRudD,{"WKD_TVEM07","C", 15,0})
Aadd(aRudD,{"WKD_TVEM08","C", 15,0})
Aadd(aRudD,{"WKD_TVEM09","C", 15,0})
Aadd(aRudD,{"WKD_TVEM10","C", 15,0})
Aadd(aRudD,{"WKD_TVEM11","C", 15,0})
Aadd(aRudD,{"WKD_TVEM12","C", 15,0})
Aadd(aRudD,{"WKD_TVEM13","C", 15,0})
Aadd(aRudD,{"WKD_TVEM14","C", 15,0})
Aadd(aRudD,{"WKD_TVEM15","C", 15,0})
Aadd(aRudD,{"WKD_TVEM16","C", 15,0})
Aadd(aRudD,{"WKD_TVEM17","C", 15,0})
Aadd(aRudD,{"WKD_TVEM18","C", 15,0})
Aadd(aRudD,{"WKD_TVEM19","C", 15,0})
Aadd(aRudD,{"WKD_TVEM20","C", 15,0})
Aadd(aRudD,{"WKD_MVEM01","C", 15,0})
Aadd(aRudD,{"WKD_MVEM02","C", 15,0})
Aadd(aRudD,{"WKD_MVEM03","C", 15,0})
Aadd(aRudD,{"WKD_MVEM04","C", 15,0})
Aadd(aRudD,{"WKD_MVEM05","C", 05,0})
Aadd(aRudD,{"WKD_MVEM06","C", 05,0})
Aadd(aRudD,{"WKD_MVEM07","C", 05,0})
Aadd(aRudD,{"WKD_MVEM08","C", 05,0})
Aadd(aRudD,{"WKD_MVEM09","C", 05,0})
Aadd(aRudD,{"WKD_MVEM10","C", 05,0})
Aadd(aRudD,{"WKD_MVEM11","C", 05,0})
Aadd(aRudD,{"WKD_MVEM12","C", 05,0})
Aadd(aRudD,{"WKD_MVEM13","C", 05,0})
Aadd(aRudD,{"WKD_MVEM14","C", 05,0})
Aadd(aRudD,{"WKD_MVEM15","C", 05,0})
Aadd(aRudD,{"WKD_MVEM16","C", 05,0})
Aadd(aRudD,{"WKD_MVEM17","C", 05,0})
Aadd(aRudD,{"WKD_MVEM18","C", 05,0})
Aadd(aRudD,{"WKD_MVEM19","C", 05,0})
Aadd(aRudD,{"WKD_MVEM20","C", 05,0})

IF Select("WorkId") > 0
   cArqRpt    := WorkId->EEA_ARQUIV
   cTitRpt    := AllTrim(WorkId->EEA_TITULO)
   cArqRptRud := WorkId->EEA_ARQUIV
   cTitRptRud := AllTrim(WorkId->EEA_TITULO)
Else 
   cArqRpt    := "EDCPA151.RPT"
   cTitRpt    := STR0001 //"Emissao do Ato Concessorio"
   cArqRptRud := "EDCRU150.RPT"
   cTitRptRud := "Emissao do RUD"
Endif

//Pedido
aArqs  := {}
aArqs2 := {}
aArqs3 := {}
aArqs4 := {}

AADD(aArqs,{cNomDbfC,aCamposC,"CAB","WK_SEQREL+WK_PED"})
AADD(aArqs,{cNomDbfD,aCamposD,"DET","WK_SEQREL+WK_PED"})
AADD(aArqs2,{"EDCPAC2",aCamposC,"CAB2","WK_SEQREL+WK_PED"})
AADD(aArqs2,{"EDCPAD2",aCamposD,"DET2","WK_SEQREL+WK_PED"})
AADD(aArqs3,{"EDCPAC3",aCamposC,"CAB3","WK_SEQREL+WK_PED"})
AADD(aArqs3,{"EDCPAD3",aCamposD,"DET3","WK_SEQREL+WK_PED"})
AADD(aArqs4,{"EDCPAC4",aCamposC,"CAB4","WK_SEQREL+WK_PED"})
AADD(aArqs4,{"EDCPAD4",aCamposD,"DET4","WK_SEQREL+WK_PED"})

//Rud
aArqsRud := {}
AADD(aArqsRud,{cNomDbfRudC,aCamposRudC,"RudC","WK_SEQREL+WK_PED"})
AADD(aArqsRud,{cRudD,aRudD,"RudD","WK_SEQREL+WK_PED"})
dbSelectArea(nOldArea)

RestOrd(aOrd)
aMarcados := {}
aRotina := MenuDef()
                        
cCadastro := STR0005 //"Selecao de Pedido de Drawback"
cMarca := GetMark()  
lInverte := .F.
oMainWnd:ReadClientCoords()

DbSelectArea("ED0")

ED0->(DbSetFilter({||(ED0->ED0_MODAL = "2" .And. EMPTY(ED0->ED0_DT_ENC)) /*.Or. (ED0->ED0_MODAL = "1" .And. ED0->ED0_ELETRO = "2" .And. EMPTY(ED0->ED0_DT_ENC))*/ }, "(ED0->ED0_MODAL = '2'.And. EMPTY(ED0->ED0_DT_ENC))"))  //  .Or. (ED0->ED0_MODAL = '1' .And. ED0->ED0_ELETRO = '2' .And. EMPTY(ED0->ED0_DT_ENC))   - NOPADO POR AOM - 03/11/10 - para apresentar apenas ato concessório da modalidade Isenção

ED0->(MarkBrow("ED0","ED0_OK",,,,cMarca,,,,,"PAMarca_Des()")) //Marca/Desmarca

Set Filter To

ED0->(DBSETORDER(1))
ED1->(DBSETORDER(1))
ED2->(DBSETORDER(1))
ED3->(DBSETORDER(1))
ED4->(DBSETORDER(1))
ED5->(DBSETORDER(1))
SYD->(DBSETORDER(1))
SB1->(DBSETORDER(1))
EE9->(DBSETORDER(1))
ED9->(DBSETORDER(1))//AWR - 14/004/2009

IF SELECT("WORK_MEN") # 0
   Work_Men->(E_ERASEARQ(cFileMen))
ENDIF

dbselectArea("SX3")
Return .F.
                    


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 15:23
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0002 ,"AxPesqui"  , 0 , 1},; //"Pesquisar"                                     
                    { STR0003 ,"Eval({|| PAMensagem() })" , 0 , 0},; //"Mensagens"
                    { STR0054 ,"PA150Assin" , 0 , 0},; //"Assinaturas"
                    { STR0076 ,"PA150OrdRUD" , 0 , 0},; //"Ordem RUD"
                    { STR0080 ,"PA150OrdAne" , 0 , 0},; //"Ordem Anexo"
                    { STR0004 ,"Eval({|| PAImpressao()})", 0 , 0}}  //"Emissao"
                   
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DPA150MNU")
	aRotAdic := ExecBlock("DPA150MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


*------------------------------------*
Function PAMarca_Des()
*------------------------------------*
Local nPos:=aScan(aMarcados,ED0->(RecNo()))

IF !ED1->(DbSeek(xFilial("ED1")+ED0->ED0_PD))
   Help(" ",1,"AVG0005202",,Alltrim(ED0->ED0_PD)+" "+STR0010,1,8) //"Pedido "###"não possui Itens Exportados"###"Informação"
   Return .F.
ElseIF !ED2->(DbSeek(xFilial("ED2")+ED0->ED0_PD))
   Help(" ",1,"AVG0005203",,Alltrim(ED0->ED0_PD)+" "+STR0012,1,8) //"Pedido "###"não possui Itens a Importar"###"Informação"
   Return .F.
Else
   If RecLock("ED0",.F.)
      If ED0->ED0_OK == cMarca
         ED0->ED0_OK := Space(Len(ED0->ED0_OK))
         If nPos > 0
            aDel(aMarcados,nPos)
            aSize(aMarcados,Len(aMarcados)-1)
         Endif
      Else
         ED0->ED0_OK := cMarca
         If nPos = 0
            aAdd(aMarcados,ED0->(Recno()))
         Endif                               
      Endif                  
      ED0->(MSUNLOCK())
   Endif           
Endif                 

Return .T.

*--------------------------*
Function PAImpressao()
*--------------------------*
Local n
Local lIntEDCIsencao := FindFunction("EDCPA151")
Local lRet := .F.
Private oFont2 
Private dData, cOrd:=Left(EasyGParam("MV_ORDRUD",,"1"),1), FileWork, FileWork2
Private cFilSYT:= xFilial("SYT")
Private cPed, cNumero:="", cTipo, cCidade:=""
Private lImpDIOrig := .F. //AOM -18/07/2012
nMarcados:=Len(aMarcados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conta os registros validos para impressao.                        ³
                                  
If nMarcados == 0
   Help(" ",1,"AVG0005204") //"Não existem registros marcados para a impressão !"###"Atenção"
Else
   
   //AOM - 18/07/2012
   If Pergunte("PA150",.T.)
      lImpDIOrig := mv_par01 == 2
   EndIf
   
   
   If lIntEDCIsencao .And. nMarcados > 1//BAK - para impressão do pedido de Drawback integrado isenção - 26/09/2011
      MsgInfo("Selecione somente um pedido de drawback.","Atenção")
      For n := 1 To Len(aMarcados)
         ED0->(dbGoTo(aMarcados[n]))
         If RecLock("ED0",.F.)
            ED0->ED0_OK := Space(Len(ED0->ED0_OK))
            ED0->(MSUNLOCK())
         EndIf
         Next n
      aMarcados := {}
      Return Nil
   EndIf
   
   If Select("QRY") # 0
      QRY->(dbCloseArea())
   EndIf
   If Select("QRY2") # 0
      QRY2->(dbCloseArea())
   EndIf
   dbSelectArea("ED0") 
      
   nMarcados:=1
   ED0->(dbGoTo(aMarcados[nMarcados]))
    
   If !PA150Carta()
      For n:= 1 to Len(aMarcados)
         ED0->(dbGoTo(aMarcados[n]))
         RecLock("ED0",.F.)
         ED0->ED0_OK := Space(Len(ED0->ED0_OK)) //Pedido Drawback Desmarcado
         ED0->(MsUnLock())
      Next n
      Return .T.
   Endif
                
   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()

   aRetCrw    := CrwNewFile(aArqs)
   aRetCrw2   := CrwNewFile(aArqs2)
   aRetCrw3   := CrwNewFile(aArqs3)
   aRetCrw4   := CrwNewFile(aArqs4)
   aRetCrwRud := CrwNewFile(aArqsRud)
   
   If cOrd $ "2/3"
      GeraWorkRud()
   EndIf

   Processa({|| lRet:= PA150GrvAnexo(lAdit, cPed, cNumero, cTipo)})   //PA150GrvAnexo(lAdit,aAnexo, aAnexo4,aDetail)})
   If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"ANTES_PREVIEW"),)
   If lRet
      If !lIntEDCIsencao //BAK - para impressão do pedido de Drawback integrado isenção - 26/09/2011
         cArqRpt := "EDCPA151.RPT"
         lRet    := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
         cArqRpt := "EDCPA152.RPT"
         lRet    := CrwPreview(aRetCrw2,cArqRpt,cTitRpt,cSeqRel)
         cArqRpt := "EDCPA153.RPT"
         lRet    := CrwPreview(aRetCrw3,cArqRpt,cTitRpt,cSeqRel)
         cArqRpt := "EDCPA154.RPT"
         lRet    := CrwPreview(aRetCrw4,cArqRpt,cTitRpt,cSeqRel)
      Else  

         If aMarcados[1] > 0
            lRet := EDCPA151(aMarcados[1],mMemoCarta)
         EndIf

         If RecLock("ED0",.F.)
            ED0->ED0_OK := Space(Len(ED0->ED0_OK))
            ED0->(MSUNLOCK())
         EndIf

      EndIf
      /*
        Caso o usuário optar por não ter dados de Nota-Fiscal (data e número da Nota-Fiscal) 
        no RUD, abre .rpt sem as colunas referente a esses dados.
        HFD
      */ 
      //NOPADO por RRC - 12/12/2012 - Os Relatórios foram unificados para o EDCRU150.rpt
      //if cOrdNF $ "2 - Nao" 
       //	 cArqRptRud := "EDCRU151.RPT" 
      //else                             
         cArqRptRud := "EDCRU150.RPT" 
      // EndIf
      
      /*
        ER - 08/12/2006                                                                                                       
        O RUD não será impresso no caso do Campo "Imprime RUD" estiver como "3-Não Imprime" ou caso a Modalidade seja Suspensão
        e o campo Suspensão Eletronica estiver como "Não.
      */
      
      If lRet
         If (Left(ED0->ED0_RUD, 1) == "3") .or. (Left(ED0->ED0_MODAL,1) == "1" .And. Left(ED0->ED0_ELETRO,1) == "2")//Não Imprime
            CrwCloseFile(aRetCrwRud,.T.) // Fecha e apaga os arquivos temporarios do Crystal...         
         Else
            lRet := CrwPreview(aRetCrwRud,cArqRptRud,cTitRptRud,cSeqRel)
         EndIf
      EndIf
      
      RecLock("ED0",.F.)
      ED0->ED0_DT_PED := If(Empty(ED0->ED0_DT_ENV),dDataBase,ED0->ED0_DT_ENV)
      ED0->(MSUNLOCK())
   Else
      CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
      CrwCloseFile(aRetCrwRud,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
   Endif
   
   If cOrd$"2/3"
      WorkRud->(E_EraseArq(FileWork))
      WorkRud2->(E_EraseArq(FileWork2))
   EndIF
    
Endif

ED0->(DBSETORDER(1))   
aMarcados:={}
CloseWork()

Return(NIL)

*---------------------------------------------------------------------------------------------*
FUNCTION PA150GrvAnexo(lAdit, cPed, cNumero, cTipo) //PA150GrvAnexo(lAdit, aAnexo, aAnexo4,aDetail )
*---------------------------------------------------------------------------------------------*
Local mMemoAuxCarta, nPosAnexo, cAnexo, nMarca, lBateBranco:=.F., nx, a
Local aRudUnid:={},x:=1,cUnid:="",nTotQtde := 0,cCampo:="",cUnidade:="",nTotFrete:=0,nTotSeguro:=0
Local cCampo_Moeda :="",cCampo_Vlr:= "", aRudVlr :={}, cRegProd, nCoef:=0
Local cRegNCM, dRegDtEmba, cRegRE, nRegPeso:=0, nRegQtd:=0, nRegPrcUn:=0, nRegPrcTot:=0
Local lPVez := .T., lLoop := .F., nPos:=0, i:=0, lImpNCM:=.F., cUM:=""
Local cExtenso
Local cExtenso1
Local cExtenso2

lED0Deduzp := SX3->(DBSeek("ED0_DEDUZP"))
lED0SubTot := SX3->(DBSeek("ED0_SUBTOT"))
lED1Umanex := SX3->(DBSeek("ED1_UMANEX"))
lED2Inat   := SX3->(DBSeek("ED2_INAT"))
lED2Umanex := SX3->(DBSeek("ED2_UMANEX"))

Private cUnMed:="" //unidade de medida - Alcir Alves - 02-05-05
Private cPictPeso:= AVSX3("ED1_PESO",6), cPictQt:= AVSX3("ED1_QTD",6), aAneQtdTot:={}
Private cPictVl:= AVSX3("ED3_VAL_CO",6), cPictNcm:= AVSX3("ED1_NCM",6)
Private cPictVlEm:= AVSX3("ED1_VAL_EM",6), cPictNcm2:= AVSX3("ED2_NCM",6)
Private cPictQt2:= AVSX3("ED2_QTD",6), cPictValor:= AVSX3("ED2_VALCAL",6)
Private cPictPeso2:= AVSX3("ED2_PESO",6), cPictUni:=AVSX3("ED2_PRCUNI",6)
Private nLIN, cPicRe:= AVSX3("ED1_RE",6), nAnexoP, cNcmExp, cNcmImp, nAnexos_E, nAnexos_I //NCCF 17/02/09
Private nValTot1 := nPesoTot1 := nQtdTot1 := 0, cDescr:="",cAnexoImp:="", cDescricao:=""
Private cNCM:="", cProd:="", lRet := .T., nTotNCMPeso := nTotNCMQtd := nTotNCMTotal:= 0           
Private cTitulo := STR0001 //"Emissao do Ato Concessorio"
Private nAnexoCal := 0,nRudQtde:=0,nQtde:=0, nTotAneEx:= 0, nTotAneIm:= 0, aAneQtd:={}
Private lImpPrcUn:=EasyGParam("MV_IMPPRCU",,.T.), cOrdAnexo:=EasyGParam("MV_ORDANE",,"1"), cNumAux := cNumero
Private cFilEd1:=xFilial("ED1"), cFilEd2:=xFilial("ED2"), cFilEd3:=xFilial("ED3") 
Private cFilEd4:=xFilial("ED4"), cFilEd5:=xFilial("ED5"), cFilSyd:=xFilial("SYD")
Private lSumariza := EasyGParam("MV_SUMANEE",,.T.)

If(!lAdit, ProcRegua(Len(aMarcados)), )
PA150Ordem(.T.)

For nMarca:=1 To If(!lAdit,Len(aMarcados),1)
   // Verifica os itens a exportar do Aditivo
   If lAdit .And. cTipo == "E"
            
            ED1->(DbSeek(cFilED1+cPed))
                              
            nLIN := 999
            cNCM := cItem := cUm := ""
            cAnexoExp := ED1->ED1_ANEXO
            nValTot1 := nPesoTot1:= nQtdTot1 := nSomaTot := 0
            nValCab1 := nPesoCab1:= nQtdCab1 := 0
            nTotNCMPeso := nTotNCMQtd := nTotNCMTotal:= 0
   
            // Buscar Dados do Importador, da NCM e do Produto
            SYT->(DbSeek(CFILSYT+ED0->ED0_IMPORT))             

            cCidade := SYT->YT_CIDADE
            //cNumPed := ED0->ED0_PD
   
            If Left(ED0->ED0_ANEEXP , 1) == "1" // Agrupar por Documentos/Aditivo
               
               Do While !ED1->(EOF()) .And. ED1->ED1_FILIAL == cFilEd1 .And. ED1->ED1_PD == cPed //;
                  
                  cUnMed:=ED1->ED1_UMNCM //Alcir Alves - 02-05-05
                  If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),)
                  If !ED1->ED1_ANEXO $ cNumero .Or. cTipo <> "E"
                     ED1->(dbSkip())
                     Loop
                  Endif
                  
                  If cAnexoExp <> ED1->ED1_ANEXO .or. lPVez
                     cAnexoExp := ED1->ED1_ANEXO       
                     
                     If cNCM # "" .And. lED0SubTot .AND. ED0->ED0_SUBTOT == "1"  //Imprime Subtotais (ACSJ - 18/11/2004)
                        lPVez := .F.
                        nLIN := nLIN+1
                        DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                        DET->WK_SEQREL := cSEQREL
                        DET->WK_LCS    := "B"
                        DET->WK_PED    := ED0->ED0_PD
                        DET->WKD_ITE   := STR0018 //"Total...:"
                        DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)
                        DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)
                        DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVl)
                        nTotNCMPeso  := 0
                        nTotNCMQtd   := 0
                        nTotNCMTotal := 0       
                        
                        iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cUm:=ED1->ED1_UMNCM , cUm:=ED1->ED1_UMANEX),cUm:=ED1->ED1_UMNCM) // ACSJ - 18/11/2004
                        
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     Endif
                  Endif
          
                  If cAnexoExp <> ED1->ED1_ANEXO .or. lPVez
                     If cNCM # ""
                        nLIN := nLIN+1
                        DET->(DBAPPEND()) // Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
                        DET->WK_PED    := ED0->ED0_PD                        
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                        
                        DET->WK_SEQREL := cSEQREL
                        DET->WK_LCS    := "C"
                        DET->WKD_PESO  := Transf(nPesoTot1,cPictPeso)//cPictPeTot)
                        DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
                        DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
                        nValTot1 := nPesoTot1:= nQtdTot1 := 0

                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                                      
                        DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
                        DET->WK_SEQREL := cSEQREL
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                        DET->WK_LCS    := "D"
                        DET->WK_PED    := ED0->ED0_PD
                        DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
                        DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"") //Ass. para o Pedido
                        DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")

                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     EndIf
                     
                     
                     
                     DET->(DBAPPEND())     //Grava o Cabecalho dos Anexos Principais
                     DET->WK_SEQREL  := cSEQREL
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     DET->WK_LCS     := "A"
                     DET->WKD_EXPORT := "X"
                     DET->WK_PED     := ED0->ED0_PD
                     DET->WKD_ANEXO  := cAnexoExp
                     nLIN := 0
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF,,DET->WKD_QTDE2})
                                      
                     If cNCM # ""
                        nLIN := nLIN+1
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                        DET->WK_LCS    := "B"
                        DET->WK_PED    := ED0->ED0_PD
                        DET->WKD_ITE   := Trans(ED1->ED1_NCM, cPictNcm)  //4.Item da tarifa
                        DET->WKD_QTDE  := cUnMed //Alcir Alves - 02/05/05  //  ED1->ED1_UMNCM                 //6.Quantidade
                        If lImpPrcUn
                           DET->WKD_PRE_F := STR0019 //"US$"                //9.Preco Fob
                        Else
                           DET->WKD_TOT_F := STR0019 //"US$"                //10.Total
                        EndIf
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     EndIf
                  EndIf
         
         
                  (cAliasSB1)->(DbSeek(cFilSB1Aux+ED1->ED1_PROD))
                  SYD->(DbSeek(cFilSyd+ED1->ED1_NCM))
                  If cNCM # ED1->ED1_NCM .Or. cUm <> If(Empty(ED1->ED1_UMANEX), ED1->ED1_UMNCM , ED1->ED1_UMANEX) .OR.;
                     ED1->ED1_PROD # cProd //AAF 28/07/05
                  
                     if cNCM # ED1->ED1_NCM .Or. cUm <> If(Empty(ED1->ED1_UMANEX), ED1->ED1_UMNCM , ED1->ED1_UMANEX)
                        If cNCM # "" .And. lED0SubTot .AND. ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                           nLIN := nLIN+1
                           DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                           DET->WK_SEQREL := cSEQREL
                           DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                           DET->WK_LCS    := "B"
                           DET->WK_PED    := ED0->ED0_PD
                           DET->WKD_ITE   := STR0018 //"Total...:"
                           DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)
                           DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)
                           DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVl)
   
                           AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                         DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                         DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                         DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                         DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                         DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                        EndIf
                        cNCM  := ED1->ED1_NCM
                        iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cUm:=ED1->ED1_UMNCM , cUm:=ED1->ED1_UMANEX),cUm:=ED1->ED1_UMNCM)   // ACSJ - 18/11/2004
                        nTotNCMPeso := 0
                        nTotNCMQtd  := 0
                        nTotNCMTotal:= 0
                     Endif

                     cProd := ED1->ED1_PROD
                     nLIN := nLIN+1
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD
                     DET->WKD_ITE   := Transf(ED1->ED1_NCM, cPictNcm)   //4.Item da tarifa
                     DET->WKD_QTDE  := cUnMed //Alcir Alves - 02/05/05 - ED1->ED1_UMNCM                   //6.Quantidade
                     If lImpPrcUn
                        DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB
                     Else
                        DET->WKD_TOT_F := STR0019 //"US$"                //10.Total   
                     EndIf
                     //DET->WKD_TOT_F := STR0019 
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                  EndIf
                  
                  cRegNCM    := ED1->ED1_NCM
                  dRegDtEmba := ED1->ED1_DTEMBA
                  cRegRE     := ED1->ED1_RE
                  cRegProd   := ED1->ED1_PROD
                  iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cRegUM := ED1->ED1_UMNCM, cRegUM := ED1->ED1_UMANEX),cRegUM := ED1->ED1_UMNCM)   // ACSJ - 18/11/2004
                  nRegPeso   := 0
                  nRegQtd    := 0
                  nRegPrcUn  := 0
                  nRegPrcTot := 0
                  
                  If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(ED1->ED1_PROD,"EE2_COD")))
                     cDescr         := Alltrim(ED1->ED1_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                  ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(ED1->ED1_PROD,"B1_COD")))
                     cDescr:= Alltrim(ED1->ED1_PROD)+" - "+AllTrim(SB1->B1_DESC)
                  EndIf

                  DescExp()
                  
                  Do While !ED1->(EOF()) .and. ED1->ED1_FILIAL == cFilED1 .and.;
                  ED1->ED1_PD == ED0->ED0_PD .and.;
                  iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX),ED1->ED1_UMNCM,ED1->ED1_UMANEX),ED1->ED1_UMNCM) == cRegUM .and.;   // ACSJ - 18/11/2004
                  ED1->ED1_NCM == cRegNCM .and. ED1->ED1_DTEMBA = dRegDtEmba .and.;
                  ED1->ED1_RE == cRegRE .and. ED1->ED1_PROD == cRegProd
                     nRegPeso   += ED1->ED1_PESO
                     if lED1Umanex
                        If Empty(ED1->ED1_UMANEX)
                           nRegQtd    += ED1->ED1_QTDNCM
                        Else
                           nRegQtd    += AVTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
                        EndIf                                                   
                     Else                               
                        nRegQtd    += ED1->ED1_QTDNCM
                     Endif
                     
                     nRegPrcTot += Round(ED1->ED1_VAL_EM - (ED1->ED1_VAL_EM * ED1->ED1_PERCAG )/100,2)
                     nRegPrcUn  += nRegPrcTot/nRegQtd //ED1->ED1_QTDNCM
                     If  cAnexoExp <> ED1->ED1_ANEXO
                        ED1->(RecLock("ED1",.F.))
                        ED1->ED1_ANEXO := cAnexoExp
                        ED1->(msUnlock())
                     Endif
                     ED1->(dbSkip())
                  EndDo

                  nLIN := nLIN+1
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD
                  DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
                  DET->WKD_DOC_E := Transf(cRegRE, cPicRe)                //8.Docto Comprob. Exp.
                  DET->WKD_PESO  := Transf(nRegPeso, cPictPeso)           //5.Peso Liquido
                  DET->WKD_QTDE  := Transf(nRegQtd, cPictQt)              //6.Quantidade NCM
                  nTot_F         := nRegPrcTot
                  DET->WKD_TOT_F := Transf(nTot_F, cPictVl)               //10.Total
                  If lImpPrcUn
                     DET->WKD_PRE_F := Transf(nTot_F /(ED1->ED1_QTDNCM), cPictUni)  //10.Total
                  EndIf

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                  
                  EDCPAMLCOUNT("E")

                  nTotNCMPeso += nRegPeso
                  nTotNCMQtd  += nRegQtd
                  nTotNCMTotal+= nTot_F

                  nPesoTot1+= nRegPeso
                  nQtdTot1 += nRegQtd
                  nValTot1 += nTot_F

                  nPesoCab1+= nRegPeso
                  nQtdCab1 += nRegQtd
                  nValCab1 += nTot_F

                  ED1->(DbSkip())
         
               Enddo
            ElseIf Left(ED0->ED0_ANEEXP, 1) == "2"  //Agrupar por NCM + Prod./Aditivo
                            
               ED3->(DbSeek(cFilED3+cPed))
               cAnexoExp := ED3->ED3_ANEXO
               
               Do While !ED3->(EOF()) .And. ED3->ED3_FILIAL == cFilEd3 .And. ED3->ED3_PD == cPed //;

                  cUnMed:= ED3->ED3_UMNCM
                  If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),) 
                  If !ED3->ED3_ANEXO $ cNumero .Or. cTipo <> "E"
                     ED3->(dbSkip())
                     Loop
                  Endif

                  If cAnexoExp <> ED3->ED3_ANEXO .or. lPVez
                     lPVez := .F.
                     cAnexoExp := ED3->ED3_ANEXO
                     (cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))
                     
                     If cNCM # ""                        
                        nLIN := nLIN+1 
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL                   
                        DET->WK_LCS    := "B"
                        DET->WK_PED    := ED0->ED0_PD               
                        DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso)             //5.Peso Liquido
                        DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt)                //6.Quantidade NCM
                        //DET->WKD_DISCR := Alltrim(SB1->B1_DESC)+STR0032+SB1->B1_COD  //7.Discriminacao do Produto ###" - "
                        //EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey("PORT. -PORTUGUES","EE2_IDIOMA")+AVKey(cItem,"EE2_COD")))
                        //cDescr         := Alltrim(cItem)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                                                
                        If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                           aAdd(aAneQtd,{cUMCom,nQtdIte1})
                        Else
                           aAneQtd[nPos,2] += nQtdIte1
                        EndIf
                        
                        DescExp()
                        DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
                        DET->WKD_TOT_F := Transf(nValIte1, cPictVlEm)              //10.Total
                        If lImpPrcUn
                           DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni)     //10.Total
                        EndIf
                 
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})

                        EDCPAMLCOUNT("E")
                        
                        if lED0SubTot   // ACSJ - 18/11/2004
                        
                           If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                              nLIN := nLIN+1 
                              DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                              DET->WK_SEQREL := cSEQREL                   
                              DET->WK_LCS    := "B"  
                              DET->WK_PED    := ED0->ED0_PD               
                              DET->WKD_ITE   := STR0018 //"Total...:"               
                              DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)    // Peso 
                              DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)       // Quantidade
                              DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVlEm)   // Total  

                              AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                            DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                            DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                            DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                            DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                            DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                           Endif
                        Endif
                        
                        DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL                  
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                  
                        DET->WK_LCS    := "C"
                        DET->WK_PED    := ED0->ED0_PD
                        DET->WKD_PESO  := Transf(nPesoTot1,cPictPeso) //cPictPeTot)
                        //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
                        DET->WKD_QTDE  := ""
                        DET->WKD_QTDE2 := ""
                        If Len(aAneQtd) <= 6
                           For i:=1 to Len(aAneQtd)
                              cUnAne:= aAneQtd[i,1]
                              If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                              If i<=3
                                 DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                              Else
                                 DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                              EndIf
                           Next i
                        EndIf
                        aAneQtd := {}
                        
                        DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
                        nValTot1 := nPesoTot1:= nQtdTot1 := 0
                  
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                                      
                        DET->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
                        DET->WK_SEQREL := cSEQREL
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                        DET->WK_LCS    := "D"
                        DET->WK_PED    := ED0->ED0_PD
                        DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
                        DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
                        DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     EndIf
                     DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
                     DET->WK_SEQREL  := cSEQREL
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     DET->WK_LCS     := "A"
                     DET->WKD_EXPORT := "X"
                     DET->WK_PED     := ED0->ED0_PD            
                     DET->WKD_ANEXO  := cAnexoExp 
                     nLIN := 0                        

                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     If cNCM # "" 
                        cNCM  := ED3->ED3_NCM
                        cItem := ED3->ED3_PROD
                        cUm   := ED3->ED3_UMNCM
                        nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
                        nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    
             
                        nLIN := nLIN+1                                  
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL 
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                        DET->WK_LCS    := "B"
                        DET->WK_PED    := ED0->ED0_PD            
                        DET->WKD_ITE   := Transf(ED3->ED3_NCM, cPictNcm)   //4.Item da tarifa           
                        DET->WKD_QTDE  := cUnMed //(cAliasSB1)->B1_UM                    //6.Quantidade
                        If lImpPrcUn
                           DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB    
                        Else
                           DET->WKD_TOT_F := STR0019 //"US$"                //10.Total   
                        EndIf

                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                     Endif   
                  EndIf
         
                  SYD->(DbSeek(cFilSyd+ED3->ED3_NCM))
                  If cNCM # ED3->ED3_NCM .Or. cItem # ED3->ED3_PROD .or. cUm <> ED3->ED3_UMNCM
                     If cNCM # ""          
                        (cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))                                              
                        nLIN := nLIN+1 
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL 
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8) 
                        DET->WK_LCS    := "B"
                        DET->WK_PED    := ED0->ED0_PD               
                        DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso)             //5.Peso Liquido
                        DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt)                //6.Quantidade NCM
                        //EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey("PORT. -PORTUGUES","EE2_IDIOMA")+AVKey(ED3->ED3_PROD,"EE2_COD")))
                        //cDescr         := Alltrim(ED3->ED3_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                        If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                           aAdd(aAneQtd,{cUMCom,nQtdIte1})
                        Else
                           aAneQtd[nPos,2] += nQtdIte1
                        EndIf
                        DescExp()
                        DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
                        DET->WKD_TOT_F := Transf(nValIte1, cPictVlEm)              //10.Total  	   
                        If lImpPrcUn
                           DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1, cPictUni)     //10.Total  	   
                        EndIf

                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})

                        EDCPAMLCOUNT("E")
                        
                        If lED0SubTot  // ACSJ - 18/11/2004
                           If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                              nLIN := nLIN+1 
                              DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                              DET->WK_SEQREL := cSEQREL 
                              DET->WK_SEQPED := StrZero(Val(cSEQPED),8) 
                              DET->WK_LCS    := "B"  
                              DET->WK_PED    := ED0->ED0_PD               
                              DET->WKD_ITE   := STR0018 //"Total...:"
                              DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)    // Peso 
                              DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)       // Quantidade
                              DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVlEm)   // Total  

                              AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                            DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                            DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                            DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                            DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                            DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                           Endif
                        Endif                 
                        
                        If nLIN == (NUMDELIN - 1)
                           nLIN := nLIN+1                                  
                           DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                           DET->WK_SEQREL := cSEQREL 
                           DET->WK_SEQPED := StrZero(Val(cSEQPED),8) 
                           DET->WK_LCS    := "B"                                 
                           DET->WK_PED    := ED0->ED0_PD               
                           AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                           Loop
                        Endif  

                     EndIf
                                  
                     cNCM  := ED3->ED3_NCM
                     cItem := ED3->ED3_PROD
                     cUm   := ED3->ED3_UMNCM
             
                     nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
                     nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    

                     nLIN := nLIN+1                                  
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL 
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD            
                     DET->WKD_ITE   := Transf(ED3->ED3_NCM, cPictNcm)   //4.Item da tarifa           
                     DET->WKD_QTDE  := cUnMed //(cAliasSB1)->B1_UM                   //6.Quantidade
                     If lImpPrcUn
                        DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB
                     Else
                        DET->WKD_TOT_F := STR0019 //"US$"                //10.Total   
                     EndIf
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                  Endif                                                                        
                                               
                  nTotNCMTotal+= ED3->ED3_VAL_EM
                  nTotNCMPeso += ED3->ED3_PESO
                  nTotNCMQtd  += ED3->ED3_QTDNCM
 
                  nValTot1 += ED3->ED3_VAL_EM
                  nPesoTot1+= ED3->ED3_PESO
                  nQtdTot1 += ED3->ED3_QTDNCM

                  nValIte1 += ED3->ED3_VAL_EM
                  nPesoIte1+= ED3->ED3_PESO
                  nQtdIte1 += ED3->ED3_QTDNCM
                  cUMCom   := ED3->ED3_UMNCM

                  nValCab1 += ED3->ED3_VAL_EM
                  nPesoCab1+= ED3->ED3_PESO
                  nQtdCab1 += ED3->ED3_QTDNCM
                  
                  If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(cItem,"EE2_COD")))
                     cDescr:= Alltrim(cItem)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                  ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(cItem,"B1_COD")))
                     cDescr:= Alltrim(cItem)+" - "+AllTrim(SB1->B1_DESC)
                  EndIf

                  ED3->(DbSkip())
               Enddo

            Endif                    
            
            PA150FIM("E")        
               
      //   Next nPosAnexo
      //EndIf
   ElseIf !lAdit // Verifica os itens a exportar do Pedido de Drawback
            
      ED0->(dbGoTo(aMarcados[nMarca]))
      
      IncProc(STR0008) // Atualiza barra de progresso //"Imprimindo..."
      
      Fre_Seg := ED0->ED0_FRE_S
      
      PA150Cabec()
   
      ED0->(dbGoTo(aMarcados[nMarca]))

      //Gerar 5 vias do Pedido
      cAliasAux := "DET"
      For nx := 1 To 5
          If nx>2
             cAliasAux := "DET"+Alltrim(Str(nx-1))
          EndIf
          (cAliasAux)->(DBAPPEND()) // Grava a Pagina Principal do Pedido de Drawback- "1 pag p/ cada Pedido"
          (cAliasAux)->WK_SEQREL := cSEQREL
          (cAliasAux)->WK_LCS    := "H"
          (cAliasAux)->WK_PED    := ED0->ED0_PD
          (cAliasAux)->WK_FLAG   := Alltrim(Str(nx))
      next nx

      //Imprimi o Protocolo
      DET->(DBAPPEND())
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "P"
      DET->WK_PED    := ED0->ED0_PD
      //-----Fim
      
      ED1->(DbSeek(cFilEd1+ED0->ED0_PD))
      
      nLIN := 999
      cNCM := cItem := cUM := ""
      //cAnexoExp := ED1->ED1_ANEXO
      nValTot1 := nPesoTot1:= nQtdTot1 := nSomaTot := 0
      nValCab1 := nPesoCab1:= nQtdCab1 := 0
      nTotNCMPeso := nTotNCMQtd := nTotNCMTotal:= 0
      cAnexoExp := 0

      If Left(ED0->ED0_ANEEXP , 1) == "1" // Agrupar por Documentos/Pedido de Drawback
         Do While !ED1->(Eof()) .And. ED1->ED1_FILIAL == cFilEd1 .And. ED1->ED1_PD == ED0->ED0_PD

            cUnMed:=ED1->ED1_UMNCM //Alcir Alves - 02-05-05
            If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),) 
            (cAliasSB1)->(DbSeek(cFilSB1Aux+ED1->ED1_PROD))
            
            If lPvez            
               cNcmExp:= STR0071+Transf(ED1->ED1_NCM, cPictNcm)+CHR(13)+CHR(10)+STR0072 //"N.C.M. "###"e outros conforme Anexos" TAN
            Endif

            If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(ED1->ED1_PROD,"EE2_COD")))
               cDescr:= Alltrim(ED1->ED1_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
            ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(ED1->ED1_PROD,"B1_COD")))
               cDescr:= Alltrim(ED1->ED1_PROD)+" - "+AllTrim(SB1->B1_DESC)
            EndIf
            DescExp()
            If MlCount(cDescr,TAMDESCPED)+nLIN >= NUMDELIN //.or. lPVez .or.; //cAnexoExp <> ED1->ED1_ANEXO
            //(Len(aAneQtd) = 6 .and. aScan(aAneQtd,{|x| x[1]==ED1->ED1_UMNCM}) = 0)
               
               If cNCM # "" .And. lED0SubTot .AND. ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                  nLIN := nLIN+1
                  DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais                  
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD
                  DET->WKD_ITE   := STR0018 //"Total...:"
                  DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)
                  DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)
                  DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVl)
                  nTotNCMPeso  := 0
                  nTotNCMQtd   := 0
                  nTotNCMTotal := 0
                  cNCM    := ED1->ED1_NCM
                  
                  iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cUm:=ED1->ED1_UMNCM , cUm:=ED1->ED1_UMANEX),cUm:=ED1->ED1_UMNCM)

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
               Endif
               
            Endif
    
            If MlCount(cDescr,TAMDESCPED)+nLIN >= NUMDELIN .Or. lPVez //.or.; //MlCount(Alltrim(ED1->ED1_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP),TAMDESCEXP)+nLIN > NUMDELIN
            //(Len(aAneQtd) = 6 .and. aScan(aAneQtd,{|x| x[1]==ED1->ED1_UMNCM}) = 0)
               /*If (Len(aAneQtd) = 6 .and. aScan(aAneQtd,{|x| x[1]==ED1->ED1_UMNCM}) = 0)
                  For i:=nLIN to NUMDELIN
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL 
                     If lAdit
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     Endif   
                     DET->WK_PED    := ED0->ED0_PD             
                     DET->WK_LCS    := "B"  
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
                  Next i
                  lBateBranco:=.T.
               EndIf*/
               lPVez:= .F.
               cAnexoExp += 1
               If cNCM # ""
                  nLIN := nLIN+1
                  DET->(DBAPPEND()) // Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
                  DET->WK_PED    := ED0->ED0_PD                  
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_LCS    := "C"
                  DET->WKD_PESO  := Transf(nPesoTot1,cPictPeTot)
                  DET->WKD_QTDE  := ""
                  DET->WKD_QTDE2 := ""
                  If Len(aAneQtd) <= 6
                     For i:=1 to Len(aAneQtd)
                        cUnAne:= aAneQtd[i,1]
                        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                        If i<=3
                           DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                        Else
                           DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                        EndIf
                     Next i
                  EndIf
                  aAneQtd := {}
                  //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
                  DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
                  nValTot1 := nPesoTot1:= nQtdTot1 := 0

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})

                  DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_LCS    := "D"
                  DET->WK_PED    := ED0->ED0_PD
                  DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
                  DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
                  DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
               EndIf
               DET->(DBAPPEND())     //Grava o Cabecalho dos Anexos Principais
               DET->WK_SEQREL  := cSEQREL                     
               DET->WK_LCS     := "A"
               DET->WKD_EXPORT := "X"
               DET->WK_PED     := ED0->ED0_PD
               DET->WKD_ANEXO  := StrZero(cAnexoExp,3)
               DET->WK_FLAG    := "1"
               nLIN := 0

               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_QTDE2})
               /*  NCCF 11/02/09
               If cNCM # "" .and. !lBateBranco
                  nLIN := nLIN+1
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL                        
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD
                  DET->WKD_ITE   := Trans(ED1->ED1_NCM, cPictNcm)  //4.Item da tarifa
                                    
                  if lED1Umanex   // ACSJ - 18/11/2004
                     If Empty(ED1->ED1_UMANEX)
                        DET->WKD_QTDE  := cUnMed  //Alcir Alves - 02/05/05   //ED1->ED1_UMNCM              //6.UM
                     Else
                        DET->WKD_QTDE  := ED1->ED1_UMANEX             //6.UM
                     EndIf
                  Else
                     DET->WKD_QTDE  := ED1->ED1_UMNCM                 //6.UM
                  Endif                  
                                    
                  If lImpPrcUn
                     DET->WKD_PRE_F := STR0019  //                //9.Preco Fob
                  Else
                     DET->WKD_TOT_F := STR0019  //                //10.Total
                  Endif
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
               EndIf*/
               lBateBranco:=.F.
            EndIf
         
            (cAliasSB1)->(DbSeek(cFilSB1Aux+ED1->ED1_PROD))
            SYD->(DbSeek(cFilSyd+ED1->ED1_NCM))
            If cNCM # ED1->ED1_NCM .or. cUm <> iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), ED1->ED1_UMNCM , ED1->ED1_UMANEX),ED1->ED1_UMNCM) .OR.;  // ACSJ - 18/11/2004            
               cProd # ED1->ED1_PROD
               
               If cNCM # ED1->ED1_NCM .or. cUm <> iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), ED1->ED1_UMNCM , ED1->ED1_UMANEX),ED1->ED1_UMNCM)
                  If(cNCM # "" , lImpNCM := .T. ,)
            
                  If cNCM # "" .And. lED0SubTot .AND. ED0->ED0_SUBTOT == "1" //Imprime Subtotais (ACSJ - 18/11/2004)
                     nLIN := nLIN+1
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                        
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD
                     DET->WKD_ITE   := STR0018 //"Total...:"
                     DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)
                     DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)
                     DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVl)
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_QTDE2})
                  EndIf
               
                  cNCM := ED1->ED1_NCM
               
                  iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cUm:=ED1->ED1_UMNCM , cUm:=ED1->ED1_UMANEX),cUm:=ED1->ED1_UMNCM)
                  nTotNCMPeso := 0
                  nTotNCMQtd  := 0
                  nTotNCMTotal:= 0
               Endif
               cProd:= ED1->ED1_PROD

               nLIN := nLIN+1
               DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
               DET->WK_SEQREL := cSEQREL
                     
               DET->WK_LCS    := "B"
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_ITE   := Transf(ED1->ED1_NCM, cPictNcm)   //4.Item da tarifa
               
               if lED1Umanex   // ACSJ -18/11/2004
                  If Empty(ED1->ED1_UMANEX)
                     DET->WKD_QTDE  := cUnMed//AAF 11/07/05 - Un. Medida //ED1->ED1_UMNCM                   //6.Quantidade
                  Else
                     DET->WKD_QTDE  := ED1->ED1_UMANEX                   //6.Quantidade
                  EndIf                   
               Else
                  DET->WKD_QTDE  := ED1->ED1_UMNCM                   //6.Quantidade
               Endif
               
               If lImpPrcUn
                  DET->WKD_PRE_F := STR0019  //"US$"  9.Preco FOB
               Else
                  DET->WKD_TOT_F := STR0019  //"US$"  10.Total
               Endif
 
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
            EndIf

            cRegNCM    := ED1->ED1_NCM
            dRegDtEmba := ED1->ED1_DTEMBA
            cRegRE     := ED1->ED1_RE
            cRegProd   := ED1->ED1_PROD
            iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX), cRegUM := ED1->ED1_UMNCM, cRegUM := ED1->ED1_UMANEX),cRegUM := ED1->ED1_UMNCM)   // ACSJ - 18/11/2004
            nRegPeso   := 0
            nRegQtd    := 0
            nRegPrcUn  := 0
            nRegPrcTot := 0

            If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(ED1->ED1_PROD,"EE2_COD")))
               cDescr := Alltrim(ED1->ED1_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
            ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(ED1->ED1_PROD,"B1_COD")))
               cDescr:= Alltrim(ED1->ED1_PROD)+" - "+AllTrim(SB1->B1_DESC)
            EndIf

            DescExp()

            Do While !ED1->(EOF()) .and. ED1->ED1_FILIAL == cFilED1 .and.;
            ED1->ED1_PD == ED0->ED0_PD .and.;
            iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX),ED1->ED1_UMNCM,ED1->ED1_UMANEX),ED1->ED1_UMNCM) == cRegUM .and.;   // ACSJ - 18/11/2004
            ED1->ED1_NCM == cRegNCM .and. ED1->ED1_PROD == cRegProd .AND.;
            If(!lSumariza, ED1->ED1_DTEMBA=dRegDtEmba .and. ED1->ED1_RE==cRegRE, .T.)//AAF 21/07/05 - Sumarização desconsiderando RE.
            
               nRegPeso   += ED1->ED1_PESO
               
               if lED1Umanex   // ACSJ - 18/11/2004
                  If Empty(ED1->ED1_UMANEX)
                     nRegQtd    += ED1->ED1_QTDNCM
                  Else
                     nRegQtd    += AVTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
                  EndIf
               Else 
                  nRegQtd    += ED1->ED1_QTDNCM
               Endif
               nRegPrcTot += Round(ED1->ED1_VAL_EM - (ED1->ED1_VAL_EM * ED1->ED1_PERCAG )/100,2)
               nRegPrcUn  += nRegPrcTot/nRegQtd //ED1->ED1_QTDNCM
               If  StrZero(cAnexoExp,3) <> ED1->ED1_ANEXO
                  ED1->(RecLock("ED1",.F.))
                  ED1->ED1_ANEXO := StrZero(cAnexoExp,3)
                  ED1->(msUnlock())
               Endif
               ED1->(dbSkip())
            EndDo            
            
            nLIN := nLIN+1
            DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
            DET->WK_SEQREL := cSEQREL
            DET->WK_LCS    := "B"
            DET->WK_PED    := ED0->ED0_PD
            DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
            If !lSumariza //AAF 21/07/05
               DET->WKD_DOC_E := Transf(cRegRE, cPicRe)                //8.Docto Comprob. Exp.
            Endif
            DET->WKD_PESO  := Transf(nRegPeso, cPictPeso)           //5.Peso Liquido
            DET->WKD_QTDE  := Transf(nRegQtd, cPictQt)              //6.Quantidade NCM
            If (nPos:=aScan(aAneQtd,{|x| x[1]==cRegUM})) = 0
               aAdd(aAneQtd,{cRegUM,nRegQtd})
            Else
               aAneQtd[nPos,2] += nRegQtd
            EndIf
            nTot_F         := nRegPrcTot
            DET->WKD_TOT_F := Transf(nTot_F, cPictVl)               //10.Total
            If(lImpPrcUn,DET->WKD_PRE_F := Transf(nTot_F / nRegQtd, cPictUni),)    //10.Total

            AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                          DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                          DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                          DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                          DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                          DET->WKD_VALEMB,DET->WKD_NF})

            EDCPAMLCOUNT("E")
           
            nTotNCMPeso += nRegPeso
            nTotNCMQtd  += nRegQtd
            nTotNCMTotal+= nTot_F
         
            nPesoTot1+= nRegPeso
            nQtdTot1 += nRegQtd
            nValTot1 += nTot_F

            nPesoCab1+= nRegPeso
            nQtdCab1 += nRegQtd
            If (nPos:=aScan(aAneQtdTot,{|x| x[1]==cRegUM})) = 0
               aAdd(aAneQtdTot,{cRegUM,nRegQtd})
            Else
               aAneQtdTot[nPos,2] += nRegQtd
            EndIf
            nValCab1 += nTot_F
                  
         Enddo
      ElseIf Left(ED0->ED0_ANEEXP, 1) == "2"  //Agrupar por NCM + Prod./Pedido de Drawback
         ED3->(DbSeek(cFilED3+ED0->ED0_PD))

         ED1->(dbSetOrder(1))
         EE9->(DbSetOrder(2))

         cAnexoExp := 0
         
         Do While !ED3->(Eof()) .And. ED3->ED3_FILIAL == cFilEd3 .And. ED3->ED3_PD == ED0->ED0_PD

            //AAF 22/07/05 - Unidade de Medida
            cUnMed:=ED3->ED3_UMNCM //Alcir Alves - 02-05-05
            If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),) 
            (cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))
            
            If lPvez
               cNcmExp:= STR0071+Transf(ED3->ED3_NCM, cPictNcm) //"N.C.M. " TAN
            Endif

            If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(ED3->ED3_PROD,"EE2_COD")))
               cDescr         := Alltrim(ED3->ED3_PROD)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
            ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(ED3->ED3_PROD,"B1_COD")))
               cDescr:= Alltrim(ED3->ED3_PROD)+" - "+AllTrim(SB1->B1_DESC)
            EndIf

            DescExp()
            If MlCount(cDescr,TAMDESCPED)+nLIN >= NUMDELIN .or. lPVez .or.;//cAnexoExp <> ED3->ED3_ANEXO
            (Len(aAneQtd) = 5 .and. aScan(aAneQtd,{|x| x[1]==cUMCom}) = 0)
               If (Len(aAneQtd) = 5 .and. aScan(aAneQtd,{|x| x[1]==cUMCom}) = 0)
                  lBateBranco:=.T.
               EndIf
               lPVez := .F.
               cAnexoExp += 1 //ED3->ED3_ANEXO
               //(cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))
               If cNCM # ""

                  If !lLoop
                     nLIN := nLIN+1 
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                   
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD               
                     DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso)             //5.Peso Liquido
                     DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt)                //6.Quantidade NCM
                     If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                        aAdd(aAneQtd,{cUMCom,nQtdIte1})
                     Else
                        aAneQtd[nPos,2] += nQtdIte1
                     EndIf
                     //DET->WKD_DISCR := Alltrim(SB1->B1_DESC)+STR0032+SB1->B1_COD  //7.Discriminacao do Produto ###" - "
                     If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(cItem,"EE2_COD")))
                        cDescr         := Alltrim(cItem)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                     ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(ED1->ED1_PROD,"B1_COD")))
                        cDescr:= Alltrim(ED1->ED1_PROD)+" - "+AllTrim(SB1->B1_DESC)
                     EndIf
   
                     DescExp()
                     DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
                     DET->WKD_TOT_F := Transf(nValIte1, cPictVlEm)              //10.Total
                     If lImpPrcUn
                        DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni)     //10.Total  	   
                     EndIf

                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF})

                     EDCPAMLCOUNT("E")
                     
                     If lBateBranco
                        lBateBranco:=.F.
                        k:= 1                               // NCCF 17/02/09
                        For i:=nLIN to NUMDELIN
                            DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                            DET->WK_SEQREL := cSEQREL 
                            If lAdit
                               DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                            Endif   
                            DET->WK_PED    := ED0->ED0_PD             
                            DET->WK_LCS    := "B"  
                            
                            If k/2 == int(k/2)              // NCCF 17/02/09
                               DET->WKD_DOC_E := "SUPRIMIR"
                            EndIf
                            k++
                            
                            AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                          DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                          DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                          DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                          DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
                        Next i
                     EndIf
                     
                     if lED0SubTot   // ACSJ - 18/11/2004
                  
                        If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                           nLIN := nLIN+1 
                           DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                           DET->WK_SEQREL := cSEQREL                   
                           DET->WK_LCS    := "B"  
                           DET->WK_PED    := ED0->ED0_PD               
                           DET->WKD_ITE   := STR0018 //"Total...:"               
                           DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)    // Peso 
                           DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)       // Quantidade
                           DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVlEm)   // Total  

                           AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                         DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                         DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                         DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                         DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                         DET->WKD_VALEMB,DET->WKD_NF})
                        Endif
                     Endif    
                  Else
                     lLoop := .F.
                  EndIf
               
                  DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_LCS    := "C"
                  DET->WK_PED    := ED0->ED0_PD
                  DET->WKD_PESO  := Transf(nPesoTot1,cPictPeTot)
                  //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
                  DET->WKD_QTDE  := ""
                  DET->WKD_QTDE2 := ""
                  If Len(aAneQtd) <= 6
                     For i:=1 to Len(aAneQtd)
                        cUnAne:= aAneQtd[i,1]
                        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                        If i<=3
                           DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                        Else
                           DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                        EndIf
                     Next i
                  EndIf
                  aAneQtd := {}
                  DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
                  nValTot1 := nPesoTot1:= nQtdTot1 := 0
                  cNCM := ED3->ED3_NCM

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF})

                  DET->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
                  DET->WK_SEQREL := cSEQREL
                  DET->WK_LCS    := "D"
                  DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
                  DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
                  DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
                  DET->WK_PED    := ED0->ED0_PD
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF})
               EndIf
            
               DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
               DET->WK_SEQREL  := cSEQREL            
               DET->WK_LCS     := "A"
               DET->WKD_EXPORT := "X"
               DET->WK_PED     := ED0->ED0_PD            
               DET->WKD_ANEXO  := StrZero(cAnexoExp,3)
               DET->WK_FLAG    := "1"
               nLIN := 0                        
                
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
               /*   //NCCF 11/02/09              
               If cNCM # ""
                  cNCM  := ED3->ED3_NCM
                  cItem := ED3->ED3_PROD
                  cUM   := ED3->ED3_UMNCM
                  nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
                  nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    
             
                  nLIN := nLIN+1                                  
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL 
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD            
                  DET->WKD_ITE   := Transf(ED3->ED3_NCM, cPictNcm)   //4.Item da tarifa
                  DET->WKD_QTDE  := cUnMed //(cAliasSB1)->B1_UM                   //6.Quantidade
                  If lImpPrcUn
                     DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB                     
                  Else
                     DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total
                  EndIf

                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
               Endif   */
            EndIf
            
            If  StrZero(cAnexoExp,3) <> ED3->ED3_ANEXO
               ED3->(RecLock("ED3",.F.))
               ED3->ED3_ANEXO := StrZero(cAnexoExp,3)
               ED3->(msUnlock())
            Endif

            SYD->(DbSeek(cFilSYD+ED3->ED3_NCM))
            If cNCM # ED3->ED3_NCM .Or. cItem # ED3->ED3_PROD .or. cUM <> ED3->ED3_UMNCM
               If cNCM # ""
                  If(cNCM # ED3->ED3_NCM, lImpNCM := .T. , )
                  (cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))                                              
                  nLIN := nLIN+1 
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL                   
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD               
                  DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso)             //5.Peso Liquido
                  DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt)                //6.Quantidade NCM
                  If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                     aAdd(aAneQtd,{cUMCom,nQtdIte1})
                  Else
                     aAneQtd[nPos,2] += nQtdIte1
                  EndIf
                  If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(cItem,"EE2_COD")))
                     cDescr         := Alltrim(cItem)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
                  ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(cItem,"B1_COD")))
                     cDescr:= Alltrim(cItem)+" - "+AllTrim(SB1->B1_DESC)
                  EndIf
                 
                  DescExp()
                  DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
                  DET->WKD_TOT_F := Transf(nValIte1, cPictVlEm)              //10.Total
                  If lImpPrcUn
                     DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni)       //10.Total
                  EndIf
                 
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF})

                  EDCPAMLCOUNT("E")
                                    
                  if lED0SubTot // ACSJ - 18/11/2004
                  
                     If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                        nLIN := nLIN+1 
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL                   
                        DET->WK_LCS    := "B"  
                        DET->WK_PED    := ED0->ED0_PD               
                        DET->WKD_ITE   := STR0018 //"Total...:"               
                        DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso)    // Peso 
                        DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt)       // Quantidade
                        DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictVlEm)   // Total  
        
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF})
                     Endif                 
                     
                  Endif
                                
                  If nLIN == (NUMDELIN - 1)
                     nLIN := nLIN+1                                  
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                      
                     DET->WK_LCS    := "B"                                 
                     DET->WK_PED    := ED0->ED0_PD               
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF})
                     lLoop := .T.
                     Loop
                  Endif  

               EndIf
                                  
               cNCM  := ED3->ED3_NCM
               cItem := ED3->ED3_PROD
               cUM   := ED3->ED3_UMNCM
             
               nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
               nValIte1 := nPesoIte1:= nQtdIte1 := 0

               nLIN := nLIN+1
                           
               //If (NUMDELIN - nLIN) >= 2  //TAN
               DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
               DET->WK_SEQREL := cSEQREL                
               DET->WK_LCS    := "B"
               DET->WK_PED    := ED0->ED0_PD            
               DET->WKD_ITE   := Transf(ED3->ED3_NCM, cPictNcm)   //4.Item da tarifa           
               DET->WKD_QTDE  := cUnMed //(cAliasSB1)->B1_UM                   //6.Quantidade
               If lImpPrcUn
                  DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB
               Else
                  DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total   
               EndIf

               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
            Endif         
            
            nTotNCMTotal+= ED3->ED3_VAL_EM
            nTotNCMPeso += ED3->ED3_PESO
            nTotNCMQtd  += ED3->ED3_QTDNCM
 
            nValTot1 += ED3->ED3_VAL_EM
            nPesoTot1+= ED3->ED3_PESO
            nQtdTot1 += ED3->ED3_QTDNCM

            nValIte1 += ED3->ED3_VAL_EM
            nPesoIte1+= ED3->ED3_PESO
            nQtdIte1 += ED3->ED3_QTDNCM
            cUMCom   := ED3->ED3_UMNCM

            nValCab1 += ED3->ED3_VAL_EM
            nPesoCab1+= ED3->ED3_PESO
            nQtdCab1 += ED3->ED3_QTDNCM
            If (nPos:=aScan(aAneQtdTot,{|x| x[1]==ED3->ED3_UMNCM})) = 0
               aAdd(aAneQtdTot,{ED3->ED3_UMNCM,ED3->ED3_QTDNCM})
            Else
               aAneQtdTot[nPos,2] += ED3->ED3_QTDNCM
            EndIf
      
            ED3->(DbSkip())
         Enddo
      Endif                    
              
      PA150FIM("E")
      
      cAliasCab := "CAB"
      
      For nx:= 1 To 4
         If nx>1
            cAliasCab := "CAB"+Alltrim(Str(nx))
         EndIf
         
         (cAliasCab)->WK_TOTPES1 := Transf(nPesoCab1,cPictPeTot)          //25.Total
         //(cAliasCab)->WK_TOTQTD1 := Transf(nQtdCab1,cPictQtde)            //26.Total
         If Len(aAneQtdTot) <= 6
            For i:=1 to Len(aAneQtdTot)
               cUnAne:= aAneQtdTot[i,1]
               If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
               If i<=2
                  (cAliasCab)->WK_TOTQTD1:= Alltrim((cAliasCab)->WK_TOTQTD1)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
               ElseIf i>2 .and. i<=4
                  (cAliasCab)->WK_TOTQTD := Alltrim((cAliasCab)->WK_TOTQTD)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
               Else
                  (cAliasCab)->WK_TOTQT  := Alltrim((cAliasCab)->WK_TOTQT)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
               EndIf
            Next i
         Else
            PA150AneQtd("E",nx)  // TLM 28/03/2008 Incluído o parâmetro nx na chamada da função PA150AneQtd()
         EndIf
         
         (cAliasCab)->WK_TOTFOB1 := Transf(nValCab1,cPictFob)             //27.Total
         (cAliasCab)->WK_FOBEXT1 := "("+StrTran(EXTENSO(nValCab1 ,.F.),"REAIS",If(nValCab1<2,cDolar,cDolares))+")"
         
         // AST - 05/05/09 - Solicitação 3M, primeira letra maiuscula, resto minuscula
         //(cAliasCab)->WK_FOBEXT1 := "("+StrTran(EXTENSO(nValCab1 ,.F.),"REAIS",If(nValCab1<2,cDolar,cDolares))+")"
         cExtenso := Alltrim(StrTran(EXTENSO(nValCab1 ,.F.),"REAIS",If(nValCab1<2,cDolar,cDolares)))
         cExtenso := SubStr(cExtenso,1,1)+Lower(subStr(cExtenso,2,len(cExtenso)))
         IF "eua" $ cExtenso
            cExtenso1 := Substr(cExtenso,1,At("eua", cExtenso)-1)
            cExtenso2 := "EUA " + Substr(cExtenso,At("eua", cExtenso) + 4,LEN(cExtenso))
            cExtenso := cExtenso1 + cExtenso2
         ENDIF
          
         (cAliasCab)->WK_FOBEXT1 := "("+cExtenso+")"
         
         //If lImpNCM// .AND. Left(ED0->ED0_ANEEXP, 1) == "2"                 // NCCF 17/02/09
            //(cAliasCab)->WK_NCMEXP  := cNcmExp+CHR(13)+CHR(10)+STR0072 //"e outros conforme Anexos"
            nAnexos_E := if(ValType(cAnexoExp) <> "N",Val(cAnexoExp),cAnexoExp)
            (cAliasCab)->WK_NCMEXP := if(nAnexos_E > 1,"VIDE ANEXOS"+CHR(13)+CHR(10)+"001 À "+StrZero(cAnexoExp,3),"VIDE ANEXO 001")
            //(cAliasCab)->WK_NCMEXP :=    */                                 // NCCF 17/02/09
         //EndIf
         
      Next nx 
   
   Endif
      
   // Verifica os itens a Importar
   lPVez := .T.

   If lAdit .And. cTipo == "I"
      // Buscar Dados do Importador, da NCM e do Produto
      SYT->(DbSeek(CFILSYT+ED0->ED0_IMPORT))             

      cCidade := SYT->YT_CIDADE
      //cNumPed := ED0->ED0_PD
      
      AneAditImp()
         
   ElseIf !lAdit

      ED4->(DbSeek(cFilEd4+ED0->ED0_PD))
         
      nLIN := 999
      cNCM := cItem := cUm := ""
      cAnexoImp := cAnexoExp //ED4->ED4_ANEXO 
      nValTot1 := nPesoTot1:= nQtdTot1 := nSomaTot := 0
      nValCab1 := nPesoCab1:= nQtdCab1 := 0      
      nValIte1 := nPesoIte1:= nQtdIte1 := 0            
      cFilSW7:= xFilial("SW7")
      nTotNCMPeso := nTotNCMQtd := nTotNCMTotal:= 0
      aAneQtd:={}
      aAneQtdTot := {}
      lImpNCM := .F.

      Do While !ED4->(Eof()) .And. ED4->ED4_FILIAL == cFilEd4 .And. ED4->ED4_PD == ED0->ED0_PD
         
         cUnMed:= ED4->ED4_UMNCM
         If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),) //AAF 21/07/05
         ED2->(dbSetOrder(1))
         SW8->(DbSetOrder(6))
         SW7->(dbSetOrder(4))

         SB1->(DbSeek(cFilSB1+ED4->ED4_ITEM))

         If lPvez
            cNcmImp:= STR0071+Transf(ED4->ED4_NCM, cPictNcm2)  //"N.C.M. " TAN
         Endif

         cDescricao := Alltrim(ED4->ED4_ITEM)+" - "
         DescImp()
        /*                           // NCCF 17/02/09
         cDescricao2 := cDescricao
         
         ED4->(dbSkip())
         
         If !ED4->(Eof()) .And. ED4->ED4_FILIAL == cFilEd4 .And. ED4->ED4_PD == ED0->ED0_PD
            cDescricao := Alltrim(ED4->ED4_ITEM)+" - "
            DescImp()         
         Else
            cDescricao := ""
         EndIf
         
         ED4->(dbSkip(-1))
         
         cDescricao3 := cDescricao
         cDescricao  := cDescricao2
         cDescricao2 := cDescricao3
        */ 
         If (MlCount(cDescricao,TAMDESCPED)+MlCount(cDescricao2,TAMDESCPED)+nLIN >= NUMDELIN .or. lPVez .or.;
         (Len(aAneQtd) = 5 .and. aScan(aAneQtd,{|x| x[1]==cUMCom}) = 0)) .and. (cNCM # ED4->ED4_NCM .or. cItem # ED4->ED4_ITEM .Or. cUm # ED4->ED4_UMNCM)//cAnexoImp <> ED4->ED4_ANEXO
            /* // NCCF 17/02/09
            If (Len(aAneQtd) = 5 .and. aScan(aAneQtd,{|x| x[1]==cUMCom}) = 0)
               lBateBranco:=.T.
            EndIf
            */
            lBateBranco:=.T.
            cAnexoImp += 1  //ED4->ED4_ANEXO
            lPVez := .F.
            If cNCM # ""
               If !lLoop
                  nLIN := nLIN+1 
                  SB1->(DbSeek(cFilSb1+cItem)) 
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL                      
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD               
                  //DET->WKD_DISCR := Alltrim(SB1->B1_DESC)+STR0032+SB1->B1_COD   //7.Discriminacao do Produto ###" - "
                  cDescricao := Alltrim(cItem)+" - "
                  DescImp()
                  DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,1)) 
                  DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso2)             //5.Peso Liquido
                  DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt2)                //6.Quantidade NCM
                  If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                     aAdd(aAneQtd,{cUMCom,nQtdIte1})
                  Else
                     aAneQtd[nPos,2] += nQtdIte1
                  EndIf
                  DET->WKD_TOT_F := Transf(nValIte1, cPictValor)              //10.Total  	   
                  If(lImpPrcUn, DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni),) //9.Preco FOB 	   
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                DET->WKD_VALEMB,DET->WKD_NF})
                                
                  EDCPAMLCOUNT("I")

                  If lBateBranco
                     lBateBranco:=.F.
                     k:=1                                                 // NCCF 17/02/09
                     For i:=nLIN to NUMDELIN
                         DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                         DET->WK_SEQREL := cSEQREL 
                         If lAdit
                            DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                         Endif   
                         DET->WK_PED    := ED0->ED0_PD             
                         DET->WK_LCS    := "B"  
                         
                         If k/2 == int(k/2)                              // NCCF 17/02/09 
                            DET->WKD_DOC_E := "SUPRIMIR"
                         EndIf
                         k++                         
                         
                         AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                       DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                       DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                       DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                       DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
                     Next i
                  EndIf
                  
                  if lED0SubTot   // ACSJ - 18/11/2004

                     If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                        nLIN := nLIN+1 
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL 
                        DET->WK_LCS    := "B"  
                        DET->WK_PED    := ED0->ED0_PD               
                        DET->WKD_ITE   := STR0018 //"Total...:"               
                        DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso2)
                        DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt2)
                        DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictValor)
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                      DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                      DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                      DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                      DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                      DET->WKD_VALEMB,DET->WKD_NF})
                     Endif
                     
                  Endif
                  
               Else
                  lLoop := .F.
               EndIf   
            
               DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
               DET->WK_SEQREL := cSEQREL
               DET->WK_LCS    := "C"
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_PESO  := Transf(nPesoTot1,cPictPeTot)
               //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
               DET->WKD_QTDE  := ""
               DET->WKD_QTDE2 := ""
               If Len(aAneQtd) <= 6
                  For i:=1 to Len(aAneQtd)
                     cUnAne:= aAneQtd[i,1]
                     If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                     If i<=3
                        DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                     Else
                        DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                     EndIf
                  Next i
               EndIf
               aAneQtd := {}
               DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
               nValTot1 := nPesoTot1:= nQtdTot1 := 0
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
                             
               DET->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
               DET->WK_SEQREL := cSEQREL 
               DET->WK_LCS    := "D"
               DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
               DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
               DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
               DET->WK_PED    := ED0->ED0_PD
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})

            EndIf                                    
                  
            DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
            DET->WK_SEQREL  := cSEQREL                  
            DET->WK_LCS     := "A"
            DET->WKD_PORIMP := "X"
            DET->WK_PED     := ED0->ED0_PD            
            DET->WKD_ANEXO  := StrZero(cAnexoImp,3)
            DET->WK_FLAG    := "1"
            nLIN := 0                        
            AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
            // NCCF 25/02/10 - desnopado             
            If cNCM # "" 
               cNCM  := ED4->ED4_NCM
               cItem := ED4->ED4_ITEM
               cUm   := cUnMed
               nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
               nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    

               nLIN := nLIN+1                                  
               DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
               DET->WK_SEQREL := cSEQREL                      
               DET->WK_LCS    := "B"
               DET->WK_PED    := ED0->ED0_PD            
               DET->WKD_ITE   := Transf(ED4->ED4_NCM, cPictNcm2)   //4.Item da tarifa           
               DET->WKD_QTDE  := cUnMed //SB1->B1_UM                    //6.Quantidade
               If lImpPrcUn
                  DET->WKD_PRE_F := STR0019  //"US$"                 //9.Preco FOB
               Else
                  DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total   
               Endif   
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
            Endif // NCCF 17/02/09
         EndIf
         
         If  StrZero(cAnexoImp,3) <> ED4->ED4_ANEXO
            ED4->(RecLock("ED4",.F.))
            ED4->ED4_ANEXO := StrZero(cAnexoImp,3)
            ED4->(msUnlock())
         Endif
                  
         SYD->(DbSeek(cFilSyd+ED4->ED4_NCM))
         If cNCM # ED4->ED4_NCM .or. cItem # ED4->ED4_ITEM .Or. cUm # ED4->ED4_UMNCM
            If cNCM # ""
               If(cNCM # ED4->ED4_NCM , lImpNCM:=.T. ,)
               nLIN := nLIN+1 
               SB1->(DbSeek(cFilSb1+cItem)) 
               DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
               DET->WK_SEQREL := cSEQREL                      
               DET->WK_LCS    := "B"
               DET->WK_PED    := ED0->ED0_PD
               cDescricao     := Alltrim(cItem)+" - "
               DescImp()
               DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,1)) 
               DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso2)             //5.Peso Liquido
               DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt2)                //6.Quantidade NCM
               If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                  aAdd(aAneQtd,{cUMCom,nQtdIte1})
               Else
                  aAneQtd[nPos,2] += nQtdIte1
               EndIf
               DET->WKD_TOT_F := Transf(nValIte1, cPictValor)              //10.Total
               If(lImpPrcUn, DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni),)        //9.Preco FOB 	   
               AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})

               EDCPAMLCOUNT("I")
               
               if lED0SubTot   // ACSJ - 18/11/2004
               
                  If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                     nLIN := nLIN+1 
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL 
                     DET->WK_LCS    := "B"  
                     DET->WK_PED    := ED0->ED0_PD               
                     DET->WKD_ITE   := STR0018 //"Total...:"               
                     DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso2)
                     DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt2)
                     DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictValor)
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF})
                  Endif         
                  
               Endif              
               
               If nLIN == (NUMDELIN - 1)
                  nLIN := nLIN+1
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                  DET->WK_SEQREL := cSEQREL                      
                  DET->WK_LCS    := "B"                                 
                  DET->WK_PED    := ED0->ED0_PD               
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
                  lLoop := .T.
                  Loop
               Endif  

            EndIf
                                  
            cNCM  := ED4->ED4_NCM
            cItem := ED4->ED4_ITEM
            cUm   := ED4->ED4_UMNCM
            nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
            nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    
            
            nLIN := nLIN+1                                  
            
            DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais  
            DET->WK_SEQREL := cSEQREL                            
            DET->WK_LCS    := "B"
            DET->WK_PED    := ED0->ED0_PD            
            DET->WKD_ITE   := Transf(ED4->ED4_NCM, cPictNcm2)      //4.Item da tarifa           
            DET->WKD_QTDE  := cUnMed //SB1->B1_UM                       //6.Quantidade
            If lImpPrcUn
               DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB
            Else
               DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total
            Endif   

            AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                          DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                          DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                          DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                          DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                          DET->WKD_VALEMB,DET->WKD_NF})
         Endif

         If lED0Deduzp .AND. ED0->ED0_DEDUZP == "1" .AND. ED4->ED4_QTD<>ED4->ED4_QTDCAL
            nCoef    := Round(ED4->ED4_QTDCAL / ED4->ED4_QTD,2)
            
            nTotNCMPeso += If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
            nTotNCMQtd  += ED4->ED4_QTDNCM * nCoef
            nTotNCMTotal+= ED4->ED4_VALCAL
          
            nPesoTot1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
            nQtdTot1 += ED4->ED4_QTDNCM * nCoef
            nValTot1 += ED4->ED4_VALCAL
                  
            nPesoIte1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
            nQtdIte1 += ED4->ED4_QTDNCM * nCoef
            nValIte1 += ED4->ED4_VALCAL
            
            nPesoCab1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
            nQtdCab1 += ED4->ED4_QTDNCM * nCoef
            If (nPos:=aScan(aAneQtdTot,{|x| x[1]==ED4->ED4_UMNCM})) = 0
               aAdd(aAneQtdTot,{ED4->ED4_UMNCM,ED4->ED4_QTDNCM*nCoef})
            Else
               aAneQtdTot[nPos,2] += ED4->ED4_QTDNCM * nCoef
            EndIf
            nValCab1 += ED4->ED4_VALCAL
         Else
            nTotNCMPeso += If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
            nTotNCMQtd  += ED4->ED4_QTDNCM
            nTotNCMTotal+= ED4->ED4_VALEMB
          
            nPesoTot1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
            nQtdTot1 += ED4->ED4_QTDNCM
            nValTot1 += ED4->ED4_VALEMB
                  
            nPesoIte1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
            nQtdIte1 += ED4->ED4_QTDNCM
            nValIte1 += ED4->ED4_VALEMB
            
            nPesoCab1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
            nQtdCab1 += ED4->ED4_QTDNCM
            If (nPos:=aScan(aAneQtdTot,{|x| x[1]==ED4->ED4_UMNCM})) = 0
               aAdd(aAneQtdTot,{ED4->ED4_UMNCM,ED4->ED4_QTDNCM})
            Else
               aAneQtdTot[nPos,2] += ED4->ED4_QTDNCM
            EndIf
            nValCab1 += ED4->ED4_VALEMB
         EndIf
         cUMCom   := ED4->ED4_UMNCM

         ED4->(DbSkip())
      Enddo     

      PA150FIM("I")
      cAliasCab := "CAB"

      For nx:= 1 To 5
         If nx>2
            cAliasCab := "CAB"+Alltrim(Str(nx-1))
         EndIf
         
         IF  (cAliasCab)->WK_OPCAO = "1"
            nSomaTot := nValCab1// +Val(strtran(strtran((cAliasCab)->WK_FRETE,".",""),",","."))+Val(strtran(strtran((cAliasCab)->WK_SEGURO,".",""),",",".")) //AAF 17/05/05 - Valor sem frete e seguro.
            (cAliasCab)->WK_TOTALG  := Transf(nSomaTot,cPictFob)            //Mercadorias Diversas
            // AST - 05/05/09 - Solicitação 3M, primeira letra maiuscula, resto minuscula
            //(cAliasCab)->WK_FOBEXT2 := "("+StrTran(EXTENSO(nSomaTot ,.F.),"REAIS",If(nSomaTot<2,cDolar,cDolares))+")"            
            cExtenso := Alltrim(StrTran(EXTENSO(nSomaTot ,.F.),"REAIS",If(nSomaTot<2,cDolar,cDolares)))
            cExtenso := SubStr(cExtenso,1,1)+Lower(subStr(cExtenso,2,len(cExtenso)))
            IF "eua" $ cExtenso
               cExtenso1 := Substr(cExtenso,1,At("eua", cExtenso)-1)
               cExtenso2 := "EUA " + Substr(cExtenso,At("eua", cExtenso) + 4,LEN(cExtenso))
               cExtenso := cExtenso1 + cExtenso2
            ENDIF 
            (cAliasCab)->WK_FOBEXT2 := "("+cExtenso+")"
            
            
            //Sandra 
            If (cAliasCab)->WK_OPCAO == "2"
               (cAliasCab)->WK_INCOTE := "CIF"
            Else
               (cAliasCab)->WK_INCOTE := "FOB"
            EndIf
         Else
            (cAliasCab)->WK_TOTALG  := Transf(nValCab1,cPictFob)            //15.Total
            // AST - 05/05/09 - Solicitação 3M, primeira letra maiuscula, resto minuscula
            //(cAliasCab)->WK_FOBEXT2 := "("+StrTran(EXTENSO(nValCab1 ,.F.),"REAIS",If(nValCab1<2,cDolar,cDolares))+")" //16.Total  
            cExtenso := Alltrim(StrTran(EXTENSO(nValCab1 ,.F.),"REAIS",If(nValCab1<2,cDolar,cDolares)))
            cExtenso := SubStr(cExtenso,1,1)+Lower(subStr(cExtenso,2,len(cExtenso))) 
            IF "eua" $ cExtenso
               cExtenso1 := Substr(cExtenso,1,At("eua", cExtenso)-1)
               cExtenso2 := "EUA " + Substr(cExtenso,At("eua", cExtenso) + 4,LEN(cExtenso))
               cExtenso := cExtenso1 + cExtenso2
            ENDIF
            (cAliasCab)->WK_FOBEXT2 := "("+cExtenso+")"
            
            
            
            //Sandra 
            If (cAliasCab)->WK_OPCAO == "2"
               (cAliasCab)->WK_INCOTE := "FOB"
            Else
               (cAliasCab)->WK_INCOTE := "CIF"
            EndIf
         Endif                                                                           

         (cAliasCab)->WK_TOTFOB2 := Transf(nValCab1,cPictFob)           //12.Total
         (cAliasCab)->WK_TOTPES2 := Transf(nPesoCab1,cPictPeTot)        //13.Total
         //(cAliasCab)->WK_TOTQTD2 := Transf(nQtdCab1,cPictQtde)          //14.Total
         If Len(aAneQtdTot) <= 6
            If nx <> 2
               For i:=1 to Len(aAneQtdTot)
                  // ** AAF 22/07/05 - Unidade de Medida.
                  cUnAne:= aAneQtdTot[i,1]
                  If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                  // **
                  If i<=2
                     (cAliasCab)->WK_TOTQTD2:= Alltrim((cAliasCab)->WK_TOTQTD2)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
                  ElseIf i>2 .and. i<=4
                     (cAliasCab)->WK_TOTQTD3:= Alltrim((cAliasCab)->WK_TOTQTD3)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
                  Else
                     (cAliasCab)->WK_TOTQTD4:= Alltrim((cAliasCab)->WK_TOTQTD4)+Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
                  EndIf
               Next i
            EndIf
         Else
            PA150AneQtd("I",nx) // TLM 28/03/2008 Incluído o parâmetro nx na chamada da função PA150AneQtd()
         EndIf
         //If lImpNCM   // NCCF 17/02/09
            nAnexos_I := if(ValType(cAnexoImp) <> "N",Val(cAnexoImp),cAnexoImp)
			(cAliasCab)->WK_NCMIMP := if(/*nAnexos_I*/cAnexoImp-(cAnexoExp+1) >= 1,"VIDE ANEXOS"+CHR(13)+CHR(10)+StrZero(cAnexoExp+1,3)+" Á "+StrZero(cAnexoImp,3),"VIDE ANEXO "+StrZero(cAnexoExp+1,3))
         //Else
         //   (cAliasCab)->WK_NCMIMP := cNcmImp //AAF 17/02/09
         //   (cAliasCab)->WK_NCMIMP := "VIDE ANEXO"+StrZero((cAnexoExp+1)) 
         //EndIf
      Next nx

      PA150DETRUD()

      If Left(ED0->ED0_ANEEXP,1) == "3"       
         If ED0->ED0_MODAL == "2"
            mMemoAuxCarta := StrTran(mMemoCarta,STR0053,Space(10)+STR0022) //"Modalidade - Isenção / Suspensão Não Eletrônica"###Modalidade Isenção
         Else
            mMemoAuxCarta := StrTran(mMemoCarta,STR0053,STR0023) //"Modalidade - Isenção / Suspensão Não Eletrônica"###Modalidade Suspensão Não Eletrônica
         Endif
         mMemoAuxCarta := StrTran(mMemoAuxCarta,STR0039,STR0049) //"Documentos Comprobatórios da Importação e da Exportação"###"Documentos Comprobatórios da Importação "
      Else
         If ED0->ED0_MODAL == "2"
            mMemoAuxCarta := StrTran(mMemoCarta,STR0053,Space(10)+STR0022) //"Modalidade - Isenção / Suspensão Não Eletrônica"###Modalidade Isenção
         Else
            mMemoAuxCarta := StrTran(mMemoCarta,STR0053,STR0023) //"Modalidade - Isenção / Suspensão Não Eletrônica"###Modalidade Suspensão Não Eletrônica
         Endif
      Endif              
      
      cAliasCab := "CAB"
            
      For nx:= 1 To 5
         If nx>2
            cAliasCab := "CAB"+Alltrim(Str(nx-1))
         EndIf
         If nx == 1   
            If (cAliasCab)->WK_OPCAO == "2" 
               mMemoAuxCarta := StrTran(mMemoAuxCarta,STR0034, STR0050+Alltrim((cAliasCab)->WK_FRETE)) //"Frete Estimado"###"Frete Estimado US$ "
               mMemoAuxCarta := StrTran(mMemoAuxCarta,STR0035, STR0051+Alltrim((cAliasCab)->WK_SEGURO)) //"Seguro Estimado"###"Seguro Estimado US$ "
            Else   
               mMemoAuxCarta  := StrTran(mMemoAuxCarta,STR0034, Space(100)) //"Frete Estimado"
               mMemoAuxCarta  := StrTran(mMemoAuxCarta,STR0035, Space(100)) //"Seguro Estimado"
            Endif   
         EndIf   
      Next nx
      
      nLen := MlCount(mMemoAuxCarta,92)  
      
      For a:= 1 To 3
         //Flag para o Detail M
         DET->(DBAPPEND())
         DET->WK_SEQREL := cSEQREL 
         If(a=1,DET->WK_LCS := "Q",DET->WK_LCS := "T")
         DET->WK_PED := ED0->ED0_PD       
         //Fim
         For i:=1 to nLen
            DET->(DBAPPEND())  // Grava a Carta Final do Relatorio- "Relatorio de Comprovacao de Drawback"
            DET->WK_SEQREL := cSEQREL 
            If(a=1,DET->WK_LCS := "I",DET->WK_LCS := "M")
            DET->WK_LCS := "I"
            DET->WK_PED    := ED0->ED0_PD       
            DET->WKD_CARTA := MemoLine(mMemoAuxCarta, 85,I)//92
         Next i
         //Flag para o Detail N
         DET->(DBAPPEND())
         DET->WK_SEQREL := cSEQREL 
         If(a=1,DET->WK_LCS := "N",DET->WK_LCS := "U")
         DET->WK_PED := ED0->ED0_PD       
         //Fim
         If nLen <> 0    
            DET->(DBAPPEND()) // Grava o Rodape da Carta Final do Relatorio- "Relatorio de Comprovacao de Drawback"
            DET->WK_SEQREL  := cSEQREL 
            If a=1
               DET->WK_LCS := "J"
            Else 
               DET->WK_LCS := "L"
            Endif
            DET->WK_PED := ED0->ED0_PD
         EndIf
         If a = 2
            DET->WK_FLAG := "2"
         ElseIf a = 3
            DET->WK_FLAG := "3"
         EndIf
      Next a   
      RecLock("ED0",.F.)
      ED0->ED0_OK  := Space(Len(ED0->ED0_OK))  //Pedido Drawback Desmarcado
      ED0->(MsUnLock())          
   Endif
   cNumPed := ED0->ED0_PD
   Pa150ImpPerda()
   // ** AAF 19/10/05 - Não Imprimir no Aditivo.
   If !lAdit
      Pa150ImpCNPJ()
   Endif
   // **
Next nMarca

GravanoRud()
PA150Ordem(.F.)
Return(lRet)

*------------------------*
Static Function DescExp()
*------------------------*
cDescr := StrTran( cDescr, CRLF , " " )
cDescr := StrTran( cDescr, Chr(13) , " " )
Do While At("  ",cDescr) > 0
   cDescr := StrTran( cDescr, "  " , " " )
EndDo
Return .T.

*------------------------*
Static Function DescImp()
*------------------------*
Local cProd := "" //AOM - 05/06/2012

//AOM - 05/06/2012
If !Empty(SB1->B1_DESC_I) 
   cProd := MSMM(SB1->B1_DESC_I,AvSX3("B1_VM_I",AV_TAMANHO))
Else
   cProd := AvDescProdEE2(SB1->B1_COD)
EndIf

cDescricao     += Alltrim(MSMM(SB1->B1_DESC_GI,TAMDESCLI))
cDescricao     += STR0069+Alltrim(cProd)+STR0070 //" (Nome Comercial - "###")" //AOM - 05/06/2012
cDescricao     := StrTran( cDescricao, CRLF , " " )
cDescricao     := StrTran( cDescricao, Chr(13), " " )
Do While At("  ",cDescricao) > 0
   cDescricao := StrTran( cDescricao, "  " , " " )
EndDo
Return .T.

*--------------------------*
Static Function GravanoRud()
*--------------------------*
If !lAdit
   //--->Grava os dados nos arquivos do rud (EDCRU150.RPT)
   CAB->(DBGOTOP())
   DET->(DBGOTOP())
   Do While CAB->(!Eof())
      RudC->(DbAppend())
      RudC->WK_SEQREL  := CAB->WK_SEQREL
      RudC->WK_PED     := CAB->WK_PED
      RudC->WK_EMPRESA := CAB->WK_BENEFIC
      RudC->WK_ENDERE  := CAB->WK_ENDERE
      RudC->WK_CGC     := CAB->WK_CGC
      RudC->WK_ANETIM  := StrZero(nTotAneIm,3,0)
      RudC->WK_ANETEX  := StrZero(nTotAneEx,3,0)
      RudC->(MsUnlock())
      CAB->(DbSkip())
   EndDo
EndIf

Return .T.
                          
*-----------------------------*
Static Function PA150Cabec()
*-----------------------------*
Local cPictSeg:= AVSX3("ED0_SEGURO",6), cPictFre:= AVSX3("ED0_FRETE",6), nx
          
dDtProt  := AVCTOD("  /  /  ")

SYT->(DBSETORDER(1))

// Buscar Dados do Importador, da NCM e do Produto
SYT->(DbSeek(CFILSYT+ED0->ED0_IMPORT))             

cCidade := SYT->YT_CIDADE
cNumPed := ED0->ED0_PD
If(lTop, Pa150Query(), )

cAliasCab := "CAB"
//Gerar 5 vias para o Cabeçalho

For nx:= 2 To 5
   If nx>2
      cAliasCab := "CAB"+Alltrim(Str(nx-1))
   EndIf
      
   (cAliasCab)->(DBAPPEND())
   (cAliasCab)->WK_SEQREL  := cSEQREL
   (cAliasCab)->WK_PED     := ED0->ED0_PD
   
   //ER - 08/12/2006
   If Left(ED0->ED0_MODAL,1) == "1" .And. Left(ED0->ED0_ELETRO,1) == "2"
      (cAliasCab)->WK_SUSPEN  := "X"                                     // Suspenção
   Else
      (cAliasCab)->WK_ISENCAO := "X"                                     // Isencao   
   EndIf
   
   (cAliasCab)->WK_BENEFIC := ALLTRIM(SYT->YT_NOME)                   // 4.Beneficiario
   (cAliasCab)->WK_CGC     := Transf(ALLTRIM(SYT->YT_CGC), cPictCGC)  // 5.Inscrição no CGC
   (cAliasCab)->WK_ENDERE  := ALLTRIM(SYT->YT_ENDE)+STR0032+ALLTRIM(cCidade)+STR0032+ALLTRIM(SYT->YT_ESTADO)+STR0032+ALLTRIM(SYT->YT_CEP)// Endereço ###" - " // NCCF 17/02/09
   (cAliasCab)->WK_DESC_IM := STR0020 //"Mercadorias diversas, conforme Anexos" - 10.Discriminacao
   (cAliasCab)->WK_COBERT  := "X"
   (cAliasCab)->WK_DESC_EX := STR0020 //"Mercadorias diversas, conforme Anexos" - 22.Discriminacao
   (cAliasCab)->WK_VALID   := "X"
   (cAliasCab)->WK_FRETE   := Transf(ED0->ED0_FRETE, cPictFre)
   (cAliasCab)->WK_SEGURO  := Transf(ED0->ED0_SEGURO, cPictSeg)
   (cAliasCab)->WK_OPCAO   := Fre_Seg

   (cAliasCab)->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
   (cAliasCab)->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")

   (cAliasCab)->WK_LOCALDT := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
   If ED0->ED0_PROAP3 == "1"
      (cAliasCab)->WK_PRAZO   := ED0->ED0_DT_PR3
   Elseif ED0->ED0_PROAP2 == "1"          
      (cAliasCab)->WK_PRAZO   := ED0->ED0_DT_PR2
   Elseif ED0->ED0_PROAP1 == "1"          
      (cAliasCab)->WK_PRAZO   := ED0->ED0_DT_PR1
   Elseif !EMPTY(ED0->ED0_DT_VA2)  
      (cAliasCab)->WK_PRAZO   := ED0->ED0_DT_VA2
   Else                    
      (cAliasCab)->WK_PRAZO   := ED0->ED0_DT_VA1
   Endif
   
   (cAliasCab)->WK_DEL_REC    := ED0->ED0_DELEGA
   
   // ASK - 15/04/05
   If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"IMPRIME_CABEC"),)
Next nx

Return .T.

*----------------------------*
STATIC  FUNCTION PA150Carta()
*----------------------------*             
Local nOpc    := 0, dDtAux:=If(Empty(ED0->ED0_DT_ENV),dDataBase,ED0->ED0_DT_ENV)
Local lRet    := .F., i
Local cTit , oDlg2, nVolta, aMeses
Local cNome:="",cCargo:=""
            
cTit  := STR0021 //"Relatório de Comprovação de Drawback"
mMemoCarta :=""
      
SYT->(DbSetOrder(1))
SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))
cCidade := SYT->YT_CIDADE    
mMemoCarta :=/*Chr(13)+Chr(10)+Chr(13)+Chr(10)+*/Chr(13)+Chr(10)+Space(24)+STR0024+; //"Relatório de Comprovação de Drawback"
             Chr(13)+Chr(10)+Space(24)+STR0053+Chr(13)+Chr(10)+Space(24)+; //"Modalidade - Isenção / Suspensão Não Eletrônica"
             STR0025+Chr(13)+Chr(10)+Chr(13)+Chr(10)+; //"(Comunicado SECEX no. 08 de 15/02/11)" //"(Comunicado DECEX no. 21, de 11/07/97)"
             STR0026+Chr(13)+Chr(10)+STR0027+Chr(13)+Chr(10)+STR0028+Chr(13)+Chr(10)+; //"Ao"###"Banco do Brasil S.A."###"Agência - "
             /*STR0029+*/Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0030+SYT->YT_NOME+Chr(13)+Chr(10)+; //"A/C Sr: "####"Empresa: "
             STR0031+Alltrim(SYT->YT_ENDE)+STR0032+Alltrim(cCidade)+STR0032+Alltrim(SYT->YT_ESTADO)+; //"Endereço: "###" - "
             Chr(13)+Chr(10)+STR0033+Transf(SYT->YT_CGC, cPictCGC) //"C.G.C.: "

mMemoCarta += Chr(13)+Chr(10)

  If SELECT("WORK_MEN") # 0
      
     Work_Men->(dbGotop())

     /*
     Do While ! Work_Men->(EOF()) .AND. Work_Men->WKORDEM<'zzzzz'
        mMemoCarta += Chr(13)+Chr(10)+Work_Men->WKOBS+Chr(13)+Chr(10)
        Work_Men->(dbSkip())
     EndDo
     */
   EndIf
	  
   aMeses:= {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}  
   dData := StrZero(Day(dDtAux),2)+" de "+Lower(aMeses[Month(dDtAux)])+" de "+Str(Year(dDtAux),4)+"."
      
   /*
   For i:=MLCOUNT(mMemoCarta,60) To 25
      mMemoCarta += Chr(13)+Chr(10)
   Next
   */
   
   //mMemoCarta += STR0034+Space(17)+STR0035+Chr(13)+Chr(10) //"Frete Estimado"###"Seguro Estimado"
   //mMemoCarta += STR0039+Chr(13)+Chr(10) //"Documentos Comprobatórios da Importação e da Exportação"
   
   mMemoCarta += Chr(13)+Chr(10)
   mMemoCarta += STR0088+Chr(13)+Chr(10) //"Para fins de comprovação/habilitação ao regime de drawback integrado isenção,"
   mMemoCarta += STR0089+Chr(13)+Chr(10) //"conforme disposto na Portaria SECEX no. 08, de 15/02/2011," 
   mMemoCarta += STR0090+Chr(13)+Chr(10) //"declaramos estar cientes de que poderá ser solicitada, pelo Departamento de Operações"
   mMemoCarta += STR0091+Chr(13)+Chr(10) //"de Comércio Exterior (DECEX), a apresentação dos documentos relacionados nos anexos"
   mMemoCarta += STR0092+Chr(13)+Chr(10) //"Relatório de Importação, de Exportação (inclusive de notas fiscais de empresas"
   mMemoCarta += STR0093+Chr(13)+Chr(10) //"comerciais exportadoras) e da Aquisição no Mercado Interno."
   
   mMemoCarta += Chr(13)+Chr(10)
   
   mMemoCarta += Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+STR0040+dData+Chr(13)+Chr(10)+Space(01)+STR0041 //", "###"Local e Data"
   mMemoCarta += Chr(13)+Chr(10)+Chr(13)+Chr(10)
   mMemoCarta += Chr(13)+Chr(10)+Chr(13)+Chr(10)+Replicate("-",45)
   mMemoCarta += Chr(13)+Chr(10)+Space(01)+STR0042+Chr(13)+Chr(10) //"Assinatura Autorizada"
   
   mMemoCarta += Chr(13)+Chr(10)+Chr(13)+Chr(10)
   
   //mMemoCarta += Chr(13)+Chr(10)+Replicate("-",45)+Chr(13)+Chr(10)
   //Nome completo do Usuário
   /*
   PswOrder(2)
   If PswSeek(cUserName,.T.)
      cNome := PswRet()[1][4] //Retorna nome completo do usuário
      cCargo:= PswRet()[1][13] //Retorna Cargo
   EndIf
   mMemoCarta += cNome+Chr(13)+Chr(10)
   mMemoCarta += cCargo+Chr(13)+Chr(10)
   mMemoCarta += Space(01)+STR0043 //"Nome por Extenso"
   */                              
   DEFINE MSDIALOG oDlg2 TITLE cTit ;
   From 00,00 to 22,90 OF oMainWnd 

   DEFINE FONT oFont2 NAME STR0052 SIZE 0,16 //"Courier New"
   oDlg2:SetFont(oFont2)       
   
   @ 12,00 GET mMemoCarta SIZE 357 ,155 Pixel OF oDlg2 HSCROLL 

   ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nVolta:=1,oDlg2:End()},;
                                                 {||oDlg2:End()}) Centered
   If nVolta == 1
      lRet := .T.
   Else
      lRet := .F.
   Endif

Return(lRet)
  
*---------------------------------*
 Static Function PA150FIM(cTipo)                                    
*---------------------------------*
Local i, na, ny
Local cProd := "" //AOM - 05/06/2012

If nTotNCMPeso # 0 .or. nTotNCMQtd # 0 .or. nTotNCMTotal # 0
   If cTipo = "I" 
      SB1->(DbSeek(cFilSb1+cItem))         
      nLIN := nLIN+1 
      DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL 
      If lAdit
         DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
      Endif   
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD      
      DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso2)              //5.Peso Liquido      
      DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt2)                 //6.Quantidade NCM
      If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
         aAdd(aAneQtd,{cUMCom,nQtdIte1})
      Else
         aAneQtd[nPos,2] += nQtdIte1
      EndIf
      
      //AOM - 05/06/2012
      If !Empty(SB1->B1_DESC_I) 
         cProd := MSMM(SB1->B1_DESC_I,AvSX3("B1_VM_I",AV_TAMANHO))
      Else
         cProd := AvDescProdEE2(SB1->B1_COD)
      EndIf
      
      cDescricao     := Alltrim(cItem)+" - "
      cDescricao     += Alltrim(MSMM(SB1->B1_DESC_GI,TAMDESCLI))
      cDescricao     += STR0069+Alltrim(cProd)+STR0070 //" (Nome Comercial - "###")"
      cDescricao := StrTran( cDescricao, CRLF , " " )
      cDescricao := StrTran( cDescricao, Chr(13), " " )
      Do While At("  ",cDescricao) > 0
         cDescricao := StrTran( cDescricao, "  " , " " )
      EndDo
      DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,1))
      DET->WKD_TOT_F := Transf(nValIte1, cPictValor)               //10.Total
      If lImpPrcUn
         DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni)         //9.Preco FOB  	Transf(Val(DET->WKD_TOT_F)/(Val(DET->WKD_QTDE)), cPictValor)  
      EndIf
      AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                    DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                    DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                    DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                    DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
      
      EDCPAMLCOUNT("I")
      
   Else
      
      If Left(ED0->ED0_ANEEXP, 1) == "2"
         (cAliasSB1)->(DbSeek(cFilSB1Aux+cItem))
         nLIN := nLIN+1
         DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL 
         If lAdit
            DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
         Endif
         DET->WK_LCS    := "B"
         DET->WK_PED    := ED0->ED0_PD      
         DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso)               //5.Peso Liquido      
         DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt)                  //6.Quantidade NCM
         If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
            aAdd(aAneQtd,{cUMCom,nQtdIte1})
         Else
            aAneQtd[nPos,2] += nQtdIte1
         EndIf
         If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(cItem,"EE2_COD")))
            cDescr         := Alltrim(cItem)+" - "+MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
         ElseIf SB1->(DbSeek(xFilial("SB1")+AvKey(cItem,"B1_COD")))
            cDescr:= Alltrim(cItem)+" - "+AllTrim(SB1->B1_DESC)
         EndIf

         cDescr := StrTran( cDescr, CRLF , " " )
         cDescr := StrTran( cDescr, Chr(13), " " )
         Do While At("  ",cDescr) > 0
            cDescr := StrTran( cDescr, "  " , " " )
         EndDo
         DET->WKD_DISCR := Alltrim(Memoline(cDescr,TAMDESCPED,1))
         DET->WKD_TOT_F := Transf(nValIte1, cPictVlEm)                //10.Total
         If lImpPrcUn
            DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni)         //9.Preco FOB   Transf(Val(DET->WKD_TOT_F)/(Val(DET->WKD_QTDE)), cPictVlEm)
         EndIf
         AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                       DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                       DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                       DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                       DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})

         EDCPAMLCOUNT("E")
         
      Endif   
   EndIf   
                         
   If (cTipo = "I"  .Or. cTipo = "E") .and. lED0SubTot   // ACSJ - 18/11/2004
   
      If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
         nLIN := nLIN+1 
         DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL 
         If lAdit
            DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
         Endif   
         DET->WK_PED    := ED0->ED0_PD         
         DET->WK_LCS    := "B"  
         DET->WKD_ITE   := STR0018 //"Total...:"               
         DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso2)
         DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt2)
         DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictValor)      

         AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                       DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                       DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                       DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                       DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
      Endif
   Endif
   
   k:=1
   For i:=nLIN to NUMDELIN
       DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
       DET->WK_SEQREL := cSEQREL 
       If lAdit
          DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
       Endif   
       DET->WK_PED    := ED0->ED0_PD             
       DET->WK_LCS    := "B"  
       // NCCF 17/02/09
       If k/2 == int(k/2)
          DET->WKD_DOC_E := "SUPRIMIR"
       EndIf
       k++       
       
       AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                     DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                     DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                     DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                     DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
   Next
         
   DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
   DET->WK_SEQREL := cSEQREL 
   If lAdit
      DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
   Endif   
   DET->WK_LCS    := "C"  
   DET->WK_PED    := ED0->ED0_PD         
   DET->WKD_PESO  := Transf(nPesoTot1, cPictPeso)//,cPictPeTot)
   //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
   DET->WKD_QTDE  := ""
   DET->WKD_QTDE2 := "" 
   If Len(aAneQtd) <= 6
      For i:=1 to Len(aAneQtd)
         cUnAne:= aAneQtd[i,1]
         If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
            If i<=3
              DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
            Else
              DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
            EndIf
      Next i
   EndIf
 /*  If Len(aAneQtd) <= 6
      For i:=1 to Len(aAneQtd)
         cUnAne:= aAneQtd[i,1]
         If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
         If i<=3
            DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
         Else
            DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
         EndIf
      Next i
   EndIf   */
   DET->WKD_TOT_F := Transf(nValTot1,cPictFob)

   AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                 DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                 DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                 DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                 DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})
                                   
   DET->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
   DET->WK_SEQREL := cSEQREL 
   If lAdit
      DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
   Endif   
   DET->WK_LCS    := "D"  
   DET->WK_PED    := ED0->ED0_PD
   DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
   DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
   DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData

   AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                 DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                 DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                 DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                 DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG})

   cAliasAux := "DET"
   For ny := 1 To 4
       If ny>1
          cAliasAux := "DET"+Alltrim(Str(ny))
       EndIf
       For na := 1 To Len(aDetail)
          (cAliasAux)->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
          (cAliasAux)->WK_SEQREL  := aDetail[na,1]
          If lAdit
             (cAliasAux)->WK_SEQPED := StrZero(Val(cSEQPED),8)
          Endif
          (cAliasAux)->WK_PED     := aDetail[na,2]
          (cAliasAux)->WK_LCS     := aDetail[na,3]
          (cAliasAux)->WKD_ITE    := aDetail[na,4]
          (cAliasAux)->WKD_PORIMP := aDetail[na,5]
          (cAliasAux)->WKD_EXPORT := aDetail[na,6]
          (cAliasAux)->WKD_PESO   := aDetail[na,7]
          (cAliasAux)->WKD_QTDE   := aDetail[na,8]
          (cAliasAux)->WKD_DISCR  := aDetail[na,9]
          (cAliasAux)->WKD_DOC_E  := aDetail[na,10]
          (cAliasAux)->WKD_PRE_F  := aDetail[na,11]
          (cAliasAux)->WKD_TOT_F  := aDetail[na,12]
          (cAliasAux)->WKD_TOT_P  := aDetail[na,13]
          (cAliasAux)->WKD_TOT_Q  := aDetail[na,14]
          (cAliasAux)->WKD_ANEXO  := aDetail[na,15]
          (cAliasAux)->WKD_DI_ADI := aDetail[na,16]
          (cAliasAux)->WKD_DTREGI := aDetail[na,17]
          (cAliasAux)->WKD_PARTNU := aDetail[na,18]
          (cAliasAux)->WKD_AGENCI := aDetail[na,19]
          (cAliasAux)->WKD_CARTA  := aDetail[na,20]
          (cAliasAux)->WKD_CONTAT := aDetail[na,21]
          (cAliasAux)->WKD_QTDE2  := aDetail[na,len(aDetail[na])-1]
          
          If (cAliasAux)->WK_LCS = "D"             
             (cAliasAux)->WK_LCS := "S"
             If ny = 1 //flag para a impressão da mensagem das vias no rodapé
                (cAliasAux)->WK_FLAG  := "2"
             ElseIf ny = 2
                (cAliasAux)->WK_FLAG  := "3"
             ElseIf ny = 3
                (cAliasAux)->WK_FLAG  := "4"
             ElseIf ny = 4
                (cAliasAux)->WK_FLAG  := "5"
             EndIf
          ElseIf (cAliasAux)->WK_LCS = "A"
             If ny = 1 //flag para a impressão da mensagem do Anexo
                (cAliasAux)->WK_FLAG  := "2"
             ElseIf ny = 2
                (cAliasAux)->WK_FLAG  := "3"
             ElseIf ny = 3
                (cAliasAux)->WK_FLAG  := "4"
             ElseIf ny = 4
                (cAliasAux)->WK_FLAG  := "5"
             EndIf
          EndIf
       Next na

   Next ny
   aDetail:={}
EndIf                   

Return .T.              

*----------------------------*
Function PAMensagem()
*----------------------------*

AV_ESC_OBS("0",,,,cMarca)

Return .T.

/*                                                                             
Funcao      : Pa150Query()
Objetivos   : Busca dados do Percentual
Autor       : Sandra Yuriko Inoue
Data/Hora   : 12/09/2002
*/
*----------------------------*
Function Pa150Query()
*----------------------------*
Local cQuery:=""

//Alcir Alves - 05-05-05
If Select("QRY") # 0
  QRY->(dbclosearea())
endif

cQuery := "SELECT DISTINCT ED1.ED1_PROD, ED2.ED2_ITEM, SG1.G1_PERDA "+If(ED2->( FieldPos("ED2_VLCOPE") ) > 0,", ED2.ED2_VLCOPE ","")+" FROM "+;
          RetSqlName('ED1')+ " ED1, " +RetSqlName('ED2')+ " ED2, " +RetSqlName('SG1')+" SG1 " +;
          "WHERE ED1.D_E_L_E_T_ <> '*' AND ED1.ED1_FILIAL = '"+cFilED1+"' "+;
          "AND ED1.ED1_PD = '"+cNumPed+"' AND ED2.D_E_L_E_T_ <> '*' "+;
          "AND ED2.ED2_FILIAL = '"+cFilED2+"' AND ED2.ED2_PD = '"+cNumPed +"' "+;
          "AND SG1.D_E_L_E_T_ <> '*' AND SG1.G1_FILIAL = '"+cFilSG1+"' "+;
          "AND SG1.G1_COD = ED1.ED1_PROD AND SG1.G1_COMP = ED2.ED2_ITEM "+;
          "AND SG1.G1_PERDA <> 0 "

cCmd := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.) 

//Alcir Alves - 05-05-05
If Select("QRY2") # 0
  QRY2->(dbclosearea())
endif

cQuery := "SELECT DISTINCT ED1.ED1_PROD, ED7.ED7_DE, SG1.G1_PERDA "+If(ED2->( FieldPos("ED2_VLCOPE") ) > 0,", ED2.ED2_VLCOPE ","")+" FROM "+;
          RetSqlName('ED1')+ " ED1, " +RetSqlName('ED2')+ " ED2, " +RetSqlName('ED7')+" ED7, "+RetSqlName('SG1')+" SG1 "+;
          "WHERE ED1.D_E_L_E_T_ <> '*' AND ED1.ED1_FILIAL = '"+cFilED1+"' "+;
          "AND ED1.ED1_PD = '"+cNumPed+"' AND ED2.D_E_L_E_T_ <> '*' "+;
          "AND ED2.ED2_FILIAL = '"+cFilED2+"' AND ED2.ED2_PD = '"+cNumPed +"' "+;
          "AND ED7.D_E_L_E_T_ <> '*' AND ED7.ED7_FILIAL = '"+cFilED7+"' "+;
          "AND ED7.ED7_PARA = ED2.ED2_ITEM "+;
          "AND SG1.D_E_L_E_T_ <> '*' AND SG1.G1_FILIAL = '"+cFilSG1+"' "+;
          "AND SG1.G1_COD = ED1.ED1_PROD AND SG1.G1_COMP <> ED2.ED2_ITEM "+;
          "AND SG1.G1_COMP = ED7.ED7_DE AND SG1.G1_PERDA <> 0 "

cCmd := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY2", .F., .T.) 

Return .T.

/*
Funcao      : Pa150ImpPerda()
Objetivos   : Busca dados do Percentual
Autor       : Sandra Yuriko Inoue
Data/Hora   : 12/09/2002
*/
*----------------------------*
Function Pa150ImpPerda()
*----------------------------*
Local cDescricao:="",nTamDesc:= 40,nLin:=0,aPerda:={}, na, i, nz, ny
nAnexoP:=If(ValType(cAnexoImp) <> "N",Val(cAnexoImp),cAnexoImp) //AAF - 18/10/05 - Convertido para Numerico. //Val(cAnexoImp) //TAN

Private nPercMaior:=0, nPercMenor:= 5, lPercPerda:= .F., lVlComerc:= .F.


If Select("QRY") # 0 .and. !(QRY->(EOF()) .and. QRY->(BOF()))
   Do While QRY->(!Eof())
      If QRY->G1_PERDA > 5
         lPercPerda:= .T.
         Exit
      Else
         If Qry->G1_PERDA > nPercMaior
            nPercMaior:= Qry->G1_PERDA
         Endif
         If Qry->G1_PERDA < nPercMenor
            nPercMenor:= Qry->G1_PERDA
         Endif
      Endif
      
      // ** AAF 02/06/05 - Valor Comercial a Perda
      If ED2->( FieldPos("ED2_VLCOPE") ) > 0 .AND. QRY->ED2_VLCOPE == "S"
         lVlComerc := .T.
      EndIf
      // **
      
      QRY->(dbSkip())
   EndDo
   If !lPercPerda .and. Select("QRY2") # 0 .and. !QRY2->(EOF()) .and. !QRY2->(BOF())
      Do While QRY2->(!Eof())
         If QRY2->G1_PERDA > 5
            lPercPerda:= .T.
            Exit
         Else
            If Qry2->G1_PERDA > nPercMaior
               nPercMaior:= Qry2->G1_PERDA
            Endif
            If Qry->G1_PERDA < nPercMenor
               nPercMenor:= Qry2->G1_PERDA
            Endif
         Endif
         
         // ** AAF 02/06/05 - Valor Comercial a Perda
         If ED2->( FieldPos("ED2_VLCOPE") ) > 0 .AND. QRY->ED2_VLCOPE == "S"
            lVlComerc := .T.
         EndIf
         // **
         
         QRY2->(dbSkip())//AAF 08/08/05 QRY->(dbSkip())
      EndDo
   EndIf
Endif

If lPercPerda
   nAnexoP += 1
   DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
   DET->WK_SEQREL  := cSEQREL
   DET->WK_LCS     := "A"
   DET->WKD_ANEXO  := StrZero(nAnexoP,3)
   DET->WK_PED     := ED0->ED0_PD
   DET->WK_FLAG    := "1"
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO})
 
   DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   DET->WK_LCS    := "B"
   DET->WK_PED    := ED0->ED0_PD
   DET->WKD_DISCR := STR0057 //7.Discriminacao do Produto ###" - " //'Continuação do campo 33 do pedido de "Drawback":'
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO})
                    
   DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   DET->WK_PED    := ED0->ED0_PD
   DET->WK_LCS    := "B"
   DET->WKD_QTDE  := STR0058 //"     Cód. Mercadoria"
   DET->WKD_DISCR := STR0059 //"            Descrição"
   DET->WKD_DOC_E := STR0060 //"  Cód. Produto"
   DET->WKD_PRE_F := STR0061 //"    % Perda"
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO})
                
   DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   DET->WK_LCS    := "B"
   DET->WK_PED    := ED0->ED0_PD
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO})
                
   QRY->(dbGoTop())
   Do While QRY->(!Eof())
       
      If QRY->G1_PERDA <= 5
         QRY->(dbSkip())
         Loop      
      Endif
      
      If nLin > NUMDELIN1
         DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
         DET->WK_SEQREL := cSEQREL 
         DET->WK_LCS    := "C"  
         DET->WK_PED    := ED0->ED0_PD
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
 
         DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "D"
         DET->WK_PED    := ED0->ED0_PD
         DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
         DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
         DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
         nLin:=1
                      
         nAnexoP += 1
         DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
         DET->WK_SEQREL  := cSEQREL                  
         DET->WK_LCS     := "A"
         DET->WKD_ANEXO  := StrZero(nAnexoP,3)
         DET->WK_PED     := ED0->ED0_PD
         DET->WK_FLAG    := "1"
         
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "B"
         DET->WK_PED    := ED0->ED0_PD
         DET->WKD_DISCR := STR0057   //7.Discriminacao do Produto ###" - " //'Continuação do campo 33 do pedido de "Drawback":'
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_PED    := ED0->ED0_PD
         DET->WK_LCS    := "B"
         DET->WKD_QTDE  := STR0058 //"     Cód. Mercadoria"
         DET->WKD_DISCR := STR0059 //"            Descrição"
         DET->WKD_DOC_E := STR0060 //"  Cód. Produto"
         DET->WKD_PRE_F := STR0061 //"    % Perda"
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "B"
         DET->WK_PED    := ED0->ED0_PD
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
      EndIf
      SB1->(DbSeek(xFilial("SB1")+QRY->ED2_ITEM))
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD
      //Descrição do Produto
      SB1->(DbSeek(xFilial("SB1")+QRY->ED2_ITEM))
      cDescricao := Alltrim(MSMM(SB1->B1_DESC_I,nTamDesc))
      cDescricao := StrTran( cDescricao, CRLF , " " )
      cDescricao := StrTran( cDescricao, Chr(13), " " )
      Do While At("  ",cDescricao) > 0
         cDescricao := StrTran( cDescricao, "  " , " " )
      EndDo
      DET->WKD_DISCR := MemoLine(cDescricao,TAMDESCPED,1)
      DET->WKD_QTDE  := QRY->ED2_ITEM //Código do Produto de Importação
      DET->WKD_DOC_E := QRY->ED1_PROD //Código do Produto de Exportação
      DET->WKD_PRE_F := Alltrim(Transform(QRY->G1_PERDA,"@E 99.99"))
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
      nLin += 1
      For na := 2 To MlCount(cDescricao,TAMDESCPED)
          If !Empty(MemoLine(cDescricao,TAMDESCPED,na))
             DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
             DET->WK_SEQREL := cSEQREL
             DET->WK_LCS    := "B"
             DET->WK_PED    := ED0->ED0_PD
             DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,na))
             AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
             nLin += 1
          EndIf
      Next na

      QRY->(DbSkip())
   EndDo
   
   QRY2->(dbGoTop())
   Do While QRY2->(!Eof())
       
      If QRY2->G1_PERDA <= 5
         QRY2->(dbSkip())
         Loop      
      Endif
      
      If nLin > NUMDELIN1
         DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
         DET->WK_SEQREL := cSEQREL 
         DET->WK_LCS    := "C"  
         DET->WK_PED    := ED0->ED0_PD
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
 
         DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "D"
         DET->WK_PED    := ED0->ED0_PD
         DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
         DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
         DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
         nLin:=1
                      
         nAnexoP += 1
         DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
         DET->WK_SEQREL  := cSEQREL                  
         DET->WK_LCS     := "A"
         DET->WKD_ANEXO  := StrZero(nAnexoP,3)
         DET->WK_PED     := ED0->ED0_PD
         DET->WK_FLAG    := "1"
         
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "B"
         DET->WK_PED    := ED0->ED0_PD
         DET->WKD_DISCR := STR0057   //7.Discriminacao do Produto ###" - " //'Continuação do campo 33 do pedido de "Drawback":'
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_PED    := ED0->ED0_PD
         DET->WK_LCS    := "B"
         DET->WKD_QTDE  := STR0058 //"     Cód. Mercadoria"
         DET->WKD_DISCR := STR0059 //"            Descrição"
         DET->WKD_DOC_E := STR0060 //"  Cód. Produto"
         DET->WKD_PRE_F := STR0061 //"    % Perda"
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
         DET->WK_SEQREL := cSEQREL
         DET->WK_LCS    := "B"
         DET->WK_PED    := ED0->ED0_PD
         AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
      EndIf
      SB1->(DbSeek(xFilial("SB1")+QRY2->ED7_DE))
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD
      //Descrição do Produto
      SB1->(DbSeek(xFilial("SB1")+QRY2->ED7_DE))
      cDescricao := Alltrim(MSMM(SB1->B1_DESC_I,nTamDesc))
      cDescricao := StrTran( cDescricao, CRLF , " " )
      cDescricao := StrTran( cDescricao, Chr(13), " " )
      Do While At("  ",cDescricao) > 0
         cDescricao := StrTran( cDescricao, "  " , " " )
      EndDo
      DET->WKD_DISCR := MemoLine(cDescricao,TAMDESCPED,1)
      DET->WKD_QTDE  := QRY2->ED7_DE   //Código do Produto de Importação
      DET->WKD_DOC_E := QRY2->ED1_PROD //Código do Produto de Exportação
      DET->WKD_PRE_F := Alltrim(Transform(QRY2->G1_PERDA,"@E 99.99"))
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
      nLin += 1
      For na := 2 To MlCount(cDescricao,TAMDESCPED)
          If !Empty(MemoLine(cDescricao,TAMDESCPED,na))
             DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
             DET->WK_SEQREL := cSEQREL
             DET->WK_LCS    := "B"
             DET->WK_PED    := ED0->ED0_PD
             DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,na))
             AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
             nLin += 1
          EndIf
      Next na

      QRY2->(DbSkip())
   EndDo
   
   If nLin <= NUMDELIN1
      k:= 1
      For i:=nLin to NUMDELIN1 //Completa os itens do corpo
          DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
          DET->WK_SEQREL := cSEQREL
          DET->WK_PED    := ED0->ED0_PD
          DET->WK_LCS    := "B"
          // NCCF 17/02/09
          If k/2 == int(k/2)
             DET->WKD_DOC_E := "SUPRIMIR"
          EndIf
          k++
          
          AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

      Next i
   EndIf
   DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
   DET->WK_SEQREL := cSEQREL 
   DET->WK_LCS    := "C"  
   DET->WK_PED    := ED0->ED0_PD
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})
   DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
   DET->WK_SEQREL := cSEQREL
   DET->WK_LCS    := "D"
   DET->WK_PED    := ED0->ED0_PD
   DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
   DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
   DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO})
   
   cAliasAux := "DET"
   For ny := 1 To 4
       If ny>1
          cAliasAux := "DET"+Alltrim(Str(ny))
       EndIf
       For nz :=1 To Len(aPerda) //Imprimi cinco via do anexo para percentual de perda
           (cAliasAux)->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
           (cAliasAux)->WK_SEQREL  := aPerda[nz,1]
           If aPerda[nz,2] = "D"
              (cAliasAux)->WK_LCS := "S"
              If ny = 1 //flag para a impressão da mensagem das vias no rodapé
                 (cAliasAux)->WK_FLAG  := "2"
              ElseIf ny = 2
                 (cAliasAux)->WK_FLAG  := "3"
              ElseIf ny = 3
                 (cAliasAux)->WK_FLAG  := "4"
              ElseIf ny = 4
                 (cAliasAux)->WK_FLAG  := "5"
              EndIf
           Else
              (cAliasAux)->WK_LCS := aPerda[nz,2]
              (cAliasAux)->WK_FLAG:= aPerda[nz,10]
           EndIf
           (cAliasAux)->WK_PED     := aPerda[nz,3]
           (cAliasAux)->WKD_PORIMP := aPerda[nz,4]
           (cAliasAux)->WKD_DISCR  := aPerda[nz,5]
           (cAliasAux)->WKD_QTDE   := aPerda[nz,6]
           (cAliasAux)->WKD_DOC_E  := aPerda[nz,7]
           (cAliasAux)->WKD_PRE_F  := aPerda[nz,8]
           (cAliasAux)->WK_LOCALDT := aPerda[nz,9]
           (cAliasAux)->WKD_ANEXO  := aPerda[nz,11]
       Next nz
   Next ny   
   QRY->(dbCloseArea())
   QRY2->(dbCloseArea())
EndIf

If !lAdit
   if lPercPerda
      If !lVlComerc //Sem valor Comercial a Perda
         CAB->WK_PEDMSG1:= "X"
         CAB->WK_PEDMSG := space(10)+"Não há"+space(10)  // NCCF 17/02/09
      Else
         //Feito só para o CAB, já que somente será utilizado para a Via de cor cinza
         If (nAnexoP) - (cAnexoImp+1) = 0 // TAN
            CAB->WK_PEDMSG := STR0062+Alltrim(Strzero(nAnexoP,3)) //"Conforme Anexo Nro. "
         ElseIf (nAnexoP) - (cAnexoImp+1) >= 2
            CAB->WK_PEDMSG := STR0062+Alltrim(Strzero(cAnexoImp+1,3))+STR0063+Alltrim(Strzero(nAnexoP,3)) //"Conforme Anexos Nro. "###" a "
         ElseIf (nAnexoP) - (cAnexoImp+1) = 1
            CAB->WK_PEDMSG := STR0062+Alltrim(Strzero(cAnexoImp+1,3))+STR0064+Alltrim(Strzero(nAnexoP,3)) //"Conforme Anexos Nro. "###" e " 
         Else
            CAB->WK_PEDMSG := ""
            //CAB->WK_PEDMSG1:= ""
         Endif
      Endif
   Else
      If !lVlComerc
         CAB->WK_PEDMSG1:= "X"
         CAB->WK_PEDMSG := space(10)+"Não há"+space(10) // NCCF 17/02/09
      Else
         If (nPercMenor<> 5 .And. nPercMaior <> 0) .And. nPercMenor <> nPercMaior
            CAB->WK_PEDMSG := STR0065+Alltrim(StrTran(Str(nPercMenor),".",","))+;  //"Percentual de Perda entre "
                              STR0066+Alltrim(StrTran(Str(nPercMaior),".",","))+STR0067 //"% e "###"%"
         
         ElseIf nPercMenor == nPercMaior
            CAB->WK_PEDMSG := STR0068+Alltrim(StrTran(Str(nPercMaior),".",","))+STR0067 //"Percentual de Perda de "###"%"
         Else
            CAB->WK_PEDMSG := ""
            //CAB->WK_PEDMSG1:= ""
         Endif
      Endif
   EndIf
Endif

Return .T.

/*
Funcao      : Pa150ImpCNPJ()
Objetivos   : Busca dados do Importador/CNPJ
Autor       : TAN
Data/Hora   : 12/03/03
*/
*--------------------------*
Function Pa150ImpCNPJ()
*--------------------------*
Local nLin:=0, aCnpj:={}, nAneCnpj, z, i, y, zz, nx
Local nCont:= 0, lCnpj:= .F., aImpCnpj:= {}
Local cFilEDB, cPictCnpj
Local lAbriuEDB  := SX3->(dbSeek("EDB_FILIAL"))

if lAbriuEDB // ACSJ - 18/11/2004
   cFilEDB:=xFilial("EDB") 
   cPictCnpj:= AVSX3("EDB_CNPJ", 06)
Endif

nAneCnpj:=nAnexoP

SYT->(dbSetOrder(1))

if lAbriuEDB  /// ACSJ - 18/11/2004
   EDB->(dbSetOrder(1))
   If EDB->(dbSeek(cFilEDB+ED0->ED0_PD))   
      lCnpj:= .T.
      nAneCnpj += 1
    
      DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
      DET->WK_SEQREL  := cSEQREL
      DET->WK_LCS     := "A"
      DET->WKD_ANEXO  := StrZero(nAneCnpj,3)
      DET->WK_PED     := ED0->ED0_PD
      DET->WK_FLAG    := "1"
      AaDD(aCnpj, {DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
        
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD
      DET->WKD_DISCR := STR0074 //'Continuação dos campos 4, 5 e 30 do pedido de "Drawback":'
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
             
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                  DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                  DET->WKD_ANEXO})

      nContEDB:= 0
      EDB->(dbSetOrder(1))
      EDB->(dbSeek(cFilEDB+ED0->ED0_PD))
      Do While !EDB->(Eof()) .And. cFilEDB == EDB->EDB_FILIAL .And. EDB->EDB_PD == ED0->ED0_PD
         nContEDB++

         If nContEDB < 3
            cAliasCab:= "CAB"
            For z:= 1 To 4
               If z>1
                  cAliasCab := "CAB"+Alltrim(Str(z))
               EndIf
               cCampoCnpj:= "WK_CGC"+Alltrim(Str(nContEDB))
               (cAliasCab)->&(cCampoCnpj) := Transf(EDB->EDB_CNPJ, cPictCnpj)
            Next z
         Endif

         If nLin > NUMDELIN1
            DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
            DET->WK_SEQREL := cSEQREL 
            DET->WK_LCS    := "C"  
            DET->WK_PED    := ED0->ED0_PD
            AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})
 
            DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
            DET->WK_SEQREL := cSEQREL
            DET->WK_LCS    := "D"
            DET->WK_PED    := ED0->ED0_PD
            DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
            DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
            DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
            AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})
            nLin:=1
    
            nAneCnpj += 1
            DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
            DET->WK_SEQREL  := cSEQREL
            DET->WK_LCS     := "A"
            DET->WKD_ANEXO  := StrZero(nAneCnpj,3)
            DET->WK_PED     := ED0->ED0_PD
            DET->WK_FLAG    := "1"
    
            AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})

            DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
            DET->WK_SEQREL := cSEQREL
            DET->WK_LCS    := "B"
            DET->WK_PED    := ED0->ED0_PD
            DET->WKD_DISCR := STR0074 //'Continuação dos campos 4, 5 e 30 do pedido de "Drawback":'
            AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})

            nLin ++
       
            DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
            DET->WK_SEQREL := cSEQREL
            DET->WK_LCS    := "B"
            DET->WK_PED    := ED0->ED0_PD
            AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                      DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                      DET->WKD_ANEXO})

         nLin ++
      EndIf

      SYT->(dbSeek(cFilSYT+EDB->EDB_IMPORT))
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"      
      DET->WKD_DISCR := EDB->EDB_DESC
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})                   
      nLin ++
      
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_DISCR := Alltrim(SYT->YT_ENDE)
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
      nLin ++

      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_DISCR := Alltrim(SYT->YT_CIDADE)+STR0032+Alltrim(SYT->YT_ESTADO)
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
           
      nLin ++
      
      DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_DISCR := "CNPJ: "+Transf(EDB->EDB_CNPJ, cPictCnpj)
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                  DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                  DET->WKD_ANEXO})
      nLin ++
            
      DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_DISCR := STR0075 //"- Unidade da Receita Federal Jurisdicionante -"
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                  DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                  DET->WKD_ANEXO})
                  
      nLin ++
      DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_DISCR := EDB->EDB_DELEGA
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                  DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                  DET->WKD_ANEXO})
      nLin ++
      
      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
         nLin ++

         nPos:= aScan(aImpCnpj,{|x| x[1]==EDB->EDB_PD .And. x[2]==EDB->EDB_IMPORT })

         If nPos = 0
            Aadd(aImpCnpj, {EDB->EDB_CNPJ})
         Endif

         EDB->(DbSkip())
      EndDo

      If nLin <= NUMDELIN1
         k := 1
         For i:=nLin to NUMDELIN1 //Completa os itens do corpo
             DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
             DET->WK_SEQREL := cSEQREL
             DET->WK_PED    := ED0->ED0_PD
             DET->WK_LCS    := "B"
             // NCCF 17/02/09
             If k/2 == int(k/2)
               DET->WKD_DOC_E := "SUPRIMIR"
             EndIf
             k++
             
             AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})
    
         Next i
      EndIf
   
      DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
      DET->WK_SEQREL := cSEQREL 
      DET->WK_LCS    := "C"  
      DET->WK_PED    := ED0->ED0_PD
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                         DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                         DET->WKD_ANEXO})
      DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "D"
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
      DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
      DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
      AaDD(aCnpj,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO})
            
      cAliasAux := "DET"
      For zz := 1 To 4
          If zz>1
             cAliasAux := "DET"+Alltrim(Str(zz))
          EndIf
          For y :=1 To Len(aCnpj) //Imprimi cinco via do anexo para percentual de perda
              (cAliasAux)->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
              (cAliasAux)->WK_SEQREL  := aCnpj[y,1]
              If aCnpj[y,2] = "D"
                 (cAliasAux)->WK_LCS := "S"
                 If zz = 1 //flag para a impressão da mensagem das vias no rodapé
                    (cAliasAux)->WK_FLAG  := "2"
                 ElseIf zz = 2
                    (cAliasAux)->WK_FLAG  := "3"
                 ElseIf zz = 3
                    (cAliasAux)->WK_FLAG  := "4"
                 ElseIf zz = 4
                    (cAliasAux)->WK_FLAG  := "5"
                 EndIf
              Else
                 (cAliasAux)->WK_LCS := aCnpj[y,2]
                 (cAliasAux)->WK_FLAG:= aCnpj[y,10]
              EndIf
              (cAliasAux)->WK_PED     := aCnpj[y,3]
              (cAliasAux)->WKD_PORIMP := aCnpj[y,4]
              (cAliasAux)->WKD_DISCR  := aCnpj[y,5]
              (cAliasAux)->WKD_QTDE   := aCnpj[y,6]
              (cAliasAux)->WKD_DOC_E  := aCnpj[y,7]
              (cAliasAux)->WKD_PRE_F  := aCnpj[y,8]
              (cAliasAux)->WK_LOCALDT := aCnpj[y,9]
              (cAliasAux)->WKD_ANEXO  := aCnpj[y,11]
          Next y
      Next zz
   
   Endif
   
Endif

If lCnpj
   cAliasCab := "CAB"
   For nx:= 1 To 4
      If nx>1
         cAliasCab := "CAB"+Alltrim(Str(nx))
      EndIf

      If (nAneCnpj - (nAnexoP+1)) = 0
         (cAliasCab)->WK_MENSA := STR0062+Alltrim(Strzero(nAneCnpj,3)) //"Conforme Anexo Nro. "
         (cAliasCab)->WK_MENSA2:= STR0073+Alltrim(Strzero(nAneCnpj,3)) //"E outras conforme anexo(s) "
      ElseIf (nAneCnpj - (nAnexoP+1)) >= 2
         (cAliasCab)->WK_MENSA := STR0062+Alltrim(Strzero(nAnexoP+1,3))+STR0063+Alltrim(Strzero(nAneCnpj,3)) //"Conforme Anexos Nro. "###" a "
         (cAliasCab)->WK_MENSA2:= STR0073+Alltrim(Strzero(nAnexoP+1,3))+STR0063+Alltrim(Strzero(nAneCnpj,3)) //"E outras conforme anexo(s) "###" a "
      ElseIf (nAneCnpj - (nAnexoP+1)) = 1
         (cAliasCab)->WK_MENSA := STR0062+Alltrim(Strzero(nAnexoP+1,3))+STR0064+Alltrim(Strzero(nAneCnpj,3)) //"Conforme Anexos Nro. "###" e "
         (cAliasCab)->WK_MENSA2:= STR0073+Alltrim(Strzero(nAnexoP+1,3))+STR0064+Alltrim(Strzero(nAneCnpj,3)) //"E outras conforme anexo(s) "###" e "
      Else
         (cAliasCab)->WK_MENSA := ""
         (cAliasCab)->WK_MENSA2:= ""
      Endif
   Next nx
Else

   CAB->WK_MENSA := ""
   CAB->WK_MENSA2:= ""
   If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"WK_MESA2"),)
EndIf

Return .T.

/*
Funcao      : PA150DETRUD()
Objetivos   : Impressão do Rud
Autor       : 
Data/Hora   : 17/09/2002
*/
*-----------------------------------------------------------------*
Function PA150DETRUD()
*-----------------------------------------------------------------*
Local cFilEd1 := xFilial("ED1"), cFilSW7:=xFilial("SW7")
Local cFilEd2 := xFilial("ED2") 
Local cFilEd3 := xFilial("ED3") 
Local cFilEd4 := xFilial("ED4") 
Local cFilEd5 := xFilial("ED5") 
Local cFilSYD := xFilial("SYD")     
Local aRudUnid:={},x:=1,cUnid:="",nTotQtde := 0,cCampo:="",cUnidade:="",nTotFrete:=0,nTotSeguro:=0
Local cCampo_Moeda :="",cCampo_Vlr:= "", cNcm
Local aRudVlr :={},cDescr:="", i, b, a
Local cPedido:="",cDINum,dDtRegi,cCodProd:="",cUnida:="", cIte:="",cPESO:="",cQTDE:="",cUNIDAD, dDtDese
Local cDIOrig := "", cAdicOrig := ""  // GFP - 22/03/2012
Local cPRE_F:="",cVALEMB:="",cSEGURO:="",cFR_USS,nLinMemo:="",cAdicao:=""
Local nAneTot:=0,nAnePeso:=0,nAneQtde:=0,nTotLin:=0, nLinBranco:=0//, cAlias:="ED2"
Local nRegPRE_F:=0, nRegVALEMB :=0, nRegPESO :=0, nRegQTDE :=0, nRegSEGURO :=0, nRegFR_USS :=0
Local nPESO := 0, nQTDE :=0, nPRE_F :=0, nVALEMB := 0, nCoefAux:=0, lPVez:=.T.
Local lEECFAT := EasyGParam("MV_EECFAT",,.F.)
Local nPesoT := nQtdT := nValEmbT := nValFobT := 0   // Totalizadores por NCM
Local lAgrp := .F.
Local cProd := "" //AOM - 05/06/2012                                  // Variável que testa agrupamento (NCM ou Produto) 
Local aComp := {}, aOrd := SaveOrd({"ED8"})
Local nComp := 0  
Local cPictTec:= AVSX3("W8_TEC",6)

Local nRecno
Local lVazDI := .T.


Private cAlias := "ED2"
Private cMOEDA:="", cAliasRDM:="ED2"   // ACSJ - 07/06/2004 - Utilizado para o RDM da 3M (MUDARUDE/I)
Private aNFRUD := {}
Private lTemED9Cpos:=ED9->(FieldPOs("ED9_VAL_SE")) # 0 .AND. ED9->(FieldPOs("ED9_VALCOM")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_VALORI")) # 0 .AND. ED9->(FieldPOs("ED9_UMNCM" )) # 0 .AND.;
                     ED9->(FieldPOs("ED9_QTDNCM")) # 0 .AND. ED9->(FieldPOs("ED9_TX_USS")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DTAVRB")) # 0 .AND. ED9->(FieldPOs("ED9_ISENTO")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_SALISE")) # 0 .AND. ED9->(FieldPOs("ED9_FASEDR")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DT_INT")) # 0 .AND. SIX->(dbSeek("ED9"+"4"))//AWR - 14/04/2009

EE2->(DbSetOrder(1))
SW8->(DbSetOrder(6))
SW9->(DBSETORDER(1))
SW6->(dbSetOrder(1))
SW7->(dbSetOrder(4))

//Inicio do RUD - Relatorio Unico de Drawback

ED2->(DbSetOrder(5)) //Pedido+Dt.Registro+Num.DI+Adição
ED2->(DbSeek(cFilED2+ED0->ED0_PD))
//RRC - 26/11/2012 - Posiciona em um Item a Importar que não seja uma compra nacional para separar estes dados das importações no relatório
If Empty((cAlias)->ED2_DI_NUM)
   nRecno := (cAlias)->(Recno())
   Do While lVazDI .And. !(cAlias)->(Eof()) .And. (cAlias)->ED2_FILIAL == cFilEd2 .And. (cAlias)->ED2_PD == ED0->ED0_PD
      If Empty((cAlias)->ED2_DI_NUM)
         If (nPos:=aScan(aComp,{|x| x[1]==ED2->ED2_PD .and. x[2]==ED2->ED2_ITEM})) > 0
            aComp[nPos,9]  += ED2->ED2_PESO
            aComp[nPos,11] += ED2->ED2_QTD
            aComp[nPos,12] += ED2->ED2_QTDNCM
            aComp[nPos,13] += ED2->ED2_VALORI
            aComp[nPos,14] += ED2->ED2_VALEMB
         Else
            SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
            SA2->(DbSeek(ED2->(AvKey(ED2_FILIAL,"A2_FILIAL")+AvKey(ED2_FORN,"A2_COD")+AvKey(ED2_LOJA,"A2_LOJA"))))
            aAdd(aComp,{ED2->ED2_PD,;
            ED2->ED2_ITEM,;
            ED2->ED2_NF,;
            ED2->ED2_SERIE,;
            Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_MOD_NF"),;//ED8->ED8_MOD_NF,;
            TRANSF(Alltrim(ED2->ED2_NCM), cPictTec),;
            SA2->A2_CGC,;                            
            Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_DESC"),;//ED8->ED8_DESC,;
            ED2->ED2_PESO,;
            Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_UM"),;//ED8->ED8_UM,;
            ED2->ED2_QTD,;
            ED2->ED2_QTDNCM,;
            ED2->ED2_VALORI,;
            ED2->ED2_VALEMB})
         EndIf 
         (cAlias)->(DbSkip())
      Else
         lVazDI := .F.
      EndIf
   EndDo
   If lVazDi
      (cAlias)->(DbGoTo(nRecno))
   EndIf
   RestOrd(aOrd,.T.)
EndIf

If cOrd$"2/3"
   cAlias:="WorkRud"
   GrvWorkRUD()
EndIf

nLin := 999
dDtRegi := (cAlias)->ED2_DTREG
dDtDese := GetDtDesemb((cAlias)->ED2_DI_NUM)  // GFP - 18/05/2012
If (cAlias)->(FieldPos("ED2_DI_ORI")) > 0
   cDIOrig := (cAlias)->ED2_DI_ORI  // GFP - 22/03/2012
   cAdicOrig := (cAlias)->ED2_ADANT // GFP - 22/03/2012
EndIf
cDiNum  := (cAlias)->ED2_DI_NUM
cAdicao := (cAlias)->ED2_ADICAO
cCodProd:= iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM)   // ACSJ - 18/11/2004
cUnida  := (cAlias)->ED2_UMNCM
cNcm    := (cAlias)->ED2_NCM


//IF lEDCDIE //Alcir Alves - define se virá dados das DI´s externas - - NOPADO POR AOM - 04/11/10
   DBSELECTAREA("ED8")
   ED8->(DBSEEK(XFILIAL("ED8")+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA))
//endif
SB1->(DbSeek(cFilSb1+iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM)))   // ACSJ - 18/11/2004
If lMultiFil //AJP 26/06/07
   SW8->(DbSeek((cAlias)->ED2_FILORI+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
Else
   SW8->(DbSeek(xFilial("SW8")+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
EndIf
cDescricao := Alltrim(MSMM(SW8->W8_DESC_DI,TAMDESCDI))

//AOM - 05/06/2012
If !Empty(SB1->B1_DESC_I) 
   cProd := MSMM(SB1->B1_DESC_I,AvSX3("B1_VM_I",AV_TAMANHO))
Else
   cProd := AvDescProdEE2(SB1->B1_COD)
EndIf

If Empty(cDescricao)
   if !EMPTY(ED8->ED8_DESC) //lEDCDIE .AND.  - NOPADO POR AOM - 04/11/10
      cDescricao := Alltrim(ED8->ED8_DESC)   
   else
      cDescricao := Alltrim(cCodProd + " - " + MSMM(SB1->B1_DESC_GI,TAMDESCLI))
      cDescricao += STR0069+Alltrim(cProd)+STR0070 //" (Nome Comercial - "###")"
   endif  
EndIf
cDescricao := StrTran( cDescricao, CRLF , " " )
cDescricao := StrTran( cDescricao, Chr(13), " " )
Do While At("  ",cDescricao) > 0
   cDescricao := StrTran( cDescricao, "  " , " " )
EndDo
nLinMemo := 1
If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DESCRICAO_RUD"),) //Alcir Alves - 04-07-05

aNFRUD := {}
Do While !(cAlias)->(Eof()) .And. (cAlias)->ED2_FILIAL == cFilEd2 .And. (cAlias)->ED2_PD == ED0->ED0_PD
  //  If cCodProd # ED2->ED2_ITEM
   If Empty((cAlias)->ED2_DI_NUM) //RRC - 26/11/2012 - Tratamento para Compras Nacionais
      If (nPos:=aScan(aComp,{|x| x[1]==ED2->ED2_PD .and. x[2]==ED2->ED2_ITEM})) > 0
         aComp[nPos,9]  += ED2->ED2_PESO
         aComp[nPos,11] += ED2->ED2_QTD
         aComp[nPos,12] += ED2->ED2_QTDNCM
         aComp[nPos,13] += ED2->ED2_VALORI
         aComp[nPos,14] += ED2->ED2_VALEMB
      Else
         SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
         SA2->(DbSeek(ED2->(AvKey(ED2_FILIAL,"A2_FILIAL")+AvKey(ED2_FORN,"A2_COD")+AvKey(ED2_LOJA,"A2_LOJA"))))
         aAdd(aComp,{ED2->ED2_PD,;
         ED2->ED2_ITEM,;
         ED2->ED2_NF,;
         ED2->ED2_SERIE,;
         Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_MOD_NF"),;//ED8->ED8_MOD_NF,;
         TRANSF(Alltrim(ED2->ED2_NCM), cPictTec),;
         SA2->A2_CGC,;                            
         Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_DESC"),;//ED8->ED8_DESC,;
         ED2->ED2_PESO,;
         Posicione("ED8",5,xFilial("ED8")+AvKey(ED2->ED2_PD,"ED8_PEDIDO")+AvKey(ED2->ED2_POSICA,"ED8_POSDI"),"ED8_UM"),;//ED8->ED8_UM,;
         ED2->ED2_QTD,;
         ED2->ED2_QTDNCM,;
         ED2->ED2_VALORI,;
         ED2->ED2_VALEMB})
      EndIf 
      RestOrd(aOrd,.T.)
      (cAlias)->(DbSkip())
      Loop
   EndIf
   If !lPVez
        For x:=nLinMemo to MlCount(cDescricao,TAMDESCREL)//TAMDESC)
           RudD->(DBAPPEND())
           RudD->WK_SEQREL  := cSEQREL
           RudD->WK_PED     := ED0->ED0_PD
           RudD->WKD_FLAG   := "F" //- AOM - 25/05/2012 - O correto é o Valor "F"
           RudD->WKD_DESCR  := Alltrim(MemoLine(cDescricao,TAMDESCREL,x))
// ACL
           If Len(aNFRUD) >= x
              RudD->WKD_NF     := aNFRUD[x][1]
              RudD->WKD_DTNF   := DtoC(aNFRUD[x][2])
           EndIf   
           nTotLin := nTotLin+1
           If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
              If nLin # 999 
                  For i:= nTotLin to NUMLINRUD// - nLinBranco
                     RudD->(DBAPPEND())
                     RudD->WK_SEQREL  := cSEQREL
                     RudD->WK_PED     := ED0->ED0_PD
                     RudD->WKD_FLAG   := "F"
                  Next
                  
                  RudD->(DBAPPEND())
                  RudD->WK_SEQREL  := cSEQREL
                  RudD->WK_PED     := ED0->ED0_PD
                  RudD->WKD_FLAG   := "G"
                  RudD->WKD_LOCAL  := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
                  RudD->WKD_TOT_P  := Transf(nAnePeso, cPictPeso2)
                  RudD->WKD_TOT_Q  := Alltrim(Transf(nAneQtde, cPictQtde))
                  RudD->WKD_TOT_F  := Transf(nAneTot, cPictValor)
                  RudD->WKD_TOTFRT := Transf(nTotFrete,"@E 999,999,999.99")
                  RudD->WKD_TOTSEG := Transf(nTotSeguro,"@E 999,999,999.99")
                  RudD->WKD_ASSRU1 := EasyGParam("MV_ASSRUD1",,"") 
                  RudD->WKD_ASSRU2 := EasyGParam("MV_ASSRUD2",,"")
                                                          
                  aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})//Imprime totais por moeda
                  For b := 1 To Len(aRudVlr)
                      cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)
                      &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                      cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)
                      &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
                  Next b
                  
                  aSort(aRudUnid,,,{|x,y| x[1] > y[1]})//Imprimi totais por Vlr de Embarque
                  For a := 1 To Len(aRudunid)
                      cUnAne:= aRudUnid[a,1]
                      If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                      cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                      &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde))//cPictValor))
                      cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                      &cUnidade:= Alltrim(cUnAne)+" - "
                  Next a
                  
                  TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
                  
                  aRudUnid:={}
                  aRudVlr :={}
                  nAnePeso  := 0
                  nAneQtde  := 0
                  nAneTot   := 0
                  nTotFrete := 0
                  nTotSeguro:=0
              EndIf
              
              RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback" (Importacao)
              nAnexoCal += 1
              nTotAneIm +=1
              RudD->WK_SEQREL := cSEQREL 
              RudD->WKD_FLAG  := "E"           
              RudD->WK_PED    := ED0->ED0_PD                                      
              RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
              nLIN    := 0
              nTotLin := 0
              cLastFlag:= "E"
           EndIf
        Next x
// acl           
        If Len(aNFRUD) > x
           For i:= x to Len(aNFRUD)
              RudD->(DBAPPEND())
              RudD->WK_SEQREL  := cSEQREL
              RudD->WK_PED     := ED0->ED0_PD
              RudD->WKD_FLAG   := "F"
              RudD->WKD_NF     := aNFRUD[i][1]
              RudD->WKD_DTNF   := DtoC(aNFRUD[i][2])
              nTotLin := nTotLin+1
           Next
        Endif
        If Len(aNFRUD) > 0
           RudD->(DBAPPEND())
           RudD->WK_SEQREL  := cSEQREL
           RudD->WK_PED     := ED0->ED0_PD
           RudD->WKD_FLAG   := "F" 
           aNFRUD := {}
           nTotLin := nTotLin+1
        EndIf   
        
        /*
        Testa se há agrupamento (por NCM ou Código de Item)
        Caso haja, inclue registro com os valores totais
        HFD
        */
        If lAgrp
           nLIN    := nLIN + 1
           nTotLin := nTotLin + 1
          
           RudD->(DBAPPEND())  // Grava o Detail do RUD - "Relatorio Unico Drawback" com o Total por NCM 
           RudD->WK_SEQREL  := cSEQREL
           RudD->WKD_FLAG   := "F"
           RudD->WK_PED     := cPedido
           RudD->WKD_DI_ADI := ""
           RudD->WKD_DTREGI := ""                                                               // Dt Registro
           RudD->WKD_NCM    := Iif(cOrd == "2", cIte, "")                                       // Ncm
           RudD->WKD_PARTNU := Iif(cOrd == "2","" , cCodProd)                                   // Cod. Produto
           RudD->WKD_DESCR  := "TOTAL"                                                          // Campo Totalizador
       
           nLinMemo += 1                                         
       
           RudD->WKD_PESO   := Alltrim(Transf(nPesoT, cPictPeso2))                       // Peso
           RudD->WKD_QTDE   := Alltrim(Transf(nQtdT, cPictQt2))                         // Quantidade
           RudD->WKD_UNID   := cUnMed                                                           // Unidade de Medida
           RudD->WKD_VAL_F  := Alltrim(Transf(nValFobT, cPictValor))                       // Valor Total
           RudD->WKD_VALEMB := Alltrim(Transf(Round(nValEmbT,2),"@E 99,999,999,999.99"))   // Valor Local de Embarque
           RudD->WKD_MOEDA  := cMOEDA  //ED2->ED2_MOEDA
       
           nLIN    := nLIN + 1
           nTotLin := nTotLin + 1
    
           RudD->(DBAPPEND())     
           RudD->WKD_FLAG   := "F"  
           RudD->WK_SEQREL  := cSEQREL
           RudD->WK_PED     := cPedido 
               
           nPesoT := nQtdT := nValEmbT := nValFobT := 0
        EndIf        
        
        cCodProd:= iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM)   // ACSJ - 18/11/2004
        cUnida  := (cAlias)->ED2_UMNCM
        //IF lEDCDIE  -  NOPADO POR AOM - 04/11/10
            DBSELECTAREA("ED8")
            ED8->(DBSEEK(XFILIAL("ED8")+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA))
        //endif
        SB1->(DbSeek(cFilSb1+cCodProd))
        //AJP 26/06/07 Multifilial
        If lMultiFil
           SW8->(DbSeek((cAlias)->ED2_FILORI+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
        Else
           SW8->(DbSeek(xFilial("SW8")+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
        EndIf
        cDescricao := Alltrim(MSMM(SW8->W8_DESC_DI,TAMDESCDI)) 
        //AOM - 05/06/2012
        If !Empty(SB1->B1_DESC_I) 
           cProd := MSMM(SB1->B1_DESC_I,AvSX3("B1_VM_I",AV_TAMANHO))
        Else
           cProd := AvDescProdEE2(SB1->B1_COD)
        EndIf
        If Empty(cDescricao)
           if !EMPTY(ED8->ED8_DESC)// lEDCDIE .AND.  - NOPADO POR AOM - 04/11/10
               cDescricao := Alltrim(ED8->ED8_DESC)   
           else
               cDescricao := Alltrim(cCodProd + " - " + MSMM(SB1->B1_DESC_GI,TAMDESCLI))
               cDescricao += STR0069+Alltrim(cProd)+STR0070 //" (Nome Comercial - "###")"
           endif    
        EndIf
        cDescricao := StrTran( cDescricao, CRLF , " " )
        cDescricao := StrTran( cDescricao, Chr(13), " " )
        Do While At("  ",cDescricao) > 0
           cDescricao := StrTran( cDescricao, "  " , " " )
        EndDo
        nLinMemo := 1
        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DESCRICAO_RUD"),) //Alcir Alves - 04-07-05
   EndIf

// ACL NF de Importacao
   If Len(aNFRUD) = 0
      If Left(cOrdNF,1) == "1"
         //cFilSWN:= xFilial("SWN")//AAF 14/09/05 - Filial do SWN.
         cFilSWN:= If(lMultiFil,(cAlias)->ED2_FILORI,xFilial("SWN"))//AJP 26/06/07 - Multifilial
         cFilSF1:= If(lMultiFil,(cAlias)->ED2_FILORI,xFilial("SF1"))//AJP 26/06/07 - Multifilial
         SWN->(DbSetOrder(3))
         SF1->(DbSetOrder(1))
         If SWN->(DbSeek(cFilSWN+(cAlias)->ED2_HAWB))
            aNFRUD := {}
            While SWN->(!Eof()) .and. SWN->WN_FILIAL == cFilSWN .AND. SWN->WN_HAWB = (cAlias)->ED2_HAWB//AAF 14/09/05 - Verifica Filial do SWN.
               If SWN->WN_PRODUTO = (cAlias)->ED2_ITEM
                  SF1->(DbSeek(cFilSF1+SWN->WN_DOC+SWN->WN_SERIE))
                  Aadd(aNFRUD,{SF1->F1_DOC, SF1->F1_EMISSAO, SWN->WN_PRODUTO})
               EndIf
               SWN->(DbSkip())
            EndDo
         EndIf
         SWN->(DbSetOrder(1))
      EndIf   
   EndIf
    nRegPRE_F:=0; nRegVALEMB :=0; nRegPESO :=0; nRegQTDE :=0; nRegSEGURO :=0; nRegFR_USS :=0
    lPVez := .F.
    cIte := ""

    Do While !(cAlias)->(Eof()) .And. (cAlias)->ED2_FILIAL == cFilEd2 .And. (cAlias)->ED2_PD == ED0->ED0_PD .and. ;
             If(cOrd=="1",.T.,cNcm==(cAlias)->ED2_NCM) .and.;
             dDtRegi == (cAlias)->ED2_DTREG .and. cDiNum  == (cAlias)->ED2_DI_NUM  .and. (cAlias)->ED2_ADICAO == cAdicao .and.;
             cCodProd == iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM) .and.;   // ACSJ - 18/11/2004
             cUnida == (cAlias)->ED2_UMNCM .AND. (FieldPos("ED2_DI_ORI") == 0 .OR. (cAlias)->ED2_DI_ORI == cDiOrig .AND. (cAlias)->ED2_ADANT == cAdicOrig)

        If lMultiFil //AJP 26/06/2007
           SW8->(DbSeek((cAlias)->ED2_FILORI+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
        Else
           SW8->(DbSeek(xFilial("SW8")+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
        Endif
        
        /*
        If SW9->(dbSeek(xFilial("SW9")+(cAlias)->ED2_INVOIC+SW8->W8_FORN)) .and.;
        SW6->(dbSeek(xFilial("SW6")+(cAlias)->ED2_HAWB)) .and. (cAlias)->ED2_MOEDA <> cMoedaPAR
           nRudVal  := (cAlias)->ED2_VL_MOE   //ED2->ED2_VALEMB * (SW6->W6_TX_US_D / SW9->W9_TX_FOB) //De dolar para moeda
        Else
        	If (cAlias)->ED2_MOEDA == cMoedaPAR // caso o ED2_VL_MOE=0 - Alterado em 22/09/05 LAM
        		nRudVal  := (cAlias)->ED2_VALEMB
        	Else
        		nRudVal  := ((cAlias)->ED2_VALEMB*(cAlias)->ED2_TX_USS/(cAlias)->ED2_TX_MOE)
        	Endif
        EndIf
        */
        
        If ED2->(FieldPos("ED2_DI_ORI")) > 0
           cDiOrig   := (cAlias)->ED2_DI_ORI
           cAdicOrig := (cAlias)->ED2_ADANT
        EndIf
        
        cUNIDAD  := (cAlias)->ED2_UMNCM
        cUnMed:=cUNIDAD  //Alcir Alves - 02-05-05
        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),)                  
        cUNIDAD := cUnMed//AAF 11/07/05 - Unidade de Medida.

        cPedido := ED0->ED0_PD
        If !Empty(SW8->W8_TEC)
           cIte:=Alltrim(Transf(SW8->W8_TEC, cPictNcm2)) //ED2->ED2_NCM
        Else
           if !EMPTY(ED8->ED8_NCM) // lEDCDIE .AND. - NOPADO POR AOM - 04/11/10          
               cIte:=Transf(ED8->ED8_NCM, cPictNcm2)
           else
               cIte:=If(Empty(cIte),Alltrim(Transf((cAlias)->ED2_NCM, cPictNcm2)),cIte) //ED2->ED2_NCM
           endif    
        EndIf
        cMOEDA  := (cAlias)->ED2_MOEDA
        cAliasRDM := cAlias
        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"MOEDARUDI"),)

        // ** AAF 10/11/05 - Valor Original(Preço da DI) na Moeda da DI.
        If (cAlias)->ED2_MOEDA == "US$"
           nRudVal := (cAlias)->ED2_VALORI
        Else
           nRudVal := (cAlias)->ED2_VALORI * (cAlias)->ED2_TX_MOE / (cAlias)->ED2_TX_USS
        Endif
        // **
        
        nRegVALEMB += (cAlias)->ED2_VALORI
        nRegPRE_F  += nRudVal
        nRegPESO   += (cAlias)->ED2_PESO
        nRegQTDE   += (cAlias)->ED2_QTDNCM
        nRegSEGURO += (cAlias)->ED2_SE_USS
        nRegFR_USS += (cAlias)->ED2_FR_USS

        nAneTot    += nRudVal
        nAnePeso   += (cAlias)->ED2_PESO
        nAneQtde   += (cAlias)->ED2_QTDNCM
        nTotSeguro += (cAlias)->ED2_SE_USS
        nTotFrete  += (cAlias)->ED2_FR_USS

        // Totalizadores por NCM ou Cod. Item
        // HFD
        //if cOrd == "2" .or. cOrd == "3" 
        if (cOrd == "2" .and. cNcm == (cAlias)->ED2_NCM) .or. (cOrd == "3" .and. cCodProd == iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM)) 
    	   nPesoT   += (cAlias)->ED2_PESO
           nQtdT    += (cAlias)->ED2_QTDNCM
	       nValEmbT += (cAlias)->ED2_VALORI
    	   nValFobT += nRudVal
    	endIf
        (cAlias)->(DBSKIP())
    EndDo

    If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
        If nLin # 999 
            For i:= nTotLin to NUMLINRUD
               RudD->(DBAPPEND()) // Grava o Detail do RUD- "Relatorio Unico Drawback" 
               RudD->WK_SEQREL  := cSEQREL
               RudD->WK_PED     := ED0->ED0_PD
               RudD->WKD_FLAG   := "F"               
            Next i
            
            nAneTot    -= nRegPRE_F
            nAnePeso   -= nRegPESO
            nAneQtde   -= nRegQTDE
            nTotFrete  -= nRegFR_USS
            nTotSeguro -= nRegSEGURO
            
            RudD->(DBAPPEND())
            RudD->WK_SEQREL  := cSEQREL
            RudD->WK_PED     := ED0->ED0_PD
            RudD->WKD_FLAG   := "G"
            RudD->WKD_LOCAL  := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
            RudD->WKD_TOT_P  := Transf(nAnePeso, cPictPeso2)
            RudD->WKD_TOT_Q  := Alltrim(Transf(nAneQtde, cPictQtde))
            
            RudD->WKD_TOT_F  := Transf(nAneTot, cPictValor)
            
            RudD->WKD_TOTFRT := Transf(nTotFrete,"@E 999,999,999.99")
            RudD->WKD_TOTSEG := Transf(nTotSeguro,"@E 999,999,999.99")
            RudD->WKD_ASSRU1 := EasyGParam("MV_ASSRUD1",,"")
            RudD->WKD_ASSRU2 := EasyGParam("MV_ASSRUD2",,"")
            
            aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
            aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
         
            For a := 1 To Len(aRudunid)            
                cUnAne   := aRudUnid[a,1]
                If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde)) //cPictValor
                cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                &cUnidade:= Alltrim(cUnAne)+" - "
            Next a

            For b := 1 To Len(aRudVlr)
                cCampo   := "RudD->WKD_TVEM"+StrZero(b,2)
                &cCampo  := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                cUnidade := "RudD->WKD_MVEM"+StrZero(b,2)
                &cUnidade:= Alltrim(aRudVlr[b,1])+" - "
            Next b
            
            TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
            
            aRudUnid := {}
            aRudVlr  := {}
            
            nAneTot    := nRegPRE_F
            nAnePeso   := nRegPESO
            nAneQtde   := nRegQTDE
            nTotFrete  := nRegFR_USS
            nTotSeguro := nRegSEGURO
            
        EndIf
        
        //If !ED2->(EOF())
           RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback" (Importacao)
           nAnexoCal += 1
           nTotAneIm +=1
           RudD->WK_SEQREL := cSEQREL
           RudD->WKD_FLAG  := "E"
           RudD->WK_PED    := ED0->ED0_PD
           RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
           nLIN    := 0
           nTotLin := 0
        //Endif

        cLastFlag:= "E" //AAF 18/05/05
    EndIf 
    nLIN    := nLIN + 1
    nTotLin := nTotLin + 1
    
    RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
    RudD->WK_SEQREL  := cSEQREL
    RudD->WKD_FLAG   := "F"
    RudD->WK_PED     := cPedido
    If ED2->(FieldPos("ED2_DI_ORI")) > 0 .And. lImpDIOrig //AOM - 15/06/2012
       RudD->WKD_DIADOR := Transf(cDiOrig, cPictDi)+"/"+Alltrim(cAdicOrig)  // GFP - 22/03/2012
    EndIf
    //AOM - 15/06/2012
    If Empty(RudD->WKD_DIADOR)
      RudD->WKD_DIADOR := Transf(cDiNum, cPictDi)+"/"+Alltrim(cAdicao)
    EndIf
    RudD->WKD_DI_ADI := Transf(cDiNum, cPictDi)+"/"+Alltrim(cAdicao)
    RudD->WKD_DTREGI := Dtoc(dDtRegi) //ED2->ED2_DTREG                                                         // Dt Registro
    RudD->WKD_DTDESE := Dtoc(dDtDese) // GFP - 18/05/2012
    RudD->WKD_NCM    := cIte//Alltrim(Transf(ED2->ED2_NCM, cPictNcm2))                               // Ncm
    RudD->WKD_PARTNU := cCodProd//ED2->ED2_ITEM                                                          // Cod. Mercadoria
    If nLinMemo <= MlCount(cDescricao, 58) .and. Len(Alltrim(cDescricao))<>19//TAMDESC) 
       RudD->WKD_DESCR := Alltrim(MemoLine(cDescricao,TAMDESCREL,nLinMemo))
// ACL
       If Len(aNFRUD) > 0
          RudD->WKD_NF     := aNFRUD[1][1]
          RudD->WKD_DTNF   := DtoC(aNFRUD[1][2])
       EndIF   
    Else 
       RudD->WKD_DESCR := Alltrim(cCodProd)
       If Len(aNFRUD) > 0
          RudD->WKD_NF     := aNFRUD[1][1]
          RudD->WKD_DTNF   := DtoC(aNFRUD[1][2])
       EndIF   
    EndIf
    
    nLinMemo += 1
    RudD->WKD_PESO   := Alltrim(Transf(nRegPESO, cPictPeso2))  // Peso
    RudD->WKD_QTDE   := Alltrim(Transf(nRegQTDE, cPictQt2))    // Quantidade
    RudD->WKD_UNID   := cUnMed // Unidade de Medida
    RudD->WKD_VAL_F  := Alltrim(Transf(nRegPRE_F, cPictValor)) // Valor Total
    RudD->WKD_VALEMB := Alltrim(Transf(Round(nRegVALEMB,2),"@E 99,999,999,999.99"))        // Valor Local de Embarque
    RudD->WKD_MOEDA  := cMOEDA  //ED2->ED2_MOEDA
    RudD->WKD_SEGURO := Alltrim(Transf(nRegSEGURO,"@E 99,999,999,999.99"))        //Vlr.Seguro
    RudD->WKD_FR_USS := Alltrim(Transf(nRegFR_USS,"@E 99,999,999,999.99"))        //Vlr.Frete

    nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(cUNIDAD)})
    nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(cMOEDA)})
    
    //Testa se há agrupamento (por NCM ou Código do Produto)
    lAgrp := (cOrd == "2" .AND. cNcm <> (cAlias)->ED2_NCM .or.;
            cOrd == "3" .and. cCodProd <> iif(lED2Inat,If(Empty((cAlias)->ED2_INAT),(cAlias)->ED2_ITEM,(cAlias)->ED2_INAT),(cAlias)->ED2_ITEM))
               
    If nUM = 0
       AADD(aRudUnid,{Alltrim(cUNIDAD),nRegQTDE}) //,nRudQtde})
    Else
       aRudUnid[nUM,2] += nRegQTDE //nRudQtde
    EndIf

    If nVL = 0
       AADD(aRudVlr ,{Alltrim(cMOEDA),Round(nRegVALEMB,2)})
    Else
       aRudVLR[nVL,2] += Round(nRegVALEMB,2)
    EndIf

    If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DETALHE_IMP"),)
    dDtRegi := (cAlias)->ED2_DTREG
    cDiNum  := (cAlias)->ED2_DI_NUM
    cAdicao := (cAlias)->ED2_ADICAO
    cNcm    := (cAlias)->ED2_NCM
    //RRC - 12/12/2012 - Verifica se é uma importação para retornar a data de desembaraço, se for uma DI externa retornará uma data em branco  
    dDtDese := If(Empty((cAlias)->ED2_HAWB),CTod(""),GetDtDesemb((cAlias)->ED2_DI_NUM))

EndDo

For x := nLinMemo to MlCount(cDescricao,TAMDESCREL)//TAMDESC)
    RudD->(DBAPPEND())  // Grava o restante da descrição
    RudD->WK_SEQREL  := cSEQREL
    RudD->WKD_FLAG   := "F"
    RudD->WK_PED     := ED0->ED0_PD
    RudD->WKD_DESCR  := Alltrim(MemoLine(cDescricao,TAMDESCREL,x))
// acl
    If Len(aNFRUD) >= x
       RudD->WKD_NF     := aNFRUD[x][1]
       RudD->WKD_DTNF   := DtoC(aNFRUD[x][2])
    EndIf
    nTotLin := nTotLin + 1
          
    If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
       If nLin # 999 
          For i:= nTotLin to NUMLINRUD             
             RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
             RudD->WK_SEQREL := cSEQREL 
             RudD->WKD_FLAG  := "F"  
             RudD->WK_PED    := ED0->ED0_PD          
          Next i
          RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback"
          RudD->WK_SEQREL := cSEQREL
          RudD->WKD_FLAG  := "G"
          RudD->WK_PED    := ED0->ED0_PD
          RudD->WKD_LOCAL := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
          RudD->WKD_TOT_P  := Transf(nAnePeso, cPictPeso2)
          RudD->WKD_TOT_Q  := Alltrim(Transf(nAneQtde, cPictQtde))
          
          RudD->WKD_TOT_F  := Transf(nAneTot, cPictValor)
          
          RudD->WKD_TOTFRT := Transf(nTotFrete,"@E 999,999,999.99")
          RudD->WKD_TOTSEG := Transf(nTotSeguro,"@E 999,999,999.99")
          RudD->WKD_ASSRU1 := EasyGParam("MV_ASSRUD1",,"")
          RudD->WKD_ASSRU2 := EasyGParam("MV_ASSRUD2",,"")
             
          aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})//Imprimi totais por moeda
            For b := 1 To Len(aRudVlr)
                cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)
                &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)
                &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
            Next b
            aSort(aRudUnid,,,{|x,y| x[1] > y[1]})//Imprimi totais po Vlr de Embarque
            For a := 1 To Len(aRudunid)
                cUnAne   := aRudUnid[a,1]
                If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde)) //cPictValor
                cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                &cUnidade:= Alltrim(cUnAne)+" - "
            Next a
            
            TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
            
            aRudUnid:={}
            aRudVlr :={}
            nAnePeso  := 0
            nAneQtde  := 0
            nAneTot   := 0
            nTotFrete := 0
            nTotSeguro:= 0
            dDtRegi := (cAlias)->ED2_DTREG
            cDiNum  := (cAlias)->ED2_DI_NUM
            cAdicao := (cAlias)->ED2_ADICAO
            cNcm    := (cAlias)->ED2_NCM
        EndIf

        If x <> MlCount(cDescricao,TAMDESCREL) //!(cAlias)->(EOF()) .Or. nLinMemo <> MlCount(cDescricao,TAMDESCREL) - GFC 16/03/04
           RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback" (Importacao)
           nAnexoCal += 1
           nTotAneIm +=1
           RudD->WK_SEQREL := cSEQREL
           RudD->WKD_FLAG  := "E"
           RudD->WK_PED    := ED0->ED0_PD
           RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
           cLastFlag:= "E"
        Endif
        nLIN    := 0
        nTotLin := 0
    EndIf

Next x

// acl
If Len(aNFRUD) >= x
   For i:= x to Len(aNFRUD)
      RudD->(DBAPPEND())
      RudD->WK_SEQREL  := cSEQREL
      RudD->WK_PED     := ED0->ED0_PD
      RudD->WKD_FLAG   := "F"
      RudD->WKD_NF     := aNFRUD[i][1]
      RudD->WKD_DTNF   := DtoC(aNFRUD[i][2])
      nTotLin := nTotLin+1
   Next
Endif
aNFRUD := {}
nAnexoCal:= 0

/*
Testa se há agrupamento (por NCM ou Código de Item)
Caso haja, inclue registro com os valores totais
HFD
*/
If lAgrp
    nLIN    := nLIN + 1
    nTotLin := nTotLin + 1
           
    RudD->(DBAPPEND())  // Grava o Detail do RUD - "Relatorio Unico Drawback" com o Total por NCM 
    RudD->WK_SEQREL  := cSEQREL
    RudD->WKD_FLAG   := "F"
    RudD->WK_PED     := cPedido
    RudD->WKD_DI_ADI := ""
    RudD->WKD_DTREGI := ""                                                   // Dt Registro
    RudD->WKD_NCM    := Iif(cOrd == "2", cIte, "")                           // Ncm
    RudD->WKD_PARTNU := Iif(cOrd == "2","" , cCodProd)                       // Cod Item                               
    RudD->WKD_DESCR  := "TOTAL"                                              // Campo Totalizador
       
    nLinMemo += 1
       
    RudD->WKD_PESO   := Alltrim(Transf(nPesoT, cPictPeso2))                  // Peso
    RudD->WKD_QTDE   := Alltrim(Transf(nQtdT, cPictQt2))                     // Quantidade
    RudD->WKD_UNID   := cUnMed                                               // Unidade de Medida
    RudD->WKD_VAL_F  := Alltrim(Transf(nValFobT, cPictValor))                // Valor Total
    RudD->WKD_VALEMB := Alltrim(Transf(Round(nValEmbT,2),"@E 99,999,999,999.99"))   // Valor Local de Embarque
    RudD->WKD_MOEDA  := cMOEDA  //ED2->ED2_MOEDA
       
    nLIN    := nLIN + 1
    nTotLin := nTotLin + 1
    
    RudD->(DBAPPEND())     
    RudD->WKD_FLAG   := "F"  
    RudD->WK_SEQREL  := cSEQREL
    RudD->WK_PED     := cPedido
      
    nPesoT := nQtdT := nValEmbT := nValFobT := 0
EndIf

If nTotLin <> 0
   
   For i:= nTotLin to NUMLINRUD
      RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
      RudD->WK_SEQREL := cSEQREL
      RudD->WKD_FLAG  := "F"
      RudD->WK_PED    := ED0->ED0_PD
   Next i

   RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback" 
   RudD->WK_SEQREL := cSEQREL 
   RudD->WKD_FLAG  := "G"                       
   RudD->WK_PED    := ED0->ED0_PD        
   RudD->WKD_LOCAL := Upper(Left(cCidade,1))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
   RudD->WKD_TOT_P := Transf(nAnePeso, cPictPeso2)
   RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
   
   RudD->WKD_TOT_F := Transf(nAneTot, cPictValor)
   
   RudD->WKD_TOTFRT:= Transf(nTotFrete,"@E 999,999,999.99")
   RudD->WKD_TOTSEG:= Transf(nTotSeguro,"@E 999,999,999.99")
   RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
   RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

   //SAndra 
   aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
   For b := 1 To Len(aRudVlr)
      cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)    
      &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
      cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)    
      &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
   Next b
      
   aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
   For a := 1 To Len(aRudunid)
      cUnAne   := aRudUnid[a,1]
      If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
      cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
      &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde)) //cPictValor
      cUnidade := "RudD->WKD_UNI"+StrZero(a,2)    
      &cUnidade:= Alltrim(cUnAne)+" - "
   Next a
   
   TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
   
   aRudUnid:={}
   aRudVlr :={}
   nAnePeso  := 0
   nAneQtde  := 0
   nAneTot   := 0
   nTotFrete := 0
   nTotSeguro:= 0
Endif

TotParc("IMPR", "PARCIAL")

//RRC - 10/12/2012 - Tratamento para Compras Nacionais

nComp:=1
If !Empty(aComp)
   nLin := 999
EndIf
        
Do While nComp <= Len(aComp)

   /*If nCount > nTotal
      ProcRegua(nTotal)
      nCount:=0
   Else 
      IncProc(STR0014+"ED8...") //#STR0014->"Lendo "
      nCount++
   EndIf*/

   //SA5->(DbSeek(cFilSA5+aImp[nImp,4]))
   //-----SB1->(DbSeek(cFil_SB1+ED8->ED8_COD_I))

   /*If Empty(aComp[nComp,1])  //ED8_PEDIDO
      nComp += 1
      If lCabImp .AND. nComp>Len(aComp)
         RU150RODAPE()
      EndIF
      Loop
   EndIf
   */			
  //lCabImp:=.T.
			
   If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
      If nLin # 999
         //RU150RODAPE()
         If nTotLin <> 0
            For i:= nTotLin to NUMLINRUD
               RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
               RudD->WK_SEQREL := cSEQREL
               RudD->WKD_FLAG  := "D"
               RudD->WK_PED    := ED0->ED0_PD
            Next i
         
            RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback" 
            RudD->WK_SEQREL := cSEQREL 
            RudD->WKD_FLAG  := "G"                       
            RudD->WK_PED    := ED0->ED0_PD        
            RudD->WKD_LOCAL := Upper(Left(cCidade,1))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
            RudD->WKD_TOT_P := AllTrim(Transf(nAnePeso, cPictPeso2))
            RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
            RudD->WKD_TOT_F := Alltrim(Transf(nAneTot, cPictValor))
            RudD->WKD_TOTFRT:= Alltrim(Transf(nTotFrete,"@E 999,999,999.99"))
            RudD->WKD_TOTSEG:= Alltrim(Transf(nTotSeguro,"@E 999,999,999.99"))
            RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
            RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

            //SAndra 
            aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
            For b := 1 To Len(aRudVlr)
               cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)    
               &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
               cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)    
               &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
            Next b
      
            aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
            For a := 1 To Len(aRudunid)
               cUnAne   := aRudUnid[a,1]
               If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                  cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                  &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde)) //cPictValor
                  cUnidade := "RudD->WKD_UNI"+StrZero(a,2)    
                  &cUnidade:= Alltrim(cUnAne)+" - "
            Next a
   
            TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
   
            aRudUnid:={}
            aRudVlr :={}
            nAnePeso  := 0
            nAneQtde  := 0
            nAneTot   := 0
            nTotFrete := 0
            nTotSeguro:= 0
         EndIf
      EndIf        
      RudD->(DBAPPEND())  //Grava o Cabecalho de Compras Nacionais
      nAnexoCal += 1
      RudD->WK_SEQREL := cSEQREL
      RudD->WKD_FLAG  := "C" //RRC - 26/11/2012
              
      cLastFlag := "C" //RRC - 26/11/2012
              
      RudD->WK_PED    := ED0->ED0_PD
      RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
      nAnePeso := 0
      nAneQtde := 0
      nAneTot  := 0
      nLIN := 0
      nTotLin := 0
   EndIf
			 
   nLIN += 1
   nTotLin += 1
   //GFP - 24/10/2011 -  Grava corpo do RPT
   RudD->(DBAPPEND())   
   RudD->WK_SEQREL   := cSEQREL
   RudD->WK_PED      := ED0->ED0_PD
   RudD->WKD_FLAG    := "D" //RRC - 26/11/2012
           
   cLastFlag := "D" //RRC - 26/11/2012
            
   RudD->WKD_PEDCOM  := aComp[nComp,1]
   RudD->WKD_NCM     := aComp[nComp,6]
   RudD->WKD_PARTNU  := Alltrim(SB1->B1_COD)  
   RudD->WKD_DESCR   := aComp[nComp,8]
   RudD->WKD_PESO    := Alltrim(Transf(aComp[nComp,9], cPictPeso2))           
   RudD->WKD_QTD_AD  := Alltrim(Transf(aComp[nComp,11], cPictQt2))
   RudD->WKD_QTD_ES  := Alltrim(Transf(aComp[nComp,12], cPictQt2))
   RudD->WKD_VAL_R   := Alltrim(Transf(aComp[nComp,13], "@E 99,999,999,999.99"))
   RudD->WKD_VAL_D   := Alltrim(Transf(aComp[nComp,14], "@E 99,999,999,999.99"))

   nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(aComp[nComp,10])})

   nAneTot   += aComp[nComp,14]   // Total FOB US$
   nAnePeso  += aComp[nComp,9]    // Peso
   nAneQtde  += aComp[nComp,11]   // Quantidade
   nComp+=1
             
   If nComp>Len(aComp)
      //RU150RODAPE()
      If nTotLin <> 0
         For i:= nTotLin to NUMLINRUD
            RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
            RudD->WK_SEQREL := cSEQREL
            RudD->WKD_FLAG  := "D"
            RudD->WK_PED    := ED0->ED0_PD
         Next i
         
         RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback" 
         RudD->WK_SEQREL := cSEQREL 
         RudD->WKD_FLAG  := "G"                       
         RudD->WK_PED    := ED0->ED0_PD        
         RudD->WKD_LOCAL := Upper(Left(cCidade,1))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
         RudD->WKD_TOT_P := Alltrim(Transf(nAnePeso, cPictPeso2))
         RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
         RudD->WKD_TOT_F := Alltrim(Transf(nAneTot, cPictValor))
         RudD->WKD_TOTFRT:= Alltrim(Transf(nTotFrete,"@E 999,999,999.99"))
         RudD->WKD_TOTSEG:= Alltrim(Transf(nTotSeguro,"@E 999,999,999.99"))
         RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
         RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

         //SAndra 
         aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
         For b := 1 To Len(aRudVlr)
            cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)    
            &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
            cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)    
            &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
         Next b
      
         aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
         For a := 1 To Len(aRudunid)
            cUnAne   := aRudUnid[a,1]
            If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
               cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
               &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde)) //cPictValor
               cUnidade := "RudD->WKD_UNI"+StrZero(a,2)    
               &cUnidade:= Alltrim(cUnAne)+" - "
         Next a
   
         TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
   
         aRudUnid:={}
         aRudVlr :={}
         nAnePeso  := 0
         nAneQtde  := 0
         nAneTot   := 0
         nTotFrete := 0
         nTotSeguro:= 0
      EndIf   
   EndIf
   //TotParc("IMPR", "PARCIAL")
Enddo     


EE9->(DbSetOrder(2))

// ** AAF 10/10/05 - Ordenação do RUD Exportação.
If cOrd == "1"
   cAlias:= "ED1"
   ED1->(DbSetOrder(7))//Pedido+Dt.Embarque+Núm.RE
Else
   cAlias:= "WorkRUD2"   
Endif
// **

(cAlias)->(DbSeek(cFilEd1+ED0->ED0_PD))

dDtRegi := (cAlias)->ED1_DTEMBA//(cAlias)->ED1_DTRE//(cAlias)->ED1_DTEMBA
cRENum  := (cAlias)->ED1_RE
cCodProd:= (cAlias)->ED1_PROD
lPVez := .T.

(cAliasSB1)->(DbSeek(cFilSB1Aux+(cAlias)->ED1_PROD))
lAgrp := .F.
           
If Left(ED0->ED0_RUD, 1) == "1"
    nLin := 999
    nRudQtde:=0
    nAneTot :=  nAnePeso :=   nAneQtde :=  nTotLin := nTotFrete := nTotSeguro := 0
    dDtRegi := (cAlias)->ED1_DTEMBA//(cAlias)->ED1_DTRE//(cAlias)->ED1_DTEMBA
    cRENum  := (cAlias)->ED1_RE
    cCodProd:= (cAlias)->ED1_PROD
    nAnexoCal:= 0
    nTotAneEx:= 0
    
    cDescricao:=""
    IF EE9->(DbSeek(If(lMultiFil,(cAlias)->ED1_FILORI,xFilial("EE9"))+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
       IF !EMPTY(EE9->EE9_DESCRE)
          cDescricao := Alltrim(MSMM_DR(EE9->EE9_DESCRE,TAMDESCRE))
       ENDIF
    ELSEIF lTemED9Cpos .AND. EMPTY((cAlias)->ED1_PREEMB)//AWR - 14/04/09
       ED9->(DBSETORDER(4))//Essa ordem é nova
       IF ED9->(DbSeek(xFilial("ED9")+(cAlias)->ED1_RE+(cAlias)->ED1_SEQUEN))
          //cDescricao := ED9->ED9_DESC     
          cDescricao := CriaVar("ED9_DESC") //RRC - 14/05/2012 - Criação de variável devido a uso de campo virtual
       ENDIF
    ENDIF    
    If Empty(cDescricao)
       EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey((cAlias)->ED1_PROD,"EE2_COD")))
       cDescricao := Alltrim(MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP))
    EndIf
    cDescricao := AllTrim(cCodProd) + " - " + cDescricao //AOM - 18/07/2012
    cDescricao := StrTran( cDescricao, CRLF , " " )
    cDescricao := StrTran( cDescricao, Chr(13), " " )
    Do While At("  ",cDescricao) > 0
       cDescricao := StrTran( cDescricao, "  " , " " )
    EndDo
    nLinMemo := 1
    If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DESCRICAO_RUD"),) //Alcir Alves - 04-07-05
    Do While !(cAlias)->(Eof()) .And. (cAlias)->ED1_FILIAL == cFilEd1 .And. (cAlias)->ED1_PD == ED0->ED0_PD
      //  If cCodProd # ED1->ED1_PROD
       If !lPVez
             For x:=nLinMemo to MlCount(cDescricao,TAMDESCREL+8)//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
                 RudD->(DBAPPEND())  // Grava o restante da descrição
                 RudD->WK_SEQREL  := cSEQREL
                 //NOPADO por RRC - 07/12/2012
                 //RudD->WKD_FLAG   := "P" //RudD->WKD_FLAG   := "F" - AOM - 25/05/2
                 RudD->WKD_FLAG   := "J"
                 RudD->WK_PED     := ED0->ED0_PD
                 RudD->WKD_DESCR  := Alltrim(MemoLine(cDescricao,TAMDESCREL+8,x))//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
                 
                 // ACL
                 If Len(aNFRUD) >= x
                    RudD->WKD_NF     := aNFRUD[x][1]
                    RudD->WKD_DTNF   := DtoC(aNFRUD[x][2])
                 EndIf   
                 nTotLin := nTotLin + 1
                 If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
                      If nLin # 999 
                         For i:= nTotLin to NUMLINRUD                            
                            RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
                            RudD->WK_SEQREL := cSEQREL
                            //NOPADO por RRC 07/12/2012 
                            //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
                            RudD->WKD_FLAG  := "J"
                            RudD->WK_PED    := ED0->ED0_PD          
                         Next    
                         RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback"
                         RudD->WK_SEQREL := cSEQREL
                         RudD->WKD_FLAG  := "G"
                         RudD->WK_PED    := ED0->ED0_PD
                         RudD->WKD_LOCAL := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
                         RudD->WKD_TOT_P := Transf(nAnePeso, cPictPeso2)
                         RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
                         
                         RudD->WKD_TOT_F := Transf(nAneTot, cPictValor)
                         
                         RudD->WKD_TOTFRT:= Transf(nTotFrete,"@E 999,999,999.99")
                         RudD->WKD_TOTSEG:= Transf(nTotSeguro,"@E 999,999,999.99")
                         RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
                         RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")
                         
                         aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})//Imprimi totais por moeda
                         For b := 1 To Len(aRudVlr)                        
                             cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)
                             &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                             cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)
                             &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
                         Next b
                         aSort(aRudUnid,,,{|x,y| x[1] > y[1]})//Imprimi totais po Vlr de Embarque
                         For a := 1 To Len(aRudunid)
                             cUnAne   := aRudUnid[a,1]
                             If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                             cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                             &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictValor))
                             cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                             &cUnidade:= Alltrim(cUnAne)+" - "
                         Next a

                         TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)

                         aRudUnid:={}
                         aRudVlr :={}
                         nAneTot    := 0
                         nAnePeso   := 0
                         nAneQtde   := 0
                      EndIf                                  

                      RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback" (Importacao)
                      nAnexoCal += 1
                      nTotAneEx +=1 
                      RudD->WK_SEQREL := cSEQREL 
                      RudD->WKD_FLAG  := "K"           
                      RudD->WK_PED    := ED0->ED0_PD                        
                      RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
                      nLIN    := 0
                      nTotLin := 0
                      cLastFlag := "K" //AAF 18/05/05
                 EndIf

             Next x
// acl           
             If Len(aNFRUD) > x
                For i:= x to Len(aNFRUD)
                   RudD->(DBAPPEND())
                   RudD->WK_SEQREL  := cSEQREL
                   RudD->WK_PED     := ED0->ED0_PD
                   //NOPADO por RRC 07/12/2012 
                   //RudD->WKD_FLAG   := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
                   RudD->WKD_FLAG := "J"
                   RudD->WKD_NF     := aNFRUD[i][1]
                   RudD->WKD_DTNF   := DtoC(aNFRUD[i][2])
                   nTotLin := nTotLin+1
                Next
             Endif
             If Len(aNFRUD) > 0
                RudD->(DBAPPEND())
                RudD->WK_SEQREL  := cSEQREL
                RudD->WK_PED     := ED0->ED0_PD
                //NOPADO por RRC 07/12/2012 
                //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
                RudD->WKD_FLAG  := "J"
                aNFRUD := {}
                nTotLin := nTotLin+1
             EndIf

              /*
              Testa se há agrupamento (por NCM ou Código de Item)
              Caso haja, inclue registro com os valores totais
              HFD
              */
             if lAgrp
                nLIN    := nLIN + 1
                nTotLin := nTotLin + 1
    
                RudD->(DBAPPEND())  // Grava o Detail do RUD - "Relatorio Unico Drawback" com o Total por NCM 
                RudD->WK_SEQREL  := cSEQREL
                //NOPADO por RRC - 07/12/2012
                //RudD->WKD_FLAG   := "P" //RudD->WKD_FLAG   := "F"  - AOM - 01/06/2012
                RudD->WKD_FLAG := "J"
                RudD->WK_PED     := cPedido
                RudD->WKD_DI_ADI := ""
                RudD->WKD_DTREGI := ""                                           // Dt Registro
                RudD->WKD_NCM    := Iif(cOrd == "2", cIte, "")                   // NCM
                RudD->WKD_PARTNU := Iif(cOrd == "2","" , cCodProd)               // Cod Item                                        
                RudD->WKD_DESCR  := "TOTAL"                                      // Campo Totalizador

                nLinMemo += 1
                RudD->WKD_PESO   := Alltrim(Transf(nPesoT, cPictPeso2))          // Peso
                RudD->WKD_QTDE   := Alltrim(Transf(nQtdT, cPictQt2))             // Quantidade
                RudD->WKD_UNID   := cUnMed                                       // Unidade de Medida
                RudD->WKD_VAL_F  := Alltrim(Transf(nValFobT, cPictValor))        // Valor Total
                RudD->WKD_VALEMB := Alltrim(Transf(Round(nValEmbT,2),"@E 99,999,999,999.99"))   // Valor Local de Embarque
                RudD->WKD_MOEDA  := cMOEDA  //ED2->ED2_MOEDA
       
                //Acréscimo de linha para espaçamento
                nLIN    := nLIN + 1
                nTotLin := nTotLin + 1               
    
                RudD->(DBAPPEND())
                //NOPADO por RRC - 07/12/2012     
                //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012 
                RudD->WKD_FLAG  := "J" 
                RudD->WK_SEQREL  := cSEQREL
                RudD->WK_PED     := cPedido
       
                nPesoT := nQtdT := nValEmbT := nValFobT := 0
             EndIf             
             
             cCodProd:= (cAlias)->ED1_PROD
             (cAliasSB1)->(DbSeek(cFilSB1Aux+cCodProd))
             
             cDescricao := ""
             IF EE9->(DbSeek(If(lMultiFil,(cAlias)->ED1_FILORI,xFilial("EE9"))+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
                IF !EMPTY(EE9->EE9_DESCRE)
                   cDescricao := Alltrim(MSMM_DR(EE9->EE9_DESCRE,TAMDESCRE))
                ENDIF
             ELSEIF lTemED9Cpos .AND. EMPTY((cAlias)->ED1_PREEMB)//AWR - 14/04/09
                ED9->(DBSETORDER(4))//Essa ordem é nova
                IF ED9->(DbSeek(xFilial("ED9")+(cAlias)->ED1_RE+(cAlias)->ED1_SEQUEN))
                   //cDescricao := ED9->ED9_DESC     
                   cDescricao := CriaVar("ED9_DESC") //RRC - 14/05/2012 - Criação de variável devido a uso de campo virtual
                ENDIF
             ENDIF
             
             If Empty(cDescricao)
                EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey((cAlias)->ED1_PROD,"EE2_COD")))
                cDescricao := Alltrim(MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP))
             EndIf
             cDescricao := AllTrim(cCodProd) + " - " + cDescricao //AOM - 18/07/2012
             cDescricao := StrTran( cDescricao, CRLF , " " )
             cDescricao := StrTran( cDescricao, Chr(13), " " )
             Do While At("  ",cDescricao) > 0
                cDescricao := StrTran( cDescricao, "  " , " " )
             EndDo
             nLinMemo := 1
             If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DESCRICAO_RUD"),) //Alcir Alves - 04-07-05
       EndIf

// ACL        
       If Len(aNFRUD) = 0
          If Left(cOrdNF,1) == "1"
             If lEECFAT = .F.
                //cFilEES:= xFilial("EES") //AAF 14/09/05 - Filial do EES.
                cFilEES:= If(lMultiFil,(cAlias)->ED1_FILORI,xFilial("EES")) //AJP 26/06/2007
                If EES->(DbSeek(cFilEES+(cAlias)->ED1_PREEMB))
                   aNFRUD := {}
                   While EES->(!Eof()) .and. EES->EES_FILIAL == cFilEES .AND. EES->EES_PREEMB = (cAlias)->ED1_PREEMB //AAF 14/09/05 - Verifica filial do EES.
                      If EES->EES_COD_I = (cAlias)->ED1_PROD
                        Aadd(aNFRUD,{EES->EES_NRNF, EES->EES_DTNF, EES->EES_COD_I})
                      EndIf
                      EES->(DbSkip())
                   EndDo
                EndIf
             Else
               //cFilSD2 := xFilial("SD2") //AAF 14/09/05 - Filial do SD2.
               cFilSD2 := If(lMultiFil,(cAlias)->ED1_FILORI,xFilial("SD2")) //AJP 26/06/2007 MULTIFIL
               
               SD2->(DbSetOrder(8))
               If !EMPTY((cAlias)->ED1_PREEMB) .AND. SD2->(DbSeek(cFilSD2+(cAlias)->ED1_PREEMB))
                  aNFRUD := {}
                  While SD2->(!Eof()) .and. SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_PREEMB = (cAlias)->ED1_PREEMB//AAF 14/09/05 - Verifica filial do SD2.
                     If SD2->D2_COD = (cAlias)->ED1_PROD
                        Aadd(aNFRUD,{SD2->D2_DOC, SD2->D2_EMISSAO, SD2->D2_COD})
                     EndIf
                     SD2->(DbSkip())
                  EndDo
               EndIf
            EndIf
         EndIf   
      EndIf
        nPESO := nQTDE := nPRE_F := nVALEMB := 0
        lPVez := .F.
           
        If lMultiFil //AJP 26/06/2007
           EE9->(DbSeek((cAlias)->ED1_FILORI+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
        Else
           EE9->(DbSeek(xFilial("EE9")+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
        EndIf
        
        cNcm    := (cAlias)->ED1_NCM //Guarda NCM anterior
        
        Do While !(cAlias)->(Eof()) .And. (cAlias)->ED1_FILIAL == cFilEd1 .And. (cAlias)->ED1_PD == ED0->ED0_PD .and. ;
                 dDtRegi = (cAlias)->ED1_DTEMBA/*(cAlias)->ED1_DTRE*/ .and. cRENum  = (cAlias)->ED1_RE .and. cCodProd = (cAlias)->ED1_PROD //(cAlias)->ED1_DTEMBA
                          
             cUNIDAD  := (cAlias)->ED1_UMNCM
             cUnMed:=cUNIDAD  //Alcir Alves - 02-05-05
             If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),)  
             
             nRudFob  := ConvVal((cAlias)->ED1_MOEDA,(cAlias)->ED1_VAL_EM,(cAlias)->ED1_DTRE,"E")//(cAlias)->ED1_DTEMBA
             
             cPedido := ED0->ED0_PD
             IF !Empty(EE9->EE9_POSIPI)
                cIte := Alltrim(Transf(EE9->EE9_POSIPI, cPictNcm))
             ELSE
                IF lTemED9Cpos .AND. EMPTY((cAlias)->ED1_PREEMB)//AWR - 14/04/09
                   ED9->(DBSETORDER(4))//Essa ordem é nova
                   IF ED9->(DbSeek(xFilial("ED9")+(cAlias)->ED1_RE+(cAlias)->ED1_SEQUEN))
                      cIte := Alltrim(Transf(ED9->ED9_NCM, cPictNcm))
                   ENDIF
                ELSE
                   cIte := Alltrim(Transf((cAlias)->ED1_NCM, cPictNcm))    // Ncm  #  (cAlias)->ED1_NCM
                ENDIF    
             endif
             cMOEDA  := (cAlias)->ED1_MOEDA                             //Moeda
//           cAliasRDM := "ED1"  //HFD - 26.mar.2009 - Assim como no caso de importação há que passar para o RDMake o alias atual.
             cAliasRDM := cAlias
             If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"MOEDARUDE"),)

             nPESO   += (cAlias)->ED1_PESO
             nQTDE   += (cAlias)->ED1_QTDNCM
             nPRE_F  += nRudFob
             nVALEMB += (cAlias)->ED1_VAL_EM

             nAneTot    += nRudFob
             nAnePeso   += (cAlias)->ED1_PESO
             nAneQtde   += (cAlias)->ED1_QTDNCM

             // Totalizadores por NCM ou Cod. Item
             // HFD
             if (cOrd == "2" .and. cNcm == (cAlias)->ED1_NCM) .or. (cOrd == "3" .and. cCodProd == (cAlias)->ED1_PROD) 
    	        nPesoT    += (cAlias)->ED1_PESO
                nQtdT     += (cAlias)->ED1_QTDNCM
	            nValEmbT  += (cAlias)->ED1_VAL_EM
    	        nValFobT  += nRudFob
    	     endIf

             (cAlias)->(DbSkip())
        EndDo

        If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI 
            If nLin # 999 
                For i:= nTotLin to NUMLINRUD
                     RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
                     RudD->WK_SEQREL := cSEQREL
                     //NOPADO por RRC - 07/12/2012     
                     //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
                     RudD->WKD_FLAG  := "J"  
                     RudD->WK_PED    := ED0->ED0_PD          
                  Next             

                  nAneTot    -= nPRE_F
                  nAnePeso   -= nPESO
                  nAneQtde   -= nQTDE

                  RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback" 
                  RudD->WK_SEQREL := cSEQREL 
                  RudD->WKD_FLAG  := "G"                       
                  RudD->WK_PED    := ED0->ED0_PD
                  RudD->WKD_LOCAL := Upper(Left(cCidade,1))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
                  RudD->WKD_TOT_P := Transf(nAnePeso, cPictPeso)
                  RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
                  
                  RudD->WKD_TOT_F := Transf(nAneTot, cPictVl)
                  
                  RudD->WKD_TOTFRT:= Transf(nTotFrete,"@E 999,999,999.99")
                  RudD->WKD_TOTSEG:= Transf(nTotSeguro,"@E 999,999,999.99")
                  RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
                  RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

                  aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
                  aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
 
                  For a := 1 To Len(aRudunid)                  
                      cUnAne   := aRudUnid[a,1]
                      If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                      cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                      &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictValor))
                      cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                      &cUnidade:= Alltrim(cUnAne)+" - "
                  Next a

                  For b := 1 To Len(aRudVlr)
                      cCampo   := "RudD->WKD_TVEM"+StrZero(b,2)
                      &cCampo  := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                      cUnidade := "RudD->WKD_MVEM"+StrZero(b,2)
                      &cUnidade:= Alltrim(aRudVlr[b,1])+" - "
                  Next b

                  TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)

                  aRudUnid := {}
                  aRudVlr  := {}
         
                  nAneTot  := nPRE_F
                  nAnePeso := nPESO
                  nAneQtde := nQTDE
            EndIf     
           
            RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback"(Exportacao) 
            nAnexoCal += 1
            nTotAneEx += 1
            RudD->WK_SEQREL := cSEQREL 
            RudD->WKD_FLAG  := "K"           
            RudD->WK_PED    := ED0->ED0_PD                        
            RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)                        
           cLastFlag:= "K"
            nLIN    := 0
            nTotLin := 0                            
        EndIf                             
        
        nLIN    := nLIN + 1
        nTotLin := nTotLin + 1
        RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
        RudD->WK_SEQREL  := cSEQREL 
        //NOPADO por RRC - 07/12/2012
        //RudD->WKD_FLAG   := "P" //"F" - GFP - 22/03/2012
        RudD->WKD_FLAG   := "J"
        RudD->WK_PED     := cPedido
        RudD->WKD_DI_ADI := Transf(cRENum, cPicRe)       // RE
        RudD->WKD_DTREGI := Dtoc(dDtRegi)                // Dt Embarque
        RudD->WKD_NCM    := cIte                         // Ncm 
        RudD->WKD_PARTNU := cCodProd                     // Cod. Mercadoria

        If nLinMemo <= MlCount(cDescricao,TAMDESCREL+8)//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
           RudD->WKD_DESCR  := Alltrim(MemoLine(cDescricao,TAMDESCREL+8,nLinMemo))//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
           If Len(aNFRUD) > 0
              RudD->WKD_NF     := aNFRUD[1][1]
              RudD->WKD_DTNF   := DtoC(aNFRUD[1][2])
           EndIF   
        Else
           RudD->WKD_DESCR  := Alltrim(cCodProd)
           If Len(aNFRUD) > 0
              RudD->WKD_NF     := aNFRUD[1][1]
              RudD->WKD_DTNF   := DtoC(aNFRUD[1][2])
           EndIF   
        EndIf
        nLinMemo        += 1
        RudD->WKD_PESO   := Alltrim(Transf(nPESO, cPictPeso))   // Peso Total
        RudD->WKD_QTDE   := Alltrim(Transf(nQTDE, cPictQt))   // Qtde Total
        RudD->WKD_UNID   := cUnMed //EE9->EE9_UNIDAD//ED1->ED1_UMPROD                             // Unidade de Medida
        RudD->WKD_VAL_F  := Alltrim(Transf(nPRE_F, cPictVlEm)) // Valor FOB        
        RudD->WKD_VALEMB := Alltrim(Transf(Round(nVALEMB,2),"@E 99,999,999,999.99"))        // Valor Local de Embarque
        RudD->WKD_MOEDA  := cMOEDA                                                          //Moeda
        RudD->WKD_SEGURO := Alltrim(Transf(0,"@E 99,999,999,999.99"))        //Vlr.Seguro
        RudD->WKD_FR_USS := Alltrim(Transf(0,"@E 99,999,999,999.99"))        //Vlr.Frete

        
        //Testa se há agrupamento (por NCM ou Código de Item)
        lAgrp := (cOrd == "2" .and. cNcm <> (cAlias)->ED1_NCM .or.;
                 cOrd == "3" .AND. cCodProd <> (cAlias)->ED1_PROD)

        nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(cUNIDAD)})
        nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(cMOEDA)})
           
        If nUM = 0
           AADD(aRudUnid,{Alltrim(cUNIDAD),nQTDE/*nRudQtde*/})
        Else
           aRudUnid[nUM,2] += nQTDE
        EndIf
            
        If nVL = 0
            AADD(aRudVlr ,{Alltrim(cMOEDA),Round(nVALEMB,2)})
        Else
            aRudVLR[nVL,2] += Round(nVALEMB,2)
        EndIf

         dDtRegi := (cAlias)->ED1_DTEMBA//(cAlias)->ED1_DTRE//(cAlias)->ED1_DTEMBA
         cRENum  := (cAlias)->ED1_RE
        cNcm    := (cAlias)->ED1_NCM   // Guarda a NCM anterior

         If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"DETALHE_EXP"),)
    Enddo
    For x:=nLinMemo to MlCount(cDescricao,TAMDESCREL+8)//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
         RudD->(DBAPPEND())  // Grava o restante da descrição
         RudD->WK_SEQREL  := cSEQREL
         //NOPADO por RRC - 07/12/2012
         //RudD->WKD_FLAG   := "P" //RudD->WKD_FLAG   := "F" - AOM - 25/05/2012 - Para imprimir alinha as descrições quando é efetuada a quebra.
         RudD->WKD_FLAG   := "J"
         RudD->WK_PED     := ED0->ED0_PD            
         RudD->WKD_DESCR := Alltrim(MemoLine(cDescricao,TAMDESCREL+8,x))//AOM - 02/07/2012 - aumenta a descrição do produto a exportar
// acl
         If Len(aNFRUD) >= x
            RudD->WKD_NF     := aNFRUD[x][1]
            RudD->WKD_DTNF   := DtoC(aNFRUD[x][2])
         EndIf
         nTotLin  += 1
         nLinMemo += 1
         If nTotLin > NUMLINRUD .OR. nLIN > NUMLINDI
             If nLin # 999 
                 For i:= nTotLin to NUMLINRUD
                      RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
                      RudD->WK_SEQREL := cSEQREL
                      //NOPADO por RRC - 07/12/2012
                      //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
                      RudD->WKD_FLAG  := "J"
                      RudD->WK_PED    := ED0->ED0_PD
                  Next
                  RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback"
                  RudD->WK_SEQREL := cSEQREL
                  RudD->WKD_FLAG  := "G"
                  RudD->WK_PED    := ED0->ED0_PD
                  RudD->WKD_LOCAL := Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
                  RudD->WKD_TOT_P := Transf(nAnePeso, cPictPeso2)
                  RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
                  
                  RudD->WKD_TOT_F := Transf(nAneTot, cPictValor)
                  
                  RudD->WKD_TOTFRT:= Transf(nTotFrete,"@E 999,999,999.99")
                  RudD->WKD_TOTSEG:= Transf(nTotSeguro,"@E 999,999,999.99")
                  RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
                  RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

                  aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})//Imprimi totais por moeda
                  For b := 1 To Len(aRudVlr)         
                       cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(b,2)
                       &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
                       cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(b,2)
                       &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
                  Next b
                  aSort(aRudUnid,,,{|x,y| x[1] > y[1]})//Imprimi totais po Vlr de Embarque
                  For a := 1 To Len(aRudunid)
                       cUnAne := aRudUnid[a,1]
                       If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                       cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
                       &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictValor))
                       cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
                       &cUnidade:= Alltrim(cUnAne)+" - "
                  Next a
                  
                  TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)
                  
                  aRudUnid:={}
                  aRudVlr :={}
                  dDtRegi := (cAlias)->ED1_DTEMBA//(cAlias)->ED1_DTRE//(cAlias)->ED1_DTEMBA
                  cRENum  := (cAlias)->ED1_RE
                  cCodProd:= (cAlias)->ED1_PROD
             EndIf

             RudD->(DBAPPEND())  //Grava o Cabecalho do RUD- "Relatorio Unico Drawback" (Importacao)
             nAnexoCal += 1
             nTotAneEx += 1
             RudD->WK_SEQREL := cSEQREL
             RudD->WKD_FLAG  := "K"
             RudD->WK_PED    := ED0->ED0_PD
             RudD->WKD_ANEXO := StrZero(nAnexoCal,3,0)
             nLIN    := 0
             nTotLin := 0
             cLastFlag:= "K"
         EndIf

    Next x 
        
// acl
    If Len(aNFRUD) >= x
       For i:= x to Len(aNFRUD)
          RudD->(DBAPPEND())
          RudD->WK_SEQREL  := cSEQREL
          RudD->WK_PED     := ED0->ED0_PD
          //NOPADO por RRC - 07/12/2012
          //RudD->WKD_FLAG  := "P" //RudD->WKD_FLAG  := "F"  - AOM - 05/06/2012
          RudD->WKD_FLAG   := "J"
          RudD->WKD_NF     := aNFRUD[i][1]
          RudD->WKD_DTNF   := DtoC(aNFRUD[i][2])
          nTotLin := nTotLin+1
       Next
    Endif
    nAnexoCal := 0
      
    /*
     Testa se há agrupamento (por NCM ou Código de Item)
     Caso haja, inclue registro com os valores totais
     HFD
    */    
    if lAgrp 
       nLIN    := nLIN + 1
       nTotLin := nTotLin + 1
    
       RudD->(DBAPPEND())  // Grava o Detail do RUD - "Relatorio Unico Drawback" com o Total por NCM 
       RudD->WK_SEQREL  := cSEQREL
       //NOPADO por RRC - 07/12/2012
       //RudD->WKD_FLAG   := "P"  //AOM - 28/05/2012 - RudD->WKD_FLAG   := "F"
       RudD->WKD_FLAG   := "J"
       RudD->WK_PED     := cPedido
       RudD->WKD_DI_ADI := ""
       RudD->WKD_DTREGI := ""                                                          // Dt Registro
       RudD->WKD_NCM    := Iif(cOrd == "2", cIte, "")                                  // Ncm
       RudD->WKD_PARTNU := Iif(cOrd == "2","" , cCodProd)                              // Cod. Item                      
       RudD->WKD_DESCR  := "TOTAL"                                                     // Campo Totalizador

       nLinMemo += 1
       RudD->WKD_PESO   := Alltrim(Transf(nPesoT, cPictPeso2))                         // Peso
       RudD->WKD_QTDE   := Alltrim(Transf(nQtdT, cPictQt2))                            // Quantidade
       RudD->WKD_UNID   := cUnMed                                                      // Unidade de Medida
       RudD->WKD_VAL_F  := Alltrim(Transf(nValFobT, cPictValor))                       // Valor Total
       RudD->WKD_VALEMB := Alltrim(Transf(Round(nValEmbT,2),"@E 99,999,999,999.99"))   // Valor Local de Embarque
       RudD->WKD_MOEDA  := cMOEDA  //ED2->ED2_MOEDA
       
       //Acréscimo de linha para espaçamento
       nLIN    := nLIN + 1
       nTotLin := nTotLin + 1
    
       RudD->(DBAPPEND())     
       //NOPADO por RRC - 07/12/2012
       //RudD->WKD_FLAG   := "P"  //AOM - 28/05/2012 - RudD->WKD_FLAG   := "F" 
       RudD->WKD_FLAG   := "J"
       RudD->WK_SEQREL  := cSEQREL
       RudD->WK_PED     := cPedido
       nPesoT := nQtdT := nValEmbT := nValFobT := 0
    EndIf      
      
    For i:= nTotLin to NUMLINRUD
        RudD->(DBAPPEND())  // Grava o Detail do RUD- "Relatorio Unico Drawback" 
        RudD->WK_SEQREL := cSEQREL 
        //NOPADO por RRC - 07/12/2012
        //RudD->WKD_FLAG  := "P" //"F" - GFP - 22/03/2012
        RudD->WKD_FLAG  := "J"
        RudD->WK_PED    := ED0->ED0_PD
    Next
    
    RudD->(DBAPPEND())  // Grava o Rodape do RUD- "Relatorio Unico Drawback" 
    RudD->WK_SEQREL := cSEQREL 
    RudD->WKD_FLAG  := "G"                       
    RudD->WK_PED    := ED0->ED0_PD        
    RudD->WKD_LOCAL := Upper(Left(cCidade,1))+Alltrim(Lower(Right(cCidade,19)))+", "+dData//Upper(Alltrim(SYT->YT_CIDADE))+", "+dData
    RudD->WKD_TOT_P := Transf(nAnePeso, cPictPeso)
    RudD->WKD_TOT_Q := Alltrim(Transf(nAneQtde, cPictQtde))
    
    RudD->WKD_TOT_F := Transf(nAneTot, cPictVlEm)
    
    RudD->WKD_TOTFRT:= Transf(nTotFrete,"@E 999,999,999.99")
    RudD->WKD_TOTSEG:= Transf(nTotSeguro,"@E 999,999,999.99")
    RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
    RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

    aSort(aRudUnid,,,{|x,y| x[1] > y[1]})
    aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})
         
    For a := 1 To Len(aRudunid)
        cUnAne   := aRudUnid[a,1]
        If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
        cCampo   := "RudD->WKD_TUNI"+StrZero(a,2)
        &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictValor))
        cUnidade := "RudD->WKD_UNI"+StrZero(a,2)
        &cUnidade:= Alltrim(cUnAne)+" - "
    Next a

    For b := 1 To Len(aRudVlr)
        cCampo   := "RudD->WKD_TVEM"+StrZero(b,2)
        &cCampo  := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
        cUnidade := "RudD->WKD_MVEM"+StrZero(b,2)
        &cUnidade:= Alltrim(aRudVlr[b,1])+" - "
    Next b
    dDtRegi := (cAlias)->ED1_DTEMBA//(cAlias)->ED1_DTRE//(cAlias)->ED1_DTEMBA
    cRENum  := (cAlias)->ED1_RE

    TotParc("TOTAL",,nAnePeso, nAneTot, nAneQtde, nTotFrete, nTotSeguro, aRudVlr)

    aRudUnid := {}
    aRudVlr  := {}
                                          
    RudD->WKD_ASSRU1:= EasyGParam("MV_ASSRUD1",,"")
    RudD->WKD_ASSRU2:= EasyGParam("MV_ASSRUD2",,"")

    TotParc("IMPR", "PARCIAL")
Endif

SW8->(DbSetOrder(1))
SW7->(dbSetOrder(1))
EE9->(DbSetOrder(1))

Return .T.

*-----------------------------------------------------------------------------------------------*
Function PA150Assin()
*-----------------------------------------------------------------------------------------------*
Local cAssRud1:=EasyGParam("MV_ASSRUD1",,""), cAssRud2:=EasyGParam("MV_ASSRUD2",,"")
Local cAssPed1:=EasyGParam("MV_PEDATO1",,""), cAssPed2:=EasyGParam("MV_PEDATO2",,"")
Local nOpcao:=0, oDlg
Local oPanel

cAssRud1 := cAssRud1 + Space(80 - Len(cAssRud1))
cAssRud2 := cAssRud2 + Space(80 - Len(cAssRud2))
cAssPed1 := cAssPed1 + Space(80 - Len(cAssPed1))
cAssPed2 := cAssPed2 + Space(80 - Len(cAssPed2))

DEFINE MSDIALOG oDlg TITLE STR0054 ; //"Assinaturas"
       FROM 0, 0 TO 20, 85 OF GetWndDefault()

   oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
   @1.2, 01 SAY   STR0054+STR0055   of oPanel  //"Assinaturas"###" RUD"
   @1.2, 20 SAY   STR0054+STR0056   of oPanel  //"Assinaturas"###" Pedido"   
   @1.8,  0.5 TO 05, 19             of oPanel
   @1.8, 19.5 TO 05, 38             of oPanel
   
   @03,  1.4 MSGET cAssRud1 SIZE 120, 8 of oPanel
   @04,  1.4 MSGET cAssRud2 SIZE 120, 8 of oPanel
   @03, 20.4 MSGET cAssPed1 SIZE 120, 8 of oPanel
   @04, 20.4 MSGET cAssPed2 SIZE 120, 8 of oPanel

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()},,,,,,,.F.) CENTERED

If nOpcao=1
   PutMV("MV_ASSRUD1",cAssRud1)
   PutMV("MV_ASSRUD2",cAssRud2)
   PutMV("MV_PEDATO1",cAssPed1)
   PutMV("MV_PEDATO2",cAssPed2)
EndIf

Return .T.

*-----------------------------------------------------------------------------------*
Static Function PA150AneQtd(cMod,nx)
*-----------------------------------------------------------------------------------*
Local ix:=0, nAneAux, aPerda:={},nLin:=0, i, nz, ny

If nx <= 1

If cMod == "E"
   nAneAux := cAnexoExp + 1
Else
   nAneAux := cAnexoImp + 1
EndIf
//nAnexoImp += 1
DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
DET->WK_SEQREL  := cSEQREL
DET->WK_LCS     := "A"
DET->WKD_ANEXO  := StrZero(nAneAux,3)
DET->WK_PED     := ED0->ED0_PD
DET->WK_FLAG    := "1"
AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
 
DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
DET->WK_SEQREL := cSEQREL
DET->WK_LCS    := "B"
DET->WK_PED    := ED0->ED0_PD

If cMod == "E"
   DET->WKD_DISCR := 'Continuação do campo 26 do pedido de "Drawback":' 
   nLin += 1 // NCCF 17/02/09
Else
   DET->WKD_DISCR := 'Continuação do campo 14 do pedido de "Drawback":'
   nLin += 1 // NCCF 17/02/09
EndIf
AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
             
DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
DET->WK_SEQREL := cSEQREL
DET->WK_LCS    := "B"
DET->WK_PED    := ED0->ED0_PD
DET->WKD_DOC_E := "SUPRIMIR" // NCCF 17/02/09

AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
                                 
DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
DET->WK_SEQREL := cSEQREL
DET->WK_PED    := ED0->ED0_PD
DET->WK_LCS    := "B"
DET->WKD_PESO  := "     Unid. Medida"
DET->WKD_QTDE  := "     Quant. Total"
AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
             
DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
DET->WK_SEQREL := cSEQREL
DET->WK_LCS    := "B"
DET->WK_PED    := ED0->ED0_PD
DET->WKD_DOC_E := "SUPRIMIR"

AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
nLin += 3
                
For ix:=1 to Len(aAneQtdTot)

   If nLin > NUMDELIN1
      DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "C"
      DET->WK_PED    := ED0->ED0_PD
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO,DET->WKD_PESO})
 
      DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "D"
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
      DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
      DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO,DET->WKD_PESO})
      nLin:=1
                      
      nAneAux += 1
      DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
      DET->WK_SEQREL  := cSEQREL                  
      DET->WK_LCS     := "A"
      DET->WKD_ANEXO  := StrZero(nAneAux,3)
      DET->WK_PED     := ED0->ED0_PD
      DET->WK_FLAG    := "1"
         
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO,DET->WKD_PESO})

      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_LCS    := "B"
      DET->WK_PED    := ED0->ED0_PD 
      
      If cMod == "E"
         DET->WKD_DISCR := 'Continuação do campo 26 do pedido de "Drawback":'
         nLin += 1 // NCCF 17/02/09
      Else
         DET->WKD_DISCR := 'Continuação do campo 14 do pedido de "Drawback":' 
         nLin += 1 // NCCF 17/02/09
      EndIf
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO,DET->WKD_PESO})

      DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
      DET->WK_SEQREL := cSEQREL
      DET->WK_PED    := ED0->ED0_PD
      DET->WK_LCS    := "B"
      DET->WKD_PESO  := "     Unid. Medida"
      DET->WKD_QTDE  := "     Quant. Total"
      AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                   DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                   DET->WKD_ANEXO,DET->WKD_PESO})

     DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
     DET->WK_SEQREL := cSEQREL
     DET->WK_LCS    := "B"
     DET->WK_PED    := ED0->ED0_PD
     DET->WKD_DOC_E := "SUPRIMIR" // NCCF 17/02/09
     
     AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                  DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                  DET->WKD_ANEXO,DET->WKD_PESO})
     nLin += 2 // NCCF 17/02/09
   EndIf
   DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   DET->WK_LCS    := "B"
   DET->WK_PED    := ED0->ED0_PD
   
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
   
   DET->(DBAPPEND())     // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   DET->WK_LCS    := "B"
   DET->WK_PED    := ED0->ED0_PD
   DET->WKD_PESO  := aAneQtdTot[ix,1] //Unidade de Medida
   DET->WKD_QTDE  := Transf(aAneQtdTot[ix,2], cPictQt) //Quantidade Total na Unidade 
   DET->WKD_DOC_E := "SUPRIMIR"
   
   If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_DET_ANEXO"),)//AAF 11/07/05 - Gravação dos detalhes do anexo.
   
   AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                DET->WKD_ANEXO,DET->WKD_PESO})
   nLin += 2 // NCCF 17/02/09
Next ix

If nLin <= NUMDELIN1
   k:= 1
   For i:=nLin to NUMDELIN1 //Completa os itens do corpo
       DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
       DET->WK_SEQREL := cSEQREL
       DET->WK_PED    := ED0->ED0_PD
       DET->WK_LCS    := "B"
       If k/2 == int(k/2)
          DET->WKD_DOC_E := "SUPRIMIR" // NCCF 17/02/09
       EndIf
       k++
       
       AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
                    DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
                    DET->WKD_ANEXO,DET->WKD_PESO})
   Next i
EndIf
DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
DET->WK_SEQREL := cSEQREL 
DET->WK_LCS    := "C"  
DET->WK_PED    := ED0->ED0_PD
AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})
DET->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
DET->WK_SEQREL := cSEQREL
DET->WK_LCS    := "D"
DET->WK_PED    := ED0->ED0_PD
DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")
AaDD(aPerda,{DET->WK_SEQREL,DET->WK_LCS,DET->WK_PED,DET->WKD_PORIMP,DET->WKD_DISCR,;
             DET->WKD_QTDE,DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WK_LOCALDT,DET->WK_FLAG,;
             DET->WKD_ANEXO,DET->WKD_PESO})

cAliasAux := "DET"
For ny := 1 To 4
   If ny>1
      cAliasAux := "DET"+Alltrim(Str(ny))
   EndIf
   For nz :=1 To Len(aPerda) //Imprimi cinco vias do anexo para percentual de perda
      (cAliasAux)->(DBAPPEND()) //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
      (cAliasAux)->WK_SEQREL  := aPerda[nz,1]
      If aPerda[nz,2] = "D"
         (cAliasAux)->WK_LCS := "S"
         If ny = 1 //flag para a impressão da mensagem das vias no rodapé
            (cAliasAux)->WK_FLAG  := "2"
         ElseIf ny = 2
            (cAliasAux)->WK_FLAG  := "3"
         ElseIf ny = 3
            (cAliasAux)->WK_FLAG  := "4"
              ElseIf ny = 4
            (cAliasAux)->WK_FLAG  := "5"
         EndIf
      Else
         (cAliasAux)->WK_LCS := aPerda[nz,2]
         (cAliasAux)->WK_FLAG:= aPerda[nz,10]
      EndIf
      (cAliasAux)->WK_PED     := aPerda[nz,3]
      (cAliasAux)->WKD_PORIMP := aPerda[nz,4]
      (cAliasAux)->WKD_PESO   := aPerda[nz,12]
      (cAliasAux)->WKD_QTDE   := aPerda[nz,6]
      (cAliasAux)->WK_LOCALDT := aPerda[nz,9]
      (cAliasAux)->WKD_ANEXO  := aPerda[nz,11]
      (cAliasAux)->WKD_DISCR  := aPerda[nz,5]
      (cAliasAux)->WKD_DOC_E  := aPerda[nz,7] // NCCF 17/02/09
   Next nz
Next ny

EndIf

If cMod == "E"
   If nx <= 1
      If cAnexoExp+1 <> nAneAux
         (cAliasCab)->WK_TOTQTD1:= " VIDE ANEXOS"    // NCCF 17/02/09
         (cAliasCab)->WK_TOTQTD := " DE "+StrZero(cAnexoExp+1,3)+" À "+StrZero(nAneAux,3)
      Else
         (cAliasCab)->WK_TOTQTD1:= " VIDE ANEXO "+StrZero(nAneAux,3)    // NCCF 17/02/09
      EndIf
      cAnexoExp := nAneAux
   Else
      (cAliasCab)->WK_TOTQTD1:= CAB->WK_TOTQTD1
      (cAliasCab)->WK_TOTQTD := CAB->WK_TOTQTD
   EndIf
Else
   If nx <= 1
      If cAnexoImp+1 <> nAneAux
         (cAliasCab)->WK_TOTQTD2:= " VIDE ANEXOS" // NCCF 17/02/09
         (cAliasCab)->WK_TOTQTD3:= " DE "+StrZero(cAnexoImp+1,3)+" À "+StrZero(nAneAux,3)
      Else
         (cAliasCab)->WK_TOTQTD2:= " VIDE ANEXO "+StrZero(nAneAux,3)  // NCCF 17/02/09
      EndIf
      cAnexoImp := nAneAux
   Else
      (cAliasCab)->WK_TOTQTD2:= CAB->WK_TOTQTD2
      (cAliasCab)->WK_TOTQTD3:= CAB->WK_TOTQTD3
   EndIf
EndIf

Return .T.

*---------------------------------------------------------------------------------------------*
Static Function PA150Ordem(lComeco)
*---------------------------------------------------------------------------------------------*
If lComeco
   SYD->(DBSETORDER(1))
   If Left(cOrdAnexo,1)=="1"
      ED1->(DBSETORDER(8)) //6
      ED3->(DBSETORDER(6)) //5
      ED4->(DBSETORDER(6)) //5
   Else
      ED1->(DBSETORDER(2))
      ED3->(DBSETORDER(7))
      ED4->(DBSETORDER(7))
   EndIf
   ED2->(DBSETORDER(1))
   ED5->(DBSETORDER(3))
   ED0->(MSUNLOCKALL())
   ED0->(DBSETORDER(2))
   EE2->(DbSetOrder(1))
   SB1->(dbSetOrder(1))
Else
   ED5->(dbSetOrder(1))
   CAB->(DBGOTOP())
   DET->(DBGOTOP())
EndIf

Return .T.

*-----------------------------------------------------------------------------------------------*
Function PA150OrdRUD()
*-----------------------------------------------------------------------------------------------*
Local cOrdRud:=EasyGParam("MV_ORDRUD",,"1"), nOpcao:=0, oDlg, oCbxOrd
Local aOrd:={"1- Dt. registro + DI + Adição / Dt. registro RE + RE + Anexo",;
             "2- NCM + Dt. registro + DI + Adição / NCM + Código de item + Dt. Registro + RE + Anexo",;
             "3- Código do Item/Produto + NCM + Dt. registro + DI + Adição / NCM + Código de item + Dt. Registro + RE + Anexo"}
Local oPanel

DEFINE MSDIALOG oDlg TITLE STR0076 ; //"Ordem RUD"
       FROM 0,0 TO 15,80 OF GetWndDefault()

   oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @02,01 SAY  STR0079 of oPanel //"Ordem de Impressão do RUD"
   @02,11 ComboBox oCbxOrd Var cOrdRud Items aOrd SIZE 210,08 of oPanel

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()},,,,,,,.F.) CENTERED

If nOpcao=1
   PutMV("MV_ORDRUD",cOrdRud)
EndIf

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function GeraWorkRUD()
*----------------------------------------------------------------------------------------------*
Local aSemSX3ED2:={}, aSemSX3ED1:={}, cDiOri := ""
Private aHeader[0], aCampos:=Array(ED2->(fCount()))  //E_CriaTrab utiliza

AADD(aSemSX3ED2,{"ED2_PD","C",AVSX3("ED2_PD",3),0})
AADD(aSemSX3ED2,{"ED2_INVOIC","C",AVSX3("ED2_INVOIC",3),0})
AADD(aSemSX3ED2,{"ED2_AC","C",AVSX3("ED2_AC",3),0})
AADD(aSemSX3ED2,{"ED2_DI_NUM","C",AVSX3("ED2_DI_NUM",3),0})
AADD(aSemSX3ED2,{"ED2_UMNCM","C",AVSX3("ED2_UMNCM",3),0})
if lED2Umanex // ACSJ - 18/11/2004
   AADD(aSemSX3ED2,{"ED2_UMANEX","C",AVSX3("ED2_UMANEX",3),0})
Endif
AADD(aSemSX3ED2,{"ED2_PESO","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)}) //TAN AADD(aSemSX3ED2,{"ED2_PESO","N",AVSX3("ED2_PESO",3),AVSX3("ED2_PESO",4)})
AADD(aSemSX3ED2,{"ED2_SEQ","C",AVSX3("ED2_SEQ",3),0})
AADD(aSemSX3ED2,{"ED2_PGI_NU","C",AVSX3("ED2_PGI_NU",3),0})
AADD(aSemSX3ED2,{"ED2_ADICAO","C",AVSX3("ED2_ADICAO",3),0})
AADD(aSemSX3ED2,{"ED2_MOEDA","C",AVSX3("ED2_MOEDA",3),0})
AADD(aSemSX3ED2,{"ED2_MARCA","C",2,0})
AADD(aSemSX3ED2,{"ED2_TX_MOE","N",AVSX3("ED2_TX_MOE",3),AVSX3("ED2_TX_MOE",4)})
AADD(aSemSX3ED2,{"ED2_RECNO" ,"N",10,0})
AADD(aSemSX3ED2,{"ED2_POSICA","C",AVSX3("ED2_POSICA",3),0})
AADD(aSemSX3ED2,{"ED2_DTREG","D",8,0})
AADD(aSemSX3ED2,{"ED2_TX_USS","N",AVSX3("ED2_TX_USS",3),AVSX3("ED2_TX_USS",4)})
AADD(aSemSX3ED2,{"ED2_HAWB","C",AVSX3("ED2_HAWB",3),0})
AADD(aSemSX3ED2,{"ED2_QTDNCM","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)})
AADD(aSemSX3ED2,{"ED2_VL_MOE","N",AVSX3("ED2_VL_MOE",3),AVSX3("ED2_VL_MOE",4)})
AADD(aSemSX3ED2,{"ED2_PO_NUM","C",AVSX3("ED2_PO_NUM",3),0})
AADD(aSemSX3ED2,{"ED2_FILIAL","C",2,0})
AADD(aSemSX3ED2,{"ED2_VALORI","N",AVSX3("ED2_VALORI",3),AVSX3("ED2_VALORI",4)})
AADD(aSemSX3ED2,{"ED2_SEQSIS","C",AVSX3("ED2_SEQSIS",3),0})
//AST 30/06/08 - Verifica se o campo é usado antes de adicionar no array.
If !X3Uso(Posicione("SX3",2,"ED2_FRETE","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_FRETE","N",AVSX3("ED2_FRETE",3),AVSX3("ED2_FRETE",4)})
EndIf   
If !X3Uso(Posicione("SX3",2,"ED2_FR_USS","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_FR_USS","N",AVSX3("ED2_FR_USS",3),AVSX3("ED2_FR_USS",4)})
EndIf                                                
If !X3Uso(Posicione("SX3",2,"ED2_MOE_FR","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_MOE_FR","C",AVSX3("ED2_MOE_FR",3),0})
EndIF                                                
If !X3Uso(Posicione("SX3",2,"ED2_TX_FR","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_TX_FR","N",AVSX3("ED2_TX_FR",3),AVSX3("ED2_TX_FR",4)})
EndIf                                 
If !X3Uso(Posicione("SX3",2,"ED2_SEGURO","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_SEGURO","N",AVSX3("ED2_SEGURO",3),AVSX3("ED2_SEGURO",4)})
EndIf                                  
If !X3Uso(Posicione("SX3",2,"ED2_SE_USS","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_SE_USS","N",AVSX3("ED2_SE_USS",3),AVSX3("ED2_SE_USS",4)})
EndIf                                  
If !X3Uso(Posicione("SX3",2,"ED2_MOE_SE","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_MOE_SE","C",AVSX3("ED2_MOE_SE",3),0})
EndIf
If !X3Uso(Posicione("SX3",2,"ED2_TX_SE","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_TX_SE","N",AVSX3("ED2_TX_SE",3),AVSX3("ED2_TX_SE",4)})
EndIf   
cDiOri := ""
If ED2->(FieldPos("ED2_DI_ORI")) > 0
   AADD(aSemSX3ED2,{"ED2_DI_ORI",AVSX3("ED2_DI_ORI",2),AVSX3("ED2_DI_ORI",3),AVSX3("ED2_DI_ORI",4)})
   AADD(aSemSX3ED2,{"ED2_ADANT",AVSX3("ED2_ADANT",2),AVSX3("ED2_ADANT",3),AVSX3("ED2_ADANT",4)})
   cDiOri := "+ED2_DI_ORI+ED2_ADANT"
EndIf

FileWork:=E_CriaTrab("ED2",aSemSX3ED2,"WorkRud",,.F.)
If cOrd == "2"
   IndRegua("WorkRud",FileWork+TEOrdBagExt(),"ED2_PD+ED2_NCM+DtoS(ED2_DTREG)+ED2_DI_NUM+ED2_ADICAO+ED2_ITEM"+cDiOri)
Else
   IndRegua("WorkRud",FileWork+TEOrdBagExt(),"ED2_PD+ED2_ITEM+ED2_NCM+DtoS(ED2_DTREG)+ED2_DI_NUM+ED2_ADICAO"+cDiOri)
EndIf

SET INDEX TO (FileWork+TEOrdBagExt())
WorkRud->(dbSetOrder(1))

AADD(aSemSX3ED1,{"ED1_FILIAL","C",2,0})
AADD(aSemSX3ED1,{"ED1_PD","C",AVSX3("ED1_PD",3),0})
AADD(aSemSX3ED1,{"ED1_AC","C",AVSX3("ED1_AC",3),0})
AADD(aSemSX3ED1,{"ED1_RE","C",AVSX3("ED1_RE",3),0})
AADD(aSemSX3ED1,{"ED1_UMNCM","C",AVSX3("ED1_UMNCM",3),0})
AADD(aSemSX3ED1,{"ED1_UMANEX","C",AVSX3("ED1_UMANEX",3),0})
AADD(aSemSX3ED1,{"ED1_PESO","N",AVSX3("ED1_QTDNCM",3),AVSX3("ED1_QTDNCM",4)})
AADD(aSemSX3ED1,{"ED1_SEQ","C",AVSX3("ED1_SEQ",3),0})
AADD(aSemSX3ED1,{"ED1_ANEXO","C",AVSX3("ED1_ANEXO",3),0})
AADD(aSemSX3ED1,{"ED1_MOEDA","C",AVSX3("ED1_MOEDA",3),0})
AADD(aSemSX3ED1,{"ED1_TX_MOE","N",AVSX3("ED1_TX_MOE",3),AVSX3("ED1_TX_MOE",4)})
AADD(aSemSX3ED1,{"ED1_RECNO" ,"N",10,0})
AADD(aSemSX3ED1,{"ED1_PREEMB","C",AVSX3("ED1_PREEMB",3),0})
AADD(aSemSX3ED1,{"ED1_PEDIDO","C",AVSX3("ED1_PEDIDO",3),0})
AADD(aSemSX3ED1,{"ED1_SEQUEN","C",AVSX3("ED1_SEQUEN",3),0})
AADD(aSemSX3ED1,{"ED1_DTEMBA","D",8,0})
AADD(aSemSX3ED1,{"ED1_DTRE"  ,"D",8,0})
AADD(aSemSX3ED1,{"ED1_TX_USS","N",AVSX3("ED1_TX_USS",3),AVSX3("ED1_TX_USS",4)})
AADD(aSemSX3ED1,{"ED1_QTDNCM","N",AVSX3("ED1_QTDNCM",3),AVSX3("ED1_QTDNCM",4)})
AADD(aSemSX3ED1,{"ED1_VL_MOE","N",AVSX3("ED1_VL_MOE",3),AVSX3("ED1_VL_MOE",4)})
AADD(aSemSX3ED1,{"ED1_VALORI","N",AVSX3("ED1_VALORI",3),AVSX3("ED1_VALORI",4)})

FileWork2:=E_CriaTrab("ED1",aSemSX3ED1,"WorkRud2",,.F.)
If cOrd == "2"
   IndRegua("WorkRud2",FileWork2+TEOrdBagExt(),"ED1_FILIAL+ED1_PD+ED1_NCM+ED1_PROD+DtoS(ED1_DTEMBA)+ED1_RE+ED1_ANEXO")
Else
   IndRegua("WorkRud2",FileWork2+TEOrdBagExt(),"ED1_FILIAL+ED1_PD+ED1_PROD+ED1_NCM+DtoS(ED1_DTEMBA)+ED1_RE+ED1_ANEXO")//+ED1_ITEM+ED2_NCM+DtoS(ED2_DTREG)+ED2_DI_NUM+ED2_ADICAO")
EndIf

SET INDEX TO (FileWork2+TEOrdBagExt())
WorkRud2->(dbSetOrder(1))

Return .T.

*---------------------------------------------------------------------------------------------*
Static Function GrvWorkRUD()
*---------------------------------------------------------------------------------------------*
Local cFilSW8 := xFilial("SW8"),cFilEE9:= xFilial("EE9"), cCampo:="", ED2TotCpos:=ED2->(FCount()), ED1TotCpos:=ED1->(FCount())
Local i, cFilED8:= XFILIAL("ED8")
WorkRud->(avzap())
dbSelectArea("ED2")
Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL == cFilEd2 .and. ED2->ED2_PD == ED0->ED0_PD
   If (lMultiFil,cFilSW8:=ED2->ED2_FILORI,) //AJP 26/06/2007
   SW8->(DbSeek(cFilSW8+ED2->ED2_HAWB+ED2->ED2_INVOIC+ED2->ED2_PO_NUM+ED2->ED2_POSICA+ED2->ED2_PGI_NU))
   WorkRud->(RecLock("WorkRud",.T.))
   For i := 1 To ED2TotCpos
      cCampo:=FIELDNAME(i)
      WorkRud->&(cCampo) := ED2->&(cCampo)
   Next i
   If !Empty(SW8->W8_TEC)
      WorkRud->ED2_NCM  := SW8->W8_TEC
   elseif ED8->(DBSEEK(cFilED8+ED2->ED2_DI_NUM+ED2->ED2_ADICAO+ED2->ED2_POSICA)) //lEDCDIE .and. - NOPADO POR AOM - 04/11/10      
      WorkRud->ED2_NCM  := ED8->ED8_NCM         
   EndIf
   WorkRud->ED2_RECNO:= ED2->(RECNO())
   WorkRud->(msUnlock())
   ED2->(dbSkip())
EndDo
WorkRud->(dbGoTop())

//AAF 10/10/05 - Ordenação do RUD Exportação.
EE9->(DbSetOrder(2))

WorkRud2->(avzap())
dbSelectArea("ED1")
ED1->( dbSeek(cFilED1+ED0->ED0_PD) )
Do While !ED1->(EOF()) .and. ED1->ED1_FILIAL == cFilEd1 .and. ED1->ED1_PD == ED0->ED0_PD   
   If (lMultiFil,cFilEE9:=ED1->ED1_FILORI,) //AJP 26/06/2007 Multifil
   EE9->( dbSeek(cFilEE9+ED1->ED1_PREEMB+ED1->ED1_PEDIDO+ED1->ED1_SEQUEN))
   
   WorkRud2->(RecLock("WorkRud2",.T.))
   For i := 1 To ED1TotCpos
      cCampo:=FIELDNAME(i)
      WorkRud2->&(cCampo) := ED1->&(cCampo)
   Next i
   If !Empty(EE9->EE9_POSIPI)
      WorkRud2->ED1_NCM  := EE9->EE9_POSIPI
   ELSEIF lTemED9Cpos .AND. EMPTY(ED1->ED1_PREEMB)//AWR - 14/04/09
      ED9->(DBSETORDER(4))//Essa ordem é nova
      IF ED9->(DbSeek(xFilial("ED9")+ED1->ED1_RE+ED1->ED1_SEQUEN))
         WorkRud2->ED1_NCM := ED9->ED9_NCM
      ENDIF
   ENDIF    
   WorkRud2->ED1_RECNO:= ED1->(RECNO())
   WorkRud2->( MsUnLock() )
   ED1->(dbSkip())
EndDo

WorkRud2->(dbGoTop())

Return .T.

*------------------------------------*
Static Function EDCPAMLCOUNT(cAlias)
*------------------------------------*
Local ni

For ni := 2 To MlCount(If(cAlias=="E", cDescr,cDescricao),TAMDESCPED)
   nLIN := nLIN+1
   DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
   DET->WK_SEQREL := cSEQREL
   If(lAdit, DET->WK_SEQPED := StrZero(Val(cSEQPED),8), )
   DET->WK_LCS    := "B"
   DET->WK_PED    := ED0->ED0_PD
   DET->WKD_DISCR := Alltrim(Memoline(If(cAlias=="E", cDescr,cDescricao),TAMDESCPED,ni))
   AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                 DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                 DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                 DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                 DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                 DET->WKD_VALEMB,DET->WKD_NF})
Next ni

Return .T.

*-----------------------------------------------------------------------------------------------*
Function PA150OrdAne()
*-----------------------------------------------------------------------------------------------*
Local nOpcao:=0, oDlg, oCbxOrd, cImpPrcu:=If(EasyGParam("MV_IMPPRCU",,.T.),STR0084,STR0085) //"1 - Sim" # "2 - Nao"
Local aOrd:={STR0081,STR0082} //"1 - UM Comp/Vend + NCM + Item/Prod" # "2 - NCM + Item/Prod + UM Comp/Vend"
Local aImpPrcu:={STR0084,STR0085} //"1 - Sim" # "2 - Nao"
Local oCbxImp
Local oPanel
cOrdAnexo:=EasyGParam("MV_ORDANE",,"1")

DEFINE MSDIALOG oDlg TITLE STR0080 ; //"Ordem Anexo"
       FROM 0, 0 TO 15, 80 OF GetWndDefault()

   oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   @02,01 SAY  STR0083 of oPanel //"Ordem de Impressão do Anexo"
   @02,11 ComboBox oCbxOrd Var cOrdAnexo Items aOrd SIZE 105,08 of oPanel
   @03,01 SAY  STR0086 of oPanel //"Imprime preço unitário?"
   @03,11 ComboBox oCbxImp Var cImpPrcu Items aImpPrcu SIZE 60,08 of oPanel

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()},,,,,,, .F.) CENTERED

If nOpcao=1
   // ** PLB 24/04/06 - Caso necessite de atualizacao do indice, bloqueia ordenacao tipo '1' ate que o usuario baixe e suba a tabela
   //MFR 26/03/2019 OSSME-2704
   /*If lManut
      MsgStop(STR0087)  // "Manutencao necessaria. Favor entrar em contato com o Suporte Average para atualizacao da Ordenacao de Impressao do Anexo."
      Return .F.
   Else */
      PutMV("MV_ORDANE" ,cOrdAnexo)
      PutMV("MV_IMPPRCU",If(Left(cImpPrcu,1)=="1",.T.,.F.))
   //EndIf
   // **
EndIf

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function AneAditImp()
*-----------------------------------------------------------------------------------------------*
Local i

lED0Deduzp := SX3->(DBSeek("ED0_DEDUZP"))
lED0SubTot := SX3->(DBSeek("ED0_SUBTOT"))
lED1Umanex := SX3->(DBSeek("ED1_UMANEX"))
lED2Inat   := SX3->(DBSeek("ED2_INAT"))
lED2Umanex := SX3->(DBSeek("ED2_UMANEX"))

            ED4->(DbSeek(cFilED4+cPed))
            ED0->(DbSeek(cFilEd0+ED4->ED4_AC))            
   
            nLIN := 999
            cNCM := cItem := ""
            cAnexoImp := ED4->ED4_ANEXO 
            nValTot1 := nPesoTot1:= nQtdTot1 := nSomaTot := 0
            nValCab1 := nPesoCab1:= nQtdCab1 := 0      
            nValIte1 := nPesoIte1:= nQtdIte1 := 0            
            nTotNCMPeso := nTotNCMQtd := nTotNCMTotal:= 0              
                     
            Do While !ED4->(EOF()) .And. ED4->ED4_FILIAL == cFilED4 .And. ED4->ED4_PD == cPed

               //AAF 21/07/05
               cUnMed:= ED4->ED4_UMNCM
               If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"UNIDADE_MEDIDA"),) //AAF 21/07/05 
               If !ED4->ED4_ANEXO $ (cNumAux) .Or. cTipo <> "I"
                  ED4->(dbSkip())
                  Loop
               Endif
      
               SB1->(DbSeek(cFilSb1+ED4->ED4_ITEM))
                              
               If MlCount(cDescricao,TAMDESCPED)+nLIN >= NUMDELIN .Or. cAnexoImp <> ED4->ED4_ANEXO .Or. lPVez
                  cAnexoImp := ED4->ED4_ANEXO
                  lPVez := .F.
                  If cNCM # "" 

                     nLIN := nLIN+1
                     SB1->(DbSeek(cFilSb1+cItem))
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD
                     //DET->WKD_DISCR := Alltrim(SB1->B1_DESC)+STR0032+SB1->B1_COD   //7.Discriminacao do Produto ###" - "
                     cDescricao     := Alltrim(cItem)+" - "
                     DescImp()
                     DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,1)) 
                     DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso2)             //5.Peso Liquido
                     DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt2)                //6.Quantidade NCM
                     If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                        aAdd(aAneQtd,{cUMCom,nQtdIte1})
                     Else
                        aAneQtd[nPos,2] += nQtdIte1
                     EndIf
                     DET->WKD_TOT_F := Transf(nValIte1, cPictValor)              //10.Total
                     If(lImpPrcUn, DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni),)     //9.Preco FOB
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                   DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                   DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                   DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                   DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                   DET->WKD_VALEMB,DET->WKD_NF})

                     EDCPAMLCOUNT("I")
                     
                     if lED0SubTot   // ACSJ - 18/11/2004

                        If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                           nLIN := nLIN+1 
                           DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                           DET->WK_SEQREL := cSEQREL 
                           DET->WK_LCS    := "B"  
                           DET->WK_PED    := ED0->ED0_PD               
                           DET->WKD_ITE   := STR0018 //"Total...:"               
                           DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso2)
                           DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt2)
                           DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictValor)

                           AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                         DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                         DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                         DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                         DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                         DET->WKD_VALEMB,DET->WKD_NF})
                        Endif                 
                        
                     Endif
                     DET->(DBAPPEND())  //Grava os Totais(Peso,Qtde e Fob)dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                      
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                     
                     DET->WK_LCS    := "C"  
                     DET->WK_PED    := ED0->ED0_PD               
                     DET->WKD_PESO  := Transf(nPesoTot1,cPictPeso)//cPictPeTot)
                     //DET->WKD_QTDE  := Transf(nQtdTot1,cPictQtde)
                     DET->WKD_QTDE  := ""
                     DET->WKD_QTDE2 := ""
                     If Len(aAneQtd) <= 6
                        For i:=1 to Len(aAneQtd)
                           cUnAne:= aAneQtd[i,1]
                           If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOT_ANEXO"),)//AAF 11/07/05 - Gravação dos totais do anexo.
                           If i<=3
                              DET->WKD_QTDE := Alltrim(DET->WKD_QTDE)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                           Else
                              DET->WKD_QTDE2:= Alltrim(DET->WKD_QTDE2)+Alltrim(Transf(aAneQtd[i,2],cPictQtde))+"-"+cUnAne+"; "
                           EndIf
                        Next i
                     EndIf
                     aAneQtd := {}
                     
                     DET->WKD_TOT_F := Transf(nValTot1,cPictFob)
                     nValTot1 := nPesoTot1:= nQtdTot1 := 0     
               
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})

                     DET->(DBAPPEND())  //Grava o Rodapé (Local e Data, Ass. Autor. e Nome)dos Anexos
                     DET->WK_SEQREL := cSEQREL 
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                     DET->WK_LCS    := "D"
                     DET->WK_PED    := ED0->ED0_PD
                     DET->WK_LOCALDT:= Alltrim(Upper(Left(Alltrim(cCidade),1)))+Alltrim(Lower(Right(cCidade,19)))+", "+dData
                     DET->WKD_ASSRU1 := EasyGParam("MV_PEDATO1",,"")
                     DET->WKD_ASSRU2 := EasyGParam("MV_PEDATO2",,"")

                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF,DET->WKD_QTDE2})
                  EndIf                                    
                  
                  DET->(DBAPPEND())  //Grava o Cabecalho dos Anexos Principais
                  DET->WK_SEQREL  := cSEQREL                  
                  DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                  
                  DET->WK_LCS     := "A"
                  DET->WKD_PORIMP := "X"
                  DET->WK_PED     := ED0->ED0_PD            
                  DET->WKD_ANEXO  := cAnexoImp
                  DET->WK_FLAG    := "1"
                  nLIN := 0
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})

                  If cNCM # "" 
                     cNCM  := ED4->ED4_NCM
                     cItem := ED4->ED4_ITEM
                     nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
                     nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    

                     nLIN := nLIN+1                                  
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                      
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                     
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD            
                     DET->WKD_ITE   := Transf(ED4->ED4_NCM, cPictNcm2)   //4.Item da tarifa           
                     DET->WKD_QTDE  := cUnMed //SB1->B1_UM                     //6.Quantidade
                     If lImpPrcUn
                        DET->WKD_PRE_F := STR0019 //"US$"                   //9.Preco FOB
                     Else
                        DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total
                     Endif   
                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
                  Endif   
               EndIf
                  
               SYD->(DbSeek(cFilSyd+ED4->ED4_NCM))
               If cNCM # ED4->ED4_NCM .or. cItem # ED4->ED4_ITEM
                  If cNCM # ""                            
                     nLIN := nLIN+1 
                     SB1->(DbSeek(cFilSb1+cItem)) 
                     DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                     DET->WK_SEQREL := cSEQREL                      
                     DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                     
                     DET->WK_LCS    := "B"
                     DET->WK_PED    := ED0->ED0_PD               
                     SB1->(DbSeek(xFilial("SB1")+If(Select("QRY")#0,QRY->ED2_ITEM,cItem)))
                     //cDescricao     := Alltrim(MSMM(SB1->B1_DESC_I,TAMDESC))+" - "+If(Select("QRY")#0,QRY->ED2_ITEM,cItem)
                     cDescricao := Alltrim(cItem)+" - "
                     DescImp()
                     DET->WKD_DISCR := Alltrim(MemoLine(cDescricao,TAMDESCPED,1)) 
                     DET->WKD_PESO  := Transf(nPesoIte1, cPictPeso2)             //5.Peso Liquido
                     DET->WKD_QTDE  := Transf(nQtdIte1, cPictQt2)                //6.Quantidade NCM
                     If (nPos:=aScan(aAneQtd,{|x| x[1]==cUMCom})) = 0
                        aAdd(aAneQtd,{cUMCom,nQtdIte1})
                     Else
                        aAneQtd[nPos,2] += nQtdIte1
                     EndIf
                     DET->WKD_TOT_F := Transf(nValIte1, cPictValor)              //10.Total
                     If(lImpPrcUn, DET->WKD_PRE_F := Transf(nValIte1/nQtdIte1,cPictUni),) //9.Preco FOB

                     AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})

                     EDCPAMLCOUNT("I")
                     
                     if lED0SubTot   // ACSJ - 18/11/2004
                     
                        If ED0->ED0_SUBTOT == "1" //Imprime Subtotais
                           nLIN := nLIN+1 
                           DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                           DET->WK_SEQREL := cSEQREL 
                           DET->WK_LCS    := "B"  
                           DET->WK_SEQPED := StrZero(Val(cSEQPED),8)
                           DET->WK_PED    := ED0->ED0_PD               
                           DET->WKD_ITE   := STR0018 //"Total...:"               
                           DET->WKD_PESO  := Transf(nTotNCMPeso, cPictPeso2)
                           DET->WKD_QTDE  := Transf(nTotNCMQtd, cPictQt2)
                           DET->WKD_TOT_F := Transf(nTotNCMTotal, cPictValor)
         
                           AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                                         DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                                         DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                                         DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                                         DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                                         DET->WKD_VALEMB,DET->WKD_NF})
                        Endif                   
                         
                     Endif

                     If nLIN == (NUMDELIN - 1)
                        nLIN := nLIN+1                                  
                        DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais
                        DET->WK_SEQREL := cSEQREL                      
                        DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                        
                        DET->WK_LCS    := "B"                                 
                        DET->WK_PED    := ED0->ED0_PD               
                        AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
                        Loop
                     Endif  

                  EndIf
                                  
                  cNCM  := ED4->ED4_NCM
                  cItem := ED4->ED4_ITEM
                  nTotNCMPeso := nTotNCMQtd  := nTotNCMTotal:= 0         
                  nValIte1 := nPesoIte1:= nQtdIte1 := 0                                                                                                                    

                  nLIN := nLIN+1                                  
                  DET->(DBAPPEND())  // Grava o Detail(Corpo) dos Anexos Principais  
                  DET->WK_SEQREL := cSEQREL                   
                  DET->WK_SEQPED := StrZero(Val(cSEQPED),8)                  
                  DET->WK_LCS    := "B"
                  DET->WK_PED    := ED0->ED0_PD            
                  DET->WKD_ITE   := Transf(ED4->ED4_NCM, cPictNcm2)      //4.Item da tarifa           
                  DET->WKD_QTDE  := cUnMed //SB1->B1_UM                       //6.Quantidade
                  If lImpPrcUn
                     DET->WKD_PRE_F := STR0019 //"US$"                  //9.Preco FOB
                  Else
                     DET->WKD_TOT_F := STR0019 //"US$"                  //10.Total
                  Endif   
                  AAdd(aDetail,{DET->WK_SEQREL,DET->WK_PED,DET->WK_LCS,DET->WKD_ITE,DET->WKD_PORIMP,;
                             DET->WKD_EXPORT,DET->WKD_PESO,DET->WKD_QTDE,DET->WKD_DISCR,;
                             DET->WKD_DOC_E,DET->WKD_PRE_F,DET->WKD_TOT_F,DET->WKD_TOT_P,;
                             DET->WKD_TOT_Q,DET->WKD_ANEXO,DET->WKD_DI_ADI,DET->WKD_DTREGI,;
                             DET->WKD_PARTNU,DET->WKD_AGENCI,DET->WKD_CARTA,DET->WKD_CONTAT,DET->WK_FLAG,;
                             DET->WKD_VALEMB,DET->WKD_NF})
               Endif
                      
               If lED0Deduzp .AND. ED0->ED0_DEDUZP == "1" .AND. ED4->ED4_QTD<>ED4->ED4_QTDCAL
                  nCoef    := Round(ED4->ED4_QTDCAL / ED4->ED4_QTD,2)
                  
                  nTotNCMPeso += If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
                  nTotNCMQtd  += ED4->ED4_QTDNCM * nCoef
                  nTotNCMTotal+= ED4->ED4_VALCAL
          
                  nPesoTot1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
                  nQtdTot1 += ED4->ED4_QTDNCM * nCoef
                  nValTot1 += ED4->ED4_VALCAL
                  
                  nQtdIte1 += ED4->ED4_QTDNCM * nCoef
                  nValIte1 += ED4->ED4_VALCAL
                  nPesoIte1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
                  
                  nPesoCab1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO*nCoef)
                  nQtdCab1 += ED4->ED4_QTDNCM * nCoef
                  nValCab1 += ED4->ED4_VALCAL
               Else
                  nTotNCMPeso += If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
                  nTotNCMQtd  += ED4->ED4_QTDNCM       
                  nTotNCMTotal+= ED4->ED4_VALEMB
          
                  nPesoTot1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
                  nQtdTot1 += ED4->ED4_QTDNCM
                  nValTot1 += ED4->ED4_VALEMB
               
                  nQtdIte1 += ED4->ED4_QTDNCM
                  nValIte1 += ED4->ED4_VALEMB
                  nPesoIte1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
                  
                  nPesoCab1+= If(Empty(ED4->ED4_PESO),SB1->B1_PESO, ED4->ED4_PESO)
                  nQtdCab1 += ED4->ED4_QTDNCM
                  nValCab1 += ED4->ED4_VALEMB
               EndIf
               cUMCom   := ED4->ED4_UMNCM
                  
               ED4->(DbSkip())
            Enddo     

            PA150FIM("I")
         
      //   Next nPosAnexo
      //EndIf
      
Return .T.

//AAF 18/05/05
Static Function TotParc(cFlagImp, cTipoTot, nTotPeso, nVlTot, nTotQtde, nTotFrete, nTotSeg, aVlRud)
Local nInd

// GFP - 27/10/2011 - Tratamento para Compras e Vendas Nacionais.
If cLastFlag == "E"
   cTotFlag := "R"
ElseIf cLastFlag == "K"
   cTotFlag := "S"
ElseIf cLastFlag == "C"
   cTotFlag := "H"
Else
   cTotFlag := "I"
EndIf

If !Empty(cLastFlag)
   If cFlagImp == "IMPR" .AND. (nPos:= aScan(aTotais,{|X| X[1] == cTipoTot})) > 0
      RudD->( dbAppend() )
      RudD->WK_SEQREL  := cSEQREL
      If cTipoTot == "GERAL"
         RudD->WK_PED     := cUltPD
         RudD->WKD_FLAG   := "T"
      Else
         RudD->WK_PED     := ED0->ED0_PD
         RudD->WKD_FLAG   := cTotFlag //If(cLastFlag == "E", "R", "S")
         cUltPD := ED0->ED0_PD
      Endif
      
      RudD->WKD_TOT_P  := Transf(aTotais[nPos][2], cPictPeso2)
      RudD->WKD_TOT_F  := Transf(aTotais[nPos][3], cPictValor)
      RudD->WKD_TOT_Q  := Alltrim(Transf(aTotais[nPos][4], cPictQtde))
      RudD->WKD_TOTFRT := Transf(aTotais[nPos][5],"@E 999,999,999.99")
      RudD->WKD_TOTSEG := Transf(aTotais[nPos][6],"@E 999,999,999.99")
      
      aSort(aTotais[nPos][7],,,{|x,y| x[1] > y[1]})
      For nInd := 1 To Len(aTotais[nPos][7])
         cCampo_Moeda  := "RudD->WKD_TVEM"+StrZero(nInd,2)
         &cCampo_Moeda := Alltrim(Transf(aTotais[nPos][7][nInd,2],"@E 99,999,999,999.99"))
         cUnidade_Vlr  := "RudD->WKD_MVEM"+StrZero(nInd,2)
         &cUnidade_Vlr := Alltrim(aTotais[nPos][7][nInd,1])+" - "
      Next
      
      // ** AAF 11/08/2006 - Ponto de entrada para gravação dos totais.
      If(EasyEntryPoint("EDCPA150"),ExecBlock("EDCPA150",.F.,.F.,"GRV_TOTPARC"),)
      /*
      For nInd := 1 To Len(aTotais[nPos][7])
         RudD->( dbAppend() )
         RudD->WK_SEQREL  := cSEQREL
         RudD->WK_PED     := ED0->ED0_PD
         RudD->WKD_FLAG   := "P"
         RudD->WKD_MVEM01 := aTotais[nPos][7][nInd][1]
         RudD->WKD_TVEM01 := Transf(aTotais[nPos][7][nInd][2],cPictValor)
         RudD->WK_PED     := AllTrim(Str(nPagina))
      Next nInd
      */
      
      aDel(aTotais,nPos)
      aSize(aTotais,Len(aTotais)-1)
      
   ElseIf cFlagImp == "TOTAL"
      
      //Acumula Total Parcial
      If (nPos := aScan(aTotais,{|X| X[1] == "PARCIAL"})) == 0
         aAdd(aTotais,{"PARCIAL",nTotPeso, nVlTot, nTotQtde, nTotFrete, nTotSeg, aClone(aVlRud) })
      Else
         aTotais[nPos][2] += nTotPeso
         aTotais[nPos][3] += nVlTot
         aTotais[nPos][4] += nTotQtde
         aTotais[nPos][5] += nTotFrete
         aTotais[nPos][6] += nTotSeg
         
         For nInd := 1 To Len(aVlRud)
            If (nPos2:= aScan(aTotais[nPos][7],{|X| X[1] == aVlRud[nInd][1]})) == 0
               aAdd(aTotais[nPos][7],aClone(aVlRud[nInd]))
            Else
               aTotais[nPos][7][nPos2][2] += aVlRud[nInd][2]
            Endif
         Next
      Endif
      
      //Acumula Total Geral
      If (nPos := aScan(aTotais,{|X| X[1] == "GERAL"})) == 0
         aAdd(aTotais,{"GERAL",nTotPeso, nVlTot, nTotQtde, nTotFrete, nTotSeg, aClone(aVlRud) })
      Else
         aTotais[nPos][2] += nTotPeso
         aTotais[nPos][3] += nVlTot
         aTotais[nPos][4] += nTotQtde
         aTotais[nPos][5] += nTotFrete
         aTotais[nPos][6] += nTotSeg
         
         For nInd := 1 To Len(aVlRud)
            If (nPos2:= aScan(aTotais[nPos][7],{|X| X[1] == aVlRud[nInd][1]})) == 0
               aAdd(aTotais[nPos][7],aVlRud[nInd])
            Else
               aTotais[nPos][7][nPos2][2] += aVlRud[nInd][2]
            Endif
         Next
      Endif
      
   Endif
Endif

Return .T.

Static Function CloseWork()

   //Pedido
   If Select("CAB") # 0
      CAB->(dbCloseArea())
   EndIf
   If Select("DET") # 0
      DET->(dbCloseArea())
   EndIf
   If Select("CAB2") # 0
      CAB2->(dbCloseArea())
   EndIf
   If Select("DET2") # 0
      DET2->(dbCloseArea())
   EndIf
   If Select("CAB3") # 0
      CAB3->(dbCloseArea())
   EndIf
   If Select("DET3") # 0
      DET3->(dbCloseArea())
   EndIf
   If Select("CAB4") # 0
      CAB4->(dbCloseArea())
   EndIf
   If Select("DET4") # 0
      DET4->(dbCloseArea())
   EndIf
   

//Rud

   If Select("RudC") # 0
      RudC->(dbCloseArea())
   EndIf
   If Select("RudD") # 0
      RudD->(dbCloseArea())
   EndIf
Return Nil

/*
Funcao      : GetDtDesemb()
Parametros  : cDI : Numero de DI
Retorno     : dDtDesemb : Data de Desembaraço
Objetivos   : Busca Data de Desembaraço na SW6
Autor       : Guilherme Fernandes Pilan
Data/Hora   : 18/05/2012 : 18:32
*/
*--------------------------------*
Function GetDtDesemb(cDI) 
*--------------------------------*
Local dDtDesemb := CToD("")
Local aOrd := SaveOrd("SW6")

	SW6->(DbSetOrder(11))//W6_FILIAL+W6_DI_NUM
	If SW6->(DbSeek(xFilial()+AvKey(cDI, "W6_DI_NUM")))
		dDtDesemb := SW6->W6_DT_DESE
	EndIf

RestOrd(aOrd, .T.) 

Return dDtDesemb
