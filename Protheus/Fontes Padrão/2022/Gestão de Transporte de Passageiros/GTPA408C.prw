#include "GTPA408C.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH' 


Static n408LinMark    := 0
STatic c408VeicAtual  := ''

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Rotina de Veículos por Escala.(Seleção de Veiculos Step 4)

@sample  	ModelDef()

@return  	oModel - Objeto do Model 

@author		Fernando Amorim (Cafu)
@since		
@version 	P12.1.16
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStruPai		:= FWFormModelStruct():New()// Inclusão Obrigatoria (Nao Usado)
Local oStruVeic  	:= FWFormModelStruct():New() // Cabeçalho da escala
//Local bPosValid		:= {|oModel| GTPA408CTdOk(oModel)}

G408CStruct(oStruPai,oStruVeic,"M")

oModel := MPFormModel():New('GTPA408C',/*bPreValid*/, /*bPosValid*/, /*{|oMdl| G408CCommit(oMdl)}*/, /*bCancel*/)

oModel:AddFields("PAI",/*PAI*/,oStruPai)
oModel:AddGrid("VEICULO",'PAI',oStruVeic)
oModel:SetRelation( 'VEICULO', { { 'PAI', 'PAI' } }   )


oModel:GetModel("PAI"):SetOnlyQuery(.T.)
oModel:GetModel("VEICULO"):SetOnlyQuery(.T.)
oModel:GetModel( 'VEICULO' ):SetNoDeleteLine( .T. )
oModel:GetModel("PAI"):SetDescription('PAI') //Seleção de Veículos
oModel:GetModel("VEICULO"):SetDescription(STR0001) //Seleção de Veículos //'Seleção de Veículos'
oModel:SetDescription(STR0002)// Veículos //'Veículos'

oModel:SetPrimaryKey({})

oModel:SetActivate( { |oModel|GTPA408CAPOS(oModel) } )

Return (oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@sample  	ViewDef()

@return  	oView - Objeto do View

@author		Fernando Amorim(Cafu)

@since		11/07/2017
@version 	P12.1.16
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView			:= Nil	
																					
Local oStruVeic	    := FWFormViewStruct():New()

Local oModel		:= FWLoadModel("GTPA408C")

G408CStruct(Nil,oStruVeic,"V") 

oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddGRID("VIEW_VEIC",oStruVeic,"VEICULO")
Oview:GetModel('VEICULO'):SetNoDeleteLine(.T.)


oView:CreateHorizontalBox("SUPERIOR" , 100) // grid de veiculo

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_VEIC", "SUPERIOR")

oView:EnableTitleView("VIEW_VEIC", STR0001)// STR0001

oView:GetViewObj("VIEW_VEIC")[3]:SetDoubleClick({|oVw,cCpo,nLn,nLn2| ShowCaract(oVw,cCpo,nLn,nLn2) })

If __cUserId == "000000" // Keys adicionados como solução de contorno para automação com TIR (metodo ClickImage não está funcionando)
	SetKey( VK_F6 , {|oVw,cCpo,nLn,nLn2| ShowCaract(oView,'VEICULO',1,1) } ) 
Endif

Return(oView)

/*/{Protheus.doc} G408CCommit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 11/07/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
/*Static Function G408CCommit(oModel)


Return(lRet)*/



/*/{Protheus.doc} G408CStruct()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 11/07/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408CStruct(oStruPai,oStruVeic,cTipo) 


If ( cTipo == "M" )
	If ValType( oStruPai ) == "O"
		oStruPai:AddTable("   ",{" "}," ")
		oStruPai:AddField(	STR0004,;									// 	[01]  C   Titulo do campo
					 		STR0004,;									// 	[02]  C   ToolTip do campo
					 		"PAI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		3,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	Endif
	If ValType( oStruVeic ) == "O"
		oStruVeic:AddTable("   ",{" "}," ")
		oStruVeic:AddField(	STR0004,;									// 	[01]  C   Titulo do campo
					 		STR0004,;									// 	[02]  C   ToolTip do campo
					 		"PAI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		3,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		
		oStruVeic:AddField( '   ', ; // cTitle // 'Mark'
				STR0005, ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKVEI', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				{|oModel, cCampo, xValueNew, nLine, xValueOld| vldMark(oModel, cCampo, xValueNew, nLine, xValueOld) }, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual		
		
		oStruVeic:AddField(	STR0006,;									// 	[01]  C   Titulo do campo
					 		STR0006,;									// 	[02]  C   ToolTip do campo
					 		"FILIAL",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("T9_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruVeic:AddField(	STR0007,;									// 	[01]  C   Titulo do campo
					 		STR0008,;									// 	[02]  C   ToolTip do campo
					 		"VEICULO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		16,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual

		oStruVeic:AddField(	STR0009,;						// 	[01]  C   Titulo do campo
				 		    STR0009,;				// 	[02]  C   ToolTip do campo
					 		"DESCRICAO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		40,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
									
	Endif
	
		
Else
    If ValType( oStruVeic ) == "O"
    
    	oStruVeic:AddField( 'CHECKVEI', ; // cIdField
				'01', ; // cOrdem
				'Check', ; // cTitulo // 'Mark'
				STR0010, ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				{STR0011}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
				'CHECK', ; // cType
				'@!', ; // cPicture
				Nil, ; // nPictVar
				Nil, ; // Consulta F3
				.T., ; // lCanChange
				'' , ; // cFolder
				Nil, ; // cGroup
				Nil, ; // aComboValues
				Nil, ; // nMaxLenCombo
				Nil, ; // cIniBrow
				.T., ; // lVirtual
				Nil ) // cPictVar
    	
	    oStruVeic:AddField(	"VEICULO",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0012,;						// [03]  C   Titulo do campo
	                        STR0012,;						// [04]  C   Descricao do campo
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruVeic:AddField(	"DESCRICAO",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0009,;						// [03]  C   Titulo do campo
	                        STR0009,;						// [04]  C   Descricao do campo
	                        {STR0014},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	EndIf
    
EndIf



Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldMark
	valida a marcação do registro e elimina uma marcação anterior
@sample 	VldMark()
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function VldMark( oMdlBase, cCampo, xValueNew, nLine, xValueOld )

Local nLinAtual		:= 0
Local lRet       	:= .T. 


If lRet .And. xValueNew
	nLinAtual   := oMdlBase:GetLine()
	
	If nLinAtual <> n408LinMark 
	
		If n408LinMark <> 0
			oMdlBase:GoLine( n408LinMark )
			oMdlBase:SetValue('CHECKVEI', .T. ) 
		EndIf
		
		oMdlBase:GoLine( nLinAtual )  // retorna ao item posicionado antes
		
	EndIf
	
	n408LinMark := nLinAtual
Else
	n408LinMark := 0
EndIf

oMdlBase:GoLine( 1 ) 

Return lRet
				 		
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPa408cAPOS
Executa a verificação da edição da linha no grid dos Colaboradores

@sample		GTP301APre( oModel )

@param 			oModel	- Objeto, objeto do model

@return		cRet
@author		Fernando Amorim(Cafu)
@since			10/07/2017
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA408CAPOS(oModel)

Local aArea		:= GetArea()
Local aAreaGQA	:= GQA->( GetArea() )
Local lRet 		:= .T.
Local nX		:= 0
Local oMdlVei 	:= oModel:GetModel( 'VEICULO' )
Local cIdModel	:= 'VEICULO'
Local aVeic		:= GetAveic()
Local oModel408A:= GA408GetModel('GTPA408A')

oView			:= GA408GetView('GTPA408C')

For nX:= 1 To Len(aVeic)
	
	If ( !G408IsVeicEscala(aVeic[nX],oModel408A:GetModel("MASTER"):GetValue("GY4_ESCALA"))[1] )
	
		If  !oMdlVei:IsEmpty() .and. !( oMdlVei:Length() == 1 .and. Empty(oMdlVei:GetValue( 'VEICULO' )))
			If oMdlVei:Length() == oMdlVei:AddLine()
				Return .F.
			EndIf
		Endif
			
		oModel:LoadValue(cIdModel, 'VEICULO', aVeic[nX])	
		oModel:LoadValue(cIdModel, 'DESCRICAO', posicione('ST9',1,xFilial('ST9')+ aVeic[nX],'T9_NOME' ))
		
		dbSelectArea("GQA")  
		GQA->(DbSetOrder(1))
	
		If !( lRet := oModel:LoadValue(cIdModel, 'CHECKVEI', GQA->(DbSeek(xFilial("GQA") + oModel408A:GetModel("MASTER"):GetValue("GY4_ESCALA") + aVeic[nX] ) ) ) ) 
			lRet := .F.
			Exit
		EndIf
	
	EndIf
	
Next

RestArea( aAreaGQA )
RestArea( aArea )

Return (lRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ShowCaract
Executa uma consulta as caracteristicas de um veiculo

@sample		ShowCaract( oModel )

@param 			oModel	- Objeto, objeto do model

@return		cRet
@author		Fernando Amorim(Cafu)
@since			13/07/2017
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function ShowCaract(oView,cCampoVei,nLin,nLin2)

If cCampoVei <> 'CHECKVEI'
	OMldVei 	:= oView:GetModel('VEICULO')
	OMldVei:GoLine(nLin)
	c408VeicAtual 	:= OMldVei:GetValue( 'VEICULO' )
	If !Empty(alltrim(c408VeicAtual))

		If FindFunction('ViewStb')
			FWExecView(STR0018,"VIEWDEF.GTPA408D",MODEL_OPERATION_VIEW,,{|| .T.},,60) //'Caracteristicas do veiculo'
		Else
			FWExecView("Dados do Veículo","VIEWDEF.MNTA084",MODEL_OPERATION_VIEW,,{|| .T.},,60) //'Dados do Veículo'
		Endif	

	Endif
Endif	

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetaVeic
	Busca o array static aG408Veic
@since		13/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function GetVeicAt()

Return c408VeicAtual


