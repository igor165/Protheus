#Include 'Protheus.ch'
#Include "report.ch"
#Include "TECR180.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECR060
@description	Relatório Sindicato X Orçamento
@sample	 	TECR180() 
@param		Nenhum
@return		Nil
@author		filipe.goncalves
@since		15/04/2016
@version	P12   
/*/
//------------------------------------------------------------------------------

Function TECR180()
Local aArea := GetArea()	//Guarda a area atual
Local oReport	
Local oSecPai
Local oSecFilha
Local oSecNeta

Private cPerg := "TECR180"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Do Contrato ?                                               ³
//³ MV_PAR02 : Até Contrato ?                                              ³
//³ MV_PAR03 : Do Sindicato ?                                              ³
//³ MV_PAR04 : Até Sindicato ?	                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
Pergunte(cPerg, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a criacao do objeto oReport  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "TECR180" TITLE STR0001 PARAMETER "TECR180" ACTION {|oReport| PrintReport(oReport,cPerg)} //"Sindicato X Orçamento"
	oReport:SetLandscape() //Escolher o padrão de Impressao como Paisagem 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao1 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SECTION oSecPai OF oReport TITLE STR0002//"Orçamento"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao1  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE CELL NAME "TFJ_CODIGO" 	OF oSecPai TITLE STR0002 ALIAS "TFJ"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao2 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DEFINE SECTION oSecFilha OF oSecPai TITLE STR0003 TABLE "RCE" LEFT MARGIN 5	//"Sindicato" 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao2  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE CELL NAME "RCE_CODIGO" OF oSecFilha ALIAS "RCE"  	    
		DEFINE CELL NAME "RCE_DESCRI" OF oSecFilha ALIAS "RCE"     
		DEFINE CELL NAME "RCE_MESDIS" OF oSecFilha ALIAS "RCE"         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao3 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	DEFINE SECTION oSecNeta OF oSecFilha TITLE STR0004 TABLE "TFF", "ABS", "SRJ" LEFT MARGIN 10 //"Itens Orçamento"	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao3  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
		DEFINE CELL NAME "TFF_ITEM"		OF oSecNeta ALIAS "TFF"  
		DEFINE CELL NAME "TFF_LOCAL"	OF oSecNeta ALIAS "TFF"
		DEFINE CELL NAME "ABS_DESCRI"	OF oSecNeta ALIAS "ABS"
		DEFINE CELL NAME "TFF_CONTRT"	OF oSecNeta ALIAS "TFF" 
		DEFINE CELL NAME "TFF_QTDVEN"	OF oSecNeta ALIAS "TFF"      
		DEFINE CELL NAME "TFF_PERINI"	OF oSecNeta ALIAS "TFF"  
		DEFINE CELL NAME "TFF_PERFIM"	OF oSecNeta ALIAS "TFF" 	    
		DEFINE CELL NAME "TFF_FUNCAO"	OF oSecNeta ALIAS "TFF"     
		DEFINE CELL NAME "RJ_DESC"		OF oSecNeta ALIAS "SRJ" 
	
oReport:PrintDialog()

RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Vendas CRM         º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Selecao dos itens a serem impressos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATRX X                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport,cPerg)
Local oSection1 	:= oReport:Section(1)						//Define como seção Pai
Local oSection2	:= oReport:Section(1):Section(1)			//Define a secao Filha 
Local oSection3	:= oReport:Section(1):Section(1):Section(1)	//Define a secao Neta  
Local cAlias 		:= GetNextAlias()
Local cChave1		:= ""
Local cChave2		:= ""
Local cCTRDe		:= ""
Local cCTRAte		:= ""
Local cSindDe		:= ""
Local cSindAte	:= ""

Pergunte( cPerg , .F. )

cCTRDe		:= MV_PAR01
cCTRAte	:= MV_PAR02
cSindDe	:= MV_PAR03
cSindAte	:= MV_PAR04
		
MakeSqlExp(cPerg)
	
BEGIN REPORT QUERY oSection1
	BEGIN REPORT QUERY oSection2
		BEGIN REPORT QUERY oSection3

			BeginSql alias cAlias

				SELECT TFJ.TFJ_CODIGO, RCE.RCE_CODIGO, RCE.RCE_DESCRI, RCE.RCE_MESDIS, TFF.TFF_ITEM,   TFF.TFF_LOCAL, ABS.ABS_DESCRI, 
				       TFF.TFF_CONTRT, TFF.TFF_QTDVEN, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_FUNCAO, SRJ.RJ_DESC
				 FROM  %Table:TFJ% TFJ
				       INNER JOIN %Table:TFL% TFL On TFL.%NotDel%
				                                 And TFL.TFL_FILIAL = %xfilial:TFL%
				                                 And TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
				       INNER JOIN %Table:TFF% TFF On TFF.%NotDel%
				                                 And TFF.TFF_FILIAL = %xfilial:TFF%
				                                 And TFF.TFF_CODPAI = TFL.TFL_CODIGO
				       INNER JOIN %Table:RCE% RCE On RCE.%NotDel%
				                                 And RCE.RCE_FILIAL = %xfilial:RCE%
				                                 And RCE.RCE_CODIGO = TFF.TFF_CODISS
				       INNER JOIN %Table:ABS% ABS ON ABS.%NotDel%
				                                 And ABS.ABS_FILIAL = %xfilial:ABS%
				                                 And ABS.ABS_LOCAL = TFF.TFF_LOCAL
				       INNER JOIN %Table:SRJ% SRJ ON SRJ.%NotDel%
				                                 And SRJ.RJ_FILIAL  = %xfilial:SRJ%
				                                 And SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
				 WHERE TFJ.TFJ_FILIAL = %xfilial:TFJ%
				   AND TFJ.TFJ_CODIGO >= %Exp:cCTRDe%
				   AND TFJ.TFJ_CODIGO <= %Exp:cCTRAte%
				   AND TFF.TFF_CODISS >= %Exp:cSindDe%
				   AND TFF.TFF_CODISS <= %Exp:cSindAte%
				   AND TFF.TFF_CONTRT <> ''
				   AND TFF.TFF_ITEM <> ''
				   AND TFJ.%NotDel% 

				ORDER BY TFJ_CODIGO, RCE_CODIGO, TFF_ITEM,TFF_LOCAL

			EndSql

		END REPORT QUERY oSection1
	END REPORT QUERY oSection2
END REPORT QUERY oSection3
	
dbSelectArea(cAlias)
While !oReport:Cancel() .And. !(cAlias)->(Eof())
	oSection1:Init()
	oSection1:PrintLine()
	cChave1	:= (cAlias)->TFJ_CODIGO 

	While !oReport:Cancel() .And. !(cAlias)->(Eof()) .AND. cChave1	== (cAlias)->TFJ_CODIGO 
	
		oSection2:Init()
		oSection2:PrintLine()
		cChave2	:= (cAlias)->TFJ_CODIGO + (cAlias)->RCE_CODIGO 

		oSection3:Init()
		While !oReport:Cancel() .And. !(cAlias)->(Eof()) .AND. cChave2	== (cAlias)->TFJ_CODIGO + (cAlias)->RCE_CODIGO 
			oSection3:PrintLine()
			(cAlias)->(dbSkip())
		EndDo

		oSection3:Finish()
		oSection2:Finish()

	EndDo
	oSection1:Finish()
EndDo
	
(cAlias)->(DbCloseArea())
Return Nil