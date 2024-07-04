#INCLUDE "Eicor150.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#include "avprint.ch"

#xtranslate :COURIER_08 => \[1\]
 
*---------------------------------------------*
FUNCTION ORI100Rel(TOpcao,cFase,cEnvio)
*---------------------------------------------*
LOCAL OldAlias := SELECT() , OldRecno:=TRB->(RECNO()), lMarcados:=.F., nPos:= 0
LOCAL cRegAnt  := OldRecno
Local RecnoSW8 := SW8->(RECNO())
LOCAL cString  := "TRB", cNomeArq
Private lNVE := EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 .And. EasyGParam("MV_EIC0011",,.F.)  //BCO - 20/09/12 Checa se o parametro MV_EIC0011 esta ligado
PRIVATE titulo   := STR0049  //"Relatorio de Envio ao Despachante"
PRIVATE MLin,MPag:=0, lPrimPag:=.t.,cPictPeso:="@E 999,999,999."+REPL("9",AVSX3("B1_PESO",4))
PRIVATE cUnidade
PRIVATE aMoeda := {}
PRIVATE lTemInvoice := .F.
Private lPrintNVE := .F. // BCO - 24/09/12 - Define se o usuário quer imprimir as NVAE'S no relatório

// PLB 06/08/07 - Referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
Private lW4_Fre_Inc := SW4->( FieldPos("W4_FREINC" ) ) > 0
Private lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Private lSegInc := SW4->(FIELDPOS("W4_SEGINC")) # 0 .AND. SW4->(FIELDPOS("W4_SEGURO")) # 0 .AND.;  // EOB - 14/07/08 - Inclusão do tratamento de incoterm com seguro
                   SW8->(FIELDPOS("W8_SEGURO")) # 0

// Usada no Rdmake - Hunter  //FSY - 06/11/2012 - Alteração para setar tamanho do campo WKNCM pelo cadastro da NCM. 
Struct:= { {"WKNCM"     ,"C",AVSX3("YD_TEC",3),0} ,;
           {"WKEX_NCM"  ,"C",LEN(SYD->YD_EX_NCM),0} ,;
           {"WKEX_NBM"  ,"C",LEN(SYD->YD_EX_NBM),0} ,;
           {"WKFABR"    ,"C",AVSX3("W3_FABR",AV_TAMANHO),0} ,;
           {"WKCOD_I"   ,"C",AVSX3("W3_COD_I",AV_TAMANHO),0} ,;
           {"WKPO_NUM"  ,"C",AvSx3("W2_PO_NUM", AV_TAMANHO),0} ,;
           {"WKDESTAQ"  ,"C",03,0} ,;
           {"WKREGIST"  ,"C",10,0} ,;
           {"WKQUAL_NCM","C",03,0} ,;
           {"WKQUALIF"  ,"C",03,0} ,;
           {"WKPART_N"  ,"C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} ,;
           {"WKUNID"    ,"C",03,0} ,;     
           {"WKQTDE"    ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE" ,4)},;
           {"WKPESO_T"  ,"N",17,AVSX3("B1_PESO" ,4)},;
           {"WKPRECO"   ,"N",AVSX3("W7_PRECO"  ,3),AVSX3("W7_PRECO",4)},;
           {"WKPRECO_T" ,"N",AVSX3("W6_FOB_TOT",3),AVSX3("W6_FOB_TOT",4)},;
           {"WKQTE_ES"  ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE",4)}  ,;
           {"WKANUENCIA","C",03,0},;
           {"WKPGI_NUM" ,"C",AVSX3("W4_PGI_NUM",AV_TAMANHO),0} ,;
           {"WKCLASS"   ,"C",01,0},;
           {"WKMOEDA"   ,"C",AVSX3("W9_MOE_FOB",3),0},;
           {"WKINVOICE" ,"C",AVSX3("W9_INVOICE",AV_TAMANHO),0},;
           {"WKFORN"    ,"C",AVSX3("W9_FORN",3),0},;
           {"WKHAWB"    ,"C",AVSX3("W9_HAWB",AV_TAMANHO),0},;
           {"WKCOND"    ,"C",AVSX3("W2_COND_PA",3),0},;
           {"WKDIAS"    ,"C",AVSX3("W2_DIAS_PA",AV_TAMANHO),0}}
           
           
           iF lNVE /*.AND. lPrintNVE*/ .AND. cFase == FASE_DI //BCO - 20/09/12 Se o Parametro MV_EIC0011 está ligado , verifica fase e impressão de NVEAE, então é adicionado o campo WKNVE na Work
              aAdd(Struct,{"WKNVE"  ,"C",AVSX3("EIM_CODIGO",3),0})//BCO - 19/09/2012 - Inclui tabela NVE da ncm do Produto
           endif
           
If EICLOJA() .And. (nPos := aScan(Struct, {|x| x[1] == "WKFABR" })) > 0
   aAdd(Struct, Nil)
   aIns(Struct, nPos + 1)
   Struct[nPos+1] := {"WKFABLOJ", "C", AvSx3("W3_FABLOJ", AV_TAMANHO),0}
EndIf   

If EICLOJA() .And. (nPos := aScan(Struct, {|x| x[1] == "WKFORN" })) > 0
   aAdd(Struct, Nil)
   aIns(Struct, nPos + 1)
   Struct[nPos+1] := {"WKFORLOJ", "C", AvSx3("W9_FORLOJ", AV_TAMANHO),0}
EndIf 

IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"6"),)//AWR 16/11/1999

TRB->(DBGOTOP())
TRB->(DBEVAL({||IF(WP_FLAGWIN==cMarca,lMarcados:=.T.,)}))

IF ! lMarcados
   Help("", 1, "AVG0000127")//MsgInfo(OemToAnsi(STR0050),STR0048) //"NÆo existem Registro marcados para ImpressÆo."###"Informação"
   RETURN .T.
ENDIF

IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"ADICIONA_CAMPO"),)    //TRP-17/03/08- Inclusão de ponto de entrada- Chamado 072098
IF Select("Work") != 0      //BCO - 24/09/12 - Verifica se existe a Work. Se sim, fecha pra criar uma nova. Dessa forma sempre será criada uma work nova 
   Work -> ( DbCloseArea()) //para atender á possivel mudança de estrutura da work caso o user. deseje imprimir as NVE'S
endif

   cNomWork := E_CriaTrab(,Struct,"WORK") //THTS - 06/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help(" ",1,"E_NAOHARE")
      RETURN .F.
   ENDIF
   If !EICLoja()
      if lNVE /*.AND. lPrintNVE*/ .AND. cFase == FASE_DI   //BCO - 20/09/12 Checa se o parametro MV_EIC0011 esta ligado e se as outras condições estão satisfeitas. Caso afirmativo, é alterado o indice da tabela. 
         IndRegua("WORK",cNomWork+TEOrdBagExt(),"WKHAWB+WKINVOICE+WKPO_NUM+WKNCM+WKEX_NCM+WKEX_NBM+WKFABR+WKNVE",;
                  "AllwaysTrue()",;
                  "AllwaysTrue()",;
                  "Indexando Arquivo Temporario...")
      else
          IndRegua("WORK",cNomWork+TEOrdBagExt(),"WKHAWB+WKINVOICE+WKPO_NUM+WKNCM+WKEX_NCM+WKEX_NBM+WKFABR",;
                  "AllwaysTrue()",;
                  "AllwaysTrue()",;
                  "Indexando Arquivo Temporario...")
      endif
   Else  
      if lNVE /*.AND. lPrintNVE*/ .AND. cFase == FASE_DI    
         IndRegua("WORK",cNomWork+TEOrdBagExt(),"WKHAWB+WKINVOICE+WKPO_NUM+WKNCM+WKEX_NCM+WKEX_NBM+WKFABR+WKFABLOJ+WKNVE",;
                 "AllwaysTrue()",;
                 "AllwaysTrue()",;
                 "Indexando Arquivo Temporario...")
      Else
         IndRegua("WORK",cNomWork+TEOrdBagExt(),"WKHAWB+WKINVOICE+WKPO_NUM+WKNCM+WKEX_NCM+WKEX_NBM+WKFABR+WKFABLOJ",;
                 "AllwaysTrue()",;
                 "AllwaysTrue()",;
                 "Indexando Arquivo Temporario...")
      endif
   EndIf     

TRB->(DBGOTO(OldRecno))

PRINT oPrn NAME ""
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME titulo

   ProcRegua(TRB->(LASTREC()))

   DEFINE FONT oFont1  NAME "Courier New"            SIZE 0,08  BOLD    OF  oPrn

   aFontes := { oFont1 }

   AVPAGE
//      oPrn:oFont := aFontes:1
      TRB->( DBGOTOP() )

      WHILE ! TRB->( EOF() )
        IncProc("Imprimindo...")
        IF TRB->WP_FLAGWIN <> cMarca
           TRB->( DBSKIP() )
           LOOP
        ENDIF
        cChave :=IF(cFase==FASE_PO,TRB->W2_PO_NUM,TRB->W6_HAWB)
        ORI100Imp(cChave,TOpcao,cFase,cString)
        TRB->( DBSKIP() )
      END

   AVENDPAGE

AVENDPRINT
oFont1:End()

MS_FLUSH()

TRB->( DBGOTO( OldRecno ) ) //BCO 28/09/12 - Posiciona a tabela no registro que estava 

SW8->(DBGOTO(RecnoSW8))

DBSELECTAREA(OldAlias)
RETURN NIL

*----------------------------------------------*
FUNCTION ORI100Imp(PChave,TOpcao,cFase,cString)
*----------------------------------------------*
LOCAL MLARG:=0,cPaisProc,cURF_Desp:="",cURF_Cheg:="",;
      nRecno:=0,nPes_Tot:=0,nVlr_Tot:=0,nItems:=0,MCOL4:=0, cFil:=''

LOCAL sRecnoPo, sIndexPo, cAliasImp:=Alias()

LOCAL nOrdSW2:=SW2->(INDEXORD()), nOrdSW6:=SW6->(INDEXORD())
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL I
LOCAL nRegAtu := 0,nRegAnt := 0 //LGS-06/07/2016 //LRS - 29/09/2017
PRIVATE AreaPrincipal,MCOL:=1,nTot_Vlr:=0,nPesTotPODI:=0,MDesFrePODI:=0 ,;
        OldArea,cNCM,nFabri,cFabLoj:= "",nTot_Pes:=0,NewArea,nCOLTOT1:=0,nCOLTOT2:=0, nPesoItem:=0

PRIVATE cTexto:= "", lImpDescIt := .T. //Usados no RdMake EICOR150 

Private cLastNCM // BCO - 24/09/12 - Armazena a última NCM para fazer verificação posteriormente.
Private cLastNVE
Private lGeraCab := .F. //BCO 28/09/12 Variáveis de controle de fluxo

IF cFASE == FASE_DI        
   nCOLTOT1:=54
   nCOLTOT2:=90
ELSE
   nCOLTOT1:=38
   nCOLTOT2:=74
ENDIF   
SW2->(DBSETORDER(1))
SY4->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SWP->(DBSETORDER(1))
SYF->(DBSETORDER(1))
SYT->(DBSETORDER(1))

SW2->(DBSEEK(xFilial()+Work->WKPO_NUM))
SW6->(DBSEEK(xFilial()+Work->WKHAWB))

IF cFase = FASE_PO
   SW2->(DBSEEK(xFilial()+PChave))
   SY4->(DBSEEK(xFilial()+SW2->W2_AGENTE))
   SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EM))
ELSE
   SW6->(DBSEEK(xFilial()+PChave))
   SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
   SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
   SW4->(DBSEEK(xFilial()+SW7->W7_PGI_NUM))
   SWP->(DBSEEK(xFilial()+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
   SY4->(DBSEEK(xFilial()+SW6->W6_AGENTE))
   SYQ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA))
ENDIF

SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
SY5->(DBSEEK(xFilial()+IF(cFase= FASE_PO,cCodigo,SW6->W6_DESP)))
SYF->(DBSEEK(xFilial()+SW2->W2_MOEDA))

MLin  := 1
MPag  := 1

PRIVATE MConta:=MContG:=0

MontaCabRel(titulo, MPag,ALLTRIM(SY5->Y5_NOME))
MLin+=50

IF cFase = FASE_DI
   IF ! EMPTY(SW6->W6_HOUSE)
      oPrn:Say( MLin, Ori100xCol(001),STR0051+SW6->W6_HOUSE, aFontes:COURIER_08) //"Nr do Conhecimento..: "
      MLin+=50
   ENDIF
   oPrn:Say( MLin, Ori100xCol(001),STR0052+SW6->W6_HAWB, aFontes:COURIER_08) //"Processo............: "
   oPrn:Say( MLin, Ori100xCol(055),STR0053+DTOC(SW6->W6_DT_HAWB), aFontes:COURIER_08) //"Data Processo....: "
   oPrn:Say( MLin, Ori100xCol(093),STR0054+SW6->W6_MAWB, aFontes:COURIER_08) //"Nr. Master.......: "
ELSE
   oPrn:Say( MLin, Ori100xCol(001),STR0055+TRANS(SW2->W2_PO_NUM,_PictPO), aFontes:COURIER_08) //"Nr. P.O.............: "
ENDIF
MLin+=100
oPrn:Say( MLin, Ori100xCol(001),STR0056+SYT->YT_NOME+STR0057+TRANS(SYT->YT_CGC,'@R 99.999.999/9999-99'), aFontes:COURIER_08) //"Importador..........: "###"        Inscricao no CGC/CPF: "
MLin+=50
oPrn:Say( MLin, Ori100xCol(001),STR0058+SYT->YT_ENDE, aFontes:COURIER_08) //"Endereco............: "
MLin+=50
SYA->( DBSEEK( xFilial() + SYT->YT_PAIS ) )

oPrn:Say( MLin, Ori100xCol(001),"                      "+ALLTRIM(SYT->YT_CIDADE)+;
                                                        IF(!EMPTY(ALLTRIM(SYT->YT_ESTADO))," - "+ALLTRIM(SYT->YT_ESTADO),"")+;
                                                        IF(!EMPTY(ALLTRIM(SYA->YA_DESCR))," - "+SYA->YA_CODGI+" "+ALLTRIM(SYA->YA_DESCR),"")+;
                                                        IF(!EMPTY(ALLTRIM(SYT->YT_CEP)),STR0059+TRANS(SYT->YT_CEP,"@R 99999-999"),""),aFontes:COURIER_08) //" CEP : "
MLin+=50
oPrn:Say( MLin, Ori100xCol(001),STR0060+SYT->YT_TEL_IMP, aFontes:COURIER_08) //"Fone................: "
oPrn:Say( MLin, Ori100xCol(055),STR0061+SYT->YT_FAX_IMP, aFontes:COURIER_08) //"Fax.: "
MLin+=50

IF ! EMPTY(SW2->W2_CONSIG)
   SYT->(DBSEEK(xFilial()+SW2->W2_CONSIG))
   oPrn:Say( MLin, Ori100xCol(001),STR0062+ALLTRIM(SYT->YT_NOME)+" / "+TRANS(SYT->YT_CGC,'@R 99.999.999/9999-99'), aFontes:COURIER_08) //"Consignatario / CGC.: "
   MLin+=50
   SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
ENDIF

IF cFase = FASE_DI
   oPrn:Say( MLin, Ori100xCol(001),STR0065+DTOC(SW6->W6_DT_EMB), aFontes:COURIER_08) //"Data de Embarque....: "
   oPrn:Say( MLin, Ori100xCol(055),STR0066+SW6->W6_ORIGEM, aFontes:COURIER_08) //"Local de Embarque: "
   oPrn:Say( MLin, Ori100xCol(093),STR0067+DTOC(SW6->W6_DT_ETA), aFontes:COURIER_08) //"Data ETA.........: "
   MLin+=50
ENDIF

SA2->(DBSETORDER(1))
IF ! EMPTY( SW2->W2_EXPORTA )  .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
   SA2->(DBSEEK(xFilial()+SW2->W2_EXPORTA+EICRetLoja("SW2","W2_EXPLOJ")))
ELSE
   SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
ENDIF

SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))

cPaisProc:=PADL(SYR->YR_PAIS_OR,3,"0") // RHP - IGUAL AO ENVIO

IF cFase # FASE_PO
   cURF_Desp:=PADL(ALLTRIM(SW6->W6_URF_DES),7,"0")
   cURF_Cheg:=PADL(ALLTRIM(SW6->W6_URF_ENT),7,"0")
   SWP->(DBSETORDER(1))
   IF SWP->(DBSEEK(xFilial()+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
      IF !EMPTY(SWP->WP_PAIS_PR)
         cPaisProc:=PADL(ALLTRIM(SWP->WP_PAIS_PR),3,"0")
      ENDIF
      SW4->(DBSETORDER(1))
      SW4->(DBSEEK(xFilial()+SW7->W7_PGI_NUM))
      cURF_Desp:=PADL(ALLTRIM(SW4->W4_URF_DES),7,"0")
      cURF_Cheg:=PADL(ALLTRIM(SW4->W4_URF_CHE),7,"0")
   Else   
      SYR->(DBSETORDER(1))
      SYR->(DBSEEK(xFilial()+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
      cPaisProc:=PADL(SYR->YR_PAIS_OR,3,"0")                                    
   ENDIF                               

   SY9->(DBSETORDER(2))
   SY9->(DBSEEK(xFilial()+SW6->W6_LOCAL))
   SY9->(DBSETORDER(1))
   oPrn:Say( MLin, Ori100xCol(001),STR0068+SUBSTR(SY9->Y9_DESCR,1,23), aFontes:COURIER_08) //"Local Desembaraco...: "
   oPrn:Say( MLin, Ori100xCol(055),STR0069 +SW6->W6_LOTE, aFontes:COURIER_08) //"Numero do Lote...: "

   MLin+=50
   oPrn:Say( MLin, Ori100xCol(001),STR0212+ALLTRIM(TRAN(SW6->W6_VLFREPP,'999,999,999,999.99')), aFontes:COURIER_08) //"Frete PP............: "
   oPrn:Say( MLin, Ori100xCol(055),STR0213+ALLTRIM(TRAN(SW6->W6_VLFRECC,'999,999,999,999.99')), aFontes:COURIER_08) //"Frete CC.........: "
   oPrn:Say( MLin, Ori100xCol(093),STR0214+ALLTRIM(TRAN(SW6->W6_VLFRETN,'999,999,999,999.99')), aFontes:COURIER_08) //"Frete TN.........: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(001),STR0215+SW6->W6_SEGMOED+" "+ALLTRIM(TRAN(SW6->W6_VL_USSE,'999,999,999,999.99')), aFontes:COURIER_08) //"Seguro...........: "
   MLin+=50
ENDIF
SYA->(DBSETORDER(1))
SYA->(DBSEEK(xFilial()+cPaisProc))

IF cFase=FASE_DI
   oPrn:Say( MLin, Ori100xCol(055), STR0074+cURF_Desp, aFontes:COURIER_08) //"URF de Despacho..: " 
   oPrn:Say( MLin, Ori100xCol(093), STR0075+cURF_Cheg, aFontes:COURIER_08) //"URF de Entrada...: "
   MLin+=50
ENDIF

IF cFase = FASE_PO
   oPrn:Say( MLin, Ori100xCol(001),STR0081+SW2->W2_TIPO_EM, aFontes:COURIER_08) //"Via de Transporte...: "
Else                                                      
   oPrn:Say( MLin, Ori100xCol(001),STR0081+SW6->W6_VIA_TRA, aFontes:COURIER_08) //"Via de Transporte...: "
Endif   
oPrn:Say( MLin, Ori100xCol(055),STR0082+IF(cFase=FASE_DI,SW6->W6_IDENTVE,""), aFontes:COURIER_08) //"Embarcacao.......: "
MLin+=50
oPrn:Say( MLin, Ori100xCol(001),STR0083+ALLTRIM(SY4->Y4_NOME)+" / "+TRANS(SY4->Y4_CGC,'@R 99.999.999/9999-99'), aFontes:COURIER_08) //"Agente Transp./CGC..: "
MLin+=50

IF SA2->A2_ID_REPR $ cSim
   MLin+=100
   oPrn:Say( MLin, Ori100xCol(001),STR0084, aFontes:COURIER_08) //"REPRESENTANTE"
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(001),STR0085+SA2->A2_REPRES, aFontes:COURIER_08) //"Nome................: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(001),STR0086+SA2->A2_REPR_BA, aFontes:COURIER_08) //"Banco...............: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(055),STR0087+SA2->A2_REPR_AG, aFontes:COURIER_08) //"Agencia..........: "
   oPrn:Say( MLin, Ori100xCol(093),STR0088+SA2->A2_REPR_CO, aFontes:COURIER_08) //"Conta............: "
   MLin+=50
ENDIF

if CFASE == FASE_PO
   IF ! EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
      SY6->(DBSEEK(xFilial()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX,3)))
   ELSE
      SY6->(DBSEEK(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3)))
   ENDIF
ENDIF

IF cFase = FASE_DI
   SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
   OldArea       := "SW7"
   AreaPrincipal := "SW6"
   cPos_Det      := SW7->(FIELDPOS('W7_HAWB'))
   cPos_Fil      := SW7->(FIELDPOS('W7_FILIAL'))
ELSE
   SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
   OldArea       := "SW3"
   AreaPrincipal := "SW2"
   cPos_Det      := SW3->(FIELDPOS('W3_PO_NUM'))
   cPos_Fil      := SW3->(FIELDPOS('W3_FILIAL'))
ENDIF

MDespesas := 0
IF cFASE == FASE_PO
   IF EasyGParam("MV_RATEIO") $ cSim
      MDespesas := SW2->W2_INLAND + SW2->W2_PACKING - SW2->W2_DESCONT
      mFob_Total:= SW2->W2_FOB_TOT + MDespesas
   ENDIF                                                             
ENDIF

IF EasyGParam("MV_RAT_FRE") $ cSim
   cFil:=xFilial(OldArea)
   WHILE ! (OldArea)->(EOF()) .AND.;
           (AreaPrincipal)->(FIELDGET(cPos_Chave)) == (OldArea)->(FIELDGET(cPos_Det)) .AND.;
           (OldArea)->(FIELDGET(cPos_Fil)) = cFil

      IF EVAL(SEQ) # 0
        (OldArea)->(DBSKIP()) ; LOOP
      ENDIF
      SB1->(DBSETORDER(1))
      SB1->(DBSEEK(xFilial()+EVAL(COD_I)))
      nPesoItem:=If(AreaPrincipal=="SW6",W5Peso(),B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))) //FCD 04/07/2001  //  LDR OS - 1239/03
      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"11"),)//AWR 11/11/1999      
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOIT_W3"),)
      
	     nPesTotPODI+=EVAL(QTDE)*nPesoItem
      (OldArea)->(DBSKIP())
   ENDDO

   IF cFase = FASE_DI
      SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
      cPos_Det:=SW7->(FIELDPOS('W7_HAWB'))
      cPos_Fil:=SW7->(FIELDPOS('W7_FILIAL'))
   ELSE
      MDesFrePODI:= SW2->W2_FRETEIN
      mFob_Total += MDesFrePODI
      SW3->(DBSEEK(xFilial("SW2")+SW2->W2_PO_NUM))
      cPos_Det:=SW3->(FIELDPOS('W3_PO_NUM'))
      cPos_Fil:=SW3->(FIELDPOS('W3_FILIAL'))
   ENDIF
ENDIF

sRecnoPo := SW2->( Recno() )
sIndexPo := SW2->(indexord()) 
nFob:=0
cFil:=xFilial(OldArea)

If MDesFrePODI # 0 .OR. MDespesas # 0
   WHILE ! (OldArea)->(EOF()) .AND.;
           (AreaPrincipal)->(FIELDGET(cPos_Chave)) == (OldArea)->(FIELDGET(cPos_Det)) .AND.;
           (OldArea)->(FIELDGET(cPos_Fil)) = cFil

      IF EVAL(SEQ) # 0
        (OldArea)->(DBSKIP()) ; LOOP
      ENDIF
      SB1->(DBSETORDER(1))
      SB1->(DBSEEK(xFilial()+EVAL(COD_I)))

      SW2->( DBSETORDER(1) )
      SW2->( DBSEEK( xFilial()+(OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'PO_NUM'))) ) )

      nPesoItem:=If(AreaPrincipal=="SW6",W5Peso(),B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))) //FCD 04/07/2001   // LDR - OS 1239/03
      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"11"),)//AWR 11/11/1999      
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOIT_W3"),)
  
      mFob_Total -=EVAL(QTDE)*EVAL(PRECO) + (MDespesas * ((EVAL(QTDE)*EVAL(PRECO))/(AreaPrincipal)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,'W6_','W2_')+'FOB_TOT')))))
      mFob_Total -=MDesFrePODI*(EVAL(QTDE)*nPesoItem/IF(nPesTotPODI<=0,1,nPesTotPODI))
     (OldArea)->(DBSKIP())
   ENDDO           
Else
   mFob_Total := 0
EndIf

SW2->( DbGoTo( sRecnoPo ) )
SW2->( DBSetOrder( sIndexPo ) )

SYF->(DBSEEK(xFilial("SYF")+SW2->W2_MOEDA))

IF cFase = FASE_DI
//   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
//   cPos_Det:=SW7->(FIELDPOS('W7_HAWB'))
//   cPos_Fil:=SW7->(FIELDPOS('W7_FILIAL'))
ELSE
   SW3->(DBSEEK(SW2->W2_FILIAL+SW2->W2_PO_NUM))
   cPos_Det:=SW3->(FIELDPOS('W3_PO_NUM'))
   cPos_Fil:=SW3->(FIELDPOS('W3_FILIAL'))
ENDIF

IF cFase == FASE_DI .AND. SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB))
   lPrintNVE := If(lNVE , OR100PqNVE("DI" ,SW6->W6_HAWB ,.T.) , .F.)//FDR - 17/05/13
   ORI100InvPrePro()
ELSE
   lPrintNVE := If(lNVE , OR100PqNVE("LI" ,SW6->W6_HAWB ,.T.) , .F.)//FDR - 17/05/13
   ORI100PrePro(OldArea,cFASE)
ENDIF
Work->(DBGOTOP())

//ORI100PODISubCAb(.F.,cFASE)
//nRecno++

SW2->(DBSETORDER(1))
WHILE ! Work->(EOF())

 cWKMOEDA := Work->WKMOEDA
 cWKHAWB  := Work->WKHAWB
 cWKPO    := Work->WKPO_NUM
 cInvoice := Work->WKINVOICE

 SY6->(DBSEEK(xFilial()+Work->WKCOND+Work->WKDIAS))
 
 IF MPag > 1
    IF cNCM # Work->WKNCM+Work->WKEX_NCM+Work->WKEX_NBM .Or. (nFabri # Work->WKFABR .And. IIF(EICLoja(),cFabLoj # Work->WKFABLOJ,.T.)) .or. cWKPO # Work->WKPO_NUM
       oPrn:Say( MLin, Ori100xCol(nCOLTOT1),REPL('-',18), aFontes:COURIER_08)
       oPrn:Say( MLin, Ori100xCol(nCOLTOT2),REPL('-',18), aFontes:COURIER_08)
       MLin+=50
       oPrn:Say( MLin, Ori100xCol(nCOLTOT1),TRANS(nPes_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
       oPrn:Say( MLin, Ori100xCol(nCOLTOT2),TRANS(nVlr_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
       MLin+=50
       nPes_Tot:=0
       nVlr_Tot:=0
       nItems  :=0
       cWKPO := Work->WKPO_NUM
       cInvoice := Work->WKINVOICE
    ENDIF
    ORI100PODISubCAb(.T.,cFASE,.F.)
 Else
    MLin+=50
    oPrn:Box( MLin , 0, MLin+1, 3000 )
    MLin+=30
 ENDIF

 IF cFase = FASE_PO
    SW2->(DBSEEK(xFilial()+PChave))
    SY4->(DBSEEK(xFilial()+SW2->W2_AGENTE))
    SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EM))
//    SY6->(Dbseek(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))
    SY6->(Dbseek(xFilial("SY6")+Work->WKCOND+Work->WKDIAS))
 ELSE
    SW6->(DBSEEK(xFilial()+PChave))
    SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
    SW2->(DBSEEK(xFilial()+Work->WKPO_NUM /*SW7->W7_PO_NUM*/)) //LGS-26/11/2014
    SW4->(DBSEEK(xFilial()+SW7->W7_PGI_NUM))
    SWP->(DBSEEK(xFilial()+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
    SY4->(DBSEEK(xFilial()+SW6->W6_AGENTE))
    SYQ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA))
 ENDIF
 SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
 SY5->(DBSEEK(xFilial()+IF(cFase= FASE_PO,cCodigo,SW6->W6_DESP)))
 SYF->(DBSEEK(xFilial()+Work->WKMOEDA))

/* ISS - 25/02/10 - Alteração do "seek" para que o mesmo busque o número da invoice e o seu respectivo processo, para que a invoice 
                    pega realmente seja a invoice usada no pedido corrente, chamado (727258)

   If SW9->(DBSEEK(xFilial("SW9")+Work->WKINVOICE)) */
   If SW9->(DBSEEK(xFilial("SW9")+Work->WKINVOICE+Work->WKFORN+EICRetLoja("Work","WKFORLOJ")+Work->WKHAWB)) //DFS - 07/02/11 - Ajuste no seek 

    lTemInvoice := .T.
//    SY6->(Dbseek(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0)))
    SY6->(Dbseek(xFilial("SY6")+Work->WKCOND+Work->WKDIAS))
 Else
    lTemInvoice := .F.
 EndIf

 oPrn:Say( MLin, Ori100xCol(001),STR0063+Work->WKMOEDA, aFontes:COURIER_08) //"Moeda...............: "
 oPrn:Say( MLin, Ori100xCol(055),STR0064+IF(cFase=FASE_DI .And. !Empty(SW9->W9_INCOTER),SW9->W9_INCOTER /*BuscaIncoterm(.T.)*/,SW2->W2_INCOTER), aFontes:COURIER_08) //"Incoterm.........: " //MCF - 09/04/2015
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0071+ALLTRIM(TRAN(If(cFase=FASE_DI .AND. SW9->W9_FREINC = "2",SW9->W9_FRETEIN,SW2->W2_FRETEIN),'999,999,999,999.99')), aFontes:COURIER_08) //"Frete...............: " 
 oPrn:Say( MLin, Ori100xCol(055),STR0073+cPaisProc+" "+LEFT(SYA->YA_DESCR,20), aFontes:COURIER_08) //"Pais de Procedencia.: "
 MLin+=50
 //TRP-08/02/08- Posicionar fornecedor correto para cada item.
 SA2->(DBSETORDER(1))
 If cFase = FASE_PO
    IF ! EMPTY( SW2->W2_EXPORTA ) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
       SA2->(DBSEEK(xFilial()+SW2->W2_EXPORTA+EICRetLoja("SW2","W2_EXPLOJ")))
    ELSE
       SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
    ENDIF
 ELSEIF cFase=FASE_DI 
    IF lTemInvoice 
       SA2->(DBSEEK(xFilial()+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
    ELSE
       SA2->(DBSEEK(xFilial()+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))
    ENDIF
 ENDIF 
 oPrn:Say( MLin, Ori100xCol(001),STR0089, aFontes:COURIER_08) //"FORNECEDOR"
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0085+ALLTRIM(SA2->A2_COD)+" "+IF(EICLoja(),ALLTRIM(SA2->A2_LOJA),"")+" "+LEFT(SA2->A2_NOME,37), aFontes:COURIER_08) //"Nome................: "
 MLin+=50 
 oPrn:Say( MLin, Ori100xCol(001),STR0076+IF (SA2->A2_VINCULA="3",STR0077,IF (SA2->A2_VINCULA="2",STR0078,STR0079)), aFontes:COURIER_08) //"Vinculacao..........: "###"Com, Com Influencia de Preco"###"Com, Sem Influencia de Preco"###"Sem Vinculacao"
 SYA->( DBSEEK( xFilial() + SA2->A2_PAIS ) )
 oPrn:Say( MLin, Ori100xCol(078),STR0090+ALLTRIM(SA2->A2_PAIS)+" "+LEFT(SYA->YA_DESCR,20), aFontes:COURIER_08) //"Pais de Aquisicao da Mercadoria.: "
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0091+SA2->A2_END, aFontes:COURIER_08) //"Logradouro..........: "
 oPrn:Say( MLin, Ori100xCol(078),STR0092+SA2->A2_NR_END, aFontes:COURIER_08) //"Numero....: "
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0093+SA2->A2_MUN, aFontes:COURIER_08) //"Cidade..............: "
 oPrn:Say( MLin, Ori100xCol(078),STR0094+SA2->A2_ESTADO, aFontes:COURIER_08) //"Estado....: "
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0095, aFontes:COURIER_08) //"COBERTURA CAMBIAL"
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0096+PG100Cobertura(), aFontes:COURIER_08) //"Regime Cambial......: "
 MLin+=50
 oPrn:Say( MLin, Ori100xCol(001),STR0097+TRANS(SY6->Y6_COD,'@R 9.9.999')+" / " +TRANS(SY6->Y6_DIAS_PA,'999')+" - "+ALLTRIM(MSMM(SY6->Y6_DESC_P,32,1)), aFontes:COURIER_08) //"Condicao Pagamento..: "
 DO CASE
    CASE SY6->Y6_TIPOCOB = "1"
         oPrn:Say( MLin  , Ori100xCol(078),STR0098+PADL(SY6->Y6_TABELA,2,'0'), aFontes:COURIER_08) //"Modalidade Pagamento: "
         oPrn:Say( MLin  , Ori100xCol(120),STR0099 +STRZERO(SY6->Y6_DIAS,3), aFontes:COURIER_08) //"Qtde.Dias Limite Pagto: "
    CASE SY6->Y6_TIPOCOB = "2"
         oPrn:Say( MLin  , Ori100xCol(078),STR0100+PADL(SY6->Y6_TABELA,2,'0'), aFontes:COURIER_08) //"Modalidade de Pagamento..: "
    CASE SY6->Y6_TIPOCOB = "3"
         oPrn:Say( MLin  , Ori100xCol(078),STR0101+PADL(SY6->Y6_INST_FI,2,'0'), aFontes:COURIER_08) //"Instituicao Financiadora.: "
    CASE SY6->Y6_TIPOCOB = "4"
         oPrn:Say( MLin  , Ori100xCol(078),STR0102+PADL(SY6->Y6_MOTIVO,2,'0'), aFontes:COURIER_08) //"Motivo...................: "
 ENDCASE
 MLin+=50

 IF cFase = FASE_DI
    SW9->(DBSETORDER(1))
    SW9->(DBSEEK(xFilial()+Work->WKINVOICE+Work->WKFORN + IIF(EICLoja(),Work->WKFORLOJ,""))) //FMB 07/06/04 - SW9->(DBSEEK(xFilial()+Work->WKINVOICE)) 
    oPrn:Say( MLin  , Ori100xCol(001),STR0103+SW9->W9_INVOICE, aFontes:COURIER_08) //"Fatura Invoice...........: "
    oPrn:Say( MLin  , Ori100xCol(078),STR0104+DTOC(SW9->W9_DT_EMIS), aFontes:COURIER_08) //"Data Invoice............: "
    oPrn:Say( MLin  , Ori100xCol(001),"                           "+SW9->W9_INVOICE, aFontes:COURIER_08)
    oPrn:Say( MLin  , Ori100xCol(078),"                          "+DTOC(SW9->W9_DT_EMIS), aFontes:COURIER_08)
    MLin+=50
 ENDIF

 MLin+=50
 oPrn:Say( MLin  , Ori100xCol(001),STR0105, aFontes:COURIER_08) //"MERCADORIA"
 MLin+=50

 IF MLin > TOTLIN
    ORI100PODISubCAb(.T.,cFASE,.T.)
 Else
    ORI100PODISubCAb(.F.,cFASE,.T.)
 ENDIF

 While !Work->(EOF()) .and. Work->WKHAWB == cWKHAWB .and. Work->WKMOEDA == cWKMOEDA .and. ;
                            /*Work->WKPO_NUM == cWKPO .AND.*/ Work->WKINVOICE == cInvoice
 if Empty(cLastNVE)
    cLastNVE := ""
 ENDIF
 
 if lNVE/*lPrintNVE*/ //BCO 28/09/12 Se o registro possui NVAE, é gerado o sub cabeçalho novamente                          
    if (avkey(WORK->WKNVE,"EIM_COD") != AVKEY(cLastNVE,"EIM_COD")) .AND. WORK->WKNCM == AvKey(cLastNCM,"YD_TEC") .AND. cFase = FASE_DI
        lGeraCab := .T.
        MLin+=30
        ORI100PODISubCAb(.F.,2,.T.)
    endif
 endif   
 

   IF MLin > TOTLIN //LGS-06/07/2016
      nRegAtu := Work->(RecNo())
      Work->(DbGoTo(nRegAnt)) //Posiciona no registro anterior pq deu quebra de pagina e ainda precisa finalizar a impressão.
      ORI100PODISubCAb(.T.,cFASE,.T.)
      Work->(DbGoTo(nRegAtu))
   ENDIF

   SW2->(DBSEEK(xFilial()+Work->WKPO_NUM))
   //FDR - 10/05/13 - Incluso campo loja no seek
   SYG->(DBSEEK(xFilial()+AvKey(SW2->W2_IMPORT,"YG_IMPORTA")+AvKey(Work->WKFABR,"YG_FABRICA")+IIF(EICLoja(),AvKey(Work->WKFABLOJ,"YG_FABLOJ"),"")+AvKey(Work->WKCOD_I,"YG_ITEM")))

   IF cNCM # Work->WKNCM+Work->WKEX_NCM+Work->WKEX_NBM .Or. (nFabri # Work->WKFABR) .Or. (EICLoja() .And. cFabLoj # Work->WKFABLOJ) .or. cWKPO # Work->WKPO_NUM

      IF nItems >= 1
         oPrn:Say( MLin, Ori100xCol(nCOLTOT1),REPL('-',18), aFontes:COURIER_08)
         oPrn:Say( MLin, Ori100xCol(nCOLTOT2),REPL('-',18), aFontes:COURIER_08)
         MLin+=50
         oPrn:Say( MLin, Ori100xCol(nCOLTOT1),TRANS(nPes_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
         oPrn:Say( MLin, Ori100xCol(nCOLTOT2),TRANS(nVlr_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
         MLin+=50
      ENDIF
      nPes_Tot:=0
      nVlr_Tot:=0
      nItems  :=0
      cWKPO := Work->WKPO_NUM
      cInvoice:= Work->WKINVOICE
      ORI100PODISubCAb(IF (MLin > TOTLIN,.T.,.F.),cFASE,.T. )

   ENDIF

   SB1->(DBSETORDER(1))
   SB1->(DBSEEK(xFilial()+Work->WKCOD_I))

   nItems++
   nRecno++
   MLARG := 60
   MCOL  := 01

   nPes_Tot+=Work->WKPESO_T
   nVlr_Tot+=Work->WKPRECO_T

   IF cFase = FASE_DI
      oPrn:Say( MLin  , Ori100xCol(MCOL),ALLTRIM(TRANS(Work->WKPO_NUM,_PictPO)), aFontes:COURIER_08)
      MCOL+=LEN(SW2->W2_PO_NUM)+1
   ENDIF

   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKCOD_I,_PictItem), aFontes:COURIER_08)
   MCOL4:=MCOL+=LEN(TRANS(SW3->W3_COD_I,_PictItem))+1 //IF((LEN(SB1->B1_COD)-2)<15,15,LEN(SB1->B1_COD)-2)
   oPrn:Say( MLin  , Ori100xCol(MCOL), Work->WKUNID, aFontes:COURIER_08)
   MCOL+=17
   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKQTDE,_PictQtde), aFontes:COURIER_08,,,,1)
   MCOL+=19
   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKPESO_T,cPictPeso), aFontes:COURIER_08,,,,1)
   MCOL+=18
   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKPRECO,_PictPrUn) , aFontes:COURIER_08,,,,1)
   MCOL+=18//LEN(_PictPrUn)-2
   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKPRECO_T,_PictPrTot), aFontes:COURIER_08,,,,1)
   MCOL+=18
   oPrn:Say( MLin  , Ori100xCol(MCOL), TRANS(Work->WKQTE_ES,_PictQtde), aFontes:COURIER_08,,,,1)
   MCOL+=05//19
   oPrn:Say( MLin  , Ori100xCol(MCOL), Work->WKANUENCIA, aFontes:COURIER_08)
   MCOL+=08
   oPrn:Say( MLin  , Ori100xCol(MCOL), BuscaClass(Work->WKCLASS), aFontes:COURIER_08)
   MLin+=50
   oPrn:Say( MLin  , Ori100xCol(001),STR0106+Work->WKPART_N, aFontes:COURIER_08) //"P/N.: "

   IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"DESC_ITEM_REL"),)
   
   If lImpDescIt .and. !AvFlags("SUFRAMA")
      MLin+=50
      oPrn:Say( MLin, Ori100xCol(001), STR0210 +SB1->B1_DESC)  //"Descrição do Item: "
   EndIf

   MLin+=50
   cTexto:=''
   cTexto := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3))
   cCodProduto:=AllTrim(SB1->B1_COD)
   STRTRAN(cTexto, CHR(13)+CHR(10), " ")

   IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"DESC_LI_REL"),)

   SW4->(DBSEEK(xFilial()+Work->WKPGI_NUM))
   IF AvFlags("SUFRAMA") .AND. !EMPTY(SW4->W4_PROD_SU)
     SYX->(DBSETORDER(3))
     IF SYX->(DBSEEK(xFilial("SYX") + SW4->W4_PROD_SU + Work->WKCOD_I))
        IF !EMPTY(SYX->YX_DES_ZFM)
           cTexto := SYX->YX_DES_ZFM
        ELSE
           cTexto := cTexto := MSMM(SB1->B1_DESC_P,AVSX3("B1_VM_P",3))
        ENDIF
       cCodProduto:=AllTrim(SYX->YX_INSUMO)
     ENDIF
     SYX->(DBSETORDER(1))
   ENDIF

   FOR I := 1 TO MLCOUNT(cTexto,MLARG)

       IF EMPTY(MEMOLINE(cTexto,MLARG,I))
          LOOP
       ENDIF

       IF MLin > TOTLIN
          ORI100PODISubCAb(.T.,cFASE,.T.)
       ENDIF

       oPrn:Say( MLin, Ori100xCol(001),IF(I=1,cCodProduto+"-","")+ MEMOLINE(cTexto,MLARG,I), aFontes:COURIER_08)
       MLin+=50

   NEXT
   oPrn:Say( MLin, Ori100xCol(001), STR0209 +SYG->YG_REG_MIN)  //"Reg.Minist.: "
   MLin+=50

   IF lHunter 
      cDadosItem:=""
      ExecBlock("IC010DI1",.F.,.F.,"14")//AWR 11/11/1999      
      oPrn:Say( MLin, Ori100xCol(001),cDadosItem)
      MLin+=50
   ENDIF

   nRegAnt := Work->(RecNo()) //LGS-06/07/2016 - Guarda o RecNo atual.
   Work->(DBSKIP())

 ENDDO

ENDDO

IF MLin > TOTLIN
   MPAG++
   MontaCabRel(titulo, MPag,ALLTRIM(SY5->Y5_NOME))
   MLin+=50
ENDIF

oPrn:Say( MLin, Ori100xCol(nCOLTOT1),REPL('-',18), aFontes:COURIER_08)
oPrn:Say( MLin, Ori100xCol(nCOLTOT2),REPL('-',18), aFontes:COURIER_08)
MLin+=50
IF MLin > TOTLIN
   MPAG++
   MontaCabRel(titulo, MPag,ALLTRIM(SY5->Y5_NOME))
   MLin+=50
ENDIF
oPrn:Say( MLin, Ori100xCol(nCOLTOT1),TRANS(nPes_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
oPrn:Say( MLin, Ori100xCol(nCOLTOT2),TRANS(nVlr_Tot,"@E 999,999,999,999.99"), aFontes:COURIER_08)
MLin+=50
IF MLin > TOTLIN
   MPAG++
   MontaCabRel(titulo, MPag,ALLTRIM(SY5->Y5_NOME))
   MLin+=50
ENDIF
oPrn:Say( MLin, Ori100xCol(nCOLTOT1),REPL('-',20), aFontes:COURIER_08)
oPrn:Say( MLin, Ori100xCol(nCOLTOT2),REPL('-',20), aFontes:COURIER_08)
MLin+=50
IF MLin > TOTLIN
   MPAG++
   MontaCabRel(titulo, MPag,ALLTRIM(SY5->Y5_NOME))
   MLin+=50
ENDIF
oPrn:Say( MLin, Ori100xCol(MCOL4),STR0107, aFontes:COURIER_08) //"Total Geral"
oPrn:Say( MLin, Ori100xCol(nCOLTOT1),TRANS(nTot_Pes,"@E 999,999,999,999.99"), aFontes:COURIER_08)

MPAG:=0

If !lTemInvoice
   oPrn:Say( MLin, Ori100xCol(nCOLTOT2),TRANS(nTot_Vlr,"@E 999,999,999,999.99"), aFontes:COURIER_08)
   nTot_Vlr := 0
Else   
   For i := 1 to Len(aMoeda)
       oPrn:Say( MLin, Ori100xCol(nCOLTOT2),aMoeda[i][1]+TRANS(aMoeda[i][2],"@E 9,999,999,999.99"), aFontes:COURIER_08)
       MLin+=40
   Next
   aMoeda := {}
EndIf

SW2->(DBSETORDER(nOrdSW2))
SW6->(DBSETORDER(nOrdSW6))

DBSELECTAREA(cAliasImp)

RETURN NIL

*-------------------------*
FUNCTION ORI100Ret( pArea )
*-------------------------*
LOCAL OldRecno := SWP->( Recno() )
LOCAL OldAlias := SELECT() , lMarcados:=.F.
LOCAL cRegAnt  := OldRecno

PRIVATE nFob_PLI:= 0
PRIVATE MLin,MPag:=0, lPrimPag:=.t.
PRIVATE PGI_Chave:=''  ,nTot_PLI:=0,;
        tBate1vez:=.T.,nPesTotPLI:=0,MDesFrePLI:=0

IF pArea == 'SWP'
   SWP->( DBSEEK(xFilial()) )
   SWP->(DBEVAL( {||IF( WP_FLAGWIN == cMarca, lMarcados:= .T., )},,{||xFilial()==WP_FILIAL}))
ELSE
   SWP->( DBSETORDER( 1 ) )
   TRB->( DBGOTOP() )
   WHILE !TRB->( EOF() )

      IF TRB->WP_FLAGWIN == cMarca
         IF SWP->( DBSEEK( xFilial() + TRB->WP_PGI_NUM + TRB->WP_SEQ_LI ) )
            SWP->( RecLock( 'SWP', .F. ) )
            SWP->WP_FLAGWIN   := cMarca
            SWP->( MsUnlock() )
         ENDIF
         lMarcados:= .T.
      ENDIF
      TRB->( DBSKIP() )
   ENDDO
ENDIF

IF ! lMarcados
   Help("", 1, "AVG0000127")//E_Msg( STR0121,1000,.T.) //"Nao existem Registro marcados para Impressao."
   DBSELECTAREA(pArea)
   RETURN .T.
ENDIF

SWP->( DBGOTO( OldRecno ) )

PRINT oPrn NAME ""
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME STR0122 //"Controle de envio de LI para o orientador."

   ProcRegua(SWP->(LASTREC()+1))

   DEFINE FONT oFont1  NAME "Courier New"        SIZE 0,08         OF  oPrn

   aFontes := { oFont1 }

   AVPAGE
      SWP->( DBSEEK(xFilial()) )

      DO WHILE !SWP->( EOF() ) .AND.;
            xFilial("SWP")==SWP->WP_FILIAL
        IncProc(STR0123) //"Imprimindo..."
        IF SWP->WP_FLAGWIN <> cMarca
           SWP->( DBSKIP() )
           LOOP
        ENDIF
        ORI100Det()
        SWP->( DBSKIP() )
      ENDDO
	
	  IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"IMPRIME_EST_MUN"),) //MCF - 22/08/2014
	 
      IF nTot_PLI > 0
         MLin+=50
         IF MLin > TOTLIN
            ORI100Cab(.F.)
            MLin+=50
         ENDIF             
       
         oPrn:Say( MLin, Ori100xCol(069), STR0124 , aFontes:COURIER_08) //"Valor Total da PLI...............:"
         oPrn:Say( MLin, Ori100xCol(122), TRANS(nTot_PLI,"@E 999,999,999,999.99"), aFontes:COURIER_08,,,,1 )
         IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"TOTALIZADOR"),)  //LRS - 27/03/2015
      ENDIF
   AVENDPAGE

AVENDPRINT
oFont1:End()
  
MS_FLUSH()

SWP->( DBGOTO( OldRecno ) )
DBSELECTAREA(pArea)
RETURN NIL


*-------------------------*
FUNCTION ORI100Det()
*-------------------------*
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
Local nRatFre := 0
Private _PictPO  := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _PictPrUn :=ALLTRIM(X3Picture("W3_PRECO"  ))
Private _PictQtde :=ALLTRIM(X3Picture("W3_QTDE"   ))
Private _PictPrTot:=ALLTRIM(X3Picture("W2_FOB_TOT"))
PRIVATE nPesTotLI := nPesTotItem:= 0
PRIVATE lPrimeiro:=.F., sRecnoPo, sIndexPo, cFornAux, cForLoja := ""
PRIVATE Testa:= .T., mPGI_Num,mSeq_Li , nTx_Conv,MDesFreLI := 0, MCol
PRIVATE MDespesas := nValor_Tot := nValor_Uni := 0
PRIVATE nTot_Itens:= 0, nNumIte     := 0 ,nTot_Peso := 0, nTot_LI := 0
PRIVATE nFob_LI   := 0, MAusenciafa :="1",nNumIteIgu:= 0 ,nRecSW5 // PARA PART NUMBER NA DESCRICAO DA SUFRAMA
PRIVATE cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

SW5->( DbSetOrder( 7 ) )
SW4->( DbSeek( xFilial() + SWP->WP_PGI_NUM ) )

IF ! SW5->( DbSeek( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI ) )
   Return NIL
ENDIF

mPGI_Num := SW5->W5_PGI_NUM
mSeq_Li  := SW5->W5_SEQ_LI

IF EasyGParam( 'MV_RATEIO' ) $ cSim
   MDespesas:= SW4->W4_INLAND + SW4->W4_PACKING - SW4->W4_DESCONTO
   IF SW4->(FIELDPOS("W4_OUT_DES")) # 0 
      MDespesas+=SW4->W4_OUT_DES
   ENDIF                           
   // EOB - 14/07/08 - Tratamento de incoterms com seguro
   IF lSegInc .AND. SW4->W4_SEGINC $ cNao .AND. AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_SEG")/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
      MDespesas+=SW4->W4_SEGURO
   ENDIF   
ENDIF

IF PGI_Chave # SWP->WP_PGI_NUM .OR. tBate1vez
   nPesTotPLI  := 0
   IF lW4_Fre_Inc  .Or.  EasyGParam( 'MV_RAT_FRE' ) $ cSim
      SW5->( DbSeek( xFilial() + SWP->WP_PGI_NUM ) )
      WHILE mPGI_Num == SW5->W5_PGI_NUM .AND. !SW5->( EOF() ) .AND.;
            xFilial("SW5") == SW5->W5_FILIAL

         IF SW5->W5_SEQ # 0
            SW5->( DBSKIP() )
            LOOP
         ENDIF
         SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )

         nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/2001  // LDR OS 1239/03
         IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)//AWR 16/11/1999      
         IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)

         nPesTotPLI += SW5->W5_QTDE * nPesoItem   //<< PESO
         SW5->( DBSKIP() )
      ENDDO
   ENDIF
   nFob_PLI := SW4->W4_FOB_TOT

   IF EasyGParam( 'MV_RATEIO' ) $ cSim
      nFob_PLI += MDespesas
   ENDIF

   IF lW4_Fre_Inc .Or. EasyGParam( 'MV_RAT_FRE' ) $ cSim
      MDesFrePLI  := SW4->W4_FRETEINT              //<< PESO
      If !lW4_Fre_Inc  .Or.  ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE") ) /* FSM - 28/12/10 *///AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
         nFob_PLI += MDesFrePLI
      EndIf
   ENDIF

   SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM ) )

   sRecnoPo := SW2->( Recno() )
   sIndexPo := SW2->( indexord() )
   WHILE mPGI_Num == SW5->W5_PGI_NUM .AND. !SW5->( EOF() )  .AND.;
            xFilial("SW5") == SW5->W5_FILIAL

      IF SW5->W5_SEQ # 0
         SW5->( DBSKIP() )
         LOOP
      ENDIF

      SB1->( DBSETORDER(1) )
      SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )
      SW2->( DbSetOrder(1) )
      SW2->( DbSeek( xFilial()+SW5->W5_PO_NUM ) )
      SW4->(DBSEEK(xFilial()+SW5->W5_PGI_NUM))
      nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/01  // LDR OS 1239/03
      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)//AWR 16/11/1999      
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)

      nFob_PLI -= ROUND( SW5->W5_QTDE * SW5->W5_PRECO + ( MDespesas * ( ( SW5->W5_QTDE * SW5->W5_PRECO) / SW4->W4_FOB_TOT ) ), AVSX3("W6_FOB_TOT",4) )   //VI
      nFob_PLI -= ROUND( MDesFrePLI * ( SW5->W5_QTDE * nPesoItem / IF( nPesTotPLI <= 0, 1, nPesTotPLI ) ), AVSX3("W6_FOB_TOT",4) )

      SW5->( DBSKIP() )
   ENDDO
   SW2->( DbGoTo( sRecnoPo ) )
   SW2->( DbSetOrder( sIndexPo ) )

   IF !tBate1vez
      MLin+=50
      IF MLin > TOTLIN
         ORI100Cab(.F.)
         MLin+=50
      ENDIF
      oPrn:Say( MLin, Ori100xCol(069), STR0124 , aFontes:COURIER_08) //"Valor Total da PLI...............:"
      oPrn:Say( MLin, Ori100xCol(122), TRANS(nTot_PLI,"@E 999,999,999,999.99"), aFontes:COURIER_08,,,,1 )
      IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"TOTALIZADOR"),)  //LRS- 27/03/2015
      nTot_PLI := 0
      MLin+=50
   ENDIF

   lPrimeiro := .T.
   tBate1vez := .F.
   PGI_Chave := SWP->WP_PGI_NUM
   SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI ) )
   ORI100Cab(.T.)
ELSE
   ORI100SubCab()
ENDIF

sRecnoPo := SW2->( Recno() )
sIndexPo := SW2->( indexord() )
SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI ) )

WHILE mPGI_Num == SW5->W5_PGI_NUM .AND. mSeq_Li == SW5->W5_SEQ_LI .AND. !SW5->( EOF() ) .AND.;
            xFilial("SW5") == SW5->W5_FILIAL

   IF SW5->W5_SEQ # 0
      SW5->( DBSKIP() )
      LOOP
   ENDIF

   SB1->( DBSETORDER(1) )
   SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )
   SW2->( DbSetOrder(1) )
   SW2->( DbSeek( xFilial()+SW5->W5_PO_NUM ) )

   IF ! EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
      cFornAux:= SW2->W2_EXPORTA
      If EICLoja()
         cForLoja:= SW2->W2_EXPLOJ
      EndIf
   ELSE
      cFornAux:= SW5->W5_FORN
      If EICLoja()
         cForLoja:= SW2->W2_FORLOJ
      EndIf
   ENDIF

   IF Testa
      IF (SW5->W5_FABR # cFornAux .And. IIF(EICLoja(),SW5->W5_FABLOJ # cForLoja,.T.))
         IF (EMPTY(SW5->W5_FABR_01) .And. EICEmptyLJ("SW5","W5_FAB1LOJ")) .OR. ;
            ( (!EMPTY(SW5->W5_FABR_01) .And. !EICEmptyLJ("SW5","W5_FAB1LOJ") ) .AND. ;
            (SW5->W5_FABR == SW5->W5_FABR_01 .And. IIF(EICLoja(),SW5->W5_FABLOJ == SW5->W5_FAB1LOJ,.T.)))
            MAusenciafa := "2"
         ELSE 
            MAusenciafa := "3"
            Testa:=.F.
         ENDIF
      ENDIF
   ENDIF

   nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/01  // LDR OS - 1239/03
   IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)//AWR 16/11/1999      
   IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)

   nPesTotLI+=SW5->W5_QTDE * nPesoItem
   nFob_LI  +=SW5->W5_QTDE * SW5->W5_PRECO  // VI
   SW5->( DBSKIP() )
ENDDO

SW2->( DbGoTo( sRecnoPo ) )
SW2->( DbSetOrder( sIndexPo ) )

SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI ) )

MDesFreLI:= (MDesFrePLI*(NPesTotLI/IF(NPesTotPLI<=0,1,NPesTotPLI)))//<< PESO
MDespesas:= (MDespesas *(nFob_LI / SW4->W4_FOB_TOT ) )
mPGI_Num := SW5->W5_PGI_NUM
mSeq_Li  := SW5->W5_SEQ_LI
mCod_I   := SW5->W5_COD_I
nRecSW5 := SW5->(RECNO())
sRecnoPo := SW2->( Recno() )
sIndexPo := SW2->( indexord() )
nRecSW5 := SW5->(RECNO())
cPart_n := ""

WHILE mPGI_Num == SW5->W5_PGI_NUM .AND. mSeq_Li == SW5->W5_SEQ_LI .AND. !SW5->( EOF() ) .AND.;
            xFilial("SW5") == SW5->W5_FILIAL

   IF SW5->W5_SEQ # 0
      SW5->( DBSKIP() )
      LOOP
   ENDIF

   IF mCod_I # SW5->W5_COD_I
     Final_Item()
     MLin+=50
   ELSE
      nNumIteIgu++
   ENDIF

   IF MLin > TOTLIN
      ORI100Cab(.F.)
   ENDIF

   SB1->( DBSETORDER(1) )
   SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )
   SYF->( DBSEEK( xFilial() + IF(!EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ"),cMoedaDolar,SW2->W2_MOEDA) ) ) // VI
   SA5->(DBSETORDER(3))
   //SA5->( DBSEEK( xFilial() + SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN ) )
   EICSFabFor(xFilial("SA5")  + SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))
   SA5->(DBSETORDER(1))
   SW2->( DbSetOrder(1) )
   SW2->( DbSeek( xFilial() + SW5->W5_PO_NUM ) )
   
   cUnidade:=BUSCA_UM(SW5->W5_COD_I+SW5->W5_FABR +SW5->W5_FORN,SW5->W5_CC+SW5->W5_SI_NUM, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))
   
   IF cUnidade # SWP->WP_UNID
      IF AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
         nTx_Conv:=B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))  // LDR OS - 1239/03
      ELSE
         IF !SJ5->(DBSEEK(xFilial()+AVKEY(cUnidade,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+SW5->W5_COD_I))
         //If !SJ5->(DBSEEK(xFilial()+cUnidade+SWP->WP_UNID+SW5->W5_COD_I))
            SJ5->(DBSEEK(xFilial()+AVKEY(cUnidade,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+Space(AvSx3("J5_COD_I", AV_TAMANHO))))
         EndIf
         IF LEN(SJ5->J5_DE) > LEN(cUnidade)
            cUnidade:=cUnidade+SPACE(LEN(SJ5->J5_DE)-LEN(cUnidade))
         ENDIF
         IF !SJ5->(DBSEEK(xFilial()+AVKEY(cUnidade,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+SW5->W5_COD_I))
         //If !SJ5->(DBSEEK(xFilial()+cUnidade+SWP->WP_UNID+SW5->W5_COD_I))
            SJ5->(DBSEEK(xFilial()+AVKEY(cUnidade,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+Space(AvSx3("J5_COD_I", AV_TAMANHO))))
         EndIf
         nTx_Conv := SJ5->J5_COEF
      ENDIF
   ELSE
      nTx_Conv:= 1
   ENDIF

   nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/01  // LDR - OS 1239/03
   IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)//AWR 16/11/1999      
   IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)

   nPesTotItem:= SW5->W5_QTDE * nPesoItem             //<< PESO

   nValParid:=1
   IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")// VI
      nValParid := SW2->W2_PARID_US
   ENDIF
   nValor_Tot := ROUND( SW5->W5_QTDE * SW5->W5_PRECO + ( MDespesas * (SW5->W5_QTDE*SW5->W5_PRECO/IF(nFob_LI<=0,1,nFob_LI))),AVSX3("W6_FOB_TOT",4))+IF(lPrimeiro,nFob_PLI,0) // VI
   //nValor_Tot += ROUND( MDesFreLI*(SW5->W5_QTDE*nPesoItem/IF(nPesTotLI<=0,1,nPesTotLI)),AVSX3("W6_FOB_TOT",4))
   //** PLB 06/08/07
   If !lW4_Fre_Inc .Or. ( SW4->W4_FREINC $ cNao  .And.  AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
      nRatFre := ROUND( MDesFreLI*(SW5->W5_QTDE*nPesoItem/IF(nPesTotLI<=0,1,nPesTotLI)),AVSX3("W6_FOB_TOT",4))
      nValor_Tot += nRatFre
   EndIf
   //**

   IF EasyGParam("MV_RATEIO") $ cSim  .Or.  nRatFre > 0  // PLB 06/08/07  // EasyGParam("MV_RAT_FRE") $ cSim
      nValor_Uni:= ROUND( nValor_Tot / SW5->W5_QTDE, AVSX3("W7_PRECO",4) )
   ELSE
      nValor_Uni:= SW5->W5_PRECO  //VI
   ENDIF
   nTot_Peso  += nPesoItem * SW5->W5_QTDE
   nTot_Itens += nValor_Tot * nValParid
   nTot_PLI   += nValor_Tot * nValParid
   MCol       := ( 30 / 2 ) + 4 //18         

   oPrn:Say( MLin, Ori100xCol(002)  , AvKey(SW5->W5_PO_NUM, "W5_PO_NUM") + "  ";
                                    + AvKey(SW5->W5_COD_I, "W5_COD_I") + "  ";
                                    + Pad(TRANS(cUnidade,"@!") + " " + LTrim(TRANS(SW5->W5_QTDE,_PictQtde)), Len("Qtde Comercializada")) + "  ";
                                    + AvKey(LTrim(TRANS(nPesoItem*SW5->W5_QTDE,"@E 999,999,999.99999999")), "W5_PESO") + "  ";
                                    + AvKey(LTrim(TRANS(nValor_Uni*nValParid,_PictPrUn)), "W5_PRECO") + "  ";
                                    + AvKey(LTrim(TRANS(nValor_Tot*nValParid,_PictPrTot)), "W5_PRECO") + "  ";
                                    + Pad(LTrim(TRANS(SW5->W5_QTDE*nTx_Conv,_PictQtde)), Len("Qtde Estatistica"));
                                    , aFontes:COURIER_08 )

   MLin+=50    
 
   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
      SW3->(DbSetOrder(8))
      SW3->(DbSeek(xFilial("SW3") + SW5->W5_PO_NUM + SW5->W5_POSICAO))
      If !Empty(SW3->W3_PART_N)
         cPart_N :=  SW3->W3_PART_N  
      Else                     
         cPart_N := SA5->A5_CODPRF
      EndIf           
   Else 
      cPart_N := SA5->A5_CODPRF
   EndIf
   //oPrn:Say( MLin, Ori100xCol(002) , STR0125+SA5->A5_CODPRF , aFontes:COURIER_08) //"P/N : "
   oPrn:Say( MLin, Ori100xCol(002) , STR0125 + cPart_N , aFontes:COURIER_08) //"P/N : "
   MLin+=50

   lPrimeiro:=.F.
   nRecSW5 := SW5->(RECNO())
   SW5->( DBSKIP() )
ENDDO
SW2->( DbGoTo( sRecnoPo ) )
SW2->( DbSetOrder( sIndexPo ) )

Final_Item()

IF nNumIte > 1
   MLin+=50
   IF MLin > TOTLIN
      ORI100Cab(.F.)
      MLin+=50
   ENDIF
   oPrn:Say( MLin, Ori100xCol(069), STR0126, aFontes:COURIER_08) //"Valor Total no Local de Embarque.:"
   oPrn:Say( MLin, Ori100xCol(122), TRANS(nTot_LI,"@E 999,999,999,999,999.99"), aFontes:COURIER_08,,,,1 ) 
   MLin+=50
ENDIF
nNumIte:= 0

RETURN NIL

*------------------------------*
FUNCTION ORI100Cab(lBate)
*------------------------------*
LOCAL nCol:=2,cTexto,Line
LOCAL _PictPGI := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
LOCAL aTipoDoc  :=   {  STR0127       ,; //"1-Normal"
                        STR0128 ,; //"2-Substitutiva"
                        STR0129 ,; //"3-Cancelamento"
                        " "                  }

LOCAL aTipoAplic:={  STR0130   ,; //"00-Comercializacao "
                     STR0131   ,; //"01-Industrializacao"
                     STR0132   ,; //"02-Uso Proprio     "
                     STR0133   ,; //"03-Outras          "
                     STR0134   ,; //"04-PROEX           "
                     " "                        }
cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")//AWR - 13/12/2004 - Essa funcao é chamada do EICSU100.PRW Tambem.
SW2->( DBSETORDER(1))
SW4->( DBSETORDER(1))
SYF->( DBSETORDER(1))
SYT->( DBSETORDER(1))
SY8->( DBSETORDER(1))
SYZ->( DBSETORDER(1))
SW2->( DbSeek( xFilial() + SW5->W5_PO_NUM  ) )
SW4->( DbSeek( xFilial() + SW5->W5_PGI_NUM ) )
SYF->( DBSEEK( xFilial() + IF(!EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ"),cMoedaDolar,SW2->W2_MOEDA) ) ) // VI
SYT->( DBSEEK( xFilial() + SW2->W2_IMPORT  ) )
SY8->( DBSEEK( xFilial() + SW4->W4_REGIMP  ) )
SYZ->( DBSEEK( xFilial() + SW4->W4_PROD_SUF ) )

IF !EMPTY( SW4->W4_COND_PAG )
   SY6->( DBSEEK( xFilial() + SW4->W4_COND_PAG + STR( SW4->W4_DIAS_PAG, 3 ) ) )
ELSE
   IF ! EMPTY(SW2->W2_EXPORTA)  .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
      SY6->( DBSEEK( xFilial() + SW2->W2_COND_EX + STR( SW2->W2_DIAS_EX, 3 ) ) )
   ELSE
      SY6->( DBSEEK( xFilial() + SW2->W2_COND_PA + STR( SW2->W2_DIAS_PA, 3 ) ) )
   ENDIF
ENDIF

MLin:= 50
MPag++
MontaCabRel( STR0135, MPag,) //"RELATORIO DE P.L.I./L.I."
IF lBate

   oPrn:Say( MLin, Ori100xCol(nCol),   STR0136, aFontes:COURIER_08) //"Nr. PLI...............:                           Data PLI.........:"
   oPrn:Say( MLin, Ori100xCol(nCol+20),TRANS( SWP->WP_PGI_NUM, _PICTPGI), aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+61),DTOC(SW4->W4_PGI_DT), aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+86), STR0137+SYF->YF_COD_GI , aFontes:COURIER_08) //"Moeda....: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol), STR0138,aFontes:COURIER_08) //"Nome Importador/CGC...:"
   oPrn:Say( MLin, Ori100xCol(nCol+20), ALLTRIM( SYT->YT_NOME )+" / "+TRANS( SYT->YT_CGC, '@R 99.999.999/9999-99' ) , aFontes:COURIER_08)
   Mlin+=50

   IF ! EMPTY( SW2->W2_CONSIG )
      SYT->( DBSEEK( xFilial() + SW2->W2_CONSIG ) )
      oPrn:Say( MLin, Ori100xCol(nCol), STR0139+ALLTRIM( SYT->YT_NOME )+" / "+TRANS( SYT->YT_CGC,'@R 99.999.999/9999-99') , aFontes:COURIER_08) //"Consignatario / CGC...: "
      MLin+=50
      SYT->( DBSEEK( xFilial() + SW2->W2_IMPORT ) )
   ENDIF

   IF AvFlags("SUFRAMA")
      oPrn:Say( MLin, Ori100xCol(nCol    ),STR0140, aFontes:COURIER_08) //"Inscricao SUFRAMA.....:                           Cod. Atividade...:                  CPF Repr.:"
      oPrn:Say( MLin, Ori100xCol(nCol+020),TRANS(SYT->YT_INS_SUFR,'@R 99.9999.99-9'), aFontes:COURIER_08)
      oPrn:Say( MLin, Ori100xCol(nCol+061),TRANS(SYT->YT_COD_ATV,"@!"), aFontes:COURIER_08)
      oPrn:Say( MLin, Ori100xCol(nCol+098),TRANS(SYT->YT_CPF_REP, '@R 999.999.999-99'), aFontes:COURIER_08)
      MLin+=50
   ENDIF

   oPrn:Say( MLin, Ori100xCol(nCol    ),STR0141, aFontes:COURIER_08) //"URF Despacho..........:                           URF Chegada......:"
   oPrn:Say( MLin, Ori100xCol(nCol+20 ),SW4->W4_URF_DESP, aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+61 ),SW4->W4_URF_CHEG, aFontes:COURIER_08)
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol    ),STR0142, aFontes:COURIER_08) //"Comunicacao de Compra.:                           Incoterm.........:"
   oPrn:Say( MLin, Ori100xCol(nCol+020),SW4->W4_COMUNICA, aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+061),IF( EMPTY( SW4->W4_INCOTERM ),SW2->W2_INCOTERM, SW4->W4_INCOTERM ), aFontes:COURIER_08)
   MLin+=50

   cAco_Tar := SPACE(1)
   DO CASE
      CASE SW4->W4_ACO_TAR = "1" ; cAco_Tar := STR0143 //"-MERCOSUL"
      CASE SW4->W4_ACO_TAR = "2" ; cAco_Tar := STR0144 //"-ALADI"
      CASE SW4->W4_ACO_TAR = "3" ; cAco_Tar := STR0145 //"-OMC"
      CASE SW4->W4_ACO_TAR = "4" ; cAco_Tar := STR0146 //"-SGPC"
   ENDCASE

   oPrn:Say( MLin, Ori100xCol(nCol),STR0147, aFontes:COURIER_08) //"Acordo Tarifario......:                           Fundamentacao....:"
   oPrn:Say( MLin, Ori100xCol(nCol+20) ,SW4->W4_ACO_TAR + cAco_Tar, aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+61) ,SW4->W4_REGIMP+" - "+ SUBST( SY8->Y8_DES, 1, 22 ) + ' - ' + RI100TRI( SY8->Y8_REG_TRIB ), aFontes:COURIER_08)
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol   ) ,STR0148, aFontes:COURIER_08) //"Agencia Secex.........:                           Cod. Aladi.......:"
   oPrn:Say( MLin, Ori100xCol(nCol+020),SW4->W4_AGSECEX, aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+061),SWP->WP_ALADI, aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(nCol+086),STR0149+SWP->WP_SUBST, aFontes:COURIER_08) //"LI Subst.: "
   MLin+=50

   cCond_Mer := SPACE(1)
   DO CASE
      CASE SW4->W4_COND_MER = "1" ; cCond_Mer := STR0150 //"-NORMAL"
      CASE SW4->W4_COND_MER = "2" ; cCond_Mer := STR0151 //"-FABRICADO/ENCOMENDA"
      CASE SW4->W4_COND_MER = "3" ; cCond_Mer := STR0152 //"-MATERIAL USADO"
   ENDCASE
   oPrn:Say( MLin, Ori100xCol(nCol),STR0153, aFontes:COURIER_08) //"Condicao Mercadoria...:                           Ato. Concessorio.:"
   oPrn:Say( MLin, Ori100xCol(nCol+20),SW4->W4_COND_MER + cCond_Mer, aFontes:COURIER_08)
   
   nOrderSX3:=(IndexOrd())
   SX3->(DbSetOrder(2))                          //Usado para o Drawback
   lExisteWP_AC := SX3->(DbSeek("WP_AC"))
   SX3->(DBSETORDER(nOrderSX3))
   
   oPrn:Say( MLin, Ori100xCol(nCol+61),Transf(If(lExisteWP_AC, SUBSTR( SWP->WP_AC, 1, 13 ), SUBSTR( SW4->W4_ATO_CONC, 1, 13 )),'@R 9999999999999'), aFontes:COURIER_08)
   Mlin+=50

   oPrn:Say( MLin, Ori100xCol(nCol), STR0154, aFontes:COURIER_08) //"Complemento...........:"

   cImprime :=.F.
   cTexto:=""
   cTexto := MSMM(SW4->W4_DESC_GE,AVSX3("W4_VM_DESG",3))

   For Line:=1 TO MlCount(cTexto, 101) 
       IF Empty( MEMOLINE(cTexto, 101, Line ) )
          Loop
       Endif
       cImprime :=.T.

       oPrn:Say( MLin, Ori100xCol(nCol+20),  MEMOLINE(cTexto,101,Line), aFontes:COURIER_08)
       MLin+=50
   Next

   IF ! cImprime
      MLin+=50
   ENDIF

   IF AvFlags("SUFRAMA")
      oPrn:Say( MLin, Ori100xCol(nCol),STR0155, aFontes:COURIER_08) //"Tipo Documento........:                           Tipo Aplicacao...:"
      oPrn:Say( MLin, Ori100xCol(nCol+24),aTipoDoc  [IF(!EMPTY(SW4->W4_TIPO_DOC).AND.VAL(SW4->W4_TIPO_DOC)<5,VAL(SW4->W4_TIPO_DOC ),4)], aFontes:COURIER_08)
      oPrn:Say( MLin, Ori100xCol(nCol+69),aTipoAplic[IF(!EMPTY(SW4->W4_TIPOAPL).AND.VAL(SW4->W4_TIPOAPL)<6,VAL(SW4->W4_TIPOAPL),5)+1], aFontes:COURIER_08)
      MLin+=50

      oPrn:Say( MLin, Ori100xCol(nCol),STR0156, aFontes:COURIER_08) //"Produto ZFM...........:"
      oPrn:Say( MLin, Ori100xCol(nCol+20),SYZ->YZ_CODIGO+" / "+SYZ->YZ_DESCR, aFontes:COURIER_08)
      MLin+=50

   ENDIF

   oPrn:Box( MLin, 0, MLin+1, 3000 )
   MLin+=30
   oPrn:Say( MLin, Ori100xCol(nCol),STR0095, aFontes:COURIER_08) //"COBERTURA CAMBIAL"
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol),STR0157+PG100Cobertura(), aFontes:COURIER_08) //"Regime Cambial........: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol),STR0158+TRANS(SY6->Y6_COD,'@R 9.9.999')+" / "+TRANS(SY6->Y6_DIAS_PAG,'999')+" - "+MSMM(SY6->Y6_DESC_P,32,1), aFontes:COURIER_08) //"Condicao Pagamento....: "
   MLin+=50

   DO CASE
   CASE SY6->Y6_TIPOCOB = "1"
           oPrn:Say( MLin, Ori100xCol(nCol),STR0159  + SY6->Y6_TABELA +' - '+PG100DescTab(), aFontes:COURIER_08) //"Modalidade Pagamento..: "
           oPrn:Say( MLin, Ori100xCol(100), STR0160+STRZERO(SY6->Y6_DIAS,3,0), aFontes:COURIER_08) //"Qtde. Dias Limite Pagto.: "
           MLin+=50
      CASE SY6->Y6_TIPOCOB = "2"
           oPrn:Say( MLin, Ori100xCol(nCol),STR0159+ SY6->Y6_TABELA +' - '+PG100DescTab(), aFontes:COURIER_08) //"Modalidade Pagamento..: "
           MLin+=50
      CASE SY6->Y6_TIPOCOB = "3"
           oPrn:Say( MLin, Ori100xCol(nCol),STR0161+ SY6->Y6_INST_FI +' - '+PG100DescTab(), aFontes:COURIER_08) //"Inst. Financiadora....: "
           MLin+=50
      CASE SY6->Y6_TIPOCOB = "4"
           oPrn:Say( MLin, Ori100xCol(nCol),STR0162+ SY6->Y6_MOTIVO +' - '+PG100DescTab(), aFontes:COURIER_08) //"Motivo................: "
           MLin+=50
   ENDCASE
   ORI100SubCab()
ELSE
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol),STR0163+TRANS( SWP->WP_PGI_NUM, _PICTPGI)+"/"+SWP->WP_SEQ_LI+; //"Nr. P.L.I. no EASY....: "
                               STR0164+TRANS( SWP->WP_REGIST,"@R 99/9999999-9")+STR0165, aFontes:COURIER_08) //"     Nr. L.I. SISCOMEX.....: "###"     Continuacao..."
   oPrn:Box( MLin, 0, MLin+1, 3000 )
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol), AvKey("Nr. P. O.", "W5_PO_NUM") + "  " + AvKey("Codigo do Item", "W5_COD_I") + "  " + "Qtde Comercializada" + "  " + AvKey("Peso Total", "W5_PESO") + "  " + AvKey("Preco Unitario", "W5_PRECO") + "  " + AvKey("Valor Total", "W5_PRECO") + "  " + "Qtde Estatistica", aFontes:COURIER_08)
   //"   Nr. P. O.          Codigo do Item           Qtde Comercializada     Peso Total         Preco Unitario     Valor Total     Qtde Estatistica"
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol), trac("W5_PO_NUM") + "  " + trac("W5_COD_I") + "  " + Replicate("-", Len("Qtde Comercializada")) + "  " + trac("W5_PESO") + "  " + trac("W5_PRECO") + "  " + trac("W5_PRECO") + "  " + Replicate("-", Len("Qtde Estatistica")), aFontes:COURIER_08)
   MLin+=100
ENDIF

RETURN NIL

//EJA - 17/12/2018 - Replica traços com o mesmo tamanho do campo cField no SX3
Static Function trac(cField)
Return Replicate("-", TamSX3(cField)[1])

*----------------------------*
FUNCTION ORI100SubCab()
*----------------------------*
LOCAL nCol := 2, cFornAux , cForLoja := ""
LOCAL _PictPGI := ALLTRIM(X3PICTURE("W4_PGI_NUM"))

SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI ) )

IF !EMPTY( SW2->W2_EXPORTA ) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
   SA2->( DBSEEK( xFilial() + SW2->W2_EXPORTA + EICRetLoja("SW2","W2_EXPLOJ")) )
   cFornAux:= SW2->W2_EXPORTA
   If EICLoja()
      cForLoja:= SW2->W2_EXPLOJ
   EndIf
ELSE
   SA2->( DBSEEK( xFilial() + SW5->W5_FORN + EICRetLoja("SW5","W5_FORLOJ")) )
   cFornAux:= SW5->W5_FORN
   If EICLoja()
      cForLoja:= SW5->W5_FORLOJ
   EndIf
ENDIF

IF (SW5->W5_FABR # cFornAux .OR. IIF(EICLoja(),SW5->W5_FABLOJ # cForLoja,.F.)) 
   IF (EMPTY(SW5->W5_FABR_01) .And. EICEmptyLJ("SW5","W5_FAB1LOJ")) .OR.;
      ((!EMPTY(SW5->W5_FABR_01) .And. !EICEmptyLJ("SW5","W5_FAB1LOJ")).AND.;
      (SW5->W5_FABR == SW5->W5_FABR_01 .And. IIF(EICLoja(),SW5->W5_FABLOJ == SW5->W5_FAB1LOJ,.T.)))
      MAusenciafa := "2"
   ELSE 
      MAusenciafa := "3"
   ENDIF
ENDIF
SB1->( DBSETORDER(1) )
SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )
cNCM := Busca_NCM("SW5",)
SYD->(DBSEEK(xFilial()+cNCM))
 

IF ( MLin + 450 ) > TOTLIN
   MLin:= 50
   MPag++
   MontaCabRel( STR0135, MPag,) //"RELATORIO DE P.L.I./L.I."
ELSE
   oPrn:Box( MLin , 0, MLin+1, 3000 )
ENDIF

MLin+=30
oPrn:Say( MLin, Ori100xCol(nCol),STR0167,aFontes:COURIER_08) //"Nr. P.L.I. no EASY....:                           Fornecedor Codigo/Nome.: "
oPrn:Say( MLin, Ori100xCol(nCol+20),TRANS(SWP->WP_PGI_NUM, _PICTPGI)+"/"+SWP->WP_SEQ_LI, aFontes:COURIER_08)
oPrn:Say( MLin, Ori100xCol(nCol),"                                                                           "+cFornAux+" - "+SA2->A2_LOJA +" / "+AllTrim(SA2->A2_NOME), aFontes:COURIER_08)
MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol),"                                                                           "+ALLTRIM( SA2->A2_END )+" "+PADL( SA2->A2_NR_END, 6, "0" ), aFontes:COURIER_08)
MLin+=50

IF SA2->A2_ID_REPR $ cSim
   oPrn:Say( MLin, Ori100xCol(nCol),STR0168+ALLTRIM( SA2->A2_REPRES ), aFontes:COURIER_08) //"                                                  Dados do Representante.: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol),"                                                                           "+ALLTRIM(SA2->A2_REPR_END), aFontes:COURIER_08)
   MLin+=50
ENDIF

IF MAusenciafa == "2"
   SA2->( DBSEEK( xFilial() + SWP->WP_FABR + EICRetLoja("SWP","WP_FABLOJ")) )
   oPrn:Say( MLin, Ori100xCol(nCol),STR0169+SWP->WP_FABR+ IIF(EICLoja()," - "+SWP->WP_FABLOJ,"") +" / "+SA2->A2_NOME, aFontes:COURIER_08) //"                                                  Fabricante Codigo/Nome.: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(nCol),"                                                                           "+ALLTRIM( SA2->A2_END )+" "+PADL( SA2->A2_NR_END, 6, "0" ), aFontes:COURIER_08)
   MLin+=50
   SA2->(DBSEEK(xFilial("SA2")+cFornAux+IIF(EICLoja(),cForLoja,"")))
ENDIF

oPrn:Say( MLin, Ori100xCol(nCol),STR0170+TRANS( SWP->WP_REGIST, "@R 99/9999999-9" ), aFontes:COURIER_08) //"Nr. L.I. SISCOMEX.....: "

DO CASE
   CASE MAusenciafa == "1"
        oPrn:Say( MLin , Ori100xCol(nCol),STR0171, aFontes:COURIER_08) //"                                                  Fornecedor = Fabricante (X)"
   CASE MAusenciafa == "2"
        oPrn:Say( MLin , Ori100xCol(nCol),STR0172, aFontes:COURIER_08) //"                                                  Fornecedor # Fabricante (X)"
   CASE MAusenciafa == "3"
        oPrn:Say( MLin , Ori100xCol(nCol),STR0173, aFontes:COURIER_08) //"                                                  Fabricante Desconhecido (X)"
ENDCASE

MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol),STR0174, aFontes:COURIER_08) //"Pais Aquisicao Merc...:                           Pais Origem Mercadoria.:                          Pais Procedencia.:"
SYA->( DBSEEK( xFilial() + SA2->A2_PAIS ) )
oPrn:Say( MLin , Ori100xCol(022),SYA->YA_CODGI +" "+ LEFT( SYA->YA_DESCR, 20 ), aFontes:COURIER_08)

SA2->( DBSEEK( xFilial() + SW5->W5_FABR + EICRetLoja("SW5","W5_FABLOJ")) )
SYA->( DBSEEK( xFilial() + SA2->A2_PAIS ) )
oPrn:Say( MLin ,Ori100xCol(nCol),"                                                                           "+SYA->YA_CODGI +" "+LEFT( SYA->YA_DESCR, 20 ), aFontes:COURIER_08)

IF EMPTY( SWP->WP_PAIS_PR )
   SYR->( DBSEEK( xFilial() + SW2->W2_TIPO_EMB + SW2->W2_ORIGEM + SW2->W2_DEST ) )
   SYA->( DBSEEK( xFilial() + SYR->YR_PAIS_OR ) )
ELSE
   SYA->( DBSEEK( xFilial() + SWP->WP_PAIS_PR ) )
ENDIF

oPrn:Say( MLin, Ori100xCol(121) ,SYA->YA_CODGI +" "+LEFT( SYA->YA_DESCR, 20 ), aFontes:COURIER_08)
MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol),STR0175, aFontes:COURIER_08) //"NCM/EX. NCM/EX. NBM...:                           Nr. Destaque...........:"
oPrn:Say( MLin, Ori100xCol(nCol+20),TRANS( SYD->YD_TEC,'@R 9999.99.99')+"/"+SYD->YD_EX_NCM+"/"+SYD->YD_EX_NBM, aFontes:COURIER_08)
oPrn:Say( MLin, Ori100xCol(nCol+75),SWP->WP_DESTAQ, aFontes:COURIER_08)
MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol)   ,STR0176+SWP->WP_NAL_SH, aFontes:COURIER_08) //"Unidade...............:                           Naladi SH..............: "
oPrn:Say( MLin, Ori100xCol(nCol+20),SWP->WP_UNID, aFontes:COURIER_08)
MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol)   ,STR0177+SWP->WP_SUFRAMA, aFontes:COURIER_08) //"PLI Suframa...........: "
MLin+=50
oPrn:Box( MLin, 0, MLin+1, 3000 )
MLin+=30
oPrn:Say( MLin, Ori100xCol(nCol), AvKey("Nr. P. O.", "W5_PO_NUM") + "  " + AvKey("Codigo do Item", "W5_COD_I") + "  " + "Qtde Comercializada" + "  " + AvKey("Peso Total", "W5_PESO") + "  " + AvKey("Preco Unitario", "W5_PRECO") + "  " + AvKey("Valor Total", "W5_PRECO") + "  " + "Qtde Estatistica", aFontes:COURIER_08)
//"   Nr. P. O.          Codigo do Item           Qtde Comercializada     Peso Total         Preco Unitario     Valor Total     Qtde Estatistica"
MLin+=50
oPrn:Say( MLin, Ori100xCol(nCol), trac("W5_PO_NUM") + "  " + trac("W5_COD_I") + "  " + Replicate("-", Len("Qtde Comercializada")) + "  " + trac("W5_PESO") + "  " + trac("W5_PRECO") + "  " + trac("W5_PRECO") + "  " + Replicate("-", Len("Qtde Estatistica")), aFontes:COURIER_08)
MLin+=50

RETURN NIL

*--------------------------*
FUNCTION Final_Item()
*--------------------------*
LOCAL I,MLARG:=55
LOCAL nOrd := SA5->(INDEXORD())
LOCAL nRecANTSW5 := SW5->(RECNO())
PRIVATE cTexto:="" 
SW5->(DBGOTO(nRecSW5))

SB1->( DBSETORDER(1) )
SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )
SW4->( DBSEEK( xFilial() + SW5->W5_PGI_NUM ) )

cTexto := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3))

IF AvFlags("SUFRAMA") .AND. !EMPTY(SW4->W4_PROD_SU)
  SYX->(DBSETORDER(3))
  IF SYX->(DBSEEK (xFilial("SYX") + SW4->W4_PROD_SU+SB1->B1_COD))
    SA5->(DBSETORDER(3))
    //SA5->(DBSEEK(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
    EICSFabFor(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))
    cTexto := ALLTRIM(SYX->YX_DES_ZFM)+" "+ ALLTRIM(SB1->B1_ESPECIF)+ " "

   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
      SW3->(DbSetOrder(8))
      SW3->(DbSeek(xFilial("SW3") + SW5->W5_PO_NUM + SW5->W5_POSICAO))
      If !Empty(SW3->W3_PART_N)
         cTexto +=  SW3->W3_PART_N  +" " 
      Else                                 
         cTexto += ALLTRIM(SA5->A5_CODPRF)+" "
      EndIf   
   Else 
      cTexto += ALLTRIM(SA5->A5_CODPRF)+" "
   EndIf
   
    cTexto += ALLTRIM(SA5->A5_PARTOPC)+" "+ALLTRIM(SB1->B1_MAT_PRI)
    SA5->(DBSETORDER(nOrd))
  ENDIF
  SYX->(DBSETORDER(1))
ENDIF
IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"DESCRICAO_ITEM"),) //BHF-22/05/09
SW5->(DBGOTO(nRecANTSW5))

FOR I := 1 TO MLCOUNT(cTexto,MLARG)

    IF EMPTY(MEMOLINE(cTexto,MLARG,I))
       LOOP
    ENDIF

    If mLin > TOTLIN
       ORI100Cab(.F.)
    Endif

    oPrn:Say( MLin ,Ori100xCol(002),MEMOLINE(cTexto,MLARG,I), aFontes:COURIER_08)
    MLin+=50
NEXT

IF lHunter 
   cDadosItem:=""
   ExecBlock("IC010DI1",.F.,.F.,"16")//AWR 16/11/1999
   oPrn:Say( MLin, Ori100xCol(002),cDadosItem)
   MLin+=50
ENDIF

IF nNumIteIgu > 0
   nNumIteIgu:=0
   oPrn:Say( MLin, Ori100xCol(068),REPL('-',22), aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(107),REPL('-',20), aFontes:COURIER_08)
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(050),STR0178, aFontes:COURIER_08) //"Peso Total Item.:"
   oPrn:Say( MLin, Ori100xCol(070),TRANS(nTot_Peso,"@E 99,999,999.99999999"), aFontes:COURIER_08)
   oPrn:Say( MLin, Ori100xCol(085),STR0179, aFontes:COURIER_08) //"      Total Item.:"
   oPrn:Say( MLin, Ori100xCol(105),TRANS(nTot_Itens,"@E 9,999,999,999,999.9999"), aFontes:COURIER_08)
   MLin+=50
Endif

mCod_I    := SW5->W5_COD_I
nTot_LI   += nTot_Itens
nNumIte   += 1
nTot_Peso := 0
nTot_Itens:= 0
RETURN NIL

*--------------------------------------------------------------*
FUNCTION MontaCabRel(PTexto01, PPag, PTexto02)
*--------------------------------------------------------------*
IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF
MLin:=50

oPrn:Box( MLin , 0, MLin+1, 3000 )

MLin+=30
oPrn:Say( MLin, Ori100xCol(0), ALLTRIM(SM0->M0_NOMECOM), aFontes:COURIER_08)
oPrn:Say( MLin, 1500, pTexto01, aFontes:COURIER_08,,,,2) 
oPrn:Say( MLin, 2400, STR0180+STRZERO( PPag ,3,0), aFontes:COURIER_08) //"Pagina..:"
MLin+=50

IF PTexto02 = NIL
   //oPrn:Say( MLin, Ori100xCol(0) , "Average Tecnologia", aFontes:COURIER_08)
   oPrn:Say( MLin, 2400, STR0181+DTOC(dDataBase), aFontes:COURIER_08) //"Emissao.:"
ELSE
   //oPrn:Say( MLin, Ori100xCol(0) , "Average Tecnologia", aFontes:COURIER_08) //"Average Tecnologia"
   //oPrn:Say( MLin, 1500, pTexto02, aFontes:COURIER_08,,,,2) BCO - 28/09/12 - Retirado o Nome da Average
   oPrn:Say( MLin, 2400, STR0181+DTOC(dDataBase), aFontes:COURIER_08) //"Emissao.:"
ENDIF
MLin+=50
oPrn:Box( MLin, 0, MLin+1, 3000 )
MLin+=30

RETURN .T.

*---------------------------*
FUNCTION PG100DESCT() 
*---------------------------*
LOCAL cTexto
IF SY6->Y6_TIPOCOB = "4"
   SJ8->(DBSEEK(xFilial("SJ8")+SY6->Y6_MOTIVO))
   cTexto:=SJ8->J8_DESC
ELSEIF SY6->Y6_TIPOCOB # "3"
   SJ6->(DBSEEK(xFilial("SJ6")+SY6->Y6_TABELA))
   cTexto:=SJ6->J6_DESC
ELSE
   SJ7->(DBSEEK(xFilial("SJ7")+SY6->Y6_INST_FI))
   cTexto:=SJ7->J7_DESC
ENDIF

RETURN cTexto

*-----------------------------*
FUNCTION RI100Tri(PTipo)
*-----------------------------*
LOCAL MTipo:=SPACE(21)

DO CASE
   CASE PTipo = "1"
        MTipo:= STR0183 //"Recolhimento Integral"

   CASE PTipo = "2"
        MTipo:= STR0184 //"Imunidade            "

   CASE PTipo = "3"
        MTipo:= STR0185 //"Isencao              "

   CASE PTipo = "4"
        MTipo:= STR0186 //"Reducao              "

   CASE PTipo = "5"
        MTipo:= STR0187 //"Suspencao            "

   CASE PTipo = "6"
        MTipo:= STR0188 //"Nao Incidencia       "

ENDCASE

RETURN MTipo

*------------------------------------*
Function Ori100xCol( pnColuna )
*------------------------------------*
Return ( pnColuna * 20 )

*-------------------*
Function ORI100VMQ()
*-------------------*
LOCAL lRetorno:=SX5->(DBSEEK(xFilial()+'Y5'+M->mv_par01))
LOCAL cMaquina
IF !lRetorno
   Help(" ",1,"EICMAQ")
ENDIF
cMaquina:=Alltrim(SX5->X5_CHAVE)
IF SX5->(!DBSEEK(xFilial("SX5")+"CE"+cMaquina)) .OR. EMPTY(SX5->X5_DESCRI)
   MsgAlert(STR0211)//"Caminho da Maquina nao encontrado"
   lRetorno:=.F.
ENDIF

Return lRetorno

*-------------------*
FUNCTION ORI100Per()
*-------------------*
IF mv_par02 > mv_par03
   Help(" ",1,"EFUNPERI")
   RETURN .F.
ENDIF
RETURN .T.

*-----------------------------------------*
FUNCTION ORI100PrePro(OldArea,cFASE)
*-----------------------------------------*
LOCAL lPrimeiro := .T., nValParid:=1
Local aSW5Ord  //BCO - 20/09/12 Variavel que guarda a ordem da tabela SW5
WORK->(avzap())
IF cFase = FASE_DI
   cPos_Fil:=SW7->(FIELDPOS('W7_FILIAL'))
ELSE
   cPos_Fil:=SW3->(FIELDPOS('W3_FILIAL'))
ENDIF
cFil:=xFilial(OldArea)
WHILE ! (OldArea)->(EOF()) .AND.;
        (AreaPrincipal)->(FIELDGET(cPos_Chave)) == (OldArea)->(FIELDGET(cPos_Det)) .AND.;
        (OldArea)->(FIELDGET(cPos_Fil)) = cFil

   IF cFase = FASE_DI
      IF EVAL(SEQ) # 0
         (OldArea)->(DBSKIP()) ; LOOP
      ENDIF
      SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
      SW4->(DBSEEK(xFilial("SW4")+SW7->W7_PGI_NUM))
      sArea := SELECT() ; sOrder := INDEXORD()
      PosO1_ItPedidos(SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,SW7->W7_SEQ,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"))
      cUnidade:=BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"))
      DBSELECTAREA( sArea )  ;  DBSETORDER( sOrder )
   ELSE
      IF EVAL(SEQ) # 0  //ASR 10/01/2006 - IF EVAL(SEQ) == 0
         (OldArea)->(DBSKIP()) ; LOOP
      ENDIF
      cUnidade:=BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))
   ENDIF

   IF ! EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ")
      nValParid:=SW2->W2_PARID_US
   ELSE
      nValParid:=1
   ENDIF

   SB1->(DBSETORDER(1))
   SB1->(DBSEEK(xFilial()+EVAL(COD_I)))
   SA5->(DBSETORDER(3))
   SA5->(DBSEEK(xFilial()+EVAL(COD_I) + EVAL(FABR) + EVAL(FORN)))
   SA5->(DBSETORDER(1))
   
   IF cFASE == FASE_PO
      SW5->(DBSEEK(xFilial()+SW3->W3_PGI_NUM+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_COD_I))
   ELSE
      SW5->(DBSEEK(xFilial()+SW7->W7_PGI_NUM+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I))
   ENDIF
   SWP->(DBSEEK(xFilial()+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI))

   sArea := SELECT()      ;  sOrder := INDEXORD()
   PosO1_It_Solic( (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=2,'W7','W3')+'_CC'))), (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=2,'W7','W3')+'_SI_NUM'))), EVAL(COD_I), EVAL(REG), 0 )
   DBSELECTAREA( sArea )  ;  DBSETORDER( sOrder )
   nPesoItem:=If(cFase=2,W5Peso(),B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))) //FCD 04/07/01  // LDR - OS 1239/03
   SAH->(DBSEEK(xFILIAL("SAH")+cUnidade)) 
   IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"10"),)//AWR 11/11/1999      
   IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOIT_W3"),)

   IF cUnidade # SWP->WP_UNID

      IF ALLTRIM(SWP->WP_UNID) == "10"
         cTx_Conv:=nPesoItem
      ELSE
//         SJ5->(DBSEEK(xFilial()+cUnidade+SWP->WP_UNID))
           SJ5->(DBSEEK(xFilial()+AVKEY(cUnidade,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+SW5->W5_COD_I))
         cTx_Conv := SJ5->J5_COEF
      ENDIF
   ELSE
      cTx_Conv := 1
   ENDIF
                                  
   If MDesFrePODI # 0 .OR. MDespesas # 0
      cValor_Tot := ROUND(EVAL(QTDE)*EVAL(PRECO)+(MDespesas * ((EVAL(QTDE)*EVAL(PRECO))/(AreaPrincipal)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,'W6_','W2_')+'FOB_TOT')))))+IF(lPrimeiro,mFob_Total,0),AVSX3("W6_FOB_TOT",4))
      cValor_Tot += ROUND(MDesFrePODI*(EVAL(QTDE)*nPesoItem/IF(nPesTotPODI<=0,1,nPesTotPODI)),AVSX3("W6_FOB_TOT",4)) //<< PESO
      cValor_Uni := cValor_Tot / EVAL(QTDE)
   Else
      cValor_Tot := ROUND(EVAL(QTDE)*EVAL(PRECO),AVSX3("W6_FOB_TOT",4))   
      cValor_Uni := EVAL(PRECO)
   EndIf
   SYD->(DBSEEK(xFilial()+ Busca_NCM(IF(cFase == FASE_DI,"SW7","SW3"),)))

   Work->(DBAPPEND())
   Work->WKNCM      := SYD->YD_TEC
   Work->WKEX_NCM   := SYD->YD_EX_NCM
   Work->WKEX_NBM   := SYD->YD_EX_NBM
   Work->WKQUAL_NCM := SYD->YD_EX_NCM
   Work->WKQUALIF   := SYD->YD_EX_NBM
   Work->WKFABR     := EVAL(FABR)                                                             
   //FDR - 13/05/13 - Gravação do campo loja
   Work->WKFABLOJ   := (OLDAREA)->(FIELDGET(FIELDPOS(IF(CFASE=FASE_DI,"W7_","W3_")+"FABLOJ")))
   Work->WKDESTAQ   := SYD->YD_DESTAQUE
   Work->WKREGIST   := SWP->WP_REGIST
   Work->WKPO_NUM   := (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'PO_NUM')))
   Work->WKPGI_NUM  := (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'PGI_NUM')))
   Work->WKCOD_I    := EVAL(COD_I)
   Work->WKUNID     := cUnidade
   Work->WKQTDE     := EVAL(QTDE)

   Work->WKPRECO    := Round(cValor_Uni * nValParid,AVSX3("W7_PRECO",4))
   Work->WKPRECO_T  := Round(cValor_Tot * nValParid,AVSX3("W6_FOB_TOT",4))

   Work->WKQTE_ES   := EVAL(QTDE) * cTx_Conv
   Work->WKANUENCIA := IF((OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'FLUXO')))=='7',STR0193,STR0194) //'Nao'###'Sim'
   //Work->WKPART_N   := SA5->A5_CODPRF
   Work->WKCLASS    := SW1->W1_CLASS
   Work->WKPESO_T   := EVAL(QTDE) * nPesoItem
   
   If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007    
      SW3->(DbSetOrder(8))
      If cFase = FASE_DI
         SW3->(DbSeek(xFilial("SW3") + SW7->W7_PO_NUM + SW7->W7_POSICAO))
      EndIf                                   
      If !Empty(SW3->W3_PART_N)      
         Work->WKPART_N :=  SW3->W3_PART_N  + chr(13)+chr(10)  
      Else                            
         Work->WKPART_N := SA5->A5_CODPRF
      EndIF   
   Else 
      Work->WKPART_N := SA5->A5_CODPRF
   EndIf

   Work->WKMOEDA    := SW2->W2_MOEDA
   Work->WKCOND     := SW2->W2_COND_PA
   Work->WKDIAS     := STR(SW2->W2_DIAS_PA,3,0) 
   
   
   
   IF cFase == FASE_DI .AND. lNVE .AND. lPrintNVE
     aSW5Ord := SaveOrd("SW5",7) //BCO - 20/09/12 Salva a ordem corrente da tabela SW5 e define a ordem 7.
   
      SW5->(DbSeek( xFilial("SW5") + SW7->W7_PGI_NUM + SW7->W7_SEQ_LI + STR(SW7->W7_SEQ,2,0) + SW7->W7_COD_I ))
   
      if !empty(SW5->W5_NVE) //BCO - 20/09/12 Adiciona o conteudo do campo NVE da Tabela SW5 na work
         Work->WKNVE := SW5->W5_NVE
      endif 
      restOrd(aSW5Ord)
   Endif
   
          
   IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"15"),)//AWR 11/11/1999      
   IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"GRAVA_WORK"),) //BHF - 22/05/09      

   nTot_Pes+=Work->WKPESO_T
   nTot_Vlr+=Work->WKPRECO_T

   lPrimerio := .F.

   (OldArea)->(DBSKIP())
ENDDO

Work->(DBCOMMIT())

RETURN NIL

*-------------------------------------------------------*
FUNCTION ORI100PODISubCAb(lImpCab,cFASE,lSubCabec)
*-------------------------------------------------------*
LOCAL MCOL:=1
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
Local cNivel := "" // BCO - 21/09/2012 - Armazena o nivel da NVE de acordo com seu codigo
Local aOrdEIM // bco - Guarda a ordem da tabela EIM
Local i := 1 // BCO - 21/09/12 - Variavel contadora.


If Empty(cLastncm) // //BCO - 21/09/12 - Verifica o conteúdo da variável.
   cLastNCM := ""
endif

If Empty(cLastNVE)
   cLastNVE := "" //BCO 28/09/12 Define valor padrao da variavel  cLastNVE
ENDIF


IF lImpCab
   MPAG++
   MontaCabRel(titulo, MPag,SUBSTR(ALLTRIM(SY5->Y5_NOME),1,40))
   MLin+=50
ELSE
   oPrn:Box( MLin , 0, MLin+1, 3000 )
   MLin+=30
ENDIF

If lSubCabec

 	SYD->(DbSetORder(1)) //FMB 08/06/04 - exibicao das aliq. do II e IPI
	SYD->(DBSEEK(xFilial()+Work->WKNCM+Work->WKEX_NCM+Work->WKEX_NBM)) // GCC - 11/07/2013
  	
   oPrn:Say( MLin, Ori100xCol(001),STR0195+TRANS(Work->WKNCM,'@R 9999.99.99')+"/"+Work->WKQUAL_NCM+"/"+Work->WKQUALIF, aFontes:COURIER_08) //"NCM/EX. NCM/EX. NBM.: "
   oPrn:Say( MLin, Ori100xCol(040),"II: "+TRANS(SYD->YD_PER_II, _PICTPGI)+"% IPI: "+TRANS(SYD->YD_PER_IPI, _PICTPGI)+"% PIS: ";
   +TRANS(SYD->YD_PER_PIS, _PICTPGI)+"% COFINS: "+TRANS(SYD->YD_PER_COF, _PICTPGI)+"% ICMS: "+TRANS(SYD->YD_ICMS_RE, _PICTPGI)+"%", aFontes:COURIER_08)  //LRS 26/09/2013 - Adicionado no relatorio PIS/COFINS/ICMS
   //LRS - 28/06/2017
   IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"IMPOSTOS"),) //FMB 14/06/04
   
   oPrn:Say( MLin, Ori100xCol(083),STR0196+Work->WKFABR+" - "+ALLTRIM(BuscaF_F(Work->WKFABR, /*lREDUZIDO*/,Work->WKFABLOJ))/*+" - "+ALLTRIM(SA2->A2_END)+" "+STR0197+SA2->A2_PAIS*/, aFontes:COURIER_08) //"Fabricante.: "###" Pais Origem.: "
   MLin+=50
   oPrn:Say( MLin, Ori100xCol(083),STR0216+":"+ALLTRIM(SA2->A2_END)+" "+STR0197+SA2->A2_PAIS, aFontes:COURIER_08) //MCF - 09/04/2015 - Quebra de linha endereço do fornecedor
   MLin+=50
   
   oPrn:Say( MLin, Ori100xCol(001),STR0198+Work->WKDESTAQ, aFontes:COURIER_08) //"Nr. Destaque........: "
   oPrn:Say( MLin, Ori100xCol(050),STR0199+Work->WKREGIST, aFontes:COURIER_08) //"Nr. LI.....: "
   oPrn:Say( MLin, Ori100xCol(070),"Nr. PLI....: "+WKPGI_NUM, aFontes:COURIER_08)
   IF cFase == FASE_DI
      SY8->( DBSEEK( xFilial() + SW4->W4_REGIMP  ) )
      oPrn:Say( MLin, Ori100xCol(095),STR0070+SUBST(SY8->Y8_DES,1,18) + ' - ' + RI100TRI(SY8->Y8_REG_TRI), aFontes:COURIER_08) //"Reg. Importacao..: "
      if lNVE //.AND. lPrintNVE // 24/09/12 - Caso o parametro de NVE esteja ligado e o usuário deseja imprimir as NVE'S
         aOrdEIM := SaveOrd("EIM",3)
         EIM->(DbSetOrder(3)) 
         //MFR 26/11/2018 OSSME-1483
         //EIM->(DbSeek(xFilial("EIM") + "LI" + AVKEY(Work->WKPGI_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO"))) // BCO - Posiciona a tabela EIM de acordo com o indice da WORK
         EIM->(DbSeek(GetFilEIM("LI") + "LI" + AVKEY(Work->WKPGI_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO"))) // BCO - Posiciona a tabela EIM de acordo com o indice da WORK         
         Do Case 
            Case (EIM->(EIM_NIVEL) == "1");  cNivel := "C-Capitulo" // BCO - Decide o nivel da NVE
            Case (EIM->(EIM_NIVEL) == "2");  cNivel := "P-Posicao" 
            Case (EIM->(EIM_NIVEL) == "3");  cNivel := "U-SubItem"  
            Case (EIM->(EIM_NIVEL) == "4");  cNivel := "AS-SubPosicao Nivel 1" 
            Case (EIM->(EIM_NIVEL) == "5");  cNivel := "BS-SubPosicao Nivel 2" 
         ENDCASE      
         if !empty(cNivel) // //BCO 28/09/12 Tratamento para imprimir nivel apenas se o registro estiver associado á uma NVE
            MLin+=50
            oPrn:Say( MLin, Ori100xCol(001), "Nivel = " + cNivel) // BCO -  Imprime o NIVEL
         endif
         RestOrd(aOrdEIM)
      ENDIF
   ENDIF
   MLin+=50
   oPrn:Box( MLin , 0, MLin+1, 3000 )

   cNCM   := Work->WKNCM+Work->WKEX_NCM+Work->WKEX_NBM
   nFabri := Work->WKFABR 
   If EICLoja()
      cFabLoj:= Work->WKFABLOJ
   EndIf
   
         

   
   if cFase = FASE_DI .AND. lNve  .AND. (WORK->(WKNCM) != cLastNCM .OR. lGeraCab) //.AND. lPrintNVE    // BCO - 21/09/12 -  Caso todas as condições sejam satisfeitas são impressas os atributos da NVAE
      lGeraCab := .F.	
      cLastNCM := WORK->WKNCM
      cLastNVE := WORK->WKNVE
      
      if !empty(WORK->WKNVE)
         MLin+=30
         EIM->(DbSetOrder(3))  //BCO - 20/09/2012 - Posiciona a tabela de NVE.
         //MFR 26/11/2018 OSSME-1483
         //IF !EIM->(DbSeek(xFilial("EIM") + "LI" + AVKEY(Work->WKPGI_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO")))
         //   EIM->(DbSeek(xFilial("EIM") +AvKey("DI","EIM_FASE") + AVKEY(Work->WKPO_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO"))) //LRS - 05/10/2017
         //EndIF
         IF !EIM->(DbSeek(GetFilEIM("LI") + "LI" + AVKEY(Work->WKPGI_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO")))
            EIM->(DbSeek(GetFilEIM("DI") +AvKey("DI","EIM_FASE") + AVKEY(Work->WKPO_NUM,"EIM_HAWB") + AVKEY(Work->WKNVE,"EIM_CODIGO"))) //LRS - 05/10/2017
         EndIF         
         MCOL:=1
         oPrn:Say( MLin  , Ori100xCol(MCOL),"Codigo do Atributo"        , aFontes:COURIER_08) ;MCOL+=35
         oPrn:Say( MLin  , Ori100xCol(MCOL),"Descrição do Atributo"     , aFontes:COURIER_08) ;MCOL+=35 
         oPrn:Say( MLin  , Ori100xCol(MCOL),"Codigo da especificação"   , aFontes:COURIER_08) ;MCOL+=35 
         oPrn:Say( MLin  , Ori100xCol(MCOL),"Descrição da Especificação", aFontes:COURIER_08) ;MCOL+=35

         MCOL:=1
         MLin+=50  
         
         For i := 1 to 4
            oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',35), aFontes:COURIER_08)
            MCOL+=35
         next 
      
      ENDIF 
      
      
      MCOL := 1
      MLin+=25        
      Do while EIM->(!EOF()) .AND. EIM->(EIM_CODIGO) ==  WORK->(WKNVE)
         
         oPrn:Say( MLin, Ori100xCol(MCOL), EIM-> (EIM_ATRIB));MCOL+=35
         oPrn:Say( MLin, Ori100xCol(MCOL), EIM->(EIM_DES_AT));MCOL+=35
         oPrn:Say( MLin, Ori100xCol(MCOL), EIM->(EIM_ESPECI));MCOL+=35
         oPrn:Say( MLin, Ori100xCol(MCOL), EIM->(EIM_DES_ES));MCOL+=35        
         MCOL := 1 
         EIM->(DbSkip())
         MLin+=50 
      END DO
      
   endif 
   
   MLin+=15
   IF cFase = FASE_DI
      oPrn:Say( MLin , Ori100xCol(MCOL),STR0200, aFontes:COURIER_08) //"P.O."
      MCOL+=LEN(SW2->W2_PO_NUM)+1
   ENDIF

   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0201, aFontes:COURIER_08) ;MCOL+=LEN(TRANS(SW3->W3_COD_I,_PictItem))+1 //IF((LEN(SB1->B1_COD)-2)<15,15,LEN(SB1->B1_COD)-2) //"Codigo do Item"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0202, aFontes:COURIER_08) ;MCOL+=20 //"Qtde Comercializada"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0203, aFontes:COURIER_08) ;MCOL+=19 //"        Peso Total"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0204, aFontes:COURIER_08) ;MCOL+=LEN(_PictPrUn)-2 //"    Valor Unitario"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0205, aFontes:COURIER_08) ;MCOL+=19 //"       Valor Total"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0206, aFontes:COURIER_08) ;MCOL+=17 //"Qtde Estatistica"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0207, aFontes:COURIER_08) ;MCOL+=10 //"Anuencia"
   oPrn:Say( MLin  , Ori100xCol(MCOL),STR0208, aFontes:COURIER_08) //"Classificacao"

   MCOL:=1
   MLin+=50

   IF cFase = FASE_DI
      oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',LEN(SW2->W2_PO_NUM)), aFontes:COURIER_08)
      MCOL+=LEN(SW2->W2_PO_NUM)+1
   ENDIF

   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',LEN(TRANS(SW3->W3_COD_I,_PictItem))), aFontes:COURIER_08)
   MCOL+=LEN(TRANS(SW3->W3_COD_I,_PictItem))+1
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',20), aFontes:COURIER_08)
   MCOL+=20
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',19), aFontes:COURIER_08)
   MCOL+=19
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',LEN(_PictPrUn)-2), aFontes:COURIER_08)
   MCOL+=LEN(_PictPrUn)-2
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',18), aFontes:COURIER_08)
   MCOL+=19
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',17), aFontes:COURIER_08)
   MCOL+=17
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',08), aFontes:COURIER_08)
   MCOL+=10
   oPrn:Say( MLin  , Ori100xCol(MCOL),REPL('-',13), aFontes:COURIER_08)
   MLin+=50

ENDIF

RETURN NIL
*-------------------------------------*
Function ORI100InvPrePro()//AWR INVOICES \/ \/ \/ \/ \/ \/ 16/12/2000
*-------------------------------------*
LOCAL lPrimerio := .T., nValParid:=1, nIndSW7
LOCAL nRatFre := nRatDesp :=0  ,cNCM := SPACE(10)
LOCAL cFilSAH:=xFilial("SAH")
LOCAL cFilSA5:=xFilial("SA5")
LOCAL cFilSB1:=xFilial("SB1")
LOCAL cFilSJ5:=xFilial("SJ5")
LOCAL cFilSW2:=xFilial("SW2")
LOCAL cFilSW4:=xFilial("SW4")

LOCAL cFilSW7:=xFilial("SW7")
LOCAL cFilSW8:=xFilial("SW8")//Inv_New - IVH
LOCAL cFilSW9:=xFilial("SW9")//Invoices- IV
LOCAL cFilSWP:=xFilial("SWP")//Capa LI
LOCAL cFilSYD:=xFilial("SYD")
LOCAL cUnidNCM  := "" // JBS - 25/10/2004
LOCAL lAchouSWP := .F.// JBS - 25/10/2004

SAH->(DBSETORDER(1))
SA5->(DBSETORDER(3))
SB1->(DBSETORDER(1))
SJ5->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(6)) //HAWB+INVOICE+PO
SW9->(DBSETORDER(1))
SWP->(DBSETORDER(1))
SYD->(DBSETORDER(1))

SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))
WORK->(avzap())
aMoeda := {}

DO WHILE ! SW8->(EOF()) .AND. SW8->W8_FILIAL == cFilSW8 .AND.;
                              SW8->W8_HAWB   == SW6->W6_HAWB
   //SW9->(DBSEEK(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")))
   If !SW9->(DBSEEK(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB))
      SW8->(dbSkip())
      Loop
   EndIf
         
   If SW6->W6_HAWB == SW9->W9_HAWB 
      nPos := AScan(aMoeda,{|x| x[1] == SW9->W9_MOE_FOB})
      If nPos = 0
         Aadd(aMoeda,{SW9->W9_MOE_FOB,0})
      Endif
   EndIf
   cSw8PO := SW8->W8_PO_NUM
   
   nIndSW7:=SW7->(INDEXORD())
   Do While ! SW8->(Eof()) .AND. SW8->W8_FILIAL == cFilSW8 .AND.;
              SW8->W8_HAWB   == SW6->W6_HAWB .AND. SW8->W8_INVOICE == SW9->W9_INVOICE .AND.;
              SW8->W8_PO_NUM == cSw8PO
           
      nRAtDesp := nRatFre := 0

      SW7->(DBSETORDER(4))
      SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
      
      // Foi mudada esta chave no SW7 porque estava pegando o item errado com o peso errado.
      //SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PGI_NUM+SW8->W8_CC+SW8->W8_SI_NUM+SW8->W8_COD_I))
   
      SW2->(DBSEEK(cFilSW2+SW8->W8_PO_NUM))
      SW4->(DBSEEK(cFilSW4+SW7->W7_PGI_NUM))
      SW3->(PosO1_ItPedidos(SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,SW7->W7_SEQ,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ")))
      SW1->(PosO1_It_Solic(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_REG,0) )
      SB1->(DBSEEK(cFilSB1+SW8->W8_COD_I))
      //SA5->(DBSEEK(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN))
      EICSFabFor(xFilial("SA5")+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))
      cUnidade:=BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR +SW8->W8_FORN,SW8->W8_CC+SW8->W8_SI_NUM, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))
   
      SAH->(DBSEEK(cFilSAH+cUnidade))
      lAchouSWP := SWP->(DBSEEK(cFilSWP+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
      SYD->(DBSEEK(cFILSYD + Busca_NCM("SW7")))
      
      If !Empty(SWP->WP_UNID).and. lAchouSWP  // JBS - 25/10/2004
         cUnidNCM := SWP->WP_UNID
      Else
         cUnidNCM := SYD->YD_UNID
      EndIf   
      
      IF cUnidade # cUnidNCM                                           // JBS - 25/10/2004 // SWP->WP_UNID
         IF AvVldUn(cUnidNCM) // MPG - 06/02/2018
            cTx_Conv:=nPesoItem
         ELSE          
            cChavSJ5 := cFilSJ5                                        // JBS - 25/10/2004
            cChavSJ5 += cUnidade+space(len(SJ5->J5_DE)-len(cUnidade))  // JBS - 25/10/2004
            cChavSJ5 += cUnidNCM+space(len(SJ5->J5_PARA)-len(cUnidNCM))// JBS - 25/10/2004
            SJ5->(DBSEEK(cChavSJ5+SW8->W8_COD_I))                       // JBS - 25/10/2004
            cTx_Conv := SJ5->J5_COEF
         ENDIF
      ELSE
         cTx_Conv := 1
      ENDIF
      IF ! EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2","W2_EXPLOJ") //TDF - 26/11/12 - Verifica loja do exportador
         nValParid:=SW2->W2_PARID_U
      ELSE
         nValParid:=1
      ENDIF
      nPesoItem := W5Peso() //SB1->B1_PESO FCD 04/07/01
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOIT_W3"),)

      nRatDesp   := DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T.) // EOB - 14/07/08 
      cValor_Tot := SW8->(W8_QTDE*W8_PRECO) + nRatDesp

      IF nRatDesp #0
        cValor_Uni := cValor_Tot / SW8->W8_QTDE
      ELSE
        cValoR_Uni := SW8->W8_PRECO
      ENDIF
      cValor_Tot := ROUND(cValor_Tot,AVSX3("W6_FOB_TOT",4))

      Work->(DBAPPEND())
      Work->WKNCM      := SYD->YD_TEC
      Work->WKEX_NCM   := SYD->YD_EX_NCM
      Work->WKEX_NBM   := SYD->YD_EX_NBM
      Work->WKQUAL_NCM := SYD->YD_EX_NCM
      Work->WKQUALIF   := SYD->YD_EX_NBM
      Work->WKFABR     := SW8->W8_FABR
      Work->WKDESTAQ   := SYD->YD_DESTAQU
      Work->WKREGIST   := SWP->WP_REGIST
      Work->WKPO_NUM   := SW8->W8_PO_NUM
      Work->WKPGI_NUM  := SW8->W8_PGI_NUM
      Work->WKCOD_I    := SW8->W8_COD_I
      Work->WKUNID     := cUnidade
      Work->WKQTDE     := SW8->W8_QTDE
      Work->WKPRECO    := Round(cValor_Uni * nValParid,AVSX3("W8_PRECO",4))
      Work->WKPRECO_T  := Round(cValor_Tot * nValParid,AVSX3("W6_FOB_TOT",4))
      Work->WKQTE_ES   := SW8->W8_QTDE * cTx_Conv
      Work->WKANUENCIA := IF(SW8->W8_FLUXO=='7',STR0193,STR0194) //'Nao'###'Sim'
      ///Work->WKPART_N   := SA5->A5_CODPRF 
      Work->WKCLASS    := SW1->W1_CLASS
      Work->WKPESO_T   := SW8->W8_QTDE * nPesoItem  //SB1->B1_PESO
      Work->WKMOEDA    := SW9->W9_MOE_FOB
      Work->WKINVOICE  := SW9->W9_INVOICE
      Work->WKFORN	    := SW9->W9_FORN // FMB 07/06/04 - inclusão desta linha	
      Work->WKHAWB     := SW9->W9_HAWB
      Work->WKCOND     := SW9->W9_COND_PA
      Work->WKDIAS     := STR(SW9->W9_DIAS_PA,3,0)
      nTot_Pes         += Work->WKPESO_T
      nTot_Vlr         += Work->WKPRECO_T
      lPrimerio        := .F.
      if lNVE .AND. lPrintNVE .AND. cFase == FASE_DI // BCO - Recebe o valor no campo apenas se o mesmo existir.
         Work->WKNVE   := SW8->W8_NVE
      endif
   
      If EICLoja()
         Work->WKFABLOJ := SW8->W8_FABLOJ
         Work->WKFORLOJ := SW9->W9_FORLOJ
      EndIf
                                         
      If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007        
         SW3->(DbSetOrder(8))
         SW3->(DbSeek(xFilial("SW3") + SW8->W8_PO_NUM + SW8->W8_POSICAO)) 
         If !Empty(SW3->W3_PART_N)
            Work->WKPART_N :=  SW3->W3_PART_N  
         Else                                                     
            Work->WKPART_N := SA5->A5_CODPRF  
         EndIf   
      Else 
         Work->WKPART_N := SA5->A5_CODPRF
      EndIf

      nPos := AScan(aMoeda,{|x| x[1] == Work->WKMOEDA})
      If nPos > 0
         aMoeda[nPos][2] += Work->WKPRECO_T
      Endif   
      IF(EasyEntryPoint("EICOR150"),ExecBlock("EICOR150",.F.,.F.,"GRV_WORK_INV"),)
      SW8->(DBSKIP())
      
   Enddo
   SW7->(DBSETORDER(nIndSW7))
ENDDO

RETURN .T.//AWR INVOICES /\ /\ /\ /\ /\ /\ 16/12/2000  


//------------------------------------------------------------------------------------//
//                          FIM DO PROGRAMA EICOR150.PRW
//------------------------------------------------------------------------------------//

