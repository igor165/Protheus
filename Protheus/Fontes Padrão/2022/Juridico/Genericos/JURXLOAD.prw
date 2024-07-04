#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURXLOAD.CH'

Static aDadosNTY := {} // Dados de Legendas
Static aDadosNTZ := {} // Dados de Regras de Preenchimento
Static aDadosNVX := {} // Dados de Agrupamento Cabeçalho
Static aDadosNUX := {} // Dados de Agrupamento Agrupamentos
Static aDadosNUY := {} // Dados de Agrupamento Campos dos Agrupamentos

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadLeg
Cria registros da tabela de legendas conforme parametros.

@param  cTabela     Tabela de referencia
@param  cFunction   Nome da Funcao referente as legendas. Se nao For especificado pega as definiçoes cadastradas com o
                    nome da funcao em branco para a tabela.

@author Ernani Forastieri
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoadLeg( cTabela, cFuncao )
Local lRet       := .T.
Local aArea      := GetArea()
Local aStruct    := {}
Local aGrvVazio  := {}
Local cTabDados  := 'NTY'
Local cFilTab    := xFilial(cTabDados)

ParamType 0 Var cTabela  As Character Optional Default Alias()
ParamType 1 Var cFuncao  As Character Optional Default Space(10)

aAdd( aStruct, 'NTY_FILIAL' )
aAdd( aStruct, 'NTY_TABELA' )
aAdd( aStruct, 'NTY_FUNCAO' )
aAdd( aStruct, 'NTY_SEQ'    )
aAdd( aStruct, 'NTY_REGRA'  )
aAdd( aStruct, 'NTY_COR'    )
aAdd( aStruct, 'NTY_LEGEND' )
aAdd( aStruct, 'NTY_LEGENG' )
aAdd( aStruct, 'NTY_LEGSPA' )
aAdd( aStruct, 'NTY_PROPRI' )

aAdd( aGrvVazio, 'NTY_LEGEND' )
aAdd( aGrvVazio, 'NTY_LEGENG' )
aAdd( aGrvVazio, 'NTY_LEGSPA' )
aAdd( aGrvVazio, 'NTY_REGRA'  )
aAdd( aGrvVazio, 'NTY_COR'    )


// Cores GREEN, RED, YELLOW, ORANGE, BLUE , GRAY , BROWN , BLACK, PINK, WHITE
If Len( aDadosNTY ) == 0

	aAdd( aDadosNTY, { cFilTab, 'NSU', cFuncao , '001', 'NSU_FIMVGN > DATE() .OR. EMPTY(NSU_FIMVGN) .OR. NSU_DCAREN > DATE()'                                                              , 'GREEN'          , STR0023       , STR0023       , STR0023       , 'S' } ) //"Ativo                                             "###"Ativo                                             "###"Ativo                                             "
	aAdd( aDadosNTY, { cFilTab, 'NSU', cFuncao , '002', 'NSU_FIMVGN <= DATE() .OR. NSU_DCAREN <= DATE()'                                                                                   , 'RED'            , STR0024       , STR0024       , STR0024       , 'S' } ) //"Encerrado                                         "###"Encerrado                                         "###"Encerrado
	aAdd( aDadosNTY, { cFilTab, 'NQL', cFuncao , '001', "JURLEGANEX('NQL','NQL->NQL_COD', "+"'"+"XFILIAL("+chr(34)+"NQL"+chr(34)+")+NQL->NQL_COD"+"'"+")"                                  , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NQL', cFuncao , '002', "!JURLEGANEX('NQL','NQL->NQL_COD', "+"'"+"XFILIAL("+chr(34)+"NQL"+chr(34)+")+NQL->NQL_COD"+"'"+")"                                 , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NSY', cFuncao , '001', "JURLEGANEX('NSY','NSY->NSY_COD', "+"'"+"XFILIAL("+chr(34)+"NSY"+chr(34)+")+NSY->NSY_COD+NSY->NSY_CAJURI"+"'"+")"                  , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NSY', cFuncao , '002', "!JURLEGANEX('NSY','NSY->NSY_COD', "+"'"+"XFILIAL("+chr(34)+"NSY"+chr(34)+")+NSY->NSY_COD+NSY->NSY_CAJURI"+"'"+")"                 , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NT2', cFuncao , '001', "JURLEGANEX('NT2','NT2->NT2_CAJURI+NT2->NT2_COD', "+"'"+"XFILIAL("+chr(34)+"NT2"+chr(34)+")+NT2->NT2_CAJURI+NT2->NT2_COD"+"'"+")"  , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NT2', cFuncao , '002', "!JURLEGANEX('NT2','NT2->NT2_CAJURI+NT2->NT2_COD', "+"'"+"XFILIAL("+chr(34)+"NT2"+chr(34)+")+NT2->NT2_CAJURI+NT2->NT2_COD"+"'"+")" , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NT3', cFuncao , '001', "JURLEGANEX('NT3','NT3->NT3_CAJURI+NT3->NT3_COD', "+"'"+"XFILIAL("+chr(34)+"NT3"+chr(34)+")+NT3->NT3_CAJURI+NT3->NT3_COD"+"'"+")"  , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NT3', cFuncao , '002', "!JURLEGANEX('NT3','NT3->NT3_CAJURI+NT3->NT3_COD', "+"'"+"XFILIAL("+chr(34)+"NT3"+chr(34)+")+NT3->NT3_CAJURI+NT3->NT3_COD"+"'"+")" , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NT4', cFuncao , '001', "JURLEGANEX('NT4','NT4->NT4_COD', "+"'"+"XFILIAL("+chr(34)+"NT4"+chr(34)+")+NT4->NT4_COD"+"'"+")"                                  , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NT4', cFuncao , '002', "!JURLEGANEX('NT4','NT4->NT4_COD', "+"'"+"XFILIAL("+chr(34)+"NT4"+chr(34)+")+NT4->NT4_COD"+"'"+")"                                 , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '001', "Posicione('NQN', 1 , xFilial('NQN') + NTA->NTA_CRESUL , 'NQN_TIPO') == '2'"                                                       , 'GREEN'          , STR0005       , STR0005       , STR0005       , 'S' } ) //"Efetuado                                          "###"Efetuado                                          "###"Efetuado                                          "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '002', "(Posicione('NQN',1,xFilial('NQN')+NTA->NTA_CRESUL,'NQN_TIPO')=='1').AND.(NTA->NTA_DTFLWP<DATE())"                                 , 'RED'            , STR0006       , STR0006       , STR0006       , 'S' } ) //"Pendente - Em Atraso                              "###"Pendente - Em Atraso                              "###"Pendente - Em Atraso                              "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '003', "Posicione('NQN', 1 , xFilial('NQN') + NTA->NTA_CRESUL , 'NQN_TIPO') == '3'"                                                       , 'GRAY'           , STR0007       , STR0007       , STR0007       , 'S' } ) //"Cancelado                                         "###"Cancelado                                         "###"Cancelado                                         "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '004', 'JUR106PEN()'                                                                                                                      , 'YELLOW'         , STR0008       , STR0008       , STR0008       , 'S' } ) //"Pendente - Em Andamento                           "###"Pendente - Em Andamento                           "###"Pendente - Em Andamento                           "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '005', 'JUR106REAG()'                                                                                                                     , 'BLUE'           , STR0009       , STR0009       , STR0009       , 'S' } ) //"Reagendado                                        "###"Reagendado                                        "###"Reagendado                                        "
	aAdd( aDadosNTY, { cFilTab, 'NTA', cFuncao , '006', "Posicione('NQN', 1 , xFilial('NQN') + NTA->NTA_CRESUL , 'NQN_TIPO') == '4'"                                                       , 'WHITE'          , STR0064       , STR0064       , STR0064       , 'S' } ) //"Em Aprovação                                      "###"Em Aprovação                                      "###"Em Aprovação                                      "
	aAdd( aDadosNTY, { cFilTab, 'NUN', cFuncao , '001', "JURLEGANEX('NUN','NUN->NUN_COD', "+"'"+"XFILIAL("+chr(34)+"NUP"+chr(34)+")+NUN->NUN_COD+NUP->NUP_COD+NUP->NUP_CTPDOC"+"'"+")"     , 'GREEN'          , STR0003       , STR0003       , STR0003       , 'S' } ) //"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "###"Ha Anexo(s)                                       "
	aAdd( aDadosNTY, { cFilTab, 'NUN', cFuncao , '002', "!JURLEGANEX('NUN','NUN->NUN_COD', "+"'"+"XFILIAL("+chr(34)+"NUP"+chr(34)+")+NUN->NUN_COD+NUP->NUP_COD+NUP->NUP_CTPDOC"+"'"+")"    , 'RED'            , STR0004       , STR0004       , STR0004       , 'S' } ) //"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "###"Nao Ha Anexo(s)                                   "
	aAdd( aDadosNTY, { cFilTab, 'NUZ', cFuncao , '001', 'NUZ_USAPRO=="1".AND.NUZ_USACAS=="1"'                                                                                              , 'GREEN'          , STR0010       , STR0010       , STR0010       , 'S' } ) //"Usado Processo/Caso                               "###"Usado Processo/Caso                               "###"Usado Processo/Caso                               "
	aAdd( aDadosNTY, { cFilTab, 'NUZ', cFuncao , '002', 'NUZ_USAPRO=="1".AND.NUZ_USACAS=="2"'                                                                                              , 'YELLOW'         , STR0011       , STR0011       , STR0011       , 'S' } ) //"Usado Processo                                    "###"Usado Processo                                    "###"Usado Processo                                    "
	aAdd( aDadosNTY, { cFilTab, 'NUZ', cFuncao , '003', 'NUZ_USAPRO=="2".AND.NUZ_USACAS=="1"'                                                                                              , 'BLUE'           , STR0012       , STR0012       , STR0012       , 'S' } ) //"Usado Caso                                        "###"Usado Caso                                        "###"Usado Caso                                        "
	aAdd( aDadosNTY, { cFilTab, 'NUZ', cFuncao , '004', 'NUZ_USAPRO=="2".AND.NUZ_USACAS=="2"'                                                                                              , 'GRAY'           , STR0013       , STR0013       , STR0013       , 'S' } ) //"Nao Usado                                         "###"Nao Usado                                         "###"Nao Usado                                         "
	aAdd( aDadosNTY, { cFilTab, 'NTY', cFuncao , '001', 'NTY_PROPRI == "S"'                                                                                                                , 'BLUE'           , STR0014       , STR0015       , STR0015       , 'S' } ) //"Legenda Padrão                                    "###"Não Permite Alteração                             "###"Não Permite Alteração                             "
	aAdd( aDadosNTY, { cFilTab, 'NTY', cFuncao , '002', 'NTY_PROPRI <> "S"'                                                                                                                , 'YELLOW'         , STR0016       , STR0017       , STR0017       , 'S' } ) //"Legenda Customizada                               "###"Permite Alteração                                 "###"Permite Alteração                                 "
	aAdd( aDadosNTY, { cFilTab, 'NTZ', cFuncao , '001', 'NTZ_PROPRI == "S"'                                                                                                                , 'RED'            , STR0015       , STR0015       , STR0015       , 'S' } ) //"Não Permite Alteração                             "###"Não Permite Alteração                             "###"Não Permite Alteração                             "
	aAdd( aDadosNTY, { cFilTab, 'NTZ', cFuncao , '002', 'NTZ_PROPRI <> "S"'                                                                                                                , 'GREEN'          , STR0017       , STR0017       , STR0017       , 'S' } ) //"Permite Alteração                                 "###"Permite Alteração                                 "###"Permite Alteração                                 "
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '001', 'NX0_SITUAC == "2"'                                                                                                                , 'RED'            , JurSitGet("2"), JurSitGet("2"), JurSitGet("2"), 'S' } ) //"Análise", "Análise", "S" } )   //"Análise"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '002', 'NX0_SITUAC == "3"'                                                                                                                , 'YELLOW'         , JurSitGet("3"), JurSitGet("3"), JurSitGet("3"), 'S' } ) //"Alterada", "Alterada", "S" } )   //"Alterada"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '003', 'NX0_SITUAC == "4"'                                                                                                                , 'ORANGE'         , JurSitGet("4"), JurSitGet("4"), JurSitGet("4"), 'S' } ) //"Emitir Fatura", "Emitir Fatura", "S" } )   //"Emitir Fatura"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '004', 'NX0_SITUAC == "5"'                                                                                                                , 'BLUE'           , JurSitGet("5"), JurSitGet("5"), JurSitGet("5"), 'S' } ) //"Emitir Minuta", "Emitir Minuta", "S" } )   //"Emitir Minuta"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '005', 'NX0_SITUAC == "6"'                                                                                                                , 'GRAY'           , JurSitGet("6"), JurSitGet("6"), JurSitGet("6"), 'S' } ) //"Minuta Emitida", "Minuta Emitida", "S" } )   //"Minuta Emitida"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '006', 'NX0_SITUAC == "7"'                                                                                                                , 'BROWN'          , JurSitGet("7"), JurSitGet("7"), JurSitGet("7"), 'S' } ) //"Minuta Cancelada", "Minuta Cancelada", "S" } )   //"Minuta Cancelada"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '007', 'NX0_SITUAC == "8"'                                                                                                                , 'BR_CANCEL'      , JurSitGet("8"), JurSitGet("8"), JurSitGet("8"), 'S' } ) //"Pré-Fatura Substituída/Cancelada", "Pré-Fatura Substituída/Cancelada", "S" } )  	 //"Pré-Fatura Substituída/Cancelada"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '008', 'NX0_SITUAC == "9"'                                                                                                                , 'WHITE'          , JurSitGet("9"), JurSitGet("9"), JurSitGet("9"), 'S' } ) //"Minuta Socio"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '009', 'NX0_SITUAC == "A"'                                                                                                                , 'HGREEN'         , JurSitGet("A"), JurSitGet("A"), JurSitGet("A"), 'S' } ) //"Minuta Socio Emitida"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '010', 'NX0_SITUAC == "B"'                                                                                                                , 'BROWN'          , JurSitGet("B"), JurSitGet("B"), JurSitGet("B"), 'S' } ) //"Minuta Socio Cancelada"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '011', 'NX0_SITUAC == "C"'                                                                                                                , 'PINK'           , JurSitGet("C"), JurSitGet("C"), JurSitGet("C"), 'S' } ) //"Em Revisão"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '012', 'NX0_SITUAC == "D"'                                                                                                                , 'HGREEN'         , JurSitGet("D"), JurSitGet("D"), JurSitGet("D"), 'S' } ) //"Revisada"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '013', 'NX0_SITUAC == "E"'                                                                                                                , 'LBLUE'          , JurSitGet("E"), JurSitGet("E"), JurSitGet("E"), 'S' } ) //"Revisada com Restrições"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '014', 'NX0_SITUAC == "F"'                                                                                                                , 'VIOLET'         , JurSitGet("F"), JurSitGet("F"), JurSitGet("F"), 'S' } ) //"Aguardando Sincronização"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '015', 'NX0_SITUAC == "G"'                                                                                                                , 'GREEN'          , JurSitGet("G"), JurSitGet("G"), JurSitGet("G"), 'S' } ) //"Fatura Emitida"
	aAdd( aDadosNTY, { cFilTab, 'NX0', cFuncao , '016', 'NX0_SITUAC == "H"'                                                                                                                , 'BLACK'          , JurSitGet("H"), JurSitGet("H"), JurSitGet("H"), 'S' } ) //"Cancelada pela Revisão"
	aAdd( aDadosNTY, { cFilTab, 'NWT', cFuncao , '001', 'NWT_FLAG == "1"'                                                                                                                  , 'GREEN'          , STR0033       , STR0033       , STR0033       , 'S' } ) //"Registro importado com sucesso"
	aAdd( aDadosNTY, { cFilTab, 'NWT', cFuncao , '002', 'NWT_FLAG == "2"'                                                                                                                  , 'RED'            , STR0034       , STR0034       , STR0034       , 'S' } ) //"Registro com falha na importacao"
	aAdd( aDadosNTY, { cFilTab, 'NZF', cFuncao , '001', 'NZF_STATUS == "1"'                                                                                                                , 'RED'            , STR0060       , STR0060       , STR0060       , 'S' } ) //"Pendente"
	aAdd( aDadosNTY, { cFilTab, 'NZF', cFuncao , '002', 'NZF_STATUS == "2"'                                                                                                                , 'BLUE'           , STR0061       , STR0061       , STR0061       , 'S' } ) //"Aprovado"
	aAdd( aDadosNTY, { cFilTab, 'NZF', cFuncao , '003', 'NZF_STATUS == "3"'                                                                                                                , 'YELLOW'         , STR0062       , STR0062       , STR0062       , 'S' } ) //"Não Aprovado"
	aAdd( aDadosNTY, { cFilTab, 'NZF', cFuncao , '004', 'NZF_STATUS == "4"'                                                                                                                , 'GREEN'          , STR0063       , STR0063       , STR0063       , 'S' } ) //"Encerrado"

EndIf

JurLoadData(cTabela, cFuncao, aStruct, aDadosNTY, cTabDados, aGrvVazio)

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadData(cTabRegra, cFuncao, aStruct, aDados, cTabDados, aGrvVazio, aNaoGrava)
Verifica se houve alteração na linha do array com a regra em relação a base de dados

@Param  cTabRegra    Tabela que serão gravados os dados
@param  cFunction    Nome da Funcao referente as legendas. Se nao For especificado pega as definiçoes cadastradas com o
                     nome da funcao em branco para a tabela.
@param  aStruct      Estrutura de campos da tabela
@Param  aDados       Array com os dados da funcioalidade Ex: Legendas
@Param  cTabDados    Tabela que serão gravados dos dados do array
@Param  aGrvVazio    Array com os campos que serão gravados somente se na base estiver vazio. Ex: Campos editaveis pelo usuário
@Param  aNaoGrava    Array com os campos que não serão gravados na base. Ex: campos de lingua que não sao do sistema.

@Return aChanged  Array com os campos e informação que estao diferentes e devem ser atualizadas
        aChanged[N][1] Campo da estrutura
        aChanged[N][2] Informação a ser alterada

@author Luciano Pereira dos Santos
@since 23/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurLoadData(cTabRegra, cFuncao, aStruct, aDados, cTabDados, aGrvVazio, aNaoGrava)
Local lRet      := .T.
Local nReg      := 0
Local nI        := 0
Local aChave    := StrToArray(FWX2Unico(cTabDados), '+')
Local cFilDados := xFilial(cTabDados)
Local cChave    := ''

Default aGrvVazio := {}
Default aNaoGrava := {}

For nReg := 1 To Len(aDados)

	If aDados[nReg][1] == cFilDados .And. aDados[nReg][2] == cTabRegra .And. aDados[nReg][3] == cFuncao
		cChave := ''
		For nI := 1 To Len(aChave)
			cChave += aDados[nReg][aScan( aStruct, {|x| x == aChave[nI]})]
		Next nI

		(cTabDados)->(DbSetOrder(1))
		If !(cTabDados)->(DbSeek(cChave))
			RecLock(cTabDados, .T.)
			For nI := 1 To Len(aStruct)
				If aScan(aNaoGrava, {|a| aStruct[nI] == a}) == 0
					(cTabDados)->(FieldPut(FieldPos(aStruct[nI]) , aDados[nReg][nI]))
				EndIf
			Next nI
			(cTabDados)->(MsUnLock())
		Else
			aTabAltera := JurChanged(cTabDados, aDados[nReg], aStruct, aChave, aGrvVazio, aNaoGrava )
			
			If Len(aTabAltera) > 0 //Houve alteração do array em relação a base de dados
				RecLock(cTabDados, .F.)
				For nI := 1 To Len(aTabAltera)
					(cTabDados)->(FieldPut(FieldPos(aTabAltera[nI][1]), aTabAltera[nI][2]))
				Next nI
				(cTabDados)->(MsUnLock())
			EndIf
		EndIf
	EndIf

Next nReg

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JurChanged(cTabela, aLinha, aStruct, aChave, aGrvVazio, aNaoGrava)
Verifica se houve alteração na linha do array com a regra em relação a base de dados

@Param  cTabela      Tabela a ser verificada 
@param  aLinha       Linha do array a ser validada
@param  aStruct      Estrutura de campos da tabela
@param  aChave       Campos da chave da tabela (esses campos não devem sofrer alteração)
@Param  aGrvVazio    Array com os campos que serão gravados somente se na base estiver vazio. Ex: Campos editaveis pelo usuário
@Param  aNaoGrava    Array com os campos que não serão gravados na base. Ex: campos de lingua que não sao do sistema.

@Obs    Por questões de performace a rotina trabalha com a linha posicionada pela rotina JurLoadData()

@Return aChanged  Array com os campos e informação que estao diferentes e devem ser atualizadas
        aChanged[N][1] Campo da estrutura
        aChanged[N][2] Informação a ser alterada

@author Luciano Pereira / Nivia Ferreira
@since 23/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurChanged(cTabela, aLinha, aStruct, aChave, aGrvVazio, aNaoGrava)
Local aChanged  := {}
Local nI        := 0
Local cCpoInfo  := ''
Local cCampo    := ''
Local lGrava    := .F.

Default aGrvVazio := {}
Default aNaoGrava := {}

For nI:= 1 To Len(aStruct)
	cCampo := aStruct[nI]
	If aScan(aChave, {|a| a == cCampo}) == 0 // Não é campo da chave
		cCpoInfo  := (cTabela)->(FieldGet(FieldPos(cCampo)))
		If lGrava := AllTrim(aLinha[nI]) != AllTrim(cCpoInfo) //Se o conteudo for diferente do array 
		
			lGrava := (aScan(aNaoGrava, {|a| cCampo == a}) == 0)  //Verifica se campo pode ser gravado
			
			If lGrava .And. (aScan(aGrvVazio, {|a| cCampo == a}) > 0) //Verifica se o campo só pode ser gravado se vazio
				 lGrava := Empty(cCpoInfo)
			EndIf
		
			If lGrava
				aAdd(aChanged, {cCampo, aLinha[nI]})
			EndIf
		EndIf
	EndIf
Next nI

Return aChanged


//-------------------------------------------------------------------
/*/{Protheus.doc} JXLOADLang(cSrtring)
Verifica a lingua e devolve o conteudo da string conforme a variavel __Language

@Param  aCampos    Campos de idioma da estrutura na ordem {'BRA','ENG','SPA'}
@Param  nRetorno   Espefica os campos no array do retorno; 1- Campo referente ao 
                   idioma dos sistema; 2 - Campos que não são do idioma do sistema
@Return aRet       Array como os campos conforme o parametro nRetorno

@author Luciano Pereira / Nivia Ferreira
@since 23/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JXLOADLang(aCampos, nRetorno)
Local aRet := {}
Local nPos := 0

Default nRetorno := 1
Default aCampos  := {}

Do Case
	Case __Language == 'PORTUGUESE'
		nPos := 1
	Case __Language == 'ENGLISH'
		nPos := 2
	Case __Language == 'SPANISH'
		nPos := 3
	OtherWise
		nPos := 2 //O Ingles é o padrão do sistema
EndCase

If nRetorno == 1
	aEval(aCampos, {|a,x| Iif(nPos == x .AND. !X3Obrigat(a), aAdd(aRet, a), Nil) } )
ElseIf nRetorno == 2
	aEval(aCampos, {|a,x| Iif(nPos != x .AND. !X3Obrigat(a), aAdd(aRet, a), Nil) } )
EndIF

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadRul
Cria registros da tabela de regras de preenchimento conforme parametros

@param 	cTabela     Tabela de referencia
@param 	cFunction 	Nome da Funcao referente as legendas. Se nao For especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.

@author Ernani Forastieri
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoadRul( cTabela, cFuncao )
Local lRet       := .T.
Local aArea      := GetArea()
Local aStruct    := {}
Local cTabDados  := 'NTZ'
Local cFilTab    := xFilial(cTabDados)

ParamType 0 Var cTabela  As Character Optional Default Alias()
ParamType 1 Var cFuncao  As Character Optional Default Space(10)

aAdd( aStruct, 'NTZ_FILIAL' )
aAdd( aStruct, 'NTZ_TABORI' )
aAdd( aStruct, 'NTZ_FUNCAO' )
aAdd( aStruct, 'NTZ_ORIGEM' )
aAdd( aStruct, 'NTZ_TABDES' )
aAdd( aStruct, 'NTZ_DESTIN' )
aAdd( aStruct, 'NTZ_TIPO'   )
aAdd( aStruct, 'NTZ_CONDIC' )
aAdd( aStruct, 'NTZ_PROPRI' )

If Len( aDadosNTZ ) == 0
	aAdd( aDadosNTZ, { cFilTab, 'NSZ', cFuncao , 'NSZ_CAREAJ', 'NSZ', 'NSZ_CSUBAR', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NSZ', cFuncao , 'NSZ_LCLIEN', 'NSZ', 'NSZ_NUMCAS', '1',  'SuperGetMV("MV_JCASO1",, "1") == "1"    ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NT2', cFuncao , 'NT2_CAGENC', 'NT2', 'NT2_CCONTA', '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NT2', cFuncao , 'NT2_CBANCO', 'NT2', 'NT2_CAGENC', '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NT9', cFuncao , 'NT9_TIPOP ', 'NT9', 'NT9_CGC   ', '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NT9', cFuncao , 'NT9_TIPOEN', 'NT9', 'NT9_CTPENV', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUQ', cFuncao , 'NUQ_CCOMAR', 'NUQ', 'NUQ_CLOC2N', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUQ', cFuncao , 'NUQ_INSTAN', 'NUQ', 'NUQ_CLOC2N', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUQ', cFuncao , 'NUQ_CCORRE', 'NUQ', 'NUQ_CADVOG', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUQ', cFuncao , 'NUQ_CLOC2N', 'NUQ', 'NUQ_CLOC3N', '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUQ', cFuncao , 'NUQ_CNATUR', 'NUQ', 'NUQ_CTIPAC', '1',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUE', cFuncao , 'NUE_CCLIEN', 'NUE', 'NUE_CLOJA' , '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUE', cFuncao , 'NUE_CLOJA ', 'NUE', 'NUE_CCASO' , '3',  'SuperGetMV("MV_JCASO1",, "1") == "1"    ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NUE', cFuncao , 'NUE_CFASE ', 'NUE', 'NUE_CTAREF', '3',  '                                        ', 'S' } )
	aAdd( aDadosNTZ, { cFilTab, 'NW2', cFuncao , 'NW2_CCLIEN', 'NW3', 'NW3_CCONTR', '3',  '                                        ', 'S' } )
EndIf

JurLoadData(cTabela, cFuncao, aStruct, aDadosNTZ, cTabDados)

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadAgp
Cria registros das tabelas de agrupamento de campos conforme parametros

@param 	cTabela     Tabela de referencia
@param 	cFunction 	Nome da Funcao referente as legendas. Se nao For especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.
@param lLoadCIni   Verifica se ira executar a carga inicial, alterando os campos necessarios

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoadAgp( cTabela, cFuncao, lLoadCIni )
Local lRet        := .T.
Local aArea       := GetArea()
Local aStruct     := {}
Local cTabDados   := 'NVX'
Local cFilTab     := xFilial( cTabDados )
Local aNaoGrava   := {}
Local aGrvVazio   := {}

Default lLoadCIni := .F. 

ParamType 0 Var cTabela  As Character Optional Default Alias()
ParamType 1 Var cFuncao  As Character Optional Default Space( 10 ) 

aAdd( aStruct, 'NVX_FILIAL' )
aAdd( aStruct, 'NVX_TABELA' )
aAdd( aStruct, 'NVX_FUNCAO' )
aAdd( aStruct, 'NVX_OUTROS' )
aAdd( aStruct, 'NVX_OUTENG' )
aAdd( aStruct, 'NVX_OUTSPA' )
aAdd( aStruct, 'NVX_INIFIM' )
aAdd( aStruct, 'NVX_TIPOUT' )
aAdd( aStruct, 'NVX_PROPRI' )

aAdd( aGrvVazio, 'NVX_OUTROS' ) //Campos que pode ser alterados pelo usuario só sao alterados se estiverem vazios
aAdd( aGrvVazio, 'NVX_OUTENG' )
aAdd( aGrvVazio, 'NVX_OUTSPA' )
aAdd( aGrvVazio, 'NVX_TIPOUT' )
aAdd( aGrvVazio, 'NVX_PROPRI' )

If Len( aDadosNVX ) == 0
	aAdd( aDadosNVX, { cFilTab, 'NT4', cFuncao, STR0021, STR0021, STR0021, '1', '1', 'S' } ) //"Dados do Andamento                      "###"Dados do Andamento                      "###"Dados do Andamento                      "
	aAdd( aDadosNVX, { cFilTab, 'NTA', cFuncao, STR0022, STR0022, STR0022, '1', '1', 'S' } ) //"Dados do Follow-up                      "###"Dados do Follow-up                      "###"Dados do Follow-up                      "
	aAdd( aDadosNVX, { cFilTab, 'NVE', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
	aAdd( aDadosNVX, { cFilTab, 'NT2', cFuncao, STR0019, STR0019, STR0019, '1', '1', 'S' } ) //"Dados Garantia / Alvará                 "###"Dados Garantia / Alvará                 "###"Dados Garantia / Alvará                 "
	aAdd( aDadosNVX, { cFilTab, 'NSY', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
	aAdd( aDadosNVX, { cFilTab, 'NT3', cFuncao, STR0020, STR0020, STR0020, '1', '1', 'S' } ) //"Dados Despesa Jurídica                  "###"Dados Despesa Jurídica                  "###"Dados Despesa Jurídica                  "
	aAdd( aDadosNVX, { cFilTab, 'NT0', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
	aAdd( aDadosNVX, { cFilTab, 'NVK', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
	aAdd( aDadosNVX, { cFilTab, 'NWU', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
	Aadd( aDadosNVX, { cFilTab ,'NUF', cFuncao, STR0018, STR0018, STR0018, '1', '1', 'S' } ) //"Dados Gerais                            "###"Dados Gerais                            "###"Dados Gerais                            "
EndIf

Chkfile(cTabDados)
if lLoadCIni
	aNaoGrava := JXLOADLang(aGrvVazio, 2) //Rertona o array com os campos referente as linguas que não são do sistema e que não serão gravados mesmo que vazios
	
	JurLoadData(cTabela, cFuncao, aStruct, aDadosNVX, cTabDados, aGrvVazio, aNaoGrava)
EndIf
// Agrupamentos
aStruct   := {}
aLinguag  := {}
cTabDados := 'NUX'
cFilTab   := xFilial(cTabDados)

aAdd( aStruct, 'NUX_FILIAL' )
aAdd( aStruct, 'NUX_TABELA' )
aAdd( aStruct, 'NUX_FUNCAO' )
aAdd( aStruct, 'NUX_CODGRP' )
aAdd( aStruct, 'NUX_GRUPO'  )
aAdd( aStruct, 'NUX_SEQ'    )
aAdd( aStruct, 'NUX_GRUENG' )
aAdd( aStruct, 'NUX_GRUSPA' )
aAdd( aStruct, 'NUX_TIPO'   )

aAdd( aGrvVazio, 'NUX_GRUPO'  )
aAdd( aGrvVazio, 'NUX_GRUENG' )
aAdd( aGrvVazio, 'NUX_GRUSPA' )
aAdd( aGrvVazio, 'NUX_TIPO' )

If Len( aDadosNUX ) == 0
	aAdd( aDadosNUX, { cFilTab, 'NT4', cFuncao, '001', STR0262, '01', STR0262, STR0262, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NTA', cFuncao, '001', STR0262, '01', STR0262, STR0262, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NVE', cFuncao, '001', STR0263, '01', STR0263, STR0263, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '001', STR0264, '01', STR0264, STR0264, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '002', STR0265, '02', STR0265, STR0265, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '003', STR0266, '03', STR0266, STR0266, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '004', STR0267, '04', STR0267, STR0267, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '005', STR0268, '05', STR0268, STR0268, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '006', STR0271, '02', STR0271, STR0271, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '007', STR0272, '03', STR0272, STR0272, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '008', STR0273, '04', STR0273, STR0273, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '009', STR0274, '09', STR0274, STR0274, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '010', STR0275, '10', STR0275, STR0275, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '011', STR0276, '11', STR0276, STR0276, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '012', STR0277, '12', STR0277, STR0277, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '013', STR0278, '13', STR0278, STR0278, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '014', STR0279, '14', STR0279, STR0279, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '015', STR0280, '15', STR0280, STR0280, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '016', STR0281, '16', STR0281, STR0281, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '017', STR0282, '17', STR0282, STR0282, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '018', STR0283, '18', STR0283, STR0283, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '019', STR0284, '19', STR0284, STR0284, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '020', STR0285, '20', STR0285, STR0285, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NSY', cFuncao, '021', STR0286, '21', STR0286, STR0286, '2' } )
	aAdd( aDadosNUX, { cFilTab, 'NWU', cFuncao, '001', STR0287, '01', STR0287, STR0287, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NWU', cFuncao, '002', STR0288, '02', STR0288, STR0288, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NWU', cFuncao, '003', STR0289, '03', STR0289, STR0289, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NWU', cFuncao, '004', STR0290, '04', STR0290, STR0290, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NWU', cFuncao, '005', STR0291, '05', STR0291, STR0291, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '001', STR0264, '01', STR0264, STR0264, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '002', STR0265, '02', STR0265, STR0265, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '003', STR0266, '03', STR0266, STR0266, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '004', STR0267, '04', STR0267, STR0267, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '005', STR0268, '05', STR0268, STR0268, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '006', STR0271, '02', STR0271, STR0271, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '007', STR0272, '03', STR0272, STR0272, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '008', STR0273, '04', STR0273, STR0273, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '009', STR0274, '09', STR0274, STR0274, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '010', STR0275, '10', STR0275, STR0275, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '011', STR0276, '11', STR0276, STR0276, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '012', STR0277, '12', STR0277, STR0277, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '013', STR0278, '13', STR0278, STR0278, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '014', STR0279, '14', STR0279, STR0279, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '015', STR0280, '15', STR0280, STR0280, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '016', STR0281, '16', STR0281, STR0281, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '017', STR0282, '17', STR0282, STR0282, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '018', STR0283, '18', STR0283, STR0283, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '019', STR0284, '19', STR0284, STR0284, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '020', STR0285, '20', STR0285, STR0285, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NZ1', cFuncao, '021', STR0286, '21', STR0286, STR0286, '1' } )
	Aadd( aDadosNUX, { cFilTab, 'NUF', cFuncao, '001', STR0292, '01', STR0292, STR0292, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NT3', cFuncao, '001', STR0262, '01', STR0262, STR0262, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NT0', cFuncao, '001', '     ', '01', '     ', '     ', '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NT2', cFuncao, '001', STR0262, '01', STR0262, STR0262, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NVK', cFuncao, '001', STR0269, '01', STR0269, STR0269, '1' } )
	aAdd( aDadosNUX, { cFilTab, 'NVK', cFuncao, '002', STR0270, '02', STR0270, STR0270, '1' } )
EndIf

Chkfile(cTabDados)
If lLoadCIni
	JurLoadData(cTabela, cFuncao, aStruct, aDadosNUX, cTabDados, aGrvVazio)
EndIf
// Campos dos Agrupamentos
aStruct   := {}
aGrvVazio  := {}
cTabDados := 'NUY'
cFilTab   := xFilial(cTabDados)

aAdd( aStruct, 'NUY_FILIAL' )
aAdd( aStruct, 'NUY_TABELA' )
aAdd( aStruct, 'NUY_FUNCAO' )
aAdd( aStruct, 'NUY_CODGRP' )
aAdd( aStruct, 'NUY_CAMPO' )

If Len(  aDadosNUY ) == 0
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_CMOPED' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_DMOPED' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PEDATA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PEINVL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PESOMA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PEVLR ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PEVLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_DTJURO' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_PERMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_CCOMON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_DCOMON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_DTMULT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_MULATU' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_CCORPE' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '001', 'NSY_CJURPE' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_MULAT1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_CMOIN1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_DMOIN1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_SAV1  ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_SV1   ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_V1DATA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_V1INVL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_V1SOMA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_V1VLR ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_V1VLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_DTJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_PERMU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_CFCOR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_DFCOR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_DTMUL1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_CCORP1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '002', 'NSY_CJURP1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_CCORPC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_CJURPC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_CMOCON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_DMOCON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_DTCONT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_INECON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_SLCONA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_SLCONT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_SOMCON' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_VLCONA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_VLCONT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_DTJURC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_PERMUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_CFCORC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_DFCORC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_DTMULC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_MULATC' } )
	DbSelectArea("NSY")
	If ColumnPos('NSY_REDUT') > 0
		aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_REDUT'  } )
		aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '003', 'NSY_VLREDU' } )
	EndIf
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_CMOIN2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_DMOIN2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_SAV2  ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_SV2   ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_V2DATA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_V2INVL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_V2SOMA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_V2VLR ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_V2VLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_DTJUR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_PERMU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_CFCOR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_DFCOR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_DTMUL2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_MULAT2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_CCORP2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '004', 'NSY_CJURP2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_CCORPT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_CJURPT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_CMOTRI' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_DMOTRI' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_SATR  ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_STR   ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_TRDATA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_TRVLR ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_DTMUTR' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_PERMUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_TRINVL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_TRSOMA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_TRVLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_DTJURT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_CFCORT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_DFCORT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '005', 'NSY_VLRMUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_CALMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_DTAMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_DTINCM' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_CMOEMU' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_SIMBMM' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_VLRMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_MUATUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_CFCMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_DFCMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_CCORMP' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '006', 'NSY_CJURMP' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_CCORJP' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_CJURJP' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_CJUROS' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_DTJURJ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_DTINJU' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_CMOEJU' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_SIMBMJ' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_VLRJUR' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_JURATU' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_FCJURO' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '007', 'NSY_DFCJUR' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '008', 'NSY_SPE'    } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '008', 'NSY_SAPE'   } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '008', 'NSY_TOTPED' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '008', 'NSY_TOPEAT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_CCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_LCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_DCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_NUMCAS' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_DCASO'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_PATIVO' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_PPASSI' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_DSITUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_NUMPRO' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '009', 'NSY_DTDIST' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_DTMUT1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_CAMUL1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_CFJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_DFCMU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_DTINC1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_CMOEM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_SIMBM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_VLRMU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_MUATU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_CCORM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '010', 'NSY_CJURM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_CCORJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_CJURJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_CJURO1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_FCJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_DFCJU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_DTJU1'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_DTINJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_CMOEJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_SIMBJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_VLRJU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '011', 'NSY_JUATU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '012', 'NSY_TOTOR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '012', 'NSY_TOTAT1' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '012', 'NSY_SV1'    } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '012', 'NSY_SAV1'   } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_CAMUL2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_CFMUL2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_DFCMU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_DTMUT2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_DTINC2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_CMOEM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_SIMBM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_CCORM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_CJURM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_MUATU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '013', 'NSY_VLRMU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_VLRJU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_JUATU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_CCORJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_CJURJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_CJURO2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_FCJUR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_DFCJU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_DTJU2'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_DTINJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_CMOEJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '014', 'NSY_SIMBJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '015', 'NSY_TOTOR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '015', 'NSY_TOTAT2' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '015', 'NSY_SV2'    } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '015', 'NSY_SAV2'   } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_CAMULT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_CFMULT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_DFCMUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_DTMUTT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_DTINCT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_CMOEMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_SIMBMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_VLRMT'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_MUATT'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_CCORMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '016', 'NSY_CJURMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_CCORJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_CJURJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_CJUROT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_FCJURT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_FCJURT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_DFCJUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_DTJUT'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_DTINJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_CMOEJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_SIMBJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_VLRJUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '017', 'NSY_JUATUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '018', 'NSY_TOTORT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '018', 'NSY_TOTATT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '018', 'NSY_STR'    } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '018', 'NSY_SATR'   } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_CAMULC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_CFMULC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_DFCMUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_DTMUTC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_DTINCC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_CMOEMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_SIMBMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_VLRMUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_MUATC'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_CCORMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '019', 'NSY_CJURMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_CCORJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_CJURJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_CJUROC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_FCJURC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_DFCJUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_DTJUC'  } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_DTINJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_CMOEJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_SIMBJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_JUATUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '020', 'NSY_CLRJUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '021', 'NSY_TOTORC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '021', 'NSY_TOTATC' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '021', 'NSY_SLCONT' } )
	aAdd( aDadosNUY, { cFilTab, 'NSY', cFuncao, '021', 'NSY_SLCONA' } )

	aAdd( aDadosNUY, { cFilTab, 'NT0', cFuncao, '001', 'NT0_COD   ' } )
	aAdd( aDadosNUY, { cFilTab, 'NT0', cFuncao, '001', 'NT0_NOME  ' } )

	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_CCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_DCASO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_DCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_DSITUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_DTDIST' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_LCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_NUMCAS' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_NUMPRO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_PATIVO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT2', cFuncao, '001', 'NT2_PPASSI' } )

	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_CCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_DCASO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_DCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_DSITUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_DTDIST' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_LCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_NUMCAS' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_NUMPRO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_PATIVO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT3', cFuncao, '001', 'NT3_PPASSI' } )

	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_CCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_DCASO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_DCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_DSITUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_DTDIST' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_LCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_NUMCAS' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_NUMPRO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_PATIVO' } )
	aAdd( aDadosNUY, { cFilTab, 'NT4', cFuncao, '001', 'NT4_PPASSI' } )

	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_CCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_DCASO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_DCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_DSITUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_DTDIST' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_LCLIEN' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_NUMCAS' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_NUMPRO' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_PATIVO' } )
	aAdd( aDadosNUY, { cFilTab, 'NTA', cFuncao, '001', 'NTA_PPASSI' } )

	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CPART1' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DPART1' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CESCRI' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DESCRI' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_TPHORA' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DAREAJ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DTPLAN' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DESPAD' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_VLHORA' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_EXITO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_VIRTUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CIDIO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DIDIO ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DSPDIS' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CTABH ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DTABH ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CTABS ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DTABS ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_OBSFAT' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_REDFAT' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_LANTS ' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_LANDSP' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_LANTAB' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_ENCDES' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_ENCHON' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_ENCTAB' } )
	aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_SIGLA1' } )
	If ( NVE->( FieldPos( "NVE_SIGLA5" )) > 0 )
		aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_SIGLA5' } )
		aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_CPART5' } )
		aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_DPART5' } )
	EndIf
	If ( NVE->( ColumnPos( "NVE_SITCAD" )) > 0 )
		aAdd( aDadosNUY, { cFilTab, 'NVE', cFuncao, '001', 'NVE_SITCAD' } )
	EndIf
	
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '001', 'NVK_CCORR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '001', 'NVK_CLOJA1' } )
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '001', 'NVK_DCORR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '002', 'NVK_CCORR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '002', 'NVK_CLOJA2' } )
	aAdd( aDadosNUY, { cFilTab, 'NVK', cFuncao, '002', 'NVK_DCORR2' } )

	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTFIMP' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTINIO' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTINIP' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTPROT' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTRENI' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_DTVENO' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_NUM'    } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_PRAZOT' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_PRAZOR' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_PRAZOM' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '001', 'NWU_TPPRA'  } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '002', 'NWU_DTSTAT' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '002', 'NWU_STATUS' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '003', 'NWU_DTSTSA' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '003', 'NWU_STATSA' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '004', 'NWU_DTSTSC' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '004', 'NWU_STATSC' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '005', 'NWU_DTSTSG' } )
	aAdd( aDadosNUY, { cFilTab, 'NWU', cFuncao, '005', 'NWU_STTUSC' } )

	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_PEVLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_V1VLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_VLCONA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_V2VLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_TRVLRA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_CFCOR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_DFCOR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_CCOMON' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_DCOMON' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_CFCORC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_DFCORC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_CFCOR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_DFCOR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_CFCORT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_DFCORT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_MULATU' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_MULAT1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_VLRMUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '006', 'NZ1_MUATUA' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '007', 'NZ1_JURATU' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '006', 'NZ1_CFCMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '006', 'NZ1_DFCMUL' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '007', 'NZ1_FCJURO' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '007', 'NZ1_DFCJUR' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '010', 'NZ1_CFJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '010', 'NZ1_DFJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '010', 'NZ1_MUATU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '011', 'NZ1_FCJUR1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '011', 'NZ1_DFCJU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '011', 'NZ1_JUATU1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '013', 'NZ1_CFMUL2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '013', 'NZ1_DFMUL2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_MULAT2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '014', 'NZ1_FCJUR2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '014', 'NZ1_DFCJU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '016', 'NZ1_CFMULT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '016', 'NZ1_DFMULT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '016', 'NZ1_MUATT'  } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '017', 'NZ1_FCJURT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '017', 'NZ1_DFCJUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '017', 'NZ1_JUATUT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '019', 'NZ1_CFMULC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '019', 'NZ1_DFMULC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '019', 'NZ1_MUATC'  } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '020', 'NZ1_FCJURC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '020', 'NZ1_DFCJUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '020', 'NZ1_JUATUC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_CCORPE' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '001', 'NZ1_CJURPE' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '006', 'NZ1_CCORMP' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '006', 'NZ1_CJURMP' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '007', 'NZ1_CCORJP' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '007', 'NZ1_CJURJP' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_CCORP1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '002', 'NZ1_CJURP1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_CCORPC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_CJURPC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_CCORP2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '004', 'NZ1_CJURP2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_CCORPT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '005', 'NZ1_CJURPT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '010', 'NZ1_CCORM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '010', 'NZ1_CJURM1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '011', 'NZ1_CCORJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '011', 'NZ1_CJURJ1' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '013', 'NZ1_CCORM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '013', 'NZ1_CJURM2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '014', 'NZ1_CCORJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '014', 'NZ1_CJURJ2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '016', 'NZ1_CCORMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '016', 'NZ1_CJURMT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '017', 'NZ1_CCORJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '017', 'NZ1_CJURJT' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '019', 'NZ1_CCORMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '019', 'NZ1_CJURMC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '003', 'NZ1_MULATC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '020', 'NZ1_CCORJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '020', 'NZ1_CJURJC' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '013', 'NZ1_MUATU2' } )
	aAdd( aDadosNUY, { cFilTab, 'NZ1', cFuncao, '014', 'NZ1_JUATU2' } )

	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_CESCR'  } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_CFATU'  } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DTEMIF' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DTVENF' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_CMOEDA' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DMOEDA' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_VLFATH' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_VLFATD' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_VLACRE' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_VLDESC' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFIH' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFFH' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFID' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFFD' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFIT' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_DREFFT' } )
	aAdd( aDadosNUY, { cFilTab, 'NUF', cFuncao, '001', 'NUF_PERFAT' } )
EndIf

Chkfile(cTabDados)
If lLoadCIni
	JurLoadData(cTabela, cFuncao, aStruct, aDadosNUY, cTabDados)
endIf
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadAsJ
Cria registros das tabelas de agrupamento de campos conforme parametros

@param 	cTabela     Tabela de referencia
@param 	cFunction 	Nome da Funcao referente as legendas. Se nao For especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.

@author André Spirigoni Pinto
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoadAsJ(lAutomato)
Local aArea     := GetArea()
Local aAreaNT9  := NT9->( GetArea() )
Local aStruct   := {}
Local aDadosNYB := {}
Local aDadosNYC := {}
Local aApagaNYC := {}
Local aDadosNZ6 := {}
Local aDadosNVJ := {}
Local aDadosNUZ := {}
Local aChave    := {}
Local cChave    := ''
Local nReg      := 0
Local nI        := 0
Local lRet      := .T.
Local cAlias    := 'NYB'
Local cFilTab   := xFilial( cAlias )
Local lVazio    := .T.
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Default lAutomato := .F.

cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("NYB") + " NYB "
cQuery += " WHERE NYB.NYB_FILIAL  = '" + xFilial("NYB") + "' " + CRLF
cQuery += " AND NYB.D_E_L_E_T_ = ' ' " + CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
(cAliasQry)->( dbGoTop() )

If !(cAliasQry)->( EOF())
	lVazio := .F.
EndIf

//-- Validação para automação
If lAutomato
	lVazio := .T.
Endif

(cAliasQry)->( dbCloseArea())

aChave := StrToArray( FWX2Unico(cAlias), '+' )

aAdd( aStruct, 'NYB_FILIAL' )
aAdd( aStruct, 'NYB_COD' )
aAdd( aStruct, 'NYB_DESC' )
aAdd( aStruct, 'NYB_CORIG' )

If lVazio
	ProcRegua(8)
	IncProc(STR0046)//'Criando Assuntos Juridicos'
EndIf

If Len( aDadosNYB ) == 0

	aAdd( aDadosNYB, { cFilTab, '001', STR0035, '' } )//'Contencioso'
	aAdd( aDadosNYB, { cFilTab, '002', STR0036, '' } )//'Criminal'
	aAdd( aDadosNYB, { cFilTab, '003', STR0037, '' } )//'Administrativo'
	aAdd( aDadosNYB, { cFilTab, '004', STR0038, '' } )//'Cade'
	aAdd( aDadosNYB, { cFilTab, '005', STR0039, '' } )//'Consultivo'
	aAdd( aDadosNYB, { cFilTab, '006', STR0040, '' } )//'Contratos'
	aAdd( aDadosNYB, { cFilTab, '007', STR0041, '' } )//'Procurações'
	aAdd( aDadosNYB, { cFilTab, '008', STR0042, '' } )//'Societário'
	aAdd( aDadosNYB, { cFilTab, '009', STR0043, '' } )//'Ofícios'
	aAdd( aDadosNYB, { cFilTab, '010', STR0044, '' } )//'Licitações'
	aAdd( aDadosNYB, { cFilTab, '011', STR0045, '' } )//'Marcas e Patentes'
	aAdd( aDadosNYB, { cFilTab, '012', STR0095, '' } )//'Despesas'
	aAdd( aDadosNYB, { cFilTab, '013', STR0312, '' } )//'NIP'

EndIf

For nReg := 1 To Len( aDadosNYB )

	If aDadosNYB[nReg][1] == xFilial( 'NYB' )

		cChave := ''
		For nI := 1 To Len( aChave )
			cChave += aDadosNYB[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
		Next

		If !lAutomato
			( cAlias )->( dbSetOrder( 1 ) )
			If !( cAlias )->( dbSeek ( cChave ) )
				RecLock( cAlias, .T.  )
				For nI := 1 To Len( aStruct )
					( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNYB[nReg][nI] ) )
				Next
				MsUnLock()
			EndIf
		EndIf
	EndIf

Next

If lVazio
	IncProc(STR0047)//'Finalizando criação de assuntos juridicos'
	IncProc(STR0048)//'Adicionando Guias'
EndIf

// Tabelas
aStruct  := {}
aChave   := {}
cChave   := ''
cAlias   := 'NYC'
cFilTab  := xFilial( cAlias )

aChave := StrToArray( FWX2Unico(cAlias), '+' )

aAdd( aStruct, 'NYC_FILIAL' )
aAdd( aStruct, 'NYC_CTPASJ' )
aAdd( aStruct, 'NYC_TABELA' )
aAdd( aStruct, 'NYC_DTABEL' )

If Len( aDadosNYC ) == 0
	aAdd( aDadosNYC, { cFilTab, '001', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
	aAdd( aDadosNYC, { cFilTab, '001', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '001', 'NYP', AllTrim( JA023TIT('NYP') ) } )
	aAdd( aDadosNYC, { cFilTab, '002', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
	aAdd( aDadosNYC, { cFilTab, '002', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '003', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
	aAdd( aDadosNYC, { cFilTab, '003', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '003', 'NYP', AllTrim( JA023TIT('NYP') ) } )
	aAdd( aDadosNYC, { cFilTab, '004', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
	aAdd( aDadosNYC, { cFilTab, '004', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '004', 'NYP', AllTrim( JA023TIT('NYP') ) } )
	aAdd( aDadosNYC, { cFilTab, '006', 'NXY', AllTrim( JA023TIT('NXY') ) } )
	aAdd( aDadosNYC, { cFilTab, '006', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '007', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '008', 'NYJ', AllTrim( JA023TIT('NYJ') ) } )
	aAdd( aDadosNYC, { cFilTab, '008', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '009', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
	aAdd( aDadosNYC, { cFilTab, '009', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '010', 'NXY', AllTrim( JA023TIT('NXY') ) } )
	aAdd( aDadosNYC, { cFilTab, '010', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '011', 'NT9', AllTrim( JA023TIT('NT9') ) } )
	aAdd( aDadosNYC, { cFilTab, '013', 'NT9', AllTrim( JA023TIT('NT9') ) } )
EndIf

aApagaNYC := {}

If Len( aApagaNYC ) == 0
	aAdd( aApagaNYC, { cFilTab, '008', 'NUQ', AllTrim( JA023TIT('NUQ') ) } )
Endif

//Apaga itens antigos que devem ser apagados
For nReg := 1 To Len( aApagaNYC )

	cChave := ''
	For nI := 1 To Len( aChave )
		cChave += aApagaNYC[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
	Next

	If !lAutomato
		( cAlias )->( dbSetOrder( 1 ) )
		If ( cAlias )->( dbSeek ( cChave ) )
			RecLock( cAlias, .F. )
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
Next

For nReg := 1 To Len( aDadosNYC )

	cChave := ''
	For nI := 1 To Len( aChave )
		cChave += aDadosNYC[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
	Next

	If !lAutomato
		( cAlias )->( dbSetOrder( 1 ) )
		If !( cAlias )->( dbSeek ( cChave ) )
			RecLock( cAlias, .T. )
			For nI := 1 To Len( aStruct )
				( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNYC[nReg][nI] ) )
			Next
			MsUnLock()
		EndIf
	EndIf
Next

// Tabelas
aStruct  := {}
aChave   := {}
cChave   := ''
cAlias   := 'NZ6'
cFilTab  := xFilial( cAlias )

aChave := StrToArray( FWX2Unico(cAlias), '+' )

aAdd( aStruct, 'NZ6_FILIAL' )
aAdd( aStruct, 'NZ6_TIPOAS' )
aAdd( aStruct, 'NZ6_CPARAM' )
aAdd( aStruct, 'NZ6_CONTEU' )
aAdd( aStruct, 'NZ6_TIPO'	)

//Incluir parametro MV_JNUMCNJ apenas onde tem a tabela NUQ
nReg := 1
While nReg > 0
 	nReg := AscanX(aDadosNYC, {|x| x[3] == "NUQ"}, nReg)

	If nReg > 0
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JNUMCNJ", "2", "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JANDAUT", "2", "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JTPANAU", "1", "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JATOAUT", "" , "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JANDEXC", "1", "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JAJUENC", "" , "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYC[nReg][2], "MV_JFORVAR", "1" ,"C"} )

		nReg++
	EndIf
EndDo

For nI := 1 to Len(aDadosNYB)
	If Empty(AllTrim(JurgetDados('NZ6',1,xFilial('NZ6')+aDadosNYB[nI][2]+"MV_JPESPEC","NZ6_TIPOAS")))
		Aadd( aDadosNZ6, {cFilTab, aDadosNYB[nI][2], "MV_JPESPEC", "2", "C"} )
	EndIf
	If aDadosNYB[nI][2] $ "006|007|008" .And. Empty(AllTrim(JurgetDados('NZ6',1,xFilial('NZ6')+aDadosNYB[nI][2]+"MV_JAREAC","NZ6_TIPOAS"))) // Somente para contratos, procurações e societário
		Aadd( aDadosNZ6, {cFilTab, aDadosNYB[nI][2], "MV_JAREAC", "", "C"} )
	EndIf

	If aDadosNYB[nI][2] $ "001|002|003|004|009"
		Aadd( aDadosNZ6, {cFilTab, aDadosNYB[nI][2], "MV_JVLRCO" , SuperGetMV("MV_JVLRCO" ,, "1"), "C"} )
		Aadd( aDadosNZ6, {cFilTab, aDadosNYB[nI][2], "MV_JVLPROV", SuperGetMV("MV_JVLPROV",, "1"), "C"} )
	EndIF

Next

For nReg := 1 To Len( aDadosNZ6 )

	cChave := ''
	For nI := 1 To Len( aChave )
		cChave += aDadosNZ6[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
	Next

	If !lAutomato
		( cAlias )->( dbSetOrder( 1 ) )
		If !( cAlias )->( dbSeek ( cChave ) )
			RecLock( cAlias, .T. )
			For nI := 1 To Len( aStruct )
				( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNZ6[nReg][nI] ) )
			Next
			MsUnLock()
		EndIf
	EndIf
Next nReg

If lVazio

	IncProc(STR0049)//'Finalizando guias'
	IncProc(STR0050)//'Vinculando Pesquisas aos assuntos jurídicos'

	// Pesquisas
	aStruct  := {}
	aChave   := {}
	cChave   := ''
	cAlias   := 'NVJ'
	cFilTab  := xFilial( cAlias )

	aChave := StrToArray( FWX2Unico(cAlias), '+' )
	
	aAdd( aStruct, 'NVJ_FILIAL' )
	aAdd( aStruct, 'NVJ_CASJUR' )
	aAdd( aStruct, 'NVJ_CPESQ'  )

	If Len( aDadosNVJ ) == 0
		//aAdd( aDadosNVJ, { cFilTab, '001', JurGetDados("NVG", 5, xFilial("NVG") + STR0035, "NVG_CPESQ" ) } )//'Contencioso'
		aAdd( aDadosNVJ, { cFilTab, '001', '001' } )//'Contencioso'
		aAdd( aDadosNVJ, { cFilTab, '001', '002' } )//'Contencioso-Fup'
		aAdd( aDadosNVJ, { cFilTab, '002', '003' } )//'Criminal'
		aAdd( aDadosNVJ, { cFilTab, '002', '004' } )//'Criminal-Fup'
		aAdd( aDadosNVJ, { cFilTab, '003', '005' } )//'Administrativo'
		aAdd( aDadosNVJ, { cFilTab, '003', '006' } )//'Administrativo-Fup'
		aAdd( aDadosNVJ, { cFilTab, '004', '007' } )//'Cade'
		aAdd( aDadosNVJ, { cFilTab, '004', '008' } )//'Cade-Fup'
		aAdd( aDadosNVJ, { cFilTab, '005', '009' } )//'Consultivo'
		aAdd( aDadosNVJ, { cFilTab, '005', '010' } )//'Consultivo-Fup'
		aAdd( aDadosNVJ, { cFilTab, '006', '011' } )//'Contratos'
		aAdd( aDadosNVJ, { cFilTab, '006', '012' } )//'Contratos-Fup'
		aAdd( aDadosNVJ, { cFilTab, '007', '013' } )//'Procurações'
		aAdd( aDadosNVJ, { cFilTab, '007', '014' } )//'Procurações-Fup'
		aAdd( aDadosNVJ, { cFilTab, '008', '015' } )//'Societário'
		aAdd( aDadosNVJ, { cFilTab, '008', '016' } )//'Societário-Fup'
		aAdd( aDadosNVJ, { cFilTab, '009', '017' } )//'Ofícios'
		aAdd( aDadosNVJ, { cFilTab, '009', '018' } )//'Ofícios-Fup'
		aAdd( aDadosNVJ, { cFilTab, '010', '019' } )//'Licitações'
		aAdd( aDadosNVJ, { cFilTab, '010', '020' } )//'Licitações-Fup'
		aAdd( aDadosNVJ, { cFilTab, '011', '021' } )//'Marcas e Patentes'
		aAdd( aDadosNVJ, { cFilTab, '011', '022' } )//'Marcas e Patentes-Fup'

		aAdd( aDadosNVJ, { cFilTab, '001', '023' } )//'Contencioso-Desp'
		aAdd( aDadosNVJ, { cFilTab, '002', '024' } )//'Criminal-Desp'
		aAdd( aDadosNVJ, { cFilTab, '003', '025' } )//'Administrativo-Desp'
		aAdd( aDadosNVJ, { cFilTab, '004', '026' } )//'Cade-Desp'
		aAdd( aDadosNVJ, { cFilTab, '005', '027' } )//'Consultivo-Desp'
		aAdd( aDadosNVJ, { cFilTab, '006', '028' } )//'Contratos-Desp'
		aAdd( aDadosNVJ, { cFilTab, '007', '029' } )//'Procurações-Desp'
		aAdd( aDadosNVJ, { cFilTab, '008', '030' } )//'Societário-Desp'
		aAdd( aDadosNVJ, { cFilTab, '009', '031' } )//'Ofícios-Desp'
		aAdd( aDadosNVJ, { cFilTab, '010', '032' } )//'Licitações-Desp'
		aAdd( aDadosNVJ, { cFilTab, '011', '033' } )//'Marcas e Patentes-Desp'
	EndIf

	For nReg := 1 To Len( aDadosNVJ )

		cChave := ''
		For nI := 1 To Len( aChave )
			cChave += aDadosNVJ[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
		Next

		If !lAutomato
			( cAlias )->( dbSetOrder( 1 ) )
			If !( cAlias )->( dbSeek ( cChave ) )
				RecLock( cAlias, .T. )
				For nI := 1 To Len( aStruct )
					( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNVJ[nReg][nI] ) )
				Next
				MsUnLock()
			EndIf
		EndIf
	Next

	If !lAutomato
		J160CarIni() // Carga inicial de grid de pesquisa.
	EndIf

	IncProc(STR0051)//'Concluindo vínculo'

	IncProc(STR0052)//'Adicionando Campos'

	// Campos
	aStruct  := {}
	aChave   := {}
	cChave   := ''
	cAlias   := 'NUZ'
	cFilTab  := xFilial( cAlias )

	aChave := StrToArray( FWX2Unico(cAlias), '+' )
	
	aAdd( aStruct, 'NUZ_FILIAL' )
	aAdd( aStruct, 'NUZ_CAMPO' )
	aAdd( aStruct, 'NUZ_DESCPO' )
	aAdd( aStruct, 'NUZ_CTAJUR' )

	If Len( aDadosNUZ ) == 0

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CAREAJ', RetTitle( 'NSZ_CAREAJ' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DAREAJ', RetTitle( 'NSZ_DAREAJ' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', STR0065                 , '001' } ) //'Cód Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', STR0066                 , '001' } ) //'Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CFCORR', STR0071				  , '001' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DFCORR', STR0071				  , '001' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCAU', STR0072				  , '001' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCAU', STR0072				  , '001' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENV', STR0073				  , '001' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENV', STR0073				  , '001' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOPRO', STR0074				  , '001' } ) //"Moeda Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOPRO', STR0074				  , '001' } ) //"Moeda Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COBJET', RetTitle( 'NSZ_COBJET' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DOBJET', RetTitle( 'NSZ_DOBJET' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', STR0067                 , '001' } ) //'Sigla Resp'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', STR0068                 , '001' } ) //'Responsável'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA2', RetTitle( 'NSZ_SIGLA2' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART2', RetTitle( 'NSZ_DPART2' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA3', RetTitle( 'NSZ_SIGLA3' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART3', RetTitle( 'NSZ_DPART3' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CPROGN', STR0075				  , '001' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPROGN', STR0075				  , '001' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CRITO' , RetTitle( 'NSZ_CRITO' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DRITO' , RetTitle( 'NSZ_DRITO' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCAUS', STR0076				  , '001' } ) //"Data Valor Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENVO', STR0077				  , '001' } ) //"Data Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTPROV', STR0078				  , '001' } ) //"Data Valor Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '001' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_JUSTIF', STR0087				  , '001' } ) //"Justificativa Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LITISC', RetTitle( 'NSZ_LITISC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SITUAC', RetTitle( 'NSZ_SITUAC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VACAUS', STR0080				  , '001' } ) //"Valor Causa Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VAENVO', STR0081				  , '001' } ) //"Valor Envolvido Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VAPROV', STR0082				  , '001' } ) //"Valor Provisão Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VCPROV', STR0083				  , '001' } ) //"Correção Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VJPROV', STR0084				  , '001' } ) //"Juros Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCAUS', RetTitle( 'NSZ_VLCAUS' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLENVO', STR0085				  , '001' } ) //"Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLPROV', STR0086				  , '001' } ) //"Valor Provisão"
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CAJURI', RetTitle( 'NT9_CAJURI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CFORNE', RetTitle( 'NT9_CFORNE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LFORNE', RetTitle( 'NT9_LFORNE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_COD'   , RetTitle( 'NT9_COD' )   , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_OBSERV', RetTitle( 'NT9_OBSERV' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_PRINCI', RetTitle( 'NT9_PRINCI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TFORNE', RetTitle( 'NT9_TFORNE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOCL', RetTitle( 'NT9_TIPOCL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOEN', RetTitle( 'NT9_TIPOEN' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOP' , RetTitle( 'NT9_TIPOP' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTADM' , RetTitle( 'NT9_DTADM' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTDEMI', RetTitle( 'NT9_DTDEMI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CCRGDP', RetTitle( 'NT9_CCRGDP' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DCRGDP', RetTitle( 'NT9_DCRGDP' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CCGECL', RetTitle( 'NT9_CCGECL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DCGECL', RetTitle( 'NT9_DCGECL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENDECL', RetTitle( 'NT9_ENDECL' ), '001' } )

		DbSelectArea("NT9")
		If ColumnPos('NT9_MATRIC') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NT9_MATRIC', RetTitle( 'NT9_MATRIC' ), '001' } )
		EndIf
		If ColumnPos('NT9_CDPENV') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NT9_CDPENV', RetTitle( 'NT9_CDPENV' ), '001' } )
			aAdd( aDadosNUZ, { cFilTab, 'NT9_DDPENV', RetTitle( 'NT9_DDPENV' ), '001' } )
		EndIf

		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CADVOG', RetTitle( 'NUQ_CADVOG' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DADVOG', RetTitle( 'NUQ_DADVOG' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCOMAR', RetTitle( 'NUQ_CCOMAR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCOMAR', RetTitle( 'NUQ_DCOMAR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCORRE', RetTitle( 'NUQ_CCORRE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_LCORRE', RetTitle( 'NUQ_LCORRE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCORRE', RetTitle( 'NUQ_DCORRE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CDECIS', RetTitle( 'NUQ_CDECIS' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DDECIS', RetTitle( 'NUQ_DDECIS' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DTDECI', RetTitle( 'NUQ_DTDECI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC2N', RetTitle( 'NUQ_CLOC2N' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC2N', RetTitle( 'NUQ_DLOC2N' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC3N', RetTitle( 'NUQ_CLOC3N' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC3N', RetTitle( 'NUQ_DLOC3N' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CNATUR', RetTitle( 'NUQ_CNATUR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DNATUR', RetTitle( 'NUQ_DNATUR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CTIPAC', RetTitle( 'NUQ_CTIPAC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DTIPAC', RetTitle( 'NUQ_DTIPAC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DTDIST', RetTitle( 'NUQ_DTDIST' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DTEXEC', RetTitle( 'NUQ_DTEXEC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_EXECUC', RetTitle( 'NUQ_EXECUC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_INSATU', RetTitle( 'NUQ_INSATU' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_INSTAN', RetTitle( 'NUQ_INSTAN' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMPRO', RetTitle( 'NUQ_NUMPRO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_OBSERV', RetTitle( 'NUQ_OBSERV' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATA',   RetTitle( 'NYP_DATA'   ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CMOEDA', RetTitle( 'NYP_CMOEDA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_VALOR',  RetTitle( 'NYP_VALOR'  ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALI', RetTitle( 'NYP_DATALI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_TIPO',   RetTitle( 'NYP_TIPO'   ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CSTATU', RetTitle( 'NYP_CSTATU' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATAIN', RetTitle( 'NYP_DATAIN' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUIN',  RetTitle( 'NYP_USUIN'  ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUAL',  RetTitle( 'NYP_USUAL'  ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DTINCL', RetTitle( 'NT4_DTINCL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_USUINC', RetTitle( 'NT4_USUINC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DTALTE', RetTitle( 'NT4_DTALTE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_USUALT', RetTitle( 'NT4_USUALT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_HORA'  , RetTitle( 'NTA_HORA' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DRESUL', RetTitle( 'NTA_DRESUL' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_CPREPO', RetTitle( 'NTA_CPREPO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DPREPO', RetTitle( 'NTA_DPREPO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_CATO'  , RetTitle( 'NTA_CATO' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DATO'  , RetTitle( 'NTA_DATO' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_CFASE' , RetTitle( 'NTA_CFASE' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DFASE' , RetTitle( 'NTA_DFASE' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTORIG', RetTitle( 'NTA_DTORIG' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTALT' , RetTitle( 'NTA_DTALT' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUALT', RetTitle( 'NTA_USUALT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUCON', RetTitle( 'NTA_USUCON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTCON' , RetTitle( 'NTA_DTCON' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_CADVCR', RetTitle( 'NTA_CADVCR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DADVCR', RetTitle( 'NTA_DADVCR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTLIMT', RetTitle( 'NTA_DTLIMT' ), '001' } )
		
		DbSelectArea("NSZ")
		If ColumnPos("NSZ_VRDPRO") > 0
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_VRDPRO', RetTitle( 'NSZ_VRDPRO' ), '001' } )
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_VRDPOS', RetTitle( 'NSZ_VRDPOS' ), '001' } )
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_VRDREM', RetTitle( 'NSZ_VRDREM' ), '001' } )
		EndIf
		//Carga NSY
		//Detalhe
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPEVLR', RetTitle( 'NSY_CPEVLR' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPEVLR', RetTitle( 'NSY_DPEVLR' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPROG' , RetTitle( 'NSY_CPROG' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPROG' , RetTitle( 'NSY_DPROG' ) , '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CENVOL', RetTitle( 'NSY_CENVOL' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DENVOL', RetTitle( 'NSY_DENVOL' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DESC'  , RetTitle( 'NSY_DESC' )  , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTULAT', RetTitle( 'NSY_DTULAT' ), '001' } )
		
		//processo
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PATIVO', RetTitle( 'NSY_PATIVO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PPASSI', RetTitle( 'NSY_PPASSI' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DSITUA', RetTitle( 'NSY_DSITUA' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_NUMPRO', RetTitle( 'NSY_NUMPRO' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTDIST', RetTitle( 'NSY_DTDIST' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CINSTA', RetTitle( 'NSY_CINSTA' ), '001' } ) 
	
		//pedidos
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCOMON', RetTitle( 'NSY_CCOMON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEDATA', RetTitle( 'NSY_PEDATA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURO', RetTitle( 'NSY_DTJURO' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOPED', RetTitle( 'NSY_CMOPED' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOPED', RetTitle( 'NSY_DMOPED' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLR' , RetTitle( 'NSY_PEVLR' ) , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULT', RetTitle( 'NSY_DTMULT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUL', RetTitle( 'NSY_PERMUL' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEINVL', RetTitle( 'NSY_PEINVL' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PESOMA', RetTitle( 'NSY_PESOMA' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPE', RetTitle( 'NSY_CCORPE' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPE', RetTitle( 'NSY_CJURPE' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATU', RetTitle( 'NSY_MULATU' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLRA', RetTitle( 'NSY_PEVLRA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SPE'   , RetTitle( 'NSY_SPE' )   , '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SAPE'  , RetTitle( 'NSY_SAPE' )  , '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTPED', RetTitle( 'NSY_TOTPED') , '001' } )  
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOPEAT', RetTitle( 'NSY_TOPEAT '), '001' } )
		
		
		//contigência 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CFCORC', RetTitle( 'NSY_CFCORC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DFCORC', RetTitle( 'NSY_DFCORC' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTCONT', RetTitle( 'NSY_DTCONT' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURC', RetTitle( 'NSY_DTJURC' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOCON', RetTitle( 'NSY_CMOCON' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOCON', RetTitle( 'NSY_DMOCON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULC', RetTitle( 'NSY_DTMULC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUC', RetTitle( 'NSY_PERMUC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SOMCON', RetTitle( 'NSY_SOMCON' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_INECON', RetTitle( 'NSY_INECON' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONT', RetTitle( 'NSY_VLCONT' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPC', RetTitle( 'NSY_CCORPC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPC', RetTitle( 'NSY_CJURPC' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATC', RetTitle( 'NSY_MULATC' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONA', RetTitle( 'NSY_VLCONA' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONT', RetTitle( 'NSY_SLCONT' ), '001' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONA', RetTitle( 'NSY_SLCONA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTORC', RetTitle( 'NSY_TOTORC' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTATC', RetTitle( 'NSY_TOTATC' ), '001' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CFCORR', STR0071				  , '002' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DFCORR', STR0071				  , '002' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCAU', STR0072				  , '002' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCAU', STR0072				  , '002' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENV', STR0073				  , '002' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENV', STR0073				  , '002' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COBJET', RetTitle( 'NSZ_COBJET' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DOBJET', RetTitle( 'NSZ_DOBJET' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CPROGN', STR0075				  , '002' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPROGN', STR0075				  , '002' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCAUS', STR0076				  , '002' } ) //"Data Valor Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENVO', STR0077				  , '002' } ) //"Data Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTINCL', RetTitle( 'NSZ_DTINCL' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '002' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG01', RetTitle( 'NSZ_FLAG01' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG02', RetTitle( 'NSZ_FLAG02' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_JUSTIF', STR0087				  , '002' } ) //"Justificativa Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LITISC', RetTitle( 'NSZ_LITISC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMERO', RetTitle( 'NSZ_NUMERO' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_PERMUL', RetTitle( 'NSZ_PERMUL' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SAPE'  , STR0088				  , '002' } ) //"Saldo Pedido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_TIPOAS', RetTitle( 'NSZ_TIPOAS' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTIPAS', RetTitle( 'NSZ_DTIPAS' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUENC', RetTitle( 'NSZ_USUENC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VACAUS', STR0080				  , '002' } ) //"Valor Causa Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VAENVO', STR0081				  , '002' } ) //"Valor Envolvido Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCAUS', RetTitle( 'NSZ_VLCAUS' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLENVO', STR0085				  , '002' } ) //"Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLINES', RetTitle( 'NSZ_VLINES' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCOMAR', RetTitle( 'NUQ_CCOMAR' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCOMAR', RetTitle( 'NUQ_DCOMAR' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC2N', RetTitle( 'NUQ_CLOC2N' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC2N', RetTitle( 'NUQ_DLOC2N' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC3N', RetTitle( 'NUQ_CLOC3N' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC3N', RetTitle( 'NUQ_DLOC3N' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '002' } )
		//Carga NSY
		//Detalhe
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPEVLR', RetTitle( 'NSY_CPEVLR' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPEVLR', RetTitle( 'NSY_DPEVLR' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPROG' , RetTitle( 'NSY_CPROG' ) , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPROG' , RetTitle( 'NSY_DPROG' ) , '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CENVOL', RetTitle( 'NSY_CENVOL' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DENVOL', RetTitle( 'NSY_DENVOL' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DESC'  , RetTitle( 'NSY_DESC' )  , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTULAT', RetTitle( 'NSY_DTULAT' ), '002' } )
		
		//processo
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PATIVO', RetTitle( 'NSY_PATIVO' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PPASSI', RetTitle( 'NSY_PPASSI' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DSITUA', RetTitle( 'NSY_DSITUA' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_NUMPRO', RetTitle( 'NSY_NUMPRO' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTDIST', RetTitle( 'NSY_DTDIST' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CINSTA', RetTitle( 'NSY_CINSTA' ), '002' } ) 
	
		//pedidos
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCOMON', RetTitle( 'NSY_CCOMON' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEDATA', RetTitle( 'NSY_PEDATA' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURO', RetTitle( 'NSY_DTJURO' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOPED', RetTitle( 'NSY_CMOPED' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOPED', RetTitle( 'NSY_DMOPED' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLR' , RetTitle( 'NSY_PEVLR' ) , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULT', RetTitle( 'NSY_DTMULT' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUL', RetTitle( 'NSY_PERMUL' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEINVL', RetTitle( 'NSY_PEINVL' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PESOMA', RetTitle( 'NSY_PESOMA' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPE', RetTitle( 'NSY_CCORPE' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPE', RetTitle( 'NSY_CJURPE' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATU', RetTitle( 'NSY_MULATU' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLRA', RetTitle( 'NSY_PEVLRA' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SPE'   , RetTitle( 'NSY_SPE' )   , '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SAPE'  , RetTitle( 'NSY_SAPE' )  , '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTPED', RetTitle( 'NSY_TOTPED') , '002' } )  
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOPEAT', RetTitle( 'NSY_TOPEAT '), '002' } )
		
		
		//contigência 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CFCORC', RetTitle( 'NSY_CFCORC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DFCORC', RetTitle( 'NSY_DFCORC' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTCONT', RetTitle( 'NSY_DTCONT' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURC', RetTitle( 'NSY_DTJURC' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOCON', RetTitle( 'NSY_CMOCON' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOCON', RetTitle( 'NSY_DMOCON' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULC', RetTitle( 'NSY_DTMULC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUC', RetTitle( 'NSY_PERMUC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SOMCON', RetTitle( 'NSY_SOMCON' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_INECON', RetTitle( 'NSY_INECON' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONT', RetTitle( 'NSY_VLCONT' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPC', RetTitle( 'NSY_CCORPC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPC', RetTitle( 'NSY_CJURPC' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATC', RetTitle( 'NSY_MULATC' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONA', RetTitle( 'NSY_VLCONA' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONT', RetTitle( 'NSY_SLCONT' ), '002' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONA', RetTitle( 'NSY_SLCONA' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTORC', RetTitle( 'NSY_TOTORC' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTATC', RetTitle( 'NSY_TOTATC' ), '002' } )
		
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CFCORR', STR0071				  , '003' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DFCORR', STR0071				  , '003' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCAU', STR0072				  , '003' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCAU', STR0072				  , '003' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENV', STR0073				  , '003' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENV', STR0073				  , '003' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COBJET', RetTitle( 'NSZ_COBJET' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DOBJET', RetTitle( 'NSZ_DOBJET' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CPROGN', STR0075				  , '003' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPROGN', STR0075				  , '003' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCAUS', STR0076				  , '003' } ) //"Data Valor Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENVO', STR0077				  , '003' } ) //"Data Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTINCL', RetTitle( 'NSZ_DTINCL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '003' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG01', RetTitle( 'NSZ_FLAG01' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG02', RetTitle( 'NSZ_FLAG02' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_JUSTIF', STR0087				  , '003' } ) //"Justificativa Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LITISC', RetTitle( 'NSZ_LITISC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_PERMUL', RetTitle( 'NSZ_PERMUL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SAPE'  , STR0088				  , '003' } ) //"Saldo Pedido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_TIPOAS', RetTitle( 'NSZ_TIPOAS' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTIPAS', RetTitle( 'NSZ_DTIPAS' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUENC', RetTitle( 'NSZ_USUENC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VACAUS', STR0080				  , '003' } ) //"Valor Causa Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VAENVO', STR0081				  , '003' } ) //"Valor Envolvido Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCAUS', RetTitle( 'NSZ_VLCAUS' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLENVO', STR0085				  , '003' } ) //"Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLINES', RetTitle( 'NSZ_VLINES' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COD'   , RetTitle( 'NSZ_COD' )   , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENTR', RetTitle( 'NSZ_DTENTR' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FILIAL', RetTitle( 'NSZ_FILIAL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_INSEST', RetTitle( 'NSZ_INSEST' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_INSMUN', RetTitle( 'NSZ_INSMUN' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUINC', RetTitle( 'NSZ_USUINC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATA'  , RetTitle( 'NYP_DATA'   ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CMOEDA', RetTitle( 'NYP_CMOEDA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_VALOR' , RetTitle( 'NYP_VALOR'  ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALI', RetTitle( 'NYP_DATALI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_TIPO'  , RetTitle( 'NYP_TIPO'   ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CSTATU', RetTitle( 'NYP_CSTATU' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATAIN', RetTitle( 'NYP_DATAIN' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUIN' , RetTitle( 'NYP_USUIN'  ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUAL' , RetTitle( 'NYP_USUAL'  ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCOMAR', RetTitle( 'NUQ_CCOMAR' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCOMAR', RetTitle( 'NUQ_DCOMAR' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC2N', RetTitle( 'NUQ_CLOC2N' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC2N', RetTitle( 'NUQ_DLOC2N' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC3N', RetTitle( 'NUQ_CLOC3N' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC3N', RetTitle( 'NUQ_DLOC3N' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CAJURI', RetTitle( 'NT9_CAJURI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOCL', RetTitle( 'NT9_TIPOCL' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_PRINCI', RetTitle( 'NT9_PRINCI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOEN', RetTitle( 'NT9_TIPOEN' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOP' , RetTitle( 'NT9_TIPOP' ) , '003' } )
		//Detalhe
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPEVLR', RetTitle( 'NSY_CPEVLR' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPEVLR', RetTitle( 'NSY_DPEVLR' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPROG' , RetTitle( 'NSY_CPROG' ) , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPROG' , RetTitle( 'NSY_DPROG' ) , '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CENVOL', RetTitle( 'NSY_CENVOL' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DENVOL', RetTitle( 'NSY_DENVOL' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DESC'  , RetTitle( 'NSY_DESC' )  , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTULAT', RetTitle( 'NSY_DTULAT' ), '003' } )
		
		//processo
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PATIVO', RetTitle( 'NSY_PATIVO' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PPASSI', RetTitle( 'NSY_PPASSI' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DSITUA', RetTitle( 'NSY_DSITUA' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_NUMPRO', RetTitle( 'NSY_NUMPRO' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTDIST', RetTitle( 'NSY_DTDIST' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CINSTA', RetTitle( 'NSY_CINSTA' ), '003' } ) 
	
		//pedidos
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCOMON', RetTitle( 'NSY_CCOMON' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEDATA', RetTitle( 'NSY_PEDATA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURO', RetTitle( 'NSY_DTJURO' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOPED', RetTitle( 'NSY_CMOPED' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOPED', RetTitle( 'NSY_DMOPED' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLR' , RetTitle( 'NSY_PEVLR' ) , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULT', RetTitle( 'NSY_DTMULT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUL', RetTitle( 'NSY_PERMUL' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEINVL', RetTitle( 'NSY_PEINVL' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PESOMA', RetTitle( 'NSY_PESOMA' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPE', RetTitle( 'NSY_CCORPE' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPE', RetTitle( 'NSY_CJURPE' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATU', RetTitle( 'NSY_MULATU' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLRA', RetTitle( 'NSY_PEVLRA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SPE'   , RetTitle( 'NSY_SPE' )   , '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SAPE'  , RetTitle( 'NSY_SAPE' )  , '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTPED', RetTitle( 'NSY_TOTPED') , '003' } )  
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOPEAT', RetTitle( 'NSY_TOPEAT '), '003' } )
		
		
		//contigência 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CFCORC', RetTitle( 'NSY_CFCORC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DFCORC', RetTitle( 'NSY_DFCORC' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTCONT', RetTitle( 'NSY_DTCONT' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURC', RetTitle( 'NSY_DTJURC' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOCON', RetTitle( 'NSY_CMOCON' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOCON', RetTitle( 'NSY_DMOCON' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULC', RetTitle( 'NSY_DTMULC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUC', RetTitle( 'NSY_PERMUC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SOMCON', RetTitle( 'NSY_SOMCON' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_INECON', RetTitle( 'NSY_INECON' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONT', RetTitle( 'NSY_VLCONT' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPC', RetTitle( 'NSY_CCORPC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPC', RetTitle( 'NSY_CJURPC' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATC', RetTitle( 'NSY_MULATC' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONA', RetTitle( 'NSY_VLCONA' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONT', RetTitle( 'NSY_SLCONT' ), '003' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONA', RetTitle( 'NSY_SLCONA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTORC', RetTitle( 'NSY_TOTORC' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTATC', RetTitle( 'NSY_TOTATC' ), '003' } )
		

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CFCORR', STR0071				  , '004' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DFCORR', STR0071				  , '004' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCAU', STR0072				  , '004' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCAU', STR0072				  , '004' } ) //"Moeda Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENV', STR0073				  , '004' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENV', STR0073				  , '004' } ) //"Moeda Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CPROGN', STR0075				  , '004' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPROGN', STR0075				  , '004' } ) //"Prognóstico"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCAUS', STR0076				  , '004' } ) //"Data Valor Causa"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENVO', STR0077				  , '004' } ) //"Data Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTINCL', RetTitle( 'NSZ_DTINCL' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '004' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG01', RetTitle( 'NSZ_FLAG01' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FLAG02', RetTitle( 'NSZ_FLAG02' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_JUSTIF', STR0087				  , '004' } ) //"Justificativa Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_PERMUL', RetTitle( 'NSZ_PERMUL' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SAPE'  , STR0088				  , '004' } ) //"Saldo Pedido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_TIPOAS', RetTitle( 'NSZ_TIPOAS' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTIPAS', RetTitle( 'NSZ_DTIPAS' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUENC', RetTitle( 'NSZ_USUENC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VACAUS', STR0080				  , '004' } ) //"Valor Causa Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VAENVO', STR0081				  , '004' } ) //"Valor Envolvido Atual"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCAUS', RetTitle( 'NSZ_VLCAUS' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLENVO', STR0085				  , '004' } ) //"Valor Envolvido"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLINES', RetTitle( 'NSZ_VLINES' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COD'   , RetTitle( 'NSZ_COD' )   , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUINC', RetTitle( 'NSZ_USUINC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATA'  , RetTitle( 'NYP_DATA'   ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CMOEDA', RetTitle( 'NYP_CMOEDA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_VALOR' , RetTitle( 'NYP_VALOR'  ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALI', RetTitle( 'NYP_DATALI' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_TIPO'  , RetTitle( 'NYP_TIPO'   ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_CSTATU', RetTitle( 'NYP_CSTATU' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATAIN', RetTitle( 'NYP_DATAIN' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUIN' , RetTitle( 'NYP_USUIN'  ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYP_USUAL' , RetTitle( 'NYP_USUAL'  ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCOMAR', RetTitle( 'NUQ_CCOMAR' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCOMAR', RetTitle( 'NUQ_DCOMAR' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC2N', RetTitle( 'NUQ_CLOC2N' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC2N', RetTitle( 'NUQ_DLOC2N' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC3N', RetTitle( 'NUQ_CLOC3N' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC3N', RetTitle( 'NUQ_DLOC3N' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '004' } )
		//Detalhe
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPEVLR', RetTitle( 'NSY_CPEVLR' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPEVLR', RetTitle( 'NSY_DPEVLR' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPROG' , RetTitle( 'NSY_CPROG' ) , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPROG' , RetTitle( 'NSY_DPROG' ) , '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CENVOL', RetTitle( 'NSY_CENVOL' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DENVOL', RetTitle( 'NSY_DENVOL' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DESC'  , RetTitle( 'NSY_DESC' )  , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTULAT', RetTitle( 'NSY_DTULAT' ), '004' } )
		
		//processo
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PATIVO', RetTitle( 'NSY_PATIVO' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PPASSI', RetTitle( 'NSY_PPASSI' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DSITUA', RetTitle( 'NSY_DSITUA' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_NUMPRO', RetTitle( 'NSY_NUMPRO' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTDIST', RetTitle( 'NSY_DTDIST' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CINSTA', RetTitle( 'NSY_CINSTA' ), '004' } ) 
	
		//pedidos
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCOMON', RetTitle( 'NSY_CCOMON' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEDATA', RetTitle( 'NSY_PEDATA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURO', RetTitle( 'NSY_DTJURO' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOPED', RetTitle( 'NSY_CMOPED' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOPED', RetTitle( 'NSY_DMOPED' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLR' , RetTitle( 'NSY_PEVLR' ) , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULT', RetTitle( 'NSY_DTMULT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUL', RetTitle( 'NSY_PERMUL' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEINVL', RetTitle( 'NSY_PEINVL' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PESOMA', RetTitle( 'NSY_PESOMA' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPE', RetTitle( 'NSY_CCORPE' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPE', RetTitle( 'NSY_CJURPE' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATU', RetTitle( 'NSY_MULATU' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLRA', RetTitle( 'NSY_PEVLRA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SPE'   , RetTitle( 'NSY_SPE' )   , '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SAPE'  , RetTitle( 'NSY_SAPE' )  , '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTPED', RetTitle( 'NSY_TOTPED') , '004' } )  
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOPEAT', RetTitle( 'NSY_TOPEAT '), '004' } )
		
		
		//contigência 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CFCORC', RetTitle( 'NSY_CFCORC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DFCORC', RetTitle( 'NSY_DFCORC' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTCONT', RetTitle( 'NSY_DTCONT' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURC', RetTitle( 'NSY_DTJURC' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOCON', RetTitle( 'NSY_CMOCON' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOCON', RetTitle( 'NSY_DMOCON' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULC', RetTitle( 'NSY_DTMULC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUC', RetTitle( 'NSY_PERMUC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SOMCON', RetTitle( 'NSY_SOMCON' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_INECON', RetTitle( 'NSY_INECON' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONT', RetTitle( 'NSY_VLCONT' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPC', RetTitle( 'NSY_CCORPC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPC', RetTitle( 'NSY_CJURPC' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATC', RetTitle( 'NSY_MULATC' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONA', RetTitle( 'NSY_VLCONA' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONT', RetTitle( 'NSY_SLCONT' ), '004' } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONA', RetTitle( 'NSY_SLCONA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTORC', RetTitle( 'NSY_TOTORC' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTATC', RetTitle( 'NSY_TOTATC' ), '004' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CAREAJ', RetTitle( 'NSZ_CAREAJ' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DAREAJ', RetTitle( 'NSZ_DAREAJ' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', RetTitle( 'NSZ_SIGLA1' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', RetTitle( 'NSZ_DPART1' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA2', RetTitle( 'NSZ_SIGLA2' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART2', RetTitle( 'NSZ_DPART2' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENTR', RetTitle( 'NSZ_DTENTR' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '005' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SOLICI', RetTitle( 'NSZ_SOLICI' ), '005' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', STR0065                 , '006' } ) //'Cód Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', STR0066                 , '006' } ) //'Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', STR0067                 , '006' } ) //'Sigla Resp'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', STR0068                 , '006' } ) //'Responsável'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CFCORR', STR0071				  , '006' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DFCORR', STR0071				  , '006' } ) //"Correção"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COD'   , RetTitle( 'NSZ_COD' )   , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTASSI', STR0300				  , '006' } ) //"Data Assinatura Contrato" 
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTADIT', STR0299				  , '006' } ) //"Data Assinatura Aditivo"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTINVI', RetTitle( 'NSZ_DTINVI' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTTMVI', RetTitle( 'NSZ_DTTMVI' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CDPSOL', RetTitle( 'NSZ_CDPSOL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DDPSOL', RetTitle( 'NSZ_DDPSOL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FPGTO' , RetTitle( 'NSZ_OBSERV' ), '006' } ) //Campo de forma de pagamento teve seu título alterado através dos aceleradores para OBSERVAÇÕES
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSMUL', RetTitle( 'NSZ_OBSMUL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_RENOVA', RetTitle( 'NSZ_RENOVA' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_RESCIS', RetTitle( 'NSZ_RESCIS' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SOLICI', RetTitle( 'NSZ_SOLICI' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CODCON', RetTitle( 'NSZ_CODCON' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCON', RetTitle( 'NSZ_DESCON' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_IDENTI', RetTitle( 'NSZ_IDENTI' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ESTADO', RetTitle( 'NSZ_ESTADO' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMUNIC', RetTitle( 'NSZ_CMUNIC' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMUNIC', RetTitle( 'NSZ_DMUNIC' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_MULTA' , RetTitle( 'NSZ_MULTA' ) , '006' } )
		DbSelectArea("NSZ")
		If ColumnPos('NSZ_DTCONT') > 0 .And. ColumnPos('NSZ_CMOCON') > 0 .And. ColumnPos('NSZ_VACONT') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCONT', STR0089			  , '006' } ) //"Data Valor Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCON', STR0090			  , '006' } ) //"Moeda Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCON', STR0090			  , '006' } ) //"Moeda Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_VACONT', STR0091			  , '006' } ) //"Valor Contrato Atual"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCONT', STR0092			  , '006' } ) //"Valor Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_MULCON', STR0093			  , '006' } ) //"% Multa Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCPCON', STR0094			  , '006' } ) //"Condição Pagamento Contrato"
			aAdd( aDadosNUZ, { cFilTab, 'NSZ_DCPCON', STR0094			  , '006' } ) //"Condição Pagamento Contrato"
		EndIf
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCON', RetTitle( 'NSZ_NUMCON' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CFORNE', RetTitle( 'NT9_CFORNE' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LFORNE', RetTitle( 'NT9_LFORNE' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TFORNE', RetTitle( 'NT9_TFORNE' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENDECL', RetTitle( 'NT9_ENDECL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOCL', RetTitle( 'NT9_TIPOCL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOP' , RetTitle( 'NT9_TIPOP' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DDD'   , RetTitle( 'NT9_DDD' )   , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TELEFO', RetTitle( 'NT9_TELEFO' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_EMAIL' , RetTitle( 'NT9_EMAIL' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_OBSERV', RetTitle( 'NT9_OBSERV' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , STR0069                 , '006' } ) //'Cód Tp Andam'
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , STR0070                 , '006' } ) //'Tp Andamento'
		aAdd( aDadosNUZ, { cFilTab, 'NTA_HORA'  , RetTitle( 'NTA_HORA' )  , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DRESUL', RetTitle( 'NTA_DRESUL' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTORIG', RetTitle( 'NTA_DTORIG' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTALT' , RetTitle( 'NTA_DTALT' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUALT', RetTitle( 'NTA_USUALT' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUCON', RetTitle( 'NTA_USUCON' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTCON' , RetTitle( 'NTA_DTCON' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_OBJETO', RetTitle( 'NXY_OBJETO' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_CTIPO' , RetTitle( 'NXY_CTIPO' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_DTIPO' , RetTitle( 'NXY_DTIPO' ) , '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_NUMCON', RetTitle( 'NXY_NUMCON' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_ADITIV', RetTitle( 'NXY_ADITIV' ), '006' } )
		aAdd( aDadosNUZ, { cFilTab, 'NXY_DTASSI', STR0301				  , '006' } ) //Dt Assi Adit (Data Assinatura Aditivo)

		DbSelectArea("NXY")
		If ColumnPos('NXY_DTINVI') > 0 .And. ColumnPos('NXY_DTTMVI') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DTINVI', RetTitle( 'NXY_DTINVI' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DTTMVI', RetTitle( 'NXY_DTTMVI' ), '006' } )
		EndIf
		If ColumnPos('NXY_CFCORR') > 0 .And. ColumnPos('NXY_DTVLAD') > 0 .And. ColumnPos('NXY_CMOADI') > 0 .And. ;
		   ColumnPos('NXY_VLADIT') > 0 .And. ColumnPos('NXY_VAADIT') > 0 .And. ColumnPos('NXY_DTULAT') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NXY_CFCORR', RetTitle( 'NXY_CFCORR' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DFCORR', RetTitle( 'NXY_DFCORR' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DTVLAD', RetTitle( 'NXY_DTVLAD' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_CMOADI', RetTitle( 'NXY_CMOADI' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DMOADI', RetTitle( 'NXY_DMOADI' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_VLADIT', RetTitle( 'NXY_VLADIT' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_VAADIT', RetTitle( 'NXY_VAADIT' ), '006' } )
			aAdd( aDadosNUZ, { cFilTab, 'NXY_DTULAT', RetTitle( 'NXY_DTULAT' ), '006' } )
		EndIf

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', STR0065                 , '007' } ) //'Cód Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', STR0066                 , '007' } ) //'Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', STR0067                 , '007' } ) //'Sigla Resp'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', STR0068                 , '007' } ) //'Responsável'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTINVI', RetTitle( 'NSZ_DTINVI' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTTMVI', RetTitle( 'NSZ_DTTMVI' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_TPPROC', RetTitle( 'NSZ_TPPROC' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CSBPRO', RetTitle( 'NSZ_CSBPRO' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DSBPRO', RetTitle( 'NSZ_DSBPRO' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_PODER' , RetTitle( 'NSZ_PODER' ) , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTASSI', RetTitle( 'NSZ_DTASSI' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', RetTitle( 'NSZ_SIGLA1' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', RetTitle( 'NSZ_DPART1' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA2', RetTitle( 'NSZ_SIGLA2' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART2', RetTitle( 'NSZ_DPART2' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTLANC', RetTitle( 'NSZ_DTENTR' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SOLICI', RetTitle( 'NSZ_SOLICI' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CFORNE', RetTitle( 'NT9_CFORNE' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LFORNE', RetTitle( 'NT9_LFORNE' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TFORNE', RetTitle( 'NT9_TFORNE' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_EMAIL' , RetTitle( 'NT9_EMAIL' ) , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DDD'   , RetTitle( 'NT9_DDD' )   , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TELEFO', RetTitle( 'NT9_TELEFO' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOP' , RetTitle( 'NT9_TIPOP' ) , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_HORA'  , RetTitle( 'NTA_HORA' )  , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DRESUL', RetTitle( 'NTA_DRESUL' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTORIG', RetTitle( 'NTA_DTORIG' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTALT' , RetTitle( 'NTA_DTALT' ) , '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUALT', RetTitle( 'NTA_USUALT' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_USUCON', RetTitle( 'NTA_USUCON' ), '007' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DTCON' , RetTitle( 'NTA_DTCON' ) , '007' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', STR0065                 , '008' } ) //'Cód Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', STR0066                 , '008' } ) //'Unidade'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', STR0067                 , '008' } ) //'Sigla Resp'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', STR0068                 , '008' } ) //'Responsável'
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', RetTitle( 'NSZ_DPART1' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ALTPOS', RetTitle( 'NSZ_ALTPOS' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ALVARA', RetTitle( 'NSZ_ALVARA' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_BAIRRO', RetTitle( 'NSZ_BAIRRO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CEP'   , RetTitle( 'NSZ_CEP' )   , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOCAP', RetTitle( 'NSZ_CMOCAP' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOCAP', RetTitle( 'NSZ_DMOCAP' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMUNIC', RetTitle( 'NSZ_CMUNIC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMUNIC', RetTitle( 'NSZ_DMUNIC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CNAE'  , RetTitle( 'NSZ_CNAE' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COMPLE', RetTitle( 'NSZ_COMPLE' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CTPSOC', RetTitle( 'NSZ_CTPSOC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTPSOC', RetTitle( 'NSZ_DTPSOC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DENOM' , RetTitle( 'NSZ_DENOM' ) , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESALT', RetTitle( 'NSZ_DESALT' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCAPI', RetTitle( 'NSZ_DTCAPI' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCONS', RetTitle( 'NSZ_DTCONS' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENTR', RetTitle( 'NSZ_DTENTR' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ESTADO', RetTitle( 'NSZ_ESTADO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_INSEST', RetTitle( 'NSZ_INSEST' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_INSMUN', RetTitle( 'NSZ_INSMUN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LOGNUM', RetTitle( 'NSZ_LOGNUM' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LOGRAD', RetTitle( 'NSZ_LOGRAD' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NIRE'  , RetTitle( 'NSZ_NIRE' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NOMEFT', RetTitle( 'NSZ_NOMEFT' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBJSOC', RetTitle( 'NSZ_OBJSOC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ULTCON', RetTitle( 'NSZ_ULTCON' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLACAO', RetTitle( 'NSZ_VLACAO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_VLCAPI', RetTitle( 'NSZ_VLCAPI' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CNACIO', RetTitle( 'NT9_CNACIO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DNACIO', RetTitle( 'NT9_DNACIO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CSITUA', RetTitle( 'NT9_CSITUA' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DSITUA', RetTitle( 'NT9_DSITUA' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DDD'   , RetTitle( 'NT9_DDD' )   , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTENTR', RetTitle( 'NT9_DTENTR' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTSAID', RetTitle( 'NT9_DTSAID' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_EMAIL' , RetTitle( 'NT9_EMAIL' ) , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_OBSERV', RetTitle( 'NT9_OBSERV' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_PERCAC', RetTitle( 'NT9_PERCAC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_PRECO' , RetTitle( 'NT9_PRECO' ) , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_PRINCI', RetTitle( 'NT9_PRINCI' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_RG'    , RetTitle( 'NT9_RG' )    , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TELEFO', RetTitle( 'NT9_TELEFO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOCL', RetTitle( 'NT9_TIPOCL' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_ALVARA', RetTitle( 'NYJ_ALVARA' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_BAIRRO', RetTitle( 'NYJ_BAIRRO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_CCLIEN', RetTitle( 'NYJ_CCLIEN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_LCLIEN', RetTitle( 'NYJ_LCLIEN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_DCLIEN', RetTitle( 'NYJ_DCLIEN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_CEP'   , RetTitle( 'NYJ_CEP' )   , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_CMUNIC', RetTitle( 'NYJ_CMUNIC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_DMUNIC', RetTitle( 'NYJ_DMUNIC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_CNAE'  , RetTitle( 'NYJ_CNAE' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_COD'   , RetTitle( 'NYJ_COD' )   , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_COMPLE', RetTitle( 'NYJ_COMPLE' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_CTPSOC', RetTitle( 'NYJ_CTPSOC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_DTPSOC', RetTitle( 'NYJ_DTPSOC' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_DENOM' , RetTitle( 'NYJ_DENOM' ) , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_DTCONS', RetTitle( 'NYJ_DTCONS' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_ESTADO', RetTitle( 'NYJ_ESTADO' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_INSEST', RetTitle( 'NYJ_INSEST' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_INSMUN', RetTitle( 'NYJ_INSMUN' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_LOGNUM', RetTitle( 'NYJ_LOGNUM' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_LOGRAD', RetTitle( 'NYJ_LOGRAD' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_NIRE'  , RetTitle( 'NYJ_NIRE' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NYJ_NOMEFT', RetTitle( 'NYJ_NOMEFT' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '008' } )     

		DbSelectArea("NT4")
		If ColumnPos('NT4_CONVOC') > 0 .And. ColumnPos('NT4_NUMARQ') > 0 .And. ;
		   ColumnPos('NT4_DTARQ') > 0 .And. ColumnPos('NT4_ATOPUB') > 0 .And. ColumnPos('NT4_LIVSOC') > 0
			aAdd( aDadosNUZ, { cFilTab, 'NT4_CONVOC', RetTitle( 'NT4_CONVOC' ), '008' } )
			aAdd( aDadosNUZ, { cFilTab, 'NT4_NUMARQ', RetTitle( 'NT4_NUMARQ' ), '008' } )
			aAdd( aDadosNUZ, { cFilTab, 'NT4_DTARQ' , RetTitle( 'NT4_DTARQ' ) , '008' } )
			aAdd( aDadosNUZ, { cFilTab, 'NT4_ATOPUB', RetTitle( 'NT4_ATOPUB' ), '008' } )
			aAdd( aDadosNUZ, { cFilTab, 'NT4_LIVSOC', RetTitle( 'NT4_LIVSOC' ), '008' } )
		EndIf

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '009' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SITUAC', RetTitle( 'NSZ_SITUAC' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CFORNE', RetTitle( 'NT9_CFORNE' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LFORNE', RetTitle( 'NT9_LFORNE' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_OBSERV', RetTitle( 'NT9_OBSERV' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TFORNE', RetTitle( 'NT9_TFORNE' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CAJURI', RetTitle( 'NUQ_CAJURI' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CCOMAR', RetTitle( 'NUQ_CCOMAR' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DCOMAR', RetTitle( 'NUQ_DCOMAR' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC2N', RetTitle( 'NUQ_CLOC2N' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC2N', RetTitle( 'NUQ_DLOC2N' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_CLOC3N', RetTitle( 'NUQ_CLOC3N' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_DLOC3N', RetTitle( 'NUQ_DLOC3N' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_COD'   , RetTitle( 'NUQ_COD' )   , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_INSATU', RetTitle( 'NUQ_INSATU' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_INSTAN', RetTitle( 'NUQ_INSTAN' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMPRO', RetTitle( 'NUQ_NUMPRO' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '009' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '009' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCRIJU', RetTitle( 'NSZ_CCRIJU' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DCRIJU', RetTitle( 'NSZ_DCRIJU' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMODLI', RetTitle( 'NSZ_CMODLI' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMODLI', RetTitle( 'NSZ_DMODLI' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DETENC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOLIC', RetTitle( 'NSZ_CMOLIC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOLIC', RetTitle( 'NSZ_DMOLIC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CODRES', RetTitle( 'NSZ_CODRES' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NOMRES', RetTitle( 'NSZ_NOMRES' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', RetTitle( 'NSZ_DETALH' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCONC', RetTitle( 'NSZ_DTCONC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTLICI', RetTitle( 'NSZ_DTLICI' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMLIC', RetTitle( 'NSZ_NUMLIC' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGRES', RetTitle( 'NSZ_SIGRES' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CGC'   , RetTitle( 'NT9_CGC' )   , '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_TIPOP' , RetTitle( 'NT9_TIPOP' ) , '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '010' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '010' } )

		aAdd( aDadosNUZ, { cFilTab, 'NSZ_BITMAP', RetTitle( 'NSZ_BITMAP' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLASS', RetTitle( 'NSZ_CCLASS' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DCLASS', RetTitle( 'NSZ_DCLASS' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CCLIEN', RetTitle( 'NSZ_CCLIEN' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_LCLIEN', RetTitle( 'NSZ_LCLIEN' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CNATMA', RetTitle( 'NSZ_CNATMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DNATMA', RetTitle( 'NSZ_DNATMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CREGIO', RetTitle( 'NSZ_CREGIO' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DREGIO', RetTitle( 'NSZ_DREGIO' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CSITMA', RetTitle( 'NSZ_CSITMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DSITMA', RetTitle( 'NSZ_DSITMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CTIPMA', RetTitle( 'NSZ_CTIPMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTIPMA', RetTitle( 'NSZ_DTIPMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTEMIS', RetTitle( 'NSZ_DTEMIS' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTPROR', RetTitle( 'NSZ_DTPROR' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTSITU', RetTitle( 'NSZ_DTSITU' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTSOLI', RetTitle( 'NSZ_DTSOLI' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTULAT', STR0079				  , '011' } ) //"Última Atualização Valores"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ESPECI', RetTitle( 'NSZ_ESPECI' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_JUSTPR', RetTitle( 'NSZ_JUSTPR' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NOMEMA', RetTitle( 'NSZ_NOMEMA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMPED', RetTitle( 'NSZ_NUMPED' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SITREL', RetTitle( 'NSZ_SITREL' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SOLICI', RetTitle( 'NSZ_SOLICI' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_USUINC', RetTitle( 'NSZ_USUINC' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CEMPCL', RetTitle( 'NT9_CEMPCL' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_LOJACL', RetTitle( 'NT9_LOJACL' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , RetTitle( 'NT9_NOME' )  , '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_ENTIDA', RetTitle( 'NT9_ENTIDA' ), '011' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), '011' } )

		aAdd( aDadosNUZ, { cFilTab, 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '001' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '002' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '003' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '004' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '009' } )

		aAdd( aDadosNUZ, { cFilTab, 'NT4_CADITI', RetTitle( 'NT4_CADITI' ), '006' } )

		aAdd( aDadosNUZ, { cFilTab, 'NT4_CCONCE', RetTitle( 'NT4_CCONCE' ), '008' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT4_CUNIDA', RetTitle( 'NT4_CUNIDA' ), '008' } )

		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '001' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '002' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '003' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '004' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '005' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '006' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '007' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '008' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '009' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '010' } ) // "Descrição"
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , JA160X3Des( 'NTA_DESC' ), '011' } ) // "Descrição"

		If Len(TamSX3('NUQ_TLOC3N')) > 0
			aAdd( aDadosNUZ, { cFilTab, 'NUQ_TLOC3N', RetTitle( 'NUQ_TLOC3N' ), '001' } )
			aAdd( aDadosNUZ, { cFilTab, 'NUQ_TLOC3N', RetTitle( 'NUQ_TLOC3N' ), '002' } )
			aAdd( aDadosNUZ, { cFilTab, 'NUQ_TLOC3N', RetTitle( 'NUQ_TLOC3N' ), '003' } )
			aAdd( aDadosNUZ, { cFilTab, 'NUQ_TLOC3N', RetTitle( 'NUQ_TLOC3N' ), '004' } )
			aAdd( aDadosNUZ, { cFilTab, 'NUQ_TLOC3N', RetTitle( 'NUQ_TLOC3N' ), '009' } )
		EndIf

		
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_FILIAL', JA160X3Des( 'NSZ_FILIAL' ), '013' } ) // "Filial"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_COD '  , STR0302                   , '013' } ) // "Protocolo Interno"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCERT', STR0303                   , '013' } ) // "Data da Notificação"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTEMIS', STR0304                   , '013' } ) // "Data da RVE"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTCONC', STR0313                   , '013' } ) // "Data Prazo"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_IDENTI', STR0305                   , '013' } ) // "Número da Demanda"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NIRE'  , STR0306                   , '013' } ) // "Protocolo"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMPED', STR0307                   , '013' } ) // "Prazo"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETALH', STR0308                   , '013' } ) // "Reclamação"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_TOMBO' , STR0309                   , '013' } ) // "Assunto"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBJSOC', STR0310                   , '013' } ) // "Natureza"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_ULTCON', STR0311                   , '013' } ) // "Status ANS"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' )  , '013' } ) // "Cód Unidade"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' )  , '013' } ) // "Unidade"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMREG', RetTitle( 'NSZ_NUMREG' )  , '013' } ) // "Plano contratado"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CPART2', RetTitle( 'NSZ_CPART2' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CAREAJ', RetTitle( 'NSZ_CAREAJ' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DAREAJ', RetTitle( 'NSZ_DAREAJ' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA1', RetTitle( 'NSZ_SIGLA1' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART1', RetTitle( 'NSZ_DPART1' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SIGLA2', RetTitle( 'NSZ_SIGLA2' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DPART2', RetTitle( 'NSZ_DPART2' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_SITUAC', JA160X3Des( 'NSZ_SITUAC' ), '013' } ) // "Status Interno"
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' )  , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_HORA'  , RetTitle( 'NTA_HORA' )    , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NTA_DESC'  , RetTitle( 'NTA_DESC' )    , '013' } )
		aAdd( aDadosNUZ, { cFilTab, 'NT9_NOME'  , JA160X3Des( 'NT9_NOME' )  , '013' } ) // "Nome do beneficiario"
		
		DbSelectArea("NT9")
		If NT9->( FieldPos("NT9_CODBEN") ) > 0
			aAdd( aDadosNUZ, { cFilTab, 'NT9_CODBEN', JA160X3Des( 'NT9_CODBEN' ), '013' } ) // "Código beneficiario"
		EndIf
		DbCloseArea()

	EndIf

	For nReg := 1 To Len( aDadosNUZ )

		cChave := ''
		For nI := 1 To Len( aChave )
			cChave += aDadosNUZ[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
		Next

		If !lAutomato
			( cAlias )->( dbSetOrder( 1 ) )
			If !( cAlias )->( dbSeek ( cChave ) )
				RecLock( cAlias, .T. )
				For nI := 1 To Len( aStruct )
					( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNUZ[nReg][nI] ) )
				Next
				MsUnLock()
			EndIf
		EndIf
	Next

If !lAutomato
	// Carga Inicial Prognóstico
	JA006CFG()

	//  Carga Inicial Tipo de Envolvidos
	JA009CFG()

	//  Carga Inicial Tipo de Follow-Up
	JA021CFG()

	//  Carga Inicial Tipo de Garantia
	JA024CFG()

	//  Carga Inicial Tipo de Despesa
	JA087CFG()

	//  Carga Inicial Tipo de Ação
	JA022Ws()

	//  Carga Inicial Comarcas CNJ
	JA005CFG()
EndIf

IncProc(STR0053)//'Finalizando'

EndIf

RestArea( aAreaNT9 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCpoPesq
Cria os campos e pesquisas do padrão

@author Jorge Luis Branco Martins Junior
@since 03/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCpoPesq(lAutomato)
Local aArea     := GetArea()
Local aAreaNTA  := NTA->( GetArea() )
Local aAreaNTE  := NTE->( GetArea() )
Local aAreaNSZ  := NSZ->( GetArea() )
Local aStruct   := {}
Local aDadosNVH := {}
Local aDadosNVG := {}
Local aChave    := {}
Local nReg      := 0
Local nI        := 0
Local lRet      := .T.
Local lNTECajuri:= .F.
Local cChave    := ''
Local cCPesq    := ''
Local cAlias    := 'NVH'
Local cFilTab   := xFilial( cAlias )
Local cTabNSY   := RetSqlName('NSY')
Local cTabNSZ   := RetSqlName('NSZ')
Local cTabNT3   := RetSqlName('NT3')
Local cTabNT4   := RetSqlName('NT4')
Local cTabNT9   := RetSqlName('NT9')
Local cTabNTA   := RetSqlName('NTA')
Local cTabNTE   := RetSqlName('NTE')
Local cTabNUQ   := RetSqlName('NUQ')
Local cTabNYJ   := RetSqlName('NYJ')
Local cFilNVH   := xFilial("NVH")
Local nTam      := 0

Default lAutomato := .F.

	ProcRegua(4)
	IncProc(STR0054)//'Gerando campos de pesquisa'

	//Config Campos Pesquisa
	aChave := StrToArray( FWX2Unico(cAlias), '+' )
	
	aAdd( aStruct, 'NVH_FILIAL' )
	aAdd( aStruct, 'NVH_COD'    )
	aAdd( aStruct, 'NVH_DESC'   )
	aAdd( aStruct, 'NVH_TABELA' )
	aAdd( aStruct, 'NVH_CAMPO'  )
	aAdd( aStruct, 'NVH_WHERE'  )
	aAdd( aStruct, 'NVH_PROPRI' )
	aAdd( aStruct, 'NVH_F3DIF'  )
	aAdd( aStruct, 'NVH_F3CONS' )
	aAdd( aStruct, 'NVH_RETF3'  )
	aAdd( aStruct, 'NVH_F3MULT' )
	aAdd( aStruct, 'NVH_TPPESQ' )

	IncProc(STR0054)//'Gerando campos de pesquisa'

	If Len( aDadosNVH ) == 0
		//                 FILIAL   COD    DESC                      TABELA   CAMPO         WHERE                    PROPRI   F3DIF   F3CONS   RETF3   F3MULT   TPPESQ
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_COD" )   , cTabNSZ, "NSZ_COD"   , J163Where("NSZ_COD")      , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CCLIEN" ), cTabNSZ, "NSZ_CCLIEN", J163Where("NSZ_CCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_LCLIEN" ), cTabNSZ, "NSZ_LCLIEN", J163Where("NSZ_LCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMCAS" ), cTabNSZ, "NSZ_NUMCAS", J163Where("NSZ_NUMCAS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CESCRI" ), cTabNSZ, "NSZ_CESCRI", J163Where("NSZ_CESCRI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CAREAJ" ), cTabNSZ, "NSZ_CAREAJ", J163Where("NSZ_CAREAJ")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_COBJET" ), cTabNSZ, "NSZ_COBJET", J163Where("NSZ_COBJET")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CPROGN" ), cTabNSZ, "NSZ_CPROGN", J163Where("NSZ_CPROGN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CRITO" ) , cTabNSZ, "NSZ_CRITO" , J163Where("NSZ_CRITO")    , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DETALH" ), cTabNSZ, "NSZ_DETALH", J163Where("NSZ_DETALH")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTENCE" ), cTabNSZ, "NSZ_DTENCE", J163Where("NSZ_DTENCE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTENTR" ), cTabNSZ, "NSZ_DTENTR", J163Where("NSZ_DTENTR")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTINCL" ), cTabNSZ, "NSZ_DTINCL", J163Where("NSZ_DTINCL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_DTDIST" ), cTabNUQ, "NUQ_DTDIST", J163Where("NUQ_DTDIST")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_USUINC" ), cTabNSZ, "NSZ_USUINC", J163Where("NSZ_USUINC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_LITISC" ), cTabNSZ, "NSZ_LITISC", J163Where("NSZ_LITISC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_SIGLA1" ), cTabNSZ, "NSZ_SIGLA1", J163Where("NSZ_SIGLA1")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_SIGLA2" ), cTabNSZ, "NSZ_SIGLA2", J163Where("NSZ_SIGLA2")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_SITUAC" ), cTabNSZ, "NSZ_SITUAC", J163Where("NSZ_SITUAC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_VLCAUS" ), cTabNSZ, "NSZ_VLCAUS", J163Where("NSZ_VLCAUS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_CEMPCL" ), cTabNT9, "NT9_CEMPCL", J163Where("NT9_CEMPCL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_NOME" )  , cTabNT9, "NT9_NOME"  , J163Where("NT9_NOME")     , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CCOMAR" ), cTabNUQ, "NUQ_CCOMAR", J163Where("NUQ_CCOMAR")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CDECIS" ), cTabNUQ, "NUQ_CDECIS", J163Where("NUQ_CDECIS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CLOC2N" ), cTabNUQ, "NUQ_CLOC2N", J163Where("NUQ_CLOC2N")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CLOC3N" ), cTabNUQ, "NUQ_CLOC3N", J163Where("NUQ_CLOC3N")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CNATUR" ), cTabNUQ, "NUQ_CNATUR", J163Where("NUQ_CNATUR")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CTIPAC" ), cTabNUQ, "NUQ_CTIPAC", J163Where("NUQ_CTIPAC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_INSATU" ), cTabNUQ, "NUQ_INSATU", J163Where("NUQ_INSATU")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_INSTAN" ), cTabNUQ, "NUQ_INSTAN", J163Where("NUQ_INSTAN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CCORRE" ), cTabNUQ, "NUQ_CCORRE", J163Where("NUQ_CCORRE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_LCORRE" ), cTabNUQ, "NUQ_LCORRE", J163Where("NUQ_LCORRE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_NUMPRO" ), cTabNUQ, "NUQ_NUMPRO", J163Where("NUQ_NUMPRO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSY_CPEVLR" ), cTabNSY, "NSY_CPEVLR", J163Where("NSY_CPEVLR")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CGRCLI" ), cTabNSZ, "NSZ_CGRCLI", J163Where("NSZ_CGRCLI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMERO" ), cTabNSZ, "NSZ_NUMERO", J163Where("NSZ_NUMERO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT4_CJZREL" ), cTabNT4, "NT4_CJZREL", J163Where("NT4_CJZREL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT4_CJZREV" ), cTabNT4, "NT4_CJZREV", J163Where("NT4_CJZREV")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT4_CJZVOG" ), cTabNT4, "NT4_CJZVOG", J163Where("NT4_CJZVOG")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT4_CPERIT" ), cTabNT4, "NT4_CPERIT", J163Where("NT4_CPERIT")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_INSEST" ), cTabNSZ, "NSZ_INSEST", J163Where("NSZ_INSEST")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_INSMUN" ), cTabNSZ, "NSZ_INSMUN", J163Where("NSZ_INSMUN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_SOLICI" ), cTabNSZ, "NSZ_SOLICI", J163Where("NSZ_SOLICI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CDPSOL" ), cTabNSZ, "NSZ_CDPSOL", J163Where("NSZ_CDPSOL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTEMIS" ), cTabNSZ, "NSZ_DTEMIS", J163Where("NSZ_DTEMIS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CTPSOC" ), cTabNSZ, "NSZ_CTPSOC", J163Where("NSZ_CTPSOC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CAREAN" ), cTabNSZ, "NSZ_CAREAN", J163Where("NSZ_CAREAN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CODCON" ), cTabNSZ, "NSZ_CODCON", J163Where("NSZ_CODCON")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CDPSOL" ), cTabNSZ, "NSZ_CDPSOL", J163Where("NSZ_CDPSOL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTADIT" ), cTabNSZ, "NSZ_DTADIT", J163Where("NSZ_DTADIT")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTASSI" ), cTabNSZ, "NSZ_DTASSI", J163Where("NSZ_DTASSI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTINVI" ), cTabNSZ, "NSZ_DTINVI", J163Where("NSZ_DTINVI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTTMVI" ), cTabNSZ, "NSZ_DTTMVI", J163Where("NSZ_DTTMVI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_IDENTI" ), cTabNSZ, "NSZ_IDENTI", J163Where("NSZ_IDENTI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMREG" ), cTabNSZ, "NSZ_NUMREG", J163Where("NSZ_NUMREG")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_REGULA" ), cTabNSZ, "NSZ_REGULA", J163Where("NSZ_REGULA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_RENOVA" ), cTabNSZ, "NSZ_RENOVA", J163Where("NSZ_RENOVA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_CTPENV" ), cTabNT9, "NT9_CTPENV", J163Where("NT9_CTPENV")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_SUBEST" ), cTabNSZ, "NSZ_SUBEST", J163Where("NSZ_SUBEST")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_TPPROC" ), cTabNSZ, "NSZ_TPPROC", J163Where("NSZ_TPPROC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CSBPRO" ), cTabNSZ, "NSZ_CSBPRO", J163Where("NSZ_CSBPRO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_ALTPOS" ), cTabNSZ, "NSZ_ALTPOS", J163Where("NSZ_ALTPOS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_ALVARA" ), cTabNSZ, "NSZ_ALVARA", J163Where("NSZ_ALVARA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_CGC" )   , cTabNT9, "NT9_CGC"   , J163Where("NT9_CGC")      , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_DTENTR" ), cTabNT9, "NT9_DTENTR", J163Where("NT9_DTENTR")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_DTSAID" ), cTabNT9, "NT9_DTSAID", J163Where("NT9_DTSAID")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_CNAE" )  , cTabNYJ, "NYJ_CNAE"  , J163Where("NYJ_CNAE")     , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_DTENCE" ), cTabNYJ, "NYJ_DTENCE", J163Where("NYJ_DTENCE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_INSEST" ), cTabNYJ, "NYJ_INSEST", J163Where("NYJ_INSEST")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_INSMUN" ), cTabNYJ, "NYJ_INSMUN", J163Where("NYJ_INSMUN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_NIRE" )  , cTabNYJ, "NYJ_NIRE"  , J163Where("NYJ_NIRE")     , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NYJ_VLCAPI" ), cTabNYJ, "NYJ_VLCAPI", J163Where("NYJ_VLCAPI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT9_TIPOP" ) , cTabNT9, "NT9_TIPOP" , J163Where("NT9_TIPOP")    , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMLIC" ), cTabNSZ, "NSZ_NUMLIC", J163Where("NSZ_NUMLIC")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CCRIJU" ), cTabNSZ, "NSZ_CCRIJU", J163Where("NSZ_CCRIJU")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CMODLI" ), cTabNSZ, "NSZ_CMODLI", J163Where("NSZ_CMODLI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTLICI" ), cTabNSZ, "NSZ_DTLICI", J163Where("NSZ_DTLICI")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_DTCERT" ), cTabNSZ, "NSZ_DTCERT", J163Where("NSZ_DTCERT")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CTIPMA" ), cTabNSZ, "NSZ_CTIPMA", J163Where("NSZ_CTIPMA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NOMEMA" ), cTabNSZ, "NSZ_NOMEMA", J163Where("NSZ_NOMEMA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CSITMA" ), cTabNSZ, "NSZ_CSITMA", J163Where("NSZ_CSITMA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CNATMA" ), cTabNSZ, "NSZ_CNATMA", J163Where("NSZ_CNATMA")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CREGIO" ), cTabNSZ, "NSZ_CREGIO", J163Where("NSZ_CREGIO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CCLASS" ), cTabNSZ, "NSZ_CCLASS", J163Where("NSZ_CCLASS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CODWF" ),  cTabNSZ, "NSZ_CODWF",  J163Where("NSZ_CODWF")    , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTE_SIGLA" ) , cTabNTE, "NTE_SIGLA" , J163Where("NTE_SIGLA")    , .F.    , .F.  ,  ''     , ''   , .F.     , '1'} )

		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTA_CTIPO" ) , cTabNTA, "NTA_CTIPO" , J163Where("NTA_CTIPO")    , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMERO" ), cTabNSZ, "NSZ_NUMERO", J163Where("NSZ_NUMERO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CCLIEN" ), cTabNSZ, "NSZ_CCLIEN", J163Where("NSZ_CCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_LCLIEN" ), cTabNSZ, "NSZ_LCLIEN", J163Where("NSZ_LCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMCAS" ), cTabNSZ, "NSZ_NUMCAS", J163Where("NSZ_NUMCAS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_TIPOAS" ), cTabNSZ, "NSZ_TIPOAS", J163Where("NSZ_TIPOAS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , STR0058                 , cTabNTA, "NTA_DTFLWP", J163Where("NTA_DTFLWP", 1), .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , STR0059                 , cTabNTA, "NTA_DTFLWP", J163Where("NTA_DTFLWP", 2), .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTA_CODWF" ) , cTabNTA, "NTA_CODWF",  J163Where("NTA_CODWF")    , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTE_SIGLA" ) , cTabNTE, "NTE_SIGLA" , J163Where("NTE_SIGLA")    , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTA_CRESUL" ), cTabNTA, "NTA_CRESUL", J163Where("NTA_CRESUL")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NTA_CPREPO" ), cTabNTA, "NTA_CPREPO", J163Where("NTA_CPREPO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_CCORRE" ), cTabNUQ, "NUQ_CCORRE", J163Where("NUQ_CCORRE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_LCORRE" ), cTabNUQ, "NUQ_LCORRE", J163Where("NUQ_LCORRE")   , .F.    , .F.  ,  ''     , ''   , .F.     , '2'} )

		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT3_CTPDES" ), cTabNT3, "NT3_CTPDES", J163Where("NT3_CTPDES")   , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NT3_DATA" )  , cTabNT3, "NT3_DATA"  , J163Where("NT3_DATA")     , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_CCLIEN" ), cTabNSZ, "NSZ_CCLIEN", J163Where("NSZ_CCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_LCLIEN" ), cTabNSZ, "NSZ_LCLIEN", J163Where("NSZ_LCLIEN")   , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NSZ_NUMCAS" ), cTabNSZ, "NSZ_NUMCAS", J163Where("NSZ_NUMCAS")   , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )
		aAdd( aDadosNVH, { cFilTab,      , RetTitle( "NUQ_NUMPRO" ), cTabNUQ, "NUQ_NUMPRO", J163Where("NUQ_NUMPRO")   , .F.    , .F.  ,  ''     , ''   , .F.     , '5'} )

	EndIf

	IncProc(STR0054)//'Gerando campos de pesquisa'

	For nReg := 1 To Len( aDadosNVH )

		If aDadosNVH[nReg][1] == xFilial( 'NVH' )

			aDadosNVH[nReg][2] := GetSXENUM( 'NVH', 'NVH_COD' )

			cChave := ''
			For nI := 1 To Len( aChave )
				cChave += aDadosNVH[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
			Next

			( cAlias )->( dbSetOrder( 1 ) )
			If !lAutomato
				If !( cAlias )->( dbSeek ( cChave ) )
					RecLock( cAlias, .T.  )
					For nI := 1 To Len( aStruct )
						( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNVH[nReg][nI] ) )
					Next
					MsUnLock()
					If __lSX8
						ConfirmSX8()
					Else
						RollBackSX8()
					EndIf
				Else
					RollBackSX8()
				EndIf
			EndIf

		EndIf

	Next

	IncProc(STR0054)//'Gerando campos de pesquisa'

	ProcRegua(14)
	IncProc(STR0055)//'Gerando pesquisas'

	// Layout Campos Pesquisa
	aStruct  := {}
	aChave   := {}
	cChave   := ''
	cAlias   := 'NVG'
	cFilTab  := xFilial( cAlias )

	aChave := StrToArray( FWX2Unico(cAlias), '+' )
	
	aAdd( aStruct, 'NVG_FILIAL' )
	aAdd( aStruct, 'NVG_COD'    )
	aAdd( aStruct, 'NVG_CPESQ'  )
	aAdd( aStruct, 'NVG_DESC'   )
	aAdd( aStruct, 'NVG_CCAMPO' )
	aAdd( aStruct, 'NVG_SUGEST' )
	aAdd( aStruct, 'NVG_VISIVE' )
	aAdd( aStruct, 'NVG_ENABLE' )
	aAdd( aStruct, 'NVG_TPPESQ' )

	IncProc(STR0055)//'Gerando pesquisas'

	If Len( aDadosNVG ) == 0

		nTam   := Len(SX3->X3_CAMPO)

		cCPesq := JA163NewCPq()
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CAREAJ", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COBJET", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CPROGN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CRITO" , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_DTDIST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_USUINC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LITISC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_VLCAUS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCOMAR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CDECIS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC2N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC3N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CNATUR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CTIPAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSATU", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSTAN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_LCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035, JurGetDados("NVH", 3, cFilNVH + Padr("NSY_CPEVLR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contencioso'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'

		If lNTECajuri .And. !Empty(AllTrim(JurGetDados("NVH", 3, cFilNVH + Padr("NTE_SIGLA" , nTam) + "2", "NVH_COD" )))
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTE_SIGLA" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		EndIf
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCORRE", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_LCORRE", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contencioso'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CGRCLI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COBJET", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_DTDIST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LITISC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NT4_CJZREL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NT4_CJZREV", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NT4_CJZVOG", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NT4_CPERIT", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCOMAR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_LCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CDECIS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC2N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC3N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CNATUR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CTIPAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSATU", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSTAN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Criminal'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Criminal'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSY_CPEVLR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CGRCLI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COBJET", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_DTDIST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_INSEST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_INSMUN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LITISC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SOLICI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCOMAR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_LCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CDECIS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC2N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC3N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CTIPAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSATU", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSTAN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Administrativo'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Administrativo'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CGRCLI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCOMAR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CDECIS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC2N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CLOC3N", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSATU", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_INSTAN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Cade'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Cade'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CAREAJ", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CDPSOL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTEMIS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CTPSOC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CAREAN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SOLICI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Consultivo'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Consultivo'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CODCON", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CDPSOL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTADIT", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTASSI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINVI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTTMVI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_IDENTI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMREG", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_REGULA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_RENOVA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SOLICI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Contratos'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Contratos'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTASSI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DETALH", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SOLICI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CTPENV", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SUBEST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TPPROC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CTPSOC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CSBPRO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Procurações'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Procurações'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_ALTPOS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_ALVARA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CTPSOC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_INSEST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_INSMUN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CGC"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CTPENV", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_DTSAID", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_CNAE"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_INSEST", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_INSMUN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_NIRE"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042, JurGetDados("NVH", 3, cFilNVH + Padr("NYJ_VLCAPI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Societário'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Societário'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENCE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTENTR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_TIPOP" , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCOMAR", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_CCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_LCORRE", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Ofícios'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Ofícios'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CESCRI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_NOME"  , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMLIC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCRIJU", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CMODLI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTLICI", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTCERT", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Licitações'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Licitações'

		IncProc(STR0055)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NT9_CEMPCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_DTINCL", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA1", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SIGLA2", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CTIPMA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NOMEMA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CSITMA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_SITUAC", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_COD"   , nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CNATMA", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CREGIO", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLASS", nTam) + "1", "NVH_COD" ), ''     , .T.    , .T.    , '1' } ) //'Marcas e Patentes'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')

		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NTA_CTIPO" , nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMERO", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_TIPOAS", nTam) + "2", "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0058                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0057, JurGetDados("NVH", 2, cFilNVH + STR0059                       , "NVH_COD" ), ''     , .T.    , .T.    , '2' } ) //'Marcas e Patentes'

		IncProc(STR0055+"..."+STR0095)//'Gerando pesquisas'
		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0035+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contencioso-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0036+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Criminal-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0037+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Administrativo-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0038+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Cade-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0039+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Consultivo-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0040+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Contratos-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0041+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Procurações-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0042+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Societário-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0043+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Ofícios-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0044+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Licitações-Despesas'

		cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
		//                 FILIAL   COD    CPESQ   DESC     CCAMPO                                                                       SUGEST   VISIVE   ENABLE   TPPESQ
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_CTPDES", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NT3_DATA"  , nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_CCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_LCLIEN", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NSZ_NUMCAS", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'
		aAdd( aDadosNVG, { cFilTab,      , cCPesq, STR0045+'-'+STR0095, JurGetDados("NVH", 3, cFilNVH + Padr("NUQ_NUMPRO", nTam) + "5", "NVH_COD" ), ''     , .T.    , .T.    , '5' } ) //'Marcas e Patentes-Despesas'

	EndIf

	IncProc(STR0055)//'Gerando pesquisas'

	For nReg := 1 To Len( aDadosNVG )

		aDadosNVG[nReg][2] := GetSXENUM( 'NVG', 'NVG_COD',,2 )

		cChave := ''
		For nI := 1 To Len( aChave )
			cChave += aDadosNVG[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
		Next

		( cAlias )->( dbSetOrder( 1 ) )

		If !lAutomato
			If !( cAlias )->( dbSeek ( cChave ) )
				RecLock( cAlias, .T. )
				For nI := 1 To Len( aStruct )
					( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNVG[nReg][nI] ) )
				Next
				MsUnLock()
				If __lSX8
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			Else
				RollBackSX8()
			EndIf
		EndIf
	Next

	IncProc(STR0055)//'Gerando pesquisas'

	ProcRegua(0)
	IncProc(STR0056)//'Finalizando geração de pesquisas'

	// Seta chave e label dos campos de pesquisa na NVH
	JNVHLABEL()

RestArea( aAreaNSZ )
RestArea( aAreaNTE )
RestArea( aAreaNTA )
RestArea( aArea )


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JXLAtualiza(cTipoAs)
Efetua a carga inicial da tabela NSY caso não tenha rodado o Rup ou a Carga inicial 

@param 	cTipoAs     Assunto Juridico

@author Brenno Gomes
@since 01/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
function JXLAtualiza(cTipoAs, lAutomato)
Local aArea     := GetArea()
Local aStruct   := {}
Local aDadosNUZ := {}
Local aChave    := {}
Local cChave    := ''
Local nReg      := 0
Local nI        := 0
Local cAlias    := 'NUZ'
Local cFilTab   := xFilial( cAlias )

Default lAutomato := .F.

	aChave := StrToArray( FWX2Unico(cAlias), '+' )
	aAdd( aStruct, 'NUZ_FILIAL' )
	aAdd( aStruct, 'NUZ_CAMPO' )
	aAdd( aStruct, 'NUZ_DESCPO' )
	aAdd( aStruct, 'NUZ_CTAJUR' )
	
		//Detalhe
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPEVLR', RetTitle( 'NSY_CPEVLR' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPEVLR', RetTitle( 'NSY_DPEVLR' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CPROG' , RetTitle( 'NSY_CPROG' ) , cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DPROG' , RetTitle( 'NSY_DPROG' ) , cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CENVOL', RetTitle( 'NSY_CENVOL' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DENVOL', RetTitle( 'NSY_DENVOL' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DESC'  , RetTitle( 'NSY_DESC' )  , cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTULAT', RetTitle( 'NSY_DTULAT' ), cTipoAs } )
		
		//processo
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PATIVO', RetTitle( 'NSY_PATIVO' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PPASSI', RetTitle( 'NSY_PPASSI' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DSITUA', RetTitle( 'NSY_DSITUA' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_NUMPRO', RetTitle( 'NSY_NUMPRO' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTDIST', RetTitle( 'NSY_DTDIST' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CINSTA', RetTitle( 'NSY_CINSTA' ), cTipoAs } ) 
		//pedidos
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCOMON', RetTitle( 'NSY_CCOMON' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEDATA', RetTitle( 'NSY_PEDATA' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURO', RetTitle( 'NSY_DTJURO' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOPED', RetTitle( 'NSY_CMOPED' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOPED', RetTitle( 'NSY_DMOPED' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLR' , RetTitle( 'NSY_PEVLR' ) , cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULT', RetTitle( 'NSY_DTMULT' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUL', RetTitle( 'NSY_PERMUL' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEINVL', RetTitle( 'NSY_PEINVL' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PESOMA', RetTitle( 'NSY_PESOMA' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPE', RetTitle( 'NSY_CCORPE' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPE', RetTitle( 'NSY_CJURPE' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATU', RetTitle( 'NSY_MULATU' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PEVLRA', RetTitle( 'NSY_PEVLRA' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SPE'   , RetTitle( 'NSY_SPE' )   , cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SAPE'  , RetTitle( 'NSY_SAPE' )  , cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTPED', RetTitle( 'NSY_TOTPED') , cTipoAs } )  
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOPEAT', RetTitle( 'NSY_TOPEAT '), cTipoAs } )
		
		//contigência 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CFCORC', RetTitle( 'NSY_CFCORC' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DFCORC', RetTitle( 'NSY_DFCORC' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTCONT', RetTitle( 'NSY_DTCONT' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTJURC', RetTitle( 'NSY_DTJURC' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CMOCON', RetTitle( 'NSY_CMOCON' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DMOCON', RetTitle( 'NSY_DMOCON' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DCOMON', RetTitle( 'NSY_DCOMON' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_DTMULC', RetTitle( 'NSY_DTMULC' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_PERMUC', RetTitle( 'NSY_PERMUC' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SOMCON', RetTitle( 'NSY_SOMCON' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_INECON', RetTitle( 'NSY_INECON' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONT', RetTitle( 'NSY_VLCONT' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CCORPC', RetTitle( 'NSY_CCORPC' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_CJURPC', RetTitle( 'NSY_CJURPC' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_MULATC', RetTitle( 'NSY_MULATC' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_VLCONA', RetTitle( 'NSY_VLCONA' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONT', RetTitle( 'NSY_SLCONT' ), cTipoAs } ) 
		aAdd( aDadosNUZ, { cFilTab, 'NSY_SLCONA', RetTitle( 'NSY_SLCONA' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTORC', RetTitle( 'NSY_TOTORC' ), cTipoAs } )
		aAdd( aDadosNUZ, { cFilTab, 'NSY_TOTATC', RetTitle( 'NSY_TOTATC' ), cTipoAs } ) 

		For nReg := 1 To Len( aDadosNUZ )

			cChave := ''
			For nI := 1 To Len( aChave )
				cChave += aDadosNUZ[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
			Next

			If !lAutomato
				( cAlias )->( dbSetOrder( 1 ) )
				If !( cAlias )->( dbSeek ( cChave ) )
					RecLock( cAlias, .T. )
					For nI := 1 To Len( aStruct )
						( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNUZ[nReg][nI] ) )
					Next
					MsUnLock()
				EndIf
			EndIf
		Next
		
	aSize(aStruct,0)
	aSize(aDadosNUZ,0)
	aSize(aChave,0)
	
	RestArea( aArea )
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JNVHLABEL()
COMPLEMENTA A NVH COM CHAVE E LABEL PARA UTILIZAR NO CAMPO F3 DO TOTVS LEGAL

@since 	09/04/2021
/*/
//-------------------------------------------------------------------
Function JNVHLABEL()
Local aArea      := GetArea()
Local cAliasNVH  := GetNextAlias()
Local aStruct    := {"NVH_FILIAL", "NVH_COD", "NVH_CAMPO", "NVH_TPPESQ", "NVH_CHAVE", "NVH_LABEL"}
Local aDados     := {}
Local cTabela    := ""
Local cChave     := ""
Local cLabel     := ""
Local aTabelas   := {}
Local nPos       := 0
Local lBusca     := .T.

	DbSelectArea("NVH")
	If NVH->(FieldPos("NVH_LABEL")) > 0

		//Array com chave e label das tabelas
		Aadd(aTabelas, {'CTT','CTT_DESC01'})
		Aadd(aTabelas, {'NRL','NRL_DESC'})
		Aadd(aTabelas, {'NYJ','NYJ_NOMEFT'})
		Aadd(aTabelas, {'O0A','O0A_DESC'})
		Aadd(aTabelas, {'CC2','CC2_MUN'})
		Aadd(aTabelas, {'NY3','NY3_DESC'})
		Aadd(aTabelas, {'SQ3','Q3_DESCSUM'})
		Aadd(aTabelas, {'NRS','NRS_DADVPC'})
		Aadd(aTabelas, {'NQY','NQY_DESC'})
		Aadd(aTabelas, {'NVE','NVE_DGRPCL'})
		Aadd(aTabelas, {'ACY','ACY_DESCRI'})
		Aadd(aTabelas, {'CTO','CTO_DESC'})
		Aadd(aTabelas, {'NQS','NQS_DESC'})
		Aadd(aTabelas, {'NQW','NQW_DESC'})
		Aadd(aTabelas, {'NSR','NSR_DESC'})
		Aadd(aTabelas, {'NSV','NSV_DESC'})
		Aadd(aTabelas, {'NSW','NSW_DESC'})
		Aadd(aTabelas, {'NUL','NUL_DESC'})
		Aadd(aTabelas, {'NWY','NWY_DESC'})
		Aadd(aTabelas, {'NXT','NXT_DESC'})
		Aadd(aTabelas, {'NXU','NXU_DESC'})
		Aadd(aTabelas, {'NXZ','NXZ_DESC'})
		Aadd(aTabelas, {'NY0','NY0_DESC'})
		Aadd(aTabelas, {'NYQ','NYQ_DESC'})
		Aadd(aTabelas, {'SAL','AL_DESC'})
		Aadd(aTabelas, {'SB1','B1_DESC'})
		Aadd(aTabelas, {'SED','ED_DESCRIC'})
		Aadd(aTabelas, {'SRJ','RJ_DESC'})
		Aadd(aTabelas, {'CC3','CC3_DESC'})
		Aadd(aTabelas, {'NQ1','NQ1_DESC'})
		Aadd(aTabelas, {'NQ4','NQ4_DESC'})
		Aadd(aTabelas, {'NQ6','NQ6_DESC'})
		Aadd(aTabelas, {'NQ7','NQ7_DESC'})
		Aadd(aTabelas, {'NQA','NQA_DESC'})
		Aadd(aTabelas, {'NQC','NQC_DESC'})
		Aadd(aTabelas, {'NQE','NQE_DESC'})
		Aadd(aTabelas, {'NQG','NQG_DESC'})
		Aadd(aTabelas, {'NQI','NQI_DESC'})
		Aadd(aTabelas, {'NQN','NQN_DESC'})
		Aadd(aTabelas, {'NQO','NQO_DESC'})
		Aadd(aTabelas, {'NQQ','NQQ_DESC'})
		Aadd(aTabelas, {'NQU','NQU_DESC'})
		Aadd(aTabelas, {'NQX','NQX_DESC'})
		Aadd(aTabelas, {'NRB','NRB_DESC'})
		Aadd(aTabelas, {'NRO','NRO_DESC'})
		Aadd(aTabelas, {'NRP','NRP_DESC'})
		Aadd(aTabelas, {'NS6','NS6_DESC'})
		Aadd(aTabelas, {'NSP','NSP_DESC'})
		Aadd(aTabelas, {'NT0','NT0_NOME'})
		Aadd(aTabelas, {'NTB','NTB_DESC'})
		Aadd(aTabelas, {'NW7','NW7_DESC'})
		Aadd(aTabelas, {'NY4','NY4_DESC'})
		Aadd(aTabelas, {'NY5','NY5_DESC'})
		Aadd(aTabelas, {'NY6','NY6_DESC'})
		Aadd(aTabelas, {'NY7','NY7_DESC'})
		Aadd(aTabelas, {'NY8','NY8_DESC'})
		Aadd(aTabelas, {'NY9','NY9_DESC'})
		Aadd(aTabelas, {'NYA','NYA_DESC'})
		Aadd(aTabelas, {'NYB','NYB_DESC'})
		Aadd(aTabelas, {'NYI','NYI_DESC'})
		Aadd(aTabelas, {'NZA','NZA_DESC'})
		Aadd(aTabelas, {'O01','O01_DESC'})
		Aadd(aTabelas, {'O03','O03_DESC'})
		Aadd(aTabelas, {'O04','O04_DESC'})
		Aadd(aTabelas, {'O0R','O0R_DESC'})
		Aadd(aTabelas, {'NSQ','NSQ_DESC'})
		Aadd(aTabelas, {'SA1','A1_NOME'})
		Aadd(aTabelas, {'SA2','A2_NOME'})
		Aadd(aTabelas, {'NQH','NQH_NOME'})
		Aadd(aTabelas, {'NQL','NQL_NOME'})
		Aadd(aTabelas, {'NQM','NQM_DESC'})
		Aadd(aTabelas, {'NS7','NS7_NOME'})
		Aadd(aTabelas, {'SU5','U5_CONTAT'})
		Aadd(aTabelas, {'RD0','RD0_NOME'})
		Aadd(aTabelas, {'NQR','NQR_NOMRPT'})
		Aadd(aTabelas, {'O0L','O0L_NOME'})
		Aadd(aTabelas, {'SA6','A6_NOME'})
		Aadd(aTabelas, {'CTJ','CTJ_DESC'})
		Aadd(aTabelas, {'SE4','E4_DESCRI'})

		//Busca campos NVH para atualizar
		cQuery := "SELECT DISTINCT NVH_FILIAL, NVH_COD, NVH_CAMPO, NVH_TPPESQ, NVH_CHAVE, NVH_LABEL "
		cQuery +=  " FROM " + RetSqlName("NVH") + " WHERE D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery, .F.)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNVH, .F., .F. )

		While (!(cAliasNVH)->(Eof()))
			// Valida se é F3
			If !Empty(GetSx3Cache((cAliasNVH)->NVH_CAMPO,"X3_F3"))

				cLabel := ''
				cChave := ''
				cTabela:= PadL(SubStr((cAliasNVH)->NVH_CAMPO, 1, At("_",(cAliasNVH)->NVH_CAMPO)-1), 3, "S")

				//BUSCA RELACIONAMENTO
				SX9->(dbsetorder(2))
				SX9->(DBSeek(cTabela))
				lBusca := .T.
				nPos   := 0

				While !(SX9->(Eof())) .And. (SX9->X9_CDOM == cTabela .And. lBusca)

					If AllTrim(SX9->X9_EXPCDOM) == AllTrim((cAliasNVH)->NVH_CAMPO)
						cTabela := SX9->X9_DOM
						cChave  := SX9->X9_EXPDOM
						nPos    := aScan(aTabelas, {|x| x[1] == cTabela})
						If nPos > 0
							cLabel  := aTabelas[nPos][2]
						EndIf

						lBusca  := .F.
					EndIf
					SX9->(dbSkip())
				End

				If (cAliasNVH)->NVH_CAMPO $(' NSZ_CCLIEN | NT9_CEMPCL ')
					cChave := 'A1_COD'
					cLabel := 'A1_NOME'
				elseif (cAliasNVH)->NVH_CAMPO $(' NSZ_NUMCAS ')
					cChave := 'NVE_NUMCAS'
					cLabel := 'NVE_TITULO'
				elseif (cAliasNVH)->NVH_CAMPO $(' NSZ_SIGLA1 | NSZ_SIGLA2 | NTE_SIGLA ')
					cChave := 'RD0_SIGLA'
					cLabel := 'RD0_NOME'
				elseif (cAliasNVH)->NVH_CAMPO $(' NUQ_CCORRE ')
					cChave := 'A2_COD'
					cLabel := 'A2_NOME'
				EndIf

				Aadd(aDados, {(cAliasNVH)->NVH_FILIAL, (cAliasNVH)->NVH_COD, (cAliasNVH)->NVH_CAMPO, (cAliasNVH)->NVH_TPPESQ,cChave,cLabel})
			EndIf

			(cAliasNVH)->( dbSkip() )
		End

		If Len(aDados) > 0
			AtuNVH(aStruct, aDados)
		EndIf

		(cAliasNVH)->(dbCloseArea())
		NVH->(dbCloseArea())

		RestArea(aArea)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNVH( aStruct, aDadosNVH)
Inclui novos registro na tabela NVH - Campos Pesquisa
RUP_JURI

@param	aStruct 	- Estrutura dos campos que seram atualizados
@param	aDadosNVH	- Conteudo dos campos que seram atualizados
@param	lForcaInc	- Define se ira forcar a inclusao mesmo se ja encontrar o campo

@author Rafael Tenorio da Costa
@since 10/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtuNVH(aStruct, aDadosNVH, lForcaInc)
Local aArea		:= GetArea()
Local cChave   	:= ""
Local cTabAtu   := "NVH"
Local nReg		:= 0
Local nI		:= 0
Local nPosCod	:= Ascan( aStruct, {|x| x == 'NVH_COD'} )
Local nPosCampo	:= Ascan( aStruct, {|x| x == 'NVH_CAMPO'} )
Local nPosTpPes	:= Ascan( aStruct, {|x| x == 'NVH_TPPESQ'} )
Local lNovo		:= .F.

Default lForcaInc := .F.

	//Se a tabela nao estiver vazia inclui os registros, caso esteja vazia nao faz nada, para deixar a rotina jura163 gerar essa tabela
	If !JurTabEmpt('NVH') .And. nPosCampo > 0 .And. nPosTpPes > 0

		DbSelectArea(cTabAtu)

		//Config Campos Pesquisa
		For nReg := 1 To Len( aDadosNVH )

			lNovo	:= .F.
			cChave 	:= xFilial(cTabAtu) + PadR(aDadosNVH[nReg][nPosCampo], TamSx3("NVH_CAMPO")[1]) + aDadosNVH[nReg][nPosTpPes]

			// Inclui
			( cTabAtu )->( dbSetOrder( 3 ) ) //NVH_FILIAL + NVH_CAMPO + NVH_TPPESQ
			If !( cTabAtu )->( dbSeek ( cChave ) ) .Or. lForcaInc

				//Gera codigo do registro
				cCodNVH := GetSXENUM('NVH', 'NVH_COD')
				lNovo	:= .T.

				If nPosCod == 0
					Aadd(aDadosNVH[nReg], "")
					nPosCod := Len(aDadosNVH[nReg])
				EndIf

				aDadosNVH[nReg][nPosCod] := cCodNVH

			//Altera
			Else
				aDadosNVH[nReg][nPosCod] := NVH->NVH_COD
			EndIf

			//Grava os dados
			RecLock( cTabAtu, lNovo )
			For nI := 1 To Len( aStruct )
				( cTabAtu )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNVH[nReg][nI] ) )
			Next nI
			(cTabAtu)->( MsUnLock() )

			If lNovo
				If __lSX8
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			EndIf

		Next nReg
	EndIf

	RestArea( aArea )

Return Nil

