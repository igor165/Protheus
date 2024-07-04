#INCLUDE "JURA105.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105
Envolvidos 

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/

Static _cEntidade := "" //variável criada para compor o retorno do F3 da consulta de entidades pois na versão 12 depois da mudança do frame de usar FWLookUp para todas as consultas, isso não esta funcionando.
Static _cChave    := "" //variável criada para compor o retorno do F3 da consulta de entidades pois na versão 12 depois da mudança do frame de usar FWLookUp para todas as consultas, isso não esta funcionando.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105TE
Filtra a consulta padrão de tipo de envolvimento conforme o tipo de envolvido
Uso no cadastro de Envolvidos. Foi alterado em 28/08/13 pois o filtro reornando
True ou False não estava funcionando em conjunto com a restrição de cadastro básico.

@Return cRet	 	Filtro que deve ser usado na consulta padrão.
@sample

@author Juliana Iwayama Velho
@since 02/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105TE()
Local oModel    := Nil
Local oModelNT9 := Nil
Local cRet      := "@#@#"

If IsPesquisa()
	If !Empty(M->NT9_TIPOEN)
		cRet := IIF( M->NT9_TIPOEN == '1', "@#NQA->NQA_POLOAT == '1'@#", ;
			IIF( M->NT9_TIPOEN == '2', "@#NQA->NQA_POLOPA == '1'@#", ;
			IIF( M->NT9_TIPOEN == '3', "@#NQA->NQA_TERCIN == '1'@#", ;
			IIF( M->NT9_TIPOEN == '4', "@#NQA->NQA_SOCIED == '1'@#", ;
			IIF( M->NT9_TIPOEN == '5', "@#NQA->NQA_PARTIC == '1'@#", ;
			IIF( M->NT9_TIPOEN == '6', "@#NQA->NQA_ADMINI == '1'@#", cRet))))))
	 EndIf

Else
	oModel := FWModelActive()
	If !(oModel:cId $ 'JURA095|JURA055|JURA219')			// Se o Model que vier carregado for diferente do JURA095, carrega o Modelo correspondente do JURA070
		oModel:= FWLoadModel( 'JURA095' )
		oModel:Activate()	// Ativa o model.
	EndIf

	oModelNT9 := oModel:GetModel('NT9DETAIL')

	If !Empty(oModelNT9:GetValue('NT9_TIPOEN')).And.(oModelNT9:Length() > 0)
		cRet	:=	IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '1' , "@#NQA->NQA_POLOAT == '1'@#",;
					IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '2' , "@#NQA->NQA_POLOPA == '1'@#",;
					IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '3' , "@#NQA->NQA_TERCIN == '1'@#",;
					IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '4' , "@#NQA->NQA_SOCIED == '1'@#",;
					IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '5' , "@#NQA->NQA_PARTIC == '1'@#",;
					IIF( oModelNT9:GetValue( 'NT9_TIPOEN' ) == '6' , "@#NQA->NQA_ADMINI == '1'@#", cRet))))))
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105TE2
Valida se o campo de tipo de envolvimento está correto conforme o tipo de envolvido
Uso no cadastro de Envolvidos a partir de Processos.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105TE2()
Local lRet      := .T.
Local aAreaNQA  := NQA->( GetArea() )
Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oM        := oModel:GetModel( 'NT9DETAIL')
Local cCod      := ''
Local cTmpDesc  := ''
Local nTipPol   := 0

If oModel:IsFieldUpdated( 'NT9DETAIL','NT9_CTPENV') // Verifica se a linha foi alterada..
	
	cCod    := oM:GetValue( 'NT9_CTPENV')
	nTipPol := oM:GetValue( 'NT9_TIPOEN')

	If NQA->( dbSeek( xFilial( 'NQA' ) + cCod ) )
		// Validação por tipo de envolvido.
		Do Case
		Case (nTipPol == '1').And.( NQA->NQA_POLOAT <> '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  ) // STR0016 = " Favor verificar a regra do Campo " STR0017 = " para o tipo de envolvimento: ' "

		Case ( lRet .And. nTipPol == '2').And.( NQA->NQA_POLOPA <> '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  )

		Case (lRet .And. nTipPol == '3').And.( NQA->NQA_TERCIN   <> '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  )

		Case (lRet .And. nTipPol == '4').And.( NQA->NQA_SOCIED  <> '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  )

		Case (lRet .And. nTipPol == '5').And.( NQA->NQA_PARTIC   <> '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  )

		Case (lRet .And. nTipPol == '6').And.(NQA->NQA_ADMINI <>  '1' )
			cTmpDesc := ALLTRIM(NQA->NQA_DESC)
			lRet := JurMsgErro( STR0016 +  RetTitle( 'NT9_TIPOEN' ) + STR0017 +oM:GetValue( 'NT9_CTPENV') +'-' + cTmpDesc + " ' "  )
		EndCase
	Else
		lRet := JurMsgErro( STR0018 +  RetTitle( 'NT9_TIPOEN' ) + STR0019 ) //  'Campo ' +  RetTitle( 'NT9_TIPOEN' ) + ' não encontrado na tabela de Tipo de Envolvimento (NQA)
	EndIf
EndIf

RestArea( aAreaNQA )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105EMP
Valida os campos de empresa
Uso no cadastro de Envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 24/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105EMP()
Local aArea      := GetArea()
Local aAreaNT9   := NT9->( GetArea() )
Local lRet       := .T.
Local oModel     := FWModelActive()
Local oM         := oModel:GetModel( 'NT9DETAIL' )
Local nCt        := 0
Local nPoloAt    := 0
Local nPoloPa    := 0
Local nEmpPoloAt := 0
Local nEmpPoloPa := 0
Local cRepetCli	 := SuperGetMV('MV_JENVTAB',, '2') //Indica se o cadastro de envolvidos sera tabelado, obrigando ou nao preenchimento de Cliente e Loja (1=Sim; 2=Nao)
Local cParam2	 := SuperGetMV('MV_JOBRENV',, '1') //Obriga preencher campos cliente e loja no envolvido. 1 - Habilitado; 2 - Desabilitado
Local aNT9       := {}

For nCt := 1 To oM:Length()
	aNT9 :=	oM:GetLinesChanged()
	If !oM:IsDeleted(nCt) .And. Len(aNT9) > 0 // Necessário para percorrer as demais linhas, verificando se esta deletado ou não.

		If oM:GetValue('NT9_TIPOCL', nCt) == '1'

			//Verifica se a opção Cliente está marcada e os campos de empresa
			If (cParam2 == '1').And.( Empty(oM:GetValue('NT9_CEMPCL', nCt)).Or.Empty(oM:GetValue('NT9_LOJACL', nCt)) )
				lRet := JurMsgErro(STR0015)   // É necessário preenhcher os campos de cliente/loja
				Exit
			Else
				//Conta a qtde de envolvidos por tipo, que possuem o campo de empresa preenchidos

				If (cRepetCli <> '1').And.!Empty ( oM:GetValue('NT9_TIPOEN', nCt) ) .And. !Empty( oM:GetValue('NT9_CEMPCL', nCt) )
					If oM:GetValue('NT9_TIPOEN', nCt) == '1'
						nEmpPoloAt++
					ElseIf oM:GetValue('NT9_TIPOEN', nCt) == '2'
						nEmpPoloPa++
					EndIf
				EndIf

				//Verifica o CGC
				If !Empty ( oM:GetValue('NT9_CGC', nCt) ) .And. cParam2 == '1'
					cCNPJ := Posicione('SA1', 1 , xFilial('SA1') + oM:GetValue('NT9_CEMPCL', nCt) + oM:GetValue('NT9_LOJACL', nCt), 'A1_CGC')
					If oM:GetValue('NT9_CGC', nCt) <> cCNPJ .Or. Empty(cCNPJ)
						lRet := JurMsgErro(STR0012 )
					EndIf
				EndIf

			EndIf

		EndIf

		//Verifica a qtde de envolvidos que são Principal
		If lRet .And.(cRepetCli <> '1') .And.( oM:GetValue('NT9_PRINCI', nCt) == '1')
			If oM:GetValue('NT9_TIPOEN', nCt) == '1'
				nPoloAt++
			ElseIf oM:GetValue('NT9_TIPOEN', nCt) == '2'
				nPoloPa++
			EndIf
		EndIf

	EndIf

Next                                                  

If lRet .And. (nPoloAt > 1 .Or. nPoloPa > 1)
	lRet := JurMsgErro(STR0013)  // ja existe um envolvido principal cadastrado
EndIf

RestArea(aAreaNT9)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105CLI
Valida se o cliente como empresa é igual ao do assunto jurídico, conforme
o litisconsórcio
Uso no cadastro de Envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 11/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105CLI()
Local aArea    := GetArea()
Local aAreaNT9 := NT9->( GetArea() )
Local lRet     := .T.
Local oModel   := FWModelActive()
Local oM       := oModel:GetModel( 'NT9DETAIL')
Local nCt      := 0

If SuperGetMV('MV_JFTJURI',, '1') == '1'
	If oModel:GetValue('NSZMASTER','NSZ_LITISC') == '2'
		For nCt := 1 To oM:GetQtdLine()
			If !oM:IsDeleted() .And. oM:GetValue('NT9_TIPOCL', nCt) == '1'
				If oM:GetValue('NT9_CEMPCL', nCt) <> oModel:GetValue( 'NSZMASTER','NSZ_CCLIEN', nCt)
					lRet := JurMsgErro(STR0010 + RetTitle('NT9_CEMPCL' ))
					Exit
				EndIf
			EndIf
		Next
	EndIf
ElseIf SuperGetMV('MV_JFTJURI',, '1') == '2' 
	lRet:= .T.
EndIf

RestArea(aAreaNT9)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105ECL
Filtra a consulta padrão de empresa (cliente e loja) conforme cliente do
assunto jurídico
Uso no cadastro de Envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105ECL()
Local aArea   := GetArea()
Local cRet    := "@#@#"
Local aRestr  := JA162RstUs(  If(IsMemVar('oCmbConfig'), oCmbConfig:cValor, "")   )
Local lLitis  := .F.
Local cGrpCli := ''
Local oModel

If !IsPesquisa()
	oModel   := FWModelActive()
	// Manter o "oModel != NIl" na expressão por conta do uso do campo 'NT9_CEMPCL' na tela de pesquisa
	If oModel != NIl .And. oModel:getID() $ 'JURA095|JURA219' .AND. !EMPTY( oModel:GetValue("NSZMASTER", "NSZ_LITISC") )
		If oModel:GetValue("NSZMASTER", "NSZ_LITISC")  == "1"
			lLitis  := .T.
		EndIf
		If !Empty( oModel:GetValue("NSZMASTER", "NSZ_CCLIEN")) .and. !Empty( oModel:GetValue("NSZMASTER", "NSZ_LCLIEN"))
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+oModel:GetValue("NSZMASTER", "NSZ_CCLIEN")+oModel:GetValue("NSZMASTER", "NSZ_LCLIEN")))
				cGrpCli := SA1->A1_GRPVEN
			EndIf			
		EndIf
	EndIf
	
	If !lLitis .And. !Empty(M->NSZ_CCLIEN) .And. SuperGetMV('MV_JFTJURI',, '1') == '1'
		If Empty(cGrpCli)
			cRet := "@#SA1->A1_COD == '"+M->NSZ_CCLIEN+"' AND SA1->A1_GRPVEN == '" + Space(TamSX3('A1_GRPVEN')[1]) + "' @#"
		Else
			cRet := "@#SA1->A1_GRPVEN == '"+cGrpCli+"'@#"
		EndIf
	ElseIf lLitis	
		cRet := J105AllCli( aRestr )	
	EndIF
Else
	cRet := J105AllCli( aRestr )	
EndIF


RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105NTB
Valida se o campo de local de trabalho está correto conforme cliente e loja
do processo
Uso no cadastro de Envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 11/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105NTB()
Local lRet     	:= .F.
Local oModel   	:= FWModelActive()
Local oNT9DETAIL:= oModel:GetModel( 'NT9DETAIL')
Local nLinhaMdl := 0
Local cCliLjNTB := ""
Local aSaveRows := {}

If !Empty(oNT9DETAIL:GetValue('NT9_CLOCTR'))
	//Cliente/ Loja do local de trabalho
	cCliLjNTB += AllTrim(JurGetDados("NTB", 1, xFilial('NTB') + oNT9DETAIL:GetValue('NT9_CLOCTR'), "NTB_CCLIEN"))
	cCliLjNTB += AllTrim(JurGetDados("NTB", 1, xFilial('NTB') + oNT9DETAIL:GetValue('NT9_CLOCTR'), "NTB_LOJACL"))
	
	If cCliLjNTB == AllTrim(oNT9DETAIL:GetValue('NT9_CEMPCL'))+AllTrim(oNT9DETAIL:GetValue('NT9_LOJACL'))
		//Valida o cliente, independente se é ou não polo Passivo
		lRet := .T.
	ElseIf !oNT9DETAIL:IsEmpty()
		If !Empty (cCliLjNTB)
			aSaveRows := FWSaveRows()
			// Varre as linhas da grid de envolvidos
			For nLinhaMdl := 1 To oNT9DETAIL:Length()
				oNT9DETAIL:GoLine( nLinhaMdl )
				If !oNT9DETAIL:IsDeleted()
					//Caso algum dos envolvidos seja o cliente vinculado ao local de trabalho, é validado
					If cCliLjNTB == AllTrim(oNT9DETAIL:GetValue('NT9_CEMPCL'))+AllTrim(oNT9DETAIL:GetValue('NT9_LOJACL')) .AND.;
						oNT9DETAIL:GetValue('NT9_TIPOEN') == "2"
						lRet := .T.
						Exit
					EndIf
				EndIf
			Next nLinhaMdl
			FWRestRows( aSaveRows )
		EndIf
	EndIf
	If !lRet
		lRet := JurMsgErro( STR0010 + RetTitle('NT9_CLOCTR') ) //"Campo invalido "
	EndIf
Else
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105CLT
Filtra a consulta padrão de local de trabalho pelo cliente e loja do
assunto jurídico
Uso no cadastro de Envolvidos.

@Return cRet	 	Condição

@author Juliana Iwayama Velho
@since 11/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105CLT()
Local cRet      := "@#@#"
Local aFiltro   := {}
Local oModel    := FWModelActive()
Local oNT9DETAIL:= oModel:GetModel( 'NT9DETAIL')
Local nLinhaMdl := 0
Local aSaveRows := {}
Local nI        := 0
	//Se for cliente, adiciona a linha editada, independente se é ou não polo Passivo
	aAdd(aFiltro, {AllTrim(oNT9DETAIL:GetValue('NT9_CEMPCL')), AllTrim(oNT9DETAIL:GetValue('NT9_LOJACL'))})
	aSaveRows := FWSaveRows()
	// Varre as linhas da grid de envolvidos
	For nLinhaMdl := 1 To oNT9DETAIL:Length()
		oNT9DETAIL:GoLine( nLinhaMdl )
		If !oNT9DETAIL:IsDeleted()
			If !Empty(oNT9DETAIL:GetValue('NT9_CEMPCL')) .AND. oNT9DETAIL:GetValue('NT9_TIPOEN') == "2"
				//Guarda no array todos os clientes envolvidos 
				aAdd(aFiltro, {AllTrim(oNT9DETAIL:GetValue('NT9_CEMPCL')),AllTrim(oNT9DETAIL:GetValue('NT9_LOJACL'))})
			EndIf
		EndIf
	Next nLinhaMdl
	FWRestRows( aSaveRows )
	
	//Monta a condição do filtro 
	If !Empty(aFiltro)
		cRet := "@#("
		For nI := 1 to Len(aFiltro)
			cRet += "NTB->NTB_CCLIEN == '"+aFiltro[nI][1]+"' .AND. NTB->NTB_LOJACL == '"+aFiltro[nI][2]+"'"
			If nI < Len(aFiltro) 
				cRet += ") .OR. ("
			EndIf
		Next nI
		cRet += ")@#"
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105TOK
Valida informações ao salvar.
Uso no cadastro de Envolvidos

@param 	oModel  		oModel a ser verificado
@Return lRet	 		.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 11/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105TOK(oModel)
Local aArea	:= GetArea()
Local lRet  := .T.
Local nOpc  := oModel:GetOperation()

If nOpc == 3 .Or. nOpc == 4
	lRet := JURA105EMP()
	If lRet .And. SuperGetMV('MV_JOBRENV',, '1') == '1'
		lRet := JURA105CLI()
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR105CGC2
Verifica se o envolvido é pessoa física ou jurídica para inclusão de máscara
no campo de CNPJ/CPF
Uso no cadastro de Envolvidos

@Return cRet	 		Máscara para o campo de CNPJ/CPF

@author Juliana Iwayama Velho
@since 13/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR105CGC2()
Local cRet := ''

cRet:= JURM1(FWFldGet('NT9_TIPOP'))

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105QYNRP
Monta a query de cargos a partir de cliente e loja ou pesquisa
Uso no cadastro de Envolvidos.

@Param cCliente    Campo de cliente do processo
@Param cLoja       Campo de loja do processo
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105QYNRP(cCliente,cLoja)
Local cQuery := ''

If Empty(cCliente) .And. Empty(cLoja)
	cQuery := "SELECT NRP.NRP_COD, NRP.NRP_DESC, NRP.R_E_C_N_O_ NRPRECNO  "
	cQuery += "  FROM "+RetSqlName("NRP")+" NRP"
	cQuery += " WHERE NRP.NRP_FILIAL = '" + xFilial( "NRP" ) + "' "
	cQuery += "   AND NRP.D_E_L_E_T_ = ' ' "
Else
	cQuery := "SELECT NRP.NRP_COD, NRP.NRP_DESC, NRP.R_E_C_N_O_ NRPRECNO  "
	cQuery += "  FROM "+RetSqlName("NRP")+" NRP,"+RetSqlName("NU0")+" NU0"
	cQuery += " WHERE NRP.NRP_FILIAL = '" + xFilial( "NRP" ) + "' "
	cQuery += "   AND NU0.NU0_FILIAL = '" + xFilial( "NU0" ) + "' "
	cQuery += "   AND NRP.NRP_COD = NU0.NU0_CCARGO"
	cQuery += "   AND NU0.NU0_CCLIEN = '" + cCliente + "'"
	cQuery += "   AND NU0.NU0_CLOJA  = '" + cLoja + "'"
	cQuery += "   AND NRP.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NU0.D_E_L_E_T_ = ' ' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105F3NRP
Customiza a consulta padrão de cargo pelo cliente e loja, se for da tela
de pesquisa lista todos
Uso no cadastro de Envolvidos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105F3NRP()
Local lRet      := .F.
Local aArea     := GetArea()
Local cQuery    := ""
Local aPesq     := {"NRP_COD","NRP_DESC"}
Local nResult   := 0

If IsPesquisa()
	cQuery := JA105QYNRP(M->NSZ_CCLIEN,M->NSZ_LCLIEN)
Else
	cQuery := JA105QYNRP( FwFldGet('NT9_CEMPCL'), FwFldGet('NT9_LOJACL'))
EndIf

cQuery := ChangeQuery(cQuery, .F.)
RestArea( aArea )

nResult := JurF3SXB("NRP", aPesq,, .F., .F.,, cQuery)
lRet := nResult > 0

If lRet
	DbSelectArea("NRP")
	NRP->(dbgoTo(nResult))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105VNRP
Verifica se o valor do campo de cargo é válido
Uso no cadastro de Envolvidos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105VNRP()
Local lRet      := .F.
Local aArea     := GetArea()
Local cQuery    := JA105QYNRP( FwFldGet('NT9_CEMPCL'), FwFldGet('NT9_LOJACL') )
Local cAlias    := GetNextAlias()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )
	If (cAlias)->NRP_COD == FwFldGet('NT9_CCGECL')
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
End

If !lRet
	JurMsgErro(STR0010)
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105QYNS6
Monta a query de funções a partir de cliente e loja ou pesquisa
Uso no cadastro de Envolvidos.

@Param cCliente    Campo de cliente do processo
@Param cLoja       Campo de loja do processo
@Return cQuery	   Query montada

@author Juliana Iwayama Velho
@since 26/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105QYNS6(cCliente,cLoja)
Local cQuery := ''

If Empty(cCliente) .And. Empty(cLoja)
	cQuery := "SELECT NS6.NS6_COD, NS6.NS6_DESC, NS6.R_E_C_N_O_ NS6RECNO  "
	cQuery += "  FROM "+RetSqlName("NS6")+" NS6"
	cQuery += " WHERE NS6.NS6_FILIAL = '" + xFilial( "NS6" ) + "' "
	cQuery += "   AND NS6.D_E_L_E_T_ = ' ' "
Else
	cQuery := "SELECT NS6.NS6_COD, NS6.NS6_DESC, NS6.R_E_C_N_O_ NS6RECNO  "
	cQuery += "  FROM "+RetSqlName("NS6")+" NS6,"+RetSqlName("NU8")+" NU8"
	cQuery += " WHERE NS6.NS6_FILIAL = '" + xFilial( "NS6" ) + "' "
	cQuery += "   AND NU8.NU8_FILIAL = '" + xFilial( "NU8" ) + "' "
	cQuery += "   AND NS6.NS6_COD = NU8.NU8_CFUNC "
	cQuery += "   AND NU8.NU8_CCLIEN = '" + cCliente + "'"
	cQuery += "   AND NU8.NU8_CLOJA  = '" + cLoja + "'"
	cQuery += "   AND NS6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NU8.D_E_L_E_T_ = ' ' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105F3NS6
Customiza a consulta padrão de função pelo cliente e loja, se for da tela
de pesquisa lista todos
Uso no cadastro de Envolvidos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 26/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105F3NS6()
Local lRet      := .F.
Local aArea     := GetArea()
Local aCampos   := {"NS6_COD","NS6_DESC"}
Local cQuery    := ""
Local nResult   := 0
Local cCodCli   := ""
Local cCodLoja  := ""
Local aCamposP  := {}
Local nPos      := 0

If IsPesquisa()
	If !Empty(M->NT9_CEMPCL)
		cCodCli  := M->NT9_CEMPCL
		cCodLoja := M->NT9_LOJACL
	Else
		aCamposP := J162CmpPes()
		If (nPos := Ascan(aCamposP, {|x| x:cNomeCampo == 'NT9_CEMPCL'})) > 0
			cCodCli := aCamposP[nPos]:VALOR
		EndIf
		If (nPos := Ascan(aCamposP, {|x| x:cNomeCampo == 'NT9_LOJACL'})) > 0
			cCodLoja := aCamposP[nPos]:VALOR
		EndIf
	EndIf

	cQuery   := JA105QYNS6(cCodCli, cCodLoja)
Else
	cQuery   := JA105QYNS6( FwFldGet('NT9_CEMPCL'), FwFldGet('NT9_LOJACL') )
EndIf

cQuery := ChangeQuery(cQuery, .F.)
uRetorno := ''
RestArea( aArea )

nResult := JurF3SXB("NS6", aCampos,, .F., .F.,, cQuery)
lRet := nResult > 0

If lRet
	DbSelectArea("NS6")
	NS6->(dbgoTo(nResult))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105VNS6
Verifica se o valor do campo de função é válido
Uso no cadastro de Envolvidos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 26/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105VNS6()
Local lRet      := .F.
Local aArea     := GetArea()
Local cQuery    := JA105QYNS6( FwFldGet('NT9_CEMPCL'), FwFldGet('NT9_LOJACL') )
Local cAlias    := GetNextAlias()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )
While !(cAlias)->( EOF() )
	If (cAlias)->NS6_COD == FwFldGet('NT9_CFUNCL')
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
End

If !lRet
	JurMsgErro(STR0010)
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105VLCLI
Ao preencher os campos de cliente e loja valida se o cliente é igual ao do processo,
conforme o litisconsórcio
Uso no cadastro de Envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105VLCLI()
Local aArea    := GetArea()
Local aAreaNT9 := NT9->( GetArea() )
Local lRet     := .T.

If SuperGetMV('MV_JFTJURI',, '1') == '1'
	If FwFldGet('NSZ_LITISC') == '2'
		If FwFldGet('NT9_TIPOCL') == '1'
			If FwFldGet('NT9_CEMPCL') <> FwFldGet('NSZ_CCLIEN')
				lRet := JurMsgErro(STR0010 + RetTitle('NT9_CEMPCL' )) //Campo invalido 
			EndIf
		EndIf
	EndIf
Else

lRet := .T.

EndIf

RestArea(aAreaNT9)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA105RSTCO
Retorna filtro para restrição por CORRESPONDENTES

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 08/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA105RSTCO(cCod)
Local aArea   		:= GetArea()
Local cSQL			:= ""
Local cRet			:= ""
Local cAlias		:= GetNextAlias()
Local nFlxCorres	:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

cSQL := "	SELECT SA1.A1_COD CLI, SA1.A1_LOJA LOJA, SA1.R_E_C_N_O_ RECNOLAN " + CRLF
cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF
cSQL +=        " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "+ CRLF
cSQL +=                                                     " NSZ.NSZ_CCLIEN = SA1.A1_COD AND " + CRLF
cSQL +=                                                     " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND " + CRLF
cSQL +=                                                     " NSZ.D_E_L_E_T_ = ' ') " + CRLF

//Fluxo de correspondente por Assunto Jurídico
If nFlxCorres == 2
	cSQL +=         " LEFT JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' AND "+ CRLF
	cSQL +=                                                     " NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND " + CRLF
	cSQL +=                                                     "	NUQ.NUQ_INSATU = '1' AND " + CRLF
	cSQL +=                                                     "	NUQ.D_E_L_E_T_ = ' ') " + CRLF
	cSQL += 				"	INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CUSER = '"+__CUSERID+"' AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CCORR = NUQ.NUQ_CCORRE AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CLOJA = NUQ.NUQ_LCORRE AND "+ CRLF
	cSQL +=                                              " NVK.NVK_COD	 = "+ cCod +" AND "+ CRLF
	cSQL +=                                              " NVK.D_E_L_E_T_ = ' ') "+ CRLF
	cSQL += 				"	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
	cSQL +=   				" AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
			
	cSQL +=	"	UNION  " + CRLF
		
	cSQL += "	SELECT SA1.A1_COD CLI, SA1.A1_LOJA LOJA, SA1.R_E_C_N_O_ RECNOLAN " + CRLF
	cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF
	cSQL +=        " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "+ CRLF
	cSQL +=                                                     " NSZ.NSZ_CCLIEN = SA1.A1_COD AND " + CRLF
	cSQL +=                                                     " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND " + CRLF
	cSQL +=                                                     " NSZ.D_E_L_E_T_ = ' ') " + CRLF
	
	cSQL += 				"	INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CUSER = '"+__CUSERID+"' AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CCORR = NSZ.NSZ_CCORRE AND "+ CRLF
	cSQL +=                                              " NVK.NVK_CLOJA = NSZ.NSZ_LCORRE AND "+ CRLF
	cSQL +=                                              " NVK.NVK_COD	 = "+ cCod +" AND "+ CRLF
	cSQL +=                                              " NVK.D_E_L_E_T_ = ' ') "+ CRLF
	cSQL += 				"	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
	cSQL +=   				" AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
	
//Fluxo de correspondente por Follow-up
Else
	cSQL +=         " LEFT JOIN " + RetSqlName("NTA") + " NTA ON (NTA.NTA_FILIAL = '"+xFilial("NTA")+"' AND "+ CRLF
	cSQL +=                                                     " NTA.NTA_CAJURI = NSZ.NSZ_COD AND " + CRLF
	cSQL +=                                                     " NTA.D_E_L_E_T_ = ' ') " + CRLF
	cSQL += 				"	INNER JOIN " + RetSqlName("NVK") + " NVK ON ( NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "+ CRLF
	cSQL +=                                              					" NVK.NVK_CUSER = '"+__CUSERID+"' AND "+ CRLF
	cSQL +=                                              					" NVK.NVK_CCORR = NTA.NTA_CCORRE AND "+ CRLF
	cSQL +=                                              					" NVK.NVK_CLOJA = NTA.NTA_LCORRE AND "+ CRLF
	cSQL +=                                              					" NVK.NVK_COD	 = "+ cCod +" AND "+ CRLF
	cSQL +=                                              					" NVK.D_E_L_E_T_ = ' ') "+ CRLF
	cSQL += 				"	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
	cSQL +=   				" AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

EndIf

cSQL += "	GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_  " + CRLF

cSQL := ChangeQuery( cSQL )
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F. )

If !(cAlias)->( EOF() )
	While !(cAlias)->( EOF() )
		cRet += "( SA1->A1_COD == '"+(cAlias)->CLI+"' .AND. SA1->A1_LOJA == '"+(cAlias)->LOJA+"') .OR."
		(cAlias)->(dbSkip())
	EndDo
EndIf
(cAlias)->( dbCloseArea() )
RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J105AllCli

Função que retona os codigos de clientes que estão vinculados a Restricao

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Rafael Rezende Costa
@since 13/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J105AllCli( aRestr )
Local cRet    := "@#@#"
Local nPos    := ''
Local cRetFim := ''
Local nI      := 0
Local cGrpRest := JurGrpRest()

Default aRestr	:= JA162RstUs(  If(IsMemVar('oCmbConfig'), oCmbConfig:cValor, "")   )

If !Empty(aRestr)
	cRet := "@#("
	For nI := 1 to LEN(aRestr)
		If 'CLIENTES' $ cGrpRest
			cRet += "( SA1->A1_COD == '"+aRestr[nI][2]+"' .AND. SA1->A1_LOJA == '"+aRestr[nI][3]+"') .OR."
		EndIf
		If 'CORRESPONDENTES' $ cGrpRest
			cRet += JA105RSTCO(aRestr[nI][1])
		EndIf
	Next nI
	
	nPos   := Len(AllTrim(cRet))
	cRetFim:= SUBSTRING(cRet,1,nPos-4)+")@#"
	
	cRet   := cRetFim
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR105VNT9
Validação dos campos dos envolvidos
Uso no cadastro dos envolvidos.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 24/06/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function JUR105VNT9()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oModelNT9  := oModel:GetModel('NT9DETAIL')
Local nCt        := 0
Local aDADOS     := ARRAY(6,2)
Local nTipo
/*
Array que guardará quantidade de registros por pólo e quantidade de principais.
1=Polo Ativo;2=Polo Passivo;3=Terceiro Interessado;4=Sociedade Envolvida;5=Participacao Societaria;6=Administracao
*/
aDADOS := {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}

//Preenche array
For nCt := 1 To oModelNT9:GetQtdLine()

	if (!oModelNT9:IsDeleted(nCt))
		nTipo := Val(oModelNT9:GetValue('NT9_TIPOEN',nCt))
		aDADOS[nTipo][1]++

		If (oModelNT9:GetValue('NT9_PRINCI',nCt)=="1")
			aDADOS[nTipo][2]++
		Endif
	Endif

End

For nCt := 1 To len(aDADOS)
		//valida se tem mais de um principal
	If (lRet .And. aDADOS[nCt][2] > 1)
		lRet := .F.
	Endif

		//valida se tem algum principal
	If (lRet .And. aDADOS[nCt][1] > 0 .And. aDADOS[nCt][2] == 0)
		lRet := .F.
	Endif

End

If (!lRet)
	JurMsgErro(STR0020) 
Endif

	RestArea( aArea )


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105ENVOL
Validação dos campos de Envolvido
Uso na pesquisa de processo para vinculo.
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 13/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105ENVOL()
Local oModel      := FWModelActive()
Local oModelNT9   := oModel:GetModel('NT9DETAIL')
Local aArea       := GetArea()
Local nEnvolvido  := 0
Local nEmpPolAti  := 0
Local nEmpPolPas  := 0
Local nPorc       := 0 //Porcentagem de rateio entre envolvidos
Local lRet        := .T.
Local nLine       := oModelNT9:nLine
Local nI          := 0
Local lIsFornec   := .F.
Local lIsClient   := .F.
Local lEnvTabel   := SuperGetMV('MV_JENVTAB',, '2') == '1' //Indica se o cadastro de envolvidos sera tabelado, obrigando ou nao preenchimento de Cliente/Fornecedor e Loja (1=Sim; 2=Nao)

oModelNT9:GoLine( nI )
For nI := 1 To oModelNT9:GetQtdLine()

	lIsFornec := oModelNT9:GetValue("NT9_TFORNE",nI) == '1'
	lIsClient := oModelNT9:GetValue("NT9_TIPOCL",nI) == '1'

	If !oModelNT9:IsDeleted(nI)
	
		If !oModelNT9:IsDeleted(nI) .and. !Empty(oModelNT9:GetValue('NT9_TIPOEN', nI))
			nEnvolvido++
		EndIf
		
		If oModelNT9:HasField("NT9_TIPOCL") .And. oModelNT9:HasField("NT9_PRATPR") .And. (oModelNT9:GetValue('NT9_TIPOCL', nI)) == '1'
			If !Empty(oModelNT9:GetValue('NT9_PRATPR', nI))
				nPorc += oModelNT9:GetValue('NT9_PRATPR', nI)
			EndIf
		EndIf

		If lEnvTabel
			If lIsFornec
				If Empty(oModelNT9:GetValue("NT9_CFORNE", nI)) .and. Empty(oModelNT9:GetValue("NT9_LFORNE", nI))
					lRet := JurMsgErro(STR0024)//"Favor preencher os campos de Código e Loja do Envolvido (Cliente ou Fornecedor)"
					Exit
				EndIf
		
				If !Empty(oModelNT9:GetValue('NT9_CEMPCL', nI)) .and. !Empty(oModelNT9:GetValue('NT9_LOJACL', nI)) .and. ;
						!Empty(oModelNT9:GetValue("NT9_CFORNE", nI)) .and. !Empty(oModelNT9:GetValue("NT9_LFORNE", nI))
					lRet := JurMsgErro(STR0025)//"Um envolvido não pode ser cliente e fornecedor simultaneamente."
					Exit
				EndIf
			Else
				If lIsClient
					If (Empty(oModelNT9:GetValue('NT9_CEMPCL', nI)) .Or. Empty(oModelNT9:GetValue('NT9_LOJACL', nI)))
						lRet := JurMsgErro(STR0026) //"Favor preencher os campos de Cliente e Loja do Envolvido"
						Exit
					EndIf
				EndIf
			EndIf
		
			If lIsFornec
			  		//Verifica o Polo Ativo e Passivo
				If !Empty( oModelNT9:GetValue("NT9_TIPOEN", nI) ) .and. !Empty( oModelNT9:GetValue("NT9_CFORNE", nI) )
					If oModelNT9:GetValue("NT9_TIPOEN", nI) == "1"
						nEmpPolAti++
					ElseIf oModelNT9:GetValue("NT9_TIPOEN", nI) == "2"
						nEmpPolPas++
					EndIf
				EndIf
			EndIf
		Else
			If lIsClient .and. lIsFornec
				lRet := JurMsgErro(STR0025)//"Um envolvido não pode ser cliente e fornecedor simultaneamente."
				Exit
			EndIf
		
			 	//Valida Cliente
			If lIsClient
				If Empty(oModelNT9:GetValue('NT9_CEMPCL', nI)) .Or. Empty(oModelNT9:GetValue('NT9_LOJACL', nI))
					lRet := JurMsgErro(STR0026) //"Favor preencher os campos de Cliente e Loja do Envolvido"
					Exit
				EndIf
			EndIf
		
			//Valida o Fornecedor
			If lIsFornec
				If Empty( oModelNT9:GetValue("NT9_CFORNE", nI) ) .Or. Empty( oModelNT9:GetValue("NT9_LFORNE", nI) )
					lRet := JurMsgErro(STR0027)//"Favor preencher os campos de Fornecedor e Loja do Envolvido"
					Exit
				EndIf
			EndIf
		EndIf
		
		If oModelNT9:GetValue('NT9_DTENTR', nI) < oModel:GetValue('NSZMASTER','NSZ_DTCONS')
			lRet := JurMsgErro(STR0028) //"O campo de data de entrada do cadastro de envolvido nao pode ser inferior a data de Constituicao"
			Exit
		EndIf
		
		If oModelNT9:GetValue('NT9_DTENTR', nI) > Date()
			lRet := JurMsgErro(STR0029) //"Data de entrada do cadastro de envolvido não pode ser maior que a data atual. Verifique"
			Exit
		EndIf
		
		If oModelNT9:GetValue('NT9_DTSAID', nI) < oModelNT9:GetValue('NT9_DTENTR', nI) .And. !Empty(oModelNT9:GetValue('NT9_DTSAID', nI))
			lRet := JurMsgErro(STR0030) //"O campo de data de saida do cadastro de envolvido nao pode ser inferior a data de entrada"
			Exit
		EndIf
		
		If !Empty(oModelNT9:GetValue('NT9_DTSAID', nI)) .And. Empty(oModelNT9:GetValue('NT9_DTENTR', nI))
			lRet := JurMsgErro(STR0031) //"O campo de data de entrada do cadastro de envolvido não está preenchido, portanto não é possível ter uma data de saída do cadastro de envolvido"
			Exit
		EndIf
	EndIf
Next

If lRet .And. nEnvolvido == 0
	lRet := JurMsgErro(STR0032) //"É necessário ter um envolvido cadastrado, verificar"
EndIf

If lRet .And. nPorc <> 100 .And. nPorc <> 0
	lRet := JurMsgErro(STR0054) //"Rateio entre envolvidos deve ser igual a 100% do valor total. Verifique!"
EndIf

If lRet .And. nEmpPolAti > 1 .And. nEmpPolPas > 1
	lRet := JurMsgErro(STR0033)//"Já existe envolvido cadastrado como Fornecedor"
EndIf

RestArea( aArea )
oModelNT9:GoLine( nLine )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105Reu()
Informa o nome do réu principal do processo
Uso no cadastro de Processos.
@param  oModel Modelo de dados do cadastro de processo
@return cReu
@author Clóvis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105Reu(oModel)
Local cReu := ''
Local nI
Local oModelGrid := oModel:GetModel("NT9DETAIL")
	//valida se o modelo existe
	If oModelGrid <> Nil
		For nI := 1 To oModelGrid:GetQtdLine()
			If !oModelGrid:IsDeleted( nI ) .And. !oModelGrid:IsEmpty( nI ) .And. oModelGrid:GetValue('NT9_TIPOEN', nI) == '2' .And. oModelGrid:GetValue('NT9_PRINCI', nI) == '1'
				cReu := (oModelGrid:GetValue('NT9_NOME', nI))
				Exit
			EndIf
		Next
	Endif

Return cReu

//-------------------------------------------------------------------
/*/{Protheus.doc} JA105Aut(cCajur)
Informa o nome do autor principal do processo
Uso no cadastro de Processos.
@param  oModel Modelo de dados do cadastro de processo
@return cAutor
@author Clóvis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA105Aut(oModel)
Local cAutor := ''
Local nI
Local oModelGrid := oModel:GetModel("NT9DETAIL")
	//valida se o modelo existe
	If oModelGrid <> Nil
		For nI := 1 To oModelGrid:GetQtdLine()
			If !oModelGrid:IsDeleted( nI ) .And. !oModelGrid:IsEmpty( nI ) .And. oModelGrid:GetValue('NT9_TIPOEN', nI) == '1' .And. oModelGrid:GetValue('NT9_PRINCI', nI) == '1'
				cAutor := (oModelGrid:GetValue('NT9_NOME', nI))
				Exit
			EndIf
		Next
	Endif

Return cAutor

//-------------------------------------------------------------------
/*/{Protheus.doc} J105NT9For
Função que habilita ou nao o preenchimento dos campos Fornecedor e loja
no cadsatro de envolvidos

@return lRet
@author Rodrigo Guerato
@since 15/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105NT9For()
Local lRet      := .T.
	If SuperGetMV('MV_JENVTAB',, '2') == '1'
		lRet := .T.
	Else
		lRet := (FwFldGet('NT9_TFORNE') == '1')
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J105NT9Cli
Função que habilita ou nao o preenchimento dos campos cliente e loja
no cadsatro de envolvidos
seja futura.
@return lRet
@author Clóvis Eduardo Teixeira
@since 06/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105NT9Cli()
Local lRet      := .T.
	If SuperGetMV('MV_JENVTAB',, '2') == '1'
		lRet := .T.
	Else
		lRet := (FwFldGet('NT9_TIPOCL') == '1')
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J105ATUNT9()
Função que replica a alteração dos campos: NSZ_CCLIEN e NSZ_LCLIEN, para a tabela de envolvidos (NT9)

@return lRet

@author Jacques Alves Xavier
@since 04/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105ATUNT9()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelNT9 := oModel:GetModel("NT9DETAIL")
Local nI        := 0
Local nLinAnt   := 0
Local cEntid    := SuperGetMV('MV_JENVENT',, '2')
Local cJFTJURI  := SuperGetMV('MV_JFTJURI',, '1')
	
	If oModelNT9 == NIL
		Return lRet
	Endif

	If cJFTJURI == '1'
		nLinAnt   := oModelNT9:getLine()
		
		For nI := 1 To oModelNT9:GetQtdLine()
			oModelNT9:GoLine(nI)
			If !oModelNT9:IsDeleted() .And. oModelNT9:GetValue("NT9_TIPOCL") == '1'
			
				//Atualiza o codigo da entidade
				If cEntid == '1' //Alterada condição para verificar apenas se é entidade origem, caso sim, ele seta apenas a Entidade e atualiza. Caso contrário, seta e atualiza o cliente e loja. 
					oModelNT9:SetValue("NT9_CODENT", FwFldGet("NSZ_CCLIEN") + FwFldGet("NSZ_LCLIEN"))
				Else
					oModelNT9:SetValue("NT9_CEMPCL", FwFldGet("NSZ_CCLIEN"))
					oModelNT9:SetValue("NT9_LOJACL", FwFldGet("NSZ_LCLIEN"))
				EndIf 
				oModelNT9:LoadValue("NT9_NOME" , AllTrim(SA1->A1_NOME) ) //Força a atualização do nome, que não estava sendo atualizado em alguns momentos
			EndIf
		Next

		oModelNT9:GoLine(nLinAnt)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA105FUN
Preenche as informações funcionais do envolvido conforme o cadastro de funcionários.
Uso no cadastro de Envolvidos.

@author Juliana Iwayama Velho
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA105FUN()
Local aArea    := GetArea()
Local aAreaSRA := SRA->( GetArea() )
Local oModel   := FWModelActive()
Local oModelNT9:= oModel:GetModel('NT9DETAIL')
Local cQuery   := ""
Local cAlias   := Nil
Local nI       := 0
Local lRet     := .T. 
Local aDePara  := {}
Local nTamRaFil:= TamSX3('RA_FILIAL')[1]

If SuperGetMV('MV_JINTERH',, '2') == '1'
	if !Empty(oModelNT9:GetValue("NT9_CGC"))
	
		cQuery := "SELECT SRA.R_E_C_N_O_ RARECNO "
		cQuery += " FROM "+RetSqlName("RD0")+" RD0,"+RetSqlName("SRA")+" SRA,"+RetSqlName("RDZ")+" RDZ"
		cQuery += " WHERE RD0_FILIAL = '" + xFilial( "RD0" ) + "'"
		cQuery += " AND RA_FILIAL = '" + xFilial("SRA") + "'"
		cQuery += " AND RDZ_FILIAL = '" + xFilial("RDZ") + "'"
		cQuery += " AND RDZ_CODRD0 = RD0_CODIGO "
		cQuery += " AND RDZ_ENTIDA = 'SRA' "
		cQuery += " AND RA_FILIAL = SUBSTRING( RDZ_CODENT, 1," + AllTrim( Str( nTamRaFil ) ) + ")"
		cQuery += " AND RA_MAT    = SUBSTRING( RDZ_CODENT, " + AllTrim( Str( nTamRaFil + 1 ) )  + "," + AllTrim( Str( TamSX3('RA_MAT')[1] ) ) + ")"
		cQuery += " AND SRA.D_E_L_E_T_ = ' '"
		cQuery += " AND RD0.D_E_L_E_T_ = ' '"
		cQuery += " AND RDZ.D_E_L_E_T_ = ' '"
		cQuery += " AND SRA.RA_CIC = '"+AllTrim(oModelNT9:GetValue("NT9_CGC"))+"'"
		cQuery := ChangeQuery(cQuery)

		uRetorno := ''

		cAlias := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .T., .F. )
		uRetorno := (cAlias)->RARECNO

		If !Empty(uRetorno)

			SRA->( dbGoto( uRetorno ) )

			aDePara := {}
			aAdd( aDePara, { "NT9_NOME"  ,SRA->RA_NOMECMP} )
			aAdd( aDePara, { "NT9_DTADM" ,SRA->RA_ADMISSA } )
			aAdd( aDePara, { "NT9_DTNASC",SRA->RA_NASC    } )
			aAdd( aDePara, { "NT9_DTDEMI",SRA->RA_DEMISSA } )
			aAdd( aDePara, { "NT9_EMAIL" ,SRA->RA_EMAIL   } )
			aAdd( aDePara, { "NT9_TELEFO",SRA->RA_TELEFON } )
			aAdd( aDePara, { "NT9_CTPS"  ,SRA->RA_NUMCP   } )
			aAdd( aDePara, { "NT9_SERIE" ,SRA->RA_SERCP   } )
			aAdd( aDePara, { "NT9_VLRUSA",SRA->RA_SALARIO } )
			aAdd( aDePara, { "NT9_PIS"   ,SRA->RA_PIS     } )
			aAdd( aDePara, { "NT9_CCRGDP",SRA->RA_CARGO   } )
			aAdd( aDePara, { "NT9_CFUNDP",SRA->RA_CODFUNC } )

			oModelNT9:SetValue("NT9_NOME"  ,SRA->RA_NOMECMP)

			//Erro no setValue - pendente framework
			For nI := 1 To Len( aDePara )
				If !oModelNT9:SetValue(aDePara[nI][1],aDePara[nI][2])
					lRet := JurMsgErro( STR0021 + aDePara[nI][1] + STR0022 + AllToChar( aDePara[nI][2] ) ) //"Erro Integração RH: Campo / Conteudo = "
					Exit
				EndIf
			Next
		EndIf
		(cAlias)->( dbcloseArea() )
	Else
		lRet := JurMsgErro( STR0023 +RetTitle('NT9_CGC'))//"É necessário preencher o(s) campo(s) de"
	EndIf
EndIf

RestArea( aAreaSRA )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J105SelEnt

Função que abre uma janela onde o usuário pode escolher algumas entidades
para buscar informações que serão preenchidas na aba de Envolvidos

@Return lRet .T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105SelEnt()
Local aArea      := GetArea()					// Salva a area atual	
Local alEntida   := {}
Local aEntSXB    := {}
Local aEntidades := {}							// Contem as entidades da tabela T5 (Entidades do contato)
Local aOpcoes    := {}		         			// Contem as entidades da tabela T5 (Radio)
Local nI         := 0							// Contador
Local cCodigo    := ""							// Codigo da entidade
Local cLoja      := ""        				    // Loja da Entidade
Local cFilialEnt := ""        				    // Filial da Entidade
Local nOpAlias   := 1							// Variavel com a opcao selecionada da entidade para o F3 - Default 1 = SA1
Local nOpcA      := 0							// Opcao ao confirmar a tela de selecao de entidades 
Local cEntidade  := ""							// Alias da Entidade Selecionada
Local cChave     := ""							// Filial, Codigo e loja da entidade selecionada
Local cNome      := ""							// Nome da Entidade
Local cCgc       := ""							// Cnpj/Cpf da Entidade
Local cEndereco	 := ""							// Endereco da Entidade
Local cBairro	 := ""							// Bairro da Entidade
Local cCidade	 := ""							// Cidade da Entidade
Local cEstado	 := ""							// EStado da Entidade
Local cTelefone	 := ""							// Telefone da Entidade
Local nLengthCod := 0                           //Tamanho do campo código da entidade  
Local cBVCampo   := "J105EntDados(cEntidade,cFilialEnt,cCodigo,cLoja, @cNome, @oNome, @cCgc, @oCgc,@cEndereco, @oEndereco, @cTelefone, @oTelefone,@cBairro, @oBairro,@cEstado,@oEstado, @cCidade, @oCidade)"
Local cBSetF3    := "nEntSXB := aScan(aEntSXB,{|x| x[1] == aEntidades[nOpAlias,1]}),IIF(nEntSXB==0,aEntidades[nOpAlias,1],aEntSXB[nEntSXB][2])"
//Objetos
Local oDlgEnt                         			// Tela
Local oEntidade									// Objeto Radio na selecao de entidades
Local oCodigo									// Objeto Get para o codigo da entidade
Local oLoja										// Objeto Get para a loja da entidade
Local oNome										// Objeto Get para o nome da entidade
Local oCgc										// Objeto Get para o cnpj/cpf da entidade
Local oEndereco									// Objeto Get para o endereco da entidade
Local oBairro									// Objeto Get para o bairro da entidade
Local oCidade									// Objeto Get para a cidade da entidade
Local oEstado									// Objeto Get para o estado da entidade
Local oTelefone									// Objeto Get para o telefone da entidade
Local oBtnAlt									// Objeto Button para alteracao de entidades        
Local nPosalEnt	:= 0
Local nLargColFi:= 0

	//Carrega campos das entidades
	Aadd(alEntida, {"SA1", "A1_COD"		, "A1_LOJA", "A1_FILIAL" } )
	Aadd(alEntida, {"SA2", "A2_COD"		, "A2_LOJA", "A2_FILIAL" } )
	Aadd(alEntida, {"SU5", "U5_CODCONT", "", "U5_FILIAL" } )
	Aadd(alEntida, {"SRA", "RA_MAT"		, "", "RA_FILIAL" } )	
	Aadd(alEntida, {"NZ2", "NZ2_COD"	, "", "NZ2_FILIAL"} )

	//Carrega consultas
	Aadd(aEntSXB, {"SA1", GetSx3Cache("NT9_CEMPCL","X3_F3")} )
	Aadd(aEntSXB, {"SU5", "SU5JUR"} )
	Aadd(aEntSXB, {"SA2", GetSx3Cache("NT9_CFORNE","X3_F3")} )
	Aadd(aEntSXB, {"NZ2", "NZ2"   } )

	//Verifica se esta ativo a consulta de funcionairos com multi filiais
	If SuperGetMv("MV_JCONFUN", , "1") == "2"
		Aadd(aEntSXB, {"SRA", "JSXBRA"} )
	Else
		Aadd(aEntSXB, {"SRA", "JURSRA"} )
	EndIf

	//Pega o campo de funcionario para calcular o tamanho da coluna da filial, porque ela pode ser a maior
	nLargColFi := TamSX3("RA_FILIAL")[1] * 4		
				
	INCLUI := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as entidades utilizadas na tabela T5.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to LEN(alEntida)
		Aadd(aEntidades,{	alEntida[nI][1], TRIM(JurX2Nome(alEntida[nI][1]))})
	Next
						
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indexa o array pela descricao dos arquivos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEntidades:= ASort(aEntidades,,,{|x,y| x[2] < y[2]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta o array com as entidades que serao exibidas para o usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AEval( aEntidades, { |x| AAdd( aOpcoes, x[2] ) } ) 	

	If !Empty(FwFldget("NT9_ENTIDA")) .And. Ascan(alEntida, {|x| x[1] == FwFldget("NT9_ENTIDA")} ) > 0  
		cEntidade := FwFldget("NT9_ENTIDA")
	Else
		cEntidade := aEntidades[nOpAlias,1]
	EndIf
		
	//Inicializa o tamanho da variável baseado no tamanho do campo de código (<*>)
	nPosalEnt 	:= Ascan(alEntida,{|x| x[1] == cEntidade})
	cCodigo 	:= Space(TamSX3(alEntida[nPosalEnt][2])[1])
	cLoja		:= Iif(!Empty(alEntida[nPosalEnt][3]),Space(TamSX3(alEntida[nPosalEnt][3])[1]),"")
	cFilialEnt  := Space(TamSX3(alEntida[nPosalEnt][4])[1])
	//cEntFilial  := IIf(Empty(oM:GetValue("NT9DETAIL","NT9_ENVFIL")), cEntFilial, oM:GetValue("NT9DETAIL","NT9_ENVFIL"))
	nOpAlias	:= Iif(Empty(cEntidade),nOpAlias,aScan(aEntidades,{|x|x[1] == cEntidade}))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra os dados do envolvido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgEnt FROM  0,0 TO 230,700 TITLE STR0034  PIXEL // "Seleção de Entidades"  

		@ 003,005 TO 094,100 LABEL STR0035		OF oDlgEnt  PIXEL	// "Entidades"
		@ 003,105 TO 094,345 LABEL STR0036		OF oDlgEnt  PIXEL	// "Informações da entidade"
		
		
		@ 12,110 SAY STR0037 SIZE 50,8 OF oDlgEnt PIXEL //"Código:"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
		@ 12,200 SAY STR0038 SIZE 30,8 OF oDlgEnt PIXEL //"Loja"
		//@ 12,235 SAY STR0055 SIZE 30,8 OF oDlgEnt PIXEL //"Filial:"
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria os radioboxes pelo constructor para garantir que todos na consulta T5  sejam criados        ³
		//³Alem disso, o evento CHANGE de cada radiobox vai atualizar a consulta F3 de acordo com a entidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oEntidade:= TRadMenu():New(10, 10, aOpcoes,;
									bSETGET(nOpAlias), oDlgEnt , NIL ,;
									{|| nOpAlias 	:= oEntidade:nOption											 ,;
										cEntidade 	:= aEntidades[nOpAlias,1]										 ,;
										nPosalEnt 	:= Ascan(alEntida,{|x| x[1] == cEntidade}) 						 ,;
										cCodigo     := Space(TamSX3(alEntida[nPosalEnt][2])[1]), oCodigo:Refresh()	 ,;	
										cLoja       := Iif(!Empty(alEntida[nPosalEnt][3]),Space(TamSX3(alEntida[nPosalEnt][3])[1]),""), oLoja:Refresh()	 ,;
										cFilialEnt  := Space(TamSX3(alEntida[nPosalEnt][4])[1]), oFilialEnt:Refresh(),;
										oCodigo:cF3 := Eval(&("{|| " + cBSetF3 + "}"))							 	 ,;
										Eval(&("{|| " + cBVCampo + "}"))	}							 			 ,;
									NIL, NIL, NIL, .T., NIL,;
									80, 10, NIL, .T., .T., .T. )
		
		@ 26,110 SAY STR0039 SIZE 40,10 OF oDlgEnt PIXEL 					// "Razão Social: "
		@ 36,110 SAY STR0040 SIZE 30,10	OF oDlgEnt PIXEL 			        // "Cpf/Cnpj: "
		@ 46,110 SAY STR0041 SIZE 30,10 OF oDlgEnt PIXEL 					// "Endereço: "
		@ 56,110 SAY STR0042 SIZE 30,10	OF oDlgEnt PIXEL 					// "Bairro :"
		@ 56,250 SAY STR0043 SIZE 25,10 OF oDlgEnt PIXEL 					// "Cidade: "
		@ 66,110 SAY STR0044 SIZE 30,10	OF oDlgEnt PIXEL 					// "Telefone: "		
		
		//Campos para gatilho  de codigos da entidade.
		oCodigo 	:= TGet():New(011,145,{|u| if(Pcount()>0, cCodigo := u	 , cCodigo)}	, oDlgEnt, 055		 , 8,;
							"@!", {||(cChave := cCodigo							, Eval(&("{|| " + cBVCampo + "}")),.T.)},,,,,,.T.,,,,,,,,,Eval(&("{|| " + cBSetF3 + "}")),,,,,.T.)
		
		oLoja   	:= TGet():New(011,215,{|u| if(Pcount()>0, cLoja	:= u	 , cLoja)}  	, oDlgEnt, 010		 , 8,;
							"@!", {||(cChave := LTrim(cFilialEnt)+cCodigo+cLoja	, Eval(&("{|| " + cBVCampo + "}")),.T.)},,,,,,.T.,,,,,,,,,,,,,,.T.)
		
		oFilialEnt 	:= TGet():New(011,250,{|u| if(Pcount()>0, cFilialEnt := u, cFilialEnt)}	, oDlgEnt, nLargColFi, 8,;
							"@!", {||(cChave := LTrim(cFilialEnt)+cCodigo+cLoja	, Eval(&("{|| " + cBVCampo + "}")),.T.)},,,,,,.T.,,,,,,,,,,,,,,.T.)
							
		// MsGet com os dados da entidade		  						
		@ 25,145 MSGET oNome 		VAR cNome 		SIZE 195,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
		@ 35,145 MSGET oCgc		 	VAR cCgc		SIZE 100,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
		@ 45,145 MSGET oEndereco 	VAR cEndereco	SIZE 195,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
		@ 55,145 MSGET oBairro 		VAR cBairro		SIZE 120,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.  
		@ 55,245 MSGET oCidade 		VAR cCidade		SIZE 080,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.  
		@ 55,325 MSGET oEstado 		VAR cEstado 	SIZE 015,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.   
		@ 65,145 MSGET oTelefone	VAR cTelefone  	Picture "@R 999 9999999999" SIZE 060,8 OF oDlgEnt PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.  
		
		@ 80,110 BUTTON oBtnAlt PROMPT STR0045	SIZE 30,10 PIXEL;	//"Novo"
			WHEN (cEntidade=="NZ2");
			ACTION (J105OpPar(cFilialEnt,cCodigo,cLoja,3),;
			cCodigo := NZ2->NZ2_COD, oCodigo:Refresh(),;
		cChave := LTrim(cFilialEnt) + cCodigo,;
			Eval(&("{|| " + cBVCampo + "}")));
			OF oDlgEnt
			
		@ 80,145 BUTTON oBtnAlt PROMPT STR0004	SIZE 30,10 PIXEL;	//"Alterar"
			WHEN (cEntidade=="NZ2" .And. !Empty(cChave));
			ACTION (J105OpPar(cFilialEnt,cCodigo,cLoja,4),;
			Eval(&("{|| " + cBVCampo + "}")));
			OF oDlgEnt 
		
		DEFINE SBUTTON FROM 100,275 TYPE 1	ENABLE OF oDlgEnt ACTION IIF(J105VldEnt(cEntidade,cFilialEnt,cCodigo,cLoja),(J105SetDados(cEntidade,cChave),nOpcA:=1,oDlgEnt:End()),)//OK
		DEFINE SBUTTON FROM 100,315 TYPE 2 	ENABLE OF oDlgEnt ACTION (nOpcA:=0, oDlgEnt:End()) 					//CANCELA
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a tela foi acionada pela segunda vez na rotina, exibe os³
		//³dados preenchidos anteriormente                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !EMPTY(cChave:= RTrim(FwFldget("NT9_CODENT")))
			//Caso a chave não esteja em branco, preencher os campos
			//Obs: A filial nem sempre estará preenchida
			If !Empty(cChave) 
				If cEntidade $ "SA1/SA2"
					If cEntidade == 'SA1'
						cCodigo := FwFldget("NT9_CEMPCL")
						cLoja   := FwFldget("NT9_LOJACL") 
					Else
						cCodigo := FwFldget("NT9_CFORNE")
						cLoja   := FwFldget("NT9_LFORNE")
					Endif
					nLengthCod  := AT(cCodigo+cLoja,cChave)
					
					If nLengthCod > 1
						cFilialEnt  := SubStr(cChave,1,nLengthCod-1)
					Endif
										
					oCodigo:Refresh()
					oLoja:Refresh()
			
				Else
					If cEntidade == 'SU5'
						nLengthCod := TamSX3('U5_CODCONT')[1]
					Elseif cEntidade == 'SRA'	
						nLengthCod := TamSX3('RA_MAT')[1]
					Elseif cEntidade == 'NZ2'	
						nLengthCod := TamSX3('NZ2_COD')[1]
					Endif
					
					cFilialEnt := SubStr(cChave,1, Len(xFilial(cEntidade)))
					cCodigo    := SubStr(cChave, Len(cFilialEnt) + 1, nLengthCod)

					oCodigo:Refresh()
									
				Endif
				
				Eval(&("{|| " + cBVCampo + "}"))
			Endif
			oCodigo:Refresh()	
		EndIf
		//Posiciona o foco no controle que recebe o código
		oCodigo:SetFocus()

		
	ACTIVATE MSDIALOG oDlgEnt CENTER                

	RestArea(aArea)

Return(nOpcA ==1)


//-------------------------------------------------------------------
/*/{Protheus.doc} J105EntDados

Função que le os dados da entidade selecionada e preenche os visores na tela de 
seleção de entidades

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105EntDados(cEntidade, cFilialEnt, cCodigo, cLoja, cNome, oNome, cCgc, oCgc, cEndereco,;
 oEndereco, cTelefone, oTelefone, cBairro, oBairro, cEstado, oEstado, cCidade, oCidade)
Local aArea      := GetArea()
Local aCampos    := {}
Local nPos       := 0
Local aAreaEnt   := (cEntidade)->(GetArea())
Local cPesquisa  := ''
Local aCmpsDisp  := {}

//Campos padrão das entidades
// ENTIDADE, {1 - CHAVE, 2 - NOME, 3 - TELEFONE, 4 - CPF/CNPJ, 5 - ENDEREÇO, 6 - BAIRRO, 7 - ESTADO, 8 - CIDADE, 9 - DDD
aAdd(aCampos,{"SA1",{"A1_FILIAL+A1_COD+A1_LOJA","A1_NOME","A1_TEL","A1_CGC","A1_END","A1_BAIRRO","A1_EST","A1_COD_MUN","A1_DDD"}})
aAdd(aCampos,{"SA2",{"A2_FILIAL+A2_COD+A2_LOJA","A2_NOME","A2_TEL","A2_CGC","A2_END","A2_BAIRRO","A2_EST","A2_COD_MUN","A2_DDD"}})
aAdd(aCampos,{"SU5",{"U5_FILIAL+U5_CODCONT","U5_CONTAT","U5_FONE","U5_CPF","U5_END","U5_BAIRRO","U5_EST","U5_MUN","U5_DDD"}})
aAdd(aCampos,{"NZ2",{"NZ2_FILIAL+NZ2_COD","NZ2_NOME","NZ2_TELEFO","NZ2_CGC","NZ2_ENDE","NZ2_BAIRRO","NZ2_ESTADO","NZ2_CMUNIC","NZ2_DDD"}})
aAdd(aCampos,{"SRA",{"RA_FILIAL+RA_MAT","RA_NOMECMP","RA_TELEFON","RA_CIC","RA_ENDEREC","RA_BAIRRO","RA_ESTADO","RA_MUNICIP","RA_DDDFONE"}})

nPos := aScan(aCampos, {|x| x[1]==cEntidade})

aCmpsDisp := JCmpDispPD(aCampos[nPos][2])

If Empty(cFilialEnt) 
	cPesquisa := xFilial(cEntidade) + cCodigo + cLoja
Else	
	cPesquisa := cFilialEnt + cCodigo + cLoja
Endif

(cEntidade)->( dbSetOrder(1) )
If (cEntidade)->( dbSeek(cPesquisa) )
	cNome     := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][2]) > 0 , (cEntidade)->&(aCampos[nPos][2][2]), '*****')
	cCgc      := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][4]) > 0 , (cEntidade)->&(aCampos[nPos][2][4]), '*****')
	cTelefone := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][3]) > 0 , (cEntidade)->&(aCampos[nPos][2][9]) + (cEntidade)->&(aCampos[nPos][2][3]) , '*****')
	cEndereco := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][5]) > 0 , (cEntidade)->&(aCampos[nPos][2][5]), '*****')
	cBairro   := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][6]) > 0 , (cEntidade)->&(aCampos[nPos][2][6]), '*****')
	cEstado   := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][7]) > 0 , (cEntidade)->&(aCampos[nPos][2][7]), '*****')
	cCidade   := Iif( Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nPos][2][8]) > 0 , Eval(&("{|| JurGetDados('CC2',1,xFilial('CC2')+'" + (cEntidade)->&(aCampos[nPos][2][7]) + (cEntidade)->&(aCampos[nPos][2][8]) + "','CC2_MUN')}")), '*****')
Else
	cNome     := ""
	cCgc      := ""
	cTelefone := ""
	cEndereco := ""
	cBairro   := ""
	cEstado   := ""
	cCidade   := ""
Endif

oNome:Refresh()
oCgc:Refresh()
oEndereco:Refresh()
oTelefone:Refresh()
oBairro:Refresh()
oEstado:Refresh()
oCidade:Refresh()

RestArea(aAreaEnt)
RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} J105SetDados

Função que grava os dados nos campos da NT9, provenientes da tela de 
seleção de entidades

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105SetDados(cEntidade	,cChave)

_cEntidade := cEntidade
_cChave := cChave

/* comentado porque na versão 12 depois da mudança do frame de usar FWLookUp para todas as consultas, isso não esta funcionando.
M->NT9_ENTIDA := cEntidade
M->NT9_CODENT := cChave
*/

Return cEntidade

//-------------------------------------------------------------------
/*/{Protheus.doc} J105LoadE

Função que é executada no gatilho do campo NT9_CODENT, responsável por 
preencher os dados de forma automática da NT9, a partir de outras entidades.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105LoadE()
Local oModel     := FwModelActive()
Local cEntidade  := IIF(EMPTY(FWFLDGET("NT9_ENTIDA")),_cEntidade,oModel:GetValue("NT9DETAIL","NT9_ENTIDA"))
Local aArea      := GetArea()
Local nLinha     := oModel:GetModel("NT9DETAIL"):nLine
Local aAreaEnt   := (cEntidade)->(GetArea())
Local cChave     := IIF(EMPTY(FWFLDGET("NT9_CODENT")),_cChave,oModel:GetValue("NT9DETAIL","NT9_CODENT"))
Local aCampNT9   := {"NT9_CEMPCL","NT9_LOJACL","NT9_NOME","NT9_CFORNE","NT9_LFORNE","NT9_DDD","NT9_TELEFO","NT9_EMAIL","NT9_ESTADO","NT9_RG","NT9_CMUNIC","NT9_BAIRRO","NT9_INSCR","NT9_INSCRM","NT9_CESTCV","NT9_DTADM","NT9_DTNASC","NT9_DTDEMI","NT9_CTPS","NT9_SERIE","NT9_VLRUSA","NT9_PIS","NT9_CCRGDP","NT9_CFUNDP","NT9_CEP","NT9_CADVPC","NT9_ENDECL"}
Local aCampDest	 := {} // 26 campos por enquanto
Local oStructNT9 := oModel:GetModel("NT9DETAIL"):GetStruct()
Local nI         := 0
Local lAux       := .T.
Local lBkpNoUpd  := .F.
Local bBkpWhen   := {|| .T.}
Local nTamCod    := ""
Local nTamLoja   := ""

//Campos Sim/Não
Do Case
	Case cEntidade == "SA1"
		oModel:SetValue("NT9DETAIL","NT9_TIPOCL","1")  //Cliente sim
		oModel:SetValue("NT9DETAIL","NT9_TFORNE","2") //fornecedor não
		aCampDest := {"A1_COD","A1_LOJA","A1_NOME","","","A1_DDD","A1_TEL","A1_EMAIL","A1_EST","A1_RG","A1_COD_MUN","A1_BAIRRO","A1_INSCR","A1_INSCRM","","","","","","","","","","","A1_CEP","","A1_END"}
	
 		//Campo tipo pessoa, de/para NT9 x NZ2.
		aAdd(aCampNT9,"NT9_TIPOP")
		aAdd(aCampDest,"IIF((cEntidade)->A1_PESSOA=='F','1','2')")		
		aAdd(aCampNT9,"NT9_CGC")
		aAdd(aCampDest,"A1_CGC")
	Case cEntidade == "SU5"
		oModel:SetValue("NT9DETAIL","NT9_TIPOCL","2") //cliente não
		oModel:SetValue("NT9DETAIL","NT9_TFORNE","2") //fornecedor não
		oModel:LoadValue("NT9DETAIL","NT9_TIPOP","1") // pessoa física
		aCampDest := {"","","U5_CONTAT","","","U5_DDD","U5_FONE","U5_EMAIL","U5_EST","U5_RG","","U5_BAIRRO","","","","","","","","","","","","","U5_CEP","","U5_END"}
		aAdd(aCampNT9,"NT9_CGC")
		aAdd(aCampDest,"U5_CPF")
	Case cEntidade == "SA2"
		oModel:SetValue("NT9DETAIL","NT9_TIPOCL","2") //cliente não
		oModel:SetValue("NT9DETAIL","NT9_TFORNE","1") //fornecedor sim
		aCampDest := {"","","A2_NOME","A2_COD","A2_LOJA","A2_DDD","A2_TEL","A2_EMAIL","A2_EST","A2_PFISICA","A2_COD_MUN","A2_BAIRRO","A2_INSCR","A2_INSCRM","","","","","","","","","","","A2_CEP","","A2_END"}
		
		//Campo tipo pessoa, de/para NT9 x NZ2.
		aAdd(aCampNT9,"NT9_TIPOP")
		aAdd(aCampDest,"IIF((cEntidade)->A2_TIPO=='F','1','2')")
		aAdd(aCampNT9,"NT9_CGC")
		aAdd(aCampDest,"A2_CGC")
	Case cEntidade == "SRA"
		oModel:SetValue("NT9DETAIL","NT9_TIPOCL","2") //cliente não
		oModel:SetValue("NT9DETAIL","NT9_TFORNE","2") //fornecedor não
		oModel:LoadValue("NT9DETAIL","NT9_TIPOP","1") // pessoa física
		
		aCampDest := {"","","RA_NOMECMP","","","RA_DDDFONE","RA_TELEFON","RA_EMAIL","RA_ESTADO","RA_RG","","RA_BAIRRO","","","RA_ESTCIVI","RA_ADMISSA","RA_NASC","RA_DEMISSA","RA_NUMCP","RA_SERCP","RA_SALARIO","RA_PIS","RA_CARGO","RA_CODFUNC","RA_CEP","","RA_ENDEREC","RA_CIC"}
		aAdd(aCampNT9,"NT9_CGC")
		cChave := ALLTRIM(cChave)
	Case cEntidade == "NZ2"
		oModel:SetValue("NT9DETAIL","NT9_TIPOCL","2") //cliente não
		oModel:SetValue("NT9DETAIL","NT9_TFORNE","2") //fornecedor não
		aCampDest := {"","","NZ2_NOME","","","NZ2_DDD","NZ2_TELEFO","NZ2_EMAIL","NZ2_ESTADO","NZ2_RG","NZ2_CMUNIC","NZ2_BAIRRO","","","","","","","","","","","","","NZ2_CEP","NZ2_CADVPC","NZ2_ENDE"}
		
		//Campo tipo pessoa, de/para NT9 x NZ2.
		aAdd(aCampNT9,"NT9_TIPOP")
		aAdd(aCampDest,"NZ2_TIPOP")
		aAdd(aCampNT9,"NT9_CGC")
		aAdd(aCampDest,"NZ2_CGC")
	Otherwise
		Alert("Inclusão não implementada.")                             
EndCase

//Sugere principal quando é a primeira linha e não for distribuição
If oModel:GetModel("NT9DETAIL"):GetQtdLine() == 1 .And. !IsInCallStack("JURA219")
	oModel:SetValue("NT9DETAIL","NT9_PRINCI","1") //ùnica linha, principal = Sim.
Endif

//preenche os demais campos
(cEntidade)->( dbSetOrder(1) )

//-- Trata a chave composta de cliente (SA1) e Fornecedor (SA2) quando recebe dados do TOTVS Jurídico
If ( JModRst() ) .AND. cEntidade == "SA1" .OR. cEntidade == "SA2" 

	nTamCod  := Len( (cEntidade)->&( RIGHT(cEntidade, 2) + "_COD" ) )
	nTamLoja := Len( (cEntidade)->&( RIGHT(cEntidade, 2) + "_LOJA" ) )

	cChave := PadR( Substr( RTRIM(cChave),1,Len(RTRIM(cChave))-nTamLoja ), nTamCod, " " ) + RIGHT( RTRIM(cChave),nTamLoja )
EndIf

If (cEntidade)->( dbSeek(xFilial(cEntidade) + cChave) ) .Or. (cEntidade)->( dbSeek(cChave) )
 	For nI := 1 to len(aCampNT9) 
		lAux := .T.
		If !Empty(aCampDest[nI]) //Valida se o campo de origem da informação existe no de/para de origem
		
			//Salva propriedade dos campos
			lBkpNoUpd := oStructNT9:GetProperty( aCampNT9[nI], MODEL_FIELD_NOUPD)
			bBkpWhen  := oStructNT9:GetProperty( aCampNT9[nI], MODEL_FIELD_WHEN )
		
			//Libera o campo para edição
			If oStructNT9:hasField(aCampNT9[nI]) .and. lAux
				oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_NOUPD, .F. )
				oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_WHEN, {|| .T.} )
			Endif
			If (len(aCampDest[nI])<=10) //valida se é um campo ou alguma fórmula
				//valida se o campo existe.
				If ((cEntidade)->( FieldPos(aCampDest[nI]) )) > 0
					//Se for caracter, usa o substr para previnir problemas com tamanho de campo
					If AllTrim(aCampNT9[nI]) $ "NT9_CEMPCL/NT9_LOJACL/NT9_CFORNE/NT9_LFORNE/NT9_CCRGDP"
						oModel:LoadValue("NT9DETAIL",(aCampNT9[nI]),SubStr(((cEntidade)->&(aCampDest[nI])),1,TamSX3(aCampNT9[nI])[1]))
					else
						If ValType((cEntidade)->&(aCampDest[nI])) == "C"
							lAux := oModel:SetValue("NT9DETAIL",(aCampNT9[nI]),SubStr(((cEntidade)->&(aCampDest[nI])),1,TamSX3(aCampNT9[nI])[1]))
								If !lAux
								Alert("Campo "+aCampNT9[nI]+" não implementado com "+ SubStr(((cEntidade)->&(aCampDest[nI])),1,TamSX3(aCampNT9[nI])[1])+", devido a problemas de validação.")
							EndIf                           
						Else
							lAux := oModel:SetValue("NT9DETAIL",(aCampNT9[nI]),((cEntidade)->&(aCampDest[nI])))
							If !lAux
								Alert("Campo "+aCampNT9[nI]+" não implementado com "+((cEntidade)->&(aCampDest[nI]))+", devido a problemas de validação.")
							EndIf
						EndIf
					Endif
				Endif
			Else
				lAux := oModel:SetValue("NT9DETAIL",(aCampNT9[nI]),Eval(&("{||" + aCampDest[nI] + "}")))
				If !lAux
					Alert("Campo "+aCampNT9[nI]+" não implementado com "+ Eval(&("{||" + aCampDest[nI] + "}"))+", devido a problemas de validação.")
				EndIf
			Endif
			
			//Volta o campo para modo de edição padrao
			If IsInCallStack("JURA219")	

				If oStructNT9:hasField(aCampNT9[nI]) 
					oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_NOUPD	, lBkpNoUpd )
					oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_WHEN	, bBkpWhen  )
				Endif
				
			//Deixa o campo como somente leitura
			Else
			
				If oStructNT9:hasField(aCampNT9[nI]) .and. lAux .and. (cEntidade <> "NZ2") .and. (cEntidade <> "SRA") 
					oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_NOUPD, .T. )
					oStructNT9:SetProperty( aCampNT9[nI], MODEL_FIELD_WHEN, {|| .F.} )
				Endif
			EndIf
			/*else 
							//JurMsgErro("Valor do campo " + RetTitle("NT9_ENTIDA") + " inválido.")
							JurMsgErro(STR0052 + STR0053)*/
		Endif
		oModel:SetValue("NT9DETAIL","NT9_CODENT",cChave)
	Next
	endIf
	 
 
RestArea(aAreaEnt)
RestArea(aArea)

Return oModel:GetValue("NT9DETAIL","NT9_CODENT",nLinha)
//-------------------------------------------------------------------
/*/{Protheus.doc} J105VldEnt

Função que valida o codigo da entidade

@Return lRet .T./.F. As informações são válidas ou não

@author Beatriz Gomes
@since 05/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105VldEnt(cEntidade,cFilialEnt,cCodigo,cLoja)
Local lRet := .F.

	(cEntidade)->( dbSetOrder(1) )

	If Empty(cFilialEnt)
		cFilialEnt := xFilial(cEntidade) 
	EndIf

	If (cEntidade)->( dbSeek(cFilialEnt + cCodigo + cLoja) )
		lRet := .T.
	Else
		lRet := JurMsgErro(STR0052 + STR0053)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J105OpPar

Função que vai receber os dados da parte contrária selecionada 
e vai abrir a o modelo no modo de alteração ou modo inclusão.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105OpPar(cFilialEnt,cCodigo,cLoja, nOper)
Local aArea   := GetArea()
Local lFilial := FWModeAccess("NZ2",1) == "E" .And. FWModeAccess("NZ2",2) == "E" .And. FWModeAccess("NZ2",3) == "E"
Local cFilNz2 := IIF(lFilial,cFilAnt,xFilial("NZ2"))
Local nRet
Local cPesquisa := ''

Default nOper := 4

If Empty(cFilialEnt)
	cPesquisa := cFilNz2 + cCodigo + cLoja
Else
	cPesquisa := cFilialEnt + cCodigo + cLoja
Endif

If nOper == 4 
	NZ2->(DBSetOrder(1))
	NZ2->(dbSeek(cPesquisa))
	
	nRet := FWExecView( STR0004, 'JURA184', 4,, { || .T. },,10 ) // "Alterar"
Else
	nRet := FWExecView( STR0046, 'JURA184', 3,, { || .T. },,10 ) // "Inclusão"
Endif


RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J105UPDATE
Função que atualiza a NT9 com base nas entidades externas (SA1, SA2, SU5 e SRA.


@param aParam  Parâmetro utilizado internamente, recebido pelo Schedule
@param cFilNT9 Parâmetro opcional que deve ser utilizado quando é preciso
limitar os registros que devem ser alterados, tendo como base filial na tabela NT9.
@param cCajuri Parâmetro opcional que deve ser utilizado quando é preciso
limitar os registros que devem ser alterados, tendo como base o Cajuri.

@author André Spirigoni Pinto
@since 23/12/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J105UPDATE(aParam, cFilNT9, cCajuri)
Local aArea     := GetArea()
Local aEntidade := {}
Local cAliasQry
Local cQuery
Local nI
Local nC
Local cEntFil
Local aCampNT9 := {"NT9_NOME","NT9_CGC","NT9_DDD","NT9_TELEFO","NT9_EMAIL","NT9_ESTADO","NT9_RG","NT9_CMUNIC","NT9_BAIRRO","NT9_INSCR","NT9_INSCRM","NT9_CESTCV","NT9_DTADM","NT9_DTNASC","NT9_DTDEMI","NT9_CTPS","NT9_SERIE","NT9_VLRUSA","NT9_PIS","NT9_CCRGDP","NT9_CFUNDP","NT9_CEP","NT9_CADVPC","NT9_ENDECL"}
Local oCompara := "" //variável usada na comparação de valores, pois os campos so são atualizados caso o valor seja diferente
Local nQtd := 0 //quantidade de registros afetados.
Local lAmbiente := .F. //avalia se o ambiente está montado.

Default cFilNT9 := ""
Default cCajuri := ""
Default aParam  := {}

aAdd(aEntidade,{"SA1",{"A1_FILIAL+A1_COD+A1_LOJA","A1_NOME","A1_CGC","A1_DDD","A1_TEL","A1_EMAIL","A1_EST","A1_RG","A1_COD_MUN","A1_BAIRRO","A1_INSCR","A1_INSCRM","","","","","","","","","","","A1_CEP","","A1_END"}})
aAdd(aEntidade,{"SA2",{"A2_FILIAL+A2_COD+A2_LOJA","A2_NOME","A2_CGC","A2_DDD","A2_TEL","A2_EMAIL","A2_EST","A2_PFISICA","A2_COD_MUN","A2_BAIRRO","A2_INSCR","A2_INSCRM","","","","","","","","","","","A2_CEP","","A2_END"}})
aAdd(aEntidade,{"SU5",{"U5_FILIAL+U5_CODCONT","U5_CONTAT","U5_CPF","U5_DDD","U5_FONE","U5_EMAIL","U5_EST","U5_RG","U5_MUN","U5_BAIRRO","","","U5_CIVIL","","","","","","","","","","U5_CEP","","U5_END"}})
aAdd(aEntidade,{"SRA",{"RA_FILIAL+RA_MAT","RA_NOMECMP","RA_CIC","RA_DDDFONE","RA_TELEFON","RA_EMAIL","RA_ESTADO","RA_RG","","RA_BAIRRO","","","RA_ESTCIVI","RA_ADMISSA","RA_NASC","RA_DEMISSA","RA_NUMCP","RA_SERCP","RA_SALARIO","RA_PIS","RA_CARGO","RA_CODFUNC","RA_CEP","","RA_ENDEREC"}})

ConOut(i18n(STR0047,{JurTimeStamp()})) //"#1: Iniciando rotina de atualização dos dados de envolvidos."

if type("cFilAnt") == "U" .And. len(aParam)>0
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]
	lAmbiente := .T.
Endif

//Valida ambiente

cAliasQry := GetNextAlias()

For nI := 1 to len(aEntidade)
	
	//Configura a filial da entidade de destino.
	cEntFil := FwxFilial(aEntidade[nI][1],cFilAnt,FWModeAccess(aEntidade[nI][1],1),FWModeAccess(aEntidade[nI][1],2),FWModeAccess(aEntidade[nI][1],3))
	
	cQuery := "SELECT NT9.R_E_C_N_O_ NT9RECNO," + aEntidade[nI][1] + ".* FROM " + RetSqlName(aEntidade[nI][1]) + " " + aEntidade[nI][1] + ", " + RetSqlName("NT9") + " NT9, "
	cQuery += RetSqlName("NSZ") + " NSZ " + CRLF
	cQuery += "WHERE NT9_ENTIDA ='" + aEntidade[nI][1] + "' " + CRLF
	cQuery += "AND NT9.NT9_FILIAL = NSZ.NSZ_FILIAL " + CRLF
	cQuery += "AND NT9.NT9_CAJURI = NSZ.NSZ_COD " + CRLF
	cQuery += "AND NSZ.NSZ_SITUAC='1' " + CRLF
	cQuery += "AND (" + Replace(aEntidade[nI][2][1],'+','||') + ") = ('" + cEntFil + "'||NT9_CODENT)" + CRLF
	cQuery += "AND NT9.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "AND " + aEntidade[nI][1] + ".D_E_L_E_T_ = ' '" + CRLF
	
	//Caso seja informado o a filial, fazer o filtro.
	If !Empty(cFilNT9)
		cQuery += "AND NT9.NT9_FILIAL = '" + cFilNT9 + "'" + CRLF	
	Endif
	
	//Caso seja informado o cajuri, fazer o filtro.
	If !Empty(cCajuri)
		cQuery += "AND NT9.NT9_CAJURI = '" + cCajuri + "'" + CRLF	
	Endif
	
	cQuery := ChangeQuery( cQuery )
		
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )
	
	//Monta lista de formas que usam o índice
	While !(cAliasQry)->(EOF())
		dbSelectArea("NT9")
		NT9->( dbSetOrder(1) )
		NT9->( dbGoTo( (cAliasQry)->NT9RECNO ) )
		If !NT9->(EOF())
			For nC := 2 to len(aEntidade[nI][2])
				If !Empty(aEntidade[nI][2][nC]) .And. NT9->( FieldPos(aCampNT9[nC-1]) ) > 0 .And. (cAliasQry)->( FieldPos(aEntidade[nI][2][nC]) ) > 0 
					//Valida se o formato não é data ou número para que a comparação funcione.
					if ValType(NT9->&(aCampNT9[nC-1])) == "D"
						oCompara := StoD((cAliasQry)->&(aEntidade[nI][2][nC]))
					ElseIf (ValType(NT9->&(aCampNT9[nC-1])) == "N")
						oCompara := (cAliasQry)->&(aEntidade[nI][2][nC])
					Else
						oCompara := SubStr( (cAliasQry)->&(aEntidade[nI][2][nC]) ,1, TamSX3(aCampNT9[nC-1])[1] )
					Endif
					
					If NT9->&(aCampNT9[nC-1]) != oCompara 
						RecLock( "NT9", .F. )
						NT9->&(aCampNT9[nC-1]) :=  oCompara
						MsUnLock()
						nQtd++
					Endif
				Endif
			Next 
		Endif
		
		(cAliasQry)->( dbSkip() )
	End
	
	(cAliasQry)->(dbCloseArea())

Next

If lAmbiente
	RESET ENVIRONMENT //encerra o ambiente aberto para rodar a rotina.
Endif

aParam := aSize(aParam,0)
aParam := Nil

ConOut(I18N(STR0048,{JurTimeStamp(),AllTrim(Str(nQtd))}))//"#1: Operação concluída com sucesso. Registros processados: #2"

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J105GEnt

Função que retorna os dados da variável de entidade

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105GEnt()
Return _cEntidade

//-------------------------------------------------------------------
/*/{Protheus.doc} J105GChav

Função que retorna os dados da variável com a chave da entidade.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 08/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105GChav()
Return _cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} J105ValEnt

Valida campo NT9_ENTIDA.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Rafael Tenorio da Costa
@since 25/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J105ValEnt()
Local lRet	  := .T.
Local oModel  := FwModelActive()
Local lEnvAut := (SuperGetMV('MV_JENVENT',, '2') == '1')

	// Não podera passar se na validação se a chamada foi na inclusão de 'Modelo de processo', na Distribuição ou Totvs Legal
	IF IsInCallStack("J162IncMod") .Or. IsInCallStack("JURA219") .Or. JModRst() .Or. IsInCallStack("JURA298")
		Return lRet
	EndIf
	
	If Type("cTipoAsJ") == "U" .AND. (IsInCallStack("MILESCHIMP") .OR. IsInCallStack("FWMILEMVC")  .OR. IsInCallStack("CFGA600"))
		Return lRet	
	EndIf
	
	IF lEnvAut 
		cContVal := FwFldGet("NT9_ENTIDA")

		If Empty(cContVal)
			lRet := JurMsgErro(STR0050 + RetTitle("NT9_ENTIDA") + STR0051)
			
		ElseIf !(cContVal $ "SA1|SA2|SU5|SRA|NZ2")
			lRet := JurMsgErro(STR0052 + RetTitle("NT9_ENTIDA") + STR0053)
		EndIf
	EndIf 
	
	If lRet .and. ( !(FwFldGet("NT9_ENTIDA") $ "SA1|SA2|SU5|SRA|NZ2") .Or. Empty( J105GEnt() ) .OR. J105GEnt() <> FwFldGet("NT9_ENTIDA"))

		//Caso tenha interface apresenta a tela para a escolha da entidade
		If !JurAuto()
			//Abre tela de consulta para retornar tambem o campo NT9_CODENT que não é editavel 
			lRet := J105SelEnt()
		EndIf
		
		If lRet
			J105LoadE()
			oModel:SetValue("NT9DETAIL", "NT9_ENTIDA", J105GEnt())
				
			//Limpa campos de entidade, mas não limpa a chave que sera utilizada no gatilho do campo
			J105SetDados("", J105GChav())
		EndIf
	EndIf
	
Return lRet
