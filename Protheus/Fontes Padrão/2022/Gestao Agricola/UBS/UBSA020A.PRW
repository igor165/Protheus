/*{Protheus.doc} UBSA020A
Rotina que mostra o Saldo por Lote e permite selecionar o Lote para direcionar

@param     Modelo da rotina UBSA020 ( De direcionamento de lotes )
@return    Modelo atualizado com os lotes selecionados.
@author    AgroIndustria
@since      Agosto/2020
@version    P11
*/

#Include 'totvs.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWEDITPANEL.CH'

Static _aLotesSel := {}  // Ira conter os lotes dados dos lotes selecionados.selecionados

Function UBSA020A( oMdlUBA020)
    Local cAliasQRY		:= GetNextAlias()
	local cIndice 		:= ""
	Local nIndice
	local cChaveA
	Local aIndex	
	local lRastros := .t.
	local nx
	local ny
	local nSaldoL
	Local aSeek 		:= {}
	Local aColumns		:= {}
	Local aResultado 	:= FiltraResultados()
	Local cResult		:= ""
	Local cTypeDB		:= Upper( TcGetDb() )
	Local aSize := {}
	Local lEmpPrev		:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
	Local OMDL_ND5		:= nil
	Local nQTPVRESER	:= 0
	Local nQtDirec		:= 0
	Local cFiltro		:= 0
	Local nQtPvLbEst    := 0
	Local cCodSaf		:= ''
	Local cCultura		:= ''
	Local cCtvar		:= ''
	Local cCategoria	:= ''
	Local cPeneira		:= ''
	Local CPV			:= ''
	Local cUm			:= ''
	Local cProdutoPV	:= ''

	_aLotesSel 	:={}
	aCPosBRW	:={}
    aCPosBRWRe	:={}

 IF FWIsInCallStack('UBSA020B') .AND. oMdlUBA020 != NIL

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
	
	fLtesND6( oMdlUBA020 ) //Retorna lotes que ja se encontram no Grid ND6 ( para traze-los marcados no BROWSE)

EndIF

	aSize := MsAdvSize(.F.)	

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



/*Regra Geral
     Deve levar em consideração se o Lote está liberado
	 Deve mostrar somente lotes que a UM é igual a UM do pedido
	 considerar as caracteristicas ref. Ctvar,Peneira,categ. e codisaf
	 Agrupar por saldo do lote
*/

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
		SELECT NP9.NP9_FILIAL,NP9.NP9_CODSAF, NP9.NP9_PROD,SB1.B1_UM,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_UM, NP9.NP9_2UM,	NP9.NP9_CULTRA,NP3.NP3_DESCRI,
		NP9.NP9_CTVAR,NP4_DESCRI,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SB8.B8_LOCAL,B8_NUMLOTE,B8_LOTECTL,
		ROW_NUMBER() OVER ( PARTITION BY NP9.NP9_LOTE ,SB8.B8_NUMLOTE ORDER BY NP9.NP9_LOTE ,SB8.B8_NUMLOTE) AS IDLine,
		(SELECT SUM(ND6.ND6_QT) FROM  %Table:ND5% ND5
			INNER JOIN  %Table:ND6% ND6
     			ON ND6.%notDel%
	 			AND ND6.ND6_FILIAL = %xFilial:ND6% 
     			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
			WHERE ND5.%notDel%
			AND ND5.ND5_STATUS = '1'
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			///AND ND6.ND6_PRODUT = NP9.NP9_PROD
			AND ND6.ND6_LOTE = NP9.NP9_LOTE
			AND ND6.ND6_SUBLOT = SB8.B8_NUMLOTE
			///AND ND6.ND6_LOCAL = SB8.B8_LOCAL
		)  AS QTDIRECIONADA,

				(SELECT SUM(ND6.ND6_QT) FROM  %Table:ND5% ND5
			INNER JOIN  %Table:ND6% ND6
     			 ON ND6.%notDel%
	 			AND ND6.ND6_FILIAL = %xFilial:ND6% 
     			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
			WHERE ND5.%notDel%
			AND ND5.ND5_STATUS = '3' /// QT DIRECIONADA ONDE O DIRECIONAMENTO SE ENCONTRA EM TRANSFERENCIA DE UM PV PARA OUTRO
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			AND ND6.ND6_LOTE   = NP9.NP9_LOTE
			AND ND6.ND6_SUBLOT = SB8.B8_NUMLOTE
		)  AS QTDIRTRANSF,

		
		(SELECT SUM(SC0.C0_QUANT) FROM %Table:SC0% SC0
			INNER JOIN %Table:NJ6% NJ6
				ON NJ6.NJ6_RESERV  = SC0.C0_NUM 
				AND NJ6.NJ6_NMLOTE = SC0.C0_NUMLOTE
				AND NJ6.NJ6_LOTECT = SC0.C0_LOTECTL
				AND NJ6.NJ6_FILIAL = %xFilial:NJ6% 
				AND NJ6.%notDel%'
			INNER JOIN %Table:ND5%  ND5
				ON  ND5.ND5_PEDIDO = NJ6.NJ6_NUMPV
				AND ND5.ND5_ITEM   = NJ6.NJ6_ITEM
				AND ND5.ND5_STATUS = '1'
				AND ND5.ND5_UM     = SB1.B1_UM
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
				AND ND5.%notDel%
			INNER JOIN %Table:ND6%  ND6
				ON  ND6.ND6_CODIGO = ND5.ND5_CODIGO
				AND ND6.ND6_LOTE = NP9.NP9_LOTE
                AND ND6.ND6_SUBLOT =SB8.B8_NUMLOTE
				AND ND6.ND6_FILIAL = %xFilial:ND6% 
				AND ND6.%notDel%
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
			WHERE SC0.C0_LOTECTL  = NP9.NP9_LOTE
			 AND SC0.C0_NUMLOTE  = SB8.B8_NUMLOTE
			 AND SC0.C0_FILIAL   = %xFilial:SC0% 
			 AND SC0.%notDel%
		) AS QTPVRESERV,

		(SELECT SUM(C9_QTDLIB) QUANTIDADE
			FROM %Table:SC9%  SC9
			INNER JOIN %Table:ND5% ND5AUX4 
			    ON ND5AUX4.%notDel%
				AND ND5AUX4.ND5_FILIAL = %xFilial:ND5% 
				AND ND5AUX4.ND5_STATUS = '1'
				AND ND5AUX4.ND5_CODSAF = NP9.NP9_CODSAF
				AND ND5AUX4.ND5_PEDIDO = SC9.C9_PEDIDO
				AND ND5AUX4.ND5_ITEM   = SC9.C9_ITEM
				AND ND5AUX4.ND5_UM     = SB1.B1_UM
			INNER JOIN %Table:ND6%  ND6AUX4 
			    ON  ND6AUX4.%notDel%
				AND ND6AUX4.ND6_CODIGO = ND5AUX4.ND5_CODIGO 
				AND ND6AUX4.ND6_FILIAL = ND5AUX4.ND5_FILIAL 	
				AND ND6AUX4.ND6_PEDIDO = ND5AUX4.ND5_PEDIDO
				AND ND6AUX4.ND6_ITEMPV = ND5AUX4.ND5_ITEM
				AND ND6AUX4.ND6_CODSAF = ND5AUX4.ND5_CODSAF 
				AND ND6AUX4.ND6_LOTE   = NP9.NP9_LOTE
				AND ND6AUX4.ND6_SUBLOT = SB8.B8_NUMLOTE
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6AUX4.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
			WHERE SC9.%notDel%
			AND SC9.C9_FILIAL = %xFilial:SC9% 
			AND SC9.C9_BLEST <> '02'
		    AND   //Disconsidero se existe sc9 com reserva referenciada  que ainda não foi deletada.
				( SELECT COUNT (SC0.C0_NUM) FROM  %Table:SC0% SC0
				WHERE SC0.%notDel%
				AND   SC0.C0_NUM = SC9.C9_RESERVA
				AND   SC0.C0_FILIAL = %xFilial:SC0% 
				) = 0 
			) AS QtPvLbEst

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

	////EECVIEW(getLastQuery()[2],'XXX')

	aCamTRB :=	{ ;
	{"NP9_CODSAF" ,TamSX3("NP9_CODSAF")[3]    ,TamSX3("NP9_CODSAF")[1]     ,TamSX3("NP9_CODSAF")[2]     ,"Safra"     ,PesqPict("NP9","NP9_CODSAF")      },;
	{"NP9_LOTE"},;
	{"B8_NUMLOTE"},;
	{"NP9_UM"},;
	{"B8_DTVALID"},;
	{"B8_SALDO",	TamSX3("B8_SALDO")[3],	TamSX3("B8_SALDO")[1],	TamSX3("B8_SALDO")[2],AGRTITULO("B8_SALDO"),PesqPict("SB8","B8_SALDO")},;
	{"NP9_CULTRA",	TamSX3("NP9_CULTRA")[3],TamSX3("NP9_CULTRA")[1],TamSX3("NP9_CULTRA")[2],AGRTITULO("NP9_CULTRA"),PesqPict("NP9","NP9_CULTRA")},;
	{"NP3_DESCRI",	TamSX3("NP3_DESCRI")[3],TamSX3("NP3_DESCRI")[1],TamSX3("NP3_DESCRI")[2],'Desc.Cultura',X3PICTURE("NP3_DESCRI")},;	
	{"NP9_CTVAR",	TamSX3("NP9_CTVAR")[3],	TamSX3("NP9_CTVAR")[1],	TamSX3("NP9_CTVAR")[2],AGRTITULO("NP9_CTVAR"),PesqPict("NP9","NP9_CTVAR")},;	
	{"NP4_DESCRI",	TamSX3("NP4_DESCRI")[3],TamSX3("NP4_DESCRI")[1],TamSX3("NP4_DESCRI")[2],'Desc.Ctvar',X3PICTURE("NP4_DESCRI")},;	
	{"NP9_CATEG",	TamSX3("NP9_CATEG")[3],	TamSX3("NP9_CATEG")[1],	TamSX3("NP9_CATEG")[2],AGRTITULO("NP9_CATEG"),PesqPict("NP9","NP9_CATEG")},;
	{"NP9_PENE",	TamSX3("NP9_PENE")[3],	TamSX3("NP9_PENE")[1],	TamSX3("NP9_PENE")[2],AGRTITULO("NP9_PENE"),PesqPict("NP9","NP9_PENE")},;
	{"NP9_TIPLOT",	TamSX3("NP9_TIPLOT")[3],TamSX3("NP9_TIPLOT")[1],TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
	{"NP9_TRATO",	TamSX3("NP9_TRATO")[3],	TamSX3("NP9_TRATO")[1],	TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
	{"NP9_EMB",		TamSX3("NP9_EMB")[3],	TamSX3("NP9_EMB")[1],	TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")     },;
	{"MARK",		TamSX3("B1_OK")[3],		TamSX3("B1_OK")[1],		TamSX3("B1_OK")[2],FWX3Titulo("B1_OK"),PesqPict("SB1","B1_OK")     }}

    
	//Campos a aparecer no browse.
	acPosBRW:={'NP9_CODSAF','NP9_LOTE',"B8_SALDO","B8_DTVALID","NP9_CULTRA","NP3_DESCRI","NP9_CTVAR","NP4_DESCRI","NP9_CATEG","NP9_PENE","NP9_TIPLOT","NP9_TRATO",'NP9_EMB','NP9_UM'}  
	
	//Campos de resultado que serao exibidos na Consulta de lotes
	For Nx := 1 to Len(aResultado)
		aadd(aCamTRB,{ALLTRIM(aResultado[Nx][3]),TamSX3(aResultado[Nx][4])[3],TamSX3(aResultado[Nx][4])[1],TamSX3(aResultado[Nx][4])[2],aResultado[Nx][3],PesqPict("NPX",aResultado[Nx][4])})
	Next Nx

	For Nx := 1 to Len(aResultado) //adiciona os campos de Resultado de analise para um array especifico
	  						       //Pois os campos de resultado são encontrados de forma dinamica
		aadd(aCPosBRWRe,ALLTRIM(aResultado[Nx][3]))
	Next Nx

	aIndex := {"NP9_LOTE","B8_NUMLOTE"}
	aRet := AGRCRIATRB(,aCamTRB,aIndex,FunName(),.t.)
	oTRBL := aRet[3] //Nome do arquivo temporário
	cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (cAliTRBL )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )
		nIndice := If(lRastroS,2,3)

        cChaveA := IIf(lRastroS,(cAliasQRY)->(B8_NUMLOTE+NP9_LOTE+NP9_PROD+B8_LOCAL ),(cAliasQRY)->(NP9_PROD + B8_LOCAL+NP9_LOTE))

		SB8->( dbSetOrder( nIndice ) )
		IF SB8->( dbSeek( xFilial( "SB8" ) + cChaveA ) )

		 ////  IF (cAliasQRY)->NP9_TRATO == '1' .and. (cAliasQRY)->NP9_PROD != cProdutoPV  //So posso mostrar lotes tratados se for o mesmo produto do pedido
		 ////     (cAliasQRY)->(dbSkip())		
		 ////	  Loop
		 ///  EndIF

			nSaldoL  := SB8Saldo(.F.,!Empty((cAliasQRY)->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
			
			//Como a qtidade Reservada/Direcionada é uma soma por lote e a b8 traz o mesmo lote e safra n vezes
			//Faço esse tratamento para não considerar a qtidade reservada em duplicidade.
			//Não fiz um sql separado da qtd. reservada do lote para evitar ter que ficar abrindo e fechando
			//query a cada item da sb8 .

		    IF (cAliasQRY)->IDLine == 1  // Indica que é a 1a. vez que o lote aparece então eu faço adiciono a Qt. ao cpo QT Reservada
			    nQtPvLbEst  :=  (cAliasQRY)->QtPvLbEst
				nQTPVRESER 	:=  (cAliasQRY)->QTPVRESERV
				nQtDirec	:= 	(cAliasQRY)->QTDIRECIONADA + (cAliasQRY)->QTDIRTRANSF 
			EndIF
             
			IF  (nQtDirec > (nQTPVRESER + nQtPvLbEst)  )     // as Reservas do PV e possiveis, liberações de estoque (sc9) devem ser subtraidas da qt direcionada...
			    nSaldoL := nSaldoL - (nQtDirec - (nQTPVRESER + nQtPvLbEst) )
			EndIF

			nQtPvLbEst  := 0
			nQtDirec 	:= 0
			nQTPVRESER	:= 0

			DbSelectArea(cAliTRBL)
			(cAliTRBL)->( dbSetOrder(1) ) //Lote

			IF nSaldoL <> 0
				//If .not. (cAliTRBL)->( dbSeek( (cAliasQRY)->( NP9_LOTE + B8_NUMLOTE+ NP9_PROD ) ) )
				If .not. (cAliTRBL)->( dbSeek( (cAliasQRY)->( NP9_LOTE + B8_NUMLOTE ) ) )
					IF  RecLock(cAliTRBL, .t.)
						DbSelectArea(cAliasQRY)
						For nx := 1 To Fcount()
							IF Fieldname(nx) $ 'NP9_TRATO/NP9_TIPLOT/NP9_EMB/B8_SALDO'
								(cAliTRBL)->NP9_TRATO	:= X3CBoxDesc("NP9_TRATO",	( cAliasQRY )->NP9_TRATO	)
								(cAliTRBL)->NP9_TIPLOT 	:= X3CBoxDesc("NP9_TIPLOT",	( cAliasQRY )->NP9_TIPLOT)
								(cAliTRBL)->NP9_EMB		:= X3CBoxDesc("NP9_EMB"	,	( cAliasQRY )->NP9_EMB	)
								(cAliTRBL)->B8_SALDO	:= nSaldoL
							Else
								nPos := aScan(aArqTemp,{|x| AllTrim(x[1]) == Fieldname(nx)})
								If nPos > 0
									x := (cAliasQRY )+"->"+Fieldname(nx)
									y := (cAliTRBL)+"->"+aArqTemp[nPos,1]
									&y. := &x.
								EndIf

							EndIF
						Next nx

						//adicionando possiveis campos de resultado de analise no trb.
						For nx := 1 To Len( aCPosBRWRe )

							nPosCpo := aScan(aCamTRB,{|x| AllTrim(x[1]) = aCPosBRWRe[nX]})

							IF nPosCpo > 0 
								X:= (cAliasQRY )+"->"+aCamTRB[nPosCpo,1] 
								Y:= (cAliTRBL)+"->"+aCamTRB[nPosCpo,1] 
								&y. := &x.
							Endif
						nExt nX

						//Tratando possiveis lotes que ja estão selecionados no Modelo da ND6
					
						cLtSel := (cAliTRBL)->NP9_CODSAF 	+ "/"
						//cLtSel += (cAliTRBL)->NP9_PROD 		+ "/"
						//cLtSel += (cAliTRBL)-> B8_LOCAL		+ "/"
						cLtSel += (cAliTRBL)->NP9_LOTE 		+ "/"
						cLtSel += (cAliTRBL)->B8_NUMLOTE 	+ "/"
						cLtSel += (cAliTRBL)->NP9_CTVAR 

						IF nPos   := ASCAN(_aLotesSel, cLtSel ) > 0
							(cAliTRBL)->MARK := 'LBOK'
						EndIF
						
						(cAliTRBL)->( Msunlock() )
					EndIF
				Else
					IF RecLock(cAliTRBL, .f.)
						(cAliTRBL)->B8_SALDO	+= nSaldoL
						
						IF (cAliTRBL)->B8_SALDO == 0 //Garantindo que não tennho nenhum saldo zerado
						   (cAliTRBL)->( DbDelete())
						EndIF

						(cAliTRBL)->( Msunlock() )
					EndIF
				EndIF
			EndIF
		EndIf
		(cAliasQRY)->(dbSkip())		
	EndDo

	// monta a estruta para index
	For nx := 1 To Len(aIndex)
		cIndice := aIndex[nx]
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
			nPos1 := Ascan(aArqTemp,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
			If nPos1 > 0
				cDescIn += Alltrim(aArqTemp[nPos1,5])+If(ny < len(vVetInT)," + ","")
				cTamInd += aArqTemp[nPos1,3]
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
	
	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3]/1.2, oSize:aWindSize[4]/1.1, 'Seleção de lotes a direcionar', , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta
	
	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	// Instancia o layer
	oFWL1 := FWLayer():New()
	// Inicia o Layer
	oFWL1:init( oDlg,.F.)
	// Cria uma linha unica para o Layer
	oFWL1:addLine( 'LINHA1', 100 , .F.)
	//oFWL1:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL1:addCollumn('COL1',100,.T.,'LINHA1' )
	oFWL1:addWindow( 'COL1', 'Wnd1', 'Listagem de Lotes Para Direcionamento '	, 100 /*tamanho*/, .F., .T.,, 'LINHA1' )	//"Blocos"
   
    oPnlWnd1:= oFWL1:getWinPanel( 'COL1' 	, 'Wnd1', 'LINHA1' )

     //adicionando os cpos que devem aparecer no browse
     For nx := 1 To Len(acPosBRW)

	 nPosCpo := aScan(aArqTemp,{|x| AllTrim(x[1]) = acPosBRW[nX]})
 
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(acolumns)]:SetData(&("{||"+aArqTemp[nPosCpo,1]+"}"))
		aColumns[Len(acolumns)]:SetTitle	( Alltrim(aArqTemp[nPosCpo,5]))
		aColumns[Len(acolumns)]:SetPicture(Alltrim(aArqTemp[nPosCpo,6]))
		aColumns[Len(acolumns)]:SetType(Alltrim(aArqTemp[nPosCpo,2]))
		aColumns[Len(acolumns)]:SetSize(aArqTemp[nPosCpo,3])
		aColumns[Len(acolumns)]:SetReadVar(aArqTemp[nPosCpo,1])
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aArqTemp[nPosCpo, 1])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	//adicionando os campos de resultado (que são dinamicos de acordo como Layout) que devem aparecer no browse

	For nx := 1 To Len(aCPosBRWRe)
		nPosCpo := aScan(aArqTemp,{|x| AllTrim(x[1]) = aCPosBRWRe[nX]})

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(acolumns)]:SetData(&("{||"+aArqTemp[nPosCpo,1]+"}"))
		aColumns[Len(acolumns)]:SetTitle	( Alltrim(aArqTemp[nPosCpo,5]))
		aColumns[Len(acolumns)]:SetPicture(Alltrim(aArqTemp[nPosCpo,6]))
		aColumns[Len(acolumns)]:SetType(Alltrim(aArqTemp[nPosCpo,2]))
		aColumns[Len(acolumns)]:SetSize(aArqTemp[nPosCpo,3])
		aColumns[Len(acolumns)]:SetReadVar(aArqTemp[nPosCpo,1])
		aColumns[Len(aColumns)]:SetAlign( If(Alltrim(aArqTemp[nPosCpo,2]) == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

		//Sentando filtro de dados no Temp para mostrar somente lotes com qt maior que 0]
		cFiltro := "(cAliTRBL)->B8_SALDO > 0 "
		///Emerhj (cAliTRBL)->( DBSetFilter ( {|| &cFiltro}, cFiltro) )    // Filtra somente Registros selecionados e da Filial Corrente
		
		(cAliTRBL)->( dbGoTop() )

	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliTRBL OF oPnlWnd1
	oBrowsX:SetTemporary(.T.)
	oBrowsX:AddMarkColumns({|| Iif(!Empty( (oBrowsX:Alias())->MARK), "LBOK", "LBNO") }, {|| MkColClick( oBrowsX ) }, {||MarkAll(oBrowsX) })
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:SetFieldFilter(AGRITEMCBRW(aArqTemp))
	oBrowsX:DisableDetails(.F.)
	oBrowsX:SetSeek(,aSeek)

	oBrowsX:SetFilterDefault( cFiltro	) 
	oBrowsX:SetProfileID( 'UBSA020A'	) 
	////oBrowsX:SetDoubleClick( {|| fLteDetail( oBrowsX )  })
	oBrowsX:AddButton("Sair",{|| oDlg:end()},,9,0)
	oBrowsX:AddButton("Selecionar e Sair",{|| fUpdModel( oMdlUBA020 ),ODlg:End()},,9,0)
	oBrowsX:AddButton("Saldo Estoque Lote e Produtos",{|| fLteDetail( oBrowsX )},,9,0) //Explode o lote selecionado por produto.
	oBrowsX:AddButton("Saldo Estoque Lotes Com Mesma caracteristica",{|| fSldOtrLts( oMdlUBA020, oBrowsX )},,9,0) 	// Demonstra Saldo do estoque por lote 
																										//e produto de todos os lotes que tem saldo e as mesmas caracteristicas e Unid. medida

	ACTIVATE FWFORMBROWSE oBrowsX
    oDlg:Activate( , , , .t., { || .t. }, , { || } )

	oTRBL:Delete()
	( cAliasQRY )->( DbCloseArea() )
	
Return .T.


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


/*{Protheus.doc} MkColBMark(oBrowse)
Retorna a marca do item

@param     Objeto do Browse 
@sample    MkColBMark(oMrkBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
Static Function MkColBMark( oMrkBrowse )
	Local aAreaAtu	:= GetArea()
	Local cMark		:= 'LBNO'

	Iif(!Empty( (oMrkBrowse:Alias())->MARK), "LBOK", "LBNO")

	If ( ! (oMrkBrowse:Alias())->MARK == 'LBOK'  )
		cMark := 'LBNO'
	ElseIF( ! (oMrkBrowse:Alias())->MARK == ''  )
		cMark := 'LBOK'
	EndIf

	RestArea( aAreaAtu )

Return ( cMark )

/*{Protheus.doc} MkColClick(oBrowse)
Marca ou desmarca itens do Browse 

@param     Objeto do Browse 
@sample    MkColClick(oBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
Static Function MkColClick( oMrkBrowse )
	Local aAreaAtu	:= GetArea()

	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->MARK := Iif(Empty((oMrkBrowse:Alias())->MARK),"OK","  ")
	(oMrkBrowse:Alias())->(MsUnLock())

	RestArea( aAreaAtu )

Return (.t.)

/*{Protheus.doc} MkColClick(oMrkBrowse)
Marca ou desmarca todos itens

@param     Objeto do Browse 
@sample    MarkAll(oMrkBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
Static __lMarkAll := .T.
Static Function MarkAll(oMrkBrowse)

	(oMrkBrowse:Alias())->( dbGoTop() )
	
	While (oMrkBrowse:Alias())->(!Eof())
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK := Iif(__lMarkAll,"OK","  ")
		(oMrkBrowse:Alias())->(MsUnLock())

		(oMrkBrowse:Alias())->(DbSkip())
	EndDo
	__lMarkAll := !__lMarkAll
	oMrkBrowse:Refresh (.T.)
Return .T.


/*{Protheus.doc} fGetLtesND6( modelo de dados oMdlUBA020)
	Carrega os lotes que ja se encontram selecionados no modelo
	
@param     Objeto do modelo de dados 
@sample    fGetLtesND6( oMdlUBA020 )
@return    array contendo todos os lotes que ja se encontram no modelo
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
static function fLtesND6( oMdlUBA020 )

Local OMDL_ND6
Local aSaveLines
Local nX			:= 0
LOCAL cltGrid		:= ''

	IF  oMdlUBA020 != nil
		OMDL_ND6	:=  oMdlUBA020:GetModel( "OMDL_ND6" )
		aSaveLines	:= FWSaveRows()

		For nX := 1 to OMDL_ND6:Length() // Verificando se ja existe o lote no array
			OMDL_ND6:GoLine( nX )

			IF ! OMDL_ND6:IsDeleted()
				cltGrid := OMDL_ND6:GetValue( "ND6_CODSAF")		+ "/" 
				///cltGrid += OMDL_ND6:GetValue( "ND6_PRODUT" ) 	+ "/"
				///cltGrid += OMDL_ND6:GetValue( "ND6_LOCAL")		+ "/"
				cltGrid += OMDL_ND6:GetValue( "ND6_LOTE")		+ "/" 
				cltGrid += OMDL_ND6:GetValue( "ND6_SUBLOT")		+ "/"
				cltGrid += OMDL_ND6:GetValue( "ND6_CTVAR")

				AAdd(_aLotesSel,cltGrid)
			EndIF
		nExt nX
		FWRestRows( aSaveLines )
		
	EndIF
Return()



/*{Protheus.doc} fUpdModel(oMrkBrowse)
Preenche o modelo de dados da nd6 com os Lotes selecionados

@param     Objeto do Modelod e dados do UBA020
@sample    fUpdModel( oMdlUBA020 )
@return    Linha do Browse Recebe ou retira a Marca
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/

Static function fUpdModel( oMdlUBA020 )

Local oView
Local OMDL_ND6
Local nX			:= 0
Local cLtSel		:= ''
Local cLtGrid		:= ''
Local cFiltro		:= ''
Local cItem			:= ''

	IF  oMdlUBA020 != nil
		OMDL_ND6	:=  oMdlUBA020:GetModel( "OMDL_ND6" )
		
		//Limpando dados do Grid
		OMDL_ND6:cleardata()
		OMDL_ND6:InitLine()

		oMdlUBA020:Getmodel('UBSA020CALC'):cleardata()
		oMdlUBA020:Getmodel('UBSA020CALC'):Deactivate()
		oMdlUBA020:Getmodel('UBSA020CALC'):activate()

		
		oMdlUBA020:GetModel("OMDL_ND6"):GetStruct():SetProperty( 'ND6_QT' , MODEL_FIELD_OBRIGAT, .F. )


		// -- Filtrando o Arquivo Para Pegar Somentes os Registros Marcados --
		cFiltro := "(cAliTRBL)->MARK != ' ' "

		(cAliTRBL)->( DBSetFilter ( {|| &cFiltro}, cFiltro) )    // Filtra somente Registros selecionados e da Filial Corrente
		(cAliTRBL)->( dbGoTop() )

			nX := OMDL_ND6:Length() 

			While (cAliTRBL)->( !Eof() ) 

				IF nX == 0 .or. nx > 1
					OMDL_ND6:AddLine()
					nX := OMDL_ND6:Length() 
				EndIF
				
				OMDL_ND6:GoLine(nX)

				cItem := StrZero(nX,TamSX3( "ND6_ITEM" )[ 1 ])
			
			    OMDL_ND6:LoadValue( "ND6_ITEM", 	cItem )
				OMDL_ND6:LoadValue( "ND6_CODSAF", 	(cAliTRBL)->NP9_CODSAF )
				OMDL_ND6:LoadValue( "ND6_LOTE",     (cAliTRBL)->NP9_LOTE   )
				///OMDL_ND6:LoadValue( "ND6_PRODUT", 	(cAliTRBL)->NP9_PROD)
				////OMDL_ND6:LoadValue( "ND6_LOCAL", 	(cAliTRBL)->B8_LOCAL)
				OMDL_ND6:LoadValue( "ND6_CTVAR", 	(cAliTRBL)->NP9_CTVAR  )
				OMDL_ND6:LoadValue( "ND6_SUBLOT", 	(cAliTRBL)->B8_NUMLOTE  )
				OMDL_ND6:SetValue( "ND6_QT ",      0 )

				(cAliTRBL)->( dbSkip() )
				nx++

			EndDo 


		oMdlUBA020:GetModel("OMDL_ND6"):GetStruct():SetProperty( 'ND6_QT' , MODEL_FIELD_OBRIGAT, .T. )

		//Limpando total direcionado ja existente
		
		oMdlUBA020:LoadValue('UBSA020CALC','TOTDIRECIONADO', 0)
		
		
		///oMdlUBA020:Getmodel('UBSA020CALC'):cleardata()
		///oMdlUBA020:Getmodel('UBSA020CALC'):Deactivate()
		///oMdlUBA020:Getmodel('UBSA020CALC'):activate()
		

		OMDL_ND6:GoLine( 1 )
		oViewUBSA020		:= FwViewActive()
		
		IF ! oViewUBSA020= nIl 
		   
		   oViewUBSA020:Refresh('VIEW_ND6')
		   
		EndIF

	EndIF
	oDlg:end()
Return

/*{Protheus.doc} fLteDetail(oMrkBrowse)
Mostra os detalhes do Lote

@param     Browse
@sample    fLteDetail( oMrkBrowse, Unidade Medida )
@return    nil
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
Static function fLteDetail( oMrkBrowse )

UBSA020E( (oMrkBrowse:Alias())->NP9_LOTE, (oMrkBrowse:Alias())->NP9_CODSAF, (oMrkBrowse:Alias())->NP9_UM, (oMrkBrowse:Alias())->B8_SALDO )

Return()


/*{Protheus.doc} fLteDetail(oMdlUBA020)
Mostra Saldo por item de estoque ( B8 ) de Todos os lotes com a mesma UM, e caracteristicas do lote do pedido

@param     Modelo de dados da Seleção de lotes
           Browse de Lotes Disponiveis para Direcionamento.
@sample    fSldOtrLts( oMdlUBA020, oBrowsX )
@return    nil
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
Static function fSldOtrLts( oMdlUBA020, oBrowsX )

UBSA020F( oMdlUBA020, oBrowsX )

Return()
