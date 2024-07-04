
/*{Protheus.doc} UBSA020G
Rotina que mostra o Saldo dos itens do estoque, contendo lotes de sementes
de acordo com as caracteristicas e UM (Embalagem) especificadas no Item do PV.

@param     nil
@return    nil.
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

#Include 'totvs.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWEDITPANEL.CH'

Function UBSA020G( )
	
	local nx
	Local aColunas		:= {}
	Local aSize 		:= {}
	Local aCPOBROWSE	:= {}
	Local cTitleBrw		:= ''
	Local nQTPVRESER    := 0
	Local nQtPvLbEst	:= 0
	Local nSaldoDir		:= 0
	Local aArqTMP		

	Private oTmpG		:= {}	
	Private cAliaTMPG	
	Private aSeek		:= {}
	
	aSize := MsAdvSize(.F.)	

	IF !PERGUNTE('UBSA020G',.t.)
		Return .F.
	EndIf

	FWMsgRun(/*oComponent*/,{|| aArqTmp:=FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."

	//Campos a aparecer no browse.
	aCPOBROWSE:={'ND5_PRODUT','B1_DESC','ND5_UM','ND5_CODSAF',"ND6_LOTE","ND6_SUBLOT",'NP9_CATEG','NP9_CTVDES','NP9_PENE','TRATADO',"QTDIREC",'SLDLOTE'}  

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
	
	cTitleBrw := "Lote(s) Direcionado(s) para o(s) Item(s) do(s) PV(s) x Saldo de Estoque do Lote"

	oFWL_F:addWindow( 'COL1', 'Wnd1', cTitleBrw	, 100 /*tamanho*/, .F., .T.,, 'LINHA1' )	//"Blocos"
   
    oPnlWnd_F:= oFWL_F:getWinPanel( 'COL1' 	, 'Wnd1', 'LINHA1' )

     //adicionando os cpos que devem aparecer no browse
     For nx := 1 To Len(aCPOBROWSE)

		AAdd(aColunas,FWBrwColumn():New())

		IF aCPOBROWSE[ nX ] $ "SLDLOTE|QTDIREC|TRATADO"
			Do Case 
				Case aCPOBROWSE[ nX ] $ "SLDLOTE"
					aColunas[Len(aColunas)]:SetTitle(AllTrim( "Sld. Lote" ))  
					aColunas[Len(aColunas)]:SetData( &("{|| SLDLOTE }") )
					aColunas[Len(aColunas)]:SetSize( TamSx3("B8_SALDO")[1] )
					aColunas[Len(aColunas)]:SetDecimal( TamSx3('B8_SALDO')[2] )
					aColunas[Len(aColunas)]:SetPicture( X3PICTURE('B8_SALDO') )
					aColunas[Len(aColunas)]:SetAlign( CONTROL_ALIGN_RIGHT ) 
				Case aCPOBROWSE[ nX ] $ "QTDIREC"
					aColunas[Len(aColunas)]:SetTitle(AllTrim( "Qt.Direcionada" ))  
					aColunas[Len(aColunas)]:SetData( &("{|| QTDIREC }") )
			aColunas[Len(aColunas)]:SetSize( TamSx3("B8_SALDO")[1] )
					aColunas[Len(aColunas)]:SetDecimal( TamSx3('B8_SALDO')[2] )
					aColunas[Len(aColunas)]:SetPicture( X3PICTURE('B8_SALDO') )
					aColunas[Len(aColunas)]:SetAlign( CONTROL_ALIGN_RIGHT ) 
				Case aCPOBROWSE[ nX ] $ "TRATADO"
					aColunas[Len(aColunas)]:SetTitle(AllTrim( "Lote Tratado" ))  
					aColunas[Len(aColunas)]:SetData( &("{|| TRATADO }") )
					aColunas[Len(aColunas)]:SetSize( 3 )
					aColunas[Len(aColunas)]:SetDecimal( 0 )
					aColunas[Len(aColunas)]:SetPicture( '@!' )
					aColunas[Len(aColunas)]:SetAlign( CONTROL_ALIGN_LEFT ) 
  			EndCase

		Else
			aColunas[Len(aColunas)]:SetData( &("{||"+aCPOBROWSE[ nX ]+"}"))
			aColunas[Len(aColunas)]:SetTitle( AllTrim(RetTitle( aCPOBROWSE[nX]) )) 
			aColunas[Len(aColunas)]:SetSize(TamSx3(aCPOBROWSE[nX])[1])
			aColunas[Len(aColunas)]:SetDecimal(TamSx3(aCPOBROWSE[nX])[2])
			aColunas[Len(aColunas)]:SetPicture(X3PICTURE(aCPOBROWSE[nX]))
			aColunas[Len(aColunas)]:SetAlign( If( aCPOBROWSE[ nX ] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
		EndIF
		
	Next nx

	(cAliaTMPG)->( dbGoTop() )

	DEFINE FWFORMBROWSE oBrwSld DATA TABLE ALIAS cAliaTMPG OF oPnlWnd_F
	oBrwSld:SetTemporary(.T.)
	oBrwSld:SetColumns(aColunas)
	oBrwSld:SetDBFFilter(.T.)
	oBrwSld:SetUseFilter(.T.)
	oBrwSld:SetFieldFilter(AGRITEMCBRW(aArqTMP))
	oBrwSld:DisableDetails(.F.)
	oBrwSld:SetSeek(,aSeek)
	
	oBrwSld:SetProfileID( 'UBSA020G'	) 
	////oBrwSld:SetDoubleClick( {|| fSelLteDir( )  })

	oBrwSld:AddButton("Sair",{|| oDlgSldPrd:end()},,9,0)

	ACTIVATE FWFORMBROWSE oBrwSld
    oDlgSldPrd:Activate( , , , .t., { || .t. }, , { || } )

	oTmpG:Delete()
	
Return .T.

/*{Protheus.doc} fSUBQTDIR
	Função que Retorna possiveis quantidades direcionadas que ja estão 
	Em Reserva(seleção de lotes) ou em faturamento ( SC9 Liberada ou Faturada) indica que já passaram da Seleção de lotes.

@param     cCodSaf
		   Lote direcionado
           SubLote direcionado
		   Produto do PV. que possui o lote direcionado
		   Ponteiro que irá conter a qtidade que se encontra em Reserva( Seleção de Lotes)
		   Ponteiro que irá conter a qtidade que se encontra em Faturamento( SC9 Liberada ou Faturada)
@return    nil.
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

Function fSUBQTDIR(cCodSaf, cLote,cSubLote, cProdut,nQTPVRESER,nQtPvLbEst)

Local cQryNJ6		:= GetNextAlias() //Verifica se pedido direcionado ja tem reserva
Local cQrySC9		:= GetNextAlias() //Verifica se Pedido direcionado ja esta em Faturamento

// Verificando a quantidade dos pedidos direciondos que estão em Reserva ou em processo de faturamento

BeginSQL Alias cQryNJ6

	SELECT SUM(NJ6.NJ6_QTDE)  AS QTPVRESERV FROM %Table:NJ6%  NJ6
			INNER JOIN %Table:ND5% ND5 
				ON ND5.%notDel%
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			AND ND5.ND5_STATUS = '1'
			AND ND5.ND5_CODSAF = %Exp:cCodsaf%
			AND ND5.ND5_PEDIDO = NJ6.NJ6_NUMPV
			AND ND5.ND5_ITEM   = NJ6.NJ6_ITEM
			AND ND5.ND5_PRODUT = %Exp:cProdut%
		INNER JOIN %Table:ND6%  ND6 
			ON  ND6.%notDel%
			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
			AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 	
			AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
			AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
			AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
			AND ND6.ND6_LOTE   = %Exp:cLote%
			AND ND6.ND6_SUBLOT = %Exp:cSubLote%
		INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
			ON SC5.%notDel%
			AND SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
			AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')				
		WHERE NJ6.%notDel%
			AND NJ6.NJ6_LOTECT = %exp:cLote%
			AND NJ6.NJ6_NMLOTE = %exp:cSubLote%
			AND NJ6.NJ6_FILIAL = %xFilial:NJ6%
EndSQL

nQTPVRESER 	:=  (cQryNJ6)->QTPVRESERV

( cQryNJ6 )->( DbCloseArea() )

// Verificando a quantidade dos pedidos ja se contra faturado / em faturamento. ( SC9 )

BeginSQL Alias cQrySC9

 		SELECT SUM(C9_QTDLIB) QtPvLbEst
			FROM %Table:SC9%  SC9
			INNER JOIN %Table:ND5% ND5 
			    ON ND5.%notDel%
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
				AND ND5.ND5_STATUS = '1'
				AND ND5.ND5_CODSAF = %Exp:cCodsaf%
				AND ND5.ND5_PEDIDO = SC9.C9_PEDIDO
				AND ND5.ND5_ITEM   = SC9.C9_ITEM
				AND ND5.ND5_PRODUT    = %exp:cProdut%
			INNER JOIN %Table:ND6%  ND6 
			    ON  ND6.%notDel%
				AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
				AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 	
				AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
				AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
				AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
				AND ND6.ND6_LOTE   = %exp:cLote%
				AND ND6.ND6_SUBLOT = %exp:cSubLote%
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
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
EndSQL

nQtPvLbEst  :=  (cQrySC9)->QtPvLbEst

( cQrySC9 )->( DbCloseArea() )

Return (  )


/*{Protheus.doc} fsldLote
Retorna o Saldo de um lote/sublote em seu produto

@param     Lote direcionado
           SubLote direcionado
		   Produto do PV. que possui o lote direcionado
@return    nSaldo do Lote/sublote em seu produto
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

Static function fsldLote(cLote, cSubLote,cCodProd )
//Pegando conteúdo do parâmetro
Local lEmpPrev	:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
Local cAliasQRY := GetNextAlias()
Local nx 		:=0
Local cQuery	:= ''
Local lRastroS 	:= If(Rastro(cCodProd,"S"),.t.,.f.)
Local nSaldoL	:= 0
Local nIndice
 
//Buscando a estrutura da SB8
DbSelectArea("SB8")
aStruSB8 := SB8->(DbStruct())
 
//Criando a consulta que irá buscar os dados do Produto
cQuery := " SELECT "
cQuery += "        * "
cQuery += " FROM "
cQuery += "        " + RetSqlName('SB8') + " SB8 "
cQuery += " WHERE "
cQuery += "        B8_FILIAL  = '" + FWxFilial('SB8') + "' "
cQuery += "        AND B8_PRODUTO = '" + cCodProd + "'"
cQuery += "        AND B8_LOTECTL = '" + cLote + "'"
cQuery += "        AND B8_NUMLOTE  = '" + cSubLote + "'"
cQuery += "        AND SB8.D_E_L_E_T_ = ' ' "

	MPSysOpenQuery( cQuery, cAliasQRY )
 
//Percorre todas as linhas da query
    While ! (cAliasQRY)->(EoF())
	
		nIndice := If(lRastroS,2,3)

        cChaveA := IIf(lRastroS,cSubLote + cLote + cCodProd + (cAliasQRY)->B8_LOCAL, cCodProd + (cAliasQRY)->B8_LOCAL+cLote+cSubLote)

   		SB8->( dbSetOrder( nIndice ) )
		IF SB8->( dbSeek( xFilial( "SB8" ) + cChaveA ) )
			nSaldoL  += SB8Saldo(.F.,!Empty( cLote ),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
		EndIF
         
        (cAliasQRY)->( DbSkip() )
    EndDo
     
(cAliasQRY)->(DbCloseArea())

Return ( nSaldoL )

//função que monta o TMP do browse
Static function FMontaTmp()
	Local cFiltro		:=''
	Local cAliasQRY		:= GetNextAlias()
	Local aArqTMP
	Local cIndice		:=''
	Local nY			:=0
	Local nX            :=0
	Local aIndice
	Local cCateg		:= ''
    Local cCtvVar		:= ''
    Local cPene         := ''
	Local cTratado		:= ''
	
	MakeSqlExpr('UBSA020G')  // Ajusta os parametros range para formato sql

	IF !Empty(MV_PAR01)   //Safra
   		cFiltro += " AND " + MV_PAR01
	EndIF


	If Empty(cFiltro)
		cFiltro := "%%"
	Else
		cFiltro := "% " + cFiltro + " %"
	Endif

	BeginSQL Alias cAliasQRY

	SELECT ND5.ND5_FILIAL, ND5_PRODUT, ND5.ND5_UM, ND5.ND5_CODSAF,ND6.ND6_LOTE,ND6.ND6_SUBLOT, SUM(ND6.ND6_QT) AS QTDIRECIONADA FROM  %Table:ND5%  ND5 
		INNER JOIN  %Table:ND6%  ND6 
				ON ND6.%notDel%
			AND ND6.ND6_FILIAL = %xFilial:ND6%
			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
		INNER JOIN %Table:SC5%  SC5 
			ON SC5.%notDel%
			AND SC5.C5_FILIAL =%xFilial:SC5%
			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
			AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
		
		WHERE ND5.%notDel%
		AND ND5.ND5_STATUS = '1'
		AND ND5.ND5_FILIAL = %xFilial:ND5%
		%exp:cFiltro%  
		GROUP BY ND5.ND5_FILIAL,ND5.ND5_PRODUT, ND5.ND5_UM, ND5.ND5_CODSAF,ND6.ND6_LOTE,ND6.ND6_SUBLOT
		ORDER BY ND6_LOTE, ND5_PRODUT
	EndSQL

///EECVIEW(getLastQuery()[2],'XXX')

	aCamTRB :=	{ ;
	{"ND5_PRODUT",	TamSX3("ND5_PRODUT"	)[3],	TamSX3("ND5_PRODUT"	)[1],	TamSX3("ND5_PRODUT"  )[2],	"Cod.Produto",				X3PICTURE("ND5_PRODUT") 	},;
	{"B1_DESC",		TamSX3("B1_DESC"	)[3],	TamSX3("B1_DESC"  	)[1],	TamSX3("B1_DESC"  )[2],		"Produto",					PesqPict("SB1","B1_DESC")   },;
	{"ND5_UM",		TamSX3("ND5_UM"		)[3],	TamSX3("ND5_UM"		)[1],	TamSX3("ND5_UM"  )[2] ,		X3TITULO('ND5_UM'),			X3PICTURE("ND5_UM") 		},;
	{"ND5_CODSAF",	TamSX3("ND5_CODSAF")[3]    	,TamSX3("ND5_CODSAF")[1],	TamSX3("ND5_CODSAF")[2],	X3TITULO('ND5_CODSAF'),		X3PICTURE("ND5_CODSAF")     },;
	{"ND6_LOTE",	TamSX3("ND6_LOTE")[3]    	,TamSX3("ND6_LOTE")[1],		TamSX3("ND6_LOTE")[2],		X3TITULO('ND6_LOTE'),		X3PICTURE("ND6_LOTE")      	},;
	{"ND6_SUBLOT",	TamSX3("ND6_SUBLOT")[3]    	,TamSX3("ND6_SUBLOT")[1],	TamSX3("ND6_SUBLOT")[2],	X3TITULO('ND6_SUBLOT'),		X3PICTURE("ND6_SUBLOT")     },;
	{"NP9_CATEG",	TamSX3("NP9_CATEG")[3]    	,TamSX3("NP9_CATEG")[1],	TamSX3("NP9_CATEG")[2],		X3TITULO('NP9_CATEG'),		X3PICTURE("NP9_CATEG")     	},;
	{"NP9_CTVDES",	TamSX3("NP9_CTVDES")[3]    	,TamSX3("NP9_CTVDES")[1],	TamSX3("NP9_CTVDES")[2],	X3TITULO('NP9_CTVDES'),		X3PICTURE("NP9_CTVDES")     },;
	{"NP9_PENE",	TamSX3("NP9_PENE")[3]    	,TamSX3("NP9_PENE")[1],		TamSX3("NP9_PENE")[2],		X3TITULO('NP9_PENE'),		X3PICTURE("NP9_PENE")     	},;
	{"TRATADO",		'C'							,3,							0,							'Tratado',					'@!' 						},;
	{"QTDIREC",		TamSX3("ND6_QT")[3]    		,TamSX3("ND6_QT")[1],		TamSX3("ND6_QT")[2],		"Qt.Direcionada",			X3PICTURE("ND6_QT")      	},;
	{"SLDLOTE",		TamSX3("B2_QATU")[3]    	,TamSX3("B2_QATU")[1],		TamSX3("B2_QATU")[2],		"Sld. Lote" ,				X3PICTURE("B2_QATU")      	}}
	    
	aIndice := {"ND6_LOTE","ND6_SUBLOT","ND5_PRODUT"}
	aRet := AGRCRIATRB(,aCamTRB,aIndice,FunName(),.t.)
	oTmpG := aRet[3] //Nome do arquivo temporário
	cAliaTMPG := aRet[4] //Nome do alias do arquivo temporario
	aArqTMP := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (cAliaTMPG )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )

		//Fução ira retornar vrs. nas vars. ponteiro
		nQTPVRESER := 0
		nQtPvLbEst := 0
		fSUBQTDIR((cAliasQRY)->ND5_CODSAF , (cAliasQRY)->ND6_LOTE,(cAliasQRY)->ND6_SUBLOT, (cAliasQRY)->ND5_PRODUT,@nQTPVRESER,@nQtPvLbEst)
	    
		nSaldoDir := 0
    	IF  ( (cAliasQRY)->QTDIRECIONADA > (nQTPVRESER + nQtPvLbEst)  )     // as Reservas do PV e possiveis, liberações de estoque (sc9) devem ser subtraidas da qt direcionada...
		    nSalDoDir := (cAliasQRY)->QTDIRECIONADA - (nQTPVRESER + nQtPvLbEst)
		EndIF

		IF !nSaldoDir >0  // Se o direcionamento já foi completamente atendido
		   (cAliasQRY)->(dbSkip())	
		   Loop
		EndIf
		

		//Retorna saldo do Lote e produto
		nSaldoL:= fsldLote((cAliasQRY)->ND6_LOTE,(cAliasQRY)->ND6_SUBLOT, (cAliasQRY)->ND5_PRODUT )

        //Inicializa vars ponteiro
        cCateg 	:= ''
		cCtvar 	:= ''
		cPene  	:= ''
		cTratado:= ''

		fDadosLote((cAliasQRY)->ND6_LOTE, (cAliasQRY)->ND5_PRODUT, (cAliasQRY)->ND5_UM, @cCateg, @cCtvar, @cPene, @cTratado)

		DbSelectArea(cAliaTMPG)
		(cAliaTMPG)->( dbSetOrder(1) )

		(cAliaTMPG)->( dbSeek( (cAliasQRY)->( ND6_LOTE + ND6_SUBLOTE+ ND5_PRODUT ) ) )
		
		RecLock(cAliaTMPG, .t.)
		(cAliaTMPG)->ND5_PRODUT 	:= (cAliasQRY)->ND5_PRODUT
		(cAliaTMPG)->B1_DESC 		:= POSICIONE('SB1',1,xFilial('SB1') + (cAliasQRY)->ND5_PRODUT ,'B1_DESC')   
		(cAliaTMPG)->ND5_UM 		:= (cAliasQRY)->ND5_UM
		(cAliaTMPG)->ND5_CODSAF 	:= (cAliasQRY)->ND5_CODSAF
		(cAliaTMPG)->ND6_LOTE		:= (cAliasQRY)->ND6_LOTE
		(cAliaTMPG)->ND6_SUBLOT		:= (cAliasQRY)->ND6_SUBLOT
		(cAliaTMPG)->QTDIREC 		:=  nSaldoDir
		(cAliaTMPG)->SLDLOTE		:= nSaldol
		(cAliaTMPG)->NP9_CATEG		:= cCateg
		(cAliaTMPG)->NP9_CTVDES		:= cCtvar
		(cAliaTMPG)->NP9_PENE		:= cPene
		(cAliaTMPG)->TRATADO		:= cTratado

		(cAliaTMPG)->( msunlock() )

		(cAliasQRY)->(dbSkip())		
	EndDo

	( cAliasQRY )->( DbCloseArea() )


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

Return( aArqTmp )

//Rotina que encontra os dados do Lote Direcionado.
/*
@param: Lote
        Produto
		Unidade medida do Produto
		Ponteiro Categoria
		Ponteiro Cultivar
		Ponteiro Peneira
		Ponteiro cTratado
@author: AgroIndustria
@since: Agosto/2020
@return: empty
*/

static function fDadosLote(cLote, cProd, cUM, cCateg, cCtvar, cPene, cTratado)
	Local cQryNP9 := GetNextAlias()

	BeginSQL Alias cQryNP9

	SELECT NP9.NP9_LOTE, NP9.NP9_PROD, NP9.NP9_CODSAF, NP9.NP9_CULTRA, NP9.NP9_UM, NP9_CATEG, NP9.NP9_CTVAR, NP9.NP9_CTVDES, NP9.NP9_PENE, NP9.NP9_PENE, NP9_TRATO FROM %Table:NP9%  NP9
		WHERE NP9.%notDel%
			AND NP9.NP9_LOTE = %exp:cLote%
			AND NP9.NP9_PROD= %exp:cProd%
			AND NP9.NP9_FILIAL = %xFilial:NP9%
	EndSQL

	IF EMPTY( ( cQryNP9 )->NP9_LOTE ) // não encontrei o lote no produto do pedido. Indica que deve ser um Lote tratado
	                                  // Entao Busco por UM. que deve encontrar o lote em outro produto ( não tratado )
		( cQryNP9 )->( dBCloseArea() )

		cQryNP9 := GetNextAlias()
		 
		BeginSQL Alias cQryNP9
		 	SELECT NP9.NP9_LOTE, NP9.NP9_PROD, NP9.NP9_CODSAF, NP9.NP9_CULTRA, NP9.NP9_UM, NP9_CATEG, NP9.NP9_CTVAR, NP9.NP9_CTVDES, NP9.NP9_PENE, NP9.NP9_PENE, NP9_TRATO FROM %Table:NP9%  NP9
			WHERE NP9.%notDel%
				AND NP9.NP9_LOTE = %exp:cLote%
				AND NP9.NP9_UM= %exp:cUM%
				AND NP9.NP9_FILIAL = %xFilial:NP9%
		EndSQL

	EndIF

	//Abastecendo Vars Ponteiro com os dados do lote

	cCateg	:= ( cQryNP9 )->NP9_CATEG
	cCtvar	:= ( cQryNP9 )->NP9_CTVDES
	cPene	:= ( cQryNP9 )->NP9_PENE
	cTratado := 'NAO' 
	IF Alltrim( ( cQryNP9 )->NP9_TRATO) == '1'
	   cTratado := 'SIM' 
	EndIF

	( cQryNP9 )->( dBCloseArea() )

Return
