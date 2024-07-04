
/*{Protheus.doc} UBSA020F
Rotina que mostra o Saldo dos itens do estoque, contendo lotes de sementes
de acordo com as caracteristicas e UM (Embalagem) especificadas no Item do PV.

@param     Modelo da rotina UBSA020 ( De direcionamento de lotes )
           Browse da Tela de Direcionamento de Lotes
@return    Browse da Tela de Direcionamento com os lotes Selecionados.
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

#Include 'totvs.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWEDITPANEL.CH'

Function UBSA020f( oMdlUBA020 )
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
	Local aCPOBRWRES	:={}
	Local aIndice    	:= {}
	Local aArqTMP
	Local cTitleBrw		:=''

	Local cSqlFilter	:= ''
	
	Local cCodSaf		:= ''
	Local cCultura		:= ''
	Local cCtvar		:= ''
	Local cCategoria	:= ''
	Local cPeneira		:= ''
	Local CPV			:= ''
	Local cUm			:= ''
	Local cProdutoPV	:= ''
	Local aResultado 	:= FiltraResultados()
	Local cResult		:= ""
	Local cTypeDB		:= Upper( TcGetDb() )

	Private oTmpF		:= {}	
	Private cAliaTMPF	
	
	aSize := MsAdvSize(.F.)	

	IF  oMdlUBA020 != NIL

		OMDL_ND5 := oMdlUBA020:GetModel( "OMDL_ND5" )

		cCodSaf		:=	OMDL_ND5:GetValue( "ND5_CODSAF" )
		cCultura	:= 	OMDL_ND5:GetValue( "ND5_CULTRA" )
		cCtvar 		:= 	OMDL_ND5:GetValue( "ND5_CTVAR"  )
		cCategoria	:=  OMDL_ND5:GetValue( "ND5_CATEG"  )
		cPeneira	:=  OMDL_ND5:GetValue( "ND5_PENE"   ) 
		CPV			:=  OMDL_ND5:GetValue( "ND5_PEDIDO" ) 
		CItemPV		:=	OMDL_ND5:GetValue( "ND5_ITEM  " ) 
		cUm         :=  OMDL_ND5:GetValue( "ND5_UM    " ) 
		cProdutoPV  :=  OMDL_ND5:GetValue( "ND5_PRODUT" ) 

	EndIF


	cSqlFilter := " AND NP9_STATUS  = '2'"
	If !Empty(cCultura)
    	cSqlFilter += " AND NP9.NP9_CULTRA = '" 	+ cCultura 		+ "' "
	EndIF

	If !Empty(cCtvar)
		cSqlFilter += " AND NP9.NP9_CTVAR = '" 		+ cCtvar 		+ "' "
	EndIF

	If !Empty(cCategoria)
		cSqlFilter += " AND NP9.NP9_CATEG = '" 		+ cCategoria 	+ "' " 
	EndIf

	If !Empty(cPeneira)
		cSqlFilter += " AND NP9.NP9_PENE = '" 		+ cPeneira 		+ "' "
	EndIF

	IF !Empty(cCodSaf)
		 cSqlFilter += "AND NP9.NP9_CODSAF = '" 	+ cCodSaf 		+ "' "
	EndIF

	If Empty(cSqlFilter)
		cSqlFilter := "%%"
	Else
		cSqlFilter := "% " + cSqlFilter + " %"
	Endif

	//Campos de resultado que serao exibidos na Consulta de lotes
	For Nx := 1 to Len(aResultado)
		cResult += " , (SELECT "
		If cTypeDB == "MSSQL"
			cResult += " TOP 1 "	
		EndIf 
		cResult += aResultado[Nx][4] + " FROM " + RETSQLNAME('NPX') + " NPX WHERE NPX.NPX_FILIAL = '" + FWxFilial("NPX") + "'"
		cResult += " AND NPX.NPX_CODSAF ='"+cCodSaf+"' "
		cResult += " AND NPX.NPX_LOTE = NP9.NP9_LOTE AND NPX.NPX_CODTA='"+aResultado[Nx][1]+"'  AND NPX.NPX_CODVA='"+aResultado[Nx][2]+"' "
		cResult += " AND NPX.D_E_L_E_T_= ' ' AND NPX.NPX_ATIVO='1'"
		If cTypeDB == "ORACLE"
			cResult += " AND ROWNUM = 1 "	 
		EndIf
		cResult += " ) as "+aResultado[Nx][3] 
	Next Nx

	If Empty(cResult)
		cResult := "%%"
	Else
		cResult := "% " + cResult + " %"
	Endif


BeginSQL Alias cAliasQRY
		COLUMN B8_DTVALID AS DATE
		SELECT NP9.NP9_FILIAL,NP9.NP9_CODSAF, NP9.NP9_PROD,SB1.B1_DESC,SB1.B1_UM,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_UM, NP9.NP9_2UM,	NP9.NP9_CULTRA,NP3.NP3_DESCRI,
		NP9.NP9_CTVAR,NP4_DESCRI,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SB8.B8_LOCAL,B8_NUMLOTE,B8_LOTECTL
		%exp:cResult% 

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
			%exp:cSqlFilter% 
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

		//Campos de resultado que serao exibidos na Consulta de lotes
	For Nx := 1 to Len(aResultado)
		aadd(aCamTRB,{ALLTRIM(aResultado[Nx][3]),TamSX3(aResultado[Nx][4])[3],TamSX3(aResultado[Nx][4])[1],TamSX3(aResultado[Nx][4])[2],aResultado[Nx][3],PesqPict("NPX",aResultado[Nx][4])})
	Next Nx

	For Nx := 1 to Len(aResultado) //adiciona os campos de Resultado de analise para um array especifico
	  						       //Pois os campos de resultado são encontrados de forma dinamica
		aadd(aCPOBRWRES,ALLTRIM(aResultado[Nx][3]))
	Next Nx

	
	aIndice := {"NP9_LOTE","B8_NUMLOTE"}
	aRet := AGRCRIATRB(,aCamTRB,aIndice,FunName(),.t.)
	oTmpF := aRet[3] //Nome do arquivo temporário
	cAliaTMPF := aRet[4] //Nome do alias do arquivo temporario
	aArqTMP := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (cAliaTMPF )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )

		 IF (cAliasQRY)->NP9_TRATO == '1' .and. (cAliasQRY)->NP9_PROD != cProdutoPV  //So posso mostrar lotes tratados se for o mesmo produto do pedido
		      (cAliasQRY)->(dbSkip())		
		 	  Loop
		 EndIF

		nIndice := If(lRastroS,2,3)

        cChaveA := IIf(lRastroS,(cAliasQRY)->(B8_NUMLOTE+NP9_LOTE+NP9_PROD+B8_LOCAL ),(cAliasQRY)->(NP9_PROD + B8_LOCAL+NP9_LOTE))

		SB8->( dbSetOrder( nIndice ) )
		IF SB8->( dbSeek( xFilial( "SB8" ) + cChaveA ) )
			nSaldoL  := SB8Saldo(.F.,!Empty((cAliasQRY)->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)

			DbSelectArea(cAliaTMPF)
			(cAliaTMPF)->( dbSetOrder(1) )

			IF nSaldoL <> 0
				If .not. (cAliaTMPF)->( dbSeek( (cAliasQRY)->( NP9_LOTE + B8_NUMLOTE+ NP9_PROD ) ) )
					IF  RecLock(cAliaTMPF, .t.)
						DbSelectArea(cAliasQRY)
						For nx := 1 To Fcount()
							IF Fieldname(nx) $ 'NP9_TRATO/NP9_TIPLOT/NP9_EMB/B8_SALDO'
								(cAliaTMPF)->NP9_TRATO	:= X3CBoxDesc("NP9_TRATO",	( cAliasQRY )->NP9_TRATO	)
								(cAliaTMPF)->NP9_TIPLOT 	:= X3CBoxDesc("NP9_TIPLOT",	( cAliasQRY )->NP9_TIPLOT)
								(cAliaTMPF)->NP9_EMB		:= X3CBoxDesc("NP9_EMB"	,	( cAliasQRY )->NP9_EMB	)
								(cAliaTMPF)->B8_SALDO	:= nSaldoL
							Else
								nPos := aScan(aArqTMP,{|x| AllTrim(x[1]) == Fieldname(nx)})
								If nPos > 0
									x := (cAliasQRY )+"->"+Fieldname(nx)
									y := (cAliaTMPF)+"->"+aArqTMP[nPos,1]
									&y. := &x.
								EndIf

							EndIF
						Next nx

						//adicionando possiveis campos de resultado de analise no trb.
						For nx := 1 To Len( aCPOBRWRES )

							nPosCpo := aScan(aCamTRB,{|x| AllTrim(x[1]) = aCPOBRWRES[nX]})

							IF nPosCpo > 0 
								X:= (cAliasQRY )+"->"+aCamTRB[nPosCpo,1] 
								Y:= (cAliaTMPF)+"->"+aCamTRB[nPosCpo,1] 
								&y. := &x.
							Endif
						Next nX

						(cAliaTMPF)->( Msunlock() )
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
	
	oDlgSldPrd := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3]/1.25, oSize:aWindSize[4]/1.1, 'Lista de Lotes e Produtos Com Saldo.', , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta
	
	// Desabilita o fechamento da tela através da tela ESC.
	oDlgSldPrd:lEscClose := .F.

	// Instancia o layer
	oFWL_F := FWLayer():New()
	// Inicia o Layer
	oFWL_F:init( oDlgSldPrd,.F.)
	// Cria uma linha unica para o Layer
	oFWL_F:addLine( 'LINHA1', 100 , .F.)
	//oFWL_F:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL_F:addCollumn('COL1',100,.T.,'LINHA1' )
	
	cTitleBrw := " Produtos Com Saldo no Estoque com Caracteristicas do Item do PV. e Mesma UM. [(Lotes Limpos e Tratados na Mesma Embalagem)] "

	oFWL_F:addWindow( 'COL1', 'Wnd1', cTitleBrw	, 100 /*tamanho*/, .F., .T.,, 'LINHA1' )	//"Blocos"
   
    oPnlWnd_F:= oFWL_F:getWinPanel( 'COL1' 	, 'Wnd1', 'LINHA1' )

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

	//adicionando os campos de resultado (que são dinamicos de acordo como Layout) que devem aparecer no browse

	For nx := 1 To Len(aCPOBRWRES)
		nPosCpo := aScan(aArqTemp,{|x| AllTrim(x[1]) = aCPOBRWRES[nX]})

		AAdd(aColunas,FWBrwColumn():New())
		aColunas[Len(aColunas)]:SetData(&("{||"+aArqTemp[nPosCpo,1]+"}"))
		aColunas[Len(aColunas)]:SetTitle	( Alltrim(aArqTemp[nPosCpo,5]))
		aColunas[Len(aColunas)]:SetPicture(Alltrim(aArqTemp[nPosCpo,6]))
		aColunas[Len(aColunas)]:SetType(Alltrim(aArqTemp[nPosCpo,2]))
		aColunas[Len(aColunas)]:SetSize(aArqTemp[nPosCpo,3])
		aColunas[Len(aColunas)]:SetReadVar(aArqTemp[nPosCpo,1])
		aColunas[Len(aColunas)]:SetAlign( If(Alltrim(aArqTemp[nPosCpo,2]) == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	(cAliaTMPF)->( dbGoTop() )

	DEFINE FWFORMBROWSE oBrwSld DATA TABLE ALIAS cAliaTMPF OF oPnlWnd_F
	oBrwSld:SetTemporary(.T.)
	oBrwSld:SetColumns(aColunas)
	oBrwSld:SetDBFFilter(.T.)
	oBrwSld:SetUseFilter(.T.)
	oBrwSld:SetFieldFilter(AGRITEMCBRW(aArqTMP))
	oBrwSld:DisableDetails(.F.)
	oBrwSld:SetSeek(,aSeek)
	
	oBrwSld:SetProfileID( 'UBSA020F'	) 
	oBrwSld:SetDoubleClick( {|| fSelLteDir( )  })

	oBrwSld:AddButton("Sair",{|| oDlgSldPrd:end()},,9,0)

	ACTIVATE FWFORMBROWSE oBrwSld
    oDlgSldPrd:Activate( , , , .t., { || .t. }, , { || } )

	oTmpF:Delete()
	( cAliasQRY )->( DbCloseArea() )
	
Return .T.

//Função que marca o Chekbox na tela de direcionamento de lotes
Static Function fSelLteDir(  ) 

Local cLote 	:=  (oBrwSld:Alias())->NP9_LOTE
Local cSubLote 	:=  (oBrwSld:Alias())->B8_NUMLOTE

//cAliTRBL é o arquivo temporario do Browse da Tela de Seleção de Lotes.
DbSelectArea( cAliTRBL )
( cAliTRBL )->( dbSetOrder(1) )

	IF ( cAliTRBL )->( dbSeek( cLote + cSubLote ) )
		(cAliTRBL )->MARK := "LBOK" 
		(cAliTRBL )->( Msunlock() )
	Else
	   	Help(NIL, NIL, 'Ajuda', NIL, 'Este Lote não se Encontra Disponivel para Direcionamento.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Selecione Outro Lote.'})                  
	EndIF
oBrowsX:Refresh(.t.)
Return

/* Função que retorna array com as variaveis de resultados de analise do lote */

Static Function FiltraResultados()
	Local aArea := GetArea()
	Local aRet := {}
	Local cTPCampo := ""
	NPW->(dbSetOrder(2))
	NPW->(dbGoTop())
	While NPW->(!Eof()).AND. NPW->NPW_FILIAL = FwxFilial("NPW") 
		If !Empty(NPW->NPW_DESRES) .and. NPW->NPW_INFFIS = "N" .and. !Empty(NPW->NPW_CODTA)
			IF AGRIFDBSEEK("NPU",(NPW->NPW_CODTA + NPW->NPW_CAMPO),1,.F.)
				If 		NPU->NPU_TIPOVA = '1'
					cTPCampo := "NPX_RESNUM"
				Elseif 	NPU->NPU_TIPOVA = '2'
					cTPCampo := "NPX_RESTXT"
				Elseif 	NPU->NPU_TIPOVA = '3'
					cTPCampo := "NPX_RESDTA"
				Endif
				aadd(aRet,{NPW->NPW_CODTA,NPW->NPW_CAMPO,NPW->NPW_DESRES,cTPCampo})
			Endif
		Endif
		NPW->(dbSkip())
	EndDo
	RestArea(aArea)
Return aRet
