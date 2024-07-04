#INCLUDE "OGA455A.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static __oArqTemp := Nil
Static __lDataCalc	:= SuperGetMv('MV_AGRO046', , "1") // Parâmetro que indica qual data será utilizada para cálculo do serviço de armz (1 - Documento Fiscal | 2 - Romaneio)

/** {Protheus.doc} OGA455A
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA455A( aCtrSelec ) 
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer 	 := Nil		
	Local oPnCtr	 := Nil	
	Local nX       	 := 0		

	//--- Definição da estrutura da tabela temporária de Contratos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo     
	//[n][06] Picture
	Local aEstruCtr := {{ "OK", "C", 2, 0 , , } , ;
	{ "C_FILIAL"  , "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "C_MODELO"  , "C", TamSX3( "NJR_MODELO" )[ 1 ], 0 , RetTitle( "NJR_MODELO" ), PesqPict("NJR","NJR_MODELO") },;
	{ "C_STATUS"  , "C", TamSX3( "NJR_STATUS" )[ 1 ], 0 , RetTitle( "NJR_STATUS" ), PesqPict("NJR","NJR_STATUS") },;
	{ "C_CODCTR"  , "C", TamSX3( "NJR_CODCTR" )[ 1 ], 0 , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
	{ "C_DESCRI"  , "C", TamSX3( "NJR_DESCRI" )[ 1 ], 0 , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
	{ "C_CODSAF"  , "C", TamSX3( "NJR_CODSAF" )[ 1 ], 0 , RetTitle( "NJR_CODSAF" ), PesqPict("NJR","NJR_CODSAF") },;
	{ "C_NOMENT"  , "C", TamSX3( "NJ0_NOME" )  [ 1 ], 0 , RetTitle( "NJ0_NOME" )  , PesqPict("NJ0","NJ0_NOME") },;
	{ "C_SLDFIS"  , "N", 16,                          2 , RetTitle( "NJR_SLDFIS" ), "@E 999,999,999,999.99" },;	
	{ "C_DESTIP"  , "C", 20 ,                         0 , RetTitle( "NJR_TIPO" )  , "@" },;
	{ "C_CODENT"  , "C", TamSX3( "NJ0_CODENT" )[ 1 ], 0 , RetTitle( "NJ0_CODENT" ), PesqPict("NJ0","NJ0_CODENT") },;
	{ "C_LOJENT"  , "C", TamSX3( "NJ0_LOJENT" )[ 1 ], 0 , RetTitle( "NJ0_LOJENT" ), PesqPict("NJ0","NJ0_LOJENT") },;
	{ "C_CODPRO"  , "C", TamSX3( "NJR_CODPRO" )[ 1 ], 0 , RetTitle( "NJR_CODPRO" ), PesqPict("NJR","NJR_CODPRO") },;
	{ "C_DESPRO"  , "C", TamSX3( "NJR_DESPRO" )[ 1 ], 0 , RetTitle( "NJR_DESPRO" ), PesqPict("NJR","NJR_DESPRO") },;
	{ "C_QTTRANSF", "N", 16,                          2 , "Qtde. Transferir"      , "@E 999,999,999,999.99" },;
	{ "C_QTDTRF"  , "N", 16,                          2 , "Qtd.Disp.Transf"                 ,	"@E 999,999,999,999.99" },; //"Qtd.Disp.Transf"
	{ "C_TESEST"  , "C", TamSX3( "NJR_TESEST" )[ 1 ], 0 , RetTitle( "NJR_TESEST" ), "@" },;
	{ "C_TESRSI"  , "C", TamSX3( "NJR_TESRSI" )[ 1 ], 0 , RetTitle( "NJR_TESRSI" ), "@" },;
	{ "C_DATA"    , "D", 8 ,                          0 , RetTitle( "NJR_DATA" )  , "@D" },;
	{ "C_DATINI"  , "D", 8 ,                          0 , RetTitle( "NNY_DATINI" ), "@D" },;
	{ "C_DATFIM"  , "D", 8 ,                          0 , RetTitle( "NNY_DATFIM" ), "@D" },;
	{ "C_QTDCTR"  , "N", 16,                          2 , RetTitle( "NJR_QTDCTR" ), "@E 999,999,999,999.99" },;
	{ "C_QTDFIX"  , "N", 16,                          2 , RetTitle( "NN8_QTDFIX" ), "@E 999,999,999,999.99" },;
	{ "C_QTENFX"  , "N", 16,                          2 , "Qtd. Ent. Fix.", "@E 999,999,999,999.99" },; //"Qtd. Ent. Fix."						
	{ "C_QTDAFX"  , "N", 16,                          2 ,  "Qtd. a Fixar", "@E 999,999,999,999.99" },; //"Qtd. a Fixar"
	{ "C_QSLFCO"  , "N", 16,                          2 , RetTitle( "NJR_QSLFCO" ), "@E 999,999,999,999.99" },;
    { "C_QTEFCO"  , "N", 16,                          2 , RetTitle( "NJR_QTEFCO" ), "@E 999,999,999,999.99" },;
	{ "C_QTEFIS"  , "N", 16,                          2 , RetTitle( "NJR_QTEFIS" ), "@E 999,999,999,999.99" },;
	{ "C_QTSFCO"  , "N", 16,                          2 , RetTitle( "NJR_QTSFCO" ), "@E 999,999,999,999.99" },;
	{ "C_QTSFIS"  , "N", 16,                          2 , RetTitle( "NJR_QTSFIS" ), "@E 999,999,999,999.99" },;
	{ "C_DIFFIS"  , "N", 16,                          2 , "Dif. Fiscal"                 , "@E 999,999,999,999.99" },; //"Dif. Fiscal"
	{ "C_QTDRES"  , "N", 16,                          2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999.99" },;
	{ "C_RECNO"   , "N", 10,                          0 , "RECNO"                 , "@ 9999999999"},;
	{ "C_TIPO"    , "C", TamSX3( "NJR_TIPO" )  [ 1 ], 0 , RetTitle( "NJR_TIPO" )  , "@" }} 

	Local _aCpBrwCtr 	:= {}
	Local aIndCtr 	    := { "" , "C_FILIAL+C_CODPRO"} // Definição dos índices
	Local aSeek		    := {}

	Private _aCtrRet    := {}   //Variável para retornar a lista de contratos selecionados
	Private _aCtrSelec  := aCtrSelec //{{'000005', 500}, {'000006', 600}, {'000007', 700}}

	Private _cAliasCtr 
	Private _cTrabCtr
	Private _oBrwCtr
	Private _cTblName

	Private _cMarca   	:= GetMark()
	Private _lSelAll  	:= .f.
	Private _c1Perg   	:= "OGA455001"

	Private _cNoFldCTR	:= "OK,C_FILIAL,C_MODELO,C_STATUS,C_TIPO,C_TESEST,C_TESRSI,C_RECNO"
	Private _aCpBrwTrf  := {}
	Private _aContrato  := {}

	Private _cCodEntD  	:= ""
	Private _cLojEntD  	:= ""
	Private _cCodEntA  	:= ""
	Private _cLojEntA  	:= ""
	Private _cNomEnt   	:= ""
	Private _cContrD   	:= ""
	Private _cContrA   	:= ""
	Private _cPSafraD  	:= ""
	Private _cPSafraA  	:= ""
	Private _cPCodPro  	:= ""
	Private _cCultra   	:= ""
	Private aMovServR 	:= {}

	// Tabela temporária de Contratos
	_cAliasCtr := GetNextAlias()
	__oArqTemp := AGRCRTPTB(_cAliasCtr, {aEstruCtr, {aIndCtr} })  

	_aCpBrwCtr	:= aEstruCtr //Matriz com a estrutura do arquivo temporario + label e picutre
	_cTblName   :=  __oArqTemp:GetRealName()

	A455A1FIL( )

	//--- Montagem da tela ---//
	oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], "Transferência", , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Transferência

	//--- Layers ---//
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	// Contratos
	oFWLayer:AddLine( 'LinContrato', 100, .F. )
	oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinContrato' )
	oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinContrato' )

	DEFINE FWFORMBROWSE _oBrwCtr DATA TABLE ALIAS _cAliasCtr DESCRIPTION "Contratos" OF oPnCtr //"Contratos"
	_oBrwCtr:SetTemporary(.T.)
	_oBrwCtr:SetdbFFilter(.T.)
	_oBrwCtr:SetUseFilter(.T.)	
	//_oBrwCtr:SetQueryIndex(aIndCtr)

	aseek := {}
	//Para melhor entendimento aAdd( aSeek, { 'FILIAL+Contrato' , { {"AquiConsultaF3Setitver","C",'2',0,'filial',"@!"} ,{"","C",6,0,'codctr','@!'}  ,1  } )
	aAdd( aSeek, { Alltrim( RetTitle( "NJR_FILIAL" )) + '+' + Alltrim( RetTitle( "NJR_CODCTR" )),{{"",TAMSX3('NJR_FILIAL')[3],TAMSX3('NJR_FILIAL')[1],TAMSX3('NJR_FILIAL')[2],RetTitle( "NJR_FILIAL" ),PesqPict("NJR","NJR_FILIAL")},{""	,TAMSX3('NJR_CODCTR')[3],TAMSX3('NJR_CODCTR')[1],TAMSX3('NJR_CODCTR')[2],RetTitle( "NJR_CODCTR" ),PesqPict("NJR","NJR_CODCTR")}} ,1  } )
	aAdd( aSeek, { Alltrim( RetTitle( "NJR_FILIAL" )) + '+' + Alltrim( RetTitle( "NJR_CODPRO" )),{{"",TAMSX3('NJR_FILIAL')[3],TAMSX3('NJR_FILIAL')[1],TAMSX3('NJR_FILIAL')[2],RetTitle( "NJR_FILIAL" ),PesqPict("NJR","NJR_FILIAL")},{""	,TAMSX3('NJR_CODPRO')[3],TAMSX3('NJR_CODPRO')[1],TAMSX3('NJR_CODPRO')[2],RetTitle( "NJR_CODPRO" ),PesqPict("NJR","NJR_CODPRO")}} ,1  } )		

	//_oBrwCtr:SetSeek(,aDesIndice)
	_oBrwCtr:SetSeek(,aSeek)
	_oBrwCtr:SetFieldFilter(AGRITEMCBRW(_aCpBrwCtr))
	ADD MARKCOLUMN oColumn DATA { || If(( _cAliasCtr )->OK == _cMarca,'LBOK','LBNO') } ;
	DOUBLECLICK { |_oBrwCtr| A455ACLK( _cAliasCtr , _oBrwCtr) } OF _oBrwCtr 

	_oBrwCtr:AddLegend( "C_MODELO=='1'"						, "WHITE"	, X3CboxDesc( "NJR_MODELO", "1" ) ) //Pré-Contrato
	_oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='P'"	, "BLUE"	, X3CboxDesc( "NJR_STATUS", "P" ) ) //Previsto
	_oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='A'"	, "GREEN"	, X3CboxDesc( "NJR_STATUS", "A" ) ) //Aberto
	_oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='I'"	, "YELLOW"	, X3CboxDesc( "NJR_STATUS", "I" ) ) //Iniciado
	_oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='E'"	, "BLACK"	, X3CboxDesc( "NJR_STATUS", "E" ) ) //Cancelado
	_oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='F'"	, "RED"	    , X3CboxDesc( "NJR_STATUS", "F" ) ) //Finalizado

	For nX := 1 To Len(_aCpBrwCtr)
		If !( _aCpBrwCtr[nX,1] $ _cNoFldCTR )
			ADD COLUMN oColumn DATA &('{||'+_aCpBrwCtr[nX,1]+'}') Title _aCpBrwCtr[nX,5] SIZE _aCpBrwCtr[nX,3] PICTURE _aCpBrwCtr[nX,6] ;
			DOUBLECLICK { |_oBrwCtr| A455ACLK( _cAliasCtr , _oBrwCtr) } OF _oBrwCtr
		EndIf
	Next nX
	_oBrwCtr:DisableDetails()		
	_oBrwCtr:AddButton("Confirmar",	{|| A455ACONF(), oDlg:End() },,,,,,'30') //"Confirmar"
	_oBrwCtr:AddButton("Detalhes",	{|| A455ADET( (_cAliasCtr)->C_CODCTR ) },,,,,,'30')	//"Detalhes"
	_oBrwCtr:AddButton("Filtro",	{|| A455A1FIL( (_cAliasCtr)->C_CODCTR ) },,,,,,'30')//"Filtro"
	_oBrwCtr:AddButton("Sair", {|| oDlg:End() },,,,,,'10') //"Sair"
	ACTIVATE FWFORMBROWSE _oBrwCtr

	oDlg:Activate( , , , .t., { || .t. }, , { || } )

	//--- Apaga as tabelas temporárias ---//
	AGRDLTPTB(__oArqTemp)

Return( _aCtrRet )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/
Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } ) 
Return( aRotina )

/** {Protheus.doc} A455ADET
Função que detalha o contrato

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/
Function A455ADET( pcContrato )
	Local lRetorno := .t.

	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek( xFilial('NJR') + pcContrato )

		If NJR->NJR_TIPO = '1'
			A455A1View()
		ElseIf NJR->NJR_TIPO = '3'
			A455A3View()
		End				
	Endif

Return ( lRetorno )

/** {Protheus.doc} A455A1FIL
Função que filtra os contratos
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/
Function A455A1FIL( )
	Local lRetorno := .t.

	Pergunte("OGA455001",.t.)

	A455LoadCtr()

Return ( lRetorno )


/** {Protheus.doc} A455AUNSEL
Função chamada para verificar a existência de registro selecionado 
@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A455AUNSEL( pcAliasTRB )

	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := ' '
		msUnLock(pcAliasTRB)		
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 

/** {Protheus.doc} A455ATSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A455ATSEL( pcAliasTRB )
	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := _cMarca
		msUnLock(pcAliasTRB)

		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 


/** {Protheus.doc} A455ACLK()
Marca/Desmarca registro

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	01/12/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A455ACLK( pcAliasTRB, pOBrw )
	Local nPosCtr := 0

	If !(pcAliasTRB)->( Eof() )	
		nPosCtr := ASCAN(_aCtrSelec,{|x| x[1] == (_cAliasCtr)->C_CODCTR })
		if nPosCtr = 0 .OR. (nPosCtr > 0 .AND. _aCtrSelec[nPosCtr][3] = .T.)
			if (pcAliasTRB)->C_QTDTRF != 0
				RecLock(pcAliasTRB, .F.)
				(pcAliasTRB)->OK := IIf((pcAliasTRB)->OK =_cMarca,' ',_cMarca)
				If ((pcAliasTRB)->OK == _cMarca )
					(pcAliasTRB)->C_QTTRANSF := EditQtd((pcAliasTRB)->C_QTTRANSF, (pcAliasTRB)->C_QTDTRF )
					IF (pcAliasTRB)->C_QTTRANSF == 0
						(pcAliasTRB)->OK := " "
					EndIf
				Else
					(pcAliasTRB)->C_QTTRANSF = 0
				EndIf
				MsUnlock(pcAliasTRB)
			else
				Help( ,,"Ajuda",,"Contrato não possui saldo.", 1, 0 ) //"Ajuda" //"Contrato não possui saldo."
			endIF
		else
			Help( ,,"Ajuda",,"Contrato já tem Romaneio de devolução gerado, portanto, não pode ser desmarcado.", 1, 0 ) //"Ajuda" //"Contrato já tem Romaneio de devolução gerado, portanto, não pode ser desmarcado."
		endIf
	EndIf
	pOBrw:Refresh()
Return


/** {Protheus.doc} A455LoadCtr
Carrega dados da tabela temporária de Contratos.

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A455LoadCtr()

	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cFiltro    	:= ""
	
	Local cSql          := ""	

	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	A455AclTRB( _cAliasCtr )

	Pergunte("OGA455001",.f.)

	if !EMPTY(MV_PAR01)
		cFiltro += " AND NJR_CODENT >= '" + MV_PAR01 + "'"
	endIf

	if !EMPTY(MV_PAR03)
		cFiltro += " AND NJR_CODENT <= '" + MV_PAR03 + "'" 
	endIf

	if !EMPTY(MV_PAR02) 
		cFiltro += " AND NJR_LOJENT >= '" + MV_PAR02 + "'"
	endIf

	if !EMPTY(MV_PAR04)
		cFiltro += " AND NJR_LOJENT <= '" + MV_PAR04 + "'"
	endIf

	if !EMPTY(MV_PAR05)
		cFiltro += " AND NJR_CODCTR >= '" + MV_PAR05 + "'"
	endIf

	if !EMPTY(MV_PAR06)
		cFiltro += " AND NJR_CODCTR <= '" + MV_PAR06 + "'"
	endIF

	if !EMPTY(MV_PAR07)
		cFiltro += " AND NJR_CODSAF >= '" + MV_PAR07 + "'"
	endIf

	if !EMPTY(MV_PAR08)
		cFiltro += " AND NJR_CODSAF <= '" + MV_PAR08 + "'"
	endIF

	If !Empty(MV_PAR09)   
		cFiltro += " AND NJR_CODPRO  = '" + MV_PAR09 + "'"
	Endif   

	cFiltro += " AND NJR_TIPO   = '3' "
	cFiltro += " AND (NJR_STATUS = 'I' OR NJR_STATUS = 'A') "
	cFiltro 	:= "%" + cFiltro + "%"

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry

		SELECT ' ' AS OK
		,NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODENT
		,NJR_LOJENT	      
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_DATA
		,NJR_TESRSI
		,NJR_TESEST
		,NJR.R_E_C_N_O_ AS NJR_RECNO
		,(SELECT MIN(NNY_DATINI) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATINI
		,(SELECT MAX(NNY_DATFIM) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATFIM    
		,SUM(NJR_QTDCTR) as NJR_QTDCTR
		,SUM(NJR_QTEFCO) as NJR_QTEFCO
		,SUM(NJR_QTEFIS) as NJR_QTEFIS
		,SUM(NJR_QTSFCO) as NJR_QTSFCO
		,SUM(NJR_QTSFIS) as NJR_QTSFIS
		,SUM(NJR_QTDRES) as NJR_QTDRES
		,SUM(NJR_QSLFCO) as NJR_QSLFCO
		,SUM(NJR_SLDFIS) as NJR_SLDFIS
		,SUM(NN8_QTDFIX) as NN8_QTDFIX
		,SUM(NN8_QTDENT) as NN8_QTDENT
		,0 as QTD_TRANSF
		FROM %Table:NJR% NJR
		LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1'
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR% 
		%exp:cFiltro%
		GROUP BY  NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODENT
		,NJR_LOJENT	      
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_DATA
		,NJR_TESRSI
		,NJR_TESEST
		,NJR.R_E_C_N_O_
	EndSQL

	cSql := GetLastQuery()[2]

	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )
		nPosCtr := 0
		RecLock( _cAliasCtr, .T. )
		//Marca os registros anteriormente selecionados
		nPosCtr	:=	ASCAN(_aCtrSelec,{|x| x[1] == ( cAliasQry )->NJR_CODCTR })
		If nPosCtr > 0
			(_cAliasCtr)->OK := _cMarca
			( _cAliasCtr )->C_QTTRANSF := _aCtrSelec[nPosCtr][2]
		Else
			( _cAliasCtr )->C_QTTRANSF := 0
		EndIf
		( _cAliasCtr )->C_FILIAL 	:= ( cAliasQry )->NJR_FILIAL
		( _cAliasCtr )->C_MODELO 	:= ( cAliasQry )->NJR_MODELO
		( _cAliasCtr )->C_STATUS 	:= ( cAliasQry )->NJR_STATUS
		( _cAliasCtr )->C_CODCTR 	:= ( cAliasQry )->NJR_CODCTR
		( _cAliasCtr )->C_DESCRI 	:= ( cAliasQry )->NJR_DESCRI
		( _cAliasCtr )->C_CODSAF	:= ( cAliasQry )->NJR_CODSAF
		( _cAliasCtr )->C_CODPRO	:= ( cAliasQry )->NJR_CODPRO
		( _cAliasCtr )->C_DESPRO	:= Posicione("SB1",1,xFilial("SB1")+( cAliasQry )->NJR_CODPRO,"B1_DESC")
		( _cAliasCtr )->C_CODENT 	:= ( cAliasQry )->NJR_CODENT
		( _cAliasCtr )->C_LOJENT 	:= ( cAliasQry )->NJR_LOJENT
		( _cAliasCtr )->C_NOMENT 	:= Posicione("NJ0",1,xFilial("NJ0")+( cAliasQry )->NJR_CODENT+( cAliasQry )->NJR_LOJENT,"NJ0_NOME")
		( _cAliasCtr )->C_TIPO 		:= ( cAliasQry )->NJR_TIPO
		( _cAliasCtr )->C_DESTIP 	:= X3CboxDesc( "NJR_TIPO", ( cAliasQry )->NJR_TIPO )
		( _cAliasCtr )->C_DATA		:= StoD( ( cAliasQry )->NJR_DATA )
		( _cAliasCtr )->C_DATINI 	:= StoD( ( cAliasQry )->NNY_DATINI )
		( _cAliasCtr )->C_DATFIM 	:= StoD( ( cAliasQry )->NNY_DATFIM )
		( _cAliasCtr )->C_QTDCTR 	:= ( cAliasQry )->NJR_QTDCTR
		( _cAliasCtr )->C_QTDFIX 	:= ( cAliasQry )->NN8_QTDFIX
		( _cAliasCtr )->C_QTENFX 	:= ( cAliasQry )->NN8_QTDENT
		( _cAliasCtr )->C_QTDAFX 	:= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
		( _cAliasCtr )->C_QSLFCO 	:= ( cAliasQry )->NJR_QSLFCO
		( _cAliasCtr )->C_SLDFIS 	:= ( cAliasQry )->NJR_SLDFIS
		( _cAliasCtr )->C_QTEFCO 	:= ( cAliasQry )->NJR_QTEFCO
		( _cAliasCtr )->C_QTEFIS 	:= ( cAliasQry )->NJR_QTEFIS
		( _cAliasCtr )->C_QTSFCO 	:= ( cAliasQry )->NJR_QTSFCO
		( _cAliasCtr )->C_QTSFIS 	:= ( cAliasQry )->NJR_QTSFIS
		( _cAliasCtr )->C_QTDRES 	:= ( cAliasQry )->NJR_QTDRES
		( _cAliasCtr )->C_DIFFIS 	:= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS
		( _cAliasCtr )->C_TESEST 	:= ( cAliasQry )->NJR_TESEST		
		( _cAliasCtr )->C_TESRSI 	:= ( cAliasQry )->NJR_TESRSI
		( _cAliasCtr )->C_RECNO 	:= ( cAliasQry )->NJR_RECNO

		If ( cAliasQry )->NJR_TIPO $ "1|3"
			If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( _cAliasCtr )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES
			Else
				( _cAliasCtr )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif	
		Else
			If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( _cAliasCtr )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES
			Else
				( _cAliasCtr )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif	
		Endif

		( _cAliasCtr )->( MsUnLock() )

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
	If Type("_oBrwCtr") <> "U"
		_oBrwCtr:Refresh(.T.)
	EndIf

	RestArea( aAreaAtu )
Return 

/** {Protheus.doc} A455A3View

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		OGA455A 
*/
Function A455A3View( )

	Local xRet 

	xRet := FWExecView( '','OGA260', MODEL_OPERATION_VIEW )

Return xRet


/** {Protheus.doc} A455A1View
@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		OGA455A 
*/
Function A455A1View( )

	Local xRet 

	xRet := FWExecView( '','OGA280', MODEL_OPERATION_VIEW )

Return xRet


/** {Protheus.doc} A455AclTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A455AclTRB( pTableName )
	Local aAreaAtu	 	:= GetArea()

	If Select( _cAliasCtr ) > 0 // Verifica se o Arquivo Existe
		cDel := "DELETE "+ pTableName
		TCSQLExec(cDel)
	EndIf

	RestArea( aAreaAtu )
Return	


Static Function A455ACONF()
	_aCtrRet := {}
	(_cAliasCtr)->(dbGoTop())
	While !(_cAliasCtr)->(Eof())
		If (_cAliasCtr)->OK == _cMarca
			aAdd(_aCtrRet, {(_cAliasCtr)->C_CODCTR, (_cAliasCtr)->C_QTTRANSF, "|" } )
		EndIf
		(_cAliasCtr)->(DbSkip())
	EndDo
Return 


/*/{Protheus.doc} EditQtd
@author joaquim.burjack
@since 14/12/2018
@version 1.0
@type function
/*/
Static Function EditQtd(nValor, nValorMax)
	Local   nOpcao      := 0
	Local   oDlg        := Nil
	Local   nRet        := nValor
	Private nQtdNew 	:= nValor

	Define MsDialog oDlg Title "Alterar - Quantidade" From 9,0 to 20,50 Of oMainWnd
	@ 060,015 Say OemToAnsi("Quantidade: ") Of oDlg Pixel
	@ 060,070 MsGet nQtdNew  Valid nQtdNew >= 0 .And. nQtdNew <= nValorMax Picture("@E 999,999,999,999.99") Size 070, 010  Of oDlg Pixel
	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() })
	If nOpcao == 1
		nRet := nQtdNew
	EndIf
Return( nRet )


/*/{Protheus.doc} OGA455AGTN
//Responsável por gatilhar o nome da entidade quando não for inclusão.
@author brunosilva
@since 26/12/2018
@version 1.0
@return NJ0_NOME, Campo nome da entidade.

@type function
/*/
Function OGA455AGTN()	
Return Posicione("NJ0",1,FWxFilial("NJ0")+POSICIONE('NJR',1,FWXFILIAL('NJR')+NBU->NBU_CTRORI,'NJR_CODENT') +POSICIONE('NJR',1,FWXFILIAL('NJR')+NBU->NBU_CTRORI,'NJR_LOJENT') ,"NJ0_NOME")


/*/{Protheus.doc} OGA455AGTL
//Responsável por gatilhar o nome da loja da entidade quando não for inclusão.
@author brunosilva
@since 26/12/2018
@version 1.0
@return NJ0_NOMLOJ, Campo nome da loja da entidade.

@type function
/*/
Function OGA455AGTL()	
Return Posicione("NJ0",1,FWxFilial("NJ0")+POSICIONE('NJR',1,FWXFILIAL('NJR')+NBU->NBU_CTRORI,'NJR_CODENT') +POSICIONE('NJR',1,FWXFILIAL('NJR')+NBU->NBU_CTRORI,'NJR_LOJENT') ,"NJ0_NOMLOJ")


/*/{Protheus.doc} OGA455ACLC
//Função baseada no OGA262
@author brunosilva
@since 16/01/2019
@version 1.0
@param oModel, object, descricao
@type function
/*/
Function OGA455ACLC(cFilTfr, cCodTrf)
	Local lRet 			:= .T.	
	Local bRotina  		:= Nil
	Local oProcess
	Local oProcess2		
	Local nX			:= 1
	Local aCtrs			:= {}
	Local aRoms			:= {}	
	Local cCtrLine		:= ""
	Local cRomLine		:= ""
	Local nPosCtr		:= 0
	Local cTabela		:= ""
	Local lExecuta 		:= .T.
	
	Private _lDestino := .F.

	If NBT->NBT_STATUS == "4"
		Help( ,,STR0023,,STR0021, 1, 0 ) //"Atencao" //"Transferência já efetuada."	
		Return
	ElseIf !(NBT->NBT_STATUS $ '3')
		Help( ,,STR0023,,STR0022, 1, 0 ) //"Atencao" //"Transferência de Serviço não pode ser efetuada. Necessário transferir propriedades."
		Return
	EndIf

	dbSelectArea("NBU")
	NBU->(DbSetOrder(1))
	If NBU->(DbSeek(xFilial("NBU")+cCodTrf))
	//Calcula da(s) origem(ns)
		While NBU->(!Eof()) ;
			.AND.  NBU->NBU_FILIAL == cFilTfr;
			.AND.  NBU->NBU_CODTRF == cCodTrf

			If !Empty(NBU->NBU_CTRORI)		
				cCtrLine := NBU->NBU_CTRORI
				cRomLine := NBU->NBU_ROMORI
				nPosCtr  := ASCAN(aCtrs,{|x| x[1] == cCtrLine})
				if nPosCtr = 0
					aAdd(aCtrs,{})
					aAdd(aCtrs[LEN(aCtrs)],cCtrLine)
					aAdd(aCtrs[LEN(aCtrs)],cRomLine)
					
					//Para ser usado também no destino.
					aAdd(aRoms,cRomLine)
				else
					if nPosCtr > 0 .AND. !EMPTY(cRomLine)
						aAdd(aCtrs[LEN(aCtrs)],cRomLine)
						
						//Para ser usado também no destino.
						aAdd(aRoms,cRomLine)
					endIf
				endIf
			EndIf

			NBU->(Dbskip())
		Enddo
	EndIf
	BEGIN TRANSACTION
		if !EMPTY(aCtrs)
			
			fDeletNKG(cCodTrf)	

			IF 	NBT->(FieldPos("NBT_USOTAB")) > 0
				If NBT->NBT_USOTAB  == '2' //destino
					cTabela := NBT->NBT_TABDES
				EndIf	
			Endif
		
			bRotina := {|x| fProcCalc( cCodTrf, @oProcess, aCtrs, .F.,cTabela ,NBT->NBT_DTCALC)}
			
			oProcess := MsNewProcess():New( bRotina, "Cálculo de Serviços", "Calculando Tarifa...", .F. )  //"Cálculo de Serviços"###"Calculando Tarifa..."
			oProcess:Activate()
			
			//fInsGrdNBV("ORIGEM",aCtrs)
		else
			lExecuta := .F.
		endIf
		
		if lExecuta .AND. !EMPTY(NBT->NBT_CTRDES) 
			//Cálculo de Serviços Destino
			aCtrs := {}
			aAdd(aCtrs,{})
			aAdd( aCtrs[1], NBT->NBT_CTRDES)
			
			for nX := 1 to Len(aRoms)
				aAdd(aCtrs[1],aRoms[nX])
			next nX

			_lDestino := .T.
			bRotina := {|x| fProcCalc( cCodTrf, @oProcess2, aCtrs, /*simulacao*/ .T., NBT->NBT_TABDES,NBT->NBT_DTCALC)}
			
			oProcess2 := MsNewProcess():New( bRotina, "Cálculo de Serviços", "Calculando Tarifa...", .F. )  //"Cálculo de Serviços"###"Calculando Tarifa..."
			oProcess2:Activate()
			
			//fInsGrdNBV("DESTINO",aCtrs)
		else
			DisarmTransaction()
			Help(,,"Ajuda",,"Verifique se o campo de contrato destino está preenchido e as notas de origem foram selcionadas.", 1, 0 ) //"Ajuda" 
		endIf
	END TRANSACTION
		
Return lRet

/*/{Protheus.doc} fProcCalc
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Function fProcCalc(cCodTrf, oProcess, aCtrs, lSimula, cTabela, dFinalMov)
	Local lRet 			:= .T.
	Local cAliasNJR    	:= GetNextAlias()
	Local cAliasNJM    	:= GetNextAlias()
	Local cAliasSD2		
	Local dInicioMov   	:= STOD("")
	Local cDocOri      	:= "" 
	Local cSerOri      	:= ""
	Local lGeraArr		:= .T.
	Local dFirstEntC   	:= ""
	Local cFiltroNJR   	:= " AND ("
	Local cFiltroNKQ   	:= ""
	Local cFiltroNJJ	:= ""
	Local lGeraNKG     	:= .F.	
	Local nRecCount    	:= 0	
	Local nX			:= 1
	Local nY			:= 1
	Local nPosCtr		:= 0

	
	if !lSimula
		for nX := 1 to LEN(aCtrs)
			cFiltroNJR += "NJR.NJR_CODCTR = '" + aCtrs[nX][1] + "' "
			if nX < LEN(aCtrs)
				cFiltroNJR += " OR "
			endIf
		next nX
	else
		cFiltroNJR += " NJR_CODCTR = '" + aCtrs[1][1] + "'"
	endIf
	
	cFiltroNJR += " ) "
	cFiltroNJR := "%" + cFiltroNJR + "%"
	
	//Query Contratos
	BeginSql Alias cAliasNJR
		SELECT *
		  FROM %Table:NJR% NJR
		 WHERE NJR.%notDel%
		   AND NJR_FILIAL  = %xFilial:NJR%
		   %exp:cFiltroNJR%
	EndSQL
	
	DbSelectArea( cAliasNJR )
	Count to nRecCount
	oProcess:SetRegua1( nRecCount )

	(cAliasNJR)->( DbGoTop() )
	While  ! (cAliasNJR)->( Eof() )  
		
		oProcess:IncRegua1( OemToAnsi( "Calculando Tarifa..." + " " + " Contrato" ) +" ["+ (cAliasNJR)->NJR_CODCTR +"]" ) //"Calculando Tarifa..."##" Contrato"##" [999999]" 

		cFiltroNJJ := ""
		nPosCtr  := ASCAN(aCtrs,{|x| x[1] == (cAliasNJR)->NJR_CODCTR})
		for nY := 1 to LEN(aCtrs[nPosCtr])
			if nY = 1
				cFiltroNJJ += " AND ("
			else
				if nY < LEN(aCtrs[nPosCtr])
					cFiltroNJJ += " NJJ.NJJ_CODROM = '" + aCtrs[nPosCtr][nY] + "' OR "
				else
					cFiltroNJJ += " NJJ.NJJ_CODROM = '" + aCtrs[nPosCtr][nY] + "') "
				endIf
			endIf
		next nY
		cFiltroNJJ := "%" + cFiltroNJJ + "%"
		
		BeginSql Alias cAliasNJM
			SELECT NJM.*, NJJ.*
			  FROM %Table:NJM% NJM
			 INNER JOIN %Table:NJJ% NJJ
			    ON NJJ.%notDel%
			   AND NJJ.NJJ_FILIAL = %xFilial:NJJ%
			   %exp: cFiltroNJJ%
			 WHERE NJM.%notDel%
			   AND NJM.NJM_FILIAL  = %XFilial:NJM%
			   AND NJM.NJM_CODROM = NJJ.NJJ_CODROM
			 ORDER BY NJM.NJM_CODROM
		EndSQL
		
		dbSelectArea( cAliasNJM )
		Count to nRecCount
		oProcess:SetRegua2( nRecCount )
		
		(cAliasNJM)->( DbGoTop() )
		If ! (cAliasNJM)->( Eof() ) 
			If __lDataCalc == "1"
                dFirstEntC := (cAliasNJM)->NJM_DTRANS
            else
                dFirstEntC := (cAliasNJM)->NJJ_DATA
            EndIf            
		Endif		   
		
		lGeraNKG := .T.
		
		// percorrer os registros de comercialização para o contrato; deve ignorar os que sejam do tipo 3 = Retenção 				
		While ! (cAliasNJM)->( Eof() )   
			cAliasSD2 := GetNextAlias()
			
//			SELECT SUM(D2_QUANT) AS QUANT
//			FROM SD2010 SD2
//			WHERE SD2.D_E_L_E_T_= ' '
//			  AND D2_FILIAL = '0302'
//			  AND D2_NFORI = '000037'
//			  AND D2_SERIORI = '1'
					
			BeginSql Alias cAliasSD2
				SELECT *
				  FROM %Table:SD2% SD2
				 WHERE SD2.%notDel%
				   AND D2_FILIAL  = %xFilial:SD2%
				   AND D2_NFORI  = %exp:(cAliasNJM)->NJM_CODCTR%
			EndSQL
			
			oProcess:IncRegua2( OemToAnsi( "Processando" + "... " + "Romaneio" ) +" ["+ (cAliasNJM)->NJM_CODROM +"]" ) //"Processando"##"... "##"Romaneio"##" [999999]" 
			OGA455TARIF( cAliasNJR, cAliasNJM, dFirstEntC, dInicioMov, dFinalMov, cFiltroNKQ, lGeraArr, lSimula, cDocOri, cSerOri, cTabela, cCodTrf )
			
			(cAliasNJM)->( dbSkip() )
		EndDo //Fim laço NJM	
		(cAliasNJM)->( DbCloseArea() )
				
		(cAliasNJR)->( dbSkip() )		
	EndDo //Fim laço NJR
	(cAliasNJR)->( dbCloseArea() )

	//atualiza o status
	If lRet
		If RecLock( "NBT", .f. )			
			NBT->( NBT_STATUS) := "4"	
			msUnLock()
		EndIf
	EndIf
	

Return lRet

/*/{Protheus.doc} OGA455TARIF
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function OGA455TARIF( pcAliasNJR, pcAliasNJM, dFirstEnt,dInicioMov, dFinalMov, cFiltroSer, lGeraArr, plSimula, cDocOri, cSerOri, cTabela, cCodTrf )
	Local cAliasNKQ    := GetNextAlias()
	Local cAliasSD2    := GetNextAlias()
	//Local oGridNBU     := oModel:GetModel("OGA455_NBU") 
	Local dNextCal
	local dDTrans
	Local dIniPerCalc
	Local dFimCaren
	Local dIni1aEntr
	Local nTarifa      := 0.00
	Local nTotRom      := 0.00
	Local nPer         := 0
	Local nValTar      := 0
	Local aCalcPer     := {}
	Local nQuant       := 0.00
	Local nX           := 0
	Local nS           := 0
	Local lPerVal      := .T.
	Local lCalcula	   := .F.
	Local qtPerAnt     := 0.00
	Local aNotasRet    := {}
	Local nVezes       := 0
	Local nPesoDesc	   := 0
	Local nPesoRom     := 0
	Local nPesoLiq 	   := 0 
	Local nDescProp	   := 0
	Local nPesoTrf	   := 0
	Local nPesoFinal   := 0
	Local nPesoFis	   := 0
    Local dBaseCalcOrig := nil
    Local dBaseCalc     := nil
	
	Private aPeriodos  := {}
	Private cEntDev    := ""
	Private cLojDev    := ""
	
	Default cDocOri	:= Space( TamSX3("NJM_DOCNUM")[1] )
	Default cSerOri	:= Space( TamSX3("NJM_DOCSER")[1] )
	
	If Empty(cTabela) 
		cTabela := (pcAliasNJR)->NJR_CODTSE
	EndIf

    If __lDataCalc == "1" //documento fiscal
        dBaseCalc := (pcAliasNJM)->NJM_DTRANS
    else    
        dBaseCalc := (pcAliasNJM)->NJJ_DATA
    EndIf

	dbSelectArea("NBU")
	NBU->(DbSetOrder(1))
	If NBU->(DbSeek(xFilial("NBU")+cCodTrf))
		While NBU->(!Eof());
			.AND. NBU->NBU_FILIAL == xFilial("NBU");
			.AND. NBU->NBU_CODTRF == cCodTrf

			If !EMPTY(NBU->NBU_CTRORI) .AND. ((pcAliasNJM)->NJJ_CODROM = NBU->NBU_ROMORI)
				nPesoLiq += NBU->NBU_QTDSEL
			EndIf	
			NBU->(Dbskip())
		EndDo
	EndIf

	if !EMPTY(cTabela)
		BeginSql Alias cAliasNKQ
			SELECT *
			  FROM %Table:NKQ% NKQ
			 WHERE NKQ.%notDel%
			   AND NKQ_FILIAL  = %xFilial:NKQ%
			   AND NKQ_CODTSE  = %exp:cTabela%
			   AND NKQ_ATIVO   = '1'
			 ORDER BY NKQ_ORDEM		   
		EndSQL	
		
		DbSelectArea( cAliasNKQ )
		(cAliasNKQ)->( DbGoTop() )	
		While ! (cAliasNKQ)->( Eof() ) 
			
			/* NKQ_FATGER			   0= Entrada				1= Saída		      2= Saldo  */
			
			If   ( ( (cAliasNKQ)->NKQ_CONFIS = '1' .And. (pcAliasNJM)->NJJ_TIPENT = '0' ); 		//NJJ_TIPENT 0=Fisico
			  .Or. ( (cAliasNKQ)->NKQ_CONSIM = '1' .And. (pcAliasNJM)->NJJ_TIPENT = '2' ) ); 	//NJJ_TIPENT 2=Simbolico
			.And.( ( (cAliasNKQ)->NKQ_FATGER = '0' .And. (pcAliasNJM)->NJJ_TIPO   = '3' );		//NJJ_TIPO 3= (E) Entrada para Deposito
			  .Or. ( (cAliasNKQ)->NKQ_FATGER = '1' .And. (pcAliasNJM)->NJJ_TIPO   = '6' );		//NJJ_TIPO 6= (S) Devolucao de Deposito  
			  .Or. ( (cAliasNKQ)->NKQ_FATGER = '2' .And. (pcAliasNJM)->NJJ_TIPO   = '3' ) )		//NJJ_TIPO 3= (E) Entrada para Deposito
				
				/* verificar qual o último movimento para a tarifa na NKG e salvar a maior data encontrada em uma variável */
				
//				BeginSql Alias cAliasNKG
//					SELECT *
//					  FROM %Table:NKG% NKG
//					 WHERE NKG.%notDel%
//					   AND NKG_FILIAL = %XFilial:NKG%
//					   AND NKG_CODROM = %exp:(pcAliasNJM)->NJM_CODROM%
//					   AND NKG_ITEROM = %exp:(pcAliasNJM)->NJM_ITEROM%
//					   AND NKG_CODTRF = %exp:cCodTrf%
//					   AND NKG_CODTSE = %exp:(cAliasNKQ)->NKQ_CODTSE%
//					   AND NKG_ITETSE = %exp:(cAliasNKQ)->NKQ_ITETSE%
//				EndSQL
//				
//				dbSelectArea( cAliasNKG )
//				(cAliasNKG)->(dbGoTop())
//							
//				(cAliasNKG)->( dbCloseArea() )

				dbSelectArea( cAliasNKQ )
					
				////////////////////////////////////////////////////////////
				/// FATO GERADOR = ENTRADA                               ///
				////////////////////////////////////////////////////////////
				If (cAliasNKQ)->NKQ_FATGER = "0" //0=Entrada
					nPesoDesc  := 0
					nDescProp  := 0
					nPesoFinal := 0
					nPesoRom   := 0
					nPesoFis   := 0
					nPesoTrf   := 0
					
					cEntDev := (pcAliasNJR)->NJR_CODENT
					cLojDev := (pcAliasNJR)->NJR_LOJENT
					
					If StoD( dBaseCalc )  < dInicioMov //data movimento de
						(cAliasNKQ)->( DbSkip() )
						Loop
					EndIf	 
					
					// Se o parametro foi marcado para calcular somente para uma Nota fiscal
					If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
						If (pcAliasNJM)->( NJM_DOCNUM + NJM_DOCSER ) <> cDocOri + cSerOri
							(cAliasNKQ)->( DbSkip() )
							Loop
						EndIf
					EndIf
					
					// Calcular a data fim conforme a periodicidade							
					aCalcPer := fCalcPer( cAliasNKQ, , dBaseCalc, , 1, dFinalMov, ,nPesoLiq)		
					
					dNextCal := aCalcPer[1]
					
					If dNextCal > dFinalMov
						// --- ir para próximo registro NKQ
						(cAliasNKQ)->( DbSkip() )
						Loop
					Endif			
					
					// verificar se tem tarifa por resultado de análise
					nTarifa := fTarAnalise( cAliasNKQ, (pcAliasNJM)->NJM_CODROM )
					
					If nTarifa = 0
						If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
							nTarifa := (cAliasNKQ)->NKQ_VALTAR
						Else
							nTarifa := (cAliasNKQ)->NKQ_PERRET
						EndIf
					EndIf
					
					If  (cAliasNKQ)->NKQ_FATMUL = '0'  // 0-Peso
						//CONSIDERAR A QUANTIDADE QUE ESTÁ SENDO TRANSFERIDA DO ROMANEIO QUE ESTÁ SENDO CONSIDERADO.
						If (cAliasNKQ)->NKQ_TIPPES = '0'  // 0-Líquido					
							
//							for nR := 1 to oGridNBU:Length()
//								oGridNBU:GoLine(nR)
//								if !(oGridNBU:IsDeleted()) .AND. !EMPTY(oGridNBU:GetValue("NBU_CTRORI") .AND. (pcAliasNJM)->NJJ_CODROM = oGridNBU:GetValue("NBU_ROMORI"))
//									nPesoRom += oGridNBU:GetValue("NBU_QTDSEL")
//								endIf
//							next nR
							nPesoRom := nPesoLiq
							
						Else
							/* neste caso é Peso Bruto, porém é necesssário ratear o valor de 
							   NJJ_PSSUBT entre todos os registros de comercialização do romaneio */
							/** Rateio: ler todos registros da NJM do mesmo romaneio, tomando cuidado para não
								desposicionar a NJM que já está lida  */							
							nTotRom  := 0 //Zera acumulador
							nPesoRom := 0
							dbSelectArea('NJM')
							dbSetOrder(1)
							NJJ->( dbSeek( xFilial('NJM') + (pcAliasNJM)->NJM_CODROM ) )
							While ! NJJ->( Eof() ) .And. NJJ->( NJJ_FILIAL + NJJ_CODROM ) == xFilial('NJJ') + (pcAliasNJM)->NJM_CODROM
								nPesoRom += NJJ->NJJ_PSLIQU
								nPesoFis += NJJ->NJJ_PSSUBT
								NJJ->( DbSkip() )	
							EndDo
							
							nPesoTrf := nPesoLiq
							
//							for nR := 1 to oGridNBU:Length()
//								oGridNBU:GoLine(nR)
//								if !(oGridNBU:IsDeleted()) .AND. !EMPTY(oGridNBU:GetValue("NBU_CTRORI")) .AND. (pcAliasNJM)->NJJ_CODROM = oGridNBU:GetValue("NBU_ROMORI")
//									nPesoTrf += oGridNBU:GetValue("NBU_QTDSEL")
//								endIf
//							next nR
							
							//** O sistema calcula quanto, proporcionalmente em cada romaneio, quanto de desconto haveria na quantidade **//
							//** a ser transferida.  Então, o peso a ser transferido é somado com este desconto calculado **//
							//** e este novo valor é considerado como peso bruto para os cálculos da transferência.       **//
							
							//---------------------------------------------------------------------//
							//** EXEMPLO: Romaneio de 30.000 Kg com descontos totais de 1.000 Kg **//
							//**														   		 **//
							//** Peso sem desc      Peso desconto                          		 **//
							//**    30.000             1.000                               		 **//
							//**  Peso transferido  Peso desconto equivalente              		 **//
							//**     10.000            X                                   		 **//
							//**   30.000x = 10.000.000                                     	 **//
							//**   x = 10.000.000 / 30.000                                  	 **//
							//**   x = 333.33    (Peso equivalente do desconto )           		 **//
							//**   Somo valor da transferência com o desconto equivalente  		 **//
							//**   10.000 + 333.33  =  10.333,33                           		 **//
							//---------------------------------------------------------------------//
							
							//PESO SEM DESCONTO - PESO COM DESCONTO
							nPesoDesc := nPesoFis - nPesoRom
							
							nDescProp := (nPesoTrf * nPesoDesc) / nPesoFis
							
							nPesoFinal := nPesoTrf + nDescProp
							
							nPesoRom := nPesoFinal
						Endif	
					EndIf
					
					nFatMul := 1
					
					If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
						nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom )
					Else
						nFatMul := nPesoRom 
					Endif
					
					If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
						nValTar := nTarifa * nFatMul
					Else // 1=Retenção
						nValTar := (nTarifa * nFatMul) / 100   
					EndIf 
					
					If nValTar > 0
						dIniPer := StoD( dBaseCalc )
						dFimPer := dNextCal
						nPer    := 1
						
						fGravaNKG( cAliasNKQ, pcAliasNJM, pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, , , lGeraArr, plSimula)	
					EndIf					
					//Fim Fato Gerador Entrada	
					
				////////////////////////////////////////////////////////////
				/// FATO GERADOR = SAIDA                                 ///
				////////////////////////////////////////////////////////////
				ElseIf (cAliasNKQ)->NKQ_FATGER = "1"     // 1-Saída
					nPesoDesc  := 0
					nDescProp  := 0
					nPesoFinal := 0
					nPesoRom   := 0
					nPesoFis   := 0
					nPesoTrf   := 0
					
					If StoD(dBaseCalc ) >= dInicioMov //data movimento de
						// verificar a carência, quando o tipo de carência for 1a entrega 
						If    (cAliasNKQ)->NKQ_TIPCAR         = '0' // 0-primeira entrega
							dIni1aEntr := fCalcDtIni( cAliasNKQ, dFirstEnt )
							
							if StoD( dBaseCalc ) < dIni1aEntr
								// --- ir para próximo registro NKQ
								(cAliasNKQ)->( DbSkip() )
								Loop
							endif	
						EndIf
						
						DbSelectArea( "SC5" )
						DbSetOrder( 1 ) //C5_FILIAL+C5_NUM
						If DbSeek( xFilial( "SC5" ) + (pcAliasNJM)->( NJM_PEDIDO ) )
							
							DbSelectArea( "SF2" )
							DbSetOrder( 1 ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
							If DbSeek( xFilial( "SF2" ) + SC5->( C5_NOTA + C5_SERIE + C5_CLIENTE + C5_LOJACLI ) )								
								
								cEntDev := (pcAliasNJR)->NJR_CODENT
								cLojDev := (pcAliasNJR)->NJR_LOJENT	
								
								// Necessário tratar transferencia Origem e destino, não está fazendo ainda.... incompleto
								If (pcAliasNJM)->NJM_TRSERV $ '1|2' // NJM_TRSERV    0=Não;1=Tarifa Origem;2=Tarifa Destino
									
									//Buscar entidade devedora
									dbSelectArea('NJJ')
									dbSetOrder(1)
									If dbSeek( (pcAliasNJM)->NJJ_FILIAL + (pcAliasNJM)->NJJ_ROMREL ) 
										cEntDev := NJJ->NJJ_CODENT
										cLojDev := NJJ->NJJ_LOJENT		
									Endif								
								Endif
								
								/*ler SD2 	ITENS DA NOTA FISCAL SAÍDA/RETORNO, 'n' registro    		*/			
								BeginSql Alias cAliasSD2
									SELECT *
									  FROM %Table:SD2% SD2
									 WHERE SD2.%notDel%
									   AND D2_FILIAL  = %XFilial:SD2%
									   AND D2_DOC     = %exp:SF2->F2_DOC%
									   AND D2_SERIE   = %exp:SF2->F2_SERIE%
									   AND D2_CLIENTE = %exp:SF2->F2_CLIENTE%
									   AND D2_LOJA    = %exp:SF2->F2_LOJA%
								EndSQL
								
								dbSelectArea( cAliasSD2 ) // ITENS DA NOTA DE SAÍDA 
								While ! (cAliasSD2)->( Eof() )  
									
									// Se o parametro foi marcado para calcular somente para uma Nota fiscal
									If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
										If (cAliasSD2)->( D2_NFORI + D2_SERIORI ) <> cDocOri + cSerOri
											(cAliasSD2)->( DbSkip() )
											Loop
										EndIf
									EndIf
									
									dbSelectArea( "SD1" )  // ITENS DA NOTA DE ENTRADA ORIGINAL
									dbSetOrder( 1 )
									If dbSeek( xFilial( "SD1" ) + (cAliasSD2)->( D2_NFORI + D2_SERIORI + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEMORI ) ) 
										
										/***---------------------------------------------------
											A leitura abaixo utiliza um espelho da tabela NJM,
											já posicionada com o alias pcAliasNJM.
											Ao manutenir esse código favor dar atenção a essa
											interação, pois, afeta toda a criação de movimentos
											para fato gerador de saída.
										----------------------------------------------------***/
										dbSelectArea('NJM')
										dbSetOrder(1)
										If NJM->( dbSeek( xFilial('NJM') + SD1->( D1_CODROM + D1_ITEROM ) ) )
											If __lDataCalc == "1" //documento fiscal
                                                dBaseCalcOrig := NJM->NJM_DTRANS
                                            else    
                                                dBaseCalcOrig := POSICIONE("NJJ",1,NJM->(NJM_FILIAL+NJM_CODROM),"NJJ_DATA") 
                                            EndIf

                                            If (cAliasNKQ)->NKQ_TIPCAR  == '1' // 1=cada entrega
												dIniPerCalc := fCalcDtIni ( cAliasNKQ, DtoS( dBaseCalcOrig ) )
												
												// verificar a carência, quando o tipo de carência for a Cada Entrega 
												if StoD( dBaseCalc ) <  dIniPerCalc
													// --- ir para próximo registro SD2
													(cAliasSD2)->( DbSkip() )
													Loop
												endif
											else 
												// carencia pela 1a entrega, porém não poderia calcular antes da própria entrega acontecer
												If 	dIni1aEntr > dBaseCalcOrig
													dIniPerCalc := dIni1aEntr  
												Else 
													dIniPerCalc := dBaseCalcOrig
												Endif			
											EndIf
											
											// calcular a data fim conforme a periodicidade																						
											aCalcPer := fCalcPer( cAliasNKQ, , DtoS( dIniPerCalc ), StoD( dBaseCalc ), 2, dFinalMov, , nPesoLiq )	
											
											nPer     := aCalcPer[2]
											
											If nPer = 0	//  --- ir para próximo registro SD2
												(cAliasSD2)->( DbSkip() )
												Loop
											EndIf
											
											// verificar se tem tarifa por resultado de análise
											nTarifa := fTarAnalise( cAliasNKQ, NJM->NJM_CODROM )   // este da NJM registro é de origem 
											
											If nTarifa = 0
												If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
													nTarifa := (cAliasNKQ)->NKQ_VALTAR
												ELSE
													nTarifa := (cAliasNKQ)->NKQ_PERRET
												EndIf
											EndIf
											
											// verificar a base de cálculo 
											nFatMul := 1
											
											If  (cAliasNKQ)->NKQ_FATMUL = '0'  // 0-Peso
												If (cAliasNKQ)->NKQ_TIPPES = '1' // 1-Peso Bruto
													nTotRom  := 0 //Zera acumulador
													nPesoRom := 0
													dbSelectArea('NJM')
													dbSetOrder(1)
													NJM->( dbSeek( xFilial('NJM') + (pcAliasNJM)->NJM_CODROM ) )
													While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial('NJM') + (pcAliasNJM)->NJM_CODROM
														nPesoRom += NJM->NJM_QTDFCO
														nPesoFis += NJM->NJM_QTDFIS
														NJM->( DbSkip() )	
													EndDo
													
//													for nR := 1 to oGridNBU:Length()
//														oGridNBU:GoLine(nR)
//														if !(oGridNBU:IsDeleted()) .AND. !EMPTY(oGridNBU:GetValue("NBU_CTRORI")) .AND. (pcAliasNJM)->NJJ_CODROM = oGridNBU:GetValue("NBU_ROMORI")
//															nPesoTrf += oGridNBU:GetValue("NBU_QTDSEL")
//														endIf
//													next nR
													
													nPesoTrf := nPesoLiq
														
													//** O sistema calcula quanto, proporcionalmente em cada romaneio, quanto de desconto haveria na quantidade **//
													//** a ser transferida.  Então, o peso a ser transferido é somado com este desconto calculado **//
													//** e este novo valor é considerado como peso bruto para os cálculos da transferência.       **//
													
													//---------------------------------------------------------------------//
													//** EXEMPLO: Romaneio de 30.000 Kg com descontos totais de 1.000 Kg **//
													//**														   		 **//
													//** Peso sem desc      Peso desconto                          		 **//
													//**    30.000             1.000                               		 **//
													//**  Peso transferido  Peso desconto equivalente              		 **//
													//**     10.000            X                                   		 **//
													//**   30.000x = 10.000.000                                     	 **//
													//**   x = 10.000.000 / 30.000                                  	 **//
													//**   x = 333.33    (Peso equivalente do desconto )           		 **//
													//**   Somo valor da transferência com o desconto equivalente  		 **//
													//**   10.000 + 333.33  =  10.333,33                           		 **//
													//---------------------------------------------------------------------//
													
													//PESO SEM DESCONTO - PESO COM DESCONTO
													nPesoDesc := nPesoFis - nPesoRom
													
													nDescProp := (nPesoTrf * nPesoDesc) / nPesoFis
													
													nPesoFinal := nPesoTrf + nDescProp
													
													nPesoRom := nPesoFinal
													 
												Else  
//													for nR := 1 to oGridNBU:Length()
//														oGridNBU:GoLine(nR)
//														if !(oGridNBU:IsDeleted()) .AND. !EMPTY(oGridNBU:GetValue("NBU_CTRORI")) .AND. (pcAliasNJM)->NJJ_CODROM = oGridNBU:GetValue("NBU_ROMORI")
//															nPesoRom += oGridNBU:GetValue("NBU_QTDSEL")
//														endIf
//													next nR
													
													nPesoRom := nPesoLiq
													
													//nPesoRom := (cAliasSD2)->D2_QUANT
												Endif    
												
												If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
													nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom)
												Else
													nFatMul := nPesoRom
												EndIf
											EndIf
											
											If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor
												nValTar := nTarifa * nFatMul
											Else                   // 1=Retenção, na saída a base será 100% menos - o % retenção
												nValTar := (nTarifa * nFatMul) / (100 - nTarifa)  
											EndIf 
											
											If (cAliasNKQ)->NKQ_FATMPE = '0' // 0=Qt.Períodos
												nValTar := nValTar * nPer
											EndIf
											
											//Se valor tarifa > 0 então cria movimento	
											If nValTar > 0 
												dIniPer := dBaseCalcOrig
												dFimPer := StoD( dBaseCalc )
												
												//Criação NKG
												fGravaNKG( cAliasNKQ, pcAliasNJM, pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, NJM->NJM_DOCSER, NJM->NJM_DOCNUM, lGeraArr,.F. )
												
											EndIf				
											
											//NJM->( DbSkip() )							
										EndIf											
									EndIf
									
									(cAliasSD2)->( DbSkip() )										    
								EndDo //Fim laço SD2
								(cAliasSD2)->( dbCloseArea() )
								
							Endif
						Endif								
					EndIf			       
					// Fim Fato Gerador Saida    
				
				////////////////////////////////////////////////////////////
				/// FATO GERADOR = SALDO                                 ///
				////////////////////////////////////////////////////////////
				ElseIf (cAliasNKQ)->NKQ_FATGER = "2"     // 2-Saldo 
					nPesoDesc  := 0
					nDescProp  := 0
					nPesoFinal := 0
					nPesoRom   := 0
					nPesoFis   := 0
					nPesoTrf   := 0
					
					cEntDev := (pcAliasNJR)->NJR_CODENT
					cLojDev := (pcAliasNJR)->NJR_LOJENT
					
					// Se o parametro foi marcado para calcular somente para uma Nota fiscal
					If ! Empty( cDocOri ) .And. ! Empty( cSerOri )
						If (pcAliasNJM)->( NJM_DOCNUM + NJM_DOCSER ) <> cDocOri + cSerOri
							(cAliasNKQ)->( DbSkip() )
							Loop
						EndIf
					EndIf
					
					// Data final de carencia, considerando dias corridos
					dFimCaren := StoD(dBaseCalc) + ( cAliasNKQ )->NKQ_DIACAR
					If   (cAliasNKQ)->NKQ_TIPCAR   = '0' // 0-primeira entrega
					    dFimCaren := StoD(dFirstEnt) + ( cAliasNKQ )->NKQ_DIACAR
					EndIf   
					
					// calcular todos os períodos para a entrega 			
					aCalcPer := fCalcPer( cAliasNKQ, pcAliasNJM, dBaseCalc, dFinalMov, 3, dFinalMov, ( cAliasNKQ )->NKQ_DIACAR, nPesoLiq) 
					
					dNextCal := aCalcPer[1]   
					
					// Verificar se tem retenção já calculadas para esta nota 
					If !_lDestino
					   aNotasRet := X262NOTA( (pcAliasNJM)->NJM_CODCTR, (pcAliasNJM)->NJM_DOCNUM, (pcAliasNJM)->NJM_DOCSER )
					EndIf
					
					If (cAliasNKQ)->NKQ_PERCOB = '0' // diario -> criar os períodos
						fPerDiario (pcAliasNJM, aNotasRet, dFinalMov, dFimCaren)
					EndIf 
					
					// Procura todas as NFs de Saída que tiveram como origem a NF de Entrada a Depósito do romaneio posicionado em pcAliasNJM
//					dbSelectArea( 'SD2' ) // ITENS DA NOTA DE SAÍDA 
//					dbSetOrder( 10 )
//					dbSeek( xFilial( 'SD2' ) + (pcAliasNJM)->NJM_DOCNUM + (pcAliasNJM)->NJM_DOCSER )
//					While ! SD2->( Eof() ) ;
//					.And. SD2->( D2_FILIAL + D2_NFORI + D2_SERIORI ) == xFilial("SD2") + (pcAliasNJM)->NJM_DOCNUM + (pcAliasNJM)->NJM_DOCSER
//						
//						If LEN(aPeriodos) > 0 .And. SD2->D2_EMISSAO <= dFinalMov
//							nVezes := LEN(aPeriodos)
//							
//							For nX := 1 to nVezes
//								If (cAliasNKQ)->NKQ_PERCOB = '0' // diario
//									if aPeriodos[ nX, 1] >= SD2->D2_EMISSAO  
//								   		aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - SD2->D2_QUANT		
//									endif
//								else 
//									If   ( dFimCaren >= aPeriodos[ nX, 1] .and. dFimCaren <= aPeriodos[ nX, 2] .and. dFimCaren >= SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PERCOB <> '0' .and. (cAliasNKQ)->NKQ_DIACAR > 0) ;
//									.or. (aPeriodos[ nX, 2] > SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PEPARC = '0') ; // tarifa livre  0 – Livre 1 – Cheia 2 – Proporcional
//									.or. (aPeriodos[ nX, 1] > SD2->D2_EMISSAO .and. (cAliasNKQ)->NKQ_PEPARC $ '1|2') // tarifa cheia - Atenção Proporcional não pode utilizar - tem validação no cadastro
//										aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - SD2->D2_QUANT					
//									Endif
//								
//								endif
//							Next nX
//						EndIf
//								 
//						SD2->( DbSkip() )
//					EndDo         
					
					// VERIFICAR SE TEM RETENÇÕES JÁ CALCULADAS
					For nS := 1 to Len( aNotasRet )
						
						nQuant	 := aNotasRet[ nS, 2 ]
						dDtrans  := StoD(aNotasRet[ nS, 1 ])
						lCalcula := iif(aNotasRet[ nS, 3 ] = (cAliasNKQ)->NKQ_CODDES, .T., .F.)
						
						If LEN(aPeriodos) > 0 .And. dDtrans <= dFinalMov .AND. lCalcula
							nVezes := LEN(aPeriodos)
							
							For nX := 1 to nVezes
								If (cAliasNKQ)->NKQ_PERCOB = '0' // diario
								
									if aPeriodos[ nX, 1] >= dDtrans 
								   		aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - nQuant		
									endif
								else
									If   (dFimCaren >= aPeriodos[ nX, 1] .and. dFimCaren <= aPeriodos[ nX, 2] .and. dFimCaren >= dDtrans .and. (cAliasNKQ)->NKQ_PERCOB <> '0'  .and. ( cAliasNKQ )->NKQ_DIACAR > 0 ) ;
									.or. (aPeriodos[ nX, 2] > dDtrans .and. (cAliasNKQ)->NKQ_PEPARC = '0') ; // tarifa livre  0 – Livre 1 – Cheia 2 – Proporcional
									.Or. (aPeriodos[ nX, 1] > dDtrans .and. (cAliasNKQ)->NKQ_PEPARC $ '1|2') // tarifa cheia - Atenção Proporcional não pode utilizar - tem validação no cadastro
										aPeriodos[ nX, 3] := aPeriodos[ nX, 3] - nQuant		
									Endif
								endif 
							Next nX
						endif
					Next nS
					
					/*********/
				
					If LEN(aPeriodos) > 0
						qtperAnt := 0
						
						For nX := 1 to LEN(aPeriodos)
							If (cAliasNKQ)->NKQ_DESCPE = '1' .And. (cAliasNKQ)->NKQ_TIPCOB = '1' //Sim##Peso 
								aPeriodos[ nX, 3] -= qtPerAnt
							Endif		 
							If aPeriodos[ nX, 3] >= 0
								lPerVal := .T.	
								
								// verificar a carência E se os períodos são maiores que último cálculo
								If   (cAliasNKQ)->NKQ_TIPCAR   = '0' // 0-primeira entrega
									dIniPerCalc := fCalcDtIni( cAliasNKQ, dFirstEnt )
								Else
									dIniPerCalc := fCalcDtIni( cAliasNKQ, dBaseCalc )
								EndIf    
								
								IF lPerVal .OR. _lDestino
									// valor tarifa  
									If (cAliasNKQ)->NKQ_TIPCOB  = '0' // 0=Valor 
										nTarifa := (cAliasNKQ)->NKQ_VALTAR
									ELSE
										nTarifa := (cAliasNKQ)->NKQ_PERRET
									EndIf
									
									// verificar a base de cálculo 
									nFatMul := 1
									
									If  (cAliasNKQ)->NKQ_FATMUL   = '0'  // 0-Peso
										nPesoRom := nPesoLiq
										
										If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
											nFatMul := AGRX001( (pcAliasNJM)->NJJ_UM1PRO , (cAliasNKQ)->NKQ_UMTAR, nPesoRom )
										Else
											nFatMul := nPesoRom 
										EndIf
									EndIf
									
									If (cAliasNKQ)->NKQ_TIPCOB = '0' // 0=Valor 
										nValTar :=  nTarifa * nFatMul
									ELSE                   // 1=Retenção
										nValTar := (nTarifa * nFatMul) / 100   
									EndIf 
									
									nPer := 1      // saldo sempre será 1 período
									If (cAliasNKQ)->NKQ_FATMPE = '0' /* Qt Periodos = 0 */ ;  
									.And. (cAliasNKQ)->NKQ_PERCOB = '0' // diario
										nPer    := aPeriodos[ nX, 2] - aPeriodos[ nX, 1] 											   
										nValTar := nValTar * nPer
									EndIf
									
									If nValTar > 0 
										qtPerAnt += nValTar
										dIniPer  := aPeriodos[ nX, 1]
										dFimPer  := aPeriodos[ nX, 2]
										
										fGravaNKG( cAliasNKQ , pcAliasNJM , pcAliasNJR, nTarifa, nFatMul, dIniPer, dFimPer, nPer, nValTar, , , lGeraArr,plSimula) 										
									EndIf	
									
								Endif								
							Endif
						Next nX 							
					Endif
					
					// Fim Fato Gerador Saldo
				EndIf
			Endif
			
			(cAliasNKQ)->( DbSkip() )
		EndDo //Fim laço NKQ
		(cAliasNKQ)->( dbCloseArea() )
	else
		Help( ,,"Ajuda",,"Contrato "+ (pcAliasNJR)->NJR_CODCTR +" não possui tabela de serviço.", 1, 0 ) //"Ajuda" //"Contrato não possui saldo."
	endIf
Return( NIL )


/*/{Protheus.doc} fCalcPer
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function fCalcPer( pAlias, pAliasNJM, pdDataIni, pDataFim, pPer, pdFinal, nDiasCar, nPesoLiq )
	Local lContinua := .T.
	Local dNextCal  
	Local nPer      := 0  
	Local nDiasProp := 0
	Local aRetorno  := { , , }
	Local nQtdFco	:= 0
	Local nCar		:= 0
	
	aPeriodos := {} //Limpa Array
	
	/* *** Ver qual sera o proximo calculo *** */
	If pPer = 1
		
		If   ((( pAlias )->NKQ_PERCOB = '2') .Or. (( pAlias )->NKQ_PERCOB = '1') .And. (Day(StoD(pdDataIni)) > 15) )
			// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
			
			If Month(StoD(pdDataIni)) = 12
				dNextCal := CtoD('01/01/' + STR(YEAR(StoD(pdDataIni))+1,4))
			Else
				dNextCal := CtoD('01/' + STR(MONTH(StoD(pdDataIni)) + 1,2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
			Endif
		Else
			If ( pAlias )->NKQ_PERCOB = '1' // quinzenal
				dNextCal := Ctod( '16/' + STR(MONTH(StoD(pdDataIni)),2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
			Else
				// diario ou nulo 
				dNextCal := StoD(pdDataIni) + 1
			EndIf
				
			dNextCal := dNextCal - 1
		Endif
	Else 
		If ( pAlias )->NKQ_PERCOB = '0' // diario
        	nPer := pDataFim - StoD(pdDataIni)   // retorna a quantidade de dias
        Else 
			//trata carencia
			If !Empty(nDiasCar)

				nDiasCar := Iif(nDiasCar<15,15,nDiasCar) //arredondamento pra quinzena.
				nQuinzCar := (nDiasCar/15) //quantidade de quinzena
		
				For nCar := 1 to nQuinzCar
					If Day(StoD(pdDataIni)) > 15 //se a data inicial for maior do que quinze
						// vai até dia 01 do outro mês
						pdDataIni := CtoD('01/' + STR(MONTH(StoD(pdDataIni)) + 1,2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
					Else //menor do que 15
						// vai até dia 15.
						pdDataIni := CtoD( '16/' + STR(MONTH(StoD(pdDataIni)),2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
					EndIf

					If ValType(pdDataIni) == "D" //proteger os tipos precisa ser string.
						pdDataIni := DtoS(pdDataIni) 
					EndIf 

				Next nCar

				If ValType(pdDataIni) == "D" //proteger os tipos precisa ser string.
					pdDataIni := DtoS(pdDataIni) 
				EndIf 
			EndIf

        	While lContinua

				If ( pAlias )->NKQ_PERCOB = '2' .Or. (( pAlias )->NKQ_PERCOB = '1' .And. Day(StoD(pdDataIni)) > 15 ) 
					// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
					
					If MONTH(StoD(pdDataIni)) = 12
						dNextCal := CtoD('01/01/' + STR(YEAR(StoD(pdDataIni)) + 1,4))
					Else
						dNextCal := CtoD('01/' + STR(MONTH(StoD(pdDataIni)) + 1,2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
					Endif
				Elseif ( pAlias )->NKQ_PERCOB = '1' // quinzenal
					dNextCal := CtoD( '16/' + STR(MONTH(StoD(pdDataIni)),2) + '/' + STR(YEAR(StoD(pdDataIni)),4))
				Endif
	           
	            If !Empty(dNextCal)
	           		dNextCal := dNextCal - 1
	           	Endif	
	           
				/*if nQtdFco = 0
					for nR := 1 to oGridNBU:Length()
						oGridNBU:GoLine(nR)
						if !(oGridNBU:IsDeleted()) .AND. !EMPTY(oGridNBU:GetValue("NBU_CTRORI")) .AND. ((pAliasNJM)->NJJ_CODROM = oGridNBU:GetValue("NBU_ROMORI"))
							nQtdFco += oGridNBU:GetValue("NBU_QTDSEL")
						endIf
					next nR
				endIf*/

				// quando chegar na data fim, parar de contar períodos
				If dNextCal >= pdFinal .Or. dNextCal >= pDataFim
				    
				   // verificar se tem período parcial ou cheio para cobrar  
				   if ( pAlias )->NKQ_PEPARC = '1'  // tarifa CHEIA  0 – Livre 1 – Cheia 2 – Proporcional
				   		If pPer = 3 //saldo    
							aAdd( aPeriodos, { StoD(pdDataIni), dNextCal, nQtdFco /*( pAliasNJM )->NJM_QTDFCO*/ })
						Endif	 					   
				       nPer := nPer + 1
				   elseif ( pAlias )->NKQ_PEPARC = '2'  // tarifa PROPORCIONAL  0 – Livre 1 – Cheia 2 – Proporcional
				       nDiasProp := (pDataFim - StoD(pdDataIni)) 
				       
				      If nDiasProp > 0 
					       if ( pAlias )->NKQ_PERCOB = '1' // quinzenal 
					          nPer := nPer + (nDiasProp / 15)
					       else 
					          nPer := nPer + (nDiasProp / 30) 
					       endif
					   Endif         
				   endif
				
					lContinua := .F.
				Else 
					If pPer = 3 //saldo    
						/* Este bloco precisa de uma worktable para guardar os períodos
						 WT_DATINI
						 WT_DATFIM
						 WT_QTSALDO   -> ESTE CAMPO SERÁ ALIMENTADO COM BASE NAS SAÍDAS */
					  	aAdd( aPeriodos, { StoD(pdDataIni), dNextCal, nQtdFco /*( pAliasNJM )->NJM_QTDFCO*/ }) 					  	
   		           EndIf	 
					nPer      := nPer + 1
					pdDataIni := DtoS(dNextCal + 1)
   		       EndIf        
		   EndDo
		EndIf     
	Endif		
	
	aRetorno[1] := dNextCal
	aRetorno[2] := nPer
	aRetorno[3] := nDiasProp
	
Return (aRetorno)


/*/{Protheus.doc} fPerDiario
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function fPerDiario( pAliasNJM, aRetAnt, pDataFim, pFimCaren )
	Local nX  		   := 0
	
	Default aRetAnt  := {}   // pode não ter retenção anterior já calculada 
	
	aPeriodos  := {} //Limpa Array
	aDatDia    := {}
	 			
	//Quando faz a simulação da transferência para o destino não verifica...
	If !(_lDestino)   
		// Procura todas as NFs de Saída que tiveram como origem a NF de Entrada a Depósito do romaneio posicionado em pAliasNJM
		dbSelectArea( 'SD2' ) // ITENS DA NOTA DE SAÍDA 
		dbSetOrder( 10 )
		dbSeek( xFilial( 'SD2' ) + (pAliasNJM)->NJM_DOCNUM + (pAliasNJM)->NJM_DOCSER )
		While ! SD2->( Eof() ) ;
		.And. SD2->( D2_FILIAL + D2_NFORI + D2_SERIORI ) == xFilial("SD2") + (pAliasNJM)->NJM_DOCNUM + (pAliasNJM)->NJM_DOCSER
					
			if SD2->D2_EMISSAO <= pDataFim		
				if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == SD2->D2_EMISSAO }) = 0
					// criar mais um registro com a data da saída
					aAdd( aDatDia, { SD2->D2_EMISSAO , })
				endif
			endif  				
			SD2->( DbSkip() )
		EndDo         
		
		// VERIFICAR AS DATA DE RETENÇÕES JÁ CALCULADAS
		For nX := 1 to Len( aRetAnt )
			If StoD(aRetAnt[ nX, 1 ]) <= pDataFim
		
				// Neste ponto poderia verificar qual serviço que está no aRetAnt, e só considerar os que forem do tipo Quebra Técnica na NKQ ou Desconta Período
				if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == StoD(aRetAnt[ nX, 1 ]) }) = 0
					// criar mais um registro com a data da saída
					aAdd( aDatDia, {StoD(aRetAnt[ nX, 1 ]), })
				endif
			ENDIF
							
		Next nX	
	EndIf

    If __lDataCalc == "1" //documento fiscal
        dBaseCalc := (pcAliasNJM)->NJM_DTRANS
    else    
        dBaseCalc := (pcAliasNJM)->NJJ_DATA
    EndIf
	
	// Verificar o final da carência por dias corridos
	if pFimCaren > StoD( dBaseCalc ) .and. pFimCaren < pDataFim .and. (Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == pFimCaren }) = 0)
		// criar mais um registro com a data final da carência
		aAdd( aDatDia, {pFimCaren, })
	endif  				
	
	// Verificar a data final de corte, no mínimo terá esta data no aDataDia, ou seja uma linha no array 
	if Len( aDatDia ) = 0 .or. ASCAN(aDatDia, {|x| x[1] == pDataFim }) = 0
		// criar mais um registro com a data final de corte do cálculo 
		aAdd( aDatDia, {pDataFim, })
	endif  
	
	if  Len( aDatDia ) = 0
		// criar pelo menos um registro quando não teve nenhuma movimentação
	   aAdd( aDatDia, {StoD( dBaseCalc ), pDataFim })
	else    
		//Ordena o Array Multidimensional levando em consideração somente a primeira coluna
		aSortComp  := ASORT(aDatDia,,, { |x, y| x[1] < y[1] })
	endif
		
	For nX := 1 to Len( aDatDia )
		
		// data inicial do período diário, depois da primeira saída   	
		if  nX = 1
			aDatDia[nX, 2] := aDatDia[nX, 1]
			aDatDia[nX, 1] := StoD( dBaseCalc )
		else 
			aDatDia[nX, 2] := aDatDia[nX, 1]
			aDatDia[nX, 1] := aDatDia[nX - 1, 2]     // dia final do registro anterior   
		endif
		 
	Next nX	
	
	For nX := 1 to Len( aDatDia )
		aAdd( aPeriodos, { aDatDia[nX, 1], aDatDia[nX, 2], (pAliasNJM)->NJM_QTDFCO })
		
	Next nX	

Return (.T.)


/*/{Protheus.doc} fCalcDtIni
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function fCalcDtIni( pAlias, pdDataIni)
	Local dRetIni   := StoD(pdDataIni)
	Local iPerCar   := 0 
	Local iPer      := 0
	Local nX		  := 0
	
	If     ( pAlias )->NKQ_DIACAR = 0  ; // sem carencia  
	.or.   ( pAlias )->NKQ_PERCOB = '0'; // Diário
	.or.   ( pAlias )->NKQ_PEPARC = '2'; // Cobrança proporcional em período parcial
	.or.   ( pAlias )->NKQ_FATMPE = '1'  // 0=Qt.Períodos;1=Unidade
	 
	dRetIni := StoD(pdDataIni) + ( pAlias )->NKQ_DIACAR 
			
	else
		if ( pAlias )->NKQ_PERCOB = '1' // Quinzenal
			iPerCar := ( pAlias )->NKQ_DIACAR / 15
		else 
			iPerCar := ( pAlias )->NKQ_DIACAR / 30	// mensal
		endif
		
		if     ( pAlias )->NKQ_PEPARC = '0' // Livre 
			iPer	:= int(iPerCar)
		
		elseif ( pAlias )->NKQ_PEPARC = '1'  // 1 – Cheia
			iPer    := int(iPerCar)
			iPerCar := iPerCar - iPer
			
			// se for período parcial, considera um período inteiro 
			if iPerCar > 0
				iPer    := iPer + 1
			endif
		endif
		
		if iper > 0
			// calcular a data do ultimo período de carência
			for nX := 1 to iPer
				If ( pAlias )->NKQ_PERCOB = '2' .Or. (( pAlias )->NKQ_PERCOB = '1' .And. Day(dRetIni) > 15 ) 
              	// quinzenal > 15 ou mensal -> dia 01 do mes seguinte */
              	
              	If MONTH(dRetIni) = 12
              		dRetIni := CtoD('01/01/' + STR(YEAR(dRetIni) + 1,4))
              	Else
              		dRetIni := CtoD('01/' + STR(MONTH(dRetIni) + 1,2) + '/' + STR(YEAR(dRetIni),4))
	              Endif
	           Elseif ( pAlias )->NKQ_PERCOB = '1' // quinzenal
	           	dRetIni := CtoD( '16/' + STR(MONTH(dRetIni),2) + '/' + STR(YEAR(dRetIni),4))
	           Endif
			next nX
		endif
	endif 	 
	
Return (dRetIni)


/*/{Protheus.doc} fGravaNKG
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function fGravaNKG( pcAliasNKQ, pcAliasNJM, pcAliasNJR, pnTarifa, pnFatMul, pdIniPer, pdFimPer, pnPer, pnValTar, pcSerOri, pcNfOri, lGeraArr, lSimul )
	Local nDecPeso   := SuperGetMV("MV_OGDECPS",,0)
	Local cCtrCtrl   := ""
	Local nNextItem  := 0
	Local cCtrDes	 := NBT->NBT_CODTRF
	
	If cCtrCtrl == (pcAliasNJR)->NJR_CODCTR
		nNextItem += 1
	Else
		cCtrCtrl  := (pcAliasNJR)->NJR_CODCTR
		nNextItem := fGetNextNKG( (pcAliasNJR)->NJR_CODCTR)
	Endif	
	
	RecLock( 'NKG', .t. )
		NKG->NKG_FILIAL := FWxFilial('NKG')
		NKG->NKG_CODCTR := (pcAliasNJR)->NJR_CODCTR
		NKG->NKG_ITEMOV := Strzero( nNextItem, 8 )
		NKG->NKG_CODDEV := cEntDev 
		NKG->NKG_LOJDEV := cLojDev
		NKG->NKG_CODENT := (pcAliasNJR)->NJR_CODENT
		NKG->NKG_LOJENT := (pcAliasNJR)->NJR_LOJENT
		NKG->NKG_CODSAF := (pcAliasNJR)->NJR_CODSAF
		NKG->NKG_CODPRO := (pcAliasNJR)->NJR_CODPRO
		NKG->NKG_UM1PRO := (pcAliasNJR)->NJR_UM1PRO
		NKG->NKG_DATCAL := dDatabase 
		NKG->NKG_QTDBAS := pnFatMul
		NKG->NKG_QTDAJU := 0 // inicialmente o ajuste é zero, pois poderá ser ajustado em tela
		NKG->NKG_CODTSE := (pcAliasNKQ)->NKQ_CODTSE
		NKG->NKG_ITETSE := (pcAliasNKQ)->NKQ_ITETSE
		NKG->NKG_CODDES := (pcAliasNKQ)->NKQ_CODDES
		NKG->NKG_FATGER := (pcAliasNKQ)->NKQ_FATGER
		NKG->NKG_PERCOB := (pcAliasNKQ)->NKQ_PERCOB
		NKG->NKG_DATINI := pdIniPer
		NKG->NKG_DATFIM := pdFimPer
		NKG->NKG_QTDPER := pnPer
		NKG->NKG_PERRET := (pcAliasNKQ)->NKQ_PERRET
		NKG->NKG_SERORI := pcSerOri
		NKG->NKG_NFORI  := pcNfOri
		NKG->NKG_CODTRF := cCtrDes
		NKG->NKG_CODROM := (pcAliasNJM)->NJM_CODROM
		
		If !lSimul
			//NKG->NKG_CODROM := (pcAliasNJM)->NJM_CODROM
			NKG->NKG_ITEROM := (pcAliasNJM)->NJM_ITEROM
			NKG->NKG_DOCSER := (pcAliasNJM)->NJM_DOCSER
			NKG->NKG_DOCNUM := (pcAliasNJM)->NJM_DOCNUM
			NKG->NKG_DOCEMI := StoD( (pcAliasNJM)->NJM_DTRANS )
			
			If (pcAliasNKQ)->NKQ_APROV = "0" // Automatica
				if (pcAliasNKQ)->NKQ_TIPRET = '1' // Cobrança Retenção
					NKG->NKG_STATUS := '4' //Pend Comerc
				else
					NKG->NKG_STATUS := '1' //Atualizado
				endif	 
			Else
				NKG->NKG_STATUS := '0' //Pendente
			EndIf
		ELSE
			NKG->NKG_DOCEMI := dFimPer    // DATA DA SIMULAÇÃO
			NKG->NKG_STATUS := '9'        //Simulado
		ENDIF
		
		If (pcAliasNKQ)->NKQ_TIPCOB = "0" // 0=Valor
			NKG->NKG_VALTAR := pnTarifa
			NKG->NKG_UMTAR  := (pcAliasNKQ)->NKQ_UMTAR
			NKG->NKG_VALSER := pnValTar 
			NKG->NKG_VLTARC := pnValTar
		Else
			NKG->NKG_QTDRET := ROUND( pnValTar, nDecPeso ) //TODO: Verificar se este é o valor gravado do serviço
			NKG->NKG_QTRETC := ROUND( pnValTar, nDecPeso )
			NKG->NKG_TIPRET := (pcAliasNKQ)->NKQ_TIPRET
		EndIf
		
	NKG->( msUnLock() )	 
	
	If lGeraArr	
		
		If NKG->NKG_QTDRET > 0
			
			aAdd( aMovServR,{;
			NKG->NKG_CODCTR,;
			NKG->NKG_CODTRF,;
			NKG->NKG_ITEMOV,;
			NKG->NKG_CODROM,;
			NKG->NKG_CODDEV,;
			NKG->NKG_LOJDEV,;
			NKG->NKG_CODSAF,;
			NKG->NKG_CODPRO,;
			NKG->NKG_DOCSER,;
			NKG->NKG_DOCNUM,;
			NKG->NKG_DOCEMI,;
			NKG->NKG_CODTSE,;
			NKG->NKG_CODDES,;
			NKG->NKG_FATGER,;
			NKG->NKG_PERCOB,; 
			NKG->NKG_QTDPER,;
			NKG->NKG_QTDBAS,;
			NKG->NKG_PERRET,;
			NKG->NKG_UMTAR,;
			NKG->NKG_QTDRET})
			
		Else
			
			aAdd( aMovServV,{;
			NKG->NKG_CODCTR,;
			NKG->NKG_CODTRF,;
			NKG->NKG_ITEMOV,;
			NKG->NKG_CODROM,;
			NKG->NKG_CODDEV,;
			NKG->NKG_LOJDEV,;
			NKG->NKG_CODSAF,;
			NKG->NKG_CODPRO,;
			NKG->NKG_DOCSER,;
			NKG->NKG_DOCNUM,;
			NKG->NKG_DOCEMI,;
			NKG->NKG_CODTSE,;
			NKG->NKG_CODDES,;
			NKG->NKG_FATGER,; 
			NKG->NKG_PERCOB,;   
			NKG->NKG_QTDPER,;
			NKG->NKG_QTDBAS,;
			NKG->NKG_VALTAR,;
			NKG->NKG_UMTAR,;
			NKG->NKG_VALSER})		
			
		Endif		
	Endif                 
	
Return( .T. )	


/*/{Protheus.doc} fGetNextNKG
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@param pcContrato, , descricao
@type function
/*/
Static Function fGetNextNKG( pcContrato )
	Local cAliasQuery :=	GetNextAlias()
	Local nNextItem := 0
	
	BeginSql Alias cAliasQuery
		SELECT NKG_ITEMOV
		  FROM %Table:NKG% NKG
		 WHERE NKG.%notDel%
		   AND NKG_FILIAL = %exp:xFilial('NKG')%
		   AND NKG_CODCTR = %exp:pcContrato%
		 ORDER BY NKG_ITEMOV DESC			
	EndSql	
	
	dbSelectArea(cAliasQuery)
	(cAliasQuery)->( dbGoTop() )
	
	if ! (cAliasQuery)->( Eof() )
		nNextItem := Val( (cAliasQuery)->NKG_ITEMOV )
	endif
		
	(cAliasQuery)->( dbCloseArea() )
	
Return( nNextItem + 1 )


/*/{Protheus.doc} fTarAnalise
//Baseado no OGA262.
@author brunosilva
@since 16/01/2019
@version 1.0
@type function
/*/
Static Function fTarAnalise ( pAliasNKQ, pcRomaneio ) 
	Local nTarifa   := 0.00
	Local cAliasNKR := GetNextAlias()
	
	// Ler todas as tarifas por resultado analise da tabela  
	// Ler NKR com chave: "NKR_FILIAL+NKR_CODTSE+NKR_ITETSE"
	BeginSql Alias cAliasNKR
		SELECT *
		  FROM %Table:NKR% NKR
		 WHERE NKR.%notDel%
		   AND NKR_FILIAL = %XFilial:NKR%
		   AND NKR_CODTSE = %exp:( pAliasNKQ )->NKQ_CODTSE%
		   AND NKR_ITETSE = %exp:( pAliasNKQ )->NKQ_ITETSE%		   
	EndSQL
	
	dbSelectArea( cAliasNKR )
	(cAliasNKR)->(dbGoTop())
	While ! (cAliasNKR)->( Eof() ) 
		
		// Ler todas classificações do romaneio 
		// Ler NJK com chave NJK_FILIAL+ NJK_CODROM
		
		dbSelectArea('NJK')
		dbSetOrder(1)
		NJK->( dbSeek( xFilial('NJK') + pcRomaneio ) )
		While ! NJK->( Eof() ) .And. NJK->( NJK_FILIAL + NJK_CODROM ) == xFilial('NJK') + pcRomaneio 
			
			If    NJK->NJK_CODDES  = (cAliasNKR)->NKR_CODDES;
			.And. NJK->NJK_PERDES >= (cAliasNKR)->NKR_PERINI;
			.And. NJK->NJK_PERDES <= (cAliasNKR)->NKR_PERFIM
			
				If ( pAliasNKQ )->NKQ_TIPCOB = '0' // 0=Valor 
					nTarifa := (cAliasNKR)->NKR_VALTAR
				Else
					nTarifa := (cAliasNKR)->NKR_PERRET
				EndIf
			Endif
			
			NJK->( DbSkip() )
		EndDo				
		(cAliasNKR)->( DbSkip() )
	EndDo //Fim laço NKR
	(cAliasNKR)->( dbCloseArea() ) 
	
Return ( nTarifa ) 

/*/{Protheus.doc} fDeletNKG
//Responsável por excluir cálculos anteriores referentes a mesma transferencia.
@author brunosilva
@since 25/06/2019
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function fDeletNKG(cCodTrf)
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
		
	dbSelectArea('NKG')
	dbSetOrder(7)
	if NKG->( dbSeek( FWxFilial('NKG') + cCodTrf ) )
		While NKG->(!Eof()) .AND. NKG->(NKG_FILIAL) == FWxFilial("NKG") .AND. NKG->(NKG_CODTRF) == cCodTrf
			If RecLock( "NKG", .f. )
				dbDelete()
				MsUnLock()
			else
				lRet := .F.
			EndIf
			NKG->( DbSkip() )
		EndDo
	endIf
		
	RestArea(aArea)	
Return lRet
 
/*/{Protheus.doc} OGA455STS(cCodTrf, cSeqTrf)
	tratamento do status da transferencia
	@type  Function
	@author mauricio.joao
	@since 07/11/2019
	@version 1.0

	//1 - pendente (nenhum rom gerado)
	//2 - rom gerado (rom gerados mas sem nota)
	//3 - notas geradas (rom e notas ok!)		
	//4 - serv transf (serviços geradaos)

	/*/
 Function OGA455STS(cCodTrf, cSeqTrf)

Return .T.