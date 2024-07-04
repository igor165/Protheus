#Include "Protheus.ch"
#Include "MNTSTEP.ch"

#Define _OS_ 1 
#Define _SS_ 2

Function _MNTStep()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTStep
Classe de Etapas de Ordem de Servi�o

@author Douglas Constancio
@author Maria Elisandra de Paula
@since 02/03/2018
/*/
//------------------------------------------------------------------------------
Class MNTStep From NGGenerico

	Method new() Constructor

	// Metodos Publicos
	Method validBusiness()
	Method upsert()
	Method delete()
	Method getResultList()

	// Metodos Privados
	Method isAccomplished()
	Method isForeseen()
	Method isExclusive()
	Method isMultiple()
	Method isPreventive()
	Method isCorrective()
	Method hasServOrder()
	Method hasServRequest()
	Method hasOption()
	Method hasGrid()
	Method hasAnswer()
	Method isInfoAnswer()
	Method isMarkAnswer()
	Method isCreateSO()
	Method isCreateSS()

	// Atributos Privados
	Data aResult as Array Init {}

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe

@author Douglas Constancio
@since 02/03/2018
@return objeto, self criado
/*/
//------------------------------------------------------------------------------
Method new() Class MNTStep

	Local aRelatiTPQ := {}

	_Super:new()

	//Etapas da O.S.
	::setAlias("STQ")

	//Opcoes da Etapa da O.S.
	::setAliasGrid("TPQ")

	// Carrega os campos da estrutura.
	::initFields(.T.)

	// Tipo da Validacao - Business
	::setValidationType("BU")

	// Campos da chave unica da tabela nao alteraveis
	::setUniqueField("TQ_FILIAL")
	::setUniqueField("TQ_ORDEM" )
	::setUniqueField("TQ_PLANO" )

	// Etapas x Respostas
	aAdd(aRelatiTPQ, {"TPQ_FILIAL", "xFilial('TPQ')"})
	aAdd(aRelatiTPQ, {"TPQ_ORDEM" , "TQ_ORDEM" })
	aAdd(aRelatiTPQ, {"TPQ_PLANO" , "TQ_PLANO" })
	aAdd(aRelatiTPQ, {"TPQ_TAREFA", "TQ_TAREFA"})
	aAdd(aRelatiTPQ, {"TPQ_ETAPA" , "TQ_ETAPA" })

    ::oStruct:setRelation("TPQ", aRelatiTPQ)

	// Garante que o atributo esteja vazio na constru��o
	::aResult := {{},{}}

	// Nome da Classe
	::cClassName := "MNTStep"

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
M�todo que realiza a valida��o da regra de neg�cio da classe.

@author Douglas Constancio
@since 02/03/2018
@return l�gico, se valida��o est� ok
/*/
//------------------------------------------------------------------------------
Method validBusiness() Class MNTStep

	Local aArea      := GetArea()
	Local cError     := ""
	Local lTarGe     := AllTrim(SuperGetMV("MV_NGTARGE", .F., "2")) == "1"
	Local aReturn    := {}
	Local cOption    := ""
	Local cOrderG    := ""
	Local cAnswer    := ""
	Local cService   := ""
	Local cCodAsset  := ""
	Local nOption    := 0
	Local nOrderG    := 0
	Local nAnswer    := 0
	Local aHeaderAux := {}
	Local aColsAux   := {}
	Local nLine      := 0
	Local nLenAux    := 0
	Local aSequence  := {}
	Local cSequence  := ""
	Local cStep      := ::getValue("TQ_ETAPA")
	Local lMntStep   := ExistBlock("MNTSTEP")

	//TODO: Remover a variavel lParent quando classe de etapa deixar de ser orf� no mobile
	Local lParent := ValType( ::getParent() ) == "O" // Indica se objeto pai foi instanciado

	If ::isValid() .And. ::isUpsert()

		//+-------------------------------------------------------------------
		// 1.0 - O campo Ordem (TQ_ORDEM) deve estar preenchido.
		//+-------------------------------------------------------------------
		If Empty(::getValue("TQ_ORDEM"))
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_ORDEM") + Space(1) + STR0002//"O campo"#"deve estar preenchido."
		EndIf

		//+-------------------------------------------------------------------
		// 2.0 - O campo Ordem (TQ_ORDEM) deve ser o mesmo da TJ_ORDEM.
		//+-------------------------------------------------------------------
		If Empty(cError) .And. lParent .And. ::getValue("TQ_ORDEM") != ::getParent():getValue("TJ_ORDEM")
			//"O campo"#"deve estar preenchido corretamente de acordo com a Ordem de Servi�o que a Etapa pertence."
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_ORDEM") + Space(1) + STR0003
		EndIf

		//+-------------------------------------------------------------------
		// 3.0 - O campo Plano (TQ_PLANO) deve estar preenchido.
		//+-------------------------------------------------------------------
		If Empty(cError) .And. Empty(::getValue("TQ_PLANO"))
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_PLANO") + STR0002//"O campo"#"deve estar preenchido."
		EndIf

		//+-------------------------------------------------------------------
		// 4.0 - O campo Ordem (TQ_PLANO) deve ser o mesmo da TJ_PLANO.
		//+-------------------------------------------------------------------
		If  Empty(cError) .And. lParent .And. ::getValue("TQ_PLANO") != ::getParent():getValue("TJ_PLANO")
			//"O campo"#"deve estar preenchido corretamente de acordo com a ordem de servi�o que a etapa pertence."
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_PLANO") + Space(1) + STR0003
		EndIf

		//+------------------------------------------------------------------------
		// 5.0 - O c�digo da tarefa deve existir na tabela TT9 Tarefas Gen�ricas.
		//+------------------------------------------------------------------------
		If Empty(cError) .And. (::isCorrective() .And. lTarGe) .And. !NGIFDBSEEK("TT9", ::getValue("TQ_TAREFA"), 1)
			cError := STR0004//"A Tarefa n�o existe ou n�o pertence � tabela TT9 - Tarefas Gen�ricas."
		EndIf

		//+------------------------------------------------------------------------
		// 6.0 - O c�digo da Etapa deve existir na tabela TPA Etapas Gen�ricas.
		//+------------------------------------------------------------------------
		If Empty(cError) .And. !NGIFDBSEEK("TPA", cStep, 1)
			cError := STR0005//"A Etapa n�o existe ou pertence � tabela TPA - Etapas Gen�ricas."
		EndIf

		//+-------------------------------------------------------------------
		// 7.0 - Se OS for Preventiva, a Tarefa deve estar preenchida
		// com um c�digo existente na tabela ST5 - Tarefas da Manuten��o.
		//+-------------------------------------------------------------------
		If Empty(cError) .And. ::isPreventive() .And. Alltrim(::getValue("TQ_TAREFA")) <> "0" .And.;
		!NGIFDBSEEK("ST5", ::getValue("TQ_TAREFA"), 5)
			cError := STR0006//"A Tarefa n�o existe ou pertence � tabela ST5 - Tarefas da Manuten��o."
		EndIf

		//+--------------------------------------------------------------------------
		// 8.0 - Se Tarefa estiver preenchida, Etapa se torna obrigat�ria.
		//+--------------------------------------------------------------------------
		If Empty(cError) .And. ((lTarGe .And. ::isCorrective()) .Or. ::isPreventive()) .And.;
		!Empty(::getValue("TQ_TAREFA")) .And. Empty( cStep )
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_ETAPA") + STR0002//"O campo"#"deve estar preenchido."
		EndIf

		//+---------------------------------------------------------------------------
		//  9.0 - Se Etapa estiver preenchida, Tarefa se torna obrigat�ria.
		//+---------------------------------------------------------------------------
		If Empty(cError) .And. ((lTarGe .And. ::isCorrective()) .Or. ::isPreventive()) .And.;
		!Empty( cStep ) .And. Empty(::getValue("TQ_TAREFA"))
			cError := STR0001 + Space(1) + NgRetTitulo("TQ_TAREFA") + STR0002//"O campo"#"deve estar preenchido."
		EndIf

		//+---------------------------------------------------------------------------
		//  10.0 - Verifica chave unica da tabela
		//+---------------------------------------------------------------------------
		If NGIFDBSEEK("STQ", ::getValue("TQ_ORDEM") + ::getValue("TQ_PLANO") +;
		::getValue("TQ_TAREFA") + cStep + ::getValue("TQ_SEQTARE") , 1) .And. ;
		::oStruct:aRecno[1,2] != STQ->(Recno())
			cError := STR0007//"Chave do registro ja existe na base de dados."
		EndIf

	EndIf

	// Regras de Altera��o/ Exclus�o
	If Empty(cError) .And. ::isAccomplished() .And. (::isDelete() .Or. ::isUpdate())

		//+--------------------------------------------------------------------------------
		// 11.0 - Verifica a exitencia de O.S. para a etapa a ser desmarcada ou excluida
		//+--------------------------------------------------------------------------------
		aReturn := ::hasServOrder()

		If aReturn[1]
			cError := STR0008 + Space(1)  //"N�o ser� poss�vel"  
			cError += IIf(::isDelete() , STR0009, STR0046 ) + Space(1)//"excluir"#"alterar" 
			cError += STR0011 + Space(1) + STR0012 + Space(1) //#"a Etapa pois h�"#"Ordem(s) de Servi�o gerada(s)" 
			cError += STR0013 + CRLF + STR0014 + Space(1) //"atrav�s da etapa respondida." #"A(s) Ordem(s) de Servi�o:"
			cError += aReturn[2] + Space(1) + STR0015//"deve(m) ser cancelada(s) para prosseguir com a opera��o."
		EndIf

		//+--------------------------------------------------------------------------------
		// 12.0 - Verifica a exitem S.S. para a etapa a ser desmarcada ou excluida
		//+--------------------------------------------------------------------------------
		If Empty(cError)

			aReturn := ::hasServRequest()

			If aReturn[1]
				cError := STR0008 + Space(1)  //"N�o ser� poss�vel"  
				cError += IIf(::isDelete() , STR0009, STR0010) + Space(1)//"excluir"#"desmarcar" 
				cError += STR0011 + Space(1) + STR0016 + Space(1) //#"a Etapa pois h�"#"Solicita��o(s) de Servi�o gerada(s)" 
				cError += STR0013 + CRLF + STR0014 + Space(1) //"atrav�s da etapa respondida." #"A(s) Ordem(s) de Servi�o:"
				cError += aReturn[2] + Space(1) + STR0017 //"deve(m) ser exclu�da(s) para prosseguir com a opera��o."
			EndIf
		EndIf

	EndIf

	//-------------------------------------------------
	// Verifica se etapa executada possui respostas
	//-------------------------------------------------
	If Empty(cError) .And. ::isUpsert() .And. ::hasOption() .And. ::isAccomplished() .And.  !(::hasAnswer()) 
		cError := STR0020 //"� necess�rio marcar e/ou informar pelo menos uma op��o de resposta para Etapas 'Exclusiva' ou 'M�ltiplas'."
	EndIf

	// Valida��es de Etapa que possua grid(TPQ)
	If Empty(cError) .And. ::hasGrid()

		// Busca Campos da TPQ
		aHeaderAux := ::getHeader("TPQ")
		aColsAux   := fGetAnswered( ::getCols("TPQ"), aHeaderAux, Self)

		nOption  := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_OPCAO" })
		nOrderG  := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_ORDEMG"})
		nAnswer  := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_RESPOS"})
		nLenAux  := Len(aColsAux)
		
		//--------------------------------------------------------------------------
		// Impede de informar respostas para etapas previstas
		//--------------------------------------------------------------------------
		If ::isForeseen() .And. nLenAux > 0
			cError := STR0018 //"Etapas previstas n�o devem possuir respostas."
		EndIf

		//--------------------------------------------------------------------
		// Valida quando � etapa exclusiva
		//--------------------------------------------------------------------
		If Empty(cError) .And. ::isExclusive() .And. nLenAux > 1
			cError := STR0019 // "Etapas exclusivas devem possuir apenas uma resposta."
		EndIf

		//----------------------------------------------
		// Valida��es de Respostas
		//----------------------------------------------
		If Empty(cError)

			For nLine := 1 To Len( aColsAux )

				cOption := aColsAux[nLine][nOption]
				cOrderG := aColsAux[nLine][nOrderG]
				cAnswer := aColsAux[nLine][nAnswer]

				//--------------------------------------------------------------------------
				// Valida campo op��o vazio
				//--------------------------------------------------------------------------
				If Empty( cOption )
					cError := STR0001 + Space(1) + NgRetTitulo("TPQ_OPCAO") + Space(1) + STR0002//"O campo"#"deve estar preenchido."
					Exit
				EndIf
				//---------------------------------------------------------------------------
				// O c�digo da resposta deve existir na tabela TPC - Op��es da Etapa Gen�rica
				//---------------------------------------------------------------------------
				If !NGIFDBSEEK("TPC", cStep + cOption, 1)
					cError := STR0021 + Space(1) + Alltrim(cOption) + Space(1) //"A Op��o"  
					cError += STR0022 //"n�o existe ou n�o pertence � tabela TPC - Op��es da Etapa Gen�rica."
				EndIf

				If ::isUpsert()

					//------------------------------------------------------
					// Valida quando etapa informativa deve ser respondida
					//------------------------------------------------------
					If Empty(cError) .And. Empty(cAnswer) .And. ::isInfoAnswer(cOption)
						cError := STR0021 + Space(1) + Alltrim(cOption) + Space(1) //"A Op��o"
						cError += STR0023 // "tem o preenchimento obrigat�rio do campo 'Resposta'."  
					EndIf

					//------------------------------------------------------------------
					// Busca pela op��o da etapa relacionada a resposta para validar o
					// tipo da resposta
					//------------------------------------------------------------------
					If Empty(cError) .And. ::hasOption() .And. NGIFDBSEEK("TPC", cStep + cOption, 1) .And.;
					!(NGTPCONTCAR(TPC->TPC_TIPCAM, cAnswer, .F.))
						// "O valor digitado n�o corresponde ao tipo utilizado. Informe um valor do tipo"
						cError := Alltrim(cOption) + Space(1) + STR0024 + Space(1) +  NGRETSX3BOX("TPC_TIPCAM",TPC->TPC_TIPCAM)
					EndIf

					//------------------------------------------------------
					// Validacoes de criacao de O.S. e S.S.
					//------------------------------------------------------
					If Empty(cError) .And. (::isCreateSO(cOption) .Or. ::isCreateSS(cOption))

						//------------------------------------------------------
						// Verifica campos de Servi�o e Codigo do Bem
						//------------------------------------------------------
						If NGIFDBSEEK("TPC",cStep + cOption, 1)
							cService := TPC->TPC_SERVIC
							cCodAsset  := IIf(TPC->TPC_PORBEM == "2", TPC->TPC_DESCRI, "")
						EndIf

						//------------------------------------------------------
						// Valida se Bem da O.S. ser� valido
						//------------------------------------------------------
						If Empty(cError) .And. !Empty(cCodAsset)
							If !(NGIFDBSEEK("ST9", cCodAsset, 1))
								cError := STR0025 //"O Bem informado (TPC_PORBEM) n�o existe ou n�o pertence � tabela ST9 - Bens."
							EndIf
						EndIf

						//------------------------------------------------------
						// Valida se opcao da Etapa cria Ordem de Servico
						//------------------------------------------------------
						If Empty(cError) .And. ::isCreateSO(cOption)

							If TPC->TPC_PORBEM == "1" //para o pr�prio bem
								cCodAsset := NGSEEK( "STJ", ::getValue("TQ_ORDEM"), 1,  "TJ_CODBEM") 
							EndIf

							//------------------------------------------------------
							// Valida se servi�o da O.S. ser� valido
							//------------------------------------------------------
							If !(NGIFDBSEEK("ST4", cService, 1))
								cError := STR0026 //"O Servi�o informado (TPC_SERVIC) n�o existe ou n�o pertence � tabela ST4 - Servi�os de Manuten��o."
							EndIf

							//----------------------------------------------------------
							// O.S. Preventiva
							//----------------------------------------------------------
							If Empty(cError) .And. NGSEEK("STE",ST4->T4_TIPOMAN ,1 ,"TE_CARACTE") == "P"
								If fVerCreate( cStep, cOption, cAnswer, cOrderG )

									//---------------------------------------------------------------
									// O c�digo da manuten��o deve existir na tabela STF - MANUTEN��O
									//---------------------------------------------------------------
									If !NGIFDBSEEK("STF", cCodAsset + cService, 1)
										cError := STR0029 + Space(1)//"Houve a necessidade de gerar uma O.S. Preventiva a partir da resposta da etapa"
										cError += STR0030 + CRLF //"por�m n�o existe manuten��o cadastrada para o Bem e Servi�o." 
										cError += STR0031 + Space(1) + Alltrim(cCodAsset)+ Space(1) // "Cadastrar uma manuten��o para o Bem" 
										cError += "-" + Space(1) + STR0032 + Space(1) + Alltrim(cService) //"Servi�o"
										Exit
									EndIf
									
									//-------------------------------------------------
									// Verifica se manuten��o tem mais de uma sequ�ncia
									//-------------------------------------------------									
									aSequence := fSequence( cStep, cOption, cCodAsset, cService ) 
									
									//-----------------------------------------------------------
									// Faz tratamento para mobile quando h� mais de 1 sequencia 
									//-----------------------------------------------------------
									If Len( aSequence ) > 1 .And. GetRemoteType() == -1
										If lMntStep
											cSequence := ExecBlock("MNTSTEP",.F.,.F.,{"SEQUENCE", Self, cCodAsset, cService, cStep, cOption})
										EndIf

										If Empty( cSequence ) .Or. aScan( aSequence, cSequence ) == 0 
											cError := STR0029 + Space(1)//"Houve a necessidade de gerar uma O.S. Preventiva a partir da resposta da etapa"
											cError += Alltrim( cOption ) +"," + Space(1) +  STR0035 //"por�m a manuten��o cadastrada possui mais de uma sequ�ncia." + CRLF 
											::addInfo( cOption ) //adiciona c�digo da op��o na lista de retorno 
											Exit
										EndIf
									EndIf									
								EndIf
							EndIf
							
							//------------------------------------------------------
							// Valida se opcao da Etapa cria Solicita��o de Servico
							//------------------------------------------------------
						ElseIf Empty(cError) .And. ::isCreateSS(cOption)

							//------------------------------------------------------------------------------------
							// Valida��o do servi�o da S.S. somente quando est� preenchido, campo n�o obrigat�rio
							//------------------------------------------------------------------------------------
							If !Empty( cService ) .And. !( NGIFDBSEEK( "TQ3", cService, 1 ) )
								cError := STR0027 //"O Servi�o informado (TPC_SERVIC) n�o existe ou n�o pertence � tabela TQ3 - Tipos de Servi�o da SS."
							EndIf
						EndIf
					EndIf
				EndIf

				//------------------------------------------------------
				// Verifica se existe erro encontrado no registro
				//------------------------------------------------------
				If !Empty(cError)
					Exit
				EndIf

			Next nLine
		EndIf
	EndIf

	//------------------------------------------------------
	// Adiciona o Erro ao Objeto instanciado
	//------------------------------------------------------
	If !Empty(cError)
		::addError(cError)
	EndIf

	RestArea(aArea)

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} upsert
M�todo para inclus�o e altera��o dos alias definidos para a classe.

@author Douglas Constancio
@since 02/03/2018
@return l�gico, se valida��o est� ok
@sample If oObj:valid()
			oObj:upsert()
		Else
			Help(,,'HELP',, oObj:GetErrorList()[1],1,0)
        EndIf
/*/
//------------------------------------------------------------------------------
Method upsert() Class MNTStep

	Local aArea  := GetArea()

	Local lTarGe := AllTrim(SuperGetMV("MV_NGTARGE", .F., "2")) == "1"
	Local aGener := {}
	Local nI,nX

	// Todos os conteudos a serem gravados passam entre a classe.
	::setValue("TQ_TAREFA", IIf((lTarGe .And. ::isCorrective() .Or. ::isPreventive()),;
		::getValue("TQ_TAREFA"), "0" + Space(TamSX3("TQ_TAREFA")[1] - 1)))

	//--------------------------------
	// Carrega todas os campos da classe em memoria de trabalho
	//--------------------------------
	::classToMemory()

	Begin Transaction

		If ::isValid()
			
			If ::hasAnswer()

				//-------------------------------------------------
				// Verifica e Gera ordens de servi�o ou solicita��o
				// a partir das respostas
				//-------------------------------------------------
				fGera( Self )

				If !(::isValid())
					DisarmTransaction()
					Break
				Else	
					//-------------------------------------
					//Tratamento das ordens e SS's geradas 
					//-------------------------------------
					For nX := 1 to Len(::getResultList())
						aGener:= ::getResultList()[nX]
						For nI := 1 to Len(aGener)
							::setValue('TPQ_ORDEMG',aGener[nI][4],;
										{{'TPQ_FILIAL', ::getValue('TQ_FILIAL')},;
										{'TPQ_ORDEM'  , ::getValue('TQ_ORDEM' )},;
										{'TPQ_PLANO'  , ::getValue('TQ_PLANO' )},;
										{'TPQ_TAREFA' , ::getValue('TQ_TAREFA')},;
										{'TPQ_ETAPA'  , ::getValue('TQ_ETAPA' )},;
										{'TPQ_OPCAO'  , aGener[nI][3]}})
						Next nI
					Next nX
				EndIf
			EndIf

			_Super:upsert()

			MsUnlockAll()

		Else
			DisarmTransaction()
			Break//posiciona a execu��o ap�s end transaction
		EndIf

	End Transaction

	RestArea(aArea)

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} delete
M�todo para exclus�o dos alias definidos para a classe.

@author Douglas Constancio
@since 02/03/2018
@return l�gico se a valida��o est� ok
@sample If oObj:valid()
			oObj:Delete()
		Else
			Help(,,'HELP',, oObj:GetErrorList()[1],1,0)
		EndIf
/*/
//------------------------------------------------------------------------------
Method delete() Class MNTStep

	// Carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	Begin Transaction

		If ::isValid()
			_Super:delete()
			MsUnlockAll()
		Else
			DisarmTransaction()
			Break//posiciona a execu��o ap�s end transaction
		EndIf

	End Transaction

Return ::isValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasServOrder
Indica se a etapa possui ordem de servico abertas

@author Douglas Constancio
@since 02/03/2018
@return array, se tem S.S. / ordens de Servi�os
/*/
//------------------------------------------------------------------------------
Method hasServOrder() Class MNTStep

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cOrders   := ""
	Local cQuery	:= ""
	Local lExist    := .F.

	cQuery := " SELECT TPQ_ORDEMG FROM " + RetSqlName("TPQ") + " TPQ"
	cQuery += " INNER JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += " 	ON STJ.TJ_ORDEM = TPQ.TPQ_ORDEMG "
	cQuery += " 	AND STJ.TJ_FILIAL  = " + ValtoSql(xFilial("STJ"))
	cQuery += " 	AND STJ.TJ_SITUACA <> 'C'"
	cQuery += " 	AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("TPC") + " TPC"
	cQuery += " 	ON TPC.TPC_ETAPA = TPQ.TPQ_ETAPA"
	cQuery += "		AND TPC.TPC_OPCAO = TPQ.TPQ_OPCAO"
	cQuery += " 	AND TPC.TPC_FILIAL = " + ValtoSql(xFilial("TPC"))
	cQuery += " 	AND TPC.TPC_TPMANU = '1'"
	cQuery += " 	AND TPC.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE TPQ.TPQ_FILIAL = " + ValtoSql(xFilial("TPQ"))
	cQuery += " 	AND TPQ.TPQ_ORDEM  = " + ValtoSql(::getValue("TQ_ORDEM"))
	cQuery += " 	AND TPQ.TPQ_PLANO  = " + ValtoSql(::getValue("TQ_PLANO"))
	cQuery += " 	AND TPQ.TPQ_TAREFA = " + ValtoSql(::getValue("TQ_TAREFA"))
	cQuery += " 	AND TPQ.TPQ_ETAPA  = " + ValtoSql(::getValue("TQ_ETAPA"))
	cQuery += " 	AND TPQ.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasQry)

	//Concatena todas as Ordens de Servi�o encontradas abertas.
	While (cAliasQry)->(!EoF())

		lExist := .T.

		If !Empty(cOrders)
			cOrders += "/ "
		EndIf

		cOrders += (cAliasQry)->TPQ_ORDEMG

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return {lExist, cOrders}

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasServRequest
Indica se a etapa possui solicita��es de servico abertas.

@author Douglas Constancio
@since 02/03/2018
@return array, se tem S.S. / Ordens de Servi�os
/*/
//------------------------------------------------------------------------------
Method hasServRequest() Class MNTStep

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local lExist 	:= .F.
	Local cRequests := ""
	Local cQuery	:= ""

	cQuery := " SELECT TPQ_ORDEMG FROM " + RetSqlName("TPQ") + " TPQ"
	cQuery += " INNER JOIN " + RetSqlName("TQB") + " TQB"
	cQuery += " 	ON TQB.TQB_SOLICI = TPQ.TPQ_ORDEMG"
	cQuery += " 	AND TQB.TQB_FILIAL = " + ValtoSql(xFilial("TQB"))
	cQuery += " 	AND TQB.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + RetSqlName("TPC") + " TPC"
	cQuery += " 	ON TPC.TPC_ETAPA = TPQ.TPQ_ETAPA"
	cQuery += " 	AND TPC.TPC_OPCAO = TPQ.TPQ_OPCAO "
	cQuery += " 	AND TPC.TPC_FILIAL = " + ValtoSql(xFilial("TPC"))
	cQuery += " 	AND TPC.TPC_TPMANU = '2'"
	cQuery += " 	AND TPC.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE TPQ.TPQ_FILIAL = " + ValtoSql(xFilial("TPQ"))
	cQuery += " 	AND TPQ.TPQ_ORDEM  = " + ValtoSql(::getValue("TQ_ORDEM"))
	cQuery += " 	AND TPQ.TPQ_PLANO  = " + ValtoSql(::getValue("TQ_PLANO"))
	cQuery += " 	AND TPQ.TPQ_TAREFA = " + ValtoSql(::getValue("TQ_TAREFA"))
	cQuery += " 	AND TPQ.TPQ_ETAPA  = " + ValtoSql(::getValue("TQ_ETAPA"))
	cQuery += " 	AND TPQ.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasQry)

	//Concatena todas as solicita��es encontradas abertas.
	While (cAliasQry)->(!EoF())

		lExist := .T.

		If !Empty(cRequests)
			cRequests += "/ "
		EndIf

		cRequests += (cAliasQry)->TPQ_ORDEMG

		(cAliasQry)-> (dbSkip())
	EndDo

	(cAliasQry)-> (dbCloseArea())

	RestArea(aArea)

Return {lExist, cRequests}

//------------------------------------------------------------------------------
/*/{Protheus.doc} isAccomplished
Indica se a etapa ja foi executada.

@author Douglas Constancio
@since 03/02/2018
@return l�gico, se a etapa est� realizada
/*/
//------------------------------------------------------------------------------
Method isAccomplished() Class MNTStep
Return !Empty(::getValue("TQ_OK"))

//------------------------------------------------------------------------------
/*/{Protheus.doc} isForeseen
Indica se a etapa � previsto.

@author Douglas Constancio
@since 02/05/2018
@return l�gico, se a etapa � prevista (n�o executada)
/*/
//------------------------------------------------------------------------------
Method isForeseen() Class MNTStep
Return Empty(::getValue("TQ_OK"))

//------------------------------------------------------------------------------
/*/{Protheus.doc} isPreventive
Indica se a Ordem de Servi�o � Preventiva

@author Douglas Constancio
@since 05/03/2018
@return l�gico, se a ordem de servi�o � preventiva
/*/
//------------------------------------------------------------------------------
Method isPreventive() Class MNTStep

	Local lRet := .F.

	If ValType( ::getParent() ) == "O"
		lRet := ::getParent():isPreventive()
	Else
		lRet := Val(::getValue("TQ_PLANO")) > 0
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} isCorrective
Indica se a Ordem de Servi�o � Corretiva

@author Douglas Constancio
@since 05/03/2018
@return l�gico, se � corretiva
/*/
//------------------------------------------------------------------------------
Method isCorrective() Class MNTStep

	Local lRet := .F.
	
	If ValType( ::getParent() ) == "O" //Verifica se objeto pai foi instanciado
		lRet := ::getParent():isCorrective()
	Else
		lRet := Val(::getValue("TQ_PLANO")) == 0
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasOption
Indica se a etapa possui op��o de resposta

@author Douglas Constancio
@since 01/01/2015
@return l�gico, se tem op��o de resposta
/*/
//------------------------------------------------------------------------------
Method hasOption() Class MNTStep

Return AllTrim(NGSEEK("TPA", ::getValue("TQ_ETAPA"), 1 ,"TPA_OPCOES")) != "0"

//------------------------------------------------------------------------------
/*/{Protheus.doc} isInfoAnswer
Indica se a op��o de resposta � informada

@author Douglas Constancio
@since 03/05/2018
@param cOption - Op��o de reposta - Obrigat�rio
@return l�gico, se a reposta � do tipo informar
/*/
//------------------------------------------------------------------------------
Method isInfoAnswer(cOption) Class MNTStep

Return NGIFDBSEEK("TPC", ::getValue("TQ_ETAPA") + cOption, 1) .And. TPC->TPC_TIPRES == "2"

//------------------------------------------------------------------------------
/*/{Protheus.doc} isMarkAnswer
Indica se a op��o de resposta � marcada

@author Douglas Constancio
@since 01/01/2015
@param cOption - Op��o de reposta - Obrigat�rio
@return l�gico, se a resposta � do tipo Marcar
/*/
//------------------------------------------------------------------------------
Method isMarkAnswer(cOption) Class MNTStep

Return NGIFDBSEEK("TPC", ::getValue("TQ_ETAPA") + cOption, 1) .And. TPC->TPC_TIPRES == "1" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} isCreateSO
Indica se a gera O.S. pela resposta

@author Douglas Constancio
@since 03/05/2018
@param cOption - Op��o de reposta - Obrigat�rio
@return l�gico, se a resposta tem a��o de gerar ordem de servi�o
/*/
//------------------------------------------------------------------------------
Method isCreateSO(cOption) Class MNTStep

Return NGIFDBSEEK("TPC", ::getValue("TQ_ETAPA") + cOption, 1) .And. TPC->TPC_TPMANU $ "1"

//------------------------------------------------------------------------------
/*/{Protheus.doc} isCreateSS
Indica se a gera S.S. pela resposta

@author Douglas Constancio
@since 03/05/2018
@param cOption - Op��o de reposta - Obrigat�rio
@return l�gico, se a resposta tem a��o de gerar solicita��o de servi�o
/*/
//------------------------------------------------------------------------------
Method isCreateSS(cOption) Class MNTStep

Return NGIFDBSEEK("TPC", ::getValue("TQ_ETAPA") + cOption, 1) .And. TPC->TPC_TPMANU == "2"

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasGrid
Indica se o cadastro da etapa utilizou grid

@author Douglas Constancio
@since 03/05/2018
@return l�gico, se utilizou grid
/*/
//------------------------------------------------------------------------------
Method hasGrid() Class MNTStep

	Local lFillGrid := .F.
	Local nLine 	:= 0

	For nLine := 1 To Len(::getCols("TPQ"))
		If !(_Super:EmptyLine("TPQ", nLine))
			lFillGrid := .T.
			Exit
		EndIf
	Next nLine

Return lFillGrid
//------------------------------------------------------------------------------
/*/{Protheus.doc} isExclusive
Indica se as op��es de etapa � exclusiva

@author Maria Elisandra de Paula
@since 03/05/2018
@return l�gico, se � op��o exclusiva
/*/
//------------------------------------------------------------------------------
Method isExclusive() Class MNTStep

Return AllTrim(NGSEEK("TPA", ::getValue("TQ_ETAPA"), 1, "TPA_OPCOES")) == "1"

//------------------------------------------------------------------------------
/*/{Protheus.doc} isMultiple
Indica se as op��es de etapa � multiplas

@author Maria Elisandra de Paula
@since 03/05/2018
@return l�gico, se � op��o Multipla
/*/
//------------------------------------------------------------------------------
Method isMultiple() Class MNTStep

Return AllTrim(NGSEEK("TPA", ::getValue("TQ_ETAPA"), 1 ,"TPA_OPCOES")) == "2"

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasAnswer
Indica se a etapa possui resposta da op��o

@param cOption - Op��o da Etapa
@author Douglas Constancio
@since 01/01/2018
@return l�gico, se tem resposta ou n�o
/*/
//------------------------------------------------------------------------------
Method hasAnswer() Class MNTStep

	Local aHeaderAux  := {}
	Local aColsAux    := {}

	If ::hasGrid()
		aHeaderAux := ::getHeader("TPQ")
		aColsAux   := fGetAnswered( ::getCols("TPQ"), aHeaderAux, Self)
	EndIf

Return Len(aColsAux) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} getResultList
Busca as OS/ SS geradas atrav�s das respostas das etapas da Ordem de Servi�o

@author Douglas Constancio
@since 08/05/2018
@return aResult, array, ordens de servi�os e solicita��es geradas
/*/
//------------------------------------------------------------------------------
Method getResultList() Class MNTStep
Return ::aResult

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetAnswered
Retorna apenas as op��es respondidas e n�o deletadas

@author Maria Elisandra de Paula
@since 03/05/2018
@param aCols, array, aCols com todas as op��es da resposta
@param aHeader,array, cabe�alho da TPQ
@param oSTQ, objeto, self de MntStep
@return array, op��es respondidas
/*/
//------------------------------------------------------------------------------
Static Function fGetAnswered(aCols, aHeader, oSTQ)

	Local nLine
	Local aColsAux := {}
	Local nOK      := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TPQ_OK"})

	For nLine := 1 to Len(aCols)

		//Somente linhas n�o-exclu�das
		If aTail( aCols[nLine] )
			Loop
		EndIf

		//Somente executados
		If !Empty(aCols[nLine][nOK])
			aAdd(aColsAux, aCols[nLine])
		EndIf

	Next nLine

Return aColsAux
//------------------------------------------------------------------------------
/*/{Protheus.doc} fGera
Gera ordens de servi�o e/ou Solicita��es a partir das respostas das etapas

@param oSTQ, objeto, self MntStep
@author Maria Elisandra de Paula
@since 03/05/2018
@return Nil

/*/
//------------------------------------------------------------------------------
Static Function fGera( oSTQ )

	Local aHeaderAux := {}
	Local aColsAux   := {}
	Local nLine      := 0
	Local nOption    := 0
	Local nOrderG    := 0
	Local nAnswer    := 0
	Local cOption    := ""
	Local cOrderG    := ""
	Local cAnswer    := ""
	Local aGeraOS    := {}
	Local aFieldsTQB := {}
	Local cConDin    := '' 
	Local cService   := ""
	Local cCodAsset  := ""
	Local cError     := ""
	Local cStep      := oSTQ:getValue('TQ_ETAPA' )
	Local aSequence  := {}
	Local cSequence  := ""
	Local cSituation := IIf( Alltrim( SuperGetMV( "MV_NGGEROS",.F. , "2" ) ) <> "2", "L","P" )
	Local lMntStep   := ExistBlock("MNTSTEP")

	//Variaveis utilizadas para o MsExecAuto de solicita��es
	Private lMSHelpAuto := .T. // N�o apresenta erro em tela
	Private lMSErroAuto := .F. // Caso a variavel torne-se .T. apos MsExecAuto, apresenta erro em tela

	If oSTQ:hasGrid()

		aHeaderAux := oSTQ:getHeader("TPQ")
		aColsAux   := fGetAnswered( oSTQ:getCols("TPQ"), aHeaderAux, oSTQ)
		nOption    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_OPCAO" })
		nOrderG    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_ORDEMG"})
		nAnswer    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPQ_RESPOS"})

		For nLine := 1 To Len( aColsAux )

			cOption := aColsAux[nLine][nOption]
			cOrderG := aColsAux[nLine][nOrderG]
			cAnswer := aColsAux[nLine][nAnswer]

			//--------------------------------------------------------------------------
			// Verifica se a resposta est� dentro das condi��es para gerar uma OS ou SS
			//--------------------------------------------------------------------------
			If (oSTQ:isCreateSO(cOption) .Or. oSTQ:isCreateSS(cOption)) .And. ;
				fVerCreate( cStep, cOption, cAnswer, cOrderG )

				//------------------------------------------------------------------
				// Busca pela op��o da etapa relacionada a resposta
				//------------------------------------------------------------------
				DBSelectArea("TPC")
				DBSetOrder(1)
				DBSeek( xFilial("TPC") + cStep + cOption )
				cService := TPC->TPC_SERVIC
				cConDin  := TPC->TPC_CONDIN

				If TPC->TPC_PORBEM == "1" //para o pr�prio bem
					dbSelectArea("STJ")
					dbSetOrder(1)
					If dbSeek(xFilial("STJ") + oSTQ:getValue("TQ_ORDEM"))
						cCodAsset := STJ->TJ_CODBEM
					EndIf
				Else
					cCodAsset := TPC->TPC_DESCRI
				EndIf
				//--------------------------------------------------------------
				// Concatena a observa��o
				//--------------------------------------------------------------
				cMessage := STR0028 + Space(1) + oSTQ:getValue('TQ_ORDEM') + CRLF //"O.S. origem:"
				cMessage += AllTrim( NgRetTitulo( 'TQ_ETAPA' ) ) + ':' + Space( 1 ) + oSTQ:getValue( 'TQ_ETAPA' ) + ' - ' 
				cMessage += AllTrim( NgSeek("TPA", oSTQ:getValue('TQ_ETAPA' ), 1, "TPA_DESCRI" )) + CRLF
				cMessage += AllTrim( NgRetTitulo( 'TPQ_OPCAO' ) ) + ':' + Space( 1 ) + cOption + CRLF

				If oSTQ:isInfoAnswer( cOption )
					cMessage +=  STR0045 + cConDin + CRLF //Limite:
					cMessage +=  STR0044 + cAnswer //Informou: 
				Else
					cMessage += STR0043 //Marcou: Sim
				EndIf
		
				//--------------------------------------------------------------
				// Define tratamentos especificos para gera��o de O.S.
				//--------------------------------------------------------------
				If oSTQ:isCreateSO( cOption )
					
					cTypeMnt	:= NGSEEK("ST4",cService ,1 ,"T4_TIPOMAN")
					cTypeServ	:= NGSEEK("STE",cTypeMnt ,1 ,"TE_CARACTE")
					cCodAsset   := Padr(cCodAsset,TamSx3('TF_CODBEM')[1])

					//----------------------------------------------------------
					// O.S. Preventiva
					//----------------------------------------------------------
					If cTypeServ == "P"

						cPlanMnt := "000001"

						//TODO: Desenvolver metodo para carregar insumos e etapas da manuten��o na classe
						
						//--------------------------------------------------
						// Busca a sequ�ncia da manuten��o
						//--------------------------------------------------
						aSequence := fSequence( cStep, cOption, cCodAsset, cService ) 
						cSequence := ""
						
						//-----------------------------------------------------------
						// Faz tratamento para mobile quando h� mais de 1 sequencia 
						//-----------------------------------------------------------
						If Len( aSequence ) > 1 .And. GetRemoteType() == -1
							If lMntStep
								cSequence := ExecBlock("MNTSTEP",.F.,.F.,{"SEQUENCE", oSTQ, cCodAsset, cService, cStep, cOption})
							EndIf
						Else
							cSequence := aSequence[1]
						EndIf
					
						//----------------------------------------------------------
						// O.S. Corretiva
						//----------------------------------------------------------
					ElseIf cTypeServ == "C"
						cPlanMnt := "000000"
						cSequence := "0"
					EndIf

					//------------------------------
					//Gera a O.S
					//------------------------------
					aGeraOS := NGGERAOS( cTypeServ, dDatabase, cCodAsset, cService, cSequence, "S", "S", "S", , cSituation, .f., .f. )
					
					//------------------------------
					//Verifica se a O.S foi aberta com sucesso
					//------------------------------
					If aGeraOS[1,1] == 'S'
					
						//Realiza grava��o da observa��o na O.S. gerada pela etapa.
						dbSelectArea( 'STJ' )
						dbSetOrder( 1 )
						If dbSeek( xFilial( 'STJ' ) + aGeraOS[1,3] )
						
							RecLock( 'STJ', .F. )
							If NGCADICBASE( 'TJ_MMSYP', 'A', 'STJ', .F. )
								MsMM( /**cChave **/, 80, /**nLin**/, cMessage, 1, /**nTamSize**/, /**lWrap**/, 'STJ', 'TJ_MMSYP' )
							Else
								STJ->TJ_OBSERVA := cMessage
							EndIf
							STJ->( MsUnLock() )
						
						EndIf
					
						aAdd( oSTQ:aResult[_OS_], {oSTQ:getValue('TQ_TAREFA'), oSTQ:getValue('TQ_ETAPA'), cOption, aGeraOS[1,3]} )
				
					Else
					
						cError := STR0033 + Space(1) + Alltrim(cOption) + Space(1) + CRLF //"Erro ao gerar uma Ordem de Servi�o a partir da Op��o" 
						cError += aGeraOS[1][2]
						Exit
					
					EndIf
					
				//--------------------------------------------------------------
				// Define tratamentos especificos para gera��o de S.S.
				//--------------------------------------------------------------
				ElseIf oSTQ:isCreateSS( cOption )

					aFieldsTQB := {}
					//TODO: codigo do bem deve vir da O.S.
					aAdd( aFieldsTQB , { "TQB_CODBEM", cCodAsset, Nil } )
					aAdd( aFieldsTQB , { "TQB_RAMAL" , "0000"   , Nil } )
					aAdd( aFieldsTQB , { "TQB_DESCSS", cMessage , Nil } )
					aAdd( aFieldsTQB , { "TQB_CDSERV", cService , Nil } )

					lMSHelpAuto := .T. // N�o apresenta erro em tela
					lMSErroAuto := .F. // Caso a vari�vel torne-se .T. apos MsExecAuto, apresenta erro em tela

					MSExecAuto( {|x,z,y,w| MNTA280(x,z,y,w)},,, aFieldsTQB )

					If lMsErroAuto
						//TODO: Pegar retorno do execAuto
						cError := STR0034 + Space(1) + cOption // "Erro ao gerar uma solicita��o de servi�o a partir da Op��o" 
						Exit						
					Else
						aAdd( oSTQ:aResult[_SS_],{oSTQ:getValue('TQ_TAREFA'),oSTQ:getValue('TQ_ETAPA'),;
													cOption, TQB->TQB_SOLICI})
					EndIf
				EndIf
			EndIf
		Next nLine
	EndIf

	//------------------------------------------------------
	// Adiciona o Erro ao Objeto instanciado
	//------------------------------------------------------
	If !Empty(cError)
		oSTQ:addError(cError)
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} fSequence
retorna as sequencias da manuten��o

@param oSTQ, objeto, self MntStep
@param cError, caracter, mensagem com erro, caso exista
@author Maria Elisandra de Paula
@since 11/06/2018
@return aSeq, array, sequencias da manuten��o

/*/
//------------------------------------------------------------------------------
Static Function fSequence( cStep, cOption, cCodAsset, cService )

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local aSeq      := {}

	cQuery := " SELECT TF_SEQRELA "
	cQuery += " FROM " + RetSqlName("TPC") + " TPC"
	cQuery += " JOIN " + RetSqlName("STF") + " STF"
	cQuery += " 	ON TF_FILIAL = " + ValtoSql(xFilial("STF")) 
	cQuery += " 	AND TF_CODBEM  = " + ValtoSql(cCodAsset)
	cQuery += " 	AND TF_SERVICO  = " + ValtoSql(cService)
	cQuery += " 	AND STF.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE TPC_FILIAL = " + ValtoSql(xFilial("TPC"))
	cQuery += "		AND TPC_ETAPA = " + ValtoSql(cStep)
	cQuery += "		AND TPC_OPCAO = " + ValtoSql(cOption)
	cQuery += "		AND TPC_TPMANU = '1'"//GERA OS
	cQuery += "		AND TPC.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasQry)

	dbSelectArea(cAliasQry)
	While !Eof()
		aAdd(aSeq, (cAliasQry)->TF_SEQRELA)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	RestArea( aArea )
Return aSeq
//------------------------------------------------------------------------------
/*/{Protheus.doc} fVerCreate
Verifica se o informe est� nas condi��es para gerar O.S. ou S.S.

@author Maria Elisandra
@since 11/06/2018
@param oObj, objeto, objeto self da classe
@param cOption, caracter, c�digo da op��o 
@param cAnswer, caracter, resposta da op��o
@param cOrderG, caracter, c�digo da OS/SS gerada pela resposta
@return lCondition, boolean, indica se o informe est� nas condi��es
/*/
//------------------------------------------------------------------------------
Static Function fVerCreate( cStep, cOption, cAnswer, cOrderG )

	Local lCondition := .F. 
	Local cModAnswer := ""
	Local cFormula   := ""

	If NGIFDBSEEK("TPC", cStep + cOption , 1)
		If TPC->TPC_TIPRES == "2" //informar
			Do Case
			Case TPC->TPC_TIPCAM == "L"
				cModAnswer := AllTrim( cAnswer )
			Case TPC->TPC_TIPCAM == "N"
				cModAnswer := cValToChar( Val( cAnswer ) )
			Case TPC->TPC_TIPCAM == "D"
				cModAnswer := "'" + DtoS( CtoD ( cAnswer ) ) + "'"
			Case TPC->TPC_TIPCAM == "C"
				cModAnswer := "'" + AllTrim( cAnswer ) + "'"
			EndCase
			cFormula := StrTran( TPC->TPC_FORMUL, '#RESP#', cModAnswer )
			lCondition := &( cFormula )
		ElseIf TPC->TPC_TIPRES == "1" //Marcar
			lCondition := .T.
		EndIf
	
		//------------------------------------------------------------------
		// Desconsidera se j� existir uma ordem n�o cancelada ou solicita��o 
		// gerada pela resposta 
		//------------------------------------------------------------------		
		If lCondition .And. !Empty( cOrderG )
			If (TPC->TPC_TPMANU == "1" .And. NGIFDBSEEK("STJ", cOrderG, 1) .And. STJ->TJ_SITUACA <> "C") .Or.;
				(TPC->TPC_TPMANU == "2" .And. NGIFDBSEEK("TQB", cOrderG, 1) )
				lCondition := .F.
			EndIf			
		EndIf
	EndIf

Return lCondition
