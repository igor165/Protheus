#Include 'OGC080.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWBrowse.ch'
#DEFINE CRLF CHR(13)+CHR(10)

Static __cTabReg	:= "" //Tabela Temporária de Regras BCI
Static __cTabBlc	:= "" //Tabela Temporária de Blocos
Static __cTabFar	:= "" //Tabela Temporária de Fardos

/*{Protheus.doc} OGC080
Consulta de Fardos e Blocos do Contrato
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@param pcCodCtr, , descricao
@type function
*/
function OGC080(pcCodCtr)
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local aFilBrowBlc := {}
	Local aFilBrowFar := {}
	Local nCont       := 0
	Local aButtons    := {}

	Private _cCodCtr := pcCodCtr //contrato selecionado
	Private _oBrowseReg  := Nil
	Private _oBrowse1	 := Nil
	Private _oBrowse2    := Nil

	//----- Proteção para chamadas atraves do Menu
	//- Realizada a proteção para MERGE com MAIN
	If Empty(pcCodCtr)
		Help('',1,"AGRNOEXISTFUN") //"Função não disponível para Menu.
		Return()
	EndIf
	//------------------------------------------------------------------

	If !OGC080EBCI(pcCodCtr) //caso não exista regra BCI com vinculação de blocos e fardos, não abre a tela
		return
	EndIf

	//campos Regra BCI
	aCpsBrowReg := {{STR0002 , "N78_FILIAL"	, TamSX3( "N78_FILIAL" )[3]	, TamSX3( "N78_FILIAL" )[1]	, TamSX3( "N78_FILIAL" )[2]	, PesqPict("N78","N78_FILIAL") 	},; //Contrato
					{STR0050 , "N78_CODCTR"	, TamSX3( "N78_CODCTR" )[3]	, TamSX3( "N78_CODCTR" )[1]	, TamSX3( "N78_CODCTR" )[2]	, PesqPict("N78","N78_CODCTR") 	},; //Contrato
					{STR0051 , "N78_SEQUEN"	, TamSX3( "N78_SEQUEN" )[3]	, TamSX3( "N78_SEQUEN" )[1]	, TamSX3( "N78_SEQUEN" )[2]	, PesqPict("N78","N78_SEQUEN") },;  //Sequencia
					{STR0052 , "N78_OUTCOD"	, TamSX3( "N78_OUTCOD" )[3]	, TamSX3( "N78_OUTCOD" )[1]	, TamSX3( "N78_OUTCOD" )[2]	, PesqPict("N78","N78_OUTCOD") },;  //Código do desconto
					{STR0053 , "N78_OUTDES"	, TamSX3( "N78_OUTDES" )[3]	, TamSX3( "N78_OUTDES" )[1]	, TamSX3( "N78_OUTDES" )[2]	, PesqPict("N78","N78_OUTDES") },;  //Descrição ágio/deságil
					{STR0054 , "N78_OUTPER"	, TamSX3( "N78_OUTPER" )[3]	, TamSX3( "N78_OUTPER" )[1]	, TamSX3( "N78_OUTPER" )[2]	, PesqPict("N78","N78_OUTPER") },;  //Percentual do contrato
					{STR0055 , "N78_OUTREG"	, TamSX3( "N78_OUTREG" )[3]	, TamSX3( "N78_OUTREG" )[1]	, TamSX3( "N78_OUTREG" )[2]	, PesqPict("N78","N78_OUTREG") }}   //Regra

	//campos blocos
	aCpsBrowBlc := {{STR0017 , "DXP_STATUS"	, TamSX3( "DXP_STATUS" )[3]	, TamSX3( "DXP_STATUS" )[1]	, TamSX3( "DXP_STATUS" )[2]	, PesqPict("DXP","DXP_STATUS") 	},; //"Qtd. Take-Up"
					{STR0043 , "TMP_QTDFAR" , "N" ,  4, , "@" },; //Qtd. Fardo
					{STR0001 , "DXP_ITECAD"	, TamSX3( "DXP_ITECAD" )[3]	, TamSX3( "DXP_ITECAD" )[1]	, TamSX3( "DXP_ITECAD" )[2]	, PesqPict("DXP","DXP_ITECAD") 	},;
					{STR0002 , "DXD_FILIAL"	, TamSX3( "DXD_FILIAL" )[3]	, TamSX3( "DXD_FILIAL" )[1]	, TamSX3( "DXD_FILIAL" )[2]	, PesqPict("DXD","DXD_FILIAL") 	},;	//"Reserva"
			        {STR0003 , "DXD_CODIGO"	, TamSX3( "DXD_CODIGO" )[3]	, TamSX3( "DXD_CODIGO" )[1]	, TamSX3( "DXD_CODIGO" )[2]	, PesqPict("DXD","DXD_CODIGO") 	},;	//"Reserva"
			        {STR0011 , "DXP_CODIGO"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},;
					{STR0056 , "DXP_TIPRES"	, TamSX3( "DXP_TIPRES" )[3]	, TamSX3( "DXP_TIPRES" )[1]	, TamSX3( "DXP_TIPRES" )[2]	, PesqPict("DXD","DXP_TIPRES") 	},;  //"Tipo da Reserva"
					{STR0004 , "DXD_CLACOM"	, TamSX3( "DXD_CLACOM" )[3]	, TamSX3( "DXD_CLACOM" )[1]	, TamSX3( "DXD_CLACOM" )[2]	, PesqPict("DXD","DXD_CLACOM") 	},;	//"Reserva"
					{STR0005 , "DXD_SAFRA"	, TamSX3( "DXD_SAFRA" )[3]	, TamSX3( "DXD_SAFRA" )[1]	, TamSX3( "DXD_SAFRA" )[2]	, PesqPict("DXD","DXD_SAFRA") 	}}  //"Qtd. Take-Up"

	//campos Fardos
	aCpsBrowFar := {{STR0027 , "DXP_RECNO"  , "N", 18, 0, "@ 9999999999"},; //recno reserva
					{STR0028 , "DXI_RECNO"  , "N", 18, 0, "@ 9999999999"},; //recno fardo
					{STR0017 , "DXP_STATUS"	, TamSX3( "DXP_STATUS" )[3]	, TamSX3( "DXP_STATUS" )[1]	, TamSX3( "DXP_STATUS" )[2]	, PesqPict("DXP","DXP_STATUS") 	},; //"Qtd. Take-Up"
					{STR0001 , "DXP_ITECAD"	, TamSX3( "DXP_ITECAD" )[3]	, TamSX3( "DXP_ITECAD" )[1]	, TamSX3( "DXP_ITECAD" )[2]	, PesqPict("DXP","DXP_ITECAD") 	},;
					{STR0002 , "DXI_FILIAL"	, TamSX3( "DXI_FILIAL" )[3]	, TamSX3( "DXI_FILIAL" )[1]	, TamSX3( "DXI_FILIAL" )[2]	, PesqPict("DXI","DXI_FILIAL") 	},;	//"Reserva"
			        {STR0006 , "DXI_CODIGO"	, TamSX3( "DXI_CODIGO" )[3]	, TamSX3( "DXI_CODIGO" )[1]	, TamSX3( "DXI_CODIGO" )[2]	, PesqPict("DXI","DXI_CODIGO") 	},;	//"Reserva"
			        {STR0003 , "DXI_BLOCO"	, TamSX3( "DXI_BLOCO" )[3]	, TamSX3( "DXI_BLOCO" )[1]	, TamSX3( "DXI_BLOCO" )[2]	, PesqPict("DXI","DXI_BLOCO") 	},;	//"Reserva"
			        {STR0011 , "DXP_CODIGO"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},;
					{STR0004 , "DXI_CLACOM"	, TamSX3( "DXI_CLACOM" )[3]	, TamSX3( "DXI_CLACOM" )[1]	, TamSX3( "DXI_CLACOM" )[2]	, PesqPict("DXI","DXI_CLACOM") 	},;	//"Reserva"
			        {STR0005 , "DXI_SAFRA"	, TamSX3( "DXI_SAFRA" )[3]	, TamSX3( "DXI_SAFRA" )[1]	, TamSX3( "DXI_SAFRA" )[2]	, PesqPict("DXI","DXI_SAFRA") 	}}

	Processa({|| __cTabReg := MonTabelas(aCpsBrowReg, {{"", "N78_FILIAL+N78_CODCTR+N78_SEQUEN+N78_OUTCOD"}})},STR0018)
	Processa({|| __cTabBlc := MonTabelas(aCpsBrowBlc, {{"", "DXD_FILIAL+DXD_SAFRA+DXD_CODIGO"}})},STR0018)
	Processa({|| __cTabFar := MonTabelas(aCpsBrowFar, {{"", "DXI_FILIAL+DXI_SAFRA+DXI_BLOCO+DXP_CODIGO+DXI_CODIGO"}})},STR0018)

	Processa({|| fGetDados()},STR0019)

	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0008, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta Blocos e Fardos

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine( 'TOP' , 30 , .F.)
	oFWL:addCollumn( 'TOPALL'  ,100  ,.F., 'TOP' )

	oFWL:addWindow( 'TOPALL' , 'TOP1', "Regras BCI",  100 /*tamanho*/, .F., .T.,, 'TOP' )
	oPnlTop1:= oFWL:getWinPanel( 'TOPALL' , 'TOP1', 'TOP' )

	oFWL:addLine( 'MASTER'   , 70 , .F.)
	oFWL:addCollumn( 'LEFT'  ,50  ,.F., 'MASTER' )
	oFWL:addCollumn( 'RIGHT' , 50 ,.F., 'MASTER' )

	oFWL:setColSplit ( 'LEFT', 1,  'MASTER' )
	oFWL:setColSplit ( 'RIGHT', 2,  'MASTER' )

	//cria as janelas
	oFWL:addWindow( 'LEFT' , 'Wnd1', STR0009,  100 /*tamanho*/, .F., .T.,, 'MASTER' )
	oFWL:addWindow( 'RIGHT', 'Wnd2', STR0010,  100 /*tamanho*/, .F., .T.,, 'MASTER' )

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'LEFT' , 'Wnd1', 'MASTER' )
	oPnlWnd2:= oFWL:getWinPanel( 'RIGHT', 'Wnd2', 'MASTER' )


	/****************** REGRAS BCI ********************************/
	//adicionando os widgets de tela
	_oBrowseReg := FWMBrowse():New()
    _oBrowseReg:SetAlias(__cTabReg)
    _oBrowseReg:DisableDetails()
    _oBrowseReg:SetMenuDef( "" )
    _oBrowseReg:DisableReport(.T.)
    _oBrowseReg:DisableSeek(.T.)
    _oBrowseReg:SetProfileID("IDBWSEREG")
    _oBrowseReg:SetChange({|cSequencia|OGC080BLC((__cTabReg)->N78_SEQUEN)})

    For nCont := 1  to Len(aCpsBrowReg)
        _oBrowseReg:AddColumn( {aCpsBrowReg[nCont][1], &("{||"+aCpsBrowReg[nCont][2]+"}")  ,aCpsBrowReg[nCont][3],aCpsBrowReg[nCont][6],1,aCpsBrowReg[nCont][4],aCpsBrowReg[nCont][5],.F.} )
        aADD(aCpsBrowReg,  {aCpsBrowReg[nCont][1], aCpsBrowReg[nCont][2], aCpsBrowReg[nCont][3], aCpsBrowReg[nCont][4], aCpsBrowReg[nCont][5], aCpsBrowReg[nCont][6] } )
    Next nCont

    _oBrowseReg:SetFieldFilter(aCpsBrowReg)
    _oBrowseReg:Activate(oPnlTop1)

	/****************** BLOCOS ********************************/
	//adicionando os widgets de tela
	_oBrowse1 := FWMBrowse():New()
    _oBrowse1:SetAlias(__cTabBlc)
    _oBrowse1:DisableDetails()
    _oBrowse1:SetMenuDef( "" )
    _oBrowse1:DisableReport(.T.)
    _oBrowse1:DisableSeek(.T.)
    _oBrowse1:SetProfileID("IDBWSEBLC")
    _oBrowse1:SetChange({ |cSequenciaFar,cBloco| OGC080FAR((__cTabReg)->N78_SEQUEN, (__cTabBlc)->DXD_FILIAL,  (__cTabBlc)->DXD_CODIGO)})

    For nCont := 5  to Len(aCpsBrowBlc) //desconsiderar MARK, STATUS, QTD_FARDO, MENSAGEM
        _oBrowse1:AddColumn( {aCpsBrowBlc[nCont][1]  , &("{||"+aCpsBrowBlc[nCont][2]+"}") ,aCpsBrowBlc[nCont][3],aCpsBrowBlc[nCont][6],1,aCpsBrowBlc[nCont][4],aCpsBrowBlc[nCont][5],.f.} )
        aADD(aFilBrowBlc,  {aCpsBrowBlc[nCont][2], aCpsBrowBlc[nCont][1], aCpsBrowBlc[nCont][3], aCpsBrowBlc[nCont][4], aCpsBrowBlc[nCont][5], aCpsBrowBlc[nCont][6] } )
    Next nCont

    _oBrowse1:SetFieldFilter(aFilBrowBlc)
    _oBrowse1:Activate(oPnlWnd1)


	/****************** FARDOS ********************************/
	_oBrowse2 := FWMBrowse():New()
    _oBrowse2:DisableReport(.T.)
    _oBrowse2:DisableDetails()
    _oBrowse2:SetAlias(__cTabFar)
    _oBrowse2:SetMenuDef( "" )
    _oBrowse2:DisableReport(.T.)
    _oBrowse2:DisableSeek(.T.)
    _oBrowse2:SetProfileID("IDBWSEFAR")

    For nCont := 6  to Len(aCpsBrowFar) //desconsiderar Mark, Status, Recno Reserva,  Recno Fardo e Mensagem
        _oBrowse2:AddColumn( {aCpsBrowFar[nCont][1]  , &("{||"+aCpsBrowFar[nCont][2]+"}") ,aCpsBrowFar[nCont][3],aCpsBrowFar[nCont][6],1,aCpsBrowFar[nCont][4],aCpsBrowFar[nCont][5],.f.} )
        aADD(aFilBrowFar, {aCpsBrowFar[nCont][2], aCpsBrowFar[nCont][1], aCpsBrowFar[nCont][3], aCpsBrowFar[nCont][4], aCpsBrowFar[nCont][5], aCpsBrowFar[nCont][6]})
    Next nCont

    _oBrowse2:SetFieldFilter(aFilBrowFar)
    _oBrowse2:Activate(oPnlWnd2)

    //cria os botões adicionais
    Aadd( aButtons, {STR0058, {|| GetFardos(),OGC080BLC((__cTabReg)->N78_SEQUEN),OGC080FAR((__cTabReg)->N78_SEQUEN, (__cTabBlc)->DXD_FILIAL,  (__cTabBlc)->DXD_CODIGO)}, STR0058, STR0058 , {|| .T.}} ) //"Selecionar Fardos"

	oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, , {||  oDlg:End() } /*Fechar*/,,@aButtons,,,.f.,.f.,.f.,.f.,.f.) )

return

/** {Protheus.doc} MonTabelas
Função que monta as Temp-Tables da Rotina
@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     24/07/2017
@Uso:       OGC080
*/
Static Function MonTabelas(aCpsBrow, aIdxTab)
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


/*{Protheus.doc} OGC080
Verifica se existe rebra BCI com vinculação de fardos pro contrato
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@param pcCodCtr, , descricao
@type function
*/
function OGC080EBCI(pcCodCtr)

Local cAliasBCI	 := GetNextAlias()
Local cFiltro    := ""


	cFiltro += " AND N78.N78_FILIAL = '"+ FWxFilial("NJR")+"' " +;
			   " AND N78.N78_CODCTR = '"+_cCodCtr+"' "  + ;
	           " AND N7K.N7K_VINCUL = '2' " +  ; //Se a regra Vilcula blocos
			   " AND N7K.N7K_SITUAC = '1'"  +  ;  //Se a regra está Ativa
			   " AND N78.N78_APLICA = '3'"      //Se a regra é BCI
	cFiltro := "%" + cFiltro + "%"

	//monta a query de busca
	BeginSql Alias cAliasBCI

        SELECT N78_CODCTR
		  FROM %Table:N78% N78
		  INNER JOIN %Table:N7K% N7K ON  N7K.N7K_CODIGO  = N78.N78_OUTCOD
	    				             AND N7K.N7K_FILIAL = %exp:FWxFilial('N7K')%
		  							 AND N7K.%notDel%
	    WHERE N78.%notDel%
		      %exp:cFiltro%
		ORDER BY N78.N78_SEQUEN

	EndSQL


	If Empty((cAliasBCI)->N78_CODCTR)
		msgalert(STR0057)
		(cAliasBCI)->(dbCloseArea())

		Return .F.
	EndIf

	(cAliasBCI)->(dbCloseArea())

return .T.

/*{Protheus.doc} fGetDados
Popula blocos e Fardos
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function fGetDados

	OGC080EXTMP() //limpa as temporárias
	OGC080N78()   //Seleciona as regras e carrega a temporária de regras (__cTabReg)

return .t.

/*{Protheus.doc} OGC080N78
Monta a consulta das regras BCI e carrega a temporária __cTabReg do browse de regras
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function OGC080N78()

Local cAliasN87	 := GetNextAlias()
Local cFiltro    := ""


	cFiltro += " AND N78.N78_FILIAL = '"+ FWxFilial("NJR")+ "' "  + ;
			   " AND N78.N78_CODCTR = '"+_cCodCtr+"' "  + ;
	           " AND N7K.N7K_VINCUL = '2' " +  ; //Se a regra Vilcula blocos
			   " AND N7K.N7K_SITUAC = '1'"  + ;     //Se a regra está Ativa
			   " AND N78.N78_APLICA = '3'"      //Se a regra é BCI

	cFiltro := "%" + cFiltro + "%"

	//monta a query de busca
	BeginSql Alias cAliasN87

        SELECT N78_FILIAL, N78_CODCTR, N78_SEQUEN, N78_OUTCOD, N7K_DESCRI, N78_OUTPER
		  FROM %Table:N78% N78
		  INNER JOIN %Table:N7K% N7K ON  N7K.N7K_CODIGO  = N78.N78_OUTCOD
	    				             //AND N7K.N7K_FILIAL = N78.N78_FILIAL
		  							 AND N7K.%notDel%
	    WHERE N78.%notDel%
		      %exp:cFiltro%
		ORDER BY N78.N78_SEQUEN

	EndSQL

    //apropriação de dados
	DbselectArea( cAliasN87 )
	DbGoTop()

	While ( cAliasN87 )->( !Eof() )
		RecLock((__cTabReg),.T.)

			(__cTabReg)->N78_FILIAL	:= (cAliasN87)->N78_FILIAL
			(__cTabReg)->N78_CODCTR	:= (cAliasN87)->N78_CODCTR
			(__cTabReg)->N78_SEQUEN	:= (cAliasN87)->N78_SEQUEN
			(__cTabReg)->N78_OUTCOD	:= (cAliasN87)->N78_OUTCOD
			(__cTabReg)->N78_OUTDES := (cAliasN87)->N7K_DESCRI
			(__cTabReg)->N78_OUTPER	:= (cAliasN87)->N78_OUTPER

		MsUnlock()
		(cAliasN87)->(dbSkip())
	EndDo

	(cAliasN87)->(dbCloseArea())

return

/*{Protheus.doc} OGC080BLC
Monta a consulta dos blocos e carrega a temporária __cTabBlc do browse de Blocos
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function OGC080BLC(cSeqRegra)

Local cAliasBlc	 := GetNextAlias()
Local cFiltro    := ""

	cFiltro += " AND N87.N87_SEQUEN = '" + cSeqRegra+"' " + ;
			   " AND N87.N87_CODCTR = '" + _cCodCtr + "' " + ;
			   " AND N87.N87_FILIAL = '" + fwXfilial("N87") + "' " +;
			   " AND DXP.DXP_CODCTP = '" + _cCodCtr + "' " + ;
			   " AND DXP.DXP_FILIAL = '" + fwXfilial("DXP") + "' "
			  
	cFiltro := "%" + cFiltro + "%"
	// " AND N87.N87_FILIAL = '" + FWxFilial("N87") + "' " + ;

	//monta a query de busca
	BeginSql Alias cAliasBlc

       SELECT DISTINCT DXD.DXD_FILIAL, DXD.DXD_CODIGO, DXP_TIPRES, DXD.DXD_CLACOM, DXD.DXD_SAFRA, DXP_ITECAD, DXP_FILIAL, DXP_CODIGO,
	   DXP_STATUS, DXD.R_E_C_N_O_  DXPRECNO
		  FROM %Table:DXD% DXD
		  INNER JOIN %Table:DXI% DXI ON  DXI.DXI_FILIAL = DXD.DXD_FILIAL
		                             AND DXI.DXI_SAFRA  = DXD.DXD_SAFRA
		                             AND DXI.DXI_BLOCO  = DXD.DXD_CODIGO
                     		         AND DXI.%notDel%
          INNER JOIN %Table:DXQ% DXQ ON  DXQ.DXQ_BLOCO  = DXI.DXI_BLOCO
						             AND DXQ.DXQ_FILORG = DXI.DXI_FILIAL
							         AND DXQ.DXQ_CODRES = DXI.DXI_CODRES
							         AND DXQ.DXQ_ITEM   = DXI.DXI_ITERES
					 	             AND DXQ.%notDel%           		         
          INNER JOIN %Table:DXP% DXP ON  DXP.DXP_CODIGO = DXQ.DXQ_CODRES
				 	                 AND DXP.DXP_FILIAL = DXQ.DXQ_FILIAL
				 	                 AND DXP.%notDel%           		         
		  INNER JOIN %Table:N87% N87 ON  N87.N87_SAFRA  = DXI.DXI_SAFRA
		                             AND N87.N87_ETIQ   = DXI.DXI_ETIQ  
		                             AND N87.N87_FILORG = DXI.DXI_FILIAL  
                     		         AND N87.%notDel%
		WHERE DXD.%notDel%
		      %exp:cFiltro%
		ORDER BY DXD.DXD_CODIGO

	EndSQL
	
    OGC080DLTMP('__cTabBlc')
    OGC080DLTMP('__cTabFar')
 	//apropriação de dados
	DbselectArea( cAliasBlc )
	DbGoTop()

	While ( cAliasBlc )->( !Eof() )
		RecLock((__cTabBlc),.T.)

			(__cTabBlc)->DXP_ITECAD	:= (cAliasBlc)->DXP_ITECAD
			(__cTabBlc)->DXP_STATUS	:= (cAliasBlc)->DXP_STATUS
			(__cTabBlc)->DXD_FILIAL	:= (cAliasBlc)->DXD_FILIAL
			(__cTabBlc)->DXD_CODIGO := (cAliasBlc)->DXD_CODIGO
			(__cTabBlc)->DXP_CODIGO	:= (cAliasBlc)->DXP_CODIGO
			(__cTabBlc)->DXP_TIPRES	:= (cAliasBlc)->DXP_TIPRES
			(__cTabBlc)->DXD_CLACOM	:= (cAliasBlc)->DXD_CLACOM
			(__cTabBlc)->DXD_SAFRA	:= (cAliasBlc)->DXD_SAFRA
			//(__cTabBlc)->NJR_VLRBAS	:= (cAliasBlc)->NJR_VLRBAS
			//(__cTabBlc)->TMP_PSLIQU	:= (cAliasBlc)->PSLIQU

		MsUnlock()

		(cAliasBlc)->(dbSkip())
	EndDo

	(cAliasBlc)->(dbCloseArea())

	If ValType(_oBrowse1) == 'O'
		//_oBrowse2:UpdateBrowse()
		_oBrowse1:Refresh()
		_oBrowse1:GoTop()
	EndIf

	If ValType(_oBrowse2) == 'O'
		//_oBrowse2:UpdateBrowse()
		OGC080FAR((__cTabReg)->N78_SEQUEN, (__cTabBlc)->DXD_FILIAL, (__cTabBlc)->DXD_CODIGO)
		_oBrowse2:UpdateBrowse()
		_oBrowse2:Refresh(.T.)
		_oBrowse2:GoTop()
	EndIf

return

/*{Protheus.doc} OGC080FAR
Monta a consulta dos fardos e carrega a temporária __cTabFar do browse de Fardos
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function OGC080FAR(cSeqRegra, cFilOrg, cBloco)

Local cAliasFar	 := GetNextAlias()
Local cFiltro    := ""

	cFiltro += " AND N87.N87_FILIAL = '" + FwXfilial("N87")+"' " + ;
			   " AND N87.N87_CODCTR = '" + _cCodCtr+"' " + ;
			   " AND N87.N87_SEQUEN = '" + cSeqRegra+"' " + ;
			   " AND DXQ.DXQ_BLOCO  = '" + cBloco+"' " + ;
			   " AND DXQ.DXQ_FILORG = '" + cFilOrg+"' " + ;
			   " AND DXP.DXP_FILIAL = '" + FwXfilial("DXP")+"' " + ;
			   " AND DXP.DXP_CODCTP = '" + _cCodCtr +"' "
	cFiltro := "%" + cFiltro + "%"


	//monta a query de busca
	BeginSql Alias cAliasFar

       SELECT DXP_STATUS, DXP_ITECAD, DXI_FILIAL,
              DXI_CODIGO, DXI_BLOCO, DXP_CODIGO,DXI_CLACOM, DXI_SAFRA
		  FROM %Table:DXD% DXD
		  INNER JOIN %Table:DXI% DXI ON  DXI.DXI_FILIAL = DXD.DXD_FILIAL
		                             AND DXI.DXI_SAFRA  = DXD.DXD_SAFRA
		                             AND DXI.DXI_BLOCO  = DXD.DXD_CODIGO
                     		         AND DXI.%notDel%
          INNER JOIN %Table:DXQ% DXQ ON  DXQ.DXQ_BLOCO  = DXI.DXI_BLOCO
						             AND DXQ.DXQ_FILORG = DXI.DXI_FILIAL
							         AND DXQ.DXQ_CODRES = DXI.DXI_CODRES
							         AND DXQ.DXQ_ITEM   = DXI.DXI_ITERES
					 	             AND DXQ.%notDel%           		         
          INNER JOIN %Table:DXP% DXP ON  DXP.DXP_CODIGO = DXQ.DXQ_CODRES
				 	                 AND DXP.DXP_FILIAL = DXQ.DXQ_FILIAL
				 	                 AND DXP.%notDel%           		         
		  INNER JOIN %Table:N87% N87 ON  N87.N87_SAFRA  = DXI.DXI_SAFRA
		                             AND N87.N87_ETIQ   = DXI.DXI_ETIQ  
		                             AND N87.N87_FILORG = DXI.DXI_FILIAL  
                     		         AND N87.%notDel%
		WHERE DXD.%notDel%
		      %exp:cFiltro%
		ORDER BY DXI.DXI_CODIGO

	EndSQL

	OGC080DLTMP('__cTabFar')

	DbselectArea( cAliasFar )
	DbGoTop()

	While ( cAliasFar )->( !Eof() )
		RecLock((__cTabFar),.T.)

 			(__cTabFar)->DXP_STATUS := (cAliasFar)->DXP_STATUS
			(__cTabFar)->DXP_ITECAD := (cAliasFar)->DXP_ITECAD
			(__cTabFar)->DXI_FILIAL := (cAliasFar)->DXI_FILIAL
			(__cTabFar)->DXI_CODIGO := (cAliasFar)->DXI_CODIGO
			(__cTabFar)->DXI_BLOCO  := (cAliasFar)->DXI_BLOCO
			(__cTabFar)->DXP_CODIGO := (cAliasFar)->DXP_CODIGO
			(__cTabFar)->DXI_CLACOM := (cAliasFar)->DXI_CLACOM
			(__cTabFar)->DXI_SAFRA  := (cAliasFar)->DXI_SAFRA

		MsUnlock()

		(cAliasFar)->(dbSkip())
	EndDo

	(cAliasFar)->(dbCloseArea())

	If ValType(_oBrowse2) == 'O'
		//_oBrowse2:UpdateBrowse()
		_oBrowse2:Refresh(.T.)
		_oBrowse2:GoTop()
	EndIf

return

/*{Protheus.doc} OGC080EXTMP
Limpa as tabelas temporárias __cTabReg, __cTabFar ou __cTabBlc
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function OGC080DLTMP(cTabela)


    If cTabela == '__cTabReg'
		//--Deleta tudo da temporaria para realizar nova busca de blocos
		DbSelectArea((__cTabReg))
		DbGoTop()
		If DbSeek((__cTabReg)->N78_FILIAL)
			While !(__cTabReg)->(Eof())

				If RecLock((__cTabReg),.f.)
					(__cTabReg)->(DbDelete())
					(__cTabReg)->(MsUnlock())
				EndIf
				(__cTabReg)->( dbSkip() )
			EndDo
		EndIF
	ElseIf cTabela == '__cTabBlc'
			//--Deleta tudo da temporaria para realizar nova busca de blocos
			DbSelectArea((__cTabBlc))
			DbGoTop()
			If DbSeek((__cTabBlc)->DXD_FILIAL)
				While !(__cTabBlc)->(Eof())

					If RecLock((__cTabBlc),.f.)
						(__cTabBlc)->(DbDelete())
						(__cTabBlc)->(MsUnlock())
					EndIf
					(__cTabBlc)->( dbSkip() )
				EndDo
			EndIF

	Else //cTabela == '__cTabFar'
		//--Deleta tudo da temporaria para realizar nova busca de fardos
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL)
			While !(__cTabFar)->(Eof())

				If RecLock((__cTabFar),.f.)
					(__cTabFar)->(DbDelete())
					(__cTabFar)->(MsUnlock())
				EndIf
				(__cTabFar)->( dbSkip() )
			EndDo
		EndIF
	EndIf
Return

/*{Protheus.doc} OGC080EXTMP
Limpa as tabelas temporárias
@author Daniel Maniglia
@since 21/09/2017
@version undefined
@type function
*/
static function OGC080EXTMP()

	//--Deleta tudo da temporaria para realizar nova busca de regras
	If Select(__cTabReg) == 0
		DbSelectArea((__cTabReg))
		ZAP  //exclui todos os registros da tabela temporária
	EndIf

    If Select(__cTabBlc) == 0
		DbSelectArea((__cTabBlc))
		ZAP
	EndIf

    If Select(__cTabFar) == 0
		DbSelectArea((__cTabFar))
		ZAP
	EndIf

return


/*{Protheus.doc} GetFardos
Executa a funcao de Busca de Blocos e Fardos AGRX720 e
no retorno grava os dados na tabela
@author Marcelo Ferrari
@since 15/09/2017
@version undefined
@param
@type function
*/
Static Function GetFardos()
	Local aArea := GetArea()
	Local cCodCtr 	:= _cCodCtr
	Local cSafra	:= "" //(__cTabBlc)->DXD_SAFRA
	Local cTiposCtr := ""
	Local aFilHVI   := {}
	Local aFarSelec := {}
	Local nCont     := 0
	Local nQtdCad   := 0
	Local nTolen    := 0
	Local aOptions  := {}
	
	//só chama se o contrato foi preenchido
	if !empty(cCodCtr)

     	If Select("NJR") = 0
     	   DbSelectArea("NJR")
     	EndIf

     	NJR->(DbGoTop())
     	If NJR->(dBSeek( FwxFilial("NJR")+cCodCtr ) )
           cSafra	 := NJR->NJR_CODSAF
        EndIf


        //Busca os fardos que já foram selecionados para o contrato
        __aFardos := AtlFardos(cCodCtr, (__cTabReg)->N78_SEQUEN )


	    dbSelectArea("NJR")
		dbSelectArea("NNY")
		//busca o tipo padrão
		cTiposCtr := Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_TIPALG")
		cTiposCtr := IIF(allTrim(cTiposCtr) == "-", "", cTiposCtr ) //problema de gravar com mascara
		nTolen    :=  Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_TOLENT")
		nQtdCad   :=  Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_QTDCTR") * ((__cTabReg)->N78_OUTPER / 100 )

		if !empty(cTiposCtr) //para ter tipos aceitavéis tem que existir tipo padrão
			dbSelectArea( "N7E" )
			N7E->( dbSetOrder( 1 ) )
			N7E->( dbSeek( xFilial( "N7E" ) + cCodCtr ) )
			While !( Eof() ) .And. N7E->( N7E_FILIAL ) + N7E->( N7E_CODCTR ) == xFilial( "N7E" ) + cCodCtr
			    cTiposCtr += " OU " + N7E->( N7E_TIPACE )
				N7E->( dbSkip() )
			EndDo
		endif

		//monta o array de hvi
		dbSelectArea( "N7H" )
		N7H->( dbSetOrder( 1 ) )
		N7H->( dbSeek( xFilial( "N7H" ) + cCodCtr ) )
		While !( Eof() ) .And. N7H->( N7H_FILIAL ) + N7H->( N7H_CODCTR ) == xFilial( "N7H" ) + cCodCtr
		    aADD(aFilHVI,{N7H->( N7H_CAMPO ),N7H->( N7H_HVIDES ) ,N7H->( N7H_VLRINI ), N7H->( N7H_VLRFIM ) })
			N7H->( dbSkip() )
		EndDo

		//monta filtro da DXI
		cFiltroDXI := "DXI_SAFRA = '"+alltrim(cSafra)+"'" 
	
		//monta filtro da N9D
		cFiltroN9D := "N9D_TIPMOV = '02' AND N9D_CODCTR = '"+alltrim(cCodCtr)+"' AND N9D_FILORG = '"+FwXFilial("NJR")+"' " 
		
		//monta as opções
		aAdd(aOptions, {'_cCodCtr', cCodCtr})  
		aAdd(aOptions, {'_lShowAVinc', .f. })  
		
		//Executa a tela de Selecionar Blocos e Fardos para o contrato
		aFarSelec := AGRX720(cFiltroDXI, cTiposCtr, @aFilHVI, cFiltroN9D, aOptions , __aFardos, /*Fardos Excluídos*/ , nQtdCad, nTolen) //consulta especifica de fardos			
			
		if aFarSelec[1] //foi clicado em ok
			//Exclui os registros da N87 referente o contrato atual
			OGC080EXFR(Nil, _cCodCtr, (__cTabReg)->N78_SEQUEN )

			//Inclui novos registros na tabela que vincula os fardos a regra BCI
			BEGIN TRANSACTION
				For nCont := 1  to Len(aFarSelec[2]) //listagem de dados
				   If RecLock( "N87", .T. )
				      N87->N87_FILIAL := FwxFilial("N87")
				      N87->N87_CODCTR := (__cTabReg)->N78_CODCTR
				      N87->N87_APLICA := "3"
				      N87->N87_SEQUEN := (__cTabReg)->N78_SEQUEN
				      N87->N87_SAFRA  := aFarSelec[2][nCont][4]
				      N87->N87_ETIQ   := aFarSelec[2][nCont][5]
				      N87->N87_FILORG := aFarSelec[2][nCont][1]
				      MsUnlock()
				   EndIf
			    Next nCont
		    END TRANSACTION
		    
		    Processa({|| OGX016(FwxFilial("NJR"), _cCodCtr) }, STR0059) //executa o ágio e deságio
		    
		    OGX055(FwxFilial("NJR"),_cCodCtr) //recalcula os valores das regras fiscais

		endif
	else
		//help de selecionar contrato AGRA720SCTR
		Help('',1,"OGC080CTR01") //"Contrato não informado"  // Selecionar um registro de contrato para realizar estar operação
		Return(.F.)
	endif


	NJR->(dbCloseArea())
	NNY->(dbCloseArea())
	RestArea(aArea)
Return(.T.)

/*{Protheus.doc} AtlFardos
Executa a funcao de Busca de Blocos e Fardos AGRX720 e
no retorno grava os dados na tabela
@author Marcelo Ferrari
@since 15/09/2017
@version undefined
@param
@type function
*/
Static Function AtlFardos(cCodCtr, cSequencia)
   Local aArea := GetArea()
   Local aRet   := {}
   Local aRec   := {}
   Local cQuery := ""
   Local cAliasTmp := ""
   Local cSeqIt    := ""

   cQuery := "SELECT DXQ.DXQ_ITEM, DXQ.DXQ_BLOCO, DXI.R_E_C_N_O_ DXIRECNO "
   cQuery += " FROM " + RetSqlName("DXI") + " DXI "
   cQuery +=                " LEFT JOIN " + RetSqlName("DXQ") + " DXQ ON DXI.DXI_FILIAL = DXQ.DXQ_FILORG "
   cQuery +=                                     " AND DXI.DXI_CODRES = DXQ.DXQ_CODRES "
   cQuery +=                                     " AND DXI.DXI_BLOCO  = DXQ.DXQ_BLOCO "
   cQuery +=                                     " AND DXI.D_E_L_E_T_ = ' ' "
   cQuery +=                " INNER JOIN " + RetSqlName("DXP") + " DXP ON DXQ.DXQ_FILIAL = DXP.DXP_FILIAL "
   cQuery += 				                     " AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO "
   cQuery += 									 " AND DXQ.D_E_L_E_T_ = ' ' "
   cQuery += 				" INNER JOIN " + RetSqlName("N78") + " N78 ON N78.N78_FILIAL = DXP.DXP_FILIAL "
   cQuery += 				                     " AND N78.N78_CODCTR = DXP.DXP_CODCTP "
   cQuery += 									 " AND N78.N78_APLICA = '3' "
   cQuery += 									 " AND N78.D_E_L_E_T_ = ' ' "
   cQuery += 				" INNER JOIN " + RetSqlName("N87") + "  N87 ON N87.N87_FILIAL = N78.N78_FILIAL "
   cQuery += 				                     " AND N87.N87_CODCTR = N78.N78_CODCTR "
   cQuery += 									 " AND N87.N87_SEQUEN = N78.N78_SEQUEN "
   cQuery += 									 " AND N87.N87_SAFRA  = DXI.DXI_SAFRA "
   cQuery += 									 " AND N87.N87_ETIQ   = DXI.DXI_ETIQ "
   cQuery += 									 " AND N87.N87_FILORG = DXI.DXI_FILIAL"
   cQuery += 									 " AND N87.D_E_L_E_T_ = ' ' "
   cQuery += " WHERE 1=1 "
   cQuery += " AND DXP.DXP_FILIAL = '" + fwXFilial("DXP")+ "' "
   cQuery += " AND DXP.DXP_CODCTP = '" + cCodCtr + "' "
   If !Empty(cSequencia)
      cQuery += " AND N87.N87_SEQUEN = '" + cSequencia + "' "
   EndIf
   cQuery += " AND DXP.D_E_L_E_T_ = ' ' "
   cQuery += " ORDER BY DXQ.DXQ_ITEM, DXQ.DXQ_BLOCO

   cAliasTmp := GetSqlAll(cQuery)

   cSeqIt := (cAliasTmp)->DXQ_ITEM
   cBloco := (cAliasTmp)->DXQ_BLOCO
   While !(cAliasTmp)->(Eof())
      aAdd(aRec, (cAliasTmp)->DXIRECNO)
      (cAliasTmp)->(DbSkip())

      If ( (cAliasTmp)->(Eof()) ) .OR. ( (cAliasTmp)->DXQ_ITEM != cSeqIt )
         aAdd(aRet, {cSeqIt, cBloco, aRec} )
         aRec := {}
         If !(cAliasTmp)->(Eof())
            cSeqIt := (cAliasTmp)->DXQ_ITEM
            cBloco := (cAliasTmp)->DXQ_BLOCO
         EndIf
      EndIf
   EndDo

   (cAliasTmp)->(DbCloseArea())
   RestArea(aArea)

Return aRet


/*{Protheus.doc} OGC080EXET
Exclui um fardo específico da tabela de regra
no retorno grava os dados na tabela
@author Marcelo Ferrari
@since 15/09/2017
@version undefined
@param
@type function
*/
Function OGC080EXET(cFilOrg, cSafra, cEtiqueta )
	Local aArea := GetArea()
	Local cQuery := ""
	Local cAliasDel := ""

    If !Empty(cSafra)  .AND. !Empty(cEtiqueta)
	    cQuery := "SELECT N87.R_E_C_N_O_ N87RECNO
		cQuery += " FROM " + RetSqlName("N87") + " N87 "
		cQuery += "WHERE 1=1 "
		cQuery += "AND N87_SAFRA = '" + cSafra + "' "
		cQuery += "AND N87_ETIQ =  '" + cEtiqueta + "' "
		cQuery += "AND N87_FILORG =  '" + cFilOrg + "' "
		cQuery += "  AND N87.D_E_L_E_T_ = ' ' "

		cAliasDel := GetSqlAll(cQuery)
		While !(cAliasDel)->(Eof())
			N87->(DbGoTo( (cAliasDel)->N87RECNO ) )
			If RecLock( "N87", .f.)
				N87->(DbDelete())
				N87->(MsUnlock())
			EndIf
			(cAliasDel)->( dbSkip() )
		EndDo
	EndIf
    RestArea(aArea)
Return .T.


/*{Protheus.doc} AtlFardos
Exclui os fardos da tabela N87
no retorno grava os dados na tabela
@author Marcelo Ferrari
@since 15/09/2017
@version undefined
@param
@type function
*/
Function OGC080EXFR(aFardos, cContr, cRegra )
	Local aArea := GetArea()
	Local aFardosSel := {}
	Local aFardosBkp := {}
	Local nI  := 0
	Local nJ  := 0
	Local aEtiq  := {}
	Local aFarSel := {}
	Local cRecN87 := Nil

	Default cContr := ""
	Default cRegra := ""

	If Select("N87") == 0
	   DbSelectArea("N87")
	EndIf

	If !Empty(aFardos)

		aFardosSel := aFardos[1]
		aFardosBkp := aFardos[2]

		//Monta uma lista única com todos os fardos selecionados
		For nI := 1 to len(aFardosSel)
			For nJ := 1 to len(aFardosSel[nI][3])
				aAdd(aFarSel, aFardosSel[nI][3][nJ])
			Next nJ
		Next nI

		For nI := 1 to len(aFardosBkp)
			For nJ := 1 to Len(aFardosBkp[nI][3])
				nPos := aScan(aFarSel, aFardosBkp[nI][3][nJ] )
	    	    If nPos = 0
	    	       aAdd(aEtiq, aFardosBkp[nI][3][nJ])
	    	    EndIf
	    	Next nJ
	    Next nI

		If Len(aEtiq) > 0
		    If Select("DXI") = 0
		       DbSelectArea("DXI")
		    EndIf
		    DXI->(DbGoTop())
			For nI := 1 to Len(aEtiq)
				DXI->(DbGoTo(aEtiq[nI]))
				cRecN87 := GetDataSql("SELECT N87.R_E_C_N_O_ N87RECNO " + ;
                                      " FROM " + RetSqlName("N87") + " N87 " + ;
		                              " WHERE N87_SAFRA = '" + DXI->DXI_SAFRA + "' " + ;
		                              " AND N87_ETIQ  = '" + DXI->DXI_ETIQ + "' " + ;
		                              " AND N87_FILORG  = '" + DXI->DXI_FILIAL + "' " + ;
		                              " AND N87.D_E_L_E_T_ = ' ' " )

				N87->(DbGoTo( cRecN87 ) )
				If !(N87->(Eof()))
					If RecLock( "N87", .f.)
						N87->(DbDelete())
						N87->(MsUnlock())
					EndIf
				EndIf
			Next nI
		EndIF

	ElseIF !(Empty(cContr)) .AND. !(Empty(cRegra))
		N87->(DbGoTop())
		If N87->(DbSeek(FwxFilial("N87")+cContr+"3"+cRegra))
			While !N87->(EOF()) .AND. ;
			      (N87->(N87_FILIAL+N87_CODCTR+N87_SEQUEN) == FwxFilial("N87")+cContr+cRegra )
				If RecLock( "N87", .F. )
					N87->(DbDelete())
					MsUnlock()
				EndIf
				N87->( dbSkip() )
			EndDo
		EndIf

	EndIF

    RestArea(aArea)
Return .T.
