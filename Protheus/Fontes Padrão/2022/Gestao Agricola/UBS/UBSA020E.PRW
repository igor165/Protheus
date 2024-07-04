
#Include 'totvs.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWEDITPANEL.CH'

Function UBSA020E( cLote,cCodSaf,cUM, nSaldo )
    Local cAliasQRY		:= GetNextAlias()
	local cIndice 		:= ""
	Local nIndice
	local cChaveA
	local lRastros 		:= .t.
	local nx
	local ny
	local nSaldoL
	Local aSeek 		:= {}
	Local aColunas		:= {}
	
	Local aSize 		:= {}
	Local lEmpPrev		:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
	Local aCPOBROWSE	:= {}
	Local aIndice    	:= {}
	Local aArqTMP
	Local cTitleBrw		:=''

	Private oTMP		:= {}	
	Private cAliTMP	
	
	

	aSize := MsAdvSize(.F.)	

BeginSQL Alias cAliasQRY
		COLUMN B8_DTVALID AS DATE
		SELECT NP9.NP9_FILIAL,NP9.NP9_CODSAF, NP9.NP9_PROD,SB1.B1_DESC,SB1.B1_UM,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_UM, NP9.NP9_2UM,	NP9.NP9_CULTRA,NP3.NP3_DESCRI,
		NP9.NP9_CTVAR,NP4_DESCRI,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SB8.B8_LOCAL,B8_NUMLOTE,B8_LOTECTL

		FROM %Table:SB8% SB8
			INNER JOIN %table:NP9% NP9 
				ON NP9.%notDel%
				AND NP9.NP9_FILIAL = %xFilial:NP9%  
				AND  NP9.NP9_LOTE = SB8.B8_LOTECTL 
				AND NP9.NP9_PROD = SB8.B8_PRODUTO
			INNER JOIN %Table:NP4%  NP4
				ON  NP4.NP4_CODIGO = NP9.NP9_CTVAR
				AND NP4.NP4_FILIAL = %xFilial:NP4% 
				AND NP4.%notDel%
			INNER JOIN %Table:NP3%  NP3
				ON  NP3.NP3_CODIGO = NP9.NP9_CULTRA
				AND NP3.NP3_FILIAL = %xFilial:NP3% 
				AND NP3.%notDel%
			INNER JOIN %Table:SB1%  SB1
				ON  SB1.B1_COD = NP9.NP9_PROD
				AND SB1.B1_FILIAL = %xFilial:SB1% 
				AND SB1.B1_UM     = %exp:cUM%  
				AND SB1.%notDel%
		WHERE
			SB8.B8_FILIAL=%xFilial:SB8%    
			AND NP9.NP9_LOTE = %exp:cLOTE%
			AND NP9.NP9_CODSAF = %exp:cCodSaf%
			AND SB8.%NotDel% 
		ORDER BY NP9_LOTE,B8_NUMLOTE,NP9_PROD
	EndSQL

///EECVIEW(getLastQuery()[2],'XXX')

	aCamTRB :=	{ ;
	{"NP9_PROD" ,	TamSX3("NP9_PROD"  )[3]    	,TamSX3("NP9_PROD"  )[1]     ,TamSX3("NP9_PROD"  )[2]     ,"Cod.Produto"   ,PesqPict("NP9","NP9_PROD")      },;
	{"B1_DESC" ,	TamSX3("B1_DESC"  )[3]    	,TamSX3("B1_DESC"  )[1]     ,TamSX3("B1_DESC"  )[2]     ,"Produto"   ,PesqPict("SB1","B1_DESC")      },;
	{"NP9_CODSAF",	TamSX3("NP9_CODSAF")[3]    	,TamSX3("NP9_CODSAF")[1]     ,TamSX3("NP9_CODSAF")[2]     ,"Safra"     ,PesqPict("NP9","NP9_CODSAF")      },;
	{"NP9_LOTE"},;
	{"B8_NUMLOTE"},;
	{"NP9_UM"},;
	{"B8_DTVALID"},;
	{"B8_SALDO",	TamSX3("B8_SALDO")[3],	TamSX3("B8_SALDO")[1],	TamSX3("B8_SALDO")[2],"Saldo Estoque",PesqPict("SB8","B8_SALDO")},;
	{"NP9_CULTRA",	TamSX3("NP9_CULTRA")[3],TamSX3("NP9_CULTRA")[1],TamSX3("NP9_CULTRA")[2],AGRTITULO("NP9_CULTRA"),PesqPict("NP9","NP9_CULTRA")},;
	{"NP3_DESCRI",	TamSX3("NP3_DESCRI")[3],TamSX3("NP3_DESCRI")[1],TamSX3("NP3_DESCRI")[2],'Desc.Cultura',X3PICTURE("NP3_DESCRI")},;	
	{"NP9_CTVAR",	TamSX3("NP9_CTVAR")[3],	TamSX3("NP9_CTVAR")[1],	TamSX3("NP9_CTVAR")[2],AGRTITULO("NP9_CTVAR"),PesqPict("NP9","NP9_CTVAR")},;	
	{"NP4_DESCRI",	TamSX3("NP4_DESCRI")[3],TamSX3("NP4_DESCRI")[1],TamSX3("NP4_DESCRI")[2],'Desc.Ctvar',X3PICTURE("NP4_DESCRI")},;	
	{"NP9_CATEG",	TamSX3("NP9_CATEG")[3],	TamSX3("NP9_CATEG")[1],	TamSX3("NP9_CATEG")[2],AGRTITULO("NP9_CATEG"),PesqPict("NP9","NP9_CATEG")},;
	{"NP9_PENE",	TamSX3("NP9_PENE")[3],	TamSX3("NP9_PENE")[1],	TamSX3("NP9_PENE")[2],AGRTITULO("NP9_PENE"),PesqPict("NP9","NP9_PENE")},;
	{"NP9_TIPLOT",	TamSX3("NP9_TIPLOT")[3],TamSX3("NP9_TIPLOT")[1],TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
	{"NP9_TRATO",	TamSX3("NP9_TRATO")[3],	TamSX3("NP9_TRATO")[1],	TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
	{"NP9_EMB",		TamSX3("NP9_EMB")[3],	TamSX3("NP9_EMB")[1],	TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")     }}
    
	//Campos a aparecer no browse.
	aCPOBROWSE:={'NP9_LOTE','NP9_PROD','B1_DESC','NP9_UM',"B8_SALDO","B8_DTVALID",'NP9_CODSAF',"NP9_CULTRA","NP3_DESCRI","NP9_CTVAR","NP4_DESCRI","NP9_CATEG","NP9_PENE","NP9_TIPLOT","NP9_TRATO",'NP9_EMB'}  
	
	aIndice := {"NP9_LOTE","B8_NUMLOTE"}
	aRet := AGRCRIATRB(,aCamTRB,aIndice,FunName(),.t.)
	oTmp := aRet[3] //Nome do arquivo temporário
	cAliTMP := aRet[4] //Nome do alias do arquivo temporario
	aArqTMP := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (cAliTMP )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )
		nIndice := If(lRastroS,2,3)

        cChaveA := IIf(lRastroS,(cAliasQRY)->(B8_NUMLOTE+NP9_LOTE+NP9_PROD+B8_LOCAL ),(cAliasQRY)->(NP9_PROD + B8_LOCAL+NP9_LOTE))

		SB8->( dbSetOrder( nIndice ) )
		IF SB8->( dbSeek( xFilial( "SB8" ) + cChaveA ) )
			nSaldoL  := SB8Saldo(.F.,!Empty((cAliasQRY)->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)

			DbSelectArea(cAliTMP)
			(cAliTMP)->( dbSetOrder(1) )

			IF nSaldoL <> 0
				If .not. (cAliTMP)->( dbSeek( (cAliasQRY)->( NP9_LOTE + B8_NUMLOTE+ NP9_PROD ) ) )
					IF  RecLock(cAliTMP, .t.)
						DbSelectArea(cAliasQRY)
						For nx := 1 To Fcount()
							IF Fieldname(nx) $ 'NP9_TRATO/NP9_TIPLOT/NP9_EMB/B8_SALDO'
								(cAliTMP)->NP9_TRATO	:= X3CBoxDesc("NP9_TRATO",	( cAliasQRY )->NP9_TRATO	)
								(cAliTMP)->NP9_TIPLOT 	:= X3CBoxDesc("NP9_TIPLOT",	( cAliasQRY )->NP9_TIPLOT)
								(cAliTMP)->NP9_EMB		:= X3CBoxDesc("NP9_EMB"	,	( cAliasQRY )->NP9_EMB	)
								(cAliTMP)->B8_SALDO	:= nSaldoL
							Else
								nPos := aScan(aArqTMP,{|x| AllTrim(x[1]) == Fieldname(nx)})
								If nPos > 0
									x := (cAliasQRY )+"->"+Fieldname(nx)
									y := (cAliTMP)+"->"+aArqTMP[nPos,1]
									&y. := &x.
								EndIf

							EndIF
						Next nx
						(cAliTMP)->( Msunlock() )
					EndIF
				EndIF
			EndIF
		EndIf
		(cAliasQRY)->(dbSkip())		
	EndDo

	// monta a estruta para index
	For nx := 1 To Len(aIndice)
		cIndice := aIndice[nx]
		cIndice := StrTran(cIndice," ","")
		cIndice := StrTran(cIndice,"Dtos(","")
		cIndice := StrTran(cIndice,"Descend(","")
		cIndice := StrTran(cIndice,")","")
		cDescIn := Space(1)
		vVetInT := {}
		While !Empty(cIndice)
			nPos := At("+",cIndice)
			cCam := If(nPos > 0,Alltrim(SubStr(cIndice,1,nPos-1)),Alltrim(SubStr(cIndice,1,Len(cIndice))))
			Aadd(vVetInT,cCam)
			cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
		End
		cTamInd := 0
		For ny := 1 To Len(vVetInT)
			nPos1 := Ascan(aArqTMP,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
			If nPos1 > 0
				cDescIn += Alltrim(aArqTMP[nPos1,5])+If(ny < len(vVetInT)," + ","")
				cTamInd += aArqTMP[nPos1,3]
			EndIf
		Next ny
		Aadd(aSeek,{cDescIn,{{"","C",cTamInd,0,' ',,}}})
	Next nx

	aSize := MsAdvSize()
	aCoors := FWGetDialogSize( oMainWnd )
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()
	
	oDlgPrdLts := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3]/1.25, oSize:aWindSize[4]/1.1, 'Detalhes do Lote por Produto', , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta
	
	// Desabilita o fechamento da tela através da tela ESC.
	oDlgPrdLts:lEscClose := .F.

	// Instancia o layer
	oFWL_1 := FWLayer():New()
	// Inicia o Layer
	oFWL_1:init( oDlgPrdLts,.F.)
	// Cria uma linha unica para o Layer
	oFWL_1:addLine( 'LINHA1', 100 , .F.)
	//oFWL_1:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL_1:addCollumn('COL1',100,.T.,'LINHA1' )
	
	cTitleBrw := " Produtos do Estoque que Contem o Lote : " + Alltrim( cLote ) + ". Saldo P/Direcionamento: "  + cValtochar(nSaldo)
	oFWL_1:addWindow( 'COL1', 'Wnd1', cTitleBrw	, 100 /*tamanho*/, .F., .T.,, 'LINHA1' )	//"Blocos"
   
    oPnlWnd_1:= oFWL_1:getWinPanel( 'COL1' 	, 'Wnd1', 'LINHA1' )

     //adicionando os cpos que devem aparecer no browse
     For nx := 1 To Len(aCPOBROWSE)

	 nPosCpo := aScan(aArqTMP,{|x| AllTrim(x[1]) = aCPOBROWSE[nX]})
 
		AAdd(aColunas,FWBrwColumn():New())
		aColunas[Len(aColunas)]:SetData(&("{||"+aArqTMP[nPosCpo,1]+"}"))
		aColunas[Len(aColunas)]:SetTitle	( Alltrim(aArqTMP[nPosCpo,5]))
		aColunas[Len(aColunas)]:SetPicture(Alltrim(aArqTMP[nPosCpo,6]))
		aColunas[Len(aColunas)]:SetType(Alltrim(aArqTMP[nPosCpo,2]))
		aColunas[Len(aColunas)]:SetSize(aArqTMP[nPosCpo,3])
		aColunas[Len(aColunas)]:SetReadVar(aArqTMP[nPosCpo,1])
		aColunas[Len(aColunas)]:SetAlign( If(TamSx3(aArqTMP[nPosCpo, 1])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	(cAliTMP)->( dbGoTop() )

	DEFINE FWFORMBROWSE oBrowsX1 DATA TABLE ALIAS cAliTMP OF oPnlWnd_1
	oBrowsX1:SetTemporary(.T.)
	oBrowsX1:SetColumns(aColunas)
	oBrowsX1:SetDBFFilter(.T.)
	oBrowsX1:SetUseFilter(.T.)
	oBrowsX1:SetFieldFilter(AGRITEMCBRW(aArqTMP))
	oBrowsX1:DisableDetails(.F.)
	oBrowsX1:SetSeek(,aSeek)
	
	oBrowsX1:SetProfileID( 'UBSA020E'	) 

	oBrowsX1:AddButton("Sair",{|| oDlgPrdLts:end()},,9,0)

	ACTIVATE FWFORMBROWSE oBrowsX1
    oDlgPrdLts:Activate( , , , .t., { || .t. }, , { || } )

	oTMP:Delete()
	( cAliasQRY )->( DbCloseArea() )
	
Return .T.



