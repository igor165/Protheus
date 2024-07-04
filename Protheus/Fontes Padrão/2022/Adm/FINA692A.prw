#Include 'Protheus.ch' 
#Include 'FWMVCDEF.CH'
#Include 'FINA692A.CH'

#DEFINE INCLUSAO_PV 3

/*/{Protheus.doc}FINA692A
Faturamento em Lote - Prestação de Contas.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FINA692A()

If Pergunte("FINA692A", .T. )
	FWExecView( STR0001,'FINA692A', MODEL_OPERATION_INSERT )
EndIf

Return

/*/{Protheus.doc}ModelDef
Modelo de dados - Faturamento em Lote.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Static Function ModelDef()
Local oModel 	:= MPFormModel():New('FINA692A',/*Pre*/,/*Pos*/,{|oModel|F692AGRVFT(oModel)})
Local oMaster 	:= FWFormModelStruct():New()
Local oTotal 	:= Nil
Local oFLF	 	:= FWFormStruct(1, 'FLF')
Local aAux	 	:= aClone(oFLF:GetFields())

oTotal := FN692Struct(1)
oMaster:AddTable('FLF',,STR0002) 
oMaster:AddField(	"CPOVIRTUAL",; //Título do campo
					"",; //cToolTip
					"CPOVIRTUAL",;// Id do Campo
					"C",; //cTipo
					1,; //Tamanho do Campo	
					0)//Decimal
//---Campo lógico na FL5 para selecionar os pedidos que serão faturados.
oFLF:AddField("","","FLF_MARK","L",1)
//TES
oFLF:AddField(STR0010,STR0010,'FLF_TES',"C",3,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/)
//Produto
oFLF:AddField(STR0009,STR0009,"FLF_PROD","C",15,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/) 
oFLF:AddTrigger( "FLF_MARK","FLF_MARK", {|| .T. }  , {|| FN692ATotal() }  )
oFLF:AddTrigger( "FLF_FATCLI","FLF_FATCLI", {|| .T. }  , {|x| FN692ARec(oModel) }  )
oTotal:AddTrigger("YYY_LOJA","YYY_NOME",{|| .T. }, {|oModel|FN692ANome(oModel) })
//
oModel:AddFields('MASTER',/*cOwner*/ , oMaster)
oFLF:SetProperty('*' , MODEL_FIELD_OBRIGAT ,  .F.  )
oFLF:SetProperty('FLF_FATCLI' , MODEL_FIELD_WHEN 	 , {|oModel| oModel:GetValue('FLF_TIPO') == '2' .AND. oModel:GetValue('FLF_MARK') } )
oFLF:SetProperty('FLF_FATCLI' , MODEL_FIELD_VALID 	 , {|oModel| Positivo() .AND. oModel:GetValue('FLF_FATCLI') + oModel:GetValue('FLF_FATEMP') <= 100 } )
oFLF:SetProperty('FLF_FATEMP' , MODEL_FIELD_WHEN 	 , {|oModel| oModel:GetValue('FLF_TIPO') == '2' .AND. oModel:GetValue('FLF_MARK') } )
oFLF:SetProperty('FLF_FATEMP' , MODEL_FIELD_VALID 	 , {|oModel| Positivo() .AND. oModel:GetValue('FLF_FATCLI') + oModel:GetValue('FLF_FATEMP') <= 100 } )
//Cria campo natureza.
FN693ACPO(1,oFLF)

oModel:AddGrid('FLFDETAIL', 'MASTER'   , oFLF)
oModel:AddGrid('TOTALIZADOR', 'MASTER', oTotal)
//
oModel:GetModel('TOTALIZADOR'):SetOnlyQuery(.T.)
oModel:GetModel('MASTER'):SetOnlyQuery(.T.)
oModel:GetModel("MASTER"):SetPrimaryKey({})
oModel:GetModel('TOTALIZADOR'):SetOptional( .T. )
oModel:GetModel('FLFDETAIL'):SetOptional( .T. )
oModel:SetActivate( {|oModel| F692ALoadFT(oModel) } )
//
Return oModel

/*/{Protheus.doc}ModelDef
Interface - Faturamento em Lote.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Static Function ViewDef()
Local oView  := FWFormView():New()
Local oModel := FWLoadModel('FINA692A')
Local oFLF	 := FWFormStruct(2, 'FLF')
Local oDet	 := Nil	
Local oTotal := Nil
Local nX	 := 0
Local aAux	 := aClone(oFLF:GetFields())
Local nPos	 := ''

For nX := 1 To Len(aAux)
	If !aAux[nX][1] $ 'FLF_PRESTA|FLF_CLIENT|FLF_LOJA|FLF_DTINI|FLF_DTFIM|FLF_NACION|FLF_FATCLI|FLF_FATEMP|FLF_TDESP1|FLF_TDESC1'
		oFLF:RemoveField( aAux[nX][1] )
	EndIf
Next nX

oFLF:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )
oFLF:SetProperty("FLF_FATCLI", MVC_VIEW_CANCHANGE , .T. )
//Limpa variavel da memoria.
aSize( aAux, 0 )
aAux := {}
oTotal := FN692Struct(2)
//---Campo lógico na FL5 para selecionar os pedidos que serão faturados.
oFLF:AddField("FLF_MARK","01","","",{},"L")//cPicture
nPos := Val(oFLF:GetProperty("FLF_LOJA", MVC_VIEW_ORDEM))
//Produto
oFLF:AddField('FLF_PROD',StrZero(++nPos,2),'Produto','Produto',,'Get',PesqPict('SC6','C6_PRODUTO'),/**/,'SB1')
//TES
oFLF:AddField('FLF_TES',StrZero(++nPos,2),'TES','TES',,'Get',PesqPict('SC6','C6_TES'),/**/,'SF4')
//
oView:SetModel( oModel )
//
//Cria campo natureza.
FN693ACPO(2,oFLF)

oView:AddGrid('VIEW_FLF', oFLF, 'FLFDETAIL' )
oView:AddGrid('VIEW_TOT', oTotal,'TOTALIZADOR') 
//
oView:CreateHorizontalBox( 'BOXFLF', 70 )
oView:CreateHorizontalBox( 'BOXTOT', 30 )
//
oView:SetOwnerView('VIEW_FLF','BOXFLF') 
oView:SetOwnerView('VIEW_TOT','BOXTOT')
oView:EnableTitleView('VIEW_TOT' , STR0003 ) //total por cliente
oView:EnableTitleView('VIEW_FLF' , STR0004 ) //prestação de contas
oView:SetNoInsertLine('VIEW_FLF')
oView:SetNoInsertLine('VIEW_TOT')
oView:SetNoDeleteLine('VIEW_TOT')
oView:SetNoDeleteLine('VIEW_FLF')
oView:SetViewCanActivate( {|| FN692AView() } )

Return oView

/*/{Protheus.doc}F692ALoadFT
Função carrega os dados no modelo de dados.
@param oModel - Modelo de dados 
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function F692ALoadFT( oModel )
Local lRet	 	:= .T.
Local cQuery 	:= ""
Local nPorc		:= 0
Local cAliasFLF := GetNextAlias()
Local oSubFLF	:= oModel:GetModel("FLFDETAIL")
Local cProd     := SupergetMv("MV_RESPROD",.T.,"   ")

//
oSubFLF:SetNoInsertLine( .F. )
oModel:SetValue("MASTER","CPOVIRTUAL","1")
//
dbSelectArea("FL6")
FL6->(dbSetOrder(1))
dbSelectArea("FLF")
FLF->(dbSetOrder(2))
cQuery := "SELECT FLF_PRESTA, FLF_CLIENT, FLF_LOJA, FLF_FATCLI, FLF_FATEMP, FLF_NACION, " + CRLF
cQuery += "FLF_DTINI, FLF_DTFIM, FLF_TDESP1, FLF_TDESC1, FLF_TIPO " + CRLF
cQuery += "FROM " 	 + RetSQLTab('FLF') + CRLF
cQuery += "WHERE " + CRLF
cQuery += "FLF_PEDIDO = '' AND "  + CRLF //Não pode ter pedido gerado.
cQuery += "FLF_VIAGEM = '' AND "  + CRLF //Prestação de Contas avulsa.
cQuery += "FLF_TIPO	  ='2' AND "  + CRLF //Tipo = Avulsa.		
cQuery += "FLF_DTINI >= '" + DTOS(MV_PAR01)+ "' AND " + CRLF
cQuery += "FLF_DTFIM <= '" + DTOS(MV_PAR02)+ "' AND " + CRLF
cQuery += "FLF_PRESTA BETWEEN '"+ MV_PAR03 + "' AND '"+ MV_PAR04 + "' AND " + CRLF
cQuery += "FLF_CLIENT BETWEEN '"+ MV_PAR05 + "' AND '"+ MV_PAR07 + "' AND " + CRLF
cQuery += "FLF_LOJA   BETWEEN '"+ MV_PAR06 + "' AND '"+ MV_PAR08 + "' AND " + CRLF
cQuery += "FLF.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFLF,.T.,.T.)
dbSelectArea(cAliasFLF)
(cAliasFLF)->(DbGotop())
While (cAliasFLF)->(!Eof())
	
	If !oSubFLF:IsEmpty()
		oSubFLF:AddLine()
	EndIf
	oSubFLF:LoadValue('FLF_PRESTA'	, (cAliasFLF)->FLF_PRESTA 	)
	oSubFLF:LoadValue('FLF_CLIENT'	, (cAliasFLF)->FLF_CLIENT 	)
	oSubFLF:LoadValue('FLF_LOJA'	, (cAliasFLF)->FLF_LOJA 	)
	oSubFLF:LoadValue('FLF_DTINI'	, STOD((cAliasFLF)->FLF_DTINI) 	)
	oSubFLF:LoadValue('FLF_DTFIM'	, STOD((cAliasFLF)->FLF_DTFIM) 	)
	oSubFLF:LoadValue('FLF_FATCLI'	, (cAliasFLF)->FLF_FATCLI)
	oSubFLF:LoadValue('FLF_FATEMP'	, (cAliasFLF)->FLF_FATEMP)
	oSubFLF:LoadValue('FLF_NACION'	, (cAliasFLF)->FLF_NACION)
	oSubFLF:LoadValue('FLF_TDESP1'	, (cAliasFLF)->FLF_TDESP1)
	oSubFLF:LoadValue('FLF_TDESC1'	, (cAliasFLF)->FLF_TDESC1)
	oSubFLF:LoadValue('FLF_TIPO'	, (cAliasFLF)->FLF_TIPO)
	oSubFLF:LoadValue('FLF_PROD'    , AllTrim(cProd))
	oSubFLF:LoadValue('FLF_TES'     , F693IniTES(FLF->FLF_CLIENT,FLF->FLF_LOJA))				
	//
	(cAliasFLF)->(dbSkip())

EndDo

oSubFLF:SetNoInsertLine( .T. )

Return lRet

/*/{Protheus.doc}FN692ATotal
Resumo dos faturamentos de cada cliente.
@param oModel - Modelo de dados 
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FN692ATotal()
Local oView	:= FWViewActive()
Local oModel	:= FWModelActive() 
Local oAux		:= oModel:GetModel('TOTALIZADOR')
Local oAuxFLF	:= oModel:GetModel("FLFDETAIL")
Local lMark	:= oModel:GetValue('FLFDETAIL','FLF_MARK')
Local nTotal	:= 0
Local cRet 	:= ""
Local nX		:= 0

oAux:SetNoInsertLine( .F. )

nTotal := (oAuxFLF:GetValue("FLF_TDESP1") - oAuxFLF:GetValue("FLF_TDESC1")) * oAuxFLF:GetValue("FLF_FATCLI") / 100
//
If oAux:SeekLine({{"YYY_CLIENTE",oAuxFLF:GetValue("FLF_CLIENT")},{"YYY_LOJA",oAuxFLF:GetValue('FLF_LOJA') }} )

	//
	If lMark 
		oAux:SetValue("YYY_TOTFAT" , oAux:GetValue("YYY_TOTFAT") + nTotal)
	ELse 
		oAux:SetValue("YYY_TOTFAT" , oAux:GetValue("YYY_TOTFAT") - nTotal)
		
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
	oAux:SetValue("YYY_CLIENTE" , oAuxFLF:GetValue("FLF_CLIENT") )
	oAux:SetValue("YYY_LOJA" 	, oAuxFLF:GetValue("FLF_LOJA"  ) )
	oAux:SetValue("YYY_TOTFAT"  , nTotal )	
	//
EndIf

oAux:SetNoInsertLine( .T. )
oAux:SetLine(1)
oView:Refresh()

Return cRet

/*/{Protheus.doc}F687GRV
Gravação do modelo de dados.
@author William Matos 	
@since  24/06/2015
@param oModel - Modelo de dados.
@version 12
/*/	
Function F692AGRVFT(oModel)
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
Local nTotal	:= 0
Local oTotal	:= oModel:GetModel("TOTALIZADOR")
Local oAuxFLF	:= oModel:GetModel("FLFDETAIL")
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
		aAdd( aCab, { "C5_NATUREZ" 	,oAuxFLF:GetValue('NATUREZ'), Nil })		
		nY := 1
		cItem := "00"
		While nY <= oAuxFLF:Length() 
		
			If  oTotal:GetValue('YYY_CLIENTE', nX) == oAuxFLF:GetValue("FLF_CLIENT", nY) .AND. oAuxFLF:GetValue("FLF_MARK", nY)
				//
				oAuxFLF:SetLine( nY )
				nTotal := (oAuxFLF:GetValue("FLF_TDESP1") - oAuxFLF:GetValue("FLF_TDESC1")) * oAuxFLF:GetValue("FLF_FATCLI") / 100
				//
				aAux 	:= {}
				cItem	:= Soma1(cItem)	
				aAdd( aAux, { "C6_FILIAL"   ,xFilial( "SC6" )				,Nil } )
				aAdd( aAux, { "C6_ITEM"   	,cItem							,Nil } )
				aAdd( aAux, { "C6_UM"    	,cUnMed							,Nil } )
				aAdd( aAux, { "C6_CLI"   	,oTotal:GetValue('YYY_CLIENTE'	, nX),Nil } )
				aAdd( aAux, { "C6_LOJA"  	,oTotal:GetValue('YYY_LOJA'	  	, nX),Nil } )	
				aAdd( aAux, { "C6_PRODUTO"	,oAuxFLF:GetValue("FLF_PROD")	,Nil } )	
				aAdd( aAux, { "C6_QTDVEN"  	,1   			       			,Nil } )
				aAdd( aAux, { "C6_PRCVEN"  	,nTotal							,Nil } )
				aAdd( aAux, { "C6_PRUNIT"  	,nTotal							,Nil } )
				aAdd( aAux, { "C6_TES"   	,oAuxFLF:GetValue("FLF_TES")	,Nil } )
				aAdd( aItens, aClone(aAux) )
			EndIf
				
			nValor	:= 0
			nY++
		EndDo
		
		//Inclusao do pedido de venda³
		lMSERROAUTO := .F.
		lMSHELPAUTO	:= .T.
		nAnt := MAFISSAVE()
		MAFISEND()
	
		MsgRun( STR0006, STR0007, { | | MsExecAuto( { | x, y, z | MATA410( x, y, z ) }, aCab, aItens, INCLUSAO_PV ) } ) //"Gerando Pedido(s)."###"Aguarde..."
		If lMSERROAUTO
			lRet	:= .F.
			MostraErro()		
			Help(" ",1,"ERRO",,STR0005,1,0)	 //Erro ao processar pedidos.
		Else
		
			For nZ := 1 To oAuxFLF:Length()
				If  oTotal:GetValue('YYY_CLIENTE', nX) == oAuxFLF:GetValue("FLF_CLIENT", nZ) .AND. oAuxFLF:GetValue("FLF_MARK", nZ)
					oAuxFLF:SetLine(nZ)
					oAuxFLF:SetValue("FLF_PEDIDO", SC5->C5_NUM )
				EndIf
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
	While nX <= oAuxFLF:Length() .AND. lRet
			
		If oAuxFLF:GetValue('FLF_MARK', nX)
		
			oAuxFLF:SetLine( nX )
			
			SA1->(dbSetOrder(1))
			SA1->(DBSeek(xFilial("SA1") + oAuxFLF:GetValue('FLF_CLIENT', nX) + oAuxFLF:GetValue('FLF_LOJA'  , nX)))
			cTes := If(SA1->A1_RESFAT = '1', cTes1, cTes2)
			nTotal := (oAuxFLF:GetValue("FLF_TDESP1") - oAuxFLF:GetValue("FLF_TDESC1")) * oAuxFLF:GetValue("FLF_FATCLI") / 100
			//Cabecalho do Pedido de Venda³
			aAdd( aCab, { "C5_FILIAL" 	,xFilial("SC5")	,Nil } )
			aAdd( aCab, { "C5_TIPO"   	,"N"			,Nil } )
			aAdd( aCab, { "C5_CLIENTE"  ,oAuxFLF:GetValue('FLF_CLIENT', nX),Nil})
			aAdd( aCab, { "C5_LOJACLI" 	,oAuxFLF:GetValue('FLF_LOJA'  , nX),Nil})
			aAdd( aCab, { "C5_CONDPAG"	,cCond			,Nil } )
			aAdd( aCab, { "C5_EMISSAO"	,dDataBase  	,Nil } )
			aAdd( aCab, { "C5_MENNOTA" 	,cMsgNota		,Nil } )
			aAdd( aCab, { "C5_ORIGEM" 	,FunName()		,Nil } )
			aAdd( aCab, { "C5_NATUREZ" 	,oAuxFLF:GetValue('NATUREZ'	  , nX),Nil})			
		
			//Itens do Pedido de Venda
			aAux 	:= {}
			aAdd( aAux, { "C6_FILIAL"   ,xFilial( "SC6" )					,Nil } )
			aAdd( aAux, { "C6_ITEM"   	,Soma1( cItem )						,Nil } )
			aAdd( aAux, { "C6_UM"    	,cUnMed								,Nil } )
			aAdd( aAux, { "C6_CLI"   	,oAuxFLF:GetValue('FLF_CLIENT', nX)	,Nil } )
			aAdd( aAux, { "C6_LOJA"  	,oAuxFLF:GetValue('FLF_LOJA'  , nX)	,Nil } )	
			aAdd( aAux, { "C6_PRODUTO"	,oAuxFLF:GetValue('FLF_PROD'  , nX)	,Nil } )	
			aAdd( aAux, { "C6_QTDVEN"  	,1   			       				,Nil } )
			aAdd( aAux, { "C6_PRCVEN"  	,nTotal								,Nil } )
			aAdd( aAux, { "C6_PRUNIT"  	,nTotal							  	,Nil } )
			aAdd( aAux, { "C6_TES"   	,oAuxFLF:GetValue('FLF_TES'  , nX)	,Nil } )
			aAdd( aItens, aClone(aAux) )
		
			//Inclusao do pedido de venda³
			lMSERROAUTO := .F.
			lMSHELPAUTO	:= .T.
			nAnt := MAFISSAVE()
			MAFISEND()
		
			MsgRun(  STR0006, STR0007, { | | MsExecAuto( { | x, y, z | MATA410( x, y, z ) }, aCab, aItens, INCLUSAO_PV ) } ) //"Gerando Pedido(s)."###"Aguarde..."
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
				Help(" ",1,"ERRO",,STR0005,1,0)	 //Erro ao processar pedidos.
				lRet		:= .F.    
			Else
				oAuxFLF:SetValue("FLF_PEDIDO", SC5->C5_NUM )
			Endif
		EndIf
		nX++
	EndDo
EndIf

If lRet
	
	FLF->(dbSetOrder(1))
	For nX := 1 To oAuxFLF:Length()
		If oAuxFLF:GetValue("FLF_MARK", nX )
			FLF->(dbSeek( xFilial("FLF") + oAuxFLF:GetValue("FLF_TIPO", nX) + oAuxFLF:GetValue("FLF_PRESTA", nX)))
			Reclock("FLF", .F.)
			FLF->FLF_STATUS	:= "9"
			FLF->FLF_PEDIDO	:= oAuxFLF:GetValue("FLF_PEDIDO", nX)
			FLF->(MsUnlock())
		EndIf	
	Next nX
	
EndIf

Return lRet

/*/{Protheus.doc}FN692ANome
Função responsavel por retornar o nome do cliente.
@author William Matos 	
@since  24/06/2015
@param oModel - Modelo de dados.
@version 12
/*/	
Function FN692ANome(oModel)
Local cDesc := ""

cDesc := Posicione("SA1",1, xFilial("SA1") + oModel:GetValue("YYY_CLIENTE") + oModel:GetValue("YYY_LOJA"), "A1_NOME")

Return cDesc

/*/{Protheus.doc}FN692AView
Verifica se a view pode ser ativa.
@author William Matos 	
@since  24/06/2015
@version 12
/*/	
Function FN692AView()
Local lRet		  := .T.
Local cQuery    := ""
Local cAliasFLF := GetNextAlias()
	//
	dbSelectArea("FL6")
	FL6->(dbSetOrder(1))
	dbSelectArea("FLF")
	FLF->(dbSetOrder(2))
	cQuery := "SELECT FLF_PRESTA, FLF_CLIENT, FLF_LOJA, FLF_FATCLI, FLF_FATEMP, FLF_NACION, " + CRLF
	cQuery += "FLF_DTINI, FLF_DTFIM, FLF_TDESP1, FLF_TDESC1, FLF_TIPO " + CRLF
	cQuery += "FROM " 	 + RetSQLTab('FLF') + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "FLF_PEDIDO = '' AND "  + CRLF //Não pode ter pedido gerado.
	cQuery += "FLF_VIAGEM = '' AND "  + CRLF //Prestação de Contas avulsa.
	cQuery += "FLF_TIPO	  ='2' AND "  + CRLF //Tipo = Avulsa.		
	cQuery += "FLF_DTINI >= '" + DTOS(MV_PAR01)+ "' AND " + CRLF
	cQuery += "FLF_DTFIM <= '" + DTOS(MV_PAR02)+ "' AND " + CRLF
	cQuery += "FLF_PRESTA BETWEEN '"+ MV_PAR03 + "' AND '"+ MV_PAR04 + "' AND " + CRLF
	cQuery += "FLF_CLIENT BETWEEN '"+ MV_PAR05 + "' AND '"+ MV_PAR07 + "' AND " + CRLF
	cQuery += "FLF_LOJA   BETWEEN '"+ MV_PAR06 + "' AND '"+ MV_PAR08 + "' AND " + CRLF
	cQuery += "FLF.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFLF,.T.,.T.)
	dbSelectArea(cAliasFLF)
	(cAliasFLF)->(DbGotop())
	lRet := (cAliasFLF)->(!Eof())
	If !lRet
		Help(" ",1,"VAZIO",,STR0008,1,0)			
	EndIf

Return lRet


/*/{Protheus.doc}FN692ARec
Realiza o recalculo do total por cliente.
@author William Matos 	
@since  13/11/2015
@version 12
/*/	
Function FN692ARec(oModel)
Local oAuxTot := Nil
Local oAuxFLF := Nil
Local nX		:= 0
Local cCliente:= ''
Local cLoja	:= ''
Local nTot		:= 0
Local oView	:= FWViewActive()
Default oModel := FWModelActive()
	
	oAuxFLF  := oModel:GetModel('FLFDETAIL')
	oAuxTot  := oModel:GetModel('TOTALIZADOR')	 
	cCliente := oAuxFLF:GetValue('FLF_CLIENT')
	cLoja	  := oAuxFLF:GetValue('FLF_LOJA')	
	//
	For nX := 1 To oAuxFLF:Length()	
		
		If cCliente + cLoja == oAuxFLF:GetValue('FLF_CLIENT', nX) + oAuxFLF:GetValue('FLF_LOJA', nX) .AND. oAuxFLF:GetValue('FLF_MARK', nX)	
			nTot += (oAuxFLF:GetValue("FLF_TDESP1", nX) - oAuxFLF:GetValue("FLF_TDESC1",nX) ) * oAuxFLF:GetValue("FLF_FATCLI",nX) / 100
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
