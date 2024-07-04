#INCLUDE "pcor030.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR030  �Autor  � Gustavo Henrique   � Data �  25/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Chamada do relatorio de Visao Gerencial Resumida           ���
�������������������������������������������������������������������������͹��
���Uso       � Planejamento e Controle Orcamentario                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOR030( lCallPrg )

Local oReport
Local aArea		  := GetArea()
Local aAreaAKO    := {}
Local aAreaAK2TMP := {}
Local aAreaAK1TMP := {}
Local cPerg       := "PCRVIS"		// Nome do grupo de perguntas
Local lOk         := .T.

Default lCallPrg := .F.

If lCallPrg

	aAreaAKO    := AKO->(    GetArea() )
	aAreaAK1TMP := TMPAK1->( GetArea() )
	aAreaAK2TMP := TMPAK2->( GetArea() )

Else	

	Pergunte( cPerg, .T. )

	dbSelectArea("AKN")
	dbSetOrder(1)

	lOk := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)

	If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  		// 1-Verifica acesso por entidade
		lOk := .T.                        			// 2-Nao verifica o acesso por entidade
	Else
		lOk := ( PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.) # 0 ) // 0=bloqueado
		If ! lOk
			Aviso(STR0011,STR0012,{STR0013},2)//"Aten��o"###"Usuario sem acesso a esta configura��o de visao gerencial. "###"Fechar"
		EndIf
	EndIf    

EndIf
	
If lOk
	oReport := ReportDef( lCallPrg, cPerg )
	oReport:PrintDialog()
EndIf	

RestArea( aArea )  

If lCallPrg
	RestArea( aAreaAKO    )
	RestArea( aAreaAK1TMP )
	RestArea( aAreaAK2TMP )
EndIf	

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Gustavo Henrique   � Data �  25/05/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indica se esta sendo chamado da rotina de consulta ���
���          �         da visao gerencial (PCOA180)                       ���
���          � EXPC1 - Grupo de perguntas do relatorio                    ���
�������������������������������������������������������������������������͹��
���Uso       � Planejamento e Controle Orcamentario                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef( lCallPrg, cPerg )

Local cReport	:= "PCOR030" // Nome do relatorio
Local cTitulo	:= STR0001	 // Titulo do relatorio
Local cDescri	:= STR0014	 // Descricao do relatorio

Local oReport
Local oSection1        
Local oSection2

Pergunte( cPerg, .F. )
                   
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport  := TReport():New( cReport, cTitulo,cPerg, { |oReport| PCOR030Imp( oReport, lCallPrg ) }, cDescri ) // "Este relat�rio apresentara todas as contas orcamentarias da execucao da visao gerencial."
oReport:ParamReadOnly()

//������������������������������������������������������Ŀ
//� Define a 1a. secao do relatorio                      �
//��������������������������������������������������������
oSection1 := TRSection():New( oReport, STR0015, {"AKN"} )	// "Visao orcamentaria"
oSection1:SetNoFilter("AKN")

TRCell():New( oSection1, "AKN_CODIGO","AKN"    ,STR0002,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Codigo
TRCell():New( oSection1, "AKN_DESCRI","AKN"    ,STR0003,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Descricao
TRCell():New( oSection1, "dIniPer"   ,/*Alias*/,STR0004,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)	// Dt.Inicio
TRCell():New( oSection1, "dFimPer"   ,/*Alias*/,STR0005,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)	// Dt.Fim

//������������������������������������������������������Ŀ
//� Define a 2a. secao do relatorio                      �
//��������������������������������������������������������
oSection2 := TRSection():New( oSection1, STR0016, {"AKO"} )	// "Contas orcamentarias"

TRCell():New( oSection2, "AKO_CO"    ,"AKO",STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// C.O.G.
TRCell():New( oSection2, "AKO_NIVEL" ,"AKO",STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nivel
TRCell():New( oSection2, "AKO_DESCRI","AKO",STR0003,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Descricao
TRCell():New( oSection2, "AKO_CLASSE","AKO",STR0008,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)	// Tipo

Return oReport      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR030Imp �Autor�Microsiga           � Data �  05/25/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Query para impressao do relatorio de visao resumida        ���
�������������������������������������������������������������������������͹��
���Parametros� EXPO1 - Objeto TReport do relatorio                        ���
���          � EXPL1 - Indica se esta sendo chamado da rotina de consulta ���
���          �         da visao gerencial (PCOA180)                       ���
�������������������������������������������������������������������������͹��
���Uso       � Planejamento e Controle Orcamentario                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOR030Imp( oReport, lCallPrg )

local cQuery1   := "QRYAKO"
local cQuery2   := "QRYAKN"
local oSection1 := oReport:Section(1) 
local oSection2 := oReport:Section(1):Section(1)
local cCodigo
local dIniPer
local dFimPer
local nCont		:= 0

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

cCodigo   := Iif( lCallPrg, TMPAK1->AK1_CODIGO, mv_par01 )
dIniPer   := Iif( lCallPrg, TMPAK1->AK1_INIPER, mv_par03 )
dFimPer   := Iif( lCallPrg, TMPAK1->AK1_FIMPER, mv_par04 )

//�����������������������������������������������Ŀ
//�Query do relat�rio da secao 1                  �
//�������������������������������������������������
oSection1:BeginQuery()

BeginSql Alias cQuery1

	SELECT
		AKN_CODIGO, AKN_DESCRI
	FROM 
		%table:AKN% AKN
	WHERE
		AKN_FILIAL = %xfilial:AKN%  AND
		AKN_CODIGO = %exp:cCodigo% AND
		AKN.%notDel%
	ORDER BY AKN_CODIGO

EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1:EndQuery()

//�����������������������������������������������Ŀ
//�Query do relat�rio da secao 2                  �
//�������������������������������������������������
oSection2:BeginQuery()

BeginSql Alias cQuery2

	SELECT
		AKO_CO, AKO_DESCRI, AKO_NIVEL, AKO_CLASSE
	FROM 
		%table:AKO% AKO
	WHERE 
		AKO_FILIAL = %xfilial:AKO%  AND
		AKO_CODIGO = %exp:cCodigo% AND
		AKO.%notDel%
	ORDER BY AKO_CO

EndSql

oSection2:EndQuery()

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
(cQuery2)->( dbGoTop() )
(cQuery2)->( dbEval( { || nCont++ } ) )
(cQuery2)->( dbGoTop() )

oReport:SetMeter(nCont)

//������������������������������������������������������������������������Ŀ
//�Imprime a 1a. secao do relatorio                                        �
//��������������������������������������������������������������������������
oSection1:Init()
oSection1:Cell("dIniPer"):SetValue(dIniPer)
oSection1:Cell("dFimPer"):SetValue(dFimPer)
oSection1:PrintLine()
oSection1:Finish()

//������������������������������������������������������������������������Ŀ
//�Imprime a 2a. secao do relatorio                                        �
//��������������������������������������������������������������������������
oSection2:Init()

Do While ! oReport:Cancel() .And. ! (cQuery2)->( Eof() )

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf

	oSection2:PrintLine()
		
	(cQuery2)->(dbSkip())
	
EndDo

oSection2:Finish()

(cQuery1)->(dbCloseArea())
(cQuery2)->(dbCloseArea())

Return