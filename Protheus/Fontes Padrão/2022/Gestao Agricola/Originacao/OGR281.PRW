#INCLUDE "OGR281.ch"
#include "protheus.ch"

/** {Protheus.doc} OGR281
Resumo Contratos Compras/Vendas

@param: 	Nil
@author: 	Jean Carlos Pontes Schulze	
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGR281()
	Local aAreaAtu 	  := GetArea()
	Local oReport	  := Nil
	
	Private vVetCom, vRetCom 
	Private vVetEnt, vRetEnt
	Private cNoT1, cAlT1, aAlT1, cNoT2, cAlT2, aAlT2
	
	Private cPergunta := "OGR281001" 
		
	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- CONTRATOS				||
	+================================================*/
	vVetCom := {	{"NJR_FILIAL"}, ;
					{"NJ0_CODENT"}, ;	
					{"NJ0_LOJENT"}, ;	//LOJA
					{"NJR_CODSAF"}, ;	//SAFRA					
					{"NJR_CODPRO"}, ;	//PRODUTO		
					{"NJR_CODCTR"}, ;	
					{"TIPO","C",1,0,"@!",STR0002}	, ; //Tipo (Contrato, Fixação)		
					{"NJR_DATA"}	, ;	//DATA
					{"TIPFIX" ,"C",07,0,"@!", RetTitle( "NJR_TIPFIX" )}	, ;		//TIPO PREÇO
					{"NJR_QTDCTR"}, ;		//QTDCONTRATO
					{"MOEDA", "C",05,0,"@!", STR0015}	, ;		//MOEDA
					{"NJR_UMPRC"}	, ;	    //UN					
					{"QTDSUP","N",18,2,PesqPict('NJR',"NJR_QTDCTR"),STR0003}	, ;		//Supressão
					{"QTDADT","N",18,2,PesqPict('NJR',"NJR_QTDCTR"),STR0004}	, ;		//Aditado
					{"ENTREGUE","N",18,2,PesqPict('NJR',"NJR_QTDCTR"),STR0005}	, ;	//Ctr Entr
					{"AENTREGA","N",18,2,PesqPict('NJR',"NJR_QTDCTR"),STR0006}	, ;	//Ctr a Entr
					{"NN8_QTDFIX"}, ;							//QTD FIXADA						
					{"FIXENT","N",18,2,PesqPict('NN8',"NN8_QTDFIX"),STR0007}	, ;	//Fix Entr
					{"AFIXENT","N",18,2,PesqPict('NN8',"NN8_QTDFIX"),STR0008}	, ;	//Fix a Entr					
					{"PRCUNIT","N",18,2,PesqPict('NN8',"NN8_VALUNI"),STR0009}	, ;	//Prc Unit				
					{"SLDFIX","N",18,2,PesqPict('NJR',"NJR_QTDCTR"),STR0010}}		//Sld a Fixar

	
	vRetCom := AGRCRIATRB(,vVetCom,{"NJ0_CODENT+NJ0_LOJENT+NJR_CODSAF+NJR_CODPRO+NJR_CODCTR+TIPO"},STR0001,.T.) //"OGR281"	//FUNCAO DO AGRUTIL01
	cNoT1 := vRetCom[3]	//INDICE
	cAlT1 := vRetCom[4] //ALIAS        
	aAlT1 := vRetCom[5]	//ARRAY 

	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- Entidade                ||
	+================================================*/
	vVetEnt := {	{"NJ0_CODENT"}, ;	
					{"NJ0_NOME"},   ;	//NOME
					{"NJ0_LOJENT"}, ;	//LOJA
					{"NJR_CODSAF"}, ;	//SAFRA					
					{"NJR_CODPRO"}, ;	//PRODUTO					
					{"NJR_DESPRO"}, ;	//DESCRICAO
					{"NJR_UM1PRO"}	}	//UM
	
	vRetEnt := AGRCRIATRB(,vVetEnt,{"NJ0_CODENT+NJ0_LOJENT+NJR_CODSAF+NJR_CODPRO"},STR0001,.T.) //"OGR281"	//FUNCAO DO AGRUTIL01
	cNoT2 := vRetEnt[3]	//INDICE
	cAlT2 := vRetEnt[4] //ALIAS        
	aAlT2 := vRetEnt[5]	//ARRAY 		
	
	If TRepInUse()
		
		Pergunte( cPergunta, .f. )
		oReport := ReportDef()
		oReport:PrintDialog()
		
	EndIf
	
	RestArea( aAreaAtu )
	
	//destroi tabela temporária
	AGRDELETRB( cAlT1, cNoT1 )  
	AGRDELETRB( cAlT2, cNoT2 )  
Return( Nil )

/** {Protheus.doc} PrintReport
Constroi o layout do relatório.
@param: 	oReport
@author: 	Jean Carlos Pontes Schulze
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
	
	oReport := TReport():New("OGR281", STR0025, cPergunta, {| oReport | PrintReport( oReport ) }, STR0026) //"Resumo de Contratos de Compras/Vendas"###"
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()	
	
	/*Monta as Colunas*/
	
	oSection1 := TRSection():New( oReport, STR0011, cAlT1 ) //"Contrato"
	
	TRCell():New( oSection1, "NJR_FILIAL" , cAlT1, STR0048, , TamSX3("NJR_FILIAL")[1] )
	TRCell():New( oSection1, "NJR_CODCTR" , cAlT1, STR0011, , TamSX3("NJR_CODCTR")[1] )
	TRCell():New( oSection1, "NJR_DATA"   , cAlT1, STR0012, , 10)
	TRCell():New( oSection1, "TIPFIX"	  , cAlT1, STR0013, , 7) //NJR_TIPFIX
	TRCell():New( oSection1, "NJR_QTDCTR" , cAlT1, STR0014, , TamSX3("NJR_QTDCTR")[1])
	TRCell():New( oSection1, "QTDSUP"     , cAlT1, STR0003, PesqPict('NJR',"NJR_QTDCTR"), TamSX3("NJR_QTDCTR")[1])
	TRCell():New( oSection1, "QTDADT"     , cAlT1, STR0004, PesqPict('NJR',"NJR_QTDCTR"), TamSX3("NJR_QTDCTR")[1])
		
	TRCell():New( oSection1, "ENTREGUE"   , cAlT1, STR0005, PesqPict('NJR',"NJR_QTDCTR"), TamSX3("NJR_QTDCTR")[1])

	TRCell():New( oSection1, "AENTREGA"   , cAlT1, STR0006, PesqPict('NJR',"NJR_QTDCTR"), TamSX3("NJR_QTDCTR")[1])
	TRCell():New( oSection1, "MOEDA"      , cAlT1, STR0015, , 5) //moeda
	TRCell():New( oSection1, "PRCUNIT"    , cAlT1, STR0009, PesqPict('NN8',"NN8_VALUNI"), TamSX3("NN8_VALUNI")[1])
	TRCell():New( oSection1, "NJR_UMPRC"  , cAlT1, STR0016, , TamSX3("NJR_UMPRC")[1])
	
	TRCell():New( oSection1, "NN8_QTDFIX" , cAlT1, STR0017, , TamSX3("NN8_QTDFIX")[1])
	TRCell():New( oSection1, "FIXENT"     , cAlT1, STR0007, PesqPict('NN8',"NN8_QTDFIX"), TamSX3("NN8_QTDFIX")[1])
	TRCell():New( oSection1, "AFIXENT"    , cAlT1, STR0008, PesqPict('NN8',"NN8_QTDFIX"), TamSX3("NN8_QTDFIX")[1])
	TRCell():New( oSection1, "SLDFIX"     , cAlT1, STR0010, PesqPict('NJR',"NJR_QTDCTR"), TamSX3("NJR_QTDCTR")[1])

	
	oSection2 := TRSection():New( oReport, STR0018, cAlT2 ) //"Entidade"
	
	TRCell():New( oSection2, "NJ0_CODENT" , cAlT2, STR0018, , TamSX3("NJ0_CODENT")[1])
	TRCell():New( oSection2, "NJ0_NOME"   , cAlT2, STR0019, , TamSX3("NJ0_NOME")[1])
	TRCell():New( oSection2, "NJ0_LOJENT" , cAlT2, STR0020, , TamSX3("NJ0_LOJENT")[1]) 
	TRCell():New( oSection2, "NJR_CODSAF" , cAlT2, STR0021, , TamSX3("NJR_CODSAF")[1])
	TRCell():New( oSection2, "NJR_CODPRO" , cAlT2, STR0022, , TamSX3("NJR_CODPRO")[1])	
	TRCell():New( oSection2, "NJR_DESPRO" , cAlT2, STR0023, , TamSX3("NJR_DESPRO")[1])
	TRCell():New( oSection2, "NJR_UM1PRO" , cAlT2, STR0024, , TamSX3("NJR_UM1PRO")[1])
	

	/*Breaks*/	
	oBreak1 := TRBreak():New( oSection2, {||(cAlT2)->(NJ0_CODENT+NJ0_LOJENT+NJR_CODSAF+NJR_CODPRO)} , STR0027, .f. )//"Total Produto -->"
	TRFunction():New(oSection1:Cell("NJR_QTDCTR")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDSUP")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDADT")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("ENTREGUE")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AENTREGA")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("NN8_QTDFIX")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("FIXENT")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AFIXENT")	, Nil, "SUM", oBreak1, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("SLDFIX")   , Nil, "SUM", oBreak1, , , , .f., .f. )
	
	
	oBreak2 := TRBreak():New( oSection2, {||(cAlT2)->(NJ0_CODENT+NJ0_LOJENT+NJR_CODSAF)}, STR0028, .f. )//"Total  Safra-->"
	TRFunction():New(oSection1:Cell("NJR_QTDCTR")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDSUP")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDADT")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("ENTREGUE")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AENTREGA")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("NN8_QTDFIX")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("FIXENT")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AFIXENT")	, Nil, "SUM", oBreak2, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("SLDFIX")   , Nil, "SUM", oBreak2, , , , .f., .f. )
	
	oBreak3 := TRBreak():New( oSection2, {||(cAlT2)->(NJ0_CODENT+NJ0_LOJENT)}, STR0029, .f. )//"Total Loja -->"
	TRFunction():New(oSection1:Cell("NJR_QTDCTR")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDSUP")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDADT")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("ENTREGUE")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AENTREGA")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("NN8_QTDFIX")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("FIXENT")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AFIXENT")	, Nil, "SUM", oBreak3, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("SLDFIX")   , Nil, "SUM", oBreak3, , , , .f., .f. )
	
	oBreak4 := TRBreak():New( oSection2, {||(cAlT2)->(NJ0_CODENT)}, STR0030, .f. )//"Total Entidade -->"
	TRFunction():New(oSection1:Cell("NJR_QTDCTR")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDSUP")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDADT")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("ENTREGUE")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AENTREGA")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("NN8_QTDFIX")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("FIXENT")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AFIXENT")	, Nil, "SUM", oBreak4, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("SLDFIX")   , Nil, "SUM", oBreak4, , , , .f., .f. )
	
    oBreak5 := TRBreak():New( oSection2,  {||}, STR0031, .f. )//"Total Geral -->"
	TRFunction():New(oSection1:Cell("NJR_QTDCTR")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDSUP")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("QTDADT")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("ENTREGUE")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AENTREGA")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("NN8_QTDFIX")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("FIXENT")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("AFIXENT")	, Nil, "SUM", oBreak5, , , , .f., .f. )
	TRFunction():New(oSection1:Cell("SLDFIX")   , Nil, "SUM", oBreak5, , , , .f., .f. )

Return( oReport )

/** {Protheus.doc} PrintReport
Gerar o relatório.
@param: 	oReport
@author: 	Jean Carlos Pontes Schulze
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function PrintReport( oReport ) 
	Local oS1		:= oReport:Section( 1 )
	Local oS2		:= oReport:Section( 2 )
	
	Local cFilDe	:= mv_par01
	Local cFilAte	:= mv_par02
	Local cEntDe	:= mv_par03
	Local cLojDe	:= mv_par04
	Local cEntAte	:= mv_par05	
	Local cLojAte	:= mv_par06	
	Local cProdDe	:= mv_par07
	Local cProdAte	:= mv_par08
	Local cSafrDe	:= mv_par09
	Local cSafrAte	:= mv_par10
	Local cCtrDe	:= mv_par11
	Local cCtrAte	:= mv_par12	
	Local cTipCtr	:= mv_par13
		
	Local cFiltro	:= ""
			
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	cFiltro += " AND NJR.NJR_FILIAL >= '" + cFilDe  + "' AND NJR.NJR_FILIAL <= '" + cFilAte  + "' "
	cFiltro += " AND NJR.NJR_CODENT >= '" + cEntDe  + "' AND NJR.NJR_CODENT <= '" + cEntAte  + "' "
	cFiltro += " AND NJR.NJR_LOJENT >= '" + cLojDe  + "' AND NJR.NJR_LOJENT <= '" + cLojAte  + "' "	
	cFiltro += " AND NJR.NJR_CODPRO >= '" + cProdDe + "' AND NJR.NJR_CODPRO <= '" + cProdAte + "' "
	cFiltro += " AND NJR.NJR_CODSAF >= '" + cSafrDe + "' AND NJR.NJR_CODSAF <= '" + cSafrAte + "' "
	cFiltro += " AND NJR.NJR_CODCTR >= '" + cCtrDe  + "' AND NJR.NJR_CODCTR <= '" + cCtrAte  + "' "
	IF cTipCtr = 1 //compra		
		cFiltro += "AND NJR.NJR_TIPO = '1'"
	elseif cTipCtr = 2	//venda
		cFiltro += "AND NJR.NJR_TIPO = '2' "
	else //ambos
	    cFiltro += "AND (NJR_TIPO = '1' OR NJR_TIPO = '2') "
	endif    
		
	//cFiltro := "%" + cFiltro + "%"
		
	CriaTT(cFiltro) //cria a tabela temporária dos dados
		    	
	DbSelectArea( cAlt2 )	
	(cAlt2)->( dbGoTop() )
	
	oS2:Init()	
	
	While .Not. (cAlt2)->( Eof( ) )
		
		/*Print Cabecalho*/
		oS2:PrintLine( )
								
		/*Print Contratos*/
		oS1:Init()
	    	
		DbSelectArea( cAlt1 )	/*filial*/
		(cAlt1)->(dbSeek((cAlt2)->NJ0_CODENT + (cAlt2)->NJ0_LOJENT + (cAlt2)->NJR_CODSAF + (cAlt2)->NJR_CODPRO))
			
		While .Not. (cAlt1)->( Eof( ) ) .AND. ( (cAlt2)->NJ0_CODENT = (cAlt1)->NJ0_CODENT .AND. (cAlt2)->NJ0_LOJENT = (cAlt1)->NJ0_LOJENT  .AND. (cAlt2)->NJR_CODSAF = (cAlt1)->NJR_CODSAF .AND. (cAlt2)->NJR_CODPRO = (cAlt1)->NJR_CODPRO    )
			oS1:PrintLine( )
						
			(cAlt1)->( dbSkip() )
		EndDo
		
		oS1:Finish()		
		/*Fim print Contratos*/	
					
		(cAlt2)->( dbSkip() )
	EndDo
	
	oS2:Finish()	
	
		
Return( )

/** {Protheus.doc} CriaTT
Cria os registros das tabelas temporárias.
@param: 	cFiltro
@author: 	Jean Carlos Pontes Schulze
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
static Function CriaTT(cFiltro)
	Local cQuery 	:= ''
	Local cQuery8 	:= ''
	
	Private cAliasNN8 := GetNextAlias()
	Private cAliasNJR := GetNextAlias()	
	
	Private iQtFix    := 0
	Private iPrcUnTot := 0
	Private iQtSldFix := 0 
		
	//Query Contratos	
	//BeginSql Alias cAliasNJR
	//	Select *
	//	From %table:NJR% NJR
	//	WHERE NJR.%notDel%
	//	  AND NJR_FILIAL = %Exp:xFilial('NJR')%
	//	  AND %Exp:cFiltro% 
	//EndSQL
	
	cQuery := ""
	cQuery += " SELECT NJR.*"
	cQuery +=   " FROM " + RetSqlName('NJR')+ " NJR "
	cQuery +=  " WHERE NJR.D_E_L_E_T_  = '' "
	cQuery += cFiltro	//*** FILTRO
	cQuery := ChangeQuery(cQuery)
	If select("cAliasNJR") <> 0
		cAliasNJR->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJR,.T.,.T.)
	
	DbSelectArea( cAliasNJR )		
	(cAliasNJR)->( dbGoTop() )
	
	While .Not. (cAliasNJR)->( Eof( ) )
		
		//reset variaveis
		iQtSldFix := 0 
		iQtFix    := 0
		iPrcUnTot := 0
		
		/**************Criar cabecalho da entidade**************/

		DbSelectArea( cAlt2 )	
		If .not. (cAlt2)->(dbSeek((cAliasNJR)->NJR_CODENT + (cAliasNJR)->NJR_LOJENT + (cAliasNJR)->NJR_CODSAF  + (cAliasNJR)->NJR_CODPRO))
			
			//Não existe cabecalho, cria
			Reclock(cAlt2, .T.)	
				(cAlt2)->NJ0_CODENT := (cAliasNJR)->NJR_CODENT	//Entidade
				(cAlt2)->NJ0_NOME   := POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,'NJ0_NOME') //NOME
				(cAlt2)->NJ0_LOJENT := (cAliasNJR)->NJR_LOJENT	//LOJA
				(cAlt2)->NJR_CODSAF := (cAliasNJR)->NJR_CODSAF	//SAFRA
				(cAlt2)->NJR_CODPRO := (cAliasNJR)->NJR_CODPRO	//PRODUTO
				(cAlt2)->NJR_DESPRO := POSICIONE('SB1',1,XFILIAL('SB1')+(cAliasNJR)->NJR_CODPRO,'B1_DESC')	//DESCRICAO
				(cAlt2)->NJR_UM1PRO := (cAliasNJR)->NJR_UM1PRO	//UM
			MsUnlock()
			
		Endif
			
		cQuery8 := ""
		cQuery8 += " SELECT NN8.*"
		cQuery8 +=   " FROM " + RetSqlName('NN8')+ " NN8 "
		cQuery8 +=  " WHERE NN8.D_E_L_E_T_  = '' "
		cQuery8 += " AND NN8_FILIAL  = '" + (cAliasNJR)->NJR_FILIAL + "'" 
		cQuery8 += " AND NN8_CODCTR  = '" + (cAliasNJR)->NJR_CODCTR + "'"
		cQuery8 += " AND NN8_TIPOFX  = '1' "	//somente firme
		
		cQuery8 := ChangeQuery(cQuery8)
		If select("cAliasNN8") <> 0
			cAliasNN8->( dbCloseArea() )
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery8),cAliasNN8,.T.,.T.)
				
		DbSelectArea( cAliasNN8 )
		(cAliasNN8)->(DbGoTop())
	    
		While  .Not. (cAliasNN8)->( Eof( ) )			
			
	
			Reclock(cAlt1, .T.)			
				(cAlt1)->NJR_FILIAL := (cAliasNJR)->NJR_FILIAL	//Filial
				(cAlt1)->NJ0_CODENT := (cAliasNJR)->NJR_CODENT	//Entidade
				(cAlt1)->NJ0_LOJENT := (cAliasNJR)->NJR_LOJENT	//LOJA
				(cAlt1)->NJR_CODSAF := (cAliasNJR)->NJR_CODSAF	//SAFRA
				(cAlt1)->NJR_CODPRO := (cAliasNJR)->NJR_CODPRO	//PRODUTO			
				(cAlt1)->NJR_CODCTR := (cAliasNJR)->NJR_CODCTR	//Contrato
				(cAlt1)->NJR_DATA	:= StoD((cAliasNN8)->NN8_DATA)    //Data da Fixação
				(cAlt1)->NJR_QTDCTR := 0		
				(cAlt1)->MOEDA      := SuperGetMV("MV_SIMB"+AllTrim(Str((cAliasNN8)->NN8_MOEDA)))	//MOEDA				
				(cAlt1)->NJR_UMPRC  := (cAliasNJR)->NJR_UMPRC  //Unidade de medida
				(cAlt1)->QTDSUP     := 0
				(cAlt1)->QTDADT		:= 0	
				(cAlt1)->ENTREGUE   := 0 
				(cAlt1)->AENTREGA   := 0 
				(cAlt1)->NN8_QTDFIX := (cAliasNN8)->NN8_QTDFIX 
				(cAlt1)->FIXENT     := GetEntFix((cAliasNN8)->NN8_CODCTR, (cAliasNN8)->NN8_ITEMFX) //quantidade entregue que foi fixada
				(cAlt1)->AFIXENT    := (cAliasNN8)->NN8_QTDFIX - (cAlt1)->FIXENT //quantidade a entregar da fixação
				(cAlt1)->PRCUNIT    := (cAliasNN8)->NN8_VLRUNI //Valor unitário da fixação 
				(cAlt1)->SLDFIX     := 0
				(cAlt1)->TIPO       := "2" //1- Contrato, 2- Fixação
				(cAlt1)->TIPFIX     := STR0043
										 
			MsUnlock()	
			
			//Soma quantidade fixada
			iQtSldFix := (cAliasNN8)->NN8_QTDFIX + iQtSldFix
			
			(cAliasNN8)->( dbSkip() )
		
		end	
		(cAliasNN8)->(dbCloseArea())	
		
		/****************Criação dos dados do Contrato*********************/
				
		Reclock(cAlt1, .T.)
			(cAlt1)->NJR_FILIAL  := (cAliasNJR)->NJR_FILIAL	//Filial
			(cAlt1)->NJ0_CODENT  := (cAliasNJR)->NJR_CODENT	//Entidade
			(cAlt1)->NJ0_LOJENT  := (cAliasNJR)->NJR_LOJENT	//LOJA
			(cAlt1)->NJR_CODSAF  := (cAliasNJR)->NJR_CODSAF	//SAFRA
			(cAlt1)->NJR_CODPRO  := (cAliasNJR)->NJR_CODPRO	//PRODUTO			
			(cAlt1)->NJR_CODCTR  := (cAliasNJR)->NJR_CODCTR	//CONTRATO
			(cAlt1)->QTDSUP      := GetUpdCtr((cAliasNJR)->NJR_CODCTR,2)  //Supressões
			(cAlt1)->QTDADT		 := GetUpdCtr((cAliasNJR)->NJR_CODCTR,1)  //Aditamentos	
			(cAlt1)->NJR_DATA    := StoD((cAliasNJR)->NJR_DATA)	//DATA
			(cAlt1)->NJR_QTDCTR  := (cAliasNJR)->NJR_QTDCTR    // Quantidade do Contrato
			(cAlt1)->MOEDA       := SuperGetMV("MV_SIMB"+AllTrim(Str((cAliasNJR)->NJR_MOEDA)))	//MOEDA
			(cAlt1)->NJR_UMPRC   := (cAliasNJR)->NJR_UMPRC //CONTRATO			
			(cAlt1)->ENTREGUE    := iIf( (cAliasNJR)->NJR_TIPO = "1" , (cAliasNJR)->NJR_QTEFCO - (cAliasNJR)->NJR_QTSFCO, (cAliasNJR)->NJR_QTSFCO - (cAliasNJR)->NJR_QTEFCO)
			(cAlt1)->AENTREGA    := (cAlt1)->NJR_QTDCTR - (cAlt1)->ENTREGUE 
		
			(cAlt1)->FIXENT      := 0  
			(cAlt1)->AFIXENT     := 0
			
			(cAlt1)->SLDFIX      := (cAlt1)->NJR_QTDCTR - iQtSldFix
			
			(cAlt1)->TIPO        := "1"  //1- Contrato, 2- Fixação
			(cAlt1)->TIPFIX      := iIf( (cAliasNJR)->NJR_TIPFIX = "1" , STR0044, STR0045)
												
			
		MsUnlock()	
		
		(cAliasNJR)->( dbSkip() )
		
	end	
	(cAliasNJR)->(dbCloseArea())
	

return()

/** {Protheus.doc} GetEntFix
Obtem o total das entregas da fixação.
@param: 	Filial, CodCtr, ItemFx
@author: 	Jean Carlos Pontes Schulze
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

static Function GetEntFix(cCodCtr, cItemFx)
	Local cQueryC 	:= ''

	Private cAliasNNC := GetNextAlias()
	Private iQtFixEnt := 0
	
	cQueryC := ""
	cQueryC += " SELECT NNC.NNC_QTDENT"
	cQueryC +=   " FROM " + RetSqlName('NNC')+ " NNC "
	cQueryC +=  " WHERE NNC.D_E_L_E_T_  = '' "
	cQueryC += " AND NNC.NNc_FILIAL = '" + (cAliasNJR)->NJR_FILIAL + "'"
	cQueryC += " AND NNC.NNC_CODCTR  = '" + cCodCtr + "'"
	cQueryC += " AND NNC.NNC_ITEMFX  = '" + cItemFx + "'"
		
	cQueryC := ChangeQuery(cQueryC)
	If select("cAliasNNC") <> 0
		cAliasNNC->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryC),cAliasNNC,.T.,.T.)
		
	DbSelectArea( cAliasNNC )
	(cAliasNNC)->(DbGoTop())
	
	While  .Not. (cAliasNNC)->( Eof( ) )
		
		iQtFixEnt := iQtFixEnt + (cAliasNNC)->NNC_QTDENT
		
		(cAliasNNC)->( dbSkip() )
	end.
	(cAliasNNC)->(dbCloseArea())
			
return(iQtFixEnt) 

/** {Protheus.doc} GetUpdCtr
Obtem o total dos aditamentos/supressões do Contrato.
@param: 	Filial, CodCtr, Tipo (1 - Adicao, 2- supressao)
@author: 	Jean Carlos Pontes Schulze
@since: 	10/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
static Function GetUpdCtr(cCodCtr, nTipo)
	Local cQueryW 	:= ''

	Private cAliasNNW := GetNextAlias()
	Private iQtUpdCtr := 0
	
	cQueryW := ""
	cQueryW += " SELECT NNW.NNW_QTDALT"
	cQueryW +=   " FROM " + RetSqlName('NNW')+ " NNW "
	cQueryW +=  " WHERE NNW.D_E_L_E_T_  = '' "
	cQueryW += " AND NNW.NNW_FILIAL = '" + (cAliasNJR)->NJR_FILIAL + "'"
	cQueryW += " AND NNW.NNW_CODCTR  = '" + cCodCtr + "'"
	cQueryW += " AND NNW.NNW_TIPO  	 = '" + STR(nTipo) + "'"
		
	cQueryW := ChangeQuery(cQueryW)
	If select("cAliasNNW") <> 0
		cAliasNNW->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryW),cAliasNNW,.T.,.T.)
		
	DbSelectArea( cAliasNNW )
	(cAliasNNW)->(DbGoTop())
	
	While  .Not. (cAliasNNW)->( Eof( ) )
		
		iQtUpdCtr := iQtUpdCtr + (cAliasNNW)->NNW_QTDALT
		
		(cAliasNNW)->( dbSkip() )
	end.
	(cAliasNNW)->(dbCloseArea())
			
return(iQtUpdCtr) 

