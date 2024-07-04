#INCLUDE "pcoc341.ch"
#include "protheus.ch"
#include "msgraphi.ch"

#DEFINE N_COL_VALOR		2

Static lPostgres

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC341  ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 11/02/08   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta ao arquivo de saldos mensais dos Cubos  ณฑฑ
ฑฑณ          ณ Por Periodo                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC341                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCO_C340(2) - Executa a chamada da funcao de visua- ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC341(nCallOpcx,dIni,dFim,nTpPer,nMoeda,cCodCube,cCfgCube,lZerado)

Local bBlock
Local nPos

SaveInter()

Private cCadastro	:= STR0001 //"Consulta Saldos por Periodos - Cubos"
Private aRotina := MenuDef()

If lPostgres == Nil
	lPostgres := Alltrim(Upper(TCGetDB()))=="POSTGRES"
EndIf

If nCallOpcx <> Nil
	nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
	If ( nPos # 0 )
		bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g,h| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g,h) }" )
		Eval( bBlock,Alias(),AL4->(Recno()),nPos,,,,dIni,dFim,nTpPer,nMoeda,cCodCube,cCfgCube,lZerado)
	EndIf
Else
	mBrowse(6,1,22,75,"AL1")
EndIf

RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco_340View บAutor  ณPaulo Carnelossi    บ Data ณ  11/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta a grade e o grafico baseado nos parametros   บฑฑ
ฑฑบ          ณinformados                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_340View(cAlias,nRecno,nOpcx,xRes1,xRes2,xRes3,dIni,dFim,nTpPer,nMoeda,cCodCube,cCfgCube,lZerado)
Local nX, nZ
Local nTpGraph
Local aCuboCfg 		:= {}
Local aSeriesCfg 	:= {}
Local aListArq 		:= {}
Local aAcessoCfg 
Local oStructCube
Local aConfig  := {}
Local lSintetica 	:= .F.
Local lTotaliza 	:= .T.
Local lMovimento 	:= .F.
Local aProcCube 	:= {}
Local aFilesErased 	:= {}
Local aDescrAnt
Local aFiltroAKD
Local aWhere
Local cWhereTpSld
Local lContinua 	:= .T.
Local aTpGrafico

//***********************************************
// Implemantacao do Grafico com FwChartFactory  *
//***********************************************
Private lNewGrafic := SuperGetMV("MV_PCOTPGR",.F.,2)==1 .and. FindFunction("__FWCBCOMP")
// parametro que informa qual objeto grafico sera utilizado 1= fwChart qquer outra informacao = msGraphic
Private oLayer,oChart := Nil

If lNewGrafic
                         
	aTpGrafico:= {STR0004,; //"1=Linha"
					"2="+SubStr(STR0007,3)}//"4=Barra"

Else
	aTpGrafico 	:= {STR0004,; //"1=Linha"
								STR0005,; //"2=Area"
								STR0006,; //"3=Pontos"
								STR0007,; //"4=Barra"
								STR0008,; //"5=Piramide"
								STR0009,; //"6=Cilindro"
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

Private aParamCons 	:= {}
Private aCfgCub 	:= {}
Private aCfgSel 	:= {}

Private aPeriodo
Private aPerAux		:= {}

Private aColAux
Private COD_CUBO  	:= AL1->AL1_CONFIG
Private nNivInic 	:= 1
Private cClasse
Private lClassView 	:= .F.
                
DEFAULT dIni 		:= dDataBase
DEFAULT dFim 		:= dDataBase+20
DEFAULT nTpPer		:= 3
DEFAULT cCodCube  	:= AL1->AL1_CONFIG
DEFAULT nMoeda 		:= 1
DEFAULT lZerado 	:= .F.

//***************************
// Valida Estrtura do Cubo  *
//***************************
If FindFunction("PcoVldCub") .and. !PcoVldCub(COD_CUBO)
	lContinua := .F.
EndIf

If lContinua
	//1a. tela de parametros
	lContinua := ParamBox({ 	{ 1 ,STR0019,dIni,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
							{ 1 ,STR0020,dFim,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
							{ 2 ,STR0021,nTpPer,{STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0070,STR0077},80,"",.F.},; //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"##'7=Diario'##'8=Trimestral'
							{ 2 ,STR0028,1,{STR0029,STR0030,STR0031,STR0032,STR0033},80,"",.F.},; //"Moeda"###"1=Moeda 1"###"2=Moeda 2"###"3=Moeda 3"###"4=Moeda 4"###"5=Moeda 5"
							{ 2 ,STR0034,4,aTpGrafico,80,"",.F.},; //"Tipo do Grafico"
							{ 1 ,STR0035,1,"" 	 ,""  ,""    ,"" ,50 ,.F. },;	//"Qtd. Series"
							{ 3 ,STR0069, 1,{STR0039,STR0040},40,,.F.} },STR0036,aParamCons,{||PCOC341TOk()},,,,,, "PCOC341_01",,.T.) //"Parametros" ### "Sim" ### "Nao"
EndIf

If lContinua							

	For nX := 1 TO aParamCons[6]
		&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)),2,0))) := Space(LEN(AL4->AL4_CODIGO))
		&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)+1),2,0))) := 1
		aAdd(aCuboCfg, { 1  ,STR0037+Str(nX, 2,0),Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. }) //"Config.Cubo Serie"
		aAdd(aCuboCfg, { 3 ,STR0038,1,{STR0039,STR0040},40,,.F.}) //"Exibe Configura็๕es"###"Sim"###"Nao"
		aAdd(aCuboCfg, { 1  ,STR0041,STR0042+Str(nx,2,0),"@!" 	 ,""  ,"" ,"" ,75 ,.F. })//"Descri็ใo S้rie"###"Serie "
		aAdd(aCuboCfg, { 3 ,STR0043,1,{STR0044,STR0045},95,,.F.}) //"Considerar "###"Saldo final do periodo"###"Movimento do periodo"
	Next
	
	//2a. tela de parametros (Solicita as configuracoes de cubos desejadas)
	lContinua := ParamBox(aCuboCfg, STR0046, aCfgCub,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC341_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"

EndIf

If lContinua

	nTpGraph 	:= If(ValType(aParamCons[5])=="N", aParamCons[5], Val(aParamCons[5]))
	nTpPer 		:= If(ValType(aParamCons[3])=="N", aParamCons[3], Val(aParamCons[3]))
	aParamCons[4]	:= If(ValType(aParamCons[4])=="N", aParamCons[4], Val(aParamCons[4]))
	aPeriodo 	:= PcoRetPer(aParamCons[1]/*dIniPer*/, aParamCons[2]/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/, aPerAux)
	nNivInic 	:= 1
	
	If Len(aPerAux) > 180 //limitar em 180 no maximo
        Aviso(STR0047, STR0078, {"Ok"})  //"Atencao"##"Consulta limitada a 180 periodos no maximo. Verifique a periodicidade."
		lContinua := .F.
	EndIf

    If lContinua
		For nX := 1 TO aParamCons[6]
			aAdd(aSeriesCfg, Str(nX,1,0)+"="+aCfgCub[ (nX*4)-1 ])
		Next
	
		For nX := 1 TO Len(aCfgCub) STEP 4
			aAdd( aCfgSel, { aCfgCub[ nX ]/*Configuracao*/, aCfgCub[ nX + 1]/*se exibe Configuracao*/, aCfgCub[ nX + 2 ]/*descricao da serie*/, aCfgCub[ nX + 3 ]/*Final Periodo/Movimento*/ } )
		Next
	
	   	For nX := 1 TO Len(aCfgSel)
	   	
			//verificar se usuario tem acesso as configuracoes
			aAcessoCfg := PcoVer_Acesso( cCodCube, aCfgSel[nX,1] )  	//retorna posicao 1 (logico) .T. se tem acesso
	   											 						//        posicao 2 - Nivel acesso (0-Bloqueado 1-Visualiza 2-altera 
			If ! aAcessoCfg[1]
				lContinua := .F.
	   			Exit
	   		EndIf
	   		
	   		If lContinua
	   		
				lMovimento := ( aCfgSel[nX, 4] == 2 )
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
					lZerado		:=	aConfig[Len(aConfig)-1]          	//penultimo informacao da parambox (check-box)
					lSintetica	:=	aConfig[Len(aConfig)]        		//ultimo informacao da parambox (check-box)
					lTotaliza 	:= ( aParamCons[7] == 1 )
					//veja se tipo de saldo inicial e final eh o mesmo e se nao ha filtro definido neste nivel
					cWhereTpSld := ""
					If oStructCube:nNivTpSld > 0 .And. ;
						oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
						Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
							cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
					EndIf								
					
				    aAdd(aProcCube, { aPerAux, oStructCube, aCfgSel, aAcessoCfg, lZerado, lSintetica, lTotaliza, cWhereTpSld, lMovimento } )
				    
				EndIf
		   		
			EndIf
			
			If ! lContinua 
				Exit
			EndIf
	   		
	   	Next 
    EndIf
	//montagem da planilha e grafico
	If lContinua
		PCOC_340PFI(aProcCube,nNivInic,""/*cChave*/,nTpGraph,aDescrAnt,aFiltroAKD,aWhere,.T./*lShowGraph*/,aListArq,aFilesErased)
	Else
		Aviso(STR0047,STR0048,{STR0049},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
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
ฑฑบPrograma  ณPCOC_340PFI บAutor  ณPaulo Carnelossi  บ Data ณ  11/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que exibe a grade e o grafico                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCOC_340PFI( aProcCube, nNivel, cChave, nTpGrafico, aDescrAnt, aFiltroAKD, aWhere , lShowGraph, aListArq, aFilesErased)
Local aArea 		:= GetArea()

Local oDlg
Local oPanel
Local oPanel1
Local oPanel2
Local aSize      	:= {}
Local aPosObj    	:= {}
Local aObjects   	:= {}
Local aInfo      	:= {}

Local oView
Local aView      	:= {}

Local oGrafico

Local aProcessa
Local nx,ny,nZ
Local cDescri    	:= ""
Local aTabMail   	:= {}
Local aParam     	:= {"",.F.,.F.,.F.}

Local lPergNome  	:= ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )

Local aButtons   	:= {}

Local cWhere := ""
Local aDtSaldo := {}
Local aDtIni := {}
Local aTotSer := {}
Local aTmpSld, cQry, nLin, cChaveAux, aValorAux, aTotSerAux
Local nMaxNiv := aProcCube[1, 2]:nMaxNiveis
Local nNivClasse := aProcCube[1, 2]:nNivClasse

Local lTotaliza := ( aParamCons[7] == 1 )
Local oStructCube 
Local cDescrAux := ""
Local cDescrChv := ""
Local cCpoAux
Local lAuxSint 

Local bLinTotal 	:= {|| lTotaliza .And. Alltrim(Upper(aView[oView:nAT,1])) == "TOTAL" } 

Local bClasse 		:= {|| If(lClassView, cClasse := aView[oView:nAT,1], NIL) }

Local bAddDescr 	:= {|| aDescrAnt[nNivel] := Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]) }

Local bFiltro 		:= {|| aFiltroAKD[nNivel] := cCpoAux +" = '"+PadR(aView[oView:nAT,1],Len(&cCpoAux))+"' "}

Local bDoubleClick 	:= {||	If(Eval(bLinTotal), ;
								NIL, ;						// se for ultima linha/total nao faz nada 
								If(nNivel < nMaxNiv, ; 		//se nao atingiu o ultimo nivel
									( 	Eval(bFiltro), ; 	//atribui o filtro
										Eval(bClasse), ;  	//se eh dimensao por classe atribui a varmem
										Eval(bAddDescr), ;  //adiciona a descricao e faz drilldown cubo
										PCOC_340PFI(aProcCube,nNivel+1,aView[oView:nAT,1]/*cChave*/,nTpGrafico,aDescrAnt,aFiltroAKD,aWhere,@lShowGraph,aListArq,aFilesErased) ;
									), ;//senao
									( 	Eval(bFiltro), ;		//atribui o filtro
										Pcoc_340lct(aFiltroAKD) ;  // no ultimo nivel o drilldown eh o lancto AKD
									);
								) ;//fecha If
							) ;//fecha If
						}  //fecha bloco de codigo

Local bEncerra := {|| 	If( nNivel == nNivClasse, (lClassView := .F., cClasse := NIL), NIL), ;  // se for nivel da classe inicializa var.
						If( nNivel > nNivInic, ;
								oDlg:End(), ; //se nivel > nivel inicial somente fecha
								If( Aviso(STR0050,STR0051, {STR0039, STR0040},2)==1, ;  //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
									( PcoArqSave(aListArq), oDlg:End() ), ;
							 		NIL;
						  		);//fecha o 3o. If
						 ) ; //fecha o 2o.If		
					} //fecha codeBlock

//Tratamento das entidades adicionais CV0
Local cPlanoCV0	:= ""
Local cAliasCubo	:= ""
Local cCodCube	:= AL1->AL1_CONFIG
Local nTamCampo := 0
Local nSer_EOF  := 0
 
DEFAULT aDescrAnt := {}
DEFAULT cChave := ""
DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}

If nNivel+1 <= nMaxNiv
	aButtons := {	{"PMSZOOMIN"	,{|| Eval(oView:blDblClick) },STR0052 ,STR0053},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  ,{|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0054,STR0055 },; //"Enviar Emial"###"Email"
						{"GRAF2D"   ,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0071,STR0072 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	,{|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq) },STR0074,STR0075 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" ,{|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       ,{|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0060 ,STR0060 }; //"Proximo"
					}
Else
	aButtons := {	{"PMSZOOMIN"	,{|| Eval(oView:blDblClick) },STR0052 ,STR0053},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  ,{|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0054,STR0055 },; //"Enviar Emial"###"Email"
						{"GRAF2D"   ,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0071,STR0072 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	,{|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq) },STR0074,STR0075 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" ,{|| PcoConsPsq(aView,.F.,@aParam,@oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       ,{|| PcoConsPsq(aView,.T.,@aParam,@oView) },STR0060 ,STR0060 }; //"Proximo"
					}
EndIf					

For nX := 1 TO Len(aPerAux)
	aAdd(aDtIni, STOD(aPerAux[nX,1]) ) 
	aAdd(aDtSaldo, STOD(aPerAux[nX,2]) ) 
Next

//prepara a clausula where para qdo pressionar o drill-down ja passar para a a funcao
If nNivel > 1
	If Empty(Alltrim(cChave))
		aWhere[ nNivel-1 ] := "AKT.AKT_NIV" + StrZero(nNivel-1, 2) + " = ' ' "
	Else
		aWhere[ nNivel-1 ] := "AKT.AKT_NIV" + StrZero(nNivel-1, 2) + " = '" + Alltrim(cChave) +"' "
	EndIf
	cWhere := ""
	For nZ := 1 TO ( nNivel - 1 )
		cWhere += aWhere[nZ] + " AND "
	Next	
EndIf	

lClassView := ( nNivClasse == nNivel )

CursorWait()

//processa o cubo e o array aTmpSld contera as tabelas temporarias com os saldos para cada serie(cfg) da consulta
//cada elemento de aTmpSld equivale a uma serie (config. cubo)
aTmpSld := 	PcoProcCubo(aProcCube, nNivel, aParamCons[4]/*nMoeda*/, cWhere, aFilesErased, aDtSaldo, aDtIni)

aProcessa := {}
aView := {}
nLin := 0

For nX := 1 TO Len(aTmpSld)   // o Len(aTmpSld) tem q ser igual ao Len(aProcCube) 

	oStructCube := aProcCube[nX, 2]
	cDescri 	:= oStructCube:aDescri[nNivel]
	cCpoAux 	:= oStructCube:aChaveR[nNivel]

	If nX == 1 //somente na primeira serie deve montar o titulo
		aColAux := {}
		aAdd(aColAux, cDescri)
		aAdd(aColAux, STR0058)//"Descricao"
		For nY := 1 TO Len(aPeriodo)
			For nZ := 1 TO aParamCons[6]  //para cada periodo colocar colunas com as series
				aAdd(aColAux, aPeriodo[nY]+"["+AllTrim(aCfgCub[(nZ*4)-1])+"]")
			Next
		Next
		aAdd(aTabMail, aClone(aColAux) )
	EndIf	

	cQry := "SELECT * FROM " + aTmpSld[nX]
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TMPAUX", .T., .T. )

    aTotSerAux := Array(Len(aPeriodo))
    aFill(aTotSerAux, 0)

	dbSelectArea("TMPAUX")
	dbGoTop()
	If !Eof()
		While ! Eof()
	
			//Ajustes para entidades adicionais CV0 - Renato Neves
			cPlanoCV0 := ""
			cAliasCubo:= oStructCube:aAlias[nNivel]
			nTamCampo:= len(&(oStructCube:achave[nNivel]))
			If cAliasCubo == "CV0"
				cPlanoCV0 := GetAdvFVal("AKW","AKW_CHAVER",XFilial("AKW")+cCodCube+StrZero(nNivel,2),1,"")
				cPlanoCV0 := Right(AllTrim(cPlanoCV0),2)
				cPlanoCV0 := GetAdvFVal("CT0","CT0_ENTIDA",XFilial("CT0")+cPlanoCV0,1,"")
			EndIf

			cChaveAux :=  PadR(TMPAUX->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2)))) , nTamCampo   )
	
			//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
			dbSelectArea(oStructCube:aAlias[nNivel])
			cDescrAux := ""
			lAuxSint := .F.	
			
			If DbSeek(XFilial()+iif(!empty(cPlanoCV0),cPlanoCV0+cChaveAux,cChaveAux)) //Ajustado para entidades adicionais CV0 - Renato Neves
				cDescrAux := &(oStructCube:aDescRel[nNivel])
				If ! Empty(oStructCube:aCondSint[nNivel])
					lAuxSint := &(oStructCube:aCondSint[nNivel])
				EndIf
			Else
				cDescrAux := STR0076 //"Outros"
			EndIf
	
			aValorAux := Array(Len(aPeriodo))
		    aFill(aValorAux, 0)
	
			For nY := 1 TO Len(aPeriodo)
				aValorAux[nY] := TMPAUX->(FieldGet(FieldPos("AKT_SLD"+StrZero(nY, 3))))
				If ! lAuxSint   //SOMENTE ACUMULA NO TOTAL SE NAO FOR SINTETICA
					aTotSerAux[nY] += aValorAux[nY]
				EndIf
			Next
			
			//pesquisa para ver se ja nao existe a linha no array para list box
			If ( nLin := aScan(aView, {|x| x[1] == cChaveAux} ) ) == 0
				//se nao existe
				Pcoc_AddLin(aView, aProcessa, aTabMail, @nLin)       								//adiciona nova linha
	
				Pcoc_AtribVal(aView, nLin, 1/*nCol*/, cChaveAux/*xValue*/)		//adiciona coluna 1 = codigo
	
				Pcoc_AtribVal(aView, nLin, 2/*nCol*/, cDescrAux/*xValue*/)				//adiciona coluna 2 = descricao
	
				//adiciona as colunas de valores de cada periodo
				For nZ := 1 TO Len(aPeriodo)
					Pcoc_AtribVal(aView, nLin, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2  /*nCol*/, aValorAux[nZ] /*xValue*/)
				Next	
				
	            //carrega array aProcessa
				Pcoc_AtribVal(aProcessa, nLin, 1/*nCol*/, cChaveAux /*xValue*/)
	
				For nZ := 1 TO Len(aPeriodo)
					Pcoc_AtribVal(aProcessa, nLin, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 1  /*nCol*/, aValorAux[nZ] /*xValue*/)
				Next	
				
				Pcoc_AtribVal(aTabMail, nLin+1, 1/*nCol*/, cChaveAux /*xValue*/)
				Pcoc_AtribVal(aTabMail, nLin+1, 2/*nCol*/, PadR(cDescrAux, 50) /*xValue*/)
	
				For nZ := 1 TO Len(aPeriodo)
					Pcoc_AtribVal(aTabMail, nLin+1, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2 /*nCol*/, Alltrim(Transform(aValorAux[nZ], "@E 999,999,999,999.99"))/*xValue*/)
				Next	
	
			Else
	
				//se ja existe a linha atribui a coluna de valor correspondente
				For nZ := 1 TO Len(aPeriodo)
					Pcoc_AtribVal(aView, 		nLin, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2/*nCol*/, aValorAux[nZ]/*xValue*/)
					Pcoc_AtribVal(aProcessa, 	nLin, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 1/*nCol*/, aValorAux[nZ]/*xValue*/)
					Pcoc_AtribVal(aTabMail, 	nLin+1, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2/*nCol*/, Alltrim(Transform(aValorAux[nZ], "@E 999,999,999,999.99"))/*xValue*/)
				Next	
	
			EndIf
			
			dbSelectArea("TMPAUX")
			dbSkip()
		
		EndDo
    Else
		nSer_EOF++
    EndIf
    
	aAdd(aTotSer, aClone(aTotSerAux))
	
	dbSelectArea("TMPAUX")
	dbCloseArea()
		
Next

If nSer_EOF == Len(aTmpSld)    	
	IW_MsgBox(STR0059,STR0050,"STOP")	//"Nใo existem lan็amentos para compor o saldo deste cubo."###"Aten็ใo"
EndIf

CursorArrow()

If !Empty(aView)
                
	aView := aSort( aView,,, { |x,y| x[1] < y[1] } )
	aTabMail := aSort( aTabMail,2,, { |x,y| x[1] < y[1] } )
	aProcessa := aSort( aProcessa,,, { |x,y| x[1] < y[1] } )
	
	If nNivel > 1
		cDescrChv := ""
		For nX := 1 TO ( nNivel - 1 )
			cDescrChv += aDescrAnt[nX]+CRLF
		Next	
	EndIf

	If lTotaliza	// Exibe totais das series
		AAdd( aView, { STR0068, "" } ) // TOTAL
		AAdd( aProcessa, { "" } )
		AAdd( aTabMail, { STR0068, Space(50) } ) // TOTAL
		          
		nLenView := Len(aView)
		
		For nx := 1 to Len(aTotSer)
			For nZ := 1 TO Len(aPeriodo)
				AAdd( aView[nLenView], 0 )
				AAdd( aProcessa[nLenView], 0 )
				AAdd( aTabMail[Len(aTabMail)], Alltrim(Transform(0, "@E 999,999,999,999.99")) )
			Next // nZ
		Next nx
		
		For nX := 1 to Len(aTotSer)
			//adiciona as colunas de valores de cada periodo
			aValorAux := aClone(aTotSer[nX])
			For nZ := 1 TO Len(aPeriodo)
				Pcoc_AtribVal(aView, nLenView, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2  /*nCol*/, aValorAux[nZ] /*xValue*/)
				Pcoc_AtribVal(aProcessa, nLenView, (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 1  /*nCol*/, aValorAux[nZ] /*xValue*/)
				Pcoc_AtribVal(aTabMail, Len(aTabMail), (nZ * aParamCons[6]) - (aParamCons[6]-nX) + 2  /*nCol*/, Alltrim(Transform(aValorAux[nZ], "@E 999,999,999,999.99")) /*xValue*/)
			Next // nZ
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

	@ 2,4 SAY "Drilldown" of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2   SAY cDescrChv Of oPanel PIXEL SIZE 640 ,79 FONT oBold
	

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aColAux,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 TO Len(aView)
		aView[nX] := PcoFrmDados(aView[nX], cClasse, lClassView)
 	Next

	oView:SetArray(aView)
	oView:blDblClick := bDoubleClick
	oView:bLine := { || aView[oView:nAT]}
	oView:bChange := { || oGrafico:= C340_Grafico(aPosObj, oPanel2, oFont, nTpGrafico, cChave, nNivel, aProcessa[oView:nAT],aParamCons) }
			   
	oGrafico:= C340_Grafico(aPosObj, oPanel2, oFont, nTpGrafico, cChave, nNivel, aProcessa[oView:nAT],aParamCons)
	
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aColAux,aView} } ))

	dbSelectArea("AL1")
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{|| Eval(bEncerra)},,aButtons )

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC340_GraficoบAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta o objeto grafico para exibicao no folder   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340_Grafico(aPosObj, oPanel, oFont, nTpGrafico, cChave, nNivel, aValues, aParamCons)
Local nZ        := 0
Local ny        := 0
Local oGraphic  
Local nPeriodo	:= 1
Local aSeries	:= {}
Local aColors   := {CLR_BLUE,CLR_GREEN,CLR_RED,CLR_CYAN,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,CLR_YELLOW,CLR_HBLUE}
Local aSerie2	:= {}

	@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	
	If !lNewGrafic .AND. oLayer == Nil
		For nZ := 1 TO aParamCons[6]
			aAdd(aSeries,Nil	)
			aSeries[nz] := oGraphic:CreateSerie( If(lNewGrafic,If(nTpGrafico==2,4,nTpGrafico),nTpGrafico) )	
		Next nz                
		
		oGraphic:l3D := .F.
		
		For nZ := 2 To Len(aValues) Step aParamCons[6]
			For ny := 1 TO aParamCons[6]
				oGraphic:Add(aSeries[ny], Round(aValues[nZ+ny-1],2), aPeriodo[nPeriodo], aColors[ny])	
			Next
			nPeriodo++
		Next
	EndIf	

	If lNewGrafic

		//oGraphic:Hide()
		//***********************************************
		// Implemantacao do Grafico com FwChartFactory  *
		//***********************************************
		// Monta Series
		aAdd(aSerie2, AllTrim(aCfgCub[3]))
		For ny := 2 To aParamCons[6]
			aAdd(aSerie2, AllTrim(aCfgCub[(4*(ny-1))+3]))
		Next
		
		PcoGrafPer(aValues,aPeriodo,nNivel,cChave,oPanel,nTpGrafico,aSerie2,@oLayer,@oChart,.T.)
	
	EndIf

Return(oGraphic)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPco_C340lct  บAutor ณEdson Maricate      บ Data ณ 03/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza lancamento                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoC_340lct(aFiltroAKD, lExibeMsg)
Local aArea			:= GetArea()
Local aAreaAKD		:= AKD->(GetArea())
Local aSize			:= MsAdvSize(,.F.,430)
Local aIndexAKD	:= {}
Local cFiltroAKD
Local nX
PRIVATE bFiltraBrw:= {|| Nil }
Private aRotina 	:= {		{STR0002,"PesqBrw",0,2},;  //"Pesquisar"
								{STR0003,"_C340LctView",0,2}}  //"Visualizar"

Default lExibeMsg := .F.

cFiltroAKD := "AKD->AKD_FILIAL ='"+xFilial("AKD")+"' .And. "
cFiltroAKD += "DTOS(AKD->AKD_DATA) >= '" +DTOS(aParamCons[1])+"' .And. "
cFiltroAKD += "DTOS(AKD->AKD_DATA) <= '" +DTOS(aParamCons[2])+"' .And. "

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
	Aviso(STR0050,STR0059,{"Ok"})	// Atencao ### Nใo existem lan็amentos para compor o saldo deste cubo.
Else
	If ExistBlock("PCOC3412")
		aAddBtn := ExecBlock("PCOC3412", .F., .F.)
		aAdd(aRotina,aAddBtn)
	EndIf
	
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
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ_C340LctView บAutor ณEdson Maricate      บ Data ณ 03/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza lancamento                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function _C340LctView()
Local aArea	:= GetArea()
Local aAreaAKD	:= AKD->(GetArea())

PCOA050(2)

RestArea(aAreaAKD)
RestArea(aArea)
Return



Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ STR0003, 	"Pco_340View" , 0 , 2} }  //"Visualizar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3411" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3411                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3411", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf
Return(aRotina)

//=========================================================================================================//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoProcCubo บAutor  ณPaulo Carnelossi    บ Data ณ 11/02/08  บฑฑ
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
Static Function PcoProcCubo(aProcCube, nNivel, nMoeda, cWhere, aFilesErased, aDtSaldo, aDtIni)
Local cCodCube    := ""
Local cArquivo    := ""
Local cArqSld     := ""
Local cArqTmp     := ""
Local cWhereTpSld := ""
Local cArqAS400   := ""
Local cProcScript := ""
Local cFetch 	  := ""
Local cCampos 	  := ""
Local cValues 	  := ""

Local nX		  := 0
Local nZ		  := 0
Local nQtdVal     := 0
Local nRet 		  := 0
Local nPTratRec   := 0

Local aPeriodo    := {}
Local aTabResult  := {}
Local aQueryDim   := {}
Local aCposQry	  := {}
Local aResult 	  := {}

Local lZerado     := .F.
Local lSintetica  := .F.
Local lTotaliza   := .F.
Local lMovimento  := .F.
Local lRet 		  := .F.

Local cSrvType 	  := Alltrim(Upper(TCSrvType()))
Local lProc 	  := (GetNewPar("MV_PCOCPRC","0")=="1")

Local oStructCube 

//Utilizado para debug
//lProc := MsgYesNo("Utiliza Procedure","PROCEDURE") 

//Processar todas as series(configuracoes) do cubo
For nX := 1 to Len(aProcCube)

    aPeriodo	:= aProcCube[nX, 1]
    nQtdVal		:= Len(aPeriodo)
	oStructCube := aProcCube[nX, 2]
	lZerado 	:= aProcCube[nX, 5]
	lSintetica 	:= aProcCube[nX, 6]
	lTotaliza 	:= aProcCube[nX, 7]
	lMovimento 	:= aProcCube[nX, 9]
	cWhereTpSld := aProcCube[nX, 8]
	cCodCube 	:= oStructCube:cCodeCube

	If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
		//cria arquivo para popular
		PcoCriaTemp(oStructCube, @cArqAS400, nQtdVal,lProc)
		aAdd(aFilesErased, cArqAS400)
    EndIf

	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArquivo, nQtdVal,lProc)
	aAdd(aFilesErased, cArquivo)

	PcoLimpTemp(cArquivo)
	If lProc		
		aCposQry  := {}
		nPTratRec := 0
		cFetch 	  := ""
		cCampos   := ""
		cValues   := ""

		dbSelectArea(cArquivo)
		cNomProc := Subs(cArquivo,1,8)+"PR_"+cEmpAnt
		cProcScript := " CREATE PROCEDURE "+cNomProc
		cProcScript += "("+CRLF
		cProcScript += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
		cProcScript += ")"+CRLF
		cProcScript += "as"+CRLF
		
		For nZ := 1 TO FCOUNT()
			cNomeCpo := FieldName(nZ)
			cCpoAux  := &(cNomeCpo)
			cProcScript += "  DECLARE @"+cNomeCpo+" "+If( Valtype(cCpoAux)=="C", ;
																"Char( "+Alltrim(Str(Len(cCpoAux)))+" )",;
																"Float" ;
																)+" "+CRLF
		Next		
		cProcScript += "Declare @iRecno integer "+CRLF
		cProcScript += "Declare @iNroRegs   Integer "+CRLF
		cProcScript += "Declare @iTranCount  Integer "+CRLF   // --Var.de ajuste para SQLServer e Sybase.
		
		cProcScript  += "begin"+CRLF
		
		cProcScript  += "   Select @iRecno = Null"+CRLF
		cProcScript  += "   select @OUT_RESULT = '0'"+CRLF
		cProcScript  += "   DELETE FROM "+cArquivo+" "+CRLF
		
		cProcScript  += "   Declare POPTEMP"+StrZero(1,2)+" insensitive cursor for"+CRLF
		
	EndIf

	aQryDim 	:= {}
    For nZ := 1 TO oStructCube:nMaxNiveis
		If lSintetica .And. nZ > nNivel			
			aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica, .T./*lForceNoSint*/, lProc/*lProc*/)
    	Else
			aQueryDim := PcoCriaQueryDim(oStructCube, nZ, lSintetica, .F./*lForceNoSint*/, lProc/*lProc*/)
		EndIf	
			
		//aqui fazer tratamento quando expressao de filtro e expressao sintetica nao for resolvida
		If (aQueryDim[2] .And. aQueryDim[3])  //neste caso foi resolvida
			
			If ! aQueryDim[4]
				aAdd( aQryDim, { aQueryDim[1], ""} )
			Else	
				aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
			EndIf
			
		Else  //se filtro ou condicao de sintetica nao foi resolvida pela query			
			If lProc
				aAdd( aQryDim, { aQueryDim[1], If(aQueryDim[4],"' '","")} )
			Else
				aQueryDim := PcoQueryDim(oStructCube, nZ, @cArqTmp, aQueryDim[1] )
				aAdd(aFilesErased, cArqTmp)
				
				If ! aQueryDim[4]
					aAdd( aQryDim, { aQueryDim[1], ""} )
				Else	
					aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
				EndIf
			EndIf
		EndIf	
    Next    
	//criacao das querys para os diversos periodos ( e gerada uma query para cada periodo)	           
	aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, nQtdVal, aDtSaldo, aQryDim, cWhere/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, lMovimento, aDtIni, /*lAllNiveis*/, /*aCposNiv*/, /*lDebito*/, /*lCredito*/, lProc, aCposQry )
	
	If lProc		
		For nZ := 1 TO Len(aCposQry)
			cFetch 	+= " @"+Alltrim( aCposQry[nZ] )+If(nZ<Len(aCposQry),", ","")
			cCampos += Alltrim( aCposQry[nZ] )+", "
			cValues += " @"+Alltrim( aCposQry[nZ] )+", "
		Next
		
		For nZ := 1 TO Len(aQuery)
		
			cProcScript += aQuery[nZ]
			cProcScript += " FOR READ ONLY "+CRLF
			cProcScript += " "+CRLF
			cProcScript += " OPEN POPTEMP"+StrZero(nZ,2)+" "+CRLF
			cProcScript += " Fetch POPTEMP"+StrZero(nZ,2)+" into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012  "+CRLF
			cProcScript += cFetch+" "+CRLF
			cProcScript += " While ( @@Fetch_Status = 0) begin "+CRLF			
			cProcScript += " "+CRLF
			cProcScript += "   If @AKT_SLD"+StrZero(nZ,3)+" <> 0 begin "+CRLF
			cProcScript += "	   select @iNroRegs = @iNroRegs + 1 "+CRLF
			cProcScript += " "+CRLF
			cProcScript += "		If @iNroRegs = 1 begin "+CRLF
			cProcScript += "			begin tran "+CRLF
			cProcScript += "			select @iNroRegs = @iNroRegs "+CRLF
			cProcScript += "		End "+CRLF
			cProcScript += " "+CRLF
			cProcScript += "		select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cArquivo+CRLF
			cProcScript += "	    select @iRecno = @iRecno + 1 "+CRLF
			cProcScript += " "+CRLF
			cProcScript += " ##TRATARECNO @iRecno\" + CRLF
			cProcScript += "	     Insert into "+cArquivo+" ( " //AKT_NIV01, AKT_SLD001, AKT_SLD002, AKT_SLD003, AKT_SLD004, AKT_SLD005, AKT_SLD006, AKT_SLD007, AKT_SLD008, AKT_SLD009, AKT_SLD010, AKT_SLD011, AKT_SLD012, 
			cProcScript += cCampos+"R_E_C_N_O_ ) "+CRLF
			cProcScript += "	                      values( " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 , 
			cProcScript += cValues+"@iRecno ) "+CRLF
			cProcScript += " "+CRLF
			cProcScript += " "+CRLF
			cProcScript += " ##FIMTRATARECNO "+ CRLF
			cProcScript += "  "+CRLF
			cProcScript += " End"+CRLF
			cProcScript += "   Fetch POPTEMP"+StrZero(nZ,2)+" into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 "+CRLF
			cProcScript += cFetch+" "+CRLF
			cProcScript += "	If @iNroRegs >= 4000 begin"+CRLF
			cProcScript += "      commit tran"+CRLF
			cProcScript += "      select @iNroRegs = 0"+CRLF
			cProcScript += "	End"+CRLF
			cProcScript += " "+CRLF
			cProcScript += " End"+CRLF
			cProcScript += " "+CRLF
			cProcScript += " Close POPTEMP"+StrZero(nZ,2)+" "+CRLF
			cProcScript += " Deallocate POPTEMP"+StrZero(nZ,2)+" "+CRLF
			cProcScript += " "+CRLF
			cProcScript += " If @iNroRegs > 0 begin"+CRLF
			cProcScript += "    commit tran"+CRLF
			cProcScript += "    select @iTranCount = 0"+CRLF
			cProcScript += " End"+CRLF
			
			
			If nZ < Len(aQuery)
				cProcScript  += "   Declare POPTEMP"+StrZero(nZ+1,2)+" insensitive cursor for"+CRLF
			EndIf
		
		Next
		
		cProcScript += "		select @OUT_RESULT = '1'"+CRLF
		cProcScript += "	End"+CRLF
		
		cProcScript := CtbAjustaP(.T., cProcScript, @nPTratRec)
		cProcScript := MsParse(cProcScript,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
		cProcScript := CtbAjustaP(.F., cProcScript, nPTratRec)
		
		If !TCSPExist( cNomProc ) .And. !Empty(cProcScript)
			nRet := TcSqlExec(cProcScript)
			If nRet != 0 				
				MsgAlert( STR0079 + cNomProc) //'Erro na criacao da procedure '
				lRet:= .F.			
			Else
				MsgRun( STR0080 , cNomProc , {|| aResult := TCSPEXEC( xProcedures(Left(cNomProc,10))) } ) //"Inserindo registros no arquivo temporแrio...." 
				
				If Empty(aResult) .or. aResult[1] = "0"
					lUsaProc := .F.
					MsgAlert(STR0081 + cNomProc )//"Erro na inclusใo de dados via procedure "
				Endif
		
				nRet := TcSqlExec(" DROP PROCEDURE " + cNomProc)
				If nRet != 0 				
					MsgAlert(STR0082 + cNomProc)//"Erro na exclusao da procedure " 
					lRet:= .F.			
				EndIf	
			EndIf
		EndIf		
	Else	
		//execucao das querys criadas e popular arquivo temporario
		PcoPopulaTemp(oStructCube, cArquivo, aQuery, nQtdVal, lZerado, cArqAS400)
	EndIf
	
	//cria arquivo que contera o resultado da query agrupada 
	PcoCriaTemp(oStructCube, @cArqSld, nQtdVal,lProc)
	aAdd(aFilesErased, cArqSld)
	
	If lProc
		Pco341Final( oStructCube, nNivel, cArqSld/*cAliasSld*/, nQtdVal, cArquivo)	
	Else
		//execucao da query para agrupar os diversos periodos e popular arq temporario que sera usado na consulta
		PcoQryFinal( oStructCube, nNivel, cArqSld/*cAliasSld*/, nQtdVal, cArquivo)
	EndIf

	aAdd( aTabResult, cArqSld )

Next

Return( aTabResult )
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
Static Function Pcoc_AddLin(aView, aProcessa, aTabMail, nLin)
Local nX, nZ

aAdd(aView, {})  //adiciona uma nova linha
aAdd(aView[Len(aView)], "")  //adiciona na linha a primeira coluna (Codigo)
aAdd(aView[Len(aView)], "")  //adiciona na linha a segunda coluna (Descricao)

For nZ := 1 TO Len(aPeriodo)
	For nX := 1 TO aParamCons[6]  //acrescenta uma nova coluna para cada serie
		aAdd(aView[Len(aView)], 0)  
	Next
Next

aAdd(aTabMail, {})  //adiciona uma nova linha
aAdd(aTabMail[Len(aTabMail)], "")  //adiciona na linha a primeira coluna (Codigo)
aAdd(aTabMail[Len(aTabMail)], "")  //adiciona na linha a segunda coluna (Descricao)

For nZ := 1 TO Len(aPeriodo)
	For nX := 1 TO aParamCons[6]  //acrescenta uma nova coluna para cada serie
		aAdd(aTabMail[Len(aTabMail)], Alltrim(Transform(0, "@E 999,999,999,999.99")) )  
	Next
Next

aAdd(aProcessa, {})
aAdd(aProcessa[Len(aProcessa)], "")  
For nZ := 1 TO Len(aPeriodo)
	For nX := 1 TO aParamCons[6]  //acrescenta uma nova coluna para cada serie
		aAdd(aProcessa[Len(aProcessa)], 0)  
	Next
Next

nLin := Len(aView)

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
Static Function Pcoc_AtribVal(aArray, nLin, nCol, xValue)

aArray[nLin, nCol] := xValue

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PCOC341TOk บAutor  ณ Gustavo Henrique   บ Data ณ  17/04/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes gerais na confirmacao dos parametros informados บฑฑ
ฑฑบ          ณ na Parambox inicial.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta de Saldos por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC341TOk()
Local lRet := .T.
lRet := PCOCVldPer(mv_par01,mv_par02)
Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} Pco341Final
Query para grava็ใo do arquivo temporแrio da consulta

@author TOTVS
@since 24/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Pco341Final( oStructCube, nNivel, cAliasSld, nQtdVal, cArqTmp)
Local cQuery	  := ""
Local cFetch   	  := ""
Local cCampos  	  := ""
Local cValues  	  := ""
Local cProcScript := ""
Local cNomProc    := ""
Local cNomeCpo    := ""

Local nZ          := 0
Local nRet		  := 0
Local nPTratRec   := 0

Local lret     	  := .T.

Local aCposQry 	:= {}
Local aResult   := {}
	
dbSelectArea(cAliasSld)

cNomProc := Subs(cAliasSld,1,8)+"PR_"+cEmpAnt
cProcScript := " CREATE PROCEDURE "+cNomProc
cProcScript += "("+CRLF
cProcScript += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
cProcScript += ")"+CRLF
cProcScript += "as"+CRLF

For nZ := 1 TO FCOUNT()
	cNomeCpo := FieldName(nZ)
	cCpoAux  := &(cNomeCpo)
	cProcScript += "  DECLARE @"+cNomeCpo+" "+If( Valtype(cCpoAux)=="C", ;
														"Char( "+Alltrim(Str(Len(cCpoAux)))+" )",;
														"Float" ;
														)+" "+CRLF
Next

cProcScript += "Declare @iRecno integer "+CRLF
cProcScript += "Declare @iNroRegs   Integer "+CRLF
cProcScript += "Declare @iTranCount  Integer "+CRLF   

cProcScript  += "begin"+CRLF

cProcScript  += "   Select @iRecno = Null"+CRLF
cProcScript  += "   select @OUT_RESULT = '0'"+CRLF
cProcScript  += "   DELETE FROM "+cAliasSld+" "+CRLF

cProcScript  += "   Declare POPTEMP insensitive cursor for"+CRLF

cQuery := P341RetQry(nNivel,nQtdVal,cArqTmp,lPostgres,aCposQry)

For nZ := 1 TO Len(aCposQry)
	cFetch 	+= " @"+Alltrim( aCposQry[nZ] )+If(nZ<Len(aCposQry),", ","")
	cCampos += Alltrim( aCposQry[nZ] )+", "
	cValues += "@"+Alltrim( aCposQry[nZ] )+", "
Next

cProcScript += cQuery
cProcScript += " FOR READ ONLY "+CRLF
cProcScript += " "+CRLF
cProcScript += "OPEN POPTEMP "+CRLF
cProcScript += "Fetch POPTEMP into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012  "+CRLF
cProcScript += cFetch+" "+CRLF
cProcScript += "While ( @@Fetch_Status = 0) begin "+CRLF
cProcScript += " "+CRLF
cProcScript += "   select @iNroRegs = @iNroRegs + 1 "+CRLF
cProcScript += " "+CRLF
cProcScript += "   If @iNroRegs = 1 begin "+CRLF
cProcScript += "      begin tran "+CRLF
cProcScript += "      select @iNroRegs = @iNroRegs "+CRLF
cProcScript += "   End "+CRLF
cProcScript += "    "+CRLF
cProcScript += "     select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cAliasSld+CRLF
cProcScript += "     select @iRecno = @iRecno + 1 "+CRLF
cProcScript += "   "+CRLF
cProcScript += "   		##TRATARECNO @iRecno\" + CRLF
cProcScript += "     Insert into "+cAliasSld+" ( " //AKT_NIV01, AKT_SLD001, AKT_SLD002, AKT_SLD003, AKT_SLD004, AKT_SLD005, AKT_SLD006, AKT_SLD007, AKT_SLD008, AKT_SLD009, AKT_SLD010, AKT_SLD011, AKT_SLD012, 
cProcScript += 	cCampos+"R_E_C_N_O_ ) "+CRLF
cProcScript += "                      values( " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 , 
cProcScript += cValues+"@iRecno ) "+CRLF
cProcScript += " "+CRLF
cProcScript += " "+CRLF
cProcScript += " ##FIMTRATARECNO "+ CRLF
cProcScript += "   "+CRLF
cProcScript += "   Fetch POPTEMP into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 "+CRLF
cProcScript += cFetch+" "+CRLF
cProcScript += "   If @iNroRegs >= 4000 begin"+CRLF
cProcScript += "      commit tran"+CRLF
cProcScript += "      select @iNroRegs = 0"+CRLF
cProcScript += "   End"+CRLF
cProcScript += " "+CRLF
cProcScript += " End"+CRLF
cProcScript += " "+CRLF
cProcScript += " Close POPTEMP "+CRLF
cProcScript += " Deallocate POPTEMP "+CRLF
cProcScript += " "+CRLF
cProcScript += " If @iNroRegs > 0 begin"+CRLF
cProcScript += "    commit tran"+CRLF
cProcScript += "    select @iTranCount = 0"+CRLF
cProcScript += " End"+CRLF
cProcScript += "		select @OUT_RESULT = '1'"+CRLF
cProcScript += "	End"+CRLF

cProcScript := CtbAjustaP(.T., cProcScript, @nPTratRec)
cProcScript := MsParse(cProcScript,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cProcScript := CtbAjustaP(.F., cProcScript, nPTratRec)

If !TCSPExist( cNomProc ) .And. !Empty(cProcScript)
	nRet := TcSqlExec(cProcScript)
	If nRet != 0 				
		MsgAlert(STR0079 + cNomProc) //'Erro na criacao da procedure ' 
		lRet:= .F.			
	Else
		MsgRun( STR0080 , cNomProc , {|| aResult := TCSPEXEC( xProcedures(Left(cNomProc,10))) } ) //"Inserindo registros no arquivo temporแrio...." 
		
		If Empty(aResult) .or. aResult[1] = "0"			
			MsgAlert( STR0081 + cNomProc ) //"Erro na inclusใo de dados via procedure " 
		Endif

		nRet := TcSqlExec(" DROP PROCEDURE " + cNomProc)
		If nRet != 0 				
			MsgAlert(STR0082 + cNomProc) //"Erro na exclusao da procedure " 
			lRet:= .F.			
		EndIf	
	EndIf
EndIf

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} Pco341Final
Query para grava็ใo do arquivo temporแrio da consulta

@author TOTVS
@since 24/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P341RetQry(nNivel,nQtdVal,cArqTmp,lPostgres,aCposQry)
Local cQuery := ""
Local nZ     := 0

cQuery := "SELECT AKT_NIV"+StrZero(nNivel,2)+" "
aAdd(aCposQry, "AKT_NIV" + StrZero(nNivel,2))
						
For nZ := 1 TO nQtdVal
	cQuery += ",  SUM(AKT_SLD" + StrZero(nZ,3) +  ") AKT_SLD"+StrZero(nZ,3)
	aAdd(aCposQry, "AKT_SLD" + StrZero(nZ,3))
Next                                        

cQuery += CRLF

cQuery += " FROM ( "

cQuery += "SELECT * FROM "+cArqTmp         //sub-query
cQuery += " ) TMPSALDO "
cQuery += CRLF

cQuery += " GROUP BY AKT_NIV"+StrZero(nNivel,2)
cQuery += CRLF
cQuery += " ORDER BY AKT_NIV"+StrZero(nNivel, 2)
cQuery += CRLF

cQuery := ChangeQuery( cQuery )

Return cQuery