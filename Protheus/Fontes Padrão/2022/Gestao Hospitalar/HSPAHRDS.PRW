#INCLUDE "HSPAHRDS.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDS  บ Autor ณ Daniel Peixoto     บ Data ณ  08/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ESTATISTICA DE OCUPACAO MENSAL                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบBOPS      ณ Luiz Gustavo M. Caloi - 00000099820                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHRDS()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
		 		/*              				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
    				    			   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 Local imprime        := .T.
 Local aOrd 				      := {}    
 Private Titulo       := STR0003 //"Ocupa็ใo Mensal"
 Private Cabec1 	   := ""
 Private Cabec2 	   := ""

 Private cModelo_De   := ""
 Private cModelo_Ate  := ""
 Private dData_De     := ""
 Private dData_Ate    := ""
 Private nAgrup       := 0
 Private nTipRel      := 0

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 80
 Private tamanho      := "P"
 Private nomeprog     := "HSPAHRDS" /* Coloque aqui o nome do programa para impressao no cabecalho */
 Private nTipo        := 18
 Private aReturn      := {STR0006 , 1, STR0007, 2, 2, 1, "", 1}       //"Administracao"###"Zebrado"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRDS" /* Coloque aqui o nome do arquivo usado para impressao em disco */
 Private cPerg        := "HSPRDS"
 Private cString      := ""
 Private cLimDataE    := "" 
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 Private cHorExe    := Substr(Time(), 1, 5) 
 Private nPermLei   := GETMV("MV_PERMLEI")
 If Empty(nPermLei) .Or. Type("nPermLei") <> "N" .Or. nPermLei <= 0
  HS_MsgInf(STR0017, STR0012, STR0003) //"O parโmetro [MV_PERMLEI] referente a quantidade de horas de perman๊ncia mํnima nos leitos, nใo foi encontrado ou estแ invแlido. Verifique!"###"Aten็ใo"###"Ocupa็ใo Mensal"
  Return()
 Endif  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ PARAMETROS                                                         ณ
	//ณ MV_PAR01	Do Tipo Acomodacao                                     			ณ
	//ณ MV_PAR02	Ate Tipo Acomodacao                                    			ณ
	//ณ MV_PAR03	Da Data                                                			ณ
	//ณ MV_PAR04	Ate Data                                               			ณ
	//ณ MV_PAR05	Considera Data Saida 1=Nao  2=Sim                      			ณ
	//ณ MV_PAR06	Agrupado por (1=Modelo 2=Setor)                        			ณ
	//ณ MV_PAR07	Tipo do relatorio (1=Analitico 2=Sintetico)            			ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte(cPerg,.T.)
 	Return()
 EndIf
 
 cModelo_De   := mv_par01
 cModelo_Ate  := mv_par02
 dData_De     := mv_par03
 dData_Ate    := mv_par04
 nDtSaida     := mv_par05
 nAgrup       := mv_par06
 nTipRel      := mv_par07
 
 nMaxLin := HS_MaxLin(cCODIMP)
 wnRel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
 
 If nLastKey == 27
 	Return()
 Endif
 
 Titulo := AllTrim(Titulo) + " - " + IIf(nTipRel == 1, STR0008, STR0009) //"Analํtico"###"Sint้tico"
 Cabec1 := PadR(IIf(nAgrup == 1, STR0004, STR0010), 28) + STR0016 //"Tipo de Acomoda็ใo"###"Setor"###"===Dias ===Dias ===Dias ===Dias ===Taxa ===Taxa"
 Cabec2 := STR0005 //"M๊s/Ano                     Dispon. Indisp.   Ocup.  Ocios.     Ocup.     Ocios."
                   //"                            ===Dias ===Dias ===Dias ===Dias   ===Taxa    ===Taxa"
                   /* 0.........1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
   				               0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */

 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return()
 Endif
 
 nTipo := If(aReturn[4]==1,15,18)
 
 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  08/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1, Cabec2, Titulo)
 Local cChave       := ""
 Local nCha         := 0
 Local nLei         := 0
 Local nMes         := 0 
 Local dData        := CToD("")
 Local cSQL 	     := ""  
 
 Private aMeses     := {}
 Private aDiasMes   := {}
 
 Private aChaves    := {}
 Private aTotCha    := {}
 Private aValCha    := {}
 Private aLeitos    := {}
 Private aValLei    := {}
 Private aMes       := {}
 Private aValTot    := {0, 0, 0}
 
 Private nLin       := nMaxLin + 1
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carregar meses envolvidos, conforme datas das perguntas            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For dData := dData_De to dData_Ate
  If dData > dDataBase
   Exit
  Endif 
  aAdd(aMeses, Substr(DToS(dData), 1, 6))
  If dData == dData_De
   aAdd(aDiasMes, Day(LastDay(dData)) - Day(dData) + 1)
  ElseIf Substr(DToS(dData), 1, 6) == Substr(DToS(dData_Ate), 1, 6)
   aAdd(aDiasMes, Day(dData_Ate))
  Else 
   aAdd(aDiasMes, Day(LastDay(dData)))
  Endif
  
  dData := LastDay(dData)  
 Next dData

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carregar meses envolvidos, conforme datas das perguntas            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nAgrup == 1
  cSQL := "SELECT GAV_MODELO CHAVE, GAV_CODLOC || GAV_QUARTO || GAV_LEITO LEITO " 
 Else
  cSQL := "SELECT GAV_CODLOC CHAVE, GAV_QUARTO || GAV_LEITO LEITO " 
 Endif
 cSQL += "FROM " + RetSQLName("GAV") + " "
 cSQL += "WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*' "
 cSQL += "AND GAV_MODELO BETWEEN '" + cModelo_De + "' AND '" + cModelo_Ate + "' "
 cSQL += "AND GAV_ESTATI = '1' "
 cSQL += "ORDER BY CHAVE, LEITO
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0011, STR0012, STR0003) //"Nenhum leito foi encontrado para a sele็ใo efetuada"###"Aten็ใo"###"Ocupa็ใo Mensal"
  DbCloseArea()
  Return()
 Endif 
  
//1=Qtde total de dias disponiveis no periodo 2=Qtde de dias interditados 3=Qtde de dias utilizados  While !Eof()
 While !Eof()
  If QRY->CHAVE <> cChave
   cChave := QRY->CHAVE
   aAdd(aChaves, cChave)
   aAdd(aValCha, Array(Len(aMeses)))
   For nMes := 1 to Len(aMeses)
    aValCha[Len(aChaves), nMes] := {0, 0, 0} 
   Next nMes
  Endif
  
  aAdd(aLeitos, {QRY->LEITO, QRY->CHAVE})
  aAdd(aValLei, Array(Len(aMeses)))
  For nMes := 1 to Len(aMeses)
   aValLei[Len(aLeitos), nMes] := {aDiasMes[nMes], 0, 0} 
  Next nMes

  DbSkip()
 End
 DbCloseArea()
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Acumula a qtde total de diarias dispon. dos leitos por modelo      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nLei := 1 to Len(aLeitos)

  nCha := aScan(aChaves, aLeitos[nLei, 2])
  For nMes := 1 to Len(aMeses)
   aValCha[nCha, nMes, 1] += aValLei[nLei, nMes, 1]
  Next nMes

 Next nLei 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Obter intervalos de interdicao dos leitos                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nAgrup == 1
  cSQL := "SELECT GAV.GAV_MODELO CHAVE, GF8.GF8_CODLOC || GF8.GF8_QUARTO || GF8.GF8_LEITO LEITO, " 
 Else
  cSQL := "SELECT GAV.GAV_CODLOC CHAVE, GF8.GF8_QUARTO || GF8.GF8_LEITO LEITO, "  
 Endif
 cSQL += "GF8.GF8_DATINI DATAI, GF8.GF8_HORINI HORAI, GF8.GF8_DATFIN DATAF, GF8.GF8_HORFIN HORAF "
 cSQL += "FROM " + RetSQLName("GF8") + " GF8 "
 cSQL += "JOIN " + RetSQLName("GAV") + " GAV "
 cSQL += "ON GAV.GAV_CODLOC = GF8.GF8_CODLOC AND GAV.GAV_QUARTO = GF8.GF8_QUARTO AND GF8.GF8_LEITO = GAV.GAV_LEITO "
 cSQL += "AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' "
 cSQL += "WHERE GF8.GF8_FILIAL = '" + xFilial("GF8") + "' AND GF8.D_E_L_E_T_ <> '*' "
 cSQL += "AND GAV.GAV_MODELO BETWEEN '" + cModelo_De + "' AND '" + cModelo_Ate + "' "
 cSQL += "AND GAV.GAV_ESTATI = '1' "
 cLimDataE := IIF(SUBSTR(DToS(dData_Ate),1,6) < Substr(DTOS(DDATABASE), 1, 6), DTOS(dData_Ate),  DTOS(DDATABASE))
 cSQL += " AND GF8.GF8_DATINI <= '" + cLimDataE + "' "
 cSQL += " AND (GF8.GF8_DATFIN >= '" + DToS(dData_De) + "' OR GF8.GF8_DATFIN = '" + SPACE(8) + "') "
 cSQL += " AND GF8.GF8_DATINI <> GF8.GF8_DATFIN "
 cSQL += "ORDER BY CHAVE, LEITO, DATAI, HORAI"
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"                                                          
 
 DbSelectArea("QRY")
 DbGoTop()
 
 FS_AcumH(2)  //a ocorrencia 2 refere-se as diarias interditadas
 DbCloseArea()
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Obter intervalos de utilizacao dos leitos                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nAgrup == 1
  cSQL := "SELECT GAV.GAV_MODELO CHAVE, GB1.GB1_CODLOC || GB1.GB1_QUARTO || GB1.GB1_LEITO LEITO, " 
 Else
  cSQL := "SELECT GAV.GAV_CODLOC CHAVE, GB1.GB1_QUARTO || GB1.GB1_LEITO LEITO, "  
 Endif
 cSQL += "GB1.GB1_DATAE DATAI, GB1.GB1_HORAE HORAI, GB1.GB1_DATAS DATAF, GB1.GB1_HORAS HORAF "
 cSQL += "FROM " + RetSQLName("GB1") + " GB1 "
 cSQL += "JOIN " + RetSQLName("GAV") + " GAV "
 cSQL += "ON GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO AND GB1.GB1_LEITO = GAV.GAV_LEITO "
 cSQL += "AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' "
 cSQL += "WHERE GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' "
 cSQL += "AND GAV.GAV_MODELO BETWEEN '" + cModelo_De + "' AND '" + cModelo_Ate + "' "
 cSQL += "AND GAV.GAV_ESTATI = '1' "
 cLimDataE := IIF(SUBSTR(DToS(dData_Ate),1,6) < Substr(DTOS(DDATABASE), 1, 6), DTOS(dData_Ate), DTOS(DDATABASE))
 cSQL += " AND GB1.GB1_DATAE <= '" + cLimDataE + "' "
 cSQL += " AND (GB1.GB1_DATAS >= '" + DToS(dData_De) + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
 cSQL += "ORDER BY CHAVE, LEITO, DATAI, HORAI"
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 FS_AcumH(3) //a ocorrencia 3 refere-se as diarias UTILIZADAS
 DbCloseArea()
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do relatorio                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(Len(aChaves))
 For nCha := 1 to Len(aChaves)
  IncRegua()
  nLin := IIf(nTipRel==1, nMaxLin+1, nLin)
  If nLin > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  If nAgrup == 1
   @nLin, 000 PSAY HS_RDescrB("GAV_MODELO", aChaves[nCha])
  Else
   @nLin, 000 PSAY HS_IniPadr("GCS", 1, aChaves[nCha], "GCS_NOMLOC",, .F.)  
  Endif 
  
  If nTipRel == 1 //Analitico
   aTotCha := {0, 0, 0}
   nLei := aScan(aLeitos, {|x| x[2] == aChaves[nCha]} )
   While aLeitos[nLei, 2] == aChaves[nCha] //Enquanto leitos do mesmo modelo...
    If nLin > nMaxLin
     FS_Cabec()
    Endif
    nLin += 1
    @nLin, 001 PSAY STR0013 + ": " + IIf(nAgrup == 1, Substr(aLeitos[nLei, 1], 1, 2) + " ", "") + Substr(aLeitos[nLei, 1],IIF(nAgrup == 1, 3, 1), 4) + " " + Substr(aLeitos[nLei, 1], IIF(nAgrup == 1, 7, 5)) //"Leito"###
    FS_ImpDet(STR0014 + STR0013, aValLei[nLei], 4) //"Total do "###"Leito"
    If nLei == Len(aLeitos)
     Exit
    Endif 
    nLei += 1
   End
   If nLin+1 > nMaxLin
    FS_Cabec()
   Endif
   nLin += 1
   FS_ImpVal(STR0014 + IIf(nAgrup == 1, STR0004, STR0010), aTotCha[1] - aTotCha[2], aTotCha[2], aTotCha[3], aTotCha[1] - aTotCha[2] - aTotCha[3])   //"Total do "###"Tipo de Acomoda็ใo"###"Setor"
   nLin += 1
  Else
   FS_ImpDet(STR0014 + IIf(nAgrup == 1, STR0004, STR0010), aValCha[nCha], 2)  //"Total do "###"Tipo de Acomoda็ใo"###"Setor"
  Endif 
       
 Next nCha
 If nLin > nMaxLin
  FS_Cabec()                                                                                   
 Endif
 nLin += 1
 FS_ImpVal(STR0015, aValTot[1] - aValTot[2], aValTot[2], aValTot[3], aValTot[1] - aValTot[2] - aValTot[3]) //"Total Geral"
                                                                                    
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif
 MS_FLUSH()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AcumH  บ Autor ณ Cibele Peria       บ Data ณ  25/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acumula horas por leito e modelo                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AcumH(nOcor)
 Local nCha    := 0
 Local nLei    := 0
 Local nMes    := 0, nDataI := 0
 Local nGB1Ini := 0 
 Local nGB1Fim := 0
 Local cFiltro := ""
 Local aIteDat := {}
 Local dData   := CToD("")
 Local dDataI  := CToD("")
 Local dDataF  := CToD("")
 
 While !Eof()
  nCha := aScan(aChaves, QRY->CHAVE)
  
  While !Eof() .And. QRY->CHAVE == aChaves[nCha]
   nLei := aScan(aLeitos, {|x| x[1] == QRY->LEITO} )    
   aIteDat := {}
   aMes := Array(Len(aMeses))
   For nMes := 1 to len(aMeses)
    aMes[nMes] := aFill(Array(31), 0)
   Next nMes 
   
   While !Eof() .And. QRY->CHAVE == aChaves[nCha] .And. QRY->LEITO == aLeitos[nLei, 1]
        
    dDataI := IIF(STOD(QRY->DATAI) < dData_De, dData_De, STOD(QRY->DATAI)) 	
    If !EMPTY(STOD(QRY->DATAF))
     dDataF := IIF(STOD(QRY->DATAF) > STOD(cLimDataE), STOD(cLimDataE), STOD(QRY->DATAF))
    Else 
     dDataF := STOD(cLimDataE)
    EndIf
    
    If nOcor == 2
     If nAgrup == 1
      cFiltro := "GB1_CODLOC || GB1_QUARTO || GB1_LEITO = '" + QRY->LEITO + "'" 
     Else
      cFiltro := " GB1_QUARTO || GB1_LEITO = '" + QRY->LEITO + "'"  
     Endif
     If "MSSQL" $ TcGetDb()
      cFiltro := StrTran(cFiltro, "||", "+")    
     Endif
     nDataI := HS_CountTB("GB1", cFiltro + " AND GB1_DATAS = '" + DTOS(dDataI) + "'" ) 
       
     If nDataI > 0 
      dDataI := dDataI + 1
     Endif
    ElseIf nOcor == 3    
     nGB1Ini := aScan(aIteDat, { | aVet | aVet[1] == dDataI})
     nGB1Fim := aScan(aIteDat, { | aVet | aVet[1] == dDataF})
     If nGB1Ini > 0 
      If dDataI == dDataF
       dBSkip()
       Loop
      Else
       dDataI := dDataI + 1
       nGB1Ini := aScan(aIteDat, { | aVet | aVet[1] == dDataI})
       If nGB1Ini == 0
        AADD(aIteDat, {dDataI})
       Endif
      Endif
     Else
      AADD(aIteDat, {dDataI})
     Endif
    Endif
    
    If dDataI == dDataF
     FS_SomaD(nCha, nLei, nOcor, dDataI)
    Else
     For dData := dDataI to (dDataF - 1)
      FS_SomaD(nCha, nLei, nOcor, dData)
     Next dData  
     
     If Empty(QRY->HORAF)
      FS_SomaD(nCha, nLei, nOcor, dDataF)
      If nOcor == 3 
       If nGb1Fim == 0
        AADD(aIteDat, {dDataF})
       Endif
      Endif
     Else
      If nOcor == 3 .And. (nDtSaida == 2 .And. SubHoras(QRY->HORAF, 0) >= nPermLei) //Considera Dt Saida
       FS_SomaD(nCha, nLei, nOcor, dDataF)
       If nGb1Fim == 0
        AADD(aIteDat, {dDataF})
       Endif
      EndIf
     Endif
    Endif 

    DbSkip()
   End
  End
 End 

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_SomaD  บ Autor ณ Cibele Peria       บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Acumula diarias, conforme horario e permanencia minima     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SomaD(nCha, nLei, nOcor, dData)
 Local nMes := ascan(aMeses, {|x| x == Substr(DToS(dData), 1, 6)})

 aValLei[nLei, nMes, nOcor] += 1
 aValCha[nCha, nMes, nOcor] += 1

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do cabecalho do relatorio                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 8
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpDet บ Autor ณ Cibele Peria       บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do detalhe (totais por mes)                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpDet(cTitulo, aValMes)
 Local nMes   := 0
 Local aTotal := {0, 0, 0}
 
 For nMes := 1 to Len(aValMes)
  If nLin >= nMaxLin
   FS_Cabec()
  Endif 
  nLin += 1
  FS_ImpVal(Substr(MesExtenso(SToD(aMeses[nMes]+"01")), 1, 3) + "/" + Substr(aMeses[nMes], 1, 4), ;
            aValMes[nMes, 1] - aValMes[nMes, 2], ;
            aValMes[nMes, 2], ;
            aValMes[nMes, 3], ;
            aValMes[nMes, 1] - aValMes[nMes, 2] - aValMes[nMes, 3])
  
  aTotal[1]  += aValMes[nMes, 1] 
  aTotal[2]  += aValMes[nMes, 2] 
  aTotal[3]  += aValMes[nMes, 3] 
 Next nMes

 If nTipRel == 1
  aTotCha[1] += aTotal[1] 
  aTotCha[2] += aTotal[2] 
  aTotCha[3] += aTotal[3]
 Endif 
 
 aValTot[1] += aTotal[1] 
 aValTot[2] += aTotal[2] 
 aValTot[3] += aTotal[3]

 If nLin >= nMaxLin
  FS_Cabec()
 Endif
 nLin += 1
 FS_ImpVal(cTitulo, aTotal[1] - aTotal[2], aTotal[2], aTotal[3], aTotal[1] - aTotal[2] - aTotal[3])
 nLin += 1
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao dos valores                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpVal(cTitulo, nDDisp, nDIndi, nDOcup, nDOcio)
 Local nPOcup     := (nDOcup / nDDisp) * 100
 
 @nLin, 02 PSAY cTitulo
 @nLin, 28 PSAY TRANSFORM(nDDisp    , "@E 999,999") //Qtde dias disponiveis
 @nLin, 36 PSAY TRANSFORM(nDIndi    , "@E 999,999") //Qtde dias indisponiveis
 @nLin, 44 PSAY TRANSFORM(nDOcup    , "@E 999,999") //Qtde dias ocupados (utilizados)
 @nLin, 52 PSAY TRANSFORM(nDOcio    , "@E 999,999") //Qtde dias ociosos
 @nLin, 61 PSAY TRANSFORM(nPOcup    , "@E 9999.999") //Percentual de ocupacao
 @nLin, 72 PSAY TRANSFORM(100-nPOcup, "@E 9999.999") //Percentual de ociosidade

Return()