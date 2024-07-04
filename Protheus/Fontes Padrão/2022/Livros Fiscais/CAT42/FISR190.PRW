#Include "FISR190.ch"
#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR190()

Relatório de conferência.
PORTARIA CAT 42/2018 - SISTEMA DE APURAÇÃO E RESSARCIMENTO OU 
COMPLEMENTO DO ICMS RETIDO POR SUBSTITUIÇÃO TRIBUTÁRIA. 
Esta rotina gera o relatório de conferência da apuração.

@author Eduardo Vicente da Silva
@since 21/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISR190()
Local cPerg := "FISR190"

If Pergunte(cPerg, .T.)
	FwMsgRun(,{|oSay| FR190Proc(oSay) },STR0001,"")	 //"Relatório de Conferência"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FR190Proc()

Processamento dos registros.

@author Eduardo Vicente da Silva
@since 21/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FR190Proc(oSay)
Local oExcel  		:= FWMSEXCEL():New()
Local cAnoMesDe		:= MV_PAR01
Local cAnoMesAte	:= MV_PAR02
Local cProdutoDe	:= MV_PAR03
Local cProdutoAte	:= MV_PAR04
Local cDir			:= AllTrim(MV_PAR05)
Local cArq	  		:= AllTrim(MV_PAR06)
Local cArquivo		:= ""
Local cQuery  		:= ""
Local cAlias  		:= GetNextAlias()
Local cContrib		:= SM0->M0_NOMECOM
Local cIE			:= SM0->M0_INSC
Local cCabec		:= ""
Local lConcFil	  	:= SUPERGETMV('MV_COFLSPD', .F., .T.)
Local cFilProd    	:= Iif(lConcFil,xFilial("SB1"),"")
Local cPartic		:= ""
Local cProd			:= ""
Local nMovto		:= MV_PAR07
Local cTpReg		:= ""
Local cWhere		:= ""
Local nQtdMov		:= 0
Local nTotSup		:= 0
Local nVRessa 		:= 0
Local nVCompl 		:= 0
Local nVCredi 		:= 0
Local nIcmEfeS		:= 0
Local nIcmEfeE		:= 0
Local cEnqLeg 		:= ""
Local nQtdMovE		:= 0
Local nTotSupE		:= 0
Local nQtdMovS		:= 0
Local nTotSupS		:= 0
Local nUniSupS		:= 0
Local cPerPrdAnt	:= ""
Local nOrdem		:= 0
Local aDados        := {}
Local aSldIni		:= {}

AtualizaMsg( oSay, STR0002 ) //"Selecionando os registros do relatório"

If Substr(cDir,Len(cDir), 1) != "\"
	cDir += "\"
EndIf

If At(Upper(cArq),".XML") == 0
	cArq += ".xml"
EndIf

cArquivo := cDir+ cArq

If File(cArquivo)
	If MsgYesNo(STR0003) //"O arquivo ja existe! Deseja substituir?"
		If fErase(cArquivo) <> 0
			Alert(STR0004) //"Erro na exclusão do Arquivo. Verifique se o arquivo não está em uso."
			Return			
		EndIf
	Else
		Return
	EndIf	
EndIf

cWhere := " F2U.F2U_FILIAL = " + ValToSql(xFilial("F2U"))
cWhere += " AND 	F2U.F2U_ANOMES BETWEEN " + ValToSql(cAnoMesDe)  + " AND " + ValToSql(cAnoMesAte)
cWhere += " AND 	F2U.F2U_PRODUT BETWEEN " + ValToSql(cProdutoDe) + " AND " + ValToSql(cProdutoAte)
If nMovto == 1
	cWhere += " AND	F2U.F2U_TPREG  = " + ValToSql("")
ElseIf nMovto == 2
	cWhere += " AND	F2U.F2U_TPREG  = " + ValToSql("1")
EndIf
cWhere += " AND F2U.D_E_L_E_T_ = ' ' "

cWhere := "%" + cWhere + "%"

BeginSql Alias cAlias

	COLUMN F2U_DTMOV AS DATE
        
	SELECT  F2U.F2U_ANOMES,
			F2U.F2U_PRODUT,
			F2U.F2U_ALIQIC,
			F2U.F2U_ORDEM,
			F2U.F2U_DTMOV,
			F2U.F2U_CHVDOC,
			F2U.F2U_SERECF,
			F2U.F2U_TPMOV,
			F2U.F2U_SERIE,
			F2U.F2U_NFISCA,
			F2U.F2U_PARTIC,
			F2U.F2U_LOJA,
			F2U.F2U_CFOP,
			F2U.F2U_ITEM,
			F2U.F2U_QTDMOV,
			F2U.F2U_ENQLEG,
			F2U.F2U_VUISUP,
			F2U.F2U_VTISUP,
			F2U.F2U_ICMEFE,
			F2U.F2U_ICMEFS,
			F2U.F2U_QTDSLD,
			F2U.F2U_VUNSLD,
			F2U.F2U_VTOSLD,
			F2U.F2U_VRESSA,
			F2U.F2U_VCOMPL,
			F2U.F2U_VCREDI,			
            B1_UM,
			F2U.F2U_TIPO
	FROM 	%TABLE:F2U% F2U
	INNER JOIN %TABLE:SB1% SB1 ON SB1.B1_FILIAL = %XFILIAL:SB1% AND SB1.B1_COD = F2U.F2U_PRODUT AND SB1.%NOTDEL%
	WHERE %Exp:cWhere%
	ORDER BY F2U.F2U_ANOMES, F2U.F2U_PRODUT, B1_UM, F2U.F2U_ALIQIC, F2U.F2U_ORDEM
	
EndSql

If (cAlias)->(EOF())
	Alert(STR0005) //"Nenhum registro encontrado com os parâmetros informados."
	Return
EndIf

AtualizaMsg( oSay, STR0006 ) //"Gerando o Relatório"

ImpCabec(@oExcel, @cCabec, cContrib, cIE)

While !(cAlias)->(EOF())

	cProd := (cAlias)->F2U_PRODUT + cFilProd

	If cPerPrdAnt != ((cAlias)->F2U_ANOMES + cProd)
		nOrdem  := 1
		aSldIni := RetSldIni((cAlias)->F2U_ANOMES, (cAlias)->F2U_PRODUT)
		aDados  := {{(cAlias)->F2U_ANOMES, AllTrim(cProd), (cAlias)->B1_UM, (cAlias)->F2U_ALIQIC, StrZero(nOrdem,9), '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, aSldIni[1], aSldIni[2], aSldIni[3], 0, 0, 0, ''}}
		oExcel:AddRow("Plan1",cCabec,aDados[1])
	EndIf
	
	cPartic		:= ""
	cEnqLeg 	:= AllTrim((cAlias)->F2U_ENQLEG)
	nQtdMovE	:= 0
	nTotSupE	:= 0
	nQtdMovS	:= 0
	nTotSupS	:= 0
	nUniSupS	:= 0
	nOrdem++

	If (cAlias)->F2U_TIPO == 'D'
		nQtdMov := (cAlias)->F2U_QTDMOV * -1 
		nTotSup := (cAlias)->F2U_VTISUP * -1
		nVRessa := (cAlias)->F2U_VRESSA * -1
		nVCompl := (cAlias)->F2U_VCOMPL * -1
		nVCredi := (cAlias)->F2U_VCREDI * -1
		nIcmEfeS:= (cAlias)->F2U_ICMEFS * -1
		nIcmEfeE:= (cAlias)->F2U_ICMEFE * -1
	Else
		nQtdMov := (cAlias)->F2U_QTDMOV
		nTotSup := (cAlias)->F2U_VTISUP
		nVRessa := (cAlias)->F2U_VRESSA
		nVCompl := (cAlias)->F2U_VCOMPL
		nVCredi := (cAlias)->F2U_VCREDI
		nIcmEfeS:= (cAlias)->F2U_ICMEFS
		nIcmEfeE:= (cAlias)->F2U_ICMEFE
	EndIf

	If ((cAlias)->F2U_TPMOV == 'E' .And. (cAlias)->F2U_TIPO != 'D') .Or. ((cAlias)->F2U_TPMOV == 'S' .And. (cAlias)->F2U_TIPO == 'D')
        cPartic 	:= Iif((cAlias)->F2U_TIPO == 'B',"SA1","SA2") + Iif(lConcFil, cFilAnt, "") + (cAlias)->F2U_PARTIC + (cAlias)->F2U_LOJA
		nQtdMovE	:= nQtdMov
		nTotSupE	:= nTotSup
	Else
		cPartic     := Iif((cAlias)->F2U_TIPO == 'B',"SA2","SA1") + Iif(lConcFil, cFilAnt, "") + (cAlias)->F2U_PARTIC + (cAlias)->F2U_LOJA
		nQtdMovS	:= nQtdMov
		nTotSupS	:= nTotSup
		nUniSupS	:= (cAlias)->F2U_VUISUP
	EndIf

	aDados :=  {{(cAlias)->F2U_ANOMES,;
				 AllTrim(cProd),;
				 (cAlias)->B1_UM,;
				 (cAlias)->F2U_ALIQIC,;
				 StrZero(nOrdem,9),;
				 (cAlias)->F2U_DTMOV,;
				 (cAlias)->F2U_CHVDOC,;
				 (cAlias)->F2U_SERECF,;
				 (cAlias)->F2U_TPMOV,;
				 (cAlias)->F2U_SERIE,;
				 (cAlias)->F2U_NFISCA,;
				 cPartic,;
				 (cAlias)->F2U_CFOP,;
				 (cAlias)->F2U_ITEM,;
				 nQtdMovE,;
				 nTotSupE,;
				 nQtdMovS,;
				 nUniSupS,;
				 Iif(cEnqLeg == "1", nTotSup, 0),;
				 Iif(cEnqLeg == "2", nTotSup, 0),;
				 Iif(cEnqLeg == "3", nTotSup, 0),;
				 Iif(cEnqLeg == "4", nTotSup, 0),;
				 Iif(cEnqLeg == "0", nTotSup, 0),;
				 nIcmEfeS,;
				 nIcmEfeE,;
				 (cAlias)->F2U_QTDSLD,;
				 (cAlias)->F2U_VUNSLD,;
				 (cAlias)->F2U_VTOSLD,;
				 nVRessa,;
				 nVCompl,;
				 nVCredi,;
				 Iif((cAlias)->F2U_TIPO == "D", "Sim", "Não")}}

	oExcel:AddRow("Plan1",cCabec,aDados[1])

	cPerPrdAnt := (cAlias)->F2U_ANOMES + cProd

	(cAlias)->(dbSkip())
 
EndDo

(cAlias)->(dbCloseArea())

AtualizaMsg( oSay, STR0007 ) //"Processamento concluído"

oExcel:Activate()
oExcel:GetXMLFile(cArquivo)
If MsgYesNo(STR0009, STR0008) //"Abrir Relatório" //"Deseja abrir o relatório?"
	ShellExecute("Open", cArquivo, "", "XML", 1)
EndIf

aDados  := aSize(aDados ,0)
aSldIni	:= aSize(aSldIni,0)

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec()

Processamento dos registros.

@author Eduardo Vicente da Silva
@since 21/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ImpCabec(oExcel, cCabec, cContrib, cIE)

cCabec := STR0011 + cContrib + STR0010 + cIE //"INSCRIÇÃO ESTADUAL: " //"RELATÓRIO DE CONFERÊCNIA - MERCADORIAS EMQUADRADAS NA SUBSTITUIÇÃO TRIBUTÁRIAS  CONTRIBUINTE: "

oExcel:AddworkSheet("Plan1")

oExcel:AddTable ("Plan1",cCabec)

oExcel:AddColumn("Plan1",cCabec,STR0012,1,1) //"Ano/Mês"
oExcel:AddColumn("Plan1",cCabec,STR0014,1,1) //"Produto"
oExcel:AddColumn("Plan1",cCabec,STR0015,1,1) //"Unidade Medida"
oExcel:AddColumn("Plan1",cCabec,STR0016,1,1) //"Alíquota ICMS"
oExcel:AddColumn("Plan1",cCabec,STR0013,1,1) //"Ordem"
oExcel:AddColumn("Plan1",cCabec,STR0017,1,1) //"Data Movimento"
oExcel:AddColumn("Plan1",cCabec,STR0018,1,1) //"Chave NFE"
oExcel:AddColumn("Plan1",cCabec,STR0019,1,1) //"Número de Série ECF"
oExcel:AddColumn("Plan1",cCabec,STR0020,1,1) //"Tipo do Documento"
oExcel:AddColumn("Plan1",cCabec,STR0021,1,1) //"Série do Documento"
oExcel:AddColumn("Plan1",cCabec,STR0022,1,1) //"Número do Documento"
oExcel:AddColumn("Plan1",cCabec,STR0023,1,1) //"Cliente/Fornecedor"
oExcel:AddColumn("Plan1",cCabec,STR0024,1,1) //"CFOP"
oExcel:AddColumn("Plan1",cCabec,STR0025,1,1) //"Item do Documento"
oExcel:AddColumn("Plan1",cCabec,STR0026,3,2,.T.) //"Quantidade de Entrada"
oExcel:AddColumn("Plan1",cCabec,STR0027,3,2,.T.) //"Valor Total do ICMS Suportado"
oExcel:AddColumn("Plan1",cCabec,STR0043,3,2,.T.) //"Quantidade de Saída"
oExcel:AddColumn("Plan1",cCabec,STR0028,3,2) //"Valor Unitário do ICMS Suportado"
oExcel:AddColumn("Plan1",cCabec,STR0029,3,2,.T.) //"Código Enquadramento Legal = 1"
oExcel:AddColumn("Plan1",cCabec,STR0030,3,2,.T.) //"Código Enquadramento Legal = 2"
oExcel:AddColumn("Plan1",cCabec,STR0031,3,2,.T.) //"Código Enquadramento Legal = 3"
oExcel:AddColumn("Plan1",cCabec,STR0032,3,2,.T.) //"Código Enquadramento Legal = 4"
oExcel:AddColumn("Plan1",cCabec,STR0033,3,2,.T.) //"Código Enquadramento Legal = 0"
oExcel:AddColumn("Plan1",cCabec,STR0034,3,2,.T.) //"ICMS Efetivo na Saída"
oExcel:AddColumn("Plan1",cCabec,STR0042,3,2,.T.) //"ICMS Efetivo na Entrada"
oExcel:AddColumn("Plan1",cCabec,STR0035,3,2) //"Quantidade do Saldo"
oExcel:AddColumn("Plan1",cCabec,STR0036,3,2) //"Valor Unitário do Saldo"
oExcel:AddColumn("Plan1",cCabec,STR0037,3,2) //"Valor Total do Saldo"
oExcel:AddColumn("Plan1",cCabec,STR0038,3,2,.T.) //"Valor do Ressarcimento"
oExcel:AddColumn("Plan1",cCabec,STR0039,3,2,.T.) //"Valor do Complemento"
oExcel:AddColumn("Plan1",cCabec,STR0040,3,2,.T.) //"ICMS - Crédito da Operação Própria"
oExcel:AddColumn("Plan1",cCabec,STR0041,1,1) //"Movto de Devolução"
 
Return

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Eduardo Vicente da Silva
@since 22/11/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg )

oSay:cCaption := (cMsg)
ProcessMessages()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSldIni()

Retorna o Saldo Inicial do produto no início do período.

@author Ulisses P. Oliveira
@since 21/07/2020
@version 
/*/
//-------------------------------------------------------------------
Static Function RetSldIni(cPeriodo, cProduto)
Local aRet := {0,0,0}

F2V->(DbSetOrder(1)) //---1 - F2V_FILIAL+F2V_ANOMES+F2V_PRODUT---//
If F2V->(DbSeek(xFilial("F2V") + cPeriodo + cProduto))
	aRet := {F2V->F2V_QTDSLD, F2V->F2V_VUNSLD, F2V->F2V_VTOSLD}
EndIf

Return aRet