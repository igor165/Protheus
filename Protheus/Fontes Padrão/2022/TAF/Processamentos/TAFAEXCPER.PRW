#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWCOMMAND.CH"     

// --------------------------------------------------------------------------------------------------------
//DEFINIÇÕES DE LAYOUT DO ARQUIVO LAYOUT.DEF
#DEFINE Z1_LAYOUT		01
#DEFINE Z1_DESC		02
#DEFINE Z1_ADAPT		03
#DEFINE Z1_TABLE		04
#DEFINE Z1_DESTAB		05
#DEFINE Z1_ORDER		06
#DEFINE Z1_MVCOPT		07
#DEFINE Z1_MVCMET		08
#DEFINE Z1_CHANELS	09

#DEFINE Z2_CHANEL		01
#DEFINE Z2_SUPER		02
#DEFINE Z3_RELAC		03
#DEFINE Z3_DESC		04
#DEFINE Z3_IDOUT		05
#DEFINE Z3_OCCURS		06
#DEFINE Z3_ORDER		07
#DEFINE Z3_FIELDS		08 

#DEFINE Z4_SEQ		01
#DEFINE Z4_FIELD		02
#DEFINE Z4_DESC		03
#DEFINE Z4_TYPFLD		04
#DEFINE Z4_SOURCE		05
#DEFINE Z4_EXEC		06

STATIC aLayDef := Nil
STATIC aDelLay := Nil
STATIC nQtdReg := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAEXCPER
                       
Rotina de exclusão em lote, conforme período informado pelo usuário.  

@param 	aPar - Campos:
		aPar[1] - Data inicial
		aPar[2] - Data final
		aPar[3] - Escopos de exclusão / 1-Fiscal / 2-Contábil/ 3-eSocial /
		aPar[4] - Eventos que devem ser apagados ( Ex: 'S-1010;S-1020;S1030' )
		
		cFilTaf - Filial do processamento, somente será utilizado quando a chamada da funçaõ for realizada
				   pelo SIGAGPE
		
@obs Exemplo de chamada: TAFAEXCPER("20150301","20150331","1;2;")  

@return aRet     [1] - Nome do Layout do eSocial
                 [2] - Indica se foi realizada exclusao ou não da tabela

@author Anderson Costa
@since 11/03/2015
@version 1.0

Altered by Rodrigo Aguilar in 29/10/2015
Realizada alteração para que o SIGAGPE possa realizar a chamada da função pelo módulo, informando
a filial do processamento e filtrando quais os registros que devem ser considerados no processamento
/*/
//-------------------------------------------------------------------
Function TAFAEXCPER(aPar, cFilTaf, lSkipAlert)

Local aRet       		:= {}
Local oProcessFil		:= Nil

Default lSkipAlert		:= .F.

If ! lSkipAlert
	oProcessFil := TAFProgress():New( { |lEnd| aRet := TafAExcFil(@lEnd, @oProcessFil, aPar, cFilTaf, lSkipAlert) }, "Selecionando Registros", .F. )
	oProcessFil:Activate()
Else
	aRet := TafAExcFil(, @oProcessFil, aPar, cFilTaf, lSkipAlert)
EndIf

Return(aRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} TafAExcFil
                       
Execuçção da rotina TAFAEXCPER via TAFProgress para interação do
progresso de execução com o usuário

@param	lEnd			-> Verifica se a operacao foi abortada pelo usuario
		oProcess		-> Objeto da barra de progresso da emissao do ECF
		aPar			->
		cFilTaf			-> 

@return NIL

@author Felipe Rossi Moreira
@since 27/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Function TafAExcFil(lEnd, oProcessFil, aPar, cFilTaf, lSkipAlert, lAuto)

Local cPergunt			:= "TAFEXCPER" // Pergunte SX1
Local dDtIni			:= ""
Local dDtFin			:= ""
Local cEscopoExc		:= ""
Local cProcFiscal		:= ""	   	//Considera movimentos Fiscais?
Local cProcContabil		:= ""	  	//Considera movimentos Contabeis?
Local cProcRH			:= ""	   	//Considera movimentos RH?
Local cProcReinf		:= ""		//Considera movimentos do ReInf
Local nI				:= 0
Local cQuery			:= ""
Local cAliasQry			:= ""
Local cLayout			:= ""
Local cAlias			:= ""
Local cAlias2			:= ""
Local cCampoInt			:= ""
Local cRegREC			:= ""
Local cRegEsc			:= ""
Local cPerIni    		:= ""
Local cPerFin    		:= ""
Local cRotinaModelo		:= ""
Local aMovExc			:= {}
Local aRegExc			:= {}
Local aLisFil			:= {}
Local nFilSel			:= 0
Local nlI 				:= 0
Local cRegs      		:= ''
Local cMensagem  		:= '' 
Local aRet       		:= {}
Local aEmpAux			:= {}
Local lLimpaC1E			:= .T.
Local lFiscal			:= .F.
Local lContab			:= .F.
Local lESoc				:= .F.
Local lReinf			:= .F.
Local cAmbEsocial   	:= ''
Local cAmbReinf   		:= ''
Local cTpEvento			:= ''
Local aArea				:= {}
Local oModel050			:= Nil
Local oProcess			:= Nil
Local lProc 			:= .F.

Default aPar			:= {}
Default cFilTaf   		:= ''
Default lSkipAlert		:= .F.
Default lEnd			:= .F.
Default lAuto           := .F.

//Verifica se a Empresa está Operando em Produção
cAmbEsocial := GetNewPar( "MV_TAFAMBE", "3" )
cAmbReinf		:= GetNewPar( "MV_TAFAMBR", "3" )

//Verifica se o usuário pertence ao grupo de adminaaistradores
If !(FWIsAdmin( __cUserID ) )
    Help(,, "TafAExcFil", , ' O usuário ' + __cUserID + ' não pertence ao grupo de administradores!', 1, 0, , , , , , {"Confira o grupo ao qual o usuário pertence."})
    Return Nil
Endif

lLimpaC1E  := Empty(cFilTaf) //Se cFilTaf com conteúdo, vem do GPE, então não devo limpar C1E

If Len(aPar) > 0
	
	dDtIni     := aPar[1]
	dDtFin     := aPar[2]
	cEscopoExc := aPar[3]
	cRegs      := aPar[4]
	If Len(aPar) > 4 .And. Valtype(aPar[5]) <> "U"
		cProcReinf := aPar[5]
	Else
		cProcReinf := "1"
	EndIf
	
ElseIf Pergunte( cPergunt, .T. )
	
	dDtIni			:= DTOS( MV_PAR01 )
	dDtFin			:= DTOS( MV_PAR02 )
	
	cProcFiscal	   	:= allTrim( str( MV_PAR03 ) )	//Considera movimentos Fiscais? 1 = Nao; 2 = Sim
	cProcContabil	:= allTrim( str( MV_PAR04 ) )	//Considera movimentos Contabeis? 1 = Nao; 2 = Sim
	cProcRH		   	:= allTrim( str( MV_PAR05 ) )   //Considera movimentos RH? 1 = Nao; 2 = Sim
	If Valtype(MV_PAR06) == "N"
		cProcReinf	:= allTrim( str( MV_PAR06 ) )   //Considera movimentos Reinf? 1 = Nao; 2 = Sim
	Else 
		cProcReinf	:= "1" 
	EndIf 
Else
	Return NIL
EndIf

//Verifica se ira excluir movimentos fiscais
If cProcFiscal == "2"		//2 = Sim
	cEscopoExc	+=	"1;"	//Adiciona o identificador "1" na variavel cEscopoExc, que representa os movimentos fiscais
EndIf

//Verifica se ira excluir movimentos contabeis
If cProcContabil == "2"		//2 = Sim
	cEscopoExc	+=	"2;"	//Adiciona o identificador "2" na variavel cEscopoExc, que representa os movimentos contabeis
Endif

//Verifica se ira excluir movimentos RH
If cProcRH == "2"			//2 = Sim
	cEscopoExc	+=	"3;"	//Adiciona o identificador "3" na variavel cEscopoExc, que representa os movimentos esocial
Endif

If cProcReinf == '2'
	cEscopoExc	+=	"4"	
EndIf

If !lAuto .And. Empty( cEscopoExc )
		Help(,, "TafAExcFil", , 'Não foi escolhido nenhum tipo de movimentação para exclusão!', 1, 0, , , , , , {"Selecione o tipo de Movimentação e confirme a exclusão."})
	Return Nil
EndIf

//No caso do eSocial não é necessário o período ser informado pois toda a tabela será apagada.
//Claudio Gaspar 
//No caso do eSocial e se for gerado do SigaGpe não será necessário o período ser 
//informado pois toda a tabela serão apagadas.

//If ( "3" $ cEscopoExc ) .and. ( Empty( dDtIni ) .Or. Empty( dDtFin ) )

If !lAuto .And. Empty(cFilTaf) .and. cEscopoExc <> "3" .and. ( Empty( dDtIni ) .Or. Empty( dDtFin ) ) 
	Help(,, "TafAExcFil", , 'Não foi informado um período de movimentação válido para exclusão!', 1, 0, , , , , , {"Confira as datas e informe um período válido."})
	Return Nil
EndIf

//Guardo a filial corrente que esta logado para restaurar no final do processo
aAdd( aEmpAux , { cEmpAnt , cFilAnt } )

//Caso a filial já tenha sido informada na chamada da função não abro a tela de seleção de filias
if !lAuto .And. empty( cFilTaf )
	//Realizo a Verificacao das Filiais Selecionadas
	aLisFil  :=	xFunTelaFil(.T.,,,.F.)
else
	aAdd( aLisFil, { .T., cFilTaf } )
endif

If Len(aLisFil) > 0

	If ("4" $ cEscopoExc .And. cAmbReinf == "1")
		
		If ("4" $ cEscopoExc .And. cAmbReinf == "1")
			cMensagem += "Ambiente Reinf" + CRLF
			cMensagem += "Empresa operando em Produção." + CRLF + CRLF
		EndIf 

		cMensagem += "A exclusão por período fiscal não será executada. A exclusão é permitida apenas para ambientes de Pré-Produção - Dados Reais e Pré-Produção - Dados Fictícios. " + CRLF

		If lSkipAlert
			lProc := .F.
		Else
			Help(,,"Exclusão por Período Fiscal", , cMensagem, 1, 0, , , , , , {"Verifique a configuração do ambiente de trabalho (Produção / Homologação)."})
			lProc := .F.
		EndIf

	Else 
		If "1" $ cEscopoExc
			cMensagem += "Fiscal"
		Endif
		If "2" $ cEscopoExc
			if !Empty(cMensagem)
				cMensagem += "/"
			endif
			cMensagem += "Contábil"
		endif
		If "1" $ cEscopoExc .Or. "2" $ cEscopoExc
			cMensagem += CRLF
			If empty( cFilTaf )
				cMensagem += "Esse processo excluirá todos os registros contidos no período e escopo(s) selecionados."
			Else
				cMensagem += "Esse processo excluirá todos os registros da filial " + cFilTaf + ", eventos " + StrTran(cRegs,';', ' e ' ) + " que não foram transmitidos ao Fisco."
			EndIf
		Endif
		If "3" $ cEscopoExc
			if !Empty(cMensagem)
				cMensagem += CRLF+CRLF
			endif
			cMensagem += "eSocial"
			cMensagem += CRLF+"Empresa operando em "
			If cAmbEsocial == '1' //1-Produção
				cMensagem += "Produção"
			ElseIf cAmbEsocial == '2' //2-Pré Produção - Dados Reais
				cMensagem += "Pré Produção - Dados Reais"
			ElseIf cAmbEsocial == '3' //3-Pré Produção - Dados Fictícios
				cMensagem += "Pré Produção - Dados Fictícios"
			EndIf
			cMensagem += CRLF
			cMensagem += "Esse processo excluirá todos os registros "
			If cAmbEsocial == '1' //1-Produção
				cMensagem += "não transmitidos "
			EndIf
			cMensagem += "das tabelas de movimentação do eSocial desconsiderando o período de data."
			cMensagem += CRLF+CRLF
		EndIf
		If "4" $ cEscopoExc
			if !Empty(cMensagem)
				cMensagem += CRLF+CRLF
			endif
			cMensagem += "Reinf"
			cMensagem += CRLF+"Empresa operando em "
			If cAmbReinf == '1' //1-Produção
				cMensagem += "Produção"
			ElseIf cAmbReinf == '2' //2-Pré Produção - Dados Reais
				cMensagem += "Pré Produção - Dados Reais"
			ElseIf cAmbReinf == '3' //3-Pré Produção - Dados Fictícios
				cMensagem += "Pré Produção - Dados Fictícios"
			EndIf
			cMensagem += CRLF
			cMensagem += "Esse processo excluirá todos os registros "
			If cAmbReinf == '1' //1-Produção
				cMensagem += "não transmitidos "
			EndIf
			cMensagem += "para o TOP Alias: " + FWGetTopInfo()[5] 
			cMensagem += " das tabelas espelho do Reinf desconsiderando o período de data."
			cMensagem += CRLF+CRLF
		EndIf
		cMensagem += "Deseja continuar?"

		If lAuto .Or. lSkipAlert
			lProc := .T.
		Else
			If Aviso("Exclusão ", cMensagem, {"Sim","Não"}, 3) == 1
				lProc := .T.
			EndIf 
		EndIf

		If lProc
			If !lAuto .And. !lSkipAlert
				oProcessFil:Set1Progress( Len(aLisFil) )
			EndIf
			
			// Loop pelas filiais selecionadas
			For nFilSel := 1 To Len(aLisFil)
				
				If aLisFil[ nFilSel , 1 ]
					
					//cFilSel := aLisFil[nFilSel][2]
					SM0->( MsSeek( cEmpAnt + aLisFil[ nFilSel , 2 ] , .T. ) )
					cFilAnt	:=	FWGETCODFILIAL
					If !lAuto .And. !lSkipAlert
						oProcessFil:Inc1Progress( "Empresa/Filial " +  cEmpAnt +"/"+ aLisFil[ nFilSel , 2 ] )
						oProcessFil:Set2Progress( 4 )
					EndIf
					
					//Executa para os Tres Escopos - 1 - Fiscal, 2-Contabil, 3-eSocial
					For nlI := 1 to 4
						If !lAuto .And. !lSkipAlert
							if nlI == 1
								oProcessFil:Inc2Progress( "Fiscal" )
							elseif nlI == 2
								oProcessFil:Inc2Progress( "Contábil" )
							elseif nlI == 3
								oProcessFil:Inc2Progress( "eSocial" )
							elseif nlI == 4
								oProcessFil:Inc2Progress( "Reinf" )
							endif
						EndIf
						
						//Quando o parametro de filial estiver preenchido significa que a chamada foi realizada 
						//pelo SIGAGPE e assim não preciso executar o processamento para os escopos FISCAL e CONTÁBIL
						if  nlI <> 3 .and. !empty( cFilTaf ) 
							Loop
						endif
					
						// Obtém as movimentações passíveis de exclusão
						aMovExc := TAFMovExc(cEscopoExc, nlI )
					

						//Adiciona tratativa para selecionar corretamente os registro que devem ser excluídos
						//de acordo com o escopo selecionado pelo usuário
						//Escopo 3 E-Social - todos os registros devem ser excluídos
						//Escopo 4 REINF - todos os registros das tabelas espelho devem ser excluídos
						lESoc	:=	nlI = 3 .AND. ( "3" $ cEscopoExc )
						lReinf	:=	nlI = 4 .AND. ( "4" $ cEscopoExc )

						// Loop pelas movimentações
						For nI := 1 to Len( aMovExc )
							
							//Quando se tratar do eSocial o cliente deve informar quais eventos
							//deseja apagar na base de dados 
							If !Empty(cFilTaf)
								if nlI == 3 .and. !( aMovExc[nI,4] $ cRegs)
									Loop
								endif
							EndIf
							
							//Adiciona tratativa para selecionar corretamente os registro que devem ser excluídos
							//de acordo com o escopo selecionado pelo usuário
							//Escopo 1 Fiscal - apenas os registro que possuem campo de período são excluídos (movimento)
							//Escopo 2 Contábil - apenas os registro que possuem campo de período são excluídos (movimento)
							lFiscal	:=	nlI = 1 .AND. ( "1" $ cEscopoExc ) .AND. !empty( aMovExc[nI,6] )
							lContab	:=	nlI = 2 .AND. ( "2" $ cEscopoExc ) .AND. !empty( aMovExc[nI,6] )
							
							if lFiscal .OR. lContab .OR. lESoc .OR. lReinf 
							
								cLayout   := aMovExc[nI,4]
								cAlias    := aMovExc[nI,3]
								cAlias2   := aMovExc[nI,3] + "_2"
								cCampoInt := aMovExc[nI,6]
								cRegEsc   := aMovExc[nI,5]
								cRotinaModelo := aMovExc[nI,1]
								
								//Exceções que não devem ser excluidas
								If cAlias $ 'C1E|C9F|C9A|CM7|CMW|C9Z|CEL'
									Loop
								Endif
									
								If  nlI == 3 
									cTpEvento := aMovExc[nI,12]
									 IF (cTpEvento == "T" .And. cAmbEsocial == '1')
										Loop
									EndIf
								EndIf	

								If TAFAlsInDic( cAlias )

									// Monta query para obter os ID dos registros que serão excluídos
									cQuery := "SELECT " + cAlias + ".R_E_C_N_O_ REGREC "
									cQuery += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
									cQuery += "WHERE D_E_L_E_T_ = '' " 

									//cQuery += "  AND " + cAlias + "_FILIAL = '" + cFilSel + "'"
									cQuery += "  AND " + cAlias + "_FILIAL = '" + xFilial( cAlias ) + "'"
									if nlI == 4 .and. cAmbReinf = '1'
										cQuery += "  AND " + cAlias + "_STATUS NOT IN ('2','4','6','7') "
									endif

									//Quando se tratar dos registros do eSocial não se deve verificar as datas, todos os registros
									//não transmitidos da tabela devem ser apagados
									If nlI <> 3 .And. nlI <> 4 //Fiscal e Contabil

										if TAFColumnPos(cAlias + '_STATUS')
											cQuery += "  AND " + cAlias + "_STATUS IN ('0','1','') "
										endif	

										If !Empty(cCampoInt) .and. GetSX3Cache(cCampoInt,'X3_TIPO') == 'C'
											cPerIni := substr(dDtIni,5,2) + substr(dDtIni,1,4) 
											cPerFin := substr(dDtFin,5,2) + substr(dDtFin,1,4) 
											cQuery += "  AND " + cCampoInt + " >= '" + cPerIni + "' AND " + cCampoInt + "<= '" + cPerFin + "' "	
										ElseIf !Empty(cCampoInt) .and. GetSX3Cache(cCampoInt,'X3_TIPO') == 'D'
											cQuery += "  AND " + cCampoInt + " BETWEEN '" + dDtIni + "' AND '" + dDtFin + "' "							
										Endif
									//No caso do eSocial devemos verificar se existem registros já transmitidos na tabela, se
									//sim não devemos realizar a exclusão de nenhuma informação
									ElseIf nlI == 3 //eSocial								    

										//Na tabela C1G - Processo limpa somente os registros ref. ao eSocial
										//Verificado pelo campo C1G_ESOCIA = 'S' 								    
										If cAlias == 'C1G'
											cQuery += " AND " + cAlias + "_ESOCIA = '1' "
										EndIf

										If cAmbEsocial == '1' //1-Produção
											cQuery += "  AND " + cAlias + "_STATUS NOT IN ('2','4','6','7') "
										Endif

										If cAlias $ "C9V|C91|"
											cQuery += "  AND " + cAlias + "_NOMEVE = '"+StrTran(cLayout,"-","")+"' "
										endif

										//Se já foi transmitida não limpar								    								    
										// cQuery += " AND ( ( SELECT COUNT(*) FROM " + RetSqlName(cAlias) + " " + cAlias2
										// cQuery += "         WHERE " + cAlias2 + ".D_E_L_E_T_ = '' "
										// cQuery += "         AND " + cAlias2 + "." + cAlias + "_FILIAL = '" + xFilial( cAlias ) + "' "
										// cQuery += "         AND " + cAlias2 + "." + cAlias + "_STATUS IN ('2','3','4') ) = 0 ) "

									EndIf
										
									cAliasQry := "MOVEXC"
									
									cQuery := ChangeQuery(cQuery)
									TcQuery cQuery New Alias &cAliasQry
									
									//Alimenta o Array de Retorno da função
									if (cAliasQry)->(Eof())
										aAdd( aRet, { cLayout, .F. } )
									else
										aAdd( aRet, { cLayout, .T. } )
									endif
									
									// Loop pelos ID retornados
									While (cAliasQry)->(!Eof())
										cRegREC := (cAliasQry)->REGREC
										
										// Adiciona ao array de registros que serão excluídos
										aAdd(aRegExc, {cLayout, cAlias, cRegREC, cRegEsc, cRotinaModelo})
							
										(cAliasQry)->(DBSkip())
									EndDo
									
									(cAliasQry)->(DBCloseArea())
								Endif
							endif	
						Next nI
					next nlI

					If !lAuto .And. !lSkipAlert
						oProcessFil:Inc2Progress( "Complemento de Empresa" )
					EndIf

					If lAuto .Or. ( "3" $ cEscopoExc .And. cAmbEsocial <> '1' .And. lLimpaC1E ) //1-Produção
						aArea := GetArea()
						
						//Atualiza a tabela de Complemento de Empresa
						C1E->( dbSetOrder(3) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
						If C1E->( MsSeek(xFilial("C1E")+cFilAnt+"1" ) )
							TAFConOut( "Atualização C1E: C1E_ID / C1E_FILTAF / C1E_CODFIL " + C1E->( C1E_ID +"/"+ C1E_FILTAF +"/"+ C1E_CODFIL ), 1, .T., "EXCPER" )
							oModel050 := FWLoadModel("TAFA050")
							oModel050:SetOperation(4)
							oModel050:Activate()
							oModel050:LoadValue( 'MODEL_C1E', 'C1E_VERSAO', xFunGetVer() )
							oModel050:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "I" )
							FWFormCommit( oModel050 )
							TAFConOut( Space(5) + "Versão alterada via modelo", 1, .F., "EXCPER" )
							oModel050:DeActivate()

							dbSelectArea("C1E")
							RecLock("C1E", .F.)
							C1E->C1E_STATUS := " "
							C1E->C1E_PROTUL := " "
							C1E->C1E_PROTPN := " "
							MsUnLock()
							TAFConOut( Space(5) + "Limpeza de status e protocolos", 1, .F., "EXCPER" )
						EndIf

						RestArea( aArea )
					Endif
				
				EndIf
			Next nFilSel

			// Executa rotina de exclusão dos registros
			//oProcess := TAFProgress():New( { |lEnd| TAFExcReg(@lEnd, @oProcess, aRegExc, , ,cFilTaf ) }, "Processando exclusão" )
			If !lAuto .And. !lSkipAlert
				oProcess := TAFProgress():New( { |lEnd| TAFExcReg2(@lEnd, @oProcess, aRegExc,lSkipAlert, ("3" $ cEscopoExc .And. cAmbEsocial <> '1'), ("4" $ cEscopoExc .And. cAmbReinf == '1')) }, "Processando exclusão", .F. )
				oProcess:Activate()
			Else
				if lAuto
					lSkipAlert := .T.
					aAdd( aRegExc, {' ', ' ', ' ', ' ', ' '} )
				endif
				TAFExcReg2(, @oProcess, aRegExc,lSkipAlert, ("3" $ cEscopoExc .And. cAmbEsocial <> '1'), ("4" $ cEscopoExc .And. cAmbReinf == '1'))
			EndIf
		EndIf 
	EndIf

EndIf

//Restauro a filial que estava logado no inicio do processo
SM0->( MsSeek( aEmpAux[ 1 , 1 ] + aEmpAux[ 1 , 2 ] , .T. ) )
cFilAnt	:=	FWGETCODFILIAL

// Encerra os arrays utilizados durante o processamento
TAFEncArr(@aMovExc)
TAFEncArr(@aRegExc)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFEncArr
                       
Função que encerra o Array passado como parâmtro.  

@return NIL

@author Anderson Costa
@since 11/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFEncArr(aArray)

If Len(aArray) > 0
	aSize(aArray, 0)
	aArray := Nil
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMovExc
                       
Função que retorna um Array com todas as rotinas de movimentos que 
 temos no TAF e são passíveis de exclusão.  

@param 	cEscopo - Escopos que devem ser retornados
		nOpc    - 1 Fiscal, 2 - COntabil, 3-eSocial

@return NIL

@author Anderson Costa
@since 11/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFMovExc(cEscopo, nOpc)

// Estrutura do array: 
// Registro - Alias da tabela Pai - Campo referente ao início - Fonte - Escopo - Índice do ID
Local aRet	:= {}

//Escopo Fiscal
if nOpc == 1			 			
	//verifica se o cliente solicitou o Escopo Fiscal
	if "1" $ cEscopo
		aRet := TAFRotinas( , , , 1 )
	endif

//Escopo Contábil
elseif nOpc == 2

	//verifica se o cliente solicitou o Escopo Contabil
	if "2" $ cEscopo
		aRet := TAFRotinas( , , , 3 )
	endif

//Escopo eSocial	
elseif nOpc == 3
	
	//verifica se o cliente solicitou o Escopo eSocial
	if "3" $ cEscopo
		aRet := TAFRotinas( , , , 2 )
	endif
elseif nOpc == 4
	if "4" $ cEscopo
		aRet := TAFRotinas( , , , 5 )
	endIf		
endif


Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} TAFLayDef()
@author Alexandre Inacio Lemes
@since 09/04/2014
@version 1.0
*/ 
//-------------------------------------------------------------------   
Function TAFLayDef( cLayInteg, lJob )

Local aOrdDel   	:= {}
Local cLayOut   	:= ""
Local cLine     	:= ""
Local nPosZ4    	:= 0 
Local lNewLayOut	:= .F.
Local aModel    	:= {}
Local oModel    	:= Nil
Local lFaz			:= .T. 
Local lLayUnic		:= .F.
Local cFile		:=	TAFLayout()

Default cLayInteg	:= ""
Default lJob := .F.

aLayDef := {}
aDelLay := {}

If file( cFile )
	
	FT_FUSE(cFile)
	FT_FGotop()
	
	// -------------------------------------------------
	// Carregamento de layout Total  
	// -------------------------------------------------
	While (!FT_FEof())
		
		cLine := AllTrim(Upper(FT_FREADLN()))

		// ----------------------------------------------------
		// Verifica se quero fazer a carga de um Layout unico 
		// ----------------------------------------------------
		If !Empty(cLayInteg) .AND. !lLayUnic
			lFaz := .F. 
					
			If !lFaz .AND. ( "["+cLayInteg $ cLine )
				lFaz := .T. 
				lLayUnic := .T. 
			EndIf
			
		// ------------------------------------------------
		// Verifica se é o fim da carga do Layout unico
		ElseIf lLayUnic .AND. "###"$cLine
			If Len(aOrdDel) > 0
				aSort( aOrdDel ,,, { |x,y| PadR(x[1],6) > PadR(y[1],6) } )
				aDelLay[Len(aDelLay)][Len(aDelLay[Len(aDelLay)])] := aOrdDel
			EndIf
			aOrdDel := {}
			Exit 
		EndIf 

		If lJob .Or. lFaz
			If lJob .Or. Substr(cLine,1,10) == "XZ1_LAYOUT"
				aadd(aLayDef,{Substr(cLine,12,8),"","","","","","",""})
				lNewLayOut:= .T.
				cLayOut := Substr(cLine,12,8)
				TAFConOut( "Carregando Layout TOTVS -->" +	cLayOut, 1, .T., "EXCPER" )
				if !lJob
				oModel  := FWLoadModel( cLayOut )
				aModel  := oModel:GetDependency()  
	 			else
					exit
				endif
	 		ElseIf Substr(cLine,1,8) == "XZ1_DESC"
				aLayDef[Len(aLayDef)][Z1_DESC]  := Substr(cLine,10,50)
			ElseIf Substr(cLine,1,9) == "XZ1_ADAPT"
				aLayDef[Len(aLayDef)][Z1_ADAPT] := Substr(cLine,11,10)
			ElseIf Substr(cLine,1,9) == "XZ1_TABLE"
				aLayDef[Len(aLayDef)][Z1_TABLE] := Substr(cLine,11,3)
			ElseIf Substr(cLine,1,10) == "XZ1_DESTAB"
				aLayDef[Len(aLayDef)][Z1_DESTAB]:= Substr(cLine,12,40)
			ElseIf Substr(cLine,1,9) == "XZ1_ORDER"
				aLayDef[Len(aLayDef)][Z1_ORDER] := Substr(cLine,11,1)
			ElseIf Substr(cLine,1,10) == "XZ1_MVCOPT"
				aLayDef[Len(aLayDef)][Z1_MVCOPT]:= Substr(cLine,12,1)     
			ElseIf Substr(cLine,1,10) == "XZ1_MVCMET"
				aLayDef[Len(aLayDef)][Z1_MVCMET]:= Substr(cLine,12,1)
			EndIf
			
			If Substr(cLine,1,10) == "XZ2_CHANEL"
			
				lT001 := .F.
				lRegFilho := .F.
				If Len( aLayDef[ Len(aLayDef) ] ) == 8
					aadd(aLayDef[Len(aLayDef)],{ {"","","","","",""} } )
					
					//Tratamento para que quando se tratar do registro T001 seja criada a estrutura corretamente.
					If Len(aLayDef) == 6
						lT001 := .T.
					EndIf
				Else
					lRegFilho := .T.
				EndIf
				
				If 	lT001 .Or. lRegFilho
	
					aadd(aLayDef[Len(aLayDef)][Z1_CHANELS], {"","","","","","",""} )
	
					If lNewLayOut
						aadd(aDelLay , {Substr(cLine,12,20) , {Substr(cLine,12,20) , "" } } )
	 					aadd(aOrdDel , {Substr(cLine,12,20) , "" } )
						lNewLayOut := .F.
					Else
						aadd(aOrdDel , { Substr(cLine,12,20) , ""} )
					EndIf
		
				EndIf
	
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z2_CHANEL]:= Substr(cLine,12,20)
				
			ElseIf Substr(cLine,1,9) == "XZ2_SUPER"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z2_SUPER] := Substr(cLine,11,20)
			ElseIf Substr(cLine,1,10) == "XZ3_CHANEL"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z3_RELAC] := Substr(cLine,12,20)
			ElseIf Substr(cLine,1,8) == "XZ3_DESC"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z3_DESC]  := Substr(cLine,10,50)
			ElseIf Substr(cLine,1,9) == "XZ3_IDOUT"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z3_IDOUT] := Substr(cLine,11,15)
	
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z3_RELAC] := TafGetRel( aModel , Substr(cLine,11,15) , .F. ) 
	
				If Len(aLayDef[Len(aLayDef)][Z1_CHANELS]) > 1
					aOrdDel[Len(aOrdDel),2] := Substr(cLine,17,3)
				EndIf
		
			ElseIf SubStr( cLine, 1, 10 ) == "XZ3_OCCURS"
				aLayDef[Len( aLayDef )][Z1_CHANELS][Len( aLayDef[Len( aLayDef )][Z1_CHANELS] )][Z3_OCCURS] := SubStr( cLine, 12, 1 )
			ElseIf Substr( cLine, 1, 9 ) == "XZ3_ORDER"
				aLayDef[Len( aLayDef )][Z1_CHANELS][Len( aLayDef[Len( aLayDef )][Z1_CHANELS] )][Z3_ORDER] := SubStr( cLine, 11, 1 )
			EndIf

			If Substr(cLine,1,7) == "XZ4_SEQ"
				If Len( aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])]) == 7
					aadd( aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])] ,{ {"","","","","",""} } )
				Else
					aadd( aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS], {"","","","","",""} )
				EndIf
	
				nPosZ4 := Len(aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef)][Z1_CHANELS])][Z3_FIELDS]) 
	
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_SEQ]:= Substr(cLine,9,3)
			ElseIf Substr(cLine,1,9) == "XZ4_FIELD"                                                     
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_FIELD]:= Substr(cLine,11,10)
			ElseIf Substr(cLine,1,8)  == "XZ4_DESC"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_DESC]:= Substr(cLine,10,50)
			ElseIf Substr(cLine,1,10) == "XZ4_TYPFLD"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_TYPFLD]:= Substr(cLine,12,1)
			ElseIf Substr(cLine,1,10) == "XZ4_SOURCE"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_SOURCE]:= Substr(cLine,12,40)
			ElseIf Substr(cLine,1,8)  == "XZ4_EXEC"
				aLayDef[Len(aLayDef)][Z1_CHANELS][Len(aLayDef[Len(aLayDef),Z1_CHANELS])][Z3_FIELDS][nPosZ4][Z4_EXEC]:= Substr(cLine,10,250)
			EndIf
			
		EndIf 
		
		FT_FSKIP()

		cLine := AllTrim(FT_FREADLN())
		If Len(aOrdDel) > 0
			If ( Substr(cLine,1,10) == "XZ1_LAYOUT" .And. !Empty(cLayOut) .And.  cLayOut <> Substr(cLine,12,8) ) .Or. FT_FEof()  
				aSort( aOrdDel ,,, { |x,y| PadR(x[1],6) > PadR(y[1],6) } )
				aDelLay[Len(aDelLay)][Len(aDelLay[Len(aDelLay)])] := aOrdDel
				aOrdDel := {}
	        EndIf
	    EndIf
        
	EndDo
	
	FT_FUse()
	
	If FErase( cFile ) < 0
		Aviso( "Atenção", "Falha para apagar o arquivo: " + cFile + "." + Chr( 13 ) + Chr( 10 ) + "Código do erro: " + AllTrim( Str( FError() ) ) + Chr( 13 ) + Chr( 10 ) + "Mais informações: http://tdn.totvs.com/display/tec/FError", { "Fechar" }, 3 )
	EndIf	
EndIf

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} TafGetRel()
Funcao recursiva de apoio a funcao LoadLayOut buscar o relacionamento 
do canal atraves do MODELO passado pela LoadLayOut()

@param aModel, cModelo, lEnd
@return aRetorno = Relacionamento do Canal

@author Alexandre Inacio Lemes
@since 07/05/2014
@version 1.0
*/ 
//-------------------------------------------------------------------   
Static Function TafGetRel( aModel , cModelo , lEnd ) 

Local aRetorno := {}
Local n1       := 0

For n1 := 1 to Len(aModel)
   If aModel[n1][2] == cModelo
      aRetorno := aModel[n1][3]:GetRelation()[1]
	  lEnd := .T.	
      Exit
   Else	
	  If Len(aModel[n1][4])	> 0     
       	aRetorno := TafGetRel( aModel[n1][4] , cModelo , @lEnd )
		If lEnd
			Exit
		EndIf	
      EndIf
   EndIf
Next n1

Return( aRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFilhoLay
                       
Função que retorna os alias dos registros filhos do layout informado.  

@return aRet - Campos:
		aRet[1] - Alias do registro filho

@author Anderson Costa
@since 11/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFilhoLay( cLayout, aLayOut )

Local nI, nJ		:= 0
Local aRet			:= {}	// Array com os alias dos registros filhos
Local cFilho		:= ""	// Guarda o alias do registro filho
Local lLocReg		:= .F. // Sinaliza que localizou o layout pai (cLayout)

If !Empty( aLayOut )
	aLayDef := aClone( aLayOut )
	
	If !Empty(cLayout)
	
		// Loop pelos layouts
		For nI := 1 to Len( aLayDef )
			lLocReg := .F.
			
			// Loop pelos registros filhos de um layout pai 
			For nJ := 1 to Len( aLayDef[nI,9] ) 
				
				If aLayDef[nI,9,nJ,1] == cLayout
					
					lLocReg := .T.
					
				EndIf
	
				If nJ > 2 .And. lLocReg
				
					// Obtém o alias e adiciona ao array
					cFilho := Substr(aLayDef[nI,9,nJ,5],7,3)
					aAdd(aRet, cFilho)
				
				EndIf
				
			Next nJ
		Next nI
	endif
	
//Caso esteja vazio significa que estamos excluíndo os eventos do e-Social e assim devemos tratar
//nesse ELSE ( Sem se Basear no Layout.def )
else
	if cLayout == 'S-1000'
		aAdd(aRet, 'CRM')
		aAdd(aRet, 'T07')
		aAdd(aRet, 'T08')
			
	elseif cLayout == 'S-1020'
		aAdd(aRet, 'T03')
		
	elseif cLayout == 'S-1030'
		aAdd(aRet, 'T10')
		aAdd(aRet, 'T11')
	
	elseif cLayout == 'S-1050'
		aAdd(aRet, 'CRL')
		
	elseif cLayout == 'S-1060'
		aAdd(aRet, 'T09')
	
	endif	
endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExcReg
                       
Rotina de exclusão dos registros contidos no array.  

@param	lEnd		-> Verifica se a operacao foi abortada pelo usuario
		oProcess	-> Objeto da barra de progresso da emissao do ECF
		aPar		-> Campos:
						aPar[1] - Layout
						aPar[2] - Alias
						aPar[3] - Recno do registro
						aPar[4] - Escopo do registro
		aLayout	->
		lJob		->
		cFilTaf	->

@return NIL

@author Anderson Costa
@since 11/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFExcReg( lEnd, oProcess, aPar, aLayOut, lJob, cFilTaf, lExcluiu )

// Dados do array aPar
Local cRegLayout	:=	""
Local cAlias		:=	""
Local cRegREC		:=	""
Local cRegEsc		:=	""
Local cRegFil		:=	""

Local nI, nJ		:=	0
Local cRegID		:=	""
Local cCampoID		:=	""
Local cChvNF		:=	"C20|C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3A|C3F|C3G|C3H|C3I|C6W|C7B|CAI|CH1|CH2|"
Local nIndice		:=	0
Local nProgress1	:=	0
Local aRegFilho	:=	{}

Default aLayOut		:=	{}
Default lJob		:=	.F.
Default cFilTaf		:=	""
Default lExcluiu	:=	.f.

//Quando se trata de uma integração do eSocial não preciso carregar o Layout.def
If Empty( aLayOut ) .And. Empty( cFilTaf )
	// Carrega o layout.def
	TAFLayDef()
EndIf

If !lJob 
	// Zera contador de registros excluídos
	nQtdReg := 0

	//Alimenta a variável de controle da barra de status do processamento
	For nI := 1 To Len(aPar)
		nProgress1++
	Next nI

	nProgress1 := nProgress1 + 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )
EndIf

// Loop pelos registros
For nI := 1 to Len(aPar)
	
	// Verifica se mudou o registro
	If aPar[nI,1] <> cRegLayout
		
		cRegLayout := aPar[nI,1]
		
		// Limpa o array de registros filhos 
		TAFEncArr(@aRegFilho)
		
		// Obtém os registros filhos, se houverem
		aRegFilho := {}
		aRegFilho := TAFilhoLay( cRegLayout, Iif( !Empty( aLayOut ), aLayOut, aLayDef ) )
		
	EndIf
	
	cAlias  := aPar[nI,2]
	cRegREC := aPar[nI,3]
	cRegEsc := aPar[nI,4]
	
	DBSelectArea( cAlias )
	( cAlias )->( DBGoTo( cRegREC ) )

	if empty(cFilTaf) .or. alltrim(( cAlias )->&(cAlias+"_FILIAL")) == cFilTaf
		lExcluiu := .t.
		If cAlias $ cChvNF
			cCampoID := "_CHVNF"
		Else
			cCampoID := "_ID" 
		EndIf

		cRegFil := ( cAlias )->&( cAlias + "_FILIAL" )
		cRegID  := ( cAlias )->&( cAlias + cCampoID )

		If !lJob
			oProcess:Inc1Progress( "Excluindo dados da tabela " + cAlias )
		EndIf
		
		//Primeiro exclui os filhos
		For nJ := 1 to Len( aRegFilho )

			If aRegFilho[nJ] $ cChvNF
				cCampoID := "_CHVNF"
			Else
				cCampoID := "_ID"
			EndIf

			//A funcao xFunIndID foi DESCONTINUADA, nao deve mais ser utilizada. Utilizar a TAFGetIdIndex - TAFXFUNDIC
			if findFunction( "TAFGetIdIndex" )
				nIndice := TAFGetIdIndex( aRegFilho[ nJ ] , cCampoID )
			else
				nIndice := Iif( cRegEsc == "1", xFunIndID( aRegFilho[nJ] ), 1 )
			endif

			If nIndice <> 0
				( aRegFilho[nJ] )->( DBSetOrder( nIndice ) ) //FILIAL + ID
				If ( aRegFilho[nJ] )->( MsSeek( cRegFil + cRegID ) )
					While ( aRegFilho[nJ] )->( !Eof() ) .and. ( aRegFilho[nJ] )->&( aRegFilho[nJ] + "_FILIAL" ) == cRegFil .and. ( aRegFilho[nJ] )->&( aRegFilho[nJ] + cCampoID ) == cRegID
						RecLock( aRegFilho[nJ], .F. )
						( aRegFilho[nJ] )->( DBDelete() )
						( aRegFilho[nJ] )->( MsUnlock() )
		
						nQtdReg ++
		
						( aRegFilho[nJ] )->( DBSkip() )
					EndDo
				EndIf
			Endif
		Next nJ

		//Em seguida, exclui o pai
		If !( ( cAlias )->( Eof() ) ) .And. cAlias <> "C1E"
			RecLock( cAlias, .F. )
			( cAlias )->( DBDelete() )
			( cAlias )->( MsUnlock() )
		EndIf

		nQtdReg ++
	endif
Next nI

If !lJob
	oProcess:Inc1Progress( "Foram excluídos " + AllTrim(Str(nQtdReg)) + " registros." )
	oProcess:Inc2Progress( "Clique em Finalizar" )
EndIf

If !Empty( aLayDef )
	TAFEncArr(@aLayDef)
EndIf

If !Empty( aDelLay )
	TAFEncArr(@aDelLay)
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFExcReg2
                       
Rotina de exclusão dos registros pais contidos no array considerando o 
modelo MVC para exclusão dos registros filhos

@param	lEnd			-> Verifica se a operacao foi abortada pelo usuario
		oProcess		-> Objeto da barra de progresso da emissao do ECF
		aPar			-> Campos:
							aPar[1] - Layout
							aPar[2] - Alias
							aPar[3] - Recno do registro
							aPar[4] - Escopo do registro
							aPar[5] - Rotina/Modelo MVC do layout
		lJob			-> Se esta sendo executado via Job
		lLimpaStatus	-> Força a limpeza dos status antes da exclusão

@return NIL

@author Felipe Rossi Moreira
@since 18/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFExcReg2( lEnd, oProcess, aPar, lJob, lLimpaStatus, lLimReinf,  cXERPAlias, lVldChvFort, lErrorMsg )

// Dados do array aPar

Local cRegLayout	:=	""
Local cRotinaModelo	:=	""
Local cAlias		:=	""
Local cRegREC		:=	""
Local cRegFil		:=	""

Local nI			:=	0
Local cFilBkp		:=  cFilAnt
Local cRegID		:=	""
Local cCampoID		:=	""
Local cChvNF		:=	"C20|C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3A|C3F|C3G|C3H|C3I|C6W|C7B|CAI|CH1|CH2|"
Local cStatsDel		:=	"|4|2|6|7|"
Local cV48			:=  ""

Local oModel
Local lModelOk		:= .F.
Local lDeleReinf	:= .T.

Default lJob		 :=	.F.
Default lLimpaStatus := .F.
Default	lLimReinf	 := .F.
Default	lVldChvFort  := .F.
Default	lErrorMsg 	 := .F.
Default	cXERPAlias	 := "" 
If !lJob 
	// Zera contador de registros excluídos
	nQtdReg := 0

	//Alimenta a variável de controle da barra de status do processamento
	oProcess:Set1Progress( Len(aPar) )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )
EndIf

// Loop pelos registros
For nI := 1 to Len(aPar)
	
	// Verifica se mudou o modelo/layout
	If (len(aPar[nI]) > 4) .and. aPar[nI][5] <> cRotinaModelo
		
		cRegLayout := aPar[nI][1]
		cRotinaModelo := aPar[nI][5]

		if lModelOk
			oModel:Destroy()
		endif
		if !empty(cRotinaModelo)
		oModel := FWLoadModel(cRotinaModelo)
		lModelOk := (Valtype(oModel) <> "U")		
		endif
		TAFConOut( "Exclusão via Modelo/Layout: " + cRotinaModelo+"/"+cRegLayout + If(lModelOk,""," *** modelo NÃO carregado"), 2, .T., "EXCPER" )
	EndIf

	cAlias  := aPar[nI][2]
	cRegREC := aPar[nI][3]

	if !empty(cAlias)
	DBSelectArea( cAlias )
	( cAlias )->( DBGoTo( cRegREC ) )

	cCampoID := if(cAlias $ cChvNF, "_CHVNF", "_ID") 
	cRegFil := ( cAlias )->&( cAlias + "_FILIAL" )
	cRegID  := ( cAlias )->&( cAlias + cCampoID )
	endif
	TAFConOut( Space(5) + cAlias + " | Fil/ID: " + cRegFil + "/" + allTrim( cRegID ), 1, .T., "EXCPER" )
	SM0->(MsSeek( cEmpAnt + cRegFil, .T.))
	cFilAnt	:=	FWGETCODFILIAL
	
	If !lJob
		oProcess:Inc1Progress( "Excluindo dados da tabela " + cAlias ) 
	EndIf
	If lLimReinf
		lDeleReinf :=  !(( cAlias )->&( cAlias+"_STATUS") $ cStatsDel) 
	EndIf
	//Se o modelo for carregado
	If lModelOk .And. lDeleReinf
		If ( cAlias )->( !Eof() )
			if lLimpaStatus
				RecLock( cAlias, .F. )
				( cAlias )->&( cAlias+"_STATUS" ) := " "
				( cAlias )->( MsUnlock() )
			endif
			oModel:SetOperation(5)
			oModel:Activate()
			if !lVldChvFort .or. empty(cXERPAlias) .or. (len(aPar[nI]) <= 4)
				If !lErrorMsg .And. oModel:VldData(oModel:cId,.F.)
					If !lJob .And. oModel:CommitData()						
						cV48 := Iif(cAlias == "V0S",cAlias + "->" + cAlias + "_PERAPU" + "|" + cAlias + "->" + cAlias + "_TPINSC" + "|" + cAlias + "->" + cAlias + "_NRINSC", "")
						if TAFColumnPos( cAlias + "_PROCID" )
							TAFLimpId( cAlias, cAlias + "->" + cAlias + "_PROCID", cRotinaModelo, "", cV48 )
						endif
						nQtdReg ++
					Else
						TAFConOut( Space(5)+Space(5) + "Erro ao Executar o Commit", 2, .T., "EXCPER" )
					EndIf
				Else
					TAFConOut( Space(5)+Space(5) + AllTrim(oModel:GetErrorMessage()[6]), 2, .T., "EXCPER" )
				EndIf
			else
				if oModel:VldData() // Valida integridade de dados, tabela chave estrangeira que possui vinculo com outra tabela Ex: T003 x T013. T003 só pode ser excluído se não houver nota com o determinado participante
					If oModel:CommitData()//FWFormCommit()
						( cXERPAlias )->( DBGoTo( aPar[nI,6] ))
						TafGrvTick( cXERPAlias, "2",,,,, "3" )
						TafExcHist(cXERPAlias)
						nQtdReg ++
					Else
						cMsg := "Erro ao Executar o Commit"
						( cXERPAlias )->( DBGoTo( aPar[nI,6] ))
						TafGrvTick( cXERPAlias, "1",( cXERPAlias )->TAFKEY, ( cXERPAlias )->TAFTICKET,cAlias,cRegREC, "9", "000004", cMsg, )
					EndIf
				else
					cMsg := oModel:GetErrorMessage()[6]
					( cXERPAlias )->( DBGoTo( aPar[nI,6] ))
					TafGrvTick( cXERPAlias, "1",( cXERPAlias )->TAFKEY, ( cXERPAlias )->TAFTICKET,cAlias,cRegREC, "9", "000004", cMsg, )
				endif	
			endif
			oModel:DeActivate()
		EndIf
	Endif
Next nI

If !lJob
	oProcess:Inc1Progress( "Foram excluídos " + AllTrim(Str(nQtdReg)) + " registros." )
	oProcess:Inc2Progress( "Concluído" )
	MsgInfo( "Foram excluídos " + AllTrim(Str(nQtdReg)) + " registros." )
EndIf

SM0->(MsSeek(cEmpAnt + cFilBkp, .T.))
cFilAnt := FWGETCODFILIAL

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TafExcHist
                       
Rotina de exclusão dos registros de histórico de exclusões erradas anteriores

@param	cXERPAlias	alias da TAFXERP

@return NIL

@author Henrique Pereira
@since 19/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TafExcHist(cXERPAlias)
Local cAliasQry	:=	getNextAlias()
Local	cSql := "SELECT * FROM TAFXERP WHERE TAFKEY = '" + (cXERPAlias)->TAFKEY + "' AND  TAFTICKET = '" + (cXERPAlias)->TAFTICKET + "'"
		cSql += " AND TAFSTATUS = 9 AND TAFCODERR = '000004' "

		cSql := ChangeQuery( cSql )
		TcQuery cSql New Alias &cAliasQry
	
	While (cAliasQry)->(!eof())
		( cXERPAlias )->( DBGoTo( (cAliasQry)->R_E_C_N_O_ ))
		RecLock( cXERPAlias, .F. )
		( cXERPAlias )->( DBDelete() )
		( cXERPAlias)->( MsUnlock() )		
		(cAliasQry)->(DBSkip())
	EndDo
	
	DbCloseArea()
Return()
