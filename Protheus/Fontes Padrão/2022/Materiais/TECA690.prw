#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
#Include 'TECA690.ch'


//------------------------------------------------------------------------------
/* {Protheus.doc} TECA690()
       Função da rotina TECA690
@sample      TECA690() 
@since       06/09/2013  
@version     P11.90
/*/
//------------------------------------------------------------------------------
Function TECA690()

Local oBrw := FwMBrowse():New()

At690Unit()  												// Chamada da Static Function At690Unit()
oBrw:SetAlias( 'TCU' )
oBrw:SetMenudef( 'TECA690' )
oBrw:SetDescription ( OEmToAnsi( STR0001 ) )				//Cadastro de Tipos
oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
       Rotina para construção do menu
@sample      Menudef() 
@since       06/09/2013  
@version     P11.90
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := FWMVCMenu('TECA690')							// Cria o menu na chamada do TECA690

Return aMenu

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author alessandro.silva

@since 24/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1	  := FWFormStruct(1,'TCU')

oModel := MPFormModel():New('TECA690',,{|oModel| At690TdOk(oModel) }) 
oModel:addFields('TCU',,oStr1)
oModel:SetPrimaryKey({ 'TCU_FILIAL', 'TCU_COD' })
oModel:getModel('TCU'):SetDescription(STR0002)				//'Tipos de Alocação'
oModel:SetDescription(STR0002)								//'Tipos de Alocação'
oModel:SetVldActivate({|oModel|At690Excl(oModel)})


Return oModel

//------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
	Definição do interface

@author alessandro.silva

@since 24/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1  := FWFormStruct(2, 'TCU')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'TCU' ) 
oView:CreateHorizontalBox( 'TECA690', 100)
oView:SetOwnerView('FORM1','TECA690')

Return oView

//------------------------------------------------------------------------------
/* {Protheus.doc} At690Unit
Definição da Function At690Unit

@author alessandro.silva

@since 24/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Function At690Unit()					

Local nVar		 := .T.
Local aCodigos   := {{'001',STR0004,'1','2'},;				//Efetivo
					{'002',STR0005,'2','1'},;				//Cobertura
					{'003',STR0006,'1','1'},;				//Apoio
					{'004',STR0007,'1','1'},;				//Excedente
					{'005',STR0008,'1','2'},;				//Treinamento
					{'006',STR0009,'2','2'},;				//Curso
					{'007',STR0010,'1','2'}}				//Cortesia

DbselectArea('TCU')
TCU->(Dbsetorder(1))

For nVar:=1 to Len(aCodigos)

	If TCU->(!Dbseek(Xfilial('TCU')+aCodigos[nVar,1]))		// Gravando array na tabela TCU
		RecLock('TCU',.T.)
		TCU->TCU_FILIAL    := xFilial('TCU')
    	TCU->TCU_COD       := aCodigos[nVar][1]				//EX. Posição 1 [001]
    	TCU->TCU_DESC      := aCodigos[nVar][2]				//EX. Posição 2 [Efetivo]   
    	TCU->TCU_EXALOC    := aCodigos[nVar][3]				//EX. Posição 3 [1]          
       	TCU->TCU_EXMANU    := aCodigos[nVar][4]				//EX. Posição 4 [2]  
    	TCU->(MsUnlock())
	EndIf										     		 
	
Next nVar

Return

//------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
	Definição da Function At690Vld()

@author alessandro.silva

@since 24/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function At690Vld()

Local lRet := .T.
Local oModel := FWModelActivate() 

If ( oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.;
	 oModel:GetOperation() == MODEL_OPERATION_INSERT) .And. ;
	 FwFldGet('TCU_COD') < '007'   											   					   // Validação do campo TCU_COD onde nele não poderá ser digitado valor de codigo no intervalo de 001 / 007
		Help(' ',1,'At690NoAltera',,I18N(STR0011 ,{AllTrim(RetTitle('At690NoAltera'))}),1,0)	   // O Codigo digitado é de uso exclusivo do sistema. Use um codigo maior que 007   -  Não Permitido
		lRet:= .F.
Endif                                                                                                                                                                                

Return lRet

//------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
	Definição da Function At690Excl(oModel)

@author alessandro.silva

@since 24/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function At690Excl(oModel)

Local lRet := .T.

If ( oModel:GetOperation() == MODEL_OPERATION_DELETE ) .And. TCU->TCU_COD <= '007'
	Help(' ',1,'At690NoExcl',,I18N(STR0013 ,{AllTrim(RetTitle('At690NoExcl'))}),1,0)				//O Codigo não pode ser excluido, seu uso é exclusivo do sistema.  -  Não Permitido
	lRet := .F.
	
EndIf

Return lRet
//-------------------------------------------------------------------------------
/*/{Protheus.doc} At690TdOk
@description PosValid do modelo
@author Mateus Boiani
@since  27/08/2020
/*/
//-------------------------------------------------------------------------------
Function At690TdOk(oModel)
Local lRet := .T.
Local oMdlTCU := oModel:GetModel("TCU")
If TecBTCUAlC()
	If oMdlTCU:GetValue("TCU_ALOCEF") == '2'
		If oMdlTCU:GetValue("TCU_EXMANU") == '1' .OR. oMdlTCU:GetValue("TCU_EXALOC") == '2'
			lRet := .F.
			Help( "", 1, "At690TdOk", ,;
			STR0020, 1, 0,,,,,,; //"O campo Aloc.Efetivo deve ser utilizado com valor Não apenas em movimentação de alocação."
			{STR0021}) //"Altere o campo Exibe Manut para Não e o campo Exibe Aloc para Sim"
		EndIf
	EndIf
EndIf
Return lRet
