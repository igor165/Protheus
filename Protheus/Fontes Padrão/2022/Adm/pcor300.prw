#INCLUDE "pcor300.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR300  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao do demonstrativo de saldos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR300                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao do demonstrativo de saldos             ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR300(aPerg)

Local aArea	  	:= GetArea()
Local lPrint	:=	.T.
Local cCubo		:=	""

Private COD_CUBO	

Default aPerg := {}

	If Len(aPerg) == 0
		
		If 	Pergunte("PCR300",.T.)
		
			cCubo := mv_par01
		
			COD_CUBO := cCubo
		
		   	oReport	:= PCOR300Def( "PCR300", cCubo)
		
		Else
			lPrint	:=	.F.
		Endif
		
	Else
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
	   	oReport	:= PCOR300Def( "PCR300", cCubo)
	EndIf

	If lPrint	
		oReport:PrintDialog()
	Endif

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOR300Defº Autor ³ Gustavo Henrique   º Data ³  25/05/06  º±±
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
Static Function PCOR300Def( cPerg, cCubo )

Local cReport	:= "PCOR300" 	// Nome do relatorio
Local cTitulo	:= STR0001		// Titulo do relatorio
Local cDescri	:= STR0010		// Descricao do relatorio

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
oReport := TReport():New( cReport, cTitulo, cPerg, { |oReport| PrintReport( oReport, aNiveis, aSections ) }, cDescri ) // "Este relatorio ira imprimir o Demonstrativo de Saldos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes do relatorio a partir dos niveis do cubo selecionado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := PCOTRCubo( @oReport, cCubo, @aNiveis, @aSections )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as secoes especificas do relatorio                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotSec := Len( aSections )

For nSection := 1 To nTotSec
	TRCell():New( aSections[nSection], "SALDO_ANT"  ,/*Alias*/,STR0004,"@E 999,999,999,999.99",18,/*lPixel*/,)	// "Saldo Anterior"
	TRCell():New( aSections[nSection], "MOV_CREDITO",/*Alias*/,STR0005,"@E 999,999,999,999.99",18,/*lPixel*/,)	// "Movimento Credito"
	TRCell():New( aSections[nSection], "MOV_DEBITO" ,/*Alias*/,STR0006,"@E 999,999,999,999.99",18,/*lPixel*/,)	// "Movimento Debito"
	TRCell():New( aSections[nSection], "CRED_DEBITO",/*Alias*/,STR0009,"@E 999,999,999,999.99",18,/*lPixel*/,)	// "Credito-Debito"
	TRCell():New( aSections[nSection], "SALDO_FINAL",/*Alias*/,STR0007,"@E 999,999,999,999.99",18,/*lPixel*/,)	// "Saldo Final"
Next nSection	

Return oReport              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PrintReport ºAutor³ Bruno / Gustavo    º Data ³  08/06/06  º±±
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
Local nProxNiv	:= 0
Local nZ
Local lChangeNiv:= .T.					// Indica se houve troca de nivel durante a impressao do relatorio

Local aAcessoCfg_1
Local aProcCube := {}
Local aConfig 	:= {}
Local cCodCube
Local cCfg_1
Local oStructCube_1
Local aParametros
Local lZerado
Local lEditCfg1
Local cWhereTpSld_1
Local dDataIni, dDataFim, lAcumul
Local aPerAux := {}
Local nMoeda
Local lContinua := .T.

Private aSavPar	:= {}
/*
01 - Codigo Cubo Gerencial ?
02 - Data de ?
03 - Data Ate ?
04 - Moeda ?
05 - Configuracao do Cubo ?
06 - Editar Configuracoes do Cubo ?
07 - Considerar Zerados ?
08 - Somente Movimentos?
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva parametros para nao conflitar com parambox                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSavPar   := { MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08 }
                                                                                                             
cCodCube := MV_PAR01
dDataIni := MV_PAR02 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)
dDataFim := MV_PAR03 //manipula data base do sistema (tem que voltar depois para conteudo variavel dBase)

If ValType(MV_PAR04) == "C"
	nMoeda := Val(MV_PAR04)
Else
	nMoeda := MV_PAR04
EndIf

cCfg_1 := MV_PAR05
lEditCfg1 := ( MV_PAR06 == 1 )

lZerado := ( MV_PAR07 == 1 )
lAcumul := ( MV_PAR08 == 1 )

If SuperGetMV("MV_PCOCNIV",.F., .F.)

	//modo utilizando querys para buscar os saldos nas datas em bloco
	//verificar se usuario tem acesso as configuracoes do cubo
	aAcessoCfg_1 := PcoVer_Acesso( cCodCube, cCfg_1 )  	//retorna posicao 1 (logico) .T. se tem acesso
	   													//							.F. se nao tem
	   													//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera 
	lContinua := aAcessoCfg_1[1]
	
	If ! lContinua

		Aviso(STR0011, STR0013,{"Ok"}) //"Atencao"###"Usuario sem acesso ao relatorio. Verifique as configuracoes."

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

				aPerAux := { DTOS(aSavPar[02]-1), DTOS(aSavPar[03]) }
				aProcCube := { aPerAux, oStructCube_1, aAcessoCfg_1, lZerado, lSintetica, cWhereTpSld_1, lAcumul }
	
				aProcessa := PcoProcCubo(aProcCube, nMoeda, 2/*nQtdVal*/)
			
			EndIf

		EndIf

	EndIf
	
Else

	//processamento normal do relatorio
	aProcessa := PcoRunCube( aSavPar[1], 4, "Pcor300Sld", aSavPar[5], aSavPar[6], (aSavPar[7]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
	ASORT(aProcessa,,,{|x,y|x[1]<y[1]})
	
EndIf	

Pergunte("PCR300",.F.)
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
	
		aSections[nX]:Cell(aNiveis[nX,2]):SetBlock( { || If( .F. .And. nLinImp == 1 .And. lChangeNiv, aNiveis[aProcessa[nLoop,8],5], aProcessa[nLoop,14] ) } )
		aSections[nX]:Cell(aNiveis[nX,3]):SetBlock( { || aProcessa[nLoop,6]  } )
	
		If aSavPar[8] != 1
			aSections[nX]:Cell("SALDO_ANT"):SetBlock( { || aProcessa[nLoop,2,1] } )
			aSections[nX]:Cell("SALDO_ANT"):SetAlign("LEFT")
		Else	
			aSections[nX]:Cell("SALDO_ANT"):Hide()
			aSections[nX]:Cell("SALDO_ANT"):HideHeader()		
		EndIf	
		                                                                            
		aSections[nX]:Cell( "MOV_CREDITO" ):SetBlock( { || aProcessa[nLoop,2,2] } )
		aSections[nX]:Cell( "MOV_DEBITO"  ):SetBlock( { || aProcessa[nLoop,2,3] } )
		aSections[nX]:Cell( "MOV_CREDITO" ):SetAlign("LEFT")
		aSections[nX]:Cell( "MOV_DEBITO"  ):SetAlign("LEFT")
	
		If aSavPar[8] != 1
			aSections[nX]:Cell("CRED_DEBITO"):Disable()
			aSections[nX]:Cell("SALDO_FINAL"):SetBlock( { || aProcessa[nLoop,2,4] } )
			aSections[nX]:Cell("SALDO_FINAL"):SetAlign("LEFT")		
		Else                                  
			aSections[nX]:Cell("SALDO_FINAL"):Disable()
			aSections[nX]:Cell("CRED_DEBITO"):SetBlock( { || aProcessa[nLoop,2,4] } )
			aSections[nX]:Cell("CRED_DEBITO"):SetAlign("LEFT")		
		EndIf	
	
		aSections[nX]:SetRelation( { || xFilial( aNiveis[nLoop][1] ) + aProcessa[nLoop,14] }, aNiveis[nLoop][1], 3, .T. )
	
		TrPosition():New(aSections[nX],aNiveis[nX][1],1, { || xFilial(  aNiveis[aProcessa[nLoop,8],1] ) + aProcessa[nLoop,14] } )
	
	  	nMaxCod := Max( nMaxCod, Len(aProcessa[nLoop,14] ) )
	
	Next
	
	nMaxDescr := 100 - (nMaxCod + 3)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza tamanho das celulas a partir do valor calculado as variaveis nMaxCod e nMaxDescr   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To nSections
		aSections[nX]:Cell( aNiveis[nX,2] ):SetSize( 15  ,.F. )
		aSections[nX]:Cell( aNiveis[nX,3] ):SetSize( 65,.F. )
	Next
	
	Do While !oReport:Cancel() .And. nLoop <= nTotRecs
	                                         
		If oReport:Cancel()
			Exit
		EndIf
	
		oReport:IncMeter()
	   
	  	If aProcessa[nLoop,8] == 1    
			oReport:Line( oReport:Row(), aSections[ aProcessa[nLoop,8] ]:Cell( aProcessa[nLoop,8] ):ColPos(), oReport:Row(), oReport:PageWidth() )
		EndIf
	     
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
			nTotLin := 1	// Duas linhas para troca de nivel, sendo na 1a. nome do nivel e na 2a o detalhe
		Else
			nTotLin := 1	// Uma linha com o detalhe do nivel
		EndIf
		
	  	nNivAtu	:= aProcessa[nLoop,8]
	                                            
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o nome do nivel da chave do cubo na 1a. linha e o detalhe da chave na 2a.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	For nLinImp := 1 To nTotLin
				aSections[nNivAtu]:PrintLine()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o proximo nivel eh maior que o atual. Neste caso nao deve imprimir a linha ³ 
				//| a partir da coluna do nivel atual.                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  	nProxNiv := (nLoop+1)
				
				If ! ( nProxNiv <= nTotRecs .and. aProcessa[nProxNiv,8] < nNivAtu )                                               
					oReport:Line( oReport:Row(), aSections[nNivAtu]:Cell(nLinImp):ColPos(), oReport:Row(), oReport:PageWidth() )
				EndIf	
				 
	
	 	Next nLinImp 
	
		nLoop ++
		
	EndDo
	
  	aSections[ nNivAtu ]:Finish()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pcor300Sld³ Autor ³ Edson Maricate        ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao da planilha orcamentaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Pcor300Sld                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pcor300Sld(cConfig,cChave)
Local aRetIni,aRetFim, aRetSld
Local nCrdIni
Local nDebIni
Local nCrdFim
Local nDebFim

aRetIni := PcoRetSld(cConfig,cChave,aSavPar[2]-1)
nCrdIni := aRetIni[1, aSavPar[4]]
nDebIni := aRetIni[2, aSavPar[4]]
aRetFim := PcoRetSld(cConfig,cChave,aSavPar[3])
nCrdFim := aRetFim[1, aSavPar[4]]
nDebFim := aRetFim[2, aSavPar[4]]

nSldIni := nCrdIni-nDebIni
nSldFim := nCrdFim-nDebFim
nMovCrd := nCrdFim-nCrdIni
nMovDeb := nDebFim-nDebIni

If aSavPar[08] != 1
	aRetSld := {nSldIni,nMovCrd,nMovDeb,nSldFim}
Else
	aRetSld := {0,nMovCrd,nMovDeb,nMovCrd-nMovDeb}
EndIf

Return aRetSld

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
Local aPeriodo, oStructCube, lZerado, lSintetica, lTotaliza
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

aAdd(aDtSaldo, STOD(aPeriodo[1])) 
aAdd(aDtSaldo, STOD(aPeriodo[2])) 

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


Static Function CarregaProcessa(aProcCub, oStructCube, cArquivo, nQtdVal, lAcumul)
Local cChave, nTamNiv, nPai, cChavOri, cDescrAux, lAuxSint
Local nNivel
Local nX, nZ, nY
Local cQuery
Local aValor, nSldIni, nMovCrd, nMovDeb, nMovPer, nSldFim

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
			cDescrAux := "OUTROS ( NAO ESPECIFICADO )"
			lAuxSint := .F.		
		EndIf	
		
		aValor := {}
		For nY := 2 TO nQtdVal
            
			If lAcumul
				nSldIni := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(1,3))) - FieldGet(FieldPos("AKT_DEB"+StrZero(1,3)))  ) // nCrdIni-nDebIni
				nMovCrd := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_CRD"+StrZero(1,3))) )  // nCrdFim-nCrdIni	
				nMovDeb := (cArquivo)->( FieldGet(FieldPos("AKT_DEB"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_DEB"+StrZero(1,3))) ) // nDebFim-nDebIni
				nMovPer := nMovCrd-nMovDeb
				nSldFim := (cArquivo)->( FieldGet(FieldPos("AKT_SLD"+StrZero(nY,3))) )
		    Else
				nSldIni := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY-1,3))) - FieldGet(FieldPos("AKT_DEB"+StrZero(nY-1,3)))  ) // nCrdIni-nDebIni
				nMovCrd := (cArquivo)->( FieldGet(FieldPos("AKT_CRD"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_CRD"+StrZero(nY-1,3))) )  // nCrdFim-nCrdIni	
				nMovDeb := (cArquivo)->( FieldGet(FieldPos("AKT_DEB"+StrZero(nY,3)))   - FieldGet(FieldPos("AKT_DEB"+StrZero(nY-1,3))) ) // nDebFim-nDebIni
				nMovPer :=  nMovCrd-nMovDeb
				nSldFim := (cArquivo)->( FieldGet(FieldPos("AKT_SLD"+StrZero(nY,3))) )
		    EndIf

		    If aSavPar[8] == 1
				aAdd(aValor, 0 )
				aAdd(aValor, nMovCrd )
				aAdd(aValor, nMovDeb )
				aAdd(aValor, nMovPer )
		    Else
				aAdd(aValor, nSldIni )
				aAdd(aValor, nMovCrd )
				aAdd(aValor, nMovDeb )
				aAdd(aValor, nSldFim )
            EndIf

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
							Right(cChave, oStructCube:aTamNiv[nNivel]),;
							( nNivel  == oStructCube:nMaxNiveis ) })
	
		dbSelectArea(cArquivo)
		(cArquivo)->(dbSkip())
	
	EndDo	
	
	dbSelectArea(cArquivo)
	dbCloseArea()

Next // nX

ASORT(aProcCub,,,{|x,y|x[1]<y[1]})

Return

