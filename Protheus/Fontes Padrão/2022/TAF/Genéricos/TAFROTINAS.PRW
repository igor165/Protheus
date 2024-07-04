#INCLUDE "PROTHEUS.CH"

Static __lLaySimp	:= Nil
Static cTabsEsocial := ""

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFRotinas 
Rotina contendo array com as definições de estruturas do TAF.

@Param		cScan	->	Resultado do array de rotinas TAF a ser buscado
			nScan	->	Posição do array de rotinas TAF a ser buscado
			lAll	->	Indica que deve ser retornado todo o array
			nOwner	->	Grupo de array ao qual será buscado a informação
							0-Todos
			 				1-Fiscal 
			 				2-eSocial
			 				3-ECF
			 				4-Autocontidas
							5-Eventos Reinf
							6-Genéricos
			lLayAtivo -> Parâmetro para verificar se quer retornar somente os eventos ativos na versão layout corrente do E-Social

@Author	Felipe C. Seolin
@Since		16/04/2015

@Obs		16/06/2015 - Evandro do Santos - Realizado alteração da rotina  
			dividindo o array aRotinas em 4 arrays, possibilitando a busca
			de acordo com o escopo ( Fiscal/eSocial/ECF/Autocontidas )
			utilizando o parâmetro nOwner

@Obs		01/03/2021 - Renan Gomes - Antes de utilizar a função TAFROTINAS, 
			garantir que ela está sendo chamada em uma ambiente preparado e com acesso 
			ao dicionário 

@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFRotinas( cScan, nScan, lAll, nOwner, lLayAtivo, lMenuDef )

	Local nPos        := 0
	Local nTamRot     := 0
	Local nTamFis     := 0
	Local nTamEcf     := 0
	Local nTameSc     := 0
	Local nTamGen     := 0
	Local nTamReinf   := 0
	Local nTamAut     := 0
	Local n           := 0
	Local aRotinas    := {}
	Local aTafReinf   := {}
	Local aTafFis     := {}
	Local aTafEcf     := {}
	Local aTafeSc     := {}
	Local aTafGen     := {}
	Local aAutoCon    := {}
	Local aRet        := {}
	Local aAuxEvt     := {}
	Local lReinf20    := .F.
	Local lVerDic	  := .F.
	Local lReinf15    := .F.

	Default cScan     := ""
	Default nScan     := 0
	Default lAll      := .T.
	Default nOwner    := 0
	Default lLayAtivo := .F.
	Default lMenuDef  := .F.

	cScan 		:= AllTrim(cScan) 
	lReinf15    := alltrim(StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')) >= '10500'
	lReinf20    := alltrim(StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')) >= '20000'

	//Tratamento para verificar se a chamada esta sendo realizada pelo menuDef de algum MVC.
	if !lMenuDef
		lVerDic	:= TAFAlsInDic("V5C") .And. TAFAlsInDic("V4Q") .And. TAFAlsInDic("V4N") .And. TAFAlsInDic("V30") .And. TAFAlsInDic("V3W").And. TAFAlsInDic("V3U") .And. TAFAlsInDic("V3X")  .And. TAFAlsInDic("V4F") .And. TAFAlsInDic("V3Z") .And. TAFAlsInDic("V4K") .And. TAFAlsInDic("V4A") .And. TAFAlsInDic("V4B")
	EndIf
	

	/*
	+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| aRotinas[x][01] - Nome da Rotina																																	|
	| aRotinas[x][02] - Função de Validação																											                    |
	| aRotinas[x][03] - Nome da Tabela																																	|
	| aRotinas[x][04] - Layout Totvs																																	|
	| aRotinas[x][05] - Owner da Tabela																																    |
	| aRotinas[x][06] - Campo de período																																|
	| aRotinas[x][07] - Função de integração																															|
	| aRotinas[x][08] - Função de geração XML																															|
	| aRotinas[x][09] - Tag do Evento eSocial																															|
	| aRotinas[x][10] - Índice chave da aplicação (Filial + Código + Ativo)																								|
	| aRotinas[x][11] - Id do Trabalhador (e-Social)																													|
	| aRotinas[x][12] - Tipo do Evento (C-Carga Inicial,M-Mensal,E-Eventual,T-Totalizador)																				|
	| aRotinas[x][13] - Índice chave do protocolo(recibo) (Filial + PROTUL + ATIVO)																						|
	| aRotinas[x][14] - Campo de descrição do evento no monitor do e-Social. Deve ser um campo que identifique o registro ex: Nome do trabalhador, Desc. Rubrica etc..  |
	| aRotinas[x][15] - Eventos Periodicos/Não Periodicos que não tem relação com o trabalhador. Marcar com S.                                                          |
	| aRotinas[x][16] - Função de Apuração do evento.																												    |	
	| aROtinas[x][17] - Evento com LGPD? 			                                                                                                                    |
	| aROtinas[x][18] - 												                                                                                                |
	| aROtinas[x][19] - Evento ativo com a versão corrente do E-Social?
	| aROtinas[x][20] - Nome da rotina pai que está sendo utilizada pelo eSocial do futuro                                                                                                  |
	+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	*/

	aTafFis := {	{ "TAFA050", ""					, "C1E", "T001"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .T. },;
								{ "TAFA051", "TAF051Vld", "C1G", "T001AB", "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA026", "TAF026Vld", "C0Q", "T001AC", "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA031", "TAF031Vld", "C0W", "T001AD", "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA027", "TAF027Vld", "C0R", "T001AE", "1", "C0R_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA109", "TAF109Vld", "C6Y", "T001AG", "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA187", "TAF187Vld", "C6D", "T001AJ", "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA079", "TAF079Vld", "C3Q", "T001AK", "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA180", "TAF180Vld", "C3R", "T001AL", "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA052", "TAF052Vld", "C2J", "T002"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },; //Também faz parte do escopo 3, mas por questão de índice do ID, deve ficar como escopo 1
								{ "TAFA053", "TAF053Vld", "C1H", "T003"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA055", "TAF055Vld", "C1J", "T005"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA056", "TAF056Vld", "C1K", "T006"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA057", "TAF057Vld", "C1L", "T007"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA058", "TAF058Vld", "C2L", "T008"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA059", "TAF059Vld", "C1N", "T009"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA060", "TAF060Vld", "C1O", "T010"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },; //Também faz parte do escopo 3, mas por questão de índice do ID, deve ficar como escopo 1
								{ "TAFA061", "TAF061Vld", "C1P", "T011"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA029", "TAF029Vld", "C0T", "T012"  , "1", ""  		, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA062", "TAF062Vld", "C20", "T013"  , "1", "C20_DTES"  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA063", "TAF063Vld", "C2S", "T020"  , "1", "C2S_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA188", "TAF188Vld", "C3J", "T021"  , "1", "C3J_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA064", "TAF064Vld", "C2N", "T022"  , "1", "C2N_DTINI"	, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA065", "TAF065Vld", "C49", "T023"  , "1", "C49_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA066", "TAF066Vld", "C46", "T024"  , "1", "C46_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA067", "TAF067Vld", "C3B", "T030"  , "1", "C3B_DTOPER", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA068", "TAF068Vld", "C4I", "T031"  , "1", "C4I_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA069", "TAF069Vld", "C4L", "T032"  , "1", "C4L_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA070", "TAF070Vld", "C40", "T033"  , "1", "C40_DTO"   , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA071", "TAF071Vld", "C5I", "T034"  , "1", "C5I_DTRETE", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA072", "TAF072Vld", "C4Q", "T035"  , "1", "C4Q_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA073", "TAF073Vld", "C4B", "T036"  , "1", "C4B_DTEVEN", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA074", "TAF074Vld", "C6M", "T037"  , "1", "C6M_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA075", "TAF075Vld", "C4R", "T050"  , "1", "C4R_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA076", "TAF076Vld", "C4E", "T060"  , "1", "C4E_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA077", "TAF077Vld", "C5E", "T061"  , "1", "C5E_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA078", "TAF078Vld", "C58", "T062"  , "1", "C58_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA081", "TAF081Vld", "C5F", "T065"  , "1", "C5F_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA082", "TAF082Vld", "C4F", "T066"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA083", "TAF083Vld", "C50", "T067"  , "1", "C50_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA084", "TAF084Vld", "C5J", "T068"  , "1", "C5J_PERMOV", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA085", "TAF085Vld", "C4N", "T069"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA086", "TAF086Vld", "C55", "T070"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA087", "TAF087Vld", "C5Z", "T071"  , "1", "C5Z_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA088", "TAF088Vld", "C4X", "T072"  , "1", "C4X_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA090", ""         , "C6A", ""      , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },; 
								{ "TAFA091", "TAF091Vld", "C53", "T075"  , "1", "C53_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA092", "TAF092Vld", "C5H", "T076"  , "1", "C5H_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA093", "TAF093Vld", "C6F", "T078"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA094", "TAF094Vld", "C5A", "T079"  , "1", "C5A_DTINV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA095", "TAF095Vld", "C5Q", "T080"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA096", "TAF096Vld", "C6N", "T081"  , "1", "C6N_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA097", "TAF097Vld", "C5M", "T082"  , "1", "C5M_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA098", "TAF098Vld", "C81", "T083"  , "1", "C81_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA307", "TAF307Vld", "CA2", "T086"  , "1", "CA2_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA200", "TAF200Vld", "C7H", "T900"  , "1", "C7H_DTMOVI", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA201", "TAF201Vld", "C7I", "T901"  , "1", "C7I_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA202", "TAF202Vld", "C7M", "T902"  , "1", "C7M_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA203", "TAF203Vld", "C7P", "T903"  , "1", "C7P_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA204", "TAF204Vld", "C7U", "T904"  , "1", "C7U_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA205", "TAF205Vld", "C7Z", "T905"  , "1", "C7Z_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA206", "TAF206Vld", "C71", "T906"  , "1", "C71_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA207", "TAF207Vld", "C73", "T907"  , "1", "C73_DTMOV" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA208", "TAF208Vld", "C77", "T908"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA397", "TAF397Vld", "T18", "T045"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA399", "TAF399Vld", "T32", "T150"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA398", "TAF398Vld", "T30", "T151"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA400", "TAF400Vld", "T39", "T152"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA450", "TAF450Vld", "CWY", "T052"  , "1", "CWY_MESREF", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA472", "TAF472Vld", "T6L", "T133"  , "1", "T6L_DTLANC", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA446", "TAF446Vld", "LEF", "T051"  , "1", "LEF_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA456", "TAF456Vld", "T56", "T131"  , "1", "" 			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA452", "TAF452Vld", "LEZ", "T046"  , "1", "LEZ_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA320", ""         , "CEL", ""      , "2", ""			, "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA448", "TAF448Vld", "LEM", "T154"	 , "1", "LEM_DTEMIS", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA298", ""			, "T9F", "T156"	 , "1", "T9F_DTAPUR", "", "", "", , "", "", , "", "", "", .F. }} 
					
	aTafeSc := {{ "TAFA050", "", "C1E", "S-1000", "2", "C1E_DTINI" , "TAF050Grv", "TAF050Xml", "evtInfoEmpregador"	, 9						, ""			, "C",  , "C1E_FILTAF"	, "" , "", 	  , .T., .T., "TAFA050" },; //S-1000
				{ "TAFA253", "", "C92", "S-1005", "2", "C92_DTINI" , "TAF253Grv", "TAF253Xml", "evtTabEstab"		, 7						, ""			, "C",  , "C92_NRINSC"	, "" ,	 , .T.,	   , .T., "TAFA253" },; //S-1005
				{ "TAFA232", "", "C8R", "S-1010", "2", "C8R_DTINI" , "TAF232Grv", "TAF232Xml", "evtTabRubrica"		, 9						, ""			, "C",  , "C8R_DESRUB"	, "" , 	 , .F.,	   , .T., "TAFA232" },; //S-1010
				{ "TAFA246", "", "C99", "S-1020", "2", "C99_DTINI" , "TAF246Grv", "TAF246Xml", "evtTabLotacao"		, 6						, ""			, "C",  , "C99_DESCRI"	, "" , 	 , .T.,	   , .T., "TAFA246" },; //S-1020
				{ "TAFA235", "", "C8V", "S-1030", "2", "C8V_DTINI" , "TAF235Grv", "TAF235Xml", "evtTabCargo"		, 6						, ""			, "C",  , "C8V_DESCRI"	, "" , 	 , .F.,	   , .F., "TAFA235" },; //S-1030
				{ "TAFA467", "", "T5K", "S-1035", "2", "T5K_DTINI" , "TAF467Grv", "TAF467Xml", "evtTabCarreira"		, 6						, ""			, "C",  , "T5K_DESCRI"	, "" , 	 , .F.,	   , .F., "TAFA467" },; //S-1035
				{ "TAFA236", "", "C8X", "S-1040", "2", "C8X_DTINI" , "TAF236Grv", "TAF236Xml", "evtTabFuncao"		, 5						, ""			, "C",  , "C8X_DESCRI"	, "" , 	 , .F.,	   , .F., "TAFA236" },; //S-1040
				{ "TAFA238", "", "C90", "S-1050", "2", "C90_DTINI" , "TAF238Grv", "TAF238Xml", "evtTabHorTur"		, 5						, ""			, "C",  , "C90_DESCRI"	, "" , 	 , .F.,	   , .F., "TAFA238" },; //S-1050
				{ "TAFA389", "", "T04", "S-1060", "2", "T04_DTINI" , "TAF389Grv", "TAF389Xml", "evtTabAmbiente"		, 5						, ""			, "C",  , ""		  	, "" , 	 , .T.,	   , .F., "TAFA389" },; //S-1060
				{ "TAFA051", "", "C1G", "S-1070", "2", "C1G_DTINI" , "TAF051Grv", "TAF051Xml", "evtTabProcesso"		, 10					, ""			, "C",  , "C1G_NUMPRO"	, "" , 	 , .F.,	   , .T., "TAFA051" },; //S-1070
				{ "TAFA248", "", "C8W", "S-1080", "2", "C8W_DTINI" , "TAF248Grv", "TAF248Xml", "evtTabOperPort"		, 5						, ""			, "C",  , "C8W_CNPJOP"	, "" , 	 , .F.,	   , .F., "TAFA248" },; //S-1080
				{ "TAFA250", "", "C91", "S-1200", "2", "C91_PERAPU", "TAF250Grv", "TAF250Xml", "evtRemun"			, fRetIndx10("TAFA250")	, "C91_TRABAL"	, "M", 5, "C91_TRABAL"	, "" , 	 , .T.,	   , .T., "TAFA250" },; //S-1200
				{ "TAFA413", "", "C91", "S-1202", "2", "C91_PERAPU", "TAF413Grv", "TAF413Xml", "evtRmnRPPS"			, 2 					, "C91_TRABAL"	, "M", 5, "C91_TRABAL"	, "" , 	 , .T.,	   , .T., "TAFA413" },; //S-1202
				{ "TAFA470", "", "T62", "S-1207", "2", "T62_PERAPU", "TAF470Grv", "TAF470Xml", "evtBenPrRP"			, 2 					, "T62_CPF" 	, "M", 4, "T62_CPF"	  	, "S",	 , .T.,	   , .T., "TAFA470" },; //S-1207
				{ "TAFA407", "", "T3P", "S-1210", "2", "T3P_PERAPU", "TAF407Grv", "TAF407Xml", "evtPgtos"			, fRetIndx10("TAFA407")	, "T3P_BENEFI"	, "M", 3, "T3P_BENEFI"	, "" , 	 , .T.,	   , .T., "TAFA407" },; //S-1210
				{ "TAFA272", "", "CMR", "S-1250", "2", "CMR_PERAPU", "TAF272Grv", "TAF272Xml", "evtAqProd"			, 3						, ""			, "M", 4, ""		  	, "S",	 , .T.,	   , .F., "TAFA272" },;	//S-1250
				{ "TAFA414", "", "T1M", "S-1260", "2", "T1M_PERAPU", "TAF414Grv", "TAF414Xml", "evtComProd"			, 2						, ""		 	, "M", 3, "T1M_NRINSC"	, "S",	 , .T.,	   , .T., "TAFA414" },; //S-1260
				{ "TAFA408", "", "T2A", "S-1270", "2", "T2A_PERAPU", "TAF408Grv", "TAF408Xml", "evtContratAvNP"		, 2						, ""			, "M", 3, "T2A_EVENTO"	, "S",	 , .T.,	   , .T., "TAFA408" },;	//S-1270
				{ "TAFA410", "", "T3V", "S-1280", "2", "T3V_PERAPU", "TAF410Grv", "TAF410Xml", "evtInfoComplPer"	, 3						, ""			, "M", 2, "T3V_PRCONT"	, "S",	 , .F.,	   , .T., "TAFA410" },; //S-1280
				{ "TAFA477", "", "T72", "S-1295", "2", "T72_PERAPU", "TAF477Grv", "TAF477Xml", "evtTotConting"		, 2						, ""	 		, "M", 3, "T72_NOME"	, "S",	 , .T.,	   , .F., "TAFA477" },; //S-1295
				{ "TAFA416", "", "T1S", "S-1298", "2", "T1S_PERAPU", "TAF416Grv", "TAF416Xml", "evtReabreEvPer"		, 2						, ""			, "M", 3, "T1S_PROTUL"	, "S",	 , .F.,	   , .T., "TAFA416" },; //S-1298
				{ "TAFA303", "", "CUO", "S-1299", "2", "CUO_PERAPU", "TAF303Grv", "TAF303Xml", "evtFechaEvPer"		, fRetIndx10("TAFA303")	, ""			, "M",  , "CUO_REMUN"	, "S",	 , .T.,	   , .T., "TAFA303" },; //S-1299
				{ "TAFA412", "", "T3Z", "S-1300", "2", "T3Z_PERAPU", "TAF412Grv", "TAF412Xml", "evtContrSindPatr"	, 4						, ""		 	, "M", 3, ""		  	, "S",	 , .F.,	   , .F., "TAFA412" },; //S-1300
				{ "TAFA403", "", "T3A", "S-2190", "2", "T3A_DTADMI", "TAF403Grv", "TAF403Xml", "evtAdmPrelim"		, fRetIndx10("TAFA403")	, ""			, "E", 4, "T3A_CPF"   	, "S",	 , .T.,	   , .T., "TAFA403" },; //S-2190
				{ "TAFA278", "", "C9V", "S-2200", "2", ""          , "TAF278Grv", "TAF278Xml", "evtAdmissao"		, 10					, "C9V_ID"		, "E", 8, "C9V_NOME"  	, "" ,	 , .T.,	   , .T., "TAFA421" },; //S-2200
				{ "TAFA275", "", "T1U", "S-2205", "2", "T1U_DTALT" , "TAF275Grv", "TAF275Xml", "evtAltCadastral"	, 4						, "T1U_ID"		, "E", 5, "T1U_NOME"  	, "" ,	 , .F.,	   , .T., "TAFA421" },; //S-2205
				{ "TAFA276", "", "T1V", "S-2206", "2", "T1V_DTALT" , "TAF276Grv", "TAF276Xml", "evtAltContratual"	, 3						, "T1V_ID"		, "E", 5, "T1V_NOME"  	, "" ,	 , .F.,	   , .T., "TAFA421" },; //S-2206
				{ "TAFA257", "", "CM0", "S-2210", "2", "CM0_DTACID", "TAF257Grv", "TAF257Xml", "evtCAT"				, 4 					, "CM0_TRABAL"	, "E", 6, ""		  	, "" ,	 , .T.,	   , .T., "TAFA257" },; //S-2210
				{ "TAFA258", "", "C8B", "S-2220", "2", "C8B_DTASO" , "TAF258Grv", "TAF258Xml", "evtMonit"			, 2 					, "C8B_FUNC"	, "E", 4, ""		  	, "" ,	 , .T.,	   , .T., "TAFA258" },; //S-2220
				{ "TAFA528", "", "V3B", "S-2221", "2", "V3B_DTEXAM", "TAF528Grv", "TAF528Xml", "evtToxic"			, 5 					, "V3B_FUNC"	, "E", 4, "V3C_FUNC"	, "" ,	 , .T.,	   , .F., "TAFA528" },; //S-2221
				{ "TAFA261", "", "CM6", "S-2230", "2", "" 		   , "TAF261Grv", "TAF261Xml", "evtAfastTemp"		, 10					, "CM6_FUNC"	, "E", 4, "CM6_FUNC"  	, "" ,	 , .T.,	   , .T., "TAFA261" },; //S-2230
				{ "TAFA587", "", "V72", "S-2231", "2", "" 		   , "TAF587Grv", "TAF587Xml", "evtCessao"			, 2 					, "V72_FUNC"	, "E", 3, "V72_FUNC"  	, "" ,	 , .T.,	   , .T., "TAFA587" },; //S-2231
				{ "TAFA264", "", "CM9", "S-2240", "2", "CM9_DTINI" , "TAF264Grv", "TAF264Xml", "evtExpRisco"		, 3						, "CM9_FUNC"	, "E", 4, ""		  	, "" ,	 , .T.,	   , .T., "TAFA264" },; //S-2240
				{ "TAFA404", "", "T3B", "S-2241", "2", "T3B_DTINI" , "TAF404Grv", "TAF404Xml", "evtInsApo"			, 2						, "T3B_IDTRAB"	, "E", 4, "T3B_IDTRAB"	, "" ,	 , .T.,	   , .T., "TAFA404" },; //S-2241
				{ "TAFA529", "", "V3C", "S-2245", "2", "V3C_DTTCAP", "TAF529Grv", "TAF529Xml", "evtTreiCap"			, 2						, "V3C_FUNC"	, "E", 4, "V3C_FUNC"	, "" ,	 , .T.,	   , .F., "TAFA529" },; //S-2245
				{ "TAFA263", "", "CM8", "S-2250", "2", "CM8_DTAVIS", "TAF263Grv", "TAF263Xml", "evtAvPrevio"		, 3						, "CM8_TRABAL"	, "E", 5, "CM8_TRABAL"	, "" ,	 , .T.,	   , .F., "TAFA263" },; //S-2250
				{ "TAFA267", "", "CMF", "S-2298", "2", "CMF_DTEFEI", "TAF267Grv", "TAF267Xml", "evtReintegr"		, 5 					, "CMF_FUNC"	, "E", 4, ""		  	, "" ,	 , .T.,	   , .T., "TAFA267" },; //S-2298
				{ "TAFA266", "", "CMD", "S-2299", "2", "CMD_DTDESL", "TAF266Grv", "TAF266Xml", "evtDeslig"			, 5						, "CMD_FUNC"	, "E", 4, ""		  	, "" ,	 , .T.,	   , .T., "TAFA266" },; //S-2299
				{ "TAFA279", "", "C9V", "S-2300", "2", "C9V_DTINIV", "TAF279Grv", "TAF279Xml", "evtTSVInicio"		, fRetIndx10("TAFA279")	, "C9V_ID"	 	, "E", 8, "C9V_NOME"  	, "" ,	 , .F.,	   , .T., "TAFA421" },; //S-2300
				{ "TAFA277", "", "T0F", "S-2306", "2", "T0F_DTALT" , "TAF277Grv", "TAF277Xml", "evtTSVAltContr"		, fRetIndx10("TAFA277")	, "T0F_ID"		, "E", 5, "T0F_NOME"  	, "" ,	 , .F.,	   , .T., "TAFA421" },; //S-2306
				{ "TAFA280", "", "T92", "S-2399", "2", "T92_DTERAV", "TAF280Grv", "TAF280Xml", "evtTSVTermino"		, 3 					, "T92_TRABAL"	, "E", 6, "T92_TRABAL"  , "" ,	 , .T.,	   , .T., "TAFA280" },; //S-2399
				{ "TAFA589", "", "V73", "S-2400", "2", "V73_DTINIC", "TAF589Grv", "TAF589Xml", "evtCdBenefIn"		, 3						, "V73_CPFBEN"	, "E", 2, "V73_NOMEB"	, "S",	 , .T.,	   , .T., "TAFA588" },; //S-2400
				{ "TAFA590", "", "V73", "S-2405", "2", "V73_DTALTE", "TAF590Grv", "TAF590Xml", "evtCdBenefAlt"		, 3						, "V73_CPFBEN"	, "E", 2, "V73_NOMEB"	, "S",	 , .T.,	   , .T., "TAFA598" },; //S-2405
				{ "TAFA592", "", "V75", "S-2410", "2", "V75_DTINBE", "TAF592Grv", "TAF592Xml", "evtCdBenIn"			, 5						, "V75_CPFBEN"	, "E", 4, "V75_CPFBEN"  , "" ,	 , .T.,	   , .T., "TAFA591" },; //S-2410
				{ "TAFA593", "", "V76", "S-2416", "2", "V76_DALTBE", "TAF593Grv", "TAF593Xml", "evtCdBenAlt"		, 3						, "V76_CPFBEN"	, "E", 4, "V76_CPFBEN"  , "" ,	 , .T.,	   , .T., "TAFA591" },; //S-2416
				{ "TAFA594", "", "V77", "S-2418", "2", "V77_DTREAT", "TAF594Grv", "TAF594Xml", "evtCdBenAlt"		, 3						, "V77_CPFBEN"	, "E", 4, "V77_CPFBEN"  , "" ,	 , .T.,	   , .T., "TAFA591" },; //S-2418
				{ "TAFA595", "", "V78", "S-2420", "2", "V78_DTTERM", "TAF595Grv", "TAF595Xml", "evtCdBenTerm"		, 3						, "V78_CPFBEN"	, "E", 4, "V78_CPFBEN"  , "" ,	 , .T.,	   , .T., "TAFA591" },; //S-2420
				{ "TAFA269", "", "CMJ", "S-3000", "2", "CMJ_PERAPU", "TAF269Grv", "TAF269Xml", "evtExclusao"		, 2 					, "CMJ_TRABAL"	, "E",  , "CMJ_TPEVEN"	, "S",	 , .T.,	   , .T., "TAFA269" },; //S-3000
				{ "TAFA423", "", "T2M", "S-5001", "2", "T2M_PERAPU", "TAF423Grv", "TAF423Xml", "evtBasesTrab"		, 2						, ""			, "T", 3, ""		  	, "" ,	 , .T.,	   , .T., "TAFA423" },; //S-5001
				{ "TAFA422", "", "T2G", "S-5002", "2", "T2G_PERAPU", "TAF422Grv", "TAF422Xml", "evtIrrfBenef"		, fRetIndx10("TAFA422")	, ""			, "T", 2, ""		  	, "" ,	 , .T.,	   , .T., "TAFA422" },; //S-5002
				{ "TAFA520", "", "V2P", "S-5003", "2", "V2P_PERAPU", "TAF520Grv", "TAF520Xml", "evtBasesFGTS"		, fRetIndx10("TAFA520")	, ""			, "T",	, ""		  	, "" ,	 , .T.,	   , .T., "TAFA520" },; //S-5003
				{ "TAFA425", "", "T2V", "S-5011", "2", "T2V_PERAPU", "TAF425Grv", "TAF425Xml", "evtCS"				, 2						, ""			, "T", 3, ""		  	, "" ,	 , .T.,	   , .T., "TAFA425" },; //S-5011
				{ "TAFA426", "", "T0G", "S-5012", "2", "T0G_PERAPU", "TAF426Grv", "TAF426Xml", ""					, 2						, ""			, "T", 2, ""		  	, "" ,	 , .F.,	   , .F., "TAFA426" },; //S-5012
				{ "TAFA521", "", "V2Z", "S-5013", "2", "V2Z_PERAPU", "TAF521Grv", "TAF521Xml", "evtFGTS"			, 2						, ""			, "T",	, ""		  	, "" ,	 , .F.,	   , .T., "TAFA521" },; //S-5013
				{ "TAFA420", "", "C9V", ""      , "2", ""		   , ""			, ""		 , ""		          	, 10					, "C9V_ID" 		, "E", 8, ""		  	, "" ,	 , .F.,	   , .T., "TAFA420" },; //TAFA420
				{ "TAFA421", "", "C9V", ""      , "2", ""		   , ""			, ""		 , ""		         	, 10					, "C9V_ID"    	, "E", 8, ""		  	, "" ,	 , .T.,	   , .T., "TAFA421" },; //TAFA421
				{ "TAFA484", "", "T87", "S-2260", "2", "T87_DTINIP", "TAF484Grv", "TAF484Xml", "evtConvInterm"		, 2 					, "T87_TRABAL"	, "E", 3, ""			, "" ,	 , .T.,	   , .F., "TAFA484" },; //S-2260
				{ "TAFA473", "", "C9V", "TAUTO"	, "2", "" 		   , ""			, ""		 , ""					, 3						, "C9V_CPF"	 	, "E",  , "C9V_NOME"	, "S",	 , .F.,	   , .T., "TAFA473" },; //TAUTO //Cadastro do trabalhador autônomo, está como S-TAUTO por causa do campo C9V_NOMEVE
				{ "TAFA549", "", "C91", "TAUTO"	, "2", "" 		   , ""			, ""		 , ""					, 3						, ""	 		, "" ,	, ""			, "" ,	 , .T.,	   , .T., "TAFA549" },; //TAUTO
				{ "TAFA550", "", "T3P", "TAUTO"	, "2", "" 		   , ""			, ""		 , ""					, 3						, ""	 		, "" ,  , ""			, "" ,	 , .T.,	   , .T., "TAFA550" }}  //TAUTO
	
					//**Eventos Obsoletos
					//{ "TAFA259", "Taf259Vld", "CM4", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA274", "Taf274Vld", "CMX", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA298", "TAF298Vld", "CRS", ""      	, "2", ""  	  	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA252", "TAF252Vld", "C8Q", ""      	, "2", ""  	   	 	, ""			, ""			, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA239", "TAF239Vld", "CRR", ""      	, "2", ""  	  	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA292", "TAF292Vld", "CRV", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		 	,""},;
					//{ "TAFA262", ""         , "CM7", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA281", "TAF281Vld", "CRE", ""      	, "2", ""  	  	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA291", "TAF291Vld", "CRF", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA260", "TAF260Vld", "CM5", ""      	, "2", ""  	 	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA287", "TAF287Vld", "CRH", ""      	, "2", ""  	 	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA265", "Taf265Vld", "CMC", ""      	, "2", ""  	  	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA282", "TAF282Vld", "CRI", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA283", ""         , "CMW", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA263", "TAF263Vld", "CM8", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""	   	 	,""},;
					//{ "TAFA286", "TAF286Vld", "CRG", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,  	,""				 ,"" ,   ,""			,""},;
					//{ "TAFA285", "TAF285Vld", "CRW", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA271", "TAF271Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA288", "TAF288Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA289", "TAF289Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA290", "TAF290Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA290", "TAF290Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  	,""},;
					//{ "TAFA251", ""         , "C9A", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,""					 ,"" ,   ,""		  		,""},;
					//{ "TAFA249", "TAF249Vld", "C8Y", ""      	, "2", ""  	   	 	, ""		  	, ""		 	, ""						,	,""				 ,"" ,   ,""		  		,""},;				
					//{ "TAFA254", ""         , "C9F", ""      	, "2", "" 		   	 , ""		  	, ""		 	, ""						,	,""				 ,"" ,   ,""		  		,""},;
					//{ "TAFA288", "TAF288Vld", "CMN", ""      	, "2", ""  	   	 	, ""			, ""		 	, ""						,	,""				 ,"" ,   ,""		  		,""},;
					//{ "TAFA249", "TAF249Vld", "C8Y","" ,"2", "","","","",,"","",,"",""},;
					//{ "TAFA268", "Taf268Vld", "CRK", "","2", "","","","",,"","",,"",""},;
					//{ "TAFA294", ""     	  , "C9Z", "" "2", "","","","",,"","",,"",""},;

	aTafEcf := { 	{ "TAFA311", "TAF311Vld", "CAC", "T087", "3", "CAC_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA361", "TAF361Vld", "CAP", "T088", "3", "CAP_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA330", "TAF330Vld", "CFR", "T089", "3", "CFR_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA322", "TAF322Vld", "CEN", "T090", "3", "CEN_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA319", "TAF319Vld", "CEA", "T091", "3", "CEA_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA321", "TAF321Vld", "CEG", "T092", "3", "CEG_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA323", "TAF323Vld", "CEJ", "T093", "3", "CEJ_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA324", "TAF324Vld", "CEY", "T094", "3", "CEY_DTINI" , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA325", "TAF325Vld", "CFK", "T095", "3", "CFK_VIGINI", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA332", "TAF332Vld", "CFT", "T096", "3", "CFT_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA334", "TAF334Vld", "CAY", "T097", "3", "CAY_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA335", "TAF335Vld", "CFV", "T098", "3", "CFV_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA336", "TAF336Vld", "CFY", "T099", "3", "CFY_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA337", "TAF337Vld", "CG0", "T100", "3", "CG0_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA338", "TAF338Vld", "CG2", "T101", "3", "CG2_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA339", "TAF339Vld", "CG3", "T102", "3", "CG3_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA340", "TAF340Vld", "CG5", "T103", "3", "CG5_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA329", "TAF329Vld", "CFQ", "T104", "3", "CFQ_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA341", "TAF341Vld", "CGH", "T105", "3", "CGH_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA342", "TAF342Vld", "CGI", "T106", "3", "CGI_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA343", "TAF343Vld", "CGJ", "T107", "3", "CGJ_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA350", "TAF350Vld", "CEX", "T108", "3", "CEX_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA344", "TAF344Vld", "CGK", "T109", "3", "CGK_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA345", "TAF345Vld", "CGL", "T110", "3", "CGL_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA346", "TAF346Vld", "CGM", "T111", "3", "CGM_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA349", "TAF349Vld", "CEM", "T112", "3", "CEM_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA351", "TAF351Vld", "CGO", "T113", "3", "CGO_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA352", "TAF352Vld", "CGP", "T114", "3", "CGP_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA353", "TAF353Vld", "CGQ", "T115", "3", "CGQ_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA354", "TAF354Vld", "CGR", "T116", "3", "CGR_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA355", "TAF355Vld", "CGT", "T117", "3", "CGT_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA356", "TAF356Vld", "CGU", "T118", "3", "CGU_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA357", "TAF357Vld", "CGV", "T119", "3", "CGV_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA358", "TAF358Vld", "CGW", "T120", "3", "CGW_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA359", "TAF359Vld", "CGY", "T121", "3", "CGY_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA360", "TAF360Vld", "CGZ", "T122", "3", "CGZ_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA367", "TAF367Vld", "CH9", "T123", "3", "CH9_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA331", "TAF331Vld", "CFS", "T124", "3", "CFS_DTLCTO", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA371", "TAF371Vld", "CHC", "T125", "3", "" 		  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA373", "TAF373Vld", "CHF", "T126", "3", "CHF_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA372", "TAF372Vld", "CHD", "T127", "3", "CHD_PERINI", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA396", "TAF396Vld", "T27", "T128", "3", "T27_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA394", "TAF394Vld", "T29", "T129", "3", "T29_PERIOD", "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA429", "TAF429Vld", "T0M", "T130", "3", "T0M_DATA"  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA471", "TAF471Vld", "T67", "T132", "3", "" 		  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA505", "TAF505Vld", "V1Q", "T134", "3", "" 		  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA506", "TAF506Vld", "V1R", "T135", "3", "" 		  , "", "", "", , "", "", , "", "", "", .F. },;
								{ "TAFA507", "TAF507Vld", "V1S", "T136", "3", "V1S_DATA"  , "", "", "", , "", "", , "", "", "", .F. }}

	aAutoCon := { 	{ "TAFA001", Nil        , "C01", Nil     , "4" },;
									{ "TAFA002", Nil        , "C02", Nil     , "4" },;
									{ "TAFA003", Nil        , "C03", Nil     , "4" },;
									{ "TAFA004", Nil        , "C04", Nil     , "4" },;
									{ "TAFA005", Nil        , "C05", Nil     , "4" },;
									{ "TAFA006", Nil        , "C06", Nil     , "4" },;
									{ "TAFA007", Nil        , "C07", Nil     , "4" },;
									{ "TAFA008", Nil        , "C08", Nil     , "4" },;
									{ "TAFA009", Nil        , "C09", Nil     , "4" },;
									{ "TAFA010", Nil        , "C0A", Nil     , "4" },;
									{ "TAFA011", Nil        , "C0B", Nil     , "4" },;
									{ "TAFA012", Nil        , "C0G", Nil     , "4" },;
									{ "TAFA013", Nil        , "C13", Nil     , "4" },;
									{ "TAFA014", Nil        , "C14", Nil     , "4" },;
									{ "TAFA015", Nil        , "C15", Nil     , "4" },;
									{ "TAFA016", Nil        , "C16", Nil     , "4" },;
									{ "TAFA017", Nil        , "C17", Nil     , "4" },;
									{ "TAFA018", Nil        , "C0H", Nil     , "4" },;
									{ "TAFA019", Nil        , "C0J", Nil     , "4" },;
									{ "TAFA020", Nil        , "C1A", Nil     , "4" },;
									{ "TAFA021", Nil        , "C0L", Nil     , "4" },;
									{ "TAFA022", Nil        , "C0M", Nil     , "4" },;
									{ "TAFA023", Nil        , "C0N", Nil     , "4" },;
									{ "TAFA024", Nil        , "C0K", Nil     , "4" },;
									{ "TAFA028", Nil        , "C0S", Nil     , "4" },;
									{ "TAFA030", Nil        , "C0U", Nil     , "4" },;
									{ "TAFA032", Nil        , "C0X", Nil     , "4" },;
									{ "TAFA033", Nil        , "C0Z", Nil     , "4" },;
									{ "TAFA034", Nil        , "C0Y", Nil     , "4" },;
									{ "TAFA035", Nil        , "C11", Nil     , "4" },;
									{ "TAFA036", Nil        , "C10", Nil     , "4" },;
									{ "TAFA037", Nil        , "C1Q", Nil     , "4" },;
									{ "TAFA038", Nil        , "C1S", Nil     , "4" },;
									{ "TAFA039", Nil        , "C12", Nil     , "4" },;
									{ "TAFA040", Nil        , "C1R", Nil     , "4" },;
									{ "TAFA041", Nil        , "C1T", Nil     , "4" },;
									{ "TAFA042", Nil        , "C0V", Nil     , "4" },;
									{ "TAFA044", Nil        , "C18", Nil     , "4" },;
									{ "TAFA045", Nil        , "C19", Nil     , "4" },;
									{ "TAFA046", Nil        , "C1Y", Nil     , "4" },;
									{ "TAFA047", Nil        , "C1V", Nil     , "4" },;
									{ "TAFA048", Nil        , "C3P", Nil     , "4" },;
									{ "TAFA080", Nil        , "C3S", Nil     , "4" },;
									{ "TAFA150", Nil        , "C0C", Nil     , "4" },;
									{ "TAFA151", Nil        , "C0D", Nil     , "4" },;
									{ "TAFA152", Nil        , "C0E", Nil     , "4" },;
									{ "TAFA153", Nil        , "C0F", Nil     , "4" },;
									{ "TAFA154", Nil        , "C1B", Nil     , "4" },;
									{ "TAFA155", Nil        , "C1C", Nil     , "4" },;
									{ "TAFA156", Nil        , "C1D", Nil     , "4" },;
									{ "TAFA157", Nil        , "C0O", Nil     , "4" },;
									{ "TAFA158", Nil        , "C0I", Nil     , "4" },;
									{ "TAFA160", Nil        , "C1X", Nil     , "4" },;
									{ "TAFA161", Nil        , "C1W", Nil     , "4" },;
									{ "TAFA162", Nil        , "C2M", Nil     , "4" },;
									{ "TAFA163", Nil        , "C3Z", Nil     , "4" },;
									{ "TAFA164", Nil        , "C3V", Nil     , "4" },;
									{ "TAFA165", Nil        , "C3X", Nil     , "4" },;
									{ "TAFA166", Nil        , "C2Q", Nil     , "4" },;
									{ "TAFA167", Nil        , "C2R", Nil     , "4" },;
									{ "TAFA168", Nil        , "C3E", Nil     , "4" },;
									{ "TAFA169", Nil        , "C3D", Nil     , "4" },;
									{ "TAFA170", Nil        , "C41", Nil     , "4" },;
									{ "TAFA171", Nil        , "C42", Nil     , "4" },;
									{ "TAFA172", Nil        , "C4D", Nil     , "4" },;
									{ "TAFA176", Nil        , "C4K", Nil     , "4" },;
									{ "TAFA177", Nil        , "C4Z", Nil     , "4" },;
									{ "TAFA178", Nil        , "C52", Nil     , "4" },;
									{ "TAFA179", Nil        , "C5D", Nil     , "4" },;
									{ "TAFA181", Nil        , "C5P", Nil     , "4" },;
									{ "TAFA182", Nil        , "C5V", Nil     , "4" },;
									{ "TAFA183", Nil        , "C5X", Nil     , "4" },;
									{ "TAFA184", Nil        , "C3T", Nil     , "4" },;
									{ "TAFA185", Nil        , "C3U", Nil     , "4" },;
									{ "TAFA186", Nil        , "C6C", Nil     , "4" },;
									{ "TAFA189", Nil        , "C6R", Nil     , "4" },;
									{ "TAFA190", Nil        , "C6S", Nil     , "4" },;
									{ "TAFA191", Nil        , "C6T", Nil     , "4" },;
									{ "TAFA192", Nil        , "C6U", Nil     , "4" },;
									{ "TAFA211", Nil        , "C86", Nil     , "4" },;
									{ "TAFA212", Nil        , "C87", Nil     , "4" },;
									{ "TAFA213", Nil        , "C88", Nil     , "4" },;
									{ "TAFA214", Nil        , "C89", Nil     , "4" },;
									{ "TAFA215", Nil        , "C8A", Nil     , "4" },;
									{ "TAFA216", Nil        , "CMH", Nil     , "4" },;
									{ "TAFA217", Nil        , "C8C", Nil     , "4" },;
									{ "TAFA218", Nil        , "CMI", Nil     , "4" },;
									{ "TAFA219", Nil        , "C8D", Nil     , "4" },;
									{ "TAFA220", Nil        , "C8E", Nil     , "4" },;
									{ "TAFA221", Nil        , "C8F", Nil     , "4" },;
									{ "TAFA222", Nil        , "C8G", Nil     , "4" },;
									{ "TAFA223", Nil        , "C8H", Nil     , "4" },;
									{ "TAFA224", Nil        , "C8I", Nil     , "4" },;
									{ "TAFA225", Nil        , "C8J", Nil     , "4" },;
									{ "TAFA226", Nil        , "C8K", Nil     , "4" },;
									{ "TAFA227", Nil        , "C8L", Nil     , "4" },;
									{ "TAFA228", Nil        , "C8M", Nil     , "4" },;
									{ "TAFA229", Nil        , "C8N", Nil     , "4" },;
									{ "TAFA230", Nil        , "C8O", Nil     , "4" },;
									{ "TAFA231", Nil        , "C8P", Nil     , "4" },;
									{ "TAFA233", Nil        , "C8T", Nil     , "4" },;
									{ "TAFA234", Nil        , "C8U", Nil     , "4" },;
									{ "TAFA237", Nil        , "C8Z", Nil     , "4" },;
									{ "TAFA240", Nil        , "C94", Nil     , "4" },;
									{ "TAFA241", Nil        , "C95", Nil     , "4" },;
									{ "TAFA242", Nil        , "C96", Nil     , "4" },;
									{ "TAFA243", Nil        , "C97", Nil     , "4" },;
									{ "TAFA244", Nil        , "C98", Nil     , "4" },;
									{ "TAFA247", Nil        , "C8S", Nil     , "4" },;
									{ "TAFA270", Nil        , "CMM", Nil     , "4" },;
									{ "TAFA273", Nil        , "CML", Nil     , "4" },;
									{ "TAFA284", Nil        , "CMY", Nil     , "4" },;
									{ "TAFA293", Nil        , "CUA", Nil     , "4" },;
									{ "TAFA295", Nil        , "CUB", Nil     , "4" },;
									{ "TAFA296", Nil        , "CUC", Nil     , "4" },;
									{ "TAFA299", Nil        , "CUE", Nil     , "4" },;
									{ "TAFA300", Nil        , "CUF", Nil     , "4" },;
									{ "TAFA301", Nil        , "CUM", Nil     , "4" },;
									{ "TAFA302", Nil        , "CUN", Nil     , "4" },;
									{ "TAFA304", Nil        , "CUQ", Nil     , "4" },;
									{ "TAFA305", Nil        , "CUR", Nil     , "4" },;
									{ "TAFA306", Nil        , "CUV", Nil     , "4" },;
									{ "TAFA308", Nil        , "CA0", Nil     , "4" },;
									{ "TAFA309", Nil        , "CUY", Nil     , "4" },;
									{ "TAFA310", Nil        , "CUZ", Nil     , "4" },;
									{ "TAFA312", Nil        , "CAH", Nil     , "4" },;
									{ "TAFA313", Nil        , "CAJ", Nil     , "4" },;
									{ "TAFA314", Nil        , "CAK", Nil     , "4" },;
									{ "TAFA315", Nil        , "CAL", Nil     , "4" },;
									{ "TAFA316", Nil        , "CH0", Nil     , "4" },;
									{ "TAFA317", Nil        , "CW4", Nil     , "4" },;
									{ "TAFA318", Nil        , "CAX", Nil     , "4" },;
									{ "TAFA327", Nil        , "CFL", Nil     , "4" },;
									{ "TAFA328", Nil        , "CFM", Nil     , "4" },;
									{ "TAFA333", Nil        , "CFU", Nil     , "4" },;
									{ "TAFA347", Nil        , "CGN", Nil     , "4" },;
									{ "TAFA363", Nil        , "CW9", Nil     , "4" },;
									{ "TAFA364", Nil        , "CH6", Nil     , "4" },;
									{ "TAFA366", Nil        , "CH8", Nil     , "4" },;
									{ "TAFA368", Nil        , "CHA", Nil     , "4" },;
									{ "TAFA374", Nil        , "CHI", Nil     , "4" },;
									{ "TAFA375", Nil        , "CHJ", Nil     , "4" },;
									{ "TAFA376", Nil        , "CHK", Nil     , "4" },;
									{ "TAFA377", Nil        , "CHW", Nil     , "4" },;
									{ "TAFA378", Nil        , "CHY", Nil     , "4" },;
									{ "TAFA380", Nil        , "CW5", Nil     , "4" },;
									{ "TAFA383", Nil        , "CW6", Nil     , "4" },;
									{ "TAFA384", Nil        , "CZS", Nil     , "4" },;
									{ "TAFA385", Nil        , "CZT", Nil     , "4" },;
									{ "TAFA386", Nil        , "CZU", Nil     , "4" },;
									{ "TAFA387", Nil        , "CZV", Nil     , "4" },;
									{ "TAFA390", Nil        , "T12", Nil     , "4" },;
									{ "TAFA391", Nil        , "T13", Nil     , "4" },;
									{ "TAFA395", Nil        , "T26", Nil     , "4" },;
									{ "TAFA401", Nil        , "T34", Nil     , "4" },;
									{ "TAFA402", Nil        , "T37", Nil     , "4" },;
									{ "TAFA405", Nil        , "T3E", Nil     , "4" },;
									{ "TAFA417", Nil        , "T1T", Nil     , "4" },;
									{ "TAFA419", Nil        , "T2D", Nil     , "4" },;
									{ "TAFA427", Nil        , "T0I", Nil     , "4" },;
									{ "TAFA431", Nil        , "T0K", Nil     , "4" },;
									{ "TAFA432", Nil        , "T0L", Nil     , "4" },;
									{ "TAFA437", Nil        , "T0V", Nil     , "4" },;
									{ "TAFA440", Nil        , "LE7", Nil     , "4" },;
									{ "TAFA442", Nil        , "LE5", Nil     , "4" },;
									{ "TAFA445", Nil        , "LEE", Nil     , "4" },;
									{ "TAFA451", Nil        , "CWZ", Nil     , "4" },;
									{ "TAFA453", Nil        , "LF0", Nil     , "4" },;
									{ "TAFA457", Nil        , "T58", Nil     , "4" },;
									{ "TAFA458", Nil        , "T59", Nil     , "4" },;
									{ "TAFA459", Nil        , "T5A", Nil     , "4" },;
									{ "TAFA460", Nil        , "T5B", Nil     , "4" },;
									{ "TAFA461", Nil        , "T5C", Nil     , "4" },;
									{ "TAFA462", Nil        , "T5D", Nil     , "4" },;
									{ "TAFA463", Nil        , "T5E", Nil     , "4" },;
									{ "TAFA468", Nil        , "T5O", Nil     , "4" },;
									{ "TAFA464", Nil        , "T5F", Nil     , "4" },;
									{ "TAFA465", Nil        , "T5G", Nil     , "4" },;
									{ "TAFA454", Nil        , "T54", Nil     , "4" },;
									{ "TAFA455", Nil        , "T55", Nil     , "4" },;
									{ "TAFA466", Nil        , "T5H", Nil     , "4" },;
									{ "TAFA424", Nil        , "T2T", Nil     , "4" },;
									{ "TAFA475", Nil        , "T71", Nil     , "4" },;
									{ "TAFA479", Nil        , "T82", Nil     , "4" },;
									{ "TAFA480", Nil        , "T81", Nil     , "4" },;
									{ "TAFA481", Nil        , "T83", Nil     , "4" },;
									{ "TAFA482", Nil        , "T84", Nil     , "4" },;
									{ "TAFA483", Nil        , "T85", Nil     , "4" },;
									{ "TAFA487", Nil        , "T9A", Nil     , "4" },;
									{ "TAFA488", Nil        , "T9B", Nil     , "4" },;
									{ "TAFA504", Nil        , "V1P", Nil     , "4" },;
									{ "TAFA516", Nil        , "V2K", Nil     , "4" },;
									{ "TAFA517", Nil        , "V2L", Nil     , "4" },;
									{ "TAFA518", Nil        , "V2M", Nil     , "4" },;
									{ "TAFA522", Nil        , "V26", Nil     , "4" },;
									{ "TAFA523", Nil        , "V27", Nil     , "4" },;
									{ "TAFA524", Nil        , "V28", Nil     , "4" },;
									{ "TAFA525", Nil        , "V29", Nil     , "4" },;
									{ "TAFA530", Nil        , "V3F", Nil     , "4" },;
									{ "TAFA532", Nil        , "V3K", Nil     , "4" },;
									{ "TAFA554", Nil        , "V5L", Nil     , "4" }}

					if !lMenuDef
						If TAFAlsInDic("V6T")
							aAdd (aAutoCon, { "TAFA581", Nil        , "V6T", Nil     , "4" })
						EndIf

						If TAFAlsInDic("V6U")
							aAdd (aAutoCon, { "TAFA582", Nil        , "V6U", Nil     , "4" })
						EndIf
						
						If TAFAlsInDic("V3O") 
							aAdd (aAutoCon, { "TAFA533", Nil        , "V3O", Nil     , "4"})
							aAdd (aAutoCon, { "TAFA534", NIL        , "V3Q", NIL     , "4" })
							aAdd (aAutoCon, { "TAFA540", NIL        , "V4E", NIL     , "4" })
						EndIf 

						If TAFAlsInDic("V5O")
							If X3Uso( Posicione( "SX3", 2, "V5P_ITEM", "X3_USADO" )) .and. X3Uso( Posicione( "SX3", 2, "V5Q_ITEM", "X3_USADO" ))        
								aAdd (aAutoCon, { "TAFA570", Nil        , "V5O", Nil     , "4" })
							EndIf
						EndIf

						If TAFAlsInDic("V5Y") 					
							aAdd (aAutoCon, { "TAFA578", NIL        , "V5Y", NIL     , "4" })
							aAdd (aAutoCon, { "TAFA579", NIL        , "V5Z", NIL     , "4" })
						EndIf

						If TAFAlsInDic("V6Z")
							aAdd (aAutoCon, { "TAFA583", Nil        , "V6Z", Nil     , "4" })
						EndIf

						If TAFAlsInDic("V9H") 					
							AAdd(aAutoCon, {"TAFA605", Nil, "V9H", Nil, "4"})
						EndIf

						If TAFAlsInDic("V9T")
							aAdd (aAutoCon, { "TAFA607", Nil        , "V9T", Nil     , "4" })
						EndIf
					EndIf

					aAdd ( aTafReinf, { "TAFA494", "", "T9U", "R-1000", "5", ""          , "", "TAF494Xml", "evtInfoContri"		, 2, "", "C", 4, ""          , "", "TAFAPR1000", .T. } )
					aAdd ( aTafReinf, { "TAFA495", "", "T9V", "R-1070", "5", ""          , "", "TAF495Xml", "evtTabProcesso" 	, 2, "", "C", 4, ""          , "", "TAFAPR1070", .F. } )
					aAdd ( aTafReinf, { "TAFA486", "", "T95", "R-2010", "5", "T95_PERAPU", "", "TAF486Xml", "evtServTom"	 	, 2, "", "M", 5, "T95_PERAPU", "", "TAFAPRCP"  , .F. } )
					aAdd ( aTafReinf, { "TAFA478", "", "CMN", "R-2020", "5", "CMN_PERAPU", "", "TAF478Xml", "evtServPrest"		, 2, "", "M", 5, "CMN_PERAPU", "", "TAFAPRCP"  , .F. } )
					aAdd ( aTafReinf, { "TAFA490", "", "T9D", "R-9000", "5", ""		   	 , "", "TAF490Xml", "evtExclusao"		, 2, "", "E", 4, "T9D_TPEVE" , "", /*Apuração*/, .F. } ) //aRotinas[x][06] - Campo de período - Não informado pois o cadastro possui 2 campos de Período
					aAdd ( aTafReinf, { "TAFA255", "", "C9B", "R-2030", "5", "C9B_PERAPU", "", "TAF255Xml", "evtAssocDespRec"	, 2, "", "M", 5, "C9B_PERAPU", "", "TAFAPRECAD", .F. } )
					aAdd ( aTafReinf, { "TAFA491", "", "T9K", "R-2040", "5", "T9K_PERAPU", "", "TAF491Xml", "evtAssocDespRep"	, 2, "", "M", 5, "T9K_PERAPU", "", "TAFAPRECAD", .F. } )
					aAdd ( aTafReinf, { "TAFA492", "", "V1D", "R-2050", "5", "V1D_PERAPU", "", "TAF492Xml", "evtComProd"		, 2, "", "M", 7, "V1D_PERAPU", "", "TAFAPR2050", .F. } )

					if lReinf15
						aAdd(aTafReinf,{ "TAFA576","", "V5S", "R-2055", "5", "V5S_PERAPU", "", "TAF576Xml", "evtAqProd" 	   	, 2, "", "M", 5, "V5S_PERAPU", "", "TAFAPR2055", .F. })
					endif

					aAdd ( aTafReinf, { "TAFA499", "", "V0S", "R-2060", "5", "V0S_PERAPU", "", "TAF499Xml", "evtinfocprb"		, 2, "", "M", 3, "V0S_PERAPU", "", "TAFAPR2060", .F. } )
					aAdd ( aTafReinf, { "TAFA502", "", "V1A", "R-2098", "5", "V1A_PERAPU", "", "TAF502Xml", "evtReabreEvPer"  	, 2, "", "E", 4, "V1A_PERAPU", "", "TAFAPR2098", .F. } )
					aAdd ( aTafReinf, { "TAFA496", "", "V0B", "R-2099", "5", "V0B_PERAPU", "", "TAF496Xml", "evtFechaEvPer"  	, 2, "", "E", 4, "V0B_PERAPU", "", "TAFAPR2099", .T. } )
					aAdd ( aTafReinf, { "TAFA493", "", "V0L", "R-3010", "5", "V0L_PERAPU", "", "TAF493Xml", "evtEspDesportivo"	, 2, "", "E", 4, "V0L_PERAPU", "", "TAFAPR3010", .F. } )
					aAdd ( aTafReinf, { "TAFA501", "", "V0W", "R-5001", "5", "V0W_PERAPU", "", "TAF501Xml", "evtTotalTribEvt"	, 2, "", "T", 5, "V0W_PERAPU", "", /*Apuração*/, .F. } )
					aAdd ( aTafReinf, { "TAFA497", "", "V0C", "R-5011", "5", "V0C_PERAPU", "", "TAF497Xml", "evtTotalContrib"	, 2, "", "T", 5, "V0C_PERAPU", "", /*Apuração*/, .F. } )
					aAdd ( aTafReinf, { "TAFA503", "", "V1O", ""      , "5", ""		   	 , "", ""		  , ""					, 2, "", ""	, 5, ""			 , "", /*Apuração*/, .F. } )

					If lReinf20
						aAdd ( aTafReinf, { "TAFA546", "", "V5C", "R-4020", "5", "V5C_PERAPU", "", ""           , "" 	            , 2, "", "M", 5, "V5C_PERAPU", "", "TAFAPR4020", .F. })
						aAdd ( aTafReinf, { "TAFA545", "", "V4Q", "R-4010", "5", "V4Q_PERPAU", "", ""		 	, ""				, 2, "", "M", 5, "V4Q_PERPAU", "", "TAFAPR4010", .F. })
						aAdd ( aTafReinf, { "TAFA543", "", "V4N", "R-4040", "5", "V4N_PERPAU", "", ""		 	, ""				, 2, "", "M", 5, "V4N_PERPAU", "", "TAFAPR4040", .F. })
						aAdd ( aTafReinf, { "TAFA547", "", "V30", "R-4098", "5", "V30_PERAPU", "", ""		 	, ""				, 2, "", "E", 4, "V30_PERAPU", "", "TAFAPR4098", .F. })
						aAdd ( aTafReinf, { "TAFA548", "", "V3W", "R-4099", "5", "V3W_PERAPU", "", ""		 	, ""				, 2, "", "E", 4, "V3W_PERAPU", "", "TAFAPR4099", .F. })
					Endif

	//Array de fontes genéricos
	aTafGen  := { 	{ "TAFA485", ""			, "T93", "T200", "6", "", "", "", "", , "", "", , "", "", "", .F. } ,;
					{ "TAFA489", ""			, "T9C", "T157", "6", "", "", "", "", , "", "", , "", "", "", .F. }}

			If lReinf20	
				aAdd (aTafGen,	{ "TAFA535", ""			, "V3U", "T158", "6", "", "", "", "", , "", "", , "", "", "", .F. } )
				aAdd (aTafGen,	{ "TAFA536", ""			, "V3X", "T159", "6", "", "", "", "", , "", "", , "", "", "", .F. } )
				aAdd (aTafGen,	{ "TAFA541", ""			, "V4F", "T160", "6", "", "", "", "", , "", "", , "", "", "", .F. } )
				aAdd (aTafGen,	{ "TAFA537", ""			, "V3Z", "T161", "6", "", "", "", "", , "", "", , "", "", "", .F. } ) 
				aAdd (aTafGen,	{ "TAFA542", ""			, "V4K", "T162", "6", "", "", "", "", , "", "", , "", "", "", .F. } ) 
				aAdd (aTafGen,	{ "TAFA538", ""			, "V4A", "T163", "6", "", "", "", "", , "", "", , "", "", "", .F. } )
				aAdd (aTafGen,	{ "TAFA539", ""			, "V4B", "T164", "6", "", "", "", "", , "", "", , "", "", "", .F. } )
			Endif

	If lLayAtivo

		For n := 1 To Len(aTafeSc)

			If aTafeSc[n,19]
				Aadd(aAuxEvt, aTafeSc[n])
			EndIf

		Next

		aTafeSc := aAuxEvt

	EndIf

	//Para Owner 0, deve-se criar um único array com todos os demais Owners
	If nOwner == 0

		nTamFis := Len( aTafFis )
		nTameSc := Len( aTafeSc ) 
		nTamEcf := Len( aTafEcf )
		nTamAut := Len( aAutoCon )
		nTamReinf := Len(aTafReinf)
		nTamGen := Len(aTafGen)

		aRotinas := Array( ( nTamFis + nTameSc + nTamEcf + nTamAut + nTamReinf + nTamGen ), 6 )

		aCopy( aTafFis, aRotinas, 1, nTamFis, 1 )
		nTamRot += nTamFis

		aCopy( aTafeSc, aRotinas, 1, nTameSc, nTamRot + 1 )
		nTamRot += nTameSc

		aCopy( aTafEcf, aRotinas, 1, nTamEcf, nTamRot + 1 )
		nTamRot += nTamEcf

		aCopy( aAutoCon, aRotinas, 1, nTamAut, nTamRot + 1 )
		nTamRot += nTamAut

		aCopy( aTafGen, aRotinas, 1, nTamGen, nTamRot + 1 )
		nTamRot += nTamGen

		aCopy( aTafReinf, aRotinas, 1, nTamReinf, nTamRot + 1 )
		nTamRot += nTamReinf

	//Para Owner 3, adiciono os fontes do Fiscal que também fazem parte do ECF
	ElseIf nOwner == 3

		aAdd( aTafEcf, { "TAFA052", "TAF052Vld", "C2J", "T002", "1", "", "", "", "", , "", "", , "", "", "", .F. } )
		aAdd( aTafEcf, { "TAFA060", "TAF060Vld", "C1O", "T010", "1", "", "", "", "", , "", "", , "", "", "", .F. } )

	EndIf

	//Indica que deve ser retornado todo o array, de acordo com o Owner desejado
	If lAll

		Do Case
			Case nOwner == 0
				aRet := aRotinas
			Case nOwner == 1
				aRet := aTafFis
			Case nOwner == 2
				aRet := aTafeSc
			Case nOwner == 3
				aRet := aTafEcf
			Case nOwner == 4
				aRet := aAutoCon
			Case nOwner == 5
				aRet := aTafReinf
			Case nOwner == 6
				aRet := aTafGen
		EndCase

	//Indica que não deve ser retornado todo o array, ou seja, será realizado
	//a busca de uma informação no array, de acordo com o Owner desejado
	Else

		Do Case
			Case nOwner == 0
				If ( nPos := aScan( aRotinas, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aRotinas[nPos]
				EndIf
			Case nOwner == 1
				If ( nPos := aScan( aTafFis, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aTafFis[nPos]
				EndIf
			Case nOwner == 2
				If ( nPos := aScan( aTafeSc, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aTafeSc[nPos]
				EndIf
			Case nOwner == 3
				If ( nPos := aScan( aTafEcf, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aTafEcf[nPos]
				EndIf
			Case nOwner == 4
				If ( nPos := aScan( aAutoCon, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aAutoCon[nPos]
				EndIf
			Case nOwner == 5
				If ( nPos := aScan( aTafReinf, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aTafReinf[nPos]
				EndIf
			Case nOwner == 6
				If ( nPos := aScan( aTafGen, { |x| x[nScan] == cScan } ) ) > 0
					aRet := aTafGen[nPos]
				EndIf			
		EndCase

	EndIf

Return( aRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} tafIsTabeSocial
Informa se o Alias corresponde a um evento e-Social

@param		cAliasTab	-> Alias a ser verificado.

@return logico - se .T. o alias pertence a um evento e-Social.

@Version	1.0
/*/
//---------------------------------------------------------------------
Function tafIsTabeSocial(cAliasTab)

	Local aEvteSocial := {}
	Local nX := 0
	
	If Empty(cTabsEsocial) 

		aEvteSocial := TAFRotinas(,,.T.,2)

		For nX := 1 To Len(aEvteSocial)
			cTabsEsocial += aEvteSocial[nX][3] + "|"
		Next nX 

	EndIf 

Return (cAliasTab $ cTabsEsocial)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafFisLGPD

Verifica se o usuario tem acesso aos dados, caso nao,
a rotina e bloqueada (Ex: Gerar Xml)

@author  
@since   21/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafFisLGPD( cRotina )

	Local aArea 	:= GetArea()
	Local aHistAlt 	:= {}
	Local lRet 		:= .T.
	Local nPosTaf	:= 0
	Default cRotina := ""

	aHistAlt := TAFRotinas()

	If Len(aHistAlt) > 0

		nPosTaf := aScan(aHistAlt,{|x| x[1] == cRotina })

		If nPosTaf > 0 .And. Len(aHistAlt[nPosTaf]) > 16 .And. aHistAlt[nPosTaf][17]
			lRet := IIf(FindFunction("PROTDATA"),ProtData(),.T.)
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fRetIndx10
Retorna o indice utilizado no TAFROTINAS de acordo com o fonte pesquisado
@since   07/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fRetIndx10(cFonte)

	Local aEvts   := {{"TAFA279", 17, 22},;
					  {"TAFA277"         , 03, 06},;
					  {"TAFA403"         , 03, 05},;
					  {"TAFA407"         , 02, 07},;
					  {"TAFA250"         , 02, 09},;
					  {"TAFA422"         , 02, 03},;
					  {"TAFA520"         , 02, 07},;
					  {"TAFA303"         , 05, 06}}
	Local nIndex  := 0
	Local nPosEvt := 0

	If __lLaySimp == Nil
		__lLaySimp := TafLayESoc("S_01_00_00")
	EndIf
	
	nPosEvt := aScan(aEvts, {|x| x[1] == cFonte})

	If nPosEvt > 0
		nIndex := IIf(__lLaySimp, aEvts[nPosEvt][3], aEvts[nPosEvt][2])
	EndIf

Return nIndex
