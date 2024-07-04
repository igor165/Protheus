#INCLUDE "JURA193.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Class Rest193 From JRestModel
	Data lSm0Closed
	Method Activate()
	Method DeActivate()
	Method Total()
	Method SetAlias()
	Method Skip()
	Method Seek()
EndClass

Method Activate() Class Rest193
	self:lSm0Closed := .F.
	If Select("SM0") == 0
		self:lSm0Closed := .T.
		OpenSm0(, .F.)
	EndIf
Return _Super:Activate()

Method DeActivate() Class Rest193
	If self:lSm0Closed
		SM0->(dbCloseArea())
	EndIf
Return _Super:DeActivate()

Method Total() Class Rest193
Local nRecno := SM0->(Recno())
Local nTotal := 0

	If self:Seek()
		While !SM0->(Eof())
			nTotal++
			self:Skip()
		End
	EndIf
	SM0->(dbGoTo(nRecno))

Return nTotal

Method SetAlias(cAlias) Class Rest193
	self:cAlias := "SM0"
Return .T.

Method Skip(nSkip) Class Rest193
	SM0->(dbSkip(nSkip))
Return !SM0->(Eof())

Method Seek(cPk) Class Rest193

	If Empty(cPk)
		SM0->(dbGoTop())
	Else
		cPk := SubStr(cPk, Len(xFilial("SM0"))+1)
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cPk))
	EndIf

Return !SM0->(Eof())

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA193
Empresas Protheus para integração com o LegalDesk.

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA193()
Local oModel   := FWLoadModel( 'JURA193' )

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Integração com o Equitrac.

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStruSM0    := DefStrModel() 

oModel := FWFormModel():New( 'JURA193', { || }/*bPreValidacao*/, { || }/*bPosValidacao*/, { || }/*bCommit*/, { || }/*bCancel*/ )
oModel:AddFields( 'SM0MASTER', /*cOwner*/, oStruSM0, { || }/*bPreValidacao*/, { || }/*bPosValidacao*/,{ |oM| J193LOAD() })
oModel:SetDescription( STR0001 ) //"Empresas Protheus - Integração LegalDesk"
oModel:GetModel( 'SM0MASTER' ):SetDescription( STR0001 ) //"Empresas Protheus - Integração LegalDesk"
oModel:SetPrimaryKey( {"M0_CODIGO", "M0_CODFIL"} ) 

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrModel
Monta manualmente a estrutuda do model.

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefStrModel()
Local oStruct  := FWFormModelStruct():New()
Local bValid   := { || .T.}
Local bWhen    := { || }
Local bRelac   := { || }

	
		//-------------------------------------------------------------------
		// Tabela
		//-------------------------------------------------------------------
		
		oStruct:AddTable( ;
		"   "           , ;  // [01] Alias da tabela
		{}              , ;                // [02] Array com os campos que correspondem a primary key
		"Filiais"      , ;
		{|| }           )                 // [03] Descrição da tabela
		
		//-------------------------------------------------------------------
		// Indices
		//-------------------------------------------------------------------
		
		oStruct:AddIndex( ;
		1               , ;             // [01] Ordem do indice
		"1"             , ;             // [02] ID
		"M0_CODIGO"     , ;             // [03] Chave do indice
		"Cód Empresa"   , ;             // [04] Descrição do indice
		""              , ;             // [05] Expressão de lookUp dos campos de indice
		""              , ;             // [06] Nickname do indice
		.T. )      												 // [07] Indica se o indice pode ser utilizado pela interface
	
		//-------------------------------------------------------------------
		// Campos
		//-------------------------------------------------------------------
		
		//1
		oStruct:AddField( ;
		"Cód Empresa"                  , ;              // [01] Titulo do campo
		"Cód Empresa"                  , ;              // [02] ToolTip do campo
		"M0_CODIGO"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                             , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
	
	
		//2
		oStruct:AddField( ;
		"Cód Filial"                   , ;              // [01] Titulo do campo
		"Cód Filial"                   , ;              // [02] ToolTip do campo
		"M0_CODFIL"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                             , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
		//3  
		oStruct:AddField( ;
		"Nome Empresa"                       , ;              // [01] Titulo do campo
		"Nome Empresa"                       , ;              // [02] ToolTip do campo
		"M0_NOMECOM"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual  
		//4
		oStruct:AddField( ;
		"CNPJ"                       , ;              // [01] Titulo do campo
		"CNPJ"                       , ;              // [02] ToolTip do campo
		"M0_CGC"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
		//5
		oStruct:AddField( ;
		"UF"                       , ;              // [01] Titulo do campo
		"UF"                       , ;              // [02] ToolTip do campo
		"M0_ESTENT"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )
		//6
		oStruct:AddField( ;
		"Insc Estadual"                       , ;              // [01] Titulo do campo
		"Insc Estadual"                       , ;              // [02] ToolTip do campo
		"M0_INSC"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
		//7
		oStruct:AddField( ;
		"Insc Municipal"                       , ;              // [01] Titulo do campo
		"Insc Municipal"                       , ;              // [02] ToolTip do campo
		"M0_INSCM"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
		//8
		oStruct:AddField( ;
		"Cód Munic"                       , ;              // [01] Titulo do campo
		"Cód Munic"                       , ;              // [02] ToolTip do campo
		"M0_CODMUN"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
		//9
		oStruct:AddField( ;
		"Nome Filial"                       , ;              // [01] Titulo do campo
		"Nome Filial"                       , ;              // [02] ToolTip do campo
		"M0_FILIAL"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual 
		//10     
		oStruct:AddField( ;
		"Município"                       , ;              // [01] Titulo do campo
		"Município"                       , ;              // [02] ToolTip do campo
		"M0_CIDENT"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtua
		//11               
		oStruct:AddField( ;
		"Inscrição"                       , ;              // [01] Titulo do campo
		"Inscrição"                       , ;              // [02] ToolTip do campo
		"M0_INSCANT"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtua  
		//12
		oStruct:AddField( ;
		"NIRE"                       , ;              // [01] Titulo do campo
		"NIRE"                       , ;              // [02] ToolTip do campo
		"M0_NIRE"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtua
		//13
		oStruct:AddField( ;
		"Data do Nire"                       , ;              // [01] Titulo do campo
		"Data do Nire"                       , ;              // [02] ToolTip do campo
		"M0_DTRE"                    , ;              // [03] Id do Field
		"D"                            , ;              // [04] Tipo do campo
		8                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtua
		//14
		oStruct:AddField( ;
		"End Cob"                       , ;              // [01] Titulo do campo
		"End Cob"                       , ;              // [02] ToolTip do campo
		"M0_ENDCOB"                    , ;              // [03] Id do Field
		"C"                            , ;              // [04] Tipo do campo
		50                              , ;              // [05] Tamanho do campo
		0                              , ;              // [06] Decimal do campo
		bValid                         , ;              // [07] Code-block de validação do campo
		bWhen                          , ;              // [08] Code-block de validação When do campo
		                               , ;              // [09] Lista de valores permitido do campo
		                               , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac                         , ;              // [11] Code-block de inicializacao do campo
		.F.                            , ;              // [12] Indica se trata-se de um campo chave
		                               , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		                               , ;
		               )                               // [14] Indica se o campo é virtual
         
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J193LOAD
Carrega as informações das empresas com base no SIGAMAT.EMP.

@author Cristina Cintra
@since 26/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J193LOAD()
Local aRet   := {}

aRet := {{SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOMECOM, SM0->M0_CGC, SM0->M0_ESTENT, SM0->M0_INSC, SM0->M0_INSCM, SM0->M0_CODMUN,;
	             SM0->M0_FILIAL, SM0->M0_CIDENT, SM0->M0_INSCANT, SM0->M0_NIRE, SM0->M0_DTRE, SM0->M0_ENDCOB}, SM0->(Recno())}

Return aRet
