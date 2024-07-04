//################################################################################
//################################################################################
//################################################################################
//#####                                                                      #####
//#####     DESCONTINUADO NAO UTILIZAR, REFERENCIE DMS_ NOS FONTES VEICLS    #####
//#####                                                                      #####
//#####                                                                      #####
//################################################################################
//################################################################################
//################################################################################

// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 36     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "VEIXFUNB.CH"

STATIC cSGBD := TcGetDb()

Function VEIXFUNB
Return()

/*/{Protheus.doc} Mil_ArrayHelper

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de arrays no protheus
/*/
Class Mil_ArrayHelper
	Method New() CONSTRUCTOR
	Method Join()
	Method Map()
	Method LastIndex()
	Method Count()
	Method Sum()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_ArrayHelper
	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class Mil_ArrayHelper
Return SELF

/*/{Protheus.doc} Count
	Usado para contar numero de registros que seja compativel com o retorno do bloco passado por parametro que normalmente é usado para filtro

	@author  Vinicius Gati
	@since   05/05/2014
	@param   bBlock , bloco , Bloco que deve retornar .T. ou .F. para filtrar os dados como um seletor e definir se vai somar +1 ao Count
	@example Mil_DataContainer:Count()

/*/
Method Count(aArr, bBlock) Class Mil_ArrayHelper
	Local nQtd := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(aArr, { |el| IIF( EVAL(bBlock, el) , nQtd++, Nil ) })
	Else
		nQtd := Len(aArr)
	EndIf
Return nQtd

/*/{Protheus.doc} Join
	Junta os elementos do array como string com a string passada por parametro no cJoinStr

	@author Vinicius Gati
	@since 05/05/2014
	@param aArr    , Array , Array de strings usado para fazer join
	@param cJoinStr, String, String usada no join
	@example 'Gosto de comer:' + Join({'banana', 'maçã', 'uva'}, ', ')
						Returns: 'banana, maçã, uva'
						Same As: 'Gosto de comer:' + 'banana, maçã, uva'
/*/
Method Join(aArr, cJoinStr) Class Mil_ArrayHelper
	Local nIdx := 1
	Local cAux := ''
	For nIdx := 1 To Len(aArr)
		cAux += aArr[nIdx]
		If nIdx < Len(aArr)
			cAux += cJoinStr
		EndIf
//  'Arroz' + ', '(cJoinStr) ...e assim vai...
	Next
Return cAux

/*/{Protheus.doc} Map
	Transforma aArr em outro array modificado de acordo como bBlock

	@author   Vinicius Gati
	@since    05/05/2014
	@param    aArr    , Array, Array que será modificado de acordo com a execução do bloco
	@param    bBlock  , Bloco, String usada no join
	@example  'Gosto de comer:' + Join({'banana', 'maçã', 'uva'}, ', ')
						Returns: 'banana, maçã, uva'
						Same As: 'Gosto de comer:' + 'banana, maçã, uva'
/*/
Method Map(aArr, bBlock) Class Mil_ArrayHelper
	Local aNewArr := {}
	Local nIdx    := 1

	If VALTYPE(bBlock) == 'B'
		For nIdx := 1 To Len(aArr)
			AADD(aNewArr, EVAL(bBlock, aArr[nIdx]))				
		Next
	Else
		aNewArr := aArr
	EndIf
Return IIF( Empty(aNewArr), aArr, aNewArr )

/*/{Protheus.doc} LastIndex
	Retorna .T. caso nIdx seja o indice final do array e .F. caso contrario

	@author   Vinicius Gati
	@since    05/05/2014
	@param    nIdx  , numeroico, Indice de teste
	@param    aArr  , Array, Array 
	@example  IIF(oArrHlp:LastIndex(nIdx, aArr), .T., .F.) // => .T.
/*/
Method LastIndex(nIdx, aArr) Class Mil_ArrayHelper
Return  nIdx == Len(aArr)

/*/{Protheus.doc} Sum
	Faz a soma geral do indice de todo o array e retorna o resultado

	@author   Vinicius Gati
	@since    05/05/2014
	@param    aArr    , Array, Array contendo os dados para soma
	@param    bBlock  , Bloco, bloco que retorne .T. ou .F.
	@return   nSum    , Numerico, Soma total do array
/*/
Method Sum(nIdx, aArr, bBlock) Class Mil_ArrayHelper
	Local nSum := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(aArr, { |el| IIF(EVAL(bBlock, el), nSum += el[nIdx], Nil) })
	Else
		AEVAL(aArr, { |el| nSum += el[nIdx] })
	EndIf
Return nSum

/*/{Protheus.doc} Mil_DataContainer
	Ajuda ao trabalhar com arrays com indices intuitivos e metodos mais poderosos de contagem e soma.
	Utilizar com cautela, em volume baixo de dados para evitar overhead de metodos, para maior volume de dados ainda nao existe uma solucao.

	@author       Vinicius Gati
	@since        17/04/14
	@description  Utiliza array de arrays para salvar, recuperar e executar operacoes com dados complexos.
/*/
Class Mil_DataContainer
	Data aData

	METHOD New() CONSTRUCTOR
	METHOD GetValue()
	METHOD SetValue()
	METHOD Sum()
	METHOD Count()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_DataContainer
	@author Vinicius Gati
	@since 05/05/2014
/*/
METHOD New(aDataValues) Class Mil_DataContainer
	::aData := aDataValues
Return SELF

/*/{Protheus.doc} GetValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   05/05/2014
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
	@example oObj := Mil_DataContainer:New({ {'Nome', 'Vinicius'} })
						oObj:GetValue('Nome')      => 'Vinicius'
						oObj:GetValue('Idade', 18) => 18
/*/
METHOD GetValue(cLabel, cRetPad) Class Mil_DataContainer
	Default cRetPad := cLabel
	nIndex := ASCAN( ::aData, {|el| el[1] == cLabel } )
	If nIndex < 1
		value := cRetPad
	Else
		value := ::aData[nIndex][2]
	EndIf
Return value

/*/{Protheus.doc} SetValue
	Seta o valor relacionado ao label

	@author  Vinicius Gati
	@since   05/05/2014
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   vValue  , Any, Valor que será setado no lavel
	@example oObj := Mil_DataContainer:New({ {'Nome', 'Vinicius'} })
						oObj:SetValue('Nome', 'Otavio')      => 'Otavio'
						oObj:GetValue('Nome')                => 'Otavio'
	@return  nil em caso de não encontrar o label
/*/
METHOD SetValue(cLabel, vValue) Class Mil_DataContainer
	nIndex := ASCAN( ::aData, { |el| el[1] == cLabel } )
	if nIndex > 0
		::aData[nIndex][2] := vValue
	Else
		return nil
	Endif
Return vValue

/*/{Protheus.doc} Sum
	Usado fazer a soma de um determinado valor dos dados do Obj

	@author Vinicius Gati
	@since 05/05/2014
	@param cField  , Array, Label para pegar o valor por getValue
	@param bBlock  , Bloco, Bloco que será avaliado como filtro da soma, deve retornar .T. ou .F., usado para filtrar quais elementos serão filtrados, por exemplo de {1,2,3,4} quero somente a soma dos numeros pares
	@example oObj := Mil_DataContainer:New({{'Nome', 'Vinicius'}, {'Quantidade', 14}})
						oObj:Sum('Quantidade', {|el| el:GetValue('Nome' == 'Vinicius')}) // soma somente quando o nome for Vinicius
						oObj:Sum('Quantidade')                                           // Soma a quantidade de todos os dados contidos no container
/*/
METHOD Sum(cField, bBlock) Class Mil_DataContainer
	Local nSum := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(::aData, { |el| IIF(EVAL(bBlock, el), nSum += el:GetValue(cField), Nil) })
	Else
		AEVAL(::aData, { |el| nSum += el:GetValue(cField) } )
	EndIf
Return nSum

/*/{Protheus.doc} Count
	Usado para contar numero de registros que seja compativel com o retorno do bloco passado por parametro que normalmente é usado para filtro

	@author Vinicius Gati
	@since 05/05/2014
	@param bBlock , bloco , Bloco que deve retornar .T. ou .F. para filtrar os dados do Container como um seletor e definir se vai somar +1 ao Count
	@example Mil_DataContainer:Count()
/*/
METHOD Count(bBlock) Class Mil_DataContainer
	Local nQtd := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(::aData, { |el| IIF( EVAL(bBlock, el) , nQtd++, Nil ) })
	Else
		nQtd := Len(::aData)
	EndIf
Return nQtd

/*/{Protheus.doc} Mil_Devolucoes

	@author       Vinicius Gati
	@since        17/04/14
	@description  Acopla comandos de Devoluções de Vendas.
/*/
Class Mil_Devolucoes
	Data cTipFatNovo
	Data cTipFatUsado

	METHOD New() CONSTRUCTOR
	METHOD Todos()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_Devolucoes
	@author Vinicius Gati
	@since  05/05/2014
/*/
METHOD New() Class Mil_Devolucoes
	::cTipFatNovo  := "0"
	::cTipFatUsado := "1"
Return SELF

/*/{Protheus.doc} Todos
	Retorna todas as devoluções de veiculos filtrando os dados da como no exeplo

	@author    Vinicius Gati
	@since     05/05/2014
	@param     oObjData, character, Objeto do tipo Mil_DataContainer
	@example   Atributos válidos(Passar como Mil_DataContainer)
							- DataInicial   : Data inicial do periodo de vendas
							- DataFinal     : Data final do periodo de vendas
							- Novos?        : .T. ou .F. caso buscar veículos novos ou usados
							- Tipo          : Tipo do filtro de devolução
								- 'Venda'     : Filtrar Pela Data da Venda, para saber total de devoluções das vendas do periodo
								- 'Devolução' : Filtrar Pela Data da Devolução, para saber devoluções ocorridas no periodo
							- Filiais       : Array de empresas

							aData := {
									{'Novos?'     , .F.}, 
									{'DataInicial', '20140310'}, 
									{'DataFinal'  , '20140320'}, 
									{'Filiais'    , {'E04', 'E05'}}, 
									{'Tipo'       , 'Venda'}
							}
							aUsados := oDevolucoes:Todos( Mil_DataContainer():New(aData) )
/*/
METHOD Todos(oObjData) Class Mil_Devolucoes
	Local cQuery       := ''
	Local cAlias       := 'Devolucoes'
	Local aResults     := {}
	Local nIdx         := 0
	Local cDataInicio  := oObjData:GetValue('DataInicial')
	Local cDataFim     := oObjData:GetValue('DataFinal')
	Local cTipo        := oObjData:GetValue('Tipo')
	Local aFiliais     := oObjData:GetValue('Filiais')
	Local oFilHelp     := DMS_FilialHelper():New()
	Local oArrHelp     := DMS_ArrayHelper():New()
	Local cGruVei      := Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))+"_"
	
	// Filiais envolvidas
	Local cFilSD1      := ''
	Local cFilVVA      := ''
	Local cFilVVR      := ''
	Local cFilVV9      := ''
	Local cFilVV0      := ''
	// Tabelas envolvidas
	Local cTblVV0 := RetSqlName("VV0")
	Local cTblSD1 := RetSqlName("SD1")
	Local cTblVVA := RetSqlName("VVA")
	Local cTblVVR := RetSqlName("VVR")
	Local cTblVV9 := RetSqlName("VV9")
	
	Local lTIPMOV := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )

	For nIdx := 1 To Len(aFiliais)
		cFilSD1 := oFilHelp:GetFilial( aFiliais[nIdx], 'SD1' )
		cFilVVA := oFilHelp:GetFilial( aFiliais[nIdx], 'VVA' )
		cFilVVR := oFilHelp:GetFilial( aFiliais[nIdx], 'VVR' )
		cFilVV9 := oFilHelp:GetFilial( aFiliais[nIdx], 'VV9' )
		cFilVV0 := oFilHelp:GetFilial( aFiliais[nIdx], 'VV0' )

		cQuery += " SELECT VVA.VVA_GRUMOD , VV0.VV0_OPEMOV , VV0.VV0_FILIAL , VV0.VV0_DATMOV , "
		cQuery += "        VVA.VVA_VALMOV , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VV9.VV9_STATUS , "
		cQuery += "        VVA.VVA_CODMAR , SD1.D1_TIPO    , VVR.VVR_DESCRI "
		cQuery += "   FROM " +cTblVV0+ " VV0 "
		cQuery += "   JOIN " +cTblVVA+ " VVA ON VVA.VVA_FILIAL = '" +cFilVVA+ "' AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA "
		cQuery += "   JOIN " +cTblSD1+ " SD1 ON SD1.D1_FILIAL  = '" +cFilSD1+ "' AND SD1.D1_NFORI   = VV0.VV0_NUMNFI AND SD1.D1_SERIORI = VV0.VV0_SERNFI AND SD1.D1_TIPO = 'D' AND SD1.D1_COD = ('"+cGruVei+"'+ VVA.VVA_CHAINT) "
		cQuery += "   JOIN " +cTblVVR+ " VVR ON VVR.VVR_FILIAL = '" +cFilVVR+ "' AND VVR_CODMAR     = VVA.VVA_CODMAR AND VVR.VVR_GRUMOD = VVA.VVA_GRUMOD "
		cQuery += "   JOIN " +cTblVV9+ " VV9 ON VV9.VV9_FILIAL = '" +cFilVV9+ "' AND VV9.VV9_NUMATE = VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') "
		cQuery += "  WHERE VV0.VV0_FILIAL = '" +cFilVV0+ "'             AND VV0.VV0_OPEMOV IN (' ','0','8')               "
		cQuery += "    AND VV0.VV0_TIPFAT IN ('0','1','2')                                                                 "
		cQuery += "    AND VV0.D_E_L_E_T_ =' '  AND VVA.D_E_L_E_T_ = ' ' AND VV9.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' AND VVR.D_E_L_E_T_ = ' ' "

		If(cTipo == 'Venda')
			cQuery += "    AND VV0.VV0_DATMOV >= '" +DTOS(cDataInicio)+ "'   AND VV0.VV0_DATMOV <= '" +DTOS(cDataFim)+ "' "
		Else
			cQuery += "    AND SD1.D1_EMISSAO >= '" +DTOS(cDataInicio)+ "'   AND SD1.D1_EMISSAO <= '" +DTOS(cDataFim)+ "' "
		EndIf

		cQuery += "    AND VV0.VV0_TIPFAT = '" + If(oObjData:GetValue('Novos?'), ::cTipFatNovo, ::cTipFatUsado) + "' "

		If lTIPMOV
			cQuery += " AND VV0.VV0_TIPMOV IN (' ','0') "
		EndIf

		If( !oArrHelp:LastIndex(nIdx, aFiliais) )
			cQuery += " UNION ALL "
		EndIf
	Next

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )

	(cAlias)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !EOF()          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		aEl := {                                 ;
			{ 'VVA_CODMAR', (cAlias)->VVA_CODMAR },;
			{ 'VVA_GRUMOD', (cAlias)->VVA_GRUMOD },;
			{ 'VVR_DESCRI', (cAlias)->VVR_DESCRI },;
			{ 'VVA_VALMOV', (cAlias)->VVA_VALMOV },;
			{ 'VV0_OPEMOV', (cAlias)->VV0_OPEMOV },;
			{ 'VV0_FILIAL', (cAlias)->VV0_FILIAL },;
			{ 'VV0_DATMOV', (cAlias)->VV0_DATMOV },;
			{ 'VV0_DATMOV', (cAlias)->VV0_DATMOV },;
			{ 'VV0_TIPFAT', (cAlias)->VV0_TIPFAT },;
			{ 'VV9_STATUS', (cAlias)->VV9_STATUS },;
			{ 'D1_TIPO'   , (cAlias)->D1_TIPO    },;
		}
		oEl := DMS_DataContainer():New(aEl)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAlias)->(dbCloseArea())

Return aResults


/*/{Protheus.doc} Mil_FilialHelper

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de filiais no protheus
/*/
Class Mil_FilialHelper

	Method New() CONSTRUCTOR
	Method GetFiliais()
	Method GetFilial()
	Method CompareAccess()
	Method GetAllFilEmpresa()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_FilialHelper
	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class Mil_FilialHelper
Return SELF

/*/{Protheus.doc} GetFilial
	Retorna as filiais(formato xFilial) para as empresas do parametro aEmpresas

	@author Vinicius Gati
	@since 05/05/2014
	@param aEmpresas, character, Empresas para retornar filiais no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@example
		oMil_FilialHelper:GetFiliais({'E04', 'E03'}, 'VEC') => {'E04F01    ', 'E03F01    '}
/*/
Method GetFiliais(aEmpresas, cTabela) Class Mil_FilialHelper
	Local cFilSALVA  := cFilAnt //Salva para retornar o cache
	Local aFiliais   := {}
	Local nIdx       := {}

	For nIdx := 1 to Len(aEmpresas)
		cEmpresa := aEmpresas[nIdx]
		cFilAnt  := cEmpresa // Usada internamente para determinar a empresa atual do sistema e retornar filiais(xFilial)
		AADD( aFiliais, xFilial(cTabela) )
	Next

	cFilAnt := cFilSALVA //Retorna Cache
Return aFiliais

/*/{Protheus.doc} GetFilial
	Retorna as filial(formato xFilial) para a empresa do parametro cEmpresa

	@author Vinicius Gati
	@since 05/05/2014
	@param cEmpresa, character, Empresa atual para retornar filial no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@example
		oMil_FilialHelper:GetFilial('E04', 'VEC') => 'E04F01    '
/*/
Method GetFilial(cEmpresa, cTabela) Class Mil_FilialHelper
	Local cFilSALVA := cFilAnt
	Local cFil      := ''

	cFilAnt := cEmpresa
	cFil    := xFilial(cTabela)
	cFilAnt := cFilSALVA // Retorna Cache
Return cFil

Method CompareAccess(cFilBase, cFil) Class Mil_FilialHelper
	Local nBaseSize := LEN(ALLTRIM(cFilBase))
	Local nCompSize := LEN(ALLTRIM(cFil    ))
	Local cRet := Nil

	If nBaseSize == 0
		cRet := 'LIBERAL'
	ElseIf nBaseSize == nCompSize .OR. nBaseSize < nCompSize
		// o == acima é avaliado como cortar, pois precisa entrar no where da query, pois pode 
		// ser que o B1 tenha E01 e o registro E02 por exemplo, eles tem o mesmo tamanho mas precisa entrar na query pois são diferentes
		cRet := 'CORTAR'
	ElseIf nBaseSize > nCompSize
		cRet := 'FECHADO'
	EndIf
Return cRet

Method GetAllFilEmpresa(lAllFil) Class Mil_FilialHelper
	Local aRetorno
	Local aFilAtu
	If !lAllFil
		aRetorno := { cFilAnt }
	Else
		aFilAtu  := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
		aRetorno := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
	EndIf
Return aRetorno

Return cRet
/*/{Protheus.doc} Mil_PrestadorDAO
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Classe que faz contato com o banco de dados em busca dos dados de Prestadores/Eq. Tecnica Tabela VAI
/*/
Class Mil_PrestadorDAO
	Method New() CONSTRUCTOR
	Method GetName()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_RequisicaoFerramentas

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class Mil_PrestadorDAO
Return SELF

/*/{Protheus.doc} GetName
	Retorna o VAI_NOMTEC

	@author Vinicius Gati
	@since 05/05/2014
	@param cCodProdutivo, character, Código do produtivo VAI
/*/
Method GetName(cCodProdutivo) Class Mil_PrestadorDAO
	Local cTecName := ''
	cLastAlias = Alias()
	dbSelectArea('VAI')
	DbSelectArea('VAI')
	DbSetOrder(1) // Filial + CodTecnico/Produtivo
	DbSeek( xFilial('VAI') + cCodProdutivo )
	cTecName := VAI->VAI_NOMTEC

	DbSelectArea(cLastAlias)
Return cTecName

/*/{Protheus.doc} Mil_ControleFerramentasDAO
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Classe que faz contato com o banco de dados em busca dos dados de Prestadores/Eq. Tecnica VAI
/*/
Class Mil_ControleFerramentasDAO
	Method New() CONSTRUCTOR
	Method GetRequisicoes()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_ControleFerramentasDAO

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class Mil_ControleFerramentasDAO
Return SELF

/*/{Protheus.doc} GetRequisicoes
	Retorna as Ferramentas movimentadas(VD3)

	@author Vinicius Gati
	@since 05/05/2014
	@param cCodVDP, character, Código da movimentacao de ferramentas VDP
/*/
Method GetRequisicoes(cCodVDP) Class Mil_ControleFerramentasDAO
	Local aResults := {}
	Local cTblVD3  := RetSqlName('VD3')
	Local cFilVD3  := xFilial('VD3')
	Local cAlias   := 'ReqFerramentas'
	Local cQuery   := ""
	
	cQuery += "   SELECT VD3.VD3_SEQUEN, VD3.VD3_CODFER, VD3.VD3_DATMOV, VD3.VD3_QTDMOV, "
	cQuery += "          VD3.VD3_NUMOSV, VD3.VD3_TIPTEM, VD3.R_E_C_N_O_ "
	cQuery += "     FROM " + cTblVD3 + " VD3" 
	cQuery += "    WHERE VD3.VD3_FILIAL = '" +cFilVD3+ "' "
	cQuery += "      AND VD3.VD3_CODIGO = '" +cCodVDP+ "' "
	cQuery += " ORDER BY VD3.VD3_SEQUEN ASC "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
	(cAlias)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !EOF()          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		aData := {                               ;
			{ 'VD3_CODIGO', cCodVDP              },;
			{ 'VD3_SEQUEN', (cAlias)->VD3_SEQUEN },;
			{ 'VD3_CODFER', (cAlias)->VD3_CODFER },;
			{ 'VD3_DATMOV', (cAlias)->VD3_DATMOV },;
			{ 'VD3_QTDMOV', (cAlias)->VD3_QTDMOV },;
			{ 'VD3_NUMOSV', (cAlias)->VD3_NUMOSV },;
			{ 'VD3_TIPTEM', (cAlias)->VD3_TIPTEM },;
			{ 'R_E_C_N_O_', (cAlias)->R_E_C_N_O_ } ;
		}
		oEl := Mil_RequisicaoFerramenta():New(aData)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAlias)->(dbCloseArea())
Return aResults

/*/{Protheus.doc} Mil_RequisicaoFerramenta
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Acopla dados do VD3(Ferramentas movimentadas)
/*/
Class Mil_RequisicaoFerramenta
	Data nId
	Data cSequen
	Data cCodFerramenta
	Data dDtMov
	Data nQtdMov
	Data cCodCabReq
	Data cNroOs
	Data cTipTem

	Method New() CONSTRUCTOR
	Method Sequencia()
	Method CodigoFerramenta()
	Method DataMovimento()
	Method Quantidade()
	Method CabecaRequisicao()
	Method Ferramenta()
	METHOD TipoRequisicao()
	METHOD TipoDevolucao()
	Method NumeroOs()
	Method TipoTempo()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_RequisicaoFerramenta

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New(aData) Class Mil_RequisicaoFerramenta
	oData            := Mil_DataContainer():New(adata)
	::nId            := oData:GetValue('R_E_C_N_O_')
	::cSequen        := oData:GetValue('VD3_SEQUEN')
	::cCodFerramenta := oData:GetValue('VD3_CODFER')
	::dDtMov         := oData:GetValue('VD3_DATMOV')
	::nQtdMov        :=	oData:GetValue('VD3_QTDMOV')
	::cCodCabReq     := oData:GetValue('VD3_CODIGO')
	::cNroOs         := oData:GetValue('VD3_NUMOSV')
	::cTipTem        := oData:GetValue('VD3_TIPTEM')
Return SELF

Method Sequencia() Class Mil_RequisicaoFerramenta
Return Self:cSequen

Method CodigoFerramenta() Class Mil_RequisicaoFerramenta
Return Self:cCodFerramenta

Method DataMovimento() Class Mil_RequisicaoFerramenta
Return Self:dDtMov

Method Quantidade() Class Mil_RequisicaoFerramenta
Return Self:nQtdMov

Method CabecaRequisicao() Class Mil_RequisicaoFerramenta
Return Self:cCodCabReq

/*/{Protheus.doc} GetFilial
	Retorna o Status de movimentos de Requisicao

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method TipoRequisicao() Class Mil_RequisicaoFerramenta
Return '1'

/*/{Protheus.doc} GetFilial
	Retorna o Status de movimentos de Devolucao

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method TipoDevolucao() Class Mil_RequisicaoFerramenta
Return '0'

Method NumeroOs() Class Mil_RequisicaoFerramenta
Return Self:cNroOs

Method TipoTempo() Class Mil_RequisicaoFerramenta
Return Self:cTipTem

/*/{Protheus.doc} Mil_PecaDAO
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Acessa o banco para processar pecas(SB1)
/*/
Class Mil_PecaDAO

	Data cGruIte
	Data cCodIte
	Data cCodB1

	Method New(cGrupo,cCodigo) CONSTRUCTOR
	Method GetGrupo()
	Method SetGrupo()
	Method GetCodigo()
	Method SetCodigo()
	Method UpdateGroup()
	Method EstqSaldo()
	Method EstqSaldo2()
	Method TabelaPreco()
	Method ItensRelacionados()
	Method ItensSubstituidos()
	Method GetUltVenda()
	Method GetUltCompra()
	Method GetDemanda()
EndClass


/*/{Protheus.doc} New
	Construtor simples Mil_PecaDAO

	@author Vinicius Gati
	@since 21/05/2014
/*/
Method New(cGrupo,cCodigo) Class Mil_PecaDAO
	Default cGrupo  := ""
	Default cCodigo := ""
	Self:cGruIte := cGrupo
	Self:cCodIte := cCodigo
	If !Empty(Self:cCodIte)
		Self:SetCodigo(cCodigo)
	Else
		Self:cCodB1 := ""
	EndIf		
Return SELF

Method GetGrupo() Class Mil_PecaDAO
Return Self:cGruIte

Method SetGrupo(cGrupo) Class Mil_PecaDAO
	Local lFound := .t.
	If Empty(cGrupo) .or. (lFound := ExistCpo("SBM", cGrupo))
		Self:cGruIte := cGrupo
		Self:SetCodigo("")
	EndIf
Return lFound

Method GetCodigo() Class Mil_PecaDAO
Return Self:cCodIte

Method SetCodigo(cCodigo) Class Mil_PecaDAO
	Local lFound := .t.
	Local aAreaB1 := sGetArea(,"SB1")	
	
	SB1->(dbSetOrder(7))
	If Empty(cCodigo) .or. (lFound := SB1->(MsSeek(xFilial("SB1") + self:GetGrupo() + cCodigo)) )
		Self:cCodIte := cCodigo
		Self:cCodB1  := SB1->B1_COD
	EndIf
	sRestArea(aAreaB1)
Return lFound

Method EstqSaldo(cLocal,lAllFil,lRetDescr) Class Mil_PecaDAO

	Local aRetorno := {}
	Local nPos
	Local nCont
	Local nCont2
	Local aAuxArea
	Local oFilHelp := Mil_FilialHelper():New()

	aSM0 := oFilHelp:GetAllFilEmpresa(lAllFil)
	
	aAuxArea := sGetArea(,"SB2")
	aAuxArea := sGetArea(aAuxArea,"SBE")
	
	Default cLocal  := ""
	Default lAllFil := .f.
	Default lRetDescr := .f.
	
	cBkpCFilAnt := cFilAnt
	For nCont := 1 to Len(aSM0)

		cFilAnt := aSM0[nCont]
	
		cAuxNomeFil := FWFilialName()
		
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + Self:cCodB1 + IIf(!Empty(cLocal),cLocal,"") ))
		While !SB2->(Eof()) .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == Self:cCodB1 .and. ( Empty(cLocal) .or. SB2->B2_LOCAL == cLocal )
			AADD( aRetorno , { SB2->B2_FILIAL , SB2->B2_LOCAL , SB2->(SaldoSb2()) , "" , cAuxNomeFil } )
			SB2->(DbSkip())
		End
		
		If lRetDescr .and. (nPos := aScan(aRetorno,{ |x| x[1] == cFilAnt }) ) <> 0
			SBE->(dbSetOrder(1))
			For nCont2 := nPos to Len(aRetorno)
				aRetorno[nCont2,4] := IIf(SBE->(dbSeek(xFilial("SBE") + aRetorno[nCont2,2])) , SBE->BE_DESCRIC , "" )
			Next nCont2
		EndIf
	
	Next nCont
	cFilAnt := cBkpCFilAnt
	
	sRestArea(aAuxArea)

Return aRetorno

Method EstqSaldo2(cLocal,lAllFil) Class Mil_PecaDAO

	Local nRetorno
	Local nCont
	Local aAuxRet
	
	Default cLocal  := ""
	Default lAllFil := .f.
	
	aAuxRet := Self:EstqSaldo(cLocal,lAllFil,.f.)
	
	nRetorno := 0
	For nCont := 1 to Len(aAuxRet)
		nRetorno += aAuxRet[nCont,3]
	Next nCont

Return nRetorno

Method TabelaPreco() Class Mil_PecaDAO

	Local aRetorno := {}
	Local nCont
	Local nRecNoVEG
//	Local cBkpFilAnt := cFilAnt
	Local aAuxArea
	
	aAuxArea := sGetArea(,"SB1")
	aAuxArea := sGetArea(aAuxArea,"SB5")
	aAuxArea := sGetArea(aAuxArea,"VEG")
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + Self:cCodB1))
	
	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
	
	VEG->(dbSetOrder(2))
	VEG->(dbSeek(xFilial("VEG")+"04"))
	Do While !VEG->(EOF()) .and. VEG->VEG_FILIAL == xFilial("VEG") .and. VEG->VEG_GRUFOR == "04"
		If Empty(VEG->VEG_GRUPOS)
			lRet := .t.
		Else
			lRet := .f.
			For nCont := 1 to Len(VEG->VEG_GRUPOS) Step 4
				If Empty(SubStr(VEG->VEG_GRUPOS,nCont,4))
					Exit
				EndIf
				If Self:GetGrupo() == SubStr(VEG->VEG_GRUPOS,nCont,4)
					lRet := .t.
					Exit
				EndIf
			Next nCont
		EndIf
		//
		nRecNoVEG := VEG->(RecNo())
		If lRet
			AADD( aRetorno , { AllTrim(VEG->VEG_DESCRI), FG_FORMULA(VEG->VEG_CODIGO) } )
		Endif
		//
		VEG->(dbSetOrder(2))
		VEG->(DbGoto(nRecNoVEG))
		VEG->(dbSkip())
	Enddo
	//
//	cFilAnt := cBkpFilAnt
	//
	
	sRestArea(aAuxArea)	

Return aRetorno

Method ItensRelacionados() Class Mil_PecaDAO
	Local aAuxArea := sGetArea(,"SB1")
	Local aRetorno := FG_ITEREL( Nil , Self:GetGrupo() , Self:GetCodigo() , GetNewPar("MV_FMLPECA","") )
	sRestArea(aAuxArea)	
Return aRetorno

Method ItensSubstituidos() Class Mil_PecaDAO
	Local cSQL  
	Local lWhile   := .t.
	Local TVE9     := "TALIAVE9"
	Local ni       := 0
	Local nLenTot  := 0
	Local aRetorno := {}
	Local aAuxArea := {}
	Local cNamVE9  := RetSQLName("VE9")
	Local cNamSB1  := RetSQLName("SB1")
	Local cFilVE9  := xFilial("VE9")
	Local cFilSB1  := xFilial("SB1")
	Local cFilSB2  := xFilial("SB2")
	Local cGruIte  := Self:cGruIte
	Local cCodIte  := Self:cCodIte
	aAuxArea := sGetArea(,"SB1")
	aAuxArea := sGetArea(aAuxArea,"SB2")
	// Levantar os Antigos //
	cSQL := "SELECT VE9.VE9_GRUITE , VE9.VE9_ITEANT , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
	cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUNOV AND SB1.B1_CODITE=VE9.VE9_ITENOV AND SB1.D_E_L_E_T_=' ' ) "
	cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUNOV='"+cGruIte+"' AND VE9.VE9_ITENOV='"+cCodIte+"' AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
	While !(TVE9)->(Eof())
		AADD( aRetorno , { (TVE9)->VE9_GRUITE, (TVE9)->VE9_ITEANT , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "A" , 0 } )
		(TVE9)->(dbSkip())
	End
	(TVE9)->(dbCloseArea())
	// Levantar os Antigos dos Antigos //
	lWhile := .t.
	While lWhile
		lWhile  := .f.
		nLenTot := len(aRetorno)
		For ni := 1 to nLenTot
			If !aRetorno[ni,6]
				aRetorno[ni,6] := .t.
				cSQL := "SELECT VE9.VE9_GRUITE , VE9.VE9_ITEANT , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
				cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUNOV AND SB1.B1_CODITE=VE9.VE9_ITENOV AND SB1.D_E_L_E_T_=' ' ) "
				cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUNOV='"+aRetorno[ni,1]+"' AND VE9.VE9_ITENOV='"+aRetorno[ni,2]+"' AND VE9.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
				While !(TVE9)->(Eof())
					AADD( aRetorno , { (TVE9)->VE9_GRUITE, (TVE9)->VE9_ITEANT , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "A" , 0 } )
					lWhile := .t.
					(TVE9)->(dbSkip())
				End
				(TVE9)->(dbCloseArea())
			EndIf
		Next
	End
	// Levantar os Novos //
	cSQL := "SELECT VE9.VE9_GRUNOV , VE9.VE9_ITENOV , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
	cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUITE AND SB1.B1_CODITE=VE9.VE9_ITEANT AND SB1.D_E_L_E_T_=' ' ) "
	cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUITE='"+cGruIte+"' AND VE9.VE9_ITEANT='"+cCodIte+"' AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
	While !(TVE9)->(Eof())
		AADD( aRetorno , { (TVE9)->VE9_GRUNOV, (TVE9)->VE9_ITENOV , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "N" , 0 } )
		(TVE9)->(dbSkip())
	End
	(TVE9)->(dbCloseArea())
	// Levantar os Novos dos Novos //
	lWhile := .t.
	While lWhile
		lWhile  := .f.
		nLenTot := len(aRetorno)
		For ni := 1 to nLenTot
			If !aRetorno[ni,6]
				aRetorno[ni,6] := .t.
				cSQL := "SELECT VE9.VE9_GRUNOV , VE9.VE9_ITENOV , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
				cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9_GRUITE AND SB1.B1_CODITE=VE9.VE9_ITEANT AND SB1.D_E_L_E_T_=' ' ) "
				cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUITE='"+aRetorno[ni,1]+"' AND VE9.VE9_ITEANT='"+aRetorno[ni,2]+"' AND VE9.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
				While !(TVE9)->(Eof())
					AADD( aRetorno , { (TVE9)->VE9_GRUNOV, (TVE9)->VE9_ITENOV , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "N" , 0 } )
					lWhile := .t.
					(TVE9)->(dbSkip())
				End
				(TVE9)->(dbCloseArea())
			EndIf
		Next
	End
	//
	For ni := 1 to len(aRetorno)
		SB1->(dbSetOrder(7))
		SB1->(dbSeek( cFilSB1 + aRetorno[ni,1] + aRetorno[ni,2] ))
		SB1->(dbSetOrder(1))
		SB2->(dbSetOrder(1))
		SB2->(dbSeek( cFilSB2 + SB1->B1_COD + SB1->B1_LOCPAD ))
		aRetorno[ni,7] := SaldoSB2()
		aRetorno[ni,9]  := FG_VALPEC("",GetNewPar("MV_FMLPECA",""),SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)

	Next
	aSort(aRetorno,1,,{|x,y| x[5] > y[5] }) // Ordenar --> RECNO VE9
	//	
	DbSelectArea("SB1")
	sRestArea(aAuxArea)
	//
Return aRetorno

Method GetUltVenda() Class Mil_PecaDAO
	Local cSQL
	cSQL := "SELECT MAX(SD2.D2_EMISSAO) "
	cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_ = ' '"
	cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cSQL +=   " AND SD2.D2_COD = '" + Self:cCodB1 + "'"
	cSQL +=   " AND SD2.D_E_L_E_T_ = ' '"
Return StoD(FM_SQL(cSQL))

Method GetUltCompra() Class Mil_PecaDAO
	Local cSQL
	cSQL := "SELECT MAX(SD1.D1_DTDIGIT) "
	cSQL +=  " FROM " + RetSQLName("SD1") + " SD1 JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' '"
	cSQL += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	cSQL +=   " AND SD1.D1_COD = '" + Self:cCodB1 + "'"
	cSQL +=   " AND SD1.D_E_L_E_T_ = ' '"
Return StoD(FM_SQL(cSQL))

Method GetDemanda(lAllFil,cAno,cMes,cOrigem) Class Mil_PecaDAO
	Local cSQL
	Local nCont
	Local aRetorno := {}
	Local cBkpCFilAnt := cFilAnt
	Local TSB2 := "TALIASB2"
	Local oFilHelp := Mil_FilialHelper():New()
	Local oSqlHelp := DMS_SqlHelper():New()
	Local lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
	Local lVq3 := .F.
	Default cOrigem := "SBL"

	aSM0 := oFilHelp:GetAllFilEmpresa(lAllFil)

	Default cMes := ""

	if lNewGrpDPM
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial('SB1')+self:cCodB1 ))
		SBM->(dbSetOrder(1) )
		SBM->(dbSeek( xFilial('SBM') + SB1->B1_GRUPO ))
		lVq3 := (SBM->BM_VAIDPM == '1')
	else
		if oSqlHelp:ExistTable(retsqlname('VQ3')) .AND. FM_SQL(' SELECT COUNT(*) FROM ' + RetSqlName('VQ3') + " WHERE VQ3_FILIAL = '"+xFilial('VQ3')+"' AND D_E_L_E_T_ = ' ' ") > 0
			if FM_SQL(' SELECT COUNT(*) FROM ' + RetSqlName('VQ3') + " WHERE VQ3_FILIAL = '"+xFilial('VQ3')+"' AND  VQ3_PRODUT = '" + Self:cCodB1 + "' AND (VQ3_VDAB + VQ3_VDAO + VQ3_VDAI) > 0  AND D_E_L_E_T_ = ' ' ") > 0
				lVq3 := .t.
			EndIf
		EndIf
	EndIf

	cBkpCFilAnt := cFilAnt
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		if ! lVq3
			cSQL := "SELECT BL_FILIAL, BL_PRODUTO, BL_ANO, BL_MES, BL_DEMANDA "
			cSQL +=  " FROM " + RetSQLName("SBL") + " SBL "
			cSQL += " WHERE SBL.BL_FILIAL = '" + xFilial("SBL") + "'"
			cSQL +=   " AND SBL.BL_PRODUTO = '" + Self:cCodB1 + "'"
			cSQL +=   " AND SBL.BL_ANO = '" + cAno + "'"
			cSQL += IIf( !Empty(cMes), " AND SBL.BL_MES = '" + cMes + "'" , "")
			cSQL +=   " AND SBL.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TSB2 , .F., .T. )
			While !(TSB2)->(Eof())
				AADD( aRetorno , { (TSB2)->BL_FILIAL, (TSB2)->BL_PRODUTO , (TSB2)->BL_ANO, (TSB2)->BL_MES, (TSB2)->BL_DEMANDA } )
				(TSB2)->(dbSkip())
			End
			(TSB2)->(dbCloseArea())
		Else
			cSQL := " SELECT VQ3_FILIAL, VQ3_MES, SUM(VQ3_VDAB + VQ3_VDAO + VQ3_VDAI) as DEMANDA "
			cSQL += "  FROM " + oSqlHelp:NoLock('VQ3')
			cSQL += " WHERE VQ3.VQ3_PRODUT = '" + Self:cCodB1 + "' "
			cSQL += " AND VQ3.VQ3_ANO = '" + cAno + "' "
			cSQL += " AND VQ3.VQ3_FILIAL = '"+xFilial('VQ3')+"' "
			cSQL += IIf( !Empty(cMes), " AND VQ3.VQ3_MES = '" + cMes + "'" , "")
			cSQL += "   AND VQ3.D_E_L_E_T_ = ' ' "
			cSQL += " GROUP BY VQ3_FILIAL, VQ3_MES "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TSB2 , .F., .T. )
			While !(TSB2)->(Eof())
				AADD( aRetorno , { (TSB2)->VQ3_FILIAL, Self:cCodB1 , cAno, (TSB2)->VQ3_MES, (TSB2)->DEMANDA } )
				(TSB2)->(dbSkip())
			End
			(TSB2)->(dbCloseArea())
		EndIf
	Next nCont


	if LEN(aRetorno) = 0
		aAdd(aRetorno, {xFilial('SB1'), self:cCodB1, cAno, cMes, 0})
	EndIf
	cFilAnt := cBkpCFilAnt
Return aRetorno


/*/{Protheus.doc} UpdateGroup
	Atualiza o grupo do produto e propaga a atualização por todos os modulos de concessionária

	@author Vinicius Gati
	@since 21/05/2014
	@param aEmpresas, character, Empresas para retornar filiais no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@return -2 = Sistema deve ser acessado em modo exclusvivo para rodar este processo, 0 = Operação concluida sem erros, -1 = Um erro ocorreu
/*/
//#############################################################################################################################################
//#############################################################################################################################################
//#############################################################################################################################################
//#####                                                                                                                                   #####
//#####                   DESCONTINUADO NAO UTILIZAR, REFERENCIE DMS_ NOS FONTES VEICLS                                                   #####
//#####                                                                                                                                   #####
//#####                                                                                                                                   #####
//#############################################################################################################################################
//#############################################################################################################################################
//#############################################################################################################################################
Method UpdateGroup(cB1COD, cOldCodIte, cOldGruIte, cNewGruIte) Class Mil_PecaDAO
	Local oAccControl     := Mil_AccessControl():New()
	Local oFilHelp        := Mil_FilialHelper():New()
	Local oSqlHelp        := Mil_SqlHelper():New()
	Local nFilSize        := 0
	Local aUpdates        := {}
	Local bolConfirmation := -1
	// Lista de tabelas que tem campos que serão atualizados e deverão ser abertas exclusivamente
	//Local aTableList      := { ;
	//	'VA8', 'VAJ', 'VAN', 'VAW', 'VB1', 'VDD', 'VDR', 'VE3', 'VE6', 'VE8', 'VEC', ;
	//	'VEN', 'VEO', 'VES', 'VF7', 'VF8', 'VFB', 'VG5', 'VG6', 'VGF', 'VIA', 'VIC', ;
	//	'VIE', 'VIW', 'VJI', 'VMC', 'VO3', 'VO8', 'VOK', 'VPF', 'VPG', 'VPJ', 'VS3', ;
	//	'VS7', 'VSD', 'VSJ', 'VSS', 'VSY', 'VV6', 'VVT', 'VVW', 'VZ1', 'VZ6', 'VZ7', ;
	//	'VZZ', 'SB4', 'SBI', 'SC9', 'SCW', 'SD1', 'SD2', 'SD3', 'SLN' }

	// Lista os campos que serão usados no update
	//{ 'VB1_GRUPO'  , 'VB1_CODITE' }, ; // campos Virtuais por isso foi removido
	Local aFieldsList     := { ;
		{ 'VF7_GRUITE' , 'VF7_CODCOM' }, ; // Estrutura:= CampoDoGrupo,CampoDoCodIte
		{ 'VAJ_GRUPEC' , 'VAJ_CODPEC' }, ;
		{ 'VDD_GRUPO'  , 'VDD_CODITE' }, ;
		{ 'VA8_CODGRU' , 'VA8_CODITE' }, ;
		{ 'VAB_CODGRU' , 'VAB_CODPEC' }, ;
		{ 'VEA_GRUITE' , 'VEA_ITEANT' }, ;
		{ 'VEA_GRUITE' , 'VEA_ITENOV' }, ;
		{ 'VE9_GRUITE' , 'VE9_ITEANT' }, ;
		{ 'VE9_GRUITE' , 'VE9_ITENOV' }, ;
		{ 'B4_GRUPO'   , 'B4_COD'     }, ;
		{ 'BI_GRUPO'   , 'BI_COD'     }, ;
		{ 'C9_GRUPO'   , 'C9_PRODUTO' }, ;
		{ 'CW_GRUPO'   , 'CW_PRODUTO' }, ;
		{ 'D1_GRUPO'   , 'D1_COD'     }, ;
		{ 'D2_GRUPO'   , 'D2_COD'     }, ;
		{ 'D3_GRUPO'   , 'D3_COD'     }, ;
		{ 'LN_GRUPO'   , 'LN_COD'     }, ;
		{ 'VAN' }, { 'VAW' }, { 'VDR' }, { 'VE3' }, ;  // Para tabelas no padrão CODITE e GRUITE é só passar o nome da tabela
		{ 'VE6' }, { 'VE8' }, { 'VEC' }, { 'VEN' }, ;
		{ 'VEO' }, { 'VES' }, { 'VF8' }, { 'VFB' }, ;
		{ 'VG5' }, { 'VG6' }, { 'VGF' }, { 'VIA' }, ;
		{ 'VIC' }, { 'VIE' }, { 'VIW' }, { 'VJI' }, ;
		{ 'VMC' }, { 'VO3' }, { 'VO8' }, { 'VOK' }, { 'VPF' }, ;
		{ 'VPG' }, { 'VPJ' }, { 'VS3' }, { 'VS7' }, ;
		{ 'VSD' }, { 'VSJ' }, { 'VSS' }, { 'VSY' }, ;
		{ 'VV6' }, { 'VVT' }, { 'VVW' }, { 'VZ1' }, ;
		{ 'VZ6' }, { 'VZ7' }, { 'VZZ' }, { 'VEN' }  ;
	}
	//Local nIdxTblLock     := 1
	Local nIdxField       := 1
	Local nIdxQueries     := 1

	// Usadas nos updates
	Local cTableName      := ''
	Local cFieldPrefix    := ''
	Local cQuery          := ''

	if FieldPos("VE9_GRUNOV") > 0 
		aAdd(aFieldsList, { 'VE9_GRUNOV' , 'VE9_ITENOV' } )
	endif

	// Faz o update Geral nos campos
	For nIdxField := 1 To Len(aFieldsList)
		aEl := aFieldsList[nIdxField]
		If Len(aEl) == 2 // Se o nro de campos for 2 faz o update com os campos passados
			aFields      := aEl
			cTableName   := LEFT(aFields[1], 3) // Nome da tabela do campo 3 primeiro caracteres
			cFieldPrefix := cTableName
			If '_' $ cTableName
				cFieldPrefix := LEFT(cTableName, 2)
				cTableName   := 'S' + LEFT(cTableName, 2)
			EndIf  
		Else // Caso contrario faz update com nome padrao CODITE E GRUITE
			cTableName := aEl[1] // So tem o nome da tabela
			aFields    := { cTableName + "_GRUITE", cTableName + "_CODITE" }
			cFieldPrefix := cTableName 
		EndIf

		// correcao se a tabela nao existe no sx2
		dbSelectArea('SX2')
		dbSetOrder(1)
		If ! SX2->(dbSeek(cTableName))
			LOOP
		Else
			DbSelectArea(cTableName) // Cria tabela se não existir ainda
			dbCloseArea()
		EndIf

		// Neste campo da filial 2 digitos no campo filial sera usada entao foi usado nome da tabela 'VEC'_FILIAL
		cQuery := " UPDATE " + RetSqlName(cTableName) +                 ;
							"    SET " + aFields[1] + " = '" + cNewGruIte + "'" + ; // Seta o grupo novo
							"  WHERE " + aFields[1] + " = '" + cOldGruIte + "'" + ; // Quando o item e o grupo for = antigo
							"    AND " + aFields[2] + " = '" + IIF( LEN(cFieldPrefix) == 2, cB1COD, cOldCodIte ) + "'"

		If oFilHelp:CompareAccess( xFilial('SB1'), xFilial(cTableName) ) == 'CORTAR' // significa que o b1 é mais livre então para o update precisamos deixar o filial da tabela igual a do b1
			nFilSize := LEN(ALLTRIM(xFilial('SB1')))
			cQuery   += " AND " + oSqlHelp:CompatFunc('SUBSTR') + "(" + cFieldPrefix + "_FILIAL, 1, " + STR(nFilSize) + ") = '" + xFilial('SB1') + "'"
		ElseIf oFilHelp:CompareAccess( xFilial('SB1'), xFilial(cTableName) ) == 'FECHADO' // significa que o b1 é mais restritivo(fechado) e com isso precisamos corta-lo para o update
			nFilSize := LEN(ALLTRIM(xFilial(cTableName)))
			cQuery   += " AND " +cFieldPrefix+ "_FILIAL = '" + LEFT(xFilial('SB1'), nFilSize) + "'"
		EndIF

		AADD( aUpdates, cQuery )
	Next

	BEGIN TRANSACTION
		BEGIN SEQUENCE
			
			For nIdxQueries := 1 To Len(aUpdates)
				lRes := .F.
				if ExistBlock("PEALTGR1") // checagem de ponto de entrada onde o cliente pode invalidar a validacao de exclusividade ao alterar grupo caso deseje 
					lRes := ExecBlock("PEALTGR1",.f.,.f.)
				EndIf

				If oAccControl:ExclusiveAccess() .OR. lRes
					cQuery  := aUpdates[nIdxQueries]
					nStatus := TCSqlExec( cQuery )
					If nStatus < 0
						Break // < zero significa um erro para função TCSqlExec
					EndIf
				Else
					DisarmTransaction()
					Return -2
				EndIf
			Next
			bolConfirmation := 0 // Executou tudo beleza!
		RECOVER

			DisarmTransaction()
			UserException( TCSQLError() )
			//bolConfirmation := -1 // nem retorna, porque foi um erro de sql, só da roolback e volta, na realidade não é para acontecer.
		END SEQUENCE

	END TRANSACTION
Return bolConfirmation

/*/{Protheus.doc} Mil_Logger
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Cria Logs facilmente
/*/
Class Mil_Logger
	Data cLogFileName
	Method New() CONSTRUCTOR
	Method Log()
	Method GetFile()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_Logger
	
	@param cFileName, String, Nome do arquivo que será aberto/criado para escrever o log
	@param cFileDir,  String, Pasta para colocar o log
	@author Vinicius Gati
	@since 21/05/2014
/*/
Method New(cFileName) class Mil_Logger
	cLogFolder := "logsmil"
	makeDir( curdir() + cLogFolder )
	::cLogFileName := cLogFolder + ALLTRIM(" \ ") + cFileName
Return SELF

/*/{Protheus.doc} Log
	Loga as mensagens no arquivo

	@author Vinicius Gati
	@since  21/05/2014
	@param  aLines, Array, Array com Strings que serão gravadas 1 em cada linha
/*/
Method Log(aLines) Class Mil_Logger
	Local nIdx       := 1
	Local oArquivo   := Self:GetFile()
	Local cPulaLinha := chr(13) + chr(10)

	For nIdx := 1 To Len(aLines)
		cLine := aLines[nIdx]
		If cLine == 'TIMESTAMP'
			FWRITE( oArquivo, DTOS(DATE()) + " " + TIME() + ":" + LEFT(CVALTOCHAR( SECONDS() ), 8) + " " )
		Else
			FWRITE(oArquivo, cLine + cPulaLinha)
		EndIf
		
		If FERROR() # 0
			MSGALERT(STR0002 + str(ferror()))
			Return
		Endif
	Next
	FCLOSE(oArquivo)
Return

/*/{Protheus.doc} GetFile
	Cria/Abre arquivo e retorna o mesmo

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method GetFile() Class Mil_Logger
	Local cFullFilePath := curdir() + ::cLogFileName
	Local oFileStream   := Nil
	If FILE(cFullFilePath)
		oFileStream := FOPEN( cFullFilePath, 1 ) // 1 = write FO_WRITE
	Else
		oFileStream := FCREATE( cFullFilePath )
	EndIf
	// 0 FS_SET Ajusta a partir do inicio do arquivo. (Default)
	// 1 FS_RELATIVE Ajuste relativo a posição atual do arquivo.
	// 2 FS_END Ajuste a partir do final do arquivo.
	nFinalPos := FSEEK(oFileStream,0,2)
	FSEEK(oFileStream, nFinalPos)
Return oFileStream

/*/{Protheus.doc} Mil_AccessControl
	@author       Vinicius Gati
	@since        09/06/2014
	@description  Controle de acesso ao protheus
/*/
Class Mil_AccessControl
	Method New() Constructor
	Method ExclusiveAccess()
	Method LoggedInUsers()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_AccessControl
	
	@author Vinicius Gati
	@since  09/06/2014
/*/
Method New() Class Mil_AccessControl
Return Self

/*/{Protheus.doc} ExclusiveAccess
	Verifica se existe somente 1 conexão ao servidor(a que está sendo usada)

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method ExclusiveAccess() Class Mil_AccessControl
Return Len( self:LoggedInUsers() ) == 1

/*/{Protheus.doc} LoggedInUsers
	Retorna cada conexão ao protheus server exibindo o nome do usuário

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method LoggedInUsers() Class Mil_AccessControl
	Local aLgUsers := GetUserInfoArray()
	Local nIdx := 1
	Local aUsers := {}
	For nIdx := 1 to Len(aLgUsers)
		AADD( aUsers, aLgUsers[nIdx][1] )
	Next
Return aUsers

/*/{Protheus.doc} Mil_SqlHelper
	Class que foi criada para ajudar na compatibilização de comandos sql que devem ser multi SGBD'S
	
	@author Vinicius Gati
	@since  13/06/2014
/*/
Class Mil_SqlHelper
	Method New() Constructor
	Method CompatFunc()
	Method TOPFunc()
	Method RowCountFunc()
	Method NoLock()
	Method ConvToDate()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_SqlHelper
	
	@author Vinicius Gati
	@since  13/06/2014
/*/
Method New() Class Mil_SqlHelper
Return Self

/*/{Protheus.doc} CompatFunc
	Converte algumas funcoes SQL para o banco de dados utilizado
	
	@author Vinicius Gati
	@since  13/06/2014
	@todo colocar a lista de funcoes em arrays e buscar, fica mais bonito mas por enquanto como só eu uso fica assim
/*/
Method CompatFunc(cFuncName) Class Mil_SqlHelper
	Local cRet := ''
	If cFuncName == 'SUBSTR'
		If 'MSSQL' $ cSGBD
			cRet := 'SUBSTRING'
		Else
			cRet := cFuncName
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} TOPFunc
	Converte string SQL adicionando clausula TOP de acordo com o banco de dados utilizado
	
	@author Rubens Takahashi
	@since  11/05/2015
	
	@param cQuery, character, String SQL a ser convertida
	@param nRows, numérico, Quantidade de registros retornado
	@example oSqlHelper:TOPFunc("select * from VAI", 1)
/*/
Method TOPFunc(cQuery,nRows) Class Mil_SqlHelper
	Do Case
	Case "ORACLE" $ cSGBD
		cQuery := "SELECT * FROM ( " + cQuery + " ) WHERE ROWNUM <= " + AllTrim(Str(nRows))
	Case "MSSQL" $ cSGBD
		cQuery := StrTran(cQuery,"SELECT ", "SELECT TOP " + AllTrim(Str(nRows)) + " ", , 1)
	Case "MYSQL" $ cSGBD .or. "POSTGRES" $ cSGBD
		cQuery += " LIMIT " + AllTrim(Str(nRows))
	Case "INFORMIX" $ cSGBD
		cQuery := StrTran(cQuery,"SELECT ", "SELECT FIRST " + AllTrim(Str(nRows)) + " ", , 1)
	OtherWise
		cQuery := StrTran(cQuery,"SELECT ", "SELECT TOP " + AllTrim(Str(nRows)) + " ", , 1)
	EndCase
Return cQuery

/*/{Protheus.doc} RowCountFunc
	Converte string SQL adicionando o rowcount que pode ser adicionado a select para dar uma numeracao sequenciar a cada row
	
	@author Vinicius gati
	@since  26/05/2015
	
	@param cQuery, character, String SQL a ser convertida
	@param cOver, character, No sqlserver o over é obrigatorio
	@exemple oSqlHelper:TOPFunc("select * from VAI", 1)
/*/
Method RowCountFunc(cQuerySel, cOver, cQueryCount) class Mil_SqlHelper
	Local   cQuery       := "" 
	Default cOver        := ""
	Default cQueryCount  := ""
	// Oracle, postgresql e Sql server sao iguais
	cQuery := " SELECT "+cQueryCount+" Row_Number() OVER " + cOver + " as xrownum, aaaaz.*  FROM ( " + cQuerySel + " ) aaaaz "
	Do Case
	Case "MYSQL" $ cSGBD
		cQuery := " SELECT @rn:=@rn+1 AS xrownum, aaaaz.* FROM ( " + cQuerySel + " ) as aaaaz, (SELECT @rn:= "+cQueryCount+" ) AS t "
	EndCase
Return cQuery

/*/{Protheus.doc} NoLock
	Retorna RetSqlName com noLock syntax dependendo o banco de dados utilizado, lembrando que Oracle e postgresql 
	nao da block em selects e nao é necessario usar
	este metodo, que em caso de outros bancos 
	diferentes de sqlserver e mysql ira retornar normalmente sem nolock
	
	@author Vinicius gati
	@since  5/06/2015
	
	@param cTableName, character, Nome da tabela, mesmo parametro do RetSqlName
	@param cAlias, character, Alias que sera incluido ex: "VAI"
	@example oSqlHelper:NoLock("VAI") => "VAI020 VAI with(nolock)" -> No caso de sqlserver
/*/
Method NoLock(cTableName, cQueryAlias) class Mil_SqlHelper
	Local cTabela      := " " + RetSqlName(cTableName)
	Default cQueryAlias     := cTableName
	// SqlServer
	Do Case
	Case "MSSQL" $ cSGBD
		return cTabela + " " + cQueryAlias + " with(nolock) "
	OtherWise
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes 
	EndCase
Return ""

/*/{Protheus.doc} ConvToDate
	retorna um campo data valido para o banco alvo
	
	@author Vinicius gati
	@since  5/06/2015
	
	@param cTableName, character, Nome da tabela, mesmo parametro do RetSqlName
	@param cAlias, character, Alias que sera incluido ex: "VAI"
	@example oSqlHelper:NoLock("VAI") => "VAI020 VAI with(nolock)" -> No caso de sqlserver
/*/
Method ConvToDate(cConteudo, cFieldAlias, cFormat) class Mil_SqlHelper
	Default cFieldAlias := ""
	Default cFormat     := "%Y%m%d" // formato necessário no mysql/oracle
	
	Do Case
	Case "MYSQL" $ cSGBD
		return " STR_TO_DATE(" + cConteudo + ", '"+cFormat+"') " + cFieldAlias + " "
	Case "MSSQL" $ cSGBD
		return " CONVERT(DATETIME, " + cConteudo + ") " + cFieldAlias + " "
	OtherWise
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes 
	EndCase
Return ""

/*/{Protheus.doc} Mil_RequisicaoPecaDAO
	Classe criada para buscar e modificar dados referentes a requisicoes de pecas
	
	@author Vinicius Gati
	@since  25/06/2014
/*/
Class Mil_RequisicaoPecaDAO
	Data cNumeroOs

	Method New() Constructor
	Method PecasDuplicadas()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_RequisicaoPecaDAO
	
	@author Vinicius Gati
	@since  25/06/2014
/*/
Method New(cNumOs) Class Mil_RequisicaoPecaDAO
	self:cNumeroOs := cNumOs
Return Self

/*/{Protheus.doc} New
	Retorna um array contendo dados de produtos que foram requisitados repetidamente com a quantidade total requisitada de cada um para a OS
	excluindo VSJs deletados

	@author Vinicius Gati
	@since  25/06/2014
/*/
Method PecasDuplicadas() Class Mil_RequisicaoPecaDAO
	Local aResults    := {}
	Local cVSJTblName := RetSqlName('VSJ')
	Local cFilVSJ     := xFilial('VSJ')
	Local cAlias      := 'ReqMesmaPecaDUPL'
	Local cQuery      := ''
	Local nQtdade     := 0
	Local cCacheAlias := Alias()
	Local nB1Nro      := SB1->(RecNo())
	Local nB2Nro      := SB2->(RecNo())
	Local oEstconf    := Mil_EstoqueConfig():New()

	cQuery += "   SELECT  VSJ_GRUITE, VSJ_CODITE, VSJ_NUMLOT, VSJ_LOTECT, SUM(VSJ_QTDITE) as QTDREQTOT , COUNT(*) as NROREQTOT  "
	cQuery += "     FROM  " +cVSJTblName+ " VSJ  "
	cQuery += "    WHERE VSJ.VSJ_FILIAL = '"+cFilVSJ+"' AND VSJ.D_E_L_E_T_ = ' ' and VSJ_NUMOSV = '"+self:cNumeroOs+"'  "
	cQuery += " GROUP BY VSJ_GRUITE, VSJ_CODITE, VSJ_NUMLOT, VSJ_LOTECT  "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
	(cAlias)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAlias)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo

		// Só retorna quando requisitado mais de uma vez a mesma peça com mesmo lote no mesmo orcamento
		If (cAlias)->NROREQTOT > 1
			// Pega o saldo em estoque do item
			dbSelectArea("SB1")
			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1")+ (cAlias)->VSJ_GRUITE + (cAlias)->VSJ_CODITE))
			SB1->(dbSetOrder(1)) // voltando para evitar erros com backoffice
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			If(GetNewPar("MV_RITEORC","N") == "S") // Se trabalha com reserva, pega armazem de reserva
				cLocReser := oEstconf:getEstoqueReserva()
				If Empty( cLocReser )
					MSGALERT( STR0003 )
					aResults := {}
					Exit
				Else
					SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + cLocReser))
				EndIf
			Else
				SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD))
			EndIf
			nQtdade := SaldoSb2()
			//

			aRow := {;
				(cAlias)->VSJ_GRUITE ,; // 1
				(cAlias)->VSJ_CODITE ,; // 2
				SB1->B1_DESC         ,; // 3
				(cAlias)->QTDREQTOT  ,; // 4
				nQtdade              ,; // 5
				(cAlias)->VSJ_NUMLOT ,; // 6
				(cAlias)->VSJ_LOTECT  ; // 7
			}
			AADD(aResults, aRow)
		EndIf

		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())

	DbSelectArea(cCacheAlias)
	SB1->(DbGoTo(nB1Nro))
	SB2->(DbGoTo(nB2Nro))
Return aResults

/*/{Protheus.doc} Mil_EstoqueConfig
	Classe criada para encapsular dados de configuracoes do estoque, referentes a parametros ou não
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Class Mil_EstoqueConfig
	Method New() Constructor
	Method getEstoqueReserva()
EndClass

/*/{Protheus.doc} New
	Construtor simples Mil_EstoqueConfig
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Method New() Class Mil_EstoqueConfig
Return Self

/*/{Protheus.doc} EstoqueReserva
	Retorna o codigo do estoque de reserva

	@author Vinicius Gati
	@since  30/07/2014
/*/
Method getEstoqueReserva() Class Mil_EstoqueConfig
Return GetNewPar("MV_RESITE", "")


/*/{Protheus.doc} Mil_PMV
	Classe utilizada no calculo de prazo médio de venda de notas fiscais, inclusive pode ser usada para calcular
	o prazo médio ponderado, em caso de várias notas.

	@author Vinicius Gati
	@since 07/08/2014
/*/
Class Mil_Pmv
	Data aEntradas
	Data aSaidas

	Method New() CONSTRUCTOR
	Method Calcular()
	Method NfDadosEnt()
	Method NfDadosSai()
	Method Ponderar()
	Method GetDataToPond()
EndClass

/*/{Protheus.doc} New
	Salva os dados das notas(saídas/entradas) que serão avaliadas

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method New(aEntradas, aSaidas) Class Mil_PMV
	Self:aEntradas  := aEntradas
	Self:aSaidas    := aSaidas
Return Self

/*/{Protheus.doc} Calcular
	Calcula o PMV das notas

	Dados necessários das notas de entradas e saidas

			Saidas:
				'Quebra'
				'D2_LOJA'         Obrigatórios
				'D2_CLIENTE'      Obrigatórios
				'D2_DOC'          Obrigatórios
				'D2_SERIE'        Obrigatórios
				'E1_FILIAL'       Obrigatórios
				'F2_PREFORI'      Obrigatórios

			Entradas:
				'Quebra'
				'D1_LOJA'         Obrigatórios
				'D1_FORNECE'      Obrigatórios
				'D1_DOC'          Obrigatórios
				'D1_SERIE'        Obrigatórios
				'E2_FILIAL'       Obrigatórios
				'D1_PREFORI'      Obrigatórios

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method Calcular(oFiltro)  Class Mil_PMV
	Local aDtToPond := {}
	aDtToPond := Self:GetDataToPond(oFiltro, .T.) // Primeiro array igualo
	AEVAL(Self:GetDataToPond(oFiltro, .F.), {|el| AADD(aDtToPond, el) }) // segundo eu faço merge dos registros para ponderar
Return Self:Ponderar(aDtToPond)

/*/{Protheus.doc} GetDataToPond
	Retorna array com dados do PMV de cada nota para futuro ponderamento
	
	@author Vinicius Gati
	@since  07/08/2014
/*/
Method GetDataToPond(oFiltro, lEntrada) Class Mil_PMV
	Local nIdx    := 1
	Local nIdx2   := 1
	Local aWork   := {}
	Local nTotal  := 0.0
	Local nTotInd := 0.0 // total do indice para PMV
	Local aNfs    := IIF(lEntrada, Self:aEntradas, Self:aSaidas)
	Local aRet    := {}
	
	If Len(aNfs) > 0 .AND. !Empty( oFiltro:GetValue('Quebra') )
		For nIdx := 1 to Len(aNfs)
			If aNfs[nIdx]:GetValue('F2_PREFORI') == oFiltro:GetValue('F2_PREFORI') .OR. oFiltro:GetValue('F2_PREFORI') == 'Todos' // Balcao, Oficina ou todos
				If aNfs[nIdx]:GetValue('Quebra') == oFiltro:GetValue('Quebra') .OR. oFiltro:GetValue('Quebra') == 'Todos'

					// Quebra em branco significa que o grid esta vazio na tela
					aWork := IIF(lEntrada, Self:NfDadosEnt(aNfs[nIdx]), Self:NfDadosSai(aNfs[nIdx]))

					// a estrutura retornada é de um array contendo arrays com dados de cada parcela de cada nota
					// neste momento não importa a nota mais, só as parcelas de cada nota para calculo do PMV e futuramente o PMV ponderado
					nTotal  := 0.0
					nTotInd := 0.0
					For nIdx2 := 1 to Len(aWork)
						nTotal  += aWork[nIdx2]:GetValue('VALOR')
						nTotInd += aWork[nIdx2]:GetValue('DateDiff') * aWork[nIdx2]:GetValue('VALOR')
					Next
					AADD( aRet, { nTotal, (nTotInd/nTotal) } ) // Valor total da nota + PMV, dados utilizados no PMV ponderado 
				EndIf
			EndIf
		Next
	EndIf
Return aRet

/*/{Protheus.doc} NfDadosEnt
	Retorna array com dados do PMV de cada nota para futuro ponderamento

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method NfDadosSai(oNfData, oFiltro)  Class Mil_PMV
	Local cQEnt := ""
	Local cAl   := 'Saidas'
	Local aRet  := {}

	cQEnt += "      SELECT SE1.E1_VALOR, SE1.E1_VENCTO, SE1.E1_EMISSAO                                                              "
	cQEnt += "        FROM " + RetSqlName('SD2') + " SD2                                                                            "
	cQEnt += "   LEFT JOIN " + RetSqlName('SE1') + " SE1 ON SE1.E1_LOJA   = SD2.D2_LOJA   AND  SE1.E1_CLIENTE = SD2.D2_CLIENTE  AND "
	cQEnt += "                                              SE1.E1_NUM    = SD2.D2_DOC    AND  SE1.E1_PREFIXO = SD2.D2_SERIE    AND "
	cQEnt += "                                              SE1.D_E_L_E_T_ = ' '                                                    "
	cQEnt += "       WHERE SD2.D_E_L_E_T_ = ' '                                      "
	cQEnt += "         AND SE1.E1_FILIAL  = '" + oNfData:GetValue('E1_FILIAL')  + "' "
	cQEnt += "         AND SE1.E1_LOJA    = '" + oNfData:GetValue('D2_LOJA')    + "' "
	cQEnt += "         AND SE1.E1_CLIENTE = '" + oNfData:GetValue('D2_CLIENTE') + "' "
	cQEnt += "         AND SE1.E1_NUM     = '" + oNfData:GetValue('D2_DOC')     + "' "
	cQEnt += "         AND SE1.E1_PREFIXO = '" + oNfData:GetValue('D2_SERIE')   + "' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQEnt), cAl, .F., .T. )
	(cAl)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		AADD(aRet, Mil_DataContainer():New({ ;
			{'VALOR'      , (cAl)->E1_VALOR                      },;
			{'E1_VENCTO'  , (cAl)->E1_VENCTO                     },;
			{'E1_EMISSAO' , (cAl)->E1_EMISSAO                    },;
			{'DateDiff'   , STOD((cAl)->E1_VENCTO) - STOD((cAl)->E1_EMISSAO)+1 } ;
		}))

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} NfDadosSai
	Salva os dados das notas saidas que serão avaliadas

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method NfDadosEnt(oNfData, oFiltro) Class Mil_PMV
	Local cQSai := ""
	Local cAl   := 'Entradas'
	Local aRet  := {}


	cQSai += "      SELECT SE2.E2_VALOR, SE2.E2_VENCTO, SE2.E2_EMISSAO                                                               "
	cQSai += "        FROM " + RetSqlName('SD1') + " SD1                                                                             "
	cQSai += "   LEFT JOIN " + RetSqlName('SE2') + " SE2 ON SE2.E2_LOJA   = SD1.D1_LOJA   AND  SE2.E2_FORNECE = SD1.D1_FORNECE  AND  "
	cQSai += "                                              SE2.E2_NUM    = SD1.D1_DOC    AND  SE2.E2_PREFIXO = SD1.D1_SERIE    AND  "
	cQSai += "                                              SE2.D_E_L_E_T_ = ' '                                                     "
	cQSai += "       WHERE SD1.D_E_L_E_T_ = ' ' "
	cQSai += "         AND SE2.E2_FILIAL  = '" + oNfData:GetValue('E2_FILIAL')  + "' "
	cQSai += "         AND SE2.E2_LOJA    = '" + oNfData:GetValue('D1_LOJA')    + "' "
	cQSai += "         AND SE2.E2_FORNECE = '" + oNfData:GetValue('D1_FORNECE') + "' "
	cQSai += "         AND SE2.E2_NUM     = '" + oNfData:GetValue('D1_DOC')     + "' "
	cQSai += "         AND SE2.E2_PREFIXO = '" + oNfData:GetValue('D1_SERIE')   + "' "


	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQSai), cAl, .F., .T. )
	(cAl)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		AADD(aRet, Mil_DataContainer():New({ ;
			{'VALOR'      , (cAl)->E2_VALOR                      },;
			{'E2_VENCTO'  , (cAl)->E2_VENCTO                     },;
			{'E2_EMISSAO' , (cAl)->E2_EMISSAO                    },;
			{'DateDiff'   , STOD((cAl)->E2_VENCTO) - STOD((cAl)->E2_EMISSAO)+1 } ;
		}))

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} New
	Calcula o PMV ponderado de todas as notas passadas no parametro.
	o PMV ponderado é calculado da seguinte forma:

	Prazo médio ponderado entre o prazo e o valor de cada ativo considerado, a partir de determinada data (01/11/04) de dois títulos:
	valor R$100.000,00 com vencimento em 24/12/2004 - 53 dias;
	valor R$ 50.000,00 com vencimento em 25/01/2005 - 85 dias.
	Valor total = R$ 150.000,00
	O cálculo da média ponderada dos prazos é feito:
	
	a) multiplicando o número de dias pelo valor de cada um dos títulos
		53 x 100.000 = 5.300.000
		85 x 50.000 = 4.250.000
	
	b) somando os valores encontrados;
		5.300.000 + 4.250.000 = 9.550.000
	
	c) dividindo pelo valor total dos títulos envolvidos
		9.550.000 / 150.000
	
	d) chegando ao resultado que corresponde ao prazo médio de 63,67 dias

	!!!Sempre pondera os dados, já que caso queira o PMV de 1 só nota basta passar só os dados de 1 nota, o resultado será o mesmo.

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method Ponderar(aDados) Class Mil_PMV
	Local nSumTot := 0
	Local nSumInd := 0.0
	Local nIdx    := 0

	For nIdx := 1 to LEN(aDados)
		// 1 = Valor total, 2 = PMV
		nSumTot += aDados[nIdx, 1]
		nSumInd += aDados[nIdx, 1] * aDados[nIdx, 2]
	Next
	If nSumTot == 0
		Return 0
	EndIf
Return nSumInd/nSumTot // PMV ponderado dos titulos


/*/{Protheus.doc} Mil_Campanha
	Representa tabela do VX5	

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class Mil_Campanha
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class Mil_Campanha
Return Self

Method GetTbCode() Class Mil_Campanha
Return '026'


/*/{Protheus.doc} Mil_FaseFinanciamento
	Representa tabela do VX5	

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class Mil_FaseFinanciamento
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New
	
	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class Mil_FaseFinanciamento
Return Self

Method GetTbCode() Class Mil_FaseFinanciamento
Return '031'

/*/{Protheus.doc} Mil_LinhasDeCredito
	Representa tabela do VX5

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class Mil_LinhasDeCredito
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New
	
	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class Mil_LinhasDeCredito
Return Self

Method GetTbCode() Class Mil_LinhasDeCredito
Return '032'

/*/{Protheus.doc} Mil_FasesOrcamento // 24/03/2022 - Alex - Tornar Classe Obsoleta

	@author Vinicius Gati
	@since 06/03/2015
/*/
/* Class Mil_FasesOrcamento // 24/03/2022 - Alex - Tornar Classe Obsoleta
	Data oData

	Method New() CONSTRUCTOR
//	Method All() // Não é permitido pela Totvs TEC a criação de metodo com nome ALL
	Method Get()
EndClass */

/*/{Protheus.doc} New  // 24/03/2022 - Alex - Tornar Classe Obsoleta
	
	@author Vinicius Gati
	@since  06/03/2015
/*/
/* Method New() Class Mil_FasesOrcamento  // 24/03/2022 - Alex - Tornar Classe Obsoleta
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
	aStatus := {;
		{"0", STR0004 },; // "ORÇAMENTO DIGITADO"
		{"X", STR0005 },; // "ORÇAMENTO FECHADO"
		{"C", STR0006 },; // "ORÇAMENTO CANCELADO"
		{"2", STR0007 },; // "MARGEM DE LUCRO"
		{"3", STR0008 },; // "LIMITE DE CREDITO"
		{cFaseConfer, STR0009 },; // "SEPARACAO E CONFERENCIA"
		{"5", STR0010 },; // "LIBERACAO DE DIVERGENCIA"
		{"E", STR0011 },; // "ORCAMENTO ENVIO DE EMAIL"
		{"R", STR0012 },; // "RESERVA O ITEM"
		{"O", STR0013 },; // "IMPRIME ORDEM DE BUSCA"
		{"B", STR0014 },; // "GRAVAÇÃO DO VQH (BACKORDER)"
		{"T", STR0015 },; // "Aguard. Transf./Reserva"
		{"I", STR0016 },; // Exportado para OS
		{"P", STR0018 },; // ORÇAMENTO PENDENTE
		{"L", STR0019 },; // ORÇAMENTO LIBERADO
		{"F", STR0017 } ; // Pronto para faturar
	}
	If ( ExistBlock("VXFNB001") )
		aStatus := ExecBlock("VXFNB001",.f.,.f.,{aStatus})
	EndIf
	::oData := Mil_DataContainer():New(aStatus)
Return Self */
/*/ Não é permitido pela Totvs TEC a criação de metodo com nome ALL
Method All(cNumOrc) Class Mil_FasesOrcamento
Return Self:oData
*/
/*
Method Get(cStats) Class Mil_FasesOrcamento // 24/03/2022 - Alex - Tornar Classe Obsoleta
	If Empty(cStats)
		cStats := "0"
	EndIf	
	cVal := Self:oData:GetValue(cStats)
Return cVal
*/

/*/{Protheus.doc} Mil_Util

	Classe com metodos gerais de ajuda, para trabalhar com strings, numeros, datas, etc

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class Mil_Util
	Method New() CONSTRUCTOR
	Method UltimoDia()
EndClass

/*/{Protheus.doc} New
	
	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class Mil_Util
Return Self

Method UltimoDia(nAno, nMes) class Mil_Util
	Local cDia     := "31"
	Local dDtUlDia := STOD( STR(nAno)  + STRZERO(nMes,2) + cDia )
	
	if INT(nMes/2) == (nMes/2)
		cDia := "30" 
	EndIf
	
	dDtUlDia := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + cDia )
	if YEAR(dDtUlDia) == 0 .OR. MONTH(dDtUlDia) == MONTH(dDtUlDia+1) // fevereiro tem 28 dias
		cDia := "28"
		dDtUlDia := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + cDia ) 
		if YEAR(dDtUlDia) == 0 .OR. MONTH(dDtUlDia) == MONTH(dDtUlDia+1) // se for bisexto a mesma checkagem da errado então o ultimo dia é 29
			cDia := "29"
			dDtUlDia := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + cDia )
		endif
	endif 
Return dDtUlDia
