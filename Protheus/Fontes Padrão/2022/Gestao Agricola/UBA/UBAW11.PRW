#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "UBAA120.CH"

Function UBAW11()
Return


/*/{Protheus.doc} ModelDef
//Novo modelo para servico rest de apontamento de paradas
@author carlos.augusto
@since 20/08/2018
@version undefined
@type function
/*/
Static Function ModelDef()
	Local oModel 	 := Nil
	Local oStruNC5   := FWFormStruct( 1, 'NC5' ) 
    
    //Cria o modelo para o rest	
	oModel := MPFormModel():New( 'UBAW11',/*bPre*/,{|oModel| UBAA120Pos(oModel)}/*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:SetDescription( STR0001 ) //"Apontamento de paradas"

	//Campo adicionado por causa das validacoes de modelo do UBAA120
	oStruNC5:AddField(STR0009 /*Status*/, STR0009 /*Status*/, 'NC5_STSLEG', 'BT' , 1 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.)
	
	// Adiciona a estrutura como form
	oModel:AddFields( 'MdFieldNC5', /*cOwner*/, oStruNC5 )

	// Seta a chave
	oModel:SetPrimaryKey( { "NC5_FILIAL" , "NC5_CONJTO" , "NC5_CODIGO" } ) // Chaves primaria
Return oModel
