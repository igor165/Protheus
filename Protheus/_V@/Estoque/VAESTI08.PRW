#include "protheus.ch" 
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Apontamento de Feno" 

// Igor Oliveira 08-2024
User Function VAESTI08()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
	Private cTpMov      := ""
    Private aLotes      := {}

    SetFunName("VAESTI08")

    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZVG" )   
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL  
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI08' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'U_I08TELA1' 			    OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI08' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI08' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oStZVG    := FWFormStruct(1, 'ZVG')
	Local oStZVH    := FWFormStruct(1, 'ZVH')
	Local oStZVJ    := FWFormStruct(1, 'ZVJ')
	Local bVldPos   := {|| zVldZVGTab()}
	Local bVldCom   := {|| zCommit()}
    Local aZVHRel   := {}
    Local aZVJRel   := {}
    Local aGatilhos := {}
    Local nI

    aAdd(aGatilhos, FWStruTriggger( "ZVH_PROD"  , "ZVH_DESC"   ,"SB1->B1_DESC"  					,.T.,"SB1"  ,1,"FwxFilial('SB1')+M->ZVH_PROD" 				,NIL,"01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVH_PROD"  , "ZVH_LOCAL"  ,"SB1->B1_LOCPAD"					,.F.,""     ,,""                              				,NIL,"02"))
    aAdd(aGatilhos, FWStruTriggger( "ZVH_PROD"  , "ZVH_QUANT"  ,"0"									,.F.,""     ,,""                              				,NIL,"03"))
    aAdd(aGatilhos, FWStruTriggger( "ZVH_LOCAL" , "ZVH_B2QATU" ,"SB2->B2_QATU"						,.T.,"SB2"  ,1,"FwxFilial('SB2')+M->ZVH_PROD+M->ZVH_LOCAL"  ,NIL,"01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVH_QUANT ", "ZVH_QTAPOS" ,"M->ZVH_B2QATU - M->ZVH_QUANT"		,.F.,""     ,,""                              				,NIL,"01"))

	For nI := 1 To Len(aGatilhos)
        oStZVH:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
						    aGatilhos[nI][02],; //Campo Destino
						    aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
						    aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next 
	
	aGatilhos := {}
    aAdd(aGatilhos, FWStruTriggger( "ZVJ_PROD ", "ZVJ_DESC" ,"SB1->B1_DESC"		,.t.,"SB1",1,"FwxFilial('SB1')+M->ZVJ_PROD"                              				,NIL,"01"))

	For nI := 1 To Len(aGatilhos)
        oStZVJ:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
						    aGatilhos[nI][02],; //Campo Destino
						    aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
						    aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next 

    oStZVH:SetProperty( 'ZVH_QTAPOS', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(INCLUI,0,ZVH->ZVH_B2QATU - ZVH->ZVH_QUANT)") )
    oStZVH:SetProperty( 'ZVH_DESC'	, MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(INCLUI,'',Posicione('SB1',1,FwXfilial('SB1')+ZVH->ZVH_PROD,'B1_DESC'))") )

    oStZVH:SetProperty( 'ZVH_LOCAL', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_I08VLDP()") )
    oStZVH:SetProperty( 'ZVH_QUANT', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_I08VHDQ()") )
    
    oStZVJ:SetProperty( 'ZVJ_DESC' , MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(INCLUI,'',Posicione('SB1',1,FwXfilial('SB1')+ZVJ->ZVJ_PROD,'B1_DESC'))") )
	oStZVJ:SetProperty( 'ZVJ_QTDE' , MODEL_FIELD_WHEN , FwBuildFeature( STRUCT_FEATURE_WHEN , "FwFldGet('ZVG_TIPO')=='I'") )
	oStZVJ:SetProperty( 'ZVJ_QTDE' , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_I08VJDQ()") )

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ESTI08M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/,bVldCom/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZVGMASTER",/*cOwner*/ ,oStZVG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZVHDETAIL'  ,'ZVGMASTER',oStZVH, /* linePre */, /* LInePos */, { |oGrid, nLine,cAction, cField| I08HPRE(oGrid, nLine, cAction, cField) })
	oModel:AddGrid('ZVJDETAIL'  ,'ZVHDETAIL',oStZVJ, /* { |oGridM, nLine,cAction, cField| I03GPRE(oGridM, nLine, cAction, cField) } */)

	aAdd(aZVHRel, {'ZVH_FILIAL', 'ZVG_FILIAL'} )
	aAdd(aZVHRel, {'ZVH_CODIGO', 'ZVG_CODIGO'} )
    oModel:SetRelation('ZVHDETAIL', aZVHRel, ZVH->(IndexKey(1)))

	aAdd(aZVJRel, {'ZVJ_FILIAL', 'ZVH_FILIAL'} )
	aAdd(aZVJRel, {'ZVJ_CODIGO', 'ZVH_CODIGO'} )
	aAdd(aZVJRel, {'ZVJ_ITEMVH', 'ZVH_ITEM'} )
    oModel:SetRelation('ZVJDETAIL', aZVJRel, ZVJ->(IndexKey(3)))

	oModel:SetPrimaryKey({"ZVG_FILIAL","ZVG_CODIGO"})

    //oModel:GetModel("ZVGMASTER"):SetFldNoCopy({'ZVG_FILIAL', 'ZVG_CODIGO'})
    
	//Setando outras informações do Modelo de Dados
	oModel:GetModel("ZVGMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZVHDETAIL"):SetDescription("Produtos: "+cTitulo)
	oModel:GetModel("ZVJDETAIL"):SetDescription("Lotes: "+cTitulo)

    oModel:AddCalc('TOTAIS', 'ZVHDETAIL', 'ZVJDETAIL', 'ZVJ_QTDE', 'XX_TOTAL', 'SUM', , , "Total do produto:" )

Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VAESTI08")
	Local oStZVG    := FWFormStruct(2, 'ZVG')
	Local oStZVH    := FWFormStruct(2, 'ZVH')
	Local oStZVJ    := FWFormStruct(2, 'ZVJ')
    Local oStTot 	:= FWCalcStruct(oModel:GetModel('TOTAIS'))
	Local oView     := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZVG" , oStZVG  , "ZVGMASTER")
	oView:AddGrid("VIEW_ZVH"  , oStZVH  , "ZVHDETAIL")
	oView:AddGrid("VIEW_ZVJ"  , oStZVJ  , "ZVJDETAIL")
	oView:AddField("VIEW_TOT" , oStTot  , "TOTAIS")
	//Habilitando título
	
    oView:CreateHorizontalBox('BOX_ZVG' , 15)
    oView:CreateHorizontalBox('BOX_ZVH' , 35)
    oView:CreateHorizontalBox('BOX_ZVJ' , 35)
    oView:CreateHorizontalBox('BOX_TOT' , 15)
	
    oView:SetOwnerView('VIEW_ZVG','BOX_ZVG')
	oView:SetOwnerView('VIEW_ZVH','BOX_ZVH')
	oView:SetOwnerView('VIEW_ZVJ','BOX_ZVJ')
	oView:SetOwnerView('VIEW_TOT','BOX_TOT')
    
    oView:EnableTitleView('VIEW_ZVG', "Cabeçalho")
    oView:EnableTitleView('VIEW_ZVH', "Produtos")
    oView:EnableTitleView('VIEW_ZVJ', "Lotes")
    oView:EnableTitleView('VIEW_TOT', "Totais")

	oView:AddIncrementField( 'VIEW_ZVH', 'ZVH_ITEM' )
	oView:AddIncrementField( 'VIEW_ZVJ', 'ZVJ_ITEM' )

	oView:AddUserButton( 'Adicionar Lotes','', {|oView| aLotes := MrkLotes(.T.)} )

    //Tratativa padrão para fechar a tela

	oView:SetCloseOnOk( { |oView| .T. } )
	//O formulário da interface será colocado dentro do container
Return oView
User Function ESTI08M()
	Local aParam 		:= PARAMIXB
	Local lRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oMdlZVG 	 	:= nil
	Local oMdlZVH 	 	:= nil
	Local oMdlZVJ 	 	:= nil
	Local oStZVG		:= nil
	Local nOper      	:= 0
	Local nI

	If aParam <> NIL
		oModel 	 := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 
		
		if cIdPonto == "MODELVLDACTIVE"
			nOper := oModel:nOperation

			If nOper == 3 //.or. nOper == 4
				oStZVG := oModel:GetModel( 'ZVGMASTER' ):GetStruct()

				oStZVG:SetProperty( 'ZVG_TIPO', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+IIF(valtype(cTpMov)=='C',SubStr(cTpMov,1,1),"R")+"'" ) )
			endif
		elseif Alltrim(cIdPonto) == 'FORMPRE' .AND. cIdModel == 'ZVHDETAIL' .AND. cIdIXB5 == 'ISENABLE'
			oModel 	  := FwModelActivate()
			oMdlZVG   := oModel:GetModel("ZVGMASTER")
			oMdlZVH   := oModel:GetModel("ZVHDETAIL")
			
			if oModel:GetOperation() == 4
				if oMdlZVG:GetValue("ZVG_STATUS") == 'M'
					oMdlZVH:SetNoInsertLine(.T.)
					oMdlZVH:SetNoDeleteLine(.T.)
				endif
			endif
		elseif Alltrim(cIdPonto) == 'FORMPRE' .AND. cIdModel == 'ZVJDETAIL' .AND. cIdIXB5 == 'ISENABLE'
			oModel 	  := FwModelActivate()
			oMdlZVH   := oModel:GetModel("ZVHDETAIL")
			oMdlZVJ   := oModel:GetModel("ZVJDETAIL")
			
			if oModel:nOperation == 4

				if Len(aLotes) == 0
					oMdlZVH:GoLine(1)
					For nI := 1 To oMdlZVJ:GetQtdLine()
						oMdlZVJ:GoLine(nI)
							aAdd(aLotes, {;
								{"ZVJ_LOTE"     , oMdlZVJ:GetValue("ZVJ_LOTE")},;
								{"ZVJ_CURRAL"   , oMdlZVJ:GetValue("ZVJ_CURRAL")},;
								{"ZVJ_SALDO"    , oMdlZVJ:GetValue("ZVJ_SALDO")},;
								{"ZVJ_B8LOC"    , oMdlZVJ:GetValue("ZVJ_B8LOC")};
							})
					Next nI
				endif 		
			endif 		
		endif 		
	endif 		
Return lRet 
Static Function zCommit()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
    Local oModel    	:= FWModelActive()
    Local oMdlZVG   	:= oModel:GetModel("ZVGMASTER")
    Local oMdlZVH   	:= oModel:GetModel("ZVHDETAIL")
    Local oMdlZVJ   	:= oModel:GetModel("ZVJDETAIL")
	Local nOpc       	:= oModel:GetOperation()
	Local nI := nX      := 0
	Local lRecLock   	:= .T.

	DbSelectArea('ZVG') //ZVG_FILIAL + ZVG_CODIGO=
	ZVG->(DbSetOrder(1))

	DbSelectArea('ZVH')
	ZVH->(DbSetOrder(2))//ZVH_FILIAL + ZVH_CODIGO + ZVH_ITEM
	
	DbSelectArea('ZVJ')
	ZVJ->(DbSetOrder(2))//ZVJ_FILIAL + ZVJ_CODIGO + ZVJ_ITEM
	
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		RecLock('ZVG', lRecLock := !ZVG->(DbSeek( FwXFilial("ZVG") + oMdlZVG:GetValue('ZVG_CODIGO'))))
			ZVG->ZVG_FILIAL	:= FwXFilial("ZVG")
			ZVG->ZVG_CODIGO := oMdlZVG:GetValue('ZVG_CODIGO')
			ZVG->ZVG_DATA   := oMdlZVG:GetValue('ZVG_DATA')
			ZVG->ZVG_USER   := oMdlZVG:GetValue('ZVG_USER')
			ZVG->ZVG_TIPO   := oMdlZVG:GetValue('ZVG_TIPO')
			ZVG->ZVG_STATUS := oMdlZVG:GetValue('ZVG_STATUS')
		ZVG->(MsUnLock())

		For nI := 1 To oMdlZVH:GetQtdLine()
			oMdlZVH:GoLine(nI)
			If !oMdlZVH:isDeleted()
				RecLock('ZVH', lRecLock := !ZVH->(DbSeek( FwXFilial("ZVH") +;
											oMdlZVH:GetValue('ZVH_CODIGO') +;
											oMdlZVH:GetValue('ZVH_ITEM'))))

					ZVH->ZVH_FILIAL := FwXFilial("ZVH")
					ZVH->ZVH_CODIGO := oMdlZVH:GetValue('ZVH_CODIGO')
					ZVH->ZVH_ITEM   := oMdlZVH:GetValue('ZVH_ITEM')
					ZVH->ZVH_PROD   := oMdlZVH:GetValue('ZVH_PROD')
					ZVH->ZVH_LOCAL  := oMdlZVH:GetValue('ZVH_LOCAL')
					ZVH->ZVH_B2QATU := oMdlZVH:GetValue('ZVH_B2QATU')
					ZVH->ZVH_QUANT  := oMdlZVH:GetValue('ZVH_QUANT')

				ZVH->(MsUnlock())

				For nX := 1 to oMdlZVJ:GetQtdLine()
					oMdlZVJ:GoLine(nX)
						If !oMdlZVJ:isDeleted()
							RecLock('ZVJ', lRecLock := !ZVJ->(DbSeek( FwXFilial("ZVJ") +;
											oMdlZVJ:GetValue('ZVJ_CODIGO') +;
											oMdlZVJ:GetValue('ZVJ_ITEM'))))

								ZVJ->ZVJ_FILIAL := FwXFilial("ZVJ")
								ZVJ->ZVJ_CODIGO := oMdlZVJ:GetValue('ZVJ_CODIGO')
								ZVJ->ZVJ_ITEM   := oMdlZVJ:GetValue('ZVJ_ITEM')
								ZVJ->ZVJ_ITEMVH := oMdlZVJ:GetValue('ZVJ_ITEMVH')
								ZVJ->ZVJ_LOTE   := oMdlZVJ:GetValue('ZVJ_LOTE')
								ZVJ->ZVJ_CURRAL := oMdlZVJ:GetValue('ZVJ_CURRAL')
								ZVJ->ZVJ_B8LOC  := oMdlZVJ:GetValue('ZVJ_B8LOC')
								ZVJ->ZVJ_SALDO  := oMdlZVJ:GetValue('ZVJ_SALDO')
								ZVJ->ZVJ_PROD   := oMdlZVJ:GetValue('ZVJ_PROD')
								ZVJ->ZVJ_B1LOC  := oMdlZVJ:GetValue('ZVJ_B1LOC')
								ZVJ->ZVJ_QTDE   := oMdlZVJ:GetValue('ZVJ_QTDE')

							ZVJ->(MsUnlock())
						Else		
							If ZVJ->(DbSeek( FwXFilial("ZVJ") +;
									oMdlZVJ:GetValue('ZVJ_CODIGO') +;
									oMdlZVJ:GetValue('ZVJ_ITEM')))

								RecLock('ZVJ', .F.)
									ZVJ->(DbDelete())
								ZVJ->(MsUnlock())
							EndIf
						EndIf
				Next nX 
			Else		
				If ZVH->(DbSeek( FwXFilial("ZVH") +;
						oMdlZVH:GetValue('ZVH_CODIGO') +;
						oMdlZVH:GetValue('ZVH_ITEM')))

					RecLock('ZVH', .F.)
						ZVH->(DbDelete())
					ZVH->(MsUnlock())
					
					For nX := 1 to MdlZVJ:GetQtdLine()
						oMdlZVJ:GoLine(nI)
						If ZVJ->(DbSeek( FwXFilial("ZVJ") +;
									oMdlZVJ:GetValue('ZVJ_CODIGO') +;
									oMdlZVJ:GetValue('ZVJ_ITEM')))

								RecLock('ZVJ', .F.)
									ZVJ->(DbDelete())
								ZVJ->(MsUnlock())
							EndIf 
					Next nX 
				EndIf 
			EndIf
		Next nI

	ElseIf nOpc == MODEL_OPERATION_DELETE
	
		If ZVG->(DbSeek( FwXFilial("ZVG") + oMdlZVG:GetValue('ZVG_CODIGO')))
			RecLock('ZVG', .F.)
				ZVG->(DbDelete())
			ZVG->(MsUnlock())
		EndIf

		For nI := 1 To oMdlZVH:GetQtdLine()
			oMdlZVH:GoLine(nI)

			If ZVH->(DbSeek( FwXFilial("ZVH") +oMdlZVH:GetValue('ZVH_CODIGO') + oMdlZVH:GetValue('ZVH_ITEM')))

				RecLock('ZVH', .F.)
					ZVH->(DbDelete())
				ZVH->(MsUnlock())

				For nX := 1 to oMdlZVJ:GetQtdLine()
					oMdlZVJ:GoLine(nI)
					If ZVJ->(DbSeek( FwXFilial("ZVJ") +oMdlZVJ:GetValue('ZVJ_CODIGO') +oMdlZVJ:GetValue('ZVJ_ITEM')))

						RecLock('ZVJ', .F.)
							ZVJ->(DbDelete())
						ZVJ->(MsUnlock())
					EndIf
				next nX 
			EndIf
		Next nI
	EndIf

	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet
Static Function zVldZVGTab()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oMdlZVG   := oModel:GetModel("ZVGMASTER")
    Local oMdlZVH   := oModel:GetModel("ZVHDETAIL")
    Local oMdlZVJ   := oModel:GetModel("ZVJDETAIL")
	Local cCodigo 	:= oMdlZVG:GetValue("ZVG_CODIGO")
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT
		oMdlZVG:LoadValue("ZVG_CODIGO","")

		oMdlZVG:LoadValue("ZVG_CODIGO",cCodigo)
		//for nI := 1 to nLinhas
		//	oGridM:GoLIne(nI)
		//	if !oGridM:isDeleted()
		//		if oGridM:GetValue("ZMS_QTDE") == 0
		//			oModel:SetErrorMessage("","","","","HELP", 'Linha ' + cValToChar(nI) + ' com quantidade zerada', "Verifique a Quantidade ou Apague a linha")
		//			Return .F.
		//		endif
		//	endif
		//next

		//DbSelectArea('ZVG')
		//ZVG->(DbSetOrder(1)) 
//
		////Se conseguir posicionar, tabela jÃ¡ existe
		//If ZVG->(DbSeek( xFilial("ZVG") +;
		//		oModel:GetValue('ZVGMASTER', 'ZVG_COD')))
        //       // dToS(oModel:GetValue('ZVGMASTER', 'ZVG_DATA'))))
		//	Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
		//	lRet := .F.
		//EndIf
/* 	ElseIf nOpc == MODEL_OPERATION_DELETE
		IF oCab:GetValue("ZVG_STATUS") == 'M'
			MsgAlert("Registro com movimentação realizada, não é permitido a exclusão!", "Atenção")
			lRet  := .F.
		endif */

	EndIf

	RestArea(aArea)
Return lRet

User Function I08TELA1()
	local aArea         := GetArea()
	Local cFunBkp       := ""
    Private cPerg       := "VAZVG"

	If msgYesNo("Deseja inserir uma nova Movimentação?")

		if Len( aLotes := aClone(MrkLotes()) )  > 0
            cFunBkp := FunName()

            SetFunName("VAESTI08")
                FWExecView('Incluir', 'VAESTI08', MODEL_OPERATION_INSERT,,{||.T.})
            SetFunName(cFunBkp)

        endif 

    EndIf
    RestArea(aArea)
Return

Static function MrkLotes(lAdd)
	local nOpc          := GD_UPDATE
	local cLinOk        := "AllwaysTrue"
	local cTudoOk       := "AllwaysTrue"
	local cIniCpos      := "B8_LOTECTL"
	local nFreeze       := 000
	local nMax          := 999
	local cFieldOk      := "AllwaysTrue"
	local cSuperDel     := ""
	local cDelOk        := "AllwaysFalse"
	local nTamLin       := 16
	local nLinIni       := 03
	local nLinAtu       := nLinIni
    Local aLote        := {}

	Default lAdd        := .F.

	Private oDlg
	Private aHeadMrk    := {}
	Private aColsMrk    := {}
	Private nUsadMrk    := 0

	Private cLoteDe     := Space(TamSX3("B8_LOTECTL")[1])
	Private cLoteAte    := PadR('',TamSX3("B8_LOTECTL")[1],'Z')

	Private cCurralDe   := Space(TamSX3("B8_X_CURRA")[1])
	Private cCurralAte  := PadR('',TamSX3("B8_X_CURRA")[1],'Z')

	Private cProdDe     := Space(TamSX3("B1_COD")[1])
	Private cProdAte    := PadR('',TamSX3("B1_COD")[1],'Z')

	Private cEquip      := GetMV("JR_BALPADM",,"000001") //Space(TamSX3("ZV0_CODIGO")[1])
	Private cArm        := GetMV("JR_ARMPADM",,"01")
	Private cTpAgr      := ""


	If lAdd
		oModel := FWModelActive()
		If oModel:nOperation <> 4
			Alert("Esta operação não pode ser realizada neste modo de edição.")
			Return .F.
		EndIf
	EndIf

	aSize := MsAdvSize(.F.)

	/*
	 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	 aSize[1] = 1 -> Linha inicial á²¥a trabalho.
	 aSize[2] = 2 -> Coluna inicial á²¥a trabalho.
	 aSize[3] = 3 -> Linha final á²¥a trabalho.
	 aSize[4] = 4 -> Coluna final á²¥a trabalho.
	 aSize[5] = 5 -> Coluna final dialog (janela).
	 aSize[6] = 6 -> Linha final dialog (janela).
	 aSize[7] = 7 -> Linha inicial dialog (janela).
	*/
	aAdd(aHeadMrk,{ " "			, "cStat"      	, "@BMP"         			, 1,0,"","","C","","V","","","","V","","",""})
	aAdd(aHeadMrk,{ "Lote"		, "B8_LOTECTL"	, X3Picture("B8_LOTECTL")	, TamSX3("B8_LOTECTL")[1]	, 0, "AllwaysTrue()", X3Uso("B8_LOTECTL")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Curral"	, "B8_X_CURRA"	, X3Picture("B8_X_CURRA")	, TamSX3("B8_X_CURRA")[1]	, 0, "AllwaysTrue()", X3Uso("B8_X_CURRA")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Armazem"	, "B8_LOCAL"	, X3Picture("B8_LOCAL")		, TamSX3("B8_LOCAL")[1]		, 0, "AllwaysTrue()", X3Uso("B8_LOCAL")		, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Saldo"		, "B8_SALDO"	, X3Picture("B8_SALDO")		, TamSX3("B8_SALDO")[1]		, 0, "AllwaysTrue()", X3Uso("B8_SALDO")		, "C", "", "V" } )
	
	nUsadMrk := len(aHeadMrk)

	aColsMrk	:= {}
	aAdd(aColsMrk, array(nUsadMrk+1))
	aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.

	define msDialog oDlgMrk title "seleção de Lotes Animais" /*STYLE DS_MODALFRAME*/ From aSize[1], aSize[2] To aSize[3], aSize[5] OF oMainWnd PIXEL
	oDlgMrk:lMaximized := .T. //Maximiza a janela

	oSayFil := TSay():New(nLinAtu, 02 ,{||'Filtros de lotes'},oDlg,,,,,,.T.,,,100,30)
	oSayFil:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 13pt; text-decoration: underline}")

	nLinAtu += nTamLin

	//****************************************************************************
	// Filtro de Lote
	//****************************************************************************
	TSay():New(nLinAtu,02,{||'Lote de: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,030 MSGET oLoteDe VAR cLoteDe PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB8MFJ" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	TSay():New(nLinAtu,82,{||'Lote ate: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,110 MSGET oLoteAte VAR cLoteAte PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB8MFJ" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	//****************************************************************************
	//Filtro de Curral
	//****************************************************************************
	TSay():New(nLinAtu,162,{||'Curral de: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,190 MSGET oCurralDe VAR cCurralDe PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "Z08" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	TSay():New(nLinAtu,242,{||'Curral ate: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,270 MSGET oCurralAte VAR cCurralAte PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "Z08" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	oSeek	:= TButton():New( nLinAtu-2, 322, "Pesquisar" ,oDlgMrk, {|| SeekAll(lAdd) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	//oSeek:SetCss("QPushButton{ color: #000; }")

	oSeek	:= TButton():New( nLinAtu-2, 402, "Confirmar" ,oDlgMrk, {|| aLote := aClone(ConfirmAdd(lAdd)) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	//oSeek:SetCss("QPushButton{ color: #000; background: #2C2; font-weight: bold}")

	nLinAtu += nTamLin + 5
	If !lAdd
		oSayFil := TSay():New(nLinAtu, 02+162 ,{||'Dados da Movimentação'},oDlg,,,,,,.T.,,,100,30)
		//oSayFil:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 13pt; text-decoration: underline}")

		nLinAtu += nTamLin

		nPad := 35
		nA   := 80

		nB := (nA+nPad) + nPad + 30
		aTpMov := {"R-Rateio","I-Individual"}
		cTpMov := aTpMov[1]
		TSay():New(nLinAtu, nB/* 82+162 */,{||'Tipo Movto: '},oDlgMrk,,,,,,.T.,,,60,10)
		aTpMov := TComboBox():New(nLinAtu-1, nB+nPad/* 110+162 */,{|u|If(PCount()>0,cTpMov:=u,cTpMov)}, aTpMov,;
			65,10,oDlgMrk,,{|| SeekAll(lAdd) },,,,.T.,,,,,,,,,'cTpMov')
	else
		nLinAtu += nTamLin
	EndIf
	//nLinAtu += nTamLin + 10

	oBtMrk	:= TButton():New( nLinAtu-5, 02, "Inverter seleção" ,oDlgMrk, {|| MarcaDes(oGetDadMrk,"T") },60, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	//oBtMrk:SetCss("QPushButton{ color: #000; }")

	nLinAtu += nTamLin+4

	oGetDadMrk:= MsNewGetDados():New(nLinAtu, 02, aSize[3]/2, aSize[5]/2, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlgMrk, aHeadMrk, aColsMrk)
	oGetDadMrk:oBrowse:blDblClick := {|| MarcaDes(oGetDadMrk,"L")}

	Activate dialog oDlgMrk centered
Return aLote

/*/{Protheus.doc} seekAll
Funç£¯ responsá¶¥l por pesquisar os produtos a partir dos filtros informados em tela.
@author Renato de Bianchi
@since 15/01/2019
@version 1.0
@Return ${nenhum}, ${não há ²etorno}
@type function
/*/
static function seekAll(lAdd)
	Local nI    := 0
	Local nX      := 0
	Local _cQry   := ""
	Local cFiltro := ""
    Local cAlias  := GetNextAlias()
	Local oModel
	Local oView
	Local oMdlZVH
	Local oMdlZVJ

	If lAdd
		oModel 	 := FWModelActive()
		oView	 := FWViewActive()
		oMdlZVH := oModel:GetModel( 'ZVHDETAIL' )
		oMdlZVJ := oModel:GetModel( 'ZVJDETAIL' )

		If Len(aLotes) > 0

			cFiltro += " and B8_LOTECTL+B8_X_CURRA+B8_LOCAL not in ("
			for nI := 1 to Len(aLotes)
				cFiltro += iIf(nI > 1, ",", "") + "'" +  aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_LOTE"})][2] +;
														 aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_CURRAL"})][2] +; 
														 aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_B8LOC"})][2] +"'"
			Next
			cFiltro += " ) " + CRLF
		EndIf
	EndIf

	_cQry := " SELECT DISTINCT 'LBTIK' CSTAT,B8_X_CURRA,B8_LOTECTL,B8_LOCAL,SUM(B8_SALDO) B8_SALDO" + CRLF
	_cQry += "   FROM "+RetSqlName("SB8")+" SB8" + CRLF
	_cQry += "   JOIN "+RetSqlName("Z08")+" Z08 ON Z08_CODIGO = B8_X_CURRA AND Z08.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  WHERE B8_FILIAL = '"+FwxFilial("SB8")+"'" + CRLF
	_cQry += "    AND B8_SALDO > 0" + CRLF
	_cQry += "	AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "	AND B8_X_CURRA <> ' ' " + CRLF
	_cQry += "	AND Z08_TIPO = '4'" + CRLF
	if cFiltro <> ""
		_cQry += cFiltro + CRLF
	endif
	_cQry += "	GROUP BY B8_X_CURRA, B8_LOTECTL,B8_LOCAL" + CRLF
	_cQry += "	ORDER BY B8_X_CURRA" + CRLF
	
	MemoWrite("C:\totvs_relatorios\SQL_VAESTI08_seekAll.sql" , _cQry)

    mpSysOpenQuery(_cQry ,cAlias)
    
    aColsMrk	:= {}
    If !(cAlias)->(Eof())
        While !(cAlias)->(eof())
            aAdd(aColsMrk, array(nUsadMrk+1))

            For nX:=1 to nUsadMrk
                aColsMrk[Len(aColsMrk),nX]:=(cAlias)->( FieldGet(FieldPos(aHeadMrk[nX,2])) )
            Next
            aColsMrk[Len(aColsMrk),nUsadMrk+1]:=.F.
            (cAlias)->(dbSkip())
        End
    else
        aAdd(aColsMrk, array(nUsadMrk+1))
        aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.
    EndIf

	(cAlias)->(dbCloseArea())

	oGetDadMrk:setArray(aColsMrk)
	oGetDadMrk:oBrowse:Refresh()
	oDlgMrk:CtrlRefresh()
	ObjectMethod(oDlgMrk,"Refresh()")
Return
                      
Static Function MarcaDes(oObj,cTipo)
	Local k := 0
	If cTipo <> "T"
		If oObj:aCols[oObj:oBrowse:nAt,1] == "LBNO"
			oObj:aCols[oObj:oBrowse:nAt,1] := "LBTIK"
		Else
			oObj:aCols[oObj:oBrowse:nAt,1] := "LBNO"
		EndIf
	Else
		FOR k:= 1 TO len(oObj:aCols)
			If oObj:aCols[k,1] == "LBNO"
				oObj:aCols[k,1] := "LBTIK"
			Else
				oObj:aCols[k,1] := "LBNO"
			EndIf
		Next

	EndIf
Return (NIL)

Static Function ConfirmAdd(lAdd)
	local aArea         := GetArea()
	local nPosLote      := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_LOTECTL"})
	local nPosCurral    := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_X_CURRA"})
	local nPosSaldo     := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_SALDO"})
	local nPosLocal     := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_LOCAL"})
	Local nI            := 0
    Local aLote         := iif(Len(aLotes)>0,aClone(aLotes),{})
	Local oModel 
	Local oMdlZVH	
	Local oMdlZVJ	

	for nI := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[ nI,1]=="LBTIK"
            //VALIDAR SE O LOTE SELECIONADO ESTÁ EM ALGUMA MOVIMENTAÇÃO ABERTA.
			//If !u_vldPrdBv(oGetDadMrk:aCols[ nI,nPosProd],oGetDadMrk:aCols[ nI,nPosLote])
			//	msgAlert("Lote n.[" + oGetDadMrk:aCols[ nI,nPosLote] + " ] já está sendo utilizado em outra Movimentação")
			//		RestArea(aArea)
			//	Return
			//EndIf
			aAdd(aLote, {;
				{"ZVJ_LOTE"     , oGetDadMrk:aCols[ nI, nPosLote]},;
				{"ZVJ_CURRAL"   , oGetDadMrk:aCols[ nI, nPosCurral]},;
				{"ZVJ_SALDO"    , oGetDadMrk:aCols[ nI, nPosSaldo]},;
				{"ZVJ_B8LOC"    , oGetDadMrk:aCols[ nI, nPosLocal]};
			})
		EndIf
	Next

	If Len(aLote) == 0
		msgAlert("Nenhum lote selecionado, escolha pelo menos 1 lote para continuar.")
		Return .F.
	EndIf

	if lAdd
		oModel 	:= FwModelActivate()
		oMdlZVH	:= oModel:GetModel("ZVHDETAIL")
		oMdlZVJ := oModel:GetModel("ZVJDETAIL")

		For nI := 1 to oMdlZVH:GetQtdLine()
			oMdlZVH:GoLine(nI)
			oMdlZVH:SetValue("ZVH_QUANT",oMdlZVH:GetValue("ZVH_QUANT"))
		next nI 
	endif 
	oDlgMrk:End()
	RestArea(aArea)
Return aLote

User Function ESTI08C() // INICIADOR PADRAO DO CÓGIGO
    Local cQry      := ""
    Local cRet      := "000001"
    Local cAlias    := "" 
    Local cCampo    := SubStr(ReadVar(),At(">",ReadVar())+1,Len(ReadVar()))
    //Local oModel    := nil

    IF "ZVG_CODIGO" $ cCampo
        cQry := "SELECT MAX(ZVG_CODIGO)+1 AS COD FROM "+RetSqlName("ZVG")
        
        cAlias := GetNextAlias()
        
        mpSysOpenQuery(cQry,cAlias)

        If !(cALias)->(EOF())
            cRet := StrZero((cALias)->COD,TamSx3("ZVG_CODIGO")[1])
        endif

        (cAlias)->(DbCloseArea())
    ELSEIF "ZVH_CODIGO"  $ cCampo .OR. "ZVJ_CODIGO"  $ cCampo
		cRet := Iif(INCLUI, M->ZVG_CODIGO,ZVG->ZVG_CODIGO)
    endif

Return cRet

User Function I08VLDP() // validação do produto - grid ZVH
    Local aArea     := FwGetArea()
    Local oModel    := FWModelActive()
    Local oMdlZVH   := oModel:GetModel("ZVHDETAIL")
    Local lRet      := .T. 

    DbSelectArea("SB1")
    SB1->(DBSetOrder(1))//B1_FILIAL+B1_COD
    
    if !(SB1->(DBSeek(FwxFilial("SB1")+oMdlZVH:GetValue("ZVH_PROD"))))
        oModel:SetErrorMessage("","","","","HELP", 'Produto não encontrado', "Preencha corretamente o campo Produto")
        return .F. 
    else
        DbSelectArea("SB2")
        SB2->(DBSetOrder(1))//B2_FILIAL+B2_COD+B2_LOCAL

        IF !(SB2->((DBSeek(FwxFilial("SB2")+oMdlZVH:GetValue("ZVH_PROD")+oMdlZVH:GetValue("ZVH_LOCAL")))))
            oModel:SetErrorMessage("","","","","HELP", 'Produto sem saldo', "Verifique se o armazem e o produto estão corretos!")
            return .F.
        else 
            If SB2->B2_QATU == 0
                oModel:SetErrorMessage("","","","","HELP", 'Produto sem saldo', "Verifique se o armazem e o produto estão corretos!")
                return .F. 
            //else
            //    oMdlZVH:SetValue("ZVH_B2QATU",SB2->B2_QATU)
            EndIf 
        endif   
    endif   
    
    FwRestArea(aArea)
Return lRet 

User Function I08VHDQ() // validação do produto - grid ZVH
    Local lRet := .t. 
    Local oModel    := FWModelActive()
    Local oMdlZVG   := oModel:GetModel("ZVGMASTER")
    Local oMdlZVH   := oModel:GetModel("ZVHDETAIL")
    Local oMdlZVJ   := oModel:GetModel("ZVJDETAIL")
    Local oMdlTOT   := oModel:GetModel("TOTAIS")
	Local lTipo		:= oMdlZVG:GetValue('ZVG_TIPO') == 'I'
    Local nI,nX,nPos
    Local nQtdLote
    
    if oMdlZVH:GetValue("ZVH_QUANT") > oMdlZVH:GetValue("ZVH_B2QATU")
        oModel:SetErrorMessage("","","","","HELP", 'Quantidade maior que o saldo atual', "Verifique a quantidade digitada!")
        Return .F. 
    else	
		
		For nI := 1 to oMdlZVJ:GetQtdLine()
			oMdlZVJ:Goline(nI)
			oMdlZVJ:DeleteLine()
		Next nI
		
		//oMdlZVJ:SetNoInsertLine(.F.)
		
		nQtdLote := Len(aLotes)
		For nI := 1 To oMdlZVH:GetQtdLine()
			oMdlZVH:GoLine(nI)
			For nX := 1 To oMdlZVJ:GetQtdLine()
				oMdlZVJ:GoLine(nI)

				if !lTipo
					oMdlZVJ:LoadValue("ZVJ_QTDE"     ,oMdlZVH:GetValue("ZVH_QUANT") / nQtdLote)
				endif
			Next nX
			oMdlTOT:LoadValue("XX_TOTAL"     ,ROUND((oMdlZVH:GetValue("ZVH_QUANT") / nQtdLote) * Len(aLotes),4))
		Next nI

		nPos := nX - 1

        For nI := nPos To nQtdLote
            oMdlZVJ:AddLine()
            
            oMdlZVJ:SetValue("ZVJ_ITEMVH"   , oMdlZVH:GetValue("ZVH_ITEM"))
            oMdlZVJ:SetValue("ZVJ_LOTE"     , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_LOTE"})][2])
            oMdlZVJ:SetValue("ZVJ_CURRAL"   , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_CURRAL"})][2])
            oMdlZVJ:SetValue("ZVJ_SALDO"    , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_SALDO"})][2])
            oMdlZVJ:SetValue("ZVJ_B8LOC"    , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_B8LOC"})][2])
            oMdlZVJ:SetValue("ZVJ_PROD"     , oMdlZVH:GetValue("ZVH_PROD"))
            oMdlZVJ:SetValue("ZVJ_B1LOC"    , oMdlZVH:GetValue("ZVH_LOCAL"))
            if lTipo
				oMdlZVJ:SetValue("ZVJ_QTDE"     , 0)
			else
				oMdlZVJ:LoadValue("ZVJ_QTDE"     ,oMdlZVH:GetValue("ZVH_QUANT") / nQtdLote)
			endif
        Next nI

		oMdlTOT:LoadValue("XX_TOTAL"     ,ROUND((oMdlZVH:GetValue("ZVH_QUANT") / nQtdLote) * Len(aLotes),4))
        
		//oMdlZVJ:SetNoInsertLine(.T.)
		
        oMdlZVJ:Goline(1)
    endif 
Return lret 

User Function I08VJDQ() // validação do QUANTIDADE  - grid ZVJ_QTDE
    Local lRet 			:= .t. 
    Local oModel    	:= FWModelActive()
    Local oMdlZVG   	:= oModel:GetModel("ZVGMASTER")
    Local oMdlZVH   	:= oModel:GetModel("ZVHDETAIL")
    Local oMdlTOT   	:= oModel:GetModel("TOTAIS")
	Local aSaveLines 	:= FWSaveRows()

	if oMdlZVG:GetValue('ZVG_TIPO') == 'I'
		
		IF oMdlTOT:GetValue("XX_TOTAL") >  oMdlZVH:GetValue("ZVH_QUANT") 
			oModel:SetErrorMessage("","","","","HELP", 'Quantidade inválida', "A soma da quantidade dessa Grid não pode ser maior que a quantidade indicada na Grid Central!" + CRLF +;
																				"Verifique a Quantidade da grid central na linha: "+LTrim(Str(oMdlZVH:GetLine()))+", Item: " + oMdlZVH:GetValue("ZVH_ITEM"))
			Return .F.
		endif 

	endif 	

	FWRestRows(aSaveLines)
Return lret 

Static Function I08HPRE(oGrid, nLine, cAction, cField)
	Local lRet	 	:= .T.
	Local oModel    := FWModelActive()
    Local oMdlZVG   := oModel:GetModel("ZVGMASTER")
    Local oMdlZVH   := oModel:GetModel("ZVHDETAIL")
    Local oMdlZVJ   := oModel:GetModel("ZVJDETAIL")
    Local oMdlTOT   := oModel:GetModel("TOTAIS")
	Local nI

	If cAction == 'ADDLINE'
		if oMdlZVG:GetValue("ZVG_TIPO") == 'I'

			if oMdlTOT:GetValue("XX_TOTAL")  < oMdlZVH:GetValue("ZVH_QUANT") 
				oModel:SetErrorMessage("","","","","HELP", 'Ação inválida!', "Quantidade do produto na grid de itens não confere com a quantidade informada na grid de produtos!")
	    		Return .F. 
			endif
		ENDIF
	elseIf cAction == 'DELETE'

	  	if oMdlZVG:GetValue("ZVG_STATUS") == 'M'
	        oModel:SetErrorMessage("","","","","HELP", 'Ação inválida!', "Não permitido apagar linhas com Movimentações geradas.!")
	    	Return .F.
		ENDIF
		
		oMdlZVJ:SetNoDeleteLine(.F.)
		For nI := 1 to oMdlZVJ:GetQtdLine()
			oMdlZVJ:Goline(nI)
			oMdlZVJ:DeleteLine()
		Next nI 
		oMdlZVJ:SetNoDeleteLine(.t.)
	EndIf

Return lRet
