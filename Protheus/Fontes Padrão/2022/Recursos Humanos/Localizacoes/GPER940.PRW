#INCLUDE "GPERVACM2.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

Static lAglutPd 	:= ( GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
Static __cRotSRY	:= ""
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER940  ³ Autor ³ Leandro Drumond       ³ Data ³ 13.12.2012	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao de Recibos de Ferias Grafico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER940(void)                                             	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                               		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Nr.FNC    ³ Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³07/05/15³ PCREQ-4256³Se elimina funcion AjustaSX que realiza   ³±±
±±³            ³        ³           ³modificacion al diccionario de datos(SX1) ³±±
±±³            ³        ³           ³por motivo de ajuste nueva estructura de  ³±±
±±³            ³        ³           ³SXs para V12                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPER940()
Local oReport
Local aArea := GetArea()

Pergunte("GPER940",.F.)
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Leandro Drumond     ³ Data ³ 13/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Componente de Impressao do Relatorio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oSection6
Local oSection7
Local oCell
Local cTitulo	:= STR0001	//"RECIBO DE PAGAMENTO DE FÉRIAS

Private aOrd    := {STR0002}//"Matricula"

Pergunte("GPER940",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New('GPER940',OemToAnsi(cTitulo),'GPER940',{|oReport| PrintReport(oReport)})

oReport:nColSpace 	:= 1
oReport:nFontBody	:= 6 	// Define o tamanho da fonte.
oReport:cFontBody	:= "COURIER NEW"
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection1:SetLineStyle(.F.)   	//Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(" ")
oSection1:SetHeaderBreak(.T.)
oSection1:nColSpace:=5

/*						Campo		Alias		Titulo				Picture							Tamanho	*/
TRCell():New(oSection1,"RA_MAT"		 ,"QRYREL"	, OemToAnsi(STR0002),PesqPict("SRA","RA_MAT")		,TamSx3("RA_MAT")[1])		//"Matricula"
TRCell():New(oSection1,"REL_NOME"	 ,"   " 	, OemToAnsi(STR0003), 								,TamSx3("RA_NOME")[1])		//"Nome"
TRCell():New(oSection1,"REL_ADMISSA","   "	, OemToAnsi(STR0004), 								,12)						//"Dt. Admissao"
If cPaisLoc == "PAR"
	TRCell():New(oSection1,"REL_FUNCAO" ,"   "	, OemToAnsi(STR0005),PesqPict("SRJ","RJ_DESC")	,30)		//"Funcao"
Else
	TRCell():New(oSection1,"REL_FUNCAO" ,"   "	, OemToAnsi(STR0005),PesqPict("SRJ","RJ_DESC")	,TamSx3("RJ_DESC")[1])		//"Funcao"
EndIf
TRCell():New(oSection1,"REL_CC"		 ,"   "	, OemToAnsi(STR0006), 								,30)						//"Centro de Custos"
TRCell():New(oSection1,"REL_PERPAG" ,"     "	, OemToAnsi(STR0007), 								,10) 						//"Periodo de Pagamento"
TRCell():New(oSection1,"REL_SALARIO","   "	, OemToAnsi(STR0008),PesqPict("SRA","RA_SALARIO"), TamSx3("RA_SALARIO")[1])	//"Salario"

oSection2 := TRSection():New(oReport,oemtoansi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:nColSpace := 10

TRCell():New(oSection2, "REL_PERAQU",	"      ",OemToAnsi(STR0009), "@!",	25)	//"Periodo Aquisitivo"
TRCell():New(oSection2, "REL_PERFER",	"	   ",OemToAnsi(STR0010), "@!",	25)	//"Periodo Gozo de Ferias"
TRCell():New(oSection2, "REL_DIASFE",	"      ",OemToAnsi(STR0011), "@!",	20)	//"Dias de Ferias"
If cPaisLoc == "ARG"
	TRCell():New(oSection2, "REL_DTREC" ,	"      ",OemToAnsi(STR0012), "@!",	10)	//"Dt. Reconhecimento"
EndIf

oSection3 := TRSection():New(oReport,OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection3:SetTotalInLine(.F.)
oSection3:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection3:SetLineStyle(.F.)   	//Pone titulo del campo y aun lado el y valor

TRCell():New(oSection3,"REL_VERBA","  "	, OemToAnsi(STR0013),"@!"               ,03) //"Verba"
TRCell():New(oSection3,"REL_DESC" ,"  "	, OemToAnsi(STR0014),"@!"               ,20) //"Descricao"
TRCell():New(oSection3,"REL_QTD"  ,"  "	, OemToAnsi(STR0015),"@E 999,999,999.99",05) //"Unidades"
TRCell():New(oSection3,"REL_REMUN","  "	, OemToAnsi(STR0016),"@E 999,999,999.99",14) //"Remunerativo"
TRCell():New(oSection3,"REL_NOREM","  "	, If(cPaisLoc=="ARG",OemToAnsi(STR0017),""),"@E 999,999,999.99",14) //"Não Remunerativo"
TRCell():New(oSection3,"REL_DEDUC","  "	, OemToAnsi(STR0018),"@E 999,999,999.99",14) //"Deducoes"
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Criacao da 6ta.     Secao: Total Grles.                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oSection4 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection4:SetTotalInLine(.F.)
oSection4:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection4:SetLineStyle(.T.)   	//Valor ao lado do titulo do campo
oSection4:SetHeaderBreak(.T.)
oSection4:nColSpace := 5

TRCell():New(oSection4, "TOTVENC",, OemToAnsi(STR0019)	, "@E 999,999,999,999.99", 44)//"Totais"
TRCell():New(oSection4, "TOTNREM",, ""					, "@E 999,999,999,999.99", 11)//"Totais"
TRCell():New(oSection4, "TOTDESC",, ""					, "@E 999,999,999,999.99", 09)

oSection5 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection5:SetTotalInLine(.F.)
oSection5:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection5:SetLineStyle(.T.)   	//Valor ao lado do titulo do campo
oSection5:SetHeaderBreak(.T.)
oSection5:nColSpace := 5

TRCell():New(oSection5, "TOTNET",, OemToAnsi(STR0020), "@E 999,999,999,999.99", 72)//"Total Bruto"

oSection6 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection6:SetTotalInLine(.F.)
oSection6:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
oSection6:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection6:SetLineStyle(.T.)   	//Valor ao lado do titulo do campo
oSection6:SetCharSeparator(":")
oSection6:SetHeaderBreak(.T.)
oSection6:nColSpace := 5

TRCell():New(oSection6, "FOOTLIN1",, "", "@!", 100)
oSection6:Cell("FOOTLIN1"):SetCellBreak(.T.)
TRCell():New(oSection6, "FOOTLIN2",, "", "@!", 100)
oSection6:Cell("FOOTLIN2"):SetCellBreak(.T.)
TRCell():New(oSection6, "FOOTLIN3",, "", "@!", 200)
oSection6:Cell("FOOTLIN3"):SetCellBreak(.T.)

oSection7 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection7:SetTotalInLine(.F.)
oSection7:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
oSection7:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection7:SetLineStyle(.T.)   	//Valor ao lado do titulo do campo
oSection7:SetCharSeparator(":")
oSection7:SetHeaderBreak(.T.)
oSection7:nColSpace := 5

TRCell():New(oSection7, "DESC_MSG1",, "", "@!", 100)
oSection7:Cell("DESC_MSG1"):SetCellBreak(.T.)       //Salta linha
TRCell():New(oSection7, "DESC_MSG2",, "", "@!", 100)
oSection7:Cell("DESC_MSG2"):SetCellBreak(.T.)		//Salta linha
TRCell():New(oSection7, "DESC_MSG3",, "", "@!", 100)
oSection7:Cell("DESC_MSG3"):SetCellBreak(.T.)		//Salta linha
TRCell():New(oSection7, "DESC_MSG4",, "", "@!", 100)
oSection7:Cell("DESC_MSG4"):SetCellBreak(.T.)		//Salta linha

oSection8 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection8:SetTotalInLine(.F.)
oSection8:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
oSection8:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection8:SetLineStyle(.T.)   	//Valor ao lado do titulo do campo
oSection8:SetCharSeparator(":")
oSection8:SetHeaderBreak(.T.)
oSection8:nColSpace := 5

TRCell():New(oSection8, "FOOTFIM",, "", "@!", 100)

oSection9 := TRSection():New(oReport, OemToAnsi("EncPrograma"),,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"

oSection9:SetTotalInLine(.F.)
oSection9:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
oSection9:SetHeaderPage(.F.)	//Exibe Cabecalho da Pagina
oSection9:SetHeaderBreak(.T.)

TRCell():New(oSection9, "FIRMA",, "", "@!", 200,/*lPixel*/	, /*{||  }*/,"CENTER"	,	.F.			,"CENTER")

Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintReport ³ Autor ³ Leandro Drumond     ³ Data ³ 13/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do relatorio							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

Local aInfo		  := {}
Local aVerbas	  := {}
Local aPerAberto  := {}
Local aPerFechado := {}
Local aVerbasFunc := {}
Local cAcessaSRA  := &("{ || " + ChkRH("GPER940","SRA","2") + "}")
Local cNroHoras   := &("{ || If(aVerbasFunc[nReg,5] > 0 .And. cIRefSem == 'S', aVerbasFunc[nReg,5], aVerbasFunc[nReg,6]) }")
Local cTitulo  	  := ""
Local cPeriodo 	  := ""
Local cPago	   	  := ""
Local cRoteiro 	  := ""
Local cSituacao	  := ""
Local cCategoria  := ""
Local cSelect	  := ""
Local cFilialAnt  := ""
Local nCnt		  := 0
Local nReg		  := 0
Local nHoras	  := 0

DEFAULT	oReport	  := ReportDef()

cTitulo			  := oReport:Title()

Private cQryFER	  := 'QRYREL'
Private cIRefSem  := GetMv("MV_IREFSEM",,"S")
Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
Private oSection3 := oReport:Section(3)
Private oSection4 := oReport:Section(4)
Private oSection5 := oReport:Section(5)
Private oSection6 := oReport:Section(6)
Private oSection7 := oReport:Section(7)
Private oSection8 := oReport:Section(8)
Private oSection9 := oReport:Section(9)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private RELFUNCAO, RELPERPAG, RELPERAQU, RELPERFER, RELDIASFE, DESC_FIL, DESC_END, DESC_CGC, DESC_CID, DESC_COMP
Private aLanca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaves para faciliar o tratamento do processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cProcesso  := mv_par01
Private cPerPar    := mv_par02
Private cPagoPar   := mv_par03
Private cSit	   := mv_par06
Private cCateg	   := AllTrim(mv_par07)
Private DESC_MSG1  := AllTrim(LEFT(mv_par08,90))					 						//Mensagem 1
Private DESC_MSG2  := AllTrim(LEFT(mv_par09,90))											//Mensagem 2
Private DESC_MSG3  := AllTrim(LEFT(mv_par10,90))											//Mensagem 3
Private DESC_MSG4  := AllTrim(LEFT(mv_par11,90))											//Mensagem 4
Private TOTVENC    := 0
Private TOTDESC    := 0
Private TOTNREM	   := 0

//-- Altera o titulo do relatorio
oReport:SetTitle(OemToAnsi(STR0001)) //"Recibo de Pagamento de Férias"

If !Empty(cSit)
	cSituacao   := "("
	For nCnt := 1 To Len(cSit)
		cSituacao += "'" + SubStr( cSit, nCnt, 1) + "',"
	Next nCnt
	cSituacao 	:= SubStr(cSituacao,1,Len(cSituacao)-2) + "')"
Else
	cSituacao 	:= "(' ')"
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Buscar Categoria em formato para SQL              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !Empty(cCateg)
	cCategoria:="('"
	For nCnt:=1 To Len(cCateg)
		If Substr(cCateg,nCnt,1) <> '*'
			cCategoria+=SubStr(cCateg,nCnt,1)+"','"
		EndIf
	Next
	cCategoria := Substr(cCategoria,1,Len(cCategoria)-2)  + ")"
Else
	cCategoria	:= "(' ')"
EndIf

cSelect	:= "% RHI_FILIAL, RHI_MAT, RHI_ROTEIR, RHI_PERIOD, RHI_NUMPAG, RHI_DTPAGO, "
cSelect += " RHJ_DTINI,RHJ_DTFIM, RHJ_DTBASE, RHJ_DIASPG,
If cPaisLoc== "ARG"
	cSelect += 	"RA_MAT, RA_SALARIO, RA_SITFOLH, RA_CATFUNC, RA_NOME, RA_NOMECMP,RA_ADMISSA, RA_CC, RA_CARGO, RA_ADMISSA, RA_DTREC %"
Else
	cSelect += 	"RA_MAT, RA_SALARIO, RA_SITFOLH, RA_CATFUNC, RA_NOME, RA_NOMECMP,RA_ADMISSA, RA_CC, RA_CARGO, RA_ADMISSA %"
EndIf

MakeSqlExpr("GPER940")

cFiltro := "% RHI_PROCES = '" + cProcesso + "'  AND "
cFiltro += " RHI_PERIOD = '" + cPerPar + "' AND "
cFiltro += " RHI_NUMPAG = '" + cPagoPar + "' AND "
If !Empty(mv_par04)
	cFiltro += mv_par04 + " AND " //Range filial
EndIf
If !Empty(mv_par05)
	cFiltro += mv_par05 + " AND " //Range matricula
EndIf
cFiltro += " RHI_STATUS <> '1'  AND "
cFiltro += " RHJ_DIASPG > 0 AND "
cFiltro += " RA_SITFOLH IN  " + cSituacao + " AND "
cFiltro += " RA_CATFUNC IN  " + cCategoria + " %"

If Select(cQryFER) > 0
	DbSelectArea(cQryFER)
	DbCloseArea()
EndIf

BeginSql alias cQryFER
	SELECT %exp:cSelect%
	FROM %table:RHI% RHI
		INNER JOIN %table:RHJ% RHJ
			ON 	RHI.RHI_FILIAL=RHJ.RHJ_FILIAL
				AND RHI.RHI_MAT=RHJ.RHJ_MAT
				AND RHI.RHI_DTINI=RHJ.RHJ_DTINI
		INNER JOIN %table:SRA% SRA
			ON RHJ.RHJ_FILIAL=SRA.RA_FILIAL
				AND RHJ.RHJ_MAT=SRA.RA_MAT
				AND RHI.RHI_PROCES=SRA.RA_PROCES

	Where %exp:cFiltro%
	AND RHI.%notDel%
	AND RHJ.%notDel%
	AND SRA.%notDel%
EndSql

DbSelectArea(cQryFER)

If Eof()
	Alert(OemToAnsi(STR0021)) //"Não existem registros de férias para os parêmtros informados"
	Return .F.
EndIf

//carregar somentes verbas com RV_TIPOCOD $ '1/2' e RV_CLASIF nao vazio
DbSelectArea("SRV")
DbSetOrder(1)
dbSeek(xFilial("SRV"))

While !Eof() .And. SRV->RV_FILIAL == xFilial("SRV")
	If SRV->RV_TIPOCOD $ ('1|2')
		aAdd(aVerbas,{SRV->RV_COD,0})
	EndIf
	dbSkip()
EndDo

If (Len(aVerbas) <= 0)
	Alert(OemToAnsi(OemToAnsi(STR0022)))//"Não existem Verbas ou Processos para os parâmetros informados."
	Return .F.
EndIf

DbSelectArea(cQryFER)
DbGoTop()
While (cQryFER)->(!(Eof()) .and. !Empty((cQryFER)->RHI_MAT) )

	//-- Incializa impressao
	oSection1:Init()
	oSection2:Init()
	oSection3:Init()
	oSection4:Init()
	oSection5:Init()
	oSection6:Init()
	oSection7:Init()
	oSection8:Init()
	oSection9:Init()

	aLanca:={}         // Zera Lancamentos

	If (cQryFER)->RHI_FILIAL # cFilialAnt
		If  ! fInfo(@aInfo,(cQryFER)->RHI_FILIAL)
			Exit
		EndIf

		DESC_COMP	:= If (!Empty(Left(UPPER(AllTrim(aInfo[14])),10))," ," + Left(UPPER(AllTrim(aInfo[14])),10),	"")	//Complemento Cobranca
		DESC_FIL	:= Left(UPPER(AllTrim(aInfo[3])),50)
		DESC_END	:= Left(UPPER(AllTrim(aInfo[4])),40) + DESC_COMP     // Dados da Filial
		DESC_CGC	:= Left(UPPER(AllTrim(aInfo[8])),15)
		DESC_CID 	:= Left(UPPER(AllTrim(aInfo[05])),25)
		cFilialAnt 	:= (cQryFER)->RHI_FILIAL
	EndIf

	SRA->(DbSeek(xFilial('SRA')+(cQryFER)->RA_MAT))

	TOTVENC := TOTDESC := TOTNREM := 0

	If (cPeriodo <> (cQryFER)->RHI_PERIOD) .OR. (cPago <> (cQryFER)->RHI_NUMPAG) .OR. (cRoteiro <> (cQryFER)->RHI_ROTEIR)

		cPeriodo	:= (cQryFER)->RHI_PERIOD
		cPago		:= (cQryFER)->RHI_NUMPAG
		cRoteiro 	:= (cQryFER)->RHI_ROTEIR
		//Carregar os periodos abertos (aPerAberto) e/ou
		// os periodos fechados (aPerFechado), dependendo
		// do periodo (ou intervalo de periodos) selecionado
		RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
						cRoteiro	,; // Roteiro selecionado na Pergunte.
						cPeriodo	,; // Periodo selecionado na Pergunte.
						cPago		,; // Numero de Pagamento selecionado na Pergunte.
						NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
						NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
						@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
						@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados

	EndIf

	If (Len(aPerAberto) <= 0) .and. (Len(aPerFechado) <= 0)
		Alert(OemtoAnsi(STR0023))	//"Não existem perídos para os parametros informados."
		Return .F.
	EndIf

	//Retorna as verbas do funcionario, de acordo com os periodos selecionados
	aVerbasFunc	:= RetornaVerbasFunc(	(cQryFER)->RHI_FILIAL		,; // Filial do funcionario corrente
										(cQryFER)->RHI_MAT			,; // Matricula do funcionario corrente
										NIL							,; //
										cRoteiro					,; // Roteiro selecionado na pergunte
										aVerbas		  				,; // Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
										aPerAberto	  				,; // Array com os Periodos e Numero de pagamento abertos
										aPerFechado	 	 		 	,; // Array com os Periodos e Numero de pagamento fechados
										cPago) 							// Numero de Pago

	If Len(aVerbasFunc) > 0
		For nReg := 1 to Len(aVerbasFunc)
			If PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_TIPOCOD" ) == "1" .AND. ( ( !cPaisLoc == "ARG" ) .OR. ( ;
				!Empty(PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_CLASIF" )) .AND. ;
				PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_CLASIF" ) != "N" ) )

				nHoras := Eval(cNroHoras)
				fSomaPdRec("P",aVerbasFunc[nReg,3],nHoras,aVerbasFunc[nReg,7])
				TOTVENC += aVerbasFunc[nReg,7]

			ElseIf PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_TIPOCOD" ) == "2"
				fSomaPdRec("D",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
				TOTDESC += aVerbasFunc[nReg,7]

			ElseIf cPaisLoc == "ARG" .AND. ;
				PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_TIPOCOD" ) == "1" .AND. ;
				!Empty(PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_CLASIF" )) .AND. ;
				PosSrv( aVerbasFunc[nReg,3] , (cQryFER)->RHI_FILIAL , "RV_CLASIF" ) == "N"

				fSomaPdRec("B",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
				TOTNREM += aVerbasFunc[nReg,7]
			EndIf
		Next nReg
	EndIf

	If TOTVENC == 0 .And. TOTDESC == 0
		(cQryFER)->( dbSkip() )
		Loop
	EndIf

	fImpRel(oReport)

	(cQryFER)->( dbSkip() )

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()
	oSection5:Finish()
	oSection6:Finish()
	oSection7:Finish()
	oSection8:Finish()
	oSection9:Finish()
	oReport:EndPage()

EndDo

DbSelectArea(cQryFER)
DbCloseArea()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSomaPdRec³ Autor ³ Leandro Drumond       ³ Data ³ 13.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar as Verbas no Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSomaPdRec(Tipo,Verba,Horas,Valor)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSomaPdRec(cTipo,cPd,nHoras,nValor)
Local Desc_paga
Local cCodFol

Desc_paga := DescPd(cPd,SRA->RA_FILIAL)  // mostra como pagto
nPos := aScan(aLanca,{ |X| X[1] = cPd })

If nPos == 0 .Or. !lAglutPd
	aAdd(aLanca,{ cPd, Desc_Paga, nHoras,0,0,0})
	nPos := Len(aLanca)
Else
	aLanca[nPos,3] += nHoras
EndIf
//--Array para o Recibo Pre-Impresso
If cTipo == 'P'
	aLanca[nPos,4] += nValor
ElseIf cTipo == 'B'
	aLanca[nPos,5] += nValor
ElseIf cTipo == 'D'
	aLanca[nPos,6] += nValor
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpRel   ³ Autor ³ Leandro Drumond       ³ Data ³ 13.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui valores nas sections e imprime                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpRel(oReport)					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpRel(oReport)
Local nx 		:= 0
Local cCodFunc  := ""
Local cDescFunc := ""
Local nValSal   := ""

fBuscaFunc(StoD( (cQryFER)->RHJ_DTINI), @cCodFunc, @cDescFunc   )
nValSal := fBuscaSal(StoD((cQryFER)->RHJ_DTINI))
If nValSal == 0
	nValSal := (cQryFER)->RA_SALARIO
EndIf

oSection1:Cell("REL_FUNCAO"):SetValue(cDescFunc) // Funcao
oSection1:Cell("REL_PERPAG"):SetValue((cQryFER)->RHI_PERIOD + " - " + (cQryFER)->RHI_NUMPAG) //Periodo de Pagamento
oSection1:Cell("REL_CC"):SetValue(AllTrim((cQryFER)->RA_CC)+"-"+Left(UPPER(DescCc((cQryFER)->RA_CC,(cQryFER)->RHI_FILIAL)),22))//Centro de Custos
oSection1:Cell("REL_NOME"):SetValue(IIF(!Empty((cQryFER)->RA_NOMECMP),SubStr((cQryFER)->RA_NOMECMP,1,58),SubStr((cQryFER)->RA_NOME,1,58)))//Nome
oSection1:Cell("REL_ADMISSA"):SetValue(DtoC(StoD((cQryFER)->RA_ADMISSA)))//Data de Admissao
oSection1:Cell("REL_SALARIO"):SetValue(nValSal)//Salario

oSection1:Printline()

oSection2:Cell("REL_PERAQU"):SetValue(DTOC(STOD((cQryFER)->RHJ_DTBASE))+" A "+DTOC(STOD((cQryFER)->RHJ_DTFIM)))//Periodo Aquisitivo
oSection2:Cell("REL_PERFER"):SetValue(DTOC(STOD((cQryFER)->RHJ_DTINI))+" A "+DTOC(STOD((cQryFER)->RHJ_DTINI)+(cQryFER)->RHJ_DIASPG))//Periodo de Gozo de Ferias
oSection2:Cell("REL_DIASFE"):SetValue(STRZERO((cQryFER)->RHJ_DIASPG,3)) //Dias de ferias
If cPaisLoc == "ARG"
	oSection2:Cell("REL_DTREC"):SetValue(DtoC(StoD((cQryFER)->RA_DTREC))) //Data de Reconhecimento
EndIf

oSection2:Printline()

oReport:FatLine()

For nX := 1 to Len(aLanca)
	oSection3:Cell("REL_VERBA"):SetValue(aLanca[nX,01])
	oSection3:Cell("REL_DESC"):SetValue(aLanca[nX,02])
	oSection3:Cell("REL_QTD"):SetValue(aLanca[nX,03])
	oSection3:Cell("REL_REMUN"):SetValue(aLanca[nX,04])
	If cPaisLoc == "ARG"
		oSection3:Cell("REL_NOREM"):SetValue(aLanca[nX,05])
	Else
		oSection3:Cell("REL_NOREM"):Hide()
	EndIf
	oSection3:Cell("REL_DEDUC"):SetValue(aLanca[nX,06])
	oSection3:Printline()
Next nX

oReport:FatLine()

oSection4:Cell("TOTVENC"):SetValue(TOTVENC)
oSection4:Cell("TOTDESC"):SetValue(TOTDESC)
If cPaisLoc == "ARG"
	oSection4:Cell("TOTNREM"):SetValue(TOTNREM)
Else
	oSection4:Cell("TOTNREM"):Hide()
EndIf
oSection4:Printline()

oReport:FatLine()

oSection5:Cell("TOTNET"):SetValue((TOTVENC+TOTNREM)-TOTDESC)
oSection5:PrintLine()

oReport:FatLine()

oSection6:Cell("FOOTLIN1"):SetValue(OemToAnsi(STR0024) + DESC_FIL) //"Recebi da: "
oSection6:Cell("FOOTLIN2"):SetValue(OemToAnsi(STR0025) + StrZero(Day(STOD((cQryFER)->RHI_DTPAGO)),2) +OemToAnsi(STR0027) + MesExtenso(MONTH(StoD((cQryFER)->RHI_DTPAGO))) + OemToAnsi(STR0027) + STR(YEAR(StoD((cQryFER)->RHI_DTPAGO)),4)+",") //"em: " ### " de " ### " de "
oSection6:Cell("FOOTLIN3"):SetValue(OemToAnsi(STR0026) + AllTrim(MV_SIMB1) + " " + AllTrim(TRANS(((TOTVENC+TOTNREM)-TOTDESC),"@E 999,999,999.99")) + " ( " + AllTrim(Extenso((TOTVENC+TOTNREM)-TOTDESC,.F.)) + " ) " )  //"a importancia de: "

oSection6:PrintLine()

If !Empty(DESC_MSG1)
	oSection7:Cell("DESC_MSG1"):SetValue(DESC_MSG1)
Else
	oSection7:Cell("DESC_MSG1"):Disable()
EndIf
If !Empty(DESC_MSG2)
	oSection7:Cell("DESC_MSG2"):SetValue(DESC_MSG2)
Else
	oSection7:Cell("DESC_MSG2"):Disable()
EndIf
If !Empty(DESC_MSG3)
	oSection7:Cell("DESC_MSG3"):SetValue(DESC_MSG3)
Else
	oSection7:Cell("DESC_MSG3"):Disable()
EndIf
If !Empty(DESC_MSG4)
	oSection7:Cell("DESC_MSG4"):SetValue(DESC_MSG4)
Else
	oSection7:Cell("DESC_MSG4"):Disable()
EndIf

oSection7:PrintLine()

oSection8:Cell("FOOTFIM"):SetValue(Left(UPPER(AllTrim(DESC_CID)),40) + ", " + StrZero(Day(StoD((cQryFER)->RHI_DTPAGO)),2) + OemToAnsi(STR0027) + MesExtenso(MONTH(STOD((cQryFER)->RHI_DTPAGO))) + OemToAnsi(STR0027) + STR(YEAR(STOD((cQryFER)->RHI_DTPAGO)),4)+".") //### " de " ### " de "

oSection8:PrintLine()

oReport:SkipLine()

oSection9:Cell("FIRMA"):SetValue(Replicate("_",80))

oSection9:PrintLine()

oSection9:Cell("FIRMA"):SetValue(OemToAnsi(STR0028))  //"Assinatura do Funcionário"

oSection9:PrintLine()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpFerFiltro³ Autor ³ Leandro Drumond      ³ Data ³ 14.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro da Consulta Padrao RCHFER                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gpFerFiltro()   					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gpFerFiltro()
Local aArea	  := GetArea()
Local cFiltro := ""

If Empty(__cRotSRY)
	DbSelectArea("SRY")
	DbSeek(xFilial("SRY"))
	While !Eof()
		If SRY->RY_TIPO == "3"
			__cRotSRY := SRY->RY_CALCULO
			Exit
		EndIf
		DbSkip()
	EndDo
	RestArea(aArea)
EndIf

cFiltro := "@#(RCH->RCH_ROTEIR == '" + __cRotSRY + "')@#"

Return ( cFiltro )
