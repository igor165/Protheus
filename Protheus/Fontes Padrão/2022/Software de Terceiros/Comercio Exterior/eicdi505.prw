//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EICDI510()
//Autor.....: Leandro Delfino (LDR)
//Data......: 24 de Agosto de 2004, 15:10
//Uso.......: SIGAEIC
//Versao....: Protheus - 7.10
//Descricao.: O EICDI500 excedeu o tamanho de caracteres.
//------------------------------------------------------------------------------------//
#INCLUDE "Eicdi505.ch"
#include "Average.ch"
#Include "APWizard.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.ch"
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define COLUNA_FINAL_I (oDlgItens:nClientWidth-4)/2
#define TAM_DESC_I   65

#define FECHTO_EMBARQUE       "1"
#define FECHTO_DESEMBARACO    "2"
#define FECHTO_NACIONALIZACAO "3"

#define FINALIZAR (nOpca:=1,oDlg:End())
#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5

#define SIM     "1"
#define NAO     "2"

#define GENERICO     "06"
#define NCM_GENERICA "99999999"

*-------------------------------------------------------------*
Function DI500ImpRel(Cabec1,Cabec2,Titulo,nLin,lImpAdicao)
*-------------------------------------------------------------*
Local cFilAux, cFilAux2, cUtil, aTotais, aDespesa, i,j, nSomaICMS:=0, cAux
Local nPos, lPVez:=.T., cInvoice:="", aIncoterm := {}, x
Local bCampo1:=&("{||"+AVSX3('W6_MODAL_D',14)+"}")
Local bCampo2:=&("{||"+AVSX3('W6_TIPODOC',14)+"}")
LOCAL nTaxa:=nVMLE:=nCIF:=nBaseII:=nBaseIPI:=nValorII:=nValorIPI:=nBasePC:=0
LOCAL aCbox:={},aCbox2:={},nVLAC:=0,nVLDC:=0,nPOS1:=0,nAD:=0
LOCAL nLines
Local VlAntDumpTot,nVlrDumpA,nVlrDumpE // BHF - 23/01/09
Local cTipPagto := "" //CCH - 17/11/08 - Utilizada nos dados de câmbio
Local nTotVLMLEA := 0 //CCH - 19/12/08 - Variável utilizadas na exibição dos Totais dos Acréscimos
Local nTotVLMMNA := 0 //CCH - 19/12/08 - Variável utilizadas na exibição dos Totais dos Acréscimos
Local nTotVLMLED := 0 //CCH - 19/12/08 - Variável utilizadas na exibição dos Totais dos Deduções
Local nTotVLMMND := 0 //CCH - 19/12/08 - Variável utilizadas na exibição dos Totais dos Deduções
Local nTotPgV    := 0 //CCH - 23/12/08 - Variável utilizadas na exibição dos Totais dos Pagamentos à Vista no Câmbio
Local nTotPgA    := 0 //CCH - 23/12/08 - Variável utilizadas na exibição dos Totais dos Pagamentos Antecipados no Câmbio
Local nAliqICMSA := 0
PRIVATE nVlOutDesp:=nTOTVLMMN:=0
PRIVATE lDesvio:=.F.
PRIVATE nLin2 := nLin
Private mMemo :=""
Private cMemo :="" //igor chiba 19/02/2010

cMoeDolar := BuscaDolar()
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DESVIA_REL"),)

IF lDesvio // LDR - 06/07/04
   RETURN .T.
ENDIF

SW7->(dbSetOrder(1))
SJB->(dbSetOrder(1))
SW2->(dbSetOrder(1))
SYT->(dbSetOrder(1))
SJP->(dbSetOrder(1))

SW7->(dbSeek(xFilial("SW7")+SW6->W6_HAWB))
SJB->(dbSeek(xFilial("SJB")+SW6->W6_TIPODES))
SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
SYT->(dbSeek(xFilial("SYT")+SW2->W2_IMPORT))

nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0001 //	STR0001	"INFORMACOES BASICAS CAPA - IMPORTADOR"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0002 + SW6->W6_HAWB + Space(5) + STR0003 +DtoC(SW6->W6_DT) //STR0002	 "Ref. do Cliente    : "//STR0003	 "Data processo: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0004+ SW6->W6_TIPODES + " - " + SJB->JB_DESCR //STR0004	 "Tipo de Declaracao : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0005 + SYT->YT_NOME //STR0005	"Importador         : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0006 + SYT->YT_CGC + Space(7)+ STR0007 + SW6->W6_CGC_OUT //STR0006	 "CGC                : " //STR0007	Consignatário"
nLin := SomaLinha(nLin,1)
If SYT->(FieldPos("YT_COMPEND")) > 0   // TLM 09/06/2008 - Incluído o complemento do endereço, tabela SYT
	   @nLin,01 PSAY STR0008+ Alltrim(SYT->YT_ENDE) + ", " + IF(!Empty(SYT->YT_COMPEND),Alltrim(SYT->YT_COMPEND) + ", ","") + Alltrim(Str(SYT->YT_NR_END)) //STR0008	"Endereco Importador: "
Else
@nLin,01 PSAY STR0008+ Alltrim(SYT->YT_ENDE) + ", " + Alltrim(Str(SYT->YT_NR_END)) //#define	STR0008	"Endereco Importador: "
EndIf
nLin  := nLin + 1
@nLin,01 PSAY STR0009 + SYT->YT_CIDADE //"Cidade Importador  : " //* STR0009	"Cidade Importador  : "*/
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0010 + SW6->W6_MODAL_D+" - "+EVAL(bCampo1)//BSCXBOX("W6_MODAL_D",Alltrim(SW6->W6_MODAL_D)) //"Mod. Despacho      : " //STR0010	//"Mod. Despacho      : "
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0011 //STR0011	"PROCESSOS VINCULADOS"
cFilAux := xFilial("EIG")
EIG->(dbSetOrder(1))
EIG->(dbSeek(cFilAux+SW6->W6_HAWB))
Do While !EIG->(EOF()) .and. EIG->EIG_HAWB == SW6->W6_HAWB .and. EIG->EIG_FILIAL == cFilAux
   nLin := SomaLinha(nLin,1)
   @nLin,01 PSAY EIG->EIG_CODIGO + " - " + EIG->EIG_NUMERO
   EIG->(dbSkip())
EndDo
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

SYQ->(dbSetOrder(1))
SA4->(dbSetOrder(1))
SYA->(dbSetOrder(1))
SY9->(dbSetOrder(2))

SYQ->(dbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA))
SA4->(dbSeek(xFilial("SA4")+SW6->W6_TRANSIN))
SYA->(dbSeek(xFilial("SYA")+SW6->W6_PAISVEI))
SY9->(dbSeek(xFilial("SY9")+SW6->W6_LOCAL))
EE6->(dbSeek(xFilial("EE6")+SW6->W6_IDENTVE)) // TDF - 03/10/11
cUtil := If(SW6->W6_UTILCON=="1",STR0012,If(SW6->W6_UTILCON=="2",STR0013,If(SW6->W6_UTILCON=="3",STR0014,""))) // STR0012	 "Total"	// STR0013	"Parcial" //STR0014	"Mais de um"
@nLin,01 PSAY STR0351 //"TRANSPORTE"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0015 + SW6->W6_VIA_TRA + " - " + SYQ->YQ_DESCR //STR0015	 "Via de Transporte: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0016 + Alltrim(SW6->W6_TRANSIN) + " - " + SA4->A4_NOME //STR0016	 "Transportador    : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0017 + SW6->W6_PAISVEI + " - " + SYA->YA_DESCR  //STR0017	"Bandeira         : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0018 +SW6->W6_TIPODOC+" - "+EVAL(bCampo2)//BSCXBOX("W6_TIPODOC",Alltrim(SW6->W6_TIPODOC)) ////STR0018	"Tipo de Manifesto: "
@nLin,44 PSAY STR0019 + SW6->W6_IDEMANI  // LDR  //STR0019	"Num. Manifesto : "
nLin := SomaLinha(nLin,1)

// TDF - 03/10/11 - Impressão do código mais nome do navio
//@nLin,01 PSAY STR0361 + Left(SW6->W6_IDENTVE,23) + STR0362 //"Nome do Veiculo  : "###" Placa: "
@nLin,01 PSAY STR0020 + Alltrim(EE6->EE6_COD)+" - "+Alltrim(EE6->EE6_NOME) //"Nome do Veiculo

nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0022 + SW6->W6_TIPOCON+" - "+If(SX5->(dbSeek(xFilial("SX5")+"47"+SW6->W6_TIPOCON)),X5Descri(),"")  //STR0022	"Docto. de Carga  : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0023 + SW6->W6_HOUSE + Space(6) + STR0024 + SW6->W6_MAWB// STR0023	"Identificacao    //STR0024	"Master: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0025 + SW6->W6_PRCARGA // STR0025	"Pres. de Carga   : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0026 + DtoC(SW6->W6_DT_EMB) + Space(16) + STR0027 + cUtil //STR0026	"Emissao          : ""//SW6->W6_DT_HAWB //STR0027	"Utilizacao: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0028 + SW6->W6_LOCAL + " - " + SY9->Y9_DESCR  //STR0028	"Local            : "          : "
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

SYR->(dbSetOrder(1))
SJ0->(dbSetOrder(1))
SY4->(dbSetOrder(1))
SY5->(dbSetOrder(1))
SJA->(dbSetOrder(1))
EIH->(dbSetOrder(1))
EIF->(dbSetOrder(1)) //CCH - 13/11/08 - Inclusão dos Dados da Instrução de Despacho
EIJ->(dbSetOrder(1)) //CCH - 13/11/08 - Inclusão do Acordo Tarifário do II
SJI->(dbSetOrder(1)) //CCH - 13/11/08 - Inclusão do Acordo Tarifário do II - Tipo
SJJ->(dbSetOrder(1)) //CCH - 13/11/08 - Inclusão do Acordo Tarifário do II - Orgão
EIM->(dbSetOrder(2)) //CCH - 13/11/08 - Dados da NVE - Classificação
SJK->(dbSetOrder(1)) //CCH - 14/11/08 - Dados da NVE - Atributos
SJL->(dbSetOrder(1)) //CCH - 14/11/08 - Dados da NVE - Especificação
EIO->(dbSetOrder(1)) //CCH - 14/11/08 - Dados do Câmbio
EIK->(dbSetOrder(1)) //TRP - 22/05/09

SYA->(dbSeek(xFilial("SYA")+SW6->W6_PAISPRO))
SJG->(dbSeek(xFilial("SJG")+SW6->W6_REC_ALF+SW6->W6_SETORRA))
SJ0->(dbSeek(xFilial("SJ0")+SW6->W6_URF_ENT))
SY4->(dbSeek(xFilial("SY4")+SW6->W6_AGENTE))
SY5->(dbSeek(xFilial("SY5")+SW6->W6_DESP))
SJA->(dbSeek(xFilial("SJA")+SW6->W6_REC_ALF))
EIH->(dbSeek(xFilial("EIH")+SW6->W6_HAWB))
EIF->(dbSeek(xFilial("EIF")+SW6->W6_HAWB))  //CCH - 13/11/08
EIJ->(dbSeek(xFilial("EIJ")+SW6->W6_HAWB))  //CCH - 13/11/08

SW7->(dbSetOrder(4))
SW8->(dbSetOrder(1))
SW8->(dbSeek(xFILIAL("SW8")+SW6->W6_HAWB))
nVlTotPesoL:=0
nValorPIS:=nValorCON:=0
DO While !SW8->(Eof()) .AND.  SW8->W8_FILIAL==xFILIAL("SW8").AND.	 SW8->W8_HAWB  == SW6->W6_HAWB

   SW7->(DBSEEK(xFILIAL("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
   SB1->(dbSeek(xFILIAL("SB1")+SW8->W8_COD_I))
   IF ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim// LDR - 25/08/04
      nVlTotPesoL+= SW8->W8_QTDE * SB1->B1_QTMIDIA * SW7->W7_PESOMID
   ELSE
      nVlTotPesoL+= SW8->W8_QTDE*SW7->W7_PESO
   ENDIF

   IF SW8->(FIELDPOS("W8_VLRPIS")<>0) .AND. SW8->(FIELDPOS("W8_VLRCOF")<>0)
      nValorPIS+=SW8->W8_VLRPIS
      nValorCON+=SW8->W8_VLRCOF
   ENDIF

   SW8->(DBSKIP())

ENDDO

@nLin,01 PSAY STR0029 //"CARGA" //STR0029	"CARGA"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0030 + DtoC(SW6->W6_CHEG) //"Data de Chegada     : " //STR0030	"Data de Chegada     : "
nLin := SomaLinha(nLin,1)

@nLin,01 PSAY STR0031 + Trans(nVlTotPesoL,AVSX3("W6_PESOL",6)) + Space(9) +;  //STR0031	"Peso Liquido        : "
              STR0032 + Trans(SW6->W6_PESO_BR,AVSX3("W6_PESO_BR",6)) //STR0032	"Peso Bruto: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0033 + SW6->W6_PAISPRO + " - " + SYA->YA_DESCR //#define	STR0033	"Pais de Procedencia : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0034 + SW6->W6_AGENTE + " - " + SY4->Y4_NOME // STR0034	"Agente Transp.      :
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0035 + SW6->W6_URF_ENT + " - " + SJ0->J0_DESC //STR0035	"URF de Entrada      : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0036 + SW6->W6_DESP + " - " + SY5->Y5_NOME //STR0036	"Despachante SDA     : "
nLin := SomaLinha(nLin,1)
SJ0->(dbSeek(xFilial("SJ0")+SW6->W6_URF_DES))
@nLin,01 PSAY STR0037 + SW6->W6_URF_DES + " - " + SJ0->J0_DESC //STR0037	"URF de Despacho     : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0038 + SW6->W6_REC_ALF + " - " + Left(SJA->JA_DESCR,47) // STR0038	 "Recinto Alfandegario: "
If Len(Alltrim(SJA->JA_DESCR)) > 47
nLin := SomaLinha(nLin,1)
   @nLin,33 PSAY Right(SJA->JA_DESCR,Len(SJA->JA_DESCR)-47)
EndIf
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0039 + SW6->W6_SETORRA + " - " + Left(SJG->JG_DESC,51) //STR0039	"Setor               : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0040 + Space(7) + AVSX3("W6_VOLUMES",5) //"Volumes" //STR0040	"Armazens"
@nLin,70 PSAY AVSX3("EIH_QTDADE",5)// "Quantidade"
cFilAux  := xFilial("EIH")
cFilAux2 := xFilial("SJF")
SJF->(dbSetOrder(1))
Do While !EIH->(EOF()) .and. EIH->EIH_HAWB == SW6->W6_HAWB .and. cFilAux == EIH->EIH_FILIAL
   nLin := SomaLinha(nLin,1)
   SJF->(dbSeek(cFilAux2+EIH->EIH_CODIGO))
   @nLin,01 PSAY SW6->W6_ARMAZEM + Space(5) + EIH->EIH_CODIGO+" - "+Alltrim(SJF->JF_DESC)
   @nLin,70 PSAY Alltrim(Str(EIH->EIH_QTDADE))
   EIH->(dbSkip())
EndDo
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
//CCH - 13/11/08
SJE->(dbSetOrder(1))

@nLin,01 PSAY Upper(STR0041) //STR0041	 "Instrucoes de Despacho"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0042; @nLin,20 PSAY STR0043; @nLin,54 PSAY STR0044 //STR0042	"Codigo 	//STR0043	"Descrição" //STR0044	"Documento"

Do While !EIF->(EOF()) .and. EIF->EIF_HAWB == SW6->W6_HAWB .and. xFilial("EIF") == EIF->EIF_FILIAL
   SJE->(dbSeek(xFilial("SJE")+EIF->EIF_CODIGO))
   nLin := SomaLinha(nLin,1)
      If Len(RTrim(SJE->JE_DESC)) > 33
         @nLin,01 PSAY EIF->EIF_CODIGO + Space(17) + ALLTRIM(SubStr(SJE->JE_DESC,1,33)) + Space(1) + ALLTRIM(EIF->EIF_DOCTO)
         nLin := SomaLinha(nLin,1)
         @nLin,01 PSAY Space(19) + ALLTRIM(SubStr(SJE->JE_DESC,34,64))
      Else
         @nLin,01 PSAY EIF->EIF_CODIGO + Space(17) + ALLTRIM(SJE->JE_DESC) + Space(18) + ALLTRIM(EIF->EIF_DOCTO)
      EndIf
   EIF->(dbSkip())
EndDo

// GFP - 10/06/2013 - Tratamento para DE Mercosul
If EJ9->(dbSeek(xFilial("EJ9")+SW6->W6_HAWB))
   nLin := SomaLinha(nLin,1)
   @nLin,0 PSAY __PrtThinLine()
   nLin := SomaLinha(nLin,1)
   @nLin,01 PSAY Upper(STR0379) //STR0379	 "Declaração de Exportação Mercosul"
   nLin := SomaLinha(nLin,1)
   @nLin,01 PSAY STR0380; @nLin,28 PSAY STR0381; @nLin,54 PSAY STR0382 //STR0380	"DE Mercosul" 	//STR0381	"RE Inicial" //STR0382	"RE Final"
   
   Do While !EJ9->(EOF()) .and. EJ9->EJ9_HAWB == SW6->W6_HAWB .and. xFilial("EJ9") == EJ9->EJ9_FILIAL
      nLin := SomaLinha(nLin,1)
      @nLin,01 PSAY EJ9->EJ9_DEMERC + Space(12) + EJ9->EJ9_REINIC + Space(22) + EJ9->EJ9_REFINA
      EJ9->(dbSkip())
   EndDo
EndIf

nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

aTotais  := ConvInvMoeda(SW6->W6_HAWB)
aDespesa := ConvDespFobMoeda(SW6->W6_HAWB,,,"TUDO")
@nLin,01 PSAY STR0045 //STR0045	"TOTAIS"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0046+Alltrim(Str(SW6->W6_QTD_ADI)) //STR0046	"Numero de Adições: "
nLin := SomaLinha(nLin,1)
//nLin := SomaLinha(nLin,1)
SYF->(dbSetOrder(1))
cFilAux:=xFilial("SYF")
For i:=1 to Len(aTotais)
   SYF->(dbSeek(cFilAux+aTotais[i,1]))
   If i=1
      @nLin,01 PSAY STR0047 //STR0047	"Moeda Mercadoria : "
      @nLin,21 PSAY SYF->YF_COD_GI + " - " + aTotais[i,1]
      @nLin,34 PSAY STR0048 //STR0048	"Valor: "
      @nLin,61 PSAY Trans(aTotais[i,2],"@E 999,999,999,999.99")
   Else
      @nLin,21 PSAY SYF->YF_COD_GI + " - " + aTotais[i,1]
      @nLin,61 PSAY Trans(aTotais[i,2],"@E 999,999,999,999.99")
   EndIf
   nLin := SomaLinha(nLin,1)
Next
@nLin,01 PSAY STR0049 //STR0049	"Valor c/ Despesas: "
If !Empty(aTotais) // - BHF - 28/10/08 - Verificação do conteúdo do vetor.
   For i:=1 to Len(aDespesa)
      For x:=1 to Len(aDespesa[i])
         nPos := aScan(aTotais,{|aTab|aTab[1]==aDespesa[i][x,1]})
         SYF->(dbSeek(cFilAux+aTotais[i,1]))
         @nLin,21 PSAY SYF->YF_COD_GI + " - " + aDespesa[i][x,1]
         @nLin,61 PSAY Trans(aDespesa[i][x,2]+aTotais[nPos,2],"@E 999,999,999,999.99")
         nLin := SomaLinha(nLin,1)
      Next
   Next
Else
   nLin := SomaLinha(nLin,1) // BHF - Implementa para não Imprimir por cima.
EndIf
@nLin,01 PSAY STR0050//STR0050	"Moeda Frete Total: "

SYF->(dbSeek(cFilAux+SW6->W6_FREMOED))
@nLin,21 PSAY SYF->YF_COD_GI + " - " + SW6->W6_FREMOED
nLin := SomaLinha(nLin,1)

@nLin,21 PSAY "Prepaid: " + Space(31) + Trans(SW6->W6_VLFREPP,AVSX3("W6_VLFREPP",6))
nLin := SomaLinha(nLin,1)
@nLin,21 PSAY "Collect: " + Space(31) +Trans(SW6->W6_VLFRECC,AVSX3("W6_VLFRECC",6))
nLin := SomaLinha(nLin,1)
@nLin,21 PSAY STR0051 + Space(19) + Trans(SW6->W6_VLFRETN,AVSX3("W6_VLFRETN",6)) // STR0051	"Territorio Nacional: "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0052 + Space(33) + Trans(SW6->W6_TX_FRET,AVSX3("W6_TX_FRET",6)) //STR0052	"Taxa de Conversao do Frete : "
nLin := SomaLinha(nLin,1)
SYF->(dbSeek(cFilAux+SW6->W6_SEGMOED))

@nLin,01 PSAY STR0053 + Space(06) + SYF->YF_COD_GI + " - " +SW6->W6_SEGMOED  //STR0053	"Moeda Seguro: "
@nLin,34 PSAY STR0054 + If(!SW6->(Empty(W6_SEGPERC)),STR0055,STR0048)+Space(13)+Trans(SW6->W6_SEGPERC,"@E 999.9999")+"%" //STR0054 "Tipo Seguro: " //STR0055 "Percentual" //STR0048"Valor"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0048 + Space(04) + Trans(SW6->W6_VL_USSE,"@E 999,999,999,999.99")	//"Valor: " //STR0048	"Valor"
@nLin,34 PSAY STR0056 + Trans(SW6->W6_TX_SEG,AVSX3("W6_TX_SEG",6)) //STR0056	"Taxa de Conversao do Seguro: "
nLin := SomaLinha(nLin,1)

nTaxa:=IF(EMPTY(SW6->W6_DTREG_D),SW6->W6_TX_US_D,BuscaTaxa(cMoeDolar,SW6->W6_DTREG_D,.T.,.F.,.T.))

cFilAux := xFilial("EIJ")
EIJ->(dbSeek(cFilAux+SW6->W6_HAWB))
Do While !EIJ->(EOF()) .and. EIJ->EIJ_HAWB == SW6->W6_HAWB .and. EIJ->EIJ_FILIAL == cFilAux
   IF EIJ->EIJ_ADICAO == "MOD"
      EIJ->(DBSKIP())
      LOOP
   ENDIF
   If aScan(aIncoterm,{|x| x[1] == EIJ->EIJ_INCOTE})=0 .OR. aScan(aIncoterm,{|x| x[2] == EIJ->EIJ_LOCVEN})=0
      aADD(aIncoterm,{EIJ->EIJ_INCOTE,EIJ->EIJ_LOCVEN})
   EndIf

   IF EIJ->EIJ_MOEDA = cMoeDolar
      nVMLE += EIJ->EIJ_VLMLE
      IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         nVMLE -= EIJ->EIJ_VLFRET
      ENDIF

      // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         nVMLE -= EIJ->EIJ_VSEGLE
      ENDIF

   ELSE
      nVMLE += EIJ->EIJ_VLMMN/nTaxa
      IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         nVMLE -= EIJ->EIJ_VFREMN/nTaxa
      ENDIF

      // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         nVMLE -= EIJ->EIJ_VSEGMN/nTaxa
      ENDIF
   ENDIF
   nTOTVLMMN+= EIJ->EIJ_VLMMN
   nBaseII  += EIJ->EIJ_BAS_II
   nBaseIPI += EIJ->EIJ_BASIPI
   nValorII += EIJ->EIJ_VLARII
   nValorIPI+= EIJ->EIJ_VLAIPI
   nSomaICMS+= EIJ->EIJ_VLICMS
   nBasePC  += EIJ->EIJ_BASPIS
   nAD ++
   EIJ->(dbSkip())
EndDo

nCIF:= nBaseII/nTaxa

@nLin,01 PSAY STR0057+Space(05)+Trans(nSomaICMS,"@E 999,999,999,999.99")+Space(4)+ STR0058 	//STR0057	"ICMS: " //STR0058	"Redução: "
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

For i:=1 to Len(aIncoterm)
   If i=1
      @nLin,01 PSAY STR0059//STR0059	"INCOTERM:"
      @nLin,12 PSAY aIncoterm[i,1]
      @nLin,17 PSAY STR0061 //"LOCAL: " //STR0061	"Local            : "
      @nLin,24 PSAY aIncoterm[i,2]
   Else
      @nLin,12 PSAY aIncoterm[i,1]
      @nLin,24 PSAY aIncoterm[i,2]
   EndIf
   nLin := SomaLinha(nLin,1)
Next
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

cFilAux := xFilial("EIN")
EIN->(dbSetOrder(1))
@nLin,01 PSAY STR0062 //"ACRESCIMOS" //STR0062	"ACRESCIMOS"
nLin := SomaLinha(nLin,1)
EIN->(dbSeek(cFilAux+SW6->W6_HAWB))
Do While !EIN->(EOF()) .and. EIN->EIN_HAWB == SW6->W6_HAWB .and. EIN->EIN_FILIAL == cFilAux
   If EIN->EIN_TIPO == "2" .OR. EIN->EIN_ADICAO = "MOD"
      EIN->(dbSkip())
      Loop
   EndIf
   If lPVez
      lPVez := .F.
      @nLin,01 PSAY AVSX3("EIN_CODIGO",5)//"Codigo"
      @nLin,09 PSAY AVSX3("EIN_DESC  ",5)//"Descricao"
      @nLin,42 PSAY AVSX3("EIN_FOBMOE",5)//"Moeda"
      nLin := SomaLinha(nLin,1)
      @nLin,48 PSAY AVSX3("EIN_VLMLE" ,5)//STR0399 //"Valor na Moeda"
      @nLin,65 PSAY AVSX3("EIN_VLMMN" ,5)//STR0400 //"Valor R$"
      nLin := SomaLinha(nLin,1)
   EndIf
   @nLin,01 PSAY EIN->EIN_CODIGO
   @nLin,09 PSAY Left(Alltrim(EIN->EIN_DESC),33)
   @nLin,43 PSAY EIN->EIN_FOBMOE
   @nLin,49 PSAY Trans(EIN->EIN_VLMLE,"@E 999999,999.99")//AWR - 06/2009 - Chamado P10
   @nLin,65 PSAY Trans(EIN->EIN_VLMMN,"@E 999,999,999.99")
   nTotVLMLEA += IF(EIN->EIN_FOBMOE=cMoeDolar,EIN->EIN_VLMLE,EIN->EIN_VLMMN/nTaxa)//AWR - 06/2009 - Chamado P10
   nTotVLMMNA += EIN->EIN_VLMMN
   nLin := SomaLinha(nLin,1)
   EIN->(dbSkip())
EndDo

nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0063 +cMoeDolar+STR0064//AWR - 06/2009 - Chamado P10 //STR0063	"Totais e  //STR0064	 " e Real"
@nLin,49 PSAY Trans(nTotVLMLEA,"@E 999999,999.99")//AWR - 06/2009 - Chamado P10
@nLin,65 PSAY Trans(nTotVLMMNA,"@E 999,999,999.99")
nLin := SomaLinha(nLin,1)
lPVez:=.T.
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0065 //"DEDUCOES" //STR0065	"DEDUCOES"
nLin := SomaLinha(nLin,1)
EIN->(dbSeek(cFilAux+SW6->W6_HAWB))
Do While !EIN->(EOF()) .and. EIN->EIN_HAWB == SW6->W6_HAWB .and. EIN->EIN_FILIAL == cFilAux
   If EIN->EIN_TIPO == "1" .OR. EIN->EIN_ADICAO = "MOD"
      EIN->(dbSkip())
      Loop
   EndIf
   If lPVez
      lPVez := .F.
      @nLin,01 PSAY AVSX3("EIN_CODIGO",5)//"Codigo"
      @nLin,09 PSAY AVSX3("EIN_DESC  ",5)//"Descricao"
      @nLin,42 PSAY AVSX3("EIN_FOBMOE",5)//"Moeda"
      nLin := SomaLinha(nLin,1)
      @nLin,48 PSAY AVSX3("EIN_VLMLE" ,5)//"Valor na Moeda"
      @nLin,65 PSAY AVSX3("EIN_VLMMN" ,5)//"Valor R$"
      nLin := SomaLinha(nLin,1)
   EndIf
   @nLin,01 PSAY EIN->EIN_CODIGO
   @nLin,09 PSAY Left(Alltrim(EIN->EIN_DESC),33)
   @nLin,43 PSAY EIN->EIN_FOBMOE
   @nLin,49 PSAY Trans(EIN->EIN_VLMLE,"@E 999999,999.99")//AWR - 06/2009 - Chamado P10
   @nLin,65 PSAY Trans(EIN->EIN_VLMMN,"@E 999,999,999.99")
   nTotVLMLED += IF(EIN->EIN_FOBMOE=cMoeDolar,EIN->EIN_VLMLE,EIN->EIN_VLMMN/nTaxa)//EIN->EIN_VLMLE//AWR - 06/2009 - Chamado P10
   nTotVLMMND += EIN->EIN_VLMMN
   nLin := SomaLinha(nLin,1)
   EIN->(dbSkip())
EndDo

nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0063 + cMoeDolar+STR0064//AWR - 06/2009 - Chamado P10 //STR0063	"Totais em " //STR0064	 " e Real"
@nLin,49 PSAY Trans(nTotVLMLED,"@E 999999,999.99")//AWR - 06/2009 - Chamado P10
@nLin,65 PSAY Trans(nTotVLMMND,"@E 999,999,999.99")
nLin := SomaLinha(nLin,1)

//- AWR 30/07/2002 ------------------------------------------//
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0066//"ADMISSAO TEMPORARIO"  STR0066	"Totais das adições"
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY "VMLE (US$)       : "+Trans(nVMLE+nTotVLMLEA-nTotVLMLED,"@E 999,999,999.99") //CCH - 05/01/09 - Nos valores totais da mercadoria devem ser incluídos os acréscimos e as deduções
@nLin,40 PSAY "VMLE (R$)        : "+Trans(DITRANS(((nVMLE*nTAXA)+nTotVLMMNA-nTotVLMMND)),"@E 999,999,999.99")
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY "CIF (US$)        : "+Trans(nCIF,"@E 999,999,999.99")
@nLin,40 PSAY "CIF (R$)         : "+Trans(DITRANS(nCIF*nTAXA),"@E 999,999,999.99")//Leandro
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0067 + Trans(nBaseII,"@E 999,999,999.99") //STR0067	"Base I.I. (R$)   : "
@nLin,40 PSAY STR0068 + Trans(nValorII,"@E 999,999,999.99") //STR0068	"Valor I.I. (R$)  : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0352 + Trans(nBaseIPI,"@E 999,999,999.99")//STR0067	"Base I.P.I. (R$)   : "
@nLin,40 PSAY STR0353 + Trans(nValorIPI,"@E 999,999,999.99") //STR0068	"Valor I.P.I. (R$)  : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0069 + Trans(nBasePC,"@E 999,999,999.99") //STR0069	"Base PIS/COF(R$) : "
@nLin,40 PSAY STR0070 + Trans(nValorPIS,"@E 999,999,999.99")//STR0070	"Valor PIS (R$)   : "
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0071 + Trans(nValorCON,"@E 999,999,999.99") //STR0071	"Valor COFINS (R$): "
nLin := SomaLinha(nLin,1)

//-----------------------------------------------------------//

nLin2 := nLin
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ANTES_INFO_COMPL"),)
nLin := nLin2

@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0072 //STR0072	"Informações Complementares: "
nLin := SomaLinha(nLin,1)

// rs - 21/09/05
cMemo:=MSMM(SW6->W6_COMPLEM,60)
cMemo := EasySetMemo(cMemo) //LRS 14/11/2014 - Correção das quebras de linha na Build Nova 13227A
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"IMP_COMPLE"),)//igor chiba 18/02/2010
nLines:= MLCount(cMemo,60,,.T.)

For i:=1 to nLines
   @nLin,10 PSAY MemoLine(cMemo, 60, i)
   nLin := SomaLinha(nLin,1)
Next

nCOL1:=1
nCOL2:=15
nCOL3:=26
nCOL4:=42//44
nCOL5:=51
nCOL6:=66

// *** BHF - 30/10/08 - "Pagamento de Tributos"
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0073 //STR0073	"Pagamento de tributos"
nLin := SomaLinha(nLin,1)
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)

EII->(DbSetOrder(1))
EII->(DbSeek(xFilial()+SW6->W6_HAWB))

@nLin,nCOL1 PSAY STR0074//STR0074	"Banco:"
@nLin,nCOL2-6 PSAY AllTrim(SW6->W6_BCOPGTO)
@nLin,nCOL3+6 PSAY STR0075  //STR0075	 "Agência:"
@nLin,nCOL4 PSAY AllTrim(SW6->W6_AGEPGTO)
nLin := SomaLinha(nLin,1)
@nLin,nCOL1 PSAY STR0076  //STR0076	"Conta:"
@nLin,nCOL2-6 PSAY AllTrim(SW6->W6_CTAPGTO)
nLin := SomaLinha(nLin,1)
@nLin,nCOL1 PSAY STR0077 //STR0077	"Informações de Pagamento:"
nLin := SomaLinha(nLin,1)
While EII->(!EOF()) .And. SW6->W6_HAWB == EII->EII_HAWB
   @nLin,nCOL1 PSAY STR0078  //STR0078	 "Cod. Receita Trib.:"
   SJH->(DbSetOrder(1))
   SJH->(DbSeek(xFilial()+EII->EII_CODIGO))
   @nLin,nCOL2+6 PSAY AllTrim(SJH->JH_DESC)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0048 //STR0048	"Valor: "
   @nLin,nCOL2-6 PSAY Transform(EII->EII_VLTRIB,AVSX3("EII_VLTRIB",6))
   @nLin,nCOL3+6 PSAY STR0079  //STR0079	"Data de Pagamento:"
   @nLin,nCOL4+10 PSAY AllTrim(DtoC(EII->EII_DT_PAG))
   nLin := SomaLinha(nLin,1)
   EII->(DbSkip())
End Do
// *** BHF

IF !lImpAdicao
   RETURN .T.
ENDIF

//- Leandro D. de Brito 26/01/2004 ------------------------------------------//
SJC->(dbSetOrder(1))
EIN->(dbSetOrder(1))
SYD->(dbSetOrder(1))
SW8->(dbSetOrder(4)) //W8_FILIAL+W8_HAWB+W8_ADICAO
SX3->(DBSETORDER(2))
SX3->(DBSEEK("EIJ_REGIPI"))
aCbox:=GRV_DESCR(TRIM(SX3->X3_CBOX))
SX3->(DBSEEK("EIJ_REGICM"))
aCbox2 :=GRV_DESCR(TRIM(SX3->X3_CBOX))

SYT->(DBSETORDER(1))
SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
cCpoBasICMS:="YB_ICM_"+Alltrim(SYT->YT_ESTADO)
lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0

SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SWD->(DBSEEK(xFILIAL("SWD")+SW6->W6_HAWB))
DO WHILE SWD->(!(EOF())) .AND. xFILIAL("SWD") = SWD->WD_FILIAL .AND. SWD->WD_HAWB = SW6->W6_HAWB
   IF SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA))
      lBaseICM:=SYB->YB_BASEICM $ cSim
      IF lTemYB_ICM_UF
         lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
      ENDIF
   ENDIF
   SWD->(DBSKIP())
ENDDO

EIJ->(dbSeek(cFilAux+SW6->W6_HAWB))
@nLin,0 PSAY __PrtThinLine()
nLin := SomaLinha(nLin,1)
@nLin,01 PSAY STR0080 //STR0080	"Adições: "

Do While !EIJ->(EOF()) .and. EIJ->EIJ_HAWB == SW6->W6_HAWB .and. EIJ->EIJ_FILIAL == cFilAux
   IF EIJ->EIJ_ADICAO == "MOD"
      EIJ->(DBSKIP())
      LOOP
   ENDIF
   SX3->(dbSetOrder(2))
   nLin := SomaLinha(nLin,1)
   @nLin,0 PSAY __PrtThinLine()
   nLin := SomaLinha(nLin,1)
   SJP->(DBSEEK(XFILIAL("SJP")+EIJ->EIJ_REGTRI))
   SJC->(DBSEEK(XFILIAL("SJC")+EIJ->EIJ_ACO_II))
   SYD->(DBSEEK(XFILIAL("SYD")+EIJ->(EIJ_TEC+EIJ_EX_NCM+EIJ_EX_NBM)))
   @nLin,nCOL1 PSAY STR0081  //STR0081	"Registro.....:"
   @nLin,nCOL2+1 PSAY SW6->W6_DI_NUM
   @nLin,nCOL4 PSAY STR0082 //STR0082	"Adição: "
   @nLin,nCOL4+10 PSAY (EIJ->EIJ_ADICAO+"/"+STRZERO(nAD,3,0))
   nLin := SomaLinha(nLin,1)
   //CCH - 19/12/2008 -
   SA2->(DbSeek(xFilial("SA2")+EIJ->EIJ_FORN+EICRetLoja("EIJ", "EIJ_FORLOJ")))
   @nLin,nCOL1 PSAY STR0083 //STR0083	"Exportador...:"
   @nLin,nCOL2+1 PSAY EIJ->EIJ_FORN + If(EICLoja(), " " + EIJ->EIJ_FORLOJ, "") + " - " + SA2->A2_NOME
   nLin := SomaLinha(nLin,1)
   SA2->(DbSeek(xFilial("SA2")+EIJ->EIJ_FABR+EICRetLoja("EIJ", "EIJ_FABLOJ")))
   @nLin,nCOL1 PSAY STR0084 //STR0084	"Fabricante..."
   @nLin,nCOL2+1 PSAY EIJ->EIJ_FABR+ IF(EICLoja(), " " + EIJ->EIJ_FABLOJ, "") + " - " + SA2->A2_NOME
   nLin := SomaLinha(nLin,1)

   // EOB - 26/11/09 - Inclusão do campo de vinculação com o vendedor
   SX3->(DbSeek(AvKey("EIJ_VINCCO","X3_CAMPO")))
   @nLin,nCOL1 PSAY STR0085 //STR0085	"Vinc.c/vend. :"
   @nLin,nCOL2+1 PSAY GetStrCombo("EIJ_VINCCO",EIJ->EIJ_VINCCO)
   nLin := SomaLinha(nLin,1)

   @nLin,nCOL1 PSAY STR0086 //STR0086	"Local Venda..:"
   @nLin,nCOL2+1 PSAY ALLTRIM(EIJ->EIJ_LOCVEN)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0087  //STR0087	"Número da L.I:"
   @nLin,nCOL2+1 PSAY ALLTRIM(EIJ->EIJ_NROLI)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0088  //STR0088	"Regime Trib..:"
   @nLin,nCOL2+1 PSAY TRIM(SJP->JP_DESC)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0089 //STR0089	"Beneficio IPI:"
   IF LEN(aCbox) > 0
       nPos1:=ASCAN(aCbox,{|X| X[1] = EIJ->EIJ_REGIPI})
       IF nPos1 > 0
           @nLin,nCOL2+1 PSAY SUBSTR(aCbox[nPos1][2],3)
       ENDIF
   ENDIF
   // EOB - inclusão da impressão dos dados de PIS/COFINS
   SJP->(DBSEEK(XFILIAL("SJP")+EIJ->EIJ_REG_PC))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0090 //STR0090	"Reg. PIS/COF.:"
   @nLin,nCOL2+1 PSAY TRIM(SJP->JP_DESC)

   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0091  //STR0091	Regime ICMS..:
   IF LEN(aCbox2) > 0
       nPos1:=ASCAN(aCbox2,{|X| X[1] = EIJ->EIJ_REGICM})
       IF nPos1 > 0
           @nLin,nCOL2+1 PSAY SUBSTR(aCbox2[nPos1][2],3)
       ENDIF
   ENDIF
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY "NCM..........:"
   @nLin,nCOL2+1 PSAY ALLTRIM(EIJ->EIJ_TEC) PICTURE AVSX3("EIJ_TEC",6)
   @nLin,nCOL3+1 PSAY "EX............:"
   @nLin,nCOL4+1 PSAY TRIM(EIJ->EIJ_EX_NCM)+" "+TRIM(EIJ->EIJ_EX_NBM) PICTURE "@!"
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY "Naladi/SH....:"
   @nLin,nCOL2+1 PSAY ALLTRIM(EIJ->EIJ_NALASH) PICTURE AVSX3("EIJ_NALASH",6)
   @nLin,nCOL3+1 PSAY "Naladi/NCCA...:"
   @nLin,nCOL4+1 PSAY ALLTRIM(EIJ->EIJ_NALANC) PICTURE AVSX3("EIJ_NALANC",6)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0092   //STR0092	"Acordo II....:"
   @nLin,nCOL2+1 PSAY TRIM(SJC->JC_DESC)
   //CCH - 13/10/08 - Início - Acordo Tarifário II
   nLin := SomaLinha(nLin,1)
   IF !EMPTY(ALLTRIM(EIJ->EIJ_ASSII))
      @nLin,nCOL1 PSAY STR0093     //STR0093	"Acordo Tarifário do II:"
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0094 //STR0094	"Ato Legal....:"
      SX5->(DbSeek(xFilial("SX5")+"C4"+EIJ->EIJ_ASSII))
      @nLin,nCOL2+1 PSAY EIJ->EIJ_ASSII + " - "
      @nLin,nCOL2+5 PSAY SX5->X5_DESCRI
      nLin := SomaLinha(nLin,1)
      IF !EMPTY(ALLTRIM(EIJ->EIJ_EX_II))
         @nLin,nCOL1   PSAY Space(7)+"EX....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_EX_II
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ATO_II))
         SJI->(DbSeek(xFilial("SJI")+EIJ->EIJ_ATO_II))
         @nLin,nCOL1   PSAY Space(5)+STR0095 //STR0095	"Tipo....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ATO_II +" - "+ALLTRIM(SJI->JI_DESC)
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ORG_II))
         SJJ->(DbSeek(xFilial("SJJ")+EIJ->EIJ_ORG_II))
         @nLin,nCOL1   PSAY Space(4)+STR0096 //STR0096	"Orgão..."
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ORG_II +" - "+ALLTRIM(SJJ->JJ_DESC)
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_NRATII))
         @nLin,nCOL1   PSAY Space(3)+STR0097  //STR0097	 "Número....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_NRATII
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ANO_II))
         @nLin,nCOL1   PSAY Space(6)+STR0098 //STR0098	"Ano....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ANO_II
         nLin := SomaLinha(nLin,1)
      ENDIF
   ENDIF
   //CCH - 13/11/08 - Final - Acordo Tarifário II

   @nLin,nCOL1 PSAY "Ad. Valorem II:"
   @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALI_II,AVSX3("EIJ_ALI_II",6)))
   @nLin,nCOL3+1 PSAY STR0099 //STR0099	"Reduzida II...:"
   @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALR_II,AVSX3("EIJ_ALR_II",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0100 //STR0100	"% Reducao II.:"
   @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_PR_II,AVSX3("EIJ_PR_II",6)))
   nLin := SomaLinha(nLin,1)

   //CCH - 13/11/08 - Início - Acordo Tarifário IPI
   IF !EMPTY(ALLTRIM(EIJ->EIJ_ASSIPI))
      @nLin,nCOL1 PSAY STR0101 //STR0101	 "Acordo Tarifário do IPI:"
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0102 //STR0102	"Ato Legal....:"
      SX5->(DbSeek(xFilial("SX5")+"C4"+EIJ->EIJ_ASSIPI))
      @nLin,nCOL2+1 PSAY EIJ->EIJ_ASSIPI + " - "
      @nLin,nCOL2+5 PSAY SX5->X5_DESCRI
      nLin := SomaLinha(nLin,1)
      IF !EMPTY(ALLTRIM(EIJ->EIJ_EX_IPI))
         @nLin,nCOL1   PSAY Space(7)+"EX....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_EX_IPI
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ATOIPI))
         SJI->(DbSeek(xFilial("SJI")+EIJ->EIJ_ATOIPI))
         @nLin,nCOL1   PSAY Space(5)+STR0103 //STR0103	 "Tipo..."
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ATOIPI +" - "+ALLTRIM(SJI->JI_DESC)
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ORGIPI))
         SJJ->(DbSeek(xFilial("SJJ")+EIJ->EIJ_ORGIPI))
         @nLin,nCOL1   PSAY Space(4)+STR0104 // STR0104	"Orgão....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ORGIPI +" - "+ALLTRIM(SJJ->JJ_DESC)
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_NROIPI))
         @nLin,nCOL1   PSAY Space(3)+STR0105 //STR0105	"Número....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_NROIPI
         nLin := SomaLinha(nLin,1)
      ENDIF
      IF !EMPTY(ALLTRIM(EIJ->EIJ_ANOIPI))
         @nLin,nCOL1   PSAY Space(6)+STR0106 //STR0106	"Ano....:"
         @nLin,nCOL2+1 PSAY EIJ->EIJ_ANOIPI
         nLin := SomaLinha(nLin,1)
      ENDIF
   ENDIF
   //CCH - 13/11/08 - Final - Acordo Tarifário IPI

   IF EIJ->EIJ_TPAIPI == "1"
      @nLin,nCOL1 PSAY "Ad.Valorem IPI"
      @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALAIPI,AVSX3("EIJ_ALAIPI",6)))
      @nLin,nCOL3+1 PSAY STR0107 //STR0107	"Reduzida IPI..:"
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALRIPI,AVSX3("EIJ_ALRIPI",6)))
   ELSEIF EIJ->EIJ_TPAIPI == "2"
      @nLin,nCOL1 PSAY STR0108  //STR0108	 "Al.Especif.IPI"
      @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALUIPI,AVSX3("EIJ_ALUIPI",6)))
      @nLin,nCOL3+1 PSAY STR0109 //STR0109	"Qtd especifica:"
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_QTUIPI,AVSX3("EIJ_QTUIPI",6)))
   ENDIF
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0110 //STR0110 "%Red.Base P/C:"
   @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_PRB_PC,AVSX3("EIJ_PRB_PC",6)))
   IF EIJ->EIJ_TPAPIS == "1"
      @nLin,nCOL3+1 PSAY "Ad.Valorem PIS"
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALAPIS,AVSX3("EIJ_ALAPIS",6)))
      @nLin,nCOL5   PSAY STR0111  //STR0111	"Reducao PIS...:"
      @nLin,nCOL6+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_REDPIS,AVSX3("EIJ_REDPIS",6)))
   ELSEIF EIJ->EIJ_TPAPIS == "2"
      @nLin,nCOL3+1 PSAY STR0112 //STR0112 "Al.Especif.PIS"
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALUPIS,AVSX3("EIJ_ALUPIS",6)))
      @nLin,nCOL5   PSAY STR0113 //STR0113 "Qtd especifica:"
      @nLin,nCOL6+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_QTUPIS,AVSX3("EIJ_QTUPIS",6)))
   ENDIF
   nLin := SomaLinha(nLin,1)
   IF EIJ->EIJ_TPACOF == "1"
      @nLin,nCOL1 PSAY "Ad.Valorem Cof"
      @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALACOF,AVSX3("EIJ_ALACOF",6)))
      @nLin,nCOL3+1 PSAY STR0114 //STR0114 "Redução Cofins:"
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_REDCOF,AVSX3("EIJ_REDCOF",6)))
   ELSEIF EIJ->EIJ_TPAPIS == "2"
      @nLin,nCOL1 PSAY "Al.Especif.Cof"
      @nLin,nCOL2+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALUCOF,AVSX3("EIJ_ALUCOF",6)))
      @nLin,nCOL3+1 PSAY STR0115 //STR0115 "Qtd especifica: "
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_QTUCOF,AVSX3("EIJ_QTUCOF",6)))
   ENDIF
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY "Incoterm.....:"
   @nLin,nCOL2+1 PSAY EIJ->EIJ_INCOTE

   nAliqICMSA := SYD->YD_ICMS_RE
   IF !EMPTY(EIJ->EIJ_OPERACA)
      SWZ->(DBSETORDER(2))
      IF SWZ->(DBSEEK(xFilial("SWZ")+EIJ->EIJ_OPERACA))
         IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0 .AND. !EMPTY(SWZ->WZ_ICMS_PC)
            nAliqICMSA:= SWZ->WZ_ICMS_PC
         ELSE
            IF EMPTY(SWZ->WZ_RED_CTE)
               nAliqICMSA:= SWZ->WZ_AL_ICMS
            ELSE
               nAliqICMSA:= SWZ->WZ_RED_CTE
            ENDIF
         ENDIF
      ENDIF
   ENDIF	
		
   @nLin,nCOL3+1 PSAY STR0116  //STR0116 " Aliquota ICMS.:"
   @nLin,nCOL4+1 PSAY  ALLTRIM(TRANSF(nAliqICMSA, AVSX3("YD_ICMS_RE",6)))
   @nLin,nCOL5   PSAY STR0117  //STR0117 "Peso..........:"
   @nLin,nCOL6+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_PESOL,AVSX3("EIJ_PESOL",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  "FOB.......:R$"
   @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLMMN,AVSX3("EIJ_VLMMN",6)))
   @nLin,nCOL3+5 PSAY ALLTRIM(EIJ->EIJ_MOEDA)+".....: "//FDR - 29/01/13
   @nLin,nCOL4 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLMLE,AVSX3("EIJ_VLMLE",6)))
   @nLin,nCOL5+7 PSAY "Tx("+EIJ->EIJ_MOEDA+"): "
   @nLin,nCOL6+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_TX_FOB,AVSX3("EIJ_TX_FOB",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0118 //STR0118 "Frete.....:R$"
   @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VFREMN,AVSX3("EIJ_VFREMN",6)))
   @nLin,nCOL3+5 PSAY ALLTRIM(EIJ->EIJ_MOEDA)+".....: "//FDR - 29/01/13
   @nLin,nCOL4 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLFRET,AVSX3("EIJ_VLFRET",6)))
   @nLin,nCOL5+7 PSAY "Tx("+SW6->W6_FREMOED+"): "
   @nLin,nCOL6+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_TX_FRE,AVSX3("EIJ_TX_FRE",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0119  //STR0119 "Seguro....:R$"
   @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VSEGMN,AVSX3("EIJ_VSEGMN",6)))
   @nLin,nCOL3+5 PSAY ALLTRIM(EIJ->EIJ_MOEDA)+".....: "//FDR - 29/01/13
   @nLin,nCOL4 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VSEGLE,AVSX3("EIJ_VSEGLE",6)))
   nLin := SomaLinha(nLin,1)
   nVLAC:=0
   nVLDC:=0
   EIN->(DBSEEK(XFILIAL("EIN")+EIJ->(EIJ_HAWB+EIJ_ADICAO)))
   DO WHILE EIN->(!EOF()) .AND. EIN->(EIN_FILIAL+EIN_HAWB+EIN_ADICAO) = ;
   (XFILIAL("EIN")+EIJ->(EIJ_HAWB+EIJ_ADICAO))
       IF EIN->EIN_TIPO == "1"
           nVLAC += EIN->EIN_VLMMN
       ELSEIF EIN->EIN_TIPO == "2"
           nVLDC += EIN->EIN_VLMMN
       ENDIF
       EIN->(DBSKIP())
   ENDDO
   @nLin,nCOL1 PSAY  STR0120 //STR0120 "Acrescimo.:R$"
   @nLin,nCOL2 PSAY ALLTRIM(TRANSF(nVLAC,AVSX3("EIJ_VLMMN",6)))
   @nLin,nCOL3+5 PSAY STR0121 //STR0121 "Dedução.:R$ "
   @nLin,nCOL4 PSAY ALLTRIM(TRANSF(nVLDC,AVSX3("EIJ_VLMMN",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0122 //STR0122	"Base do II..:R$"
   @nLin,nCOL2+2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_BAS_II,AVSX3("EIJ_BAS_II",6)))
   @nLin,nCOL3+5 PSAY STR0123 //STR0123 "Base do IPI...:R$"
   @nLin,nCOL4+7 PSAY ALLTRIM(TRANSF(EIJ->EIJ_BASIPI,AVSX3("EIJ_BASIPI",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0124 //STR0124 "II Devido...:R$"
   @nLin,nCOL2+2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VL_II,AVSX3("EIJ_VL_II",6)))
   @nLin,nCOL3+5 PSAY STR0125 //STR0125 "I.P.I Devido..:R$"
   @nLin,nCOL4+7 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLDIPI,AVSX3("EIJ_VLDIPI",6)))
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0126  //STR0126 "II Recolher.:R$" //
   @nLin,nCOL2+2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLARII,AVSX3("EIJ_VLARII",6)))
   @nLin,nCOL3+5 PSAY STR0127 //STR0127 "I.P.I Recolher:R$"
   @nLin,nCOL4+7 PSAY ALLTRIM(TRANSF(EIJ->EIJ_VLAIPI,AVSX3("EIJ_VLAIPI",6)))
   // AWR - 15/10/2004 - Copia da V609A

   nVLPIS := nVLCOF := 0
   nTotAdi:=0
   aItemAdi:={}
   nVlOutDesp:=0

   SW8->(DBSEEK(XFILIAL("SW8")+EIJ->(EIJ_HAWB+EIJ_ADICAO)))
   DO WHILE SW8->(!EOF()) .AND. SW8->(W8_FILIAL+W8_HAWB+W8_ADICAO) = ;
      (XFILIAL("SW8")+EIJ->(EIJ_HAWB+EIJ_ADICAO))

      IF SW8->(FIELDPOS("W8_VLRPIS")<>0) .AND. SW8->(FIELDPOS("W8_VLRCOF")<>0)
         nVLPIS   += SW8->W8_VLRPIS
         nVLCOF   += SW8->W8_VLRCOF
      ENDIF

      mMemo    := ' '
      IF !EMPTY(SW8->W8_DESC_DI)
         mMemo := MSMM(SW8->W8_DESC_DI,AvSx3("W8_DESC_VM",3))
      ENDIF
      IF EMPTY(mMemo)
         SB1->(DBSEEK(xFILIAL("SB1")+SW8->W8_COD_I))
         mMemo := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
      ENDIF

      mMemo :=STRTRAN(mMemo,chr(13)+chr(10),' ')

      nTotAdi+=SW8->W8_BASEICM

      // IF lBaseICM
         nVlOutDesp+=SW8->W8_D_BAICM
      // ENDIF

      //ER - 25/05/2007
      If EasyEntryPoint("EICDI505")
         ExecBlock("EICDI505",.F.,.F.,"ALT_MEMO")
      EndIf

      AADD(aItemAdi,{SW8->W8_COD_I,mMemo,SW8->W8_QTDE,SW8->W8_PRECO})

      SW8->(DBSKIP())
   ENDDO

   IF SW8->(FIELDPOS("W8_VLRPIS")<>0) .AND. SW8->(FIELDPOS("W8_VLRCOF")<>0)
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY  STR0128 //STR0128 "Valor PIS...:R$"
      @nLin,nCOL2+2 PSAY ALLTRIM(TRANSF(nVLPIS,AVSX3("W8_VLRPIS",6)))
      @nLin,nCOL3+5 PSAY STR0129 //STR0129 "Valor COFINS..:R$"
      @nLin,nCOL4+7 PSAY ALLTRIM(TRANSF(nVLCOF,AVSX3("W8_VLRCOF",6)))
   ENDIF// AWR - 15/10/2004 - Copia da V609A


   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY  STR0130 //STR0130 "Vl Outras Desp:R$"
   @nLin,nCOL2+4 PSAY ALLTRIM(TRANSF(nVlOutDesp,AVSX3("EIJ_VLARII",6)))


   @nLin,nCOL3+5 PSAY STR0131 //STR0131	"Tot. Base ICMS:R$"
   @nLin,nCOL4+7 PSAY ALLTRIM(TRANSF(nTotAdi,AVSX3("EIJ_VLAIPI",6)))
   nLin := SomaLinha(nLin,1)

   //CCH - 13/11/2008 - Início - Dados
   @nLin,nCOL1 PSAY STR0132  //STR0132 "Peso Total:"
   @nLin,nCOL2+3 PSAY ALLTRIM(TRANSF(EIJ->EIJ_PESOL,"@E 9,999,999,999.99999"))
   nLin := SomaLinha(nLin,1)

   //*** BHF - 23/01/09 - AntiDumping
   If EIJ->EIJ_TPADUM $ ("1,2,3")
      @nLin,01 PSAY "ANTIDUMPING"
      nLin := SomaLinha(nLin,1)

      If EIJ->EIJ_TPADUM = "1"
         cAntDmpng := Alltrim(AvSX3("EIJ_TPADUM",5))+": Ad Valorem"
      ElseIf EIJ->EIJ_TPADUM = "2"
         cAntDmpng := Alltrim(AvSX3("EIJ_TPADUM",5))+STR0133 //STR0133	" Especifica"

      Else
         cAntDmpng := Alltrim(AvSX3("EIJ_TPADUM",5))+STR0134 //STR0134 ": Mista"
      EndIf

      // Tipo de aliquota aplicavel
      @nLin,nCOL1 PSAY cAntDmpng
      nLin := SomaLinha(nLin,1)

      // Calculo por Aliquota-AD-Valorem
      nVlrDumpA    := DI500Trans((DI500Block("EIJ","EIJ_ALADDU")*(DI500Block("EIJ","EIJ_BAD_AD")/100)))
      // Calculo por Valor Especifico
      nVlrDumpE    := DI500Trans((DI500Block("EIJ","EIJ_ALEADU")*DI500Block("EIJ","EIJ_BAE_AD")))
      // Total
      VlAntDumpTot := nVlrDumpA + nVlrDumpE

      // Base Aliquota Especifica
      @nLin,nCOL1 PSAY AvSx3("EIJ_BAE_AD",5)+": "
      @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_BAE_AD,AvSx3("EIJ_BAE_AD",6)))

      // Aliquota Especifica
      @nLin,nCOL3 PSAY AvSX3("EIJ_ALEADU",5)+": R$" //+AllTRIM(EIJ->EIJ_MOEDA)
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALEADU,AvSx3("EIJ_ALEADU",6)))
      nLin := SomaLinha(nLin,1)

      // Base Aliquota Ad-Valorem
      @nLin,nCOL1 PSAY AvSX3("EIJ_BAD_AD",5)+": R$"
      @nLin,nCOL2+3 PSAY ALLTRIM(TRANSF(EIJ->EIJ_BAD_AD,AvSx3("EIJ_BAD_AD",6)))

      // Aliquota Ad-Valorem
      @nLin,nCOL3 PSAY AvSX3("EIJ_ALADDU",5)+": %" //+AllTRIM(EIJ->EIJ_MOEDA)
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ALADDU,AvSx3("EIJ_ALADDU",6)))
      nLin := SomaLinha(nLin,1)

      //Valor a Recolher
      @nLin,nCOL1 PSAY ALLTRIM(AvSX3("EIJ_VLR_DU",5))+": R$" //+AllTRIM(EIJ->EIJ_MOEDA)
      @nLin,nCOL2+3 PSAY ALLTRIM(TRANSF(VlAntDumpTot,AvSx3("EIJ_VLR_DU",6)))

      //Valor Devido
      @nLin,nCOL3 PSAY AvSX3("EIJ_VLD_DU",5)+": R$" //+AllTRIM(EIJ->EIJ_MOEDA)+" "
      @nLin,nCOL4+1 PSAY ALLTRIM(TRANSF(VlAntDumpTot,AvSx3("EIJ_VLD_DU",6)))
      nLin := SomaLinha(nLin,1)

      //Intervalo de tempo
      @nLin,nCOL1 PSAY AvSX3("EIJ_PERIOD",5)+": "
      @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_PERIOD,AvSx3("EIJ_PERIOD",6)))

      //Nro. do Ato Legal
      @nLin,nCOL3 PSAY AvSX3("EIJ_NRODUM",5)+": "
      @nLin,nCOL4 PSAY ALLTRIM(TRANSF(EIJ->EIJ_NRODUM,AvSx3("EIJ_NRODUM",6)))
      nLin := SomaLinha(nLin,1)

      //Tipo de Ato Legal
      SJI->(DbSetOrder(1))
      SJI->(DbSeek(xFilial("SJI")+EIJ->EIJ_ATODUM))
      @nLin,nCOL1 PSAY AvSX3("EIJ_ATODUM",5)+": "
      @nLin,nCOL2 PSAY ALLTRIM(TRANSF(SJI->JI_DESC,AvSx3("JI_DESC",6)))

      //Ato Legal
      SX5->(DbSetOrder(1))
      SX5->(DbSeek(xFilial("SX5")+"C4"+EIJ->EIJ_ASSDUM))
      @nLin,nCOL3+8 PSAY AvSX3("EIJ_ASSDUM",5)+": "
      @nLin,nCOL4+3 PSAY ALLTRIM(TRANSF(SX5->X5_DESCRI,AvSx3("X5_DESCRI",6)))
      nLin := SomaLinha(nLin,1)

      //Ano do Ato Legal
      @nLin,nCOL1 PSAY AvSX3("EIJ_ANODUM",5)+": "
      @nLin,nCOL2 PSAY ALLTRIM(TRANSF(EIJ->EIJ_ANODUM,AvSx3("EIJ_ANODUM",6)))
      nLin := SomaLinha(nLin,1)

      //Fim do trecho de AntiDumping
   EndIf
   // *** BHF

   SAH->(dbSetOrder(1))
   IF !EMPTY(ALLTRIM(EIJ->EIJ_UM_EST))
      SAH->(dbSeek(xFilial("SAH")+EIJ->EIJ_UM_EST))
      @nLin,nCOL1    PSAY STR0135 //STR0135 "Unidade Med. Estatística:"
      @nLin,nCOL2+12 PSAY ALLTRIM(EIJ->EIJ_UM_EST)+" - "+ALLTRIM(SAH->AH_DESCPO)
      nLin := SomaLinha(nLin,1)
   ENDIF

   IF(EasyEntryPoint("EICDI505"),Execblock("EICDI505",.F.,.F.,"UN_MEDIDA_COMERCIALIZADA"),)   //LGS-24/09/2013 - Ponto de entrada para Unidade de Medida Comercializada

   IF !EMPTY(EIJ->EIJ_QT_EST)
      @nLin,nCOL1    PSAY STR0136 //STR0136 "Quantidade Med. Est.:"
      @nLin,nCOL2+12 PSAY EIJ->EIJ_QT_EST
      nLin := SomaLinha(nLin,1)
   ENDIF
   IF !EMPTY(EIJ->EIJ_APLICM)
      @nLin,nCOL1    PSAY STR0137 //STR0137  "Aplicação da Mercadoria:"
      @nLin,nCOL2+11 PSAY IF(EIJ->EIJ_APLICM == "1",STR0138,STR0139) //STR0138 "Consumo" //STR0139 "Revenda" /
      nLin := SomaLinha(nLin,1)
   ENDIF
   //CCH - 13/11/2008 - Fim - Dados

   //CCH - 13/11/2008 - Início - NVE
   //MFR 23/11/2018
   //EIM->(dbSeek(xFilial("EIM")+SW6->W6_HAWB+EIJ->EIJ_NVE))  //CCH - 14/11/08
   //Do While !EIM->(EOF()) .and. EIM->EIM_HAWB == SW6->W6_HAWB .and. EIM->EIM_CODIGO == EIJ->EIJ_NVE .and. xFilial("EIM") == EIM->EIM_FILIAL   
   EIM->(dbSeek(GetFilEIM("DI")+SW6->W6_HAWB+EIJ->EIJ_NVE))  //CCH - 14/11/08
   Do While !EIM->(EOF()) .and. EIM->EIM_HAWB == SW6->W6_HAWB .and. EIM->EIM_CODIGO == EIJ->EIJ_NVE .and. GetFilEIM("DI") == EIM->EIM_FILIAL
      nLin := SomaLinha(nLin,1)
      SX3->(DbSeek(AvKey("EIM_NIVEL","X3_CAMPO")))
      @nLin,nCOL1    PSAY STR0140 //STR0140 "Classificação:"
      @nLin,nCOL2+1  PSAY GetStrCombo("EIM_NIVEL",EIM->EIM_NIVEL)
      nLin := SomaLinha(nLin,1)

      IF !EMPTY(EIM->EIM_ATRIB) .AND. SJK->(dbSeek(xFilial("SJK")+If( EIM->(FieldPos("EIM_NCM")) > 0 .And. !Empty(EIM->EIM_NCM) , EIM->EIM_NCM, EIJ->EIJ_TEC )+EIM->EIM_ATRIB))
         @nLin,nCOL1 PSAY STR0141+Replicate(".",5)+":"  //STR0141 "Atributo"
         @nLin,nCOL2+1 PSAY EIM->EIM_ATRIB +" - "+ALLTRIM(SJK->JK_DES_ATR)
         nLin := SomaLinha(nLin,1)
      ENDIF

      IF !EMPTY(EIM->EIM_ESPECI) .AND. SJL->(dbSeek(xFilial("SJL")+If( EIM->(FieldPos("EIM_NCM")) > 0 .And. !Empty(EIM->EIM_NCM) , EIM->EIM_NCM, EIJ->EIJ_TEC )+EIM->EIM_ATRIB+EIM->EIM_ESPECI))
         @nLin,nCOL1   PSAY STR0142 //STR0142	"Especificação:"
         @nLin,nCOL2+1 PSAY EIM->EIM_ESPECI +" - "+ALLTRIM(SJL->JL_DES_ESP)
         nLin := SomaLinha(nLin,1)
      ENDIF
      EIM->(dbSkip())
   End Do
   //CCH - 13/11/2008 - Final - NVE

   SJ6->(DbSetOrder(1))

   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0143 //STR0143	"Cobertura:"
   @nLin,nCOL2+1 PSAY GetStrCombo("EIJ_TIPCOB",EIJ->EIJ_TIPCOB)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0144 //STR0144 "Modalidade"
   @nLin,nCOL2+1 PSAY ALLTRIM(EIJ->EIJ_MODALI)
   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0145 //STR0145 "Desc.Modalidade:"
   SJ6->(dbSeek(xFilial("SJ6")+EIJ->EIJ_MODALI))
   @nLin,nCOL2+2 PSAY ALLTRIM(SJ6->J6_DESC)
   nLin := SomaLinha(nLin,1)

   //CCH - 14/11/2008 - Início - Dados do Câmbio
   nTotPgV := 0
   nTotPgA := 0
   If EIO->(dbSeek(xFilial("EIO")+EIJ->(EIJ_HAWB+EIJ_ADICAO)))
      lCabVista := .F.
      lCabAntec := .F.
      lCabVaria := .F.
      Do While !EIO->(EOF()) .and. EIO->EIO_HAWB == SW6->W6_HAWB .and. EIO->EIO_ADICAO == EIJ->EIJ_ADICAO .and. xFilial("EIO") == EIJ->EIJ_FILIAL
         If EIO->EIO_TIPCOB == "1"
            IF !lCabVista
 			   @nLin,nCOL1 PSAY STR0146 //STR0146 "Pagamento à Vista:"
               nLin := SomaLinha(nLin,1)
               @nLin,nCOL1 PSAY STR0147 //STR0147 "Contrato"
               @nLin,nCOL2+3 PSAY STR0048 //STR0048 "Valor"
               @nLin,nCOL3+15 PSAY STR0074 //STR0074 "Banco:"
               @nLin,nCOL4+15 PSAY STR0148 //STR0148 "Praça"
               nLin := SomaLinha(nLin,1)
               lCabVista := .T.
            ENDIF
            @nLin,nCOL1 PSAY EIO->EIO_CAMBIO
            @nLin,nCOL2+3 PSAY Trans(EIO->EIO_VLMLE,AVSX3("EIO_VLMLE",AV_PICTURE))
            @nLin,nCOL3+15 PSAY EIO->EIO_BANCO
            @nLin,nCOL4+15 PSAY EIO->EIO_PRACA
            nTotPgV += EIO->EIO_VLMLE
            nLin := SomaLinha(nLin,1)
         ENDIF

         If EIO->EIO_TIPCOB == "2"
            IF !lCabAntec
               @nLin,nCOL1 PSAY STR0149 //STR0149	"Pagamento Antecipado:"
               nLin := SomaLinha(nLin,1)
               @nLin,nCOL1 PSAY STR0147 //STR0147 "Contrato"
               @nLin,nCOL2+3 PSAY STR0048  //STR0048 "Valor"
               @nLin,nCOL3+15 PSAY STR0074  //STR0074 "Banco:"
               @nLin,nCOL4+15 PSAY STR0148 //STR0148 "Praça"
               nLin := SomaLinha(nLin,1)
               lCabAntec := .T.
            ENDIF
            @nLin,nCOL1 PSAY EIO->EIO_CAMBIO
            @nLin,nCOL2+3 PSAY Trans(EIO->EIO_VLMLE,AVSX3("EIO_VLMLE",AV_PICTURE))
            @nLin,nCOL3+15 PSAY EIO->EIO_BANCO
            @nLin,nCOL4+15 PSAY EIO->EIO_PRACA
            nTotPgA += EIO->EIO_VLMLE
            nLin := SomaLinha(nLin,1)
         EndIf

         If EIO->EIO_TIPCOB == "3"
            IF lCabVaria
               @nLin,nCOL1 PSAY STR0149 //STR0149 "Pagamentos Variados:"
               nLin := SomaLinha(nLin,1)
               @nLin,nCOL2+3 PSAY STR0048 //STR0048 "Valor"
               @nLin,nCOL3+15 PSAY STR0150 //STR0150 "Mes/Ano Pagamento"
               nLin := SomaLinha(nLin,1)
               lCabVaria := .T.
            ENDIF
            @nLin,nCOL2+3 PSAY Trans(EIO->EIO_VLMLE,AVSX3("EIO_VLMLE",AV_PICTURE))
            @nLin,nCOL3+15 PSAY Trans(EIO->EIO_MESANO,AVSX3("EIO_MESANO",AV_PICTURE))
            nLin := SomaLinha(nLin,1)
         EndIf

         EIO->(dbSkip())

      End Do
   Endif

   If nTotPgV > 0
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0151 //STR0151 "Total à Vista:"
      @nLin,nCOL2+3 PSAY Trans(nTotPgV,AVSX3("EIO_VLMLE",AV_PICTURE))
      nLin := SomaLinha(nLin,1)
   ENDIF
   If nTotPgA > 0
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0152 //STR0152 "Total Antecipado:"
      @nLin,nCOL2+3 PSAY Trans(nTotPgA,AVSX3("EIO_VLMLE",AV_PICTURE))
      nLin := SomaLinha(nLin,1)
   Endif

   IF EIJ->EIJ_VL_FIN > 0
      nLin := SomaLinha(nLin,1)
      //Pagto em até 360 dias
      @nLin,nCOL1 PSAY STR0153 //STR0153 "Pagto em até 360 dias:"
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0154 //STR0154 "Parcelas:"
      @nLin,nCOL2+3 PSAY EIJ->EIJ_QTPARC
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0155 //STR0155 "Periodicidade:"
      @nLin,nCOL2+3 PSAY EIJ->EIJ_PERPAR+ " - " +If (!Empty(EIJ->EIJ_PERPAR),If(EIJ->EIJ_PERPAR == "1",STR0156,STR0157),"") //STR0156 "Diário" //STR0157 "Mensal"
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0048 //STR0048 "Valor:"
      @nLin,nCOL2+3 PSAY Trans(EIJ->EIJ_VL_FIN,AVSX3("EIJ_VL_FIN",AV_PICTURE))
      nLin := SomaLinha(nLin,1)
   ENDIF

   If !Empty(EIJ->EIJ_VLM360)
      nLin := SomaLinha(nLin,1)
      @nLin,nCOL1 PSAY STR0158 //STR0158 "Valor Montante:"
      @nLin,nCOL2+1 PSAY Trans(EIJ->EIJ_VLM360,AVSX3("EIJ_VL_FIN",AV_PICTURE))
   EndIf

   //CCH - 14/11/2008 - Final - Dados do Câmbio

   //TRP - 22/05/09
   If EIK->(dbSeek(xFilial("EIK")+EIJ->(EIJ_HAWB+EIJ_ADICAO)))
      DO While !EIK->(Eof()) .And.;
			    EIK->EIK_FILIAL == xFilial("EIK")	.And.;
 			    EIK->EIK_HAWB   == EIJ->EIJ_HAWB .And.;
 			    EIK->EIK_ADICAO == EIJ->EIJ_ADICAO

         nLin := SomaLinha(nLin,1)

         @nLin,nCOL1 PSAY STR0159 //STR0159 "Tipo Docto:"
         @nLin,nCOL1 + 15 PSAY EIK->EIK_TIPVIN

         @nLin,nCOL1 + 20 PSAY STR0160 //STR0160 "No. Docto:"
         @nLin,nCOL1 + 35 PSAY EIK->EIK_DOCVIN

         EIK->(DbSkip())
      Enddo
   Endif

   nLin := SomaLinha(nLin,1)
   @nLin,nCOL1 PSAY STR0161 //STR0161 "Itens"
   SB1->(DBSETORDER(1))

   For i:=1 to Len(aItemAdi)
       SB1->(DBSEEK(xFILIAL("SB1")+aItemAdi[i,1]))
       nLin := SomaLinha(nLin,1)

       @nLin,nCOL1 PSAY STR0162  // SVG - 04/02/2009 //STR0162 "Cod Item..:"
	   @nLin,nCOL1 + 12 PSAY ALLTRIM(SB1->B1_COD)       // RS - Chamado 055406

	   //TRP - 22/05/08
	   @nLin,nCOL1  + AVSX3("B1_COD",3) + 20 PSAY STR0163 //STR0163 "Preço..:"
  	   @nLin,nCOL1  + AVSX3("B1_COD",3) + 28 PSAY aItemAdi[i,4] PICTURE AVSX3("W8_PRECO",6)

	   nLin := SomaLinha(nLin,1)

	   //SVG - 04/02/2009
	   @nLin,nCOL1 PSAY STR0164 //STR0164 "Qtde..:"
  	   @nLin,nCOL1 + 12 PSAY aItemAdi[i,3] PICTURE AVSX3("W8_QTDE",6)

	   @nLin,nCOL1  + 35 PSAY "Unidade Medida.:"	//LRS
  	   @nLin,nCOL1  + 55 PSAY ALLTRIM(SB1->B1_UM)

	   nLin := SomaLinha(nLin,1)

       nLines:=MLCOUNT(aItemAdi[i,2],TAM_DESC_I)	// RS - Chamado 055406

		For j:=1 to nLines                                                         // RS - Chamado 055406
			@nLin,nCol1 PSAY MemoLine(aItemAdi[i,2], TAM_DESC_I, j)                // RS - Chamado 055406
			nLin := SomaLinha(nLin,1)											   // RS - Chamado 055406
		Next                                                                       // RS - Chamado 055406
   IF(EasyEntryPoint("EICDI505"),Execblock("EICDI505",.F.,.F.,{"IMPRESSAO_ITEM_ADICAO",@nLin,aItemAdi,I}),) //LRS - 23/10/2014 - Ponto entrada para colocar Unidade Medida Produto

  NEXT



  nLin2 := nLin
  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"FINAL_IMPR_ADI"),)
  nLin := nLin2

  EIJ->(DBSKIP())

Enddo
SW8->(dbSetOrder(1))

nLin++
@nLin,0 PSAY __PrtThinLine()
//---------------------------------------------------------------------------//
SY9->(dbSetOrder(1))
SW9->(dbSetOrder(1))

Return .T.

*-----------------------------------*
Function GRV_DESCR(cDESCR)
*-----------------------------------*
LOCAL nPOS:=0,aCBOX:={}
LOCAL cDESC:=cDESCR
WHILE .T.
    IF EMPTY(cDESC) .OR. cDESC == NIL
        EXIT
    ENDIF
    nPOS:=AT(";",cDESC)
    IF nPos > 0
        AADD(aCbox,{LEFT(cDESC,1),ALLTRIM(SUBSTR(cDESC,1,nPOS-1))})
        cDESC := SUBSTR(cDESC,nPOS+1)
    ELSE
        AADD(aCbox,{LEFT(cDESC,1),ALLTRIM(cDESC)})
        EXIT
    ENDIF
ENDDO

RETURN(aCBOX)
*-----------------------------------*
Static Function SomaLinha(nLinAtu,nQuant)
*-----------------------------------*
Local nRet

nRet := nLinAtu + nQuant
If nRet > 60
   nRet := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
EndIf

Return nRet

*--------------------------------*
Function DI500GeraTxt(cTipoEnv,oXML,cRetif,cVersao,cId)
*--------------------------------*
Local nTamLin, cCpo, nHdl,cArqTxt
//Local aLoadTxt  := {}
local nVlTotLocEnt:=nVlTtLocEmb:=0
local nAcrescimo := nDeducao := nAcr_LocEmb := nDed_LocEmb := 0
Local nOldArea  := Select(), i
Local aOrd      := SaveOrd({"EIF","EIG","EIH",;
                            "EII","EIJ","EIR",;
                            "SW7","SW8","SW2",;
                            "SA2","SYT","SYQ",;
                            "SY4","SY9","SYF",;
                            "SB1","EIO","EIN",;
                            "EIL","EIK","EIM","SA5",;
                            "SJD","SX5","SYA" })

Local cFilSA5 := xFilial('SA5')
Local cFilSAH := xFilial('SAH')
Local cFilSW7 := xFilial("SW7")
Local cFilSW8 := xFilial("SW8")
Local cFilSA2 := xFilial("SA2")
Local cFilSYF := xFilial("SYF")
Local cFilEIG := xFilial("EIG")
Local cFilEIF := xFilial("EIF")
Local cFilEIH := xFilial("EIH")
Local cFilEII := xFilial("EII")
Local cFilEIJ := xFilial("EIJ")
Local cFilEJ9 := xFilial("EJ9")
Local cFilEIO := xFilial("EIO")
Local cFilEIN := xFilial("EIN")
Local cFilEIL := xFilial("EIL")
Local cFilEIK := xFilial("EIK")
//MFR 26/11/2018 OSSME-1483
//Local cFilEIM := xFilial("EIM")
Local cFilEIM := GetFilEIM("DI")
Local cFilSB1 := xFilial("SB1")
Local cPathLocal := ""

// BAK - Variaveis utilizados na DAI
Local cTag := ""
Local aCapaDAI := {}
Local aAdicoes := {}
Local aAdicaoDAI := {}
Local aItens := {}
Local aItensAdDAI := {}
Local aLacreDAI := {}
Local aLoadXML := {}
Local nVlTotCap := 0, nValorCapatazia := 0
Local nPos := 0
Local lXml := ValType(oXML) == "O"
Local lLocal  := .F.
//** TDF - 29/07/11 - Novo tratamento de DE Mercosul
Local lEJ9 := ChkFile("EJ9",.F.)

/*Local lMERCODI := (EasyGParam("MV_MERCODI",,.F.) .AND. ;
SW6->(FIELDPOS("W6_DEMERCO")) # 0 .AND. SW6->(FIELDPOS("W6_REINIC")) # 0 .AND. SW6->(FIELDPOS("W6_REFINAL")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_DEMERC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REINIC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REFINA")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_IDCERT")) # 0 .AND. EIJ->(FIELDPOS("EIJ_PAISEM")) # 0 .AND. EIJ->(FIELDPOS("EIJ_DICERT")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_ITDICE")) # 0 .AND. EIJ->(FIELDPOS("EIJ_QTDCER")) # 0 )*/
Local lProcVincEsp := .F. // SVG - 27/03/09 - Controle de Tipos de Processos Vinculados
Local lExistEII := EII->(FIELDPOS("EII_BANCO")) # 0 .AND. EII->(FIELDPOS("EII_AGENCI")) # 0
Local nRecSA2 := 0        //NCF - 23/03/2012
Local aOrdSW9     := {}   //NCF - 23/03/2012

Local nOrdEJB := 0
Local nRecEJB := 0
Local nOrdEJC := 0
Local nRecEJC := 0
Local nTotAdi := 0
Local nVlCM := 0

// BAK - Tratamento para os valores de FOB na moeda negociada
Local nAcMoeNeg := 0
Local nDeMoeNeg := 0
Local nVlTot := 0
Local lSuframa

Default cRetif := ""

Private nAliqICMS := 0
Private lMERCODI := (EasyGParam("MV_MERCODI",,.F.) .AND. ;
SW6->(FIELDPOS("W6_DEMERCO")) # 0 .AND. SW6->(FIELDPOS("W6_REINIC")) # 0 .AND. SW6->(FIELDPOS("W6_REFINAL")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_DEMERC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REINIC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REFINA")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_IDCERT")) # 0 .AND. EIJ->(FIELDPOS("EIJ_PAISEM")) # 0 .AND. EIJ->(FIELDPOS("EIJ_DICERT")) # 0 .AND.;
EIJ->(FIELDPOS("EIJ_ITDICE")) # 0 .AND. EIJ->(FIELDPOS("EIJ_QTDCER")) # 0 )
//ACB - 10/03/2011 - Mudança para private para uso em ponto de entrada.
Private aLoadTxt  := {}

SW8->(DBSEEK(xFilial()+SW6->W6_HAWB)) //MCF - 22/12/2014
SW4->(Dbsetorder(1))
SW4->(DBSEEK(xFilial()+SW8->W8_PGI_NUM))

lSuframa := IF(AvFlags("SUFRAMA") .AND. !EMPTY(SW4->W4_PROD_SU),.T.,.F.)  // GFP - 05/08/2013 - Tratamento Suframa

lTemNVE := EIM->(FIELDPOS("EIM_CODIGO")) # 0 .AND.;// AWR - NVE
           SW8->(FIELDPOS("W8_NVE"))     # 0 .AND.;// AWR - NVE
           EIJ->(FIELDPOS("EIJ_NVE"))    # 0 .AND.;// AWR - NVE
           SIX->(dbSeek("EIM2"))

If(!EMPTY(cPathDest).AND.Right(cPathDest,1) != "\", cPathDest += "\",)

cTipEnv :=If(cTipoEnv=="1","A_","R_")
IF lEMail
   cTipEnv:="E"+cTipEnv
EndIf
cNomeNew:=SW6->W6_HAWB

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERA_NOME_SISC"),)

cNomeNew:=STRTRAN(cNomeNew,"\","")
cNomeNew:=STRTRAN(cNomeNew,"/","")
cNomeNew:=STRTRAN(cNomeNew,".","")
cNomeNew:=STRTRAN(cNomeNew,":","")
cNomeNew:=STRTRAN(cNomeNew,"*","")
cNomeNew:=STRTRAN(cNomeNew,"?","")
cNomeNew:=STRTRAN(cNomeNew,"'","")
cNomeNew:=STRTRAN(cNomeNew,'"',"")
cNomeNew:=STRTRAN(cNomeNew,">","")
cNomeNew:=STRTRAN(cNomeNew,"<","")
cNomeNew:=STRTRAN(cNomeNew,"|","")

cArqTxt := cTipEnv + AllTrim(cNomeNew) + ".txt"

//** PLB 08/05/07 - Verifica se o TXT deve ser gravado localmente
If "LOCAL:" == Upper(SubStr(cPathDest,1,6))
   lLocal := .T.
   cPathLocal := SubStr(cPathDest,7)
   cPathDest  := Upper(GetSrvProfString("STARTPATH",""))

ElseIf "SERVER:" == Upper(SubStr(cPathDest,1,7))
   cPathDest := SubStr(cPathDest,8)

EndIf
//**

If !lXml
   If File(cPathDest+cArqTxt)
      FErase(cPathDest+cArqTxt)
   EndIf

   nHdl := EasyCreateFile(cPathDest+cArqTxt)
   If !(nHdl > 0)
      MsgStop(STR0260+cPathDest+cArqTxt,STR0215)  // STR0260 "Erro na criação do arquivo: " //STR0215	"Atenção"
      Return Nil
   EndIf
EndIf

SW7->(dbSetOrder(1)) /* W7_FILIAL+W7_HAWB+...          */
SW8->(dbSetOrder(4)) /* W8_FILIAL+W8_HAWB+W8_ADICAO    */
SW2->(dbSetOrder(1)) /* W2_FILIAL+W2_PO_NUM            */
SA2->(dbSetOrder(1)) /* A2_FILIAL+A2_COD+A2_LOJA       */
SYT->(dbSetOrder(1)) /* YT_FILIAL+YT_COD_IMP           */
SYQ->(dbSetOrder(1)) /* QY_FILIAL+YQ_VIA               */
SY4->(dbSetOrder(1)) /* Y4_FILIAL+Y4_COD               */
SYR->(dbSetOrder(1))//SY9->(dbSetOrder(2)) /* Y9_FILIAL+Y9_SIGLA             */
SYF->(dbSetOrder(1)) /* YF_FILIAL+YF_MOEDA             */
SB1->(dbSetOrder(1)) /* B1_FILIAL+B1_COD               */
EIF->(dbSetOrder(1)) /* EIF_FILIAL+EIF_HAWB+EIF_CODIGO */
EIO->(dbSetOrder(1)) /* EIO_FILIAL+EIO_HAWB+EIO_ADICAO */
EIN->(dbSetOrder(1)) /* EIN_FILIAL+EIN_HAWB+EIN_ADICAO */
EIL->(dbSetOrder(1)) /* EIL_FILIAL+EIL_HAWB+EIL_ADICAO */
EIK->(dbSetOrder(1)) /* EIK_FILIAL+EIK_HAWB+EIK_ADICAO */
EIM->(dbSetOrder(1)) /* EIM_FILIAL+EIM_HAWB+EIM_ADICAO */
SA4->(DBSETORDER(1)) /* A4_FILIAL+A4_CODIGO JONATO */
SA5->(DBSETORDER(3)) /* A5_FILIAL+A5_PRODUTO+A5_FABR+A5_FORN+A5_LOJA*/

SW7->(dbSeek( cFilSW7 + SW6->W6_HAWB ))
SW2->(dbSeek( xFilial("SW2") + SW7->W7_PO_NUM  ))
SYT->(dbSeek( xFilial("SYT") + SW2->W2_IMPORT  ))
SYQ->(dbSeek( xFilial("SYQ") + SW6->W6_VIA_TRA ))
SY4->(dbSeek( xFilial("SY4") + SW6->W6_AGENTE  ))
//SY9->(dbSeek( xFilial("SY9") + SW6->W6_ORIGEM  )) AWR 13/11/2001
SYR->(dbSeek( xFilial("SYR")+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
SA4->(DbSeek( xFilial("SA4") + SW6->W6_TRANSIN ))

ProcRegua(SW6->W6_QTD_ADI+8)
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

nVlTotPesoL:=0

EIJ->(dbSetOrder(1)) /* EIJ_FILIAL+EIJ_HAWB+EIJ_ADICAO */
EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB))
nVlTotLocEnt:=0
DO While !EIJ->(Eof()) .And.;
		 EIJ->EIJ_FILIAL==cFilEIJ.AND.;
 		 EIJ->EIJ_HAWB  ==SW6->W6_HAWB
   IF EIJ->EIJ_ADICAO == "MOD"
      EIJ->(DBSKIP())
      LOOP
   ENDIF

   //JAP - 03/08/06
   nVlTotPesoL+= Round(EIJ->EIJ_PESOL,5)

   nAcrecimo:=nDeducao:=0

   // BAK - Valores de acrecimo e deducao na moeda negociada
   nAcMoeNeg := 0
   nDeMoeNeg := 0
   EIN->(DBSEEK(cFilEIN+EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO))
   DO WHILE EIN->(!EOF()) .AND. EIN->EIN_HAWB  ==EIJ->EIJ_HAWB   .AND.;
                                EIN->EIN_ADICAO==EIJ->EIJ_ADICAO .AND.;
                                EIN->EIN_FILIAL==cFilEIN
      IF EIN->EIN_TIPO == '1'
         nAcrecimo+=EIN->EIN_VLMMN
         nAcMoeNeg+=EIN->EIN_VLMLE
      ELSE
         nDeducao +=EIN->EIN_VLMMN
         nDeMoeNeg+=EIN->EIN_VLMLE
      ENDIF
      EIN->(DBSKIP())
   ENDDO

   nVlTotLocEnt+=EIJ->EIJ_VLMMN+(nAcrecimo-nDeducao)
   nVlTot+=EIJ->EIJ_VLMLE+(nAcMoeNeg-nDeMoeNeg)
   /* AAF - 17/03/08 - Removido pois o calculo feito pelo Siscomex não utiliza arredondamento.
   IF EIJ->EIJ_INCOTE $ "CFR,CIF,CIP,CPT,DAF,DES,DDU"
      nVlTotLocEnt-=EIJ->EIJ_VFREMN
   ENDIF
   */

   EIJ->(DBSKIP())

ENDDO

/* AAF 17/03/08 - Remove o Frete das adicões que possuem incotem com frete.
                  O calculo feito pelo Siscomex trunca o rateio do frete para as adições, o que resulta num valor no local de embarque maior,
                  que ficaria diferente do calculo arredondado caso hajam muitas adições. (ver chamado 071206).
*/
//**
EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB))
DO While !EIJ->(Eof()) .And.;
		 EIJ->EIJ_FILIAL==cFilEIJ.AND.;
 		 EIJ->EIJ_HAWB  ==SW6->W6_HAWB
   IF EIJ->EIJ_ADICAO == "MOD"
      EIJ->(DBSKIP())
      LOOP
   ENDIF

   IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
      //nVlTotLocEnt-= NoRound( EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN) * SW6->W6_TX_FRET / nVlTotPesoL,2) //Trunca na 2a casa decimal. //NCF - 23/05/2012 - Siscomex está considerando arredondado
      nVlTotLocEnt-= DI500Trans(EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN) * SW6->W6_TX_FRET / nVlTotPesoL,2)
      nVlTot -= DI500Trans(EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN)/ nVlTotPesoL,2)
   ENDIF

   // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEG")/*FDR - 28/12/10*/  //EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
      nVlTotLocEnt -= EIJ->EIJ_VSEGMN
      nVlTot -= DI500TRANS(EIJ->EIJ_VSEGMN/SW6->W6_TX_FRET)
   ENDIF

   EIJ->(DBSKIP())
ENDDO
//**

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DEPOIS_CALC_PESO_TOTAL"),)

// Tipo de Registro "01" - Informações gerais da DI
nTamLin := 824
              //Seq  Conteudo                    Tipo Tam  Dec  Ini   Fim
Aadd(aLoadTxt,{ 01 ,"01"                           , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB                   , "C" , 15 , 0 , 003 , 017})// Processo
Aadd(aLoadTxt,{ 03 ,0                              , "N" , 10 , 0 , 018 , 027})// Nr. Protocolo da DI
Aadd(aLoadTxt,{ 04 ,SW6->W6_QTD_ADI                , "N" , 03 , 0 , 028 , 030,"qtdeAdicoes"})// Quantidade de Adiacoes
Aadd(aLoadTxt,{ 05 ,SW6->W6_TIPODES                , "N" , 02 , 0 , 031 , 032})// Tipo de Declaracao
Aadd(aLoadTxt,{ 06 ,cTipoEnv                       , "N" , 01 , 0 , 033 , 033})// Motivo Transmissao
Aadd(aLoadTxt,{ 07 ,SYT->YT_TIPO                   , "N" , 01 , 0 , 034 , 034})// Tipo Importador
Aadd(aLoadTxt,{ 08 ,SYT->YT_CGC                    , "C" , 14 , 0 , 035 , 048})// CGC Importador
Aadd(aLoadTxt,{ 09 ,SYT->YT_PAIS                   , "N" , 03 , 0 , 049 , 051})// Pais Importador
Aadd(aLoadTxt,{ 10 ,SYT->YT_NOME                   , "C" , 60 , 0 , 052 , 111})// Nome Importador
Aadd(aLoadTxt,{ 11 ,SYT->YT_TEL_IMP                , "C" , 15 , 0 , 112 , 126})// Tel. Importador
Aadd(aLoadTxt,{ 12 ,SYT->YT_ENDE                   , "C" , 40 , 0 , 127 , 166})// Logr. Importador
Aadd(aLoadTxt,{ 13 ,SYT->YT_NR_END                 , "C" , 06 , 0 , 167 , 172})// Nr. Importador
If SYT->(FieldPos("YT_COMPEND")) > 0                                           // TLM - 09/06/2008 Inclusão do campo SYT->YT_COMPEND
   Aadd(aLoadTxt,{ 14 ,SYT->YT_COMPEND             , "C" , 21 , 0 , 173 , 193})// Compl. Importador
Else
   Aadd(aLoadTxt,{ 14 ,""                          , "C" , 21 , 0 , 173 , 193})// Compl. Importador
EndIf
Aadd(aLoadTxt,{ 15 ,SYT->YT_BAIRRO                 , "C" , 25 , 0 , 194 , 218})// Bairro Importador
Aadd(aLoadTxt,{ 16 ,SYT->YT_CIDADE                 , "C" , 25 , 0 , 219 , 243})// Mun. Importador
Aadd(aLoadTxt,{ 17 ,Alltrim(SYT->YT_ESTADO)        , "C" , 02 , 0 , 244 , 245})// UF Importador
Aadd(aLoadTxt,{ 18 ,SYT->YT_CEP                    , "N" , 08 , 0 , 246 , 253})// CEP Importador
Aadd(aLoadTxt,{ 19 ,SYT->YT_CPF_REP                , "N" , 11 , 0 , 254 , 264})// CPF Representante
Aadd(aLoadTxt,{ 20 ,SW6->W6_MODAL_D                , "N" , 01 , 0 , 265 , 265})// Modalidade Despacho jonato
Aadd(aLoadTxt,{ 21 ,If(SW6->W6_FUNDAP="1","S","N") , "C" , 01 , 0 , 266 , 266})// Operação FUNDAP
Aadd(aLoadTxt,{ 22 ,SW6->W6_URF_ENT                , "N" , 07 , 0 , 267 , 273})// URF Entr Carga
Aadd(aLoadTxt,{ 23 ,SW6->W6_URF_DES                , "N" , 07 , 0 , 274 , 280})// URF Despacho
Aadd(aLoadTxt,{ 24 ,SW6->W6_PRO_IMP                , "N" , 01 , 0 , 281 , 281})// Tipo Consignatario
Aadd(aLoadTxt,{ 25 ,SW6->W6_CGC_OUT                , "C" , 14 , 0 , 282 , 295})// CGC Consignatario
Aadd(aLoadTxt,{ 26 ,""                             , "C" , 60 , 0 , 296 , 355})// Nome Consignatario
Aadd(aLoadTxt,{ 27 ,SW6->W6_PAISPRO                , "N" , 03 , 0 , 356 , 358})// Pais Proc. Carga         //SY9->Y9_PAIS AWR 12/11/01
Aadd(aLoadTxt,{ 28 ,SubStr(SYQ->YQ_COD_DI,1,1)     , "N" , 02 , 0 , 359 , 360})// Via de Transporte
Aadd(aLoadTxt,{ 29 ,If(SW6->W6_MULTIMO="1","S","N"), "C" , 01 , 0 , 361 , 361})// Multimodal
Aadd(aLoadTxt,{ 30 ,If(Substr(SYQ->YQ_COD_DI,1,1)=="7",SW6->W6_IDENTVE,), "C" , 15 , 0 , 362 , 376})// Numero do Veiculo Transporte   JONATO
//TRP - 03/11/2011 - Enviar o Nome do Veículo/Embarcação.
EE6->(DbSetOrder(1))
If EE6->(DbSeek(xFilial("EE6")+SW6->W6_IDENTVE))
   Aadd(aLoadTxt,{ 31 ,If(SubStr(SYQ->YQ_COD_DI,1,1)<>"7",LEFT(EE6->EE6_NOME,30),), "C" , 30 , 0 , 377 , 406})// Nome Veiculo
Else
   Aadd(aLoadTxt,{ 31 ,Space(30), "C" , 30 , 0 , 377 , 406})// Nome Veiculo
Endif
Aadd(aLoadTxt,{ 32 ,SA4->A4_NOME                   , "C" , 60 , 0 , 407 , 466})// Transport.
Aadd(aLoadTxt,{ 33 ,SW6->W6_PAISVEI                , "N" , 03 , 0 , 467 , 469})// Bandeira TRansportador
Aadd(aLoadTxt,{ 34 ,IF(!SubStr(SYQ->YQ_COD_DI,1,1)='9',"1",)  ,"N",  01 ,   0 , 470 , 470})// Tipo Ag Carga
Aadd(aLoadTxt,{ 35 ,SY4->Y4_CGC                    , "C" , 14 , 0 , 471 , 484})// Agente de Carga
Aadd(aLoadTxt,{ 36 ,SW6->W6_TIPOCON                , "N" , 02 , 0 , 485 , 486})// Tipo Doc Carga

//IF SubStr(SYQ->YQ_COD_DI,1,1) == '1'
//   Aadd(aLoadTxt,{ 37 ,SW6->W6_PRCARGA             , "C" , 36 , 0 , 487 , 522})// Presenca de Carga
//ELSE
// Aadd(aLoadTxt,{ 37 ,SW6->W6_HOUSE               , "C" , 18 , 0 , 487 , 504})// Docto Carga
   Aadd(aLoadTxt,{ 37 ,LEFT(SW6->W6_PRCARGA,18)    , "C" , 18 , 0 , 487 , 504})// Docto Carga
   Aadd(aLoadTxt,{ 38 ,SW6->W6_MAWB                , "C" , 18 , 0 , 505 , 522})// Docto Carga Mast
//ENDIF
Aadd(aLoadTxt,{ 39 ,SYR->YR_CID_ORI                , "C" , 50 , 0 , 523 , 572})// Local Embarque         //SY9->Y9_DESCR AWR 13/11/2001
Aadd(aLoadTxt,{ 40 ,SW6->W6_DT_EMB                 , "N" , 08 , 0 , 573 , 580})// Data Embarque
Aadd(aLoadTxt,{ 41 ,SW6->W6_PESO_BR                , "N" , 15 , 5 , 581 , 595})// Peso Bruto
Aadd(aLoadTxt,{ 42 ,nVlTotPesoL                    , "N" , 15 , 5 , 596 , 610,"vlPesoLiquido"})// Peso Liquido
Aadd(aLoadTxt,{ 43 ,SW6->W6_CHEG                   , "N" , 08 , 0 , 611 , 618})// Dt Gheg Carga
Aadd(aLoadTxt,{ 44 ,SW6->W6_TIPODOC                , "N" , 01 , 0 , 619 , 619})// Tipo Manifesto
Aadd(aLoadTxt,{ 45 ,SW6->W6_IDEMANI                , "C" , 15 , 0 , 620 , 634})// Nr Manisfesto
Aadd(aLoadTxt,{ 46 ,SW6->W6_REC_ALF                , "N" , 07 , 0 , 635 , 641,"cdRecintoAduaneiro"})// Recinto Alfandegado
Aadd(aLoadTxt,{ 47 ,SW6->W6_VLFREPP                , "N" , 15 , 2 , 642 , 656})// Frete Prepaid
Aadd(aLoadTxt,{ 48 ,SW6->W6_VLFRECC                , "N" , 15 , 2 , 657 , 671})// Frete Collect
Aadd(aLoadTxt,{ 49 ,SW6->W6_VLFRETN                , "N" , 15 , 2 , 672 , 686})// Frete TNAC MNEG
cMoeda := ""
If !Empty(SW6->W6_FREMOED)
	cMoeda := Posicione("SYF",1,cFilSYF+SW6->W6_FREMOED,"YF_COD_GI")
EndIf
Aadd(aLoadTxt,{ 50 ,cMoeda                         , "N" , 03 , 0 , 687 , 689})// Moeda Frete
Aadd(aLoadTxt,{ 51 ,ValorFrete(SW6->W6_HAWB,,,1,)  , "N" , 15 , 2 , 690 , 704})// Total Frete MN
Aadd(aLoadTxt,{ 52 ,SW6->W6_VL_USSE                , "N" , 15 , 2 , 705 , 719,"vlSeguro"})// Total Seguro MNEG
cMoeda := ""
If !Empty(SW6->W6_SEGMOED)
	cMoeda := Posicione("SYF",1,cFilSYF+SW6->W6_SEGMOED,"YF_COD_GI")
EndIf
Aadd(aLoadTxt,{ 53 ,cMoeda                         , "N" , 03 , 0 , 720 , 722})// Moeda Seguro
Aadd(aLoadTxt,{ 54 ,SW6->W6_VLSEGMN                , "N" , 15 , 2 , 723 , 737})// Total Seguro MN
Aadd(aLoadTxt,{ 55 ,0                              , "N" , 15 , 2 , 738 , 752})// Total Despesas MNEG
Aadd(aLoadTxt,{ 56 ,0                              , "N" , 03 , 0 , 753 , 755})// Moeda Despesas
Aadd(aLoadTxt,{ 57 ,0                              , "N" , 15 , 2 , 756 , 770})// Total Despesas MN
Aadd(aLoadTxt,{ 58 ,nVlTotLocEnt                   , "N" , 15 , 2 , 771 , 785})// Total MLE MN    SW6->W6_FOB_TOT
Aadd(aLoadTxt,{ 59 ,SW6->W6_UTILCON                , "N" , 01 , 0 , 786 , 786})// Util Doc. Carga
Aadd(aLoadTxt,{ 60 ,"2"                            , "N" , 01 , 0 , 787 , 787})// Cod. Origem da DI
Aadd(aLoadTxt,{ 61 ,/*aqui nil*/                   , "N" , 02 , 0 , 788 , 789})// Cod. Mot. da Retific.
Aadd(aLoadTxt,{ 62 ,/*aqui nil*/                   , "N" , 02 , 0 , 790 , 791})// Nr. Reg. Decl. Retific.
Aadd(aLoadTxt,{ 63 ,0                              , "N" , 10 , 0 , 792 , 801})// Nr. Decl. a retificar
Aadd(aLoadTxt,{ 64 ,SW6->W6_SETORRAR               , "N" , 03 , 0 , 802 , 804})// Cod. Setor de Armaz.
Aadd(aLoadTxt,{ 65 ,If(Empty(SW6->W6_CTAPGTO),"2","1"), "N" , 01 , 0 , 805 , 805})// Tipo pagto. tribut.
Aadd(aLoadTxt,{ 66 ,If(cTipoEnv="2",SW6->W6_CTAPGTO,) , "C" , 19 , 0 , 806 , 824})// Conta Corente
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"INF_GERAIS_DI_SISCOMEX"),)		//CDS 1/9/05

aAdd(aCapaDAI,{"",0,"UFImportador",DI500UfCod(Alltrim(SYT->YT_ESTADO))})
cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aCapaDAI)

If !lXml
   FWrite(nHdl,cCpo,Len(cCpo))
EndIf

IncProc(STR0165) // STR0165 "Gravando dados da D.I."


// Tipo de Registro "02" - Ocorrencias de processos na declaracao
EIG->(dbSetOrder(1)) // EIG_FILIAL+EIG_HAWB+EIG_CODIGO
EIG->(dbSeek(cFilEIG+SW6->W6_HAWB))
DO While !EIG->(Eof()) .And.;
         EIG->EIG_FILIAL == cFilEIG .And.;
 		 EIG->EIG_HAWB   == SW6->W6_HAWB

    If EIG->EIG_CODIGO == "3" .Or. EIG->EIG_CODIGO == "4"
       lProcVincEsp := .T.
    EndIf
	aLoadTxt := {}
	nTamLin := 038
	             // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
	Aadd(aLoadTxt,{ 01 ,"02"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
	Aadd(aLoadTxt,{ 03 ,EIG->EIG_CODIGO  , "N" , 01 , 0 , 018 , 018})// Tipo de Processo
	Aadd(aLoadTxt,{ 04 ,EIG->EIG_NUMERO  , "C" , 20 , 0 , 019 , 038})// Nr. identificador do processo

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin)
    If !lXml
   	   FWrite(nHdl,cCpo,Len(cCpo))
   	EndIf

	EIG->(dbSkip())

EndDo
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

/* Tipo de Registro "03" - Ocorrencias de documentos de instrucao de despacho */
EIF->(dbSetOrder(1)) /* EIF_FILIAL+EIF_HAWB */
EIF->(dbSeek(cFilEIF+SW6->W6_HAWB))
DO While !EIF->(Eof()) .And.;
		 EIF->EIF_FILIAL == cFilEIF	.And.;
 		 EIF->EIF_HAWB   == SW6->W6_HAWB

	aLoadTxt := {}
	nTamLin := 044
	             /* Seq  Conteudo           Tipo Tam  Dec  Ini   Fim */
	Aadd(aLoadTxt,{ 01 ,"03"             , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro        */
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})/* Processo                */
	Aadd(aLoadTxt,{ 03 ,EIF->EIF_CODIGO  , "N" , 02 , 0 , 018 , 019})/* Tipo Docto de Instrucao */
	Aadd(aLoadTxt,{ 04 ,EIF->EIF_DOCTO   , "C" , 25 , 0 , 020 , 044})/* Nr. Docto de Instrucao  */

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin)
	If !lXml
	   FWrite(nHdl,cCpo,Len(cCpo))
    EndIf
	EIF->(dbSkip())

EndDo
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

/* Tipo de Registro "04" - Ocorrencias de embalagens de carga */
EIH->(dbSetOrder(1)) /* EIH_FILIAL+EIH_HAWB+EIH_CODIGO */
EIH->(dbSeek(cFilEIH+SW6->W6_HAWB))
DO While !EIH->(Eof()) .And.;
		 EIH->EIH_FILIAL == cFilEIH	.And.;
 		 EIH->EIH_HAWB   == SW6->W6_HAWB

	aLoadTxt := {}
	nTamLin := 024
	             /* Seq  Conteudo           Tipo Tam  Dec  Ini   Fim */
	Aadd(aLoadTxt,{ 01 ,"04"             , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro     */
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})/* Processo             */
	Aadd(aLoadTxt,{ 03 ,EIH->EIH_CODIGO  , "N" , 02 , 0 , 018 , 019})/* Tipo de Embalagem    */
	Aadd(aLoadTxt,{ 04 ,EIH->EIH_QTDADE  , "N" , 05 , 0 , 020 , 024})/* Qtd. Volume de carga */

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

	If !lXml
       FWrite(nHdl,cCpo,Len(cCpo))
	EndIf

	EIH->(dbSkip())

EndDo
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

/* Tipo de Registro "05" - Ocorrencias de carga armazenada */
If !Empty(SW6->W6_ARMAZEM)

	aLoadTxt := {}
	nTamLin := 027
	             /* Seq  Conteudo           Tipo Tam  Dec  Ini   Fim */
	Aadd(aLoadTxt,{ 01 ,"05"             , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro */
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})/* Processo         */
	Aadd(aLoadTxt,{ 03 ,SW6->W6_ARMAZEM  , "C" , 10 , 0 , 018 , 027})/* Nome do Armazem  */

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

	If !lXml
	   FWrite(nHdl,cCpo,Len(cCpo))
	EndIf
EndIf
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

/* Tipo de Registro "07" - Ocorrencias de pagamentos de tributos */
EII->(dbSetOrder(1)) /* EII_FILIAL+EII_HAWB+EII_CODIGO */
EII->(dbSeek(cFilEII+SW6->W6_HAWB))
DO While !EII->(Eof()) .And.;
		 EII->EII_FILIAL == cFilEII	.And.;
 		 EII->EII_HAWB   == SW6->W6_HAWB

	IF EII->EII_VLTRIB > 0
       aLoadTxt := {}
  	   nTamLin := 069
       cTag := ""
       If AllTrim(EII->EII_CODIGO) == "2892"
          cTag := "vlII"
       ElseIf AllTrim(EII->EII_CODIGO) == "3345"
          cTag := "vlIPI"
       ElseIf AllTrim(EII->EII_CODIGO) == "5602" .Or. AllTrim(EII->EII_CODIGO) == "5629"
          cTag := "vlPisCofins"
       ElseIf AllTrim(EII->EII_CODIGO) == "5529"
          cTag := "vlAntiDumping"
       EndIf

	               // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
   	   Aadd(aLoadTxt,{ 01 ,"07"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
	   Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
	   Aadd(aLoadTxt,{ 03 ,EII->EII_CODIGO  , "N" , 04 , 0 , 018 , 021})//Cod. Receita Tributaria
	   Aadd(aLoadTxt,{ 04 ,If(lProcVincEsp .And. lExistEII , EII->EII_BANCO,SW6->W6_BCOPGTO)   , "N" , 03 , 0 , 022 , 024})// Cod. Banco pagto tributo
	   Aadd(aLoadTxt,{ 05 ,If(lProcVincEsp .And. lExistEII , EII->EII_AGENCI,SW6->W6_AGEPGTO)  , "N" , 04 , 0 , 025 , 028})// Cod. Agencia pagto tributo
	   Aadd(aLoadTxt,{ 06 ,EII->EII_VLTRIB  , "N" , 15 , 2 , 029 , 043,cTag})// Valor do tributo pago
       Aadd(aLoadTxt,{ 07 ,EII->EII_DT_PAG  , "N" , 08 , 0 , 044 , 051})// Data do Pagamento do Tributo        dDataBase
	   Aadd(aLoadTxt,{ 08 ,0                , "N" , 09 , 2 , 052 , 060,"vlMultasJuros"})// Valor multa por acaso pagto
	   Aadd(aLoadTxt,{ 09 ,0                , "N" , 09 , 2 , 061 , 069,"vlMultasJuros"})// Valor juros por atraso pagto

	   cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aCapaDAI)

	   If !lXml
	      FWrite(nHdl,cCpo,Len(cCpo))
	   EndIf

    ENDIF

	EII->(dbSkip())

EndDo
IncProc(STR0165) // STR0165 "Gravando dados da D.I."

// Tipo de Registro "08" - Ocorrencias de informacoes complementares
nTamMemo := AvSx3("W6_VM_COMP",3)
mMemo    := MSMM(SW6->W6_COMPLEM,nTamMemo)
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ENVIO_COMPLE"),)//igor chiba 18/02/2010
Totlin   := MlCount(mMemo,nTamMemo)
For i:=1 To Totlin

	aLoadTxt := {}
	nTamLin := nTamMemo+17
	             // Seq  Conteudo                    Tipo Tam  Dec  Ini   Fim
	Aadd(aLoadTxt,{ 01 ,"08"                       , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro */
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB               , "C" , 15 , 0 , 003 , 017})/* Processo         */
	Aadd(aLoadTxt,{ 03 ,MemoLine(mMemo,nTamMemo,i) , "C" , nTamMemo , 0 , 018 , nTamLin})/* Texto  */

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

	If !lXml
	   FWrite(nHdl,cCpo,Len(cCpo))
    EndIf
Next i

// TDF - 29/07/11
/* Tipo de Registro "09" - Ocorrencias de documento Mercosul - Novo tratamento de DE Mercosul */
IF lEJ9
	   EJ9->(DBSETORDER(1))
	   EJ9->(DBSEEK(cFilEJ9+AVKEY(SW6->W6_HAWB,"EJ9_HAWB")))
	   DO WHILE !EJ9->(Eof()) .And.;
			 EJ9->EJ9_FILIAL == cFilEJ9	.And.;
 			 ALLTRIM(EJ9->EJ9_HAWB)    == ALLTRIM(SW6->W6_HAWB) .AND. EMPTY(EJ9->EJ9_ADICAO)

	   IF lMERCODI .AND. !EMPTY(EJ9->EJ9_DEMERC)
	      aLoadTxt := {}
		  nTamLin := 75
	                   // Seq  Conteudo                    Tipo Tam  Dec  Ini   Fim
	      Aadd(aLoadTxt,{ 01 ,"09"                       , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro */
	      Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB               , "C" , 15 , 0 , 003 , 017})/* Processo         */
	      Aadd(aLoadTxt,{ 03 ,EJ9->EJ9_DEMERC            , "C" , 16 , 0 , 018 , 033})/* DE Mercosul */
	      Aadd(aLoadTxt,{ 04 ,EJ9->EJ9_REINIC            , "C" , 04 , 0 , 034 , 037})/* Faixa inicial de itens da DE Mercosul */
	      Aadd(aLoadTxt,{ 05 ,EJ9->EJ9_REFINA            , "C" , 04 , 0 , 038 , 041})/* Faixa final de itens da DE Mercosul */

          cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

          If !lXml
             FWrite(nHdl,cCpo,Len(cCpo))
          EndIf

	   ENDIF
	      EJ9->(DBSKIP())
       ENDDO
ELSE
// EOB - 13/03/2008 - Dados referente ao Mercosul
    IF lMERCODI .AND. !EMPTY(SW6->W6_DEMERCO)
       aLoadTxt := {}
       nTamLin  := 41

	             // Seq  Conteudo                    Tipo Tam  Dec  Ini   Fim
	   Aadd(aLoadTxt,{ 01 ,"09"                       , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro */
	   Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB               , "C" , 15 , 0 , 003 , 017})/* Processo         */
       Aadd(aLoadTxt,{ 03 ,SW6->W6_DEMERCO            , "C" , 16 , 0 , 018 , 033})/* DE Mercosul */
	   Aadd(aLoadTxt,{ 04 ,SW6->W6_REINIC             , "C" , 04 , 0 , 034 , 037})/* Faixa inicial de itens da DE Mercosul */
 	   Aadd(aLoadTxt,{ 05 ,SW6->W6_REFINAL            , "C" , 04 , 0 , 038 , 041})/* Faixa final de itens da DE Mercosul */

   	   cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

	   If !lXml
	      FWrite(nHdl,cCpo,Len(cCpo))
	   EndIf

	EndIf
ENDIF

nTamIMemo:= AvSx3("B1_VM_GI",3)
nTamDesc := AvSx3("W8_DESC_VM",3)
cPictItem:=AVSX3("B1_COD",6)
SYA->(DbSetOrder(1))
If SYA->(DbSeek(xFilial("SYA")+SW6->W6_PAISPRO))
   aAdd(aCapaDAI,{"",0,"cdPaisProcedencia",PadL(SYA->YA_SISEXP,5,"0")})
EndIf
aAdd(aCapaDAI,{"",0,"nrDocumento"      ,SW6->W6_DI_NUM})
aAdd(aCapaDAI,{"",0,"dtDocumento"      ,DtoS(SW6->W6_DTREG_D)})
aAdd(aCapaDAI,{"",0,"numRetificacao"   ,cRetif})
aAdd(aCapaDAI,{"",0,"vlCide" ,0})
aAdd(aCapaDAI,{"",0,"vlTaxasDiversas" ,0})
aAdd(aCapaDAI,{"",0,"vlTaxasCapatazia" ,0})
aAdd(aCapaDAI,{"",0,"vlTaxaDolar"      ,SW6->W6_TX_US_D})
aAdd(aCapaDAI,{"",0,"txInfoCompl"      ,MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3)) })
aAdd(aCapaDAI,{"",0,"vlFob"            ,nVlTot})
Aadd(aCapaDAI,{"",0,"vlFrete"          ,ValorFrete(SW6->W6_HAWB,,,2,)})

SJB->(DbSetOrder(1))
If SJB->(FieldPos("JB_CODERP")) > 0 .And. SJB->(DbSeek(xFilial('SJB')+SW6->W6_TIPODES ))
   aAdd(aCapaDAI,{"",0,"tipoDIe" ,SJB->JB_CODERP})
EndIf

Aadd(aLoadTxt,{ 05 ,               , "N" , 02 , 0 , 031 , 032,})// Tipo de Declaracao   tipoDIe
aAdd(aLoadXML,aCapaDAI)

SW8->(dbSetOrder(4)) /* W8_FILIAL+W8_HAWB+W8_ADICAO    */
// A Seguir acrescenta as adicoes
EIJ->(dbSetOrder(1)) /* EIJ_FILIAL+EIJ_HAWB+EIJ_ADICAO */
EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB))
DO While !EIJ->(Eof()) .And.;
		 EIJ->EIJ_FILIAL == cFilEIJ	.And.;
 		 EIJ->EIJ_HAWB   == SW6->W6_HAWB

    nTotAdi := 0

    IF EIJ->EIJ_ADICAO == "MOD"
       EIJ->(DBSKIP())
       LOOP
    ENDIF

	IncProc(STR0166 + AllTrim(EIJ->EIJ_ADICAO)) // STR0166 "Gravando dados da Adição: "

	nValorCapatazia := 0
    aAdicoes := {}
    aItensAdDAI := {}

    //NCF - 08/07/2011 - Calcular o valor da mercadoria das adições com acréscimos e deduções
	nAcrescimo := nDeducao := nAcr_LocEmb := nDed_LocEmb := nVlTotLocEnt := nVlTtLocEmb:=0
	EIN->(DBSEEK(cFilEIN+EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO))
    DO WHILE EIN->(!EOF()) .AND. EIN->EIN_HAWB  ==EIJ->EIJ_HAWB   .AND.;
                                EIN->EIN_ADICAO==EIJ->EIJ_ADICAO .AND.;
                                EIN->EIN_FILIAL==cFilEIN
       IF EIN->EIN_TIPO == '1'
          nAcr_LocEmb+= EIN->EIN_VLMLE
          nAcrecimo  += EIN->EIN_VLMMN
       ELSE
          nDed_LocEmb += EIN->EIN_VLMLE
          nDeducao    += EIN->EIN_VLMMN
       ENDIF

       If EIN->EIN_CODIGO == "12"
          If Empty(EIN->EIN_FOBMOE)
             nValorCapatazia :=  EIN->EIN_VLMLE
          Else
             nValorCapatazia :=  EIN->EIN_VLMMN
          EndIf
       EndIf

       EIN->(DBSKIP())
    ENDDO

    nVlTtLocEmb := EIJ->EIJ_VLMLE+(nAcr_LocEmb-nDed_LocEmb)
    nVlTotLocEnt:= EIJ->EIJ_VLMMN+(nAcrecimo-nDeducao)

    IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE")                                        //NCF - 08/07/2011 - valor é o da moeda no local de embarque
       nVlTtLocEmb -= NoRound( EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN) /* * SW6->W6_TX_FRET */ / nVlTotPesoL,2) //Trunca na 2a casa decimal.
       nVlTotLocEnt-= NoRound( EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN)  * SW6->W6_TX_FRET / nVlTotPesoL,2)
    ENDIF

    // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
    IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEG")
       nVlTtLocEmb -= EIJ->EIJ_VSEGLE
       nVlTotLocEnt-= EIJ->EIJ_VSEGMN
    ENDIF

	SW8->(dbSeek( cFilSW8 + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
	SA2->(dbSeek( cFilSA2 + SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ") ))

    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERATXT_REG10_01"),)

	/* Tipo de Registro "10" - Informações especificas da adiacao */
	aLoadTxt := {}
	nTamLin := 1140

    //** AAF 25/03/08 - Ajuste do tamanho.
    If lMercoDI
       nTamLin := 1141
    EndIf

	             // Seq  Conteudo          Tipo Tam  Dec  Ini   Fim //
	Aadd(aLoadTxt,{ 01 ,"10"            , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
	Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})// Processo
	Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020,"numAdicao"})// Nr. da Adiacao
	Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_URFENT , "N" , 07 , 0 , 021 , 027})// URF Entr. Merc.
	Aadd(aLoadTxt,{ 05 ,SubStr(SYQ->YQ_COD_DI,1,1) , "N" , 02 , 0 , 028 , 029})// Via Transporte
	Aadd(aLoadTxt,{ 06 ,If(SW6->W6_MULTIMO="1","S","N"), "C" , 01 , 0 , 030 , 030})// Multimodal
	Aadd(aLoadTxt,{ 07 ,SA2->A2_NOME    , "C" , 60 , 0 , 031 , 090})// Forn. Estr.
	Aadd(aLoadTxt,{ 08 ,SA2->A2_END     , "C" , 40 , 0 , 091 , 130})// Forn. Logradouro
	Aadd(aLoadTxt,{ 09 ,SA2->A2_NR_END  , "C" , 06 , 0 , 131 , 136})// Forn. Numero
	Aadd(aLoadTxt,{ 10 ,SA2->A2_ENDCOMP , "C" , 21 , 0 , 137 , 157})// Forn. Complemento
	Aadd(aLoadTxt,{ 11 ,SA2->A2_MUN     , "C" , 25 , 0 , 158 , 182})// Forn. Cidade
	Aadd(aLoadTxt,{ 12 ,SA2->A2_ESTADO  , "C" , 25 , 0 , 183 , 207})// Forn. Estado
	Aadd(aLoadTxt,{ 13 ,SA2->A2_PAIS    , "N" , 03 , 0 , 208 , 210})// Pais Aqui. Merc.
	Aadd(aLoadTxt,{ 14 ,EIJ->EIJ_TEC    , "N" , 08 , 0 , 211 , 218})// Mercadoria NCM
	Aadd(aLoadTxt,{ 15 ,EIJ->EIJ_PAISPR , "N" , 03 , 0 , 219 , 221})// Pais Proc. Merc.
	Aadd(aLoadTxt,{ 16 ,EIJ->EIJ_FABFOR , "N" , 01 , 0 , 222 , 222})// Ausencia Fabric.
	nRecSA2 := SA2->(Recno())
	SA2->(dbSeek( cFilSA2 + SW8->W8_FABR+EICRetLoja("SW8", "W8_FABLOJ") ))
    IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERATXT_REG10_02"),)
	//TRP-02/10/08- Só gravar informações do Fabricante caso o Fabricante seja diferente do Exportador.
	If EIJ->EIJ_FABFOR == "2"
	   Aadd(aLoadTxt,{ 17 ,SA2->A2_NOME    , "C" , 60 , 0 , 223 , 282})// Fabricante Merc.
	   Aadd(aLoadTxt,{ 18 ,SA2->A2_END     , "C" , 40 , 0 , 283 , 322})// Fabr. Logradouro
	   Aadd(aLoadTxt,{ 19 ,SA2->A2_NR_END  , "C" , 06 , 0 , 323 , 328})// Fabr. Numero
	   Aadd(aLoadTxt,{ 20 ,SA2->A2_ENDCOMP , "C" , 21 , 0 , 329 , 349})// Fabr. Complemento
	   Aadd(aLoadTxt,{ 21 ,SA2->A2_MUN     , "C" , 25 , 0 , 350 , 374})// Fabr. Cidade
	   Aadd(aLoadTxt,{ 22 ,SA2->A2_ESTADO  , "C" , 25 , 0 , 375 , 399})// Fabr. Estado
	   Aadd(aLoadTxt,{ 23 ,SA2->A2_PAIS    , "N" , 03 , 0 , 400 , 402})// Pais Origem Me      //NCF - 23/03/2012 - País de Origem é o do Fabricante
	ElseIf EIJ->EIJ_FABFOR == "1"
	   SA2->(DbGoTo(nRecSA2))                                                                 //NCF - 23/03/2012 - Recupera o cadastro do Exportador
	   Aadd(aLoadTxt,{ 17 ,                , "C" , 60 , 0 , 223 , 282})// Fabricante Merc.
	   Aadd(aLoadTxt,{ 18 ,                , "C" , 40 , 0 , 283 , 322})// Fabr. Logradouro
	   Aadd(aLoadTxt,{ 19 ,                , "C" , 06 , 0 , 323 , 328})// Fabr. Numero
	   Aadd(aLoadTxt,{ 20 ,                , "C" , 21 , 0 , 329 , 349})// Fabr. Complemento
	   Aadd(aLoadTxt,{ 21 ,                , "C" , 25 , 0 , 350 , 374})// Fabr. Cidade
	   Aadd(aLoadTxt,{ 22 ,                , "C" , 25 , 0 , 375 , 399})// Fabr. Estado
       Aadd(aLoadTxt,{ 23 ,SA2->A2_PAIS    , "N" , 03 , 0 , 400 , 402})// Pais Origem Me 	  //NCF - 23/03/2012 - País de Origem é o do Exportador
    Else                                                                                      //                   Envia o país do exportador
	   Aadd(aLoadTxt,{ 17 ,                , "C" , 60 , 0 , 223 , 282})// Fabricante Merc.
	   Aadd(aLoadTxt,{ 18 ,                , "C" , 40 , 0 , 283 , 322})// Fabr. Logradouro
	   Aadd(aLoadTxt,{ 19 ,                , "C" , 06 , 0 , 323 , 328})// Fabr. Numero
	   Aadd(aLoadTxt,{ 20 ,                , "C" , 21 , 0 , 329 , 349})// Fabr. Complemento
	   Aadd(aLoadTxt,{ 21 ,                , "C" , 25 , 0 , 350 , 374})// Fabr. Cidade
	   Aadd(aLoadTxt,{ 22 ,                , "C" , 25 , 0 , 375 , 399})// Fabr. Estado
	   If EIJ->(FieldPos("EIJ_PAISOR")) > 0 .And. !Empty(EIJ->EIJ_PAISOR)
          Aadd(aLoadTxt,{ 23 ,EIJ->EIJ_PAISOR , "N" , 03 , 0 , 400 , 402})// Pais Origem Me  //NCF - 25/04/2012 - País de Origem Indefinido(Fabricante Desconhecido)
       Else                                                               //                                      Envia o país informado na adição
          Aadd(aLoadTxt,{ 23 ,SA2->A2_PAIS    , "N" , 03 , 0 , 400 , 402})// Pais Origem Me  //NCF - 25/04/2012 - País de Origem Indefinido(Fabricante Desconhecido)
       EndIf                                                              //                                      Envia o país do fornecedor
	Endif

	Aadd(aLoadTxt,{ 24 ,EIJ->EIJ_TEC    , "N" , 10 , 0 , 403 , 412})// Merc. NBM SH
	Aadd(aLoadTxt,{ 25 ,EIJ->EIJ_NALANC , "N" , 07 , 0 , 413 , 419})// Merc. NBM NCCA
	Aadd(aLoadTxt,{ 26 ,EIJ->EIJ_NALASH , "N" , 08 , 0 , 420 , 427})// Merc. Naladi SH
	Aadd(aLoadTxt,{ 27 ,EIJ->EIJ_PESOL  , "N" , 15 , 5 , 428 , 442,"vlPesoLiquido"})// Peso Liquido
	Aadd(aLoadTxt,{ 28 ,EIJ->EIJ_QT_EST , "N" , 14 , 5 , 443 , 456})// Qt. Un. Estat.
	Aadd(aLoadTxt,{ 29 ,EIJ->EIJ_APLICM , "N" , 01 , 0 , 457 , 457})// Aplic. Mercad.
	cMoeda := ""
	If !Empty(EIJ->EIJ_MOEDA)
		cMoeda := Posicione("SYF",1,cFilSYF+EIJ->EIJ_MOEDA,"YF_COD_GI")
	EndIf
	Aadd(aLoadTxt,{ 30 ,cMoeda          , "N" , 03 , 0 , 458 , 460})// Moeda Negociada
	Aadd(aLoadTxt,{ 31 ,EIJ->EIJ_INCOTE , "C" , 03 , 0 , 461 , 463})// Incoterms Venda
	Aadd(aLoadTxt,{ 32 ,EIJ->EIJ_LOCVEN , "C" , 60 , 0 , 464 , 523})// Loc. Cond. Venda
	Aadd(aLoadTxt,{ 33 ,EIJ->EIJ_VLMLE  , "N" , 15 , 2 , 524 , 538,"vlFob"})// Val Merc. C. Ven.
    Aadd(aLoadTxt,{ 34 ,EIJ->EIJ_VLMMN  , "N" , 15 , 2 , 539 , 553})// Val Merc. Ven. MN
    nTotAdi += EIJ->EIJ_VLMMN

	//NCF - 23/03/2012 - Não enviar o valor do frete quando o incoterm já prever o frete
    If AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE")
       Aadd(aLoadTxt,{ 35 , 0 , "N" , 15 , 2 , 554 , 568,"vlFrete"})// Val Fr. Mer MNEG
       Aadd(aLoadTxt,{ 36 , 0 , "N" , 03 , 0 , 569 , 571})// MD Frete Merc.
    Else
       Aadd(aLoadTxt,{ 35 ,EIJ->EIJ_VLFRET , "N" , 15 , 2 , 554 , 568,"vlFrete"})// Val Fr. Mer MNEG
       cMoeda := ""
	   If !Empty(EIJ->EIJ_MOEFRE)
	      cMoeda := Posicione("SYF",1,cFilSYF+EIJ->EIJ_MOEFRE,"YF_COD_GI")
       EndIf
       Aadd(aLoadTxt,{ 36 ,cMoeda          , "N" , 03 , 0 , 569 , 571})// MD Frete Merc.
    EndIf

	Aadd(aLoadTxt,{ 37 ,EIJ->EIJ_VFREMN , "N" , 15 , 2 , 572 , 586})// Val Fr. Merc. MN - Real
    nTotAdi += EIJ->EIJ_VFREMN

	//NCF - 23/03/2012 - Não enviar o valor do seguro quando o incoterm já prever o seguro
	If AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEGURO")
       Aadd(aLoadTxt,{ 38 ,0 , "N" , 15 , 2 , 587 , 601,"vlSeguro"})// Val Seg. Merc. MNEG
	   Aadd(aLoadTxt,{ 39 ,0 , "N" , 03 , 0 , 602 , 604})// Moeda Seg.Merc.
	Else
       Aadd(aLoadTxt,{ 38 ,EIJ->EIJ_VSEGLE , "N" , 15 , 2 , 587 , 601,"vlSeguro"})// Val Seg. Merc. MNEG
	   cMoeda := ""
	   If !Empty(EIJ->EIJ_MOESEG)
	      cMoeda := Posicione("SYF",1,cFilSYF+EIJ->EIJ_MOESEG,"YF_COD_GI")
	   EndIf
	   Aadd(aLoadTxt,{ 39 ,cMoeda          , "N" , 03 , 0 , 602 , 604})// Moeda Seg.Merc.
	EndIf

	Aadd(aLoadTxt,{ 40 ,EIJ->EIJ_VSEGMN , "N" , 15 , 2 , 605 , 619})// Val. Seg. Merc. MN
    nTotAdi += EIJ->EIJ_VSEGMN
    Aadd(aLoadTxt,{ 41 ,EIJ->EIJ_METVAL , "N" , 02 , 0 , 620 , 621})// Met. Valoracao
	Aadd(aLoadTxt,{ 42 ,EIJ->EIJ_VINCCO , "N" , 01 , 0 , 622 , 622})// Vinc. Imp. Exp.
	Aadd(aLoadTxt,{ 43 ,EIJ->EIJ_TACOII , "N" , 01 , 0 , 623 , 623})// Tipo Acor. Tar.
	Aadd(aLoadTxt,{ 44 ,EIJ->EIJ_ACO_II , "C" , 03 , 0 , 624 , 626})// Acordo Aladi
	Aadd(aLoadTxt,{ 45 ,EIJ->EIJ_REGTRI , "N" , 01 , 0 , 627 , 627})// Reg. Tributario
	Aadd(aLoadTxt,{ 46 ,EIJ->EIJ_FUNREG , "N" , 02 , 0 , 628 , 629})// Fund. Leg. Reg.
	Aadd(aLoadTxt,{ 47 ,0               , "N" , 08 , 0 , 630 , 637})// Docto. Reducao
	//NCF - 23/03/2012 - Enviado o valor zerado conforme observado na estrutura gerada pelo SISCOMEX
	Aadd(aLoadTxt,{ 48 ,0/*EIJ->EIJ_VLMMN*/ /*nVlTotLocEnt*/ , "N" , 15 , 2 , 638 , 652})// Vl. Merc. Emb. MN [vl_merc_loc_emb_mn]
	Aadd(aLoadTxt,{ 49 ,0               , "N" , 15 , 2 , 653 , 667})// Despesas MNEG
	Aadd(aLoadTxt,{ 50 ,0               , "N" , 03 , 0 , 668 , 670})// Moeda Despesas
	Aadd(aLoadTxt,{ 51 ,0               , "N" , 15 , 2 , 671 , 685})// Vl. Despesas MN
	Aadd(aLoadTxt,{ 52 ,If(lSuframa,EIJ->EIJ_ALR_II,/*Nil*/) , "N" , 05 , 2 , 686 , 690})// Coef. Reduc. II     // GFP - 05/08/2013 - Tratamento Suframa
	Aadd(aLoadTxt,{ 53 ,If(lSuframa,EIJ->EIJ_VL_II,/*Nil*/)  , "N" , 15 , 2 , 691 , 705})// Vl. II C. DCR MN    // GFP - 05/08/2013 - Tratamento Suframa
	Aadd(aLoadTxt,{ 54 ,If(lSuframa,EIJ->EIJ_VL_II,/*Nil*/)  , "N" , 15 , 2 , 706 , 720})// Vl. II A Rec. ZFM   // GFP - 05/08/2013 - Tratamento Suframa
	Aadd(aLoadTxt,{ 55 ,EIJ->EIJ_TIPCOB , "N" , 01 , 0 , 721 , 721})// Cobert. Cambial
	Aadd(aLoadTxt,{ 56 ,EIJ->EIJ_MODALI , "N" , 02 , 0 , 722 , 723})// Modal. Pagto.
	Aadd(aLoadTxt,{ 57 ,EIJ->EIJ_INSTFI , "N" , 02 , 0 , 724 , 725})// Orgao Fin. Inter.
	Aadd(aLoadTxt,{ 58 ,EIJ->EIJ_MOTIVO , "N" , 02 , 0 , 726 , 727})// Mot. Sem Cob.
	Aadd(aLoadTxt,{ 59 ,EIJ->EIJ_QTPARC , "N" , 03 , 0 , 728 , 730})// Parc. Financ. 360
	Aadd(aLoadTxt,{ 60 ,EIJ->EIJ_PERPAR , "N" , 01 , 0 , 731 , 731})// Cd. Per. Pgto. 360
	Aadd(aLoadTxt,{ 61 ,EIJ->EIJ_PERIOD , "N" , 03 , 0 , 732 , 734})// Qt. Per. Pagto 360
	Aadd(aLoadTxt,{ 62 ,EIJ->EIJ_VL_FIN , "N" , 15 , 2 , 735 , 749})// Tot. Financ. 360
	Aadd(aLoadTxt,{ 63 ,EIJ->EIJ_TXA_JU , "N" , 13 , 7 , 750 , 762})// Pc. Taxa Juros
	Aadd(aLoadTxt,{ 64 ,EIJ->EIJ_TXB_JU , "N" , 04 , 0 , 763 , 766})// Cd. Taxa Juros
	Aadd(aLoadTxt,{ 65 ,EIJ->EIJ_VLM360 , "N" , 15 , 2 , 767 , 781})// Vl. Fin. Sup. 360
	Aadd(aLoadTxt,{ 66 ,EIJ->EIJ_NRROF  , "C" , 08 , 0 , 782 , 789})// Nr. ROF
	Aadd(aLoadTxt,{ 67 ,IF(EIJ->EIJ_TEMVAR="1","S","N"), "C" , 01 , 0 , 790 , 790})// Pgto. Variav 360         SN
	Aadd(aLoadTxt,{ 68 ,IF(EIJ->EIJ_TEMJUR="1","S","N"), "C" , 01 , 0 , 791 , 791})// Jur. ate360
	Aadd(aLoadTxt,{ 69 ,EIJ->EIJ_COMIAG , "N" , 06 , 3 , 792 , 797})// Pc. Com. Ag. Imp.
	Aadd(aLoadTxt,{ 70 ,EIJ->EIJ_COMIVL , "N" , 15 , 2 , 798 , 812})// Vl. Com. Ag. Imp.
	Aadd(aLoadTxt,{ 71 ,EIJ->EIJ_TPAGE  , "N" , 01 , 0 , 813 , 813})// Cd. Tip. Af. Imp.
	Aadd(aLoadTxt,{ 72 ,EIJ->EIJ_AGENID , "C" , 14 , 0 , 814 , 827})// Nr. Agente Imp.
	Aadd(aLoadTxt,{ 73 ,EIJ->EIJ_AGEBCO , "N" , 05 , 0 , 828 , 832})// Cd. Ban. Ag. Imp.
	Aadd(aLoadTxt,{ 74 ,EIJ->EIJ_AGEAGE , "N" , 04 , 0 , 833 , 836})// Cd. Age Ag. Imp.
	Aadd(aLoadTxt,{ 75 ,If(EIJ->EIJ_BENSEN="1","S","N"), "C" , 01 , 0 , 837 , 837})// Bem Encomend
	Aadd(aLoadTxt,{ 76 ,If(EIJ->EIJ_MATUSA="1","S","N"), "C" , 01 , 0 , 838 , 838})// Mater. Usado
	Aadd(aLoadTxt,{ 77 ,EIJ->EIJ_COMPLE , "C" ,250 , 0 , 839 ,1088})// Tx. Compl. Vl. Ad.
	Aadd(aLoadTxt,{ 78 ,EIJ->EIJ_MOTADI , "N" , 02 , 0 ,1089 ,1090})// Motivo ADM Temp
	Aadd(aLoadTxt,{ 79 ,/*aqui nil*/    , "N" , 15 , 2 ,2091 ,1105})// Vl. Calc. dcr dolar
	Aadd(aLoadTxt,{ 80 ,/*aqui nil*/    , "N" , 15 , 2 ,1106 ,1120})// Vl. II devido ZFM
	Aadd(aLoadTxt,{ 81 ,EIJ->EIJ_NROLI  , "N" , 10 , 0 ,1121 ,1130})// Numero da L.I.

	IF lAUTPCDI  // Bete - DI - Inclusao dos novos cpos relativos a PIS/COFINS
	   SYD->(DBSETORDER(1))
       SYD->(DBSEEK(xFilial("SYD")+EIJ->EIJ_TEC+EIJ->EIJ_EX_NCM+EIJ->EIJ_EX_NBM))
       nAliqICMS := SYD->YD_ICMS_RE

	   IF lQbgOperaca .AND. !EMPTY(EIJ->EIJ_OPERACA)
	      SWZ->(DBSETORDER(2))
	      IF SWZ->(DBSEEK(xFilial("SWZ")+EIJ->EIJ_OPERACA))
             IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0 .AND. !EMPTY(SWZ->WZ_ICMS_PC)
                nAliqICMS:= SWZ->WZ_ICMS_PC
             ELSE
	            IF EMPTY(SWZ->WZ_RED_CTE)
                   nAliqICMS:= SWZ->WZ_AL_ICMS
                ELSE
                   nAliqICMS:= SWZ->WZ_RED_CTE
                ENDIF
             ENDIF
          ENDIF
	   ENDIF
       IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERATXT_10_PC"),)
       Aadd(aLoadTxt,{ 82 ,/*nAliqICMS*/ 0 , "N" , 5 , 2 ,1131 ,1135})// Vl. Aliquota de ICMS  // GFP - 11/10/2013 - Ajustes em conformidade a Lei nº 12.865, de 9.10.2013
       Aadd(aLoadTxt,{ 83 ,EIJ->EIJ_FRB_PC , "N" , 2 , 0 ,1136 ,1137})// Fund. Legal p/ Redução de base para Pis/Cofins
       Aadd(aLoadTxt,{ 84 ,EIJ->EIJ_REG_PC , "N" , 1 , 0 ,1138 ,1138})// Regime de tributação p/ Pis/Cofins
       Aadd(aLoadTxt,{ 85 ,EIJ->EIJ_FUN_PC , "N" , 2 , 0 ,1139 ,1140})// Fundamento Legal p/ Pis/Cofins
	ENDIF

	// EOB - 13/03/08 - Informações referente ao Mercosul
	IF LMERCODI
       Aadd(aLoadTxt,{ 86 ,IF(Empty(EIJ->EIJ_IDCERT),"1",EIJ->EIJ_IDCERT) , "N" , 1 , 0 ,1141 ,1141})// Identificação do certificado Mercosul
    ENDIF

	//ACB - 04/03/2011
	IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GERATXT_MERCODI_ALT"),)

	cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

	If !lXml
	   FWrite(nHdl,cCpo,Len(cCpo))
	EndIf

	EIO->(dbSeek( cFilEIO + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO + "3" ))

	// Tipo de Registro "11" - Ocorrencias de pagamento das parcelas variaveis de cambio
	DO While !EIO->(Eof()) .And.;
			 EIO->EIO_FILIAL == cFilEIO	.And.;
 			 EIO->EIO_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIO->EIO_ADICAO == EIJ->EIJ_ADICAO .And.;
 			 EIO->EIO_TIPCOB == "3"

//     IF EIO->EIO_ADICAO == "MOD"
//        EIO->(DBSKIP())
//        LOOP
//     ENDIF

		aLoadTxt := {}
		nTamLin := 041
		             // Seq  Conteudo          Tipo Tam  Dec  Ini   Fim
		Aadd(aLoadTxt,{ 01 ,"11"            , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})// Processo
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
		Aadd(aLoadTxt,{ 04 ,SUBSTR(EIO->EIO_MESANO,3)+LEFT(EIO->EIO_MESANO,2), "N" , 06 , 0 , 021 , 026})// Dt Prev. pgto 360 dias(AAAAMM)
		Aadd(aLoadTxt,{ 05 ,EIO->EIO_VLMLE  , "N" , 15 , 2 , 027 , 041})// Vlr Prev. pgto a 360 dias.

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
		EndIf

		EIO->(dbSkip())

	EndDo

	EIO->(dbSeek( cFilEIO + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))

	/* Tipo de Registro "12" - Ocorrencias de pagamento a vista de cambio      */
	/* Tipo de Registro "13" - Ocorrencias de pagamento a antecipado de cambio */
	DO While !EIO->(Eof()) .And.;
			 EIO->EIO_FILIAL == cFilEIO	.And.;
 			 EIO->EIO_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIO->EIO_ADICAO == EIJ->EIJ_ADICAO

//     IF EIO->EIO_ADICAO == "MOD"
//        EIO->(DBSKIP())
//        LOOP
//     ENDIF

	   aLoadTxt  := {}
	   nTamLin    := 068

	   If EIO->EIO_TIPCOB = "1"
							 // Seq Conteudo          Tipo Tam  Dec  Ini   Fim
			Aadd(aLoadTxt,{ 01 ,"12"            , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
			Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})// Processo
			Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
			Aadd(aLoadTxt,{ 04 ,If(EIO->EIO_PGREAL="1","S","N"), "C" , 01 , 0 , 021 , 021})// Ind. pgto Real
			Aadd(aLoadTxt,{ 05 ,EIO->EIO_BANCO  , "N" , 05 , 0 , 022 , 026})// Cod. do Banco de Pagto
			Aadd(aLoadTxt,{ 06 ,EIO->EIO_PRACA  , "N" , 04 , 0 , 027 , 030})// Cod. da Praca de Pagt
			Aadd(aLoadTxt,{ 07 ,EIO->EIO_CAMBIO , "N" , 08 , 0 , 031 , 038})// Nr. da Operacao de Cambio
			Aadd(aLoadTxt,{ 08 ,EIO->EIO_VLMLE  , "N" , 15 , 2 , 039 , 053})// Valor vinculado na moeda
			Aadd(aLoadTxt,{ 09 ,EIO->EIO_TPCOM  , "N" , 01 , 0 , 054 , 054})// Tipo de comprador da moeda
			Aadd(aLoadTxt,{ 10 ,EIO->EIO_CGCCOM , "C" , 14 , 0 , 055 , 068})// CPF-CGC do comprador da moeda

		ElseIf EIO->EIO_TIPCOB = "2"
			             // Seq  Conteudo                    Tipo Tam  Dec  Ini   Fim
			Aadd(aLoadTxt,{ 01 ,"13"            , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
			Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})// Processo
			Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
			Aadd(aLoadTxt,{ 04 ,If(EIO->EIO_PGREAL="1","S","N"), "C" , 01 , 0 , 021 , 021})// Ind. pgto Real
			Aadd(aLoadTxt,{ 05 ,EIO->EIO_BANCO  , "N" , 05 , 0 , 022 , 026})// Cod. do Banco de Pagto
			Aadd(aLoadTxt,{ 06 ,EIO->EIO_PRACA  , "N" , 04 , 0 , 027 , 030})// Cod. da Praca de Pagt
			Aadd(aLoadTxt,{ 07 ,EIO->EIO_CAMBIO , "N" , 08 , 0 , 031 , 038})// Nr. da Operacao de Cambio
			Aadd(aLoadTxt,{ 08 ,EIO->EIO_VLMLE  , "N" , 15 , 2 , 039 , 053})// Valor vinculado na moeda
			Aadd(aLoadTxt,{ 09 ,EIO->EIO_TPCOM  , "N" , 01 , 0 , 054 , 054})// Tipo de comprador da moeda
			Aadd(aLoadTxt,{ 10 ,EIO->EIO_CGCCOM , "C" , 14 , 0 , 055 , 068})// CPF-CGC do comprador da moeda

		EndIf

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf

		EIO->(dbSkip())

	EndDo

	// Tipo de Registro "14" - Ocorrencias de Ato Vinculado
	If !Empty(AllTrim(EIJ->EIJ_ASSVIC))

		aLoadTxt := {}
		nTamLin := 045
		             // Seq  Conteudo          Tipo Tam  Dec  Ini   Fim
		Aadd(aLoadTxt,{ 01 ,"14"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro           */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                   */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao             */
		Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_ASSVIC , "N" , 01 , 0 , 021 , 021})/* Cod. do Assunto vinculado  */
		Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_ATOVIC , "C" , 05 , 0 , 022 , 026})/* Tipo do Ato Legal          */
		Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_ORGVIC , "C" , 06 , 0 , 027 , 032})/* Orgao emissor do Ato Legal */
		Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ANOVIC , "N" , 04 , 0 , 033 , 036})/* Ano do Ato Vinculado       */
		Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_NROVIC , "N" , 06 , 0 , 037 , 042})/* Numero do Ato Vinculado    */
		Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_EX_VIC  , "N" , 03 , 0 , 043 , 045})/* Nr. do EX do Ato Vinculado */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
	EndIf

	If !Empty(AllTrim(EIJ->EIJ_ASSVIB))

		aLoadTxt := {}
		nTamLin := 045
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"14"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro           */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                   */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao             */
		Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_ASSVIB , "N" , 01 , 0 , 021 , 021})/* Cod. do Assunto vinculado  */
		Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_ATOVIB , "C" , 05 , 0 , 022 , 026})/* Tipo do Ato Legal          */
		Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_ORGVIB , "C" , 06 , 0 , 027 , 032})/* Orgao emissor do Ato Legal */
		Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ANOVIB , "N" , 04 , 0 , 033 , 036})/* Ano do Ato Vinculado       */
		Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_NROVIB , "N" , 06 , 0 , 037 , 042})/* Numero do Ato Vinculado    */
		Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_EX_VIB , "N" , 03 , 0 , 043 , 045})/* Nr. do EX do Ato Vinculado */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
	EndIf

	If !Empty(AllTrim(EIJ->EIJ_ASSII))

		aLoadTxt := {}
		nTamLin := 045
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"14"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro           */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                   */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao             */
		Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_ASSII  , "N" , 01 , 0 , 021 , 021})/* Cod. do Assunto vinculado  */
		Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_ATO_II , "C" , 05 , 0 , 022 , 026})/* Tipo do Ato Legal          */
		Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_ORG_II , "C" , 06 , 0 , 027 , 032})/* Orgao emissor do Ato Legal */
		Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ANO_II , "N" , 04 , 0 , 033 , 036})/* Ano do Ato Vinculado       */
		Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_NRATII , "N" , 06 , 0 , 037 , 042})/* Numero do Ato Vinculado    */
		Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_EX_II  , "N" , 03 , 0 , 043 , 045})/* Nr. do EX do Ato Vinculado */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
	EndIf

	If !Empty(AllTrim(EIJ->EIJ_ASSIPI))

		aLoadTxt := {}
		nTamLin := 045
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"14"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro           */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                   */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao             */
		Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_ASSIPI , "N" , 01 , 0 , 021 , 021})/* Cod. do Assunto vinculado  */
		Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_ATOIPI , "C" , 05 , 0 , 022 , 026})/* Tipo do Ato Legal          */
		Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_ORGIPI , "C" , 06 , 0 , 027 , 032})/* Orgao emissor do Ato Legal */
		Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ANOIPI , "N" , 04 , 0 , 033 , 036})/* Ano do Ato Vinculado       */
		Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_NROIPI , "N" , 06 , 0 , 037 , 042})/* Numero do Ato Vinculado    */
		Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_EX_IPI , "N" , 03 , 0 , 043 , 045})/* Nr. do EX do Ato Vinculado */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
	EndIf

	If !Empty(AllTrim(EIJ->EIJ_ASSDUM))

		aLoadTxt := {}
		nTamLin := 045
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"14"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro           */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                   */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao             */
		Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_ASSDUM , "N" , 01 , 0 , 021 , 021})/* Cod. do Assunto vinculado  */
		Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_ATODUM , "C" , 05 , 0 , 022 , 026})/* Tipo do Ato Legal          */
		Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_ORGDUM , "C" , 06 , 0 , 027 , 032})/* Orgao emissor do Ato Legal */
		Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ANODUM , "N" , 04 , 0 , 033 , 036})/* Ano do Ato Vinculado       */
		Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_NRODUM , "N" , 06 , 0 , 037 , 042})/* Numero do Ato Vinculado    */
		Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_EX_NCM , "N" , 03 , 0 , 043 , 045})/* Nr. do EX do Ato Vinculado */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
	EndIf

    IF EIJ->EIJ_REGTRI # '6'
       aLoadTxt := {}
       /* Tipo de Registro "15" - Ocorrencias de Tributos */
       nTamLin := 180
                   // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
       Aadd(aLoadTxt,{ 01 ,"15"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
       Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
       Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
       Aadd(aLoadTxt,{ 04 ,1                , "N" , 04 , 0 , 021 , 024})// Cd. Adic. Usuario
       Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_TPAII   , "N" , 01 , 0 , 025 , 025})// Cd. Receita Imp.
       Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_BAS_II  , "N" , 15 , 2 , 026 , 040})// Vl. Base Cal. Adv.
       Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ALI_II  , "N" , 05 , 2 , 041 , 045})// Pc. Ali. Nor. Adv.
       Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_VL_II   , "N" , 15 , 2 , 046 , 060})// Vl. Cal. Ipt. Adv.
       Aadd(aLoadTxt,{ 09 ,""               , "C" , 15 , 0 , 061 , 075})// Nm. Un. Al. Es. IPT
       Aadd(aLoadTxt,{ 10 ,""               , "N" , 05 , 0 , 076 , 080})// Qt. Ml. Recepient
       Aadd(aLoadTxt,{ 11 ,0                , "N" , 09 , 0 , 081 , 089})// Qt. Me. Un. Al.Es.
       Aadd(aLoadTxt,{ 12 ,0                , "N" , 10 , 5 , 090 , 099})// Vl. Al. Es. IPT
       Aadd(aLoadTxt,{ 13 ,0                , "N" , 15 , 2 , 100 , 114})// Vl. Cal.IPT Esp.
       Aadd(aLoadTxt,{ 14 ,0                , "N" , 01 , 0 , 115 , 115})// Cd. Tip. Ben. IPI
       Aadd(aLoadTxt,{ 15 ,EIJ->EIJ_ALR_II  , "N" , 05 , 2 , 116 , 120})// Pc. Aliq. Reduz.
       Aadd(aLoadTxt,{ 16 ,EIJ->EIJ_PR_II   , "N" , 05 , 2 , 121 , 125})// Pc. Red. IPT Bli.
       Aadd(aLoadTxt,{ 17 ,EIJ->EIJ_ALA_II  , "N" , 05 , 2 , 126 , 130})// Pc. Al. Acor. Tar.
       Aadd(aLoadTxt,{ 18 ,EIJ->EIJ_VLR_II  , "N" , 15 , 2 , 131 , 145})// Vl. Cal. II Ac. Tf
       Aadd(aLoadTxt,{ 19 ,EIJ->EIJ_DEVII   , "N" , 15 , 2 , 146 , 160})// Vl. Impos. Devido
       nTotAdi += EIJ->EIJ_VLARII
       Aadd(aLoadTxt,{ 20 ,EIJ->EIJ_VLARII  , "N" , 15 , 2 , 161 , 175,"vlIi"})// Vl. IPT a Recolher
       Aadd(aLoadTxt,{ 21 ,/*aqui nil*/     , "N" , 01 , 0 , 176 , 176})// Cd. Tipo Direito
       Aadd(aLoadTxt,{ 22 ,0                , "N" , 02 , 0 , 177 , 178})// Nr. Not. Comp. Tip
       Aadd(aLoadTxt,{ 23 ,0                , "N" , 02 , 0 , 179 , 180})// Cod. Tipo Recipiente
       cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

       If !lXml
          FWrite(nHdl,cCpo,Len(cCpo))
       EndIf
    ENDIF

    IF EIJ->EIJ_REGTRI # '6'
       // Tipo de Registro "15" - Ocorrencias de Tributos */
       aLoadTxt := {}
	             // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
       Aadd(aLoadTxt,{ 01 ,"15"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
       Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
       Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
       Aadd(aLoadTxt,{ 04 ,2                , "N" , 04 , 0 , 021 , 024})// Cd. Adic. Usuario
       Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_TPAIPI  , "N" , 01 , 0 , 025 , 025})// Cd. Receita Imp.
       Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_BASIPI  , "N" , 15 , 2 , 026 , 040})// Vl. Base Cal. Adv.
       Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ALAIPI  , "N" , 05 , 2 , 041 , 045})// Pc. Ali. Nor. Adv.
       Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_VLAIPI  , "N" , 15 , 2 , 046 , 060})// Vl. Cal. Ipt. Adv.
       Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_UNUIPI  , "C" , 15 , 0 , 061 , 075})// Nm. Un. Al. Es. IPT
       Aadd(aLoadTxt,{ 10 ,EIJ->EIJ_QTRIPI  , "N" , 05 , 0 , 076 , 080})// Qt. Ml. Recepient
       Aadd(aLoadTxt,{ 11 ,EIJ->EIJ_QTUIPI  , "N" , 09 , 0 , 081 , 089})// Qt. Me. Un. Al.Es.
       Aadd(aLoadTxt,{ 12 ,EIJ->EIJ_ALUIPI  , "N" , 10 , 5 , 090 , 099})// Vl. Al. Es. IPT
       Aadd(aLoadTxt,{ 13 ,0                , "N" , 15 , 2 , 100 , 114})// Vl. Cal.IPT Esp.
       Aadd(aLoadTxt,{ 14 ,EIJ->EIJ_REGIPI  , "N" , 01 , 0 , 115 , 115})// Cd. Tip. Ben. IPI
       Aadd(aLoadTxt,{ 15 ,EIJ->EIJ_ALRIPI  , "N" , 05 , 2 , 116 , 120})// Pc. Aliq. Reduz.
       Aadd(aLoadTxt,{ 16 ,EIJ->EIJ_PRIPI   , "N" , 05 , 2 , 121 , 125})// Pc. Red. IPT Bli.
       Aadd(aLoadTxt,{ 17 ,0                , "N" , 05 , 2 , 126 , 130})// Pc. Al. Acor. Tar.
       Aadd(aLoadTxt,{ 18 ,0                , "N" , 15 , 2 , 131 , 145})// Vl. Cal. II Ac. Tf
       Aadd(aLoadTxt,{ 19 ,EIJ->EIJ_VLDIPI  , "N" , 15 , 2 , 146 , 160})// Vl. Impos. Devido
       nTotAdi += EIJ->EIJ_VLAIPI
       Aadd(aLoadTxt,{ 20 ,EIJ->EIJ_VLAIPI  , "N" , 15 , 2 , 161 , 175,"vlIpi"})// Vl. IPT a Recolher
       Aadd(aLoadTxt,{ 21 ,/*aqui nil*/     , "N" , 01 , 0 , 176 , 176})// Cd. Tipo Direito
       Aadd(aLoadTxt,{ 22 ,EIJ->EIJ_NCTIPI  , "N" , 02 , 0 , 177 , 178})// Nr. Not. Comp. Tip
       Aadd(aLoadTxt,{ 23 ,EIJ->EIJ_TPRECE  , "N" , 02 , 0 , 179 , 180})// Cod. Tipo Recipiente
       cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

       If !lXml
          FWrite(nHdl,cCpo,Len(cCpo))
       EndIf
    ENDIF

    IF EIJ->EIJ_REGTRI # '6' .AND. (!EMPTY(EIJ->EIJ_TPADUM) .OR. !EMPTY(EIJ->EIJ_ALADDU))
       aLoadTxt := {}
	// Tipo de Registro "15" - Ocorrencias de Tributos */
                   // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
       Aadd(aLoadTxt,{ 01 ,"15"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
	   Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
	   Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
       Aadd(aLoadTxt,{ 04 ,3                , "N" , 04 , 0 , 021 , 024})// Cd. Adic. Usuario
	   Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_TPADUM  , "N" , 01 , 0 , 025 , 025})// Cd. Receita Imp.
	   Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_BAD_AD  , "N" , 15 , 2 , 026 , 040})// Vl. Base Cal. Adv.
	   Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ALADDU  , "N" , 05 , 2 , 041 , 045})// Pc. Ali. Nor. Adv.
	   Aadd(aLoadTxt,{ 08 ,0                , "N" , 15 , 2 , 046 , 060})// Vl. Cal. Ipt. Adv.
	   Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_UNE_AD  , "C" , 15 , 0 , 061 , 075})// Nm. Un. Al. Es. IPT
	   Aadd(aLoadTxt,{ 10 ,0                , "N" , 05 , 0 , 076 , 080})// Qt. Ml. Recepient
	   Aadd(aLoadTxt,{ 11 ,EIJ->EIJ_BAE_AD  , "N" , 09 , 0 , 081 , 089})// Qt. Me. Un. Al.Es.
	   Aadd(aLoadTxt,{ 12 ,EIJ->EIJ_ALEADU  , "N" , 10 , 5 , 090 , 099})// Vl. Al. Es. IPT
	   Aadd(aLoadTxt,{ 13 ,0                , "N" , 15 , 2 , 100 , 114})// Vl. Cal.IPT Esp.
	   Aadd(aLoadTxt,{ 14 ,0                , "N" , 01 , 0 , 115 , 115})// Cd. Tip. Ben. IPI
	   Aadd(aLoadTxt,{ 15 ,0                , "N" , 05 , 2 , 116 , 120})// Pc. Aliq. Reduz.
	   Aadd(aLoadTxt,{ 16 ,0                , "N" , 05 , 2 , 121 , 125})// Pc. Red. IPT Bli.
	   Aadd(aLoadTxt,{ 17 ,0                , "N" , 05 , 2 , 126 , 130})// Pc. Al. Acor. Tar.
	   Aadd(aLoadTxt,{ 18 ,0                , "N" , 15 , 2 , 131 , 145})// Vl. Cal. II Ac. Tf
	   Aadd(aLoadTxt,{ 19 ,EIJ->EIJ_VLD_DU  , "N" , 15 , 2 , 146 , 160})// Vl. Impos. Devido
	   nTotAdi += EIJ->EIJ_VLR_DU
	   Aadd(aLoadTxt,{ 20 ,EIJ->EIJ_VLR_DU  , "N" , 15 , 2 , 161 , 175,"vlAntiDumping"})// Vl. IPT a Recolher
	   Aadd(aLoadTxt,{ 21 ,/*aqui nil*/     , "N" , 01 , 0 , 176 , 176})// Cd. Tipo Direito
	   Aadd(aLoadTxt,{ 22 ,0                , "N" , 02 , 0 , 177 , 178})// Nr. Not. Comp. Tip
	   Aadd(aLoadTxt,{ 23 ,0                , "N" , 02 , 0 , 179 , 180})// Cod. Tipo Recipiente
	   cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

	   If !lXml
	      FWrite(nHdl,cCpo,Len(cCpo))
       EndIf
     ENDIF

     IF lAUTPCDI
       // Tipo de Registro "15" - Ocorrencias de Tributos */

       //** AAF 11/09/2008 - Conforme Siscomex
       If Empty(EIJ->EIJ_PRB_PC) //Redução na Base de Calculo
          nBasePIS := EIJ->EIJ_BASPIS
       Else
          nBasePIS := EIJ->EIJ_BR_PIS //Base Reduzida
       EndIf
       //**

       // Bete - DI - Geração do registo de tributo ref. a PIS
       nVlAdVal := nVlEspec := 0
       IF EIJ->EIJ_TPAPIS = '1'
          nVlAdVal := nBasePIS * (EIJ->EIJ_ALAPIS/100)
       ELSE
          nVlEspec := EIJ->EIJ_QTUPIS * EIJ->EIJ_ALUPIS
       ENDIF
       aLoadTxt := {}
	             // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
       Aadd(aLoadTxt,{ 01 ,"15"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
       Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
       Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
       Aadd(aLoadTxt,{ 04 ,5                , "N" , 04 , 0 , 021 , 024})// Cd. Adic. Usuario
       Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_TPAPIS  , "N" , 01 , 0 , 025 , 025})// Cd. Receita Imp.
       Aadd(aLoadTxt,{ 06 ,nBasePIS         , "N" , 15 , 2 , 026 , 040})// Vl. Base Cal. Adv.
       Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ALAPIS  , "N" , 05 , 2 , 041 , 045})// Pc. Ali. Nor. Adv.
       Aadd(aLoadTxt,{ 08 ,nVlAdVal         , "N" , 15 , 2 , 046 , 060})// Vl. Cal. Ipt. Adv.
       Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_UNUPIS  , "C" , 15 , 0 , 061 , 075})// Nm. Un. Al. Es. IPT
       Aadd(aLoadTxt,{ 10 ,0                , "N" , 05 , 0 , 076 , 080})// Qt. Ml. Recepient
       Aadd(aLoadTxt,{ 11 ,EIJ->EIJ_QTUPIS  , "N" , 09 , 0 , 081 , 089})// Qt. Me. Un. Al.Es.
       Aadd(aLoadTxt,{ 12 ,EIJ->EIJ_ALUPIS  , "N" , 10 , 5 , 090 , 099})// Vl. Al. Es. IPT
       Aadd(aLoadTxt,{ 13 ,nVlEspec         , "N" , 15 , 2 , 100 , 114})// Vl. Cal.IPT Esp.
       Aadd(aLoadTxt,{ 14 ,0                , "N" , 01 , 0 , 115 , 115})// Cd. Tip. Ben. IPI
       Aadd(aLoadTxt,{ 15 ,EIJ->EIJ_REDPIS  , "N" , 05 , 2 , 116 , 120})// Pc. Aliq. Reduz.
       Aadd(aLoadTxt,{ 16 ,EIJ->EIJ_PRB_PC  , "N" , 05 , 2 , 121 , 125})// Pc. Red. IPT Bli.
       Aadd(aLoadTxt,{ 17 ,0                , "N" , 05 , 2 , 126 , 130})// Pc. Al. Acor. Tar.
       Aadd(aLoadTxt,{ 18 ,0                , "N" , 15 , 2 , 131 , 145})// Vl. Cal. II Ac. Tf
       Aadd(aLoadTxt,{ 19 ,EIJ->EIJ_VLDPIS  , "N" , 15 , 2 , 146 , 160})// Vl. Impos. Devido
       nTotAdi += EIJ->EIJ_VLRPIS
       Aadd(aLoadTxt,{ 20 ,EIJ->EIJ_VLRPIS  , "N" , 15 , 2 , 161 , 175,"vlPisCofins"})// Vl. IPT a Recolher
       Aadd(aLoadTxt,{ 21 ,/*aqui nil*/     , "N" , 01 , 0 , 176 , 176})// Cd. Tipo Direito
       Aadd(aLoadTxt,{ 22 ,0                , "N" , 02 , 0 , 177 , 178})// Nr. Not. Comp. Tip
       Aadd(aLoadTxt,{ 23 ,0                , "N" , 02 , 0 , 179 , 180})// Cod. Tipo Recipiente
       cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

       If !lXml
          FWrite(nHdl,cCpo,Len(cCpo))
       EndIf

       // Bete - DI - Geração do registo de tributo ref. a COFINS

       //** AAF 11/09/2008 - Conforme Siscomex
       If Empty(EIJ->EIJ_PRB_PC) //Redução na Base de Calculo
          nBaseCOF := EIJ->EIJ_BASCOF
       Else
          nBaseCOF := EIJ->EIJ_BR_COF //Base Reduzida
       EndIf
       //**

       nVlAdVal := nVlEspec := 0
       IF EIJ->EIJ_TPACOF = '1'
          nVlAdVal := nBaseCOF * (EIJ->EIJ_ALACOF/100)
       ELSE
          nVlEspec := EIJ->EIJ_QTUCOF * EIJ->EIJ_ALUCOF
       ENDIF
       aLoadTxt := {}
	             // Seq  Conteudo           Tipo Tam  Dec  Ini   Fim
       Aadd(aLoadTxt,{ 01 ,"15"             , "N" , 02 , 0 , 001 , 002})// Tipo de Registro
       Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})// Processo
       Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})// Nr. da Adiacao
       Aadd(aLoadTxt,{ 04 ,6                , "N" , 04 , 0 , 021 , 024})// Cd. Adic. Usuario
       Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_TPACOF  , "N" , 01 , 0 , 025 , 025})// Cd. Receita Imp.
       Aadd(aLoadTxt,{ 06 ,nBaseCOF         , "N" , 15 , 2 , 026 , 040})// Vl. Base Cal. Adv.
       Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_ALACOF  , "N" , 05 , 2 , 041 , 045})// Pc. Ali. Nor. Adv.
       Aadd(aLoadTxt,{ 08 ,nVlAdVal         , "N" , 15 , 2 , 046 , 060})// Vl. Cal. Ipt. Adv.
       Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_UNUCOF  , "C" , 15 , 0 , 061 , 075})// Nm. Un. Al. Es. IPT
       Aadd(aLoadTxt,{ 10 ,0                , "N" , 05 , 0 , 076 , 080})// Qt. Ml. Recepient
       Aadd(aLoadTxt,{ 11 ,EIJ->EIJ_QTUCOF  , "N" , 09 , 0 , 081 , 089})// Qt. Me. Un. Al.Es.
       Aadd(aLoadTxt,{ 12 ,EIJ->EIJ_ALUCOF  , "N" , 10 , 5 , 090 , 099})// Vl. Al. Es. IPT
       Aadd(aLoadTxt,{ 13 ,nVlEspec         , "N" , 15 , 2 , 100 , 114})// Vl. Cal.IPT Esp.
       Aadd(aLoadTxt,{ 14 ,0                , "N" , 01 , 0 , 115 , 115})// Cd. Tip. Ben. IPI
       Aadd(aLoadTxt,{ 15 ,EIJ->EIJ_REDCOF  , "N" , 05 , 2 , 116 , 120})// Pc. Aliq. Reduz.
       Aadd(aLoadTxt,{ 16 ,EIJ->EIJ_PRB_PC  , "N" , 05 , 2 , 121 , 125})// Pc. Red. IPT Bli.
       Aadd(aLoadTxt,{ 17 ,0                , "N" , 05 , 2 , 126 , 130})// Pc. Al. Acor. Tar.
       Aadd(aLoadTxt,{ 18 ,0                , "N" , 15 , 2 , 131 , 145})// Vl. Cal. II Ac. Tf
       Aadd(aLoadTxt,{ 19 ,EIJ->EIJ_VLDCOF  , "N" , 15 , 2 , 146 , 160})// Vl. Impos. Devido
       nTotAdi += EIJ->EIJ_VLRCOF
       Aadd(aLoadTxt,{ 20 ,EIJ->EIJ_VLRCOF  , "N" , 15 , 2 , 161 , 175,"vlPisCofins"})// Vl. IPT a Recolher
       Aadd(aLoadTxt,{ 21 ,/*aqui nil*/     , "N" , 01 , 0 , 176 , 176})// Cd. Tipo Direito
       Aadd(aLoadTxt,{ 22 ,0                , "N" , 02 , 0 , 177 , 178})// Nr. Not. Comp. Tip
       Aadd(aLoadTxt,{ 23 ,0                , "N" , 02 , 0 , 179 , 180})// Cod. Tipo Recipiente
       cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aAdicoes)

       If !lXml
          FWrite(nHdl,cCpo,Len(cCpo))
       EndIf
    ENDIF

    aOrdSW9 := SaveOrd({"SW9"})                      	//NCF - 23/03/2012
     DO While !SW8->(Eof()) .And.;
			 SW8->W8_FILIAL == cFilSW8	.And.;
 			 SW8->W8_HAWB   == EIJ->EIJ_HAWB .And.;
 			 SW8->W8_ADICAO == EIJ->EIJ_ADICAO

        SB1->(dbSeek(cFilSB1+SW8->W8_COD_I))
        aItens := {}
        SW9->(DbSetOrder(1))                                                               	//NCF - 23/03/2012 - Posicionar Capa da Invoice para verificação de despesas
        SW9->( DbSeek( xFilial("SW9")+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+EIJ->EIJ_HAWB ) )

        aLoadTxt := {}
        /* Tipo de Registro "16" - Ocorrencias de detalhamento da mercadoria. */
        nTamLin := 87

        cUMde:=BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN,SW8->W8_CC+SW8->W8_SI_NUM, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))

        /*
        IF SA5->(DBSEEK(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN)) .AND. ;
           !EMPTY(SA5->A5_UNID)
           cUMde:=SA5->A5_UNID
        ELSEIF SB1->(DBSEEK(cFilSB1+SW8->W8_COD_I))
           cUMde:=SB1->B1_UM
        ENDIF
        */
        SAH->(DBSEEK(cFilSAH+cUMde))

        IF ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim
            SW2->(DBSEEK(xFILIAL("SW2")+SW8->W8_PO_NUM))
            nQtdMerc := SW8->W8_QTDE * SB1->B1_QTMIDIA
            nVLMCV:=DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc) + SW8->W8_FRETEIN) /nQtdMerc,7)
        ELSE
             nQtdMerc := SW8->W8_QTDE
             nVLMCV := DI500RetVal("ITEM_INV", "TAB", .T.)  // EOB - 14/07/08 - chamada da função DI500RetVal
             nVLMCV := DI500Trans(nVLMCV/nQtdMerc,7)
        ENDIF
		             /* Seq  Conteudo         Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"16"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro                    */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                            */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao                      */
		Aadd(aLoadTxt,{ 04 ,nQtdMerc        , "N" , 14 , 5 , 021 , 034,"qtdItem"})/* Qtd. Merc. na Unid. Comercializada  */
		Aadd(aLoadTxt,{ 05 ,LEFT(SAH->AH_DESCPO,20) , "C" , 20 , 0 , 035 , 054})/* Nome Unid Med Comercializada        */
		Aadd(aLoadTxt,{ 06 ,nVLMCV                  , "N" , 20 , 7 , 055 , 074,"vlUnitario"})/* Vlr. Unit na Cond. Venda(VUCV)      */

	   	//NCF - 23/03/2012 -(VULE)Enviado o valor zerado conforme observado na estrutura gerada pelo SISCOMEX
		Aadd(aLoadTxt,{ 07 ,0/*DI500Trans(SW8->W8_VLMLE/nQtdMerc)*/, "N" , 13 , 2 , 075 , 087})/* Vlr. Unit no local Embarque(VULE)   */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aItens)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
	    EndIf

		/* Tipo de Registro "19" - Ocorrencias de texto de detalhamento da mercadoria */
        mMemo    := ' '
        IF !EMPTY(SW8->W8_DESC_DI)
           mMemo := MSMM(SW8->W8_DESC_DI,nTamDesc)
        ENDIF
        IF EMPTY(mMemo)
           mMemo := MSMM(SB1->B1_DESC_GI,nTamIMemo)
        ENDIF
        IF EasyGParam("MV_PN_DI",,.F.)
           mMemo+= " - " + ALLTRIM(TRANS(SW8->W8_COD_I,cPictItem))
           If SW3->(FieldPos("W3_PART_N")) # 0   //ASK 05/10/2007
              SW3->(DbSetOrder(8))
              SW3->(DbSeek(xFilial("SW3") + SW8->W8_PO_NUM + SW8->W8_POSICAO))
              If !Empty(SW3->W3_PART_N)
                 mMemo+= " - " + SW3->W3_PART_N
              Else
                 IF EICSFabFor(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "FORLOJ"))
                    mMemo+= " - "+ ALLTRIM(SA5->A5_CODPRF)
                 ENDIF
              EndIf
           Else
              IF EICSFabFor(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "FORLOJ"))
                 mMemo+= " - "+ ALLTRIM(SA5->A5_CODPRF)
              ENDIF
           EndIf
        ENDIF
		mMemo    := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
                IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"WHILESW8_TIPO_19"),)

		Totlin   := MlCount(mMemo,nTamDesc)
		For i:=1 To Totlin

			aLoadTxt := {}
			nTamLin := nTamDesc+20
			             /* Seq  Conteudo                     Tipo Tam  Dec  Ini   Fim */
			Aadd(aLoadTxt,{ 01 ,"19"                       , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro      */
			Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB               , "C" , 15 , 0 , 003 , 017})/* Processo              */
			Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO            , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao        */
			Aadd(aLoadTxt,{ 04 ,MemoLine(mMemo,nTamDesc,i) , "C" , nTamDesc, 0 , 021 , nTamLin,"txDescricaoDestalhada"})/* Especif. Merc.  */
			cCpo := DI500GrvTxt(aLoadTxt,nTamLin,@aItens)

			If !lXml
			   FWrite(nHdl,cCpo,Len(cCpo))
			EndIf
		Next i

        //nTotAdi+=SW8->W8_BASEICM

    	aAdd(aItens,{"",0,"adicao"            ,EIJ->EIJ_ADICAO})
    	aAdd(aItens,{"",0,"cdNcmItem"         ,EIJ->EIJ_TEC})
    	aAdd(aItens,{"",0,"cdDestaqueItem"    ,SW8->W8_COD_I})
    	aAdd(aItens,{"",0,"txDescricaoSuframa",SB1->B1_MAT_PRI})
    	aAdd(aItens,{"",0,"unidadeMedida"     ,cUMde})
    	aAdd(aItens,{"",0,"vlTotal"           ,Round(nQtdMerc*nVLMCV,2)})
		aAdd(aItensAdDAI,aItens)
		SW8->(dbSkip())

	EndDo
    RestOrd(aOrdSW9,.T.)                               //NCF - 23/03/2012

	EIN->(dbSeek( cFilEIN + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
	/* Tipo de Registro "17" - Ocorrencias de deducao de valor aduaneiro */
	DO While !EIN->(Eof()) .And.;
			 EIN->EIN_FILIAL == cFilEIN	.And.;
 			 EIN->EIN_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIN->EIN_ADICAO == EIJ->EIJ_ADICAO

//     IF EIN->EIN_ADICAO == "MOD"
//        EIN->(DBSKIP())
//        LOOP
//     ENDIF

		If EIN->EIN_TIPO = "2"
		    //SVG - 10/02/2009
			cCodEIN := EIN->EIN_CODIGO
			IF cCodEIN == "01"
			   cCodEIN := "1 "
			ENDIF
			aLoadTxt := {}
			nTamLin := 55
			             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
			Aadd(aLoadTxt,{ 01 ,"17"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro               */
			Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                       */
			Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao                 */
			Aadd(aLoadTxt,{ 04 ,cCodEIN         , "C" , 02 , 0 , 021 , 022})/* Codigo da Deducao              */
			Aadd(aLoadTxt,{ 05 ,EIN->EIN_VLMLE  , "N" , 15 , 2 , 023 , 037})/* Vlr da deducao na moeda negoc. */
			cMoeda := ""
			If !Empty(EIN->EIN_FOBMOE)
			   SYF->(DBSEEK(cFilSYF+EIN->EIN_FOBMOE))
               cMoeda := SYF->YF_COD_GI
			EndIf
			Aadd(aLoadTxt,{ 06 ,cMoeda          , "N" , 03 , 0 , 038 , 040})/* Codigo da moeda negociada      */
			Aadd(aLoadTxt,{ 07 ,EIN->EIN_VLMMN  , "N" , 15 , 2 , 041 , 055})/* Valor da deducao em Real       */
			cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

			If !lXml
			   FWrite(nHdl,cCpo,Len(cCpo))
			EndIf
		EndIf

		EIN->(dbSkip())

	EndDo

	EIN->(dbSeek( cFilEIN + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
	/* Tipo de Registro "18" - Ocorrencias de acrescimo de valor aduaneiro */
	DO While !EIN->(Eof()) .And.;
			 EIN->EIN_FILIAL == cFilEIN	.And.;
 			 EIN->EIN_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIN->EIN_ADICAO == EIJ->EIJ_ADICAO

//     IF EIN->EIN_ADICAO == "MOD"
//        EIN->(DBSKIP())
//        LOOP
//     ENDIF

		If EIN->EIN_TIPO = "1"

			aLoadTxt := {}
			nTamLin := 55
			             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
			Aadd(aLoadTxt,{ 01 ,"18"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro               */
			Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                       */
			Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao                 */
			// EOB - 02/07/08 - Chamado 704290 - Na tabela de acrescimos vinda do Siscomex, o código de acrescimo vem como "09", porém,
			// por um erro da SERPRO, na retificação da DI o Siscomex não aceita o código "09" e sim "9 ". Conforme testes realizados pelo
			// Rogerio B., se enviarmos a DI com o código "9 ", o siscomex aceita tanto no envio quanto na retificação
			// Realizei um teste no Siscomex, enviando uma DI via estrutura própria para análise, inserindo os códigos de acréscimos e deduções
			// menores que "10". Alterei o TXT retirando o zero, trazendo o número para a esquerda e deixando um espaço em branco a direita e passou
			// pela análise. Como não conseguimos fazer a retificação de uma DI, pois não podemos registrar, foi alterado somente o código "09"
			// dos acréscimos, conforme problema apontado pela Comexport e Deicmar.
			cCodEIN := EIN->EIN_CODIGO
			IF cCodEIN == "09"
			   cCodEIN := "9 "
			ENDIF
   			Aadd(aLoadTxt,{ 04 ,cCodEIN , "C" , 02 , 0 , 021 , 022})/* Codigo da Acrescimo            */
			Aadd(aLoadTxt,{ 05 ,EIN->EIN_VLMLE  , "N" , 15 , 2 , 023 , 037})/* Vlr da deducao na moeda negoc. */
			cMoeda := ""
			If !Empty(EIN->EIN_FOBMOE)
			   SYF->(DBSEEK(cFilSYF+EIN->EIN_FOBMOE))
               cMoeda := SYF->YF_COD_GI
			EndIf
			Aadd(aLoadTxt,{ 06 ,cMoeda          , "N" , 03 , 0 , 038 , 040})/* Codigo da moeda negociada      */
			Aadd(aLoadTxt,{ 07 ,EIN->EIN_VLMMN  , "N" , 15 , 2 , 041 , 055})/* Valor da Acrescimo em Real       */

			cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

			If !lXml
			   FWrite(nHdl,cCpo,Len(cCpo))
			EndIf
		EndIf

		EIN->(dbSkip())

	EndDo

	EIL->(dbSeek( cFilEIL + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
	/* Tipo de Registro "20" - Ocorrencias do destaque de NCM */
	DO While !EIL->(Eof()) .And.;
			 EIL->EIL_FILIAL == cFilEIL	.And.;
 			 EIL->EIL_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIL->EIL_ADICAO == EIJ->EIJ_ADICAO

//     IF EIL->EIL_ADICAO == "MOD"
//        EIL->(DBSKIP())
//        LOOP
//     ENDIF

		aLoadTxt := {}
		nTamLin := 23
		             /* Seq  Conteudo           Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"20"             , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB     , "C" , 15 , 0 , 003 , 017})/* Processo         */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO  , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao   */
		Aadd(aLoadTxt,{ 04 ,EIL->EIL_DESTAQ  , "C" , 03 , 0 , 021 , 023})/* Nr. do Destaque  */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        Endif
		EIL->(dbSkip())

	EndDo

	EIK->(dbSeek( cFilEIK + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
	/* Tipo de Registro "21" - Ocorrencias do documento vinculado */
	DO While !EIK->(Eof()) .And.;
			 EIK->EIK_FILIAL == cFilEIK	.And.;
 			 EIK->EIK_HAWB   == EIJ->EIJ_HAWB .And.;
 			 EIK->EIK_ADICAO == EIJ->EIJ_ADICAO

//     IF EIK->EIK_ADICAO == "MOD"
//        EIK->(DBSKIP())
//        LOOP
//     ENDIF

		aLoadTxt := {}
		nTamLin := 36
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"21"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro         */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                 */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao           */
		Aadd(aLoadTxt,{ 04 ,EIK->EIK_TIPVIN , "N" , 01 , 0 , 021 , 021})/* Tipo do docto. Vinculado */
		Aadd(aLoadTxt,{ 05 ,EIK->EIK_DOCVIN , "C" , 15 , 0 , 022 , 036})/* Nr. do docto. Vinculado  */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
        EndIf
		EIK->(dbSkip())

	EndDo
    EIM->(dbSetOrder(1)) // EIM_FILIAL+EIM_HAWB+EIM_ADICAO
    lAchou:=EIM->(dbSeek( cFilEIM + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
    bWhile:={|| EIM->EIM_ADICAO == EIJ->EIJ_ADICAO }
	IF lTemNVE	.AND. !lAchou
       EIM->(dbSetOrder(2)) // EIM_FILIAL+EIM_HAWB+EIM_CODIGO
       EIM->(dbSeek( cFilEIM + EIJ->EIJ_HAWB + EIJ->EIJ_NVE ))
       bWhile:={|| EIM->EIM_CODIGO == EIJ->EIJ_NVE }
    ENDIF
	/* Tipo de Registro "22" - Ocorrencias de especific. da merc. p/ fins de valoracao aduaneira */
	DO While !EIM->(Eof()) .And.;
			 EIM->EIM_FILIAL == cFilEIM	.And.;
 			 EIM->EIM_HAWB   == EIJ->EIJ_HAWB .And. EVAL(bWhile)

		aLoadTxt := {}
		nTamLin := 27
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		Aadd(aLoadTxt,{ 01 ,"22"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro          */
		Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                  */
		Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adiacao            */
		Aadd(aLoadTxt,{ 04 ,EIM->EIM_NIVEL  , "N" , 01 , 0 , 021 , 021})/* Cod. Abrangencia da NCM   */
		Aadd(aLoadTxt,{ 05 ,EIM->EIM_ATRIB  , "C" , 02 , 0 , 022 , 023})/* Cod. do atributo da NCM   */
		Aadd(aLoadTxt,{ 06 ,EIM->EIM_ESPECI , "N" , 04 , 0 , 024 , 027})/* Cod. da especific. da NCM */

		cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		If !lXml
		   FWrite(nHdl,cCpo,Len(cCpo))
	    EndIf
		EIM->(dbSkip())

	EndDo

	// TDF - 29/07/11
	/* Tipo de Registro "23" - Ocorrencias de documento Mercosul - Novo tratamento de DE Mercosul */
    IF lEJ9
	   EJ9->(DBSETORDER(1))
	   EJ9->(DBSEEK(cFilEJ9+AVKEY(EIJ->EIJ_HAWB,"EJ9_HAWB")+AVKEY(EIJ->EIJ_ADICAO,"EJ9_ADICAO")))
	   DO WHILE !EJ9->(Eof()) .And.;
			 EJ9->EJ9_FILIAL == cFilEJ9	.And.;
 			 ALLTRIM(EJ9->EJ9_HAWB)    == ALLTRIM(EIJ->EIJ_HAWB) .And.;
 			 ALLTRIM(EJ9->EJ9_ADICAO)  == ALLTRIM(EIJ->EIJ_ADICAO)
	   IF lMERCODI .AND. !EMPTY(EJ9->EJ9_DEMERC)
	      aLoadTxt := {}
		  nTamLin := 75

		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		  Aadd(aLoadTxt,{ 01 ,"23"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro              */
		  Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                      */
		  Aadd(aLoadTxt,{ 03 ,EJ9->EJ9_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adicao                 */
		  Aadd(aLoadTxt,{ 04 ,EJ9->EJ9_DEMERC , "C" , 16 , 0 , 021 , 036})/* DE - Mercosul                 */
		  Aadd(aLoadTxt,{ 05 ,EJ9->EJ9_REINIC , "C" , 04 , 0 , 037 , 040})/* Faixa inicial dos itens da RE */
		  Aadd(aLoadTxt,{ 06 ,EJ9->EJ9_REFINA , "C" , 04 , 0 , 041 , 044})/* Faixa final dos itens da RE   */
		  Aadd(aLoadTxt,{ 07 ,EJ9->EJ9_PAISEM , "C" , 03 , 0 , 045 , 046})/* Pais emissor do certificado   */
		  Aadd(aLoadTxt,{ 08 ,EJ9->EJ9_DICERT , "C" , 16 , 0 , 047 , 062})/* DI originária do certificado  */
		  Aadd(aLoadTxt,{ 09 ,EJ9->EJ9_ITDICE , "C" , 04 , 0 , 063 , 066})/* Item da DI do certificado     */
		  Aadd(aLoadTxt,{ 10 ,EJ9->EJ9_QTDCER , "N" , 14 , 5 , 067 , 075})/* DI originária do certificado  */

		  cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		  If !lXml
		     FWrite(nHdl,cCpo,Len(cCpo))
		  EndIf
	   ENDIF
	      EJ9->(DBSKIP())
       ENDDO
    ELSE
	/* Tipo de Registro "23" - Ocorrencias de documento Mercosul */
	   IF lMERCODI .AND. !EMPTY(EIJ->EIJ_DEMERC)
	      aLoadTxt := {}
	      nTamLin := 75
		             /* Seq  Conteudo          Tipo Tam  Dec  Ini   Fim */
		  Aadd(aLoadTxt,{ 01 ,"23"            , "N" , 02 , 0 , 001 , 002})/* Tipo de Registro              */
		  Aadd(aLoadTxt,{ 02 ,SW6->W6_HAWB    , "C" , 15 , 0 , 003 , 017})/* Processo                      */
		  Aadd(aLoadTxt,{ 03 ,EIJ->EIJ_ADICAO , "N" , 03 , 0 , 018 , 020})/* Nr. da Adicao                 */
		  Aadd(aLoadTxt,{ 04 ,EIJ->EIJ_DEMERC , "C" , 16 , 0 , 021 , 036})/* DE - Mercosul                 */
		  Aadd(aLoadTxt,{ 05 ,EIJ->EIJ_REINIC , "C" , 04 , 0 , 037 , 040})/* Faixa inicial dos itens da RE */
		  Aadd(aLoadTxt,{ 06 ,EIJ->EIJ_REFINA , "C" , 04 , 0 , 041 , 044})/* Faixa final dos itens da RE   */
		  Aadd(aLoadTxt,{ 07 ,EIJ->EIJ_PAISEM , "C" , 03 , 0 , 045 , 046})/* Pais emissor do certificado   */
		  Aadd(aLoadTxt,{ 08 ,EIJ->EIJ_DICERT , "C" , 16 , 0 , 047 , 062})/* DI originária do certificado  */
		  Aadd(aLoadTxt,{ 09 ,EIJ->EIJ_ITDICE , "C" , 04 , 0 , 063 , 066})/* Item da DI do certificado     */
		  Aadd(aLoadTxt,{ 10 ,EIJ->EIJ_QTDCER , "N" , 14 , 5 , 067 , 075})/* DI originária do certificado  */

		  cCpo := DI500GrvTxt(aLoadTxt,nTamLin)

		  If !lXml
		     FWrite(nHdl,cCpo,Len(cCpo))
		  EndIf
   	   ENDIF
    ENDIF

    aAdd(aAdicoes,{"",0,"vlCide"          ,0})
    aAdd(aAdicoes,{"",0,"vlMultaseJuros"  ,0})
    aAdd(aAdicoes,{"",0,"vlTaxasDiversas" ,0})
    nVlTotCap += nValorCapatazia
    aAdd(aAdicoes,{"",0,"vlTaxasCapatazia",nValorCapatazia})
    aAdd(aAdicoes,{"",0,"tipoImportador"  ,"1" /*SYT->YT_TIPO*/})
    aAdd(aAdicoes,{"",0,"cdImportador"    ,SYT->YT_INSCR_E})
    aAdd(aAdicoes,{"",0,"nomeImportador"  ,SYT->YT_NOME})
    aAdd(aAdicoes,{"",0,"nomeFornecedor"  ,E_Field("EIJ_FORN","A2_NOME",,,1)})

    If EIJ->(FieldPos("EIJ_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI",.F.)
       nOrdEJB := EJB->(IndexOrd())
       nRecEJB := EJB->(Recno())
       nOrdEJC := EJC->(IndexOrd())
       nRecEJC := EJC->(Recno())

       EJB->(DbSetOrder(1))
       If EJB->(DbSeek(xFilial("EJB") + AvKey(SW6->W6_IMPORT,"EJB_IMPORT") + AvKey(EIJ->EIJ_CODMAT,"EJB_CODMAT")))
          aAdd(aAdicoes,{"",0,"cdSuframa"     ,EJB->EJB_PRDSUF})
          aAdd(aAdicoes,{"",0,"cdNcmProdFinal",EJB->EJB_NCM   })
          aAdd(aAdicoes,{"",0,"cdDestinacao"  ,EJB->EJB_DESTIN})
          aAdd(aAdicoes,{"",0,"cdUtilizacao"  ,EJB->EJB_UTILIZ})
          aAdd(aAdicoes,{"",0,"cdTributacao"  ,EJB->EJB_CODTRI})
          EJC->(DbSetOrder(1))
          If EJC->(DbSeek(xFilial("EJC")+AvKey(EJB->EJB_CODTRI,"EJC_CODTRI")))
             aAdd(aAdicoes,{"",0,"vlBcIcms",nTotAdi})

             If EJB->EJB_COEFIC == "1" .And. EJC->EJC_COFNOR > 0 // 1 = Coefeciente Normal ; 2 = Optante - Lei 2.826
                nVlCM := EJC->EJC_COFNOR // Normal
             ElseIf EJB->EJB_COEFIC == "2" .And. EJC->EJC_COFLEI > 0
                nVlCM := EJC->EJC_COFLEI // Optante pela Lei 2.826
             EndIf

             aAdd(aAdicoes,{"",0,"vlCm",nVlCM})
             aAdd(aAdicoes,{"",0,"vlIcms",Round(nTotAdi * nVlCM,2)})
          EndIf
       EndIf

       EJB->(DbSetOrder(nOrdEJB))
       EJB->(DbGoTo(nRecEJB))
       EJC->(DbSetOrder(nOrdEJC))
       EJC->(DbGoTo(nRecEJC))
    EndIf

    aAdd(aAdicoes,{"",0,"numDiAdmissaoTemp",0})
    aAdd(aAdicoes,{"",0,"numDiEizof",0})

    aAdd(aAdicaoDAI,{aAdicoes,aItensAdDAI})
    EIJ->(dbSkip())
EndDo
aAdd(aLoadXML,aAdicaoDAI)
// Final da Insercao das Adicoes

SJD->(DbSetOrder(1))
If SJD->(DbSeek(xFilial()+SW6->W6_HAWB))
   While SJD->(!Eof()) .And. SW6->W6_HAWB == SJD->JD_HAWB
      aLacres := {}
      aAdd(aLacres,{"",0,"tpVeiculo","2"})
      aAdd(aLacres,{"",0,"idVeiculo",AllTrim(SJD->JD_CONTAIN)})
      aAdd(aLacres,{"",0,"nrLacre",SJD->JD_LACRE})
      SJD->(DbSkip())
      aAdd(aLacreDAI,aLacres)
   End Do
EndIf
aAdd(aLoadXML,aLacreDAI)

If (nPos := aScan(aLoadXML[1],{ |X| X[3] == "vlTaxasCapatazia"} )) > 0 .And. nVlTotCap > 0
   aLoadXML[1][nPos][2] := nVlTotCap
EndIf

oXml := DI500GrvXML(@aLoadXML,cVersao,cId)

If !lXml
   FClose(nHdl)
EndIf

//** PLB 08/05/07 - Copia arquivo para o Diretório local estabelecido pelo usuário
If !lXml
   If lLocal
      If !CpyS2T(".\"+cPathDest+cArqTxt,cPathLocal, .F. )
         MsgStop(STR0260+cPathLocal+cArqTxt,STR0215)  // STR0260 "Erro na criação do arquivo: " //STR0215	"Atenção"
         If File(cPathDest+cArqTxt)
            FErase(cPathDest+cArqTxt)
         EndIf
         Return Nil
      EndIf
   EndIf

   // **
   IncProc(STR0349) //STR0349"Gravando Histórico"

   /*************************************/
   /* Gravacao do Historico do processo */
   /*************************************/
   EIR->(RecLock("EIR",.T.))
   EIR->EIR_FILIAL := xFilial("EIR")
   EIR->EIR_HAWB   := SW6->W6_HAWB
   EIR->EIR_DATA   := dDataBase
   EIR->EIR_HORA   := Time()
   EIR->EIR_USUARI := cUserName
   EIR->EIR_ARQUIV := cArqtxt
   EIR->(MsUnlock())

   IF lEMail
      SX5->(DBSEEK(xFilial("SX5")+"CE"+cMaquina))
                //cArquivo,cTitulo,cSubject,cBody,lShedule,cTo
      ENVIA_EMAIL(cPathDest+cArqTxt,STR0167 + cPathDest+cArqTxt+" )",; //STR0167 "Arquivo TXT do SISCOMEX ( "
                                 STR0168+If(cTipoEnv=="1",STR0169,STR0170)+STR0171+SW6->W6_HAWB,,,SX5->X5_DESCRI)//AVGERAL.PRW //STR0168 "Arquivo TXT do SISCOMEX para " //STR0169 "Analise" //STR0170 "Registro" //STR0171 " do Processo: "
      If File(cPathDest+cArqTxt)
         FErase(cPathDest+cArqTxt)
      EndIf
   ELSE
      //** PLB 08/05/07 - Caso seja gravacao local apaga arquivo do Servidor
      If lLocal
         If File(cPathDest+cArqTxt)
            FErase(cPathDest+cArqTxt)
         EndIf
         MsgInfo(STR0350+cPathLocal+cArqTxt,STR0185)  // STR0350 "Arquivo criado em: " //STR0185	"Informação"
      Else
         MsgInfo(STR0350+cPathDest+cArqTxt,STR0185)  //STR0350 "Arquivo criado em: "  //STR0185	"Informação"
      EndIf
      //**
   ENDIF
   EIM->(dbSetOrder(1)) /* EIM_FILIAL+EIM_HAWB+EIM_ADICAO */
EndIf

RestOrd(aOrd)
dbSelectArea(nOldArea)

Return Nil
*--------------------------------*
Function DI500GrvTxt(aLoadTxt,nTamLin,aXML)
*--------------------------------*
Local cLin := "", nInd
Local cTipo,cConteudo,nConteudo,nTamanho,;
		nDecimal,nPosIni,nPosFim
Local aRetXML := {}
Local nPos := 0
Local cTpReg := ""

Begin Sequence

	nLen := Len(aLoadTxt)

	If nLen = 0
		Break
	EndIf

	cLin := Space(nTamLin)

    cTpReg := aLoadTxt[1][2] // Tipo de Registro
	For nInd := 1 To nLen
        cTipo    := aLoadTxt[nInd][3]
        nTamanho := aLoadTxt[nInd][4]
        nDecimal := aLoadTxt[nInd][5]
        nPosIni  := aLoadTxt[nInd][6]
        nPosFim  := aLoadTxt[nInd][7]
        If cTipo = "C"
           cConteudo := If(aLoadTxt[nInd][2]=Nil,"",AllTrim(aLoadTxt[nInd][2]))
	       If Len(cConteudo) = nTamanho
	          cCpo := cConteudo
     	   Elseif Len(cConteudo) < nTamanho
	          cCpo := Padr(cConteudo,nTamanho)
           Else
     		  cCpo := Left(cConteudo,nTamanho)
           Endif
        ElseIf cTipo = "N"
     	   nConteudo := If(aLoadTxt[nInd][2]=Nil,0,aLoadTxt[nInd][2])
           Do Case
              Case ValType(nConteudo) = "N"
		           cConteudo := Str(nConteudo,nTamanho+1,nDecimal)  //AWR Somei +1 porque eu tiro o ponto entao ganho um inteiro
		           cConteudo := StrTran(AllTrim(cConteudo),".","")
         	  Case ValType(nConteudo) = "D"
		           cConteudo := ALLTRIM(SubStr(DtoS(nConteudo),1,nTamanho))//'ALLTRIM()' Porque quando a data eh em branco deve mandar tudo com zero
         	  Case ValType(nConteudo) = "C"
		           cConteudo := STRZERO(Val(nConteudo),nTamanho,nDecimal)
           EndCase
           cCpo := Padl(cConteudo,nTamanho,"0")
        Endif
        cLin    := Stuff(cLin,nPosIni,nPosFim,cCpo)

        // Tratamento para adicionar na primeira posicao somente o conteudo, e as demais que possuírem a oitava posicao, ou seja, a tag.
        If Valtype(aXML) == "A"
           If Len(aLoadTxt[nInd]) >= 8 .And. !Empty(aLoadTxt[nInd][8])
              If (nPos := aScan(aXML,{|X| AllTrim(Upper(aLoadTxt[nInd][8])) == AllTrim(Upper(X[3])) })) == 0
                         // Tipo de Registro, Ordem           ,Tag              ,Informacao
                 aAdd(aXML,{cTpReg          ,aLoadTxt[nInd][1],aLoadTxt[nInd][8],aLoadTxt[nInd][2]} )
              Else
                 aXML[nPos][4] += aLoadTxt[nInd][2]
              EndIf
           EndIf
        EndIf

	Next nInd
	cLin += Chr(13)+Chr(10)
End Sequence

Return cLin
*--------------------------------*
Function DI500HistDI(cHawb)
*--------------------------------*
Local nOldArea := Select()
Local oDlgHist,cNomArq,TB_Campos:={},oPanelHist
Local cFilEIR := xFilial("EIR")
Local aRCampos:={},aButtons
// BAK - Tratamento para EnchoiceBar - 18/08/2011
//Local aOk     := {{|| oDlgHist:End()},STR0421} //"Sair"
Local bOk     := {|| oDlgHist:End()}
Local bCancel := {|| oDlgHist:End()}
Local aDados  :={"WorkHist",;
                STR0173,;  // STR0173 "Este relatorio emite o controle de arquivos enviados ao SISCOMEX"
                "",;
                "",;
                "M",;
                132,;
                "",;
                "",;
                STR0174,;  // STR0174 "Controle de Arquivos Enviados ao SISCOMEX"
                { STR0175, 1, STR0176, 1, 2, 1, "", 1},;   //STR0175 "Zebrado" //STR0176	 "Importação"
                "EICDI500",;
                { {|| .T. } , {|| .T. }  }  }

Private aHeader[0]

IF SELECT("Work_Capa") # 0
   aButtons:={}
   Aadd(aButtons,{"NOTE",{|| DI500Analise() },STR0177,STR0178})  //STR0177 "Analisar dados enviados" // STR0178 "Analisar"
ENDIF

aCampos:=ARRAY(EIR->(FCOUNT()))
cNomArq:=E_CriaTrab("EIR",,"WorkHist")
IndRegua("WorkHist",cNomArq+TEOrdBagExt(),"EIR_HAWB+DTOS(EIR_DATA)+EIR_HORA")
Set Index To (cNomArq+TEOrdBagExt())

cHawb := If(cHawb=Nil,"",cHawb)

EIR->(dbSetOrder(1))
EIR->(dbSeek(cFilEIR+cHawb))

cWhile := "!EIR->(EOF()) .And. EIR->EIR_FILIAL==cFilEIR"
cWhile += If(!Empty(cHawb)," .And. EIR->EIR_HAWB=cHawb","")
cWhile := "{||"+cWhile+"}"
bWhile := &cWhile

EIR->(dbEval({|| WorkHist->(dbAppend()),;
                 AvReplace("EIR","WorkHist")},,bWhile,,,.T.))

If WorkHist->(EasyRecCount("WorkHist")) > 0

	Aadd(TB_Campos,{ "EIR_HAWB"                    ,"",AvSx3("EIR_HAWB",5)   })
	Aadd(TB_Campos,{ {||DtoC(WorkHist->EIR_DATA) } ,"",AvSx3("EIR_DATA",5)   })
	Aadd(TB_Campos,{ "EIR_HORA"                    ,"",AvSx3("EIR_HORA",5)   })
	Aadd(TB_Campos,{ "EIR_USUARI"                  ,"",AvSx3("EIR_USUARI",5) })
	Aadd(TB_Campos,{ "EIR_ARQUIV"                  ,"",AvSx3("EIR_ARQUIV",5) })

	aRCampos:=E_CriaRCampos(TB_Campos)

	Do While .T.

      oMainWnd:ReadClientCoors()
      Define MsDialog oDlgHist Title STR0179 ; //STR0179 "Historico de Envio"
	         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL


         //by GFP - 05/10/2010 - 11:56 - Inclusão da função para carregar campos criados pelo usuario.
         TB_Campos := AddCpoUser(TB_Campos,"EIR","2")

         WorkHist->(dbGotop())
         oMark:= MsSelect():New("WorkHist",,,TB_Campos,.F.,cMarca,;
  	                            {34,1,(oDlgHist:nClientHeight-6)/2,(oDlgHist:nClientWidth-4)/2})
        @ 00,00 MsPanel oPanelHist Prompt "" Size 60,21
		Define SButton From 04,(oDlgHist:nClientWidth-4)/2-30 Type 6 ;
							Action (E_Report(aDados,aRCampos)) Enable Of oPanelHist
		oDlgHist:lMaximized:=.T. //LRL 29/03/04	- Maximilizar Janela

        oPanelHist:Align:=CONTROL_ALIGN_TOP
		oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


// BAK - Tratamento para EnchoiceBar - 18/08/2011
//		Activate MsDialog oDlgHist On Init (DI500EnchoiceBar(oDlgHist,,bCancel,.F.,aButtons),;
		Activate MsDialog oDlgHist On Init (EnchoiceBar(oDlgHist,bOk,bCancel,.F.,aButtons)) //LRL 29/03/04 - Alinhamento Mdi

		Exit

	EndDo

Else

   Help("",1,"AVG0000719")//Este processo nao possui historico de envio.",0057) //0422

Endif

EIR->(dbSetOrder(1))
WorkHist->(E_EraseArq(cNomArq))
dbSelectArea(nOldArea)

Return Nil
*------------------------------------------*
Function DI500Trans(nValor,nDec)
*------------------------------------------*
DEFAULT nDec := If(Type("nDecimais") # "U", nDecimais, AVSX3("W9_FOB_TOT",AV_DECIMAL)) ////NCF - 24/02/2016 - a variável nDecimais não é carregada em algumas funções que invocam a DI500TRans
RETURN ROUND(nValor,nDec)

//Funcao    :ConvInvMoeda( HAWB, MOEDA, Data Conversão )
//Autora    : RHP
//Descricao :Converte todos os totais das invoices para determinada moeda
//            , conforme data de cotação e moedas enviadas como parâmetro
//            O retorno é o valor da moeda passada para conversão , ou
//            um array de valores conforme o parametro recebido
//Sintaxe   : ConvInvMoeda( cHAWB, cMOEDA, dData_Conv )
//Parametros: cHawb : processo
//            cMoeda :array de moedas ou moeda a ser convertido o valor
//                    ou ainda um valor Nil
//            dData_Conv : data da conversao da moeda
//            Retorno : Valor se cMoeda for apenas uma moeda, array se
//                      array de valores se cMoeda for array ou for NIL
//                      neste caso as moedas são da as das invoices
// Uso       :SIGAEIC - quando se utilizar DI eletronica
// Esta funcao serve para trazer o valor total de um processo convertido,
// ou em uma moeda especifica ou  em varias moedas,para isto deve-se
// enviar cMoeda com as moedas que se deseja converter.
// Esta funcao pode retornar, no lugar dos valores convertidos,os totais
// de todas as moedas envolvidas em um processo,para isto deverá ser
// utilizado o parametro cMoeda == nil
// Como utilizar : so se manda cMoeda como parametro se for a moeda ou a lista de
// moedas que se quer converter a ela, senao , o resultado será o total para cada
// moeda envolvida no processo.
*----------------------------------------------------------------------*
FUNCTION ConvInvMoeda( cHAWB, cMOEDA, dData_Conv )
*----------------------------------------------------------------------*
LOCAL aMoeda :={} ,nValorReal := 0 , aValorTotal := {},nValConv := 0 ,IMoeda := 1
LOCAL cFilSW9 := xFilial("SW9"),nRecSW9 := SW9->(RECNO()) , nOrdSW9 := SW9->(INDEXORD()),cFilSW8:=xFilial("SW8")
LOCAL lMoeSW9 := .F.
LOCAL lExiste_Midia := IF(EasyGParam("MV_SOFTWAR",,"N")=="N",.F.,.T.)
LOCAL lPesoMid := SA5->(FIELDPOS("A5_PESOMID")) # 0 .AND. SW7->(FIELDPOS("W7_PESOMID")) # 0
Local aOrd // - BHF - 15/10/08 Declaração de variavel

IF cMoeda == NIL // Retornar os totais nas moedas envolvidas
  lMoeSW9:=.T.
  cMoeda := {}
ENDIF

dData_Conv := IF(dData_Conv == NIL,SW6->W6_DT,dData_Conv)
IF EMPTY(dData_Conv)
   dData_Conv := dDataBase
ENDIF
IF VALTYPE(cMoeda)== "C"  // Converter em apenas uma moeda
  AADD(aMoeda,cMoeda)    //Transformar em array
ELSE
  aMoeda := cMoeda        //Preencher o Array
ENDIF
IF cHAWB # SW6->W6_HAWB
   SW6->(DBSEEK(xFilial("SW6")+cHAWB))
ENDIF
SW9->(DBSETORDER(3))
SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))

  aOrd := SaveOrd({"SB1"}) // - BHF - 15/10/08 Salva ordem SB1

  SW8->(DBSETORDER(1))
  SB1->(dbSetorder(1))
  DO WHILE ! SW9->(EOF()) .AND. cFilSW9 == SW9->W9_FILIAL .AND. SW9->W9_HAWB == SW6->W6_HAWB

     SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))
     nVal_R:=0
     DO WHILE ! SW8->(EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND.;
                                   SW8->W8_HAWB    == SW9->W9_HAWB     .AND.;
                                   SW8->W8_INVOICE == SW9->W9_INVOICE  .AND.;
                                   SW8->W8_FORN    == SW9->W9_FORN     .And.;
                                   (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)

        SB1->(dbSeek(xFilial("SB1")+SW8->W8_COD_I))
        IF ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim// LDR - 25/08/04
           SW2->(DBSETORDER(1))
           SW2->(DBSEEK(xFILIAL("SW2")+SW8->W8_PO_NUM))
           nVal_R += (SW8->W8_QTDE*SB1->B1_QTMIDIA*SW2->W2_VLMIDIA)
        ELSE
           nVal_R+=SW8->W8_QTDE * SW8->W8_PRECO
        ENDIF
        SW8->(DBSKIP())
     ENDDO

    nValorReal +=  nVal_R * IF(!EMPTY(SW9->W9_TX_FOB),SW9->W9_TX_FOB,BuscaTaxa(SW9->W9_MOE_FOB,dData_Conv,.T.,.F.,.T.))

    //total da invoice no valor real
//  nValorReal += SW9->W9_FOB_TOT * IF(!EMPTY(SW9->W9_TX_FOB),SW9->W9_TX_FOB,BuscaTaxa(SW9->W9_MOE_FOB,dData_Conv,.T.,.F.,.T.))

    IF lMoeSW9 // Todos os Totais
      IF (nPos := ASCAN(aValorTotal,{|tab|tab[1]==SW9->W9_MOE_FOB})) == 0
         AADD(aValorTotal ,{SW9->W9_MOE_FOB,nVal_R})
      ELSE  // se ja existe a moeda, soma os valores
        aValorTotal[nPos,2]+=nVal_R
      ENDIF
    ENDIF
    SW9->(DBSKIP())
  ENDDO
//ENDIF

FOR IMoeda := 1 TO Len(aMoeda)   // so entra se for para converter ,se nao for , len(amoeda)=0
 IF aMoeda[IMoeda] == "R$ " // para nao fazer contas a toa
   AADD(aValorTotal,{"R$ ",ROUND(nValorReal,2)})
 ELSE
   AADD(aValorTotal,{aMoeda[Imoeda],ROUND(nValorReal / BuscaTaxa(aMoeda[Imoeda],dData_Conv,.T.,.F.,.T.),2)})
 ENDIF
NEXT

SW9->(DBSETORDER(nOrdSW9))
SW9->(DBGOTO(nRecSW9))

RestOrd(aOrd,.T.) // BHF - 15/10/08 - Retorna indice SB1, posicionando no registro anterior.

RETURN IF(LEN(aValorTotal)==1 .AND. !lMoeSW9,ROUND(aValorTotal[1,2],2),aValorTotal)


//Funcao    :ValorFrete( HAWB, MOEDA, Data Conversão )
//Autora    :RHP
//Descri‡…o :Calcula os valores totais de frete, em R$, na propria moeda
//           ,e conforme data de cotação e moeda enviadas como parâmetro
//           o valor total na moeda passada para conversão
//Sintaxe   :ValorFrete( cHAWB, cMOEDA, dData_Conv )
//Parametros:cHawb     :processo
//           cMoeda    :moeda a ser convertido o valor  , nao obrigatorio
//           dData_Conv:data da conversao da moeda
//Retorno   :array com : 1-Valor em Real
//                       2-Valor na Moeda original
//                       3-Valor na moeda enviada como parametro
//Uso       :SIGAEIC - quando se utilizar DI eletronica
*--------------------------------------------------------------------------------------*
FUNCTION ValorFrete( cHAWB,  cMOEDA, dData_Conv ,nPosicao, ldeMemoria )
*--------------------------------------------------------------------------------------*
LOCAL nValFrete := nFreReal := nFrete := 0 , aFrete := {}
LOCAL nTaxa

lDeMemoria:=IF(lDeMemoria=NIL,.F.,lDeMemoria)

IF cHAWB # SW6->W6_HAWB .AND. !lDeMemoria
   SW6->(DBSEEK(xFilial("SW6")+cHAWB))
ENDIF

IF lDeMemoria
   nValFrete := M->W6_VLFRECC + M->W6_VLFREPP - M->W6_VLFRETN
   nFreReal  := ROUND(nValFrete * M->W6_TX_FRET,2)
ELSE
   nValFrete := SW6->W6_VLFRECC + SW6->W6_VLFREPP - SW6->W6_VLFRETN
   nFreReal  := ROUND(nValFrete * SW6->W6_TX_FRET,2)
ENDIF

IF cMoeda # NIL  .AND. !EMPTY(dData_Conv)
   IF cMoeda != SW6->W6_FREMOED	//ASR 01/11/2005 - Validação que testa se a Moeda for diferente faz a conversão
      nTaxa  := BuscaTaxa(cMoeda,dData_Conv,.T.,.F.,.T.)
      nFrete := IF(nTaxa == 0,0,ROUND(nFreReal / nTaxa,2))
   ELSE		//ASR 01/11/2005 - Sendo iguais traz da capa do Processo
      nFrete := SW6->W6_VLFRECC + SW6->W6_VLFREPP - SW6->W6_VLFRETN	//ASR 01/11/2005
   ENDIF	//ASR 01/11/2005
ENDIF

aFrete := {nFreReal,nValFrete,nFrete}

RETURN IF(nPosicao # NIL ,aFrete[nPosicao],aFrete)

// Funcao    :ConvDespFobMoeda( HAWB, MOEDA, Data Conversão ,aDespesa)
// Descri‡…o :Converte todos os totais das invoices para determinada moeda
//           : , conforme data de cotação e moedas enviadas como parâmetro
//           : O retorno é o valor da moeda passada para conversão , ou
//           : um array de valores conforme o parametro recebido
// Sintaxe   : ConvInvMoeda( cHAWB, cMOEDA, dData_Conv,aDespesa)
// Parametros: cHawb : processo
//             cMoeda :array de moedas ou moeda a ser convertido o valor
//                     ou ainda um valor Nil
//             dData_Conv : data da conversao da moeda
//             Retorno : Valor se cMoeda for apenas uma moeda, array se
//                       array de valores se cMoeda for array ou for NIL
//                       neste caso as moedas são da as das invoices
//             aDespesa:Array de despesas que se quer o retorno, pode ser
//                      pode ser um array unidimensional,caso se queira
//                      os valores convertidos em uma só moeda ou um array
//                      multidimensional se quiser que o retorno seja em
//                      varias moedas (passado em cMoeda) ou nas suas
//                      moedas originais
//  Uso      : SIGAEIC - quando se utilizar DI eletronica
//  Esta funcao serve para trazer o valor total de uma despesa do processo
// convertido em uma moeda especifica ou em varias moedas,para isto deve-se
//   enviar cMoeda com as moedas que se deseja converter.
//   Esta funcao pode retornar, no lugar dos valores convertidos,os totais
//   de todas as moedas envolvidas em um processo,para isto deverá ser
//   utilizado o parametro cMoeda == nil
//   alem disto, deve-se passar quais os totais que se quer no parametro
//   adepesa , que deve ter pelo menos um dos valores :
//   VALOR : Valor Ex Works do processo ( W9_FOB_TOT )
//   INLAND :  somatorio de Inland
//   PACKING : Somatorio de Packing
//   OUTRAS : Somatorio de Outras Despesas
//   DESCONTO : Somatorio de Desconto
//   FRETE : Somatorio dos fretes das invoices
// Como utilizar : so se manda cMoeda como parametro se for a moeda ou a lista de
// moedas que se quer converter a ela, senao , o resultado será o total para cada
// moeda envolvida no processo. Enviar todas as despesas que se queira( que fazem o FOB).
*--------------------------------------------------------------------------------------*
FUNCTION ConvDespFobMoeda( cHAWB, cMOEDA, dData_Conv ,cDespesa)
*--------------------------------------------------------------------------------------*
LOCAL aDespesa := {}, aMoeda :={},aReal:={0,0,0,0,0,0,0,0} , aValorTotal := {},nValConv := 0 ,IMoeda := 1
LOCAL cFilSW9 := xFilial("SW9"),nRecSW9 := SW9->(RECNO()) , nOrdSW9 := SW9->(INDEXORD())
LOCAL lMoeSW9 := .F. , lMesmaMoeda := .F.,nTot:=0 ,nTaxaReal:=0, IReal, IDesp, cFilSW8 := xFilial("SW8")
Local cFilSB1 := xFilial("SB1")
LOCAL aTabValor:=aTabInland :=aTabPacking := aTabOutDesp :=  aTabDesconto := aTabFrete := aTabTudo := aTabFobTudo :={}
LOCAL aTabSeguro:={}  // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
Private lSegInc  := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                    SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0

lExiste_Midia := IF(EasyGParam("MV_SOFTWAR",,"N")=="N",.F.,.T.)
lIn327        := EasyGParam("MV_IN327" ,,.F.)
SX3->(DBSETORDER(2))
lPesoMid := SX3->(dbSeek("A5_PESOMID")) .AND. SX3->(dbSeek("W7_PESOMID"))
SX3->(DBSETORDER(1))

IF cMoeda == NIL // Retornar os totais nas moedas envolvidas
  lMoeSW9:=.T.
  cMoeda := {}
ENDIF

dData_Conv := IF(dData_Conv == NIL,SW6->W6_DT,dData_Conv)

IF VALTYPE(cMoeda)== "C"  // Converter em apenas uma moeda
  AADD(aMoeda,cMoeda)    //Transformar em array
ELSE
  aMoeda := cMoeda        //Preencher o Array
ENDIF
IF VALTYPE(cDespesa)== "C"  // Converter em apenas uma moeda
  AADD(aDespesa,cDespesa)    //Transformar em array
ELSE
  aDespesa :=cDespesa        //Preencher o Array
ENDIF

IF cHAWB # SW6->W6_HAWB
   SW6->(DBSEEK(xFilial("SW6")+cHAWB))
ENDIF
SW9->(DBSETORDER(3))
SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
nTaxaReal := IF(EMPTY(SW9->W9_TX_FOB),BuscaTaxa(SW9->W9_MOE_FOB,dData_Conv,.T.,.F.,.T.),SW9->W9_TX_FOB)

SW8->(DBSETORDER(1))
SB1->(dbSetorder(1))
DO WHILE ! SW9->(EOF()) .AND. cFilSW9 == SW9->W9_FILIAL .AND. SW9->W9_HAWB == SW6->W6_HAWB
   nTaxaReal :=IF(EMPTY(SW9->W9_TX_FOB), BuscaTaxa(SW9->W9_MOE_FOB,dData_Conv,.T.,.F.,.T.),SW9->W9_TX_FOB)

   IF (nPosR := ASCAN(aDespesa,"VALOR" )) # 0
      aReal[nPosR] +=SW9->W9_FOB_TOT*nTaxaReal
      IF lMoeSW9 // Todos os Totais
        IF (nPos := ASCAN(aTabFob,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
          AADD(aTabFob,{SW9->W9_MOE_FOB,SW9->W9_FOB_TOT})
        ELSE
          aTabFob[nPos,2]+=SW9->W9_FOB_TOT
        ENDIF
      ENDIF
    ENDIF

   SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))
   DO WHILE ! SW8->(EOF()) .AND. cFilSW8         == SW8->W8_FILIAL   .AND.;
                                 SW8->W8_HAWB    == SW9->W9_HAWB     .AND.;
                                 SW8->W8_INVOICE == SW9->W9_INVOICE  .AND.;
                                 SW8->W8_FORN    == SW9->W9_FORN     .And.;
                                 (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)

      SB1->(dbSeek(cFilSB1+SW8->W8_COD_I))
      IF !(ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim)
         IF (nPosR := ASCAN(aDespesa,"INLAND" )) # 0
            aReal[nPosR] +=SW8->W8_INLAND*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabInland,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabInland,{SW9->W9_MOE_FOB,SW8->W8_INLAND})
               ELSE
                  aTabInland[nPos,2]+=SW8->W8_INLAND
               ENDIF
            ENDIF
         ENDIF

         IF (nPosR := ASCAN(aDespesa,"PACKING" )) # 0
            aReal[nPosR] +=SW8->W8_PACKING*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabPacking,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabPacking,{SW9->W9_MOE_FOB,SW8->W8_PACKING})
               ELSE
                  aTabPacking[nPos,2]+=SW8->W8_PACKING
               ENDIF
            ENDIF
         ENDIF

         IF (nPosR:=ASCAN(aDespesa,"OUTRAS" )) # 0
            aReal[nPosR] +=SW8->W8_OUTDESP*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabOutDesp,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabOutDesp,{SW9->W9_MOE_FOB,SW8->W8_OUTDESP})
               ELSE
                  aTabOutDesp[nPos,2]+=SW8->W8_OUTDESP
               ENDIF
            ENDIF
         ENDIF

         IF (nPosR := ASCAN(aDespesa,"DESCONTO" )) # 0 .AND. !lIn327
            aReal[nPosR] +=SW8->W8_DESCONTO*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabDesconto,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabDesconto,{SW9->W9_MOE_FOB,SW8->W8_DESCONTO})
               ELSE
                  aTabDesconto[nPos,2]+=SW8->W8_DESCONTO
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF (nPosR := ASCAN(aDespesa,"TUDO" )) # 0
         nTotDesp := 0
         nFre := 0
         nSeg := 0
         IF !(ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim)
            nTot += SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(!lIn327,SW8->W8_DESCONT,0)
            nTotDesp := SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(!lIn327,SW8->W8_DESCONT,0)
         ENDIF
         IF AvRetInco(SW9->W9_INCOTER,"CONTEM_FRETE")/*FDR - 28/12/10*/  /*SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. SW9->W9_FREINC $ cNao//AWR - DDU
            nTot += SW8->W8_FRETEIN
            nFre := SW8->W8_FRETEIN
         ENDIF
         // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF lSegInc .AND. AvRetInco(SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 28/12/10*/  /*SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. SW9->W9_SEGINC $ cNao
            nTot += SW8->W8_SEGURO
            nSeg := SW8->W8_SEGURO
         ENDIF

         aReal[nPosR] :=nTot *nTaxaReal
         IF lMoeSW9 // Todos os Totais
            IF (nPos := ASCAN(aTabTudo,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
               AADD(aTabTudo,{SW9->W9_MOE_FOB,nTotDesp+nFre+nSeg})
            ELSE
               aTabTudo[nPos,2]+=nTotDesp+nFre+nSeg
            ENDIF
         ENDIF
      ENDIF

      IF (nPosR := ASCAN(aDespesa,"FOB_TUDO" )) # 0
         nTot += (SW8->W8_PRECO*SW8->W8_QTDE)
         nTotDesp := 0
         IF !(ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim)
            nTotDesp := DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T.)  // EOB - 14/07/08 - chamada da função DI500RetVal
            nTot += nTotDesp
         ENDIF
         aReal[nPosR] :=nTot *nTaxaReal
         IF lMoeSW9 // Todos os Totais
            IF (nPos := ASCAN(aTabFobTudo,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
               AADD(aTabFobTudo,{SW9->W9_MOE_FOB,(SW8->W8_PRECO*SW8->W8_QTDE)+nTotDesp })
            ELSE
               aTabFobTudo[nPos,2]+=(SW8->W8_PRECO*SW8->W8_QTDE)+nTotDesp
            ENDIF
         ENDIF
      ENDIF

      IF (nPosR := ASCAN(aDespesa,"FRETE" )) # 0
         IF AvRetInco(SW9->W9_INCOTER,"CONTEM_FRETE")/*FDR - 28/12/10*/ /*SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. SW9->W9_FREINC $ cNao//AWR - DDU
            aReal[nPosR] +=SW8->W8_FRETEIN*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabFrete,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabFrete,{SW9->W9_MOE_FOB,SW8->W8_FRETEIN})
               ELSE
                  aTabFrete[nPos,2]+=SW8->W8_FRETEIN
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF (nPosR := ASCAN(aDespesa,"SEGURO" )) # 0
         IF lSegInc .AND. AvRetInco(SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 28/12/10*/ /*SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"*/ .AND. SW9->W9_SEGINC $ cNao
            aReal[nPosR] +=SW8->W8_SEGURO*nTaxaReal
            IF lMoeSW9 // Todos os Totais
               IF (nPos := ASCAN(aTabSeguro,{|tab|tab[1]==SW9->W9_MOE_FOB  })) == 0
                  AADD(aTabSeguro,{SW9->W9_MOE_FOB,SW8->W8_SEGURO})
               ELSE
                  aTabSeguro[nPos,2]+=SW8->W8_SEGURO
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      SW8->(dbSkip())
   ENDDO
   SW9->(DBSKIP())
ENDDO
//ENDIF


IF !lMoeSW9
  FOR IReal:=1 TO LEN(aReal)
    if  aReal[IReal] # 0 .OR. LEN(aDespesa ) # 1  .OR.  LEN(aMoeda ) # 1
     FOR IMoeda := 1 TO Len(aMoeda)   // so entra se for para converter ,se nao for , len(amoeda)=0
       IF aMoeda[IMoeda] == "R$ " // para nao fazer contas a toa
         AADD(aValorTotal,{"R$ ",ROUND(aReal[IReal],2)})
       ELSE
         AADD(aValorTotal,{aMoeda[Imoeda],ROUND(aReal[IReal] / BuscaTaxa(aMoeda[Imoeda],dData_Conv,.T.,.F.,.T.),2)})
       ENDIF
     NEXT
   ENDIF
  NEXT
ELSE
  FOR iDesp :=1 TO LEN(aDespesa)
   DO CASE
     CASE aDespesa[iDesp] == "VALOR"
       IF Len(aTabFob) # 0
          AADD(aValorTotal, aTabFob)
       EndIf
     CASE aDespesa[iDesp] == "INLAND"
       IF Len(aTabInland) # 0
          AADD(aValorTotal, aTabInland)
       EndIf
     CASE aDespesa[iDesp] == "PACKING"
       IF Len(aTabPacking) # 0
          AADD(aValorTotal, aTabPacking)
       EndIf
     CASE aDespesa[iDesp] == "OUTRAS"
       IF Len(aTabOutDesp) # 0
          AADD(aValorTotal, aTabOutDesp)
       EndIf
     CASE aDespesa[iDesp] == "DESCONTO"
       IF Len(aTabDesconto) # 0
          AADD(aValorTotal, aTabDesconto)
       EndIf
     CASE aDespesa[iDesp] == "FRETE"
       IF Len(aTabFrete) # 0
          AADD(aValorTotal, aTabFrete)
       EndIf
     CASE aDespesa[iDesp] == "TUDO"
       IF Len(aTabTudo) # 0
          AADD(aValorTotal ,aTabTudo)
       EndIf
     CASE aDespesa[iDesp] == "FOB_TUDO"
       IF Len(aTabFobTudo) # 0
          AADD(aValorTotal,aTabFobTudo)
       EndIf
     // EOB - 14/07/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
     CASE aDespesa[iDesp] == "SEGURO"
       IF Len(aTabSeguro) # 0
          AADD(aValorTotal,aTabSeguro)
       EndIf
   ENDCASE
 NEXT
ENDIF
SW9->(DBSETORDER(nOrdSW9))
SW9->(DBGOTO(nRecSW9))
IF LEN(aValorTotal)== 0
  AADD(aValorTotal,{"  ",0})
ENDIF
RETURN aValorTotal

*------------------------------------------------------------------------------*
Function TransQtde(nQtd,lRetUnid,cTipoAC,cCod_I,cFabr,cForn,cCC,cSi_num,nPesoUn, cFabLoj, cForLoj)
*------------------------------------------------------------------------------*
Local nQtdAux, cUnid, nQtdNcmAux

cUnid:=BUSCA_UM(cCod_I+cFabr+cForn,cCC+cSi_num, cFabLoj, cForLoj)

If lRetUnid
   Return cUnid
   EndIf

/*
If AvVldUn(ED4->ED4_UMITEM) // MPG - 06/02/2018
   nQtdAux := nPesoUn * nQtd
ElseIf (cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and. cUnid <> ED4->ED4_UMITEM
   nQtdAux := AvTransUnid(cUnid,ED4->ED4_UMITEM,cCod_I,nQtd)
Else
   nQtdAux := nQtd
EndIf

If !lQT_AC2
   nQtdNcmAux := 0
ElseIf (cTipoAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and. cUnid <> ED4->ED4_UMNCM
   //nQtdNcmAux := AVTransUnid(cUnid,ED4->ED4_UMNCM,cCod_I,nQtd)
   // PLB 02/05/06 - Verificacao da Quantidade na UM de Compra
   nQtdNcmAux := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,cCod_I,nQtdAux)
Else
   nQtdNcmAux := nQtd
EndIf
*/

   //** PLB 18/07/07
   If ( cTipoAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMITEM
      nQtdAux := nQtd
   ElseIf AvVldUn(ED4->ED4_UMITEM) // MPG - 06/02/2018
      nQtdAux := nPesoUn * nQtd
   Else
      nQtdAux := AvTransUnid(cUnid,ED4->ED4_UMITEM,cCod_I,nQtd)
   EndIf

//   If !lQT_AC2
//      nQtdNcmAux := 0
//   Else
      If ( cTipoAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMNCM
         nQtdNcmAux := nQtd
      ElseIf AvVldUn(ED4->ED4_UMNCM) // MPG - 06/02/2018
         nQtdNcmAux := nPesoUn * nQtd
      ElseIf ED4->ED4_UMITEM == ED4->ED4_UMNCM
         nQtdNcmAux := nQtdAux
      Else
         nQtdNcmAux := AVTransUnid(cUnid,ED4->ED4_UMNCM,cCod_I,nQtd)
         If Empty(nQtdNcmAux)  .And.  !Empty(nQtdAux)
            nQtdNcmAux := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,cCod_I,nQtdAux)
         EndIf
      EndIf
//   EndIf
   //**

Return {nQtdAux,nQtdNcmAux}

*--------------------*
Function AtuValidade()
*--------------------*
Local aOrd:= SaveOrd({"ED0", "ED3", "ED4"})

ED3->(dbSetOrder(2))

If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
   ED0->(dbSetOrder(2))
   ED0->(dbSeek(cFilED0+ED4->ED4_AC))
EndIf
If Empty(ED0->ED0_DT_VA2) .AND. ED0->ED0_MODAL <> "2" //AAF 19/04/05 - Não calcular validade apos embarque em Isenção.
   ED0->(RecLock("ED0",.F.))
   ED0->ED0_DT_VA2 := M->W6_DTREG_D + EasyGParam("MV_DIASPRD",,180)
   ED0->(msUnlock())
   ED4->(dbSeek(cFilED4+ED0->ED0_AC))
   Do While !ED4->(EOF()) .and. ED4->ED4_FILIAL == cFilED4 .and. ED4->ED4_AC == ED0->ED0_AC
      //** AAF 27/09/06 - Verifica se o registro já está travado.
      If !ED4->( isLocked() )
         ED4->(RecLock("ED4",.F.))
      EndIf
      //**
      ED4->ED4_DT_VAL := ED0->ED0_DT_VA2
      ED4->(msUnlock())
      ED4->(dbSkip())
   EndDo
   ED3->(dbSeek(cFilED3+ED0->ED0_AC))
   Do While !ED3->(EOF()) .and. ED3->ED3_FILIAL == cFilED3 .and. ED3->ED3_AC == ED0->ED0_AC
      //** AAF 27/09/06 - Verifica se o registro já está travado.
      If !ED3->( isLocked() )
         ED3->(RecLock("ED3",.F.))
      EndIf
      //**
      ED3->ED3_DT_VAL := ED0->ED0_DT_VA2
      ED3->(msUnlock())
      ED3->(dbSkip())
   EndDo

EndIf

RestOrd(aOrd, .T.)
Return .T.

*--------------------------*
Function DI500AtuAC(lPosic,lEstorno)
*--------------------------*
Local nQtdAux, /*aQtd:={},*/ nQtdNcmAux,lAchou:=.F.,lGravaArquivo:=.F.,cAliasSW8:="Work_SW8"//AWR 14/04/05
Local nCoef   := 0  ,;
      nValAux := 0
Local cUnid
Default lPosic  := .F. //AAF 25/05/05
Default lEstorno:= .F. //AAF 26/05/05

IF Work_SW8->(EasyReccount("Work_SW8")) == 0//AWR 14/04/05
   nRecW9:= SW9->( RecNo() )//AAF 25/05/05
   Processa({|| DI500InvCarrega()},STR0180) // STR0180  "Pesquisa de Itens"
   SW9->( dbGoTo(nRecW9) )//AAF 25/05/05 - Volta ao Registro do Loop no SW9.
   cAliasSW8:="SW8"
   lGravaArquivo:=.T.
ENDIF

If lPosic
   cAliasSW8:="SW8"
   lGravaArquivo:=.T.
   Work_SW9->( dbSeek(SW9->( W9_INVOICE+W9_FORN+EICRetLoja("SW9", "W9_FORLOJ") )) )
Endif

Work_SW8->(dbSetOrder(1))
Work_SW8->(dbSeek(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))

DO WHILE !Work_SW8->(EOF()) .and. Work_SW8->WKINVOICE==Work_SW9->W9_INVOICE .AND.;
Work_SW8->WKFORN==Work_SW9->W9_FORN .And. (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)

   If lIntDraw .and. !Empty(Work_SW8->WKAC)
      ED4->(dbSeek(cFilED4+Work_SW8->WKAC+Work_SW8->WKSEQSIS))
      ED0->(dbSeek(cFilED0+Work_SW8->WKAC))
      If !lEstorno //Abate o Saldo



         // NOPADO POR - AOM 29/09/10 - baixa feita pela função AC400BxSld

         /*aQtd := TransQtde(Work_SW8->WKQTDE,,ED0->ED0_TIPOAC,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM,Work_SW8->WKPESO_L, EICRetLoja("Work_SW8", "W8_FABLOJ"), EICRetLoja("Work_SW8", "W8_FORLOJ"))
         nQtdAux    := aQtd[1]
         nQtdNcmAux := aQtd[2]
         //** AAF 27/09/06 - Verifica se o registro já está travado.
         If !ED4->( isLocked() )
            ED4->(RecLock("ED4",.F.))
         EndIf
         //**
         If ED4->ED4_NCM <> NCM_GENERICA
            ED4->ED4_QT_DI  -= nQtdAux
            If AvVldUn(ED4->ED4_UMNCM) // MPG - 06/02/2018
               ED4->ED4_SNCMDI -= Work_SW8->WKPESO_L * Work_SW8->WKQTDE
               nQtdNcmAux := Work_SW8->WKPESO_L * Work_SW8->WKQTDE
            Else
               ED4->ED4_SNCMDI -= nQtdNcmAux
            Endif
         EndIf*/
         SW5->(dbSetOrder(8))   //GFC - 16/07/2003 - Pegar dados da LI e não calcular mais.
         SW5->(dbSeek(cFilSW5+Work_SW8->WKPGI_NUM+Work_SW8->WKPO_NUM+Work_SW8->WKPOSICAO))
         Do While !SW5->(EOF()) .and. SW5->W5_SEQ <> 0
            SW5->(dbSkip())
         EndDo
         If SW5->W5_SEQ == 0
         //   ED4->ED4_VL_DI -= (Work_SW8->WKQTDE / SW5->W5_QTDE) * SW5->W5_VL_AC //AAF 25/05/05
         //   //ED4->ED4_VL_DI -= SW5->W5_VL_AC   - GFC 14/09/2004

            //** PLB 18/07/07 - Baixa o saldo com as quantidades iguais as da PLI, respeitando a proporção
            nCoef := Work_SW8->WKQTDE / SW5->W5_QTDE

            nQtdAux := nCoef * SW5->W5_QT_AC
            //If lQT_AC2
               nQtdNcmAux := nCoef * SW5->W5_QT_AC2
            //Else
               //nQtdNcmAux := 0
               //MsgInfo("Dicionário de Dados incompleto. Contate o suporte Average.")
            //EndIf
            nValAux := nCoef * SW5->W5_VL_AC

            /* - 23/04/2010 - NCF - Nopado por baixar duplicado o valor a ser abatido do saldo Qtde da DI
            If ED4->ED4_NCM <> NCM_GENERICA
               ED4->ED4_QT_DI  -= nQtdAux
               ED4->ED4_SNCMDI -= nQtdNcmAux
            EndIf
            */

            cUnid := TransQtde(Work_SW8->WKQTDE,.T.,ED0->ED0_TIPOAC,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM,Work_SW8->WKPESO_L, EICRetLoja("Work_SW8", "W8_FABLOJ"), EICRetLoja("Work_SW8", "W8_FORLOJ"))

            //AOM - 29/09/10 - Baixa no Ato Concessório da DI
            AC400BxSld(Work_SW8->WKQTDE, cUnid, Work_SW8->WKPESO_L , nValAux, EasyGParam("MV_SIMB2",,"US$"), Work_SW8->WKAC, Work_SW8->WKSEQSIS,.T.,.F.,.T.)

            //ED4->ED4_VL_DI  -= nValAux
            //**
         EndIf
         SW5->(dbSetOrder(1))
         ED4->(msUnlock())
         lAchou:=.F.
         IF lGravaArquivo//AWR 14/04/05
            SW8->(dbSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
            lAchou:=SW8->(DBSEEK( xFilial()+M->W6_HAWB+Work_SW8->(WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ))
         ENDIF
         IF lAchou
            (cAliasSW8)->(RecLock(cAliasSW8,.F.))
         ENDIF
         If ED4->ED4_NCM <> NCM_GENERICA
            IF lGravaArquivo .AND. lAchou//AWR 14/04/05
               SW8->W8_QT_AC  := nQtdAux
            ELSE
               Work_SW8->WKQT_AC  := nQtdAux
            ENDIF
            IF lGravaArquivo .AND. lAchou//AWR 14/04/05
               SW8->W8_QT_AC2 := nQtdNcmAux
            ELSE
               Work_SW8->WKQT_AC2 := nQtdNcmAux
            ENDIF
         EndIf
         If SW5->W5_SEQ == 0
         //   IF lGravaArquivo .AND. lAchou//AWR 14/04/05
         //      SW8->W8_VL_AC := (Work_SW8->WKQTDE / SW5->W5_QTDE) * SW5->W5_VL_AC
         //   ELSE
         //      Work_SW8->WKVL_AC := (Work_SW8->WKQTDE / SW5->W5_QTDE) * SW5->W5_VL_AC   //GFC 14/09/2004
         //   EndIf
         //
            //** PLB 18/07/07
            If lGravaArquivo  .And.  lAchou
               SW8->W8_VL_AC := nValAux
            Else
               Work_SW8->WKVL_AC := nValAux
            EndIf
            //**
         EndIf
         (cAliasSW8)->(msUnlock())
         If cAntImp=="2" .and. ED0->ED0_MODAL == "1" //GFC - 17/07/2003 - Anterioridade Drawback
            DIGrvAnt(1,M->W6_HAWB,Work_SW8->WKPO_NUM,Work_SW8->WKINVOICE,Work_SW8->WKCOD_I,Work_SW8->WKPOSICAO,Work_SW8->WKPGI_NUM,nQtdAux/*Work_SW8->WKQT_AC*/,M->W6_DTREG_D,ED4->ED4_AC,ED4->ED4_SEQSIS,ED4->ED4_PD)  // PLB 19/12/06 - Var nQtdAux
         EndIf
      Else
         // ** AAF 25/05/05 - Volta o Saldo
         SW8->( dbSetOrder(6) )//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
         If SW8->(DBSEEK(xFilial()+M->W6_HAWB+Work_SW8->(WKINVOICE+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ))
            If ED4->(dbSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS))

               // ** AAF 27/09/06 - Verifica se o registro já está travado.
               If !ED4->( isLocked() )
                  ED4->(RecLock("ED4",.F.))
               EndIf
               // **

               ED4->ED4_QT_DI += SW8->W8_QT_AC
               ED4->ED4_VL_DI += SW8->W8_VL_AC
               ED4->ED4_SNCMDI+= SW8->W8_QT_AC2

               If GetModAtoC(SW8->W8_AC) == "1"        //NCF - 15/08/2019 - Só gera saldo a exportar quando modalidade = Suspensão
                  //AOM - 29/09/10
                  If ED4->(FieldPos("ED4_SQTDEX")) > 0
                     ED4->ED4_SQTDEX -=SW8->W8_QT_AC
                  EndIf

                  If ED4->(FieldPos("ED4_SNCMEX")) > 0
                     ED4->ED4_SNCMEX -=SW8->W8_QT_AC2
                  EndIf
               EndIf
               
               ED4->( MsUnLock() )

               RecLock("SW8",.F.)
               SW8->W8_QT_AC := 0
               SW8->W8_VL_AC := 0
               SW8->W8_QT_AC2:= 0
               SW8->( MsUnLock() )
            Endif
            If cAntImp=="2" .and. ED0->ED0_MODAL == "1"  //PLB 19/12/06 - Anterioridade Drawback
               DIGrvAnt(2,SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM)
            EndIf
         Endif
         // **
      Endif
      AtuValidade()
   EndIf
   Work_SW8->(dbSkip())
EndDo
SW8->(dbSetOrder(1))

Return .T.

*-------------------------------------------------------------------------------------------------------------------------*
Function DIGrvAnt(nOpc,cAntHawb,cAntPO,cAntInv,cAntItem,cAntPos,cAntPGI,cAntQtd,cAntData,cAC,cSeq,cPD,cCodOpe)
*-------------------------------------------------------------------------------------------------------------------------*
 Local lIndexPed := "EDD_PEDIDO" $ EDD->(IndexKey(1)) .And. "EDD_PEDIDO" $ EDD->(IndexKey(2))//AOM - 22/11/2011 - Verifica se o indice está atualizado com o campo Pedido
 Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade
 Local nQtdOcor  := 0 , nRecEDD := 0
 Local lMFilEDC  := VerSenha(115)  ;
                    .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                    .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                    .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                    .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                    .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                    .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                    .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                    .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                    .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0

 //AOM - 23/11/2011
 Default cAntHawb:= Space(AVSX3("EDD_HAWB"  ,AV_TAMANHO))
 Default cAntPO  := Space(AVSX3("EDD_PO_NUM",AV_TAMANHO))
 Default cAntInv := Space(AVSX3("EDD_INVOIC",AV_TAMANHO))
 Default cAntItem:= Space(AVSX3("EDD_ITEM"  ,AV_TAMANHO))
 Default cAntPos := Space(AVSX3("EDD_POSICA",AV_TAMANHO))
 Default cAntPGI := Space(AVSX3("EDD_PGI_NU",AV_TAMANHO))
 Default cAntQtd := Space(AVSX3("EDD_QTD"   ,AV_TAMANHO))
 Default cPD := Space(AVSX3("EDD_PD"   ,AV_TAMANHO))

 If  AvFlags("SEQMI") .AND. Empty(cAntHawb)
    Default cSeq    := Space(AVSX3("EDD_SEQMI"    ,AV_TAMANHO))
 Else
    Default cSeq    := Space(AVSX3("EDD_SEQSII"    ,AV_TAMANHO))
 EndIf

 //AOM - 22/06/2012
 If lTpOcor
   Default cCodOpe  := Space(AVSX3("EDH_CODOCO"    ,AV_TAMANHO))
 EndIf


   If nOpc = 1       //INCLUIR
      EDD->(RecLock("EDD",.T.))
      EDD->EDD_FILIAL := xFilial("EDD")
      EDD->EDD_AC     := cAC//ED4->ED4_AC
      EDD->EDD_PD     := cPD//ED4->ED4_PD
      EDD->EDD_HAWB   := cAntHawb //M->W6_HAWB
      EDD->EDD_PO_NUM := cAntPO //Work_SW8->WKPO_NUM
      EDD->EDD_INVOIC := cAntInv //Work_SW8->WKINVOICE
      EDD->EDD_ITEM   := cAntItem //Work_SW8->WKCOD_I
      EDD->EDD_POSICA := cAntPos //Work_SW8->WKPOSICAO
      EDD->EDD_PGI_NU := cAntPGI //Work_SW8->WKPGI_NUM
      EDD->EDD_SEQSII := cSeq// ED4->ED4_SEQSIS
      IF ED4->(FieldPos("ED4_SEQMI")) > 0 .And. Empty(cAntHawb) // GFP - 10/11/2011 - Tratamento de Compras Nacionais e Vendas para Exportadores
         EDD->EDD_SEQMI  := cSeq//ED4->ED4_SEQMI
      Else
         EDD->EDD_SEQSII := cSeq// ED4->ED4_SEQSIS
      ENDIF
      EDD->EDD_QTD    := cAntQtd //If(cAlias="Work",Work_SW8->WKQT_AC,SW8->W8_QT_AC)
      EDD->EDD_DTREG  := cAntData //dDataReg
      EDD->EDD_QTD_OR := cAntQtd //If(cAlias="Work",Work_SW8->WKQT_AC,SW8->W8_QT_AC)
      If lMFilEDC
         EDD->EDD_FILIMP := cFilAnt
      EndIf
      //AOM - 22/06/2012
      If lTpOcor
         EDD->EDD_CODOCO  := cCodOpe
      EndIf
      EDD->(MsUnlock())
   ElseIf nOpc = 2   //EXCLUIR

      // GFP - 10/11/2011 - Tratamento de Compras Nacionais e Vendas para Exportadores
      IF AvFlags("SEQMI") .AND. Empty(cAntHawb) .And. !Empty(cAntPO)
         EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ELSE
         EDD->(DbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ENDIF

      If EDD->(dbSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")))
         EDD->(RecLock("EDD",.F.))
         EDD->(dbDelete())
         EDD->(MsUnlock())
      EndIf
   //** PLB 19/12/06
   ElseIf nOpc == 3  // ALTERAR

      // GFP - 10/11/2011 - Tratamento de Compras Nacionais e Vendas para Exportadores
      IF AvFlags("SEQMI") .AND. Empty(cAntHawb)
         EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ELSE
         EDD->(DbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ENDIF

      If EDD->( DBSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")))
         While xFilial("EDD") == EDD->EDD_FILIAL .And. AvKey(cAntHawb,"EDD_HAWB") == EDD->EDD_HAWB .And. AvKey(cAntInv ,"EDD_INVOIC") == EDD->EDD_INVOIC .And. ;
               AvKey(cAntPO  ,"EDD_PO_NUM") == EDD->EDD_PO_NUM .And. AvKey(cAntPos ,"EDD_POSICA") == EDD->EDD_POSICA .And. AvKey(cAntPGI ,"EDD_PGI_NU") == EDD->EDD_PGI_NU .And.;
               IF(lTpOcor, Empty(EDD->EDD_CODOCO),.T.) //AOM - 25/06/2012
            RecLock("EDD",.F.)
            EDD->EDD_DTREG  := cAntData
            EDD->(MsUnlock())
         EDD->(DbSkip())
         EndDo
      EndIf
   // **
   ElseIf nOpc == 4 // Baixa de Quanntidade

      // GFP - 10/11/2011 - Tratamento de Compras Nacionais e Vendas para Exportadores
      IF AvFlags("SEQMI") .AND. Empty(cAntHawb)
         EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ELSE
         EDD->(DbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ENDIF

      If EDD->( DBSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")+AvKey(cAC     ,"EDD_AC")+cSeq+ AvKey("","EDD_PREEMB") + IF(lIndexPed,AvKey("","EDD_PEDIDO")+AvKey("","EDD_SEQUEN"),"") + If(lTpOcor,AvKey("","EDD_CODOCO"),"") ))
         nQtdOcor := EDD->EDD_QTD - cAntQtd
         //AOM - 18/11/2011 - Parametro para permitir a gravação de comprovação de anterioridade negativa
         If !EasyGParam("MV_EDC0009",,.F.) .And. nQtdOcor <= 0
            EDD->(RecLock("EDD",.F.))
            EDD->(dbDelete())
            EDD->(MsUnlock())
         Else
            If EDD->(RecLock("EDD",.F.))
               EDD->EDD_QTD    := nQtdOcor
            EDD->(MsUnlock())
            EndIf
         EndIf
         //AOM - 22/06/2012
         If lTpOcor
            DIGrvAnt(1,EDD->EDD_HAWB,EDD->EDD_PO_NUM,EDD->EDD_INVOIC,EDD->EDD_ITEM,EDD->EDD_POSICA,EDD->EDD_PGI_NU,cAntQtd,EDD->EDD_DTREG,EDD->EDD_AC,cSeq,EDD->EDD_PD,cCodOpe)
         EndIf
      EndIf

   ElseIf nOpc == 5 // Estorno de Quantidade

      // GFP - 10/11/2011 - Tratamento de Compras Nacionais e Vendas para Exportadores
      IF AvFlags("SEQMI") .AND. Empty(cAntHawb)
         EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ELSE
         EDD->(DbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO
      ENDIF

      If lTpOcor .And. !Empty(cCodOpe) .And. EDD->( DBSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")+AvKey(cAC     ,"EDD_AC")+cSeq + AvKey("","EDD_PREEMB") + IF(lIndexPed,AvKey("","EDD_PEDIDO")+AvKey("","EDD_SEQUEN"),"") + AvKey(cCodOpe,"EDD_CODOCO") ))
            nRecEDD := EDD->(Recno())
               //AOM - 22/06/2012
               If EDD->( DBSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")+AvKey(cAC     ,"EDD_AC")+cSeq + AvKey("","EDD_PREEMB") + IF(lIndexPed,AvKey("","EDD_PEDIDO")+AvKey("","EDD_SEQUEN"),"") + AvKey("","EDD_CODOCO") ))
                  If EDD->(RecLock("EDD",.F.))
                     EDD->EDD_QTD    += cAntQtd
                  EDD->(MsUnlock())
                  EndIf
                  EDD->(DbGoTo(nRecEDD))
                  If EDD->(RecLock("EDD",.F.))
                     EDD->(dbDelete())
                     EDD->(MsUnlock())
                  EndIf
               Else
                  EDD->(DbGoTo(nRecEDD))
                  If EDD->(RecLock("EDD",.F.))
                     EDD->EDD_CODOCO   := ""
                  EDD->(MsUnlock())
                  EndIf
               EndIf


      ElseIf EDD->( DBSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv ,"EDD_INVOIC")+AvKey(cAntPO  ,"EDD_PO_NUM")+AvKey(cAntPos ,"EDD_POSICA")+AvKey(cAntPGI ,"EDD_PGI_NU")+AvKey(cAC     ,"EDD_AC")+cSeq + AvKey("","EDD_PREEMB") + IF(lIndexPed,AvKey("","EDD_PEDIDO")+AvKey("","EDD_SEQUEN"),"") + If(lTpOcor,AvKey("","EDD_CODOCO"),"") ))
         If EDD->(RecLock("EDD",.F.))
            EDD->EDD_QTD    += cAntQtd
         EDD->(MsUnlock())
         EndIf

      Else
        DIGrvAnt(1,cAntHawb,cAntPO,cAntInv,cAntItem,cAntPos,cAntPGI,cAntQtd,If(Empty(cAntData),dDatabase,cAntData),cAC,cSeq,cPd,)
      EndIf
   EndIf


Return .T.

*---------------------------------------------------*
// AWR  10/06/2003 - Projeto DSI e Regime Tributario
Function DI500Simples(oBrw,lLocRegTri)
*---------------------------------------------------*
LOCAL nInd,oDlgEIJ,nTipo:=2
LOCAL aTelaInv, aGetsInv, cTitulo, TB
DEFAULT lLocRegTri:= .F.
PRIVATE lRegTri   := lLocRegTri, aBotaoDSI:={}
PRIVATE cFiltroSJP:=cFiltroSJ8:=cFiltroSY8:=cFiltroSJR:=cFiltroRPC:=cFiltroEIV:=""
PRIVATE lWhenAutPis:=.F.,lWhenAutCof:= .F.

If AvFlags("DUIMP") .AND. M->W6_TIPOREG == "2"
   EasyHelp(STR0284,STR0285) // "Ação não disponível para processos do tipo DUIMP.","AVISO"
   Return .F.
EndIf

IF !lRegTri .AND. nPos_aRotina # VISUAL .AND. nPos_aRotina # ESTORNO
   IF EMPTY(M->W6_TIPODES)
      MSGINFO(STR0181 + AVSX3("W6_TIPODES",15)) //STR0181 "Para gerar os impostos e necessario o preenchimento do Campo Tipo da Declaracao na Pasta: "
      RETURN .F.
   ENDIF
   SJW->(DBSETORDER(1))
   IF SJW->(DBSEEK(xFilial()+M->W6_TIPODES))
      DO WHILE SJW->(!EOF()) .AND. xFilial("SJW") == SJW->JW_FILIAL .AND. SJW->JW_NAT_OPE == M->W6_TIPODES
         IF !(SJW->JW_REGIME $ cFiltroSJP)
            cFiltroSJP+=SJW->JW_REGIME+","
         ENDIF
         IF !(SJW->JW_FUND_LE $ cFiltroSY8) .AND. SJW->JW_FUND_LE # "00"
            cFiltroSY8+=SJW->JW_FUND_LE+","
         ENDIF
         SJW->(DBSKIP())
      ENDDO
      cFiltroSJP:=LEFT(cFiltroSJP,LEN(cFiltroSJP)-1)
      cFiltroSY8:=LEFT(cFiltroSY8,LEN(cFiltroSY8)-1)
   ELSEIF SJW->(EOF()) .AND. SJW->(BOF())
      Help(" ",1,"AVG0005353")  //LRL 08/01/04 MSGINFO("Arquivo de Regras da DSI esta vazio: Entre no Menu
                                //Atualizacoes/Tabelas Siscomex/Sisccad (Siscomex) e Importe a Opcao Regras da DSI.")
      RETURN .F.
   ENDIF
ENDIF

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_EIJ->(EasyReccount("Work_EIJ")) == 0
         Processa({|| DI500EIGrava('LEITURA',SW6->W6_HAWB,aAliasAdic)},STR0182) //STR0182 "Lendo Impostos..."
      ENDIF
      IF Work_SW8->(EasyReccount("Work_SW8")) == 0
         Processa({|| DI500InvCarrega()},STR0180) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI500Existe() },STR0180) //"Pesquisa de Itens"
   ENDIF
ENDIF

Work_EIJ->(DBGOTOP())
IF nPos_aRotina # VISUAL .AND. nPos_aRotina # ESTORNO

   Work_SW8->(DBGOTOP())
   IF WORK_SW8->(BOF()) .AND. WORK_SW8->(EOF())
      IF lRegTri
         MSGINFO(STR0183,STR0185) //STR0183 "Nao ha Itens de Invoices para Aliquotas." // STR0185 "Informação"
      ELSE
         MSGINFO(STR0184,STR0185)//STR0184 "Nao ha Itens de Invoices para calcular a DSI."// STR0185 "Informação"
      ENDIF
      RETURN .T.
   ENDIF

   Work_SW8->(DBSETORDER(1))
   Work_SW9->(DBGOTOP())

   DO WHILE !Work_SW9->(EOF())
      IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
         Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))
         IF DI500InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T., EICRetLoja("Work_SW9", "W9_FORLOJ"))
            Processa( {|| DI500InvTotais(.F.,.F.) } )
         ELSE
            RETURN .T.
         ENDIF
      ENDIF
      Work_SW9->(DBSKIP())
   ENDDO

   DI500CarrSWP()

   IF !lRegTri
      DI500Controle(3,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
      Work_EIJ->(DBSETORDER(1))
      Work_EIJ->(DBGOTOP())
      IF !(Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())) .AND.;
         !(M->W6_ADICAOK $ cSim)
         Processa( {|| DI500CalcDSI("Work_EIJ",.T.) } , STR0186) //STR0186 "Calculando Impostos"
      ENDIF
   ENDIF

ELSE
   IF Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())
      IF lRegTri
         MSGINFO(STR0187,STR0185) //STR0187 "Nao ha Aliquotas para Consulta." //STR0185 "Informação"
      ELSE
         MSGINFO(STR0188,STR0185) //STR0188 "Nao ha Impostos da DSI para Consulta." //STR0185 "Informação"
      ENDIF
      RETURN .T.
   ENDIF

ENDIF

PRIVATE aCposMostra:={},nPos:=5

aTB_CposEIJ:={}
AADD(aTB_CposEIJ,{"EIJ_ADICAO",,STR0042}) //STR0042 "Codigo"

//AWR - Mudei para baixo - 19/09/2008 - AADD(aTB_CposEIJ,{{|| Transform(Work_EIJ->EIJ_TEC,AVSX3('EIJ_TEC',6)) },,"NCM"})   //TRP-19/12/07- NCM
IF lRegTri
   //II
   AADD(aCposMostra,"EIJ_REGTRI")
   AADD(aCposMostra,"EIJ_ALI_II")
   AADD(aCposMostra,"EIJ_FUNREG")//AWR 17/09/2008
   AADD(aCposMostra,"EIJ_MOTADI")//AWR 17/09/2008
   AADD(aCposMostra,"EIJ_TACOII")
   AADD(aCposMostra,"EIJ_ACO_II")//AWR 17/09/2008
   AADD(aCposMostra,"EIJ_ALA_II")
   AADD(aCposMostra,"EIJ_ALR_II")
   AADD(aCposMostra,"EIJ_PR_II" )
   //IPI
   AADD(aCposMostra,"EIJ_REGIPI")
   AADD(aCposMostra,"EIJ_ALAIPI")
   AADD(aCposMostra,"EIJ_ALRIPI")
   AADD(aCposMostra,"EIJ_QTUIPI")
   AADD(aCposMostra,"EIJ_TPAIPI")
//   AADD(aCposMostra,"EIJ_PRIPI" )
   AADD(aCposMostra,"EIJ_ALUIPI")
   AADD(aTB_CposEIJ,{{|| DI500DescRegTri(Work_EIJ->EIJ_REGTRI)},,AVSX3('EIJ_REGTRI',5)})
   nPos:=2
ELSE
  AADD(aTB_CposEIJ,{{|| Transform(Work_EIJ->EIJ_TEC,AVSX3('EIJ_TEC',6)) },,"NCM"})   //TRP-19/12/07- NCM
  AADD(aCposMostra,"EIJ_MOTAVM")
  AADD(aCposMostra,"EIJ_EIL")
  AADD(aCposMostra,"EIJ_EIL_VM")
  AADD(aCposMostra,"EIJ_TEC_CL")
  AADD(aCposMostra,"EIJ_REGTRI")
  AADD(aCposMostra,"EIJ_FUNREG")
//AADD(aCposMostra,"EIJ_UM_EST")
  AADD(aCposMostra,"EIJ_QT_EST")
  AADD(aCposMostra,"EIJ_MOTADI")
  AADD(aCposMostra,"EIJ_REGIPI")
  AADD(aCposMostra,"EIJ_ALI_II")
  AADD(aCposMostra,"EIJ_ALAIPI")
  AADD(aCposMostra,"EIJ_MERCOS")
  AADD(aCposMostra,"EIJ_MATUSA")
ENDIF
IF lAUTPCDI  // Bete - DSI - Inclusao dos novos campos ref. a PIS/COFINS
   AADD(aCposMostra,"EIJ_REG_PC")
   AADD(aCposMostra,"EIJ_FUN_PC")
   AADD(aCposMostra,"EIJ_FRB_PC")
   AADD(aCposMostra,"EIJ_PRB_PC")
   AADD(aCposMostra,"EIJ_TPAPIS")
   AADD(aCposMostra,"EIJ_ALAPIS")
   AADD(aCposMostra,"EIJ_REDPIS")
   AADD(aCposMostra,"EIJ_QTUPIS")
   AADD(aCposMostra,"EIJ_ALUPIS")
   AADD(aCposMostra,"EIJ_TPACOF")
   AADD(aCposMostra,"EIJ_ALACOF")
   AADD(aCposMostra,"EIJ_REDCOF")
   AADD(aCposMostra,"EIJ_QTUCOF")
   AADD(aCposMostra,"EIJ_ALUCOF")
   If lCposCofMj                                //NCF - 20/07/2012 - Majoração COFINS
      AADD(aCposMostra,"EIJ_ALCOFM")
   EndIf
   If lCposPisMj                                //GFP - 11/06/2013 - Majoração PIS
      AADD(aCposMostra,"EIJ_ALPISM")
   EndIf
ENDIF

AADD(aCposMostra,"EIJ_ASSIPI")
AADD(aCposMostra,"EIJ_EX_IPI")
AADD(aCposMostra,"EIJ_ATOIPI")
AADD(aCposMostra,"EIJ_ORGIPI")
AADD(aCposMostra,"EIJ_NROIPI")
AADD(aCposMostra,"EIJ_ANOIPI")
IF lQbgOperaca//AWR - 18/09/2008 - NFE
   AADD(aCposMostra,"EIJ_OPERAC")
ENDIF
//SVG - 29/07/2009 -
IF EIJ->(FIELDPOS("EIJ_CALIPI")) <> 0
   AADD(aCposMostra,"EIJ_CALIPI")
ENDIF

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDPIS")) <> 0
   AADD(aCposMostra,"EIJ_ARDPIS")
ENDIF

//TRP - 22/02/2010
IF EIJ->(FIELDPOS("EIJ_ARDCOF")) <> 0
   AADD(aCposMostra,"EIJ_ARDCOF")
ENDIF
//TRP - 22/07/2010 - Campo para Admissão Temporária
IF EIJ->(FIELDPOS("EIJ_ALPROP")) <> 0
   AADD(aCposMostra,"EIJ_ALPROP")
ENDIF
//SVG - 16/07/2010 - Inclusão de tratamento para apresentação de campo de Usuario.
aOrd := SaveOrd("SX3",1)
SX3->(dbSeek("EIJ"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EIJ"
   If SX3->X3_PROPRI=="U" .AND. Ascan(aCposMostra,AllTrim(SX3->X3_CAMPO))==0 .AND. X3Uso(SX3->X3_USADO)
      aAdd(aCposMostra,SX3->X3_CAMPO)
   EndIF
   //LGS-05/10/2015 - Inclusão do tratamento para apresentar os campos do AntiDumping
   If lAntDumpBaseICMS .And. AllTrim(SX3->X3_FOLDER) == "5"
      AAdd(aCposMostra, SX3->X3_CAMPO)
   EndIf

   SX3->(dbSkip())
Enddo
RestOrd(aOrd)


FOR TB := nPos TO LEN(aCposMostra)
    AADD(aTB_CposEIJ,ColBrw(aCposMostra[TB],"Work_EIJ"))
NEXT

aTelaInv:=ACLONE(aTela)
aGetsInv:=ACLONE(aGets)

IF nPos_aRotina # VISUAL
   AADD(aBotaoDSI,{"BMPINCLUIR",{|| DI500DSIManut(1)},STR0189,STR0189}) //STR0189 "Incluir"
   AADD(aBotaoDSI,{"EDIT"      ,{|| DI500DSIManut(2)},STR0190,STR0190}) // STR0190 "Alterar"
   AADD(aBotaoDSI,{"EXCLUIR"   ,{|| DI500DSIManut(3)},STR0191,STR0191}) // STR0191 "Excluir"
   IF !lRegTri
      AADD(aBotaoDSI,{"RECALC"    ,{|| Processa( {|| DI500CalcDSI("Work_EIJ",.T.) } , STR0192) },STR0193,STR0194}) //STR0192 "Calculando Impostos" //STR0193 "Calcula Impostos"  // STR0194 "Calc.Imp"
   ENDIF
ELSE
   AADD(aBotaoDSI,{'PESQUISA',{|| DI500DSIManut(4)},STR0195,STR0196}) //STR0195 "Visualizacao"   //STR0196 "Visuali"
   nTipo:=4
ENDIF
IF !lRegTri
   cTitulo:=STR0197 //STR0197 "Manutencao de Impostos DSI"
   AADD(aBotaoDSI,{"SIMULACAO",{|| DI500DSITot(.T.)},STR0199,STR0198 }) // STR0198 "Total.Imp" //STR0199 "Totais dos Impostos"
ELSE
   cTitulo:=STR0200 //STR0200 "Manutencao de Aliquotas"
ENDIF
AADD(aBotaoDSI,{"PREV"     ,{|| oDlgEIJ:End()},STR0201,STR0202}) // STR0201 "Tela Anterior"-  //STR0202 "Anterior"

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_TELA_DSI"),)

DO WHILE .T.

   aGets:={}
   aTela:={}
   Work_EIJ->(DBGOTOP())

   DEFINE MSDIALOG oDlgEIJ TITLE cTitulo;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   //by GFP - 05/10/2010 - 15:05 - Inclusão da função para carregar campos criados pelo usuario.
   aTB_CposEIJ := AddCpoUser(aTB_CposEIJ,"EIJ","2")

   oMarkEIJ:=MSSELECT():New("WORK_EIJ",,,aTB_CposEIJ,lInverte,cMarca,{15,1,(oDlgEIJ:nClientHeight-6)/2,(oDlgEIJ:nClientWidth-4)/2})
   oMarkEIJ:bAval:={|| DI500DSIManut(nTipo)}
   oMarkEIJ:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   oMarkEIJ:oBrowse:Refresh()   //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   oDlgEIJ:lMaximized:=.T. //LRL 26/03/04 - Maximiliza Janelas
   ACTIVATE MSDIALOG oDlgEIJ ON INIT (EnchoiceBar(oDlgEIJ,{|| oDlgEIJ:End()},{|| oDlgEIJ:End()},.F.,aBotaoDSI)) //LRL 26/03/04 -Alinhamento MDi //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   EXIT
ENDDO
DBSELECTAREA("Work_SW8")
SET FILTER TO

aTela:=ACLONE(aTelaInv)
aGets:=ACLONE(aGetsInv)
Work->(DBGOTOP())

IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

RETURN .T.
*--------------------------------------------------*
FUNCTION DI500CarrSWP()
*--------------------------------------------------*
LOCAL cAdicao
//IF SWP->(FieldPos("WP_NAT_LSI")) # 0
   Work_SW8->(DBGOTOP())
   DO WHILE WORK_SW8->(!EOF())
      cAdicao:=IF(lExisteSEQ_ADI .AND. lRegTri,Work_SW8->WKGRUPORT,Work_SW8->WKADICAO)//AWR - 18/09/08 NFE
      IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE) .OR. !EMPTY(cAdicao) .OR. Work_SW8->WKFLAG_LSI
         Work_SW8->(DBSKIP())
         LOOP
      ENDIF
      IF SWP->(DBSEEK(xFilial()+Work_SW8->WKPGI_NUM+Work_SW8->WKSEQ_LI))
         IF !EMPTY(SWP->WP_NAT_LSI)
            nAdicao:=STRZERO(DI500GerNrAdicao(),3,0)// Tem que atribuir p/ uma variavel antes do append p/ nao dar FILE IS IN EOF
            Work_EIJ->(DBAPPEND())// Novo Registro Work_EIJ
            Work_EIJ->EIJ_ADICAO := nAdicao
            Work_EIJ->EIJ_REGTRI := SWP->WP_REG_TRI
            Work_EIJ->EIJ_FUNREG := SWP->WP_FUN_REG
            Work_EIJ->EIJ_MATUSA := SWP->WP_MATUSA
            Work_EIJ->EIJ_MERCOS := SWP->WP_MERCOS
            Work_EIJ->EIJ_MOTADI := SWP->WP_MOTIVO
            Work_EIJ->EIJ_PAISPR := SWP->WP_PAIS_PR
            Work_EIJ->EIJ_QT_EST := SWP->WP_QT_EST
            Work_EIJ->EIJ_TEC_CL := SWP->WP_TEC_CL
            Work_EIJ->EIJ_TEC    := SWP->WP_NCM
            Work_SW8->WKFLAGDSI  := cMarca
            Work_SW8->WKADICAO   := Work_EIJ->EIJ_ADICAO
            Work_SW8->WKREGTRI   := Work_EIJ->EIJ_REGTRI
            Work_SW8->WKFUNREG   := Work_EIJ->EIJ_FUNREG
            Work_SW8->WKMOTADI   := Work_EIJ->EIJ_MOTADI
            Work_SW8->WKFLAG_LSI := .T.
         ENDIF
      ENDIF
      Work_SW8->(DBSKIP())
   ENDDO
//ENDIF
RETURN .T.

*--------------------------------------------------*
FUNCTION DI500DSIManut(nLTipo)
*--------------------------------------------------*
LOCAL oDlgDSIManut,cTituto:='',nInd,nOpcao:=0,/*oEnchItens,*/nPesoTot := 0,nQtdeTot := 0
LOCAL cNomeQtde:=AVSX3("W7_QTDE",5) ,cPictQtde:=AVSX3("W7_QTDE",6)
LOCAL cPictPrec:=AVSX3("W7_PRECO",6),cPictFob :=AVSX3("W6_FOB_TOT",6)
LOCAL nRec:=Work_EIJ->WK_RECNO,lTemItemParaDSI:=.F.
LOCAL aValida:={},TB
LOCAL bValid:={|| IF(lRegTri,DI500ValTudo(aDarGetsEIJ,{|C| DI_Val_EIJ(C,.T.)},.F.) , DI500DSIValid(,.T.)) }
//LOCAL aOk:={{||IF(EVAL(bValid),(nOpcao:=1,oDlgDSIManut:End()),)},"OK"} - FDR - 12/08/11
LOCAL bOk:={||IF(EVAL(bValid),(nOpcao:=1,oDlgDSIManut:End()),)}
LOCAL bCancel:={||nOpcao:=0,oDlgDSIManut:End()},nPos
LOCAL aPictures:={AVSX3("W9_INLAND" ,6),AVSX3("W9_PACKING",6),AVSX3("W9_DESCONT",6),;
                  AVSX3("W9_FRETEIN",6),AVSX3("W9_OUTDESP",6),AVSX3("W8_VLFREMN",6),;
                  AVSX3("W8_VLSEGMN",6),AVSX3("W8_VLII"   ,6),AVSX3("W8_VLIPI"  ,6),;
                  AVSX3("W8_VLACRES",6),AVSX3("W8_VLDEDU" ,6),AVSX3("W8_VLICMS" ,6),;
                  AVSX3("W7_QTDE"   ,6),AVSX3("W7_PESO"   ,6),AVSX3("W7_PRECO"  ,6),;
                  AVSX3("W6_FOB_TOT",6)}
Local cFiltroWk:= ""
//#DEFINE FILTRO_DO_WORK_SW8 (EMPTY(Work_SW8->WKADICAO) .OR. Work_SW8->WKADICAO==M->EIJ_ADICAO) .AND. !EMPTY(Work_SW8->WKINVOICE)
#DEFINE FILTRO_DO_WORK_SW8 '(Work_SW8->WKADICAO == "' + Space(AvSx3("W8_ADICAO", AV_TAMANHO)) + '" .OR. Work_SW8->WKADICAO==M->EIJ_ADICAO)' +;
                           ' .AND. Work_SW8->WKINVOICE <> "' + Space(AvSx3("W8_INVOICE", AV_TAMANHO)) + '"'

//#DEFINE RT_FILTRO_DO_WORK_SW8 (EMPTY(Work_SW8->WKGRUPORT) .OR. Work_SW8->WKGRUPORT==M->EIJ_ADICAO) .AND. !EMPTY(Work_SW8->WKINVOICE)//AWR - 18/09/08 NFE
#DEFINE RT_FILTRO_DO_WORK_SW8 '(Work_SW8->WKGRUPORT == "' + Space(AvSx3("W8_GRUPORT", AV_TAMANHO)) + '" .OR. Work_SW8->WKGRUPORT==M->EIJ_ADICAO) .AND. '+;
                              'Work_SW8->WKINVOICE <> "' + Space(AvSx3("W8_INVOICE", AV_TAMANHO)) + '"'
PRIVATE aCamposSW8:={},nPos_DSIaRotina,aBotaoDSI:={}
PRIVATE aDarGetsEIJ:={},nTipo:=nLTipo
PRIVATE aOPREG:={"NCM+EX",STR0203,"PLI",STR0204,"Invoice",STR0205,STR0206}  // TRP - 23/02/2010 - Adicionada a "EX" ao filtro da NCM nos casos sem DI Eetronica //STR0203 "Pedido" //STR0204 "Moeda" //STR0205 "Atual" //STR0206 "Todos"
PRIVATE cOPREG,aEscolha:={},lWhenReg:=.T.,cEscolha:="NCM",oEscolha
PRIVATE lAtuAnDupi:= .T., oEnchItens //LGS-07/10/2015 - Controlar atualização do campo "EIJ_BAD_AD"
FOR TB := 1 TO LEN(aCposMostra)
    AADD(aDarGetsEIJ,aCposMostra[TB])
NEXT

IF nTipo # 3
   IF lAltDescricao .AND. !lRegTri
      AADD(aBotaoDSI,{'EDIT',{|| DI500GetDesc()},STR0207,STR0208}) //STR0207	"Alterar Descricao do Item" // STR0208  -  "Alt.Desc"
   ENDIF
   AADD(aBotaoDSI,{"RESPONSA",{|| DI500DSIPesq(oMarkItens:oBrowse) },STR0209,STR0210}) // STR0209 "Marca/Desmarca Todos"- //STR0210 "Marc/Des"
   IF !lRegTri
      AADD(aBotaoDSI,{"COLGERA" ,{|| IF(EVAL(bValid),Processa({|| DI500CalcDSI("M",.F.) }),) } ,STR0193,STR0194}) // STR0193 "Calcula Impostos"- STR0194 "Calc.Imp"
   ENDIF
ENDIF

DO CASE

CASE nTipo = 1
     cTituto:=STR0211 // STR0211 "Inclusão"
     nPos_DSIaRotina:=INCLUSAO
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd))  := CRIAVAR(FIELDNAME(nInd))
     NEXT
     IF !lRegTri
        M->EIJ_REGTRI:=LEFT(cFiltroSJP,1)
     ENDIF
     M->EIJ_ADICAO:=STRZERO(DI500GerNrAdicao(),3,0)
     //RNLP -OSSME-6017     
     IF(M->W6_TIPODES # '19', M->EIJ_TPAII:='1' /*Ad Valorem*/, )

     Work_EIJ->(DBGOTOP())

     Work_SW8->(DBGOTOP())
     DO WHILE Work_SW8->(!EOF())

        IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
           Work_SW8->(DBSKIP())
           LOOP
        ENDIF
        IF EMPTY(IF(lExisteSEQ_ADI .AND. lRegTri,Work_SW8->WKGRUPORT,Work_SW8->WKADICAO))
           lTemItemParaDSI:=.T.
        ENDIF

        Work_SW8->(DBSKIP())

     ENDDO
     Work_SW8->(DBGOTOP())

     IF !lTemItemParaDSI
        Help(" ",1,"AVG0005355")  // LRL 08/01/04 MSGSTOP("Processo nao possui mais itens para inclusao.")
        oMarkEIJ:oBrowse:Refresh()
        RETURN .F.
     ENDIF

CASE nTipo = 2
     cTituto:=STR0212 //STR0212	"Alteração"
     nPos_DSIaRotina:=ALTERACAO
     DBSELECTAREA("WORK_EIJ")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT
     IF lAUTPCDI  // Bete - DSI - Na alt., dependendo do tipo de aliq, seta var p/ habilitar ou desabilitar cpos
     	IF M->EIJ_TPAPIS = "2"
     		lWhenAutPis := .T.
     	ENDIF
     	IF M->EIJ_TPACOF = "2"
     		lWhenAutCof := .T.
     	ENDIF
     ENDIF

     //LGS-13/10/2015 - Verifica se o valor informado na base é o calculado ou foi digitado manual
     IF lAntDumpBaseICMS .And. M->EIJ_BAD_AD > 0
        Work_SW8->(DBGOTOP())
        nSomaSW8 := 0
        DO WHILE Work_SW8->(!EOF()) .And. !EMPTY(Work_SW8->WKFLAGDSI)
           nSomaSW8 := (Work_SW8->WKPRTOTMOE + Work_SW8->WKFRETEIN + If(lSegInc, Work_SW8->WKSEGURO, 0) )
           Work_SW8->(DBSKIP())
        ENDDO
        IF M->EIJ_BAD_AD <> nSomaSW8
           lAtuAnDupi := .F.
        ENDIF
        Work_SW8->(DBGOTOP())
     ENDIF

CASE nTipo = 3
     //aOk:={{||IF(MSGYESNO(STR0214,STR0215),(nOpcao:=1,oDlgDSIManut:End()),)},"OK"} //STR0214	"Confirma a Exclusao ?"  //STR0215	"Atenção"
     bOk:={||IF(MSGYESNO(STR0214,STR0215),(nOpcao:=1,oDlgDSIManut:End()),)}
     cTituto:=STR0213 // STR0213 "Exclusao"
     aDarGetsSIJ:={}
     nPos_DSIaRotina:=ALTERACAO
     DBSELECTAREA("WORK_EIJ")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT

CASE nTipo = 4
     cTituto:=STR0216 // STR0216 "Visualizacao"
     
     bOk:={||nOpcao:=0,oDlgDSIManut:End(),}
     aBotaoDSI:={}
     nPos_DSIaRotina:=VISUAL
     EIJ->(DBGOTO(nRec))
     DBSELECTAREA("WORK_EIJ")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     DBSELECTAREA("EIJ")
     FOR nInd := 1 TO FCount()
         IF (nPos:=WORK_EIJ->( FieldPos(EIJ->(FieldName(nInd))) )) # 0
            M->&(FIELDNAME(nInd)) := WORK_EIJ->(FieldGet(nPos))
         ENDIF
     NEXT
ENDCASE

IF !lRegTri
   cFiltroSY8:=""
   cFiltroSJR:=""
   cFiltroRPC:=""
   cFiltroEIV:=""
   cClassif  :=""
   DI500DSIRegra(M->W6_TIPODES,M->EIJ_REGTRI,M->EIJ_FUNREG,M->EIJ_MOTADI)
   IF nTipo = 1 .OR. nTipo = 2
      AADD(aBotaoDSI,{"COMPTITL"  ,{|| IF(EVAL(bValid),DI500DSITot(),) },STR0217,STR0218 })//STR0217 "Valores do Item" //STR0218 "Valores"
   ELSE
      AADD(aBotaoDSI,{"COMPTITL"  ,{|| DI500DSITot() },STR0217,STR0218 })//STR0217 "Valores do Item" //STR0218 "Valores"
   ENDIF
ENDIF

IF nTipo # 3 .AND. nTipo # 4
   AADD(aCamposSW8,{"WKFLAGDSI",,""})
ENDIF
AADD(aCamposSW8,{"WKINVOICE" ,,AVSX3('W9_INVOICE',5)})
AADD(aCamposSW8,{"WKTEC"     ,,AVSX3("W3_TEC"    ,5),AVSX3("W3_TEC"  ,6)})

//RMD - 25/09/14 - Incluídos os campos para facilitar a conferência.
AADD(aCamposSW8,{"WKEX_NCM"  ,,AVSX3("W3_EX_NCM"  ,5),AVSX3("W3_EX_NCM",6)})
AADD(aCamposSW8,{"WKEX_NBM"  ,,AVSX3("W3_EX_NBM"  ,5),AVSX3("W3_EX_NBM",6)})

AADD(aCamposSW8,{"WKPGI_NUM" ,,AVSX3('W8_PGI_NUM',5)})
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3('W8_PO_NUM' ,5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3('W8_COD_I'  ,5)})
AADD(aCamposSW8,{"WKDESCITEM" ,,AVSX3('B1_DESC'  ,5)})
AADD(aCamposSW8,{"WKFABR"    ,,AVSX3('W8_FABR'   ,5)})
If EICLoja()
   AADD(aCamposSW8,{"W8_FABLOJ"    ,,AVSX3('W8_FABLOJ'   ,5)})
EndIf
AADD(aCamposSW8,{"WKMOEDA"   ,,AVSX3("W2_MOEDA"  ,5)})
AADD(aCamposSW8,{"WKPRECO"   ,,AVSX3("W8_PRECO"  ,5),aPictures[15]})
AADD(aCamposSW8,{"WKQTDE"    ,,AVSX3("W8_QTDE"   ,5),aPictures[13]})
AADD(aCamposSW8,{"WKPRTOTMOE",,AVSX3("W9_FOB_TOT",5),aPictures[16]})
AADD(aCamposSW8,{"WKINLAND"  ,,AVSX3("W8_INLAND" ,5),aPictures[01]})
AADD(aCamposSW8,{"WKPACKING" ,,AVSX3("W8_PACKING",5),aPictures[02]})
AADD(aCamposSW8,{"WKOUTDESP" ,,AVSX3("W8_OUTDESP",5),aPictures[02]})
AADD(aCamposSW8,{"WKDESCONT" ,,AVSX3("W8_DESCONT",5),aPictures[03]})
IF !lRegTri
   AADD(aCamposSW8,{"WKVLMLE",,AVSX3("W8_VLMLE"  ,5),aPictures[16]})
ENDIF
AADD(aCamposSW8,{"WKFOBTOTR" ,,AVSX3("W8_FOBTOTR",5),aPictures[16]})
AADD(aCamposSW8,{"WKFRETEIN" ,,AVSX3('W8_FRETEIN',5),aPictures[04]})
IF lSegInc //LGS-13/10/2015 - W8_SEGURO esta criado
   AADD(aCamposSW8,{"WKSEGURO" ,,AVSX3("W8_SEGURO",5),aPictures[04]})
ENDIF
AADD(aCamposSW8,{"WKPESO_L"  ,,AVSX3("W7_PESO"   ,5),aPictures[14]})
AADD(aCamposSW8,{"WKPESOTOT" ,,STR0219              ,aPictures[14]}) // STR0219 "Peso Total"
IF !lRegTri
   AADD(aCamposSW8,{"WKVLFREMN" ,,AVSX3("W8_VLFREMN",5),aPictures[06]})
   AADD(aCamposSW8,{"WKVLSEGMN" ,,AVSX3("W8_VLSEGMN",5),aPictures[07]})
   AADD(aCamposSW8,{"WKBASEII"  ,,AVSX3("W8_BASEII" ,5),aPictures[08]})
   AADD(aCamposSW8,{"WKVLDEVII" ,,AVSX3("EIJ_DEVII" ,5)+" II",aPictures[08]})
   AADD(aCamposSW8,{"WKVLII"    ,,AVSX3("W8_VLII"   ,5),aPictures[08]})
   AADD(aCamposSW8,{"WKVLDEIPI" ,,AVSX3("EIJ_VLDIPI",5)+" IPI",aPictures[08]})
   AADD(aCamposSW8,{"WKVLIPI"   ,,AVSX3("W8_VLIPI"  ,5),aPictures[09]})
   IF lMV_PIS_EIC
      IF lAUTPCDI // Bete - DSI - Apresenta no browse dos itens, os novos cpos ref. a PIS/COFINS
         AADD(aCamposSW8,{"WKREG_PC",,AVSX3("W8_REG_PC",5),AVSX3("W8_REG_PC",6)})
         AADD(aCamposSW8,{"WKFUN_PC",,AVSX3("W8_FUN_PC",5),AVSX3("W8_FUN_PC",6)})
         AADD(aCamposSW8,{"WKFRB_PC",,AVSX3("W8_FRB_PC",5),AVSX3("W8_FRB_PC",6)})
      ENDIF
      AADD(aCamposSW8,{"WKBASPIS",,AVSX3("W8_BASPIS",5),AVSX3("W8_BASPIS",6)})
      AADD(aCamposSW8,{"WKPERPIS",,AVSX3("W8_PERPIS",5),AVSX3("W8_PERPIS",6)})
      AADD(aCamposSW8,{"WKVLUPIS",,AVSX3("W8_VLUPIS",5),AVSX3("W8_VLUPIS",6)})
      AADD(aCamposSW8,{"WKVLRPIS",,AVSX3("W8_VLRPIS",5),AVSX3("W8_VLRPIS",6)})
      AADD(aCamposSW8,{"WKBASCOF",,AVSX3("W8_BASCOF",5),AVSX3("W8_BASCOF",6)})
      AADD(aCamposSW8,{"WKPERCOF",,AVSX3("W8_PERCOF",5),AVSX3("W8_PERCOF",6)})
      AADD(aCamposSW8,{"WKVLUCOF",,AVSX3("W8_VLUCOF",5),AVSX3("W8_VLUCOF",6)})
      AADD(aCamposSW8,{"WKVLRCOF",,AVSX3("W8_VLRCOF",5),AVSX3("W8_VLRCOF",6)})
   ENDIF
   AADD(aCamposSW8,{"WKBASEICM" ,,AVSX3("W8_BASEICM",5),AVSX3("W8_BASEICM",6)})
   AADD(aCamposSW8,{"WKVLICMS"  ,,AVSX3("W8_VLICMS" ,5),aPictures[12]})
ENDIF
AADD(aCamposSW8,{"WKINCOTER" ,,AVSX3("W9_INCOTER",5)})
AADD(aCamposSW8,{"WKREGTRI"  ,,"Reg Trib II"})
AADD(aCamposSW8,{"WKFUNREG"  ,,AVSX3("EIJ_FUNREG",5)})
AADD(aCamposSW8,{"WKMOTADI"  ,,AVSX3("EIJ_MOTADI",5)})
AADD(aCamposSW8,{"WKADICAO"  ,,IF(lExisteSEQ_ADI .AND. lRegTri,STR0082 ,STR0042)}) //STR0082 "Adição: " //STR0042 "Codigo"
IF lExisteSEQ_ADI//AWR - 18/09/08 NFE
   AADD(aCamposSW8,{"WKSEQ_ADI",,AVSX3("W8_SEQ_ADI",5)})
   AADD(aCamposSW8,{"WKGRUPORT",,AVSX3("W8_GRUPORT",5)})
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"BROWSE_WORK_DSI"),)

aSaveTela:=ACLONE(aTela)
aSaveGets:=ACLONE(aGets)
DO WHILE .T.

   aTela:={}
   aGets:={}
   nOpcao:=0
   IF nTipo == 2 //Alteracao
      nOpcao :=1
      //bCancel:=NIL
   ENDIF
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_DSI"),)

   DEFINE MSDIALOG oDlgDSIManut TITLE cTituto+STR0220+M->EIJ_ADICAO ; //STR0220	 " do Grupo: "
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5;
             TO   oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10
      DBSELECTAREA("Work_SW8")
      Work_SW8->(DBSETORDER(1))
      IF nTipo = 3 .OR. nTipo = 4 // Exclusao ou Visualizacao
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            SET FILTER TO Work_SW8->WKGRUPORT==M->EIJ_ADICAO
         ELSE
            SET FILTER TO Work_SW8->WKADICAO==M->EIJ_ADICAO
         ENDIF
      ELSE
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            //SET FILTER TO RT_FILTRO_DO_WORK_SW8 nopado por WFS em 11/06/10
            cFiltroWk:= RT_FILTRO_DO_WORK_SW8
            Work_SW8->(DBSetFilter({|| &cFiltroWk}, cFiltroWk))
         ELSE
            //SET FILTER TO FILTRO_DO_WORK_SW8 nopado por WFS em 11/06/10
            cFiltroWk:= FILTRO_DO_WORK_SW8
            Work_SW8->(DBSetFilter({|| &cFiltroWk}, cFiltroWk))
         ENDIF
      ENDIF
      DBGOTOP()

      //GFP 21/10/2010
      aCamposSW8 := AddCpoUser(aCamposSW8,"SW8","2")

      oMarkItens:=MSSELECT():New('Work_SW8',IF(nTipo#3,'WKFLAGDSI',),,aCamposSW8,lInverte,cMarca,{nMeio,1,(oDlgDSIManut:nClientHeight-6)/2,(oDlgDSIManut:nClientWidth-4)/2})
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_SW8'),DBSETORDER(1),oMarkItens:oBrowse,.T.}
      IF nTipo # 3 .AND. nTipo # 4 //.AND. !lTemCambio - NCF - 05/05/2010 - Nopado por não permitir a gravação do regime de tributação em invoices de processo que possui cambio
         oMarkItens:bAval:={|| DI500MarkDSI(IF(EMPTY(Work_SW8->WKFLAGDSI),"M","D"),,oMarkItens:oBrowse:Refresh(),,,lRegTri), oEnchItens:Refresh() } //LGS-08/10/2015 - Força atualizar a tela sempre que um item é marcado
      ELSE
         oMarkItens:bAval:={|| .T. }
      ENDIF
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"SELECT_DSI"),)

      oEnchItens:=MsMGET():New("EIJ",nRec,nPos_DSIaRotina,,,,aCposMostra,{15,1,nMeio,(oDlgDSIManut:nClientWidth-4)/2 },aDarGetsEIJ,3,,,,,,,,,)//.T.)//19o. parametro com .T.: Desabilita as Pastas
      oDlgDSIManut:lMaximized:=.T.
	  oEnchItens:oBox:Align:=CONTROL_ALIGN_TOP
      oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
	  oMarkItens:oBrowse:Refresh() //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlgDSIManut ON INIT (EnchoiceBar(oDlgDSIManut,{||IF(Obrigatorio(aGets,aTela),Eval(bOK),)},bCancel,,aBotaoDSI)) //Alinhamento MdI//LRL 26/03/04//FDR - 12/08/11 /*DI500EnchoiceBar(oDlgDSIManut,aOk,bCancel,.F.,aBotaoDSI)*/,; //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


   IF nOpcao == 1

      lGravaSoCapa:=.F.
      lGravaEIJ:=.T.

      IF nTipo = 1  //Inclui
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            Work_SW8->(DBSETORDER(7))
         ELSE
            Work_SW8->(DBSETORDER(4))
         ENDIF
         IF !Work_SW8->(DBSEEK(M->EIJ_ADICAO))
            Help(" ",1,"AVG0005356")   // LRL 08/01/04 MSGSTOP("Nao existe itens Marcados.")
            LOOP
         ENDIF
         //SVG - 29/07/09
         If EIJ->(FieldPos("EIJ_CALIPI")) > 0 .And. M->EIJ_CALIPI == "2"
            Work_SW8->(DBSEEK(M->EIJ_ADICAO))
            DO WHILE Work_SW8->WKGRUPORT == M->EIJ_ADICAO
               nPesoTot += Work_SW8->WKPESOTOT
               Work_SW8->(DBSKIP())
            ENDDO
            M->EIJ_QTUIPI := nPesoTot
         EndIf
         //NCF - 28/02/2011 - Guardar neste campo a somatória da quantidade das adições no Regime de Tributação para rateio
         //                   do Valor de IPI de Pauta informado na capa do regime de tributação para as adições que o compõem
         IF !EasyGParam("MV_TEM_DI",,.F.)
            Work_SW8->(DBSEEK(M->EIJ_ADICAO))
            DO WHILE Work_SW8->WKGRUPORT == M->EIJ_ADICAO
               nQtdeTot += Work_SW8->WKQTDE
               Work_SW8->(DBSKIP())
            ENDDO
            M->EIJ_QT_EST := nQtdeTot
         ENDIF
         Work_EIJ->(DBAPPEND())
         AVReplace("M","Work_EIJ")
         Work_EIJ->WK_RECNO:=0

      ELSEIF nTipo = 2//Altera
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            Work_SW8->(DBSETORDER(7))
         ELSE
            Work_SW8->(DBSETORDER(4))
         ENDIF
          //SVG - 29/07/09
         If EIJ->(FieldPos("EIJ_CALIPI")) > 0 .And. M->EIJ_CALIPI == "2"
            Work_SW8->(DBSEEK(M->EIJ_ADICAO))
            DO WHILE Work_SW8->WKGRUPORT == M->EIJ_ADICAO
               nPesoTot += Work_SW8->WKPESOTOT
               Work_SW8->(DBSKIP())
            ENDDO
            M->EIJ_QTUIPI := nPesoTot
         EndIf
         AVReplace("M","Work_EIJ")

         //ACB - 26/05/2010 Ponto de entrada que seja possivel a alteração da aliquota do Pis/Cofins especificos
         If EasyEntryPoint("EICDI505")
            ExecBlock("EICDI505",.f.,.f.,"ALT_PIS_COF_ESPEC")
         End If

      ELSEIF nTipo = 3 //Exclui
         DBSELECTAREA("Work_SW8")
         SET FILTER TO
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            Work_SW8->(DBSETORDER(7))
         ELSE
         Work_SW8->(DBSETORDER(4))
         ENDIF
         DO WHILE Work_SW8->(DBSEEK(Work_EIJ->EIJ_ADICAO))
            DI500MarkDSI("D",,,,.F.,lRegTri)
            Work_SW8->(DBSKIP())
         ENDDO
         IF !EMPTY(Work_EIJ->WK_RECNO)
            AADD(aDeletados,{"EIJ",Work_EIJ->WK_RECNO})
         ENDIF
         Work_EIJ->(DBDELETE())
         Work_EIJ->(DBGOTOP())
      ENDIF

      IF nTipo = 1 .OR. nTipo = 2 //Inclui ou Altera
         IF lQbgOperaca//AWR - 18/09/2008 - NFE
            nOrderWK:=Work->(INDEXORD())
            nRecnoWK:=Work->(RECNO())
            Work->(DBSETORDER(3))
         ENDIF
         IF lExisteSEQ_ADI .AND. lRegTri//AWR - 18/09/08 NFE
            Work_SW8->(DBSETORDER(7))
         ELSE
         Work_SW8->(DBSETORDER(4))
         ENDIF
         Work_SW8->(DBSEEK(Work_EIJ->EIJ_ADICAO))
         DO WHILE Work_SW8->(!EOF()) .AND. Work_EIJ->EIJ_ADICAO == IF(lExisteSEQ_ADI .AND. lRegTri,Work_SW8->WKGRUPORT,Work_SW8->WKADICAO)//AWR - 18/09/08 NFE
            Work_SW8->WKREGTRI:=M->EIJ_REGTRI
            Work_SW8->WKFUNREG:=M->EIJ_FUNREG
            Work_SW8->WKMOTADI:=M->EIJ_MOTADI
            Work_SW8->WKTACOII:=M->EIJ_TACOII
            Work_SW8->WKACO_II:=M->EIJ_ACO_II
            IF lREGIPIW8
               Work_SW8->WKREGIPI:=M->EIJ_REGIPI  //TRP 23/11/2007 - Verifica se o campo W8_REGIPI existe na base.
            ENDIF
            IF lAUTPCDI // Bete - DSI - alimenta os itens selecionados com os dados informados de PIS/COFINS
	           Work_SW8->WKREG_PC:=M->EIJ_REG_PC
    	       Work_SW8->WKFUN_PC:=M->EIJ_FUN_PC
        	   Work_SW8->WKFRB_PC:=M->EIJ_FRB_PC
        	ENDIF
            IF lQbgOperaca//AWR - 18/09/2008 - NFE
               Work_SW8->WKOPERACA:=M->EIJ_OPERAC
               IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
                  Work->WKOPERACA:=M->EIJ_OPERAC
               ENDIF
             ENDIF
            Work_SW8->(DBSKIP())
         ENDDO
         IF lQbgOperaca//AWR - 18/09/2008 - NFE
            Work->(DBSETORDER(nOrderWK))
            Work->(DBGOTO(nRecnoWK))
         ENDIF
      ENDIF

      IF !lRegTri
         IF nTipo = 2 .OR.  nTipo = 1//Altera ou Inclusao
            Processa( {|| DI500CalcDSI("Work_EIJ",.T.) } , STR0186) //STR0186 "Calculando Impostos"
         ENDIF
      ENDIF

      //** AAF 29/04/05
      If lIntDraw .AND. EasyGParam("MV_DRAWCOM",,.F.)
         AtoComplemDi() //Adiciona ao campo complemento da DI os dados das adicoes com Drawback.
      Endif
      //**

   ELSE

      IF nTipo = 1  //Inclui

         DBSELECTAREA("Work_SW8")
         SET FILTER TO

         IF lExisteSEQ_ADI .AND. lRegTri    // - NCF-28/09/2009
            Work_SW8->(DBSETORDER(7))
         ELSE
            Work_SW8->(DBSETORDER(4))
         ENDIF

         DO WHILE Work_SW8->(DBSEEK(M->EIJ_ADICAO))
            DI500MarkDSI("D",,,,.F.,lRegTri)
            Work_SW8->(DBSKIP())
         ENDDO
         IF !lRegTri
            Work_EIL->(DBSETORDER(1))
            DO WHILE Work_EIL->(DBSEEK(M->EIJ_ADICAO))
               IF !EMPTY(Work_EIL->WK_RECNO)
                  AADD(aDeletados,{"EIL",Work_EIL->WK_RECNO})
               ENDIF
               Work_EIL->(DBDELETE())
            ENDDO
         ENDIF

      ENDIF

   ENDIF

   EXIT

ENDDO

DBSELECTAREA("Work_SW8")
Work_SW8->(DBSETORDER(1))
SET FILTER TO
DBSELECTAREA("Work_EIJ")

oMarkEIJ:oBrowse:Refresh()

aTela:=ACLONE(aSaveTela)
aGets:=ACLONE(aSaveGets)

RETURN .T.
*------------------------------------------------------*
FUNCTION DI500DSIValid(cLocalCampo,lTudo,lWhen,oCampo)//Chamada da funcao DI_Val_EIJ()
*------------------------------------------------------*
LOCAL nOrder,nRecno
DEFAULT lTudo :=.F.
DEFAULT lWhen :=.F.
lReturn:=.T.
cNomeCampo:=cLocalCampo
IF oCampo # NIL
   cNomeCampo:=oCampo:cReadvar
ENDIF
IF cNomeCampo == NIL
   cNomeCampo:=UPPER(READVAR()) // variavel private da Enchoice
ENDIF
IF Left(cNomeCampo,3) == "M->"
   cNomeCampo:=Subs(cNomeCampo,4)
ENDIF

// 1  DSI - RECOLHIMENTO INTEGRAL
// 2  DSI - IMUNIDADE
// 3  DSI - ISENCAO
// 4      - REDUCAO
// 5  DSI - SUSPENSAO      (Quando eh Admissao Temporaria)
// 6  DSI - NAO INCIDENCIA (Quando eh Reimportacao)
// 7  DSI - TRIBUTACAO SIMPLIFICADA
// 8  DSI - TRIBUTACAO SIMPLIFICADA DE BAGAGEM (Quando eh Bagagem Desacompanhada)
// 9      - RECOM
IF lWhen
  DO CASE
  CASE cNomeCampo == 'W6_TIPODES'
     Work_EIJ->(DBGOTOP())
     IF !(Work_EIJ->(BOF()) .AND. Work_EIJ->(EOF())) .AND. !EMPTY(M->W6_TIPODES)
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_FUNREG'
     IF M->EIJ_REGTRI $ '1'
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_MOTADI'
     IF !(M->EIJ_REGTRI $ '5,6,7') .OR. M->W6_TIPODES = "10"
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALI_II'
     IF (M->EIJ_REGTRI $ '2,6,9') .OR. (M->EIJ_REGTRI = "3" .AND. M->W6_TIPODES = "10")
        M->EIJ_ALI_II:=0
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_ALAIPI'
     IF M->EIJ_REGTRI $ '2,6,9' .OR. M->W6_TIPODES = "10"
        M->EIJ_ALAIPI:=0
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_QT_EST'
     IF M->W6_TIPODES = "10"
        M->EIJ_QT_EST:=0
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_EIL'
     IF M->W6_TIPODES = "10"
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_MATUSA'
     IF M->W6_TIPODES = "10" .AND. M->EIJ_REGTRI $ "2,3"
        M->EIJ_MATUSA:=SPACE(LEN(EIJ->EIJ_MATUSA))
        RETURN .F.
     ENDIF

  CASE cNomeCampo == 'EIJ_MERCOS'
     IF M->W6_TIPODES = "10" .AND. M->EIJ_REGTRI $ "2,3"
        M->EIJ_MERCOS:=SPACE(LEN(EIJ->EIJ_MERCOS))
        RETURN .F.
     ENDIF

  CASE cNomeCampo == "EIJ_FUN_PC"
     IF M->EIJ_REG_PC = "1"
        RETURN .F.
     ENDIF
  CASE cNomeCampo == "EIJ_PRB_PC"
       IF !(M->EIJ_REG_PC $ "4,5")
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_FRB_PC"
       IF !(M->EIJ_REG_PC $ "4,5")
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_REDPIS"
       IF !(M->EIJ_REG_PC $ "4,5")
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_REDCOF"
       IF !(M->EIJ_REG_PC $ "4,5")
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_ALAPIS"
       IF M->EIJ_TPAPIS # "1"
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_ALACOF"
       IF M->EIJ_TPACOF # "1"
          lRet:=.F.
          RETURN .F.
       ENDIF
  CASE cNomeCampo == "EIJ_UNUPIS"
       IF M->EIJ_TPAPIS # "2"
          lWhenAutPis:=.F.
       ELSE
          lWhenAutPis:=.T.
       ENDIF
  CASE cNomeCampo == "EIJ_ALUPIS"
       IF M->EIJ_TPAPIS # "2"
          lWhenAutPis:=.F.
       ELSE
          lWhenAutPis:=.T.
       ENDIF
  CASE cNomeCampo == "EIJ_QTUPIS"
       IF M->EIJ_TPAPIS # "2"
          lWhenAutPis:=.F.
       ELSE
          lWhenAutPis:=.T.
       ENDIF
  CASE cNomeCampo == "EIJ_UNUCOF"
       IF M->EIJ_TPACOF # "2"
          lWhenAutCof:=.F.
       ELSE
          lWhenAutCof:=.T.
       ENDIF
  CASE cNomeCampo == "EIJ_ALUCOF"
       IF M->EIJ_TPACOF # "2"
          lWhenAutCof:=.F.
       ELSE
          lWhenAutCof:=.T.
       ENDIF
  CASE cNomeCampo == "EIJ_QTUCOF"
       IF M->EIJ_TPACOF # "2"
          lWhenAutCof:=.F.
       ELSE
          lWhenAutCof:=.T.
       ENDIF

  ENDCASE

  RETURN .T.

ENDIF

nOrder:=Work_SW8->(INDEXORD())
nRecno:=Work_SW8->(RECNO())

BEGIN SEQUENCE
/* // Tirei por causa da alteracao, nao deixava sair  sem itens
IF lTudo
   Work_SW8->(DBSETORDER(4))
   IF !Work_SW8->(DBSEEK(M->EIJ_ADICAO))
      MSGSTOP("Nao existe itens Marcados.")
      lReturn := .F.
      BREAK
   ENDIF
ENDIF
*/
IF (cNomeCampo $ 'EIJ_REGTRI,EIJ_FUNREG,EIJ_MOTADI,EIJ_TEC_CL,EIJ_REG_PC') .OR. lTudo

   lFunReg:=(cNomeCampo == 'EIJ_FUNREG' .OR. lTudo)
   lMotivo:=(cNomeCampo == 'EIJ_MOTADI' .OR. lTudo)
   lClassi:=(cNomeCampo == 'EIJ_TEC_CL' .OR. lTudo)
   lReg_PC:=(cNomeCampo == 'EIJ_REG_PC' .OR. lTudo)
   lFun_PC:=(cNomeCampo == 'EIJ_FUN_PC' .OR. lTudo)

   IF M->EIJ_REGTRI $ cFiltroSJP//"1,2,3,5,6,7,8"

      cFiltroSY8:=""
      cFiltroSJR:=""
      cFiltroRPC:=""
      cFiltroEIV:=""
      cClassif  :=""
      DI500DSIRegra(M->W6_TIPODES,M->EIJ_REGTRI,M->EIJ_FUNREG,M->EIJ_MOTADI)

      IF !lTudo
         IF M->EIJ_REGTRI = "1"
            M->EIJ_FUNREG := SPACE(LEN(EIJ->EIJ_FUNREG))
         ENDIF
         IF EMPTY(cFiltroSJR)//!(M->EIJ_REGTRI $ '5,6,7')
            M->EIJ_MOTADI := SPACE(LEN(EIJ->EIJ_MOTADI))
            M->EIJ_MOTAVM := SPACE(LEN(SJR->JR_DESC))
         ENDIF
         IF lAUTPCDI  // Bete - DSI - Dependendo do regime informado p/ PIS/COFINS, limpa determinados cpos
            IF M->EIJ_REG_PC = "1"
               M->EIJ_FUN_PC := SPACE(LEN(EIJ->EIJ_FUN_PC))
            ENDIF
            IF M->EIJ_REG_PC <> "4"
               M->EIJ_FRB_PC := SPACE(LEN(EIJ->EIJ_FRB_PC))
               M->EIJ_PRB_PC := 0
               M->EIJ_REDPIS := 0
               M->EIJ_REDCOF := 0
            ENDIF

         ENDIF
      ENDIF

      IF lFunReg .AND. !EMPTY(cFiltroSY8) .AND. !(M->EIJ_FUNREG $ cFiltroSY8)
         MSGSTOP(STR0221+cFiltroSY8) //STR0221 "Regime somente aceita Fund. Legal: "
         lReturn := .F.
         BREAK
      ENDIF

      IF lMotivo
         IF EMPTY(cFiltroSJR)
            IF !EMPTY(M->EIJ_MOTADI)
               MSGSTOP(STR0222) //STR0222 "Motivo nao deve ser preenchido para esse Fundamento Legal"
               lReturn := .F.
               BREAK
            ENDIF
         ELSEIF !(M->EIJ_MOTADI $ cFiltroSJR)
            MSGSTOP(STR0223+cFiltroSJR) //STR0223 "Fundamento somente aceita Motivo: "
            lReturn := .F.
            BREAK
         ENDIF
      ENDIF

      IF lClassi .AND. !EMPTY(cClassif) .AND. !(M->EIJ_TEC_CL $ cClassif)
         MSGSTOP(STR0224+cClassif) //STR0224 "Classificacao deve ser : "
         lReturn := .F.
         BREAK
      ENDIF

      IF lReg_PC .AND. !EMPTY(cFiltroRPC) .AND. !(M->EIJ_REG_PC $ cFiltroRPC)
         MSGSTOP(STR0225+cFiltroRPC) //STR0225 "Regime de Tributacao p/ PIS/COFINS deve ser : "
         lReturn := .F.
         BREAK
      ENDIF

      IF lFun_PC .AND. !EMPTY(cFiltroEIV) .AND. !(M->EIJ_FUN_PC $ cFiltroEIV)
         MSGSTOP(STR0226+cFiltroEIV) //STR0226 "Fundamento legal p/ PIS/COFINS deve ser : "
         lReturn := .F.
         BREAK
      ENDIF

   ELSEIF (cNomeCampo $ 'EIJ_REGTRI' .OR. lTudo) .AND. M->W6_TIPODES # "12"
      MSGSTOP(STR0227+cFiltroSJP) //STR0227 "A Declaracao somente aceita Reg. Trib.: "
      lReturn := .F.
      BREAK
   ENDIF

ENDIF
IF (cNomeCampo $ "EIJ_TPAPIS,EIJ_TPACOF")
   DO CASE
     CASE cNomeCampo == "EIJ_TPAPIS"

         IF M->EIJ_TPAPIS = "1"
             lWhenAutPis:=.F.
             M->EIJ_QTUPIS := 0
             M->EIJ_UNUPIS := ""
             M->EIJ_ALUPIS := 0
         ELSE
             lWhenAutPis:=.T.
             M->EIJ_ALAPIS := 0
             M->EIJ_BASPIS := 0
             M->EIJ_BR_PIS := 0
             M->EIJ_VLDPIS := 0
             M->EIJ_VLRPIS := 0
         ENDIF

     CASE cNomeCampo == "EIJ_TPACOF"

         IF M->EIJ_TPACOF = "1"
             lWhenAutCof:=.F.
             M->EIJ_QTUCOF := 0
             M->EIJ_UNUCOF := ""
             M->EIJ_ALUCOF := 0
         ELSE
             lWhenAutCof:=.T.
             M->EIJ_ALACOF := 0
             M->EIJ_BASCOF := 0
             M->EIJ_BR_COF := 0
             M->EIJ_VLDCOF := 0
             M->EIJ_VLRCOF := 0
         ENDIF
   ENDCASE
ENDIF
END SEQUENCE

IF lTudo
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
ENDIF

RETURN lReturn
*------------------------------------------------------------------*
Function DI500DSIRegra(cTipoDes,cRegTri,cFunReg,cMotAdi,lLSI)
*------------------------------------------------------------------*
LOCAL cFilSJW:=xFilial("SJW")
DEFAULT lLSI := .F.
SJW->(DBSETORDER(1))
IF SJW->(DBSEEK(xFilial()+cTipoDes+cRegTri))
   cFiltroSY8:=""
   cFiltroSJR:=""
   cFiltroRPC:=""
   cFiltroEIV:=""
   cClassif  :=""
   DO WHILE SJW->(!EOF()) .AND. SJW->JW_FILIAL  == cFilSJW  .AND.;
                                SJW->JW_NAT_OPE == cTipoDes .AND.;
                                SJW->JW_REGIME  == cRegTri

      IF SJW->JW_FUND_LE # "00" .AND. !(SJW->JW_FUND_LE $ cFiltroSY8)
         cFiltroSY8+=SJW->JW_FUND_LE+","
      ENDIF
      IF SJW->JW_FUND_LE == cFunReg
         IF SJW->JW_MOTIVO # "00" .AND. !(SJW->JW_MOTIVO $ cFiltroSJR)
            cFiltroSJR+=SJW->JW_MOTIVO+","
         ENDIF
      ENDIF
      IF SJW->JW_FUND_LE == cFunReg .OR. SJW->JW_FUND_LE = "00"
         IF SJW->JW_MOTIVO  == cMotAdi .OR. SJW->JW_MOTIVO = "00"
            IF SJW->JW_CLASSIF $ "1,3"
               cClassif:="0"//NCM
            ENDIF
            IF SJW->JW_CLASSIF $ "2,3"
               cClassif+="1"//TSP
            ENDIF
            IF SJW->JW_CLASSIF = "4"
               IF lLSI
                  cClassif:="0,1"
               ELSE
                  cClassif:="2"//SCL
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF lAUTPCDI  .And.  !lLSI // Bete - DSI - Cria filtro para regime de tributacao e fundamento legal p/ PIS/COFINS
         IF !EMPTY(SJW->JW_REG_PC) .AND. !(ALLTRIM(SJW->JW_REG_PC) $ cFiltroRPC)
            cFiltroRPC+=ALLTRIM(SJW->JW_REG_PC)+","
         ENDIF
         IF M->EIJ_REG_PC $ SJW->JW_REG_PC
            EIV->(dbSeek(xFilial("EIV")+cTipoDes+M->EIJ_REG_PC))
            DO WHILE !EIV->(eof()) .AND. EIV->EIV_NATOPE == cTipoDes .AND. EIV->EIV_REG_PC == M->EIJ_REG_PC
               IF !EMPTY(EIV->EIV_FUN_PC) .AND. !(EIV->EIV_FUN_PC $ cFiltroEIV)
            	  cFiltroEIV += EIV->EIV_FUN_PC+","
               ENDIF
               EIV->(dbSkip())
            ENDDO
         ENDIF
      ENDIF

      SJW->(DBSKIP())
   ENDDO
   cFiltroSY8:=LEFT(cFiltroSY8,LEN(cFiltroSY8)-1)
   cFiltroSJR:=LEFT(cFiltroSJR,LEN(cFiltroSJR)-1)
   IF LEN(cFiltroRPC) > 0
      cFiltroRPC:=LEFT(cFiltroRPC,LEN(cFiltroRPC)-1)
   ENDIF
   IF LEN(cFiltroEIV) > 0
      cFiltroEIV:=LEFT(cFiltroEIV,LEN(cFiltroEIV)-1)
   ENDIF
ENDIF
RETURN .T.
*-----------------------------------------------*
Function DI500DSIPesq(oBrw)
*-----------------------------------------------*
LOCAL oDlg, nSelOp, oRadio
LOCAL nRegWork := Work_SW8->(Recno())
LOCAL bBlocSel:=NIL
PRIVATE aMoeda:={}, aPLIs:={}, aPOs:={}, aNcm:={}, aInvoice:={}
PRIVATE cNcm,cMoeda,cPLI   ,cPO   ,cInvoice
PRIVATE oNCM,oCbo  ,oCboPLI,oCboPO,oInv
PRIVATE nOpRad := 1

Work_SW8->(DBGOTOP())

DO WHILE Work_SW8->(!EOF())

   IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF ASCAN( aMoeda, Work_SW8->WKMOEDA ) == 0
      AADD ( aMoeda, Work_SW8->WKMOEDA )
      cMoeda:=aMoeda[1]
   ENDIF

   IF ASCAN( aPLIs, Work_SW8->WKPGI_NUM ) == 0
      AADD ( aPLIs, Work_SW8->WKPGI_NUM )
      cPLI:=aPLIs[1]
   ENDIF

   IF ASCAN( aPOs, Work_SW8->WKPO_NUM ) == 0
      AADD ( aPOs, Work_SW8->WKPO_NUM )
      cPO:=aPOs[1]
   ENDIF

   /*IF ASCAN( aNcm, Work_SW8->WKTEC ) == 0
      AADD ( aNcm, Work_SW8->WKTEC )
      cNcm:=aNcm[1]
   ENDIF*/

   IF ASCAN( aNcm, Work_SW8->WKTEC+Work_SW8->WKEX_NCM ) == 0  //TRP - 23/02/2010
      AADD ( aNcm, Work_SW8->WKTEC+Work_SW8->WKEX_NCM )
      cNcm:=aNcm[1]
   ENDIF

   IF ASCAN( aInvoice, Work_SW8->WKINVOICE ) == 0
      AADD ( aInvoice, Work_SW8->WKINVOICE )
      cInvoice:=aInvoice[1]
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO

Begin Sequence

   nSelOp := 0
   nCol   := 130
   nLin   := 4

   DEFINE MSDIALOG oDlg TITLE STR0228 FROM 0,0 TO 20,65 Of oMainWnd //STR0228 "Marcar/Desmarcar por Selecao"

      DI500TelaSel(oDlg,.F.)

   ACTIVATE MSDIALOG oDlg ON INIT ;
           DI500EnchoiceBar(oDlg,{{|| nSelOp:=1, oDlg:End()},"OK"},;
                                  {|| nSelOp:=0, oDlg:End()},.F.) CENTERED

   IF nSelOp == 1
      Work_SW8->(dbGoTo(nRegWork))
      IF nOpRad == 0
         BREAK
      ELSEIF nOpRad == 1
         //bBlocSel := {|| RTRIM(Work_SW8->WKTEC    ) == RTRIM(cNCM)}
         bBlocSel := {|| RTRIM(Work_SW8->WKTEC+Work_SW8->WKEX_NCM ) == RTRIM(cEscolha)}  // PLB 06/10/06  //TRP - 23/02/2010 - Adicionada a EX ao filtro por NCM.
      ELSEIF nOpRad == 2
         //bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cPO)}
         bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cEscolha)}  // PLB 06/10/06
      ELSEIF nOpRad == 3
         //bBlocSel := {|| RTRIM(Work_SW8->WKPGI_NUM) == RTRIM(cPLI)}
         bBlocSel := {|| RTRIM(Work_SW8->WKPGI_NUM) == RTRIM(cEscolha)}  // PLB 06/10/06
      ELSEIF nOpRad == 4
         //bBlocSel := {|| RTRIM(Work_SW8->WKMOEDA  ) == RTRIM(cMoeda)}
         bBlocSel := {|| RTRIM(Work_SW8->WKMOEDA  ) == RTRIM(cEscolha)}  // PLB 06/10/06
      ELSEIF nOpRad == 5
         //bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cInvoice)}
         bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cEscolha)}  // PLB 06/10/06
      ELSEIF nOpRad == 6
         Processa( {|| DI500MarkDSI(,.T.,,,,lRegTri) } )
         BREAK
      ENDIF
      Processa( {|| DI500MarkDSI(,.T.,,bBlocSel,,lRegTri) })
   ENDIF

End Sequence

Work_SW8->(dbGoTo(nRegWork))

IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

Return NIL

*-------------------------------------------------------------------------------------*
FUNCTION DI500MarkDSI(cTipo,lTodos,oBrw,bBlocSel,lFiltro,lGrupoRT)
*-------------------------------------------------------------------------------------*
Local cFiltroWk:= ""
DEFAULT lTodos:=.F.
DEFAULT lFiltro:=.T.
DEFAULT lGrupoRT:=.F.//AWR - 18/09/08 - NFE

DI500Controle(1)

IF !lTodos

   DBSELECTAREA("Work_SW8")
   SET FILTER TO

   IF cTipo = "D"
      Work_SW8->WKFLAGDSI:=""
      IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
         Work_SW8->WKGRUPORT:=""
      ELSE
         Work_SW8->WKADICAO :=""
      ENDIF
      Work_SW8->WKREGTRI :=""
      Work_SW8->WKFUNREG :=""
      Work_SW8->WKMOTADI :=""
      Work_SW8->WKBASEII := 0
      Work_SW8->WKVLDEVII:= 0
      Work_SW8->WKVLII   := 0
      Work_SW8->WKVLDEIPI:= 0
      Work_SW8->WKVLIPI  := 0
      Work_SW8->WKBASEICM:= 0
      Work_SW8->WKVLICMS := 0
      Work_SW8->WKBASPIS := 0
      Work_SW8->WKBASCOF := 0
      Work_SW8->WKVLRPIS := 0
      Work_SW8->WKVLRCOF := 0

      // AST - 10/12/08 - Limpa o campo W8_OPERAC e W7_OPERAC, regime de tributação
      IF lQbgOperaca
         Work_SW8->WKOPERACA := ""
         IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
            Work->WKOPERACA := ""
         ENDIF
      ENDIF

      IF lAUTPCDI  // Bete - DSI - ao desmarcar um item, limpa os cpos relativos a PIS/COFINS tb
         Work_SW8->WKREG_PC := ""
         Work_SW8->WKFUN_PC := ""
         Work_SW8->WKFRB_PC := ""
         Work_SW8->WKPERPIS := 0
         Work_SW8->WKPERCOF := 0
         Work_SW8->WKVLUPIS := 0
         Work_SW8->WKVLUCOF := 0
      ENDIF

      If lAntDumpBaseICMS .And. lAtuAnDupi //LGS-09/10/2015
         M->EIJ_BAD_AD -= (Work_SW8->WKPRTOTMOE + Work_SW8->WKFRETEIN + If(lSegInc, Work_SW8->WKSEGURO, 0) ) //Calculo do CIF do Item
         M->EIJ_VLD_DU := M->EIJ_VLR_DU := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )
      EndIf

   ELSEIF cTipo = "M"
      Work_SW8->WKFLAGDSI:=cMarca
      IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
         Work_SW8->WKGRUPORT:=M->EIJ_ADICAO
      ELSE
         Work_SW8->WKADICAO :=M->EIJ_ADICAO
      ENDIF
      Work_SW8->WKREGTRI :=M->EIJ_REGTRI
      Work_SW8->WKFUNREG :=M->EIJ_FUNREG
      Work_SW8->WKMOTADI :=M->EIJ_MOTADI
      IF lAUTPCDI  // Bete - DSI - ao marcar um item, alimentar os cpos relativos a PIS/COFINS tb
         Work_SW8->WKREG_PC := M->EIJ_REG_PC
         Work_SW8->WKFUN_PC := M->EIJ_FUN_PC
         Work_SW8->WKFRB_PC := M->EIJ_FRB_PC
         Work_SW8->WKPERPIS := M->EIJ_ALAPIS
         Work_SW8->WKPERCOF := M->EIJ_ALACOF
         Work_SW8->WKVLUPIS := M->EIJ_ALUPIS
         Work_SW8->WKVLUCOF := M->EIJ_ALUCOF
      ENDIF

      If lAntDumpBaseICMS .And. lAtuAnDupi //LGS-09/10/2015
         M->EIJ_BAD_AD += (Work_SW8->WKPRTOTMOE + Work_SW8->WKFRETEIN + If(lSegInc, Work_SW8->WKSEGURO, 0) ) //Calculo do CIF do Item
         M->EIJ_VLD_DU := M->EIJ_VLR_DU := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )
      EndIf

   ENDIF

ELSEIF lTodos

   IF !EMPTY(Work_SW8->WKFLAGDSI)
      cNewMarca := Space(2)
   ELSE
      cNewMarca := cMarca
   ENDIF
   DBSELECTAREA("Work_SW8")
   SET FILTER TO
   Work_SW8->(DBSETORDER(1))
   Work_SW8->(dbGoTop())
   DO While !Work_SW8->(Eof())

      IncProc(STR0229+Work_SW8->WKCOD_I) // STR0229 "Des/Marcando Item: "

      IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
         IF !EMPTY(Work_SW8->WKGRUPORT) .AND. Work_SW8->WKGRUPORT # M->EIJ_ADICAO
            WORK_SW8->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         IF !EMPTY(WORK_SW8->WKADICAO) .AND. WORK_SW8->WKADICAO # M->EIJ_ADICAO
            WORK_SW8->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF IF(bBlocSel = NIL , Empty(cNewMarca) .AND. !EMPTY(Work_SW8->WKFLAGDSI) , !EVAL(bBlocSel) )
         Work_SW8->WKFLAGDSI:=""
         IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
            Work_SW8->WKGRUPORT:=""
         ELSE
            Work_SW8->WKADICAO :=""
         ENDIF
         Work_SW8->WKREGTRI :=""
         Work_SW8->WKFUNREG :=""
         Work_SW8->WKMOTADI :=""
         Work_SW8->WKBASEII := 0
         Work_SW8->WKVLDEVII:= 0
         Work_SW8->WKVLII   := 0
         Work_SW8->WKVLDEIPI:= 0
         Work_SW8->WKVLIPI  := 0
         Work_SW8->WKBASEICM:= 0
         Work_SW8->WKVLICMS := 0
         Work_SW8->WKBASPIS := 0
         Work_SW8->WKBASCOF := 0
         Work_SW8->WKVLRPIS := 0
         Work_SW8->WKVLRCOF := 0

         // AST - 10/12/08 - Limpa o campo W8_OPERAC e W7_OPERAC, regime de tributação
         IF lQbgOperaca
            Work_SW8->WKOPERACA := ""
            IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
               Work->WKOPERACA := ""
            ENDIF
         ENDIF

         IF lAUTPCDI  // Bete - DSI - ao desmarcar todos os itens, limpa os cpos relativos a PIS/COFINS tb
            Work_SW8->WKREG_PC := ""
            Work_SW8->WKFUN_PC := ""
            Work_SW8->WKFRB_PC := ""
            Work_SW8->WKPERPIS := 0
            Work_SW8->WKPERCOF := 0
            Work_SW8->WKVLUPIS := 0
            Work_SW8->WKVLUCOF := 0
         ENDIF

         IF lAntDumpBaseICMS .And. lAtuAnDupi //LGS-09/10/2015
            M->EIJ_BAD_AD -= (Work_SW8->WKPRTOTMOE + Work_SW8->WKFRETEIN + If(lSegInc, Work_SW8->WKSEGURO, 0) ) //Calculo do CIF do Item
            M->EIJ_VLD_DU := M->EIJ_VLR_DU := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )
         ENDIF

      ELSEIF IF( bBlocSel = NIL , !Empty(cNewMarca) .AND. EMPTY(Work_SW8->WKFLAGDSI) , EVAL(bBlocSel) )
         //Work_SW8->WKFLAGDSI:=cMarca
         Work_SW8->WKFLAGDSI:=cNewMarca // FDR - 12/08/11
         IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
            Work_SW8->WKGRUPORT:=M->EIJ_ADICAO
         ELSE
            Work_SW8->WKADICAO :=M->EIJ_ADICAO
         ENDIF
         Work_SW8->WKREGTRI :=M->EIJ_REGTRI
         Work_SW8->WKFUNREG :=M->EIJ_FUNREG
         Work_SW8->WKMOTADI :=M->EIJ_MOTADI
         IF lAUTPCDI  // Bete - DSI - ao marcar todos itens, alimentar os cpos relativos a PIS/COFINS tb
            Work_SW8->WKREG_PC := M->EIJ_REG_PC
            Work_SW8->WKFUN_PC := M->EIJ_FUN_PC
            Work_SW8->WKFRB_PC := M->EIJ_FRB_PC
            Work_SW8->WKPERPIS := M->EIJ_ALAPIS
            Work_SW8->WKPERCOF := M->EIJ_ALACOF
            Work_SW8->WKVLUPIS := M->EIJ_ALUPIS
            Work_SW8->WKVLUCOF := M->EIJ_ALUCOF
         ENDIF

         IF lAntDumpBaseICMS .And. lAtuAnDupi //LGS-09/10/2015
            M->EIJ_BAD_AD += (Work_SW8->WKPRTOTMOE + Work_SW8->WKFRETEIN + If(lSegInc, Work_SW8->WKSEGURO, 0) ) //Calculo do CIF do Item
            M->EIJ_VLD_DU := M->EIJ_VLR_DU := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )
         ENDIF

      Endif

      Work_SW8->(dbSkip())

   ENDDO
   Work_SW8->(dbGoTop())

ENDIF

IF lFiltro
   IF lExisteSEQ_ADI .AND. lGrupoRT//AWR - 18/09/08 NFE
      //SET FILTER TO RT_FILTRO_DO_WORK_SW8 nopado por WFS em 11/06/10
      cFiltroWk:= RT_FILTRO_DO_WORK_SW8
      Work_SW8->(DBSetFilter({|| &cFiltroWk}, cFiltroWk))
   ELSE
      //SET FILTER TO FILTRO_DO_WORK_SW8 nopado por WFS em 11/06/10
      cFiltroWk:= FILTRO_DO_WORK_SW8
      Work_SW8->(DBSetFilter({|| &cFiltroWk}, cFiltroWk))
   ENDIF
ENDIF

IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

RETURN .T.

*-----------------------------------------------------------------------------------*
Function DI500CalcDSI(cAlias,lTodos)
*-----------------------------------------------------------------------------------*
LOCAL cFilSWZ:=xFilial("SWZ"),cFilSYD:=xFilial("SYD"),nRecno:=Work_EIJ->(RECNO())
LOCAL nIIBaseIPI:=nRecVlr:=nRecFre:=0,aAcertos:={}
LOCAL nTotReal:=nMaiorFre:=nMaiorVlr:=nAliq_ICMS:=nRedICMS:=1
LOCAL cAdicao := DI500Block(cAlias,"EIJ_ADICAO"),nCont:=0
LOCAL nOrdSW8:=Work_SW8->(INDEXORD()),nTotal:=3,lTodosMarcados:=.T.
LOCAL nMaiorDesp:=nRecDesp:=0
LOCAL aContNCM:={},aAdiNCM:={},nAdi//AWR - 25/11/2004
LOCAL nEIJ_BASPIS:=nEIJ_BR_PIS:=nEIJ_VLDPIS:=nEIJ_VLRPIS:=nEIJ_QTUPIS:=0
LOCAL nEIJ_BASCOF:=nEIJ_BR_COF:=nEIJ_VLDCOF:=nEIJ_VLRCOF:=nEIJ_QTUCOF:=0
Local cFiltroWk:= ""
DEFAULT lTodos:=.F.

Work_SW8->(DBGOTOP())
IF WORK_SW8->(BOF()) .AND. WORK_SW8->(EOF())
   RETURN .T.
ENDIF

lGravaSoCapa:=.F.
lGravaEIJ:=.T.

ProcRegua( (Work_SW8->(EasyReccount("Work_SW8"))*4) )

DBSELECTAREA("Work_SW8")
SET FILTER TO

IncProc(STR0186) //  STR0186 "Calculando Impostos "

aAcertos:={}
AADD(aAcertos,{0,ValorFrete(M->W6_HAWB,,,1,.T.)})
AADD(aAcertos,{0,M->W6_VLSEGMN })
AADD(aAcertos,{0,nSomaBaseICMS })

//Rotina de Rateio
SYD->(DBSETORDER(1))
SWZ->(DBSETORDER(2))
Work_EIJ->(DBSETORDER(1))
Work_SW8->(DBGOTOP())

//lSoma:=Empty(DI500Block(cAlias,"EIJ_QT_EST"))

M->W6_PESOL:=0
nPesoProc  :=0
DO WHILE Work_SW8->(!EOF())
   IncProc(STR0186) // STR0186 "Calculando Impostos"
   IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   M->W6_PESOL += Work_SW8->WKPESOTOT
   nPesoProc   += Work_SW8->WKPESOTOT
   //AWR - 25/11/2004 - Controle para saber se os grupos (Adicoes) tem mais de uma NCM diferente
   IF !EMPTY(Work_SW8->WKADICAO) .AND. ASCAN(aAdiNCM,Work_SW8->WKADICAO+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM) = 0
      AADD(aAdiNCM,Work_SW8->WKADICAO+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM)
      nAdi:= ASCAN(aContNCM,{|A| çA[1] = Work_SW8->WKADICAO })
      IF (nAdi = 0)
         AADD(aContNCM,{Work_SW8->WKADICAO,1})
      ELSE
         aContNCM[nAdi,2]+=1
      ENDIF
   ENDIF
   Work_SW8->(DBSKIP())
ENDDO
Work_SW8->(DBGOTOP())
DO WHILE Work_SW8->(!EOF())

   IncProc(STR0186)  //STR0186 "Calculando Impostos"

   IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF EMPTY(Work_SW8->WKFLAGDSI)
      lTodosMarcados:=.F.//nao eh p/ dar skip loop, eh so um controle
   ENDIF

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   WORK_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+M->W6_HAWB))
   IF EMPTY(Work_SW9->W9_TX_FOB)
      MSGSTOP("Inv. / Forn.: "+RTRIM(Work_SW8->WKINVOICE)+" / "+RTRIM(Work_SW8->WKFORN)+EICRetLoja("Work_SW8", "W8_FORLOJ")+STR0230)//STR0230 " com taxa nao preenchida."
      RETURN .F.
   ENDIF

   nTotSW8:=DI500Trans( DI500RetVal("ITEM_INV", "WORK", .T. ))// EOB - 14/07/08 - chamada da função DI500RetVal

   Work_SW8->WKFOBTOTR:=DI500Trans((nTotSW8*Work_SW9->W9_TX_FOB))

   aFrete:=DI500ApFreAdi(Work_SW8->WKPESOTOT,,Work_SW9->W9_TX_FOB)//Rateio do Frete em Real e na Moeda

   Work_SW8->WKVLFREMN:=aFrete[2] // Moeda Nacional - Real

   IF AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_FRETE")//Work_SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"//AWR - DDU
      nVLFRET:=aFrete[3] // Moeda da Invoice
      Work_SW8->WKVLMLE:=nTotSW8-nVLFRET
   ELSE
      Work_SW8->WKVLMLE:=nTotSW8
   ENDIF

// IF lSoma .AND. cAlias = "M"
//    nQtdeEsta:=0
//    DI500QtdeEsta()
//    M->EIJ_QT_EST+= nQtdeEsta
// ENDIF

   aAcertos[1,1]+=Work_SW8->WKVLFREMN
   nTotReal     +=(Work_SW8->WKVLMLE*Work_SW9->W9_TX_FOB)

   IF Work_SW8->WKPESOTOT > nMaiorFre
      nMaiorFre:=Work_SW8->WKPESOTOT
      nRecFre  :=Work_SW8->(RECNO())
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO

IF nRecFre # 0
   Work_SW8->(DBGOTO(nRecFre))
   IF !EMPTY(aAcertos[1,1])  .AND.   (aAcertos[1,2] # aAcertos[1,1])
      Work_SW8->WKVLFREMN+=DI500Trans(aAcertos[1,2] - aAcertos[1,1])
   ENDIF
ENDIF

IF !EMPTY(M->W6_SEGPERC)
   //Seguro em Real e na Moeda
   aSeguro:=DI500ApSegAdi("XXX",nTotReal,0,aAcertos[1,2],0,0,.F.,0)
   M->W6_VL_USSE:=aSeguro[2]/M->W6_TX_SEG  // Moeda Negociada
   M->W6_VLSEGMN:=aAcertos[2,2]:=aSeguro[2]// Moeda Nacional - Real
ENDIF

Work_SW8->(DBGOTOP())
nRecVlr :=  Work_SW8->(RECNO())
DO WHILE Work_SW8->(!EOF())

   IncProc(STR0186)//STR0186 "Calculando Impostos"

   IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   nRateio:= (Work_SW8->WKFOBTOTR/nTotReal)

   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   WORK_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+M->W6_HAWB))

   aSeguro:=DI500ApSegAdi(Work_SW9->W9_INCOTER,;
                          Work_SW8->WKFOBTOTR ,;
                          nTotReal ,;
                          Work_SW8->WKVLFREMN ,;
                          0,M->W6_VLSEGMN,.T.,0)

   Work_SW8->WKVLSEGMN:=aSeguro[2]
   Work_SW8->WKBASEICM:=DI500Trans(nSomaBaseICMS*nRateio)

   aAcertos[2,1]+=Work_SW8->WKVLSEGMN
   aAcertos[3,1]+=Work_SW8->WKBASEICM

   IF Work_SW8->WKVLSEGMN > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKVLSEGMN
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF

   IF Work_SW8->WKBASEICM > nMaiorDesp
      nMaiorDesp:=Work_SW8->WKBASEICM
      nRecDesp  :=Work_SW8->(RECNO())
   ENDIF

   IF Work_EIJ->(DBSEEK( Work_SW8->WKADICAO ))
      Work_EIJ->EIJ_QT_EST:=0
   ENDIF
   Work_SW8->(DBSKIP())

ENDDO

IF nRecVlr # 0
   Work_SW8->(DBGOTO(nRecVlr))
   IF !EMPTY(aAcertos[2,1])  .AND.   (aAcertos[2,2] # aAcertos[2,1])
      Work_SW8->WKVLSEGMN+=DI500Trans(aAcertos[2,2] - aAcertos[2,1])
   ENDIF
ENDIF

IF nRecVlr # 0
   Work_SW8->(DBGOTO(nRecDesp))
   IF !EMPTY(aAcertos[3,1])  .AND.   (aAcertos[3,2] # aAcertos[3,1])
      Work_SW8->WKBASEICM+=DI500Trans(aAcertos[3,2] - aAcertos[3,1])
   ENDIF
ENDIF

Work_SW8->(DBSETORDER(4))
IF lTodos
   Work_SW8->(DBGOTOP())
ELSE
   ProcRegua(nTotal)
   Work_SW8->(DBSEEK(cAdicao))
ENDIF

M->EIJ_QT_EST:=nVLAIPI:=nVLARII:=0

DO WHILE Work_SW8->(!EOF()) .AND. (Work_SW8->WKADICAO == cAdicao .OR. lTodos)

   IF nCont < nTotal+1 .OR. lTodos
      IncProc(STR0186) //STR0186 "Calculando Impostos"
      nCont++
   ELSE
      ProcRegua(nTotal)
      nCont:=0
   ENDIF

   IF EMPTY(Work_SW8->WKFLAGDSI) .OR. EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   WORK_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+M->W6_HAWB))
   IF lTodos
      Work_EIJ->(DBSEEK( Work_SW8->WKADICAO ))
   ENDIF

   nAdi:=ASCAN(aContNCM,{|A| A[1] = Work_SW8->WKADICAO })
   IF nAdi # 0 .AND. aContNCM[nAdi,2] == 1
      SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
      IF EMPTY(DI500Block(cAlias,"EIJ_ALAIPI"))
         DI500Block(cAlias,"EIJ_ALAIPI",SYD->YD_PER_IPI)
      ENDIF
      IF EMPTY(DI500Block(cAlias,"EIJ_ALI_II"))
         DI500Block(cAlias,"EIJ_ALI_II",SYD->YD_PER_II)
      ENDIF
      IF lAUTPCDI // DSI - Bete
      	 IF EMPTY(DI500Block(cAlias,"EIJ_TPAPIS"))
            IF !EMPTY(SYD->YD_VLU_PIS)
               DI500Block(cAlias,"EIJ_TPAPIS","2")
               DI500Block(cAlias,"EIJ_ALUPIS",SYD->YD_VLU_PIS)
            ELSE
               DI500Block(cAlias,"EIJ_TPAPIS","1")
               DI500Block(cAlias,"EIJ_ALAPIS",SYD->YD_PER_PIS)
            ENDIF
         ENDIF
      	 IF EMPTY(DI500Block(cAlias,"EIJ_TPACOF"))
            IF !EMPTY(SYD->YD_VLU_COF)
               DI500Block(cAlias,"EIJ_TPACOF","2")
               DI500Block(cAlias,"EIJ_ALUCOF",SYD->YD_VLU_COF)
            ELSE
               DI500Block(cAlias,"EIJ_TPACOF","1")
               DI500Block(cAlias,"EIJ_ALACOF",SYD->YD_PER_COF)
            ENDIF
         ENDIF
	  ENDIF

      nQtdeEsta:= 0//Para o ponto de entrada preencher
      nQtdeEsta:= (DI500Block(cAlias,"EIJ_QT_EST") + DI500QtdeEsta())
      DI500Block(cAlias,"EIJ_QT_EST", nQtdeEsta )
   ENDIF
   nAliq_ICMS:=0
   nRedICMS :=1
   nBaseII  :=0
   nBASE_PC:=0
   nAliqIPIUsada:=DI500Block(cAlias,"EIJ_ALAIPI")
   nAliqIIUsada :=DI500Block(cAlias,"EIJ_ALI_II")


   nBaseII:=DI500Trans(Work_SW8->WKFOBTOTR)

   IF !AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_FRETE")
      nBaseII+= Work_SW8->WKVLFREMN
   ENDIF

   IF !AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_SEG")
      nBaseII+= Work_SW8->WKVLSEGMN
   ENDIF

   /*IF Work_SW9->W9_INCOTER $ 'FOB,EXW,FAS,FCA,DDP,DEQ'//,DDU'//AWR - DDU
      nBaseII:=DI500Trans(Work_SW8->WKFOBTOTR+Work_SW8->WKVLFREMN+Work_SW8->WKVLSEGMN)
   ELSEIF Work_SW9->W9_INCOTER $ 'CIF,DAF,DES,CIP'
      nBaseII:=DI500Trans(Work_SW8->WKFOBTOTR)
   ELSEIF Work_SW9->W9_INCOTER $ 'CFR,CPT,DDU'//AWR - DDU
      nBaseII:=DI500Trans(Work_SW8->WKFOBTOTR+Work_SW8->WKVLSEGMN)
   ENDIF*/

   IF AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_FRETE")/*FDR - 28/12/10*/  //Work_SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"//AWR - DDU
      Work_SW8->WKVLFREMN:=0
      lAcerto:=.F.
   ENDIF

   IF DI500Block(cAlias,"EIJ_REGTRI") $ "2"//Imunidade
      Work_SW8->WKBASEII := 0
      Work_SW8->WKVLDEVII:= 0
   ELSE
      Work_SW8->WKBASEII := nBaseII
      Work_SW8->WKVLDEVII:= DI500Trans( Work_SW8->WKBASEII * (nAliqIIUsada/100))
   ENDIF
   IF DI500Block(cAlias,"EIJ_REGTRI") $ "7,2"//Trib. Simples, Imunidade
      Work_SW8->WKVLDEIPI:= 0
   ELSE
      Work_SW8->WKVLDEIPI:= DI500Trans((Work_SW8->WKBASEII+Work_SW8->WKVLDEVII) * (nAliqIPIUsada/100))
   ENDIF
   IF M->W6_TIPODES == "09" .OR. DI500Block(cAlias,"EIJ_REGTRI") $ "3,2"//Adm. Temp.  ou Isencao ou Imunidade
      Work_SW8->WKVLII   := 0
      Work_SW8->WKVLIPI  := 0
   ELSE
      Work_SW8->WKVLII   := Work_SW8->WKVLDEVII
      Work_SW8->WKVLIPI  := Work_SW8->WKVLDEIPI
   ENDIF
   nWZ_ICMSPC:=0
   IF SWZ->(DbSeek(cFilSWZ+Work_SW8->WKOPERACA))
/* Quando existir aliquota de carga tributaria equivalente esta sera usada para o calculo da base de pis e cofins*/
      IF EMPTY(SWZ->WZ_RED_CTE)
         nAliq_ICMS:= SWZ->WZ_AL_ICMS
      ELSE
         nAliq_ICMS:= SWZ->WZ_RED_CTE
      ENDIF
      IF SWZ->(FIELDPOS("WZ_ICMS_PC")) # 0
         nWZ_ICMSPC:=(SWZ->WZ_ICMS_PC/100)
      ENDIF
      nRedICMS := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
   ELSEIF SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
      nAliq_ICMS:= SYD->YD_ICMS_RE
   ENDIF
   nBaseICMS:=0
   IF lMV_PIS_EIC
      nQtde:=Work_SW8->WKQTDE // ldr - OC - 0048/04 - OS - 0989/04
      IF lVlUnid .AND. !EMPTY(Work_SW8->WKQTDE_UM) // LDR - OC - 0048/04 - OS - 0989/04
         nQtde:=Work_SW8->WKQTDE_UM
      ENDIF

      /* JONATO 04/FEV/2005. A utilização da variável nAUX_II é necessária para os casos
      em que houver redução de base de calculo, porque nesses casos as planilhas de calculo
      da Receita, reduzem a aliquota, e não a base. Também criei a variável apenas aqui para
      não ter que mexer com o tratamento dentro da função de calculo do impostos */
      nAUX_II:= nAliqIIUsada
      If DI500Block(cAlias,"EIJ_REGTRI") == '4' .and. ;
         DI500Block(cAlias,"EIJ_PR_II") <> 0    .and. ;
         EMPTY(DI500Block(cAlias,"EIJ_ALR_II"))
         nAUX_II:= nAliqIIUsada - ( nAliqIIUsada * (DI500Block(cAlias,"EIJ_PR_II")/100) )
      ElseIf DI500Block(cAlias,"EIJ_REGTRI") $ '2,3,6'  // Bete - 06/05/06 - P/ IMUNIDADE, ISENCAO ou NAO-INCIDENCIA
         nAUX_II:=0                                     // de II, a aliquota é zero p/ o cálculo do PIS/COFINS
      Endif
      nAux_IPI:=nAliqIPIUsada                         // Jonato em 28/09/2005. Segundo a MP252, para ISENÇÃO
      IF DI500Block(cAlias,"EIJ_REGIPI") $ '1,3'      // E IMUNIDADE de IPI, a aliquota é zero para calculo
         nAUX_IPI:=0                                  // de PIS
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '4,5' .AND. DI500Block(cAlias,"EIJ_TPAIPI") = '2'
         IF nVlrIPIEsp == 0
            nVlrIPIEsp := DI500Trans(DI500Block(cAlias,"EIJ_QTUIPI")*DI500Block(cAlias,"EIJ_ALUIPI"))
         ENDIF
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '5' //JAP - Zera o cálculo do IPI em caso de suspensão e o ato do IPI for = LEI
         cNroipi := EasyGParam("MV_ZIPIPIS",,"")
         cEijipi := DI500Block(cAlias,"EIJ_NROIPI")
         cNroipi := Alltrim(STRTRAN(cNroipi, ".",""))
         cEijipi := Alltrim(STRTRAN(cEijipi, ".",""))
         IF !Empty(cNroipi) .AND. cEijipi $ cNroipi .AND. ALLTRIM(DI500Block(cAlias,"EIJ_ATOIPI")) == 'LEI'
            nAUX_IPI := 0
         ENDIF
      ELSEIF DI500Block(cAlias,"EIJ_REGIPI") $ '2'
         nAUX_IPI:=DI500Block(cAlias,"EIJ_ALRIPI")  // Bete - 06/05/06 - P/ REDUCAO, considerar a aliq. reduzida
      ENDIF                                         // p/ o calculo do PIS/COFINS

      //O campo Work_SW8->WKBASEICM contem SOMENTE as despesas base de ICMS
      nBaseICMS:=DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAliqIIUsada/100),(nAliqIPIUsada/100),(nAliq_ICMS/100),(Work_SW8->WKPERPIS/100),(Work_SW8->WKPERCOF/100),0,nWZ_ICMSPC,,"PISCALC_DSI",@nBASE_PC) //RJB
      SYD->(DbSeek(cFilSYD+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))
      IF !lAUTPCDI  // Bete - DSI - alimentar var p/ o calculo do PIS/COFINS considerando ou nao os novos cpos
         nRedPis:=SYD->YD_RED_PIS
         nRedCof:=SYD->YD_RED_COF
         nAliPis:=Work_SW8->WKPERPIS
         nAliCof:=Work_SW8->WKPERCOF
         nAluPis:=Work_SW8->WKVLUPIS
         nAluCof:=Work_SW8->WKVLUCOF
      ELSE
         nRedPis := DI500Block(cAlias,"EIJ_PRB_PC")
         nRedCof := DI500Block(cAlias,"EIJ_PRB_PC")
         nAliPis := DI500Block(cAlias,"EIJ_ALAPIS")
         nAliCof := DI500Block(cAlias,"EIJ_ALACOF")
         nAluPis := DI500Block(cAlias,"EIJ_ALUPIS")
         nAluCof := DI500Block(cAlias,"EIJ_ALUCOF")
      ENDIF
      IF !EMPTY(nAluPis) .OR. (lAUTPCDI .AND. DI500Block(cAlias,"EIJ_TPAPIS") == "2")  // DSI - Bete
         Work_SW8->WKBASPIS:= 0
         Work_SW8->WKVLRPIS:= nAluPis * IIF(lAUTPCDI,DI500Block(cAlias,"EIJ_QTUPIS"),nQtde)  // ldr - OC - 0048/04 - OS - 0989/04
         IF lAUTPCDI  // Bete - DSI - alimenta determinados cpos quando aliquota especifica
            Work_SW8->WKVLUPIS:= nAluPis
            Work_SW8->WKPERPIS  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDEPIS := Work_SW8->WKVLRPIS
            IF DI500Block(cAlias,"EIJ_REG_PC") <> "1"
               Work_SW8->WKVLRPIS := 0
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+= Work_SW8->WKVLRPIS
         ENDIF
      ELSE
         Work_SW8->WKBASPIS:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliq_ICMS/100),(nAliPis/100),(nAliCof/100),(nRedPis/100),nWZ_ICMSPC,,"PISCALC_DSI",@nBASE_PC) //RJB
         Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (nAliPis/100)
         IF lAUTPCDI   // DSI - Bete
            Work_SW8->WKPERPIS  := nAliPis
         	Work_SW8->WKVLUPIS  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDEPIS := Work_SW8->WKVLRPIS
            IF DI500Block(cAlias,"EIJ_REG_PC") = "4"
               Work_SW8->WKVLRPIS:= Work_SW8->WKBASPIS * (DI500Block(cAlias,"EIJ_REDPIS")/100)
            ENDIF
            IF DI500Block(cAlias,"EIJ_REG_PC") $ "2,3,5"
               Work_SW8-> WKVLRPIS := 0
            ENDIF
            nEIJ_BASPIS+=nBASE_PC
            IF DI500Trans(Work_SW8->WKBASPIS) < DI500Trans(nBASE_PC)
               nEIJ_BR_PIS+=Work_SW8->WKBASPIS
            ENDIF
            nEIJ_VLDPIS+= Work_SW8->WKVLDEPIS
            nEIJ_VLRPIS+=Work_SW8->WKVLRPIS
         ENDIF
      ENDIF
      IF !EMPTY(nAluCof) .OR. (lAUTPCDI .AND. DI500Block(cAlias,"EIJ_TPACOF") == "2")  // DSI - Bete
         Work_SW8->WKBASCOF:= 0
         Work_SW8->WKVLRCOF:= nAluCof * IIF(lAUTPCDI,DI500Block(cAlias,"EIJ_QTUCOF"),nQtde)  // ldr - OC - 0048/04 - OS - 0989/04
         IF lAUTPCDI  // Bete - DSI - alimenta determinados cpos quando aliquota especifica
            Work_SW8->WKVLUCOF  := nAluCof
            Work_SW8->WKPERCOF  := 0  // Zera aliquota ad. valorem por estar tratando como especifica
            Work_SW8->WKVLDECOF := Work_SW8->WKVLRCOF
            IF DI500Block(cAlias,"EIJ_REG_PC") <> "1"
               Work_SW8->WKVLRCOF := 0
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ELSE
         Work_SW8->WKBASCOF:= DI500PISCalc(nBaseII,Work_SW8->WKBASEICM,(nAUX_II/100),(nAUX_IPI/100),(nAliq_ICMS/100),(nAliPis/100),(nAliCof/100),(nRedCof/100),nWZ_ICMSPC,,"PISCALC_DSI",@nBASE_PC) //RJB
         Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (nAliCof/100)
         IF lAUTPCDI  // Bete - DSI - alimenta determinados cpos quando aliquota ad valorem
            Work_SW8->WKPERCOF  := nAliCof
         	Work_SW8->WKVLUCOF  := 0  // Zera aliquota especifica por estar tratando como ad. valorem
            Work_SW8->WKVLDECOF := Work_SW8->WKVLRCOF
            IF DI500Block(cAlias,"EIJ_REG_PC") = "4"
               Work_SW8->WKVLRCOF:= Work_SW8->WKBASCOF * (DI500Block(cAlias,"EIJ_REDCOF")/100)
            ENDIF
            IF DI500Block(cAlias,"EIJ_REG_PC") $ "2,3,5"
               Work_SW8-> WKVLRCOF := 0
            ENDIF
            nEIJ_BASCOF += nBASE_PC
            IF DI500Trans(Work_SW8->WKBASCOF) < DI500Trans(nBASE_PC)
               nEIJ_BR_COF += Work_SW8->WKBASCOF
            ENDIF
            nEIJ_VLDCOF += Work_SW8->WKVLDECOF
            nEIJ_VLRCOF += Work_SW8->WKVLRCOF
         ENDIF
      ENDIF
   ENDIF
   /*Para o calculo do ICMS e sempre utilizada a aliquota normal    // LDR */
   IF SWZ->(!EOF())
      nAliq_ICMS:= SWZ->WZ_AL_ICMS
   ENDIF

   IF lMV_PIS_EIC .AND. lMV_ICMSPIS
//    IF !lVlrUnitPISCOFINS
         Work_SW8->WKBASEICM:=DI500ICMSCalc(,nRedICMS,nAliq_ICMS,nBaseII,Work_SW8->WKBASEICM,nBaseICMS,Work_SW8->WKVLII,Work_SW8->WKVLIPI,Work_SW8->WKVLRPIS,Work_SW8->WKVLRCOF,(nWZ_ICMSPC*100),"ICMSCALC_DI") //AWR 13/09/2004
//    ELSE
//       Work_SW8->WKBASEICM:=(Work_SW8->WKBASEICM+nBaseII+Work_SW8->WKVLII+Work_SW8->WKVLIPI+Work_SW8->WKVLRPIS+Work_SW8->WKVLRCOF)/( ( 100 - nAliqICMS )/ 100 )
//    ENDIF
   ELSE
      Work_SW8->WKBASEICM+=DI500Trans((nBaseII+Work_SW8->WKVLII+Work_SW8->WKVLIPI))
      Work_SW8->WKBASEICM:=DI500ICMSCalc( Work_SW8->WKBASEICM, nRedICMS, nAliq_ICMS )
   ENDIF

   Work_SW8->WKVLICMS:=DI500Trans(Work_SW8->WKBASEICM * (nAliq_ICMS/100) )

   IF M->W6_TIPODES == "10" // Bagagem
      Work_SW8->WKVLII   := 0
      Work_SW8->WKVLIPI  := 0
      Work_SW8->WKBASPIS := 0
      Work_SW8->WKVLRPIS := 0
      Work_SW8->WKBASCOF := 0
      Work_SW8->WKVLRCOF := 0
   ENDIF

   IF M->W6_TIPODES == "09" // Admissao Temporaria
      Work_SW8->WKBASPIS := 0
      Work_SW8->WKVLRPIS := 0
      Work_SW8->WKBASCOF := 0
      Work_SW8->WKVLRCOF := 0
   ELSE
      nVLARII+=Work_SW8->WKVLII
      nVLAIPI+=Work_SW8->WKVLIPI
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO

IF lAUTPCDI  // Bete - DSI - alimenta os cpos novos com o acumulo dos valores dos itens selecionados
   DI500Block(cAlias,"EIJ_BASPIS", nEIJ_BASPIS)
   DI500Block(cAlias,"EIJ_BR_PIS", nEIJ_BR_PIS)
   DI500Block(cAlias,"EIJ_VLDPIS", nEIJ_VLDPIS)
   DI500Block(cAlias,"EIJ_VLRPIS", nEIJ_VLRPIS)

   DI500Block(cAlias,"EIJ_BASCOF", nEIJ_BASCOF)
   DI500Block(cAlias,"EIJ_BR_COF", nEIJ_BR_COF)
   DI500Block(cAlias,"EIJ_VLDCOF", nEIJ_VLDCOF)
   DI500Block(cAlias,"EIJ_VLRCOF", nEIJ_VLRCOF)
ENDIF

DI500GrvEI("EII_SW6",,,,.T.)

IF cAlias = "M"
   //SET FILTER TO FILTRO_DO_WORK_SW8 nopado por WFS em 11/06/10
   cFiltroWk:= FILTRO_DO_WORK_SW8
   Work_SW8->(DBSetFilter({|| &cFiltroWk}, cFiltroWk))
ENDIF

IF lTodos
   Work_EIJ->(DBGOTOP())
ENDIF

M->W6_ADICAOK:=IF( lTodosMarcados , SIM , NAO )
DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
Work_SW8->(DBSETORDER(nOrdSW8))
Work_SW8->(DBGOTOP())
Work_EIJ->(DBGOTO(nRecno))
Return .T.
*--------------------------------------*
Function DI500DSITot(lCapas)
*--------------------------------------*
LOCAL nCo1:=2, nCo2:=9, nCo3:=19, nCo4:=25.5
LOCAL oDlg,PICT15_2:=AVSX3("W6_FOB_TOT",6)
LOCAL nLIN:=28, nCOL:=83,cTitulo:=STR0230 //STR0230 "Valores do Produto"
LOCAL nVlrAduana:=(Work_SW8->WKFOBTOTR+Work_SW8->WKVLFREMN+Work_SW8->WKVLSEGMN)
LOCAL nBaseIPI:=0

PRIVATE nAcres := nDed := 0
PRIVATE nBaseII:= nFobR  := nFrete := nSeguro:= 0
PRIVATE nVLAIPI:= nVLARII:= nVLDEII:= nICMS  := 0
PRIVATE nVL_II := nVLR_II:= nDEVII := nVLDIPI:= 0
PRIVATE nBASPIS:= nVLRPIS:= nBASCOF:= nVLRCOF:= 0

IF lCapas # NIL
   cTitulo:=STR0231 //STR0231 "Totais da DSI"
   Processa({|| DI500AdiSoma()})
   nLIN:=30
   nCOL:=57
ENDIF

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,10 TO nLIN,nCOL Of oMainWnd

 IF lCapas = NIL

    @0.5,nCo1-1 TO 5,nCo3-1.5 LABEL STR0232 OF oDlg //STR0232 " Base de Calculo "
    @1.2,nCo1 SAY STR0233  //STR0233 "Valor MLE (R$)"
    @2.2,nCo1 SAY STR0234 //STR0234 "Valor do Frete (R$)"
    @3.2,nCo1 SAY STR0235 //STR0235 "Valor do Seguro (R$)"
    @4.2,nCo1 SAY STR0236 //STR0236 "Valor Aduaneiro (R$)"

    @1.2,nCo2 MSGET Work_SW8->WKFOBTOTR WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @2.2,nCo2 MSGET Work_SW8->WKVLFREMN WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @3.2,nCo2 MSGET Work_SW8->WKVLSEGMN WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @4.2,nCo2 MSGET nVlrAduana          WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    @0.5,nCo3-1 TO 3.2,nCo4+8 LABEL " I.C.M.S. " OF oDlg
    @1.2,nCo3 SAY STR0232 //STR0232 " Base de Calculo "
    @2.2,nCo3 SAY STR0237 //STR0237 "Valor a Recolher"

    @1.2,nCo4 MSGET Work_SW8->WKBASEICM WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
    @2.2,nCo4 MSGET Work_SW8->WKVLICMS  WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT

    @5.2,nCo1-1 TO 9.7,nCo3-1.5 LABEL " I.I. " OF oDlg
    @6.2,nCo1 SAY STR0232  //STR0232 " Base de Calculo "
    @7.2,nCo1 SAY STR0238 //STR0238 "Aliquota Ad Valorem (%)"
    @8.2,nCo1 SAY STR0239  //STR0239 "Valor Devido"
    @9.2,nCo1 SAY STR0237 //STR0237 "Valor a Recolher"

    @6.2,nCo2 MSGET Work_SW8->WKBASEII  WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
    @7.2,nCo2+1.5 MSGET M->EIJ_ALI_II   WHEN .F. PICTURE "@E 999.99" SIZE 43,8 RIGHT
    @8.2,nCo2 MSGET Work_SW8->WKVLDEVII WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
    @9.2,nCo2 MSGET Work_SW8->WKVLII    WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT

    @5.2,nCo3-1 TO 9.7,nCo4+8 LABEL " I.P.I. " OF oDlg
    @6.2,nCo3 SAY STR0232 //STR0232 " Base de Calculo "
    @7.2,nCo3 SAY STR0238//STR0238 "Aliquota Ad Valorem (%)"
    @8.2,nCo3 SAY STR0239//STR0239 "Valor Devido"
    @9.2,nCo3 SAY STR0237//STR0237 "Valor a Recolher"

    IF !M->EIJ_REGTRI $ "7,2"
       nBaseIPI:=Work_SW8->WKBASEII+IF(M->EIJ_REGTRI $ "3" , Work_SW8->WKVLDEVII , Work_SW8->WKVLII )
    ENDIF
    @6.2,nCo4 MSGET nBaseIPI            WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
    @7.2,nCo4+1.5 MSGET M->EIJ_ALAIPI   WHEN .F. PICTURE "@E 999.99" SIZE 43,8 RIGHT
    @8.2,nCo4 MSGET Work_SW8->WKVLDEIPI WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
    @9.2,nCo4 MSGET Work_SW8->WKVLIPI   WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT

    IF lMV_PIS_EIC

       @10.0,nCo1-1 TO 13.6,nCo3-1.5 LABEL " PIS " OF oDlg
       @11.3,nCo1 SAY STR0232 //STR0232 " Base de Calculo "
       @12.3,nCo1 SAY STR0240 //STR0240 "Aliquota (%)"
       @13.3,nCo1 SAY STR0237//STR0237 "Valor a Recolher"

       @11.3,nCo2 MSGET Work_SW8->WKBASPIS     WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
       // DSI - Bete
       @12.3,nCo2+1.5 MSGET IF(lAUTPCDI,IF(M->EIJ_TPAPIS="1",M->EIJ_ALAPIS,M->EIJ_ALUPIS),Work_SW8->WKPERPIS) WHEN .F. PICTURE "@E 999.99" SIZE 43,8 RIGHT
       @13.3,nCo2 MSGET Work_SW8->WKVLRPIS     WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT

       @10.0,nCo3-1 TO 13.6,nCo4+8 LABEL " COFINS " OF oDlg
       @11.3,nCo3 SAY STR0232 //STR0232 " Base de Calculo "
       @12.3,nCo3 SAY STR0240 //STR0240 "Aliquota (%)"
       @13.3,nCo3 SAY STR0237 //STR0237 "Valor a Recolher"

       @11.3,nCo4 MSGET Work_SW8->WKBASCOF     WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT
       // DSI - Bete
       @12.3,nCo4+1.5 MSGET IF(lAUTPCDI,IF(M->EIJ_TPACOF="1",M->EIJ_ALACOF,M->EIJ_ALUCOF),Work_SW8->WKPERCOF) WHEN .F. PICTURE "@E 999.99" SIZE 43,8 RIGHT
       @13.3,nCo4 MSGET Work_SW8->WKVLRCOF     WHEN .F. PICTURE PICT15_2    SIZE 55,8 RIGHT

       oDlg:nHeight+= 110

    ENDIF

  ELSE

    nCo1:=2
    nCo3:=13
    nCo4:=21
    nLIN:=1.5
    nVlrAduana:=(nFobR+nFrete+nSeguro)

    @ nLIN++  ,nCo1+1 SAY STR0241 //STR0241 "Valor MLE (R$)"
    @ nLIN++  ,nCo1 MSGET nFobR   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo1 SAY STR0242 //STR0242 "Valor do Frete (R$)"
    @ nLIN++  ,nCo1 MSGET nFrete  WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo1 SAY STR0243 //STR0243 "Valor do Seguro (R$)"
    @ nLIN++  ,nCo1 MSGET nSeguro WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo1 SAY   STR0244 //STR0244 "Valor Aduaneiro (R$)"
    @ nLIN++  ,nCo1 MSGET nVlrAduana WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    @ 0.5     ,nCo1-1  TO nLIN,nCo3-3 LABEL STR0232 OF oDlg //STR0232 " Base de Calculo "

    nLIN:=1.5
    @ nLIN++  ,nCo3+1 SAY STR0245 //STR0245 "  Valor do I.I."
    @ nLIN++  ,nCo3 MSGET nVLARII WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    nLIN+=.5
    @ nLIN++  ,nCo3+1 SAY STR0246 //STR0246 "Valor do I.P.I."
    @ nLIN++  ,nCo3 MSGET nVLAIPI WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

    IF lMV_PIS_EIC

       nLIN+=.5
       @ nLIN++  ,nCo3+1 SAY AVSX3("W8_VLRPIS",5)
       @ nLIN++  ,nCo3 MSGET nVLRPIS WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

       nLIN+=.5
       @ nLIN++  ,nCo3+1 SAY AVSX3("W8_VLRCOF",5)
       @ nLIN++  ,nCo3 MSGET nVLRCOF WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT

       oDlg:nHeight+=55

    ENDIF

    nLIN+=.5
    @ nLIN++  ,nCo3+1 SAY "Valor do I.C.M.S"
    @ nLIN++  ,nCo3 MSGET nICMS   WHEN .F. PICTURE PICT15_2 SIZE 55,8 RIGHT
    IF lMV_PIS_EIC
       nLIN-=.5
    ENDIF
    @ 0.5     ,nCo3-1  TO nLIN,nCo4 LABEL STR0247 OF oDlg //STR0247 " Impostos a Recolher "

  ENDIF

ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL
*-------------------------------------*
FUNCTION DI500GrvDSI()
*-------------------------------------*
Local cFilSAH := xFilial('SAH'), E
Local cFilSB1 := xFilial('SB1')
Local cFilSYD := xFilial('SYD')
Local cFilSYT := xFilial('SYT')
Local cFilSYQ := xFilial('SYQ')
Local cFilSY4 := xFilial('SY4')
Local cFilSW8 := xFilial("SW8")
Local cFilSW9 := xFilial("SW9")
Local cFilSA2 := xFilial("SA2")
Local cFilSYF := xFilial("SYF")
Local cFilSW2 := xFilial("SW2")
Local cFilSW7 := xFilial("SW7")
Local cFilEIH := xFilial("EIH")
Local cFilEIJ := xFilial("EIJ")
Local cFilEIL := xFilial("EIL")
Local cFilEII := xFilial("EII")
Local nCont:=0,mMemo,nTotal_IPI:=nTotal_II:=nTot_VLMLERS:=nItem:=0,nTotal:=10
Local cTipoVia,nHdl,nSair,aMenslog:={},cWhere,aTabMDBs:={}
Local nTamDesc := AvSx3("W8_DESC_VM",3)
Local nTamIMemo:= AvSx3("B1_VM_GI",3)
Local nTotal_PIS:=nTotal_COF:=nTotC_PIS:=nTotC_COF:=0
//PRIVATE ENTER:=CHR(13)+CHR(10)
PRIVATE cODBC_DSI:= EasyGParam("MV_ODBCDSI",,"DSI")
PRIVATE oDlgProc := GetWndDefault()
PRIVATE nAliqICMS := 0

SB1->(dbSetOrder(1))
SW7->(dbSetOrder(4))
SW2->(dbSetOrder(1)) /* W2_FILIAL+W2_PO_NUM            */
SA2->(dbSetOrder(1)) /* A2_FILIAL+A2_COD+A2_LOJA       */
SYT->(dbSetOrder(1)) /* YT_FILIAL+YT_COD_IMP           */
SYQ->(dbSetOrder(1)) /* QY_FILIAL+YQ_VIA               */
SYD->(dbSetOrder(1))
SAH->(dbSetOrder(1))
SYF->(dbSetOrder(1)) /* YF_FILIAL+YF_MOEDA             */
EIL->(dbSetOrder(1)) /* EIL_FILIAL+EIL_HAWB+EIL_ADICAO */

DI500AbreWork()

ProcRegua(7)

IncProc(STR0248) //STR0248 "Verificando se existe a DSI no Siscomex..."

PRIVATE cErro:=""

oDlgProc:SetText(STR0249)//STR0249 "Verificacao se existe/atualizando dados no Siscomex..."

cWhere      :=" WHERE CD_DSI_MICRO = '"+LEFT( SW6->W6_HAWB,LEN(Work_Capa->CD_DSI_MIC) )+"'"
aArrayChaves:={{"CD_DSI_MICRO","CD_DSI_MIC","",""}}
aArrayCampos:={{"","","",""}}
aTabMDBs    :={"DSI_DADOS_GERAIS","DSI_BENS","DSI_VOLUMES","DSI_TRIBUTOS_BEM","DSI_PGTO_TRIBUTOS"}

FOR E := 1 TO LEN(aTabMDBs)
    cMenErro:= STR0250 + aTabMDBs[E]+ENTER   //STR0250 "A) Erro na Atualizacao dos dados da Tabela: "
    aMenslog:= {}

    IncProc(STR0251+aTabMDBs[E])  //STR0251 "Verificando dados na Tabela: "
    //Se preencher a arquivo Work_Capa...
    IF EICDLL(cODBC_DSI,aTabMDBs[E],aArrayChaves,aMenslog,"Work_Capa",,cWhere,.F.,.T.)
       Work_Capa->(DBGOTOP())
       Work_Capa->TIPO_MANUT:="E"
       //...exclui os registros existentes p/ incluir os novos registros
       DI500DLLSQL(aTabMDBs[E],"Work_Capa","TIPO_MANUT","E",aArrayCampos,aArrayChaves,cMenErro,.F.)
       DbSelectArea("Work_Capa")
       //ZAP
       AvZap("Work_Capa")
    ENDIF
    If !Empty(aMenslog)
       IF LEN(aMenslog) # 1 .OR. LEFT(aMenslog[1],2) # "13"
          cErro+=STR0252+aTabMDBs[E]+ENTER //STR0252 "A) Erro na verificacao se existe dados da Tabela: "
          For nCont = 1 To Len(aMenslog)
              cErro+=aMensLog[nCont]+ENTER
          Next
          cErro+=ENTER
       ENDIF
    EndIf
NEXT

oDlgProc:SetText(STR0253) //STR0253 "Lendo dados p/ gravacao da DSI..."

IncProc(STR0254) //STR0254 "Lendo dados da capa do Processo..."

SYT->(dbSeek(cFilSYT+SW6->W6_IMPORT  ))
SYQ->(dbSeek(cFilSYQ+SW6->W6_VIA_TRA ))

Work_Capa->(DBAPPEND())
Work_Capa->TIPO_MANUT:="I"
Work_Capa->CD_TIPO_NA:=val(SW6->W6_TIPODES)      //CD_TIPO_NATUREZA
Work_Capa->CD_DSI_MIC:=LEFT(SW6->W6_HAWB,LEN(Work_Capa->CD_DSI_MIC))//CD_DSI_MICRO
SET CENTURY ON
Work_Capa->DT_CRIACAO:=DTOC(ddatabase)+" "+TIME()//DT_CRIACAO
SET CENTURY OFF
//Pasta - Basicas
Work_Capa->CD_TIPO_IM:=SYT->YT_TIPO              //CD_TIPO_IMPORTADOR
Work_Capa->NR_IMPORTA:=SYT->YT_CGC               //NR_IMPORTADOR
Work_Capa->IN_REPR_LE:=(SW6->W6_CURRIER="1")     //IN_REPR_LEGAL
IF VAL(SYT->YT_TIPO) > 2
   Work_Capa->NM_IMPORTA:=SYT->YT_NOME           //NM_IMPORTADOR
   Work_Capa->NR_TEL_IMP:=SYT->YT_TEL_IMP        //NR_TEL_IMPORTADOR
   Work_Capa->ED_LOGR_IM:=SYT->YT_ENDE           //ED_LOGR_IMPORTADOR
   Work_Capa->ED_NR_IMPO:=STR(SYT->YT_NR_END,6)  //ED_NR_IMPORTADOR
   Work_Capa->ED_COMP_IM:=SYT->YT_BAIRRO         //ED_COMPL_IMPO
// Work_Capa->ED_BA_IMPO:=SYT->YT_BAIRRO         //ED_BA_IMPORTADOR
   Work_Capa->ED_NUM_IMP:=SYT->YT_CIDADE         //ED_MUN_IMPORTADOR
   Work_Capa->ED_UF_IMPO:=Alltrim(SYT->YT_ESTADO)//ED_UF_IMPORTADOR
   Work_Capa->ED_CEP_IMP:=SYT->YT_CEP            //ED_CEP_IMPORTADOR
   Work_Capa->CD_PAIS_IM:=SYT->YT_PAIS           //CD_PAIS_IMPORTADOR
ENDIF
//Pasta - Carga - 1 - inicio
Work_Capa->CD_PAIS_PR:=SW6->W6_PAISPRO           //CD_PAIS_PROC_CARGA
Work_Capa->CD_RECINTO:=SW6->W6_REC_ALF           //CD_RECINTO_ALFAND
Work_Capa->CD_SETOR_A:=SW6->W6_SETORRA           //CD_SETOR_ARMAZENAM
Work_Capa->PB_CARGA  :=SW6->W6_PESO_BR           //PB_CARGA
Work_Capa->PL_CARGA  :=SW6->W6_PESOL             //PL_CARGA
Work_Capa->CD_URF_DES:=SW6->W6_URF_DES           //CD_URF_DESPACHO
Work_Capa->NR_IDENT_C:=SW6->W6_PRCARGA           //NR_IDENT_CARGA
Work_Capa->DT_EMBARQU:=SW6->W6_DT_EMB            //DT_EMBARQU - DD/MM/AAAA
IF (cTipoVia:=LEFT(SYQ->YQ_COD_DI,1)) = "A"
   Work_Capa->CD_VIA_TRA:="10"                   //CD_VIA_TRANSP_CARGA
ELSE
   Work_Capa->CD_VIA_TRA:=STRZERO(VAL(LEFT(SYQ->YQ_COD_DI,1)),2)//CD_VIA_TRANSP_CARGA
ENDIF
IF !(cTipoVia $ "8,A")
   Work_Capa->CD_TIPO_DC:=SW6->W6_TIPOCON        //CD_TIPO_DCTO_CARGA
ENDIF
Work_Capa->NR_TERMO_E:=LEFT(SW6->W6_IDEMANI,LEN(Work_Capa->NR_TERMO_E))//NR_TERMO_ENTRADA
Work_Capa->NR_DCTO_MA:=LEFT(SW6->W6_MAWB   ,LEN(Work_Capa->NR_DCTO_MA))//NR_DCTO_CARGA_MAST
Work_Capa->NR_DCTO_HO:=LEFT(SW6->W6_HOUSE  ,LEN(Work_Capa->NR_DCTO_HO))//NR_DCTO_CARGA_HOUSE
//Pasta - Carga - 1 - fim
//Pasta - Carga - 2 - inicio
If !Empty(SW6->W6_FREMOED)
   IF SYF->(DBSEEK(cFilSYF+SW6->W6_FREMOED))
      Work_Capa->CD_MOEDA_F:=SYF->YF_COD_GI              //CD_MOEDA_FRETE
      Work_Capa->VL_TOT_FRE:=ValorFrete(SW6->W6_HAWB,,,2)//VL_TOT_FRETE_MNEG
      Work_Capa->VL_TOTAL_F:=ValorFrete(SW6->W6_HAWB,,,1)//VL_TOTAL_FRETE_MN//Real
   ENDIF
EndIf
If !Empty(SW6->W6_SEGMOED)
   IF SYF->(DBSEEK(cFilSYF+SW6->W6_SEGMOED))
      Work_Capa->CD_MOEDA_S:=SYF->YF_COD_GI //CD_MOEDA_SEGURO
      Work_Capa->VL_TOT_SEG:=SW6->W6_VL_USSE//VL_TOT_SEGURO_MNEG
      Work_Capa->VL_TOTAL_M:=SW6->W6_VLSEGMN//VL_TOTAL_SEG_MN
   ENDIF
EndIf
Work_Capa->DT_DSE_MAN:=SW6->W6_DT_DSE //DT_DSE_MANUAL
Work_Capa->CD_UL_DSE_:=SW6->W6_UL_DSE //CD_UL_DSE_MANUAL
Work_Capa->NR_DSE    :=SW6->W6_NR_DSE //NR_DSE
Work_Capa->NR_DDE    :=SW6->W6_NR_DDE //NR_DDE
Work_Capa->NR_PROCESS:=SW6->W6_NR_PROC//NR_PROCESSO_EXPO

//Pasta - Carga - 2 - fim

//Pasta - Pagamentos - Debito em Conta - inicio
Work_Capa->NR_CONTA_P:=SW6->W6_CTAPGTO
//Pasta - Pagamentos - Debito em Conta - fim

//Pasta - Complementares - inicio
Work_Capa->TX_INFO_CO:=MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3))//TX_INFO_COMPL
//Pasta - Complementares - fim

ProcRegua(nTotal)

nItem:=0
EIH->(dbSetOrder(1)) /* EIH_FILIAL+EIH_HAWB+EIH_CODIGO */
EIH->(dbSeek(cFilEIH+SW6->W6_HAWB))
DO While !EIH->(Eof()) .And.;
		 EIH->EIH_FILIAL == cFilEIH	.And.;
 		 EIH->EIH_HAWB   == SW6->W6_HAWB
   IF nCont < nTotal+1
      IncProc(STR0255) //STR0255 "Lendo dados dos Volumes do Processo..."
      nCont++
   ELSE
      ProcRegua(nTotal)
      nCont:=0
   ENDIF
   nItem++
   Work_Vol->(DBAPPEND())
   Work_Vol->TIPO_MANUT:="I"
   Work_Vol->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
   Work_Vol->NR_SEQUENC:=nItem                //NR_SEQUENCIAL
   //Pasta - Carga - 1 - Volumes - inicio
   Work_Vol->CD_TIPO_EM:=EIH->EIH_CODIGO//CD_TIPO_EMBALAGEM
   Work_Vol->QT_VOLUME_:=EIH->EIH_QTDADE//QT_VOLUME_CARGA
   //Pasta - Carga - 1 - Volumes - fim
   EIH->(DBSKIP())
ENDDO
nItem:=0
EII->(dbSetOrder(1)) /* EII_FILIAL+EII_HAWB+EII_CODIGO */
EII->(dbSeek(cFilEII+SW6->W6_HAWB))
DO While !EII->(Eof()) .And.;
         EII->EII_FILIAL == cFilEII .And.;
         EII->EII_HAWB   == SW6->W6_HAWB
   IF nCont < nTotal+1
      IncProc(STR0256) //STR0256 "Lendo dados dos Pagamentos do Processo..."
      nCont++
   ELSE
      ProcRegua(nTotal)
      nCont:=0
   ENDIF
   nItem++
   Work_Pgto->(DBAPPEND())
   Work_Pgto->TIPO_MANUT:="I"
   Work_Pgto->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
   Work_Pgto->NR_SEQUENC:=nItem                //NR_SEQUENCIAL
   //Pasta - Pagamentos - Debito em Conta - inicio
   Work_Pgto->CD_BANCO_P:=SW6->W6_BCOPGTO
   Work_Pgto->NR_AGENC_P:=SW6->W6_AGEPGTO
   Work_Pgto->CD_RECEITA:=EII->EII_CODIGO     //CD_RECEITA_PGTO
   Work_Pgto->VL_TRIBUTO:=EII->EII_VLTRIB     //VL_TRIBUTO_PAGO
   //Pasta - Pagamentos - Debito em Conta - fim
/*
//{ "CD_DSI_MICRO",       "CD_DSI_MIC", "" },;
//{ "NR_SEQUENCIAL",      "NR_SEQUENC", "" },;
//{ "CD_RECEITA_PGTO",    "CD_RECEITA", "" },;
//{ "CD_BANCO_PGTO_TRIB", "CD_BANCO_P", "" },;
//{ "NR_AGENC_PGTO_TRIB", "NR_AGENC_P", "" },;
//{ "VL_TRIBUTO_PAGO",    "VL_TRIBUTO", "" },;
{ "DT_PGTO_TRIBUTO",    "DT_PGTO_TR", "" },;
{ "VL_MULTA_PGTO_TRIB", "VL_MULTA_P", "" },;
{ "VL_JUROS_PGTO_TRIB", "VL_JUROS_P", "" };*/

   EII->(DBSKIP())
ENDDO

/*
//{ "CD_DSI_MICRO",       "CD_DSI_MIC", { |X| TRB->TIPO_MANUT := "I", X } },;
//{ "DT_CRIACAO",         "DT_CRIACAO", "" },;
{ "CD_ORIGEM_DSI",      "CD_ORIGEM_", "" },;
{ "NR_DECL_IMP_PROT",   "NR_DECL_IM", "" },;
{ "CD_MOTIVO_TRANS",    "CD_MOTIVO_", "" },;
{ "DT_TRANSMISSAO",     "DT_TRANSMI", "DD/MM/AAAA" },;
 "NR_DECL_SIMPL_IMP",  "NR_DECL_SI", "" },;
{ "DT_REGISTRO_DSI",    "DT_REGISTR", "DD/MM/AAAA" },;
{ "HO_REGISTRO_DSI",    "HO_REGISTR", "DD/MM/AAAA" },;
{ "NR_SEQ_RETIFICACAO", "NR_SEQ_RET", "" },;
{ "DT_SEQ_RETIFICACAO", "DT_SEQ_RET", "DD/MM/AAAA" },;
{ "HO_SEQ_RETIFICACAO", "HO_SEQ_RET", "DD/MM/AAAA" },;
{ "IN_BLOQUEIO_RETIF",  "IN_BLOQUEI", "" },;
{ "CD_TIPO_NATUREZA",   "CD_TIPO_NA", "" },;
{ "QT_ADICAO_DSI",      "QT_ADICAO_", "" },;
//{ "NR_IMPORTADOR",      "NR_IMPORTA", "" },;
//{ "NM_IMPORTADOR",      "NM_IMPORTA", "" },;
//{ "NR_TEL_IMPORTADOR",  "NR_TEL_IMP", "" },;
//{ "ED_LOGR_IMPORTADOR", "ED_LOGR_IM", "" },;
//{ "ED_NR_IMPORTADOR",   "ED_NR_IMPO", "" },;
//{ "ED_COMPL_IMPO",      "ED_COMP_IM", "" },;
//{ "ED_BA_IMPORTADOR",   "ED_BA_IMPO", "" },;
//{ "ED_MUN_IMPORTADOR",  "ED_NUM_IMP", "" },;
//{ "ED_UF_IMPORTADOR",   "ED_UF_IMPO", "" },;
//{ "ED_CEP_IMPORTADOR",  "ED_CEP_IMP", "" },;
//{ "CD_PAIS_IMPORTADOR", "CD_PAIS_IM", "" },;
//{ "IN_REPR_LEGAL",      "IN_REPR_LE", "" },;
{ "NR_REPR_LEGAL",      "NR_REPR_LE", "" },;
{ "NR_CPF_USUARIO",     "NR_CPF_USA", "" },;
//{ "CD_URF_DESPACHO",    "CD_URF_DES", "" },;
//{ "CD_PAIS_PROC_CARGA", "CD_PAIS_PR", "" },;
//{ "CD_VIA_TRANSP_CARGA","CD_VIA_TRA", "" },;
//{ "NR_TERMO_ENTRADA",   "NR_TERMO_E", "" },;
//{ "CD_TIPO_DCTO_CARGA", "CD_TIPO_DC", "" },;
//{ "NR_DCTO_CARGA_HOUSE","NR_DCTO_HO", "" },;
//{ "NR_DCTO_CARGA_MAST", "NR_DCTO_MA", "" },;
//{ "NR_IDENT_CARGA",     "NR_IDENT_C", "" },;
//{ "DT_EMBARQUE",        "DT_EMBARQU", "DD/MM/AAAA" },;
{ "DT_EMISSAO_CONHEC",  "DT_EMISSAO", "DD/MM/AAAA" },;
//{ "PB_CARGA",           "PB_CARGA",   "" },;
//{ "PL_CARGA",           "PL_CARGA",   "" },;
//{ "CD_RECINTO_ALFAND",  "CD_RECINTO", "" },;
//{ "CD_SETOR_ARMAZENAM", "CD_SETOR_A", "" },;
//{ "CD_MOEDA_FRETE",     "CD_MOEDA_F", "" },;
//{ "VL_TOT_FRETE_MNEG",  "VL_TOT_FRE", "" },;
//{ "VL_TOTAL_FRETE_MN",  "VL_TOTAL_F", "" },;
//{ "CD_MOEDA_SEGURO",    "CD_MOEDA_S", "" },;
//{ "VL_TOT_SEGURO_MNEG", "VL_TOT_SEG", "" },;
//{ "VL_TOTAL_SEG_MN",    "VL_TOTAL_M", "" },;
{ "VL_TOTAL_SEG_DOLAR", "VL_TOTAL_D", "" },;
//{ "VL_TOTAL_MLE_MN",    "VL_TOTAL_N", "" },;
{ "VL_TOTAL_MLE_DOLAR", "VL_TOTAL_O", "" },;
{ "VL_TOTAL_MLD_MN",    "VL_TOTAL__", "" },;
//{ "DT_DSE_MANUAL",      "DT_DSE_MAN", "DD/MM/AAAA" },;
//{ "CD_UL_DSE_MANUAL",   "CD_UL_DSE_", "" },;
//{ "NR_DSE",             "NR_DSE",     "" },;
//{ "NR_DDE",             "NR_DDE",     "" },;
//{ "NR_PROCESSO_EXPO",   "NR_PROCESS", "" },;
{ "VL_TOTAL_II_CALC",   "VL_TOTAL_I", "" },;
{ "VL_TOTAL_IPI_CALC",  "VL_TOTAL_P", "" },;
{ "VL_TOTAL_II_A_REC",  "VL_TOTAL_A", "" },;
{ "VL_TOTAL_IPI_A_REC", "VL_TOTAL_R", "" },;
{ "VL_TOT_TRIB_A_REC",  "VL_TOT_TRI", "" },;
{ "CD_TIPO_PGTO_TRIB",  "CD_TIPO_PG", "" },;
//{ "NR_CONTA_PGTO_TRIB", "NR_CONTA_P", "" },;
//{ "TX_INFO_COMPL",      "TX_INFO_CO", "" },;
{ "IN_SERVIDOR_UL",     "IN_SERVIDO", "" };
*/

IncProc(STR0257) //STR0257 "Lendo dados dos Itens do Processo..."
lGravaBag:=.T.
EIJ->(dbSetOrder(1))
SW8->(dbSetOrder(4))
SW8->(dbSeek(cFilSW8+SW6->W6_HAWB))
nItem:=0
DO While !SW8->(Eof()) .AND.;
          SW8->W8_FILIAL == cFilSW8 .And.;
          SW8->W8_HAWB   == SW6->W6_HAWB

   IF nCont < nTotal+1
      IncProc(STR0258+SW8->W8_COD_I) //STR0258 "Lendo dados do Item: "
      nCont++
   ELSE
      ProcRegua(nTotal)
      nCont:=0
   ENDIF

   EIJ->(dbSeek(cFilEIJ+SW6->W6_HAWB+SW8->W8_ADICAO))
   SYD->(dbSeek(cFilSYD+SW8->W8_TEC))//EIJ->EIJ_TEC))
   EIL->(dbSeek(cFilEIL+EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO))
   SA2->(dbSeek(cFilSA2+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")))
   SAH->(DBSEEK(cFilSAH+SYD->YD_UNID))//EIJ->EIJ_UM_EST))
   SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
   SW2->(dbSeek(cFilSW2+SW7->W7_PO_NUM))
   SYF->(DBSEEK(cFilSYF+SW2->W2_MOEDA))
   SB1->(DBSEEK(cFilSB1+SW8->W8_COD_I))
   cUMde:=BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN,SW8->W8_CC+SW8->W8_SI_NUM, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))

   lGravaBag:=.T.
   IF SW6->W6_TIPODES == "10" .AND. EIJ->EIJ_REGTRI $ "2,3"
      lGravaBag := .F.
   ENDIF

   nItem++
   Work_Item->(DBAPPEND())
   Work_Item->TIPO_MANUT:="I"
   Work_Item->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
   //Pasta Bens - 1 - inicio
   Work_Item->NR_BEM    :=nItem                //NR_BEM
   Work_Item->CD_REG_TRI:=EIJ->EIJ_REGTRI      //CD_REGIME_TRIBUTAR
   Work_Item->CD_FUND_LE:=EIJ->EIJ_FUNREG      //CD_FUND_LEG_REGIME
   IF SW6->W6_TIPODES # "10"
      Work_Item->CD_MOTIVO_:=EIJ->EIJ_MOTADI   //CD_MOTIVO_FUND_LEG
   ENDIF
   Work_Item->IN_CLASSIF:=VAL(EIJ->EIJ_TEC_CL) //IN_CLASSIFICACAO
   IF lGravaBag
      IF EIJ->EIJ_TEC_CL = "0"
         Work_Item->CD_MERCADO:=SW8->W8_TEC              //CD_MERCADORIA //EIJ->EIJ_TEC
      ELSEIF EIJ->EIJ_TEC_CL = "1"
         Work_Item->CD_MERCADO:=SUBSTR(SW8->W8_TEC,1,4)  //CD_MERCADORIA //EIJ->EIJ_TEC
      ENDIF
      Work_Item->NM_DESCRIC:=SYD->YD_DESC_P              //NM_DESCRICAO_MERC
      Work_Item->IN_MERCOSU:=(EIJ->EIJ_MERCOS="1")       //IN_MERCOSUL
      Work_Item->CD_PAIS_OR:=SA2->A2_PAIS                //CD_PAIS_ORIG_MERC
      IF SW6->W6_TIPODES # "10" .AND. (SW6->W6_TIPODES # "09" .OR. EIJ->EIJ_TEC_CL = "0")
         Work_Item->CD_DESTAQU:=EIL->EIL_DESTAQ             //CD_DESTAQUE_NCM
         Work_Item->NM_UN_MEDE:=SUBSTR(SAH->AH_DESCPO,1,20) //NM_UN_MEDID_ESTAT
         Work_Item->QT_UN_ESTA:=EIJ->EIJ_QT_EST             //QT_UN_ESTATISTICA
      ENDIF
      SAH->(DBSEEK(cFilSAH+cUMde))
      Work_Item->NM_UN_MEDC:=SUBSTR(SAH->AH_DESCPO,1,20) //NM_UN_MEDID_COMERC
      Work_Item->QT_MER_UN_:=SW8->W8_QTDE                //QT_MERC_UN_COMERC
      Work_Item->IN_MATERIA:=(EIJ->EIJ_MATUSA="1")       //IN_MATERIAL_USADO
      Work_Item->CD_MOEDA_N:=SYF->YF_COD_GI              //CD_MOEDA_NEGOCIADA
      Work_Item->VL_UNID_LO:=(SW8->W8_VLMLE/SW8->W8_QTDE)//VL_UNID_LOC_EMB
      Work_Item->VL_MERC_LO:=SW8->W8_VLMLE               //VL_MERC_LOC_EMB
   ENDIF
   Work_Item->PL_BEM    :=(SW8->W8_QTDE*SW7->W7_PESO) //PL_BEM
   //Pasta Bens - 1 - fim
   //Pasta Bens - 3 - Base de Calculo - inicio
   Work_Item->VL_MERC_EB:=SW8->W8_FOBTOTR             //VL_MERC_EMB_MN
   IF lGravaBag
      Work_Item->VL_FRETE_N:=SW8->W8_VLFREMN             //VL_FRETE_MERC_MN
      Work_Item->VL_SEG_MMN:=SW8->W8_VLSEGMN             //VL_SEG_MERC_MN
      Work_Item->VL_ADUANEI:=Work_Item->VL_MERC_EB+;     //VL_ADUANEIRO
                             Work_Item->VL_FRETE_N+;
                             Work_Item->VL_SEG_MMN
   ENDIF
   //Pasta Bens - 3 - Base de Calculo - fim
   //Pasta Bens - 2 - Especificacao - inicio
   mMemo   := ' '
   IF !EMPTY(SW8->W8_DESC_DI)
      mMemo:= MSMM(SW8->W8_DESC_DI,nTamDesc)
   ENDIF
   IF EMPTY(mMemo)
      mMemo:= MSMM(SB1->B1_DESC_GI,nTamIMemo)
   ENDIF
   Work_Item->TX_DESC_DE:=mMemo//TX_DESC_DET_MERC
   //Pasta Bens - 2 - Especificacao - fim

   IF lAUTPCDI  // Bete - DSI - Alimenta na Work dos itens, os novos cpos referente a PIS/COFINS
      nAliqICMS := SYD->YD_ICMS_RE

      IF lQbgOperaca .AND. !EMPTY(SW8->W8_OPERACA)
         SWZ->(DBSETORDER(2))
         IF SWZ->(DBSEEK(xFilial("SWZ")+SW8->W8_OPERACA))
            IF EMPTY(SWZ->WZ_RED_CTE)
               nAliqICMS:= SWZ->WZ_AL_ICMS
            ELSE
               nAliqICMS:= SWZ->WZ_RED_CTE
            ENDIF
         ENDIF
      ENDIF
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DSI_BENS_PC"),)
      Work_Item->VL_ALIQ_IC:=nAliqICMS
      Work_Item->CD_REGTRIP:=SW8->W8_REG_PC
      Work_Item->CD_FUNLEGP:=SW8->W8_FUN_PC
   ENDIF

   nTot_VLMLERS+=SW8->W8_FOBTOTR

/*
//{ "CD_DSI_MICRO",       "CD_DSI_MIC", { |X| TRB->TIPO_MANUT := "I", X } },;
//{ "NR_BEM",             "NR_BEM",     "" },;
//{ "NR_OPER_TRAT_PREV",  "NR_OPER_TR", "" },;
//{ "CD_REGIME_TRIBUTAR", "CD_REG_TRI", "" },;
//{ "CD_FUND_LEG_REGIME", "CD_FUND_LE", "" },;
//{ "CD_MOTIVO_FUND_LEG", "CD_MOTIVO_", "" },;
//{ "IN_CLASSIFICACAO",   "IN_CLASSIF", "" },;
//{ "CD_MERCADORIA",      "CD_MERCADO", "" },;
//{ "CD_DESTAQUE_NCM",    "CD_DESTAQU", "" },;
//{ "NM_DESCRICAO_MERC",  "NM_DESCRIC", "" },;
//{ "CD_PAIS_ORIG_MERC",  "CD_PAIS_OR", "" },;
//{ "IN_MERCOSUL",        "IN_MERCOSU", "" },;
//{ "IN_MATERIAL_USADO",  "IN_MATERIA", "" },;
//{ "NM_UN_MEDID_ESTAT",  "NM_UN_MEDE", "" },;
//{ "QT_UN_ESTATISTICA",  "QT_UN_ESTA", "" },;
//{ "NM_UN_MEDID_COMERC", "NM_UN_MEDC", "" },;
//{ "QT_MERC_UN_COMERC",  "QT_MER_UN_", "" },;
//{ "PB_BEM",             "PB_BEM",     "" },;
//{ "PL_BEM",             "PL_BEM",     "" },;
//{ "VL_UNID_LOC_EMB",    "VL_UNID_LO", "" },;
//{ "VL_MERC_LOC_EMB",    "VL_MERC_LO", "" },;
//{ "CD_MOEDA_NEGOCIADA", "CD_MOEDA_N", "" },;
//{ "VL_ADUANEIRO",       "VL_ADUANEI", "" },;
//{ "VL_FRETE_MERC_MNEG", "VL_FRETE_M", "" },;
//{ "CD_MD_FRETE_MERC",   "CD_MD_FRET", "" },;
//{ "VL_FRETE_MERC_MN",   "VL_FRETE_N", "" },;
//{ "VL_SEG_MERC_DOLAR",  "VL_SEG_MER", "" },;
//{ "VL_SEG_MERC_MN",     "VL_SEG_MMN", "" },;
//{ "VL_MERC_EMB_DOLAR",  "VL_MERC_EM", "" },;
//{ "VL_MERC_EMB_MN",     "VL_MERC_EB", "" },;
//{ "TX_DESC_DET_MERC",   "TX_DESC_DE", "" }*/

   Work_Tri->(DBAPPEND())
   Work_Tri->TIPO_MANUT:="I"
   Work_Tri->CD_DSI_MIC:=Work_Item->CD_DSI_MIC  //CD_DSI_MICRO
   Work_Tri->NR_BEM    :=Work_Item->NR_BEM      //NR_BEM

   //Pasta Bens - 3 - I.I. - inicio
   IF EIJ->EIJ_REGTRI # "2" // Imunidade
      Work_Tri->VL_BASE_CI:=Work_Item->VL_ADUANEI  //VL_BASE_CALC_ADVAL_II
      Work_Tri->PC_ALIQ_NI:=EIJ->EIJ_ALI_II        //PC_ALIQ_NORM_ADVAL_II
      Work_Tri->VL_IMPOSTI:=SW8->W8_VLDEVII        //VL_IMPOSTO_DEVIDO_II
      Work_Tri->VL_IPT_A_I:=SW8->W8_VLII           //VL_IPT_A_RECOLHER_II
   ENDIF
   //Pasta Bens - 3 - I.I. - fim
   //Pasta Bens - 3 - I.P.I. - inicio
   IF !EIJ->EIJ_REGTRI $ "2,7" // Imunidade,Tributacao simples
       Work_Tri->VL_BASE_CP:=Work_Item->VL_ADUANEI+;//VL_BASE_CALC_ADVAL_IPI
                             SW8->W8_VLII
       Work_Tri->PC_ALIQ_NP:=EIJ->EIJ_ALAIPI        //PC_ALIQ_NORM_ADVAL_IPI
       Work_Tri->VL_IMPOSTP:=SW8->W8_VLDEIPI        //VL_IMPOSTO_DEVIDO_IPI
       Work_Tri->VL_IPT_A_P:=SW8->W8_VLIPI          //VL_IPT_A_RECOLHER_IPI
   ENDIF
   //Pasta Bens - 3 - I.P.I. - fim

   IF lAUTPCDI  // Bete - DSI - Alimenta na Work dos tributos, os novos cpos referente a PIS/COFINS
      Work_Tri->VL_BASE_PC:=SW8->W8_BASPIS
      Work_Tri->PC_ALIADPI:=SW8->W8_PERPIS
      Work_Tri->VL_ALIESPI:=SW8->W8_VLUPIS
      Work_Tri->NM_UNIESPI:=EIJ->EIJ_UNUPIS
      Work_Tri->QT_MERESPI:=EIJ->EIJ_QTUPIS
      IF EIJ->EIJ_TPAPIS = "1"
         Work_Tri->VL_PISCALC:= SW8->W8_BASPIS * (SW8->W8_PERPIS/100)
      ELSE
         Work_Tri->VL_PISCALC:= SW8->W8_VLUPIS * EIJ->EIJ_QTUPIS
      ENDIF
      Work_Tri->VL_PISDEVI:=SW8->W8_VLDEPIS
      Work_Tri->VL_PISRECO:=SW8->W8_VLRPIS

      Work_Tri->PC_ALIADCO:=SW8->W8_PERCOF
      Work_Tri->VL_ALIESCO:=SW8->W8_VLUCOF
      Work_Tri->NM_UNIESCO:=EIJ->EIJ_UNUCOF
      Work_Tri->QT_MERESCO:=EIJ->EIJ_QTUCOF
      IF EIJ->EIJ_TPACOF = "1"
         Work_Tri->VL_COFCALC:= SW8->W8_BASCOF * (SW8->W8_PERCOF/100)
      ELSE
         Work_Tri->VL_COFCALC:= SW8->W8_VLUCOF * EIJ->EIJ_QTUCOF
      ENDIF
      Work_Tri->VL_COFDEVI:=SW8->W8_VLDECOF
      Work_Tri->VL_COFRECO:=SW8->W8_VLRCOF
   ENDIF

   nTotal_II +=SW8->W8_VLII
   nTotAL_IPI+=SW8->W8_VLIPI
   IF lAUTPCDI  // Bete - DSI - acumula os valores dos itens dos cpos novos ref a PIS/COFINS
      nTotal_PIS += SW8->W8_VLRPIS
      nTotal_COF += SW8->W8_VLRCOF
      IF EIJ->EIJ_TPAPIS = "1"
         nTotC_PIS += (SW8->W8_BASPIS * (SW8->W8_PERPIS/100) )
      ELSE
         nTotC_PIS += SW8->W8_VLUPIS * EIJ->EIJ_QTUPIS
      ENDIF
      IF EIJ->EIJ_TPACOF = "1"
         nTotC_COF += (SW8->W8_BASCOF * (SW8->W8_PERCOF/100) )
      ELSE
         nTotC_COF += SW8->W8_VLUCOF * EIJ->EIJ_QTUCOF
      ENDIF
   ENDIF
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRV_SW8_DSI"),)      // LDR - 21/05/04
   SW8->(DBSKIP())

ENDDO
IncProc(STR0259) //STR0259 "Lendo dados da capa do Processo..."
//Pasta - Bens - Rodape - inicio
Work_Capa->VL_TOTAL_N:=nTot_VLMLERS        //VL_TOTAL_MLE_MN
//Pasta - Bens - Rodape - fim
//Pasta - Pagamento - inicio
Work_Capa->VL_TOTAL_A:=nTotal_II           //VL_TOTAL_II_A_REC
Work_Capa->VL_TOTAL_R:=nTotAL_IPI          //VL_TOTAL_IPI_A_REC
Work_Capa->VL_TOT_TRI:=nTotAL_II+nTotAL_IPI//VL_TOT_TRIB_A_REC
IF lAUTPCDI  // Bete - DSI - Alimenta na Work geral, os novos cpos referente a PIS/COFINS
   Work_Capa->VL_TOTPISC:=nTotC_PIS
   Work_Capa->VL_TOTCOFC:=nTotC_COF
   Work_Capa->VL_TOTPISR:=nTotal_PIS
   Work_Capa->VL_TOTCOFR:=nTotal_COF
ENDIF
//Pasta - Pagamento - fim

cNomeNew:=SW6->W6_HAWB
cNomeNew:=STRTRAN(cNomeNew,"\","")
cNomeNew:=STRTRAN(cNomeNew,"/","")
cNomeNew:=STRTRAN(cNomeNew,".","")
cNomeNew:=STRTRAN(cNomeNew,":","")
cNomeNew:=STRTRAN(cNomeNew,"*","")
cNomeNew:=STRTRAN(cNomeNew,"?","")
cNomeNew:=STRTRAN(cNomeNew,"'","")
cNomeNew:=STRTRAN(cNomeNew,'"',"")
cNomeNew:=STRTRAN(cNomeNew,">","")
cNomeNew:=STRTRAN(cNomeNew,"<","")
cNomeNew:=STRTRAN(cNomeNew,"|","")
cNomeNew:=ALLTRIM(cNomeNew)+SUBSTR(E_Create(,.F.),3)
cArqTxt :=ALLTRIM(cNomeNew)+".LOG"

If File(cArqTxt)
   FErase(cArqTxt)
EndIf

DI500GrvMDB()

IF !EMPTY(cErro)

   nHdl:=EasyCreateFile(cArqTxt)
   If nHdl < 0
      MsgStop(STR0260+cArqTxt,STR0215)  // STR0260 "Erro na criação do arquivo: " //STR0215	"Atenção"
      cArqTxt:=''
   ELSE
      FWrite(nHdl,cErro)
      FClose(nHdl)
   EndIf
   aButtons:={}
   Aadd(aButtons,{"NOTE",{|| nSair:=1,oDLGDescr:End() },STR0261, STR0262}) // STR0262 "Analisar" //STR0261 "Analisar dados enviados"

   DEFINE FONT oFont NAME "Courier New" SIZE 0,15
   DO WHILE .T.
      nSair:=0
      DEFINE MSDIALOG oDLGDescr TITLE STR0263 + SW6->W6_HAWB; //STR0263 "Erros na gravacao da DSI, Processo: "
          From 00,00 To 30,70 OF oMainWnd

          oDLGDescr:SetFont(oFont)

          @17,2 GET oGetMemo VAR cErro MEMO HSCROLL SIZE 275,210 OF oDLGDescr PIXEL
          oGetMemo:Align:= CONTROL_ALIGN_ALLCLIENT

      ACTIVATE MSDIALOG oDLGDescr ON INIT DI500EnchoiceBar(oDLGDescr,,{||oDLGDescr:End()},.F.,aButtons) CENTERED
      IF nSair = 0
         EXIT
      ENDIF
      DI500Analise()
   ENDDO
ENDIF

oDlgProc:SetText(STR0264+cArqTxt) //STR0264 "Consulte o arquivo: "
IncProc(STR0265) //STR0265 "Gravando LOG do Processo"
lRecL:=.T.//!EIR->(DBSEEK(xFilial("EIR")+SW6->W6_HAWB))
EIR->(RecLock("EIR",lRecL))
EIR->EIR_FILIAL := xFilial("EIR")
EIR->EIR_HAWB   := SW6->W6_HAWB
EIR->EIR_DATA   := dDataBase
EIR->EIR_HORA   := Time()
EIR->EIR_USUARI := cUserName
EIR->EIR_ARQUIV := IF(!EMPTY(cErro),cArqTxt,STR0266) //STR0266 "Nao houve erros."
EIR->(MsUnlock())

MsgInfo(STR0267) //STR0267 "Fim do Processamento."

RETURN .T.

*-----------------------------------*
FUNCTION DI500GrvMDB()
*-----------------------------------*
Local aArrayCampos, aArrayChaves

aArrayCampos :={;
{ "CD_TIPO_NATUREZA",   "CD_TIPO_NA", "", "" },;
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "NULL" },;
{ "DT_CRIACAO",         "DT_CRIACAO", "", "NULL" },;
{ "IN_REPR_LEGAL",      "IN_REPR_LE", "", "" },;
{ "CD_TIPO_IMPORTADOR", "CD_TIPO_IM", "", "" },;
{ "NR_IMPORTADOR",      "NR_IMPORTA", "", "" },;
{ "CD_URF_DESPACHO",    "CD_URF_DES", "", "NULL" },;
{ "CD_PAIS_PROC_CARGA", "CD_PAIS_PR", "", "NULL" },;
{ "CD_VIA_TRANSP_CARGA","CD_VIA_TRA", "", "" },;
{ "NR_TERMO_ENTRADA",   "NR_TERMO_E", "", "NULL" },;
{ "CD_TIPO_DCTO_CARGA", "CD_TIPO_DC", "", "" },;
{ "NR_DCTO_CARGA_HOUSE","NR_DCTO_HO", "", "" },;
{ "NR_DCTO_CARGA_MAST", "NR_DCTO_MA", "", "" },;
{ "NR_IDENT_CARGA",     "NR_IDENT_C", "", "NULL" },;
{ "DT_EMBARQUE",        "DT_EMBARQU", "DD/MM/AAAA", "NULL" },;
{ "PB_CARGA",           "PB_CARGA",   "", "" },;
{ "PL_CARGA",           "PL_CARGA",   "", "" },;
{ "CD_RECINTO_ALFAND",  "CD_RECINTO", "", "" },;
{ "CD_SETOR_ARMAZENAM", "CD_SETOR_A", "", "" },;
{ "CD_MOEDA_FRETE",     "CD_MOEDA_F", "", "NULL" },;
{ "VL_TOT_FRETE_MNEG",  "VL_TOT_FRE", "", "" },;
{ "VL_TOTAL_FRETE_MN",  "VL_TOTAL_F", "", "" },;
{ "CD_MOEDA_SEGURO",    "CD_MOEDA_S", "", "NULL" },;
{ "VL_TOT_SEGURO_MNEG", "VL_TOT_SEG", "", "" },;
{ "VL_TOTAL_SEG_MN",    "VL_TOTAL_M", "", "" },;
{ "DT_DSE_MANUAL",      "DT_DSE_MAN", "DD/MM/AAAA", "NULL" },;
{ "CD_UL_DSE_MANUAL",   "CD_UL_DSE_", "", "NULL" },;
{ "NR_DSE",             "NR_DSE",     "", "NULL" },;
{ "NR_DDE",             "NR_DDE",     "", "NULL" },;
{ "NR_PROCESSO_EXPO",   "NR_PROCESS", "", "NULL" },;
{ "VL_TOTAL_II_A_REC",  "VL_TOTAL_A", "", "" },;
{ "VL_TOTAL_IPI_A_REC", "VL_TOTAL_R", "", "" },;
{ "VL_TOTAL_MLE_MN",    "VL_TOTAL_N", "", "" },;
{ "VL_TOT_TRIB_A_REC",  "VL_TOT_TRI", "", "" },;
{ "NR_CONTA_PGTO_TRIB", "NR_CONTA_P", "", "NULL" },; // Validacao como NULL
{ "TX_INFO_COMPL",      "TX_INFO_CO", "", "" }}  // Memo
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aArrayCampos, { "VL_TOTAL_PIS_CALC"    , "VL_TOTPISC", "", "" })
   AADD(aArrayCampos, { "VL_TOTAL_COFINS_CALC" , "VL_TOTCOFC", "", "" })
   AADD(aArrayCampos, { "VL_TOTAL_PIS_A_REC"   , "VL_TOTPISR", "", "" })
   AADD(aArrayCampos, { "VL_TOTAL_COFINS_A_REC", "VL_TOTCOFR", "", "" })
ENDIF


/*
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "" },;
{ "DT_CRIACAO",         "DT_CRIACAO", "", "NULL" },;
{ "CD_ORIGEM_DSI",      "CD_ORIGEM_", "", "" },;
{ "NR_DECL_IMP_PROT",   "NR_DECL_IM", "", "NULL" },;
{ "CD_MOTIVO_TRANS",    "CD_MOTIVO_", "", "" },;
{ "DT_TRANSMISSAO",     "DT_TRANSMI", "DD/MM/AAAA", "NULL" },;
{ "NR_DECL_SIMPL_IMP",  "NR_DECL_SI", "", "NULL" },; // Validacao como NULL
{ "DT_REGISTRO_DSI",    "DT_REGISTR", "DD/MM/AAAA", "NULL" },;
{ "HO_REGISTRO_DSI",    "HO_REGISTR", "DD/MM/AAAA", "NULL" },;
{ "NR_SEQ_RETIFICACAO", "NR_SEQ_RET", "", "NULL" },;
{ "DT_SEQ_RETIFICACAO", "DT_SEQ_RET", "DD/MM/AAAA", "NULL" },;
{ "HO_SEQ_RETIFICACAO", "HO_SEQ_RET", "DD/MM/AAAA", "NULL" },;
{ "IN_BLOQUEIO_RETIF",  "IN_BLOQUEI", "", "" },;
{ "CD_TIPO_NATUREZA",   "CD_TIPO_NA", "", "" },;
{ "QT_ADICAO_DSI",      "QT_ADICAO_", "", "" },;
{ "CD_TIPO_IMPORTADOR", "CD_TIPO_IM", "", "" },;
{ "NR_IMPORTADOR",      "NR_IMPORTA", "", "" },;
{ "NM_IMPORTADOR",      "NM_IMPORTA", "", "NULL" },;
{ "NR_TEL_IMPORTADOR",  "NR_TEL_IMP", "", "NULL" },;
{ "ED_LOGR_IMPORTADOR", "ED_LOGR_IM", "", "NULL" },;
{ "ED_NR_IMPORTADOR",   "ED_NR_IMPO", "", "NULL" },;
{ "ED_COMPL_IMPO",      "ED_COMP_IM", "", "NULL" },;
{ "ED_BA_IMPORTADOR",   "ED_BA_IMPO", "", "NULL" },;
{ "ED_MUN_IMPORTADOR",  "ED_NUM_IMP", "", "NULL" },;
{ "ED_UF_IMPORTADOR",   "ED_UF_IMPO", "", "NULL" },;
{ "ED_CEP_IMPORTADOR",  "ED_CEP_IMP", "", "NULL" },;
{ "CD_PAIS_IMPORTADOR", "CD_PAIS_IM", "", "NULL" },;
{ "IN_REPR_LEGAL",      "IN_REPR_LE", "", "" },;
{ "NR_REPR_LEGAL",      "NR_REPR_LE", "", "NULL" },;
{ "NR_CPF_USUARIO",     "NR_CPF_USA", "", "NULL" },;
{ "CD_URF_DESPACHO",    "CD_URF_DES", "", "NULL" },;
{ "CD_PAIS_PROC_CARGA", "CD_PAIS_PR", "", "NULL" },;
{ "CD_VIA_TRANSP_CARGA","CD_VIA_TRA", "", "" },;
{ "NR_TERMO_ENTRADA",   "NR_TERMO_E", "", "NULL" },;
{ "CD_TIPO_DCTO_CARGA", "CD_TIPO_DC", "", "" },;
{ "NR_DCTO_CARGA_HOUSE","NR_DCTO_HO", "", "NULL" },;
{ "NR_DCTO_CARGA_MAST", "NR_DCTO_MA", "", "NULL" },;
{ "NR_IDENT_CARGA",     "NR_IDENT_C", "", "NULL" },;
{ "DT_EMBARQUE",        "DT_EMBARQU", "DD/MM/AAAA", "NULL" },;
{ "DT_EMISSAO_CONHEC",  "DT_EMISSAO", "DD/MM/AAAA", "NULL" },;
{ "PB_CARGA",           "PB_CARGA",   "", "" },;
{ "PL_CARGA",           "PL_CARGA",   "", "" },;
{ "CD_RECINTO_ALFAND",  "CD_RECINTO", "", "" },;
{ "CD_SETOR_ARMAZENAM", "CD_SETOR_A", "", "" },;
{ "CD_MOEDA_FRETE",     "CD_MOEDA_F", "", "NULL" },;
{ "VL_TOT_FRETE_MNEG",  "VL_TOT_FRE", "", "" },;
{ "VL_TOTAL_FRETE_MN",  "VL_TOTAL_F", "", "" },;
{ "CD_MOEDA_SEGURO",    "CD_MOEDA_S", "", "NULL" },;
{ "VL_TOT_SEGURO_MNEG", "VL_TOT_SEG", "", "" },;
{ "VL_TOTAL_SEG_MN",    "VL_TOTAL_M", "", "" },;
{ "VL_TOTAL_SEG_DOLAR", "VL_TOTAL_D", "", "" },;
{ "VL_TOTAL_MLE_MN",    "VL_TOTAL_N", "", "" },;
{ "VL_TOTAL_MLE_DOLAR", "VL_TOTAL_O", "", "" },;
{ "VL_TOTAL_MLD_MN",    "VL_TOTAL__", "", "" },;
{ "DT_DSE_MANUAL",      "DT_DSE_MAN", "DD/MM/AAAA", "NULL" },;
{ "CD_UL_DSE_MANUAL",   "CD_UL_DSE_", "", "NULL" },;
{ "NR_DSE",             "NR_DSE",     "", "NULL" },;
{ "NR_DDE",             "NR_DDE",     "", "NULL" },;
{ "NR_PROCESSO_EXPO",   "NR_PROCESS", "", "NULL" },;
{ "VL_TOTAL_II_CALC",   "VL_TOTAL_I", "", "" },;
{ "VL_TOTAL_IPI_CALC",  "VL_TOTAL_P", "", "" },;
{ "VL_TOTAL_II_A_REC",  "VL_TOTAL_A", "", "" },;
{ "VL_TOTAL_IPI_A_REC", "VL_TOTAL_R", "", "" },;
{ "VL_TOT_TRIB_A_REC",  "VL_TOT_TRI", "", "" },;
{ "CD_TIPO_PGTO_TRIB",  "CD_TIPO_PG", "", "" },;
{ "NR_CONTA_PGTO_TRIB", "NR_CONTA_P", "", "NULL" },; // Validacao como NULL
{ "TX_INFO_COMPL",      "TX_INFO_CO", "", "" },; // Memo
{ "IN_SERVIDOR_UL",     "IN_SERVIDO", "", "" };*/

aArrayChaves := { { "CD_DSI_MICRO", "CD_DSI_MIC", "", "" } }

cMenErro:=STR0268+ENTER //STR0268 "B) Erros na Gravacao da capa da DSI: "

oDlgProc:SetText(STR0269) //STR0269 "Gravando dados da capa da DSI..."

DI500DLLSQL("DSI_DADOS_GERAIS","WORK_CAPA","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

aArrayCampos :={;
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "" },;
{ "NR_BEM",             "NR_BEM",     "", "" },;
{ "CD_REGIME_TRIBUTAR", "CD_REG_TRI", "", "" },;
{ "CD_FUND_LEG_REGIME", "CD_FUND_LE", "", "NULL" },;
{ "CD_MOTIVO_FUND_LEG", "CD_MOTIVO_", "", "NULL" },;
{ "IN_CLASSIFICACAO",   "IN_CLASSIF", "", "" },;
{ "CD_MERCADORIA",      "CD_MERCADO", "", "NULL" },;
{ "CD_DESTAQUE_NCM",    "CD_DESTAQU", "", "NULL" },;
{ "NM_DESCRICAO_MERC",  "NM_DESCRIC", "", "NULL" },;
{ "CD_PAIS_ORIG_MERC",  "CD_PAIS_OR", "", "NULL" },;
{ "IN_MERCOSUL",        "IN_MERCOSU", "", "" },;
{ "IN_MATERIAL_USADO",  "IN_MATERIA", "", "" },;
{ "NM_UN_MEDID_ESTAT",  "NM_UN_MEDE", "", "NULL" },;
{ "QT_UN_ESTATISTICA",  "QT_UN_ESTA", "", "" },;
{ "NM_UN_MEDID_COMERC", "NM_UN_MEDC", "", "" },;
{ "QT_MERC_UN_COMERC",  "QT_MER_UN_", "", "" },;
{ "PL_BEM",             "PL_BEM",     "", "" },;
{ "VL_UNID_LOC_EMB",    "VL_UNID_LO", "", "" },;
{ "VL_MERC_LOC_EMB",    "VL_MERC_LO", "", "" },;
{ "CD_MOEDA_NEGOCIADA", "CD_MOEDA_N", "", "NULL" },;
{ "VL_ADUANEIRO",       "VL_ADUANEI", "", "" },;
{ "VL_FRETE_MERC_MN",   "VL_FRETE_N", "", "" },;
{ "VL_SEG_MERC_MN",     "VL_SEG_MMN", "", "" },;
{ "VL_MERC_EMB_MN",     "VL_MERC_EB", "", "" },;
{ "TX_DESC_DET_MERC",   "TX_DESC_DE", "", "" }}
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aArrayCampos, { "VL_ALIQ_ICMS"                , "VL_ALIQ_IC", "", "" })
   AADD(aArrayCampos, { "CD_REGIME_TRIBUTAR_PISCOFINS", "CD_REGTRIP", "", "" })
   AADD(aArrayCampos, { "CD_FUND_LEG_REGIME_PISCOFINS", "CD_FUNLEGP", "", "" })
ENDIF
/*
aArrayCampos :=;
{;
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "" },;
{ "NR_BEM",             "NR_BEM",     "", "" },;
{ "NR_OPER_TRAT_PREV",  "NR_OPER_TR", "", "NULL" },; // Validacao como NULL
{ "CD_REGIME_TRIBUTAR", "CD_REGIME_", "", "" },;
{ "CD_FUND_LEG_REGIME", "CD_FUND_LE", "", "NULL" },;
{ "CD_MOTIVO_FUND_LEG", "CD_MOTIVO_", "", "NULL" },;
{ "IN_CLASSIFICACAO",   "IN_CLASSIF", "", "" },;
{ "CD_MERCADORIA",      "CD_MERCADO", "", "NULL" },;
{ "CD_DESTAQUE_NCM",    "CD_DESTAQU", "", "NULL" },;
{ "NM_DESCRICAO_MERC",  "NM_DESCRIC", "", "NULL" },;
{ "CD_PAIS_ORIG_MERC",  "CD_PAIS_OR", "", "NULL" },;
{ "IN_MERCOSUL",        "IN_MERCOSU", "", "" },;
{ "IN_MATERIAL_USADO",  "IN_MATERIA", "", "" },;
{ "NM_UN_MEDID_ESTAT",  "NM_UN_MEDE", "", "NULL" },;
{ "QT_UN_ESTATISTICA",  "QT_UN_ESTA", "", "" },;
{ "NM_UN_MEDID_COMERC", "NM_UN_MEDC", "", "NULL" },;
{ "QT_MERC_UN_COMERC",  "QT_MER_UN_", "", "" },;
{ "PB_BEM",             "PB_BEM",     "", "" },;
{ "PL_BEM",             "PL_BEM",     "", "" },;
{ "VL_UNID_LOC_EMB",    "VL_UNID_LO", "", "" },;
{ "VL_MERC_LOC_EMB",    "VL_MERC_LO", "", "" },;
{ "CD_MOEDA_NEGOCIADA", "CD_MOEDA_N", "", "NULL" },;
{ "VL_ADUANEIRO",       "VL_ADUANEI", "", "" },;
{ "VL_FRETE_MERC_MNEG", "VL_FRETE_M", "", "" },;
{ "CD_MD_FRETE_MERC",   "CD_MD_FRET", "", "NULL" },;
{ "VL_FRETE_MERC_MN",   "VL_FRETE_N", "", "" },;
{ "VL_SEG_MERC_DOLAR",  "VL_SEG_MER", "", "" },;
{ "VL_SEG_MERC_MN",     "VL_SEG_MMN", "", "" },;
{ "VL_MERC_EMB_DOLAR",  "VL_MERC_EM", "", "" },;
{ "VL_MERC_EMB_MN",     "VL_MERC_EB", "", "" },;
{ "TX_DESC_DET_MERC",   "TX_DESC_DE", "", "" };
}
*/

aArrayChaves := {;
{ "CD_DSI_MICRO", "CD_DSI_MIC", "", "" },;
{ "NR_BEM",       "NR_BEM",     "", "" }}

cMenErro:=STR0270+ENTER //STR0270 "C) Erros na Gravacao dos Itens da DSI: "

oDlgProc:SetText(STR0271) //STR0271 "Gravando itens da capa da DSI..."

DI500DLLSQL("DSI_BENS","WORK_ITEM","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

aArrayCampos :={;
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "" },;
{ "NR_SEQUENCIAL",      "NR_SEQUENC", "", "" },;
{ "CD_TIPO_EMBALAGEM",  "CD_TIPO_EM", "", "NULL" },;
{ "QT_VOLUME_CARGA",    "QT_VOLUME_", "", "NULL" }}

aArrayChaves := {;
{ "CD_DSI_MICRO", "CD_DSI_MIC", "", "" },;
{ "NR_SEQUENCIAL","NR_SEQUENC", "", "" }}

cMenErro:=STR0272+ENTER //STR0272  "D) Erros na Gravacao dos Volumes da DSI: "

oDlgProc:SetText(STR0273) //STR0273 "Gravando volumes da DSI..."

DI500DLLSQL("DSI_VOLUMES","WORK_VOL","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

aArrayCampos :={;
{ "CD_DSI_MICRO",           "CD_DSI_MIC", "", "" },;
{ "NR_BEM",                 "NR_BEM",     "", "" },;
{ "VL_BASE_CALC_ADVAL_II",  "VL_BASE_CI", "", "" },;
{ "PC_ALIQ_NORM_ADVAL_II",  "PC_ALIQ_NI", "", "" },;
{ "VL_IMPOSTO_DEVIDO_II",   "VL_IMPOSTI", "", "" },;
{ "VL_IPT_A_RECOLHER_II",   "VL_IPT_A_I", "", "" },;
{ "VL_BASE_CALC_ADVAL_IPI", "VL_BASE_CP", "", "" },;
{ "PC_ALIQ_NORM_ADVAL_IPI", "PC_ALIQ_NP", "", "" },;
{ "VL_IMPOSTO_DEVIDO_IPI",  "VL_IMPOSTP", "", "" },;
{ "VL_IPT_A_RECOLHER_IPI",  "VL_IPT_A_P", "", "" }}
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aArrayCampos, { "VL_BASE_CALC_ADVAL_PISCOF", "VL_BASE_PC", "", "" })
   AADD(aArrayCampos, { "PC_ALIQ_NORM_ADVAL_PIS"   , "PC_ALIADPI", "", "" })
   AADD(aArrayCampos, { "VL_ALIQ_ESPEC_PIS"        , "VL_ALIESPI", "", "" })
   AADD(aArrayCampos, { "NM_UN_ALIQ_ESPEC_PIS"     , "NM_UNIESPI", "", "" })
   AADD(aArrayCampos, { "QT_MERC_UN_ALIQ_ESPEC_PIS", "QT_MERESPI", "", "" })
   AADD(aArrayCampos, { "VL_IMPOSTO_CALCULADO_PIS" , "VL_PISCALC", "", "" })
   AADD(aArrayCampos, { "VL_IMPOSTO_DEVIDO_PIS"    , "VL_PISDEVI", "", "" })
   AADD(aArrayCampos, { "VL_IPT_A_RECOLHER_PIS"    , "VL_PISRECO", "", "" })
   AADD(aArrayCampos, { "PC_ALIQ_NORM_ADVAL_COF"   , "PC_ALIADCO", "", "" })
   AADD(aArrayCampos, { "VL_ALIQ_ESPEC_COF"        , "VL_ALIESCO", "", "" })
   AADD(aArrayCampos, { "NM_UN_ALIQ_ESPEC_COF"     , "NM_UNIESCO", "", "" })
   AADD(aArrayCampos, { "QT_MERC_UN_ALIQ_ESPEC_COF", "QT_MERESCO", "", "" })
   AADD(aArrayCampos, { "VL_IMPOSTO_CALCULADO_COF" , "VL_COFCALC", "", "" })
   AADD(aArrayCampos, { "VL_IMPOSTO_DEVIDO_COF"    , "VL_COFDEVI", "", "" })
   AADD(aArrayCampos, { "VL_IPT_A_RECOLHER_COF"    , "VL_COFRECO", "", "" })
ENDIF
aArrayChaves := {;
{ "CD_DSI_MICRO", "CD_DSI_MIC", "", "" },;
{ "NR_BEM",       "NR_BEM",     "", "" }}

cMenErro:=STR0274+ENTER //STR0274 "E) Erros na Gravacao dos Impostos da DSI: "

oDlgProc:SetText(STR0275) //STR0275 "Gravando impostos da DSI..."

DI500DLLSQL("DSI_TRIBUTOS_BEM","WORK_TRI","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

aArrayCampos :={;
{ "CD_DSI_MICRO",       "CD_DSI_MIC", "", "" },;
{ "NR_SEQUENCIAL",      "NR_SEQUENC", "", "" },;
{ "CD_RECEITA_PGTO",    "CD_RECEITA", "", "" },;
{ "CD_BANCO_PGTO_TRIB", "CD_BANCO_P", "", "" },;
{ "NR_AGENC_PGTO_TRIB", "NR_AGENC_P", "", "" },;
{ "VL_TRIBUTO_PAGO",    "VL_TRIBUTO", "", "" }}
//{ "DT_PGTO_TRIBUTO",    "DT_PGTO_TR", "", "" },;
//{ "VL_MULTA_PGTO_TRIB", "VL_MULTA_P", "", "" },;
//{ "VL_JUROS_PGTO_TRIB", "VL_JUROS_P", "", "" }}

aArrayChaves := {;
{ "CD_DSI_MICRO", "CD_DSI_MIC", "", "" },;
{ "NR_SEQUENCIAL","NR_SEQUENC", "", "" }}

cMenErro:=STR0276+ENTER //STR0276 "F) Erros na Gravacao dos Pagamentos da DSI: "

oDlgProc:SetText(STR0277) //STR0277 "Gravando Pagamentos da DSI..."

DI500DLLSQL("DSI_PGTO_TRIBUTOS","WORK_PGTO","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

RETURN .T.

*--------------------------------------------------------------------------------------------------------------------*
FUNCTION DI500DLLSQL(cTabela,cAlias,cCampoTp,cTipo,aArrayCampos,aArrayChaves,cMenErro,lProc)
*--------------------------------------------------------------------------------------------------------------------*
Local nCont, aEicdll := {}, aMensLog := {}, lMensTela := .F.
DEFAULT lProc := .T.
//INCLUSAO
Aadd(aEicdll,{IF(cTipo="I","I"," "),cTabela,aArrayCampos,aArrayChaves})
//ALTERACAO
Aadd(aEicdll,{IF(cTipo="A","A"," "),cTabela,aArrayCampos,aArrayChaves})
//EXCLUSAO
Aadd(aEicdll,{IF(cTipo="E","E"," "),cTabela,aArrayCampos,aArrayChaves})

EICDLLSQL(cODBC_DSI,aEicdll,cCampoTp,aMensLog,cAlias,"WKERRO",lProc,lMensTela)

If !Empty(aMenslog)
    cErro+=cMenErro
    For nCont = 1 To Len(aMenslog)
        cErro+=aMensLog[nCont]+ENTER
	Next
    cErro+=ENTER
EndIf

RETURN .T.
*-----------------------------------*
FUNCTION DI500Analise()
*-----------------------------------*
LOCAL oDLG,nLin:=26
Local xx := ""
Local bShow:={|nTela,o|DBSelectArea(aObjMark[nTela,2]),;
                       o:=aObjMark[nTela,1]:oBrowse,;
                       o:Show(),o:SetFocus() }
Local bHide:={|nTela| aObjMark[nTela,1]:oBrowse:Hide() }

LOCAL aButtons:={},aObjMark:={}
Aadd(aButtons,{"NOTE",{|| DI500Verro(Alias()) },STR0278,STR0279}) // STR0279  "Msg erro"	//STR0278 "Mensagem de Erro"

Work_Capa->(DBGOTOP())
Work_Item->(DBGOTOP())
Work_Pgto->(DBGOTOP())
Work_Vol ->(DBGOTOP())
Work_Tri ->(DBGOTOP())

DEFINE MSDIALOG oDLG TITLE STR0280 + SW6->W6_HAWB; //STR0280 "Analise dos dados da DSI, Processo: "
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
         TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

      oFld := TFolder():New(15,1,{STR0281,STR0161,STR0282,STR0283,STR0284},; //STR0281 "Capa" //STR0161 "Itens" //STR0282  "Impostos" //STR0283 "Volumes" //STR0284 "Pagamentos"
                                {"1","2","3","4","5"},oDLG,,,,.T.,.F.,150,100)

      oFld:Align:=CONTROL_ALIGN_ALLCLIENT

      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })

      //MsSelect(): New ( < cAlias>, [ cCampo], [ cCpo], [ aCampos], [ lInv], [ cMar], < aCord>, [ cTopFun], [ cBotFun], < oWnd>, [ uPar11], [ aColors] )

      // Capa
      oMark1 := MsSelect():New("Work_Capa",,,aTBCamposC,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[1])
      oMark1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      AADD(aObjMark,{oMark1,"Work_Capa"})
      
      //Item
      oMark2 := MsSelect():New("Work_Item",,,aTBCamposI,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[2])
      oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      AADD(aObjMark,{oMark2,"Work_Item"})

      // Impostos
      oMark3 := MsSelect():New("Work_Tri" ,,,aTBCamposT,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[3])
      oMark3:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      AADD(aObjMark,{oMark3,"Work_Tri"})      

      // Volumes
      oMark4 := MsSelect():New("Work_Vol" ,,,aTBCamposV,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[4])
      oMark4:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      AADD(aObjMark,{oMark4,"Work_Vol"})

      // Impostos
      oMark5 := MsSelect():New("Work_Pgto",,,aTBCamposP,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[5])
      oMark5:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      AADD(aObjMark,{oMark5,"Work_Pgto"})
            
      AEVAL(aObjMark,{|V,P| Eval(bHide,P)})
      Eval(bShow,1)
      oFld:bChange:={|nFolNew,nFolOld| Eval(bHide,nFolOld),Eval(bShow,nFolNew)}

ACTIVATE MSDIALOG oDLG ON INIT DI500EnchoiceBar(oDLG,,{||oDLG:End()},.F.,aButtons)

RETURN .T.

*-----------------------------------------------*
FUNCTION DI500Verro(cAlias)
*-----------------------------------------------*
LOCAL oDLG,mErro:=(cAlias)->WKERRO

DEFINE FONT oFont NAME "Courier New" SIZE 0,15
DEFINE MSDIALOG oDLG TITLE STR0285+cAlias From 15,00 To 32,54 OF oMainWnd //STR0285 "Mensagem de Erro, Arquivo: "

     oDLG:SetFont(oFont)
     @17,2 GET oGetMemo VAR mErro MEMO HSCROLL SIZE 203,100 OF oDLG PIXEL
     oGetMemo:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDLG ON INIT DI500EnchoiceBar(oDLG,,{|| oDLG:End()},.F.) CENTERED

RETURN .T.

*-----------------------------------*
FUNCTION DI500AbreWork()
*-----------------------------------*
LOCAL cPict:= "@E 999,999,999,999,999", S
LOCAL bTipo:={|| IF(TIPO_MANUT="I",STR0211 ,; //STR0211 := "Inclusão"
                 IF(TIPO_MANUT="A",STR0212,; //STR0212 := "Alteração"
                 IF(TIPO_MANUT="E",STR0213 ,"         "))) } //STR0213 := "Exclusão"
ProcRegua(5)

aTBCamposC:={}
aTBCamposI:={}
aTBCamposV:={}
aTBCamposT:={}
aTBCamposP:={}

IncProc(STR0286) //STR0286 "Criando Estruturas..."

// TABELA  : DSI_DADOS_GERAIS
aStru := {}
AADD(aStru, { "TIPO_MANUT", "C",001,0 } )
AADD(aStru, { "CD_DSI_MIC", "C",015,0 } )
AADD(aStru, { "DT_CRIACAO", "C",019,0 } )
AADD(aStru, { "CD_ORIGEM_", "N",001,0 } )
AADD(aStru, { "NR_DECL_IM", "C",010,0 } )
AADD(aStru, { "CD_MOTIVO_", "N",001,0 } )
AADD(aStru, { "DT_TRANSMI", "D",008,0 } )
AADD(aStru, { "NR_DECL_SI", "C",010,0 } )
AADD(aStru, { "DT_REGISTR", "D",008,0 } )
AADD(aStru, { "HO_REGISTR", "D",008,0 } )
AADD(aStru, { "NR_SEQ_RET", "N",001,0 } )
AADD(aStru, { "DT_SEQ_RET", "D",008,0 } )
AADD(aStru, { "HO_SEQ_RET", "D",008,0 } )
AADD(aStru, { "IN_BLOQUEI", "L",001,0 } )
AADD(aStru, { "CD_TIPO_NA", "N",003,0 } )
AADD(aStru, { "QT_ADICAO_", "N",005,0 } )
AADD(aStru, { "CD_TIPO_IM", "C",001,0 } )
AADD(aStru, { "NR_IMPORTA", "C",014,0 } )
AADD(aStru, { "NM_IMPORTA", "C",060,0 } )
AADD(aStru, { "NR_TEL_IMP", "C",015,0 } )
AADD(aStru, { "ED_LOGR_IM", "C",040,0 } )
AADD(aStru, { "ED_NR_IMPO", "C",006,0 } )
AADD(aStru, { "ED_COMP_IM", "C",021,0 } )
AADD(aStru, { "ED_BA_IMPO", "C",025,0 } )
AADD(aStru, { "ED_NUM_IMP", "C",025,0 } )
AADD(aStru, { "ED_UF_IMPO", "C",002,0 } )
AADD(aStru, { "ED_CEP_IMP", "C",008,0 } )
AADD(aStru, { "CD_PAIS_IM", "C",003,0 } )
AADD(aStru, { "IN_REPR_LE", "L",001,0 } )
AADD(aStru, { "NR_REPR_LE", "C",014,0 } )
AADD(aStru, { "NR_CPF_USA", "C",011,0 } )
AADD(aStru, { "CD_URF_DES", "C",007,0 } )
AADD(aStru, { "CD_PAIS_PR", "C",003,0 } )
AADD(aStru, { "CD_VIA_TRA", "C",002,0 } )
AADD(aStru, { "NR_TERMO_E", "C",009,0 } )
AADD(aStru, { "CD_TIPO_DC", "C",002,0 } )
AADD(aStru, { "NR_DCTO_HO", "C",011,0 } )
AADD(aStru, { "NR_DCTO_MA", "C",011,0 } )
AADD(aStru, { "NR_IDENT_C", "C",036,0 } )
AADD(aStru, { "DT_EMBARQU", "D",008,0 } )
AADD(aStru, { "DT_EMISSAO", "D",008,0 } )
AADD(aStru, { "PB_CARGA",   "N",017,5 } )
AADD(aStru, { "PL_CARGA",   "N",017,5 } )
AADD(aStru, { "CD_RECINTO", "C",007,0 } )
AADD(aStru, { "CD_SETOR_A", "C",003,0 } )
AADD(aStru, { "CD_MOEDA_F", "C",003,0 } )
AADD(aStru, { "VL_TOT_FRE", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_F", "N",017,2 } )
AADD(aStru, { "CD_MOEDA_S", "C",003,0 } )
AADD(aStru, { "VL_TOT_SEG", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_M", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_D", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_N", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_O", "N",017,2 } )
AADD(aStru, { "VL_TOTAL__", "N",017,2 } )
AADD(aStru, { "DT_DSE_MAN", "D",008,0 } )//Data Emissa  - SW6->W6_DT_DSE //DT_DSE_MANUAL     86
AADD(aStru, { "CD_UL_DSE_", "C",007,0 } )//UL DSE       - SW6->W6_UL_DSE //CD_UL_DSE_MANUAL  86
AADD(aStru, { "NR_DSE",     "C",011,0 } )//Nro da DSE   - SW6->W6_NR_DSE //NR_DSE            86
AADD(aStru, { "NR_DDE",     "C",011,0 } )//Nro do DDE   - SW6->W6_NR_DDE //NR_DDE            86
AADD(aStru, { "NR_PROCESS", "C",015,0 } )//Nro Processo - SW6->W6_NR_PROC//NR_PROCESSO_EXPO  86
AADD(aStru, { "VL_TOTAL_I", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_P", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_A", "N",017,2 } )
AADD(aStru, { "VL_TOTAL_R", "N",017,2 } )
AADD(aStru, { "VL_TOT_TRI", "N",017,2 } )
AADD(aStru, { "CD_TIPO_PG", "N",001,0 } )
AADD(aStru, { "NR_CONTA_P", "C",019,0 } )
AADD(aStru, { "TX_INFO_CO", "M",010,0 } )
AADD(aStru, { "IN_SERVIDO", "L",001,0 } )
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aStru, { "VL_TOTPISC", "N",017,2 } )
   AADD(aStru, { "VL_TOTCOFC", "N",017,2 } )
   AADD(aStru, { "VL_TOTPISR", "N",017,2 } )
   AADD(aStru, { "VL_TOTCOFR", "N",017,2 } )
ENDIF

AADD(aStru, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposC,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStru)
    IF aStru[S,2]="N"
       AADD(aTBCamposC,{aStru[S,1],,aStru[S,1],cPict+IF(aStru[S,4]=0,"","."+REPL("9",aStru[S,4]))})
    ELSE
       AADD(aTBCamposC,{aStru[S,1],,aStru[S,1],})
    ENDIF
Next

// TABELA  : DSI_BENS
aStruI := {}
AADD(aStruI, { "TIPO_MANUT", "C",001,0 } )
AADD(aStruI, { "CD_DSI_MIC", "C",015,0 } )
AADD(aStruI, { "NR_BEM",     "N",005,0 } )
AADD(aStruI, { "NR_OPER_TR", "C",010,0 } )
AADD(aStruI, { "CD_REG_TRI", "C",001,0 } )
AADD(aStruI, { "CD_FUND_LE", "C",002,0 } )
AADD(aStruI, { "CD_MOTIVO_", "C",002,0 } )
AADD(aStruI, { "IN_CLASSIF", "N",001,0 } )
AADD(aStruI, { "CD_MERCADO", "C",008,0 } )
AADD(aStruI, { "CD_DESTAQU", "C",003,0 } )
AADD(aStruI, { "NM_DESCRIC", "C",120,0 } )
AADD(aStruI, { "CD_PAIS_OR", "C",003,0 } )
AADD(aStruI, { "IN_MERCOSU", "L",001,0 } )
AADD(aStruI, { "IN_MATERIA", "L",001,0 } )
AADD(aStruI, { "NM_UN_MEDE", "C",020,0 } )
AADD(aStruI, { "QT_UN_ESTA", "N",017,5 } )
AADD(aStruI, { "NM_UN_MEDC", "C",020,0 } )
AADD(aStruI, { "QT_MER_UN_", "N",017,5 } )
AADD(aStruI, { "PB_BEM",     "N",017,5 } )
AADD(aStruI, { "PL_BEM",     "N",017,5 } )
AADD(aStruI, { "VL_UNID_LO", "N",017,2 } )
AADD(aStruI, { "VL_MERC_LO", "N",017,2 } )
AADD(aStruI, { "CD_MOEDA_N", "C",003,0 } )
AADD(aStruI, { "VL_ADUANEI", "N",017,2 } )
AADD(aStruI, { "VL_FRETE_M", "N",017,2 } )
AADD(aStruI, { "CD_MD_FRET", "C",003,0 } )
AADD(aStruI, { "VL_FRETE_N", "N",017,2 } )
AADD(aStruI, { "VL_SEG_MER", "N",017,2 } )
AADD(aStruI, { "VL_SEG_MMN", "N",017,2 } )
AADD(aStruI, { "VL_MERC_EM", "N",017,2 } )
AADD(aStruI, { "VL_MERC_EB", "N",017,2 } )
AADD(aStruI, { "TX_DESC_DE", "M",010,0 } )
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aStruI, { "VL_ALIQ_IC", "N",006,2 } )
   AADD(aStruI, { "CD_REGTRIP", "C",001,0 } )
   AADD(aStruI, { "CD_FUNLEGP", "C",002,0 } )
ENDIF

AADD(aStruI, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposI,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStruI)
    IF aStruI[S,2]="N"
       AADD(aTBCamposI,{aStruI[S,1],,aStruI[S,1],cPict+IF(aStruI[S,4]=0,"","."+REPL("9",aStruI[S,4]))})
    ELSE
       AADD(aTBCamposI,{aStruI[S,1],,aStruI[S,1]})
    ENDIF
Next

// TABELA : DSI_VOLUMES
aStruV := {}
AADD(aStruV, { "TIPO_MANUT", "C",001,0 } )
AADD(aStruV, { "CD_DSI_MIC", "C",015,0 } )
AADD(aStruV, { "NR_SEQUENC", "N",005,0 } )
AADD(aStruV, { "CD_TIPO_EM", "C",002,0 } )
AADD(aStruV, { "QT_VOLUME_", "N",010,0 } )
AADD(aStruV, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposV,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStruV)
    IF aStruV[S,2]="N"
       AADD(aTBCamposV,{aStruV[S,1],,aStruV[S,1],cPict+IF(aStruV[S,4]=0,"","."+REPL("9",aStruV[S,4]))})
    ELSE
       AADD(aTBCamposV,{aStruV[S,1],,aStruV[S,1]})
    ENDIF
Next

// TABELA : DSI_TRIBUTOS_BEM
aStruT := {}
AADD(aStruT, { "TIPO_MANUT", "C",001,0 } )
AADD(aStruT, { "CD_DSI_MIC", "C",015,0 } )
AADD(aStruT, { "NR_BEM",     "N",005,0 } )
AADD(aStruT, { "PC_ALIQ_NI", "N",017,2 } )
AADD(aStruT, { "VL_IMPOSTI", "N",017,2 } )
AADD(aStruT, { "VL_IPT_A_I", "N",017,2 } )
AADD(aStruT, { "VL_BASE_CI", "N",017,2 } )
AADD(aStruT, { "PC_ALIQ_NP", "N",017,2 } )
AADD(aStruT, { "VL_IMPOSTP", "N",017,2 } )
AADD(aStruT, { "VL_IPT_A_P", "N",017,2 } )
AADD(aStruT, { "VL_BASE_CP", "N",017,2 } )
IF lAUTPCDI  // Bete - DSI - inclusao dos novos cpos ref a PIS/COFINS
   AADD(aStruT, { "VL_BASE_PC", "N",017,2 } )
   AADD(aStruT, { "PC_ALIADPI", "N",017,2 } )
   AADD(aStruT, { "VL_ALIESPI", "N",017,2 } )
   AADD(aStruT, { "NM_UNIESPI", "C",015,0 } )
   AADD(aStruT, { "QT_MERESPI", "N",017,2 } )
   AADD(aStruT, { "VL_PISCALC", "N",017,2 } )
   AADD(aStruT, { "VL_PISDEVI", "N",017,2 } )
   AADD(aStruT, { "VL_PISRECO", "N",017,2 } )
   AADD(aStruT, { "PC_ALIADCO", "N",017,2 } )
   AADD(aStruT, { "VL_ALIESCO", "N",017,2 } )
   AADD(aStruT, { "NM_UNIESCO", "C",015,0 } )
   AADD(aStruT, { "QT_MERESCO", "N",017,2 } )
   AADD(aStruT, { "VL_COFCALC", "N",017,2 } )
   AADD(aStruT, { "VL_COFDEVI", "N",017,2 } )
   AADD(aStruT, { "VL_COFRECO", "N",017,2 } )
ENDIF

AADD(aStruT, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposT,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStruT)
    IF aStruT[S,2]="N"
       AADD(aTBCamposT,{aStruT[S,1],,aStruT[S,1],cPict+IF(aStruT[S,4]=0,"","."+REPL("9",aStruT[S,4]))})
    ELSE
       AADD(aTBCamposT,{aStruT[S,1],,aStruT[S,1]})
    ENDIF
Next

// TABELA : DSI_PGTO_TRIBUTOS
aStruP := {}
AADD(aStruP, { "TIPO_MANUT", "C",001,0 } )
AADD(aStruP, { "CD_DSI_MIC", "C",015,0 } )
AADD(aStruP, { "NR_SEQUENC", "N",005,0 } )
AADD(aStruP, { "CD_RECEITA", "C",004,0 } )
AADD(aStruP, { "CD_BANCO_P", "C",003,0 } )
AADD(aStruP, { "NR_AGENC_P", "C",005,0 } )
AADD(aStruP, { "VL_TRIBUTO", "N",017,2 } )
AADD(aStruP, { "DT_PGTO_TR", "C",008,0 } )
AADD(aStruP, { "VL_MULTA_P", "N",017,2 } )
AADD(aStruP, { "VL_JUROS_P", "N",017,2 } )
AADD(aStruP, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposP,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStruP)
    IF aStruP[S,2]="N"
       AADD(aTBCamposP,{aStruP[S,1],,aStruP[S,1],cPict+IF(aStruP[S,4]=0,"","."+REPL("9",aStruP[S,4]))})
    ELSE
       AADD(aTBCamposP,{aStruP[S,1],,aStruP[S,1]})
    ENDIF
Next

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"ALT_STRU_DSI"),)

IncProc(STR0288) //STR0288 "Criando Arq. Temp. Work_Capa..."
IF SELECT("Work_Capa") # 0
   DbSelectArea("Work_Capa")
   //ZAP
   AvZap("Work_Capa")
ELSE
   cArqTrabC := E_CriaTrab(,aStru,"Work_Capa",,.F.)
   If !USED()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

IncProc(STR0289) //STR0289 "Criando Arq. Temp. Work_Item..."
IF SELECT("Work_Item") # 0
   DbSelectArea("Work_Item")
   //ZAP
   AvZap("Work_Item")
ELSE
   cArqTrabI := E_CriaTrab(,aStruI,"Work_Item",,.F.)
   If !USED()
      DI500DelTRB()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

IncProc(STR0290) //STR0290 "Criando Arq. Temp. Work_Vol..."
IF SELECT("Work_Vol") # 0
   DbSelectArea("Work_Vol")
   //ZAP
   AvZap("Work_Vol")
ELSE
   cArqTrabV := E_CriaTrab(,aStruV,"Work_Vol",,.F.)
   If !USED()
      DI500DelTRB()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

IncProc(STR0291) //STR0291 "Criando Arq. Temp. Work_Tri..."
IF SELECT("Work_Tri") # 0
   DbSelectArea("Work_Tri")
   //ZAP
   AvZap("Work_Tri")
ELSE
   cArqTrabT := E_CriaTrab(,aStruT,"Work_Tri",,.F.)
   If !USED()
      DI500DelTRB()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

IncProc(STR0292)//STR0292 "Criando Arq. Temp. Work_Pgto..."
IF SELECT("Work_Pgto") # 0
   DbSelectArea("Work_Pgto")
   //ZAP
   AvZap("Work_Pgto")
ELSE
   cArqTrabP := E_CriaTrab(,aStruP,"Work_Pgto",,.F.)
   If !USED()
      DI500DelTRB()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

Return .T.

*-----------------------------------*
FUNCTION DI500DelTRB()
*-----------------------------------*

IF SELECT("Work_Capa") # 0
   Work_Capa->(E_EraseArq(cArqTrabC))
ENDIF

IF SELECT("Work_Item") # 0
   Work_Item->(E_EraseArq(cArqTrabI))
ENDIF

IF SELECT("Work_Vol") # 0
   Work_Vol->(E_EraseArq(cArqTrabV))
ENDIF

IF SELECT("Work_Tri") # 0
   Work_Tri->(E_EraseArq(cArqTrabT))
ENDIF

IF SELECT("Work_Pgto") # 0
   Work_Pgto->(E_EraseArq(cArqTrabP))
ENDIF

Return .T.
*-----------------------------------------------*
Function DI500RegPesq()
*-----------------------------------------------*
LOCAL oDlg, nSelOp, oRadio, lTemItens:=.F., B, oPanel, aPos1, aPos2
LOCAL nRegWork := Work_SW8->(Recno()), lRet:=.T., nInd
LOCAL i := 0
PRIVATE aMoeda:={}, aPLIs:={}, aPOs:={}, aNcm:={}, aInvoice:={}
PRIVATE cNcm,cMoeda,cPLI   ,cPO   ,cInvoice
PRIVATE oNCM,oCbo  ,oCboPLI,oCboPO,oInv
PRIVATE nOpRad := 1,aBotaoReg:={},lOperacao := .T.
PRIVATE aOPREG:={STR0293,STR0203,STR0294,STR0204,STR0295,STR0205,STR0206} // NCF - 22/01/2010 - Adicionada a "EX" ao filtro da NCM nos casos de DI Eetronica //STR0293 "NCM+EX" //STR0203 "Pedido" //STR0294 "PLI" //STR0204 "Moeda" //STR0295 "Invoice"//STR0205 "Atual"//STR0206 "Todos"
PRIVATE cOPREG:=aOPREG[LEN(aOPREG)],aEscolha:={},lWhenReg:=.T.,cEscolha:=STR0293,oEscolha//AWR - 06/2009 - Chamado P10 //STR0293 "NCM+EX"
PRIVATE lExecBlock := .T.
PRIVATE aCbox:={}
SX3->(DBSETORDER(2))
SX3->(DBSEEK("EIJ_REGIPI"))
aCbox:=GRV_DESCR(TRIM(SX3->X3_CBOX))

DBSELECTAREA("EIJ")
FOR nInd := 1 TO FCount()
    M->&(FIELDNAME(nInd))  := CRIAVAR(FIELDNAME(nInd))
NEXT
M->EIJ_REGTRI:="1"

If AvFlags("DUIMP") .AND. M->W6_TIPOREG == "2" 
   EasyHelp(STR0402, STR0375 ,STR0403) //"Ação não disponível para processos do tipo DUIMP", "Aviso","Para informar os dados tributários, acesse a opção Itens DUIMP"
   RETURN .T.
EndIf

IF !lTemAdicao .AND. !lDISimples 
   DI500Simples(,.T.)
   RETURN .T.
ENDIF

IF !Inclui .AND. lPrimeiraVez
   Processa({|| DI500Existe() },STR0180) //STR0180 "Pesquisa de Itens"
ENDIF

SW3->(dbSetOrder(8))
Work_SW8->(DBGOTOP())

DO WHILE Work_SW8->(!EOF())

   lTemItens:=.T.
   IF ASCAN( aMoeda, Work_SW8->WKMOEDA ) == 0
      AADD ( aMoeda, Work_SW8->WKMOEDA )
      cMoeda:=aMoeda[1]
   ENDIF

   IF ASCAN( aPLIs, Work_SW8->WKPGI_NUM ) == 0
      AADD ( aPLIs, Work_SW8->WKPGI_NUM )
      cPLI:=aPLIs[1]
   ENDIF

   IF ASCAN( aPOs, Work_SW8->WKPO_NUM ) == 0
      AADD ( aPOs, Work_SW8->WKPO_NUM )
      cPO:=aPOs[1]
   ENDIF
  /*
   IF ASCAN( aNcm, Work_SW8->WKTEC ) == 0
      AADD ( aNcm, Work_SW8->WKTEC )
      cNcm:=aNcm[1]
   ENDIF
  */
   IF ASCAN( aNcm, Work_SW8->WKTEC+Work_SW8->WKEX_NCM ) == 0  //NCF - 22/01/2010
      AADD ( aNcm, Work_SW8->WKTEC+Work_SW8->WKEX_NCM )
      cNcm:=aNcm[1]
   ENDIF

   IF ASCAN( aInvoice, Work_SW8->WKINVOICE ) == 0
      AADD ( aInvoice, Work_SW8->WKINVOICE )
      cInvoice:=aInvoice[1]
   ENDIF

   /* LRS - 22/03/2017 - Trecho nopado para não ser mais carregado as informações 
   IF !EMPTY(Work_SW8->WKREGTRI)
      M->EIJ_REGTRI:=Work_SW8->WKREGTRI
      M->EIJ_FUNREG:=Work_SW8->WKFUNREG
      M->EIJ_MOTADI:=Work_SW8->WKMOTADI
      M->EIJ_TACOII:=Work_SW8->WKTACOII
      M->EIJ_ACO_II:=Work_SW8->WKACO_II
      M->EIJ_OPERAC:=Work_SW8->WKOPERACA //LRS - 21/03/2017
      IF lREGIPIW8
         M->EIJ_REGIPI:=Work_SW8->WKREGIPI
      ENDIF
      IF lAUTPCDI  // Bete - DI
         M->EIJ_REG_PC:=Work_SW8->WKREG_PC
         M->EIJ_FUN_PC:=Work_SW8->WKFUN_PC
         M->EIJ_FRB_PC:=Work_SW8->WKFRB_PC
      ENDIF
   ENDIF
   */

   Work_SW8->(DBSKIP())

ENDDO

IF !lTemItens
   Help(" ",1,"AVG0005357") //LRL 08/01/04 MSGSTOP("Processo nao possui Itens de Invoice.")
   Work_SW8->(DBGOTOP())
   RETURN .T.
ENDIF

aBox:=ComboX3Box("EIJ_TACOII")
cBox:="{||"
For B:=1 To Len(aBox)
    cBox += "IF(Work_SW8->WKTACOII == '"+Substr(aBox[B],1,At("=",aBox[B])-1)+"','"+Substr(aBox[B],At("=",aBox[B])+1)+"',"
Next
cBox+="''"+Replic(")",Len(aBox))+"}"
bBox:=&(cBox)
aCamposSW8:={}
AADD(aCamposSW8,{"WKFLAGDSI"  ,,""})
AADD(aCamposSW8,{{|| DI500DescRegTri(Work_SW8->WKREGTRI)},,AVSX3('EIJ_REGTRI',5)})
AADD(aCamposSW8,{"WKFUNREG",,AVSX3("EIJ_FUNREG",5)})
AADD(aCamposSW8,{"WKMOTADI",,AVSX3("EIJ_MOTADI",5)})
AADD(aCamposSW8,{bBox,,AVSX3("EIJ_TACOII",5)})
AADD(aCamposSW8,{"WKACO_II"  ,,AVSX3("EIJ_ACO_II",5)})
AADD(aCamposSW8,{"WKTEC"     ,,AVSX3("W3_TEC"    ,5),AVSX3("W3_TEC",6)})
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3("W8_PO_NUM" ,5)})
AADD(aCamposSW8,{"WKPGI_NUM" ,,AVSX3("W8_PGI_NUM",5)})
AADD(aCamposSW8,{"WKMOEDA"   ,,AVSX3("W2_MOEDA"  ,5)})
AADD(aCamposSW8,{"WKINVOICE" ,,AVSX3("W9_INVOICE",5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3("W8_COD_I"  ,5)})
AADD(aCamposSW8,{"WKFORN"    ,,AVSX3("W8_FORN"   ,5)})
If EICLoja()
   AADD(aCamposSW8,{"W8_FORLOJ"    ,,AVSX3("W8_FORLOJ"   ,5)})
EndIf
AADD(aCamposSW8,{"WKADICAO"  ,,AVSX3("W8_ADICAO" ,5)})
AADD(aCamposSW8,{"WKOPERACA" ,,STR0296})//AWR - 20/12/2004 //STR0296 "Operação"
IF lREGIPIW8
   AADD(aCamposSW8,{{|| DI500IPIDescRegTri(Work_SW8->WKREGIPI)},,AVSX3('W8_REGIPI',5)})
ENDIF

IF lAUTPCDI  // DSI - Bete
   AADD(aCamposSW8,{{|| DI500DescRegTri(Work_SW8->WKREG_PC)},,AVSX3('W8_REG_PC',5)})
   AADD(aCamposSW8,{"WKFUN_PC"  ,,AVSX3("W8_FUN_PC" ,5)})
   AADD(aCamposSW8,{"WKFRB_PC"  ,,AVSX3("W8_FRB_PC" ,5)})
ENDIF

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"AADD_ACAMPOS_SW8"),) // JBS 05/11/2003

SJP->(DBSETORDER(1))
SJP->(DBSEEK(xFilial()+M->EIJ_REGTRI))

nCol   := 130
nLin   := 4

aCposMostra:={}
AADD(aBotaoReg,{"PREV",{|| (nSelOp:=0,oDlg:End()) },STR0201,STR0202}) //STR0202 "Tela Anterior" -  "STR0201" "Anterior"
aTelaSW6:=ACLONE(aTela)//Devem ser salvos antes da chamada da DI500Invoices() se nao ocorre erro
aGetsSW6:=ACLONE(aGets)
aTela:={}
aGets:={}
lGetRegTri := .T.  //GFC - 26/11/2003
aEscolha:=ACLONE(aNCM)

DO WHILE .T.

   nSelOp := 0
   DEFINE MSDIALOG oDlg TITLE STR0393 FROM DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM STYLE Of oMainWnd Pixel // "Regime de Tributação por Seleção"

      aPos1:= PosDlgUp(oDlg)
      aPos2:= PosDlgDown(oDlg)

      oPanel:= TPanel():New(aPos1[1], aPos1[2], "", oDlg,, .F., .F.,,, aPos1[4], aPos1[3])

      DI500TelaSel(oPanel,.T.)

      AAdd(aBotaoReg, {"", {|| IF(ExistCpo("SJP",M->EIJ_REGTRI), (Processa({|| lRet:=DI500MarkReg(nOpRad) }),oMarkItens:oBrowse:Refresh()) ,)}, STR0298, STR0298}) //"Gravar Regime nos Itens das Invoices"
      DBSELECTAREA("Work_SW8")
      Work_SW8->(DBSETORDER(1))

      cFiltro := "!Work_SW8->WKFLAGIV == '"+Space(Len(Work_SW8->WKFLAGIV))+"' .AND. "+;
                 "!Work_SW8->WKINVOICE == '"+Space(Len(Work_SW8->WKINVOICE))+"'"
      dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)

      DBGOTOP()
      oMarkItens:=MSSELECT():New("Work_SW8","WKFLAGDSI",,aCamposSW8,lInverte,cMarca,aPos2,,,oDlg)
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_SW8'),DBSETORDER(1),.T.}
      oMarkItens:oBrowse:ACOLUMNS[1]:BDATA:={|| IF(EMPTY(Work_SW8->WKREGTRI),"BR_VERMELHO","BR_VERDE") }

      oMarkItens:oBrowse:Align:=CONTROL_ALIGN_BOTTOM
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| (nSelOp:=0,oDlg:End()) },{|| (nSelOp:=0,oDlg:End()) },.F.,aBotaoReg), oMarkItens:oBrowse:Refresh())  CENTERED

   IF lRet == NIL .OR. lRet
      EXIT
   ENDIF

Enddo

lGetRegTri := .F.  //GFC - 26/11/2003
aTela:=ACLONE(aTelaSW6)
aGets:=ACLONE(aGetsSW6)

Work_SW8->(dbGoTo(nRegWork))

Return NIL
*-----------------------------------*
FUNCTION DI500TelaSel(ODLG,lRegTri)
*-----------------------------------*
Local aPosDlg, oEnchoice, oPanel
nLin := 6
nColR:= 20
nCol := nColR+111
nColS:= nCol-35
nSoma:= 16

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@nLin+07,nColR-10   SAY STR0299    OF oPanel PIXEL  //STR0299 "Filtro"
@nLin+07,nColR+5 COMBOBOX oOpReg  VAR cOpReg    ITEMS aOPREG  SIZE 75,18 ON CHANGE(DI500ValTelaSel(lRegTri)) of oPanel PIXEL   // PLB 06/10/06

@nLin+07, nCol-10 SAY STR0300     OF oPanel PIXEL //STR0300 "Escolha"
@nLin+07, nCol+10 COMBOBOX oEscolha  VAR cEscolha    ITEMS aEscolha       SIZE 75,18  of oPanel PIXEL WHEN lWhenReg
nLin+=10

DI500ValTelaSel(.F.)  // PLB 06/10/06 - Carrega o array da combo 'Escolha'

IF lRegTri
   SJP->(DBSETORDER(1))
   SJP->(DBSEEK(xFilial()+M->EIJ_REGTRI))
   nLin+=nSoma-2.5
   aCposMostra:={"EIJ_REGTRI","EIJ_FUNREG","EIJ_MOTADI","EIJ_TACOII","EIJ_ACO_II"}
   IF lREGIPIW8
      AADD(aCposMostra,"EIJ_REGIPI")
   ENDIF
   IF lAUTPCDI // Bete - DI
      AADD(aCposMostra,"EIJ_REG_PC")
      AADD(aCposMostra,"EIJ_FUN_PC")
      AADD(aCposMostra,"EIJ_FRB_PC")
   ENDIF
   IF lQbgOperaca//AWR - 20/12/2004
      AADD(aCposMostra,"EIJ_OPERAC")
   ENDIF

   aPosDlg:= PosDlg(oPanel)
   aPosDlg[1]+= nLin
   oEnchoice:= MsmGet():New("EIJ",1,3,,,,aCposMostra,aPosDlg,,3,,,,oPanel,,,,,.T.)//19o. parametro com .T.: Desabilita as Pastas
   oEnchoice:oBox:Align := CONTROL_ALIGN_BOTTOM
ENDIF

RETURN .T.

*------------------------------*
FUNCTION DI500ValTelaSel(lFlag)
*------------------------------*
//LOCAL aLixo:={""}
IF cOpReg = STR0293   //NCF - 22/01/2010  //STR0293 "NCM+EX"
   nOpRad:=1
   oEscolha:AITEMS:=ACLONE(aNCM)
   lWhenReg:= .T.
ELSEIF cOpReg = STR0203 //STR0203 "Pedido"
   nOpRad:=2
   oEscolha:AITEMS:=ACLONE(aPOs)
   lWhenReg:= .T.
ELSEIF cOpReg = "PLI"
   nOpRad:=3
   oEscolha:AITEMS:=ACLONE(aPLIs)
   lWhenReg:= .T.
ELSEIF cOpReg = STR0204 //STR0204 "Moeda"
   nOpRad:=4
   oEscolha:AITEMS:=ACLONE(aMoeda)
   lWhenReg:= .T.
ELSEIF cOpReg = STR0295 //STR0295 "Invoice"
   nOpRad:=5
   oEscolha:AITEMS:=ACLONE(aInvoice)
   lWhenReg:= .T.
ELSEIF cOpReg = STR0205 .OR. cOpReg = STR0206 //STR0205 "Atual" // "STR0206  "Todos"
   IF cOpReg = STR0205//STR0205 "Atual"
      oEscolha:AITEMS:={STR0205}//STR0205 "Atual"
      nOpRad:=6
   ELSE
      oEscolha:AITEMS:={STR0206} // "STR0206  "Todos"
      nOpRad:=7
   ENDIF
   IF lFlag
      oEscolha:AITEMS:={""}
      lWhenReg:= .F.
   ENDIF
ENDIF

Return .T.
*------------------------------*
FUNCTION DI500CBOX(lLote)
*------------------------------*
IF lLote
   IF(nOpRad=1, oCboPO:ENABLE(), oCboPO:DISABLE()) // Escolheu PO
   IF(nOpRad=2,   oInv:ENABLE(),   oInv:DISABLE()) // Escolheu Invoice
   IF(nOpRad=3,oCboPLI:ENABLE(),oCboPLI:DISABLE()) // Escolheu PLI
   IF(nOpRad=4 .AND. lLoteInclui,oCboFor:ENABLE(),oCboFor:DISABLE()) // Escolheu Todos
ELSE
   IF(nOpRad=1,   oNCM:ENABLE(),   oNCM:DISABLE()) // Escolheu NCM
   IF(nOpRad=2, oCboPO:ENABLE(), oCboPO:DISABLE()) // Escolheu PO
   IF(nOpRad=3,oCboPLI:ENABLE(),oCboPLI:DISABLE()) // Escolheu PLI
   IF(nOpRad=4,   oCbo:ENABLE(),   oCbo:DISABLE()) // Escolheu Moeda
   IF(nOpRad=5,   oInv:ENABLE(),   oInv:DISABLE()) // Escolheu Invoice
ENDIF
RETURN .T.

*-------------------------------------------------------------------------------------*
FUNCTION DI500MarkReg(nOpRad,lVerifica)
*-------------------------------------------------------------------------------------*
LOCAL nRecno  :=Work_SW8->(RECNO())
LOCAL nOrder  :=Work_SW8->(INDEXORD())
LOCAL bBlocSel:={||.T.},nCont:=xTotal:=0
LOCAL lReturn := .F.
DEFAULT lVerifica:= .F.

ProcRegua(xTotal:=Work_SW8->(EasyReccount("Work_SW8")))
xTotal:=LTRIM(STR(xTotal,7))
DBSELECTAREA("Work_SW8")
SET FILTER TO

BEGIN SEQUENCE

IF !lVerifica
   DI500Controle(1)
   IF nOpRad == 1
      bBlocSel := {|| RTRIM(Work_SW8->WKTEC+Work_SW8->WKEX_NCM ) == RTRIM(cEscolha)}  //NCF - 22/01/2010
   ELSEIF nOpRad == 2
      bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cEscolha)}
   ELSEIF nOpRad == 3
      bBlocSel := {|| RTRIM(Work_SW8->WKPGI_NUM) == RTRIM(cEscolha)}
   ELSEIF nOpRad == 4
      bBlocSel := {|| RTRIM(Work_SW8->WKMOEDA  ) == RTRIM(cEscolha)}
   ELSEIF nOpRad == 5
      bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cEscolha)}
   ENDIF

   lReturn:=.T.
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELAREGIME"),)

   IF ! lExecBlock
//    lReturn := .F.
      lExecBlock:=.T.
      BREAK
   ENDIF

   IF nOpRad == 6
//      If lIntDraw .and. Work_SW8->WKREGTRI $ ("03/05") .and. Alltrim(Work_SW8->WKFUNREG) == "16"  //GFC - 26/11/2003
//         MsgInfo("Regime de tributação não pode ser alterado pois item está atrelado a um Ato Concessório de Drawback.")
//         BREAK
//      EndIf

      // Bete 25/05/06 - Nao permitir a alteração do regime do II e do fundamento se o item for ref a Drawback
      lGrvReg := .T.
      If lIntDraw .and. !Empty(Work_SW8->WKAC)
         IF ( Work_SW8->WKREGTRI $ ("03/05") .and. ! M->EIJ_REGTRI $ ("03/05") ) .OR. ;
            ( Alltrim(Work_SW8->WKFUNREG) == "16" .AND. Alltrim(M->EIJ_FUNREG) <> "16" )
            MsgInfo(STR0301) //STR0301 "Item está atrelado a um Ato Concessório de Drawback, portanto os regimes de II e IPI não pode ser alterados!"
            lGrvReg := .F.
         ENDIF
      ENDIF
      IF lGrvReg
         Work_SW8->WKREGTRI:=M->EIJ_REGTRI
         Work_SW8->WKFUNREG:=M->EIJ_FUNREG
         Work_SW8->WKMOTADI:=M->EIJ_MOTADI
         Work_SW8->WKTACOII:=M->EIJ_TACOII
         Work_SW8->WKACO_II:=M->EIJ_ACO_II
         Work_SW8->WKADICAO:=""
         IF Work_SW8->WKREGTRI # "6"               //NCF - 22/02/2011 - Não Grava o Regime de IPI quando Reg.Trib = "NAO INCIDENCIA" pois
            IF lREGIPIW8                           //                   No Siscomex é desnecessário o Reg. de IPI neste caso e a gravação faz
               Work_SW8->WKREGIPI:=M->EIJ_REGIPI   //                   quebrar em mais de uma adição itens que possuem mesma chave de quebra
            ENDIF
         ENDIF
      ENDIF

      IF lQbgOperaca .AND. lOperacao//AWR - 20/12/2004
         Work_SW8->WKOPERACA:=M->EIJ_OPERAC
      ENDIF
      IF lAUTPCDI // Bete - DI
         Work_SW8->WKREG_PC := M->EIJ_REG_PC
         Work_SW8->WKFUN_PC := M->EIJ_FUN_PC
         Work_SW8->WKFRB_PC := M->EIJ_FRB_PC
      ENDIF
      BREAK
   ENDIF

ENDIF

Work_SW8->(DBSETORDER(1))
Work_SW8->(dbGoTop())
DO While !Work_SW8->(Eof())

   nCont++
   IncProc(STR0208+STR(nCont,7)+ STR0303+xTotal) // STR0302 "Lendo:" //STR0303 " de "

   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF lVerifica                         //NCF - 22/02/2011 - Se Reg.II for "6", não necessita verificar o Reg. IPI
      IF EMPTY(Work_SW8->WKREGTRI) .OR. IF(Work_SW8->WKREGTRI # "6", IF(lREGIPIW8,EMPTY(Work_SW8->WKREGIPI),.F.) ,.F.) .OR. IF(lAUTPCDI,EMPTY(Work_SW8->WKREG_PC),.F.)  // Bete - DI
         lReturn := .T.
         BREAK
      ENDIF
      WORK_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF !EVAL(bBlocSel)
      WORK_SW8->(DBSKIP())
      LOOP
   ENDIF

//   If lIntDraw .and. Work_SW8->WKREGTRI $ ("03/05") .and. Alltrim(Work_SW8->WKFUNREG) == "16"  //GFC - 26/11/2003
//      Work_SW8->(dbSkip())
//      Loop
//   EndIf

   // Bete 25/05/06 - Nao permitir a alteração do regime do II e do fundamento se o item for ref a Drawback
   lGrvReg := .T.
   If lIntDraw .and. !Empty(Work_SW8->WKAC)
      IF ( Work_SW8->WKREGTRI $ ("03/05") .and. ! M->EIJ_REGTRI $ ("03/05") ) .OR. ;
         ( Alltrim(Work_SW8->WKFUNREG) == "16" .AND. Alltrim(M->EIJ_FUNREG) <> "16" )
         lGrvReg := .F.
      ENDIF
   ENDIF

   IF lGrvReg
      Work_SW8->WKREGTRI:=M->EIJ_REGTRI
      Work_SW8->WKFUNREG:=M->EIJ_FUNREG
      Work_SW8->WKMOTADI:=M->EIJ_MOTADI
      Work_SW8->WKTACOII:=M->EIJ_TACOII
      Work_SW8->WKACO_II:=M->EIJ_ACO_II
      Work_SW8->WKADICAO:=""
      IF Work_SW8->WKREGTRI # "6"               //NCF - 22/02/2011 - Não Grava o Regime de IPI quando Reg.Trib = "NAO INCIDENCIA" pois
         IF lREGIPIW8                           //                   No Siscomex é desnecessário o Reg. de IPI neste caso e a gravação faz
            Work_SW8->WKREGIPI:=M->EIJ_REGIPI   //                   quebrar em mais de uma adição itens que possuem mesma chave de quebra
         ENDIF
      ENDIF
   ENDIF

   IF lQbgOperaca .AND. lOperacao//AWR - 20/12/2004
      Work_SW8->WKOPERACA:=M->EIJ_OPERAC
   ENDIF
   IF lAUTPCDI
      Work_SW8->WKREG_PC := M->EIJ_REG_PC
      Work_SW8->WKFUN_PC := M->EIJ_FUN_PC
      Work_SW8->WKFRB_PC := M->EIJ_FRB_PC
   ENDIF

   Work_SW8->(dbSkip())

ENDDO

END SEQUENCE

IF !lVerifica
   DBSELECTAREA("Work_SW8")
   //SET FILTER TO !EMPTY(Work_SW8->WKFLAGIV) .AND. !EMPTY(Work_SW8->WKINVOICE) // - nopado para tratamento cTree - FSM - 16/07/2011
   cFiltro := "!Work_SW8->WKFLAGIV == '"+Space(Len(Work_SW8->WKFLAGIV))+"' .AND. "+;
              "!Work_SW8->WKINVOICE == '"+Space(Len(Work_SW8->WKINVOICE))+"'"
   DbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)



   DBGOTOP()
ENDIF

  //LRS - 22/03/2017 - Zerar os campos apos incluir um regime.
  M->EIJ_REGTRI:="1"
  M->EIJ_FUNREG:=SPACE(AVSX3("EIJ_FUNREG",AV_TAMANHO))
  M->EIJ_MOTADI:=SPACE(AVSX3("EIJ_MOTADI",AV_TAMANHO))
  M->EIJ_TACOII:=SPACE(AVSX3("EIJ_TACOII",AV_TAMANHO))
  M->EIJ_ACO_II:=SPACE(AVSX3("EIJ_ACO_II",AV_TAMANHO))
  M->EIJ_OPERAC:=SPACE(AVSX3("EIJ_OPERAC",AV_TAMANHO))
  M->EIJ_REGIPI:="4"
  M->EIJ_REG_PC:=SPACE(AVSX3("EIJ_REG_PC",AV_TAMANHO))
  M->EIJ_FUN_PC:=SPACE(AVSX3("EIJ_FUN_PC",AV_TAMANHO))
  M->EIJ_FRB_PC:=SPACE(AVSX3("EIJ_FRB_PC",AV_TAMANHO))

Work_SW8->(DBSETORDER(nOrder))
Work_SW8->(dbGoTo(nRecno))

RETURN lReturn
*------------------------------*
FUNCTION DI500SXBFiltra(cAlias)//Chamada do SXB ALIAS: SJP,SJ8 e SJR => TIPO: 6
*------------------------------*
IF TYPE("lDISimples")="L" .AND. lDISimples
   IF cAlias = "SJP"    // CADASTRO DE TABELA DE REGIMES TRIBUTARIOS
      IF TYPE("cFiltroSJP")="C"
         RETURN SJP->JP_CODIGO $ cFiltroSJP
      ENDIF

   ELSEIF cAlias = "SY8"// CADASTRO DE FUNDAMENTO LEGAL
      IF TYPE("cFiltroSY8")="C"
         RETURN SY8->Y8_COD $ cFiltroSY8
      ENDIF

   ELSEIF cAlias = "SJR"// CADASTRO DE MOTIVO DE ADMISSAO TEMPORARIA
      IF TYPE("cFiltroSJR")="C"
         RETURN (M->EIJ_FUNREG == SJR->JR_FUNDLEG) .AND. SJR->JR_CODIGO $ cFiltroSJR
      ENDIF

   // Bete - 02/05/06 - Inicio
   ELSEIF cAlias = "RPC"  // REGIME TRIBUT. P/ PIS/COFINS
      IF TYPE("cFiltroRPC")="C"
         RETURN SJP->JP_CODIGO $ cFiltroRPC
      ENDIF

   ELSEIF cAlias = "EIV"  // FUNDAMENTO LEGAL P/ PIS/COFINS
      IF TYPE("cFiltroEIV")="C"
         RETURN SJY->JY_CODIGO $ cFiltroEIV
      ENDIF
   ENDIF
   // Bete - 02/05/06 - Fim

ELSE
   IF cAlias = "SJR"    // CADASTRO DE MOTIVO DE ADMISSAO TEMPORARIA
      RETURN EMPTY(SJR->JR_FUNDLEG)
   ENDIF
ENDIF
RETURN .T.

*----------------------*
FUNCTION DI500SJZBrow()
*----------------------*
LOCAL oDlg, Tb_Campos:={}, OldArea:=SELECT(), lOk:=.T.
LOCAL cTitulo,bReturn:={||(M->EIJ_FRB_PC:=Work_SJZ->JZ_CODIGO),oDlg:End()}

	AADD(Tb_Campos,{"JZ_CODIGO",,STR0042}) //STR0042 "Codigo"
	AADD(Tb_Campos,{"JZ_DESC",,STR0043}) // STR0043	"Descrição"

Work_SJZ->(dbgotop())
IF Work_SJZ->(EOF()) .AND. Work_SJZ->(BOF())
   Work_SJZ->(avzap())
   SJZ->(dbgotop())
   WHILE ! SJZ->(EOF())
     IF ! Work_SJZ->(dbseek(SJZ->JZ_CODIGO))
        Work_SJZ->(dbappend())
        Work_SJZ->JZ_CODIGO:=SJZ->JZ_CODIGO
        Work_SJZ->JZ_DESC:=SJZ->JZ_DESC
     ENDIF
     SJZ->(dbskip())
   END
ENDIF


cTitulo:=STR0304 //STR0304 "Consulta Padrao Fundamento Legal Base Pis/Confins"
Work_SJZ->(dbgotop())
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 4,3 TO 20,55 OF oMainWnd

         //by GFP - 06/10/2010 - 14:44 - Inclusão da função para carregar campos criados pelo usuario.
         TB_Campos := AddCpoUser(TB_Campos,"SJZ","2")

         oMark:= MsSelect():New("Work_SJZ",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160},;
         "","")

         oMark:baval:=bReturn

         DEFINE SBUTTON FROM 10,165 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlg PIXEL
         DEFINE SBUTTON FROM 25,165 TYPE 2 ACTION (lOK:=.F.,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg

DBSELECTAREA(OldArea)
RETURN lOk

*-------------------------------------------------------------------------------------*
FUNCTION DI500DescRegTri(cRegTri)
*-------------------------------------------------------------------------------------*
SJP->(DBSETORDER(1))
SJP->(DBSEEK(xFilial()+cRegTri))
RETURN LEFT(SJP->JP_DESC,34)

*-------------------------------------------------------------------------------------*
FUNCTION DI500IPIDescRegTri(cRegTri)
*-------------------------------------------------------------------------------------*
LOCAL cRet:=""
IF LEN(aCbox) > 0
   nPos1:=ASCAN(aCbox,{|X| X[1] = cRegTri})
   IF nPos1 > 0
      cRet:= SUBSTR(aCbox[nPos1][2],3)
   ENDIF
ENDIF

RETURN cRet

*-------------------------------------------------------------------------------------*
Function WhEIJ(cNomeCampo)
*-------------------------------------------------------------------------------------*
Private lRet:=.T.

IF lDISimples
   RETURN DI500DSIValid(cNomeCampo,.F.,.T.)
ENDIF

Do Case

//***************  ICMS *****************
   CASE cNomeCampo == 'EIJ_EXOICM'
      IF M->EIJ_REGICM # '8'
         lRet:= .F.
      ENDIF

   CASE cNomeCampo == 'EIJ_REGICM'
      If !lGetRegTri .and. lIntDraw .and. M->EIJ_REGICM = "5" .and. Alltrim(M->EIJ_EXOICM) == "16"  //GFC 26/11/2003
         lRet:=.F.
      EndIf

//****************  II ******************
   CASE cNomeCampo == 'EIJ_FUNREG'
      If !lGetRegTri .and. lIntDraw .and. M->EIJ_REGTRI $ "3/5" .and. Alltrim(M->EIJ_FUNREG) == "16"  //GFC 26/11/2003
         lRet:=.F.
      ElseIF M->EIJ_REGTRI $ '1'
         lRet:= .F.
      ENDIF

   CASE cNomeCampo == 'EIJ_REGTRI'
      If !lGetRegTri .and. lIntDraw .and. M->EIJ_REGTRI $ "3/5" .and. Alltrim(M->EIJ_FUNREG) == "16"  //GFC 26/11/2003
         lRet:=.F.
      EndIf

//****************  IPI *****************
   CASE cNomeCampo == 'EIJ_REGIPI'
      If !lGetRegTri .and. lIntDraw .and. M->EIJ_REGTRI $ "3/5" .and. Alltrim(M->EIJ_FUNREG) == "16"  //GFC 26/11/2003
         lRet:=.F.
      ElseIF M->EIJ_REGTRI = '6'
         lRet:= .F.
      ENDIF

EndCase

Return lRet
*-------------------------------------------------------------------------------------*
Function DI500D_OriFin(aAutoCab)  // JBS - 23/04/2004
*-------------------------------------------------------------------------------------*
Local oDlgFIN
Local lRetorno :=.F.
Local aVarMem  := {"WD_DESPESA","WD_BASEADI","WD_PAGOPOR","WD_GERFIN"}
Local aBaseAdi := ComboX3Box("WD_BASEADI")
Local aGerFin  := ComboX3Box("WD_GERFIN")
Local aPagoPor := ComboX3Box("WD_PAGOPOR")
Local i
Local cFilSYB:=xFilial('SYB') // JBS - 28/04/2004
Local aBotoes:= {}  // JBS - 28/04/2004
Local oPanel
Local nLin

default aAutoCab := {}

Private lWhenDesp := .T.
Private lWhenAdian  := .T.
Private lWhenPgPor  := .T.
Private lWhenGrFin  := .T.

// JBS - 01/05/2004
IF SWD->(FIELDPOS("WD_PREFIXO")) = 0 .OR.;
   SWD->(FIELDPOS("WD_PARCELA")) = 0 .OR.;
   SWD->(FIELDPOS("WD_TIPO"   )) = 0
   MSGSTOP(STR0305) //STR0305 "Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao existe."
   Return(.f.)
ENDIF

SX3->(dbSetOrder(2))
For i:=1 to len(aVarMem)
    If SX3->(dbSeek(aVarMem[i]))
       If ExistIni(aVarMem[i])
          M->&aVarMem[i] :=  InitPad(SX3->X3_RELACAO)
       EndIf
    EndIf
Next

// execauto de despesas
if isMemVar("lDespAuto") .and. lDespAuto
   lRetorno := EnchAuto("SWD",aAutoCab, { || DI500ValDesp("WD_DESPESA") .and. DI500ValDesp("WD_BASEADI") .and. DI500ValDesp("GATILHO") } ,3,aVarMem) .AND. lRet
else
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ALTERA_WHEN"),)
   DEFINE MSDIALOG oDlgFIN FROM 00,00 TO 250, 380 PIXEL TITLE STR0306 OF oMainWnd //STR0306 "Contas a Pagar"

      oPanel:= TPanel():New(0, 0, "", oDlgFIN,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT


      //@ 15,05 TO 85, 300 PIXEL OF oPanel
      nLin:= 17
      @ nLin,09 say AVSX3("WD_DESPESA",5)  SIZE 40,10 PIXEL OF oPanel
      nLin += 15
      @ nLin,09 say AVSX3("WD_BASEADI",5)  SIZE 40,10 PIXEL OF oPanel
      nLin += 15
      @ nLin,09 say AVSX3("WD_PAGOPOR",5)  SIZE 40,10 PIXEL OF oPanel
      nLin += 15
      @ nLin,09 say AVSX3("WD_GERFIN",5)   SIZE 40,10 PIXEL OF oPanel

      nLin:= 17
      @ nLin,55 msGet M->WD_DESPESA F3 "SYB" SIZE 40,10 VALID DI500ValDesp("GATILHO") WHEN lWhenDesp PICTURE AVSX3("WD_DESPESA",6) PIXEL OF oPanel
      nLin += 15
      @ nLin,55 ComboBox oBaseAdi VAR M->WD_BASEADI VALID DI500ValDesp("WD_BASEADI") WHEN lWhenAdian ITEMS aBaseAdi SIZE 40,10 PIXEL OF oPanel
      nLin += 15
      @ nLin,55 ComboBox oPagoPor VAR M->WD_PAGOPOR VALID AVSX3("WD_PAGOPOR",7) WHEN lWhenPgPor ITEMS aPagoPor SIZE 50,10 PIXEL OF oPanel     //AWR - MATEC (M->WD_DESPESA = "901") .OR. (M->WD_BASEADI = "2")
      nLin += 15
      @ nLin,55 ComboBox oGerFin  VAR M->WD_GERFIN  VALID AVSX3("WD_GERFIN" ,7) ITEMS aGerFin  SIZE 50,10 PIXEL OF oPanel WHEN (M->WD_DESPESA # "901") .AND. (M->WD_BASEADI = "2") .AND. lWhenGrFin

   //ACTIVATE MSDIALOG oDlgFIN ON INIT DI500EnchoiceBar(oDlgFIN,{{|| if(DI500ValDesp("WD_DESPESA"),(lRetorno:=.T.,oDlgFIN:End()),)},"OK"},,.F.,aBotoes) CENTERED
   ACTIVATE MSDIALOG oDlgFIN ON INIT EnchoiceBar(oDlgFIN,{|| if(DI500ValDesp("WD_DESPESA"),(lRetorno:=.T.,oDlgFIN:End()),)},{||oDlgFIN:End()},.F.,aBotoes) CENTERED //FDR - 18/08/11
endif

IF lRetorno    // JBS - 28/04/2004
   SYB->(dbSeek(cFilSYB+M->WD_DESPESA))
   M->WD_DESCDES := SYB->YB_DESCR
ENDIF

Return(lRetorno)
*-------------------------------------------------------------------------------------*
Function DI500ValDesp(cCampo)  // AWR - 17/05/2004
*-------------------------------------------------------------------------------------*
IF cCampo == "GATILHO"

   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ALTERA_GATILHO"),)
   IF M->WD_DESPESA = "901" .OR. M->WD_BASEADI # "2"
      M->WD_GERFIN := "2"
   ENDIF
 //** SVG 02/09/2009 - Não permitir a inclusao de despesas diferentes de 902 e 903 em processo que já possui nota unica.
   If lNaoNFCompl
      SF1->(DBSETORDER(5))
      If SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+"3"))
         IF !(M->WD_DESPESA $ "902/903")
            MsgInfo(STR0307) //STR0307 "Processo possui Nota Fiscal Unica, despesas diferentes de 902 e 903 não podem serem lançadas."
            RETURN .F.
         EndIf
      Endif
   EndIf
 //**

ELSEIF cCampo == "WD_BASEADI"

   IF !Pertence("12",M->WD_BASEADI)
      RETURN .F.
   ENDIF
   IF M->WD_BASEADI # "2"
      M->WD_GERFIN  := "2"
   ENDIF

ELSEIF cCampo == "WD_DESPESA"

   IF !NaoVazio(M->WD_DESPESA)
      RETURN .F.
   ENDIF
   IF !EVAL(AVSX3("WD_DESPESA",7))
      RETURN .F.
   ENDIF

ENDIF

RETURN .T.

*-------------------------------------------------------------------------------------*
Function DI500GrvDESP(cOpcao,lContab)  // JBS - 23/04/2004
*-------------------------------------------------------------------------------------*
LOCAL cFilSYB:=xFilial('SYB') // JBS - 28/04/2004
DEFAULT lContab := .T.
PRIVATE lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC")

If cOpcao =="2"     // Inclusao
   M->WD_HAWB := SW6->W6_HAWB
   //FDR - 18/04/13
   IF SWD->(FieldPos("WD_DA_ORI")) > 0
      IF SW6->W6_TIPOFEC == "DIN"
         M->WD_DA_ORI := '2'
      ENDIF
   ENDIF
   SWD->(RecLock("SWD",.T.))
   AVREPLACE("M","SWD")
   //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
   If lAvIntFinEIC
      SWD->WD_LINHA := DI500SWDLin()
   EndIf
   SWD->WD_FILIAL:= xFilial("SWD")
   If Type("lCposNFDesp") <> "U" .AND. lCposNFDesp                      //NCF - 30/08/2010 - Campos da nota Fiscal de Despesas
      SWD->WD_B1_COD  := SYB->YB_PRODUTO
      SWD->WD_ESPECIE := SYB->YB_ESPECIE
   Endif
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"INCLUI_DESP"),)
   SWD->(MSUNLOCK())

   TRB->(dbAppend())
   AVREPLACE("M","TRB")
   If Type("lCposNFDesp") <> "U" .AND. lCposNFDesp                      //NCF - 30/08/2010 - Campos da nota Fiscal de Despesas
      TRB->WD_B1_COD  := SYB->YB_PRODUTO
      TRB->WD_ESPECIE := SYB->YB_ESPECIE
   Endif
   TRB->RECNO := SWD->(RECNO())
   If AvFlags("EIC_EAI")
      TRB->WKSTATUS:= DI501AtuStatusDesp()
   EndIf
   AADD(aIncluiSWD,{"SWD",TRB->RECNO})

   IF lFinanceiro .and.;
      SWD->(FIELDPOS("WD_PREFIXO")) # 0 .and.;
      SWD->(FIELDPOS("WD_PARCELA")) # 0 .and.;
      SWD->(FIELDPOS("WD_TIPO"   )) # 0

      SE2->(DBSETORDER(1))
      IF SE2->(DBSEEK(xFilial("SE2")+SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA))
         IF FindFunction("F050EasyOrig")
            SE2->(RECLOCK("SE2",.F.))
            SE2->E2_ORIGEM:="SIGAEIC"
            SE2->(MSUNLOCK())
         ELSE
            IF Alltrim(SE2->E2_TIPO) == "INV"   //!Alltrim(SE2->E2_TIPO) == "NF" //GFP - 14/08/2015 - Sistema deve gravar Origem apenas quando tipo do titulo for INV.
               SE2->(RECLOCK("SE2",.F.))
               SE2->E2_ORIGEM:="SIGAEIC"
               SE2->(MSUNLOCK())
            ELSE
               SE2->(RECLOCK("SE2",.F.))
               SE2->E2_ORIGEM:=""
               SE2->(MSUNLOCK())
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   IF lContab
      EICFI400("FI400MOVCONT_I")
   ENDIF

ElseIf cOpcao =="3" // Alteracao
   IF !EMPTY(TRB->RECNO)
      AADD(aAlteraSWD,{"SWD",TRB->RECNO})
   ENDIF

   SWD->(DBGOTO(TRB->RECNO))
   M->WD_HAWB := SW6->W6_HAWB
   //FDR - 18/04/13
   IF SWD->(FieldPos("WD_DA_ORI")) > 0
      IF SW6->W6_TIPOFEC == "DIN"
         M->WD_DA := SWD->WD_DA_ORI
      ENDIF
   ENDIF

   /*LGS-28/10/13 - Foi Incluido verificação antes da utilização da variavel.
     Isso garante que não gere erros em processos onde a variavel não é utilizada. Este processo tinha sido nopado mas é necessario
     no processo onde o Financeiro e criado a partir da alteração da despesa. Campo "WD_GERFIN"=SIM. */
   lDespesa := IF(TYPE("lDespesa" )<>"L",.F.,lDespesa)
   If !Empty(TRB->WD_NF_COMP) .And. lDespesa == .T.
	 If M->WD_VALOR_R # TRB->WD_VALOR_R
	    M->WD_VALOR_R:= TRB->WD_VALOR_R
	 EndIf
   EndIf

   AVREPLACE("M","TRB")
   If AvFlags("EIC_EAI")
      TRB->WKSTATUS:= DI501AtuStatusDesp()
   EndIf
   SWD->(RecLock("SWD",.F.))
   AVREPLACE("TRB","SWD")
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"ALTERA_DESP"),)
   SWD->(MSUNLOCK())
   SYB->(dbSeek(cFilSYB+SWD->WD_DESPESA))

ElseIf cOpcao =="4" // Exclusao
   IF !EMPTY(TRB->RECNO)
//    AADD(aDeletados,{"SWD",TRB->RECNO})
      AADD(aDeletados,TRB->RECNO)// AWR - 7/5/4 - os rdmakes dos clientes usam dessa forma
   ENDIF

   SWD->(DBGOTO(TRB->RECNO))
   IF lContab
      EICFI400("FI400MOVCONT_E")
   ENDIF
   IF(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"DELETA_DESP"),)
   SWD->(RecLock("SWD",.F.))
   SWD->(DBDELETE())
   SWD->(MSUNLOCK())

   TRB->(DBDELETE())
   TRB->(DBGOTOP())

   TRB->(DI500VERTRB())
EndIf

Return(.T.)
*--------------------------------------------------------*
FUNCTION DI500VERTRB() // JBS 23/04/2004
// Alias já´passado na chamada da função
*--------------------------------------------------------*
Pack  // Corrige problema do browse qdo nao existe reg. valido.
RETURN(.T.)

// AWR - Lote - 07/06/2004 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
*-----------------------------------------------*
Function DI500Lotes()
*-----------------------------------------------*
LOCAL oDlg, lTemItens:=.F.,C // do FOR
Local oSize,oTFont,oPanel
Local cHawb := ""
Local nTam
Local nAlt

PRIVATE aForn:={},aPLIs:={},aPOs:={},aInvoice:={}
PRIVATE cPLI,cPO,cInvoice,oMarkItens,nSelOp
PRIVATE oCboPLI,oCboPO,oInv,oCboFor
PRIVATE aBotaoLote:={},bBlocSel:={||.T.}
PRIVATE dDtValLote := CTOD("")  // GFP - 19/03/2014
PRIVATE lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO") //NCF - 27/02/2019
PRIVATE dDtFabLote := CTOD("")

IF !Inclui
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(EOF()) .AND. Work_SW8->(BOF()) //LRS - 27/02/2018
         Processa({|| DI500InvCarrega()},STR0180) //STR0180"Pesquisa de Itens"
      ENDIF
      if  Work_SWV->(EOF()) .AND. Work_SWV->(BOF())
         DI500SWVGrv(.T.)
      endif
      DI500VerLotes(.T.)
      Return .T.
   ELSEIF lPrimeiraVez
      Processa({|| DI500Existe() },STR0180) //STR0180"Pesquisa de Itens"
   ENDIF
ENDIF

Work_SWV->(DBSETORDER(1))
Work_SWV->(DBGOTOP())
SA2->(DBSETORDER(1))
Work_SW8->(DBGOTOP())

DO WHILE Work_SW8->(!EOF())

   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   lTemItens:=.T.
   IF ASCAN( aForn, Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")  ) == 0
      SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")))
      AADD ( aForn, Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+" - "+ALLTRIM(SA2->A2_NREDUZ)  )
      cForn:=aForn[1]
      cLoja:=EICRetLoja("Work_SW8", "W8_FORLOJ") //SVG
   ENDIF

   IF ASCAN( aInvoice, Work_SW8->WKINVOICE ) == 0
      AADD ( aInvoice, Work_SW8->WKINVOICE )
      cInvoice:=aInvoice[1]
   ENDIF

   IF ASCAN( aPLIs, Work_SW8->WKPGI_NUM ) == 0
      AADD ( aPLIs, Work_SW8->WKPGI_NUM )
      cPLI:=aPLIs[1]
   ENDIF

   IF ASCAN( aPOs, Work_SW8->WKPO_NUM ) == 0
      AADD ( aPOs, Work_SW8->WKPO_NUM )
      cPO:=aPOs[1]
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO
//MFR 27/07/2021 OSSME-6090 Se colocar esse controle logo no íncio do códido, depois dá erro quando dá o zap na work 
If AvFlags("DUIMP")
  if M->W6_TIPOREG == "2"
     EasyHelp(STR0400, STR0375, STR0401) //'Opção não disponível quando o tipo de registro for "DUIMP". ## Atenção ## Utilize a rotina "Vinculação de LPCO" para informar os lotes para os itens do processo.'
     Return .t.
  EndIf
EndIf  

IF !lTemItens
   MSGSTOP(STR0308) //STR0308 "Processo nao possui Itens de Invoice."
   Work_SW8->(DBGOTOP())
   RETURN .T.
ENDIF

Work_SWV->(DBSETORDER(1))
Work_CWV->(DBGOTOP())
DO While !Work_CWV->(Eof())
   IF !Work_SWV->(DBSEEK(Work_CWV->WV_LOTE+Work_CWV->WV_FORN+EICRetLoja("WORK_CWV", "WV_FORLOJ")+DTOS(Work_CWV->WV_DT_VALI)))
      Work_CWV->(DBDELETE())
   ENDIF
   Work_CWV->(DBSKIP())
ENDDO
DBSELECTAREA("Work_CWV")
PACK

nCol   := 130
nLin   := 4
aCamposTWV:={}
AADD(aCamposTWV,{"WKFLAGLOT" ,,""})
AADD(aCamposTWV,{"WKDISPLOT" ,,STR0309  ,AVSX3("WV_QTDE",6)}) //STR0309 "Qtde Disp Lote"
AADD(aCamposTWV,{"WV_QTDE"   ,,AVSX3("WV_QTDE",5),AVSX3("WV_QTDE",6)})

aCposTira:={ AVSX3("WV_LOTE",5),AVSX3("WV_DT_VALI",5),AVSX3("WV_OBS",5),AVSX3("WV_QTDE",5) }
If lCpoDtFbLt
   aAdd(aCposTira, AVSX3("WV_DFABRI",5) )
EndIf
If AvFlags("DUIMP")
   aAdd(aCposTira, AVSX3("WV_HAWB",5) )
   aAdd(aCposTira, AVSX3("WV_SEQUENC",5) )
Endif
aCposTWV:=ArrayBrowse("SWV","WORK_TWV")

FOR C := 1 TO LEN(aCposTWV)
    IF ASCAN(aCposTira, {|cTira| ALLTRIM(aCposTWV[C,3]) = ALLTRIM(cTira) }) = 0
       AADD(aCamposTWV,aCposTWV[C])
    ENDIF
NEXT

lLoteInclui:=.F.

aCposMostra:={}
AADD(aBotaoLote,{"PREV"    ,{|| IF(DI500LoteVal("LOTE",,.T.),(nSelOp:=1,oDlg:End()),) },STR0201,STR0202 }) // STR0201"Tela Anterior" //STR0202 "Anterior"
AADD(aBotaoLote,{"NEXT"    ,{|| IF(DI500LoteVal("LOTE",,.T.),(nSelOp:=2,oDlg:End()),) },STR0310,STR0311 }) //"STR0310 Proxima Tela" // STR0311 := "Proximo"
AADD(aBotaoLote,{"CONTAINR",{|| DI500VerLotes(.F.)     },STR0312,STR0313}) //STR0312 "Todos os Lotes" //STR0313 "Lotes"
AADD(aBotaoLote,{"RESPONSA",{|| DI500MLotes(),oMarkItens:oBrowse:Refresh() }, STR0209,STR0314}) // STR0209 "Marca/Desmarca Todos" //STR0314	"Marc/Des"
aTelaSW6:=ACLONE(aTela)
aGetsSW6:=ACLONE(aGets)
aCposGet:={"WV_DT_VALI","WV_OBS"}
If lCpoDtFbLt
   aAdd(aCposGet,"WV_DFABRI")
EndIf
aTela:={}
aGets:={}
DBSELECTAREA("Work_CWV")
FOR C := 1 TO FCount()
    IF FIELDNAME(C) # "WV_LOTE"
       AADD(aCposGet,FIELDNAME(C))
    ENDIF
NEXT

IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"COLUNAS_BOTOES_LOTES"),)

Work_CWV->(DBGOTOP())
nSelOp := 0

DO WHILE .T.

   IF nSelOp = 1     // Anterior
      Work_CWV->(DBSKIP(-1))
      IF Work_CWV->(BOF())
         Work_CWV->(DBGOBOTTOM())
      ENDIF
   ELSEIF nSelOp = 2 // Proximo
      Work_CWV->(DBSKIP())
      IF Work_CWV->(EOF())
         Work_CWV->(DBGOTOP())
      ENDIF
   ELSEIF nSelOp = 4 // Exclusao
      Work_CWV->(DBSKIP(-1))
   ENDIF
   IF (Work_CWV->(EOF()) .AND. Work_CWV->(BOF())) .OR. lLoteInclui //LRS - 27/02/2018 - Retirado o LastRec substituido por EOF
      DBSELECTAREA("Work_CWV")
      FOR C := 1 TO FCount()
         If FieldName(C) <> "DBDELETE"   //NCF - 04/12/2017 - Não criar variável de memória para o campo DBDELETE padrão para arquivos temporários
            M->&(FIELDNAME(C)) := CRIAVAR(FIELDNAME(C))
         EndIf
      NEXT
      M->WV_LOTE   := CRIAVAR("WV_LOTE")
      M->WV_DT_VALI:= CRIAVAR("WV_DT_VALI")
      M->WV_OBS    := CRIAVAR("WV_OBS")
      If lCpoDtFbLt
         M->WV_DFABRI := CRIAVAR("WV_DFABRI")
      EndIf
      Work_TWV->(DBSETORDER(1))
      Work_TWV->(DBGOTOP())
      lLoteInclui  := .T.
      IF !DI500CrgTWV("","",{|| .T. },,CtoD(""))
         MSGSTOP(STR0315) //STR0315 "Não existem mais itens disponiveis para Lotes."
         lLoteInclui:= .F.
         nSelOp:=3
         LOOP
      ENDIF
   ELSE
      DBSELECTAREA("Work_CWV")
      FOR C := 1 TO FCount()
         M->&(FIELDNAME(C)) := FIELDGET(C)
      NEXT
      M->WV_LOTE   := Work_CWV->WV_LOTE
      M->WV_DT_VALI:= Work_CWV->WV_DT_VALI
      dDtValLote   := M->WV_DT_VALI  // GFP - 19/03/2014
      If lCpoDtFbLt
         dDtFabLote   := M->WV_DFABRI
      EndIf
      M->WV_OBS    := Work_CWV->WV_OBS
      DI500CrgTWV(Work_CWV->WV_LOTE,Work_CWV->WV_FORN,{|| .T. },,Work_CWV->WV_DT_VALI, EICRetLoja("WORK_CWV", "WV_FORLOJ"))
      IF (nPos:=ASCAN(aForn, { |F| F = Work_CWV->WV_FORN })) # 0
         cForn:=aForn[nPos]
      ENDIF
      lLoteInclui:=.F.
   ENDIF

   nSelOp := 0

   oSize:= FwDefSize():New( .F. )
   nTam := 100
   nAlt := 100
   oSize:AddObject( "ENCHOICE" , nTam,nAlt, .T., .T.  ) // enchoice
   nTam := 100
   nAlt := 250
   oSize:AddObject( "GETDADOS", nTam,nAlt, .T., .T.  ) // grid
   oSize:lProp := .T.
   oSize:Process()

   DEFINE MSDIALOG oDlg TITLE STR0316 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL OF oMainWnd

   //DEFINE MSDIALOG oDlg TITLE STR0316 FROM 0,0 TO 28,99 Of oMainWnd //STR0316 "Manutenção de Lotes"
      aTam := {oSize:GetDimension("ENCHOICE","LININI")+6,oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND")*0.70,oSize:GetDimension("ENCHOICE","COLEND")-10}
      oPanel:= TPanel():New(aTam[1],aTam[2], "", oDlg,, .F.,,,, aTam[4], aTam[3], .T. ,.T. )
      //oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      aCposMostra:={"WV_LOTE","WV_DT_VALI","WV_OBS"}
      If lCpoDtFbLt
         aAdd(aCposMostra,"WV_DFABRI")
      EndIf
      aCposMostra:=AddCpoUser(aCposMostra, "SWV", "1")

      IF lLoteInclui .or. ( alltrim(str(nSelOp)) $ '2|1' .and. !lLoteInclui )
         aCamposGet:=NIL
      ELSE
         aCamposGet:=aCposGet
      ENDIF
      
      IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500LOTES_ALT_CPOSENC"),)  //ISS - 29/10 - Ponto de entrada para editar os campos que serão apresentados.
   
      // ANTES DA ENCHOICE
      oTFont := TFont():New('Courier new',,-16,,.T.)
      nTam := oSize:GetDimension("ENCHOICE","COLINI")
      nAlt := oSize:GetDimension("ENCHOICE","LINEND")*0.03
      cHawb := "Processo " + alltrim( cPO ) // + "/" + alltrim( cInvoice)
      @ nAlt,nTam SAY oSay PROMPT cHawb SIZE 200,20 OF oPanel FONT oTFont PIXEL //STR0317 "Fornecedor"

      // FORNECEDOR E COMBO BOX
      nAlt := oSize:GetDimension("ENCHOICE","LINEND")*0.13
      @ nAlt,nTam SAY oSay1 PROMPT STR0317 SIZE 100,10 OF oPanel PIXEL //STR0317 "Fornecedor"

      nAlt := oSize:GetDimension("ENCHOICE","LINEND")*0.20
      @ nAlt,nTam COMBOBOX cForn ITEMS aForn SIZE 180,18 OF oPanel PIXEL VALID DI500LoteVal("COMBOFORN",,.F.) //WHEN lLoteInclui 

      // BOTÕES DA TELA 
      nTam := oSize:GetDimension("ENCHOICE","COLEND") * 0.9
      nAlt := oSize:GetDimension("ENCHOICE","LINEND") * 0.2
      @nAlt,nTam BUTTON oBtn1 PROMPT STR0318 SIZE 50,15 ; //STR0318 "Inclui Lote"  WHEN lLoteInclui
                          ACTION (  (nSelOp:=3,oDlg:End())  ) OF oPanel PIXEL
      nAlt += 17
      @nAlt,nTam BUTTON oBtn2 PROMPT STR0319 SIZE 50,15 WHEN !EMPTY(M->WV_LOTE) ; //STR0319 "Exclui Lote"
                          ACTION (  (nSelOp:=4,oDlg:End()) ) OF oPanel PIXEL
      nAlt += 17
      @nAlt,nTam BUTTON oBtn3 PROMPT STR0320 SIZE 50,15 ; //STR0320 "Filtra Itens"
                          ACTION ( DI500Filtra(),oMarkItens:oBrowse:Refresh() ) OF oPanel PIXEL

      DBSELECTAREA("Work_TWV")
      DBSETORDER(1)
      DBGOTOP()

      // ENCHOIDE
      //Enchoice("SWV",1,3,,,,aCposMostra,{35,02,100,COLUNA_FINAL-110},aCamposGet,3,,,,,,,,,.T.)//19o. parametro com .T.: Desabilita as Pastas   // GFP - 01/04/2013
      // ( cAlias [ nReg ]nOpc [ aCRA ] [ cLetras ] [ cTexto ] [ aAcho ] [ aPos ] [ aCpos ] [ nModelo ] [ nColMens ] [ cMensagem ] [ cTudoOk ] [ oWnd ] [ lF3 ] [ lMemoria ] [ lColumn ] [ caTela ] [ lNoFolder ] [ lProperty ] [ aField ] [ aFolder ] [ lCreate ] [ lNoMDIStretch ] )
      aTam := {oSize:GetDimension("ENCHOICE","LINEND")*0.37,oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND")*0.75,oSize:GetDimension("ENCHOICE","COLEND")*0.8}
      Enchoice("SWV",1,3,,,,aCposMostra,aTam,aCamposGet,3,,,,oPanel,,,,,.T.)

      aCamposTWV := AddCpoUser(aCamposTWV,"SWV","2")

      // GET DADOS
      aTam := { oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND") }
      //( < cAlias>, [ cCampo], [ cCpo], [ aCampos], [ lInv], [ cMar], < aCord>, [ cTopFun], [ cBotFun], < oWnd>, [ uPar11], [ aColors] )
      oMarkItens:=MSSELECT():New("Work_TWV","WKFLAGLOT",,aCamposTWV,lInverte,cMarca,aTam,,,oDlg)
      //oMarkItens:=MSSELECT():New("Work_TWV","WKFLAGLOT",,aCamposTWV,lInverte,cMarca,{nPosTop,2,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_TWV'),DBSETORDER(1),.T.}
      oMarkItens:bAval:={|| DI500GetQtde(),oMarkItens:oBrowse:Refresh() }
      oMarkItens:oBrowse:Align:=CONTROL_ALIGN_BOTTOM
      oDlg:lMaximized:=.T.

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nSelOp:=5 , iIF(Obrigatorio(aGets,aTela) .and. DI500LoteVal("LOTE",,.T.) ,(oDlg:End()),) },;//acb - 03/11/2010 - incluido função obrigatorio() para validar os campo obrigatorio
                                                         {|| (nSelOp:=0,oDlg:End()) },.F.,aBotaoLote), oMarkItens:oBrowse:Refresh()) CENTERED

   IF nSelOp # 0
      lGravaSWV:=.T.
      IF !EMPTY(M->WV_LOTE)
         Processa({|| DI500GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)+IF(EICLOJA(),LEN(WORK_SWV->WV_FORLOJ),0))+DTOS(M->WV_DT_VALI)) })
      ELSEIF lLoteInclui
         lLoteInclui := .F.
      ENDIF
      IF nSelOp = 3 // Inclusao
         lLoteInclui := .T.
      ENDIF
      IF nSelOp = 5 // OK
         IF DI500LoteVal("VAL_LOTE_PLI",,.F.)
            EXIT
         ENDIF
      ENDIF
      LOOP
   ENDIF

   EXIT

Enddo

aTela:=ACLONE(aTelaSW6)
aGets:=ACLONE(aGetsSW6)

Return NIL
*-----------------------------------*
FUNCTION DI500GetQtde()
*-----------------------------------*
LOCAL nOpca:= 0
PRIVATE nQtde:=IF(!EMPTY(Work_TWV->WV_QTDE),Work_TWV->WV_QTDE,Work_TWV->WKDISPLOT)

IF !DI500LoteVal("GET_QTDE")
   RETURN .F.
ENDIF

DEFINE MSDIALOG oDlgGet TITLE AVSX3("WV_QTDE",5) FROM 9,10 TO 18,48 Of oMainWnd

  @1.2,01 SAY AVSX3("WV_QTDE",5)
  @1.2,05 MSGET nQtde PICTURE _PictQtde  SIZE 50,8 VALID (Positivo(nQtde))

  @14,105 BUTTON "OK"    SIZE 25,11 ACTION (IF(DI500LoteVal("QTDE",nQtde),(nOpca:=1,oDlgGet:End()),)) OF oDlgGet PIXEL
  @34,105 BUTTON STR0172 SIZE 25,11 ACTION (nOpca:=0,oDlgGet:End())                             OF oDlgGet PIXEL //STR0172  "Sair"

  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"TELA_GET_QTDE"),)

ACTIVATE MSDIALOG oDlgGet CENTERED

IF nOpca = 1
   DI500MarLote(nQtde)
ENDIF

Return NIL
*-----------------------------------*
FUNCTION DI500MarLote(nQtde)
*-----------------------------------*
IF nQtde > 0
   Work_TWV->WV_QTDE  := nQtde
   Work_TWV->WKFLAGLOT:= cMarca
ELSE
   Work_TWV->WV_QTDE  := 0
   Work_TWV->WKFLAGLOT:= ""
ENDIF

Return .T.

*---------------------------------------------------------------------------------------------------------*
FUNCTION DI500LoteVal(cCampo,nQtde,lVerItens,cChave)
*---------------------------------------------------------------------------------------------------------*
LOCAL nRecno,nOrder,nPLI // do FOR
Private cValCampo := cCampo //ISS - 17/02/11 - variável para a identificação do campo que vai ser validado
Private lValLote := .T.
DEFAULT lVerItens := .F.

//NCF - 27/02/2019
If AvFlags("DATA_FABRIC_LOTE_IMPORTACAO") 
   If ReadVar() == "M->WV_DT_VALI" .Or. ReadVar() == "M->WV_DFABRI"
      IF ReadVar() == "M->WV_DFABRI" .And. !Empty(M->WV_DFABRI) .And. M->WV_DFABRI > dDatabase  
         MSGSTOP(STR0398) //"A data de fabricação não pode ser maior que a data base do sistema!"
         Return .F.
      EndIf  
      If ( !Empty(M->WV_DFABRI) .And. !Empty(M->WV_DT_VALI) )  .And. (  M->WV_DFABRI > M->WV_DT_VALI  )
         MSGSTOP(STR0397) //"A data de fabricação não pode ser maior que a data de validade!"   
         Return .F.
      EndIf
   EndIf
EndIf

IF SELECT("Work_SWV") = 0
   RETURN .T.
ENDIF

//ISS - 17/02/11 - Ponto de entrada para a validação do lote
If EasyEntryPoint("EICDI500")
   Execblock("EICDI500",.F.,.F.,"DI500LOTEVAL_VALLOTE")
EndIf

If IsMemVar("lValLote") .AND. !lValLote
   Return lValLote
EndIf

IF cCampo == "GET_QTDE"
   IF EMPTY(M->WV_LOTE)
      MSGSTOP(STR0321) //STR0321 "Lote não preenchido."
      Return .F.
   ENDIF
   IF cForn # Work_TWV->WV_FORN
      MSGSTOP(STR0322) //STR0322 "Fornecedor difere do Item Atual."
      Return .F.
   ENDIF

ELSEIF cCampo == "COMBOFORN"
   Work_SWV->(DBSETORDER(1))
   //TDF - 17/09/2012 - TRATAMENTO DE LOJA
   IF Work_SWV->(DBSEEK(M->WV_LOTE+Left(cForn,AVSX3("WV_FORN",3))+IF(EICLOJA(),cLoja,"")+DTOS(M->WV_DT_VALI))) .AND. lLoteInclui
      MSGSTOP(STR0323) //STR0323 "Lote ja existe p/ esse Fornecedor e Data de Validade."
      Return .F.
   ENDIF

   nRecno:=Work_TWV->(RECNO())
   nOrder:=Work_TWV->(INDEXORD())
   Work_TWV->(dbGoTop())
   DO While !Work_TWV->(Eof())

      If !EMPTY(Work_TWV->WV_QTDE) .AND. cForn # Work_TWV->WV_FORN
         MSGSTOP(STR0324) //STR0324 "Fornecedor nao pode ser alterado, pois ja existe itens marcados."
         Work_TWV->(DBSETORDER(nOrder))
         Work_TWV->(DBGOTO(nRecno))
         RETURN .F.
      EndIf

      Work_TWV->(dbSkip())

   ENDDO
   Work_TWV->(DBSETORDER(nOrder))
   Work_TWV->(DBGOTO(nRecno))

ELSEIF cCampo == "QTDE"
   IF nQtde > Work_TWV->WKDISPLOT
      MSGSTOP(STR0325)//STR0325 "Quantidade do Lote nao pode ser maior que a quantidade Disponivel."
      Return .F.
   ENDIF

ELSEIF cCampo == "LOTE" // Atencao: Esse CASE é chamado do X3_VALID do campo WV_LOTE tambem
   IF TYPE("cForn") # "C"
      RETURN .T.
   ENDIF
   IF EMPTY(M->WV_LOTE)
      RETURN .T.
   ENDIF
   Work_SWV->(DBSETORDER(1))
   //TDF - 17/09/12 - TRATAMENTO DE LOTE
   IF Work_SWV->(DBSEEK(M->WV_LOTE+Left(cForn,AVSX3("WV_FORN",3))+IF(EICLOJA(),cLoja,"")+DTOS(M->WV_DT_VALI))) .AND. lLoteInclui
      MSGSTOP(STR0326) //STR0326 "Lote ja existe p/ esse Fornecedor e Data de Validade."
      Return .F.
   Elseif Work_SWV->(DBSEEK(M->WV_LOTE+Left(cForn,AVSX3("WV_FORN",3))+IF(EICLOJA(),cLoja,""))) .and. M->WV_DT_VALI != Work_SWV->WV_DT_VALI .AND. lLoteInclui
      MSGSTOP( STR0399 + dtoc(Work_SWV->WV_DT_VALI) ) //STR0399 "Lote já existente para esse fornecedor com a data de validade diferente "
      Return .F.
   ENDIF

ELSEIF cCampo == "DEL_LOTE"

   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   Work_SWV->(DBSEEK(cChave))
   DO While Work_SWV->(DBSEEK(cChave))
      Work_SWV->(DBDELETE())
      Work_SWV->(dbSkip())
   ENDDO
   Work_SW8->WKDISPLOT:=WORK_SW8->WKQTDE

ELSEIF cCampo == "TEM_LOTE_AVISO"
   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   IF Work_SWV->(DBSEEK(cChave))
      IF MSGYESNO(STR0327) //STR0327 "Item pertence a um Lote,  Deseja Desmarcar ?"
         Return .T.
      ELSE
         Return .F.
      ENDIF
   ENDIF
   Return .T.

ELSEIF cCampo == "EXCLUI_LOTE"
   nRecno:=Work_SW8->(RECNO())
   nOrder:=Work_SW8->(INDEXORD())
   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   Work_SW8->(DBSETORDER(1))
   Work_SW8->(DBSEEK(WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))
   lExcluiLote:=.T.
   DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==WORK_SW9->W9_INVOICE .AND.;
                                     Work_SW8->WKFORN   ==WORK_SW9->W9_FORN    .And.;
                                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)
      IF Work_SWV->(DBSEEK(WORK_SW8->(WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE)))
         lExcluiLote:= MSGYESNO(STR0328) //STR0328 "Invoice possui itens com Lote,  Deseja Continuar ?"
         EXIT
      ENDIF
      Work_SW8->(DBSKIP())
   ENDDO
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
   Return lExcluiLote

ELSEIF cCampo == "VAL_LOTE_PLI"

   cFilSWV:=xFilial("SWV")
   SWV->(DBSETORDER(1))     //WV_FILIAL+WV_HAWB+WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)
   SW5->(DBSETORDER(1))

   cErro:=""
   FOR nPLI := 1 TO LEN(aPLIs)
       IF LEFT(aPLIs[nPLI],1) = "*"
          LOOP
       ENDIF
       SWV->(DBSEEK( cFilSWV+SPACE(LEN(SW6->W6_HAWB))+aPLIs[nPLI] ))
       DO While !SWV->(Eof()) .AND. cFilSWV == SWV->WV_FILIAL;
                              .AND. EMPTY(SWV->WV_HAWB);
                              .AND. LTRIM(aPLIs[nPLI]) == LTRIM(SWV->WV_PGI_NUM)

          SW5->(DBSEEK(xFilial()+SWV->WV_PGI_NUM))
          Work_SWV->(DBSETORDER(1))//"WV_LOTE+WV_FORN"
          lMensagem1:=.T.

          IF Work_SWV->(DBSEEK(SWV->WV_LOTE+SW5->W5_FORN+EICRetLoja("SW5", "W5_FORLOJ")+DtoS(SWV->WV_DT_VALI)))
             nQtdeEmb:=0
             cInvEmb :=" "//Tem que iniciar com espaco por causa do AT()
             Work_SWV->(DBSETORDER(3))//WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)

             IF Work_SWV->(DBSEEK(SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)+WV_LOTE)))
                lMensagem1:=.F.
                DO While !Work_SWV->(Eof()) .AND. SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)+WV_LOTE) == ;
                                             Work_SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+STR(WV_REG,nTamReg)+WV_LOTE)
                   nQtdeEmb+=Work_SWV->WV_QTDE
                   IF AT(cInvEmb,ALLTRIM(Work_SWV->WV_INVOICE)) = 0
                      cInvEmb+=ALLTRIM(Work_SWV->WV_INVOICE)+", "
                   ENDIF
                   Work_SWV->(dbSkip())
                ENDDO

                cInvEmb:=LEFT(cInvEmb,LEN(cInvEmb)-2)+"."
                IF nQtdeEmb # SWV->WV_QTDE
                   cQtde:=ALLTRIM(TRANS(SWV->WV_QTDE,AVSX3("WV_QTDE",6)))
                   cQtdeEmb:=ALLTRIM(TRANS(nQtdeEmb,AVSX3("WV_QTDE",6)))
                   cErro+=STR0329+ALLTRIM(SWV->WV_COD_I)+STR0330+cQtde+STR0331+; //STR0329 "O Produto: " //STR0330 ", tem alocado a quantidade " //STR0331 " p/ o Lote: "
                          ALLTRIM(SWV->WV_LOTE)+STR0332+ALLTRIM(TRANS(SWV->WV_PGI_NUM,AVSX3("WV_PGI_NUM",6)))+", "+; //STR0332 " na L.I.: "
                          STR0333+cQtdeEmb+STR0334+cInvEmb+CHR(13)+CHR(10)+CHR(13)+CHR(10) //STR0333 " que difere da quantidade " //STR0334 " atribuida a ele na(s) Invoice(s):"
                ENDIF
             ENDIF

          ENDIF

          IF lMensagem1
             cQtde:=ALLTRIM(TRANS(SWV->WV_QTDE,AVSX3("WV_QTDE",6)))
             cErro+=STR0329+ALLTRIM(SWV->WV_COD_I)+STR0330+cQtde+STR0331+; //STR0329 "O Produto: " //STR0330 ", tem alocado a quantidade " ///STR0331 " p/ o Lote: "
                    ALLTRIM(SWV->WV_LOTE)+STR0332+ALLTRIM(TRANS(SWV->WV_PGI_NUM,AVSX3("WV_PGI_NUM",6)))+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10)//STR0332 " na L.I.: "
          ENDIF

          SWV->(dbSkip())
       ENDDO
   NEXT


   DEFINE FONT oFont NAME "Courier New" SIZE 0,15

   nSair:=1

   IF !EMPTY(cErro)
      DEFINE MSDIALOG oDLGDescr TITLE STR0335 From 00,00 To 30,85 OF oMainWnd //STR0335 "Inconsistências encontradas nos Lotes"

       oDLGDescr:SetFont(oFont)
       @17,2 GET cErro MEMO HSCROLL SIZE 330,210 OF oDLGDescr PIXEL

      ACTIVATE MSDIALOG oDLGDescr ON INIT DI500EnchoiceBar(oDLGDescr,{{|| oDLGDescr:End() },"OK"},{|| nSair:=0,oDLGDescr:End()},.F.) CENTERED
   ENDIF

   IF nSair = 0
      RETURN .F.
   ENDIF

ENDIF

IF lVerItens
   Work_TWV->(dbGoTop())
   DO While !Work_TWV->(Eof())

      If Work_TWV->WV_QTDE # 0 //Quantidade
         Return .T.
      ENDIF

      Work_TWV->(dbSkip())

   ENDDO
   Work_TWV->(dbGoTop())
   MSGSTOP(STR0336) //STR0336 "Nao existe Itens selecionados para esse Lote."
   Return .F.
ENDIF

Return .T.

*-----------------------------------*
FUNCTION DI500VerLotes(lVisual)
*-----------------------------------*
LOCAL oMarkVer,oDlgLotes,aCamposSWV:=ArrayBrowse("SWV","WORK_SWV")

IF !lVisual .AND. !EMPTY(M->WV_LOTE)
   Processa({|| DI500GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)+IF(EICLOJA(),LEN(WORK_SWV->WV_FORLOJ),0))+DTOS(M->WV_DT_VALI)) })
ENDIF

DEFINE MSDIALOG oDlgLotes TITLE STR0337 FROM 0,0 TO 28,99 Of oMainWnd //STR0337 "Visualiza Lotes"

    DBSELECTAREA("Work_SWV")
    DBSETORDER(1)
    DBGOTOP()

    //by GFP - 07/10/2010 - 10:47 - Inclusão da função para carregar campos criados pelo usuario.
    aCamposSWV := AddCpoUser(aCamposSWV,"SWV","2")

    oMarkVer:=MSSELECT():New("Work_SWV",,,aCamposSWV,lInverte,cMarca,{25,2,(oDlgLotes:nClientHeight-6)/2,(oDlgLotes:nClientWidth-4)/2})
    oMarkVer:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
    oDlgLotes:lMaximized:=.T.

ACTIVATE MSDIALOG oDlgLotes; 
         ON INIT (oMarkVer:oBrowse:Refresh(),;
                  DI500EnchoiceBar(oDlgLotes, {{|| nSelOp:=0, oDlgLotes:End()} },{|| nSelOp:=0, oDlgLotes:End() },.F.)) CENTERED

DBSELECTAREA("Work_TWV")

Return .T.
*-----------------------------------*
FUNCTION DI500MLotes()
*-----------------------------------*
LOCAL lMarca:=.F.,nRecno := 0
IF EMPTY(M->WV_LOTE)
   MSGSTOP(STR0338)//STR0338 "Lote não preenchido."
   Return .F.
ENDIF
IF !DI500LoteVal("LOTE",,.F.)
   RETURN .F.
ENDIF
Work_TWV->(dbGoTop())
DO While !Work_TWV->(Eof())

   If cForn # Work_TWV->WV_FORN
      DI500MarLote(0)
      Work_TWV->(dbSkip())
      Loop
   EndIf
   IF nRecno = 0
      nRecno := Work_TWV->(RECNO())
      IF EMPTY(Work_TWV->WV_QTDE)
         lMarca:=.T.
      ENDIF
   ENDIF
   IF lMarca
      DI500MarLote(Work_TWV->WKDISPLOT)
   ELSE
      DI500MarLote(0)
   ENDIF

   Work_TWV->(dbSkip())

ENDDO

Work_TWV->(DBGOTO(nRecno))

RETURN .T.
*-----------------------------------*
FUNCTION DI500Filtra()
*-----------------------------------*
LOCAL oDlg, oRadio
LOCAL nLin := 17
LOCAL nColR:= 20
LOCAL nCol := nColR+111
LOCAL nColS:= nCol-35
LOCAL nSoma:= 16
LOCAL nMarcaOK:=0
bBlocSel:={||.T.}

IF !EMPTY(M->WV_LOTE)
   Processa({|| DI500GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)+IF(EICLOJA(),LEN(WORK_SWV->WV_FORLOJ),0))+DTOS(M->WV_DT_VALI)) })
ENDIF

DO WHILE .T.

   nLin := 17

   DEFINE MSDIALOG oDlg TITLE STR0339 FROM 0,0 TO 20,63 Of oMainWnd //STR0339 "Filtro de Itens"

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0) //LGS-03/02/2016
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   nOpRad:=4
   @nLin   ,nColR   TO nLin+75, nColR+54 LABEL STR0340 OF oPanel PIXEL //STR0340 "Seleção"
   @nLin+07,nColR+5 RADIO oRadio VAR nOpRad ITEMS STR0203,STR0295,"PLI",STR0206 3D SIZE 45,16 ;  //STR0203 "Pedido" //STR0295 "Invoice"  //STR0206 "Todos"
                                            PIXEL OF oPanel ON CHANGE (DI500CBOX(.T.))
   nLin+=10

   @nLin+.6, nColS SAY STR0203 OF oPanel PIXEL //STR0203 "Pedido"
   @nLin,    nCol  COMBOBOX oCboPO  VAR cPO      ITEMS aPOs     SIZE 105,18 PIXEL OF oPanel WHEN {|| nOpRad==1 }
   nLin+=nSoma

   @nLin+.6, nColS SAY STR0295 OF oPanel PIXEL//STR0295 "Invoice"
   @nLin,    nCol  COMBOBOX oInv    VAR cInvoice ITEMS aInvoice SIZE 105,18 PIXEL OF oPanel WHEN {|| nOpRad==2 }
   nLin+=nSoma

   @nLin+.6, nColS SAY "PLI"  OF oPanel PIXEL
   @nLin,    nCol  COMBOBOX oCboPLI VAR cPLI     ITEMS aPLIs    SIZE 105,18 PIXEL OF oPanel WHEN {|| nOpRad==3 }
   nLin+=nSoma

   @ nLin+.6,nColS SAY STR0317 OF oPanel PIXEL //STR0317 "Fornecedor"
   @ nLin,   nCol  COMBOBOX oCboFor VAR cForn    ITEMS aForn    SIZE 105,18 PIXEL OF oPanel WHEN EVAL({|| nOpRad==4 }) .AND. lLoteInclui

//   ACTIVATE MSDIALOG oDlg ON INIT DI500EnchoiceBar(oDlg,{{|| (nMarcaOK:=1,oDlg:End()) },"OK"},{|| (nMarcaOK:=0,oDlg:End()) },.F.) CENTERED
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (nMarcaOK:=1,oDlg:End()) },{|| (nMarcaOK:=0,oDlg:End()) },.F.) CENTERED

   IF nMarcaOK = 1
      cFornSel:=cForn
      IF lLoteInclui .AND. nOpRad # 4
         cFornSel:=""
      ENDIF
      IF nOpRad == 1
         bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cPO)}
      ELSEIF nOpRad == 2
         bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cInvoice)}
      ELSEIF nOpRad == 3
         bBlocSel := {|| RTRIM(Work_SW8->WKPGI_NUM) == RTRIM(cPLI)}
      ENDIF

      IF !DI500CrgTWV(M->WV_LOTE,LEFT(cFornSel,LEN(Work_SWV->WV_FORN)),bBlocSel,.F.,M->WV_DT_VALI,,.T.)  // GFP - 19/12/2013
         MSGSTOP(STR0341) // STR0341"Nao existe itens disponivel para essa seleção."
         LOOP
      ENDIF

   ENDIF

   EXIT

ENDDO

Work_TWV->(DBGOTOP())

RETURN .T.
*-------------------------------------------------------------------------------------*
FUNCTION DI500GrvLote(nSelOp,cChave)
*-------------------------------------------------------------------------------------*
LOCAL nCont:=xTotal:=0,lGrvItem:=.F.,C, cChaveCWV
LOCAL lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO")

ProcRegua( Work_SWV->(EasyReccount("Work_SWV")) )

IF nSelOp = 4 // Exclui Lote
   IF Work_CWV->(DBSEEK(cChave))
      IncProc()
      Work_CWV->(DBDELETE())
      DBSELECTAREA("Work_CWV")
      PACK
   ELSEIF Work_CWV->(DBSEEK(M->WV_LOTE))
      IncProc()
      Work_SWV->(DBSEEK(M->WV_LOTE))
      cChaveCWV := M->WV_LOTE + Work_SWV->WV_FORN + WORK_SWV->WV_FORLOJ + DTOS(M->WV_DT_VALI)
      DO WHILE Work_CWV->(!EOF())
      	  IF cChaveCWV == Work_CWV->(WV_LOTE+WV_FORN+WV_FORLOJ+DTOS(WV_DT_VALI))
			Work_CWV->(DBDELETE())
			DBSELECTAREA("Work_CWV")
      		PACK
         ENDIF
         WORK_CWV->(DBSKIP())
      ENDDO
   ENDIF
ENDIF

Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_SWV->(DBSETORDER(1))
IF !Work_SWV->(DBSEEK(cChave))
	Work_SWV->(DBSEEK( M->(WV_LOTE+WV_FORN+WV_FORLOJ) )) //LGS-03/02/2016
	cChave := M->WV_LOTE + Work_SWV->WV_FORN + WORK_SWV->WV_FORLOJ + DTOS(M->WV_DT_VALI)
ENDIF
lDeletou:=.F.
DO While !Work_SWV->(Eof())

   IF cChave == Work_SWV->WV_LOTE+Work_SWV->WV_FORN+If(EicLoja(),Work_SWV->WV_FORLOJ,"")+DTOS(Work_SWV->WV_DT_VALI)

	   IncProc()
	   IF EICLOJA()
	      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) )) .And. nSelOp = 4 //MCF - 29/09/2014
	         Work_SW8->WKDISPLOT+=Work_SWV->WV_QTDE
	      ENDIF
	   ELSE
	      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
	         Work_SW8->WKDISPLOT+=Work_SWV->WV_QTDE
	      ENDIF
	   ENDIF
	   /*IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
	      Work_SW8->WKDISPLOT+=Work_SWV->WV_QTDE
	   ENDIF*/
	   lDeletou:=.T.
	   Work_SWV->(DBDELETE())
	ENDIF
	Work_SWV->(dbSkip())

ENDDO

IF lDeletou
   DBSELECTAREA("Work_SWV")
   PACK
ENDIF

IF nSelOp = 4 // Exclui Lote
   Work_SWV->(DbGoTop())
   RETURN .T.
ENDIF

ProcRegua(xTotal:=Work_TWV->(EasyReccount("Work_TWV")))
xTotal:=LTRIM(STR(xTotal,7))

SX3->(DBSETORDER(2))
Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_TWV->(DBSETORDER(1))
Work_TWV->(dbGoTop())
DO While !Work_TWV->(Eof())

   nCont++
   IncProc()

   If Work_TWV->WV_QTDE <= 0 //Quantidade
      Work_TWV->(dbSkip())
      Loop
   EndIf

   If !Work_SWV->(DBSEEK(M->WV_LOTE+M->WV_FORN+IF(EICLOJA(),M->WV_FORLOJ,"")+DTOS(dDtValLote)))  // GFP - 19/03/2014
      Work_SWV->(DBAPPEND())
   /* AAF - 16/09/2014 - Não duplicar.
   Else
   	  Work_SWV->(DBAPPEND()) //MCF - 22/07/2014
   */

   //LGS-23/12/2014 - Preciso validar se o item já existe na SWV para não perder a referencia e ficar fora do lote.
   Else
      IF Work_SWV->(DBSEEK(M->WV_LOTE+M->WV_FORN+IF(EICLOJA(),M->WV_FORLOJ,"")+DTOS(dDtValLote)))
         IF Work_TWV->WV_PGI_NUM <> Work_SWV->WV_PGI_NUM
            Work_SWV->(DBAPPEND())
         ELSEIF Work_TWV->WV_POSICAO <> Work_SWV->WV_POSICAO
            Work_SWV->(DBAPPEND())
         ELSEIF Work_TWV->WV_PO_NUM <> Work_SWV->WV_PO_NUM //MCF - 08/07/2015
            Work_SWV->(DBAPPEND())
         ELSEIF Work_TWV->WV_INVOICE <> Work_SWV->WV_INVOICE //NCF - 09/12/2015
            Work_SWV->(DBAPPEND())
         ENDIF
      ENDIF
   EndIf

   AVREPLACE("Work_TWV","Work_SWV")
   DBSELECTAREA("Work_SWV")
   FOR C := 1 TO FCount()
      cCampo:=FIELDNAME(C)
      IF SX3->(DBSEEK(cCampo)) .AND. SX3->X3_PROPRI == "U"
         Work_SWV->(FIELDPUT(C, M->&(FIELDNAME(C)) ))
      ENDIF
   NEXT
   Work_SWV->WV_LOTE   :=M->WV_LOTE
   Work_SWV->WV_DT_VALI:=M->WV_DT_VALI
   Work_SWV->WV_OBS    :=M->WV_OBS
   If lCpoDtFbLt
      Work_SWV->WV_DFABRI := M->WV_DFABRI
   EndIf   
//WKINVOICE+WKFORN+W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM
   IF EICLOJA()
      IF Work_SW8->(DBSEEK( Work_TWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         //Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE //LGS-25/06/2014 - Se não tem valor disponivel retorna zero para não gerar valor negativo.
         IF (Work_SWV->WV_DT_VALI == Work_CWV->WV_DT_VALI .And. (Empty(Work_CWV->WV_DT_VALI))) .Or. Work_SWV->WV_LOTE # Work_CWV->WV_LOTE     //MCF 29/09/2014
         	//Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE))
            Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,If( nSelOp == 3,  Work_SW8->WKDISPLOT ,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE) ) ) // NCF - 07/04/2015 - Quando incluso um lote com metade do saldo de um item e ao clicar em 'proximo'e "incluir lote" o
         ENDIF                                                                                                              //                    sistema estava zerando a quantidade disponivel para lote do item o qual usou-se parte do saldo na Work_SW8
      ENDIF
   ELSE
      IF Work_SW8->(DBSEEK( Work_TWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         //Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE //LGS-25/06/2014 - Se não tem valor disponivel retorna zero para não gerar valor negativo.
         IF (Work_SWV->WV_DT_VALI == Work_CWV->WV_DT_VALI .And. (Empty(Work_CWV->WV_DT_VALI))) .Or. Work_SWV->WV_LOTE # Work_CWV->WV_LOTE     //MCF 29/09/2014
         	//Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE))
            Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,If( nSelOp == 3,  Work_SW8->WKDISPLOT ,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE) ) ) // NCF - 07/04/2015 - Quando incluso um lote com metade do saldo de um item e ao clicar em 'proximo'e "incluir lote" o
         ENDIF                                                                                                              //                    sistema estava zerando a quantidade disponivel para lote do item o qual usou-se parte do saldo na Work_SW8
      ENDIF
   ENDIF
   lLoteInclui:=.F.
   lGrvItem   :=.T.

   //ISS - 29/10 - Ponto de entrada usado para atualizar campos customizados na tabela SWV
   IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500GRVLOTE_ATU_WORKSWV"),)

   Work_TWV->(dbSkip())

ENDDO
SX3->(DBSETORDER(1))

IF lGrvItem
   IF !Work_CWV->(DBSEEK(cChave))
      Work_CWV->(DBAPPEND())
      Work_CWV->WV_LOTE:=M->WV_LOTE
      Work_CWV->WV_FORN:=cForn
   ENDIF
   AVREPLACE("M","Work_CWV")
   Work_CWV->WV_LOTE   :=M->WV_LOTE
   Work_CWV->WV_FORN   :=cForn
   If EicLoja()
      Work_CWV->WV_FORLOJ   :=cLoja //SVG
   EndIf
   Work_CWV->WV_DT_VALI:=M->WV_DT_VALI
   Work_CWV->WV_OBS    :=M->WV_OBS
   If lCpoDtFbLt
      Work_CWV->WV_DFABRI := M->WV_DFABRI
   EndIf 
ENDIF

Work_TWV->(dbGoTop())

RETURN .T.
*-----------------------------------------------------------------------------------------------------------------*
FUNCTION DI500CrgTWV(cLote,cFornecedor,bBlocSel,lZap,dDtVali,cForLoj,lFiltro)  // GFP - 19/12/2013
*-----------------------------------------------------------------------------------------------------------------*
LOCAL aOrd := SaveOrd({"Work_CWV"}), cChaveSW8 := "", lGrava := .T., aLotesCWV :={}, i,j //LGS-01/12/2014
DEFAULT lZap := .T., lFiltro := .F.
DEFAULT cForLoj := "" //FDR - 18/07/11

IF lZap
   DBSELECTAREA("Work_TWV")
   //ZAP
   AvZap("Work_TWV")
ENDIF

ProcRegua(Work_SW8->(EasyReccount("Work_SW8")))
Work_TWV->(DBSETORDER(2))
Work_SWV->(DBSETORDER(2))
Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_SW8->(dbGoTop())
lTemItens := .F.

//LGS-05/12/2014
Work_SWV->(dbGoTop())
DO WHILE Work_SWV->(!EOF())
	AADD(aLotesCWV,{ Work_SWV->WV_INVOICE,Work_SWV->WV_PO_NUM,Work_SWV->WV_CC,Work_SWV->WV_SI_NUM,Work_SWV->WV_COD_I,;
	                 Work_SWV->WV_POSICAO,Work_SWV->WV_LOTE,Work_SWV->WV_PGI_NUM,Work_SWV->WV_QTDE})
	Work_SWV->(DBSKIP())
ENDDO
aSaldo:={}
DO WHILE !Work_SW8->(Eof())
	AADD(aSaldo,{Work_SW8->WKCOD_I,Work_SW8->WKPGI_NUM,Work_SW8->WKPOSICAO,Work_SW8->WKQTDE,0,Work_SW8->WKINVOICE,Work_SW8->WKPO_NUM})       //LGS-26/02/2015
	Work_SW8->(DBSKIP())
ENDDO
FOR i:=1 TO LEN(aSaldo)
	FOR j:=1 TO LEN(aLotesCWV)
		IF aSaldo[i,1]+aSaldo[i,2]+aSaldo[i,3]+aSaldo[i,6]+aSaldo[i,7] == aLotesCWV[j,5]+aLotesCWV[j,8]+aLotesCWV[j,6]+aLotesCWV[j,1]+aLotesCWV[j,2] //LGS-26/02/2015
		   aSaldo[i,5]+=aLotesCWV[j,9]
		ENDIF
	NEXT
NEXT

Work_SW8->(dbGoTop())
DO While !Work_SW8->(Eof())

   IncProc()
   cChaveSW8 := WORK_SW8->(WKINVOICE +WKPO_NUM +WKCC +WKSI_NUM +WKCOD_I +WKPOSICAO)
   //LGS-05/12/2014
   FOR i := 1 TO LEN(aLotesCWV)
        cChaveSW8 := AvKey(aLotesCWV[i,1],"W8_INVOICE") + AvKey(aLotesCWV[i,2],"W8_PO_NUM") + AvKey(aLotesCWV[i,3],"W8_CC") + ;
                     AvKey(aLotesCWV[i,4],"W8_SI_NUM")  + AvKey(aLotesCWV[i,5],"W8_COD_I")  + AvKey(aLotesCWV[i,6],"W8_POSICAO")
   		//cChaveSW8 := aLotesCWV[i,1]+aLotesCWV[i,2]+aLotesCWV[i,3]+aLotesCWV[i,4]+aLotesCWV[i,5]+aLotesCWV[i,6]
   		IF cChaveSW8 == WORK_SW8->(WKINVOICE+WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKPOSICAO)
   			FOR j:=1 TO LEN(aSaldo)
   				IF aSaldo[j,1]+aSaldo[j,2]+aSaldo[j,3]+aSaldo[j,6]+aSaldo[j,7] == aLotesCWV[i,5]+aLotesCWV[i,8]+aLotesCWV[i,6]+aLotesCWV[i,1]+aLotesCWV[i,2] //MCF-10/07/2015
   					IF (aSaldo[j,4]-aSaldo[j,5]) = 0 //.AND. M->WV_LOTE != aLotesCWV[i][7]
   						Work_SW8->(dbskip())
   						LOOP
   					ENDIF
   				ENDIF
   			NEXT
   		ENDIF
   NEXT



   IF lGrava
	   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
	      Work_SW8->(DBSKIP())
	      LOOP
	   ENDIF

	   IF EMPTY(Work_SW8->WKDISPLOT)
	      Work_SW8->(DBSKIP())
	      LOOP
	   ENDIF

	   IF !EVAL(bBlocSel)
	      Work_SW8->(DBSKIP())
	      LOOP
	   ENDIF

	   IF !EMPTY(cFornecedor) .AND. Work_SW8->WKFORN # cFornecedor
	      Work_SW8->(DBSKIP())
	      LOOP
	   ENDIF

	   IF EICLoja()
	      IF !EMPTY(cForLoj) .AND. Work_SW8->W8_FORLOJ # cForLoj
	         Work_SW8->(DBSKIP())
	         LOOP
	      ENDIF
	   EndIf

	   IF !lZap// Para dar ZAP so se existir itens p/ trazer no filtro ( DI500TelaSel() )
	      DBSELECTAREA("Work_TWV")
	      AvZap("Work_TWV")
	      //ZAP
	      lZap:=.T.
	   ENDIF

	   Work_TWV->(DBAPPEND())
	   DI500SW8TWVGrv(lFiltro)  // GFP - 19/12/2013
	   If !lFiltro              // GFP - 19/12/2013
	      //Work_TWV->WKDISPLOT:= Work_SW8->WKDISPLOT
	      FOR i:=1 TO LEN(aSaldo) //LGS-08/12/2014
	      	   IF aSaldo[i,1]+aSaldo[i,2]+aSaldo[i,3]+aSaldo[i,6]+aSaldo[i,7] == Work_TWV->(WV_COD_I+WV_PGI_NUM+WV_POSICAO+WV_INVOICE+WV_PO_NUM) //LGS-26/02/2015 //MCF-06/07/2015
	      	      Work_TWV->WKDISPLOT := (aSaldo[i,4]-aSaldo[i,5])
	      	   ENDIF
	      NEXT
	      Work_TWV->WV_QTDE  := 0
	      Work_TWV->WKFLAGLOT:= ""
	   EndIf
	   lTemItens := .T.
   ENDIF
   lGrava := .T.
   Work_SW8->(dbSkip())
ENDDO

RestOrd(aOrd,.T.)
Work_TWV->(DBGOTOP())
//IF (nPos:=ASCAN(aForn, { |F| F[1] = Work_TWV->WV_FORN .And. (!EicLoja() .Or. F[2] == .T.) })) # 0
IF (nPos:=ASCAN(aForn, { |F| F = Work_CWV->WV_FORN })) # 0
   cForn:=aForn[nPos]
ENDIF

IF !EMPTY(cLote+cFornecedor+DtoS(dDtVali))

   ProcRegua(Work_SWV->(EasyReccount("Work_SWV")))
   Work_TWV->(DBSETORDER(2))//WV_INVOICE+WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO
   Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
   Work_SWV->(DBSETORDER(1))
   If EICLOJA()
      Work_SWV->(DBSEEK(cLote+cFornecedor+cForLoj+DtoS(dDtVali)))
   Else
      Work_SWV->(DBSEEK(cLote+cFornecedor+DtoS(dDtVali)))
   EndIf

   DO While !Work_SWV->(Eof()) .AND. cLote+cFornecedor+DtoS(dDtVali) == Work_SWV->WV_LOTE+Work_SWV->WV_FORN+DtoS(Work_SWV->WV_DT_VALI)

      IncProc()
      IF EICLOJA()
         IF !Work_TWV->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO) ))
            Work_TWV->(DBAPPEND())
            AVREPLACE("Work_SWV","Work_TWV")
         ENDIF
      ELSE
         IF !Work_TWV->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO) ))
            Work_TWV->(DBAPPEND())
            AVREPLACE("Work_SWV","Work_TWV")
         ENDIF
      ENDIF
      Work_TWV->WV_QTDE  := Work_SWV->WV_QTDE
      Work_TWV->WKFLAGLOT:= cMarca
      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         Work_TWV->WKDISPLOT:=(Work_SW8->WKDISPLOT+Work_SWV->WV_QTDE)
      ELSE
      	  IF Work_TWV->WKDISPLOT > 0 //LGS-08/12/2014
      	     Work_TWV->WKDISPLOT+=Work_TWV->WV_QTDE
      	  ELSE
      	     Work_TWV->WKDISPLOT:=Work_TWV->WV_QTDE  //LGS-25/02/2015
      	  ENDIF
      ENDIF

      Work_SWV->(dbSkip())

   ENDDO

ENDIF

Work_TWV->(DBGOTOP()) //LGS-27/02/2015
DO WHILE Work_TWV->(!EOF())
   IF Work_TWV->(WV_QTDE+WKDISPLOT) == 0
      Work_TWV->(DBDELETE())
   ENDIF
   Work_TWV->(DBSKIP())
ENDDO

Work_TWV->(DBGOTOP())
Work_TWV->(DBSETORDER(1))
Work_SWV->(DBSETORDER(1))

Return lTemItens


*------------------------------------------------------------------------------*
FUNCTION DI500SW8TWVGrv(lFiltro)  // GFP - 19/12/2013
*------------------------------------------------------------------------------*
LOCAL cFieldSW8,cFieldTWV,bFieldTWV,bFieldSW8,I
DEFAULT lFiltro := .F.

For I:=1 To Work_SW8->(FCOUNT())

    cFieldSW8:=Work_SW8->(FieldName(i))
    cFieldTWV:='WV_'+SUBSTR(cFieldSW8,3)
    IF EICLOJA() .And. "LOJ" $ cFieldSW8
       If "FO" $ cFieldSW8
          cFieldTWV:="WV_FORLOJ"
       EndIf
       If "FA" $ cFieldSW8
          cFieldTWV:="WV_FABLOJ"
       EndIF
    ENDIF
    IF Work_TWV->(FieldPos(cFieldTWV)) == 0
       LOOP
    Else
       //bFieldWk = {|Valor|IF(Valor==NIL,Work_TWV->WV_???????,Work_TWV->WV_???????:=Valor)}
       bFieldTWV:=FieldWBlock(cFieldTWV,Select("Work_TWV"))
    Endif

    //bFieldSW8 = {|Valor|IF(Valor==NIL,Work_SW8->W8_???????,Work_SW8->W8_???????:=Valor)}
    bFieldSW8:=FieldWBlock(cFieldSW8,Select("Work_SW8"))

    Eval(bFieldTWV,Eval(bFieldSW8))

Next

If lFiltro  // GFP - 19/12/2013
   Work_TWV->(DbGoTop())
   Do While Work_TWV->(!Eof())
      DI500MarLote(Work_TWV->WV_QTDE)
      Work_TWV->WKDISPLOT := Work_TWV->WV_QTDE
      Work_TWV->(DbSkip())
   EndDo
EndIf

//ISS - 29/10 - Ponto de entrada para a gravação de campos customizados da WORK_SW8 para a WORK_TWV
IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"DI500SW8TWVGRV_GRV_WORKTWV"),)

RETURN .T.

*------------------------------------------------------------------------------*
FUNCTION DI500SWVGrv(lLer)
*------------------------------------------------------------------------------*
LOCAL cFilSWV:=xFilial("SWV"),nCont:=0
LOCAL lLoopSWV := .T.
LOCAL lDelSWV  := .F. //LGS-26/02/2015
LOCAL nSelOp  //LRS - 28/04/2015
LOCAL lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO")

IF !lTemLote
   RETURN .F.
ENDIF

ProcRegua(10)

IF lLer
   DBSELECTAREA("Work_CWV")
   //ZAP
   AvZap("Work_CWV")
   DBSELECTAREA("Work_SWV")
   //ZAP
   AvZap("Work_SWV")
   aLotes:={}
   SW8->(DBSETORDER(1))
   SWV->(DBSETORDER(1))
   SWV->(DBSEEK(cFilSWV+SW6->W6_HAWB))
   DO While !SWV->(Eof()) .AND. SW6->W6_HAWB == SWV->WV_HAWB .AND. cFilSWV == SWV->WV_FILIAL

      IF nCont > 10
         ProcRegua(10)
         nCont:=0
      ELSE
         nCont++
         IncProc()
      ENDIF

      IF EMPTY(SWV->WV_FORN) .OR. EMPTY(SWV->WV_INVOICE)
         SWV->(dbSkip())
         LOOP
      ENDIF

      Work_SWV->(DBAPPEND())
      AVREPLACE("SWV","Work_SWV")

      IF !Work_CWV->(DBSEEK(SWV->WV_LOTE+SWV->WV_FORN+DTOS(SWV->WV_DT_VALI)))
         Work_CWV->(DBAPPEND())
         AVREPLACE("SWV","Work_CWV")
         Work_CWV->WV_LOTE   :=SWV->WV_LOTE
         Work_CWV->WV_FORN   :=SWV->WV_FORN
         Work_CWV->WV_DT_VALI:=SWV->WV_DT_VALI
         Work_CWV->WV_OBS    :=SWV->WV_OBS
         If lCpoDtFbLt
            Work_CWV->WV_DFABRI := SWV->WV_DFABRI
         EndIf 
      ENDIF
      IF EICLOJA()
         IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
            //Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE //LGS-25/06/2014 - Se não tem valor disponivel retorna zero para não gerar valor negativo.
            //Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE))
            If (Work_SW8->WKDISPLOT==0,0,If( nSelOp == 3,  Work_SW8->WKDISPLOT ,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE) ) ) // NCF - 07/04/2015 - Quando incluso um lote com metade do saldo de um item e ao clicar em 'proximo'e "incluir lote" o
         ENDIF                                                                                                              //                    sistema estava zerando a quantidade disponivel para lote do item o qual usou-se parte do saldo na Work_SW8
      ELSE
         IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
            //Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE //LGS-25/06/2014 - Se não tem valor disponivel retorna zero para não gerar valor negativo.
            //Work_SW8->WKDISPLOT := If (Work_SW8->WKDISPLOT==0,0,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE))
            If (Work_SW8->WKDISPLOT==0,0,If( nSelOp == 3,  Work_SW8->WKDISPLOT ,(Work_SW8->WKDISPLOT-Work_SWV->WV_QTDE) ) ) // NCF - 07/04/2015 - Quando incluso um lote com metade do saldo de um item e ao clicar em 'proximo'e "incluir lote" o
         ENDIF                                                                                                              //                    sistema estava zerando a quantidade disponivel para lote do item o qual usou-se parte do saldo na Work_SW8
      ENDIF
      SWV->(dbSkip())

   ENDDO

ELSE
   //LGS-01/12/2014 - Nopado para que ao excluir a invoice o sistema delete os dados da SWV
   /*IF !lGravaSWV
      RETURN .F.
   ENDIF*/
   SWV->(DBSETORDER(1))
   SWV->(DBSEEK(cFilSWV+M->W6_HAWB))
   DO While !SWV->(Eof()) .AND. M->W6_HAWB == SWV->WV_HAWB .AND. cFilSWV == SWV->WV_FILIAL

      IF EMPTY(SWV->WV_FORN) .OR. EMPTY(SWV->WV_INVOICE)
         SWV->(dbSkip())
         LOOP
      ENDIF

      IF nCont > 10
         ProcRegua(10)
         nCont:=0
      ELSE
         nCont++
         IncProc()
      ENDIF

      If Work_TWV->(EasyRecCount("Work_TWV")) <> 0 .Or. Work_SWV->(EasyRecCount("Work_SWV")) <> 0
         lDelSWV := .T.
      EndIf

      If lDelSWV
         SWV->(RECLOCK("SWV",.F.))
         SWV->(DBDELETE())
         SWV->(MSUNLOCK())
      EndIf
      SWV->(dbSkip())

   ENDDO

   ProcRegua(Work_SWV->(EasyReccount("Work_SWV")))
   Work_SW8->(DBSETORDER(1))
   Work_SWV->(DBSETORDER(1))
   Work_SWV->(dbGoTop())
   DO While !Work_SWV->(Eof())
      lLoopSWV := .T.
      IncProc()
      If EicLoja()
         IF !Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) )) .OR. EMPTY(Work_SW8->WKFLAGIV)
			//LGS-05/12/2014
         	Work_SW8->(DbGoTop())
         	IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN) ))
         	   Do While Work_SW8->(!Eof())
         	   	  IF Work_SW8->(W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM) == Work_SWV->(WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM)
         	   	  	 lLoopSWV := .F.
         	   	  ENDIF
         	   	  Work_SW8->(DbSkip())
         	   EndDo
         	ENDIF

         	IF lLoopSWV
          	   Work_SWV->(dbSkip())
          	   LOOP
          	ENDIF

         ENDIF
      Else
         IF !Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) )) .OR. EMPTY(Work_SW8->WKFLAGIV)
         	//LGS-05/12/2014
         	Work_SW8->(DbGoTop())
         	IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN) ))
         	   Do While Work_SW8->(!Eof())
         	   	  IF Work_SW8->(W8_FORLOJ+WKPO_NUM+WKPOSICAO+WKPGI_NUM) == Work_SWV->(WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM)
         	   	  	 lLoopSWV := .F.
         	   	  ENDIF
         	   	  Work_SW8->(DbSkip())
         	   EndDo
         	ENDIF

         	IF lLoopSWV
          	   Work_SWV->(dbSkip())
          	   LOOP
          	ENDIF
         ENDIF
      ENDIF

      SWV->(RECLOCK("SWV",.T.))
      AVREPLACE("Work_SWV","SWV")
      SWV->WV_FILIAL:= cFilSWV
      SWV->WV_HAWB  := M->W6_HAWB
      SWV->WV_REG   := 1 //LGS-01/12/2014
      SWV->(MSUNLOCK())
      Work_SWV->(dbSkip())

   ENDDO

ENDIF

RETURN  .T.

*------------------------------------------------------------------------------*
FUNCTION DI500SWVEstorno(cChave)
*------------------------------------------------------------------------------*
LOCAL cFilSWV:=xFilial("SWV")
Local lDUIMPcLte := AVFLAGS("DUIMP") .And. M->W6_TIPOREG == '2'
Local aChaveEKQ, aChaveIDWV
IF !lTemLote .And. !lDUIMPcLte
   RETURN .F.
ENDIF

SWV->(DBSETORDER(2))
SWV->(DBSEEK(cFilSWV+SW6->W6_HAWB+cChave))
DO While !SWV->(Eof()) .AND. SW6->W6_HAWB == SWV->WV_HAWB   .AND.;
                                  cFilSWV == SWV->WV_FILIAL .AND.;
                                  cChave  == SWV->(WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO)
   
   aChaveEKQ  := { xFilial("EKQ") , SWV->WV_HAWB , SWV->WV_INVOICE , SWV->WV_PO_NUM , SWV->WV_POSICAO  } 

   SWV->(RECLOCK("SWV",.F.))
   SWV->(DBDELETE())
   SWV->(MSUNLOCK())
   
   If lDUIMPcLte
      aChaveIDWV := {SWV->WV_HAWB , SWV->WV_ID}
      DI501EKQDL(aChaveEKQ )
      DI501IDWVD(aChaveIDWV)
   ENDIF

   SWV->(dbSkip())

ENDDO

SWV->(DBSETORDER(1))
RETURN  .T.
// AWR - Lote - 07/06/2004 /\/\/\


*------------------------------------------------------------------------------*
FUNCTION DI500UNID(cCod_I,cFabr,cForn,cCC,cSi_num, cFabLoj, cForLoj)
*------------------------------------------------------------------------------*
LOCAL cUNID:=LEN(SYD->YD_UM),nVAL_PAG:=0

cUNID:=Busca_UM(cCod_I+cFabr+cForn, cFabLoj, cForLoj)

SYD->(DBSETORDER(1))
SYD->(DBSEEK(xFILIAL("SYD")+Work_SW8->WKTEC+Work_SW8->WKEX_NCM+Work_SW8->WKEX_NBM))

IF !EMPTY(SYD->YD_UM)
   IF cUNID # SYD->YD_UM
      SJ5->(DBSETORDER(1))
      IF SJ5->(DBSEEK(xFILIAL("SJ5")+AVKEY(cUNID,"J5_DE")+AVKEY(SYD->YD_UM,"J5_PARA")))
         nVAL_PAG:=SJ5->J5_COEF*WORK_SW8->WKQTDE
      ENDIF
   ENDIF
ENDIF

RETURN nVAL_PAG

*-----------------------------------------------------------------------------------------------------*
Function MensDrawback(lAto,cPItem,cPForn,cPInvoice,cPPo,cPPosicao,cPPgi,cPAc,cPTec)   //GFC 18/08/04
*-----------------------------------------------------------------------------------------------------*
Local cMens:=""
Local cCGC := BuscaCNPJ(M->W6_IMPORT)   //Função BuscaCNPJ() está no EDCAC400.PRW
Local cItem := cPItem, cCamb := ""
Local cItemPrinc := ""
lAto:=If(lAto<>NIL,lAto,.T.)

//**  PLB 14/11/06 - Verifica se existe item alternativo
cItemPrinc := IG400BuscaItem("I",cPItem)
//**

SW9->(DBSETORDER(1))
If lAto
   If Work_SW8->(dbSeek(cPForn+cPInvoice+cPPo+cPPosicao+cPPgi))
      SY6->(dbSeek(xFilial("SY6")+Work_SW8->WKCOND_PA+str(Work_SW8->WKDIAS_PA,3,0)))
      cCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")
   EndIf
Else
   //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
   If SW8->(dbSeek(cFilSW8+M->W6_HAWB+cPInvoice+cPPo+cPPosicao+cPPgi)) .and. SW9->(dbSeek(cFilSW9+Sw8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+M->W6_HAWB))
      SY6->(dbSeek(xFilial("SY6")+SW9->W9_COND_PA+str(SW9->W9_DIAS_PA,3,0)))
      cCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")
   EndIf
EndIf

If Empty(cCamb)
   If SW2->(dbSeek(xFilial("SW2")+cPPo))
      SY6->(dbSeek(xFilial("SY6")+SW2->W2_COND_PA+str(SW2->W2_DIAS_PA,3,0)))
      cCamb := If(SY6->Y6_TIPOCOB<>"4","1","2")
   Else
      cCamb := "1"
   EndIf
Endif

ED0->(dbSetOrder(2))

If !Empty(cPAc)
   If lAto
      cMens := STR0342+Alltrim(cPAc)+"."  //STR0342 "Item utilizado para Ato Concessório "
   EndIf
Else

   ED4->(dbSetOrder(3))
   ED4->(dbSeek(cFilED4+cCGC+cItem+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
   //** PLB 14/11/06 - Caso não encontre com o item alternativo, procura com o item principal
   If !( ED4->ED4_FILIAL==cFilED4 .And. ED4->ED4_CNPJIM==cCGC .and. ED4->ED4_ITEM==cItem .and. ED4->ED4_CAMB==cCamb )
      ED4->( DBSeek(cFilED4+cCGC+cItemPrinc+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
   EndIf
   //**
   If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
      ED0->(dbSeek(cFilED0+ED4->ED4_AC))
   EndIf
   If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. (ED4->ED4_ITEM==cItem .Or. ED4->ED4_ITEM==cItemPrinc) .and. ED4->ED4_CAMB==cCamb
      If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
      (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and. ED4->ED4_VL_LI > 0)) .and.;
      Empty(ED0->ED0_DT_ENC)
         cMens := STR0343 // STR0343 "Item poderia ser utilizado para drawback."
      EndIf
   Else
      ED4->(dbSetOrder(4))
      ED4->(dbSeek(cFilED4+cCGC+cPTec+Space(Len(ED4->ED4_ITEM))+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
      If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
         ED0->(dbSeek(cFilED0+ED4->ED4_AC))
      EndIf
      If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. cPTec==ED4->ED4_NCM .and. Empty(ED4->ED4_ITEM) .and. ED4->ED4_CAMB==cCamb
         If !Empty(ED4->ED4_AC) .and. (ED4->ED4_QT_LI > 0 .or.;
         (ED0->ED0_TIPOAC==GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and. ED4->ED4_VL_LI > 0)) .and.;
         Empty(ED0->ED0_DT_ENC)
            cMens := STR0344 //STR0344 "Item poderia ser utilizado para drawback."
         EndIf
      Else
         ED4->(dbSeek(cFilED4+cCGC+AvKey("99999999","ED4_NCM")+Space(Len(ED4->ED4_ITEM))+cCamb+DtoS(dDataBase),.T.))  //SoftSeek
         If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+ED4->ED4_AC))
         EndIf
         If ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_CNPJIM==cCGC .and. Alltrim(ED4->ED4_NCM)=="99999999" .and. Empty(ED4->ED4_ITEM) .and. ED4->ED4_CAMB==cCamb
            If !Empty(ED4->ED4_AC) .and. ED4->ED4_VL_LI > 0 .and. Empty(ED0->ED0_DT_ENC)
               cMens :=STR0344 //STR0344 "Item poderia ser utilizado para drawback."
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

ED0->(dbSetOrder(1))

Return cMens

//Função..: AtoComplemDi()
//Autor...: AAF - Alessandro Alves Ferreira
//Data....: 27/04/05
//Objetivo: Atualiza a Descrição Complementar da DI com Descrição do Drawback.
******************************
Function AtoComplemDi()
******************************
Local nInd, nInd2

aOrd:= SaveOrd( {"ED0","ED5","Work_SW8"} )
aAtos     := {}
aAditivos := {}
cTexto := ""

cMVDrawC01 := EasyGParam("MV_DRAWC01",,"")
cMVDrawC02 := EasyGParam("MV_DRAWC02",,"")
cMVDrawC03 := EasyGParam("MV_DRAWC03",,"")
cMVDrawC04 := EasyGParam("MV_DRAWC04",,"")
cMVDrawC05 := EasyGParam("MV_DRAWC05",,"")
cMVDrawC06 := EasyGParam("MV_DRAWC06",,"")
cMVDrawC07 := EasyGParam("MV_DRAWC07",,"")
cMVDrawC08 := EasyGParam("MV_DRAWC08",,"")
cMVDrawC09 := EasyGParam("MV_DRAWC09",,"")

If ( !Empty(cMVDrawC01) .OR. !Empty(cMVDrawC02) .OR. !Empty(cMVDrawC03) .OR. !Empty(cMVDrawC04) ) .OR.;
   ( !Empty(cMVDrawC05) .OR. !Empty(cMVDrawC06) .OR. !Empty(cMVDrawC07) .OR. !Empty(cMVDrawC08) ) .AND.;
   !Empty(cMVDrawC09)

   //Verifica se a DI possui itens com Ato Concessório.
   ED0->( dbSetOrder(2) )
   Work_SW8->( dbSeek( StrZero( 1, Len(WKADICAO), 0) ) )//Busca por item com a 1a Adicao.
   Do While !Work_SW8->( EoF() )
      If !Empty(Work_SW8->WKAC)
         ED0->( dbSeek( xFilial("ED0")+Work_SW8->WKAC ) )

         If ( nPosAto:= aScan(aAtos,{|X| X[2] == Work_SW8->WKAC}) ) == 0
            If ED0->ED0_MODAL == "2" //Isenção

               cFilED5 := xFilial("ED5")

               //Procura Aditivos
               ED5->( dbSeek( cFilED5 + Work_SW8->WKAC ) )
               Do While !ED5->( EoF() ) .AND. ED5->( ED5_FILIAL+ED5_AC ) == cFilED5 + Work_SW8->WKAC
                  If !Empty(ED5->ED5_NRADI) .AND. !Empty(ED5->ED5_DT_REG)
                     aAdd(aAditivos, {ED5->ED5_NRADI, ED5->ED5_DT_REG} )
                  Endif

                  ED5->( dbSkip() )
               EndDo
            Endif

            aAdd(aAtos, { ED0->ED0_MODAL, Work_SW8->WKAC, ED0->ED0_DT_REG, {Work_SW8->WKADICAO}, aAditivos } )
            aAditivos := {}
         Else
            If aScan(aAtos[nPosAto][4],Work_SW8->WKADICAO) == 0
               aAdd(aAtos[nPosAto][4],Work_SW8->WKADICAO)
               aAtos[nPosAto][4] := aSort(aAtos[nPosAto][4])
            Endif
         EndIf
      Endif

      Work_SW8->( dbSkip() )
   EndDo

   aAtos := aSort(aAtos,,,{ |X,Y| X[4][1] < Y[4][1] })

   //Monta o Texto
   cModal := ""
   cEnter := Chr(13) + Chr(10)
   For nInd:= 1 To Len(aAtos)

      If cModal <> aAtos[nInd][1]
         cModal := aAtos[nInd][1]

         cTexto+= cEnter
         cTexto+= cEnter
         cTexto+= "DRAWBACK - " + If( aAtos[nInd][1] == "1","SUSPENSAO","ISENCAO" )
         cTexto+= cEnter
         cTexto+= Replicate("-", If(aAtos[nInd][1] == "1", 20,18))
         cTexto+= cEnter
         cTexto+= cEnter

         If aAtos[nInd][1] == "2" //Isenção
            cTexto+= RTrim(cMVDrawC01)+" "+RTrim(cMVDrawC02)+" "+RTrim(cMVDrawC03)+" "+RTrim(cMVDrawC04)
         Else
            cTexto+= RTrim(cMVDrawC05)+" "+RTrim(cMVDrawC06)+" "+RTrim(cMVDrawC07)+" "+RTrim(cMVDrawC08)
         Endif

         cTexto+= " "+cMVDrawC09+cEnter
      Endif

      cTexto+= "---"+cEnter
      cTexto+= If( Len(aAtos[nInd][4]) > 1,STR0080,STR0082) //STR0080 "Adições: " STR0082 "Adição: "

      For nInd2:= 1 To Len(aAtos[nInd][4])
         cTexto+= aAtos[nInd][4][nInd2]
         cTexto+= If(nInd2 < Len(aAtos[nInd][4]),", ",".")
      Next

      cTexto+= cEnter
      cTexto+= STR0345+AllTrim(aAtos[nInd][2])+STR0346+DToC(aAtos[nInd][3])+cEnter //STR0345 "Ato concessório" //STR0346 " DE "

      If Len(aAtos[nInd][5]) > 0 //Aditivos
         cTexto+= If( Len(aAtos[nInd][5]) > 1, STR0347, STR0348) //STR0347 "Aditivos: " //STR0348 "Aditivo: "

         For nInd2 := 1 To Len(aAtos[nInd][5])
            If Int(nInd2 / 3) == nInd2 / 3
               cTexto+= cEnter
            Endif

            cTexto+= AllTrim(aAtos[nInd][5][nInd2][1]) + STR0346 + DToC(aAtos[nInd][5][nInd2][2]) //STR0346 " DE "
            cTexto+= If(nInd2 < Len(aAtos[nInd][5]),", ",".")
         Next

      Endif

   Next

Endif

//Grava no Memo
If Len(cTexto) > 0// .AND. MsgYesNo("Deseja gerar os dados de Drawback na descrição complementar?")
   nPos:= aScan(oEnCh1:aGets,{|X| "W6_VM_COMP" $ X})

   //If !Empty(W6_VM_COMP) .AND. MsgYesNo("Já existe uma descrição complementar preenchida. Deseja apaga-la?")
   //   Eval(oEnch:aEntryCtrls[nPos]:bSetGet,Space(0)+cEnter+cTexto)
   //Else

   Eval(oEnch1:aEntryCtrls[nPos]:bSetGet,M->W6_VM_COMP + cTexto)

   //Endif

   oEnch1:aEntryCtrls[nPos]:Refresh()
   oEnch1:oBox:Refresh()
   oEnch1:Refresh()
Endif

RestOrd(aOrd)

Return .T.

/*
Função      : DI500IPIPauta()
Objetivo    : Complementar o tratamento de IPI de Pauta nas adições
Parametro   : -
Retorno     : NIL
Autor       : JWJ - Johann Wilfried Josefy
Data        : 04/12/2006.
*/
*----------------------------------------------------------------------------------------------------*
Function DI500IPIPauta()
*----------------------------------------------------------------------------------------------------*
Local i, lOK
Local oDlgIPI, oGetIPI
Local aAltera := {}
Local aRestOrd := {WORK->(IndexOrd()),WORK->(RECNO())}
Local iPO, iPOS, iPGI, iQTD, iQTDVOL //Variaveis para guardar o indice de aHeader
Private aHeader := {}
Private aCols   := {}

aHeader := {{"Invoice", "WKINVOICE", "@!", LEN(SW9->W9_INVOICE),0,nil,nil,"C",nil,nil},;
            {"Item"   , "WKCOD_I"  , "@!", LEN(SW5->W5_COD_I),0,nil,nil,"C",nil,nil},;
            {"Qtde"   , "WKQTDE"   , "@E 999,999,999.999", AVSX3("W8_QTDE",3),AVSX3("W8_QTDE",4),nil,nil,"N",nil,nil},;
            {"Qtd/VOL", "WKQTDVOL"   , "@E 999,999,999.999", AVSX3("W8_QTDE",3),AVSX3("W8_QTDE",4),nil,nil,"N",nil,nil},;
            {"Preco"  , "WKPRECO"  , "@E 999,999,999.99999", AVSX3("W8_PRECO",3),AVSX3("W8_PRECO",4),nil,nil,"N",nil,nil},;
            {"Forn"   , "WKFORN"   , "@!", Len(SW2->W2_FORN),0,nil,nil,"C",nil,nil},;
            {"P.O."   , "WKPO_NUM" , "@!", Len(SW2->W2_PO_NUM),0,nil,nil,"C",nil,nil},;
            {"Pos"    , "WKPOSICAO", "@!", Len(SW3->W3_POSICAO),0,nil,nil,"C",nil,nil},;
            {"P.L.I." , "WKPGI_NUM", "@!", Len(Work_SW8->WKCOD_I),0,nil,nil,"C",nil,nil}   }
iPO  := 7
iPOS := 8
iPGI := 9
iQTD := 3
iQTDVOL := 4

aHeader := AddCpoUser(aHeader,"SW8","4")

aAltera := {"WKQTDVOL"}
//SVG - 30/07/2009 -
If EIJ->(FieldPos("EIJ_CALIPI")) = 0 .Or. (EIJ->(FieldPos("EIJ_CALIPI")) > 0 .And. M->EIJ_CALIPI != "2")
   IF M->EIJ_TPAIPI == "2" //Aliq Especifica
      Work_SW8->(DBSETFILTER({|| Work_SW8->WKADICAO == M->EIJ_ADICAO }, "Work_SW8->WKADICAO == M->EIJ_ADICAO" ))
      Work_SW8->(DBGOTOP())
      While ! Work_SW8->(EOF())
         AADD(aCols, Array(LEN(aHeader)+1) ) //+1 por causa da coluna DELET
         For i := 1 To Len(aHeader)
            IF Left(aHeader[i,2],2) == "WK" //Campo da Work_SW8
               aCols[LEN(aCols), i] := &("Work_SW8->"+aHeader[i,2])
//          ELSE
//               aCols[LEN(aCols), i] := 0 //Qtd por unidade
            ENDIF
            IF aHeader[i,2] == "WKQTDVOL"
               IF Empty(aCols[LEN(aCols), i])
                  SB1->(DBSETORDER(1))
                  SB1->(DBSEEK(xFILIAL("SB1")+Work_SW8->WKCOD_I))
                  EI6->(DBSETORDER(1))
                  EI6->(DBSEEK(xFILIAL("EI6")+SB1->B1_TAB_IPI))
                  aCols[LEN(aCols), i]:=EI6->EI6_QTD_EM
               ENDIF
            ENDIF
         Next

         aCols[LEN(aCols), LEN(aHeader)+1] := .F. //Coluna DELET

         Work_SW8->(DBSKIP())
      Enddo

      While .T.
         DEFINE MSDIALOG oDlgIPI TITLE STR0347 ;  //STR0347 "IPI de Pauta"
                FROM oMainWnd:nTop+125,oMainWnd:nLeft +5 ;
                TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

            oGetIPI := MsGetDados():New(15,1,(oDlgIPI:nHeight-30)/2,(oDlgIPI:nClientWidth-4)/2,4,,,,.f.,aAltera,nil,.t.,1500,/*"U_FieldOk"*/nil,nil,nil)
            oGETIPI:oBROWSE:BADD := {||.F.}
            lOK := .F.

         ACTIVATE MSDIALOG oDlgIPI ON INIT EnchoiceBar(oDlgIPI,{||lOK:=.T.,oDlgIPI:End()},{||oDlgIPI:End()},,) CENTERED

         IF lOK
            Work_SW8->(DBSETORDER(1))
            //Valida
            M->EIJ_QTUIPI:=0
            For i := 1 to Len(aCols)
               IF aCols[i,4] == 0
                  lOK := .F.
               Else
                  //Gravar na WORK_SW8 as qtdes por volume digitadas pelo usuario
                  WORK_SW8->(DBSEEK(aCols[i,1]+aCols[i,6]+aCols[i,7]+aCols[i,8]+aCols[i,9])) //WORK_SW8->WKINVOICE+WORK_SW8->WKFORN+WORK_SW8->WKPO_NUM+WORK_SW8->WKPOSICAO+WORK_SW8->WKPGI_NUM
                  WORK_SW8->WKQTDVOL := aCols[i,4]
                  M->EIJ_QTUIPI += aCols[i,4] * aCols[i,3]
               Endif

            Next
            IF !lOK
               MsgStop(STR0348) //STR0348 "Favor informar a Quantidade de Unidades por Volume de todos os itens"
               LOOP
            Endif
         ENDIF

         Exit
      Enddo

   ENDIF
EndIf
Work_SW8->(DBCLEARFILTER())

Return

/*------------------------------------------------------------------------------------
Funcao      : GetStrCombo
Parametros  : cCampo - campo do SX3 que deseja obter as informações do comboBox
              cItem - nº do item que deseja obter a informação do comboBox
Retorno     : Descrição do item informado
Objetivos   : Obter a informação de um item de um comboBox
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function GetStrCombo(cCampo,cItem)
   local cAux := ""

   cCampo := alltrim(cCampo)
   cItem  := alltrim(cItem)

   SX3->(dbSeek(cCampo))
   cAux := SX3->X3_CBOX

   //Verifica se o item existe no comboBox
   If at(cItem,cAux) > 0
      //obtem apenas a subString do item desejado
      cAux := subStr(cAux,at(cItem,cAux)+2)
      If at(";",cAux) - 1 > 0
         cAux := subStr(cAux,0,at(";",cAux)-1)
      Else
         cAux := subStr(cAux,0)
      EndIf
   Else
      cAux := ""
  EndIf

return cAux

/*
Funcao      : ApDetMerc
Parametros  : Nenhum
Retorno     : aRet[]
                  [1] - ADICAO
                  [2] - Somatória do Fob unitário do itens da Adicão
                  [3] - Array contendo cada Item da Adicao com os valores Unitários e Fob Total do Item na adição
Objetivos   : Retornar a Somatória do valor unitário de cada item da adição na condição de venda
Autor       : Nilson César
Data/Hora   : 23/03/2012 - 10:00 hs
Revisao     : 10/05/2012 - Adicionada verificação de Alias
Obs.        :
*/

*--------------------------------------------------*
               Function ApDetMerc(cAlias)
*--------------------------------------------------*

Local aOrdSW9 := {}
Local nVLMCV := nVLMCVUnit := nQtdMerc := nFobUniTot := nVLMCV_Aux :=0
Local aItensAdi := {}
Local aRet := {}

If cAlias == "TAB"

   aOrdSW9 := SaveOrd({"SW8","SW9","SW2"})
   SW8->(dbSetOrder(4))
   SW8->(dbSeek( cFilSW8 + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
   SW9->(DbSetOrder(1))                                                               	//NCF - 23/03/2012 - Posicionar Capa da Invoice para verificação de despesas
   SW9->( DbSeek( xFilial("SW9")+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+EIJ->EIJ_HAWB ) )

   Do While !SW8->(Eof()) .And.;
      SW8->W8_FILIAL == cFilSW8	.And.;
      SW8->W8_HAWB   == EIJ->EIJ_HAWB .And.;
      SW8->W8_ADICAO == EIJ->EIJ_ADICAO

      IF ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim
         SW2->(DBSEEK(xFILIAL("SW2")+SW8->W8_PO_NUM))
         nQtdMerc  := SW8->W8_QTDE * SB1->B1_QTMIDIA
         nVLMCV    := DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc) + SW8->W8_FRETEIN),7)
         nVLMCVUnit:= DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc) + SW8->W8_FRETEIN)/nQtdMerc,7)
         nTotVLMCV := DI500Trans( nVLMCVUnit * nQtdMErc, 7)  //Transforma para 7 casas decimais
      ELSE
         nQtdMerc   := SW8->W8_QTDE
         nVLMCV     := DI500Trans( DI500RetVal("ITEM_INV", "TAB", .T.) , 2 )
         nVLMCVUnit := DI500Trans(nVLMCV/nQtdMerc,7)
         nTotVLMCV  := DI500Trans( nVLMCVUnit * nQtdMErc, 7) //Transforma para 7 casas decimais
      ENDIF

      nFobUniTot += nTotVLMCV

      aAdd(aItensAdi,{SW8->W8_FILIAL,SW8->W8_HAWB,SW8->W8_ADICAO,nVLMCVUnit,nTotVLMCV })
      //SW8->(W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)
      SW8->(DbSkip())
   EndDo

   RestOrd(aOrdSW9,.T.)
   aRet := {EIJ->EIJ_ADICAO,nFobUniTot,aItensAdi}

ElseIf cAlias == "Work"

   aOrdSW9 := SaveOrd({"Work_SW8","Work_SW9","SW2"})
   Work_SW8->(dbSetOrder(4))
   Work_SW8->(dbSeek(Work_EIJ->EIJ_ADICAO))
   Work_SW9->(DbSetOrder(1))                                                               	//NCF - 23/03/2012 - Posicionar Capa da Invoice para verificação de despesas
   Work_SW9->(DbSeek(Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")))  // GFP - 12/05/2015

   Do While !Work_SW8->(Eof()) .And. Work_SW8->WKADICAO == Work_EIJ->EIJ_ADICAO

      IF ExisteMidia() .AND. lPesoMid .AND. SB1->B1_MIDIA $ cSim
         SW2->(DBSEEK(xFILIAL("SW2")+Work_SW8->WKPO_NUM))
         nQtdMerc  := Work_SW8->WKQTDE * SB1->B1_QTMIDIA
         nVLMCV    := DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc) + Work_SW8->WKFRETEIN),7)
         nVLMCVUnit:= DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc) + Work_SW8->WKFRETEIN)/nQtdMerc,7)
         nTotVLMCV := DI500Trans( nVLMCVUnit * nQtdMErc, 7)  //Transforma para 7 casas decimais
      ELSE
         nQtdMerc   := Work_SW8->WKQTDE
         nVLMCV     := DI500Trans( DI500RetVal("ITEM_INV", "WORK", .T.) , 2 )
         nVLMCVUnit := DI500Trans( nVLMCV/nQtdMerc,7)
         nTotVLMCV  := DI500Trans( nVLMCVUnit * nQtdMErc, 7) //Transforma para 7 casas decimais
      ENDIF

      nFobUniTot += nTotVLMCV

      aAdd(aItensAdi,{Work_SW8->WKADICAO,nVLMCVUnit,nTotVLMCV })

      Work_SW8->(DbSkip())
   EndDo

   RestOrd(aOrdSW9,.T.)
   aRet := {Work_EIJ->EIJ_ADICAO,nFobUniTot,aItensAdi}

EndIf

Return aRet

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500GrvXML()
Parametros : aXml    - Vetor com as informações a partir do vetor aLoadTxt, como tambem em certos pontos da funçao DI500GrvTxt
             cVersao - Versao do arquivo XML
             cIdent  - Id do arquivo XML
Retorno    : oXml    - Objeto com as tags do XML
Objetivos  : Carregar o objeto oXml com as tags definidas na funcao DI500LoadXML, para criação da Declaração Amazonense de Importação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500GrvXML(aXml,cVersao,cIdent)
Local i,j,k
Local oEnviDIe := ENode():New()
Local oDIe := ENode():New()
Local oTagDIe := ENode():New()
Local oInfDIe := ENode():New()
Local oAdicoes
Local oItemAdicoes
Local oLacres
Local aDadosDAI := {}
Local aInfDie := {}
Local aAdicoes := {}
Local aCapaAdicao := {}
Local aItens := {}
Local aLacres := {}
Local oXml
Local cId := ""
Default cIdent := ""
Default cVersao := ""
Default aXml := {}

   cId := "DIe" + cIdent
   aDadosDAI := aClone(aXml[1])
   oInfDIe:SetField(EAtt():New("versao",cVersao))
   oInfDIe:SetField(EAtt():New("Id",cId))
   aInfDie := DI500LoadXML(aDadosDAI,1,cVersao)
   For i := 1 to Len(aInfDie)
      oInfDIe:SetField(aInfDIe[i][1],aInfDIe[i][2])
   Next

   // Todas as Adicoes e seus respectivos itens
   aAdicoes := aClone(aXml[2])
   For i := 1 To Len(aAdicoes)

      aCapaAdicao := DI500LoadXML(aAdicoes[i][1],2,cVersao)
      oAdicoes:= ENode():New()
      oAdicoes:SetField(EAtt():New("versao",cVersao))
      For j := 1 To Len(aCapaAdicao)
         oAdicoes:SetField(aCapaAdicao[j][1],aCapaAdicao[j][2])
      Next

      For j := 1 To Len(aAdicoes[i][2])
         aItens := DI500LoadXML(aAdicoes[i][2][j],3,cVersao)
         oItemAdicoes:= ENode():New()
         For k := 1 To Len(aItens)
            If aItens[k][1] == "numItem"
               oItemAdicoes:SetField(aItens[k][1],PADL(k,3,"0"))
            Else
               oItemAdicoes:SetField(aItens[k][1],aItens[k][2])
            EndIf
         Next
         oAdicoes:SetField("itemAdicao",oItemAdicoes)
      Next

      oInfDIe:SetField("adicao",oAdicoes)
   Next

   // Todos lacres
   If "2.01" $ cVersao
      aLacres := aClone(aXml[3])
      For i := 1 To Len(aLacres)
         aLacre := DI500LoadXML(aLacres[i],4,cVersao)
         oLacres:= ENode():New()
         oLacres:SetField(EAtt():New("versao",cVersao))
         For j := 1 To Len(aLacre)
            oLacres:SetField(aLacre[j][1],aLacre[j][2])
         Next
         oInfDIe:SetField("lacre",oLacres)
      Next
   EndIf

   oTagDIe:SetField("InfDIe",oInfDIe)
   //oTagDIe:SetField("Signature","")
   oDIe:SetField("DIe",oTagDIe)
   oDIe:SetField(EAtt():New("versao",cVersao))
   oDIe:SetField(EAtt():New("xmlns","http://www.sefaz.am.gov.br/die"))
   oDIe:SetField(EAtt():New("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance"))
   oDIe:SetField(EAtt():New("xsi:schemaLocation","http://www.sefaz.am.gov.br/die enviDIe_v"+cVersao+".xsd"))
   oEnviDIe:SetField("enviDIe",oDIe)

   oXml      := EXml():New()
   oXml:AddRec(oEnviDIe)

Return oXml

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500LoadXML()
Parametros : aDados   - Vetor com as informações do arquivo XML
             nSchema  - 1 - Dados da DI ;  2 - Dados das adições da DI ; 3 - Dados do item da adição da DI ; 4 - Dados do lacre
             cVersao  - Versao do arquivo XML
Retorno    : aRet     - Vetor responsavel pela Tag e a informação {TAG,INFORMACAO}
Objetivos  : Carregar o vetor de acordo com nSchema para criação do objeto do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500LoadXML(aDados,nSchema,cVersao)
Local i := 0
Local aRet := {}
Local aInfo := {}
Local nPosTag
Local aSchema := DI500ScheDAI(nSchema,cVersao)

   // aDados
   // {Tipo de Registro, Ordem, Tag, Informacao}

   For i := 1 To Len(aSchema)
      If (nPosTag := aScan(aDados,{|X| AllTrim(Upper(aSchema[i][1])) == AllTrim(Upper(X[1])) .And. aSchema[i][2] == X[2] .And. AllTrim(Upper(aSchema[i][3])) == AllTrim(Upper(X[3])) } )) > 0

         xInfo := aDados[nPosTag][4]
         If ValType(xInfo) == "N" .And. ValType(aSchema[i][5]) == "N"
            xInfo := xInfo * aSchema[i][5]
         ElseIf ValType(xInfo) == "U"
            xInfo := ""
         EndIf

         If aSchema[i][4] .Or. !Empty(xInfo)
            aAdd(aRet,{aDados[nPosTag][3],DI500TagTam(xInfo,aSchema[i][6])} )
         EndIf

      ElseIf aSchema[i][4]
         If aSchema[i][7] == "A"
            aAdd(aRet,{aSchema[i][3],""} )
         ElseIf aSchema[i][7] == "N"
            aAdd(aRet,{aSchema[i][3],0} )
         EndIf
      EndIf

   Next

Return aClone(aRet)

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500TagTam()
Parametros : xInfo    - Informação da Tag
             nTamanho - Tamanho da Tag
Retorno    : xInfo    - Informação da Tag
Objetivos  : Retornar o tamanho da Tag conforme especificado na funcao DI500ScheDAI
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500TagTam(xInfo,nTamanho)
Local nTamInfo := 0

   If !(ValType(xInfo) == "C")
      xInfo := cValToChar(xInfo)
   EndIf
   nTamInfo := Len(xInfo)

   If nTamInfo > nTamanho
      xinfo := Stuff(xInfo, nTamanho+1, nTamInfo, "")
   EndIf

Return xInfo

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500ScheDAI()
Parametros : nSchema - 1 - Dados da DI ;  2 - Dados das adições da DI ; 3 - Dados do item da adição da DI ; 4 - Dados do lacre
             cVersao - Versão do arquivo XML
Retorno    : aXML    - Estrutura do nSchema
Objetivos  : Retornar a estrutura do arquivo XML de acordo com suas validações e restrições
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500ScheDAI(nSchema,cVersao)
Local aXML := {}
Default cVersao := ""

// Observação: As posições do vetor aXML deverá respeitar a ordem das tags do XML da DAI.
Do Case
   Case nSchema == 1 // Dados da DI
             //  Tipo de Registro, Ordem, Tag, Obrigatorio, Coeficiente de multiplicacao, Tamanho maximo da tag, Escopo
      aAdd(aXML,{""   ,0  , "tipoDIe"               ,.T.          ,         ,002,"N" })
      aAdd(aXML,{""   ,0  , "nrDocumento"           ,.T.          ,         ,010,"N" })
      aAdd(aXML,{""   ,0  , "dtDocumento"           ,.T.          ,         ,008,"N" })
      aAdd(aXML,{""   ,0  , "numRetificacao"        ,.T.          ,         ,001,"N" })
      //aAdd(aXML,{"01" ,58 , "vlFob"                 ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlFob"                 ,.T.          ,100      ,017,"N" })
      //aAdd(aXML,{"01" ,51 , "vlFrete"               ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlFrete"               ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"01" ,52 , "vlSeguro"              ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"07" ,06 , "vlII"                  ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"07" ,06 , "vlIPI"                 ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"07" ,06 , "vlPisCofins"           ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlCide"                ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"07" ,06 , "vlAntiDumping"         ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"07" ,08 , "vlMultasJuros"         ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlTaxasDiversas"       ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlTaxasCapatazia"      ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "UFImportador"          ,.T.          ,         ,002,"N" })
      aAdd(aXML,{""   ,0  , "vlTaxaDolar"           ,.T.          ,10000    ,013,"N" })
      aAdd(aXML,{"01" ,42 , "vlPesoLiquido"         ,.T.          ,100000   ,017,"N" })
      aAdd(aXML,{"01" ,46 , "cdRecintoAduaneiro"    ,.T.          ,         ,007,"N" })
      aAdd(aXML,{""   ,0  , "cdPaisProcedencia"     ,.T.          ,         ,005,"N" })
      aAdd(aXML,{"01" ,04 , "qtdeAdicoes"           ,.T.          ,         ,003,"N" })
      If "2.01" $ cVersao // MV_DIEVERS
         aAdd(aXML,{""   ,0  , "txInfoCompl"           ,.T.          ,         ,4000,"A" })
      EndIf

   Case nSchema == 2 // Dados das adições da DI
      aAdd(aXML,{"10" ,03 , "numAdicao"             ,.T.          ,         ,003,"N" })
      aAdd(aXML,{""   ,0  , "tipoImportador"        ,.T.          ,         ,001,"N" })
      aAdd(aXML,{""   ,0  , "cdImportador"          ,.T.          ,         ,014,"N" })
      aAdd(aXML,{""   ,0  , "nomeImportador"        ,.T.          ,         ,060,"A" })
      aAdd(aXML,{""   ,0  , "nomeFornecedor"        ,.T.          ,         ,030,"A" })
      aAdd(aXML,{""   ,0  , "cdDestinacao"          ,.T.          ,         ,002,"N" })
      aAdd(aXML,{""   ,0  , "cdUtilizacao"          ,.T.          ,         ,002,"N" })
      aAdd(aXML,{""   ,0  , "cdNcmProdFinal"        ,.T.          ,         ,008,"N" })
      aAdd(aXML,{""   ,0  , "cdSuframa"             ,.T.          ,         ,004,"N" })
      aAdd(aXML,{"10" ,33 , "vlFob"                 ,.T.          ,100      ,017,"N" })
      //aAdd(aXML,{"10" ,34 , "vlFob"                 ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"10" ,35 , "vlFrete"               ,.T.          ,100      ,017,"N" })
      //aAdd(aXML,{"10" ,37 , "vlFrete"               ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"10" ,38 , "vlSeguro"              ,.T.          ,100      ,017,"N" })
      //aAdd(aXML,{"10" ,40 , "vlSeguro"              ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"15" ,20 , "vlIi"                  ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"15" ,20 , "vlIpi"                 ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"15" ,20 , "vlPisCofins"           ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlCide"                ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"15" ,20 , "vlAntiDumping"         ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlMultaseJuros"        ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlTaxasDiversas"       ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlTaxasCapatazia"      ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{"10" ,27 , "vlPesoLiquido"         ,.T.          ,100000   ,017,"N" })
      aAdd(aXML,{""   ,0  , "cdTributacao"          ,.T.          ,         ,004,"A" })
      aAdd(aXML,{""   ,0  , "vlBcIcms"              ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlCm"                  ,.T.          ,100000   ,006,"N" })
      aAdd(aXML,{""   ,0  , "vlIcms"                ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "numDiAdmissaoTemp"     ,.T.          ,         ,010,"N" })
      aAdd(aXML,{""   ,0  , "numDiEizof"            ,.T.          ,         ,010,"N" })

   Case nSchema == 3 // Dados do item da adição da DI
      aAdd(aXML,{""   ,0  , "numItem"               ,.T.          ,         ,003,"N" })
      aAdd(aXML,{""   ,0  , "cdNcmItem"             ,.T.          ,         ,008,"N" })
      aAdd(aXML,{""   ,0  , "cdDestaqueItem"        ,.T.          ,         ,004,"N" })
      aAdd(aXML,{""   ,0  , "txDescricaoSuframa"    ,.T.          ,         ,255,"A" })
      aAdd(aXML,{"19" ,04 , "txDescricaoDestalhada" ,.T.          ,         ,3723,"A" })
      aAdd(aXML,{"16" ,04 , "qtdItem"               ,.T.          ,100000   ,017,"N" })
      aAdd(aXML,{""   ,0  , "unidadeMedida"         ,.T.          ,         ,010,"A" })
      aAdd(aXML,{"16" ,06 , "vlUnitario"            ,.T.          ,10000000 ,017,"N" })
      aAdd(aXML,{""   ,0  , "vlTotal"               ,.T.          ,100      ,017,"N" })
      aAdd(aXML,{""   ,0  , "nrPexPam"              ,.T.          ,         ,009,"N" })

   Case nSchema == 4 .And. "2.01" $ cVersao // MV_DIEVERS // Dados do lacre
      aAdd(aXML,{""   ,0  , "tpVeiculo"             ,.T.          ,         ,001,"N" })
      aAdd(aXML,{""   ,0  , "idVeiculo"             ,.T.          ,         ,020,"A" })
      aAdd(aXML,{""   ,0  , "nrLacre"               ,.T.          ,         ,020,"A" })

EndCase

Return aClone(aXML)

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DI500UFCod()
Parametros : cUF
Retorno    : cCodigo - Codigo do UF
Objetivos  : Retornar o codigo do estado.
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DI500UFCod(cUF)
Local aUf := {}
Local cCodigo := ""
Local nPos := 0

aAdd(aUf,{"11", "RO" })
aAdd(aUf,{"12", "AC" })
aAdd(aUf,{"13", "AM" })
aAdd(aUf,{"14", "RR" })
aAdd(aUf,{"15", "PA" })
aAdd(aUf,{"16", "AP" })
aAdd(aUf,{"17", "TO" })
aAdd(aUf,{"21", "MA" })
aAdd(aUf,{"22", "PI" })
aAdd(aUf,{"23", "CE" })
aAdd(aUf,{"24", "RN" })
aAdd(aUf,{"25", "PB" })
aAdd(aUf,{"26", "PE" })
aAdd(aUf,{"27", "AL" })
aAdd(aUf,{"28", "SE" })
aAdd(aUf,{"29", "BA" })
aAdd(aUf,{"31", "MG" })
aAdd(aUf,{"32", "ES" })
aAdd(aUf,{"33", "RJ" })
aAdd(aUf,{"35", "SP" })
aAdd(aUf,{"41", "PR" })
aAdd(aUf,{"42", "SC" })
aAdd(aUf,{"43", "RS" })
aAdd(aUf,{"50", "MS" })
aAdd(aUf,{"51", "MT" })
aAdd(aUf,{"52", "GO" })
aAdd(aUf,{"53", "DF" })

If (nPos := aScan(aUf,{|X| X[2] == cUf})) > 0
   cCodigo := aUf[nPos][1]
EndIf

Return cCodigo

/*
Função      : DI505WizLote
Parametros  : Nenhum.
Retorno     : Nil
Objetivos   : Apresentar assistente (wizard) para vinculação dos lotes informados na fase da LI aos itens da invoice atual.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Function DI505WizLote()
Local aOrd := SaveOrd({"WORK_SW8", "Work_CWV", "Work_SWV"})

//Mensagens do wizard
Local cMensagem1, cMensagem2, cMensagem3

Local oWizard
Local oFont    := TFont():New(,, ,,.T.)

//Array contendo detalhamento dos itens com lotes disponíveis e das associações feitas durante o Wizard
Local aDados := GetItensComLote()
Local aHeaderItens := aDados[1]
Local aItens := aDados[2]

Local i

Private oBrowseItens

	//Mensagem de abertura do wizard
	cMensagem1 := StrTran(STR0354, "XXX", AllTrim(WORK_SW9->W9_INVOICE)) + ENTER //"Esta rotina irá auxilar o processo de vinculação de lotes para os itens da Invoice 'XXX'"
	cMensagem1 +=  STR0355 + ENTER //"Serão avaliados os lotes informados nas Licenças de Importação relacionadas aos itens desta invoice."
	cMensagem1 +=  STR0356 + ENTER //"Caso sejam encontrados lotes com saldo disponível, será possível associá-los na tela a seguir, clicando sobre os itens apresentados e informado a quantidade a vincular."
	cMensagem1 +=  STR0357 //"As demais operações a serem efetuadas sobre os lotes (visualização, inclusão, alteração e exclusão) deverão ser executadas na manutenção de lotes, disponível na tela principal."

	DEFINE WIZARD oWizard	TITLE STR0358; //"Assistente de Inclusão de Lotes"
							HEADER STR0359; //"Início"
							MESSAGE STR0360; //"Apresentação"
							TEXT cMensagem1;
							PANEL NEXT	{|| If(Len(aItens) > 0, oWizard:nPanel := 1, oWizard:nPanel := 2), .T. };
							FINISH 		{|| .T.}

		//Painel 1 - Apresentação dos itens que possuem lotes disponíveis para associação (quando disponíveis)
		//Ao avançar, caso algum lote tenha sido vinculado, efetiva a associação na função AssociaLotes()
		CREATE PANEL oWizard HEADER STR0361	MESSAGE STR0362 + ENTER +; //"Resultado da Verificação" - "Foram encontrados lotes disponíveis para os itens abaixo."
		                                                      STR0363; //"Clique sobre o item para verificar os lotes associados/disponíveis."
															  PANEL;
															  FINISH	{|| .F. };
															  EXEC	{|| .T. };
															  NEXT 	{|| AssociaLotes(aItens), oWizard:nPanel := 3, .T. }
	                                                          oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			//Browse contendo os itens disponíveis para vinculação com lote
			DEFINE FWBROWSE oBrowseItens DATA ARRAY ARRAY aItens OF oPanel

				For i := 1 To Len(aHeaderItens)
					//Os itens iniciados com $ no header são utilizados para controles internos e não serão exibidos no browse
					If Left(aHeaderItens[i], 1) <> "$"
						ADD;
						COLUMN oColumn;
						;//Readvar da célula. Neste caso a manutenção será feita diretamente no array, sem variável de memória
						DATA &('{ || aItens[oBrowseItens:At()][' + Str(i) + '] }');
						;//Os itens iniciados com # no Header não fazem parte do dicionário de dados e terão o título igual ao informado no header
						TITLE If(Left(aHeaderItens[i], 1) == "#", SubStr(aHeaderItens[i], 2), AvSx3(aHeaderItens[i], AV_TITULO));
						OF oBrowseItens
					EndIf
				Next
				//Ao dar duplo clique sobre o item será exibida a tela de detalhamento e associação dos lotes
				oBrowseItens:SetDoubleClick({|| VerLotes(aDados[2][oBrowseItens:At()], oWizard) })

			ACTIVATE FWBROWSE oBrowseItens

        //Painel 2 - Apresentado somente quando não existirem item/lotes disponíveis para vinculação
		CREATE PANEL oWizard HEADER STR0364	PANEL; //"Resultado da Verificação"
											BACK	{|| .F. };
											NEXT	{|| .T. };
										    FINISH	{|| .T. };
											EXEC	{|| .T. }
											oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			cMensagem2 := STR0365 + ENTER //"Não foram identificados lotes disponíveis para os itens desta invoice ou todos os itens já possuem vinculação com lotes, sem saldo disponível para nova vinculação."
			cMensagem2 += ENTER
			cMensagem2 += STR0366 + ENTER //"Nenhuma alteração foi efetuada."

			@ 10, 10 Say cMensagem2 Size oPanel:nClientHeight, oPanel:nClientWidth Font oFont Pixel Of oPanel

		//Painel 3 - Finalização da rotina e apresentação do botão com o resumo dos lotes do processo
		CREATE PANEL oWizard HEADER STR0367						MESSAGE STR0368; //"Finalização" - "Conferência Final"
																PANEL;
																BACK	{|| .F. };
																NEXT	{|| .F. };
																FINISH	{|| .T. };
																EXEC	{|| .T. }
                                                                oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			cMensagem3 := STR0369 + ENTER //"O assistente de inclusão de lotes foi finalizado. "
			cMensagem3 += ENTER
			cMensagem3 += STR0370 + ENTER //"As associações de lotes poderão ser editadas na manutenção de lotes, disponível na tela principal."
			cMensagem3 += ENTER
			cMensagem3 += STR0371 + ENTER //"Além disso, todos os lotes associados a este processo podem ser consultados ao clicar no botão 'Visualizar Lotes.'"

			@ 10, 10 Say cMensagem3 Size oPanel:nClientHeight, oPanel:nClientWidth Font oFont Pixel Of oPanel
			//Apresenta botão com resumo dos lotes do processo
			@ (oPanel:nClientHeight / 2) * 0.8, (oPanel:nClientWidth / 2) * 0.8 BUTTON STR0372  SIZE 50,12 ACTION DI500VerLotes(.T.) OF oPanel Pixel //"Visualizar Lotes"  //LGS-27/02/2015

      ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

RestOrd(aOrd, .T.)
Return Nil

/*
Função      : GetItensComLote()
Parametros  : Nenhum.
Retorno     : {aHeader, aInvoices} - Array contendo: [1]Header com o nome dos campos, [2]Array contendo a relação de itens disponíveis
Objetivos   : Relacionar os itens da invoice atual que possuem saldo não vinculado a lotes e os lotes disponíveis para associação informados na fase de LI
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function GetItensComLote()
//Indice do array de Invoices, utilizado como referência para criação do objeto FWBROWSE
Local aHeader
//Relação de itens da Invoice com saldo disponível para associação com lotes
Local aInvoice
Local aInvoices := {}
//Relação de Lotes disponíveis para associação
Local aLotesDisp
//Guia para uso do array de itens
Local nSaldo := 8, nLotesAsso := 9


	aHeader := {"W8_POSICAO", "W8_PO_NUM", "W8_COD_I", "$W8_FORN", If(EicLoja(), "$W8_FORLOJ", "$Loja"), "#Descrição", "$W8_QTDE", "#Saldo sem Lote", "$Associações", "$Lotes"}

	WORK_SW8->(DbGoTop())
	While WORK_SW8->(!Eof())
		//Busca os lotes lançados na fase de LI disponíveis para associação
		aLotesDisp := GetLotesBase()

		//Caso existam lotes disponíveis, os mesmos estarão registrados na segunda posição do array
		If Len(aLotesDisp[2]) > 0
			//Adiciona o item da Invoice
			aInvoice := WORK_SW8->({WKPOSICAO,;
									WKPO_NUM,;
									WKCOD_I,;
									WKFORN,;
									If(EicLoja(), W8_FORLOJ, ""),;
									WKDESCITEM,;
									WKQTDE,;				//Qtd.Disp
									WKQTDE,;				//Saldo a Vincular
									{},;					//Lotes já vinculados (para controle do saldo a vincular)
									aClone(aLotesDisp)})//Lotes Disponíveis para associação

			//Busca os lotes já associados
			WORK_SWV->(DbSetOrder(2))
			//WV_FORN+WV_FORLOJ+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
			WORK_SWV->(DbSeek(WORK_SW8->(WKFORN+If(EicLoja(), W8_FORLOJ, "")+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE)))
			While WORK_SWV->(WV_FORN+If(EicLoja(), WV_FORLOJ, "")+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE) == WORK_SW8->(WKFORN+If(EicLoja(), W8_FORLOJ, "")+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE)
				//Abate o saldo disponível para vinculação da quantidade já associada
				aInvoice[nSaldo] -= WORK_SWV->WV_QTDE
				aAdd(aInvoice[nLotesAsso], WORK_SWV->({WV_LOTE, WV_FORN, If(EicLoja(), WV_FORLOJ, ""), WV_PGI_NUM, WV_PO_NUM, WV_POSICAO, WV_INVOICE, WV_QTDE}))
				WORK_SWV->(DbSkip())
			EndDo
			//Caso tenha saldo a vincular e lote disponível, inclui no array aInvoices para exibição no Wizard
			If aInvoice[nSaldo] > 0
				aAdd(aInvoices, aClone(aInvoice))
			EndIf
		EndIf
		WORK_SW8->(DbSkip())
	EndDo

Return {aHeader, aInvoices}

/*
Função      : GetLotesBase()
Parametros  : Nenhum.
Retorno     : {aHeader, aLotes} - Array contendo: [1] - Header com o nome dos campos, [2] - Array com a relação de Lotes disponíveis para vinculação
Objetivos   : Buscar os lotes lançados na fase de LI disponíveis para associação com os itens da invoice atual
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function GetLotesBase()
Local cHAWB 	:= M->W6_HAWB
Local cPO		:= WORK_SW8->WKPO_NUM
Local cLI		:= WORK_SW8->WKPGI_NUM
Local cCOD		:= WORK_SW8->WKCOD_I
Local nReg		:= WORK_SW8->WKREG
Local cVazio	:= ""

Local aLotes := {}, aHeader
Local nSaldo
Local nRegQRY
Local lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO")
Local cSelect := '%WV_LOTE, WV_PGI_NUM, WV_PO_NUM, WV_CC, WV_POSICAO, WV_SI_NUM, WV_COD_I, WV_REG, WV_QTDE, WV_DT_VALI, WV_OBS,'
If lCpoDtFbLt
   cSelect += "WV_DFABRI,"
EndIf
cSelect += "%"
	/*
	Busca os lotes lançados em fase de LI relacionados ao item abatendo a quantidade já utilizada em outros processos
	As quantidades utilizadas no processo atual serão avaliadas diretamente na work de lotes
	*/
	BeginSql Alias "QRY"

		Select
			%Exp:cSelect%
			(	Select
					Sum(WV_QTDE)
				From
					%table:SWV% SALDO
				Where
					SALDO.WV_FILIAL = %xfilial:SWV%
					And SALDO.%notDel%
					And SALDO.WV_LOTE		=	LOTE.WV_LOTE
					And SALDO.WV_PO_NUM 	=	LOTE.WV_PO_NUM
					And SALDO.WV_PGI_NUM	=	LOTE.WV_PGI_NUM
					And SALDO.WV_COD_I		=	LOTE.WV_COD_I
					And SALDO.WV_REG		=	LOTE.WV_REG
					And SALDO.WV_HAWB 		<>	%Exp:cVazio%
					And SALDO.WV_HAWB 		<>	%Exp:cHAWB%
			) As QTDUSADA
		From
			%table:SWV% LOTE
		Where
			LOTE.WV_FILIAL			= %xfilial:SWV%
			And LOTE.%notDel%
			And LOTE.WV_PO_NUM 		= %Exp:cPO%
			And LOTE.WV_PGI_NUM		= %Exp:cLI%
			And LOTE.WV_COD_I		= %Exp:cCOD%
			And LOTE.WV_REG			= %Exp:nReg%
			And LOTE.WV_HAWB 		= %Exp:cVazio%

	EndSql

   TCSetField("QRY", "WV_DT_VALI", "D")
   If lCpoDtFbLt
      TCSetField("QRY", "WV_DFABRI", "D")
   EndIf

	//Relação de campos do Array
	aHeader := {"WV_LOTE", "$WV_PGI_NUM", "$WV_PO_NUM", "$WV_CC", "$WV_POSICAO", "$WV_SI_NUM", "$WV_COD_I", "$WV_REG", "WV_QTDE", "#Disponível", "&Associado", "WV_DT_VALI", "WV_OBS"}

    If lCpoDtFbLt
       aAdd(aHeader,"WV_DFABRI")
    EndIf 
	//LGS-03/12/2014-Regrava o campo WV_REG para nao apresentar itens para ser utilizado quando exclui a invoice e recria novamente e quer vincular os lotes sem gravar o desembaraço.
	nRegQRY := STR(QRY->WV_REG,4)
	SWV->(DbSeek(xFilial('SWV')+' '))
	DO WHILE SWV->(!EOF())
	   IF SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I) == QRY->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I)
	      IF SWV->WV_REG <> QRY->WV_REG
	      	  nRegQRY := STR(SWV->WV_REG,4)
	      ENDIF
	      SWV->(DbSkip())
	   ENDIF
	   SWV->(DbSkip())
	ENDDO

	//Busca as quantidades já utilizadas neste processo para definir o saldo
	WORK_SWV->(DbSetOrder(3))
	While QRY->(!Eof())
		If QRY->(WV_QTDE - QTDUSADA) > 0
			nSaldo := WV_QTDE - QTDUSADA
			//WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+ STR(WV_REG,4)+WV_LOTE
			WORK_SWV->(DbSeek(QRY->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+ nRegQRY/*STR(WV_REG,4)*/ + QRY->WV_LOTE)))
			While WORK_SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+ STR(WV_REG,4)+WV_LOTE) == QRY->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+ nRegQRY/*STR(WV_REG,4)*/+WV_LOTE)
				nSaldo -= WORK_SWV->WV_QTDE
				WORK_SWV->(DbSkip())
			EndDo
			If nSaldo > 0
				//Caso possua saldo, relaciona informações do lotes para que o mesmo esteja disponível para vinculação ao item atual
				aAdd(aLotes, QRY->({WV_LOTE, WV_PGI_NUM, WV_PO_NUM, WV_CC, WV_POSICAO, WV_SI_NUM, WV_COD_I, WV_REG, WV_QTDE, nSaldo, 0, WV_DT_VALI, WV_OBS}))
                If lCpoDtFbLt
                   aAdd( aLotes[Len(aLotes)] ,  QRY->WV_DFABRI )
                EndIf 
			EndIf
		EndIf
		QRY->(DbSkip())
	EndDo
	QRY->(DbCloseArea())

Return {aHeader, aLotes}

/*
Função      : VerLotes
Parametros  : aItem - Array contendo as definições do item atual
              oWizard - Objeto do wizard ativo
Retorno     : Nenhum
Objetivos   : Exibir os lotes disponíveis para associação ao item selecionado e permitir a vincução, obtendo a quantidade desejada pelo usuário
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function VerLotes(aItem, oWizard)
Local oDlg, i

//Header dos campos do lote a ser exibido
Local aHeader	:= aItem[10][1]

//Descrição do Item - Posição+Descrição
Local cItem	:= AllTrim(aItem[1])+"-"+AllTrim(aItem[3])

//Backup das associações de lote para comparação durante a execução
Local aLotesBack := aClone(aItem[10][2])

//Picture para os campos de quantidade de lote
Local cPictureLote := AvSX3("WV_QTDE", AV_PICTURE)

Private oBrowseLotes

//Relação de lotes a serem exibidos durante a manutenção. Utilizada também pelas funções complementares.
Private aLotes	:= aItem[10][2]

	DEFINE MSDIALOG oDlg TITLE StrTran(STR0373, "XXX", cItem) FROM 1,1 TO oWizard:oDlg:nClientHeight, oWizard:oDlg:nClientWidth OF oMainWnd PIXEL //"Associação de lotes disponíveis para o item 'XXX'"

		DEFINE FWBROWSE oBrowseLotes DATA ARRAY ARRAY aLotes OF oDlg
			//Habilita a edição de células no browse e especifica a função de validação
			oBrowseLotes:SetEditCell(.T.)
			oBrowseLotes:bValidEdit := {|| ValidVlLote(aLotes[oBrowseLotes:At()], aLotesBack[oBrowseLotes:At()], aItem, cPictureLote) }

			For i := 1 To Len(aHeader)
				//Caso o item estiver marcado com $ no header, o mesmo não será exibido no browse
				If Left(aHeader[i], 1) <> "$"
					ADD;
					COLUMN oColumn;
					DATA &('{ || aLotes[oBrowseLotes:At()][' + Str(i) + '] }');
					TITLE If(Left(aHeader[i], 1) $ "#/&", SubStr(aHeader[i], 2), AvSx3(aHeader[i], AV_TITULO));
					OF oBrowseLotes

					//Se o campo estiver marcado com &, permite a edição do mesmo
					If Left(aHeader[i], 1) == "&"
						oColumn:SetEdit(.T.)
						//O Readvar do campo será o próprio item no array
						oColumn:SetReadVar('aLotes[oBrowseLotes:At()][' + Str(i) + ']')
					Else
						//Se o campo não for editável, executa a associação automática do saldo no duplo-clique
						oColumn:SetDoubleClick({|| AssociaSaldo(aLotes[oBrowseLotes:At()], aLotesBack[oBrowseLotes:At()], aItem) })
					EndIf

					//Se o campo for numérico, define a picture de quantidade de lote
					If Len(aLotes) > 0 .And. ValType(aLotes[1][i]) == "N"
						oColumn:SetPicture(cPictureLote)
					EndIf
				EndIf
			Next

		ACTIVATE FWBROWSE oBrowseLotes

	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*
Função      : AssociaSaldo
Parametros  : aLote - Linha atual do lote editado
              aLoteBack - Linha de backup do lote atual
              aItem - Array com as definições do item editado
Retorno     : Nenhum
Objetivos   : Associar a quantidade máxima possível do lote atual com o item, no duplo-clique sobre o lote
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function AssociaSaldo(aLote, aLoteBack, aItem)

	//Verifica se o item e o lote possuem saldo
	If aItem[8] > 0 .And. aLote[10] > 0
		//Se o saldo a vincular do item for menor ou igual à quantidade disponível do lote, associa todo o saldo do item ao lote
		If aItem[8] <= aLote[10]
			//Soma a quantidade associada do lote
			aLote[11] += aItem[8]
			//Abate o saldo a vincular do lote
			aLote[10] -= aItem[8]
			//Zera o saldo a vincular do item
			aItem[8] := 0
		Else//Se a quantidade do lote for menor do que o saldo a vincular do item, associa todo o saldo do lote ao item
			//Soma a quantidade associada do lote
			aLote[11] += aLote[10]
			//Abate o saldo a vincular do item
			aItem[8] -= aLote[10]
			//Zera o saldo do lote
			aLote[10] := 0
		EndIf
		//Atualiza o backup dos lotes
		aLoteBack := aClone(aLote)
	EndIf

Return Nil

/*
Função      : ValidVlLote
Parametros  : aLote - Linha atual do lote editado
              aLoteBack - Linha de backup do lote atual
              aItem - Array com as definições do item editado
              cPictureLote - Picture dos valores de quantidade do lote
Retorno     : Nenhum
Objetivos   : Validar a quantidade informada para vinculação do lote ao item
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function ValidVlLote(aLote, aLoteBack, aItem, cPictureLote)
Local lRet := .T.

Begin Sequence

	//Somente valida se o valor digitado for diferente do valor anterior
	If aLote[11] <> aLoteBack[11]

		//Não permite valores negativos
		If aLote[11] < 0
			MsgInfo(STR0374, STR0375) //"Valor inválido." - "Aviso"
			lRet := .F.
			Break
		EndIf

		//Verifica se o valor informado é maior do que o saldo disponível do item somado do valor já associado (que será sobrescrito)
		If aLote[11] > (aItem[8]  + aLoteBack[11])
			MsgInfo(StrTran(STR0376, "XXX", AllTrim(Transform(aItem[8] , AvSX3("WV_QTDE", AV_PICTURE)))), STR0375) //"A quantidade informada é superior ao saldo não vinculado do item (XXX)." - "Aviso"
			lRet := .F.
			Break
		EndIf

		//Verifica se o valor informado é maior do que o saldo disponível do lote somado do valor já associado (que será sobrescrito)
		If aLote[11] > (aLote[10] + aLoteBack[11])
			MsgInfo(StrTran(STR0377, "XXX", AllTrim(Transform(aLote[10], cPictureLote))), STR0375) //"A quantidade informada é superior ao saldo do lote (XXX)." - "Aviso"
			lRet := .F.
			Break
		EndIf

		//Devolve o valor associado anteriormente ao saldo disponível do lote
		aLote[10] += aLoteBack[11]
		//Abate o valor associado do saldo do lote
		aLote[10] -= aLote[11]

		//Devolve o valor associado anteriormente do saldo do item
		aItem[8] += aLoteBack[11]
		//Abate o valor associado do saldo a vincular do item
		aItem[8] -= aLote[11]

		//Atualiza o backup dos lotes
		aLoteBack := aClone(aLote)

	EndIf

End Sequence

Return lRet

/*
Função      : AssociaLotes
Parametros  : aItems - Array contendo as definições dos items e dos lotes associados a eles
Retorno     : Nenhum
Objetivos   : Atualizar os arquivos de trabalho da rotina de lotes com as informações das associações feitas durante o Wizard
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/09/12
*/
Static Function AssociaLotes(aItens)
Local aOrd := SaveOrd({"Work_CWV", "Work_SWV"})
Local lAtualiza := .F., lExisteLote := .F.
Local i, j
Local lCpoDtFbLt := AvFlags("DATA_FABRIC_LOTE_IMPORTACAO")

Begin Sequence

	//Verifica se houve alguma associação
	aEval(aItens, {|x| aEval(x[10][2], {|y| If(y[11] > 0, lAtualiza := .T., ) }) })

	If !(lAtualiza .And. MsgYesNo(STR0378, STR0215)) //"Confirma a inclusão das associações de lote informadas?" - "Atenção"
		Break
	EndIf

	For i := 1 To Len(aItens)
		For j := 1 to Len(aItens[i][10][2])
			aLote := aItens[i][10][2][j]
			//Para cada lote, verifica se houve associação com o item atual
			If aLote[11] > 0

				//Atualiza o arquivo de capa dos lotes
				Work_CWV->(DbSetOrder(1))
				//WV_LOTE+WV_FORN+WV_FORLOJ+DTOS(WV_DT_VALI)
				If Work_CWV->(DbSeek(aLote[1]+aItens[i][4]+If(EicLoja(), aItens[i][5], "")+DToS(aLote[12])))
					//Se o lote já existir no arquivo, atualiza somente a quantidade
					Work_CWV->WV_QTDE		+= aLote[11]
				Else
					//Adiciona o lote no arquivo
					Work_CWV->(DbAppend())

					Work_CWV->WV_PGI_NUM	:= aLote[2]
					Work_CWV->WV_LOTE		:= aLote[1]
					Work_CWV->WV_FORN		:= aItens[i][4]
					If EICLoja()
						Work_CWV->WV_FORLOJ		:= aItens[i][5]
					EndIf
					Work_CWV->WV_QTDE		:= aLote[11]
					Work_CWV->WV_DT_VALI	:= aLote[12]
					Work_CWV->WV_INVOICE	:= Work_SW9->W9_INVOICE
					Work_CWV->WV_PO_NUM		:= aLote[3]
					Work_CWV->WV_CC			:= aLote[4]
					Work_CWV->WV_SI_NUM		:= aLote[6]
					Work_CWV->WV_COD_I		:= aLote[7]
					Work_CWV->WV_POSICAO	:= aItens[i][1]
					Work_CWV->WV_REG		:= aLote[8]
					Work_CWV->WV_OBS		:= aLote[13]
                    If lCpoDtFbLt
                       Work_CWV->WV_DFABRI  := aLote[14]
                    EndIf
				EndIf

				//Verifica se o lote já existe no arquivo WORK_SWV (reflexo da base de dados)
				Work_SWV->(DbSetOrder(2))
				//WV_FORN+WV_FORLOJ+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
				If Work_SWV->(DbSeek(aItens[i][4]+If(EicLoja(), aItens[i][5], "")+aLote[2]+aLote[3]+aItens[i][1]+Work_SW9->W9_INVOICE)) .And. Work_SWV->WV_DT_VALI == aLote[12]
					While Work_SWV->(!Eof() .And. WV_FORN+If(EicLoja(), WV_FORLOJ, "")+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE == aItens[i][4]+If(EicLoja(), aItens[i][5], "")+aLote[2]+aLote[3]+aItens[i][1]+Work_SW9->W9_INVOICE)
						If Work_SWV->(WV_LOTE == aLote[1] .And. WV_DT_VALI == aLote[12])
							lExisteLote := .T.
							Exit
						EndIf
						Work_SWV->(DbSkip())
					EndDo
				EndIf

				If lExisteLote
					//Se já existir, atualiza a quantidade
					Work_SWV->WV_QTDE += aLote[11]
				Else
					//Adiciona o lote no arquivo
					Work_SWV->(DbAppend())

					Work_SWV->WV_PGI_NUM	:= aLote[2]
					Work_SWV->WV_LOTE		:= aLote[1]
					Work_SWV->WV_FORN		:= aItens[i][4]
					If EICLoja()
						Work_SWV->WV_FORLOJ		:= aItens[i][5]
					EndIf
					Work_SWV->WV_QTDE		:= aLote[11]
					Work_SWV->WV_DT_VALI	:= aLote[12]
					Work_SWV->WV_INVOICE	:= Work_SW9->W9_INVOICE
					Work_SWV->WV_PO_NUM		:= aLote[3]
					Work_SWV->WV_CC			:= aLote[4]
					Work_SWV->WV_SI_NUM		:= aLote[6]
					Work_SWV->WV_COD_I		:= aLote[7]
					Work_SWV->WV_POSICAO	:= aItens[i][1]
					Work_SWV->WV_REG		:= aLote[8]
					Work_SWV->WV_OBS		:= aLote[13]
                    If lCpoDtFbLt
                       Work_SWV->WV_DFABRI  := aLote[14]
                    EndIf                    
				EndIf
			EndIf
		Next
	Next

End Sequence
lGravaSWV := .T.  // GFP - 06/11/2014
Return Nil

/*
Função    : ValFaseDesp()
Objetivo  : Verificar em qual fase esta a despesa(DI ou DIN)
Retorno   : Logico
Parametro : Nenhum
Autor     : Flavio Danilo Ricardo
Data      : 16/04/2013
*/
Function ValFaseDesp()

Local cFase

IF Type("lIncAux")== "L" .And. lIncAux
   IF SW6->W6_TIPOFEC="DA"
      cFase := "1"
   ELSE
      cFase := "2"
   ENDIF
ELSE
   SWD->(DBGOTO(TRB->RECNO))
   IF SW6->W6_TIPOFEC="DA"
      cFase := "1"
   ELSEIF SW6->W6_TIPOFEC="DIN" .And. SWD->(FieldPos("WD_DA_ORI")) > 0 .And. !Empty(SWD->WD_DA_ORI) .And. SWD->WD_DA_ORI=="1"
      cFase := "1"
   ELSE
      cFase := "2"
   ENDIF
ENDIF
Return cFase


/*
Função    : ValNegativo()
Objetivo  : Verificar as despesas do processo de forma a não permitir
			saldo negativo acumulado no campo Outras Despesas.
Retorno   : Logico
Autor     : Laercio G Souza Junior
Data      : 23/04/2013
*/
Function ValNegativo (lIncluir,ValOutDesp,ValOriDesp,ValAltDesp,nOp)
Local nVlrDigitado := ValAltDesp
Local nVlrOutDesp  := ValOutDesp
Local lRet := .F., lOutrasDesp
Local lDspNegativa := .F. //MCF - 02/09/2014
Private lVNegativo := .T. //LGS - 04/05/2015

If nVlrOutDesp == 0
   lOutrasDesp := .F.
Else
   lOutrasDesp := .T.
EndIf

SWD->(DBSETORDER(1))  //MCF - 02/09/2014
SWD->(DBSEEK(xFILIAL("SWD")+SW6->W6_HAWB))
Do While SWD->(!EOF()) .and. SWD->WD_HAWB == SW6->W6_HAWB
   If SWD->WD_VALOR_R < 0
	  lDspNegativa := .T.
   EndIf
   SWD->(DbSkip())
EndDo

If(EasyEntryPoint("EICDI505"),ExecBlock("EICDI505",.F.,.F.,"VAL_NEGATIVO"),) // LGS-04/05/2015 - P.E. para manipular a varivel "lVNegativo".

If lVNegativo .And. nOp != 4
	If lIncluir
	   If ( nVlrOutDesp + nVlrDigitado) < 0
	   	  MsgInfo(STR0383,STR0185)//O valor negativo digitado é maior que o saldo positivo acumulado no campo Outras Despesas. Inclua uma despesa com valor positivo antes de incluir esta despesa negativa.
	   	  lRet := .T.
	   EndIf
	Else
	   If !lOutrasDesp
	      If (ValOriDesp < 0) .And. (nVlrDigitado < 0)
	   	  	 If (nVlrDigitado *-1) > (ValOriDesp *-1)
	   	     	MsgInfo(STR0384,STR0185)//Processo não possue saldo positivo acumulado no campo Outras Despesas. Inclua uma despesas com valor positivo de forma a ter saldo para poder alterar esta despesa negativa para um valor a maior.
	   	  	  	lRet := .T.
	   	  	 EndIf
	   	  ElseIf (ValOriDesp > 0) .And. (nVlrDigitado < 0)
	      	 MsgInfo(STR0385,STR0185)//Processo não possue saldo positivo acumulado no campo Outras Despesas. Não é permitido alterar um valor positivo para um valor nagativo, inclua uma despesa com valor positivo para ser posivel esta alteração.
	   	  	 lRet := .T.
	   	  ElseIf (ValOriDesp > 0) .And. (nVlrDigitado > 0)
	   	  	 If lDspNegativa
	   	  	 	If ValOriDesp > nVlrDigitado
	   	  	 	   MsgInfo(STR0386,STR0185)//Alteração não permitida, processo contem despesas com valor negativo e o saldo acumulado no campo Outras Despesas esta zero. Altere o valor negativo de forma a ter saldo positivo antes de realizar esta alteracao.
	   	  	 	   lRet := .T.
	   	  	    EndIf
	   	  	 EndIf
	      EndIf
	   Else
	   	  If (nVlrOutDesp + nVlrDigitado) < ValOriDesp
	   	  	 MsgInfo(STR0387,STR0185)//"O valor alterado esta criando um residuo de valor negativo. Corrija o valor antes de confirmar a alteração."
	   		 lRet := .T.
	      EndIf
	   EndIf
	EndIf
//* Na exclusao verifica se a despesa vai criar residuo negativo ou não.
ElseIf nOp == 4 .And. (nVlrDigitado > 0)
   If lOutrasDesp
   	  If nVlrDigitado > nVlrOutDesp
   	  	 MsgInfo(STR0388,STR0185)//"Processo possui despesas negativas e permitir esta exclusão irá gerar residuos de saldo negativo no campo Outras Despesas. Altere ou Exclua o valor das despesas negativas antes de confirmar esta exclusão."
   	  	 lRet := .T.
   	  EndIf
   Else
   	  MsgInfo(STR0388,STR0185)//"Processo possui despesas negativas e permitir esta exclusão irá gerar residuos de saldo negativo no campo Outras Despesas. Altere ou Exclua o valor das despesas negativas antes de confirmar esta exclusão."
   	  lRet := .T.
   EndIf
EndIf

Return lRet

/*
Programa   : DI505ESS()
Objetivo   : Integrar o embarque ao módulo SIGAESS (Easy Siscoserv) para geração do Processo, Invoices e Parcelas referente as despesas
Parâmetros : cHawb - Processo de Embarque, nOpc - Operação a ser realizada
Autor      : Rafael Ramos Capuano
Data       : 20/11/2013 - 14:38
Revisão    : WFS 03/07/2014 - alterada a chamada da função para o programa EICDI505
*/
Function DI505ESS(cHawb,nOpc)
Local aCab          := {}
Local aOrd          := SaveOrd({"SWD","EJW","ELA","SW6"})
Local aItens        := {}
Local cProc         := ""
Local cNBS          := ""
Local cItem         := ""
Local cForn         := ""
Local cDI           := "" //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
Local cLoja         := ""
Local cChave        := ""
Local lExistProc    := .F.
Local lAtuaProc     := .F.
Local lFinan        := EasyGParam("MV_EASYFIN",,"") == "S"
Local nOpcAux       := nOpc
Local nRecSW6       := SW6->(Recno())
Local nRecSWD       := SWD->(Recno())
Local nRecSWB       := SWB->(Recno())
Local nTamChave//RMD - 20/10/14
Local cMsgISis := ""
Local cTipoDespe := ""
Local lErrIntSis := .F.
Default cHawb       := ""
Private lMsErroAuto := .F.
//Quando a chamada vier da rotina de Despesas (DI500Despes()), nOpc será 7, sendo assim, atualiza a variável para poder executar o MsExecAuto do Processo
If nOpc > 5
   nOpcAux := ALTERAR
EndIf
//SW6 - Capa da Declaração de Importação
//SWD - Despesas da Declaração de Importação
//EJW - Capa do Processo de Serviços
//ELA - Invoices de Serviços
Begin Sequence
If Empty(cHawb) .Or. ValType(nOpc) <> "N" .Or. !(SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0)
   Break
EndIf

//RMD - 20/10/14 - Integra dados de Frete e Seguro das Invoices com o SISCOSERV
If EasyGParam("MV_ESS0023",, .F.)
	nTamChave := AvSx3("W6_HAWB", AV_TAMANHO) + AvSx3("W9_INVOICE", AV_TAMANHO) + AvSx3("YB_DESP", AV_TAMANHO) + 2
	If  nTamChave > AvSx3("EJW_PROCES", AV_TAMANHO)
		MsgInfo(StrTran(STR0389, "XXX", AllTrim(Str(nTamChave)));//"Para integrar os valores de frete e seguro com o SISCOSERV o tamanho do campo 'Processo/EJW_PROCESS' deve ser maior ou igual a XXX."
				+ ENTER + STR0390;//"Os pedidos de aquisição criados por esta integração serão identificados por 'PROCESSO\INVOICE\DESPESA'."
				+ENTER + STR0391)//"Para habilitar a integração será necessário configurar o tamanho do campo (grupo)."
	Else
		Processa({|| INVSISIntegra(cHAWB) }, STR0392)//"Integrando dados de frete e seguro das Invoices com o SISCOSERV"
	EndIf
EndIf

EJW->(DbSetOrder(1)) //EJW_FILIAL+EJW_TPPROC+EJW_PROCES
SWD->(DbSetOrder(1)) //WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)
ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
//RRC - 21/11/2013 - Verifica se existe algum processo de serviços cuja despesa já foi excluída do embarque
//A chave do Processo é composta pelo Processo do Embarque (cHawb) mais o caractere "/" e o código da despesa, logo verifica todos os processos que podem ter sido
//gerados por esse embarque, por isso o uso do AllTrim()
If EJW->(DbSeek(xFilial("EJW")+"A"+AllTrim(cHawb))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEIC"
   Do While EJW->(!Eof()) .And. EJW->EJW_FILIAL == xFilial("EJW") .And. EJW->EJW_TPPROC == "A" .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEIC" .And. AllTrim(cHawb) == SubStr(EJW->EJW_PROCES,1,Len(AllTrim(cHawb)))
      //RMD - 20/10/14 - Verifica se não é um processo criado a partir de uma Invoice antes de excluir.
      //If At("/", SubStr(EJW->EJW_PROCES, Len(AllTrim(cHAWB))+1)) == 0 //RMD - 31/08/17 - Se for invoice o código possui duas barras, e não somente uma
      If At("/", SubStr(EJW->EJW_PROCES, Len(AllTrim(cHAWB))+2)) == 0
	      If !SWD->(DbSeek(xFilial("SWD")+AvKey(cHawb,"WD_HAWB")+SubStr(EJW->EJW_PROCES,Len(AllTrim(cHawb))+2,AvSx3("WD_DESPESA",AV_TAMANHO))))
	         cForn   := ""
	         cLoja   := ""
	         aCab    := MontaCapa(EXCLUIR,EJW->EJW_PROCES)
	         aItens  := MontaItens(EXCLUIR,EJW->EJW_PROCES)
             aDocs   := MontaDocs(EXCLUIR,EJW->EJW_PROCES) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
	         /*Campos do fornecedor e loja fazem parte da chave das tabelas ELA e ELB da invoice no SIGAESS, por isso, caso o usuário faça essa alteração no Embarque, passa
	         o conteúdo antigo para poder buscar a invoice corretamente. Posteriormente, na chamada do MsExecAuto do EICPS400, haverá a atualização do fornecedor e loja
	         tanto no Processo como na invoice e nas demais tabelas envolvidas dentro da função GravCamp()*/
	         cChave := xFilial("ELA")+"A"+AvKey(EJW->EJW_PROCES,"ELA_PROCES")+AvKey(EJW->EJW_PROCES,"ELA_NRINVO")
	         If ELA->(DbSeek(cChave))
	            //Busca a invoice originada do embarque
	            Do While !ELA->(Eof()) .And. ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) <> "SIGAEIC"
	               ELA->(DbSkip())
	            EndDo
	            If ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) == "SIGAEIC"
	               cForn := ELA->ELA_EXPORT
	               cLoja := ELA->ELA_LOJEXP
	            EndIf
	         EndIf
	         If DIGerParc(EXCLUIR,EJW->EJW_PROCES,cForn,cLoja,lFinan) .And. DIGerInv(EXCLUIR,EJW->EJW_PROCES,cForn,cLoja)
	            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,EXCLUIR)
	         EndIf
	      EndIf
	  EndIf
      EJW->(DbSkip())
   EndDo
EndIf

//Busca as despesas para integração com o SIGAESS
If SWD->(DbSeek(xFilial("SWD")+AvKey(cHawb,"WD_HAWB")))
   SW6->(DbSetOrder(1)) //W6_FILIAL+W6_HAWB
   If !SW6->(DbSeek(xFilial("SW6")+cHawb)) .Or. Empty(SW6->W6_DT_EMB)
      nOpcAux := EXCLUIR
   EndIf
   cMsgISis += STR0394 + CHR(10) + CHR(13) //Mensagem de erro caso esteja faltando alguma informação para a integração com o ESS //"A Integração com o SIGAESS não será realizada. Para que ela ocorra, preencha as seguintes informações:"
   Do While SWD->(!Eof()) .And. SWD->(WD_FILIAL+WD_HAWB) == xFilial("SWD")+AvKey(cHawb,"WD_HAWB")
      aCab    := {}
      aItens  := {}
      aDocs := {} //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
      cItem := ""
      cNBS  := ""
      cForn := ""
      cLoja := ""
      //RMD - 10/02/15 - Considera o produto já informado no SWD
      If SWD->(FieldPos("WD_PRDSIS")) > 0 .And. !Empty(SWD->WD_PRDSIS)
      	cItem := SWD->WD_PRDSIS
      Else
		//Verifica se existe produto para o frete informado na Via de Transporte, caso contrário considera o informado na despesa
		If SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(SW6->W6_VIA_TRA) .And. SYQ->(DbSeek(xFilial()+SW6->W6_VIA_TRA)) .And. !Empty(SYQ->YQ_PRDSIS)
			cItem := SYQ->YQ_PRDSIS
		Else
	      SYB->(DbSetOrder(1)) //YB_FILIAL+YB_DESP
	      SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
	      If SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA))
	         cItem := SYB->YB_PRODUTO
	      EndIf
		EndIf
	  EndIf
      If !Empty(cItem) .And. SB5->(DbSeek(xFilial("SB5")+cItem))
         cNBS := SB5->B5_NBS
      EndIf

      If !Empty(SW6->W6_DI_NUM) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
         cDI := SW6->W6_DI_NUM
      EndIf

      cProc := AllTrim(cHawb)+"/"+SWD->WD_DESPESA
      lExistProc := EJW->(DbSeek(xFilial("EJW")+"A"+AvKey(cProc,"EJW_PROCES"))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEIC"
      lAltProc   := (nOpcAux == ALTERAR .And. !((Empty(SWD->WD_VL_MOE) .Or. Empty(cNBS) .Or. Empty(SWD->WD_FORN) .Or. Empty(SWD->WD_LOJA) .Or. Empty(SWD->WD_TX_MOE)) .OR. IsInCallStack("FINA340") .And. !lExistProc))

      If (nOpcAux == INCLUIR .And. !Empty(SW6->W6_DT_EMB) .And. !Empty(SWD->WD_VL_MOE) .And. !Empty(cNBS) .And. !Empty(SWD->WD_FORN) .And. !Empty(SWD->WD_LOJA) .And. !Empty(SWD->WD_TX_MOE)) .Or. lAltProc .Or. (nOpcAux == EXCLUIR .And. lExistProc)
         /*Campos do fornecedor e loja fazem parte da chave únicas das tabelas ELA e ELB da invoice no SIGAESS, por isso, caso o usuário faça essa alteração no Embarque, passa
         o conteúdo antigo para poder buscar a invoice corretamente. Posteriormente, na chamada do MsExecAuto do EICPS400, haverá a atualização do fornecedor e loja
         tanto no Processo como na invoice e nas demais tabelas envolvidas*/
         cChave := xFilial("ELA")+"A"+AvKey(cProc,"ELA_PROCES")+AvKey(cProc,"ELA_NRINVO")
         If ELA->(DbSeek(cChave))
            //Busca a invoice originada do embarque
            Do While !ELA->(Eof()) .And. ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) <> "SIGAEIC"
               ELA->(DbSkip())
            EndDo
            If ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) == "SIGAEIC"
               cForn := ELA->ELA_EXPORT
               cLoja := ELA->ELA_LOJEXP
            EndIf
         EndIf

         //Caso esteja alterando o embarque retirando o valor da despesa e o processo equivalente já tiver sido cadastrado no SIGAESS, será realizada a exclusão do mesmo
         //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
         //Verifica campos obrigatórios para o Processo no SIGAESS
         If nOpcAux == ALTERAR .And. (Empty(SWD->WD_VL_MOE) .Or. Empty(cNBS) .Or. Empty(SWD->WD_FORN) .Or. Empty(SWD->WD_LOJA) .Or. Empty(SWD->WD_TX_MOE))
            nOpcAux := EXCLUIR
         EndIf
         aCab    := MontaCapa(nOpcAux,cProc)
         aItens  := MontaItens(nOpcAux,cProc,cItem,cNBS)
         If !Empty(cDI)
            aDocs   := MontaDocs(nOpcAux,cProc,cNBS,cDI) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
         EndIf
         If nOpcAux <> EXCLUIR .And. !(nOpcAux == ALTERAR .And. lExistProc)
            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
            If !lMsErroAuto
               If DIGerInv(nOpcAux,cProc,cForn,cLoja)
                  //LRS - 14/07/2017 - Pocisiona novamente na ELA para criar a Parcela na EEQ
                  If ELA->(DbSeek(cChave))
                     Do While !ELA->(Eof()) .And. ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) <> "SIGAEIC"
                        ELA->(DbSkip())
                     EndDo
                  EndIF 
                  DIGerParc(nOpcAux,cProc,cForn,cLoja,GerCambFin(lFinan,SWD->WD_DESPESA,SWD->WD_NUMERA))
               EndIf
            EndIf
            //Caso seja uma exclusão ou alteração de um processo já existente no SIGAESS deve atualizar a invoice primeiro.
            //É importante alterar a invoice primeiro porque o valor da despesa pode ser menor do que o atual, no SIGAESS, não pode alterar o valor do processo
            //caso na invoice o mesmo seja maior
         ElseIf nOpcAux == EXCLUIR .And. DIGerParc(nOpcAux,cProc,cForn,cLoja,GerCambFin(lFinan,SWD->WD_DESPESA,SWD->WD_NUMERA)) .And. DIGerInv(nOpcAux,cProc,cForn,cLoja)
            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpcAux)
         ElseIf nOpcAux <> EXCLUIR .And. DIGerInv(nOpcAux,cProc,cForn,cLoja) .And. DIGerParc(nOpcAux,cProc,cForn,cLoja,GerCambFin(lFinan,SWD->WD_DESPESA,SWD->WD_NUMERA))
            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
         EndIf
      Else
         
         If(SWD->WD_DESPESA == "102" .Or. SWD->WD_DESPESA == "103") /*.And. !Empty(SWD->WD_FORN)*/ .And. nModulo == 17//RMD - 31/08/17 - Verifica se o fornecedor foi informado e se o módulo é o EIC (esta função pode ser chamada do financeiro)
            Iif(SWD->WD_DESPESA == "102", cTipoDespe := "Frete",)
            Iif(SWD->WD_DESPESA == "103", cTipoDespe := "Seguro",)
         
            If lErrIntSis == .F.
               Iif(Empty(SW6->W6_DT_EMB), cMsgISis += "Data Embarque" + CHR(10) + CHR(13),)
            EndIf
            
            Iif(Empty(SWD->WD_VL_MOE), cMsgISis += "Valor Moeda (" +cTipoDespe +")" + CHR(10) + CHR(13),)
            Iif(Empty(cNBS), cMsgISis += "NBS" + CHR(10) + CHR(13),)
            Iif(Empty(SWD->WD_FORN), cMsgISis += "Fornecedor (" +cTipoDespe +")" + CHR(10) + CHR(13),)
            Iif(Empty(SWD->WD_LOJA), cMsgISis += "Loja (" +cTipoDespe +")" + CHR(10) + CHR(13),)
            Iif(Empty(SWD->WD_TX_MOE), cMsgISis += "Taxa Moeda (" +cTipoDespe +")" + CHR(10) + CHR(13),)
         
            lErrIntSis := .T.
         EndIf
      EndIf
      SWD->(DbSkip())
   EndDo
//Else //RMD - 31/08/17 - Não exibe mensagem se for exclusão
ElseIf nOpc <> EXCLUIR
cMsgISis += STR0395 + CHR(10) + CHR(13) //"As despesas de frete e/ou seguro não foram encontradas para realizar a integração com o SIGAESS. Verifique as informações de moeda, valor e taxa."
lErrIntSis := .T.
EndIf
If lErrIntSis
      EECVIEW(cMsgISis)
EndIf
End Sequence
SW6->(DbGoTo(nRecSW6))
SWD->(DbGoTo(nRecSWD))
SWB->(DbGoTo(nRecSWB))
RestOrd(aOrd,.T.)

Return Nil

/*
Programa   : MontaCapa()
Objetivo   : Montar dados da capa do embarque para integração com o módulo SIGAESS (Easy Siscoserv)
Parâmetros : nOpcAux - Tipo de Operação, cProc - Chave do Processo
Autor      : Rafael Ramos Capuano
Data       : 20/11/2013 - 14:24:00
*/

Static Function MontaCapa(nOpcAux,cProc)
Local cCnpjImp := "" //MCF - 15/01/2016
Private aCabAux   := {}

cCnpjImp := Posicione("SYT", 1, xFilial("SYT")+SW6->W6_IMPORT, "YT_CGC") //MCF - 15/01/2016

aAdd(aCabAux,{'EJW_FILIAL',xFilial("EJW")                             ,NIL})
aAdd(aCabAux,{'EJW_PROCES',AvKey(cProc,"EJW_PROCES")                  ,NIL})
aAdd(aCabAux,{'EJW_TPPROC',"A"                                        ,NIL})
aAdd(aCabAux,{'EJW_ORIGEM',"SIGAEIC"                                  ,NIL})
//Se for uma exclusão, não é necessário passar todos os campos da tabela
If nOpcAux <> EXCLUIR

   //RMD - 15/09/14 - Tratamento para quando o Fornecedor Internacional do Frete é diferente do fornecedor que recebe o título.
   If SWD->WD_DESPESA <> "102" .Or. SW6->(FieldPos("W6_FFREINT")) == 0 .Or. SW6->(FieldPos("W6_FFRELOJ")) == 0
      aAdd(aCabAux,{'EJW_EXPORT',SWD->WD_FORN                    ,NIL})
      aAdd(aCabAux,{'EJW_LOJEXP',SWD->WD_LOJA                    ,NIL})
   Else
      If Empty(SW6->W6_FFREINT) .Or. Empty(SW6->W6_FFRELOJ)
         If SW6->(RecLock("SW6", .F.))
            SW6->W6_FFREINT := SWD->WD_FORN
            SW6->W6_FFRELOJ := SWD->WD_LOJA
            SW6->(MsUnlock())
         EndIf
      EndIf
      aAdd(aCabAux,{'EJW_EXPORT',SW6->W6_FFREINT                  ,NIL})
      aAdd(aCabAux,{'EJW_LOJEXP',SW6->W6_FFRELOJ                  ,NIL})
   EndIf

   //RMD - 31/08/17 - Na prestação de contas a moeda do SWD muda para reais, neste caso o pedido deve acompanhar a moeda da capa.
   Do Case
      Case SWD->WD_DESPESA == "102" //Frete
         aAdd(aCabAux,{'EJW_MOEDA' ,SW6->W6_FREMOED                   ,NIL})
      Case SWD->WD_DESPESA == "103" //Seguro
         aAdd(aCabAux,{'EJW_MOEDA' ,SW6->W6_SEGMOED                   ,NIL})
      Otherwise //Demais despesas
         aAdd(aCabAux,{'EJW_MOEDA' ,SWD->WD_MOEDA                   ,NIL})
   EndCase
   
   If EasyGParam("MV_ESS0021",,.F.) .And. EasyGParam("MV_ESS0025",,.F.) .And. EJW->(FieldPos("EJW_CGC")) > 0 //MCF - 15/01/2016
	   aAdd(aCabAux,{'EJW_CGC',cCnpjImp,NIL})
	Endif
   //aAdd(aCabAux,{'EJW_DTPROC',                                  ,NIL})
   //aAdd(aCabAux,{'EJW_COMP' ,                                          ,NIL})
EndIf

	If EasyEntryPoint("EICDI500")
	   ExecBlock("EICDI500",.F.,.F.,"INTSIS_MONTACAPA_PAS")
	EndIf

Return aCabAux

/*
Programa   : MontaItens()
Objetivo   : Montar dados dos itens do embarque para integração com o módulo SIGAESS (Easy Siscoserv)
Parâmetros : nOpcAux - Tipo de Operação, cProc - Chave do Processo
             cItem - Serviço vinculado a Despesa, cNBS - NBS a ser utilizada
Autor      : Rafael Ramos Capuano
Data       : 20/11/2013 - 14:24
*/
Static Function MontaItens(nOpcAux, cProc, cItem, cNBS)
Local aItens    := {}
//Local aItensAux := {}
Local aOrd      := SaveOrd({"SA2"})
Local nMV0029 := EasyGParam("MV_ESS0029",,2)//LRS -15/07/2017
Local cPaisBR := "105" //LRS - 15/07/2017
Private aItensInt := {} //MCF - 16/01/2017
Default cItem   := ""
Default cNBS    := ""
SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
aAdd(aItensInt,{'EJX_FILIAL',xFilial("EJX")                                   ,NIL})
aAdd(aItensInt,{'EJX_SEQPRC',StrZero(1,AvSx3("EJX_SEQPRC",AV_TAMANHO))        ,NIL})
aAdd(aItensInt,{'EJX_PROCES',AvKey(cProc,"EJX_PROCES")                        ,NIL})
aAdd(aItensInt,{'EJX_TPPROC',"A"                                              ,NIL})
//Se for uma exclusão, não é necessário passar todos os campos da tabela
If nOpcAux <> EXCLUIR
   aAdd(aItensInt,{'EJX_ITEM'  ,cItem                                         ,NIL})
   aAdd(aItensInt,{'EJX_MODAQU',"1"                                           ,NIL})
   //LRS - 15/07/2017 - Tratamento para o pais, de acordo com o parametro MV_ESS0029
   IF nMV0029 == 1
      aAdd(aItensInt,{'EJX_PAIS'  ,AvKey(SW6->W6_PAISPRO,"EJX_PAIS")                ,NIL})
   Elseif nMV0029 == 3
      aAdd(aItensInt,{'EJX_PAIS'  ,AvKey(cPaisBR,"EJX_PAIS")                ,NIL})
   Else
     IF !Empty(SW6->W6_FFREINT) .AND. !Empty(SW6->W6_FFRELOJ) //LRS - 18/10/2016
        aAdd(aItensInt,{'EJX_PAIS'  ,If(SA2->(DbSeek(xFilial("SA2")+AvKey(SW6->W6_FFREINT,"A2_COD")+AvKey(SW6->W6_FFRELOJ,"A2_LOJA"))),SA2->A2_PAIS,""),NIL}) //País do fornecedor
     Else
        aAdd(aItensInt,{'EJX_PAIS'  ,If(SA2->(DbSeek(xFilial("SA2")+AvKey(SWD->WD_FORN,"A2_COD")+AvKey(SWD->WD_LOJA,"A2_LOJA"))),SA2->A2_PAIS,""),NIL}) //País do fornecedor
     EndIF
   EndiF

   aAdd(aItensInt,{'EJX_NBS'   ,cNBS                                          ,NIL})
   aAdd(aItensInt,{'EJX_DTINI' ,SWD->WD_DES_ADI                               ,NIL})
   //aAdd(aItensAux,{'EJX_DTINI' ,SW6->W6_DT_EMB                              ,NIL})
   //aAdd(aItensAux,{'EJX_DTFIM' ,SW6->W6_CHEG                                ,NIL})
   aAdd(aItensInt,{'EJX_QTDE'  ,1                                             ,NIL})
   
   //RMD - 31/08/17 - Na prestação de contas a moeda do SWD muda para reais, neste caso o pedido deve acompanhar os dados da capa.
   Do Case
      Case SWD->WD_DESPESA == "102" //Frete        
         aAdd(aItensInt,{'EJX_PRCUN' ,SW6->(SW6->W6_VLFRECC-W6_VLFRETN) ,NIL}) //removido fretepp da composição do valor - DTRADE3010                    
         aAdd(aItensInt,{'EJX_TX_MOE',SW6->W6_TX_FRET                   ,NIL}) 
      Case SWD->WD_DESPESA == "103" //Seguro
         aAdd(aItensInt,{'EJX_PRCUN' ,SW6->W6_VL_USSE                  ,NIL})
         aAdd(aItensInt,{'EJX_TX_MOE',SW6->W6_TX_SEG                   ,NIL})
      Otherwise
         aAdd(aItensInt,{'EJX_PRCUN' ,SWD->WD_VL_MOE                   ,NIL})
         aAdd(aItensInt,{'EJX_TX_MOE',SWD->WD_TX_MOE                   ,NIL})
   EndCase

EndIf

If EasyEntryPoint("EICDI505")
   ExecBlock("EICDI505",.F.,.F.,"INTSIS_MONTAITENS_PAS")
EndIf
	
aAdd(aItens,aClone(aItensInt))

RestOrd(aOrd,.T.)
Return aItens

Static Function MontaDocs(nOpcAux, cProc, cNBS, cDI) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
Local aDocs    := {}
Local aDocsAux := {}
aAdd(aDocsAux,{'EL2_FILIAL',xFilial("EL2"),NIL})
aAdd(aDocsAux,{'EL2_PROCES',AvKey(cProc,"EL2_PROCES"),NIL})
aAdd(aDocsAux,{'EL2_TPPROC',"A",NIL})
aAdd(aDocsAux,{'EL2_SEQDOC',StrZero(1,AvSx3("EL2_SEQDOC",AV_TAMANHO))  ,NIL})
If nOpcAux <> EXCLUIR
   aAdd(aDocsAux,{'EL2_DI'    ,cDI,NIL})
   If EasyGParam("MV_ESS0027",,9) >= 10
      aAdd(aDocsAux,{'EL2_SEQPRC',StrZero(1,AvSx3("EL2_SEQPRC",AV_TAMANHO))  ,NIL})
   EndIf
   aAdd(aDocsAux,{'EL2_STTSIS',"1"  ,NIL})
EndIf
aAdd(aDocs,aClone(aDocsAux))

Return aDocs

/*
Programa   : DIGerInv()
Objetivo   : Gerar a invoice para integração entre SIGAEIC x SIGAESS
Parâmetros : nOpcAux - Operação a ser realizada, cProc - Chave do Processo, cForn - Fornecedor da despesa, cLoja - Loja do fornecedor da despesa
Autor      : Rafael Ramos Capuano
Data       : 20/11/2013 - 16:57
*/
Static Function DIGerInv(nOpcAux, cProc, cForn, cLoja)
Local aCab          := {}
Local aItens        := {}
Local aItensAux     := {}
Local aOrd          := SaveOrd({"ELA"})
Local nPos          := 0
Local nI            := 0
Local cChave        := ""
Local cMsgErro      := ""
Default cForn       := ""
Default cLoja       := ""
Private lMsErroAuto := .F.

Begin Sequence

//RMD - 31/08/17 - Sempre busca a Invoice
/*
If nOpcAux == EXCLUIR
   ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
   If !ELA->(DbSeek(xFilial("ELA")+"A"+AvKey(cProc,"ELA_PROCES")+AvKey(cProc,"ELA_NRINVO")))
      Break
   EndIf
EndIf
*/
ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
ELA->(DbSeek(xFilial("ELA")+"A"+AvKey(cProc,"ELA_PROCES")+AvKey(cProc,"ELA_NRINVO")))

If ELA->(Found())
    //RMD - 31/08/17 - Na prestação de contas a moeda do SWD é alterada para reais, se a invoice estiver em outra moeda exclui e inclui novamente.
	If (nOpcAux <> EXCLUIR) .And. AllTrim(SWD->WD_DESPESA) $ "102/103" .And. SWD->WD_MOEDA <> ELA->ELA_MOEDA 
	   If !DIGerInv(EXCLUIR,cProc,cForn,cLoja)
	      lMsErroAuto := .T.
	      Break
	   Else
	      nOpcAux := INCLUIR
	   EndIf
	EndIf
Else
	If nOpcAux == EXCLUIR 
	   Break
	EndIf
EndIf


//Capa do Invoice
aAdd(aCab,{'ELA_FILIAL',xFilial("ELA")                             ,NIL})
aAdd(aCab,{'ELA_NRINVO',AvKey(cProc,"ELA_NRINVO")                  ,NIL})
aAdd(aCab,{'ELA_PROCES',AvKey(cProc,"ELA_PROCES")                  ,NIL})
aAdd(aCab,{'ELA_TPPROC',"A"                                        ,NIL})
/*Fornecedor e loja podem ser alterados no processo e fazem parte da chave única da Invoice, por isso, primeiramente buscará pela chave antiga e depois com a atualização
do Processo na chamada do EICPS400(), na função GravCamp(), ocorrerá a atualização destas informações em todas as tabelas envolvidas, como a de parcela de câmbio*/
aAdd(aCab,{'ELA_EXPORT',AvKey(If(!Empty(cForn),cForn, SWD->WD_FORN),"ELA_EXPORT")   ,NIL})
aAdd(aCab,{'ELA_LOJEXP',AvKey(If(!Empty(cLoja),cLoja, SWD->WD_LOJA),"ELA_LOJEXP")  ,NIL})
aAdd(aCab,{'ELA_ORIGEM',"SIGAEIC"                                  ,NIL})
aAdd(aCab,{'ELA_INT'   ,"S"                                        ,NIL})
//Se for uma exclusão, não é necessário passar todos os campos da tabela
If nOpcAux <> EXCLUIR
   aAdd(aCab,{'ELA_MOEDA' ,SWD->WD_MOEDA                       ,NIL})
   aAdd(aCab,{'ELA_DTEMIS',SWD->WD_DES_ADI                     ,NIL})
   aAdd(aCab,{'ELA_TX_MOE',SWD->WD_TX_MOE                      ,NIL})
EndIf
//Item da Invoice
aAdd(aItensAux,{'ELB_SEQPRC',StrZero(1,AvSx3("ELB_SEQPRC",AV_TAMANHO)) ,NIL})
aAdd(aItensAux,{'ELB_VLCAMB',SWD->WD_VL_MOE                    ,NIL})
aAdd(aItensAux,{'ELB_VLEXT' ,0                                         ,NIL})

aAdd(aItens,aClone(aItensAux))
//Último parâmetro possui conteúdo .F. para indicar que os títulos foram gerados inicialmente no SIGAFIN
MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,"A",aCab,aItens,nOpcAux,.F.)})

End Sequence
RestOrd(aOrd,.T.)
Return !lMsErroAuto

/*
Programa   : DIGerParc()
Objetivo   : Gerar as parcelas de câmbio para integração entre SIGAEIC x SIGAESS para cada SWD (Despesa)
Parâmetros : nOpcAux - Operação a ser realizada, cProc - Chave do Processo. cForn - Fornecedor da despesa, cLoja - Loja do fornecedor da despesa, lFinan - Verificar se
             a origem da geração dos títulos será pelo SIGAFIN
Autor      : Rafael Ramos Capuano
Data       : 25/11/2013 - 11:10
*/
Static Function DIGerParc(nOpcAux,cProc,cForn,cLoja,lFinan)
Local   aCab         := {}
Local   aOrd         := SaveOrd({"SWB","EEQ","SE2","SE5"})
Local   lExisteParc  := .F.
Local   lExisteCamb  := .F.
Local   lMovBanc     := .F.
Local   lCont        := .T.
Local   nRecSE2      := SE2->(Recno())
Local   nRecSE5      := SE5->(Recno())
Local   nPosModal    := 0
Default cForn        := ""
Default cLoja        := ""
Default cProc        := ""
Private lMsErroAuto  := .F.
Private cPed         := cProc
Private cFieldMv       := EasyGParam("MV_ESS0011",,"")
Private cFieldCont := ""

Begin Sequence

    // EJA - 15/02/2018
    If !Empty(cFieldMv)
        // Se o campo cFieldMv não existir no dicionário, mostra a mensagem de erro.
        If !AVSX3(cFieldMv, 0, "", .T.)
            EasyHelp(STR0396)
            Break
        Else
            cFieldCont := &(AVSX3(cFieldMv, 17) + "->" + cFieldMv)
        EndIf
    EndIf

   //Primeiro realiza atualização para cenário em que existe câmbio no SIGAESS, mas não existe no SIGAEIC ou no SIGAFIN, além de efetuar a exclusão
   If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
      EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC
      lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A"+cProc,"EEQ_PREEMB")))
      cCond := 'EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB) == xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A"+cProc,"EEQ_PREEMB")'
   Else
      EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
      lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey("A","EEQ_TPPROC")+AvKey(cPed,"EEQ_PROCES")+AvKey(cPed,"EEQ_NRINVO")))  // GFP - 26/05/2015
      cCond := 'EEQ->(EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES+EEQ_NRINVO) == xFilial("EEQ")+AvKey("A","EEQ_TPPROC")+AvKey(cPed,"EEQ_PROCES")+AvKey(cPed,"EEQ_NRINVO")'
   EndIf
   Do While !EEQ->(Eof()) .And. &cCond
      aCab := {}
      //Verifica se o item do câmbio corresponde a despesa que entrará como serviço para o SIGAESS
      If lFinan
         SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         lExisteCamb := SE2->(DbSeek(xFilial("SE2")+AvKey(SWD->WD_PREFIXO,"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM,"E2_NUM")+RetAsc(EEQ->EEQ_PARC,AVSX3("E2_PARCELA",AV_TAMANHO),.T.)+;
         AvKey(SWD->WD_TIPO,"E2_TIPO")+AvKey(EEQ->EEQ_FORN,"E2_FORNECE")+AvKey(EEQ->EEQ_FOLOJA,"E2_LOJA")))
      Else
         SWB->(DbSetOrder(7)) //WB_FILIAL+WB_HAWB+WB_EVENT+WB_PARCELA
         lExisteCamb := SWB->(DbSeek(xFilial("SWB")+AvKey(SWD->WD_HAWB,"WB_HAWB")+AvKey(SWD->WD_DESPESA,"WB_EVENT")+RetAsc(EEQ->EEQ_PARC,AVSX3("WB_PARCELA",AV_TAMANHO),.T.)))
      EndIf
      //Caso seja exclusão, só passará os campos da chave única e o EEQ_PROCES para identificar que é chamada do SIGAESS
      If !lExisteCamb .Or. nOpcAux == EXCLUIR
         aAdd(aCab,{'EEQ_FILIAL',xFilial("EEQ")   ,NIL})
         aAdd(aCab,{'EEQ_TPPROC',"A"              ,NIL})
         aAdd(aCab,{'EEQ_PREEMB',AvKey("A"+cProc,"EEQ_PREEMB")        ,NIL})
         aAdd(aCab,{'EEQ_NRINVO',AvKey(cProc,"EEQ_NRINVO")            ,NIL})
         aAdd(aCab,{'EEQ_PARC'  ,EEQ->EEQ_PARC    ,NIL})
         aAdd(aCab,{'EEQ_PROCES',AvKey(cProc,"EEQ_PROCES")            ,NIL})
         aAdd(aCab,{'EEQ_FASE'  ,"4"              ,NIL})
         //Verifica caso em que a parcela deve ser excluída do SIGAESS porém o título está baixado, necessário fazer o estorno primeiro
         If !Empty(EEQ->EEQ_PGT) .Or. !Empty(EEQ->EEQ_DTCE) //THTS - 02/01/2018 - Adicionada validacao para verificar se houve baixa no exterior
            aAdd(aCab,{'EEQ_PGT'   ,CToD("  /  /  ") ,NIL})
            aAdd(aCab,{'EEQ_DTCE'  ,CToD("  /  /  ") ,NIL})

            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,ALTERAR,"A",.F.)
         EndIf
         If !lMsErroAuto
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,EXCLUIR,"A",.F.)
            If lMsErroAuto
               lCont := .F.
            EndIf
         Else
            lCont := .F.
         EndIf
      EndIf
      EEQ->(DbSkip())
   EndDo

   If nOpcAux <> EXCLUIR .And. lCont
      //Inicialmente verifica se existe algum câmbio para este processo
      If lFinan
         SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         SE2->(DbSeek(xFilial("SE2")+AvKey(SWD->WD_PREFIXO,"E2_PREFIXO")+AvKey(SWD->WD_CTRFIN1,"E2_NUM")))
      Else
         SWB->(DbSetOrder(7)) //WB_FILIAL+WB_HAWB+WB_EVENT
         SWB->(DbSeek(xFilial("SWB")+AvKey(SWD->WD_HAWB,"WB_HAWB")+AvKey(SWD->WD_DESPESA,"WB_EVENT")))
      EndIf
      Do While lCont
         aCab := {}
         //Verifica se o item do câmbio corresponde a despesa que entrará como Processo para o SIGAESS
         If lFinan
            SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
            If (lExisteCamb := SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO) == xFilial("SE2")+AvKey(SWD->WD_PREFIXO,"E2_PREFIXO"))
               lExisteCamb := SE2->E2_NUM == AvKey(SWD->WD_CTRFIN1,"E2_NUM") .Or. SE2->E2_NUM == AvKey(SWD->WD_CTRFIN2,"E2_NUM") .Or. SE2->E2_NUM == AvKey(SWD->WD_CTRFIN3,"E2_NUM")
               If lExisteCamb .And. !(SE2->E2_TIPO == /*MVNOTAFIS - RMD - 31/08/17 - Deve comparar com o SWD*/ SWD->WD_TIPO .And. SE2->E2_FORNECE == AvKey(SWD->WD_FORN,"E2_FORNECE") .And. SE2->E2_LOJA == AvKey(SWD->WD_LOJA,"E2_LOJA"))
                  SE2->(DbSkip())
                  Loop
               EndIf
            EndIf
         Else
            SWB->(DbSetOrder(7)) //WB_FILIAL+WB_HAWB+WB_EVENT+WB_PARCELA
            lExisteCamb := SWB->(!Eof()) .And. SWB->(WB_FILIAL+WB_HAWB+WB_EVENT) == xFilial("SWB")+AvKey(SWD->WD_HAWB,"WB_HAWB")+AvKey(SWD->WD_DESPESA,"WB_EVENT")
         EndIf
         If !lExisteCamb
            lCont := .F.
            Loop
         EndIf
         If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
            EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC
            lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A"+cProc,"EEQ_PREEMB")+RetAsc(If(!lFinan,SWB->WB_PARCELA,SE2->E2_PARCELA),AVSX3("EEQ_PARC",AV_TAMANHO),.F.)))
         Else
            EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  //
            lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey("A","EEQ_TPPROC")+AvKey(cProc,"EEQ_PROCES")+AvKey(cProc,"EEQ_NRINVO")+RetAsc(If(!lFinan,SWB->WB_PARCELA,SE2->E2_PARCELA),AVSX3("EEQ_PARC",AV_TAMANHO),.F.)))  // GFP - 26/05/2015
         EndIf
         aAdd(aCab,{'EEQ_FILIAL',xFilial("EEQ")   ,NIL})
         aAdd(aCab,{'EEQ_PREEMB',AvKey("A"+cProc,"EEQ_PREEMB")        ,NIL})
         aAdd(aCab,{'EEQ_NRINVO',AvKey(cProc,"EEQ_NRINVO")            ,NIL})
         aAdd(aCab,{'EEQ_PARC'  ,RetAsc(If(!lFinan,SWB->WB_PARCELA,SE2->E2_PARCELA),AVSX3("EEQ_PARC",AV_TAMANHO),.F.)  ,NIL})
         aAdd(aCab,{'EEQ_PARVIN',RetAsc(If(!lFinan,SWB->WB_PARCELA,SE2->E2_PARCELA),AVSX3("EEQ_PARC",AV_TAMANHO),.F.)  ,NIL})
         aAdd(aCab,{'EEQ_PROCES',AvKey(cProc,"EEQ_PROCES")            ,NIL})
         aAdd(aCab,{'EEQ_FASE'  ,"4"              ,NIL})
         aAdd(aCab,{'EEQ_EVENT' ,"001"            ,NIL})
         //aAdd(aCab,{'EEQ_MOEDA' ,/*If(!lFinan,*/SWB->WB_MOEDA/*,SE2->E2_MOEDA)*/  ,NIL}) 
         aAdd(aCab,{'EEQ_MOEDA' ,If(!lFinan,SWB->WB_MOEDA,SWD->WD_MOEDA)     ,NIL})//RMD - 31/08/17 - Mandar a moeda do SWD
         aAdd(aCab,{'EEQ_VCT'   ,If(!lFinan,SWB->WB_DT_VEN,SE2->E2_VENCTO)   ,NIL})
         aAdd(aCab,{'EEQ_PARI'  ,1                ,NIL})
         aAdd(aCab,{'EEQ_VL'    ,If(!lFinan,SWB->WB_FOBMOE,SE2->E2_VALOR)   ,NIL})
         aAdd(aCab,{'EEQ_VLSISC',If(!lFinan,SWB->WB_FOBMOE,SE2->E2_VALOR)   ,NIL})
         aAdd(aCab,{'EEQ_DECAM' ,"2"              ,NIL})
         aAdd(aCab,{'EEQ_TIPO'  ,"A"              ,NIL})
         /*Fornecedor e loja podem ser alterados no processo, porém, primeiramente buscará pela chave antiga e depois com a atualização do Processo na chamada do EICPS400(), ocorrerá
         a atualização destas informações em todas as tabelas envolvidas, como a de parcela de câmbio*/
         aAdd(aCab,{'EEQ_FORN'  ,If(!Empty(cForn),cForn,SWD->WD_FORN),NIL})
         aAdd(aCab,{'EEQ_FOLOJA',If(!Empty(cLoja),cLoja,SWD->WD_LOJA),NIL})
         aAdd(aCab,{'EEQ_TPPROC',"A"              ,NIL})
         aAdd(aCab,{'EEQ_SOURCE',If(!lFinan,"SIGAEIC","SIGAFIN")     ,NIL})
         aAdd(aCab,{'EEQ_MODAL' ,"1"              ,NIL})
         aAdd(aCab,{'EEQ_TP_CON',"4"              ,NIL})
         If lFinan
            aAdd(aCab,{'EEQ_DESCONT',SE2->E2_DESCONT ,NIL})
            aAdd(aCab,{'EEQ_FINNUM' ,SE2->E2_NUM     ,NIL})
            aAdd(aCab,{'EEQ_PREFIX' ,SE2->E2_PREFIXO ,NIL})
         EndIf
         //Verifica caso de inclusão de parcela com o câmbio já liquidado, neste caso, primeiro inclui a parcela
         If ((lFinan .And. !Empty(SE2->E2_BAIXA)) .Or. (!lFinan .And. !Empty(SWB->WB_CA_DT))) .And. !lExisteParc

            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,nOpcAux,"A",.F.)
         EndIf
         If !lMsErroAuto
            //Carrega array para casos em o câmbio o próximo MsExecAuto terá como objetivo liquidar ou estornar a parcela no SIGAESS
            If (lFinan .And. !Empty(SE2->E2_BAIXA)) .Or. (!lFinan .And. !Empty(SWB->WB_CA_DT)) .Or. (lExisteParc .And. !Empty(EEQ->EEQ_PGT))
               lMovBanc := .F.
               If lFinan
                  SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
                  lMovBanc := !Empty(SE2->E2_BAIXA) .And. SE5->(AvSeekLast(xFilial("SE5")+AvKey(SE2->E2_PREFIXO,"E5_PREFIXO")+AvKey(SE2->E2_NUM,"E5_NUMERO")+AvKey(SE2->E2_PARCELA,"E5_PARCELA")+AvKey(SE2->E2_TIPO,"E5_TIPO");
                  +AvKey(SE2->E2_FORNECE,"E5_CLIFOR")+AvKey(SE2->E2_LOJA,"E5_LOJA")))
               EndIf
               If lMovBanc .And. SE5->E5_RECPAG == "P" .And. SE5->E5_TIPODOC = "CP" .And. SE5->E5_MOTBX = "CMP" //MCF - 01/06/2016
                  aOrdSE5 := SaveOrd("SE5")
                  SE5->(DbSeek(xFilial("SE5")+ SE5->E5_DOCUMEN))
                  If SA6->(DbSeek(xFilial("SA6") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA)) .And. SA6->A6_MOEDA <> 1 //THTS - 28/12/2017 - Verifica se a moeda do banco e estrangeira (diferente da moeda 1)
                      If (nPosModal := aScan(aCab,{|x| x[1] == "EEQ_MODAL"}) > 0)
                            aCab[nPosModal,2] := "2" //Movimento no Exterior
                      EndIf
                      aAdd(aCab,{'EEQ_BCOEXT',SE5->E5_BANCO    ,NIL})
                      aAdd(aCab,{'EEQ_AGCEXT',SE5->E5_AGENCIA  ,NIL})
                      aAdd(aCab,{'EEQ_CNTEXT',SE5->E5_CONTA    ,NIL})
                      aAdd(aCab,{'EEQ_DTCE'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                  Else
                      aAdd(aCab,{'EEQ_BANC'  ,SE5->E5_BANCO    ,NIL})
                      aAdd(aCab,{'EEQ_AGEN'  ,SE5->E5_AGENCIA  ,NIL})
                      aAdd(aCab,{'EEQ_NCON'  ,SE5->E5_CONTA    ,NIL})
                      aAdd(aCab,{'EEQ_DTCE'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                      aAdd(aCab,{'EEQ_PGT'   ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                  EndIf
                  RestOrd(aOrdSE5, .T.)
               Else
                  If SA6->(DbSeek(xFilial("SA6") + If(!lMovBanc,If(!lFinan,SWB->WB_BANCO + SWB->WB_AGENCIA + SWB->WB_CONTA,""),SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA))) .And. SA6->A6_MOEDA <> 1 //THTS - 28/12/2017 - Verifica se a moeda do banco e estrangeira (diferente da moeda 1)
                      If (nPosModal := aScan(aCab,{|x| x[1] == "EEQ_MODAL"})) > 0
                            aCab[nPosModal,2] := "2" //Movimento no Exterior
                      EndIf
                      aAdd(aCab,{'EEQ_BCOEXT',If(!lMovBanc,If(!lFinan,SWB->WB_BANCO,""),SE5->E5_BANCO)              ,NIL})
                      aAdd(aCab,{'EEQ_AGCEXT',If(!lMovBanc,If(!lFinan,SWB->WB_AGENCIA,""),SE5->E5_AGENCIA)          ,NIL})
                      aAdd(aCab,{'EEQ_CNTEXT',If(!lMovBanc,If(!lFinan,SWB->WB_CONTA,""),SE5->E5_CONTA)              ,NIL})
                      aAdd(aCab,{'EEQ_DTCE'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                  Else
                      aAdd(aCab,{'EEQ_BANC'  ,If(!lMovBanc,If(!lFinan,SWB->WB_BANCO,""),SE5->E5_BANCO)              ,NIL})
                      aAdd(aCab,{'EEQ_AGEN'  ,If(!lMovBanc,If(!lFinan,SWB->WB_AGENCIA,""),SE5->E5_AGENCIA)          ,NIL})
                      aAdd(aCab,{'EEQ_NCON'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CONTA,""),SE5->E5_CONTA)              ,NIL})
                      aAdd(aCab,{'EEQ_DTCE'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                      aAdd(aCab,{'EEQ_PGT'   ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_DT,CToD("  /  /  ")),SE2->E2_BAIXA),NIL})
                  EndIf
               EndIf

               aAdd(aCab,{'EEQ_NROP'  ,If(!lMovBanc,If(!lFinan,SWB->WB_CA_NUM,""), cFieldCont) ,NIL})
               //If lFinan .And. lMovBanc .And. !Empty(SE5->E5_TXMOEDA) //RMD - 31/08/17 - Considerar títulos em reais
               If lFinan .And. lMovBanc
                  If !Empty(SE5->E5_TXMOEDA)
                     aAdd(aCab,{'EEQ_TX' ,SE5->E5_TXMOEDA  ,NIL})
                  ElseIf SE2->E2_MOEDA == 1
                     aAdd(aCab,{'EEQ_TX' ,1                ,NIL})
                  EndIf
               ElseIf !lFinan
                  aAdd(aCab,{'EEQ_SOL',SWB->WB_DT_CONT  ,NIL})
                  If !Empty(SWB->WB_CA_TX)
                     aAdd(aCab,{'EEQ_TX' ,SWB->WB_CA_TX ,NIL})
                  EndIf
               EndIf
               //aAdd(aCab,{'EEQ_EQVL',SWB->WB_FOBREAL  ,NIL})
            EndIf

            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,nOpcAux,"A",.F.)
            If lMsErroAuto
               lCont := .F.
            EndIf
         Else
            lCont := .F.
         EndIf
         If lFinan
            SE2->(DbSkip())
         Else
            SWB->(DbSkip())
         EndIf
      EndDo
   EndIf
End Sequence
SE2->(DbGoTo(nRecSE2))
SE5->(DbGoTo(nRecSE5))
RestOrd(aOrd,.T.)
Return !lMsErroAuto

/*
Programa   : CambioVal(cTipoPar)
Objetivo   : Verifica se existe alguma parcela liquidada de acordo com o tipo da parcela
             Chamada Apenas quando tiver integração com o Logix
Parâmetros : cTipoPar = referente ao campo WB_TIPOREG, podendo assim verificar qualquer tipo de parcela.
Autor      : Jacomo A F Lisa
Data       : 14/07/2014
*/
*---------------------------------------------------*
Function CambioVal(cTipoPar,cHawb)
*---------------------------------------------------*
//Local aOrd := SaveOrd({"SWB","SW9"})
Local lRet       := .F.
DEFAULT cTipoPar := "A" // "FRETE"
Default cHawb    := ""

SWB->(DbSetOrder(1))//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA

IF SWB->(DbSeek(xFilial("SWB")+cHawb+"D"))
   Do While SWB->(!Eof()) .AND. SWB->WB_FILIAL  == xFilial("SWB") ;
                          .AND. SWB->WB_HAWB    == cHawb;
                          .AND. SWB->WB_PO_DI   == "D"

      IF Left(SWB->WB_TIPOREG,1) <> cTipoPar
         SWB->(DbSkip())
         LOOP
      ENDIF

      If !Empty(SWB->WB_CA_DT)
         lRet := .T.
         EXIT
      EndIf
      SWB->(DbSkip())
   EndDo
ENDIF
RETURN lRet

/*
Função		: INVSISIntegra
Objetivos	: Integrar as despesas embutidas na Invoice com o SISCOSERV.
Autor		: Rodrigo Mendes Diaz
Data		: 20/10/14
*/
Static Function INVSISIntegra(cHAWB)
Local bChave := {|x,y,z| AllTrim(x)+"/"+AllTrim(y)+"/"+AllTrim(z) }
Local i, j, z
Local aDespesas := {}, aDespesa
Local cProd102 := "", cNBS102 := "", cProd103 := "", cNBS103 := "", cCnpjImp := "" //MCF - 15/01/2016
Local nValorInv, nValorTot
Private lMsErroAuto := .F.

	//*** Busca as Invoices do Processo
	BeginSql Alias "INVEIC"

		Select
			SW9.W9_INVOICE,
			SW9.W9_FORN,
			SW9.W9_FORLOJ,
			SW9.W9_MOE_FOB,
			SW9.W9_TX_FOB,
			SW9.W9_COND_PA,
			SW9.W9_FRETEIN,
			SW9.W9_SEGURO
		From
			%table:SW9% SW9
		Where
			%NotDel%
			And SW9.W9_FILIAL = %xFilial:SW9%
			And SW9.W9_HAWB = %exp:cHAWB%

	EndSql
	//***

	//*** Busca dados gerais das despesas

	EJW->(DbSetOrder(1))
	ELA->(DbSetOrder(4))
	SWB->(DbSetOrder(1))
	SYQ->(DbSetOrder(1))
	SYB->(DbSetOrder(1))
	SB5->(DbSetOrder(1))
    If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
       EEQ->(DbSetOrder(4))
    Else
       EEQ->(DbSetOrder(15))
	EndIf
	//Produto para o Frete
	//Verifica se existe produto para o frete informado na Via de Transporte, caso contrário considera o informado na despesa
	If SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(SW6->W6_VIA_TRA) .And. SYQ->(DbSeek(xFilial()+SW6->W6_VIA_TRA)) .And. !Empty(SYQ->YQ_PRDSIS)
		cProd102 := SYQ->YQ_PRDSIS
	Else
		If SYB->(DbSeek(xFilial("SYB")+"102"))
			cProd102 := SYB->YB_PRODUTO
		EndIf
	EndIf
	//Busca a NBS
	If !Empty(cProd102) .And. SB5->(DbSeek(xFilial("SB5")+cProd102))
		cNBS102 := SB5->B5_NBS
	EndIf

	//Busca o Produto para o Seguro
	If SYB->(DbSeek(xFilial("SYB")+"103"))
		cProd103 := SYB->YB_PRODUTO
		//Busca a NBS
		If SB5->(DbSeek(xFilial("SB5")+cProd103))
			cNBS103 := SB5->B5_NBS
		EndIf
	EndIf

	//Busca o pais do exportador
	//cPais := If(SA2->(DbSeek(xFilial("SA2")+AvKey(SWD->WD_FORN,"A2_COD")+AvKey(SWD->WD_LOJA,"A2_LOJA"))),SA2->A2_PAIS,"")
	//Considera o país de origem
	cPais := Posicione("SYR", 1, xFilial("SYR")+SW6->W6_VIA_TRA+SW6->W6_ORIGEM, "YR_PAIS_OR")

	//MCF - 15/01/2015
	cCnpjImp := Posicione("SYT", 1, xFilial("SYT")+SW6->W6_IMPORT, "YT_CGC")

	//***

	//*** Prepara os dados de integração
	While INVEIC->(!Eof())

		//Inclui dados do Frete
		If !Empty(cProd102) .And. !Empty(cNBS102) .And. INVEIC->W9_FRETEIN > 0
			aDespesa := INVSISDados(cHAWB,;
									Eval(bChave, cHAWB, INVEIC->W9_INVOICE, "102"),;
									INVEIC->W9_INVOICE,;
									INVEIC->W9_FORN,;
									INVEIC->W9_FORLOJ,;
									cPais,;
									INVEIC->W9_MOE_FOB,;
									cProd102,;
									cNBS102,;
									SW6->W6_DT_EMB,;
									INVEIC->W9_FRETEIN,;
									INVEIC->W9_TX_FOB,;
									cCnpjImp) //MCF - 15/01/2015

			aAdd(aDespesas, aClone(aDespesa))
		EndIf

		If !Empty(cProd103) .And. !Empty(cNBS103) .And. INVEIC->W9_SEGURO > 0
			//Inclui dados do seguro
			aDespesa := INVSISDados(cHAWB,;
									Eval(bChave, cHAWB, INVEIC->W9_INVOICE, "103"),;
									INVEIC->W9_INVOICE,;
									INVEIC->W9_FORN,;
									INVEIC->W9_FORLOJ,;
									cPais,;
									INVEIC->W9_MOE_FOB,;
									cProd103,;
									cNBS103,;
									SW6->W6_DT_EMB,;
									INVEIC->W9_SEGURO,;
									INVEIC->W9_TX_FOB,;
									cCnpjImp) //MCF - 15/01/2015)

			aAdd(aDespesas, aClone(aDespesa))
		EndIf

		INVEIC->(DbSkip())
	EndDo
	INVEIC->(DbCloseArea())
	//***

	//*** Executa as exclusões (se necessário)

	//Exclui pedidos relacionados a Invoices inexistentes
	EJW->(DbSeek(xFilial()+"A"+AllTrim(cHAWB)+"/"))
	While EJW->(!Eof() .And. Left(EJW->EJW_PROCES, Len(AllTrim(cHAWB)+"/")) == AllTrim(cHAWB)+"/" )

		/*
			RMD - 02/04/15 - Verifica se realmente trata-se de um processo relacionado a despesa de invoice, para isso o código deve possuir
							 o sufixo "\102" (frete) ou "\103" (seguro). Caso não possua a barra, não trata-se de um processo relacionado
							 a uma invoice, e sim a um processo de desembaraço, o que é tratado na função específica para as despesas da capa.
		*/
		If !(("/102" $ SubStr(EJW->EJW_PROCES, Len(AllTrim(cHAWB)+"/")+1)) .Or. ("/103" $ SubStr(EJW->EJW_PROCES, Len(AllTrim(cHAWB)+"/")+1)))
			EJW->(DbSkip())
			Loop
		EndIf

		If aScan(aDespesas, {|x| AllTrim(x[1][2][2]) == AllTrim(EJW->EJW_PROCES) }) == 0 //LRS - 05/03/2015

			cProcExc := EJW->EJW_PROCES

			//Exclui Parcelas de Câmbio (SISCOSERV) relacionadas a Invoice (EIC) inexistente
            If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
               EEQ->(DbSeek(xFilial()+AvKey(cProcExc,"EEQ_NRINVO")+AvKey("A"+cProcExc,"EEQ_PREEMB")))
               cCond := 'EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB == xFilial()+AvKey(cProcExc,"EEQ_NRINVO")+AvKey("A"+cProcExc,"EEQ_PREEMB")'
            Else
               EEQ->(DbSeek(xFilial()+AvKey("A","EEQ_TPPROC")+AvKey(cProcExc,"EEQ_PROCES")+AvKey(cProcExc,"EEQ_NRINVO")))  // GFP - 26/05/2015
               cCond := 'EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO == xFilial()+AvKey("A","EEQ_TPPROC")+AvKey(cProcExc,"EEQ_PROCES")+AvKey(cProcExc,"EEQ_NRINVO")'
            EndIf
			While EEQ->(!Eof() .And. &cCond)  // GFP - 26/05/2015
				aExcluir := {	{"EEQ_FILIAL", EEQ->EEQ_FILIAL, Nil},;
								{"EEQ_NRINVO", EEQ->EEQ_NRINVO, Nil},;
								{"EEQ_PREEMB", EEQ->EEQ_PREEMB, Nil},;
								{"EEQ_PARC"  , EEQ->EEQ_PARC  , Nil}}

				MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)}, "EEQ", , , aExcluir, EXCLUIR, "A", .F.)

				EEQ->(DbSkip())
			EndDo

			//Exclui Invoices (SISCOSERV) relacionadas a Invoice (EIC) inexistente
			ELA->(DbSeek(xFilial()+"A"+AvKey(cProcExc, "ELA_PROCES")+AvKey(cProcExc, "ELA_NRINVO")))
			While ELA->(!Eof() .And. ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO == xFilial()+"A"+AvKey(cProcExc, "ELA_PROCES")+AvKey(cProcExc, "ELA_NRINVO"))
				aExcluir := {	{"ELA_FILIAL", ELA->ELA_FILIAL, Nil},;
								{"ELA_TPPROC", ELA->ELA_TPPROC, Nil},;
								{"ELA_PROCES", ELA->ELA_PROCES, Nil},;
								{"ELA_NRINVO", ELA->ELA_NRINVO, Nil},;
								{"ELA_EXPORT", ELA->ELA_EXPORT, Nil},;
								{"ELA_LOJEXP", ELA->ELA_LOJEXP, Nil}}

				MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,"A", aExcluir,, EXCLUIR, .F. /*Indica que não será integrado ao SigaFin*/)})

				ELA->(DbSkip())
			EndDo

			//Exclui o Pedido (SISCOSERV) relacionado a Invoice (EIC) inexistente (registro EJW posicionado no momento)
			aExcluir := {	{"EJW_FILIAL", EJW->EJW_FILIAL, Nil},;
							{"EJW_ORIGEM", "SIGAEIC"      , Nil},;
							{"EJW_TPPROC", EJW->EJW_TPPROC, Nil},;
							{"EJW_PROCES", EJW->EJW_PROCES, Nil}}

			MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)}, aExcluir,{},,EXCLUIR)

		EndIf
		EJW->(DbSkip())

	EndDo
	//RMD - 02/04/15 - Despreza o retorno de MsErroAuto nas chamadas de limpeza de base.
	lMsErroAuto := .F.
	//***

	//*** Executa a integração
	For i := 1 To Len(aDespesas)

		nOpcPed := If(!EJW->(DbSeek(xFilial()+"A"+AvKey(aDespesas[i][1][2][2], "EJW_PROCES"))), INCLUIR, ALTERAR)
		//nOpcInv := If(!ELA->(DbSeek(xFilial()+"A"+AvKey(aDespesas[i][1][2][2], "EJW_PROCES")+AvKey(aDespesas[i][1][2][2], "EJW_PROCES"))), INCLUIR, ALTERAR)
		//RMD - 02/04/15 - Utiliza a invoice do campo correto (SW9) e utiliza o índice correto
		ELA->(DbSetOrder(4))
		nOpcInv := If(!ELA->(DbSeek(xFilial()+"A"+AvKey(aDespesas[i][3][3][2], "ELA_PROCES")+AvKey(aDespesas[i][3][2][2], "ELA_NRINVO"))), INCLUIR, ALTERAR)

		//*** Caso seja Inclusão, inclui o Pedido e em seguida a Invoice
		If nOpcPed == INCLUIR .And. !lMsErroAuto
			//Inclui o Pedido
			MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)}, aDespesas[i][1], aDespesas[i][2],,nOpcPed)
		EndIf
		If nOpcInv == INCLUIR .And. !lMsErroAuto
			//Inclui a Invoice
			MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,"A", aDespesas[i][3], aDespesas[i][4], nOpcInv, .F. /*Indica que não será integrado ao SigaFin*/)})
		EndIf
		//***

		//*** Integra as parcelas de Câmbio
		For j := 1 To Len(aDespesas[i][5])

			//Rateia o valor da Invoice entre as parcelas de câmbio
			nValorInv := aDespesas[i][4][1][aScan(aDespesas[i][4][1], {|x| x[1] == "ELB_VLCAMB" })][2]
			nValorTot := 0
			For z := 1 To Len(aDespesas[i][5])
				nValorTot += aDespesas[i][5][z][aScan(aDespesas[i][5][z], {|x| x[1] == "EEQ_VL"})][2]
			Next

			oRateio := EasyRateio():New(nValorInv, nValorTot, z-1, AvSx3("EEQ_VLSISC", AV_DECIMAL))

			For z := 1 To Len(aDespesas[i][5])
				aDespesas[i][5][z][aScan(aDespesas[i][5][z], {|x| x[1] == "EEQ_VLSISC"})][2] := oRateio:GetItemRateio(aDespesas[i][5][z][aScan(aDespesas[i][5][z], {|x| x[1] == "EEQ_VL"})][2])
			Next

			If !lMsErroAuto
				//Inclui/Altera o Câmbio (EEQ)
                If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
                   nOpcCamb := If(!EEQ->(DbSeek(xFilial()+AvKey(aDespesas[i][5][j][3][2],"EEQ_NRINVO")+AvKey(aDespesas[i][5][j][2][2],"EEQ_PREEMB")+aDespesas[i][5][j][4][2])), INCLUIR, ALTERAR)
                Else
                   nOpcCamb := If(!EEQ->(DbSeek(xFilial()+AvKey(aDespesas[i][5][j][18][2],"EEQ_TPPROC")+AvKey(aDespesas[i][5][j][6][2],"EEQ_PROC")+AvKey(aDespesas[i][5][j][3][2],"EEQ_NRINVO")+aDespesas[i][5][j][4][2])), INCLUIR, ALTERAR)  // GFP - 26/05/2015
                EndIf
				MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)}, "EEQ", , , aDespesas[i][5][j], nOpcCamb, "A", .F.)
			EndIf

		Next
		//***

		//*** Caso seja alteração, atualiza a Invoice e depois o Pedido
		If nOpcInv <> INCLUIR .And. !lMsErroAuto
			//Atualiza a Invoice
			MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,"A", aDespesas[i][3], aDespesas[i][4], nOpcInv, .F. /*Indica que não será integrado ao SigaFin*/)})
		EndIf
		If nOpcPed <> INCLUIR .And. !lMsErroAuto
			//Atualiza o Pedido
			MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)}, aDespesas[i][1], aDespesas[i][2],,nOpcPed)
		EndIf
		//***

	Next
	//***

Return Nil


/*
Função		: INVSISDados
Objetivos	: Preparar os dados de integração com o SISCOSERV de despesas embutidas na Invoice.
Autor		: Rodrigo Mendes Diaz
Data		: 20/10/14
*/
Static Function INVSISDados(cHAWB, cProcSIS, cInvoice, cForn, cLoja, cPaisForn, cMoeda, cItem, cNBS, dDtEmba, nValor, nTaxa, cCnpjImp)
Local aPed := {}, aPedItem := {}, aInv := {}, aInvItem := {}, aParcelas := {}, aParcela

	//*** Dados da Capa do Pedido no SISCOSERV
	aAdd(aPed,{'EJW_FILIAL',xFilial("EJW")				,NIL})
	aAdd(aPed,{'EJW_PROCES',cProcSIS						,NIL})
	aAdd(aPed,{'EJW_TPPROC',"A"							,NIL})
	aAdd(aPed,{'EJW_ORIGEM',"SIGAEIC"					,NIL})
	aAdd(aPed,{'EJW_EXPORT',cForn,NIL})
	aAdd(aPed,{'EJW_LOJEXP',cLoja,NIL})
	aAdd(aPed,{'EJW_MOEDA',cMoeda,NIL})
	If EasyGParam("MV_ESS0021",,.F.) .And. EasyGParam("MV_ESS0025",,.F.) .And. EJW->(FieldPos("EJW_CGC")) > 0 //MCF - 15/01/2016
	   aAdd(aPed,{'EJW_CGC',cCnpjImp,NIL})
	Endif
	//***

	//*** Dados do Item do Pedido no SISCOSERV
	aAdd(aPedItem,{'EJX_FILIAL',xFilial("EJX"),NIL})
	aAdd(aPedItem,{'EJX_SEQPRC',StrZero(1,AvSx3("EJX_SEQPRC",AV_TAMANHO)),NIL})
	aAdd(aPedItem,{'EJX_PROCES',cProcSIS,NIL})
	aAdd(aPedItem,{'EJX_TPPROC',"A",NIL})
	aAdd(aPedItem,{'EJX_ITEM'  ,cItem,NIL})
	aAdd(aPedItem,{'EJX_MODAQU',"1",NIL})
	aAdd(aPedItem,{'EJX_PAIS'  ,cPais,NIL}) //País do fornecedor
	aAdd(aPedItem,{'EJX_NBS'   ,cNBS,NIL})
	aAdd(aPedItem,{'EJX_DTINI' ,dDtEmba,NIL})
	aAdd(aPedItem,{'EJX_QTDE'  ,1,NIL})
	aAdd(aPedItem,{'EJX_PRCUN' ,nValor,NIL})
	aAdd(aPedItem,{'EJX_TX_MOE',nTaxa,NIL})

	aPedItem := {aPedItem}

	//***

	//*** Dados da Invoice do Pedido no SISCOSERV
	aAdd(aInv,{'ELA_FILIAL',xFilial("ELA"),NIL})
	aAdd(aInv,{'ELA_NRINVO',cInvoice,NIL})
	aAdd(aInv,{'ELA_PROCES',cProcSIS,NIL})
	aAdd(aInv,{'ELA_TPPROC',"A",NIL})
	aAdd(aInv,{'ELA_EXPORT',cForn,NIL}) //Busca da Invoice
	aAdd(aInv,{'ELA_LOJEXP',cLoja,NIL}) //Busca da Invoice
	aAdd(aInv,{'ELA_ORIGEM',"SIGAEIC",NIL})
	aAdd(aInv,{'ELA_INT'   ,"S",NIL})
	aAdd(aInv,{'ELA_MOEDA' ,cMoeda,NIL})
	aAdd(aInv,{'ELA_DTEMIS',dDtEmba,NIL})
	aAdd(aInv,{'ELA_TX_MOE',nTaxa,NIL})
	//Item da Invoice
	aAdd(aInvItem,{'ELB_SEQPRC',StrZero(1,AvSx3("ELB_SEQPRC",AV_TAMANHO)) ,NIL})
	aAdd(aInvItem,{'ELB_VLCAMB',nValor,NIL})
	aAdd(aInvItem,{'ELB_VLEXT' ,0,NIL})

	aInvItem := {aInvItem}
	//***

	//*** Dados do Cambio do Pedido do Frete no SISCOSERV
	SWB->(DbSeek(xFilial()+AvKey(cHAWB, "WB_HAWB")+AvKey("D","WB_PO_DI")+AvKey(cInvoice, "WB_INVOICE")+AvKey(cForn, "WB_FORN")+AvKey(cLoja, "WB_LOJA")))
	While SWB->(!Eof() .And. WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA == xFilial()+AvKey(cHAWB, "WB_HAWB")+AvKey("D","WB_PO_DI")+AvKey(cInvoice, "WB_INVOICE")+AvKey(cForn, "WB_FORN")+AvKey(cLoja, "WB_LOJA"))

		aParcela := {}

		aAdd(aParcela,{'EEQ_FILIAL',xFilial("EEQ"),NIL})
		aAdd(aParcela,{'EEQ_PREEMB',AvKey("A"+cProcSIS, "EEQ_PREEMB"),NIL})//RMD - 02/04/15 - Incluido o AvKey
		aAdd(aParcela,{'EEQ_NRINVO',cInvoice,NIL})
		aAdd(aParcela,{'EEQ_PARC'  ,StrZero((Val(RetAsc(SWB->WB_PARCELA,Len(SWB->WB_PARCELA))) - Val(RetAsc(EasyGParam("MV_1DUP"),Len(SWB->WB_PARCELA))))+1,Len(EEQ->EEQ_PARC)) ,NIL})  // GFP - 02/06/2015
		aAdd(aParcela,{'EEQ_PARVIN',RetAsc(SWB->WB_PARCELA,AVSX3("EEQ_PARC",AV_TAMANHO),.F.),NIL})
		aAdd(aParcela,{'EEQ_PROCES',cProcSIS,NIL})
		aAdd(aParcela,{'EEQ_FASE'  ,"4",NIL})
		aAdd(aParcela,{'EEQ_EVENT' ,"001",NIL})
		aAdd(aParcela,{'EEQ_MOEDA' ,SWB->WB_MOEDA,NIL})
		aAdd(aParcela,{'EEQ_VCT'   ,SWB->WB_DT_VEN,NIL})
		aAdd(aParcela,{'EEQ_PARI'  ,1,NIL})
		aAdd(aParcela,{'EEQ_VL'    ,SWB->WB_FOBMOE,NIL})
		aAdd(aParcela,{'EEQ_VLSISC',SWB->WB_FOBMOE,NIL})
		aAdd(aParcela,{'EEQ_DECAM' ,"2",NIL})
		aAdd(aParcela,{'EEQ_TIPO'  ,"A",NIL})
		aAdd(aParcela,{'EEQ_FORN'  ,SWB->WB_FORN,NIL})
		aAdd(aParcela,{'EEQ_FOLOJA',SWB->WB_LOJA,NIL})
		aAdd(aParcela,{'EEQ_TPPROC',"A",NIL})
		aAdd(aParcela,{'EEQ_SOURCE',"SIGAEIC",NIL})
		aAdd(aParcela,{'EEQ_MODAL' ,"1",NIL})
		aAdd(aParcela,{'EEQ_TP_CON',"4",NIL})
		aAdd(aParcela,{'EEQ_BANC'  ,SWB->WB_BANCO,NIL})
		aAdd(aParcela,{'EEQ_AGEN'  ,SWB->WB_AGENCIA,NIL})
		aAdd(aParcela,{'EEQ_NCON'  ,SWB->WB_CONTA,NIL})
		aAdd(aParcela,{'EEQ_PGT'   ,SWB->WB_CA_DT,".T."})//RMD - 03/04/15 - Desabilita a validação do campo.
		aAdd(aParcela,{'EEQ_NROP'  ,SWB->WB_CA_NUM,NIL})
		aAdd(aParcela,{'EEQ_SOL',SWB->WB_DT_CONT,NIL})
		aAdd(aParcela,{'EEQ_TX' ,SWB->WB_CA_TX,NIL})

		aAdd(aParcelas, aClone(aParcela))

		SWB->(DbSkip())
	EndDo
	//***

Return {aPed, aPedItem, aInv, aInvItem, aParcelas}

/*
Funcao    : DI500ValRat()
Objetivo  : Validar o rateio feito na adição automatica e garantir nao ter valores negativos no processo
Autor     : Laercio G S Junior - LGS
Data      : 26/11/2014
Retorna   : Nenhum
*/
*-----------------------*
Function DI500ValRat(nOpc)
*-----------------------*
Local A, X
Local cCpoValid := ""
Local aOrd, aVldTab
Local aSW8Cps := {"Work_SW8->WKINLAND","Work_SW8->WKPACKING","Work_SW8->WKDESCONT","Work_SW8->WKOUTDESP","Work_SW8->WKFRETEIN","Work_SW8->WKSEGURO"}
Local aEIJCps := {{"Work_EIJ->EIJ_VLMLE",0},{"Work_EIJ->EIJ_VLMMN",0},{"Work_EIJ->EIJ_VFREMN",0},{"Work_EIJ->EIJ_VSEGMN",0}}
Default nOpc := 0

If nOpc == 0 .And. !Empty(aValRat)
	aOrd  := SaveOrd({"Work_SW8"})
	For A := 1 To Len(aValRat)
		aValRat[A,1] := 0
		cCpoValid    := aSW8Cps[A]
		If(&cCpoValid < 0, aValRat[A,1]+= (aValRat[A,1]+(&cCpoValid *-1)), )
	Next
Else
	aOrd  := SaveOrd({"Work_EIJ"})
	For A := 1 To Len(aEIJCps)
		cCpoValid := aEIJCps[A,1]
		If(&cCpoValid < 0, aEIJCps[A,2]+= (aEIJCps[A,2]+(&cCpoValid *-1)), )
	Next
EndIf

If nOpc == 0 .And. !Empty(aValRat) //Work_SW8
	aVldTab := Aclone(aValRat)
	X := 1
Else
	aVldTab := Aclone(aEIJCps)     //Work_EIJ
	X := 2
EndIf

For A := 1 To Len(aVldTab)
	cCpoValid := If(nOpc == 0, aSW8Cps[A], aEIJCps[A,1])
	If( nOpc == 0, Work_SW8->(DbGoTop()), Work_EIJ->(DbGoTop()) )
	Do While If( nOpc == 0, Work_SW8->(!Eof()), Work_EIJ->(!Eof()) ) .AND. aVldTab[A,X] > 0
		If &cCpoValid <  0
		   &cCpoValid := 0
		Else
			If &cCpoValid   >=  aVldTab[A,X]
			   &cCpoValid   += (aVldTab[A,X]*-1)
			   aVldTab[A,X] := 0
			Else
			   aVldTab[A,X] += (&cCpoValid *-1)
			   &cCpoValid   := 0
			EndIf
		EndIf
		If(nOpc == 0, Work_SW8->(DbSkip()), Work_EIJ->(DbSkip()) )
	EndDo
Next

RestOrd(aOrd, .T.)
Return Nil

/*
  LGS-14/05/2015
*/
Function DI500SldSW8()
Local aOrdSW8   := SaveOrd({"SW8"})
Local nSaldoSW8 := 0

SW8->(DbSetOrder(3))
If SW8->(DbSeek(xFilial("SW8")+SW6->W6_HAWB+Work->(WKPGI_NUM+WKPO_NUM+WKSI_NUM+WKCC+WKCOD_I+STR(WKREG, 4, 0))))
   Do While SW8->(!Eof()) .And. ;
            SW8->(W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG, 4, 0)) ==;
            SW6->W6_HAWB+AvKey(Work->WKPGI_NUM,"W8_PGI_NUM")+AvKey(Work->WKPO_NUM,"W8_PO_NUM")+;
            AvKey(Work->WKSI_NUM,"W8_SI_NUM")+AvKey(Work->WKCC,"W8_CC")+AvKey(Work->WKCOD_I,"W8_COD_I")+;
            STR(Work->WKREG, 4, 0)
            
      nSaldoSW8 += SW8->W8_QTDE
      SW8->(DbSkip())
   EndDo
   Work->WKDISPINV:= (Work->WKQTDE - nSaldoSW8)
Else
   Work->WKDISPINV:= Work->WKQTDE
EndIf
RestOrd(aOrdSW8,.T.)
Return Nil

//LGS-09/10/2015 - Função utilizada por gatilho "EIJ" - AntiDumping
*---------------------------*
Function DI500ValEIJ(cCampo)
*---------------------------*
Local nRet := 0
Default cCampo := ""

Begin Sequence
	If Empty(cCampo)
	   Break
	EndIf
	Do Case
	   Case cCampo == "EIJ_BAD_AD"	//Campo base AD-Valorem
	        lAtuAnDupi := .F.
	        nRet := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )

	   Case cCampo == "EIJ_ALADDU" .Or. cCampo == "EIJ_ALEADU" .Or. cCampo == "EIJ_BAE_AD"	.Or. cCampo == "EIJ_TPADUM"
	        If cCampo == "EIJ_TPADUM" .And. M->EIJ_TPADUM == "1"
	           M->EIJ_BAE_AD := M->EIJ_ALEADU := 0
	        ElseIf cCampo == "EIJ_TPADUM" .And. M->EIJ_TPADUM == "2"
	           M->EIJ_ALADDU := 0
	        EndIf
	        nRet := DI500TRANS( (M->EIJ_ALADDU * M->EIJ_BAD_AD) /100) + DI500TRANS( (M->EIJ_ALEADU * M->EIJ_BAE_AD) )
	EndCase

End Sequence

Return nRet

/*
Funcao    : GerCambFin
Objetivo  : Verificar se o câmbio deverá apurar pelo Cambio do EIC ou pelo Financeiro no Protheus ou se será controlado pelo EIC x Siscoserv (MV_EASYFIN, MV_CAMBFRE, MV_CAMBSEG e MV_FIN_EIC)
Parâmetros: lValEnt  - Valor de entrada na Função, referente ao valor atual da variável lFinan;
            cDespesa - Codigo da despesa. 102=Frete; 103=Seguro;
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 02/01/2018
Retorna   : lRet - .T. indica que deve gerar financeiro no Protheus; .F. controle será feito pelo câmbio do EIC;
*/
Static Function GerCambFin(lValEnt,cDespesa,lNumera)
Local lRet      := lValEnt // Se lValEnt for .T., o MV_EASYFIN está habilitado;
Local lMvFinEIC := EasyGParam("MV_FIN_EIC",.F.,.F.)
Default lNumera := .F.
/* Se lRet for .F. (MV_EASYFIN Desabilitado, o retorno da função será falso, pois não deve gerar financeiro, 
 indepensente do conteúdo dos parâmetros MV_CAMBFRE, MV_CAMBSEG e MV_FIN_EIC);
*/
If lRet //MV_EASYFIN = S 
    Do Case
        Case AvFlags("GERACAO_CAMBIO_FRETE")  .And. cDespesa == "102" .and. !lNumera //MV_CAMBFRE == .T. e despesa == Frete
            lRet := .F.
        
        Case AvFlags("GERACAO_CAMBIO_SEGURO") .And. cDespesa == "103" .and. !lNumera //MV_CAMBSEG == .T. e Despesa == Seguro
            lRet := .F.

    EndCase
EndIf

Return lRet


Static Function GetModAtoC(cAtoConc,lPosiciona)
Local cTipo        := ""
Local aOrd         := SaveOrd("ED0")
Default cAtoConc   := ""
Default lPosiciona := .F.
ED0->(DbSetOrder(2))
If ED0->(DbSeek( xFilial("ED0") + AvKey(cAtoConc, "ED0_AC")  ))
   cTipo := ED0->ED0_MODAL
EndIf

If !lPosiciona
   RestOrd(aOrd,.T.)
EndIf

Return cTipo

/*
Funcao    : DI505GatDsp
Objetivo  : Normalização de gatilhos dos campos de despesas(isolar gatilhos de validações)
Parâmetros: cCampo - Campo que disparou o gatilho
Autor     : Nilson César
Data      : 18/06/2020
Retorna   : N/A
*/
Function DI505GatDsp(cCampo)
Local xRet
DO CASE

   CASE cCampo == "WD_BASEADI"
      xRet := IF(M->WD_BASEADI $ cSim   ,'1' , IF(M->WD_BASEADI $ cNao ,'2',' '))
END CASE

Return xRet

/*
Funcao    : ExisteMidia
Objetivo  : Utilização da variavel Existe_Midia sem declaração, para evitar declarar como private foi necessário criar a funçao ExisteMidia
Parâmetros: 
Autor     : Ramon Prado
Data      : 10/11/2020
Retorna   : EasyGParam("MV_SOFTWAR",,"N") $ cSim
*/
Static Function ExisteMidia()
Return EasyGParam("MV_SOFTWAR",,"N") $ cSim
//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA EICDI505.PRW
//------------------------------------------------------------------------------------//
