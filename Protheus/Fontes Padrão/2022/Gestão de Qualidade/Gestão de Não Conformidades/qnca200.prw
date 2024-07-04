#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCA200.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QNCA200  บAutor  ณAndre Anjos	     บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta Alocacao de Recursos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAQNC e SIGAPMS /                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCA200()
Local aParams  := {}
Local aCabec   := {}
Local aDados   := {}
Local aButtons := {}
Local aUserBut := {}
Local aOpcPesq := {}
Local aPosObj  := {}
Local aSize	   := MsAdvSize(.T.)
Local oDlg     := NIL
Local oBrowse  := NIL
Local oComPesq := NIL
Local oGetPesq := NIL
Local oTotPrev := NIL
Local oTotApon := NIL
Local cValPesq := ""
Local cCombo   := ""
Local nTotPrev := 0
Local nTotApon := 0
Local nButtIni := 5
Local nColOrd  := 14
Local nQTMKPMS := SuperGetMV("MV_QTMKPMS",.F.,1)
Local lPesqEx  := .T.

Private cCadastro := STR0001

If nQTMKPMS < 3
	Aviso(STR0002,STR0003,{"OK"}) //Esta rotina ้ de uso exclusivo em ambientes com integra็ใo entre os m๓dulos QNC e PMS.
	Return
EndIf

//-- Criacao de perguntas

aAdd(aParams,{5,STR0004,.T.,50,,.F.}) //Pendentes
aAdd(aParams,{5,STR0005,.T.,50,,.F.}) //Na fila
aAdd(aParams,{5,STR0006,.T.,50,,.F.}) //Atrasadas
aAdd(aParams,{5,STR0007,.F.,50,,.F.}) //Futuras
aAdd(aParams,{5,STR0008,.F.,50,,.F.}) //Potenciais
aAdd(aParams,{5,STR0009,.F.,50,,.F.}) //Concluํdas

aAdd(aButtons,{"FILTRO",{ || QA200Perg(@aDados,@oTotPrev,@oTotApon,@oBrowse,aParams,nColOrd)},STR0010,'Parโmetros'}) //Parametros
aAdd(aButtons,{"PMSCOLOR",{ || Q200Legend()},STR0012,STR0013}) //Legenda
aAdd(aButtons,{"SDUFIELDS",{ || Q200Ordena(@oBrowse,@aDados,@nColOrd,aCabec)},STR0042,STR0041}) //Reordenar

If nQTMKPMS == 4
	aAdd(aOpcPesq,RetTitle("QI2_NCHAMA"))
	cValPesq := Space(TamSX3("ADE_CODIGO")[1])
Else
	cValPesq := Space(TamSX3("QI2_FNC")[1])
EndIf
aAdd(aOpcPesq,RetTitle("QI2_FNC"))
aAdd(aOpcPesq,RetTitle("QI3_CODIGO"))
aAdd(aOpcPesq,RetTitle("QI5_DESCTP"))
aAdd(aOpcPesq,STR0014)
aAdd(aOpcPesq,STR0015)
aAdd(aOpcPesq,STR0016)
aAdd(aOpcPesq,RetTitle("AF9_DESCRI"))

aAdd(aCabec,"") 					//-- 01.Status
If nQTMKPMS == 4
	aAdd(aCabec,RetTitle("QI2_NCHAMA"))	//-- 02.Chamado
EndIf
aAdd(aCabec,RetTitle("QI2_FNC"))	//-- 03.FNC
aAdd(aCabec,RetTitle("QI2_REV"))	//-- 04.Rev. FNC
aAdd(aCabec,RetTitle("QI3_CODIGO"))	//-- 05.Plano Acao
aAdd(aCabec,RetTitle("QI3_REV"))	//-- 06.Rev. Acao
aAdd(aCabec,RetTitle("AF9_PROJET"))	//-- 07.Projeto
aAdd(aCabec,RetTitle("AF9_TAREFA"))	//-- 08.Tarefa
aAdd(aCabec,RetTitle("QI5_DESCTP"))	//-- 09.Etapa
aAdd(aCabec,STR0014)				//-- 10.Responsavel
aAdd(aCabec,STR0015)				//-- 11.Etapa Atual
aAdd(aCabec,STR0016)  				//-- 12.Resp. Atual
aAdd(aCabec,RetTitle("AF9_DESCRI"))	//-- 13.Desc. Tarefa
aAdd(aCabec,STR0017)				//-- 14.Aloca็ใo Prevista
aAdd(aCabec,STR0018)				//-- 15.Andamento (%)
aAdd(aCabec,STR0019)				//-- 16.Hrs Previstas
aAdd(aCabec,STR0020)				//-- 17.Hrs Apontadas

aPosObj := MsObjSize({aSize[1],aSize[2],aSize[3],aSize[4],3,3},{{100,100,.T.,.T.}},.T.) 

If QA200Perg(@aDados,@nTotPrev,@nTotApon,@oBrowse,aParams,nColOrd)
	Define MsDialog oDlg Title cCadastro OF oMainWnd Pixel From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd

	//== Pesquisa ==========================================================================
	TSay():New(43,08,{|| STR0021},oDlg,,,,,,.T.,,,200,20)
	oComPesq := TComboBox():New(40,35,{|u| If(PCount()>0,cCombo:=u,cCombo)},aOpcPesq,60,30,oDlg,,{|| Q200IniPes(oComPesq:nAt,@cValPesq,@oGetPesq)},,,,.T.)
	oGetPesq := TGet():New(43,100,{|u| If(PCount()>0,cValPesq:=u,cValPesq)},oDlg,180,10,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cValPesq,,,,)  
   	TButton():New(43,285,STR0022,oDlg,{|| Q200Pesqui(@oBrowse,oComPesq:nAt,cValPesq,lPesqEx)},50,12,,,.F.,.T.,.F.,,.F.,,,.F.)
   	TCheckBox():New(43,345,STR0023,{|u| If(PCount()>0,lPesqEx:=u,lPesqEx)},oDlg,100,10,,,,,,,,.T.,,,)
 	//== Fim Pesquisa ======================================================================

	//== Browse ============================================================================
	oBrowse := TCBrowse():New(63,05,aPosObj[1,4]-05,aPosObj[1,3]-80,,aCabec,,oDlg,,,,,,,,,,,,,,.T.,,.F.,,,)
	oBrowse:SetArray(aDados)
	oBrowse:bLine := {|| {Q200Legend(aDados[oBrowse:nAt,1]),aDados[oBrowse:nAt,2],aDados[oBrowse:nAt,3],aDados[oBrowse:nAt,4],;
						   aDados[oBrowse:nAt,5],aDados[oBrowse:nAt,6],aDados[oBrowse:nAt,7],aDados[oBrowse:nAt,8],;
						   aDados[oBrowse:nAt,9],aDados[oBrowse:nAt,10],aDados[oBrowse:nAt,11],aDados[oBrowse:nAt,12],;
						   aDados[oBrowse:nAt,13],aDados[oBrowse:nAt,14],aDados[oBrowse:nAt,15],aDados[oBrowse:nAt,16],;
						   aDados[oBrowse:nAt,17]}	}
	//== Fim Browse ========================================================================
	
	//== Rodape ============================================================================
	If nQTMKPMS == 4
		TButton():New(aPosObj[1,3]-12,nButtIni,STR0024,oDlg,{|| Q200Visual(1,oBrowse)},50,12,,,.F.,.T.,.F.,,.F.,,,.F.) //Chamado
		nButtIni+=50
	EndIf
	TButton():New(aPosObj[1,3]-12,nButtIni,STR0025,oDlg,{|| Q200Visual(2,oBrowse)},50,12,,,.F.,.T.,.F.,,.F.,,,.F.) //FNC
	TButton():New(aPosObj[1,3]-12,nButtIni+=50,STR0026,oDlg,{|| Q200Visual(3,oBrowse)},50,12,,,.F.,.T.,.F.,,.F.,,,.F.) //Plano
	TButton():New(aPosObj[1,3]-12,nButtIni+=50,STR0027,oDlg,{|| Q200Visual(4,oBrowse)},50,12,,,.F.,.T.,.F.,,.F.,,,.F.) //Tarefa
	
	oTotPrev := TSay():New(aPosObj[1,3]-10,aPosObj[1,4]-240,{|| STR0028 +Transform(nTotPrev,"@E 99,999,999,999.99")},oDlg,,,,,,.T.,,,120,20) //Total de horas previstas: 
	oTotApon := TSay():New(aPosObj[1,3]-10,aPosObj[1,4]-120,{|| STR0029 +Transform(nTotApon,"@E 99,999,999,999.99")},oDlg,,,,,,.T.,,,120,20) //Total de horas apontadas: 
	//== Fim Rodape ========================================================================
	
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},,aButtons)
EndIf

SetKey(VK_F12, NIL)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200ProcesบAutor  ณMicrosiga           บ Data ณ  03/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que realiza a pesquisa na base de dados, prepara o  บฑฑ
ฑฑบ          ณ array de dados e atualiza os objetos em tela.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aDados: array com os dados a serem apresentados no browse. บฑฑ
ฑฑบ			 ณ oTotPrev: objeto totalizador das horas previstas. 		  บฑฑ
ฑฑบ			 ณ oTotApon: objeto totalizador das horas apontadas. 		  บฑฑ
ฑฑบ			 ณ oBrowse: objeto browse de exibicao dos resultados. 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200Proces(aDados,uTotPrev,uTotApon,oBrowse,aChecks,nColOrd)
Local cQuery    := ""
Local cQryAux   := ""
Local cBanco    := TCGetDB()
Local bLine     := If(ValType(oBRowse) == "O",oBrowse:bLine,NIL)
Local nLegend   := NIL
Local nTotPrev  := 0
Local nTotApon  := 0
Local nPercAF9	:= 0
Local nTotRec   := 0
Local nCol		:= 0
Local nQTMKPMS  := SuperGetMV("MV_QTMKPMS",.F.,1)

QAA->(dbSetOrder(1))
QI5->(dbSetOrder(1))

aDados := {}

If Select("TRB") > 0
	TRB->(dbCloseArea())
EndIf

Pergunte("QNC200",.F.)

If aChecks[1] .Or. aChecks[2] .Or. aChecks[3] .Or. aChecks[6]
	//-- Campos com os detalhes da tarefa
	cQuery += "SELECT 'AF9' AS TABALIAS, AF9.AF9_FNC, AF9.AF9_REVFNC, AF9.AF9_ACAO, AF9.AF9_REVACA, "
	cQuery += "AFA.AFA_PROJET, AFA.AFA_REVISA, AFA.AFA_TAREFA, AFA.AFA_RECURS, AF9.AF9_DESCRI, "
	cQuery += "AFA.AFA_START, AFA.AFA_HORAI, AFA.AFA_FINISH, AFA.AFA_HORAF, AFA.AFA_QUANT, "
	cQuery += "' ' AS QI5_OBRIGA, "
	
	//-- Subquery para obter o nro do chamado
	cQuery += "(SELECT QI2_NCHAMA FROM " +RetSQLName("QI2") +" QI2 WHERE QI2.D_E_L_E_T_ <> '*' AND "
	cQuery += "QI2.QI2_FILIAL = '" +xFilial("QI2") +"' AND QI2.QI2_FNC = AF9.AF9_FNC AND "
	cQuery += "QI2.QI2_REV = AF9.AF9_REVFNC) AS QI2_NCHAMA,"

	//-- Subquery para obter a acao correspondente a tarefa
	cQuery += "(SELECT QI5.QI5_TPACAO FROM " +RetSQLName("QI5") +" QI5 WHERE "
	cQuery += "QI5.D_E_L_E_T_ <> '*' AND QI5.QI5_FILIAL = '" +xFilial("QI5") +"' AND "
	cQuery += "	QI5.QI5_PROJET = AFA.AFA_PROJET AND QI5.QI5_TAREFA = AFA.AFA_TAREFA) AS QI5_TPACAO, "

	//-- Subquery para obter o total de horas apontadas para a tarefa
	cQuery += "(SELECT SUM(AFU.AFU_HQUANT) FROM " +RetSQLName("AFU") +" AFU WHERE "
	cQuery += "AFU.D_E_L_E_T_ <> '*' AND AFU.AFU_FILIAL = '" +xFilial("AFU") +"' AND "
	cQuery += "AFU.AFU_PROJET = AFA.AFA_PROJET AND AFU.AFU_REVISA = AFA.AFA_REVISA AND "
	cQuery += "AFU.AFU_TAREFA = AFA.AFA_TAREFA AND AFU.AFU_RECURS = AFA.AFA_RECURS) AS AFU_HQUANT "

	cQuery += "FROM " +RetSQLName("AFA") +" AFA "

	cQuery += "JOIN " +RetSQLName("AF9") +" AF9 ON "
	cQuery += "AF9.D_E_L_E_T_ <> '*' AND AF9.AF9_FILIAL = '" +xFilial("AF9") +"' AND "
	cQuery += "AF9.AF9_PROJET = AFA.AFA_PROJET AND AF9.AF9_REVISA = AFA.AFA_REVISA AND "
	cQuery += "AF9.AF9_TAREFA = AFA.AFA_TAREFA "

	cQuery += "WHERE AFA.D_E_L_E_T_ <> '*' AND AFA.AFA_FILIAL = '" +xFilial("AFA") +"' AND "
	cQuery += "(AFA.AFA_START BETWEEN '" +DToS(mv_par02) +"' AND '" +DToS(mv_par03) +"' OR "
	cQuery += "AFA.AFA_FINISH BETWEEN '" +DToS(mv_par02) +"' AND '" +DToS(mv_par03) +"') AND "
	
	If !Empty(mv_par01) //-- Filtra projeto
		cQuery += "AFA.AFA_PROJET = '" +mv_par01 +"' AND "
	EndIf
	
	If !Empty(mv_par05) //-- Filtra recurso
		cQuery += "AFA.AFA_RECURS = '" +mv_par05 +"' AND "
	ElseIf !Empty(mv_par04) //-- Filtra equipe
		cQuery += "AFA.AFA_RECURS IN "
		
		//-- Subquery para obter os recursos da equipe filtrada
		cQuery += "(SELECT AE8.AE8_RECURS FROM " +RetSQLName("AE8") +" AE8 WHERE "
		cQuery += "AE8.D_E_L_E_T_ <> '*' AND AE8.AE8_FILIAL = '" +xFilial("AE8") +"' AND "
		cQuery += "AE8.AE8_EQUIP = '" +mv_par04 +"') AND "
	EndIf
	
	cQuery += "AFA.AFA_REVISA = "
	
	//-- Subquery para obter a revisao atual do projeto
	cQuery += "(SELECT AF8.AF8_REVISA FROM " +RetSQLName("AF8") +" AF8 "
	cQuery += "	WHERE AF8.D_E_L_E_T_ <> '*' AND AF8.AF8_FILIAL = '" +xFilial("AF8") +"' AND "
	cQuery += "	AF8.AF8_PROJET = AFA.AFA_PROJET) "
EndIf

If (aChecks[1] .Or. aChecks[2] .Or. aChecks[3] .Or. aChecks[6]) .And. (aChecks[4] .Or. aChecks[5])
	cQuery += "UNION "
EndIf

If aChecks[4] .Or. aChecks[5]
	//-- Campos com os detalhes da tarefa
	cQuery += "SELECT 'QI5' AS TABALIAS, QI2.QI2_FNC AS AF9_FNC, QI2.QI2_REV AS AF9_REVFNC, "
	cQuery += "QI5.QI5_CODIGO AS AF9_ACAO, QI5.QI5_REV AS AF9_REVACA, QI5.QI5_PROJET AS AFA_PROJET, "
	cQuery += "' ' AS AFA_REVISA, QI5.QI5_TAREFA AS AFA_TAREFA, QAA.QAA_RECUR AS AFA_RECURS, "
	cQuery += "' ' AS AF9_DESCRI, ' ' AS AFA_START, ' ' AS AFA_HORAI, ' ' AS AFA_FINISH, "
	cQuery += "' ' AS AFA_HORAF, 0 AS AFA_QUANT, QI5.QI5_OBRIGA, QI2.QI2_NCHAMA, QI5.QI5_TPACAO, "
	cQuery += "0 AS AFU_HQUANT "

	cQuery += " FROM " +RetSQLName("QI5") +" QI5, "
	cQuery += RetSQLName("QI2") + " QI2, "
	cQuery += RetSQLName("QAA") + " QAA "
	cQuery += " WHERE QI2.D_E_L_E_T_ <> '*' AND "
	cQuery += " QAA.D_E_L_E_T_ <> '*' AND "
	
	//cQuery += "JOIN	" +RetSQLName("QI2") +" QI2 ON QI2.D_E_L_E_T_ <> '*' AND "
	cQuery += "QI2.QI2_FILIAL = '" +xFilial("QI2") +"' AND QI2.QI2_CODACA = QI5.QI5_CODIGO AND "
	cQuery += "QI2.QI2_REVACA = QI5.QI5_REV " //AND QI2.QI2_OBSOL <> 'S' "

	//cQuery += "JOIN	" +RetSQLName("QAA") +" QAA ON QAA.D_E_L_E_T_ <> '*' AND "
	cQuery += " AND QAA.QAA_FILIAL = QI5.QI5_FILMAT AND QAA.QAA_MAT = QI5.QI5_MAT "

	If !Empty(mv_par05) //-- Filtra recurso
		cQuery += "AND QAA.QAA_RECUR = '" +mv_par05 +"' "
	ElseIf !Empty(mv_par04) //-- Filtra equipe
	
		cQuery += "AND QAA.QAA_RECUR IN "
		
		//-- Subquery para obter os recursos da equipe filtrada
		cQuery += "(SELECT AE8.AE8_RECURS FROM " +RetSQLName("AE8") +" AE8 WHERE "
		cQuery += "AE8.D_E_L_E_T_ <> '*' AND AE8.AE8_FILIAL = '" +xFilial("AE8") +"' AND "
		cQuery += "AE8.AE8_EQUIP = '" +mv_par04 +"') "
	EndIf

	//cQuery += "WHERE QI5.D_E_L_E_T_ <> '*' AND QI5.QI5_FILIAL = '" +xFilial("QI5") +"' AND "
	cQuery += " AND QI5.D_E_L_E_T_ <> '*' AND QI5.QI5_FILIAL = '" +xFilial("QI5") +"' AND "
	cQuery += "QI5.QI5_TAREFA = ' ' AND "
	
	If !Empty(mv_par01) //-- Filtra projeto
		cQuery += "QI5.QI5_PROJET = '" +mv_par01 +"' AND "
	EndIf
	
	cQuery += "QI5.QI5_SEQ > ("
	                          
	//-- Subquery para obter a ultima sequencia executada do plano de acao
	cQuery += "SELECT "
	
	Do Case
	Case "DB2" $ cBanco
		cQuery += "COALESCE"
	Case "ORACLE" $ cBanco  
  		cQuery += "NVL"
	Otherwise
 		cQuery += "ISNULL"
	EndCase

	cQuery += "(MAX(QI5TMP.QI5_SEQ),'zz') FROM " +RetSQLName("QI5") +" QI5TMP WHERE "
	cQuery += "QI5TMP.D_E_L_E_T_ <> '*' AND QI5TMP.QI5_FILIAL = '" +xFilial("QI5") +"' AND "
	cQuery += "QI5TMP.QI5_CODIGO = QI5.QI5_CODIGO AND QI5TMP.QI5_REV = QI5.QI5_REV AND "
	cQuery += "QI5TMP.QI5_TAREFA <> ' ' AND QI5TMP.QI5_STATUS NOT IN ('4','5') "
	
	cQuery += ") "
EndIf

If !Empty(cQuery)
	cQuery += "ORDER BY AFA_START, AFA_HORAI, AFA_FINISH, AFA_HORAF"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)   
	
	TCSetField("TRB","AFA_START","D",8,0)
	TCSetField("TRB","AFA_FINISH","D",8,0)
	TCSetField("TRB","AFA_QUANT","N",TamSX3("AFA_QUANT")[1],TamSX3("AFA_QUANT")[2])
	TCSetField("TRB","AFU_HQUANT","N",TamSX3("AFU_HQUANT")[1],TamSX3("AFU_HQUANT")[2])
	
	TRB->(dbEVal({|| nTotRec += 1},{|| .T.},{|| !EOF()}))
	TRB->(dbGoTop())
	ProcRegua(nTotRec)
	
	While !TRB->(EOF())
		IncProc()
				
		//-- Atribui legenda
		If TRB->TABALIAS == "AF9"
			nPercAF9 := TRB->(PmsPOCAF9(AFA_PROJET,AFA_REVISA,AFA_TAREFA,dDataBase))

			If nPercAF9 == 100
				nLegend := 6
			ElseIf dDataBase > TRB->AFA_START .Or. (dDataBase == TRB->AFA_START .And. Substr(Time(),1,5) > TRB->AFA_HORAI)
				nLegend := 3
			ElseIf Empty(nPercAF9)
				nLegend := 2
			Else
				nLegend := 1
			EndIf
		Else
			nPercAF9 := 0

			If TRB->QI5_OBRIGA == '1'
				nLegend := 4
			Else
				nLegend := 5
			EndIf
		EndIf
		
		If aChecks[nLegend]
			nCol := 0
			aAdd(aDados,Array(17))
			aTail(aDados)[++nCol] := nLegend
			If nQTMKPMS == 4
				aTail(aDados)[++nCol] := Transform(TRB->QI2_NCHAMA,PesqPict("QI2","QI2_NCHAMA"))
			EndIf
			aTail(aDados)[++nCol] := If(!Empty(TRB->AF9_FNC),Transform(TRB->AF9_FNC,PesqPict("QI2","QI2_FNC")),"")
			aTail(aDados)[++nCol] := TRB->AF9_REVFNC
			aTail(aDados)[++nCol] := If(!Empty(TRB->AF9_ACAO),Transform(TRB->AF9_ACAO,PesqPict("QI3","QI3_CODIGO")),"")
			aTail(aDados)[++nCol] := TRB->AF9_REVACA
			aTail(aDados)[++nCol] := TRB->AFA_PROJET
			aTail(aDados)[++nCol] := TRB->AFA_TAREFA
			aTail(aDados)[++nCol] := Posicione("QID",1,xFilial("QID")+TRB->QI5_TPACAO,"QID_DESCTP")
			aTail(aDados)[++nCol] := Posicione("AE8",1,xFilial("AE8")+TRB->AFA_RECURS,"AE8_DESCRI")
			
			cEtpAtu  := ""
			cRespAtu := ""
			
			If TRB->TABALIAS == "QI5" .Or. nLegend == 6
				QI5->(dbSeek(xFilial("QI5")+TRB->(AF9_ACAO+AF9_REVACA)))
				While !QI5->(EOF()) .And. QI5->(QI5_FILIAL+QI5_CODIGO+QI5_REV) == xFilial("QI5")+TRB->(AF9_ACAO+AF9_REVACA)
					If !Empty(QI5->QI5_TAREFA) .And. !(QI5->QI5_STATUS $ '45')
						QAA->(dbSeek(QI5->(QI5_FILMAT+QI5_MAT)))
						cEtpAtu  := Posicione("QID",1,xFilial("QID")+QI5->QI5_TPACAO,"QID_DESCTP")
						cRespAtu := Posicione("AE8",1,xFilial("AE8")+QAA->QAA_RECUR,"AE8_DESCRI")
						Exit
					EndIf
					QI5->(dbSkip())
				End
			EndIf
			
			If TRB->TABALIAS == "AF9"
				If nLegend < 6
					aTail(aDados)[++nCol] := Posicione("QID",1,xFilial("QID")+TRB->QI5_TPACAO,"QID_DESCTP")
					aTail(aDados)[++nCol] := Posicione("AE8",1,xFilial("AE8")+TRB->AFA_RECURS,"AE8_DESCRI")
				Else
					aTail(aDados)[++nCol] := cEtpAtu
					aTail(aDados)[++nCol] := cRespAtu
				EndIf
			Else
				aTail(aDados)[++nCol] := cEtpAtu
				aTail(aDados)[++nCol] := cRespAtu
			EndIf
			aTail(aDados)[++nCol] := TRB->AF9_DESCRI
			
			If TRB->TABALIAS == "AF9"
				aTail(aDados)[++nCol] := TRB->(DToC(AFA_START) +"," +AFA_HORAI +" at้ " +DToC(AFA_FINISH) +"," +AFA_HORAF)
			Else
				aTail(aDados)[++nCol] := STR0030 //Indeterminado
			EndIf
			
			aTail(aDados)[++nCol] := Str(nPercAF9,3) +"%"
			aTail(aDados)[++nCol] := Transform(TRB->AFA_QUANT,PesqPict("AFA","AFA_QUANT"))
			aTail(aDados)[++nCol] := Transform(TRB->AFU_HQUANT,PesqPict("AFU","AFU_HQUANT"))
			
			nTotPrev += TRB->AFA_QUANT
			nTotApon += TRB->AFU_HQUANT
		EndIf
		
		TRB->(dbSkip())
	End
	TRB->(dbCloseArea())
EndIf

//-- Para nao gerar erro
If Empty(aDados)
	aAdd(aDados,{0,"","","","","","","","","","","","","","","",""})
EndIf

aSort(aDados,,,{|x,y| x[nColOrd] < y[nColOrd]})

If ValType(oBrowse) == "O"
	oBrowse:SetArray(aDados)
	oBrowse:bLine := bLine
	
	uTotPrev:SetText(STR0028 +Transform(nTotPrev,"@E 99,999,999,999.99")) //Total de horas previstas:
	uTotApon:SetText(STR0029 +Transform(nTotApon,"@E 99,999,999,999.99")) //Total de horas apontadas:
	uTotPrev:Refresh()
	uTotApon:Refresh()
Else
	uTotPrev := nTotPrev
	uTotApon := nTotApon
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200VisualบAutor  ณ Andre Anjos        บ Data ณ  21/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa visualizacao do chamado, FNC ou Plano de acao.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpc: opc visualizacao: 1-Chamado,2-FNC,3-Plano,4-Tarefa.  บฑฑ
ฑฑบ			 ณ oBrowse: objeto de navegacao das tarefas.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200Visual(nOpc,oBrowse)
Private INCLUI  := .F.
Private ALTERA  := .F.

Do Case
	Case nOpc == 1 .And. !Empty(oBrowse:aArray[oBrowse:nAt,2])
		ADE->(dbSetOrder(1))
		If ADE->(dbSeek(xFilial("ADE")+oBrowse:aArray[oBrowse:nAt,2]))
			TK503AOpc("ADE",ADE->(Recno()),2)
		EndIf
	Case nOpc == 2 .And. !Empty(oBrowse:aArray[oBrowse:nAt,3])
		aRotina := STATICCALL(QNCA040,MenuDef)
		QI2->(dbSetOrder(2))
		If QI2->(dbSeek(xFilial("QI2")+StrTran(oBrowse:aArray[oBrowse:nAt,3],"/","")+oBrowse:aArray[oBrowse:nAt,4]))
			QNC040Alt("QI2",QI2->(Recno()),2)
		EndIf
	Case nOpc == 3 .And. !Empty(oBrowse:aArray[oBrowse:nAt,5])
		aRotina := STATICCALL(QNCA030,MenuDef)
		QI3->(dbSetOrder(2))
		If QI3->(dbSeek(xFilial("QI3")+StrTran(oBrowse:aArray[oBrowse:nAt,5],"/","")+oBrowse:aArray[oBrowse:nAt,6]))
			QNC030Alt("QI3",QI3->(Recno()),2)
		EndIf
	Case nOpc == 4 .And. !Empty(oBrowse:aArray[oBrowse:nAt,7])
		AF8->(dbSetOrder(1))
		AF8->(dbSeek(xFilial("AF8")+oBrowse:aArray[oBrowse:nAt,7]))
		AF9->(dbSetOrder(1))
		If AF9->(dbSeek(xFilial("AF9")+AF8->(AF8_PROJET+AF8_REVISA)+oBrowse:aArray[oBrowse:nAt,8]))
			PMSA203(2,,"000")
		EndIf
EndCase

oBrowse:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200IniPesบAutor  ณ Andre Anjos        บ Data ณ  03/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que prepara o get de pesquisa para receber o        บฑฑ
ฑฑบ          ณ conteudo conforme escolha no combo                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpcPesq: opcao selecionada no combo de pesquisa			  บฑฑ
ฑฑบ			 ณ cValPesq: variavel utilizada pelo get de pesquisa		  บฑฑ
ฑฑบ			 ณ oGet: objeto do get de pesquisa							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200IniPes(nOpcPesq,cValPesq,oGet)
Local nQTMKPMS := SuperGetMV("MV_QTMKPMS",.F.,1)

If nQTMKPMS # 4
	nOpcPesq += 1
EndIf

Do Case
	Case nOpcPesq == 1
		cValPesq := Space(TamSX3("ADE_CODIGO")[1])
	Case nOpcPesq == 2
		cValPesq := Space(TamSX3("QI2_FNC")[1] + 1)
	Case nOpcPesq == 3
		cValPesq := Space(TamSX3("QI3_CODIGO")[1] + 1)
	Case nOpcPesq == 4 .Or. nOpcPesq == 5
		cValPesq := Space(TamSX3("QI5_DESCTP")[1])
	Case nOpcPesq == 6 .Or. nOpcPesq == 7
		cValPesq := Space(TamSX3("AE8_DESCRI")[1])
	Case nOpcPesq == 8
		cValPesq := Space(TamSX3("AF9_DESCRI")[1])
EndCase

oGet:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200PesquiบAutor  ณ Andre Anjos		 บ Data ณ  19/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza a pesquisa de um item no browse                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oBrowse: objeto com as tarefas							  บฑฑ
ฑฑบ			 ณ nOpcPesq: indica qual a coluna de busca					  บฑฑ
ฑฑบ			 ณ cValPesq: indica qual a o conteudo procurado.			  บฑฑ
ฑฑบ			 ณ lPesqEx: indica se a busca e exata.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200Pesqui(oBrowse,nOpcPesq,cValPesq,lPesqEx)
Local nPosCol := 0
Local nLinPes := 0
Local nQTMKPMS := SuperGetMV("MV_QTMKPMS",.F.,1)

If nQTMKPMS # 4
	nOpcPesq += 1
EndIf

Do Case
	Case nOpcPesq == 1
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == RetTitle("QI2_NCHAMA")})
	Case nOpcPesq == 2
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == RetTitle("QI2_FNC")})
	Case nOpcPesq == 3
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == RetTitle("QI3_CODIGO")})
	Case nOpcPesq == 4
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == RetTitle("QI5_DESCTP")})
	Case nOpcPesq == 5
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == "Responsแvel"})
	Case nOpcPesq == 6
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == "Etapa Atual"})
	Case nOpcPesq == 7
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == "Resp. Atual"})
	Case nOpcPesq == 8
		nPosCol := aScan(oBrowse:aHeaders,{|x| x == RetTitle("AF9_DESCRI")})
EndCase

nLinPes := aScan(oBrowse:aArray, {|x| If(lPesqEx,AllTrim(x[nPosCol]) == AllTrim(cValPesq),cValPesq $ x[nPosCol])})

If !Empty(nLinPes)
	oBrowse:nAt := nLinPes
	oBrowse:nColPos := nPosCol
	oBrowse:SetFocus()
	oBrowse:Refresh()
Else
	Aviso(STR0002,STR0031,{"OK"}) //A pesquisa nใo encontrou resultados.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQA200Perg บAutor  ณ Andre Anjos		 บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao chamada ao teclar F12 para exibicao das perguntas   บฑฑ
ฑฑบ          ณ e execucao de nova pesquisa.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aDados: array com os dados a serem apresentados no browse. บฑฑ
ฑฑบ			 ณ oTotPrev: objeto totalizador das horas previstas. 		  บฑฑ
ฑฑบ			 ณ oTotApon: objeto totalizador das horas apontadas. 		  บฑฑ
ฑฑบ			 ณ oBrowse: objeto browse de exibicao dos resultados. 		  บฑฑ
ฑฑบ			 ณ aParams: array para filtro das tarefas por status. 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QA200Perg(aDados,oTotPrev,oTotApon,oBrowse,aParams,nColOrd)
Local lValid  := .F.
Local aChecks  := {.F.,.F.,.F.,.F.,.F.,.F.}

Private cAE8EQP   := Space(TamSX3("AE8_EQUIP")[1])

Pergunte("QNC200",.F.)
cAE8EQP := mv_par04

//-- Parametros
While !lValid
	If !Pergunte("QNC200",.T.) .Or. (lValid := (mv_par03 - mv_par02 <= 90))
		If lValid
			lValid := ParamBox(aParams,STR0032,@aChecks) //Exibir tarefas...
		EndIf
		Exit
	EndIf		
	Aviso(STR0002,STR0033,{"OK"}) //O intervalo de data nใo pode ultrapassar 90 dias.
End

//-- Se param validos, processa
If lValid
	Processa({|| Q200Proces(@aDados,@oTotPrev,@oTotApon,@oBrowse,aChecks,nColOrd)},STR0001,STR0034,.F.) //Aguarde, processando pesquisa...
EndIf

Return lValid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200LegendบAutor  ณAndre Anjos		 บ Data ณ  19/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a legenda dos itens do browse.       				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200Legend(nLin)
Local aLegenda := {}
Local uRet     := NIL

aAdd(aLegenda,{'BR_VERDE',STR0035}) 		//Tarefa pendente
aAdd(aLegenda,{'BR_AMARELO',STR0036})		//Tarefa na fila
aAdd(aLegenda,{'BR_VERMELHO',STR0037})		//Tarefa atrasada
aAdd(aLegenda,{'BR_LARANJA',STR0038})		//Tarefa futura
aAdd(aLegenda,{'BR_BRANCO',STR0039})		//Tarefa potencial
aAdd(aLegenda,{'BR_AZUL',STR0040})			//Tarefa concluํda

If ValType(nLin) == "N"
	If nLin > 0
		uRet := LoadBitmap(GetResources(),aLegenda[nLin,1])
	Else
		uRet := ""
	EndIf
Else
	BrwLegenda(STR0001,STR0013,aLegenda) //Tarefa X Recurso		Legenda
EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQC200InEQPบAutor  ณ Andre Anjos		 บ Data ณ  28/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Preenche variavel private cAE8EQP utilizada na SXB do rec. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QC200InEQP()
Local lRet := ExistCpo('AED',mv_par04,1)

If lRet
	cAE8EQP := mv_par04
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ200OrdenaบAutor  ณAndre				 บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ordena as linhas do browse.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Q200Ordena(oBrowse,aDados,nColOrd,aColunas)
Local bLine   := oBrowse:bLine
Local aOpcoes := {}
Local aParams := {}
Local aOpc    := {nColOrd-1}

aEval(aColunas,{|x| If(Empty(x),Nil,aAdd(aOpcoes,x))})
aAdd(aParams,{3,"Ordenar por",aOpc[1],aOpcoes,70,NIL,.T.,NIL}) //Ordenar por

If ParamBox(aParams,"Reordenar",@aOpc)
	nColOrd := aOpc[1] + 1
	aSort(aDados,,,{|x,y| x[nColOrd] < y[nColOrd]})
	oBrowse:SetArray(aDados)
	oBrowse:bLine := bLine
	oBrowse:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQC200VlRecบAutor  ณ Andre Anjos        บ Data ณ  28/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida a digitacao do recurso na pergunte.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QNCA200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QC200VlRec()
Local lRet := .T.

AE8->(dbSetOrder(1))
If !AE8->(dbSeek(xFilial("AE8")+mv_par05)) .Or. AE8->AE8_EQUIP # cAE8EQP
	Help(" ",1,"REGNOIS")
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑบPrograma  ณ QNC200STS บAutor  ณAdriano da Silva      ณ Data ณ 31/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบDesc.     ณ Retorna o Status das Tarefas para os Leds da Legenda       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QNC200STS(cCodaca,cRevaca,cTpacao,cSeq)                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1= Codigo do Plano de A็ใo                             ณฑฑ
ฑฑณ          ณ ExpC2= Revisใo do Plano de A็ใo                            ณฑฑ
ฑฑณ          ณ ExpC3= Etapa do Plano de A็ใo                              ณฑฑ
ฑฑณ          ณ ExpC4= Sequencia do Plano de A็ใo                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบRetorno   ณ ExpA1: Array: [1]: Codigo da Legenda                       ณฑฑ
ฑฑบ          ณ ExpA2: Array: [2]: Data Inicial do SLA                     ณฑฑ
ฑฑบ          ณ ExpA3: Array: [3]: Hora Inicial do SLA                     ณฑฑ
ฑฑบ          ณ ExpA4: Array: [4]: Data Final do SLA                       ณฑฑ
ฑฑบ          ณ ExpA5: Array: [5]: Hora Final do SLA                       ณฑฑ
ฑฑบ          ณ ExpA6: Array: [6]: Percentual Informado na Tabela AFF      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QNCXFUN	                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function QNC200STS(cCodaca,cRevaca,cTpacao,cSeq)
Local aArea	  	:= GetArea()
Local aAuxRet 	:= {}
Local aPlanos 	:= {}
Local aDtPlan 	:= {}
Local nX      	:= 0
Local nPos	  	:= 0
Local aStatus 	:= {}
Local nQuantAFF := 0
Local nDurDate	:= 0
Local nDurTarf 	:= 0
Local nPerc 	:= 0
Local nHoraFin 	:= 0
Local nHoraDat  := 0
Local lStart	:= .F.
Local dDatIni	:= Date()
Local dDatFin	:= dDatIni
Local cHorIni	:= "00:00"
Local cHorFin	:= "00:00"
Local cRet		:= "2"
Local nQtdAFF	:= 0
Local nHorIni   := 0
Local nHorAtu   := 0

aAreaAF9 := AF9->(GetArea())


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Query para pesquisar os planos de acao para o calculo de SLA de cada Plano   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery :=" SELECT QI5_FILIAL, QI5_CODIGO, QI5_REV, QI5_SEQ, QI5_TPACAO, QI5_PRZHR, QI5_PROJET "
cQuery +=" FROM " + RetSQLName("QI5") + " QI5 "
cQuery +=" WHERE QI5.QI5_FILIAL='"+xFilial("QI5")+"' " 
cQuery +=" AND QI5.QI5_CODIGO='"+cCodaca+"' " 
cQuery +=" AND QI5.QI5_REV='"+cRevaca+"' " 
cQuery +=" AND QI5.D_E_L_E_T_ <> '*' "

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,3"
Else
	cQuery += " ORDER BY " + SqlOrder("QI5_FILIAL+QI5_CODIGO+QI5_REV")
Endif	
		
cQuery := ChangeQuery(cQuery)								
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPAF9",.T.,.T.)
    
TMPAF9->(dbGoTop())
While TMPAF9->(!EOF())
	dbSelectArea("AF9")	//Tarefas do Projeto
	dbSetOrder(6)		//AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO
	If dbSeek(xFilial("AF9")+PadR(AllTrim(cCodaca),TamSx3("AF9_ACAO")[1])+PadR(AllTrim(cRevaca),TamSx3("AF9_REVACA")[1]))
		aAdd(aPlanos,	{TMPAF9->QI5_CODIGO,;		//1-Plano de Acao
						TMPAF9->QI5_REV,;			//2-Revisใo do Plano de Acao
						TMPAF9->QI5_SEQ,;			//3-Sequencia do Plano de Acao
						TMPAF9->QI5_TPACAO,;		//4-Etapa do Plano de Acao
						TMPAF9->QI5_PRZHR,;		//5-Prazo de Horas do Plano
						TMPAF9->QI5_PROJET,;		//6-Projeto 
						AF9->AF9_CALEND,;			//7-Calendario
						AF9->AF9_START,;			//8-Data Inicial
						AF9->AF9_HORAI,;			//9-Hora Inicial
						AF9->AF9_FINISH,;			//10-Data Final
						AF9->AF9_HORAF})			//11-Hora Final
        EndIf
	TMPAF9->(DbSkip())
EndDo
TMPAF9->(DbCloseArea())


For nX:= 1 To Len(aPlanos)
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso seja a Primeira posicao, adiciono do Array para o calculo do SLA a partir da data Final  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nX == 1
		aAdd(aDtPlan,	{aPlanos[nX][1],;		//1-Plano de Acao
						aPlanos[nX][2],;		//2-Revisใo do Plano de Acao
						aPlanos[nX][3],;		//3-Sequencia do Plano de Acao
						aPlanos[nX][4],;		//4-Etapa do Plano de Acao
						aPlanos[nX][5],;		//5-Prazo de Horas do Plano
						aPlanos[nX][6],;		//6-Projeto 
						aPlanos[nX][7],;		//7-Calendario
						aPlanos[nX][8],;		//8-Data Inicial
						aPlanos[nX][9],;		//9-Hora Inicial
						aPlanos[nX][10],;		//10-Data Final
						aPlanos[nX][11]})		//11-Hora Final
	Else	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Funcao que Retorna as Horas (Caracter) em Numerico ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nQI5InHrs := QNCPrzHR2(aPlanos[nX][5] ,"H","H","D","H")
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Funcao que Retorna as datas finais a partit de data e hora inicial  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAuxRet	:= PMSDTaskF(aDtPlan[nX-1][10],aDtPlan[nX-1][11],aPlanos[nX][7],nQI5InHrs,aPlanos[nX][6],Nil)			
		aAdd(aDtPlan,	{aPlanos[nX][1],;		//1-Plano de Acao
						aPlanos[nX][2],;		//2-Revisใo do Plano de Acao
						aPlanos[nX][3],;		//3-Sequencia do Plano de Acao
						aPlanos[nX][4],;		//4-Etapa do Plano de Acao
						aPlanos[nX][5],;		//5-Prazo de Horas do Plano
						aPlanos[nX][6],;		//6-Projeto 
						aPlanos[nX][7],;		//7-Calendario
						aAuxRet[1],;			//8-Data Inicial
						aAuxRet[2],;			//9-Hora Inicial
						aAuxRet[3],;			//10-Data Final
						aAuxRet[4] })			//11-Hora Final
	EndIf
Next nX

dbSelectArea("AF9")	//Tarefas do Projeto
DbSetOrder(6)		//AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO
If dbSeek(xFilial("AF9")+PadR(AllTrim(cCodaca),TamSx3("QI5_CODIGO")[1])+AllTrim(cRevaca)+PadR(AllTrim(cTpacao),TamSx3("QI5_TPACAO")[1]))
	If !Empty(AF9->AF9_DTATUI)
		dbSelectArea("AFF")	//Confirma็๕es
		aAreaAFF := AFF->(GetArea())
		dbSetOrder(1)		//AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
		If dbSeek(AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
	        nQtdAFF := NoRound(AFF->AFF_QUANT*100,2)
			lStart := .T.
	    EndIf
		RestArea(aAreaAFF)
	EndIf
EndIf

nPos := aScan(aDtPlan,{|x| Trim(x[1]) == AllTrim(cCodaca) .And. Trim(x[2]) == AllTrim(cRevaca) .And. Trim(x[4]) == AllTrim(cTpacao) }) 

If nPos > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Funcao que Retorna as datas finais a partit de data e hora inicial  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nDurDate := PmsHrsItv2(aDtPlan[nPos][8],aDtPlan[nPos][9],Date(),SubStr(time(),1,5),aDtPlan[nPos][7],aDtPlan[nPos][6],,,)
		
	nDurTarf 	:= QNCPrzHR2(aDtPlan[nPos][5] ,"H","H","D","H")
	nPerc 		:= (nDurDate/nDurTarf)*100
	dDatIni		:= aDtPlan[nPos][8]
	dDatFin		:= aDtPlan[nPos][10]
	cHorIni		:= aDtPlan[nPos][9]
	cHorFin		:= aDtPlan[nPos][11]
	
	If nDurDate > nDurTarf //Periodo de Horas do Sistema Maior que o Periodo de Horas da Tarefa
    	cRet := "2" //Tarefa Atrasada
    EndIf
    
    If nDurDate < nDurTarf //Periodo de Horas do Sistema Menor que o Periodo de Horas da Tarefa   	
    	If lStart	//Tarefas jแ iniciadas e com percentuais informados.
        	If aDtPlan[nPos][8] <= Date() .And. aDtPlan[nPos][10] >= Date() //Data do Sistema esteja na Vig๊ncia do SLA
        		If nQtdAFF == nPerc	//Percentual da Tarefa igual ao Percentual Calculado
        	    	cRet := "1"	//Tarefa em Andamento
        	    EndIf
        	 	If nQtdAFF < nPerc	//Percentual da Tarefa Menor que o Percentual Calculado
        	    	cRet := "2"	//Tarefa Atrasada
        	    EndIf
        	 	If nQtdAFF > nPerc	//Percentual da Tarefa Menor que o Percentual Calculado
        	    	cRet := "3"	//Tarefa Adiantada
        	    EndIf
        	EndIf
        	If Date() < aDtPlan[nPos][8] .And. Date() <aDtPlan[nPos][10]	//Data do Sistema esteja Menor que a Vig๊ncia do SLA
				cRet := "3"	//Tarefa Adiantada	        
     		EndIf
        Else
			If dDatIni >  Date()
				cRet := "3" //Tarefa Adiantada			
			Else
				If dDatIni == Date()
					nHorIni := QNCPrzHR2(aDtPlan[nPos][9] ,"H","H","D","H") 
					nHorAtu := QNCPrzHR2(SubStr(time(),1,5) ,"H","H","D","H")  
					If nHorAtu > nHorIni 
						cRet := "2" //Tarefa Atrasada
				    ElseIf nHorIni == nHorAtu
						cRet := "1" //Tarefa Em Andamento
					Else 
						cRet := "3" //Tarefa Adiantada
				    EndIf
				Else
					cRet := "2" //Tarefa Atrasada        	    					
				EndIf
			EndIf
       	EndIf            
	EndIf
EndIf

RestArea(aAreaAF9)
RestArea(aArea)

Return ({cRet,dDatIni,cHorIni,dDatFin,cHorFin,nQtdAFF})
