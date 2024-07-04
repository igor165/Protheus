#include "protheus.ch"
#include "report.ch"
#include "ATFR450.ch"




//Verifica se o AVP do ATF esta ativo     
Static lAvpAtf := If(FindFunction("AFAvpAtf"),AFAvpAtf(),.f.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFR450   �Autor  � Ramon Neves        � Data �  09/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Demonstrativo: C�lculo do AVP imobilizado                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFR450()
Local oReport
Local lTReport		:= FindFunction("TRepInUse") .And. TRepInUse()
Local lDefTop		:= IIF( FindFunction("IfDefTopCTB"), IfDefTopCTB(), .F.) // verificar se pode executar query (TOPCONN)

//Controle de AVP de Ativo
Private cPerg		:= "AFR450"
Private aSelFil		:= {}
Private nTotalFil	:= 0  
Private cAliasAvp	:= GetNextAlias() 
Private aSelClass := {}

If lAvpAtf

	If !lDefTop
		Help("  ",1,"AFR450TOP",,STR0001 ,1,0) //"Fun��o dispon�vel apenas para ambientes TopConnect"
		Return
	EndIf

	If !lTReport
		Help("  ",1,"AFR450R4",,STR0009,1,0) //"Fun��o dispon�vel apenas TREPORT"
		Return
	ENdIf

	lRet := Pergunte( cPerg , .T. )

	If lRet
		If mv_par09 == 1 .And. Len( aSelFil ) <= 0
			aSelFil := AdmGetFil()
			If Len( aSelFil ) <= 0
				Return
			EndIf
		EndIf
		
		If mv_par10 == 1 .And. FindFunction("AdmGetClass")
			aSelClass := AdmGetClass()
			If Len( aSelClass ) <= 0
				Return
			EndIf 			
		EndIf	

		oReport := ReportDef()
		oReport:PrintDialog()
	Endif
Else
	Help("  ",1,"AFR450NOFOUND",,STR0002 ,1,0) //"Dicion�rio desatualizado"
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Ramon Neves         � Data �  08/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o LayOut do Relat�rio:C�lculo do AVP do imobilizado  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oSecSN1
Local oSecFNF
Local oSecFIL
Local oBreak2
Local cTitulo	:= STR0003	//"Demonstrativo de C�lculo do AVP do Imobilizado"
Local aOrd		:= {}		//em branco porque n�o se faz necess�rio ordenar nesse relat�rio

Pergunte(cPerg,.F.)

oReport := TReport():New("ATFR450",cTitulo,cPerg,{|oReport| ATFR450Imp( oReport,aOrd,cTitulo)},STR0004) //"Este relat�rio ir� imprimir informa��es do c�lculo do AVP conforme par�metros informados"

oSecSN1 := TRSection():New( oReport,STR0012,{"SN1"},,,,"")//"Ficha do Ativo"
TRCell():New( oSecSN1,"N1_FILIAL" ,"SN1",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)
TRCell():New( oSecSN1,"N1_CBASE"  ,"SN1",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)
TRCell():New( oSecSN1,"N1_ITEM"   ,"SN1",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)
TRCell():New( oSecSN1,"N1_DESCRIC","SN1",STR0005     ,/*Picture*/,/*Tamanho*/,/*lPixel*/) //"Desc. Item"

oSecFNF := TRSection():New( oSecSN1,STR0013,{"FNF"},,,,"")//"Movimentos AVP"
TRCell():New( oSecFNF,"DESC_SALDO",""   ,STR0006     ,"@!"       ,10         ,.F.       ,{|| Tabela("SL",(cAliasAvp)->FNF_TPSALD)}) //"Desc. Saldo"
TRCell():New( oSecFNF,"FNF_TPMOV" ,"FNF",STR0007     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        ) //"Desc. Movto"
TRCell():New( oSecFNF,"FNF_DTAVP" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )
TRCell():New( oSecFNF,"FNF_VALOR" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )
TRCell():New( oSecFNF,"FNF_ENT01" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )
TRCell():New( oSecFNF,"FNF_ENT02" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )
TRCell():New( oSecFNF,"FNF_ENT03" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )
TRCell():New( oSecFNF,"FNF_ENT04" ,"FNF",/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/        )

oSecFIL := TRSection():New( oReport,STR0014 )//"Filial"       //se��o para utiliza��o do totalizador por filial
TRCell():New( oSecFIL,"TOT_FIL","",STR0010,"@E 9,999,999,999,999.99",/*Tamanho*/,/*lPixel*/)

oSecSN1:SetHeaderPage(.T.)
oSecFNF:SetHeaderPage(.T.)
oSecSN1:SetAutoSize()
oSecFNF:SetAutoSize()

oReport:ParamReadOnly()

oFunc := TRFunction():New(oSecFNF:Cell("FNF_VALOR"),,"ONPRINT",/*oBreak*/,STR0011,/*cPicture*/,{|| SaldoAprop(oSecSN1:Cell("N1_FILIAL"):GetValue(.T.),oSecSN1:Cell("N1_CBASE"):GetValue(.T.),oSecSN1:Cell("N1_ITEM"):GetValue(.T.))},.T.,.F.,.F.,oSecFNF) //"Saldo a Apropriar"
oFunc:HideHeader()

oBreak2 := TRBreak():New( oReport, oSecSN1:Cell('N1_FILIAL') , STR0010, /*lTotalInLine*/, 'NOMEBRK', .F. )
oBreak2:OnPrintTotal({|| nTotalFil := 0})
oBreak2:SetPageBreak(.T.)
 
TRFunction():New(oSecFIL:Cell("TOT_FIL"),,"ONPRINT",oBreak2,,,{|| nTotalFil},.F.,.F., .F.)

Return( oReport )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFR450Imp�Autor  �Ramon Neves         � Data �  08/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a impress�o do Relat�rio C�lculo do AVP do         ���
���          � imobilizado                                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
���Parametros� Expo1 = oReport                                            ���
���          � Expa1 = Array com ordem de pesquisa                        ���
���          � Expc1 = Titulo do relatorio                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ATFR450Imp(oReport,aOrd,cTitulo)
Local oSecSN1		:= oReport:Section(1)
Local oSecFNF		:= oReport:Section(1):Section(1)
Local cCodDe		:= ""
Local cCodAte		:= ""
Local cItemDe		:= ""
Local cItemAte		:= ""
Local dPeriodIni	:= CToD("")
Local dPeriodFim	:= ""
Local cQlSaldo		:= ""
Local nImprime		:= 0
Local nSelFili		:= 0
Local cSelFili		:= ""
Local cCondFil		:= ""
Local cWhereAux		:= ""
Local lFilClass		:= (MV_PAR10 == 1 .And. Len(aSelClass) > 0 .And. FindFunction("FormatClass"))
Local cTmpFil

Pergunte( cPerg , .F. )

cCodDe      := MV_PAR01
cCodAte     := MV_PAR02
cItemDe     := MV_PAR03
cItemAte    := MV_PAR04
dPeriodIni	:= MV_PAR05
dPeriodFim	:= MV_PAR06
cQlSaldo    := MV_PAR07
nImprime    := MV_PAR08
nSelFili    := MV_PAR09

//Tratamento filial
cWhereAux += " FNF_FILIAL " + GetRngFil( aSelfil , "FNF", .T., @cTmpFil )

//Tratamento tipo de saldo
If !Empty(cQlSaldo)
	cWhereAux += " AND FNF.FNF_TPSALD = '" +cQlSaldo+ "' "
Endif

//Tratamento Analitico|Sintetico
If nImprime == 2 //Sintetico
	cWhereAux += " AND FNF.FNF_TPMOV = '1' " //Exibe somente a constituicao
EndIf  

//Filtra Classifica��es patrimoniais
If lFilClass 
	cWhereAux += " AND  SN1.N1_PATRIM IN " + FormatClass(aSelClass, .T.)
EndIf

cWhereAux := "%" + cWhereAux + "%"

BEGIN REPORT QUERY oSecSN1

	BeginSql alias cAliasAvp

		SELECT	SN1.N1_FILIAL,SN1.N1_CBASE ,SN1.N1_ITEM   ,SN1.N1_DESCRIC,SN1.N1_PATRIM,FNF.FNF_FILIAL,
				FNF.FNF_CBASE,FNF.FNF_ITEM ,FNF.FNF_TPSALD,FNF.FNF_TPMOV ,FNF.FNF_DTAVP ,
				FNF.FNF_VALOR,FNF.FNF_ENT01,FNF.FNF_ENT02 ,FNF.FNF_ENT03 ,FNF.FNF_ENT04 


		FROM %table:FNF% FNF INNER JOIN %table:SN1% SN1
		    ON SN1.N1_FILIAL = FNF.FNF_FILIAL
		    	AND SN1.N1_CBASE = FNF.FNF_CBASE 
		    	AND SN1.N1_ITEM = FNF.FNF_ITEM

		WHERE 	SN1.N1_CBASE >= %Exp:cCodDe% AND SN1.N1_CBASE <= %Exp:cCodAte%
				AND SN1.N1_ITEM >= %Exp:cItemDe% AND SN1.N1_ITEM <= %Exp:cItemAte%
				AND FNF_DTAVP >= %Exp:DTOS(dPeriodIni)% AND FNF_DTAVP <= %Exp:DTOS(dPeriodFim)%
				AND %Exp:cWhereAux%
				AND FNF.%notDel%
				AND SN1.%notDel%

		ORDER BY N1_FILIAL,N1_CBASE,N1_ITEM,FNF_REVIS,FNF_DTAVP,FNF_SEQAVP,FNF_TPMOV

	EndSql

END REPORT QUERY oSecSN1


oSecFNF:SetParentQuery()
oSecFNF:SetParentFilter({|cParam| (cAliasAvp)->(FNF_FILIAL+FNF_CBASE+FNF_ITEM) == cParam},{|| (cAliasAvp)->(N1_FILIAL+N1_CBASE+N1_ITEM) })
CtbTmpErase(cTmpFil)
oSecSN1:Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SaldoAprop�Autor  �Ramon Neves         � Data �  19/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula valor do saldo a constituir                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
���Retorno   � nSaldAVP (Valor do Saldo a Constituir)                     ���
�������������������������������������������������������������������������ͼ��
���Parametros� Expc1 = Filial                                             ���
���          � Expc2 = Codigo do bem                                      ���
���          � Expc3 = Item                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SaldoAprop(cFil,cBase,cItem)
Local aArea		:= GetArea()
Local aAreaFNF	:= FNF->(GetArea())
Local lTranf		:= .F.
Local nSaldAvp	:= 0  //saldo a apropriar//exibir no relat�rio

dbSelectArea("FNF")
dbSetOrder(1) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TIPO+FNF_SEQ+FNF_TPSALD+FNF_REVIS+FNF_SEQAVP+FNF_MOEDA+DTOS(FNF_DTAVP)

If MsSeek(cFil+cBase+cItem)
	
	While FNF->(!EOF()) .AND. FNF->(FNF_FILIAL+FNF_CBASE+FNF_ITEM) == cFil+cBase+cItem

		If FNF->FNF_TPMOV == "1" .And. FNF->FNF_STATUS != "7|8|9"

			nSaldAvp := FNF->FNF_VALOR - FNF->FNF_ACMAVP
						
		Endif
		
		//Valida se h� transferencia entre filiais
		If FNF->FNF_TPMOV == "8" 
			lTranf := .T.	
		EndIf
		
		
	FNF->(DbSkip())
	EndDo

Endif

//Quando houver transferencia, o saldo deve ser zerado, pois � exibido na filia destino
If lTranf
	nSaldAvp := 0	
EndIf

nTotalFil += nSaldAvp

RestArea(aAreaFNF)
RestArea(aArea)

Return nSaldAvp

