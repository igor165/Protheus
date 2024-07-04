#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

#DEFINE NUM_PICT "@E 999,999,999"
#DEFINE PER_PICT "@E 999,999.99"

Static cMesAnoCornt	:= FmesAnoRef()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CSAPGOnl ³ Autor ³ Joeudo Santana        ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definicao dos paineis on-line para modulo Cargos e Salarios³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAPGOnl                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACSA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAPGOnl(oPGOnline)

Local cDescMesAno	:= " Ref: "+Right(cMesAnoCornt,2)+"/"+Left(cMesAnoCornt,4)
Local aToolBar		:= {}
Local nTempo   		:= SuperGetMV("MV_PGORFSH", .F., 60)//Tempo para atualizacao do painel

/* ------------------------------------- PAINEIS --------------------------------------------------------------
1 - Aumento Salarial Mes e Ano   		- ( Dos funcionarios que tiveram aumento - qual foi o percentual medio de aumento)
2 - Tempo medio de aumento salarial		- ( Quanto tempo foi aumentado o salario dos funcionários)
3 - Numero de funcionarios 				- ( Quantidade de funcionario para cada situacao)
4 - Progressão dos salarios no ano 		- ( Percentual de aumento salarial ao longo do ano)
5 - Indice de valores salariais			- ( Comparativo de salarios pagos no ano com o ano anterior)*/


//-------------------------------------------------------------------------------
// PAINEL 1 - AUMENTO SALARIAL MES E ANO
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
 	Aadd( aToolBar, { "S4WB016N","Help",  "{ || MsgInfo("+CsaHelpPnl(1)+") }"})
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0013;  //"Aumento Salarial Mes e Ano"
		DESCR		STR0014 +cDescMesAno;  //"Aumento salarial no mês e acumulado no ano(%)."
		TYPE		4;
		ONLOAD		"CSAPGOL001";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;
		NAME		"CSAPGOL001"

//-------------------------------------------------------------------------------
// PAINEL 2 - TEMPO MEDIO DE AUMENTO SALARIAL
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
	aToolBar  := {}
	Aadd( aToolBar, { "S4WB016N","Help", "{ || MsgInfo("+CsaHelpPnl(2)+") }"})
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0015;  //"Tempo médio de aumento salarial"
		DESCR		STR0015;  //"Tempo médio de aumento salarial"
		TYPE		1;
		ONLOAD		"CSAPGOL002";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;
		NAME		"CSAPGOL002";
		PARAMETERS	"CSAPG2"

//-------------------------------------------------------------------------------
// PAINEL 3 - NUMERO DE FUNCIONARIOS
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
	aToolBar  := {}
	Aadd( aToolBar, { "S4WB016N","Help", "{ || MsgInfo("+CsaHelpPnl(3)+") }"})
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0016;  				//"Número de funcionários"
		DESCR		STR0017 + cDescMesAno;	//"Número de funcionários por situação"
		TYPE		2;
		ONLOAD		"CSAPGOL003";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;
		NAME		"CSAPGOL003";
		DEFAULT 	2

//-------------------------------------------------------------------------------
// PAINEL 4 - PROGRESSAO DOS SALARIOS NO ANO
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
	aToolBar  := {}
	Aadd( aToolBar, { "S4WB016N","Help", "{ || MsgInfo("+CsaHelpPnl(4)+") }"})
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0018; //"Progressão dos salários no Ano"
		DESCR		STR0019 +cDescMesAno; //"Índice de progressão dos salários no ano."
		TYPE		2;
		ONLOAD		"CSAPGOL004";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;
		NAME		"CSAPGOL004";
		DEFAULT 	3

//-------------------------------------------------------------------------------
// PAINEL 5 - INDICE DE VALORES SALARIAIS
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
	aToolBar  := {}
	Aadd( aToolBar, { "S4WB016N","Help","{ || MsgInfo("+CsaHelpPnl(5)+") }"})
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0020; //"Índice de valores salariais (Comparativo)"
		DESCR		STR0020 + cDescMesAno; //"Índice de valores salariais (Comparativo)"
		TYPE		4;
		ONLOAD		"CSAPGOL005";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;
		NAME		"CSAPGOL005"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CSAPGOL001 ³ Autor ³ Joeudo Santana		  ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 1 (tipo 4) - Percentual de aumento salarial 	³±±
±±³          ³ no mes e acumulado ano										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL001													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 4)					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function CSAPGOL001

Local aRetorno 			:=	{}
Local cDataIniMes		:=	cMesAnoCornt+"01"
Local cDataFimMes		:=	cMesAnoCornt+strzero(f_UltDia(stod(cDataIniMes)),2)
Local cDataIniAno  		:=	Left(cMesAnoCornt,4)+'0101'
Local cDataFimAno  		:=	Left(cMesAnoCornt,4)+'1231'
Local nPercMes			:=	0
Local nPercAno			:=	0

//-------------------------------------------------------------------------------
// Percentual de aumento salarial medio entre os funcionarios que tiveram aumento
//-------------------------------------------------------------------------------

nPercMes	:= AumentSal(cDataIniMes,cDataFimMes,1) // Percentual de aumento salarial no mes
nPercAno	:= AumentSal(cDataIniAno,cDataFimAno,1) // Percentual de aumento salarial no ano

aRetorno:=	{"" , 0, 100,;
				{;
					{ If (nPercMes > 0 ,Alltrim(Transform(nPercMes,PER_PICT))+"%", STR0021), If (nPercMes > 0 ,STR0022,""), CLR_BLACK, Nil, nPercMes },;   //"Não há dados a serem exibidos" | "Mês"
					{ If (nPercAno > 0 ,Alltrim(Transform(nPercAno,PER_PICT))+"%", STR0021), If (nPercAno > 0 ,STR0023,""), CLR_BLACK, Nil, nPercAno };    //"Não há dados a serem exibidos" | "Ano"
				};
			}

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CSAPGOL002 ³ Autor ³ Joeudo Santana		  ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Painel 2 (Tipo 3) - Tempo medio de aumento salarial ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL002													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 3)					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAPGOL002

Local cTempo		:= ""
Local aRetorno		:= {}
Local nTempAument	:= 0
Pergunte("CSAPG2", .F.)

//------------------------------------------------------------------------------------------------------------
//Tempo medio de aumento salarial para os funcionarios que tiveram aumento no periodo determinado pelo usuario
//------------------------------------------------------------------------------------------------------------

nTempAument:= AumentSal(dtos(mv_par01),dtos(mv_par02),2)    //  tempo medio de aumento salarial

If nTempAument > 0 .and. nTempAument < 30
	cTempo		:= STR0024	//Dias
Else
	cTempo		:= STR0033	//Meses
	nTempAument	:= nTempAument/30
EndIf

aRetorno:=	{;
			{ cTempo,	If (nTempAument > 0, Alltrim(Transform(nTempAument,NUM_PICT)),STR0021),CLR_BLACK,	Nil };	 	//"Não há dados a serem exibidos"
			}

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CSAPGOL003 ³ Autor ³ Joeudo Santana		  ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 3 (tipo 2) - Numero de funcionarios		 	³±±
±±³			 ³ (Em Atividade, Em Ferias, Afastados e demitidos)				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL003													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 2)					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAPGOL003

Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local cAliasSRA 	:= "QRYSRA"
Local cDataPesq		:= cMesAnoCornt+"01"
Local nAtivos		:= 0
Local nFerias		:= 0
Local nAfastados	:= 0
Local nDemitidos	:= 0
Local aAtivos		:= {}
Local aFerias		:= {}
Local aAfastados	:= {}
Local aDemitidos	:= {}
Local aFuncionarios	:= {}
Local aCabec		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {} )

Private lOfusca		:= Len(aFldRel) > 0

//-- Query que apura a quantidade de funcionarios nas situacoes: ativos, ferias, afastados e demitidos.
BeginSql alias cAliasSRA
	SELECT SRA.RA_SITFOLH, COUNT(SRA.RA_MAT) AS NUMFUNC
	FROM %table:SRA% SRA
	WHERE SRA.%notDel% AND ( SRA.RA_DEMISSA = '        ' OR (SRA.RA_DEMISSA >= %exp:cDataPesq% AND SRA.RA_RESCRAI NOT IN('30','31')) )
	AND SRA.RA_ADMISSA < %exp:cDataPesq%
	GROUP BY RA_SITFOLH
	ORDER BY RA_SITFOLH
EndSql

Dbselectarea(cAliasSRA)
While !(cAliasSRA)->(eof())
//-- Carrega a quantidade de funcionarios em cada situacao
	If (cAliasSRA)->RA_SITFOLH == " "
		nAtivos	:= (cAliasSRA)->NUMFUNC
	ElseIf (cAliasSRA)->RA_SITFOLH == "F"
		nFerias	:= (cAliasSRA)->NUMFUNC
	ElseIf (cAliasSRA)->RA_SITFOLH == "A"
		nAfastados	:= (cAliasSRA)->NUMFUNC
	ElseIf (cAliasSRA)->RA_SITFOLH == "D"
		nDemitidos	:= (cAliasSRA)->NUMFUNC
	Endif
	(cAliasSRA)->(dbskip())
Enddo


aAtivos		:= FuncPorSit('')   	// Numero de funcionarios ativos
aFerias		:= FuncPorSit('F')     // Numero de funcionarios em ferias
aAfastados	:= FuncPorSit('A')     // Numero de funcionarios afastados
aDemitidos	:= FuncPorSit('D')     // Numero de funcionarios demitidos

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasSRA)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)


//Cabecalho do detalhamento dos funcionarios por situacao
aCabec	:={ STR0025 , STR0026 }     //"Matrícula" | "Nome"


// Carrega array com detalhamento de funcionarios por situacao

If(len(aAtivos)>0 )
	Aadd(aFuncionarios,{ STR0027	,aCabec	, aAtivos		})  	//"Ativos"
Else
	Aadd(aFuncionarios,{ STR0027 ,{STR0021}	, array(1,1)	} )		//"Ativos""	|  "Não há dados a serem exibidos"
EndIf

If(len(aFerias)>0 )
	Aadd(aFuncionarios,{ STR0028	,aCabec	, aFerias  		})   	//"Férias"
Else
	Aadd(aFuncionarios,{ STR0028 	,{STR0021}	, array(1,1)	} ) //"Férias"		| "Não há dados a serem exibidos"
EndIf
If(len(aAfastados)>0 )
	Aadd(aFuncionarios,{ STR0029	,aCabec	, aAfastados  	})   	//"Afastados"
Else
	Aadd(aFuncionarios,{ STR0029 	,{STR0021}	, array(1,1)	} ) //"Afastados"  		|  "Não há dados a serem exibidos"
Endif
If(len(aDemitidos)>0 )
	Aadd(aFuncionarios,{ STR0030 	,aCabec	, aDemitidos	})	   	//"Demitidos"
Else
	Aadd(aFuncionarios,{ STR0030 	,{STR0021}	, array(1,1)	} ) //"Demitidos" 		| "Não há dados a serem exibidos"
EndIf

aRetorno := {  GRP_PIE,;
				{ STR0031						 					,;	//"Funcionários por Situação:"
					Nil												,;
 					{STR0027,STR0028 , STR0029, STR0030}		,;	//"Ativos"  - "Férias"  - "Afastados"  - "Demitidos"
 					{nAtivos,nFerias,nAfastados,nDemitidos}   	 ;
 				}								   					,;
 				{ STR0032, Nil,  aFuncionarios  }        ; 	   		//"Funcionários"
 			}

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CSAPGOL004 ³ Autor ³ Joeudo Santana		  ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 4 (tipo 2) - Indice de progressao dos 		³±±
±±³          ³ salarios pagos ao longo do ano								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL004													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 2)					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function CSAPGOL004

Local nMeses	:= Val(Right(cMesAnoCornt,2))
Local nX		:= 0
Local cAno		:= Left(cMesAnoCornt,4)
Local aRetorno	:= {}
Local aEixoX	:= Array(nMeses,1)
Local aPercMes	:= Array(nMeses,1)
Local aMeses	:= {STR0001, STR0002, STR0003, STR0004, STR0005, STR0006, STR0007, STR0008, STR0009, STR0010, STR0011,STR0012 }  //"Janeiro", "Fevereiro"... "Dezembro"

// Alimenta array com os percentuais de aumento salarial ate o mes de referencia
For nX:=1 to nMeses
	cDataIni		:= cAno + If(nX < 10, "0"+Alltrim(str(nX)), Alltrim(str(nX))) + "01"
	cDataFim		:= cAno + If(nX < 10, "0"+Alltrim(str(nX)), Alltrim(str(nX))) + strzero(f_UltDia(stod(cDataIni)),2)

	aPercMes[nX][1]	:= Round(AumentSal(cDataIni,cDataFim, 1),2)
	aEixoX[nX] 		:= aMeses[nX]
Next nX

aRetorno:=	{;
				GRP_BAR,;
				NIL,;
				{STR0033},;//"Meses"
				aEixoX,;
				aPercMes;
			}

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CSAPGOL005 ³ Autor ³ Joeudo Santana		  ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 5 (tipo 4)- Indice de valores salariais pagos³±±
±±³          ³ no ano em comparacao ao ano anterior 						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL005													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 4)					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function CSAPGOL005

Local aRetorno		:=	{}
Local cDataIni		:=	""
Local cDataFim		:=	""
Local cDataIniAnt	:=	""
Local cDataFimAnt	:=	""
Local cAno			:=	Left(cMesAnoCornt,4)
Local cAnoAnt		:=  Str(Val(cAno)-1)
Local nPercAnoAnt	:=	0
Local nPercAno		:=	0

//-----------------------------------------------------------------------
// Percentual de aumento salarial do ano vigente ate o mes de referencia
cDataIni	:= cAno+"0101"
cDataFim	:= cMesAnoCornt+strzero(f_UltDia(stod(cMesAnoCornt+"01")),2)
nPercAno	:= AumentSal(cDataIni,cDataFim,1)
//------------------------------------------------------------------------

//-----------------------------------------------------------------------
// Percentual de aumento salarial de todo o ano anterior
cDataIniAnt	:=	cAnoAnt+"0101"
cDataFimAnt	:=	cAnoAnt+"1231"
nPercAnoAnt	:=	AumentSal(Alltrim(cDataIniAnt),AllTrim(cDataFimAnt), 1)
//-------------------------------------------------------------------------

aRetorno:=	{"" , 0, 100,;
				{;
					{ If(nPercAnoAnt > 0 ,Alltrim(Transform(nPercAnoAnt,PER_PICT))+"%",STR0021), Alltrim(cAnoAnt), CLR_BLACK, "{ || MsgInfo("+CsaHelpPnl(6)+") }", nPercAnoAnt },;//"Não há dados a serem exibidos"
					{ If(nPercAno    > 0 ,Alltrim(Transform(nPercAno   ,PER_PICT))+"%",STR0021), AllTrim(cAno)   , CLR_BLACK, "{ || MsgInfo("+CsaHelpPnl(7)+") }", nPercAno    }; //"Não há dados a serem exibidos"
				};
			}
Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CursPlanej		³ Autor ³ Joeudo Santana	  ³ Data ³ 23/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade e valor dos cursos planejados	no periodo	  	  ³±±
±±³			 ³ determinado pelo usuario										  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CursPlanej()	   													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(quantidade e valor)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACSA  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AumentSal(cDataIni,cDataFim, nTipo)

Local aArea	   		:=	GetArea()
Local nPercent		:=	0
Local nValDif		:=	0
Local nCount		:= 	0
Local nSalAnter 	:=	0
Local nTempAument	:=	0
Local nRetorno		:=	0
Local cAliasQry 	:=	GetNextAlias()
Local dDataAnt		:=	CTOD("  /  /  ")
Local cMatAnt		:=	""
Local cChavePesq	:=	""

//-- Query que apura as alteracoes salariais ocorridas no mes.
BeginSql alias cAliasQry
	SELECT SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA, SR3.R3_TIPO, SR3.R3_VALOR, SR3.R3_SEQ
	FROM %table:SR3% SR3
	WHERE SR3.%notDel% AND SR3.R3_PD = '000' AND SR3.R3_DATA BETWEEN %exp:cDataIni% AND %exp:cDataFim%
	AND NOT SR3.R3_TIPO = '001'
	ORDER BY SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA DESC, SR3.R3_SEQ DESC, SR3.R3_TIPO
EndSql

//-- Ajusta o campo de data da alteracao salarial
TCSetField(cAliasQry, "R3_DATA", "D", 8, 0)


//-- Abre a area dos historicos salariais para pesquisar o penultimo valor antes do aumento
Dbselectarea("SR3")
//-- Apura os valores e percentuais das diferencas salarias
Dbselectarea(cAliasQry)
While !(cAliasQry)->(eof())
	cChavePesq	:= (cAliasQry)->(R3_FILIAL+R3_MAT)
	nValDif		:= 0
	nSalAnter	:= 0
	If (cAliasQry)->(R3_MAT) <> cMatAnt .or. (cAliasQry)->(R3_DATA) <> dDataAnt

		dDataAnt:=(cAliasQry)->(R3_DATA)
		cMatAnt	:=(cAliasQry)->(R3_MAT)

		//-- Busca o salario anterior
		SR3->(DbSetOrder(2))
		If SR3->( Dbseek(cChavePesq+DTOS((cAliasQry)->(R3_DATA))+(cAliasQry)->(R3_SEQ)+(cAliasQry)->(R3_TIPO)))
			While !SR3->(Bof()) .And. SR3->(R3_FILIAL+R3_MAT) == cChavePesq
				SR3->(dbskip(-1))
				If SR3->(R3_TIPO+R3_SEQ) <> (cAliasQry)->(R3_TIPO+R3_SEQ) .And.;
					SR3->R3_DATA < (cAliasQry)->R3_DATA
					If nTipo == 1
				 		nSalAnter	:= SR3->R3_VALOR
				 	Else
				 		dDataAnt	:= SR3->R3_DATA
				 	EndIf
				 	Exit
				Endif
			Enddo
		Endif
		If	nTipo == 1
			//-- Apura o valor da diferenca e o percentual do aumento
			If nSalAnter > 0
				nValDif		:=	(cAliasQry)->R3_VALOR - nSalAnter
				nPercent	+=	(nValDif/(cAliasQry)->R3_VALOR)*100
				nCount++
			Endif
		Else
			// -- Apura o tempo entre o ultimo aumento e o anterior
			If !Empty(dDataAnt)
				nTempAument += (cAliasQry)->R3_DATA -  dDataAnt
				nCount++
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbskip())
Enddo

If nTipo ==  1
	nRetorno:= If (nPercent > 0, nPercent/nCount,0)
Else
	nRetorno:= If (nTempAument > 0, nTempAument/nCount,0)
EndIf
(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return nRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FmesAnoRefºAutor  ³Joeudo Santana		 º Data ³  23/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para iniciar a variavel de mes e ano de referencia  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Painel CSA		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FmesAnoRef()

Local cRet	:= SuperGetMv("MV_FOLMES",,MesAno(dDataBase))

cRet	:= If(Len(alltrim(cRet)) == 0,MesAno(dDataBase),cRet)

return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FuncPorSitºAutor  ³Joeudo Santana		 º Data ³  21/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcionarios por situacao               	  				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CSAXPGL			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FuncPorSit(cSit)

Local aArea	   		:=	GetArea()
Local cQuerySRA		:=	GetNextAlias()
Local aFuncionarios	:=	{}
Local cDataPesq		:= cMesAnoCornt+"01"

//-- Query que apura funcionarios nas situacoes: ativos, ferias, afastados e demitidos.
BeginSql alias cQuerySRA
	SELECT RA_MAT, RA_NOME
	FROM %table:SRA% SRA
	WHERE SRA.%notDel% AND ( SRA.RA_DEMISSA = '        ' OR (SRA.RA_DEMISSA >= %exp:cDataPesq% AND SRA.RA_RESCRAI NOT IN('30','31')) )
	AND SRA.RA_ADMISSA < %exp:cDataPesq%
	AND RA_SITFOLH = %exp:cSit%
	ORDER BY RA_MAT, RA_NOME
EndSql

//-- Adiciona matricula e nome dos funcionarios para detalhamento por situacao
Dbselectarea(cQuerySRA)
While !(cQuerySRA)->(eof())
	aAdd(aFuncionario,{ (cQuerySRA)->RA_MAT , If( lOfusca, Replicate('*',30), (cQuerySRA)->RA_NOME ) } )
	(cQuerySRA)->(dbskip())
Enddo

(cQuerySRA)->(DbCloseArea())
RestArea(aArea)
Return aFuncionarios


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CsaHelpPnlºAutor  ³Joeudo Santana	     º Data ³  09/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta Helps dos paineis do CSA                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PAINEL SIGACSA                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CsaHelpPnl(nPainel)
Local cHelp := ""

   Do Case
   		Case nPainel = 1
   			cHelp := "'"+STR0034+"'+Chr(13)+Chr(10)+'"+STR0035+"'" //"Neste painel são apresentados percentuais de aumentos salariais no mês de referência e acumulado no ano."
   		   											  //"Onde o sistema seleciona todos os funcionários que receberam aumento no período (mês/ano) e calcula a média.
   		Case nPainel = 2
   			cHelp := "'"+STR0036+"'"	//"Tempo médio de aumento salarial" -- Neste painel é apresentado o tempo médio entre aumentos salariais no período determinado pelo usuário."
   		Case nPainel = 3
   			cHelp := "'"+STR0037+"'"	//"Neste painel são apresentados os números de funcionários nas situações: Ativos, Férias, Afastados e Demitidos."
   		Case nPainel = 4
   			cHelp := "'"+STR0038+"'"	//"Neste painel é apresentado o percentual médio de aumento salarial em cada mês do ano, até o mês de referência."
   		Case nPainel = 5
   			cHelp := "'"+STR0039+"'"	//"Neste painel é apresentado  indice  de valores salariais pagos no ano em comparação ao ano anterior."
   		Case nPainel = 6
   			cHelp := "'"+STR0040+"'"	//"Percentual de aumento salarial no ano anterior (inteiro)"
		Case nPainel = 7
   			cHelp := "'"+STR0041+"'"	//"Percentual de aumento salarial no ano até o mês de referência"
     EndCase
Return cHelp
