#INCLUDE "atfr052.ch"
#Include "Protheus.ch"


// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

// TRADUCAO DE CH'S PARA PORTUGAL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFR052    ³ Autor ³ Paulo Augusto         ³ Data ³ 12.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldo Atualizado- Legislacao Mexico                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ATFR052                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR052()
Private nInpcOri:=0
Private oReport,oSection1,oSection11,oSection2,oSection3
Private nTxAtua:=0

oReport:=ReportDef()
oReport:PrintDialog()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Paulo Augusto          ³ Data ³12/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cReport := "ATFR052"
Local cAlias1 := "SN3"
Local cTitulo := STR0001 //"Resultado por tenecia de Ativos nao monetarios"
Local cDescri := STR0002+ STR0003 //"Saldo a depreciar "###"Este programa ir  emitir a rela‡Æo dos valores para cada bem"
Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() + OemToAnsi(STR0004)+;   //" POR "
										Upper(aOrd[oSection1:GetOrder()] )+ "   " + STR0005 + Alltrim(STR(Year(GetMV("MV_ULTDEPR")))) ),;  //"EXERCICIO "
									 	ReportPrint( oReport ) }
Local aOrd := {}
Local cMoeda 

DbSelectArea("SIE")   
DbSetOrder(1)

DbSelectArea("SN1") // Forca a abertura do SN1

aOrd  := {	OemToAnsi(STR0006),;   //"Conta"
				OemToAnsi(STR0007)}   //"C.Custo"

Pergunte( "ATR052" , .F. )
oReport  := TReport():New( cReport, Upper(cTitulo), "ATR052" , bReport, cDescri )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio Valores nas Moedas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport,STR0008, {cAlias1,"SN1"}, aOrd )	  //"Dados da Entidade"
TRCell():New( oSection1, "N3_CCONTAB"	, cAlias1,/*X3Titulo*/,/*Picture*/,Len(CT1->CT1_DESC01)/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "N3_CCUSTO" 	, cAlias1,/*X3Titulo*/,/*Picture*/,Len(CTT->CTT_DESC01)/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection11 := TRSection():New( oSection1, STR0009, {cAlias1,"SN1"} )	  //"Dados do Bem"
TRCell():New( oSection11, "N1_DESCRIC"	, "SN1"  ,STR0010/*X3Titulo*/,/*Picture*/,Len(CT1->CT1_DESC01)/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"ATIVO FIXO"
TRCell():New( oSection11, "N1_AQUISIC"	, "SN1"  ,STR0011 +CHR(13)+CHR(10)+STR0012/*X3Titulo*/,/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"DATA"###"AQUISICAO"
TRCell():New( oSection11, "N3_VORIG1"	, cAlias1,STR0013/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"MOI"
TRCell():New( oSection11, "N3_TXDEPR1"	, cAlias1,STR0014+CHR(13)+CHR(10)+STR0015/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"TAXA DE"###"DEPREC."
TRCell():New( oSection11, "MESES"		, "   "  ,STR0016+CHR(13)+CHR(10)+STR0017+CHR(13)+CHR(10)+STR0018/*X3Titulo*/,/*Picture*/,    5,/*lPixel*/,/*{|| code-block de impressao }*/ )  //"MESES"###"DE"###"USO"
TRCell():New( oSection11, "INPCDATAAQ"	, "   "  ,STR0019+CHR(13)+CHR(10)+STR0011+CHR(13)+CHR(10)+STR0012/*X3Titulo*/,PesqPict("SIE","IE_INDICE")/*Picture*/,TamSX3("IE_INDICE")[1]/*Tamanho*/,/*lPixel*/,)  //"INPC"###"DATA"###"AQUISICAO"
TRCell():New( oSection11, "FATORATU"	, "   "  ,STR0020+CHR(13)+CHR(10)+STR0021/*X3Titulo*/,PesqPict("SIE","IE_INDICE")/*Picture*/,TamSX3("N3_VRDMES1")[1]/*Tamanho*/,/*lPixel*/,/*{|| }*/)  //"FATOR"###"ATUALIZACAO"
TRCell():New( oSection11, "VALORATU"	, "   "  ,STR0013+CHR(13)+CHR(10)+STR0022/*X3Titulo*/,PesqPict("SN3","N3_VRDMES1")/*Picture*/,TamSX3("N3_VRDMES1")[1]/*Tamanho*/,/*lPixel*/,/*{|| }*/) //"MOI"###"ATUALIZADO"
TRCell():New( oSection11, "N3_VRDMES1"	, "   ",STR0023+CHR(13)+CHR(10)+STR0024/*X3Titulo*/,PesqPict("SN3","N3_VRDMES1")/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| }*/) //"SALDO X"###"REDIMIR" //"DEPRECIACAO"###"MES"
TRCell():New( oSection11, "N3_VRDACM1"	, "   ",STR0023+CHR(13)+CHR(10)+STR0025/*X3Titulo*/,PesqPict("SN3","N3_VRDMES1")/*Picture*/,TamSX3("N3_VRDMES1")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"DEPRECIACAO"###"ACUMULADA"
TRCell():New( oSection11, "VALNETATU"	, "   "  ,STR0026+CHR(13)+CHR(10)+STR0022/*X3Titulo*/,PesqPict("SN3","N3_VRDMES1")/*Picture*/,TamSX3("N3_VRDMES1")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/ )    //"VALOR NETO"###"ATUALIZADO"
oSection11:SetHeaderPage()
Return oReport
                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Paulo Augusto       º Data ³  12/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query de impressao do relatorio                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport )
Local oSection1  := oReport:Section(1)
Local oSection11 := oReport:Section(1):Section(1)
Local oSection2	:= oReport:Section(2)
Local cChave
Local cQuery		:= "SN3"
Local cAliasCT1	:= "CT1"
Local cAliasCTT	:= "CTT"
Local nOrder   := oSection1:GetOrder()
Local cWhere	:= ""
Local cQuebra	:= .T.
Local nx:=1    
Local nTotvOrig:= 0
Local nTotDep:=   0
Local nTotDpAt:=  0
Local nTotSlMed:= 0
Local nTxUltC:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza registro inicial                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("N3_CCONTAB"):SetBlock( { || (cAliasCT1)->CT1_DESC01 } )
	
IF nOrder == 1
	SN3->(dbSetOrder(2))
	cWhere := "N3_CCONTAB <> ' ' AND "
	oSection1:Cell("N3_CCUSTO"):Disable()
	oSection11:SetTotalText({ || STR0027 + cQuebra } )		  //"Total da Conta: "
	oSection1:Cell("N3_CCONTAB"):SetBlock( { || (cAliasCT1)->CT1_DESC01 } )
ElseIF nOrder == 2
	SN3->(dbSetOrder(3))
	cWhere := "N3_CCUSTO <> ' ' AND "
	oSection1:Cell("N3_CCONTAB"):Disable()
	oSection1:Cell("N3_CCUSTO"):SetBlock( { || (cAliasCTT)->CTT_DESC01 } )
	oSection11:SetTotalText( {||STR0028 + cQuebra } )	  //"Total do Centro de Custo: "
End
cChave := SN3->(IndexKey())

#IFDEF TOP

	cQuery 		:= GetNextAlias()
	cAliasCT1	:= cQuery
	cAliasCTT	:= cQuery
	
	cChave 	:= "%"+SqlOrder(cChave)+"%"
	cWhere	:= "%" + cWhere + "%"
	
	oSection1:BeginQuery()
	
	BeginSql Alias cQuery
		SELECT
			N3_CBASE, N3_ITEM, N3_CCUSTO, N3_CCONTAB, N3_VORIG1, N3_AMPLIA1, N3_VRCACM1, N3_VRDACM1, N3_VRCDA1, 
			N3_VORIG2, N3_AMPLIA2, N3_VRDACM2, N3_VORIG3, N3_AMPLIA3, N3_VRDACM3, N3_VORIG4, N3_AMPLIA4, N3_VRDACM4,
			N3_VORIG5, N3_AMPLIA5, N3_VRDACM5, N3_CDEPREC, N3_CCDEPR, N1_DESCRIC, CTT_DESC01, CT1_DESC01,N3_TXDEPR1,
			N3_VORIG1,N1_AQUISIC,N3_DINDEPR,N3_VRDMES1,N3_VRDBAL1,N3_VRDMES1,N1_DESCRIC
		FROM %table:SN3% SN3
			JOIN %table:SN1% SN1 ON 
			SN1.N1_FILIAL =  %xfilial:SN1%  
			AND SN1.N1_CBASE = SN3.N3_CBASE 
			AND SN1.N1_ITEM = SN3.N3_ITEM 
			AND SN1.%notDel%
			LEFT JOIN %table:CT1% CT1 ON
			CT1.CT1_FILIAL =  %xfilial:CT1%
			AND CT1.CT1_CONTA = SN3.N3_CCONTAB 
			AND CT1.%notDel%
			LEFT JOIN %table:CTT% CTT ON
			CTT.CTT_FILIAL =  %xfilial:CTT%
			AND CTT.CTT_CUSTO = SN3.N3_CCUSTO 
			AND CTT.%notDel%
		WHERE
			SN3.N3_FILIAL = %xfilial:SN3% AND
			SN3.N3_CBASE >= %Exp:mv_par01% AND 
			SN3.N3_CBASE <= %Exp:mv_par02% AND 
			SN3.N3_BAIXA = '0' AND
			SN3.N3_TXDEPR1 <> 0 AND
			(SN3.N3_CDEPREC <> ' ' OR
			 SN3.N3_CDESP <> ' ' OR
        	 SN3.N3_CCDEPR <> ' ' ) AND
			%Exp:cWhere%
			SN3.%notDel%
		ORDER BY %Exp:cChave%
	EndSql

	oSection1:EndQuery()
	oSection11:SetParentQuery()
	
#ELSE

	cFiltro := 'N3_FILIAL == "'+xFilial("SN3")+'" .And. '
	cFiltro += 'N3_CBASE>= "'+mv_par01+'" .And. '
	cFiltro += 'N3_CBASE<= "'+mv_par02+'" .And. '
	cFiltro += StrTran(cWhere, "AND", ".And." )
	cFiltro += 'Val(N3_BAIXA) = 0 .And.'
	cFiltro += '(!Empty(N3_CDEPREC) .Or. !Empty(N3_CDESP) .Or. !Empty(N3_CCDEPR)) .And. ' 
	cFiltro += 'N3_TXDEPR1 <> 0'
	oSection1:SetFilter(cFiltro,cChave)

	TRPosition():New(oSection1,"CT1",1,{|| xFilial("CT1")+SN3->N3_CCONTAB })
	TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT")+SN3->N3_CCUSTO })
	TRPosition():New(oSection11,"SN1",1,{|| xFilial("SN1")+SN3->(N3_CBASE+N3_ITEM) })

#ENDIF


//TRCell():New( oSection11, "N3_VRDACM1"	, "   ",STR0023+CHR(13)+CHR(10)+STR0025/*X3Titulo*/,PesqPict("SN3","N3_VRDMES1")/*Picture*/,TamSX3("N3_VRDMES1")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"DEPRECIACAO"###"ACUMULADA"
oSection11:Cell("N3_VORIG1"):SetBlock( { ||atf052CM((cQuery)->N3_DINDEPR,(cQuery)->N3_VORIG1,(cQuery)->N3_VRDACM1,(cQuery)->N3_TXDEPR1)} )

// Cria variável a ser usada para impressao do texto da quebra da secao
oSection11:SetLineCondition( { || If(nOrder==1, cQuebra := (Mascara(N3_CCONTAB) + " - " + (cAliasCT1)->CT1_DESC01), cQuebra := (N3_CCUSTO + " - " + (cAliasCTT)->CTT_DESC01)),.T. } )
oSection11:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)
oReport:SetTotalText("TOTAIS") 

If nOrder == 1
	oSection11:SetParentFilter({|cParam| (cQuery)->N3_CCONTAB == cParam },{|| (cQuery)->N3_CCONTAB })
Else
	oSection11:SetParentFilter({|cParam| (cQuery)->N3_CCUSTO == cParam },{|| (cQuery)->N3_CCUSTO })
Endif	

TRFunction():New(oSection11:Cell("N3_VORIG1"),,"SUM",,,,, .T. ,.T. )	
TRFunction():New(oSection11:Cell("VALORATU"),,"SUM",,,,, .T., .T. )	
TRFunction():New(oSection11:Cell("VALNETATU"),,"SUM",,,,, .T., .T. )	


nTxUltC:=0
SIE->(DbSetOrder(1))
SIE->(DbSeek( xFilial("SIE")+Str(Year(GetMV("MV_ULTDEPR")),4)+ Strzero(Month(GetMV("MV_ULTDEPR")),2) ))
nTxUltC:=SIE->IE_INDICE
oReport:SkipLine()
oReport:PrintText( STR0029 + Transform(	nTxUltC,PesqPict("SIE","IE_INDICE")) ) //"INPC FECHAMENTO: "
oReport:SkipLine(2)



oSection1:Print()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³atf052CM   ºAutor  ³Paulo Augusto       º Data ³  12/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Taxa das moeda                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function atf052CM(dDatInDep,nVorig,nValAcum,nTxDep)

Local nTxMed:=0
Local nMesIni:=0
Local nMesUso:=0
Local nTxAqui:=0
Local nDepMes:=0
Default nTxDep := 0


nTxAtua:=0

If Year(dDatInDep)<> Year(GetMV("MV_ULTDEPR"))
	nMesIni:=1
Else
	nMesIni:=Month(dDatInDep)
EndIf	

cMesMed:=Strzero(Month(GetMV("MV_ULTDEPR")),2)

DbSelectArea("SIE")   
DbSetOrder(1)
If DbSeek( xFilial("SIE")+Str(Year(GetMV("MV_ULTDEPR")),4)+cMesMed) 
	nTxMed:=SIE->IE_INDICE
EndIf

If DbSeek( xFilial("SIE")+Str(Year(dDatInDep),4)+STRzero(Month(dDatInDep),2))
	nTxAqui:=SIE->IE_INDICE
EndIf

nTxAtua:=nTxMed/nTxAqui

//oSection11:Cell("FATORATU"):SetValue(nTxMed) 
oSection11:Cell("INPCDATAAQ"):SetValue(nTxAqui) 
oSection11:Cell("FATORATU"):SetValue(nTxAtua) 
oSection11:Cell("VALORATU"):SetValue(nVorig*nTxAtua)


If Year(dDatInDep) <> Year(GetMV("MV_ULTDEPR"))
	If Year(GetMV("MV_ULTDEPR")) - Year(dDatInDep)  == 1
		nMesUso:= Month(GetMV("MV_ULTDEPR"))+ (12 - Month(dDatInDep))
    Else                              
    	nMesUso:= (Year(GetMV("MV_ULTDEPR")) - Year(dDatInDep))*12 - (Month(dDatInDep)- Month(GetMV("MV_ULTDEPR")))
    EndIf
EndIf


//Alterar aqui os meses
oSection11:Cell("MESES"):SetValue(nMesUso)

//SetBlock( { ||Iif((cQuery)->N3_VRDMES1<=0,0,Iif(Year(GetMV("MV_ULTDEPR"))<>Year((cQuery)->N3_DINDEPR),Month(GetMV("MV_ULTDEPR")),Month(GetMV("MV_ULTDEPR"))-Month((cQuery)->N3_DINDEPR)))   } )

If nMesUso >0
	nDepMes:=(nVorig*nTxAtua)*((nTxDep/12)/100)
EndIf
oSection11:Cell("N3_VRDMES1"):SetValue(nDepMes)

oSection11:Cell("N3_VRDACM1"):SetValue(nDepMes *	nMesUso)

oSection11:Cell("VALNETATU"):SetValue((nVorig*nTxAtua)- (nDepMes *	nMesUso))


Return(nVorig)


