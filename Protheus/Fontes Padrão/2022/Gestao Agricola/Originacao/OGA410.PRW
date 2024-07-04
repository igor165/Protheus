#INCLUDE "OGA410.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utiliza??o do novo modelo de negocio

/** {Protheus.doc} OGA410
Rotina para cadastro de Componentes de Preço
@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	13/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA410()
	Local oMBrowse := Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NK7" )
	oMBrowse:SetDescription( STR0001 ) //"Componentes de Preço"
	oMBrowse:AddLegend( "NK7_ATIVO<>'N'", "GREEN",	STR0002 ) //"Ativo"
	oMBrowse:AddLegend( "NK7_ATIVO=='N'", "GRAY",	STR0003 ) //"Inativo"
	oMBrowse:DisableDetails()

	oMBrowse:Activate()

Return()


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0004, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0005, "ViewDef.OGA410", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0006, "ViewDef.OGA410", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0007, "ViewDef.OGA410", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0008, "ViewDef.OGA410", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0009, "ViewDef.OGA410", 0, 8, 0, Nil } ) //"Imprimir Lista"
	aAdd( aRotina, { STR0010, "ViewDef.OGA410", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function ModelDef()
	Local oStruNK7	:= FWFormStruct( 1, "NK7" )
	Local oStruNK8	:= FWFormStruct( 1, "NK8" )
	Local oModel

	If (!__lnewNeg .AND. NK7->(FieldPos("NK7_DESABR")) > 0  .AND. NK7->(FieldPos("NK7_FIXAVE")) > 0)
		oStruNK7:SetProperty( "NK7_DESABR" 	, MODEL_FIELD_OBRIGAT	, .F. )
		oStruNK7:SetProperty( "NK7_FIXAVE" 	, MODEL_FIELD_OBRIGAT	, .F. )
	EndIF

	//Remove campo da tela
	oStruNK8:RemoveField( "NK8_CODCOM" )

	If NK8->(FieldPos("NK8_DATINI")) > 0
		//Habilita ou Desabilita campo
		oStruNK7:SetProperty( "NK7_PRCMAR"  , MODEL_FIELD_WHEN  , {||sfValUti()} )
	EndIf

	If NK7->(FieldPos("NK7_ALTERA")) > 0
		oStruNK7:SetProperty( "NK7_CALCUL" 	, MODEL_FIELD_VALID	, {| oField | OGA410WH1( oField ) } )
		oStruNK7:SetProperty( "NK7_GERMUL" 	, MODEL_FIELD_VALID	, {| oField | OGA410WH2( oField ) } )
	EndIf

	oModel:= MPFormModel():New( "OGA410" , ,{| oModel | PosModelo( oModel ) })
	oModel:SetVldActivate( { |oMod| OGA410VLD( oMod ) } )
	oModel:SetDescription( STR0001 ) //"Componentes de Preço"

	oModel:AddFields( "NK7MASTER", /*cOwner*/, oStruNK7, , /*bPost*/, /*bLoad */ {|oMod, lCopy| OGA410LOAD(oMod, lCopy)}  )
	oModel:SetPrimaryKey( { "NK7_FILIAL", "NK7_CODCOM" } )
	oModel:GetModel( "NK7MASTER" ):SetDescription( STR0001 ) //"Componentes de Preço"

	oModel:AddGrid( "NK8DETAIL", "NK7MASTER", oStruNK8, /*bLinePre*/, /*bLinePost*/{|oModelGrid| fValLinNK8(oModelGrid)} , /*bPre*/,  { |oMod| OGA410POST( oMod ) }/*bPost*/, /*bLoad*/ )
	oModel:GetModel( "NK8DETAIL" ):SetUniqueLine( { "NK8_ITEMCO" } )
	oModel:SetRelation( "NK8DETAIL", { { "NK8_FILIAL", "xFilial( 'NK8' )" }, { "NK8_CODCOM", "NK7_CODCOM" } }, NK8->( IndexKey( 1 ) ) )
	oModel:GetModel( "NK8DETAIL" ):SetDescription( STR0011 ) //"Produtos X Componentes"

	If NK8->(ColumnPos( "NK8_DATINI" )) > 0
		OGA410DIC()
	EndIf


Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function ViewDef()	
	Local oModel   	:= FWLoadModel( "OGA410" )
	Local oView    	:= FWFormView():New()

	Local oStruNK7P := NIL
	Local oStruNK7C := NIL
	Local oStruNK8P := NIL
	

	If __lnewNeg 
		oStruNK7P := FWFormStruct( 2, "NK7" , { |x| ALLTRIM(x)  $ 'NK7_CODCOM, NK7_DESCRI, NK7_DESABR, NK7_ATIVO,  NK7_APLICA, NK7_ORDEM, NK7_PLVEND' })
		oStruNK7C := FWFormStruct( 2, 'NK7' , { |x| !ALLTRIM(x)  $ 'NK7_CODCOM, NK7_DESCRI, NK7_DESABR, NK7_ATIVO,  NK7_APLICA, NK7_ORDEM, NK7_PLVEND' })
		oStruNK8P := FWFormStruct( 2, 'NK8' , { |x| !ALLTRIM(x)  $ 'NK8_CODCOM' })
	Else
		oStruNK7P := FWFormStruct( 2, "NK7" , { |x| ALLTRIM(x)  $ 'NK7_CODCOM, NK7_DESCRI, NK7_ATIVO,  NK7_APLICA, NK7_CALCUL, NK7_UTILIZ, NK7_PRCMAR, NK7_GERFIN' })		
		oStruNK8P := FWFormStruct( 2, 'NK8' , { |x| !ALLTRIM(x)  $ 'NK8_CODCOM,NK8_BOLSA,NK8_DIAINI,NK8_MESINI,NK8_DIAFIM,NK8_MESFIM' })
	EndIf		
	
	oView:SetModel( oModel )	
	
	If __lnewNeg
		//*Cria Folder 
		oView:CreateFolder( 'FOLDER1')

		//*Cria Sheet1 - Principal
		oView:AddSheet('FOLDER1','PRINCIPAL','Principal')
		//Divide Sheet1 - Field e Grid - Principal
		oView:CreateHorizontalBox( 'BOX_NK7P', 50, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'PRINCIPAL')
		oView:CreateHorizontalBox( 'BOX_NK8P', 50, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'PRINCIPAL')

		//*Cria Sheet2 - Calculo
		oView:AddSheet('FOLDER1','CALCULO','Cálculo')
		oView:CreateHorizontalBox( 'BOX_NK7C', 100, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'CALCULO')

		//*Field e Grid - Principal
		oView:AddField('VIEW_NK7P' 	, oStruNK7P, "NK7MASTER")
		oView:AddGrid('VIEW_NK8P' 	, oStruNK8P, "NK8DETAIL")  
		oView:AddIncrementField( "VIEW_NK8P", "NK8_ITEMCO" )

		//*Field - Calculo
		oView:AddField('VIEW_NK7C'  , oStruNK7C, "NK7MASTER") 

		oView:SetOwnerView('VIEW_NK7P','BOX_NK7P')
		oView:SetOwnerView('VIEW_NK8P','BOX_NK8P')
		oView:SetOwnerView('VIEW_NK7C','BOX_NK7C')	
	Else		
		//*Field e Grid - Principal		
		oView:AddField('VIEW_NK7P' 	, oStruNK7P, "NK7MASTER")
		oView:AddGrid('VIEW_NK8P' 	, oStruNK8P, "NK8DETAIL")  
		oView:AddIncrementField( "VIEW_NK8P", "NK8_ITEMCO" )

		oView:CreateVerticallBox( "TELANOVA" , 100 )
		oView:CreateHorizontalBox( "BOX_NK7P" , 40, "TELANOVA" )
		oView:CreateHorizontalBox( "BOX_NK8P" , 60, "TELANOVA" )

		oView:SetOwnerView( "VIEW_NK7P", "BOX_NK7P" )
		oView:SetOwnerView( "VIEW_NK8P", "BOX_NK8P" )
		oView:EnableTitleView( "VIEW_NK7P" )
		oView:EnableTitleView( "VIEW_NK8P" )
	EndIf

	If NK7->(FieldPos("NK7_REGRA")) > 0
		oView:addUserButton(STR0020, '',  { |oView| aRegConNJR(oView) } , STR0020 )
	EndIf
	oView:SetCloseOnOk( {||.t.} )

	oView:SetFieldAction( 'NK7_UTILIZ', { |oView| FNk7Utiliz(oView) } )

Return( oView )

/** {Protheus.doc} aRegConNJR
Função que cria a expressão de regra.

@param: 	nil
@return:	.T. ou .F.
@author: 	Jean Carlos Pontes Schulze
@since: 	06/03/2017
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function aRegConNJR(oView)
	Local cExpFiltro := FwFldGet('NK7_REGRA')
	
	if oView:GetOperation() == 3 .or. oView:GetOperation() == 4   
		cExpFiltro := BuildExpr("N79", , cExpFiltro,,,,,STR0020)
		
		FWFldPut('NK7_REGRA', cExpFiltro )
	endif		
Return .t.





/** {Protheus.doc} OGA410VLD
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Function OGA410VLD( oModel )

	Local nOpc       := oModel:GetOperation()
	Local cAliasQry  := GetNextAlias()
	Local cAliasQry2 := GetNextAlias()

	/* --- Exclusão  --- */
	// Só é possível excluir Componente não utilizado em nenhuma Fixação 
	If nOpc == MODEL_OPERATION_DELETE

		// Verifica se o componente não foi utilizado em nenhuma Fixação
		BeginSql Alias cAliasQry
		Select
		NKA.*
		From
		%Table:NKA% NKA
		Where
		NKA.%NotDel% And
		NKA.NKA_CODCOM = %exp:NK7->( NK7_CODCOM )%
		EndSql

		DbselectArea( cAliasQry )
		DbGoTop()
		If .Not. ( cAliasQry )->( Eof() )
			//Cadastrado no projeto de Manutenção o HELP
			Help('',1,"OGA410VNKA")  //"HELP"##"Não é permitido EXCLUIR componentes que já tenham sido utilizados em alguma Fixação de Preços. Caso não queira mais utilizar este componente, você deve colocá-lo como INATIVO."
			//Help( ,, STR0012,, STR0013, 1, 0,) //"HELP"##"Não é permitido EXCLUIR componentes que já tenham sido utilizados em alguma Fixação de Preços. Caso não queira mais utilizar este componente, você deve colocá-lo como INATIVO."

			( cAliasQry )->( dbCloseArea() )
			Return( .F. )
		EndIf
		( cAliasQry )->( dbCloseArea() )

		IF AliasIndic("N7C")
			//Verifica se o componente não foi usado em nenhum negócio	
			BeginSql Alias cAliasQry2
			Select
			N7C.*
			From
			%Table:N7C% N7C
			Where
			N7C.%NotDel% And
			N7C.N7C_CODCOM = %exp:NK7->( NK7_CODCOM )%
			EndSql

			DbselectArea( cAliasQry2 )
			DbGoTop()
			If !( cAliasQry2 )->( Eof() )
				Help('',1,"OGA410VN7C") //"Não é permitido EXCLUIR componentes que já tenham sido utilizados em algum Negócio. Caso não queira mais utilizar este componente, você deve colocá-lo como INATIVO."   
				( cAliasQry2 )->( dbCloseArea() )
				Return( .F. )
			EndIf
			( cAliasQry2 )->( dbCloseArea() )
		EndIf
	EndIf

Return( .T. )


/** {Protheus.doc} ADMIAD
Bloco de código de pós-validação do submodelo. Equivale ao "TUDOOK".

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Function OGA410POST( oModel )
	Local nOpc := oModel:GetOperation()

	// O sistema não deverá permitir associar mais de um componente de margem para o mesmo produto ou grupo de produtos.
	/* --- Exclusão  --- */
	// Só é possível excluir Componente não utilizado em nenhuma Fixação 
	If nOpc == MODEL_OPERATION_DELETE
		// Verifica se o componente não foi utilizado em nenhuma Fixação
		DbSelectArea( "NKA" )
		DbSetOrder( 2 ) // NKA_FILIAL+NKA_CODCOM
		If DbSeek( xFilial( "NKA" ) + NK7->( NK7_CODCOM ) )
			Help( ,, STR0012,, STR0013, 1, 0,) //"HELP"##"Não é permitido EXCLUIR componentes que já tenham sido utilizados em alguma Fixação de Preços. Caso não queira mais utilizar este componente, você deve colocá-lo como INATIVO."
			Return( .F. )
		EndIf
	EndIf
Return( .T. )


/** {Protheus.doc} OGA410LOAD
Função de tratamento para carga dos dados para o formulário.

@param: 	oModel		Objeto de Model do MVC
lCopy		.T. ou .F. = indica se está sendo efetuada a cópia de um registro ou não
@return:	aLoad 		:= {{},} // Array de retorno com os valores dos campos da tela (Ex.: { { '01', 'XXXXX', 999 }, Recno()} )
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Function OGA410LOAD( oModel, lCopy )
	Local aLoad		:= {{},} // Array de retorno com os valores dos campos da tela (Ex.: { { '01', 'XXXXX', 999 }, Recno()} )
	Local aFieldsNK7	:= oModel:GetStruct():aFields
	Local nOpc			:= oModel:GetOperation()
	Local nX 			:= 0
	Local xValue
	Local cFieldsNotCopy := "NK7_CODCOM,NK7_ATIVO"

	For nX := 1 to Len( aFieldsNK7 )

		// Se campo VIRTUAL, ou campo pertence ao grupo de campos que não devem ser copiados
		If aFieldsNK7[nX][14] .Or. ( AllTrim( aFieldsNK7[nX][3] ) $ cFieldsNotCopy .And. ( lCopy .Or. nOpc == 3 ) )
			xValue := oModel:GetValue( aFieldsNK7[nX][3] )	// Inicializa com o padrão
		Else
			xValue := NK7->( &( aFieldsNK7[nX][3] ) ) 			// Inicializa com os dados da tabela
		EndIf

		// Adiciona o valor do campo no array aLoad	
		aAdd( aLoad[1], xValue )

	Next nX

	If nOpc == 3 .Or. lCopy 	// Se for Inclusão ou Cópia
		aLoad[2] := 0	 				// recno = 0
	Else
		aLoad[2] := NK7->( Recno() ) 	// pega o recno atual
	EndIf

Return aLoad


/*{Protheus.doc} fValLinNK8(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pos validação da linha do Grid NK8 (LinhaOk)

@author Emerson coelho
@param oModelGrid Modelo
@return lRet
@since 13/11/2014
@version 1.0
*/
Static Function fValLinNK8(oGridNK8)	
	Local nCampos 		:= 0
	Local lRet			:= .t.
	Local nPosDiaIni 	:= gdFieldPos('NK8_DIAINI', oGridNK8:aHeader )
	Local nPosMesIni 	:= gdFieldPos('NK8_MESINI', oGridNK8:aHeader )
	Local nPosDiaFim 	:= gdFieldPos('NK8_DIAFIM', oGridNK8:aHeader )
	Local nPosMesFim 	:= gdFieldPos('NK8_MESFIM', oGridNK8:aHeader )
	Local nPosCodidx 	:= gdFieldPos('NK8_CODIDX', oGridNK8:aHeader )
	Local cCposData		:= ''
	Local cCposRest		:= ''

	If NK7->(ColumnPos( 'NK7_TIPPRC' )) > 0 
		/*Coloca a validação tipo resultado */
		If FwFldGet('NK7_CALCUL') = 'R' //quando o tipo é resultado
	
			/*Não pode informar dia/mes - e nem indice */
			If ( ! Empty(oGridNK8:GETVALUE('NK8_DIAINI')), cCposRest += oGridNK8:aHeader[nPosDiaIni,1] + "," ,)
			If ( ! Empty(oGridNK8:GETVALUE('NK8_MESINI')), cCposRest += oGridNK8:aHeader[nPosMesIni,1] + "," ,)
			If ( ! Empty(oGridNK8:GETVALUE('NK8_DIAFIM')), cCposRest += oGridNK8:aHeader[nPosDiaFim,1] + "," ,)
			If ( ! Empty(oGridNK8:GETVALUE('NK8_MESFIM')), cCposRest += oGridNK8:aHeader[nPosMesFim,1] + "," ,)
			If ( ! Empty(oGridNK8:GETVALUE('NK8_CODIDX')), cCposRest += oGridNK8:aHeader[nPosCodidx,1] + "," ,)
	
			If ! Empty(cCposRest)
				Help( , , STR0012, , STR0018 + "(" + Substr(cCposRest,1,len(cCposRest)-1) + ")" + STR0019 , 1, 0 ) //"AJUDA"###"OS CAMPOS"###cCposRest###"não podem estar preenchidos. O Tipo de Cálculo é Resultado."
				lRet := .f.
			EndIf
	
		EndIf 
	EndIf 
	
	If NK8->(ColumnPos( "NK8_DATINI" )) > 0
		//Valida se as datas estão todas preenchidas ou não
		If (!Empty(FwFldGet("NK8_DATINI")) .AND. Empty(FwFldGet("NK8_DATFIM"))) .Or. (Empty(FwFldGet("NK8_DATINI")) .AND. !Empty(FwFldGet("NK8_DATFIM")))
			Help('',1,STR0012,,STR0022,1,0) //#Atenção //#Data Inicial e Data Final devem estar preenchidas
			lRet := .F.
		EndIf

		//Valida se a data fim é menor que a data inicial
		If !Empty(FwFldGet("NK8_DATINI")) .AND. !Empty(FwFldGet("NK8_DATFIM"))
			If FwFldGet("NK8_DATFIM") < FwFldGet("NK8_DATINI")
				Help('',1,STR0012,,STR0023,1,0) //#Atenção //#Data Final não pode ser menor que a Data Inicial
				lRet := .F.
			EndIf
		EndIf
	Else
		//--<< Inicio Validação dos Campos Ref Data , Precso Garantir que os Quatro Campos Estão Preenchidos Ou os 4 Vazios >>-- 
		If ( ! Empty(oGridNK8:GETVALUE('NK8_DIAINI')),nCampos+=1,)
		If ( ! Empty(oGridNK8:GETVALUE('NK8_MESINI')),nCampos+=1,)
		If ( ! Empty(oGridNK8:GETVALUE('NK8_DIAFIM')),nCampos+=1,)
		If ( ! Empty(oGridNK8:GETVALUE('NK8_MESFIM')),nCampos+=1,)

		If (nCampos > 0 .and. nCampos < 4 ) //Indica que os 4 Campos não estão preenchidos
			cCposData	+= "("
			cCposData	+=	oGridNK8:aHeader[nPosDiaIni,1] + ','
			cCposData	+= 	oGridNK8:aHeader[nPosMesIni,1] + ','
			cCposData	+=	oGridNK8:aHeader[nPosDiaFim,1] + ','
			cCposData	+=	oGridNK8:aHeader[nPosMesFim,1]
			cCposData	+= ')'
			Help( , , STR0012, , STR0014 + cCposData + STR0015 , 1, 0 ) //"AJUDA"###"OS CAMPOS"###CCPOSDATA###"nao estão preenchidos de forma correta"
			lRet := .f.
		EndIf
		//--<< Fim    Validação dos Campos Ref Data , Precso Garantir que os Quatro Campos Estão Preenchidos Ou os 4 Vazios >>--
	EndIf
	
	//valida tratamento de bolsa
	If NK8->(ColumnPos( "NK8_BOLSA" )) > 0 
		If !Empty(oGridNK8:GETVALUE('NK8_BOLSA')) .and. !Empty(oGridNK8:GETVALUE('NK8_CODIDX')) //informou bolsa e indíce
			if POSICIONE('NK0',1,XFILIAL('NK0')+oGridNK8:GETVALUE('NK8_CODIDX'),'NK0_CODBOL') <> oGridNK8:GETVALUE('NK8_BOLSA')
				//indice inválido para bolsa informada
				Help( , , STR0012, , STR0028,  1, 0,,,,,,{STR0029} ) //"AJUDA"#"Indíce inválido para Bolsa informada."#"Informe um indíce válido para a Bolsa."
				lRet := .f.
			endif
		endif
	endif	
Return lRet


/*{Protheus.doc} fnK7Utiliz(oView)
Rotina de Ação Executada Pos validação do Campo NK7_UTILIZ

@author Emerson coelho
@param oVIEW
@return lRet
@since 13/11/2014
@version 1.0
*/
Static Function fnK7Utiliz( oView )
	Local oModel     := FWModelActive()
	If .NOT. oModel:GetValue("NK7MASTER","NK7_UTILIZ" ) == 'M'
		oModel:LoadValue("NK7MASTER","NK7_PRCMAR" , 0 )
	EndIf
	oView:Refresh()
Return


/* {Protheus.doc} sfValUti
Função para travar campo quando utiliza ou não o campo Margem.

@param:     oNJJ - Enchoice do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Marlon Richard Trettin
@since:     24/01/2015
@Uso:       OGA250 - Romaneio
*/
Static Function sfValUti()
	Local lRetorno  := .T.

	If FwFldGet('NK7_UTILIZ') == 'M'
		lRetorno  := .T.
	Else
		lRetorno  := .F.
	EndIf

Return( lRetorno )


/*{Protheus.doc} OGA410DIC(oView)
Ajusta a base de dados para que o conteúdo do campos NK8_DIAINI, 
NK8_MESINI, NK8_ANOINI, NK8_DIAFIM, NK8_MESFIM, NK8_ANOFIM que estão 
inativos, caso preenchidos, sejam passados para os campos NK8_DATINI
e NK8_DATFIM 

@author Janaina F B Duarte
@param  none
@return none
@since 28/08/2017
@version 1.0
*/
Static Function OGA410DIC()
	Local dDtIni 	
	Local dDtFim
	Local dDataHoje := Date()

	dbSelectArea( "NK8" )
	dbSetOrder( 1 )		
	dbSeek( xFilial( "NK8" ) )
	//	dbSeek( xFilial("NK8") + NK8->(NK8_CODCOM))
	//While !(NK8->(Eof())) .And. NK8->(NK8_FILIAL) + NK8->(NK8_CODCOM ) == xFilial( "NK8" ) + NK8->(NK8_CODCOM)
	While .Not. NK8->( Eof() )
		//Somente para os registros que estão com NK8_DATINI vazia e tem o NK8_DIAINI e demais campos
		If !Empty(NK8->(NK8_DIAINI)) .AND. Empty(NK8->(NK8_DATINI))    

			dDtIni := ctod( NK8->(NK8_DIAINI) + '/' + NK8->(NK8_MESINI) +'/'+ strzero(year(dDataHoje),4) )
			dDtFim := ctod( NK8->(NK8_DIAFIM) + '/' + NK8->(NK8_MESFIM) +'/'+ strzero(year(dDataHoje),4) )

			//Atualiza os campos NK8_DATINI e NK8_DATFIM
			RecLock('NK8', .F.)
			NK8->(NK8_DATINI) := dDtIni
			NK8->(NK8_DATFIM) := dDtFim
			NK8->(NK8_DIAINI) := ''
			NK8->(NK8_MESINI) := ''
			NK8->(NK8_ANOINI) := ''
			NK8->(NK8_DIAFIM) := ''
			NK8->(NK8_MESFIM) := ''
			NK8->(NK8_ANOFIM) := ''
			NK8->( MsUnLock() )
		EndIf

		NK8->( dbSkip() )
	EndDo	

Return


/** {Protheus.doc} OGA410WH1
Função para dicionário [SX3] - validação para excluir o campo NK7_TIPPRC quando o calculo for dIferente de Resultado.
Essa função esta sendo utilizada na validação do campo NK7_CALCUL

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Ana Laura Olegini
@since:     14/08/2017
@Uso:       OGA410 - Componente de Preço
*/
Function OGA410WH1()
	Local aAreaAtu   := GetArea()
	Local oModel	 := FWModelActive()	
	Local oNK7		 := oModel:GetModel( "NK7MASTER" )
	Local nOperation := oModel:GetOperation()
	Local lRetorno  := .T.

	If .NOT. oNK7:GetValue("NK7_CALCUL" ) == "R"	//Resultado
		oNK7:LoadValue("NK7_TIPPRC" , "")
	EndIf
	If .NOT. oNK7:GetValue("NK7_CALCUL" ) == "T"	//Tributo
	   	
        oNK7:LoadValue("NK7_TRIBUT" , "")
		oNK7:LoadValue("NK7_DESCTR" , "")
		
	EndIf
	If .NOT. oNK7:GetValue("NK7_CALCUL" ) == "M"	//Multa		
        oNK7:LoadValue("NK7_GERMUL" , "")	
		oNK7:LoadValue("NK7_MPREFI" , "")	
		oNK7:LoadValue("NK7_MTIPO" 	, "")
		oNK7:LoadValue("NK7_MNATUR" , "")
		If oNK7:HasField("NK7_ALCADA")
        	oNK7:LoadValue("NK7_ALCADA" , "0")
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE
		If NK7->NK7_CALCUL <> "R" .AND. oNK7:GetValue("NK7_CALCUL") == "R"
			dbSelectArea("N75")
			dbSetOrder(2)
			If dbSeek(xFilial('N75')+oNK7:GetValue("NK7_CODCOM"))
				lMsg  := STR0036 //"O componente já está cadastrado como 'Componente para Cálculo' no 'Cadastro de Fórmula para Cálculo de Componentes!'"
				oModel:GetModel():SetErrorMessage( oNK7:GetId(), , oNK7:GetId(), "", STR0035, lMsg, STR0038, "", "") //"Alteração não permitida!" ### "Alterar o valor do campo 'Calculo' !"
				lRetorno := .f.
			EndIf
		ElseIf NK7->NK7_CALCUL = "R" .AND. oNK7:GetValue("NK7_CALCUL") <> "R"
			dbSelectArea("N74")
			dbSetOrder(1)
			If dbSeek(xFilial('N74')+oNK7:GetValue("NK7_CODCOM"))
				lMsg  := STR0037 //"O componente já está cadastrado como 'Componente de Resultado' no 'Cadastro de Fórmula para Cálculo de Componentes'!"
				oModel:GetModel():SetErrorMessage( oNK7:GetId(), , oNK7:GetId(), "", STR0035, lMsg, STR0038, "", "") //"Alteração não permitida!" ### "Alterar o valor do campo 'Calculo' !"
				lRetorno := .f.
			EndIf
		EndIf

	EndIf

	RestArea(aAreaAtu)

Return (lRetorno)


/** {Protheus.doc} OGA410WH2
Função para dicionário [SX3] - validação para excluir o campo NK7_TIPPRC quando o calculo for dIferente de Resultado.
Essa função esta sendo utilizada na validação do campo NK7_CALCUL

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Ana Laura Olegini
@since:     14/08/2017
@Uso:       OGA410 - Componente de Preço
*/
Function OGA410WH2()
	Local oField	:= FWModelActive()	
	Local oNK7		:= oField:GetModel( "NK7MASTER" )
	Local lRetorno  := .T.

	If oNK7:GetValue("NK7_GERMUL" ) $ "1|2|3|" 			
        oNK7:LoadValue("NK7_MPREFI" 	, "")	
		oNK7:LoadValue("NK7_MTIPO" 		, "")
		oNK7:LoadValue("NK7_MNATUR" 	, "")

		If oNK7:HasField("NK7_ALCADA")

			If oNK7:GetValue("NK7_GERMUL" ) == "1" 	//A PAGAR		
				oNK7:LoadValue("NK7_ALCADA" 	, "1")
			Else
				oNK7:LoadValue("NK7_ALCADA" 	, "0")
			EndIf

		EndIf
	EndIf 	
	
Return(lRetorno)

/** {Protheus.doc} OGA410WH3
Função para dicionário [SX3] - validação para permitir editar os campos 
nk7_mtipo/m_pref/_mnatur, quando o calculo multa e o NK7_GERMUL =

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Marcelo Ferrari
@since:     01/12/2017
@Uso:       OGA410 - Componente de Preço
*/
Function OGA410WH3()
	Local oField	:= FWModelActive()	
	Local oNK7		:= oField:GetModel( "NK7MASTER" )
	Local lRetorno  := .T.

	lRetorno := oNK7:GetValue("NK7_GERMUL") $ '1/2' .OR. (oNK7:GetValue("NK7_CALCUL") == 'M' .AND. oNK7:GetValue("NK7_GERMUL") == '3' )

Return(lRetorno)


/** {Protheus.doc} PosModelo
Pos modelo validações

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    marcelo.wesan
@since:     25/09/2017
@Uso:       PosModelo - Componente de Preço
*/
Static Function PosModelo( oModel )
	Local nOperation   	:= oModel:GetOperation()
	Local oModelNK8 	:= oModel:GetModel( "NK8DETAIL" )
	Local lRet			:= .T.

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE		
		If FwFldGet('NK7_CALCUL') == 'R'  //quando o tipo é resultado
			If  ! Empty(oModelNK8:GETVALUE('NK8_CODIDX'))
				Help(" ",1,"OGA410NK8")	//o campo indice não deve ser preenchido quando a forma de calculo for Resultado
				lRet := .F.
			EndIf
		ElseIf FwFldGet('NK7_CALCUL') =='T' //quando o tipo é tributo
		        If  __lnewNeg
					 
					If ! Empty(oModelNK8:GETVALUE('NK8_CODIDX'))
						Help(" ",1,"OGA410NK8A")//o campo indice não deve ser preenchido quando a forma de calculo for Tributo
						lRet := .F.
					EndIf 

					If Empty(FwFldGet('NK7_TRIBUT') )
						Help(" ",1,"OGA410NK8C")//Campo de tributo não preenchido.  //Por favor informe um tributo.				
						lRet := .F.
					EndIf			

					If  !(Alltrim(FwFldGet('NK7_TRIBUT')) $ "ICMS|PIS|COFINS") 
						Help(" ",1,"OGA410NK8E")//Tributo informado não é permitido para compor preço. //Somente os tributos ICMS, PIS e COFINS são válidos.				
						lRet := .F.
					EndIf
				else
					Help(NIL, NIL, STR0012, NIL, STR0041, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0042}) /*"Não é possivel utilizar o cálculo por Tributo."*/ /*"Para utilizar o cálculo por Tributo é  necessário ativar o parâmetro MV_AGRO002."*/
				    lRet := .f.	
				EndIf
		ElseIf  FwFldGet('NK7_CALCUL') == 'M' //quando o tipo é multa	
			If __lnewNeg 
				If ! Empty(oModelNK8:GETVALUE('NK8_CODIDX'))
					Help(" ",1,"OGA410NK8B")//o campo indice não deve ser preenchido quando a forma de calculo for  multa
					lRet := .F.
				EndIf 
			else 
			    Help(NIL, NIL, STR0012, NIL, STR0039, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0040}) /*"Não é possivel utilizar o cálculo por Multa."*/ /*"Para utilizar o cálculo por Multa é  necessário ativar o parâmetro MV_AGRO002."*/
				lRet := .f.		
			EndIf
		EndIf
		
		If !Empty(FwFldGet('NK7_MNATUR'))
			If !OGA410NAT(FwFldGet('NK7_MNATUR'))
				lRet := .F.
			EndIf
		EndIf		
	EndIf

Return( lRet )    

 
//-------------------------------------------------------------------
/*/{Protheus.doc} OGA410NAT
Valida Natureza conforme o tipo do título
@author  rafael.voltz
@since   13/04/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGA410NAT(cNatureza)
	Local cArea 	 := GetArea()
	Local cUso  	 := ""
	Local cTipoMulta := FwFldGet('NK7_GERMUL') 
	Local lRet  	 := .F.
	Local lMsg       := ""
	
	cUso := POSICIONE("SED",1,xFilial("SED")+cNatureza, "ED_USO")
	
	If cTipoMulta == "1" .And. cUso $ "0|2" 	//1=Titulo A Pagar   | 0=Livre; 2=Contas a pagar; 
		lRet := .T.				
	ElseIf cTipoMulta == "2" .And. cUso $ "0|1" //2=Titulo A Receber | 0=Livre; 1=Contas a receber;
		lRet := .T.			
	EndIf	

	If !lRet
		lMsg  := STR0030 + CRLF //"Natureza de operação diverge do tipo da multa."
		lMsg  += STR0031 + X3CBOXDESC("ED_USO",cUso)  + CRLF //"Tipo da Natureza: "
		lMsg  += STR0032 + X3CBOXDESC("NK7_GERMUL",cTipoMulta) //"Tipo da Multa: "				  
		Help( , , STR0033, ,  lMsg, 1, 0,,,,,,{STR0034} ) //"Ajuda"###"Por favor, informe uma natureza válida." 
	EndIF
		
	RestArea(cArea)

Return lRet
