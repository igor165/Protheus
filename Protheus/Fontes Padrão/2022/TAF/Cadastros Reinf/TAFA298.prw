#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA298.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA298
Espet�culo Desportivo

@author fabio.santana
@since 29/01/2018
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA298()

BrowseDef()

Return

/*/{Protheus.doc} BrowseDef
Browse definition

@author Bruno Cremaschi
@since 16/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

Local oBrw	as object

If FunName() == "TAFXREINF"
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
EndIf

oBrw := FWmBrowse():New()
oBrw:SetDescription(STR0001) //'Espet�culo Desportivo'
oBrw:SetAlias('T9F')
oBrw:SetMenuDef( 'TAFA298' )
oBrw:Activate()

Return( oBrw )
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author fabio.santana
@since 29/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "TAFA298" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author fabio.santana
@since 29/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT9F := FWFormStruct( 1, 'T9F' )
Local oStruT9G := FWFormStruct( 1, 'T9G' )
Local oStruT9H := FWFormStruct( 1, 'T9H' )
Local oStruT9I := FWFormStruct( 1, 'T9I' )
Local oStruT9J := FWFormStruct( 1, 'T9J' )

Local oModel   := MPFormModel():New( 'TAFA298' ,,{|oModel| ValidModel(oModel) }, { |oModel| SaveModel( oModel ) }  )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

oModel:AddFields('MODEL_T9F', /*cOwner*/, oStruT9F)

// Tabela T9G - Boletim
oModel:AddGrid("MODEL_T9G","MODEL_T9F",oStruT9G,,{|oModel| ValidT9G(oModel)})
oModel:GetModel("MODEL_T9G"):SetOptional(.F.)
oModel:GetModel("MODEL_T9G"):SetUniqueLine({"T9G_NUMBOL",'T9G_TPCOMP','T9G_CATEVE'})
oModel:SetRelation("MODEL_T9G",{ {"T9G_FILIAL","xFilial('T9G')"}, {"T9G_ID","T9F_ID"}, {"T9G_DTAPUR","T9F_DTAPUR"} },T9G->(IndexKey(1)) )

// Tabela T9J - Informa��es de Processos relacionados a Suspens�o da Contribui��o previdenci�ria
oModel:AddGrid("MODEL_T9J","MODEL_T9F",oStruT9J)
oModel:GetModel("MODEL_T9J"):SetOptional(.F.)
oModel:GetModel("MODEL_T9J"):SetUniqueLine({"T9J_IDPROC", "T9J_CODSUS"})  
oModel:SetRelation("MODEL_T9J",{ {"T9J_FILIAL","xFilial('T9J')"}, {"T9J_ID","T9F_ID"}, {"T9J_DTAPUR","T9F_DTAPUR"} },T9J->(IndexKey(1)) )

// Tabela T9H - Receita Ingressos
oStruT9H:SetProperty('T9H_QTDVDO', MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID ,'T298ValIng("T9H_QTDVDO")'))  
oStruT9H:SetProperty('T9H_QTDDEV', MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID ,'T298ValIng("T9H_QTDDEV")'))
oModel:AddGrid("MODEL_T9H","MODEL_T9G",oStruT9H)
oModel:GetModel("MODEL_T9H"):SetOptional(.F.)
oModel:GetModel("MODEL_T9H"):SetUniqueLine({"T9H_CODSEQ"})
oModel:SetRelation("MODEL_T9H",{ {"T9H_FILIAL","xFilial('T9H')"}, {"T9H_ID","T9F_ID"}, {"T9H_DTAPUR","T9F_DTAPUR"}, {"T9H_NUMBOL","T9G_NUMBOL"}, {"T9H_TPCOMP","T9G_TPCOMP"},{"T9H_CATEVE","T9G_CATEVE"} },T9H->(IndexKey(1)) )



// Tabela T9I - Outras Receitas
oModel:AddGrid("MODEL_T9I","MODEL_T9G",oStruT9I)
oModel:GetModel("MODEL_T9I"):SetOptional(.F.)
oModel:GetModel("MODEL_T9I"):SetUniqueLine({"T9I_CODSEQ"})
oModel:SetRelation("MODEL_T9I",{ {"T9I_FILIAL","xFilial('T9I')"}, {"T9I_ID","T9F_ID"}, {"T9I_DTAPUR","T9F_DTAPUR"}, {"T9I_NUMBOL","T9G_NUMBOL"}, {"T9I_TPCOMP","T9G_TPCOMP"}, {"T9I_CATEVE","T9G_CATEVE"} },T9I->(IndexKey(1)) )

oModel:GetModel('MODEL_T9F'):SetPrimaryKey({'T9F_FILIAL', 'T9F_ID', 'T9F_DTAPUR'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author fabio.santana
@since 29/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'TAFA298' )
Local oStruT9F := FWFormStruct( 2, 'T9F' )
Local oStruT9G := FWFormStruct( 2, 'T9G' )
Local oStruT9H := FWFormStruct( 2, 'T9H' )
Local oStruT9I := FWFormStruct( 2, 'T9I' )
Local oStruT9J := FWFormStruct( 2, 'T9J' )

Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T9F', oStruT9F, 'MODEL_T9F' )
oView:EnableTitleView( 'VIEW_T9F', STR0002) //'Receita de Espet�culo Desportivo'

oView:AddGrid("VIEW_T9G",oStruT9G,"MODEL_T9G")
oView:EnableTitleView("VIEW_T9G", STR0003 ) //'Boletim'

oView:AddGrid("VIEW_T9H",oStruT9H,"MODEL_T9H")
oView:EnableTitleView("VIEW_T9H", STR0004 ) //'Receita Ingressos'

oView:AddGrid("VIEW_T9I",oStruT9I,"MODEL_T9I")
oView:EnableTitleView("VIEW_T9I", STR0005 ) //'Outras Receitas'

oView:AddGrid("VIEW_T9J",oStruT9J,"MODEL_T9J")
oView:EnableTitleView("VIEW_T9J", STR0006 )//'Informa��es de processos relacionados a Suspens�o da Contribui��o previdenci�ria'

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
// ----- PAINEL SUPERIOR -----
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",25)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") 

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0002) //'Receita de Espet�culo Desportivo'
oView:CreateHorizontalBox("PAINEL_T9F",100,,,"FOLDER_PRINCIPAL","ABA01") 

// ----- PAINEL INFERIOR -----
oView:CreateHorizontalBox("PAINEL_INFERIOR",75)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")  

//ABAT9G
oView:AddSheet("FOLDER_INFERIOR","ABAT9G",STR0003) //'Boletim'
oView:CreateHorizontalBox("PAINEL_T9G",45,,,"FOLDER_INFERIOR","ABAT9G")
oView:CreateHorizontalBox("PAINEL_INFERIOR_T9G",55,,,"FOLDER_INFERIOR","ABAT9G")

oView:CreateFolder("FOLDER_T9G","PAINEL_INFERIOR_T9G")
oView:AddSheet("FOLDER_T9G","ABA_T9H",STR0004) //'Receita Ingressos'
oView:CreateHorizontalBox("PAINEL_T9H",100,,,"FOLDER_T9G","ABA_T9H")

oView:AddSheet("FOLDER_T9G","ABA_T9I",STR0005) //'Outras receitas'
oView:CreateHorizontalBox("PAINEL_T9I",100,,,"FOLDER_T9G","ABA_T9I")
oModel:GetModel("MODEL_T9I"):SetOptional(.T.)                                        

oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0006) //'Informa��es de processos relacionados a Suspens�o da Contribui��o previdenci�ria'
oView:CreateHorizontalBox("PAINEL_T9J",100,,,"FOLDER_INFERIOR","ABA02")
oModel:GetModel("MODEL_T9J"):SetOptional(.T.)                                        

oStruT9F:RemoveField( "T9F_ID")
oStruT9H:RemoveField( "T9H_CODSEQ")
oStruT9I:RemoveField( "T9I_CODSEQ")
oStruT9F:RemoveField( "T9H_ID")
oStruT9I:RemoveField( "T9I_IDSUSP")
oStruT9J:RemoveField( "T9J_IDSUSP")

oView:SetOwnerView( 'VIEW_T9F', 'PAINEL_T9F' ) 
oView:SetOwnerView( 'VIEW_T9G', 'PAINEL_T9G' ) 
oView:SetOwnerView( 'VIEW_T9H', 'PAINEL_T9H' ) 
oView:SetOwnerView( 'VIEW_T9I', 'PAINEL_T9I' ) 
oView:SetOwnerView( 'VIEW_T9J', 'PAINEL_T9J' ) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local lAltReinf	As Logical
Local nOperation	As Numeric

lAltReinf	:= .F.
nOperation	:= oModel:GetOperation()
	
	If FwFormCommit(oModel)  		
		If  nOperation == MODEL_OPERATION_UPDATE
			TafEndGRV( "T9F","T9F_PROCID", "", T9F->(Recno()))    				
		EndIf							
	EndIf		

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} T298ValIng
Fun��o de valida��o dos campos de ingressos vendidos e devolvidos n�o pode ser maior que o 

@Param  cCampo, caracter, nome do campo 

@Return lret, logico, retorna .t. se valida��o ok
/*/
//-------------------------------------------------------------------
Function T298ValIng(cCampo)
Local lRet as character
Local nQtdIngr as numeric

Default cCampo := ""

lRet := .T.
nQtdIngr := M->&cCampo
If nQtdIngr > FwFldGet("T9H_QTDVDA")
	If cCampo == "T9H_QTDVDO"
		Help( ,,"T9H_QTDVDO",,STR0007, 1, 0 ) //"Quantidade de ingressos vendidos n�o pode ser maior que a quantidade � venda!"
	ElseIf	cCampo == "T9H_QTDDEV"
		Help( ,,"T9H_QTDDEV",,STR0008, 1, 0 ) //"Quantidade de ingressos devolvidos n�o pode ser maior que a quantidade � venda!"
	EndIf
	lRet := .F.
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Fun��o para validar o vlrReceitaotal : Deve corresponder a soma de {vlrTotal} de{receitaIngressos} e de {vlrReceita}
de {outrasReceitas} que estejam vinculados ao mesmo estabelecimento 

@Param  oModel, objeto, modelo

@Return lret, logico, retorna .t. se valida��o ok
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local lRet as character
Local oSubT9G 			as object
Local oSubT9H 			as object
Local oSubT9I 			as object
Local nLinAtual 		as numeric
Local nLinG 			as numeric
Local nI 				as numeric
Local nG 				as numeric
Local nVlrReceitaTotal 	as numeric
Local nOperation 		as numeric

lRet := .T.
nOperation	:= oModel:GetOperation()
	
If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT

	oSubT9G:= oModel:GetModel("MODEL_T9G")
	nLinG := oSubT9G:GetLine()
	nVlrReceitaTotal := 0
	For nG := 1 to oSubT9G:Length()
		oSubT9G:GoLine(nG)
		
		oSubT9H:= oModel:GetModel("MODEL_T9H")
		nLinAtual := oSubT9H:GetLine()
		
		For nI := 1 To oSubT9H:Length()
			oSubT9H:GoLine(nI)
			nVlrReceitaTotal += oSubT9H:GetValue("T9H_VLRTOT")	
		Next nI
		oSubT9H:GoLine(nLinAtual)
		
		
		oSubT9I:= oModel:GetModel("MODEL_T9I")
		nLinAtual := oSubT9I:GetLine()
		For nI := 1 To oSubT9I:Length()
			oSubT9I:GoLine(nI)
			nVlrReceitaTotal += oSubT9I:GetValue("T9I_VALREC")	
		Next nI
		oSubT9I:GoLine(nLinAtual)
	Next nG
	oSubT9G:GoLine(nLinG)

	oSubT9H := nil
	oSubT9I := nil
	oSubT9G := nil
	
	If nVlrReceitaTotal != oModel:GetModel("MODEL_T9F"):GetValue("T9F_VALTOT")
		lRet := .F.
		Help( ,,"T9F_VALTOT",,, 1, 0 ) //"Valor da receita bruta total n�o corresponde ao somat�rio das receitas de ingressos e outras receitas!"
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidT9G
Fun��o para validar se o Tipo de Evento for diferente de internacional, CNPJ visitante obrigatorio, se for internacional, informar ou o nome ou o cnpj 
@Param  oModel, objeto, modelo

@Return lret, logico, retorna .t. se valida��o ok
/*/
//-------------------------------------------------------------------
Static Function ValidT9G(oModel)
Local lRet as character

lRet := .T.
If Empty(FwFldGet("T9G_CNPJVI")) .and. FwFldGet("T9G_CATEVE") != "1"
	lRet := .F.
	Help( ,,"NO_CNPJVI",,STR0010, 1, 0 ) //"Informar o CNPJ do visitante!"
EndIf	
If lRet .and. Empty(FwFldGet("T9G_CNPJVI")) .and. FwFldGet("T9G_CATEVE") == "1" .and. Empty(FwFldGet("T9G_NOMVIS"))
	lRet := .F.
	Help( ,,"NO_NOMVIS",,STR0011, 1, 0 )//"Informe o nome do visitante!"
EndIf
Return lRet