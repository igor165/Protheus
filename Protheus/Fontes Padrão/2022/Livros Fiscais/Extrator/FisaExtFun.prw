#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "Fileio.ch"

Static oFisaExtSx := Nil

Static __cString	:= ''

Static lJob := IsBlind()

/*/{Protheus.doc} FisaExtX01
Fun��o para executar a fun��o cGetFile pela consulta padr�o.

@author Vitor Ribeiro719
@since 05/02/2018

@param c_Mascara, caracter, Indica o nome do arquivo ou m�scara.
@param c_Titulo, caracter, Indica o t�tulo da janela.
@param n_Opcoes, numerico, Indica a op��o de funcionamento.
@param l_Salvar, logico, Indica se � um "save dialog" ou um "open dialog".
@param l_Arvore, logico, Indica se, verdadeiro (.T.), apresenta o �rvore do servidor; caso contr�rio, falso (.F.).

@return caracter, retorna o diretorio selecionado.
/*/

Function FisaExtX01(c_Mascara,c_Titulo,n_Opcoes,l_Salvar,l_Arvore)
	
	Local cDiretorio	:= ""
	
	Default c_Mascara	:= "Arquivos Texto (*.TXT) |*.txt"
	Default c_Titulo	:= "Selecione o local para salvar..."
	
	Default n_Opcoes	:= GetOpcoes()
	
	Default l_Salvar	:= .F.
	Default l_Arvore	:= .F.
	
	// cGetFile(cMascara,cTitulo,nMascpadrao,cDirinicial,lSalvar,nOpcoes,lArvore,lKeepCase)
	cDiretorio := AllTrim(cGetFile(c_Mascara,c_Titulo,,,l_Salvar,n_Opcoes,l_Arvore,))
	
Return cDiretorio

/*/{Protheus.doc} GetOpcoes
Fun��o para retornar as op��es para a fun��o cGetFile. 

@author Vitor Ribeiro
@since 05/02/2018

@return numeico, retorna as op��es GETF_LOCALFLOPPY (8), GETF_LOCALHARD (16), GETF_RETDIRECTORY (128).
/*/

Static Function GetOpcoes()
	
	Local nOpcoes := 0
	
	// GETF_LOCALFLOPPY (8) - Apresenta a unidade do disquete da m�quina local.
	nOpcoes += GETF_LOCALFLOPPY
	
	// GETF_LOCALHARD (16) - Apresenta a unidade do disco local.
	nOpcoes += GETF_LOCALHARD
	
	// GETF_RETDIRECTORY (128) - Retorna/apresenta um diret�rio.
	nOpcoes += GETF_RETDIRECTORY

Return nOpcoes

/*/{Protheus.doc} FisaExtX02
	(Fun��o para instanciar objeto FisaExtSx)

	@type Function
	@author Vitor Ribeiro
	@since 06/12/2017

	@Return oFisaExtSx, objeto, instancia do FisaExtSx.
	/*/
Function FisaExtX02()

	If ValType(oFisaExtSx) == "U"
		oFisaExtSx := FisaExtSx_Class():New()
	EndIf

Return oFisaExtSx

/*/{Protheus.doc} FisaExtX04
	(Fun��o para montar uma browser com mark.)

	@type Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param c_Titulo, caracter, titulo do browser
    @param a_Header, array, cabe�alho do browser
    @param a_Cols, array, itens do browser
    @param a_Retorno, array, array com os campos do cabe�alho que devem ser retornados
    @param l_JustOne, logico, se deve marcar somente um item

	@return aRetorno, array, retorna os dados selecionados no mark browser
	/*/
Function FisaExtX04(c_Titulo,a_Header,a_Cols,a_Retorno,l_JustOne)

	Local aRetorno := {}
	
	Private nPosMark := 0
	
	Default c_Titulo := "Teste"
	
	Default a_Header := {}
	Default a_Cols := {}
	Default a_Retorno := {}
	
	Default l_JustOne := .F.
	
	If !Empty(a_Header) .And. !Empty(a_Cols) .And. !Empty(a_Retorno)
		// Inclui a coluna do mark
		Aeval(a_Cols,{|x| Aadd(x,"LBNO")})
		
		nPosMark := Len(a_Cols[1])
		
		// Monta a tela
		aRetorno := fMakeTela(c_Titulo,a_Header,a_Cols,a_Retorno,l_JustOne)
	EndIf
	
Return aRetorno

/*/{Protheus.doc} fMakeTela
    (Fun��o para montar uma browser com mark.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param c_Titulo, caracter, titulo do browser
    @param a_Header, array, cabe�alho do browser
    @param a_Cols, array, itens do browser
    @param a_Retorno, array, array com os campos do cabe�alho que devem ser retornados
    @param l_JustOne, logico, se deve marcar somente um item

	@return aRetorno, array, retorna os dados selecionados no mark browser
    /*/
Static Function fMakeTela(c_Titulo,a_Header,a_Cols,a_Retorno,l_JustOne)

	Local aCoors := {}
	Local aRetorno := {}
	
	Local bConfirma := {|| aRetorno := fConfirma(a_Header,a_Retorno),oDialog:End() }
	Local bCancela := {|| aRetorno := {}, oDialog:End() }
	
	Local oDialog := Nil
	
	Private aCols := {}
	
	Private oBrowse := Nil

	Default c_Titulo := ""
	
	Default a_Header := {}
	Default a_Cols := {}
	Default a_Retorno := {}
	
	Default l_JustOne := .F.
	
	aCols := a_Cols

	aCoors := FWGetDialogSize()

	Define MsDialog oDialog From aCoors[1],aCoors[2] To aCoors[3]/2+50,aCoors[4]/2 Pixel Title c_Titulo

		//Criacao do browse com as al�adas
		oBrowse := FWFormBrowse():New()
		oBrowse:DisableDetails()
		oBrowse:SetOwner(oDialog)
		oBrowse:SetDescription("Selecione")
		oBrowse:AddMarkColumns( {|| aCols[oBrowse:At()][nPosMark] },{|| fMarkOne(oBrowse,l_JustOne) },{|| fMarkAll(oBrowse) })
		oBrowse:SetDataArray()		// Define que a utilizacao <E9> por array
		oBrowse:SetArray(aCols)
		oBrowse:SetColumns(DataTelas(a_Header))
		oBrowse:SetMenuDef("FISAEXTX04")
		oBrowse:DisableReport()
		oBrowse:DisableConfig()
		oBrowse:Activate()

	Activate MsDialog oDialog On Init EnchoiceBar(oDialog,bConfirma,bCancela,,{}) Centered
	
Return aRetorno

/*/{Protheus.doc} DataTelas
    (Fun��o para adicionar uma coluna no Browse em tempo de execu��o. )

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param a_Campos, array, campos que ser�o utilizados nas browser.

    @return array, multidimensional contendo objetos da FWBrwColumn.
    /*/
Static Function DataTelas(a_Campos)

	Local nCount := 0
	
	Local oColuna := Nil

	Local aColumns := {}

	Default a_Campos := {}	
	
	If !Empty(a_Campos)
		SX3->(DbSetOrder(2))	// X3_CAMPO
	
		For nCount := 1 To Len(a_Campos)
			If SX3->(DbSeek(a_Campos[nCount][1])) .And. Empty(a_Campos[nCount][2])
				SetPrvt(AllTrim(SX3->X3_CAMPO))
				
				oColuna := FWBrwColumn():New()				// Cria objeto
				oColuna:SetEdit(.F.)       				// Indica se <E9> editavel
				oColuna:SetTitle(SX3->X3_TITULO)			// Define titulo
				oColuna:SetType(SX3->X3_TIPO)				// Define tipo
				oColuna:SetSize(SX3->X3_TAMANHO)			// Define tamanho
				oColuna:SetPicture(SX3->X3_PICTURE)		// Define picture
				oColuna:SetAlign(AlignTipo(SX3->X3_TIPO))// Define alinhamento				
				oColuna:SetData(&( "{|| aCols[oBrowse:At()][" + Alltrim(Str(nCount)) + "] }" ))
				
				Aadd(aColumns,oColuna)
			Else
				SetPrvt(AllTrim(a_Campos[nCount][1]))
				
				oColuna := FWBrwColumn():New()							// Cria objeto
				oColuna:SetEdit(.F.)       							// Indica se <E9> editavel
				oColuna:SetTitle(a_Campos[nCount][2][1])				// Define titulo
				oColuna:SetType(a_Campos[nCount][2][2])				// Define tipo
				oColuna:SetSize(a_Campos[nCount][2][3])				// Define tamanho
				oColuna:SetPicture(a_Campos[nCount][2][4])			// Define picture
				oColuna:SetAlign(AlignTipo(a_Campos[nCount][2][2]))	// Define alinhamento				
				oColuna:SetData(&( "{|| aCols[oBrowse:At()][" + Alltrim(Str(nCount)) + "] }" ))
				
				Aadd(aColumns,oColuna)
			EndIf
		Next nCount
	EndIf

Return aColumns

/*/{Protheus.doc} AlignTipo
    (Fun��o para retornar o alinhamento de campos conforme seu tipo. )

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param c_Tipo, caracter, tipo do campo.

    @return caracter, contem o alinhamento.
    /*/
Static Function AlignTipo(c_Tipo)

	Local cAlign := ""
	
	Default c_Tipo := ""

	If c_Tipo == "N"
		cAlign := "RIGHT"
	ElseIf c_Tipo == "D"
		cAlign := "CENTER"
	Else
		cAlign := "LEFT"
	EndIf
	
Return cAlign

/*/{Protheus.doc} fMarkOne
    (Fun��o para marcar um registro.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param o_Objeto, caracter, contem o objeto da browse.

    @return Nil, nulo, n�o tem retorno
    /*/

Static Function fMarkOne(o_Objeto,l_JustOne)

	Local cMark := ""

	Default l_JustOne := .F.

	If aCols[o_Objeto:At()][nPosMark] == "LBNO"
		cMark := "LBOK"
	Else
		cMark := "LBNO"
	EndIf
	
	If l_JustOne
		fMarkAll(o_Objeto,.F.)
		o_Objeto:Refresh()
	EndIf
	
	aCols[o_Objeto:At()][nPosMark] := cMark

Return Nil

/*/{Protheus.doc} fMarkAll
    (Fun��o para marcar todos os registros.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param o_Objeto, caracter, contem o objeto da browse.

    @return Nil, nulo, n�o tem retorno
    /*/
Static Function fMarkAll(o_Objeto,l_MarkAll)

	Local nCount := 0
	
	Local lGoTop := .F.
	
	If ValType(l_MarkAll) <> "L"
		l_MarkAll := Ascan(aCols,{|x| AllTrim(x[nPosMark]) == "LBNO" }) > 0
		lGoTop := .T.
	EndIf

	For nCount := 1 To Len(aCols)
		If l_MarkAll
			aCols[nCount][nPosMark] := "LBOK"
		Else
			aCols[nCount][nPosMark] := "LBNO"
		EndIf
	Next
	
	If lGoTop
		o_Objeto:GoTop(.T.)
	EndIf

Return Nil

/*/{Protheus.doc} fConfirma
    (Fun��o executada na confirma��o da tela.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @param a_Header, array, cabe�alho do browser
    @param a_Retorno, array, array com os campos do cabe�alho que devem ser retornados

    @return aRetorno, array, retorna os dados selecionados no mark browser
    /*/
Static Function fConfirma(a_Header,a_Retorno)

	Local nCount1 := 0
	Local nCount2 := 0
	
	Local nPosicao := 0
	
	Local aRetorno := {}
	
	For nCount1 := 1 To Len(aCols)
		If aCols[nCount1][nPosMark] == "LBOK"
			
			Aadd(aRetorno,{})
			
			For nCount2 := 1 To Len(a_Retorno)
				nPosicao := Ascan(a_Header,{|x| AllTrim(x[1]) == a_Retorno[nCount2] })
				
				If nPosicao > 0
					Aadd(aRetorno[Len(aRetorno)],aCols[nCount1][nPosicao])
				EndIf
			Next
		EndIf
	Next
	
Return aRetorno

/*/{Protheus.doc} FisaExtX05
	(Fun��o para montar a tela de pesquisa das especies)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @return cRetorno, caracter, cont�m a informa��o selecionada separada por ponto e virgula
	/*/
Function FisaExtX05()

	Local aDados := {}
	Local aSelecao := {}
	
	Local cRetorno := ""
	
	// Fun��o para buscar as especies.
	aDados := QryEspecie()
	
	// Fun��o para montar a tela para sele��o.
	// FisaExtX04(c_Titulo,a_Header,a_Cols,a_Retorno)
	aSelecao := FisaExtX04("Especies",{{"X5_CHAVE",},{"X5_DESCRI",}},aDados,{"X5_CHAVE"})
	
	Aeval(aSelecao,{|x| IIf(!Empty(cRetorno),cRetorno += ";",), cRetorno += AllTrim(x[1]) })
	
Return cRetorno

/*/{Protheus.doc} QryEspecie
    (Fun��o para buscar as especie da nota)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/06/2018

    @return aDados, array, retorna as especies cadastradas.
    /*/
Static Function QryEspecie()

	Local cAlias := ""
	
	cAlias := GetNextAlias()
	
	BeginSQL Alias cAlias
        SELECT
            SX5.X5_CHAVE
			,SX5.X5_DESCRI
        FROM %Table:SX5% SX5
		
        WHERE
			SX5.%NotDel%
			AND SX5.X5_FILIAL = %xFilial:SX5%
			AND SX5.X5_TABELA = '42'

		ORDER BY
            SX5.X5_CHAVE
	EndSQL

	// Fun��o para retornar um query em um array. 
	// FisaExtX06(c_Query,c_AliasQry,l_RetCabec,l_TrataRes,a_TrataRes)
	aDados := FisaExtX06(,cAlias,,.T.)
	
	(cAlias)->(DbCloseArea())
	
Return aDados

/*/{Protheus.doc} FisaExtX06
    (Fun��o para ler um query ou um alias e retorna-la em um array.)

    @author Vitor Ribeiro
    @since 05/06/2018

    @param c_Query, caracter, contem a query que ser� lida.
    @param c_AliasQry, caracter, contem o alias da query para ser lida.
    @param l_RetCabec, logico, se ir� retornar o cabe�alho da query
    @param l_TrataRes, logico, se ir� tratar o retorno da query com o tcsetfield conforme o campo no SX3 ou o array a_TrataRes.
    @param a_TrataRes, array, contem as informa��es para o tratamento do campo no tcsetfield.

    @obs Para que a fun��o funcione � necessario ou o primeiro parametro(c_Query) ou o segundo(c_AliasQry). Se forem passados os dois, o programa ir� assumir a query e n�o o alias.

    @return array, retorna os resultados da query.
    /*/
Function FisaExtX06(c_Query,c_AliasQry,l_RetCabec,l_TrataRes,a_TrataRes)

	Local nCount := 0
	Local nPosic := 0

	Local cAlias := ""

	Local aLinha := {}
	Local aDados := {}
	Local aEstou := {}
	Local aArSx3 := {}

	Default c_Query := ""
	Default c_AliasQry := ""

	Default l_RetCabec := .F.
	Default l_TrataRes := .F.

	Default a_TrataRes := {}

	aArSx3 := SX3->(GetArea())

	SX3->(DbSetOrder(2)) // X3_CAMPO

	// Se foi passado um alias, passa para variavel principal.
	If !Empty(c_AliasQry)
		cAlias := c_AliasQry
	EndIf

	// Se o foi passado um query ou um alias, continua.
	If !Empty(c_Query) .Or. !Empty(cAlias)
		aEstou := GetArea()

		// Se foi passado por query, executa.
		If !Empty(c_Query)
			// Se foi passado algum alias junto com a query fecha ele primeiro.
			If !Empty(cAlias) .And. Select(cAlias) > 0
				(cAlias)->(DbCloseArea())
			EndIf
			// Pega um alias pra tabela temporaria contendo a query
			cAlias := GetNextAlias()

			// Executa a query
			TCQUERY c_Query NEW ALIAS (cAlias)
		EndIf

		// Vai para o primeiro registro
		(cAlias)->(DbGoTop())

		// Trata o resultado da query
		If l_TrataRes
			For nCount := 1 to (cAlias)->(fCount())
				nPosic := aScan(a_TrataRes,{|x| AllTrim(Upper(x[1])) == AllTrim(Upper((cAlias)->(Field(nCount)))) })

				If nPosic > 0 .And. Len(a_TrataRes[nPosic]) == 4
					TCSetField(cAlias,a_TrataRes[nPosic][1],a_TrataRes[nPosic][2],a_TrataRes[nPosic][3],a_TrataRes[nPosic][4])
				ElseIf SX3->(DbSeek((cAlias)->(Field(nCount))))
					TCSetField(cAlias,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)
				EndIf
			Next
		EndIf

		// Vai para o primeiro registro
		(cAlias)->(DbGoTop())

		// Se a query retornou valor
		If (cAlias)->(!Eof())
			// Cria o array com as colunas da query
			aLinha := Array((cAlias)->(fCount()))

			// Retorna o cabecalho da query
			If l_RetCabec
				For nCount := 1 to (cAlias)->(fCount())
					aLinha[nCount] := (cAlias)->(Field(nCount))
				Next

				Aadd(aDados,aclone(aLinha))
			EndIf

			// Preenche o array com os valores
			While (cAlias)->(!Eof())
				// Preenche as colunas da linha
				For nCount := 1 to (cAlias)->(fCount())
					aLinha[nCount] := (cAlias)->(FieldGet(nCount))
				Next

				// Preenche o array com os dados da query
				Aadd(aDados,aclone(aLinha))

				(cAlias)->(DbSkip())
			Enddo
		EndIf

		// Se foi passado por query, fecha o alias.
		If !Empty(c_Query)
			// Fecha a tabela temporaria
			(cAlias)->(DbCloseArea())
		EndIf

		// Restaura a area que estava.
		RestArea(aEstou)
	EndIf

	// Restaura a area do SX3.
	RestArea(aArSx3)

Return aDados

/*/{Protheus.doc} FisaExtX07
	(Funcao responsavel pela gravacao das informacoes)

	@type Function
	@author Vitor Ribeiro
	@since 04/07/2018

	@param nHandle, numerico, handle do arquivo txt
	@param cString, caracter, terxto a ser gravado

	@return nRet, numerico, erro gerado pelo FWrite
	/*/
Function FisaExtX07(nHandle,cString)

	Local nRet := 0

	Default nHandle := 0

	Default cString := Nil

	If cString <> Nil .And. !Empty(cString)
		__cString	+=	cString 
		if len(__cString) >= 800 //Kb
			nRet := FWrite(nHandle,__cString,Len(__cString))
			__cString	:=	''

			//Se houver erro na gravacao, nao limpo a variavel
			If nRet <> -1
				cString := ""
			EndIf

		EndIf  
	EndIf   

Return nRet

/*/{Protheus.doc} FisaExtF07
(Funcao responsavel pela gravacao das informacoes)

@type Function
@author Ivan Pinheiro/ Henrique Pereira
@since 01/10/2019

@param nHandle, numerico, handle do arquivo txt
@param cString, caracter, terxto a ser gravado

@return nRet, numerico, erro gerado pelo FWrite
/*/
Function FisaExtF07(nHandle)

	Local nRet := 0

	Default nHandle := 0
  
	nRet := FWrite(nHandle,__cString,Len(__cString))

	__cString	:=	''

Return nRet