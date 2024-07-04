#INCLUDE "PROTHEUS.CH"
#include "msgraphi.ch"
#INCLUDE "TOPCONN.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPO060  ³ Autor ³ Rogerio Tabosa        ³ Data ³ 16/04/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 2 Padrao 3: Top 5      ³±±
±±³          ³de guias faturadas no Lote                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HSPPO060()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} ³±±
±±³          ³ cCombo1     = Detalhes                                       ³±±
±±³          ³ cText1      = Texto da Coluna                         		³±±
±±³          ³ cValor      = Valor a ser exibido (string)                   ³±±
±±³          ³ nColorValor = Cor do Valor no formato RGB (opcional)         ³±±
±±³          ³ cClick      = Funcao executada no click do valor (opcional)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function HSPPO060()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local cAliasRC1	:= "GCZ"
//Local cCodLocI	:= "  "
//Local cCodLocF	:= "ZZ"
//Local aRet		:= {} 
Local cMes		:= StrZero(Month(dDataBase),2)
Local cAno		:= Substr(DTOC(dDataBase),7,2)
Local dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Local dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
//Local dDataIniA	:= CTOD("01/01/"+cAno)
//Local dDataFimA := CTOD("31/12/"+cAno)
Local nAteAmbM	:= 0 //Tipo 1                                 	
Local nAteAmbD	:= 0

Local nAteIntM	:= 0 //Tipo 0
Local nAteIntD	:= 0
Local nAtePAM	:= 0 //Tipo 2
Local nAtePAD	:= 0
Local nAteAmb	:= 0 
Local nAtePA	:= 0
Local nAteInt	:= 0
Local aEixoX    := {}
Local aValores  := {}  
Local aRetPanel := {}
Local cCodCon	:= ""   
Local aConvTot	:= {}
Local nSomaTot	:= 0
Local i			:= 0
Local cSqlTmp 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                              D I A R I O                               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero de Atendimentos cancelados por mes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT GCZ_CODCON,GA9_NREDUZ, GE7.GE7_SEQDES SQPROC,GE6.GE6_SEQDES SQTAX,GE5.GE5_SEQDES SQMM
 FROM %table:GCZ% GCZ
 	JOIN %table:GA9% GA9 
 	ON GA9_CODCON=GCZ_CODCON AND GA9.GA9_FILIAL = %xFilial:GA9% AND GA9.%NotDel%
	LEFT JOIN %table:GE7% GE7
	ON GE7_NRSEQG = GCZ_NRSEQG AND GE7.GE7_FILIAL = %xFilial:GE7% AND GE7.%NotDel%
	LEFT JOIN %table:GE6% GE6
	ON GE6_NRSEQG = GCZ_NRSEQG AND GE6.GE6_FILIAL = %xFilial:GE6% AND GE6.%NotDel%
	LEFT JOIN %table:GE5% GE5
	ON GE5_NRSEQG = GCZ_NRSEQG AND GE5.GE5_FILIAL = %xFilial:GE5% AND GE5.%NotDel%	
	WHERE GCZ.GCZ_FILIAL = %xFilial:GCZ% AND GCZ.%NotDel% AND GCZ.GCZ_STATUS =  %Exp:3% 
	AND (   EXISTS(SELECT 1 FROM %table:GE7% GE71 WHERE GE71.GE7_NRSEQG=GCZ_NRSEQG) 
	 OR EXISTS(SELECT 1 FROM %table:GE6% GE61 WHERE GE61.GE6_NRSEQG=GCZ_NRSEQG)
	 OR EXISTS(SELECT 1 FROM %table:GE5% GE51 WHERE GE51.GE5_NRSEQG=GCZ_NRSEQG) )
EndSql

cCodCon := (cAliasRC1)->GCZ_CODCON 
Aadd(aConvTot, {cCodCon + "-" + (cAliasRC1)->GA9_NREDUZ , 0})

While !(cAliasRC1)->(EOF())  
	If cCodCon <> (cAliasRC1)->GCZ_CODCON
		cCodCon := (cAliasRC1)->GCZ_CODCON
		aConvTot[Len(aConvTot),2] := nSomaTot
		nSomaTot := 0
		Aadd(aConvTot, {cCodCon + "-" + (cAliasRC1)->GA9_NREDUZ , 0})
	EndIf
	If !Empty((cAliasRC1)->SQPROC) 
		cSqlTmp := "SELECT GE7_SEQDES FROM " + RetSqlName("GE7") + " WHERE GE7_SEQDES= '" + (cAliasRC1)->SQPROC + "'"
	 	TCQUERY cSqlTmp NEW ALIAS "TMPGE7" 
		If !TMPGE7->(EOF()) 
			nSomaTot += HS_RTOTAIS('GE7_TOTDSC')
			TMPGE7->(DbCloseArea())
		EndIf        
	EndIf 
	
	If !Empty((cAliasRC1)->SQTAX)
		cSqlTmp := "SELECT GE6_SEQDES FROM " + RetSqlName("GE6") + " WHERE GE6_SEQDES= '" + (cAliasRC1)->SQTAX + "'"
	 	TCQUERY cSqlTmp NEW ALIAS "TMPGE6" 
		If !TMPGE6->(EOF()) 
			nSomaTot += HS_RTOTAIS('GE6_TOTDSC')
			TMPGE6->(DbCloseArea())
		EndIf        
	EndIf                               
	
	If !Empty((cAliasRC1)->SQMM)
		cSqlTmp := "SELECT GE5_SEQDES FROM " + RetSqlName("GE5") + " WHERE GE5_SEQDES= '" + (cAliasRC1)->SQMM + "'"
	 	TCQUERY cSqlTmp NEW ALIAS "TMPGE5" 
		If !TMPGE5->(EOF()) 
			nSomaTot += HS_RTOTAIS('GE5_TOTDSC')
			TMPGE5->(DbCloseArea())
		EndIf        
	EndIf
	
	(cAliasRC1)->(DbSkip())
	If (cAliasRC1)->(EOF())	
		aConvTot[Len(aConvTot),2] := nSomaTot		
	EndIf
End 
(cAliasRC1)->(DbCloseArea())
 
If Len(aConvTot) > 0 
	aSort(aConvTot,,,{|x,y| x[2] > y[2]})
EndIf  

For i := 1 to IIf(Len(aConvTot) > 5,5, Len(aConvTot))
	Aadd( aEixoX, aConvTot[i,1] )
	Aadd( aValores, Round(aConvTot[i,2],2) )
Next i

aRetPanel := 	{GRP_BAR,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aAreaGCY)
RestArea(aArea)

Return aRetPanel  

