#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OGC004.CH"
#Include "Protheus.ch"

Static __lCtrRisco 	 := SuperGetMv('MV_AGRO041', , .F.) 

/*{Protheus.doc} OGC004
Painel de Fixações - Precificação
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Function OGC004()
	Local aFilBrowCtr := {}
	Local nCont       := 0

	Local aWidthColum := {}

	Private _cFiltro := nil
	Private _cTabCtr := nil
	Private _oBrowse := nil
	Private _aCpsBrowCt := nil

	//-- Proteção de Código
	If .Not. TableInDic('N75') .OR. .Not. TableInDic('N79')  .OR. .Not. TableInDic('N7C')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	// Abre a tela de parâmetros de perguntas
	If !Pergunte( STR0001, .T. )
		Return
	EndIf

	_cFiltro := fMntFiltro() //apropria filtro

	//campos blocos
	_aCpsBrowCt := {{STR0029 , "FIX_STATUS"	, "C", 1, 0	, "@!"	},;	//"Reserva"					
					{STR0030 , "TIPO_CTR"	, "C", 1	, 0	, "@!"	},;	//"Tipo CTR"
					{STR0032 , "NJR_CODCTR"	, TamSX3( "NJR_CODCTR" )[3]	, TamSX3( "NJR_CODCTR" )[1]	, TamSX3( "NJR_CODCTR" )[2]	, PesqPict("NJR","NJR_CODCTR") 	},;
					{STR0031 , "NJR_FILIAL"	, TamSX3( "NJR_FILIAL" )[3]	, TamSX3( "NJR_FILIAL" )[1]	, TamSX3( "NJR_FILIAL" )[2]	, PesqPict("NJR","NJR_FILIAL") 	},; //"Qtd. Take-Up"
					{AgrTitulo("NJR_CTREXT") , "NJR_CTREXT"	, TamSX3( "NJR_CTREXT" )[3]	, TamSX3( "NJR_CTREXT" )[1]	, TamSX3( "NJR_CTREXT" )[2]	, PesqPict("NJR","NJR_CTREXT") 	},;
					{STR0033 , "NNY_ITEM"	, TamSX3( "NNY_ITEM" )[3]	, TamSX3( "NNY_ITEM" )[1]	, TamSX3( "NNY_ITEM" )[2]	, PesqPict("NNY","NNY_ITEM") 	},;
					{STR0059 , "NNY_MESEMB"	, TamSX3( "NNY_MESEMB" )[3]	, TamSX3( "NNY_MESEMB" )[1]	, TamSX3( "NNY_MESEMB" )[2]	, PesqPict("NNY","NNY_MESEMB") 	},; // Mês/Embarque
					{AgrTitulo("NNY_FILORG"), "NNY_FILORG"	, TamSX3( "NNY_FILORG" )[3]	, TamSX3( "NNY_FILORG" )[1]	, TamSX3( "NNY_FILORG" )[2]	, PesqPict("NNY","NNY_FILORG") 	},; // Filial de Origem
					{AgrTitulo("NNY_FILDES"), "NNY_FILDES"	, TamSX3( "NNY_FILDES" )[3]	, TamSX3( "NNY_FILDES" )[1]	, TamSX3( "NNY_FILDES" )[2]	, PesqPict("NNY","NNY_FILDES") 	},; // Descrição Filial de Origem
					{STR0034 , "NJR_CODNGC"	, TamSX3( "NJR_CODNGC" )[3]	, TamSX3( "NJR_CODNGC" )[1]	, TamSX3( "NJR_CODNGC" )[2]	, PesqPict("NJR","NJR_CODNGC") 	},;
					{STR0035 , "NJR_VERSAO"	, TamSX3( "NJR_VERSAO" )[3]	, TamSX3( "NJR_VERSAO" )[1]	, TamSX3( "NJR_VERSAO" )[2]	, PesqPict("NJR","NJR_VERSAO") 	},;
					{STR0036 , "NJR_CODENT"	, TamSX3( "NJR_CODENT" )[3]	, TamSX3( "NJR_CODENT" )[1]	, TamSX3( "NJR_CODENT" )[2]	, PesqPict("NJR","NJR_CODENT") 	},;	//"Reserva"
			        {STR0037 , "NJR_LOJENT"	, TamSX3( "NJR_LOJENT" )[3]	, TamSX3( "NJR_LOJENT" )[1]	, TamSX3( "NJR_LOJENT" )[2]	, PesqPict("NJR","NJR_LOJENT") 	},;
			        {STR0038 , "NJR_NOMENT"	, TamSX3( "NJR_NOMENT" )[3]	, TamSX3( "NJR_NOMENT" )[1]	, TamSX3( "NJR_NOMENT" )[2]	, PesqPict("NJR","NJR_NOMENT") 	},;	//"Reserva"
					{STR0039 , "NJR_CODSAF"	, TamSX3( "NJR_CODSAF" )[3]	, TamSX3( "NJR_CODSAF" )[1]	, TamSX3( "NJR_CODSAF" )[2]	, PesqPict("NJR","NJR_CODSAF") 	},; //"Qtd. Take-Up"
					{STR0040 , "NJR_CODPRO"	, TamSX3( "NJR_CODPRO" )[3]	, TamSX3( "NJR_CODPRO" )[1]	, TamSX3( "NJR_CODPRO" )[2]	, PesqPict("NJR","NJR_CODPRO") 	},;	//"Reserva"
					{STR0041 , "NJR_DESPRO"	, TamSX3( "NJR_DESPRO" )[3]	, TamSX3( "NJR_DESPRO" )[1]	, TamSX3( "NJR_DESPRO" )[2]	, PesqPict("NJR","NJR_DESPRO") 	},;	//"Reserva"
					{STR0072 , "NJR_RESFIX" , TamSX3( "NJR_RESFIX" )[3]	, 15                    	, TamSX3( "NJR_RESFIX" )[2]	, PesqPict("NJR","NJR_RESFIX") 	},;  //Responsável pela Fixação
					{STR0069 , "NJR_BOLSA"	, TamSX3( "NJR_BOLSA" )[3]	, TamSX3( "NJR_BOLSA" )[1]	, TamSX3( "NJR_BOLSA" )[2]	, PesqPict("NJR","NJR_BOLSA") 	},; //"Bolsa Ref."
					{STR0070 , "NNY_IDXNEG" , TamSX3( "NNY_IDXNEG" )[3]	, TamSX3( "NNY_IDXNEG" )[1]	, TamSX3( "NNY_IDXNEG" )[2]	, PesqPict("NNY","NNY_IDXNEG") 	},;  //Indice negocio
					{STR0071 , "NNY_IDXCTF" , TamSX3( "NNY_IDXCTF" )[3]	, TamSX3( "NNY_IDXCTF" )[1]	, TamSX3( "NNY_IDXCTF" )[2]	, PesqPict("NNY","NNY_IDXCTF") 	},;  //Indice Ct. Futuro
					{STR0042 , "NJR_QTDCTR"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},; //"Qtd. Take-Up"
					{STR0043 , "QTDAFIXAR"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},;  //agio folha
					{STR0048 , "QTDWORK"	, TamSX3( "NJR_QTDCTR" )[3]	, TamSX3( "NJR_QTDCTR" )[1]	, TamSX3( "NJR_QTDCTR" )[2]	, PesqPict("NJR","NJR_QTDCTR") 	},;  //agio folha
					{STR0062 , "NN8_VLRUNI"	, TamSX3( "NN8_VLRUNI" )[3]	, TamSX3( "NN8_VLRUNI" )[1]	, TamSX3( "NN8_VLRUNI" )[2]	, PesqPict("NN8","NN8_VLRUNI") 	},;  //agio folha
					{STR0049 , "TIPO_FIX"	, "C", 12	, 0	, "@!"	},;	//"Tipo Fixação"
					{STR0044 , "NJR_DATA"	, TamSX3( "NJR_DATA" )[3]	, TamSX3( "NJR_DATA" )[1]	, TamSX3( "NJR_DATA" )[2]	, PesqPict("NJR","NJR_DATA") 	},; //agio cor
					{STR0045 , "NNY_DTLFIX"	, TamSX3( "NNY_DTLFIX" )[3]	, TamSX3( "NNY_DTLFIX" )[1]	, TamSX3( "NNY_DTLFIX" )[2]	, PesqPict("NNY","NNY_DTLFIX") 	},; //agio cor
					{STR0046 , "NNY_DATINI"	, TamSX3( "NNY_DATINI" )[3]	, TamSX3( "NNY_DATINI" )[1]	, TamSX3( "NNY_DATINI" )[2]	, PesqPict("NNY","NNY_DATINI") 	},; //agio hvi
					{STR0047 , "NNY_DATFIM" , TamSX3( "NNY_DATFIM" )[3]	, TamSX3( "NNY_DATFIM" )[1]	, TamSX3( "NNY_DATFIM" )[2]	, PesqPict("NNY","NNY_DATFIM") 	}}

	//coloca a quantidade de tamanho padrao
	aWidthColum := {2,2,5,10,3,10,10,20,10,3,10,3,20,5,10,15,10,6,6,6,10,10,10,10,10,8,8,8,8} //fixando o tamanho das colunas

	//monta a lista de componentes
	fCompDisp(@aWidthColum, _cFiltro)

	Processa({|| _cTabCtr := MontaTabel(_aCpsBrowCt, {{"", "FIX_STATUS+NJR_CODCTR+NJR_FILIAL+NNY_ITEM"}})},STR0011)

	Processa({|| fLoadDados(_cFiltro)},STR0010)

	//atalho de pesquisa
	SetKey( VK_F12, { || OGC04F12(.t.) } )

	//Criando o Browser de Visualização
	_oBrowse := FWMBrowse():New()
    _oBrowse:SetAlias(_cTabCtr)
    _oBrowse:SetDescription( STR0006 )
    _oBrowse:DisableDetails()
    _oBrowse:SetMenuDef( "OGC004" ) //verifica para coloca as opções de menu aqui - fixar, contrato, etc.
    _oBrowse:SetProfileID("OGC004BRW1")

    //legenda
    _oBrowse:AddLegend( "FIX_STATUS == '1'", "GREEN"      , STR0014) //"Fixado"
    _oBrowse:AddLegend( "FIX_STATUS == '4'", "YELLOW"     , STR0013) //"Fixação Parcial"
    _oBrowse:AddLegend( "FIX_STATUS == '5'", "RED"        , STR0012, ) //"À Fixar"
    _oBrowse:AddLegend( "FIX_STATUS == '7'", "BR_PRETO"   , STR0082 ) //"Fixação Finalizada"
	_oBrowse:AddLegend( "FIX_STATUS == '8'", "BR_PINK"    , STR0083 ) //"Cancelamento Finalizado"
	_oBrowse:AddLegend( "FIX_STATUS == '3'", "BR_BRANCO"  , STR0063) //"Pendente
    _oBrowse:AddLegend( "FIX_STATUS == '2'", "ORANGE"     , STR0015) //"Trabalhando"
	_oBrowse:AddLegend( "FIX_STATUS == '6'", "BR_VIOLETA" , STR0081 ) //"Em Aprovação Financeira"
	_oBrowse:AddLegend( "FIX_STATUS == '9'", "BLUE"       , STR0084 ) //"Modificação"
	
    For nCont := 1  to Len(_aCpsBrowCt) //desconsiderar STATUS e Tipo
    
        if substr(_aCpsBrowCt[nCont][2], 1, 3) <> "CEX" //campos de excessao
	        If .Not. _aCpsBrowCt[nCont][2] $ "FIX_STATUS|"
	        	_oBrowse:AddColumn( {_aCpsBrowCt[nCont][1]  , &("{||"+_aCpsBrowCt[nCont][2]+"}") ,_aCpsBrowCt[nCont][3],_aCpsBrowCt[nCont][6],iif(_aCpsBrowCt[nCont][3] == "N",2,1),_aCpsBrowCt[nCont][4],_aCpsBrowCt[nCont][5],.f.} )	        
	        EndIf
	        if _aCpsBrowCt[nCont][2] != "NNY_MESEMB"
	        	aADD(aFilBrowCtr,  {_aCpsBrowCt[nCont][2], _aCpsBrowCt[nCont][1], _aCpsBrowCt[nCont][3], _aCpsBrowCt[nCont][4], _aCpsBrowCt[nCont][5], _aCpsBrowCt[nCont][6] } )
	        endif
	    endif
    Next nCont
    _oBrowse:SetWidthColumns(aWidthColum)
    _oBrowse:SetFieldFilter(aFilBrowCtr)
    _oBrowse:Activate()

Return .t.

/*{Protheus.doc} MenuDef
Define as operações que serão realizadas pela aplicação
@author 	ana.olegini
@since 		13/03/2017
@version 	1.0
@return 	aRotina , array contendo as operações
*/
Static Function MenuDef()
	Local aRotina 	:= {}
    Local aRotina1 	:= {}
	
    aAdd( aRotina, { STR0018 , "OGC004FIXA()" , 0, 4, 0, .f. } ) //"Fixar Contrato"
	aAdd( aRotina, { STR0055 , "OGC004VIEW()" , 0,2, 0, .f. } ) //Detalhar Fixações
	aAdd( aRotina, { STR0025 , "OGC004X700(1)" , 0, 4, 0, .f. } ) //Aprovar Negócio
	aAdd( aRotina, { STR0060 , "OGC004X700(2)" , 0, 4, 0, .f. } ) //Rejeitar Negócio
	aAdd( aRotina, { STR0076 , "OGC004X700(3)" , 0, 4, 0, .f. } ) //Conhecimento
	aAdd( aRotina, { STR0077 , "OGC004X700(4)" , 0, 4, 0, .f. } ) //Histórico do Negócio
	aAdd( aRotina, { STR0080 , "OGC004CFIX((_cTabCtr)->NJR_FILIAL , (_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NNY_ITEM, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO, (_cTabCtr)->FIX_STATUS, 'C') " , 0, 4, 0, .f. } ) // # "Cancelar Fixação"
	aAdd( aRotina, { STR0094 , "OGC004CANQ((_cTabCtr)->NJR_FILIAL , (_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NNY_ITEM, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO, (_cTabCtr)->FIX_STATUS, 'C') " , 0, 4, 0, .f. } ) // # "Cancelar Quantidade"
	aAdd( aRotina, { STR0095 , "OGA335((_cTabCtr)->NJR_CODCTR,(_cTabCtr)->NJR_FILIAL ) " , 0, 4, 0, .f. } ) // # "Aditar Contrato"
	aAdd( aRotina, { STR0085 , "OGC004CFIX((_cTabCtr)->NJR_FILIAL , (_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NNY_ITEM, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO,  (_cTabCtr)->FIX_STATUS, 'M') " , 0, 4, 0, .f. } ) // # "Modificar Fixação"
	aAdd( aRotina, { STR0056 , "OGC004AGLU()" , 0, 4, 0, .f. } ) //"Aglutinar Fixações"
	aAdd( aRotina, { STR0079 , "OGC004CBOL()" , 0, 2, 0, .f. } ) //"Gerar Boleta"
	
    If __lCtrRisco
		aAdd( aRotina1, { STR0097, "OGA700CTRF((_cTabCtr)->NJR_FILIAL, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO, 'S')", 0, 4, 0, Nil } )      //Selecionar
	    aAdd( aRotina1, { STR0098 ,"OGA700CTRF((_cTabCtr)->NJR_FILIAL, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO, 'R')", 0, 4, 0, Nil } )    //Remover

        aAdd( aRotina, { STR0092 , aRotina1 , 0, 4, 0, .f. } ) //"Selecionar Contratos Futuros"	
	EndIf
	
Return( aRotina )

/*{Protheus.doc} fCompDisp
Lista os componentes Passíveis de Exibição
@author jean.schulze
@since 09/10/2017
@version undefined
@param aWidthColum, array, descricao
@param cFiltro, characters, descricao
@type function
*/
Static Function fCompDisp(aWidthColum, cFiltro)
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
		aadd(_aCpsBrowCt, {STR0020 + alltrim((cAliasNK7)->NK7_DESABR)  	, "CMP"+(cAliasNK7)->NK7_CODCOM		, "N",TamSx3("NKA_VLRCOM")[1],TamSx3("NKA_VLRCOM")[2], PesqPict('NKA', 'NKA_VLRCOM')} ) //coloca a descrição da moeda e UM
		aAdd(_aCpsBrowCt, {STR0019 + alltrim((cAliasNK7)->NK7_DESABR)  	, "CMP"+(cAliasNK7)->NK7_CODCOM+"1" , "N",TamSx3("NN8_QTDFIX")[1],TamSx3("NN8_QTDFIX")[2], PesqPict('NN8', 'NN8_QTDFIX')} )	//" Qtd Fix"
		aAdd(_aCpsBrowCt, {STR0021 + alltrim((cAliasNK7)->NK7_DESABR) 	, "CMP"+(cAliasNK7)->NK7_CODCOM+"2" , "N",TamSx3("NN8_QTDFIX")[1],TamSx3("NN8_QTDFIX")[2], PesqPict('NN8', 'NN8_QTDFIX')} )	//" Qtd Fix"
		
		//Tamanho de campo
		aadd(aWidthColum,6)
		aAdd(aWidthColum,6)
		aAdd(aWidthColum,6)
	
		( cAliasNK7 )->( dbSkip() )
	enddo

return(.t.)

/*{Protheus.doc} fLoadDados
Carrega os dados da Tabela Temporária
@author jean.schulze
@since 09/10/2017
@version undefined
@param cFiltro, characters, descricao
@type function
*/
Static Function fLoadDados(cFiltro)
	Local nQtdFixTot := 0
	Local cAliasNJR  := GetNextAlias()
	Local cAliasN7M  := GetNextAlias()
	Local cAliasN79  := GetNextAlias()
	Local cAliasN7C  := GetNextAlias()		
	Local aCompTrab  := {} //componentes trabalhando	
	Local nQtdWork   := 0
	Local cFiltroN79 := ""
	Local nQtdNF     := 0
	Local nVlTotNF   := 0
	
	//limpa a tabela temporária
	DbSelectArea((_cTabCtr))
	ZAP

	//Monta o filtro de Fixações
	if MV_PAR19 == 1  
	    cFiltroN79 := "% AND N79.N79_STATUS <> '4' %" //diferente de rejeitado
	else
	    cFiltroN79 := "% AND N79.N79_STATUS <= '2' %" //Em aprovação e Trabalhando - FLUIG
	endif
	     
	//monta po filtro padrão
	cFiltro := "%" + cFiltro + "%"     
	
	//monta a query de busca
	BeginSql Alias cAliasNJR

		SELECT NJR.*, NNY.*
		  FROM %Table:NJR% NJR
		  INNER JOIN %Table:NNY% NNY ON  NNY.NNY_FILIAL = NJR.NJR_FILIAL
		                             AND NNY.NNY_CODCTR = NJR.NJR_CODCTR
		                             AND NNY.%notDel%
		WHERE NNY.%notDel%
		      %exp:cFiltro%
		ORDER BY NJR.NJR_CODCTR

	EndSQL

	//apropriação de dados
	DbselectArea( cAliasNJR )
	DbGoTop()
	While ( cAliasNJR )->( !Eof() )

	    nQtdFixTot := 0 //reset value
	    nPrecoFix  := 0
	    nQtdWork   := 0
	    aCompTrab  := {} //reset

	    cResFix := ""
		If (cAliasNJR)->NJR_RESFIX  == '1'
			cResFix := STR0073	//"Comprador"
		ElseIf (cAliasNJR)->NJR_RESFIX   == '2'
			cResFix := STR0074	//"Vendedor"
		ElseIf (cAliasNJR)->NJR_RESFIX   == '3'
			cResFix := STR0075	//"Ambos"
		EndIf
	    
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
		 	  AND (N79.N79_TIPO  = "2" OR N79.N79_TIPO = "3" OR N79.N79_TIPO = "5") //fixação ou cancelamento
		 	  %exp:cFiltroN79%	 	  	    			         		           
		EndSQL
		
		//apropriação de dados
		DbselectArea( cAliasN79 )
		DbGoTop()
		while ( cAliasN79 )->( !Eof() ) //não possso ter mais de 1 negócio em aberto
			
			Reclock(_cTabCtr, .T.)
			
			(_cTabCtr)->FIX_STATUS  := fFixStatus((cAliasN79)->N79_TIPO, (cAliasN79)->N79_STATUS ) //Trabalhando
			(_cTabCtr)->NJR_FILIAL 	:= (cAliasNJR)->NJR_FILIAL
			(_cTabCtr)->NNY_ITEM	:= (cAliasNJR)->NNY_ITEM
			(_cTabCtr)->NNY_MESEMB	:= (cAliasNJR)->NNY_MESEMB
			(_cTabCtr)->NNY_FILORG	:= (cAliasNJR)->NNY_FILORG
			(_cTabCtr)->NNY_FILDES	:= OGX700PSM0(cAliasNJR + '->NNY_FILORG')
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
			(_cTabCtr)->NJR_RESFIX 	:= cResFix
			(_cTabCtr)->NJR_BOLSA 	:= (cAliasNJR)->NJR_BOLSA
			(_cTabCtr)->NNY_IDXNEG 	:= (cAliasNJR)->NNY_IDXNEG
			(_cTabCtr)->NNY_IDXCTF 	:= (cAliasNJR)->NNY_IDXCTF			
			(_cTabCtr)->NJR_DATA 	:= StoD((cAliasN79)->N79_DATA)
			(_cTabCtr)->QTDWORK   	:= iif((_cTabCtr)->FIX_STATUS == "2", (cAliasN79)->N7A_QTDINT, 0)
			(_cTabCtr)->NJR_QTDCTR 	:= (cAliasN79)->N7A_QTDINT
			(_cTabCtr)->NNY_DATINI 	:= StoD((cAliasNJR)->NNY_DATINI)
			(_cTabCtr)->NNY_DATFIM 	:= StoD((cAliasNJR)->NNY_DATFIM)
			(_cTabCtr)->NNY_DTLFIX 	:= StoD((cAliasNJR)->NNY_DTLFIX)	
			
					
			if (cAliasN79)->N79_TPCANC == "2" //Quantidade
				(_cTabCtr)->TIPO_FIX := STR0078
			elseif (cAliasN79)->N79_FIXAC == "1" //Preço
				nQtdWork             := iif((_cTabCtr)->FIX_STATUS == "2", (cAliasN79)->N7A_QTDINT, 0)//é fixação de preço 
				
				//contando com os itens que estao em aprovacao
				if (cAliasN79)->N79_STATUS <> "3" //finalizado
					nQtdFixTot           += iif(!((_cTabCtr)->FIX_STATUS $ "7|8|9"), (cAliasN79)->N7A_QTDINT, 0)
				endif	
				
				(_cTabCtr)->TIPO_FIX := iif((cAliasN79)->N79_TIPO == "2", STR0064, STR0065)
			else
				(_cTabCtr)->TIPO_FIX := iif((cAliasN79)->N79_TIPO == "2", STR0066, STR0067 )
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
					
					&("(_cTabCtr)->CMP"+(cAliasN7C)->N7C_CODCOM ) := (((cAliasN7C)->N7C_VLRCOM * (cAliasN7C)->N7C_QTAFIX) + ((cAliasN7C)->N7C_VLRFIX * (cAliasN7C)->N7C_QTDFIX)) / ( (cAliasN7C)->N7C_QTAFIX + (cAliasN7C)->N7C_QTDFIX)
					&("(_cTabCtr)->CMP"+(cAliasN7C)->N7C_CODCOM +"1") := (cAliasN7C)->N7C_QTAFIX + (cAliasN7C)->N7C_QTDFIX 
	
				elseif (cAliasN7C)->N7C_TPCALC == "R" .and. (cAliasN7C)->N7C_TPPREC == "2" //Preço Negociado
					(_cTabCtr)->NN8_VLRUNI	:= (cAliasN7C)->N7C_VLRCOM			
				endif
								
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
		
		
		Reclock(_cTabCtr, .T.)

			(_cTabCtr)->NJR_FILIAL 	:= (cAliasNJR)->NJR_FILIAL
			(_cTabCtr)->NNY_ITEM	:= (cAliasNJR)->NNY_ITEM
			(_cTabCtr)->NNY_MESEMB	:= (cAliasNJR)->NNY_MESEMB
			(_cTabCtr)->NNY_FILORG	:= (cAliasNJR)->NNY_FILORG
			(_cTabCtr)->NNY_FILDES	:= OGX700PSM0(cAliasNJR + '->NNY_FILORG')
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
			(_cTabCtr)->NJR_RESFIX 	:= cResFix
			(_cTabCtr)->NJR_BOLSA 	:= (cAliasNJR)->NJR_BOLSA
			(_cTabCtr)->NNY_IDXNEG 	:= (cAliasNJR)->NNY_IDXNEG
			(_cTabCtr)->NNY_IDXCTF 	:= (cAliasNJR)->NNY_IDXCTF			
			(_cTabCtr)->QTDAFIXAR	:= (cAliasNJR)->NNY_QTDINT - nQtdFixTot
			(_cTabCtr)->NJR_DATA 	:= StoD((cAliasNJR)->NJR_DATA)
			(_cTabCtr)->NJR_QTDCTR 	:= (cAliasNJR)->NNY_QTDINT
			(_cTabCtr)->QTDWORK   	:= nQtdWork
			(_cTabCtr)->NNY_DATINI 	:= StoD((cAliasNJR)->NNY_DATINI)
			(_cTabCtr)->NNY_DATFIM 	:= StoD((cAliasNJR)->NNY_DATFIM)
			(_cTabCtr)->NNY_DTLFIX 	:= StoD((cAliasNJR)->NNY_DTLFIX)
			(_cTabCtr)->NN8_VLRUNI  := nPrecoFix / nQtdFixTot //monta a média ponderada
			(_cTabCtr)->TIPO_FIX    := STR0068

		/**Busca os dados*/
		//Realiza a Busca nas Fixações de componente
		BeginSql Alias cAliasN7M
			SELECT N7M.N7M_CODCOM, SUM(N7M_QTDFIX) N7M_QTDFIX, SUM(N7M_VALOR * N7M_QTDFIX ) N7M_VALOR
			  FROM %Table:N7M% N7M
			  
			WHERE N7M.%notDel%
			  AND N7M.N7M_FILIAL = %exp:(cAliasNJR)->NJR_FILIAL%
			  AND N7M.N7M_CODCTR = %exp:(cAliasNJR)->NJR_CODCTR%
			  AND N7M.N7M_CODCAD = %exp:(cAliasNJR)->NNY_ITEM%
			GROUP BY N7M.N7M_CODCOM
	        
		EndSQL

		//apropriação de dados
		DbselectArea( cAliasN7M )
		DbGoTop()
		While ( cAliasN7M )->( !Eof() )

			if ASCAN(_aCpsBrowCt, {|x| AllTrim(x[2]) == "CMP"+(cAliasN7M)->N7M_CODCOM}) > 0 //verifica se existe o componente
				
				&("(_cTabCtr)->CMP"+(cAliasN7M)->N7M_CODCOM )     := (cAliasN7M)->N7M_VALOR / (cAliasN7M)->N7M_QTDFIX
				&("(_cTabCtr)->CMP"+(cAliasN7M)->N7M_CODCOM +"1") := (cAliasN7M)->N7M_QTDFIX
				&("(_cTabCtr)->CMP"+(cAliasN7M)->N7M_CODCOM +"2") := (cAliasNJR)->NNY_QTDINT - (cAliasN7M)->N7M_QTDFIX
						
			endif

			(cAliasN7M)->(dbSkip())
		enddo
		
		(cAliasN7M)->(dbCloseArea())
		
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
		else
		   (_cTabCtr)->FIX_STATUS := "5" //à fixar
		endif

		(_cTabCtr)->(MsUnlock())
		
		
	(cAliasNJR)->(dbSkip())

	enddo

	(cAliasNJR)->(dbCloseArea())

Return(.t.)

/** {Protheus.doc} SetDataBlc
Função que monta as Temp-Tables da Rotina
@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     24/07/2017
@Uso:       OGC040 - Consulta de Blocos/Fardos
*/
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

/*{Protheus.doc} fMntFiltro
Monta o Filtro de Busca de Dados
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Static Function fMntFiltro()
	Local cFiltro := ""

	//trata os filtros
	cFiltro  =  "  AND NJR.NJR_FILIAL >= '" + MV_PAR01  + "'"
	cFiltro +=  "  AND NJR.NJR_FILIAL <= '" + MV_PAR02  + "'"
	cFiltro +=  "  AND NJR.NJR_CODCTR >= '" + MV_PAR03  + "'"
	cFiltro +=  "  AND NJR.NJR_CODCTR <= '" + MV_PAR04  + "'"
	cFiltro +=  "  AND NJR.NJR_CODENT >= '" + MV_PAR05  + "'"
	cFiltro +=  "  AND NJR.NJR_LOJENT >= '" + MV_PAR06  + "'"
	cFiltro +=  "  AND NJR.NJR_CODENT <= '" + MV_PAR07  + "'"
	cFiltro +=  "  AND NJR.NJR_LOJENT <= '" + MV_PAR08  + "'"
	cFiltro +=  "  AND NJR.NJR_CODSAF >= '" + MV_PAR09  + "'"
	cFiltro +=  "  AND NJR.NJR_CODSAF <= '" + MV_PAR10  + "'"
	cFiltro +=  "  AND NJR.NJR_CODPRO >= '" + MV_PAR11  + "'"
	cFiltro +=  "  AND NJR.NJR_CODPRO <= '" + MV_PAR12  + "'"
	cFiltro +=  "  AND NJR.NJR_TABELA >= '" + MV_PAR13  + "'"
	cFiltro +=  "  AND NJR.NJR_TABELA <= '" + MV_PAR14  + "'"

	if !Empty(MV_PAR15)
		cFiltro +=  "  AND NJR.NJR_DATA   >= '" + dTOs(MV_PAR15)  + "'"
	endif

	if !Empty(MV_PAR16)
		cFiltro +=  "  AND NJR.NJR_DATA   <= '" + dTOs(MV_PAR16)  + "'"
	endif

	if !Empty(MV_PAR17)
		cFiltro +=  "  AND NNY.NNY_DTLFIX >= '" + dTOs(MV_PAR17)  + "'"
	endif

	if !Empty(MV_PAR18)
		cFiltro +=  "  AND NNY.NNY_DTLFIX <= '" + dTOs(MV_PAR18)  + "'"
	endif
	
	
	if !Empty(MV_PAR20)
		cFiltro +=  "  AND NJR.NJR_CTREXT >= '" + MV_PAR20  + "'"
	endif

	if !Empty(MV_PAR21)
		cFiltro +=  "  AND NJR.NJR_CTREXT <= '" + MV_PAR21  + "'"
	endif
	
	
	cFiltro +=  "  AND NJR.NJR_CODNGC <> ''" //força para mostrar somente aqueles pelo processo novo
return cFiltro

/*{Protheus.doc} OGC04F12
Reexecuta o Filtro de Busca
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Function OGC04F12(lPergunta)
	// Abre a tela de parâmetros de perguntas
	If lPergunta .and. !Pergunte(STR0001, .T.)
		Return 
	Else
		Pergunte(STR0001, .F.)
	EndIf

	//monta filtro
	_cFiltro := fMntFiltro() //apropria filtro

	//limpa o filtro
	//_oBrowse:oFwFilter:CleanFilter(.T.)

	//-- Carrega dados e cria arquivos temporários
	Processa( { || fLoadDados(_cFiltro) }, STR0010)	//"Aguarde..."

	_oBrowse:UpdateBrowse()

Return(.t.)

/*{Protheus.doc} OGC004FXOK
Opções do menu do OGA700
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Function OGC004X700(nOption)
	Local lUpdateBrw := .f.
	Local cChave := (_cTabCtr)->(FIX_STATUS)+(_cTabCtr)->(NJR_CODCTR)+(_cTabCtr)->(NJR_FILIAL)+(_cTabCtr)->(NNY_ITEM)
	 
	//Posciona Registro		
	DbselectArea( "N79" )
	DbSetOrder( 1 )
	DbGoTop()
	
	If N79->(dbSeek( (_cTabCtr)->NJR_FILIAL + (_cTabCtr)->NJR_CODNGC + (_cTabCtr)->NJR_VERSAO))
		Do Case 
			Case nOption == 1 
				lUpdateBrw := OGA700APVA()
			Case nOption == 2 
				lUpdateBrw := OGA700REPR()
			Case nOption == 3 
				AGRCONHECIM('N79')
			Case nOption == 4 
				OGA700HIST()			
		EndCase
		
		if lUpdateBrw
			//reload de browser
			OGC04F12(.f.)

			OGC04PER(cChave)
		endif
	endif

		
return(.t.)


/*{Protheus.doc} OGC004FIXA
Tela para fixação de Preço/Componente
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
/*/
Function OGC004FIXA()
Local cChave := (_cTabCtr)->(FIX_STATUS)+(_cTabCtr)->(NJR_CODCTR)+(_cTabCtr)->(NJR_FILIAL)+(_cTabCtr)->(NNY_ITEM)

	//verifica se o registro está disponivel para fixação
	if (_cTabCtr)->FIX_STATUS $ "4|5"
		
		//posiciona no registro para fixar
		DbselectArea( "N79" )
		N79->(DbGoTop())
		N79->(dbSetOrder(1))
		if N79->(dbSeek((_cTabCtr)->NJR_FILIAL+(_cTabCtr)->NJR_CODNGC+(_cTabCtr)->NJR_VERSAO))
			OGA700FIXA((_cTabCtr)->NNY_ITEM)
		else
			Help( ,,STR0027,, STR0057, 1, 0 ) //"AJUDA"###"Registro Não Encontrado para Fixação"                                                                                                                                                                                                                                                                                                                                                                                                                              
			return(.F.) 
		endif	
		
		//reload de browser
		OGC04F12(.f.)

		OGC04PER(cChave)

	else
		//não se trata de fixação trabalhando
		Help( ,,STR0027,, STR0028, 1, 0 ) //"AJUDA"###"A Opção de Fixação é somente para contratos com Status 'Fixação Parcial e À Fixar'."                                                                                                                                                                                                                                                                                                                                                                                                                               
		return(.F.) 
	endif
		
return(.t.)

/*{Protheus.doc} OGC004VIEW
//Visualização de Fixações
@author jean.schulze
@since 14/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC004VIEW()
	Local cChave := (_cTabCtr)->(FIX_STATUS)+(_cTabCtr)->(NJR_CODCTR)+(_cTabCtr)->(NJR_FILIAL)+(_cTabCtr)->(NNY_ITEM)

	OGC050( (_cTabCtr)->NJR_FILIAL, (_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NNY_ITEM, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO )

	//reload de browser
	OGC04F12(.f.)	

	OGC04PER(cChave)
	
	
return .t.

/*{Protheus.doc} OGC004AGLU
Chamada para operação de aglutinação
@author jean.schulze
@since 14/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC004AGLU()
	Local cChave := (_cTabCtr)->(FIX_STATUS)+(_cTabCtr)->(NJR_CODCTR)+(_cTabCtr)->(NJR_FILIAL)+(_cTabCtr)->(NNY_ITEM)
	
	OGX720((_cTabCtr)->NJR_FILIAL, (_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NNY_ITEM)
	
	//reload de browser
	OGC04F12(.f.)	
	
	OGC04PER(cChave)
return .t.

/*{Protheus.doc} OGC004CFIX
//Apresenta o browse de cancelamento de fixação.
@author roney.maia
@since 23/10/2017
@version 1.0
@param cCodCtr, characters, Código do Contrato
@param cStatusReg  - status do registro
@type function
*/
Function OGC004CFIX(cFilCtr, cCodCtr, cCodCad, cCodNgc, cVersao, cStatusReg, cFuncao)
	Local aArea		:= GetArea()
	Local oExecView	:= FWViewExec():New()
	Local oView    	:= FWFormView():New()
	Local oModel	:= MPFormModel():New("OGC004CFIX", , , {|| .T.}) // Instancia um objeto model
	Local oStruFld  := FWFormModelStruct():New() // Instancia uma Struct do Tipo Model
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F., Nil},{.T., STR0052},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Fechar"
	Local aListNgc  := {}
	Local cFiltDft  := "@ "
	Local nX        := 0
	Local cDescri   := ""
	Local cBtFechar := ""
	Local cBtOpcao  := ""
	Local cBtVisual := ""
	Local cChave := (_cTabCtr)->(FIX_STATUS)+(_cTabCtr)->(NJR_CODCTR)+(_cTabCtr)->(NJR_FILIAL)+(_cTabCtr)->(NNY_ITEM)

	Private _oMBrwCFix 	:= FWMBrowse():New()
	Private _oFilBrw	:= Nil
	Private _cAliasBrw  := ""
	Private _aCpsBrow   := {}
	
	Default cCodCtr    := ""
	Default cStatusReg := "" 
	Default cFuncao    := "C" //cancelar
	
	cDescri   := IIF( cFuncao == "C", STR0050, STR0085 )       // "Cancelamento de Fixação" / Selecionar a Fixação
	cTitulo   := IIF( cFuncao == "C", STR0051, STR0086 )       //"Cancelamento de Fixação" / 
	cBtFechar := STR0052 // Fechar
	cBtOpcao  := IIF( cFuncao == "C", STR0053, STR0087 )       //Cancelar / Selecionar
	cBtVisual := STR0054 //Visualizar
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F., Nil},{.T., cBtFechar},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Fechar"

    if cStatusReg $ "1|4|5"
		cCodNgc := "" 
    EndIf
	
    aListNgc  := OGC004LIST(cFilCtr, cCodCtr, cCodCad, cCodNgc, cVersao, " AND (N79.N79_TIPO <= '2' OR N79.N79_TIPO = '5' )") //retornar também os novos negócios 
    _cAliasBrw  := "N79"
    dbSelectArea( _cAliasBrw ) // Selecia o alias para realizar a ordenação anteriormente para utilização no browse
    (_cAliasBrw)->(dbSetOrder(3)) // Seta a ordenacao por data
    if len(aListNgc) == 0 //não encontrou nada
       
       Help( ,,STR0027,, iif(cFuncao == "C", STR0058, STR0088), 1, 0 )   //"Não existem negociações com saldo para cancelamento."                                                                                                                                                                                                                                                                                                                                                                                                                             
       RestArea(aArea)
       Return .F.

    elseif len(aListNgc) == 1 //somente 1
       dbSelectArea("N79")
       N79->(dbSetOrder(1)) 
 
       if N79->(dbSeek(aListNgc[1][1]+aListNgc[1][2]+aListNgc[1][3]))
          If cFuncao == "C"
          	OGA700CANC() //cancelamento
          else
          	OGA700MODF() //modificar
          endif	
       endif 
       
       RestArea(aArea)
 
       //reload de browser
       OGC04F12(.f.)

	   OGC04PER(cChave)	

       Return .t.
    else //temos vários negócios
      
       //monta o filtro com somente os negócios selecionados
       for nX := 1 to len(aListNgc)
          if nX > 1
             cFiltDft += " OR "
          endif
          cFiltDft += " R_E_C_N_O_ = "+alltrim(str(aListNgc[nX][4]))
       next nX
	  
	   _cAliasBrw := "N79" // Selecia o alias para realizar a ordenação anteriormente para utilização no browse
	   (_cAliasBrw)->(dbSetOrder(3)) // Seta a ordenacao por data
      
       cDescri := STR0050 // # "Cancelamento de Fixação"
      
       _oMBrwCFix:AddLegend( "N79_FIXAC=='1'", "BR_CINZA", X3CboxDesc( "N79_FIXAC", "1" )   ) //"Preço"
       _oMBrwCFix:AddLegend( "N79_FIXAC=='2'", "BR_VERDE", X3CboxDesc( "N79_FIXAC", "2" )   ) //"Componente"
      
    EndIf
   
	_oMBrwCFix:SetAlias( _cAliasBrw )
	_oMBrwCFix:SetDescription(cDescri)
	_oMBrwCFix:SetMenuDef("")
	_oMBrwCFix:DisableDetails()
	_oMBrwCFix:SetProfileId("OGC004CFIX")

	If .NOT. Empty(cCodCtr)  // Se foi passado como parametro o contrato então adicionar o mesmo ao filtro
       _oMBrwCFix:AddButton(cBtOpcao , {|| Iif(Iif(cFuncao == "C",OGA700CANC(),OGA700MODF()), _oMBrwCFix:UpdateBrowse(), Nil)} , , 4) // # "Cancelar"
	   _oMBrwCFix:AddButton(cBtVisual, "OGA700VISU", , 2) // # "Visualizar"
	  
	   If .NOT. Empty(cFiltDft) // Se foi passado como parametro o contrato então adicionar o mesmo ao filtro
	      _oMBrwCFix:SetFilterDefault(cFiltDft) // Seta o filtro
	   Else
	   	   _oMBrwCFix:SetFilterDefault("@ N79_CODCTR = '" + cCodCtr + "' AND (N79_TIPO = '2' OR N79_TIPO = '5' ) AND N79_STATUS = '3'") // Seta o filtro
	   EndIF
	   
	endif
	
	oStruFld:AddField("FLDID", "FLDID", 'FLDID', 'C' , 6 , 0, , , , .T., , , .F., .T.) // Default Model Requerido
	oModel:AddFields("MODEL_FLD",/*cOwner*/,oStruFld,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:GetModel("MODEL_FLD"):SetDescription(cDescri)// # "Cancelamento de Fixação" | Default Model Requerido
	oModel:SetPrimaryKey({"FLDID"}) // Default Model Requerido
	oModel:SetDescription(cDescri)   //Default Model Requerido 
							
	oView:SetModel(oModel) // Seta o modelo
	oView:AddOtherObject("VIEW_BROWSE", {|oPanel, oObj| _oMBrwCFix:SetOwner(oPanel), _oMBrwCFix:Activate(), _oFilBrw := _oMBrwCFix:FwFilter() }, {|| _oFilBrw:CleanFilter(), _oMBrwCFix:DeActivate()}) // Adiciona o componente browse	
	oView:CreateHorizontalBox( 'BOXBROWSE', 100 ) // Cria o box
	oView:SetOwnerView("VIEW_BROWSE", "BOXBROWSE") // Seta a view proprietária do box

	oExecView:SetView(oView) // Seta a view utilizada no ExecView
	oExecView:SetTitle(cTitulo) // # "Cancelamento de Fixação"
	oExecView:SetOperation(MODEL_OPERATION_INSERT) // Seta operação como inserção
	oExecView:SetReduction(10) // Percentual de redução da tela
	oExecView:SetButtons(aButtons)
	
	//oExecView:SetDescription(cDescri)
	
	oExecView:OpenView(.F.) // Abre a view

	RestArea(aArea)
	
	//reload de browser
	OGC04F12(.f.)	
	
Return


/*{Protheus.doc} OGC004LIST
Retorna os negócios que possuem saldo a cancelar
@author jean.schulze
@since 14/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@param cCodNgc, characters, descricao
@type function
*/
function OGC004LIST(cFilCtr, cCodCtr, cCodCad, cCodNgc, cVersao, cTipos)
 	Local aListNgcs := {}
 	Local cAliasN79 := GetNextAlias()
 	Local lSaldo    := .f.
 	Local cFiltro   := ""
 	
	if !Empty(cCodNgc)
		cFiltro := "AND N79.N79_CODNGC = '" + cCodNgc + "'"	
		cFiltro += "AND N79.N79_VERSAO = '" + cVersao + "'"	
	endif
	
	cFiltro += cTipos
	
	cFiltro := "%" + cFiltro + "%"	
	
	BeginSql Alias cAliasN79

	   SELECT N79_FILIAL, N79_CODNGC, N79_VERSAO, N7A_CODCAD, N79_FIXAC , N79_TIPO ,N79.R_E_C_N_O_ N79REC 
	  	  FROM %Table:N79% N79 
  	      INNER JOIN %Table:N7A% N7A ON  N7A.N7A_FILIAL = N79.N79_FILIAL
	  	  							 AND N7A.N7A_CODNGC = N79.N79_CODNGC
	  	  							 AND N7A.N7A_VERSAO = N79.N79_VERSAO
	  	  							 AND N7A.N7A_USOFIX <> "LBNO" //somente os que estão de fato no negócio.
		WHERE N79.%notDel%
		  AND N79.N79_FILIAL = %exp:cFilCtr% 
		  AND N79.N79_CODCTR = %exp:cCodCtr% 
		  AND N7A.N7A_CODCAD = %exp:cCodCad% 
	 	  AND N79.N79_STATUS = "3"  //diferente de aprovado ou rejeitado
	 	  	  %exp:cFiltro%		           
	EndSQL
	
	DbselectArea( cAliasN79 )
	DbGoTop()
	while ( cAliasN79 )->( !Eof() )
		
		//reset
		lSaldo := .f.
		
		//verifica se tem saldo de quantidade
		/*if ( cAliasN79 )->N79_TIPO == "1" //novo negócio
			if OGX700SDCQ(( cAliasN79 )->N79_FILIAL, cCodCtr, ( cAliasN79 )->N7A_CODCAD) > 0
			 	lSaldo := .t.
			endif
		endif*/
		
		if lSaldo = .f.
			if ( cAliasN79 )->N79_FIXAC == "1" //preço
				if OGX700SLDP(( cAliasN79 )->N79_FILIAL, ( cAliasN79 )->N79_CODNGC, ( cAliasN79 )->N79_VERSAO, ( cAliasN79 )->N7A_CODCAD) > 0
					lSaldo := .t.
				endif
			else
				if OGX700SLDC(( cAliasN79 )->N79_FILIAL, ( cAliasN79 )->N79_CODNGC, ( cAliasN79 )->N79_VERSAO, ( cAliasN79 )->N7A_CODCAD) > 0
					lSaldo := .t.
				endif
			endif
		endif
		
		if lSaldo
			if ASCAN(aListNgcs, {|x| AllTrim(x[1]+x[2]+x[3]) == alltrim(( cAliasN79 )->N79_FILIAL+( cAliasN79 )->N79_CODNGC+( cAliasN79 )->N79_VERSAO)}) == 0
				aAdd(aListNgcs, {( cAliasN79 )->N79_FILIAL, ( cAliasN79 )->N79_CODNGC, ( cAliasN79 )->N79_VERSAO, ( cAliasN79 )->N79REC})
			endif	
		endif
	  	( cAliasN79 )->( dbSkip() )
	enddo
	( cAliasN79 )->( dbCloseArea() )
return aListNgcs


/*{Protheus.doc} OGC004SLFX
Campos de seleção de fixação
@author jean.schulze
@since 06/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Function OGC004SLFX()
   __aFixacaoSelec := {(_cAliasBrw)->NN8_FILIAL, ; 
                      (_cAliasBrw)->NN8_CODCTR, ;
                      (_cAliasBrw)->NN8_CODCAD, ;
                      (_cAliasBrw)->NN8_CODNGC, ;
                      (_cAliasBrw)->NN8_VERSAO, ;
                      (_cAliasBrw)->NN8_ITEMFX, ;
                      (_cAliasBrw)->NN8_QTDFIX, ;
                      (_cAliasBrw)->NN8_VLRUNI, ;
                      (_cAliasBrw)->NN8_VLRTOT, ;
                      (_cAliasBrw)->NN8_RECNO }

Return .T.


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

/*{Protheus.doc} OGC004CBOL
Função para geração da Boleta
@author  rafael.voltz
@since   21/07/2018
@version version
*/
Function OGC004CBOL()

	OGAR740((_cTabCtr)->NJR_CODCTR, (_cTabCtr)->NJR_CODNGC, (_cTabCtr)->NJR_VERSAO)

	/*Restaura os parâmetros do pergunte */
	Pergunte( STR0001, .F. )
	
	//reload de browser
	OGC04F12(.f.)	
Return

/*{Protheus.doc} OGC04PER
Reexecuta o Filtro de Busca
@author Christopher.miranda
@since 21/11/2018
@version undefined
@type function
*/
Function OGC04PER(cChave)

	dbSelectArea(_cTabCtr)
	(_cTabCtr)->(DbSetOrder(1))
	(_cTabCtr)->(dbSeek(cChave))

	_oBrowse:GoTo((_cTabCtr)->(RECNO()))

Return(.t.)


/*/{Protheus.doc} OGC004SINT
//Legenda referente a cada registro
@author carlos.augusto
@since 23/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cStatus, characters, descricao
@type function
/*/
Static Function OGC004SINT(cStatus)

	Do Case
		Case cStatus == " "
		cStatus := "BR_BRANCO" 	//Não foi realizada tentativa de integração
		Case cStatus == "1"
		cStatus := "BR_VERDE" 	//Integrado
		Case cStatus == "2"
		cStatus := "BR_VERMELHO" //Falha na tentativa
	EndCase
    
Return cStatus

/*/{Protheus.doc} OGC004CANQ
Tratamento para buscar o novo negócio, para cancelamento de quantidade
@author jean.schulze
@since 23/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@type function
/*/
Function OGC004CANQ(cFilCtr, cCodCtr)
	
	//Posicionamos na NJR
	DbselectArea( "NJR" )
	NJR->(DbGoTop())
	NJR->(dbSetOrder(1))
	if NJR->(dbSeek(cFilCtr+cCodCtr))
		
		//posiciona no registro para cancelar
		DbselectArea( "N79" )
		N79->(DbGoTop())
		N79->(dbSetOrder(1))
		if N79->(dbSeek(NJR->NJR_FILIAL+NJR->NJR_CODNGC+NJR->NJR_VERSAO))
			OGA700CANC()
		else
			Help( ,,STR0027,, STR0096, 1, 0 ) //"AJUDA"###"Registro não encontrado para cancelamento."                                                                                                                                                                                                                                                                                                                                                                                                                              
			return(.F.) 
		endif	
		
	else
		Help( ,,STR0027,, STR0096, 1, 0 ) //"AJUDA"###"Registro não encontrado para cancelamento."                                                                                                                                                                                                                                                                                                                                                                                                                              
		return(.F.) 
	endif	

	//reload de browser
	OGC04F12(.f.)	
	
return .t.
