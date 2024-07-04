#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH' 
#Include "FINA692.CH"

#DEFINE INCLUSAO_PV 3

/*/{Protheus.doc}FINA692
Faturamento em Lote - Viagens.
@author William Matos 	
@since  24/06/2015
@version 12
/*/ 
Function FINA692()
Local aEnableButtons:= {} 

If Pergunte("FINA692", .T. )
	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	FWExecView( STR0001,'FINA692', MODEL_OPERATION_INSERT,,,,,aEnableButtons,,,,)
EndIf

Return

/*/{Protheus.doc}ModelDef
Modelo de dados - Faturamento em Lote.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Static Function ModelDef()
Local oModel 	:= MPFormModel():New('FINA692',/*Pre*/,{|oModel| F692Vld(oModel)},{|oModel|F692GRV(oModel)})
Local oMaster 	:= FWFormModelStruct():New()
Local oTotal 	:= Nil
Local oDet		:= Nil
Local oFL5	 	:= FWFormStruct(1, 'FL5')
Local oFL6		:= FWFormStruct(1, 'FL6')
Local aAux		:= {}

oMaster:AddTable('UUU',,STR0003) 
oMaster:AddField(	"CPOVIRTUAL",; //Título do campo
					"",; //cToolTip
					"CPOVIRTUAL",;// Id do Campo
					"C",; //cTipo
					1,; //Tamanho do Campo	
					0)//Decimal
oTotal := FN692Struct(1)
oDet   := FN693StrModel()   

oDet:SetProperty('FL6_COB', MODEL_FIELD_VALID , {|| .T. })
oFL5:SetProperty('FL5_NOME', MODEL_FIELD_INIT, { |oFL5| POSICIONE("SA1",1, XFILIAL("SA1")  + oFL5:GetValue("FL5_CLIENT") + oFL5:GetValue("FL5_LOJA"),"A1_NOME") })
//---Campo lógico na FL5 para selecionar os pedidos que serão faturados.
oFL5:AddField("","","FL5_MARK","L",1)
oFL5:AddTrigger( "FL5_MARK","FL5_MARK", {|| .T. }  , {|| FN692TotCli() }  )
oTotal:AddTrigger("YYY_LOJA","YYY_NOME",{|| .T. }, {|oModel|FN692ANome(oModel) })
oDet:AddTrigger( "FL6_PORC","FL6_PORC", {|| .T. }  , {|x| FN692Recalc(oModel) }  )
//
oModel:AddFields('MASTER',/*cOwner*/ , oMaster)
oFL5:SetProperty('*' , MODEL_FIELD_OBRIGAT ,  .F.  )
//Cria campo natureza para a estrutura.
FN693ACPO(1,oFL5)
//
oModel:AddGrid('FL5DETAIL', 'MASTER' , oFL5, {|oModel,nLine,cAction,cField,xValue,xOldValue| F692FL5Pre( oModel, nLine, cAction, cField, xValue, xOldValue)})
//
oDet:AddTrigger('FL6_PORC','FL6_COB',{||.T.}, {|x,y| F693PorCli(oModel:GetModel('FL6DETAIL'),1)}) 
oDet:AddTrigger('FL6_COB','FL6_PORC',{||.T.}, {|x,y| F693PorCli(oModel:GetModel('FL6DETAIL'),2)}) 
//
oModel:AddGrid('FL6DETAIL', 'FL5DETAIL', oDet)
oModel:AddGrid('TOTALIZADOR', 'MASTER', oTotal)
//Relacionamento FL6 -> FL5
aAdd(aAux,{'FL6_VIAGEM','FL5_VIAGEM'})
oModel:SetRelation( 'FL6DETAIL', aAux , FL6->(IndexKey(1)))
//
oModel:GetModel('TOTALIZADOR'):SetOnlyQuery(.T.)
oModel:GetModel('MASTER'):SetOnlyQuery(.T.)
oModel:GetModel("MASTER"):SetPrimaryKey({})
oModel:GetModel('TOTALIZADOR'):SetOptional( .T. )
oModel:GetModel('FL5DETAIL'):SetOptional( .T. )
oModel:GetModel('FL6DETAIL'):SetOptional( .T. )
oModel:SetActivate( {|oModel| F692LoadFat(oModel) } )
//
Return oModel

/*/{Protheus.doc}ViewDef
Interface - Faturamento em Lote.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	 
Static Function ViewDef()
Local oView  := FWFormView():New()
Local oModel := FWLoadModel('FINA692')
Local oFL5	 := FWFormStruct(2, 'FL5')
Local oDet	 := Nil	
Local oTotal := Nil
Local nX	 := 0
Local aAux	 := aClone(oFL5:GetFields())

For nX := 1 To Len(aAux)
	If !aAux[nX][1] $ 'FL5_VIAGEM|FL5_CLIENT|FL5_LOJA|FL5_DTINI|FL5_DTFIM|FL5_NACION'
		oFL5:RemoveField( aAux[nX][1] )
	EndIf
Next nX

oFL5:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )

//Limpa variavel da memoria.
aSize( aAux, 0 )
aAux := {}
//---Campo lógicoadmi na FL5 para selecionar os pedidos que serão faturados.
oFL5:AddField("FL5_MARK","01","","",{},"L")//cPicture
//
oTotal := FN692Struct(2)
oDet   := FN693StrView()   
oView:SetModel( oModel )
//Cria campo natureza para a estrutura.
FN693ACPO(2,oFL5)
//
oView:AddGrid('VIEW_FL5', oFL5, 'FL5DETAIL' )
oView:AddGrid('VIEW_FL6', oDet, 'FL6DETAIL' )
oView:AddGrid('VIEW_TOT', oTotal,'TOTALIZADOR') 
//
oView:CreateHorizontalBox( 'BOXFL5', 35 )
oView:CreateHorizontalBox( 'BOXFL6', 37 )
oView:CreateHorizontalBox( 'BOXTOT', 28 )
//
oView:SetOwnerView('VIEW_FL5','BOXFL5') 
oView:SetOwnerView('VIEW_TOT','BOXTOT')
oView:SetOwnerView('VIEW_FL6','BOXFL6')
oView:EnableTitleView('VIEW_TOT' , STR0003 ) //Total por cliente 
oView:EnableTitleView('VIEW_FL6' , STR0004 ) //Detalhes
oView:EnableTitleView('VIEW_FL5' , STR0005 ) //Viagens
oView:SetNoInsertLine('VIEW_FL6')
oView:SetNoInsertLine('VIEW_FL5')
oView:SetNoInsertLine('VIEW_TOT')
oView:SetNoDeleteLine('VIEW_TOT')
oView:SetNoDeleteLine('VIEW_FL5')
oView:SetNoDeleteLine('VIEW_FL6')
oView:SetViewCanActivate( {|| FN692Alias() } )

Return oView

/*/{Protheus.doc}FN692Struct
Função responsavel por criar a estrutura temporaria do totalizador dos faturamentos.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FN692Struct(nType)
Local oStruct := Nil 

If nType == 1 //Model
	
	oStruct := FWFormModelStruct():New()
	oStruct:AddTable('YYY',,'TMP') //Estrutura temporaria.
	
	If ExistBlock("F692STRU")
		oStruct := ExecBlock("F692STRU",.F.,.F.,{oStruct})
	Else
		//Cliente
		oStruct:AddField("Cliente","","YYY_CLIENTE","C",6)
		//Loja
		oStruct:AddField("Loja","","YYY_LOJA","C",2)
		//Nome
		oStruct:AddField("Nome","","YYY_NOME","C",50)
		//Total
		oStruct:AddField("Total","","YYY_TOTFAT","N",14,2)

	Endif

Else //View

	oStruct := FWFormViewStruct():New()
	//Cliente
	oStruct:AddField("YYY_CLIENTE","01",STR0006,STR0006,{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F.) 
	//Loja
	oStruct:AddField("YYY_LOJA","02",STR0007,STR0007,{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F.)  
	//Nome
	oStruct:AddField("YYY_NOME","02",STR0008,STR0008,{},"C","@!",/*bPictVar*/,/*cLookUp*/,.F.) 
	//Total
	oStruct:AddField("YYY_TOTFAT","05",STR0009,STR0009,{},"N","@E 99,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.F.) 
	
EndIf

Return oStruct

/*/{Protheus.doc}FN692Struct
Carrega os dados no modelo de dados.
@param oModel - Modelo de dados.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function F692LoadFat( oModel )
Local oSubFL5	:= oModel:GetModel('FL5DETAIL')
Local oSubFL6	:= oModel:GetModel('FL6DETAIL')
Local lRet	 	:= .T.
Local cQuery 	:= ""
Local nPorc		:= 0
Local cAliasFL5 := GetNextAlias()
Local lFatAnt 	:= SupergetMv("MV_RESFTAN",.T.,"2") == "1"
Local cProd     := SupergetMv("MV_RESPROD",.T.,"   ")
Local nValConfe	:= 0
//
oSubFL5:SetNoInsertLine( .F. )
oSubFL6:SetNoInsertLine( .F. )
oModel:SetValue("MASTER","CPOVIRTUAL","1")
dbSelectArea("FL6")
FL6->(dbSetOrder(1))
dbSelectArea("FLF")
FLF->(dbSetOrder(2))
cQuery := "SELECT FL5_VIAGEM, FL5_DTINI, FL5_DTFIM, FL5_CLIENT, FL5_LOJA, FL5_NACION" + CRLF
cQuery += "FROM " 	 + RetSQLTab('FL5') + CRLF
cQuery += "WHERE " + CRLF
cQuery += "FL5_PEDIDO = '' AND "  + CRLF //Não pode ter pedido gerado.
cQuery += "FL5_DTINI >= '" + DTOS(MV_PAR01)+ "' AND " + CRLF
cQuery += "FL5_DTFIM <= '" + DTOS(MV_PAR02)+ "' AND " + CRLF
cQuery += "FL5_VIAGEM BETWEEN '"+ MV_PAR03 + "' AND '"+ MV_PAR04 + "' AND " + CRLF
cQuery += "FL5_CLIENT BETWEEN '"+ MV_PAR05 + "' AND '"+ MV_PAR07 + "' AND " + CRLF
cQuery += "FL5_LOJA   BETWEEN '"+ MV_PAR06 + "' AND '"+ MV_PAR08 + "' AND " + CRLF
cQuery += "FL5.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFL5,.T.,.T.)
dbSelectArea(cAliasFL5)
(cAliasFL5)->(DbGotop())
While (cAliasFL5)->(!Eof())
	FL6->(dbSeek(xFilial("FL6") + (cAliasFL5)->FL5_VIAGEM ))
	If lFatAnt .OR. FL6->FL6_STATUS == '2'//Tratamento faturamento antecipado
		If !oSubFL5:IsEmpty()
			oSubFL5:AddLine()
		EndIf
		oSubFL5:LoadValue('FL5_VIAGEM'	, (cAliasFL5)->FL5_VIAGEM 	)
		oSubFL5:LoadValue('FL5_CLIENT'	, (cAliasFL5)->FL5_CLIENT 	)
		oSubFL5:LoadValue('FL5_LOJA'	, (cAliasFL5)->FL5_LOJA 	)
		oSubFL5:LoadValue('FL5_DTINI'	, STOD((cAliasFL5)->FL5_DTINI) 	)
		oSubFL5:LoadValue('FL5_DTFIM'	, STOD((cAliasFL5)->FL5_DTFIM) 	)
		oSubFL5:LoadValue('FL5_NACION'	, (cAliasFL5)->FL5_NACION 	)
		
	
		//Grava o submodelo temporario, com os detalhes da viagem.
	
		While FL6->(!Eof()) .AND. FL6->FL6_FILIAL = xFilial("FL6") .AND. FL6->FL6_VIAGEM = (cAliasFL5)->FL5_VIAGEM
	
				nValConfe	:= If (lFatAnt .AND. FL6->FL6_VCONFE <= 0,FL6->FL6_TOTAL, FL6->FL6_VCONFE)
				//
				If !oSubFL6:IsEmpty()
					oSubFL6:AddLine()
				EndIf
				nPorc := FN693PClie((cAliasFL5)->FL5_VIAGEM, FL6->FL6_ITEM)
				oSubFL6:LoadValue('FL6_VIAGEM', (cAliasFL5)->FL5_VIAGEM )
				oSubFL6:LoadValue('FL6_DESC'  , STR0014 + AllTrim(FL6->FL6_IDRESE) )	
				oSubFL6:LoadValue('FL6_VALOR' , nValConfe)	
				oSubFL6:LoadValue('FL6_PORC'  , nPorc) 
				oSubFL6:LoadValue('FL6_COB'   , nValConfe * nPorc / 100)
				oSubFL6:LoadValue('FL6_PROD'  , AllTrim(cProd))
				oSubFL6:LoadValue('FL6_TES'   , F693IniTES(FL5->FL5_CLIENT,FL5->FL5_LOJA))				
			FL6->(dbSkip())
			//
	
						
		EndDo
		
		FLF->(dbSeek(xFilial("FLF") + (cAliasFL5)->FL5_VIAGEM ))
		While FLF->(!Eof()) .AND. FLF->FLF_FILIAL = xFilial("FLF") .AND. FLF->FLF_VIAGEM = (cAliasFL5)->FL5_VIAGEM
			//Grava o submodelo temporario, com os detalhes das prestações de contas relacionadas a viagem.
			If !oSubFL6:IsEmpty()
				oSubFL6:AddLine()
			EndIf
			//
			nPorc := 100//FLF->FLF_FATCLI
			oSubFL6:LoadValue('FL6_VIAGEM', (cAliasFL5)->FL5_VIAGEM )
			oSubFL6:LoadValue('FL6_DESC'  , STR0013 + AllTrim(FLF->FLF_PRESTA) )	
			oSubFL6:LoadValue('FL6_VALOR' , FLF->(FLF_TDESP1 - FLF_TDESC1)   )	
			oSubFL6:LoadValue('FL6_PORC'  , 75 )  
			oSubFL6:LoadValue('FL6_COB'   , (FLF->(FLF_TDESP1 - FLF_TDESC1) * nPorc / 100))	
			oSubFL6:LoadValue('FL6_PROD'  , AllTrim(cProd))
			oSubFL6:LoadValue('FL6_TES'   , F693IniTES(FL5->FL5_CLIENT,FL5->FL5_LOJA))				
			FLF->(dbSkip())
			//
		EndDo
	//
	endif
	(cAliasFL5)->(dbSkip())

EndDo

oSubFL5:SetNoInsertLine( .T. )
oSubFL6:SetNoInsertLine( .T. )

Return lRet

/*/{Protheus.doc}FN692TotCli
Resumo do total de faturamento por cliente.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FN692TotCli()
Local oModel	:= FWModelActive() 
Local oView		:= FWViewActive()
Local oAux		:= oModel:GetModel('TOTALIZADOR')
Local oAuxFL5	:= oModel:GetModel('FL5DETAIL')
Local oAuxFL6	:= oModel:GetModel("FL6DETAIL")
Local lMark		:= oModel:GetValue('FL5DETAIL','FL5_MARK')
Local nValor	:= 0
Local cRet 		:= ""
Local nX		:= 0

oAux:SetNoInsertLine( .F. )

For nX := 1 To oAuxFL6:Length()
	nValor += oAuxFL6:GetValue('FL6_COB', nX)
Next nX

If nValor > 0
	If oAux:SeekLine({{"YYY_CLIENTE",oAuxFL5:GetValue("FL5_CLIENT")},{"YYY_LOJA",oAuxFL5:GetValue('FL5_LOJA') }} )

		If lMark 
			oAux:SetValue("YYY_TOTFAT" , oAux:GetValue("YYY_TOTFAT") + nValor)
		ELse 
			oAux:SetValue("YYY_TOTFAT" , oAux:GetValue("YYY_TOTFAT") - nValor)
		
			If Empty(oAux:GetValue("YYY_TOTFAT"))
				oAux:SetNoDeleteLine(.F.)
				oAux:DeleteLine()
				oAux:SetNoDeleteLine(.T.)
			EndIf 
		
		EndIf
	
	Else
		If !oAux:IsEmpty()
			oAux:AddLine()	
		EndIf
		//
		oAux:SetValue("YYY_CLIENTE" , oAuxFL5:GetValue("FL5_CLIENT") )
		oAux:SetValue("YYY_LOJA" 	, oAuxFL5:GetValue("FL5_LOJA"  ) )
		oAux:SetValue("YYY_TOTFAT"  , nValor )	
		//
	EndIf
Endif

oAux:SetNoInsertLine( .T. )
oAux:SetLine(1)
oView:Refresh()

Return cRet

/*/{Protheus.doc}F692FL5Pre
Valida os dados digitados no cabeçalho (FL5 master)
@author Marcello Gabriel 	
@since  26/08/2015
@version 12
/*/	
Function F692FL5Pre(oModel,nLine,cAction,cField,xValue,xOldValue)
Local lRet		:= .T.
Local oAuxFL6	:= Nil
Local oModAux	:= Nil
Local nX		:= 0
Local nLenFL6	:= 0

If AllTrim(cField) == "FL5_MARK"
	If !xOldValue
		oModAux	:= FWModelActive()
		oAuxFL6 := oModAux:GetModel("FL6DETAIL")
		nLenFL6 := oAuxFL6:Length()
		lRet := .F.
		While nX < nLenFL6 .And. !lRet
			nX++
			lRet := (oAuxFL6:GetValue('FL6_COB', nX) > 0)
		Enddo
		If !lRet			
			Help("  ",1,"VLDMOD",,STR0025 + CRLF,1,0)		//"Este item não possui valores para faturamento." 			
		Endif
	Endif
Endif
Return(lRet)


/*/{Protheus.doc}F692GRV
Gravação do modelo de dados.
@author William Matos 	
@since  24/06/2015
@param oModel - Modelo de dados.
@version 12
/*/	
Function F692GRV(oModel)
Local cCond     := SupergetMv("MV_RESCPGT",.T.,"   ")
Local cTes		:= ""
Local cTes1     := SupergetMv("MV_RESTES1",.T.,"   ")
Local cTes2     := SupergetMv("MV_RESTES2",.T.,"   ")
Local cProd     := SupergetMv("MV_RESPROD",.T.,"   ")
Local cItem		:= "00"
Local cUnMed	:= "" 
Local nValor	:= 0
Local aCab    	:= {}
Local aItens  	:= {}
Local aAux	  	:= {}	
Local aArea 	:= GetArea()
Local lRet 		:= .T.
Local lAglutina	:= MV_PAR09 == 1
Local cMsgNota	:= ""
Local nX		:= 0
Local nY		:= 1
Local nZ		:= 0
Local oTotal	:= oModel:GetModel("TOTALIZADOR")
Local oFL5		:= oModel:GetModel("FL5DETAIL")
Local oFL6		:= oModel:GetModel("FL6DETAIL")

Private  lMsErroAuto := .F.

DbSelectArea("SC5")
DbSelectArea("SC6")
DbSelectArea("SA1")

//Produto.
SB1->(dbSetOrder(1))
DBSeek(xFilial("SB1") + cProd)
cUnMed := SB1->B1_UM

If lAglutina

	nX := 1
	While nX <= oTotal:Length() .AND. lRet .AND. !oTotal:IsDeleted(nX)
	
		SA1->(dbSetOrder(1))
		SA1->(DBSeek(xFilial("SA1") + oTotal:GetValue('YYY_CLIENTE', nX) + oTotal:GetValue('YYY_LOJA'  , nX)))
		cTes := If(SA1->A1_RESFAT = '1', cTes1, cTes2)
			
		//Cabecalho do Pedido de Venda³
		aAdd( aCab, { "C5_FILIAL" 	,xFilial("SC5")	,Nil } )
		aAdd( aCab, { "C5_TIPO"   	,"N"			,Nil } )
		aAdd( aCab, { "C5_CLIENTE"  ,oTotal:GetValue("YYY_CLIENTE", nX),Nil})
		aAdd( aCab, { "C5_LOJACLI" 	,oTotal:GetValue("YYY_LOJA"  , nX),Nil})
		aAdd( aCab, { "C5_CONDPAG"	,cCond			,Nil } )
		aAdd( aCab, { "C5_EMISSAO"	,dDataBase  	,Nil } )
		aAdd( aCab, { "C5_MENNOTA" 	,cMsgNota		,Nil } )
		aAdd( aCab, { "C5_ORIGEM" 	,FunName()		,Nil } )
		aAdd( aCab, { "C5_NATUREZ"  ,oFL5:GetValue('NATUREZ'),Nil})
		
		nY := 1
		While nY <= oFL5:Length() 
		
			If  oTotal:GetValue('YYY_CLIENTE', nX) == oFL5:GetValue("FL5_CLIENT", nY) .AND. oFL5:GetValue("FL5_MARK", nY)
				//
				oFL5:SetLine( nY )
				For nZ := 1 To oFL6:Length()

					aAux 	:= {}
					cItem	:= Soma1(cItem)	
					aAdd( aAux, { "C6_FILIAL"   ,xFilial( "SC6" )			,Nil } )
					aAdd( aAux, { "C6_ITEM"   	,cItem						,Nil } )
					aAdd( aAux, { "C6_UM"    	,cUnMed						,Nil } )
					aAdd( aAux, { "C6_CLI"   	,oTotal:GetValue('YYY_CLIENTE'	,nX),Nil } )
					aAdd( aAux, { "C6_LOJA"  	,oTotal:GetValue('YYY_LOJA'	  	,nX),Nil } )	
					aAdd( aAux, { "C6_PRODUTO"	,oFL6:GetValue("FL6_PROD"	 	,nZ),Nil } )	
					aAdd( aAux, { "C6_QTDVEN"  	,1   			       			   	,Nil } )
					aAdd( aAux, { "C6_PRCVEN"  	,oFL6:GetValue("FL6_COB"		,nZ),Nil } )
					aAdd( aAux, { "C6_PRUNIT"  	,oFL6:GetValue("FL6_COB"		,nZ),Nil } )
					aAdd( aAux, { "C6_TES"   	,oFL6:GetValue("FL6_TES"		,nZ),Nil } )
					aAdd( aItens, aClone(aAux) )
			
				Next nZ

			EndIf
				
			nValor	:= 0
			nY++
		EndDo
		
		//Inclusao do pedido de venda³
		lMSERROAUTO := .F.
		lMSHELPAUTO	:= .T.
		nAnt := MAFISSAVE()
		MAFISEND()
	
		MsgRun( STR0011, STR0012, { | | MsExecAuto( { | x, y, z | mata410( x, y, z ) }, aCab, aItens, INCLUSAO_PV ) } ) //"Gerando Pedido(s)."###"Aguarde..."
		If lMSERROAUTO
			lRet	:= .F.
			MostraErro()		
			Help(" ",1,"VLDMOD",,STR0010,1,0)		//"Erro ao processar o pedido de venda"
		Else
			For nZ := 1 To oFL5:Length() 
				oFL5:SetLine(nZ)
				oFL5:SetValue("FL5_PEDIDO",SC5->C5_NUM )
			Next nZ
		EndIf
		//
		aSize(aCab,   0)
		aSize(aItens, 0)
		aSize(aAux,   0)
		aItens	:= {}
		aCab 	:= {}
		aAux	:= {}
			
		nX++
	EndDo
	
Else

	nX := 1
	While nX <= oFL5:Length() .AND. lRet
			
		If oFL5:GetValue('FL5_MARK', nX)
		
			oFL5:SetLine( nX )
			
			//Cabecalho do Pedido de Venda³
			aAdd( aCab, { "C5_FILIAL" 	,xFilial("SC5")	,Nil } )
			aAdd( aCab, { "C5_TIPO"   	,"N"			,Nil } )
			aAdd( aCab, { "C5_CLIENTE"  ,oFL5:GetValue('FL5_CLIENT', nX),Nil})
			aAdd( aCab, { "C5_LOJACLI" 	,oFL5:GetValue('FL5_LOJA'  , nX),Nil})
			aAdd( aCab, { "C5_CONDPAG"	,cCond			,Nil } )
			aAdd( aCab, { "C5_EMISSAO"	,dDataBase  	,Nil } )
			aAdd( aCab, { "C5_MENNOTA" 	,cMsgNota		,Nil } )
			aAdd( aCab, { "C5_ORIGEM" 	,FunName()		,Nil } )
			aAdd( aCab, { "C5_NATUREZ"  ,oFL5:GetValue('NATUREZ', nX),Nil})
		
			For nY := 1 To oFL6:Length()

				//Itens do Pedido de Venda
				aAux 	:= {}
				cItem   := Soma1(cItem)
				aAdd( aAux, { "C6_FILIAL"   ,xFilial( "SC6" )	,Nil } )
				aAdd( aAux, { "C6_ITEM"   	,cItem				,Nil } )
				aAdd( aAux, { "C6_UM"    	,cUnMed				,Nil } )
				aAdd( aAux, { "C6_CLI"   	,oFL5:GetValue('FL5_CLIENT'	, nX),Nil } )
				aAdd( aAux, { "C6_LOJA"  	,oFL5:GetValue('FL5_LOJA'  	, nX),Nil } )	
				aAdd( aAux, { "C6_PRODUTO"	,oFL6:GetValue("FL6_PROD"  	, nY),Nil } )	
				aAdd( aAux, { "C6_QTDVEN"  	,1   			       			 ,Nil } )
				aAdd( aAux, { "C6_PRCVEN"  	,oFL6:GetValue("FL6_COB"	, nY),Nil } )
				aAdd( aAux, { "C6_PRUNIT"  	,oFL6:GetValue("FL6_COB"	, nY),Nil } )
				aAdd( aAux, { "C6_TES"   	,oFL6:GetValue("FL6_TES"	, nY),Nil } )
				aAdd( aItens, aClone(aAux) )

			Next nY
			//Inclusao do pedido de venda³
			lMSERROAUTO := .F.
			lMSHELPAUTO	:= .T.
			nAnt := MAFISSAVE()
			MAFISEND()
		
			MsgRun( STR0011, STR0012, { | | MsExecAuto( { | x, y, z | mata410( x, y, z ) }, aCab, aItens, INCLUSAO_PV ) } ) //"Gerando Pedido(s)."###"Aguarde..."
			//
			aSize(aCab,   0)
			aSize(aItens, 0)
			aSize(aAux,   0)
			aItens	:= {}
			aCab 	:= {}
			aAux	:= {}
			//
			If lMsErroAuto 
				MostraErro()
				Help(" ",1,"VLDMOD",,STR0010,1,0)		//"Erro ao processar o pedido de venda"
				lRet := .F.    
			Else
				oFL5:SetValue("FL5_PEDIDO", SC5->C5_NUM )
			Endif
		EndIf
		nX++
	EndDo
EndIf

//Atualiza o status do adiantamento, prestação de contas e viagem.
If lRet

	For nX := 1 To oFL5:Length()
	
		If oFL5:GetValue("FL5_MARK", nX)
		
			FL5->(dbSeek(xFilial("FL5") + oFL5:GetValue("FL5_VIAGEM", nX)))
			RecLock("FL5",.F.)
			FL5->FL5_PEDIDO := oFL5:GetValue("FL5_PEDIDO", nX)
			if (SupergetMv("MV_RESFTAN",.T.,"2") == "1") .and. (!FN693PedFina(FL5->FL5_VIAGEM))
				FL5->FL5_STATUS := '7'
			else
				FL5->FL5_STATUS := '3'
			endif
			MsUnlock()     
			
			dbSelectArea("FLF")
			dbSetOrder(2)
			dbSeek(xFilial("FLF") + oFL5:GetValue("FL5_VIAGEM", nX ))
			While !Eof() .and. FLF->FLF_FILIAL = xFilial("FLF")  .and. FLF->FLF_VIAGEM = oFL5:GetValue("FL5_VIAGEM", nX ) 
			 	RecLock("FLF",.F.)
			 	FLF->FLF_STATUS := "9"
			 	dbSkip()
			EndDo     	
			
			dbSelectArea("FLD")
			dbSetOrder(1)
			dbSeek(xFilial("FLD") + oFL5:GetValue("FL5_VIAGEM", nX ))
			While !Eof() .and. FLD->FLD_FILIAL = xFilial("FLD")  .and. FLD->FLD_VIAGEM = oFL5:GetValue("FL5_VIAGEM", nX ) 
			 	RecLock("FLD",.F.)
			 	FLD->FLD_STATUS := "5"
			 	dbSkip()
			EndDo
		
		EndIf	
		 
	Next nX

EndIf

Return lRet

/*/{Protheus.doc}F692VLD
Verifica os dados para gravação do modelo.
@author Marcello Gabriel 	
@since  25/08/2015
@param oModel - Modelo de dados.
@version 12
/*/	
Function F692VLD(oModel)
Local cCond     := SupergetMv("MV_RESCPGT",.T.,"   ")
Local cTes1     := SupergetMv("MV_RESTES1",.T.,"   ")
Local cTes2     := SupergetMv("MV_RESTES2",.T.,"   ")
Local cProd     := SupergetMv("MV_RESPROD",.T.,"   ")
Local aArea 	:= GetArea()
Local lRet 		:= .F.
Local cMsg		:= ""
Local nX		:= 0
Local nLenTot	:= 0
Local oTotal	:= Nil

/* Verifica os dados para o faturamento */

/* Verifica se ha itens marcados para faturar */
oTotal	:= oModel:GetModel("TOTALIZADOR")
nLenTot := oTotal:Length()
nX := 0
lRet := .F.
While nX < nLenTot .And. !lRet
	nX++
	lRet := !oTotal:IsDeleted(nX) .And. oTotal:GetValue("YYY_TOTFAT",nX) > 0
Enddo

If lRet
	/* Validacao do TES */

	If Empty(cTes1) .And. Empty(cTes2)
		cMsg += STR0016 + CRLF		//"TES não foi informado."
	Else
		SF4->(DbSetOrder(1))
		If cTes1 > "500"
			If !Empty(cTes1) .And. !(SF4->(DbSeek(xFilial("SF4") + cTes1)))
				cMsg += STR0017 + ": " + cTes1 + CRLF		//"TES não foi encontrado" 
			Endif
		Else
			cMsg += STR0026 + ": " + cTes1 + CRLF		//"Código de TES inválido (deve ser >= 501)" 
		Endif
		If cTes2 > "500"
			If !Empty(cTes2) .And. !(SF4->(DbSeek(xFilial("SF4") + cTes2)))
				cMsg += STR0017 + ": " + cTes2 + CRLF		//"TES não foi encontrado" 
			Endif
		Else
			cMsg += STR0026 + ": " + cTes2 + CRLF		//"Código de TES inválido (deve ser >= 501)" 
		Endif
	Endif
  
	/*
	Validacao da condicao de pagamento */
	If Empty(cCond)
		cMsg += STR0018 + CRLF		//"Condição de pagamento não informada." 
	Else
		SE4->(DbSetOrder(1))
		If !(SE4->(DbSeek(xFilial("SE4") + cCond)))
			cMsg += STR0019 + ": " + AllTrim(cCond) + CRLF		//"Condição de pagamento não encontrada"
		Endif
	Endif
	/*
	Validacao do codigo do produto */
	If Empty(cProd)
		cMsg += STR0020 + CRLF		//"Código do produto não informado."
	Else
		SB1->(DbSetOrder(1))
		If !(SB1->(DbSeek(xFilial("SB1") + cProd)))
			cMsg += STR0021 + ": " + Alltrim(cProd) + CRLF	//"Código de produto não encontrado" 
		Endif
	Endif	
	If !Empty(cMsg)
		lRet := .F.
		cMsg := STR0022 + ":" + CRLF + CRLF + cMsg + CRLF + CRLF + STR0023		//"Foram encontadas as seguintes inconsistências que impedem a geração do pedido"###'Utilize o assitente de configuração de viagens, item  "Faturamento", para solucioná-las.'	
		Help("  ",1,"VLDMOD",,cMsg,1,0)
	Else
		lRet := .T.
	Endif
Else
	lRet := .F.
	Help("  ",1,"VLDMOD",,STR0024 + CRLF,1,0)		//"Não há viagens selecionadas para geração do pedido." 
Endif
/*-*/
RestArea(aArea)
Asize(aArea,0)
aArea := Nil
Return(lRet)


/*/{Protheus.doc}FN692Alias
Verifica se a view pode ser ativa.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FN692Alias()
Local cAliasFL5 := GetNextAlias()
Local cQuery	  := ""
Local lRet		  := .T.

	dbSelectArea("FL6")
	FL6->(dbSetOrder(1))
	dbSelectArea("FLF")
	FLF->(dbSetOrder(2))
	cQuery := "SELECT FL5_VIAGEM, FL5_DTINI, FL5_DTFIM, FL5_CLIENT, FL5_LOJA, FL5_NACION" + CRLF
	cQuery += "FROM " 	 + RetSQLTab('FL5') + CRLF
	cQuery += "LEFT JOIN" + RetSQLTab('FL6') + "ON FL6_VIAGEM = FL5_VIAGEM " + CRLF
	cQuery += "LEFT JOIN" + RetSQLTab('FLF') + "ON FLF_VIAGEM = FL5_VIAGEM " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "FL5_PEDIDO = '' AND "  + CRLF //Não pode ter pedido gerado.
	cQuery += "FLF_STATUS = '8' AND " + CRLF //Prestação de Contas Finalizada.
	If (SupergetMv("MV_RESFTAN",.T.,"2") == "2")
		cQuery += "FL6_STATUS = '2' AND " + CRLF //Valores do Pedido Conferidos.
	EndIf
	cQuery += "FL5_DTINI >= '" + DTOS(MV_PAR01)+ "' AND " + CRLF
	cQuery += "FL5_DTFIM <= '" + DTOS(MV_PAR02)+ "' AND " + CRLF
	cQuery += "FL5_VIAGEM BETWEEN '"+ MV_PAR03 + "' AND '"+ MV_PAR04 + "' AND " + CRLF
	cQuery += "FL5_CLIENT BETWEEN '"+ MV_PAR05 + "' AND '"+ MV_PAR07 + "' AND " + CRLF
	cQuery += "FL5_LOJA   BETWEEN '"+ MV_PAR06 + "' AND '"+ MV_PAR08 + "' AND " + CRLF
	cQuery += "FL5.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFL5,.T.,.T.)
	dbSelectArea(cAliasFL5)
	(cAliasFL5)->(DbGotop())
	lRet := (cAliasFL5)->(!Eof())
	If !lRet
		Help(" ",1,"VIAGEM",,STR0015,1,0)		
	EndIf
//	
Return lRet

/*/{Protheus.doc}FN692Recalc
Realiza o recalculo do total por cliente.
@author William Matos 	
@since  13/11/2015
@version 12
/*/	
Function FN692Recalc(oModel)
Local oAuxTot := Nil
Local oAuxFL6 := Nil
Local oAuxFL5 := Nil
Local nX		:= 0
Local nY		:= 0
Local cCliente:= ''
Local cLoja	:= ''
Local nTot		:= 0
Local oView	:= FWViewActive()
Default oModel := FWModelActive()
	
	oAuxFL5  := oModel:GetModel('FL5DETAIL')
	oAuxFL6  := oModel:GetModel('FL6DETAIL')
	oAuxTot  := oModel:GetModel('TOTALIZADOR')	 
	cCliente := oAuxFL5:GetValue('FL5_CLIENT')
	cLoja	  := oAuxFL5:GetValue('FL5_LOJA')	
	//
	For nX := 1 To oAuxFL5:Length()	
		
		If cCliente + cLoja == oAuxFL5:GetValue('FL5_CLIENT', nX) + oAuxFL5:GetValue('FL5_LOJA', nX) .AND. oAuxFL5:GetValue('FL5_MARK', nX)	
			
			oAuxFL5:SetLine( nX )
			For nY := 1 To oAuxFL6:Length()
				nTot += (oAuxFL6:GetValue("FL6_VALOR", nY)  * oAuxFL6:GetValue("FL6_PORC", nY)) / 100			
			Next nY
			
		EndIf
		
	Next nX

 	oAuxTot:SeekLine({{"YYY_CLIENTE",cCliente},{"YYY_LOJA",cLoja}} )
	
	If nTot > 0 
		oAuxTot:SetValue("YYY_TOTFAT" , nTot)
	Else
		oAuxTot:SetNoDeleteLine(.F.)
		oAuxTot:DeleteLine()
		oAuxTot:SetNoDeleteLine(.T.)
	EndIf 

	If oView != Nil
		oView:Refresh()
	EndIf	

Return 
