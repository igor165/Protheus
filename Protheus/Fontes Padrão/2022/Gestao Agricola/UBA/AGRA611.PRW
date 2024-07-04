#INCLUDE "AGRA611.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

/** --------------------------------------------------------------------------------
{Protheus.doc} AGRA611
Cadastro de Conjuntos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: Generico
-------------------------------------------------------------------------------- **/
Function AGRA611()
	Local oBrowse

	// Instancia o objeto Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DXE')
	oBrowse:SetDescription( STR0001 )  //"Cadastro de Conjuntos"

	// Ativa o Browse
	oBrowse:Activate()
Return NIL

/** --------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de dados da rotina do Cadastro Conjuntos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA611
-------------------------------------------------------------------------------- **/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXE 	:= FwFormStruct( 1, 'DXE' )// Conjuntos
	Local oStruDXF 	:= FwFormStruct( 1, 'DXF' )// Itens Adicionais
	Local oStruDes 	:= FwFormStruct( 1, 'DXC' )// Desmontagem
			
	// ---------------------------
	// Remove campo da estrutura
	// ---------------------------
	oStruDXE:RemoveField( 'DXE_PSITEM' )
	
	// -----------------------------
	// Instancia o modelo de dados
	// -----------------------------
	oModel := MpFormModel():New( 'AGRA611', ,{|oMdl| AGRA611POS(oMdl)})
	oModel:SetDescription( STR0001 ) //"Cadastro de Conjuntos"

	// -------------------------------------------------------------------
	// Adiciona os atribudos do cabecalho na estrutura do modelo de dados
	// -------------------------------------------------------------------
	oModel:AddFields( 'MdFieldDXE', /*cOwner*/, oStruDXE)
	oModel:GetModel( 'MdFieldDXE' ):SetDescription( STR0002 ) //"Dados do Conjunto"

	// --------------------------------------------------------------------
	// Adiciona os atribudos do cabecalho na estrutura do modelo de dados
	// --------------------------------------------------------------------
	oModel:AddGrid( 'MdGridDXF', 'MdFieldDXE', oStruDXF)
	oModel:GetModel( 'MdGridDXF' ):SetDescription( STR0003 ) //"Itens Adicionais"
	oModel:GetModel( 'MdGridDXF' ):SetUniqueLine( {'DXF_CODPRO'} )
	
	// --------------------------------------------------------------------
	// Adiciona os atribudos do cabecalho na estrutura do modelo de dados
	// --------------------------------------------------------------------
	oModel:AddGrid( 'MdGridDes', 'MdFieldDXE', oStruDes, , , , { |x| ValPosDXC( x ) } )
	oModel:GetModel( 'MdGridDes' ):SetDescription( STR0004 ) //"Dados dos itens gerados pela Desmontagem"
	oModel:GetModel( 'MdGridDes' ):SetUniqueLine( { 'DXC_CODPRO' } )
			
	// ---------------------------------------------------
	// Faz o relacionamento entre o cabecalho e os itens
	// ---------------------------------------------------
	oModel:SetRelation( 'MdGridDXF', { { 'DXF_FILIAL', 'xFilial( "DXF" )' }, { 'DXF_CODIGO', 'DXE_CODIGO' } } )
	oModel:SetRelation( 'MdGridDes', { { 'DXC_FILIAL', 'xFilial( "DXC" )' }, { 'DXC_CODIGO', 'DXE_CODIGO' } } )

	oModel:SetActivate(   { | oModel | fIniModelo( oModel ) } )
	oModel:SetDeActivate( { | oModel | fFimModelo( oModel ) } )
	
Return oModel

/** --------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna View de dados da rotina do Cadastro de Conjuntos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA611
-------------------------------------------------------------------------------- **/
Static Function ViewDef()
	Local oView			:= Nil
	Local oModel		:= FwLoadModel( 'AGRA611' )	
	Local oStruDXE 		:= FwFormStruct( 2, 'DXE', {|cCampo| !(AllTrim(cCampo) $ 'DXE_RDMIN|DXE_RDMAX|DXE_RDMED|DXE_NUMSER|DXE_KGPHR|DXE_HRPROD|DXE_FRDDIA|DXE_ULTREN') })// Cabeçalho
	Local oStruDXEAb	:= FwFormStruct( 2, 'DXE', {|cCampo|  (AllTrim(cCampo) $ 'DXE_RDMIN|DXE_RDMAX|DXE_RDMED|DXE_NUMSER|DXE_KGPHR|DXE_HRPROD|DXE_FRDDIA|DXE_ULTREN') })// Aba Produtividade 
	Local oStruDXF 		:= FwFormStruct( 2, 'DXF' )// Itens Adicionais
	Local oStruDes 		:= FwFormStruct( 2, 'DXC' )// Desmontagem
	
	// ---------------------------
	// Remove campo da estrutura
	// ---------------------------
	oStruDXE:RemoveField( 'DXE_PSITEM' )
		
	// ------------------
	// Instancia a View
	// ------------------
	oView := FwFormView():New()

	// ---------------
	// Seta o modelo 
	// ---------------
	oView:SetModel( oModel )

	// ---------------------------------------------------------
	// Adiciona os atribudos do cabecalho na estrutura da View
	// ---------------------------------------------------------
	oView:AddField( 'VIEW_DXE', oStruDXE, 'MdFieldDXE' )

	oView:AddGrid( 'VIEW_DXF' , oStruDXF, 'MdGridDXF')
	oView:AddGrid( 'VIEW_DES' , oStruDes, 'MdGridDes')
	
	oView:AddField( 'VIEW_PRO', oStruDXEAb, 'MdFieldDXE' )
	
	// -----------
	// Cria o Box
	// -----------
	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )

	// ------------
	// Cria Folder
	// ------------
	oView:CreateFolder( 'GRADES', 'INFERIOR')
	oView:AddSheet( 'GRADES', 'PASTA01', STR0005) //"Itens Adicionais"
	oView:AddSheet( 'GRADES', 'PASTA02', STR0006) //"% de Separação e Produção"
	oView:AddSheet( 'GRADES', 'PASTA03', STR0031) //"Produtividade"
	
	// ----------
	// Cria Box
	// ----------
	oView:CreateHorizontalBox( 'PASTA_DXF', 100, , , 'GRADES', 'PASTA01' )
	oView:CreateHorizontalBox( 'PASTA_DES', 100, , , 'GRADES', 'PASTA02' )
	oView:CreateHorizontalBox( 'PASTA_PRO', 100, , , 'GRADES', 'PASTA03' )
	
	// -------------------
	// Seta owner da view
	// -------------------
	oView:SetOwnerView( 'VIEW_DXE', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DXF', 'PASTA_DXF' )
	oView:SetOwnerView( 'VIEW_DES', 'PASTA_DES' )
	oView:SetOwnerView( 'VIEW_PRO', 'PASTA_PRO' )
	
	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_DXF', 'DXF_ITEM' )
	oView:AddIncrementField( 'VIEW_DES', 'DXC_ITEM' )
	
Return oView

/** --------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Monta o menu padrao da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA611
-------------------------------------------------------------------------------- **/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.AGRA611' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.AGRA611' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.AGRA611' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.AGRA611' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.AGRA611' OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina


/*/{Protheus.doc} fIniModelo
//--Função que Inicializa / Activate o modelo de dados
@author ana.olegini
@since  17/05/2018
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
/*/
Static Function fIniModelo( oModel )
	Local lRetorno := .T.

	//---------------------------
	// Opção F4 - Campo LOTE
	//---------------------------
	SetKey(VK_F4,{|| AGRA611F4()})

Return lRetorno


/*/{Protheus.doc} fFimModelo
//--Função executada no Deactivate do modelo de dados
@author ana.olegini
@since  17/05/2018
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
/*/
Static Function fFimModelo( oModel )
	Local lRetorno := .T.
	
	//--------------
	// Opção F4
	//--------------
	SetKey(VK_F4,Nil)
	
Return lRetorno


/** --------------------------------------------------------------------------------
{Protheus.doc} AGRA611POS
Pos validação do model e atualização dos dados do cabeçalho

@param: oModel Modelo de dados da Grid
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA611
-------------------------------------------------------------------------------- **/
Static Function AGRA611POS(oModel)
	Local oMdlGrid 	 := oModel:GetModel( 'MdGridDXF' )
	Local oMdGridDes := oModel:GetModel( 'MdGridDes' )
				
	Local nI 		 := 0
	Local nTpsItem 	 := 0
	Local nTpsBal 	 := 0
	Local lRet 		 := .T.
	Local nOperation := oModel:GetOperation()
	Local lPluma     := .F.

	If nOperation <> MODEL_OPERATION_DELETE .AND. (!IsInCallStack("IncludeCottonGinMachine") .AND. !IsInCallStack("AlteraCottonGinMachine"))
	    		
		lPluma := .F.
		For nI := 1 to oMdGridDes:Length()
			oMdGridDes:GoLine( nI )
			
			If !oMdGridDes:IsDeleted()
			
				If oMdGridDes:GetValue('DXC_PLUMA') = '1' //Produto Pluma
					lPluma := .T.
				Endif
				
				If oMdGridDes:GetValue('DXC_GRPROD') = '1' //Gera Produção
					
					//TM precisa ser informada
					If lRet .And. Empty(oMdGridDes:GetValue('DXC_TM'))
						lRet := .f.
						//"Ajuda" - "A TM de produção deve ser informada."
						Help('',1, STR0020, , STR0024, 1, 0 ) 
					Endif
					
					//Local Produção precisa ser informado
					If lRet .And. Empty(oMdGridDes:GetValue('DXC_LOCPRD'))
						lRet := .f.
						//"Ajuda" - "O local de produçao deve ser informado."
						Help('',1, STR0020, , STR0026, 1, 0 ) 
					Endif
					
					//Produto Produção precisa ser informado
					If lRet .And. Empty(oMdGridDes:GetValue('DXC_PRDPRO'))
						lRet := .f.
						//"Ajuda" - "O produto produção deve ser informado."
						Help('',1, STR0020, , STR0025, 1, 0 ) 
					Endif
				Endif
				
				//O % de rateio de custo não pode ser igual ou inferior a ZERO
				If lRet .And. oMdGridDes:GetValue('DXC_RATEIO') <= 0
					lRet := .F.
					//"Ajuda" - "O percentual de rateio de custo informado deve ser superior a 0."
					Help('',1, STR0020, , STR0023, 1, 0 ) 
				Endif
				
				//Se o produto não é PLUMA e o % é menor ou igual a zero, valida
				If lRet .And. oMdGridDes:GetValue('DXC_PLUMA') = '2' .And. oMdGridDes:GetValue('DXC_PERC') <= 0
					lRet := .F.
					//"Ajuda" - "O percentual de rendimento informado deve ser superior a 0." 
					Help('',1, STR0020, , STR0022, 1, 0 )
				Endif
				
				//Se o produto é Pluma e o tipo não é Realizado
				If lRet .And. oMdGridDes:GetValue('DXC_PLUMA') = '1' .And. oMdGridDes:GetValue('DXC_TIPO') <> '3'
					lRet := .F.
					//Ajuda - "Produto Pluma deve ser do tipo Realizado."
					Help('',1, STR0020, , STR0027, 1, 0 )
				Endif
				
				//Se o produto não é Pluma, o tipo não pode ser realizado
				If lRet .And. oMdGridDes:GetValue('DXC_PLUMA') = '2' .And. oMdGridDes:GetValue('DXC_TIPO') = '3'
					lRet := .F.
					//Ajuda - "Apenas produto Pluma pode ser do tipo Realizado."
					Help('',1, STR0020, , STR0028, 1, 0 )
				Endif
			Endif	
		Next nI
		
		//-----------------------------------------------------------------------------
		// Valida se foi definido o produto pluma nos itens do percentual de separação
		//-----------------------------------------------------------------------------
		If !lPluma
			lRet := .F.
			Help('',1, 'PRODUTOPLUMA', , STR0012, 1, 0 ) //"Informe na aba percentuais de separação o produto que será tratado pelo sistema como pluma!"				
		EndIf

		If lRet
			For nI := 1 To oMdlGrid:Length()
				oMdlGrid:GoLine( nI )
		
				If oMdlGrid:GetValue('DXF_CPBAL' ) == '1'
					nTpsBal  += oMdlGrid:GetValue( 'DXF_PSUNIT' ) * oMdlGrid:GetValue( 'DXF_QTDPRO' ) 
				Endif
										
				nTpsItem += oMdlGrid:GetValue( 'DXF_PSUNIT' ) * oMdlGrid:GetValue( 'DXF_QTDPRO' )
			Next nI
		
			If lRet
				lRet := oModel:SetValue('MdFieldDXE','DXE_PSBAL', nTpsBal)
			EndIf
		EndIf
		
		If SuperGetMV("MV_AGRB002", ,"N") = "S"
			CottonStruct()
		Endif	
	EndIf
	
Return(lRet)

/** --------------------------------------------------------------------------------
{Protheus.doc} ValPosDXC
Pos validação da gride

@param: 	oGride - Gride Percentuais de Separacao
@author: 	Aécio Ferreira Gomes
@since: 	18/12/2012
@Uso: 		AGRA611
-------------------------------------------------------------------------------- **/
Static Function ValPosDXC(oGride)
	Local cTipo		:= ''
	Local lRet	 	:= .T.
	Local nLinha	:= 0
	Local nX		:= 0
	Local nSomaTp1	:= 0
	Local nSomaTp2	:= 0
	Local nSomaRat  := 0
	Local nPerc		:= 0
	Local nRateio	:= 0
	Local nPluma    := 0
	
	if !IsInCallStack("IncludeCottonGinMachine") .AND. !IsInCallStack("AlteraCottonGinMachine")
	nLinha := oGride:nLine
	For nX := 1 to oGride:Length()
		oGride:GoLine( nX )

		cTipo	:= oGride:GetValue( 'DXC_TIPO' )
		nPerc	:= oGride:GetValue( 'DXC_PERC' )
		nRateio	:= oGride:GetValue( 'DXC_RATEIO' )

		If !oGride:IsDeleted()

			// Incrementa o percentual de separação
			nSomaTp1 += IIf( cTipo = '1', nPerc, 0 )
			nSomaTp2 += IIf( cTipo = '2', nPerc, 0 )
		
			// Incrementa o percentual de rateio de custo dos itens da separação
			nSomaRat += nRateio

		EndIf
		
		// Se for pluma, incrementa o contador
		If oGride:GetValue('DXC_PLUMA') = '1'  
			nPluma++
		Endif
	Next nX
	oGride:GoLine( nLinha )
	
	//Se existir mais de uma Pluma, 
	If lRet .And. nPluma > 1
		lRet := .F.
		//"Atenção"###"Somente um registro pode ser definido como pluma, verifique se existem outros registros na tela com está definição."
		Help('',1 , STR0020, , STR0021, 1, 0 ) 
	Endif	
		
	If lRet .And. nSomaTp1 > 100
		lRet := .F.
		Help('',1, 'AJUDA', , STR0013, 1, 0 ) //"Percentual de separação somado do Tipo Fixo é maior que 100%."
	EndIf

	If lRet .And. nSomaTp2 > 100
		lRet := .F.
		Help('',1, 'AJUDA', , STR0014, 1, 0 ) //"Percentual de separação somado do Tipo Variavel é maior que 100%."
	EndIf

	If lRet .And. nSomaTp2 < 100
		lRet := .F.
		Help('',1 , 'AJUDA', , STR0015, 1, 0 ) //"Percentual somado do Tipo Variavel é menor que 100%."
	EndIf

	// Valida o total de rateio de custo informado para os itens da tabela de percentual de separação
	If lRet .And. nSomaRat > 100
		lRet := .F.
		Help('',1, 'AJUDA', , STR0016, 1, 0 ) //"Percentual de rateio de custo superou 100%."
	EndIf

	If lRet .And. nSomaRat < 100
		lRet := .F.
		Help('',1, 'AJUDA', , STR0017, 1, 0 ) //"Percentual de rateio é inferior a 100%."
	EndIf
	endIf
Return( lRet)

/** --------------------------------------------------------------------------------
{Protheus.doc} AGR611VCPO()
Validação de campos.

@author: 	Aécio Ferreira Gomes
@since: 	15/03/2013
@Uso: 		AGRA611
-------------------------------------------------------------------------------- **/
Function AGR611VCPO()
	Local oModel		:= FwModelActive()
	Local oMdGridDes	:= oModel:GetModel('MdGridDes')
	Local cCampo		:= ReadVar()
	Local xConteudo		:= &(ReadVar())
	Local lRet			:= .T.
	Local nPosHd		:= 0
	Local nCont			:= 0
	Local nReg			:= 0

	cCampo	:= Alltrim(cCampo)

	if !IsInCallStack("IncludeCottonGinMachine") .AND. !IsInCallStack("AlteraCottonGinMachine")
	If 'DXC_PLUMA' $ cCampo
	    //--------------------------------------------------
		// Valida se existe algum item definido como pluma
		//--------------------------------------------------
		nPosHd  := GdFieldPos('DXC_PLUMA', oMdGridDes:aHeader )
		aEval(oMdGridDes:aCols, {| | nCont++,  If( oMdGridDes:aCols[nCont,nPosHd] == '1' .And. !oMdGridDes:IsDeleted(),  nReg++,  nReg ) } )
		If nReg > 1
			lRet := .F.
			Help('',1 , STR0020, , STR0021, 1, 0 ) //"Atenção"###"Somente um registro pode ser definido como pluma, verifique se existem outros registros na tela com está definição."
		Else
			oMdGridDes:SetValue('DXC_TIPO','0')
		EndIf
		
		If lRet .And. xConteudo = '1'
			oMdGridDes:LoadValue('DXC_TIPO','3')
			oMdGridDes:LoadValue('DXC_PERC', 0 )
		Else
			oMdGridDes:LoadValue('DXC_TIPO','2')		
		Endif
	EndIf
	endIf

Return(lRet)

/** --------------------------------------------------------------------------------
{Protheus.doc} AGR611TM()
Opção F4 - para campo Lote (Consulta de Saldos)

@author: 	Ana Laura Olegini
@since: 	05/05/2015
@Uso: 		AGRA611
-------------------------------------------------------------------------------- **/
Function AGR611TM( )
	Local cFiltro := ""	

	If ReadVar() == 'M->DXC_TM'
		cFiltro := "@# F5_TIPO == 'P' @#" //Produção
	ElseIf ReadVar() == 'M->DXF_TM'
		cFiltro := "@# F5_TIPO == 'R' @#" //Requisição
	Else
		cFiltro := "@#@#"
	Endif

Return cFiltro


/*/{Protheus.doc} AGRA611F4
Opção F4 - para campo Lote (Consulta de Saldos)

@author ana.olegini
@since  27/04/2018
@version undefined
@type function
/*/
Static Function AGRA611F4()
	Local aOldArea  := GetArea()
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oDXF		:= oModel:GetModel( "MdGridDXF" )
	Local oDXC		:= oModel:GetModel( "MdGridDes" )
	Local cCodPro	:= ''
	Local cCodLoc	:= ''

	if ValType(oModel) != "U" // verifica se o modelo é um objeto para não estourar erro na tela inicial caso o F4 seja utilizado
		nOperation  := oModel:GetOperation()
		IF nOperation == MODEL_OPERATION_UPDATE // só dever ser executado se for UPDATE
			oDXF		:= oModel:GetModel( "MdGridDXF" )
			cCodPro         := oDXF:GetValue( "DXF_CODPRO" )
			
			If ReadVar() == "M->DXF_LOTCTL"	.Or. ReadVar() == "M->DXF_NMLOT"
				cCodPro	:= oDXF:GetValue( "DXF_CODPRO" )
				cCodLoc	:= oDXF:GetValue( "DXF_LOCAL" )	
		
				If Rastro(cCodPro) 
					//--Usada a função do AGro pois o F4Lote() não realiza a consulta quando os produtos que tem rastro por Lote.	 	
					//--somente funciona com produtos que tem rastro por Sublote.				
					OGAC120( cCodPro )
				Else
					Help('',1, STR0029, , STR0030, 1, 0 )	//"Ajuda"#"Produto não possui rastro por lote."  
				EndIf
			EndIf
	
			If ReadVar() == "M->DXC_LOTCTL" .Or. ReadVar() == "M->DXC_NMLOT"
				cCodPro	:= oDXC:GetValue( "DXC_CODPRO" )
				cCodLoc	:= oDXC:GetValue( "DXC_LOCAL" )	
		
				If Rastro(cCodPro)
					//--Usada a função do AGro pois o F4Lote() não realiza a consulta quando os produtos que tem rastro por Lote.	 	
					//--somente funciona com produtos que tem rastro por Sublote.				
					OGAC120( cCodPro )
				Else
					Help('',1, STR0029, , STR0030, 1, 0 )	//"Ajuda"#"Produto não possui rastro por lote."    
				EndIf
			EndIf	
	
			If ReadVar() == "M->DXC_LOTPRD" .Or. ReadVar() == "M->DXC_NMLPRD"
				cCodPro	:= oDXC:GetValue( "DXC_PRDPRO" )
				cCodLoc	:= oDXC:GetValue( "DXC_LOCPRD" )
		
				If Rastro(cCodPro) 
					//--Usada a função do AGro pois o F4Lote() não realiza a consulta quando os produtos que tem rastro por Lote.	 	
					//--somente funciona com produtos que tem rastro por Sublote.				
					OGAC120( cCodPro )
				Else
					Help('',1, STR0029, , STR0030, 1, 0 )	//"Ajuda"#"Produto não possui rastro por lote."     
				EndIf
			EndIf		
	
		EndIf	
	EndIf
	
	RestArea(aOldArea)
Return lRet


/*/{Protheus.doc} CottonStruct
//TODO Atualiza a estrutura do produto algodao
@author bruna.rocio
@since 16/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CottonStruct( )
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local oModel	:= FwModelActive()
	Local oDXF		:= oModel:GetModel( "MdGridDXF" )
	Local oDXC		:= oModel:GetModel( "MdGridDes" )
	Local nDXC      := 0
	Local nCount    := 0
	
	If ValType(oModel) != "U" // verifica se o modelo é um objeto para não estourar erro na tela inicial
	
		For nDXC := 1 to oDXC:Length()
			oDXC:GoLine( nDXC )
			If !oDXC:IsDeleted()
		
				If oDXC:GetValue('DXC_PLUMA') = '1'
				
					For nCount := 1 to oDXF:Length()
						oDXF:GoLine( nCount )
						If !oDXF:IsDeleted()
						
							dbSelectArea('SG1')
							dbSetOrder(2)
							If dbSeek(fwxFilial('SG1')+oDXF:GetValue('DXF_CODPRO')+oDXC:GetValue('DXC_PRDPRO'))
								If RecLock('SG1',.F.)
									SG1->G1_QUANT := oDXF:GetValue('DXF_QTDPRO')  
								Endif
								SG1->(dbUnlock())
							Else
								If RecLock('SG1',.T.)
									SG1->G1_FILIAL := fwxFilial('SG1')
									SG1->G1_COD    := oDXC:GetValue('DXC_PRDPRO')
									SG1->G1_COMP   := oDXF:GetValue('DXF_CODPRO')
									SG1->G1_QUANT  := oDXF:GetValue('DXF_QTDPRO') 
									SG1->G1_FIXVAR := "V" //variavel
									SG1->G1_REVFIM := "ZZZ"
									SG1->G1_INI    := dDatabase
									SG1->G1_FIM    := ctod("31/12/2049")
								Endif
								SG1->(dbUnlock())
							Endif
						Else
							//Deleta produto da estrutura
							dbSelectArea('SG1')
							dbSetOrder(2)
							If dbSeek(fwxFilial('SG1')+oDXF:GetValue('DXF_CODPRO')+oDXC:GetValue('DXC_PRDPRO'))
								If RecLock('SG1',.F.)
									SG1->(dbDelete())  
								Endif
								SG1->(dbUnlock())
							Endif	
						Endif
					Next nCount
				Endif
			Endif	
		Next nDXC
	Endif
	
	RestArea(aArea)
Return lRet
