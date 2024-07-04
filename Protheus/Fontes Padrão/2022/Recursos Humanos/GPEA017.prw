#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "GPEA1010.CH"




/*/{Protheus.doc} gpea017
Cadastro de Locais de convocação Foi solicitado a criação deste novo cadastro de locais no sistema, independente dos demais. 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function GPEA017() 
Local oBrowse 	:= Nil
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SV6")
oBrowse:SetDescription(oEmToAnsi(STR0357))
oBrowse:Activate()
return


/*/{Protheus.doc} MenuDef
Opções de manutenção da respectiva tela 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"        OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GPEA017" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GPEA017" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GPEA017" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GPEA017" OPERATION 5 ACCESS 0  //"Excluir"

Return ( aRotina )


/*/{Protheus.doc} ModelDef
Model da rotina GPEA017 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function ModelDef()

Local oModel	 := Nil
Local oStruSV6	 := FWFormStruct(1,"SV6")
Local cSV6CmpFil := '|V6_COD|V6_DESC|V6_LOGRT|V6_LOGRD|V6_LOGDS|V6_LOGNU|V6_LOGC|V6_BAIRRO|V6_CEP|V6_CODMU|V6_DESMU|V6_ESTAD' 

oStruSV6 := FwFormStruct( 1, 'SV6', {|x| AllTrim( x )  $ cSV6CmpFil } )

oModel := MPFormModel():New("GPEA017",/*PreValidacao*/,{|oModel|FazValid(oModel)} ,   {|oModel|FazCommit(oModel)} )
oModel:AddFields("Md1FieldSV6", /*cOwner*/, oStruSV6, , , )

oModel:GetModel('Md1FieldSV6'):SetPrimaryKey({"V6_FILIAL+V6_COD"   })
oModel:GetModel( 'Md1FieldSV6' ):SetDescription('Locais')

oModel:SetPrimaryKey ( {"V6_FILIAL","V6_COD"})
Return oModel


/*/{Protheus.doc} ViewDef
View da rotina GPEA017 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function ViewDef()
Local oModel	:= FWLoadModel("GPEA017")
Local oView	    := FWFormView():New()

Local oStruSV6	 := FWFormStruct(2,"SV6")
Local cSV6CmpFil := '|V6_COD|V6_DESC|V6_LOGRT|V6_LOGRD|V6_LOGDS|V6_LOGNU|V6_LOGC|V6_BAIRRO|V6_CEP|V6_CODMU|V6_DESMU|V6_ESTAD'

oStruSV6 := FwFormStruct( 2, 'SV6', {|x| AllTrim( x )  $ cSV6CmpFil } )

oView:SetModel(oModel)
oView:AddField('Vw1FieldSV6', oStruSV6 , 'Md1FieldSV6') 

oView:CreateHorizontalBox("SUPERIOR",100)//cabecalho com duas guias

oView:SetOwnerView('Vw1FieldSV6'   ,"SUPERIOR" )

oView:SetDescription(oEmToAnsi(STR0358))


Return oView  



/*/{Protheus.doc} FazValid
Validação da Tela
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function FazValid (oModel)
Local lRet      := .T.
Local cAliasTab := GetNextAlias()
Local oSV6Model	:= oModel:GetModel("Md1FieldSV6")
Local nOpc := oSV6Model:GEToPERATION()

		
If  nOpc == 5
	BeginSql Alias cAliasTab
			SELECT   *  FROM  %table:SV7% //tabela SV6 é compartilhada e por destar sendo usada em qualquer outra empresa-filial, por isto não filtramos filial   
			 WHERE  V7_LOCAL = %Exp:( oSV6Model:GetValue("V6_COD") )%
			   AND  %NotDel%
	EndSql
				
	If (cAliasTab)->(!Eof())
		Help( ,,"GPEA017",,oEmToAnsi(STR0359) + "(" + Alltrim( (cAliasTab)->(V7_FILIAL) ) + "\" + Alltrim( (cAliasTab)->(V7_MAT) ) + ")", 1, 0 )
		lRet := .F.
	EndIf
			
	(cAliasTab)->(DbCloseArea())
EndIf

return lRet

/*/{Protheus.doc} FazCommit
Finaliza operação de inclusão de dados no Banco  
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function FazCommit (oModel)
Local nOpc	    := 0    
Local oSV6Model	:= oModel:GetModel("Md1FieldSV6")
Local lRet      := .T.
Local lJob		:= .F.

nOpc := oSV6Model:GETOPERATION()

If nOpc == 3 
	reclock('SV6',.T.) 
	
	SV6->V6_FILIAL := FWxfilial('SV6')
	SV6->V6_COD    := oSV6Model:GetValue("V6_COD")
	SV6->V6_DESC   := oSV6Model:GetValue("V6_DESC")
	SV6->V6_LOGRT  := oSV6Model:GetValue("V6_LOGRT")
	SV6->V6_LOGDS  := oSV6Model:GetValue("V6_LOGDS")
	SV6->V6_LOGNU  := oSV6Model:GetValue("V6_LOGNU")
	SV6->V6_LOGC   := oSV6Model:GetValue("V6_LOGC")
	SV6->V6_BAIRRO := oSV6Model:GetValue("V6_BAIRRO")
	SV6->V6_CEP    := oSV6Model:GetValue("V6_CEP")
	SV6->V6_CODMU  := oSV6Model:GetValue("V6_CODMU")
	SV6->V6_ESTAD  := oSV6Model:GetValue("V6_ESTAD")
	
	msUnLock()
	ConfirmSX8()
Else
	dbselectarea('SV6')
	dbsetorder(1)
    SV6->( DbSeek( Fwxfilial('SV6')+oSV6Model:GetValue("V6_COD") ) )
    
    If SV6->(!Eof())
    
    	If nOpc == 4   //alteracao
			If (oSV6Model:GetValue("V6_LOGRT")	<> SV6->V6_LOGRT	.Or.;
				oSV6Model:GetValue("V6_LOGDS")	<> SV6->V6_LOGDS	.Or.;
				oSV6Model:GetValue("V6_LOGNU")	<> SV6->V6_LOGNU	.Or.;
				oSV6Model:GetValue("V6_LOGC")	<> SV6->V6_LOGC		.Or.;
				oSV6Model:GetValue("V6_BAIRRO")	<> SV6->V6_BAIRRO	.Or.;
				oSV6Model:GetValue("V6_CEP")	<> SV6->V6_CEP		.Or.;	
				oSV6Model:GetValue("V6_CODMU")	<> SV6->V6_CODMU	.Or.; 
				oSV6Model:GetValue("V6_ESTAD")	<> SV6->V6_ESTAD		)
				lJob := .T.
			Endif

		    reclock('SV6',.F.)
			SV6->V6_DESC   := oSV6Model:GetValue("V6_DESC")
			SV6->V6_LOGRT  := oSV6Model:GetValue("V6_LOGRT")
			SV6->V6_LOGDS  := oSV6Model:GetValue("V6_LOGDS")
			SV6->V6_LOGNU  := oSV6Model:GetValue("V6_LOGNU")
			SV6->V6_LOGC   := oSV6Model:GetValue("V6_LOGC")
			SV6->V6_BAIRRO := oSV6Model:GetValue("V6_BAIRRO")
			SV6->V6_CEP    := oSV6Model:GetValue("V6_CEP")
			SV6->V6_CODMU  := oSV6Model:GetValue("V6_CODMU")
			SV6->V6_ESTAD  := oSV6Model:GetValue("V6_ESTAD")
			msUnLock()
		EndIf
		
		If nOpc == 5  //exclusao
		    reclock('SV6',.F.)
			SV6->(DbDelete())
			msUnLock()
		EndIf
    EndIf

	If lJob
		fGravaRJB()
	Endif
    
EndIf

return lRet


/*/{Protheus.doc} fGravaRJB()
Função para definição de qual consulta padrão ativar para o campo RV_INCIRF
@type      	Function
@author   	Claudinei Soares
@since		28/05/2019
@version	1.0
@return		lRetWhen,	logic,	Retorno da função
/*/

Static Function fGravaRJB()

If ChkFile("RJB") .and. ChkFile("RJC") // se existem as tabelas RJB e RJC, continua com o processamento

	RJB->(DbSetOrder(2)) //RJB_FILIAL+RJB_CODIGO+RJB_FCHAVE+RJB_CHAVE
	RecLock("RJB", .T.)
		RJB->RJB_FILIAL 	:= Fwxfilial('SV6')
		RJB->RJB_CODIGO 	:= GetSx8Num("SV6", "RJB_CODIGO")
		RJB->RJB_EVENT  	:= "S2206"
		RJB->RJB_TIPO		:= "2" //Atualização Locais de Convocação
		RJB->RJB_STATUS		:= "0" // Pendente
		RJB->RJB_FCHAVE 	:= Fwxfilial('SV6')
		RJB->RJB_CHAVE		:= SV6->V6_COD
		RJB->RJB_DTINC		:= dDataBase

	MsUnLock()
	ConfirmSx8()
Endif

Return


