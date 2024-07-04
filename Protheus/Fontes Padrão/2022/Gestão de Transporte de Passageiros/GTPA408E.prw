#Include "GTPA408E.ch"
#include "GTPA408A.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH'

Static oG408ETab	:= Nil

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para a gravação das Escalas de Veículos
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/07/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel    := nil
Local oStruPai  := Nil
Local oStruG52  := FWFormStruct(1,"G52")
Local oStruGQA  := FWFormStruct(1,"GQA")
Local oStruGZQ  := FWFormStruct(1,"GZQ")

Local oStruGY4  := Eval({|x| x :=  FwLoadModel("GTPA408A"):GetModel("MASTER"), x:GetStruct()})

Local aRelation := {}

GA408EStruct(@oStruPai,oStruG52,oStruGQA)

oModel :=  MPFormModel():New("GTPA408E")

oModel:AddFields("MASTER",/*PAI*/,oStruPai,,,{||G408ECARGA()})
oModel:AddGrid("G52DETAIL", "MASTER", oStruG52)
oModel:AddGrid("GQADETAIL", "MASTER", oStruGQA)
oModel:AddGrid("GY4DETAIL", "MASTER", oStruGY4)
oModel:AddGrid("GZQDETAIL", "G52DETAIL", oStruGZQ)

aAdd(aRelation, { "G52_FILIAL", "XFILIAL('G52')" } )
aAdd(aRelation, { "G52_CODIGO", "G52_CODIGO" } )

oModel:SetRelation( "G52DETAIL", aClone(aRelation), G52->(IndexKey(1)))

aRelation := {}

aAdd(aRelation, { "GQA_FILIAL", "XFILIAL('GQA')" } )
aAdd(aRelation, { "GQA_CODESC", "G52_CODIGO" } )

oModel:SetRelation( "GQADETAIL", aClone(aRelation), GQA->(IndexKey(1))  )

aRelation := {}

aAdd(aRelation, { "GY4_FILIAL", "XFILIAL('GY4')" } )
aAdd(aRelation, { "GY4_ESCALA", "G52_CODIGO" } )
aAdd(aRelation, { "GY4_TIPO", "'1'"})
oModel:SetRelation( "GY4DETAIL", aClone(aRelation), GY4->(IndexKey(1))  )

aRelation := {}

aAdd(aRelation,{ "GZQ_FILIAL", "XFILIAL('GZQ')"	})
aAdd(aRelation,{ "GZQ_ESCALA", "G52_CODIGO" 	})
aAdd(aRelation,{ "GZQ_SEQESC", "G52_SEQUEN"		})

oModel:GetModel("MASTER"):SetOnlyQuery (.T.)
oModel:SetRelation( "GZQDETAIL", aClone(aRelation), GZQ->(IndexKey(1))  )

oModel:GetModel("GZQDETAIL"):SetOptional(.t.)

oModel:GetModel("MASTER"):SetDescription(STR0001) //"Escala"
oModel:GetModel("G52DETAIL"):SetDescription(STR0002) //"Horários da Escala"
oModel:GetModel("GQADETAIL"):SetDescription(STR0003) //"Veículos da Escala"
oModel:GetModel("GY4DETAIL"):SetDescription(STR0004) //"Filtro da Escala"
oModel:GetModel("GZQDETAIL"):SetDescription("Secionamento")

oModel:SetDescription(STR0005) //"Escala de Veículos"

oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc} ViewDef
    Função que define a view para a gravação das Escalas de Veículos
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/07/2017
    @version 1
    @param 
    @return oView, objeto, instância da classe FwFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

Local oView			:= Nil	

Local oStruPai  := Nil
Local oStruG52  := FWFormStruct(2,"G52")
Local oStruGQA  := FWFormStruct(2,"GQA")

Local oModel	:= FWLoadModel("GTPA408E")

GA408EStruct(@oStruPai,oStruG52,oStruGQA,"V")

oView := FWFormView():New()

oStruG52:RemoveField('G52_CODIGO' )
oStruG52:RemoveField('G52_DESCRI' )
oStruGQA:RemoveField('GQA_CODESC' )

oView:SetModel(oModel)	

oView:AddField("VW_MASTER",oStruPai,"MASTER")
oView:AddGrid("VW_G52DETAIL",oStruG52,"G52DETAIL")
oView:AddGrid("VW_GQADETAIL",oStruGQA,"GQADETAIL")
oView:GetModel('G52DETAIL'):SetNoDeleteLine(.T.)
oView:GetModel('GQADETAIL'):SetNoDeleteLine(.T.)

oView:CreateHorizontalBox("PAI" , 20) 
oView:CreateHorizontalBox("SUPERIOR" , 40) // cabeçalho
oView:CreateHorizontalBox("INFERIOR" , 40) // montagem da escala

oView:AddUserButton("Seccionado","GTPA408E",{|oModel| GTPA408G(oModel,oModel:GetModel("G52DETAIL"):GetLine())},"Seccionando", , {MODEL_OPERATION_VIEW}) // "Seccionado"    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VW_MASTER", "PAI")
oView:SetOwnerView( "VW_G52DETAIL", "SUPERIOR")
oView:SetOwnerView( "VW_GQADETAIL", "INFERIOR")

oView:EnableTitleView("VW_G52DETAIL", STR0002) //"Horários da Escala"
oView:EnableTitleView("VW_GQADETAIL", STR0003) //"Veículos da Escala"

Return(oView)

/*/{Protheus.doc} GA408EStruct
    Função responsável por criar a estrutura dos submodelos, tanto para o model quanto view,
	utilizados pelo MVC. 
    @type  Static Function
    @author(s) 	Fernando Radu Muscalu
				Mick William
    @since 27/03/2017
    @version 1

    @param 	oStruPai, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (MASTER)
			oStruG52, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (G52DETAIL)
			oStruGQA, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GQADETAIL)
			cTipo, caractere, Tipo de Estrutura que será criada - "M" - model; "V" - View
			oStrMdlGrd, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (ITENS).
				Usado somente na montagem da view
    @return nil, nulo, Sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA408EStruct(oStruPai,oStruG52,oStruGQA,cTipo)

Local cFieldsIn := ""

Local nI       := 0

Local aFldStr   := {}
Local aOrdem	:= {}

Default cTipo   := "M"

If ( cTipo == "M" )

	oStruPai := FWFormModelStruct():New()
	
	G408ETempTab()
	oStruPai:AddTable(oG408ETab:GetAlias(), , STR0014, {|| oG408ETab:GetRealName() })	//"Temporario G52"
	
	oStruPai:AddField(						  ;
	AllTrim( STR0006 ) 					, ; //'Codigo'
	AllTrim( STR0006 ) 					, ; //'Codigo'
	'G52_CODIGO' 								, ;
	'C' 									, ;
	TamSX3("G52_CODIGO")[1] 				, ;
	0 										, ;
	Nil										, ;
	NIL 									, ;
	Nil										, ; 
	NIL 									, ;
	NIL										, ;
	NIL 									, ;
	NIL 									, ; 
	.T. 										)
	
	oStruPai:AddField(						  ;
	AllTrim( STR0007 ) 					, ; //'Descrição'
	AllTrim( STR0007 ) 					, ; //'Descrição'
	'G52_DESCRI' 							, ;
	'C' 									, ;
	TamSX3("G52_DESCRI")[1] 				, ;
	0 										, ;
	Nil										, ;
	NIL 									, ;
	Nil										, ; 
	NIL 									, ;
	NIL										, ;
	NIL 									, ;
	NIL 									, ; 
	.T. 										)
    
	oStruPai:AddField(						  ;
	AllTrim( STR0008 ) 					, ; //'Horário'
	AllTrim( STR0008 ) 					, ; //'Horário'
	'G52_SERVIC' 								, ;
	'C' 									, ;
	TamSX3("G52_SERVIC")[1] 				, ;
	0 										, ;
	Nil										, ;
	NIL 									, ;
	Nil										, ; 
	NIL 									, ;
	NIL										, ;
	NIL 									, ;
	NIL 									, ; 
	.T. 										)
	
	//Adição de campos novos na estrutura do Filho - G52
	oStruG52:AddField(	STR0013,;							// 	[01]  C   Titulo do campo	//"Origem/Destino"
				 		STR0013,;						// 	[02]  C   ToolTip do campo	//"Origem/Destino"
				 		"GIDNLINHA",;							// 	[03]  C   Id do Field	
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSX3("GID_NLINHA")[1],;				//	[05]  N	  Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{|| Iif(!INCLUI,TPNomeLinh(G52->G52_LINHA, ,G52->G52_SENTID),"") },;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
	
    //Estrutura do Modelo do Pai - MASTER
    oStruPai:SetProperty("G52_CODIGO",MODEL_FIELD_OBRIGAT,.T.)
    oStruPai:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})
	
	oStruGQA:SetProperty("GQA_CODVEI",MODEL_FIELD_VALID,{|| .T.})

    //Estrutura do Modelo Filho da tabela G52
    oStruG52:SetProperty("*",MODEL_FIELD_OBRIGAT,.f.)

Else
	oStruPai := FWFormViewStruct():New()
	
	oStruPai:AddField( 					  		  ; 
	'G52_CODIGO' 								, ;
	'1' 										, ;
	AllTrim( STR0009 ) 	, ; //'Escala'
	AllTrim( STR0009 ) 	, ; //'Escala'
	{ STR0010 } 			, ; //'Codigo da Escala'
	'GET' 										, ;
	'@!' 										, ;
	NIL 										, ;
	Nil 										, ;
	.T. 										, ;
	NIL 										, ;
	NIL 										, ;
	Nil 										, ;
	NIL 										, ;
	NIL 										, ;
	.T. 										, ;
	NIL 											)
	
	oStruPai:AddField( 					  		  ; 
	'G52_DESCRI' 								, ;
	'2' 										, ;
	AllTrim( STR0011 ) 						, ; //'Descricao'
	AllTrim( STR0011 ) 						, ; //'Descricao'
	{ STR0012 } 					, ; //'Codigo da Descrição'
	'GET' 										, ;
	'@!' 										, ;
	NIL 										, ;
	Nil 										, ;
	.T. 										, ;
	NIL 										, ;
	NIL 										, ;
	Nil 										, ;
	NIL 										, ;
	NIL 										, ;
	.T. 										, ;
	NIL 											)
	
	//Adicionao campo à estrutura da tabela G52
	oStruG52:AddField( 	'GIDNLINHA' 								, ;
						'02' 										, ;
						STR0013 						, ; //"Origem/Destino"
						STR0013 						, ; //"Origem/Destino"
						{ STR0013 } 					, ; //"Origem/Destino"
						'GET' 										, ;
						'@!' 										, ;
						NIL 										, ;
						Nil 										, ;
						.T. 										, ;
						NIL 										, ;
						NIL 										, ;
						Nil 										, ;
						NIL 										, ;
						NIL 										, ;
						.T. 										, ;
						NIL 											)
						
    //Estrutura da tabela G52
    cFieldsIn := "G52_SERVIC|"
    cFieldsIn += "GIDNLINHA|"
    cFieldsIn += "G52_SEQUEN|"
    cFieldsIn += "G52_DIA|"
    cFieldsIn += "G52_PMANUT|"
    cFieldsIn += "G52_DPARAD|"
    //cFieldsIn += "G52_KMVIAG|"
    cFieldsIn += "G52_HRSDGR|"
    cFieldsIn += "G52_HRSDRD|"
    cFieldsIn += "G52_HRCHRD|"
    cFieldsIn += "G52_HRCHGR|"
    cFieldsIn += "G52_SEGUND|"
    cFieldsIn += "G52_TERCA|"
    cFieldsIn += "G52_QUARTA|"
    cFieldsIn += "G52_QUINTA|"
    cFieldsIn += "G52_SEXTA|"
    cFieldsIn += "G52_SABADO|"
    cFieldsIn += "G52_DOMING"

    aFldStr := aClone(oStruG52:GetFields())

    For nI := 1 to Len(aFldStr)

        If ( !(aFldStr[nI,1] $ cFieldsIn) )
            oStruG52:RemoveField(aFldStr[nI,1])
        EndIf

    Next nI
	
	oStruG52:SetProperty("G52_SERVIC",MVC_VIEW_ORDEM,"01")
	
	cFieldsIn := "GQA_CODESC|GQA_CODVEI|GQA_DESVEI"

	aFldStr := aClone(oStruGQA:GetFields())

    For nI := 1 to Len(aFldStr)

        If ( !(aFldStr[nI,1] $ cFieldsIn) )
            oStruGQA:RemoveField(aFldStr[nI,1])
        EndIf

    Next nI

	AAdd(aOrdem,{"G52_SEQUEN","G52_SERVIC"})
    AAdd(aOrdem,{"G52_SERVIC","GIDNLINHA"})
    AAdd(aOrdem,{"GIDNLINHA","G52_HRSDGR"})
    AAdd(aOrdem,{"G52_HRSDGR","G52_HRSDRD"})
	AAdd(aOrdem,{"G52_HRSDRD","G52_HRCHRD"})
	AAdd(aOrdem,{"G52_HRCHRD","G52_HRCHGR"})
	AAdd(aOrdem,{"G52_HRCHGR","G52_PMANUT"})
	AAdd(aOrdem,{"G52_PMANUT","G52_DPARAD"})
	AAdd(aOrdem,{"G52_DPARAD","G52_SEGUND"})
	AAdd(aOrdem,{"G52_SEGUND","G52_TERCA"})
	AAdd(aOrdem,{"G52_TERCA","G52_QUARTA"})
	AAdd(aOrdem,{"G52_QUARTA","G52_QUINTA"})
	AAdd(aOrdem,{"G52_QUINTA","G52_SEXTA"})
	AAdd(aOrdem,{"G52_SEXTA","G52_SABADO"})
	AAdd(aOrdem,{"G52_SABADO","G52_DOMING"})
	
	GTPOrdVwStruct(oStruG52,aOrdem)
    
EndIf

Return()

/*/{Protheus.doc} G408ECARGA
    Função responsável por criar a estrutura dos submodelos, tanto para o model quanto view,
	utilizados pelo MVC. 
    @type  Static Function
    @author	Mick William
    @since 27/03/2017
    @version 1

    @param 	
    @return nil, nulo, Sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408ECARGA()
	Local aLoad := {}
	Local aAux := {G52->G52_CODIGO,G52->G52_DESCRI,G52->G52_SERVIC} 
		
	aAdd(aLoad,aAux)
	aAdd(aLoad,0)

Return(aLoad)

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} CPEA40TempTab
Função para criar tabela temporária para guardar a estrutura fake utilizada no Grid.
Esta estrutura 'fake' criada foi proposital, para não possuir o vínculo com o metadados, por
questões de validações e limitações impostas (que são necessárias na rotina de cadastro de 
usuários) por ele.

@params

@return 
	
@type 		Static Function
@author 	Mick William
@since 		27/07/2017
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Static Function G408ETempTab()

Local aFldG52	:= {"G52_CODIGO","G52_DESCRI"}
Local aStruct	:= {}

Local nX		:= 0

If ( Valtype(oG408ETab) <> "O" )

	For nX := 1 to len(aFldG52)
		AAdd(aStruct,{AllTrim(aFldG52[nX]),TAMSX3(aFldG52[nX])[3],TAMSX3(aFldG52[nX])[1],TAMSX3(aFldG52[nX])[2]})
	Next nX

	oG408ETab := FWTemporaryTable():New()

	oG408ETab:SetFields(aStruct)
	oG408ETab:AddIndex("index1", {"G52_CODIGO"})
	oG408ETab:Create()

Else
	TcSqlExec('TRUNCATE TABLE '+ oG408ETab:GetRealName())
EndIf

Return()
