#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "JURA289.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA289
Rotina responsavel pelos Relacionamentos do Assunto jurÍ­dico
Incidedentes, Vinculados e Relacionados 
@since 22/01/2021
/*/
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 22/01/2021
@return oModel, retorna o objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel      := nil
Local oStrNSZ     := FWFormStruct(1,'NSZ',{|cpo| alltrim(cpo)+',' $ 'NSZ_FILIAL, NSZ_COD, NSZ_FPRORI, NSZ_CPRORI, NSZ_DCASO,'})
Local oStrNVO     := FWFormStruct(1,'NVO')
Local oStrNXX     := FWFormStruct(1,'NXX')
Local oStrNSZGRID := FWFormStruct(1,'NSZ',{|cpo| alltrim(cpo)+',' $ 'NSZ_FILIAL, NSZ_COD, NSZ_FPRORI, NSZ_CPRORI, NSZ_DCASO,'})

	oStrNVO:AddField( "" ,"" ,"NVO_DCASO"  ,"C",250  ,0  ,,,,,,,,.T. ,)
	oStrNXX:AddField( "" ,"" ,"NXX_DCASO"  ,"C",250  ,0  ,,,,,,,,.T. ,)
	oStrNVO:AddField( "" ,"" ,"NVO_TIPOAS"  ,"C",3  ,0  ,,,,,,,,.T. ,)
	oStrNXX:AddField( "" ,"" ,"NXX_TIPOAS"  ,"C",3  ,0  ,,,,,,,,.T. ,)
	
	oModel := MPFormModel():New('JURA289', ,{|oM| PosValid(oModel)} , ,  )

	// MASTER
	oModel:AddFields( "NSZMASTER", ,oStrNSZ,,,)
	oModel:SetDescription(STR0001) //'Relacionamentos' 
	oModel:GetModel('NSZMASTER'):SetDescription(STR0001) //'Relacionamentos' 

	// VINCULADOS
	oModel:AddGrid('NVODETAIL' ,'NSZMASTER',oStrNVO,,,,,{ |oM| LoadNVO(oM) })
	oModel:SetRelation('NVODETAIL' ,{{ 'NVO_FILORI', 'NSZ_FILIAL' },{ 'NVO_CAJUR1', 'NSZ_COD' }},NVO->(IndexKey(1))) //NVO_FILIAL+NVO_FILORI+NVO_CAJUR1+NVO_FILDES+NVO_CAJUR2
	oModel:getModel('NVODETAIL'):setOptional(.T.)

	// RELACIONADOS
	oModel:AddGrid('NXXDETAIL' ,'NSZMASTER',oStrNXX,,,,,{ |oM| LoadNXX(oM) })
	oModel:getModel('NXXDETAIL'):setOptional(.T.) 

	// Incidentes
	oModel:AddGrid('NSZDETAIL' ,'NSZMASTER',oStrNSZGRID,,,,,{ |oM| LoadNSZ(oM) })
	oModel:getModel('NSZDETAIL'):setOptional(.T.)
	oModel:getModel('NSZDETAIL'):SetNoInsertLine(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadNSZ
Função responsavel pela carga do submodelo de incidentes
@since 22/01/2021
@return oModel, retorna o objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function LoadNSZ( oObj )
Local aArea := GetArea()
Local aRet := {}
Local cTmp := ''
Local cQuery := ''
Local cFilPro := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_FILIAL')
Local cCajuri := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_COD')
	
	cTmp := GetNextAlias()

	cQuery := " SELECT NSZ_FILIAL, " + ;
					 " NSZ_COD , " + ;
					 " NSZ_FPRORI, " + ;
					 " NSZ_CPRORI, " + ;
					 " R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSqlName( 'NSZ' ) + " NSZ "
	cQuery +=  " WHERE NSZ_FPRORI = '" + cFilPro + "' "
	cQuery +=    " AND NSZ_CPRORI = '" + cCajuri + "' "
	cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
	
	aRet := FWLoadByAlias( oObj, cTmp, 'NSZ' )
	
	(cTmp)->( dbCloseArea() )
	
	RestArea( aArea )
 
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadNVO
Função responsavel pela carga do submodelo de vinculados
@since 22/01/2021
@return oModel, retorna o objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function LoadNVO( oObj )
Local aArea := GetArea()
Local aRet := {}
Local cTmp := ''
Local cQuery := ''
Local cFilPro := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_FILIAL')
Local cCajuri := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_COD')
	
	cTmp := GetNextAlias()
	cQuery := "SELECT NVO.*, NVE.NVE_TITULO NVO_DCASO, NSZ.NSZ_TIPOAS NVO_TIPOAS FROM " + RetSqlName( 'NVO' ) + " NVO "
	cQuery += "INNER JOIN " + RetSqlName( 'NSZ' ) + " NSZ "
	cQuery += " ON (NVO_FILDES = NSZ_FILIAL AND NVO_CAJUR2 = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName( 'NVE' ) + " NVE "
	cQuery += " ON (NVE_FILIAL = '" + xFilial('NVE') + "'"
	cQuery += " AND NVE_CCLIEN = NSZ_CCLIEN "
	cQuery += " AND NVE_LCLIEN = NSZ_LCLIEN "
	cQuery += " AND NVE_NUMCAS = NSZ_NUMCAS "
	cQuery += " AND NVE.D_E_L_E_T_ = ' ') "
	cQuery +=  " WHERE NVO_FILORI = '" + cFilPro + "' "
	cQuery +=    " AND NVO_CAJUR1 = '" + cCajuri + "'"
	cQuery +=    " AND NVO.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
	
	aRet := FWLoadByAlias( oObj, cTmp, 'NVO' )
	
	(cTmp)->( dbCloseArea() )
	
	RestArea( aArea )
 
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadNXX
Função responsavel pela carga do submodelo de relacionados
@since 22/01/2021
@return oModel, retorna o objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function LoadNxx( oObj )
Local aArea := GetArea()
Local aRet := {}
Local cTmp := ''
Local cQuery := ''
Local cFilPro := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_FILIAL')
Local cCajuri := oObj:getModel():getModel('NSZMASTER'):getValue('NSZ_COD')
	
	cTmp := GetNextAlias()
	cQuery := "SELECT NXX.*, NVE.NVE_TITULO NXX_DCASO, NSZ.NSZ_TIPOAS NXX_TIPOAS FROM " + RetSqlName( 'NXX' ) + " NXX "
	cQuery += "INNER JOIN " + RetSqlName( 'NSZ' ) + " NSZ "
	cQuery += 	" ON (NXX_FILDES = NSZ_FILIAL AND NXX_CAJURD = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName( 'NVE' ) + " NVE "
	cQuery += " ON (NVE_FILIAL = '" + xFilial('NVE') + "'"
	cQuery += " AND NVE_CCLIEN = NSZ_CCLIEN "
	cQuery += " AND NVE_LCLIEN = NSZ_LCLIEN "
	cQuery += " AND NVE_NUMCAS = NSZ_NUMCAS "
	cQuery += " AND NVE.D_E_L_E_T_ = ' ') "
	cQuery +=  " WHERE NXX_FILORI = '" + cFilPro + "' "
	cQuery +=    " AND NXX_CAJURO = '" + cCajuri + "'"
	cQuery +=    " AND NXX.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
	
	aRet := FWLoadByAlias( oObj, cTmp, 'NXX' )
	
	(cTmp)->( dbCloseArea() )
	
	RestArea( aArea )
 
Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} PosValid
	(Valida e ajusta os lançamentos dos elacionamentos)
	@since 27/01/2021
	@param oModel , Object, Modelo de Relacionamentos
	@return lRet, Boolean 
/*/
//------------------------------------------------------------------------------
Static Function PosValid(oModel)
Local lRet     := .T.
	
	If ! SetNVO(@oModel)
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, STR0002, ;
			STR0003, STR0004,,)
			// "Vinculados"
			// "Falha ao realizar vínculo!"
			// "Tente Novamente."
	EndIf

	If lRet .And. ! SetNXX(@oModel)
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, STR0005, ;
			STR0006, STR0004,,)
			//"Relacionados"
			//"Falha ao realizar relacionamento!"
	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetNVO(oModel)
	Valida a operação e ajusta a contrapartida da NVO (Vinculados)
	@since 27/01/2021
	@param oModel , Object, Modelo de Relacionamentos
	@return lRet, Boolean 
/*/
//------------------------------------------------------------------------------
Static Function SetNVO(oModel)
Local aArea    := GetArea()
Local aAreaNVO := NVO->( GetArea() )
Local nQtdNVO  := oModel:GetModel("NVODETAIL"):Length()
Local nI       := 0
Local cCajuri1 := ""
Local cCajuri2 := ""
Local cFilial1 := ""
Local cFilial2 := ""
Local lRet     := .T.
	
	DbSelectArea('NVO')
	NVO->(DBSetOrder(1)) // NVO_FILIAL+NVO_FILORI+NVO_CAJUR1+NVO_FILDES+NVO_CAJUR2

	for nI := 1 to nQtdNVO
		oModel:GetModel("NVODETAIL"):GoLine(nI)
		cFilial1 := oModel:GetValue("NVODETAIL","NVO_FILORI")
		cCajuri1 := oModel:GetValue("NVODETAIL","NVO_CAJUR1")
		cFilial2 := oModel:GetValue("NVODETAIL","NVO_FILDES")
		cCajuri2 := oModel:GetValue("NVODETAIL","NVO_CAJUR2")

		if oModel:GetModel("NVODETAIL"):IsUpdated() .And. !oModel:GetModel("NVODETAIL"):IsDeleted()
				if ! NVO->(dbSeek(xFilial('NVO') + cFilial1 + cCajuri1 + cFilial2 + cCajuri2 ))
					
					RecLock("NVO", .T.)
						NVO->NVO_FILIAL := xFilial('NVO')
						NVO->NVO_CAJUR1 := oModel:GetValue("NVODETAIL","NVO_CAJUR2")
						NVO->NVO_CAJUR2 := oModel:GetValue("NVODETAIL","NVO_CAJUR1")
						NVO->NVO_FILORI := oModel:GetValue("NVODETAIL","NVO_FILDES")
						NVO->NVO_FILDES := oModel:GetValue("NVODETAIL","NVO_FILORI")
					NVO->(MsUnlock())
					NVO->(DbCommit())
					ConfirmSX8()
				endif

		elseif oModel:GetModel("NVODETAIL"):IsDeleted()

			if NVO->(dbSeek(xFilial('NVO') + cFilial2 + cCajuri2 + cFilial1 + cCajuri1 ))
				Reclock( "NVO", .F. )
					dbDelete()
				MsUnLock()
			else
				lRet := .F.
			endif
		endif
	next

	RestArea( aAreaNVO )
	RestArea( aArea )

Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetNXX(oModel)
	Valida a operação e ajusta a contrapartida da NVO (Vinculados)
	@since 27/01/2021
	@param oModel , Object, Modelo de Relacionamentos
	@return lRet, Boolean 
/*/
//------------------------------------------------------------------------------
Static Function SetNXX(oModel)
Local aArea    := GetArea()
Local aAreaNXX := NXX->( GetArea() )
Local nQtdNXX  := oModel:GetModel("NXXDETAIL"):Length()
Local nI       := 0
Local cCajuri1 := ""
Local cCajuri2 := ""
Local cFilial1 := ""
Local cFilial2 := ""
Local lRet     := .T.
	
	DbSelectArea('NXX')
	NXX->(DBSetOrder(1)) // NXX_FILIAL+NXX_FILORI+NXX_CAJURO+NXX_FILDES+NXX_CAJURD
	for nI := 1 to nQtdNXX
		oModel:GetModel("NXXDETAIL"):GoLine(nI)
		cFilial1 := oModel:GetValue("NXXDETAIL","NXX_FILORI")
		cCajuri1 := oModel:GetValue("NXXDETAIL","NXX_CAJURO")
		cFilial2 := oModel:GetValue("NXXDETAIL","NXX_FILDES")
		cCajuri2 := oModel:GetValue("NXXDETAIL","NXX_CAJURD")

		if oModel:GetModel("NXXDETAIL"):IsUpdated() .And. !oModel:GetModel("NXXDETAIL"):IsDeleted()
				if ! NXX->(dbSeek(xFilial('NXX') + cFilial1 + cCajuri1 + cFilial2 + cCajuri2 ))
					
					RecLock("NXX", .T.)
						NXX->NXX_FILIAL := xFilial('NXX')
						NXX->NXX_CAJURO := oModel:GetValue("NXXDETAIL","NXX_CAJURD")
						NXX->NXX_CAJURD := oModel:GetValue("NXXDETAIL","NXX_CAJURO")
						NXX->NXX_FILORI := oModel:GetValue("NXXDETAIL","NXX_FILDES")
						NXX->NXX_FILDES := oModel:GetValue("NXXDETAIL","NXX_FILORI")
					NXX->(MsUnlock())
					NXX->(DbCommit())
					ConfirmSX8()
				endif

		elseif oModel:GetModel("NXXDETAIL"):IsDeleted()

			if NXX->(dbSeek(xFilial('NXX') + cFilial2 + cCajuri2 + cFilial1 + cCajuri1 ))
				Reclock( "NXX", .F. )
					dbDelete()
				MsUnLock()
			else
				lRet := .F.
			endif
		endif
	next

	RestArea( aAreaNXX )
	RestArea( aArea )

Return lRet 
