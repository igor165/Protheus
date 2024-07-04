#INCLUDE "Protheus.ch
#INCLUDE 'TopConn.ch'
#INCLUDE "OGR296.ch

/** {Protheus.doc} OGR296
Listagem de Romaneios por  transportador
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

Function OGR296()


//--< variáveis >---------------------------------------------------------------------------
	Private cPerg	 	:= "OGR296"
	Private oBreak1,oBreak2,Obreak3
	Private aTotalPro   := {}

	Pergunte(cPerg,.f.)
	
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/** {Protheus.doc} OGR295
Montando a estrutura/layout do tReport
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

Static Function ReportDef()
	Private oReport
    
//Montando o objeto oReport
	oReport := TReport():NEW("OGR296", STR0001, cPerg, {|oReport|PrintReport(oReport)}, STR0001) //Listagem de romaneios por transportador

//Para não imprimir a página de parâmetros
	oReport:lParamPage := .f.
	oReport:GetOrientation(2)
	oreport:nFontBody := 8
	oReport:CFONTBODY			:= "Courier New"
	oReport:nLineHeight:=40
	oReport:SetDevice(2) //iMPRESSORA
	oReport:oPage:setPaperSize(9) // 9 e 10 sao A4
	oReport:SetColSpace(1)
	
	oSecRom := TRSection():New(oReport, STR0002,{}) //"Romaneios"
	oSecRom:SettotalInline(.t.)
	oSecRom:lbold:=.t.
	oSecRom:SetColSpace(1,.t.)
	oSecRom:lAutosize:=.f.
	oSecRom:llinebreak:=.f.
	

	TRCell():New(oSecRom,"Filial"			,"",STR0003					,'@!'								,10	,.f.) 	//'Filial'
	TRCell():New(oSecRom,"EMISSAO"			,"",STR0004					,PesqPict('NJJ',"NJJ_DOCEMI")	,15	,.f.) 	//'Emissão'
	TRCell():New(oSecRom,"TPMVTO"			,"",STR0005					,"@!"								,3	,.f.) 	//'TP'	
	TRCell():New(oSecRom,"ROMAN"			,"",STR0006					,'@!'								,14,.f.) 	//'  Romaneio'	
	TRCell():New(oSecRom,"PLACA"     		,"",STR0055		 			,'@R! AAA-9999'					,14	,.f.) 	// Placa
	///TRCell():New(oSecRom,"MOTORISTA"		,"",'Motorista'			,'@!'								,46,.f.)
	TRCell():New(oSecRom,"CONTRATO"			,"",STR0007					,'@!'								,14	,.f.) 	//'Contrato'
	TRCell():New(oSecRom,"PRODUTO"			,"",Padl(STR0008,70)			,'@!'								,70	,.f.) 	//'Produto'
	TRCell():New(oSecRom,"PESO1"     		,"",STR0009	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   1aPesagem"
	TRCell():New(oSecRom,"PESO2"     		,"",STR0010	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   2aPesagem"
	TRCell():New(oSecRom,"PESOBRUTO"    	,"",STR0011	 				,'@E 99,999,999,999'				,17	,.f.) 	//"  Liq S/Desc"
	TRCell():New(oSecRom,"DESCONTOS"     	,"",STR0012	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   Descontos"
	TRCell():New(oSecRom,"PESOLIQ"       	,"",STR0013					,'@E 99,999,999,999'				,17	,.f.) 	//"   P.Liquido"
	
	
	//TOTAIS
	
	oSecTot := TRSection():New(oReport, "Totais",{}) //"Romaneios"
	oSecTot:SettotalInline(.t.)
	oSecTot:lbold:=.t.
	oSecTot:SetColSpace(1,.t.)
	oSecTot:lAutosize:=.f.
	oSecTot:llinebreak:=.f.
	
	TRCell():New(oSecTot,"PRODUTO"			,"",Padl(STR0008,70)		,'@!'								,70	,.f.) 	//'Produto'
	TRCell():New(oSecTot,"PESO1"     		,"",STR0009	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   1aPesagem"
	TRCell():New(oSecTot,"PESO2"     		,"",STR0010	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   2aPesagem"
	TRCell():New(oSecTot,"PESOBRUTO"    	,"",STR0011	 				,'@E 99,999,999,999'				,17	,.f.) 	//"  Liq S/Desc"
	TRCell():New(oSecTot,"DESCONTOS"     	,"",STR0012	 				,'@E 99,999,999,999'				,17	,.f.) 	//"   Descontos"
	TRCell():New(oSecTot,"PESOLIQ"       	,"",STR0013					,'@E 99,999,999,999'				,17	,.f.) 	//"   P.Liquido"
	
//--Ajustando alinhamento das Celulas e Tit;Cabeçalho dos Descontos--//
		
	oSecRom:Cell( "PESO1"		):SetHeaderAlign('RIGHT' )
	oSecRom:Cell( "PESO1"		):SetAlign('RIGHT' )
	     
	oSecRom:Cell( "PESO2" 		):SetHeaderAlign('RIGHT' )
	oSecRom:Cell( "PESO2" 		):SetAlign('RIGHT' )
	     
	oSecRom:Cell( "PESOBRUTO"	):SetHeaderAlign('RIGHT' )
	oSecRom:Cell( "PESOBRUTO"	):SetAlign('RIGHT' )
		
	oSecRom:Cell( "DESCONTOS"	):SetHeaderAlign('RIGHT' )
	oSecRom:Cell( "DESCONTOS"	):SetAlign('RIGHT' )
		 
	oSecRom:Cell( "PESOLIQ"	):SetHeaderAlign('RIGHT' )
	oSecRom:Cell( "PESOLIQ"	):SetAlign('RIGHT' )
	
	/*TOTAIS*/
	oSecTot:Cell( "PESO1"		):SetHeaderAlign('RIGHT' )
	oSecTot:Cell( "PESO1"		):SetAlign('RIGHT' )
	     
	oSecTot:Cell( "PESO2" 		):SetHeaderAlign('RIGHT' )
	oSecTot:Cell( "PESO2" 		):SetAlign('RIGHT' )
	     
	oSecTot:Cell( "PESOBRUTO"	):SetHeaderAlign('RIGHT' )
	oSecTot:Cell( "PESOBRUTO"	):SetAlign('RIGHT' )
		
	oSecTot:Cell( "DESCONTOS"	):SetHeaderAlign('RIGHT' )
	oSecTot:Cell( "DESCONTOS"	):SetAlign('RIGHT' )
		 
	oSecTot:Cell( "PESOLIQ"	):SetHeaderAlign('RIGHT' )
	oSecTot:Cell( "PESOLIQ"	):SetAlign('RIGHT' )
		
		
	oBreak1 := TRBreak():New( oSecRom, {||QryNJM->(NJJ_CODTRA)}				              , {||}) 	// "Total transportado do Transportador
	oBreak2 := TRBreak():New( oSecRom, {||QryNJM->(NJJ_CODTRA + NJM_CODENT + NJM_LOJENT)} , {||}) 	// 	"Total Transportado da Loja
	oBreak3 := TRBreak():New( oSecRom, {||QryNJM->(NJJ_CODTRA + NJM_CODENT)}			  , {||}) 	//	"Total Transportado da Entidade
	
	///TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint) 
	TRFunction():New(oSecRom:Cell("PESO1")			,,"SUM",oBreak1,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESO2")			,,"SUM",oBreak1,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOBRUTO")	,,"SUM",oBreak1,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("DESCONTOS")	,,"SUM",oBreak1,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOLIQ")		,,"SUM",oBreak1,,'@E 99,999,999,999',, .f., .f. )
	
	TRFunction():New(oSecRom:Cell("PESO1")			,,"SUM",oBreak2,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESO2")			,,"SUM",oBreak2,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOBRUTO")	,,"SUM",oBreak2,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("DESCONTOS")	,,"SUM",oBreak2,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOLIQ")		,,"SUM",oBreak2,,'@E 99,999,999,999',, .f., .f. )
		
	TRFunction():New(oSecRom:Cell("PESO1")			,,"SUM",oBreak3,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESO2")			,,"SUM",oBreak3,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOBRUTO")	,,"SUM",oBreak3,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("DESCONTOS")	,,"SUM",oBreak3,,'@E 99,999,999,999',, .f., .f. )
	TRFunction():New(oSecRom:Cell("PESOLIQ")		,,"SUM",oBreak3,,'@E 99,999,999,999',, .f., .f. )
	

	oReport:SetLandScape()
	oReport:DisableOrientation()
	
	oReport:OnPageBreak({|| fPrnCabEsp(1)  })  	// Irá Forçar Imprimir o Cabeçalho Especifico
	
	
	
Return(oReport)


/** {Protheus.doc} 
    Filtra e imprime a listagem
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

Static Function PrintReport(oReport)
	Local limpLine	:= .f.
	Local cFilialIni	:= 	MV_PAR01
	Local cFilialFim	:= 	MV_PAR02
	Local cTranspIni 	:= MV_PAR03
	Local cTranspfim	:= MV_PAR04
	Local cEntidIni 	:= 	MV_PAR05
	Local cLojaIni 	:= 	MV_PAR06
	Local cEntidFim 	:= 	MV_PAR07
	Local cLojaFim 	:= 	MV_PAR08
	Local cCtrIni		:= 	MV_PAR09
	Local cCtrFim		:= 	MV_PAR10
	Local cCodSafIni	:=	MV_PAR11
	Local cCodSafFim	:=	MV_PAR12
	Local dDtIni 		:=	MV_PAR13
	Local dDtFim 		:=	MV_PAR14
	Local cProdutIni 	:=	MV_PAR15
	Local cProdutFim	:=	MV_PAR16
	Local nTpMvRom	:=	MV_PAR17
	Local nTpRom		:=	MV_PAR18
	Local nx

	Local	 cQuery	:= ""

	Private oSecRom		:= oReport:Section(1)
	Private oSecTot		:= oReport:Section(2)
	
	nCont	:= 0
	nPag	:= 1

	oReport:SetPageNumber(nPag)
	oReport:Page(nPag)
	
	cquery:=''
	cQuery += " SELECT "
	cQuery += " 		(CASE "
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') THEN 'E'"	//Romaneios de Entrada
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) THEN 'S'"	//Romaneios de Saida
	cQuery += "  		END) AS TPROM, "
	cQuery += " 		SB1.*, NJJ.*, NJM.* , "
	cQuery += " ( "
	cQuery += "	SELECT SUM(NJK.NJK_QTDDES) FROM " + RetSqlName('NJK')+ " NJK "
	cQuery += " WHERE "
	//// Tirado cQuery += " 	WHERE NJK.NJK_FILIAL = NJM.NJM_FILIAL AND NJK.NJK_CODROM = NJM.NJM_CODROM AND NJK.D_E_L_E_T_ !='*' "
	
	  //--Encontrando a Filial do Inner NJK --
    cJoinFil :=''
	If FWModeAccess("NJK") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  NJK.NJK_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("NJK",3) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("NJK",2) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("NJK",1) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " NJK.NJK_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
   //------------------------------------------------------------------------
   	cQuery +=  cJoinfil + " NJK.NJK_CODROM = NJM.NJM_CODROM AND NJK.D_E_L_E_T_ !='*' "
	
	cQuery += " ) AS DESCONTO "
	cQuery += " FROM " + RetSqlName('NJM')+ " NJM "
	cQuery += " LEFT JOIN " + RetSqlName('SB1')+ " SB1 ON "
////Mudado rel imprime agora de FILIAL DE /ATE cQuery += " 		ON SB1.B1_FILIAL = '" + fwXfilial('SB1') 	+ "' AND SB1.B1_COD = NJM.NJM_CODPRO AND SB1.D_E_L_E_T_ = ' '"	
	
    //--Encontrando a Filial do Inner Join SB1 --
    cJoinFil :=''
	If FWModeAccess("SB1") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  SB1.B1_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("SB1",3) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("SB1",2) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("SB1",1) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " SB1.B1_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
   //-----------------------------------------------------------------------
	cQuery += cJoinFil +" SB1.B1_COD = NJM.NJM_CODPRO AND SB1.D_E_L_E_T_ = ' '"   		
	
	cQuery += " LEFT JOIN " + RetSqlName('NJJ')+ " NJJ ON "
////Mudado Rel. impme agora de FILIAL DE / ATE 	cQuery += " 		ON NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJM.D_E_L_E_T_ = ' '"

    //--Encontrando a Filial do Inner Join NJJ --
    cJoinFil :=''
	If FWModeAccess("NJJ") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("NJJ",3) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("NJJ",2) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("NJJ",1) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
//---------------------------------------------------------------------------
 	cQuery += cJoinFil + " NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJJ.D_E_L_E_T_ = ' '"

	cQuery += " WHERE  NJM.NJM_CODENT	BETWEEN '" 	+ cEntidIni 	+ "' AND '" + cEntidFim	+ 	"'"
	cQuery += "  	AND NJJ_CODTRA		BETWEEN '"		+ cTranspIni  + "' AND '" + cTranspFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_LOJENT	BETWEEN '" 	+ cLojaIni		+ "' AND '" + cLojaFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_CODCTR	BETWEEN  '"	+ cCtrIni	  	+ "' AND '" + cCtrFim	+	"'"
//	cQuery += "	AND NJM.NJM_CODROM	BETWEEN '" 	+ cRomanIni 	+ "' AND '" + cRomanFim	+ 	"'"
	cQuery += "	AND NJM.NJM_CODPRO 	BETWEEN '"  	+ cProdutIni 	+ "' AND '" + cProdutFim	+	"'"
	cQuery += "	AND NJM.NJM_CODSAF 	BETWEEN '"		+ cCodSafIni  + "' AND '" + cCodSafFim	+	"'"
	cQuery += "	AND NJJ.NJJ_DATA 		BETWEEN '"		+ dTOS(dDtIni) 		+ "' AND '" + dTOs(dDtFim) 	+	"'"
	///cQuery += "	AND NJM.NJM_FILIAL 	= 	'"			+ FwXfilial('NJM') + "'"
	cQuery += "	AND NJM.NJM_FILIAL 	BETWEEN '" 	+ cFilialIni 	+ "' AND '" +	cFilialFim	 + "'"
	IF nTpMvRom == 02 //Considera somente entradas
		cQuery += " AND NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') "
	ElseIF nTpMvRom == 03 //Considera somente Saidas
		cQuery += " AND NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) "
	////ElseIF nTpMvRom == 01 // Considera todos os Romaneios //
	EndIF
	
	IF nTpRom == 4 //Considera Romaneios Simbolicos
		cQuery += " AND NJJ.NJJ_TIPENT = '2' "
	ElseIF nTpRom == 3 //Considera Romaneios Gerenciais
		cQuery += " AND NJJ.NJJ_TIPENT = '1' "
	ElseIF nTpRom == 2 //Considera Romaneios Fisicos
		cQuery += " AND NJJ.NJJ_TIPENT = '0' "
	//IF nTpRom == 1 //Considera todos os romaneios..
	EndIF
	cQuery += "   AND NJJ_STATUS NOT IN ('4') " // n. listar Cancelados
	cQuery += "	AND NJM.D_E_L_E_T_ != '*' "
	
	cquery += " ORDER BY NJJ_CODTRA,NJJ.NJJ_CODENT, NJJ.NJJ_LOJENT, NJM.NJM_FILIAL, NJM.NJM_CODCTR, NJJ_DATA ASC" //1 é a coluna Calculada por tp.movto Entrada ou Saida
   //--ordem Transportador, Entidade, Loja, Contrato,Data
	cQuery:= ChangeQuery(cQuery)

	If select("QryNJM") <> 0
		QryNJM->( dbCloseArea() )
	endif

	TCQUERY cQuery NEW ALIAS "QryNJM"
	
	Count To nRecCount			//Contando o registro da query
	
	oReport:SetMeter( nRecCount )

//-- Visao do Header , quebra na ordem: Entidade,Fazenda(lja),Produto, no Footer é ao contrario 1o/Produto,Fazenda(lja),Entidade --
	cQuebra1 := ''	// Quebra  Por Transportador
	cQuebra2 := ''	// Quebra  Por Loja da Entidade (Fazenda)
	cQuebra3 := ''	//	Quebra  Por Entidade
	nLine:=0
	
	oSecRom:Init()
	QryNJM->( DbGoTop() )
	nCont := 0
	While .t.     	//Loop finito, so saio apos verificar se deve-se imprimir os totais.
		IF oReport:Cancel()
			Exit
		EndIF
	
		oReport:IncMeter()
		

		IF oBreak2:Execute(.f.) //Loja
			fSaltaPage(2)//Tenho q imprimir 2 linhas a do total + a linha do rodape
			oreport:PrintText ( STR0014  	,oreport:row() 	, 10) //"Total transportado da Loja"
			oBreak2:Printtotal()
			lImpLine := .t.
		EndIF
		IF oBreak3:Execute(.f.) //Entidade
			fsaltaPage(2) //Tenho q imprimir 2 linhas a do total + a linha do rodape
			oreport:PrintText ( STR0015 	,oreport:row() 	, 10) //"Total transpordado da Entidade"
			oBreak3:Printtotal()
			lImpLine := .t.
		EndIF

		//--Verificando se as Quebras iram acontecer na Proxima Linha Se Sim, forço a imprimir os totais--/
		IF oBreak1:Execute(.f.)   //Transportador
			fSaltaPage(2) //Tenho q imprimir 2 linhas a do total + a linha do rodape
			oreport:PrintText ( STR0016 	,oreport:row() 	, 10) //"Total Transportado pelo Transportador"
			oBreak1:Printtotal()
			lImpLine := .t.
		EndIF		
		
		//-- Qdo Tem Quebra apos o Total , preciso imprimir uma Linha para separar o total dos titulos Entidade,Loja,Produto --//
		IF limpLine == .t.
			IF !fSaltaPage(2)
				oReport:Fatline()
				oreport:Skipline()
				limpline := .f.
			EndIF
		EndIF		
		
		//--Se for fim de arquivo deve-se Sair do Loop-//
		IF QryNJM->(Eof())
		   Exit
		EndIf
		//---------------------------------------------//
		
		// -- Verificando Se o Transportador Mudou Para imprimir os Dados do Mesmo como kbeçalho-- //
		IF cQuebra3 != QryNJM->NJJ_CODTRA
			cQuebra3	:= QryNJM->NJJ_CODTRA 
			cAux		:= AllTrim(QryNJM->NJJ_CODTRA)  + "-" + POSICIONE('SA4',1,XFILIAL('SA4')+QryNJM->NJJ_CODTRA,'A4_NOME')

			oreport:nFontBody := 08 //Aumento a Fonte Para 10
				///oSecProd:Cell( "Produto"	):SetValue( cAux ) N.Usei a secao, poise os spacos stao baguncando
			fSaltaPage(2) //Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 10)
			oReport:SkipLine(2)//oreport:incrow(50) // Pula 25 Pixels
		EndIF
		
	// -- Verificando se A Entidade Mudou Para imprimir os Dados da Entidade -- //	
		IF cQuebra1 != QryNJM->(NJJ_CODTRA + NJM_CODENT)
			cQuebra1 	:= QryNJM->(NJJ_CODTRA + NJM_CODENT)
			cAux		:= AlltRim(QryNJM->NJM_CODENT) + "-" + POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJM->NJM_CODENT+QryNJM->NJM_LOJENT,'NJ0_NOME')
			oreport:nFontBody 	:=08 //Aumento a Fonte Para 10
			fSaltaPage(2) ////Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 30)
			oreport:SkipLine(2) //oreport:incrow(50) // Pula 25 Pixels
		EndIF
	// -- Verificando se A Entidade e Loja Mudou Para imprimir os Dados da Loja (Fazenda)-- //
		IF cQuebra2 != QryNJM->(NJJ_CODTRA + NJM_CODENT + NJM_LOJENT)
			cQuebra2 	:= QryNJM->(NJJ_CODTRA + NJM_CODENT + NJM_LOJENT)
			cAux		:= Alltrim(QryNJM->NJM_CODENT) 	+ '-' + QryNJM->NJM_LOJENT + "-" + POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJM->NJM_CODENT+QryNJM->NJM_LOJENT,'NJ0_NOMLOJ')
			oreport:nFontBody := 08 //Aumento a Fonte Para 10
			fSaltaPage(2) //Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 60)
			oreport:SkipLine(2)//oreport:incrow(50) // Pula 25 Pixels
		EndIF
			
	
		oreport:nFontBody := 08	// Retorno a Fonte ao Tamanho Normal.
		
		
		oSecRom:Cell( "FILIAL"		):SetValue( Alltrim(QryNJM->NJM_FILIAL) )
		oSecRom:Cell( "EMISSAO"		):SetValue( dToc( StoD(QryNJM->NJJ_DATA )) )
		oSecRom:Cell( "ROMAN" 		):SetValue( QryNJM->NJJ_CODROM )
		oSecRom:Cell( "PLACA" 		):SetValue( QryNJM->NJJ_PLACA )
		
		cTipoRo := Substr(Posicione("SX5",1,xFilial("SX5")+"K5"+QryNJM->NJJ_TIPO,"X5DESCRI()"),2,1)
		cTipoRo += QryNJM->NJJ_TIPO
		
		oSecRom:Cell( "TPMVTO"		):SetValue( cTipoRo )
		cMotorista :=  QryNJM->NJJ_CODMOT + " - " + POSICIONE('DA4',1,XFILIAL('DA4')+QryNJM->NJJ_CODMOT ,'DA4_NOME')
		///oSecRom:Cell( "MOTORISTA"	):SetValue( cMotorista )
		oSecRom:Cell( "CONTRATO"	):SetValue( QryNJM->NJM_CODCTR )
		cProduto := QryNJM->NJM_CODPRO + "-" + Posicione('SB1',1,xFilial('SB1')+QryNJM->NJM_CODPRO,'B1_DESC')
		oSecRom:Cell( "PRODUTO"	):SetValue(cProduto )
		nPeso1 	:= QryNJM->NJJ_PESO1
		nPeso2 	:= QryNJM->NJJ_PESO2
		nDesconto 	:= QryNJM->DESCONTO
		nPercRom  	:= QryNJM->NJM_PERDIV
		//Verificando se o item do Romaneio e 100 % da Carga 
		IF ! nPercRom=100
			nPeso1 	*= nPercRom / 100
			nPeso2 	*= nPercRom / 100
			nDesconto 	*= nPercRom / 100
		EndIF
								
		nPesoBruto := IIf(nPeso1 > nPeso2,nPeso1 - nPeso2, nPeso2 - nPeso1 )  //Tratando qdo for entrada e Saida;
		 
		oSecRom:Cell( "PESO1"		):SetValue( nPeso1 )
		oSecRom:Cell( "PESO2" 		):SetValue( nPeso2 )
		oSecRom:Cell( "PESOBRUTO"	):SetValue( nPesoBruto )
		oSecRom:Cell( "DESCONTOS"	):SetValue( nDesconto  )
		oSecRom:Cell( "PESOLIQ"	):SetValue( nPesoBruto - nDesconto )
		
		/*Grava os totais*/
		//colocar o totalizador de produto -- verifica se existe e coloca ele na posição (soma valores) 
	    nPos  := aScan(aTotalPro,{|x| AllTrim(x[1]) == "C" + Alltrim(QryNJM->NJM_CODPRO) })
	    If nPos > 0
	    	aTotalPro[nPos][3] += nPeso1 //"PESO1"
	    	aTotalPro[nPos][4] += nPeso2 //"PESO2" 
	    	aTotalPro[nPos][5] += nPesoBruto //"PESOBRUTO"
	    	aTotalPro[nPos][6] += nDesconto //"DESCONTOS"
	    	aTotalPro[nPos][7] += ( nPesoBruto - nDesconto ) //"PESOLIQ"		 		
	    else
	        /*cria novo*/
	        aadd (aTotalPro, {"C"+Alltrim(QryNJM->NJM_CODPRO), cProduto, nPeso1, nPeso2 ,nPesoBruto	, nDesconto, (nPesoBruto - nDesconto)} )   
	    end.
	    
		fSaltaPage(1)
		oSecRom:PrintLine()
		
		QryNJM->(DbSkip())
		
	Enddo
	
	QryNJM->( dbCloseArea() )
	
	/*Impressão de totais*/
	if ! Empty(aTotalPro)
		oReport:OnPageBreak({|| fPrnCabEsp(2)  }) 
		oReport:SkipLine(1) // Pula 12 Pixels
				
		fSaltaPage(2) //Verifica se precisa Saltar a Pagina
				
		oreport:PrintText ( "TOTAIS POR PRODUTO" ,oreport:row() 	, 10)
		
		oReport:SkipLine(1) // Pula 12 Pixels
		
		oSecTot:Init()
		
		fPrnCabEsp(2)
		
		for nx := 1 To Len(aTotalPro) 
			oSecTot:Cell("PRODUTO"	 ):SetValue(aTotalPro[nx][2])
			oSecTot:Cell("PESO1"	 ):SetValue(aTotalPro[nx][3])
			oSecTot:Cell("PESO2" 	 ):SetValue(aTotalPro[nx][4])
			oSecTot:Cell("PESOBRUTO" ):SetValue(aTotalPro[nx][5])
			oSecTot:Cell("DESCONTOS" ):SetValue(aTotalPro[nx][6])
			oSecTot:Cell("PESOLIQ"   ):SetValue(aTotalPro[nx][7])
			fSaltaPage(1)
			oSecTot:PrintLine()
		end.
		
		oSecTot:Finish()
	end.
Return oReport

/*
@param: Nil
@description: Funcao para Impressão de Cabeçalho especifico
				esta função ajusta o kbeçalho da seção
@author: Emerson Coelho
@since: 09/09/2013
@return: Impressao do kbeçalho conforme solicitado
*/


//--<< Imprime Cabeçalho Especifico na Pagina >>--
Static Function fPrnCabEsp(nCabec )
***********************************
	Local oSecRom := oReport:Section(nCabec) // Seção q contem o keçalho q quero no top da pagina //

	oSecRom:SetHeaderSection(.t.)
	oSecRom:Show()
	oSecRom:PrintHeader()
	oSecRom:SetHeaderSection(.f.)
	
Return
/*
@param: nil 
@description: Funcao que verifica se preciso imprimir o rodape
   				e pular a pagina
@author: Emerson Coelho
@since: 09/09/2013
@return: array com 3 linhas contendo as descrições do tipo de movto.
*/

Static Function fSaltaPage(nLines)
	Local lSaltou := .f.
	Local ni:=0
	ni:=1

	While oReport:ChkIncRow(nLines,.t.)
		if nI == 1
			oReport:Fatline()  //Somente essa linha como rodape
			lSaltou := .t.
		ELSE
			oReport:SkipLine(1)
		EndIF
		ni++
			
	EndDo

Return(lSaltou)


