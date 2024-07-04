#INCLUDE "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TECA570.CH"

#DEFINE MODEL  1
#DEFINE VIEW   2

#DEFINE MANUT_TIPO_CANCEL  '05'	//Tipo Cancelamento

#DEFINE PERMISSAO_CLIENTE       1
#DEFINE PERMISSAO_CONTRATO      2
#DEFINE PERMISSAO_BASEATEND     3
#DEFINE PERMISSAO_CONTRATOSERV  4
#DEFINE PERMISSAO_EQUIPE        5

Static cAliasTmp := ""//Alias Temporario dos dados de conflito
Static aPerm := NIL //Controle de permissões. Esta variavel deverá ser recuperada através do método at570getPe()

/*
{Protheus.doc} TECA570

Apresenta conflitos de alocação relacionados a demissão, férias ou afastamentos no RH. 

@param aParam 	Array 		Array com informações para realização do filtro, caso não seja passado será apresentado pergunte para realização do filtro
								[1]Data Inicial de Alocação
								[2]Data Final de alocação
								[3]Atendente De
								[4]Atendente Ate
@param lPrevisao	Boolean 	Caso Verdadeiro será apresentada a previsão dos conflitos conforme datas do parametro, caso falso será apresentado conflitos existentes na alocação.
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return Nil
@menu    
*/
Function TECA570(aParam, lPrevisao)

Local oDialog := Nil

Local aSize	:= FWGetDialogSize( oMainWnd )
Local cPerg := "TEC570"
Local lExibe := .T.
Local dAlocDe := STOD("")
Local dAlocAte := STOD("")
Local cAtendDe := ""
Local cAtendAte := ""
Local cPermissao := ""
Local cCompart  := Posicione("SX2",1,"AA1","X2_MODO")
Local lMultFil	:= SuperGetMV("MV_GSMSFIL",,.F.)

Default lPrevisao := .F.
Private cCadastro := ""
Private oBrowse := Nil

If at570CPerm()//controla permissoes?
	cPermissao := AT570Perm()
	If Empty(cPermissao)
		Help( ' ', 1, 'TECA570', , STR0017, 1, 0 )	//"Usuário sem permissão de acesso para as informações de alocação!"
		lExibe := .F.
	EndIf	
EndIf

If lExibe
	If cCompart == "E" .And. lMultFil
		lExibe := .F.
		Help( "", 1, "TECA570", ,STR0039,1, 0,,,,,,{STR0040})
	Endif
Endif	

If lExibe 
	If (ValType(aParam)=="A" .AND. Len(aParam) > 0)
		dAlocDe   := aParam[1]
		dAlocAte  := aParam[2]
		cAtendDe  := aParam[3]
		cAtendAte := aParam[4]
	Else
		lExibe    := Pergunte(cPerg, .T.)
		dAlocDe   := MV_PAR01
		dAlocAte  := MV_PAR02
		cAtendDe  := MV_PAR03
		cAtendAte := MV_PAR04
	EndIf
EndIf

If lExibe
	cAliasTmp := GetNextAlias()

	oBrowse := FWMarkBrowse():New()

	oBrowse:SetDataQuery(.T.)

	If lPrevisao
		oBrowse:SetQuery( AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte ) )
	Else
		oBrowse:SetQuery( AT570Query(dAlocDe, dAlocAte, cAtendDe, cAtendAte) )
	EndIf
	oBrowse:SetAlias( cAliasTmp )
	oBrowse:SetFieldMark("BR_MARK")
	oBrowse:bAllMark := {||oBrowse:AllMark()}	
	oBrowse:AddStatusColumns( { || AT570Status( cAliasTmp ) }, { || AT570Legen() } )
	oBrowse:SetColumns( AT570Colum() )
	oBrowse:SetUseFilter( .T. )

	//filtros
	oBrowse:SetFilterDefault( "At570Filter()")

	oBrowse:AddButton( STR0007, { || AT570Legen()},,2,, .F., 2 )	//'Legenda'
	oBrowse:AddButton( STR0002, { || If((oBrowse:Alias())->(!EOF()), FWExecView(STR0003,'TECA570', MODEL_OPERATION_VIEW,, { || .T. } ),NIL) },,2,, .F., 2 )	//'Visualizar' - Conflito de Alocação
	If !IsInCallStack('AT570Detal')
		oBrowse:AddButton( STR0008, { || MsgRun ( STR0009, STR0008, {|| AT570Subst(oBrowse:Alias(), oBrowse)} ), MsgRun ( STR0011, STR0010, {|| AT570Refresh(oBrowse)} ) },,4,, .F., 2 )	//'Substituir' - Realizando Substituição
		oBrowse:AddButton( STR0013, { || If(Pergunte("TEC570"), MsgRun ( STR0011, STR0010, {|| AT570Refresh(oBrowse)} ),NIL) },,4,, .F., 2 )	//Opções - 'Atualizar' - Atualizando
	EndIf
	oBrowse:AddButton( STR0001, { ||oDialog:End() },,,, .F., 2 )	//'Sair'

	If (cAliasTmp)->(RecCount()) == 0
		Help( ' ', 1, 'TECA570', , STR0014, 1, 0 )	//"Não há registros para serem exibidos!"
	Else
		oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "", , , , , , , , /*oMainWnd*/, .T. )
		oBrowse:SetOwner( oDialog )
		oBrowse:Activate()
		oDialog:Activate()
	EndIf

EndIf

Return

// 
/*
{Protheus.doc} AT570Colum
     
Recupera informações das colunas que serão exibidas no browse
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return aColumns Array
*/
Static Function AT570Colum()
Local aCampos := AT570Field()
Local aColumns:= {}
Local nI 		:= 1
Local nJ 		:= 1
Local aArea	:= GetArea()
Local aAreaSX3:= SX3->(GetArea())

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO

For nI := 1 To Len(aCampos)
	If ( SX3->( MsSeek( aCampos[nI] ) ) )

		aAdd( aColumns, FWBrwColumn():New() )

		If ( SX3->X3_TIPO == "D"  )
			aColumns[nJ]:SetData( &("{||SToD(" + aCampos[nI] + ")}") )
		Else
			aColumns[nJ]:SetData( &("{||" + aCampos[nI] + "}") )
		EndIf

		aColumns[nJ]:SetTitle( X3Titulo() )
		aColumns[nJ]:SetSize( SX3->X3_TAMANHO )
		aColumns[nJ]:SetDecimal( SX3->X3_DECIMAL )
		aColumns[nJ]:SetPicture( SX3->X3_PICTURE )

		If aCampos[nI] == "RH_DATAINI"
			aColumns[nJ]:SetData( {|| At570IniF()} )
		ElseIf aCampos[nI] == "RH_DATAFIM"
			aColumns[nJ]:SetData( {|| At570FimF()} )
		EndIf

		nJ++
	EndIf
Next nI

RestArea(aAreaSX3)
RestArea(aArea)

Return aColumns

//
/*
{Protheus.doc} ModelDef

Definição do Model da rotina TECA570
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return oModel MPFormModel Modelo da rotina 
*/
Static Function ModelDef()
Local oModel:= MPFormModel():New('TECA570', /*bPreValidacao*/, /**/, {||.T.}, /*bCancel*/ )
Local oStru := AT570Struc(MODEL)

oModel:AddFields( 'MASTER', /*cOwner*/, oStru, /*bPreValidacao*/, /*bPosValidacao*/, {||} )

oModel:SetDescription( STR0003 )
oModel:GetModel( 'MASTER'):SetDescription( STR0003 )

oModel:SetActivate( {|oModel| AT570LoadM( oModel ) } )
oModel:setPrimaryKey({})

Return oModel

/*
{Protheus.doc} ViewDef

Definição da View

@param  
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return oView FWFormView
*/
Static Function ViewDef()
Local oView := Nil
Local oStruct := AT570Struc(VIEW)
Local oModel := FWLoadModel( 'TECA570' )
Local aCpos := AT570Field()
Local nI := 1

//Atribui propriedade somente visualização
For nI:=1 To Len(aCpos)
	oStruct:SetProperty( aCpos[nI] , MVC_VIEW_CANCHANGE, .F.)
Next nI


oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_TECA570', oStruct, 'MASTER' )//Add Controle

oView:CreateHorizontalBox( 'TELA' , 100 )// Criar um "box" horizontal para receber algum elemento da view

oView:SetOwnerView( 'VIEW_TECA570', 'TELA' )// Relaciona o ID da View com o "box" para exibicao

Return oView


/*Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TECA570' OPERATION 3 ACCESS 0
Return aRotina*/



/*
{Protheus.doc} AT570Field

Retorna campos que serão utilizados

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return aCampos Array array com campos utilizados 
*/
Static Function AT570Field()
Local aCampos := {}
Local lResRHTXB	:= TableInDic("TXB")

aAdd(aCampos, "AA1_CODTEC")//Codigo do Atendente
aAdd(aCampos, "AA1_NOMTEC")//Nome do Atendnete
aAdd(aCampos, "ABB_DTINI")//Data Alocação Inicial
aAdd(aCampos, "ABB_HRINI")//Hora Alocação Inicial
aAdd(aCampos, "ABB_DTFIM")//Data Alocação Inicial
aAdd(aCampos, "ABB_HRFIM")//Hora Alocação Final
aAdd(aCampos, "RA_SITFOLH")//Situação no GPE
aAdd(aCampos, "RH_DATAINI")//Data Inicial Programação Férias
aAdd(aCampos, "RH_DATAFIM")//Data Final Programação Férias
aAdd(aCampos, "R8_DATAINI")//Data Inicial Afastamento
aAdd(aCampos, "R8_DATAFIM")//Data Final Afastamento
aAdd(aCampos, "RA_DEMISSA")//Data de Demissão

IF IsInCallStack("At190dCons")
    aAdd(aCampos, "TDV_DTREF")//Data de Referencia
Endif

If lResRHTXB
	aAdd(aCampos, "TXB_DTINI")//Data inicial
	aAdd(aCampos, "TXB_DTFIM")//Data final
Endif

Return aCampos


//Retorna Estrutura para o Model
/*
{Protheus.doc} AT570Struc

Recupera estrutura de Model ou de View da rotina TECA570

@param  nType Integer - 1(MODEL), 2(VIEW)
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return oStruct - FWFormModelStruct ||  FWFormViewStruct
*/
Static Function AT570Struc(nType)
Local oStruct := Nil
Local aCampos := AT570Field()
Local nI := 1
Local aArea	:= GetArea()
Local aAreaSX3:= SX3->(GetArea())
Local bBlockIni := Nil

If nType == MODEL
	oStruct := FWFormModelStruct():New()
Else
	oStruct := FWFormViewStruct():New()
EndIf

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO

For	nI:=1 To Len(aCampos)

	If ( SX3->( MsSeek( aCampos[nI] ) ) )

		If nType == MODEL//Estrutura para Model

			If aCampos[nI] == "RH_DATAINI"
				bBlockIni := {|| At570IniF()}
			ElseIf aCampos[nI] == "RH_DATAFIM"
				bBlockIni := {|| At570FimF()}
			Else
				bBlockIni := Nil
			EndIf

			oStruct:AddField( ;
				X3Titulo()  		, ;             // [01] Titulo do campo
				X3Descric()	, ;             // [02] ToolTip do campo
				AllTrim(aCampos[nI])     	, ;             // [03] Id do Field
				SX3->X3_TIPO		, ;            	// [04] Tipo do campo
				SX3->X3_TAMANHO	, ;             // [05] Tamanho do campo
				SX3->X3_DECIMAL 	, ;               // [06] Decimal do campo
				/*NIL*/            , ;               // [07] Code-block de validação do campo
				/*{||.F.}*/   		, ;               // [08] Code-block de validação When do campo
				/*NIL*/ 			, ;         	  // [09] Lista de valores permitido do campo
				/*.F.*/     		, ;               // [10] Indica se o campo tem preenchimento obrigatório
				bBlockIni          , ;               // [11] Code-block de inicializacao do campo
				/*.F.*/            , ;               // [12] Indica se trata-se de um campo chave
				.T.					, ;               // [13] Indica se o campo pode receber valor em uma operação de update.
				.T.     )              				  // [14] Indica se o campo é virtual
		Else// Estrutura para View			
		    oStruct:AddField( ;
			    aCampos[nI]   			, ;             // [01] Campo
			    cValToChar(nI)        , ;             	// [02] Ordem
			    X3Titulo()	        	, ;             	// [03] Titulo
			    X3Descric()           , ;             	// [04] Descricao
			    /*{}*/                 , ;             	// [05] Help
			    'GET'					, ;             	// [06] Tipo do campo   COMBO, Get ou CHECK
			    IIF(aCampos[nI] == 'AA1_CODTEC', "@!", SX3->X3_PICTURE)		, ;             	// [07] Picture
			    /*''*/                 	, ;             	// [08] PictVar
			    /*NIL*/            	, ;            		// [09] F3
			    .T.						, ;             	// [10] Editavel
			    '01'                 	, ;        			// [11] Folder
			    /*''*/           		, ;            		// [12] Group
			    /*{}*/                 	, ;            		// [13] Lista Combo
			    /*10*/                 	, ;            		// [14] Tam Max CombO
			    /*''*/               	, ;            		// [15] Inic. Browse
			    .T.  )               						// [16] Virtual		  
		EndIf
	EndIf
Next nI

RestArea(aAreaSX3)
RestArea(aArea)

Return oStruct


/*
{Protheus.doc} AT570Query

Recupera query para listagem dos cnflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param cPermissao String COndição para filtro devido a permissoes
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cQuery String Query para recuperação de conflitos com o RH 
*/
Static Function AT570Query(dAlocDe, dAlocAte, cAtendDe,  cAtendAte)

Local cQuery := ""
Local cPermissao := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
Local lResRHTXB	:= TableInDic("TXB")
Local lVerFr	:= SuperGetMV("MV_GSVERFR",,.T.)
Local cCondFr	:= '1 = 1'


cQuery := " SELECT DISTINCT "
If isInCallStack("TECA570")
	cQuery += " '' BR_MARK ,"
EndIf
cQuery += 		"ABB.ABB_FILIAL,"
cQuery += 	    "Isnull(AA1.AA1_CODTEC,'') AA1_CODTEC,"
cQuery += 		"Isnull(AA1.AA1_NOMTEC,'') AA1_NOMTEC,"
cQuery += 		"ABB.ABB_DTINI,"
cQuery += 		"ABB.ABB_HRINI,"
cQuery += 		"ABB.ABB_DTFIM,"
cQuery += 		"ABB.ABB_HRFIM,"
cQuery += 		"TDV.TDV_DTREF,"
cQuery += 		"COALESCE(SRA.RA_SITFOLH,' ') RA_SITFOLH,"
cQuery += 		"COALESCE(SRA.RA_ADMISSA,' ') RA_ADMISSA,"
cQuery += 		"COALESCE(SRA.RA_DEMISSA,' ') RA_DEMISSA,"
cQuery += 		"COALESCE(SRF.RF_DATAINI,' ') RF_DATAINI,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO1, 0 ) RF_DFEPRO1,"
cQuery += 		"COALESCE(SRF.RF_DATINI2,' ') RF_DATINI2,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO2, 0 ) RF_DFEPRO2,"
cQuery += 		"COALESCE(SRF.RF_DATINI3,' ') RF_DATINI3,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO3, 0 ) RF_DFEPRO3,"
cQuery += 		"COALESCE(SR8.R8_DATAINI,' ') R8_DATAINI,"
cQuery += 		"COALESCE(SR8.R8_DATAFIM,' ') R8_DATAFIM "

If lResRHTXB
	cQuery += ",COALESCE(TXB.TXB_DTINI,' ') TXB_DTINI, "
	cQuery += "COALESCE(TXB.TXB_DTFIM,' ') TXB_DTFIM "
Endif

cQuery += 		", ABB.ABB_CODIGO "
cQuery += 		"FROM "+RetSqlName("ABB")+" ABB"

cQuery += " INNER JOIN "+RetSqlName("TDV")+" TDV "
cQuery += 		" ON TDV.TDV_FILIAL = '" + xFilial("TDV") + "'"
cQuery += 		" AND TDV.TDV_CODABB = ABB.ABB_CODIGO"
cQuery += 		" AND TDV.D_E_L_E_T_ = ' ' "
cQuery += 		" AND ("
cQuery += 		" TDV.TDV_DTREF BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"' "
cQuery += 		")"

cQuery += " LEFT JOIN "+RetSqlName("AA1")+" AA1"
cQuery += 		" ON AA1.AA1_FILIAL = '"+xFilial("AA1")+"'"
cQuery += 		" AND AA1.AA1_CODTEC = ABB.ABB_CODTEC"
cQuery += 		" AND AA1.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RetSqlName("SRA")+" SRA"
cQuery += 		" ON SRA.RA_FILIAL = AA1.AA1_FUNFIL"
cQuery += 		" AND SRA.RA_MAT = AA1.AA1_CDFUNC"
cQuery += 		" AND SRA.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RetSqlName("SR8")+" SR8"
cQuery += 		" ON SR8.R8_FILIAL = SRA.RA_FILIAL"
cQuery += 		" AND SR8.R8_MAT = SRA.RA_MAT"
cQuery += 		" AND ("
cQuery += 			"(TDV.TDV_DTREF >= SR8.R8_DATAINI AND TDV.TDV_DTREF <= SR8.R8_DATAFIM) OR 
cQuery += 			"(TDV.TDV_DTREF >= SR8.R8_DATAINI AND SR8.R8_DATAFIM ='') OR "
cQuery += 			"(TDV.TDV_DTREF <= SR8.R8_DATAINI AND (TDV.TDV_DTREF >= SR8.R8_DATAFIM AND SR8.R8_DATAFIM <> ''))"
cQuery += 			" )"
cQuery += 		" AND SR8.D_E_L_E_T_ = ' '"

If !lVerFr // Realizado condição (2 = 1) caso MV_GSVERFR := .F.
	cCondFr := '2 = 1'
EndIf

cQuery += " LEFT JOIN "+RetSqlName("SRF")+" SRF"
cQuery += 		" ON SRF.RF_FILIAL = SRA.RA_FILIAL"
cQuery += 		" AND SRF.RF_MAT = SRA.RA_MAT	"
cQuery +=		" AND "+cCondFr+" 
cQuery += 		" AND SRF.D_E_L_E_T_ = ' '"
cQuery += 		" AND "

If Trim(Upper(TcGetDb())) $ "ORACLE,DB2,INFORMIX"
		
	cQuery += "("
	cQuery += 		"("
	cQuery += 			" SRF.RF_DATAINI <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATAINI AND TO_CHAR(TO_DATE(RF_DATAINI, 'YYYYMMDD') + RF_DFEPRO1-1)) "
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI2 <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATINI2 AND TO_CHAR(TO_DATE(RF_DATINI2, 'YYYYMMDD') + RF_DFEPRO2-1)) "
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI3 <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATINI3 AND TO_CHAR(TO_DATE(RF_DATINI3, 'YYYYMMDD') + RF_DFEPRO3-1)) "
	cQuery += 		")"
	cQuery += ")"

ElseIf Trim(Upper(TcGetDb())) $ "POSTGRES"	
	cQuery += "("
	cQuery += 		"("
	cQuery += 			" SRF.RF_DATAINI <> '' AND CAST(TDV.TDV_DTREF AS DATE) BETWEEN CAST(TDV.TDV_DTREF AS DATE) and (CAST(SRF.RF_DATAINI AS DATE) + INTERVAL '1' DAY * (SRF.RF_DFEPRO1-1))"
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI2 <> '' AND CAST(TDV.TDV_DTREF AS DATE) BETWEEN CAST(TDV.TDV_DTREF AS DATE) and (CAST(SRF.RF_DATINI2 AS DATE) + INTERVAL '1' DAY * (SRF.RF_DFEPRO2-1)) "
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI3 <> '' AND CAST(TDV.TDV_DTREF AS DATE) BETWEEN CAST(TDV.TDV_DTREF AS DATE) and (CAST(SRF.RF_DATINI3 AS DATE) + INTERVAL '1' DAY * (SRF.RF_DFEPRO3-1)) "
	cQuery += 		")"
	cQuery += ")"


Else
	cQuery += "("
	cQuery += 		"("
	cQuery += 			" SRF.RF_DATAINI <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATAINI AND DATEADD(day, RF_DFEPRO1-1, RF_DATAINI) ) "
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI2 <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATINI2 AND DATEADD(day, RF_DFEPRO2-1, RF_DATINI2) ) "
	cQuery += 		") OR ("
	cQuery += 			" SRF.RF_DATINI3 <> '' AND (TDV.TDV_DTREF BETWEEN SRF.RF_DATINI3 AND DATEADD(day, RF_DFEPRO3-1, RF_DATINI3) ) "
	cQuery += 		")"
	cQuery += ")"
EndIf

If lResRHTXB
	cQuery += " LEFT JOIN " + RetSqlName("TXB") + " TXB ON AA1.AA1_FILIAL = '"+xFilial('AA1')+"' "
	cQuery += " AND TXB.TXB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ((TDV.TDV_DTREF >= TXB.TXB_DTINI AND TDV.TDV_DTREF <= TXB.TXB_DTFIM ) OR"
	cQuery += "(TDV.TDV_DTREF >= TXB.TXB_DTINI AND TDV.TDV_DTREF <= TXB.TXB_DTFIM ) OR"
	cQuery += "(TDV.TDV_DTREF >= TXB.TXB_DTINI AND TXB.TXB_DTFIM  ='') OR"
	cQuery += "(TDV.TDV_DTREF <= TXB.TXB_DTINI AND (TDV.TDV_DTREF >= TXB.TXB_DTFIM AND TXB.TXB_DTFIM <> '')))"
	cQuery += " AND TXB.D_E_L_E_T_ = ' ' "
Endif

cQuery += " WHERE "
cQuery += 		" ABB.ABB_FILIAL = '"+xFilial("ABB")+"'"
cQuery += 		" AND ABB.ABB_CODTEC BETWEEN '"+cAtendDe+"' AND '"+cAtendAte+"'"
cQuery += 		" AND ABB.ABB_ATIVO ='1'"
cQuery += 		" AND ABB.ABB_ATENDE ='2'"

cQuery += 		" AND ABB.D_E_L_E_T_ = ' '"
cQuery += 		" AND ("
cQuery += 			" (SRA.RA_ADMISSA <> '' AND SRA.RA_ADMISSA > TDV.TDV_DTREF) OR"
cQuery += 			" (SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= TDV.TDV_DTREF)"

If lUsaEAIGS
	cQuery += 		" OR SRA.RA_SITFOLH = 'A'"
Else
	cQuery += 		" OR SR8.R8_DATAINI <> '"+Space(8)+"'"
EndIf

cQuery += 			" OR SRF.RF_DATAINI <> '"+Space(8)+"'"
cQuery += 			" OR SRF.RF_DATINI2 <> '"+Space(8)+"'"
cQuery += 			" OR SRF.RF_DATINI3 <> '"+Space(8)+"'"

If lResRHTXB
	cQuery += " OR TXB.TXB_DTINI <> '"+Space(8)+"'"
EndIf

cQuery += 		"OR EXISTS(SELECT 1 FROM "+RetSqlName("ABB")+" ABB2 WHERE ABB2.ABB_FILIAL = '"+xFilial("ABB")+"'" 
cQuery += 			"AND ABB.ABB_CODTEC = ABB2.ABB_CODTEC "
cQuery += 			"AND ABB.ABB_CODIGO <> ABB2.ABB_CODIGO "
cQuery += 			"AND ABB2.ABB_ATIVO ='1'"
cQuery += 			"AND ABB2.ABB_ATENDE ='2'"
cQuery += 			"AND ABB2.D_E_L_E_T_ = ' '"
cQuery +=  			"AND TDV.TDV_DTREF BETWEEN ABB2.ABB_DTINI AND ABB2.ABB_DTFIM "
cQuery +=  			"AND (ABB.ABB_HRINI BETWEEN ABB2.ABB_HRINI AND ABB2.ABB_HRFIM "
cQuery +=  			"OR ABB.ABB_HRFIM BETWEEN ABB2.ABB_HRINI AND ABB2.ABB_HRFIM ) )"
cQuery +=  		")"

If At570CPerm()//controla permissoes?
	cPermissao := AT570Perm()
	If !Empty(cPermissao)
		cQuery += cPermissao
	EndIf
EndIf

cQuery += " ORDER BY AA1_CODTEC, AA1_NOMTEC, ABB_DTINI, ABB_HRINI, ABB_DTFIM"



Return ChangeQuery(cQuery)

/*
{Protheus.doc} AT570QryPC
Encapsula a função AT570QryPrev que retorna uma string em forma de query de previsão de conflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param aLstAte	Array Contendo uma Lista simples com os códigos dos atendentes que se deseja consultar.

@version V12
@since   21/05/2015 
@return cQuery String Query para recuperação de conflitos com o RH em uma determinada data
*/
Function AT570QryPC(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB, cNotIdcFal, lCheckRT)
Local cRet := ""
cRet := AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB, cNotIdcFal, lCheckRT)
Return cRet


/*
{Protheus.doc} AT570QryPrev

Recupera query para previsão de conflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param aLstAte	Array Contendo uma Lista simples com os códigos dos atendentes que se deseja consultar.
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cQuery String Query para recuperação de conflitos com o RH em uma determinada data
*/
Static Function AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB, cNotIdcFal, lCheckRT )

Local cQuery := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
Local nI := 0
Local nX
Local cLstAte   := ""
Local aSM0 		:= FWArrFilAtu()
Local aFilPesq	:= {}
Local cCompE	:= FWModeAccess("ABB",1)
Local cCompU	:= FWModeAccess("ABB",2)
Local cCompF	:= FWModeAccess("ABB",3)
Local cFilPesq	:= ""
Local lResRHTXB	:= TableInDic("TXB")
Local lTecr020  := IsInCallStack("TECR020")
Local lVerFr	:= SuperGetMV("MV_GSVERFR",,.T.)
Local cCondFr	:= '1 = 1'

Default aLstAte  := {}	//{cCdAte1,cCdAte2,..,cCdAten} - Entre cada par de aspas simples deve constar um código de atendente
Default lJoinABB := .F.
Default cNotIdcFal := ""
Default lCheckRT := .F.

cQuery := "SELECT DISTINCT"
If isInCallStack("TECA570")
	cQuery += " '' BR_MARK ,"
EndIf
cQuery += " AA1.AA1_FILIAL, "
cQuery += " AA1.AA1_CODTEC, "
cQuery += " AA1.AA1_NOMTEC,  "
cQuery += " '"+DTOS(dAlocDe)+"' AS ABB_DTINI, "
cQuery += " '  :  ' AS ABB_HRINI, "
cQuery += " '"+DTOS(dAlocAte)+"' AS ABB_DTFIM, "
cQuery += " '  :  ' AS ABB_HRFIM,  "
IF IsInCallStack("At190dCons")
    cQuery += " TDV.TDV_DTREF, "
Endif
cQuery += " COALESCE(SRA.RA_SITFOLH,' ') RA_SITFOLH, "
cQuery += " COALESCE(SRA.RA_ADMISSA,' ') RA_ADMISSA, "
cQuery += " COALESCE(SRA.RA_DEMISSA,' ') RA_DEMISSA, "
cQuery += " COALESCE(SRF.RF_DATAINI,' ') RF_DATAINI,"
cQuery += " COALESCE(SRF.RF_DFEPRO1, 0 ) RF_DFEPRO1,"
cQuery += " COALESCE(SRF.RF_DATINI2,' ') RF_DATINI2,"
cQuery += " COALESCE(SRF.RF_DFEPRO2, 0 ) RF_DFEPRO2,"
cQuery += " COALESCE(SRF.RF_DATINI3,' ') RF_DATINI3,"
cQuery += " COALESCE(SRF.RF_DFEPRO3, 0 ) RF_DFEPRO3,"
cQuery += " COALESCE(SR8.R8_DATAINI,' ') R8_DATAINI,"
cQuery += " COALESCE(SR8.R8_DATAFIM,' ') R8_DATAFIM "


If (lJoinABB .And. !lTecr020) .OR. IsInCallStack("At190dCons")
	cQuery += " , CASE WHEN ABB.ABB_DTINI IS NOT NULL THEN  ABB.ABB_DTINI ELSE ' ' END  AS DTINI  " 
	cQuery += " , CASE WHEN ABB.ABB_DTFIM IS NOT NULL THEN  ABB.ABB_DTFIM ELSE ' ' END  AS DTFIM  " 
	cQuery += " , CASE WHEN ABB.ABB_HRINI IS NOT NULL THEN  ABB.ABB_HRINI ELSE ' ' END  AS HRINI  " 
	cQuery += " , CASE WHEN ABB.ABB_HRFIM IS NOT NULL THEN  ABB.ABB_HRFIM ELSE ' ' END  AS HRFIM  " 
	cQuery += " , CASE WHEN ABB.ABB_ATIVO IS NOT NULL THEN  ABB.ABB_ATIVO ELSE ' ' END  AS ATIVO  " 
	IF !IsInCallStack("At190dCons")
		cQuery += " , TDV.TDV_DTREF AS DTREF "
	EndIf
	If lCheckRT
		cQuery += " ,CASE WHEN TCU.TCU_COD IS NOT NULL THEN TCU.TCU_COD ELSE '' END TCU_COD "
		cQuery += " ,CASE WHEN TCU.TCU_RESTEC IS NOT NULL THEN TCU.TCU_RESTEC ELSE '' END TCU_RESTEC "
	EndIf
EndIf

If lTecr020
	cQuery += " ,'' AS DTINI, "
	cQuery += " '' AS DTFIM, "
	cQuery += " '' AS HRINI, "
	cQuery += " '' AS HRFIM, "
	cQuery += " '' AS ATIVO, "
	cQuery += " '' AS DTREF "
Endif

If lResRHTXB
	cQuery += " , COALESCE(TXB.TXB_DTINI,' ')  TXB_DTINI, "
	cQuery += "   COALESCE(TXB.TXB_DTFIM,' ')  TXB_DTFIM "
Endif

cQuery += " FROM "+RetSqlName("AA1")+" AA1 "

cQuery += "	LEFT JOIN "+RetSqlName("SRA")+"  SRA "
cQuery += 		" ON SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' "

cQuery += "	LEFT JOIN  "+RetSqlName("SR8")+" SR8 "
cQuery += 		"ON SR8.R8_FILIAL = SRA.RA_FILIAL 	AND SR8.R8_MAT = SRA.RA_MAT "
cQuery += 			" AND ( "
cQuery += 			"('"+DTOS(dAlocDe )+"' >= SR8.R8_DATAINI AND ('"+DTOS(dAlocDe)+"' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM ='')) OR "
cQuery += 			"('"+DTOS(dAlocDe )+"' <= SR8.R8_DATAINI AND '"+DTOS(dAlocAte)+"' <= SR8.R8_DATAFIM) OR "
cQuery += 			"('"+DTOS(dAlocDe )+"' <= SR8.R8_DATAINI AND '"+DTOS(dAlocAte)+"' >= SR8.R8_DATAFIM) OR "
cQuery += 			"('"+DTOS(dAlocAte)+"' >= SR8.R8_DATAINI AND SR8.R8_DATAFIM ='') "
cQuery += 			")"
cQuery += "	AND SR8.D_E_L_E_T_ = ' ' "

If !lVerFr // Realizado condição (2 = 1) caso MV_GSVERFR := .F.
	cCondFr := '2 = 1'
EndIf  

cQuery += "	LEFT JOIN "+RetSqlName("SRF")+" SRF "
cQuery += 		" ON SRF.RF_FILIAL = SRA.RA_FILIAL AND SRF.RF_MAT = SRA.RA_MAT AND "+cCondFr+" AND SRF.D_E_L_E_T_ = ' ' AND "
cQuery += "("
cQuery += 		"("
cQuery += 		" ( '"+DTOS(dAlocDe)+"' >= SRF.RF_DATAINI OR"
cQuery += 		"   '"+DTOS(dAlocAte)+"' <= SRF.RF_DATAINI ) "
cQuery += 		" OR (SRF.RF_DATAINI BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"' ) "
cQuery += 		")OR("
cQuery += 		" ( '"+DTOS(dAlocDe)+"' >= SRF.RF_DATINI2 OR"
cQuery += 		"   '"+DTOS(dAlocAte)+"' <= SRF.RF_DATINI2 ) "
cQuery += 		" OR (SRF.RF_DATINI2 BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"' ) "
cQuery += 		")OR("
cQuery += 		" ( '"+DTOS(dAlocDe)+"' >= SRF.RF_DATINI3 OR"
cQuery += 		" '"+DTOS(dAlocAte)+"' <= SRF.RF_DATINI3 ) "
cQuery += 		" OR (SRF.RF_DATINI3 BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"' ) "
cQuery += 		")"
cQuery += ")"

If (lJoinABB .And. !lTecr020) .OR. IsInCallStack("At190dCons")

	If cCompE == 'C' .AND. cCompU == 'C' .AND. cCompF == 'C'
		cFilPesq := XFilial("ABB")
	ElseIf cCompU == 'E'
		aFilPesq := FWAllFilial(aSM0[SM0_EMPRESA],aSM0[SM0_UNIDNEG])
	ElseIf cCompE == 'E'
		aFilPesq := FWAllUnitBusiness(aSM0[SM0_EMPRESA])
	EndIf

	For nX := 1 To Len(aFilPesq)
		If nX > 1
			cFilPesq+="','"
		EndIf
		If cCompF == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+aFilPesq[nX]
		ElseIf cCompU == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+Space(Len(aFilPesq[nX]))
		ElseIf cCompE == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+Space(Len(aSM0[SM0_UNIDNEG]))+Space(Len(aSM0[SM0_FILIAL]))
		EndIf
	Next nX
	cQuery += " LEFT JOIN " + RetSqlName("ABB") + " ABB ON ABB.ABB_FILIAL IN ('" + cFilPesq + "') "
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
	
	cQuery += " LEFT JOIN " + RetSqlName("TDV") + " TDV ON TDV.TDV_FILIAL = ABB.ABB_FILIAL "
	cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
	cQuery += " AND TDV.TDV_DTREF BETWEEN '" + DTOS(dAlocDe) + "' AND '" + DTOS(dAlocAte)  + "' "

	If lCheckRT
		cQuery += " LEFT JOIN " + RetSqlName("TCU") + " TCU ON "
		cQuery += FWJoinFilial("ABB" , "TCU" , "ABB", "TCU", .T.) + " AND "
		cQuery += " TCU.D_E_L_E_T_ = ' ' AND "
		cQuery += " ABB.ABB_TIPOMV = TCU.TCU_COD "
	EndIf
EndIf

If lResRHTXB
	cQuery += " LEFT JOIN " + RetSqlName("TXB") + " TXB ON TXB.TXB_FILIAL = '"+xFilial('TXB')+"' "
	cQuery += " AND TXB.TXB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND (('"+DTOS(dAlocDe)+"' >= TXB.TXB_DTINI AND '"+DTOS(dAlocDe)+"' <= TXB.TXB_DTFIM ) OR"
	cQuery += "('"+DTOS(dAlocAte)+"' >= TXB.TXB_DTINI AND '"+DTOS(dAlocAte)+"' <= TXB.TXB_DTFIM ) OR"
	cQuery += "('"+DTOS(dAlocDe)+"' >= TXB.TXB_DTINI AND TXB.TXB_DTFIM  ='') OR"
	cQuery += "('"+DTOS(dAlocAte)+"' >= TXB.TXB_DTINI AND TXB.TXB_DTFIM  ='') OR"
	cQuery += "('"+DTOS(dAlocDe)+"' <= TXB.TXB_DTINI AND ('"+DTOS(dAlocAte)+"' >= TXB.TXB_DTFIM AND TXB.TXB_DTFIM <> '')))"
	cQuery += " AND TXB.D_E_L_E_T_ = ' ' "
Endif

cQuery += "	WHERE  "

cQuery += "	AA1.AA1_FILIAL = '"+xFilial('AA1')+"' "

If Empty(aLstAte)
	cQuery += "	AND AA1.AA1_CODTEC >= '"+cAtendDe+"' "
	cQuery += "	AND AA1.AA1_CODTEC <= '"+cAtendAte+"' "
Else
	cLstAte := "("
	For nI := 1 to Len(aLstAte)
		cLstAte += "'" + aLstAte[nI]
		cLstAte += If(Len(aLstAte) == nI, "'","';")
	Next nI
	cLstAte += ") "
	
	cQuery += "	AND AA1.AA1_CODTEC IN " + cLstAte
EndIf

cQuery += "	AND AA1.D_E_L_E_T_ = ' ' "
cQuery += "	AND ("
cQuery += "	(SRA.RA_ADMISSA <> '' AND SRA.RA_ADMISSA >= '"+DTOS(dAlocDe)+"') OR "
cQuery += "	(SRA.RA_ADMISSA <> '' AND SRA.RA_ADMISSA >= '"+DTOS(dAlocAte)+"') OR "
cQuery += "	(SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= '"+DTOS(dAlocDe)+"') OR "
cQuery += "	(SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= '"+DTOS(dAlocAte)+"') OR "

If lUsaEAIGS
	cQuery += "	SRA.RA_SITFOLH = 'A' "
Else
	cQuery += "	SR8.R8_DATAINI <> '' "
EndIf

cQuery += "OR SRF.RF_DATAINI <> '' "
cQuery += "OR SRF.RF_DATINI2 <> '' OR SRF.RF_DATINI3 <> '' "

If lResRHTXB
	cQuery += " OR TXB.TXB_DTINI <> '' "
EndIf

If (lJoinABB .And. !lTecr020) .OR. IsInCallStack("At190dCons")
	cQuery += " OR (ABB.ABB_DTINI BETWEEN '"+DTOS(dAlocDe)+"' AND '" + DTOS(dAlocAte)  + "' OR ABB.ABB_DTFIM BETWEEN '"+DTOS(dAlocDe)+"' AND '" + DTOS(dAlocAte) + "') AND ABB.ABB_ATIVO <> '2' "
EndIf

cQuery += ")"

If lJoinABB .AND. !EMPTY(cNotIdcFal) .And. !lTecr020 
	If !IsInCallStack("At190GAlAv")
		cQuery += " AND ABB.ABB_IDCFAL <> '" + cNotIdcFal + "' "                     
	EndIf	
EndIf

If IsInCallStack("At330ADtCfl")

	cQuery += " UNION "
	cQuery += " SELECT "
	cQuery += "  AA1.AA1_FILIAL "
	cQuery += " ,AA1.AA1_CODTEC "
	cQuery += " ,AA1.AA1_NOMTEC "
	cQuery += " ,ABB.ABB_DTINI ABB_DTINI "
	cQuery += " ,ABB.ABB_HRINI ABB_HRINI "
	cQuery += " ,ABB.ABB_DTFIM ABB_DTFIM "
	cQuery += " ,ABB.ABB_HRFIM ABB_HRFIM "
	cQuery += " ,' ' RA_SITFOLH "
	cQuery += " ,' ' RA_DEMISSA "
	cQuery += " ,' ' RF_DATAINI "
	cQuery += " ,' ' RF_DFEPRO1 "
	cQuery += " ,' ' RF_DATINI2 "
	cQuery += " ,' ' RF_DFEPRO2 "
	cQuery += " ,' ' RF_DATINI3 "
	cQuery += " ,' ' RF_DFEPRO3 "
	cQuery += " ,' ' R8_DATAINI "
	cQuery += " ,' ' R8_DATAFIM "

	If lResRHTXB
		cQuery += " , ' '  TXB_DTINI "
		cQuery += " , ' '  TXB_DTFIM "
	Endif

	cQuery += " FROM "+RetSqlName("AA1")+" AA1 "

	cQuery += " LEFT JOIN " + RetSqlName("ABB") + " ABB ON ABB.ABB_FILIAL = '"+xFilial('ABB')+"'  "
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

	cQuery += "	WHERE  "

	cQuery += "	AA1.AA1_FILIAL = '"+xFilial('AA1')+"' "

	If Empty(aLstAte)
		cQuery += "	AND AA1.AA1_CODTEC >= '"+cAtendDe+"' "
		cQuery += "	AND AA1.AA1_CODTEC <= '"+cAtendAte+"' "
	Else
		cLstAte := "("
		For nI := 1 to Len(aLstAte)
			cLstAte += "'" + aLstAte[nI]
			cLstAte += If(Len(aLstAte) == nI, "'","';")
		Next nI
		cLstAte += ") "

		cQuery += "	AND AA1.AA1_CODTEC IN " + cLstAte
	EndIf

	cQuery += "	AND AA1.D_E_L_E_T_ = ' ' "
	cQuery += " AND (ABB.ABB_DTINI BETWEEN '" + DTOS(dAlocDe) + "' AND '" + DTOS(dAlocAte)  + "' OR ABB.ABB_DTFIM BETWEEN '" + DTOS(dAlocDe) + "' AND '" + DTOS(dAlocAte) + "') "

Endif  

IF IsInCallStack("At190dCons")
    cQuery += "	 AND TDV_DTREF <> ''"
Endif

cQuery += "	 ORDER BY AA1_CODTEC"
cQuery += "	,AA1_NOMTEC"
cQuery += "	,ABB_DTINI"
cQuery += "	,ABB_HRINI"
cQuery += "	,ABB_DTFIM"

Return ChangeQuery(cQuery)

/*/{Protheus.doc} AT570LoadM
Realiza o Carregamento no Model
@param	oModel MPFormModel
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return 
/*/
Static Function AT570LoadM(oModel)
Local aCpos := AT570Field()
Local nI := 1
Local oStruct := oModel:GetModel("MASTER"):GetStruct()

For nI:=1 To Len(aCpos)
	If !aCpos[nI] $ "RH_DATAINI|RH_DATAFIM"
		If oStruct:GetProperty(aCpos[nI], MODEL_FIELD_TIPO) == "D"
			oModel:LoadValue("MASTER",aCpos[nI], STOD((cAliasTmp)->&(aCpos[nI])))
		Else
			oModel:LoadValue("MASTER",aCpos[nI], (cAliasTmp)->&(aCpos[nI]))
		EndIf
	EndIf
Next nI

Return

/*
{Protheus.doc} AT570Status

Recupera Status de conflito para apresentação no Browse

@param  cAlias	String	Alias aberto para verificação do status
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cStatus	String Status do registro do cAlias
*/
Static Function AT570Status(cAlias)

Local cStatus := ''
Local cFeriasIni := DTOS(At570IniF())
Local cFeriasFim := DTOS(At570FimF())
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
Local lResRHTXB	:= TableInDic("TXB")
Local aPrjAgd	:= {}
Local lGSVERHR  := .F.

//Admissão
If !Empty((cAlias)->RA_ADMISSA) .AND. ((cAlias)->RA_ADMISSA >= (cAlias)->TDV_DTREF)
	cStatus := 'BR_BRANCO'

//Demissão e Admissão 
ElseIf !Empty((cAlias)->RA_DEMISSA) .AND. ((cAlias)->RA_DEMISSA <= (cAlias)->TDV_DTREF)  
	cStatus := 'BR_VERMELHO'

//Férias
ElseIf ((cAlias)->TDV_DTREF >= cFeriasIni .AND. (cAlias)->TDV_DTREF <= cFeriasFim)
	cStatus := "BR_AZUL"

//Afastamento
ElseIf	(!Empty((cAlias)->R8_DATAINI) .And. ( ( lUsaEAIGS .And. (cAlias)->RA_SITFOLH = 'A' ) ;
		.OR. ( !lUsaEAIGS .And. ;
		((cAlias)->TDV_DTREF >= (cAlias)->R8_DATAINI .AND. (cAlias)->TDV_DTREF <= (cAlias)->R8_DATAFIM) .OR.;
		((cAlias)->TDV_DTREF >= (cAlias)->R8_DATAINI .AND. Empty((cAlias)->R8_DATAFIM) );
		)))
	cStatus := "BR_AMARELO"

//Restrição de RH
Elseif lResRHTXB .And. !Empty((cAlias)->TXB_DTINI)
	cStatus := "BR_PRETO"

//Conflito de agenda
Elseif !Empty((cAlias)->ABB_DTINI)

	cStatus := "BR_PINK"
Endif

Return cStatus

/*
{Protheus.doc} AT570Legen

Aprensentação das Legendas disponiveis

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
*/
Static Function AT570Legen()
Local oLegenda  :=  FWLegend():New()
Local lResRHTXB := TableInDic("TXB")

oLegenda:Add( '', 'BR_BRANCO'   , STR0038 ) //'Alocação sem Admissão'
oLegenda:Add( '', 'BR_VERMELHO'	, STR0004 )	//'Alocação com Demissão'
oLegenda:Add( '', 'BR_AMARELO'	, STR0005 )	//'Alocação com Afastamento'
oLegenda:Add( '', 'BR_AZUL'		, STR0006 )	//'Alocação com Férias'

If lResRHTXB
	oLegenda:Add( '', 'BR_PRETO'	, STR0021 )	//"Conflito de Alocação RH"
Endif

oLegenda:Add( '', 'BR_PINK'	, STR0022 )	//"Conflito de agenda"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//Substituição da alocação
/*
{Protheus.doc} AT570Subst

Apresenta tela para escolha de substituto e gera registro na manunteção da alocação. 

@param  cAlias	String
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013  
*/
Function AT570Subst(cAlias, oBrowse )

	Local aCarga := {}
	Local aArea := GetArea()
	Local aAreaABB := ABB->(GetArea())
	Local aAreaABR := ABR->(GetArea())
	Local cCodAtdSub := Space(Len(ABR->ABR_CODSUB))
	Local aErrors := {}
	Local cAliasBkp := ""
	Local cAliasABB:=""
	Local aQry540 := {}
	Local cQryABB := ""
	Local lRet := .T.
	Local cMotivo :=  AllTrim(SuperGetMV("MV_ATMTCAN", , "")) //Parametro para motivo de cancelamentol
	Local aCombo := StrToKArr(RetField("SX3", 2, "ABR_TIPDIA", "X3_CBOX"), ";")	//	Retorna o Combo do Campo
	Local cTipoDia := " "
	Local cMsg := CRLF
	Local nOpcao := 0
	Local nFail := 0
	Local nIncl := 0
	Local nX := 0
	Local nY := 0
	Local oTela
	Local oTipo

	aSize(aCombo, Len(aCombo) + 1)
	aIns(aCombo, 1)
	aCombo[1] := " "	//	Insere opção EM BRANCO

	//Valida Motivo de cancelamento
	If ValType(cMotivo) != "C" .OR. Empty(cMotivo) .OR. !AT570VldMt(AllTrim(cMotivo))
		Help( ' ', 1, 'AT570Subst', , STR0012, 1, 0 )	//"Parametro MV_ATMTCAN deve ser um motivo do tipo de Cancelamento."
		Return .F.
	EndIf

	Define MsDialog oTela Title STR0023 From 0, 0 To 200, 280 Pixel
	@ 010, 030 Say STR0024 Of oTela Pixel
	@ 020, 030 MsGet cCodAtdSub Valid (Empty(cCodAtdSub) .Or. ExistCpo("AA1", cCodAtdSub, 1)) F3 "T19AA1" Picture "@!" Of oTela Pixel
	@ 040, 030 Say STR0025 Of oTela Pixel
	@ 050, 030 ComboBox oTipo Var cTipoDia Items aCombo Of oTela Pixel Size 85, 10
	@ 080, 030 Button STR0026 Size 40,15 Action (nOpcao := 1, oTela:End()) Of oTela Pixel
	@ 080, 095 Button STR0027 Size 20,15 Action oTela:End() Of oTela Pixel
	Activate MsDialog oTela Centered
	If nOpcao == 1
		(cAlias)->(dbGoTop())
		While ! (cAlias)->(Eof())
			If oBrowse:IsMark()
				Begin Transaction

					//Encontra informações para a carga
					ABB->(DbSetOrder(1))//ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)+ABB_HRINI+DTOS(ABB_DTFIM)+ABB_HRFIM
					If ABB->(MsSeek( (cAlias)->ABB_FILIAL+(cAlias)->AA1_CODTEC+(cAlias)->ABB_DTINI+(cAlias)->ABB_HRINI+(cAlias)->ABB_DTFIM+(cAlias)->ABB_HRFIM))

						//Recupera contrato e Origem
						ABQ->(DbSetOrder(1))//ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
						If ABQ->(DbSeek(xFilial("ABQ")+ABB->ABB_IDCFAL))
							AAdd( aCarga, { ABB->ABB_CODTEC 										 	,;
								SubStr( ABB->ABB_IDCFAL, 1, TAMSX3( 'AAH_CONTRT' )[1] )	,;
								ABB->ABB_CODIGO  					   							,;
								DTOS(ABB->ABB_DTINI)												,;
								ABB->ABB_HRINI	   											,;
								DTOS(ABB->ABB_DTFIM)	   											,;
								ABB->ABB_HRFIM} )//Origem		

							//Verifica Manutenções
							If	AT570CkMan(ABB->ABB_FILIAL, ABB->ABB_CODIGO)
								Help( ' ', 1, 'AT570Subst', , STR0015, 1, 0 )	//"A agenda já possui manutenção por motivo de cancelamento."

							Else//Não existe manutenção do tipo Cancelamento '05'

								ABQ->(DbSetOrder(1))
								ABQ->(MsSeek(xFilial("ABQ") + ABB->ABB_IDCFAL))
							
								TFF->(DbSetOrder(1))
								TFF->(MsSeek(xFilial("TFF") + ABQ->ABQ_CODTFF))

								cAliasABB := GetNextAlias()
								cAliasBkp := At550GtAls()

								aQry540 := AT540ABBQry( ABB->ABB_CODTEC, ABB->ABB_CHAVE, ABB->ABB_DTINI, ABB->ABB_DTFIM, Nil , Nil, ABB->ABB_CODIGO, .T., ABB->ABB_ENTIDA )//Recupera cQuery para o model da TECA550

								If Len(aQry540) > 0

									cQryABB := aQry540[1]
									//Habilita registros no Alias temporario para ser considerada a agenda no Model TECA550
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryABB),cAliasABB)

									AT550StAls(cAliasABB)//Add Alias para o model
									At550SetGrvU(.T.)

									oModel := FWLoadModel( "TECA550" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
									oModel:SetOperation(MODEL_OPERATION_INSERT)
									lRet := oModel:Activate()
									lRet := lRet .And. oModel:SetValue('ABRMASTER', 'ABR_MOTIVO', cMotivo)
									lRet := lRet .And. oModel:SetValue('ABRMASTER', 'ABR_CODSUB', cCodAtdSub)
									lRet := lRet .And. oModel:SetValue('ABRMASTER', 'ABR_TIPDIA', cTipoDia)
									lRet := lRet .And. oModel:VldData()
									lRet := lRet .And. oModel:CommitData()//Grava Model
									If lRet
										nIncl++
									Else
										nFail++
										aAdd(aErrors, oModel:GetErrorMessage())
									EndIf

									At550StAls(cAliasBkp)//Volta alias original para rotina
									At550SetGrvU(.F.)
								EndIf
							EndIf
						EndIf
					EndIf
				End Transaction
			Endif
			(cAlias)->(dbSkip())
		Enddo
		If nIncl + nFail == 0
			cMsg += STR0028
		Elseif Empty(aErrors)
			If nIncl > 1
				cMsg += STR0029 + Alltrim(Str(nIncl)) + STR0030
			Else
				cMsg += STR0031
			Endif
			oBrowse:Refresh(.T.)
		Else
			cMsg := STR0032 + cValToChar(nIncl + nFail) + CRLF
			cMsg += STR0033 + cValToChar(nIncl) + CRLF
			cMsg += STR0034 + cValToChar(nFail) + CRLF + CRLF
			cMsg += STR0035 + CRLF + CRLF
			For nX := 1 To Len(aErrors)
				For nY := 1 To Len(aErrors[nX])
					If aErrors[nX, nY] <> Nil .And. ! Empty(aErrors[nX, nY])
						cMsg += aErrors[nX, nY] + CRLF
					Endif
				Next
				cMsg += CRLF + Replicate("-", 70) + CRLF
			Next
			cMsg += CRLF + STR0036
		Endif
		AtShowLog(cMsg, STR0037, /*lVScroll*/, /*lHScroll*/, /*lWrdWrap*/, .F.)
	Endif
	RestArea(aAreaABB)
	RestArea(aAreaABR)
	RestArea(aArea)

Return lRet

//Atualiza Browse
/*
{Protheus.doc} AT570Refresh

Atualiza o Browse

@param  oBrw FWFormBrowse
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013  
*/
Function AT570Refresh(oBrw)

	oBrw:SetQuery( AT570Query(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04) )

	oBrw:Refresh( .T. )
Return


/*
{Protheus.doc} AT570VldMt

Realiza validação do motivo de manut
@param  cMotivo String Motivo que será validado
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean 
*/
Static Function AT570VldMt(cMotivo)
Local aArea 	:= GetArea()
Local aAreaABN := ABN->(GetArea())
Local lRet := .F.

ABN->(DbSetOrder(1))//ABN_FILIAL+ABN_CODIGO

If ValType(cMotivo) == "C" .AND. ( ABN->( DbSeek( xFilial('ABN') + Padr( cMotivo, Tamsx3("ABN_CODIGO")[1] ) ) ) )
	lRet := ABN->ABN_TIPO == MANUT_TIPO_CANCEL
EndIf

RestArea(aAreaABN)
RestArea( aArea )

Return lRet


/*
{Protheus.doc} At570VldRh

Valida Inconsistencias no RH para alocação em determinada data.
Retorn Verdadeiro caso não exista inconsistencias para o tecnico, Falso caso exista inconsistencias

@param	cCodTec	String Codigo do tecnico a ser validado
@param dDataIni	Data Data inicial de alocação a ser validada
@param dDataFim	Data Data Final de alocação a ser validada
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet	Boolean 
*/
Function At570VldRh(cCodTec, dDataIni, dDataFim,nTpRest)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaAA1:= AA1->(GetArea())
Local cFilFun := ""
Local cMat := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada

Default nTpRest := 0

AA1->(DbSetOrder(1))//AA1_FILIAL+AA1_CODTEC

If AA1->(MsSeek(xFilial("AA1")+cCodTec))
	cFilFun := AA1->AA1_FUNFIL
	cMat := AA1->AA1_CDFUNC
EndIf

If !Empty(cMat)

	//Verifica inconsistencias em determinada data
	If CheckDemis(cFilFun, cMat, dDataIni, dDataFim) .OR. CheckAfast(cFilFun, cMat, dDataIni, dDataFim)
		nTpRest := 1
		lRet := .F.
	EndIf

	If lRet .And. CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
		lRet := .F.
		nTpRest := 2
	EndIf

	If lRet .And. lUsaEAIGS .And. Posicione("SRA",1,xFilial("SRA")+cMat,"RA_SITFOLH") $ "A/D"
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaAA1)
RestArea(aArea)
Return lRet


/*
{Protheus.doc} CheckDemis

Verifica se há inconsistencia de Demissao 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
 */
Static Function CheckDemis(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := .F.
	Local aAreaSRA := SRA->(GetArea())

	SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
	If SRA->(MsSeek(cFilFun+cMat))
		If !Empty(SRA->RA_DEMISSA)
			If SRA->RA_DEMISSA <= dDataIni .OR. SRA->RA_DEMISSA <= dDataFim
				lRet := .T.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSRA)

Return lRet

/*
{Protheus.doc} CheckAdmis

Verifica se há inconsistencia de Admissão  
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  Matheus.Gonçalves
@author  Matheus.Gonçalves
@version V12
@since   15/02/2021
@return lRet 	 
 */
Static Function CheckAdmis(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := .F.
	Local aAreaSRA := SRA->(GetArea())

	SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
	If SRA->(MsSeek(cFilFun+cMat))
		If !Empty(SRA->RA_ADMISSA)
			If SRA->RA_ADMISSA >= dDataIni .OR. SRA->RA_ADMISSA >= dDataFim 
				lRet := .T.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSRA)

Return lRet

/*/{Protheus.doc} CheckAfast

Verifica se há inconsistencia de Afastamento

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
/*/ 
Static Function CheckAfast(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
	Local lRet := .F.
	Local aArea := GetArea()
	Local cAlias := GetNextAlias() 
	
	Default lRetPeriod := .F.
	Default aPeriodos := {}
	
	BeginSQL alias cAlias		
		SELECT 	COUNT(*) NUM, SR8.R8_DATAINI, SR8.R8_DATAFIM
 		FROM %table:SR8% SR8  
 		WHERE 		
			SR8.%notDel%
 			AND SR8.R8_FILIAL = %exp:cFilFun% 				
 			AND SR8.R8_MAT = %exp:cMat%
 			AND (( SR8.R8_DATAINI BETWEEN %exp:dDataIni% AND %exp:dDataFim%
      				OR SR8.R8_DATAFIM BETWEEN %exp:dDataIni% AND %exp:dDataFim%)
      				
      		OR ( %exp:dDataIni% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM 
      				OR %exp:dDataFim% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM))
      				
      				
      	GROUP BY
      		SR8.R8_DATAINI, SR8.R8_DATAFIM		
	EndSQL	

	If (cAlias)->(!Eof()) .AND. (cAlias)->NUM > 0
		lRet := .T.
	EndIf
	
	If lRetPeriod
		While (cAlias)->(!Eof())
			AADD(aPeriodos , {(cAlias)->R8_DATAINI ,(cAlias)->R8_DATAFIM})
			(cAlias)->(DbSkip())
		End
	EndIf
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
					
Return lRet


/*/{Protheus.doc} CheckAfast

Verifica se há inconsistencia de Férias

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
/*/ 
Static Function CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := .F.
	Local aArea := GetArea()
	Local cAliasSRF := GetNextAlias() 
	Local lVerFr	:= SuperGetMV("MV_GSVERFR",,.T.)

	If lVerFr
		BeginSQL alias cAliasSRF			
			SELECT 	
				SRF.RF_DATAINI, 
				SRF.RF_DFEPRO1,
				SRF.RF_DATINI2,
				SRF.RF_DFEPRO2,
				SRF.RF_DATINI3,
				SRF.RF_DFEPRO3
				
			FROM %table:SRF% SRF 
			WHERE 
				SRF.%notDel%
				AND SRF.RF_FILIAL = %exp:cFilFun% 				
				AND SRF.RF_MAT = %exp:cMat%
				AND ( 	
						(
							%exp:dDataIni% >= SRF.RF_DATAINI OR
							%exp:dDataFim% <= SRF.RF_DATAINI 				
						) OR (					
							%exp:dDataIni% >= SRF.RF_DATINI2 OR	
							%exp:dDataFim% <= SRF.RF_DATINI2  					
						) OR ( 	
							%exp:dDataIni% >= SRF.RF_DATINI3 OR
							%exp:dDataFim% <= SRF.RF_DATINI3 
						)
					) 	 			
		EndSQL	

		While (cAliasSRF)->(!Eof())
		
			If !Empty((cAliasSRF)->RF_DATAINI) .AND.;
				DTOS(dDataIni) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
				DTOS(dDataFim) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
				DTOS(dDataIni) <= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1)))
					
				lRet := .T.
				Exit
									
			ElseIf  !Empty((cAliasSRF)->RF_DATINI2) .AND.;
				DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
				DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
				DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1)))
				
				lRet := .T.
				Exit
							
			ElseIf  !Empty((cAliasSRF)->RF_DATINI3) .AND.;
				DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
				DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
				DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1)))
				
				lRet := .T.
				Exit
							
			EndIf

			(cAliasSRF)->(DbSkip())
		EndDo

		(cAliasSRF)->(DbCloseArea())
				
		RestArea(aArea)		
	EndIf	
Return lRet

/*
{Protheus.doc} AT570Detal

Apresenta tela com detalhes de conflitos de alocação

@param	cAtend		String	Codigo do atendente
@param	aPeriodos	Array	Informações de periodos a serem considerados
@param	aConfAloc	Array	Configuração de alocação a ser considerada
@param	aPosPeriod	Array	Posição de data inicial e data Final dentro do aConfAloc [1]Data Inicial [2]Data Final
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
*/
Function AT570Detal(cAtend, aPeriodos)
Local nI := 1
Local dAlocDe := STOD("")
Local dAlocAte := STOD("")
Local cAliasBkp := cAliasTmp //realiza backup do alias atual da variavel estatica, para o caso de chamar a rotina dentro da TECA570


Default aPeriodos := {}

If ValType(aPeriodos) == "A" .AND. Len(aPeriodos) > 0
	dAlocDe 	:= aPeriodos[1][1]
	dAlocAte 	:= aPeriodos[1][3]

	//Encontra menor e mairo data de alocacao do periodo
	For nI:=1 To Len(aPeriodos)
		If aPeriodos[nI][1] < dAlocDe
			dAlocDe := aPeriodos[nI][1]
		EndIf
		If aPeriodos[nI][3] > dAlocAte
			dAlocAte := aPeriodos[nI][3]
		EndIf
	Next nI

	TECA570({dAlocDe, dAlocAte, cAtend, cAtend}, .T.)

	cAliasTmp := cAliasBkp //Volta Alias

EndIf


Return

/*
{Protheus.doc} AT570CkMan

Verifica se agenda possui manutenções do tipo de cancelamento

@param	cFil	String	Filial da agenda
@param	cAgenda	String	Codigo da Agenda

@return lRet	Boolean	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   05/06/2013 
*/
Static Function AT570CkMan(cFil, cAgenda)
	Local lRet := .F.
	Local aArea := ABR->(GetArea())

	ABR->(DbSelectArea(1))//ABR_FILIAL+ABR_AGENDA+ABR_MOTIVO
	ABR->( MsSeek(cFil+cAgenda ) )
	While ABR->(!EOF()) .AND. ABR->ABR_FILIAL == cFil .AND. ABR->ABR_AGENDA == cAgenda
		If AT570VldMt(ABR->ABR_MOTIVO)
			lRet := .T.
			Exit
		EndIF
		ABR->(DbSkip())
	End

	RestArea(aArea)

Return lRet

/*
{Protheus.doc} AT570Perm

Recupera permissão de contratos e equipes no formato SQL para realização de filtros em query

@param  
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return cPermissao String Permissoes no formato SQL
 
*/
Static Function AT570Perm()
Local aPermissao	:= at570GetPe()//Recupera array de permissoes
Local aOs := {}
Local aAtend := {}
Local cOs:=""
Local cAtend := ""

Local nI := 1
Local cRet := ""

//Verifica permissoes de equipes
aAtend := at570PerAt()
If Len(aAtend) > 0
	For nI:=1 To Len(aAtend)
		cAtend += "'"+aAtend[nI]+"',"
	Next nI
	
	If !Empty(cAtend)
		cAtend:=SubStr(cAtend, 1, Len(cAtend)-1)
	EndIf
EndIf

If !Empty(cAtend)
 	cRet += " AND ABB.ABB_CODTEC IN ("+cAtend+")"
EndIf

Return cRet

/*
{Protheus.doc} at570PerAt

retorna codigo dos atendentes da equipe do usuario logado.

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aRet Array Codigos de atendentes das equipes do usuario
*/
Static Function at570PerAt()
Local aPerEquipe := at570Equip(__cUserId)
Local aRet:={}
Local nI:=1

//Recupera codigo dos atendentes
For nI:=1 To Len(aPerEquipe)
	AAY->(DbSetOrder(1))//AAY_FILIAL+AAY_CODEQU+AAY_CODTEC
	If AAY->(MsSeek(xFilial("AAY")+aPerEquipe[nI]))

		While( AAY->(!EOF()) .AND. xFilial("AAY")==AAY->AAY_FILIAL .AND. aPerEquipe[nI]==AAY->AAY_CODEQU)
			If aScan(aRet, {|x| x == AAY->AAY_CODTEC}) == 0
				aAdd(aRet,AAY->AAY_CODTEC)
			EndIf
			AAY->(DbSkip())
		End

	EndIf
Next nI


Return aRet

/*
{Protheus.doc} at570Equip

Retorna codigos das equipes do usuario definido pelo parametro cId

@param  cID String Id do usuario
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aEquipe Array Codigos da equipe do usuario 
*/
Static Function at570Equip(cId)
Local aEquipe := {}
Local cAlias := GetNextAlias()
Local cQuery := ""

AA1->(DbSetorder(4)) //AA1_FILIAL+AA1_CODUSR

If !Empty(cId) .AND. AA1->(DbSeek(xFilial("AA1")+cId))
	cQuery := 	" SELECT AAY.AAY_CODEQU,R_E_C_N_O_ AAYRECNO FROM " + RetSqlName("AAY") + " AAY "
	cQuery += 	"WHERE"
	cQuery += 	" AAY_FILIAL='" + xFilial( "AAY" ) + "' AND "
	cQuery +=	"AAY_CODTEC = '"+AA1->AA1_CODTEC+"' AND "
	cQuery += 	"D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias, .T., .T. )

	While (cAlias)->( !Eof() )
		aAdd(aEquipe, ( cAlias )->AAY_CODEQU)
		( cAlias )->(DbSkip())
	End
EndIf

Return aEquipe


/*
{Protheus.doc} at570CPerm

Verifica se controla permissoes de acordo com parametro MV_TECPCON  e cadastro de permissoes
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return lCOntrola Boolean - Verdadeiro indica que controla permissoes, Falso indica que não controla permissoes 
*/
Static Function at570CPerm()
Local lPercTec		:= SuperGetMv('MV_TECPCON',,.F.)
Local aPermissao	:= at570GetPe()//Recupera permissoes
Local aAtend 		:= at570PerAt()//Permissoes de equipe
Local lControla := .F.

If lPercTec .OR. !Empty(aPermissao) .OR. !Empty(aAtend)
	lControla := .T.
Else
	lControla := .F.
EndIf
Return lControla

/*
{Protheus.doc} at570GetPe

Aplicação de padrão singleton para aPErm
 
Controle da variavel estática aPerm, caso não tenha sido realizada atribuição com seu conteudo, realiza a chamada da função At120Perm 
para carregar variavel aPerm somente uma vez no fonte.
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aPerm Array
*/
Static Function at570GetPe()
If ValType(aPerm) == "U"
	aPerm := At201Perm()
EndIf
Return aPerm

/*/{Protheus.doc} At570IniF
	
@author rogerio.souza
@since 23/12/2013
@version V11.9
@return dData, Data de inicio das férias
@description
Calcula e retorna data de inicio das férias

/*/
Function At570IniF()

Local dData := STOD("")

If !Empty(RF_DATAINI) .AND.;
	ABB_DTINI >= RF_DATAINI .AND. ABB_DTINI <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTFIM >= RF_DATAINI .AND. ABB_DTFIM <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTINI <= RF_DATAINI .AND. ABB_DTFIM >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1)))

	dData := STOD(RF_DATAINI)

ElseIf  !Empty(RF_DATINI2) .AND.;
	ABB_DTINI >= RF_DATINI2 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTFIM >= RF_DATINI2 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTINI <= RF_DATINI2 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1)))

	dData := STOD(RF_DATINI2)

ElseIf  !Empty(RF_DATINI3) .AND.;
	ABB_DTINI >= RF_DATINI3 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTFIM >= RF_DATINI3 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTINI <= RF_DATINI3 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1)))

	dData := STOD(RF_DATINI3)

EndIf

Return dData

/*/{Protheus.doc} At570FimF
	
@author rogerio.souza
@since 23/12/2013
@version V11.9	
@return dData, Data final das férias

@description
Calcula e retorna data final das férias do funcionário.

/*/
Function At570FimF()

Local dData := STOD("")

If !Empty(RF_DATAINI) .AND.;
	ABB_DTINI >= RF_DATAINI .AND. ABB_DTINI <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTFIM >= RF_DATAINI .AND. ABB_DTFIM <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTINI <= RF_DATAINI .AND. ABB_DTFIM >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1)))

	dData := STOD(RF_DATAINI) + (RF_DFEPRO1-1)

ElseIf  !Empty(RF_DATINI2) .AND.;
	ABB_DTINI >= RF_DATINI2 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTFIM >= RF_DATINI2 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTINI <= RF_DATINI2 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1)))

	dData := STOD(RF_DATINI2) + (RF_DFEPRO2-1)

ElseIf  !Empty(RF_DATINI3) .AND.;
	ABB_DTINI >= RF_DATINI3 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTFIM >= RF_DATINI3 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTINI <= RF_DATINI3 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1)))

	dData := STOD(RF_DATINI3) + (RF_DFEPRO3-1)

EndIf


Return dData

/*/{Protheus.doc} At570Filter
	
@since 08/12/2014
@version V12
@return lREt, avaliação do filtro
@description filtro para avaliação de férias, demissão, admissãoe a fastamento durante período de alocação 
/*/
Function At570Filter()

Local lAfasta 		:= .F.
Local lDemiss 		:= .F.
Local lAdmiss		:= .F.
Local lFerias 		:= .F.
Local lUsaEAIGS 	:= ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
Local lResRHTXB		:= TableInDic("TXB")
Local lRestri		:= .F.
Local lConfl		:= .F.

// Conflito de Afastamento
lAfasta := (AllTrim(R8_DATAINI) <> '')

//Conflito de Admissão
lAdmiss := !lAfasta .And.( ;
				( lUsaEAIGS .And. RA_SITFOLH = 'A' ) ;
				.Or. ;
				( !lUsaEAIGS .And. (( AllTrim(RA_ADMISSA) != '' .AND. RA_ADMISSA >= ABB_DTINI ) .OR. ; 				
				 					 (AllTrim(RA_ADMISSA) != '' .AND. RA_ADMISSA >= ABB_DTFIM ))) ;
			)

//Conflito de Demissão
lDemiss := !lAfasta .And. !lAdmiss .And.( ;
				( lUsaEAIGS .And. RA_SITFOLH = 'A' ) ;
				.Or. ;
				( !lUsaEAIGS .And. (( AllTrim(RA_DEMISSA) != '' .AND. RA_DEMISSA <= ABB_DTINI ) .OR. ; 				
				 					 (AllTrim(RA_DEMISSA) != '' .AND. RA_DEMISSA <= ABB_DTFIM ))) ;
			)

//Conflito de Férias
lFerias := !lAfasta .And. !lAdmiss .And. !lDemiss .And. ( ;
				AllTrim(RF_DATAINI) != '' .AND. ;
				( ;
					TDV_DTREF >= RF_DATAINI .AND. TDV_DTREF <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR. ;
					TDV_DTREF <= RF_DATAINI .AND. TDV_DTREF >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) ;
				) ;
			) .OR. ( ;
				AllTrim(RF_DATAINI2) != '' .AND. ;
				( ;
					TDV_DTREF >= RF_DATINI2 .AND. TDV_DTREF <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
					TDV_DTREF <= RF_DATINI2 .AND. TDV_DTREF >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) ;
				) ;
			) .OR. ( ;
				AllTrim(RF_DATAINI3) != '' .AND. ;
				( ;
					TDV_DTREF >= RF_DATINI3 .AND. TDV_DTREF <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
					TDV_DTREF <= RF_DATINI3 .AND. TDV_DTREF >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) ;
				) ;
			)

//Restrições RH GS
lRestri := !lAfasta .And. !lAdmiss .And. !lDemiss .And. !lFerias.And. lResRHTXB .And. !Empty(TXB_DTINI)

//Conflitos de agenda ABB
If !lAfasta .And. !lAdmiss .And. !lDemiss .And. !lFerias.And. !lRestri
	If IsInCallStack("At330ADtCfl")
		lConfl := At570CoflAg()
	ElseIf !Empty(ABB_DTINI)
		lConfl := .T.
	Endif
Endif

Return (lAfasta .Or. lAdmiss .Or. lDemiss .Or. lFerias .Or. lRestri .Or. lConfl)

/*/{Protheus.doc} At570ChkDm

Encapsula a função CheckDemis 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação

@simple At570ChkDm(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015 
@return lRet Boolean	 
 /*/
Function At570ChkDm(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := CheckDemis(cFilFun, cMat, dDataIni, dDataFim)
Return lRet

/*/{Protheus.doc} At570ChkAd

Encapsula a função CheckAdmis 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação

@simple At570ChkAd(cFilFun, cMat, dDataIni, dDataFim)
@since  25/02/2021
@return lRet Boolean	 
 /*/
Function At570ChkAd(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := CheckAdmis(cFilFun, cMat, dDataIni, dDataFim)
Return lRet

/*/{Protheus.doc} At570ChkAf

Encapsula a função CheckAfast 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@simple At570ChkAf(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015
@return lRet Boolean	 
/*/ 
Function At570ChkAf(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
Local lRet := CheckAfast(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
Return lRet

/*
{Protheus.doc} At570ChkFe

Encapsula a função CheckFeria 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação

@simple At570ChkFe(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015 
@return lRet Boolean	 
 */ 
Function At570ChkFe(cFilFun, cMat, dDataIni, dDataFim)
Local lRet := CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
Return lRet

/*
{Protheus.doc} At570ChkFe

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@simple At570CoflAg()
@since  18/05/2019
@return lRet Boolean	 
 */ 
Static Function At570CoflAg()
Local aPrjAgd  	:= AT330ArsSt("AATEAGEST")
Local lGSVERHR 	:= SuperGetMV("MV_GSVERHR",,.F.)
Local nHrIni   	:= 0
Local nHrFim   	:= 0
Local nAddABB	:= 0
Local nHrIniAge := 0
Local nHrFimAge	:= 0
Local nAddZZX	:= 0
Local lRet	   	:= .F.

If !Empty(aPrjAgd)

	nPos := Ascan(aPrjAgd,{|x| Alltrim(x[6]) == Alltrim(AA1_CODTEC) .And. x[2] == sTod(ABB_DTINI) .Or. x[2] == sTod(ABB_DTFIM) })

	If nPos > 0
		lRet := .T.

		If ( Empty(aPrjAgd[nPos,10]) .OR. aPrjAgd[nPos,11] <> '1') .AND.  ;
			lGSVERHR .And. (aPrjAgd[nPos,04] <> "FOLGA" .And. aPrjAgd[nPos,05] <> "FOLGA") 					

			nHrIniAge := Val(AtJustNum(aPrjAgd[nPos,04]))
			nHrFimAge := Val(AtJustNum(aPrjAgd[nPos,05]))

			nAddZZX := Iif(nHrIniAge >= nHrFimAge, 2400,0)	
					
			nHrIni := Val(AtJustNum(ABB_HRINI))
			nHrFim := Val(AtJustNum(ABB_HRFIM))
												
			nAddABB := Iif(nHrFim <= nHrIni, 2400,0)
			
			If 	( nHrIniAge >= nHrIni .AND.;
					nHrIniAge <= ( nHrFim + nAddABB ) ) ;
						.OR.;
				( ( nHrFimAge  + nAddZZX ) >= nHrIni .AND.;
					( nHrFimAge  + nAddZZX ) <= (nHrFim + nAddABB ));
						.OR.;
				( nHrIniAge <= nHrIni .AND.;
					( nHrFimAge + nAddZZX ) >= ( nHrFim + nAddABB ) )
					
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif
Endif

Return lRet

