#INCLUDE "pcor510.ch"
#INCLUDE "PROTHEUS.CH"

#define TAM_CEL		18

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR510  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao do demonstrativo de saldos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR510                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao do demonstrativo de saldos             ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR510(aPerg)

Local aArea	  	:= GetArea()
Local lPrint	:=	.T.
Local cCubo		:=	""
Local dBase 	:= dDataBase

Private COD_CUBO	

Default aPerg := {}

If Len(aPerg) == 0
	If Pergunte("PCR510",.T.)
		cCubo	:=	mv_par01
		COD_CUBO := cCubo
		oReport	:= PCOR510Def( "PCR510", cCubo)
	Else
		lPrint	:=	.F.
	Endif
Else
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
   	oReport	:= PCOR510Def( "PCR510", cCubo)
EndIf
	
If lPrint	
	oReport:PrintDialog()
Endif

RestArea(aArea)
dDataBase := dBase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOR510Defº Autor ³ Gustavo Henrique   º Data ³  14/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±º          ³ EXPC2 - Codigo do cubo em que o relatorio deve ser impressoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOR510Def( cPerg, cCubo )

Local cReport	:= "PCOR510" 	// Nome do relatorio
Local cTitulo	:= STR0001		// Titulo do relatorio
Local cDescri	:= STR0015 		// Descricao do relatorio

Local aNiveis	:= {}
Local aSections := {}
            
Local nTotSec	:= 0
Local nSection	:= 0

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

// "Este relatorio ira imprimir o Comparativo de Cubos - Demonstrativo de Saldos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."
oReport := TReport():New( cReport, cTitulo, cPerg, { |oReport| PrintReport( oReport, aNiveis, aSections ) }, cDescri ) 

oReport:SetLandscape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes do relatorio a partir dos niveis do cubo selecionado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := PCOTRCubo( @oReport, cCubo, @aNiveis, @aSections )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes especificas do relatorio                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotSec := Len( aSections )

For nSection := 1 To nTotSec
	TRCell():New( aSections[nSection], "SALDO_CUBO1",/*Alias*/,STR0011,"@E 999,999,999,999.99",TAM_CEL,,,,,"RIGHT")
	TRCell():New( aSections[nSection], "SALDO_CUBO2",/*Alias*/,STR0012,"@E 999,999,999,999.99",TAM_CEL,,,,,"RIGHT")
	TRCell():New( aSections[nSection], "DIFERENCA"  ,/*Alias*/,STR0013,"@E 999,999,999,999.99",TAM_CEL,,,,,"RIGHT")
	TRCell():New( aSections[nSection], "VARIACAO"   ,/*Alias*/,STR0014,/*Picture*/,TAM_CEL,,,,,"RIGHT")
Next nSection	

Return oReport      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PrintReport ºAutor³ Bruno / Gustavo    º Data ³  19/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao das secoes do relatorio definida em cima da      º±±
±±º          ³ configuracao do cubo no array aSections.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport( oReport, aNiveis, aSections )

Local nNivAtu 	:= 0
Local nLoop		:= 1  
Local nX		:= 1  
Local nY		:= 1  
Local nTotRecs	:= 0
Local nSections	:= Len( aSections )		// Total de secoes desconsiderando a ultima referente ao grupo de perguntas
Local nMaxCod	:= 0
Local nMaxDescr	:= 0
Local nLinImp	:= 0
Local nTotLin	:= 0
Local nPosComp	:= 0

Local cConfig1	:= ""
Local cConfig2	:= ""

Local lInc		:= .F.
Local lChangeNiv:= .T.					// Indica se houve troca de nivel durante a impressao do relatorio
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

Local nMoeda
Local lContinua := .T.

Private aSavPar		:= {}
Private aProcessa	:= {}
Private aProcComp	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva parametros para nao conflitar com parambox                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSavPar := { MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09 }

/* PARAMETROS DO RELATORIO (SX1)
MV_PAR01 * Codigo do Cubo Gerencial ?
MV_PAR02 * Data de Referencia Saldo ?
MV_PAR03 * Moeda ?
MV_PAR04 * Configuracao do Cubo 1 ?
MV_PAR05 * Editar Configuracoes Cubo 1 ?
MV_PAR06 * Configuracao do Cubo 2 ?
MV_PAR07 * Editar Configuracoes Cubo 2 ?
MV_PAR08 * Considera Zerados ?
MV_PAR09 * Considerar Cfg. 1 Cubo ?
*/ 

cCodCube := MV_PAR01
dDataBase := MV_PAR02 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)
If ValType(MV_PAR03) == "C"
	nMoeda := Val(MV_PAR03)
Else
	nMoeda := MV_PAR03
EndIf
cCfg_1 := MV_PAR04
lEditCfg1 := ( MV_PAR05 == 1 )

cCfg_2 := MV_PAR06
lEditCfg2 := ( MV_PAR07 == 1 )

lZerado := ( MV_PAR08 == 1 )

If !Empty(aSavPar[4])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[4]) 
		cConfig1 := Left(AllTrim(AL3->AL3_DESCRI),15)
	EndIf
EndIf

If !Empty(aSavPar[6])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[6]) 
		cConfig2 := Left(AllTrim(AL3->AL3_DESCRI),15)
	EndIf
EndIf


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

		Aviso(STR0016, STR0017,{"Ok"}) //"Atencao"###"Usuario sem acesso ao relatorio. Verifique as configuracoes."

	Else
	

		oStructCube_1 := PcoStructCube( cCodCube, cCfg_1 )
				
		If Empty(oStructCube_1:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
			lContinua := .F.
		EndIf
	                
		If lContinua
	
			//monta array aParametros para ParamBox
			aParametros := PcoParametro( oStructCube_1, lZerado, aAcessoCfg_1[1]/*lAcesso*/, aAcessoCfg_1[2]/*nDirAcesso*/ )
	
	        //exibe parambox para edicao ou visualizacao
			Pco_aConfig(aConfig, aParametros, oStructCube_1, lEditCfg1/*lViewCfg*/, @lContinua)
					
			If lContinua
				lZerado	:=	aConfig[Len(aConfig)-1]          //penultimo informacao da parambox (check-box)
				lSintetica	:=	aConfig[Len(aConfig)]        //ultimo informacao da parambox (check-box)
				//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
				cWhereTpSld_1 := ""
				If oStructCube_1:nNivTpSld > 0 .And. ;
					oStructCube_1:aIni[oStructCube_1:nNivTpSld] == oStructCube_1:aFim[oStructCube_1:nNivTpSld] .And. ;
					Empty(oStructCube_1:aFiltros[oStructCube_1:nNivTpSld])
						cWhereTpSld_1 := " AKT.AKT_TPSALD = '" + oStructCube_1:aIni[oStructCube_1:nNivTpSld] + "' AND "
				EndIf								
						
				aProcCube := { dDataBase, oStructCube_1, aAcessoCfg_1, lZerado, lSintetica, cWhereTpSld_1 }
	
				aProcessa := PcoProcCubo(aProcCube, nMoeda)
					
			EndIf
		
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
							
					aProcCube := { dDataBase, oStructCube_2, aAcessoCfg_2, lZerado, lSintetica, cWhereTpSld_2 }
		
					aProcComp := PcoProcCubo(aProcCube, nMoeda)
						
				EndIf
			
			EndIf
	    
		EndIf	
		
	EndIf

Else

	//modo atual utilizando a funcao pcoruncube()
	//processamento do relatorio
	aProcessa := PcoRunCube( aSavPar[01] /*confg.rel.*/, 1 /*Qtd.Colunas*/, "Pcor510Sld"/*funcao processa pcocube*/,aSavPar[04],aSavPar[05], (aSavPar[08]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
	aProcComp := PcoRunCube( aSavPar[01] /*confg.rel.*/, 1 /*Qtd.Colunas*/, "Pcor510Sld"/*funcao processa pcocube*/,aSavPar[06],aSavPar[07], (aSavPar[08]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

EndIf	

If lContinua
                                                 
	For nX := 1 To Len(aSavPar)
		&("MV_PAR"+StrZero(nX,2)) := aSavPar[nX]
	Next	
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
	
	nTotRecs  := Len( aProcessa )
	
	If nTotRecs > 0
		oReport:SetMeter( nTotRecs )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza conteudo das celulas com o valor que deve ser impresso a partir do array aProcessa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To nSections
		    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desabilita a impressao do cabecalho das secoes a partir do 1o. nivel do cubo e configura³
			//³ impressao do cabecalho da 1a. secao no inicio de cada pagina (SetHeaderPage)            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nX > 1
				aSections[nX]:SetHeaderSection(.F.)
			Else
				aSections[nX]:SetHeaderPage(.T.)
			EndIf	
		
			aSections[nX]:Cell(aNiveis[nX,2]):SetBlock( { || If( nLinImp == 1 .And. lChangeNiv, aNiveis[aProcessa[nLoop,8],5], aProcessa[nLoop,14] ) } )
			aSections[nX]:Cell(aNiveis[nX,3]):SetBlock( { || aProcessa[nLoop,6]  } )
		
			aSections[nX]:Cell("SALDO_CUBO1"):SetBlock( { || aProcessa[nLoop,2,1] } )
		
			If ! Empty( aSavPar[4] )
				aSections[nX]:Cell("SALDO_CUBO1"):SetTitle(cConfig1)
			EndIf	
		
			If ! Empty( aSavPar[6] )
				aSections[nX]:Cell("SALDO_CUBO2"):SetTitle(cConfig2)
			EndIf	
		
			aSections[nX]:Cell("SALDO_CUBO2"):SetBlock( { ||	If( nPosComp > 0, aProcComp[nPosComp,2,1], 0 ) } )
		
			aSections[nX]:Cell("DIFERENCA"  ):SetBlock( { ||	If( nPosComp > 0, ;
																		(aProcessa[nLoop,2,1] - aProcComp[nPosComp,2,1]),;
																		(aProcessa[ nLoop, 2, 1 ]) ) } )
		
			aSections[nX]:Cell("VARIACAO"   ):SetBlock( { || 	If( nPosComp > 0 .And. If(aSavPar[09]==1 , aProcComp[nPosComp,2,1] # 0, aProcessa[nLoop,2,1] # 0) ,;
																( If(aSavPar[09]==1, ;
																	aProcessa[nLoop,2,1] / aProcComp[nPosComp,2,1] * 100,;
																	aProcComp[nPosComp,2,1] / aProcessa[nLoop,2,1] * 100 );
																),;
																'...' ) } )		// 18 eh o tamanho da celula
		
			aSections[nX]:SetRelation( { || xFilial( aNiveis[nLoop,1] ) + aProcessa[nLoop,14] }, aNiveis[nLoop,1], 3, .T. )
		
		   	nMaxCod := Max( nMaxCod, Len(aProcessa[nLoop,14] ) )
		
		Next nX
		
		nMaxDescr := 60 - (nMaxCod + 3)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza tamanho das celulas a partir do valor calculado as variaveis nMaxCod e nMaxDescr   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To nSections
			aSections[nX]:Cell( aNiveis[nX,2] ):SetSize( nMaxCod  ,.F. )
			aSections[nX]:Cell( aNiveis[nX,3] ):SetSize( nMaxDescr,.F. )
		Next
		
		Do While !oReport:Cancel() .And. nLoop <= nTotRecs
		                                         
			If oReport:Cancel()
				Exit
			EndIf
		
			oReport:IncMeter()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza impressao da secao atual, caso for maior que a proxima secao              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nNivAtu > aProcessa[nLoop,8]
				aSections[nNivAtu]:Finish()
		   	EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicia impressao da proxima secao, caso a atual for diferente da secao anterior    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lChangeNiv := (nNivAtu <> aProcessa[nLoop,8])
		
			If lChangeNiv
				aSections[aProcessa[nLoop,8]]:Init()
				nTotLin := 2	// Duas linhas para troca de nivel, sendo na 1a. nome do nivel e na 2a o detalhe
			Else
				nTotLin := 1	// Uma linha com o detalhe do nivel
			EndIf
			
			nNivAtu		:= aProcessa[nLoop,8]
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Indica se existe posicao no array da 2a. configuracao de cubo                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosComp	:= aScan( aProcComp, { |x| x[1] == aProcessa[nLoop,1] } )
		                                                                                  
			If nPosComp # 0 .And. aProcComp[ nPosComp, 2, 1 ] # 0
				aSections[ nNivAtu ]:Cell( "VARIACAO" ):SetPicture( "@E 999,999.99%" )
			Else
				aSections[ nNivAtu ]:Cell( "VARIACAO" ):SetPicture( "@!" )
				aSections[ nNivAtu ]:Cell( "VARIACAO" ):SetAlign( "RIGHT" )
			EndIf	
		                              
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime o nome do nivel da chave do cubo na 1a. linha e o detalhe da chave na 2a.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	For nLinImp := 1 To nTotLin
		 	
		 		If nLinImp == 1 .And. lChangeNiv
		 			aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):Hide()
		 			aSections[ nNivAtu ]:Cell( "SALDO_CUBO1" ):Hide()
		 			aSections[ nNivAtu ]:Cell( "SALDO_CUBO2" ):Hide()
					aSections[ nNivAtu ]:Cell( "DIFERENCA"   ):Hide()
					aSections[ nNivAtu ]:Cell( "VARIACAO"    ):Hide()			
		 			aSections[ nNivAtu ]:PrintLine()
		 		Else
		 			aSections[ nNivAtu ]:Cell( aNiveis[ nNivAtu, 3 ] ):Show()
		 			aSections[ nNivAtu ]:Cell( "SALDO_CUBO1" ):Show()
		 			aSections[ nNivAtu ]:Cell( "SALDO_CUBO2" ):Show()
					aSections[ nNivAtu ]:Cell( "DIFERENCA"   ):Show()
					aSections[ nNivAtu ]:Cell( "VARIACAO"    ):Show()			
					aSections[ nNivAtu ]:PrintLine() 		
		 		EndIf
		
		 	Next nLinImp
		
			nLoop ++
			
		EndDo
		
		aSections[ nNivAtu ]:Finish()
		
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pcor510Sld³ Autor ³ Edson Maricate        ³ Data ³18/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento para impressao do dem. de saldos.   ³±±
±±³          ³Esta funcao e chama pela pcocube nos niveis de processamento³±±
±±³          ³parametrizados / ou pre configurados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Pcor510Sld                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pcor510Sld(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim

aRetFim := PcoRetSld(cConfig,cChave,aSavPar[2])
nCrdFim := aRetFim[1, aSavPar[3]]
nDebFim := aRetFim[2, aSavPar[3]]

nSldFim := nCrdFim-nDebFim

Return {nSldFim}



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
Static Function PcoProcCubo(aProcCube, nMoeda)
Local cCodCube
Local cArquivo := ""
Local aQueryDim, cArqTmp
Local nZ
Local cWhereTpSld := ""
Local cWhere := ""
Local dData, oStructCube, lZerado, lSintetica, lTotaliza
Local nNivel := 1 //sempre processar a partir do primeiro nivel
Local aCposNiv := {}
Local aFilesErased := {}
Local aProcCub := {}
Local cArqAS400 := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))

dData		:= aProcCube[1]
oStructCube := aProcCube[2]
lZerado 	:= aProcCube[4]
lSintetica 	:= aProcCube[5]
lTotaliza 	:= .F.
cWhereTpSld := aProcCube[6]
cCodCube 	:= oStructCube:cCodeCube
If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, 1/*nQtdVal*/)
	aAdd(aFilesErased, cArqAS400)
EndIf

//cria arquivo para popular
PcoCriaTemp(oStructCube, @cArquivo, 1/*nQtdVal*/)
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

aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, 1/*nQtdVal*/, { dData }/*aDtSld*/, aQryDim, cWhere/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, .F., NIL, .T./*lAllNiveis*/, aCposNiv )

PcoPopulaTemp(oStructCube, cArquivo, aQuery, 1/*nQtdVal*/, lZerado, cArqAS400)

dbSelectArea(cArquivo)
dbCloseArea()

CarregaProcessa(aProcCub, oStructCube, cArquivo)

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


Static Function CarregaProcessa(aProcCub, oStructCube, cArquivo)
Local cChave, nTamNiv, nPai, cChavOri, cDescrAux, lAuxSint
Local nNivel
Local nX, nZ
Local cQuery
Local cChvAux

For nX := 1 TO oStructCube:nMaxNiveis

	nNivel := nX
	nTamNiv := oStructCube:aTam[nNivel]
	
	cQuery := " SELECT "

	For nZ := 1 TO nNivel
		cQuery += If(nZ>1, ", ", "") + "AKT_NIV"+StrZero(nZ,2)
	Next //nZ

	cQuery += " , SUM(AKT_SLD001) SOMA_VALOR "

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
		cChave := PadR(cChave, nTamNiv)
		nPai := 0
		cChavOri := cChave
		//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
		dbSelectArea(oStructCube:aAlias[nNivel])
		cChvAux := PadR( (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2)))), oStructCube:aTamNiv[nNivel] )
		If dbSeek(xFilial()+cChvAux )
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
		
	  	aAdd(aProcCub, {	cChave, ;
	  						{ (cArquivo)->(FieldGet(FieldPos("SOMA_VALOR")))}, ;
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
							cChvAux,;
							( nNivel  == oStructCube:nMaxNiveis ) })
	
		dbSelectArea(cArquivo)
		(cArquivo)->(dbSkip())
	
	EndDo	
	
	dbSelectArea(cArquivo)
	dbCloseArea()
	
Next

ASORT(aProcCub,,,{|x,y|x[1]<y[1]})

Return
