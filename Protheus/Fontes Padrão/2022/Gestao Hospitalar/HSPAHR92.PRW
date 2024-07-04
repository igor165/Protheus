#INCLUDE "HSPAHR92.ch"
#Include "protheus.ch"
#include "TopConn.ch"      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR92  บ Autor ณ Saude              บ Data ณ  02/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio MAPA CIRURGICO                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR92()
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Declaracao de Variaveis                                             ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
*/
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd 				      := {}

Private Titulo       := STR0003 //"Mapa Cirurgico"
Private Cabec1       := ""
Private Cabec2       := ""
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHR92" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004, 1, STR0005, 2, 1, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR92" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR92"

Private aVetCRM  := {}
Private aVetPRO  := {}
Private aVetMAT  := {}
Private aVetBEM  := {}
Private cString  := ""

Private cGcsTipLoc := "4"
Private cGcsCodLoc := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao


DbSelectArea("GC1")
DbSetOrder(1)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ PARAMETROS                                                         ณ
ณ MV_PAR01	Da De Agend                                              ณ
ณ MV_PAR02	Ate De Agend                                             ณ
ณ MV_PAR03	Da De Dig.                                               ณ
ณ MV_PAR04	Ate De Dig. 											 ณ																																			ณ
ณ MV_PAR05	Do Setor                                                 ณ
ณ MV_PAR06	Da Sala                                                  ณ
ณ MV_PAR07 Ate Setor                                                 ณ
ณ MV_PAR08	Ate Sala                                                 ณ
ณ MV_PAR09	Do Plano                                                 ณ
ณ MV_PAR10	Ate Plano                                                ณ
ณ MV_PAR11	Do Medico                                                ณ
ณ MV_PAR12	Ate medico                                               ณ
ณ MV_PAR13	Ordenar Por   //1=medico 2=Sala 3=Horแrios 4=Data        ณ
ณ MV_PAR14 Cirurgias  ?                                              ณ
ณ MV_PAR15 Impressora ?                                              ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
*/

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport() },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Saude              บ Data ณ  2/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
Local    cSQL 	     := ""
Local    nForMem    := 0
Local    nDuracao   := 0
Local    cDuracao   := ""

Private  cCodCRM    := ""
Private  cQuarto    := ""
Private  cDatAge    := ""
Private  nTotDia    := 0
Private  nTotMed    := 0
Private  nTotSal    := 0
Private  nTotGer    := 0
Private  cCodAge		  := ""
Private  cCodPac		  := ""

cSQL := " SELECT GMJ.GMJ_CODAGE,  GE9.GE9_CODCRM, GE9.GE9_TIPATM"  //equipe medica
cSQL += " FROM " + RetSQLName("GMJ") + " GMJ "
cSQL += " JOIN " + RetSQLName("GE9") + " GE9 ON GE9.GE9_CODAGE = GMJ.GMJ_CODAGE  "
cSQL += " WHERE "
cSQL += " GE9.GE9_FILIAL = '" + xFilial("GE9") + "' AND GE9.D_E_L_E_T_ <> '*'  "
cSQL += " AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf
cSQL += " AND GMJ.GMJ_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GMJ.GMJ_CODPLA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GMJ.GMJ_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GMJ.GMJ_QUARTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GMJ.GMJ_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "
cSQL += " ORDER BY GMJ_CODAGE "

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()
FS_MontVet("MED")
dbCloseArea()

cSQL := " SELECT GMJ.GMJ_CODAGE,  GEA.GEA_CODPRO "  //PROCED. CONJUGADOS
cSQL += " FROM " + RetSQLName("GMJ") + " GMJ "
cSQL += " JOIN " + RetSQLName("GEA") + " GEA ON GEA.GEA_CODAGE = GMJ.GMJ_CODAGE  "
cSQL += " WHERE "
cSQL += " GEA.GEA_FILIAL = '" + xFilial("GEA") + "' AND GEA.D_E_L_E_T_ <> '*'  "
cSQL += " AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf
cSQL += " AND GMJ.GMJ_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GMJ.GMJ_CODPLA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GMJ.GMJ_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GMJ.GMJ_QUARTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GMJ.GMJ_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "
cSQL += " ORDER BY GMJ_CODAGE "

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()
FS_MontVet("PRO")
dbCloseArea()

cSQL := " SELECT GMJ.GMJ_CODAGE,  GEB.GEB_CODMAT "  //mat conj.
cSQL += " FROM " + RetSQLName("GMJ") + " GMJ "
cSQL += " JOIN " + RetSQLName("GEB") + " GEB ON GEB.GEB_CODAGE = GMJ.GMJ_CODAGE  "
cSQL += " WHERE "
cSQL += " GEB.GEB_FILIAL = '" + xFilial("GEB") + "' AND GEB.D_E_L_E_T_ <> '*'  "
cSQL += " AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf
cSQL += " AND GMJ.GMJ_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GMJ.GMJ_CODPLA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GMJ.GMJ_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GMJ.GMJ_QUARTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GMJ.GMJ_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "

cSQL += " ORDER BY GMJ_CODAGE "

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()
FS_MontVet("MAT")
dbCloseArea()

cSQL := " SELECT GMJ.GMJ_CODAGE,  GET.GET_CODEQP "  //bem usado
cSQL += " FROM " + RetSQLName("GMJ") + " GMJ "
cSQL += " JOIN " + RetSQLName("GET") + " GET ON GET.GET_CODAGE = GMJ.GMJ_CODAGE  "
cSQL += " WHERE "
cSQL += " GET.GET_FILIAL = '" + xFilial("GET") + "' AND GET.D_E_L_E_T_ <> '*'  "
cSQL += " AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf
cSQL += " AND GMJ.GMJ_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GMJ.GMJ_CODPLA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GMJ.GMJ_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GMJ.GMJ_QUARTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GMJ.GMJ_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "

cSQL += " ORDER BY GMJ_CODAGE "

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()
FS_MontVet("BEM")
dbCloseArea()

cSQL := "SELECT GMJ.GMJ_FILAGE, GMJ.GMJ_CODAGE, GMJ.GMJ_STATUS, GMJ.GMJ_CODCRM, GMJ.GMJ_QUARTO, GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE, GMJ.GMJ_HORAFI ,GMJ.GMJ_REGATE, GMJ.GMJ_REGGER,  "
cSQL += " GMJ.GMJ_NOMPAC, GMJ.GMJ_MATRIC, GMJ.GMJ_IDADE , GMJ.GMJ_PESO, GMJ.GMJ_TELPAC, GMJ.GMJ_DATINT, GMJ.GMJ_HEMODE, GMJ.GMJ_USAUTI, GMJ.GMJ_CODLOC, GMJ.GMJ_DIAGNO, "
cSQL += " GMJ.GMJ_CODPAT, GCM.GCM_DESPLA, GMJ.GMJ_CODPRO, GMJ.GMJ_HORCAD, GA7.GA7_DESC, GMJ.GMJ_TOPOGR, GMJ.GMJ_CODPLA, GME.GME_CODCRM, GMF.GMF_CODATO, SRA.RA_NOME, "
cSQL += " GBH.GBH_DTNASC, GMJ.GMJ_DATCAD, GMJ.GMJ_CODUSU"
cSQL += " FROM " + RetSQLName("GMJ") + " GMJ"
cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GMJ.GMJ_CODPRO AND GMJ.GMJ_CODAGE = GMJ.GMJ_SEQAGE AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GMJ.GMJ_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GMJ.GMJ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GMJ.GMJ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GME") + " GME ON GME.GME_CODCRM = GMJ.GMJ_CODCRM AND GME.GME_FILIAL = '" + xFilial("GME") + "' AND GME.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GMF") + " GMF ON GMF.GMF_CODCRM = GME.GME_CODCRM AND GMF.GMF_FILIAL = '" + xFilial("GMF") + "' AND GMF.D_E_L_E_T_ <> '*' "
cSQL += " WHERE "
cSQL += " GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
 cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf
cSQL += " AND GMJ.GMJ_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GMJ.GMJ_CODPLA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GMJ.GMJ_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GMJ.GMJ_QUARTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GMJ.GMJ_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "

DbSelectArea("SX1")
DbSetOrder(1)
If MV_PAR14 == 1  //USA UTI
	cSQL += " AND GMJ.GMJ_USAUTI = '0' "
ElseIf MV_PAR14 == 2
	cSQL += " AND GMJ.GMJ_USAUTI = '1' "
EndIf

If MV_PAR13 == 1  				//ORDENAR POR MEDICO
	cSQL += " ORDER BY GMJ_CODCRM, GMJ_DATAGE, GMJ_HORAGE "
ElseIf MV_PAR13 == 2			//ORDENAR POR SALA
	cSQL += " ORDER BY GMJ_QUARTO, GMJ_DATAGE, GMJ_HORAGE "
ElseIf MV_PAR13 == 3			//ORDENAR POR HORARIO
	cSQL += " ORDER BY GMJ_HORAGE, GMJ_DATAGE "
ElseIf MV_PAR13 == 4			//ORDENAR POR DATA
	cSQL += " ORDER BY GMJ_DATAGE, GMJ_HORAGE "
EndIf

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()

If Eof()
	HS_MsgInf(STR0016, STR0067, STR0068) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
	DBCloseArea()
	Return()
Endif

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
*/

          /*            				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                     0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
Cabec1 := STR0069 //"Sala                    Dt. Intern.  Paciente                              Plano                      Dt. Cad. Hr Cad. Usuario      "
Cabec2 := STR0070 //"Hora  Final Dura็ใo     Dt.Cirurgia  Sexo Idade     Peso Telefone          Matricula                  CID       UTI  Hemod.  Topogr."

SetRegua(100)

While !EOF()
	
	If nLin > nMaxLin
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
		nLin := 8
	Endif
	
	IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY STR0021 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If cDatAge <> QRY->GMJ_DATAGE
		If  IIf(MV_PAR13 == 1, !EMPTY(cCodCRM), !EMPTY(cQuarto))
			FS_Imprime(000, STR0022 + TRANSFORM(nTotDia, "@E 999,999")) //"Total do Dia.......:"
			nTotDia := 0
			nLin ++
		EndIf
 		cDatAge := QRY->GMJ_DATAGE
 	EndIf

 	If MV_PAR13 == 1 .And. cCodCRM <> QRY->GMJ_CODCRM 
  		If !EMPTY(cCodCRM)
			 FS_Imprime(000, STR0023 + TRANSFORM(nTotMed, "@E 999,999")) //"Total do Medico....:"
			 nTotMed := 0
			 cDatAge := ""
			 nLin ++
		EndIf 
		cCodCRM := QRY->GMJ_CODCRM
	EndIf	

	If MV_PAR13 == 2 .And. cQuarto <> QRY->GMJ_QUARTO 
		If !EMPTY(cQuarto)
 			FS_Imprime(000, STR0024 + TRANSFORM(nTotSal, "@E 999,999")) //"Total da Sala......:"
 			nTotSal := 0
			cDatAge := ""
 			nLin ++     
 		EndIf
 		cQuarto := QRY->GMJ_QUARTO 	
	EndIf
	
	nLin ++
	@nLin,000 PSAY REPLI("-", 132)
 	nLin ++ 
	
	FS_Imprime(000, QRY->GMJ_QUARTO)
	@nLin,024 PSAY DTOC(STOD(QRY->GMJ_DATINT))
	@nLin,037 PSAY IIF(!EMPTY(QRY->GMJ_REGGER),ALLTRIM(QRY->GMJ_REGGER) + "-" + SUBSTR(QRY->GMJ_NOMPAC, 1, 28),ALLTRIM(QRY->GMJ_NOMPAC)) 
	@nLin,075 PSAY SUBSTR(QRY->GCM_DESPLA, 1, 25)
	@nLin,102 PSAY STOD(QRY->GMJ_DATCAD)
	@nLin,111 PSAY QRY->GMJ_HORCAD
	@nLin,119 PSAY SUBSTR(QRY->GMJ_CODUSU, 1, 12)	
	nLin ++
	
	FS_Imprime(000, QRY->GMJ_HORAGE)
	@nLin, 006 PSAY QRY->GMJ_HORAFI
	nDuracao := SubtHoras( STOD(QRY->GMJ_DATAGE) , QRY->GMJ_HORAGE , STOD(QRY->GMJ_DATAGE) , QRY->GMJ_HORAFI )
	If nDuracao < 0
		nDuracao := 0
	EndIf
	cDuracao := SUBSTR(STRZERO(nDuracao, 5, 2), 1, 2) + ":" + STRZERO((nDuracao - INT(nDuracao) )* 60, 2)
	@nLin,012 PSAY cDuracao
	@nLin,024 PSAY STOD(QRY->GMJ_DATAGE)
	@nLin,037 PSAY IIF(!EMPTY(QRY->GMJ_REGGER),IIF(POSICIONE("GBH",1,XFILIAL("GBH")+QRY->GMJ_REGGER,"GBH_SEXO")=="0",STR0061,STR0062),(SPACE(4))) //"Masc"###"Fem"
	@nLin,042 PSAY IIF(!EMPTY(QRY->GMJ_REGGER), ALLTRIM(SUBSTR(HS_AgeGer(STOD(QRY->GBH_DTNASC), STOD(QRY->GMJ_DATAGE)), 1, 7)), ALLTRIM(QRY->GMJ_IDADE)+ IIF(!Empty(QRY->GMJ_IDADE), STR0075, ""))//" anos"
	@nLin,049 PSAY TRANSFORM(QRY->GMJ_PESO, "@E 999.999")
	@nLin,057 PSAY QRY->GMJ_TELPAC
	@nLin,075 PSAY SUBSTR(QRY->GMJ_MATRIC, 1, 25)
	@nLin,102 PSAY SUBSTR(QRY->GMJ_CODPAT, 1, 8)
 	@nLin,112 PSAY IIf(QRY->GMJ_USAUTI == "0", STR0056, STR0057) //"Nao"###"Sim"
	@nLin,117 PSAY IIf(QRY->GMJ_HEMODE == "0", STR0056, STR0057) //"Nao"###"Sim"
	DO CASE
		CASE QRY->GMJ_TOPOGR == "0"
			@nLin,125 PSAY STR0063 //"Nenhum"
		CASE QRY->GMJ_TOPOGR == "1"
			@nLin,125 PSAY STR0064 //"Direito"
		CASE QRY->GMJ_TOPOGR == "2"
			@nLin,125 PSAY STR0065 //"Esquerdo"
		CASE QRY->GMJ_TOPOGR == "3"
			@nLin,125 PSAY STR0066 //"Ambos"
	ENDCASE
				
 	nLin += 2

 	FS_Imprime(000, STR0071 + QRY->GMJ_CODCRM + " - " + SUBSTR(QRY->RA_NOME, 1, 35))  //"Cirurgiao...............: "
 	@nLin,074 PSAY STR0072 + QRY->GMJ_DIAGNO //"Diagnostico: "
		
	If MV_PAR13 == 1 //por medico
		nTotMed ++
	ElseIf MV_PAR13 == 2 //por sala
		nTotSal ++
	EndIf
		
	nTotDia ++
	nTotGer ++
	
	cCodAge := QRY->GMJ_CODAGE
	cCodPac := QRY->GMJ_REGGER
		
	FS_ImpVet()

	nLin++	

	cOBSERV :=  HS_IniPadr("GMJ", 1, QRY->GMJ_CODAGE, "GMJ_OBSERV",, .F.)
	If !EMPTY(cOBSERV)
	 	FS_Imprime(000, STR0058) //"OBS: "
	 	For nForMem:= 1 to MlCount(cOBSERV)
	 		FS_Imprime(006, MemoLine(cOBSERV,, nForMem))
	 		nLin++
	 	Next
	 	nLin ++
	EndIf
	
	dbSkip() /* Avanca o ponteiro do registro no arquivo */
	
End

//imprime o total do ultimo reg
FS_Imprime(000, STR0022 + TRANSFORM(nTotDia, "@E 999,999")) //"Total do Dia.......:"
nLin++
If MV_PAR13 == 1 //por medico
	FS_Imprime(000, STR0023 + TRANSFORM(nTotMed, "@E 999,999")) //"Total do Medico....:"
Else
	FS_Imprime(000, STR0024 + TRANSFORM(nTotSal, "@E 999,999")) //"Total da Sala......:"
EndIf
nLin++
FS_Imprime(000, STR0074 + TRANSFORM(nTotGer, "@E 999,999")) //"Total Geral........:"

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Finaliza a execucao do relatorio...                                 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

SET DEVICE TO SCREEN

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
*/

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR92  บAutor  ณ Saude              บ Data ณ  02/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Monta o Vetor com os Med,Proced,MAt e Equip. Conjugados   บฑฑ          ณ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MontVet(cTipo)

While !EOF()
	If cTipo == "MED"
		AADD(aVetCRM,{QRY->GMJ_CODAGE, QRY->GE9_CODCRM, QRY->GE9_TIPATM})  //CODAGE , CODCRM, TIPATM
	ElseIF cTipo == "PRO"
		AADD(aVetPRO,{QRY->GMJ_CODAGE, QRY->GEA_CODPRO})  //CODAGE , CODPRO
	ElseIF cTipo == "MAT"
		AADD(aVetMAT,{QRY->GMJ_CODAGE, QRY->GEB_CODMAT})  //CODAGE , CODMAT
	ElseIF cTipo == "BEM"
		AADD(aVetBEM,{QRY->GMJ_CODAGE, QRY->GET_CODEQP})  //CODAGE , CODEQP
	EndIf
	
	dbSkip()
	
End

DbGoTop()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR92  บAutor  ณ Saude              บ Data ณ  02/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Imprimi o Vetor com Med,PRo, Mat e Bem COnjugados        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpVet()
Local nCOnt := 1        

nLin ++
If Len(aVetCRM) > 0
	FS_Imprime(000, STR0025) //"Equipe Medica...........:"
	For nCont:= 1 To Len(aVetCRM)
		If aVetCRM[nCont,1] == cCOdAGe
  			IIF(nCOnt > 1, nLin ++, Nil)
			FS_Imprime(026, SUBSTR(HS_IniPadR("SRA", 11, aVetCRM[nCont, 2], "RA_NOME",,.F.), 1, 35) + "  " + HS_IniPadR("GMC", 1, aVetCRM[nCont, 3], "GMC_DESATO",,.F.) ) 
		EndIf
	Next
EndIf                    

nLin ++
FS_Imprime(000, STR0073 + ALLTRIM (QRY->GMJ_CODPRO) + " - " + SUBSTR(QRY->GA7_DESC,1,35)) //"Procedimento............: "*/
nLin ++

If Len(aVetPRO) > 0
	FS_Imprime(000, STR0026) //"Procedimentos Conjugados:"
	For nCont:= 1 To Len(aVetPRO)
		If aVetPRO[nCont,1] == cCOdAGe
			FS_Imprime(026, aVetPRO[nCont,2] + " - "+ HS_iniPadR("GA7", 1, aVetPRO[nCont, 2], "GA7_DESC",,.F.)) //PROCED CONJUGADOS
			nLin ++
		EndIF
	Next
EndIF

nLin ++

If Len(aVetBEM) > 0
	FS_Imprime(000, STR0028) //"Equipamentos Utilizados.:"
	For nCont:= 1 To Len(aVetBEM)
		If aVetBEM[nCont,1] == cCOdAGe
		  	FS_Imprime(026, Hs_IniPadR("ST9", 1, aVetBEM[nCont, 2], "T9_NOME",,.F.)) //EQUIPAMENTOS
		  	nLin ++
		EndIF
	Next
EndIf

nLin ++	

If Len(aVetMAT) > 0
	FS_Imprime(000, STR0027) //"Materiais Especiais.....:"
	For nCont:= 1 To Len(aVetMAT)
		If aVetMAT[nCont,1] == cCOdAGe
			FS_Imprime(026, HS_iniPadR("SB1", 1, aVetMAT[nCont, 2], "B1_DESC",,.F.)) //MAT CONJUGADOS
			nLin ++
		EndIf
	Next
EndIf

nLin++

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR92  บAutor  ณSaude               บ Data ณ  02/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica o valor de nPar, caso seja 1 o retorno e o conteu บฑฑ
ฑฑบ          ณ do de MV_PAR05, caso contrario o retorno e o MV_PAR07      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldR92(nPar)

cGcsCodLoc := IIF(nPar == 1,MV_PAR05,MV_PAR07)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR92  บAutor  ณSaude               บ Data ณ  02/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reimprimi o cabecalho e traca uma linha                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Imprime(nCol, cLinha)

	If nLin > nMaxLin
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
		nLin := 9
	Endif
	
	@nLin, nCol PSAY cLinha

Return()
