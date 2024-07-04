#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA090.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA090
Consulta do Espelho de Ponto

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA090()
	If !PosSRAUser()
		Return 
	EndIf

	If Pergunte("TCFA080", .T.)
		FWExecView(STR0001, "TCFA090", MODEL_OPERATION_VIEW)	//"Espelho de Ponto"
	EndIf
Return
/*
Function TCFA090()
	Local cPrimaryKey := "01000007" // Passar a chave primaria para localizar registro 
	// Chama o Formulario MVC já passando a chave primaria para busca
	oPortalMain:FWExecView(	"Espelho de Ponto",;
							"TCFA090",;
							MODEL_OPERATION_VIEW,;
						    //oDlg,;
						    //bCloseOnOk,;
						    //Uso Interno do Portal,;
						    cPrimaryKey)
Return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
			[n,1] Nome a aparecer no cabecalho
			[n,2] Nome da Rotina associada
			[n,3] Reservado
			[n,4] Tipo de Transação a ser efetuada:
				1 - Pesquisa e Posiciona em um Banco de Dados
				2 - Simplesmente Mostra os Campos
				3 - Inclui registros no Bancos de Dados
				4 - Altera o registro corrente
				5 - Remove o registro corrente do Banco de Dados
				6 - Alteração sem inclusão de registros
				7 - Cópia
				8 - Imprimir
			[n,5] Nivel de acesso
			[n,6] Habilita Menu Funcional

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd(aRotina, {STR0027,	"VIEWDEF.TCFA090",	0, 2, 0, NIL})		//"Visualizar"
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel:= MPFormModel():New("TCFA090")
	Local oStructSRA := FWFormStruct(1, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")})
	Local oStructChild := FWFormModelStruct():New()            
	oStructChild:addField(STR0002, STR0002, "DATA", "D", 10)		//"Data"
	oStructChild:addField(STR0003, STR0003, "DIA",  "C", 8)			//"Dia"
	oStructChild:addField(STR0004, STR0005, "ENT1", "C", 5)			//"1ª Ent."	//"1ª Entrada"
	oStructChild:addField(STR0006, STR0007, "SAI1", "C", 5)			//"1ª Sai."	//"1ª Saida"
	oStructChild:addField(STR0008, STR0009, "ENT2", "C", 5)			//"2ª Ent."	//"2ª Entrada"
	oStructChild:addField(STR0010, STR0011, "SAI2", "C", 5)			//"2ª Sai."	//"2ª Saida"
	oStructChild:addField(STR0012, STR0013, "ENT3", "C", 5)			//"3ª Ent."	//"3ª Entrada"
	oStructChild:addField(STR0014, STR0015, "SAI3", "C", 5)			//"3ª Sai."	//"3ª Saida"
	oStructChild:addField(STR0016, STR0017, "ENT4", "C", 5)			//"4ª Ent."	//"4ª Entrada"
	oStructChild:addField(STR0018, STR0019, "SAI4", "C", 5)			//"4ª Sai."	//"4ª Saida"
	oStructChild:addField(STR0020, STR0020, "OBS",  "C", 30)		//"Observacoes"

	
	oModel:AddFields("TCFA090_SRA", NIL, oStructSRA)

	oModel:AddGrid("TCFA090_TMP", "TCFA090_SRA", oStructChild, NIL, NIL, NIL, NIL, {|| Carga() } )
	oModel:GetModel("TCFA090_TMP"):SetDescription(STR0001)		//"Espelho de Ponto"
	
	oModel:SetPrimaryKey({"RA_MAT"})
Return(oModel)                                                                            


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da visualização de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView		 := FWFormView():New()
	Local oModel	 := FWLoadModel("TCFA090")
	Local oStructSRA := FWFormStruct(2, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")})
	Local oStructChild := FWFormViewStruct():New()
	oStructChild:addField("DATA", "01", STR0002, STR0002, NIL, "D", "@D")		//"Data"
	oStructChild:addField("DIA",  "02", STR0003, STR0003, NIL, "C", "")		//"Dia"
	oStructChild:addField("ENT1", "03", STR0004, STR0005, NIL, "C", "")		  //"1ª Ent."   "1ª Entrada"
	oStructChild:addField("SAI1", "04", STR0006, STR0007, NIL, "C", "")		  //"1ª Sai."   "1ª Saida"
	oStructChild:addField("ENT2", "05", STR0008, STR0009, NIL, "C", "")		  //"2ª Ent."   "2ª Entrada"
	oStructChild:addField("SAI2", "06", STR0010, STR0011, NIL, "C", "")		  //"2ª Sai."   "2ª Saida"
	oStructChild:addField("ENT3", "07", STR0012, STR0013, NIL, "C", "")		  //"3ª Ent."   "3ª Entrada"
	oStructChild:addField("SAI3", "08", STR0014, STR0015, NIL, "C", "")		  //"3ª Sai."   "3ª Saida"
	oStructChild:addField("ENT4", "09", STR0016, STR0017, NIL, "C", "")		  //"4ª Ent."   "4ª Entrada"
	oStructChild:addField("SAI4", "10", STR0018, STR0019, NIL, "C", "")		  //"4ª Sai."   "4ª Saida"
	oStructChild:addField("OBS",  "11", STR0020, STR0020, NIL, "C", "")		  //"Observação", 
	
	oStructSRA:aFolders:= {}
	
	oView:SetModel(oModel)
	oView:AddField("TCFA090_SRA", oStructSRA)   
	oView:AddGrid("TCFA090_TMP", oStructChild)
	
	oView:CreateHorizontalBox("HEADER", 10)
	oView:CreateHorizontalBox("ITEM", 90)      
	
	oView:SetOwnerView("TCFA090_SRA", "HEADER")
	oView:SetOwnerView("TCFA090_TMP", "ITEM")	
Return oView

Static Function Carga()
	Local aTabCalend:= {}, aTabPadrao:= {}
	Local aTabela	
	Local aMarcacoes:= {}
	Local aTurnos	:= {}
	Local dPerIni, dPerFim
	
	Pergunte("TCFA080", .F.)	

	//GetPonMesDat(@dPerIni, @dPerFim, SRA->RA_FILIAL )
	dPerIni:= MV_PAR01
	dPerFim:= MV_PAR02

	//dPerIni:= CToD("01/10/2009")
	//dPerFim:= CToD("31/10/2009")

	IF !GetMarcacoes(	@aMarcacoes					,;	//Marcacoes dos Funcionarios
						@aTabCalend					,;	//Calendario de Marcacoes
						@aTabPadrao					,;	//Tabela Padrao
						@aTurnos					,;	//Turnos de Trabalho
						dPerIni 					,;	//Periodo Inicial
						dPerFim						,;	//Periodo Final
						SRA->RA_FILIAL				,;	//Filial
						SRA->RA_MAT					,;	//Matricula
						NIL							,;	//Turno
						NIL							,;	//Sequencia de Turno
						SRA->RA_CC					,;	//Centro de Custo
						"SP8"						,;	//Alias para Carga das Marcacoes
						NIL							,;	//Se carrega Recno em aMarcacoes
						.T.							,;	//Se considera Apenas Ordenadas
					    .T.    						,;	//Se Verifica as Folgas Automaticas
					  	.F.    			 			 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
					 )
		Return {}
	EndIf
	
	aTabela:= MontaEspelho(aTabCalend, aMarcacoes, dPerIni, dPerFim)
		
Return aTabela



Static Function GetDayTypes()
	Local oTipoDia:= HashTable():New()
	oTipoDia:Add(" ", "")
	oTipoDia:Add("S", STR0021)		//"Ausente"
	oTipoDia:Add("N", STR0022)		//"Nao Trabalhado"
	oTipoDia:Add("D", STR0023)		//"D.S.R."
	oTipoDia:Add("C", STR0024)		//"Compensado"
Return oTipoDia


Static Function MontaEspelho(aTabCalend, aMarcacoes, dInicio, dFim)
	Local cTipAfas   := ""
	Local cDescAfas  := ""
	Local cOcorr     := ""
	Local cOrdem     := ""
	Local cTipDia    := ""
	Local dData      := Ctod("//")
	Local dDtBase    := dFim
	Local lFeriado   := .T.
	Local lTrabaFer  := .F.
	Local lAfasta    := .T.   
	Local nX         := 0
	Local nDia       := 0
	Local nMarc      := 0
	Local nLenMarc	 := Len( aMarcacoes )
	Local nTab       := 0
	Local nDias		 := 0 
	Local oTipoDia  := GetDayTypes()
	
	//-- Variaveis ja inicializadas.
	Local aEspelho := {}
	
	nDias := ( dDtBase - dInicio )
	For nDia := 0 To nDias
	
		//-- Reinicializa Variaveis.
		dData      := dInicio + nDia
		cOcorr     := ""
		cTipAfas   := ""
		cDescAfas  := ""
		cOcorr	   := ""
		//-- o Array aTabcalend ‚ setado para a 1a Entrada do dia em quest„o.
		IF ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == "1E" }) ) == 0.00
			Loop
		EndIF
	
		//-- o Array aMarcacoes ‚ setado para a 1a Marca‡„o do dia em quest„o.
		nMarc := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })
	
		//-- Consiste Afastamentos, Demissoes ou Transferencias.
		IF ( ( lAfasta := aTabCalend[ nTab , 24 ] ) .or. SRA->( RA_SITFOLH $ "DúT" .and. dData > RA_DEMISSA ) )
			lAfasta		:= .T.
			cTipAfas	:= IF(!Empty(aTabCalend[ nTab , 25 ]),aTabCalend[ nTab , 25 ],fDemissao(SRA->RA_SITFOLH, SRA->RA_RESCRAI) )
			cDescAfas	:= Capital( fDescAfast( cTipAfas, Nil, Nil, SRA->( RA_SITFOLH == "D" .and. dData > RA_DEMISSA ) ) )
		EndIF
	
		//Verifica Regra de Apontamento ( Trabalha Feriado ? )
		lTrabaFer := ( PosSPA( aTabCalend[ nTab , 23 ] , xFilial("SPA") , "PA_FERIADO" , 01 ) == "S" )
	
		//-- Consiste Feriados.
		IF ( lFeriado := aTabCalend[ nTab , 19 ] )  .AND. !lTrabaFer
			cOcorr := aTabCalend[ nTab , 22 ]
		EndIF
	
		//-- Ordem e Tipo do dia em quest„o.
		cOrdem  := aTabCalend[nTab,2]
		cTipDia := aTabCalend[nTab,6]
	
	    //-- Se a Data da marcacao for Posterior a Admissao
		IF dData >= SRA->RA_ADMISSA
			//-- Se Afastado
			If ( lAfasta  .AND. aTabCalend[nTab,10] <> "E" ) .OR. ( lAfasta  .AND. aTabCalend[nTab,10] == "E" .AND. !lImpExcecao )
				cOcorr := cDescAfas 
			//-- Se nao for Afastado
			Else                    
	
			    //-- Se tiver EXCECAO para o Dia  ------------------------------------------------
				If aTabCalend[nTab,10] == "E"			
			       //-- Se excecao trabalhada
			       If cTipDia == "S"  
			          //-- Se nao fez Marcacao
			          If Empty(nMarc)
						 cOcorr := STR0021	//"Ausente"
					  //-- Se fez marcacao	 
			          Else
			          	 //-- Motivo da Marcacao
		          		 If !Empty(aTabCalend[nTab,11])
						 	cOcorr := AllTrim(aTabCalend[nTab,11])
						 Else
						 	cOcorr := STR0025	//"Excecao nao Trabalhada"
						 EndIf
			          Endif	 
			       //-- Se excecao outros dias (DSR/Compensado/Nao Trabalhado)
			       Else
	 					//-- Motivo da Marcacao
			       		If !Empty(aTabCalend[nTab,11])
							cOcorr := AllTrim(aTabCalend[nTab,11])
						Else
							cOcorr := STR0025	//"Excecao nao Trabalhada"
						EndIf
				   Endif	
	
			    //-- Se nao Tiver Excecao  no Dia ---------------------------------------------------
			    Else
					If cTipDia == 'S' .and. !Empty(nMarc)
						cTipDia := ' '
					EndIf
					
			        //-- Se feriado 
			       	If lFeriado 
			       	    //-- Se nao trabalha no Feriado
			       	    If !lTrabaFer 
							cOcorr := If(!Empty(cOcorr), cOcorr, STR0026)	//"Feriado"
						//-- Se trabalha no Feriado
						Else
						    //-- Se Dia Trabalhado e Nao fez Marcacao						    
						    cOcorr:= oTipoDia:GetItem(cTipDia)						    
						Endif
			    	Else
			    	    //-- Se Dia Trabalhado e Nao fez Marcacao
						cOcorr:= oTipoDia:GetItem(cTipDia)				
					Endif	
			    Endif
			Endif
		Endif	    
				
		//-- Adiciona Nova Data a ser impressa.
		aAdd(aEspelho, {0, {}})
		aAdd(aEspelho[Len(aEspelho), 2], aTabCalend[nTab,1])
		aAdd(aEspelho[Len(aEspelho), 2], DiaSemana(aTabCalend[nTab,1]))
		
		//-- Marca‡oes ocorridas na data.
		If nMarc > 0
			While nMarc <= nLenMarc .and. cOrdem == aMarcacoes[nMarc,3]
				aAdd( aEspelho[Len(aEspelho), 2], StrTran(StrZero(aMarcacoes[nMarc,2],5,2),".",":"))
				nMarc ++
			End While
		EndIf
	
		ASize(aEspelho[Len(aEspelho), 2], 10)	
		aAdd(aEspelho[Len(aEspelho), 2], cOcorr)
	Next nDia

Return aEspelho


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewWebDef
Gera o XML para Web

@author Rogerio Ribeiro da Cruz
@since 29/06/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return oView:GetXML2Web(nOperation, cPk, cFormMVC)