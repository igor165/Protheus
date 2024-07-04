#include 'PROTHEUS.CH'
#include 'FINA891.CH'
#include 'FWMVCDEF.CH'

Static __lMotRet	:= Nil
Static __lPccBaix  	:= Nil
Static __nCtrlFo1  	:= Nil
Static __nCtrlFo2  	:= Nil
Static __oFIN8912  	:= Nil 
Static __oFIN8913  	:= Nil
Static __oFwBrw    	:= Nil
Static oBrowse     	:= Nil
Static oPnlAux     	:= Nil
Static oTPanel     	:= Nil
Static __aEmp		:= Nil
Static aBanSel		:= Nil
Static aTitSel		:= Nil
Static aDdsEdit		:= Nil
Static nCtrPrev		:= Nil
Static oStepWiz		:= Nil
Static o1stPage		:= Nil
Static o2ndPage		:= Nil
Static o3rdPage		:= Nil
Static o4thPage		:= Nil
Static o5thPage		:= Nil
Static o6thPage		:= Nil
Static lVldRep		:= Nil
Static oMrkTitle	:= Nil
Static cTrabF71		:= Nil
Static __nTotReg	:= Nil
Static cTraDF71		:= Nil
Static __nCasasDc   := Nil

/*/{Protheus.doc} FINA891
Wizard Transmissão do PIX

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Function FINA891()

	Local aArea		As Array

	Private aDadBcoPix As Array
	Private lPixAPI    As Logical

	aBanSel		:= {}
	aTitSel		:= {}
	aDdsEdit	:= {}
	aDadBcoPix  := {}
	nCtrPrev	:= 0
	aArea		:= GetArea()
	lPixAPI     := APIPIXOn()
	
	If !LockByName("FINA891", .T., .F.)
		MsgStop(STR0048, STR0050) // Semáforo já existente, função não pode ser executada!  ### 'Atenção'
		Return
	EndIf

	If !TableInDic("F70") .Or. !TableInDic("F71")
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf
	
	If !IsBlind() .And. GetHlpLGPD({"A1_NOME", "F71_NOMCLI"})
		Return .F.
	EndIf

	If ExistPix()
		//Encapsulamento da função que cria o wizard
		FA891WIZ()
	Else
		Help(,,"F891NOTIT",,STR0053,1,0)   //"Não existem títulos para geração e/ou cancelamento"
	EndIf

	UnlockByName("FINA891", .T., .F., .F.)

	RestArea(aArea)

Return

/*/{Protheus.doc} FA891WIZ
Rotina para construção do wizard da Transmissão PIX

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function FA891WIZ()

	//Inicialização das variáveis
	__nCtrlFo1 	:= 1
	__nCtrlFo2 	:= 0
	__nTotReg 	:= 0

	lVldRep		:= .F.

	oStepWiz := FwWizardControl():New(,{600,850})//Instancia a classe FwWizardControl
	oStepWiz:ActiveUISteps()

	// Pagina 1
	o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel|Cria_Pn1(Panel)}) // Adiciona um Step
	o1stPage:SetStepDescription(STR0001) // Início
	o1stPage:SetNextTitle(STR0002) // Avançar
	o1stPage:SetNextAction({||.T.}) // Define o bloco ao clicar no botão Avançar
	o1stPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

	// Pagina 2
	o2ndPage := oStepWiz:AddStep("2RDSTEP", {|Panel|Cria_Pn2(Panel)})
	o2ndPage:SetStepDescription(STR0003)  //   "Seleção de Bancos"
	o2ndPage:SetNextTitle(STR0002)  // Avançar
	o2ndPage:SetNextAction({|| Valid_PG2()})
	o2ndPage:SetCancelAction({|| BtnCancel()})
	o2ndPage:SetPrevWhen({||.F.})

	// Pagina 3
	o3rdPage := oStepWiz:AddStep("3RDSTEP", {|Panel|Cria_Pn3(Panel, __nCtrlFo1, __nCtrlFo2)})
	o3rdPage:SetStepDescription(STR0004)  //   "Seleção de títulos"
	o3rdPage:SetNextTitle(STR0002)  // Avançar
	o3rdPage:SetNextAction({|| FINA891A02(aDdsEdit, __nCtrlFo1 ) })
	o3rdPage:SetCancelAction({|| BtnCancel()})
	o3rdPage:SetPrevWhen({||.F.})

	// Pagina 4
	o4thPage := oStepWiz:AddStep("4THSTEP", {|Panel|Cria_Pn4(Panel, __nTotReg)})
	o4thPage:SetStepDescription(STR0005) //Cancelamentos
	o4thPage:SetNextTitle(STR0002)  // Avançar
	o4thPage:SetNextAction({||.T.}) // Define o bloco ao clicar no botão Avançar
	o4thPage:SetCancelAction({|| BtnCancel()})
	o4thPage:SetPrevWhen({||.F.})
	
	// Pagina 5	
	o5thPage := oStepWiz:AddStep("5THSTEP", {|Panel|Cria_Pn5(Panel)})
	o5thPage:SetStepDescription(STR0006) // Geração de arquivos
	o5thPage:SetNextTitle(STR0002)
	o5thPage:SetNextAction({|| Valid_PG5()})
	o5thPage:SetCancelAction({|| BtnCancel()})
	o5thPage:SetPrevWhen({||.F.})

	// Pagina 6
	o6thPage := oStepWiz:AddStep("6THSTEP", {|Panel|Cria_Pn6(Panel)})
	o6thPage:SetStepDescription(STR0007) // Conclusão
	o6thPage:SetNextTitle(STR0007)	// Conclusão
	o6thPage:SetNextAction({||.T.})
	o6thPage:SetCancelAction({||.F.})
	o6thPage:SetPrevWhen({||.F.})

	oStepWiz:Activate()

	// Limpa Tabelas Temporarias
	ClearTMP()

	//Limpa Variaveis Staticas
	__nCtrlFo1	:= Nil
	__oFwBrw	:= Nil
	FreeObj(oBrowse)
	FreeObj(oPnlAux)
	FreeObj(oStepWiz)

Return

// Início dos blocos de construçãos das páginas de cada step

/*/{Protheus.doc} Cria_Pn1
Função para construção da primeira página do wizard

@param oPanel 

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Cria_Pn1( oPanel As Object )
	Local oFont As Object

	oFont := TFont():New(,,-25,.T.,.T.,,,,,)

	TSay():New(10,15,{|| STR0008},oPanel,,oFont,,,,.T.,CLR_BLUE,)	// Geração de CNAB PIX – Contas a Receber
	TSay():New(35,10,{|| STR0009},oPanel,,,,,,.T.,CLR_BLUE,) 	 	// Clique em “Avançar” para:
	TSay():New(45,15,{|| STR0010},oPanel,,,,,,.T.,CLR_BLUE,) 	 	// - Selecionar bancos
	TSay():New(55,15,{|| STR0011},oPanel,,,,,,.T.,CLR_BLUE,) 		// - Selecionar títulos dos respectivos bancos
	TSay():New(65,15,{|| STR0012},oPanel,,,,,,.T.,CLR_BLUE,) 		// - Visualizar cancelamentos relacionados aos bancos
	TSay():New(75,15,{|| STR0013},oPanel,,,,,,.T.,CLR_BLUE,)	 	// - Gerar arquivos
	TSay():New(95,10,{|| STR0014},oPanel,,,,,,.T.,CLR_BLUE,) 	 	// Ao final do processo, os arquivos CNAB PIX serão disponibilizados para envio

Return

/*/{Protheus.doc} cria_pn2
Função para construção da Segunda página do wizard

@param oPanel 

@author Adriano Sato
@since  05/11/2020
@version 12.1.27
/*/
Static Function Cria_Pn2( oPanel As Object )

	Local oBrwF70   As Object
	Local aDdsEdit  As Array
	Local aStruct	As Array
	Local aColumns	As Array
	Local aCmbTpChv	As Array
	Local aBoxSX3	As Array
	Local aBoxF71	As Array
	Local aBoTMP	As Array
	Local aCmbChv	As Array
	Local cQryF70	As Character
	Local cQry1		As Character
	Local cAlsF70	As Character
	Local cAls1		As Character
	Local cItem 	As Character
	Local cDesc 	As Character
	Local cEditCel	As Character
	Local CTpChave 	As Character
	Local cData 	As Character
	Local cHora 	As Character
	Local cMinuto 	As Character
	Local cArqCfg 	As Character
	Local cArqSai 	As Character
	Local nX 		As Numeric

	oBrwF70 	:= Nil

	aCmbChv 	:= {}
	aCmbTpChv 	:= {}
	aDdsEdit 	:= {}
	aStruct		:= {}
	aColumns	:= {}
	aDadBcoPix  := {}

	cEditCel 	:= ""
	cTpChave 	:= ""
	cItem 		:= ""
	cDesc 		:= ""
	cArqCfg 	:= ""
	cArqSai 	:= ""
	cData 		:= DToS(Date())
	cHora 		:= SubStr(Time(),1,2)
	cMinuto 	:= SubStr(Time(),4,2)
	cFilePath 	:= AllTrim(SuperGetMV("MV_LOCENV", .F., .F.))

	cAlsF70 	:= GetNextAlias()
	cAls1 		:= GetNextAlias()

	aBoxF71 	:= SX3Box2Arr( "F70_TPCHV" , @aBoxSX3 )
	
	If Empty(ATail(aBoxF71))
		ASize(aBoxF71, Len(aBoxF71)-1)
	EndIf

	For nX := 1 To Len(aBoxF71)
		aBoTMP := StrTokArr2( aBoxF71[nX], "=", .T. )
		cItem := aBoTMP[1]
		cDesc := aBoTMP[2]

		AAdd(aCmbTpChv, {cItem, cDesc} )
		AAdd(aCmbChv, cDesc )
	Next nX

	cQryF70	:= " SELECT F70_COD, F70_AGENCI, F70_DVAGE, F70_NUMCON, F70_DVCTA, F70_TPCHV, F70_CHVPIX, ISNULL(EE_SUBCTA, '') AS EE_SUBCTA, ISNULL(EE_EXTEN, '') AS EE_EXTEN, EE_FILIAL "
	cQryF70	+= "    FROM " + RetSQLName("F70") + " F70 "
	cQryF70	+= "       INNER JOIN " + RetSQLName("SEE") + " SEE "
	cQryF70	+= " 	      ON SEE.D_E_L_E_T_ = ' ' "
	cQryF70	+= " 	     And SEE.EE_FILIAL = '" + xFilial("SEE") + "' "
	cQryF70	+= " 	     AND SEE.EE_CODIGO = F70.F70_COD "
	cQryF70	+= " 		 AND SEE.EE_AGENCIA = F70.F70_AGENCI "
	cQryF70	+= " 		 AND SEE.EE_DVAGE = F70.F70_DVAGE "
	cQryF70	+= " 		 AND SEE.EE_CONTA = F70.F70_NUMCON "
	cQryF70	+= " 		 AND SEE.EE_DVCTA = F70.F70_DVCTA "
	cQryF70	+= " 		 AND SEE.EE_NRBYTES = 750 "
	cQryF70	+= "    WHERE F70.D_E_L_E_T_ = ' ' "
	cQryF70	+= "      AND F70.F70_FILIAL = '" + xFilial("F70") + "' "
	cQryF70	+= "      AND F70.F70_ACTIVE = '1' "
	cQryF70	+= "    ORDER BY F70_COD, F70_AGENCI, F70_DVAGE, F70_NUMCON, F70_DVCTA"

	cQryF70 := ChangeQuery(cQryF70)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQryF70), cAlsF70)

	While !(cAlsF70)->(Eof())

		cArqCfg := GetSrvProfString("StartPath", "")+(cAlsF70)->F70_COD+"_PIX.REM"
		
		// Verifica se o arquivo de configuração existe no diretório corrente do servidor
		If File(Upper(cArqCfg)) .Or. File(Lower(cArqCfg)) 
			cArqCfg := Pad( cArqCfg,50 )
		Else
			cArqCfg := Space(50)
		EndIf

		cArqSai := Pad( FindFile( cFilePath, (cAlsF70)->F70_COD + "_" + cData + cHora + cMinuto + "." + (cAlsF70)->EE_EXTEN, aDdsEdit ),50 )

		AAdd(aDdsEdit,{ .F.																				,;
						(cAlsF70)->F70_COD																,;
						(cAlsF70)->( AllTrim(F70_AGENCI) + "-" + F70_DVAGE)								,;
						(cAlsF70)->( AllTrim(F70_NUMCON) + "-" + F70_DVCTA)								,;
						(cAlsF70)->EE_SUBCTA															,;
						AllTrim( aCmbTpChv[AScan(aCmbTpChv,{|x| x[1] == (cAlsF70)->F70_TPCHV})][2] ) 	,;
						AllTrim( (cAlsF70)->F70_CHVPIX ) 												,;
						cArqCfg 													 					,;
						cArqSai 																		})

		AAdd(aDadBcoPix, {(cAlsF70)->EE_FILIAL, (cAlsF70)->F70_TPCHV })  //FILIAL, TIPO DE CHAVE, CHAVE PIX

		(cAlsF70)->(DbSkip())
	EndDo

	If Len(aDdsEdit) == 0

		cQry1 := " SELECT COUNT(*) AS TOTCHV "
		cQry1 += "    FROM " + RetSQLName("F70") + " F70 "
		cQry1 += "    WHERE F70.D_E_L_E_T_ = ' ' "
		cQry1 += "      AND F70.F70_FILIAL = '" + xFilial("F70") + "' "
		cQry1 += "      AND F70.F70_ACTIVE = '1' "

		cQry1 := ChangeQuery(cQry1)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry1), cAls1)

		If (cAls1)->TOTCHV = 0
			Help(,,"F891NOCHVATV",,STR0051,1,0) 		// "Não existem bancos com chave PIX principal"
		Else
			Help(,,"F891NOPARBCO",,STR0052,1,0) 		// "Não existem parâmetros de bancos configurado para PIX"
		EndIf
		(cAls1)->(DbCloseArea())
		Return .F.
	EndIf

	AAdd( aStruct, "MARK" 	  )
	AAdd( aStruct, "BANCO"    )
	AAdd( aStruct, "AGENCIA"  )
	AAdd( aStruct, "CONTA"    )
	AAdd( aStruct, "SUBCONTA" )
	AAdd( aStruct, "TPCHAVE"  )
	AAdd( aStruct, "CHAVEPIX" )
	AAdd( aStruct, "ARQCFG"   )
	AAdd( aStruct, "ARQSAI"   )

	oBrwF70 := FwBrowse():New(oPanel)
	oBrwF70:SetDataArray()
	oBrwF70:SetDescription(STR0003) 	// 'Seleção de bancos'
	oBrwF70:SetArray(aDdsEdit)

	For nX := 1 To Len(aStruct)
		If	aStruct[nX] == "BANCO"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][2] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "F70_COD", "X3_TAMANHO" ) )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "F70_COD", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "F70_COD", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "F70_COD", "X3_PICTURE" ) )
		ElseIf	aStruct[nX] == "AGENCIA"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][3] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "F70_AGENCI", "X3_TAMANHO" ) )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "F70_AGENCI", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "F70_AGENCI", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "F70_AGENCI", "X3_PICTURE" ) )
		ElseIf	aStruct[nX] == "CONTA"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][4] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "F70_NUMCON", "X3_TAMANHO" )+2 )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "F70_NUMCON", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "F70_NUMCON", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "F70_NUMCON", "X3_PICTURE" ) )
		ElseIf	aStruct[nX] == "SUBCONTA"
			cEditCel := "VlrNew"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][5] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "EE_SUBCTA", "X3_TAMANHO" ) )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "EE_SUBCTA", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "EE_SUBCTA", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "EE_SUBCTA", "X3_PICTURE" ) )
			aColumns[Len(aColumns)]:SetEdit(.T.)
			aColumns[Len(aColumns)]:SetReadVar( cEditCel )
		ElseIf	aStruct[nX] == "TPCHAVE"
			cEditCel := "VlrNew"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][6] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "F70_TPCHV", "X3_TAMANHO" ) )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "F70_TPCHV", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "F70_TPCHV", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "F70_TPCHV", "X3_PICTURE" ) )
			aColumns[Len(aColumns)]:SetEdit(.T.)
			aColumns[Len(aColumns)]:SetReadVar( cEditCel )
			aColumns[Len(aColumns)]:SetOptions( aCmbChv )
		ElseIf	aStruct[nX] == "CHAVEPIX"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][7] } )
			aColumns[Len(aColumns)]:SetSize( GetSx3Cache( "F70_CHVPIX", "X3_TAMANHO" )+2 )
			aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache( "F70_CHVPIX", "X3_DECIMAL" ) )
			aColumns[Len(aColumns)]:SetTitle( GetSx3Cache( "F70_CHVPIX", "X3_TITULO" ) )
			aColumns[Len(aColumns)]:SetPicture( GetSx3Cache( "F70_CHVPIX", "X3_PICTURE" ) )
		ElseIf	aStruct[nX] == "ARQCFG"
			cEditCel := "VlrNew"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][8] } )
			aColumns[Len(aColumns)]:SetSize( 50 )
			aColumns[Len(aColumns)]:SetDecimal( 0 )
			aColumns[Len(aColumns)]:SetTitle( STR0035 ) 	// 'Arquivo de Configuração'
			aColumns[Len(aColumns)]:SetPicture( "@!" )
			aColumns[Len(aColumns)]:SetEdit(.T.)
			aColumns[Len(aColumns)]:SetReadVar( cEditCel )
		ElseIf	aStruct[nX] == "ARQSAI"
			cEditCel := "VlrNew"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( {|| aDdsEdit[oBrwF70:nAt][9] } )
			aColumns[Len(aColumns)]:SetSize( 50 )
			aColumns[Len(aColumns)]:SetDecimal( 0 )
			aColumns[Len(aColumns)]:SetTitle( STR0036 ) 	// 'Arquivo de Saída'
			aColumns[Len(aColumns)]:SetPicture( "@!" )
			aColumns[Len(aColumns)]:SetEdit(.T.)
			aColumns[Len(aColumns)]:SetReadVar( cEditCel )
		EndIf
		
	Next nX

	oBrwF70:AddMarkColumns({|| If(aDdsEdit[oBrwF70:nAt][1], 'LBOK', 'LBNO') }, {|| F70MarkDM( oBrwF70 ) }, {|| F70MarlAll( oBrwF70 ), oBrwF70:Refresh() })
	oBrwF70:SetColumns(aColumns)
	oBrwF70:SetEditCell(.T., {|A,B| ChvEdit(A,B, aCmbTpChv)})

	oBrwF70:DeActivate()
	oBrwF70:Activate()

	oBrwF70:Refresh()

Return

/*/{Protheus.doc} cria_pn3
Função para construção da Terceira página do wizard

@param oPanel 

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Cria_Pn3(oPanel As Object, __nCtrlFo1 As Numeric, __nCtrlFo2 As Numeric)
	Local aStruc11		As Array
	Local cQuery		As Character
	Local cIndex		As Character
	Local cChave		As Character

	If __nCtrlFo2 == 0
		Default __nCtrlFo1 := 1

		//Inicialização das variáveis
		aStruc11	:= F71->(DbStruct()) // Carrego a estrutura da tabela de títulos a receber
		cQuery		:= ""
		cIndex		:= ""
		cChave		:= ""
		nCtrPrev	:= Len(aBanSel)

		cIndex := 'F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO+F71_CODCLI+F71_LOJCLI'

		cQuery += " SELECT F71_FILIAL, F71_PREFIX, F71_NUM, F71_PARCEL, F71_TIPO, F71_CODCLI, F71_LOJCLI, "
		cQuery += " F71_VALOR, F71_VENCTO, F71_CODBAN, F71_AGENCI, F71_NUMCON, F71_SEQ, F71_IDTRAN,  "
		cQuery += " F71_EMISSA, F71_SOLCAN, F71_STATUS FROM " + RetSqlName('F71') + " F71 "
		cQuery += " WHERE F71.F71_FILIAL = '" + FWxFilial('F71') + "' "
		cQuery += " AND F71.F71_STATUS = '1' " // 1 - A TRANSMITIR ; 2 - ENVIADO ; 3 - QR GERADO ; 4 - CLIENTE NOTIFICADO ; 5 - CONFIRMADO PAGO ; 6 - CANCELAMENTO SOLICITADO ; 7 - CANCELADO
		cQuery += " AND F71.F71_SOLCAN IN ('2',' ') " // 1 - SIM ; 2 - NAO
		cQuery += " AND F71.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY "+ SqlOrder(cIndex)

		cQuery := ChangeQuery(cQuery)

		AAdd(aStruc11, {"MARK"    ,"C",02,0})  // Adiciono o campo de marca

		If __oFIN8912 <> Nil
			__oFIN8912:Delete()
			__oFIN8912 := Nil
		EndIf

		cTrabF71 := GetNextAlias()

		__oFIN8912 := FwTemporaryTable():New(cTrabF71)
		__oFIN8912:SetFields(aStruc11)
		__oFIN8912:AddIndex("1", {"F71_NUM"})

		//Criando a Tabela Temporaria
		__oFIN8912:Create()

		MsgRun(STR0023,STR0008,{|| SqlToTrb(cQuery, aStruc11, cTrabF71)}) // Gerando relação de títulos / Geração de CNAB PIX – Contas a Receber

		(cTrabF71)->( DbSetOrder(0) ) 		// Fica na ordem da query
		
		__nTotReg := (cTrabF71)->(RECCOUNT())
		aDdsEdit  := {}
		aDdsEdit  := AClone(aBanSel)
	EndIf
	
	If __nTotReg > 0
		FINA891A01(aDdsEdit, oPanel, __nCtrlFo1, nCtrPrev, cTrabF71 )
	Else
		oStepWiz:NextPage()
	EndIf
Return

/*/{Protheus.doc} cria_pn4
Função para construção da Quarta página do wizard

@param oPanel 

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Cria_Pn4( oPanel As Object, __nTotReg As Numeric )
	Local aStruct2		As Array
	Local aStrCan 		As Array
	Local cQuery		As Character
	Local cIndex		As Character
	Local aColumn2		As Array
	Local nX			As Numeric
	Local nTotCancel	As Numeric
	Local cACodban 		As Character
	Local cAAgenci		As Character
	Local cANumCon 		As Character
	Local cNomBan 		As Character

	Default oPanel 		:= Nil
	Default __nTotReg := 0

	//Inicialização das variáveis
	aStruct2	:= F71->(DbStruct()) // Carrego a estrutura da tabela monitor PIX
	cQuery		:= ""
	cIndex		:= ""
	aColumn2	:= {}
	nX			:= 0
	nTotCancel		:= 0
	cACodban 	:= ""
	cAAgenci	:= ""
	cANumCon 	:= ""
	cNomBan		:= ""

	cIndex := 'F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO+F71_CODCLI+F71_LOJCLI'

	cQuery += " SELECT F71_FILIAL, F71_PREFIX, F71_NUM, F71_PARCEL, F71_TIPO, F71_CODCLI, F71_LOJCLI, "
	cQuery += " F71_VALOR, F71_VENCTO, F71_CODBAN, F71_AGENCI, F71_NUMCON, F71_SEQ, F71_IDTRAN,  "
	cQuery += " F71_EMISSA, F71_SOLCAN, F71_STATUS FROM " + RetSqlName('F71') + " F71 "
	cQuery += " WHERE F71.F71_FILIAL = '" + FwXFilial('F71') + "' "

	For nX := 1 To Len(aBanSel)
		If nX == 1
			cACodban := "'" + aBanSel[nX][1]  + "'"
			cAAgenci := "'" + aBanSel[nX][2]  + "'"
			cANumCon := "'" + aBanSel[nX][3]  + "'"
		Else
			cACodban := cACodban + ",'" + aBanSel[nX][1]  + "'"
			cAAgenci := cAAgenci + ",'" + aBanSel[nX][2]  + "'"
			cANumCon := cANumCon + ",'" + aBanSel[nX][3]  + "'"
		EndIf
	next nX

	cQuery += " AND F71.F71_CODBAN IN (" + cACodban + ") "
	cQuery += " AND F71.F71_AGENCI IN (" + cAAgenci + ") "
	cQuery += " AND F71.F71_NUMCON IN (" + cANumCon + ") "
	cQuery += " AND F71.F71_STATUS IN ('3','4') " // 1 - A TRANSMITIR ; 2 - ENVIADO ; 3 - QR GERADO ; 4 - CLIENTE NOTIFICADO ; 5 - CONFIRMADO PAGO ; 6 - CANCELAMENTO SOLICITADO ; 7 - CANCELADO
	cQuery += " AND F71.F71_IDPD = ' ' " //Não pode ter sido integrado via PIX API
	cQuery += " AND F71.F71_SOLCAN = '1' " // 1 - SIM ; 2 - NAO
	cQuery += " AND F71.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY "+ SqlOrder(cIndex)

	cQuery := ChangeQuery(cQuery)

	AAdd(aStruct2, {'NomeCli',GetSX3Cache("E1_NOMCLI", "X3_TIPO"),GetSX3Cache("E1_NOMCLI","X3_TAMANHO"),GetSX3Cache("E1_NOMCLI", "X3_DECIMAL")})   //  Nome Cliente
	AAdd(aStruct2, {'BA_AG_CO','C',58,0})   // Banco + Agencia + Conta + Nome

	If __oFIN8913 <> Nil
		__oFIN8913:Delete()
		__oFIN8913	:= Nil
	EndIf

	cTraDF71 := GetNextAlias()

	__oFIN8913 := FwTemporaryTable():New(cTraDF71)
	__oFIN8913:SetFields(aStruct2)

	//Criando a Tabela Temporaria
	__oFIN8913:Create()

	MsgRun(STR0023,STR0008,{||SqlToTrb(cQuery, aStruct2, cTraDF71)}) // Gerando relação de títulos / Geração de CNAB PIX – Contas a Receber

	(cTraDF71)->( DbSetOrder(0) ) // Fica na ordem da query

	//Faz uma contagem de titulos por conta do maximo de linhas do MVC
	COUNT TO nTotCancel

	If nTotCancel > 0
		aStrCan := {}
		AAdd(aStrCan, "F71_PREFIX" 	)
		AAdd(aStrCan, "F71_NUM" 	)
		AAdd(aStrCan, "F71_PARCEL"	)
		AAdd(aStrCan, "F71_TIPO"	)
		AAdd(aStrCan, "F71_VALOR"	)
		AAdd(aStrCan, "F71_VENCTO"	)
		AAdd(aStrCan, "F71_CODCLI"	)
		AAdd(aStrCan, "F71_LOJCLI"	)
		AAdd(aStrCan, "F71_NOMCLI"	)

		aColumn2 := StruTela(aStrCan, 4)

		oMrkTitle:= FwMarkBrowse():New()

		oMrkTitle:SetMenuDef("")
		oMrkTitle:SetColumns(aColumn2)
		oMrkTitle:oBrowse:SetEditCell(.F.)
		oMrkTitle:SetOwner(oPanel)
		oMrkTitle:SetAlias(cTraDF71)
		oMrkTitle:SetDescription(STR0005)
		oMrkTitle:Activate()
	Else
		If __nTotReg == 0
			MsgAlert(STR0047 ,STR0008) // 'Não existem registro para serem transmitidos' ### 'Geração de CNAB PIX – Contas a Receber'
		EndIf
		oStepWiz:NextPage()
	EndIf
	(cTraDF71)->( DbSetOrder(0) ) // Fica na ordem da query

	(cTraDF71)->(DbGoTop())
	While !(cTraDF71)->(Eof())
		AAdd(aTitSel, {(cTraDF71)->F71_FILIAL, (cTraDF71)->F71_PREFIX, (cTraDF71)->F71_NUM, (cTraDF71)->F71_PARCEL, (cTraDF71)->F71_TIPO, (cTraDF71)->F71_CODCLI, (cTraDF71)->F71_LOJCLI, (cTraDF71)->F71_SEQ, (cTraDF71)->F71_IDTRAN, (cTraDF71)->F71_CODBAN, (cTraDF71)->F71_AGENCI, (cTraDF71)->F71_NUMCON, (cTraDF71)->F71_SOLCAN, "C" })
		(cTraDF71)->(DbSkip())
	EndDo
Return

/*/{Protheus.doc} cria_pn5
Função para construção da Quinta página do wizard

@param oPanel 

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Cria_Pn5( oPanel As Object )
	Local oFont As Object

	Default oPanel := Nil

	If Len(aTitSel) > 0

		oFont := TFont():New(,,-25,.T.,.T.,,,,,)

		TSay():New(10,15,{|| STR0008},oPanel,,oFont,,,,.T.,CLR_BLUE,) // Geração de arquivo CNAB PIX
		TSay():New(35,10,{|| STR0028},oPanel,,,,,,.T.,CLR_BLUE,) // 'Clique em "Avançar" para efetivar a geração dos arquivos CNAB PIX conforme os parâmetros selecionados anteriormente.'

	Else
		oStepWiz:NextPage()
	EndIf

Return

/*/{Protheus.doc} cria_pn6
Função para construção da sexta página do wizard

@param oPanel 

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Cria_Pn6( oPanel As Object )

	Local oFont	As Object

	Default oPanel := Nil

	oFont := TFont():New(,,-25,.T.,.T.,,,,,)

	// Apresenta o tSay com a fonte Courier New
	TSay():New(10,15,{|| STR0029},oPanel,,oFont,,,,.T.,CLR_BLUE,)
	
Return

// Início dos blocos de Ação das páginas de cada step para o botão "Avançar"

/*/{Protheus.doc} Valid_PG2
Função para ação da Segunda página do wizard

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Valid_PG2() As Logical

	Local nX		As Numeric
	Local cBanco	As Character
	Local cAgencia	As Character
	Local cConta	As Character
	Local cSubCta	As Character
	Local cPath 	As Character
	Local cExt 		As Character
	Local cArqCfg	As Character
	Local cArqSai	As Character
	Local cBarra	As Character
	Local cChave	As Character
	Local lRet 		As Logical

	nX			:= 0
	cBanco		:= ""
	cAgencia	:= ""
	cConta 		:= ""
	cSubCta 	:= ""
	cPath 		:= ""
	cExt 		:= ""
	cArqCfg 	:= ""
	cArqSai 	:= ""
	cBarra		:= ""
	cChave 		:= ""
	lRet 		:= .T.

	If Len(aBanSel) > 0
		For nX := 1 To Len(aBanSel)
			If !Empty(aBanSel[nX][1])
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ aBanSel [1] := Banco 				³
				//³ aBanSel [2] := Agencia 				³
				//³ aBanSel [3] := Conta 				³
				//³ aBanSel [4] := Chave PIX 			³
				//³ aBanSel [5] := SubConta 			³
				//³ aBanSel [6] := Arq. de Configuração ³
				//³ aBanSel [7] := Arquivo de Saida		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cBanco		:= aBanSel[nX][1]
				cAgencia	:= aBanSel[nX][2]
				cConta 		:= aBanSel[nX][3]
				cChave 		:= AllTrim(aBanSel[nX][4])
				cSubCta 	:= aBanSel[nX][5]
				cArqCfg 	:= AllTrim(aBanSel[nX][6])
				cArqSai 	:= AllTrim(aBanSel[nX][7])

				// Validação da Chave Pix
				If Empty(cChave)
					MsgAlert(STR0043 + cBanco + ", " + STR0016 + " " +  cAgencia + ", " +  STR0017+ " " +  cConta ,STR0008) // 'Necessária a informação da chave Pix no Banco ' ### 'Banco' ### 'Agência' ### 'Conta' ### 'Geração de CNAB PIX – Contas a Receber'
					lRet := .F.
				EndIf

				// Validação da SubConta
				If Empty(cSubCta)
					MsgAlert(STR0024 + cBanco + ", " + STR0016 + " " +  cAgencia + ", " +  STR0017+ " " +  cConta ,STR0008) // 'Necessária a informação de sub-conta no Banco' ### 'Banco' ### 'Agência' ### 'Conta' ### 'Geração de CNAB PIX – Contas a Receber'
					lRet := .F.
				ElseIf !Empty(cSubCta) 		// Verifica se a SubConta existe na tabela de Parametros Bancarios
					DbSelectArea("SEE")
					SEE->( DbSetOrder(1) ) 		// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
					If !SEE->( DbSeek( xFilial('SEE')+cBanco+cAgencia+cConta+cSubCta ) )
						MsgAlert(STR0024 + cBanco + ", " + STR0016 + " " +  cAgencia + ", " +  STR0017+ " " +  cConta ,STR0008) // 'Necessária a informação de sub-conta no Banco' ### 'Agência' ### 'Conta' ### 'Geração de CNAB PIX – Contas a Receber'
						lRet := .F.
					EndIf
				EndIf

				// Validação do Arquivo de Configuração
				If Empty(cArqCfg)
					MsgAlert(STR0021 + cBanco + ", " + STR0016 + " " +  cAgencia + ", " +  STR0017+ " " +  cConta,STR0008) // 'Necessário o nome do arquivo de configuração no Banco' ### 'Agência' ### 'Conta' ### 'Geração de CNAB PIX – Contas a Receber'
					lRet := .F.
				Else 		
					If !File(cArqCfg) 			// Verifica se o Arquivo de Configuração existe no Root Path
						cPath := "Root Path"
						If AT(":",cArqCfg)>0
							If AT("/",cArqCfg)>0
								cBarra := "/"
							ElseIf AT("\",cArqCfg)>0
								cBarra := "\"
							EndIf
							cPath := SubStr(TRIM(cArqCfg),1,RAT(cBarra,cArqCfg))
						EndIf

						cArqCfg  := SubStr(TRIM(cArqCfg),RAT(cBarra,cArqCfg)+1,LEN(cArqCfg))

						MsgAlert(STR0044 + cArqCfg + STR0045 + cPath, STR0008) // 'Não existe arquivo de configuração com o nome ' ### ' na pasta ' ### 'Geração de CNAB PIX – Contas a Receber'
						lRet := .F.
					EndIf
				EndIf

				// Validação do Arquivo de Saida
				If Empty(cArqSai)
					MsgAlert(STR0022 + cBanco + ", " + STR0016 + " " +  cAgencia + ", " +  STR0017+ " " +  cConta,STR0008) 	// 'Necessário o nome do arquivo de saída no Banco' ### 'Agência' ### 'Conta' ### 'Geração de CNAB PIX – Contas a Receber'
					lRet := .F.
				Else
					If File(cArqSai) 
						If AT(":",cArqSai)>0
							If AT("/",cArqSai)>0
								cBarra := "/"
							ElseIf AT("\",cArqSai)>0
								cBarra := "\"
							EndIf
							cPath := SubStr( TRIM(cArqSai),1,RAT(cBarra,cArqSai) )
						Else
							If Empty( AllTrim(SuperGetMV("MV_LOCENV", .F., .F.)) )
								cPath := "Root Path"
							Else
								cPath := AllTrim(SuperGetMV("MV_LOCENV", .F., .F.))
							EndIf
						EndIf

						Help(,,"F891EXTARQSAI",,STR0034+cPath,1,0, NIL, NIL, NIL, NIL, NIL, {STR0046}) 		// 'Arquivo de Saida ja existente na pasta ' ### 'Troque o diretorio de destino ou o nome do arquivo de saida.'
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Next nX
	Else
		MsgAlert(STR0030,STR0008) 		// 'Selecione ao menos um banco, para prosseguir.' ### 'Geração de CNAB PIX – Contas a Receber'
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} Valid_PG5
Função para ação da quinta página do wizard
@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function Valid_PG5() As Logical
	Local aTit150 	As Array
	Local cChaveF71	As Character
	Local nI		As Numeric
	Local nX 		As Numeric
	Local nZ 		As Numeric
	

	nZ := 1
	nX := 1

	aTit150 := {}

	For nZ := 1 To Len(aBanSel)
		aTit150 	:= {}

		For nX := 1 To Len(aTitSel)
			If aTitSel[nX][10] == aBanSel[nZ][1] .And. aTitSel[nX][11] == aBanSel[nZ][2] .And. aTitSel[nX][12] == aBanSel[nZ][3]
				AAdd(aTit150, {aTitSel[nX][1], aTitSel[nX][2], aTitSel[nX][3], aTitSel[nX][4], aTitSel[nX][5], aTitSel[nX][6], aTitSel[nX][7], aTitSel[nX][8], aTitSel[nX][9], aTitSel[nX][10], aTitSel[nX][11], aTitSel[nX][12], aTitSel[nX][13], aTitSel[nX][14] })
			EndIf
		Next nX
		
		If Len(aTit150) > 0
			If !lPixAPI
				MsgRun(STR0031,STR0008,{|| FA150PIX( aBanSel[nZ], aTit150 )}) // Processando arquivo CNAB PIX , Geração de arquivo CNAB PIX
			Else
				// Caso o envio seja feito pela API PIX, faz apenas a gravação do banco / agência / conta
				aAreaF71 := F71->(GetArea())
				F71->( DbSetOrder(3) ) // F71_IDTRAN
				
				For nI := 1 To Len(aTit150)

					cChaveF71 := aTitSel[nI,9]  // F71_IDTRAN
					If !F71->(MsSeek(cChaveF71))
						Loop
					EndIf
					
					Reclock("F71",.F.)
					F71->F71_CODBAN := aBanSel[nZ,1]
					F71->F71_AGENCI := aBanSel[nZ,2]
					F71->F71_NUMCON := aBanSel[nZ,3]
					F71->F71_FILBCO := aBanSel[nZ,8]
					F71->F71_TPCHV  := aBanSel[nZ,9]
					F71->F71_CHVPIX := aBanSel[nZ,4]
					F71->(MsUnlock())
				Next nI
				RestArea(aAreaF71)
			EndIf
		EndIf
	Next nZ

	INCLUI := .F.

Return .T.

// Início dos blocos de ação das páginas de cada step para o botão "Voltar"

/*/{Protheus.doc} BtnCancel
Função para ação do botão cancelar

@author Rodrigo Franco
@since  22/10/2020
@version 12.1.27
/*/
Static Function BtnCancel() As Logical
	Local lRet As Logical

	lRet := MsgYesNo(STR0032,STR0008) // Deseja cancelar a geração do arquivo CNAB PIX ?

Return lRet

/*/{Protheus.doc} Wzd02Cos
Rotina utilizada para montar a tela de opções da Chave PIX utilizada na pagina 02 do wizard.

@author Adriano Sato
@since  05/11/2020
@version 12.1.27
/*/
Static Function Wzd02Cos(aBrowse as Array)

	Local oDlg 		as Object
	Local oLbx 		as Object
	Local lRet		as Logical
	Local cChvPix 	as Character
	Local nLinha1 	as Numeric
	Local nColum1 	as Numeric

	Default aBrowse := {}

	lRet	:= .F.
	cChvPix	:= ""

	DEFINE MSDIALOG oDlg TITLE STR0018 FROM 0,0 TO 400,600 PIXEL //'Tipo da Chave PIX'

	nLinha1 := (oDlg:nHeight - 100) / 2
	nColum1 := (oDlg:nWidth - 10) / 2

	@ 030,002 LISTBOX oLbx VAR cVar FIELDS HEADER STR0018, STR0019 SIZE nColum1, nLinha1 OF oDlg PIXEL ColSizes 30, 40 	// 'Tipo da Chave PIX' ### 'Chave PIX'

	oLbx:SetArray(aBrowse)
	oLbx:align := CONTROL_ALIGN_ALLCLIENT

	oLbx:bLine := {|| {aBrowse[oLbx:nAt][1], aBrowse[oLbx:nAt][2]}}
	oLbx:Refresh()

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {|| lRet := .T., cChvPix := aBrowse[oLbx:nAt,02], oDlg:End() }, {||oDlg:End()})

Return {lRet,cChvPix}

/*/{Protheus.doc} ClearTMP()
Limpa tabelas temporarias, caso existam

@author Rodrigo Franco	
@since  11/11/2020
@version 12.1.27
/*/
Static Function ClearTMP()

	If __oFIN8913 <> Nil
		__oFIN8913:Delete()
		__oFIN8913 := Nil
	EndIf

	If __oFIN8912 <> Nil
		__oFIN8912:Delete()
		__oFIN8912 := Nil
	EndIf

Return

/*/ {Protheus.doc} FINA891A01()
Loop na tela de Titulos para Diversos bancos

@Project	CNAB PIX
@author	 	Rodrigo Franco
@since		12/11/2020
@version	P12
@Return		Logico com o resultado da integração
@param
@Obs
/*/
Static Function FINA891A01(aDdsEdit as Array, oPanel as Object, __nCtrlFo2 as Numeric, nLenEdi as Numeric, cTrabF71 as Character)

	Local oPnlAux	As Object
	Local cBanco	As Character
	Local cAgenc	As Character
	Local cConta	As Character
	Local cNomBan	As Character
	Local aStruc1	As Array
	Local aColumn1	As Array
	Local aSeek    	As Array
	Local aCpsFil 	As Array
	Local nTotTrans	As Numeric

	Default aDdsEdit	:= {}
	Default oPanel 		:= Nil
	Default __nCtrlFo2	:= 0
	Default nLenEdi 	:= 0
	Default cTrabF71 	:= ""

	Static cMark71 	:= GetMark()

	oPnlAux		:= Nil
	aStruc1		:= {}
	aColumn1	:= {}
	aSeek    	:= {}
	cBanco	  	:= aBanSel[__nCtrlFo2][1]
	cAgenc		:= aBanSel[__nCtrlFo2][2]
	cConta		:= aBanSel[__nCtrlFo2][3]
	cNomBan		:= ""
	aCpsFil 	:= {}
	nTotTrans 	:= 0

	If oPanel != Nil
		__oFwBrw	:= oPanel
		oTPanel	:= oPanel
	EndIf

	If __nCtrlFo2 > 1
		oBrowse:DeActivate(.T.)
		oBrowse:Destroy()
		oBrowse	:= Nil
	EndIf

	If __nCtrlFo2 > nLenEdi
		Return .T.
	EndIf

	AAdd(aStruc1, "F71_PREFIX" 	)
	AAdd(aStruc1, "F71_NUM" 	)
	AAdd(aStruc1, "F71_PARCEL"	)
	AAdd(aStruc1, "F71_TIPO"	)
	AAdd(aStruc1, "F71_VALOR"	)
	AAdd(aStruc1, "F71_VENCTO"	)
	AAdd(aStruc1, "F71_CODCLI"	)
	AAdd(aStruc1, "F71_LOJCLI"	)
	AAdd(aStruc1, "F71_NOMCLI"	)

	AAdd(aSeek,{ GetSX3Cache("F71_NUM","X3_TITULO"),; 		// [n,1] Título da pesquisa
				 { { "F71_NUM",; 							// [n,2,n,1] LookUp
			 	 	GetSX3Cache("F71_NUM","X3_TIPO"),; 		// [n,2,n,2] Tipo de dados
				 	GetSX3Cache("F71_NUM","X3_TAMANHO"),; 	// [n,2,n,3] Tamanho
				 	GetSX3Cache("F71_NUM","X3_DECIMAL"),; 	// [n,2,n,4] Decimal
				 	GetSX3Cache("F71_NUM","X3_TITULO"),; 	// [n,2,n,5] Título do campo
				 	GetSX3Cache("F71_NUM","X3_PICTURE"),; 	// [n,2,n,6] Máscara
				  } },; 									// [n,2,n,7] Nome Físico do campo - Opcional - é ajustado no programa
				 1} )										// [n,3] Ordem da pesquisa

	AAdd(aCpsFil ,{"F71_FILIAL", GetSX3Cache("E1_FILIAL","X3_TITULO")  , GetSX3Cache("E1_FILIAL","X3_TIPO")  , GetSX3Cache("E1_FILIAL","X3_TAMANHO")	, GetSX3Cache("E1_FILIAL","X3_DECIMAL")		, GetSX3Cache("E1_FILIAL","X3_PICTURE")		})
	AAdd(aCpsFil ,{"F71_PREFIX", GetSX3Cache("E1_PREFIXO","X3_TITULO") , GetSX3Cache("E1_PREFIXO","X3_TIPO") , GetSX3Cache("E1_PREFIXO","X3_TAMANHO")	, GetSX3Cache("E1_PREFIXO","X3_DECIMAL")	, GetSX3Cache("E1_PREFIXO","X3_PICTURE")	})
	AAdd(aCpsFil ,{"F71_NUM"   , GetSX3Cache("E1_NUM","X3_TITULO")     , GetSX3Cache("E1_NUM","X3_TIPO")     , GetSX3Cache("E1_NUM","X3_TAMANHO")		, GetSX3Cache("E1_NUM","X3_DECIMAL")		, GetSX3Cache("E1_NUM","X3_PICTURE")		})
	AAdd(aCpsFil ,{"F71_PARCEL", GetSX3Cache("E1_PARCELA","X3_TITULO") , GetSX3Cache("E1_PARCELA","X3_TIPO") , GetSX3Cache("E1_PARCELA","X3_TAMANHO")	, GetSX3Cache("E1_PARCELA","X3_DECIMAL")	, GetSX3Cache("E1_PARCELA","X3_PICTURE")	})
	AAdd(aCpsFil ,{"F71_TIPO"  , GetSX3Cache("E1_TIPO","X3_TITULO")    , GetSX3Cache("E1_TIPO","X3_TIPO")    , GetSX3Cache("E1_TIPO","X3_TAMANHO")		, GetSX3Cache("E1_TIPO","X3_DECIMAL")		, GetSX3Cache("E1_TIPO","X3_PICTURE")		})
	AAdd(aCpsFil ,{"F71_EMISSA", GetSX3Cache("E1_EMISSAO","X3_TITULO") , GetSX3Cache("E1_EMISSAO","X3_TIPO") , GetSX3Cache("E1_EMISSAO","X3_TAMANHO")	, GetSX3Cache("E1_EMISSAO","X3_DECIMAL")	, GetSX3Cache("E1_EMISSAO","X3_PICTURE")	})
	AAdd(aCpsFil ,{"F71_VENCTO", GetSX3Cache("E1_VENCTO","X3_TITULO")  , GetSX3Cache("E1_VENCTO","X3_TIPO")  , GetSX3Cache("E1_VENCTO","X3_TAMANHO")	, GetSX3Cache("E1_VENCTO","X3_DECIMAL")		, GetSX3Cache("E1_VENCTO","X3_PICTURE")		})

	(cTrabF71)->(DbGoTop())

	oBrowse := FwBrowse():new(__oFwBrw)
	oBrowse:SetDataTable()
	oBrowse:SetAlias(cTrabF71)
	oBrowse:SetFieldFilter(aCpsFil)
	oBrowse:SetProfileID("FINA891")
	oBrowse:SetUseFilter()
	oBrowse:SetLocate()
	oBrowse:SetSeek(Nil,aSeek)
	oBrowse:SetDescription(STR0004) // 'Seleção de títulos'

	cAliasTmp := (cTrabF71)

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())
		If !Empty((cAliasTmp)->F71_CODBAN)
			RecLock( cAliasTmp,.F. )
			DbDelete()
			MsUnlock()
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	COUNT TO nTotTrans

	If nTotTrans > 0

		aColumn1 := StruTela(aStruc1, 3)

		oBrowse:AddMarkColumns( { ||IIf( !Empty( MARK ),"LBOK","LBNO" ) },{ || F71MarkDM( oBrowse, __nCtrlFo2 ) }, { || F71MarkAll( oBrowse, __nCtrlFo2 ), oBrowse:GoTo( oBrowse:nAt ), oBrowse:Refresh() } )
		oBrowse:SetColumns(aColumn1)

		oBrowse:DeActivate()
		oBrowse:Activate()

		oBrowse:Refresh()
		__oFwBrw:Refresh()
	Else
		Help(,,"F891NOREG",,STR0049 ,1,0) // Sem títulos para seleção
		o3rdPage:SetNextAction({||.F.})
		BtnCancel()
	EndIf
	oPnlAux	:= TPanel():New(120,0,,oTPanel,,.T.,,CLR_YELLOW,CLR_RED,400,30)
	oPnlAux:Align := CONTROL_ALIGN_BOTTOM

	DbSelectArea("SA6")
	SA6->( DbSetOrder(1) )
	If SA6->( DbSeek(FwXFilial("SA6")+cBanco+cAgenc+cConta) )
		cNomBan := SA6->A6_NOME
	EndIf

	@ 012,010 SAY STR0033					SIZE 200,08 PIXEL Of oPnlAux 	// Banco
	@ 012,030 SAY cBanco + " - " + cNomBan	SIZE 200,08 PIXEL Of oPnlAux

	@ 012,215 SAY STR0016 		SIZE 50,08 PIXEL Of oPnlAux				// Agência
	@ 012,240 SAY cAgenc  		SIZE 50,08 PIXEL Of oPnlAux

	@ 012,280 SAY STR0017 		SIZE 50,08 PIXEL Of oPnlAux				// Conta
	@ 012,300 SAY cConta  		SIZE 50,08 PIXEL Of oPnlAux

Return

/*/{Protheus.doc} F71MarkDM()
Função do Double click para selecionar um registro na FwBrowse.

@author Adriano Sato
@since  02/11/2020
@version 12.1.027
/*/
Static Function F71MarkDM( oBrwF71 As Object, nBcoSel as Numeric  )

	Default oBrwF71 := Nil
	Default nBcoSel := 0

	RecLock( cTrabF71,.F. )
		If Empty( ( cTrabF71 )->MARK )
			( cTrabF71 )->MARK := cMark71
			( cTrabF71 )->F71_CODBAN := aBanSel[nBcoSel][1]
			( cTrabF71 )->F71_AGENCI := aBanSel[nBcoSel][2]
			( cTrabF71 )->F71_NUMCON := aBanSel[nBcoSel][3]
		Else
			( cTrabF71 )->MARK := ""
			( cTrabF71 )->F71_CODBAN := ""
			( cTrabF71 )->F71_AGENCI := ""
			( cTrabF71 )->F71_NUMCON := ""
		EndIf
	( cTrabF71 )->( MsUnLock() )

Return( Nil )

/*/{Protheus.doc} F71MarkAll()
Função do Header click para selecionar todos os registros na FwBrowse.

@author Adriano Sato
@since  02/12/2020
@version 12.1.027
/*/
Static Function F71MarkAll( oBrwF71 As Object, nBcoSel as Numeric )

	Local lMarca As Logical

	Default oBrowse := Nil
	Default nBcoSel := 0
	
	lMarca := ( cTrabF71 )->MARK <> cMark71

	( cTrabF71 )->( DbGoTop() )

	While ( cTrabF71 )->( !EOF() )
		RecLock( cTrabF71, .F. )
		If lMarca
			( cTrabF71 )->MARK := cMark71
			( cTrabF71 )->F71_CODBAN := aBanSel[nBcoSel][1]
			( cTrabF71 )->F71_AGENCI := aBanSel[nBcoSel][2]
			( cTrabF71 )->F71_NUMCON := aBanSel[nBcoSel][3]
		Else
			( cTrabF71 )->MARK := ""
			( cTrabF71 )->F71_CODBAN := ""
			( cTrabF71 )->F71_AGENCI := ""
			( cTrabF71 )->F71_NUMCON := ""
		EndIf
		( cTrabF71 )->( MsUnLock() )
		( cTrabF71 )->( DbSkip() )
	EndDo

Return( Nil )

/*/{Protheus.doc} FINA891A02()
Função que verifica e valida se existe mais do que uma tela do wizard para seleção dos Titulos de varios bancos 

@author Rodrigo Franco
@since  11/11/2020
@version 12.1.019
/*/
Static Function FINA891A02(aDdsEdit as Array, nVlrFor as Numeric, oPanel as Object, nLenEdi as Numeric) As Logical

	Local lRet	As Logical
	Local nX	As Numeric

	lRet := .F.
	nX   := 1

	Default aDdsEdit := {}
	Default nVlrFor  := 0 
	Default oPanel   := Nil 
	Default nLenEdi  := 0

	If !lVldRep
		__nCtrlFo2 := 0
	EndIf

	If __nCtrlFo2 == 0 .And. nVlrFor == 1 .And. !lVldRep
		lVldRep	:= .T.
		__nCtrlFo2 := __nCtrlFo2 + 1
	EndIf

	If Len(aDdsEdit) == 0 .And. __nCtrlFo2 <= nLenEdi
		Cria_Pn3(oPanel, __nCtrlFo2++)
		Return .F.
	ElseIf Len(aDdsEdit) == 0 .And. __nCtrlFo2 > nLenEdi
		Return .T.
	EndIf

	(cTrabF71)->(DbGoTop())
	While !(cTrabF71)->(Eof())
		If !Empty((cTrabF71)->MARK)
			AAdd(aTitSel, {(cTrabF71)->F71_FILIAL, (cTrabF71)->F71_PREFIX, (cTrabF71)->F71_NUM, (cTrabF71)->F71_PARCEL, (cTrabF71)->F71_TIPO, (cTrabF71)->F71_CODCLI, (cTrabF71)->F71_LOJCLI, (cTrabF71)->F71_SEQ, (cTrabF71)->F71_IDTRAN,  (cTrabF71)->F71_CODBAN,  (cTrabF71)->F71_AGENCI,  (cTrabF71)->F71_NUMCON,  (cTrabF71)->F71_SOLCAN, "I" })
		EndIf
		(cTrabF71)->(DbSkip())
	EndDo

	lRet := .T.
	__nCtrlFo2	:= __nCtrlFo2 + 1
	If nCtrPrev > 1 .And. __nCtrlFo2 <= nCtrPrev
		If len(aTitSel) >= (cTrabF71)->(Reccount())
			__nCtrlFo2 := nCtrPrev + 1
		Else
			Cria_Pn3(oPanel, __nCtrlFo2)
		EndIf
	EndIf
	
	If lRet
		If nCtrPrev >= __nCtrlFo2
			lRet	:= .F.
		ElseIf  nCtrPrev < __nCtrlFo2
			lRet	:= .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ChvEdit()
Função que verifica e valida os dados dos campos editaveis 

@author Adriano Sato
@since  19/11/2020
@version 12.1.027
/*/
Static Function ChvEdit(A As Object, B As Object, aCmbTpChv As Array) As Logical

	Local nX		As Numeric
	Local aOpcao	As Array
	Local cDdsAlt	As Character
	Local lRet		As Logical
	Local aDdsAlt	As Array
	Local aListaChv as Array
	Local aRet      as Array
	Local nTamaAge	as Numeric
	Local nTamDage	as Numeric
	Local nTamCta	as Numeric
	Local nTamDcta	as Numeric
	Local nLinhas   as Numeric
	Local cMensage  as Character
	Local cOldTipo  as Character
	Local cOldChav  as Character

	Default aCmbTpChv := {}

	nX			:= 0
	aOpcao		:= {}
	cDdsAlt		:= ""
	lRet		:= .T.
	aDdsAlt		:= {}
	aListaChv 	:= {}
	aRet 		:= {}
	nLinhas 	:= 0
	nTamaAge 	:= TamSX3("F70_AGENCI")[1]
	nTamDage 	:= TamSX3("F70_DVAGE")[1]
	nTamCta		:= TamSX3("F70_NUMCON")[1]
	nTamDcta 	:= TamSX3("F70_DVCTA")[1]
	cMensage 	:= ""
	cOldTipo 	:= ""
	cOldChav 	:= ""

	If B:COLPOS() == 6
		aOpcao	:= aCmbTpChv
		If ! Empty(VlrNew)
			cOldTipo 	:= B:ODATA:AARRAY[B:AT()][06]
			cOldChav 	:= B:ODATA:AARRAY[B:AT()][07]
			cDdsAlt		:= AllTrim(VlrNew)
			If AScan(aOpcao,{|X| Upper(X[2]) == Upper(cDdsAlt) }) > 0

				aAgencia  := StrTokArr2( B:ODATA:AARRAY[B:AT()][03], "-", .T. )
				aConta    := StrTokArr2( B:ODATA:AARRAY[B:AT()][04], "-", .T. )

				If Len(aAgencia) > 2	// Tem DV no campo da agencia
					cAgencia  := PadR(aAgencia[1] + "-" + aAgencia[2], nTamaAge) + PadR(aAgencia[3], nTamDage)
				Else
					cAgencia  := PadR(aAgencia[1], nTamaAge) + PadR(aAgencia[2], nTamDage)
				EndIf

				If Len(aConta) > 2	// Tem DV no campo da conta
					cConta    := PadR(aConta[1] + "-" + aConta[2], nTamCta) + PadR(aConta[3], nTamDcta)
				Else
					cConta    := PadR(aConta[1], nTamCta) + PadR(aConta[2], nTamDcta)
				EndIf

				cChave := FwXFilial("F70") + B:ODATA:AARRAY[B:AT()][02] + ;
						  cAgencia + cConta + aCmbTpChv[AScan(aCmbTpChv,{|x| Upper(x[2]) == Upper(cDdsAlt)})][1]

				DbSelectArea("F70")
				F70->( DbSetOrder(1) ) 		// F70_FILIAL+F70_COD+F70_AGENCI+F70_DVAGE+F70_NUMCON+F70_DVCTA+F70_TPCHV+F70_CHVPIX
				If F70->( DbSeek(cChave) )
					While F70->(!EOF()) .And. F70->(F70_FILIAL+F70_COD+F70_AGENCI+F70_DVAGE+F70_NUMCON+F70_DVCTA+F70_TPCHV) == cChave
						nLinhas++

						AAdd( aListaChv , {VlrNew , F70->F70_CHVPIX} )

						F70->( DbSkip() )
					Enddo
					If nLinhas > 1
						aRet := Wzd02Cos(aListaChv)
						If aRet[1]
							B:ODATA:AARRAY[B:AT()][06] := cDdsAlt
							B:ODATA:AARRAY[B:AT()][07] := aRet[2]
						Else
							B:ODATA:AARRAY[B:AT()][06] := cOldTipo
							B:ODATA:AARRAY[B:AT()][07] := cOldChav
							//MSGALERT( STR0042, STR0037 ) 		// 'Favor selecionar uma chave PIX'  ### 'Seleção de chave PIX'
						EndIf
					Else
						B:ODATA:AARRAY[B:AT()][06] := cDdsAlt
						B:ODATA:AARRAY[B:AT()][07] := aListaChv[1][2]
					EndIf
				else
					B:ODATA:AARRAY[B:AT()][06] := cDdsAlt
					B:ODATA:AARRAY[B:AT()][07]	:= " "
					If Upper(B:ODATA:AARRAY[B:AT()][06])  ==  Upper(aCmbTpChv[1][2]) // 01 - TELEFONE
						cMensage := STR0038 	// 'Não existe chave PIX de telefone cadastrada neste banco'
					ElseIf Upper(B:ODATA:AARRAY[B:AT()][06])  ==  Upper(aCmbTpChv[2][2])  // 02 - EMAIL
						cMensage := STR0039 	// 'Não existe chave PIX de e-mail cadastrada neste banco'
					ElseIf Upper(B:ODATA:AARRAY[B:AT()][06])  ==  Upper(aCmbTpChv[3][2])  // 03 - CPF/CNPJ
						cMensage := STR0040 	// 'Não existe chave PIX de cpf/cnpj cadastrada neste banco'
					ElseIf Upper(B:ODATA:AARRAY[B:AT()][06])  ==  Upper(aCmbTpChv[4][2])  // 04 - ALEATORIA
						cMensage := STR0041 	// 'Não existe chave PIX aleatória cadastrada neste banco'
					EndIf
					MSGALERT( cMensage, STR0037 ) 	// 'Seleção de chave PIX'
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIF B:COLPOS() == 8 .Or. B:COLPOS() == 9 .Or. B:COLPOS() == 5
		B:ODATA:AARRAY[B:AT()][B:COLPOS()] := VlrNew
	Else
		If B:ODATA:AARRAY[B:AT()][B:COLPOS()]
			B:ODATA:AARRAY[B:AT()][B:COLPOS()] := .F.
		Else
			B:ODATA:AARRAY[B:AT()][B:COLPOS()] := .T.
		EndIf
	EndIf

	If lRet
		AtuBanSel( B )
	EndIf

Return lRet

/*/{Protheus.doc} F70MarkDM()
Função do Double click para selecionar um registro na FwBrowse.

@author Adriano Sato
@since  19/11/2020
@version 12.1.027
/*/
Static Function F70MarkDM( oBrwF70 As Object  )

	Default oBrwF70 := {}

	If oBrwF70:oDATA:aARRAY[oBrwF70:AT()][oBrwF70:COLPOS()]
		oBrwF70:oDATA:aARRAY[oBrwF70:AT()][oBrwF70:COLPOS()] := .F.
	Else
		oBrwF70:oDATA:aARRAY[oBrwF70:AT()][oBrwF70:COLPOS()] := .T.
	EndIf

	AtuBanSel( oBrwF70 )

	oBrwF70:Refresh()

Return( Nil )

/*/{Protheus.doc} F70MarlAll()
Função do Header click para selecionar todos os registros na FwBrowse.

@author Adriano Sato
@since  19/11/2020
@version 12.1.027
/*/
Static Function F70MarlAll( oBrwF70 As Object  )

	Local nX 	 As Numeric
	Local lMarca As Logical

	Default oBrwF70 := {}

	If oBrwF70:oDATA:aARRAY[1][1]
		lMarca := .F.
	Else
		lMarca := .T.
	EndIf

	For nX := 1 To LEN(oBrwF70:oDATA:aARRAY)
		oBrwF70:oDATA:aARRAY[nX][1] := lMarca
	Next nX

	AtuBanSel( oBrwF70 )

	oBrwF70:Refresh()

Return( Nil )

/*/{Protheus.doc} AtuBanSel()
Função para atualização do array de parametros que sera utilizado  em outras paginas do wizard.

@author Adriano Sato
@since  19/11/2020
@version 12.1.027
/*/
Static Function AtuBanSel( oBrwF70 As Object  )

	Local aAgencia 	As Array
	Local aConta 	As Array
	Local cAgencia 	As Character
	Local cConta 	As Character
	Local nTamaAge	As Numeric
	Local nTamCta	As Numeric
	Local nX 		As Numeric

	Default oBrwF70 := {}

	aAgencia := {}
	aConta 	 := {}
	aBanSel  := {}
	cAgencia := ""
	cConta 	 := ""
	nTamaAge := TamSX3("F70_AGENCI")[1]
	nTamCta	 := TamSX3("F70_NUMCON")[1]

	For nX := 1 To Len(oBrwF70:ODATA:AARRAY)
		If oBrwF70:ODATA:AARRAY[nX][1]
			aAgencia  := StrTokArr2( oBrwF70:ODATA:AARRAY[nX][03], "-", .T. )
			If Len(aAgencia) > 2	// Tem DV no campo da agencia
				cAgencia  := PadR(aAgencia[1]+"-"+aAgencia[2],nTamaAge)
			Else
				cAgencia  := PadR(aAgencia[1], nTamaAge)
			EndIf

			aConta    := StrTokArr2( oBrwF70:ODATA:AARRAY[nX][04], "-", .T. )
			If Len(aConta) > 2	// Tem DV no campo da conta
				cConta    := PadR(aConta[1]+"-"+aConta[2],nTamCta)
			Else
				cConta    := PadR(aConta[1], nTamCta)
			EndIf

			AAdd(aBanSel, { oBrwF70:ODATA:AARRAY[nX][02], cAgencia, cConta, oBrwF70:ODATA:AARRAY[nX][07], oBrwF70:ODATA:AARRAY[nX][05], oBrwF70:ODATA:AARRAY[nX][08], AllTrim(oBrwF70:ODATA:AARRAY[nX][09]), aDadBcoPix[Nx][1], aDadBcoPix[Nx][2]} )
		EndIf
	Next nX

Return( Nil )

/*/{Protheus.doc} FindFile()
Função para a verificação da existencia do nome do arquivo no diretorio informado.

@author Adriano Sato
@since  20/11/2020
@version 12.1.027
/*/
Static Function FindFile( cFilePath As Character, cFileName As Character, aDdsEdit As Array ) As Character

	Local lValidName 	As Logical
	Local cExt 			As Character
	Local cVldName 		As Character
	Local cFullRoot 	As Character
	Local nY 			As Numeric
	Local nI 			As Numeric
	Local cBarra 		As Character
	Local lF150Arq 		As Logical
	Local cArq150 		As Character
	Local cDrive 		As Character
	Local cDir 			As Character
	Local cNome 		As Character
	Local cExtensao 	As Character

	Default cFilePath := ""
	Default cFileName := ""
	Default aDdsEdit  := {}

	lValidName 	:= .F.
	nI 			:= 1
	cBarra 		:= IIf( GetRemoteType() == 2, '/', '\') 	// GetRemoteType() == 2 // linux
	lF150Arq	:= ExistBlock("F150ARQ")
	cArq150 	:= ""
	cDrive 		:= ""
	cDir 		:= ""
	cNome 		:= ""
	cExtensao 	:= ""

	If lF150Arq
		cArq150 := ExecBlock("F150ARQ",.F.,.F.,cFileName)
		SplitPath( cArq150, @cDrive, @cDir, @cNome, @cExtensao )
		
		If !Empty(cDrive)
			If !Empty(cDir)
				cFilePath := cDrive+cDir
			Else
				cFilePath := cDrive
			EndIf
		Else
			If !Empty(cDir)
				cFilePath := cDir
			EndIf
		EndIf

		If !Empty(cNome)
			If !Empty(cExtensao)
				cFileName := AllTrim(cNome+cExtensao)
			Else
				cFileName := AllTrim(cNome)
				cExt      := AllTrim(cExtensao)
			EndIf
		EndIf
	EndIf

	If GetRemoteType() == 2	// Linux / Unix
		cFilePath := Lower(StrTran(cFilePath,"\","/"))
	EndIf

	nY := At(".", cFileName)
	If nY > 0
		cExt	  := SubStr(cFileName,  nY, Len(cFileName)) 	// Guarda extensao
		cFileName := Left(cFileName,  nY - 1) 					// Deixa Nome do Arquivo sem Extens?o
	EndIf

	If !Empty( cFilePath )
		If RIGHT(cFilePath,1) != cBarra 	// Verifica se o ultimo caracter do diretorio é uma "/" ou "\"
			cVldName := cFilePath+cBarra+cFileName+cExt
			cFullRoot := cVldName
		Else
			cVldName := cFilePath+cFileName+cExt
			cFullRoot := cVldName	
		EndIf
	Else
		cVldName := cBarra+cFileName+cExt
		cFullRoot := cVldName
	EndIf

	// Garante que o nome do arquivo não irá sobrepor nenhum outro
	While !lValidName
		If File(UPPER(cFullRoot)) .or. File(LOWER(cFullRoot)) .or. ( aScan(aDdsEdit,{|x| x[9] == Pad(cVldName,75)}) > 0 )
			If !Empty( cFilePath )
				If RIGHT(cFilePath,1) != cBarra
					cVldName := cFilePath+cBarra+cFileName+"("+cValToChar(nI)+")"+cExt
				Else
					cVldName := cFilePath+cFileName+"("+cValToChar(nI)+")"+cExt
				EndIf
			Else
				cVldName := cBarra+cFileName+"("+cValToChar(nI)+")"+cExt
			EndIf
			cFullRoot := cVldName
		Else
			lValidName := .T.
		EndIf
		nI++
	EndDo

Return cVldName

/*/{Protheus.doc} PixGerImp
	Gera abatimento de IR e PCC configurados na baixa de contas a receber
	A funcao deve ser chamada com a SE1 posicionada
	
	@author Igor Nascimento
	@since 10/11/2020
	@version P12.1.27
/*/
Function PixGerImp(nBaseImpos As Numeric, nTxMoeda As Numeric) As Logical
	Local lRet        As Logical
	Local lPccMR      As Logical
	Local lPccBxMR    As Logical
	Local lIrfMR      As Logical
	Local lIrfBxMR    As Logical		
	Local lIrfPjBx    As Logical
	Local cCamposE5   As Character
	Local cChaveTit   As Character
	Local cChaveFK7   As Character
	Local cOrigem     As Character
	Local cPrefOrig   As Character
	Local cNumOrig    As Character
	Local cParcOrig   As Character
	Local cTipoOrig   As Character
	Local cCliOrig    As Character
	Local cLojaOrig   As Character	
	Local cSequencia  As Character	
	Local cIdFK1      As Character
	Local cIdFk3      As Character
	Local cIdFK4      As Character
	Local nPIS        As Numeric
	Local nCOFINS     As Numeric
	Local nCSLL       As Numeric
	Local nIrrf       As Numeric
	Local nX          As Numeric	
	Local nRegistroNF As Numeric	
	Local nImposBaix  As Numeric
	Local aAreaAtual  As Array
	Local aAreaSE1    As Array
	Local aPcc        As Array
	Local aImpos      As Array
	Local aImpostos   As Array
	Local aTitCalc    As Array	
	Local oModelBx    As Object
	Local oSubFK1     As Object
	Local oSubFKA     As Object
	Local oSubFK3     As Object
	Local oSubFK4     As Object
	
	//Defaults dos parâmetros.
	Default nBaseImpos := 0
	Default nTxMoeda   := 0
	
	//Inicializa variáveis
	lRet        := .T.
	lPccMR      := .F.
	lPccBxMR    := .F.
	lIrfMR      := .F.
	lIrfBxMR    := .F.
	lIrfPjBx    := FIrPjBxCr(.T.)
	cCamposE5   := ""
	cChaveTit   := xFilial("SE1")+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
	cChaveFK7   := ""
	cOrigem     := FunName()
	cPrefOrig   := ""
	cNumOrig    := ""
	cParcOrig   := ""
	cTipoOrig   := ""
	cCliOrig    := ""
	cLojaOrig   := ""
	cSequencia  := ""
	cIdFK1      := ""
	cIdFk3      := ""
	cIdFK4      := ""
	nPIS        := 0
	nCOFINS     := 0
	nCSLL       := 0
	nIrrf       := 0
	nX          := 0	
	nRegistroNF := SE1->(Recno())	
	nImposBaix  := 0	
	aAreaAtual  := GetArea()
	aAreaSE1    := SE1->(GetArea())
	aPcc        := {}
	aImpos      := {}
	aImpostos   := {}
	aTitCalc    := {}
	oModelBx    := Nil
	oSubFK1     := Nil
	oSubFKA     := Nil
	oSubFK3     := Nil
	oSubFK4     := Nil
	
	//Privates
	Private lRetTitMin := .F.
	Private nPisCalc   := 0
	Private nCofCalc   := 0
	Private nCslCalc   := 0
	Private nIrfCalc   := 0	
	Private nVlPis     := 0
	Private nVlCofins  := 0
	Private nVlCsll    := 0	
	Private nPisBaseR  := 0
	Private nCofBaseR  := 0
	Private nCslBaseR  := 0
	Private nIrfBaseR  := 0
	Private nPccBaseC  := 0
	Private nIrfBaseC  := 0
	Private nPisBaseC  := 0
	Private nCofBaseC  := 0
	Private nCslBaseC  := 0
	Private nPisFin891 := 0
	Private nCofFin891 := 0
	Private nCslFin891 := 0
	Private nIrfFin891 := 0	
	Private aPccExc    := {}
	Private aDadosRef  := Array(7)
	Private aDadosRet  := Array(7)	
	Private dBaixa     := dDataBase
	
	__lPccBaix := IIf(__lPccBaix == Nil, FPccBxCr(), __lPccBaix)  
	__lMotRet  := IIf(__lMotRet == Nil, ExistFunc("FTemMotor") .And. FTemMotor(), __lMotRet)
	__nCasasDc := IIf(__nCasasDc == Nil, TamSX3("FK1_TXMOED")[2], __nCasasDc)
	nPccBaseC  := nIrfBaseC := nIrfBaseR := nBaseImpos
	
	//Cálculo de impostos pelo configurador de tributos.
	If __lMotRet
		aImpos  := FINCalImp("2", SE1->E1_NATUREZ, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILORIG, nBaseImpos, dDataBase, .T., {}, SE1->E1_TIPO, cChaveTit, Nil, {})
		
		For nX := 1 To Len(aImpos)
			Do Case
				Case aImpos[nX,8] == "PIS"
					nPis		+= aImpos[nX,5]
					nPisCalc	:= nPis
					lPccMR	 	:= .T.
					lPccBxMR 	:= (aImpos[nX,9] == "2")
				Case aImpos[nX,8] == "COF"
					nCofins		+= aImpos[nX,5]
					nCofCalc	:= nCofins
					lPccMR	 	:= .T.
					lPccBxMR 	:= (aImpos[nX,9] == "2")
				Case aImpos[nX,8] == "CSL"
					nCsll		+= aImpos[nX,5]
					nCslCalc	:= nCsll
					lPccMR	 	:= .T.
					lPccBxMR 	:= (aImpos[nX,9] == "2")
				Case aImpos[nX,8] == "IRF"
					nIrrf	 	+= aImpos[nX,5]
					lIrfMR	 	:= .T.
					lIrfBxMR 	:= (aImpos[nX,9] == "2")
			EndCase
		Next nX
		
		If Len(aImpos) > 0
			F061GrvIMt(aImpos,,SE1->E1_SITUACA,nPis+nCofins+nCsll+nIrrf)
		EndIf
	EndIf
	
	//Cálculo de IRRF
	If lIrfPjBx .And. !lIrfMR			
		nIrrf := FCaIrBxCR(nBaseImpos, nRegistroNF, Nil, Nil, Nil, dDataBase, 0, .T.)
	EndIf
	
	//Cálculo do pis, cofins e csll
	If __lPccBaix .And. !lPccMR
		aPcc	:= newMinPcc(dDataBase, nBaseImpos, SE1->E1_NATUREZ, "R", SE1->(E1_CLIENTE+E1_LOJA))
		nPis	:= aPcc[2]
		nCofins	:= aPcc[3]
		nCsll	:= aPcc[4]
		
		If Len(aPcc) > 4
			aTitCalc := aPcc[5]
		Endif
	EndIf	
	
	Begin Sequence
		If (__lPccBaix .And. !lPccMR .And. (nPisCalc+nCofCalc+nCslcalc) > 0) .Or. (lIrfPjBx .And. !lIrfMR .And. nIrfCalc > 0)
			nPisFin891 := nPis
			nCofFin891 := nCofins
			nCslFin891 := nCsll
			nIrfFin891 := nIrrf
			nImposBaix   := Iif(lIrfPjBx .And. !lIrfMR, nIrrf, 0) + Iif(__lPccBaix .And. !lPccMR, (nPis+nCofins+nCsll), 0)
			nImposBaix   := IIf(SE1->E1_MOEDA == 1, nImposBaix, Round(xMoeda(nImposBaix, 1, SE1->E1_MOEDA, dDataBase, __nCasasDc, 0, nTxMoeda), 2))
			
			Reclock("SE1",.F.)
			SE1->E1_SALDO  -= nImposBaix
			SE1->E1_VALLIQ := nImposBaix
			SE1->E1_BAIXA  := dDataBase
			SE1->(MsUnlock())
			
			cChaveTit := xFilial("SE1")+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
			cChaveFK7 := FinBuscaFK7(cChaveTit, "SE1", SE1->E1_FILORIG)
			
			//IRRF
			cSequencia := FaNxtSeqBx("SE1", .T.)
			If lIrfPjBx .And. !lIrfMR .And. nIrfCalc > 0
				Aadd(aImpostos, {"IRF", nIrfCalc, &(SuperGetMV("MV_IRF")), "", nIrrf, nIrfBaseC, nIrfBaseR, "", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CGC})
				
				If nIrrf > 0					
					FGrvIrRec(@nIrrf, nRegistroNF, .F., cSequencia, "FINA891", SE1->E1_MOEDA)
					SE1->(DbGoto(nRegistroNF))						
					
					cCamposE5 := "{"
					cCamposE5 += "{'E5_DTDIGIT',  dDataBase}"
					cCamposE5 += ",{'E5_PREFIXO', SE1->E1_PREFIXO}"
					cCamposE5 += ",{'E5_NUMERO',  SE1->E1_NUM}"
					cCamposE5 += ",{'E5_PARCELA', SE1->E1_PARCELA}"
					cCamposE5 += ",{'E5_CLIFOR',  SE1->E1_CLIENTE}"
					cCamposE5 += ",{'E5_CLIENTE', SE1->E1_CLIENTE}"
					cCamposE5 += ",{'E5_BENEF',   SE1->E1_NOMCLI}"
					cCamposE5 += ",{'E5_LOJA',    SE1->E1_LOJA}"
					cCamposE5 += ",{'E5_TIPO',    SE1->E1_TIPO}"
					cCamposE5 += ",{'E5_DTDISPO', dDatabase}"
					cCamposE5 += ",{'E5_VRETIRF', Val('" + cValToChar(nIrrf) + "')}"
					cCamposE5 += ",{'E5_PRETIRF', '4'}"
					cCamposE5 += "}"
					
					oModelBx := FWLoadModel("FINM010")
					oModelBx:SetOperation( MODEL_OPERATION_INSERT )
					oModelBx:Activate()
					oModelBx:SetValue("MASTER", "E5_GRV", .T.)
					oModelBx:SetValue("MASTER", "E5_CAMPOS", cCamposE5)
					oModelBx:SetValue("MASTER", "HISTMOV", STR0055)
					oModelBx:SetValue("MASTER", "NOVOPROC", .T.)
					oSubFKA := oModelBx:GetModel("FKADETAIL")
					
					If !oSubFKA:IsEmpty()
						oSubFKA:AddLine()
					Endif
					
					cIdFK1 := FWUUIDV4()
					oSubFKA:SetValue("FKA_IDORIG", cIdFK1)
					oSubFKA:SetValue("FKA_TABORI", "FK1")
					
					oSubFK1 := oModelBx:GetModel("FK1DETAIL")
					oSubFK3 := oModelBx:GetModel("FK3DETAIL")
					oSubFK4 := oModelBx:GetModel("FK4DETAIL")
					
					//Dados da baixa a pagar
					oSubFK1:SetValue("FK1_IDDOC" , cChaveFK7)
					oSubFK1:SetValue("FK1_IDFK1" , cIdFK1)
					oSubFK1:SetValue("FK1_DATA"  , dDatabase)
					oSubFK1:SetValue("FK1_NATURE", SE1->E1_NATUREZ)
					oSubFK1:SetValue("FK1_RECPAG", "R")
					oSubFK1:SetValue("FK1_TPDOC" , "BA")
					oSubFK1:SetValue("FK1_MOTBX" , "IRF")
					oSubFK1:SetValue("FK1_ORIGEM", cOrigem)
					oSubFK1:SetValue("FK1_SEQ"   , cSequencia )
					oSubFK1:SetValue("FK1_CCUSTO", SE1->E1_CCUSTO)
					oSubFK1:SetValue("FK1_DOC"   , F71->F71_IDTRAN)
					oSubFK1:SetValue("FK1_VALOR" , nIrrf)
					oSubFK1:SetValue("FK1_VLMOE2", nIrrf)
					oSubFK1:SetValue("FK1_MOEDA" , StrZero(1, 2))
					oSubFK1:SetValue("FK1_TXMOED", nTxMoeda)
					oSubFK1:SetValue("FK1_FILORI", SE1->E1_FILORIG)
					oSubFK1:SetValue("FK1_HISTOR", STR0055)
					
					If !oSubFK3:IsEmpty()
						oSubFK3:AddLine()
						oSubFK3:GoLine(oSubFK3:Length())
					Endif
					
					cIdFk3	:= FINFKSID('FK3', 'FK3_IDFK3')
					cIdFK4	:= FINFKSID('FK4', 'FK4_IDFK4')
					aImpostos[1,4] := cIdFK4
					
					oSubFK3:SetValue("FK3_IDFK3",  cIdFk3)
					oSubFK3:SetValue("FK3_DATA" ,  SE1->E1_EMISSAO)
					oSubFK3:SetValue("FK3_ORIGEM", cOrigem)
					oSubFK3:SetValue("FK3_IMPOS",  "IRF" )
					oSubFK3:SetValue("FK3_RECPAG", "R" )
					oSubFK3:SetValue("FK3_MOEDA",  "01" )
					oSubFK3:SetValue("FK3_VALOR",  nIrfCalc )
					oSubFK3:SetValue("FK3_NATURE", aImpostos[1][3])
					oSubFK3:SetValue("FK3_FILORI", SE1->E1_FILORIG)
					oSubFK3:SetValue("FK3_BASIMP", nIrfBaseC)
					oSubFK3:SetValue("FK3_IDORIG", cIdFK1)
					oSubFK3:SetValue("FK3_TABORI", "FK1")
					oSubFK3:SetValue("FK3_IDRET",  cIdFK4)
					
					If __lMotRet
						oSubFK3:SetValue("FK3_CODFKM", "" )
						oSubFK3:SetValue("FK3_CLIFOR", SA1->A1_COD )
						oSubFK3:SetValue("FK3_LOJA",   SA1->A1_LOJA )
						oSubFK3:SetValue("FK3_CGC",    SA1->A1_CGC )
						oSubFK3:SetValue("FK3_RAICGC", Substr(SA1->A1_CGC, 1, 8) )
					Endif
					
					//Gravo o relacionamento de retencao dos t¡tulos que tiveram impostos retidos na baixa atual
					FinFk3BCR(aTitCalc, aImpostos)
					
					If !oSubFK4:IsEmpty()
						oSubFK4:AddLine()
						oSubFK4:GoLine( oSubFK4:Length() )
					EndIf
					
					oSubFK4:SetValue("FK4_IDFK4",  cIdFK4)
					oSubFK4:SetValue("FK4_DATA",   dDataBase)
					oSubFK4:SetValue("FK4_ORIGEM", cOrigem)
					oSubFK4:SetValue("FK4_IMPOS",  "IRF")
					oSubFK4:SetValue("FK4_RECPAG", "R")
					oSubFK4:SetValue("FK4_MOEDA",  "01")
					oSubFK4:SetValue("FK4_VALOR",  nIrrf)
					oSubFK4:SetValue("FK4_NATURE", aImpostos[1][3])
					oSubFK4:SetValue("FK4_FILORI", SE1->E1_FILORIG)
					oSubFK4:SetValue("FK4_BASIMP", nIrfBaseR)
					
					If __lMotRet
						oSubFK4:SetValue("FK4_CODFKM", "")
						oSubFK4:SetValue("FK4_CLIFOR", SA1->A1_COD)
						oSubFK4:SetValue("FK4_LOJA",   SA1->A1_LOJA)
						oSubFK4:SetValue("FK4_CGC",    SA1->A1_CGC)
						oSubFK4:SetValue("FK4_RAICGC", Substr(SA1->A1_CGC, 1, 8))
					Endif
					
					//Gravo o relacionamento de retenção dos títulos
					FinFk3BCR(aTitCalc, aImpostos)
					
					If oModelBx:VldData()
						oModelBx:CommitData()
						SE5->(dbGoto(oModelBx:GetValue( "MASTER", "E5_RECNO" )))
						oModelBx:DeActivate()
					Else
						lRet := .F.
						cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[6])
						Help( ,,"F891IRFPIX",,cLog, 1, 0 )
					Endif
					
					oModelBx:DeActivate()
					oModelBx:Destroy()
					oModelBx := Nil
					cCamposE5 := ""
				Else
					FNGFK3BCR(1, "FK7", cChaveFK7, aImpostos)
				EndIf
			EndIf
			
			//PCC
			cSequencia := FaNxtSeqBx("SE1", .T.)
			If lRet .And. __lPccBaix .And. !lPccMR .And. ((nPisCalc+nCofCalc+nCslcalc) > 0)
				aImpostos := {}
				Aadd(aImpostos, {"PIS", nPisCalc, SuperGetMV("MV_PISNAT"), "", nPis,    nPisBaseC, nPisBaseR, "", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CGC})
				Aadd(aImpostos, {"COF", nCofCalc, SuperGetMV("MV_COFINS"), "", nCofins, nCofBaseC, nCofBaseR, "", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CGC})
				Aadd(aImpostos, {"CSL", nCslcalc, SuperGetMV("MV_CSLL")  , "", nCsll,   nCslBaseC, nCslBaseR, "", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CGC})
				
				If (nPis+nCofins+nCsll) > 0
					FGrvPccRec(@nPis, @nCofins, @nCsll, nRegistroNF, .F., .T., cSequencia, "FINA891", 1)
					SE1->(DbGoto(nRegistroNF))						
					
					cCamposE5 := "{"
					cCamposE5 += " {'E5_DTDIGIT' , dDataBase}"
					cCamposE5 += ",{'E5_PREFIXO' , SE1->E1_PREFIXO}"
					cCamposE5 += ",{'E5_NUMERO'  , SE1->E1_NUM}"
					cCamposE5 += ",{'E5_PARCELA' , SE1->E1_PARCELA}"
					cCamposE5 += ",{'E5_CLIFOR'  , SE1->E1_CLIENTE}"
					cCamposE5 += ",{'E5_CLIENTE' , SE1->E1_CLIENTE}"
					cCamposE5 += ",{'E5_BENEF'   , SE1->E1_NOMCLI}"
					cCamposE5 += ",{'E5_LOJA'    , SE1->E1_LOJA}"
					cCamposE5 += ",{'E5_TIPO'    , SE1->E1_TIPO}"
					cCamposE5 += ",{'E5_DTDISPO' , dDatabase}"
					cCamposE5 += ",{'E5_VRETPIS' , Val('" + cValToChar(nPis) + "')}"
					cCamposE5 += ",{'E5_VRETCOF' , Val('" + cValToChar(nCofins) +"')}"
					cCamposE5 += ",{'E5_VRETCSL' , Val('" + cValToChar(nCsll) + "')}"
					cCamposE5 += ",{'E5_PRETPIS' , '4'}"
					cCamposE5 += ",{'E5_PRETCOF' , '4'}"
					cCamposE5 += ",{'E5_PRETCSL' , '4'}"
					cCamposE5 += "}"
					
					oModelBx := FWLoadModel("FINM010")
					oModelBx:SetOperation( MODEL_OPERATION_INSERT)
					oModelBx:Activate()
					oModelBx:SetValue("MASTER", "E5_GRV", .T.)
					oModelBx:SetValue("MASTER", "E5_CAMPOS", cCamposE5)
					oModelBx:SetValue("MASTER", "HISTMOV", STR0054)
					oModelBx:SetValue("MASTER", "NOVOPROC", .T.)
					
					cIdFK1  := FWUUIDV4()
					oSubFKA := oModelBx:GetModel("FKADETAIL")
					
					oSubFKA:SetValue("FKA_IDORIG", cIdFK1)
					oSubFKA:SetValue("FKA_TABORI", "FK1")
					
					oSubFK1 := oModelBx:GetModel("FK1DETAIL")
					oSubFK4 := oModelBx:GetModel("FK4DETAIL")
					oSubFK3 := oModelBx:GetModel("FK3DETAIL")
					
					//Dados da baixa a pagar
					oSubFK1:SetValue("FK1_IDDOC",  cChaveFK7)
					oSubFK1:SetValue("FK1_IDFK1",  cIdFK1)
					oSubFK1:SetValue("FK1_DATA",   dDatabase)
					oSubFK1:SetValue("FK1_NATURE", SE1->E1_NATUREZ)
					oSubFK1:SetValue("FK1_RECPAG", "R")
					oSubFK1:SetValue("FK1_TPDOC",  "BA")
					oSubFK1:SetValue("FK1_MOTBX",  "PCC")
					oSubFK1:SetValue("FK1_ORIGEM", cOrigem)
					oSubFK1:SetValue("FK1_SEQ",    cSequencia)
					oSubFK1:SetValue("FK1_CCUSTO", SE1->E1_CCUSTO)
					oSubFK1:SetValue("FK1_DOC",    F71->F71_IDTRAN)
					oSubFK1:SetValue("FK1_VALOR",  (nPis+nCofins+nCsll))
					oSubFK1:SetValue("FK1_VLMOE2", (nPis+nCofins+nCsll))
					oSubFK1:SetValue("FK1_MOEDA",  StrZero(1, 2))
					oSubFK1:SetValue("FK1_TXMOED", nTxMoeda)
					oSubFK1:SetValue("FK1_FILORI", SE1->E1_FILORIG)
					oSubFK1:SetValue("FK1_HISTOR", STR0054)
					
					For nX := 1 to Len(aImpostos)
						If aImpostos[nX,2] > 0
							cIdFk3 := FINFKSID('FK3', 'FK3_IDFK3')
							
							//Houve retencao de impostos PCC
							If aImpostos[nX][5] > 0
								cIdFK4:= FINFKSID('FK4', 'FK4_IDFK4')
								aImpostos[nX,4] := cIdFK4
							Endif
							
							If !oSubFK3:IsEmpty()
								oSubFK3:AddLine()
								oSubFK3:GoLine( oSubFK3:Length() )
							Endif
							
							//Grava Imposto Calculado
							oSubFK3:SetValue("FK3_IDFK3",  cIdFK3)
							oSubFK3:SetValue("FK3_DATA",   dDataBase)
							oSubFK3:SetValue("FK3_ORIGEM", cOrigem)
							oSubFK3:SetValue("FK3_IMPOS",  aImpostos[nX][1])
							oSubFK3:SetValue("FK3_RECPAG", "R")
							oSubFK3:SetValue("FK3_MOEDA",  "01")
							oSubFK3:SetValue("FK3_VALOR",  aImpostos[nX][2])
							oSubFK3:SetValue("FK3_NATURE", aImpostos[nX][3])
							oSubFK3:SetValue("FK3_FILORI", SE1->E1_FILORIG)
							oSubFK3:SetValue("FK3_BASIMP", aImpostos[nX][6])
							oSubFK3:SetValue("FK3_IDORIG", cIdFK1)
							oSubFK3:SetValue("FK3_TABORI", "FK1")
							oSubFK3:SetValue("FK3_IDRET",  aImpostos[nX,4])
							
							If __lMotRet
								oSubFK3:SetValue("FK3_CODFKM", aImpostos[nX,8])
								oSubFK3:SetValue("FK3_CLIFOR", SA1->A1_COD)
								oSubFK3:SetValue("FK3_LOJA",   SA1->A1_LOJA)
								oSubFK3:SetValue("FK3_CGC",    SA1->A1_CGC)
								oSubFK3:SetValue("FK3_RAICGC", Substr(SA1->A1_CGC, 1, 8))
							Endif
							
							//Grava Imposto Retido
							If aImpostos[nX][5] > 0
								If !oSubFK4:IsEmpty()
									oSubFK4:AddLine()
									oSubFK4:GoLine(oSubFK4:Length())
								Endif
								
								oSubFK4:SetValue("FK4_IDFK4",  aImpostos[nx,4])
								oSubFK4:SetValue("FK4_DATA",   dDataBase)
								oSubFK4:SetValue("FK4_ORIGEM", cOrigem)
								oSubFK4:SetValue("FK4_IMPOS",  aImpostos[nx,1])
								oSubFK4:SetValue("FK4_RECPAG", "R")
								oSubFK4:SetValue("FK4_MOEDA",  "01")
								oSubFK4:SetValue("FK4_VALOR",  aImpostos[nX,5])
								oSubFK4:SetValue("FK4_NATURE", aImpostos[nX,3])
								oSubFK4:SetValue("FK4_FILORI", SE1->E1_FILORIG)
								oSubFK4:SetValue("FK4_BASIMP", aImpostos[nX][7])
								
								If __lMotRet
									oSubFK4:SetValue("FK4_CODFKM", aImpostos[nX,8])
									oSubFK4:SetValue("FK4_CLIFOR", SA1->A1_COD)
									oSubFK4:SetValue("FK4_LOJA",   SA1->A1_LOJA)
									oSubFK4:SetValue("FK4_CGC",    SA1->A1_CGC)
									oSubFK4:SetValue("FK4_RAICGC", Substr(SA1->A1_CGC, 1, 8))
								Endif
							Endif
						Endif
					Next nX
					
					If oModelBx:VldData()
						oModelBx:CommitData()
						SE5->(dbGoto(oModelBx:GetValue( "MASTER", "E5_RECNO" )))
						oModelBx:DeActivate()
					Else
						lRet := .F.
						cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[6])
						Help( ,,"F891PCCPIX",,cLog, 1, 0 )
					EndIf
					
					oModelBx:DeActivate()
					oModelBx:Destroy()
					oModelBx := Nil
					cCamposE5 := ""
				ElseIf (nPisCalc+nCofCalc+nCslCalc) > 0
					FNGFK3BCR(1, "FK7", cChaveFK7, aImpostos)
				EndIf
				
				For nX := 1 to Len(aTitCalc)
					FINGFK3BOR(2, aTitCalc[nX,1], aTitCalc[nX,2], aImpostos,.F.)
				Next nX
			EndIf
			
			If !lRet
				DisarmTransaction()
				BREAK
			Endif
		EndIf
	End Sequence
	
	RestArea(aAreaSE1)
	RestArea(aAreaAtual)
	FwFreeArray(aAreaSE1)
	FwFreeArray(aAreaAtual)	
Return lRet

/*/{Protheus.doc} NomeCli
//Informa o Nome do Cliente  

@author Rodrigo Franco	
@since  25/11/2020
@version 12.1.27
/*/
Static Function NomeCli(cFil as Character, cCli as Character, cLoj as Character)

	Local cRetorno as Character
	
	cRetorno := ""

	Default cFil := ""
	Default cCli := ""
	Default cLoj := ""

	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek(FwXFilial("SA1") + cCli + cLoj))
		cRetorno :=  AllTrim(SA1->A1_NOME)
	EndIf

Return cRetorno

/*/{Protheus.doc} ExistPix
Verifica se há títulos 

@author Edson Melo
@since  01/12/2020
@version 12.1.27
/*/
Static Function ExistPix() As Logical
	Local lRet 		As Logical
	Local cQuery   As Character
	
	//Inicializa variáveis
	lRet		:= .F.
	cQuery		:= ""

	cQuery += "SELECT COUNT(F71_FILIAL) F71NUM FROM " + RetSqlName("F71") + " F71 "
	cQuery += "WHERE F71.F71_FILIAL = '" + FWxFilial('F71') + "' "
	cQuery += "AND (F71.F71_STATUS = '1' OR (F71.F71_SOLCAN = '1' AND F71.F71_STATUS IN ('3', '4'))) "
	cQuery += " AND F71.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	lRet := MpSysExecScalar(cQuery, "F71NUM") > 0
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StruTela()
Função para a criação do array que contem a estrutura dos campos que 
serão exibidos na tela 3 e 4.

@author Adriano Sato
@since  01/12/2020
@version 12.1.027
/*/
Static Function StruTela(aCampos As Array, nTela As Numeric) As Array

	Local aColumns 	As Array
	Local nX 		As Numeric

	Default aCampos := {}
	Default nTela   := 0

	aColumns := {}

	For nX := 1 To Len(aCampos)
		If aCampos[nX] == 'F71_FILIAL'
			AAdd(aColumns,FwBrwColumn():New())  
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_FILIAL }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_FILIAL }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_FILIAL", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_FILIAL", "X3_TAMANHO"  ) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_FILIAL", "X3_DECIMAL"  ) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_FILIAL", "X3_PICTURE"  ) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_FILIAL", "X3_TIPO"		) )
		ElseIf aCampos[nX] == 'F71_PREFIX'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_PREFIX }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_PREFIX }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_PREFIX", "X3_TITULO"	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_PREFIX", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_PREFIX", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_PREFIX", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_PREFIX", "X3_TIPO"		) )
		ElseIf aCampos[nX] == 'F71_NUM'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_NUM }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_NUM }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_NUM", "X3_TITULO"  	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_NUM", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_NUM", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_NUM", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_NUM", "X3_TIPO" 		) )
		ElseIf aCampos[nX] == 'F71_PARCEL'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_PARCEL }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_PARCEL }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_PARCEL", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_PARCEL", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_PARCEL", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_PARCEL", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_PARCEL", "X3_TIPO"	   	) )
		ElseIf aCampos[nX] == 'F71_TIPO'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_TIPO }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_TIPO }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_TIPO", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_TIPO", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_TIPO", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_TIPO", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_TIPO", "X3_TIPO"	 	) )
		ElseIf aCampos[nX] == 'F71_VALOR'
			AAdd(aColumns,FwBrwColumn():New())  
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_VALOR }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_VALOR }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_VALOR", "X3_TITULO"  	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_VALOR", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_VALOR", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_VALOR", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_VALOR", "X3_TIPO"	  	) )
			aColumns[Len(aColumns)]:SetAlign( 2 ) 		// (0=Centralizado, 1=Esquerda ou 2=Direita)
		ElseIf aCampos[nX] == 'F71_VENCTO'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_VENCTO }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_VENCTO }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_VENCTO", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_VENCTO", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_VENCTO", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_VENCTO", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_VENCTO", "X3_TIPO"		) )
			aColumns[Len(aColumns)]:SetAlign( 0 ) 		// (0=Centralizado, 1=Esquerda ou 2=Direita)
		ElseIf aCampos[nX] == 'F71_CODCLI'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_CODCLI }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_CODCLI }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_CODCLI", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_CODCLI", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_CODCLI", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_CODCLI", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_CODCLI", "X3_TIPO"		) )
		ElseIf aCampos[nX] == 'F71_LOJCLI'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &('{|| (cTrabF71)->F71_LOJCLI }'		) )
			Else
				aColumns[Len(aColumns)]:SetData( &('{|| (cTraDF71)->F71_LOJCLI }'		) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_LOJCLI", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_LOJCLI", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_LOJCLI", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_LOJCLI", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_LOJCLI", "X3_TIPO"		) )
		ElseIf aCampos[nX] == 'F71_NOMCLI'
			AAdd(aColumns,FwBrwColumn():New())
			If nTela == 3
				aColumns[Len(aColumns)]:SetData( &("{|| NomeCli( (cTrabF71)->(F71_FILIAL), (cTrabF71)->(F71_CODCLI), (cTrabF71)->(F71_LOJCLI) )}"  ) )
			Else
				aColumns[Len(aColumns)]:SetData( &("{|| NomeCli( (cTraDF71)->(F71_FILIAL), (cTraDF71)->(F71_CODCLI), (cTraDF71)->(F71_LOJCLI) )}"  ) )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(   GetSX3Cache("F71_NOMCLI", "X3_TITULO" 	) )
			aColumns[Len(aColumns)]:SetSize(    GetSX3Cache("F71_NOMCLI", "X3_TAMANHO" 	) )
			aColumns[Len(aColumns)]:SetDecimal( GetSX3Cache("F71_NOMCLI", "X3_DECIMAL" 	) )
			aColumns[Len(aColumns)]:SetPicture( GetSX3Cache("F71_NOMCLI", "X3_PICTURE" 	) )
			aColumns[Len(aColumns)]:SetType(    GetSX3Cache("F71_NOMCLI", "X3_TIPO"    	) )
		EndIf
	Next nX

Return aColumns

/*/{Protheus.doc} APIPIXOn()
Verifica se a API PIX está habilitada.

@author Edson Melo
@since  19/02/2021
@version 12.1.027
/*/
Static Function APIPIXOn() As Logical	
	Local cChaveConf As Character
	Local cTenant    As Character
	Local cUser      As Character	
	Local cPass      As Character
	Local cExtBusId  As Character
	Local cPosId     As Character
	Local lPixApiOn	 As Logical
	
	//Inicializa variáveis.
	lPixApiOn  := .T.
	cChaveConf := cEmpAnt
	oConfig    := FwTFConfig()	
	cTenant    := oConfig["fin_tenant_PagamentosDigitais_" + cChaveConf]
	cUser      := AllTrim(oConfig["fin_user_PagamentosDigitais_" + cChaveConf])		
	cPass      := AllTrim(oConfig["fin_password_PagamentosDigitais_" + cChaveConf])
	cExtBusId  := AllTrim(oConfig["fin_extBusId_PagamentosDigitais_" + cChaveConf])	
	cPosId     := AllTrim(oConfig["fin_idpos_PagamentosDigitais_" + cChaveConf])
	lPixApiOn  := (!Empty(cTenant) .And. !Empty(cUser) .And. !Empty(cPass) .And. !Empty(cPosId) .And. !Empty(cExtBusId))	
	FreeObj(oConfig)
Return lPixApiOn 
