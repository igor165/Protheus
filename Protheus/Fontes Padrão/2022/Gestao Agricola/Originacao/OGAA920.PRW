#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGAA920.ch'

Static __cTabTmp := ""
Static __cNamTmp := ""

/*/{Protheus.doc} InsRegDoc()
Função para dar manutenção nos valores previstos de recebimento do DCO.
@type  Static Functions
@author rafael.kleestadt / tamyris.g
@since 27/09/2018
@version 1.0
@param cFilTmp, caractere, código da Filial da previsão de recebimnto posicionada;
@param cNumAvi, caractere, código do Aviso PEPRO;
@param cNumDco, caractere, código do DCO;
@param cVersao, caractere, Sequencial do DCO;
@param nValor, numerico, valor previsto atual.
@return True, Logycal, True or False
@example
(examples)
@see http://tdn.totvs.com/x/EFjAFQ
/*/
Function OGAA920(cFilTmp, cNumAvi, cNumDco, cVersao, dDtPrev)

	Private _cFilTmp := cFilTmp
	Private _cNumAvi := cNumAvi
	Private _cNumDco := cNumDco
	Private _cVersao := cVersao
	Private _cTitle  := ""
	Private _dDtPrev := dDtPrev

	//Proteç?o
	If !TableInDic('N9X')
		Help( , , STR0008, , STR0009, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf 

	_cTitle := AllTrim(RetTitle("N9X_NUMAVI")) + ": " + AllTrim(cNumAvi) + ", " + AllTrim(RetTitle("N9X_NUMDCO")) + ": " + AllTrim(cNumDco) + ", " + AllTrim(RetTitle("N9X_SEQUEN")) + ": " + AllTrim(cVersao)

	 CriaBrowser()

Return _dDtPrev

/*/{Protheus.doc} InsRegDoc()
Função para criar a estrutura da tabela temporária e tela
@type  Static Function
@author rafael.kleestadt
@since 27/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see http://tdn.totvs.com/x/EFjAFQ
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
	Local nOpcX         := 1

	Private _oBrwN9X   := Nil
	Private _oGet1		:= Nil
	Private _oGet2		:= Nil
	Private _oGet3		:= Nil
	Private _nVolDisp	:= 0
	Private _nTotPer	:= 0
	Private _nTotPv   	:= 0

    //-------------------------------Estrutura da Tabela-----------------------------------//
	AAdd(aStrcTmp, {RetTitle("N9X_FILIAL"), "T_FILIAL", TamSX3("N9X_FILIAL")[3], TamSX3("N9X_FILIAL")[1], TamSX3("N9X_FILIAL")[2], PesqPict("N9X","N9X_FILIAL")})
    AAdd(aStrcTmp, {RetTitle("N9X_NUMAVI"), "T_NUMAVI", TamSX3("N9X_NUMAVI")[3], TamSX3("N9X_NUMAVI")[1], TamSX3("N9X_NUMAVI")[2], PesqPict("N9X","N9X_NUMAVI")})
	AAdd(aStrcTmp, {RetTitle("N9X_NUMDCO"), "T_NUMDCO", TamSX3("N9X_NUMDCO")[3], TamSX3("N9X_NUMDCO")[1], TamSX3("N9X_NUMDCO")[2], PesqPict("N9X","N9X_NUMDCO")})
	AAdd(aStrcTmp, {RetTitle("N9X_SEQUEN"), "T_SEQUEN", TamSX3("N9X_SEQUEN")[3], TamSX3("N9X_SEQUEN")[1], TamSX3("N9X_SEQUEN")[2], PesqPict("N9X","N9X_SEQUEN")})
	AAdd(aStrcTmp, {RetTitle("N9X_SEQSE1"), "T_SEQSE1", TamSX3("N9X_SEQSE1")[3], TamSX3("N9X_SEQSE1")[1], TamSX3("N9X_SEQSE1")[2], PesqPict("N9X","N9X_SEQSE1")})
	AAdd(aStrcTmp, {RetTitle("N9X_PARSE1"), "T_PARSE1", TamSX3("N9X_PARSE1")[3], TamSX3("N9X_PARSE1")[1], TamSX3("N9X_PARSE1")[2], PesqPict("N9X","N9X_PARSE1")})
	AAdd(aStrcTmp, {RetTitle("N9X_DTPREV"), "T_DTPREV", TamSX3("N9X_DTPREV")[3], TamSX3("N9X_DTPREV")[1], TamSX3("N9X_DTPREV")[2], PesqPict("N9X","N9X_DTPREV")})
	AAdd(aStrcTmp, {RetTitle("N9X_VALOR"),  "T_VALOR",  TamSX3("N9X_VALOR")[3],  TamSX3("N9X_VALOR")[1],  TamSX3("N9X_VALOR")[2],  PesqPict("N9X","N9X_VALOR")})
	AAdd(aStrcTmp, {"" , "T_RECNO" , "N" , 20 , 0 , "@!"})
	
    // Definição dos índices da tabela
	aIndTmp := {{"", "T_FILIAL, T_NUMAVI, T_NUMDCO, T_SEQUEN"}}

	Processa({|| OG710ACTMP(@__cTabTmp, @__cNamTmp, aStrcTmp, aIndTmp)}, STR0002) //Aguarde. "Criando a Tabela..."

	// Carrega os registros das tabelas temporárias.
	Processa({|| InsRegDoc()}, STR0003) //Aguarde. "Selecionando as Dados Disponíveis..."

    aHeader := {}
	
 	For nCont := 2  to Len(aStrcTmp)
		IF !aStrcTmp[nCont][2] $ "T_FILIAL|T_NUMAVI|T_NUMDCO|T_SEQUEN|T_RECNO"
			Aadd(aHeader, {aStrcTmp[nCont][1], &("{||"+aStrcTmp[nCont][2]+"}"), aStrcTmp[nCont][3], aStrcTmp[nCont][6], IIF(aStrcTmp[nCont][2] == "T_AGRUPA", 1, 2), aStrcTmp[nCont][4], aStrcTmp[nCont][5], .F.})
			Aadd(aFilBrwTmp, {aStrcTmp[nCont][2], aStrcTmp[nCont][1], aStrcTmp[nCont][3], aStrcTmp[nCont][4], aStrcTmp[nCont][5], aStrcTmp[nCont][6]})
		EndIf
	Next nCont

    oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .T.  // Calculo vertical	
	oSize:lProp 	:= .T.
	oSize:aMargins := {3,3,3,3}
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] * 0.65, oSize:aWindSize[4] * 0.65, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Ajuste Previsão de Recebimento DCO"

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )
	oFWLayer:AddLine( 'GRID', 85, .F. )
	oFWLayer:AddCollumn( 'ALL' , 99, .T., 'GRID' )
	oPnl := oFWLayer:GetColPanel( 'ALL', 'GRID' )

	//Criação e instância do browse de fardos de malas
	_oBrwN9X := FWFormBrowse():New()
	_oBrwN9X:SetOwner(oPnl)
	_oBrwN9X:SetDataTable(.T.)
    _oBrwN9X:SetTemporary(.T.)
    _oBrwN9X:SetAlias(__cTabTmp)
    _oBrwN9X:SetProfileID("DOC")    
    _oBrwN9X:Acolumns := {}
    _oBrwN9X:SetColumns(aHeader)                             
    _oBrwN9X:SetFieldFilter(aFilBrwTmp)
	_oBrwN9X:SetDescription(_cTitle)
	_oBrwN9X:DisableDetails()
    
    _oBrwN9X:Activate()
    _oBrwN9X:Enable()
	_oBrwN9X:Refresh(.T.)

    _oBrwN9X:SetFocus()  // Focus no browser de Finalidades - Principal
	_oBrwN9X:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação 

    _oBrwN9X:SetEditCell(.T., {|| .T. })//indica que o grid e editavel
	_oBrwN9X:Acolumns[3]:SetEdit(.T.)
    _oBrwN9X:Acolumns[3]:SetReadVar("T_DTPREV")

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

	If nOpcX == 1
		fGrvDados()
    EndIf

	RestArea(aAreaAtu)

Return .T.

/*/{Protheus.doc} InsRegDoc()
Função de carga inicial nas tabelas temporarias
@type  Static Function
@author rafael.kleesatdt
@since 27/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see http://tdn.totvs.com/x/EFjAFQ
/*/
Static Function InsRegDoc()
Local cFilOrig := ""

// Limpa a tabela temporária
DbSelectArea(__cTabTmp)
(__cTabTmp)->(DbSetorder(1))
ZAP

//------------------Carga Tabela de Carga da Grid------------------//
DbselectArea( "N9X" )
N9X->(DbSetOrder(1)) //N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO+N9X_SEQUEN
N9X->(DbGoTop())
If N9X->(DbSeek(_cFilTmp+_cNumAvi+_cNumDco))
	While N9X->( !Eof() ) .And. N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO) == _cFilTmp+_cNumAvi+_cNumDco

		cFilOrig := Posicione("N9U", 1, N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO), "N9U_FILORI")

		RecLock(__cTabTmp, .T.)
			(__cTabTmp)->T_FILIAL  := N9X->N9X_FILIAL
			(__cTabTmp)->T_NUMAVI  := N9X->N9X_NUMAVI
			(__cTabTmp)->T_NUMDCO  := N9X->N9X_NUMDCO
			(__cTabTmp)->T_SEQUEN  := N9X->N9X_SEQUEN
			(__cTabTmp)->T_DTPREV  := N9X->N9X_DTPREV
			(__cTabTmp)->T_VALOR   := N9X->N9X_VALOR 
			(__cTabTmp)->T_SEQSE1  := Posicione("N8L", 9, cFilOrig+"DCO"+N9X->(N9X_NUMAVI+N9X_NUMDCO+N9X_SEQUEN), "N8L_NUM")
			(__cTabTmp)->T_PARSE1  := Posicione("N8L", 9, cFilOrig+"DCO"+N9X->(N9X_NUMAVI+N9X_NUMDCO+N9X_SEQUEN), "N8L_PARCEL")
			(__cTabTmp)->T_RECNO   := N9X->(RecNo())
		(__cTabTmp)->(MsUnlock())
		
		N9X->(DbSkip())
	EndDo
EndIf
N9X->(DbCloseArea())

Return .T.

/*/{Protheus.doc} fGrvDados()
Grava as informações alteradas na Grid
@type  Static Function
@author rafael.kleesatdt
@since 27/09/2018
@version 1.0
@param param, param_type, param_descr
@return .T., logycal, true or false
@example
(examples)
@see http://tdn.totvs.com/x/EFjAFQ
/*/
Static Function fGrvDados()
Local nCont := 0

BEGIN TRANSACTION
	DbselectArea(__cTabTmp)
	DbGoTop()
	While (__cTabTmp)->(!EOF())

		DbSelectArea("N9X")
		N9X->(dbGoTop())
		N9X->(DbGoTo( (__cTabTmp)->T_RECNO ))
		If RecLock("N9X", .F.)

			N9X->N9X_DTPREV := (__cTabTmp)->T_DTPREV
			
			If nCont == 0
				_dDtPrev := (__cTabTmp)->T_DTPREV
			EndIf

			If _dDtPrev < N9X->N9X_DTPREV
				_dDtPrev := N9X->N9X_DTPREV
			EndIf

			N9X->(MsUnlock())
		EndIf

		nCont ++

		(__cTabTmp)->(DbSkip())
	EndDo

	//Gera/Atualiza os Títulos a Receber previstos para o DCO
	DbselectArea(__cTabTmp)
	DbGoTop()
	If .Not. OGA810PPF((__cTabTmp)->T_FILIAL, (__cTabTmp)->T_NUMAVI, (__cTabTmp)->T_NUMDCO)
		DisarmTransaction()
	EndIf

END TRANSACTION

Return .T.