#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGAA900.ch'

Static __cTabTmp := ""
Static __cNamTmp := ""

/*/{Protheus.doc} InsRegDoc()
Função para dar manutenção nos itens do Plano de vendas através do painel de acompanhamento.
@type  Static Function
@author rafael.kleestadt / tamyris.g
@since 11/09/2018
@version 1.0
@param cUnineg, caractere, código da unidade de negócio do registro posicionado no painel de acompanhamento
@param cGrpProd, caractere, código do grupo de produtos do registro posicionado no painel de acompanhamento
@param cCodPro, caractere, código do produto do registro posicionado no painel de acompanhamento
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGAA900(cUnineg, cGrpProd, cCodPro)
	Local cNmProd := AllTrim(Posicione("SB1",1,FwxFilial("SB1")+cCodPro,"B1_DESC"))
	Local cNmGPro := AllTrim(Posicione("SBM",1,FwxFilial("SBM")+cGrpProd,"BM_DESC"))
	Local cNmUnNg := AllTrim(Posicione("ADK",1,FwxFilial("ADK")+cUnineg,"ADK_NOME"))

	Private _cUnineg  := cUnineg
	Private _cGrpProd := cGrpProd
	Private _cCodPro  := cCodPro
	Private _cTitle   := ""

	_cTitle := IIF(Empty(cNmUnNg), AllTrim(cUnineg), cNmProd) + "-" + cNmGPro + "-" + cNmProd

	CriaBrowser()

Return .T.

/*/{Protheus.doc} InsRegDoc()
Função para criar a estrutura da tabela temporária e tela
@type  Static Function
@author rafael.kleestadt
@since 11/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaBrowser()
	Local aAreaAtu      := GetArea()
	Local oSize         := Nil
	Local oDlg          := Nil
	Local aButtons      := {}
	Local aStrcTmp      := {}
	Local aIndTmp       := {}
	Local aFilBrwTmp    := {}
	Local nCont  		:= 0
	Local aCoors        := FWGetDialogSize( oMainWnd )

	Private _oBrowse1   := Nil
	Private _oGet1		:= Nil
	Private _oGet2		:= Nil
	Private _oGet3		:= Nil
	Private _nVolDisp	:= 0
	Private _nTotPer	:= 0
	Private _nTotPv   	:= 0

    //-------------------------------Estrutura da Tabela-----------------------------------//
	AAdd(aStrcTmp, {RetTitle("N8W_SAFRA"),  "T_SAFRA",  TamSX3("N8W_SAFRA")[3],  TamSX3("N8W_SAFRA")[1],  TamSX3("N8V_SAFRA")[2],  PesqPict("N8V","N8W_SAFRA")})
    AAdd(aStrcTmp, {RetTitle("N8V_CODPLA"), "T_CODPLA", TamSX3("N8V_CODPLA")[3], TamSX3("N8V_CODPLA")[1], TamSX3("N8V_CODPLA")[2], PesqPict("N8V","N8V_CODPLA")})
	AAdd(aStrcTmp, {RetTitle("N8W_FILIAL"), "T_UNINEG", TamSX3("N8W_FILIAL")[3], TamSX3("N8W_FILIAL")[1], TamSX3("N8W_FILIAL")[2], PesqPict("N8W","N8W_FILIAL")})
	AAdd(aStrcTmp, {RetTitle("N8W_GRPROD"), "T_GRPPRO", TamSX3("N8W_GRPROD")[3], TamSX3("N8W_GRPROD")[1], TamSX3("N8W_GRPROD")[2], PesqPict("N8W","N8W_GRPROD")})
	AAdd(aStrcTmp, {RetTitle("N8W_CODPRO"), "T_CODPRO", TamSX3("N8W_CODPRO")[3], TamSX3("N8W_CODPRO")[1], TamSX3("N8W_CODPRO")[2], PesqPict("N8W","N8W_CODPRO")})
	AAdd(aStrcTmp, {RetTitle("N8W_MESANO"), "T_MESANO", TamSX3("N8W_MESANO")[3], TamSX3("N8W_MESANO")[1], TamSX3("N8W_MESANO")[2], PesqPict("N8W","N8W_MESANO")})
	AAdd(aStrcTmp, {RetTitle("N8W_TIPMER"), "T_TIPMER", TamSX3("N8W_TIPMER")[3], TamSX3("N8W_TIPMER")[1], TamSX3("N8W_TIPMER")[2], PesqPict("N8W","N8W_TIPMER")})
	AAdd(aStrcTmp, {RetTitle("N8W_TIPMER"), "T_DTPMER", TamSX3("N8W_TIPMER")[3], 2, 0, PesqPict("N8W","N8W_TIPMER")})
	AAdd(aStrcTmp, {RetTitle("N8W_MOEDA"),  "T_MOEDA",  TamSX3("N8W_MOEDA")[3],  TamSX3("N8W_MOEDA")[1],  TamSX3("N8W_MOEDA")[2],  PesqPict("N8W","N8W_MOEDA")})
	AAdd(aStrcTmp, {RetTitle("N8W_MOEDA") , "T_DMOEDA", "C" , 6 , 0 , "@!"})
    AAdd(aStrcTmp, {RetTitle("N8W_PERVEN"), "T_PERVEN", TamSX3("N8W_PERVEN")[3], TamSX3("N8W_PERVEN")[1], TamSX3("N8W_PERVEN")[2], PesqPict("N8W","N8W_PERVEN")})
	AAdd(aStrcTmp, {RetTitle("N8W_QTPRVE"), "T_QTPRVE", TamSX3("N8W_QTPRVE")[3], TamSX3("N8W_QTPRVE")[1], TamSX3("N8W_QTPRVE")[2], PesqPict("N8W","N8W_QTPRVE")})
	AAdd(aStrcTmp, {"" , "T_RECNO" , "N" , 20 , 0 , "@!"})
	
    // Definição dos índices da tabela
	aIndTmp := {{"", "T_UNINEG, T_SAFRA, T_CODPLA, T_GRPPRO, T_CODPRO"}}

	Processa({|| OG710ACTMP(@__cTabTmp, @__cNamTmp, aStrcTmp, aIndTmp)}, STR0004) //"Aguarde. Criando a Tabela..."

	// Carrega os registros das tabelas temporárias.
	Processa({|| InsRegDoc()}, STR0005) //Aguarde. "Selecionando as Dados Disponíveis..."

    aHeader := {}
	
 	For nCont := 2  to Len(aStrcTmp)
		IF !aStrcTmp[nCont][2] $ "T_SAFRA|T_CODPLA|T_UNINEG|T_TIPMER|T_MOEDA|T_GRPPRO|T_CODPRO|T_RECNO"
			Aadd(aHeader, {aStrcTmp[nCont][1], &("{||"+aStrcTmp[nCont][2]+"}"), aStrcTmp[nCont][3], aStrcTmp[nCont][6], IIF(aStrcTmp[nCont][2] == "T_AGRUPA", 1, 2), aStrcTmp[nCont][4], aStrcTmp[nCont][5], .F.})
			Aadd(aFilBrwTmp, {aStrcTmp[nCont][2], aStrcTmp[nCont][1], aStrcTmp[nCont][3], aStrcTmp[nCont][4], aStrcTmp[nCont][5], aStrcTmp[nCont][6]})
		EndIf
	Next nCont

	oSize := FwDefSize():New()
	oSize:SetWindowSize(aCoors)
	oSize:AddObject( "P1", 100, 15, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 70, .t., .t., .t. )
	oSize:AddObject( "P3", 100, 15, .t., .t., .t. )
	oSize:lProp     := .T.
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ] /* * 0.90 */, oSize:aWindSize[ 4 ]/*  * 0.80 */, STR0006,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Alterar Item do Plano de Vendas"

	oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ) /* * 0.90 */,oSize:GetDimension( "P1", "YSIZE" )/*  * 0.80 */ )
	oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ) /* * 0.90 */,oSize:GetDimension( "P2", "YSIZE" )/*  * 0.80 */ )
	oPnTres := tPanel():New( oSize:GetDimension( "P3", "LININI" ), oSize:GetDimension( "P3", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P3", "XSIZE" ) /* * 0.90 */,oSize:GetDimension( "P3", "YSIZE" )/*  * 0.80 */ )

	TSay():New( 005, 10, {|| OemToAnsi( _cTitle ) } , oPnUm, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 )
	
	TSay():New( 015, 10, {|| OemToAnsi( STR0007 ) } , oPnUm, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 030 ) //"Volume Disponível"
	_oGet1 := TGet():New( 025, 10,bSetGet(_nVolDisp), oPnUm,096,010,PesqPict( "N8W", "N8W_QTPRVE" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"nVolDisp")
	TSay():New( 005, 10, {|| OemToAnsi( STR0008 ) } , oPnTres, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 030 ) //"Total % Prev. Venda"
	_oGet2 := TGet():New( 015, 10,bSetGet(_nTotPer), oPnTres,096,010,PesqPict( "N8W", "N8W_PERVEN" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"nTotPer")
	TSay():New( 005, 110, {|| OemToAnsi( STR0009 ) }, oPnTres, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 030 ) //"Total Qtd. Prev. Venda"
	_oGet3 := TGet():New( 015, 110,bSetGet(_nTotPv), oPnTres,096,010,PesqPict( "N8W", "N8W_QTPRVE" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"nTotPv")

	_oBrowse1 := FWFormBrowse():New()
	_oBrowse1:SetOwner(oPnDois)
	_oBrowse1:SetDataTable(.T.)
    _oBrowse1:SetTemporary(.T.)
    _oBrowse1:SetAlias(__cTabTmp)
    _oBrowse1:SetProfileID("DOC")
    _oBrowse1:DisableDetails()    
    _oBrowse1:Acolumns := {}
    _oBrowse1:SetColumns(aHeader)         
    _oBrowse1:DisableReport(.T.)                              
    _oBrowse1:SetFieldFilter(aFilBrwTmp)
    
    _oBrowse1:Activate()
    _oBrowse1:Enable()
	_oBrowse1:Refresh(.T.)

    _oBrowse1:SetFocus()  // Focus no browser de Finalidades - Principal
	_oBrowse1:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação 

    _oBrowse1:SetEditCell(.T., {|| .T. })//indica que o grid e editavel
	_oBrowse1:Acolumns[4]:SetEdit(.T.)
	_oBrowse1:Acolumns[4]:bValid := {|| fCalcPerc(__lCalcQtPr := .F.)}
    _oBrowse1:Acolumns[4]:SetReadVar("T_PERVEN")
	_oBrowse1:Acolumns[5]:SetEdit(.T.)
	_oBrowse1:Acolumns[5]:bValid := {|| fCalcQtPr(__lCalcPerc := .F.)}
    _oBrowse1:Acolumns[5]:SetReadVar("T_QTPRVE")

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| If( OGAA900OK(), oDlg:End(), Nil) },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

RestArea(aAreaAtu)
Return .T.

/*/{Protheus.doc} InsRegDoc()
Função para dar a carga inicial na tabela temporária que alimenta os dados da tela.
@type  Static Function
@author rafael.kleestadt
@since 11/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function InsRegDoc()

// Limpa a tabela temporária
DbSelectArea(__cTabTmp)
(__cTabTmp)->(DbSetorder(1))
ZAP

//------------------Carga Tabela------------------//
dbSelectArea("N8W")
N8W->(dbSetOrder(3))
If N8W->(dbSeek(N8V->N8V_FILIAL + N8V->N8V_SAFRA + N8V->N8V_CODPLA + DTOS(N8V->N8V_DATATU) ))
	While N8W->(!EOF()) .And. N8W->(N8W_FILPLA + N8W_SAFRA + N8W_CODPLA) == N8V->(N8V_FILIAL + N8V_SAFRA + N8V_CODPLA) .And. N8W->N8W_DTATUA == N8V->N8V_DATATU

		If N8W->N8W_FILIAL == _cUnineg .And. N8W->N8W_GRPROD == _cGrpProd .And. N8W->N8W_CODPRO == _cCodPro
			RecLock(__cTabTmp, .T.)
	            (__cTabTmp)->T_RECNO   := N8W->( RecNo() )
	            (__cTabTmp)->T_SAFRA   := N8W->N8W_SAFRA
				(__cTabTmp)->T_CODPLA  := N8W->N8W_CODPLA
				(__cTabTmp)->T_UNINEG  := N8W->N8W_FILIAL
				(__cTabTmp)->T_MESANO  := N8W->N8W_MESANO
				(__cTabTmp)->T_GRPPRO  := N8W->N8W_GRPROD
				(__cTabTmp)->T_CODPRO  := N8W->N8W_CODPRO
				(__cTabTmp)->T_TIPMER  := N8W->N8W_TIPMER
				(__cTabTmp)->T_DTPMER  := IIF(N8W->N8W_TIPMER == "1", "MI", "ME")
				(__cTabTmp)->T_MOEDA   := N8W->N8W_MOEDA
				(__cTabTmp)->T_DMOEDA  := SuperGetMv("MV_SIMB"+AllTrim(Str(N8W->N8W_MOEDA,2)))
				(__cTabTmp)->T_PERVEN  := N8W->N8W_PERVEN
				(__cTabTmp)->T_QTPRVE  := N8W->N8W_QTPRVE
			(__cTabTmp)->(MsUnlock())

			_nTotPer += N8W->N8W_PERVEN
			_nTotPv  += N8W->N8W_QTPRVE
		EndIF
		
		N8W->(DbSkip())
	EndDo
EndIf
N8W->(DbCloseArea())
								  //N8Y_FILIAL+N8Y_SAFRA+N8Y_CODPLA+N8Y_GRPROD+N8Y_CODPRO+DTOS(N8Y_DTATUA)
_nVolDisp := Posicione( "N8Y", 1, _cUnineg+N8V->(N8V_SAFRA+N8V_CODPLA+_cGrpProd+_cCodPro+DTOS(N8V_DATATU)), "N8Y_QTDCOM")

Return .T.

/*/{Protheus.doc} fCalcQtPr()
Função para atualizar a variavel privada que alimenta o campo "Total % Prev. Venda"
@type  Static Function
@author rafael.kleestadt
@since 12/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcPerc()
Local aArea := GetArea()

_nTotPer := 0

DbSelectArea(__cTabTmp)

If RecLock(__cTabTmp, .F.)
	(__cTabTmp)->T_QTPRVE := _nVolDisp / (100 / (__cTabTmp)->T_PERVEN)
	(__cTabTmp)->(MsUnlock())
EndIf

(__cTabTmp)->(DbGoTop())
While (__cTabTmp)->(! EOF())

	_nTotPer += (__cTabTmp)->T_PERVEN

	(__cTabTmp)->(DbSkip())
EndDo

__lCalcPerc := .T.

If .Not. __lCalcQtPr
	fCalcQtPr()
EndIf

RestArea(aArea)
Return .T.

/*/{Protheus.doc} fCalcQtPr()
Função para atualizar a variavel privada que alimenta o campo "Total Qtd. Prev. Venda"
@type  Static Function
@author rafael.kleestadt
@since 12/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcQtPr()
Local aArea := GetArea()

_nTotPv := 0

DbSelectArea(__cTabTmp)

If RecLock(__cTabTmp, .F.)
	(__cTabTmp)->T_PERVEN := (100 * (__cTabTmp)->T_QTPRVE) / _nVolDisp
	(__cTabTmp)->(MsUnlock())
EndIf

(__cTabTmp)->(DbGoTop())
While (__cTabTmp)->(! EOF())

	_nTotPv += (__cTabTmp)->T_QTPRVE

	(__cTabTmp)->(DbSkip())
EndDo

__lCalcQtPr := .T.

If .Not. __lCalcPerc
	fCalcPerc()
EndIf
RestArea(aArea)
Return .T.


/*/{Protheus.doc} OGAA900OK()
Valida e salva os valores na tabela
@type  Static Function
@author user
@since date
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA900OK()
	Local aArea := GetArea()
	
	If _nTotPv > _nVolDisp
		Help( , , STR0001, , STR0002, 1, 0 ) //""A Soma da Qtd Prev Venda não pode ser maior que o Volume Disponível"
		Return .F.
	EndIF
	
	If Round(_nTotPer,2) <> 100
		Help( , , STR0001, , STR0003, 1, 0 ) //""Soma do % de Venda deve ser igual a 100%"                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
		Return .F.
	EndIF
	
	(__cTabTmp)->(DbGoTop())
	While (__cTabTmp)->(! EOF())
	
		dbSelectArea("N8W")
		N8W->(dbGoTop())
		N8W->(DbGoTo( (__cTabTmp)->T_RECNO ))
		RecLock("N8W",.F.)
			N8W->N8W_QTPRVE := (__cTabTmp)->T_QTPRVE
			N8W->N8W_PERVEN := (__cTabTmp)->T_PERVEN
			N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
		N8W->(MsUnlock())
		(__cTabTmp)->(DbSkip())
	EndDo
	
	__lAltItem := .T.

	RestArea(aArea)
Return .T.