#INCLUDE "REPORT.CH"
#INCLUDE "MATR281.CH"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMATR281   ณ Autor ณ Rodrigo T. Silva      ณ Data ณ 29/12/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRelacao de Claculo da Correcao Monetaria             		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MATR281()
Local oReport				//Objeto do relatorio personalizavel
Local aArea := GetArea()	//Guarda a area atual

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                       PARAMETROS                                       ณ
//ณ                                                                        ณ
//ณ MV_PAR01 : Data de Fechamento 	?                              		   ณ
//ณ MV_PAR02 : Produto ?                                      		       ณ
//ณ MV_PAR03 : Grupo ?                                      	   		   ณ
//ณ MV_PAR04 : Tipo ?                                      	   		       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("MATR281",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInterface de impressaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport := Mat281RptDef()
oReport:SetLandscape()
oReport:PrintDialog()

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMat281RptDef บAutor  ณRodrigo T. Silva    บ Data ณ  29/12/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para informar as celulas que serao utilizadas no rela-  บฑฑ
ฑฑบ          ณlatorio                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATR281                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Mat281RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local aOrdem	:= {}  
Local cAlias1	:= ""	// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1	:= GetNextAlias()
#ELSE 
	cAlias1	:= "SDZ"
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a criacao do objeto oReport  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE REPORT oReport NAME "MATR281" TITLE STR0001 PARAMETER "MTR281" ACTION {|oReport| Mtr281PrtRpt(oReport, aOrdem, cAlias1)} DESCRIPTION STR0002+STR0003 + "" //"Rela็ใo de Cแlculo da Corre็ใo Monetแria"#"   Este programa ira imprimir a Listagem de Cแlculo da Corre็ใo"#" Monetแria, conforme os parametros solicitados."
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define a secao1 do relatorio  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE SECTION oSection1 OF oReport TITLE "" TABLES "SDZ" ORDERS aOrdem
		oSection1:SetLineBreak() 
		oSection1:AutoSize() 		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Define as celulas que irao aparecer na secao1  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		DEFINE CELL NAME "DZ_PRODUTO" 	OF oSection1 ALIAS "SDZ"
		DEFINE CELL NAME "B1_DESC" 		OF oSection1 ALIAS "SDZ" BLOCK {|| Posicione("SB1",1,xFilial("SB1")+(cAlias1)->DZ_PRODUTO,"B1_DESC")}		
		DEFINE CELL NAME "DZ_MOEDA" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_MOEDA",2) HEADER ALIGN RIGHT
		DEFINE CELL NAME "DZ_DTULCOM" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_DTULCOM")
		DEFINE CELL NAME "DZ_CUULCOM" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_CUULCOM",14) HEADER ALIGN RIGHT
		DEFINE CELL NAME "DZ_DTMACOM" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_DTMACOM")
		DEFINE CELL NAME "DZ_CUMACOM" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_CUMACOM",14) HEADER ALIGN RIGHT
		DEFINE CELL NAME "DZ_FTCORRE" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_FTCORRE",14) HEADER ALIGN RIGHT 
		DEFINE CELL NAME "DZ_VLRBASE" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_VLRBASE",14) HEADER ALIGN RIGHT 
		DEFINE CELL NAME "DZ_CUUNCOR" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_CUUNCOR",14) HEADER ALIGN RIGHT 
		DEFINE CELL NAME "DZ_CUTOTCR" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_CUTOTCR",14) HEADER ALIGN RIGHT
		DEFINE CELL NAME "DZ_VLRCMON" 	OF oSection1 ALIAS "SDZ" PICTURE PesqPict("SDZ","DZ_VLRCMON",14) HEADER ALIGN RIGHT		
Return oReport
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMtr281PrtRptบAutor  ณRodrigo T. Silva    บ Data ณ  29/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                      	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoReport: Objeto TReport do relatorio personalizavel        	บฑฑ
ฑฑบ          ณaOrdem:  Array com as ordens de impressao disponiveis      	บฑฑ
ฑฑบ          ณcAlias1: Alias principal do relatorio                      	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATR281                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Mtr281PrtRpt( oReport, aOrdem, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local nOrdem 	:= 1								// Ordem definida pelo usuario
Local cOrderBy	:= ""								// Chave de ordenacao
Local cIndexKey := ""								// Indice do filtro (CodeBase)
Local cFiltro	:= ""								// Filtro da tabela (CodeBase)
Local nLin 		:= 0								// Guarda a linha atual impressa
Local lTop      := .T.	
Local lImpSDZ	:= .T.
       
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Pega a ordem escolhida pelo usuario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nOrdem := oSection1:GetOrder() 
If nOrdem <= 0
	nOrdem := 1
EndIf

#IFDEF TOP
	cDbMs	:= UPPER(TcGetDb())  //define o tipo de banco para diferenciar o operador de soma
	cOrderBy := "% DZ_FILIAL,DZ_PRODUTO %"
	cIndexKey:= "DZ_FILIAL+DZ_PRODUTO"
#ENDIF

#IFDEF TOP
	lTop := .T.
	DbSelectArea("SDZ") 
	DbSetOrder(1)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("MTR281")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BEGIN REPORT QUERY oSection1

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuery da secao1 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BeginSql alias cAlias1				
		SELECT DZ_PRODUTO, DZ_DATAFEC, DZ_MOEDA, DZ_DTULCOM, DZ_CUULCOM, DZ_DTMACOM, DZ_CUMACOM,
		       DZ_TPCORRE, DZ_FTCORRE, DZ_VLRBASE, DZ_CUUNCOR, DZ_CUTOTCR, DZ_VLRCMON		
		FROM %table:SDZ% SDZ, %table:SB1% SB1
		WHERE	SDZ.DZ_PRODUTO=SB1.B1_COD
				AND SB1.B1_FILIAL = %xfilial:SB1%
				AND SDZ.DZ_DATAFEC = %exp:mv_par01%
				AND SB1.%notDel%     
				AND SDZ.%notDel%																				
		ORDER BY %exp:cOrderBy%				
	EndSql
	oReport:Section(1):EndQuery({MV_PAR02,MV_PAR03,MV_PAR04})	
#ELSE
	lTop := .F.
	DbSelectArea(cAlias1) 
	DbSetOrder(1)	
	cFiltro := "DZ_FILIAL=='"+xFilial("SDZ")+"'.AND."
	cFiltro += "DtoS(DZ_DATAFEC)=='"+Dtos(mv_par01)+"'"
		  
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetua o filtro de acordo com a expressao do arquivo SDZ ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport:Section(1):SetFilter(cFiltro, cIndexKey)
#ENDIF	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona a ordem escolhida ao titulo do relatorio          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:SetTitle(oReport:Title() + Space(05))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:SetMeter((cAlias1)->(LastRec()))
DbSelectArea(cAlias1)

While !oReport:Cancel() .AND. !(cAlias1)->(Eof())		
	If nLin > 0
		oReport:Section(1):SetPageBreak(.T.)
	EndIf	
	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Imprime a secao 1 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lTop
	    SB1->(DbSetOrder(1))
	    If SB1->(dbSeek(xFilial("SB1")+(cAlias1)->DZ_PRODUTO))
	    	lImpSDZ := .T.
	    	If !Empty(MV_PAR02) .And. !AllTrim(SB1->B1_COD)$(MV_PAR02) 
		    	lImpSDZ := .F.
		    EndIf
		    If lImpSDZ .And. !Empty(MV_PAR03) .And. !Alltrim(SB1->B1_TIPO)$(MV_PAR03)
		    	lImpSDZ := .F.
		    EndIf
			If lImpSDZ .And. !Empty(MV_PAR04) .And. !Alltrim(SB1->B1_GRUPO)$(MV_PAR04)
				lImpSDZ := .F.
			EndIf
			If lImpSDZ
	    		oSection1:Init()
				oSection1:PrintLine()
				nLin := oReport:Row()
	    	EndIf
	    EndIf
	Else
		oSection1:Init()                                                                            
		oSection1:PrintLine()
		nLin := oReport:Row()
	EndIf

	dbSelectArea(cAlias1)
	dbSkip()
End 
oSection1:Finish()

Return