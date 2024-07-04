#INCLUDE "PROTHEUS.CH"     
#INCLUDE "TMKA510H.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณHelpDeskHist          บAutorณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Interface de usuario para exibir o historico de chamados help desk.บฑฑ 
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class HelpDeskHist From HelpDeskFindCalls 
Data tipHistory

Method New() Constructor 
Method Find(oRelBrowse, aFields) 
EndClass 
             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew          บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class HelpDeskHist 
Self:lFinding 	:= .F.
Self:lStop		:= .F.   
Self:cSelCall	:= ""
Self:isHistory 	:= .T.
Self:tipHistory := 1
Self:cStr1 		:= STR0001 // "Hist๓rico de atendimento"
Self:cStr2 		:= ""
Self:cStr3 		:= STR0002 // "Nใo foi selecionado um chamado para ser iniciado o atendimento."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPergunte - TMK510HI                                                           ณ
//ณMV_PAR01 - De                                                        		 ณ
//ณMV_PAR02 - Ate                                                                ณ
//ณMV_PAR03 - Do Chamado                                                         ณ
//ณMV_PAR04 - Ate o chamado                                                      ณ
//ณMV_PAR05 - Status do chamado                                                  ณ
//ณMV_PAR06 - Do Cliente                                                         ณ
//ณMV_PAR07 - Da Loja                                                            ณ	
//ณMV_PAR08 - Ate o Cliente                                                      ณ
//ณMV_PAR09 - Ate a Loja                                                         ณ	
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
Self:cPergunte	:= "TMK510HI" 

Return Self  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFind         บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza procura por chamados que atendam ao criterio de     บฑฑ
ฑฑบ          ณbusca.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Find(oRelBrowse, aFields) Class HelpDeskHist 
Local cQuery := ""  
Local aArea := GetArea()
Local cWhere		:= ""
Local cCodContact	:= ""						//Codigo do contato
Local cEntityName	:= ""  						//Nome da Entidade 
										
Default aFields := {}

Self:cKeyWords := AllTrim(Self:cKeyWords)

If Self:tipHistory == 1
	cCodContact	:= M->ADE_CODCON											
	cEntityName	:= M->ADE_ENTIDA	
EndIf

If Empty(cCodContact) .AND. Self:tipHistory == 1
	MsgAlert(STR0003,STR0004) //"Por favor, selecione um contato"###"Atencao"
	Return(.F.)
Else

	Self:lFinding 	:= .T.
	DbSelectArea("ADE")
	DbSetOrder(1)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunte - TMK510H                                                            ณ
	//ณMV_PAR01 - De                                                        		 ณ
	//ณMV_PAR02 - Ate                                                                ณ
	//ณMV_PAR03 - Do Chamado                                                         ณ
	//ณMV_PAR04 - Ate o chamado                                                      ณ
	//ณMV_PAR05 - Status do chamado                                                  ณ
	//ณMV_PAR06 - Exibir hist๓rico de ?                                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunte - TMK510HI                                                           ณ
	//ณMV_PAR01 - De                                                        		 ณ
	//ณMV_PAR02 - Ate                                                                ณ
	//ณMV_PAR03 - Do Chamado                                                         ณ
	//ณMV_PAR04 - Ate o chamado                                                      ณ
	//ณMV_PAR05 - Status do chamado                                                  ณ
	//ณMV_PAR06 - Do Cliente                                                         ณ
	//ณMV_PAR07 - Da Loja                                                            ณ	
	//ณMV_PAR08 - Ate o Cliente                                                      ณ
	//ณMV_PAR09 - Ate a Loja                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		

	If ValType(MV_PAR05) == "N"
		MV_PAR05 := cValToChar(MV_PAR05)
	EndIf
	If ValType(MV_PAR06) == "N"
		MV_PAR06 := cValToChar(MV_PAR06)
	EndIf
	
	#IFDEF TOP		
		cQuery := "	SELECT "		
		cQuery += "	ADE.ADE_FILIAL,	ADE.ADE_CODSB1,	ADE.ADE_ENTIDA,		ADE.ADE_CHAVE, "
		cQuery += "	ADE.ADE_CODIGO,	ADE.ADE_DATA,	ADE.ADE_SEVCOD,		ADE.ADE_CODINC, "
		cQuery += "	ADE.ADE_DATA,	ADE.ADE_STATUS,	ADE.ADE_DTEXPI,		ADE.ADE_OPERAD  "
		cQuery += "	FROM " + RetSQLName("ADE") + " ADE"
		
		If !Empty(Self:cKeyWords)
			cQuery += " INNER JOIN " + RetSQLName("SYP") + " SYP ON ADE.ADE_CODINC = SYP.YP_CHAVE AND SYP.D_E_L_E_T_ = ''"
		EndIf		
		
		cWhere += "	WHERE ADE.ADE_FILIAL = '" + xFilial("ADE") + "' AND" 

		cWhere += "	ADE.ADE_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' AND"		
		cWhere += " ADE.ADE_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND"				
		
		If Val(MV_PAR05) < 4                                              
			cWhere += " ADE.ADE_STATUS = '" + AllTrim(MV_PAR05) + "' AND"					
		EndIf
		
		If !Empty(Self:cProduto)
			cWhere += "	ADE.ADE_CODSB1 = '" + Self:cProduto + "' AND"
		EndIf

		If !Empty(Self:cGroup)
			cWhere += "	ADE.ADE_GRUPO = '" + Self:cGroup + "' AND"
		EndIf	

		If Self:tipHistory == 1
			If Val(MV_PAR06) == 1 //Contato
				cWhere += " ADE.ADE_CODCON = '" + M->ADE_CODCON + "' AND"
			ElseIf Val(MV_PAR06) == 2	//Entidade                       
				cWhere += " ADE.ADE_ENTIDA = '" + M->ADE_ENTIDA + "' AND"		
				cWhere += " ADE.ADE_CHAVE  = '" + M->ADE_CHAVE + "' AND"			
			EndIf   
		Else
			cWhere += " ADE.ADE_CHAVE  BETWEEN '" + MV_PAR06+MV_PAR07 + "' AND '" + MV_PAR08+MV_PAR09 + "' AND"			
			cWhere += " ADE.ADE_ENTIDA = 'SA1' AND"		
		EndIf
		
		If !Empty(Self:cKeyWords)
			cWhere += " SYP.YP_FILIAL = '"+xFilial("SYP")+"' AND (UPPER(SYP.YP_TEXTO) LIKE '%" + Upper(Self:cKeyWords) + "%' OR UPPER(ADE.ADE_PLVCHV) LIKE '%" + Upper(Self:cKeyWords) + "%') AND"
		EndIf
	
		cWhere += "	ADE.D_E_L_E_T_ = ' '"  
		cQuery += cWhere		
		cQuery += "	ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
	
		DbSelectArea("ADE")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ADE", .F., .T.)			
		
		TCSetField("ADE", "ADE_DTEXPI"	, "D")
		TCSetField("ADE", "ADE_DATA"	, "D")				
	#ELSE       
		DbSelectArea("ADE")
		DbSetOrder(3) //ADE_FILIAL+ ADE_GRUPO		
		DbSeek(xFilial("ADE")+Self:cPosto)	
		nTot := RecCount()
	#ENDIF
	                 
	IncProc(STR0005) // "Criando lista de chamados..."	        
	Self:FillData("ADE", @aFields, @oRelBrowse)
			                            	
	DbSelectArea("ADE")
	DbCloseArea()	
	
	Self:lFinding 	:= .F.
	Self:lStop		:= .F.                      
	
	RestArea(aArea)
EndIf
Return Nil          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMKA510H ณ Autor ณ IP - Vendas Clientes  ณ Data ณ 29/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Exibe a tela de historico do atendimento Help Desk         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MP10                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function TMKA510H(lViewOnly)
 
Local oObj := Nil
Local cPergunte := "TMK510H"  
Local cCodContact	:= M->ADE_CODCON											//Codigo do contato

SaveInter()
             
oObj := HelpDeskHist():New() 

Default lViewOnly := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPergunte - TMK510H                                                            ณ
//ณMV_PAR01 - De                                                        		 ณ
//ณMV_PAR02 - Ate                                                                ณ
//ณMV_PAR03 - Do Chamado                                                         ณ
//ณMV_PAR04 - Ate o chamado                                                      ณ
//ณMV_PAR05 - Status do chamado                                                  ณ
//ณMV_PAR06 - Exibir hist๓rico de ?                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
oObj:cPergunte := cPergunte

If Empty(cCodContact)
	MsgAlert(STR0006,STR0004) //"Por favor, selecione um contato"###"Atencao"
	Return(.F.)
Else
	oObj:lViewOnly := lViewOnly
	If oObj:showDialog()
		aAdd(ParamIXB[1], "ADE")
		aAdd(ParamIXB[1], 1)		
		aAdd(ParamIXB[1], xFilial("ADE")+oObj:cSelCall)	
	EndIf
EndIf

RestInter()

Return .F.   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMKA510HIณ Autor ณ IP - Vendas Clientes  ณ Data ณ 29/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Exibe a tela de historico do atendimento Help Desk         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MP10                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function TMKA510HI(lViewOnly)
 
Local oObj := Nil

SaveInter()

oObj := HelpDeskHist():New()
                      
If Type("aCols")=="U"
	Private aCols := {}
EndIf

If Type("aHeader")=="U"
	Private aHeader := {}
EndIf

Default lViewOnly := .T.

oObj:lViewOnly := lViewOnly 
oObj:tipHistory	:= 2
oObj:showDialog()
                
RestInter()

Return .F.  