#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA929.CH"

/*/
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEA929    � Autor � Alessandro Santos       	                � Data � 29/05/2014 ���
���������������������������������������������������������������������������������������������������Ĵ��
���Descricao 	� Funcao para geracao de Logs eSocial                        			            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	�                                                           	  		            ���
���������������������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Analista     � Data     � FNC/Requisito  � Chamado �  Motivo da Alteracao                        ���
���������������������������������������������������������������������������������������������������Ĵ��
���Raquel Hager �11/08/2014�00000026544/2014�TQHIID   �Inclusao de fonte na Versao 12.				���
����������������������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������*/

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
	aAdd(aParamBox, {1, "Filial At�:"	, cFilAte	, "", "", "XM0"		, "", 0	, .T.})	
	aAdd(aParamBox, {1, "Evento De:"	, cEvenDe	, "", "", "EVESOC"	, "", 0	, .F.})
	aAdd(aParamBox, {1, "Evento At�:"	, cEvenAte	, "", "", "EVESOC"	, "", 0	, .T.})
	aAdd(aParamBox, {1, "Usu�rio De:"	, cUserDe	, "", "", "USR"		, "", 0	, .F.})
	aAdd(aParamBox, {1, "Usu�rio At�:"	, cUserAte	, "", "", "USR"		, "", 0	, .T.})
	aAdd(aParamBox, {1, "Data De:"		, dDataDe	, "", "", ""		, "", 50, .T.})
	aAdd(aParamBox, {1, "Data At�:"		, dDataAte	, "", "", ""		, "", 50, .T.})
	aAdd(aParamBox, {2, "Tipo de Log:"	, cTpLog	, {OemToAnsi(STR0051), OemToAnsi(STR0052), OemToAnsi(STR0053)}, 80, "", .F.}) //#"1-Integrado ao Taf" #"2-Erro na Integra��o com Taf"#"3-Ambos"
		
	//Executa perguntas		   
	If ParamBox(aParamBox, OemToAnsi(STR0003), @aRet) //##"Filtros - Logs eSocial"   	
		//Visualiza logs 
		fGp29Logs(aRet)		
	EndIf


Return()

/* 
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� 
�������������������������������������������������������������������������Ŀ�� 
���Funcao    � fGp29Logs� Autor � Alessandro Santos     � Data �29/05/2014��� 
�������������������������������������������������������������������������Ĵ�� 
���Descricao � Gera tela com as informacoes de logs.                      ��� 
�������������������������������������������������������������������������Ĵ�� 
���Sintaxe   � fGp29Logs()                                           	  ��� 
�������������������������������������������������������������������������Ĵ�� 
���Parametros� aRet - Opcoes para os filtros                              ��� 
�������������������������������������������������������������������������Ĵ�� 
��� Uso      � GPEA929   					                              ��� 
��������������������������������������������������������������������������ٱ� 
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� */

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
ElseIf Subs(aRet[9], 1, 1) == "2" //Erro na Integra��o com Taf
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
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� 
�������������������������������������������������������������������������Ŀ�� 
���Funcao    �fTabelas  � Autor � Alessandro Santos     � Data �03/02/2014��� 
�������������������������������������������������������������������������Ĵ�� 
���Descricao �Selecionar as tabelas para integracao com o TAF.            ��� 
�������������������������������������������������������������������������Ĵ�� 
���Sintaxe   � fTabelas()                                           	  ��� 
�������������������������������������������������������������������������Ĵ�� 
���Parametros�                                                            ��� 
�������������������������������������������������������������������������Ĵ�� 
��� Uso      � GPEM023   					                              ��� 
��������������������������������������������������������������������������ٱ� 
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� */

Function fGp929Eve()

Local aArea   	:= GetArea()
Local cTitulo 	:= OemToAnsi(STR0007) //##"Eventos eSocial"
Local MvPar   	:= &(ReadVar())
Local MvParDef	:= "" 
Local MvStrRet	:= ""
Local lRet    	:= .T. 
Local l1Elem  	:= .T.  
Local nI		:= 0
Local aEventos := {OemtoAnsi(STR0008),; //##"S1000 - Informa��es do Empregador"
					OemtoAnsi(STR0009),; //##"S1010 - Rubricas"
					OemtoAnsi(STR0010),; //##"S1020 - Lota��es/Departamentos"
					OemtoAnsi(STR0011),; //##"S1030 - Cargos"
					OemtoAnsi(STR0012),; //##"S1040 - Fun��es"	
					OemtoAnsi(STR0013),; //##"S1050 - Hor�rios/Turnos de Trabalho"	
					OemtoAnsi(STR0014),; //##"S1060 - Estabelecimentos/Obras"	
					OemtoAnsi(STR0015),; //##"S1070 - Processos Administrativos"	
					OemtoAnsi(STR0016),; //##"S1070 - Tabela de Operadores Portuarios"
					OemtoAnsi(STR0017),; //##"S2100 - Cadastramento Inicial do Vinculo"							
					OemtoAnsi(STR0018),; //##"S2200 - Admiss�o do Trabalhador"
					OemtoAnsi(STR0019),; //##"S2220 - Altera��o dos dados cadastrais do trabalhador"
					OemtoAnsi(STR0020),; //##"S2240 - Altera��o do Contrato de Trabalho"
					OemtoAnsi(STR0021),; //##"S2260 - Profissional de Sa�de"
					OemtoAnsi(STR0022),; //##"S2280 - Atestado de Sa�de ocupacional"
					OemtoAnsi(STR0023),; //##"S2320 - Afastamento Tempor�rio"
					OemtoAnsi(STR0024),; //##"S2325 - Altera��o do Motivo do Afastamento"
					OemtoAnsi(STR0025),; //##"S2330 - Retorno de Afastamento Tempor�rio"
					OemtoAnsi(STR0026),; //##"S2340 - Estabilidade In�cio"
					OemtoAnsi(STR0027),; //##"S2345 - Estabilidade T�rmino"					  
					OemtoAnsi(STR0028),; //##"S2360 - Condi��o Diferenciada de Trabalho - In�cio"
					OemtoAnsi(STR0029),; //##"S2365 - Condi��o Diferenciada de Trabalho - T�rmino"
					OemtoAnsi(STR0030),; //##"S2400 - Aviso Pr�vio"
					OemtoAnsi(STR0031),; //##"S2405 - Cancelamento de Aviso Pr�vio"					  
					OemtoAnsi(STR0032),; //##"S2600 - Trabalhador sem V�nculo de Emprego"
					OemtoAnsi(STR0033),; //##"S2620 - Trabalhador Sem V�nculo de Emprego - Alt. Contratual"
					OemtoAnsi(STR0034),; //##"S2680 - Trabalhador Sem V�nculo de Emprego - T�rmino"
					OemtoAnsi(STR0035),; //##"S2800 - Desligamento"
					OemtoAnsi(STR0036),; //##"S2820 - Reintegra��o"
					OemtoAnsi(STR0037),; //##"S1100 - Eventos Peri�dicos - Abertura"
					OemtoAnsi(STR0038),; //##"S1200 - Eventos Peri�dicos - Remunera��o do Trabalhador"					  					  					  
					OemtoAnsi(STR0039),; //##"S1310 - Eventos Peri�dicos - Servi�os Tomados mediante Cess�o de M�o de Obra"
					OemtoAnsi(STR0040),; //##"S1320 - Eventos Peri�dicos - Servi�os Prestados mediante Cess�o de M�o de Obra"
					OemtoAnsi(STR0041),; //##"S1330 - Eventos Peri�dicos - Servi�os Tomados de Cooperativa de Trabalho"
					OemtoAnsi(STR0042),; //##"S1340 - Eventos Peri�dicos - Servi�os Prestados pela Cooperativa de Trabalho"
					OemtoAnsi(STR0043),; //##"S1350 - Eventos Peri�dicos - Aquisi��o de Produ��o"
					OemtoAnsi(STR0044),; //##"S1360 - Eventos Peri�dicos - Comercializa��o da Produ��o"
					OemtoAnsi(STR0045),; //##"S1380 - Eventos Peri�dicos - Informa��es complementares a Desonera��o"
					OemtoAnsi(STR0046),; //##"S1390 - Eventos Peri�dicos - Receita de Atividades Concomitantes"					  
					OemtoAnsi(STR0047),; //##"S1399 - Eventos Peri�dicos - Fechamento"					  					  
					OemtoAnsi(STR0048),; //##"S1400 - Eventos Peri�dicos - Bases, Reten��o, Dedu��es e Contribui��es"
					OemtoAnsi(STR0049),; //##"S1800 - Eventos Peri�dicos - Espet�culo Desportivo"					  
					OemtoAnsi(STR0050)}  //##"S2900 - Exclus�o de Eventos"

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
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� 
�������������������������������������������������������������������������Ŀ�� 
���Funcao    �fGp929Leg � Autor � Alessandro Santos     � Data �11/07/2014��� 
�������������������������������������������������������������������������Ĵ�� 
���Descricao �Legenda dos Logs de Eventos eSocial.                        ��� 
�������������������������������������������������������������������������Ĵ�� 
���Sintaxe   � fGp929Leg()                                           	  ��� 
�������������������������������������������������������������������������Ĵ�� 
���Parametros�                                                            ��� 
�������������������������������������������������������������������������Ĵ�� 
��� Uso      � GPEA929   					                              ��� 
��������������������������������������������������������������������������ٱ� 
����������������������������������������������������������������������������� 
����������������������������������������������������������������������������� */

Function fGp929Leg()

Local aLegenda := {}

//Montagem da legenda dos Logs
AADD(aLegenda,{"BR_VERDE" 	, OemToAnsi(STR0054)})	//#"Integrado ao TAF"
AADD(aLegenda,{"BR_VERMELHO", OemToAnsi(STR0055)})	//#"Erro na Integra��o"

BrwLegenda(cCadastro, OemToAnsi(STR0056), aLegenda) //#"Legenda"

Return Nil