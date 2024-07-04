/////////////////////
// º Versao º 43   //
/////////////////////

#Include "protheus.ch"
#Include "OFIOC150.ch"

/*/{Protheus.doc} OFIOC150
	@author       Fabio
	@since        03/05/2000
	@description  Função principal que chama MBROWSE com Peças(Tabela SB1)
/*/
Function OFIOC150(cGrupo, cCodIte)
	Local   cFiltro   := ""
	Local   cGruVei   := PadR(ALLTRIM(GetNewPar("MV_GRUVEI","VEIC")), TamSx3("B1_GRUPO")[1], " ") // Grupo do Veículo
	Local   cGruSrv   := PadR(ALLTRIM(GetNewPar("MV_GRUSRV","SRVC")), TamSx3("B1_GRUPO")[1], " ") // Grupo do Serviço
	Private aRotina   := MenuDef()
	Private cCadastro := (STR0001)

	Default cGrupo    := ''
	Default cCodIte   := ''

	If !Empty(cGrupo) .And. !Empty(cCodIte)
		DbSelectArea("SB1")
		DbSetOrder(7)

		DbSeek(xFilial("SB1") + cGrupo + cCodIte)

		Processa( {|| FS_OC150() } )
	Else
		cFiltro := "B1_GRUPO <> '" + cGruVei + "' AND B1_GRUPO <> '" + cGruSrv + "'"

		mBrowse(06, 01, 22, 75, "SB1",,,,,,,,,,,,,, cFiltro)
	EndIf
Return

/*/{Protheus.doc} FS_OC150
	@author       Fabio
	@since        22/03/2002
	@description  Visualizar da tela de movimentos de peça
/*/
Function FS_OC150()
	//variaveis controle de janela
	Local aObjects       := {}, aPosObj := {}, aPosObjApon := {}, aInfo := {}
	Local aSizeAut       := MsAdvSize(.F.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local cFiltroBtw     := '' //Filtro do between entre datas
	Local i              := 0 //used on for's
	Local nCntFor        := 0
	Local aPecas         := {}, aArmazem := {}, nCountS := 0, xCol := {}
	Local cB9Data        := ""
	Local dB9Data        := nil
	Local cArm      := ""
	Local cArmz     := ""
	Local cArmazens := ""
	Local lInicio   := .t.
	Local cSQLNNR   := "SQLNNR"
	Local cArm1     := ""
	Local cOrdOrc   := ""
	Local nHorMov   := 0
	Local cArmCab   := MV_PAR01

	Private lMostraSaldo := .F.
	Private oSqlHelper   := DMS_SqlHelper():New()

	cB1_GRUPO  := SB1->B1_GRUPO
	cB1_COD    := SB1->B1_COD
	cB1_CODITE := SB1->B1_CODITE
	cB1_DESC   := SB1->B1_DESC

	// Pega o armazem e se mostra o saldo da peça
	// MV_PAR01 = Armazem
	// MV_PAR02 = Se mostra saldo 1(Sim) ou 2(Não)
	cPerg = "OFC150Prg"
	ValidPerg(cPerg)    // Na realidade diferente do nome, esse comando cria uma pergunta no sx1
	If !Pergunte(cPerg) // Faz a pergunta
		Return
	EndIf

	cArmz := IIF(! Empty(MV_PAR01), MV_PAR01, FM_PRODSBZ(SB1->B1_COD, "SB1->B1_LOCPAD"))

/*	A ALTERACAO ABAIXO EH UMA DAS ALTERACOES DO CI 002792, QUE ENTENDO TER FICADO ERRADO, POR ISSO ESTE SENDO RETIRADA, MANTENDO-SE A OUTRA, ENTRE A LINHA 341 E 352
	// Pega a data do saldo inicial do protheus e troca caso a passada no parametro seja menor
	//  com isso, removemos da tela os dados que foram importados para o protheus e não podem aparecer na tela (maqnelson)
	cB9Data := FM_SQL(;
		"SELECT MAX(B9_DATA) " +;
		"  FROM " + RetSQLName("SB9") + " SB9 " + ;
		" WHERE B9_FILIAL = '" + xFilial('SB9') + "' AND SB9.B9_COD = '" + SB1->B1_COD + "' " +;
		"   AND B9_LOCAL = '" + cArmz + "' ")
	dB9Data := STOD(cB9Data)
	if ! Empty(dB9Data)
		If ! Empty(MV_PAR03) .AND. MV_PAR03 < dB9Data  
			MV_PAR03  := dB9Data
		EndIf
	Endif
*/

	If !Empty(DTOS(MV_PAR03)) .AND. !Empty(DTOS(MV_PAR04))
		cFiltroBtw := " BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	ElseIf !Empty(DTOS(MV_PAR03))
		cFiltroBtw := " > '" + DTOS(MV_PAR03-1) + "' "
	EndIf

	lMostraSaldo := (MV_PAR02 == 1) // SIM

	// Entradas Válidas
	cSQLSD1 := "SqlSD1"
	cQuery  := ""
	cQuery  += "SELECT SD1.D1_DTDIGIT, SD1.D1_QUANT,  SD1.D1_TOTAL, SD1.D1_SERIE, SF1.F1_DOC, "
	cQuery  += "       SD1.D1_LOCAL,   SD1.D1_TES,    SD1.D1_CF,    SD1.D1_CUSTO, SF1.F1_SERIE, "
	cQuery  += "       SF1.F1_FORNECE, SF1.F1_STATUS, SF1.F1_HORA,  SF1.F1_LOJA,  SF4.F4_ESTOQUE, "
	cQuery  += "       (CASE WHEN SD1.D1_QUANT > 0 THEN (SD1.D1_CUSTO / SD1.D1_QUANT) ELSE 0 END) AS CUSTO_UNDD, "
	cQuery  += "       SF1.F1_FILIAL,  SF1.F1_TIPO, SD1.D1_NUMSEQ, "
	
	cQuery  += "(CASE WHEN SD1.D1_NFORI <> ' ' THEN 'Edv' ELSE 'Ent' END)  AS tm "
	
	cQuery  += "FROM       " + RetSQLName("SD1") + " SD1 "
	cQuery  += "LEFT JOIN  " + RetSQLName("SF4") + " SF4 ON SF4.F4_CODIGO = SD1.D1_TES "
	cQuery  += "  AND SF4.F4_FILIAL = '" + xFilial("SF4")  + "' AND  SF4.D_E_L_E_T_ = ' ', "
	cQuery  += "           " + RetSQLName("SF1") + " SF1 "
	cQuery  += "WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND SD1.D1_COD  = '" + cB1_COD + "' "
	cQuery  += "  AND SD1.D1_FORNECE = SF1.F1_FORNECE           AND SF1.F1_LOJA = SD1.D1_LOJA "
	cQuery  += "  AND SD1.D1_SERIE   = SF1.F1_SERIE             AND SF1.F1_DOC  = SD1.D1_DOC "
	cQuery  += "  AND SF1.F1_FILIAL  = '" + xFilial("SF1") + "' "
	cQuery  += "  AND SF1.D_E_L_E_T_ = ' ' "
	cQuery  += "  AND SD1.D_E_L_E_T_ = ' ' "
	

	If !Empty(MV_PAR01)
		cQuery += "  AND SD1.D1_LOCAL = '" + MV_PAR01 + "' "
	EndIf

	If !Empty(cFiltroBtw)
		cQuery += "  AND SD1.D1_DTDIGIT " + cFiltroBtw
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cSQLSD1, .F., .T. )

	// Posiciona o cursor no início da área de trabalho ativa
	(cSQLSD1)->(DbGoTop())

	// Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
	While !EOF()

		nValComFrete := (cSQLSD1)->D1_TOTAL

		Aadd(aPecas, {                  ;
			"0"                        ,; //01
			STOD((cSQLSD1)->D1_DTDIGIT),; //02
			(cSQLSD1)->F1_HORA         ,; //03
			(cSQLSD1)->tm              ,; //04
			(cSQLSD1)->F1_DOC          ,; //05
			(cSQLSD1)->D1_QUANT        ,; //06
			0                          ,; //07
			nValComFrete               ,; //08
			Space(12)                  ,; //09
			Space(1)                   ,; //10
			(cSQLSD1)->CUSTO_UNDD      ,; //11
			(cSQLSD1)->D1_CUSTO        ,; //12
			(cSQLSD1)->D1_LOCAL        ,; //13
			Space(1)                   ,; //14
			(cSQLSD1)->D1_TES          ,; //15
			(cSQLSD1)->D1_CF           ,; //16
			Space(1)                   ,; //17
			(cSQLSD1)->D1_CUSTO        ,; //18
			Space(1)                   ,; //19
			""                         ,; //20
			"  -  "                    ,; //21
			(cSQLSD1)->F4_ESTOQUE      ,; //22
			(cSQLSD1)->F1_STATUS       ,; //23
			(cSQLSD1)->F1_DOC          ,; //24
			(cSQLSD1)->F1_SERIE        ,; //25
			(cSQLSD1)->F1_FORNECE      ,; //26
			(cSQLSD1)->F1_LOJA         ,; //27
			(cSQLSD1)->F1_FILIAL       ,; //28
			(cSQLSD1)->F1_TIPO         ,; //29
			(cSQLSD1)->D1_NUMSEQ+repl("X",15) ,; //30
			"SD1"                       ; //31
		})

		DbSkip()
	EndDo

	(cSQLSD1)->(dbCloseArea())
	// Fim Entradas Validas


	// Entradas Canceladas
	cSQLSD1 := "SqlSD1"
	cQuery  := ""
	cQuery  += "SELECT SD1.D1_DTDIGIT, SD1.D1_QUANT,  SD1.D1_TOTAL, SD1.D1_SERIE, SF1.F1_DOC, "
    cQuery  += "       SD1.D1_LOCAL,   SD1.D1_TES,    SD1.D1_CF,    SD1.D1_CUSTO, SF1.F1_SERIE, "
    cQuery  += "       SF1.F1_FORNECE, SF1.F1_STATUS, SF1.F1_HORA,  SF1.F1_LOJA,  SF4.F4_ESTOQUE, "
    cQuery  += "       (CASE WHEN SD1.D1_QUANT > 0 THEN (SD1.D1_CUSTO / SD1.D1_QUANT) ELSE 0 END) AS CUSTO_UNDD, "
    cQuery  += "       SF1.F1_FILIAL,  SF1.F1_TIPO, SD1.D1_NUMSEQ, "
    cQuery  += "       'Ecn' AS tm "
    cQuery  += "FROM       " + RetSQLName("SD1") + " SD1 "
    cQuery  += "LEFT JOIN  " + RetSQLName("SF4") + " SF4 ON SF4.F4_CODIGO = SD1.D1_TES "
    cQuery  += "  AND SF4.F4_FILIAL = '" + xFilial("SF4")  + "' AND  SF4.D_E_L_E_T_ = ' ', "
    cQuery  += "           " + RetSQLName("SF1") + " SF1 "
    cQuery  += "WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND SD1.D1_COD  = '" + cB1_COD + "' "
    cQuery  += "  AND SD1.D1_FORNECE = SF1.F1_FORNECE           AND SF1.F1_LOJA = SD1.D1_LOJA "
    cQuery  += "  AND SD1.D1_SERIE   = SF1.F1_SERIE             AND SF1.F1_DOC  = SD1.D1_DOC "
    cQuery  += "  AND SD1.D1_DTDIGIT = SF1.F1_DTDIGIT           AND SF1.F1_EMISSAO  = SD1.D1_EMISSAO "
    cQuery  += "  AND SF1.F1_FILIAL  = '" + xFilial("SF1") + "' "
    cQuery  += "  AND SD1.D_E_L_E_T_ = '*' "
    cQuery  += "  AND SF1.D_E_L_E_T_ = '*' "
	If !Empty(MV_PAR01)
		cQuery += "  AND SD1.D1_LOCAL = '" + MV_PAR01 + "' "
	EndIf

	If !Empty(cFiltroBtw)
		cQuery += "  AND SD1.D1_DTDIGIT " + cFiltroBtw
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cSQLSD1, .F., .T. )

	// Posiciona o cursor no início da área de trabalho ativa
	(cSQLSD1)->(DbGoTop())

	// Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
	While !EOF()

		Aadd(aPecas, {                  ;
			"0"                        ,; //01
			STOD((cSQLSD1)->D1_DTDIGIT),; //02
			(cSQLSD1)->F1_HORA         ,; //03
			(cSQLSD1)->tm              ,; //04
			(cSQLSD1)->F1_DOC          ,; //05
			(cSQLSD1)->D1_QUANT        ,; //06
			0                          ,; //07
			0			               ,; //08
			Space(12)                  ,; //09
			Space(1)                   ,; //10
			(cSQLSD1)->CUSTO_UNDD      ,; //11
			(cSQLSD1)->D1_CUSTO        ,; //12
			(cSQLSD1)->D1_LOCAL        ,; //13
			Space(1)                   ,; //14
			(cSQLSD1)->D1_TES          ,; //15
			(cSQLSD1)->D1_CF           ,; //16
			Space(1)                   ,; //17
			(cSQLSD1)->D1_CUSTO        ,; //18
			Space(1)                   ,; //19
			""                         ,; //20
			"  -  "                    ,; //21
			(cSQLSD1)->F4_ESTOQUE      ,; //22
			(cSQLSD1)->F1_STATUS       ,; //23
			(cSQLSD1)->F1_DOC          ,; //24
			(cSQLSD1)->F1_SERIE        ,; //25
			(cSQLSD1)->F1_FORNECE      ,; //26
			(cSQLSD1)->F1_LOJA         ,; //27
			(cSQLSD1)->F1_FILIAL       ,; //28
			(cSQLSD1)->F1_TIPO         ,; //29
			(cSQLSD1)->D1_NUMSEQ+repl("X",15) ,; //30
			"SD1"                       ; //31
		})

		DbSkip()

	EndDo

	(cSQLSD1)->(dbCloseArea())
	// Fim Entradas Canceladas

	// Requisições
	cQueryVen := "SELECT A3_NOME "
	cQueryVen += "FROM " + RetSQLName("VS1") + " VS1 "
	cQueryVen += "JOIN " + RetSQLName("SA3") + " SA3 ON SA3.A3_FILIAL = '" + xFilial('SA3') + "' "
	cQueryVen += "  AND SA3.A3_COD     = VS1_CODVEN "
	cQueryVen += "WHERE VS1_FILIAL     = '" + xFilial('VS1') + "' AND VS1.VS1_NUMOSV = 'XXXXXX' "
	cQueryVen += "  AND VS1.D_E_L_E_T_ = ' ' "
	cQueryVen += "ORDER BY VS1_NUMORC DESC "
	cQueryVen := oSQLHelper:TOPFunc(cQueryVen, 1)

	cSQLVO3 := "SqlVO3"
	cQuery  := ""
	cQuery  += "SELECT DISTINCT VO2.VO2_DATREQ, VO2.VO2_HORREQ, VO2.VO2_NUMOSV, "
	cQuery  += "       VO3.VO3_QTDREQ, VO3.VO3_TIPTEM, VO3.VO3_NOSNUM, VO3.VO3_NUMDOC, "
	cQuery  += "       VO3.VO3_QTDREQ * VO3.VO3_VALPEC AS TOTAL, "
	cQuery  += "       VOI.VOI_CODALM, VOI.VOI_LOCALI, "
	cQuery  += "       SD3.D3_NUMSEQ, "
	cQuery  += "       (SELECT count(*) FROM " + RetSQLName("VEC") + " VEC "
	cQuery  += "       WHERE VEC_FILIAL     = '" + xFilial('VEC') + "' AND VEC_CODITE     = '" + SB1->B1_CODITE + "' "
	cQuery  += "         AND VEC.VEC_GRUITE = '" + cB1_GRUPO      + "' AND VEC.VEC_NUMNFI = VO3.VO3_NUMNFI "
	cQuery  += "         AND VEC.VEC_SERNFI = VO3.VO3_SERNFI           AND VO3.VO3_NUMNFI <> ' ') AS tem_nota, "
	cQuery  += "        (CASE WHEN VO2.VO2_DEVOLU = '0' THEN 'Dev' ELSE 'Req' end) AS TM "
	cQuery  += "FROM " + RetSQLName("VO3") + " VO3 " 
	cQuery  += "JOIN " + RetSQLName("VO2") + " VO2 ON ( VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2.VO2_NOSNUM = VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_ = ' ' ) "
	cQuery  += "JOIN " + RetSQLName("VOI") + " VOI ON ( VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_ = ' ' ) "
	cQuery  += "JOIN " + RetSQLName("SD3") + " SD3 ON ( SD3.D3_FILIAL  = '" + xFilial("SD3") + "' AND SD3.D3_DOC     = VO3.VO3_NUMDOC AND SD3.D3_COD = '"+cB1_COD+"' AND SD3.D_E_L_E_T_ = ' ' ) "
	cQuery  += "WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "' "
	cQuery  += "  AND VO3.VO3_GRUITE = '" + cB1_GRUPO      + "' "
	cQuery  += "  AND VO3.VO3_CODITE = '" + cB1_CODITE     + "' "
	cQuery  += "  AND VO3.D_E_L_E_T_ = ' ' "
	If !Empty(MV_PAR01)
		cQuery += "  AND VOI.VOI_CODALM = '" + MV_PAR01 + "' "
	Endif
	If !Empty(cFiltroBtw)
		cQuery += "  AND VO2.VO2_DATREQ " + cFiltroBtw
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO3, .F., .T. )

	// Posiciona o cursor no início da área de trabalho ativa
	(cSQLVO3)->(DbGoTop())

	// Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
	While !EOF()
		cFDate := Transform(STOD((cSQLVO3)->VO2_DATREQ), '@D') + ' - ' + (cSQLVO3)->VO3_NOSNUM
		cOsv   := Space(12)

		If !Empty((cSQLVO3)->VO2_NUMOSV)
			cOSv := "OSv " + (cSQLVO3)->VO2_NUMOSV

			cQuery  := STrTran(cQueryVen, "XXXXXX", (cSQLVO3)->VO2_NUMOSV)
			cVended := FM_SQL(cQuery)
		EndIf

		Aadd(aPecas, {                                    ;
			"1"                                          ,; // 01
			STOD((cSQLVO3)->VO2_DATREQ)                  ,; // 02
			Transform((cSQLVO3)->VO2_HORREQ, '@R 999:99'),; // 03
			(cSQLVO3)->TM                                ,; // 04
			(cSQLVO3)->VO3_NUMDOC                        ,; // 05
			(cSQLVO3)->VO3_QTDREQ                        ,; // 06
			Space(0)                                     ,; // 07
			(cSQLVO3)->TOTAL                             ,; // 08
			cOSv                                         ,; // 09
			(cSQLVO3)->VO3_TIPTEM                        ,; // 10
			Space(0)                                     ,; // 11
			Space(0)                                     ,; // 12
			(cSQLVO3)->VOI_CODALM                        ,; // 13
			(cSQLVO3)->VOI_LOCALI                        ,; // 14
			Space(0)                                     ,; // 15
			Space(0)                                     ,; // 16
			cVended                                      ,; // 17
			Space(0)                                     ,; // 18
			(cSQLVO3)->VO2_NUMOSV                        ,; // 19
			""                                           ,; // 20
			cFDate                                       ,; // 21
			'N'                                          ,; // 22
			'  -  '                                      ,; // 23
			''                                           ,; // 24
			''                                           ,; // 25
			''                                           ,; // 26
			''                                           ,; // 27
			''                                           ,; // 28
			''                                           ,; // 29
			(cSQLVO3)->D3_NUMSEQ+repl("X",15)            ,; // 30
			"VO3"                                         ; // 31
		})

		DbSkip()
	EndDo

	(cSQLVO3)->(dbCloseArea())
	// Fim Requisições

	// Movimentações
	cSQLSD3 := "SqlSD3"
	cQuery  := ""
	cQuery  += "SELECT SD3.D3_EMISSAO , SD3.D3_CF    , "
	cQuery  += "       SD3.D3_DOC     , SD3.D3_QUANT , "
	cQuery  += "       SD3.D3_CUSTO1  , SD3.D3_LOCAL , "
	cQuery  += "       SD3.D3_LOCALIZ , SD3.D3_TM    ,"
	cQuery  += "       SD3.D3_NUMSEQ  , SD3.R_E_C_N_O_ AS RECSD3 , "

	If AliasInDic("VR7")
		cQuery += "   VR7.VR7_REFORI, VR7.VR7_TIPREF, COALESCE(VR7.VR7_HORMOV,0) HorMov, "
		cQuery += "   SA3.A3_NOME, "
	EndIf

	cQuery  += "       (SELECT count(*) FROM " + RetSQLName("VO3") + " VO3 "
	cQuery  += "       WHERE VO3.VO3_NUMDOC = SD3.D3_DOC "
	cQuery  += "         AND VO3.VO3_CODITE = '" + SB1->B1_CODITE + "' AND VO3.VO3_GRUITE = '" + cB1_GRUPO + "' "
	cQuery  += "         AND VO3.D_E_L_E_T_ = ' ' "
	cQuery  += "         AND VO3.VO3_FILIAL = '" + xFilial("VO3") + "') as nro_vo3s "
	cQuery  += "FROM " + RetSQLName("SD3") + " SD3 "

	If AliasInDic("VR7")
		cQuery += "LEFT JOIN " + RetSQLName("VR7") + " VR7 ON VR7.VR7_FILIAL = SD3.D3_FILIAL "
		cQuery += "  AND VR7.VR7_CODSB1 = SD3.D3_COD AND VR7.VR7_DOCSD3 = SD3.D3_DOC "
		cQuery += "  AND VR7.VR7_SEQUEN = SD3.D3_NUMSEQ  AND VR7.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " + RetSQLName("VS1") + " VS1 ON VS1.VS1_FILIAL = SD3.D3_FILIAL "
		cQuery += "  AND VS1.VS1_NUMORC = VR7.VR7_REFORI AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " + RetSQLName("SA3") + " SA3 ON SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
		cQuery += "  AND SA3.A3_COD = VS1.VS1_CODVEN     AND SA3.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery  += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D3_COD = '" + cB1_COD + "' "

	If !Empty(MV_PAR01)
		cQuery += "  AND SD3.D3_LOCAL = '" + MV_PAR01 + "' "
	EndIf

	cQuery  += "  AND SD3.D_E_L_E_T_ = ' ' "
	cQuery  += "  AND SD3.D3_QUANT > 0 "

	If !Empty(cFiltroBtw)
		cQuery += "  AND SD3.D3_EMISSAO " + cFiltroBtw
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery ), cSQLSD3, .F., .T. )

	(cSQLSD3)->(DbGoTop())

	Do While !EOF()
		nValTotal := (cSQLSD3)->D3_CUSTO1 / (cSQLSD3)->D3_QUANT

		cFDoc     := (cSQLSD3)->D3_DOC + (cSQLSD3)->D3_CF

		cVended := Space(20)
		nHorMov := 0

		If AliasInDic("VR7")
			If (cSQLSD3)->VR7_TIPREF == "1"
				cOrdOrc := "Orc "+ (cSQLSD3)->VR7_REFORI

				cVended := Left((cSQLSD3)->A3_NOME, 20)
			Else
				cOrdOrc := "OSv "+ (cSQLSD3)->VR7_REFORI
			EndIf

			nHorMov := (cSQLSD3)->HorMov
		EndIf

		If Len(alltrim(cOrdOrc)) == 3
			cOrdOrc := Space(12)
		EndIf

		Aadd(aPecas, {                      ;
			"1"                            ,; // 01
			STOD((cSQLSD3)->D3_EMISSAO)    ,; // 02
			Transform(nHorMov, '@R 999:99'),; // 03
			(cSQLSD3)->D3_CF               ,; // 04
			(cSQLSD3)->D3_DOC              ,; // 05
			(cSQLSD3)->D3_QUANT            ,; // 06
			0                              ,; // 07
			0                              ,; // 08
			cOrdOrc                        ,; // 09
			Space(04)                      ,; // 10
			nValTotal                      ,; // 11
			(cSQLSD3)->D3_CUSTO1           ,; // 12
			(cSQLSD3)->D3_LOCAL            ,; // 13
			(cSQLSD3)->D3_LOCALIZ          ,; // 14
			Space(03)                      ,; // 15
			Space(05)                      ,; // 16
			cVended                        ,; // 17
			(cSQLSD3)->D3_CUSTO1           ,; // 18
			cFDoc                          ,; // 19
			(cSQLSD3)->D3_TM               ,; // 20
			"  -  "                        ,; // 21
			'  -  '                        ,; // 22
			'  -  '                        ,; // 23
			''                             ,; // 24
			''                             ,; // 25
			''                             ,; // 26
			''                             ,; // 27
			''                             ,; // 28
			''                             ,; // 29
			(cSQLSD3)->D3_NUMSEQ+strzero((cSQLSD3)->RECSD3,15) ,; // 30
			"SD3"                           ; // 31
		})
			
		If Upper(Substr((cSQLSD3)->D3_CF, 1, 2)) == "DE"
			aPecas[Len(aPecas), 4] := "AC+"
		ElseIf Upper(Substr((cSQLSD3)->D3_CF, 1, 2)) == "RE"
			aPecas[Len(aPecas), 4] := "AC-"
		EndIf
			
		If Upper(left((cSQLSD3)->D3_DOC, 6)) == "INVENT"
			If Upper(Substr((cSQLSD3)->D3_CF, 1, 2)) == "DE"
				aPecas[Len(aPecas), 4] := "AJ+"
			ElseIf Upper(Substr((cSQLSD3)->D3_CF, 1, 2)) == "RE"
				aPecas[Len(aPecas), 4] := "AJ-"
			EndIf
		EndIf

		DbSkip()
	EndDo

	(cSQLSD3)->(dbCloseArea())
	// Fim Movimentações

	// Saídas
	cSQLSD2 := "SqlSD2"
	cQuery  := ""
	cQuery  += "SELECT DISTINCT SD2.R_E_C_N_O_, "
	cQuery  += "       VEC.VEC_BALOFI, VEC.VEC_NUMOSV, VEC.VEC_TIPTEM, SD2.D2_DOC, SF2.F2_HORA, "
	cQuery  += "       D2_SERIE,       SF4.F4_ESTOQUE, "
	cQuery  += "       SD2.D2_CUSTO1,  SD2.D2_LOCAL,   SD2.D2_LOCALIZ, SD2.D2_TES, SD2.D2_CF, "
	cQuery  += "       SD2.D2_NUMSEQ,  SD2.D2_EMISSAO, VEC.VEC_NUMORC, "
	cQuery  += "       SA3.A3_NOME, "
	cQuery  += "       SD2.D2_QUANT,   SD2.D2_TOTAL,   (CASE WHEN SD2.D_E_L_E_T_ = '*' THEN 'Can' ELSE 'Sai' END) AS tm, "
	cQuery  += "       VS1.VS1_TIPORC "
	cQuery  += "FROM " + RetSQLName("SD2") + " SD2 "
	cQuery  += "LEFT JOIN " + RetSQLName("VEC") + " VEC ON VEC.VEC_NUMNFI = SD2.D2_DOC "
	cQuery  += "  AND VEC.VEC_SERNFI = SD2.D2_SERIE AND VEC.VEC_ITENFI = SD2.D2_ITEM "
	cQuery  += "  AND VEC.VEC_FILIAL = '" + xFilial('VEC') + "' "
	cQuery  += "  AND VEC.D_E_L_E_T_ = ' '          AND VEC.VEC_CODITE = '"   + SB1->B1_CODITE + "' "
	cQuery  += "JOIN " + RetSQLName("SF2") + " SF2 ON SF2.F2_DOC = SD2.D2_DOC 
	cQuery  += "  AND SF2.F2_SERIE   = SD2.D2_SERIE AND SF2.F2_FILIAL = '"    + xFilial('SF2') + "' "
	cQuery  += "LEFT JOIN " + RetSQLName("SF4") + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO "
	cQuery  += "  AND SF4.D_E_L_E_T_ = ' '          AND SF4.F4_FILIAL = '"    + xFilial('SF4') + "' "
	cQuery  += "LEFT JOIN " + RetSQLName("VS1") + " VS1 ON VS1.VS1_NUMNFI = SD2.D2_DOC "
	cQuery  += "  AND VS1.D_E_L_E_T_ = ' '          AND VS1.VS1_FILIAL = '"   + xFilial('VS1') + "' "
	cQuery  += "  AND VS1.VS1_SERNFI = SD2.D2_SERIE "
	cQuery  += "LEFT JOIN " + RetSQLName("SA3") + " SA3 ON SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
	cQuery  += "  AND SA3.A3_COD = SF2.F2_VEND1     AND SA3.D_E_L_E_T_ = ' ' "
	cQuery  += "WHERE SD2.D2_COD = '" + SB1->B1_COD + "' "
	cQuery  += "  AND SD2.D2_FILIAL  = '"   +xFilial("SD2")+ "' "
	cQuery  += "  AND SD2.D2_QUANT > 0              AND SD2.D2_TIPO NOT IN ('C', 'I', 'P') "
	
	If !Empty(MV_PAR01)
		cQuery += "  AND SD2.D2_LOCAL  = '" + MV_PAR01 + "' "
	EndIf

	If !Empty(cFiltroBtw)
		cQuery += "  AND SD2.D2_EMISSAO " + cFiltroBtw
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cSQLSD2, .F., .T. )

	(cSQLSD2)->(DbGoTop())

	Do While !EOF()
		nValTotal := (cSQLSD2)->D2_CUSTO1 / (cSQLSD2)->D2_QUANT

		cFDoc     := (cSQLSD2)->D2_DOC + (cSQLSD2)->D2_CF

		cOrdOrc   := Space(12)
		cVended   := Space(20)

		If !Empty((cSQLSD2)->VEC_NUMOSV)
			cOrdOrc := "OSv " + (cSQLSD2)->VEC_NUMOSV
		EndIf

		If Empty(cOrdOrc) .and. !Empty((cSQLSD2)->VEC_NUMORC)
			cOrdOrc := "Orc " + (cSQLSD2)->VEC_NUMORC

			cVended := Left((cSQLSD2)->A3_NOME, 20)
		EndIf

		cTm := (cSQLSD2)->tm
		/** An alert on this 'Sai' validation, this is needed to avoid overwriting canceled invoices with 'Tra' */
		if (cSQLSD2)->VS1_TIPORC == "3" .and. cTm == 'Sai'
			cTm := 'Tra'
		endif

		Aadd(aPecas, {                                              ;
			"2"                                                    ,; // 01
			STOD((cSQLSD2)->D2_EMISSAO)                            ,; // 02
			(cSQLSD2)->F2_HORA                                     ,; // 03
			cTm                                                    ,; // 04
			(cSQLSD2)->D2_DOC                                      ,; // 05
			(cSQLSD2)->D2_QUANT                                    ,; // 06
			0                                                      ,; // 07
			(cSQLSD2)->D2_TOTAL                                    ,; // 08
			cOrdOrc                                                ,; // 09
			(cSQLSD2)->VEC_TIPTEM                                  ,; // 10
			nValTotal                                              ,; // 11
			(cSQLSD2)->D2_CUSTO1                                   ,; // 12
			(cSQLSD2)->D2_LOCAL                                    ,; // 13
			(cSQLSD2)->D2_LOCALIZ                                  ,; // 14
			(cSQLSD2)->D2_TES                                      ,; // 15
			(cSQLSD2)->D2_CF                                       ,; // 16
			cVended                                                ,; // 17
			(cSQLSD2)->D2_CUSTO1                                   ,; // 18
			cFDoc                                                  ,; // 19
			""                                                     ,; // 20
			STOD((cSQLSD2)->D2_EMISSAO)                            ,; // 21
			(cSQLSD2)->F4_ESTOQUE                                  ,; // 22
			'  -  '                                                ,; // 23
			(cSQLSD2)->D2_SERIE                                    ,; // 24
			(cSQLSD2)->D2_DOC                                      ,; // 25
			''                                                     ,; // 26
			''                                                     ,; // 27
			''                                                     ,; // 28
			''                                                     ,; // 29
			(cSQLSD2)->D2_NUMSEQ+repl("X",15)                      ,; // 30
			"SD2"                                                   ; // 31
		})

		// Único array que é maior pois contém série e doc do d2 para mostrar tela de detalhes da nota
		// != 'Can' é para o caso tenha sido deletado vai ficar como Can mesmo de cancelado
		If (cSQLSD2)->VEC_BALOFI == "B" .AND. (cSQLSD2)->tm != 'Can'
			aPecas[Len(aPecas), 4] := "NFB"
		ElseIf (cSQLSD2)->VEC_BALOFI == "O" .AND. (cSQLSD2)->tm != 'Can'
			aPecas[Len(aPecas), 4] := "NFO"
		EndIf

		DbSkip()
	EndDo

	(cSQLSD2)->(dbCloseArea())
	// Fim Saídas

	// Armazéns
	cArm      := mv_par05
	cArmazens := "("

	For i := 1 to Len(mv_par05)
		nPos := at("/", cArm)

		cArm1 := substr(cArm, 1, nPos - 1)
		cArm  := substr(cArm, nPos + 1, Len(cArm))
		If !Empty(substr(cArm1,1,2))
			If !lInicio
				cArmazens += ","
			EndIf

			cArmazens += "'" + cArm1 + "'"
		Else
			Exit
		EndIf

		If lInicio
			lInicio := .f.
		EndIf
	Next

	cArmazens += ")"

	cQuery  := "SELECT NNR.NNR_CODIGO, NNR.NNR_DESCRI "
	cQuery  += "FROM " + RetSQLName('NNR') + " NNR "
	cQuery  += "WHERE NNR.NNR_FILIAL = '" + xFilial("NNR") + "' "

	If !lInicio
		cQuery += "  AND NNR.NNR_CODIGO NOT IN " + cArmazens
	EndIf

	cQuery  += "  AND NNR.D_E_L_E_T_ = ' ' "
	cQuery  += "ORDER BY NNR.NNR_CODIGO "

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cSQLNNR, .F., .T. )
	
	(cSQLNNR)->(DbGoTop())

	Do While !EOF()
		If Len(aArmazem) == 0 .Or. !Empty(aArmazem[Len(aArmazem), 4])
			Aadd(aArmazem, { ;
				Space(2)    ,; // 01
				Space(15)   ,; // 02
				0           ,; // 03
				Space(2)    ,; // 04
				Space(15)   ,; // 05
				0           ,; // 06
				0           ,; // 07
				0           ,; // 08
				0           ,; // 09
				0            ; // 10
			})
		EndIf
		
		DbSelectArea("SB2")
		DbSetOrder(1)

		DbSeek(xFilial("SB2") + cB1_COD + (cSQLNNR)->NNR_CODIGO)

		If Empty(aArmazem[Len(aArmazem), 1])
			aArmazem[Len(aArmazem), 1]  := (cSQLNNR)->NNR_CODIGO
			aArmazem[Len(aArmazem), 2]  := (cSQLNNR)->NNR_DESCRI
			aArmazem[Len(aArmazem), 3]  := SaldoSB2() // CalcEst(nB1_COD, (cSQLNNR)->NNR_CODIGO, dDataBase+1)[1]
			aArmazem[Len(aArmazem), 7]  := SB2->B2_QEMP + SB2->B2_QEMPSA
			aArmazem[Len(aArmazem), 9]  := SB2->B2_QACLASS
		Else
			aArmazem[Len(aArmazem), 4]  := (cSQLNNR)->NNR_CODIGO
			aArmazem[Len(aArmazem), 5]  := (cSQLNNR)->NNR_DESCRI
			aArmazem[Len(aArmazem), 6]  := SaldoSB2() // CalcEst(nB1_COD, (cSQLNNR)->NNR_CODIGO, dDataBase+1)[1]
			aArmazem[Len(aArmazem), 8]  := SB2->B2_QEMP + SB2->B2_QEMPSA
			aArmazem[Len(aArmazem), 10] := SB2->B2_QACLASS
		EndIf

		DbSelectArea(cSQLNNR)

		(cSQLNNR)->(DbSkip())
	EndDo

	(cSQLNNR)->(dbCloseArea())
	// Fim Armazéns
	DbSelectAre("SB2")
	If !Empty(DTOS(MV_PAR03))
		// Se tem a data vamos pegar o saldo por calcest
		cSaldoIni := CalcEst(cB1_COD, cArmz, MV_PAR03)[1]

		Aadd(aPecas, {         ;
			Space(1)          ,; // 01
			MV_PAR03          ,; // 02
			Space(5)          ,; // 03
			Space(3)          ,; // 04
			STR0004           ,; // 05
			0                 ,; // 06
			cSaldoIni         ,; // 07
			0                 ,; // 08
			Space(12)         ,; // 09
			Space(4)          ,; // 10
			0                 ,; // 11
			0                 ,; // 12
			cArmz             ,; // 13
			Space(15)         ,; // 14
			Space(3)          ,; // 15
			Space(5)          ,; // 16
			""                ,; // 17
			0                 ,; // 18
			Space(09)         ,; // 19
			Space(03)         ,; // 20
			"  -  " + space(9),; // 21
			'  -  '           ,; // 22
			'  -  '           ,; // 23
			''                ,; // 24
			''                ,; // 25
			''                ,; // 26
			''                ,; // 27
			''                ,; // 28
			''                ,; // 29
			Space(6)          ,; // 30
			""                 ; // 31
		})
	Else
		// Senão teremos que buscar no B9
		If SB9->(DbSeek(xFilial("SB9") + SB1->B1_COD + cArmz))
			Aadd(aPecas, {         ;
				Space(1)          ,; // 01
				SB9->B9_DATA      ,; // 02
				Space(5)          ,; // 03
				Space(3)          ,; // 04
				STR0004           ,; // 05
				SB9->B9_QINI      ,; // 06
				SB9->B9_QINI      ,; // 07
				0                 ,; // 08
				Space(8)          ,; // 09
				Space(12)         ,; // 10
				0                 ,; // 11
				0                 ,; // 12
				SB9->B9_LOCAL     ,; // 13
				Space(15)         ,; // 14
				Space(3)          ,; // 15
				Space(5)          ,; // 17
				""                ,; // 18
				""                ,; // 19
				Space(09)         ,; // 10
				""                ,; // 20
				"  -  " + space(9),; // 21
				'  -  '           ,; // 22
				'  -  '           ,; // 23
				''                ,; // 24
				''                ,; // 25
				''                ,; // 26
				''                ,; // 27
				''                ,; // 28
				''                ,; // 29
				space(6)          ,; // 30
				"SB9"              ; // 31
			})
		Else
			// Adiciona saldo zerado
			Aadd(aPecas, {         ;
				Space(1)          ,; // 01
				STOD('19000101')  ,; // 02
				Space(5)          ,; // 03
				Space(3)          ,; // 04
				STR0004           ,; // 05
				0                 ,; // 06
				0                 ,; // 07
				0                 ,; // 08
				Space(12)         ,; // 09
				Space(4)          ,; // 10
				0                 ,; // 11
				0                 ,; // 12
				cArmz             ,; // 13
				Space(15)         ,; // 14
				Space(3)          ,; // 15
				Space(5)          ,; // 16
				""                ,; // 17
				0                 ,; // 18
				Space(09)         ,; // 19
				Space(03)         ,; // 20
				"  -  " + space(9),; // 21
				'  -  '           ,; // 22
				'  -  '           ,; // 23
				''                ,; // 24
				''                ,; // 25
				''                ,; // 26
				''                ,; // 27
				''                ,; // 28
				''                ,; // 29
				Space(6)          ,; // 30
				""                 ; // 31
			} )
		EndIf
	EndIf

	If Len(aPecas) == 0
		Aadd(aPecas, {         ;
			Space(1)          ,; // 01
			"  -  "           ,; // 02
			Space(5)          ,; // 03
			Space(3)          ,; // 04
			Space(9)          ,; // 05
			0                 ,; // 06
			0                 ,; // 07
			0                 ,; // 08
			Space(12)         ,; // 09
			Space(4)          ,; // 10
			0                 ,; // 11
			0                 ,; // 12
			Space(02)         ,; // 13
			Space(15)         ,; // 14
			Space(03)         ,; // 15
			Space(05)         ,; // 16
			""                ,; // 17
			0                 ,; // 18
			Space(09)         ,; // 19
			Space(03)         ,; // 20
			"  -  " + space(9),; // 21
			'  -  '           ,; // 22
			'  -  '           ,; // 23
			''                ,; // 24
			''                ,; // 25
			''                ,; // 26
			''                ,; // 27
			''                ,; // 28
			''                ,; // 29
			Space(6)          ,; // 30
			""                 ; // 31
		})
	EndIf

	If Len(aArmazem) == 0
		Aadd(aArmazem, { ;
			Space(2)    ,; // 01
			Space(15)   ,; // 02
			0           ,; // 03
			Space(2)    ,; // 04
			Space(15)   ,; // 05
			0           ,; // 06
			0           ,; // 07
			0           ,; // 08
			0           ,; // 09
			0            ; // 10
		})
	EndIf

	aSort(aPecas,,,{|x , y| Dtos(x[2]) + x[30] + x[1] + x[5] + x[3] > Dtos(y[2]) + y[30] + y[1] + y[5] + y[3] })

	// Saldo por mov.
	// 4 -> TM (tipo de mov.)
	// 6 -> QTD Movimentada
	// 22 -> Mov. Estoque? == 'Sim' = .T.
	// 13 -> Armazem
	If lMostraSaldo
		For nCountS := Len(aPecas) to 1 step - 1 // começa no 2 porque o 1 tem a quantidade inicial em estoque
			cTM := aPecas[nCountS][04]

			If nCountS == Len(aPecas)
				nQtdAnt := aPecas[nCountS, 07]
				Loop
			EndIf

			If aPecas[nCountS][13] == cArmz
				If cTM $ "AC+/AJ+"
					nQtdAnt += aPecas[nCountS][06] // soma
				ElseIf cTM $ "AC-/AJ-"
					nQtdAnt -= aPecas[nCountS][06] // subtrai
				Else
					If aPecas[nCountS][22] == 'S' // SF4 - Mov.Estoque
						If cTM $ "Dev/Ent/Edv"
							nQtdAnt += aPecas[nCountS][06] // soma
						ElseIf cTM $ "Req/NFB/NFO/Sai/Tra"
							nQtdAnt -= aPecas[nCountS][06] // subtrai
						EndIf
					EndIf
				EndIf
			EndIf

			// Isto impede a sobrescrita caso já exista valor no saldo, usado para debug das movs
			//If Empty(aPecas[nCountS, 07])
				aPecas[nCountS, 07] := nQtdAnt
			//EndIf
		Next
	EndIf

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd(aObjects, { 05, 15, .T. , .F. }) //Cabecalho
	AAdd(aObjects, { 01, 10, .T. , .T. }) //list box superior
	AAdd(aObjects, { 01, 80, .T. , .F. }) //list box inferior
	AAdd(aObjects, { 01, 30, .T. , .F. }) //list box inferior

	aInfo := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2}
	aPosObj := MsObjSize (aInfo, aObjects, .F.)

	DEFINE MSDIALOG oDlgPecas TITLE STR0001 From aSizeAut[7], 000 to aSizeAut[6], aSizeAut[5] of oMainWnd PIXEL // Movimento do Item

	// Cabeçalho
	// Dados Veículo
	@ aPosObj[1,1] + 007, aPosObj[1,2] + 005 SAY STR0006 OF oDlgPecas PIXEL COLOR CLR_BLUE // Cod Item
	@ aPosObj[1,1] + 005, aPosObj[1,2] + 030 MSGET cB1_GRUPO PICTURE "@!" OF oDlgPecas PIXEL COLOR CLR_BLACK When .f.
	@ aPosObj[1,1] + 005, aPosObj[1,2] + 060 MSGET cB1_CODITE PICTURE "@!" OF oDlgPecas SIZE 090,10 PIXEL COLOR CLR_BLACK When .f.
	@ aPosObj[1,1] + 005, aPosObj[1,2] + 160 MSGET cB1_DESC PICTURE "@!" OF oDlgPecas SIZE 110,10 PIXEL COLOR CLR_BLACK When .f.
	// Fim Dados Veículo

	// Armazém
	@ aPosObj[1,1] + 007, aPosObj[1,2] + 290 SAY STR0033 OF oDlgPecas PIXEL COLOR CLR_BLUE // "Armazem"
	@ aPosObj[1,1] + 005, aPosObj[1,2] + 320 MSGET cArmz PICTURE "@!" OF oDlgPecas PIXEL COLOR CLR_BLACK When .f.
	// Fim Armazém

	// Botões
	@ aPosObj[1,1] + 006, aPosObj[1,4] - 90 BUTTON STR0041 SIZE 26,11 ACTION OFC150LEG() OF oDlgPecas PIXEL // Legenda
	DEFINE SBUTTON FROM aPosObj[1,1] + 006, aPosObj[1,4] - 60 TYPE 6 ACTION OFC1500016_ChamadaImpressaoMovimentoDoItem() ENABLE OF oDlgPecas // Imprimir
	DEFINE SBUTTON FROM aPosObj[1,1] + 006, aPosObj[1,4] - 30 TYPE 1 ACTION oDlgPecas:End() ENABLE OF oDlgPecas // Ok
	// Fim Botões
	// Fim Cabeçalho

	// Corpo (Meio)
	// Movimentos
	@ aPosObj[2,1] + 005, aPosObj[2,2] TO aPosObj[2,3], aPosObj[2,4] LABEL STR0007 OF oDlgPecas PIXEL // Movimentos

	@ aPosObj[2,1] + 013, aPosObj[2,2] + 003 LISTBOX oLbPecas;
		FIELDS HEADER OemToAnsi();
		COLSIZES &( "30,15,20,30,30," + If(lMostraSaldo , "20," , "") + "30,30,10,40,40,15,30,20,15,20,40" );
		SIZE aPosObj[2,4] - 6, aPosObj[2,3] - aPosObj[1,3] - 20 OF oDlgPecas PIXEL

	xCol := {}
	Aadd(xCol, '') // 'Legenda'
	Aadd(xCol, STR0008) // DatMov
	Aadd(xCol, STR0009) // Hr
	Aadd(xCol, STR0010) // TM
	Aadd(xCol, STR0019) // Ar
	Aadd(xCol, STR0020) // Locacao
	Aadd(xCol, STR0011) // NroDoc
	Aadd(xCol, STR0012) // QtdMov

	If lMostraSaldo
		Aadd(xCol, (STR0059 + " - " + If(!Empty(MV_PAR01), MV_PAR01, FM_PRODSBZ(SB1->B1_COD, "SB1->B1_LOCPAD")))) // Armazém
	Else
		Aadd(xCol, "")
	EndIf

	Aadd(xCol, STR0014) // Vlr Movimen
	Aadd(xCol, STR0015) // NroOs/Orc
	Aadd(xCol, STR0034) // Dt baixa
	Aadd(xCol, STR0016) // TT
	Aadd(xCol, STR0017) // Cst Indiv
	Aadd(xCol, STR0018) // Cst Total
	Aadd(xCol, STR0021) // TES
	Aadd(xCol, STR0035) // TM
	Aadd(xCol, STR0022) // CFO
	Aadd(xCol, STR0036) // Custo
	Aadd(xCol, STR0062) // Mov. Estoque?
	Aadd(xCol, STR0063) // NF. Class.?
	Aadd(xCol, STR0070) // Vendedor

	// ListBox
	oLbPecas:aHeaders := aClone(xCol)
	oLbPecas:bHeaderClick := {|oObj, nCol| IIf(nCol == 1, OFC150LEG(), Nil)}
	oLbPecas:bLDblClick := {|| RowClick(oLbPecas)}

	bColConf := {|| {                                                                          ;
		OFC150GLeg(aPecas[oLbPecas:nAt,4])                                                    ,; // 'Legenda'
		aPecas[oLbPecas:nAt,2]                                                                ,; // DatMov
		aPecas[oLbPecas:nAt,3]                                                                ,; // Hr
		aPecas[oLbPecas:nAt,4]                                                                ,; // TM
		aPecas[oLbPecas:nAt,13]                                                               ,; // Ar
		aPecas[oLbPecas:nAt,14]                                                               ,; // Locacao
		aPecas[oLbPecas:nAt,5]                                                                ,; // NroDoc
		FG_AlinVlrs(Transform(aPecas[oLbPecas:nAt,6], '@E 999999.9999'))                      ,; // QtdMov
		IIf(lMostraSaldo,FG_AlinVlrs(Transform(aPecas[oLbPecas:nAt,7], '@E 999999.9999')),"") ,; // Armazém
		FG_AlinVlrs(Transform(OFC150PrtVal(aPecas[oLbPecas:nAt,8], 0.0), '@E 99,999,999.99')) ,; // Vlr Movimen
		aPecas[oLbPecas:nAt,9]                                                                ,; // NroOs/Orc
		aPecas[oLbPecas:nAt,21]                                                               ,; // Dt baixa
		aPecas[oLbPecas:nAt,10]                                                               ,; // TT
		FG_AlinVlrs(Transform(OFC150PrtVal(aPecas[oLbPecas:nAt,11], 0.0), '@E 99,999,999.99')),; // Cst Indiv
		FG_AlinVlrs(Transform(OFC150PrtVal(aPecas[oLbPecas:nAt,12], 0.0), '@E 99,999,999.99')),; // Cst Total
		aPecas[oLbPecas:nAt,15]                                                               ,; // TES
		aPecas[oLbPecas:nAt,20]                                                               ,; // TM
		aPecas[oLbPecas:nAt,16]                                                               ,; // CFO
		FG_AlinVlrs(Transform(OFC150PrtVal(aPecas[oLbPecas:nAt,18], 0.0), '@E 99,999,999.99')),; // Custo
		OC15FmtMEst(aPecas[oLbPecas:nAt,22], '  -  ')                                         ,; // Mov. Estoque?
		OC15FmtCNF(aPecas[oLbPecas:nAt,23], '  -  ')                                          ,; // NF. Class.?
		aPecas[oLbPecas:nAt,17]                                                                ; // Vendedor
	}}

	oLbPecas:SetArray(aPecas)

	oLbPecas:bLine := bColConf
	// Fim ListBox
	// Fim Movimentos

	// Armazém
	@ aPosObj[3,1], aPosObj[3,2] TO aPosObj[3,3], aPosObj[3,4] LABEL STR0023 OF oDlgPecas PIXEL // Armazem

	@ aPosObj[3,1] + 009, aPosObj[3,2] + 003 LISTBOX oLbArmazem FIELDS;
		HEADER STR0023, STR0024, STR0026, STR0071, STR0072 , STR0023, STR0024, STR0026, STR0071, STR0072; // Armazem / Descricao / Saldo Atual / Empenho / a Endereçar / Armazem / Descricao / Saldo Atual / Empenho / a Endereçar
		COLSIZES 30,50,40,40,40,30,50,35,40,40;
		SIZE aPosObj[3,4] - 6, aPosObj[3,3] - aPosObj[2,3] - 14 OF oDlgPecas PIXEL

	oLbArmazem:SetArray(aArmazem)

	// ListBox
	oLbArmazem:bLine := {|| {aArmazem[oLbArmazem:nAt,1]   ,; // Armazem
		aArmazem[oLbArmazem:nAt,2]                        ,; // Descricao
		Transform(aArmazem[oLbArmazem:nAt,3], "@E 999999"),; // Saldo Atual
		Transform(aArmazem[oLbArmazem:nAt,7], "@E 999999"),; // Empenho
		Transform(aArmazem[oLbArmazem:nAt,9], "@E 999999"),; // a Endereçar
		aArmazem[oLbArmazem:nAt,4]                        ,; // Armazem
		aArmazem[oLbArmazem:nAt,5]                        ,; // Descricao
		Transform(aArmazem[oLbArmazem:nAt,6], "@E 999999"),; // Saldo Atual
		Transform(aArmazem[oLbArmazem:nAt,8], "@E 999999"),; // Empenho
		Transform(aArmazem[oLbArmazem:nAt,10], "@E 999999"); // a Endereçar
	}}
	// Fim ListBox
	// Fim Armazém
	// Fim Corpo (Meio)

	// Rodapé
	// Status
	@ aPosObj[4,1], aPosObj[4,2] TO aPosObj[4,3], aPosObj[4,4] LABEL STR0075 OF oDlgPecas PIXEL // Status
	@ aPosObj[4,1] + 3,  aPosObj[4,2] + 30      SAY PADR('[Ent] ' + STR0042, 31, ' ') OF oDlgPecas PIXEL // Entrada
	@ aPosObj[4,1] + 3,  aPosObj[4,2] + 1 * 130 SAY PADR('[Ecn] ' + STR0057, 31, ' ') OF oDlgPecas PIXEL // Entrada Cancelada
	@ aPosObj[4,1] + 3,  aPosObj[4,2] + 2 * 130 SAY PADR('[Edv] ' + STR0073, 31, ' ') OF oDlgPecas PIXEL // Entrada p/ Dev
	@ aPosObj[4,1] + 3,  aPosObj[4,2] + 3 * 130 SAY PADR('[NFB] ' + STR0056, 31, ' ') OF oDlgPecas PIXEL // Saída Balcão
	@ aPosObj[4,1] + 3,  aPosObj[4,2] + 4 * 130 SAY PADR('[Sai] ' + STR0058, 31, ' ') OF oDlgPecas PIXEL // Saída

	@ aPosObj[4,1] + 11, aPosObj[4,2] + 30      SAY PADR('[Tra] ' + STR0074, 31, ' ') OF oDlgPecas PIXEL // Transferência (Saída)
	@ aPosObj[4,1] + 11, aPosObj[4,2] + 1 * 130 SAY PADR('[Can] ' + STR0055, 31, ' ') OF oDlgPecas PIXEL // Saída Cancelada
	@ aPosObj[4,1] + 11, aPosObj[4,2] + 2 * 130 SAY PADR('[Req] ' + STR0049, 31, ' ') OF oDlgPecas PIXEL // Requisição
	@ aPosObj[4,1] + 11, aPosObj[4,2] + 3 * 130 SAY PADR('[Dev] ' + STR0050, 31, ' ') OF oDlgPecas PIXEL // Req. de Devolução
	@ aPosObj[4,1] + 11, aPosObj[4,2] + 4 * 130 SAY PADR('[AC+] ' + STR0051, 31, ' ') OF oDlgPecas PIXEL // Mov. Devolução

	@ aPosObj[4,1] + 19, aPosObj[4,2] + 30      SAY PADR('[AC-] ' + STR0052, 31, ' ') OF oDlgPecas PIXEL // Mov. Retorno
	@ aPosObj[4,1] + 19, aPosObj[4,2] + 1 * 130 SAY PADR('[AJ+] ' + STR0053, 31, ' ') OF oDlgPecas PIXEL // Mov. Devolução Inventário
	@ aPosObj[4,1] + 19, aPosObj[4,2] + 2 * 130 SAY PADR('[AJ-] ' + STR0054, 31, ' ') OF oDlgPecas PIXEL // Mov. Retorno Inventário
	// Fim Status
	// Fim Rodapé

	ACTIVATE MSDIALOG oDlgPecas
Return

/*/{Protheus.doc} OFC1500016_ChamadaImpressaoMovimentoDoItem
Chamada para impressão dos Movimentos do Item
@author Fernando Vitor Cavani
@since 17/09/2019
@version undefined
@type function
/*/
Static Function OFC1500016_ChamadaImpressaoMovimentoDoItem()
	Local oReport

	Private cTitulo := STR0040 // Movimento do Item

	oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
	oReport:SetLandscape() // Define orientação de página do relatório como paisagem.
	oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return

/*/{Protheus.doc} ReportDef
Criando o padrão para impressão dos Movimentos do Item
@author Fernando Vitor Cavani
@since 17/09/2019
@version undefined
@type function
/*/
Static Function ReportDef()
	Local cDesc := ""
	Local oReport
	Local oSection1
	Local oSection2

	cDtm := cHr  := cTM1 := cAr  := cLoc := cNrd := cQtm := ""
	cArm := cVlm := cNos := cDtb := cTT  := cCin := cCto := ""
	cTES := cTM2 := cCFO := cCus := cMov := cNFc := cVen := ""

	cAz1 := cDe1 := cSa1 := cEm1 := cEn1 := ""
	cAz2 := cDe2 := cSa2 := cEm2 := cEn2 := ""

	// Descrição
	cDesc := STR0076 // Este programa tem como objetivo imprimir os movimentos do item

	// TReport
	oReport := TReport():New(            ;
		"OFIOC150",                      ;
		cTitulo,                         ;
		cPerg,                           ;
		{|oReport| FS_IMPOC150(oReport)},;
		cDesc)

	// Dados (Movimentos do Item)
	oSection1 := TRSection():New(oReport, "oDados")

	TRCell():New(oSection1, "oDtm",, STR0008, "@!"            , 20,, {|| cDtm },,,        ,,,,,,) // DatMov
	TRCell():New(oSection1, "oHr" ,, STR0009, "@!"            , 10,, {|| cHr  },,,        ,,,,,,) // Hr
	TRCell():New(oSection1, "oTM1",, STR0010, "@!"            ,  5,, {|| cTM1 },,,        ,,,,,,) // TM
	TRCell():New(oSection1, "oAr" ,, STR0019, "@!"            ,  5,, {|| cAr  },,,        ,,,,,,) // Ar
	TRCell():New(oSection1, "oLoc",, STR0020, "@!"            , 10,, {|| cLoc },,,        ,,,,,,) // Locacao
	TRCell():New(oSection1, "oNrd",, STR0011, "@!"            , 25,, {|| cNrd },,,        ,,,,,,) // NroDoc
	TRCell():New(oSection1, "oQtm",, STR0012, "@E 999999.9999", 10,, {|| cQtm },,, "RIGHT",,,,,,) // QtdMov

	If lMostraSaldo
		TRCell():New(oSection1, "oArm",, Substr(STR0059, 1, 5) + " - " + If(!Empty(MV_PAR01), MV_PAR01, FM_PRODSBZ(SB1->B1_COD, "SB1->B1_LOCPAD")), "@E 999999.9999", 20,, {|| cArm },,,"RIGHT",,,,,,) // Armazém
	EndIf

	TRCell():New(oSection1, "oVlm",, STR0014, "@E 99,999,999.99", 20,, {|| cVlm },,, "RIGHT",,,,,,) // Vlr Movimen
	TRCell():New(oSection1, "oNos",, STR0015, "@!"              , 25,, {|| cNos },,,        ,,,,,,) // NroOs/Orc
	TRCell():New(oSection1, "oDtb",, STR0034, "@!"              , 20,, {|| cDtb },,,        ,,,,,,) // Dt baixa
	TRCell():New(oSection1, "oTT" ,, STR0016, "@!"              ,  5,, {|| cTT  },,,        ,,,,,,) // TT
	TRCell():New(oSection1, "oCin",, STR0017, "@E 99,999,999.99", 20,, {|| cCin },,, "RIGHT",,,,,,) // Cst Indiv
	TRCell():New(oSection1, "oCto",, STR0018, "@E 99,999,999.99", 20,, {|| cCto },,, "RIGHT",,,,,,) // Cst Total
	TRCell():New(oSection1, "oTES",, STR0021, "@!"              ,  5,, {|| cTES },,,        ,,,,,,) // TES
	TRCell():New(oSection1, "oTM2",, STR0035, "@!"              ,  5,, {|| cTM2 },,,        ,,,,,,) // TM
	TRCell():New(oSection1, "oCFO",, STR0022, "@!"              ,  5,, {|| cCFO },,,        ,,,,,,) // CFO
	TRCell():New(oSection1, "oCus",, STR0036, "@E 99,999,999.99", 20,, {|| cCus },,, "RIGHT",,,,,,) // Custo
	TRCell():New(oSection1, "oMov",, STR0062, "@!"              , 20,, {|| cMov },,,        ,,,,,,) // Mov. Estoque?
	TRCell():New(oSection1, "oNFc",, STR0063, "@!"              , 20,, {|| cNFc },,,        ,,,,,,) // NF. Class.?
	TRCell():New(oSection1, "oVen",, STR0070, "@!"              , 30,, {|| cVen },,,        ,,,,,,) // Vendedor

	// Armazém (Totais)
	oSection2 := TRSection():New(oReport, "oTotais")

	oSection2:SetLinesBefore(2)       // Define a quantidade de linhas que serão saltadas antes da impressão da seção

	TRCell():New(oSection2, "oAz1",, STR0023, "@!"       , 15,, {|| cAz1 },,,        ,,,,,,) // Armazem
	TRCell():New(oSection2, "oDe1",, STR0024, "@!"       , 25,, {|| cDe1 },,,        ,,,,,,) // Descricao
	TRCell():New(oSection2, "oSa1",, STR0026, "@E 999999", 15,, {|| cSa1 },,, "RIGHT",,,,,,) // Saldo Atual
	TRCell():New(oSection2, "oEm1",, STR0071, "@E 999999", 15,, {|| cEm1 },,, "RIGHT",,,,,,) // Empenho
	TRCell():New(oSection2, "oEn1",, STR0072, "@E 999999", 15,, {|| cEn1 },,, "RIGHT",,,,,,) // a Endereçar
	TRCell():New(oSection2, "oAz2",, STR0023, "@!"       , 15,, {|| cAz2 },,,        ,,,,,,) // Armazem
	TRCell():New(oSection2, "oDe2",, STR0024, "@!"       , 25,, {|| cDe2 },,,        ,,,,,,) // Descricao
	TRCell():New(oSection2, "oSa2",, STR0026, "@E 999999", 15,, {|| cSa2 },,, "RIGHT",,,,,,) // Saldo Atual
	TRCell():New(oSection2, "oEm2",, STR0071, "@E 999999", 15,, {|| cEm2 },,, "RIGHT",,,,,,) // Empenho
	TRCell():New(oSection2, "oEn2",, STR0072, "@E 999999", 15,, {|| cEn2 },,, "RIGHT",,,,,,) // a Endereçar
Return(oReport)

/*/{Protheus.doc} FS_IMPOC150
	@author       Vinicius Gati
	@since        20/06/2002
	@description  Impressão das movimentações
/*/
Static Function FS_IMPOC150(oReport)
	Local nFor      :=  0
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)

	// Dados (Movimentos do Item)
	oSection1:Init()

	For nFor := 1 To Len(oLbPecas:aArray)
		cDtm := oLbPecas:aArray[nFor, 2]  // DatMov

		If Len(Alltrim(oLbPecas:aArray[nFor, 3])) <= 4
			cHr := ""
		ElseIf Substr(oLbPecas:aArray[nFor, 3], 4, 1) == ":"
			cHr := Substr(oLbPecas:aArray[nFor, 3], 1, 6) // Hr
		Else
			cHr := Substr(oLbPecas:aArray[nFor, 3], 1, 5) // Hr
		EndIf

		cTM1 := oLbPecas:aArray[nFor, 4]  // TM
		cAr  := oLbPecas:aArray[nFor, 13] // Ar
		cLoc := oLbPecas:aArray[nFor, 14] // Locacao
		cNrd := oLbPecas:aArray[nFor, 5]  // NroDoc
		cQtm := OFC150PrtVal(oLbPecas:aArray[nFor, 6], 0.0) // QtdMov

		If(lMostraSaldo)
			cArm := OFC150PrtVal(oLbPecas:aArray[nFor, 7], 0.0) // Armazém - XX
		EndIf

		cVlm := OFC150PrtVal(oLbPecas:aArray[nFor, 8], 0.0) // Vlr Movimen
		cNos := oLbPecas:aArray[nFor, 9]  // Nr
		cDtb := oLbPecas:aArray[nFor, 21] // Dt baixa
		cTT  := oLbPecas:aArray[nFor, 10] // TT
		cCin := OFC150PrtVal(oLbPecas:aArray[nFor, 11], 0.0) // Cs
		cCto := OFC150PrtVal(oLbPecas:aArray[nFor, 12], 0.0) // Cst
		cTES := oLbPecas:aArray[nFor, 15] // TES
		cTM2 := oLbPecas:aArray[nFor, 20] // TM
		cCFO := oLbPecas:aArray[nFor, 16] // CFO
		cCus := OFC150PrtVal(oLbPecas:aArray[nFor, 18] , 0.0) // Custo
		cMov := OC15FmtMEst(oLbPecas:aArray[nFor, 22], '  -  ') // Mov. Estoque?
		cNFc := OC15FmtCNF(oLbPecas:aArray[nFor, 23], '  -  ') // NF. Class.?
		cVen := oLbPecas:aArray[nFor, 17] // Vendedor

		oSection1:PrintLine()
	Next

	oSection1:Finish()

	// Armazem (Totais)
	oSection2:Init()

	For nFor := 1 To Len(oLbArmazem:aArray)
		cAz1 := oLbArmazem:aArray[nFor, 1]  // Armazem
		cDe1 := oLbArmazem:aArray[nFor, 2]  // Descricao
		cSa1 := oLbArmazem:aArray[nFor, 3]  // Saldo Atual
		cEm1 := oLbArmazem:aArray[nFor, 7]  // Empenho
		cEn1 := oLbArmazem:aArray[nFor, 9]  // a Endereçar
		cAz2 := oLbArmazem:aArray[nFor, 4]  // Armazem
		cDe2 := oLbArmazem:aArray[nFor, 5]  // Descricao
		cSa2 := oLbArmazem:aArray[nFor, 6]  // Saldo Atual
		cEm2 := oLbArmazem:aArray[nFor, 8]  // Empenho
		cEn2 := oLbArmazem:aArray[nFor, 10] // a Endereçar

		oSection2:PrintLine()
	Next

	oSection2:Finish()
Return

/*/{Protheus.doc} MenuDef
	@author       Fabio
	@since        13/06/2001
	@description  Menus disponíveis no programa
/*/
Static Function MenuDef()
	Local aRotina := {                                  ;
		{STR0002, "axPesqui"                    , 0, 1},; // Pesquisar
		{STR0003, "Processa( {|| FS_OC150() } )", 0, 2} ; // Visualizar
	}
Return aRotina

/*/{Protheus.doc} OFC150GLeg
	@author       Vinicius Gati
	@since        31/03/2014
	@description  Busca Legenda dependendo o status do Movimento
/*/
Function OFC150GLeg(cStatus)
	Local oPink  := LoadBitmap(GetResources() , "BR_PINK")     // Remessa
	Local oAzul  := LoadBitmap(GetResources() , "BR_AZUL")     // Consignado
	Local oVerm  := LoadBitmap(GetResources() , "BR_VERMELHO") // Pedido
	Local oAmar  := LoadBitmap(GetResources() , "BR_AMARELO")  // Reservados
	Local oColor := oAzul

	Local aLegMap := {                          ;
		{{'ECn', 'Ent'},        oAzul, STR0042},; // Entradas 42
		{{'Dev', 'Req'},        oPink, STR0043},; // Requisições 43
		{{'AC+', 'AJ+'},        oAmar, STR0044},; // Movimentações de Entrada 44
		{{'AC-', 'AJ-'},        oAmar, STR0045},; // Movimentações de Saída 45
		{{'Can', 'Sai', 'Tra'}, oVerm, STR0046},; // Saídas
		{{'NFB', 'NFO'},        oVerm, STR0047} ; // Saídas Balcão
	}

	Local i := 1

	For i := 1 to Len(aLegMap) Step + 1
		nIdxFound := ASCAN(aLegMap[i][1], {|cVal| cVal == cStatus})
		If nIdxFound > 0
			oColor := aLegMap[i][2]
			// Sair do FOR pois ja encontrou o elemento procurado
		EndIf
	Next
Return oColor

/*/{Protheus.doc} OFC150PrtVal
	@author       Vinicius Gati
	@since        01/04/2014
	@description  Caso o valor passado por parametro seja Nil ou em branco imprime 
	              o valor default passado como parametro.
/*/
Function OFC150PrtVal(nValue, nDefVal)
	Default nDefVal := 0

	If (Empty(nValue))
		nValue := nDefVal
	EndIf
Return nValue

/*/{Protheus.doc} OFC150LEG
	@author       Vinicius Gati
	@since        01/04/2014
	@description  Mostra a legenda dos status dos movimentos de estoque
/*/
Static Function OFC150LEG()
	Local aLegenda := {          ;
		{'BR_PINK'    , STR0043},; // Requisições
		{'BR_AZUL'    , STR0042},; // Entradas
		{'BR_VERMELHO', STR0046},; // Saídas
		{'BR_VERMELHO', STR0047},; // Saídas Balcão
		{'BR_AMARELO' , STR0044},; // Movimentações de Entrada
		{'BR_AMARELO' , STR0045} ; // Movimentações de Saída
	}

	BrwLegenda(STR0041, STR0041, aLegenda) // Legenda / Legenda
Return

/*/{Protheus.doc} ValidPerg
	@author       Vinicius Gati
	@since        04/04/2014
	@description  Cria uma pergunta por codigo, o grupo sera o parametro cPerg, 
								os campos são iguais aos do sx1
/*/
Static Function ValidPerg(cPerg)
	Local i, j

	_sAlias := Alias()

	dbSelectArea("SX1")
	dbSetOrder(1)

	cPerg := PADR(cPerg, Len(SX1->X1_GRUPO))

	aRegs := {}

	AADD(aRegs, {cPerg, "01", STR0064, "", "", "mv_ch1", "C", 2, 0, 0, "G", "", "mv_par01", ""     , "", "", "", "", ""     ,; // Armazem       ?
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "BE2", "", "" , "", ""                        , ""})

	AADD(aRegs, {cPerg, "02", STR0065, "", "", "mv_ch2", "C", 1, 0, 1, "C", "", "mv_par02", STR0060, "", "", "", "", STR0061,; // Mostra Saldo  ? / Sim / Não
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "", "" , "", ""                        , ""})

	AADD(aRegs, {cPerg, "03", STR0066, "", "", "mv_ch3", "D", 8, 0, 0, "G", "", "mv_par03", ""     , "", "", "", "", ""     ,; // Dt. Inicial ?
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "", "S", "", ""                        , ""})

	AADD(aRegs, {cPerg, "04", STR0067, "", "", "mv_ch4", "D", 8, 0, 0, "G", "", "mv_par04", ""     , "", "", "", "", ""     ,; // Dt. Final   ?
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "", "S", "", ""                        , ""})

	AADD(aRegs, {cPerg, "05", STR0068, "", "", "mv_ch5", "C",70, 0, 0, "G", "", "mv_par05", ""     , "", "", "", "", ""     ,; // Não listar Armazéns
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "", "S", "", "!!/!!/!!/!!/!!/!!/!!/!!/", ""})

	For i := 1 to Len(aRegs)
		If !DbSeek(cPerg + aRegs[i,2])
			RecLock("SX1", .T.)

			For j := 1 to FCount()
				FieldPut(j, aRegs[i,j])
			Next

			MsUnlock()
			dbCommit()
		EndIf
	Next

	DbSelectArea(_sAlias)
Return

/*/{Protheus.doc} RowClick
	@author       Vinicius Gati
	@since        04/04/2014
	@description  Evento de click que e utilizado no listbox dos movimentos de peça
	@param        oObj, Listbox contendo os dados de movimentacoes de pecas
/*/
Static Function RowClick(oObj)
	Local cSerie  := ""
	Local cDoc    := ""
	Local cFornec := ""
	Local cLoja   := ""
	Local cFil    := ""
	Local cTipo   := ""
	Local nRow    := oObj:nAt
	Local nCol    := oObj:nColPos
	Local aRow    := oObj:aArray[nRow]

	If nCol == 7 .AND. aRow[31] == "SD2"
		// row válido pois é maior que os outros (contêm informações de nota fiscal)
		cSerie := aRow[24] // D2_SERIE
		cDoc   := aRow[25] // D2_DOC

		// nota fiscal existente?
		If !Empty(cDoc) .AND. !Empty(cSerie)
			SF2->(DbSetOrder(1))

			If SF2->(DbSeek(xFilial("SF2") + cDoc + cSerie))
				cAlias := "SF2"
				nReg   := SF2->(Recno())
				nOpc   := 2

				Mc090Visual(cAlias, nReg, nOpc)
			EndIf
		EndIf
	ElseIf nCol == 7 .AND. aRow[31] == "SD1"
		// Entrada
		cSerie  := aRow[25]
		cDoc    := aRow[24]
		cFornec := aRow[26]
		cLoja   := aRow[27]
		cFil    := aRow[28]
		cTipo   := aRow[29]

		SF1->(DBSetOrder(1))

		If SF1->(DBSeek(cFil + cDoc + cSerie + cFornec + cLoja + cTipo))
			cAlias := "SF1"
			nReg   := SF1->(Recno())
			nOpc   := 2

			A103NFiscal(cAlias, nReg, nOpc, .f.)
		EndIf
	ElseIf nCol == 7 // aRow[31] $ "SD3/VO3"
		// Movimentações da SD3
		dbSelectArea("SD3")
		dbSetOrder(2)

		If dbSeek(xFilial("SD3") + aRow[5] + cB1_COD)
			nReg := Recno()

			A260Visual("SD3", nReg, 2)
		Else
			MsgInfo(STR0069)
		EndIf
	ElseIf nCol == 11
		// Orçamento ou OS
		If Left(aRow[9],3) == "Orc"
			VS1->(DbSetOrder(1))

			If VS1->(dbSeek(xFilial("VS1") + right(aRow[9], 8)))
				OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
			EndIf
		ElseIf Left(aRow[9],3) == "OSv"
			nOpc := 2

			VO1->(DbSetOrder(1))

			If VO1->(dbSeek(xFilial("VO1") + right(aRow[9], 8)))
				OFIOC060(.T.)
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} OC15FmtMEst
	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata valor que será mostrado quando for nota e movimentar estoque no tipo de E/S
	@param        oObj,Valor do F4_ESTOQUE, Valor padrão em caso de 'em branco'
/*/
Static Function OC15FmtMEst(cValue, cDefault)
	If (cValue == "S")
		Return STR0060 // Sim
	Else
		IF(cValue != cDefault)
			Return STR0061 // Não
		EndIf
	EndIf
Return cDefault

/*/{Protheus.doc} OC15FmtCNF
	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata valor que será mostrado quando for nota e a mesma estiver classificada
	@param        Value, Valor F1_STATUS, Valor que caso em branco não esta classificada
/*/
Static Function OC15FmtCNF(cValue, cDefault)
	If (cValue != cDefault)
		If(!Empty(cValue))
			Return STR0060 // Sim
		Else
			Return STR0061 // Não
		EndIf
	EndIf
Return cDefault
