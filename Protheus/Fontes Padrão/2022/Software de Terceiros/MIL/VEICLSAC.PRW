////////////////
// Versao 017 //
////////////////

#include "protheus.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/07/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006839_1"

Function VEICLSAC()
Return()

/*/{Protheus.doc} DMS_ControleFerramentasDAO
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Classe que faz contato com o banco de dados em busca dos dados de Prestadores/Eq. Tecnica VAI
/*/
Class DMS_ControleFerramentasDAO
	Method New() CONSTRUCTOR
	Method GetRequisicoes()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_ControleFerramentasDAO

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class DMS_ControleFerramentasDAO
Return SELF

/*/{Protheus.doc} GetRequisicoes
	Retorna as Ferramentas movimentadas(VD3)

	@author Vinicius Gati
	@since 05/05/2014
	@param cCodVDP, character, Codigo da movimentacao de ferramentas VDP
/*/
Method GetRequisicoes(cCodVDP) Class DMS_ControleFerramentasDAO
	Local aResults := {}
	Local cTblVD3  := RetSqlName('VD3')
	Local cFilVD3  := xFilial('VD3')
	Local cAlias   := 'ReqFerramentas'
	Local cQuery   := ""

	cQuery += "   SELECT VD3.VD3_SEQUEN, VD3.VD3_CODFER, VD3.VD3_DATMOV, VD3.VD3_QTDMOV, VD3.R_E_C_N_O_ "
	cQuery += "     FROM " + cTblVD3 + " VD3"
	cQuery += "    WHERE VD3.VD3_FILIAL = '" +cFilVD3+ "' "
	cQuery += "      AND VD3.VD3_CODIGO = '" +cCodVDP+ "' "
	cQuery += "      AND VD3.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VD3.VD3_SEQUEN ASC "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
	(cAlias)->(DbGoTop()) // Posiciona o cursor no inicio da area de trabalho ativa
	While !EOF()          // Enquanto o cursor da area de trabalho ativa nao indicar fim de arquivo
		aData := {                                 ;
			{ 'VD3_CODIGO', cCodVDP              },;
			{ 'VD3_SEQUEN', (cAlias)->VD3_SEQUEN },;
			{ 'VD3_CODFER', (cAlias)->VD3_CODFER },;
			{ 'VD3_DATMOV', (cAlias)->VD3_DATMOV },;
			{ 'VD3_QTDMOV', (cAlias)->VD3_QTDMOV },;
			{ 'R_E_C_N_O_', (cAlias)->R_E_C_N_O_ } ;
		}
		oEl := DMS_RequisicaoFerramenta():New(aData)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAlias)->(dbCloseArea())
Return aResults

/*/{Protheus.doc} DMS_Campanha
	Representa tabela do VX5

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class DMS_Campanha
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class DMS_Campanha
Return Self

Method GetTbCode() Class DMS_Campanha
Return '026'


/*/{Protheus.doc} DMS_CampanhaDAO

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Classe criada para acoplar metodos relacionados a campanha, assim como seus dados de tabela ja que a mesma esta no VX5
	// TODO: Remover duplicada

/*/
CLASS DMS_CampanhaDAO
	METHOD New() CONSTRUCTOR
	METHOD TableCode() // codigo da tabela no vx5
ENDCLASS

METHOD New() CLASS DMS_CampanhaDAO
Return SELF

METHOD TableCode() CLASS DMS_CampanhaDAO
Return '026'



/*/{Protheus.doc} DMS_CacheB2

	@author       Vinicius Gati
	@since        06/07/2015
	@description  Classe criada para criar tabela e manipular dados de cache de b2

/*/
CLASS DMS_CacheB2
	Data cTableName

	Method New() CONSTRUCTOR
	Method CacheInv()
	Method PrepareToProc()
	Method CacheToPMM()
	Method AnyToProc()
	Method ProcLote()
	Method GetInfo()
	Method GetTotInv()
	Method Clear()
ENDCLASS

//	[1] nome do campo/coluna (maximo de 10 caracteres);
//	[2] tipo ("C" = Caracter, "N" = Numerico, "M" = Memo, "L" = Logico, "D" = Data);
//	[3] tamando (numerico);
//	[4] decimais (numerico)
Method New() Class DMS_CacheB2
	Local oSqlHlp := DMS_SqlHelper():New()

	cTableName := 'MIL_DPM_CACHE_INVENTARIO'
	aTblStruct := {            ;
		{'FILIAL', 'C', FWSizeFilial(), 0},; // FILIAL
		{'PRODUT', 'C', tamsx3("B1_COD")[1], 0},; // B1_COD
		{'DATAEX', 'D',  8, 0},; // DATA de EXECUCAO DO CALCEST (no parametro)
		{'ALMOXE', 'C', tamsx3("B2_LOCAL")[1], 0},; // LOCAL
		{'CM'    , 'N', tamsx3("B2_CM1")[1], tamsx3("B2_CM1")[2]},; // CUSTO MEDIO B2_CM1
		{'QUANT' , 'N', tamsx3("B2_QATU")[1], tamsx3("B2_QATU")[2]},; // QUANTIDADE EM ESTOQUE
		{'FLAGP' , 'C',  1, 0} ; // Flag de processamento
	}

	if ! oSqlHlp:ExistTable( cTableName )
		DBCreate( cTableName , aTblStruct, "TOPCONN" )

		TcSqlExec( "CREATE NONCLUSTERED INDEX idx_dpm_pmm15 ON MIL_DPM_CACHE_INVENTARIO (FILIAL , PRODUT , DATAEX , ALMOXE, D_E_L_E_T_)" )
	endIf
	::cTableName := cTableName
Return SELF

/*/{Protheus.doc} GetCalcEst

	@author       Vinicius Gati
	@since        06/07/2015
	@description  Processa registro de cache

/*/
Method CacheInv(cCodB1, dData) Class DMS_CacheB2
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local cBckFil := cFilANt

	DbSelectArea("SB2")

	cQuery += " SELECT R_E_C_N_O_ as CODIGO, FILIAL , ALMOXE FROM " + ::cTableName
	cQuery += "  WHERE DATAEX = '" +DTOS(dData)+ "'"
	cQuery += "    AND PRODUT = '" +cCodB1+      "'"
	cQuery += "    AND FLAGP  = ' ' " // nao processado
	cQuery += " ORDER BY FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )

	(cAlias)->(DbGoTop()) // Posiciona o cursor no inicio da area de trabalho ativa
	While ! (cAlias)->(EOF())          // Enquanto o cursor da area de trabalho ativa nao indicar fim de arquivo
		cFilAnt  := (cAlias)->FILIAL
		aCalcEst := CalcEst(cCodB1, (cAlias)->ALMOXE, dData)
		nQtd     := aCalcEst[1] // Elemento 1 - Quantidade inicial em estoque na data
		nCm      := IIF(nQtd > 0, aCalcEst[2]/aCalcEst[1] , aCalcEst[2]) // Elemento 2 - Custo inicial na data na moeda 1
		if nCm > 999999
			conout('WARNING OFINJD09 -> CUSTO MEDIO MUITO ALTO ' + cValToChar(nCm) + ' peça: ' + cCodB1 + ' filial: ' + cFilAnt)
		endif
		// Salvar os dados do calcest no registro
		cQuery := " UPDATE " + ::cTableName + ;
		          " SET QUANT = " + ALLTRIM(STR(nQtd)) + ;
		          "   , CM    = " + STRTRAN(TRANSFORM(nCm, "@E 9999999999.99"), "," , ".")  + ;
		          "   , FLAGP = 'P' " + ; // marca como processado
		          " WHERE R_E_C_N_O_ = " + ALLTRIM(STR( (cAlias)->CODIGO ))
		TcSqlExec(cQuery)
		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())
	cFilAnt := cBckFil
Return .T.

/*/{Protheus.doc} GetTotInv

	@author       Vinicius Gati
	@since        25/08/2015
	@description  Retorna o valor do inventario de acordo com os parametros:
		nInv := oCache:GetTotInv({;
			{'filial'        , cFilial},;
			{'data'          , dUltDia},;
			{'critical_code' , cCodCri},;
			{'tipo'          , cCodCri},; // D1 = original, outro nao original
			{'grupos'        , aGrupos},; // poucos grupos apenas?
			{'in_grupos'     , cInGrupos} ; //  devido a compatibilidade com BM deve-se passar o IN diretamente
		})

/*/
Method GetTotInv(aParams) Class DMS_CacheB2
	Local aData      := DMS_DataContainer():New(aParams)
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local cFilBck    := cFilAnt
	Local cAl        := GetNextAlias()
	Local oDpePecas  := DMSB_DpePecas():New()

	cCC := IIF( aData:GetValue('critical_code') == "00", "  ", aData:GetValue('critical_code') )
	cFilAnt := aData:GetValue('filial')

	cQuery := " "
	cQuery += " SELECT COALESCE( SUM( CACHE.CM * CACHE.QUANT ), 0) as TOTAL_INVENTARIO "
	cQuery += "   FROM " + self:cTableName  + " CACHE "
	cQuery += "   JOIN " + oSqlHlp:NoLock('SB1') + " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' AND CACHE.PRODUT    = SB1.B1_COD   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON SBM.BM_FILIAL  = '" + xFilial('SBM') + "' AND SBM.BM_GRUPO    = SB1.B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE CACHE.FILIAL     = '" + xFilial('SB2') + "' "
	cQuery += "    AND CACHE.DATAEX     = '" + DTOS(aData:GetValue('data')) + "' "
	cQuery += "    AND CACHE.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SB1.B1_CRICOD LIKE '" + cCC +  "' "
	cQuery += "    AND SBM.BM_PROORI = '" + aData:GetValue('tipo') + "' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

	If !(cAl)->(EOF())
		nTot := (cAl)->(TOTAL_INVENTARIO)
	EndIf

	(cAl)->(dbCloseArea())

	cFilAnt := cFilBck

Return nTot

/*/{Protheus.doc} PrepareToProc

	@author       Vinicius Gati
	@since        06/07/2015
	@description  Prepara tabela para rodar calcests e cachear[NUNCA CHAMAR DIRETAMENTE SEM USAR O PROCLOT, USER O CACHETOPMM]

/*/
Method PrepareToProc(dData, aGrupos, lForce) Class DMS_CacheB2
	Local cQuery     := ""
	Local cQueryI    := ""
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local oArHlp     := DMS_ArrayHelper():New()
	Local oDPM       := DMS_DPM():New()
	Local oLogger    := DMS_Logger():New()
	Local lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
	Default lForce   := .F.

	aDatasOk := oArHlp:Map( oLogger:GetArray("OFINJD25", 'MES_COMPLETO'), {|cData| STOD(cData) } )

	If FM_SQL(" SELECT COALESCE(COUNT(*), 0) as JAFEZ FROM  " + ::cTableName + " WHERE DATAEX = '"+DTOS(dData)+"' AND D_E_L_E_T_ = ' ' AND FLAGP = 'P' ") > 0
		If lForce == .T. //se esta feito pela metade ou esta pedindo pra fazer forçado
			// remove registros que podem estar errados devido a queda do processo
			// ao chamar esse metodo deve-se avaliar se o mes nao foi completado com sucesso antes pela tabela VQL
			// o OFINJD25 faz isso, se tiver registro e nao registrou como completo o mes e porque caiu na metade
			// nao e possível continuar de onde parou já que nao tem como saber se terminou
			TcSqlExec(" DELETE FROM " + ::cTableName + " WHERE DATAEX = '"+DTOS(dData)+"' ")
		Else
			Return .T. // ja foi feito o processamento, pode-se apenas reprocessar
		EndIf
	EndIf
	// possui todos os almoxerifes de cada b1 para cada filial
	cQuery  := ""
	cQueryI := ""
	cQueryI += " INSERT INTO " + ::cTableName + "(R_E_C_N_O_, FILIAL, PRODUT, ALMOXE, DATAEX, CM, QUANT) "
	cQuery  += "    SELECT DISTINCT SB2.B2_FILIAL c1, SB1.B1_COD c2, SB2.B2_LOCAL c3, '"+DTOS(dData)+"' c4, B2_CM1 c5, B2_QATU c6 "
	cQuery  += "      FROM "+oSqlHlp:NoLock('SB2')
	cQuery  += "      JOIN "+oSqlHlp:NoLock('SB1')+" ON SB2.B2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' '    "
	cQuery  += "     WHERE SB2.B2_LOCAL != ' '                                                              "
	cQuery  += "       AND SB2.D_E_L_E_T_ = ' '                                                             "

	If lNewGrpDPM
		cQuery += "    AND SB1.B1_GRUPO IN " + oDPM:GetInGroups()
	Else
		If Empty(aGrupos)
			aGrupos := oDPM:GetPecGroups()
		EndIf
		cQuery += "    AND SB1.B1_GRUPO IN ('" + oArHlp:Join(aGrupos, "','") + "') "
	EndIf

	cQuery  := oSqlHlp:RowCountFunc(cQuery,  " (ORDER BY c1) ", " (SELECT COALESCE(MAX(R_E_C_N_O_), 0) FROM " + ;
		::cTableName + ") + ")
	cQueryI += " " + cQuery
	If TcSqlExec(cQueryI) < 0
		Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} CacheToPMM

	@author       Vinicius Gati
	@since        06/07/2015
	@description  Buscara so B1s que foram movimentados para fazer calcest seletivamente e gerar um inventário em tempo hábil para uso
	@return       .T. se fez o cache rapido ou .F. se o inventario já está computado

/*/
Method CacheToPMM(nAno, nMes, aFilis) Class DMS_CacheB2
	Local cQuery   := ""
	Local cAl      := GetNextAlias()
	Local nIdx     := 1
	Local nIdx2    := 1
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local oUtil    := DMS_Util():New()
	Local cBckFil  := cFilAnt
	Local aProds   := {}
	Local dMesPass := nil
	Local oDPM     := DMS_DPM():New()
	Local oArHlp   := DMS_ArrayHelper():New()
	Local oLogger  := DMS_Logger():New()

	Default aFilis := oDPM:GetFiliais()

	aDatasOk := oArHlp:Map( oLogger:GetArray("OFINJD25", 'MES_COMPLETO'), {|cData| STOD(cData) } )
	dIni     := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + '01' ) // dia 1
	dIni     := oUtil:RemoveMeses(dIni, 1) - 1 // removo 1 mês pra pegar 2 meses de movimentacao e evitar arrastar erros por mais de 1 mes
	dUltDia  := oUtil:UltimoDia(nAno, nMes)
	dMesPass := oUtil:UltimoDia( YEAR(oUtil:RemoveMeses(dUltDia, 1)), MONTH(oUtil:RemoveMeses(dUltDia, 1)) ) // ultimo dia do mes passado

	If ASCAN( aDatasOk, {|dData| dData == dUltDia } ) > 0
		Return .F.
	EndIf

	::PrepareToProc(dUltDia)


	/**
	 * Parametro: Evita o uso do calcest ?
	 *
	 * Utilizado geralmente por clientes com problemas de lentidão que tem o SB2 razoávelmente correto
	 * ou confiável, é uma alternativa criada que deve ser utilizada com cautela.
	 */
	if GETMV("MV_MIL0146", .F.) == .T.
		tcSqlExec(" UPDATE " + ::cTableName + " SET FLAGP = 'P' WHERE FLAGP = ' ' AND DATAEX = '"+DTOS(dUltDia)+"' ")
		return .t.
	endif

	For nIdx := 1 to LEN(aFilis)
		DbSelectArea("SB2")
		cFilAnt  := aFilis[nIdx][1]
		cQuery := ""
		cQuery += " SELECT SD1.D1_COD PRODUT FROM " + oSqlHlp:NoLock('SD1') + " WHERE SD1.D1_EMISSAO BETWEEN '" + ;
			DTOS(dIni) + "' AND '"+DTOS(dUltDia+1)+"' AND SD1.D1_FILIAL = '" + xFilial('SD1') + "' "
		cQuery += " UNION "
		cQuery += " SELECT SD2.D2_COD PRODUT FROM " + oSqlHlp:NoLock('SD2') + " WHERE SD2.D2_EMISSAO BETWEEN '" + ;
			DTOS(dIni) + "' AND '"+DTOS(dUltDia+1)+"' AND SD2.D2_FILIAL = '" + xFilial('SD2') + "' "
		cQuery += " UNION "
		cQuery += " SELECT SD3.D3_COD PRODUT FROM " + oSqlHlp:NoLock('SD3') + " WHERE SD3.D3_EMISSAO BETWEEN '" + ;
			DTOS(dIni) + "' AND '"+DTOS(dUltDia+1)+"' AND SD3.D3_FILIAL = '" + xFilial('SD3') + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAl, .F., .T. )
		//
		// Pega os produtos que tiveram movimentacao na filial
		//
		// processa o inventario do mes de forma mais simplificada
		// pegando calcest somente dos produtos que foram movimentados
		//
		(cAl)->(DbGoTop()) // Posiciona o cursor no inicio da area de trabalho ativa
		While ! (cAl)->(EOF())
			// pega os almoxarifados do registro antigo para recalcular para o proximo(calcest)
			cQuery := ""
			cQuery += " SELECT ALMOXE FROM " + ::cTableName
			cQuery += "  WHERE DATAEX = '" + DTOS(dMesPass)  + "' "
			cQuery += "    AND FILIAL = '" + xFilial('SB2')  + "' "
			cQuery += "    AND PRODUT = '" + (cAl)->(PRODUT) + "' "
			aDados := oSqlHlp:GetSelect({  ;
				{'campos', {"ALMOXE"}     }, ;
				{'query' , cQuery         }  ;
			})
			//
			// Sem preocupacao com novos almoxerifados, pois os mesmos ja foram gravados no CACHE pelo metodo PrepareToProc
			//
			For nIdx2 := 1 to LEN(aDados)
				oRet := aDados[nIdx2] // dados do produto que sera atualizado

				aCalcEst := CalcEst((cAl)->(PRODUT), oRet:GetValue('ALMOXE') , dUltDia+1)
				nQtd     := aCalcEst[1] // Elemento 1 - Quantidade inicial em estoque na data
				nCm      := IIF(nQtd > 0, aCalcEst[2]/aCalcEst[1] , aCalcEst[2]) // Elemento 2 - Custo inicial na data na moeda 1
				if nCm > 999999
					conout('WARNING OFINJD09 -> CUSTO MEDIO MUITO ALTO ' + cValToChar(nCm) + ' peça: ' + (cAl)->(PRODUT) + ' filial: ' + cFilAnt)
				endif
				// Salvar os dados do calcest no registro
				cQuery := " UPDATE " + ::cTableName + ;
				          " SET QUANT = " + ALLTRIM(STR(nQtd)) + ;
				          "   , CM    = " + STRTRAN(TRANSFORM(nCm, "@E 9999999999.99"), "," , ".")  + ;
				          "   , FLAGP = 'P' " + ; // marca como processado
				          " WHERE DATAEX     = '" + DTOS(dUltDia) + "' " + ; // mes atual que estamos gerando PMM
				          "   AND ALMOXE     = '" + oRet:GetValue('ALMOXE') + "' " + ;
				          "   AND FLAGP      = ' ' " + ;
				          "   AND D_E_L_E_T_ = ' ' " + ;
				          "   AND PRODUT     = '" + (cAl)->(PRODUT) + "' " + ;
				          "   AND FILIAL     = '" + xFilial('SB2')  + "' "
				TcSqlExec(cQuery)
				//
			Next
			//
			(cAl)->(DbSkip())
		End
		(cAl)->(dbCloseArea())


	Next
	//
	If FM_SQL(" SELECT COALESCE(COUNT(*),0) FROM " + RetSqlName('VQL') + " WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND D_E_L_E_T_ = ' ' AND VQL_DADOS = 'MES_COMPLETO' AND VQL_DADOS ='" + DTOS(dUltDia) + "' ") > 0
		oLogger:LogToTable({                        ;
			{'VQL_AGROUP'     , 'OFINJD25'        },;
			{'VQL_TIPO'       , 'MES_COMPLETO'    },;
			{'VQL_DADOS'      , DTOS(dUltDia)     } ;
		})
	EndIf
	//
	//
	// Precisa depois de tudo, pegar o que tem do mes anterior e copiar como prox mes mantendo quantidade *INCRIVEL*
	// Replica mes anterior para o atual, somente de pecas nao processadas
	// isso e lindo
	if tcGetDb() == "ORACLE"
		cQuery := " UPDATE "+::cTableName+" T1 "
		cQuery += "    SET (QUANT,CM,FLAGP) = ( "
		cQuery += "         SELECT T2.QUANT, T2.CM, T2.FLAGP "
		cQuery += "           FROM "+ ::cTableName +" T2 "
		cQuery += "          WHERE T2.FILIAL  = T1.FILIAL "
		cQuery += "            AND T2.PRODUT  = T1.PRODUT "
		cQuery += "            AND T2.ALMOXE  = T1.ALMOXE "
		cQuery += "            AND T2.DATAEX  = '" + DTOS(dMesPass) + "' "
		cQuery += "            AND T2.FLAGP   = 'P' "
		cQuery += "            AND T2.D_E_L_E_T_ = ' ' "
		cQuery += " ) "
		cQuery += " WHERE T1.FILIAL = '"+xFilial('VS3')+"' "
		cQuery += "   AND T1.FLAGP  = ' ' "
		cQuery += "   AND T1.DATAEX = '"+DTOS(dUltDia)+"' "
		cQuery += "   AND T1.D_E_L_E_T_ = ' ' "
		cQuery += "   AND EXISTS ( "
		cQuery += "       SELECT PRODUT "
		cQuery += "         FROM MIL_DPM_CACHE_INVENTARIO T3 "
		cQuery += "        WHERE T3.FILIAL = T1.FILIAL "
		cQuery += "          AND T3.PRODUT = T1.PRODUT "
		cQuery += "          AND T3.ALMOXE = T1.ALMOXE "
		cQuery += "          AND T3.DATAEX = '" + DTOS(dMesPass) + "' "
		cQuery += "          AND T3.FLAGP  = 'P' "
		cQuery += "          AND T3.D_E_L_E_T_ = ' ' "
		cQuery += "   ) "
	else
		cQuery := ""
		cQuery += " UPDATE " + ::cTableName + " SET "
		cQuery += "        QUANT = CACHE.QUANT, "
		cQuery += "        CM    = CACHE.CM   , "
		cQuery += "        FLAGP = 'P'          "
		cQuery += "   FROM ( SELECT * FROM " + ::cTableName + " WHERE D_E_L_E_T_ = ' ' AND DATAEX = '" + DTOS(dMesPass) + "' AND FLAGP = 'P' ) CACHE  "
		cQuery += "  WHERE " + ::cTableName + ".DATAEX     = '" + DTOS(dUltDia) + "' " // mes atual
		cQuery += "    AND " + ::cTableName + ".PRODUT     = CACHE.PRODUT "
		cQuery += "    AND " + ::cTableName + ".FILIAL     = CACHE.FILIAL "
		cQuery += "    AND " + ::cTableName + ".ALMOXE     = CACHE.ALMOXE "
		cQuery += "    AND " + ::cTableName + ".D_E_L_E_T_ = ' '          "
		cQuery += "    AND " + ::cTableName + ".FLAGP      = ' '          "
	endif
	if tcSqlExec(cQuery) < 0
		MSGSTOP("Erro de sql detectado: " + TCSQLError())
		conout(TCSQLError())
	end
	//
	If ( ::AnyToProc(dUltDia) )
		// ... fazer os que faltam processar
		::ProcLote( dUltDia )
	EndIf
	//
	cFilAnt := cBckFil
Return .T.

/*/{Protheus.doc} AnyToProc

	@author       Vinicius Gati
	@since        21/07/2015
	@description  Responde a pergunta, existe algum registro sem processar na data?(isso relacionado a cache de inventario)
	@return       .T. se tem sem processar .F. se não tem nenhum

/*/
Method AnyToProc(dData) Class DMS_CacheB2
	Local cQuery := ''

	cQuery += "   SELECT COALESCE(COUNT(*), 0) as ALGUM FROM " + ::cTableName + " CACHE "
	cQuery += "    WHERE CACHE.D_E_L_E_T_ = ' ' "
	cQuery += "      AND CACHE.FLAGP      = ' ' " // não foram processados
	cQuery += "      AND CACHE.DATAEX     = '" +DTOS(dData)+ "' "
	Return FM_SQL(cQuery) > 0
Return .F.

/*/{Protheus.doc} ProcLote

	@author       Vinicius Gati
	@since        21/07/2015
	@description  Processa em lotes de N registros(roda calcest, cacheia o inventario) todos os itens faltando processar daquela determinada data
	@return       .T. se tem sem processar .F. se não tem nenhum

/*/
Method ProcLote(dData, nTamLote, bBlock) Class DMS_CacheB2
	Local lAllProd   := .F.
	Local oSqlHlp    := DMS_SqlHelper():New()
	Default nTamLote := 1000
	//
	Do While lAllProd == .F.
		cAlias := GetNextAlias()
		cQuery := "   SELECT CACHE.PRODUT as B1_COD FROM " + ::cTableName + " CACHE "
		cQuery += "    WHERE CACHE.D_E_L_E_T_ = ' '                 "
		cQuery += "      AND CACHE.FLAGP      = ' '                 " // não foram processados
		cQuery += "      AND CACHE.DATAEX     = '" +DTOS(dData)+ "' "
		cQuery := oSqlHlp:TOPFunc(cQuery, nTamLote)
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
		(cAlias)->(DbGoTop()) // necessario voltar o ponteiro
		/// verifica se ainda tem b1 pra cachear
		If EOF()
			lAllProd := .T.
		Else
			While !(cAlias)->(EOF())
				::CacheInv( (cAlias)->B1_COD, dData )
				(cAlias)->(DbSkip())

				if VALTYPE(bBlock) == "B"
					EVAL(bBlock)
				End If
			End
			(cAlias)->(dbCloseArea())
		EndIf
		conout(TIME() + " - Lote de " + STR(nTamLote) + " itens computados... ")
	End Do
Return .T.

/*/{Protheus.doc} GetInfo

	@author       Vinicius Gati
	@since        09/10/2015
	@description  Retorna informações relevantes sobre o andamento do cache do inventário de determinada data
	@param        Data para pegar informações de cache
	@return       DMS_DataContainer com os valores QTD_REGS, QTD_PROC, TOTAL, STATUS preenchidos.

/*/
Method GetInfo(dData) Class DMS_CacheB2
	Local nRegs, nProc, nValue, cStatus


	nRegs  := FM_SQL(" SELECT COALESCE(COUNT(*), 0)      FROM " + ::cTableName + " WHERE  DATAEX = '"+DTOS(dData)+"' AND D_E_L_E_T_ = ' ' ")
	nProc  := FM_SQL(" SELECT COALESCE(COUNT(*), 0)      FROM " + ::cTableName + " WHERE  DATAEX = '"+DTOS(dData)+"' AND FLAGP != ' ' AND D_E_L_E_T_ = ' ' ")
	nValue := FM_SQL(" SELECT COALESCE(SUM(CM*QUANT), 0) FROM " + ::cTableName + " WHERE  DATAEX = '"+DTOS(dData)+"' AND D_E_L_E_T_ = ' ' ")

	If nRegs == 0
		cStatus := "ERRO"
	ElseIf nRegs > nProc
		cStatus := "PARCIAL"
	Else
		cStatus := "OK"
	EndIf

Return DMS_DataContainer():New({;
	{'QTD_REGS', nRegs   },;
	{'QTD_PROC', nProc   },;
	{'TOTAL'   , nValue  },;
	{'STATUS'  , cStatus } ;
})

/*/{Protheus.doc} GetInfo

	@author       Vinicius Gati
	@since        09/10/2015
	@description  deleta todos os dados de cache do mês
	@param        dData para pegar informações de cache
	@return       DMS_DataContainer com os valores QTD_REGS, QTD_PROC, TOTAL, STATUS preenchidos.

/*/
Method Clear(dData) Class DMS_CacheB2
	TcSqlExec("DELETE FROM " + ::cTableName + " WHERE DATAEX = '"+DTOS(dData)+"' ") // devemos deletar mesmo , porque dados nessa tabela consomem muito espaço no mês
	TcSqlExec("UPDATE " + RetSqlName('VQL') + " SET R_E_C_D_E_L_ = R_E_C_N_O_, D_E_L_E_T_ = '*' WHERE VQL_AGROUP = 'OFINJD25' AND VQL_TIPO = 'MES_COMPLETO' AND VQL_DADOS = '"+DTOS(dData)+"' ")
Return

/*/{Protheus.doc} DMS_Cliente
	@author       Vinicius Gati
	@since        24/05/2017
	@description  Classe que faz contato com o banco de dados em busca dos dados de Prestadores/Eq. Tecnica VAI
/*/
Class DMS_Cliente
	Method New() CONSTRUCTOR
	Method Bloqueado()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_Cliente

	@author Vinicius Gati
	@since 24/05/2017
/*/
Method New() CLASS DMS_Cliente
Return SELF

/*/{Protheus.doc} Bloqueado
	Verifica se cliente esta bloqueado e mostra mensagem caso precise

	@author Vinicius Gati
	@since 24/05/2017
	@version undefined
	@param cA1_COD, characters, Codigo do cliente
	@param cA1_LOJA, characters, Loja do cliente
	@param lShowHlp, logical, Se deve ou nao mostrar mensagem de erro
	@return lBloq, logical, Se cliente esta ou nao bloqueado
	@type function
/*/
Method Bloqueado(cA1_COD, cA1_LOJA, lShowHlp) Class DMS_Cliente
	Local cMsg       := ""
	Local lBloq      := .F.
	Local aArea      := GetArea()
	Local aAreaA1    := SA1->(GetArea())
	Default lShowHlp := .T.

	dbSelectarea('SA1')
	dbSetOrder(1)
	msSeek(xFilial('SA1') + cA1_COD + cA1_LOJA)

	if SA1->( Found() ) .AND. SA1->A1_MSBLQL == '1'
		lBloq := .T.
	end

	if lBloq .AND. lShowHlp
		cMsg := chr(13) + chr(10) + "SA1" + chr(13) + chr(10)
		cMsg += RetTitle("A1_COD")  + ":" + SA1->A1_COD  + chr(13) + chr(10)
		cMsg += RetTitle("A1_LOJA") + ":" + SA1->A1_LOJA + chr(13) + chr(10)

		HELP(" ",1,"REGBLOQ",,cMsg,3,1)
	end

	RestArea( aAreaA1 )
	RestArea( aArea   )
Return lBloq
