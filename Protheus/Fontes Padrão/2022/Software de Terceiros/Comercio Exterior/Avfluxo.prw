#INCLUDE "EicFi400.ch"  
#INCLUDE "Average.ch"
//Funcao    : AVFLUXO()
//Autor     : SIDNEY MONTEIRO
//Data      : 21 Nov 2000
//Descricao : Ponto de entrada Antes e Depois das gravacoes do PO e da DI
//Cliente   : "Los Hermanos"

#DEFINE DESP_FRETE   '102'
#DEFINE DESP_SEGURO  '103'
#DEFINE ENTER CHR(13)+CHR(10) 

*-------------------------------------------*
FUNCTION AVPOS_PO(cPO_Num,cFase)
*-------------------------------------------*
LOCAL aDespesas:={},nAlias:=SELECT(), aDtEntr := {}   // GFP - 26/03/2013
LOCAL nInd := SW2->(INDEXORD()),    nOrdSW3:=(SW3->(INDEXORD())), nOrdSWI:=(SWI->(INDEXORD())),;
      nOrdSY5:= SY5->(INDEXORD()),  nOrdSB1:= SB1->(INDEXORD()),;
      nOrdSWD:= SWD->(INDEXORD()),  nOrdSYW:=SYW->(INDEXORD()) ,  nOrdSY4:=SY4->(INDEXORD())      
LOCAL cFornecMV:=PADR(EasyGParam("MV_FORDESP"),LEN(SA2->A2_COD))
LOCAL cLojaFMV :=PADR(EasyGParam("MV_LOJDESP"),LEN(SA2->A2_LOJA))
LOCAL cMoeda1:=EasyGParam("MV_SIMB1")
LOCAL cMoeda2:=EasyGParam("MV_SIMB2")
LOCAL cFornFret:= "", cLojaFret:= "", nDesp
Local cMsgAgente:= ""
Local cMsgDespach:= "" 
Local cMsgValid:= ""
Local lIntEAI:= AvFlags("EIC_EAI")
Local lEventFin:= .T.
Local lMoedaWF := If( (EasyGParam("MV_EASYFPO",,"N") == "S" .Or. EasyGParam("MV_EASYFDI",,"N") == "S") .And. SWF->(FieldPos("WF_IDMOEDA")) > 0 ,.T.,.F.)//LGS-28/07/2016
Local loIntPr:= .F.
Local cFilSWI := XFILIAL("SWI")//RMD - 21/03/19 - Para evitar chamada em loop
Local cFilSWH := XFILIAL("SWH")//RMD - 21/03/19 - Para evitar chamada em loop
Local cFilSW3 := XFILIAL("SW3")//RMD - 21/03/19 - Para evitar chamada em loop
//RMD - 21/03/19 - Buffer para os dados do SW3, Despesas e SW5
Local oBufferSW3 := tHashMap():New(), nBufRecSW3
Local oBufferDesp := tHashMap():New(), aBufDesp
Local oVlrGI := tHashMap():New(), aBufVlrGI
Local cTMPSWH := GetNextAlias()
Local cQuery
Local lGera
PRIVATE nSld_Gi:= 0,nQtd_Gi:= 0,TPO_NUM:= cPO_Num,lSair:=.F.
//TRP - 09/03/2010 - Variável utilizada em rdmake
PRIVATE nValorRdm := 0
PRIVATE cDespRdm  := ""
Private cUltParc := ""  // GFP - 20/01/2014

SW2->(DBSETORDER(1))
IF !SW2->(DBSEEK(xFilial("SW2")+cPO_Num))
   SW2->(DBSETORDER(nInd))
   RETURN .F.
ENDIF
SWD->(DBSETORDER(1))
SYW->(DBSETORDER(1))
SY4->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SY6->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SWI->(DBSETORDER(2))
SW5->(DBSETORDER(3)) // GFP - 26/03/2013
SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN))       
SWF->(DBSEEK(xFilial("SWF")+SW2->W2_TAB_PC))

If !SWI->(DBSEEK(cFilSWI/*RMD - 21/03/19 xFilial("SWI")*/+SW2->W2_TIPO_EM+SW2->W2_TAB_PC)) // // RRV - 10/08/2012 / Procura a tabela de pré-calculo com via de transporte referente ao PO, se existirem mais de uma com o mesmo código corretamente.
   SWI->(DBSETORDER(1))
   SWI->(DBSEEK(cFilSWI/*RMD - 21/03/19 xFilial("SWI")*/+SW2->W2_TAB_PC))
EndIf   

//Tabela de pré-cálculo vinculada ao P.O.
cTabPC:=SW2->W2_TAB_PC

//Código do agente de transporte/ embarcador
If SY4->(DBSEEK(XFILIAL("SY4")+SW2->W2_AGENTE))
   cFornFret:=SY4->Y4_FORN
   cLojaFret:=SY4->Y4_LOJA   
EndIf

If Empty(cFornFret)
	cMsgAgente:= StrTran(STR0151, "XXXX", AllTrim(SW2->W2_AGENTE)) + ENTER //"O fornecedor do Agente de Transporte não foi infomado. Atualize o cadastro XXXX."
EndIf

//Código do despachante
If !Empty(SW2->W2_DESP)
   IF SY5->(DBSEEK(XFILIAL("SY5")+ SW2->W2_DESP )) .AND. !EMPTY(SY5->Y5_FORNECE)
      cFornecMV:= SY5->Y5_FORNECE 
      cLojaFMV := SY5->Y5_LOJAF   
   ENDIF
   If Empty(cFornecMV)
      cMsgDespach:= StrTran(STR0152, "XXXX", AllTrim(SW2->W2_DESP)) + ENTER //"O fornecedor do Despachante não foi infomado. Atualize o cadastro XXXX."
   EndIf
Else
   cMsgDespach:= STR0153 //"O campo Despachante não está preechido. Preencha o campo Despachante na pasta Cadastrais do Purchase Order."
EndIf                       


//Cadastro de contas (evento contábil) configurado
If lIntEAI
   EC6->(DBSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   If EC6->(DBSeek(xFilial() + AvKey("IMPORT", "EC6_TPMODU") + AvKey("150", "EC6_ID_CAM")))
      If Empty(EC6->EC6_NATFIN)
         cMsgValid += StrTran(STR0154, "####", AvSx3("EC6_NATFIN", AV_TITULO)) + ENTER //"O tipo de despesa do ERP para a geração do título no financeiro não foi informado. Acesse o cadastro de Eventos Contábeis e atualize o evento contábil IMPORT-150 (despesas provisórias), campo '####'."
         lEventFin:= .F.
      EndIf
   Else
      cMsgValid += STR0155 + ENTER //"O evento contábil IMPORT-150 (despesas provisórias) não foi encontrado. Verifique o cadastro de Eventos Contábeis."
      lEventFin:= .F.
   EndIf
EndIf

//Atualização das tabelas do sigaeic
SW3->(DBSETORDER(7))
ProcRegua(3)

EICTP25A({cPO_Num,cTabPC,cFase})

// GFP - 26/03/2013
aDtEntr := {}
If cFase == "DI"
   SW5->(DbSetFilter({|| SW5->W5_SEQ == 0 .And. SW5->W5_SALDO_Q > 0}, "SW5->W5_SEQ == 0 .And. SW5->W5_SALDO_Q > 0")) //wfs - out/2019: ajustes de performance
   SW5->(DbSeek(xFilial("SW5")+cPO_Num))
   Do While SW5->(!Eof()) .AND. SW5->W5_FILIAL == xFilial("SW5") .AND. SW5->W5_PO_NUM == cPO_Num
      If SW5->W5_SEQ == 0 .AND. SW5->W5_SALDO_Q > 0   
         aAdd(aDtEntr, SW5->W5_DT_ENTR)
      EndIf
      SW5->(DbSkip())
   EndDo
   SW5->(DbClearFilter())
   aSort(aDtEntr,,,{|x,y| x < y} )
EndIf

IF(EasyEntryPoint("AVFLUXO"),Execblock("AVFLUXO",.F.,.F.,"APOS_EICTP25A"),)
If lSair 
   RETURN
ENDIF   

//RMD - 21/03/19 - Retirado do loop para melhorar a performance
If cMoeda2 <> "US$" .And. cMoeda2 <> "USD" //TDF - 15/08/12 - Caso a moeda 2 não seja dólar, deve usar a taxa do dólar para conversão, pois o pré-cálculo grava a tabela SWH em dólar.
   nTaxa:=BuscaTaxa("US$"  ,dDataBase,.T.,.F.,.T.)  
Else   
   nTaxa:=BuscaTaxa(cMoeda2,dDataBase,.T.,.F.,.T.)
EndIf

aDespesas:={}                 
SW3->(DBSETORDER(7))
SWH->(DBSETORDER(1))
SWH->(DBSEEK(cFilSWH/*RMD - 21/03/19 - XFILIAL("SWH")*/+cPO_Num))

cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSQLName("SWH") + " "
cQuery += " WHERE WH_FILIAL = '" + cFilSWH + "' "
cQuery += "   AND WH_PO_NUM = '" + cPO_Num + "'
cQuery += "   AND D_E_L_E_T_= ' ' "
cQuery += " ORDER BY WH_FILIAL, WH_PO_NUM, WH_NR_CONT, WH_DESPESA "

EasyWkQuery(cQuery,cTMPSWH,,{{"RECNO","N",10,0}})


DO WHILE  !(cTMPSWH)->(EOF())
   SWH->(dbGoTo((cTMPSWH)->RECNO))
   // Verifica Despesa
   IF (SWH->WH_DESPESA$'101' .OR. (SWH->WH_DESPESA$'102'.AND.  AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE")) .OR. (SWH->WH_DESPESA$'103'.AND.  AvRetInco(SW2->W2_INCOTER,"CONTEM_SEGURO") )) .Or.;
      (!EMPTY(SW2->W2_HAWB_DA) .AND. SWH->WH_DESPESA $ '102,103')
      (cTMPSWH)->(DBSKIP())
      LOOP
   ENDIF                                                                       

   // Verifica Saldo em Quantidade
   //SW3->(DBSEEk(XFILIAL("SW3")+SWH->WH_PO_NUM+STR(0,2)+STR(SWH->WH_NR_CONT,4))) //3)))  GFP - 11/10/2011

   nBufRecSW3 := 0
   //RMD - 21/03/19 - Efetua a busca pelo registro no SW3 e cria um buffer para reaproveitar a informação
   If oBufferSW3:Get(cFilSW3+SWH->WH_PO_NUM+STR(0,2)+STR(SWH->WH_NR_CONT,4), @nBufRecSW3)
      If SW3->(Recno()) <> nBufRecSW3
         SW3->(DbgoTo(nBufRecSW3))
      EndIf
   Else
      SW3->(DbSeek(cFilSW3/*RMD - 21/03/19 - XFILIAL("SW3")*/+SWH->WH_PO_NUM+STR(0,2)+STR(SWH->WH_NR_CONT,4)))
      oBufferSW3:Set(cFilSW3+SWH->WH_PO_NUM+STR(0,2)+STR(SWH->WH_NR_CONT,4), SW3->(Recno()))
   EndIf
      
   nSld_Gi:= 0
   nQtd_Gi:= 0
   TPO_NUM:= cPO_Num
   //Po420_IgPos("3")
   //RMD - 21/03/19 - Efetua a busca pelos saldos do SW5 e cria um buffer para reaproveitar a informação
   aBufVlrGI := {}
   If oVlrGI:Get(SW3->(Recno()), @aBufVlrGI)
      nSld_GI := aBufVlrGI[1]
      nQtd_GI  := aBufVlrGI[2]
   Else
      Po420_IgPos("3",,,.F.)//RMD - 03/04/19 - Indica que a função não precisa posicionar o SW5, somente calcular os totais do item
      oVlrGI:Set(SW3->(Recno()), {nSld_GI, nQtd_Gi})
   EndIf

   IF SW3->W3_FLUXO == "7"
      nQtde := nSld_Gi
   ELSE
      nQtde := SW3->W3_SALDO_Q + nSld_Gi 
   ENDIF

   IIF(nQtde <= 0,lGera:=.F.,lGera:=.T.)
   
   If lGera
      // Posiciona Tabela de Pre-Calculo  
      /*
      If !(SWI->(DbSeek(XFILIAL("SWI")+SW2->W2_TIPO_EM+SW2->W2_TAB_PC+SWH->WH_DESPESA ))) // RRV - 10/08/2012 / Procura a tabela de pré-calculo com via de transporte referente ao PO, se existirem mais de uma com o mesmo código corretamente.
         SWI->(DBSETORDER(1))
         SWI->(DbSeek(XFILIAL("SWI")+SW2->W2_TAB_PC+SWH->WH_DESPESA))
      EndIf   
      SYB->(DbSeek(XFILIAL("SYB")+SWH->WH_DESPESA ))
      */

      //RMD - 21/03/19 - Efetua a busca pela despesa na tabela de pré-calculo e cria um buffer para reaproveitar a informação
      aBufDesp := {}
      If oBufferDesp:Get(cFilSWI+SW2->W2_TIPO_EM+SW2->W2_TAB_PC+SWH->WH_DESPESA, @aBufDesp)
         If SWI->(Recno()) <> aBufDesp[1]
            SWI->(DbGoTo(aBufDesp[1]))
         EndIf
         If SYB->(Recno()) <> aBufDesp[2]
            SYB->(DbGoTo(aBufDesp[2]))
         EndIf
      Else
         If !(SWI->(DbSeek(cFilSWI+SW2->W2_TIPO_EM+SW2->W2_TAB_PC+SWH->WH_DESPESA ))) // RRV - 10/08/2012 / Procura a tabela de pré-calculo com via de transporte referente ao PO, se existirem mais de uma com o mesmo código corretamente.
            SWI->(DBSETORDER(1))
            SWI->(DbSeek(cFilSWI+SW2->W2_TAB_PC+SWH->WH_DESPESA))
         EndIf   
         SYB->(DbSeek(XFILIAL("SYB")+SWH->WH_DESPESA ))
         oBufferDesp:Set(cFilSWI+SW2->W2_TIPO_EM+SW2->W2_TAB_PC+SWH->WH_DESPESA, {SWI->(Recno()), SYB->(Recno())})
      EndIf

      /* RMD - 21/03/19 - Movido para fora do loop
      //FDR - 09/09/13 - Tratamento para moeda USD   
      If cMoeda2 <> "US$" .And. cMoeda2 <> "USD" //TDF - 15/08/12 - Caso a moeda 2 não seja dólar, deve usar a taxa do dólar para conversão, pois o pré-cálculo grava a tabela SWH em dólar.
         nTaxa:=BuscaTaxa("US$"  ,dDataBase,.T.,.F.,.T.)  
      Else   
         nTaxa:=BuscaTaxa(cMoeda2,dDataBase,.T.,.F.,.T.)
      EndIf
      */
      
      If lMoedaWF .And. SWF->WF_IDMOEDA $ '2' //LGS-28/07/2016
         cMoeda1 := SWI->WI_MOEDA
         nTaxa   := nTaxa:=BuscaTaxa(cMoeda1,dDataBase,.T.,.F.,.T.)
         nValPg  := SWH->WH_VALOR_R/nTaxa
      Else
         nTaxa:=IF(nTaxa=0,1,nTaxa)
         nValPg:=SWH->WH_VALOR*nTaxa   
      EndIf          

      nAsc:=ASCAN(aDespesas, {|cAsc| cAsc[1]==SWH->WH_DESPESA } )
         
      IF nAsc == 0
         AADD(aDespesas,{SWH->WH_DESPESA,cMoeda1,SWH->WH_PER_DES,nValPg,If(cFase == "DI" .AND. Len(aDtEntr) > 0,aDtEntr[1],SW3->W3_DT_ENTR)+SWI->WI_QTDDIAS,SYB->YB_DESCR,SWH->WH_DESC  })   // GFP - 26/03/2013
      ELSE
      // If(cFase == "PO", aDespesas[nAsc,4] += nValPg, )                             // GFP - 26/03/2013
      // If(cFase == "PO", aDespesas[nAsc,5] := SW3->W3_DT_ENTR+SWI->WI_QTDDIAS, )    // GFP - 26/03/2013
         
         //LRS - 13/01/2017
         aDespesas[nAsc,4] += nValPg  
         aDespesas[nAsc,5] := SW3->W3_DT_ENTR+SWI->WI_QTDDIAS
      ENDIF
   EndIf

   (cTMPSWH)->(DBSKIP())
      
ENDDO
(cTMPSWH)->(dbCloseArea())

SY5->(DBSETORDER(1))
cNum :=  Replicate("0",TamSX3("E2_NUM")[1]- Len(SW2->W2_PO_SIGA)) + SW2->W2_PO_SIGA

loIntPr:= Type("oIntPr") == "O"    
IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
   nDup:=0
   xRecSA2:=SA2->(recno())
	For nDesp:=1 to Len(aDespesas)
	   
		  cDescFB  :=' '
		  IF cPaisLoc # "BRA"         
			 SFB->(DBSEEK(XFILIAL("SFB")+aDespesas[nDesp,7]))
			 IF !SFB->(EOF()) .AND. !EMPTY(aDespesas[nDesp,7])
				cFornec:=SFB->FB_FORNECE 
				cLojaF :=SFB->FB_LOJA
				cDescFB:=SFB->FB_DESCR
			 ENDIF
		  ENDIF   

		  IF aDespesas[nDesp,1] == DESP_FRETE
			 //Dados do agente de transporte
			 cFornec:=cFornFret
			 cLojaF :=cLojaFret
			 
			 cMsgValid += cMsgAgente
		  Else
			 //Dados do despachante
			 cFornec:=cFornecMV
			 cLojaF :=cLojaFMV
			 
			 cMsgValid += cMsgDespach
			 cMsgDespach:= ""
		  ENDIF
			 
		  If Empty(cFornec)
			 Loop
		  EndIf

		  //Se está habilitada a integração via mensagem única e o evento contábil não existe ou não está configurado
		  If lIntEai .And. !lEventFin
			 Exit
		  EndIf
		  
         IF nDesp == 1 .or. XFILIAL("SA2")+cFornec+cLojaF != SA2->A2_FILIAL+SA2->A2_COD+SA2->A2_LOJA
            SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF))
         endif
		  nErroDup:=1
			   
		  IF !SA2->(EOF()) .and.   aDespesas[nDesp,4] > 0 .AND. EasyGeraProv("PR",aDespesas[nDesp,1])
			 nValorRdm := aDespesas[nDesp,4]
			 cDespRdm  := aDespesas[nDesp,1]

			 IF(EasyEntryPoint("AVFLUXO"),Execblock("AVFLUXO",.F.,.F.,"VALOR_TIT_PR"),)
			 nDup+=1
			 If (AvFlags("AVINT_PR_EIC") .OR. cFase == "DI" .AND.  AvFlags("AVINT_PRE_EIC"))  .AND. loIntPr //AOM - 23/04/2012 - Considerar os titulos PRE gerados no embarque e adicionar o HAWB no PR quando os titulos só forem gerados no embarque
				oIntPr:GeraProv(aDespesas[nDesp,4]  ,;   //Valor da duplicata
						   dDataBase,;              //data de emissao
						   IIF(dDataBase>aDespesas[nDesp][5],dDataBase,aDespesas[nDesp][5]) ,;  //Data de vencimento
						   aDespesas[nDesp,2],;     //Simbolo da moeda
						   "PR",;                   //Tipo do titulo
						   1,;                      //Numero de parcela.
						   cFornec,;                //Fornecedor
						   cLojaF,;                 //Loja
						   "",;                
						   "",;                     //Processo
						   SW2->W2_PO_NUM,;         //Pedido
						   aDespesas[nDesp][1],;    //Despesa
						   "")                      //Invoice
			 Else
				nErroDup:=GeraDupEic(SW2->W2_PO_SIGA,;     //Numero das duplicatas
						aDespesas[nDesp,4]  ,;   //Valor da duplicata
						dDataBase,;              //data de emissao
						IIF(dDataBase>aDespesas[nDesp][5],dDataBase,aDespesas[nDesp][5]) ,;  // PLB 19/09/07  //aDespesas[nDesp,5],;     //Data de vencimento
						aDespesas[nDesp,2],;     //Simbolo da moeda
						"EIC",;                  //Prefixo do titulo
						"PR" ,;                  //Tipo do titulo
						nDup,;                   //Numero de parcela.
						cFornec,;                //Fornecedor
						cLojaF,;                 //Loja
						"SIGAEIC",;              //Origem da geracao da duplicata (Nome da rotina)
						"Ped.: "+ALLTRIM(SW2->W2_PO_NUM)+' '+ ;
								 IF(EMPTY(aDespesas[nDesp,7]),aDespesas[nDesp,6],;//Historico da geracao
																	  cDescFB),;
						0,,,SW2->W2_PO_NUM)
			 EndIf
		  ENDIF
	Next nDesp
   SA2->(DBGOTO(xRecSA2))
EndIF   
IncProc()

SW3->(DBSETORDER(nOrdSW3))
SWI->(DBSETORDER(nOrdSWI))
SY5->(DBSETORDER(nOrdSY5))
SB1->(DBSETORDER(nOrdSB1))
SWD->(DBSETORDER(nOrdSWD))
SYW->(DBSETORDER(nOrdSYW))
SY4->(DBSETORDER(nOrdSY4))

SELECT(nAlias)
SW2->(DBSETORDER(nInd))


If !Empty(cMsgValid)
	cMsgValid:= STR0156 + ENTER + ENTER + cMsgValid //"Algumas despesas não puderam ser integradas ao Financeiro. Verifique as informações abaixo:"
	MsgAlert(cMsgValid, STR0004) // mensagens, Atenção 
EndIf

Return NIL


*------------------------------------------------------------------------------------------------------------------*
FUNCTION AVPOS_DI(cHawb,lFazPrDesp,lFretSeg,lAltFrete,lAltSeguro)  // EOS - 15/04/04 - inclusao do 3º par. que indica se passará pelas rotinas de geracao de frete e seguro no financeiro
*------------------------------------------------------------------------------------------------------------------*
LOCAL aDespesas:={}, nAlias:=SELECT()
LOCAL nInd := SW6->(INDEXORD()),    nOrdSW3:=SW3->(INDEXORD()), nOrdSWI:=SWI->(INDEXORD()),;
      nOrdSY5:= SY5->(INDEXORD()),  nOrdSB1:=SB1->(INDEXORD()), nOrdSW7:=SW7->(INDEXORD()),;
      nOrdSWD:= SWD->(INDEXORD()),  nOrdSYW:=SYW->(INDEXORD()), nOrdSY4:=SY4->(INDEXORD()),; 
      nOrdSWF:= SWF->(INDEXORD())
LOCAL cFornecMV:=PADR(EasyGParam("MV_FORDESP"),LEN(SA2->A2_COD))
LOCAL cLojaFMV :=PADR(EasyGParam("MV_LOJDESP"),LEN(SA2->A2_LOJA))
LOCAL cMoeda1:=EasyGParam("MV_SIMB1"), nDesp
LOCAL cMoeda2:=EasyGParam("MV_SIMB2")
LOCAL cTipoPar  := "PR"
LOCAL lTem901   := .f. //  Jonato, OS 1174/03 da ocorrência 0111/03
LOCAL ntamDesp  := AVSX3("WD_DESPESA",3)
Local nQtdDias := 0  // PLB 19/09/07
Local dDtVencto := CToD("  /  /  ")  // PLB 19/09/07
Local nLeadTDesem,nLeadTTran
Local aDIsNasc
Local i
Local n := 0 //RRV - 22/02/2013
Local cMsgInfo := "", cMsgYesNo := "", nValFret := 0, nValSeg := 0
Local cPict    := "@E 999,999,999.99" //LGS-01/12/2015
Local lMoedaWF := If( (EasyGParam("MV_EASYFPO",,"N") == "S" .Or. EasyGParam("MV_EASYFDI",,"N") == "S") .And. SWF->(FieldPos("WF_IDMOEDA")) > 0 ,.T.,.F.) //LGS-28/07/2016
Local nValPgWH := 0 //LGS-01/08/2016
Local cIndice  := ""//LGS-03/08/2016
Local lTem102 := lTem103 := .F.
Local lSiscoserv := EasyGParam("MV_ESS0022",,.T.) //THTS - 14/11/2017 - Habilita integracao SIGAEIC x SIGAESS
Local loIntPr:= .F.
//TRP - 09/03/2010 - Variável utilizada em rdmake
PRIVATE nValorRdm := 0
PRIVATE cDespRdm  := ""

Private cUltParc := ""  // GFP - 20/01/2014

DEFAULT lAltFrete  := If(!IsInCallStack("EICNU400"),.T.,.F.)  // GFP - 06/11/2013 - Sistema não deve gerar titulos de Frete quando a chamada for pelo Numerario
DEFAULT lAltSeguro := If(!IsInCallStack("EICNU400"),.T.,.F.)  // GFP - 06/11/2013 - Sistema não deve gerar titulos de Seguro quando a chamada for pelo Numerario

lFretSeg := IF(lFretSeg==NIL,.F.,lFretSeg)

SW6->(DBSETORDER(1))
IF !SW6->(DBSEEK(xFilial("SW6")+cHawb))
   SW6->(DBSETORDER(nInd))
   RETURN NIL
ENDIF

IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"//AVGERAL.PRW
   SW6->(RECLOCK("SW6",.F.))
   SW6->W6_NUMDUP:=AvgNumSeq("SW6","W6_NUMDUP")
   SW6->(MSUNLOCK())
ELSE
   IF EMPTY(SW6->W6_NUMDUP)  //  Jonato, OS 1174/03 da ocorrência 0111/03
      SW6->(RECLOCK("SW6",.F.))
      If EasyGParam("MV_EICNUMT",,"1") == "2"
         SW6->W6_NUMDUP:=GetSXENum("SE2","E2_NUM")
      Else
         SW6->W6_NUMDUP:=GetSXENum("SW6","W6_NUMDUP")
      EndIf
      SW6->(MSUNLOCK())
   ENDIF
   ConfirmSX8()
ENDIF  

M->W6_NUMDUP:= SW6->W6_NUMDUP // TDF - 16/07/12 - ATUALIZA A VARIAVEL DE MEMÓRIA

// EOS - 03/06/04 - Foi movida a chamada da rotina que gera os titulos de frete e seguro antes de testar a data de 
// encerramento do processo, pois se estiver encerrado deve-se ignorar somente a geracao dos titulos provisorios
IF lFretSeg  // EOS - 15/04/04
   // Despesas de Frete e Seguro
   IF lAltFrete
      //LGS-26/11/2015
      If EIC->(DbSeek(xFilial("EIC") + M->W6_HAWB + AvKey(DESP_FRETE,"EIC_DESPES") ))//EIC_FILIAL+EIC_HAWB+EIC_DESPES
         If !Empty(EIC->EIC_DT_EFE) .And. SWD->(DbSeek(xFilial("SWD") + EIC->EIC_HAWB + EIC->EIC_DESPES + DTOS(EIC->EIC_DT_EFE)))
            If (AvFlags("GERACAO_CAMBIO_FRETE") .Or. !Empty(M->W6_VENCFRE)) .and. !Empty(M->W6_VLFRECC) //LRS - 11/07/2017
                IF EMPTY(SWD->WD_CTRFIN1) //LRS - 11/07/2017
                   If EasyGParam("MV_EASYFIN",,"N") == "S"
                           cMsgYesNo += StrTran( StrTran(STR0159,"XXX",DESP_FRETE + " - " + AllTrim(Posicione("SYB",1,XFILIAL("SYB")+AvKey(DESP_FRETE,"YB_DESP"),"YB_DESCR"))),"YYYY", AllTrim( cValToChar( Transform(SWD->WD_VALOR_R,cPict) ) ) ) + ENTER
                           nValFret := M->W6_VLFRECC * M->W6_TX_FRET
                   Else
                           cMsgInfo += StrTran( StrTran(STR0159,"XXX",DESP_FRETE),"YYYY", AllTrim( cValToChar( Transform(SWD->WD_VALOR_R,cPict) ) ) ) + ENTER
                   EndIf
                n++
                Else
                    cMsgInfo += StrTran(STR0164,"XXX",DESP_FRETE) + ENTER + ENTER //Foi identificado que para a despesa XXX existe título gerado pela rotina de prestação de contas.
                    lTem102 := .T.
                EndIf
            EndIF
         Else
            /*******
            A despesa existe no numerario, porem nao foi efetivada, dessa forma não existe na SWD ainda
            ********************************************************************************************/
            AVINCFRETESEG(DESP_FRETE)
         EndIf
      Else
         AVINCFRETESEG(DESP_FRETE)
      EndIf
   ENDIF
   
   IF lAltSeguro
      //LGS-26/11/2015
      If EIC->(DbSeek(xFilial("EIC") + M->W6_HAWB + AvKey(DESP_SEGURO,"EIC_DESPES") ))//EIC_FILIAL+EIC_HAWB+EIC_DESPES
         If !Empty(EIC->EIC_DT_EFE) .And. SWD->(DbSeek(xFilial("SWD") + EIC->EIC_HAWB + EIC->EIC_DESPES + DTOS(EIC->EIC_DT_EFE)))//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)
            If (AvFlags("GERACAO_CAMBIO_SEGURO") .Or. !Empty(M->W6_VENCSEG)) .AND. !EMPTY(M->W6_VL_USSE) //LRS - 11/07/2017
               IF EMPTY(SWD->WD_CTRFIN1) //LRS - 11/07/2017
                  If EasyGParam("MV_EASYFIN",,"N") == "S"
                          cMsgYesNo += StrTran( StrTran(STR0159,"XXX",DESP_SEGURO + " - " + AllTrim(Posicione("SYB",1,XFILIAL("SYB")+AvKey(DESP_SEGURO,"YB_DESP"),"YB_DESCR"))),"YYYY", AllTrim( cValToChar( Transform(SWD->WD_VALOR_R,cPict) ) ) ) + ENTER
                          nValSeg := M->W6_VL_USSE * M->W6_TX_SEG
                  Else
                          cMsgInfo += StrTran( StrTran(STR0159,"XXX",DESP_SEGURO),"YYYY", AllTrim(cValToChar( Transform(SWD->WD_VALOR_R,cPict) ) ) ) + ENTER
                  EndIf
               n++
               Else
                  cMsgInfo += StrTran(STR0164,"XXX",DESP_SEGURO) + ENTER + ENTER //Foi identificado que para a despesa XXX existe título gerado pela rotina de prestação de contas.
                  lTem103 := .T.
               EndIF
            EndIf
         Else
            /*******
            A despesa existe no numerario, porem nao foi efetivada, dessa forma não existe na SWD ainda
            ********************************************************************************************/
            AVINCFRETESEG(DESP_SEGURO)
         EndIf
      Else
         AVINCFRETESEG(DESP_SEGURO)
      EndIf
   ENDIF
   //LRS - 12/07/2017
   If lTem102 .Or. lTem103
      cMsgInfo += (STR0165) //"Para atualizar o(s) valor(es) da(s) despesa(s) realize a alteração pela rotina de Despesas ou realize a inclusão de uma despesa adicional, com a diferença de valores."
   EndIF

   //LGS-26/11/2015
   If !Empty(cMsgYesNo) 
      If MsgYesNo(cMsgYesNo + ENTER + STR0162 + ENTER + STR0163)  //"Deseja atualizar o valor da(s) despesa(s)?"  ##  "O(s) título(s) no Financeiro será(ão) gerado(s) após a Prestação de Contas."
         If SWD->(DbSeek(xFilial("SWD") + M->W6_HAWB + AvKey(DESP_FRETE,"WD_DESPESA"))) .AND. nValFret > 0 //LRS - 11/07/2017
            SWD->(RecLock("SWD",.F.))
            SWD->WD_VALOR_R := nValFret
            //THTS - 14/11/2017 - MTRADE-1688 - Grava os valores referente ao Siscoserv - Frete
            If lSiscoserv
                SWD->WD_MOEDA   := M->W6_FREMOED
                SWD->WD_VL_MOE  := M->W6_VLFRECC
                SWD->WD_TX_MOE  := M->W6_TX_FRET
            EndIf
            SWD->(MsUnlock())
         EndIf
         If SWD->(DbSeek(xFilial("SWD") + M->W6_HAWB + AvKey(DESP_SEGURO,"WD_DESPESA"))) .AND. nValSeg > 0 //LRS - 11/07/2017
            SWD->(RecLock("SWD",.F.))
            SWD->WD_VALOR_R := nValSeg
            //THTS - 14/11/2017 - MTRADE-1688 - Grava os valores referente ao Siscoserv - Seguro
            If lSiscoserv
                SWD->WD_MOEDA   := M->W6_SEGMOED
                SWD->WD_VL_MOE  := M->W6_VL_USSE
                SWD->WD_TX_MOE  := M->W6_TX_SEG
            EndIf
            SWD->(MsUnlock())
         EndIf
      EndIf
      n := 0
   EndIF
   If !Empty(cMsgInfo) 
      IF lTem102 .Or. lTem103 //LRS - 12/07/2017
         MsgInfo( cMsgInfo, STR0004)
      Else
        MsgInfo( cMsgInfo + ENTER + If(n == 2, STR0160, STR0161), STR0004)
        n := 0
      EndIF
   EndIf
   
   IF AVFValidaImp()//AWR - 22/10/2004 - AVFLUXO
      AVINCFRETESEG("201")
      AVINCFRETESEG("202")
      AVINCFRETESEG("204")
      AVINCFRETESEG("205")
      cMV_CODTXSI:=EasyGParam("MV_CODTXSI",,"415")
      IF !EMPTY(cMV_CODTXSI)
         AVINCFRETESEG(cMV_CODTXSI)
      ELSE
         MsgInfo("Titulo da Despesa Taxa do SISCOMEX nao sera gerado porque o Codigo no Arquivo de Parametro (SX6) nao esta preenchido.",;
                 "Parametro: MV_CODTXSI")
      ENDIF
   ENDIF//AWR - 22/10/2004
ENDIF
IF !empty(SW6->W6_DT_ENCE) //  Jonato, OS 1174/03 da ocorrência 0111/03
   RETURN NIL
ENDIF

SWD->(DBSETORDER(1))
SYW->(DBSETORDER(1))
SY4->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SY5->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SW3->(DBSETORDER(8))
SWI->(DBSETORDER(2))
SWF->(DBSETORDER(1))

//IF GetNewPar("MV_EASYFIN","N")=="S"  - NOPADO POR AOM - 23/04/2012 
   IF SELECT("WORKTP") == 0
      axFl2DelWork:={}
      TP252CriaWork()
   ELSE// AWR - 27/05/2004
      DBSELECTAREA("WORKTP")
      WorkTP->(DBGOTOP())
      DO WHILE WorkTP->(!EOF())
         WorkTP->(DBDELETE())// Nao pode dar ZAP por que o ADS nao aceita ZAP dentro do Begin Transaction acionado para o financeiro
         WorkTP->(DBSKIP())
      ENDDO
   ENDIF
//ENDIF

SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN))       
IF SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB+"901")) //  Jonato, OS 1174/03 da ocorrência 0111/03
   lTem901:= ! EMPTY(SWD->WD_CTRFIN1)
ENDIF

SWF->(DBSEEK(xFilial("SWF")+SW6->W6_TAB_PC))
IF SWF->(EOF())
   SWF->(DBSEEK(xFilial("SWF")))
ENDIF

If !(SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+SW6->W6_TAB_PC))) // RRV - 10/08/2012 / Procura a tabela de pré-calculo com via de transporte referente ao PO, se existirem mais de uma com o mesmo código corretamente.
   SWF->(DBSETORDER(1))
   SWI->(DBSETORDER(1))
   SWI->(DBSEEK(XFILIAL("SWI")+SWF->WF_TAB))
EndIf 

ProcRegua(3)

IF lFazPrDesp
   
   EICTP252({cHawb,SW6->W6_IMPORT})

   lDA := AllTrim(SW6->W6_TIPOFEC) == "DA"
   
   If lDA
      aDIsNasc := FI400GetDIsNa(SW6->W6_HAWB)
   EndIf
   
   WorkTP->(DBGOTOP())
  
   DO WHILE  !WORKTP->(EOF())
        
         IF !AVFAZDESP(lTem901,nTamDesp) //Ignora 102,103 se 'W6_TIPOFEC = "DIN"'
            WORKTP->(DBSKIP())
            LOOP
         ENDIF                                                                       
         // Posiciona Tabela de Pre-Calculo   
         
         //FDR - 09/09/13 - Tratamento para moeda USD    
         If cMoeda2 <> "US$" .And. cMoeda2 <> "USD" //RRV - 17/08/12 - Caso a moeda 2 não seja dólar, deve usar a taxa do dólar para conversão, pois o pré-cálculo grava a tabela SWH em dólar.
            nTaxa:=BuscaTaxa("US$"  ,dDataBase,.T.,.F.,.T.)  
         Else   
            nTaxa:=BuscaTaxa(cMoeda2,dDataBase,.T.,.F.,.T.)
         EndIf
         
         nTaxa:=IF(nTaxa=0,1,nTaxa)
            
         If WORKTP->(FieldPos("WKVLPAGTO2")) # 0    // GFP - 16/01/2014
            nValPg:=WORKTP->WKVLPAGTO2*nTaxa
         Else
            nValPg:=WORKTP->WKVL_PAGTO*nTaxa
         EndIf
         
         If lMoedaWF .And. SWF->WF_IDMOEDA $ '2' //LGS-28/07/2016 - Posiciona na despesa para saber qual é a moeda            
            nValPgWH := nValPg
            cIndice := If(SWI->(IndexOrd()) == 2, 'SWI->(DBSEEK(xFilial("SWI")+SW6->W6_VIA_TRA+SW6->W6_TAB_PC+WORKTP->WKDESPESA))',;
                                                  'SWI->(DBSEEK(xFilial("SWI")+SW6->W6_TAB_PC+WORKTP->WKDESPESA))') //LGS-03/08/2016
            If &(cIndice)            
               cMoeda1 := SWI->WI_MOEDA
               nTaxa   := nTaxa:=BuscaTaxa(cMoeda1,dDataBase,.T.,.F.,.T.)
               nValPg  := nValPgWH/nTaxa
            EndIf
         EndIf         

         If lDA
            nDespDis := 0
            SWD->(dbSetOrder(1)) //WD_FILIAL+WD_HAWB+WD_DESPESA
            For i := 1 To Len(aDIsNasc)
               cChaveSWD := xFilial("SWD")+aDIsNasc[i]+WORKTP->WKDESPESA
               SWD->(dbSeek(cChaveSWD))
               Do While SWD->(!Eof() .AND. WD_FILIAL+WD_HAWB+WD_DESPESA == cChaveSWD)
                  nDespDis += SWD->WD_VALOR_R
                  SWD->(dbSkip())
               EndDo
            Next i
            
            nValPg -= nDespDis
         EndIf
         
         If nValPg > 0
            // Adiciona Itens para Previsao
            nAsc:=ASCAN(aDespesas, {|cAsc| cAsc[1]==WORKTP->WKDESPESA } )
            IF nAsc == 0
               AADD(aDespesas,{WORKTP->WKDESPESA,cMoeda1,,nValPg,WORKTP->WKDT_PAGTO,WORKTP->WKDESPDESC})
            ELSE
               aDespesas[nAsc,4]+=nValPg
            ENDIF
         EndIf
         
         WORKTP->(DBSKIP())
   ENDDO
EndIf
   
//RRV - 22/02/2013 - Tratamento de títulos provisórios de numerário.
If EasyGParam("MV_EIC0023",,.F.) .And. If(Type("cControle") <> "C",.F.,If(cControle $ "Inclusao/Cancela/GeraPA/ExcluiPA/Desemb",.T.,.F.))
   aDesp1 := {}
   SWD->(DbSetOrder(1))
   If SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + "901"))
      For n := 1 to Len(aDespesas)
         If EIC->(DbSeek(xFilial("EIC") + SW6->W6_HAWB + aDespesas[n][1]))
            If !(SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + aDespesas[n][1])) .And. !(Left(aDespesas[n][1],1) $ "19"))
               aAdd(aDesp1,aDespesas[n])
            EndIf
         Else
            aAdd(aDesp1,aDespesas[n])
         EndIf
      Next

      aDespesas := aDesp1
      If SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + "901"))            //MFR 17/12/2019 OSSME-4179
         Do While SWD->(!Eof()) .And. SWD->WD_HAWB == SW6->W6_HAWB .AND. SWD->WD_DESPESA == "901" .AND. SWD->WD_FILIAL == XFILIAL("SWD")
            If !(SWD->WD_TIPO == "PA ")
               aAdd(aDespesas,{"901",cMoeda1,,SWD->WD_VALOR_R,/*dDataBase*/ SWD->WD_DES_ADI,"ADIANTAMENTO"}) //AAF 02/02/2017 - Utilizar a data digitada pelo usuário para o provisório de adiantamento.
            EndIf
         SWD->(DbSkip())
         EndDo
      EndIF
   EndIf
EndIF
      
If Len(aDespesas) > 0 //AAF 02/02/2017 - Permitir gerar provisório de numerário independente dos outros provisórios.

   SY5->(DBSETORDER(1))
   nDup:= 0

   //ASK - 30/07/07 Tratamento para a data de vencimento dos títulos PRE conforme a ordem de preenchimento das datas.
   SY9->(DbSetOrder(2))
   SY9->(DbSeek(xFilial("SY9") + SW6->W6_DEST))
   If SY9->Y9_LT_DES == 0
      nLead_Des := EasyGParam("MV_LT_DESE")
   Else
      nLead_Des := SY9->Y9_LT_DES
   EndIf
   dDtVenc_PR := CTOD("")    
   //** PLB 19/09/07 - Inclusão de datas a serem consideradas para Data de Vencimento dos Títulos no Financeiro
   nLeadTDesem := 0
   nLeadTTran := 0
   If !EasyGParam("MV_DTLEADT",,.F.)  // By JPP - 23/10/2007 - 16:30 - Quando este MV retorna .F., o sistema calcula a data de vencimento dos titulos PRE da forma padrão antiga(somando os lead times desembaraço e Transito do cadastro de via de transporte).  
      nLeadTDesem := nLead_Des
      nLeadTTran := SY9->Y9_LT_TRA
   EndIf
   If !Empty(SW6->W6_DT_ENTR)      // Data de Entrega
      dDtVenc_PR := SW6->W6_DT_ENTR
   ElseIf !Empty(SW6->W6_PRVENTR)  // Previsão de Entrega
      dDtVenc_PR := SW6->W6_PRVENTR
   //**
   ElseIf !Empty(SW6->W6_DT_DESE)  //Data do Desembaraço 
      dDtVenc_PR := SW6->W6_DT_DESE + nLeadTTran //SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30
   ElseIf !Empty(SW6->W6_PRVDESE)  // Previsão do Desembaraço 
      dDtVenc_PR := SW6->W6_PRVDESE + nLeadTTran //SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30 
   ElseIf !Empty(SW6->W6_CHEG)     // Data de Atracação
      dDtVenc_PR := SW6->W6_CHEG + nLeadTDesem + nLeadTTran // nLead_Des +SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30 
   ElseIf !Empty(SW6->W6_DT_ETA)   // Data Prevista de Atracação
      dDtVenc_PR := SW6->W6_DT_ETA + nLeadTDesem + nLeadTTran //nLead_Des + SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30
   ElseIf !Empty(SW6->W6_DT_EMB)   // Data de Embarque
      dDtVenc_PR := SW6->W6_DT_EMB + SYR->YR_TRANS_T + nLeadTDesem + nLeadTTran // nLead_Des + SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30  
   ElseIf !Empty(SW6->W6_DT_ETD)   // Data Prevista de Embarque
      dDtVenc_PR := SW6->W6_DT_ETD + SYR->YR_TRANS_T + nLeadTDesem + nLeadTTran // nLead_Des + SY9->Y9_LT_TRA // By JPP - 23/10/2007 - 16:30       
   EndIf

   loIntPr:= Type("oIntPr") == "O"
   IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	   For nDesp:=1 to Len(aDespesas)
		   cTipoPar  := "PR"
		   cFornec:=cFornecMV
		   cLojaF :=cLojaFMV
		   IF SY5->(DBSEEK(XFILIAL("SY5")+SW6->W6_DESP))
			  IF !EMPTY(SY5->Y5_FORNECE)
				 cFornec:=SY5->Y5_FORNECE 
				 cLojaF :=SY5->Y5_LOJAF   
			  ENDIF
		   ENDIF

		   IF aDespesas[nDesp][1] = DESP_FRETE .AND. !EMPTY(SW6->W6_AGENTE)
			  IF SY4->(DBSEEK(XFILIAL("SY4")+SW6->W6_AGENTE))
				 IF !EMPTY(SY4->Y4_FORN)
					cFornec:=SY4->Y4_FORN 
					cLojaF :=SY4->Y4_LOJA   
				 ENDIF
			  ENDIF
		   ELSEIF aDespesas[nDesp][1] = DESP_SEGURO .AND. !EMPTY(SW6->W6_CORRETO)
			  IF SYW->(DBSEEK(XFILIAL("SYW")+SW6->W6_CORRETO))
				 IF !EMPTY(SYW->YW_FORN)
					cFornec:=SYW->YW_FORN 
					cLojaF :=SYW->YW_LOJA   
				 ENDIF
			  ENDIF
		   ENDIF

		   IF cPaisLoc # "BRA"         
			  cDescFB:=' '
			  SFB->(DBSEEK(XFILIAL("SFB")+ALLTRIM(aDespesas[nDesp,6])))
			  IF !EMPTY(SFB->FB_FORNECE)
				 cFornec :=SFB->FB_FORNECE 
				 cLojaF  :=SFB->FB_LOJA
				 cDescFB :=SFB->FB_DESCR
			  ELSE
				 cDescFB:=aDespesas[nDesp,6] 
			  ENDIF
		   ELSE
			  cDescFB:=aDespesas[nDesp,6]
		   ENDIF
			
		   xRecSA2:=SA2->(recno())
		   nErroDup:=1
		   IF SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF))   .and.   aDespesas[nDesp,4] > 0  .AND. EasyGeraProv("PRE",aDespesas[nDesp,1])
			 //** PLB 19/09/07 - Consideração da Tabela de Pré-Cálculo para compor data de vencimento dos títulos
			 nQtdDias := 0
			 SWF->(DbSetOrder(1))  //WF_FILIAL+WF_TAB  // GFP - 22/01/2014
			 If !SWF->( DBSeek(xFilial("SWF")+SW6->W6_TAB_PC) )
				SWF->( DBSeek(xFilial("SWF")) )
			 EndIf   
			 If SWF->( !EoF() )
				SWI->(DbSetOrder(1))  //WI_FILIAL+WI_TAB+WI_DESP  // GFP - 22/01/2014
				If SWI->( DBSeek(xFilial("SWI")+SWF->WF_TAB+aDespesas[nDesp][1]) )
				   nQtdDias := SWI->WI_QTDDIAS
				EndIf
			 EndIf
			 If Empty(dDtVenc_PR)
				dDtVencto := aDespesas[nDesp,5]
			 Else
				dDtVencto := dDtVenc_PR + nQtdDias
			 EndIf
			 If dDtVencto < dDataBase  // Caso o vencimento seja anterior à emissão do título
				dDtVencto := dDataBase
			 EndIf
			 //**
			 //TRP - 09/03/2010 
			 nValorRdm := aDespesas[nDesp,4]
			 cDespRdm  := aDespesas[nDesp,1]
			 
			 //RRV - 22/02/2013 - Tratamento de data de vencimento dos títulos provisórios de numerário. 
			 If EasyGParam("MV_EIC0023",,.F.) .AND. aDespesas[nDesp][1] == "901"
				//If(Type("dDtVenc") <> "D",dDtVencto,dDtVencto := dDtVenc)
				dDtVencto := aDespesas[nDesp,5] //AAF 02/02/2017 - Utilizar a data digitada pelo usuário no provisório de numerário.
			 EndIf
			 
			 IF(EasyEntryPoint("AVFLUXO"),Execblock("AVFLUXO",.F.,.F.,"VALOR_TIT_PRE"),)
			 nDup+=1
			 If AvFlags("AVINT_PRE_EIC") /*lAvIntDesp*/ .AND. loIntPr    //NOPADO POR AOM - 23/04/2012 - Pois deve ser considerada a flag já que os pedidos podem nao ter gerados os titulos, e só o embarque optar por esta opção.
				oIntPr:GeraProv(aDespesas[nDesp,4]  ,;   //Valor da duplicata
						   dDataBase,;              //data de emissao
						   dDtVencto,;              //Data de vencimento
						   aDespesas[nDesp,2],;     //Simbolo da moeda
						   "PRE",;                  //Tipo do titulo
						   1,;                      //Numero de parcela
						   cFornec,;                //Fornecedor
						   cLojaF,;                 //Loja
						   "",;                     
						   SW6->W6_HAWB,;           //Processo
						   "",;                     //Pedido
						   aDespesas[nDesp][1],;    //Despesa
						   "")                      //Invoice
			 Else
				nErroDup:=GeraDupEic(SW6->W6_NUMDUP ,; //Numero das duplicatas
						aDespesas[nDesp,4]  ,;          //Valor da duplicata
						dDataBase,;        //data de emissao
						dDtVencto,;  //If(Empty(dDtVenc_PR),aDespesas[nDesp,5],dDtVenc_PR),; //Data de vencimento
						aDespesas[nDesp,2],;    //Simbolo da moeda
						"EIC",;            //Prefixo do titulo
						"PRE" ,;            //Tipo do titulo
						nDup,;            //Numero de parcela.
						cFornec,;     //Fornecedor
						cLojaF,;     //Loja
						"SIGAEIC",;        //Origem da geracao da duplicata (Nome da rotina)
						"Proc."+ALLTRIM(SW6->W6_HAWB)+' '+;
							"-"+cDescFB,;//Historico da geracao
						0,,SW6->W6_HAWB)                 //Taxa da moeda (caso usada uma taxa diferente a
			 EndIf
		  ENDIF
		   SA2->(DBGOTO(xRecSA2))
		   
		   IF(EasyEntryPoint("AVFLUXO"),Execblock("AVFLUXO",.F.,.F.,"VALOR_TIT_PRE_POS"),)//AOM - 17/03/2010
			
	   Next nDesp  
   EndIF   
ENDIF   

IncProc()

SW3->(DBSETORDER(nOrdSW3))
SW7->(DBSETORDER(nOrdSW7))
SWI->(DBSETORDER(nOrdSWI))
SY5->(DBSETORDER(nOrdSY5))
SB1->(DBSETORDER(nOrdSB1))
SWD->(DBSETORDER(nOrdSWD))
SYW->(DBSETORDER(nOrdSYW))
SY4->(DBSETORDER(nOrdSY4))
SWF->(DBSETORDER(nOrdSWF))

SELECT(nAlias)
SW6->(DBSETORDER(nInd))

Return NIL

*------------------------------------------------------------------------------------------*
Function DeleImpDesp(cDuplic,cTipo,cFase,lnoFretSeg,lAltFrete,lAltSeguro)
*------------------------------------------------------------------------------------------*
LOCAL cFornDesp, cLojaDesp, cFornFret, cLojaFret,cFornSeg, cLojaSeg, F
Private cUltParc := ""  // GFP - 20/01/2014
Private lLoop102 := lLoop103 := .F. //LGS-26/11/2015

DEFAULT lAltFrete  := .T.
DEFAULT lAltSeguro := .T.

//LGS-23/11/2015 - Executa a função para verificar as despesas 102 e 103
NU400Desp('SWB')

SA2->(DBSETORDER(1))
IF lnoFretSeg==NIL
   lnoFretSeg:=.F.
ELSE
   lnoFretSeg:=.T.
ENDIF   
IF EasyGParam("MV_EASYFIN",,"N") $ cSim
   cFornDesp:=PADR(EasyGParam("MV_FORDESP"),LEN(SA2->A2_COD))
   cLojaDesp:=PADR(EasyGParam("MV_LOJDESP"),LEN(SA2->A2_LOJA))
   DO CASE 
      CASE cFase == "PO"
           SY5->(DBSEEK(XFILIAL("SY5")+SW2->W2_DESP))
           cFornDesp:=IF(EMPTY(SY5->Y5_FORNECE),cFornDesp,SY5->Y5_FORNECE)
           cLojaDesp:=IF(EMPTY(SY5->Y5_LOJAF)  ,cLojaDesp,SY5->Y5_LOJAF) 
           SY4->(DBSEEK(XFILIAL("SY4")+SW2->W2_AGENTE))
           cFornFret:=SY4->Y4_FORN
           cLojaFret:=SY4->Y4_LOJA 
           cFornSeg :=cFornDesp
           cLojaSeg :=cLojaDesp
           
      CASE cFase == "DI"
           SY5->(DBSEEK(XFILIAL("SY5")+SW6->W6_DESP))
           cFornDesp:=IF(EMPTY(SY5->Y5_FORNECE),cFornDesp,SY5->Y5_FORNECE)
           cLojaDesp:=IF(EMPTY(SY5->Y5_FORNECE),cLojaDesp,SY5->Y5_LOJAF) 
           SY4->(DBSEEK(XFILIAL("SY4")+SW6->W6_AGENTE))
           cFornFret:=SY4->Y4_FORN
           cLojaFret:=SY4->Y4_LOJA                     
           SYW->(DBSEEK(XFILIAL("SYW")+SW6->W6_CORRETO))
           cFornSeg :=SYW->YW_FORN
           cLojaSeg :=SYW->YW_LOJA                     
           
   ENDCASE
      
   IF !(cPaisLoc=="BRA")
      SFB->(DBSEEK(XFILIAL("SFB")))

      DO WHILE  !SFB->(EOF())  .AND. XFILIAL("SFB") == SFB->FB_FILIAL

         DeleDupEIC("EIC",;            //Prefixo do titulo
           cDuplic,;  //Numero das duplicatas
           -1,;               //Numero de parcela.
           cTipo ,;            //Tipo do titulo
           IF(EMPTY(SFB->FB_FORNECE),cFornDesp,SFB->FB_FORNECE),;     //Fornecedor
           IF(EMPTY(SFB->FB_LOJA)   ,cLojaDesp,SFB->FB_LOJA) ,;     //Loja
           "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
           
         SFB->(DBSKIP())        
      ENDDO 
   ENDIF
      
   IF !EMPTY(cFornDesp) .AND. SA2->(DBSEEK(XFILIAL('SA2')+cFornDesp+cLojaDesp))
      DeleDupEIC("EIC",;            //Prefixo do titulo
           cDuplic,;  //Numero das duplicatas
           -1,;               //Numero de parcela.
           cTipo ,;            //Tipo do titulo
           cFornDesp,;     //Fornecedor
           cLojaDesp ,;     //Loja
           "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
   
   ENDIF
   
   IF !EMPTY(cFornFret) .AND. SA2->(DBSEEK(XFILIAL('SA2')+cFornFret+cLojaFret))
      DeleDupEIC("EIC",;            //Prefixo do titulo
           cDuplic,;  //Numero das duplicatas
           -1,;               //Numero de parcela.
           cTipo ,;            //Tipo do titulo
           cFornFret ,;     //Fornecedor
           cLojaFret ,;     //Loja
           "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
        
   Endif        
   
   IF !EMPTY(cFornSeg) .AND. SA2->(DBSEEK(XFILIAL('SA2')+cFornSeg+cLojaSeg))
      DeleDupEIC("EIC",;            //Prefixo do titulo
           cDuplic,;  //Numero das duplicatas
           -1,;               //Numero de parcela.
           cTipo ,;            //Tipo do titulo
           cFornSeg ,;     //Fornecedor
           cLojaSeg ,;     //Loja
           "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
   Endif       
   
   
   IF cFase="DI" .and. !lnoFretSeg //.and. cTipo <> "PR" - AWR 19/03/2004
      IF cPaisLoc == "BRA"
         IF !FindFunction("FI400TitFin")   // JBS - 23/04/2004
            MSGINFO("Rotinas que interagem com o financeiro estao desatualizadas!!!" + CHR(13)+CHR(10)+;
                    STR0094, STR0004) //"Favor contatar o departamento de suporte."   
         ELSE
            //LRS - 26/11/2015 - Verifica se foi preenchido o Fornecedor do frete, e se foi trocado para deletar a parcela e criar uma nova.
            IF !EMPTY(SW6->W6_HOUSE) .AND. (AvFlags("GERACAO_CAMBIO_FRETE") .Or. !EMPTY(SW6->W6_VENCFRE)) .AND. lAltFrete .And. !EMPTY(M->W6_FORNECF) .And. EXCFreSeg(M->W6_HAWB,DESP_FRETE) .And. !lLoop102 //LGS-01/12/2015
               If FI400TITFIN("SW6_102","4",.T.) // Exclui a Parcela de Frete  do SE2 (Financeiro)
                  //Se excluiu o titulo de Frete no Financeiro, deve limpar o campo referente ao numero do titulo na SWD
                  If SWD->(dbSeek(xFilial("SWD") + M->W6_HAWB + DESP_FRETE)) .And. !Empty(SWD->WD_CTRFIN1)
                     RecLock("SWD",.F.)
                     SWD->WD_PREFIXO := ""
                     SWD->WD_CTRFIN1 := ""
                     SWD->WD_PARCELA := ""
                     SWD->WD_TIPO    := ""
                     SWD->WD_FORN    := ""
                     SWD->WD_LOJA    := ""
                     SWD->(MsUnlock())
                  EndIf
               EndIf
            ENDIF
            IF (AvFlags("GERACAO_CAMBIO_SEGURO") .Or. !EMPTY(SW6->W6_VENCSEG)) .AND. lAltSeguro .And. !EMPTY(M->W6_FORNECS) .And. EXCFreSeg(M->W6_HAWB,DESP_SEGURO) .And. !lLoop103 //LGS-01/12/2015
               If FI400TITFIN("SW6_103","4",.T.) // Exclui a Parcela de Seguro do SE2 (Financeiro)
                  //Se excluiu o titulo de Seguro no Financeiro, deve limpar o campo referente ao numero do titulo na SWD
                  If SWD->(dbSeek(xFilial("SWD") + M->W6_HAWB + DESP_SEGURO)) .And. !Empty(SWD->WD_CTRFIN1)
                     RecLock("SWD",.F.)
                     SWD->WD_PREFIXO := ""
                     SWD->WD_CTRFIN1 := ""
                     SWD->WD_PARCELA := ""
                     SWD->WD_TIPO    := ""
                     SWD->WD_FORN    := ""
                     SWD->WD_LOJA    := ""
                     SWD->(MsUnlock())
                  EndIf
               EndIf
            ENDIF
            //AWR - 09/11/2004 - Titulos Impostos
            aImpostos:={"201","202","204","205",EasyGParam("MV_CODTXSI",,"415")}
            FOR F := 1 TO LEN(aImpostos) 
                IF AVImpostos(aImpostos[F],"APAGA_IMP")
                   SWD->(DBSETORDER(1))
                   IF SWD->(DBSEEK(xFilial()+SW6->W6_HAWB+aImpostos[F]))
                      FI400TITFIN("SW6_IMP","4",.T.)
                   ENDIF
                ENDIF
            NEXT
            //AWR - 09/11/2004 - Titulos Impostos
         ENDIF
      ELSE
         IF !EMPTY(SW6->W6_HOUSE) .AND. (AvFlags("GERACAO_CAMBIO_FRETE") .Or. !EMPTY(SW6->W6_VENCFRE)) .AND. lAltFrete
            cDuplFin:=SW6->W6_NUMDUP
            IF !GetNewPar("MV_CAMBIL",.F.)
               IF SWD->(DBSEEK(XFILIAL("SWD")+SW6->W6_HAWB+DESP_FRETE))                     
                  cDuplFin:=SWD->WD_CTRFIN1
               ENDIF
            ENDIF   
            IF SA2->(DBSEEK(XFILIAL('SA2')+cFornfret+cLojaFret))
               DeleDupEIC("EIC",; // Prefixo do titulo
                  cDuplFin,;      // Numero das duplicatas
                  -1,;            // Numero de parcela.
                  "NF" ,;         // Tipo do titulo
                  cFornFret ,;    // Fornecedor
                  cLojaFret ,;    // Loja
                  "SIGAEIC")      // Origem da geracao da duplicata (Nome da rotina)
            ENDIF     
         ENDIF
      
         IF (AvFlags("GERACAO_CAMBIO_SEGURO") .Or. !EMPTY(SW6->W6_VENCSEG)) .AND. lAltSeguro
            cDuplFin:=SW6->W6_NUMDUP
            IF !GetNewPar("MV_CAMBIL",.F.)
               IF SWD->(DBSEEK(XFILIAL("SWD")+SW6->W6_HAWB+DESP_SEGURO))                     
                  cDuplFin:=SWD->WD_CTRFIN1
               ENDIF
            ENDIF
            IF SA2->(DBSEEK(XFILIAL('SA2')+cFornSeg+cLojaSeg))
               DeleDupEIC("EIC",;   // Prefixo do titulo
               cDuplFin,;           // Numero das duplicatas
               -1,;                 // Numero de parcela.
               "NF" ,;              // Tipo do titulo
               cFornSeg ,;          // Fornecedor
               cLojaSeg ,;          // Loja
               "SIGAEIC")           // Origem da geracao da duplicata (Nome da rotina)
            ENDIF
         ENDIF     
      ENDIF
   ENDIF
   
ENDIF           
RETURN NIL


*-----------------------------------------------------------*
Function AVNUMER(lBase,cFornec,cLojaF)                           
*-----------------------------------------------------------*
Private cUltParc := ""  // GFP - 20/01/2014
IF EasyGParam("MV_EASYFIN",,"N") $ cSim .AND. AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
   IF SW6->W6_TIPOFEC = 'DIN' .AND. SWD->WD_DESPESA $ "102,103"
      RETURN
   ENDIF

      IF EMPTY(cFornec) .OR. lBase//BASEAD $ cNAO
         SY5->(DBSEEK(XFILIAL("SY5")+ SW6->W6_DESP ))
         IF EMPTY(SY5->Y5_FORNECE)
            cFornec:=EasyGParam("MV_FORDESP")
            cFornec:=cFornec+SPACE(LEN(SA2->A2_COD)-LEN(cFornec))
            cLojaF :=EasyGParam("MV_LOJDESP")
         ELSE
            cFornec:=SY5->Y5_FORNECE 
            cLojaF :=SY5->Y5_LOJAF   
         ENDIF
      ENDIF   
      IF SWD->WD_DESPESA # "901" 
         IF EMPTY(TRB->EIC_FORN)
            SWD->WD_FORN:= cFornec
            SWD->WD_LOJA:= cLojaF
         ELSE
            SWD->WD_FORN:= TRB->EIC_FORN
            SWD->WD_LOJA:= TRB->EIC_LOJA
         ENDIF   
      ENDIF   
	  IF lBase
		 IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"//AVGERAL.PRW
			cNumWD:=AvgNumSeq("SWD","WD_CTRFIN1")
		 ELSE
			If EasyGParam("MV_EICNUMT",,"1") == "2"
			   cNumWD:=GetSXENum("SE2","E2_NUM")
			Else
			   cNumWD:=GetSXENum("SWD","WD_CTRFIN1")
			EndIf
			ConfirmSX8()
		 ENDIF
		 SWD->WD_CTRFIN1:= cNumWD
		 DeleImpDes(SW6->W6_NUMDUP,"PR",SW6->W6_DESP)
		 nErroDup:=1                  
		 SA2->(DBSETORDER(1))
		 IF SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF))  
		
			nErroDup:=GeraDupEic(SWD->WD_CTRFIN1,; //Numero das duplicatas
					SWD->WD_VALOR_R  ,;          //Valor da duplicata
					dDataBase,;        //data de emissao
					SWD->WD_DES_ADI,;  //Data de vencimento
					EasyGParam("MV_SIMB1"),;    //Simbolo da moeda
					"EIC",;            //Prefixo do titulo
					IF(SWD->WD_DESPESA='901',"PA","NF") ,;            //Tipo do titulo
					1,;            //Numero de parcela.
					cFornec,;     //Fornecedor
					cLojaF,;     //Loja
					"SIGAEIC",;    	  //Origem da geracao da duplicata (Nome da rotina)
					"Proc:"+ALLTRIM(SW6->W6_HAWB)+' '+STR0005+' '+SWD->WD_DESPESA,; //Historico da geracao
					0,.T.,SW6->W6_HAWB)       //Taxa da moeda (caso usada uma taxa diferente a
																			 
		 ENDIF       
	  ENDIF
ENDIF
RETURN NIL


*-----------------------------------------------------------*
Function AVFAZDESP(lTem901,nTamDesp)
*-----------------------------------------------------------*
DO CASE     
   CASE WorkTP->WKDESPESA$'101' 
        RETURN .F.
   CASE WorkTP->WKDESPESA=DESP_FRETE
        IF (EMPTY(SW6->W6_VLFRECC) .OR. EMPTY(SW6->W6_HOUSE)  .OR. SW6->W6_TX_FRET=0 .OR.;
            EMPTY(SW6->W6_FREMOED) .OR. (!AvFlags("GERACAO_CAMBIO_FRETE") .And. EMPTY(SW6->W6_VENCFRE))) .AND.;
           SW6->W6_TIPOFEC # 'DIN' .AND. ( !SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB+ SUBST(WorkTP->WKDESPESA,1,nTamDesp))).OR. !lTem901) //.OR. SWD->WD_BASEADI <> "1" - TDF - 31/03/10  
           RETURN .T.      
        ELSE                                           
           RETURN .F.
        ENDIF      
   CASE WorkTP->WKDESPESA=DESP_SEGURO
        IF (SW6->W6_VL_USSE=0 .OR. EMPTY(SW6->W6_SEGMOED)      .OR.;
           (!AvFlags("GERACAO_CAMBIO_SEGURO") .And. EMPTY(SW6->W6_VENCSEG))).AND.;// .AND. EMPTY(SW6->W6_DI_NUM)
           SW6->W6_TIPOFEC # 'DIN' .AND. ( !SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB+ SUBST(WorkTP->WKDESPESA,1,nTamDesp))).OR. !ltem901) //OR. SWD->WD_BASEADI <> "1" - TDF - 31/03/10 
           RETURN .T.
        ELSE
           RETURN .F.
        ENDIF      
   OTHERWISE
       IF SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB+ SUBST(WorkTP->WKDESPESA,1,nTamDesp)))   // Jonato, OS 1174/03 da ocorrência 0111/03
          IF !EMPTY(SWD->WD_CTRFIN1) .OR. ;
             (SWD->WD_BASEADI == "1" .AND. ltem901)
             RETURN .F.
          ENDIF
        ENDIF      
ENDCASE   
RETURN .T.

*-----------------------------------------------------------*
Function AVINCFRETESEG(cDesp)                           
*-----------------------------------------------------------*
LOCAL lFazDesp,lIncDesp
LOCAL cDuplFin:=SW6->W6_NUMDUP
LOCAL cMoeda:="R$", nTaxa:=0
LOCAL nFreteReal:=(SW6->W6_VLFRECC*SW6->W6_TX_FRET)
LOCAL cChaveSWD:=XFILIAL("SWD")+SW6->W6_HAWB+cDesp
//Local nChr := Asc(Alltrim(EasyGParam("MV_1DUP"))) - 1   // EOS - 30/04/04
Local cMsg_Erro_Frete // JBS - 10/05/2004
LOCAL lImpostos:=.F.//AWR - 09/11/2004 - Titulos Impostos
LOCAL aOrdSWD:= {} 
LOCAL lFretSegWD := .T. //NCF - 18/02/10 - Gravar Titulo no SWD para frete e seguro no embarque
Private lNumOk := .F. //CCH - 28/07/09 - Retorno da função de verificação das despesas de frete e seguro provenientes do numerário
PRIVATE lAutomatico:=.F.,nAtomatico:=2,nValorSWD:=nValor:=0,cFornec:=cLojaF:=""//AWR - 22/10/2004
PRIVATE cIniDocto:=SPACE(LEN(SW6->W6_NUMDUPF))//AWR - 22/10/2004
PRIVATE dDataVenc:=IF(cDesp='102',SW6->W6_VENCFRE,SW6->W6_VENCSEG)//AWR - 22/10/2004
Private lAvIntFinEIC := AvFlags("AVINT_FINANCEIRO_EIC")
Private cUltParc := ""  // GFP - 20/01/2014
// AWR - 23/06/2004 - Inclusao Automatica
IF SX1->(DBSEEK("EICFI5")) 
   Pergunte("EICFI5",.F.)
   IF(!EMPTY(MV_PAR01), nAtomatico:=MV_PAR01 ,)
ENDIF
lAutomatico := (nAtomatico = 1)
// AWR - 23/06/2004 - Inclusao Automatica
   
PRIVATE c_DuplDoc := GetNewPar("MV_DUPLDOC","  ")
PRIVATE n, nRecSE2 := 0  //ASR 08/02/2006   
// SVG - 20/10/2010 - Tratamento para geração de titulos mesmo em nacionalização
/*IF SW6->W6_TIPOFEC = 'DIN'
   RETURN
ENDIF
*/
DO CASE
   CASE cDesp==DESP_FRETE

        lFazdesp:= .t.      // JBS - 10/05/2004
        cMsg_Erro_Frete := "" // JBS - 10/05/2004
                           
        IF EMPTY(SW6->W6_VLFRECC)
           lFazdesp:=.f.
        ELSE
           AvValidFre(@cMsg_Erro_Frete,@lFazdesp,"SW6")
           cChaveSWD:=XFILIAL("SWD")+SW6->W6_HAWB+cDesp
        ENDIF

        IF !empty(cMsg_Erro_Frete) // JBS - 10/05/2004
           cMsg_Erro_Frete := "Titulo de Frete nao gerado pelos seguintes motivos:"+CHR(13)+CHR(10)+cMsg_Erro_Frete   
           MsgInfo(cMsg_Erro_Frete,"Aviso")
        ENDIF 
        
        IF lFazDesp
           nValor   := nFreteReal// ( SW6->W6_VLFRECC+SW6->W6_VLFREPP-SW6->W6_VLFRETN) * SW6->W6_TX_FRET
           nValorSWD:= nFreteReal
           If cPaisLoc <> "BRA"
              cMoeda:=  EasyGParam("MV_SIMB1")
           Endif   
           If cPaisLoc == "ARG"
              nValor:= SW6->W6_VLFRECC //( SW6->W6_VLFRECC+SW6->W6_VLFREPP-SW6->W6_VLFRETN) 
              cMoeda:= SW6->W6_FREMOED 
              nTaxa := SW6->W6_TX_FRET
           Endif
           cFornec:=IF(!EMPTY(SW6->W6_FORNECF),SW6->W6_FORNECF,SY4->Y4_FORN)  //NCF - 18/02/10 
           cLojaF :=IF(!EMPTY(SW6->W6_LOJAF),SW6->W6_LOJAF,SY4->Y4_LOJA)      //NCF - 18/02/10
        ENDIF   
        
        
   CASE cDesp==DESP_SEGURO
   
        lFazdesp:= .t.      // JBS - 10/05/2004
        cMsg_Erro_Frete := "" // JBS - 10/05/2004
        
        IF EMPTY(SW6->W6_VL_USSE)
           lFazdesp := .f.
        ELSE
           AvValidSeg(@cMsg_Erro_Frete,@lFazdesp,"SW6")
           cChaveSWD:=XFILIAL("SWD")+SW6->W6_HAWB+cDesp
        ENDIF
        
        IF !empty(cMsg_Erro_Frete) // JBS - 10/05/2004
           cMsg_Erro_Frete := "Titulo de Seguro nao gerado pelos seguintes motivos:"+CHR(13)+CHR(10)+cMsg_Erro_Frete   
           MsgInfo(cMsg_Erro_Frete,"Aviso")
        ENDIF 
 
        IF lFazdesp
           DO CASE 
              CASE SW6->W6_TX_SEG # 0 
                   nValor := SW6->W6_VL_USSE * SW6->W6_TX_SEG
 
              CASE SW6->W6_SEGMOED == EasyGParam("MV_SIMB2") .AND. SW6->W6_TX_US_D != 0
                   nValor := SW6->W6_VL_USSE * SW6->W6_TX_US_D
                   
              Otherwise
                   nValor := SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,SW6->W6_DT,.T.,.F.,.T.)
           ENDCASE
           nValorSWD:= nValor
           If cPaisLoc <> "BRA"
              cMoeda:=  EasyGParam("MV_SIMB1")
           Endif  
           If cPaisLoc == "ARG"
              nValor := SW6->W6_VL_USSE 
              cMoeda := SW6->W6_SEGMOED      
              nTaxa  := SW6->W6_TX_SEG
           Endif   
           
           cFornec:=IF(!EMPTY(SW6->W6_FORNECS),SW6->W6_FORNECS,SY4->Y4_FORN)  //NCF - 18/02/10
           cLojaF :=IF(!EMPTY(SW6->W6_LOJAS),SW6->W6_LOJAS,SY4->Y4_LOJA)      //NCF - 18/02/10
        ENDIF

   OTHERWISE//AWR - 22/10/2004

        lFazDesp :=AVImpostos(cDesp,"DEPOIS_GRV")//AWR - 22/10/2004
        lImpostos:=.T.//AWR - 22/10/2004

ENDCASE

IF lFazDesp .OR. (EMPTY(nValorSWD) .AND. SWD->(DBSEEK(cChaveSWD)))
   SYB->(DBSEEK(XFILIAL("SYB")+cDesp))
   IF (cPaisLoc # "BRA" .AND. !Getnewpar("MV_CAMBIL",.F.)) .OR. lImpostos//AWR - 22/10/2004
      
      lIncDesp:=.T.
      IF !SWD->(DBSEEK(cChaveSWD)) 
         SWD->(RECLOCK("SWD",.T.))
         //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
         If lAvIntFinEIC
            SWD->WD_LINHA := DI500SWDLin(SW6->W6_HAWB,cDesp)
         EndIf
      ELSE            
         SWD->(RECLOCK("SWD",.F.))
         IF EMPTY(nValorSWD)
            SWD->(DBDELETE())
            lIncDesp:=.F.
         ENDIF
      ENDIF   
      IF lIncDesp
         SWD->WD_FILIAL  := xFilial("SWD")
         SWD->WD_DESPESA := cDesp
         SWD->WD_HAWB    := SW6->W6_HAWB
         SWD->WD_DES_ADI := dDataVenc
         SWD->WD_VALOR_R := nValorSWD
         SWD->WD_BASEADI := "2"
         SWD->WD_PAGOPOR := "2"
         SWD->WD_GERFIN  := "1"
         SWD->WD_DOCTO   := IF(cDesp==DESP_SEGURO,SW6->W6_NF_SEG,IF(cDesp==DESP_FRETE,SW6->W6_HOUSE,""))
         SWD->WD_FORN    := cFornec
         SWD->WD_LOJA    := cLojaF
         SWD->WD_DTENVF  := dDataBase      
         IF cPaisLoc # "BRA"//AWR - Voltou por causa dos Impostos
            IF EMPTY(SWD->WD_CTRFIN1)
               IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(SWD->WD_DOCTO)
                  cNroDupl := SWD->WD_DOCTO
               ELSE
                  IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"//AVGERAL.PRW
                     cNroDupl := AvgNumSeq("SWD","WD_CTRFIN1")
                  ELSE
                     If EasyGParam("MV_EICNUMT",,"1") == "2"
                        cNroDupl := GetSXENum("SE2","E2_NUM")
                     Else
                        cNroDupl := GetSXENum("SWD","WD_CTRFIN1")
                     EndIf
                     ConfirmSX8()
                  ENDIF
               ENDIF
               SWD->WD_CTRFIN1:=cNroDupl
            ENDIF   
            cDuplFin:=SWD->WD_CTRFIN1
         ENDIF   
      ENDIF   
      SWD->(MSUNLOCK())
   ENDIF
   
   nErroDup:=1                  
   SA2->(DBSETORDER(1))
   
   If cDesp == "102" .AND. AvFlags("GERACAO_CAMBIO_FRETE")  // GFP - 02/06/2015
      lFazDesp:= .F.
   EndIf
   If cDesp == "103" .AND. AvFlags("GERACAO_CAMBIO_SEGURO") // GFP - 02/06/2015
      lFazDesp:= .F.
   EndIf
   IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	   IF lFazDesp .AND. SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF)) .And. lFinanceiro

		  IF cPaisLoc == "BRA"   // JBS - 23/04/2004        
			 lNumOk := AV_FSNUM(cDesp) // CCH - 28/07/09 - Verifica se as despesas de frete e seguro no SWD vieram da solicitação de numerário
			 If !lNumOk // CCH - 28/07/09 - Se o retorno da função AV_FSNUM for igual a True (.T.), pula a gravação do título
				IF !FindFunction("FI400TitFin")   // JBS - 23/04/2004
				   MSGINFO("Rotinas que interagem com o financeiro estao desatualizadas!!!" + CHR(13)+CHR(10)+;
						STR0094,STR0004)//"Favor contatar o departamento de suporte.", Atenção      
				ELSE           
				   cIniDocto := SPACE(LEN(SW6->W6_NUMDUPF))
				   IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"//AVGERAL.PRW
	//                IF lAutomatico
					  IF cDesp == "102"
						 cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPF")) # 0, AvgNumSeq("SW6","W6_NUMDUPF"), " ")  //M->E2_NUM
						 nValor := SW6->W6_VLFRECC  // LDR - 03/03/2005
						 cMoeda := SW6->W6_FREMOED  // LDR - 03/03/2005 
						 nTaxa := SW6->W6_TX_FRET
					  ELSE
						 cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPS")) # 0, AvgNumSeq("SW6","W6_NUMDUPS"), " ")  //M->E2_NUM
						 nValor := SW6->W6_VL_USSE 
						 cMoeda := SW6->W6_SEGMOED 
						 nTaxa  := SW6->W6_TX_SEG
					  ENDIF
	//               ELSE
	//                  cIniDocto := AvgNumSeq("SW9","W9_NUM")//M->E2_NUM
	//               ENDIF
				   ELSE
					  IF cDesp == "102"
						 cIniDocto := IF(SE2->(FieldPos("E2_NUM")) # 0, GetSXENum("SE2","E2_NUM"), " ")  // M->E2_NUM
						 nValor := SW6->W6_VLFRECC  // LDR - 03/03/2005
						 cMoeda := SW6->W6_FREMOED   // LDR - 03/03/2005
						 nTaxa  := SW6->W6_TX_FRET
					  ELSE
						 cIniDocto := IF(SE2->(FieldPos("E2_NUM")) # 0, GetSXENum("SE2","E2_NUM"), " ")  //M->E2_NUM
						 nValor := SW6->W6_VL_USSE 
						 cMoeda := SW6->W6_SEGMOED 
						 nTaxa  := SW6->W6_TX_SEG
					  ENDIF					  
				   ENDIF
				   cPrefixo  := ""                          //M->E2_PREFIXO
				   cTIPO_Tit := "NF"                        //M->E2_TIPO
				   cCodFor   := cFornec                     //M->E2_FORNECE
				   cLojaFor  := cLojaF                      //M->E2_LOJA
				   nMoedSubs := SimbToMoeda(cMoeda)         //M->E2_MOEDA
				   nValorS   := nValor                      //M->E2_VLCRUZ
				   cEMISSAO  := SW6->W6_DT_HAWB             //M->E2_EMISSAO
				   cDtVecto  := dDataVenc                   //M->E2_VENCTO
				   nTxMoeda  := nTaxa                       //M->E2_TXMOEDA
				   cHistorico:= "Proc:"+ALLTRIM(SW6->W6_HAWB)+"-"+SYB->YB_DESCR //M->E2_HIST
				   cParcela  := EasyGetParc()  //Chr(nChr + 1)//FI400TamCpoParc(nChr,nParc) //DFS - 29/09/11 - Chamada da função que verifica o tamanho do campo parcela e preenche corretamente.
				   IF cDesp == "102" .AND. !EMPTY(SW6->W6_PREFIXF+SW6->W6_NUMDUPF+SW6->W6_PARCELF+SW6->W6_TIPOF)
					  cPrefixo := SW6->W6_PREFIXF
					  cIniDocto:= SW6->W6_NUMDUPF
					  cParcela := SW6->W6_PARCELF
					  cTIPO_Tit:= SW6->W6_TIPOF  
				   ELSEIF cDesp == "103" .AND. !EMPTY(SW6->W6_PREFIXS+SW6->W6_NUMDUPS+SW6->W6_PARCELS+SW6->W6_TIPOS)
					  cPrefixo := SW6->W6_PREFIXS
					  cIniDocto:= SW6->W6_NUMDUPS
					  cParcela := SW6->W6_PARCELS
					  cTIPO_Tit:= SW6->W6_TIPOS  
				   ENDIF
				   // Bete - 28/07/05 - Se o retorno da SimbToMoeda for 0, significa que a moeda nao esta cadastrada em um dos MV_SIMBs.               
				   IF nMoedSubs == 0
					  MSGSTOP("Nao e possivel a geracao do titulo de "+IIF(cDesp=="102","frete","seguro")+"! A moeda: " + cMoeda + " nao esta configurada no Financeiro!")
				   ELSEIF FI400TITFIN("SW6_"+cDesp,"2")  // Inclusao SE2         
					  SE2->(DBGoTo(nRecSE2)) //ASR 08/02/2006
					  If SW6->(RecLock("SW6",.F.))
						 aOrdSWD:= SaveOrd("SWD")
						 SWD->(DbSetOrder(1))
						 IF cDesp == "102"
							SW6->W6_PREFIXF := SE2->E2_PREFIXO
							SW6->W6_NUMDUPF := SE2->E2_NUM    
							SW6->W6_PARCELF := SE2->E2_PARCELA
							SW6->W6_TIPOF   := SE2->E2_TIPO
							SW6->W6_FORNECF := SE2->E2_FORNECE
							SW6->W6_LOJAF   := SE2->E2_LOJA
							
							//TRP - 02/02/2012 - Atualizar o campo Gera Financeiro para as despesas de Frete e Seguro quando título gerado.
							IF SWD->(DbSeek(xFilial("SWD")+ SW6->W6_HAWB + "102"))
							   IF !Empty(SW6->W6_NUMDUPF)
								  IF SWD->WD_GERFIN <> "1"
									 Reclock("SWD",.F.)
									 SWD->WD_GERFIN:= "1"
									 SWD->(MsUnlock())
								  ENDIF
							   ENDIF
							Endif     
						 
						 ELSEIF cDesp == "103"
							SW6->W6_PREFIXS := SE2->E2_PREFIXO
							SW6->W6_NUMDUPS := SE2->E2_NUM    
							SW6->W6_PARCELS := SE2->E2_PARCELA
							SW6->W6_TIPOS   := SE2->E2_TIPO
							SW6->W6_FORNECS := SE2->E2_FORNECE
							SW6->W6_LOJAS   := SE2->E2_LOJA
						 
							//TRP - 02/02/2012 - Atualizar o campo Gera Financeiro para as despesas de Frete e Seguro quando título gerado.
							IF SWD->(DbSeek(xFilial("SWD")+ SW6->W6_HAWB + "103"))
							   IF !Empty(SW6->W6_NUMDUPS)
								  IF SWD->WD_GERFIN <> "1"
									 Reclock("SWD",.F.)
									 SWD->WD_GERFIN:= "1"
									 SWD->(MsUnlock())
								  ENDIF
							   ENDIF
							Endif 
						 
						 ENDIF
						 RestOrd(aOrdSWD,.T.)
						 SW6->(MsUnlock())
						 //IF SWD->(DBSEEK(cChaveSWD))  // LDR - 27/05/04    //NCF - 18/02/10 - Gravar Titulo no SWD para frete e seguro no embarque
						 //   SWD->(RECLOCK("SWD",.F.))
							lFretSegWD := !(SWD->(DBSEEK(cChaveSWD)))
							SWD->(RECLOCK("SWD",lFretSegWD))
							IF lFretSegWD 
							   SWD->WD_FILIAL  := xFilial("SWD") 
							   SWD->WD_HAWB    := SW6->W6_HAWB
							   SWD->WD_DESPESA := cDesp
							   SWD->WD_VALOR_R := nValorS
							   SWD->WD_DES_ADI := dDataVenc
							   SWD->WD_DTENVF  := dDataBase
							   SWD->WD_VALOR_R := nValorSWD
							   SWD->WD_BASEADI := "2"
							   SWD->WD_PAGOPOR := "2"
							   SWD->WD_GERFIN  := "1"   
							   SWD->WD_DTENVF  := dDataBase
							   If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0
								  SWD->WD_MOEDA   := cMoeda      // GFP - 17/09/2015
								  SWD->WD_VL_MOE  := nValor      // GFP - 17/09/2015
								  SWD->WD_TX_MOE  := nTaxa       // GFP - 17/09/2015
							   EndIf
							ENDIF
							SWD->WD_PREFIXO := SE2->E2_PREFIXO
							SWD->WD_CTRFIN1 := SE2->E2_NUM    
							SWD->WD_PARCELA := SE2->E2_PARCELA
							SWD->WD_TIPO    := SE2->E2_TIPO
							SWD->WD_FORN    := SE2->E2_FORNECE
							SWD->WD_LOJA    := SE2->E2_LOJA
							SWD->(MsUnlock())
						 //ENDIF
					  ENDIF
				   ENDIF
				ENDIF
			 ENDIF
		  ELSE   
			 nErroDup:=GeraDupEic(cDuplFin,; //Numero das duplicatas
						  nValor ,;          //Valor da duplicata
						  SW6->W6_DT_HAWB,;  //data de emissao//dDataBase
						  dDataVenc,;        //Data de vencimento
						  cMoeda  ,;         //Simbolo da moeda
						  "EIC",;            //Prefixo do titulo
						  "NF" ,;            //Tipo do titulo
						  1,;                //Numero de parcela.
						  cFornec,;          //Fornecedor
						  cLojaF,;           //Loja
						  "SIGAEIC",;    	 //Origem da geracao da duplicata (Nome da rotina)
						  "Proc:"+ALLTRIM(SW6->W6_HAWB)+" "+SYB->YB_DESCR,; //Historico da geracao
						  nTaxa,,SW6->W6_HAWB)             //Taxa da moeda (caso usada uma taxa diferente a
		  ENDIF
	   ENDIF
   EndIF
ENDIF

RETURN .T.

Function AvValidFre(cMsg_Erro,lFazdesp,cAliasSW6)
Local lRet      := .T.
Local aAreaSY4  := SY4->(GetArea())

Default cMsg_Erro := ""
Default lFazdesp  := .F.
Default cAliasSW6 := "SW6"

IF(EMPTY(&(cAliasSW6+"->W6_HOUSE"))  ,(cMsg_Erro+="House / B.L. não Informado!"+CHR(13)+CHR(10)  ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
IF(EMPTY(&(cAliasSW6+"->W6_FREMOED")),(cMsg_Erro+="Moeda Frete não Informada!"+CHR(13)+CHR(10)   ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
IF(EMPTY(&(cAliasSW6+"->W6_TX_FRET")),(cMsg_Erro+="Taxa Frete não Informada!"+CHR(13)+CHR(10)    ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
If !AvFlags("GERACAO_CAMBIO_FRETE")
        IF(EMPTY(&(cAliasSW6+"->W6_VENCFRE")),(cMsg_Erro+="Dt.Venc.Frete não Informada!"+CHR(13)+CHR(10) ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
EndIf
If AvFlags("GERACAO_CAMBIO_FRETE")
        IF(EMPTY(&(cAliasSW6+"->W6_CONDP_F")),(cMsg_Erro+="Condição de Pagamento não Informada!"+CHR(13)+CHR(10)    ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
EndIf
SY4->(dbSetOrder(1))//Y4_FILIAL + Y4_COD
IF !SY4->(DBSEEK(XFILIAL("SY4") + &(cAliasSW6+"->W6_AGENTE")))  // JBS - 10/05/2004
        cMsg_Erro+="Agente não Encontrado!"+CHR(13)+CHR(10)
        lFazdesp:=.f.
        lRet    := .F.
ELSE
        IF(EMPTY(SY4->Y4_FORN),(cMsg_Erro+="Fornecedor/Loja do Agente não Informado!"+CHR(13)+CHR(10) ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
ENDIF
RestArea(aAreaSY4)
Return lRet

Function AvValidSeg(cMsg_Erro,lFazdesp,cAliasSW6)
Local lRet      := .T.
Local aAreaSYW  := SYW->(GetArea())

Default cMsg_Erro := ""
Default lFazdesp  := .F.
Default cAliasSW6 := "SW6"

IF(EMPTY(&(cAliasSW6+"->W6_SEGMOED")),(cMsg_Erro+="Moeda do Seguro não Informada!"+CHR(13)+CHR(10)   ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
If !AvFlags("GERACAO_CAMBIO_SEGURO")
        IF(EMPTY(&(cAliasSW6+"->W6_VENCSEG")),(cMsg_Erro+="Dt.Venc.do seguro não Informada!"+CHR(13)+CHR(10) ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
EndIf
If AvFlags("GERACAO_CAMBIO_SEGURO")
        IF(EMPTY(&(cAliasSW6+"->W6_CONDP_S")),(cMsg_Erro+="Condição de Pagamento não Informada!"+CHR(13)+CHR(10)   ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
EndIf
SYW->(dbSetOrder(1))//YW_FILIAL + YW_COD
IF !SYW->(DBSEEK(XFILIAL("SYW") + &(cAliasSW6+"->W6_CORRETO"))) // JBS - 10/05/2004
        cMsg_Erro+="Corretor não Encontrado!"+CHR(13)+CHR(10)
        lFazdesp:= .f.
        lRet    := .F.
ELSE   
        IF(EMPTY(SYW->YW_FORN),(cMsg_Erro+="Fornecedor/Loja do Corretor não Informado!"+CHR(13)+CHR(10) ,lFazdesp:=.f.,lRet:=.F.),) // JBS - 10/05/2004
ENDIF
RestArea(aAreaSYW)
Return lRet

*-----------------------------------------------------------------------------------------------------------------*
Function AVImpostos(cDesp,cTipo,lRETURN)//AWR - 22/10/2004
*-----------------------------------------------------------------------------------------------------------------*
STATIC aCodValEII:={}
LOCAL nDespesa,cCodigo:="",lGeraFin:=.F.
LOCAL cMV_CODTXSI:= EasyGParam("MV_CODTXSI",,"415")

IF !GETNEWPAR("MV_TEM_DI",.F.) .OR. !EasyGParam("MV_EASYIMP",,.F.) .OR. cPaisLoc # "BRA"
   RETURN .F.
ENDIF 

IF EMPTY(aCodValEII)
   //                          aCodValEII:={ II  ,IPI ,PIS ,COFINS,Taxa SISCOMEX}
   cCod_EII:=ALLTRIM(GETNEWPAR("MV_COD_EII","2892,3345,5602,5629"))//7811

   DO WHILE !EMPTY(cCod_EII)
   
      nPos:=AT(',',cCod_EII)
      IF nPos # 0 
         AADD(aCodValEII,{SUBSTR(cCod_EII,1,nPos-1),.F.})
         cCod_EII:=SUBSTR(cCod_EII,nPos+1)
      ELSE
         AADD(aCodValEII,{cCod_EII,.F.})
         cCod_EII:=""
      ENDIF
       
   ENDDO

   AADD(aCodValEII,{"7811",.F.})//Taxa SISCOMEX

ENDIF

IF cDesp == "201"    // I.I.
   cCodigo :=aCodValEII[1,1]
   lGeraFin:=aCodValEII[1,2]
   nDespesa:=1

ELSEIF cDesp == "202"// I.P.I
   cCodigo :=aCodValEII[2,1]
   lGeraFin:=aCodValEII[2,2]
   nDespesa:=2

ELSEIF cDesp == "204"// PIS
   cCodigo :=aCodValEII[3,1]
   lGeraFin:=aCodValEII[3,2]
   nDespesa:=3

ELSEIF cDesp == "205"// COFINS
   cCodigo :=aCodValEII[4,1]
   lGeraFin:=aCodValEII[4,2]
   nDespesa:=4

ELSEIF cDesp == cMV_CODTXSI// Taxa SISCOMEX
   cCodigo :=aCodValEII[5,1]
   lGeraFin:=aCodValEII[5,2]
   nDespesa:=5

ELSE//IF cTipo == "DEPOIS_GRV"
   MsgInfo("Despesa "+cDesp+" nao disponivel para geracao de Titulos no finaceiro.")
   RETURN .F.
ENDIF

IF cTipo == "APAGA_IMP"
   IF M->W6_ADICAOK $ "N,2"
      RETURN .T.
   ENDIF
   RETURN lGeraFin
ENDIF

IF Work_EII->(DBSEEK(cCodigo))
   
   IF cTipo == "ANTES_GRV"

      aCodValEII[nDespesa,2]:=.F.
      IF M->W6_ADICAOK $ "N,2"
         lRETURN:= .T.// Variavel usada na funcao FI400DIAlterou(cHAWB,cTipo)
      ELSEIF !EMPTY(Work_EII->WK_RECNO)
         EII->(DBGOTO(Work_EII->WK_RECNO))
         IF !EMPTY(Work_EII->EII_VLTRIB)
            SWD->(DBSETORDER(1))
            IF EII->EII_VLTRIB # Work_EII->EII_VLTRIB .OR. !SWD->(DBSEEK(xFilial()+SW6->W6_HAWB+cDesp))
               aCodValEII[nDespesa,2] := .T.
               lRETURN:= .T.// Variavel usada ba funcao FI400DIAlterou(cHAWB,cTipo)
            ENDIF
         ENDIF
      ELSE
         aCodValEII[nDespesa,2] := .T.
         lRETURN:= .T.// Variavel usada ba funcao FI400DIAlterou(cHAWB,cTipo)
      ENDIF

      RETURN .T.

   ELSEIF cTipo == "DEPOIS_GRV"
   
      IF lGeraFin .AND. EMPTY(Work_EII->EII_VLTRIB)
         MsgInfo("Titulo da Despesa "+cDesp+" nao sera gerado porque o valor nao esta preenchido.")
         lGeraFin:=.F.
      ENDIF 

      IF lGeraFin
         dDataVenc := dDataBase
         nValor := nValorSWD:= Work_EII->EII_VLTRIB
         cFornec:= EasyGParam("MV_FORNIMP",,"")// AWR - Ja esta validado na funcao AVF ValidaImp()
         cFornec:= cFornec+SPACE(LEN(SA2->A2_COD)-LEN(cFornec))
         cLojaF := EasyGParam("MV_LOJAIMP",,"")// AWR - Ja esta validado na funcao AVF ValidaImp()
         IF lAutomatico
            IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"//AVGERAL.PRW
               cIniDocto := AvgNumSeq("SWD","WD_CTRFIN1")
            ELSE
               If EasyGParam("MV_EICNUMT",,"1") == "2"
                  cIniDocto := GetSXENum("SE2","E2_NUM")
               Else
                  cIniDocto := GetSXENum("SWD","WD_CTRFIN1")
               EndIf
               ConfirmSX8()
            ENDIF
         ENDIF

         RETURN .T.
      ELSE
         nValor:=nValorSWD:=0
      ENDIF   

   ENDIF   

ENDIF

RETURN .F.

*-----------------------------------------------------------------------------------------------------------------*
Function AVFValidaImp()//AWR - 25/10/2004
*-----------------------------------------------------------------------------------------------------------------*
LOCAL cFornec,cLojaF

IF !GETNEWPAR("MV_TEM_DI",.F.) .OR. !EasyGParam("MV_EASYIMP",,.F.) .OR. cPaisLoc # "BRA"
   RETURN .F.
ENDIF 

IF SW6->W6_ADICAOK $ "N,2"
   MSGSTOP("Titulos de Impostos nao serao gerados porque as Adicoes nao estao OK.")
// RETURN .T.
ENDIF

cFornec:= EasyGParam("MV_FORNIMP",,"")
cFornec:= cFornec+SPACE(LEN(SA2->A2_COD)-LEN(cFornec))
cLojaF := EasyGParam("MV_LOJAIMP",,"")

IF EMPTY(cFornec) .OR. EMPTY(cLojaF)
   MsgInfo("Titulos dos Impostos nao serao gerados porque o Fornecedor no Arquivo de Parametro (SX6) esta incorreto.",;
           "Parametros: MV_FORNIMP e MV_LOJAIMP")
   RETURN .F.
ENDIF 

IF !SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF))
   MsgInfo("Titulos dos Impostos nao serao gerados porque o Fornecedor no Arquivo de Parametro (SX6) nao foi encontrado no Cadastrado de Fornecedores.",;
           "Parametros: MV_FORNIMP e MV_LOJAIMP")
   RETURN .F.
ENDIF 

cCod_EII:=ALLTRIM(GETNEWPAR("MV_COD_EII","2892,3345,5602,5629"))
IF LEN(cCod_EII) # LEN("2892,3345,5602,5629")
   MsgInfo("Os codigos de debitos do SISCOMEX nao estao corretos no Arquivo de Parametro (SX6).",;
           "Parametro: MV_COD_EII")
   RETURN .F.
ENDIF 

RETURN .T.

/*
Função     : AV_FSNUM()
Parâmetros : cDesp - Despesa em processamento
Retorno    : lRet = .T. ou .F.
Objetivos  : Verificação das despesas de frete e seguro no WD. Se existirem e forem provenientes de numerário, retorna .T.
Autor      : Caio César Henrique
Data/Hora  : 28/07/2009 - 11:55 
*/

*-------------------------*
Static Function AV_FSNUM(cDesp)
*-------------------------*

Local aOrd := SaveOrd("SWD")
Local lRet := .F.                     
Local cDespProc := ""              
Local cProcW6 := If(!Empty(SW6->W6_HAWB),SW6->W6_HAWB,)

SWD->(DbSetOrder(1))

If !Empty(cDesp) .and. cDesp $ "102,103"                                 

   cDespProc := Posicione("SWD",1,xFilial("SWD")+cProcW6+cDesp,"WD_DESPESA")  
   
   If SWD->WD_FILIAL == xFilial("SWD") .and. !Empty(cDespProc) .and. !Empty(SWD->WD_CODINT)   
      lRet := .T. 
   EndIf 

EndIf                                                                                         

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : EasyGetParc()
Parâmetros : nParcela - Número da Parcela
Retorno    : cParcela - Parcela convertida conforme parametro MV_1DUP
Objetivos  : Tratamento para conversão correta da parcela de títulos conforme parametro MV_1DUP
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 20/01/2014 :: 10:11
*/

*-----------------------------*
Function EasyGetParc(nParcela)
*-----------------------------*
Local nTamCpoParc := AVSX3("E2_PARCELA",3)
Local cParcela := ""
Default nParcela := 1

Begin Sequence 
   
   If nParcela <> 1  // Tratamento para a segunda parcela em diante, pois a primeira parcela leva o conteudo do parametro.
      cParcela := SomaIt(cUltParc)
   Else
      If cModulo == "ESS" .Or. nModulo == 85 //wfs
            cParcela:= Strzero(nParcela,AVSX3("EEQ_PARC",3)) // LRS - 28/09/2015
      Else
         cParcela := EasyGParam("MV_1DUP",.F.,"A")
	      If Len(AllTrim(cParcela)) > nTamCpoParc // Tamanho da Parcela e o parâmetro devem estar em conformidade de tamanho. //MCF - 09/10/2015
	         /*MsgAlert(STR0148 + ENTER +;
	                STR0149 ,STR0004) // "Parâmetro MV_1DUP configurado incorretamente." ### "Favor verificar." ### "Atenção"*/
	         Help(" ",1,"AVG0005385") // MCF - 15/04/2015 - "O parâmetro MV_1DUP está 
	                                   //configurado incorretamente e irá gerar o(s) titulo(s) no módulo do Financeiro(SIGAFIN)."
	         
	      EndIF
      EndIf
   EndIf
   
   If Empty(cParcela) //LGS-02/09/2014
   	  cParcela := EasyGParam("MV_1DUP",.F.,"A")
   EndIf
   
   cUltParc := cParcela

End Sequence

Return cParcela

/*
Função     : EasyVal1Dup()
Parâmetros : cConteudo - Valor verificador - "A" para alfanumerico / "1" para numerico.
Retorno    : lRet = .T./.F.
Objetivos  : Validação do parametro MV_1DUP conforme conteudo e tamanho da parcela no ambiente.
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 20/01/2014 :: 15:10
*/

*-----------------------------*
Function EasyVal1Dup(cConteudo)
*-----------------------------*
Local nTamCpoParc := AVSX3("E2_PARCELA",3)
Local nTam1Dup := Len(Alltrim(EasyGParam("MV_1DUP",.F.,"A")))
Local nTamParcEEQ := AVSX3("EEQ_PARC",3) //LRS - 23/01/2018
Local lRet := .F.
Local cCaracter:= "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/Y/Z"
Local cNumeric := "1/2/3/4/5/6/7/8/9/0"
Local nTamDobro := Len(Alltrim(EasyGParam("MV_1DUP",.F.,"A"))) * 2 //LRS - 23/01/2018
Default cConteudo := "A"

Begin Sequence 
   
   IF Left(EasyGParam("MV_1DUP",.F.,"A"),1) $ cNumeric .OR. nModulo == 17
      If nTam1Dup <= nTamCpoParc
         IF nModulo <> 17 .And. nTamParcEEQ < nTamCpoParc
            MsgAlert(STR0166,STR0004)
            //"Ajustar grupo de campos 'Parcelas de câmbio' deixando com o mesmo tamanho do E2_PARCELA e revisar o parâmetro MV_1DUP"
            Break
         EndIF
         If cConteudo $ EasyGParam("MV_1DUP",.F.,"A")
            lRet := .T.
         EndIf 
      Else
         MsgAlert(STR0148 + ENTER +;
                 STR0149 ,STR0004) // "Parâmetro MV_1DUP configurado incorretamente." ### "Favor verificar." ### "Atenção"
      EndIf
   ElseIF Left(EasyGParam("MV_1DUP",.F.,"A"),1) $ cCaracter
      IF nTamParcEEQ >= nTamDobro
         lRet := .T.
      Else 
         MsgAlert(STR0167,STR0004)
         //Ajustar grupo de campos 'Parcelas de câmbio' deixando com o dobro do tamanho do conteúdo do MV_1DUP.
      EndIF
   EndIF

End Sequence

Return lRet

/*
Função     : AVDTFINVAL()
Parâmetros : cDesp - Despesa em processamento
Retorno    : lRet = .T. ou .F.
Objetivos  : Validação do Parametro MV_DATAFIN para a Function GERADUPEIC
Autor      : LUCAS RAMINELLI - LRS
Data/Hora  : 13/04/2018
*/

*--------------------*
Function AVDTFINVAL()
*--------------------*


Local lRet := !(EasyGParam("MV_EASYFIN",,"N") == "S" .And. !DtMovFin())                     
  
/* OSSME-6483 MFR-10/01/2022
If EasyGParam("MV_EASYFIN",,"N") == "S" .And. EasyGParam("MV_DATAFIN") > dDataBase 
  //Help( " ", 1, "DTMOVFIN") // Nao sao permitidas movimentacoes financeiras com datas menores que a data limite de movimentacao no financeiro
  // na função DtMovFin do fonte finxfin.prx já tem esse mesmo help
   lRet := .F.
EndIF
*/
Return lRet


Static Function EXCFreSeg(cHawb,cDesp)
Local lRet := .F.
Local cNBS := ""
Local aAreaSWD := SWD->(GetArea())

If cDesp == DESP_FRETE //102
   lRet := (M->W6_FORNECF <> SW6->W6_FORNECF .OR. M->W6_LOJAF <> SW6->W6_LOJAF .OR. M->W6_TX_FRET <> SW6->W6_TX_FRET .OR. M->W6_VENCFRE <> SW6->W6_VENCFRE .OR. M->W6_VLFRECC <> SW6->W6_VLFRECC)
ElseIf cDesp == DESP_SEGURO //103
   lRet := (M->W6_FORNECS <> SW6->W6_FORNECS .OR. M->W6_LOJAS <> SW6->W6_LOJAS .OR. M->W6_TX_SEG <> SW6->W6_TX_SEG .OR. M->W6_VENCSEG <> SW6->W6_VENCSEG .OR. M->W6_VL_USSE <> SW6->W6_VL_USSE)
EndIf
//Se lRet for .T., não precisa verificar mais, pois o título ja deve ser excluído
If !lRet .And. EasyGParam("MV_ESS0022",,.T.) //Integração com o Siscoserv habilitada

   cNBS := EICTemNBS(cDesp,M->W6_VIA_TRA)
   SWD->(dbSetOrder(1)) //WD_FILIAL + WD_HAWB + WD_DESPESA + WD_DES_ADI
   If !Empty(cNBS) .And. SWD->(dbSeek(xFilial("SWD") + cHawb + cDesp))
      If cDesp == DESP_FRETE //102
         lRet := SWD->WD_MOEDA # M->W6_FREMOED .and. SWD->WD_TX_MOE # M->W6_TX_FRET .and. SWD->WD_VL_MOE <> M->W6_VLFRECC
      ElseIf cDesp == DESP_SEGURO //103
         lRet := SWD->WD_MOEDA  # M->W6_SEGMOED .and. SWD->WD_TX_MOE # M->W6_TX_SEG .and. SWD->WD_VL_MOE <> M->W6_VL_USSE
      EndIf
   EndIf

EndIf

RestArea(aAreaSWD)

Return lRet
//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA AVFLUXO.PRW
//------------------------------------------------------------------------------------//
