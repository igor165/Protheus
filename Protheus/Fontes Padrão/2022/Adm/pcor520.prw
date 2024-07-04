#INCLUDE "pcor520.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE CELLTAMDATA 420

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR520  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao do demonstrativo saldo/Periodo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR520                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao do demonstrativo saldo/periodo         ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR520(aPerg)

Local aArea	  	:= GetArea()
Local lPrint	:=	.T.

Private oReport
Private aPeriodos := {}
private nHeight	:= 0 // Tamanho total em Pixel de um nivel do cubo
Default aPerg 	  := {}

If Len(aPerg) == 0
	lPrint := Pergunte("PCR520",.T.)	
Else
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
EndIf
If lPrint	
			aPeriodos := PcoRetPer( MV_PAR02/*dIniPer*/, MV_PAR03/*dFimPer*/, MV_PAR05/*cTipoPer*/, MV_PAR06==1/*lAcumul*/)
			If Len(aPeriodos) > 0
				If Len(aPeriodos) > 100
				   Aviso(STR0056, STR0059, {"Ok"})   //"Atencao"###"Consulta limitada a 100 periodos no maximo. Verifique a periodicidade."  
				Else
		   			oReport := PCOR520Def( MV_PAR01 )	// Codigo do Cubo
					oReport:PrintDialog()
				EndIf
			EndIf
Endif
	
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOR520Defº Autor ³ Gustavo Henrique   º Data ³  12/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Codigo do cubo em que o relatorio deve ser impressoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOR520Def( cCubo )

Local cReport	:= "PCOR520" 	// Nome do relatorio
Local aNiveis	:= {}
Local aSections := {}
            
Local nTotSec	:= 0
Local nTotPer	:= 0
Local nSection	:= 1	// Contador de secoes
Local nSldPer	:= 1	// Contador de celulas de saldos por periodo
Local nX, nSections
Local nTam		:= 5 //Valor adicionado para ajustar a apresentação do título referente aos períodos   

Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New( cReport, STR0001,'PCR520', { |oReport| PrintReport( oReport, aNiveis, aSections ) }, STR0024 ) // "Cubos Comparativos - Demonstrativo de Saldos por Periodo" ### "Este relatorio ira imprimir o Cubos Comparativos - Demonstrativo de Saldos por Periodo de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes do relatorio a partir dos niveis do cubo selecionado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := PCOTRCubo( @oReport, cCubo, @aNiveis, @aSections )

oReport:ParamReadOnly()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes especificas do relatorio                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotSec := Len( aSections )
nTotPer := Len( aPeriodos )

For nSection := 1 To nTotSec
	TRCell():New( aSections[nSection], "MOVIMENTOS", /*Alias*/, STR0026 /*Titulo*/, /*Picture*/, 20 /*Tamanho*/, .T.)	// "Movimentos"
	For nSldPer := 1 To nTotPer
		TRCell():New( aSections[nSection], aPeriodos[ nSldPer ],/*Alias*/, aPeriodos[ nSldPer ] /*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,Len(aPeriodos[ nSldPer ])+ nTam/*Tamanho*/,.T.,/*{||}*/,"RIGHT",,"RIGHT")
	Next nSldPer
Next nSection

oDescComp := TRSection():New( oReport, STR0025 )	// "Comparativo entre configurações" 

TRCell():New( oDescComp, "DESCRI_COMP1",/*Alias*/,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)
TRCell():New( oDescComp, "DESCRI_COMP2",/*Alias*/,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)

oDescComp:SetHeaderPage()

nSections	:= Len( aSections )		// Total de secoes desconsiderando a ultima referente ao grupo de perguntas

For nX := 1 To nSections
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza tamanho das celulas de codigo e descricao do nivel do cubo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSections[nX]:Cell(aNiveis[nX,2]):SetSize( 25, .F. )
	aSections[nX]:Cell(aNiveis[nX,3]):SetSize( 40, .F. )
	aSections[nX]:Cell(aNiveis[nX,3]):SetLineBreak()

Next

Return oReport      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PrintReport ºAutor³ Gustavo Henrique   º Data ³  12/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao das secoes do relatorio definida em cima da      º±±
±±º          ³ configuracao do cubo no array aSections.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±º          ³ EXPA2 - Array com os niveis do cubo selecionado            º±±
±±º          ³ EXPA3 - Array com os objetos das secoes de cada nivel      º±±
±±º          ³ EXPA4 - Array com os periodos selecionados para impressao  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport( oReport, aNiveis, aSections )

Local nX			:= 1
Local lInc			:= .F.
Local cConfig1		:= ""
Local cConfig2		:= ""

Local aAcessoCfg_1
Local aAcessoCfg_2

Local aProcCube := {}
Local aConfig 	:= {}
Local cCodCube
Local cCfg_1
Local cCfg_2
Local oStructCube_1
Local oStructCube_2
Local aParametros
Local lZerado
Local lEditCfg1
Local lEditCfg2
Local cWhereTpSld_1
Local cWhereTpSld_2
Local dDataIni, dDataFim, lAcumul, nTpPer
Local aPerAux := {}

Local nMoeda
Local lContinua := .T.

Private aSavPar		:= {}
Private aProcessa	:= {}
Private aProcComp	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte do Relatorio                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
01 - Codigo Cubo Gerencial ?
02 - Periodo de ?
03 - Periodo Ate ?
04 - Qual Moeda ?
05 - Tipo Periodo ?
06 - Acumulado ?
07 - Configuracao do Cubo-1 ?
08 - Editar Configuracoes Cubo-1 ?
09 - Configuracao do Cubo-2 ?
10 - Editar Configuracoes Cubo-2 ?
11 - Considera Zerados ?
12 - Total Geral no Resumo ?
13 - Considerar Cfg. 1 Cubo ?
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva parametros para nao conflitar com parambox                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSavPar   := { MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10, MV_PAR11, MV_PAR12, MV_PAR13 }

cCodCube := MV_PAR01
dDataIni := MV_PAR02 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)
dDataFim := MV_PAR03 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)

If ValType(MV_PAR04) == "C"
	nMoeda := Val(MV_PAR04)
Else
	nMoeda := MV_PAR04
EndIf

nTpPer  := MV_PAR05
lAcumul := ( MV_PAR06 == 1 )

cCfg_1 := MV_PAR07
lEditCfg1 := ( MV_PAR08 == 1 )

cCfg_2 := MV_PAR09
lEditCfg2 := ( MV_PAR10 == 1 )

lZerado := ( MV_PAR11 == 1 )

If SuperGetMV("MV_PCOCNIV",.F., .F.)

	//modo utilizando querys para buscar os saldos nas datas em bloco
	//verificar se usuario tem acesso as configuracoes do cubo
	aAcessoCfg_1 := PcoVer_Acesso( cCodCube, cCfg_1 )  	//retorna posicao 1 (logico) .T. se tem acesso
	   													//							.F. se nao tem
	   													//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera 
	lContinua := aAcessoCfg_1[1]
	
	If lContinua 
		aAcessoCfg_2 := PcoVer_Acesso( cCodCube, cCfg_2 )  	//retorna posicao 1 (logico) .T. se tem acesso
	   												   		//							.F. se nao tem
		   													//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera 
		lContinua := aAcessoCfg_2[1]

	EndIf

	If ! lContinua

		Aviso(STR0056, STR0057,{"Ok"}) //"Atencao"###"Usuario sem acesso ao relatorio. Verifique as configuracoes."

	Else
	

		oStructCube_1 := PcoStructCube( cCodCube, cCfg_1 )
				
		If Empty(oStructCube_1:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
			lContinua := .F.
		EndIf
	                
		If lContinua

			PcoRetPer( aSavPar[02]-1/*dIniPer*/, aSavPar[03]/*dFimPer*/, aSavPar[05]/*cTipoPer*/, aSavPar[06]==1/*lAcumul*/, aPerAux)
	
			lContinua := Len(aPerAux) > 0
			
			If lContinua

				//monta array aParametros para ParamBox
				aParametros := PcoParametro( oStructCube_1, lZerado, aAcessoCfg_1[1]/*lAcesso*/, aAcessoCfg_1[2]/*nDirAcesso*/ )
		
		        //exibe parambox para edicao ou visualizacao
				Pco_aConfig(aConfig, aParametros, oStructCube_1, lEditCfg1/*lViewCfg*/, @lContinua)
					
				lZerado	:=	aConfig[Len(aConfig)-1]          //penultimo informacao da parambox (check-box)
				lSintetica	:=	aConfig[Len(aConfig)]        //ultimo informacao da parambox (check-box)
				//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
				cWhereTpSld_1 := ""
				If oStructCube_1:nNivTpSld > 0 .And. ;
					oStructCube_1:aIni[oStructCube_1:nNivTpSld] == oStructCube_1:aFim[oStructCube_1:nNivTpSld] .And. ;
					Empty(oStructCube_1:aFiltros[oStructCube_1:nNivTpSld])
						cWhereTpSld_1 := " AKT.AKT_TPSALD = '" + oStructCube_1:aIni[oStructCube_1:nNivTpSld] + "' AND "
				EndIf								
						
				aProcCube := { aPerAux, oStructCube_1, aAcessoCfg_1, lZerado, lSintetica, cWhereTpSld_1, lAcumul }
	
				aProcessa := PcoProcCubo(aProcCube, nMoeda, Len(aPerAux)/*nQtdVal*/)
					
			EndIf

			Pergunte( "PCR520" , .F. )
		EndIf

		If lContinua

			oStructCube_2 := PcoStructCube( cCodCube, cCfg_2 )
				
			If Empty(oStructCube_2:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
				lContinua := .F.
			EndIf
	                
			If lContinua
	
				//monta array aParametros para ParamBox
				aParametros := PcoParametro( oStructCube_2, lZerado, aAcessoCfg_2[1]/*lAcesso*/, aAcessoCfg_2[2]/*nDirAcesso*/ )
		
		        //exibe parambox para edicao ou visualizacao
				Pco_aConfig(aConfig, aParametros, oStructCube_2, lEditCfg1/*lViewCfg*/, @lContinua)
						
				If lContinua
					lZerado	:=	aConfig[Len(aConfig)-1]          //penultimo informacao da parambox (check-box)
					lSintetica	:=	aConfig[Len(aConfig)]        //ultimo informacao da parambox (check-box)
					//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
					cWhereTpSld_2 := ""
					If oStructCube_2:nNivTpSld > 0 .And. ;
						oStructCube_2:aIni[oStructCube_2:nNivTpSld] == oStructCube_2:aFim[oStructCube_2:nNivTpSld] .And. ;
						Empty(oStructCube_2:aFiltros[oStructCube_2:nNivTpSld])
							cWhereTpSld_2 := " AKT.AKT_TPSALD = '" + oStructCube_2:aIni[oStructCube_2:nNivTpSld] + "' AND "
					EndIf								
							
					aProcCube := { aPerAux, oStructCube_2, aAcessoCfg_2, lZerado, lSintetica, cWhereTpSld_2, lAcumul}
		
					aProcComp := PcoProcCubo(aProcCube, nMoeda, Len(aPerAux)/*nQtdVal*/)
						
				EndIf
			
			EndIf

			Pergunte( "PCR520" , .F. )
	    
		EndIf	
		
	EndIf

Else

	//modo atual utilizando a funcao pcoruncube()
	//processamento do relatorio
	aProcessa := PcoRunCube(aSavPar[1], Len(aPeriodos)*4, "Pcor520Sld", aSavPar[7], aSavPar[8] , (aSavPar[11]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
	aProcComp := PcoRunCube(aSavPar[1], Len(aPeriodos)*4, "Pcor520Sld", aSavPar[9], aSavPar[10], (aSavPar[11]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
	
EndIf	

AL3->( dbSetOrder( 1 ) )

If Len(aProcessa) > 0
	cConfig1 := aProcessa[1,13]
Else
	AL3->( MsSeek( xFilial("AL3") + MV_PAR07 ) )
	cConfig1 := AllTrim(AL3->AL3_DESCRI)
Endif

If Len(aProcComp) > 0
	cConfig2 := aProcComp[1,13]
Else
	AL3->( MsSeek( xFilial("AL3") + MV_PAR09 ) )
	cConfig2 := AllTrim(AL3->AL3_DESCRI)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona no aProcessa de origem as chaves de cubo so existem no destino                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aProcComp)
	If aScan(aProcessa,{|x| x[9]== aProcComp[nX][9]}) == 0
		AAdd(aProcessa,aClone(aProcComp[nX]))
		aProcessa[Len(aProcessa),13] := cConfig1
		aFill(aProcessa[Len(aProcessa),2],0)
		lInc := .T.
	Endif
Next	

If lInc
	aSort(aProcessa,,,{|x,y| x[9]<y[9]})
Endif

R520Imp( oReport, aProcessa, aSections, aNiveis, aPeriodos, cConfig1, cConfig2 )
	
Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R520Imp  ºAutor  ³ Gustavo Henrique   º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime os relatorios nas opcoes do parametro MV_PAR10     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport para impressao                      º±±
±±º          ³ EXPA2 - Array com os valores por periodo                   º±±
±±º          ³ EXPA3 - Array com os objetos das secoes                    º±±
±±º          ³ EXPA4 - Array com os niveis do cubo selecionado            º±±
±±º          ³ EXPA5 - Array com os periodos selecionados para impressao  º±±
±±º          ³ EXPC6 - Descricao da 1a. configuracao de cubo (mv_par07)   º±±
±±º          ³ EXPC7 - Descricao da 2a. configuracao de cubo (mv_par09)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R520Imp( oReport, aProcessa, aSections, aNiveis, aPeriodos, cConfig1, cConfig2 )

Local nX		:= 1					// Contador generico
Local nLinImp	:= 0
Local nNivAtu 	:= 0
Local nTotLin	:= 0
Local nLoop		:= 1                             
Local nPerAtu	:= 0
Local nPosComp	:= 0					// Posicao do aProcessa no aPosComp
Local nSections	:= Len( aSections )		// Total de secoes desconsiderando a ultima referente ao grupo de perguntas
Local nTotRecs	:= Len( aProcessa )
Local nTotPer	:= Len( aPeriodos )		// Total de periodos

Local lChangeNiv:= .T.					// Indica se houve troca de nivel durante a impressao do relatorio

Local bShowCod	:= { ||		aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):ShowHeader(),;
							aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):Show() } 
							
Local bShowDes	:= { ||		aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):ShowHeader(),;
							aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):Show() }

Local bHideCod	:= { |lParam|	aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):HideHeader(),;
								If( lParam, .T., aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):Hide() ) }
							
Local bHideDes	:= { || 	aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):HideHeader(),;
							aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):Hide() }

Local aLinTit	:= {	STR0005,;	//"Saldo Inicial (A1): "
						STR0006,;	//"Saldo Inicial (A2): "
						STR0007,;	//"Diferenca (A1-A2):"
						STR0008,;	//"Dif. (A2/A1 %):"
						STR0009,;	//"Mov.Credito (C1):"
						STR0010,;	//"Mov.Credito (C2):"
						STR0011,;	//"Diferenca (C1-C2):"
						STR0012,;	//"Dif. (C2/C1 %):"
						STR0013,;	//"Mov.Debito (D1)"
						STR0014,;	//"Mov.Debito (D2)"
						STR0015,;	//"Diferenca (D1-D2):"
						STR0016,;	//"Dif. (D2/D1 %):"
						STR0017,;	//"Res.Mov.(C1 - D1):"
						STR0018,;	//"Res.Mov.(C2 - D2):"
						STR0019,;	//"Diferenca Res.:"
						STR0020 } 	//"Dif. Res. (%):"

If nTotRecs > 0

	Pergunte("PCR520",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza conteudo das celulas com o valor que deve ser impresso a partir do array aProcessa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To nSections
	    
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza conteudo das colunas codigo e descricao                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSections[nX]:Cell(aNiveis[nX,2]):SetBlock( { || If( nLinImp == 1 .And. lChangeNiv, aNiveis[aProcessa[nLoop,8],5], aProcessa[nLoop,9] ) } )
		aSections[nX]:Cell(aNiveis[nX,3]):SetBlock( { || aProcessa[nLoop,6]  } )
	
		aSections[nX]:SetRelation( { || xFilial( aNiveis[nLoop][1] ) + aProcessa[nLoop,14] }, aNiveis[nLoop][1], 3, .T. )
		aSections[nX]:SetAutoSize(.T.)
	
	Next
	
	oReport:Section(2):Cell("DESCRI_COMP1"):SetTitle( STR0021 + cConfig1 +" (1)" )	// "COMPARATIVO ENTRE A CONFIGURACAO: "
	oReport:Section(2):Cell("DESCRI_COMP2"):SetTitle( STR0022 + cConfig2 +" (2)" )	// " E A CONFIGURAÇÃO: "
	
	oReport:SetLandScape()
	oReport:SetMeter( nTotRecs )
	
	Do While !oReport:Cancel() .And. nLoop <= nTotRecs
	                                         
		If oReport:Cancel()  
			oReport:PrintText(STR0021) //"Impressao cancelada pelo operador..."
			Exit
		EndIf
	
		oReport:IncMeter()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza impressao da secao atual, caso for maior que a proxima secao              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nNivAtu <> aProcessa[nLoop,8] 
			For nX := nNivAtu To aProcessa[nLoop,8] Step - 1
				aSections[nNivAtu]:Finish()
			Next nX	
	  	EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia impressao da proxima secao, caso a atual for diferente da secao anterior    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lChangeNiv 	:= (nNivAtu <> aProcessa[nLoop,8])
		nNivAtu		:= aProcessa[nLoop,8]
		
		If lChangeNiv
			aSections[nNivAtu]:Init()
			nTotLin := 2	// Duas linhas para troca de nivel, sendo na 1a. nome do nivel e na 2a o detalhe
		Else
			nTotLin := 1	// Uma linha com o detalhe do nivel
		EndIf

 		If nLoop>1
	 		If oReport:GetOrientation()==1
		 		 If (oReport:nRow - nHeight) > 2853
		 		 	oReport:EndPage()
		 		 EndIf
	 		Else
		 		 If (oReport:nRow - nHeight) > 1553
		 		 	oReport:EndPage()
		 		 EndIf 			
	 		EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o nome do nivel da chave do cubo na 1a. linha e o detalhe da chave na 2a.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If nLoop==1
		 	nHeight := oReport:nRow
	 	EndIf
	 	For nLinImp := 1 To nTotLin
	 				 		
	 		If nLinImp == 1 .And. lChangeNiv
	                                 
	 			aSections[ nNivAtu ]:Cell( "MOVIMENTOS" ):Disable()
					
				For nPerAtu := 1 To nTotPer
		 			aSections[ nNivAtu ]:Cell( aPeriodos[ nPerAtu ] ):Disable()
		 		Next nPerAtu			
	
				Eval( bHideCod, .F. )
				Eval( bHideDes )	
	
				aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):Show()
	 			aSections[ nNivAtu ]:PrintLine()
	
		 	Else
	
				If !lChangeNiv
					aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 2 ] ):Show()
				EndIf
				Eval( bShowDes )			
				
				R520ImpDet(	oReport, aSections, aPeriodos, aNiveis, { bHideCod, bHideDes },;
							nNivAtu, nTotPer, nLoop, aLinTit )
	 				
	 		EndIf
	
	 	Next nLinImp    
	    
   	 	If nLoop==1
		 	nHeight := oReport:nRow - nHeight
	 	EndIf
	    
		nLoop ++
		
	EndDo        
	
	For nX := nNivAtu To 1 Step -1
		aSections[ nX ]:Finish()
	Next nX

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R520ImpDetºAutor  ³ Gustavo Henrique   º Data ³  14/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao do relatorio detalhado. Parametro MV_PAR10       º±±
±±º          ³ igual a 2.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport para impressao                      º±±
±±º          ³ EXPA2 - Array com os objetos das secoes                    º±±
±±º          ³ EXPA3 - Array com os periodos selecionados para impressao  º±±
±±º          ³ EXPA4 - Array com os niveis do cubo selecionado            º±±
±±º          ³ EXPA5 - Array com os code blocks para desabilitar a        º±±
±±º          ³         impressao dos campos Codigo e Descricao do cubo    º±±
±±º          ³ EXPN6 - Nivel atual de impressao do cubo                   º±±
±±º          ³ EXPN7 - Total de periodos selecionados para impressao      º±±
±±º          ³ EXPN8 - Linha atual do vetor aProcessa                     º±±
±±º          ³ EXPN9 - Array com os titulos das linhas de movimentos      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R520ImpDet(	oReport, aSections, aPeriodos, aNiveis, aHide,;
							nNivAtu, nTotPer, nLoop, aLinTit )

Local cBlock	:= ""				// Bloco de codigo com a expressa para impressao do conteudo das celulas
Local cPosProc	:= ""				// Posicao no aProcessa
Local cPosComp	:= ""				// Posicao no aProcComp
Local cValProc	:= ""				// Valor do aProcessa ou aProcComp

Local aCelHide	:= {}

Local nPerAtu	:= 1				// Contador de periodo atual
Local nColPer	:= 1				// Contador das colunas referentes ao periodo de cada linha de movimento
Local nLinMov	:= 1				// Contador de linhas de movimento
Local nLinTit	:= 1				// Contador de linhas de titulo dos movimentos
Local nBlocoImp	:= 1				// Bloco de impressao atual. Total de 4 blocos cada um com 4 linhas de movimento 
Local nLenTit	:= Len( aLinTit )	// Tamanho dos titulos das 4 linhas de movimentos
Local nPosComp	:= 0				// Posicao do aProcessa no aPosComp

Local nX		:= 1		// Contador generico

nPosComp := aScan(aProcComp, { |x| x[1] == aProcessa[nLoop][1] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia impressao na 3a. coluna subsequente as colunas de codigo e descricao do nivel do cubo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSections[ nNivAtu ]:Cell( "MOVIMENTOS" ):Enable()

For nPerAtu := 1 To nTotPer Step 4
                    
	aCelHide 	:= {}
	nBlocoImp 	:= 1
	
	For nLinTit := 1 To nLenTit Step 4

		For nLinMov := 1 To 4		// Linhas de movimentos 
	                                                     
			aSections[ nNivAtu ]:Cell( "MOVIMENTOS" ):SetValue( aLinTit[ nLinMov + (nLinTit-1) ] )
	
			For nColPer := nPerAtu To (nPerAtu + 3)		// Total de 4 colunas para periodos
	                            
				If nColPer <= nTotPer             
                        
   		cPosProc := AllTrim( Str( nLoop ) )
   		cPosComp := AllTrim( Str( nPosComp ) ) 
    				cValProc := AllTrim( Str( nBlocoImp + ( 4 * ( nColPer-1 ) ) ) )

					Do Case
			    
									Case nLinMov == 1	// Movimento 1 - Ex.: Mov.Credito (C1)

							If  Val(cValProc) <= Len(aProcessa[Val(cPosProc),2])
			 					cBlock := "{ || aProcessa[ " + cPosProc + ", 2, " + cValProc + " ] }"
							Else
				 				cBlock := "{ || 0 }"             
							EndIf	

									Case nLinMov == 2	// Movimento 2 - Ex.: Mov.Credito (C2)
							If nPosComp > 0 .And. Val(cValProc) <= Len(aProcComp[Val(cPosComp),2]) 
				 				cBlock := "{ || aProcComp[ " + cPosComp + ", 2, " + cValProc + " ] }"
							Else
				 				cBlock := "{ || 0 }"             
							EndIf	
						
									Case nLinMov == 3	// Movimento 1-Movimento 2 - Ex.: Diferenca (C1-C2)
							If nPosComp > 0 .And. Val(cValProc) <= Len(aProcessa[Val(cPosProc),2]) .And. Val(cValProc) <= Len(aProcComp[Val(cPosComp),2])   
				 				cBlock := "{ || aProcessa[ "+cPosProc+", 2, "+cValProc+" ] - aProcComp[ "+cPosComp+", 2, "+cValProc+" ] }"
							Else
								If  Val(cValProc) <= Len(aProcessa[Val(cPosProc),2]) 
					 				cBlock := "{ || aProcessa[ "+cPosProc+", 2, "+cValProc+" ] }"
								Else
				 					cBlock := "{ || 0 }"
				 				EndIf             
							EndIf	
						
									Case nLinMov == 4	// Movimento 2/Movimento 1 - Ex.: Dif. (C2/C1 %)
							If nPosComp > 0 .And. Val(cValProc) <= Len(aProcessa[Val(cPosProc),2]) .And. Val(cValProc) <= Len(aProcComp[Val(cPosComp),2])  
				 				cBlock := "{ || aProcComp[ "+cPosComp+", 2, "+cValProc+" ] / aProcessa[ "+cPosProc+", 2, "+cValProc+" ] * 100 }"
							Else
				 				cBlock := "{ || 0 }"             
							EndIf	
						
					EndCase

					aSections[ nNivAtu ]:Cell( aPeriodos[ nColPer ] ):SetBlock( MontaBlock( cBlock ) )
                                                    
					If nLinMov == 1                           
		 				aSections[ nNivAtu ]:Cell( aPeriodos[ nColPer ] ):Enable()
						AAdd( aCelHide, aPeriodos[ nColPer ] )
		EndIf
                                                     		
	 			EndIf

		 	Next nColPer
	                        
			If nLinTit == 1 .And. nLinMov == 1
		aSections[ nNivAtu ]:PrintHeader()
	EndIf

	aSections[ nNivAtu ]:PrintLine()
                 
			If nLinMov == 1
	            Eval( aHide[1], .F. )
				Eval( aHide[2] )
				aSections[ nNivAtu ]:Cell( "MOVIMENTOS" ):HideHeader()
			EndIf
	                
		Next nLinMov
		                                     
		nBlocoImp ++
		
        oReport:ThinLine()
		
	Next nLinTit

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilita celulas jah impressas antes da quebra de periodos            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCelHide )
		aSections[ nNivAtu ]:Cell( aCelHide[ nX ] ):Disable()
	Next nX                               

Next nPerAtu

aSections[ nNivAtu ]:Cell( "MOVIMENTOS" ):ShowHeader()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pcor520Sld³ Autor ³ Edson Maricate        ³ Data ³18/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento do demonstrativo saldo / periodo.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Pcor520Sld                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pcor520Sld(cConfig,cChave)

Local aRetorno := {}
Local aRetIni,aRetFim
Local nCrdIni
Local nDebIni
Local nCrdFim
Local nDebFim
Local ny

For ny := 1 to Len(aPeriodos)

	dIni := CtoD(Subs(aPeriodos[ny],1,10))
	dFim := CtoD(Subs(aPeriodos[ny],14))

	aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
	nCrdIni := aRetIni[1, aSavPar[4]]
	nDebIni := aRetIni[2, aSavPar[4]]

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aSavPar[4]]
	nDebFim := aRetFim[2, aSavPar[4]]

	nSldIni := nCrdIni-nDebIni
	nMovCrd := nCrdFim-nCrdIni	
	nMovDeb := nDebFim-nDebIni
	nMovPer := nMovCrd-nMovDeb

	aAdd(aRetorno,nSldIni)
	aAdd(aRetorno,nMovCrd)
	aAdd(aRetorno,nMovDeb)
	aAdd(aRetorno,nMovPer)

Next

Return aRetorno

//------------------------------------------------------------------------------------------------------------------//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoProcCubo ºAutor  ³Paulo Carnelossi    º Data ³ 03/10/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta as querys baseados nos parametros e configuracoes de  º±±
±±º          ³cubo e executa essas querys para gerar os arquivos tempora- º±±
±±º          ³rios cujos nomes sao devolvidos no array aTabResult         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoProcCubo(aProcCube, nMoeda, nQtdVal)

Local cCodCube
Local cArquivo 		:= ""
Local aQueryDim, cArqTmp
Local nZ

Local cWhereTpSld 	:= ""
Local cWhere 		:= ""
Local nNivel 		:= 1 //sempre processar a partir do primeiro nivel
Local aCposNiv 		:= {}
Local aFilesErased 	:= {}
Local aProcCub 		:= {}
Local cArqAS400 	:= ""
Local cSrvType 		:= Alltrim(Upper(TCSrvType()))
Local lDebito 		:= .T.
Local lCredito 		:= .T.
Local aDtSaldo 		:= {}
Local aDtIni 		:= {}
Local nX, aPeriodo, oStructCube, lZerado, lSintetica, lTotaliza
Local lMovimento 	:= .F.
Local lAcumul
aPeriodo	:= aProcCube[1]
oStructCube := aProcCube[2]
lZerado 	:= aProcCube[4]
lSintetica 	:= aProcCube[5]
lTotaliza 	:= .F.
cWhereTpSld := aProcCube[6]
lAcumul		:= aProcCube[7]
cCodCube 	:= oStructCube:cCodeCube

If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, nQtdVal)
	aAdd(aFilesErased, cArqAS400)
EndIf

//cria arquivo para popular
PcoCriaTemp(oStructCube, @cArquivo, nQtdVal)
aAdd(aFilesErased, cArquivo)

aQryDim 	:= {}
For nZ := 1 TO oStructCube:nMaxNiveis
	If lSintetica .And. nZ > nNivel
		aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica, .T./*lForceNoSint*/)
	Else
		aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica)
	EndIf
	//aqui fazer tratamento quando expressao de filtro e expressao sintetica nao for resolvida
	If (aQueryDim[2] .And. aQueryDim[3])  //neste caso foi resolvida
		
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
		
	Else  //se filtro ou condicao de sintetica nao foi resolvida pela query

		aQueryDim := PcoQueryDim(oStructCube, nZ, @cArqTmp, aQueryDim[1] )
		aAdd(aFilesErased, cArqTmp)
		
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
	
	EndIf	
Next

For nZ := nNivel+1 TO oStructCube:nMaxNiveis
	If nZ == oStructCube:nNivTpSld
		aAdd(aCposNiv, "AKT_TPSALD")
	Else
		aAdd(aCposNiv, "AKT_NIV"+StrZero(nZ, 2) )
	EndIf
Next

For nX := 1 TO Len(aPeriodo)
	aAdd(aDtIni, STOD(aPeriodo[nX,1])) 
	aAdd(aDtSaldo, STOD(aPeriodo[nX, 2])) 
Next

aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, nQtdVal, aDtSaldo, aQryDim, cWhere, cWhereTpSld, oStructCube:nNivTpSld, lMovimento, aDtIni, .T./*lAllNiveis*/, aCposNiv, lDebito, lCredito )

PcoPopulaTemp(oStructCube, cArquivo, aQuery, nQtdVal, lZerado, cArqAS400, lDebito, lCredito )

dbSelectArea(cArquivo)
dbCloseArea()

CarregaProcessa(aProcCub, oStructCube, cArquivo, nQtdVal, lAcumul)

If ! Empty(aFilesErased)
	//apaga os arquivos temporarios criado no banco de dados
	For nZ := 1 TO Len(aFilesErased)
		If Select(Alltrim(aFilesErased[nZ])) > 0
			dbSelectArea(Alltrim(aFilesErased[nZ]))
			dbCloseArea()
		EndIf	
		MsErase(Alltrim(aFilesErased[nZ]))
	Next
EndIf

Return aProcCub

//---------------------------------------------------------------------------------------------------------

Static Function CarregaProcessa(aProcCub, oStructCube, cArquivo, nQtdVal, lAcumul)

Local cChave, nTamNiv, nPai, cChavOri, cDescrAux, lAuxSint
Local nNivel
Local nX, nZ, nY
Local cQuery
Local aValor, nSldIni, nMovCrd, nMovDeb, nMovPer

For nX := 1 TO oStructCube:nMaxNiveis

	nNivel := nX
	nTamNiv := oStructCube:aTam[nNivel]

	cQuery := " SELECT "

	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ

	For nY := 1 TO nQtdVal
		cQuery += " , SUM(AKT_DEB"+StrZero(nY,3)+") AKT_DEB"+StrZero(nY,3)
		cQuery += " , SUM(AKT_CRD"+StrZero(nY,3)+") AKT_CRD"+StrZero(nY,3)
		cQuery += " , SUM(AKT_SLD"+StrZero(nY,3)+") AKT_SLD"+StrZero(nY,3)
	Next //nY

	cQuery +=" FROM "+cArquivo

	cQuery += " GROUP BY "
	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ
	cQuery += " ORDER BY "
	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cArquivo, .T., .T. )

	dbSelectArea(cArquivo)
	dbGoTop()
	
	While (cArquivo)->( ! Eof() )
		cChave := ""
		For nZ := 1 TO nX	
			cChave += PadR( (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nZ,2)))) , oStructCube:aTamNiv[nZ])
		Next //nZ
		cChave := PadR( cChave , nTamNiv)

		nPai := 0
		cChavOri := cChave
		//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
		dbSelectArea(oStructCube:aAlias[nNivel])
		If dbSeek(xFilial()+PadR( (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2)))) , oStructCube:aTamNiv[nNivel]) )
			cDescrAux := &(oStructCube:aDescRel[nNivel])
			If ! Empty(oStructCube:aCondSint[nNivel])
				lAuxSint := &(oStructCube:aCondSint[nNivel])
			Else	
				lAuxSint := .F.	
			EndIf
		Else
			cDescrAux := ""
			lAuxSint := .F.		
		EndIf	
		
		aValor := {}
		For nY := 2 TO nQtdVal
            
			If lAcumul
				nSldIni := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(1,3))) - FieldGet(FieldPos("AKT_DEB"+StrZero(1,3)))  ) // nCrdIni-nDebIni
				nMovCrd := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_CRD"+StrZero(1,3))) )  // nCrdFim-nCrdIni	
				nMovDeb := (cArquivo)->( FieldGet(FieldPos("AKT_DEB"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_DEB"+StrZero(1,3))) ) // nDebFim-nDebIni
				nMovPer :=  nMovCrd-nMovDeb
		    Else
				nSldIni := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY-1,3))) - FieldGet(FieldPos("AKT_DEB"+StrZero(nY-1,3)))  ) // nCrdIni-nDebIni
				nMovCrd := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_CRD"+StrZero(nY-1,3))) )  // nCrdFim-nCrdIni	
				nMovDeb := (cArquivo)->( FieldGet(FieldPos("AKT_DEB"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_DEB"+StrZero(nY-1,3))) ) // nDebFim-nDebIni
				nMovPer :=  nMovCrd-nMovDeb
		    EndIf
			aAdd(aValor, nSldIni )
			aAdd(aValor, nMovCrd )
			aAdd(aValor, nMovDeb )
			aAdd(aValor, nMovPer )

        Next  //nY

	  	aAdd(aProcCub, {	cChave, ;
	  						aClone(aValor), ;
		  					oStructCube:aConcat[nNivel], ;
		  					oStructCube:aAlias[nNivel], ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					1,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ) })
	
		dbSelectArea(cArquivo)
		(cArquivo)->(dbSkip())
	
	EndDo	
	
	dbSelectArea(cArquivo)
	dbCloseArea()

Next // nX

ASORT(aProcCub,,,{|x,y|x[1]<y[1]})

Return
