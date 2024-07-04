#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA030.CH" 

Static _lAmbOffLn 	:= NIL //Loja Offline ?

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATA030A

Cadastro de Complementos de Cliente.

@sample	MATA030A()

@param		

@return	

@author	Renato da Cunha
@since		27/05/2014
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function MATA030A(cCodigo,nOper)

Local aArea    := GetArea()
Local aAreaAI0 := AI0->(GetArea())
Local nOperMod := 0
Local lExist   := .F.
Local lProc    := .T.     
Local oModel   := Nil
Local cMens1   := STR0157          	//"Complemento Não Registrado!"
Local cMens2   := STR0158           //"Operação Inválida!"
Default cCodigo := ""
Default nOper   := 0

AI0->(DbSetOrder(1))

If !Empty(cCodigo) .AND. nOper > 0
      
      lExist := AI0->(DbSeek(xFilial("AI0")+cCodigo))
      
      Do Case

            Case lExist .AND. nOper == 4
                  nOperMod  := MODEL_OPERATION_UPDATE
                        
                              
            Case lExist .AND. nOper <> 4 
                  nOperMod  := MODEL_OPERATION_VIEW
                  

            Case !lExist .AND. nOper <> 4
                  Aviso(STR0159,cMens1,{"OK"},1) // "Atenção"
                  lProc := .F.

            Case !lExist .AND. nOper == 4 
                  nOperMod  := MODEL_OPERATION_INSERT
                  
            OtherWise
                 Aviso(STR0159,cMens2,{"OK"},1) //"Atenção"
                  lProc := .F.

      EndCase

      If lProc
            oModel := FwLoadModel("MATA030A")
            oModel:SetOperation(nOperMod)
            oModel:Activate()

            FWExecView( STR0160, "VIEWDEF.MATA030A", nOperMod, /*oDlg*/, {|| .T. } ,, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )//"Complementos"
      EndIf 

EndIf

RestArea(aAreaAI0)
RestArea(aArea)

Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} Modeldef

@sample	ViewDef()

@param		Nenhum

@return	Cadastro de Complemento de Cliente

@author	Renato da Cunha
@since		01/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function Modeldef()
	
Local oModel		:= NIL
Local oStructAI0	:= FWFormStruct( 1, 'AI0', , ) 
Local bInit	  	:= {|oModel| Ata030Inip(oModel)} 
Local bVldPos     := {|oModel| IIf(FindFunction("FinRecPix"), FinRecPix(oModel, .F.), .T.) .AND.;
      IIf(FindFunction("F713VldEmB"), F713VldEmB(oModel:GetModel('AI0MASTER')), .T.)}

oModel := MPFormModel():New( 'MATA030A', /*bPreValidacao*/, bVldPos,  {|oModel| Ata030Cmmt(oModel   )}, /*bCancel*/  )

oModel:AddFields( 'AI0MASTER',, oStructAI0 )

oModel:SetDescription(STR0161)//"Complemento do Cliente"
oModel:GetModel('AI0MASTER'):SetDescription(STR0160) //"Complemento"
oModel:SetActivate(bInit)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef


@sample	ViewDef()

@param		oView

@return	Cadastro de Complemento de Cliente

@author	Renato da Cunha
@since		01/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= NIL
Local oStructAI0	:= FWFormStruct( 2, 'AI0' )
Local oModel 		:= FWLoadModel( 'MATA030A' )

oStructAI0:RemoveField("AI0_FILIAL")
oStructAI0:RemoveField("AI0_CODCLI")
oStructAI0:RemoveField("AI0_LOJA")

oView := FWFormView():New()
oView:SetModel( oModel )


oView:AddField("VIEW_AI0",oStructAI0,"AI0MASTER"	)
	  
oView:EnableTitleView("VIEW_AI0",STR0161)//"Complemento do Cliente"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ata030Inip


@sample	Ata030Inip(oModel)

@param		nOper

@return	Cadastro de Complemento de Cliente - Defini operação atual da View

@author	Renato da Cunha
@since		01/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------

Static Function Ata030Inip(oModel)

Local nOper := oModel:GetOperation()


If nOper == MODEL_OPERATION_INSERT
	oModel:GetModel("AI0MASTER"):SetValue("AI0_CODCLI",SA1->A1_COD)
	oModel:GetModel("AI0MASTER"):SetValue("AI0_LOJA",SA1->A1_LOJA)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ata030Cmmt


@sample	Ata030Cmmt(oModel)

@param		nOper

@return	 Gera as informações para integração do LojaOffLine

@author	fabiana.silva
@since		16/06/2017
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function Ata030Cmmt(oModel)
Local oProcessOff := NIl //Dados do processo offline
Local nOper       := oModel:GetOperation()

If _lAmbOffLn == NIL
	_lAmbOffLn := SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline
EndIf

FWFormCommit(oModel)

If _lAmbOffLn

   //Instancia o objeto LJCProcessoOffLine
     oProcessOff := LJCProcessoOffLine():New("007")
     
     //Determina o tipo de operacao
      If nOper == MODEL_OPERATION_INSERT
         cTipo := "INSERT"
     ElseIf nOper == MODEL_OPERATION_UPDATE 
         cTipo := "UPDATE"
     ElseIf nOper == MODEL_OPERATION_DELETE
         cTipo := "DELETE"       
         //Considera os registros deletados
         SET DELETED OFF
     EndIf
     
     If !Empty(cTipo)
         //Insere os dados do processo (registro da tabela)
         oProcessOff:Inserir("AI0", xFilial("AI0") + oModel:GetModel("AI0MASTER"):GetValue("AI0_CODCLI") + oModel:GetModel("AI0MASTER"):GetValue("AI0_LOJA"), 1, cTipo)
         
         //Processa os dados
         oProcessOff:Processar()
     EndIf
     
     //Desconsidera os registros deletados
     If nOper == MODEL_OPERATION_DELETE 
     	SET DELETED ON
     EndIf

EndIf

Return .T.
