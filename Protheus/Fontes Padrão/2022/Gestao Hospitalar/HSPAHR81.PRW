#INCLUDE 'HSPAHR81.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'Topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR81  ºAutor  ³ Saude              º Data ³  14/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Quantidade de Partos e Nascidos por convenio. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHR81()
Local oReport

Private cGcsTipLoc := "3"	// Filtra o tipo de Setor (Postos de Enfermagem Internacao Tipo = "3")
 
Pergunte("HSPR81", .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// PARAMETROS                                          ³
// MV_PAR01	Data de Nascimento De ?                    ³
// MV_PAR02	Data de Nascimento Ate ?                   ³
// MV_PAR03	Setor de ?                                 ³
// MV_PAR04	Setor Ate ?                                ³
// MV_PAR05	Tipo de Parto ? (Cesarea, Normal ou Todos) ³
// MV_PAR06	Convenio De ?                              ³
// MV_PAR07	Convenio Ate ?                             ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
oReport := ReportDef() 
oReport:PrintDialog()  

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ReportDef ºAutor  ³ Saude              º Data ³  14/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicio da funcao do relatorio personalizavel.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport		// Objeto do relatório
Local oSection1		// Objeto da seção 1
Local oCell			// Obejot do cabeçalho
 
oReport := TReport():New("HSPAHR81",STR0001, "HSPR81", {|oReport| R81IMP(oReport)}, STR0002 + ; //"RELATÓRIO QUANTIDADE DE PARTOS E NASCIDOS POR CONVÊNIO"###"Este relatório tem por objetivo"
						STR0003) //" imprimir a quantidade partos e nascidos por convênio por período."
 
oReport:SetPortrait()

oSection1 := TRSection():New(oReport, STR0001, {"GB2"}) //"RELATÓRIO QUANTIDADE DE PARTOS E NASCIDOS POR CONVÊNIO"
oCell := TRCell():New(oSection1, " ",,STR0004,,17) 		//"CONVENIOS"
oCell := TRCell():New(oSection1, " ",,STR0005,,40) 		//"DATA REGIST NASC"
oCell := TRCell():New(oSection1, " ",,STR0006,,40) 		//"TIPO DE PARTO"
oCell := TRCell():New(oSection1, " ",,STR0007,,20) 		//"TOTAL"
   
Return(oReport)  
 
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R81Imp    ºAutor  ³ Saude              º Data ³  14/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicio da funcao do relatorio personalizavel.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R81Imp(oReport)
Local oSection1 := oReport:Section(1)
Local cCond		:= ""					// Variavel ira receber a condicao que sera passada, para o tipo de nascimento
Local cNreduz	:= ""					// Variavel ira receber o nome do convenio
Local nNormal	:= 0					// Quatidade de partos normais
Local nCesareas	:= 0					// Quantidade de cesareas
Local nNascV	:= 0					// Quantidade de Nascidos Vivos
Local nNascM	:= 0					// Quantidade de Nascidos Mortos
Local nPartosC	:= 0					// Total de partos por convenio
Local nNormalT	:= 0					// Total de partos normal no periodo
Local nCesareaT	:= 0					// Total de cesareas no periodo
Local nNascVT	:= 0					// Total de Nascidos Vivos no periodo
Local nNascMT	:= 0					// Total de Nascidos Mortos no periodo
Local nTotG		:= 0					// Total geral de Partos
Local cConv		:= ""					// Variavel auxiliar, para controle de quebra do convenio
Local dDatNasc	:= Space(8)				// Variavel auxiliar, para controle da quebra de data

If MV_PAR05 == 3			// Todos os tipo de nascimento
	cCond := "%(GB2.GB2_TIPO = '0' OR GB2.GB2_TIPO = '1')%"
ElseIf MV_PAR05 == 2		// Parto Normal
  	cCond := "%GB2.GB2_TIPO = '1'%"
Else						// Cesarea
 	cCond := "%GB2.GB2_TIPO = '0'%"
EndIf

MakeSqlExp("HSPR81")
oSection1:BeginQuery()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
//³GB2->STNASC -> 1=Nativivo;2=Natimorto;3=Obito Fetal³
//³GB2->TIPO -> 0=Cesarea;1=Normal                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			 
BeginSql Alias "QRYGB2"

	SELECT GA9_CODCON, GA9_NREDUZ, GB2_DTNASC, GB2_TIPO TIPOPARTO  ,GB2_STNASC TIPONACTO, COUNT(*) TOTAL
	FROM %table:GB2% GB2
	 LEFT JOIN %table:GCZ% GCZ ON GCZ_FILIAL = %xfilial:GCZ% AND GCZ.GCZ_REGATE = GB2.GB2_REGATE AND GCZ.%notDel% 
	      LEFT JOIN %table:GA9% GA9 ON GA9_FILIAL = %xfilial:GA9% AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.%notDel%
	          LEFT JOIN %table:GCY% GCY ON GCY_FILIAL = %xfilial:GCY% AND GCY.GCY_REGATE = GB2.GB2_REGATE AND GCY.%notDel%
	 		     LEFT JOIN %table:GCS% GCS ON GCS_FILIAL = %xfilial:GCS% AND GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.%notDel%
	WHERE GB2.GB2_FILIAL = %xFilial:GB2% 
	  AND GB2.GB2_NRODEC <> '          '
	  AND GB2.GB2_DTNASC BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
	  AND GCS.GCS_CODLOC BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
	  AND %Exp:cCond%
	  AND GA9.GA9_CODCON BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	  AND GB2.%notDel%
	GROUP BY GA9_CODCON, GA9_NREDUZ, GB2_DTNASC, GB2_TIPO, GB2_STNASC, GCS_CODLOC
	ORDER BY GA9_CODCON, GB2_DTNASC, TIPONACTO
	
EndSql

oSection1:EndQuery()

oSection1:Init()
oSection1:PrintLine()
oSection1:Finish() 

DbSelectArea("QRYGB2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pego o convenio, data de nascimento e nome do convenio, para controlar a quebra, e certificar que ³
//³o primeiro registro sera guardado, para ser impresso.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cConv 		:= QRYGB2->GA9_CODCON
cNreduz		:= QRYGB2->GA9_NREDUZ
dDatNasc	:= QRYGB2->GB2_DTNASC

While !Eof() .AND. !oReport:Cancel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se no registro atual quebrar por convenio ou data, sera impresso sempre o registro anterior,      ³
	//³pois sempre guardo os valores de cada registro da query, e quando encontro uma quebra, imprimo os ³
	//³dados que estao nas variaveis, e zero os contadores do convenio, para gerar do proximo registro   ³
	//³que sera guardado.                                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cConv <> QRYGB2->GA9_CODCON .OR. dDatNasc <> QRYGB2->GB2_DTNASC
		oReport:SkipLine(1)
		// Impressao do convenio anterior
		oReport:PrintText(cNreduz, oReport:Row(), 10) 
		oReport:PrintText(DTOC(dDatNasc), oReport:Row(), 255)
		
		oReport:PrintText(STR0009, oReport:Row(), 830) //"NORMAL"
		oReport:PrintText(TransForm(nNormal,"@E 999999"), oReport:Row(), 1405)
		oReport:SkipLine(2)
		
		oReport:PrintText(STR0010, oReport:Row(), 830) //"CESAREAS"
		oReport:PrintText(TransForm(nCesareas,"@E 999999"), oReport:Row(), 1405)
		oReport:SkipLine(2)
		
		oReport:PrintText(STR0011, oReport:Row(), 830) //"NASCIDOS VIVOS"
		oReport:PrintText(TransForm(nNascV,"@E 999999"), oReport:Row(), 1405)
		oReport:SkipLine(2)
		
		oReport:PrintText(STR0012, oReport:Row(), 830) //"NASCIDOS MORTOS"
		oReport:PrintText(TransForm(nNascM,"@E 999999"), oReport:Row(), 1405)
		oReport:SkipLine(2)

	   	nNormal		:= 0
	    nCesareas	:= 0
		nNascV		:= 0
		nNascM		:= 0

	EndIf	
    
	If cConv <> QRYGB2->GA9_CODCON		// Se mudar o convenio, imprime subtotal dos partos
		oReport:SkipLine(1)
		oReport:PrintText(STR0013, oReport:Row(), 600) //"TOTAL DE PARTOS DO CONVÊNIO NO PERÍDO:"
		oReport:PrintText(TransForm(nPartosC,"@E 999999"), oReport:Row(), 1405)
		oReport:SkipLine(1)
		oReport:PrintText("____________________________________________________________________________________________________________________", oReport:Row(), 10)
		oReport:SkipLine(3)
		nPartosC := 0					// Zero a quantidade de partos por convenio
		oReport:EndPage()				// Quebra página quando tiver quebra de convenio
	EndIf

	If QRYGB2->TIPOPARTO == "0"
		nCesareas += QRYGB2->TOTAL		// Cesareas
		nCesareaT += QRYGB2->TOTAL		// Total de Cesareas
	Else
		nNormal  += QRYGB2->TOTAL		// Normal
		nNormalT += QRYGB2->TOTAL		// Total de partos Normais
	EndIf
		
	If QRYGB2->TIPONACTO == "1"
		nNascV  += QRYGB2->TOTAL		// Nascidos Vivos
		nNascVT += QRYGB2->TOTAL		// Total de nascidos vivos
	Else
		nNascM  += QRYGB2->TOTAL		// Nascidos Mortos
		nNascMT += QRYGB2->TOTAL		// Total de nascidos mortos
	EndIf

	nPartosC 	+= QRYGB2->TOTAL				// Totaliza os partos no periodo
	nTotG 		+= QRYGB2->TOTAL				// Totaliza os partos em geral

	cConv		:= QRYGB2->GA9_CODCON		// Atualizo o convenio com o mesmo do restro atual, para comparar com o proximo registro
	cNreduz		:= QRYGB2->GA9_NREDUZ		// Atualizo o nome do convenio
	dDatNasc 	:= QRYGB2->GB2_DTNASC		// Atualizo a data de Nascimento com a data do resitro atual, para comparar com o proximo registo

	DbSkip()
End

oReport:SkipLine(1)
If oReport:PageBreak()
	oReport:PrintHeader() 
EndIf

// Impressao do ultimo registro de convenio
oReport:PrintText(cNreduz, oReport:Row(), 10) 
oReport:PrintText(DTOC(dDatNasc), oReport:Row(), 255)
		
oReport:PrintText(STR0009, oReport:Row(), 830) //"NORMAL"
oReport:PrintText(TransForm(nNormal,"@E 999999"), oReport:Row(), 1405)
oReport:SkipLine(2)
		
oReport:PrintText(STR0010, oReport:Row(), 830) //"CESAREAS"
oReport:PrintText(TransForm(nCesareas,"@E 999999"), oReport:Row(), 1405)
oReport:SkipLine(2)

oReport:PrintText(STR0011, oReport:Row(), 830) //"NASCIDOS VIVOS"
oReport:PrintText(TransForm(nNascV,"@E 999999"), oReport:Row(), 1405)
oReport:SkipLine(2)
		
oReport:PrintText(STR0012, oReport:Row(), 830) //"NASCIDOS MORTOS"
oReport:PrintText(TransForm(nNascM,"@E 999999"), oReport:Row(), 1405)
oReport:SkipLine(3)

// Impressão do total por convenio do último convenio
oReport:PrintText(STR0013, oReport:Row(), 600) //"TOTAL DE PARTOS DO CONVÊNIO NO PERÍDO:"
oReport:PrintText(TransForm(nPartosC,"@E 999999"), oReport:Row(), 1405)
oReport:SkipLine(1)
oReport:PrintText("____________________________________________________________________________________________________________________", oReport:Row(), 10)

// Quebra página para imprimir os totais gerais
oReport:EndPage()

// Impressão dos totais gerais
oReport:SkipLine(2)
oReport:PrintText(STR0014, oReport:Row(), 830) //"RESUMO TOTAL DO PERIODO"
oReport:SkipLine(2)
oReport:PrintText(STR0015, oReport:Row(), 10) //"TOTAL GERAL DE PARTOS.........."
oReport:PrintText(TransForm(nTotG,"@E 999999"), oReport:Row(), 490)
oReport:PrintText(STR0016, oReport:Row(), 1300) //"PARTO NORMAL..............."
oReport:PrintText(TransForm(nNormalT,"@E 999999"), oReport:Row(), 1720)
oReport:SkipLine(2)
oReport:PrintText(STR0017, oReport:Row(), 1300) //"PARTO CESÁREA.............."
oReport:PrintText(TransForm(nCesareaT,"@E 999999"), oReport:Row(), 1720)
oReport:SkipLine(2)
oReport:PrintText(STR0018, oReport:Row(), 1300) //"NASCIDOS VIVOS............."
oReport:PrintText(TransForm(nNascVT,"@E 999999"), oReport:Row(), 1720)
oReport:SkipLine(2)
oReport:PrintText(STR0019, oReport:Row(), 1300) //"NASCIDOS MORTOS............"
oReport:PrintText(TransForm(nNascMT,"@E 999999"), oReport:Row(), 1720)
oReport:SkipLine(3)

oReport:SkipLine(1)
If oReport:PageBreak()
	oReport:PrintHeader() 
EndIf  

Return(Nil)