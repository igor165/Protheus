#Include "RESTFUL.CH"

#Include "TOTVS.CH"

#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"
#Include "COLORS.CH"
#Include "TBICONN.CH"
#Include "COMMON.CH"
#Include "XMLXFUN.CH"
#Include "fileio.ch"


#Include "FSCOM01C.CH"

#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

WSRESTFUL GETRESIDUES DESCRIPTION STR0012

WSDATA page AS INTEGER
WSDATA pageSize AS INTEGER

WSDATA sourceApp AS STRING
WSDATA companyId AS STRING
WSDATA branchId AS STRING

WSDATA movementType AS STRING

WSDATA movementInternalId AS STRING

WSMETHOD GET    DESCRIPTION STR0012 WSSYNTAX "/GETRESIDUES || /GETRESIDUES/{id}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE page, pageSize, sourceApp, companyId, branchId, movementType, movementInternalId WSSERVICE GETRESIDUES
	Local lMetodo := .F.

	Local cTempMov := ""
	Local lNew := .F.
	Local nTotal := 0
	Local nPages
	Local nPSize
	Local cMarca
	Local cEmpre
	Local cBranc
	Local lMovementType
	Local lMovementInternalId
	
	local itemnum := ''
	
	Local cComp := ''
	Local nLenComp := 0
	Local lCompact := .F.
	Local cQry := " "

	local jsreturn
	local jsdata
	local strJs
	
	Local aArrayMovimRet := {}
	Local aArrayItemMovim := {}
	
	Private bError         := { |e| oError := e, Break(e) }
	Private bErrorBlock    := ErrorBlock( bError )
	Private oError

	DEFAULT ::page 	 			     := 0
	DEFAULT ::pageSize 	 			 := 0
	DEFAULT ::sourceApp 	 		 := ''
	DEFAULT ::companyId 	 		 := ''
	DEFAULT ::branchId               := ''
	DEFAULT ::movementType           := ''
	DEFAULT ::movementInternalId 	 := ''
	
	BEGIN SEQUENCE

		nPages := ::page
		nPSize := ::pageSize
		cMarca := ::sourceApp
		cEmpre := ::companyId
		cBranc := ::branchId
		lMovementType := ::movementType
		lMovementInternalId     := ::movementInternalId

		if(Empty (cMarca))
			SetRestFault(400, STR0006)
			Return (lMetodo)
		endif
		
		aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

		If Len (aEmpre) < 2
			SetRestFault(400, STR0001 + cEmpre + STR0002 + cBranc + "' " + STR0005 + cMarca +"!")
			Return (lMetodo)
		EndIf

		If Len (aEmpre) > 1

			RESET ENVIRONMENT

			RPCSetType(3)

			PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "SC7", "SC1", "SCP", "DHN","SD1", "SF2", "SD2" MODULO "COM"

		EndIf

		cPdCVer          := RTrim(PmsMsgUVer('ORDER',                  'MATA120')) //Versão do Pedido de Compra
		cPrdVer		   := RTrim(PmsMsgUVer('ITEM','MATA010')) //Versão do Produto
		cSCoVer			:= RTrim(PmsMsgUVer('REQUEST',			'MATA110')) //Versão da Solicitação de Compra
		cSAoVer			:= RTrim(PmsMsgUVer('REQUEST',			'MATA105')) //Versão da Solicitação de Armazem
	
		fSetErrorHandler(STR0007)

		If TcGetDB() == "ORACLE"
			cBanco := "ORACLE"
		Else
			cBanco := "MSSQL"
		EndIf

		fResetErrorHandler()

		If ! fMandInfor(nPages,nPSize,cMarca,cEmpre,cBranc, lMovementType, lMovementInternalId)

			Return (lMetodo)

		EndIf

		cQry := fGetSQL(cBranc, cMarca, lMovementType, lMovementInternalId, nPages, nPSize, cBanco)

		If ! fReadSQL(cQry)
			Return (lMetodo)
		EndIf

		/*
		RETORNO REST
		RETORNO REST
		*/
		
		fSetErrorHandler(STR0008)

		// define o tipo de retorno do método
		::SetContentType("application/json")

		jsreturn := JsonObject():new()

		jsreturn['page']  := 1

		jsdata := JsonObject():new()

		jsreturn['pageSize'] := 1
		
		lNew := .F.
		
		nTotal := 0
		
		DBSelectArea("DAD")
		DBGoTop()
		Do While DAD->( !EOF() )

			nTotal += 0

			jsMovim := JsonObject():new()

			jsMovim['companyInternalId'] := cEmpAnt+'|'+RTrim(DAD->FILIAL)
			//jsMovim['documentType'] := DAD->ENTIDADE
			
			//jsMovim['recNo'] := DAD->RECNO

			If !Empty ( DAD->ITEMNUMBER )
				if(DAD->TYPE == 0)
					itemnum := IntSCoExt(/*cEmpresa*/, /*Filial*/, RTrim(DAD->NUMSC), RTrim(DAD->ITEMNUMBER), cSCoVer)[2]
					
					jsMovim['itemNumber'] := itemnum
				elseif(DAD->TYPE == 1)
					itemnum := IntPdCExt(/*Empresa*/, /*Filial*/, RTrim(DAD->NUMPC), RTrim(DAD->ITEMNUMBER), cPdCVer)[2]
					
					jsMovim['itemNumber'] := itemnum
				else
					itemnum := IntSArExt(/*Empresa*/, /*Filial*/, RTrim(DAD->NUMSA), RTrim(DAD->ITEMNUMBER), SToD(DAD->DATASA), cSAoVer)[2]
					
					
					jsMovim['itemNumber'] := itemnum
				endif
			EndIf
			
			
			If !Empty ( DAD->TYPE )
				jsMovim['type'] := DAD->TYPE
			EndIf

			If !Empty ( DAD->NUMSC )
				jsMovim['documentNumberSC'] := IntSCoExt(/*cEmpresa*/, /*Filial*/, RTrim(DAD->NUMSC), Nil, cSCoVer)[2]
			EndIf
			
			If !Empty ( DAD->NUMSA )
				jsMovim['documentNumberSA'] := IntSArExt(/*cEmpresa*/, /*Filial*/, RTrim(DAD->NUMSA), Nil, cSAoVer)[2]
			EndIf

			If !Empty ( DAD->NUMPC )
				jsMovim['documentNumberPC'] := IntPdCExt(/*Empresa*/, /*Filial*/, RTrim(DAD->NUMPC), Nil, cPdCVer)[2]
			EndIf

			If !Empty ( DAD->QUANTSC )
				jsMovim['quantitySC'] := DAD->QUANTSC
			EndIf

			If !Empty ( DAD->QUANTPC )
				jsMovim['quantityPC'] := DAD->QUANTPC
			EndIf

			If !Empty ( DAD->RESIDUOSC )
				jsMovim['residuoSC'] := RTrim(DAD->RESIDUOSC)
			else
				jsMovim['residuoSC'] := ""
			EndIf

			If !Empty ( DAD->RESIDUOPC )
				jsMovim['residuoPC'] := RTrim(DAD->RESIDUOPC)
			else
				jsMovim['residuoPC'] := ""
			EndIf

			If !Empty ( DAD->UNIT )
				jsMovim['unitofMeasureInternalId'] := IntUndExt(/*cEmpresa*/, /*cFilial*/, DAD->UNIT)[2]
			EndIf
			
			//internalid do item
			If !Empty ( DAD->ITEMNUMBER )
				jsMovim['itemInternalId'] := IntProExt(cEmpAnt,xFilial('SB1'),DAD->PRODUTO,cPrdVer)[2]
			EndIf
			
			If !Empty ( DAD->QUJESC )
				jsMovim['qujeSC'] := DAD->QUJESC
			EndIf

			If !Empty ( DAD->QUJEPC )
				jsMovim['qujePC'] := DAD->QUJEPC
			EndIf
			
			If !Empty ( DAD->QTD_DEV ) //SIMULA ATENDIMENTO COMPLETO DA sc É UMA BAIXA PARCIAL DO PEDIDO.
				
				If !Empty ( DAD->QUJEPC )
				 	jsMovim['qujePC'] :=  DAD->QUJEPC - DAD->QTD_DEV
				else
					jsMovim['qujePC'] :=  DAD->QUANTPC - DAD->QTD_DEV
				EndIf
			EndIf
				
			//vERIFICAR SE PRECISA BUSCAR SC8 COTAÇÃO
			If !Empty ( DAD->COTACAOSC )
				jsMovim['cotacaoSC'] := cEmpAnt + '|' + xFilial("SC7") + '|' + RTrim(DAD->COTACAOSC)
			EndIf

			If !Empty ( DAD->APROVSC )
				jsMovim['aprovSC'] := RTrim(DAD->APROVSC)
			EndIf

			If !Empty ( DAD->APROVPC )
				jsMovim['aprovPC'] := RTrim(DAD->APROVPC)
			EndIf
			
			If !Empty ( DAD->DATASA )
				jsMovim['DataSA'] := SToD(DAD->DATASA)
			EndIf

			AAdd(aArrayMovimRet, jsMovim )

			//nCurReg := DAD->ITEMNUMBER

			DBSelectArea("DAD")
			DBSkip()

		EndDo

		jsdata['movAssignments'] := aArrayMovimRet

		//jsreturn['total']  := nTotReg
		//jsreturn['hasNext']     := Iif(nCurReg >= nTotReg,.F.,.T.)

		jsreturn['data'] := jsdata

		jsreturn['SQL'] := cQry

		strJs := FWJsonSerialize(jsreturn,.T.,.T.)

		//If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		//	lCompact := .T.
		//EndIf

		If(lCompact)
			::SetHeader('Content-Encoding','gzip')
			GzStrComp(strJs, @cComp, @nLenComp )
		Else
			cComp := strJs
		Endif

		::SetResponse(cComp)

		/*
		RETORNO REST
		RETORNO REST
		*/

		fResetErrorHandler()

		lMetodo := .T.

		RECOVER
		ErrorBlock(bErrorBlock)
		SetRestFault(400, STR0011 + TAB + oError:Description)
		lMetodo := .F.
		Return (lMetodo)

	END SEQUENCE

	ErrorBlock( bErrorBlock )

Return (lMetodo )

/*
/*{Protheus.doc} fMandInfor
Function fMandInfor
@Uso    Verifica os campos obrigatórios no recebimento da mensagem REST
@Autor  Daniel de Paulo e Silva - TOTVS
@param  Campos recebidos da mensagem REST nPages,nPSize,cMarca,cEmpre, lMovementType, lMovementInternalId
@return	.T. -> Processo validado ; .F. -> Processo Interrompido

*/

Static Function fMandInfor(nPages,nPSize,cMarca,cEmpre,cBranc,cMovementType,cMovementInternalId)
	***************************************************************************************
	**
	**
	*****

	Local lPost := .F.
	Local cNum  := " "

	If nPages <= 0
		SetRestFault(400, STR0003 + "nPage" + STR0004)

	EndIf

	If nPSize <= 0
		SetRestFault(400, STR0003 + "pageSize" + STR0004)
		Return (lPost)
	EndIf

	If Empty(cMarca)
		SetRestFault(400, STR0003 + "sourceApp" + STR0004)
		Return (lPost)
	EndIf

	If Empty(cEmpre)
		SetRestFault(400, STR0003 + "companyId" + STR0004)
		Return (lPost)
	EndIf

	If Empty(cBranc)
		SetRestFault(400, STR0003 + "branchId" + STR0004)
		Return (lPost)
	EndIf

	If Empty(cMovementType)
		SetRestFault(400, STR0003 + "movementType" + STR0004)
		Return (lPost)
	EndIf

	If Empty(cMovementInternalId)
		SetRestFault(400, STR0003 + "movementInternalId" + STR0004)
		Return (lPost)
	EndIf
	
	if cMovementType == "0"
		cNum := RTrim(CFGA070Int(cMarca, "SC1", "C1_NUM", cMovementInternalId))
				
		If Empty(cNum)
			SetRestFault(400, STR0013 + " '" + cMovementInternalId + "'")
			Return (lPost)
		EndIf
	ELSEIF cMovementType == "1"
		cNum := RTrim(CFGA070Int(cMarca, "SC7", "C7_NUM", cMovementInternalId))
				
		If Empty(cNum)
			SetRestFault(400, STR0014 + " '" + cMovementInternalId + "'")
			Return (lPost)
		EndIf
	ELSEIF cMovementType == "2"
		cNum := RTrim(CFGA070Int(cMarca, "SCP", "CP_NUM", cMovementInternalId))
				
		If Empty(cNum)
			SetRestFault(400, "SOLICITAÇÃO DE ARMAZEM " + " '" + cMovementInternalId + "'")
			Return (lPost)
		EndIf
	else
		lPost := .F.
		
	EndIf
	
	
	lPost := .T.

Return (lPost)

/*
{Protheus.doc} fGetSQL
Function fGetSQL
@Uso    Prepara o arquivo de trabalho montado na query
@param  Marca, Tipo Movimento, InternalId Movimento, ItemInternalId
@return	Nenhum

@Autor  Daniel de Paulo e Silva - TOTVS
*/

Static Function fGetSQL(cBranch, cMarca, cMovementType,cMovementInternalId, nPages, nPSize, cBanco)
	Local sNomeTabelaSC := " "
	Local sNomeTabelaPC := " "
	Local sNomeTabelaDHN := " "
	Local sNomeTabelaSP := " "
	Local sNomeItem := " "
	Local cTemp := " "
	Local cNum := " "
	Local cQry := " "

	fSetErrorHandler(STR0009)

	DBSelectArea("SC7")
	DBSetOrder(1)
	DBSeek(xFilial("SC7"))

	DBSelectArea("SC1")
	DBSetOrder(1)
	DBSeek(xFilial("SC1"))

	If ! Empty(cMovementType)

		cQry += "SELECT TYPE,ITEMNUMBER,NUMSC,NUMSA,DATASA,QUANTSC,RESIDUOSC,QUJESC,COTACAOSC,APROVSC,NUMPC,QUANTPC,RESIDUOPC," + TAB
 		cQry += " QUJEPC,APROVPC,FILIAL,UNIT,PRODUTO,SUM(QTD_DEV) QTD_DEV FROM ( " + TAB

		sNomeTabelaDHN := "DHN"

		If 	cMovementType == "0"
			sNomeTabelaSC := "SC1"
			sNomeTabelaPC := "SC7"
			
			cTemp := RTrim(CFGA070Int(cMarca, "SC1", "C1_NUM", cMovementInternalId))
			
			if(!Empty(cTemp))
				cBranch = AllTrim(Separa(cTemp,"|")[2])
				cNum = AllTrim(Separa(cTemp,"|")[3])
			endif
			
			sNomeItem := "SOL.C1_ITEM"

			cQry += "SELECT 0 TYPE, SOL.C1_ITEM AS ITEMNUMBER, SOL.C1_NUM AS NUMSC,NULL AS NUMSA,NULL DATASA, SOL.C1_QUANT AS QUANTSC, SOL.C1_RESIDUO AS RESIDUOSC, SOL.C1_QUJE AS QUJESC, " + TAB
            cQry += "                 SOL.C1_COTACAO AS COTACAOSC, SOL.C1_APROV AS APROVSC, " + TAB
            cQry += "                 coalesce(PED.C7_NUM, ' ') AS NUMPC, coalesce(PED.C7_QUANT,0) AS QUANTPC, coalesce(PED.C7_RESIDUO,' ') AS RESIDUOPC, coalesce(PED.C7_QUJE,0) AS QUJEPC, " + TAB
            cQry += "                 coalesce(PED.C7_APROV, ' ') AS APROVPC, SOL.C1_FILIAL FILIAL, C1_UM UNIT, C1_PRODUTO PRODUTO,0 as QTD_DEV " + TAB
            cQry += "            FROM " + RetSqlName(sNomeTabelaSC) + " SOL (NOLOCK) " + TAB
            cQry += "                  LEFT JOIN " + RetSqlName(sNomeTabelaPC) + "  PED (NOLOCK) " + TAB
            cQry += "                    ON PED.C7_FILIAL = '"+xFilial("SC7")+"' AND SOL.C1_FILIAL = '"+xFilial("SC1")+"' " + TAB
            cQry += "                   AND PED.C7_NUMSC = SOL.C1_NUM " + TAB
            cQry += "                   AND PED.C7_ITEMSC = SOL.C1_ITEM " + TAB
            cQry += "                   AND PED.D_E_L_E_T_ <> '*' " + TAB
            cQry += "       WHERE " + TAB
            
            cQry += "          SOL.C1_NUM = '"+cNum+"' AND " + TAB 
            cQry += "          SOL.C1_FILIAL = '"+cBranch+"' AND " + TAB 
            
            //cQry += "            AND SOL.C1_ITEM LIKE '%' || :NUMITEMSC " + TAB
            cQry += "             SOL.D_E_L_E_T_ <> '*' " + TAB
            
            //EXISTS RetSqlName("AFG")? 
		ELSEIF (cMovementType == "1")
			sNomeTabelaSC := "SC1"
			sNomeTabelaPC := "SC7"
			
			cTemp := RTrim(CFGA070Int(cMarca, "SC7", "C7_NUM", cMovementInternalId))
			
			if(!Empty(cTemp))
				cBranch = AllTrim(Separa(cTemp,"|")[2])
				cNum = AllTrim(Separa(cTemp,"|")[3])
			endif
			
			sNomeItem := "PED.C7_ITEM"

			cQry += "SELECT 1 TYPE, PED.C7_ITEM AS ITEMNUMBER, SOL.C1_NUM AS NUMSC,NULL AS NUMSA,NULL DATASA, SOL.C1_QUANT AS QUANTSC, SOL.C1_RESIDUO AS RESIDUOSC, SOL.C1_QUJE AS QUJESC,  " + TAB
            cQry += "             SOL.C1_COTACAO AS COTACAOSC, SOL.C1_APROV AS APROVSC, " + TAB
            cQry += "             coalesce(PED.C7_NUM, ' ') AS NUMPC, coalesce(PED.C7_QUANT,0) AS QUANTPC, coalesce(PED.C7_RESIDUO,' ') AS RESIDUOPC, coalesce(PED.C7_QUJE,0) AS QUJEPC,  " + TAB
            cQry += "             coalesce(PED.C7_APROV, ' ') AS APROVPC, PED.C7_FILIAL FILIAL, C7_UM UNIT, C7_PRODUTO PRODUTO " + TAB
            cQry += "        FROM " + RetSqlName(sNomeTabelaPC) + " PED (NOLOCK) " + TAB
            cQry += "               LEFT JOIN " + RetSqlName(sNomeTabelaSC) + " SOL (NOLOCK) " + TAB
            cQry += "                 ON 1 = 2 " + TAB
            cQry += "       WHERE " + TAB
            
            cQry += "          PED.C7_NUM = '"+cNum+"' AND " + TAB 
            cQry += "          PED.C7_FILIAL = '"+cBranch+"' AND " + TAB 
            
	 		cQry += "          AND coalesce(PED.C7_RESIDUO, ' ') LIKE 'S'  " + TAB  
            //cQry += "         AND PED.C7_ITEM LIKE '%' + :NUMITEMPC " + TAB
            cQry += "          PED.D_E_L_E_T_ <> '*' " + TAB
            
            //EXISTS? RetSqlName("AJ7")
		ELSEIF (cMovementType == "2") // Busca pela solicitação de armazem
		
		    DBSelectArea("SCP")
		    DBSetOrder(1)
		    DBSeek(xFilial("SCP"))
		
		    DBSelectArea("DHN")
		    DBSetOrder(1)
		    DBSeek(xFilial("DHN"))
		    
			sNomeTabelaSP := "SCP"
			sNomeTabelaSC := "SC1"
			sNomeTabelaPC := "SC7"
			
			
			cTemp := RTrim(CFGA070Int(cMarca, "SCP", "CP_NUM", cMovementInternalId))
			
			if(!Empty(cTemp))
				cBranch = AllTrim(Separa(cTemp,"|")[2])
				cNum = AllTrim(Separa(cTemp,"|")[3])
			endif
			
			sNomeItem := "SCP.CP_ITEM"

			cQry += "SELECT 2 TYPE, SCP.CP_ITEM AS ITEMNUMBER, SOL.C1_NUM AS NUMSC, SCP.CP_NUM AS NUMSA,SCP.CP_EMISSAO DATASA, " + TAB
			cQry += "               (SOL.C1_QUANT) AS QUANTSC, SOL.C1_RESIDUO AS RESIDUOSC, " + TAB 
			cQry += "               (SOL.C1_QUJE) AS QUJESC, " + TAB
            cQry += "                 SOL.C1_COTACAO AS COTACAOSC, SOL.C1_APROV AS APROVSC, " + TAB
            cQry += "                 coalesce(PED.C7_NUM, ' ') AS NUMPC, coalesce(PED.C7_QUANT,0) AS QUANTPC, coalesce(PED.C7_RESIDUO,' ') AS RESIDUOPC, coalesce(PED.C7_QUJE,0) AS QUJEPC, " + TAB
            cQry += "                 coalesce(PED.C7_APROV, ' ') AS APROVPC, SOL.C1_FILIAL FILIAL, C1_UM UNIT, C1_PRODUTO PRODUTO,0 as QTD_DEV " + TAB
            cQry += "            FROM " + RetSqlName(sNomeTabelaSP) + " SCP (NOLOCK) " + TAB
            cQry += "         	    JOIN " + RetSqlName(sNomeTabelaDHN) + " RELAC ON " + TAB
			cQry += "         			RELAC.DHN_DOCORI = SCP.CP_NUM AND RELAC.DHN_ITORI = SCP.CP_ITEM " + TAB
			cQry += "            		AND RELAC.D_E_L_E_T_ <> '*' " + TAB
			cQry += "            		AND RELAC.DHN_FILORI = '"+xFilial("SCP")+"' " + TAB
			cQry += "               LEFT JOIN "+RetSqlName(sNomeTabelaSC)+"  SOL (NOLOCK)  " + TAB
            cQry += "                 ON SOL.C1_FILIAL = '"+xFilial("SC1")+"' AND " + TAB
			cQry += "            		 RELAC.DHN_DOCDES = SOL.C1_NUM  " + TAB
			cQry += "            		AND RELAC.DHN_ITDES = SOL.C1_ITEM " + TAB
			cQry += "            		AND SCP.D_E_L_E_T_ <> '*' AND RELAC.DHN_FILDES = '"+xFilial("SC1")+"' " + TAB
            cQry += "               LEFT JOIN "+RetSqlName(sNomeTabelaPC)+"  PED (NOLOCK)  " + TAB
            cQry += "                 ON PED.C7_FILIAL = '"+xFilial("SC7")+"' AND SOL.C1_FILIAL = '"+xFilial("SC1")+"' AND " + TAB
            cQry += "            	PED.C7_NUMSC = SOL.C1_NUM  " + TAB
            cQry += "               AND PED.C7_ITEMSC = SOL.C1_ITEM  " + TAB
            cQry += "              	AND PED.D_E_L_E_T_ <> '*'          " + TAB
            
            cQry += "        WHERE  SCP.CP_NUM = '"+cNum+"' AND " + TAB 
            cQry += "          SCP.CP_FILIAL = '"+cBranch+"' AND " + TAB 
            
            //cQry += "         AND PED.C7_ITEM LIKE '%' + :NUMITEMPC " + TAB
            cQry += "          SCP.D_E_L_E_T_ <> '*' " + TAB
            
		EndIf

		//Soma devoluções na resposta -- Como eliminações de Pedidos.
		cQry += + TAB + " UNION " + TAB

		cQry +=	" SELECT '"+cMovementType+"' TYPE, "+sNomeItem+" AS ITEMNUMBER, SOL.C1_NUM AS NUMSC,SCP.CP_NUM AS NUMSA,SCP.CP_EMISSAO DATASA,  " + TAB
		cQry +=	" SOL.C1_QUANT AS QUANTSC, SOL.C1_RESIDUO AS RESIDUOSC, SOL.C1_QUJE AS QUJESC, " + TAB  
        cQry +=	" SOL.C1_COTACAO AS COTACAOSC, SOL.C1_APROV AS APROVSC,   " + TAB
        cQry +=	" coalesce(SC7.C7_NUM, ' ') AS NUMPC, coalesce(SC7.C7_QUANT,0) AS QUANTPC, " + TAB
		cQry +=	" 'S' AS RESIDUOPC, coalesce(SC7.C7_QUJE,0) AS QUJEPC,   " + TAB
        cQry +=	" coalesce(SC7.C7_APROV, ' ') AS APROVPC, SOL.C1_FILIAL FILIAL, C1_UM UNIT, C1_PRODUTO PRODUTO, " + TAB
		cQry +=	"  SD2.D2_QUANT QTD_DEV   " + TAB
	  	cQry +=	" FROM	"+RetSqlName("SD2") + " SD2 (NOLOCK) " + TAB
	  	cQry +=	" INNER JOIN "+RetSqlName("SD1") + " SD1   (NOLOCK) " + TAB 
	 	cQry +=	" 	ON  SD1.D1_FILIAL = '"+xFilial("SD1")+"'   " + TAB 
		cQry +=	" 	AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'   " + TAB 
	 	cQry +=	" 	AND SD2.D2_NFORI    = SD1.D1_DOC   " + TAB 
	 	cQry +=	" 	AND SD2.D2_SERIORI  = SD1.D1_SERIE   " + TAB 
	 	cQry +=	" 	AND SD2.D2_ITEMORI  = SD1.D1_ITEM   " + TAB 
	 	cQry +=	" 	AND SD2.D2_CLIENTE  = SD1.D1_FORNECE   " + TAB 
	 	cQry +=	" 	AND SD2.D2_LOJA		= SD1.D1_LOJA   " + TAB 
	 	cQry +=	" 	AND SD2.D_E_L_E_T_ <> '*'  " + TAB 

      	cQry +=	" 	LEFT JOIN  "+RetSqlName("SC7") + "  SC7  (NOLOCK) ON SC7.C7_FILIAL = '"+xFilial("SC7")+"'    " + TAB 
	  	cQry +=	" 	   AND SD1.D1_PEDIDO = SC7.C7_NUM   " + TAB 
	  	cQry +=	" 	   AND SD1.D1_ITEMPC = SC7.C7_ITEM 	 " + TAB 
	  	cQry +=	" 	   AND SD1.D1_FORNECE = SC7.C7_FORNECE  " + TAB 
	  	cQry +=	" 	   AND SD1.D1_LOJA = SC7.C7_LOJA  " + TAB 
	  	cQry +=	" 	   AND SD1.D1_COD = SC7.C7_PRODUTO  " + TAB 

      	cQry +=	" 	LEFT JOIN "+RetSqlName("SC1") + " SOL (NOLOCK)  ON SOL.C1_FILIAL = '"+xFilial("SC1")+"'  " + TAB 
	  	cQry +=	" 			AND SOL.C1_NUM = SC7.C7_NUMSC   " + TAB 
	  	cQry +=	" 			AND SOL.C1_ITEM = SC7.C7_ITEMSC   " + TAB 
	  	cQry +=	" 			AND SOL.C1_PRODUTO = SC7.C7_PRODUTO  " + TAB 
	  	cQry +=	" 			AND SOL.D_E_L_E_T_ <> '*'   " + TAB 

		cQry += "   LEFT JOIN " + RetSqlName(sNomeTabelaDHN) + " DHN ON " + TAB
		cQry += "   	DHN.DHN_DOCDES = SOL.C1_NUM AND DHN.DHN_ITDES = SOL.C1_ITEM " + TAB
		cQry += "   	AND DHN.D_E_L_E_T_ <> '*' " + TAB
		cQry += "   	AND DHN.DHN_FILORI = '"+xFilial("DHN")+"' " + TAB
		
	  	cQry +=	" 	LEFT JOIN "+RetSqlName("SCP") + " SCP (NOLOCK) ON " + TAB 
	   	cQry +=	" 		SCP.CP_NUM = DHN.DHN_DOCORI AND SCP.CP_ITEM = DHN.DHN_ITORI  " + TAB 
	  	cQry +=	" 		AND SCP.D_E_L_E_T_ <> '*'   " + TAB 
		  
		cQry +=	" 	  INNER JOIN "+RetSqlName("SF2") + "  SF2  (NOLOCK)  " + TAB 
	  	cQry +=	" 			ON  SF2.F2_FILIAL	= SD2.D2_FILIAL   " + TAB 
	  	cQry +=	" 			AND SF2.F2_DOC      = SD2.D2_DOC  " + TAB 
	  	cQry +=	" 			AND SF2.F2_SERIE    = SD2.D2_SERIE  " + TAB 
	  	cQry +=	" 			AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE   " + TAB 
	  	cQry +=	" 			AND SF2.F2_LOJA		= SD2.D2_LOJA  " + TAB 
	  	cQry +=	" 			AND SF2.D_E_L_E_T_ <> '*' 	 " + TAB 
	    cQry +=	" WHERE	 " + TAB 
	  	cQry +=	" SD2.D2_TES <> '   '  " + TAB 
	    cQry +=	" AND		SD2.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*'  " + TAB 

		If 	cMovementType == "0"
 			cQry += "  AND  SOL.C1_NUM = '"+cNum+"' AND " + TAB 
            cQry += "       SOL.C1_FILIAL = '"+xFilial("SC1")+"' AND " + TAB 
            cQry += "       SOL.D_E_L_E_T_ <> '*' " + TAB
		elseIf 	cMovementType == "1"
			cQry += " AND  SC7.C7_NUM = '"+cNum+"' AND " + TAB 
            cQry += "      SC7.C7_FILIAL = '"+xFilial("SC7")+"' AND " + TAB 
            cQry += "      SC7.D_E_L_E_T_ <> '*' " + TAB
		else
			cQry +=	" AND SCP.CP_NUM = '"+cNum+"' AND " + TAB 
            cQry += " SCP.CP_FILIAL = '"+xFilial("SCP")+"' " + TAB 
		endif

		cQry +=	" ) AS ELIMINACAO_DEVOLUCOES " + TAB 
  		cQry +=	" GROUP BY  " + TAB 
  		cQry +=	" TYPE,ITEMNUMBER,NUMSC,NUMSA,DATASA,QUANTSC,RESIDUOSC,QUJESC,COTACAOSC,APROVSC,NUMPC,QUANTPC,RESIDUOPC, " + TAB 
  		cQry +=	" QUJEPC,APROVPC,FILIAL,UNIT,PRODUTO " + TAB 

	EndIf
	
	**
	Return (cQry)
	**


	Static Function fReadSQL(cQry)

	cQry = ChangeQuery(cQry)

	fCloseDados("DAD")

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "DAD", .T., .T. )

	fResetErrorHandler()

	**
	Return (.T.)
	**

/*
{Protheus.doc} fCloseDados
Function fCloseDados
@Uso    Fecha um arquivo de trabalho
@param  Arquivo de trabalho
@return	Nenhum

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function fCloseDados (cDados)

	fSetErrorHandler(STR0010)

	If Select(cDados) > 0
		dbSelectArea(cDados)
		dbCloseArea()
	EndIf

	fResetErrorHandler()

Return (.T.)

/*
{Protheus.doc} fSetErrorHandler
Function fSetErro
@Uso    Seta código e mensagem de erro
@param  Objeto de erro
@return	Nenhum

@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function fSetErrorHandler(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)

/*
{Protheus.doc} fResetErrorHandler
Function fSetErro
@Uso    Seta código e mensagem de erro
@param  Objeto de erro
@return	Nenhum

@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)
