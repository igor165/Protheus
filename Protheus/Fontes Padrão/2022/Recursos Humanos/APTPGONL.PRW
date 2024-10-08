#Include "PROTHEUS.CH"
#Include "PANELONLINE.CH"
#Include "APTPGONL.CH"
#INCLUDE "MSGRAPHI.CH"

Static aTipos := {}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APTPGONL � Autor � Ricardo Duarte Costa  � Data � 21/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ROTINA PARA EXECUCAO DOS PAINEIS DE GESTAO                 ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/08/14�TQEQ39�Incluido o fonte da 11 para a 12 e efetua-���  
���            �        �      �da a limpeza.                             ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function APTPGONL(oPGOnline)

Local cDataPesq		:= fMontaData()
Local cDataPesqF	:= cDataPesq + 6
Local cDescSem		:= ": "+Dtoc(cDataPesq)+" - "+Dtoc(cDataPesqF)
Local aToolBar		:= {}
Local nTempo		:= SuperGetMV("MV_PGORFSH", .F., 14400)//Tempo para atualizacao do painel

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || APTPGHLP("001") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ;								// ###"Processos Trabalhistas Encerrados"
	DESCR STR0001 ;								// ###"Processos Trabalhistas Encerrados"
	TYPE 2 ;
	ONLOAD "APTPG001" ;
	REFRESH nTempo ;
	DEFAULT 1 ;
	TOOLBAR aToolBar;
	NAME "APTPG001" ;
	TITLECOMBO STR0008							// ###"Filiais"
 
aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || APTPGHLP("002") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0009 ;								// ###"Processos Trabalhistas em Andamento"
	DESCR STR0009 ;								// ###"Processos Trabalhistas em Andamento"
	TYPE 2 ;
	ONLOAD "APTPG002" ;
	REFRESH nTempo ;
	DEFAULT 1 ;
	TOOLBAR aToolBar;
	NAME "APTPG002" ;
	TITLECOMBO STR0008							// ###"Filiais"

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || APTPGHLP("003") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0013 ;			  					//##"Audi�ncias na semana"
	DESCR STR0013+cDescSem ;					//##"Audi�ncias na semana"
	TYPE 2 ;
	ONLOAD "APTPG003" ;
	REFRESH nTempo ;
	DEFAULT 3	 ;
	TOOLBAR aToolBar;
	NAME "APTPG003"

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || APTPGHLP("004") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0015 ;								//##"Obrigacoes da semana"
	DESCR STR0015+cDescSem ;					//##"Obrigacoes da semana"
	TYPE 2 ;
	ONLOAD "APTPG004" ;
	REFRESH nTempo ;
	DEFAULT 2	 ;
	TOOLBAR aToolBar;
	NAME "APTPG004" ;
	TITLECOMBO STR0024							//##"Tipos de Ocorrencias"

Return	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTPG001 �Autor  �Ricardo Duarte Costa� Data �  21/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processos trabalhistas encerrados.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function APTPG001()

Local aRet	:= APTTIPO("1")

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTPG002 �Autor  �Ricardo Duarte Costa� Data �  22/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processos trabalhistas em andamento.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function APTPG002()

Local aRet	:= APTTIPO("2")

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTTIPO  �Autor  �Ricardo Duarte Costa� Data �  22/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que retorna os processos trabalhistas por tipo.     ���
���          � Encerrados ou em Andamento.                                ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function APTTIPO(cTipo)

Local aInfo		:= {}
Local aInfo2	:= {}
Local aInfoBase	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasRE0 := "QRYRE0"
Local cAliasRE02:= "QRYRE02"
Local cAliasRE03:= "QRYRE03"
Local cDescFil	:= ""
Local cFilVel	:= replicate("@", FWGETTAMFILIAL)
Local cQryWhere	:= ""
Local lTrataFil	:= .T.
Local nQtde		:= 0
Local nCausas	:= 0
Local nPagos	:= 0
Local nAPagar	:= 0
Local nDespesas := 0
Local nPosFil	:= 0
Local nx		:= 0

//-- Monta o array modelo
Aadd( aInfoBase , { If(cTipo=="1",STR0004,STR0003) , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Encerrados"##"Em andamento"
Aadd( aInfoBase , { STR0005 , Transform(0.00,"@R 999,999,999.99") , CLR_RED , } )//###"Valor das Causas"
Aadd( aInfoBase , { STR0006 , Transform(0.00,"@R 999,999,999.99") , CLR_RED , } )//###"Valores pagos"
Aadd( aInfoBase , { STR0007 , Transform(0.00,"@R 999,999,999.99") , CLR_RED , } )//###"Valores a pagar"
Aadd( aInfoBase , { STR0010 , Transform(0.00,"@R 999,999,999.99") , CLR_RED , } )//###"Despesas pagas"

//-- Define o tipo de processos trabalhistas que devem ser considerados.
If cTipo == "1"
	cQryWhere	:= "%RE0_ENCERR = '1'%"				//-- Encerrados
Else
	cQryWhere	:= "%RE0_ENCERR IN(' ','2')%"		//-- Em andamento
Endif

//-- Query que apura a quantidade de processos trabalhistas e os valores das causas
BeginSql alias cAliasRE0
	SELECT RE0_FILIAL, SUM(RE0_VLRCSA) AS VLRCSA, COUNT(RE0_FILIAL) AS QTDPROC
	FROM %table:RE0% RE0
	WHERE RE0.%notDel% AND %exp:cQryWhere%
	GROUP BY RE0_FILIAL
	ORDER BY RE0_FILIAL
EndSql

//-- Apura os totais por filial
lTrataFil	:= !Empty((cAliasRE0)->RE0_FILIAL)
Dbselectarea(cAliasRE0)
While !(cAliasRE0)->(eof())
	//-- Carrega a descricao da filial
	If lTrataFil
		If cFilVel <> (cAliasRE0)->RE0_FILIAL
			If SM0->(dbseek(cEmpAnt+(cAliasRE0)->RE0_FILIAL))
				cDescFil	:= (cAliasRE0)->RE0_FILIAL + " - " + SM0->M0_FILIAL
			Else
				cDescFil	:= STR0023			//##"Filial Inexistente"
			Endif
			cFilVel	:= (cAliasRE0)->RE0_FILIAL
			aInfo2	:= aClone(aInfoBase)
		Endif
	Else
		cDescFil:= (cAliasRE0)->RE0_FILIAL+STR0011 		//##"Total da Empresa"
		cFilVel	:= (cAliasRE0)->RE0_FILIAL
		aInfo2	:= aClone(aInfoBase)
	Endif
	//-- Carrega a quantidade de processos e o valor das causas.
	While !(cAliasRE0)->(eof()) .And. cFilVel == (cAliasRE0)->RE0_FILIAL
		aInfo2[1,2]	:= Transform((cAliasRE0)->QTDPROC,"@R 99,999")
		nQtde		+= (cAliasRE0)->QTDPROC
		aInfo2[2,2]	:= Transform((cAliasRE0)->VLRCSA,"@R 999,999,999.99")
		nCausas		+= (cAliasRE0)->VLRCSA
		(cAliasRE0)->(dbskip())
	Enddo
	Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
Enddo

//-- Query que apura os valores pagos e a pagar de sentencas por processos trabalhistas
BeginSql alias cAliasRE02
	SELECT RE0_FILIAL, 
	SUM(CASE WHEN REP.REP_INTEGR = '1' THEN REP.REP_VALOR ELSE 0 END) AS VLRPGS, 
	SUM(CASE WHEN REP.REP_INTEGR IN(' ','2') THEN REP.REP_VALOR ELSE 0 END) AS VLRAPG
	FROM %table:RE0% RE0
	INNER JOIN %table:REP% REP ON RE0.RE0_FILIAL = REP.REP_FILIAL AND RE0.RE0_NUM = REP.REP_PRONUM
	WHERE RE0.%notDel% AND REP.%notDel% AND %exp:cQryWhere% 
	GROUP BY RE0_FILIAL
	ORDER BY RE0_FILIAL
EndSql

cFilVel	:= replicate("@", FWGETTAMFILIAL)
Dbselectarea(cAliasRE02)
While !(cAliasRE02)->(eof())
	nPosFil	:= aScan(aInfo,{|X| X[1] = (cAliasRE02)->RE0_FILIAL})
	//-- Carrega a descricao e dados da filial que nao existe ainda
	If nPosFil == 0
		If lTrataFil
			If cFilVel <> (cAliasRE02)->RE0_FILIAL
				If SM0->(dbseek(cEmpAnt+(cAliasRE00)->RE0_FILIAL))
					cDescFil	:= (cAliasRE02)->RE0_FILIAL + " - " + SM0->M0_FILIAL
				Else
					cDescFil	:= STR0023			//##"Filial Inexistente"
				Endif
			Endif
		Else
			cDescFil:= (cAliasRE02)->RE0_FILIAL+STR0011 		//##"Total da Empresa"
		Endif
		cFilVel	:= (cAliasRE02)->RE0_FILIAL
		aInfo2	:= aClone(aInfoBase)
		Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
		nPosFil	:= Len(aInfo)
	Else
		cFilVel	:= (cAliasRE02)->RE0_FILIAL
	Endif
	//-- Carrega os valores pagos e a pagar de sentencas por processo trabalhista
	aInfo[nPosFil,2,3,2]	:= Transform((cAliasRE02)->VLRPGS,"@R 999,999,999.99")
	nPagos					+= (cAliasRE02)->VLRPGS
	aInfo[nPosFil,2,4,2]	:= Transform((cAliasRE02)->VLRAPG,"@R 999,999,999.99")
	nAPagar					+= (cAliasRE02)->VLRAPG
	(cAliasRE02)->(dbskip())
Enddo

//-- Despesas dos processos
BeginSql alias cAliasRE03
	SELECT RE0_FILIAL, SUM(RC1_VALOR) AS VLRDESP
	FROM %table:RE0% RE0
	INNER JOIN %table:RC1% RC1 ON RE0.RE0_FILIAL = RC1.RC1_FILIAL AND RE0.RE0_NUM = RC1.RC1_PRONUM 
	WHERE RE0.%notDel% AND RC1.%notDel% AND %exp:cQryWhere% AND RC1.RC1_INTEGR = '1' 
	GROUP BY RE0_FILIAL
	ORDER BY RE0_FILIAL
EndSql

cFilVel	:= replicate("@", FWGETTAMFILIAL)
Dbselectarea(cAliasRE03)
While !(cAliasRE03)->(eof())
	nPosFil	:= aScan(aInfo,{|X| X[1] = (cAliasRE03)->RE0_FILIAL})
	//-- Carrega a descricao e dados da filial que nao existe ainda
	If nPosFil == 0
		If lTrataFil
			If cFilVel <> (cAliasRE03)->RE0_FILIAL
				If SM0->(dbseek(cEmpAnt+(cAliasRE00)->RE0_FILIAL))
					cDescFil	:= (cAliasRE03)->RE0_FILIAL + " - " + SM0->M0_FILIAL
				Else
					cDescFil	:= STR0023			//##"Filial Inexistente"
				Endif
			Endif
		Else
			cDescFil:= (cAliasRE03)->RE0_FILIAL+STR0011 		//##"Total da Empresa"
		Endif
		cFilVel	:= (cAliasRE03)->RE0_FILIAL
		aInfo2	:= aClone(aInfoBase)
		Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
		nPosFil	:= Len(aInfo)
	Else
		cFilVel	:= (cAliasRE03)->RE0_FILIAL
	Endif
	//-- Carrega os valores pagos a titulo de despesas do por processo trabalhista
	aInfo[nPosFil,2,5,2]	:= Transform((cAliasRE03)->VLRDESP,"@R 999,999,999.99")
	nDespesas				+= (cAliasRE03)->VLRDESP
	(cAliasRE03)->(dbskip())
Enddo

//-- Total Geral da Empresa
If lTrataFil .Or. Len(aInfo) == 0
	aInfo2	:= aClone(aInfoBase)
	//-- Tratamento para quando nao houver informacao a ser demonstrada ou
	//-- quando houver totalizacao de varias filiais.
	aInfo2[1,2]	:= Transform(nQtde  ,"@R 99,999")
	aInfo2[2,2]	:= Transform(nCausas,"@R 999,999,999.99")
	aInfo2[3,2]	:= Transform(nPagos ,"@R 999,999,999.99")
	aInfo2[4,2]	:= Transform(nAPagar,"@R 999,999,999.99")
	aInfo2[5,2]	:= Transform(nDespesas,"@R 999,999,999.99")
	Aadd( aInfo, { STR0011 , aClone(aInfo2) } )	//##"Total da Empresa"
Endif

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasRE0)->(dbclosearea())
(cAliasRE02)->(dbclosearea())
(cAliasRE03)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTPG003 �Autor  �Ricardo Duarte Costa� Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Painel indicativo dos afastamentos no mes.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function APTPG003()

Local aInfo		:= {}
Local aAux		:= {}
Local aFilial	:= {}
Local aValores	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasREA := "QRYREA"
Local cDataPesq	:= fMontaData()
Local cDataPesqF:= Dtos(cDataPesq + 6)
Local cDescFil	:= ""
Local nPosAf	:= 0
Local nx		:= 0
Local ny		:= 0
//-- Ajusta o tipo da variavel
cDataPesq		:= Dtos(cDataPesq)

//-- Query que apura a quantidade de afastamentos no mes corrente.
BeginSql alias cAliasREA
	SELECT REA_DATA, COUNT(REA_DATA) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:REA% REA ON RE0.RE0_FILIAL = REA.REA_FILIAL AND RE0.RE0_NUM = REA.REA_PRONUM 
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND REA_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY REA_DATA
	ORDER BY REA_DATA
EndSql

//-- Apura os totais dos afastamentos por filial
Dbselectarea(cAliasREA)
While !(cAliasREA)->(eof())
	nPosData	:= Ascan(aAux,{|X| X[1] == Dtoc(Stod((cAliasREA)->REA_DATA))})
	If nPosData > 0
		aAux[nPosData,3] += ( (cAliasREA)->QTDE )
	Else
		Aadd( aAux,{Dtoc(Stod((cAliasREA)->REA_DATA)),(cAliasREA)->QTDE})
	Endif
	//-- Monta o array do eixo X com os tipos de afastamento
	nPosTipo	:= Ascan(aTipos,{|X| X == Dtoc(Stod((cAliasREA)->REA_DATA))})
	If nPosTipo == 0
		Aadd(aTipos,Dtoc(Stod((cAliasREA)->REA_DATA)))
	Endif
	(cAliasREA)->(dbskip())
Enddo

//-- Monta o array de indicadores -- Empresas
cDescFil	:= SM0->M0_NOME
Aadd(aFilial,cDescFil)

//-- Verifica o conteudo dos tipos de afastamentos
If Len(aTipos) == 0
	Aadd(aTipos,STR0012)			//##"N�o exitem audi�ncias no per�odo!"
Endif

//-- Cria matriz para carregar as informacoes de afastamento
aValores	:= Array(Len(aTipos),Len(aFilial))
//-- Preenche os valores por tipo de afastamento
For nx := 1 to Len(aTipos)
	For ny := 1 to Len(aFilial)
		nPosAf	:= Ascan(aAux,{|X| X[1] == aTipos[nx]})
		If nPosAf > 0
			aValores[nx,ny]	:= aAux[nPosAf,2]
		Else
			aValores[nx,ny]	:= 0
		Endif
	Next ny
Next nx

//-- Salva as variaveis no server de paineis
PutServerVar("APTPG003",{aTipos})

//-- Monta as informacoes do painel
aInfo	:= { GRP_BAR , "{ || fExpLeg() }" , aFilial , aTipos , aValores }

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasREA)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fExpLeg  �Autor  �Ricardo Duarte Costa� Data �  26/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Explode a legenda indicando as datas que foram consideradas���
���          � na montagem do grafico de barras                           ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fExpLeg()

Local nx	:= 0
Local cRet	:= STR0014			//##"Datas consideradas: "
Local aGetVar := {}

//-- Restaura as variaveis no server de paineis
aGetVar := GetServerVar("APTPG003")
If !Empty(aGetVar)
	aTipos := aGetVar[1]
EndIf

For nx := 1 to Len(aTipos)
	cRet	+= CRLF+aTipos[nx]
Next nx

MsgInfo(cRet,STR0001) 			//##"Informa��o"

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTPG004 �Autor  �Ricardo Duarte Costa� Data �  26/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Painel indicativo das obrigacoes da semana.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function APTPG004()

Local aInfo		:= {}
Local aTabela	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cDataPesq	:= fMontaData()
Local cDataPesqF:= Dtos(cDataPesq + 6)
Local nx		:= 0
Local ny		:= 0
Local nw		:= 0

Private aAux		:= {}
Private aAux2		:= {}
Private aFiliais	:= {}
//Private aTipos		:= {}
Private aValores	:= {}
Private cAliasQry 	:= "QRYAPT"
Private cDescFil	:= ""
Private cTipo		:= ""
Private nPosOcor	:= 0
Private lTrataFil	:= .T.

//-- Ajusta o tipo da variavel
cDataPesq		:= Dtos(cDataPesq)
aTipos			:= {}

//-- Query que apura a quantidade de audiencia do mes
cTipo			:= STR0017 					// "Audiencias"
BeginSql alias cAliasQry
	SELECT REA.REA_FILIAL FILIAL, REA.REA_DATA DATAOCOR, %exp:cTipo% TIPO, COUNT(REA.REA_DATA) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:REA% REA ON RE0.RE0_FILIAL = REA.REA_FILIAL AND RE0.RE0_NUM = REA.REA_PRONUM 
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND REA_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY REA.REA_FILIAL, REA.REA_DATA
	ORDER BY REA.REA_FILIAL, REA.REA_DATA
EndSql

//-- Apura os totais por filial
lTrataFil	:= !Empty((cAliasQry)->FILIAL)

//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Query que apura a quantidade de ocorrencias do mes
cTipo			:= STR0016					// "Ocorrencias"
BeginSql alias cAliasQry
	SELECT REO.REO_FILIAL FILIAL, REO.REO_DATA DATAOCOR, %exp:cTipo% TIPO, COUNT(REO.REO_DATA) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:REO% REO ON RE0.RE0_FILIAL = REO.REO_FILIAL AND RE0.RE0_NUM = REO.REO_PRONUM
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND REO_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY REO.REO_FILIAL, REO.REO_DATA
	ORDER BY REO.REO_FILIAL, REO.REO_DATA
EndSql
//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Query que apura a quantidade de sentencas do mes
cTipo			:= STR0018 					// "Sentenca"
BeginSql alias cAliasQry
	SELECT RES.RES_FILIAL FILIAL, RES.RES_JULGAM DATAOCOR, %exp:cTipo% TIPO, COUNT(RES.RES_JULGAM) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:RES% RES ON RE0.RE0_FILIAL = RES.RES_FILIAL AND RE0.RE0_NUM = RES.RES_PRONUM
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND RES_JULGAM BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY RES.RES_FILIAL, RES.RES_JULGAM
	ORDER BY RES.RES_FILIAL, RES.RES_JULGAM
EndSql
//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Query que apura a quantidade de recursos do mes
cTipo			:= STR0019 					// "Recurso"
BeginSql alias cAliasQry
	SELECT REM.REM_FILIAL FILIAL, REM.REM_DATA DATAOCOR, %exp:cTipo% TIPO, COUNT(REM.REM_DATA) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:REM% REM ON RE0.RE0_FILIAL = REM.REM_FILIAL AND RE0.RE0_NUM = REM.REM_PRONUM
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND REM_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY REM.REM_FILIAL, REM.REM_DATA
	ORDER BY REM.REM_FILIAL, REM.REM_DATA
EndSql
//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Query que apura a quantidade de pericias do mes
cTipo			:= STR0020 					// "Pericia"
BeginSql alias cAliasQry
	SELECT REH.REH_FILIAL FILIAL, REH.REH_DTPERI DATAOCOR, %exp:cTipo% TIPO, COUNT(REH.REH_DTPERI) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:REH% REH ON RE0.RE0_FILIAL = REH.REH_FILIAL AND RE0.RE0_NUM = REH.REH_PRONUM
	WHERE RE0.RE0_ENCERR IN(' ','2')
	AND REH_DTPERI BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY REH.REH_FILIAL, REH.REH_DTPERI
	ORDER BY REH.REH_FILIAL, REH.REH_DTPERI
EndSql
//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Query que apura a quantidade de despesas do mes
cTipo			:= STR0021 					// "Despesa"
BeginSql alias cAliasQry
	SELECT RC1.RC1_FILIAL FILIAL, RC1.RC1_VENCTO DATAOCOR, %exp:cTipo% TIPO, COUNT(RC1.RC1_VENCTO) AS QTDE
	FROM %table:RE0% RE0
	INNER JOIN %table:RC1% RC1 ON RE0.RE0_FILIAL = RC1.RC1_FILIAL AND RE0.RE0_NUM = RC1.RC1_PRONUM
	WHERE RE0.RE0_ENCERR IN(' ','2') AND RC1.RC1_CODTIT = "APT"
	AND RC1_VENCTO BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY RC1.RC1_FILIAL, RC1.RC1_VENCTO
	ORDER BY RC1.RC1_FILIAL, RC1.RC1_VENCTO
EndSql
//-- Carrega os arrays para utilizacao nos graficos.
fDadosGraf()
(cAliasQry)->(dbclosearea())

//-- Verifica o preenchimento dos arrays quando nao existir informacao a ser mostrada
If Len(aTipos) == 0
	Aadd(aTipos,STR0022)		//##"N�o exitem ocorr�ncias no per�odo!"
	Aadd(aValores,1)
	Aadd(aFiliais,space(20))
	Aadd( aAux,{Space(FwGetTamFilial),"00/00/0000",STR0022,0})	//##"N�o exitem ocorr�ncias no per�odo!"
Endif

//-- Monta a tabela com as informacoes individuais de cada filial por tipo de afastamento
For ny := 1 to Len(aTipos)
	aAux2	:= {}
	For nw := 1 to Len(aAux)
		If aAux[nw,3] == aTipos[ny]
			nx	:= Ascan(aFiliais,{|Z| Substr(Z,1,FWGETTAMFILIAL) == aAux[nw,1]})
			Aadd(aAux2,{aFiliais[nx],Dtoc(Stod(aAux[nw,2])),Transform(aAux[nw,4],"@R 99,999,999")})
		Endif
	next nw
	Aadd(aTabela,{aTipos[ny],{STR0025,STR0026,STR0027},aClone(aAux2)})	//##"Filial/Empresa"##"Data de ocorr�ncia"## "Quantidade"
Next ny

//-- Monta as informacoes do painel
aInfo	:= { GRP_PIE ,;
				{STR0024, NIL , aTipos , aValores },;					//##"Tipos de Ocorrencias"
				{STR0008, NIL , aTabela };								//##"Filiais"
			}

//-- Retorna para a area corrente.
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fDadosGraf�Autor  �Ricardo Duarte Costa� Data �  26/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza os arrays com as informacoes para o grafico       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fDadosGraf()

Dbselectarea(cAliasQry)
While !(cAliasQry)->(eof())
	//-- Monta a tabela indicadora de Filial X Afastamento X Dias X Numero de funcionarios
	nPosOcor	:= Ascan(aAux,{|X| X[1] == (cAliasQry)->FILIAL .And. X[2] == (cAliasQry)->DATAOCOR .And. X[3] == (cAliasQry)->TIPO})
	If nPosOcor > 0
		aAux[nPosOcor,4] += (cAliasQry)->QTDE
	Else
		Aadd( aAux,{(cAliasQry)->FILIAL,(cAliasQry)->DATAOCOR,(cAliasQry)->TIPO,(cAliasQry)->QTDE})
	Endif
	//-- Monta o array de indicadores -- Filiais
	nPosFil		:= Ascan(aFiliais,{|X| X = (cAliasQry)->FILIAL})
	If nPosFil == 0
		If lTrataFil
			If SM0->(dbseek(cEmpAnt+(cAliasQry)->FILIAL))
				cDescFil	:= (cAliasQry)->FILIAL + " - " + SM0->M0_FILIAL
			Else
				cDescFil	:= STR0023			//##"Filial Inexistente"
			Endif
			Aadd(aFiliais,cDescFil)
		Else
			cDescFil:= (cAliasQry)->FILIAL+SM0->M0_NOME
			Aadd(aFiliais,cDescFil)
		Endif
	Endif
	//-- Monta o indicador do total de afastamentos da empresa
	nPosTipo	:= Ascan(aTipos,{|X| X = (cAliasQry)->TIPO})
	If nPosTipo > 0
		aValores[nPosTipo] += (cAliasQry)->QTDE
	Else
		Aadd(aTipos,(cAliasQry)->TIPO)
		Aadd(aValores,(cAliasQry)->QTDE)
	Endif
	(cAliasQry)->(dbskip())
Enddo

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fmontadata�Autor  �Ricardo Duarte Costa� Data �  22/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta a data do inicio da semana corrente.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fMontaData()

Local nDiasSem	:= Dow(dDataBase)
Local dDataRet	:= dDataBase

If nDiasSem <> 2
	dDataRet	:= dDataBase - (nDiasSem - 2)
Endif

Return(dDataRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � APTPGHLP �Autor  �Ricardo Duarte Costa� Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de Help para os paineis de gestao.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function APTPGHLP(cPainel)


If cPainel == '001'

	MsgInfo(;
	STR0029+CRLF+;	//##"- Encerrados: Nesta quantidade est�o considerados todos os processos encerrados."
	STR0030+CRLF+;	//##"- Valor da causa: Neste valor est�o considerados os valores iniciais das causas."
	STR0031+CRLF+;	//##"- Valores Pagos: Neste valor est�o consideradas todas as senten�as que foram integradas/geradas para pagamento pelo m�dulo de Gest�o de Pessoal."
	STR0032+CRLF+;	//##"- Valores a Pagar: Neste valor est�o consideradas todas as senten�as que t�m o pagamento programado, por�m ainda n�o foram efetuados."
	STR0033+CRLF;	//##"- Despesas Pagas: Neste valor est�o considerados todos os pagamentos efetuados diretamente no financeiro pela pastas de Despesas/Pagamentos"
	,STR0028)		//##"Esclarecimento"

ElseIf cPainel == '002'

	MsgInfo(;
	STR0034+CRLF+;	//##"- Em Andamento: Nesta quantidade est�o considerados todos os processos em andamento.
	STR0030+CRLF+;	//##"- Valor da causa: Neste valor est�o considerados os valores iniciais das causas."
	STR0031+CRLF+;	//##"- Valores Pagos: Neste valor est�o consideradas todas as senten�as que foram integradas/geradas para pagamento pelo m�dulo de Gest�o de Pessoal."
	STR0032+CRLF+;	//##"- Valores a Pagar: Neste valor est�o consideradas todas as senten�as que t�m o pagamento programado, por�m ainda n�o foram efetuados."
	STR0033+CRLF;	//##"- Despesas Pagas: Neste valor est�o considerados todos os pagamentos efetuados diretamente no financeiro pela pastas de Despesas/Pagamentos"
	,STR0028)		//##"Esclarecimento"

ElseIf cPainel == '003'

	MsgInfo(;
	STR0035+CRLF+;	//##"- Este indicador ser� demonstrado na forma de um gr�fico de barras. Ser�o consideradas todas as audi�ncias independentemente da filial a que estiverem vinculadas."
	STR0036+CRLF+;	//##"- Na legenda ser�o apresentados os dias da semana que t�m audi�ncia programada."
	STR0037+CRLF;	//##"- No eixo Y da barra ser� apresentada a quantidade de audi�ncias programadas em cada um dos dias."
	,STR0028)		//##"Esclarecimento"

ElseIf cPainel == '004'

	MsgInfo(;
	STR0038+CRLF+;	//##"- Este indicador ser� demonstrado na forma de um gr�fico de setor (pizza) onde os setores representar�o a quantidade ocorr�ncias de cada tipo de obriga��o poss�vel dentro do m�dulo de Processos Trabalhistas. S�o elas: Ocorrencias, Audiencias, Sentencas, Recursos, Pericias e Despesas."
	STR0039+CRLF+;	//##"- Na legenda ser�o apresentados os tipos de obriga��es citados acima.
	STR0040+CRLF;	//##"- No componente de sele��o ser�o apresentados os mesmos tipos de obriga��es da legenda, por�m, ao selecionar um deles, ser�o apresentados os detalhes de cada e data indicando a quantidade de ocorr�ncias naquele dia.
	,STR0028)		//##"Esclarecimento"

Endif

Return
