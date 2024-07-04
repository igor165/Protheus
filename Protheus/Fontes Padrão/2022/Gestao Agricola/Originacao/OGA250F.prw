#INCLUDE "OGA250F.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*---------------------------------------------------------------------
{Protheus.doc} OGA250F
Função inicial para registrar as informação na NF do Cliente nas Operações de Venda a Ordem
@author thiago.rover
@since 19/04/2018
@version undefined
@param parm1 - Código do Romaneio
@type function
---------------------------------------------------------------------*/
Function OGA250F(parm1, parm2)
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer   := Nil
	Local oPnCad	 := Nil
	Local lRet       := .F.
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//--- Definição da estrutura da tabela temporária ---//
	Local aEstruNJM := { { "T_FILIAL" , "C", TamSX3("NJM_FILIAL")[ 1 ], 0  , RetTitle("NJM_FILIAL"), PesqPict("NJM","NJM_FILIAL")},;
                         { "T_CODROM" , "C", TamSX3("NJM_CODROM")[ 1 ], 0  , RetTitle("NJM_CODROM"), PesqPict("NJM","NJM_CODROM")},;
                         { "T_ITEROM" , "C", TamSX3("NJM_ITEROM")[ 1 ], 0  , RetTitle("NJM_ITEROM"), PesqPict("NJM","NJM_ITEROM")},;
						 { "T_DOCNUM" , "C", TamSX3("NJM_DOCNUM")[ 1 ], 0  , RetTitle("NJM_DOCNUM"), PesqPict("NJM","NJM_DOCNUM")},;
						 { "T_DOCSER" , "C", TamSX3("NJM_DOCSER")[ 1 ], 0  , RetTitle("NJM_DOCSER"), PesqPict("NJM","NJM_DOCSER")},;
						 { "T_DOCESP" , "C", TamSX3("NJM_DOCESP")[ 1 ], 0  , RetTitle("NJM_DOCESP"), PesqPict("NJM","NJM_DOCESP")},;
						 { "T_CODCLI" , "C", TamSX3("N8J_CLIFOR")[ 1 ], 0  , RetTitle("N8J_CLIFOR"), PesqPict("N8J","N8J_CLIFOR")},;
						 { "T_LOJCLI" , "C", TamSX3("N8J_LOJA")[ 1 ]  , 0  , RetTitle("N8J_LOJA")  , PesqPict("N8J","N8J_LOJA")}  ,;
						 { "T_DOCREF" , "C", TamSX3("N8J_DOCREF")[ 1 ], 0  , RetTitle("N8J_DOCREF"), PesqPict("N8J","N8J_DOCREF")},;
	 					 { "T_SERREF" , "C", TamSX3("N8J_SERREF")[ 1 ], 0  , RetTitle("N8J_SERREF"), PesqPict("N8J","N8J_SERREF")},;						
						 { "T_DTEREF" , "D", 8                        , 0  , RetTitle("N8J_DTEREF"), "@D"                        },;
						 { "T_CLIREF" , "C", TamSX3("N8J_CLIREF")[ 1 ], 0  , RetTitle("N8J_CLIREF"), PesqPict("N8J","N8J_CLIREF")},;
						 { "T_LOJREF" , "C", TamSX3("N8J_LOJREF")[ 1 ], 0  , RetTitle("N8J_LOJREF"), PesqPict("N8J","N8J_LOJREF")},;
						 { "T_CODINE" , "C", TamSX3("NJM_CODINE")[ 1 ], 0  , RetTitle("NJM_CODINE"), PesqPict("NJM","NJM_CODINE")},;
						 { "T_CODCTR" , "C", TamSX3("NJM_CODCTR")[ 1 ], 0  , RetTitle("NJM_CODCTR"), PesqPict("NJM","NJM_CODCTR")},;
						 { "T_ITECTR" , "C", TamSX3("NJM_ITEM")[ 1 ]  , 0  , RetTitle("NJM_ITEM")  , PesqPict("NJM","NJM_ITEM")  },;
						 { "T_ITEREF" , "C", TamSX3("NJM_SEQPRI")[ 1 ], 0  , RetTitle("NJM_SEQPRI"), PesqPict("NJM","NJM_SEQPRI")}}
						 	 
	Local aCpBrwNJM := {}
	Local aIndNJM   := { "T_FILIAL+T_CODROM+T_ITEROM" } // Definição dos índices
	Local cTrabNJM 	:= "" 
	Local aIndice1 := {}
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private _cAliasNJM	:= "" 	
	Private _oBrwNJM   := NIL	
	Private _cCodRom   := parm1
	//Private _cCodctr   := parm2
	Private _aHeader   := {}
	
	SetKey(VK_F5,{|| OG250F()}) 
		
	//--- Criação das tabelas temporárias ---//
	aRetTRB := AGRCRIATRB( , aEstruNJM, aIndNJM, FunName(), .T. )
	 
	cTrabNJM 	:= aRetTRB[3] //Nome do arquivo temporário 
	_cAliasNJM  := aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwNJM 	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture
	
	aIndice1	:= AGRINDICONS(aIndNJM , aCpBrwNJM  )	
	
	//--- Montagem da tela ---//
	oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Informações Documento Referência" 
	
	//--- Layers ---//
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'LinTitulo', 100, .F. )
	oFWLayer:AddCollumn( 'ColTitulo', 100, .T., 'LinTitulo' )
	oPnCad := oFWLayer:GetColPanel( 'ColTitulo', 'LinTitulo' )
		
	//Primeira carga na tabela
	lRet := OG250F(oDlg)	
	 
	If lRet 
	
		Help(" ", 1, ".OGA250F00001.")
		 
	Else
				//--- Conteúdo do panel ---// 
		DEFINE FWFORMBROWSE _oBrwNJM DATA TABLE ALIAS _cAliasNJM DESCRIPTION STR0001 OF oPnCad //"Informações Documento Referência"
		    _oBrwNJM:SetTemporary(.T.)
			_oBrwNJM:SetdbFFilter(.T.)
			_oBrwNJM:SetUseFilter(.T.)
			_oBrwNJM:SetFieldFilter(AGRITEMCBRW(aCpBrwNJM))	
			_oBrwNJM:Acolumns:= {}
			_oBrwNJM:setcolumns( _aHeader )
			_oBrwNJM:SetEditCell( .T. , {|| }) // Permite edição na grid
			_oBrwNJM:acolumns[9]:SetEdit(.T.)
			_oBrwNJM:acolumns[9]:SetReadVar('T_DOCREF')
			_oBrwNJM:acolumns[10]:SetEdit(.T.)
			_oBrwNJM:acolumns[10]:SetReadVar('T_SERREF')
			_oBrwNJM:acolumns[11]:SetEdit(.T.)
			_oBrwNJM:acolumns[11]:SetReadVar('T_DTEREF')
			
			_oBrwNJM:SetSeek(,aIndice1)	
			
			_oBrwNJM:DisableDetails()		
			_oBrwNJM:AddButton(STR0002 ,	{|| oDlg:End() }	,,,,,,'31')	//"Sair"
			_oBrwNJM:AddButton(STR0003 ,	{|| OGA250FGRV(oDlg) },,,,,,'33') //"Confirmar"
			
		ACTIVATE FWFORMBROWSE _oBrwNJM
	
		oDlg:Activate( , , , .t., { || .t. }, , { || } )
		
		//--- Apaga as tabelas temporárias ---//
		AGRDELETRB( _cAliasNJM, cTrabNJM )  
	EndIf
	 
Return()


/*---------------------------------------------------------------------
{Protheus.doc} OG250F
Função que carrega os dados na tela
@author thiago.rover
@since 19/04/2018
@version undefined
@type function
---------------------------------------------------------------------*/
Static Function OG250F(oDlg)
	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cAliQryREF:= GetNextAlias()
	Local lRet      := .f.
	
	//--- Apaga conteúdo anterior da tabela temporária ---//
	fZapTRB( _cAliasNJM )
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT NJM_FILIAL,NJM_CODROM,NJM_DOCNUM, NJM_DOCSER, NJM_DOCESP, NJM_CODENT,NJM_LOJENT, "
	cQuery += " N8J_DOCREF,N8J_SERREF,N8J_DTEREF, N8J_CLIFOR, N8J_LOJA , MIN(NJM_ITEROM) as NJM_ITEROM, "
	cQuery += " NJM_CODINE,NJM_CODCTR,NJM_ITEM, NJM_SEQPRI"
	cQuery += " FROM " + RetSqlName("NJM") + " NJM"
	cQuery += " INNER JOIN " + RetSqlName("NJ0") + " NJ0 "
	cQuery += " ON (NJ0.NJ0_FILIAL = '"+ xFilial("NJ0") +"'"
	cQuery += "     AND NJ0.NJ0_CODENT = NJM.NJM_CODENT "
	cQuery += "     AND NJ0.NJ0_LOJENT = NJM.NJM_LOJENT  "
	cQuery += "     AND NJ0.D_E_L_E_T_ = '' )"
	cQuery += " INNER JOIN " + RetSqlName("N8J") + " N8J "
	cQuery += " ON (N8J.N8J_FILIAL = NJM.NJM_FILIAL " 
	cQuery += "     AND N8J.N8J_DOC = NJM.NJM_DOCNUM    "
	cQuery += "     AND N8J.N8J_SERIE = NJM.NJM_DOCSER  "
	cQuery += "     AND N8J.N8J_CLIFOR = NJ0.NJ0_CODCLI "
	cQuery += "     AND N8J.N8J_LOJA = NJ0.NJ0_LOJCLI  "
	cQuery += "     AND N8J.N8J_CODROM = NJM.NJM_CODROM  "
	cQuery += "     AND N8J.D_E_L_E_T_ = '' )"
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	cQuery += " ON (SF2.F2_FILIAL = NJM.NJM_FILIAL " 
	cQuery += "     AND SF2.F2_DOC = NJM.NJM_DOCNUM    "
	cQuery += "     AND SF2.F2_SERIE = NJM.NJM_DOCSER  "
	cQuery += "     AND SF2.F2_CLIENTE = NJ0.NJ0_CODCLI "
	cQuery += "     AND SF2.F2_LOJA = NJ0.NJ0_LOJCLI  "
	cQuery += "     AND SF2.D_E_L_E_T_ = '' "
	cQuery += "     AND SF2.F2_FIMP = ' ' )"  //Somente Notas que ainda não tenham sido integradas com SEFAZ
	cQuery += " INNER JOIN " + RetSqlName("NJJ") + " NJJ "
	cQuery += " ON (NJJ.NJJ_FILIAL = NJM.NJM_FILIAL " 
	cQuery += "     AND NJJ.NJJ_CODROM = NJM.NJM_CODROM "
	cQuery += "     AND NJJ.D_E_L_E_T_ = '' "
	cQuery += "     AND NJJ.NJJ_STATUS = '3') "  //Somente Romaneios Confirmados
	cQuery += " WHERE NJM_FILIAL = '"+ xFilial("NJM")+"'"
	cQuery += " AND NJM_CODROM = '"+_cCodRom+"'"
	cQuery += " AND NJM_SUBTIP = '46'" //Somente Romaneios do Tipo Remessa de Venda a Ordem
	cQuery += " AND NJM.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY NJM_FILIAL,NJM_CODROM,NJM_DOCNUM, NJM_DOCSER, NJM_DOCESP, NJM_CODENT,NJM_LOJENT,N8J_DOCREF, "
	cQuery += " N8J_SERREF,N8J_DTEREF,N8J_CLIFOR, N8J_LOJA, NJM_CODINE, NJM_CODCTR, NJM_ITEM, NJM_SEQPRI "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
	
	aAdd(_aHeader, {"Filial"  ,{||( _cAliasNJM )->T_FILIAL}  , 'C' ,PesqPict("NJM","NJM_FILIAL"), 1 ,TamSX3("NJM_FILIAL")[1] ,TamSX3("NJM_FILIAL")[2] ,.F.})
	aAdd(_aHeader, {"Cod. Rom",{||( _cAliasNJM )->T_CODROM}  , 'C' ,PesqPict("NJM","NJM_CODROM"), 1 ,TamSX3("NJM_CODROM")[1] ,TamSX3("NJM_CODROM")[2] ,.F.})
	aAdd(_aHeader, {"Item Rom",{||( _cAliasNJM )->T_ITEROM}  , 'C' ,PesqPict("NJM","NJM_ITEROM"), 1 ,TamSX3("NJM_ITEROM")[1] ,TamSX3("NJM_ITEROM")[2] ,.F.})
	aAdd(_aHeader, {"Cod. Cli",{||( _cAliasNJM )->T_CODCLI}  , 'C' ,PesqPict("N8J","N8J_CLIFOR"), 1 ,TamSX3("N8J_CLIFOR")[1] ,TamSX3("N8J_CLIFOR")[2] ,.F.})
	aAdd(_aHeader, {"Loja Cli",{||( _cAliasNJM )->T_LOJCLI}  , 'C' ,PesqPict("N8J","N8J_LOJA"  ), 1 ,TamSX3("N8J_LOJA"  )[1] ,TamSX3("N8J_LOJA"  )[2] ,.F.})
	aAdd(_aHeader, {"Doc. Num",{||( _cAliasNJM )->T_DOCNUM}  , 'C' ,PesqPict("NJM","NJM_DOCNUM"), 1 ,TamSX3("NJM_DOCNUM")[1] ,TamSX3("NJM_DOCNUM")[2] ,.F.})
	aAdd(_aHeader, {"Doc. Ser",{||( _cAliasNJM )->T_DOCSER}  , 'C' ,PesqPict("NJM","NJM_DOCSER"), 1 ,TamSX3("NJM_DOCSER")[1] ,TamSX3("NJM_DOCSER")[2] ,.F.})
	aAdd(_aHeader, {"Doc. Esp",{||( _cAliasNJM )->T_DOCESP}  , 'C' ,PesqPict("NJM","NJM_DOCESP"), 1 ,TamSX3("NJM_DOCESP")[1] ,TamSX3("NJM_DOCESP")[2] ,.F.})
	aAdd(_aHeader, {"Doc. Ref",{||( _cAliasNJM )->T_DOCREF}  , 'C' ,PesqPict("N8J","N8J_DOCREF"), 1 ,TamSX3("N8J_DOCREF")[1] ,TamSX3("N8J_DOCREF")[2] ,.F.})
	aAdd(_aHeader, {"Ser. Ref",{||( _cAliasNJM )->T_SERREF}  , 'C' ,PesqPict("N8J","N8J_SERREF"), 1 ,TamSX3("N8J_SERREF")[1] ,TamSX3("N8J_SERREF")[2] ,.F.})
	aAdd(_aHeader, {"Data Ref",{||( _cAliasNJM )->T_DTEREF}  , 'D' ,"@D"                        , 1 ,8                       ,8                       ,.F.})
	aAdd(_aHeader, {"Cli. Ref",{||( _cAliasNJM )->T_CLIREF}  , 'C' ,PesqPict("N8J","N8J_CLIREF"), 1 ,TamSX3("N8J_CLIREF")[1] ,TamSX3("N8J_CLIREF")[2] ,.F.})
	aAdd(_aHeader, {"Loja Ref",{||( _cAliasNJM )->T_LOJREF}  , 'C' ,PesqPict("N8J","N8J_LOJREF"), 1 ,TamSX3("N8J_LOJREF")[1] ,TamSX3("N8J_LOJREF")[2] ,.F.})
	
	If (cAliasQry)->( Eof())
		lRet := .t.
	Else
		
		While ( cAliasQry )->( !Eof() )

			cAliQryREF := GetNextAlias()
			cQuery1 := " SELECT NJM_FILIAL,NJM_CODROM, NJM_CODENT,NJM_LOJENT, NJ0_CODCLI, NJ0_LOJCLI"
			cQuery1 += " FROM " + RetSqlName("NJM") + " NJM"
			cQuery1 += " INNER JOIN " + RetSqlName("NJ0") + " NJ0 "
			cQuery1 += " ON (NJ0.NJ0_FILIAL = '"+ xFilial("NJ0") +"'"
			cQuery1 += "     AND NJ0.NJ0_CODENT = NJM.NJM_CODENT "
			cQuery1 += "     AND NJ0.NJ0_LOJENT = NJM.NJM_LOJENT  "
			cQuery1 += "     AND NJ0.D_E_L_E_T_ = '' )"
			cQuery1 += " WHERE NJM_FILIAL = '"+ xFilial("NJM") +"'"
			cQuery1 += " AND NJM_CODROM = '"+ (cAliasQry)->NJM_CODROM +"'"
			cQuery1 += " AND NJM_SUBTIP = '45'" //Somente Romaneios do (S) Tipo Venda a Ordem
			cQuery1 += " AND NJM_CODCTR = '"+ (cAliasQry)->NJM_CODCTR +"'"
			cQuery1 += " AND NJM_ITEM = '"+ (cAliasQry)->NJM_ITEM +"'"
			cQuery1 += " AND NJM_SEQPRI = '"+ (cAliasQry)->NJM_SEQPRI +"'"
			cQuery1 += " AND NJM_CODINE = '"+ (cAliasQry)->NJM_CODINE +"'"
			cQuery1 += " AND NJM.D_E_L_E_T_ = '' "
			cQuery1 += " GROUP BY NJM_FILIAL,NJM_CODROM, NJM_CODENT,NJM_LOJENT, NJ0_CODCLI, NJ0_LOJCLI"
			
			cQuery1 := ChangeQuery(cQuery1)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1),cAliQryREF, .F., .T.) 

			If (cAliQryREF)->( Eof())
				lRet := .t.
				Exit
			Else
				
				RecLock( _cAliasNJM, .T. )
				( _cAliasNJM )->T_FILIAL  := (cAliasQry)->NJM_FILIAL 
				( _cAliasNJM )->T_CODROM  := (cAliasQry)->NJM_CODROM
				( _cAliasNJM )->T_ITEROM  := (cAliasQry)->NJM_ITEROM
				( _cAliasNJM )->T_CODCLI  := (cAliasQry)->N8J_CLIFOR 
				( _cAliasNJM )->T_LOJCLI	 := (cAliasQry)->N8J_LOJA
				( _cAliasNJM )->T_DOCNUM  := (cAliasQry)->NJM_DOCNUM
				( _cAliasNJM )->T_DOCSER  := (cAliasQry)->NJM_DOCSER
				( _cAliasNJM )->T_DOCESP  := (cAliasQry)->NJM_DOCESP
				( _cAliasNJM )->T_DOCREF  := (cAliasQry)->N8J_DOCREF
				( _cAliasNJM )->T_SERREF  := (cAliasQry)->N8J_SERREF
				( _cAliasNJM )->T_DTEREF  := cToD(SUBSTR((cAliasQry)->N8J_DTEREF, 7, 2) + "/" + SUBSTR((cAliasQry)->N8J_DTEREF, 5, 2) + "/" + SUBSTR((cAliasQry)->N8J_DTEREF, 1, 4))
				( _cAliasNJM )->T_CODINE  := (cAliasQry)->NJM_CODINE
				( _cAliasNJM )->T_CODCTR  := (cAliasQry)->NJM_CODCTR
				( _cAliasNJM )->T_ITECTR  := (cAliasQry)->NJM_ITEM //ITEM CONTRATO
				( _cAliasNJM )->T_ITEREF  := (cAliasQry)->NJM_SEQPRI //ITEM REGRA FISCAL DO CONTRATO
				( _cAliasNJM )->T_CLIREF  := (cAliQryREF)->NJ0_CODCLI
				( _cAliasNJM )->T_LOJREF  := (cAliQryREF)->NJ0_LOJCLI
				( _cAliasNJM )->( MsUnLock() )
				( cAliasQry )->( DbSkip() )
			EndIF
			( cAliQryREF)->( DbCloseArea() )
		EndDo
	EndIf
	
	( cAliasQry )->( DbCloseArea() )	
	
	If Type("_oBrwNJM") <> "U"
		_oBrwNJM:Refresh(.T.)
	EndIf
	
	RestArea( aAreaAtu )

Return lRet


/*---------------------------------------------------------------------
{Protheus.doc} fZapTRB
Função que limpa a tabela 
@author thiago.rover
@since 19/04/2018
@version undefined
@type function
---------------------------------------------------------------------*/
Static Function fZapTRB( pcAliasTRB )
    Local aAreaAtu         := GetArea()
    
    If Select( pcAliasTRB ) > 0
        DbSelectArea( pcAliasTRB )
        Zap
    Endif
    
    RestArea( aAreaAtu )
Return( NIL )

/*---------------------------------------------------------------------
{Protheus.doc} OGA250FGRV
Função que grava os dados na tabela N8J
@author thiago.rover
@since 19/04/2018
@version undefined
@type function
---------------------------------------------------------------------*/
Static Function OGA250FGRV(oDlg)
    local lGetImp := .F. 
    Local lOK	  := .F.
    Local aNotGrv	:= {}
    Local cMsgErro := ''
    Local nX := 0

	dbSelectArea(_cAliasNJM)
	( _cAliasNJM )->(DbGoTop())
	While !( _cAliasNJM )->( Eof()) 	  
		    If  .NOT. lGetImp 
		    	lGetImp := OGA250FVAL()
		    EndIF
		     
		    If VLDNFVND() 
		    	//se NF de venda correspondente foi autorizada no sefaz
				dbSelectArea("N8J")
				N8J->(dbSetOrder(1)) //N8J_FILIAL+N8J_DOCREF+N8J_SERREF+N8J_CLIREF+N8J_LOJREF
		 		If N8J->(dbSeek(xFilial("N8J")+( _cAliasNJM )->T_DOCNUM+( _cAliasNJM )->T_DOCSER+( _cAliasNJM )->T_CODCLI+( _cAliasNJM )->T_LOJCLI))
					RecLock("N8J",.F.)
					N8J->N8J_DOCREF := ( _cAliasNJM )->T_DOCREF
					N8J->N8J_SERREF := ( _cAliasNJM )->T_SERREF		
					N8J->N8J_DTEREF := ( _cAliasNJM )->T_DTEREF
					N8J->N8J_CLIREF := ( _cAliasNJM )->T_CLIREF
					N8J->N8J_LOJREF := ( _cAliasNJM )->T_LOJREF
					N8J->(msUnLock())
				EndIf
				N8J->(DbCloseArea())
				
				If !Empty(( _cAliasNJM )->T_DOCREF) .AND. !Empty(( _cAliasNJM )->T_DTEREF)
					lOK := .T. //SE UM DOS REGISTROS TIVER OS DADOS DE REFERENCIAS PREENCHIDOS, SERIE NÃO OBRIGATORIA
				EndIf
				
			Else
				AADD(aNotGrv,( _cAliasNJM )->T_DOCNUM) //armazena NF que não tera os dados de referencia salvos
			EndIf

	   (_cAliasNJM)->(dbSkip())
    EndDo
    
    If Len(aNotGrv) > 0
		cMsgErro := STR0007 + CHR(13)
		For nX := 1 To Len(aNotGrv) 
			cMsgErro := cMsgErro + CHR(13) + ALLTRIM(aNotGrv[nX])
		Next nX
		Agrhelp(STR0006,cMsgErro,STR0008)
	EndIf
	
	IF lGetImp .AND. lOK
		//se NF não foi transmitida e foi informado dados de referencia
		IF MsgYesNo(STR0004+ _cCodRom + STR0005, STR0006) //#Gostaria de Transmitir o Romaneio #para o Monitor do Sefaz ? #Atenção
			OGA250GTRANS()
		EndIf
	EndIF
	
	oDlg:end()
	
Return



/*/{Protheus.doc} Return
Função que retorna se o pedido não foi transmitido
@author thiago.rover
@since 29/05/2018
@version undefined

@type function
/*/
Static Function OGA250FVAL()
	Local lRet:= .F. 
	Local aSF2Area := {}
	aSF2Area := SF2->(GetArea())
	
	DbSelectArea('SF2')
	SF2->(dbSetOrder( 2 ))   //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
	SF2->(dbSeek( (_cAliasNJM)->T_FILIAL+(_cAliasNJM)->T_CODCLI+(_cAliasNJM)->T_LOJCLI+(_cAliasNJM)->T_DOCNUM+(_cAliasNJM)->T_DOCSER+"N"+"SPED"))
	
	IF Empty(SF2->F2_FIMP) .And. SuperGetMV("MV_AGRO025", .F. , .T.)  == .T. 
	   lRet := .T.  
	EndIf
	
	RestArea(aSF2Area)

Return lRet

Static Function VLDNFVND()
	Local lRet := .F. 
	Local cAliasQry := ''
	Local cQuery := ''
	
	//BUSCA NF DE VENDA DA VENDA ORDEM 
	cAliasQry	:= GetNextAlias() 
	cQuery := " SELECT NJM_DOCNUM, NJM_DOCSER, F2_FIMP " 
	cQuery += " FROM " + RetSqlName("NJM") + " NJM "
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_ = '' AND NJM_FILIAL = F2_FILIAL "
	cQuery += "      AND NJM_DOCNUM = F2_DOC AND NJM_DOCSER = F2_SERIE "
	cQuery += " WHERE NJM_FILIAL = '"+ (_cAliasNJM)->T_FILIAL +"' AND NJM_CODROM = '"+ (_cAliasNJM)->T_CODROM +"' "
	cQuery += " AND NJM_CODINE = '"+ (_cAliasNJM)->T_CODINE +"' AND NJM_CODCTR = '"+ (_cAliasNJM)->T_CODCTR +"' "
	cQuery += " AND NJM_ITEM = '"+ (_cAliasNJM)->T_ITECTR +"' AND NJM_SEQPRI = '"+ (_cAliasNJM)->T_ITEREF +"' "
	cQuery += " AND NJM_SUBTIP = '45' " 
	cQuery += " AND NJM.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  
	
	DbSelectArea( cAliasQry )
	If (cAliasQry)->( !Eof())
		If (cAliasQry)->(F2_FIMP) == "S" //FOI TRANSMITIDA OU AUTORIZADA NO SEFAZ
			lRet := .T.			
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())	

Return lRet
