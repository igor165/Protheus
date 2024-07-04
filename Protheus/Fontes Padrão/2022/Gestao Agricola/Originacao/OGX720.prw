#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'ogx720.ch'


/*{Protheus.doc} OGX720
Aglutinação de Fixação
@author jean.schulze
@since 13/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cFilOrg, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX720(cFilOrg, cCodCtr, cCodCad)
	Local aArea		  := GetArea()
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local nCont       := 0
	Local aButtons    := {}
	Local aCpsBrwFix  := {}
	Local cNegocio    := ""


	Private _cFilOrg    := cFilOrg
	Private _cCodCtr    := cCodCtr
	Private _cCodCad	:= cCodCad
	Private _cTabFix    := ""
	Private _oBrowse1   := nil


	//verifica se existe algum cancelamento em andamento
	if !empty(cNegocio := OGX700VNGA(_cFilOrg, _cCodCtr, "3"))
		Help( , , STR0001, , STR0002+cNegocio+STR0003, 1, 0 )
		return .t.
	endif

	aCpsBrwFix := {{STR0004, "MARK"       , "C",1, , "@!"},; //control utilização
				   {STR0017, "NN8_TIPAGL" , TamSX3( "NN8_TIPAGL" )[3]	, TamSX3( "NN8_TIPAGL" )[1]	, TamSX3( "NN8_TIPAGL" )[2]	, PesqPict("NN8","NN8_TIPAGL") 	},; //"Qtd. Take-Up"
				   {STR0005, "NN8_ITEMFX" , TamSX3( "NN8_ITEMFX" )[3]	, TamSX3( "NN8_ITEMFX" )[1]	, TamSX3( "NN8_ITEMFX" )[2]	, PesqPict("NN8","NN8_ITEMFX") 	},; //"Qtd. Take-Up"
				   {STR0006, "NN8_CODNGC" , TamSX3( "NN8_CODNGC" )[3]	, TamSX3( "NN8_CODNGC" )[1]	, TamSX3( "NN8_CODNGC" )[2]	, PesqPict("NN8","NN8_CODNGC") 	},;
				   {STR0007, "NN8_VERSAO" , TamSX3( "NN8_VERSAO" )[3]	, TamSX3( "NN8_VERSAO" )[1]	, TamSX3( "NN8_VERSAO" )[2]	, PesqPict("NN8","NN8_VERSAO") 	},;
			       {STR0008, "NN8_CODCAD" , TamSX3( "NN8_CODCAD" )[3]	, TamSX3( "NN8_CODCAD" )[1]	, TamSX3( "NN8_CODCAD" )[2]	, PesqPict("NN8","NN8_CODCAD") 	},;
			       {STR0009, "NN8_DATA"   , TamSX3( "NN8_DATA" )[3]	    , TamSX3( "NN8_DATA" )[1]	, TamSX3( "NN8_DATA" )[2]	, PesqPict("NN8","NN8_DATA") 	},;
   {AgrTitulo("NNY_FILORG"), "NNY_FILORG" , TamSX3( "NNY_FILORG" )[3]	, TamSX3( "NNY_FILORG" )[1]	, TamSX3( "NNY_FILORG" )[2]	, PesqPict("NNY","NNY_FILORG") 	},; // Filial de Origem
   {AgrTitulo("NNY_FILDES"), "NNY_FILDES" , TamSX3( "NNY_FILDES" )[3]	, TamSX3( "NNY_FILDES" )[1]	, TamSX3( "NNY_FILDES" )[2]	, PesqPict("NNY","NNY_FILDES") 	},; // Descrição Filial de Origem			
			       {STR0010, "NN8_VALUNI" , TamSX3( "NN8_VALUNI" )[3]	, TamSX3( "NN8_VALUNI" )[1]	, TamSX3( "NN8_VALUNI" )[2]	, PesqPict("NN8","NN8_VALUNI") 	},;
			       {STR0011, "NN8_QTDFIX" , TamSX3( "NN8_QTDFIX" )[3]	, TamSX3( "NN8_QTDFIX" )[1]	, TamSX3( "NN8_QTDFIX" )[2]	, PesqPict("NN8","NN8_QTDFIX") 	},;
			       {STR0012, "NN8_QTDENT" , TamSX3( "NN8_QTDENT" )[3]	, TamSX3( "NN8_QTDENT" )[1]	, TamSX3( "NN8_QTDENT" )[2]	, PesqPict("NN8","NN8_QTDENT") 	},;
			       {STR0013, "SALDO"      , TamSX3( "NN8_QTDENT" )[3]	, TamSX3( "NN8_QTDENT" )[1]	, TamSX3( "NN8_QTDENT" )[2]	, PesqPict("NN8","NN8_QTDENT") 	},;
			       {STR0014, "NN8_VALTOT" , TamSX3( "NN8_VALTOT" )[3]	, TamSX3( "NN8_VALTOT" )[1]	, TamSX3( "NN8_VALTOT" )[2]	, PesqPict("NN8","NN8_VALTOT") 	},;
			       {STR0015, "NN8_MOEDA"  , TamSX3( "NN8_MOEDA" )[3]	    , TamSX3( "NN8_MOEDA" )[1]	, TamSX3( "NN8_MOEDA" )[2]	, PesqPict("NN8","NN8_MOEDA ") 	},;
			       {STR0016, "NN8_TXMOED" , TamSX3( "NN8_TXMOED" )[3]	, TamSX3( "NN8_TXMOED" )[1]	, TamSX3( "NN8_TXMOED" )[2]	, PesqPict("NN8","NN8_TXMOED") 	},;
			       {STR0017, "AGLUTINADO" , "C",3, , "@!"	},; //"Qtd. Take-Up"
				   {STR0018, "NN8_DATINI" , TamSX3( "NN8_DATINI" )[3]	, TamSX3( "NN8_DATINI" )[1]	, TamSX3( "NN8_DATINI" )[2]	, PesqPict("NN8","NN8_DATINI") 	},;
			       {STR0019, "NN8_DATFIN" , TamSX3( "NN8_DATFIN" )[3]	, TamSX3( "NN8_DATFIN" )[1]	, TamSX3( "NN8_DATFIN" )[2]	, PesqPict("NN8","NN8_DATFIN") 	},;
			       {STR0020, "NN8_CODCTR" , TamSX3( "NN8_CODCTR" )[3]	, TamSX3( "NN8_CODCTR" )[1]	, TamSX3( "NN8_CODCTR" )[2]	, PesqPict("NN8","NN8_CODCTR") 	}}	//"Qtd. Take-Up"
	
	Processa({|| _cTabFix := MontaTabel(aCpsBrwFix, {{"", "NN8_CODCTR+NN8_ITEMFX"}})}, STR0021)

	//chama o modelo - criar o dados
	fLoadDados()
	
	//verifica se tem dados 
	DbSelectArea((_cTabFix))
	DbGoTop()
	If !DbSeek((_cTabFix)->NN8_CODCTR+(_cTabFix)->NN8_ITEMFX)
		Help( , , STR0001, , STR0022, 1, 0 )
		return .t.
	endif
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0023, , , , , CLR_BLACK, CLR_WHITE, , , .t. )

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine('TOP'    , 100 , .F.)
	oFWL:addCollumn( 'LEFT-T'  ,100, .F., 'TOP' )

	//cria as janelas
	oFWL:addWindow( 'LEFT-T' , 'Wnd1', STR0024,  100 /*tamanho*/, .F., .T.,, 'TOP' )

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'LEFT-T' , 'Wnd1', 'TOP' )

	/****************************COMPONENTES À FIXAR ****************/
	_oBrowse1 := FWMBrowse():New()
    _oBrowse1:SetAlias(_cTabFix)
    _oBrowse1:DisableDetails()
    _oBrowse1:SetMenuDef( "" )
    _oBrowse1:DisableReport(.T.)
    _oBrowse1:SetProfileID("OGX720NN8")
    
     //marcação de itens
	_oBrowse1:AddMarkColumns( { ||Iif( !Empty( (_cTabFix)->MARK = "1" ),"LBOK","LBNO" ) },{ || OGX720DB(), OGX720UP(_oBrowse1, .f.),  _oBrowse1:SetFocus(), _oBrowse1:GoColumn(1)  }, { || OGX720HD() , OGX720UP(_oBrowse1, .t.),  _oBrowse1:SetFocus()  } )
    
    For nCont := 3 to Len(aCpsBrwFix)
        _oBrowse1:AddColumn( {aCpsBrwFix[nCont][1]  , &("{||"+aCpsBrwFix[nCont][2]+"}") ,aCpsBrwFix[nCont][3],aCpsBrwFix[nCont][6]} )
    Next nCont

    _oBrowse1:Activate(oPnlWnd1)

    //cria os botões adicionais
    Aadd( aButtons, {STR0023, {|| OGX720AGLU()},STR0023, STR0023 , {|| .T.}} )
    Aadd( aButtons, {STR0036, {|| OGX720DESA()},STR0036, STR0036 , {|| .T.}} )

	oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, , {||  oDlg:End() } /*Fechar*/,,@aButtons,,,.f.,.f.,.f.,.f.,.f.) )

	RestArea(aArea)

return .f.

/** {Protheus.doc} SetDataBlc
Função que monta as Temp-Tables da Rotina
@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     24/07/2017
@Uso:       OGX720 - Consulta de Blocos/Fardos
*/
Static Function MontaTabel(aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow)
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
Return cTabela


/*{Protheus.doc} fLoadDados
Obtem os dados das fixações de componente e preço
@author jean.schulze
@since 27/09/2017
@version undefined
@param _aCompnent, , descricao
@type function
*/
Static Function fLoadDados(_aCompnent)
	Local cAliasNN8 	:= GetNextAlias()
	
	DbSelectArea(_cTabFix)
	ZAP
	
	BeginSql Alias cAliasNN8

		SELECT NN8.*, NNY.NNY_FILORG
	  	  FROM %Table:NN8% NN8
	  	  LEFT JOIN %Table:NNY% NNY ON  NNY.NNY_FILIAL = %exp:FwXFilial('NNY')%
		                             AND NNY.NNY_CODCTR = NN8.NN8_CODCTR
		                             AND NNY.NNY_ITEM = NN8.NN8_CODCAD
		                             AND NNY.%notDel%
		WHERE NN8.%notDel%
		  AND NN8.NN8_FILIAL = %exp:_cFilOrg%
		  AND NN8.NN8_CODCTR = %exp:_cCodCtr%
		 // AND NN8.NN8_CODCAD = %exp:_cCodCad%
		  AND NN8.NN8_QTDFIX > NN8.NN8_QTDENT
		  AND NN8.NN8_AGLUTI = "" 		  

	EndSQL

	DbselectArea( cAliasNN8 )
	DbGoTop()
	while ( cAliasNN8 )->( !Eof() )

		Reclock(_cTabFix, .T.)					
			(_cTabFix)->AGLUTINADO  := iif(( cAliasNN8 )->NN8_TIPAGL <> "1", STR0025, STR0026) 
			(_cTabFix)->NN8_TIPAGL  := ( cAliasNN8 )->NN8_TIPAGL 
			(_cTabFix)->NN8_CODCTR  := ( cAliasNN8 )->NN8_CODCTR 
			(_cTabFix)->NN8_ITEMFX  := ( cAliasNN8 )->NN8_ITEMFX
			(_cTabFix)->NN8_CODNGC  := ( cAliasNN8 )->NN8_CODNGC
			(_cTabFix)->NN8_VERSAO  := ( cAliasNN8 )->NN8_VERSAO
			(_cTabFix)->NN8_CODCAD  := ( cAliasNN8 )->NN8_CODCAD
			(_cTabFix)->NNY_FILORG  := ( cAliasNN8 )->NNY_FILORG
			(_cTabFix)->NNY_FILDES  := OGX700PSM0(cAliasNN8 + '->NNY_FILORG')
			(_cTabFix)->NN8_VALUNI  := ( cAliasNN8 )->NN8_VALUNI
			(_cTabFix)->NN8_MOEDA   := ( cAliasNN8 )->NN8_MOEDA
			(_cTabFix)->NN8_TXMOED  := ( cAliasNN8 )->NN8_TXMOED 
			(_cTabFix)->NN8_VALTOT  := ( cAliasNN8 )->NN8_VALTOT 
			(_cTabFix)->NN8_DATA    :=  StoD(( cAliasNN8 )->NN8_DATA)
			(_cTabFix)->NN8_DATINI  :=  StoD(( cAliasNN8 )->NN8_DATINI)
			(_cTabFix)->NN8_DATFIN  :=  StoD(( cAliasNN8 )->NN8_DATFIN)
			(_cTabFix)->NN8_QTDFIX  := ( cAliasNN8 )->NN8_QTDFIX 
			(_cTabFix)->NN8_QTDENT  := ( cAliasNN8 )->NN8_QTDENT
			(_cTabFix)->SALDO       := (_cTabFix)->NN8_QTDFIX -  (_cTabFix)->NN8_QTDENT
	 	MsUnlock()

		( cAliasNN8 )->( dbSkip() )
	Enddo

	( cAliasNN8 )->( dbCloseArea() )

Return( .t. )


/*{Protheus.doc} OGX720DB
Marcação de itens por Double Click
@author jean.schulze
@since 11/08/2017
@version undefined
@type function
*/
static function OGX720DB(oBrwObj, cBrwName)

	if RecLock((_cTabFix),.F.)	.and. !empty((_cTabFix)->NN8_ITEMFX) //tratamento de excessao - sempre posicionado
		(_cTabFix)->MARK = IIF((_cTabFix)->MARK  == "1", "", "1")
		MsUnlock()
	endif
	
return

/*{Protheus.doc} OGX720HD
Marcação de itens no Header do Browse
@author jean.schulze
@since 11/08/2017
@version undefined
@type function
*/
Static Function OGX720HD()
	Local cOperDat := ""
	
	DbSelectArea((_cTabFix))
	DbGoTop()
	If DbSeek((_cTabFix)->NN8_CODCTR+(_cTabFix)->NN8_ITEMFX)
		cOperDat := IIF((_cTabFix)->MARK  == "1", "", "1")
		While !(_cTabFix)->(Eof())

			If RecLock((_cTabFix),.f.)
				(_cTabFix)->MARK = cOperDat
				MsUnlock()
			EndIf

			(_cTabFix)->( dbSkip() )
		enddo
	endif

return

/*{Protheus.doc} OGX720UP
Função de Update do Browse
@author jean.schulze
@since 11/08/2017
@version undefined
@param objBrowser, object, descricao
@param lUpdAll, logical, descricao
@type function
*/
static function OGX720UP(objBrowser, lUpdAll) //tratamento de refresh
	Default lUpdAll := .t.

	if lUpdAll
		objBrowser:UpdateBrowse() //reconstroi tudo
	else
		objBrowser:LineRefresh() //só refaz a linha
	endif
	objBrowser:GoColumn(1)
return .t.

/*{Protheus.doc} OGX720AGLU
Realiza a aglutinação de Preços
@author jean.schulze
@since 13/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGX720AGLU()
	Local lRetorno  := .t.
	Local aListFix  := {}
	Local aNewsFix  := {}
	Local nQtd      := 0
	Local lOpcao    := .f.
	Local oDlg2     := nil
	Local dDate     := dDataBase
	Local nSeqfix   := 0
	Local nX        := 0
	Local cUMCtr    := Posicione("NJR",1,_cFilOrg+_cCodCtr , "NJR_UM1PRO")
	Local cUMPrc    := Posicione("NJR",1,_cFilOrg+_cCodCtr , "NJR_UMPRC")
	Local cCodPro   := Posicione("NJR",1,_cFilOrg+_cCodCtr , "NJR_CODPRO")
	Local nVlrSug   := 0
	Local aItensNKA := {}
	Local nPosNKA   := 0
		
	Private nValorNN8   := 0
	
	//monta a média ponderada X quantidade
	DbSelectArea((_cTabFix))
	DbGoTop()
	If DbSeek((_cTabFix)->NN8_CODCTR+(_cTabFix)->NN8_ITEMFX)
		While !(_cTabFix)->(Eof())

			If (_cTabFix)->MARK == "1" //está marcado
				aAdd(aListFix, {(_cTabFix)->NN8_CODCTR, (_cTabFix)->NN8_ITEMFX, (_cTabFix)->NN8_CODCAD , (_cTabFix)->NN8_QTDFIX - (_cTabFix)->NN8_QTDENT  })
				nValorNN8   += (_cTabFix)->NN8_VALUNI * ((_cTabFix)->NN8_QTDFIX - (_cTabFix)->NN8_QTDENT)
				nQtd     += (_cTabFix)->NN8_QTDFIX - (_cTabFix)->NN8_QTDENT
				
				//monta os dados da nova fixação
				if (nPos := aScan(aNewsFix,{|x| allTrim(x[1]) == alltrim((_cTabFix)->NN8_CODCAD)})) > 0
					aNewsFix[nPos][2] += (_cTabFix)->NN8_QTDFIX - (_cTabFix)->NN8_QTDENT  //valor total
				else //uso de dupla cadencia
					Aadd(aNewsFix, {(_cTabFix)->NN8_CODCAD, (_cTabFix)->NN8_QTDFIX - (_cTabFix)->NN8_QTDENT, (_cTabFix)->NN8_MOEDA, (_cTabFix)->NN8_TXMOED, (_cTabFix)->NN8_DATINI, (_cTabFix)->NN8_DATFIN, "" })
				endif
				
			EndIf

			(_cTabFix)->( dbSkip() )
		enddo
	endif
	
	//verifica se há quantidade
	if len(aListFix) > 1		
		
		//gera a média ponderada
		nValorNN8 := nValorNN8 / nQtd
		nVlrSug   := nValorNN8
		//abre a tela para saber o dia e se será aplicado a reserva
		oDlg2	:= TDialog():New(200,406,350,750,STR0027,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
		oDlg2:lEscClose := .f.
			
		@ 038,008 SAY STR0028 PIXEL		
		@ 038,024 MSGET dDate OF oDlg2 PIXEL WHEN .t.
					
		@ 038,072 SAY STR0029 PIXEL 
		@ 038,096 MSGET nValorNN8 OF oDlg2 PIXEL WHEN .t. PICTURE PesqPict("NN8","NN8_VALUNI") VALID POSITIVO() .and. !VAZIO()
	
		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| lOpcao := .T., oDlg2:End()},{|| lOpcao := .F.,oDlg2:End()}) CENTERED
		
		if lOpcao .and.  nVlrSug <> nValorNN8
			if !MsgYesNo(STR0047+"'" + allTrim(transform(nVlrSug,PesqPict("NN8","NN8_VALUNI") )) + "' "+STR0048+" '" + allTrim(transform(nValorNN8, PesqPict("NN8","NN8_VALUNI"))) + "'."+STR0049) 
				lOpcao := .f. //desarma a operacao
			endif	
		endif
				
		//gera o valor - pergunta se está ok
		if lOpcao .and. MsgYesNo(STR0030+alltrim(str(len(aListFix)))+STR0031) 
		
			BEGIN TRANSACTION
				
				nSeqfix := OGX700NN8S(_cFilOrg, _cCodCtr ) //reset sequencie
				
				dbSelectArea( "NN8" )
				dbSetOrder( 1 ) //Filial+CodCtr+Item
				
				//grava as novas fixações de preço
				For nX := 1 to Len(aNewsFix)
					
					nSeqfix++ //incremento no sequencie de dados
					
					RecLock( "NN8", .T. )
					    NN8->NN8_FILIAL := _cFilOrg
						NN8->NN8_CODCTR := _cCodCtr 
						NN8->NN8_CODCAD := aNewsFix[nX][1]
						NN8->NN8_ITEMFX := PadL(cValToChar(nSeqfix), TamSX3( "NN8_ITEMFX" )[1], "0") //sequencia usada na NN8
 						NN8->NN8_TIPOFX := "1" //fixo
						NN8->NN8_STATUS := "2" //fixo  
						NN8->NN8_DATA   := dDate 
						NN8->NN8_DATINI := aNewsFix[nX][5]
						NN8->NN8_DATFIN := aNewsFix[nX][6]
						NN8->NN8_QTDFIX := aNewsFix[nX][2]
						NN8->NN8_MOEDA 	:= aNewsFix[nX][3]
						NN8->NN8_TXMOED := aNewsFix[nX][4]
						NN8->NN8_TIPAGL := "1" //aglutinador
						
						//valor na moeda corrente
						NN8->NN8_VLRUNI := nValorNN8 //verifica a necessidade de conversao para estar no valor da unidade de medida de preço
						NN8->NN8_VLRTOT := Round( nValorNN8 * AGRX001( cUMCtr, cUMPrc, NN8->NN8_QTDFIX,cCodPro) ,2 )    
						
						//valor sem impostos em R$
						NN8->NN8_VLRLIQ := NN8->NN8_VLRUNI // verificar o tratamento a ser realizado no estudo dos impostos
						NN8->NN8_VLRLQT := NN8->NN8_VLRTOT 
												
						//valor em outra moeda
						if NN8->NN8_MOEDA  <> 1 
							
							If NN8->NN8_TXMOED  <= 0 //se a cotação não foi informada
								NN8->NN8_VALUNI := Round(xMoeda( NN8->NN8_VLRUNI, NN8->NN8_MOEDA , 1, dDate ,TamSX3("NN8_TXMOED")[2] ),TamSX3("NN8_VALUNI")[2] )  
							Else
								NN8->NN8_VALUNI  := Round(NN8->NN8_VLRUNI / NN8->NN8_TXMOED , TamSX3("NN8_VALUNI")[2] )
							EndIf
							
							//valor na unidade de medida de preço em dólar - converter
							NN8->NN8_VALTOT := Round( NN8->NN8_VALUNI * AGRX001( cUMCtr, cUMPrc, NN8->NN8_QTDFIX, cCodPro ) ,2 )   
							
							//sem imposots na outra moeda
							NN8->NN8_VALLIQ := NN8->NN8_VALUNI 
							NN8->NN8_VALLQT := NN8->NN8_VALTOT  //total da fixação sem impostos
						else //moeda corrente
							//valor na unidade de medida de preço em dólar - converter
							NN8->NN8_VALUNI := NN8->NN8_VLRUNI
							NN8->NN8_VALTOT := NN8->NN8_VLRTOT
							
							//sem imposots na outra moeda
							NN8->NN8_VALLIQ := NN8->NN8_VLRUNI 
							NN8->NN8_VALLQT := NN8->NN8_VLRTOT //total da fixação sem impostos
							
						endif					
						
						//guarda a sequencia utilizada
						aNewsFix[nX][7] := NN8->NN8_ITEMFX	
						
					NN8->(MsUnLock())
					
				next nx
				
				dbSelectArea( "NN8" )
				dbSetOrder( 1 ) //Filial+CodCtr+Item
				
				For nX := 1 to Len(aListFix)
					
					if lRetorno
					
						if NN8->(dbSeek(_cFilOrg + aListFix[nX][1] + aListFix[nX][2]))
							
							//valida se tem saldo ainda
							if NN8->NN8_QTDFIX - (NN8->NN8_QTDENT - NN8->NN8_QTDAGL) >=  aListFix[nX][4] .and. empty(NN8->NN8_AGLUTI)
								RecLock( "NN8", .F. )
								
								NN8->NN8_QTDAGL := aListFix[nX][4]
								NN8->NN8_QTDFIX -= aListFix[nX][4]
								NN8->NN8_QTDRES		:= 0   //Zerando a Qtidade Vinculada, pois será movida para a nova fixação
															              
								if (nPos := aScan(aNewsFix,{|x| allTrim(x[1]) == alltrim(NN8->NN8_CODCAD)})) > 0
									NN8->NN8_AGLUTI := aNewsFix[nPos][7]
									
									//gravamos as tabelas de componentes para encontrar a média ponderada
									DbSelectArea("NKA")
									NKA->( dbSetOrder(1) )
									NKA->(DbSeek(_cFilOrg + aListFix[nX][1] + aListFix[nX][2]))
								
									While NKA->(NKA_FILIAL + NKA_CODCTR + NKA_ITEMFX ) == _cFilOrg + aListFix[nX][1] + aListFix[nX][2]
										
										if (nPosNKA := aScan(aItensNKA,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3]) == alltrim(aNewsFix[nPos][7]) + alltrim(NKA->NKA_CODCOM) + alltrim(NKA->NKA_ITEMCO) })) == 0
										
											aaDD(aItensNKA, array(16))
											nPosNKA := len(aItensNKA)
											
											aItensNKA[nPosNKA][1]  := aNewsFix[nPos][7]//ITEM FIXAÇÃO	
											aItensNKA[nPosNKA][2]  := NKA->NKA_CODCOM //Componente
											aItensNKA[nPosNKA][3]  := NKA->NKA_ITEMCO //ITEM Componente												
											aItensNKA[nPosNKA][4]  := NKA->NKA_DESCRI
											aItensNKA[nPosNKA][5]  := NKA->NKA_TPVLR 
											aItensNKA[nPosNKA][6]  := NKA->NKA_MOEDCO
											aItensNKA[nPosNKA][7]  := NKA->NKA_UMCOM 
											aItensNKA[nPosNKA][8]  := NKA->NKA_MOEDCT 
											aItensNKA[nPosNKA][9]  := NKA->NKA_UMPRC 
											aItensNKA[nPosNKA][10] := NKA->NKA_UMPROD 
											aItensNKA[nPosNKA][11] := 0
											aItensNKA[nPosNKA][12] := 0
											aItensNKA[nPosNKA][13] := 0
											aItensNKA[nPosNKA][14] := 0
											aItensNKA[nPosNKA][15] := 0
											aItensNKA[nPosNKA][16] := 0
											
										endif
										
										//refaz os cálculos
										aItensNKA[nPosNKA][11] += NKA->NKA_VLRIDX * aListFix[nX][4] //média ponderada
										aItensNKA[nPosNKA][12] += NKA->NKA_VLRCOM * aListFix[nX][4] //média ponderada
										aItensNKA[nPosNKA][13] += NKA->NKA_VLRUN1 * aListFix[nX][4] //média ponderada
										aItensNKA[nPosNKA][14] += NKA->NKA_VLRUN2 * aListFix[nX][4] //média ponderada
										aItensNKA[nPosNKA][15] += NKA->NKA_TXACOT * aListFix[nX][4] //média ponderada
										aItensNKA[nPosNKA][16] += aListFix[nX][4] //QTD TOTAL
										
										NKA->( dbSkip() )
									EndDo
																	
									
								else //erro ao encontrar o parent
									lRetorno := .f.
								endif
								                
								NN8->(MsUnLock())
							else
								lRetorno := .f.
							endif
						else
							lRetorno := .f.
						endif
						
					endif				
					
				next nx	
				
				//gravamos as tabelas com o valor de cada componente com média ponderada
				DbSelectArea("NKA")
				dbSetOrder( 1 ) //Filial+CodCtr+Item	
				For nX := 1 to len(aItensNKA)
				
					RecLock( "NKA", .T. )
						NKA->NKA_FILIAL  := _cFilOrg
						NKA->NKA_CODCTR  := _cCodCtr
						NKA->NKA_ITEMFX  := aItensNKA[nX][1]  
						NKA->NKA_CODCOM  := aItensNKA[nX][2]  
						NKA->NKA_ITEMCO  := aItensNKA[nX][3]  									
						NKA->NKA_DESCRI  := aItensNKA[nX][4] 
						NKA->NKA_TPVLR   := aItensNKA[nX][5]  
						NKA->NKA_MOEDCO  := aItensNKA[nX][6] 
						NKA->NKA_UMCOM   := aItensNKA[nX][7]
						NKA->NKA_MOEDCT  := aItensNKA[nX][8]  
						NKA->NKA_UMPRC   := aItensNKA[nX][9]
						NKA->NKA_UMPROD  := aItensNKA[nX][10]   
						NKA->NKA_VLRIDX  := aItensNKA[nX][11] / aItensNKA[nX][16] //média ponderada
						NKA->NKA_VLRCOM  :=	aItensNKA[nX][12] / aItensNKA[nX][16] //média ponderada
						NKA->NKA_VLRUN1	 :=	aItensNKA[nX][13] / aItensNKA[nX][16] //média ponderada
						NKA->NKA_VLRUN2	 :=	aItensNKA[nX][14] / aItensNKA[nX][16] //média ponderada
						NKA->NKA_TXACOT	 := aItensNKA[nX][15] / aItensNKA[nX][16] //média ponderada
					NKA->(MsUnLock())
					
				next nX	
				
				IF lRetorno   // Move possiveis fardos das fixações aglutinadas, para aglutinadora.
				  	fMvBlcVnc( aClone(aListFix), aClone(aNewsFix), nValorNN8 )	
				  	Processa({|| OGX016(_cFilOrg, _cCodCtr) }, STR0046)								  				  		  	
				EndIF	
				
				if !lRetorno
					DisarmTransaction()
					Help( , , STR0001, , STR0032, 1, 0 )
					lRetorno := .f.	
				else
					MsgInfo(STR0033, STR0034)
				endif
				
			END TRANSACTION
			
			if lRetorno
				OGX055(_cFilOrg, _cCodCtr)	//Recalcula Valores da regra FISCAL		
			endif
			
			//reload na tabela
			fLoadDados()	
			
		endif
			
	else
		Help( , , STR0001, , STR0035, 1, 0 )
		lRetorno := .f.	
	endif
	
	OGX720UP(_oBrowse1, .t.)
	
return lRetorno

/*{Protheus.doc} fMvBlcVnc
Move blocos vinculados de fix. aglutinada para aglutinadora
@author emerson
@since 13/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function fMvBlcVnc( aListFix, aNewsFix, nNewVlr)
	Local nX         := 0
	Local nI         := 0
	Local nB         := 0
	Local aAux       := 0
	Local cIdEntr    := ''
	Local cNewIdFix  := ''
	Local cAliasN8D  := GetNextAlias()
	Local aRegFardos := {}
	Local nA		 := 0
	Local cSeqVnc	 := ''
	Local lRet		 := .t.
	Local nPesoLqVnc := 0
	Local nPesoBrVnc := 0
	Local nQtdFardos := 0
	Local lGrava	 := .f.
	Local nOrdem     := 0
	Local nQtdPrior  := 0
	Local lAlgodao   := AGRTPALGOD(Posicione("NJR",1,_cFilOrg+_cCodCtr , "NJR_CODPRO"))
	Local nVlrFix    := 0
	Local aFarInsrt  := {}
	Local aFarInativ := {}
	Local aRetorno   := {}
	Local aLstRegra  := {}
	Local nPos       := 0
	///Atenção:  rotina  está sendo chamada dentro de transação

	//Ordenando o Array, pelas coluna 1,2,3
	aListFix:=aClone( aSort(alistFix,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] }) )

	For nX := 1 to Len(aNewsFix)
		
		nOrdem    := 0
		nQtdPrior := 0
		cNewIdFix := aNewsFix[nX][7] // IdFix
		cIdEntr   := aNewsFix[nX][1]
		aLstRegra := {}
		aAux:={}
		nPos := 0

		For nI := 1 to len(aListFix)
			IF Alltrim( aListFix[nI,3]) == alltrim(cIdEntr)
				Aadd(aAux, Array(Len(aListFix[nI])))
				ACopy(aListFix[nI], aAux[Len(aAux)])
			EndIF
		Next nI

		nI := 1
		While nI <= Len(aAux) .and.  Alltrim( aAux [nI, 3] ) == Alltrim(cIdEntr)  // Encontro todas as Fixações que Geraram foram aglutinadas por cadencia.

			BeginSql Alias cAliasN8D
				SELECT N8D.*,N8D.R_E_C_N_O_ AS N8D_RECNO 
				FROM %Table:N8D% N8D
				WHERE N8D.%notDel%
				AND N8D.N8D_FILIAL  = %exp:fwxFilial("N8D")%
				AND N8D.N8D_CODCTR  = %exp:aAux [nI, 1]%  
				AND N8D.N8D_ITEMFX = %exp:aAux [nI, 2]%  

				ORDER BY N8D.N8D_CODCTR,N8D.N8D_ITEMFX,N8D.N8D_BLOCO
			EndSQL


			DbselectArea( cAliasN8D )
			DbGoTop()
			while ( cAliasN8D )->( !Eof() )
				if lAlgodao
					//Verificando se o Bloco já se encontra vinculado, Se sim irei adicionar os fardos ao vinc. Há ordem já existente
					cSeqVnc:='0'
					cSeqVnc:=fOrdBlkN8D( (cAliasN8D)->N8D_FILIAL, (cAliasN8D)->N8D_CODCTR,cNewIdFix,(cAliasN8D)->N8D_BLOCO,(cAliasN8D)->N8D_FILORG)
	
					IF cSeqVnc == '0' //o Bloco não se encontra em nenhuma outro vincula criado anteriormente, então devo criar um vinculo
						cSeqVnc := OGX720N8DS( (cAliasN8D)->N8D_FILIAL, (cAliasN8D)->N8D_CODCTR,cNewIdFix ) //Verifica a ultima sequencia (N8D_SEQVNC) que existepara a fixação a ser criada
						cSeqVnc := PadL(cSeqVnc, TamSX3( "N8D_SEQVNC" )[1], "0") 
						cSeqVnc := Soma1(cSeqVnc)
					EndIF			
	
					nPesoLqVnc 	:=0
					nPesoBrVnc  :=0
					nQtdFardos	:=0
	
					dbSelectArea("N8D")
					N8D->(dbGoTo( (cAliasN8D)->N8D_RECNO )) 
					IF (cAliasN8D)->N8D_RECNO == N8D->( Recno() ) // --- Verifica o Recno posicionado, Pois o Dbgoto() , retorno é sempre nulo ---//
						If RecLock( "N8D", .F. )
							N8D->( dbDelete() )
							N8D->( MsUnlock('N8D') )
						EndIF
	
						// Encontra os fardos a vincular na nova Fixação
						aRegFardos := fGetFrdVnc((cAliasN8D)->N8D_CODCTR ,(cAliasN8D)->N8D_ITEMFX, (cAliasN8D)->N8D_SEQVNC,(cAliasN8D)->N8D_BLOCO,(cAliasN8D)->N8D_FILORG )
						//Mudando o vinculo dos fardos para a nova fixação (aglutinadora)	
						For nA := 1  to len(aRegFardos)
							IF (Select("DXI") == 0)
								DbSelectArea("DXI")
							endif
	
							DXI->(dbGoto(aRegFardos[nA]))
							
							//lista para remover
							aAdd(aFarInativ,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{DXI->DXI_FILIAL},; // Filial Origem Fardo
																		 {_cFilOrg},; // FILIAL CTR
																		 {DXI->DXI_SAFRA},; // Safra
																		 {DXI->DXI_ETIQ},; // Etiqueta do Fardo
																		 {"03"},; // Tipo de Movimentação ("03" - Fixação)
																		 {"2"}} }) // Código do Contrato
							RecLock( "DXI", .F. )
							DXI->DXI_ITEMFX := cNewIdFix
							DXI->DXI_ORDENT := cSeqVnc
							DXI->DXI_VLBASE := nNewVlr
							nPesoLqVnc 		+=DXI->DXI_PSLIQU
							nPesoBrVnc      +=DXI->DXI_PSBRUT
							nQtdFardos		+=1
							
							//lista para incluir
							aaDD(aFarInsrt , {{"N9D_FILIAL", DXI->DXI_FILIAL	},;
											{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
										 	{"N9D_FARDO" , DXI->DXI_ETIQ	},;
										 	{"N9D_TIPMOV", "03" 			},; //fixação
										 	{"N9D_DATA"  , dDAtaBase 		},;
										 	{"N9D_PESINI", DXI->DXI_PSLIQU 	},;
										 	{"N9D_ENTLOC", DXI->DXI_PRDTOR 	},;
										 	{"N9D_LOJLOC", DXI->DXI_LJPRO 	},;
										 	{"N9D_STATUS", "2" 				},; //Ativo
										 	{"N9D_ITEFIX", cNewIdFix },;
										 	{"N9D_FILORG", _cFilOrg	} ;
										   })	
								
							DXI->(MsUnLock())
						next nA
	
						//Criando novo registo da N8D
						dbSelectArea("N8D")
						N8D->( dbSetOrder(2) ) 			//N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D->N8D_SEQVNC
						lGrava := N8D->(DbSeek(fwxFilial("N8D") + (cAliasN8D)->(N8D_CODCTR+cNewIdFix)+cSeqVnc))
						RecLock("N8D", !lGrava ) // Se existir irei ( adicionar o bloco e seus fardos ao  vinculo, senao irei criar um novo vinculo)
						N8D->N8D_FILIAL	:= FwxFilial("N8D")
						N8D->N8D_CODCTR	:= aAux [nI, 1]
						N8D->N8D_ITEMFX	:= cNewIdFix
						N8D->N8D_SEQVNC	:= cSeqVnc
						N8D->N8D_ORDEM	:= cSeqVnc //usa a mesma vinculação do campo de sequencia
						N8D->N8D_BLOCO  := (cAliasN8D)->N8D_BLOCO
						N8D->N8D_TIPO	:= (cAliasN8D)->N8D_TIPO
						N8D->N8D_QTDFAR	+= nQtdFardos
						N8D->N8D_QTDVNC	+= nPesoLqVnc
						N8D->N8D_QTDBTO	+= nPesoBrVnc
						N8D->N8D_FILORG	:= (cAliasN8D)->N8D_FILORG
						N8D->( MsUnlock() )
	
						//Atualizando qt. Vinculada na Fixação    
						dbSelectArea( "NN8" )
						dbSetOrder( 1 ) //Filial+CodCtr+Item
						IF NN8->(dbSeek( fwxfilial('NN8')+(cAliasN8D)->N8D_CODCTR+cNewIdFix ))
							RecLock( "NN8", .F. )
							NN8->NN8_QTDRES += nPesoLqVnc
							NN8->( MsUnlock() )
						EndIF
					EndIF
				else
					dbSelectArea("N8D")
					N8D->(dbGoTo( (cAliasN8D)->N8D_RECNO )) 
					IF (cAliasN8D)->N8D_RECNO == N8D->( Recno() ) // --- Verifica o Recno posicionado, Pois o Dbgoto() , retorno é sempre nulo ---//
						
						//soma a quantidade
						nQtdPrior += N8D->(N8D_QTDVNC)
						
						//quebra os valores por regra fiscal
						if (nPos := aScan(aLstRegra, { |x| Alltrim(x[1]) == alltrim(N8D->(N8D_REGRA) )})) > 0 
							aLstRegra[nPos][2] += N8D->(N8D_QTDVNC)
						else
							aadd(aLstRegra, {N8D->(N8D_REGRA), N8D->(N8D_QTDVNC), N8D->(N8D_ORDEM)})
						endif
						
						//deleta o atual
						If RecLock( "N8D", .F. )
							N8D->( dbDelete() )
							N8D->( MsUnlock('N8D') )
						EndIF
					endif	
				endif	
				( cAliasN8D )->( dbSkip() )
			Enddo
			( cAliasN8D )->( dbCloseArea() )
			nI++
		EndDo
		
		if !lAlgodao .and. nQtdPrior > 0 //tem alguma quantidade
			
			//reset
			nVlrFix := 0
			
			//Atualizando qt. Vinculada na Fixação    
			dbSelectArea( "NN8" )
			dbSetOrder( 1 ) //Filial+CodCtr+Item
			IF NN8->(dbSeek( fwxfilial('NN8')+_cCodCtr+cNewIdFix ))
				RecLock( "NN8", .F. )
				NN8->NN8_QTDRES += nQtdPrior
				nVlrFix         := NN8->NN8_VLRUNI
				NN8->( MsUnlock() )
			EndIF
			
			//novo vinculo de graos
			cSeqVnc := OGX720N8DS( _cFilOrg , _cCodCtr ) //Verifica a ultima sequencia (N8D_SEQVNC) que existepara a fixação a ser criada
			cSeqVnc := PadL(cSeqVnc, TamSX3( "N8D_SEQVNC" )[1], "0") 
						
			For nB := 1 to len(aLstRegra)
				cSeqVnc := Soma1(cSeqVnc)
				
				//Criando novo registo da N8D
				dbSelectArea("N8D")
				RecLock("N8D", .t.) // Se existir irei ( adicionar o bloco e seus fardos ao  vinculo, senao irei criar um novo vinculo)
					N8D->N8D_FILIAL	:= FwxFilial("N8D")
					N8D->N8D_CODCTR	:= _cCodCtr
					N8D->N8D_ITEMFX	:= cNewIdFix
					N8D->N8D_SEQVNC	:= cSeqVnc
					N8D->N8D_ORDEM	:= aLstRegra[nB][3] //usa a mesma vinculação do campo de sequencia
					N8D->N8D_QTDVNC	:= aLstRegra[nB][2]
					N8D->N8D_VALOR	:= nVlrFix
					N8D->N8D_REGRA  := aLstRegra[nB][1]
					N8D->N8D_CODCAD := cIdEntr
				N8D->( MsUnlock() )
            next nB
			
		endif
		
	next NX
	
	//retorna os dados para gravação
	if len(aFarInativ) > 0 
		aRetorno := AGRMOVFARD(, 2, 2, , aFarInativ) // Inativa os fardos removidos	
		if !empty(aRetorno[2])
			Help( , , STR0001, , aRetorno[2], 1, 0 )  //erro gravação de fardo
			lRet := .f.
		endif
	endif
	
	if len(aFarInsrt) > 0 
		aRetorno :=  AGRMOVFARD(aFarInsrt, 1) // Passa os fardos para gravação
		if !empty(aRetorno[2])
			Help( , , STR0001, , aRetorno[2], 1, 0 )  //erro gravação de fardo
			lRet := .f.
		endif	
	endif
	
Return( lRet )

/*{Protheus.doc} fGetFrdVnc
Obtem os Fardos que estão vinculados
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, Codigo do contrato
@param cItemFx, characters, Item de fixação
@param cOrdem, characters,  Ordem de vinculação
@param cBloco, characters, Bloco
@param cFilBloco, characters, Filial do Bloco
@type function
*/
static function fGetFrdVnc(cCodCtr, cItemFx, cSeqvnc, cBloco, cFilBloco)
	Local cAliasDXI   := GetNextAlias()
	Local aRecnos     := {}
	
	BeginSQL Alias cAliasDXI
		SELECT DXI.DXI_FILIAL, DXI.DXI_SAFRA, DXI.DXI_ETIQ, DXI.R_E_C_N_O_ AS DXI_RECNO 
		  FROM %table:DXI% DXI
		  INNER JOIN %table:DXD% DXD ON DXD.DXD_FILIAL = DXI.DXI_FILIAL  
						     		AND DXD.DXD_SAFRA  = DXI.DXI_SAFRA 
									AND DXD.DXD_CODIGO = DXI.DXI_BLOCO 
									AND DXD.%notDel%
		  INNER JOIN %table:DXQ% DXQ ON DXQ.DXQ_FILORG = DXD.DXD_FILIAL  
		  							AND DXQ.DXQ_BLOCO  = DXD.DXD_CODIGO 
		  							AND DXQ.%notDel%
		  INNER JOIN %table:DXP% DXP ON DXP.DXP_FILIAL = DXQ.DXQ_FILIAL
		  							AND DXP.DXP_CODIGO = DXQ.DXQ_CODRES
		  						    AND DXP.%notDel%					    
		
		WHERE DXP.%notDel%	
	      AND DXP.DXP_FILIAL  = %xFilial:DXP% //filial da reserva segue a filial do contrato
	      AND DXP.DXP_CODCTP  = %exp:cCodCtr%
	      AND DXI.DXI_ITEMFX  = %exp:cItemFx%
	      AND DXI.DXI_FILIAL  = %exp:cFilBloco%  
	      AND DXI.DXI_CODRES  = DXQ.DXQ_CODRES
	      AND DXI.DXI_ORDENT  = %exp:cSeqvnc%
		  AND DXI.DXI_BLOCO   = %exp:cBloco%
	EndSql
	
	dbSelectArea(cAliasDXI)
	(cAliasDXI)->( dbGoTop() )
	While (cAliasDXI)->(!Eof())
		
		aAdd(aRecnos, (cAliasDXI)->DXI_RECNO)

		(cAliasDXI)->( dbSkip() )	
	EndDo
		
return aRecnos


/*{Protheus.doc} OGX720N8DS
Retorna a ultima sequencia usada na N8D
@author Emerson coelho
@since 02/10/2017
@version undefined
@param cFilial, characters, descricao
@param cCodCtr, characters, descricao
@param cItemFx, characters, descricao
@type function
*/                                                                                                             
Function OGX720N8DS(cFilN8D, cCodCtr, cItemFx )
	Local cAliasN8D := GetNextAlias()
	Local cOrdemN8D := '0'
	Local cFiltro   := ""
	
	Default cItemFx := ""
	
	if !empty(cItemFx)
		cFiltro := "AND N8D.N8D_ITEMFX = '"+cItemFx+"'"
	endif
	
	cFiltro := "%" + cFiltro + "%" 
			
	BeginSql Alias cAliasN8D

		SELECT N8D.N8D_SEQVNC
	  	  FROM %Table:N8D% N8D 
		WHERE N8D.%notDel%
		  %exp:cFiltro% 
		  AND N8D.N8D_FILIAL = %exp:cFilN8D% 
		  AND N8D.N8D_CODCTR = %exp:cCodCtr%		  
		ORDER BY  N8D.N8D_SEQVNC DESC	
		 		         		           
	EndSQL
	
	DbselectArea( cAliasN8D )
	DbGoTop()
	if ( cAliasN8D )->( !Eof() )
	 	cOrdemN8D   := (cAliasN8D )->N8D_SEQVNC
		( cAliasN8D )->( dbSkip() )
	Endif
	( cAliasN8D )->( dbCloseArea() )
return (cOrdemN8D)

/*{Protheus.doc} fOrdBlkN8D
Verifica se um determinado bloco ja se encontra vinculado
@author Emerson coelho
@since 02/10/2017
@version undefined
@param cFilial, characters, descricao
@param cCodCtr, characters, descricao
@param cItemFx, characters, descricao
@param cBloco, characters, descricao
@param cFilBloco characters, descricao
@type function
*/
Static Function fOrdBlkN8D(cFilN8D, cCodCtr, cItemFx,cBloco,cFilBloco )
	Local cAliasN8D  := GetNextAlias()
	Local cBlocoOrd := '0'
		
	BeginSql Alias cAliasN8D

		SELECT N8D.N8D_SEQVNC
	  	  FROM %Table:N8D% N8D 
		WHERE N8D.%notDel%
		  AND N8D.N8D_FILIAL = %exp:cFilN8D% 
		  AND N8D.N8D_CODCTR = %exp:cCodCtr%
		  AND N8D.N8D_ITEMFX = %exp:cItemFx%
		  AND N8D.N8D_BLOCO  = %exp:cBloco%
		  AND N8D.N8D_FILORG = %exp:cFilbloco%
		ORDER BY  N8D.N8D_SEQVNC	 		         		           
	EndSQL
	
	DbselectArea( cAliasN8D )
	DbGoTop()
	if ( cAliasN8D )->( !Eof() )
	 	cBlocoOrd   :=  (cAliasN8D )->N8D_SEQVNC
		( cAliasN8D )->( dbSkip() )
	Endif
	( cAliasN8D )->( dbCloseArea() )
return (cBlocoOrd)

/*{Protheus.doc} OGX720DESA
Desaglutinar Fixações
@author jean.schulze
@since 15/12/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGX720DESA()
	Local lRetorno   := .t.
	Local aListFix   := {}
	Local nX         := 0
	Local nY         := 0
	Local aRecnos    := {}
	Local lVincN8D   := .f.
	Local lAlgodao   := AGRTPALGOD(Posicione("NJR",1,_cFilOrg+_cCodCtr , "NJR_CODPRO"))
	Local aFarInativ := {}
	Local aRetorno   := {}	
	Local nSeqAprop  := 0
	Local nB         := 0

	DbSelectArea((_cTabFix))
	DbGoTop()
	If DbSeek((_cTabFix)->NN8_CODCTR+(_cTabFix)->NN8_ITEMFX)
		While !(_cTabFix)->(Eof()) .and. lRetorno

			If (_cTabFix)->MARK == "1" //está marcado
				
				aAdd(aListFix, {(_cTabFix)->NN8_CODCTR, (_cTabFix)->NN8_ITEMFX })
				
				if (_cTabFix)->NN8_TIPAGL <> "1" //aglutinador
					Help( , , STR0001, ,STR0037, 1, 0 )
					lRetorno := .f.
				elseif  (_cTabFix)->NN8_QTDENT > 0
					Help( , , STR0001, ,STR0038, 1, 0 )
					lRetorno :=  .f.
				elseif (_cTabFix)->NN8_QTDFIX <=0
				 	Help( , , STR0001, ,STR0039, 1, 0 )
					lRetorno :=  .f.
				endif
				
				//verifica se tem vinculo com a N8D	
				dbSelectArea("N8D")
				N8D->( dbSetOrder(2) ) 	//N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D->N8D_SEQVNC
				if N8D->(DbSeek(fwxFilial("N8D") + (_cTabFix)->NN8_CODCTR + (_cTabFix)->NN8_ITEMFX))
					lVincN8D := .t.
				endif	
				
			EndIf

			(_cTabFix)->( dbSkip() )
		enddo
	endif
	
	if lRetorno
		//verifica se há quantidade
		if len(aListFix) > 0		
			
			//gera o valor - pergunta se está ok
			if MsgYesNo(IIF(lVincN8D, STR0045+" ","") + STR0040 + alltrim(str(len(aListFix))) + STR0031) 
			
				BEGIN TRANSACTION
								
					dbSelectArea( "NN8" )
					dbSetOrder( 1 ) //Filial+CodCtr+Item
					
					For nX := 1 to Len(aListFix)
						
						if lRetorno
							
							aRecnos := fGetFixAgl(_cFilOrg, aListFix[nX][1], aListFix[nX][2]) //retorna os itens selecionados
							
							//desmonta os lances
							For nY := 1 to Len(aRecnos)
								
								IF (Select("NN8") == 0)
									DbSelectArea("NN8")
								endif
		
								NN8->(dbGoto(aRecnos[nY]))
								RecLock( "NN8", .F. )								
									//refaz os saldos
									NN8->NN8_QTDFIX += NN8->NN8_QTDAGL
									NN8->NN8_QTDAGL := 0 //reset
									NN8->NN8_AGLUTI := ""												
								NN8->(MsUnLock())	
								
							next nY
							
							IF (Select("NN8") == 0)
								DbSelectArea("NN8")
							endif														
							dbSetOrder( 1 ) //Filial+CodCtr+Item
													
							if NN8->(dbSeek(_cFilOrg + aListFix[nX][1] + aListFix[nX][2]))
								
								//reset na fixação aglutinada
								
								RecLock( "NN8", .F. )
								
									NN8->NN8_QTDFIX := 0   //reset quantidade
									NN8->NN8_QTDRES	:= 0   //Zerando a Qtidade Vinculada, pois será movida para a nova fixação
								             
								NN8->(MsUnLock())
								
							else
								lRetorno := .f.
							endif
							
							//realizar a remoção de fardos e priorização..
							IF (Select("N8D") == 0)
								DbSelectArea("N8D")
							endif	
							
							N8D->( dbSetOrder(2) ) 	//N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D->N8D_SEQVNC
							if N8D->(DbSeek(fwxFilial("N8D") + aListFix[nX][1] + aListFix[nX][2]))
								
								while N8D->( !Eof() ) .and. N8D->N8D_FILIAL == fwxFilial("N8D") .and. N8D->N8D_CODCTR == aListFix[nX][1] .and.  N8D->N8D_ITEMFX == aListFix[nX][2] 
																		
									//limpa os relacionamentos na dxi
									if lAlgodao
										
										aRecnos := fGetFrdVnc(aListFix[nX][1] , aListFix[nX][2], N8D->N8D_SEQVNC, N8D->N8D_BLOCO, N8D->N8D_FILORG)
										
										For nY := 1  to len(aRecnos)
											IF (Select("DXI") == 0)
												DbSelectArea("DXI")
											endif
					
											DXI->(dbGoto(aRecnos[nY]))
											
											//lista fardos desabilitados
											aAdd(aFarInativ,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{DXI->DXI_FILIAL},; // Filial Origem Fardo
																		 {_cFilOrg},; // FILIAL CTR
																		 {DXI->DXI_SAFRA},; // Safra
																		 {DXI->DXI_ETIQ},; // Etiqueta do Fardo
																		 {"03"},; // Tipo de Movimentação ("03" - Fixação)
																		 {"2"}} }) // Código do Contrato
											
											RecLock( "DXI", .F. )
												DXI->DXI_ITEMFX := ""
												DXI->DXI_ORDENT := ""
												DXI->DXI_VLBASE := 0
											DXI->(MsUnLock())
										next nY													
										
									endif										
									
									If RecLock( "N8D", .F. )
										N8D->( dbDelete() )
										N8D->( MsUnlock('N8D') )
									EndIF																	
									
									N8D->( dbSkip() )
								enddo
															
							endif		

							//Faço novamente após excluir a N8D da aglutinação
							For nY := 1 to Len(aRecnos)
								
								IF (Select("NN8") == 0)
									DbSelectArea("NN8")
								endif
		
								NN8->(dbGoto(aRecnos[nY]))
								
									nQtdPrior := NN8->NN8_QTDFIX		

									//listaRegras 
									aRegrasFis := OGA570SLRG(FwxFilial("N8D"), NN8->NN8_CODCTR, NN8->NN8_CODCAD )  
									
									nSeqAprop := OGX720N8DS( FwxFilial("NJR") , NN8->NN8_CODCTR, NN8->NN8_ITEMFX ) //Verifica a ultima sequencia (N8D_SEQVNC) que existepara a fixação a ser criada
									nSeqAprop := PadL(nSeqAprop, TamSX3( "N8D_SEQVNC" )[1], "0") 	

									For nB := 1 to len(aRegrasFis)
										if aRegrasFis[nB][2] > 0 .and. nQtdPrior > 0 
											//cria automaticamente a N8D se for granel...
											nSeqAprop  := Soma1(nSeqAprop)
															
											//Criando novo registo da N8D
											dbSelectArea("N8D")
											RecLock("N8D", .t.) // Se existir irei ( adicionar o bloco e seus fardos ao  vinculo, senao irei criar um novo vinculo)
												N8D->N8D_FILIAL	:= FwxFilial("N8D")
												N8D->N8D_CODCTR	:= NN8->NN8_CODCTR
												N8D->N8D_ITEMFX	:= PadL(cValToChar(NN8->NN8_ITEMFX), TamSX3( "N8D_ITEMFX" )[1], "0")
												N8D->N8D_SEQVNC	:= nSeqAprop
												N8D->N8D_ORDEM	:= nSeqAprop //usa a mesma vinculação do campo de sequencia
												N8D->N8D_VALOR	:= NN8->NN8_VLRUNI
												N8D->N8D_REGRA	:= aRegrasFis[nB][1] 
												N8D->N8D_CODCAD	:= NN8->NN8_CODCAD
												
												if nQtdPrior > aRegrasFis[nB][2] 
													N8D->N8D_QTDVNC := aRegrasFis[nB][2]
													nQtdPrior -= aRegrasFis[nB][2]
												else
													N8D->N8D_QTDVNC := nQtdPrior
													nQtdPrior := 0 //sem saldo	
												endif														
											N8D->(MsUnLock())																	
										endif
									next nB
							next nY


						endif										
					next nx	
					
					//grava os fardos
					if lRetorno .and. len(aFarInativ) > 0
						aRetorno := AGRMOVFARD(, 2, 2, , aFarInativ) // Inativa os fardos removidos	
						if !empty(aRetorno[2])
							DisarmTransaction()
							Help( , , STR0001, , aRetorno[2], 1, 0 )  //erro gravação de fardo
							lRetorno := .f.
						endif
						
						//refaz o calculo de ágio e deságio
						Processa({|| OGX016(_cFilOrg, _cCodCtr) }, STR0046)	
						
					endif 			
											
					if !lRetorno
						DisarmTransaction()
						Help( , , STR0001, , STR0041, 1, 0 )
						lRetorno := .f.	
					else
						MsgInfo(STR0042, STR0043)
					endif
					
				END TRANSACTION
				
				if lRetorno 					
					OGX055(_cFilOrg, _cCodCtr)	//Recalcula Valores da regra FISCAL		
				endif
				
				//reload na tabela
				fLoadDados()	
				
			endif
				
		else
			Help( , , STR0001, , STR0044, 1, 0 )
			lRetorno := .f.	
		endif
	endif
	
	OGX720UP(_oBrowse1, .t.)
	
return lRetorno

/*{Protheus.doc} fGetFixAgl
//retorna os recnos utilizados
@author jean.schulze
@since 15/12/2017
@version 1.0
@return ${return}, ${return_description}
@param cFilNN8, characters, descricao
@param cCodCtr, characters, descricao
@param cItemFx, characters, descricao
@type function
*/
Static Function fGetFixAgl(cFilNN8, cCodCtr, cItemFx )
	Local cAliasNN8  := GetNextAlias()
	Local aRecnos    := {}
		
	BeginSql Alias cAliasNN8

		SELECT NN8.R_E_C_N_O_ as NN8_RECNO
	  	  FROM %Table:NN8% NN8 
		WHERE NN8.%notDel%
		  AND NN8.NN8_FILIAL = %exp:cFilNN8% 
		  AND NN8.NN8_CODCTR = %exp:cCodCtr%
		  AND NN8.NN8_AGLUTI = %exp:cItemFx% //aglutinadas
		 		         		           
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	while ( cAliasNN8 )->( !Eof() )
	 	
	 	aAdd(aRecnos, (cAliasNN8 )->NN8_RECNO )  
	 	
		( cAliasNN8 )->( dbSkip() )
	EndDo
	
	( cAliasNN8 )->( dbCloseArea() )
	
return (aRecnos)


