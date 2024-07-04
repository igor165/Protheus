#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA295.CH' 
#INCLUDE "FWMVCDEF.CH" 

Static aSetKey   := {}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA295
Cadastro de seguradoras.
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA295()
Local oMBrowse := Nil
Private aRotina:= MenuDef()
	oMBrowse:= FwMBrowse():New()
	oMBrowse:SetAlias('DL6')
	oMBrowse:SetDescription(STR0001)
	oMBrowse:Activate()
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel:= Nil
Local oStruCDL6:= FwFormStruct( 1, 'DL6',,)
	oModel:= MpFormModel():New( 'TMSA295', /*bPre*/,/*bPost*/,{|oModel| TMSA295GRV(oModel)}, /*bCancel*/ )
	oModel:SetDescription( STR0001 )
	oModel:AddFields('MdFieldDL6', Nil, oStruCDL6)                                
	oModel:SetPrimaryKey({'DL6_FILIAL','DL6_CODSEG'})
Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FwLoadModel('TMSA295')
Local oStruCDL6:= FwFormStruct( 2, 'DL6' )

	oView:= FwFormView():New()
	oView:SetModel( oModel )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:AddField('VwFieldDL6',oStruCDL6, 'MdFieldDL6')
	oStruCDL6:RemoveField('DL6_FILIAL')    
	oStruCDL6:RemoveField('DL6_TIPDOC')
	oView:SetOwnerView('VwFieldDL6', 'TELA')
	oView:SetViewAction( "BUTTONCANCEL", {|| TMSA295CAN() } )	
	oView:SetCloseOnOk({|| .T. })
	oView:AddUserButton( STR0002, "", {||TMSA295FDC()})
Return( oView)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()
Private aRotina	:= {	{ STR0003 ,'AxPesqui'  ,0,1,0,.F.},;//'Pesquisar'
						{ STR0004 ,'VIEWDEF.TMSA295' ,0 ,2 ,0 ,NIL},;//'Visualizar'
						{ STR0005 ,'VIEWDEF.TMSA295' ,0 ,3 ,0 ,NIL},;	//'Incluir'
						{ STR0006 ,'VIEWDEF.TMSA295' ,0 ,4 ,0 ,NIL},;	//'Alterar'
						{ STR0007 ,'TMSA295DEL'		 ,0 ,5 ,0 ,NIL} }	//'Excluir' 
Return( aRotina )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA295GRV
Bloco Commit do model 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA295GRV(oModel)

	FwFormCommit(oModel)
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT //Incluir
		If __lSX8
			ConfirmSX8()
		EndIf	
	ENDIF 
	
RETURN .T.
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA295DEL
Excluir registro 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 12/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA295DEL(cAlias, nReg, nOpc)
Private cCadastro := STR0001 //"Cadastro de Transportadora"

If TmsVLDSIX("DL5","3") //Suavização da Release 12.1.20
	DbSelectArea("DL5")
	DL5->(DbSetOrder(3))
	If DbSeek(xFilial("DL5")+DL6->DL6_CODSEG)
		Help(' ',1, 'TMSA29501')  //"Este registro já possui movimentação, para prosseguir com a exclusão, estorne os documentos de transporte já realizados com esta seguradora."	
		Return .F.
	EndIf
EndIf
	
AxDeleta(cAlias,nReg,nOpc,,,,) 
	
Return .T.
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA295GRV
Botao cancelar  
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA295CAN()
	If __lSX8 .And. lCancel
		RollBackSX8()
	EndIf	
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA295GRV
Botao cancelar  
@type function
@author Marcelo Radulski Nunes.
@version 12.1.17
@since 09/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA295FDC()

Local aItem      := TMSValField("DOCTMS",.F.,,.F.,.T.)
Local aDocs      := {}
Local aRet       := {}
Local aMem       := {}
Local lInv       := .F.
Local lAll       := .T.
Local cSepDoc    := "|" + StrTran(M->&('DL6_TIPDOC'), " ", "")
Local oDlg
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
	aEval(aItem, {|z,w| Aadd(aDocs, {4, "", "*" $ cSepDoc .Or. "|" + aItem[w,1] $ cSepDoc, aItem[w,1] + "-" + aItem[w,2], 80,,.F.}), Aadd(aMem, MemVarBlock("MV_PAR" + StrZero(w, 2)))})

	If ParamBox( aDocs, STR0008, @aRet, , , .T., , , , , .F.)  
		M->DL6_TIPDOC := ""
		aEval(aRet, {|z,w| If(z, M->DL6_TIPDOC += If(Len(M->DL6_TIPDOC) > 0, "|","") + aItem[w,1],lAll := .F.)})
		M->DL6_TIPDOC := Pad(If(lAll, "*", M->DL6_TIPDOC),Len(DL6->DL6_TIPDOC))
		If oModel <> Nil .And. RTrim(oModel:cID) == "TMSA295"
			If oModel:LoadValue("MdFieldDL6" , 'DL6_TIPDOC' , M->DL6_TIPDOC)
				oView:SetModified(.T.)
			Endif
		Endif
	Endif
	If	oView <> Nil
		oView:Refresh()
	Endif
Return
