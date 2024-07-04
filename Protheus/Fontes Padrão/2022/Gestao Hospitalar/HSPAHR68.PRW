#INCLUDE "HSPAHR68.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR68  บ Autor ณ Paulo C้sar        บ Data ณ  17/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio MARGEM DE CONTRIBUIวรO                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ                       
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR68()
             
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         	:= ""
Local cPict          	:= ""
Local titulo         	:= STR0003//"Faturamento por setor e grupo de despesas"
Local nLin           	:= 80
Local Cabec1         	:= ""
Local Cabec2         	:= ""
Local imprime        	:= .T.
Local aOrd 				      	:= {}    

Private lEnd         	:= .F.             
Private lAbortPrint  	:= .F.
Private limite       	:= 80 
Private tamanho      	:= "M"
Private nomeprog     	:= "HSPAHR68" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        	:= 18
Private aReturn      	:= {STR0004, 1, STR0005, 2, 2, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey     	:= 0
Private cbtxt        	:= Space(10)
Private cbcont       	:= 00
Private CONTFL       	:= 01
Private m_pag        	:= 01
Private wnrel        	:= nomeprog
Private cPerg        	:= "HSPR68"
Private nAgrupar     	:= 0
Private nTpRel								:= 0

Private cString  					:= ""

Private cCODIMP 						:= ""
Private nMaxLin 						:= 0 // quantidade maxima de linhas p/ impressao

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                         ณ
 ณ MV_PAR01	Do procedimento ?                                         ณ
 ณ MV_PAR02	Ate o procedimento ?                                      ณ
 ณ MV_PAR03	Do grupo de despesas ?                                    ณ
 ณ MV_PAR04	Ate o grupo de despesas ?                                 ณ
 ณ MV_PAR05	Da data ?                                                 ณ
 ณ MV_PAR06	Ate a data ?                                              ณ
 ณ MV_PAR07	Do convenio ?                                             ณ
 ณ MV_PAR08	Ate o convenio ?                                          ณ
 ณ MV_PAR09	Tipo de relatorio ?                                       ณ
 | MV_PAR10 Impressora ?                                              |
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2      
                                              
If MV_PAR09 == 1 // Analํtico
 tamanho      	:= "M"
 Titulo := Titulo + " - Analํtico"
 Cabec1 := STR0011 //"Convenio"
 Cabec2	:=	STR0012 //"    Plano"
Else                
 tamanho      	:= "G"
 Titulo := Titulo + " - Sint้tico"
 Cabec1 := STR0014 //"                                                                        MATERIAIS                                                                              MEDICAMENTOS"
 Cabec2	:=	STR0013 //"                    Convenio                         Qtde   Pre็o Compra   Pre็o Venda  Contribui็ใo                                         Qtde   Pre็o Compra   Pre็o Venda  Contribui็ใo"
EndIf 

nTpRel			:= MV_PAR09 // Tipo de Relatorio: 1 = Analitico / 2 = Sintetico

/*								1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Paulo C้sar        บ Data ณ  17/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local cSQL 	     	  := ""
	Local aCabecResumo := {.F., .F.}
 Local aResumo      := {}  
 Local aTabPreco    := {}
 Local aTabPreAux   := {}
 Local iConta       := 0   
 Local nPos         := 0
 Local cTipoResumo  := ""
 Local nPosTabPre   := 0 
 Local nVndPro      := 0
 Local nCusPro      := 0
 Local nFdvBRA		:= 0   
 Local aRVldVig := {{"", "GCB_ATIVO" }, ;
                    { 0, "GCB_PRCVEN"}, ;
                    {"", "GCB_CODPRO"}, ;
                    {"", "GCB_DESPRO"}, ;
                    { 0, "GCB_FATOR" }}

 Private cSetor     := ""
	Private cPlano     := ""               
	Private cConvenio  := ""
	Private cID        := ""
	Private cGrupoDesp := ""
 Private aRegistro  := {}
 Private aTotalDesp := {}
 Private aTotalPlan := {}
 Private aTotalConv := {}
 Private aTotalGera := {} 
 
 Private nQDesp := 0  
 Private nCDesp := 0
 Private nVDesp := 0
 Private nQPlan := 0  
 Private nCPlan := 0
 Private nVPlan := 0 
 Private nQConv := 0  
 Private nCConv := 0
 Private nVConv := 0
 Private nQGera := 0  
 Private nCGera := 0
 Private nVGera := 0
 Private nQMed := 0  
 Private nCMed := 0
 Private nVMed := 0
 Private nQMat := 0  
 Private nCMat := 0
 Private nVMat := 0
                                      
 cSQL := "SELECT GCZ_CODCON, GA9_NREDUZ, GCZ_CODPLA, GCM_DESPLA, GBI_TIPO, GE5_CODDES,     "
 cSQL += "       GE5_DESPRO, B1_UPRC, SUM(GE5_QTDDES) AS QRY_QTDDES, GE5_DATDES, GBI_TIPKIT "
 cSQL += "FROM "+ RetSQLName("GCZ") +" GCZ                                                 "
 cSQL += "     INNER JOIN "+ RetSQLName("GE5") +" GE5                                      "
 cSQL += "            ON GE5_FILIAL = '" + xFilial("GE5") + "' "                           "
 cSQL += "           AND GE5_NRSEQG = GCZ_NRSEQG                                           "
 cSQL += "           AND GE5_DATDES BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'  "
 cSQL += "           AND GE5_CODDES BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'      "   
 cSQL += "     INNER JOIN "+ RetSQLName("GA9") +" GA9                                      "
 cSQL += "            ON GA9_FILIAL = '" + xFilial("GA9") + "' "                           "
 cSQL += "           AND GA9_CODCON = GCZ_CODCON                                           "    
 cSQL += "     INNER JOIN "+ RetSQLName("GCM") +" GCM                                      "
 cSQL += "            ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "'                         "
 cSQL += "           AND GCM.GCM_CODCON = GCZ.GCZ_CODCON                                   " 
 cSQL += "           AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA                                   "
 cSQL += "           AND GCM.D_E_L_E_T_ <> '*'                                             "                                         
 cSQL += "     INNER JOIN "+ RetSQLName("SB1") +"                                          "
 cSQL += "            ON B1_FILIAL = '" + xFilial("SB1") + "' "                            "
 cSQL += "           AND B1_COD = GE5_CODDES                                               "
 cSQL += "           AND B1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'        "   
 cSQL += "     INNER JOIN "+ RetSQLName("GBI") +" GBI                                      "
 cSQL += "            ON GBI_FILIAL = '" + xFilial("GBI") + "' "                           "
 cSQL += "           AND GBI_PRODUT = GE5_CODDES                                           "
 cSQL += "           AND GBI_TIPO <= '1'                                                   "
 cSQL += "WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' "                                    "
 cSQL += "AND GCZ_CODCON BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                         " 
 cSQL += "GROUP BY GCZ_CODCON, GA9_NREDUZ, GCZ_CODPLA, GCM_DESPLA, GBI_TIPO, GE5_CODDES,   "
 cSQL += "         GE5_DESPRO, B1_UPRC, GE5_DATDES, GBI_TIPKIT                    "
 cSQL += "ORDER BY GCZ_CODCON, GCZ_CODPLA, GBI_TIPO                                        "
 
 cSql := ChangeQuery(cSql)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 If Eof()
  HS_MsgInf(STR0008, STR0009, STR0003) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Procedimento Realizados"
  DBCloseArea()
  Return 
 Endif

 aRegistro:={}   
 cId := QRY->GBI_TIPO
 cConvenio:=QRY->GA9_NREDUZ   
 cPlano:=QRY->GCM_DESPLA

 While !EOF()
  If     QRY->GBI_TIPO == "0" .Or. (QRY->GBI_TIPO == "4" .And. QRY->GBI_TIPKIT == "0") // 0-Materiais
 	 aTabPre := HS_RTabPre("GD9", QRY->GCZ_CODPLA, QRY->GE5_CODDES, STOD(QRY->GE5_DATDES), QRY->GCZ_CODCON)
  ElseIf QRY->GBI_TIPO == "1" .Or. (QRY->GBI_TIPO == "4" .And. QRY->GBI_TIPKIT == "1") // 1-Medicamentos
 	 aTabPre := HS_RTabPre("GDA", QRY->GCZ_CODPLA, QRY->GE5_CODDES, STOD(QRY->GE5_DATDES), QRY->GCZ_CODCON)
  EndIf
                                                                                        
  If Len(aTabPre) > 0 .And. HS_VldVig("GCB", "GCB_FILIAL = '" + xFilial("GCB") + "'AND GCB_CODTAB = '" + aTabPre[1] + "' AND GCB_PRODUT = '" + QRY->GE5_CODDES + "'", "GCB_DATVIG", @aRVldVig, STOD(QRY->GE5_DATDES))
   nVndPro := IIf(aTabPre[7] == "1" .And. aRVldVig[5][1] > 0, aRVldVig[2][1] * aRVldVig[5][1], aRVldVig[2][1]) // Fator de multiplica็ใo
	  nVndPro := IIf(aTabPre[3]     > 0, nVndPro * aTabPre[3], aRVldVig[2][1]) // Margem de lucro
  EndIf 

  nFdvBRA := Posicione("GBI",1,xFilial("GBI") + QRY->GE5_CODDES,"GBI_FDVBRA")
  If nFdvBRA > 0
  	nCusPro := QRY->B1_UPRC / nFdvBRA
  Else
  	nCusPro := QRY->B1_UPRC
  EndIf
/*  If (nPosTabPre := aScan(aTabPreAux, {|x| x[1] == QRY->GE5_CODDES .And. x[2] == QRY->GE5_DATDES})) == 0
   aTabPreco := HS_RValMM(QRY->GCZ_CODPLA, QRY->GE5_CODDES, , .F., STOD(QRY->GE5_DATDES))
   AAdd(aTabPreAux, {QRY->GE5_CODDES, QRY->GE5_DATDES, aTabPreco[2], aTabPreco[3]})
   nPosTabPre := Len(aTabPreAux)
  EndIf*/
  If MV_PAR09 == 1 // Analํtico
   If cId <> QRY->GBI_TIPO  
    GeraTT(1)
    cId := QRY->GBI_TIPO
    nQDesp := 0
    nCDesp := 0
    nVDesp := 0
   EndIf   
   
   If cPlano <> QRY->GCM_DESPLA 
    GeraTT(2)
    cId := QRY->GBI_TIPO
    cPlano:=QRY->GCM_DESPLA
    nQPlan := 0
    nCPlan := 0
    nVPlan := 0
   EndIF  
 
   If cConvenio <> QRY->GA9_NREDUZ
    GeraTT(3)
    cId := QRY->GBI_TIPO
    cPlano:=QRY->GCM_DESPLA
    cConvenio:=QRY->GA9_NREDUZ
    nQConv := 0
    nCConv := 0
    nVConv := 0
   EndIF 
   AADD(aRegistro, {0, QRY->GCZ_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCZ_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GE5_DESPRO, nCusPro, nVndPro ,  nVndPro - nCusPro, ((nVndPro / nCusPro) - 1) * 100  , QRY->GBI_TIPO, QRY->QRY_QTDDES, 0, 0, 0, 0, 0}) 
   If cID = "1" 
    nQMed += QRY->QRY_QTDDES
    nCMed += nCusPro
    nVMed += nVndPro
   Else
    nQMat += QRY->QRY_QTDDES
    nCMat += nCusPro
    nVMat += nVndPro
   EndIf         

  Else  // Sint้tico         
   cId := QRY->GBI_TIPO
   nPos:=Ascan(aRegistro,{|x| x[2] == QRY->GCZ_CODCON+"-"+QRY->GA9_NREDUZ}) 
   If nPos == 0
    AADD(aRegistro, {0, QRY->GCZ_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCZ_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GE5_DESPRO,; 
    IIf(cID = "0", nCusPro, 0), ;
    IIf(cID = "0", nVndPro, 0), ;
    IIf(cID = "0", nVndPro - nCusPro, 0), ;
    IIf(cID = "0", ((nVndPro / nCusPro) - 1) * 100, 0), ;
    QRY->GBI_TIPO, ;
    IIf(cID = "0", QRY->QRY_QTDDES, 0),;
    IIf(cID = "1", nCusPro, 0), ;
    IIf(cID = "1", nVndPro, 0), ;
    IIf(cID = "1", nVndPro - nCusPro, 0), ;
    IIf(cID = "1", ((nVndPro / nCusPro) - 1) * 100, 0), ;
    IIf(cID = "1", QRY->QRY_QTDDES, 0)}) 
   Else
    aRegistro[nPos, IIf(cID = "1", 11, 5)] += nCusPro
    aRegistro[nPos, IIf(cID = "1", 12, 6)] += nVndPro
    aRegistro[nPos, IIf(cID = "1", 13, 7)] += nVndPro - nCusPro
    aRegistro[nPos, IIf(cID = "1", 14, 8)] += ((nVndPro / nCusPro) - 1) * 100
    aRegistro[nPos, IIf(cID = "1", 15,10)] += QRY->QRY_QTDDES
   EndIf              
   If cID = "1" 
    nQMed += QRY->QRY_QTDDES
    nCMed += nCusPro
    nVMed += nVndPro
   Else
    nQMat += QRY->QRY_QTDDES
    nCMat += nCusPro
    nVMat += nVndPro
   EndIf         
  EndIF

  nQDesp += QRY->QRY_QTDDES
  nCDesp += nCusPro
  nVDesp += nVndPro
  nQPlan += QRY->QRY_QTDDES
  nCPlan += nCusPro
  nVPlan += nVndPro 
  nQConv += QRY->QRY_QTDDES
  nCConv += nCusPro
  nVConv += nVndPro
  nQGera += QRY->QRY_QTDDES  
  nCGera += nCusPro
  nVGera += nVndPro

  QRY->(dbSkip())

 EndDo   
 If MV_PAR09 == 1 // Analํtico
  GeraTT(1)
  GeraTT(2)
  GeraTT(3)
 EndIF 
 GeraTT(9) 
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
 SetRegua(len(aRegistro))
 cConvenio:=""
 cPlano:=""
 cID:=""

 For iConta := 1 to len(aRegistro)
    
  If lAbortPrint
     @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
     Exit
  Endif
  
  If aRegistro[iConta, 10] = 0 .AND. aRegistro[iConta, 15] = 0
   loop
  endif 
  
  If nLin > nMaxLin
     Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)       
     nLin := 9
     cID:=""
  Endif
  If MV_PAR09 == 1 // Analํtico 
   If cConvenio <> aRegistro[iConta, 2] .and. !Empty(aRegistro[iConta, 2])
    nLin++   
    @nLin, 000 PSAY aRegistro[iConta, 2]
    nLin++    
    cConvenio := aRegistro[iConta, 2]
   EndIF 
 
   If cPlano <> aRegistro[iConta, 3] .and. !Empty(aRegistro[iConta, 3])
    nLin++   
    @nLin, 005 PSAY aRegistro[iConta, 3]
    nLin++    
    cPlano:=aRegistro[iConta, 3]
   EndIF 

   If cID <> aRegistro[iConta, 9] .and. !Empty(aRegistro[iConta, 9]) .and. aRegistro[iConta, 1] == 0
    @nLin, 000 PSAY IIf(aRegistro[iConta, 9] == "0", STR0015, STR0016)
    nLin++    
    cID:=aRegistro[iConta, 9]
   EndIF 
 
   @nLin, 010 PSAY SubStr(aRegistro[iConta, 4], 1, 50)     
   @nLin, 062 PSAY StrZero(aRegistro[iConta, 10], 6)
   @nLin, 069 PSAY Transform(aRegistro[iConta, 5]   ,"@E 9,999,999.99")  
   @nLin, 085 PSAY Transform(aRegistro[iConta, 6]   ,"@E 9,999,999.99")  
   @nLin, 100 PSAY Transform(aRegistro[iConta, 6] - aRegistro[iConta, 5],"@E 9,999,999.99")    
   @nLin, 115 PSAY Transform(((aRegistro[iConta, 6] / aRegistro[iConta, 5]) - 1) * 100  ,"@E 99999.99")+"%"    
  Else   // Sint้tico                
   @nLin, 020 PSAY IIf(aRegistro[iConta, 1] == 0, aRegistro[iConta, 2], aRegistro[iConta, 4])
   // Materiais
   @nLin, 052 PSAY StrZero(aRegistro[iConta, 10], 6)
   @nLin, 060 PSAY Transform(aRegistro[iConta, 5]   ,"@E 9,999,999.99")  
   @nLin, 074 PSAY Transform(aRegistro[iConta, 6]   ,"@E 9,999,999.99")  
   @nLin, 088 PSAY Transform(aRegistro[iConta, 6] - aRegistro[iConta, 5],"@E 9,999,999.99")    
   // Medicamentos
   @nLin, 140 PSAY StrZero(aRegistro[iConta, 15], 6)
   @nLin, 148 PSAY Transform(aRegistro[iConta,11]   ,"@E 9,999,999.99")  
   @nLin, 162 PSAY Transform(aRegistro[iConta,12]   ,"@E 9,999,999.99")  
   @nLin, 176 PSAY Transform(aRegistro[iConta,12] - aRegistro[iConta,11]  ,"@E 9,999,999.99")    
  EndIf
 	IncRegua()
  nLin +=IIf(aRegistro[iConta, 1] == 0, 1, 2)   // Salta linhas quando for totalizador 
  
 Next
 If MV_PAR09 == 1 // Analํtico 
  nLin += 2            

  if nQMat > 0 
   @nLin, 000 PSAY STR0017   
   @nLin, 062 PSAY StrZero(nQMat, 6)
   @nLin, 069 PSAY Transform(nCMat,"@E 9,999,999.99")  
   @nLin, 085 PSAY Transform(nVMat,"@E 9,999,999.99")  
   @nLin, 100 PSAY Transform(nVMat - nCMat,"@E 9,999,999.99")    
   @nLin, 115 PSAY Transform(((nVMat / nCMat) - 1) * 100,"@E 99999.99")+"%"    
   nLin += 1
  EndIf

  If nQMed > 0 
   @nLin, 000 PSAY STR0018
   @nLin, 062 PSAY StrZero(nQMed, 6)
   @nLin, 069 PSAY Transform(nCMed,"@E 9,999,999.99")  
   @nLin, 085 PSAY Transform(nVMed,"@E 9,999,999.99")  
   @nLin, 100 PSAY Transform(nVMed - nCMed,"@E 9,999,999.99")    
   @nLin, 115 PSAY Transform(((nVMed / nCMed) - 1) * 100,"@E 99999.99")+"%"    
   nLin += 2
  EndIf
  @nLin, 000 PSAY STR0010  
  @nLin, 062 PSAY StrZero(nQMat+nQMed, 6)
  @nLin, 069 PSAY Transform(nCMat+nCMed,"@E 9,999,999.99")  
  @nLin, 085 PSAY Transform(nVMat+nVMed,"@E 9,999,999.99")  
  @nLin, 100 PSAY Transform((nVMat - nCMat)+(nVMed - nCMed),"@E 9,999,999.99")    
  @nLin, 115 PSAY Transform((((nVMat+nVMed) / (nCMat+nCMed)) - 1) * 100  ,"@E 99999.99")+"%"    
 EndIf         


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Finaliza a execucao do relatorio...                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
SET DEVICE TO SCREEN

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()
Return   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณGeraTT    บ Autor ณ Paulo C้sar        บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para Gerar total no vetor                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GeraTT(nTipo)

Do Case 
 Case nTipo == 1
 	If nQDesp <> 0 
   AADD(aRegistro, {nTipo, " ", " ", IIf(cID = "0", "Total Materiais", "Total Medicamentos"), nCDesp, nVDesp,  nVDesp - nCDesp, ((nVDesp / nCDesp) - 1) * 100  , cID, nQDesp, 0, 0, 0, 0, 0}) 
 	 nVDesp  := 0
 	 nCDesp  := 0 
 	 nQDesp  := 0
  EndIf
 Case nTipo == 2  
 	If nQPlan <> 0
   AADD(aRegistro, {nTipo, " ", " ", "Total Plano", nCPlan, nVPlan,  nVPlan - nCPlan, ((nVPlan / nCPlan) - 1) * 100  , cID, nQPlan, 0, 0, 0, 0, 0}) 
 	 nVPlan  := 0
 	 nCPlan  := 0 
 	 nQPlan  := 0
  EndIf
 Case nTipo == 3
 	If nQConv <> 0
   AADD(aRegistro, {nTipo, " ", " ", "Total Convenio", nCConv, nVConv,  nVConv - nCConv, ((nVConv / nCConv) - 1) * 100  , cID, nQConv, 0, 0, 0, 0, 0}) 
 	 nVConv  := 0
 	 nCConv  := 0 
 	 nQConv  := 0
  EndIf
 Case nTipo == 9
 	If nQGera <> 0
   If MV_PAR09 <> 1 // Analํtico
    /*AADD(aRegistro, {nTipo, " ", " ", "Total Geral", ;
    IIf(cID = "0", nCGera, 0), ;
    IIf(cID = "0", nVGera, 0), ;
    IIf(cID = "0", nVGera - nCGera, 0), ;
    IIf(cID = "0", ((nVGera / nCGera) - 1) * 100, 0), ;
    QRY->GBI_TIPO, ;
    IIf(cID = "0", nQGera, 0),;
    IIf(cID = "1", nCMed, 0), ;
    IIf(cID = "1", nVMed, 0), ;
    IIf(cID = "1", nVMed - nCMed, 0), ;
    IIf(cID = "1", ((nVMed / nCMed) - 1) * 100, 0), ;
    IIf(cID = "1", nQMed, 0)})    */
//   Else
    AADD(aRegistro, {nTipo, " ", " ", "Total Geral", ;
    nCMat, ;
    nVMat, ;
    nVMat - nCMat, ;
    ((nVMat / nCMat) - 1) * 100, ;
    QRY->GBI_TIPO, ;
    nQMat, ;
    nCMed, ;
    nVMed, ;
    nVMed - nCMed, ;
    ((nVMed / nCMed) - 1) * 100, ;
    nQMed})   
   EndIf 
  EndIf  
EndCase

Return 

