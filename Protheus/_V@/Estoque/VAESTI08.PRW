#include "protheus.ch" 
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Apontamento de Feno" 

// Igor Oliveira 08-2024
User Function VAESTI08()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
    ///Private cArquivo 	 := "C:\totvs_relatorios\"

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
    Local aZVHRel   := {}
    Local aZVJRel   := {}
    Local aGatilhos := {}
    Local nI 

    aAdd(aGatilhos, FWStruTriggger( "ZVH_PROD", "ZVH_DESC" ,"SB1->B1_DESC"  ,.T.,"SB1"  ,1,"FwxFilial('SB1')+M->ZVH_PROD" ,NIL,"01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVH_PROD", "ZVH_LOCAL","SB1->B1_LOCPAD",.F.,""     ,,""                             ,NIL,"02"))

	For nI := 1 To Len(aGatilhos)
        oStZVH:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
						    aGatilhos[nI][02],; //Campo Destino
						    aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
						    aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next 

    oStZVH:SetProperty( 'ZVH_LOCAL', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_I08VLDP()") )
    oStZVH:SetProperty( 'ZVH_QUANT', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_I08VLDQ()") )

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ESTI08M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/,/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZVGMASTER",/*cOwner*/ ,oStZVG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZVHDETAIL'  ,'ZVGMASTER',oStZVH, /* { |oGridM, nLine,cAction, cField| I03GPRE(oGridM, nLine, cAction, cField) } */)
	oModel:AddGrid('ZVJDETAIL'  ,'ZVHDETAIL',oStZVJ, /* { |oGridM, nLine,cAction, cField| I03GPRE(oGridM, nLine, cAction, cField) } */)

	aAdd(aZVHRel, {'ZVH_FILIAL', 'ZVG_FILIAL'} )
	aAdd(aZVHRel, {'ZVH_CODIGO', 'ZVG_CODIGO'} )
    oModel:SetRelation('ZVHDETAIL', aZVHRel, ZVH->(IndexKey(1)))

	aAdd(aZVJRel, {'ZVJ_FILIAL', 'ZVH_FILIAL'} )
	aAdd(aZVJRel, {'ZVJ_CODIGO', 'ZVH_CODIGO'} )
	aAdd(aZVJRel, {'ZVJ_ITEMVH', 'ZVH_ITEM'} )
    oModel:SetRelation('ZVJDETAIL', aZVJRel, ZVJ->(IndexKey(3)))

	oModel:SetPrimaryKey({ })

    oModel:GetModel("ZVGMASTER"):SetFldNoCopy({'ZVG_FILIAL', 'ZVG_CODIGO'})
    
	//Setando outras informações do Modelo de Dados
	oModel:GetModel("ZVGMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZVHDETAIL"):SetDescription("Produtos: "+cTitulo)
	oModel:GetModel("ZVJDETAIL"):SetDescription("Lotes: "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VAESTI08")
	Local oStZVG    := FWFormStruct(2, 'ZVG')
	Local oStZVH    := FWFormStruct(2, 'ZVH')
	Local oStZVJ    := FWFormStruct(2, 'ZVJ')
	Local oView     := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZVG" , oStZVG  , "ZVGMASTER")
	oView:AddGrid("VIEW_ZVH" , oStZVH  , "ZVHDETAIL")
	oView:AddGrid("VIEW_ZVJ" , oStZVJ  , "ZVJDETAIL")
	//Habilitando título
	
    oView:CreateHorizontalBox('BOX_ZVG' , 20)
    oView:CreateHorizontalBox('BOX_ZVH' , 40)
    oView:CreateHorizontalBox('BOX_ZVJ' , 40)
	
    oView:SetOwnerView('VIEW_ZVG','BOX_ZVG')
	oView:SetOwnerView('VIEW_ZVH','BOX_ZVH')
	oView:SetOwnerView('VIEW_ZVJ','BOX_ZVJ')
    
    oView:EnableTitleView('VIEW_ZVG', "Cabeçalho")
    oView:EnableTitleView('VIEW_ZVH', "Produtos")
    oView:EnableTitleView('VIEW_ZVJ', "Lotes")

	oView:AddIncrementField( 'VIEW_ZVH', 'ZVH_ITEM' )
	oView:AddIncrementField( 'VIEW_ZVJ', 'ZVJ_ITEM' )

    //Tratativa padrão para fechar a tela

	oView:SetCloseOnOk( { |oView| .T. } )
	//O formulário da interface será colocado dentro do container
Return oView

Static Function zVldZVGTab()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT

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

	EndIf

	RestArea(aArea)
Return lRet

User Function I08TELA1()
	local aArea         := GetArea()
	Local cFunBkp       := ""
    Private cPerg       := "VAZVG"
    Private aLotes      := {}
   // Private cCodMovto   := ""

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
    Local aLotes        := {}

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
	Private cTpMov      := ""
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

	oSeek	:= TButton():New( nLinAtu-2, 402, "Confirmar" ,oDlgMrk, {|| aLotes := aClone(ConfirmAdd(lAdd)) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
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
Return aLotes

/*/{Protheus.doc} seekAll
Funç£¯ responsá¶¥l por pesquisar os produtos a partir dos filtros informados em tela.
@author Renato de Bianchi
@since 15/01/2019
@version 1.0
@Return ${nenhum}, ${não há ²etorno}
@type function
/*/
static function seekAll(lAdd)
	Local nAux    := 0
	Local nX      := 0
	Local _cQry   := ""
	Local cFiltro := ""
    Local cAlias  := GetNextAlias()

	If lAdd
		oModel := FWModelActive()
		oView := FWViewActive()
		oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
		If oGridZ0D:Length() > 0
			cFiltro += " and B8_PRODUTO+B8_LOTECTL not in ("
			for nAux := 1 to oGridZ0D:Length()
				cFiltro += iIf(nAux > 1, ",", "") + "'" +  PadR(AllTrim(oGridZ0D:GetValue('Z0D_PROD', nAux)),TamSx3("B8_PRODUTO")[1])+PadR(AllTrim(oGridZ0D:GetValue('Z0D_LOTE', nAux)),TamSx3("B8_LOTECTL")[1]) + "'"
			Next
			cFiltro += " ) " + CRLF
		EndIf
	EndIf

	_cQry := " SELECT DISTINCT 'LBTIK' CSTAT,B8_X_CURRA,B8_LOTECTL,SUM(B8_SALDO) B8_SALDO" + CRLF
	_cQry += "   FROM "+RetSqlName("SB8")+" SB8" + CRLF
	_cQry += "   JOIN "+RetSqlName("Z08")+" Z08 ON Z08_CODIGO = B8_X_CURRA AND Z08.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  WHERE B8_FILIAL = '0101001'" + CRLF
	_cQry += "    AND B8_SALDO > 0" + CRLF
	_cQry += "	AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "	AND B8_X_CURRA <> ' ' " + CRLF
	_cQry += "	AND Z08_TIPO = '4'" + CRLF
	_cQry += "	GROUP BY B8_X_CURRA, B8_LOTECTL" + CRLF
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
	Local nI            := 0
    Local aLotes        := {}

	nQt := 0
	for nI := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[ nI,1]=="LBTIK"
			nQt++
            //VALIDAR SE O LOTE SELECIONADO ESTÁ EM ALGUMA MOVIMENTAÇÃO ABERTA.
			//If !u_vldPrdBv(oGetDadMrk:aCols[ nI,nPosProd],oGetDadMrk:aCols[ nI,nPosLote])
			//	msgAlert("Lote n.[" + oGetDadMrk:aCols[ nI,nPosLote] + " ] já está sendo utilizado em outra Movimentação")
			//	RestArea(aArea)
			//	Return
			//EndIf
		EndIf
	Next

	If nQt = 0
		msgAlert("Nenhum lote selecionado, escolha pelo menos 1 lote para continuar.")
		Return .F.
	EndIf

	If !lAdd
		//cCodMovto := U_ESTI08C() //GETSXENUM("ZVG","ZVG_CODIGO"); ConfirmSX8()
		//dbSelectArea("ZVG")
		//RecLock("ZVG", .T.)
        //    ZVG->ZVG_FILIAL := FWxFilial("ZVG")
        //    ZVG->ZVG_CODIGO	:= cCodMovto
        //    ZVG->ZVG_DATA	:= DATE()
        //    ZVG->ZVG_USER   := cUserName
        //    ZVG->ZVG_TIPO  	:= cTpMov
		//msUnlock()
	//else
	//	cCodMovto := ZVG->ZVG_CODIGO
	EndIf

	lShowMsg := .F.
	dbSelectArea("Z0D")
	dbSelectArea("Z0E")
	cSeq := ""
	for nI := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[ nI,1]=="LBTIK"
			If !lAdd
				If empty(cSeq)
					cSeq := "0001"
				else
					cSeq := soma1(cSeq)
				EndIf

                aAdd(aLotes, {;
                        {"ZJV_LOTE"     , oGetDadMrk:aCols[ nI, nPosLote]},;
                        {"ZVJ_CURRAL"   , oGetDadMrk:aCols[ nI, nPosCurral]},;
                        {"ZVJ_SALDO"    , oGetDadMrk:aCols[ nI, nPosSaldo]};
                    })
                    //{"ZJV_CODIGO"   , cCodMovto},;

				lShowMsg := .T.
			else
				oModel   := FWModelActive()
				oView    := FWViewActive()
				oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
				cSeq     := oGridZ0D:GetValue( 'Z0D_SEQ' , oGridZ0D:Length())
				cSeq     := soma1(cSeq)

				oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .F. )

				oGridZ0D:AddLine()
				oGridZ0D:LoadValue("Z0D_CODIGO", cCodMovto)
				oGridZ0D:LoadValue("Z0D_SEQ", cSeq)
				oGridZ0D:LoadValue("Z0D_PROD", left(oGetDadMrk:aCols[ nI, nPosProd],TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_DESC", left(AllTrim(oGetDadMrk:aCols[ nI, nPosDesc]),TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_LOCAL", Posicione("SB1",1,FWxFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_LOCPAD"))
				oGridZ0D:LoadValue("Z0D_LOTE", oGetDadMrk:aCols[ nI, nPosLote])
				oGridZ0D:LoadValue("Z0D_CURRAL", oGetDadMrk:aCols[ nI, nPosCurral])
				oGridZ0D:LoadValue("Z0D_QTDORI", oGetDadMrk:aCols[ nI, nPosSaldo])
				oGridZ0D:LoadValue("Z0D_QUANT", oGetDadMrk:aCols[ nI, nPosSaldo])

				oGridZ0D:LoadValue("Z0D_RACA"  , SubS( SB1->B1_XRACA  , 1, TamSX3('Z0D_RACA')[1]) )
				oGridZ0D:LoadValue("Z0D_SEXO"  , SubS( SB1->B1_X_SEXO , 1, TamSX3('Z0D_SEXO')[1]) )
				oGridZ0D:LoadValue("Z0D_DENTIC", SubS( SB1->B1_XDENTIC, 1, TamSX3('Z0D_DENTIC')[1]) )

				oModel:LoadValue("CALC_TOT", "Z0D__TOT01", oModel:GetValue("CALC_TOT","Z0D__TOT01")+;
					oGetDadMrk:aCols[ nI, nPosSaldo])
				oView:Refresh()

				oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .T. )
			EndIf
		EndIf
	Next

	//If lShowMsg
	//	msgInfo("Movimento N.[" + cCodMovto + " ] incluído com sucesso! Para editar seus dados, clique em alterar.")
	//EndIf

	oDlgMrk:End()
	RestArea(aArea)
Return aLotes

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
    ELSEIF "ZVH_CODIGO"  $ cCampo
        //oModel := FwModelActivate():GetModel("ZVGMASTER")
        cRet := M->ZVG_CODIGO
    ELSEIF "ZVJ_CODIGO"  $ cCampo
        //oModel := FwModelActivate():GetModel("ZVGMASTER")
        cRet := M->ZVG_CODIGO
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
            else
                oMdlZVH:SetValue("ZVH_B2QATU",SB2->B2_QATU)


            EndIf 
        endif   
    endif   
    

    

    FwRestArea(aArea)
Return lRet 

User Function I08VLDQ() // validação do produto - grid ZVH
    Local lRet := .t. 
    Local oModel    := FWModelActive()
    Local oMdlZVH   := oModel:GetModel("ZVHDETAIL")
    Local oMdlZVJ   := oModel:GetModel("ZVJDETAIL")
    Local nI
    Local nQtdLote
    
    if oMdlZVH:GetValue("ZVH_QUANT") > oMdlZVH:GetValue("ZVH_B2QATU")
        oModel:SetErrorMessage("","","","","HELP", 'Quantidade maior que o saldo atual', "Verifique a quantidade digitada!")
        Return .F. 
    else
        if !(oMdlZVJ:IsEmpty())
            oMdlZVJ:ClearData()
        endif 

        nQtdLote := Len(aLotes)
        For nI := 1 To nQtdLote
            oMdlZVJ:AddLine()
            
            oMdlZVJ:SetValue("ZVJ_ITEMVH"   , oMdlZVH:GetValue("ZVH_ITEM"))
            oMdlZVJ:SetValue("ZVJ_LOTE"     , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZJV_LOTE"})][2])
            oMdlZVJ:SetValue("ZVJ_CURRAL"   , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_CURRAL"})][2])
            oMdlZVJ:SetValue("ZVJ_SALDO"    , aLotes[nI][aScan(aLotes[nI], {|x| Upper(x[1]) == "ZVJ_SALDO"})][2])
            oMdlZVJ:SetValue("ZVJ_PROD"     , oMdlZVH:GetValue("ZVH_PROD"))
            oMdlZVJ:SetValue("ZVJ_LOCAL"    , oMdlZVH:GetValue("ZVH_LOCAL"))
            oMdlZVJ:SetValue("ZVJ_QTDE"     , oMdlZVH:GetValue("ZVH_QUANT") / nQtdLote)
        Next nI 
        
        oMdlZVJ:Goline(1)
    endif 
Return lret 
