#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_MOTIVO_DESLIGAMENTO	14
#DEFINE ANALITICO_RECIBO				15
#DEFINE ANALITICO_VALOR_DEP				16

Static __aRubrica	:= {}
Static __aCampos	:= {}
Static __oInsert	:= Nil
Static __lCanBulk	:= Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFSocialReport
@type			class
@description	Classe com funções utilizadas nos Relatórios de Conferências do eSocial ( INSS/IRRF/FGTS ).
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Class TAFSocialReport From LongClassName

	Data oVOReport
	Data aStructV3N
	Data nTamFilial

	Method New() Constructor
	Method Upsert()
	Method Delete()
	Method GetRubrica()

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
@type			method
@description	Retorna a instância do objeto.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self - Objeto para utilização nos relatórios totalizadores
/*/
//---------------------------------------------------------------------
Method New() Class TAFSocialReport

	self:oVOReport	:=	TAFVOReport():New()
	self:aStructV3N	:=	V3N->( DBStruct() )
	self:nTamFilial	:=	self:aStructV3N[aScan( self:aStructV3N, { |x| x[1] == "V3N_FILIAL" } ) ][3]

Return( self )

//---------------------------------------------------------------------
/*/{Protheus.doc} Upsert
@type			method
@description	Insere/atualiza um registro na tabela V3N.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cEvento	-	Código do Evento: S-1200|S-2299|S-2399|S-5001|S-5002|S-5003
@param			cOrigem	-	Origem da Gravação: 1=Folha|2=TAF|3=Governo-INSS|4=Governo-IRRF|5=Governo-FGTS
@param			cFilEvt	-	Filial do Evento
@param			oData	-	Objeto com os dados a ser inserido/atualizado
@param			lDelete	-	Indica se deve ser executado apenas a exclusão dos registros
/*/
//---------------------------------------------------------------------
Method Upsert(cEvento, cOrigem, cFilEvt, oData, lDelete) Class TAFSocialReport

	Local aAnalitico	:= {}
	Local aBulk			:= {}
	Local cMotDes		:= ""
	Local cNome			:= ""
	Local cProtocolo	:= ""
	Local cRecibo		:= ""
	Local cIndApu		:= ""
	Local cPerApu		:= ""
	Local cCPF			:= ""
	Local lRecibo       := .F.
	Local lVlrDep		:= TafColumnPos("V3N_VLRDEP")
	Local lMotDes		:= TafColumnPos("V3N_MOTDES")
	Local nAnalitico	:= 0
	Local nx 			:= 0
	Local nValorDep 	:= 0

	Default cEvento		:= ""
	Default cOrigem		:= ""
	Default	cFilEvt		:= ""
	Default lDelete		:= .F.
	Default oData		:= Nil

	If oData != Nil
		cNome	:= oData:GetNome()
		cRecibo	:= oData:GetRecibo()
		cIndApu	:= PadR(oData:GetIndApu(), GetSX3Cache("V3N_INDAPU", "X3_TAMANHO"))
		cPerApu	:= PadR(oData:GetPeriodo(), GetSX3Cache("V3N_PERAPU", "X3_TAMANHO"))
		cCPF	:= PadR(oData:GetCPF(), GetSX3Cache("V3N_CPF", "X3_TAMANHO"))
		cFilEvt := PadR(cFilEvt, self:nTamFilial)
		lRecibo := cOrigem $ '1|2' .And. Len(oData:aAnalitico) > 0 .And. (Len(oData:aAnalitico[1]) > 14 .And. oData:aAnalitico[1][15] <> Nil)
		cEvento := PadR(cEvento, GetSX3Cache("V3N_EVENTO", "X3_TAMANHO"))
		cOrigem := Padr(cOrigem, GetSX3Cache("V3N_ORIGEM", "X3_TAMANHO"))

		If lRecibo 
			For nx := 1 to len(oData:AANALITICO)
				self:Delete( cFilEvt , cIndApu , cPerApu , cCPF , cEvento , cOrigem  , oData:AANALITICO[nx][ANALITICO_RECIBO] , .F., lRecibo )
			Next 
		Else
			//Se existir dados para o FILIAL + INDAPU + PERAPU + CPF + EVENTO + ORIGEM então exclui, pois qualquer uma das informações do nível abaixo, pode ser alterada/exluída
			self:Delete( cFilEvt , cIndApu , cPerApu , cCPF , cEvento , cOrigem ,'', .F., lRecibo )
		EndIf 

		If !lDelete
			aAnalitico := oData:GetAnalitico()

			If __lCanBulk == Nil
				If FwLibVersion() >= "20201009" .And. TCGetBuild() >= "20181212"
					__lCanBulk := FwBulk():CanBulk()
				Else
					__lCanBulk := .F.
				EndIf
			EndIf

			If __lCanBulk
				If __oInsert == Nil
					__oInsert 	:= FwBulk():New(RetSQLName("V3N"))
					__aCampos 	:= {{"V3N_FILIAL"	},;
									{"V3N_ID"		},;
									{"V3N_INDAPU"	},;
									{"V3N_PERAPU"	},;
									{"V3N_CPF"		},;
									{"V3N_NOME"		},;
									{"V3N_MATRIC"	},;
									{"V3N_CATEG"	},;
									{"V3N_TPINSC"	},;
									{"V3N_NRINSC"	},;
									{"V3N_CODLOT"	},;
									{"V3N_EVENTO"	},;
									{"V3N_ORIGEM"	},;
									{"V3N_RECIBO"	},;
									{"V3N_NATRUB"	},;
									{"V3N_TPRUBR"	},;
									{"V3N_ITCP"		},;
									{"V3N_ITIRRF"	},;
									{"V3N_ITFGTS"	},;
									{"V3N_INDDEC"	},;
									{"V3N_TPVLR"	},;
									{"V3N_VALOR"	}}
					
					If lMotDes
						AAdd(__aCampos, {"V3N_MOTDES"})
					EndIf
					
					If lVlrDep
						AAdd(__aCampos, {"V3N_VLRDEP"})
					EndIf

					__oInsert:SetFields(__aCampos)
				EndIf

				For nAnalitico := 1 To Len(aAnalitico)
				
					If lRecibo
						cProtocolo := aAnalitico[nAnalitico][ANALITICO_RECIBO]
					Else
						cProtocolo := cRecibo
					EndIf

					aBulk := {	cFilEvt													,; 
								TAFGeraID("TAF")										,;
								cIndApu													,;
								cPerApu													,;
								cCPF													,;
								AllTrim(cNome)											,;
								AllTrim(aAnalitico[nAnalitico][ANALITICO_MATRICULA])	,;
								aAnalitico[nAnalitico][ANALITICO_CATEGORIA]				,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_ESTABELECIMENTO] 	,;
								aAnalitico[nAnalitico][ANALITICO_ESTABELECIMENTO]		,;
								aAnalitico[nAnalitico][ANALITICO_LOTACAO]				,;
								cEvento													,;
								cOrigem													,;
								AllTrim(cProtocolo)										,;
								aAnalitico[nAnalitico][ANALITICO_NATUREZA]				,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_RUBRICA]			,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_CP]			,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_IRRF]		,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_FGTS]		,;	
								aAnalitico[nAnalitico][ANALITICO_DECIMO_TERCEIRO]		,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_VALOR]			,;
								aAnalitico[nAnalitico][ANALITICO_VALOR]					}

					If lMotDes
						If Len(aAnalitico[nAnalitico]) >= 14 .And. ValType(aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]) != 'U'
							cMotDes := aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]
						Else
							cMotDes := ""
						EndIf

						AAdd(aBulk, cMotDes)
					EndIf					

					If lVlrDep
						nValorDep := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] ) == "U", 0, aAnalitico[nAnalitico][ANALITICO_VALOR_DEP])

						aAdd(aBulk, nValorDep)
					EndIf

					__oInsert:AddData(aBulk)
				Next
				
				__oInsert:Flush()
				__oInsert:Close()
			Else
				For nAnalitico := 1 To Len(aAnalitico)
					If RecLock("V3N", .T.)
						V3N->V3N_FILIAL	:= cFilEvt
						V3N->V3N_ID		:= TAFGeraID("TAF")
						V3N->V3N_INDAPU	:= cIndApu
						V3N->V3N_PERAPU	:= cPerApu
						V3N->V3N_CPF	:= cCPF
						V3N->V3N_NOME	:= cNome
						V3N->V3N_MATRIC	:= aAnalitico[nAnalitico][ANALITICO_MATRICULA]
						V3N->V3N_CATEG	:= aAnalitico[nAnalitico][ANALITICO_CATEGORIA]
						V3N->V3N_TPINSC	:= aAnalitico[nAnalitico][ANALITICO_TIPO_ESTABELECIMENTO]
						V3N->V3N_NRINSC	:= aAnalitico[nAnalitico][ANALITICO_ESTABELECIMENTO]
						V3N->V3N_CODLOT	:= aAnalitico[nAnalitico][ANALITICO_LOTACAO]
						V3N->V3N_EVENTO	:= cEvento
						V3N->V3N_ORIGEM	:= cOrigem
						V3N->V3N_NATRUB	:= aAnalitico[nAnalitico][ANALITICO_NATUREZA]
						V3N->V3N_TPRUBR	:= aAnalitico[nAnalitico][ANALITICO_TIPO_RUBRICA]
						V3N->V3N_ITCP	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_CP]
						V3N->V3N_ITIRRF	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_IRRF]
						V3N->V3N_ITFGTS	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_FGTS]
						V3N->V3N_INDDEC	:= aAnalitico[nAnalitico][ANALITICO_DECIMO_TERCEIRO]
						V3N->V3N_TPVLR	:= aAnalitico[nAnalitico][ANALITICO_TIPO_VALOR]
						V3N->V3N_VALOR	:= aAnalitico[nAnalitico][ANALITICO_VALOR]

						If TafColumnPos("V3N_MOTDES") .And. Len(aAnalitico[nAnalitico]) >= 14 .And. ValType(aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]) != 'U'
							V3N->V3N_MOTDES := aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]
						Else 
							V3N->V3N_MOTDES := ""
						EndIf

						If lRecibo
							V3N->V3N_RECIBO	:= aAnalitico[nAnalitico][ANALITICO_RECIBO]
						Else
							V3N->V3N_RECIBO	:= cRecibo
						EndIf

						If lVlrDep
							nValorDep := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] ) == "U", 0, aAnalitico[nAnalitico][ANALITICO_VALOR_DEP])

							V3N->V3N_VLRDEP	:= nValorDep
						EndIf

						V3N->(MsUnlock())
					EndIf
				Next
			EndIf
		EndIf

		oData:Clear()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Delete
@type			method
@description	Deleta logicamente um ou mais registros na tabela V3N, respeitando a chave recebida por parâmetro.
@author			Victor A. Barbosa
@since			16/05/2019
@version		1.0
@param			lAll	-	Indica se deve excluir todas as ocorrências, sem considerar a origem
/*/
//---------------------------------------------------------------------
Method Delete(cFilEvt , cIndApu , cPerApu , cCPF , cEvento , cOrigem  , cRecibo , lAll, lRecibo) Class TAFSocialReport

	Local cQryExec	:= ""
	Local lOk		:= .F.

	Default lAll	:= .F.
	Default lRecibo := .F.
	Default cRecibo := ""

	cQryExec := " DELETE FROM " + RetSqlName( "V3N" ) "
	cQryExec += " WHERE V3N_FILIAL = '" + cFilEvt 	+ "' "
	cQryExec += " AND V3N_INDAPU = '" 	+ cIndApu 	+ "' " 
	cQryExec += " AND V3N_PERAPU = '" 	+ cPerApu 	+ "' "
	cQryExec += " AND V3N_EVENTO = '" 	+ cEvento 	+ "' "
	cQryExec += " AND D_E_L_E_T_ = ' ' "

	If !lAll	
		cQryExec += " AND V3N_ORIGEM = '"		+ cOrigem 	+ "' "
		
		If lRecibo
			cQryExec += " AND V3N_RECIBO = '" + cRecibo 	+ "' "
		EndIf
	EndIf
	
	If !Empty(cCPF)
		cQryExec += " AND V3N_CPF = '" 		+ cCPF 			+ "' "
	EndIf
	
	lOk := TcSQLExec( cQryExec ) >= 0

	If lOk
		TafConout( "Delete| Realizado na tabela  " + RetSqlName( "V3N" ))
	Else 	
		TafConout( "Delete| Não foi possível realizar a exclusão dos registros da tabela ";
								+ RetSqlName( "V3N" ) + ". Erro: "  + TCSQLError( ) )
	Endif

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRubrica
@type			method
@description	Retorna um array com os dados da Rubrica.
@author			Victor A. Barbosa
@since			16/05/2019
@version		1.0
@param			cCodRubr	-	Código da Rubrica
@param			cIDTabRubr	-	Identificador da Tabela de Rubrica
@param			cPerApu		-	Período de referência
@param			lMultVinc	-	Indica se o evento de origem possui Múltiplos Vínculos
@param 			nTipPer     -   Tipo de Período: 1=Período Atual; 2=Período Anterior
@return			aRubr		-	Array com as informações da Rubrica
/*/ 
//---------------------------------------------------------------------
Method GetRubrica(cCodRubr, cIDTabRubr, cPerApu, lMultVinc, nTipPer) Class TAFSocialReport

	Local aInfoSM0     	:= {}
	Local aFilMV       	:= {}
	Local aRubr        	:= Array(5)
	Local aArea        	:= GetArea()
	Local cNatureza		:= ""
	Local cTipo        	:= ""
	Local cIncCP       	:= ""
	Local cIncIRRF     	:= ""
	Local cIncFGTS     	:= ""
	Local cQuery	   	:= ""
	Local cAliasQry	   	:= ""
	Local cIdRubr	   	:= ""
	Local cCNPJRaiz    	:= SubStr(SM0->M0_CGC, 1, 8)
	Local lCont        	:= .F.
	Local nRecnoC8R    	:= 0
	Local nPosRubric	:= 0

	Default cIDTabRubr 	:= ""
	Default cPerApu    	:= ""
	Default lMultVinc  	:= .F.
	Default nTipPer		:= 1

	If !Empty(__aRubrica)
		nPosRubric := aScan(__aRubrica, {|r| r[1] + r[2] + r[3] == cCodRubr + cIDTabRubr + cPerApu .And. r[4] == lMultVinc .And. r[5] == nTipPer})
	EndIf

	If nPosRubric > 0
		aRubr := aClone(__aRubrica[nPosRubric][6])
	Else
		If lMultVinc
			aInfoSM0     	:= FWLoadSM0(.F.)
			
			aEval( aInfoSM0, { |x| Iif( SubStr( x[18], 1, 8 ) == cCNPJRaiz .and. x[1] == cEmpAnt, aAdd( aFilMV, x[2] ), Nil ) } )
			nRecnoC8R := StaticCall( TAFR120, MVQueryC8R, cCodRubr, cIDTabRubr, cPerApu, aFilMV, nTipPer )

			If nRecnoC8R > 0

				lCont := .T.
				C8R->( DBGoTo( nRecnoC8R ) )

			EndIf

		Else

			If FwIsInCallStack("TAFR124")

				cAliasQry := GetNextAlias()

				cQuery := " SELECT C8R.C8R_ID "
				cQuery += " FROM " + RetSqlName("C8R") + " C8R "
				cQuery += " WHERE C8R.C8R_FILIAL = '" + xFilial("C8R") + "' "
				cQuery += " AND C8R.C8R_IDTBRU = '" + cIDTabRubr + "' "
				cQuery += " AND C8R.C8R_CODRUB = '" + cCodRubr + "' "

				If Len(Alltrim(cPerApu)) == 6

					If Upper( AllTrim( TCGetDB() ) ) <> "MSSQL"
						cQuery += " AND SUBSTR( C8R.C8R_DTINI, 3, 4 ) || SUBSTR( C8R.C8R_DTINI, 1, 2 ) <= '" + cPerApu +  "' "
						cQuery += " AND ( SUBSTR( C8R.C8R_DTFIN, 3, 4 ) || SUBSTR( C8R.C8R_DTFIN, 1, 2 ) >= '" + cPerApu +  "' "
					Else
						cQuery += " AND CONCAT(SUBSTRING( C8R.C8R_DTINI, 3, 4 ), SUBSTRING( C8R.C8R_DTINI, 1, 2 )) <= '" + cPerApu +  "' "
						cQuery += " AND (CONCAT( SUBSTRING( C8R.C8R_DTFIN, 3, 4 ), SUBSTRING( C8R.C8R_DTFIN, 1, 2 )) >= '" + cPerApu +  "' "
					EndIf

					cQuery += " OR C8R.C8R_DTFIN = '' ) "

				ElseIf Len(Alltrim(cPerApu)) == 4

					If Upper( AllTrim( TCGetDB() ) ) <> "MSSQL"
						cQuery += " AND SUBSTR( C8R.C8R_DTINI, 3, 4 )  <= '" + cPerApu +  "' "
						cQuery += " AND SUBSTR( C8R.C8R_DTFIN, 3, 4 )  >= '" + cPerApu +  "' "
					Else
						cQuery += " AND SUBSTRING( C8R.C8R_DTINI, 3, 4 ) <= '" + cPerApu +  "' "
						cQuery += " AND (SUBSTRING( C8R.C8R_DTFIN, 3, 4 ) >= '" + cPerApu +  "' "
					EndIf

					cQuery += " OR C8R.C8R_DTFIN = '' ) "

				EndIf

				cQuery += " AND D_E_L_E_T_ = '' "
				cQuery += " ORDER BY C8R.C8R_ID DESC "
				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				If ( cAliasQry )->( !Eof() )
					cIdRubr := ( cAliasQry )->C8R_ID
				EndIf

				C8R->( DBSetOrder( 5 ) ) //C8R_FILIAL+C8R_ID+C8R_ATIVO
				If C8R->( MsSeek( xFilial( "C8R" ) + cIdRubr + "1" ) )
					lCont := .T.
				EndIf
				
				(cAliasQry)->(DBCloseArea())

			Else

				C8R->( DBSetOrder( 5 ) ) //C8R_FILIAL+C8R_ID+C8R_ATIVO
				If C8R->( MsSeek( xFilial( "C8R" ) + cCodRubr + "1" ) )
					lCont := .T.
				EndIf

			EndIf

		EndIf

		If lCont

			If C89->( MsSeek( xFilial( "C89" ) + C8R->C8R_NATRUB ) )
				cNatureza := AllTrim( C89->C89_CODIGO )
			EndIf

			cTipo := AllTrim( C8R->C8R_INDTRB )

			If C8T->( MsSeek( xFilial( "C8T" ) + C8R->C8R_CINTPS ) )
				cIncCP := AllTrim( C8T->C8T_CODIGO )
			EndIf

			If C8U->( MsSeek( xFilial( "C8U" ) + C8R->C8R_CINTIR ) )
				cIncIRRF := AllTrim( C8U->C8U_CODIGO )
			EndIf

			cIncFGTS := AllTrim( C8R->C8R_CINTFG )

		EndIf

		aRubr[1] := cNatureza
		aRubr[2] := cTipo
		aRubr[3] := cIncCP
		aRubr[4] := cIncIRRF
		aRubr[5] := cIncFGTS

		AAdd(__aRubrica, {cCodRubr, cIDTabRubr, cPerApu, lMultVinc, nTipPer, aRubr})
	EndIf

	RestArea(aArea)

Return aRubr
