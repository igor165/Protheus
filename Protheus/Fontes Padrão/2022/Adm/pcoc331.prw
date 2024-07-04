#INCLUDE "PCOC331.ch"
#include "protheus.ch"
#include "msgraphi.ch"

#DEFINE N_COL_VALOR	 2

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC331 	ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 23/01/08   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta ao arquivo de saldos mensais dos Cubos  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC331                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOC331(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC331(nCallOpcx,dData,cCodCube,cCfgCube,lZerado)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Consulta Saldos na Data - Cubos"
Private aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ "Consultar", 	"Pco_330View" , 0 , 2} }  
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3311" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3311                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3311", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
			Eval( bBlock,Alias(),AL4->(Recno()),nPos,,,,,dData,cCodCube,cCfgCube,lZerado)
		EndIf
	Else
		mBrowse(6,1,22,75,"AL1")
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco_330ViewบAutor  ณPaulo Carnelossi      บ Data ณ  23/01/08 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que solicita parametros para utilizacao na montagem   บฑฑ
ฑฑบ          ณda grade e grafico ref. saldo gerencial do pco               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_330View(cAlias,nRecno,nOpcx,xRes1,xRes2,xRes3,dData,cCodCube,cCfgCube,lZerado)
Local nTpGraph
Local nX, nZ
Local aAcessoCfg 
Local oStructCube
Local lContinua := .T.
Local aListArq := {}
Local aConfig  := {}
Local lSintetica := .F.
Local lTotaliza := .T.
Local aProcCube := {}
Local aFilesErased := {}
Local aDescrAnt
Local aFiltroAKD
Local aWhere
Local cWhereTpSld
Local aTpGrafico

//***********************************************
// Implemantacao do Grafico com FwChartFactory  *
//***********************************************
Private lNewGrafic := SuperGetMV("MV_PCOTPGR",.F.,2) == 1 .and. FindFunction("__FWCBCOMP")
// parametro que informa qual objeto grafico sera utilizado 1= fwChart qquer outra informacao = msGraphic

If lNewGrafic

	aTpGrafico := {STR0004,; //"1=Linha"
					"2="+SubStr(STR0007,3)} //"4=Barra"

Else

	aTpGrafico := {STR0004,; //"1=Linha"
								STR0005,; //"2=Area"
								STR0006,; //"3=Pontos"
								STR0007   ,; //"4=Barra"
								STR0008  ,; //"5=Piramide"
								STR0009    ,; //"6=Cilindro"
								STR0010,; //"7=Barra Horizontal"
								STR0011,; //"8=Piramide Horizontal"
								STR0012,; //"9=Cilindro Horizontal"
								STR0013,; //"10=Pizza"
								STR0014,; //"11=Forma"
								STR0015,; //"12=Linha Rapida"
								STR0016,; //"13=Flechas"
								STR0017,; //"14=Gantt"
								STR0018 } //"15=Bolha"
EndIf

Default dData	 := dDataBase    
Default cCodCube := AL1->AL1_CONFIG
Default cCfgCube := AL3->AL3_CODIGO
Default lZerado	 := .F.

Private aParamCons := {}   	//Parametros da consulta
Private aCfgSel := {}		//Configuracoes selecionadas
Private nNivInic

Private cClasse
Private lClassView := .F.

Private COD_CUBO  := AL1->AL1_CONFIG  // variavel utilizado no filtro da CONPAD

//***************************
// Valida Estrtura do Cubo  *
//***************************
If !PcoVldCub(COD_CUBO)
	lContinua := .F.
EndIf

If lContinua

	lContinua := ParamBox({ { 1,STR0023,dData,"" 	 ,""  ,""    ,"" ,50 ,.F. },; 	//"Saldo em"
						{ 2,STR0024,4,aTpGrafico,80,"",.F.},; 					// "Tipo do Grafico"
						{ 1,STR0037, 2,"99" 	 ,"pco331Ser()"  ,"" ,"" ,15 ,.F. },; 		// "Qtde de Series"
						{ 3,STR0044, 1,{STR0021,STR0022},40,,.F.} },;			//"Exibe Totais"###"Sim"###"Nao"
						STR0025,aParamCons,,,,,,, "PCOC331_01", ,.T.) 

EndIf

If lContinua

	dData := aParamCons[1]
	nTpGraph  := If(ValType(aParamCons[2])=="N", aParamCons[2], Val(aParamCons[2]))
	lTotaliza := ( aParamCons[4]==1 )

    aCfgSel := Pcoc_330Cfg( aParamCons[3], @lContinua )  //selecionar as configuracoes desejadas//aParamCons[6] == numero de series

	If lContinua


	   	For nX := 1 TO Len(aCfgSel)
	   	
   			//verificar se usuario tem acesso as configuracoes
   			aAcessoCfg := PcoVer_Acesso( cCodCube, aCfgSel[nX,1] )  	//retorna posicao 1 (logico) .T. se tem acesso
   																		//							.F. se nao tem
			   															//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera 
	   		If ! aAcessoCfg[1]
   				lContinua := .F.
   				Exit
   			EndIf
   		
	   		If lContinua
	   		
		   		oStructCube := PcoStructCube( cCodCube, aCfgSel[nX, 1] )
			
				If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
					lContinua := .F.
					Exit
				EndIf
                
				If aWhere == NIL //logo na primeira configuracao do cubo define tamnho array aWhere
					aWhere := Array(oStructCube:nMaxNiveis)
				EndIf

				If aDescrAnt == NIL //logo na primeira configuracao do cubo define tamnho array aDescrAnt
					aDescrAnt := Array(oStructCube:nMaxNiveis)
				EndIf

				If aFiltroAKD == NIL //logo na primeira configuracao do cubo define tamnho array aFiltroAKD
					aFiltroAKD := Array(oStructCube:nMaxNiveis)
				EndIf
							
				//monta array aParametros para ParamBox
				aParametros := PcoParametro( oStructCube, .F./*lZerado*/, aAcessoCfg[1]/*lAcesso*/, aAcessoCfg[2]/*nDirAcesso*/ )

                //exibe parambox para edicao ou visualizacao
				Pco_aConfig(aConfig, aParametros, oStructCube, (aCfgSel[nX, 2]==1)/*lViewCfg*/, @lContinua)
				
				If lContinua
					lZerado	:=	aConfig[Len(aConfig)-1]          //penultimo informacao da parambox (check-box)
					lSintetica	:=	aConfig[Len(aConfig)]        //ultimo informacao da parambox (check-box)
					//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
					cWhereTpSld := ""
					If oStructCube:nNivTpSld > 0 .And. ;
						oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
						Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
							cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
					EndIf								
					
				    aAdd(aProcCube, { dData, oStructCube, aCfgSel, aAcessoCfg, lZerado, lSintetica, lTotaliza, cWhereTpSld } )
				    
				EndIf
		   		
			EndIf
			
			If ! lContinua 
				Exit
			EndIf
   		
	   	Next 

	EndIf
	
	If lContinua
		nNivInic  := 1
		PCOC_330PFI(aProcCube,nNivInic,""/*cChave*/,nTpGraph,aDescrAnt,aFiltroAKD,aWhere,.T./*lShowGraph*/,aListArq,aFilesErased)
	Else
		Aviso(STR0026,STR0027,{STR0028},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
	EndIf
					
EndIf

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

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC_330PFI บAutor  ณPaulo Carnelossi  บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que processa o cubo gerencial do pco e exibe uma     บฑฑ
ฑฑบ          ณgrade com o grafico                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC_330PFI(aProcCube,nNivel,cChave,nTpGrafico,aDescrAnt,aFiltroAKD,aWhere,lShowGraph,aListArq,aFilesErased)

Local oDlg, oPanel, oPanel1, oPanel2
Local oView
Local oGraphic

Local nSerie

Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}

Local aView		:= {}

Local nx
Local cDescri	:= ""
Local aButtons  := {}
					
Local aTabMail	:=	{}

Local ny
Local nColor := 1
Local aParam	:=	{"",.F.,.F.,.F.}
Local aSeries	:= {}
Local aTotSer	:= {}
Local nTotSer
Local nz
Local nLenView	 := 0
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local aTmpSld, cQry, nLin, cChaveAux, cValorAux, aProcessa
Local nMaxNiv := aProcCube[1, 2]:nMaxNiveis
Local nNivClasse := aProcCube[1, 2]:nNivClasse
Local aSerie2 := {}

Local lTotaliza := ( aParamCons[4]==1 )
Local oStructCube 
Local cDescrAux := ""
Local cDescrChv := ""
Local cCpoAux
Local cWhere := ""
Local nTit

Local bLinTotal 	:= {|| lTotaliza .And. Alltrim(Upper(aView[oView:nAT,1])) == "TOTAL" } 

Local bClasse 		:= {|| If(lClassView, cClasse := aView[oView:nAT,1], NIL) }

Local bAddDescr 	:= {|| aDescrAnt[nNivel] := Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]) }

Local bFiltro 		:= {|| aFiltroAKD[nNivel] := cCpoAux +" = '"+aView[oView:nAT,1]+"' "}
         			
Local bDoubleClick 	:= {||	If(Eval(bLinTotal), ;
								NIL, ;						// se for ultima linha/total nao faz nada 
								If(nNivel < nMaxNiv, ; 		//se nao atingiu o ultimo nivel
									( 	Eval(bFiltro), ; 	//atribui o filtro
										Eval(bClasse), ;  	//se eh dimensao por classe atribui a varmem
										Eval(bAddDescr), ;  //adiciona a descricao e faz drilldown cubo
										PCOC_330PFI(aProcCube,nNivel+1,aView[oView:nAT,1],nTpGrafico,aDescrAnt,aFiltroAKD,aWhere,@lShowGraph,aListArq,aFilesErased) ;
									), ;//senao
									( 	Eval(bFiltro), ;		//atribui o filtro
										Pcoc_330lct(aFiltroAKD) ;  // no ultimo nivel o drilldown eh o lancto AKD
									);
								) ;//fecha If
							) ;//fecha If
						}  //fecha bloco de codigo

Local bEncerra := {|| 	If( nNivel == nNivClasse, (lClassView := .F., cClasse := NIL), NIL), ;  // se for nivel da classe inicializa var.
						If( nNivel > nNivInic, ;
								oDlg:End(), ; //se nivel > nivel inicial somente fecha
								If( Aviso(STR0029,STR0030, {STR0021, STR0022},2)==1, ;  //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
									( PcoArqSave(aListArq), oDlg:End() ), ;
							 		NIL;
						  		);//fecha o 3o. If
						 ) ; //fecha o 2o.If		
					} //fecha codeBlock

//Tratamento das entidades adicionais CV0
Local cPlanoCV0	:= ""
Local cAliasCubo	:= ""
Local cCodCube	:= AL1->AL1_CONFIG

DEFAULT aDescrAnt := {}
DEFAULT cChave := ""
DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}

If nNivel+1 <= nMaxNiv
	aButtons := {	{"PMSZOOMIN" 		,{|| Eval(oView:blDblClick) },STR0031 ,STR0032},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST" 		,{|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 },; //"Enviar Emial"###"Email"
						{"GRAF2D"		,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0046,STR0047 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"		,{|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0049,STR0050 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA"		,{|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5" 			,{|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0043 ,STR0043 }; //Pesquisa
					}
Else
	aButtons := {	{"PMSZOOMIN" 		,{|| Eval(oView:blDblClick) },STR0031 ,STR0032},;//"Drilldown do Cubo" ,"Drilldown"
						{"BMPPOST" 		,{|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 },; //"Enviar Emial"###"Email"
						{"GRAF2D"		,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph)},STR0046,STR0047 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"		,{|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0049,STR0050 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA"		,{|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5" 			,{|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0043 ,STR0043 }; //Pesquisa
					}
EndIf					

//prepara a clausula where para qdo pressionar o drill-down ja passar para a a funcao
If nNivel > 1
	aWhere[ nNivel-1 ] := "AKT.AKT_NIV" + StrZero(nNivel-1, 2) + " = '" + Alltrim(cChave) +"' "
	cWhere := ""
	For nZ := 1 TO ( nNivel - 1 )
		cWhere += aWhere[nZ] + " AND "
	Next	
EndIf	

lClassView := ( nNivClasse == nNivel )

CursorWait()

//processa o cubo e o array aTmpSld contera as tabelas temporarias com os saldos para cada serie(cfg) da consulta
//cada elemento do array aTmpSld representa uma serie (configuracao de cubo)
aTmpSld := PcoProcCubo(aProcCube, nNivel, cWhere, aFilesErased)

aProcessa := {}
aView := {}
nLin := 0

For nX := 1 TO Len(aTmpSld)   // o Len(aTmpSld) tem q ser igual ao Len(aProcCube) 

	oStructCube := aProcCube[nX, 2]
	cDescri 	:= oStructCube:aDescri[nNivel]
	cCpoAux 	:= oStructCube:aChaveR[nNivel]
	cAliasNiv	:= oStructCube:aAlias[nNivel]
	
	If nX == 1 //somente na primeira serie deve montar o titulo
		aTitle := {cDescri,STR0038} //"Conta|CC|Classe","Descricao"
		For nTit := 1 TO aParamCons[3]
			aAdd(aTitle, aCfgSel[nTit, 3])
		Next
		aAdd(aTabMail, aClone(aTitle) )
	EndIf	
	
	cQry := "SELECT * FROM " + aTmpSld[nX]
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TMPAUX", .T., .T. )

	nTotSer := 0

	dbSelectArea("TMPAUX")
	dbGoTop()
	While ! Eof()

		//Ajustes para entidades adicionais CV0 - Renato Neves
		cPlanoCV0 := ""
		cAliasCubo:= oStructCube:aAlias[nNivel]
		If cAliasCubo == "CV0"
			cPlanoCV0 := GetAdvFVal("AKW","AKW_CHAVER",XFilial("AKW")+cCodCube+StrZero(nNivel,2),1,"")
			cPlanoCV0 := Right(AllTrim(cPlanoCV0),2)
			cPlanoCV0 := GetAdvFVal("CT0","CT0_ENTIDA",XFilial("CT0")+cPlanoCV0,1,"")
		EndIf

		cChaveAux	:= TMPAUX->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2))))
		nValorAux	:= TMPAUX->(FieldGet(FieldPos("AKT_SLD001")))
		nLin		:= aScan(aView, {|x| x[1] == cChaveAux} )		// pesquisa para ver se existe a linha no array 
		lNovaLin	:= (nLin == 0)

		//se nao existe
		If lNovaLin 
			Pcoc_AddLin(aView, aTabMail, aProcessa, @nLin)    //adiciona nova linha

			Pcoc_AtribVal(aView, nLin, 1/*nCol*/, cChaveAux/*cValue*/)		//adiciona coluna 1 = codigo
			Pcoc_AtribVal(aTabMail, nLin+1, 1/*nCol*/, cChaveAux/*cValue*/)		//adiciona coluna 1 = codigo

			//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
			cDescrAux := ""
			If (cAliasNiv)->(DbSeek(XFilial()+cPlanoCV0+cChaveAux)) //Ajustado para entidades adicionais CV0 - Renato Neves
				cDescrAux := &(oStructCube:aDescRel[nNivel])
			Else
				cDescrAux := STR0051//"Outros"
			EndIf	
			//EndIf
			Pcoc_AtribVal(aView, nLin, 2/*nCol*/, PadR(cDescrAux, 50)/*cValue*/)		//adiciona coluna 2 = descricao
			Pcoc_AtribVal(aTabMail, nLin+1, 2/*nCol*/, PadR(cDescrAux, 50)/*cValue*/)		//adiciona coluna 2 = descricao

			//adiciona coluna de valor
			Pcoc_AtribVal(aView, nLin, nX+2/*nCol*/, nValorAux/*cValue*/)
			Pcoc_AtribVal(aTabMail, nLin+1, nX+2/*nCol*/, Alltrim(TransForm(nValorAux,'@E 999,999,999,999.99'))/*cValue*/)
			
            //carrega array aProcessa
			aProcessa[nLin, 1] 		:= cChaveAux
			aProcessa[nLin, nX+1] 	:= nValorAux
		Else
			//se ja existe a linha atribui a coluna de valor correspondente
			Pcoc_AtribVal(aView, nLin, nX+2/*nCol*/, nValorAux/*cValue*/)
			aProcessa[nLin, nX+1] 	:= nValorAux
			nLin	:= aScan(aTabMail, {|x| x[1] == cChaveAux} )		// pesquisa para ver se existe a linha no array 
			If nLin > 0
				Pcoc_AtribVal(aTabMail, nLin, nX+2/*nCol*/, Alltrim(TransForm(nValorAux,'@E 999,999,999,999.99'))/*cValue*/)
			EndIf	
		EndIf

		If lTotaliza
			If ! lNovaLin
				(cAliasNiv)->(dbSeek(xFilial()+cChaveAux))
			EndIf
			If ! &(oStructCube:aCondSint[nNivel])  
				nTotSer += nValorAux             
			EndIf	
		EndIf	
		
		dbSelectArea("TMPAUX")
		dbSkip()
	
	EndDo

    If lTotaliza
		aAdd(aTotSer, nTotSer)
    EndIf
    
	dbSelectArea("TMPAUX")
	dbCloseArea()
		
Next
  
If Empty(aProcessa)
	Aviso(STR0026,STR0027,{STR0028},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
EndIf  
            
CursorArrow()

If !Empty(aView) .And. !Empty(aProcessa)

	aView := aSort( aView,,, { |x,y| x[1] < y[1] } )
	
	aTabMail := aSort( aTabMail,2,, { |x,y| x[1] < y[1] } )
    
	If nNivel > 1
		cDescrChv := ""
		For nX := 1 TO ( nNivel - 1 )
			cDescrChv += aDescrAnt[nX]+CRLF
		Next	
	EndIf
	
	If lTotaliza	// Exibe totais das series
  		AAdd( aView, { STR0045, "" } ) // TOTAL
		AAdd( aTabMail, { STR0045, Space(50) } ) // TOTAL
		          
		nLenView := Len(aView)
		
		For nx := 1 to Len(aTotSer)
			AAdd( aView[nLenView], 0 )
		Next nx
		
		For nX := 1 to Len(aTotSer)
			aView[nLenView,nX+N_COL_VALOR] += aTotSer[nX]
		Next nX
	
		For nX := 1 to Len(aTotSer)
			aAdd(aTabMail[Len(aTabMail)], Alltrim(TransForm(aView[nLenView,nx+N_COL_VALOR],'@E 999,999,999,999.99')))
		Next nX
		
	EndIf
		
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - "+cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,If(Empty(cDescrChv),0,11+((nNivel-1)*11)),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	If !lShowGraph
		oPanel2:Hide()
	EndIf	
	
	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	
	For nx := 1 TO aParamCons[3]
		aAdd(aSeries,Nil	)
		aSeries[Len(aSeries)] := oGraphic:CreateSerie( If(lNewGrafic,If(nTpGrafico==2,4,nTpGrafico),nTpGrafico) )
	Next	

	For nx := 1 to Len(aProcessa)
		For ny := 1 TO aParamCons[3]
			oGraphic:Add(aSeries[ny], Round(aProcessa[nx, ny+1],2) , aProcessa[nX, 1], C_330Cores(ny))
	    Next
	Next    

	If lTotaliza
		nLenView := Len(aView)
		For nx := 3 to Len( aView[nLenView] )
			oGraphic:Add(aSeries[nx-N_COL_VALOR], Round(aView[nLenView,nx],2) , STR0045, C_330Cores(nx-N_COL_VALOR))	// TOTAL
		Next nx
	EndIf
	
	oGraphic:l3D := .F.

	If lNewGrafic
		
		//oGraphic:Hide()
		//***********************************************
		// Implemantacao do Grafico com FwChartFactory  *
		//***********************************************
		// Monta Series
		For ny := 1 TO aParamCons[3]
			aAdd(aSerie2, aCfgSel[ny, 3])
		Next
		
		PcoGrafDay(aProcessa,nNivel,cChave,oPanel2,nTpGrafico,aSerie2, lTotaliza ,aTotSer,,,.T.)
	
	EndIf

	@ 2,4 SAY STR0032 of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)//"Drilldown"
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2   SAY cDescrChv Of oPanel PIXEL SIZE 640 ,79 FONT oBold

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 TO Len(aView)
		aView[nX] := PcoFrmDados(aView[nX], cClasse, lClassView)
 	Next

	oView:SetArray(aView)
	oView:blDblClick := bDoubleClick
	oView:bLine := { || aView[oView:nAT]}

    //tem que ficar aqui por causa da variavel cDescrChv, aTitle, aView
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aTitle,aView} } ))
	
	dbSelectArea("AL1")

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoc_AddLin บAutor  ณPaulo Carnelossi  บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que adiciona linha no array aview e no array         บฑฑ
ฑฑบ          ณaprocessa para a grade com o grafico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pcoc_AddLin(aView, aTabMail, aProcessa, nLin)
Local nX
aAdd(aView, {})  //adiciona uma nova linha
aAdd(aTabMail, {})  //adiciona uma nova linha
aAdd(aView[Len(aView)], "")  //adiciona na linha a primeira coluna (Codigo)
aAdd(aView[Len(aView)], "")  //adiciona na linha a segunda coluna (Descricao)
aAdd(aTabMail[Len(aTabMail)], "")  //adiciona na linha a primeira coluna (Codigo)
aAdd(aTabMail[Len(aTabMail)], "")  //adiciona na linha a segunda coluna (Descricao)
For nX := 1 TO aParamCons[3]  //acrescenta uma nova coluna para cada serie
	aAdd(aView[Len(aView)], 0)  
	aAdd(aTabMail[Len(aTabMail)],Alltrim(TransForm(0,'@E 999,999,999,999.99')))
Next

nLin := Len(aView)

aAdd(aProcessa, {})
aAdd(aProcessa[Len(aProcessa)], "")  
For nX := 1 TO aParamCons[3]  //acrescenta uma nova coluna para cada serie
	aAdd(aProcessa[Len(aProcessa)], 0)  
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoc_AtribVal บAutor  ณPaulo Carnelossi  บ Data ณ 23/01/08  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que atribui um valor a linha e coluna informada para บฑฑ
ฑฑบ          ณa grade com o grafico                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pcoc_AtribVal(aView, nLin, nCol, cValue)

aView[nLin, nCol] := cValue

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoc_330lct บAutor  ณPaulo Carnelossi  บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณBrowse para Visualizacao dos lancamentos que compoem o saldoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Expressao Advpl de filtro na tabela de lancamentos  บฑฑ
ฑฑบ          ณEXPC2 - Indicar se deve exibir mensagem de aviso caso nao   บฑฑ
ฑฑบ          ณ        encontre nenhum lancamento no filtro passado como   บฑฑ
ฑฑบ          ณ        parametro.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consultas de detalhe do lancamento (AKD)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pcoc_330lct(aFiltroAKD, lExibeMsg)
Local aArea			:= GetArea()
Local aAreaAKD		:= AKD->(GetArea())
Local aSize			:= MsAdvSize(,.F.,430)
Local aIndexAKD	    := {}
Local nX
Local cFiltroAKD

Private bFiltraBrw  := {|| Nil }
Private aRotina 	:= {	{STR0002,"PesqBrw"    ,0,2},;  //"Pesquisar"
							{STR0003,"C_330LctView",0,2}}  //"Visualizar"

Default lExibeMsg := .F.

cFiltroAKD := "AKD->AKD_FILIAL ='"+xFilial("AKD")+"' .And. "
cFiltroAKD += "DTOS(AKD->AKD_DATA) <= '" +DTOS(aParamCons[1])+"' .And. "

For nX := 1 TO Len(aFiltroAKD)

	If aFiltroAKD[nX] != NIL
		cFiltroAKD += aFiltroAKD[nX]
		If nX < Len(aFiltroAKD)
			cFiltroAKD += " .And. "
		EndIf
	EndIf

Next	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a Filtragem                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bFiltraBrw := {|| FilBrowse("AKD",@aIndexAKD,@cFiltroAKD) }
Eval(bFiltraBrw)

If AKD->( EoF() )
	If lExibeMsg 
		Aviso(STR0029,STR0042,{"Ok"})		// Atencao ### Nใo existem lan็amentos para compor o saldo deste cubo.
	EndIf	
Else
	mBrowse(aSize[7],0,aSize[6],aSize[5],"AKD")
//	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AKD",,aRotina,,,,.F.,,,,,,,,.F.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura as condicoes de Entrada                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EndFilBrw("AKD",aIndexAKD)

RestArea(aAreaAKD)
RestArea(aArea)
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC_330LctView บAutor  ณPaulo Carnelossi  บ Data ณ  23/01/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVisualizacao do lancamento                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C_330LctView()
Local aArea	:= GetArea()
Local aAreaAKD	:= AKD->(GetArea())

PCOA050(2)

RestArea(aAreaAKD)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC_330Cores บAutor  ณPaulo Carnelossi   บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna cor para montagem do grafico - para cada serie e    บฑฑ
ฑฑบ          ณdefinida uma cor                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C_330Cores(nX)
Local	aCores := { CLR_BLUE, ;
					CLR_CYAN, ;
					CLR_GREEN, ;
					CLR_MAGENTA, ;
					CLR_RED, ;
					CLR_BROWN, ;
					CLR_HGRAY, ;
					CLR_LIGHTGRAY, ;
					CLR_BLACK}
If nX < Len(aCores)
	nCor := aCores[nX]
Else
	nCor := C_330Cores(nX/Len(aCores))
EndIf

Return nCor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPCOC_330Cfg() บAutor  ณPaulo Carnelossi  บ Data ณ 23/01/08  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMonta parambox para digitacao das configuracoes de cubos a  บฑฑ
ฑฑบ          ณser comparada graficamente com a cfg inicial                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC_330Cfg(nQtdCfg, lContinua)
Local aCfgCub := {}
Local aCfgPar := {}
Local aCuboCfg := {}
Local nX
For nX := 1 TO nQtdCfg
	&("MV_PAR"+AllTrim(STRZERO((nX*3)-2,2,0)	)	) := Space(LEN(AL4->AL4_CODIGO))
	&("MV_PAR"+AllTrim(STRZERO((nX*3)-1,2,0))) := 1
	aAdd(aCuboCfg, { 1  ,STR0039+Str(nX, 2,0),Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. }) //"Config.Cubo Serie"
	aAdd(aCuboCfg, { 3 ,STR0040,1,{STR0021,STR0022},40,,.F.}) //"Exibe Configura็๕es"###"Sim"###"Nao"
	aAdd(aCuboCfg, { 1  ,STR0036,PadR(STR0035+Str(nx,2,0),30),"@!" 	 ,""  ,"" ,"" ,75 ,.F. })//"Descri็ใo S้rie"###"Serie "
Next

If Len(aCuboCfg) > 0
	lContinua := ParamBox(aCuboCfg, STR0041, aCfgPar,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC331_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"
EndIf

If lContinua
	For nX := 1 TO Len(aCfgPar) STEP 3
		aAdd( aCfgCub, { aCfgPar[ nX ]/*Configuracao*/, aCfgPar[ nX + 1]/*se exibe Configuracao*/, aCfgPar[ nX + 2 ]/*descricao da serie*/ } )
	Next
EndIf

Return aCfgCub
	
//=========================================================================================================//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoProcCubo บAutor  ณPaulo Carnelossi    บ Data ณ 23/01/08  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMonta as querys baseados nos parametros e configuracoes de  บฑฑ
ฑฑบ          ณcubo e executa essas querys para gerar os arquivos tempora- บฑฑ
ฑฑบ          ณrios cujos nomes sao devolvidos no array aTabResult         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoProcCubo(aProcCube, nNivel, cWhere, aFilesErased)
Local cCodCube
Local aTabResult := {}
Local cArquivo := ""
Local cArqAS400 := ""
Local aQueryDim, cArqTmp
Local nX,nZ
Local cWhereTpSld := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))

//Processar todas as series(configuracoes) do cubo

For nX := 1 to Len(aProcCube)

    dData		:= aProcCube[nX, 1]
	oStructCube := aProcCube[nX, 2]
	lZerado 	:= aProcCube[nX, 5]
	lSintetica 	:= aProcCube[nX, 6]
	lTotaliza 	:= aProcCube[nX, 7]
	cWhereTpSld := aProcCube[nX, 8]
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
	
	aQuery := PcoCriaQry( cCodCube, nNivel, 1/*nMoeda*/, cArqAS400, 1/*nQtdVal*/, { dData }/*aDtSld*/, aQryDim, cWhere/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, .F., NIL )

	PcoPopulaTemp(oStructCube, cArquivo, aQuery, 1/*nQtdVal*/, lZerado, cArqAS400)

	aAdd( aTabResult, cArquivo )

Next

Return( aTabResult )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpco331Ser บAutor  ณ Acacio Egas        บ Data ณ  10/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o limite de series da consulta                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function pco331Ser()

Local lRet	:= .T.


If MV_PAR03 >= 30
	Help("",1,"PCO331SER")
	lRet := .F.
EndIf

Return lRet
