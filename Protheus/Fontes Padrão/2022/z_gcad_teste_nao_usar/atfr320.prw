#INCLUDE "protheus.ch"
#INCLUDE "ATFR320.ch"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR320   º Autor ³ Marcos S. Lobo.    º Data ³  24/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Responsáveis x Bens.					      	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFR320(cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM)
Local oReport

If TRepInUse()
	oReport:=ReportDef(cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM)
	oReport:PrintDialog()
Else
   Return ATFR320R3(cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM) // Executa versão anterior do relatorio
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Claudio D. de Souza    ³ Data ³28/06/2006³±±
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
Static Function ReportDef(cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM)
Local oReport,oSection1, oSection2
Local cReport := "ATFR320"
Local cAlias1 := "SND"
Local cAlias2 := "SN1"
Local cTitulo := STR0002 //"Responsáveis x Bens"
Local cDescri := STR0001 // "Este programa emite o relatório Responsáveis x Bens"
Local bReport := { |oReport| ReportPrint( oReport, cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM ) }
Local aOrd := {}

DbSelectArea("SN1") // Forca a abertura do SN1

dbSelectArea("SIX")
dbSetOrder(1)
If MsSeek("SND",.F.)
	While !SIX->(Eof()) .and. SIX->INDICE == "SND" .and. SIX->ORDEM <= "2"
		#IFDEF SPANISH
			aAdd(aOrd,SIX->DESCSPA)
		#ELSE
			#IFDEF ENGLISH
				aAdd(aOrd,SIX->DESCENG)
			#ELSE
				aAdd(aOrd,SIX->DESCRICAO)
			#ENDIF
		#ENDIF
		SIX->(dbSkip())
	EndDo
Else
	aOrd 	:= {STR0005,STR0006}	///" Responsável + Bem "#" Bem + Responsáveis "
Endif

Pergunte( "AFR320" , .F. )
oReport  := TReport():New( cReport, cTitulo, "AFR320" , bReport, cDescri )
/*
GESTAO - inicio */
oReport:SetUseGC(.F.)
/* GESTAO - fim
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio Valores nas Moedas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport, STR0009+STR0011 , {cAlias1}, aOrd )	//"Dados do Responsavel - "##"(Ordem 1)"
oSection1:SetHeaderSection(.T.)
oSection1:SetHeaderPage(.T.)
oSection1:SetLinesBefore(2)	
TRCell():New( oSection1, "ND_FILIAL"  , cAlias1  ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New( oSection1, "ND_CODRESP" , cAlias1  ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New( oSection1, "RD0_NOME"   , "RD0" 	 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)	
TRCell():New( oSection1, "RD0_FONE"   , "RD0" 	 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)	
TRCell():New( oSection1, "FILLER"     , "" 	     ,"   " /*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| "" },,,,,,.T.)
oSection1:Cell("ND_CODRESP"):SetBorder("BOTTOM")
oSection1:Cell("ND_FILIAL"):SetBorder("BOTTOM")		
oSection1:Cell("RD0_FONE"):SetBorder("BOTTOM")	
oSection1:Cell("RD0_NOME"):SetBorder("BOTTOM")	
oSection1:Cell("FILLER"):SetBorder("BOTTOM")

oSection2 := TRSection():New( oSection1, STR0010+STR0011 , {cAlias1} )		//"Dados dos Bens - "##"(Ordem 1)"
oSection2:SetHeaderPage(.T.)
oSection2:SetLinesBefore(0) 
oSection2:SetAutoSize(.T.)
TRCell():New( oSection2, "N1_FILIAL" , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_CBASE"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_ITEM"   , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_DESCRIC", cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_CHAPA"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_LOCAL"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_QUANTD" , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection3 := TRSection():New( oReport, STR0010+STR0012 , {cAlias1} )		//	//"Dados dos Bens - "##"(Ordem 2)"
oSection3:SetHeaderSection(.T.)
oSection3:SetHeaderPage(.T.)
oSection3:SetAutoSize(.T.)
oSection3:SetLinesBefore(2) 
TRCell():New( oSection3, "N1_FILIAL" , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_CBASE"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_ITEM"   , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_DESCRIC", cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_CHAPA"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_LOCAL"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection3, "N1_QUANTD" , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection3:Cell("N1_CBASE"):SetBorder("BOTTOM")
oSection3:Cell("N1_ITEM"):SetBorder("BOTTOM")
oSection3:Cell("N1_FILIAL"):SetBorder("BOTTOM")
oSection3:Cell("N1_DESCRIC"):SetBorder("BOTTOM")
oSection3:Cell("N1_CHAPA"):SetBorder("BOTTOM")
oSection3:Cell("N1_LOCAL"):SetBorder("BOTTOM")
oSection3:Cell("N1_QUANTD"):SetBorder("BOTTOM")

oSection4 := TRSection():New( oSection3, STR0009+STR0012 , {cAlias1}, aOrd )		//"Dados do Responsavel - "##"(Ordem 1)"
oSection4:SetHeaderPage(.T.)
oSection4:SetLinesBefore(0)
oSection4:SetAutoSize(.T.) 
TRCell():New( oSection4, "ND_CODRESP" , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
TRCell():New( oSection4, "ND_FILIAL"  , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection4, "RD0_NOME"   , "RD0" 	 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
TRCell():New( oSection4, "RD0_FONE"   , "RD0" 	 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Claudio D. de Souza º Data ³  23/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query de impressao do relatorio                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM )
Local oSection1 := Nil
Local oSection2 := Nil
Local cChave	:= ""
Local cQuery 	:= "SND"
Local nOrder	:= 0
/* GESTAO */
Local nPos		:= 0
Local cTmpFil	:= ""
Local cFilSND	:= ""
Local cFilSN1	:= ""
Local cFilRD0	:= ""
Local cFilChv	:= ""
Local lSelFil	:= .T.
Local aSelFil	:= {}
Local aTmpFil	:= {}

nOrder	:= oReport:Section(1):GetOrder()

lSecFil := (FWSizeFilial() > 2)

// Verifica como serao impressas as secoes, conforme a ordem escolhida pelo usuario
If nOrder == 1
	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(1):Section(1)
	oReport:Section(2):Hide()
	oReport:Section(2):Section(1):Hide()
	If FWModeAccess("RD0",1) == "C" .Or. !lSecFil
		oSection1:Cell("ND_FILIAL"):Disable()
	Endif
	If FWModeAccess("SN1",1) == "C" .Or. !lSecFil
		oSection2:Cell("N1_FILIAL"):Disable()
	Endif
Else
	oSection1 := oReport:Section(2)
	oSection2 := oReport:Section(2):Section(1)
	oReport:Section(1):Hide()
	oReport:Section(1):Section(1):Hide()
	If FWModeAccess("RD0",1) == "C" .Or. !lSecFil
		oSection2:Cell("ND_FILIAL"):Disable()
	Endif
	If FWModeAccess("SN1",1) == "C" .Or. !lSecFil
		oSection1:Cell("N1_FILIAL"):Disable()
	Endif
Endif

SND->(dbSetOrder(nOrder))

If !Empty(cRespINI) .or. !Empty(cRespFim)
	mv_par01 := cRespINI
	mv_par02 := cRespFIM
	lSelFil := .F.
Endif

If !Empty(cCBaseINI) .or. !Empty(cCBaseFIM)
	mv_par03 := cCBaseINI
	mv_par05 := cCBaseFIM
	lSelFil := .F.
Endif

If !Empty(cItemINI) .or. !Empty(cItemFIM)
	mv_par04 := cItemINI
	mv_par06 := cItemFIM
	lSelFil := .F.
Endif

If lSelFil
	If MV_PAR07 == 1 
		AdmSelecFil("AFR320",07,.F.,@aSelFil,"SN1",.F.)
		If Empty(aSelFil)
			Aadd(aSelFil,cFilAnt)
		Endif
	Endif
	MsgRun(STR0013,STR0002 ,{|| cFilSND := GetRngFil(aSelFil,"SND",.T.,@cTmpFil)})		// "Favor Aguardar..."
	Aadd(aTmpFil,cTmpFil)
	cFilSND := "%SND.ND_FILIAL " + cFilSND + "%"
	/*-*/
	MsgRun(STR0013,STR0002 ,{|| cFilSN1 := GetRngFil(aSelFil,"SN1",.T.,@cTmpFil)})		//"Favor Aguardar..."
	Aadd(aTmpFil,cTmpFil)
	cFilSN1 := "%SN1.N1_FILIAL " + cFilSN1 + "%"
	/*-*/
	MsgRun(STR0013,STR0002 ,{|| cFilRD0 := GetRngFil(aSelFil,"RD0",.T.,@cTmpFil)})		//"Favor Aguardar..."
	Aadd(aTmpFil,cTmpFil)
	cFilRD0 := "%RD0.RD0_FILIAL " + cFilRD0 + "%"
	/*-*/
	cChave 	:= SqlOrder(SND->(IndexKey(nOrder)))
	If (nOrder == 1 .And. FWModeAccess("RD0",1) == "C") .Or. (nOrder == 2 .And. FWModeAccess("SN1",1) == "C")
		nPos := At("ND_FILIAL,",cChave)
		If nPos > 0
			cChave := Stuff(cChave,nPos,10,"")
		Endif
	Endif
	cChave := "%" + cChave + "%"
Else
	cFilSND := "%SND.ND_FILIAL = '" + xFilial("SND") + "'%"  
	cFilSN1 := "%SN1.N1_FILIAL = '" + xFilial("SN1") + "'%"
	cFilRD0 := "%RD0.RD0_FILIAL = '" + xFilial("RD0") + "'%"
	cChave 	:= "%"+SqlOrder(SND->(IndexKey(nOrder)))+"%"
Endif
/*-*/
cQuery 	:= GetNextAlias()

oSection1:BeginQuery()

BeginSql Alias cQuery
	SELECT
		ND_FILIAL,ND_CODRESP, RD0_CODIGO, RD0_FONE, RD0_NOME, ND_CBASE, ND_ITEM,
		N1_FILIAL,N1_CBASE, N1_ITEM, N1_DESCRIC, N1_CHAPA, N1_LOCAL, N1_QUANTD
	FROM 
		%table:SN1% SN1, %table:SND% SND, %table:RD0% RD0
	WHERE
		%Exp:cFilSND% AND
		SND.ND_CODRESP >= %Exp:mv_par01% AND 
		SND.ND_CODRESP <= %Exp:mv_par02% AND
		SND.ND_CBASE   >= %Exp:mv_par03% AND 
		SND.ND_ITEM    >= %Exp:mv_par04% AND 
		SND.ND_CBASE   <= %Exp:mv_par05% AND
		SND.ND_ITEM    <= %Exp:mv_par06% AND
		SND.ND_STATUS = '1' AND
		SND.%notDel% AND
		%Exp:cFilSN1% AND
		SN1.N1_CBASE = SND.ND_CBASE AND
		SN1.N1_ITEM  = SND.ND_ITEM AND
		SN1.%notDel% AND
		%Exp:cFilRD0% AND
		RD0.RD0_CODIGO = SND.ND_CODRESP AND
		RD0.%notDel%
	ORDER BY %Exp:cChave%
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
	

If nOrder == 1
	oSection2:SetParentFilter({|cParam| (cQuery)->ND_CODRESP == cParam },{|| (cQuery)->ND_CODRESP })
Else
	oSection2:SetParentFilter({|cParam| (cQuery)->(ND_CBASE+ND_ITEM) == cParam },{|| (cQuery)->(ND_CBASE+ND_ITEM) })
Endif	

// Inclui condicao para imprimir a apolice caso encontre o Bem ou se nao encontrar, verifica se imprime apolice sem bens.
oSection1:SetLineCondition({||	SN1->(DbSetOrder(1)),SN1->(MsSeek(xFilial("SN1",(cQuery)->N1_FILIAL)+(cQuery)->(ND_CBASE+ND_ITEM))) } )

oSection1:Print()
/*
GESTAO */
If !Empty(aTmpFil) 
	MsgRun(STR0013,STR0002 ,{|| AEval(aTmpFil,{|tmpfil| CtbTmpErase(tmpFil)})})		//"Favor Aguardar..."
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR320   º Autor ³ Marcos S. Lobo.    º Data ³  24/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Responsáveis x Bens.					      	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFR320R3(cRespINI,cRespFIM,cCBASEINI,cItemINI,cCBaseFIM,cItemFIM)
Local cDesc1        := STR0001///"Este programa emite o relatório Responsáveis x Bens"
Local cDesc2        := ""
Local cDesc3        := ""
Local titulo       	:= STR0002///"Responsáveis x Bens"
Local nLin         	:= 80
Local Cabec1		:= ""
Local Cabec2		:= ""
Local lPerg			:= .T.

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "ATFR320" // Nome para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0003, 1, STR0004, 2, 2, 1, "", 1}	///"Zebrado"#"Administracao"
Private nLastKey    := 0
Private cPerg       := "AFR320"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 1
Private wnrel       := "ATFR320" // Nome do arquivo usado para impressao em disco
Private aOrd	    := {}			//// ARRAY COM O TEXTO DAS ORDENS DE IMPRESSAO

Private cString := "SN1"

dbSelectArea("SIX")
dbSetOrder(1)
If MsSeek("SND",.F.)
	While !SIX->(Eof()) .and. SIX->INDICE == "SND" .and. SIX->ORDEM <= "2"
		#IFDEF SPANISH
			aAdd(aOrd,SIX->DESCSPA)
		#ELSE
			#IFDEF ENGLISH
				aAdd(aOrd,SIX->DESCENG)
			#ELSE
				aAdd(aOrd,SIX->DESCRICAO)
			#ENDIF
		#ENDIF
		SIX->(dbSkip())
	EndDo
Else
	aOrd 	:= {STR0005,STR0006}	///" Responsável + Bem "#" Bem + Responsáveis "
Endif

pergunte(cPerg,.F.)

If !Empty(cRespINI) .or. !Empty(cRespFim)
	mv_par01 := cRespINI
	mv_par02 := cRespFIM
	lPerg := .F.
Endif

If !Empty(cCBaseINI) .or. !Empty(cCBaseFIM)
	mv_par03 := cCBaseINI
	mv_par05 := cCBaseFIM
	lPerg := .F.
Endif

If !Empty(cItemINI) .or. !Empty(cItemFIM)
	mv_par04 := cItemINI
	mv_par06 := cItemFIM
	lPerg := .F.
Endif

If lPerg	
	If !Pergunte(cPerg,.T.)
		Return
	Endif
Endif

dbSelectArea("SN1")
dbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)	/// SO FILTRO DE USUARIO E ORDENS DE IMPRESSAO

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| AFR320Run(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ATFR320   º Autor ³ Marcos S. Lobo     º Data ³  24/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AFR320Run(Cabec1,Cabec2,Titulo,nLin)

Local cFilSND 		:= xFilial("SND")
Local cFilSN1 		:= xFilial("SN1")
Local cFilRD0		:= xFilial("RD0")
Local cPicQUANTD    := PesqPict("SN1","N1_QUANTD")
Local cRD0Nome		:= ""
Local cRD0MAT		:= ""

/// TITULO DOS CAMPOS IMPRESSOS
Local cN1CBASE		:= RetTitle("N1_CBASE")
Local cN1ITEM		:= RetTitle("N1_ITEM")
Local cN1DESCRIC	:= RetTitle("N1_DESCRIC")
Local cN1CHAPA		:= RetTitle("N1_CHAPA")
Local cN1LOCAL		:= RetTitle("N1_LOCAL")
Local cN1QUANTD		:= RetTitle("N1_QUANTD")

Local cD0CODIGO		:= RetTitle("RD0_CODIGO")
Local cD0MAT		:= RetTitle("RD0_FONE")
Local cD0NOME		:= RetTitle("RD0_NOME")

/// TAMANHO DOS CAMPOS IMPRESSOS
Local nLN1CBASE		:= Len(CriaVar("N1_CBASE"))
Local nLN1ITEM		:= Len(CriaVar("N1_ITEM"))
Local nLN1DESCRIC	:= Len(CriaVar("N1_DESCRIC"))
Local nLN1CHAPA		:= Len(CriaVar("N1_CHAPA"))
Local nLN1LOCAL		:= Len(CriaVar("N1_LOCAL"))
Local nLN1QUANTD	:= Len(cPicQUANTD)

Local nLD0CODIGO	:= Len(CriaVar("RD0_CODIGO"))
Local nLD0MAT		:= Len(CriaVar("RD0_FONE"))
Local nLD0NOME		:= Len(CriaVar("RD0_NOME"))

/// POSICAO DA COLUNA PADRAO DOS CAMPOS IMPRESSOS
Local nColCBASE		:= 0
Local nColITEM		:= 12
Local nColDESCRIC	:= 18
Local nColCHAPA		:= 70
Local nColLOCAL		:= 81
Local nColQUANTD	:= 100

Local nColCODRESP	:= 0
Local nColMAT		:= 8
Local nColNOME		:= 20

/// VERICA SE PREDOMINA O TAMANHO DO TITULO OU DO CAMPO (SEMPRE O MAIOR)
nLN1CBASE		:= If(Len(cN1CBASE)		>nLN1CBASE	,Len(cN1CBASE)		,nLN1CBASE)
nLN1ITEM		:= If(Len(cN1ITEM)		>nLN1ITEM	,Len(cN1ITEM)		,nLN1ITEM)
nLN1DESCRIC		:= If(Len(cN1DESCRIC)	>nLN1DESCRIC,Len(cN1DESCRIC)	,nLN1DESCRIC)
nLN1CHAPA		:= If(Len(cN1CHAPA)		>nLN1CHAPA	,Len(cN1CHAPA)		,nLN1CHAPA)
nLN1LOCAL		:= If(Len(cN1LOCAL)		>nLN1LOCAL	,Len(cN1LOCAL)		,nLN1LOCAL)
nLN1QUANTD		:= If(Len(cN1QUANTD)	>nLN1QUANTD ,Len(cN1QUANTD)		,nLN1QUANTD)

nLD0CODIGO		:= If(Len(cD0CODIGO)	>nLD0CODIGO ,Len(cD0CODIGO)		,nLD0CODIGO)
nLD0MAT			:= If(Len(cD0MAT)		>nLD0MAT 	,Len(cD0MAT)		,nLD0MAT)
nLD0NOME		:= If(Len(cD0NOME)		>nLD0NOME 	,Len(cD0NOME)		,nLD0NOME)

/// TRATA A POSICAO DA COLUNA DE ACORDO COM O TAMANHO DOS CAMPOS                
nColCBASE	:= 0                    			/// COLUNA PARA IMPRESSAO DO CODIGO BASE DO BEM
nColITEM	:= nColCBASE+nLN1CBASE+1			/// COLUNA PARA IMPRESSAO DO ITEM BASE DO BEM
nColDESCRIC	:= nColITEM+nLN1ITEM+1				/// COLUNA PARA IMPRESSAO DA DESCRICAO DO BEM
nColCHAPA	:= nColDESCRIC+nLN1DESCRIC+1		/// COLUNA PARA IMPRESSAO DO NUMERO DE CHAPA DO BEM
nColLOCAL	:= nColCHAPA+nLN1CHAPA+1			/// COLUNA PARA IMPRESSAO DA LOCALIZACAO DO BEM
nColQUANTD	:= nColLOCAL+nLN1LOCAL+1			/// COLUNA PARA IMPRESSAO DA DATA DE AQUISICAO DO BEM

nColCODRESP	:= 0								/// COLUNA PARA IMPRESSAO DO COD. RESPONSAVEL
nColMAT		:= nColCODRESP+nLD0CODIGO+1			/// COLUNA PARA IMPRESSAO DA MATRICULA DO RESPONSAVEL
nColNOME	:= nColMAT+nLD0MAT+1				/// COLUNA PARA IMPRESSAO DO NOME DO RESPONSAVEL

dbSelectArea("SN1")										///TRATA O FILTRO SOBRE O CADASTRO DE BENS
If !Empty(aReturn[7])
	SET FILTER TO &(aReturn[7])							//// EFETUA O FILTRO
Endif

dbSelectArea("SND")
SetRegua(RecCount())
dbSetOrder(aReturn[8])
If aReturn[8] == 1																/// SE ORDENADO POR RESPONSAVEL
	MsSeek(cFilSND+mv_par01+mv_par03+mv_par04,.T.)
	bWhile := {|| SND->ND_CODRESP <= mv_par02}
	Cabec1 := PADR(cD0CODIGO,nLD0CODIGO)+" "+PADR(cD0MAT,nLD0MAT)+" "+PADR(cD0NOME,nLD0NOME)
	Cabec2 := PADR(cN1CBASE,nLN1CBASE)+" "+PADR(cN1ITEM,nLN1ITEM)+" "+PADR(cN1DESCRIC,nLN1DESCRIC)+" "+PADR(cN1CHAPA,nLN1CHAPA)+" "+PADC(cN1LOCAL,nLN1LOCAL)+PADL(cN1QUANTD,nLN1QUANTD)
Else																			/// SE ORDENADO POR BEM
	MsSeek(cFilSND+mv_par03+mv_par04+mv_par01,.T.)
	bWhile := {|| SND->ND_CBASE+SND->ND_ITEM <= mv_par05+mv_par06 }
	Cabec1 := PADR(cN1CBASE,nLN1CBASE)+" "+PADR(cN1ITEM,nLN1ITEM)+" "+PADR(cN1DESCRIC,nLN1DESCRIC)+" "+PADR(cN1CHAPA,nLN1CHAPA)+" "+PADC(cN1LOCAL,nLN1LOCAL)+PADL(cN1QUANTD,nLN1QUANTD)
	Cabec2 := PADR(cD0CODIGO,nLD0CODIGO)+" "+PADR(cD0MAT,nLD0MAT)+" "+PADR(cD0NOME,nLD0NOME)
Endif

While SND->(!EOF()) .AND. SND->ND_FILIAL == cFilSND .and. Eval(bWhile)
	
	If lAbortPrint
		@nLin,00 PSAY STR0007
		Exit
	Endif
	
	IncRegua(STR0008+SND->ND_CODRESP)

	If SND->ND_STATUS <> "1"													/// SE NAO ESTIVER ATIVO (PROXIMO)
		SND->(dbSkip())
		Loop
	Endif
	
	If SND->ND_CODRESP < mv_par01 .or. SND->ND_CODRESP > mv_par02 .or. (SND->ND_CBASE+SND->ND_ITEM < mv_par03+mv_par04) .or. (SND->ND_CBASE+SND->ND_ITEM > mv_par05+mv_par06)
		SND->(dbSkip())
		Loop
	Endif
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO
		nLin := 9
	Endif
	
	If aReturn[8] == 1															/// SE ORDENADO POR RESPONSAVEL
		dbSelectArea("RD0")
		dbSetOrder(1)
		cRespAtu	:= SND->ND_CODRESP
		cRD0Nome	:= ""
		cRD0MAT		:= ""
		
		If MsSeek(cFilRD0+cRespAtu,.F.)
			cRD0Nome	:= RD0->RD0_NOME
			cRD0MAT		:= RD0->RD0_FONE
		Endif
		
		@nLin,nColCODRESP	PSAY SND->ND_CODRESP
		@nLin,nColMAT		PSAY cRD0Mat
		@nLin,nColNOME		PSAY cRD0Nome
		nLin += 2
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO
			nLin := 9
		Endif
		
		While !SND->(Eof()) .and. SND->ND_FILIAL == cFilSND .AND. Eval(bWhile) .and. SND->ND_CODRESP == cRespAtu
			
			If SND->ND_STATUS <> "1"													/// SE NAO ESTIVER ATIVO (PROXIMO)
				SND->(dbSkip())
				Loop
			Endif
			
			If SND->ND_CODRESP < mv_par01 .or. SND->ND_CODRESP > mv_par02 .or. (SND->ND_CBASE+SND->ND_ITEM < mv_par03+mv_par04) .or. (SND->ND_CBASE+SND->ND_ITEM > mv_par05+mv_par06)
				SND->(dbSkip())
				Loop
			Endif
			
			dbSelectArea("SN1")
			dbSetOrder(1)
			If MsSeek(cFilSN1+SND->(ND_CBASE+ND_ITEM))			// SE NAO ENCONTRAR O BEM ASSOCIADO
				
				@nLin,nColCBASE		PSAY SN1->N1_CBASE
				@nLin,nColITEM		PSAY SN1->N1_ITEM
				@nLin,nColDESCRIC	PSAY SN1->N1_DESCRIC
				@nLin,nColCHAPA		PSAY SN1->N1_CHAPA
				@nLin,nColLOCAL		PSAY SN1->N1_LOCAL
				@nLin,nColQUANTD	PSAY SN1->N1_QUANTD PICTURE cPicQUANTD
				nLin++
				
				If nLin > 55
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR
					nLin := 9
				Endif
			Endif
			
			SND->(dbSkip())
			
		Enddo
	
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Else																		/// SE ORDENADO POR BEM
		cBemAtu		:= SND->(ND_CBASE+ND_ITEM)
		dbSelectArea("SN1")
		dbSetOrder(1)
		If MsSeek(cFilSN1+cBemAtu,.F.)
			
			@nLin,nColCBASE		PSAY SN1->N1_CBASE
			@nLin,nColITEM		PSAY SN1->N1_ITEM
			@nLin,nColDESCRIC	PSAY SN1->N1_DESCRIC
			@nLin,nColCHAPA		PSAY SN1->N1_CHAPA
			@nLin,nColLOCAL		PSAY SN1->N1_LOCAL
			@nLin,nColQUANTD	PSAY SN1->N1_QUANTD PICTURE cPicQUANTD
			nLin+=2
			
			If nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO
				nLin := 9
			Endif
			
			While !SND->(Eof()) .and. SND->ND_FILIAL == cFilSND .and. SND->(ND_CBASE+ND_ITEM) == cBemAtu
				
				If SND->ND_STATUS <> "1"													/// SE NAO ESTIVER ATIVO (PROXIMO)
					SND->(dbSkip())
					Loop
				Endif
				
				If SND->ND_CODRESP < mv_par01 .or. SND->ND_CODRESP > mv_par02 .or. (SND->ND_CBASE+SND->ND_ITEM < mv_par03+mv_par04) .or. (SND->ND_CBASE+SND->ND_ITEM > mv_par05+mv_par06)
					SND->(dbSkip())
					Loop
				Endif
				
				dbSelectArea("RD0")
				dbSetOrder(1)
				If MsSeek(cFilRD0+SND->ND_CODRESP,.F.)			// SE ENCONTRAR A PESSOA NO CADASTRO
					
					@nLin,nColCODRESP	PSAY SND->ND_CODRESP
					@nLin,nColMAT		PSAY RD0->RD0_FONE
					@nLin,nColNOME		PSAY RD0->RD0_NOME
					nLin++
					
					If nLin > 55
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO
						nLin := 9
					Endif
				Endif
				
				SND->(dbSkip())
			Enddo
			
			@nLin,000 PSAY __PrtThinLine()
			nLin++
		Else																					/// SE NAO ENCONTROU NO SN1
			SND->(dbSkip())
		Endif
	Endif
EndDo
        
dbSelectArea("SN1")										//// ABRE O ALIAS
If !Empty(aReturn[7])
	SET FILTER TO										//// LIMPA O FILTRO
Endif

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



