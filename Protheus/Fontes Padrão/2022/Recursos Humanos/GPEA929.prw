#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA929.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEA929    ³ Autor ³ Alessandro Santos       	                ³ Data ³ 29/05/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Funcao para geracao de Logs eSocial                        			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³                                                           	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³11/08/2014³00000026544/2014³TQHIID   ³Inclusao de fonte na Versao 12.				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEA929()
Local cFilDe		:= Space(FWGETTAMFILIAL)
Local cFilAte		:= Replicate("Z", FWGETTAMFILIAL)
Local cEvenDe		:= Space(TamSx3("RFU_EVENTO")[1])
Local cEvenAte		:= Replicate("Z", TamSx3("RFU_EVENTO")[1])
Local cUserDe		:= Space(TamSx3("RFU_USERID")[1])
Local cUserAte		:= Replicate("Z", TamSx3("RFU_USERID")[1])
Local dDataDe		:= dDataBase 
Local dDataAte		:= dDataBase
Local cTpLog		:= OemToAnsi(STR0053) //#"3-Ambos"
Local aParamBox	 	:= {}
Local aRet			:= {}

	//Opcoes para filtro de logs
	aAdd(aParamBox, {1, "Filial De:"	, cFilDe	, "", "", "XM0"		, "", 0	, .F.})
	aAdd(aParamBox, {1, "Filial Até:"	, cFilAte	, "", "", "XM0"		, "", 0	, .T.})	
	aAdd(aParamBox, {1, "Evento De:"	, cEvenDe	, "", "", "EVESOC"	, "", 0	, .F.})
	aAdd(aParamBox, {1, "Evento Até:"	, cEvenAte	, "", "", "EVESOC"	, "", 0	, .T.})
	aAdd(aParamBox, {1, "Usuário De:"	, cUserDe	, "", "", "USR"		, "", 0	, .F.})
	aAdd(aParamBox, {1, "Usuário Até:"	, cUserAte	, "", "", "USR"		, "", 0	, .T.})
	aAdd(aParamBox, {1, "Data De:"		, dDataDe	, "", "", ""		, "", 50, .T.})
	aAdd(aParamBox, {1, "Data Até:"		, dDataAte	, "", "", ""		, "", 50, .T.})
	aAdd(aParamBox, {2, "Tipo de Log:"	, cTpLog	, {OemToAnsi(STR0051), OemToAnsi(STR0052), OemToAnsi(STR0053)}, 80, "", .F.}) //#"1-Integrado ao Taf" #"2-Erro na Integração com Taf"#"3-Ambos"
		
	//Executa perguntas		   
	If ParamBox(aParamBox, OemToAnsi(STR0003), @aRet) //##"Filtros - Logs eSocial"   	
		//Visualiza logs 
		fGp29Logs(aRet)		
	EndIf


Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Funcao    ³ fGp29Logs³ Autor ³ Alessandro Santos     ³ Data ³29/05/2014³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descricao ³ Gera tela com as informacoes de logs.                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Sintaxe   ³ fGp29Logs()                                           	  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³ aRet - Opcoes para os filtros                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³ Uso      ³ GPEA929   					                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp29Logs(aRet)

Local bFiltraBrw	:= Nil
Local cFiltro	:= ""
Local aIndex	:= {}
Local aCores  	:= {{"RFU->RFU_TPLOG == '1'" , "ENABLE" },; // Integrado
                  {"RFU->RFU_TPLOG == '2'" , "DISABLE"}}  // Erro

Private cCadastro := OemToAnsi(STR0004) //##"Logs - Eventos eSocial"
Private aRotina   := {}

//Opcoes da Rotina
AADD(aRotina, {"Pesquisar"	, "AxPesqui" 	, 0, 1})
AADD(aRotina, {"Visualizar"	, "AxVisual"	, 0, 2})
AADD(aRotina, {"Legenda"	, "fGp929Leg"	, 0, 5})


//Gera filtros com as opcoes do usuario
//Filial
cFiltro := "RFU_FILIAL >= '" + aRet[1] + "' .AND."
cFiltro += "RFU_FILIAL <= '" + aRet[2] + "' .AND."

//Eventos
cFiltro += "RFU_EVENTO >= '" + aRet[3] + "' .AND."
cFiltro += "RFU_EVENTO <= '" + aRet[4] + "' .AND."

//Usuarios
cFiltro += "RFU_USERID >= '" + aRet[5] + "' .AND."
cFiltro += "RFU_USERID <= '" + aRet[6] + "' .AND."

//Periodos
cFiltro += "RFU_DATA >= SToD('" + DToS(aRet[7]) + "') .AND."
cFiltro += "RFU_DATA <= SToD('" + DToS(aRet[8]) + "')"

//Tipo Log
If Subs(aRet[9], 1, 1) == "1" //Integrado ao Taf
	cFiltro += ".AND. RFU_TPLOG == '1'"
ElseIf Subs(aRet[9], 1, 1) == "2" //Erro na Integração com Taf
	cFiltro += ".AND. RFU_TPLOG == '2'"
EndIf

//Inicializa o filtro
bFiltraBrw := {|| FilBrowse("RFU", @aIndex, @cFiltro)}
Eval(bFiltraBrw) 

//Monta Browse
mBrowse(6, 1, 22, 75, "RFU",,,,,,aCores)

//Finaliza o Filtro
EndFilBrw("RFU" , @aIndex) 

Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Funcao    ³fTabelas  ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descricao ³Selecionar as tabelas para integracao com o TAF.            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Sintaxe   ³ fTabelas()                                           	  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³                                                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³ Uso      ³ GPEM023   					                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fGp929Eve()

Local aArea   	:= GetArea()
Local cTitulo 	:= OemToAnsi(STR0007) //##"Eventos eSocial"
Local MvPar   	:= &(ReadVar())
Local MvParDef	:= "" 
Local MvStrRet	:= ""
Local lRet    	:= .T. 
Local l1Elem  	:= .T.  
Local nI		:= 0
Local aEventos := {OemtoAnsi(STR0008),; //##"S1000 - Informações do Empregador"
					OemtoAnsi(STR0009),; //##"S1010 - Rubricas"
					OemtoAnsi(STR0010),; //##"S1020 - Lotações/Departamentos"
					OemtoAnsi(STR0011),; //##"S1030 - Cargos"
					OemtoAnsi(STR0012),; //##"S1040 - Funções"	
					OemtoAnsi(STR0013),; //##"S1050 - Horários/Turnos de Trabalho"	
					OemtoAnsi(STR0014),; //##"S1060 - Estabelecimentos/Obras"	
					OemtoAnsi(STR0015),; //##"S1070 - Processos Administrativos"	
					OemtoAnsi(STR0016),; //##"S1070 - Tabela de Operadores Portuarios"
					OemtoAnsi(STR0017),; //##"S2100 - Cadastramento Inicial do Vinculo"							
					OemtoAnsi(STR0018),; //##"S2200 - Admissão do Trabalhador"
					OemtoAnsi(STR0019),; //##"S2220 - Alteração dos dados cadastrais do trabalhador"
					OemtoAnsi(STR0020),; //##"S2240 - Alteração do Contrato de Trabalho"
					OemtoAnsi(STR0021),; //##"S2260 - Profissional de Saúde"
					OemtoAnsi(STR0022),; //##"S2280 - Atestado de Saúde ocupacional"
					OemtoAnsi(STR0023),; //##"S2320 - Afastamento Temporário"
					OemtoAnsi(STR0024),; //##"S2325 - Alteração do Motivo do Afastamento"
					OemtoAnsi(STR0025),; //##"S2330 - Retorno de Afastamento Temporário"
					OemtoAnsi(STR0026),; //##"S2340 - Estabilidade Início"
					OemtoAnsi(STR0027),; //##"S2345 - Estabilidade Término"					  
					OemtoAnsi(STR0028),; //##"S2360 - Condição Diferenciada de Trabalho - Início"
					OemtoAnsi(STR0029),; //##"S2365 - Condição Diferenciada de Trabalho - Término"
					OemtoAnsi(STR0030),; //##"S2400 - Aviso Prévio"
					OemtoAnsi(STR0031),; //##"S2405 - Cancelamento de Aviso Prévio"					  
					OemtoAnsi(STR0032),; //##"S2600 - Trabalhador sem Vínculo de Emprego"
					OemtoAnsi(STR0033),; //##"S2620 - Trabalhador Sem Vínculo de Emprego - Alt. Contratual"
					OemtoAnsi(STR0034),; //##"S2680 - Trabalhador Sem Vínculo de Emprego - Término"
					OemtoAnsi(STR0035),; //##"S2800 - Desligamento"
					OemtoAnsi(STR0036),; //##"S2820 - Reintegração"
					OemtoAnsi(STR0037),; //##"S1100 - Eventos Periódicos - Abertura"
					OemtoAnsi(STR0038),; //##"S1200 - Eventos Periódicos - Remuneração do Trabalhador"					  					  					  
					OemtoAnsi(STR0039),; //##"S1310 - Eventos Periódicos - Serviços Tomados mediante Cessão de Mão de Obra"
					OemtoAnsi(STR0040),; //##"S1320 - Eventos Periódicos - Serviços Prestados mediante Cessão de Mão de Obra"
					OemtoAnsi(STR0041),; //##"S1330 - Eventos Periódicos - Serviços Tomados de Cooperativa de Trabalho"
					OemtoAnsi(STR0042),; //##"S1340 - Eventos Periódicos - Serviços Prestados pela Cooperativa de Trabalho"
					OemtoAnsi(STR0043),; //##"S1350 - Eventos Periódicos - Aquisição de Produção"
					OemtoAnsi(STR0044),; //##"S1360 - Eventos Periódicos - Comercialização da Produção"
					OemtoAnsi(STR0045),; //##"S1380 - Eventos Periódicos - Informações complementares a Desoneração"
					OemtoAnsi(STR0046),; //##"S1390 - Eventos Periódicos - Receita de Atividades Concomitantes"					  
					OemtoAnsi(STR0047),; //##"S1399 - Eventos Periódicos - Fechamento"					  					  
					OemtoAnsi(STR0048),; //##"S1400 - Eventos Periódicos - Bases, Retenção, Deduções e Contribuições"
					OemtoAnsi(STR0049),; //##"S1800 - Eventos Periódicos - Espetáculo Desportivo"					  
					OemtoAnsi(STR0050)}  //##"S2900 - Exclusão de Eventos"

VAR_IXB := MvPar

//Opcoes
For nI := 1 To Len(aEventos)
	MvParDef += Subs(aEventos[nI], 1, 5)
Next nI

//Seleciona opcao	
If f_Opcoes(@MvPar, cTitulo, aEventos, MvParDef,,, l1Elem, 5)
	For nI := 1 To Len(MvPar)
		If (SubStr(MvPar, nI, 5) # "*")
			MvStrRet += SubStr(mvpar, nI, 5)
		Else
       		MvStrRet += Space(5)
       EndIf
	Next nI
	
	VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)

Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Funcao    ³fGp929Leg ³ Autor ³ Alessandro Santos     ³ Data ³11/07/2014³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descricao ³Legenda dos Logs de Eventos eSocial.                        ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Sintaxe   ³ fGp929Leg()                                           	  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³                                                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³ Uso      ³ GPEA929   					                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fGp929Leg()

Local aLegenda := {}

//Montagem da legenda dos Logs
AADD(aLegenda,{"BR_VERDE" 	, OemToAnsi(STR0054)})	//#"Integrado ao TAF"
AADD(aLegenda,{"BR_VERMELHO", OemToAnsi(STR0055)})	//#"Erro na Integração"

BrwLegenda(cCadastro, OemToAnsi(STR0056), aLegenda) //#"Legenda"

Return Nil