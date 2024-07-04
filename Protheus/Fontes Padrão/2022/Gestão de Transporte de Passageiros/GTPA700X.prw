#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

Static Function ModelDef()

Local oModel    := nil
Local oStruPai  := Nil
Local oStruG6Y  := FWFormStruct(1,"G6Y")
Local aRelation := {}

G700XStruct(@oStruPai,oStruG6Y)

oModel :=  MPFormModel():New("GTPA700X")

oModel:AddFields("MASTER",/*PAI*/,oStruPai,,,{|oField|GTP700XLoad(oField)} )
oModel:AddGrid("G6YDETAIL", "MASTER", oStruG6Y)

aAdd(aRelation, { "G6Y_FILIAL", "XFILIAL('G6Y')" } )

oModel:SetRelation( "G6YDETAIL", aClone(aRelation), G6Y->(IndexKey(1))  )

oModel:GetModel("MASTER"):SetDescription("LANÇAMENTOS") 
oModel:GetModel("G6YDETAIL"):SetDescription("Itens")

oModel:SetDescription("LANÇAMENTOS") 

oModel:GetModel('G6YDETAIL'):SetMaxLine(999999)


oModel:SetPrimaryKey({})

Return(oModel)


Static Function G700XStruct(oStruPai,oStruG6Y)

oStruPai := FWFormModelStruct():New()
	

oStruPai:AddTable("   ",{" "}," ")
oStruPai:AddField(						  ;
	AllTrim( 'Codigo' ) 					, ; //'Codigo'
	AllTrim( 'Codigo' ) 					, ; //'Codigo'
	'CODIGO' 								, ;
	'C' 									, ;
	TamSX3("G6Y_CODIGO")[1] 				, ;
	0 										, ;
	Nil										, ;
	NIL 									, ;
	Nil										, ; 
	NIL 									, ;
	NIL										, ;
	NIL 									, ;
	NIL 									, ; 
	.T. 										)
	
oStruG6Y:SetProperty('G6Y_TPLANC' , MODEL_FIELD_VALUES,{'1=Nota Fiscal de Entrada',;
														'2=Depositos',;
 														'3=Taxa De Embarque Avulsas',;
 														'4=Taxa De Embarque',;
 														'5=Documentos Controlados',;
 														'6=Lançamento Diario',;
 														'7=Bilhetes Cancelados por Cartão de Credito',;
 														'8=Receitas',;
 														'9=Despesas',;
														'A=Deposito de Terceiros' ;
 														} )
	
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP700XLoad()

Função responsável pelo Load do Cabeçalho da Tesouraria.
 
@sample	GTPA700X()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTP700XLoad(oFieldModel)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

Local nOperacao := oFieldModel:GetOperation()

	aAdd(aCampos,Space(TamSx3("G6T_CODIGO")[1]))
	Aadd(aLoad,aCampos)
	Aadd(aLoad,0)

	RestArea(aArea)

Return aLoad
