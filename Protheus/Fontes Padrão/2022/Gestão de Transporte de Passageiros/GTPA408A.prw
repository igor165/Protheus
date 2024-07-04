#include "GTPA408A.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Rotina de Veículos por Escala. 

@sample  	ModelDef()

@return  	oModel - Objeto do Model

@author		Fernando Radu Muscalu
@since		
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruCab  := FWFormStruct(1,"GY4")//FWFormModelStruct():New()

//G408AStruct(oStruCab,"M")
If fwisincallsteak("GTPA409")
	Return ()
EndIF
oModel := MPFormModel():New('GTPA408A')//,/*bPreValid*/, /*bPosValid*/, {|oMdl| G408ACommit(oMdl)}, /*bCancel*/)

//::AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)-
oModel:AddFields("MASTER",/*PAI*/,oStruCab)//,,,{|oSub| G408ALoad(oSub,1)})

oModel:GetModel("MASTER"):SetOnlyQuery(.t.)
oModel:GetModel("MASTER"):SetDescription("Parametrização para filtro.")
oModel:SetDescription("Parametrização para filtro.")

oModel:SetPrimaryKey({})

Return (oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@sample  	ViewDef()

@return  	oView - Objeto do View

@author		Cristiane Nishizaka

@since		23/07/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView			:= Nil																						
Local oStruCab	    := FWFormStruct(2,"GY4")

Local oModel		:= FWLoadModel("GTPA408A")

If fwisincallsteak("GTPA409")
	Return ()
EndIF

G408AStruct(oStruCab,"V")

oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddField("VIEW_CAB",oStruCab,"MASTER")

oView:CreateHorizontalBox( 'SUPERIOR'  , 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_CAB", "SUPERIOR")

oView:EnableTitleView("VIEW_CAB", "Parametrização para filtro.")

Return(oView)

/*/{Protheus.doc} G408AStruct()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 13/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408AStruct(oStruct,cTipo)
Local aOperad   := NIL

If ( cTipo == "M" )

    oStruct:AddField(	"Vigência de",;									// 	[01]  C   Titulo do campo
				 		"Data de Vigência de",;									// 	[02]  C   ToolTip do campo
				 		"DT_INICIO",;							// 	[03]  C   Id do Field
				 		"D",;									// 	[04]  C   Tipo do campo
				 		8,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual

    oStruct:AddField(	"Vigência até",;						// 	[01]  C   Titulo do campo
				 		"Data de Vigência até",;				// 	[02]  C   ToolTip do campo
				 		"DT_FINAL",;							// 	[03]  C   Id do Field
				 		"D",;									// 	[04]  C   Tipo do campo
				 		8,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual

    oStruct:AddField(	"Filtra por?",;						    // 	[01]  C   Titulo do campo
				 		"Filtra por?",;				            // 	[02]  C   ToolTip do campo
				 		"FILTRO",;							    // 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		FwBuildFeature(1, "Pertence('123')"),;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		{"1=Setor","2=Localidade","3=Ambos"},;	//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{|| "1"},;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual                                              

    oStruct:AddField(	"Setor",;						        // 	[01]  C   Titulo do campo
				 		"Setor",;				                // 	[02]  C   ToolTip do campo
				 		"SETOR",;							    // 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSx3("GYT_CODIGO")[1],;   			// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		{|| Vazio() .Or. ExistCpo("GYT")},;					// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;                                   //	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual                     

    oStruct:AddField(	"Localidade de",;						// 	[01]  C   Titulo do campo
				 		"Localidade de",;				        // 	[02]  C   ToolTip do campo
				 		"LOCAL_DE",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSx3("GI1_COD")[1],;					// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		{|| Vazio() .Or. ExistCpo("GI1")},;		// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;                                   //	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual                                          

    oStruct:AddField(	"Localidade até",;						    // 	[01]  C   Titulo do campo
				 		"Localidade até",;				            // 	[02]  C   ToolTip do campo
				 		"LOCAL_ATE",;							    // 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSx3("GI1_COD")[1],;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		{|| Vazio() .Or. ExistCpo("GI1")},;					// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;                                   //	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual

    oStruct:AddField(	"Tipo",;						    // 	[01]  C   Titulo do campo
				 		"Tipo",;				            // 	[02]  C   ToolTip do campo
				 		"TIPO",;							    // 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		FwBuildFeature(1, "Pertence('12')"),;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		{"1=Extremidades","2=Totalidade"},;	//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{|| "1"},;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)										// 	[14]  L   Indica se o campo é virtual                                              
Else
   
    oStruct:RemoveField("GY4_ESCALA")
    oStruct:RemoveField("GY4_TIPO")
    oStruct:RemoveField("GY4_NUMSRV")
    
    aOperad := GTPXCBox('GY4_FILTRO')
	
	If Len(aOperad) > 2
	    aDel(aOperad,3)
	    aSize(aOperad,2)
	Endif
    
	oStruct:SetProperty('GY4_FILTRO',MVC_VIEW_COMBOBOX,aOperad)
	
    If ( !INCLUI )
        oStruct:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
    EndIf

EndIf

Return()
