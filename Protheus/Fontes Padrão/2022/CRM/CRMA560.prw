#include "CRMA560.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Protheus.ch'


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA560()

Rotina de Tipos de Negócio 

@param	Nenhum

@return	array contendo as opções disponiveis

@author	  Victor Bitencourt
@since	  05/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------
Function CRMA560(uRotAuto, nOpcAuto, lExecAuto)

Local oMBrowse  := Nil // Browse da lista de scripts executados

Private aRotina := MenuDef()

Default uRotAuto  := Nil
Default nOpcAuto  := Nil
Default lExecAuto := .T.

If uRotAuto == Nil .AND. nOpcAuto == Nil 

	oMBrowse:= FWMBrowse():New()//		Criando Browser e Layer
	oMBrowse:SetAlias("AOK")
	oMBrowse:SetDescription(STR0001) //"Tipo de Negócio"
	oMBrowse:Activate()	  

Else
// faz a execução da rotina automática 
	FWMVCRotAuto(ModelDef(),"AOK",nOpcAuto,{{"AOKMASTER",uRotAuto}},/*lSeek*/,.T.)

  	If lMsErroAuto .AND. !lExecAuto
  		MostraErro()
  		lMsErroAuto := .F. //Setando valor padrão para variavel
  	Endif

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis 

@param	Nenhum

@return	array contendo as opções disponiveis

@author	  Victor Bitencourt
@since	  05/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
// retorna as rotina padrões do cadastro - Incluir,Alterar,Excluir,Visualizar
Return (FWMVCMenu( "CRMA560" ) )


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados 

@param	 Nenhum

@return  oModel - objeto contendo o modelo de dados

@author	  Victor Bitencourt
@since	  05/12/2014
@version  12.1.3
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructAOK  := FWFormStruct(1,"AOK")

oModel := MPFormModel():New("CRMA560",/*bPosValidacao*/,/*bPreValidacao*/, /*{ |oModel| ModelCommit(oModel) }*/,/*bCancel*/)
oModel:SetDescription(STR0002)//"Tipo de Negócio"

oModel:AddFields("AOKMASTER",/*cOwner*/,oStructAOK,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"AOK_FILIAL" ,"AOK_CODIGO"})

oModel:GetModel("AOKMASTER"):SetDescription(STR0003)//"Tipo de Negócio"

return (oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

ViewDef - Visão do model 

@param	 Nenhum

@return  oView - objeto contendo a visão criada

@author	  Victor Bitencourt
@since	  05/12/2014
@version  12.1.3
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	  := FWFormView():New()
Local oModel	  := FwLoadModel("CRMA560")

Local oStructAOK  :=  FWFormStruct(2,"AOK")

//	Associa o View ao Model
oView:SetModel( oModel )//Define que a view vai usar o model
oView:SetDescription(STR0004) //"Tipo de Negócio"

oView:AddField("VIEW_AOK_FIELD", oStructAOK, "AOKMASTER" )

//--------------------------------------
//		Montagem da tela Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 100 )

oView:AddField("VIEW_AOK_FIELD", oStructAOK, "AOKMASTER" )

oView:SetOwnerView( "VIEW_AOK_FIELD", "LINEONE") 

Return (oView)


//----------------------------------------------------------
/*/{Protheus.doc} CRM560VldH()

Função para validar as datas digitadas horarios das atividades

@param	  Nenhum

@return  lRet

@author   Victor Bitencourt
@since    11/02/2015
@version  12.1.4
/*/
//----------------------------------------------------------
Function CRM560VldH()

Local lRet := .T.

Local dInicio     :=  FwFldget("AOK_DTINI")
Local dFinal      :=  FwFldget("AOK_DTFIM")

If !AtVldDiaHr( dInicio, dFinal , "00:00", "00:00")
	lRet := .F.
EndIf

Return lRet




