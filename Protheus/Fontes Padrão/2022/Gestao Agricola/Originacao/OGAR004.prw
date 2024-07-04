#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGAR004.CH"

Static __aCompDin := {}
Static __aProds   := {}
Static __aCompPrd := {}
Static __cParHist := "2"

/*/{Protheus.doc} OGAR004
//Relatorio de Fixacoes
@author carlos.augusto
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
function OGAR004()
	Local oReport	:= Nil

	//Private cAliasTemp := Nil
	Private _cTabCtr := nil
	Private _aCpsBrowCt := nil
	Private cPergunta := "OGAR004001"

	If TRepInUse()
		If Pergunte( cPergunta, .T. )
			oReport := ReportDef()
			oReport:PrintDialog()
		EndIf
	EndIf

return .t.



/*/{Protheus.doc} MontaTabel
@author carlos.augusto
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
/*/
Static Function MontaTabel(aCpsBrow, aIdxTab)
	Local nCont 	:= 0
	Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

	//-- Busca no aCpsBrow as propriedades para criar as colunas
	For nCont := 1 to Len(aCpsBrow)
		aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
	Next nCont
	//-- Tabela temporaria de pendencias
	cTabela  := GetNextAlias()
	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
	oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
Return cTabela



/*/{Protheus.doc} fFixStatus
@author carlos.augusto
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipo, characters, descricao
@param cStatus, characters, descricao
@type function
/*/
static function fFixStatus(cTipo, cStatus )
	Local cFixStatus := ""

	if cStatus == "1" //Pendente
		cFixStatus := "3"
	elseif cStatus == "2" //trabalhando
		cFixStatus := "2"
	elseif cStatus == "5" //Em Aprovação Financeira
		cFixStatus := "6"
	elseif cStatus == "3"  //finalizado
		if cTipo == "2" //Fixação  
			cFixStatus := "7"
		elseif cTipo == "3" //Cancelamento
			cFixStatus := "8"
		elseif cTipo == "5" //Modificação
			cFixStatus := "9"	
		endif
	endif	

return cFixStatus



Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
	Local nX
	Local oBreak        := Nil

	_cFiltro := fMntFiltro() //apropria filtro
	__cParHist := MV_PAR13

	//campos blocos
	_aCpsBrowCt := {	{STR0005 , "FIX_STATUS"	, "C", 1, 0	, "@!"	},;	//"Reserva"
	{STR0006 , "TIPO_CTR"	, "C", 1	, 0	, "@!"	},;	//"Tipo CTR"
	{STR0055 , "GRUPO"	, "C", 1	, 0	, "@!"	},;	//"Grupo"
	{STR0056 , "ORDEM"	, "C", 1	, 0	, "@!"	},;	//"Ordem"
	{STR0007 , "NJR_CODCTR"	, TamSX3( "NJR_CODCTR" )[3]	, TamSX3( "NJR_CODCTR" )[1]	, TamSX3( "NJR_CODCTR" )[2]	, PesqPict("NJR","NJR_CODCTR") 	},;
	{STR0008 , "NJR_FILIAL"	, TamSX3( "NJR_FILIAL" )[3]	, TamSX3( "NJR_FILIAL" )[1]	, TamSX3( "NJR_FILIAL" )[2]	, PesqPict("NJR","NJR_FILIAL") 	},; //"Qtd. Take-Up"
	{AgrTitulo("NJR_CTREXT") , "NJR_CTREXT"	, TamSX3( "NJR_CTREXT" )[3]	, TamSX3( "NJR_CTREXT" )[1]	, TamSX3( "NJR_CTREXT" )[2]	, PesqPict("NJR","NJR_CTREXT") 	},;
	{STR0009 , "NNY_ITEM"	, TamSX3( "NNY_ITEM" )[3]	, TamSX3( "NNY_ITEM" )[1]	, TamSX3( "NNY_ITEM" )[2]	, PesqPict("NNY","NNY_ITEM") 	},;
	{STR0010 , "NNY_MESEMB"	, TamSX3( "NNY_MESEMB" )[3]	, TamSX3( "NNY_MESEMB" )[1]	, TamSX3( "NNY_MESEMB" )[2]	, PesqPict("NNY","NNY_MESEMB") 	},; // Mês/Embarque
	{STR0010 , "NNY_MEMBAR"	, TamSX3( "NNY_MEMBAR" )[3]	, TamSX3( "NNY_MEMBAR" )[1]	, TamSX3( "NNY_MEMBAR" )[2]	, PesqPict("NNY","NNY_MEMBAR") 	},; // Mês/Embarque Numero
	{STR0018 , "NJR_CODNGC"	, TamSX3( "NJR_CODNGC" )[3]	, TamSX3( "NJR_CODNGC" )[1]	, TamSX3( "NJR_CODNGC" )[2]	, PesqPict("NJR","NJR_CODNGC") 	},;
	{STR0011 , "NJR_VERSAO"	, TamSX3( "NJR_VERSAO" )[3]	, TamSX3( "NJR_VERSAO" )[1]	, TamSX3( "NJR_VERSAO" )[2]	, PesqPict("NJR","NJR_VERSAO") 	},;
	{STR0012 , "NJR_CODENT"	, TamSX3( "NJR_CODENT" )[3]	, TamSX3( "NJR_CODENT" )[1]	, TamSX3( "NJR_CODENT" )[2]	, PesqPict("NJR","NJR_CODENT") 	},;	//"Reserva"
	{STR0013 , "NJR_LOJENT"	, TamSX3( "NJR_LOJENT" )[3]	, TamSX3( "NJR_LOJENT" )[1]	, TamSX3( "NJR_LOJENT" )[2]	, PesqPict("NJR","NJR_LOJENT") 	},;
	{STR0014 , "NJR_NOMENT"	, TamSX3( "NJR_NOMENT" )[3]	, TamSX3( "NJR_NOMENT" )[1]	, TamSX3( "NJR_NOMENT" )[2]	, PesqPict("NJR","NJR_NOMENT") 	},;	//"Reserva"
	{STR0015 , "NJR_CODSAF"	, TamSX3( "NJR_CODSAF" )[3]	, TamSX3( "NJR_CODSAF" )[1]	, TamSX3( "NJR_CODSAF" )[2]	, PesqPict("NJR","NJR_CODSAF") 	},; //"Qtd. Take-Up"
	{STR0016 , "NJR_CODPRO"	, TamSX3( "NJR_CODPRO" )[3]	, TamSX3( "NJR_CODPRO" )[1]	, TamSX3( "NJR_CODPRO" )[2]	, PesqPict("NJR","NJR_CODPRO") 	},;	//"Reserva"
	{STR0017 , "NJR_DESPRO"	, TamSX3( "NJR_DESPRO" )[3]	, TamSX3( "NJR_DESPRO" )[1]	, TamSX3( "NJR_DESPRO" )[2]	, PesqPict("NJR","NJR_DESPRO") 	},;	//"Reserva"
	{STR0019 , "NJR_BOLSA"	, TamSX3( "NJR_BOLSA" )[3]	, TamSX3( "NJR_BOLSA" )[1]	, TamSX3( "NJR_BOLSA" )[2]	, PesqPict("NJR","NJR_BOLSA") 	},; //"Bolsa Ref."
	{STR0020 , "NNY_IDXNEG" , TamSX3( "NNY_IDXNEG" )[3]	, TamSX3( "NNY_IDXNEG" )[1]	, TamSX3( "NNY_IDXNEG" )[2]	, PesqPict("NNY","NNY_IDXNEG") 	},;  //Indice negocio
	{STR0021 , "NNY_IDXCTF" , TamSX3( "NNY_IDXCTF" )[3]	, TamSX3( "NNY_IDXCTF" )[1]	, TamSX3( "NNY_IDXCTF" )[2]	, PesqPict("NNY","NNY_IDXCTF") 	},;  //Indice Ct. Futuro
	{STR0022 , "NJR_QTDCTR"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},; //"Qtd. Take-Up"
	{STR0023 , "QTDAFIXAR"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},;  //agio folha
	{STR0024 , "QTDWORK"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},;  //agio folha
	{STR0025 , "NN8_VLRUNI"	, TamSX3( "NN8_VLRUNI" )[3]	, TamSX3( "NN8_VLRUNI" )[1]	, TamSX3( "NN8_VLRUNI" )[2]	, PesqPict("NN8","NN8_VLRUNI") 	},;  //agio folha
	{STR0026 , "TIPO_FIX"	, "C", 255	, 0	, "@!"	},;	//"Tipo Fixação"                            
	{STR0027 , "NJR_DATA"	, TamSX3( "NJR_DATA" )[3]	, TamSX3( "NJR_DATA" )[1]	, TamSX3( "NJR_DATA" )[2]	, PesqPict("NJR","NJR_DATA") 	},; //agio cor
	{STR0028 , "NNY_DTLFIX"	, TamSX3( "NNY_DTLFIX" )[3]	, TamSX3( "NNY_DTLFIX" )[1]	, TamSX3( "NNY_DTLFIX" )[2]	, PesqPict("NNY","NNY_DTLFIX") 	},; //agio cor
	{STR0029 , "NNY_DATINI"	, TamSX3( "NNY_DATINI" )[3]	, TamSX3( "NNY_DATINI" )[1]	, TamSX3( "NNY_DATINI" )[2]	, PesqPict("NNY","NNY_DATINI") 	},; //agio hvi
	{STR0030 , "NNY_DATFIM" , TamSX3( "NNY_DATFIM" )[3]	, TamSX3( "NNY_DATFIM" )[1]	, TamSX3( "NNY_DATFIM" )[2]	, PesqPict("NNY","NNY_DATFIM") 	},;
	{STR0031 , "N7C_QTAFIX" , TamSX3( "N7C_QTAFIX" )[3]	, TamSX3( "N7C_QTAFIX" )[1]	, TamSX3( "N7C_QTAFIX" )[2]	, PesqPict("N7C","N7C_QTAFIX") 	},;  //Integrado*/
	{STR0032 , "N7C_QTCAD" ,  TamSX3( "N7C_QTAFIX" )[3]	, TamSX3( "N7C_QTAFIX" )[1]	, TamSX3( "N7C_QTAFIX" )[2]	, PesqPict("N7C","N7C_QTAFIX") 	},;
	{STR0024 , "DESBANCO"   , TamSX3("X5_DESCRI")[3]    ,TamSX3("X5_DESCRI")[1] 	,TamSX3("X5_DESCRI")[2] 	, PesqPict("SX5","X5_DESCRI")	};   //Nome do banco
	} //fecha array _aCpsBrowCt

	fCompDisp(@_aCpsBrowCt, _cFiltro)
	fCompProd(@_aCpsBrowCt, _cFiltro)

	Processa({|| _cTabCtr := MontaTabel(_aCpsBrowCt, {{"1", "NJR_CODNGC+NJR_VERSAO+NNY_ITEM"},{"2", "NJR_CODPRO+FIX_STATUS"},{"3", "NJR_CODPRO+ORDEM+NNY_MEMBAR"}})},STR0002)//"Gerando Estrutura..."

	Processa({|| fLoadDados(_cFiltro)},STR0003)//"Buscando Fixações..."		  

	PreparaTT(_cTabCtr)


	oReport := TReport():New("OGAR004", STR0001, /* cPergunta */, {| oReport | PrintReport( oReport ) }, STR0004)//"Relatório de Fixações"/"Aguarde.... Carregando Dados"

	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()	
	oReport:SetTotalInLine(.F.)

	/*Monta as Colunas*/	
	oSection1 := TRSection():New( oReport, STR0009, _cTabCtr,,,,,,,,,,,,,,,0 ) 

	TRCell():New(oSection1,"NJR_DATA",  _cTabCtr,STR0058 ,"@!",TamSX3("NJR_DATA")[1]+1  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Data Fixação"
	TRCell():New(oSection1,"NJR_NOMENT",_cTabCtr,STR0014 ,"@!",TamSX3("NJR_NOMENT")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Nome"
	TRCell():New(oSection1,"NJR_CODSAF",_cTabCtr,STR0015 ,"@!",TamSX3("NJR_CODSAF")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Safra"
	TRCell():New(oSection1,"NJR_CTREXT",_cTabCtr,STR0034 ,"@!",TamSX3("NJR_CTREXT")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Cód Ctr Ext" 
	TRCell():New(oSection1,"NNY_MESEMB",_cTabCtr,STR0010 ,"@!",TamSX3("NNY_MESEMB")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Mês Emb" 
	TRCell():New(oSection1,"NJR_BOLSA" ,_cTabCtr,STR0019 ,"@!",TamSX3("N8C_DESCR")[1]   ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Bolsa"
	TRCell():New(oSection1,"NNY_IDXNEG",_cTabCtr,STR0020 ,"@!",TamSX3("NNY_IDXNEG")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Idx Neg"
	TRCell():New(oSection1,"NNY_IDXCTF",_cTabCtr,STR0021 ,"@!",TamSX3("NNY_IDXCTF")[1]  ,.T.,/*Block*/,,,"LEFT",.T.,,.F.)//"Idx Ctr Futuro"
	TRCell():New(oSection1,"DESBANCO" , _cTabCtr,STR0057 ,"@!",35  ,.T.,/*Block*/,,,"LEFT",.T.)//"Banco"		
	TRCell():New(oSection1,"N7C_QTAFIX",_cTabCtr,STR0062 ,PesqPict("N7C","N7C_QTAFIX")  ,TamSX3("N7C_QTAFIX")[1]+3,.T.,/*Block*/,,,"RIGHT",.T.,,.F.) //"Qtd Saldo"


	For nX := 1 To Len(__aCompDin)
		TRCell():New(oSection1,__aCompDin[nX][2],_cTabCtr,__aCompDin[nX][1]       ,__aCompDin[nX][3] ,TamSX3("NKA_VLRCOM")[1]+3,.T.,/*Block*/,,,"RIGHT",.T.)
	Next nX

	TRCell():New(oSection1,"NN8_VLRUNI",_cTabCtr,STR0036,PesqPict("NN8","NN8_VLRUNI"),TamSX3("NN8_VLRUNI")[1],.T.,/*Block*/,,,"RIGHT",.T.) //"Total"

	oBreak   := TRBreak():New(oSection1, "","", .F., 'NOMEBRK',  .F.)//"Totais"        

	TRFunction():New(oSection1:Cell("N7C_QTAFIX"),,'SUM',oBreak,,,,.F.,.F.,.F.,oSection1)

Return( oReport )


Static Function fMntFiltro()
	Local cFiltro := ""

	//trata os filtros
	if !Empty(MV_PAR01)
		cFiltro  =  "  AND NJR.NJR_FILIAL >= '" + MV_PAR01  + "'"
	EndIf
	if !Empty(MV_PAR02)
		cFiltro +=  "  AND NJR.NJR_FILIAL <= '" + MV_PAR02  + "'"
	EndIf
	if !Empty(MV_PAR03)
		cFiltro +=  "  AND NJR.NJR_CTREXT >= '" + MV_PAR03  + "'"
	EndIf
	if !Empty(MV_PAR04)
		cFiltro +=  "  AND NJR.NJR_CTREXT <= '" + MV_PAR04  + "'"
	EndIf
	if !Empty(MV_PAR05)
		cFiltro +=  "  AND NJR.NJR_CODPRO >= '" + MV_PAR05  + "'"
	EndIf
	if !Empty(MV_PAR06)
		cFiltro +=  "  AND NJR.NJR_CODPRO <= '" + MV_PAR06  + "'"
	EndIf
	if !Empty(MV_PAR11)
		cFiltro +=  "  AND NJR.NJR_CODSAF >= '" + MV_PAR11  + "'"
	EndIf
	if !Empty(MV_PAR12)
		cFiltro +=  "  AND NJR.NJR_CODSAF <= '" + MV_PAR12  + "'"
	EndIf
	if !Empty(MV_PAR07)
		cFiltro +=  "  AND NJR.NJR_DATA   >= '" + dTOs(MV_PAR07)  + "'"
	endif
	if !Empty(MV_PAR08)
		cFiltro +=  "  AND NJR.NJR_DATA   <= '" + dTOs(MV_PAR08)  + "'"
	endif
	if !Empty(MV_PAR09)
		cFiltro +=  "  AND NNY.NNY_DTLFIX >= '" + dTOs(MV_PAR09)  + "'"
	endif
	if !Empty(MV_PAR10)
		cFiltro +=  "  AND NNY.NNY_DTLFIX <= '" + dTOs(MV_PAR10)  + "'"
	endif

	if !Empty(MV_PAR14)
		cFiltro +=  "  AND NNY.NNY_MEMBAR >= '" + MV_PAR14  + "'"
	endif
	if !Empty(MV_PAR15)
		cFiltro +=  "  AND NNY.NNY_MEMBAR <= '" + MV_PAR15  + "'"
	endif

	cFiltro +=  "  AND NJR.NJR_CODNGC <> ''" //força para mostrar somente aqueles pelo processo novo

return cFiltro


Static Function fCompDisp(_aCpsBrowCt, cFiltro)
	Local cAliasNK7 := GetNextAlias()

	//trata o filtro
	cFiltro := "%" + cFiltro + "%"

	BeginSql Alias cAliasNK7

		SELECT NK7.NK7_CODCOM, NK7.NK7_DESABR, NK7.NK7_CALCUL, NK7.NK7_HEDGE
		FROM %Table:NK7% NK7
		WHERE NK7.%notDel%
		AND NK7.NK7_ATIVO   = "S"
		AND NK7.NK7_FIXAVE  = "0"
		AND (NK7.NK7_CALCUL = "P" OR NK7.NK7_CALCUL = "C" )
		GROUP BY NK7.NK7_CODCOM, NK7.NK7_DESABR, NK7.NK7_CALCUL, NK7.NK7_HEDGE
		ORDER BY NK7.NK7_CODCOM

	EndSQL

	//apropriação de dados
	DbselectArea( cAliasNK7 )
	DbGoTop()
	While ( cAliasNK7 )->( !Eof() )

		aadd(__aCompDin, {alltrim((cAliasNK7)->NK7_DESABR),"CMP"+(cAliasNK7)->NK7_CODCOM, PesqPict("NKA","NKA_VLRCOM")})
		aadd(_aCpsBrowCt,{alltrim((cAliasNK7)->NK7_DESABR),"CMP"+(cAliasNK7)->NK7_CODCOM		, "N",TamSx3("NKA_VLRCOM")[1],TamSx3("NKA_VLRCOM")[2], PesqPict('NKA', 'NKA_VLRCOM')} ) //coloca a descrição da moeda e UM
		( cAliasNK7 )->( dbSkip() )
	enddo

return(.t.)


Static Function fCompProd(_aCpsBrowCt, cFiltro)
	Local cAliasN8G := GetNextAlias()
	Local cQry
	Local tamArr
	Local compant
	//trata o filtro
	cFiltro := "%" + cFiltro + "%"

	cQry := " SELECT  NK7.NK7_DESABR, NK7.NK7_CALCUL, NK7.NK7_HEDGE, NK8_CODPRO, NK8_CODCOM  "
	cQry += "   FROM " + RetSqlName('NK8') + " NK8 "
	cQry += "  LEFT JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_COD = NK8.NK8_CODPRO "
	cQry += "    AND SB1.D_E_L_E_T_  = ' ' "
	cQry += "    AND SB1.B1_FILIAL  = '" + fwxFilial("SB1") + "' "
	cQry += "    LEFT JOIN " + RetSqlName('NK7') + " NK7 ON NK7.NK7_CODCOM = NK8.NK8_CODCOM "
	cQry += " AND NK7.D_E_L_E_T_  = ' ' "
	cQry += " AND NK7.NK7_FILIAL = '" + fwxFilial("NK7") + "' "
	cQry += " WHERE NK8.NK8_FILIAL = '" + fwxFilial("NK8") + "' "
	cQry += " AND NK8.D_E_L_E_T_  = ' ' "
	cQry += " AND NK7.NK7_ATIVO   = 'S' "
	cQry += " AND NK7.NK7_FIXAVE   = '0' "
	cQry += " AND (NK7.NK7_CALCUL   = 'P'  OR NK7.NK7_CALCUL = 'C' ) "
	cQry += " GROUP BY NK8.NK8_CODCOM, NK7.NK7_DESABR, NK7.NK7_CALCUL, NK7.NK7_HEDGE, NK8_CODPRO "
	cQry += " ORDER BY NK8.NK8_CODCOM, NK8_CODPRO" 
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasN8G, .F., .T. )

	dbSelectArea(cAliasN8G)
	dbGoTop()
	compant = ""

	While (cAliasN8G)->(!Eof())

		If "CMP"+(cAliasN8G)->NK8_CODCOM != compant
			aAdd(__aCompPrd, { "CMP"+(cAliasN8G)->NK8_CODCOM, {(cAliasN8G)->NK8_CODPRO} })
			compant := "CMP"+(cAliasN8G)->NK8_CODCOM
		Else
			tamArr := Len(__aCompPrd)
			aAdd(__aCompPrd[tamArr][2], (cAliasN8G)->NK8_CODPRO )
		EndIf
		( cAliasN8G )->( dbSkip() )
	enddo

return(.t.)


Static Function fDescStatus(cStatus)
	Local cDesc	:= ""

	Do Case 
		Case cStatus == "1" 
		cDesc := STR0038 //"Fixado"
		Case cStatus == "4" 
		cDesc := STR0039 //"Fixação Parcial"
		Case cStatus == "5" 
		cDesc := STR0040 //"À Fixar"
		Case cStatus == "7"
		cDesc := STR0041 // "Fixação de Preço"
		Case cStatus == "8" 
		cDesc := STR0042 //"Cancelamento Finalizado"
		Case cStatus == "3" 
		cDesc := STR0043 //"Pendente"
		Case cStatus == "2"
		cDesc := STR0044 //"Trabalhando"
		Case cStatus == "6"
		cDesc := STR0045 //"Em Aprovação Financeira"
		Case cStatus == "9"
		cDesc := STR0046 //"Modificação"
		Case cStatus == "A"
		cDesc := STR0047 //"Fixação Componente"

	EndCase

Return cDesc


Static Function fLoadDados(cFiltro)
	Local nQtdFixTot := 0
	Local cAliasNJR  := GetNextAlias()
	Local cAliasN79  := GetNextAlias()
	Local cAliasN7C  := GetNextAlias()
	Local cAliasCOM  := GetNextAlias()
	Local aCompTrab  := {} //componentes trabalhando
	Local nQtdWork   := 0
	Local cFiltroN79 := ""
	Local nQtdNF     := 0
	Local nVlTotNF   := 0
	Local nQtdComp   := 0
	Local nX
	Local lEncProd	 := .F.

	//limpa a tabela temporária
	DbSelectArea((_cTabCtr))
	ZAP

	//Monta o filtro de Fixações
	cFiltroN79 := " AND N79.N79_STATUS <> 4 " //diferente de rejeitado

	//monta po filtro padrão
	cFiltro := "%" + cFiltro + "%"   

	If __cParHist = 1
		cFiltroN79 += " AND (N79.N79_TIPO  = '2' OR N79.N79_TIPO = '3' OR N79.N79_TIPO = '5')  "
	Else
		cFiltroN79 += " AND (N79.N79_STATUS IN ('1', '2') OR " //Independente do tipo
		cFiltroN79 += "(N79.N79_STATUS = '3' AND N79.N79_TIPO = '2')) "
	EndIf

	cFiltroN79 := "%" + cFiltroN79 + "%" 

	//monta a query de busca
	BeginSql Alias cAliasNJR

		SELECT NJR.*, NNY.*
		FROM %Table:NJR% NJR
		INNER JOIN %Table:NNY% NNY ON  NNY.NNY_FILIAL = NJR.NJR_FILIAL
		AND NNY.NNY_CODCTR = NJR.NJR_CODCTR
		AND NNY.%notDel%
		WHERE NJR.%notDel%
		%exp:cFiltro%
		ORDER BY NJR.NJR_CODCTR

	EndSQL

	//apropriação de dados
	DbselectArea( cAliasNJR )
	DbGoTop()
	While ( cAliasNJR )->( !Eof() )

		nQtdFixTot := 0 //reset value
		nQtdComp   := 0
		nPrecoFix  := 0
		nQtdWork   := 0
		aCompTrab  := {} //reset

		/*Verifica as fixações Trabalhando*/
		BeginSql Alias cAliasN79

			SELECT N79.N79_FILIAL, N79.N79_CODNGC, N79.N79_VERSAO,  N79.N79_TIPO, N79.N79_DATA, N7A.N7A_CODCAD, N79.N79_FIXAC, N79_STATUS, N79_TPCANC, N7A_QTDINT
			FROM %Table:N79% N79 
			INNER JOIN %Table:N7A% N7A ON  N7A.N7A_FILIAL = N79.N79_FILIAL
			AND N7A.N7A_CODNGC = N79.N79_CODNGC
			AND N7A.N7A_VERSAO = N79.N79_VERSAO
			AND N7A.N7A_USOFIX <> "LBNO" //somente os que estão de fato no negócio.
			WHERE N79.%notDel%
			AND N79.N79_FILIAL = %exp:(cAliasNJR)->NJR_FILIAL%
			AND N79.N79_CODCTR = %exp:(cAliasNJR)->NJR_CODCTR%
			AND N7A.N7A_CODCAD = %exp:(cAliasNJR)->NNY_ITEM%
			AND N79_FIXAC = "1" 
			%exp:cFiltroN79%
			AND N79_VERSAO = (
			SELECT MAX(N79_VERSAO)
			FROM %table:N79% N792
			WHERE N792.N79_FILIAL = N79.N79_FILIAL
			AND N792.N79_CODNGC = N79.N79_CODNGC
			AND N792.%notDel%
			)
		EndSQL

		//apropriação de dados
		DbselectArea( cAliasN79 )
		DbGoTop()
		while ( cAliasN79 )->( !Eof() ) //não possso ter mais de 1 negócio em aberto

			//Identifica quais sao os produtos do relatorio
			lEncProd := .F.
			If Empty(__aProds)
				aAdd(__aProds,(cAliasNJR)->NJR_CODPRO)
			Else
				For nX := 1 To Len(__aProds)
					If __aProds[nX] = (cAliasNJR)->NJR_CODPRO
						lEncProd :=  .T.
					EndIf
					If .Not. lEncProd
						aAdd(__aProds,(cAliasNJR)->NJR_CODPRO)
					EndIf
				Next nX
			EndIf

			Reclock(_cTabCtr, .T.)

			(_cTabCtr)->FIX_STATUS  := fFixStatus((cAliasN79)->N79_TIPO, (cAliasN79)->N79_STATUS ) //Trabalhando
			(_cTabCtr)->GRUPO		:= DefGrupo((_cTabCtr)->FIX_STATUS)
			(_cTabCtr)->ORDEM		:= DefOrdem((_cTabCtr)->FIX_STATUS)
			(_cTabCtr)->NJR_FILIAL 	:= (cAliasNJR)->NJR_FILIAL
			(_cTabCtr)->NNY_ITEM	:= (cAliasNJR)->NNY_ITEM
			(_cTabCtr)->NNY_MESEMB	:= (cAliasNJR)->NNY_MESEMB
			(_cTabCtr)->NNY_MEMBAR	:= (cAliasNJR)->NNY_MEMBAR
			//(_cTabCtr)->NNY_FILORG	:= (cAliasNJR)->NNY_FILORG
			//(_cTabCtr)->NNY_FILDES	:= OGX700PSM0(cAliasNJR + '->NNY_FILORG')
			(_cTabCtr)->TIPO_CTR 	:=  iif((cAliasNJR)->NJR_TIPO == "1", "C", "V")
			(_cTabCtr)->NJR_CODCTR 	:= (cAliasNJR)->NJR_CODCTR
			(_cTabCtr)->NJR_CTREXT 	:= (cAliasNJR)->NJR_CTREXT
			(_cTabCtr)->NJR_CODNGC 	:= (cAliasN79)->N79_CODNGC
			(_cTabCtr)->NJR_VERSAO 	:= (cAliasN79)->N79_VERSAO
			(_cTabCtr)->NJR_CODENT 	:= (cAliasNJR)->NJR_CODENT
			(_cTabCtr)->NJR_LOJENT 	:= (cAliasNJR)->NJR_LOJENT
			(_cTabCtr)->NJR_NOMENT 	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,'NJ0_NOME')
			(_cTabCtr)->NJR_CODSAF 	:= (cAliasNJR)->NJR_CODSAF
			(_cTabCtr)->NJR_CODPRO 	:= (cAliasNJR)->NJR_CODPRO
			(_cTabCtr)->NJR_DESPRO 	:= Posicione('SB1',1,xFilial('SB1')+(cAliasNJR)->NJR_CODPRO,'B1_DESC')
			//			(_cTabCtr)->NJR_RESFIX 	:= cResFix
			//(_cTabCtr)->NJR_BOLSA 	:= (cAliasNJR)->NJR_BOLSA

			(_cTabCtr)->NJR_BOLSA 	:= Posicione("N8C",1,FwXFilial("N8C") + (cAliasNJR)->NJR_BOLSA, "N8C_DESCR")

			(_cTabCtr)->NNY_IDXNEG 	:= (cAliasNJR)->NNY_IDXNEG
			(_cTabCtr)->NNY_IDXCTF 	:= (cAliasNJR)->NNY_IDXCTF			
			(_cTabCtr)->NJR_DATA 	:= StoD((cAliasN79)->N79_DATA)
			(_cTabCtr)->QTDWORK   	:= iif((_cTabCtr)->FIX_STATUS == "2", (cAliasN79)->N7A_QTDINT, 0)
			(_cTabCtr)->NJR_QTDCTR 	:= (cAliasN79)->N7A_QTDINT
			(_cTabCtr)->NNY_DATINI 	:= StoD((cAliasNJR)->NNY_DATINI)
			(_cTabCtr)->NNY_DATFIM 	:= StoD((cAliasNJR)->NNY_DATFIM)
			(_cTabCtr)->NNY_DTLFIX 	:= StoD((cAliasNJR)->NNY_DTLFIX)
			//(_cTabCtr)->N79_INTFIX 	:= (cAliasN79)->N79_INTFIX
			(_cTabCtr)->N7C_QTCAD	:= (cAliasNJR)->NNY_QTDINT            


			if (cAliasN79)->N79_TPCANC == "2" //Quantidade
				(_cTabCtr)->TIPO_FIX   := STR0054 + STR0048 //"(Preço)"                                
			elseif (cAliasN79)->N79_FIXAC == "1" //Preço
				nQtdWork             := iif((_cTabCtr)->FIX_STATUS == "2", (cAliasN79)->N7A_QTDINT, 0)//é fixação de preço 

				//contando com os itens que estao em aprovacao
				if (cAliasN79)->N79_STATUS <> "3" //finalizado
					nQtdFixTot           += iif(!((_cTabCtr)->FIX_STATUS $ "7|8|9"), (cAliasN79)->N7A_QTDINT, 0)
				endif	

				(_cTabCtr)->TIPO_FIX := iif((cAliasN79)->N79_TIPO  $ "1|2", STR0050 + STR0048 /* "Fixação (Preço)" */, STR0051 + STR0048 /* "Cancelamento (Preço)" */)                
			else
				(_cTabCtr)->TIPO_FIX := iif((cAliasN79)->N79_TIPO  $ "1|2", STR0052 + STR0048 /* "Fix Comp. (Preço)" */, STR0053 + STR0048 /* "Can. Comp. (Preço)" */)                
			endif

			//pega os valores 
			BeginSql Alias cAliasN7C

				SELECT N7C.*      
				FROM %Table:N7C% N7C	
				WHERE N7C.%notDel%
				AND N7C_FILIAL = %exp:(cAliasN79)->N79_FILIAL%
				AND N7C_CODNGC = %exp:(cAliasN79)->N79_CODNGC%
				AND N7C_VERSAO = %exp:(cAliasN79)->N79_VERSAO%
				AND N7C_CODCAD = %exp:(cAliasN79)->N7A_CODCAD% 
				AND (N7C_QTAFIX > 0 OR N7C_QTDFIX > 0) //somente o que teve quantidade			
				ORDER BY N7C_ORDEM

			EndSQL

			DbselectArea( cAliasN7C )
			DbGoTop()
			while ( cAliasN7C )->( !Eof() )
				if ASCAN(_aCpsBrowCt, {|x| AllTrim(x[2]) == "CMP"+(cAliasN7C)->N7C_CODCOM}) > 0 //verifica se existe o componente
					&("(_cTabCtr)->CMP"+(cAliasN7C)->N7C_CODCOM ) := (cAliasN7C)->N7C_VLRUN1 

				elseif (cAliasN7C)->N7C_TPCALC == "R" .and. (cAliasN7C)->N7C_TPPREC == "2" //Preço Negociado
					(_cTabCtr)->NN8_VLRUNI	:= (cAliasN7C)->N7C_VLRUN1
					(_cTabCtr)->N7C_QTAFIX	:= (cAliasN7C)->N7C_QTAFIX			
				endif

				If (cAliasN7C)->N7C_HEDGE = "1"
					(_cTabCtr)->DESBANCO := POSICIONE("SX5",1,FWXFILIAL("SX5")+"K6"+(cAliasN7C)->N7C_CODBCO,"X5_DESCRI")
				EndIf

				(cAliasN7C)->(dbSkip())
			enddo
			(cAliasN7C)->(dbCloseArea())

			MsUnlock()

			(cAliasN79)->(dbSkip())		
		enddo
		(cAliasN79)->(dbCloseArea())


		/*Busca os componentes que tem fixações de preço dinamicamente*/
		dbSelectArea( "NN8" )
		NN8->( dbSetOrder( 2 ) ) //buscando as fixaçoes firmes
		NN8->( dbGoTop() )
		if NN8->( dbSeek( (cAliasNJR)->NJR_FILIAL + (cAliasNJR)->NJR_CODCTR + '1' ) ) /*só as firmes*/
			While !( Eof() ) .And. NN8->( NN8_FILIAL ) + NN8->( NN8_CODCTR ) + '1' ==  (cAliasNJR)->NJR_FILIAL + (cAliasNJR)->NJR_CODCTR + '1'
				if NN8->( NN8_CODCAD ) == (cAliasNJR)->NNY_ITEM
					nQtdFixTot += NN8->NN8_QTDFIX
					nPrecoFix  += NN8->NN8_QTDFIX * NN8->NN8_VLRUNI
				endif
				NN8->( dbSkip() )
			EndDo
		endif
		NN8->( dbCloseArea() )

		/* Negocio */
		cQuery := "select N7C.*, N7M.N7M_VALOR, N7M.N7M_QTDSLD, N79.N79_TPCANC, N79.N79_FIXAC, N79.N79_TIPO FROM  " + RetSqlName("N7C") + " N7C "
		cQuery += " INNER JOIN " + RetSqlName("N7M")+" N7M "
		cQuery += 			" ON (N7C.N7C_FILIAL = N7M.N7M_FILIAL "
		cQuery += 		   " AND N7C.N7C_CODNGC = N7M.N7M_CODNGC "
		cQuery += 		   " AND N7C.N7C_VERSAO = N7M.N7M_VERSAO "
		cQuery += 		   " AND N7C.N7C_CODCAD = N7M.N7M_CODCAD "
		cQuery += 		   " AND N7C.N7C_CODCOM = N7M.N7M_CODCOM "
		cQuery += 		   " AND N7C.D_E_L_E_T_ = ' ') "
		cQuery += " INNER JOIN "+RetSqlName("N79")+" N79 "
		cQuery += 			" ON (N7C.N7C_FILIAL = N79.N79_FILIAL "
		cQuery += 		   " AND N7C.N7C_CODNGC = N79.N79_CODNGC "
		cQuery += 		   " AND N7C.N7C_VERSAO = N79.N79_VERSAO) "
		cQuery += 		" WHERE N7M.D_E_L_E_T_ = ' ' AND N7M.N7M_QTDSLD > 0 "
		cQuery += 		  " and N79.N79_FILIAL = '"+(cAliasNJR)->NJR_FILIAL + "'"
		cQuery += 		  " and N79.N79_CODCTR = '"+(cAliasNJR)->NJR_CODCTR + "'"
		cQuery += 		  " and N7M.N7M_CODCAD = '"+(cAliasNJR)->NNY_ITEM   + "'"

		cAliasCOM := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasCOM),.F.,.T.)

		dbSelectArea((cAliasCOM))
		(cAliasCOM)->( dbGoTop() )
		While (cAliasCOM)->( .NOT. Eof() )

			Reclock(_cTabCtr, .T.)
			(_cTabCtr)->NJR_FILIAL 	:= (cAliasNJR)->NJR_FILIAL
			(_cTabCtr)->NNY_ITEM	:= (cAliasNJR)->NNY_ITEM
			(_cTabCtr)->NNY_MESEMB	:= (cAliasNJR)->NNY_MESEMB
			(_cTabCtr)->NNY_MEMBAR	:= (cAliasNJR)->NNY_MEMBAR
			(_cTabCtr)->TIPO_CTR 	:=  iif((cAliasNJR)->NJR_TIPO == "1", "C", "V")
			(_cTabCtr)->NJR_CODCTR 	:= (cAliasNJR)->NJR_CODCTR
			(_cTabCtr)->NJR_CTREXT 	:= (cAliasNJR)->NJR_CTREXT
			(_cTabCtr)->NJR_CODNGC 	:= (cAliasNJR)->NJR_CODNGC
			(_cTabCtr)->NJR_VERSAO 	:= (cAliasNJR)->NJR_VERSAO
			(_cTabCtr)->NJR_CODENT 	:= (cAliasNJR)->NJR_CODENT
			(_cTabCtr)->NJR_LOJENT 	:= (cAliasNJR)->NJR_LOJENT
			(_cTabCtr)->NJR_NOMENT 	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,'NJ0_NOME')
			(_cTabCtr)->NJR_CODSAF 	:= (cAliasNJR)->NJR_CODSAF
			(_cTabCtr)->NJR_CODPRO 	:= (cAliasNJR)->NJR_CODPRO
			(_cTabCtr)->NJR_DESPRO 	:= Posicione('SB1',1,xFilial('SB1')+(cAliasNJR)->NJR_CODPRO,'B1_DESC')
			(_cTabCtr)->NJR_BOLSA 	:= Posicione("N8C",1,FwXFilial("N8C") + (cAliasNJR)->NJR_BOLSA, "N8C_DESCR")
			(_cTabCtr)->NNY_IDXNEG 	:= (cAliasNJR)->NNY_IDXNEG
			(_cTabCtr)->NNY_IDXCTF 	:= (cAliasNJR)->NNY_IDXCTF			
			(_cTabCtr)->NJR_QTDCTR 	:= (cAliasNJR)->NNY_QTDINT
			(_cTabCtr)->NNY_DATINI 	:= StoD((cAliasNJR)->NNY_DATINI)
			(_cTabCtr)->NNY_DATFIM 	:= StoD((cAliasNJR)->NNY_DATFIM)
			(_cTabCtr)->NNY_DTLFIX 	:= StoD((cAliasNJR)->NNY_DTLFIX)
			(_cTabCtr)->TIPO_FIX    := STR0049 /* "(Componente)" */            
			(_cTabCtr)->FIX_STATUS	:= "A"
			(_cTabCtr)->N7C_QTCAD	:= (cAliasNJR)->NNY_QTDINT
			//(_cTabCtr)->N7C_QTAFIX  := (cAliasNJR)->NNY_QTDINT - nQtdFixTot			            

			if ASCAN(_aCpsBrowCt, {|x| AllTrim(x[2]) == "CMP"+(cAliasCOM)->N7C_CODCOM}) > 0 //verifica se existe o componente
				&("(_cTabCtr)->CMP"+(cAliasCOM)->N7C_CODCOM ) := (cAliasCOM)->N7C_VLRUN1
				(_cTabCtr)->NN8_VLRUNI += (cAliasCOM)->N7C_VLRUN1
				(_cTabCtr)->N7C_QTAFIX += (cAliasCOM)->N7M_QTDSLD
				nQtdComp += (cAliasCOM)->N7C_QTAFIX	
			Endif

			if (cAliasCOM)->N79_TPCANC == "2" //Quantidade
				(_cTabCtr)->TIPO_FIX := STR0054 + STR0049 /* "(Componente)" */
			elseif (cAliasCOM)->N79_FIXAC == "1" //Preço
				(_cTabCtr)->TIPO_FIX := iif((cAliasCOM)->N79_TIPO $ "1|2", STR0050 + STR0049 /* "Fixacao (Componente)" */, STR0051 + STR0049 /* "Fixacao (Componente)" */)                
			else
				(_cTabCtr)->TIPO_FIX := iif((cAliasCOM)->N79_TIPO $ "1|2", STR0052 + STR0049 /* "Fix Comp. (Componente)" */,STR0053 + STR0049 /* "Can. Comp. (Componente)" */ )
			endif

			//Fixação de Componente			
			If (cAliasCOM)->N7C_HEDGE = "1"
				(_cTabCtr)->DESBANCO := POSICIONE("SX5",1,FWXFILIAL("SX5")+"K6"+(cAliasCOM)->N7C_CODBCO,"X5_DESCRI")
			EndIf

			(_cTabCtr)->(MsUnlock())

			(cAliasCOM)->( dbSkip() )
		EndDo 
		(cAliasCOM)->( dbCloseArea() )


		If (cAliasNJR)->NNY_QTDINT - nQtdFixTot > 0 .and. (cAliasNJR)->NNY_QTDINT - nQtdFixTot > nQtdComp

			Reclock(_cTabCtr, .T.)

			(_cTabCtr)->NJR_FILIAL 	:= (cAliasNJR)->NJR_FILIAL
			(_cTabCtr)->NNY_ITEM	:= (cAliasNJR)->NNY_ITEM
			(_cTabCtr)->NNY_MESEMB	:= (cAliasNJR)->NNY_MESEMB
			(_cTabCtr)->NNY_MEMBAR	:= (cAliasNJR)->NNY_MEMBAR				
			(_cTabCtr)->TIPO_CTR 	:=  iif((cAliasNJR)->NJR_TIPO == "1", "C", "V")
			(_cTabCtr)->NJR_CODCTR 	:= (cAliasNJR)->NJR_CODCTR
			(_cTabCtr)->NJR_CTREXT 	:= (cAliasNJR)->NJR_CTREXT
			(_cTabCtr)->NJR_CODNGC 	:= (cAliasNJR)->NJR_CODNGC
			(_cTabCtr)->NJR_VERSAO 	:= (cAliasNJR)->NJR_VERSAO
			(_cTabCtr)->NJR_CODENT 	:= (cAliasNJR)->NJR_CODENT
			(_cTabCtr)->NJR_LOJENT 	:= (cAliasNJR)->NJR_LOJENT
			(_cTabCtr)->NJR_NOMENT 	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,'NJ0_NOME')
			(_cTabCtr)->NJR_CODSAF 	:= (cAliasNJR)->NJR_CODSAF
			(_cTabCtr)->NJR_CODPRO 	:= (cAliasNJR)->NJR_CODPRO
			(_cTabCtr)->NJR_DESPRO 	:= Posicione('SB1',1,xFilial('SB1')+(cAliasNJR)->NJR_CODPRO,'B1_DESC')
			(_cTabCtr)->NJR_BOLSA 	:= Posicione("N8C",1,FwXFilial("N8C") + (cAliasNJR)->NJR_BOLSA, "N8C_DESCR")
			(_cTabCtr)->NNY_IDXNEG 	:= (cAliasNJR)->NNY_IDXNEG
			(_cTabCtr)->NNY_IDXCTF 	:= (cAliasNJR)->NNY_IDXCTF			
			(_cTabCtr)->QTDAFIXAR	:= (cAliasNJR)->NNY_QTDINT - nQtdFixTot				
			(_cTabCtr)->NJR_QTDCTR 	:= (cAliasNJR)->NNY_QTDINT
			(_cTabCtr)->QTDWORK   	:= nQtdWork
			(_cTabCtr)->NNY_DATINI 	:= StoD((cAliasNJR)->NNY_DATINI)
			(_cTabCtr)->NNY_DATFIM 	:= StoD((cAliasNJR)->NNY_DATFIM)
			(_cTabCtr)->NNY_DTLFIX 	:= StoD((cAliasNJR)->NNY_DTLFIX)
			(_cTabCtr)->NN8_VLRUNI  := nPrecoFix / nQtdFixTot //monta a média ponderada
			(_cTabCtr)->TIPO_FIX    := STR0007 // Contrato
			(_cTabCtr)->N7C_QTAFIX := (cAliasNJR)->NNY_QTDINT - nQtdFixTot
			(_cTabCtr)->N7C_QTCAD := (cAliasNJR)->NNY_QTDINT - nQtdFixTot

			//quando não é por fixação e sim pelo indice da bolsa
			If Posicione("N8C",1,FwXFilial("N8C") + (cAliasNJR)->NJR_BOLSA, "N8C_PRCBOL") == "2" //bolsa com indice(ESALQ)
				nQtdNF   := 0
				nVlTotNF := 0

				dbSelectArea( "N9A" )
				N9A->( dbSetOrder( 1 ) ) 
				if N9A->( dbSeek( (cAliasNJR)->NJR_FILIAL + (cAliasNJR)->NJR_CODCTR + (cAliasNJR)->NNY_ITEM) ) 
					While !( Eof() ) .And. N9A->N9A_FILIAL == (cAliasNJR)->NJR_FILIAL .And. N9A->N9A_CODCTR == (cAliasNJR)->NJR_CODCTR .And. N9A->N9A_ITEM == (cAliasNJR)->NNY_ITEM
						nQtdNF   += N9A->N9A_QTDNF
						nVlTotNF += N9A->N9A_VTOTNF 
						N9A->( dbSkip() )
					EndDo
				endif
				N9A->( dbCloseArea( ) )

				(_cTabCtr)->QTDAFIXAR  := (cAliasNJR)->NNY_QTDINT - nQtdNF
				(_cTabCtr)->NN8_VLRUNI := nVlTotNF / nQtdNF //monta a média 
			EndIf	        

			if (_cTabCtr)->QTDAFIXAR == 0
				(_cTabCtr)->FIX_STATUS := "1" //fixado
			elseif (_cTabCtr)->QTDAFIXAR <> (_cTabCtr)->NJR_QTDCTR
				(_cTabCtr)->FIX_STATUS := "4" //Fixado parcial
				(_cTabCtr)->NN8_VLRUNI := 0
				(_cTabCtr)->N7C_QTAFIX := (_cTabCtr)->QTDAFIXAR - nQtdComp
			else
				(_cTabCtr)->FIX_STATUS := "5" //à fixar
				(_cTabCtr)->NN8_VLRUNI := 0
				(_cTabCtr)->N7C_QTAFIX := (_cTabCtr)->QTDAFIXAR - nQtdComp
			endif
			(_cTabCtr)->ORDEM		:= DefOrdem((_cTabCtr)->FIX_STATUS)

			(_cTabCtr)->(MsUnlock())
		EndIf

		(cAliasNJR)->(dbSkip())

	enddo

	(cAliasNJR)->(dbCloseArea())

Return(.t.)


/*/{Protheus.doc} PrintReport
//Gera relatorio
@author carlos.augusto
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport( oReport ) 
	Local oS1		:= oReport:Section( 1 )
	Local cStatus	:= ""
	Local cCodPro	:= ""
	Local nX
	Local nY
	Local nZ
	Local lOkComp	:= .F.
	Local cNomeEmp  := ""
	Local cNmFil    := ""
	Local count		:= 0
	Local oTFtitulo := TFont():New("Courier New",,-10,,.T.)

	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

	If oReport:Cancel()
		Return( Nil )
		_cTabCtr:Delete()
	EndIf

	DbSelectArea( _cTabCtr )
	(_cTabCtr)->( dbSetOrder(3) )	
	(_cTabCtr)->( dbGoTop() )
	While .Not. (_cTabCtr)->( Eof( ) )

		count++

		If cCodPro  != (_cTabCtr)->NJR_CODPRO .Or. cStatus != (_cTabCtr)->FIX_STATUS //NJR_CODPRO

			If cCodPro  != (_cTabCtr)->NJR_CODPRO
				oReport:SkipLine(1)
				oReport:PrintText("")
				oReport:Say(oReport:Row(),10, AllTrim((_cTabCtr)->NJR_CODPRO) + " - " + AllTrim((_cTabCtr)->NJR_DESPRO),oTFtitulo)
				oReport:PrintText("")
			EndIf
			oReport:SkipLine(1)			

			oS1:Init()
			oReport:PrintText((_cTabCtr)->FIX_STATUS  + " - " +;
			fDescStatus((_cTabCtr)->FIX_STATUS) + ;
			IIF(!(_cTabCtr)->FIX_STATUS $ "7|A|"," - " +AllTrim((_cTabCtr)->TIPO_FIX ),"")   )

			//--------------------------------------------------------------------	
			oS1:Cell("NN8_VLRUNI"):Enable()
			For nY := 1 to Len(__aCompDin)
				lOkComp := .F.
				For nX := 1 to Len(__aCompPrd)
					If __aCompDin[nY][2] = __aCompPrd[nX][1]
						For nZ := 1 to Len(__aCompPrd[nX][2])
							If AllTrim((_cTabCtr)->NJR_CODPRO) = AllTrim(__aCompPrd[nX][2][nZ])
								lOkComp := .T.
								exit
							EndIf
						Next nZ
					EndIf
				Next nX
				If lOkComp
					oS1:Cell(__aCompDin[nY][2]):Enable()
				Else
					oS1:Cell(__aCompDin[nY][2]):Disable()
				EndIf
			Next nY

			//--------------------------------------------------------------------
			cStatus := (_cTabCtr)->FIX_STATUS
			cCodPro := (_cTabCtr)->NJR_CODPRO
		EndIf

		oS1:PrintLine( )	

		(_cTabCtr)->( dbSkip() )
		If cCodPro != (_cTabCtr)->NJR_CODPRO  .Or. cStatus != (_cTabCtr)->FIX_STATUS
			oS1:Finish()	
			If cCodPro != (_cTabCtr)->NJR_CODPRO
				oReport:EndPage( .F. ) 
			EndIf

		EndIf
	EndDo

	oS1:Finish()

Return .t.

/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author rafael.voltz
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar  := CHR(160) // caracter dummy para alinhamento do cabeçalho
	Local aAreaSM0 := SM0->(GetArea())

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp   := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase) // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate // Direita

	// Linha 5
	AADD(aCabec, STR0018 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

	RestArea(aAreaSM0)

Return aCabec

Static Function DefGrupo(cStatus)
	Local cGrupo := ""

	Do Case 
		Case cStatus == "1"
		cGrupo := "1" 
		Case cStatus == "4"
		cGrupo := "2" 
		Case cStatus == "5"
		cGrupo := "2" 
		Case cStatus == "7"
		cGrupo := "1" 
		Case cStatus == "8"
		cGrupo := "4" 
		Case cStatus == "3" 
		cGrupo := "5" 
		Case cStatus == "2"
		cGrupo := "3" 
		Case cStatus == "6"
		cGrupo := "6"
		Case cStatus == "9"
		cGrupo := "7"
		Case cStatus == "A"
		cGrupo := "2"
	EndCase

Return cGrupo

Static Function DefOrdem(cStatus)
	Local cOrdem := ""

	Do Case 
		Case cStatus == "1"
		cOrdem := "5" 
		Case cStatus == "4"
		cOrdem := "2" 
		Case cStatus == "5"
		cOrdem := "2" 
		Case cStatus == "7"
		cOrdem := "5" 
		Case cStatus == "8"
		cOrdem := "4" 
		Case cStatus == "3" 
		cOrdem := "1" 
		Case cStatus == "2"
		cOrdem := "3" 
		Case cStatus == "6"
		cOrdem := "6"
		Case cStatus == "9"
		cOrdem := "7"
		Case cStatus == "A"
		cOrdem := "2"
	EndCase

Return cOrdem



Function PreparaTT(_cTabCtr)
	Local nY

	DbSelectArea( _cTabCtr )
	(_cTabCtr)->( dbSetOrder(2) )	
	(_cTabCtr)->( dbGoTop() )
	While .Not. (_cTabCtr)->( Eof( ) )

		Reclock(_cTabCtr, .F.)
		For nY := 1 to Len(_aCpsBrowCt)

			If (_aCpsBrowCt[nY][2] $ "FIX_STATUS") .And. (&("(_cTabCtr)->" + _aCpsBrowCt[nY][2]) $ "4|A")
				&("(_cTabCtr)->" + _aCpsBrowCt[nY][2])	:= "5"
			ElseIf !(_aCpsBrowCt[nY][2] $ "GRUPO")
				&("(_cTabCtr)->" + _aCpsBrowCt[nY][2])	:= &("(_cTabCtr)->" + _aCpsBrowCt[nY][2])
			EndIf

		Next nY
		(_cTabCtr)->GRUPO := (_cTabCtr)->FIX_STATUS
		(_cTabCtr)->ORDEM := DefOrdem((_cTabCtr)->FIX_STATUS)
		(_cTabCtr)->(MsUnlock())

		(_cTabCtr)->( dbSkip() )
	EndDo

Return .T.