#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA200A.ch'
#INCLUDE 'TOPConn.ch' 

#DEFINE LTMARCA  01 
#DEFINE LTCORBRW 02
#DEFINE LTFILORI 03
#DEFINE LTLOTNFC 04
#DEFINE LTDATLOT 05
#DEFINE LTHORLOT 06
#DEFINE LTQTDLOT 07
#DEFINE LTTIPLOT 08
#DEFINE LTSTALOT 09
#DEFINE LTRATEIO 10
#DEFINE LTBACRAT 11
#DEFINE LTCRIRAT 12
#DEFINE LTPRORAT 13
#DEFINE LTORIRAT 14
#DEFINE LTCALRAT 15
#DEFINE LTTABRAT 16
#DEFINE LTTIPRAT 17
#DEFINE LTTPLOTE 18 
#DEFINE LTNUMNFC 19
#DEFINE LTSERNFC 20
#DEFINE LTCLIREM 21
#DEFINE LTLOJREM 22
#DEFINE LTNCONTR 23
#DEFINE LTCRDVFA 24
#DEFINE LTCRDVDC 25

#DEFINE NROCPOS  25 //-- Numero de campos da seleção de lotes (padrao)

Static lTM200AQRY	:= ExistBlock("TM200AQRY")

//-----------------------------------------------------
/*	Calculo de Frete para Varios Lotes
{Protheus.doc} TMSA200A
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		03/09/2013
@return 	Nil	  												  */
//------------------------------------------------------
Function TMSA200A()

Local   lPergunte := .F.
Local   aPerg 	 := {}                                             
Local   aListBox := {}
Local   lRateio	 := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local   aAreaDTC := DTC->(GetArea())

Private aLotMark  	:= {}	//-- Lotes Marcados
Private oDlg200a	:= Nil
Private oLB200A		:= Nil
Private oQtdLot		:= Nil
Private oQtdMrk		:= Nil
Private nQtdMrk		:= 0
Private nQtdLot		:= 0
Private oLoteMrk	:= Nil
Private _cLotePesq	:= Space( TamSX3("DTP_LOTNFC")[1] )
Private oMrkLote	:= Nil

Private aGrpRat := {  0 ,;	//-- [01] - Qtd. Selecionados
						 "",;	//-- [02] - DTP_BACRAT
						 "",;	//-- [03] - DTP_CRIRAT
						 "",;	//-- [04] - DTP_PRORAT
						 "",;	//-- [05] - DTP_ORIRAT
						 "",;	//-- [06] - DTP_CALRAT
						 "",;	//-- [07] - DTP_TABRAT
						 "",;	//-- [08] - DTP_TIPRAT
						 "",;	//-- [09] - DTP_NCONTR  ->  No.Contrato Cli.Dev.
						 "",;	//-- [10] - DTP_CRDVFA  ->  Criterio Devedor Faltante
						 "" }	//-- [11] - DTP_CRDVDC  ->  Criterio Prop.Vlr. Coleta

lPergunte := Pergunte("TMA200A",.T.)
If lPergunte
	//-- Array com informacoes passadas pelo pergunte do TMA200A(Tipo Lote, Lote De, Lote Ate, Data de, Data Ate, Status do Lote)
	Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05), Mv_Par06, Iif(lRateio, AllTrim(Str(Mv_Par07)), "") })
EndIf	

If !Empty(aPerg)
	CursorWait()
	T200ALIST(@aListBox, aPerg)
	T200ALot(aListBox)
	CursorArrow()
Else
	Return Nil	
EndIf

//-- Atualiza tela do lote de notas fiscais quando vindo de lá
If Type("oBrowseUp") != "U"
	If FindFunction("TMSA170Ref") .And. IsInCallStack('TMSA170')
		TMSA170Ref()
	EndIf
EndIf

RestArea(aAreaDTC)

Return Nil	


//-----------------------------------------------------
/*	Rotina de exibição dos Lotes a serem processados
{Protheus.doc} T200ALot
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		04/09/2013
@return 	Nil	  												  */
//------------------------------------------------------
//-- Tela Principal
Static Function T200ALot(aListBox)

Local lNewDlg 	 := .F.
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}  

Local oBtn01
Local oBtn02
Local oBtn03
Local oBtn04
Local oBtn05
Local oBtn06
Local bLineBkp        
Local lRateio	 := DTP->(ColumnPos("DTP_RATEIO")) > 0

Private cCadastro	:= STR0001//'Selecionar Lotes'
Private lAllMark 	:= .F.   // Usado para o controle da marca de todos os documentos
Private aPedBlq  	:= {}
Private _lMarkLote	:= .T.

Default aListBox := {}

TmsCxTabFer() // Cria arquivo temporario no banco para armazenar Feriados Municip. e Regionais

If Type("oDlg200a") != "O"

	CursorArrow()
	aSize    := MsAdvSize(.F. )
	aObjects := {}
		
	AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 020, .F., .F. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
	DEFINE MSDIALOG oDlg200a TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
		
		lNewDlg := .T.
		
		oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg200a,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

		//CABEÇALHO DA TELA DE SELEÇÃO DE LOTES		

		@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0002 SIZE 168, 08; //-- Marca/Desmarca Todos
		ON CLICK(T200AMkAll(aListBox)) OF oPanel PIXEL              
		@ 007,090 SAY STR0003 OF oPanel PIXEL //--"Qtde. Total de Lotes: "
		If !Empty(aListBox[1,LTLOTNFC])
			nQtdLot := Len(aListBox)
		EndIf
		
		@ 005,157 MSGET oQtdLot VAR nQtdLot OF oPanel PIXEL PICTURE '@E 999,999,999'
		@ 007,230 SAY STR0004  OF oPanel PIXEL //--"Qtde. de Lotes Marcados: "
		@ 005,311 MSGET oQtdMrk VAR nQtdMrk OF oPanel PIXEL PICTURE '@E 999,999,999'		
		
		@ 007,378 SAY STR0053  OF oPanel PIXEL //--"Pesquisa Lote:"
		@ 005,451 MSGET oLoteMrk VAR _cLotePesq OF oPanel PIXEL PICTURE PesqPict("DTP","DTP_LOTNFC") VALID VldLotePsq(aListBox,_cLotePesq)
		@ 005,524 CHECKBOX oMrkLote VAR _lMarkLote PROMPT STR0054 SIZE 168, 08; //-- Marca lote pesquisado
		ON CLICK(VldLotePsq(aListBox,_cLotePesq))  OF oPanel PIXEL              
		
		//-- Cabecalho dos campos do Monitor.                                    
		If lRateio                    
			@ aPosObj[2,1],aPosObj[2,2]	LISTBOX	oLB200A;
										Fields	HEADER	"",;															//-- 01		
														"",;															//-- 02 
												AllTrim(STR0005),;													//-- 03 "Filial Origem"
												AllTrim(STR0006),;													//-- 04 "No.Lote"
												AllTrim(STR0007),;													//-- 05 "Data Lote"
												AllTrim(STR0008),;													//-- 06 "Hora Lote"
												AllTrim(STR0009),;													//-- 07 "Qtd.Docs."
												AllTrim(STR0010),;													//-- 08 "Tipo Lote"
												"Status",;																//-- 09 
												AllTrim( Posicione( 'SX3', 2, 'DTP_RATEIO', 'X3_TITULO')),;		//-- 10 
												AllTrim( Posicione( 'SX3', 2, 'DTP_BACRAT', 'X3_TITULO')),;		//-- 11 
												AllTrim( Posicione( 'SX3', 2, 'DTP_CRIRAT', 'X3_TITULO')),;		//-- 12 
												AllTrim( Posicione( 'SX3', 2, 'DTP_PRORAT', 'X3_TITULO')),;		//-- 13 
												AllTrim( Posicione( 'SX3', 2, 'DTP_ORIRAT', 'X3_TITULO')),;		//-- 14 
												AllTrim( Posicione( 'SX3', 2, 'DTP_CALRAT', 'X3_TITULO')),;		//-- 15 
												AllTrim( Posicione( 'SX3', 2, 'DTP_TABRAT', 'X3_TITULO')),;		//-- 16 
												AllTrim( Posicione( 'SX3', 2, 'DTP_TIPRAT', 'X3_TITULO')),;		//-- 17 
												AllTrim( Posicione( 'SX3', 2, 'DTP_NCONTR', 'X3_TITULO')),;		//-- 18 
												AllTrim( Posicione( 'SX3', 2, 'DTP_CRDVFA', 'X3_TITULO')),;		//-- 19 
												AllTrim( Posicione( 'SX3', 2, 'DTP_CRDVDC', 'X3_TITULO'));		//-- 20 
								SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 
	    Else
	    	@ aPosObj[2,1],aPosObj[2,2]	LISTBOX	oLB200A;
										Fields	HEADER	"",;		
														"",;
												AllTrim(STR0005),;	//--"Filial Origem"
												AllTrim(STR0006),;	//--"No.Lote"
												AllTrim(STR0007),;	//--"Data Lote"
												AllTrim(STR0008),;	//--"Hora Lote"
												AllTrim(STR0009),;	//--"Qtd.Docs."
												AllTrim(STR0010);		//--"Tipo Lote"
								SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 
	    EndIf   
		oLB200A:SetArray( aListBox )
		oLB200A:bLDblClick := { || T200AMark(aListBox) }                              
		oLB200A:bLine      := { || {	Iif(aListBox[ oLB200A:nAT,LTMARCA ] == '1',LoadBitMap(GetResources(),"LBOK"),LoadBitMap(GetResources(),"LBNO")),;	
												aListBox[ oLB200A:nAT,LTCORBRW],;				
												aListBox[ oLB200A:nAT,LTFILORI ],;                      	
												aListBox[ oLB200A:nAT,LTLOTNFC],;
												aListBox[ oLB200A:nAT,LTDATLOT],;
												aListBox[ oLB200A:nAT,LTHORLOT],;
												aListBox[ oLB200A:nAT,LTQTDLOT],;
												aListBox[ oLB200A:nAT,LTTIPLOT],;
												aListBox[ oLB200A:nAT,LTSTALOT],;
												aListBox[ oLB200A:nAT,LTRATEIO],;
												aListBox[ oLB200A:nAT,LTBACRAT],;
												aListBox[ oLB200A:nAT,LTCRIRAT],;
												aListBox[ oLB200A:nAT,LTPRORAT],;
												aListBox[ oLB200A:nAT,LTORIRAT],;
												aListBox[ oLB200A:nAT,LTCALRAT],;
												aListBox[ oLB200A:nAT,LTTABRAT],;
												aListBox[ oLB200A:nAT,LTTIPRAT],;
												aListBox[ oLB200A:nAT,LTNCONTR],;
												aListBox[ oLB200A:nAT,LTCRDVFA],;
												aListBox[ oLB200A:nAT,LTCRDVDC]}}

	//-- Botoes da tela do monitor.
	@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 	PROMPT '&' +STR0011		ACTION TA200ALeg()				OF oDlg200a PIXEL SIZE 035,011	//-- "Legenda"
	@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 	PROMPT '&' +STR0012  	ACTION T200AProc(aListBox,1)	OF oDlg200a PIXEL SIZE 035,011	//-- "Calcular"
	@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn07 	PROMPT '&' +STR0048		ACTION T200AProc(aListBox,4)	OF oDlg200a PIXEL SIZE 035,011	//-- "Recalculo"
	@ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn03 	PROMPT '&' +STR0013		ACTION T200AProc(aListBox,2)  	OF oDlg200a PIXEL SIZE 035,011	//-- "Estornar"
	@ aPosObj[3,1],aPosObj[3,4] + 060 BUTTON oBtn04 	PROMPT '&' +STR0014 	ACTION T200AProc(aListBox,3)	OF oDlg200a PIXEL SIZE 035,011	//-- "Aglutinar"
	@ aPosObj[3,1],aPosObj[3,4] + 100 BUTTON oBtn05 	PROMPT '&' +STR0015		ACTION T200AParam(aListBox)		OF oDlg200a PIXEL SIZE 035,011	//-- "Parametros"
	@ aPosObj[3,1],aPosObj[3,4] + 140 BUTTON oBtn06 	PROMPT '&' +STR0016		ACTION oDlg200a:End()  			OF oDlg200a PIXEL SIZE 035,011	//-- "Sair"

		   			                                                    
Else

	oLB200A:SetArray( aListBox )                                                     
	oLB200A:bLine      := { || {	Iif(aListBox[ oLB200A:nAT,LTMARCA ] == '1',LoadBitMap(GetResources(),"LBOK"),LoadBitMap(GetResources(),"LBNO")),;	
											aListBox[ oLB200A:nAT,LTCORBRW],;				
											aListBox[ oLB200A:nAT,LTFILORI ],;
											aListBox[ oLB200A:nAT,LTLOTNFC],;
											aListBox[ oLB200A:nAT,LTDATLOT],;
											aListBox[ oLB200A:nAT,LTHORLOT],;
											aListBox[ oLB200A:nAT,LTQTDLOT],;
											aListBox[ oLB200A:nAT,LTTIPLOT],;
											aListBox[ oLB200A:nAT,LTSTALOT],;
											aListBox[ oLB200A:nAT,LTRATEIO],;
											aListBox[ oLB200A:nAT,LTBACRAT],;
											aListBox[ oLB200A:nAT,LTCRIRAT],;
											aListBox[ oLB200A:nAT,LTPRORAT],;
											aListBox[ oLB200A:nAT,LTORIRAT],;
											aListBox[ oLB200A:nAT,LTCALRAT],;
											aListBox[ oLB200A:nAT,LTTABRAT],;
											aListBox[ oLB200A:nAT,LTTIPRAT],;
											aListBox[ oLB200A:nAT,LTNCONTR],;
											aListBox[ oLB200A:nAT,LTCRDVFA],;
											aListBox[ oLB200A:nAT,LTCRDVDC]}}
	If !Empty(aListBox[1,LTLOTNFC])
		nQtdLot := Len(aListBox)
	Else
		nQtdLot := 0	
	EndIf          
	
	nQtdMrk := 0

	oLB200A:Refresh()
 	oLB200A:SetFocus()

EndIf                                                                 
If lNewDlg
	ACTIVATE MSDIALOG oDlg200a CENTERED
EndIf	

aCliRecno  := {}   //cache do SA1

Return ( Nil )

//-----------------------------------------------------
/*	Lista com os Lotes selecionados
{Protheus.doc} T200ALIST
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		03/09/2013
@return 	Nil	  												  */
//------------------------------------------------------
Static Function T200ALIST(aListBox,aPerg)

Local cQuery     := ''
Local cAlias     := GetNextAlias()
Local lRetorno   := .T.
Local oVerde     := LoadBitmap( GetResources(),'BR_VERDE'	)
Local oAmarelo   := LoadBitmap( GetResources(),'BR_AMARELO'	)
Local oVermelho  := LoadBitmap( GetResources(),'BR_VERMELHO'	)
Local oAzul      := LoadBitmap( GetResources(),'BR_AZUL'		)
Local oLaranja   := LoadBitmap( GetResources(),'BR_LARANJA'	)
Local oCor       := {}
Local nPosMrk    := 0
Local nPosIni    := 0
Local nTamIni    := 0
Local nI         := 0                           
Local cStatus    := ''
Local lRateio    := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lCmpRatNew := DTP->(ColumnPos("DTP_CRDVDC")) > 0
Local aRateio    := Iif ( lRateio, RetSx3Box( Posicione('SX3', 2, 'DTP_RATEIO', 'X3CBox()' ),,, Len(DTP->DTP_RATEIO)), {} )
Local aBACRAT	 := Iif ( lRateio, RetSx3Box( Posicione('SX3', 2, 'DTP_BACRAT', 'X3CBox()' ),,, Len(DTP->DTP_BACRAT)), {} )
Local aCRIRAT	 := Iif ( lRateio .And. !lCmpRatNew, RetSx3Box( Posicione('SX3', 2, 'DTP_CRIRAT', 'X3CBox()' ),,, Len(DTP->DTP_CRIRAT)), {} )
Local aPRORAT	 := Iif ( lRateio .And. !lCmpRatNew, RetSx3Box( Posicione('SX3', 2, 'DTP_PRORAT', 'X3CBox()' ),,, Len(DTP->DTP_PRORAT)), {} )
Local aCRDVDC	 := Iif ( lRateio .And. DTP->(ColumnPos("DTP_CRDVDC")) > 0, RetSx3Box( Posicione('SX3', 2, 'DTP_CRDVDC', 'X3CBox()' ),,, Len(DTP->DTP_CRDVDC)), {""} )
Local aCRDVFA	 := Iif ( lRateio .And. DTP->(ColumnPos("DTP_CRDVFA")) > 0, RetSx3Box( Posicione('SX3', 2, 'DTP_CRDVFA', 'X3CBox()' ),,, Len(DTP->DTP_CRDVFA)), {""} )
Local cWhere	 := ""
Local cTM200Qry	 := ""

Default aListBox := {}
Default aPerg := {}

If lRateio .And. lCmpRatNew	
	 aCRIRAT:= TMSValField("DTP_CRIRAT",.F.,,.F.,.T.) 
	 aPRORAT:= TMSValField("DTP_PRORAT",.F.,,.F.,.T.) 
EndIf

If !Empty(aPerg)

	DbSelectArea("DTP")
	DbSetOrder(1)

	cStatus := AllTrim(Str(aPerg[1,6]+1))
	//-- Select para lista todos os Doc. do Painel.
	cQuery := "SELECT DTP_FILORI,DTP_LOTNFC,DTP_TIPLOT,DTP_DATLOT,DTP_HORLOT, DTP_QTDLOT, DTP_STATUS, DTP.R_E_C_N_O_ DTPRECNO"

	If lRateio 
		cQuery += " , DTP_RATEIO " 
		cQuery += " , DTP_BACRAT "
		cQuery += " , DTP_CRIRAT " 
		cQuery += " , DTP_PRORAT " 
		cQuery += " , DTP_ORIRAT " 
		cQuery += " , DTP_CALRAT " 
		cQuery += " , DTP_TABRAT " 
		cQuery += " , DTP_TIPRAT "
		If DTP->(ColumnPos("DTP_NCONTR")) > 0
		   cQuery += " , DTP_NCONTR "
		EndIf
		If DTP->(ColumnPos("DTP_CRDVFA")) > 0
		   cQuery += " , DTP_CRDVFA "
		EndIf
		If DTP->(ColumnPos("DTP_CRDVDC")) > 0
		   cQuery += " , DTP_CRDVDC "
		EndIf
	EndIf	 

	cWhere := " FROM " + RetSqlName( 'DTP' ) + " DTP "
	
	//Chamado TUFAKE - Reposicionamento deste comando, para fixar o WHERE nele.
	// Também foram efetuadas correções nas validações do intervalo de lotes e intervalo de datas.

	cWhere += " WHERE DTP_FILIAL = '" + xFilial('DTP') + "'"
	cWhere += " AND DTP_FILORI = '" + cFilAnt  + "'"
		
	If !Empty(aPerg[1,2])
		If !Empty(aPerg[1,3])
			cWhere += " AND DTP_LOTNFC BETWEEN '" + aPerg[1,2] + "' AND '" + aPerg[1,3] + "' "	
		Else
			cWhere += " AND DTP_LOTNFC >= '" + aPerg[1,2] + "' "
		EndIf
	Else
		If !Empty(aPerg[1,3])
			cWhere += " AND DTP_LOTNFC <= '" + aPerg[1,3] + "' "
		EndIf
	EndIf	
	
	If !Empty(aPerg[1,4])
		If !Empty(aPerg[1,5])
			cWhere += " AND DTP_DATLOT BETWEEN '" + aPerg[1,4] + "' AND '" + aPerg[1,5] + "' "	
		Else
			cWhere += " AND DTP_DATLOT >= '" + aPerg[1,4] + "' "
		EndIf
	Else
		If !Empty(aPerg[1,5])
			cWhere += " AND DTP_DATLOT <= '" + aPerg[1,5] + "' "
		EndIf
	EndIf
                                  
	If aPerg[1,1] <> 4
		cWhere += " AND DTP_TIPLOT = '" + AllTrim(Str(aPerg[1,1])) + "' "
	Else
		cWhere += " AND DTP_TIPLOT <> '4' "		
	EndIf
	cWhere += " AND DTP_TIPLOT <> '5' " //-- Nunca Apresentar Lotes Do Tipo '5' Coleta.

	If aPerg[1,6] <> 5
		cWhere += " AND   DTP_STATUS = '" + cStatus + "' "      	
	Else
		cWhere += " AND DTP_STATUS <> '1'"
	EndIf	

	If lRateio
		If aPerg[1,7] == StrZero(1, Len(DTP->DTP_RATEIO))
			cWhere += " AND DTP_RATEIO = '" + aPerg[1,7] + "' "
		Else
			//Chamado TUFAKE - Inclusão de parenteses no comando SQL.
			cWhere += " AND (DTP_RATEIO = '" + aPerg[1,7] + "' OR DTP_RATEIO = '')"
		EndIf
	EndIf	

	cWhere += " AND DTP.D_E_L_E_T_ = ' ' "
	
	//Chamado TVKIS1 - Garante que sejam apresentados apenas os lotes que contenham notas
	cWhere += " AND EXISTS (SELECT 1 "
	cWhere += "               FROM " + RetSqlName("DTC") + " DTC "
	cWhere += "              WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
	cWhere += "                AND DTC.DTC_FILORI = DTP.DTP_FILORI "
	cWhere += "                AND DTC.DTC_LOTNFC = DTP.DTP_LOTNFC "
	cWhere += "                AND DTC.D_E_L_E_T_ = ' ') "
	
	
	Pergunte("TMA200A",.F.)
	If lTM200AQRY
		cTM200Qry	:= ExecBlock("TM200AQRY",.F.,.F.,{ cWhere })
		
		If "FROM" $ cTM200Qry
			cWhere	:= cTM200Qry
		Else
			cWhere	+= cTM200Qry
		EndIf
		
	EndIF
	
	cWhere += " ORDER BY " + SqlOrder(DTP->(IndexKey()))
	cQuery	+= cWhere
	
	//-- Executa Parse Na Expressão
	cQuery := ChangeQuery(cQuery)	
	
	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlias, .T., .F. )
	TcSetField(cAlias,"DTP_DATLOT", "D", 8, 0)	

	If !(cAlias)->(Eof())
		While (!(cAlias)->(Eof()))
	
			//-- De acordo com a situacao do lote, seleciona uma determinada cor p/ o Objeto.
			DTP->(dbGoTo((cAlias)->DTPRECNO))
			Do Case
				Case (cAlias)->DTP_STATUS == StrZero(1,Len(DTP->DTP_STATUS))	//-- 1 Em Aberto
					oCor:= oAmarelo
				Case (cAlias)->DTP_STATUS == StrZero(2,Len(DTP->DTP_STATUS))	//-- 2 Digitado
					oCor	:= oVerde  
				Case (cAlias)->DTP_STATUS == StrZero(3,Len(DTP->DTP_STATUS))	//-- 3 Calculado
					oCor	:= oAzul    
				Case (cAlias)->DTP_STATUS == StrZero(4,Len(DTP->DTP_STATUS))//-- 4 Bloqueado
					oCor	:= oVermelho
				Case (cAlias)->DTP_STATUS == StrZero(5,Len(DTP->DTP_STATUS))//-- 5 Erro de Gravacao
					oCor	:= oLaranja
			EndCase
			
			Aadd(aListBox,Array(NROCPOS))
	
			nPosMrk := Ascan(aLotMark,{ | e | e[1]+e[2] == (cAlias)->DTP_FILORI+(cAlias)->DTP_LOTNFC })  
			aListBox[Len(aListBox),LTMARCA]  := Iif(nPosMrk == 0 ,'2',aLotMark[nPosMrk,3])
			aListBox[Len(aListBox),LTCORBRW] := oCor
			aListBox[Len(aListBox),LTFILORI] := (cAlias)->DTP_FILORI
			aListBox[Len(aListBox),LTLOTNFC] := (cAlias)->DTP_LOTNFC
			aListBox[Len(aListBox),LTDATLOT] := (cAlias)->DTP_DATLOT
			aListBox[Len(aListBox),LTHORLOT] := Transform((cAlias)->DTP_HORLOT,X3Picture("DTP_HORLOT"))
			aListBox[Len(aListBox),LTQTDLOT] := (cAlias)->DTP_QTDLOT
			aListBox[Len(aListBox),LTTIPLOT] := IIf((cAlias)->DTP_TIPLOT == '1',STR0017,IIf((cAlias)->DTP_TIPLOT == '2',STR0018,STR0019))//--'Normal'//--'Refaturamento'//--'Eletronico'
			aListBox[Len(aListBox),LTSTALOT] := (cAlias)->DTP_STATUS
			aListBox[Len(aListBox),LTRATEIO] := Iif(lRateio, AllTrim( aRateio[ Ascan( aRateio, { |x| x[ 2 ] == DTP->DTP_RATEIO} ), 3 ]), "")
			aListBox[Len(aListBox),LTBACRAT] := Iif(lRateio, AllTrim( aBACRAT[ Ascan( aBACRAT, { |x| x[ 2 ] == DTP->DTP_BACRAT} ), 3 ]), "")
			aListBox[Len(aListBox),LTCRIRAT] := Iif(lRateio .And. lCmpRatNew , AllTrim( aCRIRAT[ Ascan( aCRIRAT, { |x| x[ 1 ] == DTP->DTP_CRIRAT} ), 2 ]), "")
			aListBox[Len(aListBox),LTPRORAT] := Iif(lRateio .And. lCmpRatNew , AllTrim( aPRORAT[ Ascan( aPRORAT, { |x| x[ 1 ] == DTP->DTP_PRORAT} ), 2 ]), "")
			aListBox[Len(aListBox),LTORIRAT] := Iif(lRateio, DTP->DTP_ORIRAT, "")
			aListBox[Len(aListBox),LTCALRAT] := Iif(lRateio, DTP->DTP_CALRAT, "")
			aListBox[Len(aListBox),LTTABRAT] := Iif(lRateio, DTP->DTP_TABRAT, "")
			aListBox[Len(aListBox),LTTIPRAT] := Iif(lRateio, DTP->DTP_TIPRAT, "")
			aListBox[Len(aListBox),LTTPLOTE] := Alltrim((cAlias)->DTP_TIPLOT)
			aListBox[Len(aListBox),LTNCONTR] := Iif(lRateio .And. DTP->(ColumnPos("DTP_NCONTR")) > 0, DTP->DTP_NCONTR, "")
			aListBox[Len(aListBox),LTCRDVFA] := Iif(lRateio .And. DTP->(ColumnPos("DTP_CRDVFA")) > 0, AllTrim( aCRDVFA[ Ascan( aCRDVFA, { |x| x[ 2 ] == DTP->DTP_CRDVFA} ), 3 ]), "")
			aListBox[Len(aListBox),LTCRDVDC] := Iif(lRateio .And. DTP->(ColumnPos("DTP_CRDVDC")) > 0, AllTrim( aCRDVDC[ Ascan( aCRDVDC, { |x| x[ 2 ] == DTP->DTP_CRDVDC} ), 3 ]), "")
	
			(cAlias)->(DbSkip())
	
			If Len(aListBox) >= 32600
				MsgAlert (STR0020)//--'Qtd. de Lotes Informados excede a quantidade permitida para exibição.'
				Exit
			EndIf
	
		EndDo
	Else
		Aadd(aListBox,Array(NROCPOS))
		aListBox[Len(aListBox),LTMARCA ] := '2'
		aListBox[Len(aListBox),LTCORBRW] := ''
		aListBox[Len(aListBox),LTLOTNFC] := ''
		aListBox[Len(aListBox),LTDATLOT] := ''
		aListBox[Len(aListBox),LTHORLOT] := ''
		aListBox[Len(aListBox),LTQTDLOT] := ''
		aListBox[Len(aListBox),LTTIPLOT] := ''	
		aListBox[Len(aListBox),LTSTALOT] := ''	
		aListBox[Len(aListBox),LTRATEIO] := ''
		aListBox[Len(aListBox),LTBACRAT] := ''
		aListBox[Len(aListBox),LTCRIRAT] := ''
		aListBox[Len(aListBox),LTPRORAT] := ''
		aListBox[Len(aListBox),LTORIRAT] := ''
		aListBox[Len(aListBox),LTCALRAT] := ''
		aListBox[Len(aListBox),LTTABRAT] := ''
		aListBox[Len(aListBox),LTTIPRAT] := ''
		aListBox[Len(aListBox),LTNCONTR] := ''
		aListBox[Len(aListBox),LTCRDVFA] := ''
		aListBox[Len(aListBox),LTCRDVDC] := ''
	EndIf
	(cAlias)->(dbCloseArea())
EndIf	

Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ta200ALeg ³ Autor ³Leandro Paulino			³Data ³03.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina da Legenda do Filtro da Rotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ta200ALeg()

BrwLegenda( STR0021, STR0022,;			//--	"Status do Doc." # "Status"
			{{'BR_VERDE' , STR0023 },; 	//-- "Digitado"
			{'BR_AZUL'   , STR0024 },;    //-- "Calculado"
			{'BR_VERMELHO',STR0025 },; 	//-- "Bloqueado"
			{'BR_LARANJA',STR0026 }}) 	//-- "Erro Gravacao"

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ T200AMark  Autor ³ Leandro Paulino      ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca as rotinas no listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ T200AMark()    	                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA200A			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T200AMark(aListBox,nItem,lRefresh,lUmItem)

Local nPosMrk   := 0
Local nDocMrk   := 0		
Local nPosic    := 0
Local lRateio   := .F.
Local lCamposRat:= DTP->(ColumnPos("DTP_RATEIO")) > 0

Default nItem   := oLB200A:nAt
Default lRefresh:= .T.
Default lUmItem := .T.

If lCamposRat
	Pergunte("TMA200A",.F.)
	lRateio := Iif(AllTrim(Str(Mv_Par07)) == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
EndIf
	
If !Empty(aListBox[1,LTLOTNFC])
	
	If lUmItem
		aListBox[nItem,LTMARCA] := Iif(aListBox[nItem,LTMARCA] == '1','2','1')
		If(aListBox[nItem,LTMARCA]) == '1'
			nQtdMrk		+= 1
			
			If lRateio

				If nQtdMrk == 1
					aGrpRat[01] += 1
					aGrpRat[02] := aListBox[nItem, LTBACRAT]
					aGrpRat[03] := aListBox[nItem, LTCRIRAT]
					aGrpRat[04] := aListBox[nItem, LTPRORAT]
					aGrpRat[05] := aListBox[nItem, LTORIRAT]
					aGrpRat[06] := aListBox[nItem, LTCALRAT]
					aGrpRat[07] := aListBox[nItem, LTTABRAT]
					aGrpRat[08] := aListBox[nItem, LTTIPRAT]
					aGrpRat[09] := aListBox[nItem, LTNCONTR]
					aGrpRat[10] := aListBox[nItem, LTCRDVFA]
					aGrpRat[11] := aListBox[nItem, LTCRDVDC]					
	
				ElseIf nQtdMrk > 1
					If	(aGrpRat[02] == aListBox[nItem, LTBACRAT]) .And.;
						(aGrpRat[03] == aListBox[nItem, LTCRIRAT]) .And.;
						(aGrpRat[04] == aListBox[nItem, LTPRORAT]) .And.;
						(aGrpRat[05] == aListBox[nItem, LTORIRAT]) .And.;
						(aGrpRat[06] == aListBox[nItem, LTCALRAT]) .And.;
						(aGrpRat[07] == aListBox[nItem, LTTABRAT]) .And.;
						(aGrpRat[08] == aListBox[nItem, LTTIPRAT]) .And.;
						(aGrpRat[09] == aListBox[nItem, LTNCONTR]) .And.;
						(aGrpRat[10] == aListBox[nItem, LTCRDVFA]) .And.;
						(aGrpRat[11] == aListBox[nItem, LTCRDVDC])
						aGrpRat[01] += 1
					Else
						Help("",1,"TMSA200A01") //-- Item Não Pertence Ao Conjunto de Agrupamentos Do(s) Lote(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Rateio.
						aListBox[nItem,LTMARCA] := '2'
						nQtdMrk	-= 1
					EndIf			
				EndIf
			EndIf
 
		ElseIf(aListBox[nItem,LTMARCA]) == '2'		
			If nQtdMrk > 0
				nQtdMrk		-= 1
				aGrpRat[01] -= Iif(lRateio, 1, 0)
				
				If lRateio .And. aGrpRat[01] == 0
					aGrpRat[02] := ""
					aGrpRat[03] := ""
					aGrpRat[04] := ""
					aGrpRat[05] := ""
					aGrpRat[06] := ""
					aGrpRat[07] := ""
					aGrpRat[08] := ""
					aGrpRat[09] := ""
					aGrpRat[10] := ""
					aGrpRat[11] := ""
				EndIf
			EndIf	
		EndIf	
	Else		   
		If lAllMark
			If lRateio
				If aGrpRat[01] > 0
					If	(aGrpRat[02] == aListBox[nItem, LTBACRAT]) .And.;
						(aGrpRat[03] == aListBox[nItem, LTCRIRAT]) .And.;
						(aGrpRat[04] == aListBox[nItem, LTPRORAT]) .And.;
						(aGrpRat[05] == aListBox[nItem, LTORIRAT]) .And.;
						(aGrpRat[06] == aListBox[nItem, LTCALRAT]) .And.;
						(aGrpRat[07] == aListBox[nItem, LTTABRAT]) .And.;
						(aGrpRat[08] == aListBox[nItem, LTTIPRAT]) .And.;
						(aGrpRat[09] == aListBox[nItem, LTNCONTR]) .And.;
						(aGrpRat[10] == aListBox[nItem, LTCRDVFA]) .And.;
						(aGrpRat[11] == aListBox[nItem, LTCRDVDC])
						aGrpRat[01] += 1
						aListBox[nItem,LTMARCA] := '1'
						nQtdMrk		+= 1
					Else
						aListBox[nItem,LTMARCA] := '2'
					EndIf			
				EndIf

			Else
				aListBox[nItem,LTMARCA] := '1'
				nQtdMrk		+= 1
				aGrpRat[01] += Iif(lRateio, 1, 0)
			EndIf

		Else
			aListBox[nItem,LTMARCA] := '2'
			nQtdMrk		:= 0
			aGrpRat[01] := 0
		EndIf                                                                      
	EndIf
	nPosMrk := Ascan(aLotMark,{ | e | e[1]+e[2] == aListBox[nItem,LTFILORI]+aListBox[nItem,LTLOTNFC] })
	If nPosMrk == 0
		Aadd(aLotMark,{ aListBox[nItem,LTFILORI], aListBox[nItem,LTLOTNFC], '' })
		nPosMrk := Len(aLotMark)
	EndIf
	aLotMark[nPosMrk,3] := aListBox[nItem,LTMARCA]
	If lRefresh	
		oLB200A:Refresh()
		oQtdMrk:Refresh()
	EndIf
EndIf		 
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ T200AMkAll ³ Autor ³ Leandro Paulino     ³ Data ³03.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todas as rotinas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ T200AMkAll()    		                                      ³±±           		
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA2000A		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T200AMkAll(aListBox)
    Local nI        := 0
    Local lRefresh  := .T.
    Local lUmItem   := .F.
    Local lRateio   := .F.
    Local lCamposRat:= DTP->(ColumnPos("DTP_RATEIO")) > 0
    Local nPos		:= 0

	If lCamposRat
		Pergunte("TMA200A",.F.)
		lRateio := Iif(AllTrim(Str(Mv_Par07)) == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
	EndIf	
	
	If lRateio .And. aGrpRat[01] == 0 .And. lAllMark
		MsgAlert(STR0050 + CHR(13) + CHR(10) + STR0051) // Para seleção de TODOS os itens, se faz necessário ao menos // selecionar um item para definir o Conjunto de Agrupamento !!
		lAllMark := .F.
		oLB200A:Refresh()
	Else
		CursorWait()
		
		nQtdMrk := 0
		
		For nI := 1 To Len(aListBox)
			T200AMark(aListBox,nI,lRefresh,lUmItem)
		Next nI	
		
		CursorArrow()	
	EndIf

Return
               
/*	Efetua o calculo, estorno ou aglutinacao do Lote
{Protheus.doc} T200AProc
@author  	Leandro Paulino
@version 	P12 R1
@build		7.00.111010P
@since 		02/09/2013
@return 	Nil 			  			                        */
//------------------------------------------------------
Function T200AProc(aListBox,nAcao,nOpcx,lAuto)

Local aArea  		:= GetArea()
Local aLotes		:= {}            
Local aLotesGrv		:= {}        
Local aDocExcMot	:= {} 
Local aDocExc		:= {}    
Local nDocto 		:= 0              
Local nTamDocto		:= 0       
Local aDelDocto		:= {}
Local lRet			:= .T.
Local nQtdLotTp		:= 0
Local cTipLot  		:= ''
Local cTipDocMot    := SuperGetMv("MV_DMOTEST",.F.," ") //Tipos de documentos que pede motivo
Local aMsgErr		:= {}
Local cAlias		:= ''
Local cStatus		:= ''     
Local nI 			:= 0
Local nQtdLotMrk 	:= 0
Local aListLotes	:= {} //Array dos Lotes Marcados
Local lRefresh		:= .F.                 
Local aSays			:= {}
Local aButtons  	:= {}
Local nOPca			:= 5
Local lEstorna		:= .T.                                                           
Local aMsgErro		:= {}
Local cNumViag		:= ''
Local lLotMesc		:= .F. // Lote Mesclado com tipo NORMAL e ELETRONICO ?
Local aTpLote		:= {}
Local nPosicao		:= 0
Local lCompl		:= .F.
              
Default aListBox	:= {}
Default nAcao		:= 1                            
Default lAuto		:= .F.

//-- Fil.Docto + Docto + Serie
aListLotes  := AClone(aListBox)
ASort( aListLotes,,,{|x,y| x[ LTMARCA ] + x[ LTFILORI ] + x[ LTLOTNFC ] < y[ LTMARCA] + y[ LTFILORI ] + y[ LTLOTNFC ] })

For nI := 1 To Len(aListLotes)
	If aListLotes[nI,LTMARCA] == '2'
		Exit
	Else
		nPosicao := Ascan( aLotes, {|x| x[01]+x[02] == aListLotes[nI,LTFILORI] + aListLotes[nI,LTLOTNFC] })
		If nPosicao == 0
			Aadd(aLotes,{aListLotes[nI,LTFILORI],aListLotes[nI,LTLOTNFC],aListLotes[nI,LTTIPLOT],aListLotes[nI,LTSTALOT]})
			nQtdLotMrk++	
		EndIf
		
		lRefresh := .T.
		nPosicao := Ascan( aTpLote, {|x| x[01] == aListLotes[nI,LTTPLOTE] })
		
		If nPosicao == 0
			Aadd( aTpLote, { aListLotes[nI,LTTPLOTE], 1 } )
		Else
			aTpLote[nPosicao][02] += 1
		EndIf
	EndIf
Next nI 
lLotMesc := Iif( Len(aTpLote) > 1, .T., .F.) // Caso existam mais de um Tipo de Lote selecionado
If nQtdLotMrk > 0
	nTamDocto := Len(aLotes)
	If nAcao == 1 .Or. nAcao == 4  //Calcula//Recalculo
		If !lAuto	
			AAdd( aSays, STR0027 ) //'Este programa tem como objetivo, gerar documentos para cobran‡a de frete, a '
			AAdd( aSays, STR0028 ) //'partir de c lculos efetuados atrav‚s da tabela de frete, contida no contrato '
			AAdd( aSays, STR0029 ) //'de cada cliente. '
	
	                                                  
			AAdd( aButtons, { 1, .T., {|o| lRet := T200APrpLt(aLotes,nAcao), nOpca:= 1, o:oWnd:End() } } )
			AAdd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
			FormBatch( STR0030, aSays, aButtons )//'Calculo de Frete'
		Else
			T200APrpLt(aLotes,nAcao)
		EndIf	
	ElseIf nAcao == 2 //Estorna
		If !lAuto
			AAdd( aSays, STR0031) //'Este programa tem como objetivo, efetuar o estorno do calculo'
			AAdd( aSays, STR0032) //'Nao sera permitido estornar lotes que ja tenham conhecimentos'
			AAdd( aSays, STR0033) //'associados a uma viagem. '
		
			AAdd( aButtons, { 1, .T., {|o| nOpcA := 5, o:oWnd:End() } } )
			AAdd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
		
			FormBatch( STR0034, aSays, aButtons ) //'Estorno Calculo Frete'
		Else
			nOpcA := 5
		EndIf
	
	 	If nOpca == 5
	 	
			 If Empty(aDocExc) .AND. FindFunction("TMSA200C") .AND. FindFunction("TM200TipDo")  .AND. FWAliasInDic("DLX",.F.) 
			 	aDocExc := Tm200aDocX(aLotes)
				If !Empty(cTipDocMot) .AND. TM200TipDo( aDocExc ,cTipDocMot)
					If !(TMSA200C(aDocExc,@aDocExcMot,cTipDocMot)) //Chama tela de motivo de cancelamento de documentos
						lRet:= .F.
					Endif
				EndIf
			Endif
			If lRet
				//Necessario Buscar Todos os documentos dos Lotes escolhidos.
				DT6->(dbSetOrder(2))  
				dbSelectArea('DT6')         
				For nDocto := 1 To nTamDocto
					lEstorna := .T.
					If DT6->(dbSeek(xFilial('DT6')+aLotes[nDocto,1]+aLotes[nDocto,2]))					  
						If DT6->DT6_DOCTMS <> StrZero(8,Len(DT6->DT6_DOCTMS))
							/*VERIFICA SE NO LOTE EXISTE ALGUM DOCTO EM VIAGEM*/
							DUD->(DbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
							If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+cFilAnt))
								While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE + DUD->DUD_FILORI == ;
									xFilial("DUD") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE + cFilAnt
									If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
										If !Empty(DUD->DUD_VIAGEM)
											lEstorna := .F.
											Exit
										EndIf
									EndIf
									DUD->(DbSkip())
								EndDo					
							EndIf
						Else					   
						   lEstorna := .F.
						   lCompl   := .T.
						   AAdd( aMsgErr, {STR0044 + aLotes[nDocto,2] +  STR0052 , '04' , 'TMSA200A()'} ) //"O Lote //" nao sera estornado, pois possui Conhecimento associado a uma viagem"
						EndIf
						If !lCompl
							If !lEstorna 
								AAdd( aMsgErr, {STR0044 + aLotes[nDocto,2] +  STR0045 , '04' , 'TMSA200A()'} ) //"O Lote //" nao sera estornado, pois possui Conhecimento associado a uma viagem"
							Else
								While DT6->(!Eof()) .And. (DT6->(DT6_FILIAL+DT6_FILORI+DT6_LOTNFC) == xFilial('DT6')+aLotes[nDocto,1]+aLotes[nDocto,2])
									Aadd(aDelDocto,{DT6_FILORI,DT6_DOC,DT6_SERIE,,.T.,'2'})     
									DT6->(dbSkip())
								EndDo						
							EndIf		
						EndIf										
						If !Empty(aDelDocto)					
							Processa({|| lRet := TMSA200Exc( aDelDocto, aLotes[nDocto,2],, .F.,,,,aDocExcMot)},STR0035,STR0036)//--Procesamento Lote//--'Estornando conhecimento de frete...'
							If lRet
								Processa({|| lRet := TMSA200Sta(.F., aLotes[nDocto,2], StrZero(2,Len(DTP->DTP_STATUS)) ) }, STR0035,STR0037, .F. ) //"Processamento Lote"//'Atualizando Status do Lote...'
							EndIf	          
						EndIf
					ElseIf aLotes[nDocto,4] <> '2' //Status diferente de digitado efetua Estorno
						//Altera Status do Lote para Digitado para permitir Calculo novamente.
						If lRet
							Processa({|| lRet := TMSA200Sta(.F., aLotes[nDocto,2], StrZero(2,Len(DTP->DTP_STATUS)) ) }, STR0035,STR0037, .F. ) //"Processamento Lote"//'Atualizando Status do Lote...'
						EndIf			
					EndIf		
				Next
			EndIf
		EndIf	
	ElseIf nAcao == 3 //Aglutinar	
	   
		If nQtdLotMrk > 1
			If MsgYesNo(STR0043) //--'Tem certeza que deseja algutinar os lotes marcados?'
				DTP->(dbSetOrder(2))
				aSort( aLotes,,,{ |x,y| x[3]+x[2]+x[1] < y[3]+y[2]+y[1] } )
				For nDocto := 1 To nTamDocto		
					If TmsExp()		
						If DTP->(dbSeek(xFilial('DTP')+aLotes[nDocto,1]+aLotes[nDocto,2])) .And.  aLotes[nDocto,4] == '2' 	//--Verifica se os lotes estão sem viagens ou se fazem parte da mesma viagem.
							If nDocto > 1
								If cNumViag <> DTP->DTP_VIAGEM
									AAdd( aMsgErr, {STR0047, '04' , 'TMSA200A()'} ) //"Lote //" " não será aglutinado, pois o mesmo não está com o status: 'Digitado'.""
									aLotesGrv := {}       						
									Exit
								EndIf	
							EndIf					
							cNumViag := DTP->DTP_VIAGEM						
						EndIf
					EndIf		
					If aLotes[nDocto,4] <> '2' //--Verifica se o status dos lotes é digitado
						AAdd( aMsgErr, {STR0038 + ' ' + aLotes[nDocto,2] + ' ' + STR0046 , '04' , 'TMSA200A()'} ) //"Lote //" " não será aglutinado, pois o mesmo não está com o status: 'Digitado'.""					
					Else
						nQtdLotTp ++           
						Aadd(aLotesGrv,{aLotes[nDocto,1],aLotes[nDocto,2],aLotes[nDocto,3]})
					EndIf
				Next   

				If nQtdLotTp > 1 .And. !Empty(aLotesGrv)
					T200AAglut(aLotesGrv, lLotMesc)
				ElseIf Empty(aMsgerr)
					AAdd( aMsgErr, {STR0038+': ' + aLotes[nDocto-1,2] + ' - ' + STR0039 + ': ' + aLotes[nDocto-1,3] + ' ' + STR0040 , '04' , 'TMSA200A()'} ) //"LOTE//'TIPO'//' nao sera aglutinado. É necessário escolher dois ou mais lotes do mesmo tipo para aglutinação acontecer.'
				EndIf

			EndIf
		Else
			AAdd( aMsgErr, {STR0042 , '04' , 'TMSA200A()'} ) //"Selecione dois ou mais lotes!"
		EndIf
	ElseIf nAcao == 5 //Aglutinar Parcial
	   
		If nQtdLotMrk >= 1
				DTP->(dbSetOrder(2))
				aSort( aLotes,,,{ |x,y| x[3]+x[2]+x[1] < y[3]+y[2]+y[1] } )
				For nDocto := 1 To nTamDocto		
					If TmsExp()		
						If DTP->(dbSeek(xFilial('DTP')+aLotes[nDocto,1]+aLotes[nDocto,2])) .And.  aLotes[nDocto,4] == '2' 	//--Verifica se os lotes estão sem viagens ou se fazem parte da mesma viagem.
							If nDocto > 1
								If cNumViag <> DTP->DTP_VIAGEM
									AAdd( aMsgErr, {STR0047, '04' , 'TMSA200A()'} ) //"Lote //" " não será aglutinado, pois o mesmo não está com o status: 'Digitado'.""
									aLotesGrv := {}       						
									Exit
								EndIf	
							EndIf					
							cNumViag := DTP->DTP_VIAGEM						
						EndIf
					EndIf		
					If aLotes[nDocto,4] <> '2' //--Verifica se o status dos lotes é digitado
						AAdd( aMsgErr, {STR0038 + aLotes[nDocto,2] +  STR0046 , '04' , 'TMSA200A()'} ) //"Lote //" " não será aglutinado, pois o mesmo não está com o status: 'Digitado'.""
						aLotesGrv := {}       						
					ElseIf Empty(cTipLot) .Or. cTipLot == aLotes[nDocto,3] .And. Empty(aMsgErro)
						cTipLot := aLotes[nDocto,3]
						nQtdLotTp ++           
						Aadd(aLotesGrv,{aLotes[nDocto,1],aLotes[nDocto,2],aLotes[nDocto,3]})
					Else
						If nQtdLotTp > 1 .And. Empty(aMsgErro)
							T200AAgPar(aLotesGrv,@aListBox)			
							nQtdLotTp := 0
						Else
							aLotesGrv := {}
							AAdd( aMsgErr, {STR0038+': ' + aLotes[nDocto-1,2] +' - '+ STR0039 +': ' + aLotes[nDocto-1,3]  + STR0040  , '04' , 'TMSA200A()'} ) //"LOTE//'TIPO'//' ' nao será aglutinado. É necessário escolher dois ou mais lotes do mesmo tipo para que seja realizada a aglutinação.'
							Aadd(aLotesGrv,{aLotes[nDocto,1],aLotes[nDocto,2],aLotes[nDocto,3]})			
						EndIf                   
						cTipLot := ''			
					EndIf
				Next   
			If nQtdLotTp >= 1
					T200AAgPar(aLotesGrv,@aListBox)
				ElseIf Empty(aMsgerr)
					AAdd( aMsgErr, {STR0038+': ' + aLotes[nDocto-1,2] + ' - ' + STR0039 + ': ' + aLotes[nDocto-1,3] + STR0040 , '04' , 'TMSA200A()'} ) //"LOTE//'TIPO'//' nao sera aglutinado. É necessário escolher dois ou mais lotes do mesmo tipo para aglutinação acontecer.'
				EndIf
		Else
			AAdd( aMsgErr, {STR0042 , '04' , 'TMSA200A()'} ) //"Selecione dois ou mais lotes!"
		EndIf
	EndIf
	If !Empty(aMsgErr)
		TmsMsgErr( aMsgErr )
		lRet:= .F.
	EndIf

	RestArea( aArea )
	
	If !lAuto	
		TA200ARet(@aListBox)
		If lRefresh
			TMSA200Rfs(@aListBox)
			oLB200A:Refresh()
		 	oLB200A:SetFocus()
		EndIf
	EndIf
EndIf
Return ( lRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA200Rfs³  Autor ³ Leandro Paulino     ³ Data ³03.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza refresh do BROWSE                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA200Rfs()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA200A                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA200Rfs(aListBox, aPerg)

Local bLineBkp := oLB200A:bLine
Local lRateio  := DTP->(ColumnPos("DTP_RATEIO")) > 0

aListBox := {}

Default aPerg := {}

Pergunte("TMA200A",.F.)   
//-- Array com informacoes passadas pelo pergunte do TMSA200A(Tipo Lote, Lote De, Lote Ate, Data de, Data Ate, Status do Lote)
Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05), Mv_Par06, Iif(lRateio,AllTrim(Str(Mv_Par07)),"")})

T200ALIST(@aListBox, aPerg)

If !Empty(aListBox[1,LTLOTNFC])
	nQtdLot := Len(aListBox)
Else
	nQtdLot := 0
EndIf

oLB200A:SetArray( aListBox )
oLB200A:bLine 	:= bLineBkp
oLB200A:nAT		:= 1
oLB200A:Refresh()
oLB200A:SetFocus()

Return( Nil )

//-----------------------------------------------------
/*	Lista com os Lotes selecionados
{Protheus.doc} TA200ARet
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		03/09/2013
@return 	Nil	  												  */
//------------------------------------------------------
Static Function TA200ARet(aListBox)

Local nI       := 0
Local aLotes   := {}
Local lRefresh := .T.

//-- Retira a marca dos doctos autorizados
aLotes:= ASort( aListBox,,,{|x,y| x[ LTMARCA ] + x[ LTFILORI ] + x[ LTLOTNFC ] < y[ LTMARCA] + y[ LTFILORI ] + y[  LTLOTNFC ] })
For nI := 1 To Len(aLotes)
	If aLotes[nI,LTMARCA] == '2'
		Exit
	EndIf
	T200AMark(aListBox,nI,lRefresh,.T.)
Next nI

oLB200A:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} TA200AAglu
Marca Todos

@author Leandro Paulino
@since 02/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T200AAglut(aLotes, lLotMesc)
Local lRet 			:= .T.
Local nTamDoctos  := 0         
Local nQtdNfc		:= 1     
Local cFilOri       := ''
Local cNewLot		:= ''        
Local cStatus		:= '1' //--Aberto
Local cTipLot		:= ''
Local nX				:= 0           
Local nY				:= 0
Local aRecnoDTC	:= {}
Local nTamRecDTc	:= 0
Local cRATEIO		:= ''
Local cBACRAT		:= ''
Local cCRIRAT		:= ''
Local cPRORAT		:= ''
Local cORIRAT		:= ''
Local cCALRAT		:= ''
Local cTABRAT		:= ''
Local cTIPRAT		:= ''
Local cTBARAT		:= ''
Local cTPARAT		:= ''
Local lCamposRat	:= DTP->(ColumnPos("DTP_RATEIO")) > 0
Local aCab          := {}

Default aLotes      := {}
Default lLotMesc    := .F.

// Caso seja uma Selecao mista de Tipos de Lotes, o Lote a ser gerado sera do tipo ELETRONICO //
cTipLot := Iif( lLotMesc, StrZero(3,Len(DTP->DTP_TIPLOT)), "" )

Begin Transaction

    //cNewLot := CriaVar("DTP_LOTNFC")
    //ConfirmSX8()
    nTamDoctos := Len(aLotes)
    //-- Copia as informacoes dos lotes anteriores para comppor o novo lote.
	DTP->(dbSetOrder(2))
    For nX := 1 To nTamDoctos
        If DTP->(dbSeek(xFilial('DTP')+aLotes[nX,1]+aLotes[nX,2]))
			Aadd(aCab,{"DTP_FILORI",DTP->DTP_FILORI,Nil})
            If Empty(cTipLot)
				Aadd(aCab,{"DTP_TIPLOT",DTP->DTP_TIPLOT,Nil})
			EndIf
			If lCamposRat
					Aadd(aCab,{"DTP_RATEIO",DTP->DTP_RATEIO,Nil})
					Aadd(aCab,{"DTP_BACRAT",DTP->DTP_BACRAT,Nil})
					Aadd(aCab,{"DTP_CRIRAT",DTP->DTP_CRIRAT,Nil})
					Aadd(aCab,{"DTP_PRORAT",DTP->DTP_PRORAT,Nil})
					Aadd(aCab,{"DTP_ORIRAT",DTP->DTP_ORIRAT,Nil})
					Aadd(aCab,{"DTP_CALRAT",DTP->DTP_CALRAT,Nil})
					Aadd(aCab,{"DTP_TABRAT",DTP->DTP_TABRAT,Nil})
					Aadd(aCab,{"DTP_TIPRAT",DTP->DTP_TIPRAT,Nil})
					Aadd(aCab,{"DTP_TBARAT",DTP->DTP_TBARAT,Nil})
			    	Aadd(aCab,{"DTP_TPARAT",DTP->DTP_TPARAT,Nil})
			EndIf
			Exit
		EndIf
    Next nX
	
	Aadd(aCab,{"DTP_DATLOT", dDataBase                     ,Nil})
	Aadd(aCab,{"DTP_HORLOT", StrTran(Left(Time(),5),":",""),Nil})
	Aadd(aCab,{"DTP_QTDLOT", nQtdNfc                       ,Nil})
	Aadd(aCab,{"DTP_QTDDIG", 0 /*nQtdNfc*/                 ,Nil})
	Aadd(aCab,{"DTP_STATUS", cStatus                       ,Nil})
    //-- Inclui novo lote
	lMsErroAuto := .F.
	MSExecAuto({|x,y| cNewLot := TMSA170(x,y)},aCab,3)
    cNewLot := DTP->DTP_LOTNFC
    cFilOri := DTP->DTP_FILORI
	//-- ATUALIZA O CONJUNTO DE TABELAS RELACIONADAS COM AS NOTAS FISCAIS
	DTC->(dbSetOrder(1))
	DTP->(dbSetOrder(2))
	DVR->(dbSetOrder(1))
	DVU->(dbSetOrder(2))
	nQtdNfc	:= 0
	For nX := 1 To nTamDoctos
		If DTC->(dbSeek(xFilial('DTC')+aLotes[nX,1]+aLotes[nX,2]))                                                          
			//Altera numero do Lote do DTC
			While (DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_FILORI+DTC_LOTNFC) == (xFilial('DTC')+aLotes[nX,1]+aLotes[nX,2]))		
				Aadd(aRecnoDTC,(DTC->(Recno())))
				nQtdNfc  ++
				DTC->(dbSkip())		
			EndDo				                    
			nTamRecDTc := Len(aRecnoDTC)
			For nY := 1 To nTamRecDTC          
				DTC->(dbGoTo(aRecnoDTC[nY]))    
				RecLock('DTC',.F.)	
				DTC->DTC_LOTNFC := cNewLot
				MsUnLock()       
				//    
				If DVR->(dbSeek(xFilial('DVR')+aLotes[nX,1]+aLotes[nX,2]))
					RecLock('DVR',.F.)	
					DVR->DVR_LOTNFC := cNewLot
					MsUnLock() 
				EndIf
				//
				If DVU->(dbSeek(xFilial('DVU')+aLotes[nX,1]+aLotes[nX,2]))
					RecLock('DVU',.F.)	
					DVU->DVU_LOTNFC := cNewLot
					MsUnLock() 
				EndIf
			Next nY
			//Apaga o Lote Selecionado
			If DTP->(dbSeek(xFilial('DTP')+aLotes[nX,1]+aLotes[nX,2]))
				RecLock('DTP',.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf

	Next nX

	//-- Atualiza o novo lote com a quantidade de notas fiscais e muda o status para digitado.
	If DTP->(dbSeek(xFilial('DTP')+cFilOri+cNewLot))
		RecLock('DTP',.F.)
		DTP->DTP_QTDLOT := nQtdNfc
		DTP->DTP_QTDDIG := nQtdNfc
		DTP->DTP_STATUS := "2" //-- Digitado
		MsUnLock()
	EndIf

End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T200AParam
Atualiza Lista de acordo com os parametros.

@author Leandro Paulino
@since 02/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T200AParam(aListBox)

Local lPergunte := .F.               
Local aPerg	    := {}
Local lRateio   := DTP->(ColumnPos("DTP_RATEIO")) > 0
 
lPergunte := Pergunte("TMA200A",.T.)

If lPergunte        
	aListBox := {}          
	//-- Array com informacoes passadas pelo pergunte do TMA200A(Tipo Lote, Lote De, Lote Ate, Data de, Data Ate, Status do Lote)
	Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05), Mv_Par06, Iif(lRateio,AllTrim(Str(Mv_Par07)),"")})
	If T200ALIST(@aListBox, aPerg) .And. !Empty(aListBox)
		T200ALot(aListBox)
	EndIf	   
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T200APrpLt
Prepara Lotes para processamento

@author Leandro Paulino
@since 02/09/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function T200APrpLt(aLotes,nAcao)
Local nDocto 	:= 0
Local nTamDocto := 0
Local cFilOri   := ""
Local cLote     := ""
Local lLoteEl   := .F.
Local lEnd      := .F.

Default aLotes  := {}                   
Default nAcao   := 1
Default lSelLote:= .T.

nTamDocto := Len(aLotes)
ProcRegua( nTamDocto )

dbSelectArea("DTP")
DTP->(dbSetOrder(1))

If IsInCallStack("TMSA146Eft")
	lSelLote := .F.
EndIf

For nDocto:= 1 To nTamDocto
	If aLotes[nDocto,4] == '2' .Or. aLotes[nDocto,4] == '4'
		IncProc()    
		
		If DTP->(dbSeek(FwxFilial("DTP")+ aLotes[nDocto,2]))	   
			Processa( {|lEnd| TMSA200Lib(DTP->DTP_FILORI,DTP->DTP_LOTNFC,.T.,@lEnd) }, cCadastro,STR0055, .F. ) //'Gerando Conhecimentos do primeiro percurso...'
			Processa( {|lEnd| TMSA200Lib(DTP->DTP_FILORI,DTP->DTP_LOTNFC,.F.,@lEnd) }, cCadastro,STR0056, .F. ) //'Gerando Conhecimentos...'                           		
			TMSA200Prc( aLotes[nDocto,1], aLotes[nDocto,2],IIf(nAcao==4,.T.,.F.), lSelLote)
			If AllTrim(aLotes[nDocto,3]) == 'Eletronico'
				lLoteEl := .T.
			EndIf
		EndIf
	EndIf	                                                 	
Next nDocto

If Len(aLotes)== 1
	cFilOri:= aLotes[1][1]
	cLote  := aLotes[1][2]
EndIf
	//-- Envio para TSS após o calculo
	Pergunte("TMB200",.F.)
	If mv_par02 == 1 .And. lLoteEl
		TMSAE70(1,cFilOri,cLote)
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} TA200AAgPar
Aglutina Parcial - Notas do Lote
Utilizado pela rotina TMSA146 - Programacao de Carregamento
@author Katia
@since 05/11/14
/*/
//-------------------------------------------------------------------
Static Function T200AAgPar(aLotes,aListBox)
Local lRet 			:= .T.
Local nTamDoctos  := 0         
Local nQtdNfc		:= 0     
Local cNewLot		:= ''        
Local cStatus		:= '2' //--Digitado
Local cTipLot		:= ''
Local nX			:= 0           
Local nY			:= 0
Local aRecnoDTC	:= {}
Local nTamRecDTc	:= 0
Local nQtdNFs     := 0
Local cSeek       := ""
Local nTotNfc     := 0
Local nQtdAtu     := 0
Local aNfsDTC     := {}
Local nPos1       := 0

Begin Transaction

cNewLot := CriaVar("DTP_LOTNFC")
ConfirmSX8()

nTamDoctos := Len(aLotes)

nTotNfc    := Len(aListBox)  //Qtde de Notas selecionadas para geracao do novo lote

//--- Atualiza Documentos referente ao novo lote
DTC->(dbSetOrder(1))
DTP->(dbSetOrder(2))
DVR->(dbSetOrder(1))
DVU->(dbSetOrder(2))

For nX := 1 To nTamDoctos
	nQtdAtu:= 0
	nQtdNfc:= 0
	aRecnoDTC:= {}
	If DTC->(dbSeek(xFilial('DTC')+aLotes[nX,1]+aLotes[nX,2]))                                                          
		//Altera numero do Lote do DTC
		While (DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_FILORI+DTC_LOTNFC) == (xFilial('DTC')+aLotes[nX,1]+aLotes[nX,2]))		
			Aadd(aRecnoDTC,(DTC->(Recno())))
			//--- Quantidade de Notas (nao considerar o produto)
			nPos:= Ascan(aNfsDTC,{ | e | e[1]+e[2]+e[3]+e[4] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
			If nPos == 0
				Aadd(aNfsDTC,{DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CLIREM,DTC->DTC_LOJREM})
 				nQtdNfc  ++
 			EndIf	
 				
			DTC->(dbSkip())		
		EndDo
		
		aNfsDTC:= {}				                    
		nTamRecDTc := Len(aRecnoDTC)
		For nY := 1 To nTamRecDTC          
			DTC->(dbGoTo(aRecnoDTC[nY]))
			
			nPos:= Ascan(aListBox,{ | e | e[LTNUMNFC]+e[LTSERNFC]+e[LTCLIREM]+e[LTLOJREM] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
			If nPos > 0
				aListBox[nPos][LTLOTNFC]:= cNewLot
				
				//--- Quantidade de Notas (nao considerar o produto)

				nPos1:= Ascan(aNfsDTC,{ | e | e[1]+e[2]+e[3]+e[4] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
				If nPos1 == 0
					Aadd(aNfsDTC,{DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CLIREM,DTC->DTC_LOJREM})
 					nQtdAtu  ++
	 			EndIf	
				
				RecLock('DTC',.F.)	
				DTC->DTC_LOTNFC := cNewLot
				MsUnLock()       
				//
					    
				cSeek:= "DTC->(DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_NUMNFC+DTC_SERNFC+DTC_CODPRO)" 
				If DVR->(dbSeek(xFilial('DVR')+cSeek))
					While DVR->(!Eof()) .And. DVR->(DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO) == cSeek                                                       
						RecLock('DVR',.F.)	
						DVR->DVR_LOTNFC := cNewLot
						MsUnLock()
						DVR->(DbSkip())
					EndDo	 
				EndIf
				//                                                                           
				cSeek:= "DTC->(DTC_FILORI+DTC_LOTNFC+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM)"
				If DVU->(dbSeek(xFilial('DVU')+cSeek))
					While DVU->(!Eof()) .And. DVU->(DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM) == cSeek                                                                           
						RecLock('DVU',.F.)	
						DVU->DVU_LOTNFC := cNewLot
						MsUnLock()
						DVU->(DbSkip())
					EndDo	 
				EndIf
			EndIf	
		Next nY
	EndIf
	
	If nQtdNfc > nQtdAtu   //Sobrou notas no lote, atualiza a quantidade de lote
		If DTP->(dbSeek(xFilial('DTP')+aLotes[nX,1]+aLotes[nX,2]))
			cTipLot := DTP->DTP_TIPLOT  
			RecLock('DTP',.F.)			
			DTP->DTP_QTDLOT := DTP->DTP_QTDLOT - nQtdAtu
			DTP->DTP_QTDDIG := DTP->DTP_QTDDIG - nQtdAtu
			MsUnLock()
		EndIf
	Else
		//Apaga o Lote Selecionado
		If DTP->(dbSeek(xFilial('DTP')+aLotes[nX,1]+aLotes[nX,2]))
			cTipLot := DTP->DTP_TIPLOT
			RecLock('DTP',.F.)			
			dbDelete()
			MsUnLock()
		EndIf	
	EndIf 
Next nX

If !Empty(cNewLot)
	//Cria um numero do Lote 
	RecLock('DTP',.T.)
	DTP->DTP_FILIAL := xFilial('DTP')
	DTP->DTP_FILORI := cFilAnt
	DTP->DTP_LOTNFC := cNewLot
	DTP->DTP_DATLOT := dDataBase
	DTP->DTP_HORLOT := StrTran(Left(Time(),5),":","")
	DTP->DTP_QTDLOT := nTotNfc
	DTP->DTP_QTDDIG := nTotNfc
	DTP->DTP_STATUS := cStatus
	DTP->DTP_TIPLOT := cTipLot
	MsUnlock()
EndIf

End Transaction

//--- Apresenta o Novo Lote Gerado
If IsInCallStack(AllTrim('TMSA146'))
	Help(' ', 1, 'TMSA20028',,cNewLot,2,1) //"Numero do Novo Lote Gerado : "
EndIf
Return lRet

/*/{Protheus.doc} VldLotePsq
//TODO Valida lote pesquisado
@author caio.y
@since 18/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cLote, , Lote Pesquisado
@type function
/*/
Static Function VldLotePsq(aListBox,cLote)
    Local lRet	:= .T. 
    Local nPos	:= 0

    Default aListBox	:= {}
    Default cLote		:= ""

    If !Empty(cLote)
        nPos	:= aScan( aListBox,{|x| x[LTLOTNFC] == cLote })
        
        If nPos > 0 
            lRet	:= .T. 
            If _lMarkLote .And. aListBox[nPos][1] == "2"
                T200AMark( aListBox, nPos )
            EndIf	
            oLB200A:NaT	:= nPos
            oLB200A:Refresh()
        Else	
            Help("",1,"REGNOIS") //-- Registro não encontrado	
        EndIf

        If _lMarkLote	
            oLoteMrk:SetFocus()
        EndIf
    EndIf

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tm200aDocX()
Busca os documentos dentro dos lotes e retorna no array.
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 04/09/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tm200aDocX(aLotes)
Local aDocExcMot:= {}
Local cQuery	:= ""
Local cAliasDT6	:= GetNextAlias()
Local cLotes	:= "( "
Local nX		:= 1
Local nLenLote  := Len(aLotes)

If nLenLote > 0
	For nX := 1 to nLenLote 
		If nX = nLenLote
			cLotes += "'"+ aLotes[nX][2] + "'"
		Else
			cLotes += "'"+ aLotes[nX][2] + "',"
		EndIf
	Next nX

	cLotes	+= " )"
	
	cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE  "
	cQuery += " FROM " + RetSqlName( 'DT6' )
	cQuery += " WHERE DT6_FILIAL = '" + xFilial('DT6') + "' "
	cQuery += " AND DT6_LOTNFC IN " + cLotes
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDT6, .F., .T. )
			
	While !(cAliasDT6)->(Eof())
		If Ascan( aDocExcMot, { |x|x[4]+x[5]+x[6] == (cAliasDT6)->DT6_FILDOC + (cAliasDT6)->DT6_DOC + (cAliasDT6)->DT6_SERIE } ) = 0
			Aadd(aDocExcMot,{ .T.,,,(cAliasDT6)->DT6_FILDOC, (cAliasDT6)->DT6_DOC, (cAliasDT6)->DT6_SERIE })
		EndIf
		(cAliasDT6)->(dbSkip())
	EndDo
EndIf

(cAliasDT6)->(DbCloseArea())

Return aDocExcMot

