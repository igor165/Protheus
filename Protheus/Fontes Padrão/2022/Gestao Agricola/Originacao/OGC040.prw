#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWBrowse.ch'
#Include 'OGC040.ch'
#DEFINE CRLF CHR(13)+CHR(10)

Static __cTabBlc	:= "" //Tabela Temporária de Blocos
Static __cTabFar	:= "" //Tabela Temporária de Fardos

/*{Protheus.doc} OGC040
Consulta de Fardos e Blocos do Contrato
@author jean.schulze
@since 26/05/2017
@version undefined
@param pcCodCtr, , descricao
@type function
*/
function OGC040(pcCodCtr, cFilCtr)
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local aFilBrowBlc := {}
	Local aFilBrowFar := {}
	Local nCont       := 0
	Local aButtons    := {}

	Default cFilCtr := FwXFilial("NJR")

	Private _cCodCtr        := pcCodCtr //contrato selecionado
	Private _cFilCtr        := cFilCtr //contrato selecionado
	Private __aFixacaoSelec := {}       //Array com dados da Fixação NN8
	Private __nVlrBaseFix   := 0        //Valor unitário da Fixação    
	Private __lFixacao   	:= .F.
    	Private __aBlocosFix 	:= {} //fardos que serão calculados

	//----- Proteção para chamadas atraves do Menu
	//- Realizada a proteção para MERGE com MAIN
	If Empty(pcCodCtr)
		Help('',1,"AGRNOEXISTFUN") //"Função não disponível para Menu.
		Return()
	EndIf
	//------------------------------------------------------------------

	//campos blocos
	aCpsBrowBlc := {{STR0026 , "MARK"    	, "C" ,  1, , "@!"},; //control utilização
					{STR0017 , "DXP_STATUS"	, TamSX3( "DXP_STATUS" )[3]	, TamSX3( "DXP_STATUS" )[1]	, TamSX3( "DXP_STATUS" )[2]	, PesqPict("DXP","DXP_STATUS") 	},; //"Status"
					{STR0043 , "TMP_QTDFAR" , "N" ,  4, , "@" },; //Qtd. Fardo
					{STR0050 , "TMP_MSG"    , "M" , 20, , "@" },; //Mensagem
					{STR0001 , "DXP_ITECAD"	, TamSX3( "DXP_ITECAD" )[3]	, TamSX3( "DXP_ITECAD" )[1]	, TamSX3( "DXP_ITECAD" )[2]	, PesqPict("DXP","DXP_ITECAD") 	},; //Item Cad
					{STR0002 , "DXD_FILIAL"	, TamSX3( "DXD_FILIAL" )[3]	, TamSX3( "DXD_FILIAL" )[1]	, TamSX3( "DXD_FILIAL" )[2]	, PesqPict("DXD","DXD_FILIAL") 	},;	//"Filial"
				        {STR0003 , "DXD_CODIGO"	, TamSX3( "DXD_CODIGO" )[3]	, TamSX3( "DXD_CODIGO" )[1]	, TamSX3( "DXD_CODIGO" )[2]	, PesqPict("DXD","DXD_CODIGO") 	},;	//"Bloco"
			        	{STR0011 , "DXP_CODIGO"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},; //Reserva
					{STR0004 , "DXD_CLACOM"	, TamSX3( "DXD_CLACOM" )[3]	, TamSX3( "DXD_CLACOM" )[1]	, TamSX3( "DXD_CLACOM" )[2]	, PesqPict("DXD","DXD_CLACOM") 	},;	//"Class Com"
					{STR0005 , "DXD_SAFRA"	, TamSX3( "DXD_SAFRA" )[3]	, TamSX3( "DXD_SAFRA" )[1]	, TamSX3( "DXD_SAFRA" )[2]	, PesqPict("DXD","DXD_SAFRA") 	},; //"Safra"
					{STR0014 , "DXI_VLBASE"	, TamSX3( "DXI_VLBASE" )[3]	, TamSX3( "DXI_VLBASE" )[1]	, TamSX3( "DXI_VLBASE" )[2]	, PesqPict("DXI","DXI_VLBASE") 	},; //"Valor base"
					{STR0020 , "DXI_VADFOL"	, TamSX3( "DXI_VADFOL" )[3]	, TamSX3( "DXI_VADFOL" )[1]	, TamSX3( "DXI_VADFOL" )[2]	, PesqPict("DXI","DXI_VADFOL") 	},; //agio folha
					{STR0021 , "DXI_VADCOR"	, TamSX3( "DXI_VADCOR" )[3]	, TamSX3( "DXI_VADCOR" )[1]	, TamSX3( "DXI_VADCOR" )[2]	, PesqPict("DXI","DXI_VADCOR") 	},; //agio cor
					{STR0022 , "DXI_VADHVI"	, TamSX3( "DXI_VADHVI" )[3]	, TamSX3( "DXI_VADHVI" )[1]	, TamSX3( "DXI_VADHVI" )[2]	, PesqPict("DXI","DXI_VADHVI") 	},; //agio hvi
					{STR0023 , "DXI_VADOUT" , TamSX3( "DXI_VADOUT" )[3]	, TamSX3( "DXI_VADOUT" )[1]	, TamSX3( "DXI_VADOUT" )[2]	, PesqPict("DXI","DXI_VADOUT") 	},; //agio outros
					{STR0015 , "DXI_VADTOT"	, TamSX3( "DXI_VADTOT" )[3]	, TamSX3( "DXI_VADTOT" )[1]	, TamSX3( "DXI_VADTOT" )[2]	, PesqPict("DXI","DXI_VADTOT") 	},; //Valor agio/desagio Total
					{STR0016 , "DXI_VLCAGD"	, TamSX3( "DXI_VLCAGD" )[3]	, TamSX3( "DXI_VLCAGD" )[1]	, TamSX3( "DXI_VLCAGD" )[2]	, PesqPict("DXI","DXI_VLCAGD") 	},; //valor com ágio/deságio
					{STR0007 , "TMP_PSLIQU"	, TamSX3( "NJR_QTDINI" )[3]	, TamSX3( "NJR_QTDINI" )[1]	, TamSX3( "NJR_QTDINI" )[2]	, PesqPict("NJR","NJR_QTDINI") 	},;	//Ps. Liq.
					{STR0024 , "TMP_VLRTOT"	, TamSX3( "NJR_VLRTOT" )[3]	, TamSX3( "NJR_VLRTOT" )[1]	, TamSX3( "NJR_VLRTOT" )[2]	, PesqPict("NJR","NJR_VLRTOT") 	}}  //Valor total
	//campos Fardos
	aCpsBrowFar := {{STR0026 , "MARK"	    , "C",  1,  , "@!"},;           //control utilização
					{STR0027 , "DXP_RECNO"  , "N", 18, 0, "@ 9999999999"},; //recno reserva
					{STR0028 , "DXI_RECNO"  , "N", 18, 0, "@ 9999999999"},; //recno fardo
					{STR0050 , "TMP_MSG"    , "M", 20,  , "@" },;           //Mensagem
					{STR0017 , "DXP_STATUS"	, TamSX3( "DXP_STATUS" )[3]	, TamSX3( "DXP_STATUS" )[1]	, TamSX3( "DXP_STATUS" )[2]	, PesqPict("DXP","DXP_STATUS") 	},; //"Qtd. Take-Up"
					{STR0001 , "DXP_ITECAD"	, TamSX3( "DXP_ITECAD" )[3]	, TamSX3( "DXP_ITECAD" )[1]	, TamSX3( "DXP_ITECAD" )[2]	, PesqPict("DXP","DXP_ITECAD") 	},; //Item Cad
					{STR0002 , "DXI_FILIAL"	, TamSX3( "DXI_FILIAL" )[3]	, TamSX3( "DXI_FILIAL" )[1]	, TamSX3( "DXI_FILIAL" )[2]	, PesqPict("DXI","DXI_FILIAL") 	},;	//"Filial
			        	{STR0003 , "DXI_BLOCO"	, TamSX3( "DXI_BLOCO" )[3]	, TamSX3( "DXI_BLOCO" )[1]	, TamSX3( "DXI_BLOCO" )[2]	, PesqPict("DXI","DXI_BLOCO") 	},;	//"Bloco"
					{STR0006 , "DXI_CODIGO"	, TamSX3( "DXI_CODIGO" )[3]	, TamSX3( "DXI_CODIGO" )[1]	, TamSX3( "DXI_CODIGO" )[2]	, PesqPict("DXI","DXI_CODIGO") 	},;	//"Fardo"
					{STR0063 , "DESCSTS"	, 'C', 30, 0,  "@!"	},; 
				        {STR0011 , "DXP_CODIGO"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},; // Reserva
					{STR0004 , "DXI_CLACOM"	, TamSX3( "DXI_CLACOM" )[3]	, TamSX3( "DXI_CLACOM" )[1]	, TamSX3( "DXI_CLACOM" )[2]	, PesqPict("DXI","DXI_CLACOM") 	},;	//"Class Com."
				        {STR0005 , "DXI_SAFRA"	, TamSX3( "DXI_SAFRA" )[3]	, TamSX3( "DXI_SAFRA" )[1]	, TamSX3( "DXI_SAFRA" )[2]	, PesqPict("DXI","DXI_SAFRA") 	},; //Safra
				        {STR0014 , "DXI_VLBASE"	, TamSX3( "DXI_VLBASE" )[3]	, TamSX3( "DXI_VLBASE" )[1]	, TamSX3( "DXI_VLBASE" )[2]	, PesqPict("DXI","DXI_VLBASE") 	},; //Valor base
					{STR0020 , "DXI_VADFOL"	, TamSX3( "DXI_VADFOL" )[3]	, TamSX3( "DXI_VADFOL" )[1]	, TamSX3( "DXI_VADFOL" )[2]	, PesqPict("DXI","DXI_VADFOL") 	},; //agio folha
					{STR0021 , "DXI_VADCOR"	, TamSX3( "DXI_VADCOR" )[3]	, TamSX3( "DXI_VADCOR" )[1]	, TamSX3( "DXI_VADCOR" )[2]	, PesqPict("DXI","DXI_VADCOR") 	},; //agio cor
					{STR0022 , "DXI_VADHVI"	, TamSX3( "DXI_VADHVI" )[3]	, TamSX3( "DXI_VADHVI" )[1]	, TamSX3( "DXI_VADHVI" )[2]	, PesqPict("DXI","DXI_VADHVI") 	},; //agio hvi
					{STR0023 , "DXI_VADOUT" , TamSX3( "DXI_VADOUT" )[3]	, TamSX3( "DXI_VADOUT" )[1]	, TamSX3( "DXI_VADOUT" )[2]	, PesqPict("DXI","DXI_VADOUT") 	},; //agio outros
					{STR0015 , "DXI_VADTOT"	, TamSX3( "DXI_VADTOT" )[3]	, TamSX3( "DXI_VADTOT" )[1]	, TamSX3( "DXI_VADTOT" )[2]	, PesqPict("DXI","DXI_VADTOT") 	},; //Valor agio/desagio Total 
				        {STR0016 , "DXI_VLCAGD"	, TamSX3( "DXI_VLCAGD" )[3]	, TamSX3( "DXI_VLCAGD" )[1]	, TamSX3( "DXI_VLCAGD" )[2]	, PesqPict("DXI","DXI_VLCAGD") 	},; //Valor com agio/desagio
			        	{STR0007 , "DXI_PSLIQU"	, TamSX3( "DXI_PSLIQU" )[3]	, TamSX3( "DXI_PSLIQU" )[1]	, TamSX3( "DXI_PSLIQU" )[2]	, PesqPict("DXI","DXI_PSLIQU") 	},;	//Ps. Liq.
					{STR0025 , "TMP_VLRTOT"	, TamSX3( "NJR_VLRTOT" )[3]	, TamSX3( "NJR_VLRTOT" )[1]	, TamSX3( "NJR_VLRTOT" )[2]	, PesqPict("NJR","NJR_VLRTOT") 	},;	//"Valor total
 	 		                {STR0055, "DXI_TIPPRE"	, TamSX3( "DXI_TIPPRE" )[3]	, 12	, TamSX3( "DXI_TIPPRE" )[2]	, PesqPict("DXI","DXI_TIPPRE") 	},;
                    			{"DXI_ETIQ" , "DXI_ETIQ", TamSX3( "DXI_ETIQ" )[3]	, TamSX3( "DXI_ETIQ" )[1]	, TamSX3( "DXI_ETIQ" )[2]	, PesqPict("DXI","DXI_ETIQ") 	},;
                    {STR0064, "DX7_RES"	, TamSX3( "DX7_RES" )[3]	, TamSX3( "DX7_RES" )[1]	, TamSX3( "DX7_RES" )[2]	, PesqPict("DX7","DX7_RES") 	},; //"  RES  "
                    {STR0065, "DX7_UHM"	, TamSX3( "DX7_UHM" )[3]	, TamSX3( "DX7_UHM" )[1]	, TamSX3( "DX7_UHM" )[2]	, PesqPict("DX7","DX7_UHM") 	},; //UHM
                    {STR0066, "DX7_MIC"	, TamSX3( "DX7_MIC" )[3]	, TamSX3( "DX7_MIC" )[1]	, TamSX3( "DX7_MIC" )[2]	, PesqPict("DX7","DX7_MIC") 	}}	//MIC
	

	Processa({|| __cTabBlc := MontaTabel(aCpsBrowBlc, {{"", "DXD_FILIAL+DXD_SAFRA+DXD_CODIGO"}})},STR0018)
	Processa({|| __cTabFar := MontaTabel(aCpsBrowFar, {{"", "DXI_FILIAL+DXI_SAFRA+DXI_BLOCO+DXP_CODIGO+DXI_CODIGO"}})},STR0018)

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
	oFWL:addLine( 'MASTER'   , 100 , .F.)
	oFWL:addCollumn( 'LEFT' ,50,.F., 'MASTER' )
	oFWL:addCollumn( 'RIGHT' , 50,.F., 'MASTER' )

	oFWL:setColSplit ( 'LEFT', 1,  'MASTER' )
	oFWL:setColSplit ( 'RIGHT', 2,  'MASTER' )

	//cria as janelas
	oFWL:addWindow( 'LEFT' , 'Wnd1', STR0009,  100 /*tamanho*/, .F., .T.,, 'MASTER' )
	oFWL:addWindow( 'RIGHT', 'Wnd2', STR0010,  100 /*tamanho*/, .F., .T.,, 'MASTER' )

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'LEFT' , 'Wnd1', 'MASTER' )
	oPnlWnd2:= oFWL:getWinPanel( 'RIGHT', 'Wnd2', 'MASTER' )


	/****************** BLOCOS ********************************/
	//adicionando os widgets de tela
	oBrowse1 := FWMBrowse():New()
    oBrowse1:SetAlias(__cTabBlc)
    oBrowse1:DisableDetails()
    oBrowse1:SetMenuDef( "" )
    oBrowse1:DisableReport(.T.)
    oBrowse1:DisableSeek(.T.)
    oBrowse1:SetProfileID("OGC040BLC")
   

    //marcação de itens
	oBrowse1:AddMarkColumns( { ||Iif( !Empty( (__cTabBlc)->MARK = "1" ),"LBOK","LBNO" ) },{ || OGC040DB(oBrowse1, "B"), OGC040UP(oBrowse1, .f.), OGC040UP(oBrowse2),  oBrowse1:SetFocus(), oBrowse1:GoColumn(1)  }, { || OGC040HD(oBrowse1, "B") , OGC040UP(oBrowse1), OGC040UP(oBrowse2), oBrowse1:SetFocus()  } )

    //legenda
    oBrowse1:AddLegend( "DXP_STATUS == '1'", "GREEN", STR0012) 	//"Aguardando Take-Up"
	oBrowse1:AddLegend( "DXP_STATUS == '2'", "GRAY" , STR0013) 	//"Take-Up Efetuado"

    For nCont := 5  to Len(aCpsBrowBlc) //desconsiderar MARK, STATUS, QTD_FARDO, MENSAGEM
        if nCont >= 11  //campos de valores alinhados à direita
        	oBrowse1:AddColumn( {aCpsBrowBlc[nCont][1]  , &("{||"+aCpsBrowBlc[nCont][2]+"}") ,aCpsBrowBlc[nCont][3],aCpsBrowBlc[nCont][6],2,aCpsBrowBlc[nCont][4],aCpsBrowBlc[nCont][5],.f.} )
        Else
        	oBrowse1:AddColumn( {aCpsBrowBlc[nCont][1]  , &("{||"+aCpsBrowBlc[nCont][2]+"}") ,aCpsBrowBlc[nCont][3],aCpsBrowBlc[nCont][6],1,aCpsBrowBlc[nCont][4],aCpsBrowBlc[nCont][5],.f.} )
        EndIf
        aADD(aFilBrowBlc,  {aCpsBrowBlc[nCont][2], aCpsBrowBlc[nCont][1], aCpsBrowBlc[nCont][3], aCpsBrowBlc[nCont][4], aCpsBrowBlc[nCont][5], aCpsBrowBlc[nCont][6] } )
    Next nCont

    oBrowse1:SetFieldFilter(aFilBrowBlc)
    oBrowse1:bGotFocus := {|tGrid| OGC004FOC(tGrid)}
    oBrowse1:Activate(oPnlWnd1)


	/****************** FARDOS ********************************/
	oBrowse2 := FWMBrowse():New()
    oBrowse2:DisableReport(.T.)
    oBrowse2:DisableDetails()
    oBrowse2:SetAlias(__cTabFar)
    oBrowse2:SetMenuDef( "" )
    oBrowse2:DisableReport(.T.)
    oBrowse2:DisableSeek(.T.)
    oBrowse2:SetProfileID("OGC040FAR")
    oBrowse2:SetDoubleClick({|| OGC040HIAG("brw2")})

    //marcação de itens
	oBrowse2:AddMarkColumns( { ||Iif( !Empty( (__cTabFar)->MARK = "1" ),"LBOK","LBNO" ) },{ || OGC040DB(oBrowse2, "F"), OGC040UP(oBrowse2, .f.), oBrowse2:SetFocus(), oBrowse2:GoColumn(1)  }, { || OGC040HD(oBrowse2,"F") , OGC040UP(oBrowse2), oBrowse2:SetFocus()  } )

    //legenda
    oBrowse2:AddLegend( "DXP_STATUS == '1'", "GREEN", STR0012) 	//"Aguardando Take-Up"
	oBrowse2:AddLegend( "DXP_STATUS == '2'", "GRAY" , STR0013) 	//"Take-Up Efetuado"

    For nCont := 6  to Len(aCpsBrowFar) //desconsiderar Mark, Status, Recno Reserva,  Recno Fardo e Mensagem
    	If !("DXI_ETIQ" $ aCpsBrowFar[nCont][2])	
		If nCont >= 13 //valores alinhados a direita
	    		oBrowse2:AddColumn( {aCpsBrowFar[nCont][1]  , &("{||"+aCpsBrowFar[nCont][2]+"}") ,aCpsBrowFar[nCont][3],aCpsBrowFar[nCont][6],2,aCpsBrowFar[nCont][4],aCpsBrowFar[nCont][5],.f.} )
	    	Else
	    		oBrowse2:AddColumn( {aCpsBrowFar[nCont][1]  , &("{||"+aCpsBrowFar[nCont][2]+"}") ,aCpsBrowFar[nCont][3],aCpsBrowFar[nCont][6],1,aCpsBrowFar[nCont][4],aCpsBrowFar[nCont][5],.f.} )
	    	EndIf
    	
		aADD(aFilBrowFar, {aCpsBrowFar[nCont][2], aCpsBrowFar[nCont][1], aCpsBrowFar[nCont][3], aCpsBrowFar[nCont][4], aCpsBrowFar[nCont][5], aCpsBrowFar[nCont][6]})
    	EndIf	
    Next nCont

    oBrowse2:SetFieldFilter(aFilBrowFar)
    oBrowse2:bGotFocus := {|tGrid| OGC004FOC(tGrid)}
    oBrowse2:Activate(oPnlWnd2)

    //cria os botões adicionais
    Aadd( aButtons, {STR0029, {|| OGC040REMF()}, STR0029, STR0029 , {|| .T.}} )   

	oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, , {||  oDlg:End() } /*Fechar*/,,@aButtons,,,.f.,.f.,.f.,.f.,.f.) )


return

/*{Protheus.doc} fGetDados
Popula blocos e Fardos
@author jean.schulze
@since 26/05/2017
@version undefined
@type function
*/
static function fGetDados
	Local cAliasDXD	 := GetNextAlias()
	Local cFiltro    := ""
	Local nVlrBase   := 0
	Local nFix       := 0

	//--Deleta tudo da temporaria para realizar nova busca de blocos
	DbSelectArea((__cTabBlc))
	DbGoTop()
	If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO)
		While !(__cTabBlc)->(Eof())

			If RecLock((__cTabBlc),.f.)
				(__cTabBlc)->(DbDelete())
				(__cTabBlc)->(MsUnlock())
			EndIf
			(__cTabBlc)->( dbSkip() )
		EndDo
	EndIF

	//--Deleta tudo da temporaria para realizar nova busca de fardos
	DbSelectArea((__cTabFar))
	DbGoTop()
	If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXP_CODIGO+(__cTabFar)->DXI_CODIGO)
		While !(__cTabFar)->(Eof())

			If RecLock((__cTabFar),.f.)
				(__cTabFar)->(DbDelete())
				(__cTabFar)->(MsUnlock())
			EndIf
			(__cTabFar)->( dbSkip() )
		EndDo
	EndIF

	if !empty(_cCodCtr)
		cFiltro += "AND DXP.DXP_CODCTP = '"+_cCodCtr+" ' "//não precisamos trazer o NJR para o JOIN
	endif

	cFiltro := "%" + cFiltro + "%"

	//monta a query de busca
	BeginSql Alias cAliasDXD

		SELECT DXD.DXD_FILIAL, DXD.DXD_CODIGO, DXD.DXD_CLACOM, DXD.DXD_SAFRA, DXP_ITECAD, DXP_FILIAL, DXP_CODIGO, DXP_STATUS, NJR_FILIAL, NJR_CODCTR, NJR_UM1PRO, NJR_UMPRC, NJR_VLRBAS, NJR_CODPRO, DXP.R_E_C_N_O_  DXPRECNO
		  FROM %Table:DXD% DXD
		  INNER JOIN %Table:DXI% DXI ON DXI.DXI_FILIAL = DXD.DXD_FILIAL
		                             AND DXI.DXI_SAFRA = DXD.DXD_SAFRA
		                             AND DXI.DXI_BLOCO = DXD.DXD_CODIGO
		                             AND DXI.%notDel%
		  INNER JOIN %Table:DXQ% DXQ ON DXQ.DXQ_BLOCO   = DXD.DXD_CODIGO
					 	             AND DXQ.%notDel%
						             AND DXQ.DXQ_FILORG = DXD.DXD_FILIAL
							         AND DXQ.DXQ_CODRES = DXI.DXI_CODRES
		  INNER JOIN %Table:DXP% DXP ON DXP.DXP_CODIGO  = DXQ.DXQ_CODRES
				 	                 AND DXP.%notDel%
						             AND DXP.DXP_FILIAL = DXQ.DXQ_FILIAL
		  INNER JOIN %Table:NJR% NJR ON NJR.NJR_CODCTR = DXP.DXP_CODCTP
		  							 AND NJR.%notDel%
	    				             AND NJR.NJR_FILIAL = DXP.DXP_FILIAL
	    WHERE DXD.%notDel%
		      %exp:cFiltro%
		GROUP BY DXD.DXD_FILIAL, DXD.DXD_CODIGO, DXD.DXD_CLACOM, DXD.DXD_SAFRA, DXP_ITECAD, DXP_FILIAL, DXP_CODIGO, DXP_STATUS, NJR_FILIAL, NJR_CODCTR, NJR_VLRBAS, NJR_UM1PRO, NJR_UMPRC, NJR_CODPRO, DXP.R_E_C_N_O_
		ORDER BY DXD.DXD_CODIGO

	EndSQL

	//apropriação de dados
	DbselectArea( cAliasDXD )
	DbGoTop()
	While ( cAliasDXD )->( !Eof() )
	    
		RecLock((__cTabBlc),.T.)

			(__cTabBlc)->DXP_ITECAD	:= (cAliasDXD)->DXP_ITECAD
			(__cTabBlc)->DXP_STATUS	:= (cAliasDXD)->DXP_STATUS
			(__cTabBlc)->DXD_FILIAL	:= (cAliasDXD)->DXD_FILIAL
			(__cTabBlc)->DXD_CODIGO := (cAliasDXD)->DXD_CODIGO
			(__cTabBlc)->DXP_CODIGO	:= (cAliasDXD)->DXP_CODIGO
			(__cTabBlc)->DXD_CLACOM	:= (cAliasDXD)->DXD_CLACOM
			(__cTabBlc)->DXD_SAFRA	:= (cAliasDXD)->DXD_SAFRA

			nFix := aScan(__aBlocosFix,{|x| allTrim(x[1]) == alltrim( (cAliasDXD)->(DXD_FILIAL+DXD_SAFRA+DXD_CODIGO) ) }  )
			if (__lFixacao) .AND. (nFix > 0)
			   __aBlocosFix[nFix][1] := (cAliasDXD)->(DXD_FILIAL)
			   __aBlocosFix[nFix][3] := nVlrBase
			endif

			(__cTabBlc)->DXI_VLBASE	:= nVlrBase
			
			/*Busca os dados dos fardos*/
			fGetQryDXI(cAliasDXD)  //popula a temp-table de fardos
			
		(__cTabBlc)->(MsUnlock())

		(cAliasDXD)->(dbSkip())
	EndDo

	(cAliasDXD)->(dbCloseArea())

return .t.

/*{Protheus.doc} fGetQryDXI
Popula os fardos do bloco
@author jean.schulze
@since 26/05/2017
@version undefined
@type function
*/
static function fGetQryDXI(cAliasDXD)
	Local cAliasDXI	 := GetNextAlias()
	Local cFiltroDXI := ""
	Local nFix       := 0
	Local nVlFol     := 0
	Local nVlCor     := 0 
	Local nVlHvi     := 0
	Local nPesLiq    := 0
	Local nVlOut     := 0
	Local nVlFolM    := 0
	Local nVlcorM 	 := 0
	Local nVlHviM 	 := 0
	Local nVlOutM 	 := 0
	Local nVl1       := 0
	Local nVl2       := 0
	Local nVl3       := 0
	Local nVl4       := 0
	Local nVl5       := 0
	Local nVl7       := 0
	Local nPeso      := 0
	Local cTipP      :=""
	Local nCont      := 0

	cFiltroDXI := "AND DXI.DXI_FILIAL = '"+(cAliasDXD)->DXD_FILIAL+"' "
	cFiltroDXI += "AND DXI.DXI_SAFRA  = '"+(cAliasDXD)->DXD_SAFRA+"' "
	cFiltroDXI += "AND DXI.DXI_BLOCO  = '"+(cAliasDXD)->DXD_CODIGO+"' "
	cFiltroDXI += "AND DXI.DXI_CODRES = '"+(cAliasDXD)->DXP_CODIGO+"' "

	cFiltroDXI := "%" + cFiltroDXI + "%"

	//monta a query de busca

	cAliasDXI := GetNextAlias()//verifica se foram selecionados fardos para o bloco da IE
	cQuery := " SELECT DXI.DXI_STATUS,DXI.DXI_FILIAL, DXI.DXI_CODIGO, DXI.DXI_BLOCO, DXI.DXI_PSLIQU, DXI.DXI_CLACOM, DXI.DXI_SAFRA, DXI.DXI_ETIQ, DXI.DXI_VLBASE,DXI.DXI_VLCAGD,DXI.DXI_VADFOL,DXI.DXI_VADCOR,DXI.DXI_VADHVI,DXI.DXI_VADOUT,DXI.DXI_VADTOT,DXI.DXI_TIPPRE,DXI.DXI_EXTCAL, DXI.R_E_C_N_O_ as DXIRECNO, "
	cQuery += " DX7.DX7_RES,DX7.DX7_UHM,DX7.DX7_MIC "
	cQuery += " FROM " + RetSqlName("DXI") + " DXI "
	
    cQuery += "LEFT JOIN " + RetSqlName("DX7") + " DX7 ON "
    cQuery += 				" (DX7.DX7_FILIAL = DXI.DXI_FILIAL" 
    cQuery += 				" AND DX7.DX7_SAFRA  = DXI.DXI_SAFRA" 
    cQuery += 				" AND DX7.DX7_ETIQ   = DXI.DXI_ETIQ"
    cQuery += 				" AND DX7.D_E_L_E_T_ = ' '"
    cQuery += 				" AND DX7.DX7_ATIVO  = '1')"
	
	cQuery += "WHERE DXI.DXI_FILIAL = '"+(cAliasDXD)->DXD_FILIAL+"' "
	cQuery += "AND DXI.DXI_SAFRA  = '"+(cAliasDXD)->DXD_SAFRA+"' "
	cQuery += "AND DXI.DXI_BLOCO  = '"+(cAliasDXD)->DXD_CODIGO+"' "
	cQuery += "AND DXI.DXI_CODRES = '"+(cAliasDXD)->DXP_CODIGO+"' "
	cQuery += "AND DXI.D_E_L_E_T_ <> '*'"
	cQuery += "ORDER BY DXI.DXI_FILIAL, DXI.DXI_SAFRA, DXI.DXI_BLOCO, DXI.DXI_CODIGO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDXI, .F., .T.)


	//apropriação de dados
	DbselectArea( cAliasDXI )
	DbGoTop()
	While ( cAliasDXI )->( !Eof() )
	     DXI->(dbGoTo((cAliasDXI)->DXIRECNO))
		 cMemo := DXI->DXI_EXTCAL

		RecLock((__cTabFar),.T.)

			(__cTabFar)->DXP_ITECAD	:= (cAliasDXD)->DXP_ITECAD
			(__cTabFar)->DXP_STATUS	:= (cAliasDXD)->DXP_STATUS
			(__cTabFar)->DXI_FILIAL	:= (cAliasDXI)->DXI_FILIAL
			(__cTabFar)->DXI_CODIGO	:= (cAliasDXI)->DXI_CODIGO
			(__cTabFar)->DXI_BLOCO  := (cAliasDXI)->DXI_BLOCO
			(__cTabFar)->DXP_CODIGO	:= (cAliasDXD)->DXP_CODIGO
			(__cTabFar)->DXI_PSLIQU	:= (cAliasDXI)->DXI_PSLIQU
			(__cTabFar)->DXI_CLACOM	:= (cAliasDXI)->DXI_CLACOM
			(__cTabFar)->DXI_SAFRA	:= (cAliasDXI)->DXI_SAFRA
			(__cTabFar)->DXP_RECNO	:= (cAliasDXD)->DXPRECNO
			(__cTabFar)->DXI_RECNO	:= (cAliasDXI)->DXIRECNO
			
			(__cTabFar)->DX7_RES	:= (cAliasDXI)->DX7_RES
			(__cTabFar)->DX7_UHM	:= (cAliasDXI)->DX7_UHM
			(__cTabFar)->DX7_MIC	:= (cAliasDXI)->DX7_MIC
			
			
			(__cTabFar)->DESCSTS    := Posicione( "SX5", 1, xFilial( "SX5" ) + "KE" + (cAliasDXI)->DXI_STATUS, "X5_DESCRI" )
			
			nCont++
			nVlrBase  := (cAliasDXI)->DXI_VLBASE
			nVlFol    := (cAliasDXI)->DXI_VADFOL
			nVlcor    := (cAliasDXI)->DXI_VADCOR
			nVlHvi    := (cAliasDXI)->DXI_VADHVI
			nVlOut    := (cAliasDXI)->DXI_VADOUT
			nPesLiq   := (cAliasDXI)->DXI_PSLIQU
			
			 // medias bloco
			 nVl1 := nPesLiq * nVlCor
			 nVl2 := nPesLiq * nVlFol
			 nVl3 := nPesLiq * nVlHvi
			 nVl4 := nPesLiq * nVlOut
			 nVl5 += nVl1 + nVl2 + nVl3 + nVl4
			 nVl7 += nPesLiq * nVlrBase
			 
			 nVlFolM += (nVlFol * nPesLiq)
			 nVlcorM += (nVlcor * nPesLiq)
			 nVlHviM += (nVlHvi * nPesLiq)
			 nVlOutM += (nVlOut * nPesLiq)
			 
			 nPeso += nPesLiq
			 nFix := aScan(__aBlocosFix,{|x| allTrim(x[1]) == alltrim( (cAliasDXD)->(DXD_FILIAL+DXD_SAFRA+DXD_CODIGO) ) }  )
             If (cAliasDXI)->DXI_TIPPRE = "1"
                cTipP := STR0056
             ElseIf (cAliasDXI)->DXI_TIPPRE = "2"
                cTipP := STR0057
             ElseIf (cAliasDXI)->DXI_TIPPRE = "3"
               cTipP := STR0058       
             EndIf
			
			(__cTabFar)->DXI_VLBASE	:= (cAliasDXI)->DXI_VLBASE //Valor base
            (__cTabFar)->DXI_VADTOT	:= (cAliasDXI)->DXI_VADTOT // Valor agio/desagio Total 
			(__cTabFar)->DXI_VLCAGD	:= (cAliasDXI)->DXI_VLCAGD ////Valor com agio/desagio ok
			(__cTabFar)->TMP_VLRTOT	:= AGRX001((cAliasDXD)->NJR_UM1PRO, (cAliasDXD)->NJR_UMPRC,(__cTabFar)->DXI_PSLIQU, (cAliasDXD)->NJR_CODPRO	) * (__cTabFar)->DXI_VLCAGD
            (__cTabFar)->DXI_VADFOL	:= (cAliasDXI)->DXI_VADFOL //valor folha
			(__cTabFar)->DXI_VADCOR	:= (cAliasDXI)->DXI_VADCOR //valor cor
			(__cTabFar)->DXI_VADHVI	:= (cAliasDXI)->DXI_VADHVI //valor HVI
			(__cTabFar)->DXI_VADOUT	:= (cAliasDXI)->DXI_VADOUT //valor Outros
            (__cTabFar)->TMP_MSG    := allTrim(cMemo) // msg
            (__cTabFar)->DXI_TIPPRE	:= cTipP // tipo preço
            (__cTabFar)->DXI_ETIQ	:= (cAliasDXI)->DXI_ETIQ
            
		(__cTabFar)->(MsUnlock())

		(cAliasDXI)->(dbSkip())
	EndDo
	
	(__cTabBlc)->TMP_PSLIQU := nPeso
    (__cTabBlc)->DXI_VLBASE	:= nVl7/nPeso //Valor base media
    (__cTabBlc)->DXI_VLCAGD	:= nVl5/nPeso + (__cTabBlc)->DXI_VLBASE //Valor com agio/desagio 
    (__cTabBlc)->TMP_QTDFAR := nCont // qtd fardos
    (__cTabBlc)->DXI_VADTOT	:= nVl5/nPeso //Valor agio/desagio Total 
	(__cTabBlc)->DXI_VADFOL	:= nVlFolM/nPeso //valor folha media
	(__cTabBlc)->DXI_VADCOR	:= nVlcorM/nPeso //valor cor media 
	(__cTabBlc)->DXI_VADHVI	:= nVlHviM/nPeso //valor HVI media
	(__cTabBlc)->DXI_VADOUT	:= nVlOutM/nPeso //valor Outros media                             
	(__cTabBlc)->TMP_VLRTOT	:= AGRX001((cAliasDXD)->NJR_UM1PRO, (cAliasDXD)->NJR_UMPRC,(__cTabBlc)->TMP_PSLIQU, (cAliasDXD)->NJR_CODPRO)* (nVl5/nPeso + (__cTabBlc)->DXI_VLBASE)//valor do bloco 
    
    If nFix > 0 
	   __nVlrBaseFix := (__cTabBlc)->DXI_VLCAGD
	EndIf
	
	(cAliasDXI)->(dbCloseArea())

return

/*{Protheus.doc} OGC040DB
Marcação de itens por Double Click
@author jean.schulze
@since 11/08/2017
@version undefined
@param oBrwObj, object, descricao
@param cBrwName, characters, descricao
@type function
*/
static function OGC040DB(oBrwObj, cBrwName)
	Local cOperDat := ""

	Do Case
	case cBrwName == "B"	//blocos

		if RecLock((__cTabBlc),.F.)	.and. !empty((__cTabBlc)->DXD_CODIGO) //tratamento de excessao - sempre posicionado
			(__cTabBlc)->MARK = IIF((__cTabBlc)->MARK  == "1", "", "1")
			MsUnlock()
		endif

		/*Update for fardos*/
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO+(__cTabFar)->DXP_CODIGO)
			cOperDat := (__cTabBlc)->MARK
			While !(__cTabFar)->(Eof()) .and. (__cTabBlc)->DXD_CODIGO == (__cTabFar)->DXI_BLOCO

				If RecLock((__cTabFar),.f.)
					(__cTabFar)->MARK = cOperDat
					MsUnlock()
				EndIf

				(__cTabFar)->( dbSkip() )
			enddo
		endif

	case cBrwName == "F"   	//fardos

		if RecLock((__cTabFar),.F.)	.and. !empty((__cTabFar)->DXI_CODIGO) //tratamento de excessao - sempre posicionado
			(__cTabFar)->MARK = IIF((__cTabFar)->MARK  == "1", "", "1")
			MsUnlock()
		endif

	endCase
return

/*{Protheus.doc} OGC040HD
Marcação de itens no Header do Browse
@author jean.schulze
@since 11/08/2017
@version undefined
@param objBrowser, object, descricao
@param cBrwName, characters, descricao
@type function
*/
Static Function OGC040HD(objBrowser, cBrwName)
	Local cOperDat := 0

	Do Case
	case cBrwName == "B"	//blocos

		DbSelectArea((__cTabBlc))
		DbGoTop()
		If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO)
			cOperDat := IIF((__cTabBlc)->MARK  == "1", "", "1")
			While !(__cTabBlc)->(Eof())
				If RecLock((__cTabBlc),.f.)
					(__cTabBlc)->MARK = cOperDat
					MsUnlock()
				EndIf
				(__cTabBlc)->( dbSkip() )
			enddo
		endif

		/*Update for fardos*/
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXP_CODIGO+(__cTabFar)->DXI_CODIGO)
			cOperDat := IIF((__cTabFar)->MARK  == "1", "", "1")
			While !(__cTabFar)->(Eof())

				If RecLock((__cTabFar),.f.)
					(__cTabFar)->MARK = cOperDat
					MsUnlock()
				EndIf

				(__cTabFar)->( dbSkip() )
			enddo
		endif

	case cBrwName == "F"  	//fardos

		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXP_CODIGO+(__cTabFar)->DXI_CODIGO)
			cOperDat := IIF((__cTabFar)->MARK  == "1", "", "1")
			While !(__cTabFar)->(Eof())

				If RecLock((__cTabFar),.f.)
					(__cTabFar)->MARK = cOperDat
					MsUnlock()
				EndIf

				(__cTabFar)->( dbSkip() )
			enddo
		endif

	endCase

return

/*{Protheus.doc} OGC040UP
Função de Update do Browse
@author jean.schulze
@since 11/08/2017
@version undefined
@param objBrowser, object, descricao
@param lUpdAll, logical, descricao
@type function
*/
static function OGC040UP(objBrowser, lUpdAll) //tratamento de refresh
	Default lUpdAll := .t.

	if lUpdAll
		objBrowser:UpdateBrowse() //reconstroi tudo
	else
		objBrowser:LineRefresh() //só refaz a linha
	endif
	objBrowser:GoColumn(1)
return .t.

/*{Protheus.doc} OGC040REMF
Remoção de fardos dos blocos
@author jean.schulze
@since 11/08/2017
@version undefined
@type function
*/
Static Function OGC040REMF()
	Local aFardos 		:= {} //fardos que serão desvinculados
	Local cMotivo 		:= ""
	local nPos    		:= 0
	Local nQtdFar 		:= 0
	Local lRet    		:= .t.
	Local aFardTkp		:= {}
	Local aFardEmbar	:= {}

	DbSelectArea((__cTabFar))
	DbGoTop()
	If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXP_CODIGO+(__cTabFar)->DXI_CODIGO)
		While !(__cTabFar)->(Eof())
			if (__cTabFar)->MARK == "1" //selecionado

			 	if  (nPos := aScan(aFardos,{|x| allTrim(x[1]) == alltrim((__cTabFar)->DXP_RECNO) })) > 0
			 		aADD(aFardos[nPos][2], (__cTabFar)->DXI_RECNO ) //Quebra por reserva
			 	else
			 		aADD(aFardos, { (__cTabFar)->DXP_RECNO,  { (__cTabFar)->DXI_RECNO} }) //recno de reserva e fardo
			 	endif
			 	
			 	If "2" $ (__cTabFar)->DXP_STATUS // Se forem fardos com take-up efetuado
			 		aAdd(aFardEmbar, {(__cTabFar)->DXI_FILIAL, (__cTabFar)->DXI_SAFRA, (__cTabFar)->DXI_ETIQ, "04", (__cTabFar)->DXI_CODIGO, _cFilCtr} ) // Fardos para validação de instrução de embarque
			 		aAdd(aFardTkp, {(__cTabFar)->DXI_FILIAL, (__cTabFar)->DXI_SAFRA, (__cTabFar)->DXI_ETIQ, "02", _cCodCtr, _cFilCtr} )
			 	EndIf
			 			 	
			 	nQtdFar ++
			endif
			(__cTabFar)->( dbSkip() )
		EndDo
	EndIF
	
	If !Empty(aFardEmbar) .AND. !OGC040VEMB(aFardEmbar) // Valida se os fardos possuem instrução de embarque
		OGC040UP(oBrowse1)
		OGC040UP(oBrowse2)
		Return .T.
	EndIf

	if nQtdFar > 0
		//questiona se quer de fato aplica a remoção dos fardos
		if !empty(cMotivo := AGR720HIS(STR0030 , STR0031 + "("+alltrim(str(nQtdFar))+")"))
			//cMotivo
			lRet := OGC040RFAR(aFardos, cMotivo, _cCodCtr, aFardTkp)

			if lRet

				//processo deu certo MsgInfo
				MsgInfo ( STR0033, STR0034)

				//refaz a consulta
				Processa({|| fGetDados()},STR0019)

			else
				//Houve um erro durante a retirada dos fardos.
				Help('',1,"OGC040REM3")
			endif

		else
			//para remover os fardos vinculados é necessário informar um motivo
			Help('',1,"OGC040REM2")
		endif
	else
		//informe os fardos a serem removidos do contrato
		Help('',1,"OGC040REM1")
	endif

	//ATUALIZA OS BROWSER
	OGC040UP(oBrowse1)
	OGC040UP(oBrowse2)

return .t.

/*{Protheus.doc} OGC040RFAR
Desvinculação de fardos.
@author jean.schulze
@since 11/08/2017
@version undefined
@param aFardos, array, descricao
@param cMotivo, characters, descricao
@type function
*/
Function OGC040RFAR(aFardos, cMotivo, cKeyCtr, aFardTkp)
	Local nX       := 0
	Local nI       := 0
	Local cHistRes := ""
	Local cHistCtr := ""
	Local cIteRes  := ""
	Local cCodRes  := ""
	Local lRet     := .t.

	Default cKeyCtr 	:= "" //chave de busca do contrato
	Default aFardTkp 	:= {}
	
	//valida as notas (romaneio confirmado -  fase 2)
	//verifica a consistencia conforme os dados passados

	BEGIN TRANSACTION

		 cHistCtr += STR0040 + cKeyCtr + CHR(13)+CHR(10)
		 
		 If !Empty(aFardTkp) // Se possue fardos com take-up efetuado, remove da previsão de entrega e das regras fiscais, inativando a movimentação de fardos
			 lRet := AGRA720INAT(aFardTkp)
		 EndIf

		 For nX := 1 to Len(aFardos)

		 	if lRet //trata a transação
			 	//select reservas
			 	if (Select("DXP") == 0)
					DbSelectArea("DXP")
				endif

			 	DXP->(dbGoto(aFardos[nX][1]))

				If !DXP->(EOF()) .and. !DXP->(BOF())
					//reset
					cHistRes := STR0035 + CHR(13)+CHR(10)
					cHistRes += STR0036 + cMotivo + CHR(13)+CHR(10)
					cHistRes += STR0037 + CHR(13)+CHR(10)

					//histórico contrato
					cHistCtr += STR0041 + DXP->DXP_CODIGO + CHR(13)+CHR(10)
					if !empty(DXP->DXP_DATTKP) .and.  !empty(DXP->DXP_HORTKP)
					   cHistCtr += STR0042 + DToC(DXP->DXP_DATTKP) + " " + DXP->DXP_HORTKP + CHR(13)+CHR(10)
					endif
					cHistCtr += STR0036 + cMotivo + CHR(13)+CHR(10)
					cHistCtr += STR0037 + CHR(13)+CHR(10)

					for nI := 1 to Len( aFardos[nX][2] )

						if lRet //trata a transação

							if (Select("DXI") == 0)
								DbSelectArea("DXI")
							endif

						 	DXI->(dbGoto(aFardos[nX][2][nI]))

						 	//se não está no final, nem no começo do arquivo
						 	If !DXI->(EOF()) .and. !DXI->(BOF())

						 		//libera o uso e monta a mensagem
						 		cHistRes += STR0038 + DXI->DXI_ETIQ + ", " + STR0039 + DXI->DXI_BLOCO + CHR(13)+CHR(10)
						 		cHistCtr += STR0038 + DXI->DXI_ETIQ + ", " + STR0039 + DXI->DXI_BLOCO + CHR(13)+CHR(10)

						 		//guarda a relaçao
						 		cIteRes := DXI->DXI_ITERES
						 		cCodRes := DXI->DXI_CODRES
						 		cItemFx := DXI->DXI_ITEMFX
						 		cSeqVnc := DXI->DXI_ORDENT
						 		
								//Remove os fardos da Reserva na tabela de fardos vinculados a regra BCI
				                		OGC080EXET( DXI->DXI_FILIAL,  DXI->DXI_SAFRA, DXI->DXI_ETIQ )

						 		//reset valor
					 		  	RecLock( "DXI", .F. )
									DXI->DXI_CODRES := ""
									DXI->DXI_ITERES := ""
									DXI->DXI_VLBASE := 0 //valor usado no cálculo
					 				DXI->DXI_VADFOL := 0 //AD Folha
					 				DXI->DXI_VADCOR := 0 //AD Cor
					 				DXI->DXI_VADHVI := 0 //AD HVI
					 				DXI->DXI_VADOUT := 0//AD Outros 
					 				DXI->DXI_VADTOT := 0// agio/deságio total
					 				DXI->DXI_VLCAGD := 0 // agio/deságio total
					 				DXI->DXI_EXTCAL := ""
					 				DXI->DXI_TIPPRE := ""									
								DXI->(MsUnLock())

								//diminui a quantidade na DXQ
								if (Select("DXQ") == 0)
									DbSelectArea("DXQ")
								endif

								DXQ->(DbSetOrder(1))
								If DXQ->(DbSeek(DXP->DXP_FILIAL+cCodRes+cIteRes))
									RecLock( "DXQ", .F. )
										DXQ->DXQ_QUANT  := DXQ->DXQ_QUANT  - 1
										DXQ->DXQ_PSLIQU := DXQ->DXQ_PSLIQU - DXI->DXI_PSLIQU
										DXQ->DXQ_PSBRUT := DXQ->DXQ_PSBRUT - DXI->DXI_PSBRUT
									DXQ->(MsUnLock())
								else
									//faz tudo ou nao faz nada
									DisarmTransaction()
									lRet := .f.
								endif
								
								//remove as implementações na vinculação de fardos
								IF (Select("N8D") == 0)
									DbSelectArea("N8D")
								endif	
								N8D->( dbSetOrder(2) ) 	//N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D->N8D_ORDEM
								if N8D->(DbSeek(fwxFilial("N8D") + cKeyCtr + cItemFx + cSeqVnc))
									RecLock( "N8D", .F. )
										N8D->N8D_QTDFAR := N8D->N8D_QTDFAR - 1
										N8D->N8D_QTDVNC := N8D->N8D_QTDVNC - DXI->DXI_PSLIQU
										N8D->N8D_QTDBTO := N8D->N8D_QTDBTO - DXI->DXI_PSBRUT
									N8D->(MsUnLock())	
								endif
											
						 	else
						 		//faz tudo ou nao faz nada
						 		DisarmTransaction()
						 		lRet := .f.
						 	endif
					 	endif                                                                                                                                                                                                                                                                                                                                                                                                                              


					next nI

				    //grava o histórico
				    AGRGRAVAHIS(,,,,{"DXP",DXP->DXP_FILIAL+DXP->DXP_CODIGO,"4",cHistRes})

				    cHistCtr += CHR(13)+CHR(10)
				else
				   //faz tudo ou nao faz nada
				   DisarmTransaction()
				   lRet := .f.
				endif

			 endif

		 next nx

		 if lRet .and. !empty(cKeyCtr) //grava no histórico no contrato
		 	AGRGRAVAHIS(,,,,{"NJR",FWxFilial("NJR")+cKeyCtr,"4",cHistCtr})
		 endif
		 
		  //recalcula o ágio e deságio
		 Processa({|| OGX016(FwxFilial("NJR"), cKeyCtr) }, STR0059)
		 
		 OGX055(FwxFilial("NJR"),cKeyCtr) //recalcula os valores das regras fiscais
		 
	END TRANSACTION

return lRet

/** {Protheus.doc} SetDataBlc
Função que monta as Temp-Tables da Rotina
@param:     aCpsBrow - Estrutura da tabela
            aIdxTab - Campos do índices
@return:    String - Nome do Alias criado para a tabela temporária
@author:    Equipe Agro
@since:     17/11/2017
@Uso:       OGC040 - Consulta de Blocos/Fardos
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

/** {Protheus.doc} OGC040HIAG()
Função para mostrar as informações de histórico de ágio/deságio no doubleclick
@param:     Nil
@return:    boolean - True ou False
@author:    Niara Caetano
@since:     16/08/2017
@Uso:       OGC040 - Consulta de Blocos/Fardos
*/
Static Function OGC040HIAG(cbrowse)
    Local cHist   := ''
    Local lRet    := .T.

	if cbrowse == "brw2"
		If allTrim((__cTabFar)->TMP_MSG) != ''

			cHist := UPPER(STR0051) + " " + _cCodCtr + CRLF   //"SIMULAÇÃO DO CONTRATO NR."

			cHist += ".............................................." + CRLF
			cHist += STR0003 + ": " + (__cTabFar)->DXI_BLOCO  + CRLF                      //"Bloco"
			cHist += STR0006 + ": " + (__cTabFar)->DXI_CODIGO + CRLF                      //"Fardo"
			cHist += STR0007 + ": " + allTrim(str((__cTabFar)->DXI_PSLIQU)) + CRLF        //"Peso líquido"
			cHist += STR0054 + ": " + allTrim(Str((__cTabFar)->DXI_VLCAGD)) + CRLF + CRLF //"Valor total com ágio/deságio"
			cHist += STR0053 + ": " + CRLF + CRLF  + allTrim((__cTabFar)->TMP_MSG)        //"Extrato de processamento"

			Aviso(UPPER(STR0052),cHist,{},3)	  //Extrato processamento ágio/deságio

		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} OGC004FOC
//Posiciona na primeira coluna dos browsers.
@author marcelo.ferrari
@since 21/11/2017
@version 1.0
@return ${return}, ${return_description}
@param tGrid, , descricao
@type function
/*/
Static Function OGC004FOC(tGrid)
	tGrid:GoColumn(1)
Return

/*{Protheus.doc} OGC040VEMB
//Verifica se os fardos possuem instrução de embarque.
@author roney.maia
@since 06/03/2018
@version 1.0
@return ${return}, ${.T. - Válido, .F. - Inválido}
@param aFardos, array, Array de fardos a serem validados
@param cTitulo, array, Titulo da mensagem de aviso
@type function
*/
Function OGC040VEMB(aFardos, cTitulo)
	
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cMsg		:= ""
	Local cCodigo	:= ""
	Local nPos		:= 0
	Local cChave	:= ""
	Local cAvisTit	:= ""
    Local cFilter   := "N9D->N9D_TIPMOV == '04' .AND. N9D->N9D_CODINE != '' .AND. N9D->N9D_STATUS='2' .AND. N9D->N9D_CODCTR == '" + DXP->DXP_CODCTP + "' .AND. N9D->N9D_ITEETG == '" + DXP->DXP_ITECTP + "'"
	
	Default cTitulo := ""


	If !Empty(cTitulo)
		cAvisTit := cTitulo
	Else
		cAvisTit := STR0029 // # "Remover Fardos"
	EndIf
	
	dbSelectArea("N9D")
    N9D->(dbSetFilter({|| &cFilter }, cFilter))
	N9D->(dbGoTop())
	
	If !N9D->(EOF())
		lRet := .F.  // Se houver fardos com instrução então está inválido para remoção
		// # "Os seguintes fardos abaixo possuem instrução de embarque. Para prosseguir com a remoção, será necessário removê-los anteriormente da instrução de embarque."
		cMsg += STR0060 + CRLF + CRLF
		cMsg += STR0061 + ":" + CRLF // # "Fardos listados"
		
		While !N9D->(EOF())
			// Monta chave do fardo para localizar no array e obter o código para montar a mensagem de aviso
			cChave	:= AllTrim(N9D->N9D_FILIAL) + AllTrim(N9D->N9D_SAFRA) + AllTrim(N9D->N9D_FARDO)
			cCodigo := ""
			If (nPos := aScan(aFardos, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3])) == cChave })) > 0 // Busca de etiqueta para obter o codigo do fardo
				cCodigo := aFardos[nPos][5] // Obtém o codigo do fardo para apresentar na mensagem
			EndIf
			If !Empty(cCodigo)
				cMsg += STR0002 + ": " + AllTrim(N9D->N9D_FILIAL) + ; // "Filial"
				 "  " + STR0006 + ": " + AllTrim(cCodigo) + ; // "Fardo"
				 "  " + STR0005 + ": " + AllTrim(N9D->N9D_SAFRA) + ; // Safra
				 "  " + STR0062 + ": " + AllTrim(N9D->N9D_FARDO) + CRLF // # Etiqueta
			EndIf
			N9D->(dbSkip())
		EndDo

		Aviso(cAvisTit, cMsg) // Apresenta tela de aviso 
		
	Else
		lRet := .T. // Se não houver fardos com instrução, então está valido
	EndIf
	
	N9D->( dbCloseArea() )
	
	RestArea(aArea)

Return lRet
