#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "APWIZARD.CH"
#INCLUDE 'GPEM027.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³GPEM027   ³ Autor ³ Flavio S Correa                   ³ Data ³ 13/04/15   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento Plano Saude - Hierarquia                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Flavio Correa |13/04/15|PCREQ-4461      |Inclusao Fonte                              ³±±
±±³Allyson M.    ³26/09/16³TVVKRA 		   ³Adicionado os campos LY_DTINI e LY_DTFIM na ³±±
±±³				 ³		  ³				   ³query de M027Diver pois os campos são utili-³±±
±±³				 ³		  ³				   ³zados no critério ABS;						³±±
±±³				 ³		  ³				   ³Efetuado ajuste nos Joins das tabela SJS,SJX³±±
±±³				 ³		  ³				   ³SL0 e SLE p/ considerar a filial do registro³±±
±±³				 ³		  ³				   ³da SRA e não o da filial logada pois o pro- ³±±
±±³				 ³		  ³				   ³cessamento pode ser efetuado p/ todas as    ³±±
±±³				 ³		  ³				   ³filiais;  									³±±
±±³				 ³		  ³				   ³Ajustes nas atualizações das tabelas RHK,RHL³±±
±±³				 ³		  ³				   ³e RHM p/ considerar a filial do registro da ³±±
±±³				 ³		  ³				   ³SRA ao invés da filial logada e p/ adequar  ³±±
±±³				 ³		  ³				   ³corretamente os cadastros de plano de saúde ³±±
±±³				 ³		  ³				   ³conforme o definido na gestão de serviços;  ³±±
±±³				 ³		  ³				   ³Ajustes em fRetAlias() p/ efetuar filtro de ³±±
±±³				 ³		  ³				   ³acordo com a filial de processamento;       ³±±
±±³				 ³		  ³				   ³Ajustes p/ execução do robô de testes       ³±±
±±³Paulo O I     ³13/04/2017³DRHPAG-239    ³Melhoria -  remoção de dependencias do ctree³±±
±±³Wesley Alves  ³02/07/2019³DRHGCH-11282  ³Manutenção - Selecionar todos Funcionários  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM027()
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME", "RB_NOME"} ), {})
Local lBlqAcesso	:= Len(aFldRel) > 0

Private oWizard		:= Nil
Private lNextPanel 	:= .T.
Private lPanel1		:= .T.
Private lPanel2		:= .F.
Private lPanel3		:= .F.
Private lPanel4		:= .F.
Private cArqTmp
Private cAliasMark	:= GetNextAlias()
Private oMSRA
Private __ODLG //variavel para pergunte forçando dialog
Private oTmpTable := Nil

	If lBlqAcesso	//Tratamento de acesso a dados pessoais
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Else

		If !IsBlind()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Painel 1 - Tela inicial do Wizard 		            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWizard := APWizard():New(	OemToAnsi(STR0001) 								,; // "Processamento Benefícios"
										"" ,; // "Essa ferramenta irá efetuar a conversão dos dados de sua versão antiga do Protheus para a nova versão 12."
										OemtoAnsi(STR0001)								,; // "Processamento Benefícios"
										OemToAnsi(STR0002)+ CRLF + OemToAnsi(STR0003)+ CRLF + OemToAnsi(STR0004)+ CRLF + OemToAnsi(STR0005)								,; // "Nas próximas telas você deverá parametrizar os itens necessários para a conversão, é importante que o manual seja lido antes da conversão para sanar possíveis dúvidas."
										{|| .T.}										,;
										{||.T.}									,;
										.F.												,;
										Nil												,;
										{||.T.}									)


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Painel 2 - Parametrização			                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWizard:NewPanel(	OemToAnsi(STR0006)		,; //"Parametrização"
								OemToAnsi(STR0007)		,; //"Selecione os parâemtros que serão utilizados na pesquisa"
								{||.T.}					,; //<bBack>
								{||.T.} 				,; //<bNext>
								{||.F.}					,; //<bFinish>
								.T.						,; //<.lPanel.>
								{|| M027Perg()} )		   //<bExecute>

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Painel 3 - Browse com funcionarios com divergencia              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWizard:NewPanel(	STR0008	,; //"Seleção de funcionários"
								STR0009		,; //"Selecione os funcionários que deverão ter os planos atualizados"
								{|| M027Back()}					,; //<bBack>
								{|| M027Next()} 				,; //<bNext>
								{||.F.}					,; //<bFinish>
								.T.						,; //<.lPanel.>
								{|| M027PDiver()} )		   //<bExecute>


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Painel 4 - Seleção das tabelas		                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWizard:NewPanel(	OemToAnsi(STR0015)		,; //"Processando"
								OemToAnsi(STR0016)		,; //"Atualizando Plano de Saúde conforme funcionários selecionados."
								{||.F.}					,; //<bBack>
								{||.F.}  				,; //<bNext>
								{|| M027Back()}					,; //<bFinish>
								.T. 					,; //<.lPanel.>
								{| lEnd| M027PProc(@lEnd)})	   //<bExecute>

			oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
		Else
			M027Diver()
			M027Proc()
		EndIf

		If Select(cAliasMark) > 0
			If oTmpTable <> Nil
				oTmpTable:Delete()
				oTmpTable := Nil
			EndIf
		EndIf

	EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027Perg      ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Perguntas wizard									 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027Perg()

If !lPanel2

	Pergunte("GPEM027",.T.,,,oWizard:oMPanel[oWizard:nPanel])
	lPanel2 := .T.
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027Back()      ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao Voltar										 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027Back()

	If Valtype(oMSRA) == "O"
		oMSRA:Deactivate()
	EndIf

	Pergunte("GPEM027",.F.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027PDiver     ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento Divergentes							 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027PDiver()
Local oProcess
// Executa o processamento dos arquivos
oProcess:=	MsNewProcess():New( {|lEnd| M027Diver(oProcess) } , OemToAnsi(STR0015) , OemToAnsi(STR0017) )     //"Processando/"Funcionarios"
oProcess:Activate()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027PDiver     ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento Divergentes							 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027Diver(oProcess)
Local aArea			:= GetArea()
Local cAliasSRA		:= GetNextAlias()
Local cqry			:= ""
Local cWhere		:= ""
Local nReg			:= 0
Local aColumns		:= {}
Local cCategoria	:= ""
Local cSituacao		:= ""
Local cWhere1		:= ""
Local lAgreg		:= .F.
Local lMarcar     	:= .F.
Local cMatOld		:= ""
Local lOk			:= .F.
Local cSGBD			:= AllTrim( Upper( TcGetDb() ) )
Local cTop1			:= ""
Local cOrder		:= ""
Local cSelect 		:= ""
Local aAloc			:= {}
Local nX			:= 1
Local cFilSRA		:= ""
Local cCodCri 		:= ""
Local cCodAlias 	:= ""
Local cSindCCT		:= ""
Local aTmp 			:= {}
Local nPosNovo 		:= 0
local nPos			:= 0
Local lGrava		:= .F.
Local dDtIni		:= cToD("//")
Local dDtFim		:= cToD("//")
Local cJoinSJS 		:= "%" + FwJoinFilial("SJS", "SRA") + "%"
Local cJoinSJX 		:= "%" + FwJoinFilial("SJX", "SRA") + "%"
Local cJoinSL0 		:= "%" + FwJoinFilial("SL0", "SRA") + "%"
Local cJoinSLE 		:= "%" + FwJoinFilial("SLE", "SRA") + "%"
Local aOrdem := {}

cWhere := " RA_PLSAUDE <> '2' AND "

MakeSqlExpr( "GPEM027" )

If !Empty(MV_PAR01)
	cWhere += MV_PAR01 + " AND "
EndIf

If !Empty(MV_PAR02)
	cWhere += MV_PAR02 + " AND "
EndIf

If !Empty(MV_PAR03)
	cWhere += MV_PAR03 + " AND "
EndIf

If !Empty(MV_PAR04)
	cWhere += MV_PAR04 + " AND "
EndIf

If !Empty(MV_PAR05)
	cWhere += MV_PAR05 + " AND "
EndIf

If !Empty(MV_PAR06)
	cCategoria := fSqlIN( MV_PAR06, 1 )
	cWhere += " RA_CATFUNC IN("		+ cCategoria	+")  AND "
Endif

If !Empty(MV_PAR07)
	cSituacao := fSqlIN( MV_PAR07, 1 )
	cWhere += " RA_SITFOLH IN("		+ cSituacao	+")  AND "
Endif

If !Empty(cWhere)
	cWhere		:= "%" + cWhere + "%"
Else
	cWhere		:= "% %"
EndIf
If MV_PAR08 == 1
	cWhere1 := "%" + "AND (RHK_TPCALC IN (' ','2' ,'1') OR RHK_TPCALC IS NULL)" + "%"
Else
	cWhere1 := "%" + "AND (RHK_TPCALC IN (' ','2') OR RHK_TPCALC IS NULL)" + "%"
EndIf

Do Case
	Case cSGBD $ "ORACLE"
		cTop1 += " AND ROWNUM <= 1 "
	Case cSGBD $ "MYSQL"
		cOrder += " LIMIT 1 "
	Case cSGBD $ "DB2"
		cOrder += " FETCH FIRST 1 ROW ONLY "
	Case cSGBD $ "INFORMIX"
	Otherwise
		cSelect := " TOP 1 "
EndCase

cSelect := "% " + cSelect + " %"
cTop1  := "% " + cTop1 + " %"
cOrder  := "% " + cOrder + " %"

	BeginSql alias cAliasSRA
		SELECT '' as RA_FLAG , RA_FILIAL,RA_MAT,RA_NOME,RA_CC, SRA.R_E_C_N_O_ AS RECNO,RA_PLSAUDE ,
		 RHK_MAT,RHK_PERINI,RHK_CDPSAG, RHK_TPFORN,RHK_TPCALC,RHK_PLANO,RHK_CODFOR,RHK_PD,RHK_PDDAGR,RHK_PERFIM,RHK_TPPLAN,
		 RHL_MAT,RHL_PERINI, RHL_TPFORN,RHL_TPCALC,RHL_PLANO,RHL_CODFOR,RHL_PERFIM,RHL_TPPLAN,
		 RHM_MAT,RHM_PERINI, RHM_TPFORN,RHM_TPCALC,RHM_PLANO,RHM_CODFOR,RHM_PERFIM,RHM_TPPLAN,
		 JX_PERINI, JX_TPFORN,JX_PLANO,JX_CODFORN,JX_PD,JX_PDDEP,JX_PERFIM,JX_TPPLANO,
		 L0_PERINI, L0_TPFORN,L0_PLANO,L0_CODFORN,L0_PERFIM,L0_TPPLANO,
		 LE_PERINI, LE_TPFORN,LE_PLANO,LE_CODFORN,LE_PERFIM,LE_TPPLANO,
		 LY_CHVENT,LY_CODIGO,LY_ALIAS,LY_FILENT,LY_AGRUP,LY_DTINI,LY_DTFIM
		FROM %table:SRA% SRA
		LEFT JOIN %table:RHK%  RHK on RHK_FILIAL = RA_FILIAL and RHK_MAT = RA_MAT
				AND RHK_TPFORN = %exp:'1'%
				AND RHK.%notDel% %exp:cWhere1%
		LEFT JOIN %table:RHL%  RHL on RHL_FILIAL = RA_FILIAL and RHL_MAT = RA_MAT
				AND RHL_TPFORN = %exp:'1'%
				AND RHL.%notDel%
		LEFT JOIN %table:RHM%  RHM on RHM_FILIAL = RA_FILIAL and RHM_MAT = RA_MAT
				AND RHM_TPFORN = %exp:'1'%
				AND RHM.%notDel%
		LEFT JOIN %table:SLY% SLY ON LY_FILIAL = RA_FILIAL  AND LY_TIPO=%exp:'PS'% AND SLY.%notDel%
					AND ( %exp:dtos(ddatabase)% >= LY_DTINI AND (%exp:dtos(ddatabase)% <= LY_DTFIM or LY_DTFIM = %exp:''%))
		 INNER JOIN %table:SJS% SJS on %exp:cJoinSJS% AND JS_CDAGRUP = LY_AGRUP and JS_TABELA = LY_ALIAS and SJS.%notDel%
		 LEFT JOIN %table:SJX% SJX ON %exp:cJoinSJX%  AND LY_CODIGO = JX_CODIGO AND SJX.%notDel% AND RHK_CDPSAG = JX_CODIGO
		 LEFT JOIN %table:SL0% SL0 ON %exp:cJoinSL0%  AND LY_CODIGO = L0_CODIGO AND SL0.%notDel% AND RHK_CDPSAG = L0_CODIGO
		 LEFT JOIN %table:SLE% SLE ON %exp:cJoinSLE%  AND LY_CODIGO = LE_CODIGO AND SLE.%notDel% AND RHK_CDPSAG = JX_CODIGO
		WHERE  %exp:cWhere%
			   SRA.%notDel%
		ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
	EndSql
/*
					AND LY_AGRUP=(SELECT  %exp:cSelect%  JQ_CODIGO
									FROM %table:SJQ%  SJQ
									WHERE SJQ.%notDel%
									AND JQ_FILIAL = %xfilial:SJQ%
									AND JQ_STATUS = %exp:'1'%
									AND JQ_FILREF IN (RA_FILIAL,'')
									%exp:cTop1%
									ORDER BY JQ_FILREF DESC %exp:cOrder% )
					AND LY_ALIAS IN	(SELECT JS_TABELA FROM %table:SJQ% SJQ
									INNER JOIN %table:SJS%  SJS ON JQ_CODIGO = JS_CDAGRUP AND JS_SEQ > %exp:'01'% AND SJS.%notDel%
									INNER JOIN %table:SLY%  SLY ON LY_FILIAL=RA_FILIAL AND LY_TIPO=%exp:'PS'%
											AND LY_AGRUP=JS_CDAGRUP AND LY_ALIAS = JS_TABELA
											AND ( %exp:dtos(ddatabase)% >= LY_DTINI AND (%exp:dtos(ddatabase)% <= LY_DTFIM or LY_DTFIM = %exp:''%))
											AND SLY.%notDel%
									WHERE SJQ.%notDel%)
*/

DbSelectArea(cAliasSRA)
Count To nReg
dbSelectArea(cAliasSRA)
(cAliasSRA)->( DbGoTop() )

If !IsBlind()
	oProcess:SetRegua1(nReg)
EndIf

aColumns := {}
AADD( aColumns, {"RA_FLAG"		,"C",02,00 })
Aadd( aColumns, { "RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]		,GetSx3Cache( "RA_FILIAL" , "X3_PICTURE" ) })
Aadd( aColumns, { "RA_MAT"		,"C",TAMSX3("RA_MAT")[1],TAMSX3("RA_MAT")[2]			,GetSx3Cache( "RA_MAT" , "X3_PICTURE" )})
Aadd( aColumns, { "RA_NOME"		,"C",TAMSX3("RA_NOME")[1],TAMSX3("RA_NOME")[2]			,GetSx3Cache( "RA_NOME" , "X3_PICTURE" )})
Aadd( aColumns, { "RA_PLSAUDE"	,"C",TAMSX3("RA_PLSAUDE")[1],TAMSX3("RA_PLSAUDE")[2]	,GetSx3Cache( "RA_PLSAUDE" , "X3_PICTURE" )})
Aadd( aColumns, { "LY_CODIGO"	,"C",TAMSX3("RHK_CDPSAG")[1],TAMSX3("RHK_CDPSAG")[2]	,GetSx3Cache( "RHK_CDPSAG" , "X3_PICTURE" )})
Aadd( aColumns, { "LY_FILENT"	,"C",TAMSX3("LY_FILENT")[1],TAMSX3("LY_FILENT")[2]	,GetSx3Cache( "LY_FILENT" , "X3_PICTURE" )})
Aadd( aColumns, { "RHK_CDPSAG"	,"C",TAMSX3("RHK_CDPSAG")[1],TAMSX3("RHK_CDPSAG")[2]	,GetSx3Cache( "RHK_CDPSAG" , "X3_PICTURE" )})
Aadd( aColumns, { "G0_DESCR"	,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})
Aadd( aColumns, { "G0_DESCR1"	,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})
Aadd( aColumns, { "LY_ALIAS"	,"C",TAMSX3("LY_ALIAS")[1],TAMSX3("LY_ALIAS")[2]		,GetSx3Cache( "LY_ALIAS" , "X3_PICTURE" )})

If Select(cAliasMark) > 0
	DbSelectArea(cAliasMark)
	DbCloseArea()
EndIf

oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )

aOrdem	:=	{"RA_FILIAL","RA_MAT"}

oTmpTable:AddIndex("IND", aOrdem)
oTmpTable:Create()


While !(cAliasSRA)->(Eof())
	If !IsBlind()
		oProcess:IncRegua1(STR0014 + (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_NOME) //"Funcionário : "
	EndIf
	lAgreg := .F.
	lOk := .F.

	If cFilSRA <> (cAliasSRA)->RA_FILIAL
		cCodCri 	:= fRetCriter((cAliasSRA)->RA_FILIAL)
		cCodAlias 	:= fRetAlias(cCodCri, (cAliasSRA)->RA_FILIAL)
		cFilSra 	:= (cAliasSRA)->RA_FILIAL
		cSindCCT 	:= ""
	EndIf

	If (cAliasSRA)->LY_AGRUP == cCodCri
		lOk := .T.
	Endif

	If lOk .And. !Empty((cAliasSRA)->LY_ALIAS) .And. (cAliasSRA)->LY_ALIAS $ cCodAlias
		lOk := .T.
	EndIf

	If lOk

		dbSelectArea("SRA")
		SRA->(dbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT))

		//checa criterio
		Do Case
		Case ((cAliasSRA)->LY_ALIAS == "SQB")
			lOk := Alltrim(SRA->RA_DEPTO) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "RCE")
			lOk := Alltrim(SRA->RA_SINDICA) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "CTT")
			lOk := Alltrim(SRA->RA_CC) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "SQ3")
			lOk := Alltrim(SRA->RA_CARGO) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "RCL")
			lOk := Alltrim(SRA->RA_POSTO) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "SRJ")
			lOk := Alltrim(SRA->RA_CODFUNC) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "SR6")
			lOk := Alltrim(SRA->RA_TNOTRAB) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "SM0")
			lOk := Alltrim(SRA->RA_FILIAL) == Alltrim((cAliasSRA)->LY_CHVENT)
		Case ((cAliasSRA)->LY_ALIAS == "SWY")
			If Empty(cSindCCT)
				cSindCCT := fLoadCCT((cAliasSRA)->LY_CHVENT, SRA->RA_FILIAL)
			EndIf
			lOk := Alltrim(SRA->RA_SINDICA) $ cSindCCT
		Case ((cAliasSRA)->LY_ALIAS $ "ABS*SA1*TDX")
			dDtIni	:= sToD((cAliasSRA)->LY_DTINI)
			If !Empty((cAliasSRA)->LY_DTFIM)
				dDtFim := sToD((cAliasSRA)->LY_DTFIM)
			Else
				dDtFim := cToD( StrZero( f_UltDia( dDtIni ), 2) + "/" + SubStr( (cAliasSRA)->LY_DTINI, 5, 2 ) + "/" + SubStr( (cAliasSRA)->LY_DTINI, 1, 4 ) )
			EndIf

			aAloc := TXRetAloc((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT , dDtIni, dDtFim)
			lOk := .F.
			For nX := 1 to Len(aAloc)
				If ( (cAliasSRA)->LY_ALIAS == "ABS" .and. aAloc[nX][07] == Alltrim((cAliasSRA)->LY_CHVENT )) .or. ( (cAliasSRA)->LY_ALIAS == "SA1" .and. aAloc[nX][10] + aAloc[nX][11] == Alltrim((cAliasSRA)->LY_CHVENT) ) .or. ( (cAliasSRA)->LY_ALIAS == "TDX" .and. aAloc[nX][15] + aAloc[nX][08] == Alltrim((cAliasSRA)->LY_CHVENT ))
					lOk := .T.
					Exit
				EndIf
			Next nX

		OtherWise
			lOk := .F.
		EndCase
	EndIf

	If lOk

		//checa dependentes
		If cMatOld <> (cAliasSRA)->RA_MAT
			cQry := GetNextAlias()
			BeginSql alias cQry
				SELECT COUNT(1) AS QTD
				FROM %table:SRB% SRB
				WHERE RB_MAT=%exp:(cAliasSRA)->RA_MAT%
				and SRB.%notdel%
			EndSql

			lDepend := .F.
			If (cQry)->QTD > 0
				lDepend := .T.
			EndIf
			cMatOld := (cAliasSRA)->RA_MAT
			(cQry)->(dbCloseArea())
		EndIf

		//checa planos agregados
		If !Empty((cAliasSRA)->RHM_TPPLAN)
			If ( (cAliasSRA)->RHM_TPPLAN <> (cAliasSRA)->LE_TPPLANO .Or. (cAliasSRA)->RHM_CODFOR <> (cAliasSRA)->LE_CODFORN ;
					.Or. (cAliasSRA)->RHM_PLANO <> (cAliasSRA)->LE_PLANO)
				lAgreg := .T.
			EndIf
		Endif

		If ( ( Alltrim((cAliasSRA)->LY_CODIGO) <> Alltrim((cAliasSRA)->RHK_CDPSAG)) .Or. Empty((cAliasSRA)->RHK_CDPSAG) ) ;
				.Or. ( (cAliasSRA)->RHK_TPPLAN	<> (cAliasSRA)->JX_TPPLANO .Or. (cAliasSRA)->RHK_CODFOR <> (cAliasSRA)->JX_CODFORN .Or. (cAliasSRA)->RHK_PD <> (cAliasSRA)->JX_PD;
						.Or. (cAliasSRA)->RHK_PDDAGR <> (cAliasSRA)->JX_PDDEP .Or. (cAliasSRA)->RHK_PLANO <> (cAliasSRA)->JX_PLANO ;
						.Or. (cAliasSRA)->RHK_PERFIM <> (cAliasSRA)->JX_PERFIM );
				.Or. ( lDepend .And.( (cAliasSRA)->RHL_TPPLAN	<> (cAliasSRA)->L0_TPPLANO .Or. (cAliasSRA)->RHL_CODFOR <> (cAliasSRA)->L0_CODFORN ;
						.Or. (cAliasSRA)->RHL_PLANO <> (cAliasSRA)->L0_PLANO));
				.Or. lAgreg

			lGrava := .T.
			If !(cAliasMark)->(dbSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT))
				RecLock(cAliasMark,.T.)
			Else
				//definir prioridade de gravação
				aTmp := Separa(cCodAlias,"/")

				nPosNovo := ascan(aTMp,{|x| Alltrim(x)==Alltrim((cAliasSRA)->LY_ALIAS)})
				nPos := ascan(aTMp,{|x| Alltrim(x)==Alltrim((cAliasMark)->LY_ALIAS)})

				If nPosNovo >= nPos
					lGrava := .F.
				Else
					RecLock(cAliasMark,.F.)
				EndIf
			EndIf

			If lGrava
				If !IsBlind()
					(cAliasMark)->RA_FLAG			:= ""
				Else
					(cAliasMark)->RA_FLAG			:= "ZZ"
				EndIf
				(cAliasMark)->RA_FILIAL			:= (cAliasSRA)->RA_FILIAL
				(cAliasMark)->RA_MAT    		:= (cAliasSRA)->RA_MAT
				(cAliasMark)->RA_NOME    		:= (cAliasSRA)->RA_NOME
				(cAliasMark)->RA_PLSAUDE    	:= (cAliasSRA)->RA_PLSAUDE
				(cAliasMark)->RHK_CDPSAG    	:= (cAliasSRA)->RHK_CDPSAG
				If Empty((cAliasSRA)->RHK_CDPSAG)
					(cAliasMark)->G0_DESCR    	:= ""
				Else
					(cAliasMark)->G0_DESCR    	:= Posicione("SG0",1,xFilial("SG0")+(cAliasSRA)->RHK_CDPSAG,"G0_DESCR")
				EndIf

				(cAliasMark)->LY_CODIGO    		:= (cAliasSRA)->LY_CODIGO
				(cAliasMark)->LY_ALIAS    		:= (cAliasSRA)->LY_ALIAS
				(cAliasMark)->LY_FILENT    		:= (cAliasSRA)->LY_FILENT
				If Empty((cAliasSRA)->LY_CODIGO)
					(cAliasMark)->G0_DESCR1    	:= ""
				Else
					(cAliasMark)->G0_DESCR1    	:= Posicione("SG0",1,xFilial("SG0")+(cAliasSRA)->LY_CODIGO,"G0_DESCR")
				EndIf

				(cAliasMark)->(msUnlock())
			EndIf
		EndIf
	EndIf
	(cAliasSRA)->(dbSkip())
EndDo
(cAliasSRA)->(dbCloseArea())

dbSelectArea(cAliasMark)

If !IsBlind()
	aColumns := {}
	//AADD( aColumns, {"","RA_FLAG"	,"C",02,00 })
	Aadd( aColumns, { TitSX3("RA_FILIAL")[1]	,"RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]	,GetSx3Cache( "RA_FILIAL" , "X3_PICTURE" ) })
	Aadd( aColumns, { TitSX3("RA_MAT")[1]		,"RA_MAT"		,"C",TAMSX3("RA_MAT")[1],TAMSX3("RA_MAT")[2]		,GetSx3Cache( "RA_MAT" , "X3_PICTURE" )})
	Aadd( aColumns, { TitSX3("RA_NOME")[1]		,"RA_NOME"		,"C",TAMSX3("RA_NOME")[1],TAMSX3("RA_NOME")[2]		,GetSx3Cache( "RA_NOME" , "X3_PICTURE" )})
	Aadd( aColumns, { STR0010					,"RHK_CDPSAG"	,"C",TAMSX3("RHK_CDPSAG")[1],TAMSX3("RHK_CDPSAG")[2]		,GetSx3Cache( "RHK_CDPSAG" , "X3_PICTURE" )}) //"Cod. Atual"
	Aadd( aColumns, { STR0012					,"G0_DESCR"		,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})//"Plano Atual"
	Aadd( aColumns, { STR0011					,"LY_CODIGO"	,"C",TAMSX3("RHK_CDPSAG")[1],TAMSX3("RHK_CDPSAG")[2]		,GetSx3Cache( "RHK_CDPSAG" , "X3_PICTURE" )})//"Cod. Criterio"
	Aadd( aColumns, { STR0013					,"G0_DESCR1"	,"C",TAMSX3("G0_DESCR")[1],TAMSX3("G0_DESCR")[2]		,GetSx3Cache( "G0_DESCR" , "X3_PICTURE" )})//"Plano Criterio"

	If ValType(oMSRA) == "O"
		oMSRA:Refresh()
	//	oMSRA:deActivate()
	Else
		oMSRA := FWMarkBrowse():New()
		oMSRA:SetOwner( oWizard:oMPanel[oWizard:nPanel] )//Define o objeto pai
		oMSRA:SetDataTable(.T.)
		oMSRA:SetFields(aColumns)
		oMSRA:SetAlias( cAliasMark )//Define alias de utilizacao
		oMSRA:SetTemporary(.T.)
		oMSRA:SetFieldMark( 'RA_FLAG' )
		oMSRA:SetAllMark( { || SetMarkAll(oMSRA:Mark(),lMarcar := !lMarcar ), oMSRA:Refresh(.T.) } )
		//oMSRA:bAllMark := { ||   }

		oMSRA:DisableReport()
		oMSRA:DisableConfig()
		oMSRA:DisableSaveConfig()
		oMSRA:SetMenuDef( '' )
		oMSRA:Activate()//Ativa o browse
	EndIf
EndIf

RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SetMarkAll  ³ Autor ³ Leandro Drumond       ³ Data ³ 17/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/desmarca todos os itens 			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetMarkAll(cMarca,lMarcar )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SetMarkAll(cMarca,lMarcar )

Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->RA_FLAG := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027PProc     ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano					 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027PProc()
Local oProcess

	// Executa o processamento dos arquivos
	If MsgYesNo(STR0019, STR0018) // "Deseja efetuar a atualização dos benefícios ?"#"Atencao"
		oProcess:=	MsNewProcess():New( {|lEnd| M027Proc(oProcess) } , OemToAnsi(STR0015) , OemToAnsi(STR0017) )     //"Processando/"Funcionarios"
		oProcess:Activate()
	Else
		Alert(STR0020)//"processamento cancelado pelo usuário"
	EndIf

Return

Static Function M027Next()
Local lRet := .T.

dbSelectArea(cAliasMark)
(cAliasMark)->(dbGotop())
If (cAliasMark)->(Eof())
	lRet := .F.
	Alert(STR0043)//"Nenhum funcionario selecionado"
EndIf
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027Proc     ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano					 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027Proc(oProcess)
Local aArea 	:= GetArea()
Local cMarca 	:= ""
Local cProc		:= ""
Local cPer		:= ""
Local cPerAnt	:= ""
Local cAnoM		:= ""
Local aPer		:= {}
Local oModel	:= FwLoadModel("GPEA001")
Local lRet		:= .T.
Local oPanel	:= Nil
Local nTot		:= 0
Local nOk		:= 0
Local nReg		:= 0
Local cBkpFil	:= cFilAnt

Local aGpem027Log		:= {}
Local aGpem027TitLog	:= {}
Local aProcessoLog		:= {}
Local aContadorLog		:= {}

If !IsBlind()
	cMarca 	:= oMSRA:Mark()
	oPanel	:= oWizard:oMPanel[oWizard:nPanel]
Else
	cMarca 	:= "ZZ"
EndIf

aAdd( aGpem027TitLog , STR0021 )	//"Informacoes do Processamento"
aAdd( aProcessoLog , STR0022 + " " + time() + " " + STR0023 + " " + Dtoc( MsDate() ) ) //"Inicio do Processamento:"###" de "
aAdd( aProcessoLog , "")
aAdd( aProcessoLog , Replicate('-',150))

dbSelectArea("SRA")
SRA->(dbSetOrder(1))

DbSelectArea(cAliasMark)
Count To nReg
dbSelectArea(cAliasMark)
(cAliasMark)->( DbGoTop() )

If !IsBlind()
	oProcess:SetRegua1(nReg)
EndIf

IndRegua( cAliasMark ,cArqTmp , "RA_FLAG+RA_FILIAL+RA_MAT" , NIL , NIL , NIL , .F. )

If (cAliasMark)->(dbSeek(cMarca))
	While !(cAliasMark)->(Eof()) .And. (cAliasMark)->(RA_FLAG) == cMarca
		Begin Transaction
			If !IsBlind()
				oProcess:IncRegua1(STR0014 + (cAliasMark)->RA_MAT + " - " + (cAliasMark)->RA_NOME) //"Funcionário : "
				oProcess:SetRegua2(4)
			EndIf
			If IsBlind() .Or. oMSRA:IsMark(cMarca)

				nTot++
				If SRA->(dbseek((cAliasMark)->RA_FILIAL+(cAliasMark)->RA_MAT))
					If !IsBlind()
						oProcess:IncRegua2(STR0046)//"Atualizando Cadastro"
					EndIf
					cFilAnt	:= (cAliasMark)->RA_FILIAL
					If cProc <> SRA->RA_PROCES
						fGetPerAtual( @aPer, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() )
						If !Empty(aPer)
							cAnoM := AnoMes(aPer[1,6]-1)
							cPerAnt := Substr(cAnoM,5,2)+Substr(cAnoM,1,4)
							cPer 	:= Substr(aPer[1,1],5,2)+Substr(aPer[1,1],1,4)
						EndIf
					EndIf
					cProc := SRA->RA_PROCES
					RecLock("SRA",.F.)
						SRA->RA_PLSAUDE := "1"
					SRA->(msUnlock())

					aAdd( aProcessoLog , STR0014 + (cAliasMark)->RA_FILIAL + " | " + (cAliasMark)->RA_MAT + " | " +SRA->RA_NOME ) //"Funcionário : "

					//Atualiza SRB
					lRet := M027AtuSRB(@aProcessoLog)

					If lRet
						If !IsBlind()
							oProcess:IncRegua2(STR0047)//"Atualizando Titular"
						EndIf

						oModel:SetOperation(4)
						oModel:Activate()

						//Atualiza Plano Saude/Odontologico TITULAR
						lRet := M027AtuRHK(cPer,cPerant,oModel,@aProcessoLog,oProcess)

						oModel:Deactivate()
					EndIf
				EndIf

				If lRet
					nOk++
					aAdd( aProcessoLog , STR0024)//"********* Plano atualizado com sucesso ***********"
				Else
					aAdd( aProcessoLog ,STR0025 )//"********* Plano NÃO atualizado ***********"
					DisarmTransaction()
				EndIf
				aAdd( aProcessoLog , Replicate('-',150))
			EndIf
		End Transaction
		lRet:= .T.
		(cAliasMark)->(dbSkip())
	EndDo

	aAdd( aContadorLog , "")
	aAdd( aContadorLog , STR0044 + Alltrim(Str(nTot)))//"Funcionários selecionados : "
	aAdd( aContadorLog , STR0045 + Alltrim(Str(nOk)))//"Funcionários processados com sucesso : "
	aAdd( aContadorLog , "")


	aAdd( aGpem027Log		, aClone( aContadorLog ) )
	aAdd( aGpem027Log		, aClone( aProcessoLog ) )

	If !IsBlind()
		@ 35,10 SAY OemToAnsi(STR0026) SIZE 150, 7 OF oPanel PIXEL//"Processamento Finalizado, consulte o LOG"
		DEFINE SBUTTON FROM 50, 105 TYPE 15 ENABLE OF oPanel ACTION ( M027Log(aGpem027TitLog,aGpem027Log) )
	EndIf
Else
	Alert(STR0043)//"Nenhum funcionario selecionado"
EndIf
RestArea(aArea)
cFilAnt := cBkpFil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027Log    ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geração de LOG									 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027Log(aGpem027TitLog,aGpem027Log)
Local nX 	:= 1
Local nY	:= 1

For nX := 1 to Len(aGpem027TitLog)
	AutoGrLog(aGpem027TitLog[nX])
	For nY := 1 to Len(aGpem027Log[nX])
		AutoGrLog(aGpem027Log[nX,nY])
	Next nY
Next nX
MsAguarde( { || fMakeLog( aGpem027Log , aGpem027TitLog , FunName() , NIL , FunName() ,,,,,.F.   )} ,  STR0027 ) //"Log de Ocorrencias no Processo de Calculo"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027AtuSRB    ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano	SRA/SRB			 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027AtuSRB(aProcessoLog)
Local lRet	:= .T.
Local nTot	:= 0
Local nAtu	:= 0

	dbSelectArea("SRB")
	SRB->(dbsetOrder(1))
	If SRB->(dbSeek((cAliasMark)->RA_FILIAL+(cAliasMark)->RA_MAT))
		While !SRB->(eof()) .AND. SRB->(RB_FILIAL+RB_MAT) == (cAliasMark)->RA_FILIAL+(cAliasMark)->RA_MAT
			nTot++
			If Empty(SRB->RB_PLSAUDE)
				nAtu++
				RecLock("SRB",.F.)
					SRB->RB_PLSAUDE := "1"
				SRB->(msUnlock())
			EndIf
			SRB->(dbSkip())
		EndDo
	EndIf

	aAdd( aProcessoLog , Space(2) + STR0028 + Str(nTot))//"Total de Dependentes  : "
	aAdd( aProcessoLog , Space(2) + STR0029 + Str(nAtu))//"Dependentes Atualizados : "
	aAdd( aProcessoLog , "")
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027AtuRHK    ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano	RHK				 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027AtuRHK(cPer,cPerant,oModel,aProcessoLog,oProcess)
Local lRet1		:= .T.
Local lRet2		:= .T.
Local lRet		:= .T.
Local nI		:= 1
Local cCodPl	:= padr(Alltrim((cAliasMark)->LY_CODIGO),TAMSX3("JX_CODIGO")[1])
Local oRHK
Local aErro		:= {}
Local lInativo	:= .F.

Private aRecRHM		:= {}

oRHK := oModel:GetModel("GPEA001_MRHK")

//verifica se existe o plano na SJX e atualiza RHK
dbSelectArea("SJX")
SJX->(dbSetOrder(1))
If SJX->(dbSeek(xFilial("SJX", (cAliasMark)->RA_FILIAL)+cCodPl))
	While !SJX->(Eof()) .And. SJX->(JX_FILIAL+JX_CODIGO) = xFilial("SJX", (cAliasMark)->RA_FILIAL)+cCodPl

		If !oRHK:SeekLine({{"RHK_FILIAL",(cAliasMark)->RA_FILIAL},{"RHK_MAT",(cAliasMark)->RA_MAT},{"RHK_TPFORN",SJX->JX_TPFORN},{"RHK_CODFOR",SJX->JX_CODFORN} ,{"RHK_TPPLAN",SJX->JX_TPPLANO},{"RHK_PLANO",SJX->JX_PLANO}})
			If oRHK:GetQtdLine() > 1 .or. !Empty(oRHK:GETValue("RHK_PLANO"))
				oRHK:addLine()
			EndIf
			ORHK:SetValue("RHK_FILIAL",(cAliasMark)->RA_FILIAL)
			ORHK:SetValue("RHK_MAT",(cAliasMark)->RA_MAT)
			ORHK:SetValue("RHK_TPFORN",SJX->JX_TPFORN)
			ORHK:SetValue("RHK_CODFOR",SJX->JX_CODFORN)
			ORHK:SetValue("RHK_TPPLAN",SJX->JX_TPPLANO)
			ORHK:SetValue("RHK_PLANO",SJX->JX_PLANO)
		EndIf
		ORHK:SetValue("RHK_PD",SJX->JX_PD)
		ORHK:SetValue("RHK_PDDAGR",SJX->JX_PDDEP)
		If SJX->JX_PERINI > cPer
			ORHK:SetValue("RHK_PERINI",SJX->JX_PERINI)
		Else
			ORHK:SetValue("RHK_PERINI",cPer)
		EndIf
		If SJX->JX_PERFIM < cPer .and. !Empty(SJX->JX_PERFIM)
			ORHK:SetValue("RHK_PERFIM",cPer)
		Else
			ORHK:SetValue("RHK_PERFIM",SJX->JX_PERFIM)
		EndIf
		ORHK:LoadValue("RHK_TPCALC","2")
		ORHK:LoadValue("RHK_CDPSAG",SJX->JX_CODIGO)

		aAdd( aProcessoLog, Space(6)  + STR0030 + ; //"Titular - Plano Atual  : "
								OemToAnsi(STR0033 ) + " " + ORHK:GetValue("RHK_CODFOR") + " / " + ; //"Fornecedor: "
								OemToAnsi(STR0034) + " " + ORHK:GetValue("RHK_TPPLAN") + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + ORHK:GetValue("RHK_PLANO") )//"Plano"
		aAdd( aProcessoLog, Space(6)  + STR0031 + ; //"Titular - Plano Devido  : "
								OemToAnsi(STR0033 ) + " " + SJX->JX_CODFORN + " / " + ;//"Fornecedor: "
								OemToAnsi(STR0034) + " " + SJX->JX_TPPLANO + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + SJX->JX_PLANO )//"Plano"

		SJX->(dbSkip())
	EndDo

	//atualiza linhas antigas para não vigentes
	For nI := 1 To oRHK:GetQtdLine()
		lInativo := .F.
		oRHK:GoLine(nI)
		If !oRHK:IsUpdated() .And. !oRHK:IsInserted()
			If Empty(oRHK:GetValue("RHK_PERFIM")) .Or. oRHK:GetValue("RHK_PERFIM") > cPerAnt
				If  oRHK:GetValue("RHK_PERINI") >= cPer
					oRHK:DeleteLine()
				Else
					oRHK:LoadValue("RHK_PERFIM",cPerAnt)
				EndIf
				aAdd( aProcessoLog, Space(6)  + STR0032 + ; //"Titular - Plano Inativado  : "
						OemToAnsi(STR0033) + " " + ORHK:GetValue("RHK_CODFOR") + " / " + ;//"Fornecedor: "
						OemToAnsi(STR0034) + " " + ORHK:GetValue("RHK_TPPLAN") + " / " +;//"Tipo Plano: "
						OemToAnsi(STR0035) + " " + ORHK:GetValue("RHK_PLANO") )//"Plano"
				lInativo := .T.
			EndIf
		EndIf

		If !lInativo
			If !IsBlind()
				oProcess:IncRegua2(STR0048)//"Atualizando Dependente"
			EndIf
			//Atualiza Plano Saude/Odontologico Dependente
			lRet1 := M027AtuRHL(cPer,cPerant,oModel,oRHK,aProcessoLog)
			If !IsBlind()
				oProcess:IncRegua2(STR0049)//"Atualizando Agregado"
			EndIf
			//Atualiza Plano Saude/Odontologico Agregado
			lRet2 := M027AtuRHM(cPer,cPerant,oModel,oRHK,aProcessoLog)
		Else
			//inativa dependentes e agregados para o plano atual, ja que o do titular foi inativado
			Inativa(cPer,cPerant,oModel,oRHK,aProcessoLog)
		EndIf

		If !lRet1 .Or. !lRet2
			lRet := .F.
		EndIf
	Next nI


	//grava dados na RHK e no Historico
	If lRet
		If oModel:VldData()
			oModel:CommitData()
			lRet := .T.
		Else
			aErro := oModel:GetErrorMessage()
			aAdd( aProcessoLog, Space(6)  +	STR0039 + ' [' + Alltrim(AllToChar( aErro[1] ) ) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[2]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[3]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[4]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[5]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[6]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[7]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +	 ' [' + Alltrim(AllToChar( aErro[8]  )) + ']')// "Mensagem do erro: "
			aAdd( aProcessoLog, Space(6)  +  ' [' + Alltrim(AllToChar( aErro[9]  )) + ']')// "Mensagem do erro: "

			lRet := .F.
		EndIf
	Endif
EndIf

Return lRet

Static Function Inativa(cPer,cPerant,oModel,oRHK,aProcessoLog)
Local nI
Local oRHL := oModel:GetModel("GPEA001_MRHL")
Local oRHM := oModel:GetModel("GPEA001_MRHM")

For nI := 1 To oRHL:GetQtdLine()
	oRHL:GoLine(nI)
	If !Empty(oRHL:GetValue("RHL_CODIGO")) .And. (oRHL:GetValue("RHL_TPCALC") <> '1' .Or. MV_PAR08 == 1)
		If Empty(oRHL:GetValue("RHL_PERFIM")) .Or. oRHL:GetValue("RHL_PERFIM") > cPerAnt
			If  oRHL:GetValue("RHL_PERINI") >= cPer
				oRHL:DeleteLine()
			Else
				oRHL:LoadValue("RHL_PERFIM",cPerAnt)
			EndIf
			aAdd( aProcessoLog, Space(12)  + STR0038 + oRHL:GetValue("RHL_NOME") + ;//"Dependente - Plano Inativado  : "
					OemToAnsi(STR0033) + " " + oRHL:GetValue("RHL_CODFOR") + " / " + ;//"Fornecedor: "
					OemToAnsi(STR0034) + " " + oRHL:GetValue("RHL_TPPLAN") + " / " +;//"Tipo Plano: "
					OemToAnsi(STR0035) + " " + oRHL:GetValue("RHL_PLANO") )//"Plano"

		EndIf
	EndIf
Next nI

For nI := 1 To oRHM:GetQtdLine()
	oRHM:GoLine(nI)
	If !Empty(oRHM:GetValue("RHM_CODIGO")) .And. (oRHM:GetValue("RHM_TPCALC") <> '1' .Or. MV_PAR08 == 1)
		If Empty(oRHM:GetValue("RHM_PERFIM")) .Or. oRHM:GetValue("RHM_PERFIM") > cPerAnt
			If  oRHM:GetValue("RHM_PERINI") >= cPer
				oRHM:DeleteLine()
			Else
				oRHM:LoadValue("RHM_PERFIM",cPerAnt)
			EndIf

			aAdd( aRecRHM, oRHM:GetDataId() )

			aAdd( aProcessoLog, Space(12)  + STR0042 + oRHM:GetValue("RHM_NOME") + ;//"Dependente - Plano Inativado  : "
					OemToAnsi(STR0033) + " " + oRHM:GetValue("RHM_CODFOR") + " / " + ;//"Fornecedor: "
					OemToAnsi(STR0034) + " " + oRHM:GetValue("RHM_TPPLAN") + " / " +;//"Tipo Plano: "
					OemToAnsi(STR0035) + " " + oRHM:GetValue("RHM_PLANO") )//"Plano"

		EndIf
	EndIf
Next nI


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027AtuRHL    ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano	RHL				 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027AtuRHL(cPer,cPerant,oModel,oRHK,aProcessoLog)
Local lRet		:= .T.
Local nI		:= 1
Local cCodPl	:= Padr(Alltrim((cAliasMark)->LY_CODIGO),TAMSX3("L0_CODIGO")[1])
Local oRHL

oRHL := oModel:GetModel("GPEA001_MRHL")

dbSelectArea("SL0")
SL0->(dbSetOrder(1))

dbSelectArea("SRB")
SRB->(dbSetOrder(1))

If SRB->(dbSeek((cAliasMark)->RA_FILIAL+(cAliasMark)->RA_MAT))
	While !SRB->(Eof()) .And. SRB->(RB_FILIAL+RB_MAT) == ((cAliasMark)->RA_FILIAL+(cAliasMark)->RA_MAT)
		If SRB->RB_PLSAUDE <> '2' .AND. SRB->RB_GRAUPAR <> 'O' //1=quer plano;2=nao quer plano##O=Agregado/Outros
			If SL0->(dbSeek(xFilial("SL0", (cAliasMark)->RA_FILIAL)+cCodPl+oRHK:GetValue("RHK_TPFORN")+oRHK:GetValue("RHK_CODFOR")))
				While !SL0->(Eof()) .And. SL0->(L0_FILIAL+L0_CODIGO+ L0_TPFORN+L0_CODFORN) == xFilial("SL0", (cAliasMark)->RA_FILIAL)+cCodPl+oRHK:GetValue("RHK_TPFORN")+oRHK:GetValue("RHK_CODFOR")
					If !oRHL:SeekLine({{"RHL_FILIAL",(cAliasMark)->RA_FILIAL},{"RHL_MAT",(cAliasMark)->RA_MAT},{"RHL_CODIGO",SRB->RB_COD},{"RHL_TPFORN",SL0->L0_TPFORN},{"RHL_CODFOR",SL0->L0_CODFORN} ,{"RHL_TPPLAN",SL0->L0_TPPLANO},{"RHL_PLANO",SL0->L0_PLANO}})
						If oRHL:GetQtdLine() > 1 .or. !Empty(oRHL:GETValue("RHL_PLANO"))
							oRHL:addLine()
						EndIf
						oRHL:SetValue("RHL_FILIAL",(cAliasMark)->RA_FILIAL)
						//oRHL:SetValue("RHL_MAT",(cAliasMark)->RA_MAT)
						oRHL:SetValue("RHL_CODFOR",SL0->L0_CODFORN)
						oRHL:SetValue("RHL_CODIGO",SRB->RB_COD)
					EndIf
					//So atualiza dependente se o tipo de calulo do for branco ou automatico
					If oRHL:GetValue("RHL_TPCALC") <> "1" .Or. oRHL:IsInserted() .Or.  MV_PAR08 == 1
						//oRHL:SetValue("RHL_TPFORN",SL0->L0_TPFORN)
						oRHL:SetValue("RHL_TPPLAN",SL0->L0_TPPLANO)
						oRHL:SetValue("RHL_PLANO",SL0->L0_PLANO)
						If SL0->L0_PERINI > cPer
							oRHL:SetValue("RHL_PERINI",SL0->L0_PERINI)
						Else
							oRHL:SetValue("RHL_PERINI",cPer)
						EndIf
						If SL0->L0_PERFIM < cPer .and. !Empty(SL0->L0_PERFIM)
							oRHL:SetValue("RHL_PERFIM",cPer)
						Else
							oRHL:SetValue("RHL_PERFIM",SL0->L0_PERFIM)
						EndIf
						oRHL:LoadValue("RHL_TPCALC","2")
					EndIf

					aAdd( aProcessoLog, Space(12)  + STR0036 + SRB->RB_NOME +; //"Dependente - Plano Atual  : "
								OemToAnsi(STR0033 ) + " " + oRHL:GetValue("RHL_CODFOR") + " / " + ;//"Fornecedor: "
								OemToAnsi(STR0034) + " " + oRHL:GetValue("RHL_TPPLAN") + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + oRHL:GetValue("RHL_PLANO") )//"Plano"
					aAdd( aProcessoLog, Space(12)  + STR0037 + SRB->RB_NOME + ;//"Dependente - Plano Devido  : "
								OemToAnsi(STR0033 ) + " " + SL0->L0_CODFORN + " / " + ;//"Fornecedor: "
								OemToAnsi(STR0034) + " " + SL0->L0_TPPLANO + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + SL0->L0_PLANO )//"Plano"

				SL0->(dbSkip())
				EndDo
			EndIf
		EndIf
		SRB->(dbSkip())
	EndDo
	//atualiza linhas antigas para não vigentes desde que nao seja "informada"
	For nI := 1 To oRHL:GetQtdLine()
		oRHL:GoLine(nI)
		If !oRHL:IsUpdated() .And. !oRHL:IsInserted() .And. oRHL:GetValue("RHL_TPCALC") <> '1'
			If Empty(oRHL:GetValue("RHL_PERFIM")) .Or. oRHL:GetValue("RHL_PERFIM") > cPerAnt
				If  oRHL:GetValue("RHL_PERINI") >= cPer
					oRHL:DeleteLine()
				Else
					oRHL:LoadValue("RHL_PERFIM",cPerAnt)
				EndIf
				aAdd( aProcessoLog, Space(12)  + STR0038 + oRHL:GetValue("RHL_NOME") + ;//"Dependente - Plano Inativado  : "
						OemToAnsi(STR0033) + " " + oRHL:GetValue("RHL_CODFOR") + " / " + ;//"Fornecedor: "
						OemToAnsi(STR0034) + " " + oRHL:GetValue("RHL_TPPLAN") + " / " +;//"Tipo Plano: "
						OemToAnsi(STR0035) + " " + oRHL:GetValue("RHL_PLANO") )//"Plano"

			EndIf
		EndIf
	Next nI

EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M027AtuRHM    ³ Autor ³ Flavio S. Correa    ³ Data ³ 13/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  - Gravação Plano	RHM				 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M027AtuRHM(cPer,cPerant,oModel,oRHK,aProcessoLog)
Local lRet		:= .T.
Local nI		:= 1
Local cCodPl	:= padr(Alltrim((cAliasMark)->LY_CODIGO),TAMSX3("LE_CODIGO")[1])
Local oRHM
Local cCod  	:= ""
Local cNome  	:= ""
Local cDt  		:= ""
Local cCpf  	:= ""

oRHM := oModel:GetModel("GPEA001_MRHM")
For nI := 1 To Len(aRecRHM)
	RHM->( dbGoTo(aRecRHM[nI]) )
	cCod 	:= RHM->RHM_CODIGO
	cNome  	:= RHM->RHM_NOME
	cDt  	:= RHM->RHM_DTNASC
	cCpf  	:= RHM->RHM_CPF

	//So atualiza agregado se o tipo de calulo do for branco ou automatico
	If (RHM->RHM_TPCALC <> "1" .Or. MV_PAR08 == 1) .and. !Empty(cNome)

		//verifica se existe o plano na SLE e atualiza RHM
		dbSelectArea("SLE")
		SLE->(dbSetOrder(1))
		If SLE->(dbSeek(xFilial("SLE", (cAliasMark)->RA_FILIAL)+cCodPl+oRHK:GetValue("RHK_TPFORN")+oRHK:GetValue("RHK_CODFOR")))
			While !SLE->(Eof()) .And. SLE->(LE_FILIAL+LE_CODIGO+LE_TPFORN+LE_CODFORN) == xFilial("SLE",(cAliasMark)->RA_FILIAL)+cCodPl+oRHK:GetValue("RHK_TPFORN")+oRHK:GetValue("RHK_CODFOR")
				If !oRHM:SeekLine({{"RHM_FILIAL",(cAliasMark)->RA_FILIAL},{"RHM_MAT",(cAliasMark)->RA_MAT},{"RHM_CODIGO",RHM->RHM_CODIGO},{"RHM_TPFORN",SLE->LE_TPFORN},{"RHM_CODFOR",SLE->LE_CODFORN} ,{"RHM_TPPLAN",SLE->LE_TPPLANO},{"RHM_PLANO",SLE->LE_PLANO}})
					If oRHM:GetQtdLine() > 1
						oRHM:addLine()
					EndIf
					oRHM:SetValue("RHM_FILIAL",(cAliasMark)->RA_FILIAL)
					//oRHM:SetValue("RHM_MAT",(cAliasMark)->RA_MAT)
					oRHM:SetValue("RHM_CODFOR",SLE->LE_CODFORN)
					oRHM:SetValue("RHM_CODIGO",RHM->RHM_CODIGO)
				EndIf
				//oRHM:SetValue("RHM_TPFORN",SLE->LE_TPFORN)
				oRHM:SetValue("RHM_TPPLAN",SLE->LE_TPPLANO)
				oRHM:SetValue("RHM_PLANO",SLE->LE_PLANO)
				oRHM:SetValue("RHM_NOME",cNome)
				oRHM:SetValue("RHM_DTNASC",cDt)
				If SLE->LE_PERINI > cPer
					oRHM:SetValue("RHM_PERINI",SLE->LE_PERINI)
				Else
					oRHM:SetValue("RHM_PERINI",cPer)
				EndIf
				If SLE->LE_PERFIM < cPer .and. !Empty(SLE->LE_PERFIM)
					oRHM:SetValue("RHM_PERFIM",cPer)
				Else
					oRHM:SetValue("RHM_PERFIM",SLE->LE_PERFIM)
				EndIf
				oRHM:LoadValue("RHM_TPCALC","2")

				aAdd( aProcessoLog, Space(12)  + STR0040 + oRHM:GetValue("RHM_NOME") +;//"Agregado - Plano Atual  : "
								OemToAnsi(STR0033 ) + " " + oRHM:GetValue("RHM_CODFOR") + " / " + ;//"Fornecedor: "
								OemToAnsi(STR0034) + " " + oRHM:GetValue("RHM_TPPLAN") + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + oRHM:GetValue("RHM_PLANO") )//"Plano"
				aAdd( aProcessoLog, Space(12)  + STR0041 + oRHM:GetValue("RHM_NOME") + ; //"Agregado - Plano Devido  : "
								OemToAnsi(STR0033 ) + " " + SLE->LE_CODFORN + " / " + ;//"Fornecedor: "
								OemToAnsi(STR0034) + " " + SLE->LE_TPPLANO + " / " +;//"Tipo Plano: "
								OemToAnsi(STR0035) + " " + SLE->LE_PLANO )//"Plano"

				SLE->(dbSkip())
			EndDo
		EndIf

		//atualiza linhas antigas para não vigentes
		If !oRHM:IsUpdated() .And. !oRHM:IsInserted() .And. oRHM:GetValue("RHM_TPCALC") <> '1'
			If Empty(oRHM:GetValue("RHM_PERFIM")) .Or. oRHM:GetValue("RHM_PERFIM") > cPerAnt
				If  oRHM:GetValue("RHM_PERINI") >= cPer
					oRHM:DeleteLine()
				Else
					oRHM:LoadValue("RHM_PERFIM",cPerAnt)
				EndIf
				aAdd( aProcessoLog, Space(12)  + STR0042 + oRHM:GetValue("RHM_NOME") + ;//"Agregado - Plano Inativado  : "
					OemToAnsi(STR0033 ) + " " + oRHM:GetValue("RHM_CODFOR") + " / " + ;//"Fornecedor: "
					OemToAnsi(STR0034) + " " + oRHM:GetValue("RHM_TPPLAN") + " / " +;//"Tipo Plano: "
					OemToAnsi(STR0035) + " " + oRHM:GetValue("RHM_PLANO") )//"Plano"
			EndIf
		EndIf
	EndIf
Next nI

Return lRet

Static Function fRetAlias(cFiltro, cFilProc)
Local aArea 	 := GetArea()
Local cCod		 := ""
Local cQry 		 := GetNextAlias()
Local cFilSJS	 := ""
Default cFilProc := cFilant

cFilSJS := xFilial("SJS", cFilProc)

BEGINSQL ALIAS cQry

SELECT  JS_TABELA FROM %table:SJS% SJS
Where JS_CDAGRUP = %exp:cFiltro%
and  %notDel%
AND JS_FILIAL = %exp:cFilSJS%
AND JS_SEQ > %exp:'01'%
order by JS_SEQ
EndSql

cCod := ""
While !(cQry)->(Eof())
	cCod += (cQry)->JS_TABELA + " / "

	(cQry)->(dbSkip())
EndDo
(cQry)->(dbCloseArea())


RestArea(aArea)
Return cCod

/*/{Protheus.doc} fLoadCCT
Carrega sindicatos associados a CCT
@author Leandro Drumond
@since 25/05/2022
/*/
Static Function fLoadCCT(cCodCCT, cFilSRA)
Local cRet  		:= "#%#%#%"
Local cAliasQry 	:= GetNextAlias()
Local cFilRCE       := xFilial("RCE", cFilSRA)

BeginSql alias cAliasQry
	SELECT RCE_CODIGO
	FROM %table:RCE% RCE
	WHERE RCE_CCT = %exp:cCodCCT% AND
	RCE_FILIAL = %exp:cFilRCE% AND
	RCE.%notDel%
EndSql

If !(cAliasQry)->( EOF() )
	cRet := ""
	While !(cAliasQry)->( EOF() )
		cRet += (cAliasQry)->RCE_CODIGO + "/"
		(cAliasQry)->( DbSkip() )
	EndDo
EndIf

(cAliasQry)->(DbCloseArea())

Return cRet
