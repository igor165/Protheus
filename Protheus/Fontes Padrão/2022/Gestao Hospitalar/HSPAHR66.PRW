#INCLUDE "HSPAHR66.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR66  บ Autor ณ Paulo C้sar        บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio FATURAMENTO POR SETOR E GRUPO DE DESPESAS        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
                                                                               
Function HSPAHR66()

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
Private nomeprog     	:= "HSPAHR66" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        	:= 18
Private aReturn      	:= {STR0004, 1, STR0005, 2, 2, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey     	:= 0
Private cbtxt        	:= Space(10)
Private cbcont       	:= 00
Private CONTFL       	:= 01
Private m_pag        	:= 01
Private wnrel        	:= nomeprog
Private cPerg        	:= "HSPR66"
Private nAgrupar     	:= 0
Private cString  					:= ""

Private cCODIMP 						:= ""
Private nMaxLin 						:= 0 // quantidade maxima de linhas p/ impressao

Private cCompt_De    := "", cCompt_Ate := ""
Private cDtAtn_De    := "", cDtAtn_Ate := ""
Private nGuias       
Private cConv_De     := "", cConv_Ate := ""
Private cPlan_De     := "", cPlan_Ate := ""
Private cSeto_De     := "", cSeto_Ate := ""
Private cGrpD_De     := "", cGrpD_Ate := ""
Private nTpAtend     
Private nTpRelat     
Private nResumo      

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                         ณ
 ณ MV_PAR01	Da Competencia:                                           ณ
 ณ MV_PAR02	At้ Competencia:                                          ณ
 ณ MV_PAR03	Da Data Atendim:                                          ณ
 ณ MV_PAR04	At้ Data Atendim:                                         ณ
 ณ MV_PAR05	Guias:                                                    ณ
 ณ MV_PAR06	De Conv๊nio:                                              ณ
 ณ MV_PAR07	Para Conv๊nio:                                            ณ
 ณ MV_PAR08	Do Plano:                                                 ณ
 ณ MV_PAR09	At้ Plano:                                                ณ
 ณ MV_PAR10	Do Setor:        					                                    ณ 
 ณ MV_PAR11	At้ Setor:                  					                         ณ
 ณ MV_PAR12	Do Grupo de Despesa:                  					               ณ
 ณ MV_PAR13	Ate Grupo de Despesa:                  					              ณ
 ณ MV_PAR14	Tipo de Atendimento:                                      ณ
 | MV_PAR15 Tipo de Relatorio                                         |
 | MV_PAR16 Resumo ?                                                  | 
 | MV_PAR17 Impressora ?                                              |
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
                           
         
If !Pergunte(cPerg,.T.)
	return
EndIf                

cCompt_De  := MV_PAR01
cCompt_Ate := MV_PAR02
cDtAtn_De  := MV_PAR03
cDtAtn_Ate := MV_PAR04
nGuias     := MV_PAR05
cConv_De   := MV_PAR06
cConv_Ate  := MV_PAR07
cPlan_De   := MV_PAR08
cPlan_Ate  := MV_PAR09
cSeto_De   := MV_PAR10
cSeto_Ate  := MV_PAR11
cCCus_De   := MV_PAR12
cCCus_Ate  := MV_PAR13
cGrpD_De   := MV_PAR14
cGrpD_Ate  := MV_PAR15
nTpAtend   := MV_PAR16
nTpRelat   := MV_PAR17
nResumo    := MV_PAR18

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2      
                                              
If nTpRelat == 1 // Analํtico
 Titulo := Titulo + " - Analํtico"   
 nomeprog := nomeprog + '_Analitico'
 Cabec2	:=	STR0015 //"Conv๊nio             Plano                           Despesa                         Qtde         Valor        %"
Else
 Titulo := Titulo + " - Sint้tico"
 nomeprog := nomeprog + '_Sintetico'
 Cabec2	:=	STR0010 //"Conv๊nio             Plano                           Grupo de despesa                Qtde         Valor        %"  
EndIf 

/*								1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
Cabec1	:=	STR0014 //"Setor"
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Paulo C้sar        บ Data ณ  28/11/07   บฑฑ
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
 Local iConta       := 0   
 Local nPos         := 0
 Local cTipoResumo  := ""
 Local   cGD5 :=""
 Local cGD6 := ""
 Local cGD7 := ""
 
 Private lImpCCu    := !(Empty(cCCus_De)) .OR. !(Empty(cCCus_Ate))
 Private cSetor     := ""
	Private cPlano     := ""               
	Private cConvenio  := ""
	Private cID        := ""
	Private cGrupoDesp := ""

	Private nVDespesa  := 0
	Private nVPlano    := 0
	Private nVConvenio := 0
	Private nVSetor    := 0			
	Private nVTotal    := 0			

	Private nQDespesa  := 0
	Private nQPlano    := 0
	Private nQConvenio := 0
	Private nQSetor    := 0			
	Private nQTotal    := 0			
	
 Private aRegistro  := {}
 
  cGD5 := IIF(nGuias == 1, "GD5", "GE5")
 cGD6 := IIF(nGuias == 1, "GD6", "GE6")
 cGD7 := IIF(nGuias == 1, "GD7", "GE7")
 
 
 
 cSQL := "SELECT  'GE5' ID, " + IIf(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC GCS_NOMLOC, GA9.GA9_NREDUZ GA9_NREDUZ, GCM.GCM_DESPLA GCM_DESPLA, "+ cGD5 + "_DESPRO AS QRY_DESPRO, GAW.GAW_DESC, SUM("+ cGD5 + "_QTDDES) QRY_QTDDES, "
 cSQL += "         SUM(" + HS_FVALDES(cGD5) + ") QRY_VALPAC, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA "
 cSQL += " FROM "+ RetSQLName(cGD5) + " " + cGD5

 cSQL += " JOIN "+ RetSQLName("GCZ") +" GCZ "
 cSQL += "                      ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' " 
 cSQL += "                     AND GCZ.GCZ_NRSEQG = "+ cGD5 + "_NRSEQG "
If  nGuias == 2
cSQL += "                     AND GCZ_STATUS > '2' "
elseif nGuias == 1
cSQL += "                     AND GCZ_STATUS <= '2' "
Endif
 DO CASE
  CASE nTpAtend ==  1  // Interna็ใo
   cSQL += "                     AND GCZ_ATENDI = '0' "
  CASE nTpAtend ==  2  // Ambulat๓rio
   cSQL += "                     AND GCZ_ATENDI = '1' "
  CASE nTpAtend ==  3  // Pronto Atendimento
   cSQL += "                     AND GCZ_ATENDI = '2' "
  CASE nTpAtend ==  4  // Todos
   cSQL += "                     AND GCZ_ATENDI < '3' "
 ENDCASE     
 cSQL += "                     AND GCZ.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GA9") +" GA9 "
 cSQL += "                      ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' "
 cSQL += "                     AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
 cSQL += "                     AND GA9.GA9_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_Ate + "' "  
 cSQL += "                     AND GA9.D_E_L_E_T_ <> '*' " 

 cSQL += "      JOIN "+ RetSQLName("GCM") +" GCM "
 cSQL += "                      ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' "
 cSQL += "                     AND GCM.GCM_CODCON = GCZ.GCZ_CODCON " 
 cSQL += "                     AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
 cSQL += "                     AND GCM.D_E_L_E_T_ <> '*' "                                         
 cSQL += "                     AND GCM_CODPLA BETWEEN '" + cPlan_De + "' AND '" + cPlan_Ate + "' "  

 cSQL += "      JOIN "+ RetSQLName("SB1") +" SB1 "
 cSQL += "                     ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
 cSQL += "                     AND SB1.B1_COD = "+ cGD5 + "_CODDES "
 cSQL += "                     AND SB1.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GBI") +" GBI  "
 cSQL += "                     ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' "
 cSQL += "                     AND GBI.GBI_PRODUT = SB1.B1_COD "
 cSQL += "                     AND GBI.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GAW") +" GAW "
 cSQL += "                     ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' "
 cSQL += "                     AND GAW.GAW_CODGDE = GBI.GBI_CODGDE "
 cSQL += "                     AND GAW.D_E_L_E_T_ <> '*' 
 cSQL += "                     AND GAW.GAW_CODGDE BETWEEN '" + cGrpD_De + "' AND '" + cGrpD_Ate + "' "   
 
 cSQL += "      JOIN "+ RetSQLName("GCS") +" GCS "
 cSQL += "                      ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' "
 cSQL += "                     AND GCS.GCS_CODLOC = "+ cGD5 + "_CODLOC "
 cSQL += "                     AND GCS.D_E_L_E_T_ <> '*' "      
 If !(lImpCCu)
  cSQL += "                     AND GCS_CODLOC BETWEEN '" + cSeto_De + "' AND '" + cSeto_Ate + "' "   
 Else
  cSQL += "                     AND GCS_CODCCU BETWEEn '" + cCCus_De + "' AND '" + cCCus_Ate + "' "
 EndIf
 
 If nGuias == 2 //Guias Faturadas
  cSQL += "      JOIN "+ RetSQLName("GAT") +" GAT "
  cSQL += "                      ON GAT.GAT_FILIAL = '" + xFilial("GAT") + "' "
  cSQL += "                     AND GAT.GAT_CODCON = GCZ.GCZ_CODCON "
  cSQL += "                     AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
// Alterada a query para verificar se banco eh sql server, se for entra no IF abaixo.
  If "MSSQL" $ Upper(TCGETDB())
  	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
  	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
  Else 
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
  Endif
//  cSQL += "                     AND GAT.GAT_MESREF BETWEEN '" + cCompt_De +"' AND '" + cCompt_Ate  + "' "
  cSQL += "                     AND GAT.D_E_L_E_T_ <> '*' "  
 ElseIf nGuias == 1 //Guias Abertas
  cSQL += "      JOIN "+ RetSQLName("GCY") +" GCY "
  cSQL += "                      ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' "
  cSQL += "                     AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
  cSQL += "                     AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += "                     AND GCY.GCY_DATATE BETWEEN '" + DTOS(cDtAtn_De) + "' AND '" + DTOS(cDtAtn_Ate) + "' "
 EndIf                      
 
 cSQL += "WHERE  "+ cGD5 + "_FILIAL = '" + xFilial(cGD5) + "' " 
 cSQL += "AND "+ cGD5 + ".D_E_L_E_T_ <> '*' " 
 cSQL += "GROUP BY " + IIf(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC, GA9.GA9_NREDUZ, GCM.GCM_DESPLA, GAW.GAW_DESC, "+ cGD5 + "_DESPRO, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA "

 cSQL += "UNION ALL "

 cSQL += "SELECT  'GE6' ID, " + IIf(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC GCS_NOMLOC, GA9.GA9_NREDUZ GA9_NREDUZ, GCM.GCM_DESPLA GCM_DESPLA, "+ cGD6 + "_DESTXC AS QRY_DESPRO, GAW.GAW_DESC, SUM("+ cGD6 + "_QTDDES) QRY_QTDDES, "
 cSQL += "         SUM(" + HS_FVALDES(cGD6) + ") QRY_VALPAC, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA "
 cSQL += "FROM "+ RetSQLName(cGD6 ) + " " + cGD6
 cSQL += "      JOIN "+ RetSQLName("GCZ") +" GCZ "
 cSQL += "                      ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' " 
 cSQL += "                     AND GCZ.GCZ_NRSEQG = "+ cGD6 + "_NRSEQG "
If  nGuias == 2
cSQL += "                     AND GCZ_STATUS > '2' "
elseif nGuias == 1
cSQL += "                     AND GCZ_STATUS <= '2' "
Endif
 DO CASE
  CASE nTpAtend ==  1  // Interna็ใo
   cSQL += "                     AND GCZ_ATENDI = '0' "
  CASE nTpAtend ==  2  // Ambulat๓rio
   cSQL += "                     AND GCZ_ATENDI = '1' "
  CASE nTpAtend ==  3  // Pronto Atendimento
   cSQL += "                     AND GCZ_ATENDI = '2' "
  CASE nTpAtend ==  4  // Todos
   cSQL += "                     AND GCZ_ATENDI < '3' "
 ENDCASE     
 cSQL += "                     AND GCZ.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GA9") +" GA9 "
 cSQL += "                      ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' "
 cSQL += "                     AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "                              
 cSQL += "                     AND GA9.GA9_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_Ate + "' "   
 cSQL += "                     AND GA9.D_E_L_E_T_ <> '*' " 

 cSQL += "      JOIN "+ RetSQLName("GCM") +" GCM "
 cSQL += "                      ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' "
 cSQL += "                     AND GCM.GCM_CODCON = GCZ.GCZ_CODCON " 
 cSQL += "                     AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
 cSQL += "                     AND GCM.D_E_L_E_T_ <> '*' "                                         
 cSQL += "                     AND GCM_CODPLA BETWEEN '" + cPlan_De + "' AND '" + cPlan_Ate + "' "  

 cSQL += "      JOIN "+ RetSQLName("GAA") +" GAA "
 cSQL += "                      ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' "
 cSQL += "                     AND GAA.GAA_CODTXD = "+ cGD6 + "_CODDES
 cSQL += "                     AND GAA.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GCS") +" GCS "
 cSQL += "                      ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' "
 cSQL += "                     AND GCS.GCS_CODLOC = "+ cGD6 + "_CODLOC "
 cSQL += "                     AND GCS.D_E_L_E_T_ <> '*' "                                         
 If !(lImpCCu)
  cSQL += "                     AND GCS_CODLOC BETWEEN '" + cSeto_De + "' AND '" + cSeto_Ate + "' "   
 Else
  cSQL += "                     AND GCS_CODCCU BETWEEn '" + cCCus_De + "' AND '" + cCCus_Ate + "' "
 EndIf
 
 cSQL += "      JOIN "+ RetSQLName("GAW") +" GAW "
 cSQL += "                      ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' "
 cSQL += "                     AND GAW.GAW_CODGDE = GAA.GAA_CODGDE "
 cSQL += "                     AND GAW.D_E_L_E_T_ <> '*' "                                              
 cSQL += "                     AND GAW.GAW_CODGDE BETWEEN '" + cGrpD_De + "' AND '" + cGrpD_Ate + "' "    
  
If nGuias == 2 //Guias Faturadas
  cSQL += "      JOIN "+ RetSQLName("GAT") +" GAT "
  cSQL += "                      ON GAT.GAT_FILIAL = '" + xFilial("GAT") + "' "
  cSQL += "                     AND GAT.GAT_CODCON = GCZ.GCZ_CODCON "
  cSQL += "                     AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
// Alterada a query para verificar se banco eh sql server, se for entra no IF abaixo.
   If "MSSQL" $ Upper(TCGETDB())
	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
 Else 
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
Endif
//cSQL += "                     AND GAT.GAT_MESREF BETWEEN '" + cCompt_De +"' AND '" + cCompt_Ate + "' "
//cSQL += "                     AND GAT.GAT_MESREF BETWEEN '" + cCompt_De +"' AND '" + cCompt_Ate + "' "
  cSQL += "                     AND GAT.D_E_L_E_T_ <> '*' " 
 ElseIf nGuias == 1 //Guias Abertas
  cSQL += "      JOIN "+ RetSQLName("GCY") +" GCY "
  cSQL += "                      ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' "
  cSQL += "                     AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
  cSQL += "                     AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += "                     AND GCY.GCY_DATATE BETWEEN '" + DTOS(cDtAtn_De) + "' AND '" + DTOS(cDtAtn_Ate) + "' "
 EndIf                                                                     


 cSQL += "WHERE  "+ cGD6 + "_FILIAL = '" + xFilial(cGD6) + "' " 
 cSQL += "AND "+ cGD6 + ".D_E_L_E_T_ <> '*' " 
 cSQL += "GROUP BY " + IIf(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC, GA9.GA9_NREDUZ, GCM.GCM_DESPLA, GAW.GAW_DESC, "+ cGD6 + "_DESTXC, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA "

 cSQL += "UNION ALL "

 cSQL += "SELECT  'GE7' ID, " + IIf(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC GCS_NOMLOC, GA9.GA9_NREDUZ GA9_NREDUZ, GCM.GCM_DESPLA GCM_DESPLA, "+ cGD7 + "_DESPRT AS QRY_DESPRO, GAW.GAW_DESC, SUM("+ cGD7 + "_QTDDES) QRY_QTDDES, "
 cSQL += "         SUM(" + HS_FVALDES( cGD7 ) + ") QRY_VALPAC, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA  "
 cSQL += "FROM "+ RetSQLName(cGD7) +" " + cGD7
  cSQL += "      JOIN "+ RetSQLName("GCZ") +" GCZ "
 cSQL += "                      ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' " 
 cSQL += "                     AND GCZ.GCZ_NRSEQG = "+ cGD7 + "_NRSEQG "
If  nGuias == 2
cSQL += "                     AND GCZ_STATUS > '2' "
elseif nGuias == 1
cSQL += "                     AND GCZ_STATUS <= '2' "
Endif
 DO CASE
  CASE nTpAtend ==  1  // Interna็ใo
   cSQL += "                     AND GCZ_ATENDI = '0' "
  CASE nTpAtend ==  2  // Ambulat๓rio
   cSQL += "                     AND GCZ_ATENDI = '1' "
  CASE nTpAtend ==  3  // Pronto Atendimento
   cSQL += "                     AND GCZ_ATENDI = '2' "
  CASE nTpAtend ==  4  // Todos
   cSQL += "                     AND GCZ_ATENDI < '3' "
 ENDCASE     
 cSQL += "                     AND GCZ.D_E_L_E_T_ <> '*' "

 cSQL += "      JOIN "+ RetSQLName("GA9") +" GA9 "
 cSQL += "                      ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' "
 cSQL += "                     AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "                                   
 cSQL += "                     AND GA9.GA9_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_Ate + "' "   
 cSQL += "                     AND GA9.D_E_L_E_T_ <> '*' " 

 cSQL += "      JOIN "+ RetSQLName("GCM") +" GCM "
 cSQL += "                      ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' "
 cSQL += "                     AND GCM.GCM_CODCON = GCZ.GCZ_CODCON " 
 cSQL += "                     AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
 cSQL += "                     AND GCM.D_E_L_E_T_ <> '*' "                                         
 cSQL += "                     AND GCM_CODPLA BETWEEN '" + cPlan_De + "' AND '" + cPlan_Ate + "' "  

 cSQL += "      JOIN "+ RetSQLName("GA7") +" GA7 "
 cSQL += "                      ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' "
 cSQL += "                     AND GA7.GA7_CODPRO = "+ cGD7 + "_CODDES "
 cSQL += "                     AND GA7.D_E_L_E_T_ <> '*' "                                

 cSQL += "      JOIN "+ RetSQLName("GCS") +" GCS "
 cSQL += "                      ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' "
 cSQL += "                     AND GCS.GCS_CODLOC = "+ cGD7 + "_CODLOC "
 cSQL += "                     AND GCS.D_E_L_E_T_ <> '*' "      
 cSQL += "                     AND GCS_CODLOC BETWEEN '" + cSeto_De + "' AND '" + cSeto_Ate + "' "   
 If !(lImpCCu)
  cSQL += "                     AND GCS_CODLOC BETWEEN '" + cSeto_De + "' AND '" + cSeto_Ate + "' "   
 Else
  cSQL += "                     AND GCS_CODCCU BETWEEn '" + cCCus_De + "' AND '" + cCCus_Ate + "' "
 EndIf
 
 cSQL += "      JOIN "+ RetSQLName("GAW") +" GAW "
 cSQL += "                      ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' "
 cSQL += "                     AND GAW.GAW_CODGDE = GA7.GA7_CODGDE "
 cSQL += "                     AND GAW.D_E_L_E_T_ <> '*' " 
 cSQL += "                     AND GAW.GAW_CODGDE BETWEEN '" + cGrpD_De + "' AND '" + cGrpD_Ate + "' "   
 
 If nGuias == 2 // Guias Faturadas
  cSQL += "      JOIN "+ RetSQLName("GAT") +" GAT "
  cSQL += "                      ON GAT.GAT_FILIAL = '" + xFilial("GAT") + "' "
  cSQL += "                     AND GAT.GAT_CODCON = GCZ.GCZ_CODCON "
  cSQL += "                     AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
// Alterada a query para verificar se banco eh sql server, se for entra no IF abaixo.
  If "MSSQL" $ Upper(TCGETDB())
  	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
  	cSQL +="			   "+"AND SUBSTRING(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
Else 
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,1,2) BETWEEN '"+ Substr(cCompt_De,1,2) +"' AND '"+Substr(cCompt_Ate,1,2) +"'  "
  	cSQL +="			   "+"AND SUBSTR(GAT.GAT_MESREF,4,2) BETWEEN '"+ Substr(cCompt_De,4,2) +"' AND '"+ Substr(cCompt_Ate,4,2) +"'  "
Endif
//  cSQL += "                     AND GAT.GAT_MESREF BETWEEN '" + cCompt_De +"' AND '" + cCompt_Ate + "' "
  cSQL += "                     AND GAT.D_E_L_E_T_ <> '*' " 
 ElseIf nGuias == 1 //Guias Abertas
  cSQL += "      JOIN "+ RetSQLName("GCY") +" GCY "
  cSQL += "                      ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' "
  cSQL += "                     AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
  cSQL += "                     AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += "                     AND GCY.GCY_DATATE BETWEEN '" + DTOS(cDtAtn_De) + "' AND '" + DTOS(cDtAtn_Ate) + "' "
 EndIf                      
 
 cSQL += "WHERE  "+ cGD7 + "_FILIAL = '" + xFilial(cGD7) + "' " 
 cSQL += "AND "+ cGD7 + ".D_E_L_E_T_ <> '*'  "                                                    
 cSQL += "GROUP BY " + IIF(lImpCCu, "GCS.GCS_CODCCU, ", "") + "GCS.GCS_NOMLOC, GA9.GA9_NREDUZ, GCM.GCM_DESPLA, GAW.GAW_DESC, "+ cGD7 + "_DESPRT, GCS.GCS_CODLOC, GA9.GA9_CODCON, GCM.GCM_CODPLA "
 cSQL += "ORDER BY " + IIF(lImpCCu, "GCS_CODCCU, ", "") + "GCS_NOMLOC, GA9_NREDUZ, GCM_DESPLA, ID "
 
 cSql := ChangeQuery(cSql)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 If Eof()
  HS_MsgInf(STR0016, STR0009, STR0003) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Procedimento Realizados"
  DBCloseArea()
  Return 
 Endif                                                   

 aRegistro:={}   
 cId := QRY->GAW_DESC      
 cSetor:=QRY->GCS_NOMLOC    
 cConvenio:=QRY->GA9_NREDUZ   
 cPlano:=QRY->GCM_DESPLA

 While !EOF()
  If nTpRelat == 1 // Analํtico
   If cId <> QRY->ID
    GeraTT(1)  // Totaliza Despesas
    cId := QRY->ID
   EndIf   
   
   If cPlano <> QRY->GCM_DESPLA 
    GeraTT(1) // Totaliza Despesas
    GeraTT(2) // Totaliza Plano
    cId := QRY->ID
    cPlano:=QRY->GCM_DESPLA
   EndIF  
 
   If cConvenio <> QRY->GA9_NREDUZ
    GeraTT(1) // Totaliza Despesas
    GeraTT(2) // Totaliza Plano   
    GeraTT(3) // Totaliza Convenio
    cId := QRY->ID
    cPlano:=QRY->GCM_DESPLA
    cConvenio:=QRY->GA9_NREDUZ
   EndIF 
   if cSetor <> QRY->GCS_NOMLOC                           
    GeraTT(1) // Totaliza Despesas
    GeraTT(2) // Totaliza Plano     
    GeraTT(3) // Totaliza Convenio
    GeraTT(4) // Totaliza Setor                 
    cId := QRY->ID
    cPlano:=QRY->GCM_DESPLA
    cConvenio:=QRY->GA9_NREDUZ   
    cSetor:=QRY->GCS_NOMLOC
   EndIF                                                                                                                                                                                                                 
   If lImpCCu
    AADD(aRegistro, {0,QRY->GCS_CODLOC+"-"+QRY->GCS_NOMLOC, QRY->GA9_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCM_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GAW_DESC, QRY->QRY_DESPRO, QRY->QRY_QTDDES, QRY->QRY_VALPAC, 0, 0, QRY->ID, QRY->GCS_CODCCU}) 
   Else
    AADD(aRegistro, {0,QRY->GCS_CODLOC+"-"+QRY->GCS_NOMLOC, QRY->GA9_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCM_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GAW_DESC, QRY->QRY_DESPRO, QRY->QRY_QTDDES, QRY->QRY_VALPAC, 0, 0, QRY->ID})    
   EndIf
  Else  // Sint้tico
   If cPlano <> QRY->GCM_DESPLA 
    GeraTT(1)              
    GeraTT(2)           
    cId := QRY->GAW_DESC
    cPlano:=QRY->GCM_DESPLA
   EndIF  
   
   If cConvenio <> QRY->GA9_NREDUZ
    GeraTT(2)           
    GeraTT(3)   
    cId := QRY->GAW_DESC   
    cPlano:=QRY->GCM_DESPLA    
    cConvenio:=QRY->GA9_NREDUZ
   EndIF 

   if cSetor <> QRY->GCS_NOMLOC                           
    GeraTT(1)                 
    GeraTT(2)           
    GeraTT(3)   
    GeraTT(4)                 
    cId := QRY->GAW_DESC   
    cPlano:=QRY->GCM_DESPLA    
    cConvenio:=QRY->GA9_NREDUZ
    cSetor:=QRY->GCS_NOMLOC
   EndIF           
   nPos:=Ascan(aRegistro,{|x| x[2]+x[3]+x[4]+x[5] == QRY->GCS_CODLOC+"-"+QRY->GCS_NOMLOC+QRY->GA9_CODCON+"-"+QRY->GA9_NREDUZ+QRY->GCM_CODPLA+"-"+QRY->GCM_DESPLA+QRY->GAW_DESC}) 
   If nPos == 0
    If lImpCCu
     AADD(aRegistro, {0,QRY->GCS_CODLOC+"-"+QRY->GCS_NOMLOC, QRY->GA9_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCM_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GAW_DESC, QRY->QRY_DESPRO, QRY->QRY_QTDDES, QRY->QRY_VALPAC, 0, 0, QRY->ID, QRY->GCS_CODCCU}) 
    Else
     AADD(aRegistro, {0,QRY->GCS_CODLOC+"-"+QRY->GCS_NOMLOC, QRY->GA9_CODCON+"-"+QRY->GA9_NREDUZ, QRY->GCM_CODPLA+"-"+QRY->GCM_DESPLA, QRY->GAW_DESC, QRY->QRY_DESPRO, QRY->QRY_QTDDES, QRY->QRY_VALPAC, 0, 0, QRY->ID})    
    EndIf
   Else
    aRegistro[nPos, 8] += QRY->QRY_VALPAC
    aRegistro[nPos, 7] += QRY->QRY_QTDDES
   EndIf
  EndIF

	 nVDespesa  += QRY->QRY_VALPAC
	 nQDespesa  += QRY->QRY_QTDDES
	 nVPlano    += QRY->QRY_VALPAC
	 nQPlano    += QRY->QRY_QTDDES
	 nVConvenio += QRY->QRY_VALPAC
	 nQConvenio += QRY->QRY_QTDDES
	 nVSetor    += QRY->QRY_VALPAC			
	 nQSetor    += QRY->QRY_QTDDES			
	 nVTotal    += QRY->QRY_VALPAC				
	 nQTotal    += QRY->QRY_QTDDES						           
	 cGrupoDesp := QRY->GAW_DESC

  QRY->(dbSkip())

 EndDo
 GeraTT(1) // Totaliza Despesas
 GeraTT(2) // Totaliza Plano     
 GeraTT(3) // Totaliza Convenio
 GeraTT(4) // Totaliza Setor                 
 GeraTT(9) // Total Geral               

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
 SetRegua(len(aRegistro))
 cSetor:=""
 cConvenio:=""
 cPlano:=""

 For iConta := 1 to len(aRegistro)
    
  If lAbortPrint
     @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
     Exit
  Endif
  
  if aRegistro[iConta, 8] = 0
   loop
  endif 
  
  If nLin > nMaxLin
     Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)       
     nLin := 9
  Endif
  
  If aRegistro[iConta, 1] ==  0 

   If cSetor <> aRegistro[iConta, 2] .and. !Empty(aRegistro[iConta, 2])
    If lImpCCu
     @nLin, 000 PSAY aRegistro[iConta, 12] + "-" + HS_INIPADR("CTT", 1, aRegistro[iConta, 12], "CTT_DESC01") + " --> " + aRegistro[iConta, 2]
    Else
     @nLin, 000 PSAY aRegistro[iConta, 2]
    EndIf
    nLin++
    cSetor:=aRegistro[iConta, 2]
   EndIF 

   If cConvenio <> aRegistro[iConta, 3] .and. !Empty(aRegistro[iConta, 3])
    @nLin, 000 PSAY SubStr(aRegistro[iConta, 3],1, 20)
    cConvenio:=aRegistro[iConta, 3]
   EndIF 

   If cPlano <> aRegistro[iConta, 4] .and. !Empty(aRegistro[iConta, 4])
    @nLin, 021 PSAY SubStr(aRegistro[iConta, 4], 1, 30)
    cPlano:=aRegistro[iConta, 4]
   EndIF 
  EndIF
  If nTpRelat == 1 // Analํtico
   @nLin, 052 PSAY SubStr(aRegistro[iConta, 6], 1, 50)
  Else                                        
   if aRegistro[iConta, 1] = 0
    @nLin, 052 PSAY SubStr(aRegistro[iConta, 5], 1, 50)    
   Else                                               
    @nLin, 052 PSAY SubStr(aRegistro[iConta, 6], 1, 50)   
   EndIf 
  EndIf       
  @nLin, 104 PSAY StrZero(aRegistro[iConta, 7]  , 7)
  @nLin, 112 PSAY Transform(aRegistro[iConta, 8]   ,"@E 9,999,999.99")  
  @nLin, 125 PSAY Transform(aRegistro[iConta, 9]   ,"@E 999.99")+"%"    

  If aRegistro[iConta, 1] > 0
   nLin++
  EndIf 

 	IncRegua()
  nLin++                                  
  
Next
 
 For iConta := 1 to len(aRegistro)
  If aRegistro[iConta, 1] = 3  // Convenio
   nPos:=Ascan(aResumo,{|x| x[2]==aRegistro[iConta, 3]}) 
   If nPos <> 0
    aResumo[nPos, 3]+=aRegistro[iConta, 8]        
    aResumo[nPos, 4]:=(aResumo[nPos, 3]/nVTotal)*100    
   else 
    AADD(aResumo, {aRegistro[iConta, 1], aRegistro[iConta, 3], aRegistro[iConta, 8], (aRegistro[iConta, 8]/nVTotal)*100})
   EndIf
  ElseIf aRegistro[iConta, 1] = 0  // Grupo de despesas
   nPos:=Ascan(aResumo,{|x| x[2]==aRegistro[iConta, 5]}) 
   If nPos <> 0
    aResumo[nPos, 3]+=aRegistro[iConta, 8]        
    aResumo[nPos, 4]:=(aResumo[nPos, 3]/nVTotal)*100    
   else 
    AADD(aResumo, {aRegistro[iConta, 1], aRegistro[iConta, 5], aRegistro[iConta, 8], (aRegistro[iConta, 8]/nVTotal)*100})
   EndIf
  EndIf
 Next

 aSort(aResumo,,,{|x,y| x[1] < y[1]})
 
 If nResumo <> 4 // Se selecionado Nenhum no parametro de resumo, nใo imprime.
  @nLin, 000 PSAY Replicate("-", 132)
  nLin ++                            
  cTipoResumo := aResumo[1, 1]
  For iConta := 1 to len(aResumo)
   If (nResumo == 1) .and. (aResumo[iConta, 1] == 1) // Parametro Resumo = Convenio  Registro = Grupo de despesas
    loop
   EndIf 
   If (nResumo == 2) .and. (aResumo[iConta, 1] == 3) // Parametro Resumo = Grupo Despesas  Registro = Convenio
    loop
   EndIf

   If lAbortPrint
     @nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
     Exit
   Endif
  
   If nLin > nMaxLin
     Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)       
     nLin := 9
     aCabecResumo := {.F., .F.}     
   Endif

   If cTipoResumo <> aResumo[iConta, 1] 
    @nLin, 040 PSAY STR0013 //"Total Geral"
    @nLin, 071 PSAY Transform(nVTotal   ,"@E 9,999,999.99")  
    nLin++        
   EndIf
      
   If (aResumo[iConta, 1] ==  0) .and. !aCabecResumo[1]
    @nLin, 040 PSAY Replicate("-", 51)      
    nLin++
    @nLin, 040 PSAY STR0011 //"Grupo de Despesas                     Valor    %"   
    nLin++    
    @nLin, 040 PSAY Replicate("-", 51)      
    nLin++                     
    aCabecResumo[1] := .T.
    cTipoResumo := aResumo[iConta, 1]
   ElseIf (aResumo[iConta, 1] ==  3) .and. !aCabecResumo[2]
    @nLin, 040 PSAY Replicate("-", 51)      
    nLin++
    @nLin, 040 PSAY STR0012 //"Convenio                              Valor    %"
    nLin++
    @nLin, 040 PSAY Replicate("-", 51)      
    nLin++
    aCabecResumo[2] := .T.
    cTipoResumo := aResumo[iConta, 1]    
   EndIf

   @nLin, 040 PSAY aResumo[iConta, 2]
   @nLin, 071 PSAY Transform(aResumo[iConta, 3]   ,"@E 9,999,999.99")  
   @nLin, 084 PSAY Transform(aResumo[iConta, 4]   ,"@E 999.99")+"%"       
   nLin++
 
  Next
  @nLin, 040 PSAY STR0013 //"Total Geral"
  @nLin, 071 PSAY Transform(nVTotal   ,"@E 9,999,999.99")  
  nLin++    
  @nLin, 000 PSAY Replicate("-", 132)  
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
ฑฑบFuno    ณTTQuebra  บ Autor ณ Paulo C้sar        บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para totalizar os agrupamentos do relatorioบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function TTQuebra(nTipo)
Local nConta :=Len(aRegistro)
Local nConta1:=0
Local nTotal :=aRegistro[nConta,8] 
If nTotal <> 0               
 nConta1:=nConta
 nConta--
 Do While (aRegistro[nConta, 1] <> nTipo)                
  if aRegistro[nConta, 1] == (nTipo - 1)
   aRegistro[nConta, 9]:=(aRegistro[nConta, 8]/nTotal)*100
  ElseIf (aRegistro[nConta, 1] > 0) .and. (nTipo == 9)
   aRegistro[nConta, 10]:=(aRegistro[nConta, 8]/nTotal)*100   
  EndIf 
  nConta--                               
  If (nConta <= 0)
   Exit
  EndIf 
 EndDo
 If aRegistro[nConta1, 8] > 0    .and. (aRegistro[nConta1, 9]==0 .and. aRegistro[nConta1, 10]==0)
   aRegistro[nConta1, 9] :=(aRegistro[nConta1, 8]/nTotal)*100
   aRegistro[nConta1, 10]:=(aRegistro[nConta1, 8]/nTotal)*100
  Endif 
EndIf 
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
 	If nVDespesa <> 0 
   AADD(aRegistro, {nTipo, QRY->GCS_NOMLOC, cConvenio, cPlano, cGrupoDesp, "Total Despesa", nQDespesa, nVDespesa, 0, 0})
   TTQuebra(nTipo)                                                                                                           
 	 nVDespesa  := 0
 	 nQDespesa  := 0 
  EndIf
 Case nTipo == 2 
 	If nVPlano <> 0
   AADD(aRegistro, {nTipo, QRY->GCS_NOMLOC, cConvenio, cPlano, cGrupoDesp, "Total Plano", nQPlano, nVPlano, 0, 0})
   TTQuebra(nTipo)                                                                                                           
 	 nVPlano    := 0
 	 nQPlano    := 0
  EndIf
 Case nTipo == 3  
 	If nVConvenio <> 0
   AADD(aRegistro, {nTipo, QRY->GCS_NOMLOC, cConvenio, cPlano, cGrupoDesp, "Total Convenio", nQConvenio, nVConvenio, 0, 0})
   TTQuebra(nTipo)
 	 nVConvenio := 0 
 	 nQConvenio := 0 
  EndIf
 Case nTipo == 4
 	If nVSetor <> 0
   AADD(aRegistro, {nTipo, QRY->GCS_NOMLOC, cConvenio, cPlano, cGrupoDesp, If(lImpCCu, "Total Centro Custo/Setor", "Total Setor"), nQSetor, nVSetor, 0, 0})
   TTQuebra(nTipo)
 	 nVSetor    := 0 
 	 nQSetor    := 0
  EndIf
 Case nTipo == 9
 	If nVTotal <> 0
   AADD(aRegistro, {nTipo, QRY->GCS_NOMLOC, cConvenio, cPlano, cGrupoDesp, "Total Geral", nQTotal, nVTotal,  0, 0})
   TTQuebra(nTipo)   
  EndIf  
EndCase


Return 

