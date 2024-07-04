#INCLUDE 'TECA190.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190
	Executa a consulta aos atendentes e exibe a situa��o no dia.

@since		24/04/2014 
@version 	P12
     
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA190() 

Local oDlgConsulta	:= Nil							// Dialog Principal
Local aSize			:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oBrw			:= Nil							// Objeto do Browse
Local aList			:= {}							// Array com os dados a serem apresentados
Local oColumns		:= Nil
Local oFWLayer1     := Nil
Local oPanFiltro	:= Nil
Local oPanBrowse	:= Nil
Local oSayDtCons    := Nil
Local oGetDtCons    := Nil

Static dDiaCons     := dDatabase		// ser� a refer�ncia para os dias de consulta aos status dos atendentes

MsgRun(STR0010,STR0001,{ || aList := At190Query(dDiaCons) }) // 'Realizando pesquisa...' ### 'Consulta Atendentes'

//Cria a tela para o browse
DEFINE DIALOG oDlgConsulta TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3]-100,aSize[4]-100 PIXEL 		//"Consulta Atendentes"
	
	//------------------------------------------
	// Divide a tela e organiza os layers a serem apresentados
	oFWLayer1 := FWLayer():New()
	oFWLayer1:Init(oDlgConsulta,.F.,.T.)
	
	//oFWLayer1:AddLine("SUP",15,.F.)
	//oFWLayer1:AddLine("INF",85,.F.)

	oFWLayer1:AddLine("SUP",20,.F.)
	oFWLayer1:AddLine("INF",80,.F.)
	
	oFWLayer1:AddColumn("FIL",100,.T.,"SUP")
	oFWLayer1:AddColumn("BRW",100,.T.,"INF")
	
	oFWLayer1:AddWindow("FIL","oPanFiltro","",100,.F.,.T.,,"SUP",{|| })
	oPanFiltro := oFWLayer1:GetWinPanel("FIL","oPanFiltro","SUP")
	
	oFWLayer1:AddWindow("BRW","oPanBrowse","",100,.F.,.T.,,"INF",{|| })
	oPanBrowse := oFWLayer1:GetWinPanel("BRW","oPanBrowse","INF")
	
	//-----------------------------------------------------
	// Constr�i o browse para exibi��o dos dados
	DEFINE FWFORMBROWSE oBrw DATA ARRAY ARRAY aList LINE BEGIN 1 OF oPanBrowse
		
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][1] }") TITLE " "	SIZE 1 PICTURE "BMP" IMAGE OF oBrw
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][2] }") TITLE STR0011	SIZE 30 PICTURE "" OF oBrw // "Situa��o"
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][3] }") TITLE STR0002 	SIZE 10 	OF oBrw//"Data"
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][4] }") TITLE TxSX3Campo("AA1_CODTEC")[1] 	SIZE TamSX3("AA1_CODTEC")[1] 	OF oBrw
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][5] }") TITLE TxSX3Campo("RA_MAT")[1] 	SIZE TamSX3("RA_MAT")[1] 	OF oBrw
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][6] }") TITLE TxSX3Campo("AA1_NOMTEC")[1] 	SIZE TamSX3("AA1_NOMTEC")[1] 	OF oBrw
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][7] }") TITLE TxSX3Campo("AA1_FUNCAO")[1] 	SIZE TamSX3("AA1_FUNCAO")[1] 	OF oBrw
		ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][8] }") TITLE TxSX3Campo("RA_CARGO")[1] 	SIZE TamSX3("RA_CARGO")[1] 	OF oBrw
					
		//Adiciona o Bot�es de a��o
		ADD Button oBtLegend Title STR0012 Action "At190Leg()" OPERATION MODEL_OPERATION_VIEW   Of oBrw // "Legenda" 
		
	ACTIVATE FWFORMBROWSE oBrw
	
	//-----------------------------------------------------
	//  Adiciona o bot�o para reexecu��o do filtro e 
	// get para filtro do dia a ser consultado
	
	@ 005,005 BUTTON STR0003 SIZE 35,15 OF oPanFiltro PIXEL Action(At190Refresh(aList,oBrw,dDiaCons))//"Buscar"
	
	oSayDtCons := TSay():New( 009,050, { || 'Data: ' }, oPanFiltro,,,,,,.T.,,, 050, 15 )
	oGetDtCons := TGet():New( 005,070,{|u| If( PCount() > 0, dDiaCons := u, dDiaCons )},oPanFiltro,050,015,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'dDiaCons',,,, )
	
	@ 005,130 BUTTON STR0004 SIZE 35,15 OF oPanFiltro PIXEL Action( At190Fil( 2 ) )//"Equipe"
	@ 005,180 BUTTON STR0005 SIZE 35,15 OF oPanFiltro PIXEL Action( At190Fil( 1 ) )//"Atendente"
	
ACTIVATE DIALOG oDlgConsulta CENTERED

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190Refresh
	Atualiza os parametros e atualiza o Browse
@since		24/04/2014 
@version 	P12

@param		aList, Array, array com a refer�ncia aos dados que est�o no browse e que sofrer� a atualiza��o
@param		oBrw, Objeto, inst�ncia da classe FwFormBrowse no formato de exibi��o dos dados por array
@param		dDtFil, Data, data que ser� utilizada para filtro das informa��es pela query 

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190Refresh(aList,oBrw, dDtFil)

MsgRun(STR0010,STR0001,{ || aList := At190Query(dDtFil) }) // 'Realizando pesquisa...' ### 'Consulta Atendentes'
		
oBrw:SetArray(aList)

oBrw:Refresh(.T.)
	
Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190Leg
	Legenda da Lista de disponibilidade
@since		24/04/2014 
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190Leg()
Local oLegenda  :=  FWLegend():New() 	// Objeto FwLegend.
                                                  	
oLegenda:Add("","BR_PRETO"		, STR0013) // "F�rias Processada"
oLegenda:Add("","BR_BRANCO"		, STR0014) // "F�rias Programada"
oLegenda:Add("","BR_LARANJA"	, STR0006) //"Afastado"
oLegenda:Add("","BR_AZUL"		, STR0015) // "Folga"
oLegenda:Add("","BR_AMARELO"	, STR0016) // "Folga com Agenda"
oLegenda:Add("","BR_VERDE"		, STR0008) // "Dia de Trabalho com Agenda"
oLegenda:Add("","BR_VERMELHO"	, STR0009) // "Dia de Trabalho sem Agenda"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190Fil
	Define os bot�es para chamada dos filtros
@sample 	At190Fil( nParam )
@since		25/04/2014 
@version 	P12

@param	 	nParam, Numerico, indica qual lista de informa��es ser� passado para exibi��o do filtro
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190Fil( nParam )

Local aParam := { { 'AA1'   , '001', 'Atendente' , 1,'AA1_FILIAL+AA1_CODTEC', 'AA1', { {'AA1', 1, 'AA1_NOMTEC'} }, {}, {||.F.}, '', /*VldExtra*/ },;
				  { 'AAX'   , '001', 'Equipes', 1,'AAX_FILIAL+AAX_CODEQU', 'AAX', { {'AAX', 1, 'AAX_NOME+AAX_TPGRUP'} }, {}, {||.F.}, '', /*VldExtra*/ }, ;
				}

// Adiciona a valida��o extra para os valores digitados/selecionados pelo usu�rio
aParam[2,11] := "At201BHas(Posicione('AAX',1,xValueNew,'AAX_CODEQU'),,'"+__cUserId+"')"

TECA670( aParam[nParam], .F. /*lUsaCombobox*/ )

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190Query
	Fun��o que executa a query e seleciona os dados a serem exibidos no browse 

@sample 	At190Query() 
@since		24/04/2014 
@version 	P12

@param		dDtFiltro, Data, data de refer�ncia para apura��o das situa��es dos atendentes.
@return 	aList, Array, retorna a lista de atendentes e suas situa��es para o dia da consulta

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At190Query( dDtFiltro )
Local aRet		:= {}
Local cAliasTmp	:= GetNextAlias()
Local cDtUse    := ''
Local cCondAtd  := At670FilSql( __cUserId, .F., 'AA1', '001' )  // Atendente
Local cCondEqp  := At670FilSql( __cUserId, .F.,    'AAX', '001' )  // Equipe
Local cExpWhere := ''
Local lSRAOk    := .T.
Local cSituacao := ''
Local cCorLeg   := ''
Local lDiaTrab  := .F.
Local nPosData  := 0
Local nPosTec   := 0

DEFAULT dDtFiltro := dDataBase

If Select("cAlias") > 0 
	(cAliasTmp)->(DbCloseArea())
Endif

cDtUse := DTOS(dDtFiltro)

//------------------------------------------------------------
//  Constr�i as restri��es para filtro dos atendentes
// considerando a parametriza��o no rotina de filtro
If !Empty(cCondAtd) .Or. !Empty(cCondEqp)
	
	If !Empty(cCondAtd) .And. !Empty(cCondEqp)
		cExpWhere := "%"+cCondAtd+cCondEqp+"%"
	ElseIf !Empty(cCondAtd)
		cExpWhere := "%"+cCondAtd+"%"
	Else
		cExpWhere := "%"+cCondEqp+"%"
	EndIf
	
Else
	cExpWhere := "%"+"%"
EndIf

BeginSql Alias cAliasTmp
	
	COLUMN RF_DATAINI AS DATE
	COLUMN RF_DATINI2 AS DATE
	COLUMN RF_DATINI3 AS DATE
	COLUMN RH_DATABAS AS DATE
	COLUMN RH_DBASEAT AS DATE
	COLUMN R8_DATAINI AS DATE
	COLUMN R8_DATAFIM AS DATE
	
	SELECT DISTINCT
		AA1.AA1_CODTEC
		, AA1.AA1_NOMTEC
		, AA1.R_E_C_N_O_ AA1_RECNO
		, AA1.AA1_FUNCAO
		, COALESCE( SRA.RA_MAT		, ' ' ) RA_MAT
		, COALESCE( SRA.RA_CODFUNC	, ' ' ) RA_CODFUNC
		, COALESCE( SRA.RA_CARGO	, ' ' ) RA_CARGO
		, COALESCE( SRA.R_E_C_N_O_	, 0 ) RA_RECNO
		, COALESCE( SRF.RF_MAT		, ' ' ) RF_MAT
		, COALESCE( SRF.RF_DATAINI	, ' ' ) RF_DATAINI
		, COALESCE( SRF.RF_DFEPRO1	, 0 ) RF_DFEPRO1
		, COALESCE( SRF.RF_DATINI2	, ' ' ) RF_DATINI2
		, COALESCE( SRF.RF_DFEPRO2	, 0 ) RF_DFEPRO2
		, COALESCE( SRF.RF_DATINI3	, ' ' ) RF_DATINI3
		, COALESCE( SRF.RF_DFEPRO3	, 0 ) RF_DFEPRO3
		, COALESCE( SRH.RH_MAT		, ' ' ) RH_MAT
		, COALESCE( SRH.RH_DATABAS	, ' ' ) RH_DATABAS
		, COALESCE( SRH.RH_DBASEAT	, ' ' ) RH_DBASEAT
		, COALESCE( SR8.R8_MAT		, ' ' ) R8_MAT
		, COALESCE( SR8.R8_DATAINI	, ' ' ) R8_DATAINI
		, COALESCE( SR8.R8_DATAFIM	, ' ' ) R8_DATAFIM
		, COALESCE( ABB.ABB_CODTEC	, ' ' ) ABB_CODTEC
	FROM %Table:AA1% AA1 
		LEFT JOIN %Table:SRA% SRA ON SRA.RA_FILIAL=AA1.AA1_FUNFIL AND SRA.RA_MAT=AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_=' '
		
		LEFT JOIN %Table:SRH% SRH ON SRH.RH_FILIAL=%xFilial:SRH% AND SRH.RH_MAT=SRA.RA_MAT AND SRH.D_E_L_E_T_ = ' ' 
			AND %Exp:cDtUse% BETWEEN SRH.RH_DATABAS AND SRH.RH_DBASEAT
		
		LEFT JOIN %Table:SRF% SRF ON SRF.RF_FILIAL=%xFilial:SRF% AND SRF.RF_MAT=SRA.RA_MAT AND SRF.D_E_L_E_T_ = ' '
		
		LEFT JOIN %Table:SR8% SR8 ON SR8.R8_FILIAL=%xFilial:SR8% AND SR8.R8_MAT=SRA.RA_MAT AND SR8.D_E_L_E_T_ = ' ' 
			AND %Exp:cDtUse% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM

		LEFT JOIN %Table:ABB% ABB ON ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_CODTEC=AA1.AA1_CODTEC AND ABB.ABB_ATIVO='1' 
			AND ABB.D_E_L_E_T_=' ' AND ABB.ABB_DTINI = %Exp:cDtUse%
		
		LEFT JOIN %Table:AAY% AAY ON AAY.AAY_FILIAL=%xFilial:AAY% AND AAY.AAY_CODTEC=AA1.AA1_CODTEC AND AAY.%NotDel%
		
		LEFT JOIN %Table:AAX% AAX ON AAX.AAX_FILIAL=%xFilial:AAX% AND AAX.AAX_CODEQU=AAY.AAY_CODEQU AND AAX.%NotDel%
		
	WHERE
		AA1.AA1_FILIAL=%xFilial:AA1% AND AA1.%NotDel% %Exp:cExpWhere% 
	ORDER BY AA1_CODTEC
		
EndSql

DbSelectArea('AA1')
AA1->(DbSetOrder(1)) //RA_FILIAL+RA_MAT

DbSelectArea('SRA')
SRA->(DbSetOrder(1)) //RA_FILIAL+RA_MAT

//----------------------------------------------------------
//  Avalia o retorno da consulta para adicionar ao array de retorno
// e atribuir a situa��o de cada atendente
While (cAliasTmp)->(!EOF())
	
	cSituacao := '' // caso n�o identifique o status
	cCorLeg   := ''
	
	//----------------------------------------------
	//  Posiciona nos registros relacionados ao atendente
	// quando existir v�nculo com funcion�rio, ttbm realiza o posicionamento na SRA
	AA1->(DbGoTo((cAliasTmp)->AA1_RECNO))
	
	If ( lSRAOk := !Empty((cAliasTmp)->RA_MAT) )
		SRA->(DbGoTo((cAliasTmp)->RA_RECNO))
	EndIf
	
	//---------------------------------------------
	//  Verifica se � um dia trabalhado
	lDiaTrab := ( lSRAOk .And. TxDiaTrab(dDtFiltro, SRA->RA_TNOTRAB, SRA->RA_SEQTURN, SRA->RA_MAT, SRA->RA_CC) ) .Or. ;
				(!lSRAOk .And. TxDiaTrab(dDtFiltro, AA1->AA1_TURNO, '01') )
	
	If !Empty((cAliasTmp)->RH_MAT) .And. ;  // Exista informa��o na SRH: F�rias processadas
		!Empty((cAliasTmp)->RH_DATABAS) .And. !Empty((cAliasTmp)->RH_DBASEAT) .And. ;  // os campos estejam preenchidos
		( dDtFiltro >= (cAliasTmp)->RH_DATABAS .And. dDtFiltro <= (cAliasTmp)->RH_DBASEAT ) // esteja entre a data inicial e final das f�rias
		
		cSituacao := STR0013 // "F�rias Processada"
		cCorLeg   := "BR_PRETO"
	
	ElseIf !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informa��o na SRF
		( !Empty((cAliasTmp)->RF_DATAINI) .Or. !Empty((cAliasTmp)->RF_DATINI2) .Or. !Empty((cAliasTmp)->RF_DATINI3) ) .And.;  // alguma das datas esteja preenchida
		( ( dDtFiltro >= (cAliasTmp)->RF_DATAINI .And. dDtFiltro <= ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) ) .Or. ;
		( dDtFiltro >= (cAliasTmp)->RF_DATINI2 .And. dDtFiltro <= ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) ) .Or. ;
		( dDtFiltro >= (cAliasTmp)->RF_DATINI3 .And. dDtFiltro <= ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) ) )  
		// verifica para cada per�odo/sa�da da programa��o se a data est� entre o per�odo
		
		cSituacao := STR0014 // "F�rias Programada"
		cCorLeg   := "BR_BRANCO"
	
	ElseIf !Empty((cAliasTmp)->R8_MAT) .And. ;  // Exista informa��o na SR8
		!Empty((cAliasTmp)->R8_DATAINI) .And. !Empty((cAliasTmp)->R8_DATAFIM) .And. ; // per�odo de afastamento preenchido
		dDtFiltro >= (cAliasTmp)->R8_DATAINI .And. dDtFiltro <= (cAliasTmp)->R8_DATAFIM
		
		cSituacao := STR0007//"Afastamento"
		cCorLeg   := "BR_LARANJA"
		
	ElseIf !lDiaTrab  // n�o � dia trabalhado?
		cSituacao := STR0015 // "Folga"
		cCorLeg   := "BR_AZUL"
		
		If !Empty((cAliasTmp)->ABB_CODTEC)  // tem agenda ativa para a data?
			cSituacao := STR0016 // "Folga com Agenda"
			cCorLeg   := "BR_AMARELO"
		EndIf
	
	ElseIf lDiaTrab
		If !Empty((cAliasTmp)->ABB_CODTEC)
			cSituacao := STR0008//"Dia de Trabalho com Agenda"
			cCorLeg   := "BR_VERDE"
		Else
			cSituacao := STR0009//"Dia de Trabalho sem Agenda"
			cCorLeg   := "BR_VERMELHO"
		EndIf
	
	EndIf
	
	//-----------------------------------------
	//  Aten��o ao alterar a ordem dos campos
	// para n�o gerar erro na ordena��o do array
	// DIA + C�DIGO ATENDENTE
	nPosData := 3
	nPosTec := 4
	
	aAdd( aRet, { cCorLeg,;  // Legenda
					cSituacao,;  // Situa��o
					dDtFiltro,;  // dia da consulta
					(cAliasTmp)->AA1_CODTEC	,; // C�digo T�cnico
					(cAliasTmp)->RA_MAT		,; // Matr�cula
					(cAliasTmp)->AA1_NOMTEC	,; // Nome T�cnico
					IIF(!Empty((cAliasTmp)->RA_CODFUNC),(cAliasTmp)->RA_CODFUNC,(cAliasTmp)->AA1_FUNCAO)	,; // Fun��o
					(cAliasTmp)->RA_CARGO	; // Cargo
				} )
	
	(cAliasTmp)->(DbSkip())
End

(cAliasTmp)->(DbCloseArea())

//Ordena o array Data+C�digo T�cnico
aSort(aRet,,, {|x,y| DTOS(x[nPosData])+x[nPosTec] < DTOS(y[nPosData])+y[nPosTec]})

Return(aRet)
