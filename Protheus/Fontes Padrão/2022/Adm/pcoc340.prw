#INCLUDE "pcoc340.ch"
#include "protheus.ch"
#include "msgraphi.ch"

#DEFINE N_COL_VALOR		2

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC340  ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 24/05/05   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta ao arquivo de saldos mensais dos Cubos  ณฑฑ
ฑฑณ          ณ Por Periodo                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC340                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOC340(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC340(nCallOpcx,dIni,dFim,aFilIni,aFilFim,lZerado,nTpPer)

Local bBlock
Local nPos

SaveInter()

Private cCadastro	:= STR0001 //"Consulta Saldos por Periodos - Cubos"
Private aRotina := MenuDef()
Private cArqAKT

If nCallOpcx <> Nil
	nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
	If ( nPos # 0 )
		bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g,h| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g,h) }" )
		Eval( bBlock,Alias(),AL4->(Recno()),nPos,,,,dINi,dFim,aFilIni,aFilFim,lZerado,nTpPer)
	EndIf
Else
	PCOC341(nCallOpcx,dIni,dFim,,,,,lZerado)
EndIf

If GetNewPar("MV_PCOMCHV","1") == '4' .And. cArqAKT  != NIL
	MsErase(cArqAKT)
EndIf

RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco340ViewบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta a grade e o grafico baseado nos parametros บฑฑ
ฑฑบ          ณinformados                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco340View(cAlias,nRecno,nOpcx,xRes1,xRes2,xRes3,dIni,dFim,aFilIni,aFilFim,lZerado,nTpPer)
Local nX, nZ, nY, lRet := .F.
Local aTotProc
Local aProcessa
Local nTpGraph
Local nCfgCubo  := 1
Local aNiveis	 := {}
Local aCuboCfg := {}

Local aCfgAuxCube := {}
Local aAuxCube := {}
Local aSeriesCfg := {}
Local aListArq := {}
Local aTpGrafico

//***********************************************
// Implemantacao do Grafico com FwChartFactory  *
//***********************************************
Private lNewGrafic := SuperGetMV("MV_PCOTPGR",.F.,2) == 1 .and. FindFunction("__FWCBCOMP")
// parametro que informa qual objeto grafico sera utilizado 1= fwChart qquer outra informacao = msGraphic

If lNewGrafic

	aTpGrafico:= {STR0004,; //"1=Linha"
					"2="+SubStr(STR0007,3)}//"4=Barra"

Else

	aTpGrafico:= {STR0004,; //"1=Linha"
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
	
Private aConfig := {}
Private aCfgCub := {}

Private aPrcSldIni := {}
Private nProcCubo := 0

Private aPeriodo
Private aDataPer
Private aColAux
Private COD_CUBO  := AL1->AL1_CONFIG
Private nNivInic := 1
                
DEFAULT dINi := dDataBase
DEFAULT dFim := dDataBase+20
DEFAULT nTpPer	:= 3

If ParamBox({ 	{ 1 ,STR0019,dIni,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
					{ 1 ,STR0020,dFim,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
					{ 2 ,STR0021,nTpPer,{STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0070,STR0077},80,"",.F.},; //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"##'7=Diario'##'8=Trimestral'
					{ 2 ,STR0028,1,{STR0029,STR0030,STR0031,STR0032,STR0033},80,"",.F.},; //"Moeda"###"1=Moeda 1"###"2=Moeda 2"###"3=Moeda 3"###"4=Moeda 4"###"5=Moeda 5"
					{ 2 ,STR0034,4,aTpGrafico,80,"",.F.},; //"Tipo do Grafico"
					{ 1 ,STR0035,nCfgCubo,"" 	 ,""  ,""    ,"" ,50 ,.F. },;	//"Qtd. Series"
					{ 3 ,STR0069, 1,{STR0039,STR0040},40,,.F.} },STR0036,aConfig,{||PCOC340TOk()},,,,,, "PCOC340_01",,.T.) //"Parametros" ### "Sim" ### "Nao"

	For nX := 1 TO aConfig[6]
		&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)),2,0))) := Space(LEN(AL4->AL4_CODIGO))
		&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)+1),2,0))) := 1
		aAdd(aCuboCfg, { 1 ,STR0037+Str(nX, 2,0),Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. }) //"Config.Cubo Serie"
		aAdd(aCuboCfg, { 3 ,STR0038,1,{STR0039,STR0040},40,,.F.}) //"Exibe Configura็๕es"###"Sim"###"Nao"
		aAdd(aCuboCfg, { 1 ,STR0041,STR0042+Str(nx,2,0),"@!" 	 ,""  ,"" ,"" ,75 ,.F. })//"Descri็ใo S้rie"###"Serie "
		aAdd(aCuboCfg, { 3 ,STR0043,1,{STR0044,STR0045,STR0076},95,,.F.}) //"Considerar "###"Saldo final do periodo"###"Movimento do periodo"###"Saldo de Movimento do Perํodo"
		aAdd(aCuboCfg, { 4 ,STR0078,.F.,"",80,,.F.})
	Next
	lRet := .T.
EndIf

P340CLPAR(__cUserID+"_"+"PCOC340_02")

If lRet .And. ParamBox(aCuboCfg, STR0046, aCfgCub,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC340_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"
	nTpPer		:= If(ValType(aConfig[3])=="N", aConfig[3], Val(aConfig[3]))
	aConfig[4]	:= If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4]))
	aPeriodo 	:= PcoRetPer(aConfig[1]/*dIniPer*/, aConfig[2]/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/ , @aDataPer )
   For nX := 1 TO aConfig[6]
		If nX == 1
			aAdd(aPrcSldIni, aCfgCub[nX*4])
			aAdd(aSeriesCfg, Str(nX,1,0)+"="+aCfgCub[nX*4-1])
		Else
			aAdd(aPrcSldIni, aCfgCub[nX*5-1])
			aAdd(aSeriesCfg, Str(nX,1,0)+"="+aCfgCub[nX*5-2])		
		EndIf
   Next
	//processa primeira configuracao do cubo sempre
	nProcCubo := 1
	aAuxCube := {}
	aProcessa := PcoRunCube(AL1->AL1_CONFIG,Len(aPeriodo)*aConfig[6],"PcoC341Sld",aCfgCub[1],aCfgCub[2],aCfgCub[5],aNiveis,aFilIni,aFilFim,NIL /*lRetOriCod*/,aAuxCube,/*lProcessa*/,.T./*lVerAcesso*/,/*lForceNoSint*/,/*aItCfgBlq*/,/*aFiltCfg*/,@cArqAKT, .F./*llimpArqAKT*/)
	aAdd(aCfgAuxCube, aClone(aAuxCube))
	
   	
   	If Len(aProcessa) > 0
	   	//processa a partir da segunda configuracao
	   	For nX := 2 TO aConfig[6]
	
			nProcCubo++
			aAuxCube := {}
			aProcAux := PcoRunCube(AL1->AL1_CONFIG,Len(aPeriodo),"PcoC340Sld",aCfgCub[nX*5-4],aCfgCub[nX*5-3],aCfgCub[nX*5],aClone(aNiveis),aFilIni,aFilFim,NIL /*lRetOriCod*/,aAuxCube,/*lProcessa*/,.T./*lVerAcesso*/,/*lForceNoSint*/,/*aItCfgBlq*/,/*aFiltCfg*/,@cArqAKT, .F./*llimpArqAKT*/)
			aAdd(aCfgAuxCube, aClone(aAuxCube))
			
			If Len(aProcAux) > 0
				For nZ:=1 TO Len(aProcAux)
					nPos := ASCAN(aProcessa, {|aVal| aVal[1] == aProcAux[nZ][1]})
					If nPos > 0 //caso ja exista no cubo (aprocessa) incrementa no periodo de referencia
						For nY := 1 TO Len(aProcAux[nZ][2])
							aProcessa[nPos][2][nX+((nY-1)*aConfig[6])] += aProcAux[nZ][2][nY]
						Next	
					Else // caso nao exista no cubo (aprocessa) adiciona ao cubo
						aAdd(aProcessa, aClone(aProcAux[nZ]))
						
						aProcessa[Len(aProcessa)][2] := {}   //coloca um array vazio e popula zerado
						For nY := 1 TO aConfig[6]*Len(aPeriodo)
							aAdd(aProcessa[Len(aProcessa)][2], 0)
						Next
						//incrementa no cubo os valores do cubo auxiliar
						For nY := 1 TO Len(aProcAux[nZ][2])
							aProcessa[Len(aProcessa)][2][nX+((nY-1)*aConfig[6])] += aProcAux[nZ][2][nY]
						Next
					EndIf
				Next
			EndIf
		Next  	
    EndIf
	If !Empty(aProcessa)
		nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
		//montagem da planilha e grafico
		nNivInic := aNiveis[1]
		PCOC340PFI(aProcessa,nNivInic,,nTpGraph,aNiveis,1,,aCfgCub,,aCfgAuxCube,1/*nSerie*/,aSeriesCfg,,,aListArq)
	Else
		Aviso(STR0047,STR0048,{STR0049},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC340PFI  บAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que exibe a grade e o grafico                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC340PFI(aProcessa,nNivel,cChave,nTpGrafico,aNiveis,nCall,cDescrChv,aCfgCub,cChaveOri,aCfgAuxCube,nSerie,aSeriesCfg,cClasse, lShowGraph, aListArq)
Local oDlg
Local oFolder 
Local oView
Local aArea      := GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local cTexto
Local aSize      := {}
Local aPosObj    := {}
Local aObjects   := {}
Local aInfo      := {}
Local aView      := {}
Local aChave     := {}
Local nx,ny,nZ
Local cDescri    := ""
Local aButtons   := {}
Local oGrafico
Local oLayer,oChart
Local oPanel
Local oPanel1
Local oPanel2
Local bEncerra   := {|| If(nNivel>nNivInic,oDlg:End(),If(Aviso(STR0050,STR0051, {STR0039, STR0040},2)==1, ( PcoArqSave(aListArq), oDlg:End() ), NIL))} //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail   := {}
Local aParam     := {"",.F.,.F.,.F.}
Local aChaveOri  := {}
Local nNivCub    := 0
Local cFiltro
Local lClassView := .F.
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local aTotSer  := {}
Local nColCfg	:= 0

DEFAULT cChave     := ""
DEFAULT cChaveOri  := ""
DEFAULT nSerie     := 1
DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}

If nCall+1 <= Len(aNiveis)
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

aColAux := {}
aAdd(aColAux, cDescri )
aAdd(aColAux, STR0058 )//"Descricao"
For nX := 1 TO Len(aPeriodo)
	nColCfg := 0
	aAdd(aColAux, aPeriodo[nx]+"["+AllTrim(aCfgCub[3])+"]")
	For nZ := 2 TO aConfig[6]
		nColCfg += 5
		aAdd(aColAux, aPeriodo[nx]+"["+AllTrim(aCfgCub[3+nColCfg])+"]")
	Next
Next

aAdd(aTabMail, aClone(aColAux))

aView := C340View(aProcessa, nNivel, cChave, aChave, @cDescri,@aTabMail, aChaveOri, @cFiltro,aCfgAuxCube, nSerie,@lClassView, aTotSer)

If !Empty(aView)                                                

	aView := aSort( aView,,, { |x,y| x[1] < y[1] } )
	aChave := aSort( aChave,,, { |x,y| x[1] < y[1] } )
	aChaveOri := aSort( aChaveOri,,, { |x,y| x[1] < y[1] } )
	aTabMail := aSort( aTabMail,2,, { |x,y| x[1] < y[1] } )
	
	If ! Empty( aView ) .And. aConfig[7] == 1	// Exibe totais das series
		If Len(aTotSer) == 0
			// Atencao ### Foram encontradas inconsist๊ncias entre os movimentos e o cadastro do primeiro nํvel do cubo. O total das s้ries nใo serแ exibido.
			Aviso( STR0050, STR0073, {STR0049})
			aConfig[7] := 2
		Else
			AAdd( aView, { STR0068, "" } ) // TOTAL
			AAdd( aTabMail, { STR0068, Space(50) } ) // TOTAL
			          
			nLenView := Len(aView)
			
			For nx := 1 to Len(aTotSer[1])
				AAdd( aView[nLenView], 0 )
				AAdd( aTabMail[Len(aTabMail)], Alltrim(Transform(0, "@E 999,999,999,999.99")) )
			Next nx

			For nx := 1 to Len(aTotSer)
				For nZ := 1 to Len(aTotSer[nx])
					aView[nLenView,nZ+N_COL_VALOR] += aTotSer[nx,nZ]
				Next nZ
			Next nx

			For nx := 1+N_COL_VALOR to Len(aView[nLenView])
				aTabMail[Len(aTabMail), nX] := Alltrim(Transform(aView[nLenView, nX], "@E 999,999,999,999.99"))
            Next

		EndIf	
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
	oView:SetArray(aView)
	If nCall+1 <= Len(aNiveis)
		oView:blDblClick := { || Iif( PcocChkTot(aConfig,aView,oView), PCOC340PFI(aProcessa,aNiveis[nCall+1],aChave[oView:nAT,1],nTpGrafico,aNiveis,nCall+1,IF(!Empty(cDescrChv),cDescrChv+CHR(13)+CHR(10),"")+Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]),aCfgCub,aChaveOri[oView:nAT,1],aCfgAuxCube, nSerie, aSeriesCfg,If(lClassView,aView[oView:nAT,1],cClasse), @lShowGraph, aListArq), .T.) }
	Else
		oView:blDblClick := {|| Iif( PcocChkTot(aConfig,aView,oView), (C340Sel_Serie(@nSerie, aSeriesCfg),C340MontaFiltro(AL1->AL1_CONFIG, @cFiltro, aCfgAuxCube, nSerie, nNivel, "PCOC340"),Pcoc340lct(cFiltro+aChaveOri[oView:nAT,1]+'"')), .T. ) }
	EndIf
	oView:bChange := { || 	oGrafico:=C340Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aView[oView:nAT],aConfig, @oLayer , @oChart) }

	If lClassView
		oView:bLine := { || PcoFrmDados(aView[oView:nAT],Nil,Iif( PcocChkTot(aConfig,aView,oView), lClassView, Nil ))}
	Else
		oView:bLine := { || PcoFrmDados(aView[oView:nAT],Iif( PcocChkTot(aConfig,aView,oView), cClasse, Nil),Nil)}
	Endif                        
	oGrafico:=C340Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aView[oView:nAT],aConfig, @oLayer , @oChart )
	
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aColAux,aView} } ))
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{|| Eval(bEncerra)},,aButtons )
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC340Grafico บAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta o objeto grafico para exibicao no folder   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340Grafico(aPosObj, oPanel, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValues, aConfig , oLayer , oChart)
Local nZ        := 0
Local ny        := 0
Local oGraphic  
Local nPeriodo	:= 1
Local aSeries	:= {}
Local aColors   := {CLR_BLUE,CLR_GREEN,CLR_RED,CLR_CYAN,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,CLR_YELLOW,CLR_HBLUE}
Local aSerie2	:= {}
Local nColCfg	:= 0

	@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel

	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 15, 25, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	
	For nZ := 1 TO aConfig[6]
		aAdd(aSeries,Nil	)
		aSeries[nz] := oGraphic:CreateSerie( If(lNewGrafic,If(nTpGrafico==2,4,nTpGrafico),nTpGrafico) )
	Next nz                
	
	oGraphic:l3D := .F.
	
	For nZ := 3 To Len(aValues) Step aConfig[6]
		For ny := 1 TO aConfig[6]
			oGraphic:Add(aSeries[ny], Round(aValues[nZ+ny-1],2), aPeriodo[nPeriodo], aColors[ny])
		Next
		nPeriodo++
	Next

	If lNewGrafic
		
		oGraphic:Hide()
		//***********************************************
		// Implemantacao do Grafico com FwChartFactory  *
		//***********************************************
		// Monta Series
		aAdd(aSerie2, AllTrim(aCfgCub[3]))
		nColCfg := 0
		For ny := 2 To aConfig[6]
			nColCfg += 5
			aAdd(aSerie2, AllTrim(aCfgCub[3+nColCfg] ))
		Next
		
		PcoGrafPer(aValues,aPeriodo,nNivel,cChave,oPanel,nTpGrafico,aSerie2,@oLayer,@oChart)
	
	EndIf

Return(oGraphic)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC340View  บAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que retorna o array aview que e exibido na grade e   บฑฑ
ฑฑบ          ณserve de base para montagem do grafico                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340View(aProcessa, nNivel, cChave, aChave, cDescri,aTabMail, aChaveOri, cFiltro, aCfgAuxCube, nSerie, lClassView, aTotSer)
Local nx, nz   := 0
Local aView    := {}         
Local aAuxView := {} 

DEFAULT aTotSer  := {}

For nx := 1 to Len(aProcessa)
	If aProcessa[nx][8] == nNivel .And. (/*Empty(cChave) .Or. */Padr(aProcessa[nx][1],Len(cChave))==cChave)
		cDescri := AllTrim(aProcessa[nx][5])
		aAuxView := {}
		If Empty(cChave)
			aAdd(aAuxView, A340ChaveNivel(aProcessa[nX,1],nNivel))
		Else	
			aAdd(aAuxView, Substr(aProcessa[nx][1],Len(cChave)+1))
		EndIf	
		aAdd(aAuxView, PadR(aProcessa[nx][6], 50))
		If aConfig[7] == 1 .And. !aProcessa[nx,10]
			aAdd(aTotSer,Array(Len(aProcessa[nx,2])))
			aFill(aTotSer[Len(aTotSer)],0)
		EndIf	
		For nZ := 1 TO Len(aProcessa[nx,2])
			aAdd(aAuxView, aProcessa[nx,2,nZ])
			If aConfig[7] == 1 .And. !aProcessa[nx,10]
				aTotSer[Len(aTotSer),nZ] += aProcessa[nx,2,nZ]
			EndIf	
		Next
		aAdd(aView, aAuxView)     
		aAdd(aTabMail,{})                             
		For nZ:=1 To Len(aAuxView)        
			If ValType(aAuxView[nZ]) == "N"
				AAdd(aTabMail[Len(aTabMail)],Alltrim(Transform(aAuxView[nZ], "@E 999,999,999,999.99")))
			Else
				AAdd(aTabMail[Len(aTabMail)],aAuxView[nZ] )
			Endif
		Next
		aAdd(aChave,{aProcessa[nx][1]})
		aAdd(aChaveOri,{aProcessa[nx,9]})
		If aProcessa[nx,4] == 'AK6'
			lClassView := .T.
		Endif

	EndIf
Next

C340MontaFiltro(AL1->AL1_CONFIG, @cFiltro, aCfgAuxCube, nSerie, nNivel, "PCOC340")

Return(aView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC340SldบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que executa o calculo do saldo utilizada pela funcao บฑฑ
ฑฑบ          ณPcoRunCube() (observacao-se mudar algo mudar tb pcoc341sld) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoC340Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny
Local nSldAnt := 0

For ny := 1 to Len(aPeriodo)
   
	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2
	   // PROCESSA CUBO SALDO INICIAL 
//		dIni := CtoD(Subs(aPeriodo[ny], 1, 8))
		dIni := StoD(aDataPer[ny,1])

		aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldIni := nCrdIni-nDebIni
	ElseIf aPrcSldIni[nProcCubo] == 3 .And. ny == 1
		dIni := StoD(aDataPer[ny,1])

		aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldAnt := nCrdIni-nDebIni					
   EndIf
   
   // PROCESSA CUBO SALDO FINAL
//	dFim := CtoD(Subs(aPeriodo[ny],14))
	dFim := StoD(aDataPer[ny,2])

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aConfig[4]]
	nDebFim := aRetFim[2, aConfig[4]]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-(nSldIni+nSldAnt))
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC341SldบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que executa o calculo do saldo utilizada pela funcao บฑฑ
ฑฑบ          ณPcoRunCube()  -- utilizada no primeiro processamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoC341Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny, nZ
Local nSldAnt := 0

For ny := 1 to Len(aPeriodo)

	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2
	   // PROCESSA CUBO SALDO INICIAL 
//		dIni := CtoD(Subs(aPeriodo[ny], 1, 8))
		dIni := StoD(aDataPer[ny,1])

		aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldIni := nCrdIni-nDebIni
	ElseIf aPrcSldIni[nProcCubo] == 3 .And. ny == 1
		dIni := StoD(aDataPer[ny,1])

		aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldAnt := nCrdIni-nDebIni					
   EndIf
   
   // PROCESSA CUBO SALDO FINAL

//	dFim := CtoD(Subs(aPeriodo[ny],14))
	dFim := StoD(aDataPer[ny,2])
	
	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aConfig[4]]
	nDebFim := aRetFim[2, aConfig[4]]

	nSldFim := nCrdFim-nDebFim
	
	aAdd(aRetorno,nSldFim-(nSldIni+nSldAnt))
	
	For nZ := 2 TO aConfig[6]
		aAdd(aRetorno,0)   //aqui coloca os valores zerados para as proximas cfg cubos
	Next                  //para o periodo que esta sendo implementado
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoc340lct  บAutor ณEdson Maricate      บ Data ณ 03/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza lancamento                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pcoc340lct(cFiltroAKD)
Local aArea			:= GetArea()
Local aAreaAKD		:= AKD->(GetArea())
Local aSize			:= MsAdvSize(,.F.,430)
Local aIndexAKD	:= {}
Local aAddBtn		:= {}

PRIVATE bFiltraBrw:= {|| Nil }
Private aRotina 	:= {		{STR0002,"PesqBrw",0,2},;  //"Pesquisar"
									{STR0003,"c340LctView",0,2}}  //"Visualizar"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a Filtragem                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bFiltraBrw := {|| FilBrowse("AKD",@aIndexAKD,@cFiltroAKD) }
Eval(bFiltraBrw)

If AKD->( EoF() )
	Aviso(STR0050,STR0059,{"Ok"})	// Atencao ### Nใo existem lan็amentos para compor o saldo deste cubo.
Else
	If ExistBlock("PCOC3402")
		aAddBtn := ExecBlock("PCOC3402", .F., .F.)
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
ฑฑบPrograma  ณc340LctView บAutor ณEdson Maricate      บ Data ณ 03/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza lancamento                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function c340LctView()
Local aArea	:= GetArea()
Local aAreaAKD	:= AKD->(GetArea())

PCOA050(2)

RestArea(aAreaAKD)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC340MontaFiltroบAutor ณPaulo Carnelossi บ Data ณ 03/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณmonta filtro de acordo a configuracao do cubo               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C340MontaFiltro(cCubo, cFiltro, aCfgAuxCube, nSerie, nNivel, cPrgCall)
Local aAuxCfg := {}, nQtdNiv
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())

Default nNivel := 0

If cPrgCall == "PCOC340"
	cFiltro	:= "AKD->AKD_FILIAL ='"+xFilial("AKD")+"' .And. DTOS(AKD->AKD_DATA) >= '" +DTOS(aConfig[1])+ "' .And. DTOS(AKD->AKD_DATA) <= '" +DTOS(aConfig[2])+"'"
ElseIf cPrgCall == "PCOC330"
	cFiltro	:= "AKD->AKD_FILIAL ='"+xFilial("AKD")+"' .And. DTOS(AKD->AKD_DATA) <= '" +DTOS(aConfig[4])+"'"
EndIf

dbSelectArea("AKW")
dbSetOrder(1)   
dbSeek(xFilial()+AL1->AL1_CONFIG)

While !Eof() .And. AKW->AKW_COD == AL1->AL1_CONFIG 
	aAdd(aAuxCfg, {AKW->AKW_CHAVER, AKW->AKW_TAMANH, Alltrim(AKW->AKW_ALIAS)})
	dbSkip()
End

nQtdNiv := Len(aAuxCfg)

dbSelectArea("AKW")
dbSetOrder(1)   
dbSeek(xFilial()+AL1->AL1_CONFIG)
nNivCub := 1
While !Eof() .And. AKW->AKW_COD == AL1->AL1_CONFIG 
	If nNivCub == nNivel
		cFiltro += ".And. "+alltrim(AKW->AKW_CONCCH)+'== "'
		Exit
	EndIf
	nNivCub++
	dbSkip()
End

RestArea(aAreaAKW)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC340Sel_SerieบAutor  ณPaulo Carnelossi บ Data ณ  03/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Combo para escolher a configuracao desejada para visualizarบฑฑ
ฑฑบ          ณ lancamentos                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340Sel_Serie(nSerie, aSeriesCfg)
/*
Local aConfig := {}

If ParamBox({  { 2 ,STR0056,1,aSeriesCfg,80,"",.F.} },STR0057,aConfig) //"Series (Cfg.Cubo)"###"Selecionar"
   nSerie := If(Valtype(aConfig[1])=="N", aConfig[1], Val(aConfig[1]))
EndIf
*/
Return


Function PcoConsPsq(aDados,lDireto,aParam,oView)
Local lRet 	:= .F.
Local cPesq	:=	""
Local nPsq
DEFAULT lDireto := .F.

If lDireto .Or. ParamBox( { { 1,STR0061 ,Padr(aParam[1],200),"@" 	 ,""  ,""    ,"" ,120 ,.F. },; //"Pesquisar texto"
				{5,STR0062,aParam[2],90,,.F.},;//"Utilizar pesquisa exata"
				{5,STR0063,aParam[3],115,,.F.},;//"Pesquisar a partir do inicio"
				{5,STR0064,aParam[4],100,,.F.}	 }, STR0002, aParam )//"Coincidir maiusculas e minusculas"

	cPesq := aParam[1]
	
	If !aParam[4]
		cTexto := UPPER(aParam[1])
	Else
		cTexto := aParam[1]
	EndIf
		
	If aParam[3] .And. !lDireto
		nInicio := 0
	Else
		nInicio	:=	oView:nAt
	EndIf
	
	If !Empty(cTexto)
		If !aParam[2]
			nPsq := aScan(aDados,{|x|  AllTrim(cTexto)$ Alltrim(x[1]) },nInicio+1)
			If nPsq ==0  
				nPsq := aScan(aDados,{|x|  AllTrim(cTexto)$ Alltrim(x[2]) },nInicio+1)
			Endif
		Else
			nPsq := aScan(aDados,{|x|  Alltrim(x[1])=AllTrim(cTexto)  },nInicio+1)
			If nPsq ==0  
				nPsq := aScan(aDados,{|x|  Alltrim(x[2])=AllTrim(cTexto)  },nInicio+1)
			Endif
		EndIf
		lRet := (nPsq>0)
		If !lRet
			Aviso(STR0002,STR0065+AllTrim(cTexto)+STR0066,{STR0067},2)//"Expressใo: "##" nใo encontrada."##"Ok"
		Else
			oView:nAt	:=	nPsq
			Eval(oView:bChange)
		EndIf
	EndIf
EndIf	

Return lRet

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ STR0003, 	"Pco340View" , 0 , 2} }  //"Visualizar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3401" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3401                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3401", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ A340ChaveNivel บAutor ณ Gustavo Henrique บ Data ณ 24/01/08 บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Retorna somente a chave do nivel do cubo em processamento  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Chave completa do nivel do cubo em processamento   บฑฑ
ฑฑบ          ณ EXPN2 - Nivel do cubo atualmente processado                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta de Saldos por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A340ChaveNivel(cChaveNiv,nNivel)
Local cFilAKW	:= xFilial("AKW")
Local nTamAcum	:= 1

AKW->(dbSetOrder(1))
AKW->(MsSeek(cFilAKW+COD_CUBO))
Do While !AKW->(EoF()) .And. AKW->(cFilAKW+COD_CUBO == AKW_FILIAL+AKW_COD .And. Val(AKW_NIVEL) < nNivel)
	nTamAcum += AKW->AKW_TAMANH
	AKW->(dbSkip())
EndDo
                 
Return(SubStr(cChaveNiv,nTamAcum,AKW->AKW_TAMANH))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PCOC340TOk บAutor  ณ Gustavo Henrique   บ Data ณ  17/04/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes gerais na confirmacao dos parametros informados บฑฑ
ฑฑบ          ณ na Parambox inicial.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta de Saldos por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC340TOk()
Local lRet := .T.
lRet := PCOCVldPer( mv_par01, mv_par02 )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGrafPerบAutor  ณ Acacio Egas        บ Data ณ  10/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de cria็ใo de gafico com o Objeto FwChartFactory    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO P10.R2                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoGrafPer(aValues,aPeriodo,nNivel,cChave,oMain,nTpGrafico,aSeries,oLayer,oChart,lCNiv)

Local aLinha := {}
Local nx,ny,nZ
Local nSaltCol

Default oLayer 	:= nil
Default oChart 	:= nil
Default lCNiv	:= .F.

nSaltCol := If(lCNiv,1,2)

oLayer := FWLayer():New()
oLayer:Init(oMain, .T.)
oLayer:addCollumn( 'Col02', 100, .T. )
oLayer:addWindow( 'Col02', 'Win02', "Grafico",100, .F., .T. )

If Valtype(oChart)=="O"
	FreeObj(@oChart)
Endif

oChart := FWChartFactory():New()
oChart := oChart:getInstance( If(nTpGrafico == 1, LINECHART, BARCOMPCHART ) )
oChart:init( oLayer:getWinPanel( 'Col02', 'Win02' ) )
oChart:SetLegend( CONTROL_ALIGN_RIGHT )
oChart:SetMask( "R$ *@*")
oChart:SetPicture("@E 999,999,999,999.99")

For nx := 1 TO Len(aSeries)
	aAdd( alinha, {nil,{}})
Next

/*For nX := 1 TO Len(aSeries)
	aAdd( alinha, {nil,{}})
	alinha[nX,1] := aSeries[nX]
	nZ := 1
	For nY := nX to Len(aValues)-nSaltCol Step Len(aPeriodo)
		aAdd( alinha[nX,2],{aPeriodo[nZ] ,aValues[nY+nSaltCol]})
		nZ++
	Next
Next*/

nPeriodo := 1
For nZ := nSaltCol+1 To Len(aValues) Step Len(aSeries)
	For ny := 1 TO Len(aSeries)
		alinha[ny,1] := aSeries[ny]
		aAdd( alinha[ny,2],{aPeriodo[nPeriodo], aValues[nZ+ny-1] })
	Next
	nPeriodo++
Next

For nx := 1 TO Len(aSeries)
	oChart:AddSerie(alinha[nx,1], aLinha[nx,2] )
Next
	
oChart:build()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP340CLPAR บAutor  ณ Pedro Pereira Lima บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o arquivo de configura็ใo da parambox estแ no  บฑฑ
ฑฑบ          ณ formato antigo e apaga para gerar o novo.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function P340CLPAR(cFile)
Local cBarra 	:= If(issrvunix(), "/", "\") 
Local cLinha	:= ""
Local nCount   := 1                
Local lDeleta	:= .F.

If File(cBarra + "PROFILE" + cBarra +Alltrim(cFile)+".PRB")
	If FT_FUse(cBarra +"PROFILE"+cBarra+Alltrim(cFile)+".PRB")<> -1
		FT_FGoTop()

		While !FT_FEof()
			cLinha := FT_FReadLn()
			If nCount == 6 .And. SubStr(cLinha,1,1) == "C"
				lDeleta := .T. 
				Exit
			EndIf	
			nCount++
			FT_FSKIP()
		EndDo
	Else
		Return
	EndIf
EndIf

FT_FUse()

If lDeleta
	FErase(cBarra + "PROFILE" + cBarra +Alltrim(cFile)+".PRB")
EndIf

Return
