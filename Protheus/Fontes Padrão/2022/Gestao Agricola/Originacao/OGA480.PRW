#INCLUDE "OGA480.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*{Protheus.doc} OGA480
Substituição de titulos provisorios do contas a pagar referente a despesas
@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA480()

	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer   := Nil
	Local oPnTit	 := Nil
	Local oPnPrev	 := Nil
	Local nX         := 0
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//--- Definição da estrutura da tabela temporária de Titulos - NF ---//
	Local aEstruTit := { { "OK", "C", 2, 0 , , } , ;
						 { "T_FILIAL" , "C", TamSX3("E2_FILIAL" )[ 1 ], 0                      , RetTitle("E2_FILIAL" ), PesqPict("SE2","E2_FILIAL")},;
	 					 { "T_PREFIXO", "C", TamSX3("E2_PREFIXO")[ 1 ], 0                      , RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO")},;
	 					 { "T_NUM"    , "C", TamSX3("E2_NUM"    )[ 1 ], 0                      , RetTitle("E2_NUM"    ), PesqPict("SE2","E2_NUM")},;
						 { "T_PARCELA", "C", TamSX3("E2_PARCELA")[ 1 ], 0                      , RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA")},;
						 { "T_TIPO"   , "C", TamSX3("E2_TIPO"   )[ 1 ], 0                      , RetTitle("E2_TIPO"   ), PesqPict("SE2","E2_TIPO")},;						
						 { "T_FORNECE", "C", TamSX3("E2_FORNECE")[ 1 ], 0                      , RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE")},;						
						 { "T_LOJA"   , "C", TamSX3("E2_LOJA"   )[ 1 ], 0                      , RetTitle("E2_LOJA"   ), PesqPict("SE2","E2_LOJA")},;
						 { "T_NOMFOR" , "C", TamSX3("E2_NOMFOR" )[ 1 ], 0                      , RetTitle("E2_NOMFOR" ), PesqPict("SE2","E2_NOMFOR")},;
	                     { "T_EMISSAO", "D", 8                        , 0                      , RetTitle("E2_EMISSAO"), "@D"},;
	                     { "T_VENCTO" , "D", 8                        , 0                      , RetTitle("E2_VENCTO" ), "@D"},;  					
						 { "T_VALOR"  , "N", TamSX3("E2_VALOR"  )[ 1 ], TamSX3("E2_VALOR")[ 2 ], RetTitle("E2_VALOR"  ), PesqPict("SE2","E2_VALOR")},; 
						 { "T_SALDO"  , "N", TamSX3("E2_SALDO"  )[ 1 ], TamSX3("E2_SALDO")[ 2 ], RetTitle("E2_SALDO"  ), PesqPict("SE2","E2_SALDO")},;
						 { "T_MOEDA"  , "N", TamSX3("E2_MOEDA"  )[ 1 ], 0                      , RetTitle("E2_MOEDA"  ), PesqPict("SE2","E2_MOEDA")},;
						 { "T_CTROG"  , "C", TamSX3("E2_CTROG"  )[ 1 ], 0                      , RetTitle("E2_CTROG"  ), PesqPict("SE2","E2_CTROG")},;
						 { "T_CODSAF" , "C", TamSX3("E2_CODSAF" )[ 1 ], 0                      , RetTitle("E2_CODSAF" ), PesqPict("SE2","E2_CODSAF")},;
						 { "T_NATUREZ", "C", TamSX3("E2_NATUREZ")[ 1 ], 0                     , RetTitle("E2_NATUREZ" ), PesqPict("SE2","E2_NATUREZ")},; 
						 { "T_SLDSUB"  ,"N", TamSX3("E2_SALDO"  )[ 1 ], TamSX3("E2_SALDO")[ 2 ], "Saldo Subst"         , PesqPict("SE2","E2_SALDO")}  } 
						 
	Local aCpBrwTit := {}
	Local aIndTit   := { "T_FILIAL+T_PREFIXO+T_NUM+T_PARCELA+T_TIPO", "T_FILIAL+T_FORNECE+T_LOJA+T_PREFIXO+T_NUM+T_PARCELA+T_TIPO" } // Definição dos índices
	
	//--- Definição da estrutura da tabela temporária de Previsões ---//
	Local aEstruPrev := {{ "OK", "C", 2, 0 , , } , ;
	                     { "T_FILIAL" , "C", TamSX3("E2_FILIAL" )[ 1 ], 0                      , RetTitle("E2_FILIAL" ), PesqPict("SE2","E2_FILIAL")},;
	 					 { "T_PREFIXO", "C", TamSX3("E2_PREFIXO")[ 1 ], 0                      , RetTitle("E2_PREFIXO"), PesqPict("SE2","E2_PREFIXO")},;
	 					 { "T_NUM"    , "C", TamSX3("E2_NUM"    )[ 1 ], 0                      , RetTitle("E2_NUM"    ), PesqPict("SE2","E2_NUM")},;
						 { "T_PARCELA", "C", TamSX3("E2_PARCELA")[ 1 ], 0                      , RetTitle("E2_PARCELA"), PesqPict("SE2","E2_PARCELA")},;
						 { "T_TIPO"   , "C", TamSX3("E2_TIPO"   )[ 1 ], 0                      , RetTitle("E2_TIPO"   ), PesqPict("SE2","E2_TIPO")},;						
						 { "T_FORNECE", "C", TamSX3("E2_FORNECE")[ 1 ], 0                      , RetTitle("E2_FORNECE"), PesqPict("SE2","E2_FORNECE")},;						
						 { "T_LOJA"   , "C", TamSX3("E2_LOJA"   )[ 1 ], 0                      , RetTitle("E2_LOJA"   ), PesqPict("SE2","E2_LOJA")},;
						 { "T_NOMFOR" , "C", TamSX3("E2_NOMFOR" )[ 1 ], 0                      , RetTitle("E2_NOMFOR" ), PesqPict("SE2","E2_NOMFOR")},;
	                     { "T_EMISSAO", "D", 8                        , 0                      , RetTitle("E2_EMISSAO"), "@D"},;
	                     { "T_VENCTO" , "D", 8                        , 0                      , RetTitle("E2_VENCTO" ), "@D"},;  				
						 { "T_VALOR"  , "N", TamSX3("E2_VALOR"  )[ 1 ], TamSX3("E2_VALOR")[ 2 ], RetTitle("E2_VALOR"  ), PesqPict("SE2","E2_VALOR")},; 
						 { "T_SALDO"  , "N", TamSX3("E2_SALDO"  )[ 1 ], TamSX3("E2_SALDO")[ 2 ], RetTitle("E2_SALDO"  ), PesqPict("SE2","E2_SALDO")},;
						 { "T_MOEDA"  , "N", TamSX3("E2_MOEDA"  )[ 1 ], 0                      , RetTitle("E2_MOEDA"  ), PesqPict("SE2","E2_MOEDA")},;
						 { "T_CTROG"  , "C", TamSX3("E2_CTROG"  )[ 1 ], 0                      , RetTitle("E2_CTROG"  ), PesqPict("SE2","E2_CTROG")},;
						 { "T_CODSAF" , "C", TamSX3("E2_CODSAF" )[ 1 ], 0                      , RetTitle("E2_CODSAF" ), PesqPict("SE2","E2_CODSAF")},;
						 { "T_CODCOM" , "C", TamSX3("NN7_CODCOM")[ 1 ], 0                      , RetTitle("NN7_CODCOM"), PesqPict("NN7","NN7_CODCOM")},;
						 { "T_DESCOM" , "C", TamSX3("NN7_CODCOM")[ 1 ], 0                      , RetTitle("NN7_DESCOM"), PesqPict("NN7","NN7_DESCOM")} } 
						 
	Local aCpBrwPrev := {}
	Local aIndPrev   := { "T_FILIAL+T_PREFIXO+T_NUM+T_PARCELA+T_TIPO", "T_FILIAL+T_FORNECE+T_LOJA+T_PREFIXO+T_NUM+T_PARCELA+T_TIPO" } // Definição dos índices

	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasTit 
	Private cTrabTit 	 
	Private cAliasPrev 
	Private cTrabPrev
	Private oBrwTit 
	Private oBrwPrev
	Private aIndice1
	Private aIndice2
	Private cMarca 	:= GetMark()
	Private cNoFld 	:= "OK"
	Private cFiliDe := ''
	Private cFiliPa := ''
	Private cFornDe := ''
	Private cLojaDe := ''
	Private cFornPa := ''
	Private cLojaPa := ''
	Private cNatuDe := ''
	Private cNatuPa := ''
	Private cTipoDe := ''
	Private cTipoPa := ''
	Private nOpcao  := ''
	Private lMark   := .F.

	OGA480SX1()

	//--- Criação das tabelas temporárias ---//
	
	// Tabela temporária de Saldos
	aRetTRB := AGRCRIATRB( , aEstruTit, aIndTit, FunName(), .T. )
	 
	cTrabTit 	:= aRetTRB[3] //Nome do arquivo temporário 
	cAliasTit  	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwTit 	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndice1	:= AGRINDICONS(aIndTit , aCpBrwTit  )	
	
	// Tabela temporária de Contratos
	aRetTRB := AGRCRIATRB( , aEstruPrev, aIndPrev, FunName(), .T. )
	 
	cTrabPrev 	:= aRetTRB[3] //Nome do arquivo temporário 
	cAliasPrev 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwPrev	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndice2	:= AGRINDICONS(aIndPrev, aCpBrwPrev )
	
	//primeira carga na tabela
	OG480LDTIT()
	OG480LDPRE()
	
	//--- Montagem da tela ---//
	oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Apropriação de Titulos Provisórios Grãos

	//--- Layers ---//
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	// Saldos
	oFWLayer:AddLine( 'LinTitulo', 50, .F. )
	oFWLayer:AddCollumn( 'ColTitulo', 100, .T., 'LinTitulo' )
	oPnTit := oFWLayer:GetColPanel( 'ColTitulo', 'LinTitulo' )
	
	// Contratos
	oFWLayer:AddLine( 'LinPrevisao', 50, .F. )
	oFWLayer:AddCollumn( 'ColPrevisao', 100, .T., 'LinPrevisao' )
	oPnPrev := oFWLayer:GetColPanel( 'ColPrevisao', 'LinPrevisao' )
	
	//--- Conteúdo dos panels ---// 
	DEFINE FWFORMBROWSE oBrwTit DATA TABLE ALIAS cAliasTit DESCRIPTION STR0002 OF oPnTit //Títulos
	    oBrwTit:SetTemporary(.T.)
		oBrwTit:SetdbFFilter(.T.)
		oBrwTit:SetUseFilter(.T.)	
		oBrwTit:SetFieldFilter(AGRITEMCBRW(aCpBrwTit))	
		oBrwTit:SetSeek(,aIndice1)	
		
		ADD MARKCOLUMN oColumn DATA { || If(( cAliasTit )->OK == cMarca,'LBOK','LBNO') } ;
		DOUBLECLICK { |oBrwTit| OGA480CLK( cAliasTit , oBrwTit, '1', .f.) } ;
		HEADERCLICK { |oBrwTit| OGA480CLK( cAliasTit , oBrwTit, '1', .t.) } OF oBrwTit
		
		For nx := 1 To Len(aCpBrwTit)			
		    nTamCpoIDX	:= 1
		    If !(aCpBrwTit[nX,2] == "C")
		    	nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
		    EndIF
		    If !( aCpBrwPrev[nX,1] $ cNoFld )
				ADD COLUMN oColumn 	DATA 	&('{||'+aCpBrwTit[nX,1]+'}');
				 					Title	aCpBrwTit[nX,5];
				 					SIZE	aCpBrwTit[nX,3] * nTamCpoIDX;
				 					PICTURE	aCpBrwTit[nX,6];
				 					Align	IIf(aCpBrwTit[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
				 					Of oBrwTit		
			EndIf	
		Next nx 
		oBrwTit:bChange := {|| OGA480CHG() } 
		oBrwTit:DisableDetails()
	ACTIVATE FWFORMBROWSE oBrwTit

	DEFINE FWFORMBROWSE oBrwPrev DATA TABLE ALIAS cAliasPrev DESCRIPTION STR0003 OF oPnPrev //"Previsoes" 
	    oBrwPrev:SetTemporary(.T.)
		oBrwPrev:SetdbFFilter(.T.)
		oBrwPrev:SetUseFilter(.T.)
		oBrwPrev:SetSeek(,aIndice2)		
		oBrwPrev:SetFieldFilter(AGRITEMCBRW(aCpBrwPrev))	
				
		ADD MARKCOLUMN oColumn DATA { || If(( cAliasPrev )->OK == cMarca,'LBOK','LBNO') } ;
		DOUBLECLICK { |oBrwPrev| OGA480CLK( cAliasPrev , oBrwPrev, '2', .f.) } ;
		HEADERCLICK { |oBrwPrev| OGA480CLK( cAliasPrev , oBrwPrev, '2', .t.) } OF oBrwPrev	
						
		For nX := 1 To Len(aCpBrwPrev)
			
		    nTamCpoIDX	:= 1
		    If !(aCpBrwPrev[nX,2] == "C")   
		    	nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
		    EndIF
		    If !( aCpBrwPrev[nX,1] $ cNoFld )
				ADD COLUMN oColumn	DATA 	&('{||'+aCpBrwPrev[nX,1]+'}');
				 					Title 	aCpBrwPrev[nX,5];
				 					SIZE 	aCpBrwPrev[nX,3] * nTamCpoIDX;
				 					PICTURE aCpBrwPrev[nX,6];
				 					Align	IIf(aCpBrwPrev[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
				 					Of oBrwPrev
			EndIf
			
		Next nX
		oBrwPrev:DisableDetails()		
		oBrwPrev:AddButton(STR0004,	{|| oDlg:End() }	,,,,,,'31')	//"Sair"
		oBrwPrev:AddButton(STR0005,	{|| OGA480GRV('1') },,,,,,'33')	//"Substituir Previsão"
		oBrwPrev:AddButton(STR0006,	{|| OGA480GRV('2') },,,,,,'35')	//"Estornar Substituição"
		oBrwPrev:AddButton(STR0007,	{|| OGA480PER(  ) }	,,,,,,'37')	//"Parâmetros"
	
	ACTIVATE FWFORMBROWSE oBrwPrev

	oDlg:Activate( , , , .t., { || .t. }, , { || } )
	
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasTit, cTrabTit )  
	AGRDELETRB( cAliasPrev, cTrabPrev) 
Return()


/*{Protheus.doc} OGA480PER

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OGA480PER()
Local lOk

lOk := OGA480SX1()

If lOk	
	OG480LDTIT()
	DbselectArea( cAliasTit )
	DbGoTop()
	OG480LDPRE()
EndIf

Return

/*{Protheus.doc} OG480LDPRE

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OG480LDPRE()
	Local aAreaAtu	 := GetArea()
	Local cAliasQry	 := GetNextAlias()
	Local cQuery
	
	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	fZapTRB( cAliasPrev )
	
	//--- Query para trazer os Contratos ---//
	cAliasQry := GetNextAlias()
	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_NOMFOR, "
	cQuery += " E2_VENCTO, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CTROG, E2_CODSAF, E2_NATUREZ, NN7_CODCOM FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("NN7") + " NN7 "
	cQuery += "   ON NN7_FILIAL = '" + xFilial("NN7") + "'"
	cQuery += "  AND NN7_CODCTR = SE2.E2_CTROG "
	cQuery += "  AND NN7_PARCEL = SE2.E2_PARCELA "
	cQuery += "  AND NN7_CODCOM != ''"
	cQuery += "  AND NN7.D_E_L_E_T_ = '' "
	
	If nOpcao == 1 
		cQuery += " WHERE SE2.E2_FILIAL    >= '" + cFiliDe + "'"
		cQuery += "     AND SE2.E2_FILIAL  <= '" + cFiliPa + "'"
		cQuery += "     AND SE2.E2_FORNECE >= '" + cFornDe + "'"
		cQuery += "     AND SE2.E2_LOJA    >= '" + cLojaDe + "'"	
		cQuery += "     AND SE2.E2_FORNECE <= '" + cFornPa + "'"
		cQuery += "     AND SE2.E2_LOJA    <= '" + cLojaPa + "'"
		cQuery += "     AND SE2.E2_NATUREZ >= '" + cNatuDe + "'"
		cQuery += "     AND SE2.E2_NATUREZ <= '" + cNatuPa + "'"
		cQuery += "     AND SE2.E2_SALDO   <> 0 "
	Else
		cQuery +=  " INNER JOIN " + RetSqlName("NOB") + " NOB ON NOB.NOB_FILIAL 	= '" + (cAliasTit)->T_FILIAL + "'"
		cQuery += 	                                      " AND NOB.NOB_PREFIX 	= '" + (cAliasTit)->T_PREFIXO  + "'"
		cQuery += 	                                      " AND NOB.NOB_NUM 	= '" + (cAliasTit)->T_NUM  + "'"
		cQuery += 	                                      " AND NOB.NOB_PARCEL 	= '" + (cAliasTit)->T_PARCELA  + "'"
		cQuery += 	                                      " AND NOB.NOB_TIPO   	= '" + (cAliasTit)->T_TIPO  + "'"
	  	cQuery += 	                                      " AND NOB.NOB_FORNEC	= '" + (cAliasTit)->T_FORNECE  + "'"
	  	cQuery += 	                                      " AND NOB.NOB_LOJA	= '" + (cAliasTit)->T_LOJA  + "'"
	  	cQuery += 	                                      " AND NOB.NOB_PREFPR 	= SE2.E2_PREFIXO "
		cQuery += 	                                      " AND NOB.NOB_NUMPR 	= SE2.E2_NUM  "
		cQuery += 	                                      " AND NOB.NOB_PARCPR 	= SE2.E2_PARCELA "
		cQuery += 	                                      " AND NOB.NOB_TIPOPR 	= SE2.E2_TIPO "
	  	cQuery += 	                                      " AND NOB.D_E_L_E_T_ = '' "
	EndIF
	
	cQuery += "     AND SE2.E2_TIPO    = 'PR'" 
	cQuery += "     AND SE2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
	
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof()) 
			RecLock( cAliasPrev, .T. )
			    ( cAliasPrev )->T_FILIAL   := ( cAliasQry )->E2_FILIAL 
				( cAliasPrev )->T_PREFIXO  := ( cAliasQry )->E2_PREFIXO
				( cAliasPrev )->T_NUM      := ( cAliasQry )->E2_NUM    
				( cAliasPrev )->T_PARCELA  := ( cAliasQry )->E2_PARCELA
				( cAliasPrev )->T_TIPO     := ( cAliasQry )->E2_TIPO   
				( cAliasPrev )->T_FORNECE  := ( cAliasQry )->E2_FORNECE
				( cAliasPrev )->T_LOJA     := ( cAliasQry )->E2_LOJA    
				( cAliasPrev )->T_EMISSAO  := StoD(( cAliasQry )->E2_EMISSAO) 
				( cAliasPrev )->T_NOMFOR   := ( cAliasQry )->E2_NOMFOR 
				( cAliasPrev )->T_VENCTO   := StoD(( cAliasQry )->E2_VENCTO) 
				( cAliasPrev )->T_VALOR    := ( cAliasQry )->E2_VALOR  
				( cAliasPrev )->T_SALDO    := ( cAliasQry )->E2_SALDO  
				( cAliasPrev )->T_MOEDA    := ( cAliasQry )->E2_MOEDA  
			    ( cAliasPrev )->T_CTROG    := ( cAliasQry )->E2_CTROG  
			    ( cAliasPrev )->T_CODSAF   := ( cAliasQry )->E2_CODSAF
			    ( cAliasPrev )->T_CODCOM   := ( cAliasQry )->NN7_CODCOM
	    		( cAliasPrev )->T_DESCOM   := Posicione('NK7',1,xFilial('NK7')+( cAliasQry )->NN7_CODCOM,'NK7_DESCRI')                   					
			( cAliasPrev )->( MsUnLock() )
			
			( cAliasQry )->( DbSkip() )
		End
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If Type("oBrwPrev") <> "U"
		oBrwPrev:Refresh(.T.)
	EndIf
	
	RestArea( aAreaAtu )


Return()

/*{Protheus.doc} OG480LDTIT

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OG480LDTIT()
	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	local nVlNf := 0
	
	//-- Nenhum registro marcado --//
	lMark   := .F.
	
	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	fZapTRB( cAliasTit )
	
	//--- TITULOS DISPONIVEIS PARA SUSBTITUICAO ---//
	cAliasQry := GetNextAlias()
	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM,    E2_PARCELA, E2_TIPO,   E2_FORNECE, "
	cQuery +=        " E2_LOJA,   E2_EMISSAO, E2_NOMFOR, E2_VENCTO,  E2_VALOR,  E2_SALDO, "
	cQuery +=        " E2_MOEDA,  E2_CTROG,   E2_CODSAF, E2_NATUREZ "
	cQuery +=   " FROM " + RetSqlName("SE2") + " SE2 "
	//-- VERIFICA SE EXISTE VINCULO - CASO POSSUIR SALDO
	/*cQuery +=  " LEFT JOIN " + RetSqlName("NOB") + " NOB ON NOB.NOB_FILIAL 	= SE2.E2_FILIAL "
	cQuery += 	                                      " AND NOB.NOB_FORNEC 	= SE2.E2_FORNECE "
	cQuery += 	                                      " AND NOB.NOB_LOJA   	= SE2.E2_LOJA " 
  	cQuery += 	                                      " AND NOB.NOB_NUM		= SE2.E2_NUM "*/
	cQuery +=  " WHERE SE2.E2_FILIAL   >= '" + cFiliDe + "'"
	cQuery += "     AND SE2.E2_FILIAL  <= '" + cFiliPa + "'"
	cQuery += "     AND SE2.E2_FORNECE >= '" + cFornDe + "'"
	cQuery += "     AND SE2.E2_LOJA    >= '" + cLojaDe + "'"	
	cQuery += "     AND SE2.E2_FORNECE <= '" + cFornPa + "'"
	cQuery += "     AND SE2.E2_LOJA    <= '" + cLojaPa + "'"
	cQuery += "     AND SE2.E2_NATUREZ >= '" + cNatuDe + "'"
	cQuery += "     AND SE2.E2_NATUREZ <= '" + cNatuPa + "'"
	cQuery += "     AND SE2.E2_TIPO    >= '" + cTipoDe + "'"
	cQuery += "     AND SE2.E2_TIPO    <= '" + cTipoPa + "'"
	cQuery += "     AND SE2.E2_TIPO    <> 'PR'" 
	cQuery += 	 " AND SE2.E2_SALDO    > 0" 
	//cQuery += 	 " AND SE2.E2_TIPO    	= 'NF'" 
	cQuery += 	 " AND SE2.D_E_L_E_T_ 	= ' ' "	
	
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 

	
	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )
	
		nVlNf := 0
		dbSelectArea("NOB")
		NOB->( dbSetOrder(2) )
	    NOB->(dbseek((cAliasQry)->E2_FILIAL +(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA   ))
		While !NOB->( Eof()) .And. NOB->NOB_FILIAL+NOB->NOB_PREFIX+NOB->NOB_NUM+NOB->NOB_PARCEL+NOB->NOB_TIPO+NOB->NOB_FORNEC+NOB->NOB_LOJA == (cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA
		
			If NOB->NOB_FILIAL+NOB->NOB_PREFIX+NOB->NOB_NUM+NOB->NOB_PARCEL+NOB->NOB_TIPO+NOB->NOB_FORNEC+NOB->NOB_LOJA ==;
			  (cAliasQry)->E2_FILIAL +(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA   
				nVlNf += NOB->NOB_VALOR
			EndIf
			
			dbSelectArea("NOB")
			NOB->( dbSkip() )
		EndDo
		NOB->(dbCloseArea())
		
		If  ( (cAliasQry)->E2_SALDO > nVlNf .And. nOpcao == 1 ) .Or. (nVlNf <> 0 .And. nOpcao == 2 )
		
		RecLock( cAliasTit, .T. )
		    ( cAliasTit )->T_FILIAL   := ( cAliasQry )->E2_FILIAL 
			( cAliasTit )->T_PREFIXO  := ( cAliasQry )->E2_PREFIXO
			( cAliasTit )->T_NUM      := ( cAliasQry )->E2_NUM    
			( cAliasTit )->T_PARCELA  := ( cAliasQry )->E2_PARCELA
			( cAliasTit )->T_TIPO     := ( cAliasQry )->E2_TIPO   
			( cAliasTit )->T_FORNECE  := ( cAliasQry )->E2_FORNECE
			( cAliasTit )->T_LOJA     := ( cAliasQry )->E2_LOJA    
			( cAliasTit )->T_EMISSAO  := StoD(( cAliasQry )->E2_EMISSAO) 
			( cAliasTit )->T_NOMFOR   := ( cAliasQry )->E2_NOMFOR 
			( cAliasTit )->T_VENCTO   := StoD(( cAliasQry )->E2_VENCTO) 
			( cAliasTit )->T_VALOR    := ( cAliasQry )->E2_VALOR  
			( cAliasTit )->T_SALDO    := ( cAliasQry )->E2_SALDO  
			( cAliasTit )->T_MOEDA    := ( cAliasQry )->E2_MOEDA  
		    ( cAliasTit )->T_CTROG    := ( cAliasQry )->E2_CTROG  
		    ( cAliasTit )->T_CODSAF   := ( cAliasQry )->E2_CODSAF 					
		    ( cAliasTit )->T_NATUREZ  := ( cAliasQry )->E2_NATUREZ
		    ( cAliasTit )->T_SLDSUB   := ( cAliasQry )->E2_SALDO - nVlNf
		( cAliasTit )->( MsUnLock() )
		
		EndIf
		
		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
	If Type("oBrwTit") <> "U"
		oBrwTit:Refresh(.T.)
	EndIf
	
	RestArea( aAreaAtu )

Return()


/*{Protheus.doc} fZapTRB

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function fZapTRB( pcAliasTRB )
    Local aAreaAtu         := GetArea()
    
    If Select( pcAliasTRB ) > 0
        DbSelectArea( pcAliasTRB )
        Zap
    Endif
    
    RestArea( aAreaAtu )
Return( NIL )

/*{Protheus.doc} OGA480CLK

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OGA480CLK( pcAliasTRB, pOBrw, nBrw, lTudoOk  )

	dbSelectArea(pcAliasTRB)
	nRecnoTrb := (pcAliasTRB)->(Recno())
	If lTudoOk
		dbGoTop()
	EndIf
	If !(pcAliasTRB)->( Eof() )
		While !(pcAliasTRB)->( Eof() )
			if nOpcao == 1 .Or. nBrw == '2'.Or. !lMark .Or. (pcAliasTRB)->OK=cMarca	
				RecLock(pcAliasTRB, .F.)
				(pcAliasTRB)->OK := IIf((pcAliasTRB)->OK=cMarca,' ',cMarca)
				MsUnlock(pcAliasTRB)
				If nOpcao == 2 .And. nBrw == '1'
					lMark := IIf((pcAliasTRB)->OK=cMarca,.T.,.F.)
				EndIf
			Else
				MsgInfo(STR0008) //"Selecione apenas um Título para realizar a operação de Estorno."
			EndIf
			If lTudoOk
				(pcAliasTRB)->( DbSkip() )
			Else
				Exit
			EndIf
		End
	EndIf
	(pcAliasTRB)->(dbGoTo(nRecnoTrb))
	pOBrw:Refresh()
				
Return

/*{Protheus.doc} OGA480CHG

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OGA480CHG(   )
	
	//Só atualiza os registros se estiver mostrando os títulos com vínculo
	If nOpcao == 2
		OG480LDPRE()
	EndIf
			
Return

/*{Protheus.doc} OGA480GRV

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
static function OGA480GRV(cAcao)

	Local cFornec := ''
	Local lRet := .t.
	Private lBaixa := .F.
	Private nContTit := 0

	If cAcao == '1' .And. nOpcao == 2 /*Substituir previsao*/
		MsgInfo(STR0009) //"Para Substituir Previsão, selecione a opção 'Situação Disponível' nos parâmetros"
		Return .F.
	EndIf
	
	If cAcao == '2' .And. nOpcao == 1 /*Substituir previsao*/
		MsgInfo(STR0010) //"Para Estornar Substituição, selecione o opção 'Situação Vinculado Prev' nos parâmetros"
		Return .F.
	EndIf
	
	//Validar se os títulos selecionados são do mesmo fornecedor
	ARGSETIFARQUI(cAliasTit)
	While !(cAliasTit)->(Eof()) 
		If (cAliasTit)->OK = cMarca 
				
			If Empty(cFornec)
				cFornec := (cAliasTit)->T_FORNECE
			Else
				If cFornec <> (cAliasTit)->T_FORNECE
					MsgInfo(STR0011) //"Todos os títulos selecionados devem pertencer ao mesmo fornecedor"
					//(cAliasTit)->(dbGoTo(nRecnoTit))
					Return .F.
				EndIf
			 EndIf
        EndIF
		//Retoma a área e vai para o próximo registro
		( cAliasTit )->( DbSkip() )
	EndDo
	//(cAliasTit)->(dbGoTo(nRecnoTit))
		
	ARGSETIFARQUI(cAliasPrev)
	While !(cAliasPrev)->(Eof()) 
		If (cAliasPrev)->OK = cMarca 

			If cFornec <> (cAliasPrev)->T_FORNECE
				MsgInfo(STR0012) //"Todos os títulos selecionados devem pertencer ao mesmo fornecedor"
				//(cAliasPrev)->(dbGoTo(nRecnoPrev))
				Return .F.
			EndIf
			 
        EndIF
		//Retoma a área e vai para o próximo registro
		( cAliasPrev )->( DbSkip() )
	EndDo
	//(cAliasPrev)->(dbGoTo(nRecnoPrev))
			
	BEGIN TRANSACTION

		ARGSETIFARQUI(cAliasTit)
		While !(cAliasTit)->(Eof()) .AND. lRet 
			If (cAliasTit)->OK = cMarca 
		       
		        If cAcao == '1'
		        	lRet := OGA480ATUF()  // Atualiza Previsão financeira
	        	Else
	        		nContTit++
	        		lRet := OGA480DESF()  // Desatualiza Previsão financeira
	        	EndIF
	        EndIF
			
			//Retoma a área e vai para o próximo registro
			( cAliasTit )->( DbSkip() )
		EndDo
	END TRANSACTION		
	
	If nContTit > 0
		OG480LDTIT()
		OG480LDPRE()
	EndIf
	
	
return lRet

/*{Protheus.doc} OGA480ATUF

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA480ATUF()
	Local cSafra     := ""
	Local nSldNF     := 0
	Local nVlBaixNF  := 0
	Local nContPrev  := 0
	Local lNaoTodos  := .f.
	Local lMVSALDPRE := SuperGetMv("MV_SALDPRE", .F. , .F.)

	//Quanto do valor da NF já foi utilizado para abater outros títulos
	dbSelectArea("NOB")
	NOB->( dbSetOrder(1) )
    NOB->(dbseek((cAliasTit)->T_FILIAL+(cAliasTit)->T_PREFIXO+(cAliasTit)->T_NUM+(cAliasTit)->T_PARCELA+(cAliasTit)->T_TIPO+(cAliasTit)->T_FORNECE+(cAliasTit)->T_LOJA   ))
	While !NOB->( Eof()) .And. NOB->NOB_FILIAL+NOB->NOB_PREFIX+NOB->NOB_NUM+NOB->NOB_PARCEL+NOB->NOB_TIPO+NOB->NOB_FORNEC+NOB->NOB_LOJA == (cAliasTit)->T_FILIAL+(cAliasTit)->T_PREFIXO+(cAliasTit)->T_NUM+(cAliasTit)->T_PARCELA+(cAliasTit)->T_TIPO+(cAliasTit)->T_FORNECE+(cAliasTit)->T_LOJA
	
		If NOB->NOB_FILIAL+NOB->NOB_PREFIX+NOB->NOB_NUM+NOB->NOB_PARCEL+NOB->NOB_TIPO+NOB->NOB_FORNEC+NOB->NOB_LOJA ==;
		  (cAliasTit)->T_FILIAL+(cAliasTit)->T_PREFIXO+(cAliasTit)->T_NUM+(cAliasTit)->T_PARCELA+(cAliasTit)->T_TIPO+(cAliasTit)->T_FORNECE+(cAliasTit)->T_LOJA
		  nVlBaixNF += NOB->NOB_VALOR
		EndIf
		
		dbSelectArea("NOB")
		NOB->( dbSkip() )
	EndDo
	NOB->(dbCloseArea())
	
	//Saldo Valor NF
	nSldNF := ( cAliasTit )->T_SALDO - nVlBaixNF
	
	
	If nSldNF <= 0
		MsgInfo(STR0015) //"Título não possui saldo suficiente para Substituir Previsão"
		Return .F.
	EndIf
	
	ARGSETIFARQUI(cAliasPrev)
	While !(cAliasPrev)->(Eof()) 
		If (cAliasPrev)->OK = cMarca .And. nSldNF > 0 //Enquanto houver saldo na nota fiscal
		
			nContPrev++
	   	
			// Atualiza Previsão financeira
	        dbselectArea("SE2")
			dbSetOrder(1)		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If dbSeek( xFilial("SE2") + (cAliasPrev)->T_PREFIXO + (cAliasPrev)->T_NUM +(cAliasPrev)->T_PARCELA ); 
			.And. SE2->E2_FORNECE = (cAliasPrev)->T_FORNECE .AND. SE2->E2_LOJA = (cAliasPrev)->T_LOJA
										
				If nSldNF >= SE2->(E2_VALOR) .Or. lMVSALDPRE 
					
					cSafra := SE2->E2_CODSAF
					
					DbSelectArea("NOB")
					DbSetOrder(1)
					If !DbSeek( xFilial( "NOB" ) +	(cAliasTit)->T_PREFIXO + (cAliasTit)->T_NUM + ;
							   	(cAliasTit)->T_PARCELA + (cAliasTit)->T_TIPO + (cAliasTit)->T_FORNECE+;
							   	(cAliasTit)->T_LOJA + (cAliasPrev)->T_PREFIXO + (cAliasPrev)->T_NUM+;
								(cAliasPrev)->T_PARCELA + (cAliasPrev)->T_TIPO )
					
							RecLock( "NOB" , .T. )
						        NOB->NOB_FILIAL := ( cAliasTit )->T_FILIAL 
						        NOB->NOB_PREFIX := ( cAliasTit )->T_PREFIXO
						        NOB->NOB_NUM    := ( cAliasTit )->T_NUM 
						        NOB->NOB_PARCEL := ( cAliasTit )->T_PARCELA 
						        NOB->NOB_TIPO   := ( cAliasTit )->T_TIPO 
						        NOB->NOB_FORNEC := ( cAliasTit )->T_FORNECE 
						        NOB->NOB_LOJA   := ( cAliasTit )->T_LOJA
						        NOB->NOB_PREFPR := ( cAliasPrev )->T_PREFIXO
						        NOB->NOB_NUMPR  := ( cAliasPrev )->T_NUM    
						        NOB->NOB_PARCPR := ( cAliasPrev )->T_PARCELA
						        NOB->NOB_TIPOPR := ( cAliasPrev )->T_TIPO   
					        NOB->(MsUnlock())
					       
					EndIf  //If !DbSeek NOB
				EndIF //If nSldNF >= SE2->(E2_VALOR) .Or. SuperGetMv("MV_SALDPRE", .F. , .F.) 
				
				If nSldNF >= SE2->(E2_VALOR)
					 
					lBaixa := .T.
					
					nSldNF -= SE2->(E2_VALOR)
					NOB->( RecLock( "NOB", .f. ) )
						NOB->NOB_VALOR := SE2->(E2_VALOR)
					NOB->( msUnlock() )
					        
					SE2->( RecLock( "SE2", .f. ) )
						SE2->(E2_VALOR) := 0
						SE2->(E2_SALDO) := 0 
					SE2->( msUnlock() )
					
					//Desmarca para que o título não seja usado por outras notas
			        RecLock(cAliasPrev, .F.)
			        	(cAliasPrev)->OK := ' '
					MsUnlock(cAliasPrev)

					nContTit++
							
				Else

					If lMVSALDPRE 
						
						lBaixa := .T.
						
						NOB->( RecLock( "NOB", .f. ) )
							NOB->NOB_VALOR := nSldNF
						NOB->( msUnlock() )
																			
						SE2->( RecLock( "SE2", .f. ) )
							SE2->(E2_VALOR) -= nSldNF
							SE2->(E2_SALDO) -= nSldNF
						SE2->( msUnlock() )

						nContTit++
					Else
						lNaoTodos := .t.
					EndIF
		
					//nSldNF := 0
				EndIf //If nSldNF >= SE2->(E2_VALOR) 		
			EndIf	//SE2
		EndIf
		( cAliasPrev )->( DbSkip() )
	EndDo
	
	If nContPrev == 0
		MsgInfo(STR0014) //"Nenhum título de previsão selecionado"
		Return .F.
	EndIf
	
	If lNaoTodos
		MsgInfo(STR0017) //"O saldo do Título não foi suficiente para substituir todas as Previsões selecionadas !"
		Return .F.	
	EndIf
			
	//--Atualiza novo titulo
	dbselectArea("SE2")
	dbSetOrder(1)		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If dbSeek( xFilial( "SE2" ) + ( cAliasTit )->T_PREFIXO + ( cAliasTit )->T_NUM +( cAliasTit )->T_PARCELA )
		If SE2->E2_FORNECE = (cAliasTit)->T_FORNECE .AND. SE2->E2_LOJA = (cAliasTit)->T_LOJA
			SE2->( RecLock( "SE2", .f. ) )
				SE2->E2_HIST	:= STR0016 //"Tit.PR CTR COMPLEMENTO"
				SE2->E2_CTROG	:= (cAliasPrev)->T_NUM
				SE2->E2_CODSAF 	:= cSafra
			SE2->( msUnlock() )	
		EndIf
	EndIf 	//SE2
Return( .t. )


/*{Protheus.doc} OGA480DESF

@author 	Tamyris Ganzenmueller
@since 		27/01/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA480DESF()

	Local nContPrev := 0
			
	ARGSETIFARQUI(cAliasPrev)
	While !(cAliasPrev)->(Eof()) 
		If (cAliasPrev)->OK = cMarca 
		
			nContPrev++
			   	
			// Desatualiza Previsão financeira
	        dbselectArea("SE2")
			dbSetOrder(1)		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If dbSeek( xFilial("SE2") + (cAliasPrev)->T_PREFIXO + (cAliasPrev)->T_NUM +(cAliasPrev)->T_PARCELA ); 
			.And. SE2->E2_FORNECE = (cAliasPrev)->T_FORNECE .AND. SE2->E2_LOJA = (cAliasPrev)->T_LOJA
											
				DbSelectArea("NOB")
				DbSetOrder(3)
				//NOB_FILIAL+NOB_FORNEC+NOB_LOJA+NOB_PREFPR+NOB_NUMPR+NOB_PARCPR+NOB_TIPOPR    
				If NOB->(DbSeek((cAliasPrev)->T_FILIAL+(cAliasPrev)->T_FORNECE+(cAliasPrev)->T_LOJA+(cAliasPrev)->T_PREFIXO+(cAliasPrev)->T_NUM+(cAliasPrev)->T_PARCELA+(cAliasPrev)->T_TIPO  ))
								
						RecLock( "SE2" , .F. )
							SE2->(E2_VALOR) += NOB->NOB_VALOR
							SE2->(E2_SALDO) += NOB->NOB_VALOR
						SE2->(MsUnlock())
					
						RecLock( "NOB" , .F. )
					        dbDelete()   
				        NOB->(MsUnlock())
				       
				EndIf  //If !DbSeek NOB
			EndIF //SE2
			SE2->(dbCloseArea())
		EndIf
		( cAliasPrev )->( DbSkip() )
	EndDo
	
	If nContPrev == 0
		MsgInfo(STR0014) //"Nenhum título de previsão selecionado"
		Return .F.
	EndIf
	
	//--Atualiza novo titulo
	dbselectArea("SE2")
	dbSetOrder(1)		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If dbSeek( xFilial( "SE2" ) + ( cAliasTit )->T_PREFIXO + ( cAliasTit )->T_NUM +( cAliasTit )->T_PARCELA )
		If SE2->E2_FORNECE = (cAliasTit)->T_FORNECE .AND. SE2->E2_LOJA = (cAliasTit)->T_LOJA
			SE2->( RecLock( "SE2", .f. ) )
				SE2->E2_HIST	:= ''
				SE2->E2_CTROG	:= ''
			SE2->( msUnlock() )	
		EndIf
	EndIf 	//SE2
Return( .t. )

/*{Protheus.doc} OGA480SX1

@author 	Marcos Wagner Jr.
@since 		13/02/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OGA480SX1()
	Local lRet
	
	lRet := Pergunte( "OGA480", .T. )	

	cFiliDe := Alltrim(mv_par01)
	cFiliPa := Alltrim(mv_par02)
	If Empty(cFiliPa)
		cFiliPa := Replicate("Z",TamSx3("E2_FILIAL")[1])
	EndIf
	cFornDe := Alltrim(mv_par03)
	cLojaDe := Alltrim(mv_par04)
	cFornPa := Alltrim(mv_par05)
	If Empty(cFornPa)
		cFornPa := Replicate("Z",TamSx3("E2_FORNECE")[1])
	EndIf
	cLojaPa := Alltrim(mv_par06)
	If Empty(cLojaPa)
		cLojaPa := Replicate("Z",TamSx3("E2_LOJA")[1])
	EndIf
	cNatuDe := Alltrim(mv_par07)
	cNatuPa := Alltrim(mv_par08)
	If Empty(cNatuPa)
		cNatuPa := Replicate("Z",TamSx3("E2_NATUREZ")[1])
	EndIf
	cTipoDe := Alltrim(mv_par09)
	cTipoPa := Alltrim(mv_par10)
	If Empty(cTipoPa)
		cTipoPa := Replicate("Z",TamSx3("E2_TIPO")[1])
	EndIf
	nOpcao  := mv_par11

Return lRet
