#INCLUDE "PROTHEUS.CH"
#INCLUDE "NGKPI.CH"

#DEFINE PARAM_FIELD 1
#DEFINE PARAM_VALUE 2

#DEFINE ARQUIVO_STRUCT 1
#DEFINE   CAMPO_STRUCT 2
#DEFINE    TIPO_STRUCT 3
#DEFINE TAMANHO_STRUCT 4
#DEFINE DECIMAL_STRUCT 5
#DEFINE  TITULO_STRUCT 6
#DEFINE DESCRIC_STRUCT 7
#DEFINE PICTURE_STRUCT 8
#DEFINE CONTEXT_STRUCT 9
#DEFINE OBRIGAT_STRUCT 10
#DEFINE   VALID_STRUCT 11
#DEFINE VLDUSER_STRUCT 12
#DEFINE    CBOX_STRUCT 13

//------------------------------
// For�a a publica��o do fonte
//------------------------------
Function _NGKPI()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGKPI
Classe de Indicadores de Classe Mundial - Key Performance Indicators.

@author Wexlei Silveira
@since 16/07/2018
@version P12
/*/
//------------------------------------------------------------------------------
Class NGKPI FROM NGGenerico

	Method New() CONSTRUCTOR

	//------------------------------------------------------
	// P�blico: Valida��o e Opera��o
	//------------------------------------------------------
	Method validBusiness() // Valida��es de neg�cio
	Method validPre() // Pr�-valida��o do processo
	Method setIndParams() // Inclui os valores no objeto
	Method getKPI() // Executa o c�lculo do indicador

    //-------------------------------------------------------
	// Privado: C�lculo por Tipo de indicador
	//-------------------------------------------------------
	Method getIndicator() // Calcula valor do indicador

    //-------------------------------------------------------
	// Privado: Atribui��es internas
	//-------------------------------------------------------
	Method setStruct() // Realiza a cria��o da estrutura do objeto
	Method loadParams() // Carrega todos os par�metros dos indicadores
	Method loadFormulas() // Carrega todas as formulas dos indicadores
	Method fillParam() // Popula os par�metros 'At�' com conte�do
	Method getValue() // Retorna o conte�do do par�metro informado
	Method setIndName() // Define o nome do indicador atual
	Method getIndName() // Retorna o nome do indicador atual

	//--------------------------------------------------------------------------
	// Privado: Atributos gerais
	//--------------------------------------------------------------------------
	Data aMemory   As Array            // Campos e valores do Indicadores
	Data aFormulas As Array            // Cont�m as formulas dos Indicadores
	Data aStruct   As Array            // Estrutura dos campos do Indicadores
	Data cIndName  As String           // C�digo do Indicador atual
	Data lValidOk  As Boolean Init .F. // Inibir multiplas chamadas de valida��o

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe

@author Wexlei Silveira
@since 16/07/2018
@version P12
@return Self, Objeto, objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class NGKPI

	_Super:New()

	//Define valores padr�o das vari�veis.
	::aMemory    := {}
	::aStruct    := {}
	::aFormulas  := {}

	// Cria a estrutura de dados do objeto.
	::setStruct()

	// Carrega todos os par�metros dos indicadores.
	::loadParams()

	// Carrega todas as formulas para calculo dos indicadores.
	::loadFormulas()

	// Define o tipo de valida��o da classe.
	::setValidationType("B")

	// Par�metros utilizados
	::SetParam("MV_NGMNTFI", "N") // Integra��o com Financeiro.

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} getValue
Retorna o conte�do de um campo da estrutura de dados.

@param cField campo da estrutura de dados

@author Wexlei Silveira
@since 18/07/2018
@version P12
@return xValue Conte�do do campo.
@sample cValue := oObj:getValue("CAMPO")
/*/
//------------------------------------------------------------------------------
Method getValue(cField) Class NGKPI

	Local nValue := 0

	Default cField := "0"

	nValue := aScan(::aMemory, {|a| AllTrim(a[PARAM_FIELD]) == AllTrim(cField)})

	If nValue == 0
		//"Aten��o### //"O par�metro"####"DE_DATA n�o foi encontrado na tabela de Tipos de Par�metro. Por favor alterar
		//  o par�metro informado ou realizar a inclus�o na tabela de Tipos de Par�metros."
		Help( , , STR0013 , , STR0001 + " " + Alltrim(cField) + " " + STR0014 , 4 , 0 )
	EndIf

Return IIf(nValue == 0,"",::aMemory[nValue][PARAM_VALUE])

//------------------------------------------------------------------------------
/*/{Protheus.doc} setStruct
Carrega a estrutura inteira da tabela para cada campo de acordo com a TZ4.

@author Wexlei Silveira
@since 18/07/2018
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Method setStruct() Class NGKPI

	Local aArea := GetArea()
	Local nTail := 0

	dbSelectArea("TZ4")
	dbSetOrder(1) // TZ4_FILIAL + TZ4_MODULO + TZ4_CODPAR
	dbGoTop()
	While TZ4->(!Eof())
		aAdd(::aStruct, Array(13))
		nTail := Len(::aStruct)
		::aStruct[nTail,ARQUIVO_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_ARQUIVO"), TZ4->TZ4_TABELA)
		::aStruct[nTail,CAMPO_STRUCT  ] := AllTrim(TZ4->TZ4_CODPAR)
		::aStruct[nTail,TIPO_STRUCT   ] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_TIPO"), IIf(TZ4->TZ4_TIPO == "4", "D", IIf(TZ4->TZ4_TIPO $ "62", "N","C")))
		::aStruct[nTail,TAMANHO_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_TAMANHO"), TZ4->TZ4_TAMANH)
		::aStruct[nTail,DECIMAL_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_DECIMAL"), TZ4->TZ4_DECIMA)
		::aStruct[nTail,TITULO_STRUCT ] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3Titulo()"), TZ4->TZ4_DESCRI)
		::aStruct[nTail,DESCRIC_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3Descric()"), TZ4->TZ4_DESCRI)
		::aStruct[nTail,PICTURE_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_PICTURE"), IIf(Empty(TZ4->TZ4_PICTUR), "@!", TZ4->TZ4_PICTUR))
		::aStruct[nTail,CONTEXT_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_CONTEXT"), "V")
		::aStruct[nTail,OBRIGAT_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),IIf(Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3Obrigat(TZ4->TZ4_CAMPOS)"),"S","N"), "N")
		::aStruct[nTail,VALID_STRUCT  ] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_VALID"), TZ4->TZ4_VALID)
		::aStruct[nTail,VLDUSER_STRUCT] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_VLDUSER"), "")
		::aStruct[nTail,CBOX_STRUCT   ] := IIf(!Empty(TZ4->TZ4_CAMPOS),Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3CBox()"), TZ4->TZ4_OPCOES)
		TZ4->(dbSkip())
	End

	RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} loadParams
Carrega a estrutura de par�metros de todos os indicadores.

@author Guilherme Freudenburg
@since 08/08/2018
@version P12
@return
/*/
//------------------------------------------------------------------------------
Method loadParams() Class NGKPI

	Local aArea   := GetArea()
	Local nStruct := 0
	Local nTail   := 0

	dbSelectArea("TZ4")
	dbSetOrder(1) // TZ4_FILIAL + TZ4_MODULO + TZ4_CODPAR
	dbGoTop()
	While TZ4->(!Eof())
		aAdd(::aMemory, Array(2))
		nTail := Len(::aMemory)
		::aMemory[nTail,PARAM_FIELD] := TZ4->TZ4_CODPAR
		Do Case
			Case TZ4->TZ4_TIPO == "1" .Or. TZ4->TZ4_TIPO == "5" // 1 = Caracter ou 5 = Campo
				nStruct := aScan(::aStruct, {|a| a[CAMPO_STRUCT] == AllTrim(TZ4->TZ4_CODPAR)}) // Busca a posi��o do campo na estrutura.
				If nStruct > 0
					If "ATE_" $ Alltrim(TZ4->TZ4_CODPAR)
						::aMemory[nTail,PARAM_VALUE] := Replicate("Z", ::aStruct[nStruct, TAMANHO_STRUCT]) // Adiciona o 'ZZZZ' conforme o tamanho do campo.
					Else
						::aMemory[nTail,PARAM_VALUE] := "" // Determina valor default.
					EndIf
				EndIf
			Case TZ4->TZ4_TIPO == "2" // 2 = Numerico
				::aMemory[nTail,PARAM_VALUE] := 0
			Case TZ4->TZ4_TIPO == "3" // 3 = Logico
				::aMemory[nTail,PARAM_VALUE] := .T.
			Case TZ4->TZ4_TIPO == "4" // 4 = Data
				::aMemory[nTail,PARAM_VALUE] := dDataBase
			Case TZ4->TZ4_TIPO == "6" // 6 = Lista Opcoes
				::aMemory[nTail,PARAM_VALUE] := "1"
			Otherwise
				::aMemory[nTail,PARAM_VALUE] := ""
		EndCase
		TZ4->(dbSkip())
	End

	RestArea(aArea) // Retorna �rea posicionada.

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} loadFormulas
Carrega todas as formulas para calculo dos indicadores.

@author Guilherme Freudenburg
@since 09/08/2018
@version P12
@return
/*/
//------------------------------------------------------------------------------
Method loadFormulas() Class NGKPI

	Local aArea   := GetArea()
	Local nTail   := 0

	dbSelectArea("TZ5")
	dbGoTop()
	While TZ5->(!Eof())
		aAdd(::aFormulas, Array(2))
		nTail := Len(::aFormulas)
		::aFormulas[nTail,PARAM_FIELD] := TZ5->TZ5_CODIND
		::aFormulas[nTail,PARAM_VALUE] := StrTran(Alltrim(TZ5->TZ5_FORMUL)+Alltrim(TZ5->TZ5_FORCON), Chr(10) , "")
		TZ5->(dbSkip())
	End

	RestArea(aArea) // Retorna �rea posicionada.

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} fillParam
Adiciona par�metros n�o informados pelo usu�rio e
preenche os campos "ATE" obrigat�rios com ZZZ quando estiverem vazios.

@param aParam, Array, Array com os par�metros do indicador.

@obs - Exemplo da estrutura do par�metro aParam:
 	aParam := { {"DE_BEM"    , ""},;
	         	{"ATE_BEM"   , "ZZZZZZZZZZZZZZZZ"},;
				{"DE_CCUSTO" , ""},;
				{"ATE_CCUSTO", "ZZZZZZZZZ"},;
				{"DE_CENTRA" , ""},;
				{"ATE_CENTRA", "ZZZZZZ"} }

@author Wexlei.Silveira
@since 18/07/2018
@version P12
@return aRet, Array, Array com os par�metros preenchidos
/*/
//------------------------------------------------------------------------------
 Method fillParam(aParam) Class NGKPI

	Local nI      := 0
	Local nStruct := 0
	Local aRet    := aClone(aParam)
	Local aArea   := GetArea()

	For nI := 1 To Len(aRet) // Percorre todos os par�metros informados.

		// Identifica par�metros informados para alterar dentro da vari�vel ::aMemory.
		nStruct := aScan(::aMemory, {|a| Alltrim(a[PARAM_FIELD]) == AllTrim(aRet[nI,PARAM_FIELD])}) // Busca a posi��o do campo na estrutura.
		If nStruct > 0 .And. !Empty(aRet[nI,2])
			::aMemory[nStruct,PARAM_VALUE] := aRet[nI,2]
		EndIf

	Next nI

	RestArea(aArea)

Return ::aMemory

//------------------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
M�todo que realiza a valida��o da regra de neg�cio da classe.

@author Guilherme Freudenburg
@since 16/07/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method validBusiness() Class NGKPI

	Local aArea   := GetArea()
	Local cError  := ""
	Local xError
	Local xValPar
	Local cType   := ""
	Local cValid  := ""
	Local nLoop   := 0
	Local nX      := 0
	Local cModule := ""
	Local aParams := fGetAllPar(::getIndName()) // Busca todos os par�metros.

	If ::validPre()

		cModule := Posicione("TZ5", 2, xFilial("TZ5") + ::getIndName(), "TZ5_MODULO") // Busca o m�dulo do indicador.

		// Valida��o campo a campo
		For nLoop := 1 To Len(aParams)

			cType := Posicione("TZ4", 1, xFilial("TZ4") + cModule + aParams[nLoop], "TZ4_TIPO")

			Do Case // Define o tipo do campo
				Case cType == "2"
					cType := "N"
				Case cType == "3"
					cType := "L"
				Case cType == "4"
					cType := "D"
				Otherwise
					cType := "C"
			EndCase

			// Tipo do valor fornecido deve ser o mesmo tipo do campo
			If Empty(cError) .And.  ValType(::getValue(aParams[nLoop])) != cType
				cError := STR0003 + AllTrim(aParams[nLoop]) + "." // "Tipo de valor inv�lido para o campo "
			EndIf

			// Campos obrigat�rios
			If Empty(cError) .And. Empty(::getValue(aParams[nLoop])) .And. fRequired(aParams[nLoop], ::getIndName())
				cError := STR0004 + AllTrim(aParams[nLoop]) + STR0005 // "O campo " ### " � obrigat�rio."
			EndIf

			// Execu��o do valid do campo, caso exista
			If Empty(cError)

				cValid := AllTrim(Posicione("TZ4", 1, xFilial("TZ4") + cModule + aParams[nLoop], "TZ4_VALID"))
				cValid := AllTrim(StrTran(cValid, "M->", "", 1)) // TODO: se todos os valids forem alterados para o novo modelo, remover essa linha.
				cValid := AllTrim(StrTran(cValid, "NGI6CODATE", "NGValFromTo", 1))
				cValid := AllTrim(StrTran(cValid, "NGI6VDTIND(", "NGValFromTo('',", 1))

				For nX := 1 To Len(aParams)

					If At(Upper(AllTrim(aParams[nX])), Upper(cValid))
						Do Case // Define o tipo do campo
							Case cType == "N" .Or. cType == "L"
								xValPar := cValToChar(::getValue(AllTrim(aParams[nX])))
							Case cType == "D"
								xValPar := DToS(::getValue(AllTrim(aParams[nX])))
							Otherwise
								xValPar := ::getValue(AllTrim(aParams[nX]))
						EndCase
						cValid := AllTrim(StrTran(cValid, AllTrim(aParams[nX]), "'" + xValPar + "'", 1))
					EndIf

				Next nX

				If At(Upper("EXISTCPO"), Upper(cValid)) // Verifica se o campo existe

					If !(&cValid)
						cError := STR0006 + AllTrim(aParams[nLoop]) + STR0007 // "Registro do campo " ### " n�o encontrado."
					EndIf

				Else // Valida��o pela fun��o NGValFromTo ou fun��o equivalente

					xError := &cValid

					If ValType(xError) == "C"

						cError := xError

					ElseIf ValType(xError) == "L"

						If !xError
							cError := STR0008 + AllTrim(aParams[nLoop]) + STR0009 // "Valor do campo " ### " inv�lido."
						EndIf

					EndIf

				EndIf

			EndIf

			If !Empty(cError)
				Exit
			EndIf

		Next nLoop

		// Adiciona o Erro ao Objeto instanciado
		If !Empty( cError )
			::addError( cError )
		EndIf

	EndIf

	RestArea(aArea)

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} validPre
M�todo que realiza a pr�-valida��o para utiliza��o da classe.
@method

@author Alexandre Santos
@since 04/05/2020

@sample validPre( { 'MTBF', 'MTTR'} )

@param  aIndicator, Array, Indicadores que ser�o validados.
@return Boolean   , Confirma que as premissas da classe foram validadas.
/*/
//------------------------------------------------------------------------------
Method validPre( aIndicator ) Class NGKPI

	Local nIndex       := 0
	Local cError       := ''

	Default aIndicator := { Trim( ::getIndName() ) }

	::SetValid( .T. )

	For nIndex := 1 To Len( aIndicator )

		// Indicador deve existir na TZ5
		dbSelectArea( 'TZ5' )
		dbSetOrder( 2 ) // TZ5_FILIAL + TZ5_CODIND
		If !MsSeek( xFilial( 'TZ5' ) + aIndicator[nIndex] )
			cError := STR0002 + aIndicator[nIndex] + STR0015 // O indicador XXXX n�o foi localizado.
			Exit
		EndIf

	Next nIndex

	// Adiciona o Erro ao Objeto instanciado
	If !Empty( cError )
		::addError( cError )
	EndIf

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} setIndParams
M�todo para inclus�o dos valores no objeto.

@param aParam , Array, Array com os valores para inclus�o no objeto

@author Wexlei Silveira
@since 16/07/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method setIndParams(aParam) Class NGKPI

	Default aParam := {}

	::aMemory := ::fillParam(aParam)

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} getKPI
M�todo para execu��o do c�lculo do indicador.
@type method

@author Wexlei Silveira
@since 16/07/2018

@param cIndicator, Caracter, Indicador que ser� calculado.
@param lNoVAlid  , L�gico  , N�o realiza a valida��o dos par�metros
@return xIndicator, Indefinido, Resultado do c�lculo do indicador.
/*/
//------------------------------------------------------------------------------
Method getKPI( cIndicator, lNoValid ) Class NGKPI

	Local aArea      := GetArea()
	Local xIndicator // retorno do indicador.

	Default lNoValid := .F.

	::setIndName(cIndicator)

	/*
		A variavel lValidOK possui escopo private e � inicializada na rotina MNTA360 com intuito de inibir
		valida��es repetidas desencess�rias, otimizando assim a performance da rotina.
	*/
	If lNoValid .Or. ( ::lValidOk := ::valid() )

		BEGIN TRANSACTION

			xIndicator := ::getIndicator(cIndicator) // Calcula a formula do Indicador.

			// Finaliza processo de gera��o
			If !::isValid()
				DisarmTransaction()
			EndIf

		END TRANSACTION

		// Finaliza o processo de gera��o dos indicadores.
		MsUnlockAll()

	EndIf

	RestArea(aArea)

Return xIndicator

//------------------------------------------------------------------------------
/*/{Protheus.doc} setIndName
Define o indicador atual.

@param cIndicator, Caracter, Indicador que ser� calculado.

@author Wexlei Silveira
@since 14/08/2018
@return True
/*/
//------------------------------------------------------------------------------
Method setIndName(cIndicator) Class NGKPI
	::cIndName := cIndicator
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} getIndName
Retorna o indicador atual.

@author Wexlei Silveira
@since 14/08/2018
@return cIndName, Caractere, Nome do indicador atual.
/*/
//------------------------------------------------------------------------------
Method getIndName() Class NGKPI
Return ::cIndName

//------------------------------------------------------------------------------
/*/{Protheus.doc} fRequired
Retorna se o campo � obrigat�rio para o indicador.

@param cParam, Caracter, C�digo do campo de par�metro.
@param cIndicator, Caracter, Indicador que ser� calculado.

@author Wexlei Silveira
@since 14/08/2018
@return lRet, L�gico, Se o campo � obrigat�rio ou n�o.
/*/
//------------------------------------------------------------------------------
Static Function fRequired(cParam, cIndicator)

	Local lRet := .F.
	Local aArea := GetArea()

	lRet := !Empty(Posicione("TZ7", 1, xFilial("TZ7") + cParam + cIndicator, "TZ7_CODPAR"))

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getIndicator
M�todo respons�vel por favor o calculo do indicador, quebrando a formula e
preenchendo os parametros.

@param cIndicator, Caracter, Indicador que ser� calculado.

@author Guilherme Freudenburg
@since 23/07/2018
@return xResult, Indefinido, Valor do indicador, pode ser Num�rico ou Horas.
/*/
//------------------------------------------------------------------------------
Method getIndicator(cIndicator) Class NGKPI

	Local xResult   := Nil  // Resultado do indicador.
	Local cModule   := Posicione("TZ5",2,xFilial("TZ5")+cIndicator,"TZ5_MODULO") // Busca o m�dulo do indicador.
	Local cFormula  := fGetFormula(::aFormulas,cIndicator) // Busca a formula que ser� utilizada.
	Local cCalcForm := "" // Formula resultante que ser� feito o calculo.
	Local cFunction := "" // Fun��o adicionada na vari�vel.
	Local cValMNTV  := "" // Valor do calculo vari�vel.
	Local cVarCode  := "" // C�digo da vari�vel.
	Local nPos1     := 0  // Utilizada para identificar in�cio do MNTV na formula do indicador.
	Local nPos2     := 0  // Utilizada para identificar fim do MNTV na formula do indicador.
	Local nXX       := 0  // Variavel de controle.
	Local nComma    := 0  // Quantidade de virgulas adicionadas nas formulas, para o calculo do indicador.
	Local aParams   := {} // Todos os par�metros.

	While !Empty(cFormula) // Verifica se o indicador possui formula.

		nPos1 := AT("@",cFormula) // Quebra a formula at� o primeiro '@', basicamente at� o in�cio do primeiro MNTV.

		If nPos1 > 0 // Verifica a posi��o que ser� iniciado.

			nPos2 := AT("@", Substr(cFormula,nPos1+1) ) // Identifica a marca��o fim do MNTV.

			If nPos2 > 0 // Caso encontrou a posi��o fim do MNTV.

				cVarCode  := Substr( cFormula , nPos1+1 , nPos2-1 ) // Separa o MNTV do resto da formula.
				cCalcForm += Substr( cFormula , 1 , nPos1 - 1) // Adiciona elementos antes do MNTV como '('.
				cFunction := fGetFunction(PadR(cVarCode,12),cModule) // Busca a fun��o do MNTV.
				aParams   := fGetParams(PadR(cVarCode,12),cModule) // Busca os par�metros necess�rios para o MNTV.
				nComma    := 1 //Determina a quantidade de virgulas que ser�o adicionadas na separa��o de dos par�metros do MNTV.

				For nXX := 1 To Len(aParams)

					While nComma < Val(aParams[nXX,1]) //Verifica a quantidade de vrigulas necess�rias para separar os parametros do MNTV.
						cFunction += "," // Adiciona a virgula a aqua��o.
						nComma++ // Soma valor ao contador de virgulas.
					End

					If ValType(::getvalue(Alltrim(aParams[nXX,2]))) == "C" // Caso par�metro seja do tipo Caracter.
						If !Empty(::getvalue(Alltrim(aParams[nXX,2])))
							cFunction += "'" + Alltrim( ::getvalue(Alltrim(aParams[nXX,2])) ) + "'"
						Endif
					ElseIf ValType(::getvalue(Alltrim(aParams[nXX,2]))) == "N" // Caso par�metro seja do tipo Num�rico.
						cFunction += Alltrim( Str( ::getvalue(Alltrim(aParams[nXX,2])) ) )
					ElseIf ValType(::getvalue(Alltrim(aParams[nXX,2]))) == "D" // Caso par�metro seja do tipo Data.
						If !Empty(::getvalue(Alltrim(aParams[nXX,2])))
							cFunction += "STOD('" + DtoS(::getvalue(Alltrim(aParams[nXX,2]))) + "')"
						Endif
					ElseIf ValType(::getvalue(Alltrim(aParams[nXX,2]))) == "L" // Caso par�metro seja do tipo L�gico.
						If ::getvalue(Alltrim(aParams[nXX,2])) // Caso valor seja verdadeiro.
							cFunction += ".T."
						Else // Caso valor seja falso.
							cFunction += ".F."
						Endif
					Endif

				Next nXX

				cFunction += ")" // Fecha a formula.
				cValMNTV := &(cFunction) //Executa a o calculo da formula.

				If ValType(cValMNTV) == "C" // Caso resultado seja caracter
					cValMNTV := HTON(cValMNTV)
				Endif

				cCalcForm += Alltrim(Str(cValMNTV))
				cFormula := Substr( cFormula , nPos1+nPos2+1 ) // Adiciona a variavel o conte�do restante da formula.

			Else
				Exit // Termina a montagem da formula.
			Endif
		Else
			cCalcForm += cFormula
			Exit
		EndIf
	End

	If !Empty(cCalcForm)
		cCalcForm := StrTran(cCalcForm, "#" , "" ) // Retira '#' da formula caso ainda possua.
		xResult := &(cCalcForm) // Executa a formula do indicador para obeter o resultado final.

		xResult := fConvertData(xResult,cModule,cIndicator)
	EndIf

Return xResult

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetFormula
Busca a formula cadastrada para o indicador.

@param aFormulas, Array, Cont�m as formulas dos indicadores.
@param cIndicator, Caracter, Nome do indicador que ser� calculado.

@author Guilherme Freudenburg
@since 07/08/2018
@return cFormula, Caracter, Retorna a formula do indicador.
/*/
//------------------------------------------------------------------------------
Static Function fGetFormula(aFormulas,cIndicator)

	Local cFormula := ""
	Local nPos     := 0

	nPos := aScan(aFormulas, {|a| Alltrim(a[PARAM_FIELD]) == AllTrim(cIndicator)}) //Busca a formula do indicador posicionado.

	If nPos > 0 //Caso encontrou a formula.
		cFormula := aFormulas[nPos,2] // Adiciona a formula.
	EndIf

Return cFormula

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetParams
A fun��o � respons�vel por buscar todos os par�metros necess�rios para a vari�vel.

@param cCodVar, Caracter, C�digo da vari�vel de calculo.
@param cModule, Caracter, C�digo do m�dulo do indicador.

@author Guilherme Freudenburg
@since 07/08/2018
@return aParam, Array, Contem todos os par�metros da vari�vel de calculo.
/*/
//------------------------------------------------------------------------------
Static Function fGetParams(cCodVar, cModule)

	Local aParam   := {}
	Local aAreaPar := GetArea() // Salva �rea posicionada.

	dbSelectArea("TZ3")
	dbSetOrder(1)
	If MsSeek(xFilial("TZ3") + cModule + cCodVar) // Busca os par�metros da vari�vel de calculo.
		While !Eof() .And. xFilial("TZ3") + cCodVar == TZ3->TZ3_FILIAL + TZ3->TZ3_CODVAR .And. TZ3->TZ3_MODULO == cModule
			aAdd(aParam, { TZ3->TZ3_ORDEM , TZ3->TZ3_CODPAR})
			TZ3->(dbSkip())
		End
	EndIf

	If Len(aParam) > 0
		aSort(aParam,,, {|x,y| x[1] < y[1]}) // Ordena do menor registro para o maior.
	EndIf

	RestArea(aAreaPar) // Retorna �rea posicionada.

Return aParam

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetAllPar
Lista todos os par�metros necess�rias para executar as f�rmulas do Indicador atual.

@param cIndicator, Caracter, Nome do indicador atual.

@author Wexlei Silveira
@since 15/08/2018
@return aParam, Array, Contem todos os par�metros do Indicador.
/*/
//------------------------------------------------------------------------------
Static Function fGetAllPar(cIndicator)

	Local aParam := {}
	Local aArea  := GetArea()
	Local cAlias := GetNextAlias()

	BeginSql Alias cAlias
		SELECT DISTINCT(TZ3_CODPAR) TZ3_CODPAR FROM %Table:TZ3% TZ3
			WHERE TZ3_CODVAR IN( SELECT TZ6_CODVAR FROM %Table:TZ6% TZ6
				WHERE TZ6.%NotDel% AND
					  TZ6.TZ6_FILIAL = %xFilial:TZ6% AND
					  TZ6.TZ6_CODIND = %exp:cIndicator% ) AND
				TZ3.TZ3_FILIAL = %xFilial:TZ3% AND
				TZ3.%NotDel%
	EndSql

	dbSelectArea(cAlias)
	dbGoTop()
	While (cAlias)->(!Eof())

		aAdd(aParam, (cAlias)->TZ3_CODPAR)

		(cAlias)->(Dbskip())

	EndDo

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return aParam

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetFunction
Busca a fun��o que ser� usada para realizar o c�lculo do Indicador, atrav�s
da vari�vel que ser� enviada pelo parametro da fun��o.

@param cCodVar, Caracter, C�digo da vari�vel de calculo.
@param cModule, Caracter, C�digo do m�dulo do indicador.

@author Guilherme Freudenburg
@since 07/08/2018
@return cFunction, Caracter, Fun��o utilizada para o calculo do indicador.
/*/
//------------------------------------------------------------------------------
Static Function fGetFunction(cCodVar,cModule)

	Local cFunction  := ""
	Local aAreaFun:= GetArea() // Salva �rea posicionada

	dbSelectArea("TZ2")
	dbSetOrder(1)
	If MsSeek(xFilial("TZ2")+cModule+cCodVar) // Posiciona no MNTV
		cFunction := Alltrim(TZ2->TZ2_FUNCAO)+"("
		If TZ2->TZ2_TIPO == "2"
			cFunction := "U_"+cFunction
		Endif
	EndIf

	RestArea(aAreaFun) // Retorna �rea posicionada

Return cFunction

//------------------------------------------------------------------------------
/*/{Protheus.doc} fConvertData
Converte o valor conforme o tipo esperado pelo indicador.

@param xResult, Indefido, Resultado do calculo do indicador.
@param cModule, Caracter, M�dulo respons�vel pelo indicador.
@param cIndicator, Caracter, Indicador que est� sendo calculado.

@author Guilherme Freudenburg
@since 07/08/2018
@return xResult, Indefinido,  Retorna valor do indicador no formato esperado.
/*/
//------------------------------------------------------------------------------
Static Function fConvertData(xResult,cModule,cIndicator)

	Local aAreaCon := GetArea()

	dbSelectArea("TZ5")
	dbSetOrder(1)
	If MsSeek( xFilial("TZ5") + cModule + cIndicator )
		If TZ5->TZ5_TIPVAL == "2" // 2=Hora
			xResult := nToH(xResult)
		Else // sendo numero arredonda de acordo com o escolhido pelo user.
			xResult := Round(xResult, TZ5->TZ5_DECMED)
		EndIf
	Endif

	RestArea(aAreaCon)

Return xResult

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGValFromTo
Efetua valida��o dos campos De At� e verifica se o valor existe na tabela.

@param [cAlias], Caractere, Alias da tabela origem.
@param cFrom, Caractere, Nome do campo De.
@param cTo, Caractere, Nome do campo At�.

@author Wexlei Silveira
@since 14/08/2018
@return cError, Caractere, Mensagem de erro.
/*/
//------------------------------------------------------------------------------
Function NGValFromTo(cAlias, cFrom, cTo)

	Local cError := ""
	Local aArea  := GetArea()

	Default cAlias := ""

	If cTo < cFrom

		cError := STR0010 // "Valor inv�lido para campos De/At�."

	EndIf

	If Empty(cError) .And. !Empty(cAlias) .And. cTo != Replicate('Z',Len(cTo))

		If cAlias == "SRA"

			If !ExCpoMDT(cAlias, cTo)
				cError := STR0011 + cTo + STR0012 + cAlias // "Valor " ### " n�o econtrado na tabela "
			Endif

		Else

			If !ExistCpo(cAlias, cTo)
				cError := STR0011 + cTo + STR0012 + cAlias // "Valor " ### " n�o econtrado na tabela "
			Endif

		Endif

	EndIf

	RestArea(aArea)

Return Empty(cError) // TODO: Remover o Empty

//------------------------------------------------------------------------------------
/*/{Protheus.doc} KPIDateOS
Efetua a montagem da condi��o WHERE, seguindo os cen�rios de data considerada para
consulta de ordens de servi�o no calculo do indicador.
@type function

@author Alexandre Santos
@since 24/06/2020

@sample KPIDateOS( { '01/06/2020', '30/06/2020' }, 3)

@param  aDate, 	Array , Define o DE/ATE data que ser� consultado.
							[1] - Data Inicio
							[2] - Data fim
@param  cStop, 	String, Define se considera Data de manuten��o, parada ou ambos.
							1 - Parada
							2 - Manuten��o
							3 - Ambos
@return Array, 	[1] - Condi��o where para tabela STJ
				[2] - Condi��o where para tabela STS
/*/
//------------------------------------------------------------------------------------
Function KPIDateOS( aDate, cStop )

	Local cWhereTJ := "%"
	Local cWhereTS := "%"
	Local cDateI   := ValToSQL( aDate[1] )
	Local cDateF   := ValToSQL( aDate[2] )

	If cStop != '2' // Parada da O.S. ou Ambos

		cWhereTJ += "AND ( " + IIf( cStop > '2', " ( ", "" )
		cWhereTS += "AND ( " + IIf( cStop > '2', " ( ", "" )

		// Cen�rio 1: Data Parada Real Fim maior que o At�_Data e Data Parada Real Inicio encontra-se dentro do DE/AT�.
		cWhereTJ += " ( TJ_DTPRFIM > " + cDateF + " AND"
		cWhereTJ += " ( TJ_DTPRINI BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "
		cWhereTS += " ( TS_DTPRFIM > " + cDateF + " AND"
		cWhereTS += " ( TS_DTPRINI BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		// Cen�rio 2: Data Parada Real Inicio menor que o De_Data e Data Parada Real Fim encontra-se dentro do DE/AT�.
		cWhereTJ += " ( TJ_DTPRINI < " + cDateI + " AND"
		cWhereTJ += " ( TJ_DTPRFIM BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "
		cWhereTS += " ( TS_DTPRINI < " + cDateI + " AND"
		cWhereTS += " ( TS_DTPRFIM BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		// Cen�rio 3: Data Parada Real Inicio e Fim encontram-se dentro do DE/ATE.
		cWhereTJ += " ( TJ_DTPRINI >= " + cDateI + " AND TJ_DTPRFIM <= " + cDateF + " ) "
		cWhereTS += " ( TS_DTPRINI >= " + cDateI + " AND TS_DTPRFIM <= " + cDateF + " ) "

		cWhereTJ += " ) "
		cWhereTS += " ) "

	EndIf

	If cStop != '1' // Execu��o da O.S. ou Ambos

		cWhereTJ += IIf( cStop > '2', "OR ( ", "AND ( " )
		cWhereTS += IIf( cStop > '2', "OR ( ", "AND ( " )

		// Cen�rio 1: Data Manuten��o Real Fim maior que o At�_Data e Data Manuten��o Real Inicio encontra-se dentro do DE/AT�.
		cWhereTJ += " ( TJ_DTMRFIM > " + cDateF + " AND"
		cWhereTJ += " ( TJ_DTMRINI BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		cWhereTS += " ( TS_DTMRFIM > " + cDateF + " AND"
		cWhereTS += " ( TS_DTMRINI BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		// Cen�rio 2: Data Manuten��o Real Inicio menor que o De_Data e Data Manuten��o Real Fim encontra-se dentro do DE/AT�.
		cWhereTJ += " ( TJ_DTMRINI < " + cDateI + " AND"
		cWhereTJ += " ( TJ_DTMRFIM BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		cWhereTS += " ( TS_DTMRINI < " + cDateI + " AND"
		cWhereTS += " ( TS_DTMRFIM BETWEEN " + cDateI + " AND " + cDateF + " ) ) OR "

		// Cen�rio 3: Data Manuten��o Real Inicio e Fim encontram-se dentro do DE/ATE.
		cWhereTJ += " ( TJ_DTMRINI >= " + cDateI + " AND TJ_DTMRFIM <= " + cDateF + " ) "

		cWhereTS += " ( TS_DTMRINI >= " + cDateI + " AND TS_DTMRFIM <= " + cDateF + " ) "

		cWhereTJ += " ) " + IIf( cStop > '2', " ) ", "" )
		cWhereTS += " ) " + IIf( cStop > '2', " ) ", "" )

	EndIf

	cWhereTJ += "%"
	cWhereTS += "%"

Return { cWhereTJ, cWhereTS }

//------------------------------------------------------------------------------------
/*/{Protheus.doc} KPIDtOSFld
Efetua a montagem dos campos carregador pela consultas, seguindo os cen�rios de data
considerada para calculo do indicador.
@type function

@author Alexandre Santos
@since 24/06/2020

@sample KPIDtOSFld( { '01/06/2020', '30/06/2020' }, 3)

@param  aDate, 	Array , Define o DE/ATE data que ser� consultado.
							[1] - Data Inicio
							[2] - Data fim
@param  cStop, 	String, Define se considera Data de manuten��o, parada ou ambos.
							1 - Parada
							2 - Manuten��o
							3 - Ambos
@return Array, 	[1] - Campos para tabela STJ
				[2] - Campos para tabela STS
/*/
//------------------------------------------------------------------------------------
Function KPIDtOSFld( aDate, cStop )

	Local cFieldTJ := "%"
	Local cFieldTS := "%"
	Local cDateI   := ValToSQL( aDate[1] )
	Local cDateF   := ValToSQL( aDate[2] )
	Local cHourI   := ValToSQL( '00:00' )
	Local cHourF   := ValToSQL( '23:59' )

	Do Case

		Case cStop == '3' // Parada da O.S. priorizado, caso n�o possua, utiliza-se Execu��o da O.S.

			// Data Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRINI <> ' ' THEN "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTPRINI < " + cDateI + " THEN " + cDateI
			cFieldTJ += 			" ELSE STJ.TJ_DTPRINI "
			cFieldTJ += 		" END "
			cFieldTJ += " ELSE "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTMRINI < " + cDateI + " THEN " + cDateI
			cFieldTJ += 			" ELSE STJ.TJ_DTMRINI "
			cFieldTJ += 		" END "
			cFieldTJ += " END AS IS_DATAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRINI <> ' ' THEN "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTPRINI < " + cDateI + " THEN " + cDateI
			cFieldTS += 			" ELSE STS.TS_DTPRINI "
			cFieldTS += 		" END "
			cFieldTS += " ELSE "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTMRINI < " + cDateI + " THEN " + cDateI
			cFieldTS += 			" ELSE STS.TS_DTMRINI "
			cFieldTS += 		" END "
			cFieldTS += " END AS IS_DATAINI, "

			// Hora Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN ( STJ.TJ_HOPRINI <> ' ' AND LTRIM( RTRIM( STJ.TJ_HOPRINI ) ) <> ':' ) THEN "
    		cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTPRINI < " + cDateI + " THEN " + cHourI
			cFieldTJ += 			" ELSE STJ.TJ_HOPRINI "
			cFieldTJ += 		" END "
			cFieldTJ += 	" ELSE "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTMRINI < " + cDateI + " THEN " + cHourI
			cFieldTJ += 			" ELSE STJ.TJ_HOMRINI "
			cFieldTJ += 		" END "
			cFieldTJ += " END AS IS_HORAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN ( STS.TS_HOPRINI <> ' ' AND LTRIM( RTRIM( STS.TS_HOPRINI ) ) <> ':' ) THEN "
    		cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTPRINI < " + cDateI + " THEN " + cHourI
			cFieldTS += 			" ELSE STS.TS_HOPRINI "
			cFieldTS += 		" END "
			cFieldTS += 	" ELSE "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTMRINI < " + cDateI + " THEN " + cHourI
			cFieldTS += 			" ELSE STS.TS_HOMRINI "
			cFieldTS += 		" END "
			cFieldTS += " END AS IS_HORAINI, "

			// Data Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRFIM <> ' ' THEN "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTPRFIM > " + cDateF + " THEN " + cDateF
			cFieldTJ += 			" ELSE STJ.TJ_DTPRFIM "
			cFieldTJ += 		" END "
			cFieldTJ += " ELSE "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTMRFIM > " + cDateF + " THEN " + cDateF
			cFieldTJ += 			" ELSE STJ.TJ_DTMRFIM "
			cFieldTJ += 		" END "
			cFieldTJ += " END AS IS_DATAFIM, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRFIM <> ' ' THEN "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTPRFIM > " + cDateF + " THEN " + cDateF
			cFieldTS += 			" ELSE STS.TS_DTPRFIM "
			cFieldTS += 		" END "
			cFieldTS += " ELSE "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTMRFIM > " + cDateF + " THEN " + cDateF
			cFieldTS += 			" ELSE STS.TS_DTMRFIM "
			cFieldTS += 		" END "
			cFieldTS += " END AS IS_DATAFIM, "

			// Hora Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN ( STJ.TJ_HOPRFIM <> ' ' AND LTRIM( RTRIM( STJ.TJ_HOPRFIM ) ) <> ':' ) THEN "
    		cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTPRFIM > " + cDateF + " THEN " + cHourF
			cFieldTJ += 			" ELSE STJ.TJ_HOPRFIM "
			cFieldTJ += 		" END "
			cFieldTJ += 	" ELSE "
			cFieldTJ += 		" CASE"
			cFieldTJ += 			" WHEN STJ.TJ_DTMRFIM > " + cDateF + " THEN " + cHourF
			cFieldTJ += 			" ELSE STJ.TJ_HOMRFIM "
			cFieldTJ += 		" END "
			cFieldTJ += " END AS IS_HORAFIM "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN ( STS.TS_HOPRFIM <> ' ' AND LTRIM( RTRIM( STS.TS_HOPRFIM ) ) <> ':' ) THEN "
    		cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTPRFIM > " + cDateF + " THEN " + cHourF
			cFieldTS += 			" ELSE STS.TS_HOPRFIM "
			cFieldTS += 		" END "
			cFieldTS += 	" ELSE "
			cFieldTS += 		" CASE"
			cFieldTS += 			" WHEN STS.TS_DTMRFIM > " + cDateF + " THEN " + cHourF
			cFieldTS += 			" ELSE STS.TS_HOMRFIM "
			cFieldTS += 		" END "
			cFieldTS += " END AS IS_HORAFIM "

		Case cStop == '2' // Considera apenas a Execu��o da O.S.

			// Data Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTMRINI < " + cDateI + " THEN " + cDateI
			cFieldTJ += 	" ELSE STJ.TJ_DTMRINI "
			cFieldTJ += " END AS IS_DATAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTMRINI < " + cDateI + " THEN " + cDateI
			cFieldTS += 	" ELSE STS.TS_DTMRINI "
			cFieldTS += " END AS IS_DATAINI, "

			// Hora Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTMRINI < " + cDateI + " THEN " + cHourI
			cFieldTJ += 	" ELSE STJ.TJ_HOMRINI "
			cFieldTJ += " END IS_HORAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTMRINI < " + cDateI + " THEN " + cHourI
			cFieldTS += 	" ELSE STS.TS_HOMRINI "
			cFieldTS += " END IS_HORAINI, "

			// Data Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTMRFIM > " + cDateF + " THEN " + cDateF
			cFieldTJ += 	" ELSE STJ.TJ_DTMRFIM "
			cFieldTJ += " END AS IS_DATAFIM, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTMRFIM > " + cDateF + " THEN " + cDateF
			cFieldTS += 	" ELSE STS.TS_DTMRFIM "
			cFieldTS += " END AS IS_DATAFIM, "

			// Hora Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTMRFIM > " + cDateF + " THEN " + cHourF
			cFieldTJ += 	" ELSE STJ.TJ_HOMRFIM "
			cFieldTJ += " END IS_HORAFIM "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTMRFIM > " + cDateF + " THEN " + cHourF
			cFieldTS += 	" ELSE STS.TS_HOMRFIM "
			cFieldTS += " END IS_HORAFIM "

		Case cStop == '1' // Considera apenas a Parada da O.S.

			// Data Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRINI < " + cDateI + " THEN " + cDateI
			cFieldTJ += 	" ELSE STJ.TJ_DTPRINI "
			cFieldTJ += " END AS IS_DATAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRINI < " + cDateI + " THEN " + cDateI
			cFieldTS += 	" ELSE STS.TS_DTPRINI "
			cFieldTS += " END AS IS_DATAINI, "

			// Hora Inicio
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRINI < " + cDateI + " THEN " + cHourI
			cFieldTJ += 	" ELSE STJ.TJ_HOPRINI "
			cFieldTJ += " END IS_HORAINI, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRINI < " + cDateI + " THEN " + cHourI
			cFieldTS += 	" ELSE STS.TS_HOPRINI "
			cFieldTS += " END IS_HORAINI, "

			// Data Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRFIM > " + cDateF + " THEN " + cDateF
			cFieldTJ += 	" ELSE STJ.TJ_DTPRFIM "
			cFieldTJ += " END AS IS_DATAFIM, "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRFIM > " + cDateF + " THEN " + cDateF
			cFieldTS += 	" ELSE STS.TS_DTPRFIM "
			cFieldTS += " END AS IS_DATAFIM, "

			// Hora Fim
			cFieldTJ += " CASE"
			cFieldTJ += 	" WHEN STJ.TJ_DTPRFIM > " + cDateF + " THEN " + cHourF
			cFieldTJ += 	" ELSE STJ.TJ_HOPRFIM "
			cFieldTJ += " END IS_HORAFIM "
			cFieldTS += " CASE"
			cFieldTS += 	" WHEN STS.TS_DTPRFIM > " + cDateF + " THEN " + cHourF
			cFieldTS += 	" ELSE STS.TS_HOPRFIM "
			cFieldTS += " END IS_HORAFIM "

	End Case

	cFieldTJ += "%"
	cFieldTS += "%"

Return { cFieldTJ, cFieldTS }
