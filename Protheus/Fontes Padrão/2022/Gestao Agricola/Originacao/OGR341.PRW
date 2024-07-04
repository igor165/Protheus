#INCLUDE "OGR341.ch"
#include "protheus.ch"

/** {Protheus.doc} OGR341
Resumo Contratos de Autorizações

@param: 	Nil
@author: 	Jean Carlos Pontes Schulze	
@since: 	20/05/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGR341()
	Local aAreaAtu 	  := GetArea()
	Local oReport	  := Nil
	Private vVetAut, vRetAut
	Private vVetRom, vRetRom
	Private cNoT1, cAlT1, aAlT1, cNoT2, cAlT2, aAlT2
	
	Private cPergunta := "OGR341001"
	
	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- Autorizações				||
	+================================================*/
	vVetAut := {	{"NJP_CODCTR"},	;
					{"NJP_ITEM"},		; //codaut
					{"NJP_TIPO"},		; //tipo
					{"NJP_CODTER"},	; //terceiro
					{"NOMTERC", "C",20,0,"@!", STR0008},; //NomeTerc
					{"NJP_TALHAO"},	;
					{"NJP_QTDAUT"},	;
					{"NJP_QTDEXC"},	; //Data
					{"NJP_QTDFCO"},	; //QtdContrato
					{"QTDSDO","N",TamSX3("NJP_QTDAUT")[1],TamSX3("NJP_QTDAUT")[2],"Qdte Saldo" ,PesqPict('NJP',"NJP_QTDFCO")}} //QTD SALDO
	
	vRetAut := AGRCRIATRB(,vVetAut,{"NJP_CODCTR"},STR0001,.T.) //"OGR341"	//FUNCAO DO AGRUTIL01
	cNoT1 := vRetAut[3]	//INDICE
	cAlT1 := vRetAut[4] //ALIAS        
	aAlT1 := vRetAut[5]	//ARRAY 

	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- Romaneios               ||
	+================================================*/
	vVetRom := {	{"NJM_CODCTR"},	;
					{"NJM_CODAUT"},	;
					{"NJM_FILIAL"},	;
					{"NJM_CODROM"},	;
					{"cTipoRo", 		"C", 30, 0, "@!", STR0006},; //Tipo
					{"cStatus", 		"C", 10, 0, "@!", STR0029},; //Status
					{"NJM_CODSAF"},	;
					{"NJM_CODPRO"},	;
					{"cDescProdu",	"C",30,0,"@!", STR0031},; //Des.Produto
					{"NJM_DTRANS"},	;
					{"NJM_DOCNUM"},	;
					{"NJM_DOCSER"},	;
					{"NJM_DOCEMI"},	;
					{"NJM_QTDFCO"}}


	vRetRom := AGRCRIATRB(,vVetRom,{"NJM_CODCTR+NJM_CODAUT"},STR0001,.T.) //"OGR341"	//FUNCAO DO AGRUTIL01
	cNoT2 := vRetRom[3]	//INDICE
	cAlT2 := vRetRom[4] //ALIAS        
	aAlT2 := vRetRom[5]	//ARRAY 		
	
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
@since: 	20/05/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1	:= Nil
	
	oReport := TReport():New(STR0001, STR0002, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002) //"Resumo de autorizações"###"
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()	
	
	/*Monta as Colunas*/
	
	oSection1 := TRSection():New( oReport, STR0003, cAlT1 ) //"Autorizações"

	TRCell():New( oSection1, "NJP_CODCTR"	, cAlT1, STR0004, , TamSX3("NJP_CODCTR")[1]) //Contrato
	TRCell():New( oSection1, "NJP_ITEM"	, cAlT1, STR0005, , TamSX3("NJP_ITEM")[1])   //Item
	TRCell():New( oSection1, "NJP_TIPO"	, cAlT1, STR0006, , TamSX3("NJP_TIPO")[1])   //Tipo
	TRCell():New( oSection1, "NJP_CODTER"	, cAlT1, STR0007, , TamSX3("NJP_CODTER")[1]) //Cód Terc.
	TRCell():New( oSection1, "NOMTERC"		, cAlT1, STR0008, , TamSX3("NJ0_NOME")[1])   //Nome Terc.
	TRCell():New( oSection1, "NJP_TALHAO"	, cAlT1, STR0030, , TamSX3("NJP_TALHAO")[1]) //Talhao
	TRCell():New( oSection1, "NJP_QTDAUT"	, cAlT1, STR0009, , TamSX3("NJP_QTDAUT")[1]) //Qdte Autzado
	TRCell():New( oSection1, "NJP_QTDEXC"	, cAlT1, STR0010, , TamSX3("NJP_QTDEXC")[1]) //Qdte Autzado Excdte
	TRCell():New( oSection1, "NJP_QTDFCO"	, cAlT1, STR0011, , TamSX3("NJP_QTDFCO")[1]) //Qdte Total Mvtada
	TRCell():New( oSection1, "QTDSDO"		, cAlT1, STR0012, PesqPict('NJP',"NJP_QTDFCO") , TamSX3("NJP_QTDFCO")[1]) //Qdte Saldo


	oSection2:= TRSection():New( oReport, STR0013, cAlT2 ) //"Romaneios"
	oSection2:SetLeftMargin(5)
	TRCell():New( oSection2, "NJM_FILIAL"	, cAlT2, STR0032, , TamSX3("NJM_FILIAL")[1])	//Filial
	TRCell():New( oSection2, "NJM_CODROM"	, cAlT2, STR0015, , TamSX3("NJM_CODROM")[1])	//Romaneio
	TRCell():New( oSection2, "cTipoRo"		, cAlT2, STR0006, "!@" , 30) 					//Tipo
	TRCell():New( oSection2, "cSTATUS"		, cAlT2, STR0029, "!@" , 15)					//Status
	TRCell():New( oSection2, "NJM_CODSAF"	, cAlT2, STR0016, , TamSX3("NJM_CODSAF")[1])	//Safra
	TRCell():New( oSection2, "NJM_CODPRO"	, cAlT2, STR0017, , TamSX3("NJM_CODPRO")[1])	//Produto
	TRCell():New( oSection2, "cDescProdu"	, cAlT2, STR0031, "!@" , 30)					//Desc.Produto
	TRCell():New( oSection2, "NJM_DTRANS"	, cAlT2, STR0018, , TamSX3("NJM_DTRANS")[1])	//Dt Transação
	TRCell():New( oSection2, "NJM_DOCNUM"	, cAlT2, STR0019, , TamSX3("NJM_DOCNUM")[1])	//Num. Docto
	TRCell():New( oSection2, "NJM_DOCSER"	, cAlT2, STR0020, , TamSX3("NJM_DOCSER")[1])	//Série
	TRCell():New( oSection2, "NJM_DOCEMI"	, cAlT2, STR0022, , TamSX3("NJM_DOCEMI")[1])	//Dt Emissão
	TRCell():New( oSection2, "NJM_QTDFCO"	, cAlT2, STR0023, , TamSX3("NJM_QTDFCO")[1])	//Qt.Físico


Return( oReport )

/** {Protheus.doc} PrintReport
Gerar o relatório.
@param: 	oReport
@author: 	Jean Carlos Pontes Schulze
@since: 	20/05/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function PrintReport( oReport ) 
	Local oS1		:= oReport:Section( 1 )
	Local oS2		:= oReport:Section( 2 )
			
	Local cCtrDe	:= mv_par01
	Local cCtrAte	:= mv_par02
	Local lSaltaL := "N"
	Local cFiltro	:= ""
			
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	cFiltro += "NJP.NJP_CODCTR >= '" + cCtrDe + "' And NJP.NJP_CODCTR <= '" + cCtrAte + "' "  
		
	cFiltro := "%" + cFiltro + "%"
		
	CriaTT(cFiltro) //cria a tabela temporária dos dados

	DbSelectArea( cAlt1 )
	(cAlt1)->( dbGoTop() )
	
	oS1:Init()
	
	While .Not. (cAlt1)->( Eof( ) )
		lSaltaL := "N" // Salta Linha

		/*Print Cabecalho*/
		oS1:PrintLine( )

		/*Print Romaneios*/
		oS2:Init()

		DbSelectArea( cAlt2 )
		(cAlt2)->(dbSeek((cAlt1)->NJP_CODCTR + (cAlt1)->NJP_ITEM ))

		While .Not. (cAlt2)->( Eof( ) ) .AND. ( (cAlt1)->NJP_CODCTR = (cAlt2)->NJM_CODCTR  .AND. (cAlt1)->NJP_ITEM = (cAlt2)->NJM_CODAUT )
			lSaltaL := "S"
			oS2:PrintLine( )

			(cAlt2)->( dbSkip() )
		EndDo

		if lSaltaL == "S"
			oReport:SkipLine(1)
		Endif

		oS2:Finish()		
		/*Fim print Contratos*/	
					
		(cAlt1)->( dbSkip() )
	EndDo
	
	oS1:Finish()	
	
		
Return( )




static Function CriaTT(cFiltro)
	Local nQTDSDO := 0
	Private cAliasNJP := GetNextAlias() //Autorização
	Private cAliasNJM := GetNextAlias() //Itens do Romaneios
	
	//Query Autorizações	
	BeginSql Alias cAliasNJP
		Select *
		From %table:NJP% NJP
		WHERE NJP.%notDel%
		  AND NJP.NJP_FILIAL = %Exp:xFilial('NJP')%
		  AND %Exp:cFiltro% 
	EndSQL


	DbSelectArea( cAliasNJP )
	(cAliasNJP)->( dbGoTop() )

	While .Not. (cAliasNJP)->( Eof( ) )

		/**************Criar cabecalho da autorização**************/

		DbSelectArea( cAlt1 )
		Reclock(cAlt1, .T.)
			(cAlt1)->NJP_CODCTR	:= (cAliasNJP)->NJP_CODCTR
			(cAlt1)->NJP_ITEM		:= (cAliasNJP)->NJP_ITEM
			(cAlt1)->NJP_TIPO		:= (cAliasNJP)->NJP_TIPO
			(cAlt1)->NJP_CODTER	:= (cAliasNJP)->NJP_CODTER
			(cAlt1)->NOMTERC		:= Posicione( "NJ0", 1, xFilial( "NJ0" ) + (cAliasNJP)->NJP_CODTER + (cAliasNJP)->NJP_LOJTER, "NJ0_NOME" )
			(cAlt1)->NJP_TALHAO	:= (cAliasNJP)->NJP_TALHAO
			(cAlt1)->NJP_QTDAUT	:= (cAliasNJP)->NJP_QTDAUT
			(cAlt1)->NJP_QTDEXC	:= (cAliasNJP)->NJP_QTDEXC
			(cAlt1)->NJP_QTDFCO	:= (cAliasNJP)->NJP_QTDFCO
			nQTDSDO := (cAliasNJP)->NJP_QTDAUT - (cAliasNJP)->NJP_QTDFCO
			(cAlt1)->QTDSDO		:= IIF(nQTDSDO < 0 , 0 , nQTDSDO)
		MsUnlock()

		if mv_par03 = 1

			//Query Itens do Romaneio
			BeginSql Alias cAliasNJM
				SELECT NJM.*, NJJ.*
				  FROM %Table:NJM% NJM
				  INNER JOIN %table:NJJ% NJJ
				    ON NJJ.%notDel%
				   AND NJJ.NJJ_FILIAL = %xFilial:NJJ%
				   AND NJJ.NJJ_CODROM  = NJM.NJM_CODROM
				 WHERE NJM.%notDel%
				   AND NJM.NJM_FILIAL = %Exp:xFilial('NJM')%
				   AND NJM.NJM_CODCTR = %Exp:(cAliasNJP)->NJP_CODCTR%
				   AND NJM.NJM_CODAUT = %Exp:(cAliasNJP)->NJP_ITEM%
			EndSQL

			DbSelectArea( cAliasNJM )
			(cAliasNJM)->(DbGoTop())

			While .Not. (cAliasNJM)->( Eof( ) )	

				Reclock(cAlt2, .T.)
					(cAlt2)->NJM_FILIAL	:= (cAliasNJM)->NJM_FILIAL
					(cAlt2)->NJM_CODCTR	:= (cAliasNJM)->NJM_CODCTR
					(cAlt2)->NJM_CODAUT	:= (cAliasNJM)->NJM_CODAUT
					(cAlt2)->NJM_CODROM	:= (cAliasNJM)->NJM_CODROM
					(cAlt2)->cTipoRo		:= Posicione("SX5",1,xFilial("SX5")+"K5"+(cAliasNJM)->NJJ_TIPO,"X5DESCRI()")
					(cAlt2)->cSTATUS		:=  X3CboxDesc( "NJJ_STATUS", (cAliasNJM)->NJJ_STATUS )
					(cAlt2)->NJM_CODSAF	:= (cAliasNJM)->NJM_CODSAF
					(cAlt2)->NJM_CODPRO	:= (cAliasNJM)->NJM_CODPRO
					(cAlt2)->cDescProdu	:=  Posicione("SB1",1,xFilial("SB1")+(cAliasNJM)->NJM_CODPRO,"B1_DESC")
					(cAlt2)->NJM_DTRANS	:=  StoD((cAliasNJM)->NJM_DTRANS)
					(cAlt2)->NJM_DOCNUM	:= (cAliasNJM)->NJM_DOCNUM
					(cAlt2)->NJM_DOCSER	:= (cAliasNJM)->NJM_DOCSER
					(cAlt2)->NJM_DOCEMI	:=  StoD((cAliasNJM)->NJM_DOCEMI)
					(cAlt2)->NJM_QTDFCO	:= (cAliasNJM)->NJM_QTDFCO
				MsUnlock()

			(cAliasNJM)->( dbSkip() )
			end
			(cAliasNJM)->(dbCloseArea())	
		end
		
		(cAliasNJP)->( dbSkip() )		
	end
	(cAliasNJP)->(dbCloseArea())

return()


