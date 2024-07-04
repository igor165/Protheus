#Include "PROTHEUS.CH"
#Include "PANELONLINE.CH"
#Include "GPEPGONL.CH"
#INCLUDE "MSGRAPHI.CH"

Static cPgOnFolMes	:= MesAno(dDataBase)
Static __aAfast__	:= {}
Static __aTpAumen__	:= {}
Static __nFilter

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GPEPGONL ณ Autor ณ Ricardo Duarte Costa  ณ Data ณ 01/03/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ ROTINA PARA EXECUCAO DOS PAINEIS DE GESTAO                 ดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณCecilia Car.ณ15/08/14ณTQIBW3ณIncluido o fonte da 11 para a 12 e efetua-ณฑฑ
ฑฑณ            ณ        ณ      ณ da a limpeza.                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPEPGONL(oPGOnline)

Local cDescMesAno	:= " Ref: "+Right(cPgOnFolMes,2)+"/"+Left(cPgOnFolMes,4)
Local aToolBar		:= {}
Local nTempo   		:= SuperGetMV("MV_PGORFSH", .F., 14400)//Tempo para atualizacao do painel

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || GPEPGHLP("001") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ;								// ###"Quantidade de Funcionแrios por Situa็ใo"
	DESCR STR0001+cDescMesAno ;					// ###"Quantidade de Funcionแrios por Situa็ใo"
	TYPE 2 ;
	ONLOAD "GPEPG001" ;
	REFRESH nTempo ;
	DEFAULT 1 ;
	TOOLBAR aToolBar;
	NAME "GPEPG001";
	TITLECOMBO STR0007;							// ###"FILIAL"          
  	PYME	
		

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || GPEPGHLP("002") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0031 ;								//##"Afastamentos: Tipos X Funcionแrios"
	DESCR STR0031+cDescMesAno ;					//##"Afastamentos: Tipos X Funcionแrios"
	TYPE 2 ;
	ONLOAD "GPEPG002" ;
	REFRESH nTempo ;
	DEFAULT 3	 ;
	TOOLBAR aToolBar;
	NAME "GPEPG002";  
	PYME	

aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || GPEPGHLP("003") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0032 ;								//##"Afastamentos: Tipos X Dias"
	DESCR STR0032+cDescMesAno ;					//##"Afastamentos: Tipos X Dias"
	TYPE 2 ;
	ONLOAD "GPEPG003" ;
	REFRESH nTempo ;
	DEFAULT 2	 ;
	TOOLBAR aToolBar;
	NAME "GPEPG003" ;
	TITLECOMBO STR0033;							//##"TIPOS"
	PYME	
	
aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || GPEPGHLP("004") } } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0036 ;								//##"Alteracoes Salariais"
	DESCR STR0036+cDescMesAno ;					//##"Alteracoes Salariais"
	TYPE 5 ;
	ONLOAD "GPEPG004" ;
	REFRESH nTempo ;
	TOOLBAR aToolBar;
	NAME "GPEPG004";
	PYME	

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0055 ;								//##"Calendario Tributario-Fiscal"
	DESCR STR0056 ;								//##"Obrigacoes Fiscais"
	TYPE 7 ;
	ONLOAD "GPEPG005" ;
	REFRESH nTempo ;
	DEFAULT 6 ;
	NAME "GPEPG005"	
Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEPG001 บAutor  ณRicardo Duarte Costaบ Data ณ  01/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel indicativo do numero de funcionarios na empresa.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPG001()

Local aInfo		:= {}
Local aInfo2	:= {}
Local aInfoBase	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasSRA := "QRYSRA"
Local cAliasSRA2:= "QRYSRA2"
Local cAliasSRE := "QRYSRE"
Local cDataPesq	:= cPgOnFolMes+"01"
Local cDataPesqF:= cPgOnFolMes+strzero(f_UltDia(stod(cDataPesq)),2)
Local cDescFil	:= ""
Local cFilVel	:= Replicate("@", FWGETTAMFILIAL)
Local nAtivos	:= 0
Local nAdmitidos:= 0
Local nFerias	:= 0
Local nAfastados:= 0
Local nDemitidos:= 0
Local nTransfEnt:= 0
Local nTransfSai:= 0
Local nPosFil	:= 0
Local nx		:= 0

//-- Monta o array modelo
Aadd( aInfoBase , { STR0002 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Em Atividade"
Aadd( aInfoBase , { STR0003 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Em F้rias"
Aadd( aInfoBase , { STR0004 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Afastados"
Aadd( aInfoBase , { STR0005 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Demitidos"
Aadd( aInfoBase , { STR0009 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Admitidos"
Aadd( aInfoBase , { STR0010 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Transferidos - Entrada"
Aadd( aInfoBase , { STR0011 , Transform(0.00,"@R 99,999") , CLR_RED , } )//###"Transferidos - Saida"
Aadd( aInfoBase , { STR0012 , Transform(0.00,"@R 999.99") , CLR_RED , } )//###"% Admissใo"
Aadd( aInfoBase , { STR0013 , Transform(0.00,"@R 999.99") , CLR_RED , } )//###"% Demissใo"

//-- Query que apura a quantidade de funcionarios nas situacoes: ativos, ferias, afastados e demitidos.
BeginSql alias cAliasSRA
	SELECT SRA.RA_FILIAL, SRA.RA_SITFOLH, COUNT(SRA.RA_MAT) AS NUMFUNC
	FROM %table:SRA% SRA
	WHERE SRA.%notDel% AND ( SRA.RA_DEMISSA = '        ' OR (SRA.RA_DEMISSA >= %exp:cDataPesq% AND SRA.RA_RESCRAI NOT IN('30','31')) )
	AND SRA.RA_ADMISSA < %exp:cDataPesq%
	GROUP BY RA_FILIAL, RA_SITFOLH
	ORDER BY RA_FILIAL, RA_SITFOLH
EndSql

//-- Apura os totais por filial
Dbselectarea(cAliasSRA)
While !(cAliasSRA)->(eof())
	//-- Carrega a descricao da filial
	If cFilVel <> (cAliasSRA)->RA_FILIAL
		If SM0->(dbseek(cEmpAnt+(cAliasSRA)->RA_FILIAL))
			cDescFil	:= (cAliasSRA)->RA_FILIAL + " - " + SM0->M0_FILIAL
		Else
			cDescFil	:= STR0006			//##"Filial Inexistente"
		Endif
		cFilVel	:= (cAliasSRA)->RA_FILIAL
		aInfo2	:= aClone(aInfoBase)
	Endif
	//-- Carrega a quantidade de funcionarios em cada situacao
	While !(cAliasSRA)->(eof()) .And. cFilVel == (cAliasSRA)->RA_FILIAL
		If (cAliasSRA)->RA_SITFOLH == " "
			aInfo2[1,2]	:= Transform((cAliasSRA)->NUMFUNC,"@R 99,999")
			nAtivos	+= (cAliasSRA)->NUMFUNC
		ElseIf (cAliasSRA)->RA_SITFOLH == "F"
			aInfo2[2,2]	:= Transform((cAliasSRA)->NUMFUNC,"@R 99,999")
			nFerias	+= (cAliasSRA)->NUMFUNC
		ElseIf (cAliasSRA)->RA_SITFOLH == "A"
			aInfo2[3,2]	:= Transform((cAliasSRA)->NUMFUNC,"@R 99,999")
			nAfastados	+= (cAliasSRA)->NUMFUNC
		ElseIf (cAliasSRA)->RA_SITFOLH == "D"
			aInfo2[4,2]	:= Transform((cAliasSRA)->NUMFUNC,"@R 99,999")
			nDemitidos	+= (cAliasSRA)->NUMFUNC
		Endif
		(cAliasSRA)->(dbskip())
	Enddo
	Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
Enddo

//-- Query que apura a quantidade de funcionarios admitidos no mes.
BeginSql alias cAliasSRA2
	SELECT SRA.RA_FILIAL, COUNT(SRA.RA_MAT) AS NUMFUNC
	FROM %table:SRA% SRA
	WHERE SRA.%notDel% AND SRA.RA_ADMISSA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	GROUP BY RA_FILIAL
	ORDER BY RA_FILIAL
EndSql

//-- Total de Funcionarios Admitidos no mes
cFilVel	:= Replicate("@", FWGETTAMFILIAL)
Dbselectarea(cAliasSRA2)
While !(cAliasSRA2)->(eof())
	nPosFil	:= aScan(aInfo,{|X| X[1] = (cAliasSRA2)->RA_FILIAL})
	//-- Carrega a descricao e dados da filial que nao existe ainda
	If nPosFil == 0 .And. cFilVel <> (cAliasSRA2)->RA_FILIAL
		If SM0->(dbseek(cEmpAnt+(cAliasSRA2)->RA_FILIAL))
			cDescFil	:= (cAliasSRA2)->RA_FILIAL + " - " + SM0->M0_FILIAL
		Else
			cDescFil	:= STR0006			//##"Filial Inexistente"
		Endif
		cFilVel	:= (cAliasSRA2)->RA_FILIAL
		aInfo2	:= aClone(aInfoBase)
		Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
		nPosFil	:= Len(aInfo)
	Else
		cFilVel	:= (cAliasSRA2)->RA_FILIAL
	Endif
	//-- Carrega a quantidade de funcionarios admitidos no mes
	aInfo[nPosFil,2,5,2]	:= Transform((cAliasSRA2)->NUMFUNC,"@R 99,999")
	nAdmitidos	+= (cAliasSRA2)->NUMFUNC
	(cAliasSRA2)->(dbskip())
Enddo

//-- Query que apura a quantidade de funcionarios transferidos por entrada ou saida.
BeginSql alias cAliasSRE
	SELECT SRE.RE_EMPD, SRE.RE_FILIALD, SRE.RE_EMPP, SRE.RE_FILIALP, COUNT(SRE.RE_EMPD) AS NUMFUNC
	FROM %table:SRE% SRE
	WHERE SRE.%notDel% AND SRE.RE_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF% AND
	( SRE.RE_EMPD <> SRE.RE_EMPP OR SRE.RE_FILIALD <> SRE.RE_FILIALP )
	GROUP BY SRE.RE_EMPD, SRE.RE_FILIALD, SRE.RE_EMPP, SRE.RE_FILIALP
	ORDER BY RE_EMPD, RE_FILIALD, RE_EMPP, RE_FILIALP
EndSql

//-- Total de Transferencia de Entrada e Saida no mes
cFilVel	:= Replicate("@", FWGETTAMFILIAL)
Dbselectarea(cAliasSRE)
While !(cAliasSRE)->(eof())
	nPosFilD	:= aScan(aInfo,{|X| X[1] = (cAliasSRE)->RE_FILIALD})
	nPosFilP	:= aScan(aInfo,{|X| X[1] = (cAliasSRE)->RE_FILIALP})
	//-- Tratamento para a filial de origem
	If (cAliasSRE)->RE_EMPD == cEmpAnt
		//-- Carrega a descricao e dados da filial que nao existe ainda
		If nPosFilD == 0 .And. cFilVel <> (cAliasSRE)->RE_FILIALD
			If SM0->(dbseek(cEmpAnt+(cAliasSRE)->RE_FILIALD))
				cDescFil	:= (cAliasSRE)->RE_FILIALD + " - " + SM0->M0_FILIAL
			Else
				cDescFil	:= STR0006			//##"Filial Inexistente"
			Endif
			cFilVel	:= (cAliasSRE)->RE_FILIALD
			aInfo2	:= aClone(aInfoBase)
			Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
			nPosFil	:= Len(aInfo)
		Else
			cFilVel	:= (cAliasSRE)->RE_FILIALD
		Endif
		//-- Carrega a quantidade de funcionarios transferidos por saida no mes
		aInfo[nPosFilD,2,7,2]	:= Transform(Val(aInfo[nPosFilD,2,7,2])+(cAliasSRE)->NUMFUNC,"@R 99,999")
		nTransfSai	+= (cAliasSRE)->NUMFUNC
	Endif
	//-- Tratamento para a filial de destino
	If (cAliasSRE)->RE_EMPP == cEmpAnt
		//-- Carrega a descricao e dados da filial que nao existe ainda
		If nPosFilP == 0 .And. cFilVel <> (cAliasSRE)->RE_FILIALP
			If SM0->(dbseek(cEmpAnt+(cAliasSRE)->RE_FILIALP))
				cDescFil	:= (cAliasSRE)->RE_FILIALP + " - " + SM0->M0_FILIAL
			Else
				cDescFil	:= STR0006			//##"Filial Inexistente"
			Endif
			cFilVel	:= (cAliasSRE)->RE_FILIALP
			aInfo2	:= aClone(aInfoBase)
			Aadd( aInfo, { cDescFil , aClone(aInfo2) } )
			nPosFil	:= Len(aInfo)
		Else
			cFilVel	:= (cAliasSRE)->RE_FILIALP
		Endif
		//-- Carrega a quantidade de funcionarios transferidos por entrada no mes.
		aInfo[nPosFilP,2,6,2]	:= Transform(Val(aInfo[nPosFilP,2,6,2])+(cAliasSRE)->NUMFUNC,"@R 99,999")
		//-- Ajusta a quantidade funcionarios no inicio do mes, descontando as entradas por transferencia no mes.
		aInfo[nPosFilP,2,1,2]	:= Transform(Val(aInfo[nPosFilP,2,1,2])-(cAliasSRE)->NUMFUNC,"@R 99,999")
		nTransfEnt	+= (cAliasSRE)->NUMFUNC
	Endif
	(cAliasSRE)->(dbskip())
Enddo

//-- Total Geral da Empresa
aInfo2	:= aClone(aInfoBase)
aInfo2[1,2]	:= Transform(nAtivos,"@R 99,999")
aInfo2[2,2]	:= Transform(nFerias,"@R 99,999")
aInfo2[3,2]	:= Transform(nAfastados,"@R 99,999")
aInfo2[4,2]	:= Transform(nDemitidos,"@R 99,999")
aInfo2[5,2]	:= Transform(nAdmitidos,"@R 99,999")
aInfo2[6,2]	:= Transform(nTransfEnt,"@R 99,999")
aInfo2[7,2]	:= Transform(nTransfSai,"@R 99,999")
Aadd( aInfo, { STR0008 , aClone(aInfo2) } )	//###"TOTAL"

//-- Calcula os percentuais de admissao e demissao
For nx := 1 to len(aInfo)
	nAtivos	:= Val(aInfo[nx,2,1,2])+Val(aInfo[nx,2,2,2])+Val(aInfo[nx,2,3,2])+Val(aInfo[nx,2,4,2])
	nAtivos	:= nAtivos+Val(aInfo[nx,2,7,2])-Val(aInfo[nx,2,6,2])
	//-- Admissao
	aInfo[nx,2,8,2]	:= Transform(Val(aInfo[nx,2,5,2]) / nAtivos * 100,"@R 999.99")
	//-- Demissao
	aInfo[nx,2,9,2]	:= Transform(Val(aInfo[nx,2,4,2]) / nAtivos * 100,"@R 999.99")
next nx

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasSRA)->(dbclosearea())
(cAliasSRA2)->(dbclosearea())
(cAliasSRE)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEPG002 บAutor  ณRicardo Duarte Costaบ Data ณ  05/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel indicativo dos afastamentos no mes.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPG002()

Local aInfo		:= {}
Local aAux		:= {}
Local aFilial	:= {}
Local aTipos	:= {}
Local aValores	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasSR8 := "QRYSR8"
Local cDataPesq	:= cPgOnFolMes+"01"
Local cDataPesqF:= cPgOnFolMes+strzero(f_UltDia(stod(cDataPesq)),2)
Local cDescFil	:= ""
Local nPosAf	:= 0
Local nx		:= 0
Local ny		:= 0

//-- Query que apura a quantidade de afastamentos no mes corrente.
BeginSql alias cAliasSR8
	SELECT SR8.R8_TIPO, COUNT(SR8.R8_FILIAL) AS NUMFUNC
	FROM %table:SR8% SR8 
	WHERE SR8.%notDel%
	AND SR8.R8_DATAINI <= %exp:cDataPesqF%
	AND (SR8.R8_DATAFIM >= %exp:cDataPesq% OR SR8.R8_DATAFIM = '        ')
	AND NOT SR8.R8_TIPO = 'F'
	GROUP BY SR8.R8_TIPO
	ORDER BY SR8.R8_TIPO
EndSql

//-- Apura os totais dos afastamentos por filial
Dbselectarea(cAliasSR8)
While !(cAliasSR8)->(eof())
	nPosAf	:= Ascan(aAux,{|X| X[1] == (cAliasSR8)->R8_TIPO})
	If nPosAf > 0
		aAux[nPosAf,3] += ( (cAliasSR8)->NUMFUNC )
	Else
		Aadd( aAux,{(cAliasSR8)->R8_TIPO,(cAliasSR8)->NUMFUNC})
	Endif
	//-- Monta o array do eixo X com os tipos de afastamento
	nPosTipo	:= Ascan(aTipos,{|X| X = (cAliasSR8)->R8_TIPO})
	If nPosTipo == 0
		cDescTipo	:= (cAliasSR8)->R8_TIPO+"-"+fPesqAf((cAliasSR8)->R8_TIPO)
		Aadd(aTipos,cDescTipo)
	Endif
	(cAliasSR8)->(dbskip())
Enddo

//-- Monta o array de indicadores -- Empresas
cDescFil	:= SM0->M0_NOME
Aadd(aFilial,cDescFil)

//-- Verifica o conteudo dos tipos de afastamentos
If Len(aTipos) == 0
	Aadd(aTipos,STR0038)			//##"Nใo ocorreram afastamentos no perํodo!"
Endif
//-- Cria matriz para carregar as informacoes de afastamento
aValores	:= Array(Len(aTipos),Len(aFilial))
//-- Preenche os valores por tipo de afastamento
For nx := 1 to Len(aTipos)
	For ny := 1 to Len(aFilial)
		nPosAf	:= Ascan(aAux,{|X| X[1] == Substr(aTipos[nx],1,1)})
		If nPosAf > 0
			aValores[nx,ny]	:= aAux[nPosAf,2]
		Else
			aValores[nx,ny]	:= 0
		Endif
	Next ny
Next nx

//-- Monta as informacoes do painel
aInfo	:= { GRP_BAR , NIL , aFilial , aTipos , aValores }

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasSR8)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEPG003 บAutor  ณRicardo Duarte Costaบ Data ณ  05/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel indicativo dos afastamentos no mes.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPG003()

Local aInfo		:= {}
Local aAux		:= {}
Local aAux2		:= {}
Local aFiliais	:= {}
Local aTabela	:= {}
Local aTipos	:= {}
Local aValores	:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasSR8 := "QRYSR8"
Local cDataPesq	:= cPgOnFolMes+"01"
Local cDataPesqF:= cPgOnFolMes+strzero(f_UltDia(stod(cDataPesq)),2)
Local cDescFil	:= ""
Local nDiasAf	:= 0
Local nPosAf	:= 0
Local nx		:= 0
Local ny		:= 0
Local nw		:= 0
Local nVezes	:= 0

//-- Query que apura a quantidade de afastamentos no mes corrente.
BeginSql alias cAliasSR8
	column DATAINI as Date
	column DATAFIM as Date
	SELECT SR8.R8_FILIAL, SR8.R8_TIPO, 
	CASE WHEN SR8.R8_DATAFIM='        ' OR SR8.R8_DATAFIM > %exp:cDataPesqF% THEN %exp:cDataPesqF% ELSE SR8.R8_DATAFIM END AS DATAFIM,
	CASE WHEN SR8.R8_DATAINI < %exp:cDataPesq% THEN %exp:cDataPesq% ELSE SR8.R8_DATAINI END AS DATAINI
	FROM %table:SR8% SR8 
	WHERE SR8.%notDel%
	AND SR8.R8_DATAINI <= %exp:cDataPesqF%
	AND (SR8.R8_DATAFIM >= %exp:cDataPesq% OR SR8.R8_DATAFIM = '        ')
	AND NOT SR8.R8_TIPO = 'F'
	ORDER BY SR8.R8_FILIAL, SR8.R8_TIPO, DATAFIM, DATAINI
EndSql

//-- Apura os totais dos afastamentos por filial
Dbselectarea(cAliasSR8)
While !(cAliasSR8)->(eof())
	//-- Monta a tabela indicadora de Filial X Afastamento X Dias X Numero de funcionarios
	nPosAf	:= Ascan(aAux,{|X| X[1] == (cAliasSR8)->R8_FILIAL .And. X[2] == (cAliasSR8)->R8_TIPO})
	nDiasAf	:= ( (cAliasSR8)->DATAFIM - (cAliasSR8)->DATAINI ) + 1
	If nPosAf > 0
		aAux[nPosAf,3] += nDiasAf
		aAux[nPosAf,4] ++
	Else
		Aadd( aAux,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_TIPO,nDiasAf,1,fPesqAf((cAliasSR8)->R8_TIPO)})
	Endif
	//-- Monta o array de indicadores -- Filiais
	nPosFil		:= Ascan(aFiliais,{|X| X = (cAliasSR8)->R8_FILIAL})
	If nPosFil == 0
		If SM0->(dbseek(cEmpAnt+(cAliasSR8)->R8_FILIAL))
			cDescFil	:= (cAliasSR8)->R8_FILIAL + " - " + SM0->M0_FILIAL
		Else
			cDescFil	:= STR0006			//##"Filial Inexistente"
		Endif
		Aadd(aFiliais,cDescFil)
	Endif
	//-- Monta o indicador do total de afastamentos da empresa
	nPosTipo	:= Ascan(aTipos,{|X| X = (cAliasSR8)->R8_TIPO})
	If nPosTipo > 0
		aValores[nPosTipo] += nDiasAf
	Else
		cDescTipo	:= (cAliasSR8)->R8_TIPO+"-"+fPesqAf((cAliasSR8)->R8_TIPO)
		Aadd(aTipos,cDescTipo)
		Aadd(aValores,nDiasAf)
	Endif
	(cAliasSR8)->(dbskip())
Enddo

//-- Verifica o preenchimento dos arrays quando nao existir informacao a ser mostrada
If Len(aTipos) == 0
	Aadd(aTipos,STR0038)		//##"Nใo ocorreram afastamentos no perํodo!"
	Aadd(aValores,1)
	Aadd(aFiliais,space(20))
	Aadd( aAux,{Space(FWGETTAMFILIAL),"N",0,0,STR0038})	//##"Nใo ocorreram afastamentos no perํodo!"
Endif

//-- Monta a tabela com as informacoes individuais de cada filial por tipo de afastamento
For ny := 1 to Len(aTipos)
	aAux2	:= {}
	For nw := 1 to Len(aAux)
		If aAux[nw,2] == Substr(aTipos[ny],1,1)
			nx	:= Ascan(aFiliais,{|Z| Substr(Z,1,FWGETTAMFILIAL) == aAux[nw,1]})
			Aadd(aAux2,{aFiliais[nx],Transform(aAux[nw,3],"@R 99,999,999"),Transform(aAux[nw,4],"@R 99,999,999")})
		Endif
	next nw
	Aadd(aTabela,{aTipos[ny],{STR0007,STR0027,STR0028},aClone(aAux2)})	//##"FILIAL"##"DIAS"##"N. FUNCIONมRIOS"
Next ny

//-- Monta as informacoes do painel
aInfo	:= { GRP_PIE ,;
				{STR0030, NIL , aTipos , aValores },;					//##"Tipos de Afastamentos"
				{STR0029, NIL , aTabela };								//##"Filiais"
			}

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasSR8)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEPG004 บAutor  ณRicardo Duarte Costaบ Data ณ  07/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel indicativo das alteracoes salariais no mes.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPG004()

Local aInfo		:= {}
Local aCabec	:= {STR0007,STR0035,"%",STR0028}	//##"FILIAL"##"TIPO DO AUMENTO"##"N. FUNCIONมRIOS"
Local aAlign	:= {"LEFT","LEFT","RIGHT","RIGHT"}
Local aValores	:= {}
Local aAux		:= {}
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasSR3 := "QRYSR3"
Local cDataPesq	:= cPgOnFolMes+"01"
Local cDataPesqF:= cPgOnFolMes+strzero(f_UltDia(stod(cDataPesq)),2)
Local cDescAumen:= ""
Local cDescFil	:= ""
Local cChavePesq:= ""
Local cTexto	:= ""
Local cFilVel	:= Replicate("@", FWGETTAMFILIAL)
Local nValDif	:= 0
Local nPosFil	:= 0
Local nSalAnter	:= 0
Local nx		:= 0

//-- Query que apura as alteracoes salariais ocorridas no mes.
BeginSql alias cAliasSR3
	SELECT SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA, SR3.R3_TIPO, SR3.R3_VALOR, SR3.R3_SEQ
	FROM %table:SR3% SR3
	WHERE SR3.%notDel% AND SR3.R3_PD = '000' AND SR3.R3_DATA BETWEEN %exp:cDataPesq% AND %exp:cDataPesqF%
	AND NOT SR3.R3_TIPO = '001'
	ORDER BY SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA DESC, SR3.R3_SEQ DESC, SR3.R3_TIPO
EndSql

//-- Ajusta o campo de data da alteracao salarial
TCSetField(cAliasSR3, "R3_DATA", "D", 8, 0)

//-- Abre a area dos historicos salariais para pesquisar o penultimo valor antes do aumento
Dbselectarea("SR3")

//-- Apura os valores e percentuais das diferencas salarias por filial
Dbselectarea(cAliasSR3)
While !(cAliasSR3)->(eof())
	cChavePesq	:= (cAliasSR3)->(R3_FILIAL+R3_MAT)
	nValDif		:= 0
	nSalAnter	:= 0
	//-- Busca o salario anterior
	If SR3->( Dbseek(cChavePesq) )
		While !SR3->(eof()) .And. SR3->(R3_FILIAL+R3_MAT) == cChavePesq
			If SR3->(R3_TIPO+R3_SEQ) <> (cAliasSR3)->(R3_TIPO+R3_SEQ) .And.;
				SR3->R3_DATA < (cAliasSR3)->R3_DATA
				nSalAnter	:= SR3->R3_VALOR
			Endif
			SR3->(dbskip())
		Enddo
	Endif
	//-- Apura o valor da diferenca e o percentual do aumento
	If nSalAnter > 0
		nValDif		:= (cAliasSR3)->R3_VALOR - nSalAnter
		nPosFil		:= Ascan(aValores,{|X| Substr(X[1],1,FWGETTAMFILIAL) == (cAliasSR3)->R3_FILIAL .And. ;
											Substr(X[2],1,3) == (cAliasSR3)->R3_TIPO })
		If nPosFil > 0
			aValores[nPosFil,3]	+= nValDif
			aValores[nPosFil,4]	+= nSalAnter
			aValores[nPosFil,5]	++
		Else
			If (cAliasSR3)->R3_FILIAL <> cFilVel
				If SM0->(dbseek(cEmpAnt+(cAliasSR3)->R3_FILIAL))
					cDescFil	:= (cAliasSR3)->R3_FILIAL + " - " + SM0->M0_FILIAL
					cFilVel		:= (cAliasSR3)->R3_FILIAL
				Else
					cDescFil	:= STR0006			//##"Filial Inexistente"
					cFilVel		:= Replicate("@", FWGETTAMFILIAL)
				Endif
			Endif
			cDescAumen	:= (cAliasSR3)->R3_TIPO+"-"+fPesqTpAum((cAliasSR3)->R3_TIPO)
			aAdd(aValores,{cDescFil,cDescAumen,nValDif,nSalAnter,1})
		Endif
	Endif
	(cAliasSR3)->(dbskip())
Enddo

//-- Monta a tabela com as informacoes individuais de cada filial por tipo de afastamento
For nx := 1 to Len(aValores)
	Aadd(aAux,{	aValores[nx,1],;
				aValores[nx,2],;
				Transform(Round(aValores[nx,3] / aValores[nx,4] * 100.00,2),"@R 999,999.99"),;
				Transform(aValores[nx,5],"@R 999,999")})
Next nx

//-- Carrega aValores
aValores	:= aClone(aAux)

//-- Valores basicos para nao estourar error.log
If Len(aValores) == 0
	cTexto	:= STR0037		//##"Nใo ocorreram altera็๕es salariais no perํodo!"
	aAdd(aValores,{space(20),space(30),Transform(0.00,"@R 999,999.99"),Transform(0,"@R 999,999")})
Endif
//-- Monta as informacoes do painel
aInfo	:= { NIL , aCabec , aValores , aAlign , cTexto }

//-- Fecha os arquivos de trabalho e retorna a area corrente.
(cAliasSR3)->(dbclosearea())
RestArea(aAreaSM0)
RestArea(aArea)

Return(aInfo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fPesqAf  บAutor  ณRicardo Duarte Costaบ Data ณ  07/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para pesquisa dos tipos de afastamentos.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fPesqAf(cTipoPesq)

Local cDesc		:= ""
Local aAfast	:= aClone(__aAfast__)
Local nPos		:= 0

//-- Monta o array dos tipos de afastamentos mais utilizados.
If Len(aAfast) == 0
	Aadd(aAfast,{"A",STR0014})			//##"TEMPORARIO"
	Aadd(aAfast,{"O",STR0015})			//##"ACIDENTE"
	Aadd(aAfast,{"P",STR0016})			//##"DOENCA"
	Aadd(aAfast,{"Q",STR0017})			//##"MATERNIDADE"
	Aadd(aAfast,{"R",STR0018})			//##"MILITAR"
	Aadd(aAfast,{"V",STR0019})			//##"APOSENTADORIA"
	Aadd(aAfast,{"X",STR0020})			//##"LIC.NAO REMUN"
	Aadd(aAfast,{"Y",STR0021})			//##"OUTROS"
	Aadd(aAfast,{"8",STR0022})			//##"LIC.REMUNERAD"
	Aadd(aAfast,{"W",STR0023})			//##"SINDICAL"
	Aadd(aAfast,{"B",STR0024})			//##"ADOCAO 120D"
	Aadd(aAfast,{"6",STR0025})			//##"ADOCAO 60D"
	Aadd(aAfast,{"7",STR0026})			//##"ADOCAO 30D"
	__aAfast__	:= aClone(aAfast)
Endif

//-- Pesquisa a descricao do tipo de afastamento
nPos		:= Ascan(aAfast,{|X| X[1] == cTipoPesq})
If nPos > 0
	cDesc	:= aAfast[nPos,2]
Else
	cDesc	:= Substr(Tabela("30",cTipoPesq),1,13)
	//-- Salva o novo codigo utilizado na estatica
	Aadd(aAfast,{cTipoPesq,cDesc})
	__aAfast__	:= aClone(aAfast)
Endif
	
Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fPesqAf  บAutor  ณRicardo Duarte Costaบ Data ณ  07/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para pesquisa dos tipos de afastamentos.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fPesqTpAum(cTipoPesq)

Local cDesc		:= ""
Local aTpAumen	:= aClone(__aTpAumen__)
Local nPos		:= 0

//-- Pesquisa a descricao do tipo de afastamento
nPos		:= Ascan(aTpAumen,{|X| X[1] == cTipoPesq})
If nPos > 0
	cDesc		:= aTpAumen[nPos,2]
Else
	//-- Monta o array dos tipos de aumentos mais utilizados.
	cDesc		:= Tabela("41",cTipoPesq)
	//-- Salva o novo codigo utilizado na estatica
	Aadd(aTpAumen,{cTipoPesq,cDesc})
	__aTpAumen__:= aClone(aTpAumen)
Endif
	
Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fIniGPEPGบAutor  ณRicardo Duarte Costaบ Data ณ  08/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para iniciar a variavel de mes e ano.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fIniGPEPG()

Local cRet	:= SuperGetMv("MV_FOLMES",,MesAno(dDataBase))

cRet	:= If(Len(alltrim(cRet)) == 0,MesAno(dDataBase),cRet)

return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEPGHLP บAutor  ณRicardo Duarte Costaบ Data ณ  09/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de Help para os paineis de gestao.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPGHLP(cPainel)


If cPainel == '001'

	MsgInfo(;
	STR0040+CRLF+;	//##"- Em Atividade: Nesta quantidade estใo considerados todos os funcionแrios ativos que nใo estใo incluidos nas outras situa็๕es."
	STR0041+CRLF+;	//##"- Em F้rias: Nesta quantidade estใo considerados todos os funcionแrios que iniciaram ou terminaram ferias no m๊s corrente."
	STR0042+CRLF+;	//##"- Afastados: Nesta quantidade estใo considerados todos os funcionแrios que iniciaram, terminaram ou continuam afastados no m๊s corrente."
	STR0043+CRLF+;	//##"- Demitidos: Nesta quantidade estใo considerados todos os funcionแrios que forma demitidos no m๊s corrente."
	STR0044+CRLF+;	//##"- Admitidos: Nesta quantidade estใo considerados todos os funcionแrios admitidos no m๊s corrente."
	STR0045+CRLF+;	//##"- Transferidos - Entrada: Nesta quantidade estใo considerados todos os funcionแrios que entraram por transferencia no m๊s corrente."
	STR0046+CRLF+;	//##"- Transferidos - Saํda: Nesta quantidade estใo considerados todos os funcionแrios que sairam por transferencia no m๊s corrente."
	STR0047+CRLF+;	//##"- % Admissใo: este percentual representa o n๚mero de admiss๕es em rela็ใo ao total de funcionแrios da empresa."
	STR0048+CRLF;	//##"- % demissใo: este percentual representa o n๚mero de demiss๕es em rela็ใo ao total de funcionแrios da empresa."
	,STR0039)		//##"Esclarecimento"

ElseIf cPainel == '002'

	MsgInfo(;
	STR0049+CRLF+;	//##"- Este indicador serแ demonstrado na forma de um grแfico de barras onde as barras representarใo a quantidade de funcionแrios por tipo de afastamento.
	STR0050+CRLF;	//##"- Na legenda serใo apresentados os tipos de afastamentos ocorridos no m๊s corrente.
	,STR0039)		//##"Esclarecimento"

ElseIf cPainel == '003'

	MsgInfo(;
	STR0051+CRLF+;	//##"- Este indicador serแ demonstrado na forma de um grแfico de setor (pizza) onde cada setor representarแ a quantidade de dias de afastamento por tipo de afastamento.
	STR0052+CRLF+;	//##"- Na legenda serใo apresentados os tipos de afastamentos ocorridos no m๊s corrente.
	STR0053+CRLF;	//##"- No componente de sele็ใo serใo apresentados os mesmos tipos de afastamentos da legenda, por้m, ao selecionar o tipo de afastamento serใo apresentados os detalhes de cada filial numa lista logo abaixo.
	,STR0039)		//##"Esclarecimento"

ElseIf cPainel == '004'

	MsgInfo(;
	STR0054;		//##"- Este indicador serแ demonstrado na forma de um browse onde serใo apresentados, por filial, os tipos de aumentos, a quantidade de funcionแrios e o percentual das altera็๕es salariais ocorridas no m๊s corrente.
	,STR0039)		//##"Esclarecimento"

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEPG005  บAutor  ณMarco Bianchi       บ Data ณ  19/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta array para Painel de Gestao On-line Tipo 7.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Paineis de Gestao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEPG005()

Local aInfo := { {STR0057,STR0058,STR0059,STR0060,STR0061,STR0062,STR0063},;
				 { RetTitle("LA1_MESDIA"),RetTitle("LA1_DESCR"),RetTitle("LA1_SEQNUM") },;
				 'GpePgFil()',;
				 'GpePgFil()',;
				 'GpePgFil()',;
				 {|x| GpePgMens(x[3])} }
				 
__nFilter := 99
                              
Return aInfo

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpePgFil  บAutor  ณMarco Bianchi       บ Data ณ  19/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra dados para apresentacao no browse.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGPEPG005                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GpePgFil(oPGItem,oPGCalend,oFilter,aItem)

Local aDia        := {}
Local aDecendial  := {}
Local aQuinzenal  := {}
Local aMensal     := {}
Local aBimestral  := {}
Local aTrimestral := {} 
Local aSemestral  := {}
Local aAnual      := {}
Local lDia        := .F.

Local dDataRef    := oPGCalend:dDiaAtu  //dDataBase
Local dDataLim    := oPGCalend:dDiaAtu  //dDataBase
Local dDataCal    := CtoD("  /  /  ")
Local dDataIni    := CtoD("  /  /  ")
Local cAnoRef     := AllTrim(Str(Year(dDataRef)))
Local cMesRef     := Substr(DtoC(dDataRef),4,2)
Local cAnoCal     := cAnoRef
Local cMesCal     := Substr(DtoC(dDataRef),4,2)

aItem := {}                

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Analisa tabela de obrigacoes fiscais e preenche os arrays correspon-   ณ
//ณ desntes de acordo com sua periodicidade.                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("LA1")
dbGoTop()
While !Eof()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณObrigacao concluida ou obrigacao desabilitada ou modulo igual a Livros  ณ
	//ณFiscais nao serao consideradas.                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If LA1_STATUS == "2" .Or. LA1_HABILI == "2" .Or. LA1_MODULO == "1"
		dbSkip()
		Loop
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta Data da obrigacao gravado na tabela LA1                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(Substr(LA1_MESDIA,7,2))          
		cAnoCal := Substr(LA1_MESDIA,7,2)
	Else
		cAnoCal := cAnoRef
	EndIf
	If !Empty(Substr(LA1_MESDIA,3,2))          
		cMesCal := Substr(LA1_MESDIA,3,2)
	Else
		cMesCal := cMesRef
	EndIf
	dDataCal := CtoD(Substr(LA1_MESDIA,1,2) + "/" + cMesCal + "/" + cAnoCal)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMuda cor do dia no calendario se tiver obrigacao cadastrado             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cMesRef == cMesCal .And. cAnoRef == cAnoCal
		oPGCalend:addRestri(Day(dDataCal),CLR_HRED,CLR_WHITE)    
	EndIf	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe alterou filtro do combo faz filtros correspondentes                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If __nFilter <> oFilter:nAt
	

		dDataLim  := oPGCalend:dDiaAtu
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Decendiais                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Day (dDataRef)<=10
			While (.T.)
				If (Day (dDataLim))==10	  								//1. Decendio 
					Exit
				EndIf
				++dDataLim
			Enddo
		ElseIf Day (dDataRef)<=20
			While (.T.)
				If (Day (dDataLim))==20	  								//2. Decendio 
					Exit
				EndIf
				++dDataLim
			Enddo
		Else
			dDataLim :=	LastDay (dDataRef)						 		//3. Decendio
		EndIf
	    If dDataCal >= dDataRef .And. dDataCal <= dDataLim
			AADD(aDecendial ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )    
	    EndIf
	
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Quinzenais                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Day (dDataRef)<=15
			While (.T.)
				If (Day (dDataLim))==15								//1. Quinzena 
					Exit
				EndIf
				++dDataLim
			Enddo
		Else
			dDataLim :=	LastDay (dDataRef)	  						//2. Quinzena 
		EndIf
	    If dDataCal >= dDataRef .And. dDataCal <= dDataLim
			AADD(aQuinzenal ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Mensais                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dDataIni := CtoD("01/"+cMesRef+"/"+cAnoRef)
		dDataLim :=	LastDay (dDataRef)
	    If dDataCal >= dDataIni .And. dDataCal <= dDataLim
			AADD(aMensal,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Bimestrais                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (Month (dDataRef)>=1 .And. Month (dDataRef)<=2)
			dDataIni := CtoD("01/01/"+cAnoRef)		
			dDataLim :=	LastDay (CtoD ("01/02/"+cAnoRef))			//1. Bimestre
		ElseIf (Month (dDataRef)>=3 .And. Month (dDataRef)<=4)
			dDataIni := CtoD("01/03/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/04/"+cAnoRef))			//2. Bimestre
		ElseIf (Month (dDataRef)>=5 .And. Month (dDataRef)<=6)
			dDataIni := CtoD("01/05/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/06/"+cAnoRef))			//3. Bimestre
		ElseIf (Month (dDataRef)>=7 .And. Month (dDataRef)<=8)
			dDataIni := CtoD("01/07/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/08/"+cAnoRef))			//3. Bimestre
		ElseIf (Month (dDataRef)>=9 .And. Month (dDataRef)<=10)
			dDataIni := CtoD("01/09/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/10/"+cAnoRef))			//3. Bimestre
		Else                       
			dDataIni := CtoD("01/11/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/12/"+cAnoRef))			//4. Bimestre
		EndIf
	    If dDataCal >= dDataIni .And. dDataCal <= dDataLim
			AADD(aBimestral ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Trimestrais                               ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (Month (dDataRef)>=1 .And. Month (dDataRef)<=3)
			dDataIni := CtoD("01/01/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/03/"+cAnoRef))			//1. Trimestre
		ElseIf (Month (dDataRef)>=4 .And. Month (dDataRef)<=6)
			dDataIni := CtoD("01/04/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/06/"+cAnoRef))			//2. Trimestre
		ElseIf (Month (dDataRef)>=7 .And. Month (dDataRef)<=9)
			dDataIni := CtoD("01/07/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/09/"+cAnoRef))			//3. Trimestre
		Else
			dDataIni := CtoD("01/10/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/12/"+cAnoRef))			//4. Trimestre
		EndIf
	    If dDataCal >= dDataIni .And. dDataCal <= dDataLim
			AADD(aTrimestral,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Semestrais                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (Month (dDataRef)>=1 .And. Month (dDataRef)<=6)
			dDataIni := CtoD("01/01/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/06/"+cAnoRef))			//1. Semestre
		Else	
			dDataIni := CtoD("01/07/"+cAnoRef)				
			dDataLim :=	LastDay (CtoD ("01/12/"+cAnoRef))			//4. Semestre
		EndIf
	    If dDataCal >= dDataIni .And. dDataCal <= dDataLim
			AADD(aSemestral ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza array com obrigacoes Anuais                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dDataIni := CtoD("01/01/"+cAnoRef)			
		dDataLim :=	LastDay (CtoD (	"01/12/"+cAnoRef ))
	    If dDataCal >= dDataIni .And. dDataCal <= dDataLim
			AADD(aAnual     ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )
	    EndIf
	    
    Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe clicou no dia do calendario                                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    lDia := .T.
	    dDataLim := dDataRef
	    If dDataCal >= dDataRef .And. dDataCal <= dDataLim
			AADD(aDia ,{LA1_MESDIA, LA1_DESCR, LA1_SEQNUM} )    
	    EndIf
    
    EndIf

	dbSelectArea("LA1")
	dbSkip()

EndDo
                   
If lDia		// Click no dia
	aItem := aClone(aDia)
Else
	If oFilter:nAt == 1
		aItem := aClone(aDecendial)
	ElseIf oFilter:nAt == 2
		aItem := aClone(aQuinzenal)
	ElseIf oFilter:nAt == 3
		aItem := aClone(aMensal)
	ElseIf oFilter:nAt == 4
		aItem := aClone(aBimestral)
	ElseIf oFilter:nAt == 5
		aItem := aClone(aTrimestral)
	ElseIf oFilter:nAt == 6
		aItem := aClone(aSemestral)
	ElseIf oFilter:nAt == 7
		aItem := aClone(aAnual)
	EndIf
EndIf
             

oPGItem:SetArray(aItem)
__nFilter := oFilter:nAt
oPGItem:Refresh()

Return aItem	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpePgMens บAutor  ณMarco Bianchi       บ Data ณ  19/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta mensagem ao clicar em um registro do browse.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGPEPG005                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GpePgMens(cCodigo)

Local cMensagem := ""
Local aRetBox   := {}
Local cModulo   := ""
Local cPeriod   := ""
Local cHabili   := ""
Local cStatus   := ""

            
dbSelectArea("LA1")
dbSetOrder(1)
dbSeek(xFilial("LA1")+cCodigo)  
                  

//-- Esse array contem as descricoes existentes no ComboBox dos campos Combo
aRetBox := RetSx3Box( Posicione('SX3', 2, 'LA1_MODULO', 'X3CBox()' ),,, Len(LA1->LA1_MODULO) )
cModulo := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == LA1->LA1_MODULO} ), 3 ])		   

aRetBox := RetSx3Box( Posicione('SX3', 2, 'LA1_PERIOD', 'X3CBox()' ),,, Len(LA1->LA1_PERIOD) )
cPeriod := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == LA1->LA1_PERIOD} ), 3 ])		   

aRetBox := RetSx3Box( Posicione('SX3', 2, 'LA1_HABILI', 'X3CBox()' ),,, Len(LA1->LA1_HABILI) )
cHabili := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == LA1->LA1_HABILI} ), 3 ])		   

aRetBox := RetSx3Box( Posicione('SX3', 2, 'LA1_STATUS', 'X3CBox()' ),,, Len(LA1->LA1_STATUS) )
cStatus := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == LA1->LA1_STATUS} ), 3 ])		   
        
//cMensagem := "Detalhes da Obrigacao" + chr(13)+chr(10)	
cMensagem += " " + chr(13)+chr(10)
cMensagem += " " + chr(13)+chr(10)
cMensagem += "Modulo     : " + cModulo  + chr(13)+chr(10)
cMensagem += "Periodo    : " + cPeriod  + chr(13)+chr(10)
cMensagem += "Habilitado : " + cHabili  + chr(13)+chr(10)
cMensagem += "Acao       : " + LA1_ACAO + chr(13)+chr(10)
cMensagem += "Status     : " + cStatus  + chr(13)+chr(10)

MsgInfo("Detalhes da Obrigacao" + cMensagem)

Return()
