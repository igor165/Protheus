#INCLUDE "PROTHEUS.CH"
#Include "AP5MAIL.CH"
#Include "SIGAWF.CH"
#INCLUDE "ORGWF010.CH"

#DEFINE cCodUser "MSALPHA"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ ORGWF010 ³ Autor ³ Equipe IP-RH Inovacao ³ Data ³ 29/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Envio de WF para para integracao entre SIGAORG e SIGARSP   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ SigaOrg - Arquitetura Organizacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Cecilia Car. ³04/08/14³TQFZO4³Incluido o fonte da 11 para a 12.           ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WFAltVagas(nOpcao,nQtDig)
	Local cCodProcesso     	:= "ALTVAGA" 
	Local cAssunto         	:= OemToAnsi(STR0001)	// "Alteração de Vagas"
	Local cHtmlModelo      	:= ""					// Arquivo html template utilizado para montagem da aprovação
	Local cDetalhe			:= ""
	Local nRegRBU			:= RBU->(Recno())
	Local nOrdRBU			:= RBU->(IndexOrd())
	Local cAliasQry1		:= GetNextAlias()
	Local cWhere			:= ""
	Local aAlteracoes		:= {}
	Local aComparacao 		:= {}
	Local nA				:= 0
	Local nB				:= 0
	Local cEmailTo			:= GetMv("MV_WFRESVG")

	Default nOpcao			:= 0

	If Empty(cEmailTo)
		Return
	Endif

	oProcess := TWFProcess():New(cCodProcesso, cAssunto )
		
	//Html Modelo de Solicitacao de Alteracao de Vagas
	cHtmlModelo := "\workflow\wfaltvagas.html"

	// Crie uma tarefa.
	oProcess:NewTask(cAssunto, cHtmlModelo)
	
	If oProcess:oHtml == NIL
		Return
	EndIf    

	oProcess:oHtml:ValByName("cTitulo"    	, OemToAnsi(STR0001) )	// "Alteração de Vagas"
	oProcess:oHtml:ValByName("cTitAlteracao", OemToAnsi(STR0002) ) // "Alterações efetuadas"
			
	// String para Titulos dos campos do Posto
	oProcess:oHtml:ValByName("cTitFilial" 	, OemToAnsi(TITSX3("RBU_FILIAL")[1]) )
	oProcess:oHtml:ValByName("cTitPosto"  	, OemToAnsi(TITSX3("RBU_POSTO")[1]) )
	oProcess:oHtml:ValByName("cTitDep"    	, OemToAnsi(TITSX3("RBU_DEPTO")[1]) )
	oProcess:oHtml:ValByName("cTitCC"  		, OemToAnsi(TITSX3("RBU_CC")[1]) )
	oProcess:oHtml:ValByName("cTitCargo"  	, OemToAnsi(TITSX3("RBU_CARGO")[1]) )
	oProcess:oHtml:ValByName("cTitFuncao"	, OemToAnsi(TITSX3("RBU_FUNCAO")[1]) )
	oProcess:oHtml:ValByName("cTitNVagas"	, OemToAnsi(TITSX3("RBU_NPOSTO")[1]) )
	oProcess:oHtml:ValByName("cTitDtMov"	, OemToAnsi(TITSX3("RBU_DTAMOV")[1]) )

	// String para apresentacao das descricoes das vagas
	oProcess:oHtml:ValByName("cTitVagas"	, OemToAnsi(STR0003) )	// "Vaga associada que sofrerá alteração"
	oProcess:oHtml:ValByName("cTVaga"		, OemToAnsi(TITSX3("QS_VAGA")[1]) )	
	oProcess:oHtml:ValByName("cTCodArea"	, OemToAnsi(TITSX3("QS_AREA")[1]) )		
	oProcess:oHtml:ValByName("cTCCusto"		, OemToAnsi(TITSX3("QS_CC")[1]) )	
	oProcess:oHtml:ValByName("cTFuncao"		, OemToAnsi(TITSX3("QS_FUNCAO")[1]) )	
	oProcess:oHtml:ValByName("cTNVagas"		, OemToAnsi(TITSX3("QS_NRVAGA")[1]) )	
	oProcess:oHtml:ValByName("cTNFVagas"	, OemToAnsi(TITSX3("QS_VAGAFEC")[1]) )	
						  			
	oProcess:oHtml:ValByName("cCodFilial"		, 	RBU->RBU_FILIAL ) 
	oProcess:oHtml:ValByName("cPosto"			, 	RBU->RBU_POSTO )
	oProcess:oHtml:ValByName("cDepartamento"	, 	RBU->RBU_DEPTO  + " - " + fDesc("SQB", RBU->RBU_DEPTO, "QB_DESCRIC"))
	oProcess:oHtml:ValByName("cCentroCusto"		, 	RBU->RBU_CC + " - " + FDESC("CTT",RBU->RBU_CC,"CTT_DESC01"))
	oProcess:oHtml:ValByName("cCargo"			, 	RBU->RBU_CARGO + " - " + fDesc("SQ3",RBU->RBU_CARGO,"Q3_DESCSUM"))
	oProcess:oHtml:ValByName("cFuncao"			, 	RBU->RBU_FUNCAO  + " - " + FDESC("SRJ",RBU->RBU_FUNCAO,"RJ_DESC") )	
	oProcess:oHtml:ValByName("cNVagas"			, 	Str(RBU->RBU_NPOSTO,5) )
	oProcess:oHtml:ValByName("cDtMov"			, 	DTOC(RBU->RBU_DTAMOV) )

	// Aumento de Quadro
	If nOpcao == 0

		cWhere	:= "% RBU.D_E_L_E_T_ = ' ' AND RBU.RBU_FILIAL = '" + RBU->RBU_FILIAL+ "' AND RBU.RBU_POSTO = '" + RBU->RBU_POSTO +  "'%"
		BeginSql alias cAliasQry1
		   	SELECT RBU.*
			FROM %table:RBU% RBU 
			WHERE %exp:cWhere%
			ORDER BY RBU_CODMOV DESC
		EndSql
	
		aAlteracoes := {}
		While (cAliasQry1)->( !Eof() )
	
			aAdd( aAlteracoes , {} )
	
			For nA := 1 to (cAliasQry1)->(FCount())				
				If !(AllTrim(FieldName(nA)) $ "RBU_FILIAL/RBU_CODMOV/RBU_DTAMOV/RBU_OPERAC/RBU_POSTO/RBU_DEPTO/RBU_DTFANT/RBU_ORIGEM/RBU_RESPON/RBU_ESTRUT/RBU_REC_WT/R_E_C_N_O_/D_E_L_E_T_/R_E_C_D_E_L_")
					cConteudo	:= FieldGet( nA )
	
					If ValType( cConteudo ) == "D"
						cConteudo := DTOC( cConteudo )
					ElseIf ValType( cConteudo ) == "N"
						cConteudo := AllTrim(STR( cConteudo ))
					ElseIf ValType( cConteudo ) == "L"
						cConteudo := If(cConteudo,"Verdadeiro","Falso")
					Endif
	
					aAdd(aAlteracoes[ Len(aAlteracoes) ], { FieldName(nA), cConteudo } )
				Endif
			Next
	
			(cAliasQry1)->( dbSkip() )
	
			// Carrega apenas as duas ultimas alteracoes
			If Len(aAlteracoes) == 2
				Exit
			Endif
	
		Enddo

		If Len(aAlteracoes) > 0
	
			aComparacao := {}
			
			If Len(aAlteracoes) == 1
				For nB := 1 to Len(aAlteracoes [ 1 ])
					aAdd( aComparacao , { aAlteracoes [ nA , nB , 1 ] , 'Inicial' , aAlteracoes [ 1 , nB , 2 ] } )
				Next
			Else
				For nB := 1 to Len(aAlteracoes [ 1 ])
					If aAlteracoes [ 1 , nB , 2] <> aAlteracoes [ 2 , nB , 2]
						aAdd( aComparacao , { TITSX3(aAlteracoes [ 1 , nB , 1 ])[1] , aAlteracoes [ 2 , nB , 2 ] , aAlteracoes [ 1 , nB , 2 ] } )
					Endif
				Next
			Endif
	
			If Len(aComparacao) > 0
				cDetalhe := "<tr>"
				cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0004 +  '</span></div></td>'	// "Campo"
				cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0005 + '</span></div></td>'	// "Conteudo Anterior"
				cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0006 + '</span></div></td>'	// "Conteudo Atual"
				cDetalhe += "</tr>"
	
				oProcess:oHtml:ValByName("Array1Ctd"	, 	cDetalhe )
				
				cDetalhe := ''
				For nA := 1 to Len(aComparacao)
					cDetalhe += '<tr>'
					cDetalhe += '	<td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + aComparacao [ nA , 1 ] + '</span></div></td>'
					cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + aComparacao [ nA , 2 ] + '</span></div></td>'
					cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + aComparacao [ nA , 3 ] + '</span></div></td>'
					cDetalhe += '</tr>'
				Next
			Endif
	
			oProcess:oHtml:ValByName("Array2Ctd"	, 	cDetalhe )
			
		Endif
	
		(cAliasQry1)->( dbCloseArea() )
		dbSelectArea("RBU")
		RBU->(dbGoTo(nRegRBU))	
		RBU->(dbSetOrder(nOrdRBU))

	// Alteracao de Funcao ou Centro de Custo
	ElseIf nOpcao == 1

		cDetalhe := "<tr>"
		cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0004 +  '</span></div></td>'	// "Campo"
		cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0005 + '</span></div></td>' // "Conteudo Anterior"
		cDetalhe += '	<td width="14%" class="Fundo1"><div align="center"><span class="TituloMenor">' + STR0006 + '</span></div></td>' // "Conteudo Atual"
		cDetalhe += "</tr>"

		oProcess:oHtml:ValByName("Array1Ctd"	, 	cDetalhe )

		cDetalhe := ""
		If (cAliasQry)->QS_CC <> RBU->RBU_CC 
			cDetalhe += '<tr>'
			cDetalhe += '	<td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + "Centro de Custo" + '</span></div></td>'	// 
			cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + (cAliasQry)->QS_CC + '</span></div></td>'
			cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + RBU->RBU_CC + '</span></div></td>'
			cDetalhe += '</tr>'
		Endif
	
		If (cAliasQry)->QS_FUNCAO <> RBU->RBU_FUNCAO
			cDetalhe += '<tr>'
			cDetalhe += '	<td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + "Função" + '</span></div></td>'
			cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + (cAliasQry)->QS_FUNCAO + '</span></div></td>'
			cDetalhe += '   <td  width="14%" class="Fundo2"><div align="center"><span class="texto">' + RBU->RBU_FUNCAO + '</span></div></td>'
			cDetalhe += '</tr>'
		Endif

		oProcess:oHtml:ValByName("Array2Ctd"	, 	cDetalhe )

	Endif

	// Conteudo dos campos do cadastro de Vagas
	oProcess:oHtml:ValByName("cTCVaga"		, 	SQS->QS_VAGA + "-" + SQS->QS_DESCRIC )
	oProcess:oHtml:ValByName("cTCCodArea"	, 	SQS->QS_AREA )
	oProcess:oHtml:ValByName("cTCCCusto"	, 	SQS->QS_CC + "-" + FDESC("CTT",SQS->QS_CC,"CTT_DESC01") )	
	oProcess:oHtml:ValByName("cTCFuncao"	, 	SQS->QS_FUNCAO + "-" + FDESC("SRJ",SQS->QS_FUNCAO,"RJ_DESC") )
	oProcess:oHtml:ValByName("cTCNVagas"	, 	SQS->QS_NRVAGA )
	oProcess:oHtml:ValByName("cTCNFVagas"	, 	SQS->QS_VAGAFEC )

	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := cAssunto

	oProcess:cTo := cemailTo 
	oProcess:ohtml:ValByName("cTexto"   , STR0008 + " " + RBU->RBU_POSTO + " " + STR0009 + " " + SQS->QS_VAGA + " " + STR0010 ) // "O posto" ### "sofreu alteração e a vaga" ### "que está associada a este posto também foi alterada. Detalhes abaixo:"
	                                               
	// Apos ter repassado todas as informacoes necessarias para o workflow, solicite a
	// a ser executado o método Start() para se gerado todo processo e enviar a mensagem
	// ao destinatário.
	oProcess:Start()

	cCodProcesso   := NIL
	cAssunto       := NIL
	cHtmlModelo    := NIL
Return

Function WFCanConVagas(nOpcao)

	Local cCodProcesso     	:= "CANCONVAGA" 
	Local cAssunto         	:= ""
	Local cHtmlModelo      	:= ""					// Arquivo html template utilizado para montagem da aprovação
	Local cEmailTo			:= GetMv("MV_WFRESVG")
	Default nOpcao			:= 0
						
	oProcess := TWFProcess():New(cCodProcesso, cAssunto )
		
	//Html Modelo de Solicitacao de Alteracao de Vagas
	cHtmlModelo := "\workflow\wfcanconvagas.html"

	If nOpcao == 1 //Cancelamento
		cAssunto := OemToAnsi(STR0011)	// "Cancelamento de Vagas"
	Elseif nOpcao == 2 // Congelamento
		cAssunto := OemToAnsi(STR0012)	// "Congelamento de Vagas"
	Endif

	// Crie uma tarefa.
	oProcess:NewTask(cAssunto, cHtmlModelo)
	
	If oProcess:oHtml == NIL
		Return
	EndIf  

	If nOpcao == 1 //Cancelamento
		oProcess:oHtml:ValByName("cTitulo"    	, OemToAnsi(STR0011) ) // "Cancelamento de Vagas"
	Elseif nOpcao == 2 // Congelamento
		oProcess:oHtml:ValByName("cTitulo"    	, OemToAnsi(STR0012) )	// "Congelamento de Vagas"
	Endif

	// String para Titulos dos campos do Posto
	oProcess:oHtml:ValByName("cTitFilial" 	, OemToAnsi(TITSX3("RBU_FILIAL")[1]) )
	oProcess:oHtml:ValByName("cTitPosto"  	, OemToAnsi(TITSX3("RBU_POSTO")[1]) )
	oProcess:oHtml:ValByName("cTitDep"    	, OemToAnsi(TITSX3("RBU_DEPTO")[1]) )
	oProcess:oHtml:ValByName("cTitCC"  		, OemToAnsi(TITSX3("RBU_CC")[1]) )
	oProcess:oHtml:ValByName("cTitCargo"  	, OemToAnsi(TITSX3("RBU_CARGO")[1]) )
	oProcess:oHtml:ValByName("cTitFuncao"	, OemToAnsi(TITSX3("RBU_FUNCAO")[1]) )
	oProcess:oHtml:ValByName("cTitNVagas"	, OemToAnsi(TITSX3("RBU_NPOSTO")[1]) )

	// String para apresentacao das descricoes das vagas
	oProcess:oHtml:ValByName("cTitVagas"	, OemToAnsi(STR0003) )	// "Vaga associada que sofrerá alteração"
	oProcess:oHtml:ValByName("cTVaga"		, OemToAnsi(TITSX3("QS_VAGA")[1]) )	
	oProcess:oHtml:ValByName("cTCodArea"	, OemToAnsi(TITSX3("QS_AREA")[1]) )		
	oProcess:oHtml:ValByName("cTCCusto"		, OemToAnsi(TITSX3("QS_CC")[1]) )	
	oProcess:oHtml:ValByName("cTFuncao"		, OemToAnsi(TITSX3("QS_FUNCAO")[1]) )	
	oProcess:oHtml:ValByName("cTNVagas"		, OemToAnsi(TITSX3("QS_NRVAGA")[1]) )	
	oProcess:oHtml:ValByName("cTNFVagas"	, OemToAnsi(TITSX3("QS_VAGAFEC")[1]) )	

	dbSelectArea("RCL")
	dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )
	RCL->(dbSeek(xFilial("RCL", RBU->RBU_FILIAL) + RBU->RBU_POSTO ))

	dbSelectArea("RBU")
	oProcess:oHtml:ValByName("cCodFilial"		, 	RBU->RBU_FILIAL ) 
	oProcess:oHtml:ValByName("cPosto"			, 	RBU->RBU_POSTO )
	oProcess:oHtml:ValByName("cDepartamento"	, 	RCL->RCL_DEPTO  + " - " + fDesc("SQB", RCL->RCL_DEPTO, "QB_DESCRIC"))
	oProcess:oHtml:ValByName("cCentroCusto"		, 	RCL->RCL_CC + " - " + FDESC("CTT",RCL->RCL_CC,"CTT_DESC01"))
	oProcess:oHtml:ValByName("cCargo"			, 	RCL->RCL_CARGO + " - " + fDesc("SQ3",RCL->RCL_CARGO,"Q3_DESCSUM"))
	oProcess:oHtml:ValByName("cFuncao"			, 	RCL->RCL_FUNCAO  + " - " + FDESC("SRJ",RCL->RCL_FUNCAO,"RJ_DESC") )	
	oProcess:oHtml:ValByName("cNVagas"			, 	Str(RCL->RCL_NPOSTO,5) )

	// Conteudo dos campos do cadastro de Vagas
	oProcess:oHtml:ValByName("cTCVaga"		, 	SQS->QS_VAGA + "-" + SQS->QS_DESCRIC )
	oProcess:oHtml:ValByName("cTCCodArea"	, 	SQS->QS_AREA )
	oProcess:oHtml:ValByName("cTCCCusto"	, 	SQS->QS_CC + "-" + FDESC("CTT",SQS->QS_CC,"CTT_DESC01") )	
	oProcess:oHtml:ValByName("cTCFuncao"	, 	SQS->QS_FUNCAO + "-" + FDESC("SRJ",SQS->QS_FUNCAO,"RJ_DESC") )
	oProcess:oHtml:ValByName("cTCNVagas"	, 	SQS->QS_NRVAGA )
	oProcess:oHtml:ValByName("cTCNFVagas"	, 	SQS->QS_VAGAFEC )

	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := cAssunto
	oProcess:cTo := cEmailTo

	If nOpcao == 1	// Cancelamento	
		oProcess:ohtml:ValByName("cTexto"   , STR0008 + " " + RBU->RBU_POSTO + " " + STR0013 + " " + SQS->QS_VAGA + " " + STR0014) // "O posto" ### "sofreu cancelamento e a vaga" ### " que está associada a este posto também será encerrada. Detalhes abaixo:"
	ElseIf nOpcao == 2 //  Congelamento
		oProcess:ohtml:ValByName("cTexto"   , STR0008 + " " + RBU->RBU_POSTO + " " + STR0015 + " " + SQS->QS_VAGA + " " + STR0014) // "O posto" ### "sofreu congelamento e a vaga" ### "que está associada a este posto também será encerrada. Detalhes abaixo:"
	Endif	                                               

	// Apos ter repassado todas as informacoes necessarias para o workflow, solicite a
	// a ser executado o método Start() para se gerado todo processo e enviar a mensagem
	// ao destinatário.
	oProcess:Start()

	cCodProcesso   := NIL
	cAssunto       := NIL
	cHtmlModelo    := NIL
Return