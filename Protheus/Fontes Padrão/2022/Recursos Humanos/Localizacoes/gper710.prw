#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER710.CH"
#INCLUDE "REPORT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER710    ºAutor   ³Erika Kanamori      º Data  ³  03/19/08     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geração da Planilla de Aportes AFP´s                             º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Luciana     |03/08/09|18153/2009 |Ajuste no Relatorio Aportes AFP para      |±±
±±|            |        |           |considerar os dias proporcionais em caso  |±±
±±|            |        |           |admissao e demissao no mes que esta sendo |±±
±±|            |        |           |gerado o relatorio                        |±±
±±|Luciana     |21/09/09|22681/2009 |Tratamento para considerar os dias propor-|±±
±±|            |        |           |cionais em caso de faltas sem justificati-|±±
±±|            |        |           |vas.                                      |±±
±±|Luciana     |04/12/09|28462/2009 |Tratamento para considerar os dias propor-|±±
±±|            |        |           |cionais baseados no campo R9_Desc da tabe-|±±
±±|            |        |           |la SR9 nos casos de admissao e demissao.  |±±
±±|Alex        |29/12/09|30658/2009 |Adaptação para a Gestão corporativa       |±±
±±|            |        |           |respeitar o grupo de campos de filiais.   |±±
±±|L.Trombini  |20/06/11|006600/2011|Inclusao e ajustes de colunas de acordo   |±±
±±|            |        |           |com o novo layout do relatorio            |±±
±±|Claudinei S.|09/01/12|022252/2011|Ajuste para a padronização da impressão em|±±
±±|            |        |     TDPBYP|paisagem e do cabeçalho em Ano/Mes/Dia.   |±±
±±|Claudinei S.|31/10/12|027383/2012|Ajuste nas colunas 21,22,23 e 24 conforme |±±
±±|            |        |     TG2014|leiaute.                                  |±±
±±|M.Silveira  |19/02/13|     TGJFA1|Ajustes p/disponibilizar os campos NUA/CUA|±±
±±|            |        |           |EXT e DEPTO que sao exigidos por lei.     |±±
±±³            ³        ³           ³                                          ³±±
±±³Jonathan Glz³06/05/15³ PCREQ-4256³Se elimina la funcion AjustaSX1T,la cual  ³±±
±±³            ³        ³           ³realiza la modificacion aldiccionario de  ³±±
±±³            ³        ³           ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³        ³           ³estructura de SXs para version 12         ³±±
±±³            ³        ³           ³Se cambia grupo de preguntas a GPR710A    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER710()

Local oReport 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private aReturn 	:={ , 1,, 2, 2, 1,"",1 }
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao IMPR                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo	    := STR0024		//"Planilla de Aportes AFP´s"
Private cSubTitulo  := ""
Private nTipo		:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Acesso do Usuario                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cAcessaSRA	:= &( " { || " + ChkRH( "GPER710" , "SRA" , "2" ) + " } " )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //  Tipo de Relatorio(AFP Prevision ou Futuro³
³ mv_par02        //  Filial De						           ³
³ mv_par03        //  Filial Ate					           ³
³ mv_par04        //  Mes/Ano Competencia Inicial?             |
³ mv_par05        //  Matricula De                             ³
³ mv_par06        //  Matricula Ate                            ³
³ mv_par07        //  Centro de Custo De                       ³
³ mv_par08        //  Centro de Custo Ate                      ³
³ mv_par09        //  Nome De                                  ³
³ mv_par10        //  Nome Ate                                 ³
³ mv_par11        //  Situações a imp?                         ³
³ mv_par12        //  Categorias a imp?                        ³
³ mv_par13        //  Quantidade de dias cotados?              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   := aReturn[8]

Pergunte("GPR710A",.F.)
oReport := ReportDef(@oReport)
oReport:PrintDialog()

Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ R.H. - Tatiane Matias ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(oReport)

Local oSection1
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//"Obs.: Debe imprimirse un Formulario Mensual para cada Filial."
Local cString		:= "SRA"        // alias do arquivo principal (Base)
Local aOrd      	:= {STR0004,STR0005,STR0006}		//"Sucursal + Matricula"###"Sucursal + C. Costo"###"Sucural + Nombre"
Local cApelPat	:= "" 
Local cApelMat	:= ""
Local cApelCas	:= ""
Local cPriNom	:= ""
Local cSegNom	:= ""
Local cMes 		:= ""
Local cAno		:= ""

	cMes	 	:= Left(MV_PAR04,02)
	cAno		:= Right(MV_PAR04,04)
	
	If Empty(MV_PAR04)
		cMes := Right( AnoMes(dDataBase),2 )
		cAno := Left( AnoMes(dDataBase),4 )
	EndIf

	cSubTitulo := STR0007+ cAno+"/"+cMes+"/"+Transform(f_UltDia(CtoD("01/"+cMes+"/"+cAno)),"99") //"GESTION/MES/DIA : "
	Titulo := IIf(nTipo==1, STR0022  + " - " + cSubTitulo , STR0021 + " - " + cSubTitulo )//"Planilla de Aportes AFP´s Previsión"
					        				 //ou "Planilla de Aportes AFP´s Futuro de Bolivia"

	//-- Relatorio
	oReport:= TReport():New("GPER710",OemToAnsi(Titulo),"GPR710A",{|oReport| GR710Imp(oReport)}, Titulo)

	oReport:SetTotalInLine(.F.)
	oReport:PageTotalInLine(.T.)
	oReport:PageTotalBefore(.T.)   
                 		
		//-- Section 1
		//-- 
		//-- ------------------------------------------------------------
		//--   
		oSection1:= TRSection():New(oReport,"",{},aOrd)
		oSection1:SetTotalInLine(.F.)
			//-- Celulas			
			TRCell():New(oSection1, "RA_TIPODOC",  cString, "TIPO"               ,, 25  ,,,"CENTER", , , , , .T. , , , .T.)   //"TIPO" 
			TRCell():New(oSection1, "RA_RG",       cString, "NUMERO"             ,, 50  ,,,"CENTER", , , , , .T. , , , .T.)   //"NUMERO"
			TRCell():New(oSection1, "RA_NATURAL",  cString, "EXT" 	             ,, 25  ,,,"CENTER", , , , , .T. , , , .T.)  //"EXT"
			TRCell():New(oSection1, "RA_NRNUA",    cString, "NUA/CUA"            ,, 50  ,,,"CENTER", , , , , .T. , , , .T.)  //"NUA/CUA"
			TRCell():New(oSection1, "RA_PRISOBR",  cString, "APELLIDO PATERNO"   ,, 100 ,,,"CENTER", , , , , .T. , , , .T.)  //"APELLIDO PATERNO"
			TRCell():New(oSection1, "RA_SECSOBR",  cString, "APELLIDO MATERNO"   ,, 100 ,,,"CENTER", , , , , .T. , , , .T.)  //"APELLIDO MATERNO"
			TRCell():New(oSection1, "RA_APELIDO",  cString, "APELLIDO DE CASADA" ,, 100 ,,,"CENTER", , , , , .T. , , , .T.)  //"APELLIDO DE CASADA"
			TRCell():New(oSection1, "RA_PRINOME",  cString, "PRIMER NOMBRE"      ,, 100 ,,,"CENTER", , , , , .T. , , , .T.)  //"PRIMEIRO NOME"
			TRCell():New(oSection1, "RA_SECNOME",  cString, "SEGUNDO NOMBRE"       ,, 100 ,,,"CENTER", , , , , .T. , , , .T.)  //"SEGUNDO NOME"
			TRCell():New(oSection1, "NOVEDAD",     cString, "NOVEDAD"            ,, 50  ,,,"CENTER", , , , , .T. , , , .T.)  //"NOVEDAD"
			TRCell():New(oSection1, "FECHNOVEDAD", cString, "FECH-NOVEDAD"       ,, 50  ,,,"CENTER", , , , , .T. , , , .T.)  //"FECH-NOVEDAD"
			TRCell():New(oSection1, "DIAS-COT",    cString, "DIAS-COT"           ,, 50  ,,,"CENTER", , , , , .T. , , , .T.)  //"DIAS-COT"
			TRCell():New(oSection1, "nVCol21",     cString, "TOTAL GANADO"       ,, 90  ,,,"CENTER", , , , , .T. , , , .T.)  //Total Ganado (21) RD_VALOR
			TRCell():New(oSection1, "TIPO_COTIZANTE",     cString, "TIPO COTIZANTE"   ,, 110  ,,,"CENTER", , , , , .T. , , , .T.)  //Tipo Cotizante (21) RD_VALOR						
			TRCell():New(oSection1, "RA_TPSEGUR",  cString, "TP ASEGURADO"        ,, 90  ,,,"CENTER", , , , , .T. , , , .T.)  //"TP Segurado"
			TRFunction():New(oSection1:Cell("RA_TIPODOC"),,"COUNT",,,,,.F.,.T.,.T.)
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPFUT    ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function GR710Imp(oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Objeto
Local oSection1 	:= oReport:Section(1)
local cInicio		:= ""
Local cFim 			:= ""
Local cAntFil 		:= ""
Local cFilAux
Local nSavRec
Local nSavOrdem
Local aPerAberto 	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {}
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias   	:= ""
Local cQuery
Local cCateg  	:= ""
Local cSitu   	:= ""
Local cAliasSR9 := "QSR9"
Local cPeriodos
Local aStruct  	:= {}
Local lQuery  	:= .F.
Local lJubilac	:= .F.
Local lMaior	:= .F.
Local lVerba	:= .F.
//variaveis para impressão
Local nFunc 		:= 0
Local cNOVEDAD 	:= ""
Local cFechNovedad:= ""
Local cTipoCI		:= ""
Local cNumNua		:= ""
Local nVCol21     := 0
Local nVCol22     := 0
Local nVCol23     := 0
Local nVCol24     := 0
Local nAux
Local nDiasProp := 0
Local nDias 	:= 0
Local nTotDias	:= 0
Local dAdmissa	:= ""
Local dDemissa	:= ""

Local nCol21Tot   := 0
Local nCol22Tot   := 0
Local nCol23Tot   := 0
Local nCol24Tot   := 0
Local lReg		:= .F.
Local aSR9    	:= {}  // Centro de Custo
Local cFilialDe   := ""
Local cFilialAte  := ""
Local cMes 		:= ""
Local cAno		:= ""
Local cMatDe      := ""
Local cMatAte     := ""
Local cMesAno	:= ""
Local cCustoDe    := ""
Local cCustoAte   := ""
Local cNomeDe     := ""
Local cNomeAte    := ""
Local cSit        := ""
Local cCat        := ""
Local nQtdDias	:= 0
Local cQrySRA := "SRA"
Local cQrySRD	:= "SRD"
Local cAliasRC	:= "SRC"

	
	nTipo 		:= MV_PAR01
	cFilialDe 	:= MV_PAR02
	cFilialAte  := MV_PAR03
	cMes	 	:= Left(MV_PAR04,02)
	cAno		:= Right(MV_PAR04,04)
	cMatDe		:= MV_PAR05
	cMatAte     := MV_PAR06
	cCustoDe    := MV_PAR07
	cCustoAte   := MV_PAR08
	cNomeDe     := MV_PAR09
	cNomeAte    := MV_PAR10
	cSit        := MV_PAR11
	cCat        := MV_PAR12
	cMesAno		:= MV_PAR04

//Inicializa o mnemonico que ira armazenar as verbas de faltas a serem consideradas no tratamento.
SetMnemonicos(NIL,NIL,.T.,"P_DESCFALT")
cAcessaSRA	:= &( " { || " + ChkRH( "GPERFUT" , "SRA" , "2" ) + " } " )

#IFDEF TOP
	lQuery := .T.
#ELSE
    cQrySRA:= "SRA"
	dbSelectArea("SRA")
	nSavRec   := RecNo()
	nSavOrdem := IndexOrd()
#ENDIF

If nOrdem == 1
	If lQuery
		cQueryOrd := "RA_FILIAL, RA_MAT"
	Else
		dbSetOrder(1)
		SRA->( dbSeek( cFilialDe + cMatDe, .T. ) )
	Endif
	cInicio  := "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_MAT"
	cFim     := cFilialAte + cMatAte
Else
	If nOrdem == 2
		If lQuery
			cQueryOrd := "RA_FILIAL, RA_CC, RA_MAT"
		Else
			dbSetOrder(2)
			SRA->( dbSeek( cFilialDe + cCustoDe + cMatDe, .T. ) )
		Endif
		cInicio  := "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_CC + (cQrySRA)->RA_MAT"
		cFim     := cFilialAte + cCustoAte + cMatAte
	Elseif nOrdem == 3
		If lQuery
			cQueryOrd := "RA_FILIAL + RA_NOME + RA_MAT"
		Else
			dbSetOrder(3)
			SRA->( dbSeek( cFilialDe + cNomeDe + cMatDe, .T.) )
		Endif
		cInicio	:= "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_NOME + (cQrySRA)->RA_MAT"
		cFim	:= cFilialAte + cNomeAte + cMatAte
	Endif
Endif

If lQuery
	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes
	cAlias := "SRA"
	cQrySRA := "QSRA"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao e Categoria em formato para SQL              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cSitu   := "("
	For nAux := 1 To (Len( cSit )-1)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu 	+= "'" + Substr( cSit, len(cSit)-1, 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

	//montagem da query
	cQuery := "SELECT "
 	cQuery += " RA_FILIAL, RA_MAT, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_NOME, RA_RG, RA_TIPODOC, RA_NRNUA, RA_NATURAL,"
 	cQuery += " RA_ADMISSA, RA_DEMISSA, RA_NASC, RA_TPAFP, RA_AFPOPC, RA_HRSMES, RA_CATFUNC, RA_JUBILAC, RA_TPSEGUR, RA_APELIDO, RA_RIESPRO"
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
	cQuery += "  AND "
	cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += "  AND "
	cQuery += " RA_TPAFP = '" + iif(nTipo == 1, "1", "2") + "'"
	cQuery += "  AND "
	cQuery += " RA_SITFOLH IN " + cSitu
	cQuery += "  AND "
	cQuery += " RA_CATFUNC IN " + cCateg
	cQuery += " AND "
	cQuery += " D_E_L_E_T_ = ' '
	cQuery += " ORDER BY " + cQueryOrd

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux                                   '
	Endif

	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())
Endif

	oReport:IncMeter()

While (cQrySRA)->( !Eof() .And. &cInicio <= cFim )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua de Processamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	If oReport:Cancel()
		Exit
	EndIf   


	cFil	:= (cQrySRA)->RA_FILIAL
	cMat	:= (cQrySRA)->RA_MAT
	dAdmissa :=(cQrySRA)->RA_ADMISSA
	dDemissa :=(cQrySRA)->RA_DEMISSA

	If cAntFil <> (cQrySRA)->RA_FILIAL      //se a filial eh diferente da q acabou de imprimir, imprime rodape e
											// seta nLinha para imprimir as informacoes em uma nova folha
			
		//carrega periodo da competencia selecionada
		cFilAux:= (cQrySRA)->RA_FILIAL
		fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )
		If  Len(aPerTodos) < 1
			cFilAux:= Space(FwGetTamFilial)
			fRetPerComp( cMes , cAno , cFilAux , , , @aPerAberto , @aPerFechado , @aPerTodos )
		Endif
		If Empty(aPerTodos)       //Verifica se existem períodos validos
			Return
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Variaveis Codigos Da Folha                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
			Return
		Endif

		nCol21Tot   :=	0
		nCol22Tot   := 	0
		nCol23Tot   := 	0
		nCol24Tot   := 	0
		nFunc		:= 	0

		cAntFil := (cQrySRA)->RA_FILIAL

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !lQuery .And. ((SRA->RA_MAT < cMatDe)   .Or. (SRA->RA_MAT > cMatAte)    .Or. ;
		(SRA->RA_CC  < cCustoDe) .Or. (SRA->RA_CC  > cCustoAte)  .Or. ;
		(SRA->RA_NOME < cNomeDe) .Or. (SRA->RA_NOME > cNomeAte)  .Or. ;
		!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit))
			SRA->(dbSkip(1))
			Loop
	EndIf

		//-- Buscar a maior data dos registros para retornar os registros
		cDelet := Iif(TcSrvType() != "AS/400", "%D_E_L_E_T_ = ' '%", "%@DELETED@ = ' '%" )
		BeginSql ALIAS cAliasSR9
			SELECT R9_FILIAL, R9_MAT, R9_CAMPO, R9_DESC
			FROM %table:SR9%
			WHERE R9_FILIAL = %exp:cFil%
			  AND R9_MAT = %exp:cMat%
			  AND ( R9_CAMPO = 'RA_ADMISSA' OR R9_CAMPO = 'RA_DEMISSA')
			  AND %exp:cDelet%

		EndSql

   		aSR9 := {}
		While (cAliasSR9)-> (!EOF())
			rFil	:= (cAliasSR9)->R9_FILIAL
			rMat	:= (cAliasSR9)->R9_MAT
			dCampo	:= (cAliasSR9)->R9_CAMPO
   		 	dData	:= cTod(Substr((cAliasSR9)->R9_DESC,1,2)+"/"+Substr((cAliasSR9)->R9_DESC,4,2)+"/"+Substr((cAliasSR9)->R9_DESC,7,4))

	    	Aadd (aSR9,{rFil,rMat,dCampo,dData})

		(cAliasSR9)-> (dbSkip())
		Enddo
		(cAliasSR9)->(DbCloseArea())

		For nAux = 1 to Len(aSR9)
   			If MesAno(aSR9[nAux][4]) == cAno+cMes
				If aSR9[nAux][3] == "RA_ADMISSA"
					dAdmissa := aSR9[nAux][4]
				Endif
				If aSR9[nAux][3] == "RA_DEMISSA"
					dDemissa := aSR9[nAux][4]
				Endif
           	Endif
   		Next nAux
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( (cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		dbSelectArea(cQrySRA)
		(cQrySRA)->( dbSkip() )
   		Loop
	Endif

	//zera variaveis para cada funcionario
//		nBaseCot	:= 0
		nDiasProp	:= 0
		nTotDias	:= 0
		nVCol21     := 0

	//quantidade de dias padrao para todos os funcionarios
   		nQtdDias:= 30

	If lQuery
		cAlias := "SRD"
		cAliasRC := "SRC"
		cQrySRD := "QSRD"

		//busca periodos para formato Query
		If Len(aPerTodos)>0
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerTodos)-1)
				cPeriodos += "'" + aPerTodos[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerTodos[len(aPerTodos)][1]+"')"
		EndIf
		//montagem da query
		cQuery := "SELECT "
		cQuery += " RD_FILIAL FILIAL, RD_MAT MAT, RD_PROCES PROCES, RD_ROTEIR ROTEIR, RD_PERIODO PERIODO, RD_SEMANA SEMANA, RD_HORAS HORAS, RD_VALOR VALOR, RD_PD PD, RD_TIPO1 TIPO1 "
		cQuery += " FROM " + RetSqlName(cAlias)
		cQuery += " WHERE "
		cQuery += " RD_FILIAL = '" + cAntFil + "'"
		cQuery += " AND "
		cQuery += " RD_MAT ='" + (cQrySRA)->RA_MAT + "'"
		If !Empty(cPeriodos)
			cQuery += " AND "
			cQuery += " RD_PERIODO IN " + cPeriodos
		EndIf
		cQuery += " AND "
		cQuery += " D_E_L_E_T_ = ' '"

		cQuery += " UNION ALL "

		cQuery += "SELECT "
		cQuery += " RC_FILIAL FILIAL, RC_MAT MAT, RC_PROCES PROCES, RC_ROTEIR ROTEIR, RC_PERIODO PERIODO, RC_SEMANA SEMANA, RC_HORAS HORAS, RC_VALOR VALOR, RC_PD PD, RC_TIPO1 TIPO1 "
		cQuery += " FROM " + RetSqlName(cAliasRC)
		cQuery += " WHERE "
		cQuery += " RC_FILIAL = '" + cAntFil + "'"
		cQuery += " AND "
		cQuery += " RC_MAT ='" + (cQrySRA)->RA_MAT + "'"
		If !Empty(cPeriodos)
			cQuery += " AND "
			cQuery += " RC_PERIODO IN " + cPeriodos
		EndIf
		cQuery += " AND "
		cQuery += " D_E_L_E_T_ = ' '"
		
		cQuery += " ORDER BY FILIAL, MAT, PROCES, ROTEIR, PERIODO, SEMANA"

		cQuery := ChangeQuery(cQuery)
		aStruct := (cAlias)->(dbStruct())
		If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
			For nAux := 1 To Len(aStruct)
				If ( aStruct[nAux][2] <> "C" )
					TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
				EndIf
			Next nAux
		Endif
	Else
		dbSelectArea(cQrySRD)
		dbSetOrder(5)
	Endif

	nIdade := 0
	
	cTpcotiz := ""
	
	If ( (cQrySRA)->RA_AFPOPC == "1234" .AND. (cQrySRA)->RA_RIESPRO == "S" )
		cTpcotiz := "1"
	ElseIf ( (cQrySRA)->RA_AFPOPC == "12*4" .AND. (cQrySRA)->RA_RIESPRO = "N" )
		cTpcotiz := "8"
	ElseIf ( (cQrySRA)->RA_AFPOPC == "1*34" .AND. (cQrySRA)->RA_RIESPRO == "S")
		cTpcotiz := "C"
	ElseIf ( (cQrySRA)->RA_AFPOPC == "1**4" .AND. (cQrySRA)->RA_RIESPRO = "N")
		cTpcotiz := "D"
	EndIf	
	
	For nAux:=1 to Len(aPerTodos)
		(cQrySRD)->(dbGoTop())
		If !lQuery
			dbSeek((cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerTodos[nAux][7])
		Else
			While (cQrySRD)->(!Eof()) .And. !((cQrySRA)->(RA_FILIAL+RA_MAT)+aPerTodos[nAux][7]== (cQrySRD)->(FILIAL+MAT+PROCES))
		   		(cQrySRD)->(dbSkip())
			End
		Endif
		nIdade:= Calc_Idade( aPerTodos[len(aPerTodos)][6] , (cQrySRA)->RA_NASC )
		While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT)+aPerTodos[nAux][7]== (cQrySRD)->(FILIAL+MAT+PROCES)

		  
		  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Contribuinte de APF o campo RA_APFOPC=1 e obrigatorio, nao sendo aposentado a opcao 2 tambem se torna   ³
			³obrigatoria, sendo <65 vai para a coluna 21                ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			lJubilac := (cQrySRA)->RA_JUBILAC == "1"
			lMaior := nIdade >= 65
			lVerba := (cQrySRD)->PD == aCodFol[731,1]

		    If lVerba
				lReg	:= .T.
				If lJubilac .AND. "1" $ (cQrySRA)->RA_AFPOPC
					If !lMaior
						nVCol23 := (cQrySRD)->VALOR
						lReg	:= .T.
					Elseif lMaior
						nVCol24 := (cQrySRD)->VALOR
						lReg	:= .T.
			        EndIF
			    ElseiF !lJubilac .AND. "2" $ (cQrySRA)->RA_AFPOPC
					If !lMaior
						nVCol21 := (cQrySRD)->VALOR
						lReg	 := .T.
					Elseif lMaior
						nVCol22  := (cQrySRD)->VALOR
						lReg	 := .T.
					EndIf
				EndIf
			EndIf
			
			If  Month(dAdmissa) == Val(cMes) .OR. Month(dDemissa)== Val(cMes)  .And. Year(dAdmissa) == Val(cAno) .Or. Year(dDemissa) == Val(cAno)
				If (cQrySRD)->PD == aCodFol[0031,1]   //=Tratamento para mensalistas admissao
					nDiasProp := (cQrySRD)->HORAS
				Elseif (cQrySRD)->PD == aCodFol[0032,1] //=Tratamento para horistas admissao
					nDias:= (cQrySRA)->RA_HRSMES / 30
					nDiasProp := (cQrySRD)->HORAS / nDias
				Elseif (cQrySRD)->PD == aCodFol[0048,1] //=Tratamento para mensalistas e horistas na rescisao
					nDiasProp := (cQrySRD)->HORAS
				Elseif (cQrySRD)->PD == aCodFol[0165,1] .OR. (cQrySRA)->RA_CATFUNC == "C"  //=Tratamento para comissionados admissao e rescisao
					If Month(dAdmissa) == Val(cMes)
						nDiasProp := ( f_UltDia(aPerTodos[nAux][6]) -  Day(dAdmissa) + 1 )
					Else
						nDiasProp := Day( dDemissa )
					Endif
				Endif
			Endif
			//Verifica se a verba esta contida no mnemonico que armazena as verbas de Falta
			If (cQrySRD)->PD $ P_DESCFALT
				If  (cQrySRD)->TIPO1 $ "VD"
					nTotDias :=  (cQrySRD)->HORAS
					nQtdDias := 30 - nTotDias
				Else
					nDias:= (cQrySRA)->RA_HRSMES / 30
					nTotDias := ((cQrySRD)->HORAS / nDias )
					nQtdDias := 30 - nTotDias
				Endif
				If nDiasProp > 0
					nQtdDias := nDiasProp - nTotDias
				Endif
			Endif							
			(cQrySRD)->(dbSkip())
		End	
	Next nAux
	(cQrySRD)->(dbCloseArea())	

	If lReg
		nFunc+=1
		nCol21Tot 	+=  nVCol21
		nCol22Tot   += 	nVCol22
		nCol23Tot   += 	nVCol23
		nCol24Tot   += 	nVCol24

		cTipoCI := If( Empty((cQrySRA)->RA_TIPODOC) .Or. (cQrySRA)->RA_TIPODOC=="1", "CI", "PAS" )
		cNumNua := (cQrySRA)->RA_NRNUA	  				
			
		oSection1:Init(.F.)
		oReport:IncMeter()
		
		If oReport:Cancel()
			Exit
		EndIf 	
		
		//Funcionarios admitidos e demitidos no Mes/Ano de referencia
	 	If ( Month(dDemissa)== Val(cMes) .And.  Year(dDemissa) == Val(cAno) ) .And. ( Month(dAdmissa) == Val(cMes) .And. Year(dAdmissa) == Val(cAno) )
			cNOVEDAD:= "R"
			cFechNovedad:= DtoC(dDemissa)
			nQtdDias := nDiasProp
		//Funcionarios admitidos no Mes/Ano de referencia
		ElseIf Month(dAdmissa) == Val(cMes) .And. Year(dAdmissa) == Val(cAno)
			cNOVEDAD := "I"
		   	cFechNovedad:= DtoC(dAdmissa)
			nQtdDias := nDiasProp
		//Funcionarios demitidos no Mes/Ano de referencia
		Elseif Month(dDemissa)== Val(cMes) .And.  Year(dDemissa) == Val(cAno)
			cNOVEDAD:= "R"
			cFechNovedad:= DtoC(dDemissa)
			nQtdDias := nDiasProp	
		Else
			fBuscaAutrz(cFil, cMat , CtoD("01/"+cMes+"/"+cAno), LastDate(CtoD("01/"+cMes+"/"+cAno)))
		Endif	
		
		cApelPat := SubStr((cQrySRA)->RA_PRISOBR,1,10)
		cApelMat := SubStr((cQrySRA)->RA_SECSOBR,1,10)
		cApelCas := SubStr((cQrySRA)->RA_APELIDO,1,10)
		cPriNom	 := SubStr((cQrySRA)->RA_PRINOME,1,10)
		cSegNom	 := SubStr((cQrySRA)->RA_SECNOME,1,10)		

		oSection1:Cell("RA_TIPODOC"):SetValue(cTipoCI)  //"TIPO" 
		oSection1:Cell("RA_RG"):SetValue((cQrySRA)->RA_RG)    	//"NUMERO"
		oSection1:Cell("RA_NATURAL"):SetValue((cQrySRA)->RA_NATURAL)  //"EXT"
		oSection1:Cell("RA_NRNUA"):SetValue(cNumNua)  	//"NUA/CUA"
		oSection1:Cell("RA_PRISOBR"):SetValue(cApelPat)  //"APELLIDO PATERNO"
		oSection1:Cell("RA_SECSOBR"):SetValue(cApelMat)  //"APELLIDO MATERNO"
		oSection1:Cell("RA_APELIDO"):SetValue(cApelCas)  //"APELLIDO DE CASADA"
		oSection1:Cell("RA_PRINOME"):SetValue(cPriNom)  //"PRIMEIRO NOME"
		oSection1:Cell("RA_SECNOME"):SetValue(cSegNom)  //"SEGUNDO NOME"		
		oSection1:Cell("NOVEDAD"):SetValue(cNOVEDAD)  			//"NOVEDAD"
		oSection1:Cell("FECHNOVEDAD"):SetValue(cFechNovedad)//"FECH-NOVEDAD"
		oSection1:Cell("DIAS-COT"):SetValue(Transform(nQtdDias,"99"))  //"DIAS-COT"	
		IF(cTpcotiz == "1")
			oSection1:Cell("nVCol21"):SetValue(nVCol21)  //Total Ganado (21) RD_VALOR
		ELSEIF(cTpcotiz == "8")
			oSection1:Cell("nVCol21"):SetValue(nVCol22)  //Total Ganado (21) RD_VALOR
		ELSEIF(cTpcotiz == "C")
			oSection1:Cell("nVCol21"):SetValue(nVCol23)  //Total Ganado (21) RD_VALOR
		ELSEIF(cTpcotiz == "D")
			oSection1:Cell("nVCol21"):SetValue(nVCol24)  //Total Ganado (21) RD_VALOR
		ELSE
			oSection1:Cell("nVCol21"):SetValue(0)
		ENDIF	

		oSection1:Cell("TIPO_COTIZANTE"):SetValue(cTpcotiz)  //Tipo Cotizante		
	    oSection1:Cell("RA_TPSEGUR"):SetValue((cQrySRA)->RA_TPSEGUR)  //"TP Segurado"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a linha                                        		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:PrintLine()
		oSection1:Finish()
	
		lReg         := .F.
		cFechNovedad := ""
		cNOVEDAD     := ""
Endif	

	(cQrySRA)->(dbSkip())
End
	If !lQuery
		dbSelectArea("SRA")
		dbSetOrder(nSavOrdem)
		dbGoTo(nSavRec)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o alias padrao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		If Select(cQrySRA) > 0
			(cQrySRA)->(dbCloseArea())
		Endif
	EndIf

Return


Static Function fBuscaAutrz(cFil, cMat ,  dDtaini, dDtafim)

Local cAliasAnt  := Alias()
Local cQuery8	:= ""
Local cAliasSr8	 := "SR8"
Local cDtaIni	:= dtos(dDtaini)
Local cDtaFim	:= dtos(dDtafim)

Static cFilRCM

DEFAULT cFilRCM	 := FwxFilial("RCM")

	cAliasSr8 	:= "QrySR8"
	cQuery8 	:= "SELECT * "
	cQuery8 	+= "FROM "+RetSqlName("SR8")+" SR8 "
	cQuery8 	+= "WHERE SR8.R8_FILIAL='"+cMat+"' AND "
	cQuery8 	+= "SR8.R8_MAT='"+cMat+"' AND "
	cQuery8 	+= "SR8.R8_DATAINI >='" + cDtaIni + "' AND SR8.R8_DATAFIM <='" + cDtaFim + "' "
	cQuery8 	+= "AND SR8.D_E_L_E_T_ = ' ' "
	cQuery8 	+= "ORDER BY "+SqlOrder(SR8->(IndexKey()))

	If Select(cAliasSr8) > 0
		(cAliasSr8)->( dbCloseArea() )
	Endif

	cQuery8 		:= ChangeQuery(cQuery8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery8),cAliasSr8)

	dbSelectArea(cAliasSr8)
	(cAliasSr8)->(dbgotop())

	dbSelectArea( "SR8" )
	dbSeek( cFil + cMat)


	While (!Eof() .And. (cAliasSr8)->( R8_FILIAL + R8_MAT ) == (cFil + cMat))

        DbSelectArea( "RCM" )
        DbSetOrder( RetOrder( "RCM", "RCM_FILIAL+RCM_TIPO" ) )
        DbSeek( cFilRCM + (cAliasSr8)->R8_TIPOAFA, .F. )

        If RCM->RCM_TPIMSS $ "C/A/P"
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  | La clave para hacer la busca en las ausencias es el campo R8_DTBLEG, el importante es la  |
		  | fecha en el mes selecionado. Ej: caso tenga una ausencia con fecha inicio y fecha fin     |
		  | dentro del mes 02, pero la fecha de autori. es en mes 03, esa ausencia debera salir en el |
		  | 03.																						  ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    		If (cAliasSr8)->R8_DTBLEG >= Dtos(dDtaini) .And. (cAliasSr8)->R8_DTBLEG <= Dtos(dDtaFim)
	           	// Qdo la Ausencia esta com fecha anterior al mes buscado informa el primero dia del mes
	           	If (cAliasSr8)->R8_DATAINI < DtoS(dDtaini)
				 	cFechNovedad:= DtoC(dDtaini)
				 	nQtdDias    := 30
		           	cNOVEDAD		:="S"
		 		Else
		 			cFechNovedad:= DtoC(dDtaini)
					nQtdDias    := 30 - (day(dDtaini))
		           	cNOVEDAD		:="S"					
				Endif
	        Endif
	    Else//verifica se posui Ausencia No Remunerada durante todo el periodo pesquisado
	    	   	If RCM->RCM_TPIMSS == "L"
	        			If (cAliasSr8)->R8_DATAFIM >= DtoS(dDtafim) .And. (cAliasSr8)->R8_DATAINI <= DtoS(dDtaini)
	        				cNOVEDAD		:="L"
						 	cFechNovedad:= DtoC(dDtaini)
						 	nQtdDias	:= (cAliasSr8)->R8_DURACAO
						EndIf
	         	EndIf
	    Endif

	dbSelectArea(cAliasSr8)
	dbSkip()

	Enddo

	If Select(cAliasSr8) > 0
	 	(cAliasSr8)->( dbCloseArea() )
	Endif


	If !EMPTY(cAliasAnt)
		dbSelectArea(cAliasAnt)
	EndIf

	Return()


